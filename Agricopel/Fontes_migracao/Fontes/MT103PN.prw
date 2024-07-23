#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT103PN
Valida��o da Classifica��o da pr�-nota 
Avalia se F1_STATUS est� X (Divergente de pedido de compra)
Avalia se a confer�ncia cega da NF foi emitida e confirmada
@author Leandro F. Silveira
@since 25/11/11
@version 1
@type user function
/*/
User Function MT103PN

	Local lRet   := .T.
	Local cQuery := ""

	If SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "06" .And. !Inclui

		lRet := If(SF1->F1_STATUS == "X", .F., .T.)
		If !lRet
			MsgAlert("Esta pr� nota est� bloqueada por diverg�ncia com pedido de compra e n�o pode ser classificada.")
		Else
			cQuery := ""
			cQuery += "    SELECT ZZK_NUM "
			cQuery += "    FROM " + RetSqlName("ZZK") + " (NOLOCK) "

			cQuery += "    WHERE ZZK_FILIAL = '" + xFilial("ZZK") + "'"
			cQuery += "    AND   ZZK_DOC    = '" + SF1->F1_DOC           + "'"
			cQuery += "    AND   ZZK_SERIE  = '" + SF1->F1_SERIE         + "'"
			cQuery += "    AND   ZZK_EMISSA = '" + DTOS(SF1->F1_EMISSAO) + "'"
			cQuery += "    AND   ZZK_FORNEC = '" + SF1->F1_FORNECE       + "'"

			cQuery += "    AND   D_E_L_E_T_ = '' "

		    If Select("QRY_ZZK") <> 0
		       dbSelectArea("QRY_ZZK")
		   	   dbCloseArea()
		    Endif

			TCQuery cQuery NEW ALIAS "QRY_ZZK"

			if AllTrim(QRY_ZZK->ZZK_NUM) <> ""
			
				dbSelectArea("ZZI")
				ZZI->(dbSeek(xFilial("ZZI")+QRY_ZZK->ZZK_NUM))

			    if ZZI->ZZI_STATUS <> "B"
					lRet := MsgNoYes("Esta pr�-nota possui confer�ncia cega pendente, deseja classific�-la mesmo assim? Conf: " + ZZI->ZZI_NUM)
			    EndIf
			Else
				lRet := MsgNoYes("Esta pr�-nota n�o possui confer�ncia cega, deseja classific�-la mesmo assim?")
			EndIf
		EndIf
	EndIf

Return lRet