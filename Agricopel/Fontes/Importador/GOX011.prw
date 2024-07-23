#INCLUDE "PROTHEUS.CH"

// Programa para manifestação de notas

//////////////////////////////////////// Variáveis das tabelas
Static _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
Static _cTab2 := Upper(AllTrim(GetNewPar("MV_XGTTAB2", "")))  // Importador NFe
Static _cTab3 := Upper(AllTrim(GetNewPar("MV_XGTTAB3", "")))  // Eventos Importador - DESCONTINUADO
Static _cTab4 := Upper(AllTrim(GetNewPar("MV_XGTTAB4", "")))  // Tabela Unidade de Medida por Produto
Static _cTab5 := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
Static _cTab6 := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
Static _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
Static _cCmp2 := IIf(SubStr(_cTab2, 1, 1) == "S", SubStr(_cTab2, 2, 2), _cTab2)
Static _cCmp3 := IIf(SubStr(_cTab3, 1, 1) == "S", SubStr(_cTab3, 2, 2), _cTab3)
Static _cCmp4 := IIf(SubStr(_cTab4, 1, 1) == "S", SubStr(_cTab4, 2, 2), _cTab4)
Static _cCmp5 := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
Static _cCmp6 := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
////////////////////////////////////////

User Function GOX011()
	
	Local oDlgMain, oBmp
	
	Local aAcesso
	
	Local aStrucTab    := {}
	Local aIndexTab    := {}
	Local nCmp
	
	Private aSize      := MsAdvSize(.F., .F.)
	Private cChvMemo   := ""
	Private oLayerXML
	Private oChvSeek1
	Private cChaveSeek := Space(45)
	
	Private aRotina := {{ "aRotina Falso", "AxPesq",	0, 1 },;
						{ "aRotina Falso", "AxVisual",	0, 2 },;
						{ "aRotina Falso", "AxInclui",	0, 3 },;
						{ "aRotina Falso", "AxAltera",	0, 4 }}
	Private aHeader    := {}
	Private cAliXML
	Private oBrwXML
	
	Private lFocusChv  := .T.
	
	Private oMsgMemo
	Private cMsgMemo   := ""
	
	// Campos da tabela temporária
	Private aFieldStr
	// Campos para o Browse
	Private aFieldBrw
	
	Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	
	aFieldStr := {_cCmp1 + "_SIMP", _cCmp1 + "_DSCR", _cCmp1 + "_CHAVE", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CGCEMI", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_DTEMIS", _cCmp1 + "_TIPO", _cCmp1 + "_ERRO", _cCmp1 + "_MNTO1", _cCmp1 + "_JUST", _cCmp1 + "_ULTMNT", _cCmp1 + "_FLAG"}
	
	aFieldBrw := {_cCmp1 + "_SIMP", _cCmp1 + "_DSCR", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_DTEMIS", _cCmp1 + "_MNTO1", _cCmp1 + "_JUST", _cCmp1 + "_ULTMNT", _cCmp1 + "_CHAVE"}
	
	If !ExistBlock("GOCNPJ")
	
		Aviso("Acesso negado", "Função de permissão de CNPJ não encontrada, solicitar atualização do importador.", {"Ok"}, 2)
		Return
		
	Else
		
		aAcesso := ExecBlock("GOCNPJ", .F., .F., {SM0->M0_CGC})
		
		If aAcesso[1] != &(Embaralha("BAEEaTmmsIbbe'aa) rr,+aa  ll0chh)Uaa,s(( eMD1rDT,N5o a(C4mS()eud )bD+,Sa  tt'0raG)(", 1))
			
			Aviso("Acesso negado", "Rotina de validação de CNPJ inválida", {"Ok"}, 2)
			Return
			
		ElseIf !aAcesso[2]
			
			Aviso("Acesso negado", "CNPJ sem acesso concedido.", {"Ok"}, 2)
			Return
			
		ElseIf !aAcesso[3]
			
			Aviso("Acesso negado", "Data limite (" + aAcesso[4] + ") de utilização expirada.", {'Ok'}, 2)
			Return
			
		ElseIf !Empty(aAcesso[4])
			
			Aviso("Aviso", "Período de utilização do produto irá expirar em " + cValToChar(CToD(aAcesso[4]) - Date()) + " dia(s).", {'Ok'}, 2)
			
		EndIf
		
	EndIf
	
	If Empty(_cTab1) .Or. Empty(_cTab2) .Or. Empty(_cTab5) .Or. Empty(_cTab6)
	
		Aviso("Parâmetros de tabela", "É necessário informar os parâmetros das tabelas utilizadas pelo importador ('MV_XGTTAB1', 'MV_XGTTAB2', 'MV_XGTTAB4', 'MV_XGTTAB5' e 'MV_XGTTAB6') e executar o compatibilizador U_UPDGO01.", {"Ok"}, 2)
		Return
		
	EndIf
	
	If !(AllTrim(RetCodUsr()) $ GetNewPar("MV_XGTGERP"))
		
		Aviso("Permissão", "Esta rotina só pode ser acessada por usuários autorizados (Parâmetro MV_XGTGERP).", {"Entendi"}, 2)
		
		Return
		
	EndIf
	
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	
	For nCmp := 1 To Len(aFieldStr)
		
		If aFieldStr[nCmp] == _cCmp1 + "_SIMP"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 15, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_DSCR"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 15, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_FLAG"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "L", 1, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_ULTMNT"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 27, 0})
			//Ciência da Operação
			//Operação Não Realizada
			//Nenhuma
			//Desconhecimento da Operação
			//Frete em Desacordo
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_JUST"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "M", 10, 0})
			
		ElseIf SX3->( dbSeek(aFieldStr[nCmp]) )
			
			AAdd(aStrucTab, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
			
		EndIf
		
	Next nCmp
	
	AAdd(aIndexTab, _cCmp1 + "_CHAVE+" + _cCmp1 + "_TIPO")
	
	cAliXML := GFECriaTab({aStrucTab, aIndexTab})
	
	DEFINE MSDIALOG oDlgMain FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE 'Manifestação XML' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgMain:lEscClose := .F.
		
		oLayerXML := FWLayer():New()
		oLayerXML:Init(oDlgMain, .F.)
			
			oLayerXML:AddLine('TOP', 15, .F.)
				
				oLayerXML:AddCollumn('XML_CHAVE', 50, .T., 'TOP')
					
					oLayerXML:AddWindow('XML_CHAVE', 'WIN_XML_CHAVE', "Busca pela chave", 100, .F., .T., , 'TOP',)
						
						oChvSeek1 := TGet():New(02, 02, {|u| IF(Pcount() > 0, cChaveSeek := u, cChaveSeek)}, oLayerXML:GetWinPanel('XML_CHAVE', 'WIN_XML_CHAVE', 'TOP'), 280, 12, Replicate("9", 45),,,,,,, .T.,,,,,,, .F.,,, "cChaveSeek",,,,,,, /* Label */,,,, Replicate("_", 44))
						oChvSeek1:bValid := {|| BuscaXML()}
						
				oLayerXML:AddCollumn('XML_OBS', 50, .T., 'TOP')
					
					oChvMemo1 := tMultiget():New(10, 10, {|u| If(Pcount() > 0, cChvMemo := u, cChvMemo)}, ;
								oLayerXML:GetColPanel('XML_OBS', 'TOP'), ;
								100, 100, , , , , , .T., , , , , , .T., , , , .F.)
					oChvMemo1:Align := CONTROL_ALIGN_ALLCLIENT
					oChvMemo1:EnableVScroll(.T.)
					oChvMemo1:EnableHScroll(.F.)
					oChvMemo1:lWordWrap := .T.
					oChvMemo1:Refresh()
					
			oLayerXML:AddLine('MAIN', 65, .F.)
				
				oLayerXML:AddCollumn('COL_MAIN', 100, .T., 'MAIN')
					
					oLayerXML:AddWindow('COL_MAIN', 'WIN_COL_MAIN', "XMLs selecionados", 100, .F., .T., , 'MAIN',)
						
						// Utilizar MSGetDB
						
						dbSelectArea("SX3")
						SX3->( dbSetOrder(2) )
						
						For nCmp := 1 To Len(aFieldBrw)
							
							If aFieldBrw[nCmp] == _cCmp1 + "_SIMP"
								
								Aadd(aHeader, {"", aFieldBrw[nCmp], "@BMP", 2,;
						               0, "", "", "C", "", ""})
								
							ElseIf aFieldBrw[nCmp] == _cCmp1 + "_DSCR"
								
								Aadd(aHeader, {"Descricao", aFieldBrw[nCmp], "", 15,;
												0, "", "", "C", "", ""})
								
							ElseIf aFieldBrw[nCmp] == _cCmp1 + "_ULTMNT"
								
								Aadd(aHeader, {"Ult. Manif.", aFieldBrw[nCmp], "", 27,;
												0, "", "", "C", "", ""})
								
							ElseIf aFieldBrw[nCmp] == _cCmp1 + "_JUST"
								
								Aadd(aHeader, {"Justificativa", aFieldBrw[nCmp], "", 10,;
												0, "", "", "M", "", ""})
												
							ElseIf aFieldBrw[nCmp] == _cCmp1 + "_RETOR"
								
								Aadd(aHeader, {"Retornar?", aFieldBrw[nCmp], "@BMP", 2,;
												0, "", "", "C", "", ""})
								
							ElseIf SX3->( dbSeek(aFieldBrw[nCmp]) )
								
								Aadd(aHeader, {AllTrim( X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO,;
						               SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, cAliXML, SX3->X3_CONTEXT})
								
							EndIf
							
						Next nCmp
						
						oBrwXML := MsGetDB():New(05, 05, 145, 195, 3, "AlwaysTrue", "AlwaysTrue", /*"+" + _cCmp1 + "_SEQIMP"*/, .T., {_cCmp1 + "_MNTO1", _cCmp1 + "_JUST"},, .F., 999, cAliXML, , , .F., oLayerXML:GetWinPanel('COL_MAIN', 'WIN_COL_MAIN', 'MAIN'), , , "AlwaysTrue",)
						
						oBrwXML:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						oBrwXML:oBrowse:bChange := {|| cMsgMemo := (cAliXML)->&(_cCmp1 + "_ERRO"), oMsgMemo:Refresh()}
						
						oBrwXML:oBrowse:bAdd := {|| }
						oBrwXML:oBrowse:bLDblClick := {|nRow, nCol| U_GOX11CK(nRow, nCol)}
						
			oLayerXML:AddLine('BOTTOM', 15, .F.)
				
				oLayerXML:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')
						
					oMsgMemo := tMultiget():New(10, 10, {|u| If(Pcount() > 0, cMsgMemo := u, cMsgMemo)}, ;
								oLayerXML:GetColPanel('COL_BOTTOM', 'BOTTOM'), ;
								100, 100, , , , , , .T., , , , , , .T., , , , .F.)
					oMsgMemo:Align := CONTROL_ALIGN_ALLCLIENT
					oMsgMemo:EnableVScroll(.T.)
					oMsgMemo:EnableHScroll(.F.)
					oMsgMemo:lWordWrap := .T.
					oMsgMemo:Refresh()
					
			oLayerXML:AddLine('BUTTON', 5, .F.)
				
				oLayerXML:AddCollumn('COL_BUTTON', 100, .T., 'BUTTON')
					
					oPanelBot := tPanel():New(0, 0, "", oLayerXML:GetColPanel('COL_BUTTON', 'BUTTON'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oQuit := THButton():New(0, 0, "&Sair", oPanelBot, {|| oDlgMain:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oQuit := THButton():New(0, 0, "&Manifestar", oPanelBot, {|| Manifestar()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oQuit := THButton():New(0, 0, "&Limpar", oPanelBot, {|| LimpaXML()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oQuit := THButton():New(0, 0, "&XML's Erro Manif.", oPanelBot, {|| XmlErroMan()}, , , )
					oQuit:nWidth  := 90
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgMain CENTERED
	
	oXml := Nil
	DelClassIntf()
	
	GFEDelTab(cAliXML)
	
Return

User Function GOX11GMD(cChave)
	
	Local aRet := {.F., ""}
	
	oWSMnf := WSGdeManif():New()
	
	oWSMnf:cCNPJ  := SM0->M0_CGC
	oWSMnf:cChave := cChave
	oWSMnf:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
	oWSMnf:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
	
	If oWSMnf:GetManifestacao()
		
		aRet := {.T., AllTrim(oWSMnf:cGetManifestacaoResult)}
		
	EndIf
	
Return aRet

//Função para marcar uma chave como processada no BRProj

User Function GOX11PRC(cChave)
	
	Local lRet := .F.
	Local oCabUpd := WSGDeWService():New()
	Local cMsg := ""
	
	oCabUpd:cCNPJ  := SM0->M0_CGC
	oCabUpd:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
	oCabUpd:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))

	cChave := AllTrim(cChave)
	
	oCabUpd:CCHAVE	   := cChave
	oCabUpd:cconteudo  := 'P' // Conteúdo a ser gravado no campo customizado
	oCabUpd:nnCustom   := 1   // Número do campo Customizado (qual campo customizado)(Podem ser criados até n campos customizados)
	
	oCabUpd:cStatusDoc := " "
	
	If oCabUpd:UpdateCustom()

		// Caso precise fazer algo depois de marcado como processado no BrProj
		
		lRet := .T.
		
	Else
		
		//lRet := .F.
		
		cMsg := GetWSCError()
		
	EndIf
	
Return {lRet, cMsg}

User Function GOX11MD(cChave, cOper, cJust)
	
	Local lRet      := .F.
	Local cMsg      := ""
	Local oWSMnf
	Local aAreaTab  := (_cTab1)->( GetArea() )
	Local cDescOper
	Local oWFMnf
	
	Local cTp := ""
	
	Private oCabUpd	:= WSGDeWService():New()

	Default cOper := "2"
	Default cJust := ""
	
	oCabUpd:cCNPJ  := SM0->M0_CGC
	oCabUpd:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
	oCabUpd:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))

	cChave := AllTrim(cChave)
	cOper  := SubStr(cOper, 1, 1)
		
	cTp := SubStr(cChave, 21, 2)
		
	If Empty(cChave)
		
		Return {.F., "Chave não informada."}
		
	EndIf
	
	If !(cOper $ "1/2/3/4")
		
		Return {.F., "Operação inválida."}
		
	EndIf
	
	oCabUpd:CCHAVE	   := cChave
	oCabUpd:cconteudo  := 'P' // Conteúdo a ser gravado no campo customizado
	oCabUpd:nnCustom   := 1   // Número do campo Customizado (qual campo customizado)(Podem ser criados até n campos customizados)
	
	oCabUpd:cStatusDoc := " "
	
	If oCabUpd:UpdateCustom()

		// Caso precise fazer algo depois de marcado como processado no BrProj
		
	Else
		
		lRet := .F.
		
		cMsg := GetWSCError()
		
	EndIf

	If cTp == "57"
		
		Return {lRet, cMsg}
		
	EndIf

	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )
	If (_cTab1)->( dbSeek(AllTrim(cChave) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChave) + "2") )
		
		If (Date() - (_cTab1)->&(_cCmp1+"_DTEMIS")) > 180 
			
			Return {.F., "A Nota foi emitida há mais de 180 dias. Portanto, ela não erá manifestada."}
			
		EndIf
		
	EndIf
	
	If cOper == "1"
		
		cDescOper := "Ciência da Operação"
		
	ElseIf cOper == "2"
		
		cDescOper := "Confirmação da Operação"
		
	ElseIf cOper == "3"
		
		cDescOper := "Desconhecimento da Operação"
		
	ElseIf cOper == "4"
		
		cDescOper := "Operação não Realizada"
		
	EndIf
	
	oWSMnf := WSGdeManif():New()
	
	oWSMnf:cCNPJ          := SM0->M0_CGC
	oWSMnf:cChave         := cChave
	oWSMnf:cLogin         := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
	oWSMnf:cSenha         := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
	oWSMnf:cManifestacao  := cOper
	oWSMnf:cJustificativa := cJust
	
	If oWSMnf:PutManifestacao()
		
		If oWSMnf:cPutManifestacaoResult == "OK"
			
			lRet := .T.
			
			//GoOne - Crele Cristina - Chamado 28280: Mudança no tratamento da manifestações incluindo outros controles
			/*
			If File("\workflow\modelos\importador\XML_MNF.htm")
				
				dbSelectArea(_cTab1)
				(_cTab1)->( dbSetOrder(1) )
				If (_cTab1)->( dbSeek(AllTrim(cChave) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChave) + "2") )
					
					oWFMnf := TWFProcess():New("000001", OemToAnsi("Manifesto Destinatário Automático"))
					
					oWFMnf:NewTask("000001", "\workflow\modelos\importador\XML_MNF.htm")
					
					oWFMnf:cSubject 	:= "Manifesto Destinatário Automático"
					oWFMnf:bReturn  	:= ""
					oWFMnf:bTimeOut	:= {}
					oWFMnf:fDesc 		:= "Manifesto Destinatário Automático"
					oWFMnf:ClientName(cUserName)
					
					oWFMnf:oHTML:ValByName('cEmpresa', cEmpAnt + " - " + AllTrim(FWGrpName()))
					
					AAdd(oWFMnf:oHTML:ValByName('xm.cFilial'), cFilAnt)
					AAdd(oWFMnf:oHTML:ValByName('xm.cChave') , (_cTab1)->&(_cCmp1 + "_CHAVE"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cNumero'), (_cTab1)->&(_cCmp1 + "_DOC"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cForn')  , (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cValor') , Transform((_cTab1)->&(_cCmp1 + "_TOTVAL"), "@E 999,999,999.99"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cTipo')  , "(" + cOper + ") - " + cDescOper)
					
				EndIf
				
			EndIf
			*/
			//Flag como MANIFESTADO o documento
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek(AllTrim(cChave) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChave) + "2") )
				(_cTab1)->(RecLock(_cTab1, .F.))
				(_cTab1)->&(_cCmp1+"_MNTO"+IIf(cOper=="A", "1", cOper)) := "1"
				(_cTab1)->(msUnlock())
			Endif
			
		Else
			
			cMsg := oWSMnf:cPutManifestacaoResult
			
			//GoOne - Crele Cristina - Chamado 28280: Mudança no tratamento da manifestações incluindo outros controles
			/*
			If File("\workflow\modelos\importador\XML_MNF_ERRO.htm")
				
				dbSelectArea(_cTab1)
				(_cTab1)->( dbSetOrder(1) )
				If (_cTab1)->( dbSeek(AllTrim(cChave) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChave) + "2") )
					
					oWFMnf := TWFProcess():New("000001", OemToAnsi("Erro em Manifesto automático"))
					
					oWFMnf:NewTask("000001", "\workflow\modelos\importador\XML_MNF_ERRO.htm")
					
					oWFMnf:cSubject 	:= "Erro em Manifesto automático"
					oWFMnf:bReturn  	:= ""
					oWFMnf:bTimeOut	:= {}
					oWFMnf:fDesc 		:= "Erro em Manifesto automático"
					oWFMnf:ClientName(cUserName)
					
					oWFMnf:oHTML:ValByName('cEmpresa', cEmpAnt + " - " + AllTrim(FWGrpName()))
					
					AAdd(oWFMnf:oHTML:ValByName('xm.cFilial'), cFilAnt)
					AAdd(oWFMnf:oHTML:ValByName('xm.cChave') , (_cTab1)->&(_cCmp1 + "_CHAVE"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cNumero'), (_cTab1)->&(_cCmp1 + "_DOC"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cForn')  , (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cValor') , Transform((_cTab1)->&(_cCmp1 + "_TOTVAL"), "@E 999,999,999.99"))
					AAdd(oWFMnf:oHTML:ValByName('xm.cTipo')  , "(" + cOper + ") - " + cDescOper)
					AAdd(oWFMnf:oHTML:ValByName('xm.cErro')  , cMsg)
					
				EndIf
				
			EndIf
			*/
						
			//Flag como MANIFESTADO o documento
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek(AllTrim(cChave) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChave) + "2") )
				(_cTab1)->(RecLock(_cTab1, .F.))
				(_cTab1)->&(_cCmp1+"_MNTO"+IIf(cOper=="A", "1", cOper)) := "E"
				(_cTab1)->(msUnlock())
			Endif
			
		EndIf
		
	Else
		
		cMsg := GetWSCError()
		
		//GoOne - Crele Cristina - Chamado 28280: Mudança no tratamento da manifestações incluindo outros controles
		/*
		If File("\workflow\modelos\importador\XML_MNF_ERRO.htm")
			
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek(AllTrim(cChave) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChave) + "2") )
				
				oWFMnf := TWFProcess():New("000001", OemToAnsi("Erro em Manifesto automático"))
				
				oWFMnf:NewTask("000001", "\workflow\modelos\importador\XML_MNF_ERRO.htm")
				
				oWFMnf:cSubject 	:= "Erro em Manifesto automático"
				oWFMnf:bReturn  	:= ""
				oWFMnf:bTimeOut	:= {}
				oWFMnf:fDesc 		:= "Erro em Manifesto automático"
				oWFMnf:ClientName(cUserName)
				
				oWFMnf:oHTML:ValByName('cEmpresa', cEmpAnt + " - " + AllTrim(FWGrpName()))
				
				AAdd(oWFMnf:oHTML:ValByName('xm.cFilial'), cFilAnt)
				AAdd(oWFMnf:oHTML:ValByName('xm.cChave') , (_cTab1)->&(_cCmp1 + "_CHAVE"))
				AAdd(oWFMnf:oHTML:ValByName('xm.cNumero'), (_cTab1)->&(_cCmp1 + "_DOC"))
				AAdd(oWFMnf:oHTML:ValByName('xm.cForn')  , (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
				AAdd(oWFMnf:oHTML:ValByName('xm.cValor') , Transform((_cTab1)->&(_cCmp1 + "_TOTVAL"), "@E 999,999,999.99"))
				AAdd(oWFMnf:oHTML:ValByName('xm.cTipo')  , "(" + cOper + ") - " + cDescOper)
				AAdd(oWFMnf:oHTML:ValByName('xm.cErro')  , cMsg)
				
			EndIf
			
		EndIf
		*/
		
		//Flag como MANIFESTADO o documento
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		If (_cTab1)->( dbSeek(AllTrim(cChave) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChave) + "2") )
			(_cTab1)->(RecLock(_cTab1, .F.))
			(_cTab1)->&(_cCmp1+"_MNTO"+cOper) := "E"
			(_cTab1)->(msUnlock())
		Endif
			
	EndIf
	
	//GoOne - Crele Cristina - Chamado 28280: Mudança no tratamento da manifestações incluindo outros controles
	/*
	If ValType(oWFMnf) == "O"
		
		oWFMnf:cTo := GetNewPar("MV_ZSNXMNE", "octaviomac@gmail.com")
		
		// Inicia o processo
		oWFMnf:Start()
		// Finaliza o processo
		oWFMnf:Finish()
		
	EndIf
	*/
		
	RestArea(aAreaTab)
	
Return {lRet, cMsg}

Static Function BuscaXML(cInfXML)
	
	Local aAreaTb1 := (_cTab1)->( GetArea() ) 
	Local cMsgYN   := ""
	Local nRetXML
	
	Default cInfXML := ""
	
	cChvMemo := ""
	
	If !Empty(cInfXML)
		
		cChaveSeek := cInfXML
		
	EndIf
	
	If !Empty(cChaveSeek)
		
		lFocusChv := .T.
		
		If Len(AllTrim(cChaveSeek)) # 44
			
			// Avisar que a chave está errada
			cChvMemo := "Chave inválida! É necessário informar 44 números."
			Return .T.
			
		EndIf
		
		// Fazer a busca e marcar
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		If (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "2") )
			
			// Produto cartesiano das possibilidades
			
			If (_cTab1)->&(_cCmp1 + "_FILIAL") # cFilAnt
				
				If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
					
					cChvMemo := "NF-e de chave " + AllTrim(cChaveSeek) + " pertence a filial " + (_cTab1)->&(_cCmp1 + "_FILIAL") + ", entre na filial em questão para processar este XML."
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
					
					cChvMemo := cChvMemo := "CT-e de chave " + AllTrim(cChaveSeek) + " pertence a filial " + (_cTab1)->&(_cCmp1 + "_FILIAL") + ", entre na filial em questão para processar este XML."
					
				EndIf
				
			Else
				
				If AddTabXML()
					
					cChvMemo := "XML de chave " + AllTrim(cChaveSeek) + " selecionado para manifestar."
					
				Else
					
					cChvMemo := "XML de chave " + AllTrim(cChaveSeek) + " já selecionado."
					
				EndIf
				
			EndIf
			
		Else
			
			cChvMemo := "XML de chave " + AllTrim(cChaveSeek) + " não baixado ou inválido."
			
		EndIf
		
		RestArea(aAreaTb1)
		
		cChaveSeek := Space(45)
		
		oChvMemo1:Refresh()
		oChvSeek1:Refresh()
		oChvSeek1:SetFocus()
		
		oBrwXML:_dbGoTop()
		oBrwXML:ForceRefresh()
		
	ElseIf lFocusChv
		
		lFocusChv := .F.
		cChvMemo  := ""
		
	EndIf
	
Return !lFocusChv

Static Function AddTabXML()
	
	Local nI
	Local cDesc := ""
	Local aMnt
	Local cMnt  := ""
	
	(cAliXML)->( dbSetOrder(1) )
	If !(cAliXML)->( dbSeek((_cTab1)->&(_cCmp1 + "_CHAVE")) )
		
		oBrwXML:AddLine()
		
		For nI := 1 To Len(aFieldStr)
			
			If aFieldStr[nI] == _cCmp1 + "_SIMP"
					
				oBrwXML:_FieldPut(nI, "BR_PRETO", aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_DSCR"
				
				Do Case
					
					Case (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
						
						cDesc := "NF-e"
						
					Case (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
						
						If SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 21, 2) == "67"
							
							cDesc := "CT-e OS"
							
						Else
							
							cDesc := "CT-e " + IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "F", "(Saída)", "(Entrada)")
							
						EndIf
						
				EndCase
				
				If (_cTab1)->&(_cCmp1 + "_SIT") == "5"
					
					cDesc += " [CANC.]"
					
				EndIf
				
				oBrwXML:_FieldPut(nI, cDesc, aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_EMIT"
				
				oBrwXML:_FieldPut(nI, U_GODSEMIT(), aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_JUST"
				
				oBrwXML:_FieldPut(nI, "", aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_MNTO1"
				
				oBrwXML:_FieldPut(nI, " ", aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_ULTMNT"
				
				aMnt := U_GOX11GMD((_cTab1)->&(_cCmp1 + "_CHAVE"))
				
				If aMnt[1]
					
					If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
						
						If aMnt[2] == "1"
							
							cMnt := "Ciência de Operação"
							
						ElseIf aMnt[2] == "2"
							
							cMnt := "Confirmação da Operação"
							
						ElseIf aMnt[2] == "3"
							
							cMnt := "Desconhecimento da Operação"
							
						ElseIf aMnt[2] == "4"
							
							cMnt := "Operação não Realizada"
							
						ElseIf aMnt[2] == "98"
							
							cMnt := "Manif. em Andamento"
							
						EndIf
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
						
						If aMnt[2] $ "1;A"
							
							cMnt := "Frete em Desacordo"
							
						ElseIf aMnt[2] == "98"
							
							cMnt := "Manif. em Andamento"
							
						EndIf
						
					EndIf
					
					If Empty(cMnt)
						
						cMnt := "Nenhuma"
						
					EndIf
					
					oBrwXML:_FieldPut(nI, cMnt, aFieldStr[nI])
					
				Else
					
					oBrwXML:_FieldPut(nI, "Nenhuma", aFieldStr[nI])
					
				EndIf
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_FLAG"
				
				oBrwXML:_FieldPut(nI, .F., aFieldStr[nI])
				
			Else
				
				oBrwXML:_FieldPut(nI, (_cTab1)->&(aFieldStr[nI]), aFieldStr[nI])
				
			EndIf
			
		Next nI
		
		oBrwXML:AddLastEdit(oBrwXML:_RecNo())
		oBrwXML:lNewLine := .F.
		
		oBrwXML:_dbGoTop()
		
		oMsgMemo:Refresh()
		
		Return .T.
		
	EndIf
	
Return .F.

User Function GOX11CK(nRow, nCol)
	
	Local nPosLeg := AScan(aFieldBrw, {|x| x == _cCmp1 + "_SIMP"})
	Local nPosJus := AScan(aFieldBrw, {|x| x == _cCmp1 + "_JUST"})
	
	If nCol == nPosLeg
		
		BrwLegenda("Legenda", "Situações", {{"BR_PRETO", "Aguardando Manifestação"}, {"BR_VERDE", "Manifestado com Sucesso"}, {"BR_VERMELHO", "Erro ao Manifestar"}})
		
	ElseIf nCol == nPosJus .And. !((cAliXML)->&(_cCmp1 + "_MNTO1") $ "4;A")
		
		// Não permite alterar quando não for A ou 4
		
	Else
		
		oBrwXML:EditCell()
		
	EndIf
	
Return

User Function GOX11CB()
	
	Local cRet := "1=Ciência de Operação;2=Confirmação da Operação;3=Desconhecimento da Operação;4=Operação Não Realizada;A=Frete em Desacordo"
	
Return cRet

Static Function Manifestar()
	
	FwMsgRun(, {|| ExecMan()}, "Manifestando XML's", "Aguarde por favor.")
	
Return 

Static Function ExecMan()

	Local aAreaTb1 := (_cTab1)->( GetArea() )
	Local aRet
	Local aDocsErr := {}
	Local cDocErr  := ""
	
	If !VldXMLImp()
		
		Return
		
	EndIf
	
	(cAliXML)->( dbGoTop() )
	
	While !(cAliXML)->( Eof() )
		
		If !(cAliXML)->&(_cCmp1 + "_FLAG") .And. AllTrim((cAliXML)->&(_cCmp1 + "_SIMP")) # "BR_VERDE"
			
			aRet := U_GOX11MD((cAliXML)->&(_cCmp1 + "_CHAVE"), (cAliXML)->&(_cCmp1 + "_MNTO1"), (cAliXML)->&(_cCmp1 + "_JUST"))
			
			If aRet[1]
				
				RecLock(cAliXML, .F.)
					
					(cAliXML)->&(_cCmp1 + "_SIMP") := "BR_VERDE"
					(cAliXML)->&(_cCmp1 + "_ERRO") := ""
					
				(cAliXML)->( MSUnlock() )
				
			Else
				
				AAdd(aDocsErr, {"Chave", (cAliXML)->&(_cCmp1 + "_DOC")})
				
				RecLock(cAliXML, .F.)
					
					(cAliXML)->&(_cCmp1 + "_SIMP") := "BR_VERMELHO"
					(cAliXML)->&(_cCmp1 + "_ERRO") := aRet[2]
					
				(cAliXML)->( MSUnlock() )
				
			EndIf
			
		EndIf
		
		(cAliXML)->( dbSkip() )
		
	EndDo
	
	RestArea(aAreaTb1)
	
	oBrwXML:_dbGoTop()
	
	Eval(oBrwXML:oBrowse:bChange)
	
	If !Empty(aDocsErr)
		
		AEval(aDocsErr, {|x| cDocErr += x[1] + ": " + x[2] + CRLF})
		
		Aviso("Documentos não manifestados", "Atentar que alguns XML's não foram manifestados por erro: " + CRLF + cDocErr, {"Entendi!"}, 3)
		
	Else
		
		MsgInfo("XMl's manifestados com sucesso!")
		
	EndIf
	
Return

Static Function VldXMLImp()
	
	Local lRet := .T.
	Local cTpMnt
	
	(cAliXML)->( dbGoTop() )
	
	While !(cAliXML)->( Eof() )
		
		If !(cAliXML)->&(_cCmp1 + "_FLAG")
			
			If Empty((cAliXML)->&(_cCmp1 + "_MNTO1"))
				
				MsgInfo("Todos os XML's devem ter o tipo de Manifestação informado.", "Validação Manifesto")
				
				lRet := .F.
				
				Exit
				
			EndIf
			
			If AllTrim((cAliXML)->&(_cCmp1 + "_ULTMNT")) == "Manif. em Andamento"
				
				MsgInfo("Não é permitido manifestar um XML que está com outra manifestação em andamento.", "Validação Manifesto")
				
				lRet := .F.
				
				Exit
				
			EndIf
			
			If (cAliXML)->&(_cCmp1 + "_MNTO1") == "A" .And. (cAliXML)->&(_cCmp1 + "_TIPO") # "2"
				
				MsgInfo("A manifestação de Frete em Desacordo só por ser feita para CT-e's", "Validação Manifesto")
				
				lRet := .F.
				
				Exit
				
			EndIf
			
			If (cAliXML)->&(_cCmp1 + "_MNTO1") # "A" .And. (cAliXML)->&(_cCmp1 + "_TIPO") == "2"
				
				MsgInfo("Para CT-e's apenas a manifestação de Frete em Desacordo pode ser realizada.", "Validação Manifesto")
				
				lRet := .F.
				
				Exit
				
			EndIf
			
			If (cAliXML)->&(_cCmp1 + "_MNTO1") $ "A;4" .And. Empty((cAliXML)->&(_cCmp1 + "_JUST")) 
				
				MsgInfo("Para 'Frete em Desacordo' e 'Operação não Realizada' é necessário informar a justificativa.", "Validação Manifesto")
				
				lRet := .F.
				
				Exit
				
			EndIf
			
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek((cAliXML)->&(_cCmp1 + "_CHAVE") + "1") ) .Or. (_cTab1)->( dbSeek((cAliXML)->&(_cCmp1 + "_CHAVE") + "2") )
				
				cTpMnt := IIf((cAliXML)->&(_cCmp1 + "_MNTO1") == "A", "1", (cAliXML)->&(_cCmp1 + "_MNTO1"))
				
				If (_cTab1)->&(_cCmp1 + "_MNTO" + cTpMnt) == "1" 
					
					MsgInfo("A manifestação deste tipo já foi realizada para a nota " + (cAliXML)->&(_cCmp1 + "_DOC") + ".", "Validação Manifesto")
					
					lRet := .F.
					
					Exit
					
				EndIf
				
			EndIf
			
		EndIf
		
		(cAliXML)->( dbSkip() )
		
	EndDo
	
Return lRet

Static Function LimpaXML()
	
	(cAliXML)->( __dbZap() )
	
	oBrwXML:_dbGoTop()
	
	cMsgMemo := ""
	
	oMsgMemo:Refresh()
	
Return

Static Function XmlErroMan()
	
	Local cQuery
	Local aAli := GetArea()
	Local cAli := GetNextAlias()
	
	If MsgYesNo("Deseja buscar todos os Xml's que estão com erro de manifestação?")
		
		cQuery := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName(_cTab1) + " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND " + _cCmp1 + "_FILIAL = '" + cFilAnt + "' AND " + _cCmp1 + "_TIPO IN ('1', '2') "
		cQuery += " AND (" + _cCmp1 + "_MNTO1 = 'E' OR " + _cCmp1 + "_MNTO2 = 'E' " 
		cQuery += " 	OR " + _cCmp1 + "_MNTO3 = 'E' OR " + _cCmp1 + "_MNTO4 = 'E') "
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAli, .F., .T.)
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				(_cTab1)->( dbGoTo((cAli)->RECNO) )
				
				BuscaXML((_cTab1)->&(_cCmp1 + "_CHAVE"))
				
				(cAli)->( dbSkip() )
				
			EndDo
			
			(cAliXML)->( dbGoTop() )
			
		Else
			
			MsgInfo("Nenhum XML com erro de manifestação encontrado!")
			
		EndIf
		
		(cAli)->( dbCloseArea() )
				
	EndIf
	
	RestArea(aAli)
	
Return
