#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DestEmail �Autor  �Leandro F. Silveira � Data �  21/09/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa que ser� chamado nas rotinas de envio de WorkFlow���
���          �  cutomizadas. Ir� carregar os destinat�rios dos e-mails    ���
���          �  conforme cadastrado na tabela ZZR para que n�o tenha que  ���
���          �  ser informado no fonte                                    ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DestEmail(oProcess, cEvento)

	Local cArqTrab := ""
	Local cFiltro  := ""

	dbSelectArea("ZZR")
	cArqTrab := CriaTrab("", .F.)
	
	cFiltro := "ZZR_FILIAL = '" + xFilial("ZZR") + "' .AND. ZZR_EVENTO = '" + AllTrim(cEvento) + "'"
	IndRegua("ZZR", cArqTrab, "ZZR_FILIAL+ZZR_EVENTO",, cFiltro)

	DbGoTop()
	While !Eof()

		If ZZR->ZZR_TIPO == "2"

			If AllTrim(oProcess:cTo) <> ""
				oProcess:cTo += ";" + AllTrim(ZZR->ZZR_EMAIL)
			Else
				oProcess:cTo := AllTrim(ZZR->ZZR_EMAIL)
			EndIf

		Else

			If AllTrim(oProcess:cBCC) <> ""
				oProcess:cBCC += ";" + AllTrim(ZZR->ZZR_EMAIL)
			Else
				oProcess:cBCC := AllTrim(ZZR->ZZR_EMAIL)
			EndIf

		EndIf

		DbSkip()
	End

Return(Nil)