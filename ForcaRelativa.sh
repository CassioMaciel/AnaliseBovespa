#!/bin/bash
##################################################################################################################################################
#
##   AnaliseBovespa.sh   ---- Programa destinado a criar graficos de todas as açoes do bovespa rapidamente, permitindo uma rapida análise da bolsa
#
#    Autor e manutentor: Cássio Maciel Lemos <cassio.mac.eng@gmail.com>
#
#-------------------------------------------------------------------------------------------------------------------------------------------------
#
# Esse módulo do programa busca dados de variação no Site da ADVFN e o classifica
#
# Licença: GPL
#
# ------------------------------------------------------------------------------------------------------------------------------------------------

trap "rm /tmp/$$_* 2> /dev/null ; exit" 0 1 2 3 15

mysql -u 'AnaliseBovespa' -p'1234' -e "DROP TABLE bovespa.ForRel;"

mysql -u 'AnaliseBovespa' -p'1234' -e \
"CREATE TABLE bovespa.ForRel ( 
CodigoNegociacao varchar(12) not null,
variacao decimal(11,2),
PRIMARY KEY (CodigoNegociacao)
);"

for acao in $*
do

lynx -source  http://br.advfn.com/bolsa-de-valores/bovespa/$acao/historico > /tmp/$$_CodigoFonte

LinhaInicio=$( grep -n 'Resumo Histórico</h2>'  /tmp/$$_CodigoFonte | sed 's/\(^.*\)\(:.*$\)/'"\1/" )
LinhaFim=$( grep -n 'Cotações Históricas - 1 Mês</h2>'  /tmp/$$_CodigoFonte | sed 's/\(^...\)\(:.*$\)/'"\1/" )

sed -n "$LinhaInicio,$LinhaFim p" /tmp/$$_CodigoFonte > /tmp/$$_TabelaDeInteresse

Variacao=$( grep '>1 Mês' /tmp/$$_TabelaDeInteresse | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed 's/,/./' )

echo "INSERT INTO bovespa.ForRel VALUES ('$acao','$Variacao');" >> /tmp/$$_entradaSQL

done

mysql -u 'AnaliseBovespa' -p'1234' < /tmp/$$_entradaSQL
