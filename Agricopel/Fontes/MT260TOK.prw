#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User Function MT260TOK()

Local lRet := .T.  

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Este ponto de entrada sera executado somente para a empresa agricopel atacado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

If cEmpAnt == "01" .and. cFilAnt == "06"

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄci8¿
	//³Verifica se esta realizando transferencia    ³
	//³para produtos com o mesmo codigo             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄci8Ù
	ENDDOC*/

    If ALLTRIM(USRRETNAME(RETCODUSR())) <> "MARCIO".AND.ALLTRIM(USRRETNAME(RETCODUSR())) <> "CLAUDEMIR".AND.ALLTRIM(USRRETNAME(RETCODUSR())) <> "DIONATAN.C"
		If cCodOrig <> cCodDest
			MsgStop("Atenção! Produto origem é diferente do produto destino!")
			lRet := .F.
			Return(lRet)
		EndIf
	Else
	   If AllTrim(cCodOrig) <> AllTrim(cCodDest)
		   If MSGYESNO("Atenção! Código do produto origem diferente do codigo produto destino! Deseja continuar?")
		      lRet := .T.
	       Else
		      lRet := .F.
	       EndIf
	   EndIf
	EndIf
EndIf

Return(lRet)
