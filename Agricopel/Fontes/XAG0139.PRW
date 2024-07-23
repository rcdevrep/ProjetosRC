#INCLUDE 'Totvs.ch'
#INCLUDE "Protheus.ch"


/*/{Protheus.doc} XAG0139
    (long_description)
    @type  Function
    @author weskley.silva
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function XAG0139(_cEmp)

	Local cQuery := ""
	Local cAlias := ""
	Local nStart := ""
	//Local nStart2h := SomaHoras (nStart,2)
	Local nHora	:= 0
	Local cData  := ""
	Local lRet  := .T.
	Local oApiSF    as object
	Local cAliasSC9
	Local cAliasSC6

	RpcSetType(3)
	RpcSetEnv(_cEmp,'01')

	ConOut("Preparou o ambiente")

	oApiSF := ApiSalesForce():New()

	cAlias 		:= GetNextAlias()
	cData  		:= dtos(ddatabase-60)
	
	cQuery := " SELECT SC5.C5_XIDSF,SC5.C5_NOTA,SC5.C5_NUM,SC5.C5_FILIAL,SC5.C5_LIBEROK,SC5.C5_VEICULO,SC5.C5_BLQ, SC5.S_T_A_M_P_, SC6.S_T_A_M_P_, SC9.S_T_A_M_P_ ,SC5.D_E_L_E_T_ AS DELETADO " + CRLF
	cQuery += " FROM " + RetSqlName('SC5') + " SC5 " + CRLF
	cQuery += " JOIN " + RetSqlName('SC6') + " SC6 ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM   " + CRLF
	cQuery += " JOIN " + RetSqlName('SC9') + " SC9 ON SC9.C9_FILIAL = SC5.C5_FILIAL AND SC9.C9_PEDIDO = SC5.C5_NUM  " + CRLF
	cQuery += " WHERE SC5.C5_XIDSF <> ' ' AND SC5.C5_EMISSAO >= '"+cData+"' " + CRLF
	cQuery += " AND ( CONVERT(char(8), SC5.S_T_A_M_P_, 112) = '" + DtoS(Date()) +"'" + CRLF
	cQuery += " OR CONVERT(char(8), SC6.S_T_A_M_P_, 112) = '" + DtoS(Date()) +"'" + CRLF 
	cQuery += " OR CONVERT(char(8), SC9.S_T_A_M_P_, 112) = '" + DtoS(Date()) +"')" + CRLF

	/*cQuery := " SELECT SC5.C5_XIDSF,SC5.C5_NOTA,SC5.C5_NUM,SC5.C5_FILIAL,SC5.C5_LIBEROK,SC5.C5_VEICULO,SC5.C5_BLQ, SC5.D_E_L_E_T_ AS DELETADO "
	cQuery += " FROM "+RetSqlName("SC5")+" AS  SC5  "
	cQuery += " WHERE SC5.C5_XIDSF <> ' ' AND SC5.C5_EMISSAO >= '"+cData+"' "*/

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAlias, .F., .T.)

	If (cAlias)->(EoF())
		(cAlias)->(DbCloseArea())
		lRet := .F.
	EndIf

	ConOut("Fez a query da SC5")


	cToken := oApiSF:getToken()
	nStart := Time()

	ConOut("Resgatou o token da API")


	IF lRet
		While (cAlias)->(!EoF())
			nHora := ElapTime(nStart, Time())
			IF Val(nHora) >= 2
				cToken := oApiSalesForce:getToken()
				nStart := Time()
			ENDIF
			cQuery := " SELECT top 1 C9_BLCRED, C9_BLEST, C9_NFISCAL FROM "+RetSqlName("SC9")+" WHERE C9_PEDIDO = '"+(cAlias)->C5_NUM+"' AND C9_FILIAL = '"+(cAlias)->C5_FILIAL+"' AND D_E_L_E_T_ = '' AND ( C9_BLCRED <> '' OR C9_BLEST <> '' ) "
			cAliasSC9 := GetNextAlias()

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAliasSC9, .F., .T.)

			Conout('Finalizou a query na SC9')

			cAliasSC6 	:= GetNextAlias()

			cQry := " SELECT C6_FILIAL, C6_NUM, C6_BLQ FROM " + RetSqlName('SC6') + CRLF
			cQry += " WHERE C6_FILIAL = '" + (cAlias)->C5_FILIAL + "'" + CRLF
			cQry += " AND C6_NUM = '" + (cAlias)->C5_NUM + "'" + CRLF
			cQry += " AND C6_BLQ <> '' " + CRLF

			PlsQuery(cQry, cAliasSC6)
			Conout('Finalizou a query na SC6')


			IF !Empty((cAliasSC9)->C9_BLEST) .AND. !Empty((cAliasSC9)->C9_BLCRED) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
				xRet := oApiSF:StatusPed((cAlias)->C5_NUM, (cAlias)->C5_XIDSF, "Bloqueado por crédito", cToken)
			ELSEIF !Empty((cAlias)->C5_VEICULO) .AND. Empty((cAlias)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
				xRet := oApiSF:StatusPed((cAlias)->C5_NUM, (cAlias)->C5_XIDSF, "Programado", cToken)
			ELSEIF !Empty((cAlias)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
				xRet := oApiSF:StatusPed((cAlias)->C5_NUM, (cAlias)->C5_XIDSF, "Faturado", cToken)
			ELSEIF !Empty((cAliasSC9)->C9_BLEST) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
				xRet := oApiSF:StatusPed((cAlias)->C5_NUM, (cAlias)->C5_XIDSF, "Bloqueado por estoque", cToken)
			ELSEIF !Empty((cAliasSC9)->C9_BLCRED) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
				xRet := oApiSF:StatusPed((cAlias)->C5_NUM, (cAlias)->C5_XIDSF, "Bloqueado por crédito", cToken)
			ELSEIF Empty((cAlias)->C5_NOTA) .and. (cAlias)->C5_LIBEROK == "S" .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
				xRet := oApiSF:StatusPed((cAlias)->C5_NUM, (cAlias)->C5_XIDSF, "Liberado", cToken)
			ELSEIF !(cAliasSC6)->(EoF()) .OR. !Empty((cAlias)->DELETADO) .OR. !Empty((cAlias)->DELETADO)
				xRet := oApiSF:StatusPed((cAlias)->C5_NUM, (cAlias)->C5_XIDSF, "Cancelado", cToken)
			EndIF

			Conout('Integrou o pedido: ' + (cAlias)->C5_NUM + (cAlias)->C5_FILIAL)

			(cAliasSC6)->(DbCloseArea())
			(cAliasSC9)->(DbCloseArea())
			(cAlias)->(DBSKIP())

		Enddo
	Endif

	Conout('Finalizou a integração')
Return
