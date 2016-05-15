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
