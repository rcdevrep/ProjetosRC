#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "MSMGADD.CH"

// Nova consulta de pedidos de compra do fornecedor.

#DEFINE XML_SEL     1
#DEFINE XML_ITEM    2
#DEFINE XML_PROD    3
#DEFINE XML_DESPROD 4
#DEFINE XML_QTDE    5
#DEFINE XML_VUNIT   6
#DEFINE XML_TOTAL   7
#DEFINE XML_POS     8
#DEFINE XML_CCUS1   9 // Campo Customizado

#DEFINE PED_SEL     1
#DEFINE PED_NUMPED  2
#DEFINE PED_ITPED   3
#DEFINE PED_PROD    4
#DEFINE PED_DESPROD 5
#DEFINE PED_QTDE    6
#DEFINE PED_VUNIT   7
#DEFINE PED_TOTAL   8
#DEFINE PED_EMISSAO 9
#DEFINE PED_TIPODES 10
#DEFINE PED_TIPO    11
#DEFINE PED_LOCAL   12

//#DEFINE VIN_SEL     1
#DEFINE VIN_EXC     1
#DEFINE VIN_ITEM    2
#DEFINE VIN_PROD    3
#DEFINE VIN_DESPROD 4
#DEFINE VIN_PED     5
#DEFINE VIN_ITPED   6
#DEFINE VIN_QTDE    7
#DEFINE VIN_VUNIT   8
#DEFINE VIN_TOTAL   9
#DEFINE VIN_RELAC   10
#DEFINE VIN_TIPO    11

User Function GOX1PED()
	
	//Local aFldToTX := {}
	//Local aFldToTP := {}

	Private oDlgPed
	Private oLayerPed
	Private oLayerItPed
	Private oLayerItXml
	Private oLayerAcao
	
	Private oBrwItXml
	Private oBrwItPed
	Private oBrwItVin
	
	Private aHeadItPed := {}
	Private aHeadItXml := {}
	Private aHeadItVin := {}
	
	Private aItXml := {}
	Private aItPed := {}
	Private aItVin := {}
	
	Private aRelac := {}
	
	Private aImgChk  := {LoadBitmap(GetResources(), "LBOK"), ;
				         LoadBitmap(GetResources(), "LBNO")}
	
	Private aImgExc  := {LoadBitmap(GetResources(), "XCLOSE")}
	
	Private oFilXml
	Private cFilXml  := Space(50)
	
	Private oFilPed
	Private cFilPed  := Space(50)//Space(TamSX3("C7_NUM")[1])
	
	// Busca por pedido
	Private oChkPesPed
	Private oChkPesSol
	Private lPesqPed := .T.
	Private lPesqSol := .T.
	
	// Filtra Produto
	Private oChkFilPrd
	Private lFilPrd := .F.
	
	//Private oTotXML
	//Private oTotPed

	Private oQtdTotX
	Private oVlrTotX
	Private oQtdSelX
	Private oVlrSelX
	Private oQtdTotP
	Private oVlrTotP
	Private oQtdSelP
	Private oVlrSelP

	Private nQtdTotX := 0
	Private nVlrTotX := 0
	Private nQtdSelX := 0
	Private nVlrSelX := 0
	Private nQtdTotP := 0
	Private nVlrTotP := 0
	Private nQtdSelP := 0
	Private nVlrSelP := 0
	
	Private lXmlCCus1 := ExistBlock("GOXXMCC1")
	Private aXmlCCus1 := {"", "", 60}
	
	If lXmlCCus1
		
		aXmlCCus1 := ExecBlock("GOXXMCC1", .F., .F.)
		
	EndIf

	DEFINE MSDIALOG oDlgPed FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oLayerPed := FWLayer():New()
		oLayerPed:Init(oDlgPed, .F.)
			
			oLayerPed:AddLine('LIN1', 60, .F.)
				
				oLayerPed:AddCollumn('COL1_LIN1', 48, .T., 'LIN1')
					
					oLayerPed:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Itens no XML", 100, .F., .T., , 'LIN1',)
						
						oLayerItXml := FWLayer():New()
						oLayerItXml:Init(oLayerPed:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), .F.)
							
							oLayerItXml:AddLine('LIN1', 10, .F.)
								
								oLayerItXml:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
									
									oFilXml := TGet():New(002, 000, {|u| If(PCount() == 0, cFilXml, cFilXml := u ) }, oLayerItXml:GetColPanel('COL1_LIN1', 'LIN1'), 130, 010, "",, 0, 16777215,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F., /*F3*/, "cFilXml",,,, .T.,,, "Filtra Item", 2)
									oFilXml:bValid := {|| AtuXml()}
									
							oLayerItXml:AddLine('LIN2', 80, .F.)
								
								oLayerItXml:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
									
									//-------------------- Browse Itens do XML
									
									CargaItVin()
									
									CargaItXml(.F.)
									
									oBrwItXml := TCBrowse():New(50, 50, 200, 200,,,, oLayerItXml:GetColPanel('COL1_LIN2', 'LIN2'),,,,,,,,,,,, .T.,, .T.,)
									oBrwItXml:Align := CONTROL_ALIGN_ALLCLIENT
									oBrwItXml:nClrBackFocus := GetSysColor(13)
									oBrwItXml:nClrForeFocus := GetSysColor(14)
									oBrwItXml:SetArray(aItXml)
									
									oBrwItXml:bChange := {|| IIf(lFilPrd, AtuPed(), )}
									
									//FWGetCSS
									
									oBrwItXml:AddColumn(TCColumn():New(""    , {|| aImgChk[aItXml[oBrwItXml:nAt, XML_SEL]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
									AAdd(aHeadItXml, XML_SEL)
									
									ADD COLUMN TO oBrwItXml HEADER "Item XML" OEM DATA {|| aItXml[oBrwItXml:nAt, XML_ITEM]} ALIGN LEFT SIZE 90 PIXELS
									//oBrwItXml:AddColumn(TCColumn():New("Item XML", {|| aItXml[oBrwItXml:nAt, XML_ITEM]},,,, "RIGHT" , 90, .T., .F.,,,, .T.,))
									AAdd(aHeadItXml, XML_ITEM)
									
									ADD COLUMN TO oBrwItXml HEADER "Produto" OEM DATA {|| aItXml[oBrwItXml:nAt, XML_PROD]} ALIGN LEFT SIZE 30 PIXELS
									//oBrwItXml:AddColumn(TCColumn():New("Produto", {|| aItXml[oBrwItXml:nAt, XML_PROD]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItXml, XML_PROD)
									
									ADD COLUMN TO oBrwItXml HEADER "Desc.Prod." OEM DATA {|| aItXml[oBrwItXml:nAt, XML_DESPROD]} ALIGN LEFT SIZE 60 PIXELS
									//oBrwItXml:AddColumn(TCColumn():New("Desc.Prod.", {|| aItXml[oBrwItXml:nAt, XML_DESPROD]},,,, "RIGHT" , 60, .T., .F.,,,, .T.,))
									AAdd(aHeadItXml, XML_DESPROD)
									
									ADD COLUMN TO oBrwItXml HEADER "Qtde." OEM DATA {|| aItXml[oBrwItXml:nAt, XML_QTDE]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_QUANT")[2]) SIZE 30 PIXELS
									//oBrwItXml:AddColumn(TCColumn():New("Qtde.", {|| aItXml[oBrwItXml:nAt, XML_QTDE]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItXml, XML_QTDE)
									
									ADD COLUMN TO oBrwItXml HEADER "Val.Unit." OEM DATA {|| aItXml[oBrwItXml:nAt, XML_VUNIT]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_VUNIT")[2]) SIZE 30 PIXELS
									//oBrwItXml:AddColumn(TCColumn():New("Val.Unit.", {|| aItXml[oBrwItXml:nAt, XML_VUNIT]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItXml, XML_VUNIT)
									
									If lXmlCCus1
										
										ADD COLUMN TO oBrwItXml HEADER aXmlCCus1[1] OEM DATA {|| aItXml[oBrwItXml:nAt, XML_CCUS1]} ALIGN RIGHT SIZE 30 PIXELS
										//oBrwItXml:AddColumn(TCColumn():New(aXmlCCus1[1], {|| aItXml[oBrwItXml:nAt, XML_CCUS1]},,,, aXmlCCus1[2], aXmlCCus1[3], .T., .F.,,,, .T.,))
										AAdd(aHeadItXml, XML_CCUS1)
										
									EndIf
									
									ADD COLUMN TO oBrwItXml HEADER "Total" OEM DATA {|| aItXml[oBrwItXml:nAt, XML_TOTAL]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_TOTAL")[2]) SIZE 30 PIXELS
									//oBrwItXml:AddColumn(TCColumn():New("Total", {|| aItXml[oBrwItXml:nAt, XML_TOTAL]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItXml, XML_TOTAL)
									
									//SetDefHead(1)
									
									oBrwItXml:bLDblClick := {|| MarcReg(1)}
									
									//oBrwItXml:bHeaderClick := {|oObj, nCol| SortColumn(1, nCol, oObj)}
									
									oBrwItXml:GoTop()
									
									//////////////////////////////////////////
									
							oLayerItXml:AddLine('LIN3', 10, .F.)
								
								oLayerItXml:AddCollumn('COL1_LIN3', 100, .T., 'LIN3')

									oQtdTotX := TGet():New(002, 002, {|u| IF(Pcount() > 0, nQtdTotX := u, nQtdTotX)}, oLayerItXml:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_QUANT"), , , , , , , .T., , , {|| .F.}, , , , , , , "nQtdTotX", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Qtd Tot", 2, , )

									oVlrTotX := TGet():New(002, 062, {|u| IF(Pcount() > 0, nVlrTotX := u, nVlrTotX)}, oLayerItXml:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_TOTAL"), , , , , , , .T., , , {|| .F.}, , , , , , , "nVlrTotX", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Vlr Tot", 2, , )

									oQtdSelX := TGet():New(002, 122, {|u| IF(Pcount() > 0, nQtdSelX := u, nQtdSelX)}, oLayerItXml:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_QUANT"), , , , , , , .T., , , {|| .F.}, , , , , , , "nQtdSelX", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Qtd Sel", 2, , )

									oVlrSelX := TGet():New(002, 182, {|u| IF(Pcount() > 0, nVlrSelX := u, nVlrSelX)}, oLayerItXml:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_TOTAL"), , , , , , , .T., , , {|| .F.}, , , , , , , "nVlrSelX", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Vlr Sel", 2, , )

									/*ADD FIELD aFldToTX TITULO "Qtd Tot" CAMPO "QTDTOTX"  TIPO "N" TAMANHO TamSX3("D1_QUANT")[1] DECIMAL TamSX3("D1_QUANT")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->QTDTOTX := 0
									
									ADD FIELD aFldToTX TITULO "Vlr Tot" CAMPO "VLRTOTX"  TIPO "N" TAMANHO TamSX3("D1_TOTAL")[1] DECIMAL TamSX3("D1_TOTAL")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->VLRTOTX := 0

									ADD FIELD aFldToTX TITULO "Qtd Sel" CAMPO "QTDSELX"  TIPO "N" TAMANHO TamSX3("D1_QUANT")[1] DECIMAL TamSX3("D1_QUANT")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->QTDSELX := 0
									
									ADD FIELD aFldToTX TITULO "Vlr Sel" CAMPO "VLRSELX"  TIPO "N" TAMANHO TamSX3("D1_TOTAL")[1] DECIMAL TamSX3("D1_TOTAL")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->VLRSELX := 0

									oTotXml := MsMGet():New(,, 4,,,,, {0,0,0,0},,,,,, oLayerItXml:GetColPanel('COL1_LIN3', 'LIN3'),,.T.,,,,.T., aFldToTX,,.T.,,,.T.)
									
									oTotXml:oBox:Align := CONTROL_ALIGN_ALLCLIENT*/

				oLayerPed:AddCollumn('COL2_LIN1', 4, .T., 'LIN1')
					
					oLayerPed:AddWindow('COL2_LIN1', 'WIN1_COL2_LIN1', "Ação", 100, .F., .T., , 'LIN1',)
						
						oLayerAcao := FWLayer():New()
						oLayerAcao:Init(oLayerPed:GetWinPanel('COL2_LIN1', 'WIN1_COL2_LIN1', 'LIN1'), .F.)
							
							oLayerAcao:AddLine('LIN1', 40, .F.)
								
								oLayerAcao:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
									
									// Apenas para Espaço
									
							oLayerAcao:AddLine('LIN2', 60, .F.)
								
								oLayerAcao:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
									
									oVinc := TBtnBmp():NewBar("DESTINOS", "DESTINOS",,,, {|| RelXmlPed()},, oLayerAcao:GetColPanel('COL1_LIN2', 'LIN2'),,,"",,,,,"")
									oVinc:cToolTip := "Vincular marcados"
									oVinc:Align    := CONTROL_ALIGN_TOP
									
									oVincAut := TBtnBmp():NewBar("FILTRO1", "FILTRO1",,,, {|| U_GOX1VA()},, oLayerAcao:GetColPanel('COL1_LIN2', 'LIN2'),,,"",,,,,"")
									oVincAut:cToolTip := "Vínculo Automático"
									oVincAut:Align    := CONTROL_ALIGN_TOP
									
									oLimpa := TBtnBmp():NewBar("SDUERASE", "SDUERASE",,,, {|| DesfazVinc()},, oLayerAcao:GetColPanel('COL1_LIN2', 'LIN2'),,,"",,,,,"")
									oLimpa:cToolTip := "Desfaz todos os vínculos"
									oLimpa:Align    := CONTROL_ALIGN_TOP
									
				oLayerPed:AddCollumn('COL3_LIN1', 48, .T., 'LIN1')
					
					oLayerPed:AddWindow('COL3_LIN1', 'WIN1_COL3_LIN1', "Itens Pedido de Compra", 100, .F., .T., , 'LIN1',)
						
						oLayerItPed := FWLayer():New()
						oLayerItPed:Init(oLayerPed:GetWinPanel('COL3_LIN1', 'WIN1_COL3_LIN1', 'LIN1'), .F.)
							
							oLayerItPed:AddLine('LIN1', 10, .F.)
								
								oLayerItPed:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
									
									oFilPed := TGet():New(002, 000, {|u| If(PCount() == 0, cFilPed, cFilPed := u ) }, oLayerItPed:GetColPanel('COL1_LIN1', 'LIN1'), 100, 010, "",, 0, 16777215,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F., /*F3*/, "cFilPed",,,, .T.,,, "Nº Pedido/Sol.", 2)
									oFilPed:bValid := {|| AtuPed()}
									//oFilPed:Align := CONTROL_ALIGN_LEFT
									
									// Trazer também Solicitações de Compra
									
									oChkPesPed := TCheckBox():New(004, 140, 'Pedido', , oLayerItPed:GetColPanel('COL1_LIN1', 'LIN1'), 70, 80, , , , , , , , .T., , , )
									oChkPesPed:cToolTip  := "Procura por pedidos de compra aberto do fornecedor"
									oChkPesPed:bSetGet   := {|| lPesqPed}
									oChkPesPed:bLClicked := {|| lPesqPed := !lPesqPed, AtuPed()}
									//oChkPesPed:Align := CONTROL_ALIGN_LEFT
									
									oChkPesSol := TCheckBox():New(004, 180, 'Solicitação', , oLayerItPed:GetColPanel('COL1_LIN1', 'LIN1'), 70, 80, , , , , , , , .T., , , )
									oChkPesSol:cToolTip  := "Procura Solicitações de compra abertas para "
									oChkPesSol:bSetGet   := {|| lPesqSol}
									oChkPesSol:bLClicked := {|| lPesqSol := !lPesqSol, AtuPed()}
									//oChkPesSol:Align := CONTROL_ALIGN_LEFT
									
									oChkFilPrd := TCheckBox():New(004, 220, 'Filtra Prd.', , oLayerItPed:GetColPanel('COL1_LIN1', 'LIN1'), 70, 80, , , , , , , , .T., , , )
									oChkFilPrd:cToolTip  := "Filtra Pedido com o Produto item do XML selecionado"
									oChkFilPrd:bSetGet   := {|| lFilPrd}
									oChkFilPrd:bLClicked := {|| lFilPrd := !lFilPrd, AtuPed()}
									
									If !GetNewPar("MV_ZPSSCPD", .F.)
										
										oChkPesPed:bWhen := {|| .F.}
										
										lPesqSol := .F.
										oChkPesSol:bWhen := {|| .F.}
										
									EndIf
									
							oLayerItPed:AddLine('LIN2', 80, .F.)
								
								oLayerItPed:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
									
									//-------------------- Browse Itens do XML
									
									CargaItPed(.F.)
									
									oBrwItPed := TCBrowse():New(50, 50, 200, 200,,,, oLayerItPed:GetColPanel('COL1_LIN2', 'LIN2'),,,,,,,,,,,, .T.,, .T.,)
									oBrwItPed:Align := CONTROL_ALIGN_ALLCLIENT
									oBrwItPed:nClrBackFocus := GetSysColor(13)
									oBrwItPed:nClrForeFocus := GetSysColor(14)
									oBrwItPed:SetArray(aItPed)
									
									oBrwItPed:AddColumn(TCColumn():New(""    , {|| aImgChk[aItPed[oBrwItPed:nAt, PED_SEL]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_SEL)
									
									ADD COLUMN TO oBrwItPed HEADER "Pedido/Sol" OEM DATA {|| aItPed[oBrwItPed:nAt, PED_NUMPED]} ALIGN LEFT SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Pedido", {|| aItPed[oBrwItPed:nAt, PED_NUMPED]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_NUMPED)
									
									ADD COLUMN TO oBrwItPed HEADER "Item Ped." OEM DATA {|| aItPed[oBrwItPed:nAt, PED_ITPED]} ALIGN LEFT SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Item Ped.", {|| aItPed[oBrwItPed:nAt, PED_ITPED]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_ITPED)
									
									ADD COLUMN TO oBrwItPed HEADER "Produto" OEM DATA {|| aItPed[oBrwItPed:nAt, PED_PROD]} ALIGN LEFT SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Produto", {|| aItPed[oBrwItPed:nAt, PED_PROD]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_PROD)
									
									ADD COLUMN TO oBrwItPed HEADER "Desc.Prod." OEM DATA {|| aItPed[oBrwItPed:nAt, PED_DESPROD]} ALIGN LEFT SIZE 60 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Desc.Prod.", {|| aItPed[oBrwItPed:nAt, PED_DESPROD]},,,, "RIGHT" , 60, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_DESPROD)
									
									ADD COLUMN TO oBrwItPed HEADER "Quant." OEM DATA {|| aItPed[oBrwItPed:nAt, PED_QTDE]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_QUANT")[2]) SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Quant.", {|| aItPed[oBrwItPed:nAt, PED_QTDE]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_QTDE)
									
									ADD COLUMN TO oBrwItPed HEADER "Val.Unit." OEM DATA {|| aItPed[oBrwItPed:nAt, PED_VUNIT]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_VUNIT")[2]) SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Val.Unit.", {|| aItPed[oBrwItPed:nAt, PED_VUNIT]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_VUNIT)
									
									ADD COLUMN TO oBrwItPed HEADER "Total" OEM DATA {|| aItPed[oBrwItPed:nAt, PED_TOTAL]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_TOTAL")[2]) SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Total", {|| aItPed[oBrwItPed:nAt, PED_TOTAL]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_TOTAL)
									
									ADD COLUMN TO oBrwItPed HEADER "Armazém" OEM DATA {|| aItPed[oBrwItPed:nAt, PED_LOCAL]} ALIGN LEFT PICTURE "" SIZE 25 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Total", {|| aItPed[oBrwItPed:nAt, PED_TOTAL]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_LOCAL)
									
									ADD COLUMN TO oBrwItPed HEADER "Emissão" OEM DATA {|| aItPed[oBrwItPed:nAt, PED_EMISSAO]} ALIGN LEFT SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Total", {|| aItPed[oBrwItPed:nAt, PED_EMISSAO]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_EMISSAO)
									
									ADD COLUMN TO oBrwItPed HEADER "Tipo" OEM DATA {|| aItPed[oBrwItPed:nAt, PED_TIPODES]} ALIGN LEFT SIZE 30 PIXELS
									//oBrwItPed:AddColumn(TCColumn():New("Desc.Prod.", {|| aItPed[oBrwItPed:nAt, PED_DESPROD]},,,, "RIGHT" , 60, .T., .F.,,,, .T.,))
									AAdd(aHeadItPed, PED_TIPODES)
									
									//SetDefHead(1)
									
									oBrwItPed:bLDblClick := {|| MarcReg(2)}
									
									//oBrwItPed:bHeaderClick := {|oObj, nCol| SortColumn(1, nCol, oObj)}
									
									oBrwItPed:GoTop()
									
									//////////////////////////////////////////
									
							oLayerItPed:AddLine('LIN3', 10, .F.)
								
								oLayerItPed:AddCollumn('COL1_LIN3', 100, .T., 'LIN3')

									oQtdTotP := TGet():New(002, 002, {|u| IF(Pcount() > 0, nQtdTotP := u, nQtdTotP)}, oLayerItPed:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_QUANT"), , , , , , , .T., , , {|| .F.}, , , , , , , "nQtdTotP", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Qtd Tot", 2, , )

									oVlrTotP := TGet():New(002, 062, {|u| IF(Pcount() > 0, nVlrTotP := u, nVlrTotP)}, oLayerItPed:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_TOTAL"), , , , , , , .T., , , {|| .F.}, , , , , , , "nVlrTotP", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Vlr Tot", 2, , )

									oQtdSelP := TGet():New(002, 122, {|u| IF(Pcount() > 0, nQtdSelP := u, nQtdSelP)}, oLayerItPed:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_QUANT"), , , , , , , .T., , , {|| .F.}, , , , , , , "nQtdSelP", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Qtd Sel", 2, , )

									oVlrSelP := TGet():New(002, 182, {|u| IF(Pcount() > 0, nVlrSelP := u, nVlrSelP)}, oLayerItPed:GetColPanel('COL1_LIN3', 'LIN3'), 040, 010, PesqPict("SD1", "D1_TOTAL"), , , , , , , .T., , , {|| .F.}, , , , , , , "nVlrSelP", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Vlr Sel", 2, , )

									/*ADD FIELD aFldToTP TITULO "Qtd Tot" CAMPO "QTDTOTP"  TIPO "N" TAMANHO TamSX3("D1_QUANT")[1] DECIMAL TamSX3("D1_QUANT")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->QTDTOTP := 0
									
									ADD FIELD aFldToTP TITULO "Vlr Tot" CAMPO "VLRTOTP"  TIPO "N" TAMANHO TamSX3("D1_TOTAL")[1] DECIMAL TamSX3("D1_TOTAL")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->VLRTOTP := 0

									ADD FIELD aFldToTP TITULO "Qtd Sel" CAMPO "QTDSELP"  TIPO "N" TAMANHO TamSX3("D1_QUANT")[1] DECIMAL TamSX3("D1_QUANT")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->QTDSELP := 0
									
									ADD FIELD aFldToTP TITULO "Vlr Sel" CAMPO "VLRSELP"  TIPO "N" TAMANHO TamSX3("D1_TOTAL")[1] DECIMAL TamSX3("D1_TOTAL")[2] PICTURE PesqPict("SD1", "D1_QUANT") VALID .T. NIVEL 1 WHEN .F. //F3 "SF1"
									M->VLRSELP := 0

									oTotPed := MsMGet():New(,, 4,,,,, {0,0,0,0},,,,,, oLayerItPed:GetColPanel('COL1_LIN3', 'LIN3'),,.T.,,,,.T., aFldToTP,,.T.,,,.T.)
									
									oTotPed:oBox:Align := CONTROL_ALIGN_ALLCLIENT*/

			oLayerPed:AddLine('LIN2', 35, .F.)
				
				oLayerPed:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
					
					oLayerPed:AddWindow('COL1_LIN2', 'WIN1_COL1_LIN2', "Itens Vinculados", 100, .F., .T., , 'LIN2',)
						
						//-------------------- Browse Itens do XML
						
						oBrwItVin := TCBrowse():New(50, 50, 200, 200,,,, oLayerPed:GetWinPanel('COL1_LIN2', 'WIN1_COL1_LIN2', 'LIN2'),,,,,,,,,,,, .T.,, .T.,)
						oBrwItVin:Align := CONTROL_ALIGN_ALLCLIENT
						oBrwItVin:nClrBackFocus := GetSysColor(13)
						oBrwItVin:nClrForeFocus := GetSysColor(14)
						oBrwItVin:SetArray(aItVin)
						
						oBrwItVin:AddColumn(TCColumn():New("Exc.", {|| aImgExc[aItVin[oBrwItVin:nAt, VIN_EXC]]},,,, "RIGHT" , 10, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_EXC)
						
						ADD COLUMN TO oBrwItVin HEADER "Item XML" OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_ITEM]} ALIGN LEFT SIZE 100 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Item XML", {|| aItVin[oBrwItVin:nAt, VIN_ITEM]},,,, "RIGHT" , 100, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_ITEM)
						
						ADD COLUMN TO oBrwItVin HEADER "Produto" OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_PROD]} ALIGN LEFT SIZE 30 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Produto", {|| aItVin[oBrwItVin:nAt, VIN_PROD]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_PROD)
						
						ADD COLUMN TO oBrwItVin HEADER "Desc.Prod." OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_DESPROD]} ALIGN LEFT SIZE 60 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Desc.Prod.", {|| aItVin[oBrwItVin:nAt, VIN_DESPROD]},,,, "RIGHT" , 60, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_DESPROD)
						
						ADD COLUMN TO oBrwItVin HEADER "Pedido/Sol" OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_PED]} ALIGN LEFT SIZE 30 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Pedido", {|| aItVin[oBrwItVin:nAt, VIN_PED]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_PED)
						
						ADD COLUMN TO oBrwItVin HEADER "Item Ped." OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_ITPED]} ALIGN LEFT SIZE 30 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Item Ped.", {|| aItVin[oBrwItVin:nAt, VIN_ITPED]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_ITPED)
						
						ADD COLUMN TO oBrwItVin HEADER "Qtde." OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_QTDE]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_QUANT")[2]) SIZE 30 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Qtde.", {|| aItVin[oBrwItVin:nAt, VIN_QTDE]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_QTDE)
						
						ADD COLUMN TO oBrwItVin HEADER "Val.Unit." OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_VUNIT]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_VUNIT")[2]) SIZE 30 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Val.Unit.", {|| aItVin[oBrwItVin:nAt, VIN_VUNIT]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_VUNIT)
						
						ADD COLUMN TO oBrwItVin HEADER "Total" OEM DATA {|| aItVin[oBrwItVin:nAt, VIN_TOTAL]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_TOTAL")[2]) SIZE 30 PIXELS
						//oBrwItVin:AddColumn(TCColumn():New("Total", {|| aItVin[oBrwItVin:nAt, VIN_TOTAL]},,,, "RIGHT" , 30, .T., .F.,,,, .T.,))
						AAdd(aHeadItVin, VIN_TOTAL)
						
						//SetDefHead(1)
						
						oBrwItVin:bLDblClick := {|oObj, nCol| IIf(nCol == 1, ExcVinc(), .T.)}
						
						//oBrwItVin:bHeaderClick := {|oObj, nCol| SortColumn(1, nCol, oObj)}
						
						oBrwItVin:GoTop()
						
						//////////////////////////////////////////
						
			oLayerPed:AddLine('LIN3', 5, .F.)
				
				oLayerPed:AddCollumn('COL1_LIN3', 100, .T., 'LIN3')
					
					oPanelBot := tPanel():New(0,0,"",oLayerPed:GetColPanel('COL1_LIN3', 'LIN3'),,,,,RGB(239,243,247),000,015)
					oPanelBot:Align	:= CONTROL_ALIGN_BOTTOM
					
					oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgPed:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oLimp := THButton():New(0, 0, "Confirmar Seleção", oPanelBot, {|| IIf(ConfSel(), oDlgPed:End(), )}, , , )
					oLimp:nWidth  := 100
					oLimp:nHeight := 10
					oLimp:Align := CONTROL_ALIGN_RIGHT
					oLimp:SetColor(RGB(002, 070, 112), )
					
//					oSol := THButton():New(0, 0, "Pedido por Solicitação", oPanelBot, {|| PedSol()}, , , )
//					oSol:nWidth  := 120
//					oSol:nHeight := 10
//					oSol:Align := CONTROL_ALIGN_RIGHT
//					oSol:SetColor(RGB(002, 070, 112), )
	
		SetKey(VK_F7, {|| RelXmlPed()})
					
	ACTIVATE MSDIALOG oDlgPed CENTERED //ON INIT EnchoiceBar(oDlgPed, {|| Alert("Em construção")}, {|| oDlgPed:End()},, /*aNewButton*/)
	
Return

Static Function AtuXml()
	
	CargaItXml()
	
	oBrwItXml:SetArray(aItXml)
	
	oBrwItXml:Refresh()

	nQtdSelX := 0
	oQtdSelX:Refresh()

	nVlrSelX := 0
	oVlrSelX:Refresh()

Return

Static Function CargaItXml(lRefresh)
	
	Local nI
	Local cMaskQ := "@E 9,999,999." + Replicate("9", TamSX3("D1_QUANT")[2])
	Local cMaskV := "@E 9,999,999." + Replicate("9", TamSX3("D1_VUNIT")[2])
	Local cMaskT := "@E 9,999,999." + Replicate("9", TamSX3("D1_TOTAL")[2])
	
	Default lRefresh := .T.

	ASize(aItXml, 0)
	
	aItXml := {}
	
	nQtdTotX := 0
	nVlrTotX := 0

	// Cria conforme itens do objeto da tela aterior
	
	For nI := 1 To Len(oGetD:aCols)
		
		If AScan(aRelac, {|x| AScan(x[1], {|y| y == nI}) > 0}) == 0 .And. IIf(Empty(cFilXml), .T., ;
			(Upper(AllTrim(cFilXml)) $ Upper(GDFieldGet(_cCmp2 + "_DESC", nI,, oGetD:aHeader, oGetD:aCols)) .Or. ;
			Upper(AllTrim(cFilXml)) $ Upper(GDFieldGet(_cCmp2 + "_DSPROD", nI,, oGetD:aHeader, oGetD:aCols))))
			
			nQtdTotX += GDFieldGet(_cCmp2 + "_QUANT2", nI,, oGetD:aHeader, oGetD:aCols)
			nVlrTotX += GDFieldGet(_cCmp2 + "_TOTAL", nI,, oGetD:aHeader, oGetD:aCols)
	
			AAdd(aItXml, {;
				2, ;
				GDFieldGet(_cCmp2 + "_DESC", nI,, oGetD:aHeader, oGetD:aCols), ;
				GDFieldGet(_cCmp2 + "_COD", nI,, oGetD:aHeader, oGetD:aCols), ;
				GDFieldGet(_cCmp2 + "_DSPROD", nI,, oGetD:aHeader, oGetD:aCols), ;
				GDFieldGet(_cCmp2 + "_QUANT2", nI,, oGetD:aHeader, oGetD:aCols), ;
				GDFieldGet(_cCmp2 + "_VUNIT", nI,, oGetD:aHeader, oGetD:aCols), ;
				GDFieldGet(_cCmp2 + "_TOTAL", nI,, oGetD:aHeader, oGetD:aCols), ;
				nI, ;
				GetCCus1(nI)})
			
		EndIf
		
	Next nI
	
	If lRefresh

		oQtdTotX:Refresh()
		oVlrTotX:Refresh()

	EndIf

	If Empty(aItXml)
		
		AAdd(aItXml, {2, "", "", "", "", "", "", "", ""})
		
	EndIf
	
Return

Static Function AtuPed()
	
	CargaItPed()
	
	oBrwItPed:SetArray(aItPed)
	
	oBrwItPed:Refresh()
	
	nQtdSelP := 0
	oQtdSelP:Refresh()

	nVlrSelP := 0
	oVlrSelP:Refresh()

Return

Static Function CargaItPed(lRefresh)
	
	Local nPed
	Local lAllFor := GetNewPar("MV_ZPDXMAF", .T.)
	Local aFor
	Local cPed := AllTrim(cFilPed)
	
	Local cQuery
	Local cAlias
	
	Local cInFor := ""
	
	Default lRefresh := .T.
	
	If lAllFor
		
		aFor := U_GOX1ALLF(Posicione("SA2", 1, xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI"), "A2_CGC"))
		
	Else
		
		aFor := {{(_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"), Posicione("SA2", 1, xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI"), "A2_MSBLQL")}}
		
	EndIf
	
	ASize(aItPed, 0)
	
	aItPed := {}
	
	nQtdTotP := 0
	nVlrTotP := 0

	// Busca pedidos na SC7
	
	If lPesqPed
		
		//dbSelectArea("SC7")
		//SC7->( dbSetOrder(3) )
		
		//dbSelectArea("SB1")
		//SB1->( dbSetOrder(1) )
		
		cInFor := " AND ( "
		
		For nPed := 1 To Len(aFor)
			
			If nPed == 1
				
				cInFor += "( C7.C7_FORNECE = '" + aFor[nPed][1] + "' AND C7.C7_LOJA = '" + aFor[nPed][2] + "')"
				
			Else
				
				cInFor += " OR ( C7.C7_FORNECE = '" + aFor[nPed][1] + "' AND C7.C7_LOJA = '" + aFor[nPed][2] + "')"
				
			EndIf
			
			/*If SC7->( dbSeek(xFilial("SC7") + aFor[nPed][1] + aFor[nPed][2] + cPed) )
				
				SB1->( dbSeek(xFilial("SB1") + SC7->C7_PRODUTO) )
				
				While !SC7->( Eof() ) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_FORNECE == aFor[nPed][1] .And. SC7->C7_LOJA == aFor[nPed][2] .And. ;
					IIf(Empty(cPed), .T., ;
					(SC7->C7_NUM == cPed .Or. ;
					Upper(AllTrim(cPed)) $ Upper(SC7->C7_PRODUTO) .Or. ;
					Upper(AllTrim(cPed)) $ Upper(SB1->B1_DESC)))
					//IIf(Empty(cPed), .T., SC7->C7_NUM == cPed)
					
					If SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA > 0 .And. Empty(SC7->C7_RESIDUO) .And. SC7->C7_TPOP <> 'P' .And. SC7->C7_CONAPRO # "B"
						
						If AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == SC7->C7_NUM .And. y[2] == SC7->C7_ITEM .And. y[4] == "P"}) > 0}) == 0
							
							nQtdTotP += (SC7->C7_QUANT - SC7->C7_QUJE)
							nVlrTotP += SC7->C7_TOTAL

							AAdd(aItPed, {;
								2, ;
								SC7->C7_NUM, ;
								SC7->C7_ITEM, ;
								SC7->C7_PRODUTO, ;
								SC7->C7_DESCRI, ;
								(SC7->C7_QUANT - SC7->C7_QUJE), ;
								SC7->C7_PRECO, ;
								SC7->C7_TOTAL, ;
								SC7->C7_EMISSAO, ;
								"Pedido", ;
								"P"})
							
						EndIf
						
					EndIf
					
					SC7->( dbSkip() )
					
				EndDo
				
			EndIf*/
			
		Next nPed
		
		cInFor += ") "
		
		cQuery := " SELECT "
		cQuery += " C7.C7_NUM, C7.C7_ITEM, C7.C7_PRODUTO, C7.C7_DESCRI, C7.C7_QUANT, C7.C7_QUJE, C7.C7_PRECO, C7.C7_TOTAL, C7.C7_EMISSAO, C7.C7_LOCAL "
		cQuery += " FROM " + RetSqlName("SC7") + " C7 "
		//cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = C7.C7_PRODUTO AND B1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE C7.D_E_L_E_T_ = ' ' AND C7.C7_FILIAL = '" + xFilial("SC7") + "' "
		cQuery += " 	AND (C7.C7_QUANT - C7.C7_QUJE - C7.C7_QTDACLA) > 0 AND C7.C7_RESIDUO = ' ' AND C7.C7_TPOP <> 'P' AND C7.C7_CONAPRO <> 'B' "
		cQuery += cInFor
		
		If lFilPrd .And. !Empty(aItXml[oBrwItXml:nAt, XML_PROD])
			
			cQuery += " 	AND C7.C7_PRODUTO = '" + aItXml[oBrwItXml:nAt, XML_PROD] + "' "
			
		EndIf
		
		If !Empty(cPed)
			
			cQuery += " AND (C7.C7_NUM = '" + cPed + "' OR C7.C7_PRODUTO LIKE '%" + Upper(AllTrim(cPed)) + "%' OR C7.C7_DESCRI LIKE '%" + Upper(AllTrim(cPed)) + "%') "
			
		EndIf
		
		cAlias := MpSysOpenQuery(cQuery)
		
		While !(cAlias)->( Eof() )
			
			If AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == (cAlias)->C7_NUM .And. y[2] == (cAlias)->C7_ITEM .And. y[4] == "P"}) > 0}) == 0
				
				nQtdTotP += ((cAlias)->C7_QUANT - (cAlias)->C7_QUJE)
				nVlrTotP += (cAlias)->C7_TOTAL

				AAdd(aItPed, {;
					2, ;
					(cAlias)->C7_NUM, ;
					(cAlias)->C7_ITEM, ;
					(cAlias)->C7_PRODUTO, ;
					(cAlias)->C7_DESCRI, ;
					((cAlias)->C7_QUANT - (cAlias)->C7_QUJE), ;
					(cAlias)->C7_PRECO, ;
					(cAlias)->C7_TOTAL, ;
					SToD((cAlias)->C7_EMISSAO), ;
					"Pedido", ;
					"P", ;
					(cAlias)->C7_LOCAL})
				
			EndIf
			
			(cAlias)->( dbSkip() )
			
		EndDo
		
		(cAlias)->( dbCloseArea() )
		
	EndIf
	
	If lPesqSol
		
		cQuery := " SELECT "
		cQuery += " C1.C1_NUM, C1.C1_ITEM, C1.C1_PRODUTO, C1.C1_DESCRI, C1.C1_QUANT, C1.C1_QUJE, "
		cQuery += " C1.C1_PRECO, C1.C1_TOTAL, C1.C1_EMISSAO, C1.C1_LOCAL "
		cQuery += " FROM " + RetSqlName("SC1") + " C1 "
		cQuery += " WHERE C1.D_E_L_E_T_ = ' ' AND C1.C1_FILIAL = '" + xFilial("SC1") + "' "
		cQuery += " 	AND (C1.C1_QUANT - C1.C1_QUJE) > 0 AND C1.C1_RESIDUO = ' ' "
		cQuery += " 	AND C1.C1_PEDIDO = ' ' "
		
		If !Empty(cPed)
			
			cQuery += " AND C1.C1_NUM = '" + cPed + "' "
			
		EndIf
		
		If lFilPrd .And. !Empty(aItXml[oBrwItXml:nAt, XML_PROD])
			
			cQuery += " 	AND C1.C1_PRODUTO = '" + aItXml[oBrwItXml:nAt, XML_PROD] + "' "
			
		EndIf
		
		cAlias := MpSysOpenQuery(cQuery)
		
		While !(cAlias)->( Eof() )
			
			If AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == (cAlias)->C1_NUM .And. y[2] == (cAlias)->C1_ITEM .And. y[4] == "S"}) > 0}) == 0
				
				nQtdTotP += ((cAlias)->C1_QUANT - (cAlias)->C1_QUJE)
				nVlrTotP += (cAlias)->C1_TOTAL

				AAdd(aItPed, {;
					2, ;
					(cAlias)->C1_NUM, ;
					(cAlias)->C1_ITEM, ;
					(cAlias)->C1_PRODUTO, ;
					(cAlias)->C1_DESCRI, ;
					((cAlias)->C1_QUANT - (cAlias)->C1_QUJE), ;
					(cAlias)->C1_PRECO, ;
					(cAlias)->C1_TOTAL, ;
					STod((cAlias)->C1_EMISSAO), ;
					"Solicitação", ;
					"S", ;
					(cAlias)->C1_LOCAL})
				
			EndIf
			
			(cAlias)->( dbSkip() )
			
		EndDo
		
		(cAlias)->( dbCloseArea() )
		
	EndIf
	
	If lRefresh

		oQtdTotP:Refresh()
		oVlrTotP:Refresh()

	EndIf

	//---------------------
	
	If Empty(aItPed)
		
		AAdd(aItPed, {2, "", "", "", "", "", "", "", CToD("  /  /    "), "", "", ""})
		
	EndIf
	
Return

Static Function AtuVin()
	
	CargaItVin()
	
	oBrwItVin:SetArray(aItVin)
	
	oBrwItVin:Refresh()
	
Return

Static Function CargaItVin()
	
	Local nI
	Local cPedido  
	Local cItemPed
	
	ASize(aItVin, 0)
	
	aItVin := {}
	
	//VinByRelac()
	
	dbSelectArea("SC7")
	SC7->( dbSetOrder(1) )
	
	For nI := 1 To Len(oGetD:aCols)
		
		cPedido  := GDFieldGet(_cCmp2 + "_PEDIDO", nI,, oGetD:aHeader, oGetD:aCols)
		cItemPed := GDFieldGet(_cCmp2 + "_ITEMPC", nI,, oGetD:aHeader, oGetD:aCols)
	
		If !Empty(cPedido) .And. !Empty(cItemPed) .And. ;
			SC7->( dbSeek(xFilial("SC7") + cPedido + cItemPed) )
			
			AAdd(aRelac, {{nI}, {{SC7->C7_NUM, SC7->C7_ITEM, 0, "P", GDFieldGet(_cCmp2 + "_QUANT2", nI,, oGetD:aHeader, oGetD:aCols)}}})
			
			AAdd(aItVin, {;
				1, ;
				GDFieldGet(_cCmp2 + "_DESC", nI,, oGetD:aHeader, oGetD:aCols), ;
				SC7->C7_PRODUTO, ;
				SC7->C7_DESCRI, ;
				SC7->C7_NUM, ;
				SC7->C7_ITEM, ;
				GDFieldGet(_cCmp2 + "_QUANT2", nI,, oGetD:aHeader, oGetD:aCols), ;
				GDFieldGet(_cCmp2 + "_VUNIT", nI,, oGetD:aHeader, oGetD:aCols), ;
				GDFieldGet(_cCmp2 + "_TOTAL", nI,, oGetD:aHeader, oGetD:aCols), ;
				Len(aRelac), ;
				"P"})
			
		EndIf
		
	Next nI
	
	If Empty(aItVin)
		
		AAdd(aItVin, {1, "", "", "", "", "", "", "", "", 0, ""})
		
	EndIf
	
Return 

Static Function ExcVinc()
	
	Local nI
	Local nX
	Local nPosRel := aItVin[oBrwItVin:nAt][VIN_RELAC]
	Local nAtVin  := oBrwItVin:nAt
	
	If nPosRel > 0
		
		If Len(aRelac[nPosRel][2]) > 1 //Desmembrado
			
			nX := 1
			
			While nX <= Len(aItVin)
				
				If nAtVin # nX .And. aItVin[nX][VIN_RELAC] == nPosRel
					
					ADel(aItVin, nX)
					ASize(aItVin, Len(aItVin) - 1)
					nX--
					
					If nAtVin > nX
						nAtVin--
					EndIf
					
				EndIf
				
				nX++
				
			EndDo
			
		EndIf
		
		ADel(aRelac, nPosRel)
		ASize(aRelac, Len(aRelac) - 1)
		
		For nI := (nAtVin + 1) To Len(aItVin)
			
			aItVin[nI][VIN_RELAC]--
			
		Next nI
		
		//-------------------------
		ADel(aItVin, nAtVin)
		ASize(aItVin, Len(aItVin) - 1)
		
		If Empty(aItVin)
			
			aItVin := {}
			
			AAdd(aItVin, {1, "", "", "", "", "", "", "", "", 0, ""})
			
		EndIf
		
		oBrwItVin:SetArray(aItVin)
	
		oBrwItVin:Refresh()
		//-------------------------
		
		//AtuVin()
		AtuXml()
		AtuPed()
		
	EndIf
	
Return

Static Function MarcReg(nType)
	
	Local nI
	
	If nType == 1 // Xml
		
		If Len(oBrwItXml:aArray) == 1 .And. Empty(oBrwItXml:aArray[1][XML_ITEM])
			
			Return .F.
			
		EndIf
		
		oBrwItXml:aArray[oBrwItXml:nAt][XML_SEL] := 3 - oBrwItXml:aArray[oBrwItXml:nAt][XML_SEL]
		
		aItXml := AClone(oBrwItXml:aArray)
		
		oBrwItXml:Refresh()

		If oBrwItXml:aArray[oBrwItXml:nAt][XML_SEL] == 1 //Marcado

			nQtdSelX += oBrwItXml:aArray[oBrwItXml:nAt][XML_QTDE]

			nVlrSelX += oBrwItXml:aArray[oBrwItXml:nAt][XML_TOTAL]

		Else // Desmarcado

			nQtdSelX -= oBrwItXml:aArray[oBrwItXml:nAt][XML_QTDE]

			nVlrSelX -= oBrwItXml:aArray[oBrwItXml:nAt][XML_TOTAL]

		EndIf

		oQtdSelX:Refresh()
		oVlrSelX:Refresh()

	ElseIf nType == 2 // Pedido
		
		If Len(oBrwItPed:aArray) == 1 .And. Empty(oBrwItPed:aArray[1][PED_NUMPED])
			
			Return .F.
			
		EndIf
		
		oBrwItPed:aArray[oBrwItPed:nAt][PED_SEL] := 3 - oBrwItPed:aArray[oBrwItPed:nAt][PED_SEL]
		
		aItPed := AClone(oBrwItPed:aArray)
		
		oBrwItPed:Refresh()

		If oBrwItPed:aArray[oBrwItPed:nAt][PED_SEL] == 1 //Marcado

			nQtdSelP += oBrwItPed:aArray[oBrwItPed:nAt][PED_QTDE]

			nVlrSelP += oBrwItPed:aArray[oBrwItPed:nAt][PED_TOTAL]

		Else // Desmarcado

			nQtdSelP -= oBrwItPed:aArray[oBrwItPed:nAt][PED_QTDE]

			nVlrSelP -= oBrwItPed:aArray[oBrwItPed:nAt][PED_TOTAL]

		EndIf

		oQtdSelP:Refresh()
		oVlrSelP:Refresh()
		
	EndIf
	
Return 

Static Function RelXmlPed()
	
	Local aXmlSel := {}
	Local aPedSel := {}
	Local nXml
	Local nPed
	Local lDesmembra := .F.
	Local nDecimal := TamSX3("D1_VUNIT")[2]
	
	Local nTotQtdX := 0
	Local nTotQtdP := 0
	
	Local cProdAux
	Local cDescAux
	
	For nXml := 1 To Len(aItXml)
		
		If aItXml[nXml][XML_SEL] == 1
			
			nTotQtdX += aItXml[nXml][XML_QTDE]
			
			AAdd(aXmlSel, aItXml[nXml])
			
		EndIf
		
	Next nXml
	
	For nPed := 1 To Len(aItPed)
		
		If aItPed[nPed][PED_SEL] == 1
			
			nTotQtdP += aItPed[nPed][PED_QTDE]
			
			AAdd(aPedSel, aItPed[nPed])
			
		EndIf
		
	Next nPed
	
	// Descontinuado, pois tem casos que vem um pouquinho a mais na quantidade que é aceito.
	/*If nTotQtdX > nTotQtdP
		
		If !MsgYesNo("As quantidades dos itens dos XML marcados são maiores do que do pedidos selecionados. Deseja continuar?")
			
			Return .F.
			
		EndIf
		
	EndIf*/
	
	If Len(aXmlSel) == 0
		
		Alert("É necessário selecionar um item do XML.")
		
		Return .F.
		
	EndIf
	
	If Len(aPedSel) == 0
		
		Alert("É necessário selecionar um item do pedido de compra.")
		
		Return .F.
		
	ElseIf Len(aPedSel) > 1
		
		For nPed := 1 To Len(aPedSel)
			
			If aPedSel[nPed][PED_TOTAL] == 0
				
				Alert("Não se pode desmembrar itens com pedidos que possuam total igual a zero.")
				
				Return .F.
				
			EndIf
			
		Next nPed
		
		If Len(aXmlSel) > 1
			
			Alert("Quando selecionado mais de 1 pedido de compra você deve selecionar apenas 1 item para desmembrar.")
			
			Return .F.
			
		Else
			
			lDesmembra := .T.
			
		EndIf
		
	EndIf
	
	If Len(aItVin) == 1 .And. Empty(aItVin[1][VIN_ITEM])
		
		ASize(aItVin, 0)
		
		aItVin := {}
		
	EndIf
	
	If lDesmembra
		
		_nTotPed := 0
		_nTotQtd := 0
		_nTotRat := 0
		_nTotQXM := aXmlSel[1][XML_QTDE]
		_nXmlPrc := aXmlSel[1][XML_VUNIT]
		_nXMLTot := aXmlSel[1][XML_TOTAL]
		_nRat  := 0
		
		For nPed := 1 To Len(aPedSel)
			
			_nTotPed += aPedSel[nPed][PED_TOTAL]
			_nTotQtd += aPedSel[nPed][PED_QTDE]
			
		Next nPed
		
		For nPed := 1 To Len(aPedSel)
			
			If aPedSel[nPed][PED_QTDE] < _nTotQXM
				
				_nTotQXM -= aPedSel[nPed][PED_QTDE]
				
				_nQtdAux := aPedSel[nPed][PED_QTDE]
				
			Else
				
				_nQtdAux := _nTotQXM
				
			EndIf
			
			//_nRat := Round((aXmlSel[1][XML_TOTAL] * aPedSel[nPed][PED_TOTAL]) / _nTotPed, 2)
			_nRat := Round(_nQtdAux * _nXmlPrc, 2)
			
			_nTotRat += _nRat
			
			If nPed == 1
				AAdd(aRelac, {{aXmlSel[1][XML_POS]}, {{aPedSel[nPed][PED_NUMPED], aPedSel[nPed][PED_ITPED], _nRat, aPedSel[nPed][PED_TIPO], _nQtdAux}}})
			Else
				AAdd(ATail(aRelac)[2], {aPedSel[nPed][PED_NUMPED], aPedSel[nPed][PED_ITPED], _nRat, aPedSel[nPed][PED_TIPO], _nQtdAux})
			EndIf
			
			// Verificar se precisa mesmooooooooo
			/*If nPed == Len(aPedSel) .And. _nTotRat # _nXMLTot
				
				_nRat += _nXMLTot - _nTotRat
				
			EndIf*/
			
			/*If aPedSel[nPed][PED_TIPO] == "S" .And. !Empty(aXmlSel[1][XML_PROD])
				
				cProdAux := aXmlSel[1][XML_PROD]
				cDescAux := aXmlSel[1][XML_DESPROD]
				
			Else*/
				
				cProdAux := aPedSel[nPed][PED_PROD]
				cDescAux := aPedSel[nPed][PED_DESPROD]
				
			//EndIf
			
			AAdd(aItVin, {;
				1, ;
				aXmlSel[1][XML_ITEM], ;
				cProdAux, ;
				cDescAux, ;
				aPedSel[nPed][PED_NUMPED], ;
				aPedSel[nPed][PED_ITPED], ;
				_nQtdAux, ; //aXmlSel[1][XML_QTDE], ;
				_nXmlPrc, ;//aXmlSel[1][XML_VUNIT], ; //aPedSel[nPed][PED_VUNIT], ;
				_nRat, ;//aXmlSel[1][XML_TOTAL], ; //aPedSel[nPed][PED_TOTAL], ;
				Len(aRelac), ;
				aPedSel[nPed][PED_TIPO]})
			
		Next nPed
		
		If (aXmlSel[1][XML_TOTAL] - _nTotRat) > 0
			
			ATail(aItVin)[VIN_TOTAL] += (aXmlSel[1][XML_TOTAL] - _nTotRat)
			
			ATail(ATail(aRelac)[2])[3] += (aXmlSel[1][XML_TOTAL] - _nTotRat)
			
		EndIf
		
	Else
	
		For nXml := 1 To Len(aXmlSel)
			
			AAdd(aRelac, {{aXmlSel[nXml][XML_POS]}, {{aPedSel[1][PED_NUMPED], aPedSel[1][PED_ITPED], 0, aPedSel[1][PED_TIPO], aXmlSel[nXml][XML_QTDE]}}})
			
			If aPedSel[1][PED_TIPO] == "S" .And. !Empty(aXmlSel[nXml][XML_PROD])
				
				If aXmlSel[nXml][XML_PROD] # aPedSel[1][PED_PROD]

					If Aviso("Produto Diferente", "O Produto da Solicitação é o (" + AllTrim(aPedSel[1][PED_PROD]) + " - " + AllTrim(aPedSel[1][PED_DESPROD]) + ")" + ;
						" enquanto o do XML é o (" + AllTrim(aXmlSel[nXml][XML_PROD]) + " - " + AllTrim(aXmlSel[nXml][XML_DESPROD]) + "). Deseja usar o produto do XML ou da Solicitação?", {"Usar do XML", "Usar da Solicitação"}, 3) == 1

						cProdAux := aXmlSel[nXml][XML_PROD]
						cDescAux := aXmlSel[nXml][XML_DESPROD]

					Else

						cProdAux := aPedSel[1][PED_PROD]
						cDescAux := aPedSel[1][PED_DESPROD]

					EndIf

				Else

					cProdAux := aXmlSel[nXml][XML_PROD]
					cDescAux := aXmlSel[nXml][XML_DESPROD]

				EndIf
				
			Else
				
				cProdAux := aPedSel[1][PED_PROD]
				cDescAux := aPedSel[1][PED_DESPROD]
				
			EndIf
			
			AAdd(aItVin, {;
				1, ;
				aXmlSel[nXml][XML_ITEM], ;
				cProdAux, ;
				cDescAux, ;
				aPedSel[1][PED_NUMPED], ;
				aPedSel[1][PED_ITPED], ;
				aXmlSel[nXml][XML_QTDE], ;
				aXmlSel[nXml][XML_VUNIT], ;
				aXmlSel[nXml][XML_TOTAL], ;
				Len(aRelac), ;
				aPedSel[1][PED_TIPO]})
			
		Next nXml
		
	EndIf
	
	oBrwItVin:SetArray(aItVin)
	
	oBrwItVin:Refresh()
	
	AtuXml()
	
	AtuPed()
	
Return .T.

/*Static Function VinByRelac()
	
	Local nRel
	
	For nRel := 1 To Len(aRelac)
		
		
		
	Next nRel
	
Return*/

Static Function DesfazVinc()
	
	Local nI
	
	ASize(aRelac, 0)
	aRelac := {}
	
	ASize(aItVin, 0)
	aItVin := {}
	
	AAdd(aItVin, {1, "", "", "", "", "", "", "", "", 0, ""})
	
	oBrwItXml:GoTop()
	
	oBrwItVin:Refresh()
	
	AtuXml()
	AtuPed()
	
Return

//Static Function VincAut(lBusca, lCalc)
User Function GOX1VA(lBusca, lCalc)
	
	Local nI
	Local nX
	Local nZ
	
	Local nW

	Local aTotPed := {/*{pedido, valor total}*/}
	Local nPosPed
	Local aRelacAux

	Local nTolVinc
	
	Local aMatch := {}
	Local nPosMatch
	
	Default lBusca := .F.
	Default lCalc  := .T.

	If Empty(aItXml[1][XML_TOTAL]) .Or. Empty(aItPed[1][PED_NUMPED])
		
		If !lBusca
			Alert("Para vincular automaticamente é preciso ter item do XML e do pedido disponíveis para verificação.")
		EndIf
		
		Return
		
	EndIf
	
	ASort(aItXml,,, {|x, y| x[XML_PROD] > y[XML_PROD]})
	
	ASort(aItPed,,, {|x, y| x[PED_EMISSAO] < y[PED_EMISSAO]})
	
	If Len(aItVin) == 1 .And. Empty(aItVin[1][VIN_ITEM])
		
		ASize(aItVin, 0)
		
		aItVin := {}
		
	EndIf
	
	For nI := 1 To Len(aItXml)
		
		If AScan(aRelac, {|x| AScan(x[1], {|y| y == aItXml[nI][XML_POS]}) > 0}) == 0

			For nX := 1 To Len(aItPed)
				
				//----------------------------
				// Busca pelo total de pedidos
				//----------------------------

				lAchou := .F.

				aTotPed := {}
				
				For nZ := 1 To Len(aItPed)

					If aItPed[nZ][PED_NUMPED] == aItPed[nX][PED_NUMPED]
						
						If AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nZ][PED_NUMPED] .And. y[2] == aItPed[nZ][PED_ITPED] .And. y[4] == aItPed[nZ][PED_TIPO]}) > 0}) == 0
						
							nPosPed := AScan(aTotPed, {|x| x[1] == aItPed[nZ][PED_NUMPED] .And. x[3] == aItPed[nZ][PED_TIPO]})

							If nPosPed > 0

								aTotPed[nPosPed][2] += aItPed[nZ][PED_TOTAL]

								AAdd(aTotPed[nPosPed][4], aItPed[nZ][PED_ITPED])

							Else
								
								AAdd(aTotPed, {aItPed[nZ][PED_NUMPED], aItPed[nZ][PED_TOTAL], aItPed[nZ][PED_TIPO], {aItPed[nZ][PED_ITPED]}})

							EndIf

						EndIf

					EndIf

				Next nZ

				For nZ := 1 To Len(aTotPed)

					If aItXml[nI][XML_TOTAL] == aTotPed[nZ][2] .And. Len(aTotPed[nZ][4]) > 1

						aRelacAux := {}
						
						For nW := 1 To Len(aItPed)

							If aItPed[nW][PED_NUMPED] == aTotPed[nZ][1] .And. AScan(aTotPed[nZ][4], {|x| x == aItPed[nW][PED_ITPED]}) > 0
								
								AAdd(aRelacAux, {aItPed[nW][PED_NUMPED], aItPed[nW][PED_ITPED], aItPed[nW][PED_TOTAL], aItPed[nW][PED_TIPO], aItPed[nW][PED_QTDE]})

								AAdd(aItVin, {;
									1, ;
									aItXml[nI][XML_ITEM], ;
									aItPed[nW][PED_PROD], ;
									aItPed[nW][PED_DESPROD], ;
									aItPed[nW][PED_NUMPED], ;
									aItPed[nW][PED_ITPED], ;
									aItPed[nW][PED_QTDE], ;
									aItPed[nW][PED_VUNIT], ;
									aItPed[nW][PED_TOTAL], ;
									Len(aRelac) + 1, ;
									aItPed[nW][PED_TIPO]})

							EndIf

						Next nW
						
						AAdd(aRelac, {{aItXml[nI][XML_POS]}, aRelacAux})
						
						lAchou := .T.

						Exit

					EndIf

				Next nZ

				If lAchou

					Exit 

				EndIf
				
			Next nX
			
		EndIf
		
	Next nI
				
	For nI := 1 To Len(aItXml)
		
		aMatch := {}
		
		If AScan(aRelac, {|x| AScan(x[1], {|y| y == aItXml[nI][XML_POS]}) > 0}) == 0

			For nX := 1 To Len(aItPed)
				
				//------------------------------------
				// Procura com produto igual, valor unitário igual, quantidade igual e pelo pedido mais antigo
				//------------------------------------

				If aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .And. ;
					(aItXml[nI][XML_VUNIT] == aItPed[nX][PED_VUNIT] .Or. Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. ;
					aItXml[nI][XML_QTDE] == aItPed[nX][PED_QTDE] .And. ;
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
					AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aMatch, { ;
						{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;  //aRelac
						{;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]},; //aItVin
						aItXml[nI],;
						aItPed[nX];
					})
					
					//AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					/*AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})
					
					Exit*/
					
				EndIf

				//------------------------------------
				// Procura com mesmo produto, valor unitário e quantidade menor
				//------------------------------------

				If aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .And. ;
					(aItXml[nI][XML_VUNIT] == aItPed[nX][PED_VUNIT] .Or. Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. ;
					aItXml[nI][XML_QTDE] <= aItPed[nX][PED_QTDE] .And. ;
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
					AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aMatch, { ;
						{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
						{;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]},;
						aItXml[nI],;
						aItPed[nX];
					})
					
					//AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					/*AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})*/
					
					//Exit
					
				EndIf

				//------------------------------------
				//Produto em branco, mesmo valor unitário e mesma quantidade
				//------------------------------------
				If Empty(aItXml[nI][XML_PROD]) .And. ;
					(aItXml[nI][XML_VUNIT] == aItPed[nX][PED_VUNIT] .Or. Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. ;
					aItXml[nI][XML_QTDE] == aItPed[nX][PED_QTDE] .And. ;
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
					AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aMatch, { ;
						{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
						{;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]},;
						aItXml[nI],;
						aItPed[nX];
					})
					
					//AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					/*AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})*/
					
					//Exit
					
				EndIf

				//------------------------------------
				//Produto Em branco, valor unitário e quantidade menor
				//------------------------------------
				If Empty(aItXml[nI][XML_PROD]) .And. ;
					(aItXml[nI][XML_VUNIT] == aItPed[nX][PED_VUNIT] .Or. Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. ;
					aItXml[nI][XML_QTDE] <= aItPed[nX][PED_QTDE] .And. ;
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
					AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aMatch, { ;
						{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
						{;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]},;
						aItXml[nI],;
						aItPed[nX];
					})
					
					//AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					/*AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})*/
					
					//Exit
					
				EndIf

				//------------------------------------
				//Busca pelo valor total
				//------------------------------------
				_nValAux1 := aItXml[nI][XML_TOTAL]
				_nValAux2 := aItXml[nI][XML_TOTAL]
				
				If !lBusca
				
					If _nPosVlIcm > 0

						_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlIcm]

					EndIf

					If _nPosVlIpi > 0

						_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlIpi]
						_nValAux2 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlIpi]

					EndIf

					If _nPosDescX > 0

						_nValAux1 -= oGetD:aCols[aItXml[nI][XML_POS]][_nPosDescX]
						_nValAux2 -= oGetD:aCols[aItXml[nI][XML_POS]][_nPosDescX]

					EndIf

					If _nPosVlFrt > 0

						_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlFrt]
						_nValAux2 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlFrt]

					EndIf

					If _nPosVlISt > 0

						_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlISt]
						_nValAux2 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlISt]

					EndIf
					
				EndIf

				If (aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .Or. Empty(aItXml[nI][XML_PROD])) .And. ;
					( ;
						aItXml[nI][XML_TOTAL] == aItPed[nX][PED_TOTAL] .Or. ;
						_nValAux1 == aItPed[nX][PED_TOTAL] .Or. ;
						_nValAux2 == aItPed[nX][PED_TOTAL] ;
					) .And. ; // Criar uma condição OR e somar no XML_TOTAL os descontos + frete + impostos + etc
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
					AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aMatch, { ;
						{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
						{;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]},;
						aItXml[nI],;
						aItPed[nX];
					})
					
					//AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					/*AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})*/
					
					//Exit
					
				EndIf

				//---------------------
				// Mesma validação mas com telerância 
				//---------------------
				
				nTolVinc := GetNewPar("MV_ZTOLVIX", 0.01)

				If (aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .Or. Empty(aItXml[nI][XML_PROD])) .And. ;
					( ;
						Abs(aItXml[nI][XML_TOTAL] - aItPed[nX][PED_TOTAL]) < nTolVinc .Or. ;
						Abs(_nValAux1 - aItPed[nX][PED_TOTAL]) < nTolVinc.Or. ;
						Abs(_nValAux2 - aItPed[nX][PED_TOTAL]) < nTolVinc;
					) .And. ; // Criar uma condição OR e somar no XML_TOTAL os descontos + frete + impostos + etc
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
					AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aMatch, { ;
						{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
						{;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]},;
						aItXml[nI],;
						aItPed[nX];
					})
					
					//AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					/*AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})*/
					
					//Exit
					
				EndIf
				
			Next nX
			
			If lBusca .And. !lCalc
				
				For nX := 1 To Len(aItPed)
				
					If (aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .Or. Empty(aItXml[nI][XML_PROD])) .And. ;
						( ;
							Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < nTolVinc ;
						) .And. ; // Criar uma condição OR e somar no XML_TOTAL os descontos + frete + impostos + etc
						AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
						AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
						
						AAdd(aMatch, { ;
							{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
							{;
							1, ;
							aItXml[nI][XML_ITEM], ;
							aItPed[nX][PED_PROD], ;
							aItPed[nX][PED_DESPROD], ;
							aItPed[nX][PED_NUMPED], ;
							aItPed[nX][PED_ITPED], ;
							aItXml[nI][XML_QTDE], ;
							aItXml[nI][XML_VUNIT], ;
							aItXml[nI][XML_TOTAL], ;
							Len(aRelac), ;
							aItPed[nX][PED_TIPO]},;
							aItXml[nI],;
							aItPed[nX];
						})
						
					EndIf
					
					If (aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .Or. Empty(aItXml[nI][XML_PROD])) .And. ;
						AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
						AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
						
						AAdd(aMatch, { ;
							{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
							{;
							1, ;
							aItXml[nI][XML_ITEM], ;
							aItPed[nX][PED_PROD], ;
							aItPed[nX][PED_DESPROD], ;
							aItPed[nX][PED_NUMPED], ;
							aItPed[nX][PED_ITPED], ;
							aItXml[nI][XML_QTDE], ;
							aItXml[nI][XML_VUNIT], ;
							aItXml[nI][XML_TOTAL], ;
							Len(aRelac), ;
							aItPed[nX][PED_TIPO]},;
							aItXml[nI],;
							aItPed[nX];
						})
						
					EndIf
					
					If AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0 .And. ;
						AScan(aMatch, {|x| AScan(x[1][2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
						
						AAdd(aMatch, { ;
							{{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO], aItXml[nI][XML_QTDE]}}}, ;
							{;
							1, ;
							aItXml[nI][XML_ITEM], ;
							aItPed[nX][PED_PROD], ;
							aItPed[nX][PED_DESPROD], ;
							aItPed[nX][PED_NUMPED], ;
							aItPed[nX][PED_ITPED], ;
							aItXml[nI][XML_QTDE], ;
							aItXml[nI][XML_VUNIT], ;
							aItXml[nI][XML_TOTAL], ;
							Len(aRelac), ;
							aItPed[nX][PED_TIPO]},;
							aItXml[nI],;
							aItPed[nX];
						})
						
					EndIf
					
				Next nX
				
			EndIf
			
			If Len(aMatch) == 1 .Or. (lBusca .And. Len(aMatch) > 1)
				
				AAdd(aRelac, aMatch[1][1])
				
				aMatch[1][2][10] := Len(aRelac)
				
				AAdd(aItVin, aMatch[1][2])
				
			ElseIf Len(aMatch) > 1
				
				nPosMatch := SelMultPed(aMatch)
				
				AAdd(aRelac, aMatch[nPosMatch][1])
				
				aMatch[nPosMatch][2][10] := Len(aRelac)
				
				AAdd(aItVin, aMatch[nPosMatch][2])
				
			EndIf
			
		EndIf
		
	Next nI
	
	/*oBrwItVin:SetArray(aItVin)
	
	oBrwItVin:Refresh()
	
	AtuXml()
	AtuPed()*/

	/*If !Empty(aItXml[1][XML_ITEM]) .And. !Empty(aItPed[1][PED_NUMPED])
		
		For nI := 1 To Len(aItXml)
		
			For nX := 1 To Len(aItPed)
				
				If aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .And. ;
					(aItXml[nI][XML_VUNIT] == aItPed[nX][PED_VUNIT] .Or. Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. ;
					aItXml[nI][XML_QTDE] <= aItPed[nX][PED_QTDE] .And. ;
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED]}) > 0}) == 0
					
					AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})
					
					Exit
					
				EndIf
				
			Next nX
			
		Next nI
		
		oBrwItVin:SetArray(aItVin)
		
		oBrwItVin:Refresh()
		
		AtuXml()
		AtuPed()
		
	EndIf*/
	
	/*If !Empty(aItXml[1][XML_ITEM]) .And. !Empty(aItPed[1][PED_NUMPED])
		
		// Procura com valor unitário igual e pelo pedido mais antigo
		For nI := 1 To Len(aItXml)
			
			For nX := 1 To Len(aItPed)
				
				If Empty(aItXml[nI][XML_PROD]) .And. ;
					(aItXml[nI][XML_VUNIT] == aItPed[nX][PED_VUNIT] .Or. Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. ;
					aItXml[nI][XML_QTDE] == aItPed[nX][PED_QTDE] .And. ;
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})
					
					Exit
					
				EndIf
				
			Next nX
			
		Next nI
		
		oBrwItVin:SetArray(aItVin)
		
		oBrwItVin:Refresh()
		
		AtuXml()
		AtuPed()
		
	EndIf*/
	
	/*If !Empty(aItXml[1][XML_ITEM]) .And. !Empty(aItPed[1][PED_NUMPED])
		
		// Procura com valor unitário igual e pelo pedido mais antigo
		For nI := 1 To Len(aItXml)
			
			For nX := 1 To Len(aItPed)
				
				If Empty(aItXml[nI][XML_PROD]) .And. ;
					(aItXml[nI][XML_VUNIT] == aItPed[nX][PED_VUNIT] .Or. Abs(aItXml[nI][XML_VUNIT] - aItPed[nX][PED_VUNIT]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. ;
					aItXml[nI][XML_QTDE] <= aItPed[nX][PED_QTDE] .And. ;
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})
					
					Exit
					
				EndIf
				
			Next nX
			
		Next nI
		
		oBrwItVin:SetArray(aItVin)
		
		oBrwItVin:Refresh()
		
		AtuXml()
		AtuPed()
		
	EndIf*/
	
	/*If !Empty(aItXml[1][XML_ITEM]) .And. !Empty(aItPed[1][PED_NUMPED])
			
		// Procura com valor total igual e pelo pedido mais antigo
		For nI := 1 To Len(aItXml)
			
			For nX := 1 To Len(aItPed)
				
				_nValAux1 := aItXml[nI][XML_TOTAL]
				_nValAux2 := aItXml[nI][XML_TOTAL]

				If _nPosVlIcm > 0

					_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlIcm]

				EndIf

				If _nPosVlIpi > 0

					_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlIpi]
					_nValAux2 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlIpi]

				EndIf

				If _nPosDescX > 0

					_nValAux1 -= oGetD:aCols[aItXml[nI][XML_POS]][_nPosDescX]
					_nValAux2 -= oGetD:aCols[aItXml[nI][XML_POS]][_nPosDescX]

				EndIf

				If _nPosVlFrt > 0

					_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlFrt]
					_nValAux2 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlFrt]

				EndIf

				If _nPosVlISt > 0

					_nValAux1 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlISt]
					_nValAux2 += oGetD:aCols[aItXml[nI][XML_POS]][_nPosVlISt]

				EndIf

				If (aItXml[nI][XML_PROD] == aItPed[nX][PED_PROD] .Or. Empty(aItXml[nI][XML_PROD])) .And. ;
					( ;
						aItXml[nI][XML_TOTAL] == aItPed[nX][PED_TOTAL] .Or. ;
						_nValAux1 == aItPed[nX][PED_TOTAL] .Or. ;
						_nValAux2 == aItPed[nX][PED_TOTAL] ;
					) .And. ; // Criar uma condição OR e somar no XML_TOTAL os descontos + frete + impostos + etc
					AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
					
					AAdd(aRelac, {{aItXml[nI][XML_POS]}, {{aItPed[nX][PED_NUMPED], aItPed[nX][PED_ITPED], 0, aItPed[nX][PED_TIPO]}}})
					
					AAdd(aItVin, {;
						1, ;
						aItXml[nI][XML_ITEM], ;
						aItPed[nX][PED_PROD], ;
						aItPed[nX][PED_DESPROD], ;
						aItPed[nX][PED_NUMPED], ;
						aItPed[nX][PED_ITPED], ;
						aItXml[nI][XML_QTDE], ;
						aItXml[nI][XML_VUNIT], ;
						aItXml[nI][XML_TOTAL], ;
						Len(aRelac), ;
						aItPed[nX][PED_TIPO]})
					
					Exit
					
				EndIf
				
			Next nX
			
		Next nI
		
		oBrwItVin:SetArray(aItVin)
		
		oBrwItVin:Refresh()
		
		AtuXml()
		AtuPed()

	EndIf*/

	/*If !Empty(aItXml[1][XML_ITEM]) .And. !Empty(aItPed[1][PED_NUMPED])

		// Aqui deverá procurar somando todos os itens de um Pedido e ver se bate com algum item do XML.
		// Pois existem casos em que vários itens de um pedido entram como 1 item do XML.

		For nX := 1 To Len(aItPed)

			If AScan(aRelac, {|x| AScan(x[2], {|y| y[1] == aItPed[nX][PED_NUMPED] .And. y[2] == aItPed[nX][PED_ITPED] .And. y[4] == aItPed[nX][PED_TIPO]}) > 0}) == 0
				
				nPosPed := AScan(aTotPed, {|x| x[1] == aItPed[nX][PED_NUMPED] .And. x[3] == aItPed[nX][PED_TIPO]})

				If nPosPed > 0

					aTotPed[nPosPed][2] += aItPed[nX][PED_TOTAL]

					AAdd(aTotPed[nPosPed][4], aItPed[nX][PED_ITPED])

				Else
					
					AAdd(aTotPed, {aItPed[nX][PED_NUMPED], aItPed[nX][PED_TOTAL], aItPed[nX][PED_TIPO], {aItPed[nX][PED_ITPED]}})

				EndIf

			EndIf

		Next nX

		For nX := 1 To Len(aTotPed)

			For nI := 1 To Len(aItXml)

				If aItXml[nI][XML_TOTAL] == aTotPed[nX][2]

					aRelacAux := {}

					For nZ := 1 To Len(aItPed)

						If aItPed[nZ][PED_NUMPED] == aTotPed[nX][1] .And. AScan(aTotPed[nX][4], {|x| x == aItPed[nZ][PED_ITPED]}) > 0
							
							AAdd(aRelacAux, {aItPed[nZ][PED_NUMPED], aItPed[nZ][PED_ITPED], aItPed[nZ][PED_TOTAL], aItPed[nZ][PED_TIPO]})

							AAdd(aItVin, {;
								1, ;
								aItXml[nI][XML_ITEM], ;
								aItPed[nZ][PED_PROD], ;
								aItPed[nZ][PED_DESPROD], ;
								aItPed[nZ][PED_NUMPED], ;
								aItPed[nZ][PED_ITPED], ;
								aItPed[nZ][PED_QTDE], ;
								aItPed[nZ][PED_VUNIT], ;
								aItPed[nZ][PED_TOTAL], ;
								Len(aRelac), ;
								aItPed[nZ][PED_TIPO]})

						EndIf

					Next nZ

					AAdd(aRelac, {{aItXml[nI][XML_POS]}, aRelacAux})

					Exit

				EndIf

			Next nI

		Next nX
		
	EndIf*/

	If Empty(aItVin)
		
		AAdd(aItVin, {1, "", "", "", "", "", "", "", "", 0, ""})
		
		If !lBusca
			
			Alert("Nenhum pedido encontrado para vincular automaticamente!")
			
		EndIf
		
	EndIf
	
	If !lBusca
	
		oBrwItVin:SetArray(aItVin)
		
		oBrwItVin:Refresh()
		
		AtuXml()
		AtuPed()
		
	EndIf
	
Return

Static Function SelMultPed(aMatch)
	
	Local nPosRet := 1
	Local oLayerMult
	Local oDlgMult
	Local oBrwItPed
	Local nI
	
	Private oItem
	Private cItem := aMatch[1][3][XML_ITEM]
	
	Private oProd
	Private cProd := aMatch[1][3][XML_PROD]
	
	Private oDesc
	Private cDesc := aMatch[1][3][XML_DESPROD]
	
	Private oQtde
	Private nQtde := aMatch[1][3][XML_QTDE]
	
	Private oVUnit
	Private nVUnit := aMatch[1][3][XML_VUNIT]
	
	Private oTotal
	Private nTotal := aMatch[1][3][XML_TOTAL]
	
	Private aColsMatch := {}
	
	For nI := 1 To Len(aMatch)
		
		AAdd(aColsMatch, aMatch[nI][4])
		
	Next nI
	
	DEFINE MSDIALOG oDlgMult FROM aSize[7], 0 TO aSize[6]/1.3, aSize[5]/1.4 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oLayerMult := FWLayer():New()
		oLayerMult:Init(oDlgMult, .F.)
			
			oLayerMult:AddLine('LIN1', 20, .F.)
				
				oLayerMult:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
					
					oLayerMult:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Item do XML", 100, .F., .T., , 'LIN1',)
						
						oItem := TGet():New(002, 002, {|u| IF(Pcount() > 0, cItem := u, cItem)}, oLayerMult:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), 060, 010, , , , , , , , .T., , , {|| .F.}, , , , , , , "cItem", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Item", 2, , )

						oProd := TGet():New(002, 076, {|u| IF(Pcount() > 0, cProd := u, cProd)}, oLayerMult:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), 040, 010, , , , , , , , .T., , , {|| .F.}, , , , , , , "cProd", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Produto", 2, , )

						oDesc := TGet():New(002, 142, {|u| IF(Pcount() > 0, cDesc := u, cDesc)}, oLayerMult:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), 100, 010, , , , , , , , .T., , , {|| .F.}, , , , , , , "cDesc", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Descrição", 2, , )

						oQtde := TGet():New(002, 272, {|u| IF(Pcount() > 0, nQtde := u, nQtde)}, oLayerMult:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), 040, 010, PesqPict("SD1", "D1_QUANT"), , , , , , , .T., , , {|| .F.}, , , , , , , "nQtde", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Qtde.", 2, , )
						
						oVUnit := TGet():New(002, 332, {|u| IF(Pcount() > 0, nVunit := u, nVunit)}, oLayerMult:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), 040, 010, PesqPict("SD1", "D1_VUNIT"), , , , , , , .T., , , {|| .F.}, , , , , , , "nVUnit", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Vlr. Unit", 2, , )
						
						oTotal := TGet():New(002, 392, {|u| IF(Pcount() > 0, nTotal := u, nTotal)}, oLayerMult:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), 040, 010, PesqPict("SD1", "D1_TOTAL"), , , , , , , .T., , , {|| .F.}, , , , , , , "nTotal", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Total", 2, , )
						
			oLayerMult:AddLine('LIN2', 70, .F.)
				
				oLayerMult:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
					
					oLayerMult:AddWindow('COL1_LIN2', 'WIN1_COL1_LIN2', "Pedidos Encontrados", 100, .F., .T., , 'LIN2',)
						
						oBrwItPed := TCBrowse():New(50, 50, 200, 200,,,, oLayerMult:GetWinPanel('COL1_LIN2', 'WIN1_COL1_LIN2', 'LIN2'),,,,,,,,,,,, .T.,, .T.,)
						oBrwItPed:Align := CONTROL_ALIGN_ALLCLIENT
						oBrwItPed:nClrBackFocus := GetSysColor(13)
						oBrwItPed:nClrForeFocus := GetSysColor(14)
						oBrwItPed:SetArray(aColsMatch)
						
						ADD COLUMN TO oBrwItPed HEADER "Pedido/Sol" OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_NUMPED]} ALIGN LEFT SIZE 30 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Item Ped." OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_ITPED]} ALIGN LEFT SIZE 30 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Produto" OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_PROD]} ALIGN LEFT SIZE 30 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Desc.Prod." OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_DESPROD]} ALIGN LEFT SIZE 60 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Quant." OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_QTDE]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_QUANT")[2]) SIZE 30 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Val.Unit." OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_VUNIT]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_VUNIT")[2]) SIZE 30 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Total" OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_TOTAL]} ALIGN RIGHT PICTURE "@E 9,999,999." + Replicate("9", TamSX3("D1_TOTAL")[2]) SIZE 30 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Emissão" OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_EMISSAO]} ALIGN LEFT SIZE 30 PIXELS
						
						ADD COLUMN TO oBrwItPed HEADER "Tipo" OEM DATA {|| aColsMatch[oBrwItPed:nAt, PED_TIPODES]} ALIGN LEFT SIZE 30 PIXELS
						
			oLayerMult:AddLine('LIN3', 10, .F.)
				
				oLayerMult:AddCollumn('COL1_LIN3', 100, .T., 'LIN3')
					
					oPanelBot := tPanel():New(0,0,"",oLayerMult:GetColPanel('COL1_LIN3', 'LIN3'),,,,,RGB(239,243,247),000,015)
					oPanelBot:Align	:= CONTROL_ALIGN_BOTTOM
					
					oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgMult:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oLimp := THButton():New(0, 0, "Confirmar Pedido", oPanelBot, {|| (nPosRet := oBrwItPed:nAt), oDlgMult:End()}, , , )
					oLimp:nWidth  := 100
					oLimp:nHeight := 10
					oLimp:Align := CONTROL_ALIGN_RIGHT
					oLimp:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgMult CENTERED
	
Return nPosRet

Static Function ConfSel()
	
	Local nI
	Local nPed
	Local nQuant
	Local nQuantPed
	Local nPosXml
	
	Local aRatPed := {}
	
	Local nOpcQtdeXP := 2

	Local lTemSol   := .F.
	Local aItensSol := {}
	Local nPosSol

	Local nPosOrig
	
	Local aNovoCols := aClone(oGetD:aCols)
	
	Local lFezCond := .F.
	
	Local nH
	
	Local nTotXML := 0
	
	Local aTotOrig := {;
					  {0, 0},; //ICMS
					  {0, 0},; //IPI
					  {0, 0},; //ST
					  {0, 0},; //ST ANT
					  {0},; //Desconto
					  {0}; //Vlr. Frete
					  }
					  
	Local aTotRat := {;
					{0, 0},; //ICMS
					{0, 0},; //IPI
					{0, 0},; //ST
					{0, 0},; //ST ANT
					{0},; //Desconto
					{0}; //Vlr. Frete
					}
	
	If Empty(aRelac)
		
		Alert("É necessário vincular pelo menos um item do XML para confirmar.")
		
		Return .F.
		
	EndIf
	
	For nI := 1 To Len(aItVin)
			
		If aItVin[nI][11] == "S"
			
			// Verificar se há produtos diferentes da Solicitação com o XML, caso tenha 
			// atualizar os produtos na Solicitação
			// [TODO]

			dbSelectArea("SC1")
			SC1->( dbSetOrder(1) )
			If SC1->( dbSeek(xFilial("SC1") + aItVin[nI][5] + aItVin[nI][6]) )

				If SC1->C1_PRODUTO # aItVin[nI][3]

					RecLock("SC1", .F.)

						SC1->C1_PRODUTO := aItVin[nI][3]
						SC1->C1_DESCRI  := aItVin[nI][4]

					SC1->( MSUnlock() )

				EndIf

			EndIf

			lTemSol := .T.
			
			nPosSol := AScan(aItensSol, {|x| x[1][1] == aItVin[nI][5]})
			
			If nPosSol == 0
				
				AAdd(aItensSol, {{aItVin[nI][5], aItVin[nI][6], aItVin[nI][7], aItVin[nI][8], aItVin[nI][9]}})
				
			ElseIf AScan(aItensSol[nPosSol], {|x| x[1] == aItVin[nI][5] .And. x[2] == aItVin[nI][6]}) == 0
				
				AAdd(aItensSol[nPosSol], {aItVin[nI][5], aItVin[nI][6], aItVin[nI][7], aItVin[nI][8], aItVin[nI][9]})
				
			EndIf
			
		EndIf
		
	Next nI
	
	/*For nI := 1 To Len(aRelac)
		
		For nPed := 1 To Len(aRelac[nI][2])
			
			If aRelac[nI][2][nPed][4] == "S"
				
				lTemSol := .T.
				
				nPosSol := AScan(aItensSol, {|x| x[1][1] == aRelac[nI][2][nPed][1]})
				
				If nPosSol == 0
					
					AAdd(aItensSol, {{aRelac[nI][2][nPed][1], aRelac[nI][2][nPed][2]}})
					
				Else
					
					AAdd(aItensSol[nPosSol], {aRelac[nI][2][nPed][1], aRelac[nI][2][nPed][2]})
					
				EndIf
				
			EndIf
			
		Next nPed
		
	Next nI*/
	
	If lTemSol
		
		/*If !MsgYesNo("Existem solicitações de compra selecionadas, para continuar serão gerados pedidos de compra para estas solicitações. Confirma a geração?")
			
			Return .F.
			
		Else*/
			
			// Tela Solicitações que virarão pedido, aqui permitirá ratear a solicitação.
			
			For nI := 1 To Len(aItensSol)

				If !CriaPedSol(aItensSol[nI])
					
					Return .F.
					
				EndIf
				
			Next nI
			
		//EndIf
		
	EndIf
	
	For nI := 1 To Len(aRelac)
		
		nPosXml := aRelac[nI][1][1]
		
		nTotXML := aNovoCols[nPosXml, _nPosVlTot]
		
		// ICMS
		aTotOrig[1][1] := aNovoCols[nPosXml, _nPosBsIcm]
		aTotOrig[1][2] := aNovoCols[nPosXml, _nPosVlIcm]
		
		// IPI
		aTotOrig[2][1] := aNovoCols[nPosXml, _nPosBsIpi]
		aTotOrig[2][2] := aNovoCols[nPosXml, _nPosVlIpi]
		
		// ST
		If _nPosBsISt > 0
			aTotOrig[3][1] := aNovoCols[nPosXml, _nPosBsISt]
			aTotOrig[3][2] := aNovoCols[nPosXml, _nPosVlISt]
		EndIf
		
		// ST ANT
		If _nPosBsStA > 0
			aTotOrig[4][1] := aNovoCols[nPosXml, _nPosBsStA]
			aTotOrig[4][2] := aNovoCols[nPosXml, _nPosVlStA]
		EndIf
		
		// Desconto
		aTotOrig[5][1] := aNovoCols[nPosXml, _nPosDescX]
		
		// VlFrete
		aTotOrig[6][1] := aNovoCols[nPosXml, _nPosVlFrt]
		
		For nPed := 1 To Len(aRelac[nI][2])
		
			dbSelectArea("SC7")
			SC7->( dbSetOrder(1) )
			
			If SC7->( dbSeek(xFilial("SC7") + aRelac[nI][2][nPed][1] + aRelac[nI][2][nPed][2]) )
				
				If !lFezCond .And. !Empty(SC7->C7_COND)
					
					M->&(_cCmp1 + "_CONDPG") := SC7->C7_COND
					
					lFezCond := .T.
					
				EndIf
				
				nPosOrig := nPosXml
				
				If Len(aRelac[nI][2]) == 1
					
					nQuant    := aNovoCols[nPosXml, _nPosQtdNo]
					nQuantPed := (SC7->C7_QUANT - SC7->C7_QUJE)
					
				Else
					
					If nPed > 1
						
						AAdd(aNovoCols, Array(Len(aNovoCols[nPosXml])))
						
						// Preencher os valores default
						
						For nH := 1 To Len(oGetD:aHeader)
							
							ATail(aNovoCols)[nH] := CriaVar(oGetD:aHeader[nH][2], .F.)
							
						Next nH
						
						nPosXml := Len(aNovoCols)
						
					EndIf
					
					nQuant := nQuantPed := aRelac[nI][2][nPed][5]
					//nQuantPed := (SC7->C7_QUANT - SC7->C7_QUJE)
					
				EndIf
				
				/// VERIFICA CONVERSÃO DE UNIDADE DE MEDIDA
				
				/*If _nPosUmFor > 0 .And. !Empty(oGetD:aCols[nPosXml, _nPosUmFor]) .And. (oGetD:aCols[nPosXml, _nPosUmFor] # SC7->C7_UM .Or. SC7->C7_UM # oGetD:aCols[nPosXml, _nPosUmFor]) .And. lUMConv
				
					// Realiza a conversão de Unidade de Medida por Produto
					//                *Produto         *UM For                         *UM Nosso        *Qtd For
					aConv := ValConUM(SC7->C7_PRODUTO, oGetD:aCols[nPosXml, _nPosUmFor], SC7->C7_UM, oGetD:aCols[nPosXml, _nPosQtdFr], M->&(_cCmp1 + "_CODEMI"), M->&(_cCmp1 + "_LOJEMI"))
					
					// Conversão Ocorrida
					If aConv[1]
					
						If aConv[2] # nQuantPed
							
							If Aviso("Aviso", "A quantidade do Pedido de Compra é diferente do que a do Item da Nota!" + CRLF + ;
							   "Item: " + oGetD:aCols[nPosXml, _nPosItXml] + CRLF + ;
							   "Qtde. Xml: " + Transform(aConv[2], "@E 999999999.9999") + CRLF + ;
							   "Qtde. Pedido de Compra: " + Transform(nQuantPed, "@E 99999999.9999") + CRLF + ;
							   "Deseja manter os valores do XML, ou substituir pelo do pedido?", {"XML", "Pedido"}, 2) == 1
							   	
								nQuant := aConv[2]
								
							Else
							
								nQuant := nQuantPed
								
							EndIf
							
						EndIf
						
					ElseIf nQuant # nQuantPed
					
						If Aviso("Unidade de Medida", "A Unidade de Medida do Produto (" + oGetD:aCols[nPosXml, _nPosItXml] + ") está diferente do arquivo XML!" + CRLF + ;
						         "Un.Medida do arquivo XML: " + Transform(oGetD:aCols[nPosXml, _nPosQtdFr], "@E 999999999.9999") + " " + oGetD:aCols[nPosXml, _nPosUmFor] + CRLF + ;
						         "Un.Medida do Produto Informado: " + Transform(nQuantPed, "@E 999999999.9999") + " " + SC7->C7_UM + CRLF + ;
						         "Não foi encontrado cadastro de conversão de unidade de medida entre as informada. Deseja manter os valores do XML, ou substituir pelo do pedido?.", {"XML", "Pedido"}, 3) == 2
						
							nQuant := nQuantPed
							
						EndIf
						
					EndIf
					
				Else*/
				
					If !Empty(nQuant) .And. nQuant # nQuantPed .And. Len(aRelac[nI][2]) == 1
						
						If (aRatPed := IsMultiXml(nPosXml))[1]
							
							If Aviso("Aviso", "A quantidade do pedido de compra em relação aos itens selecionados está diferente, deseja ratear o valor do pedido ou manter as quantidades do XML?" + CRLF + ;
										"Deseja manter os valores do XML, ou substituir pelo do pedido?", {"Qtde. XML", "Ratear Qtde. Ped."}, 2) == 1
										
								nQuant := aNovoCols[nPosXml, _nPosQtdNo]
										
							Else
								
								nQuant := aRatPed[2]
								
							EndIf
							
						Else
						
							If nOpcQtdeXP < 3 // Apenas para XML ou Pedido

								nOpcQtdeXP := Aviso("Aviso", "A quantidade do Pedido de Compra é " + IIf(nQuant < nQuantPed, "MAIOR", "MENOR")+ " do que a do Item da Nota!" + CRLF + ;
										"Item: " + aNovoCols[nPosXml, _nPosItXml] + CRLF + ;
										"Qtde. XML: " + AllTrim(Transform(nQuant, "@E 999999999.9999")) + " " + aNovoCols[nPosXml, _nPosUmFor] + CRLF + ;
										"Qtde. Pedido de Compra: " + AllTrim(Transform(nQuantPed, "@E 99999999.99")) + " " + SC7->C7_UM + CRLF + ;
										"Deseja manter os valores do XML, ou substituir pelo do pedido?", {"XML", "Pedido", "Xml Todos", "Pedido Todos"}, 2)

							EndIf

							If nOpcQtdeXP == 1 .Or. nOpcQtdeXP == 3
							
								nQuant := aNovoCols[nPosXml, _nPosQtdNo]
								
							Else
							
								nQuant := nQuantPed
								
							EndIf
							
						EndIf
						
					EndIf
					
					/*If oGetD:aCols[nPosXml, _nPosVlUnt] # aPedidos[nX, 9]
					
						If Aviso("Aviso", "O Valor Unitário do Pedido de Compra está diferente do item da Nota!" + CRLF + ;
						         "Valor Unit. Item da Nota:  R$ " + AllTrim(TRANSFORM(oGetD:aCols[nPosXml, _nPosVlUnt], "@E 999,999,999.99")) + CRLF + ;
								 "Valor Unit. Pedido de Compra:  R$ " + AllTrim(TRANSFORM(aPedidos[nX, 9], "@E 999,999,999.99")) + CRLF + ;
								 "Deseja assumir o valor do pedido de compra?", {"Sim", "Não"}, 2) == 1
						
							nVal := aPedidos[nX, 9]
							
						Else
						
							nVal := oGetD:aCols[nPosXml, _nPosVlUnt]
							
						EndIf
						
					EndIf*/
					
				//EndIf
				
				//-----------------------------------------
				
				If _nPosPedid > 0
				
					aNovoCols[nPosXml, _nPosPedid] := SC7->C7_NUM
					
				EndIf
				
				If _nPosItePc > 0
				
					aNovoCols[nPosXml, _nPosItePc] := SC7->C7_ITEM
					
				EndIf
				
				If _nPosProdu > 0
				
					aNovoCols[nPosXml, _nPosProdu] := SC7->C7_PRODUTO
					
				EndIf
				
				If _nPosDcPrd > 0
				
					aNovoCols[nPosXml, _nPosDcPrd] := IIf(_nPosProdu > 0, Posicione("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "B1_DESC"), "")
					
				EndIf
				
				If _nPosUm > 0
				
					aNovoCols[nPosXml, _nPosUm] := SC7->C7_UM
					
				EndIf
				
				// Campos para copiar
				
				// NCM
				
				If _nPosNcm > 0

					aNovoCols[nPosXml, _nPosNcm] := aNovoCols[nPosOrig, _nPosNcm]

				EndIf
				
				//UM FOR
				
				If _nPosUmFor > 0

					aNovoCols[nPosXml, _nPosUmFor] := aNovoCols[nPosOrig, _nPosUmFor]

				EndIf
				
				////////////////
				
				If _nPosQtdFr > 0

					aNovoCols[nPosXml, _nPosQtdFr] := aNovoCols[nPosOrig, _nPosQtdFr]

				EndIf

				If _nPosStTri > 0

					aNovoCols[nPosXml, _nPosStTri] := aNovoCols[nPosOrig, _nPosStTri]

				EndIf

				////////////

				If _nPosQtdNo > 0
				
					aNovoCols[nPosXml, _nPosQtdNo] := nQuant
					
				EndIf
				
				If Len(aRelac[nI][2]) == 1
					
					If _nPosVlUnt > 0
						
						nVUAux := Round(aNovoCols[nPosXml, _nPosVlTot] / nQuant, TamSX3(_cCmp2 + "_VUNIT")[2])
						
						// Novo tratamento para comparação do valor unitário
						
						cVUAux := cValToChar(aNovoCols[nPosXml, _nPosVlTot])
						cVUAux := SubStr(cVUAux, At(".", cVUAux) + 1)
						
						If Abs(Round(nQuant * SC7->C7_PRECO, Len(cVUAux)) - aNovoCols[nPosXml, _nPosVlTot]) <= 0.01
							
							nVUAux := SC7->C7_PRECO
							
						EndIf
						
						aNovoCols[nPosXml, _nPosVlUnt] := nVUAux
						
					EndIf
					
					/*If _nPosVlUnt > 0
						
						aNovoCols[nPosXml, _nPosVlUnt] := Round(aNovoCols[nPosXml, _nPosVlTot] / nQuant, TamSX3(_cCmp2 + "_VUNIT")[2])
						
					EndIf*/
					
				Else
					
					//Campos a mais para o item adicionado
					
					If _nPosVlTot > 0
						
						aNovoCols[nPosXml, _nPosVlTot] := aRelac[nI][2][nPed][3]
						
					EndIf
					
					If _nPosVlUnt > 0
						
						aNovoCols[nPosXml, _nPosVlUnt] := Round(aRelac[nI][2][nPed][3] / nQuant, TamSX3(_cCmp2 + "_VUNIT")[2])
						
					EndIf
					
					If _nPosItXml > 0
						
						aNovoCols[nPosXml, _nPosItXml] := aNovoCols[aRelac[nI][1][1], _nPosItXml]
						
					EndIf
					
					// Impostos dos campos adicionados
					
					If _nPosBsIcm > 0
						
						aNovoCols[nPosXml, _nPosBsIcm] := aNovoCols[nPosOrig, _nPosBsIcm] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						aNovoCols[nPosXml, _nPosAqIcm] := aNovoCols[nPosOrig, _nPosAqIcm]
						aNovoCols[nPosXml, _nPosVlIcm] := aNovoCols[nPosOrig, _nPosVlIcm] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						
						aTotRat[1][1] += aNovoCols[nPosXml, _nPosBsIcm]
						aTotRat[1][2] += aNovoCols[nPosXml, _nPosVlIcm]
							
						If nPed == Len(aRelac[nI][2])
							
							If aTotRat[1][1] # aTotOrig[1][1]
								
								aNovoCols[nPosXml, _nPosBsIcm] += aTotOrig[1][1] - aTotRat[1][1]
								
							EndIf
							
							If aTotRat[1][2] # aTotOrig[1][2]
								
								aNovoCols[nPosXml, _nPosVlIcm] += aTotOrig[1][2] - aTotRat[1][2]
								
							EndIf
							
						EndIf
						
					EndIf
					
					If _nPosBsIpi > 0
						
						aNovoCols[nPosXml, _nPosBsIpi] := aNovoCols[nPosOrig, _nPosBsIpi] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						aNovoCols[nPosXml, _nPosAqIpi] := aNovoCols[nPosOrig, _nPosAqIpi]
						aNovoCols[nPosXml, _nPosVlIpi] := aNovoCols[nPosOrig, _nPosVlIpi] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						
						aTotRat[2][1] += aNovoCols[nPosXml, _nPosBsIpi]
						aTotRat[2][2] += aNovoCols[nPosXml, _nPosVlIpi]
							
						If nPed == Len(aRelac[nI][2])
							
							If aTotRat[2][1] # aTotOrig[2][1]
								
								aNovoCols[nPosXml, _nPosBsIpi] += aTotOrig[2][1] - aTotRat[2][1]
								
							EndIf
							
							If aTotRat[2][2] # aTotOrig[2][2]
								
								aNovoCols[nPosXml, _nPosVlIpi] += aTotOrig[2][2] - aTotRat[2][2]
								
							EndIf
							
						EndIf
						
					EndIf
					
					If _nPosVlISt > 0
					
						aNovoCols[nPosXml, _nPosBsISt] := aNovoCols[nPosOrig, _nPosBsISt] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						aNovoCols[nPosXml, _nPosPIcSt] := aNovoCols[nPosOrig, _nPosPIcSt]
						aNovoCols[nPosXml, _nPosVlISt] := aNovoCols[nPosOrig, _nPosVlISt] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						
						aTotRat[3][1] += aNovoCols[nPosXml, _nPosBsISt]
						aTotRat[3][2] += aNovoCols[nPosXml, _nPosVlISt]
							
						If nPed == Len(aRelac[nI][2])
							
							If aTotRat[3][1] # aTotOrig[3][1]
								
								aNovoCols[nPosXml, _nPosBsISt] += aTotOrig[3][1] - aTotRat[3][1]
								
							EndIf
							
							If aTotRat[3][2] # aTotOrig[3][2]
								
								aNovoCols[nPosXml, _nPosVlISt] += aTotOrig[3][2] - aTotRat[3][2]
								
							EndIf
							
						EndIf
						
					EndIf
					
					If _nPosVlStA > 0
					
						aNovoCols[nPosXml, _nPosBsStA] := aNovoCols[nPosOrig, _nPosBsStA] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						aNovoCols[nPosXml, _nPosPStA] := aNovoCols[nPosOrig, _nPosPStA]
						aNovoCols[nPosXml, _nPosVlStA] := aNovoCols[nPosOrig, _nPosVlStA] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						
						aTotRat[4][1] += aNovoCols[nPosXml, _nPosBsStA]
						aTotRat[4][2] += aNovoCols[nPosXml, _nPosVlStA]
							
						If nPed == Len(aRelac[nI][2])
							
							If aTotRat[4][1] # aTotOrig[4][1]
								
								aNovoCols[nPosXml, _nPosBsStA] += aTotOrig[4][1] - aTotRat[4][1]
								
							EndIf
							
							If aTotRat[4][2] # aTotOrig[4][2]
								
								aNovoCols[nPosXml, _nPosVlStA] += aTotOrig[4][2] - aTotRat[4][2]
								
							EndIf
							
						EndIf
						
					EndIf
					
					If _nPosDescX > 0
						
						aNovoCols[nPosXml, _nPosDescX] := aNovoCols[nPosOrig, _nPosDescX] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						
						aTotRat[5][1] += aNovoCols[nPosXml, _nPosDescX]
							
						If nPed == Len(aRelac[nI][2])
							
							If aTotRat[5][1] # aTotOrig[5][1]
								
								aNovoCols[nPosXml, _nPosDescX] += aTotOrig[5][1] - aTotRat[5][1]
								
							EndIf
							
						EndIf
						
					EndIf
					
					If _nPosVlFrt > 0
						
						aNovoCols[nPosXml, _nPosVlFrt] := aNovoCols[nPosOrig, _nPosVlFrt] * aNovoCols[nPosXml, _nPosVlTot] / nTotXML
						
						aTotRat[6][1] += aNovoCols[nPosXml, _nPosVlFrt]
							
						If nPed == Len(aRelac[nI][2])
							
							If aTotRat[6][1] # aTotOrig[6][1]
								
								aNovoCols[nPosXml, _nPosVlFrt] += aTotOrig[6][1] - aTotRat[6][1]
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
				/*If _nPosVlTot > 0
					// [TODO] Talvez não precisa, pq já cria lá em cima da função
					If nPosXml > Len(aNovoCols)
						
						aNovoCols[nPosXml, _nPosVlTot] := aPedidos[nX, 15]
						
					EndIf
					
					//aNovoCols[nPosXml, _nPosVlTot] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, aNovoCols[nPosXml, _nPosQtdNo] * aNovoCols[nPosXml, _nPosVlUnt], 0)
					
				EndIf*/
				
				If _nPosTes > 0

					If !Empty(SC7->C7_TES)
					
						aNovoCols[nPosXml, _nPosTes] := SC7->C7_TES
						
					Else

						aNovoCols[nPosXml, _nPosTes] := aNovoCols[nPosOrig, _nPosTes]

					EndIf

				EndIf
				
				If _nPosCdFis > 0 .And. !Empty(aNovoCols[nPosXml, _nPosTes])
					
					aNovoCols[nPosXml, _nPosCdFis] := IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + aNovoCols[nPosXml, _nPosTes], "F4_CF"), 2, 3)
					
				EndIf
				
				If _nPosTes > 0 .And. Empty(aNovoCols[nPosXml, _nPosTes])
					
					aNovoCols[nPosXml, _nPosTes] := Posicione("SB1", 1, xFilial("SB1") + aNovoCols[nPosXml, _nPosProdu], "B1_TE")
					
					If _nPosCdFis > 0 .And. !Empty(aNovoCols[nPosXml, _nPosTes])
						
						aNovoCols[nPosXml, _nPosCdFis] := IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + aNovoCols[nPosXml, _nPosTes], "F4_CF"), 2, 3)
						
					EndIf
					
				EndIf
				
				/*If _nPosStTri > 0
					
					aNovoCols[nPosXml, _nPosStTri] := "   "//SubStr(aNovoCols[nPosXml, _nPosStTri], 1, 1) + Posicione("SF4", 1, xFilial("SF4") + aPedidos[nX, 10], "F4_SITTRIB")
					
				EndIf*/
				
				/*If _nPosBsIcm > 0
				
					aNovoCols[nPosXml, _nPosBsIcm] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, aNovoCols[nPosXml, _nPosQtdNo] * aNovoCols[nPosXml, _nPosVlUnt], 0)
					
				EndIf*/
				
				// Deveria verificar se a alíquota de ICMS está diferente
				
				/*If _nPosAqIcm > 0 .And. !Empty(SC7->C7_PICM)
				
					aNovoCols[nPosXml, _nPosAqIcm] := SC7->C7_PICM
					
				EndIf*/
				
				/*If _nPosVlIcm > 0
				
					aNovoCols[nPosXml, _nPosVlIcm] := IIf(_nPosBsIcm > 0 .And. _nPosAqIcm > 0, aNovoCols[nPosXml, _nPosBsIcm] * aNovoCols[nPosXml, _nPosAqIcm] / 100, 0)
					
				EndIf*/
				
				/*If _nPosBsIpi > 0
				
					aNovoCols[nPosXml, _nPosBsIpi] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, aNovoCols[nPosXml, _nPosQtdNo] * aNovoCols[nPosXml, _nPosVlUnt], 0)
					
				EndIf
				
				If _nPosAqIpi > 0
				
					aNovoCols[nPosXml, _nPosAqIpi] := aPedidos[nX, 12]
					
				EndIf
				
				If _nPosVlIpi > 0
				
					aNovoCols[nPosXml, _nPosVlIpi] := IIf(_nPosBsIpi > 0 .And. _nPosAqIpi> 0, oGetD:aCols[nPosXml, _nPosBsIpi] * aNovoCols[nPosXml, _nPosAqIpi] / 100, 0)
					
				EndIf*/
				
				If _nPosConta > 0

					If !Empty(SC7->C7_CONTA)
						
						aNovoCols[nPosXml, _nPosConta] := SC7->C7_CONTA 

					Else

						aNovoCols[nPosXml, _nPosConta] := aNovoCols[nPosOrig, _nPosConta]
						
					EndIf
					
				EndIf
				
				If _nPosCtCus > 0

					If !Empty(SC7->C7_CC)
					
						aNovoCols[nPosXml, _nPosCtCus] := SC7->C7_CC 
						
					Else

						aNovoCols[nPosXml, _nPosCtCus] := aNovoCols[nPosOrig, _nPosCtCus]

					EndIf
					
				EndIf
				
				If _nPosItCon > 0

					If !Empty(SC7->C7_ITEMCTA)
					
						aNovoCols[nPosXml, _nPosItCon] := SC7->C7_ITEMCTA

					Else

						aNovoCols[nPosXml, _nPosItCon] := aNovoCols[nPosOrig, _nPosItCon]
						
					EndIf
					
				EndIf
				
				If _nPosClVal > 0
					
					If !Empty(SC7->C7_CLVL)
					
						aNovoCols[nPosXml, _nPosClVal] := SC7->C7_CLVL

					Else

						aNovoCols[nPosXml, _nPosClVal] := aNovoCols[nPosOrig, _nPosClVal]
						
					EndIf
					
				EndIf
				
			EndIf
			
		Next nPed
		
	Next nI
	
	oGetD:SetArray(aNovoCols, .T.)
	oGetD:Refresh()
	
Return .T.

Static Function CriaPedSol(aItensSol)
	
	Local nI
	Local nX
	Local lRet := .F.
	
	Private oDlgPrd
	Private oLayPrd
	
	Private aCmpSol    := {"C7_NUMSC", "C7_ITEMSC", "C7_ZRESPON", "C7_ITEM", "C7_PRODUTO", "C7_DESCRI", "C7_UM", "C7_QUANT", "C7_PRECO", "C7_TOTAL", "C7_RATEIO", "C7_CONTA", "C7_CC"}
	Private aAltSol    := {"C7_ZRESPON"}
	Private aColsSol   := {}
	Private aHeaderSol := {}
	Private oGetSol 
	
	Private aCmpRat    := {"CH_ITEMPD", "CH_ITEM", "CH_PERC", "CH_CC", "CH_CONTA", "CH_ITEMCTA", "CH_CLVL"}
	Private aAltRat    := {"CH_PERC", "CH_CC", "CH_CONTA", "CH_ITEMCTA", "CH_CLVL"}
	Private aColsRat   := {}
	Private aHeaderRat := {}
	Private oGetRat
	
	Private oMsgPrd
	Private cMsgPrd := ""
	
	Private nPosPNumSC
	Private nPosPItSC
	Private nPosPResp
	Private nPosPItem
	Private nPosPProd
	Private nPosPDesc
	Private nPosPUM
	Private nPosPQtde
	Private nPosPPrc
	Private nPosPTot
	Private nPosPCta
	Private nPosPCC
	Private nPosRat
	
	Private nPosRPerc
	Private nPosRCC
	Private nPosRCta
	Private nPosRItCta
	Private nPosRCLVL
	Private nPosRItP
	
	DEFINE MSDIALOG oDlgPrd FROM aSize[7], 0 TO aSize[6]/1.2, aSize[5]/1.2 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgPrd:lEscClose := .F.
		
		oLayPrd := FWLayer():New()
		oLayPrd:Init(oDlgPrd, .F.)
			
			oLayPrd:AddLine('LIN1', 65, .F.)
				
				oLayPrd:AddCollumn('COL1_LIN1', 60, .T., 'LIN1')
					
					oLayPrd:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Pedido Automático da Solicitação " + aItensSol[1][1], 100, .F., .T., , 'LIN1',)
						
						dbSelectArea("SX3")
						SX3->( dbSetOrder(2) )
						
						For nI := 1 To Len(aCmpSol)
							
							If SX3->( dbSeek(aCmpSol[nI]) )
								
								If aCmpSol[nI] $ "C7_CONTA;C7_CC;C7_ZRESPON"
									
									AAdd(aHeaderSol, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, AllTrim(SX3->X3_VALID) + IIf(Empty(SX3->X3_VALID), "", ".And.") + "U_GOXRep(oGetSol)", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})	
									
								//ElseIf aCmpSol[nI] == "C7_NUMSC"
									
									//AAdd(aHeaderSol, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, "SC1IMP", SX3->X3_CONTEXT})
									
								Else
									
									AAdd(aHeaderSol, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
									
								EndIf
								
							EndIf
							
						Next nI
						
						nPosPNumSC := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_NUMSC"})
						nPosPItSC  := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_ITEMSC"})
						nPosPResp  := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_ZRESPON"})
						nPosPItem  := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_ITEM"})
						nPosPProd  := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_PRODUTO"})
						nPosPDesc  := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_DESCRI"})
						nPosPUM    := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_UM"})
						nPosPQtde  := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_QUANT"})
						nPosPPrc   := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_PRECO"})
						nPosPTot   := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_TOTAL"})
						nPosPCta   := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_CONTA"})
						nPosPCC    := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_CC"})
						nPosRat    := AScan(aHeaderSol, {|x| AllTrim(x[2]) == "C7_RATEIO"})
						
						dbSelectArea("SC1")
						SC1->( dbSetOrder(1) )
						
						For nI := 1 To Len(aItensSol)
							
							If SC1->( dbSeek(xFilial("SC1") + aItensSol[nI][1] + aItensSol[nI][2]) )
								
								AAdd(aColsSol, {})
								
								For nX := 1 To Len(aHeaderSol)
									
									If AllTrim(aHeaderSol[nX][2]) == "C7_ITEM"
										
										AAdd(ATail(aColsSol), StrZero(nI, TamSX3("C7_ITEM")[1]))
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_PRODUTO"
										
										AAdd(ATail(aColsSol), SC1->C1_PRODUTO)
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_DESCRI"
										
										AAdd(ATail(aColsSol), SC1->C1_DESCRI)
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_UM"
										
										AAdd(ATail(aColsSol), SC1->C1_UM)
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_QUANT"
										
										AAdd(ATail(aColsSol), aItensSol[nI][3])
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_PRECO"
										
										AAdd(ATail(aColsSol), IIf(Empty(SC1->C1_PRECO), aItensSol[nI][4], SC1->C1_PRECO))
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_TOTAL"
										
										AAdd(ATail(aColsSol), IIf(Empty(SC1->C1_TOTAL), aItensSol[nI][5], SC1->C1_TOTAL))
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_NUMSC"
										
										AAdd(ATail(aColsSol), SC1->C1_NUM)
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_ITEMSC"
										
										AAdd(ATail(aColsSol), SC1->C1_ITEM)
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_CC"	
										
										AAdd(ATail(aColsSol), SC1->C1_CC)
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_CONTA"
										
										AAdd(ATail(aColsSol), SC1->C1_CONTA)
										
									ElseIf AllTrim(aHeaderSol[nX][2]) == "C7_RATEIO"
										
										AAdd(ATail(aColsSol), SC1->C1_RATEIO)
										
									Else
										
										AAdd(ATail(aColsSol), CriaVar(aHeaderSol[nX][2], .T.))
										
									EndIf
									
								Next nX
								
								AAdd(ATail(aColsSol), .F.)
								
							EndIf
							
						Next nI
						
						oGetSol := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltSol, 000, 999, Nil, Nil, "AlwaysFalse", oLayPrd:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), aHeaderSol, aColsSol)
						oGetSol:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						
				oLayPrd:AddCollumn('COL2_LIN1', 40, .T., 'LIN1')
					
					oLayPrd:AddWindow('COL2_LIN1', 'WIN1_COL2_LIN1', "Rateio da Solicitação " + aItensSol[1][1], 100, .F., .T., , 'LIN1',)
						
						dbSelectArea("SX3")
						SX3->( dbSetOrder(2) )
						
						For nI := 1 To Len(aCmpRat)
							
							If SX3->( dbSeek(aCmpRat[nI]) )
									
								AAdd(aHeaderRat, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
								
							EndIf
							
						Next nI
						
						nPosRPerc  := AScan(aHeaderRat, {|x| AllTrim(x[2]) == "CH_PERC"})
						nPosRCC    := AScan(aHeaderRat, {|x| AllTrim(x[2]) == "CH_CC"})
						nPosRCta   := AScan(aHeaderRat, {|x| AllTrim(x[2]) == "CH_CONTA"})
						nPosRItCta := AScan(aHeaderRat, {|x| AllTrim(x[2]) == "CH_ITEMCTA"})
						nPosRCLVL  := AScan(aHeaderRat, {|x| AllTrim(x[2]) == "CH_CLVL"})
						nPosRItP   := AScan(aHeaderRat, {|x| AllTrim(x[2]) == "CH_ITEMPD"})
						
						For nI := 1 To Len(aItensSol)
							
							If SC1->( dbSeek(xFilial("SC1") + aItensSol[nI][1] + aItensSol[nI][2]) )
								
								dbSelectArea("SCX")
								SCX->( dbSetOrder(1) )
								SCX->( dbSeek(xFilial("SCX") + SC1->C1_NUM + SC1->C1_ITEM) )
								
								While !SCX->( Eof() ) .And. SCX->CX_FILIAL == xFilial("SCX") .And. SCX->CX_SOLICIT == SC1->C1_NUM .And. ;
									SCX->CX_ITEMSOL == SC1->C1_ITEM
										
									AAdd(aColsRat, {})
									
									For nX := 1 To Len(aHeaderRat)
										
										If AllTrim(aHeaderRat[nX][2]) == "CH_ITEMPD"
											
											AAdd(ATail(aColsRat), SCX->CX_ITEMSOL)
											
										ElseIf AllTrim(aHeaderRat[nX][2]) == "CH_ITEM"
											
											AAdd(ATail(aColsRat), SCX->CX_ITEM)
											
										ElseIf AllTrim(aHeaderRat[nX][2]) == "CH_PERC"
											
											AAdd(ATail(aColsRat), SCX->CX_PERC)
											
										ElseIf AllTrim(aHeaderRat[nX][2]) == "CH_CC"
											
											AAdd(ATail(aColsRat), SCX->CX_CC)
											
										ElseIf AllTrim(aHeaderRat[nX][2]) == "CH_CONTA"
											
											AAdd(ATail(aColsRat), SCX->CX_CONTA)
											
										ElseIf AllTrim(aHeaderRat[nX][2]) == "CH_ITEMCTA"
											
											AAdd(ATail(aColsRat), SCX->CX_ITEMCTA)
											
										ElseIf AllTrim(aHeaderRat[nX][2]) == "CH_CLVL"
											
											AAdd(ATail(aColsRat), SCX->CX_CLVL)
											
										Else
											
											AAdd(ATail(aColsRat), CriaVar(aHeaderRat[nX][2], .T.))
											
										EndIf
										
									Next nX
									
									AAdd(ATail(aColsRat), .F.)
									
									SCX->( dbSkip() )
									
								EndDo
								
							EndIf
							
						Next nI
						
						If Empty(aColsRat)
							
							AAdd(aColsRat, {StrZero(1, TamSX3("CH_ITEM")[1]), ;
								0, ;
								Space(TamSX3("CH_CC")[1]), ;
								Space(TamSX3("CH_CONTA")[1]), ;
								Space(TamSX3("CH_ITEMCTA")[1]), ;
								Space(TamSX3("CH_CLVL")[1]), ;
								.F.})
							
						EndIf
						
						oGetRat := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, /*GD_UPDATE + GD_DELETE + GD_INSERT*/, "AlwaysTrue", "AlwaysTrue", "+CH_ITEM", {}/*aAltRat*/, 000, 999, Nil, Nil, "AlwaysTrue", oLayPrd:GetWinPanel('COL2_LIN1', 'WIN1_COL2_LIN1', 'LIN1'), aHeaderRat, aColsRat)
						oGetRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						
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
					
					oImp := THButton():New(0, 0, "&Gerar Pedido", oPanelBot, {|| FwMsgRun(, {|| lRet := GeraPed()}, "Aguarde", "Gerando Pedido para a Solicitação..."), IIf(lRet, oDlgPrd:End(), )}, , , )
					oImp:nWidth  := 90
					oImp:nHeight := 10
					oImp:Align := CONTROL_ALIGN_RIGHT
					oImp:SetColor(RGB(002, 070, 112), )
	
	ACTIVATE MSDIALOG oDlgPrd CENTERED
	
Return lRet

Static Function GeraPed()
	
	// Faz Validação dos dados.
	
	Local nI
	Local nX
	Local nPed
	//Local nTotRat := 0
	Local cNumPed := CriaVar("C7_NUM",.T.)
	
	Local aCab
	Local aItens := {}
	Local aRat   := {}
	Local aItRat
	
	Local aAux
	Local lRet := .F.
	
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	
	If nPosPResp > 0
		
		For nI := 1 To Len(oGetSol:aCols)
			
			If Empty(oGetSol:aCols[nI][nPosPResp])
				
				Alert("O Responsável precisa ser informado em todos os itens.")
				
				Return .F.
				
			EndIf
			
		Next nI
		
	EndIf
	
	If Len(oGetRat:aCols) > 1
		
		For nI := 1 To Len(oGetRat:aCols)
			
			If !ATail(oGetRat:aCols[nI])
				
				//nTotRat += oGetRat:aCols[nI][nPosRPerc]
				
				If oGetRat:aCols[nI][nPosRPerc] == 0
					
					Alert("O Rateio na linha " + cValToChar(nI) + " não pode ser zero.")
					
					Return .F.
					
				ElseIf Empty(oGetRat:aCols[nI][nPosRCC]) .And. Empty(oGetRat:aCols[nI][nPosRConta])
					
					Alert("A Conta e/ou Centro de Custo precisam ser informados na linha " + cValToChar(nI) + ".")
					
					Return .F.
					
				EndIf
				
			EndIf
			
		Next nI
		
		/*If nTotRat # 100
			
			Alert("A soma dos percentuais de rateio devem totalizar 100.")
				
			Return .F.
			
		EndIf*/
		
	EndIf
	
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
	
	For nI := 1 To Len(oGetSol:aCols)
		
		If !ATail(oGetSol:aCols[nI])
			
			aAux := {{"C7_ITEM"   ,	oGetSol:aCols[nI][nPosPItem], Nil}, ; // Sequencial do Item
					 {"C7_PRODUTO",	oGetSol:aCols[nI][nPosPProd], Nil}, ; // Codigo do Produto
					 {"C7_QUANT"  ,	oGetSol:aCols[nI][nPosPQtde], Nil}, ; // Quantidade
					 {"C7_PRECO"  ,	oGetSol:aCols[nI][nPosPPrc] , Nil}, ; // Preco                   
					 {"C7_TOTAL"  ,	oGetSol:aCols[nI][nPosPTot] , Nil}, ; // Valor Liquido do pedido
					 {"C7_CONTA"  ,	oGetSol:aCols[nI][nPosPCta] , Nil}, ; // Valor Liquido do pedido
					 {"C7_CC"     ,	oGetSol:aCols[nI][nPosPCC]  , Nil}, ; // Valor Liquido do pedido
					 {"C7_DATPRF" ,	Date(), Nil}} // Data de Entrega
			
			If nPosPResp > 0
				
				AAdd(aAux, {"C7_ZRESPON", oGetSol:aCols[nI][nPosPResp], Nil})
				
			EndIf
			
			//If !Empty(oGetSol:aCols[nI][nPosPNumSC])
				
				AAdd(aAux, {"C7_NUMSC" , oGetSol:aCols[nI][nPosPNumSC], Nil})
				AAdd(aAux, {"C7_ITEMSC", oGetSol:aCols[nI][nPosPItSC] , Nil})
				AAdd(aAux, {"C7_QTDSOL", oGetSol:aCols[nI][nPosPQtde] , Nil})
				
			//EndIf
			
			AAdd(aItens, aAux)
			
		EndIf
		
	Next nI
	
	If Len(oGetRat:aCols) > 1
		
		For nX := 1 To Len(oGetSol:aCols)
			
			If oGetSol:aCols[nX][nPosRat] == "1"
				
				AAdd(aRat, {oGetSol:aCols[nX][nPosPItem], {}})
				
				For nI := 1 To Len(oGetRat:aCols)
					
					If oGetRat:aCols[nI][nPosRItP] == oGetSol:aCols[nX][nPosPItem]
						
						aItRat := {}
						
						aAdd(aItRat,{"CH_ITEM", StrZero(nI, TamSX3("CH_ITEM")[1]), Nil})
						aAdd(aItRat,{"CH_PERC", oGetRat:aCols[nI][nPosRPerc], Nil})
						
						If !Empty(oGetRat:aCols[nI][nPosRCC])
							aAdd(aItRat,{"CH_CC", oGetRat:aCols[nI][nPosRCC], Nil})
						EndIf
						
						If !Empty(oGetRat:aCols[nI][nPosRCta])
							aAdd(aItRat,{"CH_CONTA", oGetRat:aCols[nI][nPosRCta], Nil})
						EndIf
						
						If !Empty(oGetRat:aCols[nI][nPosRItCta])
							aAdd(aItRat,{"CH_ITEMCTA", oGetRat:aCols[nI][nPosRItCta], Nil})
						EndIf
						
						If !Empty(oGetRat:aCols[nI][nPosRCLVL])
							aAdd(aItRat,{"CH_CLVL", oGetRat:aCols[nI][nPosRCLVL], Nil})
						EndIf
						
						aAdd(ATail(aRat)[2], aItRat)
						
					EndIf
					
				Next nI
				
			EndIf
			
		Next nX
		
	Else
		
		aRat := Nil
		
	EndIf
	
	MSExecAuto({|v,x,y,z,w,k| MATA120(v,x,y,z,w,k)}, 1, aCab, aItens,3,, aRat)
	
	If lMsErroAuto
		
		cMsgPrd := U_GOXErAut(GetAutoGrLog())
		
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
			
			// Aqui deverá atualizar os dados em tela!!!!!!!
			// Trocar o aRelac a solicitação com o pedido
			// Assim como no aVinc
			
			For nI := 1 To Len(aRelac)
				
				For nPed := 1 To Len(aRelac[nI][2])
					
					If aRelac[nI][2][nPed][4] == "S"
						
						If aRelac[nI][2][nPed][1] == SC7->C7_NUMSC .And. aRelac[nI][2][nPed][2] == SC7->C7_ITEMSC
							
							aRelac[nI][2][nPed][1] := SC7->C7_NUM
							aRelac[nI][2][nPed][2] := SC7->C7_ITEM
							aRelac[nI][2][nPed][4] := "P"
							
						EndIf
						
					EndIf
					
				Next nPed
				
			Next nI
			
			For nI := 1 To Len(aItVin)
				
				If aItVin[nI][11] == "S" .And. aItVin[nI][5] == SC7->C7_NUMSC .And. aItVin[nI][6] == SC7->C7_ITEMSC
					
					aItVin[nI][5]  := SC7->C7_NUM
					aItVin[nI][6]  := SC7->C7_ITEM
					aItVin[nI][11] := "P"
					
				EndIf
				
			Next nI
			
			SC7->( dbSkip() )
			
		EndDo
		
		AtuPed()
		
		oBrwItVin:SetArray(aItVin)
		
		oBrwItVin:Refresh()
		
		lRet := .T.
		
	EndIf
	
	oMsgPrd:Refresh()
	
Return lRet

Static Function GetCCus1(nI)
	
	Local xRet := ""
	
	If ExistBlock("GOXXMCC1")
		
		xRet := ExecBlock("GOXXMCC1", .F., .F., {nI})
		
	EndIf
	
Return xRet

Static Function IsMultiXml(nPosXML)
	
	Local aRet := {.F., 0}
	
	
	
Return aRet
