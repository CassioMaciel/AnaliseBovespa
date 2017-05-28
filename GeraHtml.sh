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
<a href=\"./ForcaRelativa.html\">Força Relativa</a><br> \
<a href=\"./Favoritos.html\">Favoritos</a><br>" > /var/www/html/index.html

for acao in $*
do

	echo -e "<img src=\"/GrafBolsa/$acao.png\"><br>" >> /var/www/html/index.html

done

echo -e "</body>" >> /var/www/html/index.html

#---------------------- FORÇA Relativa ----------------------------------------------------------------------

echo -e "\
<html> \n \
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"> \n \
<body> \n" > /var/www/html/ForcaRelativa.html

echo -e "<pre>" >> /var/www/html/ForcaRelativa.html

for Periodo in "\`1 Semana\`"	"\`1 Mes\`"	"\`3 Meses\`"	"\`6 Meses\`"	"\`1 Ano\`"	"\`3 Anos\`"	"\`5 Anos\`"
do
echo "------------------------- $Periodo ----------------------------" >> /var/www/html/ForcaRelativa.html
mysql -u 'AnaliseBovespa' -p'1234' -e "SELECT CodigoNegociacao,$Periodo from bovespa.ForRel order by $Periodo Desc; " >> /var/www/html/ForcaRelativa.html


done

echo -e "</pre>" >> /var/www/html/ForcaRelativa.html
echo -e "</body>" >> /var/www/html/ForcaRelativa.html