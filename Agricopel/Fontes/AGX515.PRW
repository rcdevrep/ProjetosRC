#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

// ROTINA JA VERIFICADA VIA XAGLOGRT

User Function AGX515(cPedido,cCliCod,cCliLoja,nTotalPed)

	Local cSerasa  := GetMV("MV_CONSER")  //Consulta Serasa.

	Local lBlqCre  := .F.
	Local lBlqCre2 := .F.
	Local cCgc     := ""
	Local cTipoPes := ""
	Local dUltComp := ""
	Local cRisco   := ""
	Local cQuery   := ""
	Local nSalCred := 0

	If cSerasa <> "S"
		Return()
	EndIf

	//Busco informacoes do cliente.
	dbSelectArea("SA1")
	dbSetOrder(1)
	If !DbSeek(xFilial("SA1")+cCliCod+cCliLoja)
		Alert("Problema grave! Cliente não encontrado para análise de crédito SERASA (AGX515)")
		Return()
	EndIf

	// Verifica se no cliente esta setado para o mesmo consultar a serasa
	If SA1->A1_CONSER <>  "1"
		Return()
	EndIf

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se o pedido ja possui alguma restricao de credito³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/

	cQuery := " SELECT R_E_C_N_O_, C9_BLCRED, C9_QTDLIB, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO "
	cQuery += " FROM " + RetSqlName("SC9") + " (NOLOCK) "
	cQuery += " WHERE C9_PEDIDO = '" + cPedido + "'"
	cQuery += " AND C9_FILIAL = '" + xFilial("SC9") + "'"
	cQuery += " AND D_E_L_E_T_ = '' "

	If Select("MSC9") <> 0
		dbSelectArea("MSC9")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "MSC9"

	lBlqCre := .F.
	dbSelectArea("MSC9")
	dbGoTop()
	While !Eof()
		If MSC9->C9_BLCRED == "01"
			lBlqCre := .T.
		EndIf
		MSC9->(dbSkip())
	EndDo

	//Se o Cliente possui outras restricoes dentro da empresa realiza o bloqueio do pedido.
	dbSelectArea("SA1")
	cCgc     := AllTrim(SA1->A1_CGC)
	cTipoPes := SA1->A1_PESSOA
	dUltComp := SA1->A1_ULTCOM
	cRisco   := SA1->A1_RISCO
	cConSer  := SA1->A1_CONSER
	nSalCred := SA1->A1_LC - SA1->A1_SALDUPM - SA1->A1_SALPEDL - SA1->A1_SALPEDB - nTotalPed
	cCliCod  := SA1->A1_COD
	cCliLoj  := SA1->A1_LOJA

	nDifMes := DateDiffMonth( dUltComp, ddatabase )

	If nDifMes > 9
		lBlqCre2 := .T.
	EndIf

	If alltrim(dtos(dUltComp)) == ""
		lBlqCre2  := .T.
	EndIf

	//Se não tiver restricao de credito bloqueia pelas restricoes da empresa.
	If lBlqCre2 .and. !lBlqCre
		dbSelectArea("MSC9")
		dbGoTop()
		While !eof()

			dbSelectArea("SC9")
			dbSetOrder(1)
			If dbSeek(xFilial("SC9")+MSC9->C9_PEDIDO+MSC9->C9_ITEM+MSC9->C9_SEQUEN+MSC9->C9_PRODUTO)
				RecLock("SC9",.F.)
				SC9->C9_BLCRED := "01"
				MsUnlock()
			EndIf
			MSC9->(dbSkip())
		EndDo

		//Gravo email para envio de workflow
		dbSelectArea("SCR")
		Reclock("SCR",.T.)

		SCR->CR_FILIAL := xFilial("SCR")
		SCR->CR_NUM    := cPedido
		SCR->CR_TIPO   := "R1"
		SCR->CR_USER   := "000008"
		SCR->CR_APROV  := "RT0036"
		SCR->CR_NIVEL  := "02"
		SCR->CR_TOTAL  := 0
		SCR->CR_EMISSAO := dDatabase
		SCR->CR_MOTIVO  := "R1"
		SCR->CR_TIPOLIM := "1"
		SCR->CR_STATUS  := '02'

		MsUnLock("SCR")

	EndIf

	//Verifico se o Cliente possui saldos duplicatas em aberto por mais de 5 dias
	cQuery := ""
	cQuery += " SELECT COALESCE(SUM(E1_VALOR), 0) SALDDUP "
	cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK) "
	cQuery += " WHERE E1_CLIENTE = '" + cClicod + "'"
	cQuery += "   AND E1_LOJA    = '" + cCliLoj + "'"
	cQuery += "   AND E1_SALDO > 0 "
	cQuery += "   AND E1_VENCREA < '" + DTOS(dDataBase-5) +  "'"
	cQuery += "   AND D_E_L_E_T_ = '' "
	cQuery += "   AND E1_TIPO NOT IN ('RA','NCC','NCA') "

	If Select("MSE1") <> 0
		dbSelectArea("MSE1")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "MSE1"

	nSalDup := 0
	dbSelectArea("MSE1")
	DbGoTop()
	While !eof()
		nSalDup += MSE1->SALDDUP
		MSE1->(dbSkip())
	EndDo

	lBlqSald := .F.

	If nSalDup > 0
		lBlqSald := .T.
	EndIf

	//Verifico se ja teve consulta no dia para o cliente

	cQuery := ""
	cQuery += " SELECT R_E_C_N_O_  "
	cQuery += " FROM " + RetSqlName("ZZD") + " ZZD (NOLOCK) "
	cQuery += " WHERE ZZD_FILIAL = '" + xFilial("ZZD") + "' "
	cQuery += "   AND ZZD_CLICOD = '" + cCliCod + "' "
	cQuery += "   AND ZZD_CLILOJ = '" + cCliLoja + "' "
	cQuery += "   AND ZZD_DTCON = '" + DTOS(dDataBase) +  "' "
	cQuery += "   AND ZZD.D_E_L_E_T_ = '' "

	cAliasQRY1 := GetNextAlias()

	If Select(cAliasQRY1) <> 0
		dbSelectArea(cAliasQRY1)
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS (cAliasQRY1)

	lConOk := .F.
	dbSelectArea(cAliasQRY1)
	DbGoTop()
	While !Eof()
		lConOk := .F.
		(cAliasQRY1)->(dbSkip())
	EndDo

	If ((lBlqCre .and.lBlqSald) .or. lBlqCre2) .and. !lConOk
		Processa({|| fGestorCred(cPedido,cCliCod,cCliLoja,nTotalPed,cTipoPes,cCgc)}, "AGX515", "Aguarde - consultando WebService")
	EndIf

Return()

Static Function fGestorCred(cPed,cCli,cLoja,nTot,cTipoPes2,cCgc2)

	Local oWS     := WSwsgestordecisao():New()
	Local cResult := ""
	Local cScore  := ""

	If cTipoPes2 == "F"
		cScore := "CSB5"
	else
		cScore := "    "
	EndIf

	nTot := Round(nTot,0)

	// Setando timeout da requisição para 30 segundos
	WsCTimeOut(30)

	If oWS:AnalisarCredito("81632093000179","RODRIGO","123456","86020488","mime",cCgc2,nTot,cScore,.F.,.F.,"")

		cResult := oWS:cAnalisarCreditoResult

		dbSelectArea("ZZD")
		dbSetOrder(1)
		IF !dbSeek(xFilial("ZZD") + cPed)
			RecLock("ZZD",.T.)
			ZZD->ZZD_FILIAL := xFilial("ZZD")
			ZZD->ZZD_PEDIDO := cPed
			ZZD->ZZD_CLICOD := cCli
			ZZD->ZZD_CLILOJ := cLoja
			ZZD->ZZD_DTCON  := dDataBase
			ZZD->ZZD_VALOR  := nTot
			ZZD->ZZD_RET    := cResult
			ZZD->ZZD_SITUAC := alltrim(SUBSTRING(cResult,22,10) )
			ZZD->ZZD_TEXTO  := cResult
			MsUnLock()
		else
			RecLock("ZZD",.F.)
			ZZD->ZZD_DTCON  := dDataBase
			ZZD->ZZD_VALOR  := nTot
			ZZD->ZZD_RET    := cResult
			ZZD->ZZD_SITUAC := alltrim(SUBSTRING(cResult,22,10) )
			MsUnLock()
		EndIf

	Else
		Alert('Erro de Execução ao processar crédito do cliente: '+ GetWSCError())
	Endif

Return()