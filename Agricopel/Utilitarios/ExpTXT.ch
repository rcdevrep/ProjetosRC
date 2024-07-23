
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ExpTXT     �Autor  Leandro F. Silveira   Data �  12/01/11  ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa feito com o intuito de auxiliar no diagn�stico    ���
���          � de problemas exportando rotinas SQL para txt               ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������

Como usar:
1 - Adicionar #INCLUDE "ExpTXT.ch" no inicio do fonte
2 - Exemplo de uso: Chamar M�todo - ExpTXT("C:\Teste.txt", cQuery) (exportar� o que tem em cQuery para um TXT no C:\ do cliente

�����������������������������������������������������������������������������
*/

Static Function ExpTXT(cNomArq, cStrExp)

	Local nCont    := ""
	Local nStatus1 := ""

   	cArquivo := AllTrim(cNomArq)
	nHandle  := 0

	If !File(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Else
		FErase(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Endif

	FWrite(nHandle,cStrExp,Len(cStrExp))
	FClose(nHandle)

	MsgAlert("Arquivo exportado em " + cNomArq)

Return