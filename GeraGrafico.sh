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

for acao in $*
do

### CONFIGURAÇÕES GLOBAIS DO GNUPLOT ###

echo "\
set terminal pngcairo size 700,500 enhanced font 'Verdana,10' ; \
set output '/var/www/html/GrafBolsa/$acao.png' ; \
set timefmt \"%Y-%m-%d\" ; \
set title \"$acao\" ; \
set xdata time ; \
set format x \"\" ; \
set style fill solid ; \
set grid; \
set xrange [ * : * ]" > /tmp/$$_Entrada_Gnuplot
#set xrange [ '`date +'%Y-%m-%d' -d"-390 days"`' : * ]" > /tmp/$$_Entrada_Gnuplot

### PLOT DO CANDLESTICK ####

#Candles Verdes

mysql -u 'AnaliseBovespa' -p'1234' -e "SELECT DISTINCT data,Abertura,Minimo,Maximo,Fechamento FROM bovespa.cotacao_hist where CodigoNegociacao = '$acao' AND data > '`date +'%Y-%m-%d' -d"-180 days"`' AND ABERTURA < FECHAMENTO ;" > /tmp/$$_Dados_Para_Candle_Subiu

echo "plot '/tmp/$$_Dados_Para_Candle_Subiu' using 1:2:3:4:5 t '' with candlesticks linecolor 'green', \\" >> /tmp/$$_Entrada_Gnuplot

#Candles vermelhos

mysql -u 'AnaliseBovespa' -p'1234' -e "SELECT DISTINCT data,Abertura,Minimo,Maximo,Fechamento FROM bovespa.cotacao_hist where CodigoNegociacao = '$acao' AND data > '`date +'%Y-%m-%d' -d"-180 days"`' AND ABERTURA > FECHAMENTO ;" > /tmp/$$_Dados_Para_Candle_Desceu

echo "'/tmp/$$_Dados_Para_Candle_Desceu' using 1:2:3:4:5 t '' with candlesticks linecolor 'red', \\" >> /tmp/$$_Entrada_Gnuplot

### FAZENDO O PLOT DOS INDICADORES ###

mysql -u 'AnaliseBovespa' -p'1234' -e "SELECT DISTINCT data,Fechamento FROM bovespa.cotacao_hist where CodigoNegociacao = '$acao' AND data > '`date +'%Y-%m-%d' -d"-220 days"`'" > /tmp/Dados_Fechamento

#Media Movel

Periodos="17 34"

Media_Movel.sh $Periodos

for i in $Periodos
do
echo "'/tmp/MM$i' using 1:2 t 'MMA$i' with lines, \\" >> /tmp/$$_Entrada_Gnuplot
done

### Plotando o grafico ###

gnuplot < /tmp/$$_Entrada_Gnuplot 2> /dev/null

done
