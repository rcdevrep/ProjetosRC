#INCLUDE "PROTHEUS.CH"

User Function GOXPrdAu()
	
	Local nI
	Local nX
	
	Local aCmpNot      := {"B1_FILIAL"}
	Local aColsAux     := {}
	
	Local aItXml
	
	Local aAlt         := {}
	
	Local cCodNext     := ""
	Local cNcmAux      := ""
	
	Private aColsPrd   := {}
	Private aHeaderPrd := {}
	
	Private oDlgPrd
	Private aSize      := MsAdvSize(.F., .F.)
	Private oGetPrd
	
	Private oMsgPrd
	Private cMsgPrd := ""
	
	For nI := 1 To Len(oGetD:aCols)
		
		aItXml := GetXmlProd(oGetD:aCols[nI][_nPosItXml])
		
		If Empty(oGetD:aCols[nI][_nPosProdu]) .And. AScan(aColsAux, {|x| x[2] == aItXml[1]}) == 0
			
			AAdd(aColsAux, {nI, aItXml[1], aItXml[2]})
			
		EndIf
		
	Next nI
	
	If Empty(aColsAux)
		
		Alert("É necessário haver produtos não vinculados para criar o cadastro de produto automaticamente.")
		
		Return
		
	EndIf
	
	DEFINE MSDIALOG oDlgPrd FROM aSize[7], 0 TO aSize[6]/1.2, aSize[5]/1.2 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgPrd:lEscClose := .F.
		
		oLayPrd := FWLayer():New()
		oLayPrd:Init(oDlgPrd, .F.)
			
			oLayPrd:AddLine('LIN1', 65, .F.)
				
				oLayPrd:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
					
					oLayPrd:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Criação Produto automático", 100, .F., .T., , 'LIN1',)
						
						dbSelectArea("SX3")
						// Campo de OK
						SX3->( dbSetOrder(2) )
						SX3->( dbSeek("D2_OK") )
						
						AAdd(aHeaderPrd, {"", "B1_OK", "@BMP", 8, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
						
						SX3->( dbSetOrder(1) )
						SX3->( dbSeek("SB1") )
						
						While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "SB1"
							
							If AScan(aCmpNot, {|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) == 0 .And. SX3->X3_CONTEXT # "V" .And. ;
								X3Uso(SX3->X3_USADO)
								
								AAdd(aHeaderPrd, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
								
								AAdd(aAlt, SX3->X3_CAMPO)
								
							EndIf
							
							SX3->( dbSkip() )
							
						EndDo
						
						cCodNext := GetNextCod("MC")
						
						For nI := 1 To Len(aColsAux)
							
							AAdd(aColsPrd, {})
							
							For nX := 1 To Len(aHeaderPrd)
								
								If AllTrim(aHeaderPrd[nX][2]) == "B1_OK"
									
									AAdd(ATail(aColsPrd), "BR_PRETO")
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_DESC"
									
									AAdd(ATail(aColsPrd), PadR(aColsAux[nI][3], TamSX3("B1_DESC")[1]))
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_COD"
									
									AAdd(ATail(aColsPrd), (cCodNext := NextCod(cCodNext))) //PadR(aColsAux[nI][2], TamSX3("B1_COD")[1])
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_POSIPI"
									
									cNcmAux := XmlPrdInfo(aColsAux[nI][2], "_NCM", "B1_POSIPI")
									
									If AllTrim(cNcmAux) == Replicate("0", Len(AllTrim(cNcmAux)))
										
										cNcmAux := Replicate("0", 8)
										
									EndIf
									
									AAdd(ATail(aColsPrd), cNcmAux)
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_LOCPAD"
									
									dbSelectArea("NNR")
									NNR->( dbSetOrder(1) )
									If NNR->( dbSeek(cFilAnt) )
										AAdd(ATail(aColsPrd), NNR->NNR_CODIGO)
									Else
										AAdd(ATail(aColsPrd), CriaVar(aHeaderPrd[nX][2], .T.))
									EndIf
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_UM"
									
									cXMLUM := XmlPrdInfo(aColsAux[nI][2], "_UCOM", "B1_UM")
									
									dbSelectArea("SAH")
									SAH->( dbSetOrder(1) )
									If SAH->( dbSeek(xFilial("SAH") + PadR(cXMLUM, TamSX3("AH_UNIMED")[1])) )
										
										AAdd(ATail(aColsPrd), SAH->AH_UNIMED)
										
									Else 
										
										AAdd(ATail(aColsPrd), CriaVar(aHeaderPrd[nX][2], .T.))
										
									EndIf
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_TIPO"
									
									AAdd(ATail(aColsPrd), "MC") // Verificar se deve ter algum tipo de inteligência para seleção do tipo
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_ORIGEM"
									
									AAdd(ATail(aColsPrd), XmlOrigem(aColsAux[nI][2]))
									
								ElseIf AllTrim(aHeaderPrd[nX][2]) == "B1_GRUPO"
									
									AAdd(ATail(aColsPrd), Padr("0010", TamSX3("B1_GRUPO")[1]))
									
								Else
									
									AAdd(ATail(aColsPrd), CriaVar(aHeaderPrd[nX][2], .T.))
									
								EndIf
								
							Next nX
							
							AAdd(ATail(aColsPrd), aColsAux[nI][2]) // Código do Produto
							
							AAdd(ATail(aColsPrd), aColsAux[nI][3]) // Descrição do Produto
							
							AAdd(ATail(aColsPrd), "") // Erro da geração
							
							AAdd(ATail(aColsPrd), .F.)
							
						Next nI
						
						oGetPrd := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAlt, 000, 999, Nil, Nil, "AlwaysFalse", oLayPrd:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), aHeaderPrd, aColsPrd)
						oGetPrd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						
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
					
					oImp := THButton():New(0, 0, "&Gerar Produtos", oPanelBot, {|| IIf(CriaProds(), oDlgPrd:End(), )}, , , )
					oImp:nWidth  := 90
					oImp:nHeight := 10
					oImp:Align := CONTROL_ALIGN_RIGHT
					oImp:SetColor(RGB(002, 070, 112), )
	
	ACTIVATE MSDIALOG oDlgPrd CENTERED
	
Return

Static Function GetXmlProd(cParam)
	
	Local cSep    := " - ["
	Local cDesc   := AllTrim(cParam)
	Local nAt     := At(cSep, cDesc)
	Local cCod    := AllTrim(SubStr(cDesc, 1, nAt - 1))
	Local cDscPrd := SubStr(cDesc, nAt + Len(cSep))
	
Return {cCod, Left(cDscPrd, Len(cDscPrd) - 1)}

Static Function XmlPrdInfo(cProd, cNode, cDefault, lPos)
	
	Local nI
	Local xRet
	Local cValNode
	
	Default lPos := .F.
	
	//GetNodeNFe(oXml, "_infNFe:_cobr:_dup")
	
	For nI := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)
		
		If AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_cProd:Text) == AllTrim(cProd)
			
			If lPos
				
				Return nI
				
			EndIf
			
			cValNode := "oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nI) + "]:_prod:" + cNode
			
			If Type(cValNode) == "O"
				
				xRet := &(cValNode + ":Text")
				
			Else
				
				xRet := CriaVar(cDefault, .T.)
				
			EndIf
			
			Exit
			
		EndIf
		
	Next nI
	
Return xRet

Static Function CriaProds()
	
	Local lRet
	Private oProcess
	
	oProcess := MsNewProcess():New({|| lRet := ExecAutPrd()}, "Aguarde...", "Criando Produtos")
	oProcess:Activate()
	
Return lRet

Static Function ExecAutPrd()

	Local nI
	Local nX
	
	Local aProdAut := {}
	Local lTudoOk  := .T.
	
	Local cCodFor
	Local cDescFor
	Local cCodNovo

	Local nPosNCM := 0
	
	Local nTotProd := Len(oGetPrd:aCols)
	
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	
	Private n
	
	oProcess:setRegua1(2)
	oProcess:incRegua1("Processando produtos...")
	
	oProcess:setRegua2(nTotProd)
	
	For nI := 1 To nTotProd
		
		oProcess:incRegua2("Produto " + cValToChar(nI) + " de " + cValToChar(nTotProd))
		
		If oGetPrd:aCols[nI][1] # "BR_VERDE"
			
			aProdAut := {}
			
			For nX := 1 To Len(aHeaderPrd)
				
				If !(AllTrim(aHeaderPrd[nX][2]) $ "B1_OK") .And. !Empty(oGetPrd:aCols[nI][nX])
					
					AAdd(aProdAut, {aHeaderPrd[nX][2], oGetPrd:aCols[nI][nX], Nil})
					
				EndIf
				
			Next nX
			
			// Caso não exista NCM criar!!!

			If GetNewPar("MV_ZGOCNCM", .T.)

				nPosNCM := ASCan(aProdAut, {|x| AllTrim(x[1]) == "B1_POSIPI"})

				If nPosNCM > 0

					dbSelectArea("SYD")
					SYD->( dbSetOrder(1) )
					If !SYD->( dbSeek(xFilial("SYD") + aProdAut[nPosNCM][2]) )

						RecLock("SYD", .T.)

							SYD->YD_FILIAL := xFilial("SYD")
							SYD->YD_TEC := aProdAut[nPosNCM][2]
							SYD->YD_DESC_P := "NCM automática via importação de XML"
							SYD->YD_UNID := "11"

						SYD->( MSUnlock() )

					EndIf

				EndIf

			EndIf

			//////////////////////////////////

			MSExecAuto({|x, y| MATA010(x, y)}, aProdAut, 3)
			
			If lMsErroAuto
				
				//aColsPrd[nI][Len(aColsPrd[nI]) - 1] := MontaErro(GetAutoGrLog())
				//aColsPrd[nI][1] := "BR_VERMELHO"
				
				oGetPrd:aCols[nI][Len(oGetPrd:aCols[nI]) - 1] := U_GOXErAut(GetAutoGrLog())
				oGetPrd:aCols[nI][1] := "BR_VERMELHO"
				
				lTudoOk := .F.
				
			Else
				
				oGetPrd:aCols[nI][Len(oGetPrd:aCols[nI]) - 1] := "Produto criado com sucesso."
				oGetPrd:aCols[nI][1] := "BR_VERDE"
				
				// Atualizar a tela de trás cos os produtos
				
				cCodFor := oGetPrd:aCols[nI][Len(oGetPrd:aCols[nI]) - 3]
				cDescFor := oGetPrd:aCols[nI][Len(oGetPrd:aCols[nI]) - 2]
				cCodNovo := GDFieldGet("B1_COD", nI, , oGetPrd:aHeader, oGetPrd:aCols)
				
				AtuPrdXml(cCodFor, cCodNovo)
				
				// Cria relação no SA5
				
				//Amarração do Produto X Fornecedor
				dbSelectArea("SA5")
				SA5->( dbSetOrder(2) )
		
				If !SA5->( dbSeek(xFilial("SA5") + cCodNovo + M->&(_cCmp1 + "_CODEMI") + M->&(_cCmp1 + "_LOJEMI")) )
		
					RecLock("SA5", .T.)
						SA5->A5_FILIAL  := xFilial("SA5")
						SA5->A5_PRODUTO := cCodNovo
						SA5->A5_FORNECE := M->&(_cCmp1 + "_CODEMI")
						SA5->A5_LOJA    := M->&(_cCmp1 + "_LOJEMI")
						SA5->A5_CODPRF  := cCodFor
						SA5->A5_NOMPROD := cDescFor
						SA5->A5_NOMEFor := Posicione("SA2", 1, xFilial("SA2") + PadR(M->&(_cCmp1 + "_CODEMI"), TamSX3("A5_FORNECE")[1]) + PadR(M->&(_cCmp1 + "_LOJEMI"), TamSX3("A5_LOJA")[1]), "A2_NOME")
					SA5->( MsUnlock() )
					
				Else
					
					RecLock("SA5", .F.)
						SA5->A5_CODPRF  := cCodFor
						SA5->A5_NOMPROD := cDescFor
					SA5->( MsUnlock() )
					
				EndIf
				
			EndIf
			
		EndIf
		
	Next nI
	
	oGetPrd:Refresh()
	
	cMsgPrd := oGetPrd:aCols[1][Len(oGetPrd:aCols[1]) - 1]
	
	oMsgPrd:Refresh()
	
Return lTudoOk


Static Function AtuPrdXml(cPrdFor, cNovoPrd)
	
	Local nI
	Local aItXml
	Local cTes
	Local cProd
	
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	SB1->( dbSeek(xFilial("SB1") + cNovoPrd) )
	
	For nI := 1 To Len(oGetD:aCols)
		
		aItXml := GetXmlProd(oGetD:aCols[nI][_nPosItXml])
		
		If aItXml[1] == cPrdFor
			
			GDFieldPut(_cCmp2 + "_COD", SB1->B1_COD, nI, oGetD:aHeader, oGetD:aCols)
			GDFieldPut(_cCmp2 + "_UM", SB1->B1_UM, nI, oGetD:aHeader, oGetD:aCols)
			GDFieldPut(_cCmp2 + "_DSPROD", SB1->B1_DESC, nI, oGetD:aHeader, oGetD:aCols)
			
			cTes := SB1->B1_TE
			
			If !Empty(cTes)
			
				GdFieldPut(_cCmp2 + "_TES", cTes, nI, oGetD:aHeader, oGetD:aCols)
				GdFieldPut(_cCmp2 + "_CF", IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_CF"), 2, 3), nI, oGetD:aHeader, oGetD:aCols)
				// PEGA A SITUAÇÃO TRIBUTÁRIA DE ACORDO COM A TES
				GDFieldPut(_cCmp2 + "_CLASFI", SubStr(GDFieldGet(_cCmp2 + "_CLASFI", , .T.), 1, 1) + Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_SITTRIB"), nI, oGetD:aHeader, oGetD:aCols)
		
			EndIf
			
			GdFieldPut(_cCmp2 + "_CONTA", SB1->B1_CONTA, nI, oGetD:aHeader, oGetD:aCols)
			
		EndIf
		
	Next nI
	
Return 

Static Function XmlOrigem(cCodProd)
	
	Local nPos := XmlPrdInfo(cCodProd,,, .T.)
	Local cRet := "0"
	
	If !Empty(nPos)
		
		cRet := PadR(U_GOXmlIcm(oXml, nPos)[5], TamSX3("B1_ORIGEM")[1])
		
	EndIf
	
	If Empty(cRet)
		
		cRet := PadR("0", TamSX3("B1_ORIGEM")[1])
		
	EndIf
	
Return cRet

Static Function GetNextCod(cTipo)
	
	Local cQuery := ""
	Local cRet   := ""
	Local cAli   := GetNextAlias()
	
	cQuery := "SELECT MAX(B1_COD) COD FROM " + RetSqlName("SB1") + " B1 WHERE B1_TIPO = '" + cTipo + "' AND SUBSTRING(B1_COD, 1, 2) = '" + cTipo + "' AND LEN(RTRIM(B1_COD)) = 8 AND B1.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,, cQuery), cAli, .F., .T.)
	
	If !(cAli)->( Eof() ) .And. !Empty((cAli)->COD)
		
		cRet := cTipo + AllTrim(SubStr((cAli)->COD, 3))
		
	Else
		
		cRet := cTipo + "000000"
		
	EndIf
	
	cRet := PadR(cRet, TamSX3("B1_COD")[1])
	
Return cRet

Static Function NextCod(cCod)
	
Return PadR(Left(cCod, 2) + Soma1(SubStr(AllTrim(cCod), 3)), TamSX3("B1_COD")[1])
