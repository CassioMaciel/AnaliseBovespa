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

mysql -u 'AnaliseBovespa' -p'1234' -e "DROP TABLE IF EXISTS bovespa.ForRel;"

mysql -u 'AnaliseBovespa' -p'1234' -e \
"CREATE TABLE bovespa.ForRel ( 
CodigoNegociacao varchar(12) not null,
\`1 Semana\` decimal(11,2),
\`1 Mes\` decimal(11,2),
\`3 Meses\` decimal(11,2),
\`6 Meses\` decimal(11,2),
\`1 Ano\` decimal(11,2),
\`3 Anos\` decimal(11,2),
\`5 Anos\` decimal(11,2),
PRIMARY KEY (CodigoNegociacao)
);"

 for acao in $*
 do
 	
	lynx -source  http://br.advfn.com/bolsa-de-valores/bovespa/$acao/historico > /tmp/$$_CodigoFonte

	LinhaInicio=$( grep -n 'Resumo Histórico</h2>'  /tmp/$$_CodigoFonte | sed 's/\(^.*\)\(:.*$\)/'"\1/" )
	LinhaFim=$( grep -n 'Cotações Históricas - 1 Mês</h2>'  /tmp/$$_CodigoFonte | sed 's/\(^...\)\(:.*$\)/'"\1/" )

	sed -n "$LinhaInicio,$LinhaFim p" /tmp/$$_CodigoFonte > /tmp/$$_TabelaDeInteresse

	Semana=$( grep '"String Column1\">1 Semana</td>' /tmp/$$_TabelaDeInteresse  | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed s/"\."/''/ | sed 's/,/./' )
	Mes=$( grep 'String Column1\">1 Mês</td>' /tmp/$$_TabelaDeInteresse         | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed s/"\."/''/ | sed 's/,/./' )
	Trimestre=$( grep 'String Column1\">3 Meses</td>' /tmp/$$_TabelaDeInteresse | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed s/"\."/''/ | sed 's/,/./' )
	Semestre=$( grep '"String Column1\">6 Meses</td>' /tmp/$$_TabelaDeInteresse | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed s/"\."/''/ | sed 's/,/./' )
	Ano=$( grep 'String Column1\">1 Ano</td>' /tmp/$$_TabelaDeInteresse         | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed s/"\."/''/ | sed 's/,/./' )
	Triano=$( grep '"String Column1\">3 Anos' /tmp/$$_TabelaDeInteresse         | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed s/"\."/''/ | sed 's/,/./' )
	Pentaano=$( grep 'String Column1\">5 Anos' /tmp/$$_TabelaDeInteresse        | sed s/"^.*<td class=\"Numeric Column10 ColumnLast\">"/''/ | sed s/'%<\/td><\/tr>'/''/ | sed s/"\."/''/ | sed 's/,/./' )
	
	 echo "INSERT INTO bovespa.ForRel VALUES ('$acao','$Semana','$Mes','$Trimestre','$Semestre','$Ano','$Triano','$Pentaano');" >> /tmp/$$_entradaSQL

 done

 grep -v \'\' /tmp/$$_entradaSQL | grep -v '>' > /tmp/$$_EntradaFiltradaSQL
 
 mysql -u 'AnaliseBovespa' -p'1234' < /tmp/$$_EntradaFiltradaSQL