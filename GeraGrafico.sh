#!/bin/bash
##################################################################################################################################################
#
##   AnaliseBovespa.sh   ---- Programa destinado a criar graficos de todas as açoes do bovespa rapidamente, permitindo uma rapida análise da bolsa
#
#    Autor e manutentor: Cássio Maciel Lemos <cassio.mac.eng@gmail.com>
#
#-------------------------------------------------------------------------------------------------------------------------------------------------
#
# Esse módulo do programa gera os graficos a partir da base de dados SQL 
#
# Licença: GPL
#
# ------------------------------------------------------------------------------------------------------------------------------------------------
#
# Change log / Histórico
#
# v0.2 2016-05-15
#	-Versão inicial do programa
#
#--------------------------------------------------------------------------------------------------------------------------------------------------

trap "rm /tmp/$$_* 2> /dev/null ; exit" 0 1 2 3 15

rm /var/www/html/GrafBolsa/* 2> /dev/null

for acao in $(mysql -u 'AnaliseBovespa' -p'1234' -e "SELECT DISTINCT CodigoNegociacao FROM bovespa.cotacao_hist GROUP BY CodigoNegociacao HAVING MIN(TotalNegocios)>30 ;" | tail -n +2)
do

	mysql -u 'AnaliseBovespa' -p'1234' -e "SELECT DISTINCT data,Abertura,Minimo,Maximo,Fechamento FROM bovespa.cotacao_hist where CodigoNegociacao = '$acao' AND data > '`date +'%Y-%m-%d' -d"-180 days"`' ;" > /tmp/$$_Dados_Para_Candle

Media_Movel.sh "/tmp/$$_Dados_Para_Candle"

gnuplot -e  "\
set terminal pngcairo size 700,500 enhanced font 'Verdana,10' ; \
set output '/var/www/html/GrafBolsa/$acao.png' ; \
set timefmt \"%Y-%m-%d\" ; \
set title \"$acao\" ; \
set xdata time ; \
set format x \"\" ; \
set xrange [ '`date +'%Y-%m-%d' -d"-90 days"`' : * ] ; \
plot '/tmp/$$_Dados_Para_Candle' using 1:2:3:4:5 t ''     with candlesticks , \
     '/tmp/$$_Dados_Para_Candle' using 1:6       t 'MM9'  with lines, \
     '/tmp/$$_Dados_Para_Candle' using 1:7       t 'MM21' with lines"

done
