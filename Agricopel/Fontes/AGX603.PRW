#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX603    ºAutor  ³Microsiga           º Data ³  08/25/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Calculo comissao apos o encerramento do pedido e atendimento±
±±º          ³ ROTINA JA VERIFICADA VIA XAGLOGRT                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX603(cPedido)

	LOCAL aElem	   := {}
	LOCAL nTxFin   := 0
	LOCAL nTxM     := GetMv("MV_TXFIN")
	LOCAL nDias    := 0
	LOCAL nDiasM   := 0
	LOCAL aa       := 1
	LOCAL _x       := 1

	PRIVATE nTxIcm   := 0
	PRIVATE nComis1  := 0
	PRIVATE nComis2  := 0

	cQuery := "SELECT C5_CLIENTE, C6_COMIS1, C6_COMIS2, C6_PRCLIST, C6_PRCVEN,  "
	cQuery += " C6_PRUNIT, C6_PERDESC ,C6_DESCONT , C6_VALODES, C6_FILIAL , C6_NUM , C6_ITEM ,C6_NOTA,C6_SERIE, C5_VEND1, C5_VEND2,"
	cQuery += "  C6_PRODUTO, C5_EMISSAO, C6.R_E_C_N_O_     FROM " + RetSqlName("SC5") + " C5 (NOLOCK) INNER JOIN " + RetSqlName("SC6") + " C6 (NOLOCK) "
	cQuery += " ON C6_FILIAL = C5_FILIAL "
	cQuery += " AND C6_NUM = C5_NUM "
	cQuery += " INNER JOIN SB1010 B1 (NOLOCK) "
	cQuery += " ON B1_FILIAL = C6_FILIAL "
	cQuery += " AND B1_COD = C6_PRODUTO "
	cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
	cQuery += " AND C6.D_E_L_E_T_ = '' "
	cQuery += " AND C5.D_E_L_E_T_ = '' "
	cQuery += " AND B1.D_E_L_E_T_ = '' "
	cQuery += " AND C5_NUM = '" + cPedido + "' "
	cQuery += " AND C5_CLIENTE NOT IN( '00368' , '00382')  "

	If (Select("TSC6") <> 0)
		DbSelectArea("TSC6")
		DbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "TSC6"

	lVendGra := .f.

	nTProd  := 0
	nTRent  := 0

	nCont := 0
	dbSelectArea("TSC6")
	While !eof()
		nCont++

		dbSelectArea("SC6")
		dbSetOrder(1)
		If !dbSeek(TSC6->C6_FILIAL+TSC6->C6_NUM +TSC6->C6_ITEM+TSC6->C6_PRODUTO)
			dbSelectArea("TSC6")
			TSC6->(dbSkip())
			loop
		EndIf

		//BUSCO INFO CLIENTE

		cRep  := ""
		cCall := ""
		nDesc  := SC6->C6_PERDESC
		//	nDesc  := SC6->C6_DESCONT
		cTipoCli := ""
		nComis1  := 0
		nComis2  := 0

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA)

		cRep  := TSC6->C5_VEND1 //SA1->A1_VEND
		cCall := TSC6->C5_VEND2 // SA1->A1_VEND2
		cTipoCli := SA1->A1_TIPO

		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(SC6->C6_FILIAL+SC6->C6_NUM)

		//30.05.2016 trecho comentado por solicitacao da Tatiane,
		//todas as vendas de ARLA devem entrar para RT que esta no cadastro cliente
		//If (ALLTRIM(SC6->C6_PRODUTO) == "43504801" .or. ;
		//ALLTRIM(SC6->C6_PRODUTO) == "44315801" .or. ;
		//ALLTRIM(SC6->C6_PRODUTO) == "45297801" .or. ;
		//ALLTRIM(SC6->C6_PRODUTO) == "44414801" .or.;
		//ALLTRIM(SC6->C6_PRODUTO) == "41063801" .or.;
		//ALLTRIM(SC6->C6_PRODUTO) == "41062800" .or.;
		//ALLTRIM(SC6->C6_PRODUTO) == "43312801" .or.;
		//ALLTRIM(SC6->C6_PRODUTO) == "41062801"  )

		//	lVendGra := .t.
		//	dbSelectArea("SC5")
		//	RecLock("SC5", .f.)
		//	SC5->C5_VEND2 := "RT0050" //COMISSAO SILVIA
		//	MsUnlock()

		//	//Atualizo capa do atendimento caso tiver
		//	dbSelectArea("SUA")
		//	dbSetOrder(8)
		//	If dbseek(xFilial("SUA")+SC5->C5_NUM)
		//		RecLock("SUA",.f.)
		//		SUA->UA_VEND2 := "RT0050"
		//		MsUnLock()
		//	EndIf
		//EndIf

		//30.05.2016 trecho comentado por solicitacao da Tatiane,
		//todas as vendas de ARLA devem entrar para RT que esta no cadastro cliente
		//If cFilAnt == "02"  .and. ALLTRIM(SC6->C6_PRODUTO) == "00020340"  .OR.  cFilAnt == "06"  .and. ALLTRIM(SC6->C6_PRODUTO) == "44380001"

		//	dbSelectArea("SC5")
		//	RecLock("SC5", .f.)
		//	SC5->C5_VEND2 := "RT0042" //COMISSAO SILVIA
		//	MsUnlock()

		//	//Atualizo capa do atendimento caso tiver
		//	dbSelectArea("SUA")
		//	dbSetOrder(8)
		//	If dbseek(xFilial("SUA")+SC5->C5_NUM)
		//		RecLock("SUA",.f.)
		//		SUA->UA_VEND2 := "RT0042"
		//		MsUnLock()
		//	EndIf
		//EndIf

		dbSelectArea("SC5")
		// nao considero o desconto comercial
		// Busco condicao de pagamento.
		// Busca a Taxa de Acrescimo Financeiro
		dbSelectArea("SE4")
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+SC5->C5_CONDPAG)
		cString:=SE4->E4_COND

		While Len(cString) > 0
			AADD(aElem,Parse(@cString))
		End

		nDesc := nDesc - SE4->E4_DESCCOM

		//COMISSAO TELEVENDAS
		aSX3SZ8 := SZ8->(DbStruct())
		cQuery := ""
		cQuery += "SELECT * "
		cQuery += "FROM "+RetSqlName("SZ8")+" SZ8 (NOLOCK) "
		cQuery += "WHERE SZ8.D_E_L_E_T_ = '' "
		cQuery += "AND SZ8.Z8_FILIAL  = '"+xFilial("SZ8")+"' "
		cQuery += "AND SZ8.Z8_REPRE   = '"+cCall+"' "
		cQuery += "AND SZ8.Z8_TPCLIEN = '"+cTipoCli+"' "

		If (Select("TRB02") <> 0)
			DbSelectArea("TRB02")
			DbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "TRB02"

		For aa := 1 to Len(aSX3SZ8)
			If aSX3SZ8[aa,2] <> "C"
				TcSetField("TRB02",aSX3SZ8[aa,1],aSX3SZ8[aa,2],aSX3SZ8[aa,3],aSX3SZ8[aa,4])
			EndIf
		Next aa

		DbSelectArea("TRB02")
		While !Eof()
			If ((Round(nDesc,2) >= TRB02->Z8_descmin).and.(Round(nDesc,2) <= TRB02->Z8_descmax) .Or.;
			(nDesc) <= 0)
				nComis2 := TRB02->Z8_comis
				Exit
			Endif
			DbSelectArea("TRB02")
			TRB02->(DbSkip())
		EndDo

		// COMISSAO REPRESENTANTE
		aSX3SZ8 := SZ8->(DbStruct())
		cQuery := ""
		cQuery += "SELECT * "
		cQuery += "FROM "+RetSqlName("SZ8")+" SZ8 (NOLOCK) "
		cQuery += "WHERE SZ8.D_E_L_E_T_ = '' "
		cQuery += "AND SZ8.Z8_FILIAL  = '"+xFilial("SZ8")+"' "
		cQuery += "AND SZ8.Z8_REPRE   = '"+cRep+"' "
		cQuery += "AND SZ8.Z8_TPCLIEN = '"+cTipoCli+"' "

		If (Select("TRB02") <> 0)
			DbSelectArea("TRB02")
			DbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "TRB02"

		For aa := 1 to Len(aSX3SZ8)
			If aSX3SZ8[aa,2] <> "C"
				TcSetField("TRB02",aSX3SZ8[aa,1],aSX3SZ8[aa,2],aSX3SZ8[aa,3],aSX3SZ8[aa,4])
			EndIf
		Next aa

		DbSelectArea("TRB02")
		While !Eof()
			If ((Round(nDesc,2) >= TRB02->Z8_descmin).and.(Round(nDesc,2) <= TRB02->Z8_descmax) .Or.;
			(nDesc) <= 0)
				nComis1 := TRB02->Z8_comis
				Exit
			Endif
			DbSelectArea("TRB02")
			TRB02->(DbSkip())
		EndDo

		cTes := ""
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
			cTes:= SB1->B1_TS
		EndIf

		nDias := 0

		For _x := 1 To Len(aElem)
			nDias += Val(aElem[_x])
		Next

		nDiasM := nDias / Len(aElem)

		nTxFin := (nTxM * nDiasM) / 30
		cGrupo := SB1->B1_GRUPO

		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(SC6->C6_FILIAL+SC6->C6_NUM)

		nTxIcm := TKCALCICM(SC6->C6_TES)

		nCbase := SC6->C6_CBASE

		if nCbase == 0
			dbselectArea("SD2")
			dbSetOrder(8)
			If dbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM)
				nCbase := SD2->D2_CBASE
			EndIf
		EndIf

		dbselectArea("SC6")

		cTpBase:= SC6->C6_TPBASE

		// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
		// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW, AGX603.PRW.

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

		aOldaCols := aClone(aCols)
		aOldHeader := aClone(aHeader)
		nBackup	:= n
		//Emerson SLA inserção de Cadastro devido a performance
		//08.2016
		nVlrCpr  :=0
		nPerVds  :=0
		nPerMgr  :=0
		IF DA1->(FieldPos("DA1_ZCSTCO")) > 0
			DbSelectArea("DA1")
			DbSetOrder(1)
			If	DbSeek(xFilial("DA1")+SC5->C5_TABELA+SC6->C6_PRODUTO,.T.)
				nVlrCpr  :=DA1_ZCSTCO   // =CstTotCompra
				nPerVds  :=DA1_ZPVEND   //=PercRefVenda
				nPerMgr  :=DA1_ZPMARG   //=PercRefMarge
			Endif
		Else
			PergMTC010()
			nVlrCpr := MaPrcPlan(SC6->C6_PRODUTO,"SLA_AGRS","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
			nPerVds := MaPrcPlan(SC6->C6_PRODUTO,"SLA_AGRS","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
			nPerMgr := MaPrcPlan(SC6->C6_PRODUTO,"SLA_AGRS","PERC_REF_MARGEM",0)        //PORCENTUAL MARGEM CONTRIBUICAO (j)
		Endif
		n := nBackup
		aCols := aClone(aOldaCols)
		aHeader := aClone(aOldHeader)

		_nPreco := SC6->C6_PRCVEN //Atualiza Preço Unitário com Descontos

		nVlrVds := (_nPreco * (nPerVds/100))  //CUSTO DA VENDA (j)
		nVlrMgr := (_nPreco * (nPerMgr/100))  //VALOR MARGEM CONTRIBUICAO (j)

		_nVComV  := (_nPreco * (nComis1/100))  //Valor de Comissao Vendedor (j)
		_nVComT  := (_nPreco * (nComis2/100))  //Valor de Comissao Televendas (j)
		_nIcmsS  := (_nPreco * (nTxIcm/100 ))  //Valor de Icms sobre as vendas nTxIcm (j)

		nRent	:= 0
		//nRent := _nPreco - nCusto // Atualiza Valor Unitário da Rentabilidade
		nRent   := (_nPreco - nVlrCpr - (nVlrVds+_nVComV+_nVComT+_nIcmsS) + nVlrMgr ) // Atualiza Valor Unitário da Rentabilidade (j)

		nRentab := 0
		nRentab := ((nRent / _nPreco ) * 100) // //ATUALIZA UB_RENTAV

		nTProd  += _nPreco
		nTRent  += nRent

		/*
		TRECHO ABAIXO COMENTADO POR SLA EM 30/06/2016 PARA UTILIZAR CÁLCULO COM BASE EM CUSTO DE PLANILHA DE FORMAÇÃO DE PREÇOS
		dbSelectArea("SZ5")
		dbSetOrder(1)
		dbSeek(xFilial("SZ5")+SB1->B1_AGMRKP)

		nBasAux := nCbase

		nCbase := nCbase - (nCbase * (SZ5->Z5_CUFICOM / 100)) // Deduz custo financeiro compra cfe Ademir  17/06/2005
		nZ5_PIS 		:= (nBasAux * (SZ5->Z5_PIS / 100))
		nZ5_COFINS 	:= (nBasAux * (SZ5->Z5_COFINS / 100))

		nCT1  := SC6->C6_QTDVEN * ((nCbase - (nZ5_PIS+nZ5_COFINS)))  // Novo calculo cfe Ademir 17/06/2005

		nPerc := SZ5->Z5_TAXAS + nTxFin + nTxIcm + nComis1 + nComis2 + SC6->C6_COMIS3

		_nPreco := SC6->C6_VALOR

		nVlrTxFin	:= (_nPreco * (nTxFin / 100))

		nZ5_PIS 		:= (_nPreco * (SZ5->Z5_PIS / 100))
		nZ5_COFINS 	:= (_nPreco * (SZ5->Z5_COFINS / 100))

		nTxProd := 0
		nTxProd := _nPreco * (nPerc / 100)

		nRent	 := 0
		nRent   := _nPreco - nCT1 - nTxProd
		//			nTProd  += _nPreco

		nRentab := 0
		nRentab := ((nRent / _nPreco ) * 100) // considera preco venda bruto cfe ademir 14/09/2004
		*/

		dbSelectArea("SC6")
		If RLock()
			RecLock("SC6", .f.)
			SC6->C6_COMIS1 := nComis1
			SC6->C6_COMIS2 := nComis2
			SC6->C6_RENTAB := nRentab
			MsUnLock()
		Endif

		//atualiza item da nota

		/*dbselectArea("SD2")
		dbSetOrder(8)
		If dbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM)
		RecLock("SD2", .f.)
		SD2->D2_RENTAB := nRentab
		SD2->D2_COMIS1 := nComis1
		SD2->D2_COMIS2 := nComis2
		MsUnLock()
		EndIf  */

		dbSelectArea("TSC6")
		TSC6->(dbSkip())
	EndDo

	dbSelectArea("SC5")
	If RLock()
		RecLock("SC5", .F.)
		SC5->C5_RENTAB := ((nTRent / nTProd ) * 100)
		MsUnLock()
	Endif

	//Chama Serasa
	dbSelectArea("SC5")
	If cEmpAnt == "01" .and. (cFilAnt == "06" .or. cFilAnt == "02") .and. !(ALLTRIM(SC5->C5_TIPO) == "B" .OR. ALLTRIM(SC5->C5_TIPO) == "D")
		U_AGX515(SC5->C5_NUM, SC5->C5_CLIENTE, SC5->C5_LOJACLI , 0 )
	Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TKCALCICM  ³ Autor ³ALAN LEANDRO           ³ Data ³19.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a taxa de Icms que sera necessaria para calcular    ³±±
±±³          ³a rentabilidade                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TKCALCICM(cTes)
	*******************************
	LOCAL aSegSF4   := SF4->(GetArea())
	LOCAL cEstado	:= GetMV("MV_ESTADO")
	LOCAL cNorte	:= GetMV("MV_NORTE")
	LOCAL nPerRet   := 0

	DbSelectarea("SF4")
	DbSetorder(1)
	If DbSeek(xFilial("SF4")+cTes)

		If SF4->F4_ICM = "S"
			If Empty(SA1->A1_INSCR)
				nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
				nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
			Elseif SB1->B1_PICM > 0
				nPerRet := SB1->B1_PICM
			Elseif SA1->A1_EST == cEstado
				nPerRet := GetMV("MV_ICMPAD")
			Elseif SA1->A1_EST <> cEstado .AND. SB1->B1_PICM == 0
				nPerRet:= GetMV("MV_ICMPAD")
			Elseif SA1->A1_EST $ cNorte .AND. At(cEstado,cNorte) == 0
				nPerRet := 7
			Else
				nPerRet := 12
			Endif
		Endif

		// ALTERACAO JOAO - SLA - 20.07.2016
		//If SF4->F4_BASEICM > 0 //Reducao base calculo conf. Alexandre 030809
		//	nPerRet := (nPerRet * SF4->F4_BASEICM) / 100
		//Endif
		If SF4->F4_BASEICM > 0 .OR. SF4->F4_PICMDIF <> 0   //Reducao base calculo ou ICMS Diferido

			nPICMBase := ROUND(((nPerRet * SF4->F4_BASEICM)/ 100),0)
			nPICMDif  := ROUND(((nPerRet * SF4->F4_PICMDIF)/ 100),0)
			nPerRet := (nPerRet - nPICMBase - nPICMDif )
		EndIf
		// FIM ALTERACAO

	Endif

	RestArea(aSegSF4)

Return nPerRet

User Function AGS603G()

	// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
	// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW, AGX603.PRW.

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+gdFieldGet("C6_PRODUTO"))

	aOldaCols := aClone(aCols)
	aOldHeader := aClone(aHeader)
	nBackup	:= n
	Pergunte( "MTC010", .F. )
	//nCusto  := MaPrcPlan(gdFieldGet("C6_PRODUTO"),"SLA_AGR","CUSTO_REF",0)            //CUSTO REFERÊNCIA DA TABELA DE PREÇOS
	nVlrCpr := MaPrcPlan(gdFieldGet("C6_PRODUTO"),"SLA_AGRS","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
	nPerVds := MaPrcPlan(gdFieldGet("C6_PRODUTO"),"SLA_AGRS","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
	nPerMgr := MaPrcPlan(gdFieldGet("C6_PRODUTO"),"SLA_AGRS","PERC_REF_MARGEM",0)        //PORCENTUAL MARGEM CONTRIBUICAO (j)

	n := nBackup
	aCols := aClone(aOldaCols)
	aHeader := aClone(aOldHeader)

	_nPreco := gdFieldGet("C6_PRCVEN") //Atualiza Preço Unitário com Descontos

	nVlrVds := (_nPreco * (nPerVds/100))  //CUSTO DA VENDA (j)
	nVlrMgr := (_nPreco * (nPerMgr/100))  //VALOR MARGEM CONTRIBUICAO (j)

	_nVComV  := (_nPreco * (nComis1/100))  //Valor de Comissao Vendedor (j)
	_nVComT  := (_nPreco * (nComis2/100))  //Valor de Comissao Televendas (j)
	_nIcmsS  := (_nPreco * (nTxIcm/100 ))  //Valor de Icms sobre as vendas nTxIcm (j)

	nRent	:= 0
	//nRent := _nPreco - nCusto // Atualiza Valor Unitário da Rentabilidade
	nRent   := (_nPreco - nVlrCpr - (nVlrVds+_nVComV+_nVComT+_nIcmsS) + nVlrMgr ) // Atualiza Valor Unitário da Rentabilidade (j)

	nRent	 := 0
	nRent   := _nPreco - nCusto // Atualiza Valor Unitário da Rentabilidade

	nRentab := 0
	nRentab := ((nRent / _nPreco ) * 100)

Return nRentab

Static Function PergMTC010()
	Pergunte("MTC010", .F. )
Return()