#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} FT400CAB
Este ponto de entrada permite efetuar a alteração ou inclusão de dados 
nas variáveis de memória referente ao cabeçalho do pedido de venda (SC5).

@since 17/07/2020
@type function
/*/
User Function FT400CAB()

	Local aSeg := GetArea()

	If (ADA->(FieldPos("ADA_XVEND6")) > 0 .And. VALTYPE(M->C5_VEND6) <> "U" .and. VALTYPE(ADA->ADA_XVEND6) <> "U")
		M->C5_VEND6 := ADA->ADA_XVEND6
	EndIf

	If (ADA->(FieldPos("ADA_XVEND7")) > 0 .And. VALTYPE(M->C5_VEND7) <> "U" .and. VALTYPE(ADA->ADA_XVEND7) <> "U")
		M->C5_VEND7 := ADA->ADA_XVEND7
	EndIf

	If (ADA->(FieldPos("ADA_XVEND8")) > 0 .And. VALTYPE(M->C5_VEND8) <> "U" .and. VALTYPE(ADA->ADA_XVEND8) <> "U")
		M->C5_VEND8 := ADA->ADA_XVEND8
	EndIf

	If (SM0->M0_CODIGO == "01" .And. (Alltrim(SM0->M0_CODFIL) == "03" .or. Alltrim(SM0->M0_CODFIL) == "15" .or. Alltrim(SM0->M0_CODFIL) == "16"))
		_cTranspSM0 := TranspSM0()

		If (!Empty(_cTranspSM0))
			M->C5_TRANSP := _cTranspSM0
		EndIf
	EndIf

	RestArea(aSeg)

Return (.T.)

Static Function TranspSM0()

	Local _cQuery := ""
	Local _cAlias := ""
	Local _cRet   := ""

	_cQuery := " SELECT SA4.A4_COD "
	_cQuery += " FROM " + RetSqlName("SA4") + " SA4 WITH (NOLOCK) "
	_cQuery += " WHERE SA4.D_E_L_E_T_ = '' "
	_cQuery += " AND   SA4.A4_FILIAL = '" + xFilial("SA4") + "'"
	_cQuery += " AND   SA4.A4_CGC =  '" + SM0->M0_CGC + "'"

	_cAlias := MpSysOpenQuery(_cQuery)

	_cRet := (_cAlias)->A4_COD

	(_cAlias)->(DbCloseArea())

Return(_cRet)
