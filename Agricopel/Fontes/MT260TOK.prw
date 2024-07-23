#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User Function MT260TOK()

Local lRet := .T.  

/*BEGINDOC
//������������������������������������������������������������������������������Ŀ
//�Este ponto de entrada sera executado somente para a empresa agricopel atacado.�
//��������������������������������������������������������������������������������
ENDDOC*/

If cEmpAnt == "01" .and. cFilAnt == "06"

	/*BEGINDOC
	//�������������������������������������������ci8�
	//�Verifica se esta realizando transferencia    �
	//�para produtos com o mesmo codigo             �
	//�������������������������������������������ci8�
	ENDDOC*/

    If ALLTRIM(USRRETNAME(RETCODUSR())) <> "MARCIO".AND.ALLTRIM(USRRETNAME(RETCODUSR())) <> "CLAUDEMIR".AND.ALLTRIM(USRRETNAME(RETCODUSR())) <> "DIONATAN.C"
		If cCodOrig <> cCodDest
			MsgStop("Aten��o! Produto origem � diferente do produto destino!")
			lRet := .F.
			Return(lRet)
		EndIf
	Else
	   If AllTrim(cCodOrig) <> AllTrim(cCodDest)
		   If MSGYESNO("Aten��o! C�digo do produto origem diferente do codigo produto destino! Deseja continuar?")
		      lRet := .T.
	       Else
		      lRet := .F.
	       EndIf
	   EndIf
	EndIf
EndIf

Return(lRet)
