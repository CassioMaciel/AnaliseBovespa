#!/bin/bash
##################################################################################################################################################
#
##   AnaliseBovespa.sh   ---- Programa destinado a criar graficos de todas as açoes do bovespa rapidamente, permitindo uma rapida análise da bolsa
#
#    Autor e manutentor: Cássio Maciel Lemos <cassio.mac.eng@gmail.com>
#
#-------------------------------------------------------------------------------------------------------------------------------------------------
#
# Esse módulo do programa gera o arquivo HTML para exibição dos graficos
#
# Licença: GPL
#
# ------------------------------------------------------------------------------------------------------------------------------------------------
#
# Change log / Histórico
#
# v0.2 2016-05-15
#	- Versão inicial do programa
#--------------------------------------------------------------------------------------------------------------------------------------------------

echo -e "\
<html> \n \
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"> \n \
<body> \n \
<a href=\"./Favoritos.html\">Favoritos</a><br>" > /var/www/html/index.html

for acao in $(mysql -u 'AnaliseBovespa' -p'1234' -e "SELECT DISTINCT CodigoNegociacao FROM bovespa.cotacao_hist GROUP BY CodigoNegociacao HAVING MIN(TotalNegocios)>10 ;" | tail -n +2) #Order by Volume ( porque do Group ? )
do

	echo -e "<img src=\"/GrafBolsa/$acao.png\"><br>" >> /var/www/html/index.html

done

echo -e "</body>" >> /var/www/html/index.html

