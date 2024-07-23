#INCLUDE "PROTHEUS.CH"

User Function GOXPedAu()
	
	Local nI
	Local nX
	
	Local aCampos      := {"C7_ITEM", "C7_PRODUTO", "C7_UM", "C7_QUANT", "C7_PRECO", "C7_TOTAL", "C7_NUMSC", "C7_ITEMSC", "C7_ZRESPON", "C7_CONTA", "C7_CC"}
	
	Local aItXml
	
	Local aAlt         := {"C7_ZRESPON", "C7_CONTA", "C7_CC", "C7_NUMSC", "C7_ITEMSC"}
	
	Local cCodNext     := ""
	
	Local aSCAux
	
	Private nPosNumSC  := AScan(aCampos, {|x| x == "C7_NUMSC"})
	Private nPosItSC   := AScan(aCampos, {|x| x == "C7_ITEMSC"})
	
	Private aColsSC7   := {}
	Private aHeaderSC7 := {}
	
	Private oDlgPrd
	Private aSize      := MsAdvSize(.F., .F.)
	Private oGetPrd
	
	Private oMsgPrd
	Private cMsgPrd := ""
	
	Private aColsAux     := {}
	
	For nI := 1 To Len(oGetD:aCols)
		
		If Empty(oGetD:aCols[nI][_nPosProdu]) //.And. AScan(aColsAux, {|x| x[2] == aItXml[1]}) == 0
			
			MsgAlert("Todos os itens precisam estar com o código de produto informado!")
			
			Return
			
		EndIf
		
	Next nI
	
	For nI := 1 To Len(oGetD:aCols)
		
		If Empty(oGetD:aCols[nI][_nPosPedid]) .Or. Empty(oGetD:aCols[nI][_nPosItePc])//.And. AScan(aColsAux, {|x| x[2] == aItXml[1]}) == 0
			
			aSCAux := GetSC(oGetD:aCols[nI][_nPosProdu], oGetD:aCols[nI][_nPosQtdNo], (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"))
			
			AAdd(aColsAux, {nI, oGetD:aCols[nI][_nPosProdu], ;
								oGetD:aCols[nI][_nPosUm], ;
								oGetD:aCols[nI][_nPosQtdNo], ;
								oGetD:aCols[nI][_nPosVlUnt], ;
								oGetD:aCols[nI][_nPosVlTot], ;
								aSCAux[1], ;
								aSCAux[2]})
			
		EndIf
		
	Next nI
	
	If Empty(aColsAux)
		
		MsgAlert("É necessário ter pelo menos 1 item sem pedido de compras informado.")
		
		Return
		
	EndIf
	
	DEFINE MSDIALOG oDlgPrd FROM aSize[7], 0 TO aSize[6]/1.2, aSize[5]/1.2 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgPrd:lEscClose := .F.
		
		oLayPrd := FWLayer():New()
		oLayPrd:Init(oDlgPrd, .F.)
			
			oLayPrd:AddLine('LIN1', 65, .F.)
				
				oLayPrd:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
					
					oLayPrd:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Criação Pedido Automático", 100, .F., .T., , 'LIN1',)
						
						dbSelectArea("SX3")
						// Campo de OK
						//SX3->( dbSetOrder(2) )
						//SX3->( dbSeek("D2_OK") )
						
						//AAdd(aHeaderSC7, {"", "B1_OK", "@BMP", 8, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
						
						SX3->( dbSetOrder(2) )
						
						For nI := 1 To Len(aCampos)
							
							If SX3->( dbSeek(aCampos[nI]) )
								
								If aCampos[nI] $ "C7_CONTA;C7_CC;C7_ZRESPON"
									
									AAdd(aHeaderSC7, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, AllTrim(SX3->X3_VALID) + IIf(Empty(SX3->X3_VALID), "", ".And.") + "U_GOXRep(oGetPrd)", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})	
									
								ElseIf aCampos[nI] == "C7_NUMSC"
									
									AAdd(aHeaderSC7, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, "SC1IMP", SX3->X3_CONTEXT})
									
								Else
									
									AAdd(aHeaderSC7, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
									
								EndIf
								
							EndIf
							
						Next nI
						
						//cCodNext := GetNextCod("MC")
						
						For nI := 1 To Len(aColsAux)
							
							AAdd(aColsSC7, {})
							
							For nX := 1 To Len(aHeaderSC7)
								
								If AllTrim(aHeaderSC7[nX][2]) == "C7_ITEM"
									
									AAdd(ATail(aColsSC7), StrZero(nI, TamSX3("C7_ITEM")[1]))
									
								ElseIf AllTrim(aHeaderSC7[nX][2]) == "C7_PRODUTO"
									
									AAdd(ATail(aColsSC7), aColsAux[nI][2])
									
								ElseIf AllTrim(aHeaderSC7[nX][2]) == "C7_UM"
									
									AAdd(ATail(aColsSC7), aColsAux[nI][3])
									
								ElseIf AllTrim(aHeaderSC7[nX][2]) == "C7_QUANT"
									
									AAdd(ATail(aColsSC7), aColsAux[nI][4])
									
								ElseIf AllTrim(aHeaderSC7[nX][2]) == "C7_PRECO"
									
									AAdd(ATail(aColsSC7), aColsAux[nI][5])
									
								ElseIf AllTrim(aHeaderSC7[nX][2]) == "C7_TOTAL"
									
									AAdd(ATail(aColsSC7), aColsAux[nI][6])
									
								ElseIf AllTrim(aHeaderSC7[nX][2]) == "C7_NUMSC"
									
									AAdd(ATail(aColsSC7), aColsAux[nI][7])
									
								ElseIf AllTrim(aHeaderSC7[nX][2]) == "C7_ITEMSC"
									
									AAdd(ATail(aColsSC7), aColsAux[nI][8])
									
								Else
									
									AAdd(ATail(aColsSC7), CriaVar(aHeaderSC7[nX][2], .T.))
									
								EndIf
								
							Next nX
							
							AAdd(ATail(aColsSC7), aColsAux[nI][1])
							
							AAdd(ATail(aColsSC7), .F.)
							
						Next nI
						
						oGetPrd := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAlt, 000, 999, Nil, Nil, "AlwaysFalse", oLayPrd:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), aHeaderSC7, aColsSC7)
						oGetPrd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						
						oGetPrd:aInfo[nPosNumSC][5] := " "
						oGetPrd:aHeader[nPosNumSC][14] := " "
						
						oGetPrd:aInfo[nPosItSC][5] := " "
						oGetPrd:aHeader[nPosItSC][14] := " "
						
			oLayPrd:AddLine('LIN2', 30, .F.)
				
				oLayPrd:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
					
					oMsgPrd := TMultiget():New(06, 06, {|u| If(Pcount()>0, cMsgPrd:=u, cMsgPrd)}, ;
		              oLayPrd:GetColPanel('COL1_LIN2', 'LIN2'), 265, 105, , , , , , .T., , , , , , .T.)		
					oMsgPrd:Align := CONTROL_ALIGN_ALLCLIENT
					oMsgPrd:EnableVScroll(.T.)
					oMsgPrd:EnableHScroll(.T.)
					
			oLayPrd:AddLine('LIN3', 5, .F.)
				
				oLayPrd:AddCollumn('COL1_LIN3', 100, .T., 'LIN3')
					
					oPanelBot := tPanel():New(0, 0, "", oLayPrd:GetColPanel('COL1_LIN3', 'LIN3'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oQuit := THButton():New(0, 0, "&Cancelar", oPanelBot, {|| oDlgPrd:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oImp := THButton():New(0, 0, "&Gerar Pedido", oPanelBot, {|| IIf(CriaPed(), oDlgPrd:End(), )}, , , )
					oImp:nWidth  := 90
					oImp:nHeight := 10
					oImp:Align := CONTROL_ALIGN_RIGHT
					oImp:SetColor(RGB(002, 070, 112), )
	
	ACTIVATE MSDIALOG oDlgPrd CENTERED
	
Return

Static Function CriaPed()
	
	Local lRet
	Private oProcess
	
	oProcess := MsNewProcess():New({|| lRet := ExecAutPed()}, "Aguarde...", "Criando Pedido")
	oProcess:Activate()
	
Return lRet

Static Function ExecAutPed()

	Local aCab    := {}
	Local aItens  := {}
	Local aAux
	Local cNumPed := CriaVar("C7_NUM",.T.)
	Local nI
	Local lTudoOk := .T.
	
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	
	Private nPosProd  := AScan(aHeaderSC7, {|x| AllTrim(x[2]) == "C7_PRODUTO"})
	
	Private nPosResp  := AScan(aHeaderSC7, {|x| AllTrim(x[2]) == "C7_ZRESPON"})
	Private nPosConta := AScan(aHeaderSC7, {|x| AllTrim(x[2]) == "C7_CONTA"})
	Private nPosCC    := AScan(aHeaderSC7, {|x| AllTrim(x[2]) == "C7_CC"})
	
	Private nPosNumSC := AScan(aHeaderSC7, {|x| AllTrim(x[2]) == "C7_NUMSC"})
	Private nPosItSC  := AScan(aHeaderSC7, {|x| AllTrim(x[2]) == "C7_ITEMSC"})
	
	dbSelectArea("SC1")
	SC1->( dbSetOrder(1) )
	
	For nI := 1 To Len(oGetPrd:aCols)
		
		If !Empty(oGetPrd:aCols[nI][nPosNumSC])
		
			If SC1->( dbSeek(xFilial("SC1") + oGetPrd:aCols[nI][nPosNumSC] + oGetPrd:aCols[nI][nPosItSC]) )
				
				If SC1->C1_PRODUTO # oGetPrd:aCols[nI][nPosProd]
					
					MsgAlert("A Solicitação " + oGetPrd:aCols[nI][nPosNumSC] + "/" + ;
					oGetPrd:aCols[nI][nPosItSC] + " informada na linha " + cValToChar(nI) + " difere do produto. ")
					
					Return .F.
					
				EndIf
				
			Else
				
				MsgAlert("Solicitação de Compras " + oGetPrd:aCols[nI][nPosNumSC] + "/" + ;
					oGetPrd:aCols[nI][nPosItSC] + " na linha " + cValToChar(nI) + " não encontrada. ")
					
				Return .F.
				
			EndIf
			
		EndIf
		
	Next nI
	
	If Empty(cNumPed)
		
		cNumPed := GetNumSC7(.F.)
		
	EndIf
	
	aCab :={{"C7_NUM"		,cNumPed,Nil},; // Numero do Pedido
			{"C7_EMISSAO"	,Date()		,Nil},; // Data de Emissao
			{"C7_FORNECE"	,(_cTab1)->&(_cCmp1 + "_CODEMI")		,Nil},; // Fornecedor
			{"C7_LOJA"		,(_cTab1)->&(_cCmp1 + "_LOJEMI")		,Nil},; // Loja do Fornecedor
			{"C7_COND"		,PadR(GetNewPar("MV_ZGOCPPA", "001"), TamSX3("C7_COND")[1]),Nil},; // Condicao de pagamento
			{"C7_CONTATO"	,"              ",Nil},; // Contato
			{"C7_FILENT"	,cFilAnt,Nil},;				 
			{"C7_MOEDA"     ,1.0            , Nil},;
			{"C7_TXMOEDA"   ,1.0            , Nil}} // Filial Entrega
	
	For nI := 1 To Len(oGetPrd:aCols)
		
		If !ATail(oGetPrd:aCols[nI])
			
			aAux := {	{"C7_ITEM",		oGetPrd:aCols[nI][1]		,Nil},; // Sequencial do Item
						{"C7_PRODUTO",	oGetPrd:aCols[nI][2]				,Nil},; // Codigo do Produto
						{"C7_QUANT",	oGetPrd:aCols[nI][4],Nil},; // Quantidade
						{"C7_PRECO",	oGetPrd:aCols[nI][5]	,Nil},; // Preco                   
						{"C7_TOTAL",	oGetPrd:aCols[nI][6] ,Nil},; // Valor Liquido do pedido
						;//{"C7_TOTAL",	oGetPrd:aCols[nI][6] ,Nil},; // Valor Liquido do pedido
						{"C7_CONTA",	oGetPrd:aCols[nI][nPosConta] ,Nil},; // Valor Liquido do pedido
						{"C7_CC",	oGetPrd:aCols[nI][nPosCC] ,Nil},; // Valor Liquido do pedido
						{"C7_DATPRF",	Date()			,Nil}} // Data de Entrega
						;//{"C7_OBS",		cObs				,Nil},; // Observacao
						;//{"C7_TES"    ,  PadR(GetNewPar("MV_ZGRPTES", "   "), TamSX3("F4_CODIGO")[1]), Nil},;	// TES do Pedido de Compra
			
			If nPosResp > 0
				
				AAdd(aAux, {"C7_ZRESPON", oGetPrd:aCols[nI][nPosResp], Nil})
				
			EndIf
			
			If !Empty(oGetPrd:aCols[nI][nPosNumSC])
				
				AAdd(aAux, {"C7_NUMSC",	oGetPrd:aCols[nI][nPosNumSC] ,Nil})
				AAdd(aAux, {"C7_ITEMSC",	oGetPrd:aCols[nI][nPosItSC] ,Nil})
				AAdd(aAux, {"C7_QTDSOL",	oGetPrd:aCols[nI][4] ,Nil})
				
			EndIf
			
			AAdd(aItens, aAux)
			
		EndIf
		
	Next nI
	
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)}, 1, aCab, aItens,3)
	
	If lMsErroAuto
		
		cMsgPrd := U_GOXErAut(GetAutoGrLog())
		
		lTudoOk := .F.
		
	Else
		
		cMsgPrd := ""
		
		// Posicionar na SC7 e liberar todos os itens.
		
		dbSelectArea("SC7")
		SC7->( dbSetOrder(1) )
		SC7->( dbSeek(xFilial("SC7") + cNumPed) )
		
		While !SC7->( Eof() ) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNumPed
			
			RecLock("SC7")
				
				SC7->C7_CONAPRO := "L"
				
			SC7->( MSUnlock() )
			
			SC7->( dbSkip() )
			
		EndDo
		
		AtuPedXml(cNumPed)
		
	EndIf
	
	oGetPrd:Refresh()
	
	oMsgPrd:Refresh()
	
Return lTudoOk

Static Function GetNextCod(cTipo)
	
	Local cQuery := ""
	Local cRet   := ""
	Local cAli   := GetNextAlias()
	
	cQuery := "SELECT MAX(B1_COD) COD FROM " + RetSqlName("SB1") + " WHERE B1_TIPO = '" + cTipo + "' AND SUBSTRING(B1_COD, 1, 2) = '" + cTipo + "' AND LEN(RTRIM(B1_COD)) = 8 "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,, cQuery), cAli, .F., .T.)
	
	If !(cAli)->( Eof() )
		
		cRet := cTipo + AllTrim(SubStr((cAli)->COD, 3))
		
	Else
		
		cRet := cTipo + "000001"
		
	EndIf
	
	cRet := PadR(cRet, TamSX3("B1_COD")[1])
	
Return cRet

Static Function NextCod(cCod)
	
Return PadR(Soma1(AllTrim(cCod)), TamSX3("B1_COD")[1])

Static Function AtuPedXml(cNumPed)
	
	Local nI
	Local nPos
	
	For nI := 1 To Len(oGetPrd:aCols)
		
		If !ATail(oGetPrd:aCols[nI])
			
			nPos := oGetPrd:aCols[nI][Len(oGetPrd:aCols[nI]) - 1]
			
			GDFieldPut(_cCmp2 + "_PEDIDO", cNumPed, nPos, oGetD:aHeader, oGetD:aCols)
			GDFieldPut(_cCmp2 + "_ITEMPC", oGetPrd:aCols[nI][1], nPos, oGetD:aHeader, oGetD:aCols)
			
		EndIf
		
	Next nI
	
Return

User Function GoXRep(oObj)
	
	Local cCampo := SubStr(ReadVar(), 4)
	Local xValor := &(ReadVar())
	Local nI
	
	If N == 1 .And. Len(oObj:aCols) > 1 .And. MsgYesNo("Deseja replicar esta informação para as demais linhas?")
		
		For nI := 2 To Len(oObj:aCols)
			
			GDFieldPut(cCampo, xValor, nI, oObj:aHeader, oObj:aCols)
			
		Next nI
		
	EndIf
	
Return .T.

Static Function GetSC(cProd, cQuant, cForn, cLoja)
	
	Local cQuery := ""
	Local cAli   := GetNextAlias()
	Local aRet   := {Space(TamSX3("C1_NUM")[1]), Space(TamSX3("C1_ITEM")[1])}
	
	cQuery := " SELECT C1.C1_FILIAL, C1.C1_NUM, C1.C1_ITEM, C1.C1_QUANT, C1.C1_FORNECE, C1.C1_LOJA FROM " + RetSqlName("SC1") + " C1 "
	cQuery += " WHERE C1.C1_FILIAL = '" + xFilial("SC1") + "' AND C1.C1_PRODUTO = '" + cProd + "' "
	cQuery += " 	AND (C1.C1_QUANT - C1.C1_QUJE) >= " + cValToChar(cQuant) + " "
	cQuery += " 	AND C1.C1_APROV IN (' ', 'L') AND C1.C1_RESIDUO = ' ' AND C1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY C1.C1_FORNECE DESC "
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,, cQuery), cAli, .F., .T.)
	
	If !(cAli)->( Eof() )
		
		aRet := {(cAli)->C1_NUM, (cAli)->C1_ITEM}
		
	EndIf
	
	(cAli)->( dbCloseArea() )
	
Return aRet
