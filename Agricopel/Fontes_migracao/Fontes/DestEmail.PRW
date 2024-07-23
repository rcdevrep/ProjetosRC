#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DestEmail ºAutor  ³Leandro F. Silveira º Data ³  21/09/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa que será chamado nas rotinas de envio de WorkFlowº±±
±±º          ³  cutomizadas. Irá carregar os destinatários dos e-mails    º±±
±±º          ³  conforme cadastrado na tabela ZZR para que não tenha que  º±±
±±º          ³  ser informado no fonte                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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