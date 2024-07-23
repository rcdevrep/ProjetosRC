#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function GOX010()
	
	Local oDlgGer
	Local cPermit := GetNewPar("MV_XGTGERP", "")
	Local aSize   := MsAdvSize()
	
	Local aRotAux := IIf(Type("aRotina") # "U", aRotina, Nil)
	
	Local aFields := {}
	
	aRotina := Nil
	
	Private oLayerMain
	Private oLayerGraf
	
	Private oFilGet
	
	Private oBrowseXML
	Private oBrowseIt
	Private oTitle
	
	Private cTitle := ""
	
	//////////////////////////////////////// Variáveis das tabelas
	Private _cTab1     := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cTab2     := Upper(AllTrim(GetNewPar("MV_XGTTAB2", "")))  // Importador NFe
	Private _cTab3     := Upper(AllTrim(GetNewPar("MV_XGTTAB3", "")))  // Eventos Importador
	Private _cTab4     := Upper(AllTrim(GetNewPar("MV_XGTTAB4", "")))  // Tabela Unidade de Medida por Produto
	Private _cCmp1     := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	Private _cCmp2     := IIf(SubStr(_cTab2, 1, 1) == "S", SubStr(_cTab2, 2, 2), _cTab2)
	Private _cCmp3     := IIf(SubStr(_cTab3, 1, 1) == "S", SubStr(_cTab3, 2, 2), _cTab3)
	Private _cCmp4     := IIf(SubStr(_cTab4, 1, 1) == "S", SubStr(_cTab4, 2, 2), _cTab4)
	////////////////////////////////////////
	
	If !FwIsAdmin() .And. !(AllTrim(RetCodUsr()) $ cPermit)
		
		Aviso("Permissão", "Esta rotina só pode ser acessada por usuários autorizados (Parâmetro MV_XGTGERP) ou pelos administradores do sistema.", {"Entendi"}, 2)
		
		Return
		
	EndIf
	
	DEFINE MSDIALOG oDlgGer FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE 'Gerenciador de XMLs - Importador' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		//oDlgGer:lEscClose := .F.
		
		oLayerMain := FWLayer():New()
		oLayerMain:Init(oDlgGer, .T.)
		
			oLayerMain:AddLine('MAIN', 100, .F.)							
						
				oLayerMain:AddCollumn('XML_IMP', 50, .F., 'MAIN')
						
					oBrowseXML := FWMBrowse():New()
					oBrowseXML:SetAlias(_cTab1)
					oBrowseXML:SetMenuDef("GOX010") 
					oBrowseXML:SetDescription("XML's bloqueados por regra")
					oBrowseXML:SetOwner(oLayerMain:GetColPanel('XML_IMP', "MAIN"))
					oBrowseXML:DisableDetails()
					oBrowseXML:DisableReport()
					oBrowseXML:DisableConfig()
					oBrowseXML:SetWalkThru(.F.)
					oBrowseXML:SetAmbiente(.F.)
					//oBrowseXML:ForceQuitButton(.T.)
					//oBrowseXML:SetFixedBrowse(.T.)
					//oBrowseXML:bChange := bUpdBrwNFe
					//SetFieldsBrowse(oBrowseXML, "NFE")
					//StaticCall(GOX001, SetFieldsBrowse, oBrowseXML, "NFE")
					
					oBrowseXML:SetOnlyFields({_cCmp1 + "_FILIAL",;
										     _cCmp1 + "_CHAVE",;
										     _cCmp1 + "_DOC",;
										     _cCmp1 + "_SERIE",;
										     _cCmp1 + "_CODEMI",;
										     _cCmp1 + "_LOJEMI",;
										     _cCmp1 + "_EMIT",;
										     _cCmp1 + "_DTEMIS",;
										     _cCmp1 + "_NATOP",;
										     _cCmp1 + "_USUIMP";
										     })
					
					//oBrowseXML:AddLegend(_cCmp1 + "_SIT=='1'", "BLUE", "Normal")
					//oBrowseXML:AddLegend(_cCmp1 + "_SIT=='3'", "RED", "Tentativa de importação com erro")
					oBrowseXML:SetFilterDefault(_cCmp1 + "_LIBER == '2'")
					oBrowseXML:SetFixedBrowse(.T.)
					oBrowseXML:Activate()
					
					oBrowseXML:bChange	:= {|| cTitle := (_cTab1)->&(_cCmp1 + "_ERRO"), oTitle:Refresh()}
						
				oLayerMain:AddCollumn('XML_COL1', 50, .F., 'MAIN')
					
					oLayerGraf := FWLayer():New()
					oLayerGraf:Init(oLayerMain:GetColPanel('XML_COL1', 'MAIN'), .T.)
						
						oLayerGraf:AddLine('FILTRO', 20, .F.)
							
							oLayerGraf:AddCollumn('FILTRO_COL1', 100, .F., 'FILTRO')
								
								oLayerGraf:AddWindow('FILTRO_COL1', 'FILTRO_COL1_WIN1', "Filtros", 100, .F., .F., {|| }, 'FILTRO',)
									
									oTitle := tMultiget():New(10, 10, {|u| If(Pcount() > 0, cTitle := u, cTitle)}, ;
												oLayerGraf:GetWinPanel('FILTRO_COL1', 'FILTRO_COL1_WIN1', 'FILTRO'), ;
												100, 100, , , , , , .T., , , , , , .T., , , , .F.)
									oTitle:Align := CONTROL_ALIGN_ALLCLIENT
									oTitle:EnableVScroll(.T.)
									oTitle:EnableHScroll(.F.)
									oTitle:lWordWrap := .T.
									oTitle:Refresh()
									
						oLayerGraf:AddLine('GRAF', 80, .F.)
							
							oLayerGraf:AddCollumn('GRAF_COL1', 100, .F., 'GRAF')
								
								//oLayerGraf:AddWindow('GRAF_COL1', 'GRAF_COL1_WIN1', "Totais XMLs período", 50, .T., .F., {|| TotGrafRefresh()}, 'GRAF', )
									
									oBrowseIt := FWMBrowse():New()
									oBrowseIt:SetAlias(_cTab2)
									oBrowseIt:SetMenuDef("") 
									oBrowseIt:SetDescription("Itens do XML Bloqueado")
									oBrowseIt:SetOwner(oLayerGraf:GetColPanel('GRAF_COL1', "GRAF"))
									oBrowseIt:DisableDetails()
									oBrowseIt:DisableReport()
									oBrowseIt:DisableConfig()
									oBrowseIt:SetWalkThru(.F.)
									oBrowseIt:SetAmbiente(.F.)
									//oBrowseIt:ForceQuitButton()
									//oBrowseIt:SetFixedBrowse(.T.)
									//oBrowseIt:bChange := bUpdBrwNFe
									//SetFieldsBrowse(oBrowseIt, "NFE")
									//StaticCall(GOX001, SetFieldsBrowse, oBrowseIt, "NFE")
									//oBrowseIt:AddLegend(_cCmp1 + "_SIT=='1'", "BLUE", "Normal")
									//oBrowseIt:AddLegend(_cCmp1 + "_SIT=='3'", "RED", "Tentativa de importação com erro")
									
									oBrowseIt:SetOnlyFields({_cCmp2 + "_DESC",;
														     _cCmp2 + "_COD",;
														     _cCmp2 + "_DSPROD",;
														     _cCmp2 + "_QUANT2",;
														     _cCmp2 + "_VUNIT",;
														     _cCmp2 + "_TOTAL",;
														     _cCmp2 + "_TES",;
														     _cCmp2 + "_CLASFI",;
														     _cCmp2 + "_NFORI",;
														     _cCmp2 + "_SERORI",;
														     _cCmp2 + "_ITORI",;
														     _cCmp2 + "_CSTERP";
														     })
									
									//oBrowseIt:SetFilterDefault("ZD7_LIBER == '2'")
									oBrowseIt:SetFixedBrowse(.T.)
									oBrowseIt:Activate()
									
									oRelXML := FWBrwRelation():New()
									oRelXML:AddRelation(oBrowseXML, oBrowseIt, {{_cCmp2 + '_FILIAL', _cCmp1 + '_FILIAL'}, {_cCmp2 + '_SEQIMP', _cCmp1 + '_SEQIMP'}})
									oRelXML:Activate()
									
									oTimer := TTimer():New(30000, {|| oBrowseXML:Refresh()}, oDlgGer)
									oTimer:Activate()
									
	ACTIVATE MSDIALOG oDlgGer CENTERED ON INIT ()
	
	aRotina := aRotAux
	
Return

Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "&Liberar" ACTION "U_GOX10LIB()" OPERATION 4 ACCESS 0
	
Return aRotina

User Function GOX10LIB()
	
	If MsgYesNo("Deseja liberar o bloqueio de regra da nota " + (_cTab1)->&(_cCmp1 + "_DOC") + "?")
		
		RecLock(_cTab1, .F.)
			
			(_cTab1)->&(_cCmp1 + "_LIBER") := "1"
			
		(_cTab1)->( MSUnlock() )
		
		MsgInfo("Liberado com sucesso!")
		
	EndIf
	
Return
