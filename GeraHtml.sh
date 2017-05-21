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

for acao in $*
do

	echo -e "<img src=\"/GrafBolsa/$acao.png\"><br>" >> /var/www/html/index.html

done

echo -e "</body>" >> /var/www/html/index.html

