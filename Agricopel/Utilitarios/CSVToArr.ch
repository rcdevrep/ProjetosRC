
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CSVToArr   �Autor  Leandro F. Silveira   Data �  07/02/17  ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa que preenche o array aDados do parametro com o    ���
���          � conteudo de arquivo cujo caminho informado em cArquivo     ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������

Como usar:
1 - Adicionar #INCLUDE "CSVToArr.ch" no inicio do fonte
2 - Exemplo de uso: Chamar M�todo - CSVToArr(&aDados, "C:\Totvs\Arquivo.csv")
3 - Ser� retornado uma matriz com as linhas e campos do arquivo CSV
4 - ATEN��O: array retornado devolve tamb�m o cabe�alho, na primeira linha

�����������������������������������������������������������������������������
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