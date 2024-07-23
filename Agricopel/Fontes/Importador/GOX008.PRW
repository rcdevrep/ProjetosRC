#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSMGADD.CH"
#INCLUDE "TCBROWSE.CH"

#DEFINE GOLOG_DISABLED "1"
#DEFINE GOLOG_INFO "2"
#DEFINE GOLOG_DEBUG "3"
#DEFINE GOLOG_CONSOLE "4"

// Importação simplificada de XML

User Function GOX008()

	Local oDlgMain, oBmp 
	Local aTotIniDoc
	Local cArqTabXml
	Local aStruXml
	Local cArqTabFil
	Local aStruFil
	Local oNovo        := LoadBitmap(GetResources(), 'BR_VERDE')
	Local oErro        := LoadBitmap(GetResources(), 'BR_VERMELHO')
	Local oOK          := LoadBitmap(GetResources(), 'BR_AZUL')
	Local oDesab       := LoadBitmap(GetResources(), 'BR_CINZA')
	Local aAcesso
	Local cChave       := Space(140)
	Local oBtOk, oChave
	Local nTamPesq     := 0
	Local nPosPesq     := 0
	
	// Variáveis GOX008
	
	Local aStrucTab    := {}
	Local aIndexTab    := {}
	Local nCmp
	
	//Local cPermit      := GetNewPar("MV_XGTGERP", "")
	Local cTpLog       := GetNewPar("MV_XGTLOG", "I")
	
	//////////////////////
	
	//////////////////////////////////////// Variáveis das tabelas
	Private _cTab1     := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cTab2     := Upper(AllTrim(GetNewPar("MV_XGTTAB2", "")))  // Importador NFe
	//Private _cTab3     := Upper(AllTrim(GetNewPar("MV_XGTTAB3", "")))  // Usuários Importador
	Private _cTab4     := Upper(AllTrim(GetNewPar("MV_XGTTAB4", "")))  // Tabela Unidade de Medida por Produto
	Private _cTab5     := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
	Private _cTab6     := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
	Private _cTab8     := Upper(AllTrim(GetNewPar("MV_ZGOTAB8", "")))  // 
	
	Private _cCmp1     := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	Private _cCmp2     := IIf(SubStr(_cTab2, 1, 1) == "S", SubStr(_cTab2, 2, 2), _cTab2)
	//Private _cCmp3     := IIf(SubStr(_cTab3, 1, 1) == "S", SubStr(_cTab3, 2, 2), _cTab3)
	Private _cCmp4     := IIf(SubStr(_cTab4, 1, 1) == "S", SubStr(_cTab4, 2, 2), _cTab4)
	Private _cCmp5     := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
	Private _cCmp6     := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
	Private _cCmp8     := IIf(SubStr(_cTab8, 1, 1) == "S", SubStr(_cTab8, 2, 2), _cTab8)
	////////////////////////////////////////
	
	Private aSize      := MsAdvSize(.F., .F.)
	Private aObjects   := {{ 100, 100 , .T., .T. }} 
	Private aInfo      := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], -3, -13}
	Private aPosObj    := MsObjSize( aInfo, aObjects)
	Private oFont1     := TFont():New('Arial', , -12, , .T.)
	Private oFont2     := TFont():New('Arial', , -11, , .T.)
	Private cEntrada   := Space(200)
	Private cSaida	   := Space(200)
	Private cProc	   := Space(200)
	Private lConfere   := GetNewPar("MV_XGTCONF", .T.)
	Private cFil       := cFilAnt
	Private cEmp       := FWGrpCompany()
	Private cEmpName   := FWGrpName()
	Private cFilName   := FWFilialName()
	Private cCombo2    := "N"
	Private cError     := ""
	Private cWarning   := ""
	Private cEspNFe    := PadR(GetNewPar("MV_XGTNFES", ""), TamSX3("F1_ESPECIE")[1])
	Private cEspNFSe   := PadR(GetNewPar("MV_XGTNFCE", "NFS"), TamSX3("F1_ESPECIE")[1])
	Private cEspNFCe   := PadR(GetNewPar("MV_XGTNFCE", "NFCE"), TamSX3("F1_ESPECIE")[1])
	Private cEspCTe    := GetNewPar("MV_XGTCTES", "")
	Private cEspCTeOS  := PadR(GetNewPar("MV_XGTCTOS", "CTEOS"), TamSX3("F1_ESPECIE")[1])
	Private oLayerXML
	Private oBrowseXML
	Private oGOLog, oMemoLog, cMemo
	Private lSaveLog   := .F.
	Private lVldErro   := .F.
	Private lVlErrMsg  := .F.
	Private cBrowse    := ""
	Private aSM0       := FWLoadSM0()
	Private nTamNota   := GetNewPar("MV_XGTTMNF", 9)
	Private nTamCmpNF  := TamSX3("F1_DOC")[1]
	Private nTamCmpSer := TamSX3("F1_SERIE")[1]
	Private bUpdBrwCTe := {|| IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "F", (cCombo2 := "S"), (cCombo2 := "E")), oCombo2:Refresh(), .T.}
	Private oPnPesqui, oPnLista
	Private oChvSeek1
	Private cChaveSeek := Space(45)
	Private lxgtLSer   := GetNewPar("MV_XGTLSER", .F.)  // Parâmetro para limpar série
	Private lFocusChv  := .T.
	Private oChvMemo1
	Private cChvMemo   := ""
	
	// Variável que indica se utilizará a conversão de unidade de medida
	Private lUMConv    := GetNewPar("MV_XSNUMCV", .T.)
	Private lUMMsg     := GetNewPar("MV_XSNUMMS", .F.)
	
	// Variável para quando a tentativa de baixa do XML pela chave não ocorra com sucesso, guarde a mensagem de erro.
	Private cRetBxXML := ""
	
	// Variáveis GOX008
	
	Private nTotIdx    := 0
	Private cAliXML
	Private oMsgMemo
	Private cMsgMemo   := ""
	Private oBrwXML	
	Private aRotina := {{ "aRotina Falso", "AxPesq",	0, 1 },;
						{ "aRotina Falso", "AxVisual",	0, 2 },;
						{ "aRotina Falso", "AxInclui",	0, 3 },;
						{ "aRotina Falso", "AxAltera",	0, 4 }}
	Private aHeader := {}
	Private nXMLCnt := 0
	
	Private cGOMark := GetMark()
	
	// Campos da tabela temporária
	Private aFieldStr
	// Campos para o Browse
	Private aFieldBrw
	
	Private cCond   := PadR(GetNewPar("MV_ZGOCPCT", ""), TamSX3("E4_CODIGO")[1]) //Space(TamSX3("E4_CODIGO")[1])
	Private cNatur  := PadR(GetNewPar("MV_ZGONTCT", ""), TamSX3("ED_CODIGO")[1]) //21532     
	Private cTesE   := PadR(GetNewPar("MV_ZGOTECT", ""), TamSX3("F4_CODIGO")[1]) //Space(TamSX3("F4_CODIGO")[1])
	Private cTesS   := PadR(GetNewPar("MV_ZGOTSCT", ""), TamSX3("F4_CODIGO")[1]) //Space(TamSX3("F4_CODIGO")[1])
	
	Private cCCS    := PadR(GetNewPar("MV_ZGOCCCS", ""), TamSX3("D1_CC")[1]) //Centro de Custo para CT-e de Saída
	Private dCtVenc := CToD("  /  /    ") //Vencimento dos CT-e's
	
	Private lUsaLib := GetNewPar("MV_ZGOLIBX", .F.) // Indica se utiliza processo de liberação do XML
	Private lUsuLib	:= U_GOX14LIB() //__cUserId $ GetNewPar("MV_ZGOUSUL", "") .Or. FwIsAdmin() //Indica que é usuário de liberação
	
	Private cPrdFrtSai := PadR(GetNewPar("MV_XGTFRET", ""), TamSX3("B1_COD")[1])

	Private aOrd := {}

	private lTdCab := .f.
	

	
	aFieldStr := {_cCmp1 + "_SIMP", _cCmp1 + "_DSCR", _cCmp1 + "_CHAVE", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CGCEMI", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_DTEMIS", _cCmp1 + "_NATOP", _cCmp1 + "_SIT", _cCmp1 + "_TIPO", _cCmp1 + "_TIPOEN", _cCmp1 + "_OK", _cCmp1 + "_RETOR", _cCmp1 + "_CLASS", _cCmp1 + "_PRENOT", _cCmp1 + "_ERRO", _cCmp1 + "_SEQIMP", _cCmp1 + "_TPCOMP", _cCmp1 + "_FLAG"}
	
	aFieldBrw := {_cCmp1 + "_SIMP", _cCmp1 + "_DSCR", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CGCEMI", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_DTEMIS", _cCmp1 + "_TIPOEN", _cCmp1 + "_TPCOMP", _cCmp1 + "_RETOR", _cCmp1 + "_CLASS", _cCmp1 + "_PRENOT", _cCmp1 + "_NATOP", _cCmp1 + "_CHAVE"}
	
	////////////////////////////////////////
	
	cFilAnt := AllTrim(cFilAnt)
	
	If !Empty(cEspNFe)
		
		cEspNFe := PadR(StrTokArr(cEspNFe, ";")[1], 5)
		
	Else
		
		cEspNFe := Space(5)
		
	EndIf
	
	If !Empty(cEspCTe)
	
		cEspCTe := PadR(StrTokArr(cEspCTe, ";")[1], 5)
		
	Else
	
		cEspCTe := Space(5)
		
	EndIf
	
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
	
		Aviso("Parâmetros de tabela", "É necessário informar os parâmetros das tabelas utilizadas pelo importador ('MV_XGTTAB1', 'MV_XGTTAB2', 'MV_XGTTAB3', 'MV_XGTTAB4', 'MV_XGTTAB5' e 'MV_XGTTAB6') e executar o compatibilizador U_UPDSEN01.", {"Ok"}, 2)
		Return
		
	EndIf
	
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	
	If !(SX3->( dbSeek(_cCmp1 + "_FILIAL") ) .And. SX3->( dbSeek(_cCmp5 + "_FILIAL") ) .And. SX3->( dbSeek(_cCmp6 + "_FILIAL") ))
	
		Aviso("Atualização de Dicionário", "É necessário execução do compatibilizador U_UPDSEN01 para utilização desta rotina.", {"Ok"}, 2)
		Return
		
	EndIf
	
	// Posiciona no cadastro de usuário do Importador
	If !U_GOX14POS()
		
		Aviso("Usuário sem acesso", "O usuário não tem permissão de utilizar o Importador. Deverá ser cadastrada as permissões do usuário no programa de Usuários do Importador.")
		REturn 
		
	EndIf
	
	oGOLog := GOLog():New("importador", "Importador", IIf(cTpLog == "I", ;
																GOLOG_INFO, ;
																IIf(cTpLog == "C", ;
																	GOLOG_CONSOLE, ;
																	GOLOG_DISABLED ;
																) ;
														 ), GetNewPar("MV_ZLGIMPA", .T.))
	
	//-------- Criação da Tabela Temporária
	
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	
	For nCmp := 1 To Len(aFieldStr)
		
		If aFieldStr[nCmp] == _cCmp1 + "_SIMP"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 15, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_DSCR"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 15, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_FLAG"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "L", 1, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_RETOR"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 10, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_CLASS"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 10, 0})
			
		ElseIf aFieldStr[nCmp] == _cCmp1 + "_PRENOT"
			
			AAdd(aStrucTab, {aFieldStr[nCmp], "C", 10, 0})
			
		ElseIf SX3->( dbSeek(aFieldStr[nCmp]) )
			
			AAdd(aStrucTab, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
			
		EndIf
		
	Next nCmp
	
	dbSelectArea("SIX")
	SIX->( dbSetOrder(1) )
	SIX->( dbSeek(_cTab1) )
	
	While SIX->INDICE == _cTab1
		
		If !(_cCmp1 + "_FILIAL" $ SIX->CHAVE)
			
			nTotIdx++
			
			AAdd(aIndexTab, AllTrim(SIX->CHAVE))
			
		EndIf
		
		SIX->( dbSkip() )
		
	EndDo
	
	nTotIdx++
	
	AAdd(aIndexTab, _cCmp1 + "_SEQIMP")
	
	cAliXML := GFECriaTab({aStrucTab, aIndexTab})
	
	(cAliXML)->( dbSetOrder(nTotIdx) )
	
	//-------------------------------------
	
	DEFINE MSDIALOG oDlgMain FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE 'Importador XML' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgMain:lEscClose := .F.
		
		SetKey(VK_F4, {|| FiltraXML()})
		
		//////////////////////////////////////// XML
		
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
								
							ElseIf aFieldBrw[nCmp] == _cCmp1 + "_RETOR"
								
								Aadd(aHeader, {"Retornar?", aFieldBrw[nCmp], "@BMP", 2,;
												0, "", "", "C", "", ""})
												
							ElseIf aFieldBrw[nCmp] == _cCmp1 + "_CLASS"
								
								Aadd(aHeader, {"Classificar?", aFieldBrw[nCmp], "@BMP", 2,;
												0, "", "", "C", "", ""})
												
							ElseIf aFieldBrw[nCmp] == _cCmp1 + "_PRENOT"
								
								Aadd(aHeader, {"Pré-Nota?", aFieldBrw[nCmp], "@BMP", 2,;
												0, "", "", "C", "", ""})
								
							ElseIf SX3->( dbSeek(aFieldBrw[nCmp]) )
								
								Aadd(aHeader, {AllTrim( X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO,;
						               SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, cAliXML, SX3->X3_CONTEXT})
								
							EndIf
							
						Next nCmp
						
						oBrwXML := MsGetDB():New(05, 05, 145, 195, 3, "U_GOX8LOK", "AlwaysTrue", /*"+" + _cCmp1 + "_SEQIMP"*/, .T., {_cCmp1 + "_TIPOEN", _cCmp1 + "_TPCOMP"},, .F., 999, cAliXML, , , .F., oLayerXML:GetWinPanel('COL_MAIN', 'WIN_COL_MAIN', 'MAIN'), , , "AlwaysTrue",)
						//oBrwXML:lNewLine := .T.
						oBrwXML:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						oBrwXML:oBrowse:bChange := {|| cMsgMemo := (cAliXML)->&(_cCmp1 + "_ERRO"), oMsgMemo:Refresh()}
						
						oBrwXML:oBrowse:bAdd := {|| }
						oBrwXML:oBrowse:bLDblClick := {|nRow, nCol| U_GOX8CLK(nRow, nCol)}
						
			oLayerXML:AddLine('BOTTOM', 15, .F.)
				
				oLayerXML:AddCollumn('COL_BOTTOM', IIf(U_GOX14CTE(), 50, 100), .T., 'BOTTOM')
					
					oMsgMemo := tMultiget():New(10, 10, {|u| If(Pcount() > 0, cMsgMemo := u, cMsgMemo)}, ;
								oLayerXML:GetColPanel('COL_BOTTOM', 'BOTTOM'), ;
								100, 100, , , , , , .T., , , , , , .T., , , , .F.)
					oMsgMemo:Align := CONTROL_ALIGN_ALLCLIENT
					oMsgMemo:EnableVScroll(.T.)
					oMsgMemo:EnableHScroll(.F.)
					oMsgMemo:lWordWrap := .T.
					oMsgMemo:Refresh()
					
				If U_GOX14CTE() // Se usuário tem permissão para importar CT-e
					
					oLayerXML:AddCollumn('COL_INFCTE', 50, .T., 'BOTTOM')
						
						oLayerXML:AddWindow('COL_INFCTE', 'WIN_INFCTE', "Parâmetros para CTe", 100, .F., .T., , 'BOTTOM', )
							
							@002, 003 SAY "TES(Ent.):"      SIZE 030, 008 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') FONT oFont2 COLOR CLR_BLUE
							@000, 035 MSGET cTesE      SIZE 030, 009 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') PICTURE "@!" F3 "SF4" ;
							          WHEN .T. VALID ValListCte(1) HASBUTTON
							          
							@013, 003 SAY "TES(Saída):"      SIZE 030, 008 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') FONT oFont2 COLOR CLR_BLUE
							@011, 035 MSGET cTesS      SIZE 030, 009 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') PICTURE "@!" F3 "SF4" ;
							          WHEN .T. VALID ValListCte(4) HASBUTTON

							// Centro de Custo para CT-e's de Saída
							@013, 068 SAY "CC (Saída):"      SIZE 030, 008 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') FONT oFont2 COLOR CLR_BLUE
							@011, 098 MSGET cCCS      SIZE 060, 009 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') PICTURE "@!" F3 "CTT" ;
							          WHEN .T. VALID ValListCte(5) HASBUTTON
							
							@002, 068 SAY "Natureza:" SIZE 028, 008 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') FONT oFont2 COLOR CLR_BLUE
							@000, 098 MSGET cNatur    SIZE 060, 009 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') PICTURE "@!" F3 "SED" ;
							          WHEN .T. VALID ValListCte(2) HASBUTTON
							          
							@002, 159 SAY "Cond. Pag.:" SIZE 035, 008 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') FONT OFont2 COLOR CLR_BLUE
							@000, 191 MSGET cCond       SIZE 030, 009 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') PICTURE "@!" F3 "SE4" WHEN .T. VALID ValListCte(3) HASBUTTON
							
							If GetNewPar("MV_ZGOIDVC", .F.)
								
								@013, 161 SAY "Dt. Venc.:"  SIZE 035, 008 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') FONT OFont2 COLOR CLR_BLUE
								@011, 193 MSGET dCtVenc     SIZE 050, 009 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') WHEN .T. VALID ValListCte(6) HASBUTTON
								
							EndIf
							
							If GetNewPar("MV_ZPRCTAL", .F.)
								
								// Produto Cte - Entrnada
								@002, 225 SAY "Prd.Cte.(Sai):" SIZE 040, 008 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') FONT OFont2 COLOR CLR_BLUE
								@000, 261 MSGET cPrdFrtSai     SIZE 050, 009 PIXEL OF oLayerXML:GetWinPanel('COL_INFCTE', 'WIN_INFCTE', 'BOTTOM') PICTURE "@" F3 "SB1" WHEN .T. VALID ValListCte(7) HASBUTTON
								
							EndIf
							
				EndIf
				
			oLayerXML:AddLine('BUTTON', 5, .F.)
				
				oLayerXML:AddCollumn('COL_BUTTON', 100, .T., 'BUTTON')
					
					oPanelBot := tPanel():New(0, 0, "", oLayerXML:GetColPanel('COL_BUTTON', 'BUTTON'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					// Lado Esquerdo
					
					oToolBar := TMenuBar():New(oPanelBot)
					oToolBar:SetDefaultUp(.T.)
					
					//oToolBar:nHeight  := 10
					oToolBar:nClrText := RGB(002, 070, 112)
					oToolBar:nClrPane := RGB(239, 243, 247)
					oToolBar:Align    := CONTROL_ALIGN_RIGHT
					
					oMenuXML := TMenu():New(0, 0, 0, 0, .T.,, oPanelBot)
					oToolBar:AddItem('&Outras Ações', oMenuXML, .T.)
						
						If !(lUsaLib .And. lUsuLib)
							
							oOp1 := TMenuItem():New(oMenuXML, 'Documentos Importados',,,, {|| U_GOX1XMLI({{'2', 'Importado', 'GREEN'}})},, /*Resource*/,,,,,,, .T.)
							oMenuXML:Add(oOp1)
							
							oOp2 := TMenuItem():New(oMenuXML, 'Documentos Canc./Bloq.',,,, {|| U_GOX1XMLI({{'5', 'Cancelado', 'RED'}, {'4', 'Entrada bloqueada', 'BLACK'}})},, /*Resource*/,,,,,,, .T.)
							oMenuXML:Add(oOp2)
							
						EndIf
						
						//////////////
						
						//oOpXml := TMenuItem():New(oMenuXML, 'XML',,,, {|| },, /*Resource*/,,,,,,, .T.)
						
						//oMenuXML:Add(oOpXml)
						
						//oXml1 := TMenuItem():New(oPanelBot, 'Ver XML',,,, {|| VerXml()},, /*Resource*/,,,,,,, .T.)
						//oOpXml:Add(oXml1)
						
						////////////
						
						If U_GOX14REL() // (FwIsAdmin() .Or. AllTrim(RetCodUsr()) $ cPermit)
							
							oOpRel := TMenuItem():New(oMenuXML, 'Relatórios',,,, {|| },, /*Resource*/,,,,,,, .T.)
							
							oMenuXML:Add(oOpRel)
							
							oRel1 := TMenuItem():New(oPanelBot, "Relatorio de Notas",,,, {|| U_GOX006()},, /*Resource*/,,,,,,, .T.)
							oOpRel:Add(oRel1)
							
							oRel2 := TMenuItem():New(oPanelBot, "Rel. Notas não importadas",,,, {|| U_GOX009()},, /*Resource*/,,,,,,, .T.)
							oOpRel:Add(oRel2)
							
							oRel3 := TMenuItem():New(oPanelBot, "Rel. Notas Unificado",,,, {|| U_GOX012()},, /*Resource*/,,,,,,, .T.)
							oOpRel:Add(oRel3)
							
						EndIf
						
						If U_GOX14ROT()
							
							oOpRot := TMenuItem():New(oMenuXML, 'Rotinas',,,, {|| },, /*Resource*/,,,,,,, .T.)
							
							oMenuXML:Add(oOpRot)
							
							oRot1 := TMenuItem():New(oPanelBot, 'Gerenciador',,,, {|| U_GOX005()},, /*Resource*/,,,,,,, .T.)
							oOpRot:Add(oRot1)
							
							oRot2 := TMenuItem():New(oPanelBot, 'Tp. NF por CFOP',,,, {|| U_GOX007()},, /*Resource*/,,,,,,, .T.)
							oOpRot:Add(oRot2)
							
							oRot3 := TMenuItem():New(oPanelBot, 'Conversão UM',,,, {|| U_ConUMGO()},, /*Resource*/,,,,,,, .T.)
							oOpRot:Add(oRot3)
							
							oRot4 := TMenuItem():New(oPanelBot, 'Importação Manual',,,, {|| U_GOX1MAN()},, /*Resource*/,,,,,,, .T.)
							oOpRot:Add(oRot4)
							
						EndIf
					
					// Lado direito
					
					oQuit := THButton():New(0, 0, "&Sair", oPanelBot, {|| oDlgMain:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					If lUsaLib .And. lUsuLib
						
						oLib := THButton():New(0, 0, "&Liberar XML", oPanelBot, {|| LiberarXML(), SetKey(VK_F4, {|| FiltraXML()})}, , , )
						oLib:nWidth  := 80
						oLib:nHeight := 10
						oLib:Align   := CONTROL_ALIGN_RIGHT
						oLib:SetColor(RGB(002, 070, 112), )
						
					EndIf
					
					If !(lUsaLib .And. lUsuLib)
						
						oImp := THButton():New(0, 0, "&Importar", oPanelBot, {|| ImportaXML(), SetKey(VK_F4, {|| FiltraXML()})}, , , )
						oImp:nWidth  := 80
						oImp:nHeight := 10
						oImp:Align   := CONTROL_ALIGN_RIGHT
						oImp:SetColor(RGB(002, 070, 112), )
						
						oLimpa := THButton():New(0, 0, "&Limpar", oPanelBot, {|| LimpaXML()}, , , )
						oLimpa:nWidth  := 80
						oLimpa:nHeight := 10
						oLimpa:Align   := CONTROL_ALIGN_RIGHT
						oLimpa:SetColor(RGB(002, 070, 112), )
						
					EndIf
					
	ACTIVATE MSDIALOG oDlgMain CENTERED //ON INIT EnchoiceBar(ODlgMain, {|| Alert("Em construção")}, {|| oDlgMain:End()},, /*aNewButton*/)
	
	SetKey(VK_F4, {|| })
	
	oXml := Nil
	DelClassIntf()
	
	GFEDelTab(cAliXML)
	
Return

// ----------------------------

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
		
		If Len(AllTrim(cChaveSeek)) == 9
			
			FiltraXML()
			
			Return .T.
			
		EndIf
		
		If Len(AllTrim(cChaveSeek)) # 44
			
			// Avisar que a chave está errada
			cChvMemo := "Chave inválida! É necessário informar 44 números."
			Return .T.
			
		EndIf
		
		// Fazer a busca e marcar
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		If (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "2") ) .Or. ;
			(_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "6") ) // Nota Fiscal de Serviço
			
			// Produto cartesiano das possibilidades
			
			If (_cTab1)->&(_cCmp1 + "_FILIAL") # cFilAnt
				
				If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
					
					cChvMemo := "NF-e de chave " + AllTrim(cChaveSeek) + " pertence a filial " + (_cTab1)->&(_cCmp1 + "_FILIAL") + ", entre na filial em questão para processar este XML."
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
					
					cChvMemo := cChvMemo := "CT-e de chave " + AllTrim(cChaveSeek) + " pertence a filial " + (_cTab1)->&(_cCmp1 + "_FILIAL") + ", entre na filial em questão para processar este XML."
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "5"
					
					cChvMemo := "Cancelamento de chave " + AllTrim(cChaveSeek) + " pertence a filial " + (_cTab1)->&(_cCmp1 + "_FILIAL") + ", entre na filial em questão para processar este XML."
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
					
					cChvMemo := "NFS-e pertence a filial " + (_cTab1)->&(_cCmp1 + "_FILIAL") + ", entre na filial em questão para processar este XML."
					
				EndIf
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "6" // XML Inconsistente 
				
				/*If AddTabXML()
					
					If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
						
						cChvMemo := "NF-e inconsistente de chave " + AllTrim(cChaveSeek) + " marcada."
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
						
						cChvMemo := "CT-e inconsistente de chave " + AllTrim(cChaveSeek) + " marcado."
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "5"
						
						cChvMemo := "Cancelamento inconsistente de chave " + AllTrim(cChaveSeek) + " marcado."
						
					EndIf
					
				Else*/
					
					If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
						
						cChvMemo := "NF-e inconsistente de chave " + AllTrim(cChaveSeek) + ". Erro: " + CRLF + (_cTab1)->&(_cCmp1 + "_ERRO")
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
						
						cChvMemo := "CT-e inconsistente de chave " + AllTrim(cChaveSeek) + ". Erro: " + CRLF + (_cTab1)->&(_cCmp1 + "_ERRO")
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
						
						cChvMemo := "NFS-e inconsistente. Erro: " + CRLF + (_cTab1)->&(_cCmp1 + "_ERRO")
						
					/*ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "5"
						
						cChvMemo := "Cancelamento inconsistente de chave " + AllTrim(cChaveSeek) + " já selecionado."*/
						
					EndIf
					
				//EndIf
			
			ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "6" // NFS-e
				
				//.And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3" // XML de Nota Fiscal pendente de importação
				If (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
					
					If AddTabXML()
						
						cChvMemo := "NFS-e de número " + (_cTab1)->&(_cCmp1 + "_DOC") + " selecionada para a área de importação."
						
					Else
						
						cChvMemo := "NFS-e de número " + (_cTab1)->&(_cCmp1 + "_DOC") + " já selecionada na área de importação."
						
					EndIf
					
				ElseIf (_cTab1)->&(_cCmp1 + "_SIT") $ "2"
					
					cChvMemo := "NFS-e de número " + (_cTab1)->&(_cCmp1 + "_DOC") + " já IMPORTADA."
					
				ElseIf (_cTab1)->&(_cCmp1 + "_SIT") $ "5"	
					
					cChvMemo := "NFS-e de número " + (_cTab1)->&(_cCmp1 + "_DOC") + " está CANCELADA."
					
				EndIf
				
			ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "1" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3" // XML de Nota Fiscal pendente de importação
				
				If U_GOX14NF()
					
					// Veriricar se já existe como pré-nota
					
					If AddTabXML()
						
						cChvMemo := "NF-e de chave " + AllTrim(cChaveSeek) + " selecionada para a área de importação."
						
					Else
						
						cChvMemo := "NF-e de chave " + AllTrim(cChaveSeek) + " já selecionada na área de importação."
						
					EndIf
					
				Else
					
					cChvMemo := "Você não tem permissão para Importar Notas Fiscais Eletrônicas."
					
				EndIf
				
			ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "1" .And. (_cTab1)->&(_cCmp1 + "_SIT") == "2" // XML de Nota Fiscal já importada
				
				// [TODO] Verificar se já existe como Pré-Nota
				
				If NfPreNota()
					
					If U_GOX14CLA()
						
						AddTabXML()
						
					Else
						
						cChvMemo := "NF-e de chave " + AllTrim(cChaveSeek) + ", você não tem permissão para classificar notas pelo importador."
						
					EndIf
					
				Else
					
					cChvMemo := "NF-e de chave " + AllTrim(cChaveSeek) + " encontrada como IMPORTADA."
					
				EndIf
				
			ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "1" .And. (_cTab1)->&(_cCmp1 + "_SIT") == "5" // XML de Nota Fiscal cancelada
				
				cChvMemo := "NF-e de chave " + AllTrim(cChaveSeek) + " encontrada como CANCELADA."
				
			ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3" // XML de Conhecimento de Frete pendente de importação
				
				If U_GOX14CTE()
					
					If AddTabXML()
						
						cChvMemo := "CT-e de chave " + AllTrim(cChaveSeek) + " encontrado na área de importação.";
						
					Else
						
						cChvMemo := "CT-e de chave " + AllTrim(cChaveSeek) + " já selecionado.";
						
					EndIf
					
					AltInfoCte()
					
				Else
					
					cChvMemo := "Você não tem permissão para Importar Conhecimentos de Transporte."
					
				EndIf
				
			ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2" .And. (_cTab1)->&(_cCmp1 + "_SIT") == "2" // XML de Conhecimento de Frete já importada
				
				cChvMemo := "CT-e de chave " + AllTrim(cChaveSeek) + " encontrado como IMPORTADO."
				
			ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2" .And. (_cTab1)->&(_cCmp1 + "_SIT") == "5" // XML de Conhecimento de Frete cancelada
				
				cChvMemo := "CT-e de chave " + AllTrim(cChaveSeek) + " encontrado como CANCELADO."
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "4"
				
				cChvMemo += "XML foi bloqueado pelo seguinte motivo: " + CRLF + (_cTab1)->&(_cCmp1 + "_ERRO")
				
			EndIf
			
		ElseIf (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "3") ) .Or. !(_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "3") )
			
			If (_cTab1)->&(_cCmp1 + "_TIPO") == "3"
				
				cChvMemo := "XML de chave " + AllTrim(cChaveSeek) + " com estrutura inválida, deverá ser enviado XML válido."
				
				cMsgYN := "XML recebido com estrutura inválida. Gostaria de realizar nova tentativa de baixa do XML de chave " + AllTrim(cChaveSeek) + " diretamente do BRGDE?" 
				
			Else
				
				cChvMemo := "XML de chave " + AllTrim(cChaveSeek) + " não encontrado no importador."
				
				cMsgYN := "XML não se encontra no Importador. Gostaria de realizar tentativa de baixa do XML de chave " + AllTrim(cChaveSeek) + " diretamente do BRGDE?"
				
			EndIf
			
			If MsgYesNo(cMsgYN, "Busca pela Chave")
				
				//StaticCall(GOX001, ReCarga, cChaveSeek)
				U_GOX1REC(cChaveSeek)
				
				dbSelectArea(_cTab1)
				(_cTab1)->( dbSetOrder(1) )
				If (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "1") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "2") ) .Or. (_cTab1)->( dbSeek(AllTrim(cChaveSeek) + "6") )
					
					cChvMemo := "XML de chave " + AllTrim(cChaveSeek) + " baixado diretamente com sucesso."
					
					If (_cTab1)->&(_cCmp1 + "_SIT") == "4"
						
						cChvMemo += " Porém ele foi bloqueado pelo seguinte motivo: " + CRLF + (_cTab1)->&(_cCmp1 + "_ERRO")
						
					Else
						
						aAreaTb1 := (_cTab1)->( GetArea() )
						
						// [TODO] Ver se isso realmente funciona ! Chamando Recursivo...
						BuscaXML(cChaveSeek)
						
						//AddTabXML()
						
					EndIf
					
				Else
					
					cChvMemo := " Tentativa de baixar o XML de chave " + AllTrim(cChaveSeek) + " diretamente sem sucesso." + CRLF + CRLF + "Problema: " + cRetBxXML
					
				EndIf
				
			EndIf
			
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

// ----------------------------

Static Function AddTabXML()
	
	Local nI
	Local cDesc := ""
	
	oBrwXML:lNewLine := .T.
	
	(cAliXML)->( dbSetOrder(1) )
	If !(cAliXML)->( dbSeek((_cTab1)->&(_cCmp1 + "_CHAVE")) )
		
		(cAliXML)->( dbSetOrder(nTotIdx) )
		
		oBrwXML:AddLine()
		
		For nI := 1 To Len(aFieldStr)
			
			If aFieldStr[nI] == _cCmp1 + "_SIMP"
				
				If (_cTab1)->&(_cCmp1 + "_SIT") == "6"
					
					oBrwXML:_FieldPut(nI, "BR_AMARELO", aFieldStr[nI])
					
				ElseIf lUsaLib .And. (_cTab1)->&(_cCmp1 + "_LIBER") # "1"
					
					oBrwXML:_FieldPut(nI, "BR_VERMELHO", aFieldStr[nI])
					
				Else
					
					oBrwXML:_FieldPut(nI, "BR_PRETO", aFieldStr[nI])
					
				EndIf
				
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
						
					Case (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
						
						cDesc := "NFS-e (Serviço)"
						
					/*Case (_cTab1)->&(_cCmp1 + "_SIT") == "6"
						
						cDesc := "Pendente "
						
						If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
							
							cDesc += "(NF-e)"
							
						ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
							
							cDesc += "(CT-e)"
							
						ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "5"
							
							cDesc += "(Canc."
							
							If (_cTab1)->&(_cCmp1 + "_TPCAN") == "N"
								
								cDesc += " CT-e"
								
							ElseIf (_cTab1)->&(_cCmp1 + "_TPCAN") == "C"
								
								cDesc += " NF-e"
								
							EndIf
							
							cDesc += ")"
							
						EndIf*/
						
				EndCase
				
				oBrwXML:_FieldPut(nI, cDesc, aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_EMIT"
				
				oBrwXML:_FieldPut(nI, U_GODSEMIT(), aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_FLAG"
				
				oBrwXML:_FieldPut(nI, .F., aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_RETOR"
				
				oBrwXML:_FieldPut(nI, "LBNO", aFieldStr[nI])
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_CLASS"
				
				If U_GOX14CLA() .And. NfPreNota(.T.)
					
					oBrwXML:_FieldPut(nI, "LBOK", aFieldStr[nI])
					
				Else
					
					oBrwXML:_FieldPut(nI, "LBNO", aFieldStr[nI])
					
				EndIf
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_PRENOT"
				
				If (_cTab1)->&(_cCmp1 + "_TIPO") == "1" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3" .And. U_GOX14SPN()
					
					oBrwXML:_FieldPut(nI, "LBOK", aFieldStr[nI])
					
				Else
					
					oBrwXML:_FieldPut(nI, "LBNO", aFieldStr[nI])
					
				EndIf
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_TIPOEN" 
			
				If !((_cTab1)->&(_cCmp1 + "_TIPO") $ "1;6")
					
					Loop
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
					
					oBrwXML:_FieldPut(nI, "N", aFieldStr[nI])
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "F" // Para compatibilidade com o Importador antigo
					
					oBrwXML:_FieldPut(nI, " ", aFieldStr[nI])
					
				Else
					
					oBrwXML:_FieldPut(nI, (_cTab1)->&(_cCmp1 + "_TIPOEN"), aFieldStr[nI])
					
				EndIf
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_TPCOMP"
				
				If oBrwXML:_FieldGet(nI, (_cTab1)->&(_cCmp1 + "_TIPOEN")) == "C"
					
					oBrwXML:_FieldPut(nI, "1", aFieldStr[nI])
					
				Else
					
					oBrwXML:_FieldPut(nI, " ", aFieldStr[nI])
					
				EndIf
				
			ElseIf aFieldStr[nI] == _cCmp1 + "_SEQIMP"
				
				oBrwXML:_FieldPut(nI, StrZero(++nXMLCnt, 10), aFieldStr[nI])
				
			Else
				
				oBrwXML:_FieldPut(nI, (_cTab1)->&(aFieldStr[nI]), aFieldStr[nI])
				
			EndIf
			
		Next nI
		
		oBrwXML:AddLastEdit(oBrwXML:_RecNo())
		oBrwXML:lNewLine := .F.
		
		cMsgMemo := (_cTab1)->&(_cCmp1 + "_ERRO")
		
		oMsgMemo:Refresh()
		
		//oBrwXML:GoTo(oBrwXML:_RecCount())
		//(cAliXML)->( dbGoTo(oBrwXML:_RecNo()) )
		//oBrwXML:Refresh(.F.)
		
		Return .T.
		
	EndIf
	
	(cAliXML)->( dbSetOrder(nTotIdx) )
	
Return .F.

// ----------------------------

User Function GOX8LOK(x,y,z)
	
	/*Local nColPos := oBrwXML:oBrowse:nColPos
	Local nRowPos := oBrwXML:oBrowse:nAt
	Local nMaxPos := oBrwXML:oBrowse:nLen   
	
	If !IsInCallStack("AddTabXML")
		
		If oBrwXML:lNewLine
			
			oBrwXML:oBrowse:SKIP(-1)     
			oBrwXML:oBrowse:Refresh()
			
		EndIf
		
	EndIf*/
	
Return .T.

User Function GOX8CMP()
	
	If M->&(_cCmp1 + "_TIPOEN") == "C"
		
		oBrwXML:_FieldPut(, "1", _cCmp1 + "_TPCOMP")
		
	Else
		
		oBrwXML:_FieldPut(, " ", _cCmp1 + "_TPCOMP")
		
	EndIf
	
Return .T.

User Function GOX8CLK(nRow, nCol)
	
	Local nPosRet := AScan(aFieldBrw, {|x| x == _cCmp1 + "_RETOR"})
	Local nPosLeg := AScan(aFieldBrw, {|x| x == _cCmp1 + "_SIMP"})
	Local nPosPre := AScan(aFieldBrw, {|x| x == _cCmp1 + "_PRENOT"})
	
	If nCol == nPosRet .And. oBrwXML:_FieldGet(, _cCmp1 + "_CLASS") == PadR("LBNO", 10) .And. U_GOX14RET()
		
		If oBrwXML:_FieldGet(, _cCmp1 + "_TIPO") == "1" .And. oBrwXML:_FieldGet(, _cCmp1 + "_SIT") # "6"
			
			If oBrwXML:_FieldGet(, _cCmp1 + "_RETOR") == PadR("LBNO", 10)
				
				oBrwXML:_FieldPut(, "LBOK", _cCmp1 + "_RETOR")
				
				oBrwXML:_FieldPut(, "LBNO", _cCmp1 + "_PRENOT")
				
				oBrwXML:_FieldPut(, " ", _cCmp1 + "_TIPOEN")
				oBrwXML:_FieldPut(, " ", _cCmp1 + "_TPCOMP")
				
			Else
				
				oBrwXML:_FieldPut(, "LBNO", _cCmp1 + "_RETOR")
				
				If oBrwXML:_FieldGet(, _cCmp1 + "_TIPO") == "1"
					
					oBrwXML:_FieldPut(, Posicione(_cTab1, 1, oBrwXML:_FieldGet(, _cCmp1 + "_CHAVE") + oBrwXML:_FieldGet(, _cCmp1 + "_TIPO"), _cCmp1 + "_TIPOEN"), _cCmp1 + "_TIPOEN")
					
					If oBrwXML:_FieldGet(, _cCmp1 + "_TIPOEN") == "C"
						
						oBrwXML:_FieldPut(, "1", _cCmp1 + "_TPCOMP")
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	ElseIf nCol == nPosPre .And. oBrwXML:_FieldGet(, _cCmp1 + "_CLASS") == PadR("LBNO", 10) .And. U_GOX14PRE() .And. !U_GOX14SPN()
		
		If oBrwXML:_FieldGet(, _cCmp1 + "_TIPO") == "1" .And. oBrwXML:_FieldGet(, _cCmp1 + "_PRENOT") == PadR("LBNO", 10)
			
			If oBrwXML:_FieldGet(, _cCmp1 + "_TIPO") == "1" .And. oBrwXML:_FieldGet(, _cCmp1 + "_RETOR") == PadR("LBOK", 10)
				
				oBrwXML:_FieldPut(, Posicione(_cTab1, 1, oBrwXML:_FieldGet(, _cCmp1 + "_CHAVE") + oBrwXML:_FieldGet(, _cCmp1 + "_TIPO"), _cCmp1 + "_TIPOEN"), _cCmp1 + "_TIPOEN")
				
				If oBrwXML:_FieldGet(, _cCmp1 + "_TIPOEN") == "C"
					
					oBrwXML:_FieldPut(, "1", _cCmp1 + "_TPCOMP")
					
				EndIf
				
			EndIf
			
			oBrwXML:_FieldPut(, "LBNO", _cCmp1 + "_RETOR")
			
			oBrwXML:_FieldPut(, "LBOK", _cCmp1 + "_PRENOT")
			
		Else
			
			oBrwXML:_FieldPut(, "LBNO", _cCmp1 + "_PRENOT")
			
		EndIf
		
	ElseIf nCol == nPosLeg
		
		BrwLegenda("Legenda", "Situações", {{"BR_PRETO", "Xml marcado para processar"}, {"BR_VERDE", "Importado com sucesso"}, {"BR_VERMELHO", "Erro ao importar"}, {"BR_AMARELO", "XML com inconsistência"}, {"BR_BRANCO", "Nota para Classificar"}})
		
	Else
		
		oBrwXML:EditCell()
		
	EndIf
	
Return

// ----------------------------

User Function GOX8WHN()
	
	If IsInCallStack("U_GOX008")
		
		Return oBrwXML:_FieldGet(, _cCmp1 + "_TIPO") == "1" .And. oBrwXML:_FieldGet(, _cCmp1 + "_SIT") $ "1;3" .And. AllTrim(oBrwXML:_FieldGet(, _cCmp1 + "_RETOR")) == "LBNO" .And. AllTrim(oBrwXML:_FieldGet(, _cCmp1 + "_CLASS")) == "LBNO"
		
	EndIf
	
Return .T.

// ----------------------------

User Function GOX8WHC()
	
	If IsInCallStack("U_GOX008")
		
		Return oBrwXML:_FieldGet(, _cCmp1 + "_TIPO") == "1" .And. oBrwXML:_FieldGet(, _cCmp1 + "_SIT") $ "1;3" .And. oBrwXML:_FieldGet(, _cCmp1 + "_TIPOEN") == "C" .And. AllTrim(oBrwXML:_FieldGet(, _cCmp1 + "_RETOR")) == "LBNO" .And. AllTrim(oBrwXML:_FieldGet(, _cCmp1 + "_CLASS")) == "LBNO"
		
	EndIf
	
Return .T.

// ----------------------------

Static Function ImportaXML()
	
	Local aAreaTb1 := (_cTab1)->( GetArea() )
	Local nRecTb1
	Local lImpCTe  := .T.
	Local aDocsErr := {}
	Local cDocErr  := ""
	
	Local lPreNota
	
	SetKey(VK_F4, {|| })
	
	If !VldXMLImp()
		
		Return
		
	EndIf
	
	//oBrwXML:_dbGoTop()
	(cAliXML)->( dbGoTop() )
	
	While !(cAliXML)->( Eof() )
		
		If !(cAliXML)->&(_cCmp1 + "_FLAG") .And. AllTrim((cAliXML)->&(_cCmp1 + "_SIMP")) # "BR_VERDE"
			
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek((cAliXML)->&(_cCmp1 + "_CHAVE") + (cAliXML)->&(_cCmp1 + "_TIPO")) )
				
				If (_cTab1)->&(_cCmp1 + "_TIPO") == "1" .And. ((_cTab1)->&(_cCmp1 + "_SIT") $ "1;3" .Or. ((_cTab1)->&(_cCmp1 + "_SIT") == "2" .And. NfPreNota()))
					
					nRecTb1 := (_cTab1)->( RecNo() )
					
					//StaticCall(GOX001, ImpAutoXML, "NFE", AllTrim((cAliXML)->&(_cCmp1 + "_RETOR")) == "LBOK", AllTrim((cAliXML)->&(_cCmp1 + "_CLASS")) == "LBOK", AllTrim((cAliXML)->&(_cCmp1 + "_PRENOT")) == "LBOK")
					
					lPreNota := NfPreNota()
					
					U_GOX1IMP("NFE", AllTrim((cAliXML)->&(_cCmp1 + "_RETOR")) == "LBOK", ;
									 AllTrim((cAliXML)->&(_cCmp1 + "_CLASS")) == "LBOK", ;
									 AllTrim((cAliXML)->&(_cCmp1 + "_PRENOT")) == "LBOK")
					
					(_cTab1)->( dbGoTo(nRecTb1) )
					
					If (_cTab1)->&(_cCmp1 + "_SIT") == "2" .And. (!lPreNota .Or. (lPreNota .And. !NfPreNota())) .And. ;
						XmlF1Info("F1_STATUS") # "B"
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIMP") := "BR_VERDE"
							(cAliXML)->&(_cCmp1 + "_SIT")  := "2"
							(cAliXML)->&(_cCmp1 + "_ERRO") := ""
							
						(cAliXML)->( MSUnlock() )
						
						If GetNewPar("MV_ZBSCCTE", .T.) .And. (_cTab1)->&(_cCmp1 + "_TIPO") $ "1;2"
							
							dbSelectArea(_cTab8)
							(_cTab8)->( dbSetOrder(2) )
							(_cTab8)->( dbSeek((_cTab1)->&(_cCmp1 + "_CHAVE")) )
							
							While !(_cTab8)->( Eof() ) .And. (_cTab8)->&(_cCmp8 + "_CHVNFE") == (_cTab1)->&(_cCmp1 + "_CHAVE")
								
								dbSelectArea(_cTab1)
								(_cTab1)->( dbSetOrder(1) )
								If (_cTab1)->( dbSeek((_cTab8)->&(_cCmp8 + "_CHVCTE") + "2") )
									
									U_GOCargaX(, .T.)
									
									BuscaXML((_cTab1)->&(_cCmp1 + "_CHAVE"))
									
								EndIf
								
								(_cTab8)->( dbSkip() )
								
							EndDo
							
						EndIf
						
					Else
						
						AAdd(aDocsErr, {"NF-e", (cAliXML)->&(_cCmp1 + "_DOC")})
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIMP") := IIf(XmlF1Info("F1_STATUS") == "B", "BR_LARANJA", "BR_VERMELHO")
							(cAliXML)->&(_cCmp1 + "_SIT")  := (_cTab1)->&(_cCmp1 + "_SIT")
							(cAliXML)->&(_cCmp1 + "_ERRO") := IIf(Empty((_cTab1)->&(_cCmp1 + "_ERRO")), "Cancelado pelo usuário.", (_cTab1)->&(_cCmp1 + "_ERRO"))
							
						(cAliXML)->( MSUnlock() )
						
					EndIf
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
					
					nRecTb1 := (_cTab1)->( RecNo() )
					
					//StaticCall(GOX001, ImpAutoXML, "CTE")
					
					/*If lImpCTe
						
						StaticCall(GOX001, SelListCte, .T., cGOMark)
						
						lImpCTe := .F.
						
					EndIf*/
					
					// Importação por lote sem mostrar a tela dos selecionados.
					//StaticCall(GOX001, ImportaCTe)
					U_GOX1IMP("CTE")
					
					(_cTab1)->( dbGoTo(nRecTb1) )
					
					If (_cTab1)->&(_cCmp1 + "_SIT") == "2"
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIMP") := "BR_VERDE"
							(cAliXML)->&(_cCmp1 + "_SIT")  := "2"
							(cAliXML)->&(_cCmp1 + "_ERRO") := ""
							
						(cAliXML)->( MSUnlock() )
						
					Else
						
						AAdd(aDocsErr, {"CT-e", (cAliXML)->&(_cCmp1 + "_DOC")})
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIMP") := "BR_VERMELHO"
							(cAliXML)->&(_cCmp1 + "_SIT")  := (_cTab1)->&(_cCmp1 + "_SIT")
							(cAliXML)->&(_cCmp1 + "_ERRO") := IIf(Empty((_cTab1)->&(_cCmp1 + "_ERRO")), "Cancelado pelo usuário.", (_cTab1)->&(_cCmp1 + "_ERRO"))
							
						(cAliXML)->( MSUnlock() )
						
					EndIf
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "6" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
					
					nRecTb1 := (_cTab1)->( RecNo() )
					
					lPreNota := .F.
					
					U_GOX1IMP("NFS")
					
					(_cTab1)->( dbGoTo(nRecTb1) )
					
					If (_cTab1)->&(_cCmp1 + "_SIT") == "2" .And. XmlF1Info("F1_STATUS") # "B"
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIMP") := "BR_VERDE"
							(cAliXML)->&(_cCmp1 + "_SIT")  := "2"
							(cAliXML)->&(_cCmp1 + "_ERRO") := ""
							
						(cAliXML)->( MSUnlock() )
						
					Else
						
						AAdd(aDocsErr, {"NFS-e", (cAliXML)->&(_cCmp1 + "_DOC")})
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIMP") := IIf(XmlF1Info("F1_STATUS") == "B", "BR_LARANJA", "BR_VERMELHO")
							(cAliXML)->&(_cCmp1 + "_SIT")  := (_cTab1)->&(_cCmp1 + "_SIT")
							(cAliXML)->&(_cCmp1 + "_ERRO") := IIf(Empty((_cTab1)->&(_cCmp1 + "_ERRO")), "Cancelado pelo usuário.", (_cTab1)->&(_cCmp1 + "_ERRO"))
							
						(cAliXML)->( MSUnlock() )
						
					EndIf
					
				ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "6" // Está aqui, mas descontinuado pra reprocessar apenas via job
					
					nRecTb1 := (_cTab1)->( RecNo() )
					
					If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
						
						U_GOCargaX(, .T.)
						
						//cDesc := "Nota: "
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
						
						U_GOCargaX(, .T.)
						
						//cDesc := "Conhecimento: "
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "5"
						
						U_GOCargaX(.T., .T.)
						
						//cDesc := "Cancelamento: Seq.(" + cValToChar(Val((_cTab1)->&(_cCmp1 + "_SEQIMP"))) + ")"
						
					EndIf
					
					(_cTab1)->( dbGoTo(nRecTb1) )
					
					If (_cTab1)->&(_cCmp1 + "_SIT") # "6"
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIT")  := "1"
							(cAliXML)->&(_cCmp1 + "_ERRO") := ""
							
						(cAliXML)->( MSUnlock() )
						
						//(cAliXML)->( dbSkip(-1) )
						
					Else
						
						AAdd(aDocsErr, {"Inconsistência " + {"NF-e", "CT-e",,,"Canc."}[Val((cAliXML)->&(_cCmp1 + "_TIPO"))], (cAliXML)->&(_cCmp1 + "_DOC")})
						
						RecLock(cAliXML, .F.)
							
							(cAliXML)->&(_cCmp1 + "_SIMP") := "BR_VERMELHO"
							
						(cAliXML)->( MSUnlock() )
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
		(cAliXML)->( dbSkip() )
		
	EndDo
	
	RestArea(aAreaTb1)
	
	(cAliXML)->( dbGoTop() )
	oBrwXML:_dbGoTop()
	
	oBrwXML:ForceRefresh()
	
	Eval(oBrwXML:oBrowse:bChange)
	
	If !Empty(aDocsErr)
		
		AEval(aDocsErr, {|x| cDocErr += x[1] + ": " + x[2] + CRLF})
		
		Aviso("Documentos não importados", "Atentar que os seguintes documentos não foram importados : " + CRLF + cDocErr, {"Entendi!"}, 3)
		
	EndIf
	
Return

// ----------------------------

Static Function LimpaXML()
	
	(cAliXML)->( __dbZap() )
	
	oBrwXML:_dbGoTop()
	
	cMsgMemo := ""
	
	oMsgMemo:Refresh()
	
Return

// ----------------------------

Static Function VldXMLImp()
	
	Local lRet := .T.
	
	(cAliXML)->( dbGoTop() )
	
	While !(cAliXML)->( Eof() )
		
		If !(cAliXML)->&(_cCmp1 + "_FLAG")
			
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek((cAliXML)->&(_cCmp1 + "_CHAVE") + (cAliXML)->&(_cCmp1 + "_TIPO")) )
				
				If (_cTab1)->&(_cCmp1 + "_TIPO") == "1" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
					
					// Valida NF-e
					
					If Empty((cAliXML)->&(_cCmp1 + "_TIPOEN")) .And. AllTrim((cAliXML)->&(_cCmp1 + "_RETOR")) # "LBOK"
						
						MsgInfo("Todos os XML's do tipo NF-e deverão possuir o tipo de entrada informado.", "Validação NF-e")
						
						lRet := .F.
						
						Exit
						
					ElseIf (cAliXML)->&(_cCmp1 + "_TIPOEN") == "C" .And. !((cAliXML)->&(_cCmp1 + "_TPCOMP") $ "1,2,3")
						
						MsgInfo("Notas de Complemento de Preço/Frete/Quantidade devem ter seu tipo especificado no campo 'Tp Compl'.", "Validação NF-e")
						
						lRet := .F.
						
						Exit
					
					// Temporário	
					ElseIf (cAliXML)->&(_cCmp1 + "_TPCOMP") == "2"
						
						MsgInfo("Complemento de Quantidade ainda não disponível.", "Validação NF-e")
						
						lRet := .F.
						
						Exit
						
					Else
						
						RecLock(_cTab1, .F.)
							
							(_cTab1)->&(_cCmp1 + "_TIPOEN") := (cAliXML)->&(_cCmp1 + "_TIPOEN")
							(_cTab1)->&(_cCmp1 + "_TPCOMP") := (cAliXML)->&(_cCmp1 + "_TPCOMP")
							
						(_cTab1)->( MSUnlock() )
						
					EndIf
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
					
					// Valida CT-e
					
					If Empty(cTesE) .And. (_cTab1)->&(_cCmp1 + "_TIPOEN") # "F"
						
						MsgInfo("Deve ser informada uma TES de Entrada para importar CT-e's", "Validação CT-e")
						
						lRet := .F.
						
						Exit
						
					ElseIf Empty(cTesS) .And. (_cTab1)->&(_cCmp1 + "_TIPOEN") == "F"
						
						MsgInfo("Deve ser informada uma TES de Saída para importar CT-e's", "Validação CT-e")
						
						lRet := .F.
						
						Exit
						
					ElseIf Empty(cNatur)
						
						MsgInfo("Deve ser informada uma Natureza Financeira para importar CT-e's", "Validação CT-e")
						
						lRet := .F.
						
						Exit
						
					ElseIf Empty(cCond)
						
						MsgInfo("Deve ser informada uma Condição de Pagamento para importar CT-e's", "Validação CT-e")
						
						lRet := .F.
						
						Exit
						
					EndIf
					
					/*RecLock(_cTab1, .F.)
						
						(_cTab1)->&(_cCmp1 + "_OK") := cGOMark
						
					(_cTab1)->( MSUnlock() )*/
					
				ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "6"
					
					// Valida Inconsistências
					
				EndIf
				
			EndIf
			
		Else
			
			/*RecLock(_cTab1, .F.)
				
				(_cTab1)->&(_cCmp1 + "_OK") := Space(2)
				
			(_cTab1)->( MSUnlock() )*/
			
		EndIf
		
		(cAliXML)->( dbSkip() )
		
	EndDo
	
Return lRet

/* ####################################################################### *\
|| #                        VALIDA CAMPOS DA TELA                        # ||
\* ####################################################################### */
Static Function ValListCte(nCampo)

	Local lExist := .T.
	
	// VALIDA CAMPO DE TES
	If !Vazio() .And. nCampo == 1
	
		If !EXISTCPO("SF4", cTesE)
		
			lExist := .F.
			
		EndIf
		
	ElseIf !Vazio() .And. nCampo == 4
	
		If !EXISTCPO("SF4", cTesS)
		
			lExist := .F.
			
		EndIf
		
	// VALIDA CAMPO DE NATUREZA
	ElseIf !Vazio() .And. nCampo == 2
	
		If !EXISTCPO("SED", cNatur)
		
			lExist := .F.
			
		EndIf
	
	// SIMULA A CONDIÇÃO DE PAGAMENTO
	ElseIf !Vazio() .And. nCampo == 3
	
		If !EXISTCPO("SE4", cCond)
		
			lExist := .F.
		
		/*Else
		
			// SIMULA AS DUPLICATAS
			aDuplicat := Condicao(1000, cCond, 0, dDataBase)
			aParCdp   := {}
			
			If !Empty(aDuplicat)
			
				For nA := 1 To Len(aDuplicat)
				
					AAdd(aParCdp, {nA, aDuplicat[nA][1]})
				
				Next nA
				
				oBrwCdp:SetArray(aParCdp)
				oBrwCdp:Refresh()
			
			Else
			
				aParCdp := {{'', ''}}
				Aviso("Aviso", "Esta condição de pagamento não conseguiu gerar duplicatas.", {"Ok"}, 2)
				lExist := .F.
			
			EndIf*/
			
		EndIf

	ElseIf !Vazio() .And. nCampo == 5
	
		If !EXISTCPO("CTT", cCCS)
		
			lExist := .F.

		EndIf
		
	ElseIf !Vazio() .And. nCampo == 6
		
		If dCtVenc < dDataBase
			
			lExist := .F.
			
		EndIf
		
	ElseIf !Vazio() .And. nCampo == 7
		
		If !EXISTCPO("SB1", cPrdFrtSai)
		
			lExist := .F.

		EndIf
		
	EndIf
	
Return lExist

Static Function FiltraXML()
	
	Local aAreaTab := (_cTab1)->( GetArea() )
	Local aFields  := {}
	
	Private aImgChk  := {LoadBitmap(GetResources(), "LBOK"), ;
				          LoadBitmap(GetResources(), "LBNO")}
	
	Private oLayerFil
	
	Private oDlgFil
	Private oTree
	Private aFilXml := {}
	
	Private oCanc
	Private oDanfe

	Private oFormFil
	
	AAdd(aFilXml, {"1", "XML's para importar (todos)", 0, "U_GOX8FLTD"})
	
	Private aXml1    := {}
	Private oLayXml1
	Private oBrwXml1
	
	AAdd(aFilXml, {"8", "NF-e's", 0, "U_GOX8FLNF"})
	
	Private aXml8    := {}
	Private oLayXml8
	Private oBrwXml8
	
	AAdd(aFilXml, {"2", "Pré-notas", 0, "U_GOX8FLPR"})
	
	Private aXml2    := {}
	Private oLayXml2
	Private oBrwXml2

	AAdd(aFilXml, {"3", "CT-e's", 0, "U_GOX8FLCT"})
	
	Private aXml3    := {}
	Private oLayXml3
	Private oBrwXml3

	Private nQtdSel3 := 0
	Private nVlrSel3 := 0
	Private oQtdSel3
	Private oVlrSel3
	
	Private oChkCteE
	Private lChkCteE := .T.
	
	Private oChkCteS
	Private lChkCteS := .T.
	
	If SC7->( FieldPos("C7_ZSEMALM") ) > 0
		
		AAdd(aFilXml, {"4", "Sem Almoxarifado", 0, "U_GOX8FLAL"})
		
		Private aXml4    := {}
		Private oLayXml4
		Private oBrwXml4  
		
	EndIf
	
	AAdd(aFilXml, {"5", "Com erro", 0, "U_GOX8FLER"})
	
	Private aXml5    := {}
	Private oLayXml5
	Private oBrwXml5
	Private oMemo5
	Private cMemo5 := ""
	
	If (_cTab1)->( FieldPos(_cCmp1 + "_PROV") ) > 0
		
		AAdd(aFilXml, {"6", "NFS-e", 0, "U_GOX8FLSE"})
		
		Private aXml6    := {}
		Private oLayXml6
		Private oBrwXml6  
		
	EndIf
	
	AAdd(aFilXml, {"7", "Transf. Filiais", 0, "U_GOX8TRFL"})
	
	Private aXml7    := {}
	Private oLayXml7
	Private oBrwXml7  
	
	DEFINE MSDIALOG oDlgFil FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE 'Filtrar XML' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oLayerFil := FWLayer():New()
		oLayerFil:Init(oDlgFil, .T.)
			
			oLayerFil:AddLine('LIN1', 100, .F.)
				
				oLayerFil:AddCollumn('LIN1_COL1', 20, .T., 'LIN1')
					
					oLayerFil:AddWindow('LIN1_COL1', 'LIN1_COL1_WIN1', "Seleção XML's", 35, .F., .T., , 'LIN1',)
						
						oBrwFil := TCBrowse():New(50, 50, 200, 200,,,, oLayerFil:GetWinPanel('LIN1_COL1', 'LIN1_COL1_WIN1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
						oBrwFil:Align := CONTROL_ALIGN_ALLCLIENT
						oBrwFil:nClrBackFocus := GetSysColor(13)
						oBrwFil:nClrForeFocus := GetSysColor(14)
						oBrwFil:SetArray(aFilXml)
						
						//oBrwFil:lVScroll := .F.
						oBrwFil:lHScroll := .F.
						
						//ADD COLUMN TO oBrwFil HEADER "Seq."  OEM DATA {|| aFilXml[oBrwFil:nAt, 1]} ALIGN LEFT SIZE 010 PIXELS
						ADD COLUMN TO oBrwFil HEADER "Desc." OEM DATA {|| aFilXml[oBrwFil:nAt, 2]} ALIGN LEFT SIZE 050 PIXELS
						//ADD COLUMN TO oBrwFil HEADER "Qtd."  OEM DATA {|| aFilXml[oBrwFil:nAt, 3]} ALIGN LEFT SIZE 015 PIXELS PICTURE "@E 999999"
						
					oLayerFil:AddWindow('LIN1_COL1', 'LIN1_COL1_WIN2', "Filtros Adicionais", 65, .F., .T., , 'LIN1',)
						
						//------------ Criação dos campos
						
						// Documento
						aTam := TamSX3(_cCmp1 + "_DOC")
						ADD FIELD aFields TITULO "Documento" CAMPO "NOTA" TIPO "C" TAMANHO aTam[1] DECIMAL aTam[2] PICTURE "" VALID .T. NIVEL 1
						If Len(AllTrim(cChaveSeek)) == 9
							M->NOTA := PadR(cChaveSeek, aTam[1])
						Else
							M->NOTA := Space(aTam[1])
						EndIf
						
						// Fornecedor de
						aTam := TamSX3(_cCmp1 + "_CODEMI")
						ADD FIELD aFields TITULO "Forn. de" CAMPO "FORNDE" TIPO "C" TAMANHO aTam[1] DECIMAL aTam[2] PICTURE "" VALID .T. NIVEL 1 F3 "FOR"
						M->FORNDE := Space(aTam[1])
						
						// Fornecedor até
						aTam := TamSX3(_cCmp1 + "_CODEMI")
						ADD FIELD aFields TITULO "Forn. até" CAMPO "FORNATE" TIPO "C" TAMANHO aTam[1] DECIMAL aTam[2] PICTURE "" VALID .T. NIVEL 1 F3 "FOR"
						M->FORNATE := Space(aTam[1])
						
						// Data de Emissão de
						aTam := TamSX3(_cCmp1 + "_DTEMIS")
						ADD FIELD aFields TITULO "Dt. Emis. de" CAMPO "DTDE" TIPO "D" TAMANHO aTam[1] DECIMAL aTam[2] PICTURE "" VALID .T. NIVEL 1
						M->DTDE := MonthSub(dDataBase, 2)
						
						// Data de Emissão até
						aTam := TamSX3(_cCmp1 + "_DTEMIS")
						ADD FIELD aFields TITULO "Dt. Emis. até" CAMPO "DTATE" TIPO "D" TAMANHO aTam[1] DECIMAL aTam[2] PICTURE "" VALID .T. NIVEL 1
						M->DTATE := dDataBase
						
						oFormFil := MsMGet():New(,, 4,,,,, {0,0,0,0},,,,,, oLayerFil:GetWinPanel('LIN1_COL1', 'LIN1_COL1_WIN2', 'LIN1'),,.T.,,,,.T., aFields,,.T.,,,.T.)
						
						oFormFil:oBox:Align := CONTROL_ALIGN_ALLCLIENT
						oFormFil:oBox:lFocusOnFirst := .T.
						
				oLayerFil:AddCollumn('LIN1_COL2', 80, .T., 'LIN1')
					
					// Caso seja necessário criar um grid mostrando os XML's selecionados
					//oLayerFil:AddWindow('LIN1_COL2', 'LIN1_COL2_WIN1', "Filtros Adicionais", 25, .F., .T., , 'LIN1',)
					
					oLayerFil:AddWindow('LIN1_COL2', 'LIN1_COL2_WIN1', "XML's Encontrados com as seleções", 85, .F., .T., , 'LIN1',)
						
						// Apenas depois para não gerar erro de janela não criada ainda
						
						
						//oBrwFil:GoTop()
						
					oLayerFil:AddWindow('LIN1_COL2', 'LIN1_COL2_WIN2', "Ações", 15, .F., .T., , 'LIN1',)
						
						oConf := THButton():New(0, 0, "&Confirmar", oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN2', 'LIN1'), {|| IIf(ConfSelXml(), oDlgFil:End(), )}, , , )
						oConf:nWidth  := 80
						oConf:nHeight := 10
						oConf:Align   := CONTROL_ALIGN_RIGHT
						oConf:SetColor(RGB(002, 070, 112), )
						
						oAtu := THButton():New(0, 0, "&Atualizar", oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN2', 'LIN1'), {|| AtuFilXml()}, , , )
						oAtu:nWidth  := 80
						oAtu:nHeight := 10
						oAtu:Align   := CONTROL_ALIGN_RIGHT
						oAtu:SetColor(RGB(002, 070, 112), )

						oDanfe := THButton():New(0, 0, "&Imp. DANFE", oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN2', 'LIN1'), {|| ImpDanfSel()}, , , )
						oDanfe:nWidth  := 80
						oDanfe:nHeight := 10
						oDanfe:Align   := CONTROL_ALIGN_RIGHT
						oDanfe:SetColor(RGB(002, 070, 112), )

						oCanc := THButton():New(0, 0, "Cancelar &NFS", oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN2', 'LIN1'), {|| IIf(ExcFilXml(), AtuFilXml(), )}, , , )
						oCanc:nWidth  := 80
						oCanc:nHeight := 10
						oCanc:Align   := CONTROL_ALIGN_RIGHT
						oCanc:SetColor(RGB(002, 070, 112), )

	ACTIVATE MSDIALOG oDlgFil CENTERED ON INIT (oBrwFil:bChange := {|| FwMsgRun(, &("{|| " + aFilXml[oBrwFil:nAt, 4] + "()}"), "Filtrando XML's", "Aguarde por favor.")}, oBrwFil:GoTop())
	
	RestArea(aAreaTab)
	
Return

Static Function ExcFilXml()

	Local nI
	Local nX
	Local aXml := {}
	Local aAreaTab := (_cTab1)->( GetArea() )
	Local lExc := .T.

	For nI := 1 To Len(aFilXml)
		
		If aFilXml[nI][1] == "6" //aFilXml[nI][1] # "5" // Comentado, caso queira deixar para a tela de todos os XML's
			
			aAux := AClone(&("aXml" + aFilXml[nI][1]))
			
			For nX := 1 To Len(aAux)
				
				If aAux[nX][1] == 1 .And. AScan(aXml, {|x| x == ATail(aAux[nX])}) == 0
					
					AAdd(aXml, ATail(aAux[nX]))
					
				EndIf
				
			Next nX
			
		EndIf
		
	Next nI

	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )

	For nI := 1 To Len(aXml)

		If !(_cTab1)->( dbSeek(aXml[nI] + "6") )

			Alert("O cancelamento é permitido apenas para notas fiscais de serviço, visto que esse tipo de nota não possui verificação de cancelamento automática.")

			lExc := .F.

			Exit

		EndIf

	Next nI

	If Empty(aXml)

		Alert("É necessário selecionar ao menos 1 XML de nota de serviço para cancelar.")

		lExc := .F.
		
	EndIf
	
	If lExc

		For nI := 1 To Len(aXml)

			If (_cTab1)->( dbSeek(aXml[nI] + "6") )

				RecLock(_cTab1)

					(_cTab1)->&(_cCmp1 + "_SIT") := "5"

					(_cTab1)->&(_cCmp1 + "_SIT") := "5"
					(_cTab1)->&(_cCmp1 + "_USUIMP") := cUserName
					(_cTab1)->&(_cCmp1 + "_HRIMP") := Time()
					(_cTab1)->&(_cCmp1 + "_DTIMP") := Date()


				(_cTab1)->( MSUnlock() )

			EndIf

		Next nI

	EndIf

	RestArea(aAreaTab)

Return lExc

Static Function LiberarXML()
	
	Local nXml := 0
	Local nSImp := AScan(aFieldStr, {|x| x == _cCmp1 + "_SIMP"})
	
	While !(cAliXML)->( Eof() )
		
		If !(cAliXML)->&(_cCmp1 + "_FLAG")
			
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek((cAliXML)->&(_cCmp1 + "_CHAVE") + (cAliXML)->&(_cCmp1 + "_TIPO")) )
				
				If (_cTab1)->&(_cCmp1 + "_LIBER") # '1'
					
					nXml++
					
					oBrwXML:_FieldPut(nSImp, "BR_PRETO", aFieldStr[nSImp])
					
					RecLock(_cTab1)
						
						(_cTab1)->&(_cCmp1 + "_LIBER") := "1"
						(_cTab1)->&(_cCmp1 + "_ERRO")  := ""
						
					(_cTab1)->( MSUnlock() )
					
				EndIf
				
			EndIf
			
		EndIf
		
		(cAliXML)->( dbSkip() )
		
	EndDo
	
	If nXml == 0
		
		MsgAlert("Nenhum XML para liberar!")
		
	Else
		
		MsgInfo("Foram liberados " + cValToChar(nXml) + " Xml's.")
		
	EndIf
	
	oBrwXML:_dbGoTop()
	oBrwXML:ForceRefresh()
	
Return

Static Function VerXml()
	
	Alert("Em desenvolvimento...")
	
Return

Static Function NfPreNota(lAtu)
	
	Local aAreaSF1 := SF1->( GetArea() )
	Local lPreNota := .F.
	
	Default lAtu := .F.
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(8) )
	If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_CHAVE")) )
		
		lPreNota := Empty(SF1->F1_STATUS)
		
	EndIf
	
	If lPreNota .And. lAtu .And. ((_cTab1)->&(_cCmp1 + "_SIT") # "2" .Or. (_cTab1)->&(_cCmp1 + "_LIBALM") # "1") 
		
		RecLock(_cTab1)
			
			(_cTab1)->&(_cCmp1 + "_SIT") := "2"
			(_cTab1)->&(_cCmp1 + "_LIBALM") := "1"
			
		(_cTab1)->( MSUnlock() )
		
	EndIf
	
	RestArea(aAreaSF1)
	
Return lPreNota

Static Function XmlF1Info(cCampo)
	
	Local aAreaSF1 := SF1->( GetArea() )
	Local xRet := CriaVar(cCampo, .F.)
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(8) )
	If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_CHAVE")) )
		
		xRet := SF1->&(cCampo)
		
	EndIf
	
	RestArea(aAreaSF1)
	
Return xRet

User Function GOX8FLTD(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"OK", "DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL", _cCmp1 + "_CHAVE"}
	Local nI
	Local bAux
	Local aMdf
	
	Default lRefresh := .F.
	
	If Type("oCanc") == "O"

		oCanc:Hide()

	EndIf
	
	If Type("oDanfe") == "O"
		
		oDanfe:Show()
		
	EndIf

	If ValType(oLayXml1) # "O" .Or. lRefresh
	    
	    If ValType(oLayXml1) # "O"
			/////////////////// Layer
			oLayXml1 := FWLayer():New()
			oLayXml1:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml1:AddLine('LIN1', 100, .F.)
					
			oLayXml1:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')		
			//////////////////////////
		Else
			
			aXml1 := {}
			
			oLayXml1:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml1 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml1:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml1:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml1:nClrBackFocus := GetSysColor(13)
		oBrwXml1:nClrForeFocus := GetSysColor(14)
		oBrwXml1:lHScroll := .F.
		
		oBrwXml1:bLDblClick := {|| MarcRegFil(1)}
		oBrwXml1:bHeaderClick := {|o, n| IIf(n == 1, MarcTd(), SortColumn(n))}
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " TAB "
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' AND TAB." + _cCmp1 + "_TIPO IN ('1', '2', '6') "
		cQuery += " AND (TAB." + _cCmp1 + "_SIT IN ('1', '3') OR (TAB." + _cCmp1 + "_SIT = '2' AND " + _cCmp1 + "_LIBALM = '1')) "
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "OK"
					
				oBrwXml1:AddColumn(TCColumn():New("", {|| aImgChk[aXml1[oBrwXml1:nAt, 1]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
				
			ElseIf aCampos[nI] == "DESC"
					
				bAux := &("{|| aXml1[oBrwXml1:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml1 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml1[oBrwXml1:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml1 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml1 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI

		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				If (cAli)->&(_cCmp1 + "_TIPO") == "1"
					
					// Ignora casos que a manifestação é desconhecimento ou operação não realizada
					If GetNewPar("MV_ZCNSMND", .F.)
						aMdf := U_GOX11GMD((cAli)->&(_cCmp1 + "_CHAVE"))
					Else
						aMdf := {.F., ""}
					EndIf
					
					If aMdf[1] .And. aMdf[2] $ "3,4"
						
						(cAli)->( dbSkip() )
						
						Loop
						
					EndIf
					
				EndIf
				
				AAdd(aXml1, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "OK"
						
						AAdd(ATail(aXml1), 2)
						
					ElseIf aCampos[nI] == "DESC"
						
						If (cAli)->&(_cCmp1 + "_TIPO") == "1" .And. (cAli)->&(_cCmp1 + "_SIT") == "2" .And. (cAli)->&(_cCmp1 + "_LIBALM") == "1"
							
							AAdd(ATail(aXml1), "Pré-nota")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "1"
							
							AAdd(ATail(aXml1), "NF-e")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "6"
							
							AAdd(ATail(aXml1), "NFS-e (Serviço)")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "2"
							
							If (cAli)->&(_cCmp1 + "_TIPOEN") == "F"
								AAdd(ATail(aXml1), "CT-e (Saída)")
							Else
								AAdd(ATail(aXml1), "CT-e (Entrada)")
							EndIf
							
						EndIf
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml1), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml1), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml1 := {AFill(Array(Len(aCampos)), "")}
			
			aXml1[1][1] := 2
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml1:SetArray(aXml1)
		
		oBrwXml1:GoTop()

		SetDefHead(.t.)
		
	EndIf
	
	BrwActive("1")
	
Return

User Function GOX8FLNF(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"OK", "DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL", _cCmp1 + "_CHAVE"}
	Local nI
	Local bAux
	Local aMdf
	
	Default lRefresh := .F.
	
	If GetNewPar("MV_ZSUGPED", .F.)
		
		ASize(aCampos, Len(aCampos) + 1)
		AIns(aCampos, 10)
		
		aCampos[10] := "SUGPED"
		
	EndIf
	
	If (_cTab8)->( FieldPos(_cCmp8 + "_DTVENC") ) > 0
		
		ASize(aCampos, Len(aCampos) + 1)
		AIns(aCampos, 11)
		
		aCampos[11] := "DTVENC"
		
	EndIf
	
	If Type("oCanc") == "O"

		oCanc:Hide()

	EndIf
	
	If Type("oDanfe") == "O"
		
		oDanfe:Show()
		
	EndIf

	If ValType(oLayXml8) # "O" .Or. lRefresh
	    
	    If ValType(oLayXml8) # "O"
			/////////////////// Layer
			oLayXml8 := FWLayer():New()
			oLayXml8:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml8:AddLine('LIN1', 100, .F.)
					
			oLayXml8:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')		
			//////////////////////////
		Else
			
			aXml8 := {}
			
			oLayXml8:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml8 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml8:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml8:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml8:nClrBackFocus := GetSysColor(13)
		oBrwXml8:nClrForeFocus := GetSysColor(14)
		oBrwXml8:lHScroll := .F.
		
		oBrwXml8:bLDblClick := {|| MarcRegFil(8)}
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " TAB "
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' AND TAB." + _cCmp1 + "_TIPO = '1' "
		cQuery += " AND TAB." + _cCmp1 + "_SIT IN ('1', '3') "
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "OK"
					
				oBrwXml8:AddColumn(TCColumn():New("", {|| aImgChk[aXml8[oBrwXml8:nAt, 1]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
				
			ElseIf aCampos[nI] == "DESC"
					
				bAux := &("{|| aXml8[oBrwXml8:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml8 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "SUGPED"
					
				bAux := &("{|| aXml8[oBrwXml8:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml8 HEADER "Ped. Sug." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "DTVENC"
					
				bAux := &("{|| aXml8[oBrwXml8:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml8 HEADER "Dt Vencs" OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml8[oBrwXml8:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml8 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml8 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				If (cAli)->&(_cCmp1 + "_TIPO") == "1"
					
					// Ignora casos que a manifestação é desconhecimento ou operação não realizada
					If GetNewPar("MV_ZCNSMND", .F.)
						aMdf := U_GOX11GMD((cAli)->&(_cCmp1 + "_CHAVE"))
					Else
						aMdf := {.F., ""}
					EndIf
					
					If aMdf[1] .And. aMdf[2] $ "3,4"
						
						(cAli)->( dbSkip() )
						
						Loop
						
					EndIf
					
				EndIf
				
				AAdd(aXml8, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "OK"
						
						AAdd(ATail(aXml8), 2)
						
					ElseIf aCampos[nI] == "DESC"
						
						AAdd(ATail(aXml8), "NF-e")
						
					ElseIf aCampos[nI] == "SUGPED"
						
						AAdd(ATail(aXml8), GetSugPed((cAli)->&(_cCmp1 + "_CHAVE")))
						
					ElseIf aCampos[nI] == "DTVENC"
						
						AAdd(ATail(aXml8), GetDtVenc((cAli)->&(_cCmp1 + "_CHAVE")))
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml8), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml8), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml8 := {AFill(Array(Len(aCampos)), "")}
			
			aXml8[1][1] := 2
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml8:SetArray(aXml8)
		
		oBrwXml8:GoTop()
		
	EndIf
	
	BrwActive("8")
	
Return

User Function GOX8FLPR(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"OK", "DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL"}
	Local nI
	Local bAux
	Local aMdf
	
	Default lRefresh := .F.
	
	If GetNewPar("MV_ZSUGPED", .F.)
		
		ASize(aCampos, Len(aCampos) + 1)
		
		aCampos[10] := "SUGPED"
		
	EndIf
	
	If (_cTab8)->( FieldPos(_cCmp8 + "_DTVENC") ) > 0
		
		ASize(aCampos, Len(aCampos) + 1)
		AIns(aCampos, 11)
		
		aCampos[11] := "DTVENC"
		
	EndIf
	
	// Processo para acrescentar uma coluna de conferido

	If ExistBlock("GOX8PRCF")

		AAdd(aCampos, "CONF")

	EndIf

	AAdd(aCampos, _cCmp1 + "_CHAVE")
	
	oCanc:Hide()
	oDanfe:Show()

	If ValType(oLayXml2) # "O" .Or. lRefresh
		
		If ValType(oLayXml2) # "O"
			/////////////////// Layer
			oLayXml2 := FWLayer():New()
			oLayXml2:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml2:AddLine('LIN1', 100, .F.)
					
			oLayXml2:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')		
			//////////////////////////
		Else
			
			aXml2 := {}
			
			oLayXml2:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml2 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml2:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml2:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml2:nClrBackFocus := GetSysColor(13)
		oBrwXml2:nClrForeFocus := GetSysColor(14)
		oBrwXml2:lHScroll := .F.
		
		oBrwXml2:bLDblClick := {|| MarcRegFil(2)}
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " TAB "
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
		cQuery += " AND TAB." + _cCmp1 + "_SIT = '2' AND TAB." + _cCmp1 + "_TIPO = '1' AND " + _cCmp1 + "_LIBALM = '1' "
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "OK"
					
				oBrwXml2:AddColumn(TCColumn():New("", {|| aImgChk[aXml2[oBrwXml2:nAt, 1]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
				
			ElseIf aCampos[nI] == "DESC"
					
				bAux := &("{|| aXml2[oBrwXml2:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml2 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "SUGPED"
					
				bAux := &("{|| aXml2[oBrwXml2:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml2 HEADER "Ped. Sug." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "DTVENC"
					
				bAux := &("{|| aXml2[oBrwXml2:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml2 HEADER "Dt Vencs" OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS

			ElseIf aCampos[nI] == "CONF"
				
				bAux := &("{|| aXml2[oBrwXml2:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml2 HEADER "Conferido?" OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS

			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml2[oBrwXml2:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml2 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml2 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				// Ignora casos que a manifestação é desconhecimento ou operação não realizada
				aMdf := U_GOX11GMD((cAli)->&(_cCmp1 + "_CHAVE"))
				
				If aMdf[1] .And. aMdf[2] $ "3,4"
					
					(cAli)->( dbSkip() )
					
					Loop
					
				EndIf
				
				AAdd(aXml2, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "OK"
						
						AAdd(ATail(aXml2), 2)
						
					ElseIf aCampos[nI] == "DESC"
						
						AAdd(ATail(aXml2), "Pré-nota")
						
					ElseIf aCampos[nI] == "SUGPED"
						
						AAdd(ATail(aXml2), GetSugPed((cAli)->&(_cCmp1 + "_CHAVE")))
						
					ElseIf aCampos[nI] == "DTVENC"
						
						AAdd(ATail(aXml2), GetDtVenc((cAli)->&(_cCmp1 + "_CHAVE")))

					ElseIf aCampos[nI] == "CONF"
						
						AAdd(ATail(aXml2), ExecBlock("GOX8PRCF", .F., .F., {cAli}))
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml2), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml2), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml2 := {AFill(Array(Len(aCampos)), "")}
			
			aXml2[1][1] := 2
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml2:SetArray(aXml2)
		
		oBrwXml2:GoTop()
		
	EndIf
	
	BrwActive("2")
	
Return

User Function GOX8FLCT(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"OK", "DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL", _cCmp1 + "_CHAVE"}
	Local nI
	Local bAux
	Local aMdf

	Default lRefresh := .F.

	oCanc:Hide()
	oDanfe:Hide()

	If ValType(oLayXml3) # "O" .Or. lRefresh
		
		nQtdSel3 := 0
		nVlrSel3 := 0

		If ValType(oLayXml3) # "O"
			/////////////////// Layer
			oLayXml3 := FWLayer():New()
			oLayXml3:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml3:AddLine('LIN1', 90, .F.)
					
				oLayXml3:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')

			////////////////////////// Totais selecionados dos CT-e's

			oLayXml3:AddLine('LIN2', 10, .F.)
					
				oLayXml3:AddCollumn('LIN2_COL1', 100, .T., 'LIN2')

					oQtdSel3 := TGet():New(002, 002, {|u| IF(Pcount() > 0, nQtdSel3 := u, nQtdSel3)}, oLayXml3:GetColPanel('LIN2_COL1', 'LIN2'), 060, 010, PesqPict("SD1", "D1_QUANT"), , , , , , , .T., , , {|| .F.}, , , , , , , "nQtdSel3", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Qtd Sel", 2, , )

					oVlrSel3 := TGet():New(002, 80, {|u| IF(Pcount() > 0, nVlrSel3 := u, nVlrSel3)}, oLayXml3:GetColPanel('LIN2_COL1', 'LIN2'), 060, 010, PesqPict("SD1", "D1_TOTAL"), , , , , , , .T., , , {|| .F.}, , , , , , , "nVlrSel3", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Vlr Sel", 2, , )
					
					oChkCteE := TCheckBox():New(004, 160, 'CT-e Entrada', , oLayXml3:GetColPanel('LIN2_COL1', 'LIN2'), 70, 80, , , , , , , , .T., , , )
					oChkCteE:cToolTip  := "Filtra Apenas CT-e de Entrada"
					oChkCteE:bSetGet   := {|| lChkCteE}
					oChkCteE:bLClicked := {|| IIf(!lChkCteS .And. lChkCteE, .T., (lChkCteE := !lChkCteE))/*, AtuFilXml()*/}
					
					oChkCteS := TCheckBox():New(004, 220, 'CT-e Saída', , oLayXml3:GetColPanel('LIN2_COL1', 'LIN2'), 70, 80, , , , , , , , .T., , , )
					oChkCteS:cToolTip  := "Filtra Apenas CT-e de Saída"
					oChkCteS:bSetGet   := {|| lChkCteS}
					oChkCteS:bLClicked := {|| IIf(!lChkCteE .And. lChkCteS, .T., (lChkCteS := !lChkCteS))/*, AtuFilXml()*/}

		Else
		
			aXml3 := {}
			
			oLayXml3:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml3 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml3:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml3:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml3:nClrBackFocus := GetSysColor(13)
		oBrwXml3:nClrForeFocus := GetSysColor(14)
		oBrwXml3:lHScroll := .F.
		
		oBrwXml3:bLDblClick := {|| MarcRegFil(3)}
		
		oBrwXml3:bHeaderClick := {|oObj, nCol| MarkAll(3, nCol, oObj)}
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " TAB "
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
		cQuery += " AND TAB." + _cCmp1 + "_SIT IN ('1', '3') AND TAB." + _cCmp1 + "_TIPO = '2' "
		
		If lChkCteS .And. !lChkCteE
			
			cQuery += " AND TAB." + _cCmp1 + "_TIPOEN = 'F' "
			
		ElseIf !lChkCteS .And. lChkCteE
			
			cQuery += " AND TAB." + _cCmp1 + "_TIPOEN <> 'F' "
			
		EndIf
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "OK"
					
				oBrwXml3:AddColumn(TCColumn():New("", {|| aImgChk[aXml3[oBrwXml3:nAt, 1]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
				
			ElseIf aCampos[nI] == "DESC"
					
				bAux := &("{|| aXml3[oBrwXml3:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml3 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml3[oBrwXml3:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml3 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml3 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				// Verificar futuramente se precisa para a prestação em desacordo
				/*aMdf := U_GOX11GMD((cAli)->&(_cCmp1 + "_CHAVE"))
				
				If aMdf[1] .And. aMdf[2] $ "3,4"
					
					(cAli)->( dbSkip() )
					
					Loop
					
				EndIf*/
				
				AAdd(aXml3, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "OK"
						
						AAdd(ATail(aXml3), 2)
						
					ElseIf aCampos[nI] == "DESC"
						
						If (cAli)->&(_cCmp1 + "_TIPOEN") == "F"
							AAdd(ATail(aXml3), "CT-e (Saída)")
						Else
							AAdd(ATail(aXml3), "CT-e (Entrada)")
						EndIf
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml3), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml3), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml3 := {AFill(Array(Len(aCampos)), "")}
			
			aXml3[1][1] := 2
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml3:SetArray(aXml3)
		
		oBrwXml3:GoTop()
		
	EndIf
	
	BrwActive("3")
	
Return

User Function GOX8FLAL(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"OK", "DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL", _cCmp1 + "_CHAVE"}
	Local nPosChv := AScan(aCampos, {|x| x == _cCmp1 + "_CHAVE"})
	Local nI
	Local bAux
	Local aMdf
	
	Default lRefresh := .F.
	
	If GetNewPar("MV_ZSUGPED", .F.)
		
		ASize(aCampos, Len(aCampos) + 1)
		AIns(aCampos, 10)
		
		aCampos[10] := "SUGPED"
		
	EndIf
	
	If (_cTab8)->( FieldPos(_cCmp8 + "_DTVENC") ) > 0
		
		ASize(aCampos, Len(aCampos) + 1)
		AIns(aCampos, 11)
		
		aCampos[11] := "DTVENC"
		
	EndIf
	
	oCanc:Hide()
	oDanfe:Show()

	If ValType(oLayXml4) # "O" .Or. lRefresh
	    
	    If ValType(oLayXml4) # "O"
			/////////////////// Layer
			oLayXml4 := FWLayer():New()
			oLayXml4:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml4:AddLine('LIN1', 100, .F.)
					
				oLayXml4:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')
			//////////////////////////
		Else
			
			aXml4 := {}
			
			oLayXml4:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml4 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml4:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml4:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml4:nClrBackFocus := GetSysColor(13)
		oBrwXml4:nClrForeFocus := GetSysColor(14)
		oBrwXml4:lHScroll := .F.
		
		oBrwXml4:bLDblClick := {|| MarcRegFil(4)}
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " TAB "
		
		// 
		cQuery += " INNER JOIN " + RetSqlName("SC7") + " SC7 ON SC7.C7_FORNECE = TAB." + _cCmp1 + "_CODEMI AND SC7.C7_LOJA = TAB." + _cCmp1 + "_LOJEMI "
		cQuery += " AND SC7.C7_ZSEMALM = 'T' AND SC7.D_E_L_E_T_ = ' ' AND SC7.C7_RESIDUO = ' ' AND SC7.C7_TPOP <> 'P' AND SC7.C7_CONAPRO <> 'B' AND SC7.C7_ITEM = '0001' "
		//
		
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
		cQuery += " AND TAB." + _cCmp1 + "_TIPO = '1' AND TAB." + _cCmp1 + "_SIT IN ('1', '3') "
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		cQuery += " AND (SC7.C7_QUANT - SC7.C7_QUJE - SC7.C7_QTDACLA) > 0 "
		
		/*cQuery += " AND EXISTS ( "
		
		cQuery += " SELECT SUM(SC7.C7_TOTAL) FROM " + RetSqlName("SC7") + " SC7 "
		cQuery += " WHERE SC7.C7_ZSEMALM = 'T' AND D_E_L_E_T_ = ' ' AND (SC7.C7_QUANT - SC7.C7_QUJE - SC7.C7_QTDACLA) > 0 "
		cQuery += " AND SC7.C7_RESIDUO = ' ' AND SC7.C7_TPOP <> 'P' AND SC7.C7_CONAPRO <> 'B' "
		cQuery += " AND SC7.C7_FORNECE = TAB." + _cCmp1 + "_CODEMI AND SC7.C7_LOJA = TAB." + _cCmp1 + "_LOJEMI "
		
		cQuery += " ) "*/
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "OK"
					
				oBrwXml4:AddColumn(TCColumn():New("", {|| aImgChk[aXml4[oBrwXml4:nAt, 1]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
				
			ElseIf aCampos[nI] == "DESC"
				
				bAux := &("{|| aXml4[oBrwXml4:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml4 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "SUGPED"
					
				bAux := &("{|| aXml4[oBrwXml4:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml4 HEADER "Ped. Sug." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "DTVENC"
					
				bAux := &("{|| aXml4[oBrwXml4:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml4 HEADER "Dt Vencs" OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml4[oBrwXml4:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml4 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml4 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				// TODO - Deverá filtrar para não trazer notas que não correspondem aos itens dos pedidos.
				// Pensando em filtrar utilizando o q ? código do produto pode ser que não tenha ainda, valor total do item? pode ser que não feche...
				// O mais certo seria pelo código do produto, e quando chegar o momento que estiver bem amarrado, irá funcionar na maioria dos casos....
				
				If AScan(aXml4, {|x| x[nPosChv] == (cAli)->&(_cCmp1 + "_CHAVE")}) > 0
					
					(cAli)->( dbSkip() )
					
					Loop
					
				Else
					
					// Verifica por produto ou por valor unitário ou por total
					
					If !VldProdXml(cAli)
						
						(cAli)->( dbSkip() )
						
						Loop
						
					EndIf
					
				EndIf
				
				// Ignora casos que a manifestação é desconhecimento ou operação não realizada
				aMdf := U_GOX11GMD((cAli)->&(_cCmp1 + "_CHAVE"))
				
				If aMdf[1] .And. aMdf[2] $ "3,4"
					
					(cAli)->( dbSkip() )
					
					Loop
					
				EndIf
				
				AAdd(aXml4, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "OK"
						
						AAdd(ATail(aXml4), 2)
						
					ElseIf aCampos[nI] == "DESC"
						
						If (cAli)->&(_cCmp1 + "_TIPO") == "1" .And. (cAli)->&(_cCmp1 + "_SIT") == "2" .And. (cAli)->&(_cCmp1 + "_LIBALM") == "1"
							
							AAdd(ATail(aXml4), "Pré-nota")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "1"
							
							AAdd(ATail(aXml4), "NF-e")
							
						Else
							
							If (cAli)->&(_cCmp1 + "_TIPOEN") == "F"
								AAdd(ATail(aXml4), "CT-e (Saída)")
							Else
								AAdd(ATail(aXml4), "CT-e (Entrada)")
							EndIf
							
						EndIf
						
					ElseIf aCampos[nI] == "SUGPED"
						
						AAdd(ATail(aXml4), GetSugPed((cAli)->&(_cCmp1 + "_CHAVE")))
						
					ElseIf aCampos[nI] == "DTVENC"
						
						AAdd(ATail(aXml4), GetDtVenc((cAli)->&(_cCmp1 + "_CHAVE")))
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml4), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml4), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml4 := {AFill(Array(Len(aCampos)), "")}
			
			aXml4[1][1] := 2
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml4:SetArray(aXml4)
		
		oBrwXml4:GoTop()
		
	EndIf
	
	BrwActive("4")
	
Return

User Function GOX8FLER(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL", _cCmp1 + "_CHAVE"/*, _cCmp1 + "_ERRO"*/}
	Local nI
	Local bAux
	Local aMdf
	
	Default lRefresh := .F.
	
	oCanc:Hide()
	oDanfe:Hide()

	If ValType(oLayXml5) # "O" .Or. lRefresh
		
		If ValType(oLayXml5) # "O"
			/////////////////// Layer
			oLayXml5 := FWLayer():New()
			oLayXml5:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml5:AddLine('LIN1', 85, .F.)
					
				oLayXml5:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')
			
			oLayXml5:AddLine('LIN2', 15, .F.)
				
				oLayXml5:AddCollumn('LIN2_COL1', 100, .T., 'LIN2')
					
			//////////////////////////
		Else
			
			aXml5 := {}
			
			oLayXml5:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml5 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml5:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml5:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml5:nClrBackFocus := GetSysColor(13)
		oBrwXml5:nClrForeFocus := GetSysColor(14)
		oBrwXml5:lHScroll := .F.
		
		//[TODO] Colocar para mostrar o erro num MultiGet
		oBrwXml5:bChange := {|| (_cTab1)->( dbGoTo(ATail(aXml5[oBrwXml5:nAt])) ), cMemo5 := (_cTab1)->&(_cCmp1 + "_ERRO"), oMemo5:Refresh()}
		
		oMemo5 := tMultiget():New(10, 10, {|u| If(Pcount() > 0, cMemo5 := u, cMemo5)}, ;
					oLayXml5:GetColPanel('LIN2_COL1', 'LIN2'), ;
					100, 100, , , , , , .T., , , , , , .T., , , , .F.)
		oMemo5:Align := CONTROL_ALIGN_ALLCLIENT
		oMemo5:EnableVScroll(.T.)
		oMemo5:EnableHScroll(.F.)
		oMemo5:lWordWrap := .T.
		oMemo5:Refresh()
		
		cQuery := " SELECT TAB.*, TAB.R_E_C_N_O_ RECNO FROM " + RetSqlName(_cTab1) + " TAB "
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
		cQuery += " AND TAB." + _cCmp1 + "_TIPO IN ('1', '2', '3', '5', '6') AND TAB." + _cCmp1 + "_SIT IN ('6', '7') "
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "DESC"
					
				bAux := &("{|| aXml5[oBrwXml5:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml5 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml5[oBrwXml5:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml5 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "M"
					
					ADD COLUMN TO oBrwXml5 HEADER AllTrim(X3Titulo()) OEM DATA {|| "Clique 2x"} ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml5 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				If (cAli)->&(_cCmp1 + "_TIPO") == "1"
					
					// Ignora casos que a manifestação é desconhecimento ou operação não realizada
					aMdf := U_GOX11GMD((cAli)->&(_cCmp1 + "_CHAVE"))
					
					If aMdf[1] .And. aMdf[2] $ "3,4"
						
						(cAli)->( dbSkip() )
						
						Loop
						
					EndIf
					
				EndIf
				
				AAdd(aXml5, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "DESC"
						
						If (cAli)->&(_cCmp1 + "_TIPO") == "1"
							
							AAdd(ATail(aXml5), "NF-e")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "2"
							
							AAdd(ATail(aXml5), "CT-e")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "3"
							
							AAdd(ATail(aXml5), "Erro de Estrutura")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "5"
							
							AAdd(ATail(aXml5), "Cancelamento")
							
						ElseIf (cAli)->&(_cCmp1 + "_TIPO") == "6"
							
							AAdd(ATail(aXml5), "NFS-e (Serviço)")
							
						EndIf
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml5), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml5), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				AAdd(ATail(aXml5), (cAli)->RECNO)
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml5 := {AFill(Array(Len(aCampos) + 1), "")}
			
			ATail(aXml5[1]) := 0
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml5:SetArray(aXml5)
		
		oBrwXml5:GoTop()
		
	EndIf
	
	BrwActive("5")
	
Return

// Notas de Transferência

User Function GOX8TRFL(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"OK", "DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL", _cCmp1 + "_CHAVE"}
	Local nI
	Local bAux
	
	Default lRefresh := .F.
	
	oCanc:Hide()
	oDanfe:Show()
	
	If ValType(oLayXml7) # "O" .Or. lRefresh
	    
	    If ValType(oLayXml7) # "O"
			
			/////////////////// Layer
			oLayXml7 := FWLayer():New()
			oLayXml7:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml7:AddLine('LIN1', 100, .F.)
					
			oLayXml7:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')		
			//////////////////////////
			
		Else
			
			aXml7 := {}
			
			oLayXml7:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml7 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml7:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml7:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml7:nClrBackFocus := GetSysColor(13)
		oBrwXml7:nClrForeFocus := GetSysColor(14)
		oBrwXml7:lHScroll := .F.
		
		oBrwXml7:bLDblClick := {|| MarcRegFil(7)}
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " TAB "
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' AND TAB." + _cCmp1 + "_TIPO = '1' "
		cQuery += " AND TAB." + _cCmp1 + "_SIT IN ('1', '3') "
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		cQuery += " AND TAB." + _cCmp1 + "_CGCEMI IN (" + CGCAllFil() + ") "
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "OK"
					
				oBrwXml7:AddColumn(TCColumn():New("", {|| aImgChk[aXml7[oBrwXml7:nAt, 1]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
				
			ElseIf aCampos[nI] == "DESC"
					
				bAux := &("{|| aXml7[oBrwXml7:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml7 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml7[oBrwXml7:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml7 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml7 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				AAdd(aXml7, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "OK"
						
						AAdd(ATail(aXml7), 2)
						
					ElseIf aCampos[nI] == "DESC"
						
						AAdd(ATail(aXml7), "NF-e")
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml7), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml7), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml7 := {AFill(Array(Len(aCampos)), "")}
			
			aXml7[1][1] := 2
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml7:SetArray(aXml7)
		
		oBrwXml7:GoTop()
		
	EndIf
	
	BrwActive("7")
	
Return

// Notas Fiscais de Serviço

User Function GOX8FLSE(lRefresh)
	
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local aCampos := {"OK", "DESC", _cCmp1 + "_DTEMIS", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_CODEMI", _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_TOTVAL", _cCmp1 + "_CHAVE"}
	Local nI
	Local bAux
	
	Default lRefresh := .F.
	
	If GetNewPar("MV_ZSUGPED", .F.)
		
		ASize(aCampos, Len(aCampos) + 1)
		AIns(aCampos, 10)
		
		aCampos[10] := "SUGPED"
		
	EndIf
	
	If (_cTab8)->( FieldPos(_cCmp8 + "_DTVENC") ) > 0
		
		ASize(aCampos, Len(aCampos) + 1)
		AIns(aCampos, 11)
		
		aCampos[11] := "DTVENC"
		
	EndIf
	
	oCanc:Show()
	oDanfe:Hide()

	If ValType(oLayXml6) # "O" .Or. lRefresh
	    
	    If ValType(oLayXml6) # "O"
			/////////////////// Layer
			oLayXml6 := FWLayer():New()
			oLayXml6:Init(oLayerFil:GetWinPanel('LIN1_COL2', 'LIN1_COL2_WIN1', 'LIN1'), .T.)
				
			oLayXml6:AddLine('LIN1', 100, .F.)
					
			oLayXml6:AddCollumn('LIN1_COL1', 100, .T., 'LIN1')		
			//////////////////////////
		Else
			
			aXml6 := {}
			
			oLayXml6:GetColPanel('LIN1_COL1', 'LIN1'):FreeChildren()
			
		EndIf
		
		oBrwXml6 := TCBrowse():New(50, 50, 200, 200,,,, oLayXml6:GetColPanel('LIN1_COL1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
		oBrwXml6:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwXml6:nClrBackFocus := GetSysColor(13)
		oBrwXml6:nClrForeFocus := GetSysColor(14)
		oBrwXml6:lHScroll := .F.
		
		oBrwXml6:bLDblClick := {|| MarcRegFil(6)}
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " TAB "
		cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' AND TAB." + _cCmp1 + "_TIPO = '6' "
		cQuery += " AND TAB." + _cCmp1 + "_SIT IN ('1', '3') "
		
		If !Empty(M->NOTA)
			
			cQuery += " AND TAB." + _cCmp1 + "_DOC = '" + M->NOTA + "' "
			
		EndIf
		
		If !Empty(M->FORNDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI >= '" + M->FORNDE + "' "
			
		EndIf
		
		If !Empty(M->FORNATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_CODEMI <= '" + M->FORNATE + "' "
			
		EndIf
		
		If !Empty(M->DTDE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DTDE) + "' "
			
		EndIf
		
		If !Empty(M->DTATE)
			
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DTATE) + "' "
			
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab1) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
			
			If SX3->X3_TIPO # "C"
				TcSetField(cAli, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCampos)
			
			If aCampos[nI] == "OK"
					
				oBrwXml6:AddColumn(TCColumn():New("", {|| aImgChk[aXml6[oBrwXml6:nAt, 1]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
				
			ElseIf aCampos[nI] == "DESC"
					
				bAux := &("{|| aXml6[oBrwXml6:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml6 HEADER "Desc." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "SUGPED"
					
				bAux := &("{|| aXml6[oBrwXml6:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml6 HEADER "Ped. Sug." OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf aCampos[nI] == "DTVENC"
					
				bAux := &("{|| aXml6[oBrwXml6:nAt, " + cValToChar(nI) + "]}")
				
				ADD COLUMN TO oBrwXml6 HEADER "Dt Vencs" OEM DATA bAux ALIGN LEFT SIZE 25 PIXELS
				
			ElseIf SX3->( dbSeek(aCampos[nI]) )
					
				bAux := &("{|| aXml6[oBrwXml6:nAt, " + cValToChar(nI) + "]}")
				
				If SX3->X3_TIPO $ "C;D"
					
					ADD COLUMN TO oBrwXml6 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
					
				ElseIf SX3->X3_TIPO == "N"
					
					ADD COLUMN TO oBrwXml6 HEADER AllTrim(X3Titulo()) OEM DATA bAux ALIGN LEFT SIZE SX3->X3_TAMANHO PICTURE SX3->X3_PICTURE
					
				EndIf
				
			EndIf
			
		Next nI
		
		If !(cAli)->( Eof() )
			
			While !(cAli)->( Eof() )
				
				AAdd(aXml6, {})
				
				For nI := 1 To Len(aCampos)
					
					If aCampos[nI] == "OK"
						
						AAdd(ATail(aXml6), 2)
						
					ElseIf aCampos[nI] == "DESC"
						
						AAdd(ATail(aXml6), "NFS-e (Serviço)")
						
					ElseIf aCampos[nI] == "SUGPED"
						
						AAdd(ATail(aXml6), GetSugPed((cAli)->&(_cCmp1 + "_CHAVE")))
						
					ElseIf aCampos[nI] == "DTVENC"
						
						AAdd(ATail(aXml6), GetDtVenc((cAli)->&(_cCmp1 + "_CHAVE")))
						
					ElseIf aCampos[nI] == _cCmp1 + "_EMIT"
						
						AAdd(ATail(aXml6), GetNameCgc((cAli)->&(_cCmp1 + "_CGCEMI")))
						
					ElseIf SX3->( dbSeek(aCampos[nI]) )
						
						AAdd(ATail(aXml6), (cAli)->&(SX3->X3_CAMPO))
						
					EndIf
					
				Next nI
				
				(cAli)->( dbSkip() )
				
			EndDo
						
		Else
			
			aXml6 := {AFill(Array(Len(aCampos)), "")}
			
			aXml6[1][1] := 2
			
		EndIf
		
		(cAli)->( dbCloseArea() )
		
		oBrwXml6:SetArray(aXml6)
		
		oBrwXml6:GoTop()
		
	EndIf
	
	BrwActive("6")
	
Return

Static Function MarcRegFil(nBrw)
	
	Local oBrw := &("oBrwXml" + cValToChar(nBrw))
	Local aArr := &("aXml" + cValToChar(nBrw))
	//Local nI
	
	If !Empty(oBrw:aArray[oBrw:nAt][2])
		
		oBrw:aArray[oBrw:nAt][1] := 3 - oBrw:aArray[oBrw:nAt][1]
		
		aArr := AClone(oBrw:aArray)
		
		oBrw:Refresh()

		If nBrw == 3

			If oBrw:aArray[oBrw:nAt][1] == 1

				nQtdSel3++
				nVlrSel3 += oBrw:aArray[oBrw:nAt][9]

			Else

				nQtdSel3--
				nVlrSel3 -= oBrw:aArray[oBrw:nAt][9]

			EndIf

			oQtdSel3:Refresh()
			oVlrSel3:Refresh()

		EndIf
		
	EndIf
	
Return

Static Function BrwActive(cBrw)
	
	Local nI
	
	For nI := 1 To Len(aFilXml)
		
		If cBrw == aFilXml[nI][1]
			&("oLayXml" + cBrw):Show()
		ElseIf Type("oBrwXml" + aFilXml[nI][1]) == "O"
			&("oLayXml" + aFilXml[nI][1]):Hide()
		EndIf
		
	Next nI
	
Return

Static Function ConfSelXml()
	
	Local nI
	Local nX
	Local aXml := {}
	Local aAux
	
	For nI := 1 To Len(aFilXml)
		
		If aFilXml[nI][1] # "5"
			
			aAux := AClone(&("aXml" + aFilXml[nI][1]))
			
			For nX := 1 To Len(aAux)
				
				If aAux[nX][1] == 1 .And. AScan(aXml, {|x| x == ATail(aAux[nX])}) == 0
					
					AAdd(aXml, ATail(aAux[nX]))
					
				EndIf
				
			Next nX
			
		EndIf
		
	Next nI
	
	If Len(aXml) > 0
		
		For nI := 1 To Len(aXml)
			
			BuscaXML(aXml[nI])
			
		Next nI
		
	Else
		
		MsgInfo("Nenhum XML selecionado.")
		
		Return .F.
		
	EndIf
	
Return .T.

Static Function AtuFilXml()
	
	&(aFilXml[oBrwFil:nAt][4] + "(.T.)")
	
Return

Static Function GetNameCGC(cCgc)
	
	SA2->( dbSetOrder(3) )
	If SA2->( dbSeek(xFilial("SA2") + cCgc) )
		
		While !SA2->( Eof() ) .And. SA2->A2_FILIAL == xFilial("SA2") .And. SA2->A2_CGC == cCgc
			
			If SA2->A2_MSBLQL # "1"
				
				Return SA2->A2_NOME
				
			EndIf
			
			SA2->( dbSkip() )
			
		EndDo
		
		If SA2->( dbSeek(xFilial("SA2") + cCgc) )
		
			Return SA2->A2_NOME
			
		EndIf

	Else

		dbSelectArea("SA1")
		SA1->( dbSetOrder(3) )
		If SA1->( dbSeek(xFilial("SA1") + cCgc) )
			
			While !SA1->( Eof() ) .And. SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_CGC == cCgc
				
				If SA1->A1_MSBLQL # "1"
					Return SA1->A1_NOME
				EndIf
				
				SA1->( dbSkip() )
				
			EndDo
			
			If SA1->( dbSeek(xFilial("SA1") + cCgc) )
			
				Return SA1->A1_NOME
				
			EndIf

		EndIf

	EndIf
	
Return ""

Static Function VldProdXml(cAli)
	
	Local cError   := ""
	Local cWarning := ""
	Local aAreaTab := (_cTab1)->( GetArea() )
	Local nI
	Local lRet     := .F.
	Local aItens
	
	Private oXml
	
	(_cTab1)->( dbSetOrder(1) )
	If (_cTab1)->( dbSeek((cAli)->&(_cCmp1 + "_CHAVE")) )
		
		oXml := XmlParser((_cTab1)->&(_cCmp1 + "_XML"), "_", @cError, @cWarning)
		
		If ValType(oXml) == "O"
			
			If Type('oXml:_NfeProc:_Nfe:_InfNfe:_det') == 'O'
			
				XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, '_det')
				
			EndIf
			
			Begin Sequence
				
				aItens := oXml:_NfeProc:_Nfe:_InfNfe:_det
				
				For nI := 1 To Len(aItens)
					
					dbSelectArea("SA5")
					SA5->( dbSetOrder(14) )
					If SA5->( dbSeek(xFilial("SA5") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI") + ;
						AllTrim(Upper(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text))) ) .And. ;
						(cAli)->C7_PRODUTO == SA5->A5_PRODUTO
						
						lRet := .T.
						Break
						
					EndIf
					
					If Round((cAli)->C7_PRECO, 2) == Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_vUnCom:Text), 2)
						
						lRet := .T.
						Break
						
					EndIf
					
				Next nI
				
			End Sequence
			
			oXml := Nil
			DelClassIntf()
	
		EndIf
		
	EndIf
	
	RestArea(aAreaTab)
	
Return lRet

Static Function ImpDanfSel()

	Local nI
	Local nX
	Local aXml := {}
	Local aAreaTab := (_cTab1)->( GetArea() )
	Local lExc := .T.

	For nI := 1 To Len(aFilXml)
		
		If aFilXml[nI][1] == "1"
			
			aAux := AClone(&("aXml" + aFilXml[nI][1]))
			
			For nX := 1 To Len(aAux)
				
				If aAux[nX][1] == 1 .And. AScan(aXml, {|x| x == ATail(aAux[nX])}) == 0
					
					AAdd(aXml, ATail(aAux[nX]))
					
				EndIf
				
			Next nX
			
		EndIf
		
	Next nI

	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )

	For nI := 1 To Len(aXml)

		If (_cTab1)->( dbSeek(aXml[nI] + "1") )

			U_GOX1DANF()

		EndIf

	Next nI

	If Empty(aXml)

		Alert("É necessário selecionar ao menos 1 XML de nota de serviço para gerar a DANFE.")
		
	EndIf

	RestArea(aAreaTab)

Return

Static Function MarkAll(nBrw, nCol, oObj)
	
	Local oBrw := &("oBrwXml" + cValToChar(nBrw))
	Local aArr := &("aXml" + cValToChar(nBrw))
	Local nI
	
	If nCol == 1
		
		For nI := 1 To Len(oBrw:aArray)
			
			oBrw:aArray[nI][1] := 3 - oBrw:aArray[nI][1]
			
			If nBrw == 3

				If oBrw:aArray[nI][1] == 1

					nQtdSel3++
					nVlrSel3 += oBrw:aArray[nI][9]

				Else

					nQtdSel3--
					nVlrSel3 -= oBrw:aArray[nI][9]

				EndIf

			EndIf
			
		Next nI
		
		oBrw:Refresh()
		
		oQtdSel3:Refresh()
		oVlrSel3:Refresh()
		
	EndIf
	
Return

Static Function CGCAllFil()
	
	Local aFil := FWAllFilial(, , SM0->M0_CODIGO, .F.)
	Local nFil
	Local aInfoFil
	Local cRet := ""
	
	For nFil := 1 To Len(aFil)
		
		aInfoFil := FWArrFilAtu(SM0->M0_CODIGO, aFil[nFil])
		
		If nFil > 1
			
			cRet += ", "
			
		EndIf
		
		cRet += "'" + aInfoFil[18] + "'"
		
	Next nFil
	
Return cRet

Static Function GetSugPed(cChave)
	
	Local cRet := "-"
	Local cAli
	Local cQuery
	
	cQuery := " SELECT TAB." + _cCmp8 + "_NUMPED FROM " + RetSqlName(_cTab8) + " TAB "
	cQuery += " WHERE TAB." + _cCmp8 + "_FILIAL = '" + xFilial(_cTab8) + "' "
	cQuery += " 	AND TAB." + _cCmp8 + "_CHVNFE = '" + cChave + "' "
	cQuery += " 	AND TAB." + _cCmp8 + "_TIPO = '2 ' "
	cQuery += " 	AND TAB.D_E_L_E_T_ = ' ' "
	
	cAli := MpSysOpenQuery(cQuery)
	
	If !(cAli)->( Eof() )
		
		cRet := ""
		
		While !(cAli)->( Eof() )
			
			If !Empty(cRet)
				
				cRet += ", "
				
			EndIf
			
			cRet += (cAli)->&(_cCmp8 + "_NUMPED")
			
			(cAli)->( dbSkip() )
			
		EndDo
		
	EndIf
	
Return cRet

Static Function GetDtVenc(cChave)
	
	Local cRet := "-"
	Local cAli
	Local cQuery
	
	cQuery := " SELECT TAB." + _cCmp8 + "_DTVENC FROM " + RetSqlName(_cTab8) + " TAB "
	cQuery += " WHERE TAB." + _cCmp8 + "_FILIAL = '" + xFilial(_cTab8) + "' "
	cQuery += " 	AND TAB." + _cCmp8 + "_CHVNFE = '" + cChave + "' "
	cQuery += " 	AND TAB." + _cCmp8 + "_TIPO = '3 ' "
	cQuery += " 	AND TAB.D_E_L_E_T_ = ' ' "
	
	cAli := MpSysOpenQuery(cQuery)
	
	If !(cAli)->( Eof() )
		
		cRet := ""
		
		While !(cAli)->( Eof() )
			
			If !Empty(cRet)
				
				cRet += ", "
				
			EndIf
			
			cRet += DToC(SToD((cAli)->&(_cCmp8 + "_DTVENC")))
			
			(cAli)->( dbSkip() )
			
		EndDo
		
	EndIf
	
Return cRet



Static Function SortColumn(nCol)
    
    If Empty(aOrd)
        
        AAdd(aOrd, nCol)
        AAdd(aOrd, "A")
        
        oBrwXml1:SetHeaderImage(nCol, "NG_SETA_BAIXO")
        
        ASort(aXml1,,, {|x, y| x[nCol] > y[nCol]})
        
    Else
        
        If aOrd[1] == nCol
            
            If aOrd[2] == "A"
                
                aOrd[2] := "D"
                
                oBrwXml1:SetHeaderImage(nCol, "NG_SETA_CIMA")
                
                ASort(aXml1,,, {|x, y| x[nCol] < y[nCol]})
                
            Else
                
                aOrd[2] := "A"
                
                oBrwXml1:SetHeaderImage(nCol, "NG_SETA_BAIXO")
                
                ASort(aXml1,,, {|x, y| x[nCol] > y[nCol]})
                
            EndIf
            
        Else
            
            SetDefHead(.f.)
            
            AAdd(aOrd, nCol)
            AAdd(aOrd, "A")
            
            oBrwXml1:SetHeaderImage(nCol, "NG_SETA_BAIXO")
            
            ASort(aXml1,,, {|x, y| x[nCol] > y[nCol]})
            
        EndIf
        
    EndIf
    
    oBrwXml1:SetArray(aXml1)
    oBrwXml1:Refresh()
	
Return


Static Function SetDefHead(lPrim)
	
	Local nI
		


    aOrd := {}
    
    For nI := 1 To Len(oBrwXml1:aColumns)
        
        If nI == 1
            
			if lPrim
            	oBrwXml1:SetHeaderImage(nI, "LBNO")
			endif
            
        Else
            
            oBrwXml1:SetHeaderImage(nI, "NEXT_PQ")
            
        EndIf
        
    Next nI
	
Return



Static Function MarcTd()
	
	Local nI


	
	If Len(oBrwXml1:aArray) == 1 .And. Empty(oBrwXml1:aArray[1][2])        
        Return .F.        
    EndIf

	if lTdCab
		oBrwXml1:SetHeaderImage(1, "LBNO")
	else
		oBrwXml1:SetHeaderImage(1, "LBOK")    
	endif    
        
	For nI := 1 To Len(oBrwXml1:aArray)

		if lTdCab
			oBrwXml1:aArray[nI][1] := 2 //"LBNO"
		else
			oBrwXml1:aArray[nI][1] := 1 //"LBOK"
		endif	
		
	Next nI

	lTdCab := !lTdCab   
    
    aArray := AClone(oBrwXml1:aArray)
    
    oBrwXml1:Refresh()
	
Return

// Verifica se precisa trocar os dados do CT-e
Static Function AltInfoCte()
	
	Local cError   := ""
	Local cWarning := ""
	
	Local cCondAux := PadR(GetNewPar("MV_ZGOCPCA", ""), TamSX3("E4_CODIGO")[1]) //Space(TamSX3("E4_CODIGO")[1])

	Local cNaturAux := PadR(GetNewPar("MV_ZGONTCA", ""), TamSX3("ED_CODIGO")[1]) //21532     

	Local cTesEAux := PadR(GetNewPar("MV_ZGOTECA", ""), TamSX3("F4_CODIGO")[1]) //Space(TamSX3("F4_CODIGO")[1])

	Local cTesSAux := PadR(GetNewPar("MV_ZGOTSCA", ""), TamSX3("F4_CODIGO")[1]) //Space(TamSX3("F4_CODIGO")[1])
		
	Local cCCSAux := PadR(GetNewPar("MV_ZGOCCCA", ""), TamSX3("D1_CC")[1]) //Centro de Custo para CT-e de Saída

	Local cPrdFrtAux := PadR(GetNewPar("MV_XGTFREA", ""), TamSX3("B1_COD")[1])

	Private oXmlAux
	
	If GetNewPar("MV_ZGOCTTP", .F.)
		
		oXmlAux := XmlParser((_cTab1)->&(_cCmp1 + "_XML"), "_", @cError, @cWarning)
		
		If Type("oXmlAux:_cteProc:_Cte:_InfCte:_Ide:_TPSERV") == "O"
			
			If AllTrim(oXmlAux:_cteProc:_Cte:_InfCte:_Ide:_TPSERV:Text) == "1"
				
				// Mudar Valor dos Campos
				
				If !Empty(cCondAux)
					
					cCond := cCondAux
					
				EndIf

				If !Empty(cNaturAux)
					
					cNatur := cNaturAux
					
				EndIf
	
				If !Empty(cTesEAux)
					
					cTesE := cTesEAux
					
				EndIf
				
				If !Empty(cTesSAux)
					
					cTesS := cTesSAux
					
				EndIf
				
				If !Empty(cCCSAux)
					
					cCCS := cCCSAux
					
				EndIf
				
				If !Empty(cPrdFrtAux)
					
					cPrdFrtSai := cPrdFrtAux
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
Return
