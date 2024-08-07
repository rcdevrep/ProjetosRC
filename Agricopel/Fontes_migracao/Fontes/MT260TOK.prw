#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User Function MT260TOK()

Local lRet := .T.  

/*BEGINDOC
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿐ste ponto de entrada sera executado somente para a empresa agricopel atacado.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ENDDOC*/

If cEmpAnt == "01" .and. cFilAnt == "06"

	/*BEGINDOC
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴훏i8�
	//쿣erifica se esta realizando transferencia    �
	//쿾ara produtos com o mesmo codigo             �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴훏i8�
	ENDDOC*/

    If ALLTRIM(USRRETNAME(RETCODUSR())) <> "MARCIO".AND.ALLTRIM(USRRETNAME(RETCODUSR())) <> "CLAUDEMIR".AND.ALLTRIM(USRRETNAME(RETCODUSR())) <> "WAGNER"
		If cCodOrig <> cCodDest
			MsgStop("Aten豫o! Produto origem � diferente do produto destino!")
			lRet := .F.
			Return(lRet)
		EndIf
	Else
	   If AllTrim(cCodOrig) <> AllTrim(cCodDest)
		   If MSGYESNO("Aten豫o! C�digo do produto origem diferente do codigo produto destino! Deseja continuar?")
		      lRet := .T.
	       Else
		      lRet := .F.
	       EndIf
	   EndIf
	EndIf
EndIf

Return(lRet)