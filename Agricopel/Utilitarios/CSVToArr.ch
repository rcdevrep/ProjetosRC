
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CSVToArr   บAutor  Leandro F. Silveira   Data ณ  07/02/17  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa que preenche o array aDados do parametro com o    นฑฑ
ฑฑบ          ณ conteudo de arquivo cujo caminho informado em cArquivo     นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ

Como usar:
1 - Adicionar #INCLUDE "CSVToArr.ch" no inicio do fonte
2 - Exemplo de uso: Chamar M้todo - CSVToArr(&aDados, "C:\Totvs\Arquivo.csv")
3 - Serแ retornado uma matriz com as linhas e campos do arquivo CSV
4 - ATENวรO: array retornado devolve tamb้m o cabe็alho, na primeira linha

฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CSVToArr(aDados, cArquivo)

	Local nPos
	Local x
	Local nIni
	Local cLinha    := ""
	Local aLinha    := {}
	Local cCab      := ""
	Local i         := 0
	Local nCols     := 0

	aDados := {}

	If (!File(cArquivo))
		Return()
	Endif

	// Abrindo o arquivo
	FT_FUse(cArquivo)
	FT_FGoTop()

	// Capturando as linhas do arquivo
	Do While (!FT_FEof())

		cLinha := FT_FReadln()
		aLinha := Separa(cLinha, ";", .T.)

		AADD(aDados, aLinha)

		FT_FSkip()
	Enddo

	FT_FUse()

Return()