#!/bin/bash
##################################################################################################################################################
#
##   AnaliseBovespa.sh   ---- Programa destinado a criar graficos de todas as açoes do bovespa rapidamente, permitindo uma rapida análise da bolsa
#
#    Autor e manutentor: Cássio Maciel Lemos <cassio.mac.eng@gmail.com>
#
#-------------------------------------------------------------------------------------------------------------------------------------------------
#
# Esse módulo doprograma baixa automaticamente os arquivos históricos e diários da bovespa, e os coloca no servidor SQL para que possa ser utilizado pelo resto do AnaliseBovespa
#
# Licença: GPL
#
# ------------------------------------------------------------------------------------------------------------------------------------------------
#
# Change log / Histórico
#
# v0.1 2016-05-14
#
#	- Feito a primeira versão do programa.
#
#--------------------------------------------------------------------------------------------------------------------------------------------------

# Layout do arquivo de cotações
# http://www.bmfbovespa.com.br/lumis/portal/file/fileDownload.jsp?fileId=8A828D294E9C618F014EB7924B803F8B

#--------------------------------------------------------------------------------------------------------------------------------------------------

trap "rm /tmp/$$_* ; exit" 0 1 2 3 15

Ano='2016'

#wget -c "http://bvmf.bmfbovespa.com.br/InstDados/SerHist/COTAHIST_A$Ano.ZIP" -O /tmp/$$_CotHist.ZIP

cp /tmp/CotHist.Zip /tmp/$$_CotHist.ZIP  #FIXME : linha adicionada apenas para não ficar baixando o tempo inteiro as cotações, descomentar a de cima.

unzip /tmp/$$_CotHist.ZIP -d /tmp/

mv /tmp/COTAHIST_A$Ano.TXT /tmp/$$_COTAHIST.TXT


#-------------------------------------------------------------------------------------------------------------------------------------------------

#Essa parte do programa retira do aquivo as partes que são importantes seguindo o Layout do arquivo de cotações

grep '^01......................010' /tmp/$$_COTAHIST.TXT > /tmp/$$_ArqTmp.TXT  #01 são cotações (Existem cabeçalhos) , 010 mercado a vista.

mv /tmp/$$_ArqTmp.TXT /tmp/$$_COTAHIST.TXT  # Não é possivel em Shell a entrada ser no mesmo arquivo da saida, por isso tive de usar um arquivo temporario

cut -c3-10 /tmp/$$_COTAHIST.TXT > /tmp/$$_Datas

cut -c13-24 /tmp/$$_COTAHIST.TXT > /tmp/$$_Codigo_de_Negociacao

cut -c57-69 /tmp/$$_COTAHIST.TXT > /tmp/$$_Preco_de_Abertura

cut -c70-82 /tmp/$$_COTAHIST.TXT > /tmp/$$_Preco_Maximo

cut -c83-95 /tmp/$$_COTAHIST.TXT > /tmp/$$_Preco_Minimo

cut -c96-108 /tmp/$$_COTAHIST.TXT > /tmp/$$_Preco_Medio

cut -c109-121 /tmp/$$_COTAHIST.TXT > /tmp/$$_Preco_Fechamento

cut -c148-152 /tmp/$$_COTAHIST.TXT > /tmp/$$_Total_de_Negocios

cut -c171-188 /tmp/$$_COTAHIST.TXT > /tmp/$$_Volume

#------------------------------------------------------------------------------------------------------------------------------------------------

# Parte do programa que cuida da manipulação dos dados

sed s/'\(....\)\(..\)\(..\)'/"\'\1-\2-\3\'"/ /tmp/$$_Datas > /tmp/$$_ArqTmp.TXT #Colocando a data no formato que o SQL lê  AAAA-MM-DD 

mv /tmp/$$_ArqTmp.TXT /tmp/$$_Datas


#Retirando espaços em branco dos Códigos de Negociação para economizar espaço de armazenamento.
sed s/' *$'/''/ /tmp/$$_Codigo_de_Negociacao > /tmp/$$_ArqTmp.TXT  

#Colocando as aspas nos Cósdigos de negociação
sed s/'\(.*\)'/"\'\1\'"/ /tmp/$$_ArqTmp.TXT > /tmp/$$_Codigo_de_Negociacao

#Tirando os 0 a esquerda e colocando aspas no total de negocios
sed s/'^0*'/''/ /tmp/$$_Total_de_Negocios | sed s/'\(.*\)'/"\'\1\'"/ > /tmp/$$_ArqTmp.TXT

mv /tmp/$$_ArqTmp.TXT /tmp/$$_Total_de_Negocios




for i in /tmp/$$_Preco_de_Abertura /tmp/$$_Preco_Maximo /tmp/$$_Preco_Minimo /tmp/$$_Preco_Medio /tmp/$$_Preco_Fechamento /tmp/$$_Volume
do

	sed s/'\(..\)$'/".\1"/ $i > /tmp/$$_ArqTmp.TXT  # colocando o separado de decimais nos preços
	# Retirando os 0 do inicio do arquivo dos preços, para reduzir consumo de memoria e colocando as aspas na entrada
	sed s/'^0*'/''/ /tmp/$$_ArqTmp.TXT | sed s/'\(.*\)'/"\'\1\'"/ > $i  

done

#------------------------------------------------------------------------------------------------------------------------------------------------

#criando o arquivo de saida para inserir no SQL

paste -d, /tmp/$$_Codigo_de_Negociacao /tmp/$$_Datas /tmp/$$_Preco_de_Abertura /tmp/$$_Preco_Maximo /tmp/$$_Preco_Minimo /tmp/$$_Preco_Fechamento \
/tmp/$$_Preco_Medio /tmp/$$_Total_de_Negocios /tmp/$$_Volume > /tmp/$$_ArqTmp.TXT

#sed 's'/'\(.*\)'/'INSERT INTO bovespa.cotacao_hist (CodigoNegociacao,Data,Abertura,Maximo,Minimo,Fechamento,Medio,TotalNegocios,Volume) VALUES (\1\);'/  /tmp/$$_ArqTmp.TXT  > /tmp/$$_Entrada_SQL

sed 's'/'\(.*\)'/'INSERT INTO bovespa.cotacao_hist VALUES (\1\);'/  /tmp/$$_ArqTmp.TXT > /tmp/$$_Entrada_SQL

#-------------------------------------------------------------------------------------------------------------------------------------------------

#Manipulando SQL server

mysql -u 'AnaliseBovespa' -p'1234' -e "DROP DATABASE bovespa"

mysql -u 'AnaliseBovespa' -p'1234' -e "CREATE DATABASE bovespa"

mysql -u 'AnaliseBovespa' -p'1234' -e \
"CREATE TABLE bovespa.cotacao_hist ( \
CodigoNegociacao varchar(12) not null,
data date,
Abertura decimal(11,2),
Maximo decimal(11,2),
Minimo decimal(11,2),
Fechamento decimal(11,2),
Medio decimal(11,2),
TotalNegocios int(5),
Volume decimal(16,2),
PRIMARY KEY (CodigoNegociacao, data)
)"

mysql -u 'AnaliseBovespa' -p'1234' < /tmp/$$_Entrada_SQL











