#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSMGADD.CH"

User Function GOX005()
	
	Local oDlgGer
	Local cPermit := GetNewPar("MV_XGTGERP", "")
	Local aSize   := MsAdvSize()
	
	Local aRotAux := IIf(Type("aRotina") # "U", aRotina, Nil)
	
	Local aFields := {}
	
	aRotina := Nil
	
	Private oLayerMain
	Private oLayerGraf
	
	// Alias
	Private cAliTot := GetNextAlias()
	Private cAliUsu := GetNextAlias()
	Private cAliPen := GetNextAlias()
	Private cAliFlx := GetNextAlias()
	
	// Gráficos
	Private oGrafTot
	Private oGrafUsu
	Private oGrafPen
	Private oGrafFlx
	
	Private oFilGet
	
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
		
		oDlgGer:lEscClose := .F.
		
		oLayerGraf := FWLayer():New()
		oLayerGraf:Init(oDlgGer, .T.)
			
			oLayerGraf:AddLine('FILTRO', 20, .F.)
				
				oLayerGraf:AddCollumn('FILTRO_COL1', 100, .F., 'FILTRO')
					
					oLayerGraf:AddWindow('FILTRO_COL1', 'FILTRO_COL1_WIN1', "Filtros", 100, .F., .F., {|| }, 'FILTRO',)
						
						ADD FIELD aFields TITULO "Filial de" CAMPO "FILDE" TIPO "D" TAMANHO FwSizeFilial() DECIMAL 0 PICTURE "" VALID '' NIVEL 1 When .T.
						M->FILDE := cFilAnt
						
						ADD FIELD aFields TITULO "Filial até" CAMPO "FILATE" TIPO "D" TAMANHO FwSizeFilial() DECIMAL 0 PICTURE "" VALID {|| RefreshAllGraf()} NIVEL 1 When .T.
						M->FILATE := cFilAnt
						
						ADD FIELD aFields TITULO "Data de" CAMPO "DATADE" TIPO "D" TAMANHO 8 DECIMAL 0 PICTURE "" VALID {|| RefreshAllGraf()} NIVEL 1 When .T.
						M->DATADE := Date()
						
						ADD FIELD aFields TITULO "Data até" CAMPO "DATAATE" TIPO "D" TAMANHO 8 DECIMAL 0 PICTURE "" VALID {|| RefreshAllGraf()} NIVEL 1 When .T.
						M->DATAATE := Date()
						
						/*ADD FIELD aFields TITULO "Tp Emissor" CAMPO "TPEMIS" TIPO "C" TAMANHO 1 DECIMAL 0 PICTURE "" VALID {|| RefreshAllGraf()} NIVEL 1 When .T. BOX "1=Fornecedor;2=Cliente"
						M->TPEMIS := "1"*/
						
						ADD FIELD aFields TITULO "Emissor de" CAMPO "EMISSDE" TIPO "C" TAMANHO TamSX3("A2_COD")[1] DECIMAL 0 PICTURE "" VALID {|| RefreshAllGraf()} NIVEL 1 When .T. F3 "SA2"
						M->EMISSDE := Space(TamSX3("A2_COD")[1])
						
						ADD FIELD aFields TITULO "Emissor até" CAMPO "EMISSATE" TIPO "C" TAMANHO TamSX3("A2_COD")[1] DECIMAL 0 PICTURE "" VALID {|| RefreshAllGraf()} NIVEL 1 When .T. F3 "SA2"
						M->EMISSATE := Replicate("z", TamSX3("A2_COD")[1])
						
						oFilGet := MsMGet():New(,, 4,,,,, {0,0,0,0},,,,,, oLayerGraf:GetWinPanel('FILTRO_COL1', 'FILTRO_COL1_WIN1', 'FILTRO'),,.T.,,,,.T., aFields,,.T.,,,.T.)
						
						oFilGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
						
						oFilGet:Refresh()
						
				/*oLayerGraf:AddCollumn('FILTRO_COL2', 20, .F., 'FILTRO')
					
					oLayerGraf:AddWindow('FILTRO_COL2', 'FILTRO_COL2_WIN1', "Ações", 100, .F., .F., {|| }, 'FILTRO', )*/
						
						
						
			oLayerGraf:AddLine('GRAF', 80, .F.)
				
				oLayerGraf:AddCollumn('GRAF_COL1', 50, .F., 'GRAF')
					
					oLayerGraf:AddWindow('GRAF_COL1', 'GRAF_COL1_WIN1', "Totais XMLs período", 50, .T., .F., {|| TotGrafRefresh()}, 'GRAF', )
						
						TotGrafRefresh()
						
					oLayerGraf:AddWindow('GRAF_COL1', 'GRAF_COL1_WIN2', "Importações por usuário", 50, .T., .F., {|| TotGrafRefresh()}, 'GRAF', )
						
						UsuGrafRefresh()
						
				oLayerGraf:AddCollumn('GRAF_COL2', 50, .F., 'GRAF')
				
					oLayerGraf:AddWindow('GRAF_COL2', 'GRAF_COL1_WIN1', "Tipo XMLs pendentes", 50, .T., .F., {|| }, 'GRAF', )
						
						PenGrafRefresh()
						
					oLayerGraf:AddWindow('GRAF_COL2', 'GRAF_COL2_WIN2', "Fluxo de entrada", 50, .T., .F., {|| }, 'GRAF', )
						
						FlxUsufRefresh()
						
	ACTIVATE MSDIALOG oDlgGer CENTERED ON INIT ()
	
	aRotina := aRotAux
	
Return

Static Function RefreshAllGraf()
	
	TotGrafRefresh()
	
	UsuGrafRefresh()
	
	PenGrafRefresh()
	
	FlxUsufRefresh()
	
Return

Static Function TotGrafRefresh()
	
	Local cQuery := ""
	Local nTot   := 0
	
	oLayerGraf:GetWinPanel('GRAF_COL1', 'GRAF_COL1_WIN1', 'GRAF'):FreeChildren()
	
	oGrafTot := FWChartFactory():New()
	
	oGrafTot := oGrafTot:GetInstance(BARCHART)
	
	oGrafTot:Init(oLayerGraf:GetWinPanel('GRAF_COL1', 'GRAF_COL1_WIN1', 'GRAF'), .F.)
	
	cQuery := " SELECT COUNT(*) TOTAL, TAB1." + _cCmp1 + "_SIT SIT "
	cQuery += " FROM " + RetSqlName(_cTab1) + " TAB1 "
	cQuery += " WHERE TAB1.D_E_L_E_T_ = ' ' "
	
	If !Empty(M->FILDE)
		
		cQuery += " AND TAB1." + _cCmp1 + "_FILIAL >= '" + M->FILDE + "' "
		
	EndIf
	
	If !Empty(M->FILATE)
		
		cQuery += " AND TAB1." + _cCmp1 + "_FILIAL <= '" + M->FILATE + "' "
		
	EndIf
	
	If !Empty(M->DATADE)
		
		cQuery += " AND TAB1." + _cCmp1 + "_DTEMIS >= '" + DToS(M->DATADE) + "' "
		
	EndIf
	
	If !Empty(M->DATAATE)
		
		cQuery += " AND TAB1." + _cCmp1 + "_DTEMIS <= '" + DToS(M->DATAATE) + "' "
		
	EndIf
	
	If !Empty(M->EMISSDE)
		
		cQuery += " AND TAB1." + _cCmp1 + "_CODEMI >= '" + M->EMISSDE + "' "
		
	EndIf
	
	If !Empty(M->EMISSATE)
		
		cQuery += " AND TAB1." + _cCmp1 + "_CODEMI <= '" + M->EMISSATE + "' "
		
	EndIf
	
	cQuery += " 	GROUP BY TAB1." + _cCmp1 + "_SIT " 
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAliTot, .F., .T.)
	
	(cAliTot)->( dbEval({|| nTot += (cAliTot)->TOTAL}) )
	
	oGrafTot:AddSerie("Total", nTot)
	
	(cAliTot)->( dbGoTop() )
	
	While !(cAliTot)->( Eof() )
		
		oGrafTot:AddSerie(AllTrim(GFEFldInfo(_cCmp1 + "_SIT", (cAliTot)->SIT, 2)), (cAliTot)->TOTAL)
		
		(cAliTot)->( dbSkip() )
		
	EndDo
	
	oGrafTot:Build()
	
	(cAliTot)->( dbCloseArea() )
	
Return

Static Function UsuGrafRefresh()
	
	Local cQuery := ""
	Local nTot   := 0
	
	oLayerGraf:GetWinPanel('GRAF_COL1', 'GRAF_COL1_WIN2', 'GRAF'):FreeChildren()
	
	oGrafUsu := FWChartFactory():New()
	
	oGrafUsu := oGrafUsu:GetInstance(LINECHART)
	
	oGrafUsu:Init(oLayerGraf:GetWinPanel('GRAF_COL1', 'GRAF_COL1_WIN2', 'GRAF'), .F.)
	
	cQuery := " SELECT COUNT(*) TOTAL, TAB1." + _cCmp1 + "_SIT SIT "
	cQuery += " FROM " + RetSqlName(_cTab1) + " TAB1 "
	cQuery += " WHERE TAB1.D_E_L_E_T_ = ' ' "
	cQuery += " 	GROUP BY TAB1." + _cCmp1 + "_SIT " 
	
	/*
	SELECT ZD7_FILIAL, ZD7_USUIMP, ZD7_DTIMP, COUNT(*) FROM ZD7010 WHERE D_E_L_E_T_ = ' ' AND ZD7_SIT = '2' AND ZD7_USUIMP <> ' '
	GROUP BY ZD7_FILIAL, ZD7_USUIMP, ZD7_DTIMP
	ORDER BY ZD7_FILIAL, ZD7_USUIMP
	*/
	
	//dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAliTot, .F., .T.)
	
	//(cAliTot)->( dbEval({|| nTot += (cAliTot)->TOTAL}) )
	
	//oGrafTot:AddSerie("Total", nTot)
	
	//(cAliTot)->( dbGoTop() )
	
	//While !(cAliTot)->( Eof() )
	
	// BARCHART(0)
	// LINECHART(1)
	// PIECHART(2)
	/*oGrafUsu := FWChartFactory():New()
	
	oGrafUsu := oGrafUsu:GetInstance(PIECHART)
	
	oGrafUsu:SetLegend(CONTROL_ALIGN_BOTTOM)
	
	oGrafUsu:Init(oLayerMain:GetWinPanel('XML_GRF', 'WIN_GRF2', 'MAIN'), .T.)
	//oGrafTot:SetMask("R$ *@*")
	
	oGrafUsu:AddSerie("Lidiane", 20)
	oGrafUsu:AddSerie("Octávio", 80)
	
	oGrafUsu:Build()*/
	
Return

Static Function PenGrafRefresh()
	
	
	
Return

Static Function FlxUsufRefresh()
	
	
	
Return

Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "&Liberar CT-e" ACTION "U_GOX5LIB" OPERATION 4 ACCESS 0
	
Return aRotina

User Function GOX5LIB()
	
	If (_cTab1)->&(_cCmp1 + "_TIPO") == "2" .And. (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3;6" .And. (_cTab1)->&(_cCmp1 + "_LIBER") # "1"
		
		RecLock(_cTab1, .F.)
			
			(_cTab1)->&(_cCmp1 + "_LIBER") := "1"
			
		MSUnlock()
		
		MsgInfo("Liberação realizada com sucesso. O usuário poderá agora modificar a nota vinculada ao CT-e no momento da importação.", "Atenção")
		
	Else
		
		MsgInfo("Somente pode ser liberado CT-e's que estão aptos para importar e não foram liberados anteriormente.", "Atenção")
		
	EndIf
	
Return
