#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT103PN
Validação da Classificação da pré-nota 
Avalia se F1_STATUS está X (Divergente de pedido de compra)
Avalia se a conferência cega da NF foi emitida e confirmada
@author Leandro F. Silveira
@since 25/11/11
@version 1
@type user function
/*/
User Function MT103PN

	Local lRet   := .T.
	Local cQuery := ""
	Local _nPosORIG  := aScan(aHeader,{|x|Alltrim(x[2])=="D1_ORIIMP"}) 

	//Valida e Ajusta dados da 
	/*If _nPosORIG > 0 .and. Type('l103Class') == 'L' .and. Len(aCols) > 0  .And. !Inclui
		If alltrim(aCols[1][_nPosORIG]) == 'SMS001'.and. l103Class
			AjustaImp() 
		Endif 
	Endif 
	*/
	If SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06" .And. !Inclui

		lRet := If(SF1->F1_STATUS == "X", .F., .T.)
		If !lRet
			MsgAlert("Esta pré nota está bloqueada por divergência com pedido de compra e não pode ser classificada.")
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
					lRet := MsgNoYes("Esta pré-nota possui conferência cega pendente, deseja classificá-la mesmo assim? Conf: " + ZZI->ZZI_NUM)
			    EndIf
			Else
				lRet := MsgNoYes("Esta pré-nota não possui conferência cega, deseja classificá-la mesmo assim?")
			EndIf
		EndIf
	EndIf

Return lRet
