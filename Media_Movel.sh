#!/bin/bash
##################################################################################################################################################
#
##   AnaliseBovespa.sh   ---- Programa destinado a criar graficos de todas as açoes do bovespa rapidamente, permitindo uma rapida análise da bolsa
#
#    Autor e manutentor: Cássio Maciel Lemos <cassio.mac.eng@gmail.com>
#
#-------------------------------------------------------------------------------------------------------------------------------------------------
#
# Esse programa calcula uma média móvel a partir de uma base de dados e então cola essa média a base
#
# Licença: GPL
#
# ------------------------------------------------------------------------------------------------------------------------------------------------
#
# Change log / Histórico
#
# v0.2 2016-05-25
#	-Versão inicial do programa
#
#--------------------------------------------------------------------------------------------------------------------------------------------------
trap "rm /tmp/$$_* 2> /dev/null ; exit" 0 1 2 3 15

Help="\
Esse programa calcula uma média móvel a partir de uma base de dados e então cola essa média a base \
uso: Media_Movel \"/tmp/<arquivo>\" 9 21 200"

Base_De_Dados=/tmp/Dados_Fechamento

Coluna_Media=2

Periodos_Entrada=$@


for Periodos in `echo $Periodos_Entrada`
do

	#Essa linha são os dados São formatados mais ou menos para entrar no programa Bc, conforme abaixo.
	#5.04+4.92+4.87+4.89+4.87+5.14+5.31+5.65+6.57
	Dados_Para_Soma=$( cat $Base_De_Dados | cut -f$Coluna_Media | tail -n +2 | tr '\n' + | sed 's/+$//' ) 

	#Constroi o inicio da variavel de médias móveis, onde os $Periodos-1 não existem, e portanto estão preenchidos por @ e o separador é ;
	MM="MM$Periodos;"$(seq 1 $(( $Periodos-1 )) | sed s/.*/@/ | tr '\n' ';' )


	while test '1' -ne '2' #Calcula a Média para cada dia
	do
		#calcula a média e joga na variavel MM
		MM=$MM$( echo $Dados_Para_Soma | cut -f1-$Periodos -d+ | sed s/'\(.*\)'/"scale=3 ; (\1)\/$Periodos"/ | bc )';'
		Dados_Para_Soma=$( echo $Dados_Para_Soma | cut -f2- -d+ ) > /dev/null #Retira o primeiro dado
	
		test $( echo $Dados_Para_Soma | cut -f1-$Periodos -d+ | sed s/[^+]//g | wc -m ) -eq $Periodos || break
	
	done

	echo $MM | sed 's/;/\n/g ; s/@/ /g' > /tmp/$$_Arq_Saida
	cat $Base_De_Dados |cut -f1 > /tmp/$$_Datas
	paste /tmp/$$_Datas /tmp/$$_Arq_Saida > /tmp/MM$Periodos

done

exit 0
