
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GetArq     �Autor  Leandro F. Silveira   Data �  07/02/17  ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa que lista em um array os arquivos existentes no   ���
���          � diretorio e subdiretorio conforme parametro recebido       ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������

Como usar:
1 - Adicionar #INCLUDE "GetArq.ch" no inicio do fonte
2 - Exemplo de uso: Chamar M�todo - GetArq("C:\Totvs\Agricopel\")
3 - Ser� retornado uma matriz[][] com os arquivos
3.1 - O primeiro item do array ser� o nome com extens�o do arquivo
3.2 - O segundo item do array ser� o diret�rio do arquivo

�����������������������������������������������������������������������������
*/

Static Function GetArq(cCaminho)

	Local aRet          := {}
	Local aArqDir       := {}
	Local aArqSubDir    := {}
	Local cArqDir       := ""
	Local i 		    := 0
	Local j 		    := 0
	Local cDiretorio    := StrTran(cCaminho, "*.*", "")
	Local nLenArqDir    := 0
	Local nLenArqSubDir := 0

	aArqDir := Directory(cCaminho, "D")

	nLenArqDir := Len(aArqDir)
	For i := 1 To nLenArqDir
		cArqDir := Lower(aArqDir[i][1])

		If (aArqDir[i][5] == "A")
			aAdd(aRet, {cArqDir, cDiretorio})
		Else
			If (aArqDir[i][5] == "D" .And. cArqDir <> "." .And. cArqDir <> ".." .And. ExistDir(cDiretorio + cArqDir))
				aArqSubDir := GetArq(cDiretorio + cArqDir + "\*.*")

				nLenArqSubDir := Len(aArqSubDir)
				For j := 1 To nLenArqSubDir
					aAdd(aRet, aArqSubDir[j])
				End
			EndIf
		EndIf
	End

Return(aRet)