#!/bin/bash
##################################################################################################################################################
#
##   AnaliseBovespa.sh   ---- Programa destinado a criar graficos de todas as açoes do bovespa rapidamente, permitindo uma rapida análise da bolsa
#
#    Autor e manutentor: Cássio Maciel Lemos <cassio.mac.eng@gmail.com>
#
#-------------------------------------------------------------------------------------------------------------------------------------------------
#
# Esse programa baixa automaticamente os arquivos históricos e diários da bovespa, faz os gráficos e os coloca em um servidor Apache. Dessa forma,
# pode-se verificar os cerca de 600 ativos do mercado a vista de maneira fácil e rápida.
#
# Licença: GPL
#
# ------------------------------------------------------------------------------------------------------------------------------------------------
#
# Change log / Histórico
#
# v0.0 2016-05-12
#
#	- Foi feito a primeira versão do cabeçalho.
#	- Foi criada a conta do GitHub
#
# v0.1 2016-05-14
#	- Foi criado o arquivo que baixa as cotações e coloca no SQL
#
# v0.2 2016-05-15
#	- Foi feito a geração de gráficos
#	- Foi feita o arquivo que cria o site
#
# v0.3 2016-05-21
#	- Foi melhorado o aspecto beleza dos graficos
#	- Foram colocadas a opção de baixar arquivo diário para o usuario
#	- Foram colocadas opções do tipo --foo no DowCot.Sh
#	- Está começando a se parecer um programa. Acho que podemos chamar de versão Alpha !!! \o/
#
# v0.7 2017-05-17
#	-Foi feito com que o programa Main controle os ativos que vão no Html e no GeraGrafico, de maneira que eles sempre sejam iguais
#	-Add. Script que garante que os ativos com graficos tenham tido negociação todos os dias
#	-Fazendo na sequencia da força relativa
#
####################################################################################################

trap "rm /tmp/$$_* 2> /dev/null ; rm /tmp/MM* ;  exit" 0 1 2 3 15

Query="SELECT DISTINCT CodigoNegociacao FROM bovespa.cotacao_hist WHERE

CodigoNegociacao IN ( 
  SELECT CodigoNegociacao
  FROM bovespa.cotacao_hist
  GROUP by CodigoNegociacao 
  having count(*) = (
    SELECT COUNT(*) 
    FROM bovespa.cotacao_hist
    WHERE CodigoNegociacao = 'PETR4'
    GROUP by CodigoNegociacao
    )
  ) 

AND

CodigoNegociacao IN ( 
  SELECT 
  CodigoNegociacao 
  from bovespa.cotacao_hist WHERE data=(select MAX(data) from bovespa.cotacao_hist) AND fechamento<10
  )
;"

acoes=$( mysql -B -u 'AnaliseBovespa' -p'1234' -B -e "$Query" | tail -n +2 )

./ForcaRelativa.sh $acoes

Query="SELECT CodigoNegociacao from bovespa.ForRel order by variacao Desc;"

mysql -u 'AnaliseBovespa' -p'1234' -B -e "SELECT CodigoNegociacao,variacao from bovespa.ForRel order by variacao Desc; " | tail -n +2 

acoes=$( mysql -B -u 'AnaliseBovespa' -p'1234' -B -e "$Query" | tail -n +2 )

./GeraHtml.sh $acoes

./GeraGrafico.sh $acoes










