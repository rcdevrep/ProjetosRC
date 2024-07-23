#INCLUDE "FILEIO.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "COMXCOL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SMS001   ºAutor  ³Deivys Joenck       º Data ³  10/28/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa importador de NF-e, CT-e, CC-e e Cancelamento     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Genérico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SMS001()

Local oDlgMain, oBmp
Local oPanelTot
Local aTotIniDoc
Local cArqTabXml
Local aStruXml
Local cArqTabFil
Local aStruFil
Local oNovo  := LoadBitmap(GetResources(), 'BR_VERDE')
Local oErro  := LoadBitmap(GetResources(), 'BR_VERMELHO')
Local oOK    := LoadBitmap(GetResources(), 'BR_AZUL')
Local oDesab := LoadBitmap(GetResources(), 'BR_CINZA')
Local lEmail
Local oTmpTabFil := Nil

Local cAliasSX2 := "SX2"
Local cAliasSIX := "SIX"

//////////Variáveis das tabelas
Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XSMSTB1", "")))
Private _cTab2 := Upper(AllTrim(GetNewPar("MV_XSMSTB2", "")))
Private _cTab3 := Upper(AllTrim(GetNewPar("MV_XSMSTB3", "")))
Private _cTab4 := Upper(AllTrim(GetNewPar("MV_XSMSTB4", "")))
Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
Private _cCmp2 := IIf(SubStr(_cTab2, 1, 1) == "S", SubStr(_cTab2, 2, 2), _cTab2)
Private _cCmp3 := IIf(SubStr(_cTab3, 1, 1) == "S", SubStr(_cTab3, 2, 2), _cTab3)
Private _cCmp4 := IIf(SubStr(_cTab4, 1, 1) == "S", SubStr(_cTab4, 2, 2), _cTab4)

/////////////////////////
Private aSize      := MsAdvSize()
Private oFont1     := TFont():New('Arial',,-12,,.T.)
Private oFont2     := TFont():New('Arial',,-11,,.T.)
Private cEntrada   := Space(200)
Private cSaida	   := Space(200)
Private cProc	   := Space(200)
Private cFil       := cFilAnt
Private cEmp       := FWGrpCompany()
Private cEmpName   := FWGrpName()
Private cFilName   := FWFilialName()
Private cCombo1    := "N"
Private cCombo2    := "N"
Private cError     := ""
Private cWarning   := ""
Private cEspNFe  := Space(5)
Private cEspCTe  := Space(5)
Private cTESCTe  := Space(3)  
Private cCCCTe   := Space(9)  
Private cTESNFe  := Space(3)
Private cCondCTe  := Space(3)
Private cContaFe := ""
Private cCustoFe := ""
Private cNatCTe  := Space(10)
Private oLayerNFe, oLayerCCe, oLayerCTe, oLayerCan, oLayerPen
Private oBrowseNFe, oBrowseCTe, oBrowseCCe, oBrowseCan, oBrowsePen
Private oMemoLog, cMemo, oTFolder, oPanelErr
Private oSay1, oSay2, oSay3, oSay4, oSay5, oSay6
Private lAglut     := .T.
Private lVldErro   := .F.
Private lVldErCNPJ := .F.
Private lVlErrMsg  := .F.
Private lPreNota   := .F.
Private cBrowse    := ""
Private aSM0       := FWLoadSM0()
Private cAliFil    := ""
Private oListXml
Private nTamCmpNF  := TamSX3("F1_DOC")[1]
Private nTamCmpSer := TamSX3("F1_SERIE")[1]
Private nDecVal    := TamSX3("D1_VUNIT")[2]
Private nDecQtd    := TamSX3("D1_QUANT")[2]
Private nDecTot    := TamSX3("D1_TOTAL")[2]
Private cMarca	   := GetMark()

Private nTimer     := 30000
Private lConfere   := .T.
Private lBtParam   := .F.
Private nTamNota   := 9
Private nTotQtdCTe := 0
Private nTotValCTe := 0
Private dDtVcto 	:= dDataBase
Private cValidad	:= Space(50)
Private cCteAgricopel 
PRIVATE lMarcCte	:= .T.
Private cProdBloq   := ''

	If Empty(_cTab1) .Or. Empty(_cTab2) .Or. Empty(_cTab3) .or. Empty(_cTab4)
		Aviso("Parâmetros de tabela", "É necessário informar os parâmetros das tabelas utilizadas pelo importador ('MV_XSMSTB1','MV_XSMSTB2','MV_XSMSTB3','MV_XSMSTB4') e executar o compatibilizador U_UPDSMS01.", {"Ok"}, 2)
		Return
	EndIf

	If (_cTab1)->(FieldPos(_cCmp1 + "_FILIAL")) == 0 .And. (_cTab1)->(FieldPos(_cCmp1 + "_CHAVE")) == 0 .And. (_cTab1)->(FieldPos(_cCmp1 + "_XML")) == 0
		Aviso("Atualização de Dicionário", "É necessário execução do compatibilizador U_UPDSMS01 para utilização desta rotina.", {"Ok"}, 2)
		Return
	EndIf                   

    // Baixar os XMLs do e-mail.
	// #METADATASQL
	IF GETNEWPAR("MV_IMPMAIL", .F.)    
	    DBSELECTAREA(cAliasSX2) // Cria registro na SX2 se não existir
    	DBSETORDER(1)
	    IF !DBSEEK('ZZ4')
    		RECLOCK(cAliasSX2,.T.)
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_CHAVE")), "ZZ4"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_PATH")), "\SIGAADV\"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_ARQUIVO")), "ZZ4010"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_NOME")), "E-MAILS IMPORTADOR DE E-MAIL"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_NOMESPA")), "E-MAILS IMPORTADOR DE E-MAIL"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_NOMEENG")), "E-MAILS IMPORTADOR DE E-MAIL"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_MODO")), "C"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_MODOUN")), "C"))
			(cAliasSX2)->(FieldPut((cAliasSX2)->(FieldPos("X2_MODOEMP")), "C"))
    		(cAliasSX2)->(MSUNLOCK())  

	    	RECLOCK(cAliasSIX,.T.)
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("INDICE")), "ZZ4"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("ORDEM")), "1"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("CHAVE")), "ZZ4_FILIAL+ZZ4_EMP+ZZ4_FIL"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("DESCRICAO")), "Empresa+Filial Email"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("DESCSPA")), "Empresa+Filial Email"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("DESCENG")), "Empresa+Filial Email"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("PROPRI")), "U"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("SHOWPESQ")), "S"))
	    	(cAliasSIX)->(MSUNLOCK())

    		RECLOCK((cAliasSIX),.T.)
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("INDICE")), "ZZ4"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("ORDEM")), "2"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("CHAVE")), "ZZ4_FILIAL+ZZ4_EMP+ZZ4_FIL+ZZ4_EMAIL"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("DESCRICAO")), "Empresa+Filial Email+E-MAIL"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("DESCSPA")), "Empresa+Filial Email+E-MAIL"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("DESCENG")), "Empresa+Filial Email+E-MAIL"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("PROPRI")), "U"))
			(cAliasSIX)->(FieldPut((cAliasSIX)->(FieldPos("SHOWPESQ")), "S"))
    		(cAliasSIX)->(MSUNLOCK())
	    ENDIF

    	DBSELECTAREA("ZZ4")  // Verifica se existe a conta de e-mail para a empresa e filial
	    DBSETORDER(1)
    	IF DBSEEK('  '+cEmpant+cFilant)
    		WHILE !ZZ4->(EOF())
	    		IF ZZ4->ZZ4_MSBLQL <> '1'
    				lEmail := .T.
    			ENDIF
    			ZZ4->(DBSKIP())
	    	ENDDO
    		IF lEmail
				MsgRun("Baixando e-mails, por favor aguarde...","Download do XML",{|| u_ImpMail()})
			ENDIF
		ENDIF
	ENDIF
	
	AjustaSX6()
	
	If TelaParam(.F.)           

		IF GETNEWPAR("MV_IMPMAIL", .F.)   // Melhoria para pegar automaticamente o caminho das pastas, quando utilizado a integração com o e-mail - Thiago SLA - 22/06/2016
			cEntrada := "\IMPMAIL\Empresa"+cEmpAnt+"\Filial"+cFilAnt+"\Novos\"
			cSaida   := "\IMPMAIL\Empresa"+cEmpAnt+"\Filial"+cFilAnt+"\Importados\"
			cProc    := "\IMPMAIL\Empresa"+cEmpAnt+"\Filial"+cFilAnt+"\Log\"
		ELSE
			cEntrada := IIf(SubStr(AllTrim(cEntrada), Len(AllTrim(cEntrada)), 1) == "\", PadR(cEntrada, 200), PadR(AllTrim(cEntrada) + "\", 200))
			cSaida   := IIf(SubStr(AllTrim(cSaida)  , Len(AllTrim(cSaida)), 1)   == "\", PadR(cSaida, 200),   PadR(AllTrim(cSaida) + "\", 200))
			cProc    := IIf(SubStr(AllTrim(cProc)   , Len(AllTrim(cProc)), 1)    == "\", PadR(cProc, 200),    PadR(AllTrim(cProc) + "\", 200))
		ENDIF

		cEntrada := Alltrim(cEntrada)
		cSaida   := Alltrim(cSaida)
		cProc    := Alltrim(cProc)

		nTimer   := GETMV("MV_XSMS003")
		lConfere := GetMV("MV_XSMS004")
		nTamNota := GetMV("MV_XSMS005")
		lBtParam := GetMV("MV_XSMS007")

		////////////////// Tabela dos xml's de outras filiais
		aStruFil := {{"ARQ", "C", 140, 0}}

		oTmpTabFil := FwTemporaryTable():New()
		oTmpTabFil:SetFields(aStruFil)
		oTmpTabFil:AddIndex("1", {"ARQ"})
		oTmpTabFil:Create()

		cAliFil := oTmpTabFil:GetAlias()

		dbSelectArea(cAliFil)
		(cAliFil)->( dbSetOrder(1) )
		// Carga das notas fiscais de entrada, cartas de correção, cancelamento e conhecimentos de Transporte
		Processa({|lEnd| CargaXML()}, "Aguarde...", "Processando XML's.", .F.)

		(_cTab4)->( dbGoTop() )
		aTotIniDoc := TotDocXml()
        
		DBSELECTAREA("SX6")
		DBSETORDER(1)
		IF DBSEEK("  "+"MV_XSMS010") .OR. DBSEEK(XFILIAL("SX6")+"MV_XSMS010")
	        IF __CUSERID $ GETMV("MV_XSMS010") // Valida o usuário que utilizará resolução diferenciada.
    	    	IF aSize[5] < VAL(GETMV("MV_XSMS011"))
					aSize[5] := VAL(GETMV("MV_XSMS011"))
					aSize[3] += 100
				ENDIF
    	    ENDIF
        ENDIF

		//Ajuste para telas com resolução inferior a 655
		nAjuste := 0 
		If aSize[3] < 655
			nAjuste := (655 - aSize[3])
		Endif 

        
		DEFINE MSDIALOG oDlgMain FROM aSize[7],0 TO aSize[3], aSize[5] TITLE 'Importador XML'  PIXEL
			oDlgMain:lEscClose := .F.

			oPanelTot := tPanel():New(0,0,,oDlgMain,,,,,,655-nAjuste,10,.T.,.F.)
			oPanelTot :Align := CONTROL_ALIGN_ALLCLIENT

			/////////////////////////////////////  CONSTRUÇÃO DO FOLDER
			oTFolder := tfolder():new( 11,0,{"NF-e","CT-e","CC-e","Cancelamento","XML's Pendentes"},,oDlgMain,,,,.T.,,655-nAjuste,285,,.T.)
			oTFolder:bChange := ({|| AtuBrowse()})

			/////////////////////////////////////////////////////////// NFE
			oLayerNFe := FWLayer():New()
			oLayerNFe:Init(oTFolder:aDialogs[1],.F.,.T.)
			oLayerNFe:AddLine('TOP'   , 20, .F.)
			oLayerNFe:AddLine('CENTER', 80, .T.)

			oLayerNFe:AddCollumn('NFE_INF', 100, .T., "TOP")
			oLayerNFe:AddCollumn('NFE_XML', 100, .T., "CENTER")
			
			cEspNfe := "SPED"
			oLayerNFe:AddWindow('NFE_INF', 'WIN_NFE_INF', "Informações adicionais da Nota Fiscal", 100, .F., .T.,, 'TOP',)
			@010,010 SAY "Espécie:"	      SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerNFe:GetWinPanel('NFE_INF', 'WIN_NFE_INF', 'TOP')
		  	@008,045 MSGET cEspNFe	      SIZE 015,009 PIXEL OF oLayerNFe:GetWinPanel('NFE_INF', 'WIN_NFE_INF', 'TOP') WHEN .T. F3 "42" VALID IIf(!Empty(cEspNFe), ExistCPO("SX5", "42" + cEspNFe), .T.) PICTURE "@!" HASBUTTON
			@010,100 SAY "Tipo da Nota: " SIZE 055,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerNFe:GetWinPanel('NFE_INF', 'WIN_NFE_INF', 'TOP')
			@008,145 COMBOBOX oCombo1 VAR cCombo1 ITEMS {"N=Normal", "D=Devolução", "B=Beneficiamento", "I=Compl. ICMS", "P=Compl. IPI", "C=Compl. Preço/Frete"} SIZE 60,10 PIXEL OF oLayerNFe:GetWinPanel('NFE_INF', 'WIN_NFE_INF', 'TOP')
			oChk := TCheckBox():New(009, 210, 'Pré-nota?',, oLayerNFe:GetWinPanel('NFE_INF', 'WIN_NFE_INF', 'TOP'), 60, 10,,,,,,,,.T.,,,)
			oChk:cToolTip  := "Insere a NFe como uma pré-nota de entrada?"
			oChk:bSetGet   := {|| lPreNota}
			oChk:bLClicked := {|| lPreNota := !lPreNota}

			cBrowse := "NFE"
			oBrowseNFe := FWMBrowse():New()
			oBrowseNFe:SetAlias(_cTab1)
			oBrowseNFe:SetMenuDef("SMS001")
			oBrowseNFe:SetDescription("Notas Fiscais a serem importadas")
			oBrowseNFe:SetOwner(oLayerNFe:GetColPanel('NFE_XML', "CENTER"))
			oBrowseNFe:DisableDetails()
			oBrowseNFe:DisableReport()
			oBrowseNFe:DisableConfig()
			oBrowseNFe:SetWalkThru(.F.)
			oBrowseNFe:SetAmbiente(.F.)
			oBrowseNFe:ForceQuitButton()
			oBrowseNFe:SetFixedBrowse(.T.)
			oBrowseNFe:bChange := ({|| IIf((_cTab1)->&(_cCmp1+"_TIPOEN") == "F", IIf(!(cCombo1 $ "I;P;C"), cCombo1 := "N",), IIf(cCombo1 <> "B", cCombo1 := "D",)), oCombo1:Refresh(), .T.})
			SetFieldsBrowse(oBrowseNFe, "NFE")
			oBrowseNFe:AddLegend(_cCmp1+"_SIT=='1'", "BLUE", "Normal")
			oBrowseNFe:AddLegend(_cCmp1+"_SIT=='3'", "RED" , "Tentativa de importação com erro")
			oBrowseNFe:SetFilterDefault(GetFilterXml("NFE", "1;3"))
			oBrowseNFe:Activate()
			AtuBrowse()
			//oBrowseNFe:ReFresh()

			/////////////////////////////////////////////////////////// Conhecimento de Transporte
			oLayerCTe := FWLayer():New()
			oLayerCTe:Init(oTFolder:aDialogs[2],.F.,.T.)
			oLayerCTe:AddLine('TOP'   , 25, .F.)
			oLayerCTe:AddLine('CENTER', 75, .T.)

			oLayerCTe:AddCollumn('CTE_INF', 100, .T., "TOP")
			oLayerCTe:AddCollumn('CTE_XML', 100, .T., "CENTER")

			cEspCTe := "CTE"
			oLayerCTe:AddWindow('CTE_INF', 'WIN_CTE_INF', "Informações adicionais do Conhecimento de Transporte", 100, .F., .T.,, 'TOP',)
			@010,010 SAY "Espécie:" SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@008,045 MSGET cEspCTe  SIZE 015,009 PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP') WHEN .T. F3 "42" VALID IIf(!Empty(cEspCTe), ExistCPO("SX5", "42" + cEspCTe), .T.) PICTURE "@! XXXXX" HASBUTTON
			oChk := TCheckBox():New(009,110, 'Aglutina Títulos?',, oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP'), 60, 110,,,,,,,,.T.,,,)
			oChk:cToolTip  := "Conhecimentos de Transporte devem gerar apenas um título o valor total?"
			oChk:bSetGet   := {|| lAglut}
			oChk:bLClicked := {|| lAglut := !lAglut}

			@023,010 SAY "TES:" 	SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@021,045 MSGET cTESCTe  SIZE 015,009 PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP') WHEN .T. F3 "SF4" VALID IIf(!Empty(cTESCTe), ExistCPO("SF4", cTESCTe), .T.) PICTURE "@! XXX" HASBUTTON
			@023,110 SAY "Cond.Pgto.:" 	SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@021,145 MSGET cCondCTe  	SIZE 015,009 PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP') WHEN .T. F3 "SE4" VALID IIf(!Empty(cCondCTe), ExistCPO("SE4", cCondCTe), .T.) PICTURE "@! XXX" HASBUTTON
			@023,200 SAY "Nat.Oper.:" 	SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@021,235 MSGET cNatCTe  	SIZE 045,009 PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP') WHEN .T. F3 "SED" VALID IIf(!Empty(cNatCTe), ExistCPO("SED", cNatCTe), .T.) PICTURE "@! XXXXXXXXXX" HASBUTTON
			@023,300 SAY "CC.:" 		SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@021,325 MSGET cCCCTe  		SIZE 045,009 PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP') WHEN .T. F3 "CTT" VALID IIf(!Empty(cNatCTe), ExistCPO("CTT", cCCCTe) .And. ValCC() , .T.) PICTURE "@! XXXXXXXXXX" HASBUTTON


			@010,aSize[6]-090 SAY "Total de CTe's:" SIZE 135,008 FONT oFont1 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@022,aSize[6]-090 SAY "Valor total: R$" SIZE 135,008 FONT oFont1 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@010,aSize[6]-030 SAY Transform(nTotQtdCTe,'@R 99,999,999')	SIZE 135,008 FONT oFont1 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')
			@022,aSize[6]-030 SAY Transform(nTotValCTe,'@R 999,999.99') SIZE 135,008 FONT oFont1 COLOR CLR_BLUE PIXEL OF oLayerCTe:GetWinPanel('CTE_INF', 'WIN_CTE_INF', 'TOP')

			cBrowse := "CTE"
			oBrowseCTe := FWMarkBrowse():New()
			oBrowseCTe:SetAlias(_cTab1)
			oBrowseCTe:SetMenuDef("SMS001")
			oBrowseCTe:SetDescription("Conhecimentos de transporte a serem importados")
			oBrowseCTe:SetOwner(oLayerCTe:GetColPanel('CTE_XML', "CENTER"))
			oBrowseCTe:DisableDetails()
			oBrowseCTe:DisableReport()
			oBrowseCTe:DisableConfig()
			oBrowseCTe:SetWalkThru(.F.)
			oBrowseCTe:SetAmbiente(.F.)
			oBrowseCTe:ForceQuitButton()
			SetFieldsBrowse(oBrowseCTe, "CTE")
			oBrowseCTe:AddLegend(_cCmp1+"_SIT=='1'", "BLUE", "Normal")
			oBrowseCTe:AddLegend(_cCmp1+"_SIT=='3'", "RED" , "Tentativa de importação com erro")
			oBrowseCTe:SetFieldMark(_cCmp1+"_OKCTE")
			oBrowseCTe:SetAllMark({|| })
			oBrowseCTe:SetCustomMarkRec({|| SetMarkNf() })
			oBrowseCTe:Activate()

			/////////////////////////////////////////////////////////// Carta de Correção
			oLayerCCe := FWLayer():New()
			oLayerCCe:Init(oTFolder:aDialogs[3],.F.,.T.)
			oLayerCCe:AddLine('CENTER', 100, .F.)
			oLayerCCe:AddCollumn('CARTA_XML', 100, .T., "CENTER")

			cBrowse := "CCE"
			oBrowseCCe := FWMBrowse():New()
			oBrowseCCe:SetAlias(_cTab1)
			oBrowseCCe:SetMenuDef("SMS001")
			oBrowseCCe:SetDescription("Cartas de Correção a serem importadas")
			oBrowseCCe:SetOwner(oLayerCCe:GetColPanel('CARTA_XML', "CENTER"))
			oBrowseCCe:DisableDetails()
			oBrowseCCe:DisableReport()
			oBrowseCCe:DisableConfig()
			oBrowseCCe:SetWalkThru(.F.)
			oBrowseCCe:SetAmbiente(.F.)
			oBrowseCCe:ForceQuitButton()
			oBrowseCCe:SetFixedBrowse(.T.)
			SetFieldsBrowse(oBrowseCCe, "CCE")
			oBrowseCCe:AddLegend(_cCmp1+"_SIT=='1'", "BLUE", "Normal")
			oBrowseCCe:AddLegend(_cCmp1+"_SIT=='3'", "RED" , "Tentativa de importação com erro")
			oBrowseCCe:Activate()

			/////////////////////////////////////////////////////////// Cancelamento
			oLayerCan := FWLayer():New()
			oLayerCan:Init(oTFolder:aDialogs[4],.F.,.T.)
			oLayerCan:AddLine('CENTER', 100, .F.)
			oLayerCan:AddCollumn('CAN_XML', 100, .T., "CENTER")

			cBrowse := "CAN"
			oBrowseCan := FWMBrowse():New()
			oBrowseCan:SetAlias(_cTab1)
			oBrowseCan:SetMenuDef("SMS001")
			oBrowseCan:SetDescription("Cancelamentos a serem importados")
			oBrowseCan:SetOwner(oLayerCan:GetColPanel('CAN_XML', "CENTER"))
			oBrowseCan:DisableDetails()
			oBrowseCan:DisableReport()
			oBrowseCan:DisableConfig()
			oBrowseCan:SetWalkThru(.F.)
			oBrowseCan:SetAmbiente(.F.)
			oBrowseCan:ForceQuitButton()
			oBrowseCan:SetFixedBrowse(.T.)
			SetFieldsBrowse(oBrowseCan, "CAN")
			oBrowseCan:AddLegend(_cCmp1+"_SIT=='1'", "BLUE", "Normal", "1")
			oBrowseCan:AddLegend(_cCmp1+"_SIT=='3'", "RED" , "Tentativa de importação com erro", "1")
			oBrowseCan:AddLegend(_cCmp1+"_TPCAN=='N'", "WHITE" , "Cancelamento de Nota Fiscal", "2")
			oBrowseCan:AddLegend(_cCmp1+"_TPCAN=='C'", "YELLOW", "Cancelamento de Conhecimento de Transporte", "2")
			oBrowseCan:Activate()

			/////////////////////////////////////////////////////////// XML's Pendentes
			oLayerPen := FWLayer():New()
			oLayerPen:Init(oTFolder:aDialogs[5],.F.,.T.)
			oLayerPen:AddLine('CENTER', 100, .F.)
			oLayerPen:AddCollumn('PEN_XML', 100, .T., "CENTER")

			cBrowse := "PEN"
			oBrowsePen := FWMarkBrowse():New()
			oBrowsePen:SetAlias(_cTab4)
			oBrowsePen:SetMenuDef("SMS001")
			oBrowsePen:SetDescription("XML Pendentes")
			oBrowsePen:SetOwner(oLayerPen:GetColPanel('PEN_XML', "CENTER"))
			oBrowsePen:DisableDetails()
			oBrowsePen:DisableReport()
			oBrowsePen:DisableConfig()
			oBrowsePen:SetWalkThru(.F.)
			oBrowsePen:SetAmbiente(.F.)
			oBrowsePen:ForceQuitButton()
			SetFieldsBrowse(oBrowsePen, "PEN")
			oBrowsePen:AddLegend(_cCmp4+"_OK <> ' '", "BLUE", "Normal")
			oBrowsePen:SetFieldMark(_cCmp4+"_OK")
			oBrowsePen:SetAllMark({|| })
			oBrowsePen:SetCustomMarkRec({|| SetMarkPn() })
			oBrowsePen:Activate()

		ACTIVATE MSDIALOG oDlgMain CENTERED

		oXml := Nil
		DelClassIntf()
		(_cTab4)->( dbCloseArea() )
		(cAliFil)->( dbCloseArea() )

		oTmpTabFil:Delete()
		FreeObj(oTmpTabFil)
	Else
		MsgInfo("Parâmtetros do importador NFE não foram definidos.")
	EndIf

Return()

///////////////////////////////////////////////
Static Function AtuBrowse()

Local nFolopc    := oTFolder:nOption
Local aTotIniDoc := TotDocXml()

Do Case
	Case nFolopc == 1
		oBrowseNFe:SetFilterDefault(GetFilterXml("NFE", "1;3"))
		oBrowseNFe:ReFresh()
	Case nFolopc == 2
		oBrowseCTe:SetFilterDefault(GetFilterXml("CTE", "1;3"))
		oBrowseCTe:ReFresh()
	Case nFolopc == 3
		oBrowseCCe:SetFilterDefault(GetFilterXml("CCE", "1;3"))
		oBrowseCCe:ReFresh()
	Case nFolopc == 4
		oBrowseCan:SetFilterDefault(GetFilterXml("CAN", "1;3"))
		oBrowseCan:ReFresh()
	Case nFolopc == 5
		oBrowsePen:ReFresh()
EndCase

nTotQtdCTe := 0
nTotValCTe := 0

Return()

///////////////////////////////////////
Static Function GetFilterXml(cCargo, cSit)

Local cKey    := cCargo
Local aCargo  := {"NFE", "CTE", "CCE", "", "CAN"}
Local cFilter := _cTab1 + "->" + _cCmp1 + "_FILIAL == '" + cFil + "' "
Local aSit    := StrTokArr(cSit, ";")
Local nI

	For nI := 1 To Len(aSit)

		If nI == 1
			cFilter += ".And. ("
		Else
			cFilter += ".Or."
		EndIf

		cFilter += " " + _cTab1 + "->" + _cCmp1 + "_SIT == '" + aSit[nI] + "'"
		If nI == Len(aSit)
			cFilter += ")"
		EndIf

	Next nI

	cFilter += ".And. " + _cTab1 + "->" + _cCmp1 + "_TIPO == '" + cValToChar(AScan(aCargo, {|x| x == cKey })) + "'"

Return cFilter

//////////////////////////////////////////////
Static Function SetFieldsBrowse(oBrowse, cType)

Local aFields := {}
Local aNotCol := {{"NFE", {_cCmp1+"_TRIB",  _cCmp1+"_DSEVEN", _cCmp1+"_CHAVE",  _cCmp1+"_CCECOR", _cCmp1+"_OKCTE"}},;
				  {"CTE", {_cCmp1+"_OKCTE", _cCmp1+"_TOTITE",_cCmp1+"_TOTIPI", _cCmp1+"_DSEVEN", _cCmp1+"_CHAVE",  _cCmp1+"_CCECOR"}},;
				  {"CCE", {_cCmp1+"_OKCTE", _cCmp1+"_DOC",    _cCmp1+"_SERIE",  _cCmp1+"_TOTITE", _cCmp1+"_TOTIPI", _cCmp1+"_TRIB",   _cCmp1+"_NATOP", _cCmp1+"_TOTVAL", _cCmp1+"_TOTITE", _cCmp1+"_TOTICM", _cCmp1+"_CODEMI", _cCmp1+"_LOJEMI", _cCmp1+"_EMIT"}},;
				  {"CAN", {_cCmp1+"_OKCTE", _cCmp1+"_TOTITE", _cCmp1+"_TOTIPI", _cCmp1+"_TRIB",   _cCmp1+"_NATOP",  _cCmp1+"_TOTVAL", _cCmp1+"_TOTITE", _cCmp1+"_DSEVEN", _cCmp1+"_CHAVE", _cCmp1+"_CCECOR"}},;
				 }
Local nPos := 0

Local _aCampoSX3 := {}
Local _cCampoSX3 := ""
Local _nX        := 0

	If (cType == "PEN")
		_aCampoSX3 := U_XAGSX3(_cTab4)
		
		For _nX := 1 To Len(_aCampoSX3)
			_cCampoSX3 := _aCampoSX3[_nX]

			If (GetSX3Cache(_cCampoSX3, "X3_BROWSE") == "S")
				AAdd(aFields, _cCampoSX3)
			EndIf
		End
	Else
		nPos := AScan(aNotCol, {|x| x[1] == cType})
		_aCampoSX3 := U_XAGSX3(_cTab1)
		
		For _nX := 1 To Len(_aCampoSX3)
			_cCampoSX3 := _aCampoSX3[_nX]

			If (GetSX3Cache(_cCampoSX3, "X3_BROWSE") == "S") .And. (AScan(aNotCol[nPos, 2], {|x| x == _cCampoSX3}) == 0)
				AAdd(aFields, _cCampoSX3)
			EndIf
		End
	Endif

	oBrowse:SetOnlyFields(aFields)

Return

///////////////////////////////////////////
Static Function SetMarkNf()

Local lIsMark
Local cFornCTE := (_cTab1)->&(_cCmp1+"_CODEMI")+(_cTab1)->&(_cCmp1+"_LOJEMI")
Local aAreaSF1 := (_cTab1)->(GetArea())

	lIsMark := oBrowseCTe:IsMark(oBrowseCTe:Mark())
	If !lIsMark
		IF lMarcCte
			If MsgYesNo("Deseja marcar todos os CTe's para o emitente "+(_cTab1)->&(_cCmp1+"_CODEMI")+"/"+(_cTab1)->&(_cCmp1+"_LOJEMI")+"?", "Aviso")
				(_cTab1)->(dbGoTop())
				While !(_cTab1)->(EOF())
					If (_cTab1)->&(_cCmp1+"_CODEMI")+(_cTab1)->&(_cCmp1+"_LOJEMI")==cFornCTE
						RecLock(_cTab1, .F.)
						(_cTab1)->&(_cCmp1+"_OKCTE") := oBrowseCTe:Mark()
						(_cTab1)->( MSUnlock() )
						nTotQtdCTe ++
						nTotValCTe += (_cTab1)->&(_cCmp1+"_TOTVAL")
					Endif
					(_cTab1)->(dbSkip())
				Enddo
		Else
			RecLock(_cTab1, .F.)
			(_cTab1)->&(_cCmp1+"_OKCTE") := IIf(lIsMark, Space(2), oBrowseCTe:Mark())
			(_cTab1)->( MSUnlock() )
			nTotQtdCTe ++
			nTotValCTe += (_cTab1)->&(_cCmp1+"_TOTVAL")
			lMarcCte := .F.
		EndIf
	ELSE
		RecLock(_cTab1, .F.)
		(_cTab1)->&(_cCmp1+"_OKCTE") := IIf(lIsMark, Space(2), oBrowseCTe:Mark())
		(_cTab1)->( MSUnlock() )
		nTotQtdCTe ++
		nTotValCTe += (_cTab1)->&(_cCmp1+"_TOTVAL")
		lMarcCte := .F.
	ENDIF
//		lMarcCte := .F.
		cMarca := oBrowseCTE:Mark()
	Else
		If MsgYesNo("Deseja desmarcar todos os CTe's para o emitente "+(_cTab1)->&(_cCmp1+"_CODEMI")+"/"+(_cTab1)->&(_cCmp1+"_LOJEMI")+"?", "Aviso")

			(_cTab1)->(dbGoTop())
			While !(_cTab1)->(EOF())
				If (_cTab1)->&(_cCmp1+"_CODEMI")+(_cTab1)->&(_cCmp1+"_LOJEMI")==cFornCTE
					RecLock(_cTab1, .F.)
					(_cTab1)->&(_cCmp1+"_OKCTE") := Space(2)
					(_cTab1)->( MSUnlock() )

					nTotQtdCTe --
					nTotValCTe -= (_cTab1)->&(_cCmp1+"_TOTVAL")
				Endif
				(_cTab1)->(dbSkip())
			Enddo

		Else

			RecLock(_cTab1, .F.)
			(_cTab1)->&(_cCmp1+"_OKCTE") := IIf(lIsMark, Space(2), oBrowseCTe:Mark())
			(_cTab1)->( MSUnlock() )

			nTotQtdCTe --
			nTotValCTe -= (_cTab1)->&(_cCmp1+"_TOTVAL")

		EndIf
	Endif
	cMarca := oBrowseCTE:Mark()

	RestArea(aAreaSF1)
	oBrowseCTe:Refresh()

Return

////////////////////////////////////

Static Function XmlTabLeg()

BrwLegenda("Legenda", "Situações", {{"BR_AZUL","XML Normal"}, {"BR_VERMELHO","XML com erro"}, {"BR_CINZA", "Desabilitado"}})

Return()

///////////////////////////////////////////
Static Function SetMarkPn()

Local lIsMark
Local aAreaTB4 := (_cTab4)->(GetArea())

	lIsMark := oBrowsePen:IsMark(oBrowsePen:Mark())
	If !lIsMark
		If MsgYesNo("Deseja marcar todos os registros?", "Aviso")

			(_cTab4)->(dbGoTop())
			While !(_cTab4)->(EOF())
				RecLock(_cTab4, .F.)
				(_cTab4)->&(_cCmp4+"_OK") := oBrowsePen:Mark()
				(_cTab4)->( MSUnlock() )
				(_cTab4)->(dbSkip())
			Enddo

		Else

			RecLock(_cTab4, .F.)
			(_cTab4)->&(_cCmp4+"_OK") := IIf(lIsMark, Space(2), oBrowsePen:Mark())
			(_cTab4)->( MSUnlock() )

		EndIf
		cMarca := oBrowsePen:Mark()
	Else
		If MsgYesNo("Deseja desmarcar todos os registros?", "Aviso")

			(_cTab4)->(dbGoTop())
			While !(_cTab4)->(EOF())
				RecLock(_cTab4, .F.)
				(_cTab4)->&(_cCmp4+"_OK") := Space(2)
				(_cTab4)->( MSUnlock() )
				(_cTab4)->(dbSkip())
			Enddo

		Else

			RecLock(_cTab4, .F.)
			(_cTab4)->&(_cCmp4+"_OK") := IIf(lIsMark, Space(2), oBrowsePen:Mark())
			(_cTab4)->( MSUnlock() )

		EndIf
	Endif
	cMarca := oBrowsePen:Mark()

	RestArea(aAreaTB4)
	oBrowsePen:Refresh()

Return()

////////////////////////////////////

Static Function ShowXmlErr(aErro, cArq)
Local oDlg
Local cInfo := ""
Local nI

Default cArq  := ""

	For nI := 1 To Len(aErro)

		If Empty(cArq) .Or. Lower(aErro[nI][1]) == Lower(cArq)
			cInfo += "-" + aErro[nI][2] + CRLF
		EndIf

	Next nI

	If !Empty(cInfo)
		cInfo := "Erros: " + CRLF + cInfo
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Erro ao importar" From 0,0 To 30, 80

		oPanelA := tPanel():New(10,10,,oDlg,,,,,,10,10,.F.,.F.)
		oPanelA:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelB := tPanel():New(0,0,,oDlg,,,,,,20,20,.F.,.F.)
		oPanelB:Align := CONTROL_ALIGN_BOTTOM

	    oTMultiget := TMultiget():New(06, 06, {|u| If(Pcount()>0, cInfo:=u, cInfo)},;
	                           oPanelA, 265, 105,,,,,, .T.,,,,,, .T.)
		oTMultiget:Align := CONTROL_ALIGN_ALLCLIENT
		oTMultiget:EnableVScroll(.T.)
		oTMultiget:EnableHScroll(.T.)

		oButtonOK := tButton():New(5, 5, 'OK', oPanelB, {|| oDlg:End()}, 25, 10,,,,  .T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

//////////////////////////////////////
Static Function SetStatusXML(cCargo, cStatus)

	RecLock(_cTab1, .F.)
	(_cTab1)->&(_cCmp1+"_SIT") := cStatus
	(_cTab1)->( MSUnlock() )

Return()

//////////////////////////////////////
Static Function ExcluirXML()

	CursorWait()
	If !(_cTab1)->( Eof() )

		If !MsgYesNo("Deseja excluir o Xml Selecionado?", "Exclusão de registro")
			CursorArrow()
			Return
		EndIf

		RecLock(_cTab1, .F.)
		dbDelete()
		(_cTab1)->( MSUnlock() )
		AtuBrowse()

	Else
		MsgInfo("É necessário selecionar um XML para excluir")
	EndIf
	CursorArrow()

Return()

//////////////////////////////////////
Static Function RECICLAXML()

Local nRegs		:= 0

	CursorWait()

	If MsgYesNo("Confirma a reciclagem dos documentos selecionados?",STR0022) //--  # Atenção
		(_cTab4)->(dbEval({|| nRegs++},{|| &(_cCmp4+"_OK") == cMarca}))
		(_cTab4)->(dbGoTop())
		Processa({|| u_RecDocs(nRegs),"Exclusão de Pendentes" +" - " +STR0023})
	EndIf

	CursorArrow()

Return()

//////////////////////////////////////

Static Function ExcluirPEN()

Local nRegs		:= 0

	CursorWait()

	If MsgYesNo("Confirma a exclusão dos documentos selecionados?",STR0022) //--  # Atenção
		(_cTab4)->(dbEval({|| nRegs++},{|| &(_cCmp4+"_OK") == cMarca}))
		(_cTab4)->(dbGoTop())
		Processa({|| u_ExclDocs(nRegs),"Exclusão de Pendentes" +" - " +STR0023})
	EndIf

	CursorArrow()

Return()

//////////////////////////////////////
user Function RECDOCS(nRegs)

Local nX	 	:= 0
Local nCount 	:= 0

ProcRegua(nRegs)

While !(_cTab4)->(EOF())

	IncProc(STR0024 +AllTrim((_cTab4)->&(_cCmp4+"_ARQ"))+ "(" +StrZero(nCount,2) +STR0025 +StrZero(nRegs,3) +")") //-- Processando documento # de

	If ((_cTab4)->&(_cCmp4+"_OK") == cMarca)
		If File(cEntrada + alltrim((_cTab4)->&(_cCmp4+"_ARQ")))
			RecLock((_cTab4),.F.)
			dbDelete()
			(_cTab4)->(MsUnLock())
		Else
			Alert("***Não foi possível reciclar o arquivo, XML não será importado. Identificação do erro: " + cValToChar(FError()), 1)
			Return {.F., ""}
		EndIf

		lRet := .T.
		nCount++
	endif
(_cTab4)->(DBSKIP())
enddo

// leio novamente o XML
ReCarga()

Return()

//////////////////////////////////////

user Function EXCLDOCS(nRegs)

Local nX	 	:= 0
Local nCount 	:= 0

ProcRegua(nRegs)

While !(_cTab4)->(EOF())

	IncProc(STR0024 +AllTrim((_cTab4)->&(_cCmp4+"_ARQ"))+ "(" +StrZero(nCount,2) +STR0025 +StrZero(nRegs,3) +")") //-- Processando documento # de

	If ((_cTab4)->&(_cCmp4+"_OK") == cMarca)

		__CopyFile(cEntrada + alltrim((_cTab4)->&(_cCmp4+"_ARQ")), cProc + alltrim((_cTab4)->&(_cCmp4+"_ARQ")))
		nErro := FError()

		If File(cProc + alltrim((_cTab4)->&(_cCmp4+"_ARQ")))
			FErase(cEntrada + alltrim((_cTab4)->&(_cCmp4+"_ARQ")))
			RecLock((_cTab4),.F.)
			(_cTab4)->&(_cCmp4+"_DTDEL") 	:= DATE()
			(_cTab4)->&(_cCmp4+"_HRDEL") 	:= TIME()
			(_cTab4)->&(_cCmp4+"_USUDEL") 	:= cUserName
			(_cTab4)->&(_cCmp4+"_OK")		:= ''
			dbDelete()
			(_cTab4)->(MsUnLock())
		Else
			Alert("***Não foi possível mover o arquivo, XML não será importado e o arquivo continuará no diretório de origem. Identificação do erro: " + cValToChar(FError()), 1)
			Return {.F., ""}
		EndIf

		lRet := .T.
		nCount++
	endif
(_cTab4)->(DBSKIP())
enddo

Return()

//////////////////////////////////////
Static Function ImportaXML()

Local nFolopc := oTFolder:nOption 

Do Case
	Case nFolopc == 1
		If lPreNota
			If cCombo1 $ "I;P;C"
				Aviso("Importação de Pré-nota", "Somente é possível importar pré-notas para os tipos 'Normal', 'Devolução', 'Beneficiamento'.", {"Ok"}, 2)
				Return()
			EndIf
		Endif
		//ImportarNFe()
		If cCombo1 $ "I;P;C"
			ImportNFeC()
		ElseIf cCombo1 $ "D;B"
			ImportNFeD()
		Else
			ImportarNFe()
		EndIf
	Case nFolopc == 2
		ImportarCTe()
	Case nFolopc == 3
		ImportarCCe()
	Case nFolopc == 4
		ImportarCan()
EndCase

oXml := Nil
AtuBrowse()
DelClassIntf()

Return()

///////////////////////////////////////
// Carga inicial dos XML da pasta de entradas
Static Function ReCarga()

	Processa({|lEnd| CargaXML()}, "Aguarde...", "Processando XML's.", .F.)
	AtuBrowse()

Return(.T.)

//////////////////////////////////////////////////

Static Function ExibeInfo(cCmp)
Local oDlg
Local cInfo
Local cDesc := ""

	If (_cTab1)->( Eof() )
		MsgInfo("É necessário selecionar um registro válido da tabela.")
		Return
	EndIf

	cInfo := &("(_cTab1)->" + cCmp)

	cDesc := GetSX3Cache(cCmp, "X3_DESCRIC")

	DEFINE MSDIALOG oDlg TITLE "Visualizar - " + cDesc From 0,0 To 30, 80

		oPanelA := tPanel():New(10,10,,oDlg,,,,,,10,10,.F.,.F.)
		oPanelA:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelB := tPanel():New(0,0,,oDlg,,,,,,20,20,.F.,.F.)
		oPanelB:Align := CONTROL_ALIGN_BOTTOM

	    oTMultiget := TMultiget():New(06, 06, {|u| If(Pcount()>0, cInfo:=u, cInfo)},;
	                           oPanelA, 265, 105,,,,,, .T.,,,,,, .T.)
		oTMultiget:Align := CONTROL_ALIGN_ALLCLIENT

		oTMultiget:EnableVScroll(.T.)
		oTMultiget:EnableHScroll(.T.)

		oButtonOK := tButton():New(5, 5, 'OK', oPanelB, {|| oDlg:End()}, 25, 10,,,,  .T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

//////////////////////////////////////////////////

// Criação de tela para alimentação dos parâmetros
Static Function TelaParam(lParam)

Local oDlgParam, oPanel2, oPanel3
Local oChk, oChl
Local cEntradaOld
Local cSaidaOld
Local cProcOld
Local lRet := .F.

Default lParam := .F.

	cEntrada := PadR(GETMV("MV_XSMS001"), 200)
	cSaida   := PadR(GETMV("MV_XSMS002"), 200)
	cProc    := PadR(GETMV("MV_XSMS006"), 200)

	cEntradaOld := cEntrada
	cSaidaOld   := cSaida
	cProcOld    := cProc

	If (Empty(Alltrim(cEntrada)) .Or. Empty(AllTrim(cSaida)) .Or. Empty(AllTrim(cProc))) .OR. lParam

		DEFINE MSDIALOG oDlgParam FROM 0,0 TO 250,470 TITLE 'Parâmetros de Importação' PIXEL
		oPanel2 := tPanel():New(0,0,"",oDlgParam,,,,,CLR_WHITE,0,125,.T.,.T.)
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT


		@015,020 SAY "Entrada:"		SIZE 035,008 COLOR CLR_BLUE PIXEL OF oPanel2
	  	@013,055 MSGET cEntrada 	SIZE 160,009 PIXEL OF oPanel2 VALID (ValidaDir(cEntrada,.F.)) PICTURE '@!'
	  	@030,020 SAY "Saída:   "	SIZE 035,008 COLOR CLR_BLUE PIXEL OF oPanel2
	  	@028,055 MSGET cSaida		SIZE 160,009 PIXEL OF oPanel2 VALID (ValidaDir(cSaida,.F.))   PICTURE '@!'
 		@045,020 SAY "Processados:" SIZE 035,008 COLOR CLR_BLUE PIXEL OF oPanel2
	  	@043,055 MSGET cProc		SIZE 160,009 PIXEL OF oPanel2 VALID (ValidaDir(cProc,.F.))    PICTURE '@!'

		@060,020 SAY "Timer Atual.:" 	SIZE 035,008 COLOR CLR_BLUE PIXEL OF oPanel2
	  	@058,055 MSGET nTimer		 	SIZE 040,009 PIXEL OF oPanel2 PICTURE '@9'
		@060,140 SAY "Tamanho Nº. NFe:" SIZE 045,008 COLOR CLR_BLUE PIXEL OF oPanel2
	  	@058,190 MSGET nTamNota			SIZE 025,009 PIXEL OF oPanel2 VALID (!Vazio()) PICTURE '@9'

		oChk := TCheckBox():New(075,020, 'Confere NFe?',, oPanel2, 100, 210,,,,,,,,.T.,,,)
		oChk:cToolTip  := ParamDesc("MV_XSMS004")
		oChk:bSetGet   := {|| lConfere }
		oChk:bLClicked := {|| lConfere := !lConfere}

		oChl := TCheckBox():New(075,120, 'Botão Parâmetros?',, oPanel2, 100, 210,,,,,,,,.T.,,,)
		oChl:cToolTip  := ParamDesc("MV_XSMS007")
		oChl:bSetGet   := {|| lBtParam }
		oChl:bLClicked := {|| lBtParam := !lBtParam}

		oPanel3 := tPanel():New(0,0,"",oDlgParam,,,,,CLR_WHITE,0,33,.T.)
		oPanel3:Align := CONTROL_ALIGN_BOTTOM
		DEFINE SBUTTON FROM 012,165 TYPE 1 ACTION (lRet := GravaParam(),oDlgParam:End()) ENABLE OF oPanel3
		DEFINE SBUTTON FROM 012,195 TYPE 2 ACTION (lRet := .F.,oDlgParam:End()) ENABLE OF oPanel3

		ACTIVATE MSDIALOG oDlgParam CENTERED

	Else
		lRet := .T.
	EndIf

	If lRet
		cEntrada := AllTrim(cEntrada)
		cSaida   := AllTrim(cSaida)
		cProc    := AllTrim(cProc)
	Else
		cEntrada := AllTrim(cEntradaOld)
		cSaida   := AllTrim(cSaidaOld)
		cProc    := AllTrim(cProcOld)
	EndIf

Return(lRet)

//////////////////////////////////////////////////

//Grava os parâmetros informados e fecha a tela
Static Function GravaParam()

	PUTMV("MV_XSMS001", cEntrada)
	PUTMV("MV_XSMS002", cSaida)
	PUTMV("MV_XSMS003", nTimer)
	PUTMV("MV_XSMS004", lConfere)
	PUTMV("MV_XSMS005", nTamNota)
	PUTMV("MV_XSMS006", cProc)
	PUTMV("MV_XSMS007", lBtParam)

	cEntrada := IIf(SubStr(AllTrim(cEntrada), Len(AllTrim(cEntrada)), 1) == "\", PadR(cEntrada, 200), PadR(AllTrim(cEntrada) + "\", 200))
	cSaida   := IIf(SubStr(AllTrim(cSaida), Len(AllTrim(cSaida)), 1) == "\", PadR(cSaida, 200), PadR(AllTrim(cSaida) + "\", 200))
	cProc    := IIf(SubStr(AllTrim(cProc), Len(AllTrim(cProc)), 1) == "\", PadR(cProc, 200), PadR(AllTrim(cProc) + "\", 200))

Return(.T.)

////////////////////////////
Static Function VALIDADIR( cPath, lDrive, lMSg )

Local aDir
Local lRet		:= .T.

Default lDrive 	:= .F.
Default lMSg 	:= .T.

If Empty(cPath)
	Return lRet
EndIf

lDrive := If(lDrive == Nil, .T., lDrive)

cPath := Alltrim(cPath)
If Subst(cPath,2,2) <> ":" .AND. lDrive
	MsgInfo("Unidade de drive não especificada")
	lRet:=.F.
Else
	cPath := If(Right(cPath,1) == "", Left(cPath,Len(cPath)-1), cPath)
	aDir  := Directory(cPath,"D")
	If Len(aDir) = 0 .and. !ExistDir(cPath)
		If lMSg
			If MsgYesNo("Diretorio - "+cPath+" - não encontrado, deseja cria-lo" )
				If MakeDir(cPath) <> 0
					Help(" ",1,"NOMAKEDIR")
					lRet := .F.
				EndIf
			EndIf
		Else
			If MakeDir(cPath) <> 0
				Help(" ",1,"NOMAKEDIR")
				lRet := .F.
			EndIf
		EndIF
	EndIf
EndIf

Return(lRet)

////////////////////////////
Static Function CargaXML()

Local cStrXmlAux
Local cStrXml := ""
Local nX1	:= 0
Local aRetXml
Local nTotXml
Local nXmlImp := 0
Local cCargo
Local aAux
Local aArquiv := {}
Local aArqAux
Local cTxtCan
Local aTxtCan 

Local _cDlocal	:= 'C:\LogImpXML'
Local aDirL		:= Directory(_cDlocal,"D")
Private cResult

///Variáveis de preenchimento da tabela _cTab1 com informações do XML
Private cNumNF    := ""
Private cEmitCod  := ""
Private cEmitLoj  := ""
Private cTpNFe    := ""
Private cNatFin   := ""
Private cEstado   := ""
Private cConPgto  := ""
Private _cHistor  := space(tamSX3("E2_HIST")[1])
Private cCtaCont  := ""
Private cCusto    := ""	
Private cEvtoDoc  := ""
Private cEvtoSer  := ""
Private cEvtoCNPJ := ""
Private cEvtoTp   := ""
Private lCanSit   := "1"
Private cCgcEmit  := ""
Private cCgcDest  := ""
Private oXml
Private cXml	:= "" 
Private cTpFrete := ""

IF Len(aDirL) = 0
	Makedir("C:\LogImpXML")   // cria a pasta na Estação se não existir
ENDIF

cResult	:= FCreate("C:\LogImpXML\Log_"+DTOS(DATE())+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+"_Emp"+cEmpAnt+"_Fil"+cFilAnt+".csv") // cria o arquivo de trabalho

// Exclui os registros de erros de XML
dbSelectArea(_cTab4)
(_cTab4)->(dbGoTop())

While !(_cTab4)->(Eof())
	RecLock(_cTab4, .F.)
	dbDelete()
	(_cTab4)->( MSUnlock() )
	(_cTab4)->(DBSkip())
Enddo

aArquiv := Directory(AllTrim(cEntrada) + "*.XML")
aArqAux := Directory(AllTrim(cEntrada) + "*.TXT")

For nX1 := 1 To Len(aArqAux)
	AAdd(aArquiv, aArqAux[nX1])
Next nX1

FWrite(cResult,"Início da importação do XML   "+DTOS(DATE())+"   "+TIME()+" "+Chr(13) + Chr(10)) // Primeira Linha

ProcRegua((nTotXml := Len(aArquiv)))
For nX1 := 1 to nTotXml

	lVldErro   := .F.
	lVldErCNPJ := .F.
	cError     := ""
	cWarning   := ""

	IncProc("Lendo XML " + cValToChar(nX1) + " de " + cValToChar(nTotXml) + "...")

	If Upper(Substr(aArquiv[nX1, 1], RAt(".", aArquiv[nX1, 1]) + 1)) == "XML"

		If ValType(oXml) == "O"
			FreeObj(oXml)
		EndIf
        
		FWrite(cResult,aArquiv[nX1, 1]+";"+Chr(13) + Chr(10)) // Grava o nome do arquivo q está sendo importado

		oXml := Nil
		_cArq := Lower(cEntrada + aArquiv[nX1,1])
		nHandle := 	FOpen(_cArq)
		cXml := ""
		cStrXml := ""
		cStrXmlAux := ""
		
		If nHandle > 0
			nTamanho := Fseek(nHandle,0,FS_END)
			FSeek(nHandle,0,FS_SET)
			FRead(nHandle,@cXml,nTamanho)
			FClose(nHandle)
		Else
		   	cAviso := "Falha ao tentar obter acesso ao arquivo " + _cArq
		   	Aviso("IMPORTADOR XML",cAviso,{"OK"},3)
		EndIf
		
		oXml := XmlParser(cXml, "_", @cError, @cWarning )   
		cStrXml := cStrXmlAux := cXml
		
		If Empty(oXml)

			If At("<?xml", cStrXmlAux) > 0

				cStrXmlAux := SubStr(cStrXmlAux, At("<?xml", cStrXmlAux))
				cStrXmlAux := SubStr(cStrXmlAux, 1, At("?>", cStrXmlAux) + 1)

				If At("encoding", cStrXmlAux) > 0

					If At("utf-8", Lower(cStrXmlAux)) > 0
						cStrXml := StrTran(cStrXml, cStrXmlAux, StrTran(Lower(cStrXmlAux), "utf-8", "ISO-8859-1"))
					ElseIf At("iso-8859-1", Lower(cStrXmlAux)) > 0
						cStrXml := StrTran(cStrXml, cStrXmlAux, StrTran(Lower(cStrXmlAux), "iso-8859-1", "UTF-8"))
					EndIf
				Else
					cStrXml := SubStr(cStrXml, cStrXmlAux, Stuff(cStrXmlAux, RAt("?>", cStrXmlAux), 0, 'encoding="ISO-8859-1"'))
				EndIf
			Else
				cStrXml := '<?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF + cStrXml
			EndIf

			oXml       := Nil
			cStrXmlAux := Nil
			DelClassIntf()
			oXml       := XmlParser(cStrXml, "_", @cError, @cWarning)
		
		EndIf

		Begin Sequence

			If !Empty(oXml)

				///////////////////Validações
				If Type("oXml:_nfeProc") == "O" // Nota Fiscal

					ValidaNFe(aArquiv[nX1, 1])

				ElseIf Type("oXml:_cteProc") == "O" //Conhecimento de Transporte

					ValidaCTe(aArquiv[nX1, 1])

				ElseIf Type("oXml:_procEventoNFe") == "O"

					If Type("oXml:_procEventoNFe:_evento:_envEvento:_evento") == "O"
						oXml := oXml:_procEventoNFe:_evento:_envEvento:_evento
					ElseIf Type("oXml:_procEventoNFe:_evento") == "O"
						oXml := oXml:_procEventoNFe:_evento
					EndIf
                             
					If Type("oXml:_infEvento") == "O"
						If oXml:_infEvento:_tpEvento:Text == "110111" //Cancelamento
	
							ValidaCan(aArquiv[nX1, 1])
	
						EndIf
					Endif

				EndIf

				/////////////////////////////////Fim Validações
				If lVldErro .Or. lVldErCNPJ

					If !lVldErCNPJ
						lVlErrMsg := .T.
					EndIf

					Break

				EndIf

				aRetXml := TransXml(aArquiv[nX1,1])
				If aRetXml[1]
					nXmlImp++
					If Type("oXml:_nfeProc") == "O" // Nota Fiscal de Entrada

						RecLock(_cTab1, .T.)
						(_cTab1)->&(_cCmp1+"_FILIAL") := xFilial("SF1")
						(_cTab1)->&(_cCmp1+"_SEQIMP") := GetSXENUM(_cTab1, _cCmp1+"_SEQIMP")
						(_cTab1)->&(_cCmp1+"_ARQUIV") := aArquiv[nX1,1]
						(_cTab1)->&(_cCmp1+"_DOC")    := cNumNF
						(_cTab1)->&(_cCmp1+"_SERIE")  := oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text
						(_cTab1)->&(_cCmp1+"_CGCEMI") := cCGCEmit
						(_cTab1)->&(_cCmp1+"_CGCDES") := cCGCDest
                        if Valtype(XmlChildEx(oXml:_NfeProc:_Nfe:_InfNfe:_Ide,"_DHEMI")) == "O"
							(_cTab1)->&(_cCmp1+"_DTEMIS") := CToD(Substr(oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_dhEmi:Text,9,2) + "/" + Substr(oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_dhEmi:Text,6,2) + "/" + Substr(oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_dhEmi:Text,1,4))
                        else
							(_cTab1)->&(_cCmp1+"_DTEMIS") := CToD(Substr(oXml:_nfeProc:_NFe:_infNFe:_ide:_dEmi:Text,9,2) + "/" + Substr(oXml:_nfeProc:_NFe:_infNFe:_ide:_dEmi:Text,6,2) + "/" + Substr(oXml:_nfeProc:_NFe:_infNFe:_ide:_dEmi:Text,1,4))
                        endif
						(_cTab1)->&(_cCmp1+"_NATOP")  := oXml:_nfeProc:_NFe:_infNFe:_ide:_natOp:Text
						(_cTab1)->&(_cCmp1+"_TOTVAL") := Round(Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vNF:Text), nDecTot)
						(_cTab1)->&(_cCmp1+"_TOTITE") := Round(Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vProd:Text), nDecTot)
						(_cTab1)->&(_cCmp1+"_TOTIPI") := Round(Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vIPI:Text), nDecTot)
						(_cTab1)->&(_cCmp1+"_TOTICM") := Round(Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vICMS:Text), nDecTot)
						(_cTab1)->&(_cCmp1+"_CODEMI") := cEmitCod
						(_cTab1)->&(_cCmp1+"_LOJEMI") := cEmitLoj
						(_cTab1)->&(_cCmp1+"_EST")    := cEstado
						(_cTab1)->&(_cCmp1+"_NATFIN") := cNatFin
						(_cTab1)->&(_cCmp1+"_CONDPG") := cConPgto
						(_cTab1)->&(_cCmp1+"_TIPOEN") := cTpNFe
						(_cTab1)->&(_cCmp1+"_XML")    := cStrXml
						(_cTab1)->&(_cCmp1+"_SIT")    := "1"
						(_cTab1)->&(_cCmp1+"_TIPO")   := "1"
						(_cTab1)->&(_cCmp1+"_CHAVE")  := Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44)
						(_cTab1)->&(_cCmp1+"_DTCRIA") := DDataBase
						(_cTab1)->&(_cCmp1+"_HRCRIA") := Time()
						(_cTab1)->&(_cCmp1+"_USUCRI") := cUserName

						//Valida se tem a tag MODFRETE
						If Type("oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete") == 'O' //oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete:Text
							
							If oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete:Text == '0'
								cTpFrete := "C"
							ElseIf oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete:Text == '1'
								cTpFrete := "F"
							ElseIf oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete:Text == '2'
								cTpFrete := "T"
							ElseIf oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete:Text == '3'
								cTpFrete := "R"
							ElseIf oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete:Text == '4'
								cTpFrete := "D"
							ElseIf oXml:_nfeProc:_NFe:_infNFe:_transp:_modfrete:Text == '9'
								cTpFrete := "S"
							Else
								cTpFrete :=""
							Endif 
							(_cTab1)->&(_cCmp1+"_TPFRETE") := cTpFrete
							
						Endif 					
						 
						(_cTab1)->( MSUnlock() )
						ConfirmSX8()
					ElseIf Type("oXml:_infEvento") == "O"
						If oXml:_infEvento:_tpEvento:TEXT == "110110" //Carta de Correção

							RecLock(_cTab1, .T.)
							(_cTab1)->&(_cCmp1+"_FILIAL") := xFilial("ZY0")
							(_cTab1)->&(_cCmp1+"_SEQIMP") := GetSXENUM(_cTab1, _cCmp1+"_SEQIMP")
							(_cTab1)->&(_cCmp1+"_ARQUIV") := aArquiv[nX1,1]
							(_cTab1)->&(_cCmp1+"_DSEVEN") := AllTrim(oXml:_infEvento:_detEvento:_descEvento:Text)
							(_cTab1)->&(_cCmp1+"_CCECOR") := AllTrim(oXml:_infEvento:_detEvento:_xCorrecao:Text)
							(_cTab1)->&(_cCmp1+"_DTEMIS") := SToD(StrTran(Substr(oXml:_infEvento:_dhEvento:Text,1,10), "-", ""))
							(_cTab1)->&(_cCmp1+"_XML")    := cStrXml
							(_cTab1)->&(_cCmp1+"_SIT")    := "1"
							(_cTab1)->&(_cCmp1+"_TIPO")   := "3"
							(_cTab1)->&(_cCmp1+"_CHAVE")  := oXml:_infEvento:_chNFe:Text
							(_cTab1)->&(_cCmp1+"_TPCAN")  := cEvtoTp
							(_cTab1)->&(_cCmp1+"_DTCRIA") := dDataBase
							(_cTab1)->&(_cCmp1+"_HRCRIA") := Time()
							(_cTab1)->&(_cCmp1+"_USUCRI") := cUserName
							(_cTab1)->( MSUnlock() )
							ConfirmSX8()

						ElseIf oXml:_infEvento:_tpEvento:TEXT == "110111" //Cancelamento

							RecLock(_cTab1, .T.)
							(_cTab1)->&(_cCmp1+"_FILIAL") := xFilial("SF1")
							(_cTab1)->&(_cCmp1+"_SEQIMP") := GetSXENUM(_cTab1, _cCmp1+"_SEQIMP")
							(_cTab1)->&(_cCmp1+"_ARQUIV") := aArquiv[nX1,1]
							(_cTab1)->&(_cCmp1+"_DOC")    := cEvtoDoc
							(_cTab1)->&(_cCmp1+"_SERIE")  := cEvtoSer
							(_cTab1)->&(_cCmp1+"_CGCEMI") := cEvtoCNPJ
							(_cTab1)->&(_cCmp1+"_CODEMI") := cEmitCod
							(_cTab1)->&(_cCmp1+"_LOJEMI") := cEmitLoj
							(_cTab1)->&(_cCmp1+"_DTEMIS") := SToD(StrTran(Substr(oXml:_infEvento:_dhEvento:Text,1,10), "-", ""))
							(_cTab1)->&(_cCmp1+"_XML")    := cStrXml
							(_cTab1)->&(_cCmp1+"_SIT")    := lCanSit
							(_cTab1)->&(_cCmp1+"_TIPO")   := "5"
							(_cTab1)->&(_cCmp1+"_CHAVE")  := oXml:_infEvento:_chNFe:Text
							(_cTab1)->&(_cCmp1+"_TPCAN")  := cEvtoTp
							(_cTab1)->&(_cCmp1+"_DTCRIA") := dDataBase
							(_cTab1)->&(_cCmp1+"_HRCRIA") := Time()
							(_cTab1)->&(_cCmp1+"_USUCRI") := cUserName
							(_cTab1)->( MSUnlock() )
							ConfirmSX8()
						EndIf
					EndIf
				Else
					lVlErrMsg := .T.
					AddErroXml(aArquiv[nX1, 1], "***Não foi possível mover o arquivo, XML não será importado e o arquivo continuará no diretório de origem. Identificação do erro: " + cValToChar(FError()), 1)
				EndIf
			Else
				lVlErrMsg := .T.
				AddErroXml(aArquiv[nX1, 1], "***Erro ao ler o XML do arquivo, ele não será importado e continuará no diretório de origem.")
			EndIf
		End Sequence
	Else
		FWrite(cResult,aArquiv[nX1, 1]+";"+Chr(13) + Chr(10)) // Grava o nome do arquivo q está sendo importado
		Begin Sequence
			cTxtCan := MemoRead(Lower(cEntrada + aArquiv[nX1,1]))
			aTxtCan := StrTokArr(AllTrim(cTxtCan), ";")

			If Lower(SubStr(aArquiv[nX1,1], 1, 4)) == "canc"
				ValidaCan(cValToChar(nX1), aTxtCan[4])
			EndIf

			If lVldErro
				lVlErrMsg := .T.
				Break
			EndIf

			aRetXml := TransXml(aArquiv[nX1,1])
			If aRetXml[1]

				If Lower(SubStr(aArquiv[nX1,1], 1, 4)) == "canc"

					//Cancelamento TXT
					RecLock(_cTab1, .T.)
					(_cTab1)->&(_cCmp1+"_FILIAL") := xFilial("SF1")
					(_cTab1)->&(_cCmp1+"_SEQIMP") := GetSXENUM(_cTab1, _cCmp1+"_SEQIMP")
					(_cTab1)->&(_cCmp1+"_ARQUIV") := aArquiv[nX1,1]
					(_cTab1)->&(_cCmp1+"_DOC")    := cEvtoDoc
					(_cTab1)->&(_cCmp1+"_SERIE")  := cEvtoSer
					(_cTab1)->&(_cCmp1+"_CGCEMI") := cEvtoCNPJ
					(_cTab1)->&(_cCmp1+"_CODEMI") := cEmitCod
					(_cTab1)->&(_cCmp1+"_LOJEMI") := cEmitLoj
					//(_cTab1)->&(_cCmp1+"_DTEMIS") := SToD(StrTran(Substr(oXml:_infEvento:_dhEvento:Text,1,10), "-", ""))
					(_cTab1)->&(_cCmp1+"_XML")    := cXml
					(_cTab1)->&(_cCmp1+"_SIT")    := lCanSit
					(_cTab1)->&(_cCmp1+"_TIPO")   := "5"
					(_cTab1)->&(_cCmp1+"_CHAVE")  := aTxtCan[4]
					(_cTab1)->&(_cCmp1+"_TPCAN")  := cEvtoTp
					(_cTab1)->&(_cCmp1+"_DTCRIA") := dDataBase
					(_cTab1)->&(_cCmp1+"_HRCRIA") := Time()
					(_cTab1)->&(_cCmp1+"_USUCRI") := cUserName
					(_cTab1)->( MSUnlock() )
					ConfirmSX8()

				EndIf

			Else
				lVlErrMsg := .T.
				AddErroXml(aArquiv[nX1, 1], "***Não foi possível mover o arquivo, XML não será importado e o arquivo continuará no diretório de origem. Identificação do erro: " + cValToChar(FError()), 1)
			EndIf

		End Sequence

	EndIf

	oXml       := Nil
	cXml       := Nil
	cStrXml    := Nil
	cStrXmlAux := Nil
	DelClassIntf()

Next nX1

FWrite(cResult,"Fim da importação do XML   "+DTOS(DATE())+"   "+TIME()+";"+Chr(13) + Chr(10))   
FClose(cResult)

oXml       := Nil
oXml       := Nil
cXml       := Nil
cStrXml    := Nil
cStrXmlAux := Nil

DelClassIntf()
Sleep(100)

IF GETNEWPAR("MV_IMPMAIL", .F.) 
	U_RemXML() // Remove os XMLs rejeitados
ENDIF	

Return(.T.)

///////////////////////////////////////////

Static Function ValidaNFe(cArquivo)

Local aAreaSZW := (_cTab1)->( GetArea() )
Local _cTipoNF := "N"
Local oError := ErrorBlock({|e| AddErroXml(cArquivo, "Erro ao ler arquivo XML (ValidaNFe) - " + e:Description) }) 

	Begin Sequence
	
	If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_emit, "_CNPJ")) <> "U"
		cCGCEmit := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:Text)
	Else
		cCGCEmit := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_emit:_CPF:Text)
	EndIf

	If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_dest, "_CNPJ")) <> "U"
		cCGCDest := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:Text)
	Else
		cCGCDest := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_dest:_CPF:Text)
	EndIf

	//Identificar que é uma nota de Devolução
	If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_ide, "_FINNFE")) <> "U"
		If AllTrim(oXml:_nfeProc:_NFe:_infNFe:_ide:_finNFe:Text) == '4'
			_cTipoNF := 'D'
		Endif 
	Endif 





		If cCGCDest != SM0->M0_CGC

			//---------------------------------------
			// Caso o xml de outra filial possa aparece com erro no monitor usar o código abaixo
			//AddErroXml(cArquivo, "CNPJ do destinatário do documento não confere com a Filial corrente do sistema." + CRLF + ;
			//				 "CNPJ arquivo XML: " + Transform(cCGCDest, "@R 99.999.999/9999-99") + CRLF + ;
			// 				 "CNPJ Empresa/Filial: " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))
			//----------------------------------------

			// Caso não deva aparecer para o usuário nem no monitor de xml's usar o código abaixo
			//----------------------------------------

			RecLock(cAliFil, .T.)
			(cAliFil)->ARQ := PadR(Lower(cArquivo), 140)
			(cAliFil)->( MsUnlock() )
            
			FWrite(cResult,cArquivo+"; CNPJ do destinatário não confere com a Filial corrente do sistema ; Emitente: "+cCGCEmit+"; Destinatário: "+cCGCDest+"; NFe;"+Chr(13) + Chr(10)) // Grava o nome do arquivo q está sendo importado

			lVldErCNPJ := .T.
			Break

		EndIf
		
		//Determina que é uma Devolução
		//<finNFe>4</finNFe>
		If _cTipoNF <> 'D'

			dbSelectArea("SA2")
			SA2->( dbSetOrder(3) )
			If U_SMS01CGC(cCGCEmit)//SA2->( dbSeek(xFilial("SA2") + cCGCEmit) )

				cEmitCod := SA2->A2_COD	
				cEmitLoj := SA2->A2_LOJA
				cNatFin  := SA2->A2_NATUREZ
				cEstado  := SA2->A2_EST
				cConPgto := SA2->A2_COND
				cTpNFe   := "F"
			Endif
		
		Else

			dbSelectArea("SA1")
			SA1->( dbSetOrder(3) )
			If SA1->( dbSeek(xFilial("SA1") + cCGCEmit) )

				cEmitCod := SA1->A1_COD
				cEmitLoj := SA1->A1_LOJA
				cNatFin  := SA1->A1_NATUREZ
				cEstado  := SA1->A1_EST
				cConPgto := SA1->A1_COND
				cTpNFe   := "C"
			Else
				AddErroXml(cArquivo, "- Emissor de CNPJ " + cCGCEmit + " informado no XML não cadastrado no sistema.")
			EndIf
		EndIf

		cNumNF := Right(IIf(Len(oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text) >= nTamNota, oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, PadL(oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, nTamNota, "0")), nTamCmpNF)

		dbSelectArea("SF1")

		SF1->( dbSetOrder(1) )
		If SF1->( dbSeek(xFilial("SF1") + cNumNF + PadR(oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text, nTamCmpSer) + cEmitCod + cEmitLoj) )
			AddErroXml(cArquivo, "- Já existe Nota Fiscal no sistema com a chave de número: " + AllTrim(cNumNF) + " e série: " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text) + " para o fornecedor: " + AllTrim(cEmitCod) + "/" + cEmitLoj + ".")
		EndIf

// valido se o arquivo foi lido alguma vez
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		If (_cTab1)->( dbSeek(Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44)) )
			AddErroXml(cArquivo, "- Já existe Nota Fiscal no sistema com a chave " + Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44) + " e situação: " + AllTrim(CBoxInfo(_cCmp1+"_SIT", (_cTab1)->&(_cCmp1+"_SIT"), 2)) + ".")
		EndIf

	End Sequence
	RestArea(aAreaSZW)
	ErrorBlock(oError)
Return

///////////////////////////////////////////

Static Function ValidaCTe(cArquivo)
Local aErros := {}
Local cErros := ""
Local _lRet	:= .F.
local aRet	:= {}
Local nI

	aRet := U_ImpXML_Cte(cArquivo, .T., aErros, oXml:_cteProc:_CTe)
	If ValType(XmlChildEx(oXml:_cteProc:_CTe:_InfCte:_emit, "_CNPJ")) <> "U"
		cCGCEmit := AllTrim(oXml:_cteProc:_CTe:_InfCte:_emit:_CNPJ:Text)
	Else
		cCGCEmit := AllTrim(oXml:_cteProc:_CTe:_InfCte:_emit:_CPF:Text)
	EndIf

	If ValType(XmlChildEx(oXml:_cteProc:_CTe:_InfCte:_dest, "_CNPJ")) <> "U"
		cCGCDest := AllTrim(oXml:_cteProc:_CTe:_InfCte:_dest:_CNPJ:Text)
	Else
		cCGCDest := AllTrim(oXml:_cteProc:_CTe:_InfCte:_dest:_CPF:Text)
	EndIf

	If !aRet[1]

		For nI := 1 To Len(aErros)
			cErros += "-" + aErros[nI][2] + CRLF    
		Next nI
		AddErroXml(cArquivo, cErros)
		FWrite(cResult,cArquivo+";"+SUBSTR(ALLTRIM(cErros),2, (LEN(SUBSTR(ALLTRIM(cErros),2))-3))+"; Emitente: "+cCGCEmit+"; Destinatário: "+cCGCDest+"; CTe;"+Chr(13) + Chr(10)) // Grava o nome do arquivo q está sendo importado
	EndIf

Return


///////////////////////////////////////////
Static Function ValidaCan(cArquivo, cChaveTxt)
Local aAreaSZW := (_cTab1)->( GetArea() )
Local aAreaSF1 := SF1->( GetArea() )
Local cChaveE
Default cChaveTxt := ""

	If !Empty(cChaveTxt)
		cChaveE := cChaveTxt
	Else
		cChaveE := oXml:_infEvento:_chNFe:Text
	EndIf

	lCanSit := "1"
	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )
	If (_cTab1)->( dbSeek(cChaveE + "5") ) .And. (_cTab1)->&(_cCmp1+"_SIT") # "2"
		AddErroXml(cArquivo, "- Já existe um Xml de cancelamento para o Documento de Entrada de número: " + AllTrim(SF1->F1_DOC) + " e série: " + AllTrim(SF1->F1_SERIE) + ".")
	ElseIf (_cTab1)->( dbSeek(cChaveE + "1") ) .Or. (_cTab1)->( dbSeek(cChaveE + "2") )

		cEvtoDoc  := (_cTab1)->&(_cCmp1+"_DOC")
		cEvtoSer  := (_cTab1)->&(_cCmp1+"_SERIE")
		cEvtoCNPJ := (_cTab1)->&(_cCmp1+"_CGCEMI")
		cEmitCod  := (_cTab1)->&(_cCmp1+"_CODEMI")
		cEmitLoj  := (_cTab1)->&(_cCmp1+"_LOJEMI")
		cEvtoTp   := IIf((_cTab1)->&(_cCmp1+"_TIPO") == "1", "N", "C")

		If (_cTab1)->&(_cCmp1+"_SIT") $ "1;3"

			SetStatusXML(IIf((_cTab1)->&(_cCmp1+"_TIPO") == "1", "NFE", "CTE"), "5")
			Aviso("Aviso de cancelamento", "O Xml chave "+cChaveE+" ainda foi não importado e foi encontrado um correspondente de cancelamento."+chr(13)+chr(10)+;
					"Cancelamento será efetuado automaticamente.", {"Ok"}, 2)
			lCanSit := "2"

		ElseIf (_cTab1)->&(_cCmp1+"_SIT") == "2"

			dbSelectArea("SF1")
			SF1->( dbSetOrder(1) )
			If !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )
				AddErroXml(cArquivo, "- Não foi encontrado Documento de Entrada de número: " + AllTrim(SF1->F1_DOC) + " e série: " + AllTrim(SF1->F1_SERIE) + ", e Xml do Documento de Entrada já foi processado.")
			EndIf

		EndIf
	Else
		AddErroXml(cArquivo, "- Não foi encontrado Documento de Entrada com a chave eletrônica " + cChaveE + " informada no Xml. Documento de Entrada pode ainda não ter sido atualizado.")
	EndIf

	RestArea(aAreaSZW)
	RestArea(aAreaSF1)
Return



///////////////////////////////////////////
Static Function GetXmlIcms(oXml)
Local nIcms := 0
Local aIcms := {{"1", {"_ICMS00", "_ICMS20", "_CST00", "_CST20"}},;
				{"2", {"_ICMS45", "_CST45"}},;
				{"3", {"_ICMS60", "_CST60"}},;
				{"4", {"_ICMS80", "_ICMS90", "_CST80", "_CST90"}};
			   }
Local nX
Local nY
Local oXmlAux
Local oXmlIcms := XmlChildEx(oXml:_cteProc:_CTe:_infCte:_imp, "_ICMS")
Local aRet     := {"2" /*Tributação*/, 0/*Base*/, 0/*Alíquota*/, 0/*Valor*/}

	If ValType(oXmlIcms) # "O"
		oXmlIcms := oXml
	EndIf


	Begin Sequence

		If ValType(oXmlIcms) # "O"
			Break
		EndIf

		For nX := 1 To Len(aIcms)
			For nY := 1 To Len(aIcms[nX][2])
				If ValType(oXmlAux := XmlChildEx(oXmlIcms, aIcms[nX][2][nY])) == "O"
					If aIcms[nX][1] != "2"
						aRet := {aIcms[nX][1], Val(oXmlAux:_vBC:Text), Val(oXmlAux:_pICMS:Text), Val(oXmlAux:_vICMS:Text)}
					EndIf
					Break
				EndIf
			Next nY
		Next nX
	End Sequence

Return aRet



///////////////////////////////////////////

Static Function ImportNFeC()

Local _aCampoSX3 := {}
Local _cCampoSX3 := ""
Local _nX        := 0

Local cError   := ""
Local cWarning := ""
Local cDesComp := IIf(cCombo1=="I", "ICMS", IIf(cCombo1=="P", "IPI", "Preço/Frete"))
Local aItens   := {}
Local nI, nX
Local cAlias   := GetNextAlias()
Local cQuery   := ""
Local aFields  := {_cCmp1+"_FILIAL", _cCmp1+"_DOC", _cCmp1+"_SERIE", _cCmp1+"_DTEMIS", _cCmp1+"_CODEMI",;
				   _cCmp1+"_LOJEMI", _cCmp1+"_EMIT", _cCmp1+"_EST", "NOUSER"}
Local aUpdFlds := {}
Local aCabec
Local aItens   := {}
Local cProduto := Space(TamSX3("D1_COD")[1])
Local cStrXml  := ""
Local cClasFis := ""
Local aAltItem := {_cCmp2+"_COD", _cCmp2+"_TES",_cCmp2+"_PICM", _cCmp2+"_CF", _cCmp2+"_TOTAL", _cCmp2+"_CLASFI", _cCmp2+"_CC", _cCmp2+"_CONTA",_cCmp2+"_PEDIDO",_cCmp2+"_ITEMPC"}
Local aAltNFs  := {}
Local aNFsIni  := {"D2_OK", "D1_DOC", "D1_SERIE"}
Local lConfirm := .F.
Local cEnchOld := GetMv("MV_ENCHOLD")

//Totais
Private nValFrete
Private nValSeguro
Private nValDesp
Private nValDesc
Private nValMerc
////////

Private oXml
Private oLayerNFeC
Private oGetDItem, oGetDNFs
Private cDescDev := "Complemento de " + IIf(cCombo1 == "I", "ICMS", IIf(cCombo1 == "P", "IPI", "Preço/Frete"))

Private aHeadItem := {}
Private aColsItem
Private aHeadNFs  := {}
Private aColsNFs
Private oBrwNFsIt
Private aMarcNFs  := {}
Private oFootAtu
Private oFootDes
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.

	If Empty(cEspNFe)
		MsgStop("Espécie do Documento deve ser informada!", "Aviso")
		Return .F.
	EndIf

	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	If !SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )
		MsgStop("Fornecedor não encontrado com o código/loja: " + AllTrim((_cTab1)->&(_cCmp1+"_CODEMI")) + "/" + AllTrim((_cTab1)->&(_cCmp1+"_LOJEMI")) + ".", "Nota Fiscal de Complemento de " + cDesComp)
		Return .F.
	EndIf


	Begin Sequence

		oXml := NIL
		oXml := XmlParser((_cTab1)->&(_cCmp1+"_XML"), "_", @cError, @cWarning)
		If Empty(oXml)
			MsgStop("Falha ao gerar o Objeto XML:" + cError, "Erro")
			Break
		Else

			nValFrete  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vFrete:Text), nDecTot)
			nValSeguro := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vSeg:Text  ), nDecTot)
			nValDesp   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vOutro:Text), nDecTot)
			nValDesc   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vDesc:Text ), nDecTot)
			nValMerc   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vProd:Text ), nDecTot)

			If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
	        	XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
			EndIf

			DEFINE MSDIALOG oDlgNFeC FROM aSize[7],0 TO aSize[6],aSize[5] TITLE 'Importador - Nota Fiscal de Complemento de ' + cDesComp STYLE DS_MODALFRAME PIXEL
				oDlgNFeC:lEscClose := .F.

				oLayerNFeC := FWLayer():New()
				oLayerNFeC:Init(oDlgNFeC, .F.)
				oLayerNFeC:AddLine('TOP', 29, .F.)
				oLayerNFeC:AddCollumn('NFEC_INFO', 100, .T., 'TOP')
				oLayerNFeC:AddWindow('NFEC_INFO', 'WIN_NFEC_INFO', "Informações da Nota Fiscal de Complemento de " + cDesComp + " a ser importada", 100, .F., .T.,, 'TOP',)

					RegToMemory(_cTab1)
					PutMv("MV_ENCHOLD", "2")
					oGetCab := MsMGet():New(_cTab1,, MODEL_OPERATION_UPDATE,,,, aFields, {0,0,0,0}, aUpdFlds,;
							   ,,,, oLayerNFeC:GetWinPanel('NFEC_INFO', 'WIN_NFEC_INFO', 'TOP'),,.T.,,,.T.,,,,,,,.T.)

					PutMv("MV_ENCHOLD", cEnchOld)
					oGetCab:oBox:Align := CONTROL_ALIGN_ALLCLIENT

				oLayerNFeC:AddLine('CENTER', 33, .F.)
				oLayerNFeC:AddCollumn('NFEC_ITEM', 100, .T., 'CENTER')
				oLayerNFeC:AddWindow('NFEC_ITEM', 'WIN_NFEC_ITEM', "Itens da Nota Fiscal de Complemento de " + cDesComp + " a ser importada", 100, .F., .T.,, 'CENTER',)

					If SF2->(FieldPos("D2_OK")) > 0
						AADD(aHeadItem, {"Vinculada?", _cCmp2+"_OK", "@BMP", 9,;
										GetSX3Cache("D2_OK", "X3_DECIMAL"),;
										GetSX3Cache("D2_OK", "X3_VALID"),;
										GetSX3Cache("D2_OK", "X3_USADO"),;
										GetSX3Cache("D2_OK", "X3_TIPO"),;
										GetSX3Cache("D2_OK", "X3_F3"),;
										GetSX3Cache("D2_OK", "X3_CONTEXT") })
					EndIf

					_aCampoSX3 := U_XAGSX3(_cTab2)

					For _nX := 1 To Len(_aCampoSX3)
						_cCampoSX3 := _aCampoSX3[_nX]

						AADD(aHeadItem, {Trim(GetSX3Cache(_cCampoSX3, "X3_TITULO")),;
					            _cCampoSX3,;
								 GetSX3Cache(_cCampoSX3, "X3_PICTURE"),;
								 GetSX3Cache(_cCampoSX3, "X3_TAMANHO"),;
								 GetSX3Cache(_cCampoSX3, "X3_DECIMAL"),;
								 GetSX3Cache(_cCampoSX3, "X3_VALID"),;
								 GetSX3Cache(_cCampoSX3, "X3_USADO"),;
								 GetSX3Cache(_cCampoSX3, "X3_TIPO"),;
								 GetSX3Cache(_cCampoSX3, "X3_F3"),;
								 GetSX3Cache(_cCampoSX3, "X3_CONTEXT") })
					
					Next _nx

					aColsItem := {}
					aMarcNFs  := Array(Len(oXml:_NfeProc:_Nfe:_InfNfe:_det))
					aFill(aMarcNFs, {"", "", "", "", "", ""})

					//-------------------- Carregar Itens do Xml no array
					For nI := 1 To Len(oXml:_NfeProc:_Nfe:_InfNfe:_det)

						cProduto := Space(TamSX3("B1_COD")[1])
						AAdd(aColsItem, Array(Len(aHeadItem) + 1))

						For nX := 1 To Len(aHeadItem)
							If !(aHeadItem[nX, 2] $ _cCmp2+"_OK")
								aColsItem[nI, nX] := CriaVar(aHeadItem[nX, 2])
							EndIf
						Next nX

						aColsItem[nI, Len(aHeadItem) + 1] := .F.

						cQuery := "SELECT SA5.A5_PRODUTO FROM " + RetSqlName("SA5") + " SA5"
						cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
						cQuery += " SA5.A5_FILIAL  = '" + xFilial("SA5") + "' AND "
						cQuery += " SA5.A5_FORNECE = '" + M->&(_cCmp1+"_CODEMI") + "' AND "
						cQuery += " SA5.A5_LOJA    = '" + M->&(_cCmp1+"_LOJEMI") + "' AND "
						cQuery += " SA5.A5_CODPRF  = '" + AllTrim(Upper(StrTran(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text,"'"))) + "' AND "
						cQuery += " SA5.A5_PRODUTO <> ' '"

						If Select(cAlias) > 0
							(cAlias)->( dbCloseArea() )
						EndIf

						dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
						If !(cAlias)->( Eof() )
							cProduto := (cAlias)->A5_PRODUTO
						EndIf


						If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nI) + "]:_imposto:_ICMS") == "O"

							SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_imposto:_ICMS XMLSTRING cStrXml
							If At("<ICMS00>", cStrXml) > 0
								cClasFis := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
							EndIf

						EndIf

						aColsItem[nI][1]  := "CANCEL_15" // Vinculada?
						aColsItem[nI][2]  := SubStr(AllTrim(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text) + " - " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_xProd:Text), 1, 40) // Desrição do Item (vindo do Xml no formato do Cliente)
						aColsItem[nI][3]  := cProduto // Código do Produto
						aColsItem[nI][4]  := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC"), Space(TamSX3("B1_DESC")[1])) // Descrição do Produto
						aColsItem[nI][5]  := oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_uCom:Text // Unidade de Medida
						aColsItem[nI][6]  := 0 // Quantidade da Nota de saída selecionada
						aColsItem[nI][7]  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_vUnCom:Text), 2) // Valor unitário
						aColsItem[nI][8]  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_vUnCom:Text), 2) // Valor total
						aColsItem[nI][9]  := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_TE"), Space(TamSX3("B1_TE")[1])) // Tes
						aColsItem[nI][10] := IIf(!Empty(aColsItem[nI][9]), IIf(GETMV("MV_ESTADO") == M->&(_cCmp1+"_EST"), "1", "2") + Substr(Posicione("SF4", 1, xFilial("SF4") + aColsItem[nI][9], "F4_CF"), 2, 3), "") // Código Fiscal
						aColsItem[nI][11] :=  cClasFis // Classificação Fiscal

					Next nI

					(cAlias)->( dbCloseArea() )
					If Len(aMarcNFs) == 0
						MsgStop("Não há itens vinculados a Nota Fiscal.")
						Break
					EndIf

					oGetDItem := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltItem, 0, 999, NIL, NIL, "AlwaysFalse", oLayerNFeC:GetWinPanel('NFEC_ITEM', 'WIN_NFEC_ITEM', 'CENTER'), aHeadItem, aColsItem, "")
					oGetDItem:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					oGetDItem:oBrowse:bSeekChange := {|| CargaNFs() }
				   	oGetDItem:oBrowse:bDrawSelect := {|| CargaNFs() }

				oLayerNFeC:AddLine('MIDDLE', 33, .F.)
				oLayerNFeC:AddCollumn('NFEC_NFE', 100, .T., 'MIDDLE')
				oLayerNFeC:AddWindow('NFEC_NFE', 'WIN_NFEC_NFE', "Itens das Notas Fiscais de origem (Entrada)", 100, .F., .T.,, 'MIDDLE',)

					For nI := 1 To Len(aNFsIni)
						_cCampoSX3 := aNFsIni[nI]

						If !Empty(GetSX3Cache(_cCampoSX3, "X3_CAMPO"))
							AADD(aHeadNFs, {Trim(GetSX3Cache(_cCampoSX3, "X3_TITULO")),;
							                IIf(AllTrim(aNFsIni[nI]) == "D2_OK", "D1_OK", _cCampoSX3),;
											IIf(AllTrim(aNFsIni[nI]) == "D2_OK", "@BMP", GetSX3Cache(_cCampoSX3, "X3_PICTURE")),;
											IIf(AllTrim(aNFsIni[nI]) == "D2_OK", 8, GetSX3Cache(_cCampoSX3, "X3_TAMANHO")),;
											GetSX3Cache(_cCampoSX3, "X3_DECIMAL"),;
											GetSX3Cache(_cCampoSX3, "X3_VALID"),;
											GetSX3Cache(_cCampoSX3, "X3_USADO"),;
											GetSX3Cache(_cCampoSX3, "X3_TIPO"),;
											GetSX3Cache(_cCampoSX3, "X3_F3"),;
											GetSX3Cache(_cCampoSX3, "X3_CONTEXT") })
						EndIf
					Next nI

					_aCampoSX3 := U_XAGSX3("SD1",,.T.,.F.)

					For _nX := 1 To Len(_aCampoSX3)

						_cCampoSX3 := _aCampoSX3[_nX]

						If !(AllTrim(_cCampoSX3) $ "D1_FILIAL") .And. AScan(aNFsIni, {|x| x = AllTrim(_cCampoSX3)}) == 0
							AADD(aHeadNFs, {Trim(GetSX3Cache(_cCampoSX3, "X3_TITULO")),;
											_cCampoSX3,;
											GetSX3Cache(_cCampoSX3, "X3_PICTURE"),;
											GetSX3Cache(_cCampoSX3, "X3_TAMANHO"),;
											GetSX3Cache(_cCampoSX3, "X3_DECIMAL"),;
											GetSX3Cache(_cCampoSX3, "X3_VALID"),;
											GetSX3Cache(_cCampoSX3, "X3_USADO"),;
											GetSX3Cache(_cCampoSX3, "X3_TIPO"),;
											GetSX3Cache(_cCampoSX3, "X3_F3"),;
											GetSX3Cache(_cCampoSX3, "X3_CONTEXT") })
						EndIf
					End

					aColsNFs := {}
					oGetDNFs := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltNFs, 0, 999, NIL, NIL, "AlwaysFalse", oLayerNFeC:GetWinPanel('NFEC_NFE', 'WIN_NFEC_NFE', 'MIDDLE'), aHeadNFs, aColsNFs, {|| /*bChange*/})
				   	oGetDNFs:oBrowse:blDblClick := {|x, nCol| MarcaNFs()}
					oGetDNFs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

					//----------------- Carrega NFs de Entrada
					CargaNFs(.F., aColsNFs)
					//-----------------


				oLayerNFeC:AddLine('BOTTOM', 5, .F.)
				oLayerNFeC:AddCollumn('NFEC_BAR', 100, .T., 'BOTTOM')

				oPanelBot := tPanel():New(0, 0, "", oLayerNFeC:GetColPanel('NFEC_BAR', 'BOTTOM'),,,,, RGB(239,243,247), 000, 015)
				oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT

				oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgNFeC:End()}, , ,)
				oQuit:nWidth  := 80
				oQuit:nHeight := 10
				oQuit:Align   := CONTROL_ALIGN_RIGHT
				oQuit:SetColor(RGB(002,070,112),)

				oImp := THButton():New(0, 0, "Importar Complemento de " + cDesComp, oPanelBot, {|| lConfirm := .T., IIf(InsereNFeD(@lConfirm), oDlgNFeC:End(),)},,,)
				oImp:nWidth  := 180
				oImp:nHeight := 10
				oImp:Align   := CONTROL_ALIGN_RIGHT
				oImp:SetColor(RGB(002,070,112),)

				oFootAtu := TSay():New(4, 10,{|| "  Todos os itens estão vinculados." }, oPanelBot,, TFont():New('Arial',,-12,,.F.),,,,.T., CLR_BLUE, CLR_WHITE,140,30)
				oFootAtu:Align := CONTROL_ALIGN_LEFT
				oFootAtu:Hide()

				oFootDes := TSay():New(4, 10,{|| "  Há itens ainda não vinculados." }, oPanelBot,, TFont():New('Arial',,-12,,.T.),,,,.T., CLR_RED, CLR_WHITE,140,30)
				oFootDes:Align := CONTROL_ALIGN_LEFT
				oFootDes:Show()

			ACTIVATE MSDIALOG oDlgNFeC CENTERED

		EndIf

	End Sequence
	AtuBrowse()

Return


///////////////////////////////////////////
User Function SMSTOT()

	If cCombo1 $ "I;P;C"
		GDFieldPut(_cCmp2+"_VUNIT", GDFieldGet(_cCmp2+"_TOTAL",, .T.))
	EndIf
	oGetDNfs:oBrowse:Refresh()

Return .T.

///////////////////////////////////////////

Static Function ImportNFeD()

Local _aCampoSX3 := {}
Local _cCampoSX3 := ""
Local _nX        := 0

Local aItens   := {}
Local nI, nX
Local cAlias   := GetNextAlias()
Local cQuery   := ""
Local aFields  := {_cCmp1+"_FILIAL", _cCmp1+"_DOC", _cCmp1+"_SERIE", _cCmp1+"_DTEMIS", _cCmp1+"_CODEMI",;
				   _cCmp1+"_LOJEMI", _cCmp1+"_EMIT", _cCmp1+"_EST", "NOUSER"}
Local aUpdFlds := {}
Local aCabec
Local aItens   := {}
Local cProduto := Space(TamSX3("D1_COD")[1])
Local cStrXml  := ""
Local cClasFis := ""
Local aAltItem := {_cCmp2+"_COD", _cCmp2+"_QUANT2", _cCmp2+"_TES",_cCmp2+"_PICM", _cCmp2+"_CF", _cCmp2+"_VUNIT", _cCmp2+"_CLASFI", _cCmp2+"_CC", _cCmp2+"_CONTA", _cCmp2+"_PEDIDO", _cCmp2+"_ITEMPC"}
Local aAltNFs  := {}
Local aNFsIni  := {"D2_OK", "D2_DOC", "D2_SERIE"}
Local lConfirm := .F.
Local cEnchOld := GetMv("MV_ENCHOLD")

//Totais
Private nValFrete
Private nValSeguro
Private nValDesp
Private nValDesc
Private nValMerc
////////

Private oXml
Private oLayerNFeD
Private oGetDItem, oGetDNFs
Private aHeadItem := {}
Private aColsItem
Private aHeadNFs  := {}
Private aColsNFs
Private oBrwNFsIt
Private aMarcNFs  := {}
Private oFootAtu
Private oFootDes
Private cDescDev  := IIf(cCombo1=="D", "devolução", "beneficiamento")
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.

	If (_cTab1)->( Eof() )
		MsgStop("Não existem notas fiscais a importar!", "Aviso")
		Return .F.
	EndIf

	If Empty(cEspNFe)
		MsgStop("Espécie do Documento deve ser informada!", "Aviso")
		Return .F.
	EndIf

	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	If !SA1->( dbSeek(xFilial("SA1") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )
		MsgStop("Cliente não encontrado com o código/loja: " + AllTrim((_cTab1)->&(_cCmp1+"_CODEMI")) + "/" + AllTrim((_cTab1)->&(_cCmp1+"_LOJEMI")) + ".", "Nota Fiscal de " + cDescDev)
		Return .F.
	EndIf


	Begin Sequence

		oXml := NIL
		oXml := XmlParser((_cTab1)->&(_cCmp1+"_XML"), "_", @cError, @cWarning)
		If Empty(oXml)
			MsgStop("Falha ao gerar o Objeto XML:" + cError, "Erro")
			Break
		Else

			nValFrete  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vFrete:Text), nDecTot)
			nValSeguro := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vSeg:Text  ), nDecTot)
			nValDesp   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vOutro:Text), nDecTot)
			nValDesc   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vDesc:Text ), nDecTot)
			nValMerc   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vProd:Text ), nDecTot)

			If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
	        	XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
			EndIf

			DEFINE MSDIALOG oDlgNFeD FROM aSize[7],0 TO aSize[6],aSize[5] TITLE 'Importador - Nota Fiscal de ' + cDescDev STYLE DS_MODALFRAME PIXEL
				oDlgNFeD:lEscClose := .F.

				oLayerNFeD := FWLayer():New()
				oLayerNFeD:Init(oDlgNFeD, .F.)
				oLayerNFeD:AddLine('TOP', 29, .F.)
				oLayerNFeD:AddCollumn('NFED_INFO', 100, .T., 'TOP')
				oLayerNFeD:AddWindow('NFED_INFO', 'WIN_NFED_INFO', "Informações da Nota Fiscal de " + IIf(cCombo1=="D", "Devolução", "Beneficiamento") + " a ser importada", 100, .F., .T.,, 'TOP',)

							RegToMemory(_cTab1)
							PutMv("MV_ENCHOLD", "2")
							oGetCab := MsMGet():New(_cTab1,, MODEL_OPERATION_UPDATE,,,, aFields, {0,0,0,0}, aUpdFlds,;
									   ,,,, oLayerNFeD:GetWinPanel('NFED_INFO', 'WIN_NFED_INFO', 'TOP'),,.T.,,,.T.,,,,,,,.T.)
							PutMv("MV_ENCHOLD", cEnchOld)
							oGetCab:oBox:Align := CONTROL_ALIGN_ALLCLIENT

				oLayerNFeD:AddLine('CENTER', 33, .F.)
				oLayerNFeD:AddCollumn('NFED_ITEM', 100, .T., 'CENTER')
				oLayerNFeD:AddWindow('NFED_ITEM', 'WIN_NFED_ITEM', "Itens da Nota Fiscal de " + IIf(cCombo1=="D", "Devolução", "Beneficiamento") + " a ser importada", 100, .F., .T.,, 'CENTER',)

					If SF2->(FieldPos("D2_OK")) > 0
						AADD(aHeadItem, {"Vinculada?", _cCmp2+"_OK", "@BMP", 9,;
										GetSX3Cache("D2_OK", "X3_DECIMAL"),;
										GetSX3Cache("D2_OK", "X3_VALID"),;
										GetSX3Cache("D2_OK", "X3_USADO"),;
										GetSX3Cache("D2_OK", "X3_TIPO"),;
										GetSX3Cache("D2_OK", "X3_F3"),;
										GetSX3Cache("D2_OK", "X3_CONTEXT") })
					EndIf

					_aCampoSX3 := U_XAGSX3(_cTab2/*, _cCmp2+"_FILIAL|"+_cCmp2+"_PEDIDO|"+_cCmp2+"_ITEMPC|"+_cCmp2+"_BASEIC|"+_cCmp2+"_PICM|"+_cCmp2+"_VALICM|"+_cCmp2+"_BASEIP|"+_cCmp2+"_IPI|"+_cCmp2+"_VALIPI"*/)

					For _nX := 1 To Len(_aCampoSX3)
						_cCampoSX3 := _aCampoSX3[_nX]

						If !(AllTrim(_cCampoSX3) $ _cCmp2+"_FILIAL|"+_cCmp2+"_PEDIDO|"+_cCmp2+"_ITEMPC|"+_cCmp2+"_BASEIC|"+_cCmp2+"_PICM|"+_cCmp2+"_VALICM|"+_cCmp2+"_BASEIP|"+_cCmp2+"_IPI|"+_cCmp2+"_VALIPI") 
						
							AADD(aHeadItem, {Trim(GetSX3Cache(_cCampoSX3, "X3_TITULO")),;
						                 _cCampoSX3,;
										 GetSX3Cache(_cCampoSX3, "X3_PICTURE"),;
										 GetSX3Cache(_cCampoSX3, "X3_TAMANHO"),;
										 GetSX3Cache(_cCampoSX3, "X3_DECIMAL"),;
										 GetSX3Cache(_cCampoSX3, "X3_VALID"),;
										 GetSX3Cache(_cCampoSX3, "X3_USADO"),;
										 GetSX3Cache(_cCampoSX3, "X3_TIPO"),;
										 GetSX3Cache(_cCampoSX3, "X3_F3"),;
										 GetSX3Cache(_cCampoSX3, "X3_CONTEXT") })
						Endif
					Next _nX 

					aColsItem := {}
					aMarcNFs  := Array(Len(oXml:_NfeProc:_Nfe:_InfNfe:_det))
					aFill(aMarcNFs, {"", "", "", "", "", ""})

					//-------------------- Carregar Itens do Xml no array

					For nI := 1 To Len(oXml:_NfeProc:_Nfe:_InfNfe:_det)

						cProduto := Space(TamSX3("B1_COD")[1])
						AAdd(aColsItem, Array(Len(aHeadItem) + 1))

						For nX := 1 To Len(aHeadItem)
							If !(aHeadItem[nX, 2] $ _cCmp2+"_OK")
								aColsItem[nI, nX] := CriaVar(aHeadItem[nX, 2])
							EndIf
						Next nX

						aColsItem[nI, Len(aHeadItem) + 1] := .F.
						cQuery := "SELECT SA7.A7_PRODUTO FROM " + RetSqlName("SA7") + " SA7"
						cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
						cQuery += " SA7.A7_FILIAL = '" + xFilial("SA7") + "' AND "
						cQuery += " SA7.A7_CLIENTE = '" + M->&(_cCmp1+"_CODEMI") + "' AND "
						cQuery += " SA7.A7_LOJA = '" + M->&(_cCmp1+"_LOJEMI") +"' AND "
						cQuery += " SA7.A7_CODCLI = '" + AllTrim(Upper(StrTran(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text,"'"))) + "' AND "
						cQuery += " SA7.A7_PRODUTO <> ' '"

						If Select(cAlias) > 0
							(cAlias)->( dbCloseArea() )
						EndIf

						dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
						If !(cAlias)->( Eof() )
							cProduto := (cAlias)->A7_PRODUTO
								//Bloqueio por tipo de produtos
								DbSelectarea('SB1')
								Dbsetorder(1)
								If Dbseek(xFilial('SB1') + cProduto)
									If alltrim(SB1->B1_TIPO)  $ 'SH/PA/LU/QR/AE' 
										cProdBloq +=  SB1->B1_COD +'-' +alltrim(SB1->B1_DESC) +chr(10)  
									Endif
								Endif
							EndIf

						If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nI) + "]:_imposto:_ICMS") == "O"

							SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_imposto:_ICMS XMLSTRING cStrXml
							If At("<ICMS00>", cStrXml) > 0
								cClasFis := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
							EndIf

						EndIf

						//aColsItem[nI][1]  := "CANCEL_15" // Vinculada?
						aColsItem[nI][2-1]  := SubStr(  PADR( AllTrim(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text),15,'') + " - " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_xProd:Text), 1, 40) // Desrição do Item (vindo do Xml no formato do Cliente)
						aColsItem[nI][3-1]  := cProduto // Código do Produto
						aColsItem[nI][4-1]  := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC"), Space(TamSX3("B1_DESC")[1])) // Descrição do Produto
						aColsItem[nI][5-1]  := oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_uCom:Text // Unidade de Medida
						aColsItem[nI][6-1]  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_qCom:Text), nDecQtd) // Quantidade no XML
						aColsItem[nI][7-1]  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_qCom:Text), nDecQtd) // Quantidade da Nota de saída selecionada
						aColsItem[nI][8-1]  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_vUnCom:Text), nDecVal) // Valor unitário
						aColsItem[nI][9-1]  := Round(aColsItem[nI][7-1] * aColsItem[nI][8-1], nDecTot) // Valor total
						aColsItem[nI][10-1] := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_TE"), Space(TamSX3("B1_TE")[1])) // Tes
						aColsItem[nI][11-1] := IIf(!Empty(aColsItem[nI][10]), IIf(GETMV("MV_ESTADO") == M->&(_cCmp1+"_EST"), "1", "2") + Substr(Posicione("SF4", 1, xFilial("SF4") + aColsItem[nI][10], "F4_CF"), 2, 3), "") // Código Fiscal
						aColsItem[nI][12-1] :=  cClasFis // Classificação Fiscal

					Next nI

					(cAlias)->( dbCloseArea() )
					If Len(aMarcNFs) == 0
						MsgStop("Não há itens vinculados a Nota Fiscal.")
						Break
					EndIf

						If Alltrim(cProdBloq) <> ''
							Alert('Para produtos do Tipo SH,PA,LU,QR e AE você deve utilizar o Importador NOVO:  '+chr(10) +cProdBloq )
							Return
						Endif 

					oGetDItem := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltItem, 0, 999, NIL, NIL, "AlwaysFalse", oLayerNFeD:GetWinPanel('NFED_ITEM', 'WIN_NFED_ITEM', 'CENTER'), aHeadItem, aColsItem, "")
					oGetDItem:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					oGetDItem:oBrowse:bSeekChange := {|| CargaNFs() }
				   	oGetDItem:oBrowse:bDrawSelect := {|| CargaNFs() }

				oLayerNFeD:AddLine('MIDDLE', 33, .F.)
				oLayerNFeD:AddCollumn('NFED_NFS', 100, .T., 'MIDDLE')
				oLayerNFeD:AddWindow('NFED_NFS', 'WIN_NFED_NFS', "Itens das Notas Fiscais de origem (Saída)", 100, .F., .T.,, 'MIDDLE',)

					For nI := 1 To Len(aNFsIni)
						_cCampoSX3 := aNFsIni[nI]

						If !Empty(GetSX3Cache(_cCampoSX3, "X3_CAMPO"))
							AADD(aHeadNFs, {Trim(GetSX3Cache(_cCampoSX3, "X3_TITULO")),;
							                _cCampoSX3,;
											IIf(AllTrim(aNFsIni[nI]) == "D2_OK", "@BMP", GetSX3Cache(_cCampoSX3, "X3_PICTURE")),;
											IIf(AllTrim(aNFsIni[nI]) == "D2_OK", 8, GetSX3Cache(_cCampoSX3, "X3_TAMANHO")),;
											GetSX3Cache(_cCampoSX3, "X3_DECIMAL"),;
											GetSX3Cache(_cCampoSX3, "X3_VALID"),;
											GetSX3Cache(_cCampoSX3, "X3_USADO"),;
											GetSX3Cache(_cCampoSX3, "X3_TIPO"),;
											GetSX3Cache(_cCampoSX3, "X3_F3"),;
											GetSX3Cache(_cCampoSX3, "X3_CONTEXT") })
						EndIf
					Next nI

					_aCampoSX3 := U_XAGSX3("SD2",,.T.,.F.)

					For _nX := 1 To Len(_aCampoSX3)

						_cCampoSX3 := _aCampoSX3[_nX]

						If !(AllTrim(_cCampoSX3) $ "D2_FILIAL") .And. AScan(aNFsIni, {|x| x = AllTrim(_cCampoSX3)}) == 0
							AADD(aHeadNFs, {Trim(GetSX3Cache(_cCampoSX3, "X3_TITULO")),;
											_cCampoSX3,;
											GetSX3Cache(_cCampoSX3, "X3_PICTURE"),;
											GetSX3Cache(_cCampoSX3, "X3_TAMANHO"),;
											GetSX3Cache(_cCampoSX3, "X3_DECIMAL"),;
											GetSX3Cache(_cCampoSX3, "X3_VALID"),;
											GetSX3Cache(_cCampoSX3, "X3_USADO"),;
											GetSX3Cache(_cCampoSX3, "X3_TIPO"),;
											GetSX3Cache(_cCampoSX3, "X3_F3"),;
											GetSX3Cache(_cCampoSX3, "X3_CONTEXT") })
						EndIf
					End

					aColsNFs := {}
					oGetDNFs := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltNFs, 0, 999, NIL, NIL, "AlwaysFalse", oLayerNFeD:GetWinPanel('NFED_NFS', 'WIN_NFED_NFS', 'MIDDLE'), aHeadNFs, aColsNFs, {|| /*bChange*/})
				   	oGetDNFs:oBrowse:blDblClick := {|x, nCol| MarcaNFs()}
					oGetDNFs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

					//----------------- Carrega NFs de Saída
					CargaNFs(.F., aColsNFs)
					//-----------------

					oLayerNFeD:AddLine('BOTTOM', 5, .F.)
					oLayerNFeD:AddCollumn('NFED_BAR', 100, .T., 'BOTTOM')

					oPanelBot := tPanel():New(0, 0, "", oLayerNFeD:GetColPanel('NFED_BAR', 'BOTTOM'),,,,, RGB(239,243,247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT

					oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgNFeD:End()}, , ,)
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002,070,112),)

					oImp := THButton():New(0, 0, "Importar " + Capital(cDescDev), oPanelBot, {|| lConfirm := .T., IIf(InsereNFeD(@lConfirm), oDlgNFeD:End(),)},,,)
					oImp:nWidth  := 120
					oImp:nHeight := 10
					oImp:Align   := CONTROL_ALIGN_RIGHT
					oImp:SetColor(RGB(002,070,112),)

					oFootAtu := TSay():New(4, 10,{|| "  Todos os itens estão vinculados." }, oPanelBot,, TFont():New('Arial',,-12,,.F.),,,,.T., CLR_BLUE, CLR_WHITE,140,30)
					oFootAtu:Align := CONTROL_ALIGN_LEFT
					oFootAtu:Hide()

					oFootDes := TSay():New(4, 10,{|| "  Há itens ainda não vinculados." }, oPanelBot,, TFont():New('Arial',,-12,,.T.),,,,.T., CLR_RED, CLR_WHITE,140,30)
					oFootDes:Align := CONTROL_ALIGN_LEFT
					oFootDes:Show()

			ACTIVATE MSDIALOG oDlgNFeD CENTERED

		EndIf

	End Sequence
	AtuBrowse()

Return .T.

///////////////////////////////////////////

Static Function InsereNFeD(lConfirm)
Local nItem
Local aCabec
Local aItens := {}
Local aColsItem := oGetDItem:aCols
Local nPos
Local lRet   := .T.
Local _i     := 0 
Local _lTemNFori := .F.
Local _lNaoTemNF := .F.

Private lMsHelpAuto    := .F.
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.

	If (nPos := aScan(aColsItem, {|x| Empty(x[GDFieldPos(_cCmp2+"_COD", oGetDItem:aHeader)])})) > 0
		Help( ,, 'Help',, "O campo do Produto deve ser informado para o item da Nota Fiscal na linha " + cValToChar(nPos) + ".", 1, 0 )
		Return .F.
	EndIf

	If (nPos := aScan(aColsItem, {|x| Empty(x[GDFieldPos(_cCmp2+"_TES", oGetDItem:aHeader)])})) > 0
		Help( ,, 'Help',, "O campo do TES deve ser informado para o item da Nota Fiscal na linha " + cValToChar(nPos) + ".", 1, 0 )
		Return .F.
	EndIf

	//Desabilitada Obrigação de Nota de Origem
	//If AScan(aMarcNFs, {|x| Empty(x[1] + x[2] + x[3] + x[4] + x[5] + x[6])}) > 0
	//	Help( ,, 'Help',, "Todos os itens da Nota Fiscal de " + cDescDev + " devem estar relacionados a um item de uma Nota Fiscal de " + IIf(cCombo1 $ "I;P;C", "Entrada", "Saída") + ".", 1, 0 )/
	//	Return .F.
	//EndIf

	//Valida Preenchimeno do item da Nota
	For _i := 1 To Len(aMarcNFs)

		//Verifica se Tem itens com Nota Vinculada
		If alltrim(aMarcNFs[_i][6] )<> ''
			_lTemNFori := .T.
		Else 
			_lNaoTemNF := .T.
		Endif
 
		//Caso haja itens com e sem nota de origem Bloqueia inclusão
		If _lTemNFori .AND. _lNaoTemNF
			Help( ,, 'Help',, "Caso um item seja vinculado a nota de origem, você terá que víncular todos. ", 1, 0 )
			Return .F.	
		Endif 

	Next _i

	_i         := 0 
	nBasIcmsST := 0
	nValIcmsST := 0

	For nItem := 1 To Len(aColsItem)

		/*AAdd(aItens, {{"D1_ITEM"   , StrZero(nItem, 4)                                                 , Nil},;
  					  {"D1_COD"	   , GDFieldGet(_cCmp2+"_COD", nItem,, oGetDItem:aHeader, aColsItem)   , Nil},;
    				  {"D1_UM"     , GDFieldGet(_cCmp2+"_UM", nItem,, oGetDItem:aHeader, aColsItem)    , Nil},;
		              {"D1_VUNIT"  , GDFieldGet(_cCmp2+"_VUNIT", nItem,, oGetDItem:aHeader, aColsItem) , Nil},;
	    	          {"D1_TOTAL"  , GDFieldGet(_cCmp2+"_TOTAL", nItem,, oGetDItem:aHeader, aColsItem) , Nil},;
	    	          {"D1_TES"    , GDFieldGet(_cCmp2+"_TES", nItem,, oGetDItem:aHeader, aColsItem)   , Nil},;
	    	          {"D1_TIPO"   , cCombo1                                                           , Nil},;
	    	          {"D1_SERIE"  , (_cTab1)->&(_cCmp1+"_SERIE")                                      , Nil},;
	    	          {"D1_CLASFIS", GDFieldGet(_cCmp2+"_CLASFI", nItem,, oGetDItem:aHeader, aColsItem), Nil},;
					  {"D1_NFORI"  , iif(alltrim(aMarcNFs[nItem][1]) <> '',aMarcNFs[nItem][1],'999999999') , Nil},;
					  //{"D1_SERIORI", aMarcNFs[nItem][2]											    , Nil},;
					  //{"D1_ITEMORI", aMarcNFs[nItem][6]                                                , Nil},;
	    	          {"D1_CONTA"  , GDFieldGet(_cCmp2+"_CONTA", nItem,, oGetDItem:aHeader, aColsItem) , Nil},;
	    	          {"D1_CC"     , GDFieldGet(_cCmp2+"_CC", nItem,, oGetDItem:aHeader, aColsItem)    , Nil},;
	    	          {"D1_VENCPRV", GDFieldGet(_cCmp2+"_VENCPR", nItem,, oGetDItem:aHeader, aColsItem)   , Nil},;
	    	          {"D1_VLDDPRV", GDFieldGet(_cCmp2+"_VLDDPR", nItem,, oGetDItem:aHeader, aColsItem)   , Nil},;
	    	          {"D1_BRICMS" , GDFieldGet(_cCmp2+"_BRICMS", nItem,, oGetDItem:aHeader, aColsItem)   , Nil},;
	    	          {"D1_ICMSRET", GDFieldGet(_cCmp2+"_ICMRET", nItem,, oGetDItem:aHeader, aColsItem)   , Nil},;
	    	          {"AUTDELETA" , "N"			                                                   , Nil};
	    	         })
		*/

		AAdd(aItens, {})
			AAdd(aItens[len(aItens)], {"D1_ITEM"   , StrZero(nItem, 4), Nil} )                                                
  			AAdd(aItens[len(aItens)], {"D1_COD"	   , GDFieldGet(_cCmp2+"_COD", nItem,, oGetDItem:aHeader, aColsItem)   , Nil})
    		AAdd(aItens[len(aItens)], {"D1_UM"     , GDFieldGet(_cCmp2+"_UM", nItem,, oGetDItem:aHeader, aColsItem)    , Nil})
		    AAdd(aItens[len(aItens)], {"D1_VUNIT"  , GDFieldGet(_cCmp2+"_VUNIT", nItem,, oGetDItem:aHeader, aColsItem) , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_TOTAL"  , GDFieldGet(_cCmp2+"_TOTAL", nItem,, oGetDItem:aHeader, aColsItem) , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_TES"    , GDFieldGet(_cCmp2+"_TES", nItem,, oGetDItem:aHeader, aColsItem)   , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_TIPO"   , cCombo1                                                           , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_SERIE"  , (_cTab1)->&(_cCmp1+"_SERIE")                                      , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_CLASFIS", GDFieldGet(_cCmp2+"_CLASFI", nItem,, oGetDItem:aHeader, aColsItem), Nil})
			AAdd(aItens[len(aItens)], {"D1_NFORI"  , iif(alltrim(aMarcNFs[nItem][1]) <> '',aMarcNFs[nItem][1],'999999999') , Nil})
			If _lTemNFori
				AAdd(aItens[len(aItens)],{"D1_SERIORI", aMarcNFs[nItem][2] , Nil})
				AAdd(aItens[len(aItens)],{"D1_ITEMORI", aMarcNFs[nItem][6],, Nil})
	    	Endif 
			AAdd(aItens[len(aItens)], {"D1_CONTA"  , GDFieldGet(_cCmp2+"_CONTA", nItem,, oGetDItem:aHeader, aColsItem) , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_CC"     , GDFieldGet(_cCmp2+"_CC", nItem,, oGetDItem:aHeader, aColsItem)    , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_VENCPRV", GDFieldGet(_cCmp2+"_VENCPR", nItem,, oGetDItem:aHeader, aColsItem)   , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_VLDDPRV", GDFieldGet(_cCmp2+"_VLDDPR", nItem,, oGetDItem:aHeader, aColsItem)   , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_BRICMS" , GDFieldGet(_cCmp2+"_BRICMS", nItem,, oGetDItem:aHeader, aColsItem)   , Nil})
	    	AAdd(aItens[len(aItens)], {"D1_ICMSRET", GDFieldGet(_cCmp2+"_ICMRET", nItem,, oGetDItem:aHeader, aColsItem)   , Nil})
			AAdd(aItens[len(aItens)], {"D1_XTES"    , GDFieldGet(_cCmp2+"_TES", nItem,, oGetDItem:aHeader, aColsItem)   , Nil})
	    	AAdd(aItens[len(aItens)], {"AUTDELETA" , "N"			                                                   , Nil})
	    	        
			nBasIcmsST := nBasIcmsST + GDFieldGet(_cCmp2+"_BRICMS", nItem,, oGetDItem:aHeader, aColsItem)
			nValIcmsST := nValIcmsST + GDFieldGet(_cCmp2+"_ICMRET", nItem,, oGetDItem:aHeader, aColsItem)

	 	If cCombo1 $ "D;B"

	 		AIns(ATail(aItens), 4)
	 		ATail(aItens)[4] := {"D1_QUANT"  , GDFieldGet(_cCmp2+"_QUANT2", nItem,, oGetDItem:aHeader, aColsItem), Nil}

	 	EndIf
	Next nItem

	aCabec := {{"F1_DOC"	, (_cTab1)->&(_cCmp1+"_DOC")					           , Nil, Nil},;
	           {"F1_SERIE"  , (_cTab1)->&(_cCmp1+"_SERIE")                             , Nil, Nil},;
	           {"F1_FORNECE", (_cTab1)->&(_cCmp1+"_CODEMI")			                   , Nil, Nil},;
	           {"F1_LOJA"   , (_cTab1)->&(_cCmp1+"_LOJEMI")				               , Nil, Nil},;
	           {"F1_EMISSAO", (_cTab1)->&(_cCmp1+"_DTEMIS")                            , Nil, Nil},;
	           {"F1_DTDIGIT", dDataBase		     		                               , Nil, Nil},;
	           {"F1_EST"    , (_cTab1)->&(_cCmp1+"_EST")		      	               , Nil, Nil},;
	           {"F1_TIPO"   , cCombo1                                                  , Nil, Nil},;
	           {"F1_ESPECIE", cEspNFe					                               , Nil, Nil},;
	           {"F1_FORMUL" , "N"					    	                           , Nil, Nil},;
	           {"F1_CHVNFE" , (_cTab1)->&(_cCmp1+"_CHAVE")                             , Nil, Nil},;
	           {"F1_VALMERC", nValMerc                                                 , Nil, Nil},;
	           {"F1_FRETE"  , nValFrete                                                , Nil, Nil},;
	           {"F1_DESPESA", nValDesp                                                 , Nil, Nil},;
	           {"F1_DESCONT", nValDesc                                                 , Nil, Nil},;
	           {"F1_SEGURO" , nValSeguro                                               , Nil, Nil},;
	           {"F1_BRICMS" , nBasIcmsST                                               , Nil, Nil},;
	           {"F1_ICMSRET", nValIcmsST                                               , Nil, Nil},;
	           {"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil},;
			   {"F1_ORIIMP", 'SMS001'												   , Nil, Nil},;	
	           {"E2_NATUREZ", M->&(_cCmp1+"_NATFIN")                                   , Nil, Nil};
			  }

	Begin Transaction

		If lPreNota 
			MsAguarde({|| MsExecAuto({|x,y,z,w,k| MATA140(x,y,z,w,k)}, aCabec, aItens, 3, .F., 1)}, "Pré-nota de entrada", "Importando Pré-nota de Devolução...")
		Else
			MsAguarde({|| MsExecAuto({|x,y,z,w| Mata103(x,y,z,w)}, aCabec, aItens, 3, lConfere)}, "Importação", "Importando Nota Fiscal de " + cDescDev + "...")
		Endif

		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		If !lMsErroAuto .And. !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

			lConfirm := .F.
			lRet := .F.
			

	    ElseIf lMsErroAuto

	    	DisarmTransaction()
      		RecLock(_cTab1, .F.)
			(_cTab1)->&(_cCmp1+"_SIT")  := "3"
			(_cTab1)->&(_cCmp1+"_ERRO") := MontaErro(GetAutoGrLog())
			(_cTab1)->( MSUnlock() )

      		ExibeErro()
      		lRet := .F.

		Else

			If alltrim(SF1->F1_ORIIMP) == ''
				Reclock('SF1',.F.)
					SF1->F1_ORIIMP := 'SMS001'
				SF1->(MsUnlock())
			Endif

			//Cria SA7 para o produto confirmado na Nota Fiscal
			For _i := 1 to len(aColsItem)

				Dbselectarea('SA7')
				DbSetOrder(1)
				//FILIAL + CLIENTE + LOJA +PRODUTO
				If Dbseek(xfilial('SA7') + (_cTab1)->&(_cCmp1+"_CODEMI")+ (_cTab1)->&(_cCmp1+"_LOJEMI") + aColsItem[_i][2] )
					If alltrim(SA7->A7_CODCLI) == ''
						RecLock('SA7',.F.)
							SA7->A7_CODCLI  := SUBSTR(aColsItem[_i][1],1,15)
							SA7->A7_DESCCLI := SUBSTR(aColsItem[_i][1],19,25)
						Msunlock()
					Endif
				Else
					RecLock('SA7',.T.)
						SA7->A7_FILIAL  := xFilial('SA7')
						SA7->A7_CLIENTE := (_cTab1)->&(_cCmp1+"_CODEMI")
						SA7->A7_LOJA    := (_cTab1)->&(_cCmp1+"_LOJEMI")
						SA7->A7_PRODUTO := aColsItem[_i][2] 
						SA7->A7_CODCLI := SUBSTR(aColsItem[_i][1],1,15)
						SA7->A7_DESCCLI := SUBSTR(aColsItem[_i][1],19,25)
					Msunlock()

				Endif 
			Next _i 


			If !lPreNota
				// faço update na SE2 com o histórico do título
				_cHistor := substr(_cHistor,1,(tamSX3("E2_HIST")[1]))
				cQuery := "update " + retSqlName("SE2") + "  set E2_HIST = '" + alltrim(_cHistor) + "'"
				cQuery += " where E2_NUM = '" + (_cTab1)->&(_cCmp1+"_DOC") + "' " 
				cQuery += " and E2_PREFIXO = '" + (_cTab1)->&(_cCmp1+"_SERIE") + "' "
				cQuery += " and E2_TIPO = 'NF' "
				cQuery += " and E2_FORNECE = '" + (_cTab1)->&(_cCmp1+"_CODEMI") + "' "	
				cQuery += " and E2_LOJA = '" + (_cTab1)->&(_cCmp1+"_LOJEMI")  + "' "
				cQuery += " and E2_FILIAL = '" + xFilial("SE2") + "' "
				cQuery += " and D_E_L_E_T_ <> '*' "
				
				If (TCSQLExec(cQuery) < 0)
					MsgStop("TCSQLError() " + TCSQLError())
					lMsErroAuto := .T.
				EndIf		
			Endif
			
			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1+"_SIT")    := "2"
				(_cTab1)->&(_cCmp1+"_ERRO")   := ""
				(_cTab1)->&(_cCmp1+"_ESPECI") := cEspNFe
				(_cTab1)->&(_cCmp1+"_TIPOEN") := cCombo1
				(_cTab1)->&(_cCmp1+"_NATFIN") := M->&(_cCmp1+"_NATFIN")
				(_cTab1)->&(_cCmp1+"_DTIMP")  := dDataBase
				(_cTab1)->&(_cCmp1+"_HRIMP")  := Time()
				(_cTab1)->&(_cCmp1+"_USUIMP") := cUserName
			(_cTab1)->( MSUnlock() )
			
			
			MsgInfo("Importação realizada com sucesso!", "Aviso")

		EndIf

	End Transaction

Return lRet


///////////////////////////////////////////

Static Function CargaNFs(lRefresh, aCols)
Local nX
Local cQuery
Local cAlias
Local aCols	 := {}
Local cTab   := IIf(cCombo1 $ "I;P;C", "SD1", "SD2")
Local cProduto := GDFieldGet(_cCmp2+"_COD", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols)
Local lAchei := .F.

Default lRefresh := .T.
Default aCols    := {}
	//conout(cProduto)
	If Empty(cProduto)
		Return .F.
	EndIf

	cAlias := GetNextAlias()
	If cCombo1 $ "I;P;C"

		oLayerNFeC:SetWinTitle('NFEC_NFE', 'WIN_NFEC_NFE', "Itens das Notas Fiscais de Origem (Entrada) para o item " + AllTrim(GDFieldGet(_cCmp2+"_COD", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols)) + " - " + AllTrim(GDFieldGet(_cCmp2+"_DSPROD", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols)), 'MIDDLE')

		cQuery := " SELECT SD1.R_E_C_N_O_ TBRECNO "
		cQuery += " FROM " + RetSqlName("SF1") + "(NOLOCK) SF1"
		cQuery += " INNER JOIN " + RetSqlName("SD1") + "(NOLOCK) SD1"
		cQuery += " 	ON SD1.D1_FILIAL  = SF1.F1_FILIAL AND "
		cQuery += " 	   SD1.D1_FORNECE = SF1.F1_FORNECE AND "
		cQuery += " 	   SD1.D1_LOJA    = SF1.F1_LOJA AND "
		cQuery += " 	   SD1.D1_DOC     = SF1.F1_DOC AND "
		cQuery += " 	   SD1.D1_SERIE   = SF1.F1_SERIE AND "
		cQuery += " 	   SD1.D1_TIPO    = SF1.F1_TIPO "
		cQuery += " WHERE "
		cQuery += " 	SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
		cQuery += " 	SF1.F1_FORNECE = '" + M->&(_cCmp1+"_CODEMI") + "' AND "
		cQuery += " 	SF1.F1_LOJA    = '" + M->&(_cCmp1+"_LOJEMI") + "' AND "
		cQuery += "     SD1.D1_COD     = '" + cProduto + "' AND "
		cQuery += " 	SD1.D1_ORIGLAN <> 'LF' AND "
		cQuery += " 	SD1.D1_TIPO NOT IN('D', 'B', 'P', 'I') AND "
		cQuery += " 	SF1.D_E_L_E_T_ = ' ' AND "
		cQuery += " 	SD1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY "
		cQuery += " 	SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM "

	Else

		oLayerNFeD:SetWinTitle('NFED_NFS', 'WIN_NFED_NFS', "Itens das Notas Fiscais de Origem (Saída) para o item " + AllTrim(GDFieldGet(_cCmp2+"_COD", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols)) + " - " + AllTrim(GDFieldGet(_cCmp2+"_DSPROD", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols)), 'MIDDLE')

		cQuery := " SELECT SD2.R_E_C_N_O_ TBRECNO "
		cQuery += " FROM " + RetSqlName("SF2") + "(NOLOCK) SF2"
		cQuery += " INNER JOIN " + RetSqlName("SD2") + "(NOLOCK) SD2"
		cQuery += " 	ON SD2.D2_FILIAL = SF2.F2_FILIAL AND "
		cQuery += " 	SD2.D2_CLIENTE   = SF2.F2_CLIENTE AND "
		cQuery += " 	SD2.D2_LOJA      = SF2.F2_LOJA AND "
		cQuery += " 	SD2.D2_DOC       = SF2.F2_DOC AND "
		cQuery += " 	SD2.D2_SERIE     = SF2.F2_SERIE AND "
		cQuery += " 	SD2.D2_TIPO      = SF2.F2_TIPO "
		cQuery += " WHERE "
		cQuery += " 	SF2.F2_FILIAL  = '" + xFilial("SF2") + "' AND "
		cQuery += " 	SF2.F2_CLIENTE = '" + M->&(_cCmp1+"_CODEMI") + "' AND "
		cQuery += " 	SF2.F2_LOJA    = '" + M->&(_cCmp1+"_LOJEMI") + "' AND "
		cQuery += "     SD2.D2_COD     = '" + cProduto + "' AND "
		cQuery += " 	SD2.D2_ORIGLAN <> 'LF' AND "
		cQuery += " 	SF2.D_E_L_E_T_ = ' ' AND "
		cQuery += " 	SD2.D_E_L_E_T_ = ' ' "
		//Conout(cQuery)
	EndIf

	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

	if (cAlias)->( Eof() )
		AAdd(aCols, Array(Len(aHeadNFs) + 1))
		ATail(aCols)[Len(aHeadNFs) + 1] := .F.

		For nX := 1 To Len(aHeadNFs)

			If AllTrim(aHeadNFs[nX, 2]) $ "D2_OK;D1_OK"
				ATail(aCols)[nX] := "BR_VERMELHO"
			endif

			if Valtype(&(cTab + "->" + aHeadNFs[nX, 2])) == "C"
				xContErr := "N/D"
			elseif Valtype(&(cTab + "->" + aHeadNFs[nX, 2])) == "N"
				xContErr := 0
			elseif Valtype(&(cTab + "->" + aHeadNFs[nX, 2])) == "L"
				xContErr := .F.
			endif

			ATail(aCols)[nX] := xContErr

		Next nX


	endif

	While !(cAlias)->( Eof() )

		AAdd(aCols, Array(Len(aHeadNFs) + 1))
		ATail(aCols)[Len(aHeadNFs) + 1] := .F.

		dbSelectArea(cTab)
		(cTab)->( dbSetOrder(1) )
		(cTab)->( dbGoTo((cAlias)->TBRECNO) )

		For nX := 1 To Len(aHeadNFs)

			If AllTrim(aHeadNFs[nX, 2]) $ "D2_OK;D1_OK"

				If cCombo1 $ "D;B"

					If SD2->D2_DOC     == aMarcNFs[oGetDItem:nAt][1] .And. SD2->D2_SERIE == aMarcNFs[oGetDItem:nAt][2] .And.;
					   SD2->D2_CLIENTE == aMarcNFs[oGetDItem:nAt][3] .And. SD2->D2_LOJA  == aMarcNFs[oGetDItem:nAt][4] .And.;
					   SD2->D2_COD     == aMarcNFs[oGetDItem:nAt][5] .And. SD2->D2_ITEM  == aMarcNFs[oGetDItem:nAt][6]

						ATail(aCols)[nX] := "BR_VERDE"

					Else
						ATail(aCols)[nX] := Space(8)
					EndIf

				Else

					If SD1->D1_DOC     == aMarcNFs[oGetDItem:nAt][1] .And. SD1->D1_SERIE == aMarcNFs[oGetDItem:nAt][2] .And.;
					   SD1->D1_FORNECE == aMarcNFs[oGetDItem:nAt][3] .And. SD1->D1_LOJA  == aMarcNFs[oGetDItem:nAt][4] .And.;
					   SD1->D1_COD     == aMarcNFs[oGetDItem:nAt][5] .And. SD1->D1_ITEM  == aMarcNFs[oGetDItem:nAt][6]

						ATail(aCols)[nX] := "BR_VERDE"

					Else
						ATail(aCols)[nX] := Space(8)
					EndIf

				EndIf

			Else
				ATail(aCols)[nX] := &(cTab + "->" + aHeadNFs[nX, 2])
			EndIf

		Next nX
		(cAlias)->( dbSkip() )

	EndDo

	oGetDNFs:SetArray(aCols, .T.)

	If lRefresh
		oGetDNFs:oBrowse:Refresh()
	EndIf
	(cAlias)->( dbCloseArea() )

Return aCols

///////////////////////////////////////////

Static Function MarcaNFs()
Local nI
Local cImg := "BR_VERDE"
Local cEmit
Local cCmp
Local cDesc
Local cVUnit

	If cCombo1 $ "I;P;C"
		cEmit  := "D1_FORNECE"
		cCmp   := "D1"
		cDesc  := "Entrada"
		cVUnit := "D1_VUNIT"
	Else
		cEmit  := "D2_CLIENTE"
		cCmp   := "D2"
		cDesc  := "Saída"
		cVUnit := "D2_PRUNIT"
	EndIf
	If GDFieldGet("D2_OK", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols) == cImg
		GDFieldPut("D2_OK", Space(8), oGetDNfs:nAt, oGetDNfs:aHeader, oGetDNfs:aCols)
		GDFieldPut(_cCmp2+"_OK", "CANCEL_15", oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
		aMarcNFs[oGetDItem:nAt] := {"", "", "", "", "", ""}
	Else

		If (GDFieldGet(cCmp+"_DOC", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols)) == "N/D"
			MsgInfo("Não foram encontradas Notas Fiscais de " + cDesc + " para o item selecionado.")
			Return
		EndIf

		If Empty(GDFieldGet(cCmp+"_DOC", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols))
			MsgInfo("Não foram encontrados itens de Notas Fiscais de " + cDesc + " para selecionar.")
			Return
		EndIf

		For nI := 1 To Len(oGetDNfs:aCols)
			GDFieldPut(cCmp+"_OK", Space(8), nI, oGetDNfs:aHeader, oGetDNfs:aCols)
		Next nI

		GDFieldPut(cCmp+"_OK", cImg, oGetDNfs:nAt, oGetDNfs:aHeader, oGetDNfs:aCols)
		GDFieldPut(_cCmp2+"_OK", "OK_15", oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)

		aMarcNFs[oGetDItem:nAt] := {GDFieldGet(cCmp+"_DOC", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
									GDFieldGet(cCmp+"_SERIE", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
									GDFieldGet(cEmit        , oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
									GDFieldGet(cCmp+"_LOJA", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
									GDFieldGet(cCmp+"_COD", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
									GDFieldGet(cCmp+"_ITEM", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols)}

		If cCombo1 $ "D;B" .And. GDFieldGet(cVUnit, oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols) # GDFieldGet(_cCmp2+"_VUNIT", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols)

			If Aviso("Preço unitário", "O preço unitário da Nota Fiscal de origem é " + AllTrim(Transform(GDFieldGet(cVUnit, oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols), "@E 999,999,999.99")) + ;
			                           " e do item do XML " + AllTrim(Transform(GDFieldGet(_cCmp2+"_VUNIT", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols), "@E 999,999,999.99")) + ". " + ;
			                           "Deseja substituir o valor com o da Nota Fiscal de origem?", {"Substituir", "Manter"}, 2) == 1

				GDFieldPut(_cCmp2+"_VUNIT", GDFieldGet(cVUnit, oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols), oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
				GDFieldPut(_cCmp2+"_TOTAL", GDFieldGet(cVUnit, oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols) * GDFieldGet(_cCmp2+"_QUANT2", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols), oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)

			EndIf

		EndIf

	EndIf

	oGetDItem:oBrowse:Refresh()
	oGetDNfs:oBrowse:Refresh()

	//Verifica Conteudo de AmarcacNfs
	/*For _i := 1 to len(aMarcNFs)
		For _x := 1 to len(aMarcNFs[_i])
			CONOUT(alltrim(str(_i)) + ' - ' + alltrim(str(_x ))+ ' - ' + valtype(aMarcNFs[_i][_x]) )
			CONOUT(aMarcNFs[_i][_x])
		Next _x
	Next _i */

	If AScan(aMarcNFs, {|x| Empty(x[1] + x[2] + x[3] + x[4] + x[5] + x[6])}) > 0
		oFootAtu:Hide()
		oFootDes:Show()
	Else
		oFootAtu:Show()
		oFootDes:Hide()
	EndIf

Return



///////////////////////////////////////////
// Função de importação do XML de Nota Fiscal selecionado.
Static Function ImportarNFe()

Local _aCampoSX3 := {}
Local _cCampoSX3 := ""
Local _nX        := 0

Local oDlgItens, oPanel1, oPanel2, oPanel3
Local aItens    := {}
Local aStruct   := {}
Local aAlter    := {}
Local nUsado    := 0
Local cStrXml   := ""
Local cPedido   := ""
Local cItemPC   := ""
Local cStTrib   := ""
Local nBaseICM  := 0
Local nPerICM   := 0
Local nValICM   := 0
Local nBaseIPI  := 0
Local nPerIPI   := 0
Local nValIPI   := 0
Local nBasePIS  := 0
Local nPerPIS   := 0
Local nValPIS   := 0
Local nBasCOFINS  := 0
Local nPerCOFINS   := 0
Local nValCOFINS   := 0
Local nPmVast   := 0
Local nPRedBCST   := 0
Local nBaseICST   := 0
Local nPerICMST   := 0
Local nValICMST   := 0
Local nvICMSDeson   := 0
Local _aCamposNfe	:= {}
Local nVdesc      := 0 
Local lImport   := .F.
Local lConfirm  := .F.
Local lProdForn := .F.
Local dDtEmis   := (_cTab1)->&(_cCmp1+"_DTEMIS")
Local nX1 := 0
Local nX := 0
Local nY := 0
Local aCampos := {}
//Totais                          
Private nValFrete
Private nValSeguro
Private nValDesp
Private nValDesc
Private nValMerc
////////

Private cNaturez   	:= Space(10)
Private cConPgto   	:= Space(03)
private _cHistor	:= space(tamSX3("E2_HIST")[1])
Private cCusto	   	:= ""
Private cCtaCont   	:= ""
Private cFornece   	:= ""
Private cLoja	   	:= ""
Private cDescFor   	:= ""
Private cValidad	:= space(50)
Private cEstado    	:= "" 
Private dDtVcto		:= dDataBase
Private aHeader    	:= {}
Private aCols	   	:= {}
Private oGetD
Private oLayerImp           
  
// Leandro Spiller - 29.11.2016
// Fixa F4 para consulta de Pedidos
// de Compra
SetKey( VK_F4,			{ || ConsPed() } )

	If (_cTab1)->( Eof() )
		MsgStop("Não existem notas fiscias a importar!", "Aviso")
		Return .F.
	EndIf

	If Empty(cEspNFe)
		MsgStop("Espécie do Documento deve ser informada!", "Aviso")
		Return .F.
	EndIf


	Begin Sequence

		If (_cTab1)->&(_cCmp1+"_CGCDES") <> SM0->M0_CGC

			If !MsgYesNo("CNPJ do destinatário do documento não confere com a Filial corrente do sistema!" + CRLF + ;
						 "CNPJ arquivo XML: " + Transform((_cTab1)->&(_cCmp1+"_CGCDES"), "@R 99.999.999/9999-99") + CRLF + ;
						 "CNPJ Empresa/Filial: " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + CRLF + ;
						 "Deseja continuar?", "Aviso")
				Break
			EndIf
		EndIf


		oXml := NIL
		oXml := XmlParser((_cTab1)->&(_cCmp1+"_XML"), "_", @cError, @cWarning)
		If Empty(oXml)
			MsgStop("Falha ao gerar o Objeto XML:" + cError, "Erro")
			Break
		Else

			nValFrete  := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vFrete:Text), nDecTot)
			nValSeguro := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vSeg:Text  ), nDecTot)
			nValDesp   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vOutro:Text), nDecTot)
			nValDesc   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vDesc:Text ), nDecTot)
			nValMerc   := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vProd:Text ), nDecTot)

			If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
	        	XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
			EndIf


			For nX1 := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)

				SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod XMLSTRING cStrXml
				If At("<xPed>", cStrXml) > 0 .AND. At("<nItemPed>", cStrXml) > 0
					cPedido := Substr(cStrXml, At("<xPed>", cStrXml) + 6, At("</xPed>", cStrXml) - (At("<xPed>", cStrXml) + 6))
					cItemPC := Substr(cStrXml, At("<nItemPed>", cStrXml) + 10, At("</nItemPed>", cStrXml) - (At("<nItemPed>", cStrXml) + 10))
				EndIf
				
				nVdesc := 0 
				If At("<vDesc>", cStrXml) > 0 
					nVdesc := Val(Substr(cStrXml, At("<vDesc>", cStrXml) + 7, At("</vDesc", cStrXml) - (At("<vDesc>", cStrXml) + 7)))	
				EndIf

				//Se tem item preenchido, formata com Zeros a Esquerda
				If Val(cItemPC) > 0 
					cItemPC := StrZero(val(cItemPC),4)
				Else
					cItemPC := ""	
				Endif  

				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_imposto:_ICMS") == "O"

					SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_imposto:_ICMS XMLSTRING cStrXml
					If At("<ICMS00>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
					EndIf
					If At("<ICMS10>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
					EndIf
					If At("<ICMS20>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
					EndIf
					If At("<ICMS30>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nPRedBCST  := Val(Substr(cStrXml, At("<pRedBCST>", cStrXml) + 10, At("</pRedBCST>", cStrXml) - (At("<pRedBCST>", cStrXml) + 10) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
					EndIf
					If (At("<ICMS40>", cStrXml) > 0).or. (At("<ICMS41>", cStrXml) > 0).or.(At("<ICMS50>", cStrXml) > 0)
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
					EndIf
					If At("<ICMS51>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nvICMSOp := Val(Substr(cStrXml, At("<vICMSOp>", cStrXml) + 9, At("</vICMSOp>", cStrXml) - (At("<vICMSOp>", cStrXml) + 9)))
						npDif := Val(Substr(cStrXml, At("<pDif>", cStrXml) + 6, At("</pDif>", cStrXml) - (At("<pDif>", cStrXml) + 6) ))
						nvICMSDif := Val(Substr(cStrXml, At("<vICMSDif>", cStrXml) + 10, At("</vICMSDif>", cStrXml) - (At("<vICMSDif>", cStrXml) + 10)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
					EndIf
					If At("<ICMS60>", cStrXml) > 0  .or. At("<ICMSST>", cStrXml) > 0  //Nova TAG
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
					
						nvBCSTRet := Val(Substr(cStrXml, At("<vBCSTDest>", cStrXml) + 11, At("</vBCSTDest>", cStrXml) - (At("<vBCSTDest>", cStrXml) + 11) ))
						nvICMSSTRet := Val(Substr(cStrXml, At("<vICMSSTDest>", cStrXml) + 13, At("</vICMSSTDest>", cStrXml) - (At("<vICMSSTDest>", cStrXml) + 13)))						
						
						//Se não Tiver St destino pebga o normal
						If nvBCSTRet == 0 .or. nvICMSSTRet == 0 
							nvBCSTRet := Val(Substr(cStrXml, At("<vBCSTRet>", cStrXml) + 10, At("</vBCSTRet>", cStrXml) - (At("<vBCSTRet>", cStrXml) + 10) ))
							nvICMSSTRet := Val(Substr(cStrXml, At("<vICMSSTRet>", cStrXml) + 12, At("</vICMSSTRet>", cStrXml) - (At("<vICMSSTRet>", cStrXml) + 12)))
						Endif 
						
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						//Spiller - Chamado 57063 
						If nvICMSSTRet <> 0 
							nBaseICST := nvBCSTRet
							nValICMST := nvICMSSTRet
							nPerICMST := Val(Substr(cStrXml, At("<pST>", cStrXml) + 5, At("</pST>", cStrXml) - (At("<pST>", cStrXml) + 5) )) 
							If nPerICMST == 0 .AND. nBaseICST > 0 
								nPerICMST := Round( (nValICMST / nBaseICST) *100 ,0)
							Endif	
						Else
							nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
							nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
							nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))  
							If nPerICMST == 0 .AND. nBaseICST > 0 
								nPerICMST := Round( (nValICMST / nBaseICST) *100 ,0)
							Endif	 
						Endif

					EndIf
					If At("<ICMS70>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nPRedBCST  := Val(Substr(cStrXml, At("<pRedBCST>", cStrXml) + 10, At("</pRedBCST>", cStrXml) - (At("<pRedBCST>", cStrXml) + 10) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
					EndIf
					If At("<ICMS90>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nPRedBCST  := Val(Substr(cStrXml, At("<pRedBCST>", cStrXml) + 10, At("</pRedBCST>", cStrXml) - (At("<pRedBCST>", cStrXml) + 10) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
					EndIf

				EndIf

				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_imposto:_IPI") == "O"

					SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_imposto:_IPI XMLSTRING cStrXml
					If AT("<IPITrib>",cStrXml) > 0
						nBaseIPI := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5)))
						nPerIPI  := Val(Substr(cStrXml, At("<pIPI>", cStrXml) + 6, At("</pIPI>", cStrXml) - (At("<pIPI>", cStrXml) + 6)))
						nValIPI  := Val(Substr(cStrXml, At("<vIPI>", cStrXml) + 6, At("</vIPI>", cStrXml) - (At("<vIPI>", cStrXml) + 6)))
					EndIf

				EndIf


				//Captura PIS 
				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_imposto:_PIS") == "O"

					SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_imposto:_PIS XMLSTRING cStrXml
					If AT("<PISAliq>",cStrXml) > 0
						nBasePIS := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5)))
						nPerPIS  := Val(Substr(cStrXml, At("<pPIS>", cStrXml) + 6, At("</pPIS>", cStrXml) - (At("<pPIS>", cStrXml) + 6)))
						nValPIS  := Val(Substr(cStrXml, At("<vPIS>", cStrXml) + 6, At("</vPIS>", cStrXml) - (At("<vPIS>", cStrXml) + 6)))
					EndIf

				EndIf

			    //Captura COFINS 
				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_imposto:_COFINS") == "O"

					SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_imposto:_COFINS XMLSTRING cStrXml
					If AT("<COFINSAliq>",cStrXml) > 0
						nBasCOFINS   := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5)))
						nPerCOFINS   := Val(Substr(cStrXml, At("<pCOFINS>", cStrXml) + 9, At("</pCOFINS>", cStrXml) - (At("<pCOFINS>", cStrXml) + 9)))
						nValCOFINS   := Val(Substr(cStrXml, At("<vCOFINS>", cStrXml) + 9, At("</vCOFINS>", cStrXml) - (At("<vCOFINS>", cStrXml) + 9)))
					EndIf

				EndIf
				
                
				IF EMPTY(cPedido)
					cPedido := ' '
				ENDIF
				AADD(aItens,{oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_cProd:Text,;
							 Substr(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_xProd:Text,1,55),;
							 oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_qCom:Text,;
							 oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_uCom:Text,;
							 oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vProd:Text,;
							 oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vUnCom:Text,;
							 cPedido,;
							 cItemPC,;
							 cStTrib,;
							 nBaseICM,;
							 nPerICM,;
							 nValICM,;
							 nBaseIPI,;
							 nPerIPI,;
							 nValIPI,;
							 nPmVast,;
							 nPRedBCST,;
							 nBaseICST,;
							 nPerICMST,;
							 nValICMST,;
							 nvICMSDeson,;
							 nBasePIS,;  
							 nPerPIS,; 
							 nValPIS,; 
							 nBasCOFINS,; 
							 nPerCOFINS,; 
							 nValCOFINS,;
							 nVdesc;
							}) 

							//nvBCSTRet := Val(Substr(cStrXml, At("<vBCSTRet>", cStrXml) + 10, At("</vBCSTRet>", cStrXml) - (At("<vBCSTRet>", cStrXml) + 10) ))
							//nvICMSSTRet

			Next nX1 // [][7]

		EndIf

		dbSelectArea("SA2")
		SA2->( dbSetOrder(1) )
		If SA2->( dBSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

			cDescFor := SA2->A2_COD + " - " + SA2->A2_NOME
			cFornece := SA2->A2_COD
			cLoja	 := SA2->A2_LOJA
			cNaturez := SA2->A2_NATUREZ
			cEstado  := SA2->A2_EST
			cConPgto := SA2->A2_COND
			nUsado := 0
	
			_aCampoSX3 := U_XAGSX3(_cTab2)

			For _nX := 1 To Len(_aCampoSX3)
				nUsado++
				_cCampoSX3 := _aCampoSX3[_nX]

				If (_cCampoSX3 <> _cCmp2+"_FILIAL")
					AADD(aHeader, {Trim(GetSX3Cache(_cCampoSX3, "X3_TITULO")),;
								   _cCampoSX3,;
								   GetSX3Cache(_cCampoSX3, "X3_PICTURE"),;
								   GetSX3Cache(_cCampoSX3, "X3_TAMANHO"),;
								   GetSX3Cache(_cCampoSX3, "X3_DECIMAL"),;
								   GetSX3Cache(_cCampoSX3, "X3_VALID"),;
								   GetSX3Cache(_cCampoSX3, "X3_USADO"),;
								   GetSX3Cache(_cCampoSX3, "X3_TIPO"),;
								   GetSX3Cache(_cCampoSX3, "X3_F3"),;
								   GetSX3Cache(_cCampoSX3, "X3_CONTEXT") })
				EndIf
			End

			//if lPreNota
			//	AADD(aAlter, _cCmp2+"_COD")
			//	AADD(aAlter, _cCmp2+"_QUANT2")
			//	AADD(aAlter, _cCmp2+"_CC")
			//	AADD(aAlter, _cCmp2+"_CONTA")
			//	AADD(aAlter, _cCmp2+"_PEDIDO")
			//	AADD(aAlter, _cCmp2+"_ITEMPC")
			//else	 
				AADD(aAlter, _cCmp2+"_COD")
				AADD(aAlter, _cCmp2+"_QUANT2")
				AADD(aAlter, _cCmp2+"_TES")
				AADD(aAlter, _cCmp2+"_CF")
				AADD(aAlter, _cCmp2+"_CLASFI")
				AADD(aAlter, _cCmp2+"_CC")
				AADD(aAlter, _cCmp2+"_CONTA")
				AADD(aAlter, _cCmp2+"_PEDIDO")
				AADD(aAlter, _cCmp2+"_ITEMPC")
				AADD(aAlter, _cCmp2+"_OPER")
			//endif

			//Permitir alteração dos Campos de ICMS ST
			AADD(aAlter, _cCmp2+"_BRICMS")
			AADD(aAlter, _cCmp2+"_ALICST")
			AADD(aAlter, _cCmp2+"_ICMRET")
			
			aCols := Array(Len(aItens), nUsado+1)
			For nY := 1 to Len(aItens)

				For nX := 1 To nUsado
					aCols[nY,nX] := CriaVar(aHeader[nX,2])
				Next nX

				aCols[nY,1]  := PADR(aItens[nY,1], 15, " ") + " - " + Substr(aItens[nY,2], 1, 30)
				aCols[nY,2]  := aItens[nY,7]
				aCols[nY,3]  := aItens[nY,8]
				aCols[nY,4]  := Space(TamSX3("B1_COD")[1])
				aCols[nY,5]  := Space(TamSX3("B1_DESC")[1])
				aCols[nY,6]  := aItens[nY,4]
				aCols[nY,7]  := Round(Val(aItens[nY,3]), nDecQtd) // Quantidade Xml
				aCols[nY,8]  := Round(Val(aItens[nY,3]), nDecQtd) // Quantidade informada
				aCols[nY,9]  := Round(Val(aItens[nY,6]), nDecVal) // Valor Unitário
				aCols[nY,10] := Round(Val(aItens[nY,5]), nDecTot) // Valor do produto
				aCols[nY,13] := aItens[nY,10]
				aCols[nY,14] := aItens[nY,11]
				aCols[nY,15] := aItens[nY,12]
				aCols[nY,16] := aItens[nY,13]
				aCols[nY,17] := aItens[nY,14]
				aCols[nY,18] := aItens[nY,15]
				aCols[nY,19] := aItens[nY,9]
				aCols[nY,24] := aItens[nY,18]
				aCols[nY,25] := aItens[nY,19]
				aCols[nY,26] := aItens[nY,20]//aItens[nY,19]
				aCols[nY,27] := ""//aItens[nY,21]//aItens[nY,20] // TAVA GRAVANDO DESON NO TP OPER
				aCols[nY,28] := aItens[nY,22]//nBasePIS,;
				aCols[nY,29] := aItens[nY,23]//nPerPIS,;
				aCols[nY,30] := aItens[nY,24]//nValPIS,;
				aCols[nY,31] := aItens[nY,25]//nBasCOFINS,;
				aCols[nY,32] := aItens[nY,26]//nPerCOFINS,;
				aCols[nY,33] := aItens[nY,27]//nValCOFINS,;
				aCols[nY,34] := aItens[nY,28]//nValdesc,;
				
				aCols[nY, nUsado + 1] := .F.

				dbSelectArea("SA5")
				SA5->( dbSetOrder(5) )
				SA5->( dbSeek(xFilial("SA5") + AllTrim(aItens[nY,1])) )
				While SA5->(!Eof()) .AND. SA5->A5_FILIAL == xFilial("SA5") .And. AllTrim(SA5->A5_CODPRF) == AllTrim(aItens[nY,1])

					If SA5->A5_FORNECE == SA2->A2_COD .And. SA5->A5_LOJA == SA2->A2_LOJA

						lProdForn := .T.
						aCols[nY, 4]  := SA5->A5_PRODUTO
						aCols[nY, 5]  := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_DESC")
						aCols[nY, 6]  := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_UM")
						aCols[nY, 11] := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_TE")

						If !Empty(aCols[nY, 11])
							aCols[nY, 12] := IIf(GETMV("MV_ESTADO") == cEstado,"1","2") + Substr(Posicione("SF4", 1, xFilial("SF4") + aCols[nY,11], "F4_CF"), 2, 3)
						EndIf

						//Bloqueio por tipo de produtos
						DbSelectarea('SB1')
						Dbsetorder(1)
						If Dbseek(xFilial('SB1') + alltrim(aCols[nY, 4]))
							If alltrim(SB1->B1_TIPO)  $ 'SH/PA/LU/QR/AE' 
								cProdBloq +=  SB1->B1_COD +'-' +alltrim(SB1->B1_DESC) +chr(10)  
							Endif
						Endif
						Exit
					EndIf

					SA5->( dbSkip() )
				Enddo
			Next nY

			If Alltrim(cProdBloq) <> ''
				Alert('Para produtos do Tipo SH,PA,LU,QR e AE você deve utilizar o Importador NOVO:  '+chr(10) +cProdBloq )
				Return
			Endif 


			DEFINE MSDIALOG oDlgItens FROM aSize[7],0 TO aSize[6],aSize[5] TITLE 'Importador NFE' STYLE DS_MODALFRAME PIXEL
				oDlgItens:lEscClose := .F.

				oLayerImp := FWLayer():New()
				oLayerImp:Init(oDlgItens, .F.)
				oLayerImp:AddLine('TOP', 25, .F.)
				oLayerImp:AddCollumn('COL_TOP', 100, .T., 'TOP')
				oLayerImp:AddWindow('COL_TOP', 'WIN_TOP', "Dados da Nota Fiscal", 100, .F., .T.,, 'TOP',)

				@009,030 SAY "Arquivo: "      SIZE 235,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
			  	@007,060 MSGET (_cTab1)->&(_cCmp1+"_ARQUIV") SIZE 175,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN .F.
				@009,292 SAY "Nat.Oper.:"	  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
			  	@007,325 MSGET (_cTab1)->&(_cCmp1+"_NATOP")  SIZE 127,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN .F.


				@021,020 SAY "Documento: "	  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
			  	@019,060 MSGET (_cTab1)->&(_cCmp1+"_DOC")    SIZE 045,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN .F.
				@021,120 SAY "Série:"		  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
			  	@019,142 MSGET (_cTab1)->&(_cCmp1+"_SERIE")  SIZE 010,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN .F.
				@021,170 SAY "Data Emissão:"  SIZE 065,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
			  	@019,215 MSGET dDtEmis        SIZE 040,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN .F.
				@021,292 SAY "Natureza:"	  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
		  		@019,325 MSGET cNaturez		  SIZE 040,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN !lPreNota F3 "SED" VALID Iif(!Empty(cNaturez),ExistCPO("SED"),.T.) PICTURE "@!" HasButton
				@021,390 SAY "Cond.Pagto.:"	  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
		  		@019,430 MSGET cConPgto		  SIZE 020,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN !lPreNota F3 "SE4" VALID Iif(!Empty(cConPgto),ExistCPO("SE4"),.T.) PICTURE "@!" HasButton
				@021,470 SAY "Historico:"	  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
		  		@019,510 MSGET _cHistor		  SIZE 150,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN !lPreNota PICTURE "@!" HasButton

				@033,020 SAY "Fornecedor:"	  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
			  	@031,060 MSGET cDescFor		  SIZE 150,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN .F.
				@033,220 SAY "Loja:"		  SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
			  	@031,240 MSGET cLoja		  SIZE 015,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN .F.

				@033,292 SAY "Prev.Vencto:"   SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
		  		@031,325 MSGET dDtVcto		  SIZE 040,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')When !lPreNota  
				@033,390 SAY "Validador:"     SIZE 035,008 FONT oFont2 COLOR CLR_BLUE PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP')
		  		@031,430 MSGET cValidad		  SIZE 150,009 PIXEL OF oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP') WHEN !lPreNota PICTURE "@!" HasButton


				oLayerImp:AddLine('CENTER', 70, .F.)
				oLayerImp:AddCollumn('COL_CENTER', 100, .T., 'CENTER')
				oLayerImp:AddWindow('COL_CENTER', 'WIN_CENTER', "Itens da Nota Fiscal a ser importada", 100, .F., .T.,, 'CENTER',)

				oGetD := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAlter, 000, 999, NIL, NIL, "AlwaysFalse", oLayerImp:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'), aHeader, aCols)
				oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

				oLayerImp:AddLine('BOTTOM', 5, .F.)
				oLayerImp:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')

				oPanelBot := tPanel():New(0, 0, "", oLayerImp:GetColPanel('COL_BOTTOM', 'BOTTOM'),,,,, RGB(239,243,247), 000, 015)
				oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT

				oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgItens:End()}, , ,)
				oQuit:nWidth  := 80
				oQuit:nHeight := 10
				oQuit:Align   := CONTROL_ALIGN_RIGHT
				oQuit:SetColor(RGB(002,070,112),)

				oImp := THButton():New(0, 0, "Importar", oPanelBot, {|| lConfirm := .T., IIf((MsAguarde({|| lImport := ImpXMLNFe(@lConfirm)}, "Importando XML da Nota Fiscal..."), lImport), oDlgItens:End(), .F.)}, , ,)
				oImp:nWidth  := 80
				oImp:nHeight := 10
				oImp:Align := CONTROL_ALIGN_RIGHT
				oImp:SetColor(RGB(002,070,112),)

				oPedCom := THButton():New(0, 0, "Ped. Compra", oPanelBot, {|| ConsPed()},,,)
				oPedCom:nWidth  := 120
				oPedCom:nHeight := 10
				oPedCom:Align   := CONTROL_ALIGN_RIGHT
				oPedCom:SetColor(RGB(002,070,112),)

			ACTIVATE MSDIALOG oDlgItens CENTERED ON INIT VALPC()

		Else
			MsgStop("Fornecedor não encontrado para o CNPJ:" + (_cTab1)->&(_cCmp1+"_CGCEMI"), "Aviso")
			Break
		EndIf

	End Sequence

	If (Select("SA2") > 0)
		SA2->(DbCloseArea())
	EndIf

	If (Select("SA5") > 0)
		SA5->(DbCloseArea())
	EndIf

	AtuBrowse()

//Leandro Spiller
//Retira F4
SetKey( VK_F4,			{ || NIL } )    

Return(.T.)

/////////////////////////////////////////////
// Função de importação dos CTe
Static Function ImportarCTe()
Local oXml
Local aRet
Local nI
Local aCab
Local aNotas
Local aNotasAux := {}
Local aFatura   := {}
Local aTitulos  := {}
Local nRecno  := (_cTab1)->(Recno())
Local aAreaSF1  := (_cTab1)->(GetArea())
Local nRegs		:= 0
Local aErros   := {}
Local cError   := ""
Local cWarning := ""
Local cFornCTe := ""
Local cLojaCTe := ""
Local nPosTes, nPosCon, nPosEsp, nPosNat

Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.

lMarcCte := .T.

If Empty(cEspCte)
	MsgStop("Espécie do Conhecimento deve ser informada!", "Aviso")
	Return .F.
EndIf

If Empty(cTESCte)
	MsgStop("Deve ser informado um TES válido!", "Aviso")
	Return .F.
EndIf

// Chamado 72549 - Obrigar CC quando conta Exigir           
If Empty(cCCCte)      
	_cconta := Posicione('SB1',1,xfilial('SB1')+GETNEWPAR("MV_XSMSPRO","DES52111102"),'B1_CONTA')
	If Posicione('CT1',1,xfilial('CT1')+_cConta,'CT1_CCOBRG') == '1'  
		MsgStop("Deve ser informado um CC válido!", "Aviso")
		Return .F.
	Endif
EndIf

If Empty(cCondCte)
	MsgStop("Deve ser informada uma condição de pagamento válida!", "Aviso")
	Return .F.
EndIf

If Empty(cNatCte)
	MsgStop("Deve ser informada uma natureza fiscal válida.", "Aviso")
	Return .F.
EndIf

If MsgYesNo(STR0021,STR0022) //-- Confirma a geração de documento para os itens selecionados? # Atenção
	(_cTab1)->(dbEval({|| nRegs++},{|| &(_cCmp1+"_OKCTE") == cMarca}))
	(_cTab1)->(dbGoTop())
	Processa({|| u_ProcDocs(nRegs),"Importação de XML" +" - " +STR0023}) //-- Monitor TOTVS Colaboração # Geração de Documentos
	(_cTab1)->(dbGoTo(nRecno))
EndIf

RestArea(aAreaSF1)

Return



///////////////////////////////////////////

Static Function ImportarCCe()

	Local aAreaSZW := (_cTab1)->( GetArea() )
	Local aAreaSF1 := SF1->( GetArea() )
	Local cTpDoc
	Local cSitDoc
	Local cErro
	Local lErro := .F.
	Local oXml
	Local cError := ""
	Local cWarning := ""
	Local cCahveE := (_cTab1)->&(_cCmp1+"_CHAVE")
	Local cFim
	Local lConfirm := .F.
	Local cXml := (_cTab1)->&(_cCmp1+"_XML")
	Local cSeq

	If (lConfirm := MsgYesNo("Confirma a importação da Carta de Correção?", "Carta de Correção"))

		CursorWait()

		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		If (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "1") + (cSitDoc := "2")) ) .Or. (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "2") + (cSitDoc := "2")) ) .Or.;
		   (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "1") + (cSitDoc := "1")) ) .Or. (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "1") + (cSitDoc := "3")) ) .Or.;
		   (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "2") + (cSitDoc := "1")) ) .Or. (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "2") + (cSitDoc := "3")) ) .Or.;
		   (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "1") + (cSitDoc := "5")) ) .Or. (_cTab1)->( dbSeek(cCahveE + (cTpDoc := "2") + (cSitDoc := "5")) )

			If cSitDoc $ "1;3"

				cErro := "- Foi encontrado Documento de Entrada ainda não importado (Seq Import: " + AllTrim((_cTab1)->&(_cCmp1+"_SEQIMP")) + ") para a carta de correção. Primeiro importe o Documento de Entrada para depois processar a Carta de Correção."
				lErro := .T.

			ElseIf cSitDoc == "5"

				cErro := "- O Documento de Entrada desta Carta de Correção já foi cancelado, portanto, não poderá ser importado."
				lErro := .T.

			ElseIf cSitDoc == "2"

				oXml := XmlParser(cXml, "_", @cError, @cWarning)

				dbSelectArea("SF1")
				SF1->( dbSetOrder(1) )
				If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

					cSeq := StrZero(1, TamSX3(_cCmp3+"_SEQ")[1])

					dbSelectArea(_cTab3)
					(_cTab3)->( dbSetOrder(1) )
					(_cTab3)->( dbSeek(xFilial(_cTab3) + "1" + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + "zzz", .T.) )

					(_cTab3)->( dbSkip(-1) )

					If (_cTab3)->&(_cCmp3+"_FILIAL") == xFilial(_cTab3) .And. (_cTab3)->&(_cCmp3+"DOC") == SF1->F1_DOC .And. (_cTab3)->&(_cCmp3+"SERIE") == SF1->F1_SERIE .And.;
					   (_cTab3)->&(_cCmp3+"FORNEC") == SF1->F1_FORNECE .And. (_cTab3)->&(_cCmp3+"LOJA") == SF1->F1_LOJA

						cSeq := StrZero(Val((_cTab3)->&(_cCmp3+"SEQ")) + 1, TamSX3(_cCmp3+"_SEQ")[1])

					EndIf

					RecLock(_cTab3, .T.)
						(_cTab3)->&(_cCmp3+"_FILIAL") := xFilial(_cTab3)
						(_cTab3)->&(_cCmp3+"_SEQ")    := cSeq
						(_cTab3)->&(_cCmp3+"_TIPO")   := "1"
						(_cTab3)->&(_cCmp3+"_DOC")    := SF1->F1_DOC
						(_cTab3)->&(_cCmp3+"_SERIE")  := SF1->F1_SERIE
						(_cTab3)->&(_cCmp3+"_FORNEC") := SF1->F1_FORNECE
						(_cTab3)->&(_cCmp3+"_LOJA")   := SF1->F1_LOJA
						(_cTab3)->&(_cCmp3+"_DSEVTO") := oXml:_procEventoNFe:_evento:_infEvento:_detEvento:_descEvento:Text
						(_cTab3)->&(_cCmp3+"_CORREC") := oXml:_procEventoNFe:_evento:_infEvento:_detEvento:_xCorrecao:Text
						(_cTab3)->&(_cCmp3+"_CONUSO") := oXml:_procEventoNFe:_evento:_infEvento:_detEvento:_xCondUso:Text
						(_cTab3)->&(_cCmp3+"_DTEVTO") := SToD(StrTran(Substr(oXml:_procEventoNFe:_evento:_infEvento:_dhEvento:Text,1,10), "-", ""))
						(_cTab3)->&(_cCmp3+"_TCRIA")  := dDataBase
						(_cTab3)->&(_cCmp3+"_HRCRIA") := Time()
						(_cTab3)->&(_cCmp3+"_USUCRI") := cUserName
					(_cTab3)->( MSUnlock() )


				EndIf

			EndIf

		Else

			cErro := "- Não foi encontrado Documento de Entrada com a chave eletrônica " + cCahveE + " informada no Xml. Documento de Entrada pode ainda não ter sido atualizado."
			lErro := .T.

		EndIf

		RestArea(aAreaSZW)

		If lErro

			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1+"_SIT")  := "3"
				(_cTab1)->&(_cCmp1+"_ERRO") := cErro
			(_cTab1)->( MSUnlock() )

		Else

			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1+"_DOC")    := SF1->F1_DOC
				(_cTab1)->&(_cCmp1+"_SERIE")  := SF1->F1_SERIE
				(_cTab1)->&(_cCmp1+"_CODEMI") := SF1->F1_FORNECE
				(_cTab1)->&(_cCmp1+"_LOJEMI") := SF1->F1_LOJA
				(_cTab1)->&(_cCmp1+"_SIT")    := "2"
				(_cTab1)->&(_cCmp1+"_ERRO")   := ""
				(_cTab1)->&(_cCmp1+"_DTIMP")  := dDataBase
				(_cTab1)->&(_cCmp1+"_HRIMP")  := Time()
				(_cTab1)->&(_cCmp1+"_USUIMP") := cUserName
			(_cTab1)->( MSUnlock() )

			MsgInfo("Carta de Correção importada com sucesso.")

		EndIf

		RestArea(aAreaSF1)

	EndIf

	CursorArrow()
	If lConfirm .And. lErro
		MsgStop("Ocorreram erros na importação da Carta de Correção.", "Carta de Correção")
		ExibeErro()
	EndIf

	AtuBrowse()

Return



///////////////////////////////////////////

Static Function ImportarCan()

	Local aCabec
	Local aItens   := {}
	Local aAreaSF1 := SF1->( GetArea() )
	Local aAreaSZW := (_cTab1)->( GetArea() )
	Local cChave
	Local lConfirm := .T.

	//Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

	If (_cTab1)->&(_cCmp1+"_TPCAN") == "N"

		//If Aviso("Cancelamento de Nota Fiscal", "Confirma o cancelamento da Nota Fical de número: " + ALlTrim((_cTab1)->&(_cCmp1+"_DOC")) + " e série: " + AllTrim((_cTab1)->&(_cCmp1+"_SERIE")) + "?", {"Confirmar", "Cancelar"}, 2) == 1

			cChave := (_cTab1)->&(_cCmp1+"_CHAVE")

			dbSelectArea("SF1")
			SF1->( dbSetOrder(1) )
			If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

				aCabec := {{"F1_DOC"	, SF1->F1_DOC    , Nil, Nil},;
				           {"F1_SERIE"  , SF1->F1_SERIE  , Nil, Nil},;
				           {"F1_FORNECE", SF1->F1_FORNECE, Nil, Nil},;
				           {"F1_LOJA"   , SF1->F1_LOJA   , Nil, Nil},;
				           {"F1_COND"   , SF1->F1_COND   , Nil, Nil},;
				           {"F1_EMISSAO", SF1->F1_EMISSAO, Nil, Nil},;
				           {"F1_DTDIGIT", SF1->F1_DTDIGIT, Nil, Nil},;
				           {"F1_EST"    , SF1->F1_EST    , Nil, Nil},;
				           {"F1_TIPO"   , SF1->F1_TIPO   , Nil, Nil},;
				           {"F1_ESPECIE", SF1->F1_ESPECIE, Nil, Nil},;
				           {"F1_FORMUL" , SF1->F1_FORMUL , Nil, Nil},;
				           {"F1_CHVNFE" , SF1->F1_CHVNFE , Nil, Nil};
						  }

				dbSelectArea("SD1")
				SD1->( dbSetOrder(1) )
				SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
				While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
					  SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA

					AAdd(aItens, {{"D1_ITEM"	, SD1->D1_ITEM   , Nil},;
								  {"D1_COD"     , SD1->D1_COD    , Nil},;
			    				  {"D1_UM"      , SD1->D1_UM     , Nil},;
					              {"D1_QUANT"   , SD1->D1_QUANT  , Nil},;
					              {"D1_VUNIT"   , SD1->D1_VUNIT  , Nil},;
				    	          {"D1_TOTAL"   , SD1->D1_TOTAL  , Nil},;
				    	          {"D1_TES"     , SD1->D1_TES    , Nil},;
				    	          {"D1_TIPO"    , SD1->D1_TIPO   , Nil},;
				    	          {"D1_SERIE"   , SD1->D1_SERIE  , Nil},;
				    	          {"D1_BASEICM" , SD1->D1_BASEICM, Nil},;
				    	          {"D1_PICM"    , SD1->D1_PICM	 , Nil},;
				    	          {"D1_VALICM"  , SD1->D1_VALICM , Nil},;
				    	          {"D1_BASEIPI" , SD1->D1_BASEIPI, Nil},;
				    	          {"D1_IPI"     , SD1->D1_IPI	 , Nil},;
				    	          {"D1_VALIPI"  , SD1->D1_VALIPI , Nil},;
				    	          {"D1_CLASFIS" , SD1->D1_CLASFIS, Nil},;
				    	          {"D1_CONTA"  	, SD1->D1_CONTA  , Nil},;
				    	          {"D1_CC" 		, SD1->D1_CC	 , Nil},;
				    	          {"D1_VENCPRV"	, SD1->D1_VENCPRV, Nil},;
				    	          {"D1_VLDDPRV"	, SD1->D1_VLDDPRV, Nil},;
				    	          {"D1_BRICMS"	, SD1->D1_BRICMS , Nil},;
				    	          {"D1_ICMSRET"	, SD1->D1_ICMSRET, Nil},;
								  {"D1_ORIIMP"   , "SMS001"	     , Nil},;  
				    	          {"AUTDELETA"  , "N"            , Nil};
				    	    	 })

					SD1->( dbSkip() )

				EndDo

				Begin Transaction

					dbSelectArea("SF1")
					SF1->( dbSetOrder(1) )
					If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

						If Empty(SF1->F1_STATUS)

							MsAguarde({|| MsExecAuto({|x,y,z,w,k| MATA140(x,y,z,w,k)}, aCabec, aItens, 5, .F., 1)}, "Cancelamento de Pré-Nota de Entrada", "Carregando visualização da Nota Fiscal...")

						Else

							MsAguarde({|| MsExecAuto({|x,y,z,w| MATA103(x,y,z,w)}, aCabec, aItens, 5, lConfere)}, "Cancelamento de Nota Fiscal", "Carregando visualização da Nota Fiscal...")

						EndIf

					EndIf

					dbSelectArea("SF1")
					SF1->( dbSetOrder(1) )
					If !lMsErroAuto .And. SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

						lConfirm := .F.

					Else

					    If lMsErroAuto

					    	DisarmTransaction()

				      		RecLock(_cTab1, .F.)

								(_cTab1)->&(_cCmp1+"_SIT")  := "3"
								(_cTab1)->&(_cCmp1+"_ERRO") := MontaErro(GetAutoGrLog())

							(_cTab1)->( MSUnlock() )

				      		ExibeErro()

						Else

							RecLock(_cTab1, .F.)

								(_cTab1)->&(_cCmp1+"_SIT")  := "2"
								(_cTab1)->&(_cCmp1+"_ERRO") := ""

							(_cTab1)->( MSUnlock() )

							dbSelectArea(_cTab1)
							(_cTab1)->( dbSetOrder(1) )
							If (_cTab1)->( dbSeek(cChave + "1") )
								SetStatusXML("NFE", "5")
							EndIf

							RestArea(aAreaSZW)
							MsgInfo("Cancelamento realizado sucesso!", "Aviso")

						EndIf
					EndIf

				End Transaction

			Else
				MsgInfo("Nota Fiscal não encontrada, é possível que outro processo tenha eliminado a Nota Fiscal.", "Aviso")
			EndIf

		//EndIf

	ElseIf (_cTab1)->&(_cCmp1+"_TPCAN") == "C"

		If Aviso("Cancelamento de Conhecimento de Transporte", "Confirma o cancelamento do Conhecimento de Transporte de número: " + ALlTrim((_cTab1)->&(_cCmp1+"_DOC")) + " e série: " + AllTrim((_cTab1)->&(_cCmp1+"_SERIE")) + "?", {"Confirmar", "Cancelar"}, 2) == 1

			cChave := (_cTab1)->&(_cCmp1+"_CHAVE")
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek(cChave + "2") )

				dbSelectArea("SF1")
				SF1->( dbSetOrder(1) )
				If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI") + "C") )

					aCabec := {}
					aAdd(aCabec, {"MV_PAR11"  , dDataBase-90})
					aAdd(aCabec, {"MV_PAR12"  , dDataBase})
					aAdd(aCabec, {"MV_PAR13"  , 1})
					aAdd(aCabec, {"MV_PAR14"  , SF1->F1_FORNECE})
					aAdd(aCabec, {"MV_PAR15"  , SF1->F1_LOJA})
					aAdd(aCabec, {"MV_PAR16"  , 1})
					aAdd(aCabec, {"MV_PAR17"  , 1})
					aAdd(aCabec, {"MV_PAR18"  , SF1->F1_EST})
					aAdd(aCabec, {"MV_PAR21"  , (_cTab1)->&(_cCmp1+"_TOTVAL")})
					aAdd(aCabec, {"MV_PAR22"  , 1})
					aAdd(aCabec, {"MV_PAR23"  , SF1->F1_DOC})
					aAdd(aCabec, {"MV_PAR24"  , SF1->F1_SERIE})
					aAdd(aCabec, {"MV_PAR25"  , SF1->F1_FORNECE})
					aAdd(aCabec, {"MV_PAR26"  , SF1->F1_LOJA})
					aAdd(aCabec, {"MV_PAR27"  , (_cTab1)->&(_cCmp1+"_TES")})
					aAdd(aCabec, {"MV_PAR28"  , 0})
					aAdd(aCabec, {"MV_PAR29"  , 0})
					aAdd(aCabec, {"MV_PAR31"  , (_cTab1)->&(_cCmp1+"_CONDPG")})
					aAdd(aCabec, {"Emissao"   , (_cTab1)->&(_cCmp1+"_DTEMIS")})
					aAdd(aCabec, {"F1_ESPECIE", (_cTab1)->&(_cCmp1+"_ESPECI")})
					aAdd(aCabec, {"Natureza"  , (_cTab1)->&(_cCmp1+"_NATFIN")})

				EndIf

				dbSelectArea("SF8")
				SF8->( dbSetOrder(3) )
				SF8->( dbSeek(xFilial("SF8") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
				While !SF8->( Eof() ) .And. SF8->F8_FILIAL == xFilial("SF8") .And. SF8->F8_NFDIFRE == SF1->F1_DOC .And. SF8->F8_SEDIFRE == SF1->F1_SERIE .And. ;
					  SF8->F8_TRANSP == SF1->F1_FORNECE .And. SF8->F8_LOJTRAN == SF1->F1_LOJA

					aItens := {}

					aAdd(aItens, {{"PRIMARYKEY", F8_NFDIFRE + F8_SEDIFRE + F8_FORNECE + F8_LOJA}})
					SF8->( dbSkip() )

				EndDo

			EndIf

			RestArea(aAreaSZW)

			Begin Transaction

				MsAguarde({|| MSExecAuto({|x,y| MATA116(x, y)}, aCabec, aItens)}, "Cancelamento de Conhecimento de Transporte", "Executando processo de cancelamento...")

				If lMsErroAuto

			    	DisarmTransaction()

		      		RecLock(_cTab1, .F.)

						(_cTab1)->&(_cCmp1+"_SIT")  := "3"
						(_cTab1)->&(_cCmp1+"_ERRO") := MontaErro(GetAutoGrLog())

					(_cTab1)->( MSUnlock() )

		      		ExibeErro()

				Else

					RecLock(_cTab1, .F.)

						(_cTab1)->&(_cCmp1+"_SIT")  := "2"
						(_cTab1)->&(_cCmp1+"_ERRO") := ""

					(_cTab1)->( MSUnlock() )

					dbSelectArea(_cTab1)
					(_cTab1)->( dbSetOrder(1) )
					If (_cTab1)->( dbSeek(cChave + "2") )
						SetStatusXML("CTE", "5")
					EndIf

					RestArea(aAreaSZW)
					MsgInfo("Cancelamento realizado sucesso!", "Aviso")

				EndIf

			End Transaction

		Else
			lConfirm := .F.
		EndIf
	EndIf

	RestArea(aAreaSF1)
	AtuBrowse()

Return



///////////////////////////////////////////
// Importação do arquivo XML

Static Function ImpXMLNFe(lConfirm)
Local cEst    := Posicione("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_EST")
Local cTipo   := cCombo1
Local aCabec  := {}
Local aItemPC := {}
Local aProj   := {}
Local lRet    := .T.
Local cNPed   := ""
Local aPrj    := {}
Local _lPedC  := .T.	
Local lSMSPRJ := ExistBlock("SMSPRJ")
Local nPMSIPC := GetMv("MV_PMSIPC")
Local nX := 0
local lVldPc	:= GetMv("MV_XSMS009")
local nBasIcmsST := 0
local nValIcmsST := 0
local _cConta    := ""

Local nPosCST    := aScan(aHeader,{|x|Alltrim(x[2])==_cTab2+"_CLASFI"})
Local nPosPrd   := aScan(aHeader,{|x|Alltrim(x[2])==_cTab2+"_COD"})
Local nPosTes    := aScan(aHeader,{|x|Alltrim(x[2])==_cTab2+"_TES"})
Local nICMNDES   := aScan(aHeader,{|x|Alltrim(x[2])==_cTab2+"_ICMRET" })
Local nBASNDES   := aScan(aHeader,{|x|Alltrim(x[2])==_cTab2+"_BRICMS" })
Local nALQNDES   := aScan(aHeader,{|x|Alltrim(x[2])==_cTab2+"_ALICST" })

Local nBasCalc   := 0
Local nAlqCalc   := 0
Local nValorCalc := 0
							
Private lMsHelpAuto    := .F.
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.

	if !lPreNota 
		If Empty(cNaturez)
			MsgStop("Natureza Financeira deve ser informada!","Aviso")
			Return .F.
		EndIf
	
		If Empty(cConPgto)
			MsgStop("Condição de Pagamento deve ser informada!","Aviso")
			Return .F.
		EndIf
	endif

	For nX := 1 To Len(oGetD:aCols)

		//Obrigação de Preenchimento dos campos da ST para Atacado
		If !lPreNota .AND. cEmpAnt $ '01/11/15' //.AND. cFilant == '06' 
			IF Substr(alltrim(oGetD:aCols[nX][nPosCST]),2,2)  $ '10/30/60/70' .AND. alltrim(oGetD:aCols[nX][nPosTes]) <> '' .AND. cTipo  <> 'D'
				
				If oGetD:aCols[nX][nICMNDES] == 0 .OR. oGetD:aCols[nX][nBASNDES] == 0 .OR. oGetD:aCols[nX][nALQNDES] == 0 
					MSGinfo('Produto:['+alltrim(oGetD:aCols[nX][nPosPrd]) +']: Verificar os valores das tags <vBCSTRet>/<vICMSSTRet>/<pST>'+;
					' para preenchimento dos campos Base Ret ICM / Vlr ICMS Sol  / Aliq. ICMS S (D1_BASNDES/D1_ICMNDES/D1_ALQNDES)','Preencher os campos de ST')
					Return .F.
				Endif

			Endif 
		Endif 

		// Valida o Pedido de Compra 
		if lVldPc
			If !Empty(oGetD:aCols[nX,2])
				dbSelectArea("SC7")
				SC7->( dbSetOrder(1) )
				If !SC7->(dbSeek(xFilial("SC7") + oGetD:aCols[nX,2] + oGetD:aCols[nX,3])) .and. !SC7->(dbSeek(xFilial("SC7") + oGetD:aCols[nX,2] + StrZero(val(oGetD:aCols[nX,3]),4) ))
					MsgStop("Número do Pedido de Compra informado no item " + oGetD:aCols[nX,2] + " / " + StrZero(nX,4) + " não foi encontrado.","Aviso")
					_lPedC := .F.
					Return .F.
				ElseIf SC7->C7_FORNECE # cFornece /*.Or. SC7->C7_LOJA # cLoja*/
					MsgStop("Pedido de Compra informado no item " + StrZero(nX, 4) + " não pertence ao fornecedor selecionado!", "Aviso")
					_lPedC := .F.
					Return .F.
				EndIf
			Else
				cNPed += cValToChar(nX) + ", "
			EndIf
		endif
		// Demais validações
		If Empty(oGetD:aCols[nX,4])
			MsgStop("Código do produto deve ser informado!", "Aviso")
			Return .F.
		EndIf

		If Empty(oGetD:aCols[nX,8])
			MsgStop("Quantidade do produto deve ser informado!", "Aviso")
			Return .F.
		EndIf

		if !lPreNota 
			If Empty(oGetD:aCols[nX,11])
				MsgStop("Código da TES deve ser informado!", "Aviso")
				Return .F.
			EndIf
		endif
	Next nX

	If !Empty(cNPed) .And. Aviso("Pedido de Compra", "Não foi(ram) informado(s) Pedido(s) de Compra para o(s) produto(s) na(s) linha(s): " + SubStr(cNPed, 1, Len(cNPed) - 2) + ". Deseja continuar com a importação?", {"Continuar", "Cancelar"}, 2) # 1
		_lPedC := .F.
		Return .F.
	EndIf

	For nX := 1 To Len(oGetD:aCols)

		If lSMSPRJ

			aPrj := ExecBlock("SMSPRJ",.F.,.F., {oGetD:aCols, nX})
			If ValType(aPrj) == "A" .And. !Empty(aPrj)
				AAdd(aProj, aPrj)
			EndIf

		EndIf
		
		//Se não tiver conta, busca no Cadastro de Produtos
		_cConta := oGetD:aCols[nX,20]
		If Alltrim(_cConta) == ''
			_cConta := Posicione("SB1", 1, xFilial("SB1") + alltrim(oGetD:aCols[nX,4]), "B1_CONTA")
		Endif 
		

		if !lPreNota 
			/*AAdd(aItemPC, {{"D1_ITEM"	, StrZero(nX,4)		, Nil},;
	  					   {"D1_COD"	, oGetD:aCols[nX,4]	, Nil},;
	    				   {"D1_UM"     , oGetD:aCols[nX,6]	, Nil},;
			               {"D1_QUANT" 	, oGetD:aCols[nX,8]	, Nil},;
			               {"D1_VUNIT"  , oGetD:aCols[nX,9]	, Nil},;
		    	           {"D1_TOTAL" 	, oGetD:aCols[nX,10], Nil},;
		    	           {"D1_TIPO" 	, cTipo				, Nil},;
		    	           {"D1_SERIE" 	, (_cTab1)->&(_cCmp1+"_SERIE")     , Nil},;
		    	           {"D1_TES" 	, oGetD:aCols[nX,11], Nil},;
		    	           {"D1_BASEICM", oGetD:aCols[nX,13], Nil},;
		    	           /*{"D1_PICM"	, oGetD:aCols[nX,14], Nil},*//*;
		    	           {"D1_VALICM"	, oGetD:aCols[nX,15], Nil},;
		    	           {"D1_BASEIPI", oGetD:aCols[nX,16], Nil},;
		    	           {"D1_IPI"	, oGetD:aCols[nX,17], Nil},;
		    	           {"D1_VALIPI"	, oGetD:aCols[nX,18], Nil},;
		    	           {"D1_CLASFIS", oGetD:aCols[nX,19], Nil},;
		    	           {"D1_CONTA"	, _cConta/*oGetD:aCols[nX,20]*//*, Nil},;
		    	           {"D1_CC"		, oGetD:aCols[nX,21], Nil},;
		    	           {"D1_BRICMS" , oGetD:aCols[nX,24]/*oGetD:aCols[nX,25]*//*, Nil},;
		    	           {"D1_ICMSRET" , oGetD:aCols[nX,26]/*oGetD:aCols[nX,27]*//*, Nil},;
		    	           {"AUTDELETA" , "N"				, Nil};
		    	          })
						  */
						aItemPCLIN := {}
						AAdd(aItemPCLIN, {"D1_ITEM"	, StrZero(nX,4)		, Nil})
						AAdd(aItemPCLIN, {"D1_COD"	, oGetD:aCols[nX,4]	, Nil})
						AAdd(aItemPCLIN, {"D1_UM"     , oGetD:aCols[nX,6]	, Nil})
						AAdd(aItemPCLIN, {"D1_QUANT" 	, oGetD:aCols[nX,8]	, Nil})
						AAdd(aItemPCLIN, {"D1_VUNIT"  , oGetD:aCols[nX,9]	, Nil})
						AAdd(aItemPCLIN, {"D1_TOTAL" 	, oGetD:aCols[nX,10], Nil})
						AAdd(aItemPCLIN, {"D1_TIPO" 	, cTipo				, Nil})
						AAdd(aItemPCLIN, {"D1_SERIE" 	, (_cTab1)->&(_cCmp1+"_SERIE"), Nil})
						AAdd(aItemPCLIN, {"D1_TES" 	, oGetD:aCols[nX,11], Nil})
						AAdd(aItemPCLIN, {"D1_BASEICM", oGetD:aCols[nX,13], Nil})
						//Chamado 57063 -  ICMS ST
						If oGetD:aCols[nX,26] == 0 .OR. SUBSTR(oGetD:aCols[nX,19],2,2) == '10' 
							AAdd(aItemPCLIN, {"D1_PICM"	, oGetD:aCols[nX,14], Nil})
						Endif
						AAdd(aItemPCLIN, {"D1_VALICM"	, oGetD:aCols[nX,15], Nil})
						AAdd(aItemPCLIN, {"D1_BASEIPI", oGetD:aCols[nX,16], Nil})
						AAdd(aItemPCLIN, {"D1_IPI"	, oGetD:aCols[nX,17], Nil})
						AAdd(aItemPCLIN, {"D1_VALIPI"	, oGetD:aCols[nX,18], Nil})
						AAdd(aItemPCLIN, {"D1_CLASFIS", oGetD:aCols[nX,19], Nil})
						AAdd(aItemPCLIN, {"D1_CONTA"	, _cConta/*oGetD:aCols[nX,20]*/, Nil})
						AAdd(aItemPCLIN, {"D1_CC"		, oGetD:aCols[nX,21], Nil})
						//Chamado 57063 -  ICMS ST
						If oGetD:aCols[nX,26] > 0 .AND. SUBSTR(oGetD:aCols[nX,19],2,2) == '60'  .OR.;
							(SUBSTR(oGetD:aCols[nX,19],2,2) $'41/30' .AND.(cEmpAnt$'11/15'.or.(cEmpAnt=='01'.and.cFilAnt=='03')))
							
							nBasCalc   := oGetD:aCols[nX,24]
							nAlqCalc   := oGetD:aCols[nX,25]
							nValorCalc := oGetD:aCols[nX,26]

							//Caso tenha 2 campos preenchidos prenche o zerado
							If nBasCalc == 0  .AND. nAlqCalc > 0  .AND. nValorCalc > 0 
									nBasCalc :=Round( ( nValorCalc / nAlqCalc) * 100, 2)
							ElseIF nValorCalc == 0 .AND. nBasCalc > 0  .AND. nAlqCalc > 0 
									nValorCalc := Round( (nBasCalc * (nAlqCalc / 100 )),2)
							ElseIf nAlqCalc == 0 .AND. nValorCalc > 0 .AND. nBasCalc > 0 
									nAlqCalc := Round((  (nValorCalc / nBasCalc) * 100 ),2)
							Endif 
							
							AAdd(aItemPCLIN, {"D1_ALQNDES"	, nAlqCalc, Nil})
							AAdd(aItemPCLIN, {"D1_BASNDES"  , nBasCalc/*oGetD:aCols[nX,25]*/, Nil})
							AAdd(aItemPCLIN, {"D1_ICMNDES"  , nValorCalc/*oGetD:aCols[nX,27]*/, Nil})
						ELSE       

							nBasCalc   := oGetD:aCols[nX,24]
							nAlqCalc   := oGetD:aCols[nX,25]
							nValorCalc := oGetD:aCols[nX,26]

							//Caso tenha 2 campos preenchidos prenche o zerado
							If nBasCalc == 0  .AND. nAlqCalc > 0  .AND. nValorCalc > 0 
									nBasCalc :=Round( ( nValorCalc / nAlqCalc) * 100, 2)
							ElseIF nValorCalc == 0 .AND. nBasCalc > 0  .AND. nAlqCalc > 0 
									nValorCalc := Round( (nBasCalc * (nAlqCalc / 100 )),2)
							ElseIf nAlqCalc == 0 .AND. nValorCalc > 0 .AND. nBasCalc > 0 
									nAlqCalc := Round((  (nValorCalc / nBasCalc) * 100 ),2)
							Endif 

							AAdd(aItemPCLIN, {"D1_ALIQSOL"	, nAlqCalc, Nil})
							AAdd(aItemPCLIN, {"D1_BRICMS"   , nBasCalc/*oGetD:aCols[nX,25]*/, Nil})
							AAdd(aItemPCLIN, {"D1_ICMSRET"  , nValorCalc/*oGetD:aCols[nX,27]*/, Nil})  
							
							nBasIcmsST := nBasIcmsST + oGetD:aCols[nX,24]/*oGetD:aCols[nX,25]*/
							nValIcmsST := nValIcmsST + oGetD:aCols[nX,26]/*oGetD:aCols[nX,27]*/
							
						Endif 

						//Campos de Cofins 
						AAdd(aItemPCLIN, {"D1_BASIMP5", oGetD:aCols[nX,31], Nil})//nBasCOFINS,;
						AAdd(aItemPCLIN, {"D1_ALQIMP5", oGetD:aCols[nX,32], Nil})//nPerCOFINS,;
						AAdd(aItemPCLIN, {"D1_VALIMP5", oGetD:aCols[nX,33], Nil})//nValCOFINS,;
						
						//Campos de Pis
						AAdd(aItemPCLIN, {"D1_BASIMP6", oGetD:aCols[nX,28], Nil})//nBasePIS,;
						AAdd(aItemPCLIN, {"D1_ALQIMP6", oGetD:aCols[nX,29], Nil})//nPerPIS,;
						AAdd(aItemPCLIN, {"D1_VALIMP6", oGetD:aCols[nX,30], Nil})//nValPIS,;


						AAdd(aItemPCLIN, {"D1_VALDESC", oGetD:aCols[nX,34], Nil})//nValdesc,;
						AAdd(aItemPCLIN, {"D1_ORIIMP" , "SMS001", Nil})   
						AAdd(aItemPCLIN, {"AUTDELETA" , "N"				, Nil})

						AADD(aItemPC,aItemPCLIN)


		else
			/*AAdd(aItemPC, {{"D1_ITEM"	, StrZero(nX,4)		, Nil},;
	  					   {"D1_COD"	, oGetD:aCols[nX,4]	, Nil},;
	    				   {"D1_UM"     , oGetD:aCols[nX,6]	, Nil},;
			               {"D1_QUANT" 	, oGetD:aCols[nX,8]	, Nil},;
			               {"D1_VUNIT"  , oGetD:aCols[nX,9]	, Nil},;
		    	           {"D1_TOTAL" 	, oGetD:aCols[nX,10], Nil},;
		    	           {"D1_TIPO" 	, cTipo				, Nil},;
		    	           {"D1_SERIE" 	, (_cTab1)->&(_cCmp1+"_SERIE")     , Nil},;
		    	           {"D1_BASEICM", oGetD:aCols[nX,13], Nil},;
		    	           /*{"D1_PICM"	, oGetD:aCols[nX,14], Nil},*//*;
		    	           {"D1_VALICM"	, oGetD:aCols[nX,15], Nil},;
		    	           {"D1_BASEIPI", oGetD:aCols[nX,16], Nil},;
		    	           {"D1_IPI"	, oGetD:aCols[nX,17], Nil},;
		    	           {"D1_VALIPI"	, oGetD:aCols[nX,18], Nil},;
		    	           {"D1_CONTA"	, _cConta/*oGetD:aCols[nX,20]*//*, Nil},;
		    	           {"D1_CC"		, oGetD:aCols[nX,21], Nil},;
		    	           {"D1_VENCPRV", dDtVcto			, Nil},;
		    	           {"D1_VLDDPRV", cValidad			, Nil},;
		    	           {"D1_BRICMS" , oGetD:aCols[nX,24]/*oGetD:aCols[nX,25]*//*, Nil},;
		    	           {"D1_ICMSRET" , oGetD:aCols[nX,26]/*oGetD:aCols[nX,27]*//*, Nil},;
		    	           {"AUTDELETA" , "N"				, Nil};
		    	          })*/

						aItemPCLIN := {}
						AAdd(aItemPCLIN,{"D1_ITEM"	, StrZero(nX,4)		, Nil})
	  					AAdd(aItemPCLIN,{"D1_COD"	, oGetD:aCols[nX,4]	, Nil})
	    				AAdd(aItemPCLIN,{"D1_UM"     , oGetD:aCols[nX,6]	, Nil})
			            AAdd(aItemPCLIN,{"D1_QUANT" 	, oGetD:aCols[nX,8]	, Nil})
			            AAdd(aItemPCLIN,{"D1_VUNIT"  , oGetD:aCols[nX,9]	, Nil})
		    	        AAdd(aItemPCLIN,{"D1_TOTAL" 	, oGetD:aCols[nX,10], Nil})
		    	        AAdd(aItemPCLIN,{"D1_TIPO" 	, cTipo				, Nil})
		    	        AAdd(aItemPCLIN,{"D1_SERIE" 	, (_cTab1)->&(_cCmp1+"_SERIE")     , Nil})
						AAdd(aItemPCLIN,{"D1_XTES" 	, oGetD:aCols[nX,11], Nil})
						AAdd(aItemPCLIN,{"D1_CF" 	,oGetD:aCols[nX,12], Nil})
		    	        AAdd(aItemPCLIN,{"D1_BASEICM", oGetD:aCols[nX,13], Nil})
						//Chamado 57063 -  ICMS ST
						If oGetD:aCols[nX,26] == 0 .OR. SUBSTR(oGetD:aCols[nX,19],2,2) == '10' 
		    	        	AAdd(aItemPCLIN, {"D1_PICM"	, oGetD:aCols[nX,14], Nil})
						Endif
		    	        AAdd(aItemPCLIN,{"D1_VALICM"	, oGetD:aCols[nX,15], Nil})
		    	        AAdd(aItemPCLIN,{"D1_BASEIPI", oGetD:aCols[nX,16], Nil})
		    	        AAdd(aItemPCLIN,{"D1_IPI"	, oGetD:aCols[nX,17], Nil})
		    	        AAdd(aItemPCLIN,{"D1_VALIPI"	, oGetD:aCols[nX,18], Nil})
						AAdd(aItemPCLIN, {"D1_CLASFIS", oGetD:aCols[nX,19], Nil})

						AAdd(aItemPCLIN,{"D1_VALDESC"  , oGetD:aCols[nX,34], Nil})//nValdesc,;
						//Campos de Cofins 
						AAdd(aItemPCLIN, {"D1_BASIMP5", oGetD:aCols[nX,31], Nil})//nBasCOFINS,;
						AAdd(aItemPCLIN, {"D1_ALQIMP5", oGetD:aCols[nX,32], Nil})//nPerCOFINS,;
						AAdd(aItemPCLIN, {"D1_VALIMP5", oGetD:aCols[nX,33], Nil})//nValCOFINS,;
						//Campos de Pis
						AAdd(aItemPCLIN, {"D1_BASIMP6", oGetD:aCols[nX,28], Nil})//nBasePIS,;
						AAdd(aItemPCLIN, {"D1_ALQIMP6", oGetD:aCols[nX,29], Nil})//nPerPIS,;
						AAdd(aItemPCLIN, {"D1_VALIMP6", oGetD:aCols[nX,30], Nil})//nValPIS,;

		    	        AAdd(aItemPCLIN,{"D1_CONTA"	, _cConta/*oGetD:aCols[nX,20]*/, Nil})
		    	        AAdd(aItemPCLIN,{"D1_CC"		, oGetD:aCols[nX,21], Nil})
		    	        AAdd(aItemPCLIN,{"D1_VENCPRV", dDtVcto			, Nil})
		    	        AAdd(aItemPCLIN,{"D1_VLDDPRV", cValidad			, Nil}) 
		    	        If oGetD:aCols[nX,26] > 0 .AND. SUBSTR(oGetD:aCols[nX,19],2,2) == '60' .OR.;
							(SUBSTR(oGetD:aCols[nX,19],2,2) $'41/30' .AND.(cEmpAnt$'11/15'.or.(cEmpAnt=='01'.and.cFilAnt=='03')))
							
							nBasCalc   := oGetD:aCols[nX,24]
							nAlqCalc   := oGetD:aCols[nX,25]
							nValorCalc := oGetD:aCols[nX,26]

							//Caso tenha 2 campos preenchidos prenche o zerado
							If nBasCalc == 0  .AND. nAlqCalc > 0  .AND. nValorCalc > 0 
									nBasCalc :=Round( ( nValorCalc / nAlqCalc) * 100, 2)
							ElseIF nValorCalc == 0 .AND. nBasCalc > 0  .AND. nAlqCalc > 0 
									nValorCalc := Round( (nBasCalc * (nAlqCalc / 100 )),2)
							ElseIf nAlqCalc == 0 .AND. nValorCalc > 0 .AND. nBasCalc > 0 
									nAlqCalc := Round((  (nValorCalc / nBasCalc) * 100 ),2)
							Endif 
														
							AAdd(aItemPCLIN, {"D1_ALQNDES"	, nAlqCalc, Nil})
							AAdd(aItemPCLIN, {"D1_BASNDES"  , nBasCalc/*oGetD:aCols[nX,25]*/, Nil})
							AAdd(aItemPCLIN, {"D1_ICMNDES"  , nValorCalc/*oGetD:aCols[nX,27]*/, Nil})
						ELSE   

							nBasCalc   := oGetD:aCols[nX,24]
							nAlqCalc   := oGetD:aCols[nX,25]
							nValorCalc := oGetD:aCols[nX,26]

							//Caso tenha 2 campos preenchidos prenche o zerado
							If nBasCalc == 0  .AND. nAlqCalc > 0  .AND. nValorCalc > 0 
									nBasCalc :=Round( ( nValorCalc / nAlqCalc) * 100, 2)
							ElseIF nValorCalc == 0 .AND. nBasCalc > 0  .AND. nAlqCalc > 0 
									nValorCalc := Round( (nBasCalc * (nAlqCalc / 100 )),2)
							ElseIf nAlqCalc == 0 .AND. nValorCalc > 0 .AND. nBasCalc > 0 
									nAlqCalc := Round((  (nValorCalc / nBasCalc) * 100 ),2)
							Endif 


							AAdd(aItemPCLIN, {"D1_ALIQSOL"	, nAlqCalc, Nil})
							AAdd(aItemPCLIN, {"D1_BRICMS"   , nBasCalc/*oGetD:aCols[nX,25]*/, Nil})
							AAdd(aItemPCLIN, {"D1_ICMSRET"  , nValorCalc/*oGetD:aCols[nX,27]*/, Nil})     
							
							nBasIcmsST := nBasIcmsST + nBasCalc/*oGetD:aCols[nX,25]*/
							nValIcmsST := nValIcmsST + nValorCalc/*oGetD:aCols[nX,27]*/	
						Endif 
		    	        
		    	        
		    	        //AAdd(aItemPCLIN,{"D1_BRICMS" , oGetD:aCols[nX,24]/*oGetD:aCols[nX,25]*/, Nil})
		    	        //AAdd(aItemPCLIN,{"D1_ICMSRET" , oGetD:aCols[nX,26]/*oGetD:aCols[nX,27]*/, Nil})


						AAdd(aItemPCLIN,{"D1_ORIIMP"   , "SMS001", Nil}) 
						AAdd(aItemPCLIN,{"D1_ORIGEM"   , "GF"	 , Nil}) //Marca para nao zerar impostos na classificação
		    	        AAdd(aItemPCLIN,{"AUTDELETA"   , "N"		 , Nil})

						AADD(aItemPC,aItemPCLIN)     
						

		endif	    	          

		If !Empty(oGetD:aCols[nX,2]) .and. _lPedC 
			AAdd(aItemPC[nX], {"D1_PEDIDO", oGetD:aCols[nX,2], Nil})
			If Alltrim(oGetD:aCols[nX,3]) <> ''
				AAdd(aItemPC[nX], {"D1_ITEMPC", StrZero(val(oGetD:aCols[nX,3]),4), Nil})
			Endif
		EndIf
		//Amarração do Produto X Fornecedor
		dbSelectArea("SA5")
		SA5->( dbSetOrder(2))
		If !SA5->( dbSeek(xFilial("SA5") + PadR(oGetD:aCols[nX,4], TamSX3("A5_PRODUTO")[1]) + cFornece + cLoja) )

			RecLock("SA5", .T.)
			SA5->A5_FILIAL  := xFilial("SA5")
			SA5->A5_PRODUTO := PadR(oGetD:aCols[nX,4], TamSX3("A5_PRODUTO")[1])
			SA5->A5_FORNECE := PadR(cFornece, TamSX3("A5_FORNECE")[1])
			SA5->A5_LOJA    := PadR(cLoja, TamSX3("A5_LOJA")[1])
			SA5->A5_CODPRF  := SubStr(oGetD:aCols[nX,1], 1, 15)
			SA5->A5_NOMPROD := SubStr(oGetD:aCols[nX,1], 19)
			SA5->A5_NOMEFOR := Posicione("SA2", 1, xFilial("SA2") + PadR(cFornece, TamSX3("A5_FORNECE")[1]) + PadR(cLoja, TamSX3("A5_LOJA")[1]), "A2_NOME")
			MsUnLock()

		EndIf

	Next nX
	
	if !lPreNota
		aCabec := {{"F1_DOC"	, (_cTab1)->&(_cCmp1+"_DOC")					           , Nil, Nil},;
		           {"F1_SERIE"  , (_cTab1)->&(_cCmp1+"_SERIE")                             , Nil, Nil},;
		           {"F1_FORNECE", cFornece					                               , Nil, Nil},;
		           {"F1_LOJA"   , cLoja 						                           , Nil, Nil},;
		           {"F1_COND"   , cConPgto        			                               , Nil, Nil},;
		           {"F1_EMISSAO", (_cTab1)->&(_cCmp1+"_DTEMIS")                            , Nil, Nil},;
		           {"F1_DTDIGIT", dDataBase		     		                               , Nil, Nil},;
		           {"F1_EST"    , cEst				      	                               , Nil, Nil},;
		           {"F1_TIPO"   , cTipo				                                       , Nil, Nil},;
		           {"F1_ESPECIE", cEspNFe					                               , Nil, Nil},;
		           {"F1_FORMUL" , "N"					    	                           , Nil, Nil},;
		           {"F1_CHVNFE" , (_cTab1)->&(_cCmp1+"_CHAVE")                             , Nil, Nil},;
		           {"F1_VALMERC", nValMerc                                                 , Nil, Nil},;
		           {"F1_FRETE"  , nValFrete                                                , Nil, Nil},;
		           {"F1_DESPESA", nValDesp                                                 , Nil, Nil},;
		           {"F1_DESCONT", nValDesc                                                 , Nil, Nil},;
		           {"F1_SEGURO" , nValSeguro                                               , Nil, Nil},;
		           {"F1_BRICMS" , nBasIcmsST                                               , Nil, Nil},;
		           {"F1_ICMSRET" , nValIcmsST                                               , Nil, Nil},;
		           {"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil},;
				   {"F1_TPFRETE",  (_cTab1)->&(_cCmp1+"_TPFRET") 						   , Nil, Nil},;
		           {"E2_HIST"   , _cHistor 	                                               , Nil, Nil},;
		           {"E2_NATUREZ", cNaturez				 	                               , Nil, Nil},;
				   {"F1_ORIIMP", 'SMS001'												   , Nil, Nil};
				  }
	else
		aCabec := {{"F1_DOC"	, (_cTab1)->&(_cCmp1+"_DOC")					           , Nil, Nil},;
		           {"F1_SERIE"  , (_cTab1)->&(_cCmp1+"_SERIE")                             , Nil, Nil},;
		           {"F1_FORNECE", cFornece					                               , Nil, Nil},;
		           {"F1_LOJA"   , cLoja 						                           , Nil, Nil},;
		           {"F1_EMISSAO", (_cTab1)->&(_cCmp1+"_DTEMIS")                            , Nil, Nil},;
		           {"F1_DTDIGIT", dDataBase		     		                               , Nil, Nil},;
		           {"F1_EST"    , cEst				      	                               , Nil, Nil},;
		           {"F1_TIPO"   , cTipo				                                       , Nil, Nil},;
		           {"F1_ESPECIE", cEspNFe					                               , Nil, Nil},;
		           {"F1_FORMUL" , "N"					    	                           , Nil, Nil},;
		           {"F1_CHVNFE" , (_cTab1)->&(_cCmp1+"_CHAVE")                             , Nil, Nil},;
		           {"F1_VALMERC", nValMerc                                                 , Nil, Nil},;
		           {"F1_FRETE"  , nValFrete                                                , Nil, Nil},;
		           {"F1_DESPESA", nValDesp                                                 , Nil, Nil},;
		           {"F1_DESCONT", nValDesc                                                 , Nil, Nil},;
		           {"F1_SEGURO" , nValSeguro                                               , Nil, Nil},;
		           {"F1_BRICMS" , nBasIcmsST                                               , Nil, Nil},;
		           {"F1_ICMSRET" , nValIcmsST                                               , Nil, Nil},;
		           {"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil},;
				   {"F1_TPFRETE", (_cTab1)->&(_cCmp1+"_TPFRET")  						   , Nil, Nil},;
				   {"F1_ORIIMP", 'SMS001'												   , Nil, Nil};			   
				  }
	endif
	Begin Transaction

		If lSMSPRJ
			PutMv("MV_PMSIPC", "2")
		EndIf

		lMsErroAuto := .F.
		if !lPreNota

			MsAguarde({|| MsExecAuto({|x,y,z,w,k| Mata103(x,y,z,w,,k)}, aCabec, aItemPC, 3, lConfere, aProj)}, "Nota de entrada", "Importando Nota de Entrada...")
		else
			MsAguarde({|| MsExecAuto({|x,y,z,w,k| MATA140(x,y,z,w,k)}, aCabec, aItemPC, 3, .F., 1)}, "Pré-nota de entrada", "Importando Pré-nota...")
		endif
		If lSMSPRJ
			PutMv("MV_PMSIPC", nPMSIPC)
		EndIf

		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		If !lMsErroAuto .And. !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

			lConfirm := .F.
			lRet 	 := .F.

	    ElseIf lMsErroAuto

	    	DisarmTransaction()
      		RecLock(_cTab1, .F.)
			(_cTab1)->&(_cCmp1+"_SIT")  := "3"
			(_cTab1)->&(_cCmp1+"_ERRO") := MontaErro(GetAutoGrLog())
			(_cTab1)->( MSUnlock() )

      		ExibeErro()
      		lRet := .F.

		Else
			
			If alltrim(SF1->F1_ORIIMP) == ''
				Reclock('SF1',.F.)
					SF1->F1_ORIIMP := 'SMS001'
				SF1->(MsUnlock())
			Endif  

			// faço update na SE2 com o histórico do título
			_cHistor := substr(_cHistor,1,(tamSX3("E2_HIST")[1]))
			cQuery := "update " + retSqlName("SE2") + "  set E2_HIST = '" + alltrim(_cHistor) + "'"
			cQuery += " where E2_NUM = '" + (_cTab1)->&(_cCmp1+"_DOC") + "' " 
			cQuery += " and E2_PREFIXO = '" + (_cTab1)->&(_cCmp1+"_SERIE") + "' "
			cQuery += " and E2_TIPO = 'NF' "
			cQuery += " and E2_FORNECE = '" + (_cTab1)->&(_cCmp1+"_CODEMI") + "' "	
			cQuery += " and E2_LOJA = '" + (_cTab1)->&(_cCmp1+"_LOJEMI")  + "' "
			cQuery += " and E2_FILIAL = '" + xFilial("SE2") + "' "
			cQuery += " and D_E_L_E_T_ <> '*' "
			
			If (TCSQLExec(cQuery) < 0)
				MsgStop("TCSQLError() " + TCSQLError())
				lMsErroAuto := .T.
			EndIf		

			RecLock(_cTab1, .F.)
			(_cTab1)->&(_cCmp1+"_SIT")    := "2"
			(_cTab1)->&(_cCmp1+"_ERRO")   := ""
			(_cTab1)->&(_cCmp1+"_ESPECI") := cEspNFe
			(_cTab1)->&(_cCmp1+"_TIPOEN") := cTipo
			(_cTab1)->&(_cCmp1+"_NATFIN") := cNaturez
			(_cTab1)->&(_cCmp1+"_CONDPG") := cConPgto
			(_cTab1)->&(_cCmp1+"_DTIMP")  := dDataBase
			(_cTab1)->&(_cCmp1+"_HRIMP")  := Time()
			(_cTab1)->&(_cCmp1+"_USUIMP") := cUserName
			(_cTab1)->( MSUnlock() )
			MsgInfo("Importação realizada com sucesso!", "Aviso")

		EndIf

	End Transaction

Return lRet


///////////////////////////////////////////
Static Function TrataTipo(xVar)

	Local cType := ValType(xVar)

	Do Case
		Case cType == "N"
			Return cValToChar(xVar)
		Case cType == "D"
			Return DToC(xVar)
		Case cType == "L"
			Return IIf(xVar, ".T.", ".F.")
	EndCase

Return xVar

///////////////////////////////////////////

// Função que realiza o movimento do xml para o backup
Static Function TransXml(cArquivo)
Local nErro

	__CopyFile(cEntrada + cArquivo, cSaida + cArquivo)
	nErro := FError()

	If File(cSaida + cArquivo)
		FErase(cEntrada + cArquivo)
		Return {.T., ""}
	Else
		Alert("***Não foi possível mover o arquivo, XML não será importado e o arquivo continuará no diretório de origem. Identificação do erro: " + cValToChar(FError()), 1)
		Return {.F., ""}
	EndIf

Return()

///////////////////////////////////////////

// Tela de Consulta dos Pedidos de Compra.
Static Function ConsPed()

	Local oDlgPedido, oPanel1, oPanel3, oListPed
	Local oOk := LoadBitmap(GetResources(), "LBOK")
	Local oNo := LoadBitmap(GetResources(), "LBNO")
	Local aHeader := {"","Pedido","Item","Data Emissão","Produto","UM","Quantidade","Descrição"}
	Local aAddCmp
	Local nCmp
	Local cAddPed := "" 
	Local nLZ := 0 
	Local _nLinha   := ogetd:NAT //Captura linha corrente
	Local _cProduto :=  oGetD:aCols[_nLinha,4]   

	Private aPedidos := {}
	Private oLayerPed  
	
	
	
    
/*    FOR nn1 := 1 to Len(aCols) // Ajuste para possibilitar a seleção do item - Thiago SLA - 06/07/2016
    	IF !EMPTY(oGetD:aCols[nn1,2])
		   	IF UPPER(ALLTRIM(oGetD:aCols[nn1,2])) == 'X'
//    			nLZ ++
	        ENDIF
        ENDIF
 	NEXT
    
    IF nLZ == 0
    	MSGALERT("Selecione o item, marcando o campo Pedido com a letra X","Item Não Marcado") 
    	RETURN()
    ENDIF */
	              
	
	dbSelectArea("SC7")
	SC7->( dbSetOrder(3) )
	If SC7->( dBSeek(xFilial("SC7") + cFornece /*+ cLoja*/) )

		While !SC7->( Eof() ) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_FORNECE == cFornece /*.And. SC7->C7_LOJA == cLoja*/

			If SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA > 0 .And. Empty(SC7->C7_RESIDUO) .And. SC7->C7_TPOP <> 'P'

				If alltrim(_cProduto) == '' .or. alltrim(_cProduto) == alltrim(SC7->C7_PRODUTO) 
					AAdd(aPedidos,{.F., SC7->C7_NUM, SC7->C7_ITEM, SC7->C7_EMISSAO, SC7->C7_PRODUTO, SC7->C7_UM, (SC7->C7_QUANT - SC7->C7_QUJE),;
							   SC7->C7_DESCRI, SC7->C7_PRECO, SC7->C7_TES, SC7->C7_PICM, SC7->C7_IPI})
				Endif
			EndIf

			SC7->( dbSkip() )

		EndDo

	EndIf

	If Len(aPedidos) > 0

		DEFINE MSDIALOG oDlgPedido FROM 0,0 TO 350,630 TITLE 'Consulta de Pedidos de Compra' PIXEL
			oDlgPedido:lEscClose := .F.

			oLayerPed := FWLayer():New()
			oLayerPed:Init(oDlgPedido, .F.)

			oLayerPed:AddLine('CENTER', 90, .F.)
			oLayerPed:AddCollumn('COL_CENTER', 100, .T., 'CENTER')

					oLayerPed:AddWindow('COL_CENTER', 'WIN_CENTER', "Fornecedor: " + cDescFor, 100, .F., .T.,, 'CENTER',)

						oListPed := TWBrowse():New(40,05,204,140,, aHeader,, oLayerPed:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'),,,,,,,,,,,,.F.,,.T.,,.F.,,,)
						oListPed:bLDblClick := {|| aPedidos[oListPed:nAt,1] := !(aPedidos[oListPed:nAt,1]),oListPed:Refresh()}
						oListPed:SetArray(aPedidos)

						oListPed:bLine := &('{|| {	IIf(aPedidos[oListPed:nAt,1],oOk,oNo), ' +;
													'aPedidos[oListPed:nAt,2],' +;
								    				'aPedidos[oListPed:nAt,3],' +;
													'aPedidos[oListPed:nAt,4],' +;
													'aPedidos[oListPed:nAt,5],' +;
													'aPedidos[oListPed:nAt,6],' +;
													'PADL(Transform(aPedidos[oListPed:nAt,7],"@E 999999.9999"),20,""),' +;
													'aPedidos[oListPed:nAt,8] ' + cAddPed + '}}')

						oListPed:Align := CONTROL_ALIGN_ALLCLIENT

				oLayerPed:AddLine('BOTTOM', 10, .F.)
				oLayerPed:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')

					oPanelBot := tPanel():New(0, 0, "", oLayerPed:GetColPanel('COL_BOTTOM', 'BOTTOM'),,,,, RGB(239,243,247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT

					oQuit := THButton():New(0, 0, "Cancelar", oPanelBot, {|| oDlgPedido:End()}, , ,)
					oQuit:nWidth  := 100
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002,070,112),)

					oSel := THButton():New(0, 0, "Selecionar", oPanelBot, {|| IIf(ValPed(),oDlgPedido:End(),.F.)}, , ,)
					oSel:nWidth  := 110
					oSel:nHeight := 10
					oSel:Align := CONTROL_ALIGN_RIGHT
					oSel:SetColor(RGB(002,070,112),)

		ACTIVATE MSDIALOG oDlgPedido CENTERED

	Else
		MsgStop("Não foram encontrados Pedidos de Compra para este Fornecedor!", "Aviso")
	EndIf

Return .T.


///////////////////////////////////////////
// Valida a seleção de pedidos de compra via tela
Static Function ValPed()

	Local nCont  := 0
	Local nQuant := 0
	Local lPassou := .F.
	Local nX := 0
	For nX := 1 To Len(aPedidos)

		If aPedidos[nX,1] == .T.
			nCont++
		EndIf

	Next nX

	If nCont == 0

		MsgStop("Não houve seleção de itens do Pedido!", "Aviso")

		Return .F.

	EndIf

	If nCont > Len(oGetD:aCols)

		MsgStop("Quantidade de itens selecionados difere da quantidade de itens da nota!","Aviso")

		Return .F.

	EndIf

	nCont := 1

	For nX := 1 To Len(aPedidos)

		lPassou := .F.

		If aPedidos[nX,1]
			nSok := .F.
            // Leandro Spiller - 29.11.2016
            // Retirado Customização de 'X'
            // e Colocado linha corrente
            
             /*FOR nn1 := 1 to Len(aCols) // Ajuste para possibilitar a seleção do item - Thiago SLA - 06/07/2016
            	IF UPPER(ALLTRIM(oGetD:aCols[nn1,2])) == 'X'  
            		IF !nSok
            	   		nCont := nn1
              			nSok := .T.
            		ENDIF
            	ENDIF
            NEXT */
            
            nCont := ogetd:NAT //Captura linha corrente
            
			If oGetD:aCols[nCont,7] < aPedidos[nX,7]

				If MsgYesNo("A quantidade do Pedido de Compra é maior do que a do Item da Nota!"+chr(13)+chr(10)+;
					"Qtde. Item da Nota: " + Transform(oGetD:aCols[nCont,7], "@E 999999999.9999")+chr(13)+chr(10)+;
					"Qtde. Pedido de Compra: " + Transform(aPedidos[nX,7], "@E 99999999.99")+chr(13)+chr(10)+;
					"Deseja baixar o pedido parcialmente?", "Aviso")

					nQuant := oGetD:aCols[nCont, 8]
					lPassou := .T.

				Else

					nQuant := aPedidos[nX,7]
					lPassou := .T.

				EndIf

			Else

				nQuant := aPedidos[nX,7]
				lPassou := .T.

			EndIf

		EndIf

		If lPassou
			oGetD:aCols[nCont,2] := aPedidos[nX,2]
			oGetD:aCols[nCont,3] := aPedidos[nX,3]
			oGetD:aCols[nCont,4] := aPedidos[nX,5]
			oGetD:aCols[nCont,5] := Posicione("SB1", 1, xFilial("SB1") + oGetD:aCols[nCont,4], "B1_DESC")
			oGetD:aCols[nCont,6] := aPedidos[nX,6]
			oGetD:aCols[nCont,8] := nQuant
			oGetD:aCols[nCont,9] := aPedidos[nX,9]
			oGetD:aCols[nCont,10] := oGetD:aCols[nCont,8]*oGetD:aCols[nCont,9]
			oGetD:aCols[nCont,11] := aPedidos[nX,10]
			oGetD:aCols[nCont,12] := Iif(GETMV("MV_ESTADO")==cEstado,"1","2")+Substr(Posicione("SF4",1,xFilial("SF4")+aPedidos[nX,10],"F4_CF"),2,3)
			oGetD:aCols[nCont,13] := oGetD:aCols[nCont,8]*oGetD:aCols[nCont,9]
			oGetD:aCols[nCont,14] := aPedidos[nX,11]
			oGetD:aCols[nCont,15] := oGetD:aCols[nCont,13]*oGetD:aCols[nCont,14]/100
			oGetD:aCols[nCont,16] := oGetD:aCols[nCont,8]*oGetD:aCols[nCont,9]
			oGetD:aCols[nCont,17] := aPedidos[nX,12]
			oGetD:aCols[nCont,18] := oGetD:aCols[nCont,16]*oGetD:aCols[nCont,17]/100
			nCont++
		EndIf

	Next nX

Return .T.

///////////////////////////////////////////

// Valida os pedidos de compra no momento do carregamento
Static Function ValPC()

	Local lPassou
	Local nX := 0

	For nX := 1 To Len(oGetD:aCols)

		lPassou := .F.

		If !Empty(oGetD:aCols[nX,2])

			dbSelectArea("SC7")
			SC7->( dbSetOrder(1) )
			If !SC7->( dbSeek(xFilial("SC7") + oGetD:aCols[nX,2] + StrZero(val(oGetD:aCols[nX,3]),4) ))
				MsgStop("1Número do Pedido de Compra informado no item " + oGetD:aCols[nX,2] + "/" + StrZero(nX, 4) + " não foi encontrado!", "Aviso")
				Return .F.
			ElseIf SC7->C7_QUJE < SC7->C7_QUANT .And. SC7->C7_ENCER <> "E"

				If SC7->C7_FORNECE # cFornece

					MsgStop("Pedido de Compra informado no item " + StrZero(nX, 4) + " não pertence ao fornecedor selecionado!", "Aviso")
					Return .F.

				ElseIf MsgYesNo("Foi encontrado um Pedido de Compra informado no item "+StrZero(nX,4)+"!"+chr(13)+chr(10)+;
								"Deseja importar as informações?", "Aviso")

					oGetD:aCols[nX,4]  := SC7->C7_PRODUTO
					oGetD:aCols[nX,5]  := Posicione("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "B1_DESC")
					oGetD:aCols[nX,6]  := SC7->C7_UM
					oGetD:aCols[nX,11] := SC7->C7_TES
					oGetD:aCols[nX,12] := IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + Substr(Posicione("SF4", 1, xFilial("SF4") + SC7->C7_TES, "F4_CF"), 2, 3)

					If (SC7->C7_QUANT-SC7->C7_QUJE)>oGetD:aCols[nX,7]
						If !MsgYesNo("Quantidade informada no item "+StrZero(nX,4)+" está maior que quantidade do arquivo XML!"+chr(13)+chr(10)+;
								      "Qtde. Item da Nota: "+Transform(oGetD:aCols[nX,7],"@E 999999999.9999")+chr(13)+chr(10)+;
									  "Qtde. Pedido de Compra: "+Transform((SC7->C7_QUANT-SC7->C7_QUJE) ,"@E 99999999.99")+chr(13)+chr(10)+;
									  "Deseja baixar o pedido parcialmente?", "Aviso")
							lPassou := .T.
						EndIf
					ElseIf (SC7->C7_QUANT-SC7->C7_QUJE)<oGetD:aCols[nX,7]

						If MsgYesNo("Quantidade informada no item "+StrZero(nX,4)+" está menor que quantidade do arquivo XML!"+chr(13)+chr(10)+;
								      "Qtde. Item da Nota: "+Transform(oGetD:aCols[nX,7],"@E 999999999.9999")+chr(13)+chr(10)+;
									  "Qtde. Pedido de Compra: "+Transform((SC7->C7_QUANT-SC7->C7_QUJE) ,"@E 99999999.99")+chr(13)+chr(10)+;
									  "Deseja importar as informações?", "Aviso")
							lPassou := .T.
						EndIf

					Endif

					If lPassou
						oGetD:aCols[nX,8]  := (SC7->C7_QUANT-SC7->C7_QUJE)
						oGetD:aCols[nX,9]  := SC7->C7_PRECO
						oGetD:aCols[nX,10] := oGetD:aCols[nX,8]*oGetD:aCols[nX,9]
						oGetD:aCols[nX,13] := oGetD:aCols[nX,8]*oGetD:aCols[nX,9]
						oGetD:aCols[nX,14] := SC7->C7_PICM
						oGetD:aCols[nX,15] := oGetD:aCols[nX,13]*oGetD:aCols[nX,14]/100
						oGetD:aCols[nX,16] := oGetD:aCols[nX,8]*oGetD:aCols[nX,9]
						oGetD:aCols[nX,17] := SC7->C7_IPI
						oGetD:aCols[nX,18] := oGetD:aCols[nX,16]*oGetD:aCols[nX,17]/100
					EndIf

					oGetD:oBrowse:Refresh()
				EndIf
			Else
				MsgStop("Número do Pedido de Compra informado no item "+StrZero(nX,4)+" não foi encontrado!", "Aviso")
				Return .F.
			EndIf

		EndIf
	Next

Return .T.

///////////////////////////////////////////

//Funções de validações de campos de tela.
User Function SMSPROD()
	Local cTes
	Local cUMXml := oXml:_nfeProc:_NFe:_infNFe:_det[N]:_prod:_uCom:Text
	Local cUM
	Local cProd := GDFieldGet(_cCmp2+"_COD",, .T.)

	DbSelectarea('SB1')
	DbsetOrder(1)
	If !Dbseek(xFilial('SB1') + cProd)
		Alert('Código de Produto Inválido')
		Return .F.
	Endif


	//Bloqueio por tipo de produtos
	If  alltrim(SB1->B1_TIPO) $ 'SH/PA/LU/QR/AE' 
		Alert('Para produtos do Tipo SH,PA,LU,QR e AE você deve utilizar o Importador NOVO: ' +chr(10) +SB1->B1_COD +'-' +alltrim(SB1->B1_DESC) +chr(10)  )
		Return .F.
	Endif

	//Evita erro de inclusão
	If ValType(M->&(_cCmp2+"_COD")) <> 'C'
		Return 
	Endif 


	MAFISREF('IT_PRODUTO', 'MT100', M->&(_cCmp2+"_COD"))
	GdFieldPut(_cCmp2+"_DSPROD", SB1->B1_DESC)   
	
	cTes := SB1->B1_TE

	If !Empty(cTes)
		GdFieldPut(_cCmp2+"_TES", cTes)
		GdFieldPut(_cCmp2+"_CF", IIf(GETMV("MV_ESTADO") == IIf(cCombo1 == "N", cEstado, M->&(_cCmp1+"_EST")), "1", "2") + Substr(Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_CF"), 2, 3))
	EndIf

	cUM := SB1->B1_UM

	If alltrim(cUMXml) <> alltrim(cUM) //Leandro Spiller - Retira espaços na Validação


		If Aviso("Unidade de Medida", "A Unidade de Medida do Produto está diferente do arquivo XML!" + CRLF +;
    				  "Un.Medida do arquivo XML: " + cUMXml + CRLF +;
					  "Un.Medida do Produto Informado: " + cUM + CRLF +;
				 	  "Deseja substituir pela unidade de medida do produto ou manter a do Xml?", {"Substituir","Manter"}, 2) == 1

			GdFieldPut(_cCmp2+"_UM", cUM)

		Else
			GdFieldPut(_cCmp2+"_UM", cUMXml)
		EndIf

	EndIf

	If cCombo1 $ "D;B;I;P;C"
		If GDFieldGet(_cCmp2+"_COD",, .T.) # GDFieldGet(_cCmp2+"_COD")

			aMarcNFs[N] := {"", "", "", "", "", ""}
			GDFieldPut(_cCmp2+"_OK", "CANCEL_15")

		EndIf
	EndIf

Return .T.

///////////////////////////////////////////

User Function SMSQTDE()

	Local nQtdXml  := GDFieldGet(_cCmp2+"_QUANT1",, .T.)
	Local nQtdInfo := GDFieldGet(_cCmp2+"_QUANT2",, .T.)

	If nQtdXml # nQtdInfo

		If Aviso("Quantidade de produto", "Quantidade informada está diferente da quantidade do arquivo XML!" + CRLF +;
    				  "Qtde. Arquivo XML: " + Transform(nQtdXml, "@E 999999999.9999")+ CRLF +;
					  "Qtde. Informada: " + Transform(nQtdInfo, "@E 99999999.99") + CRLF +;
					  "Deseja continuar?", {"Sim", "Não"}, 2) # 1

			Return .T.

		EndIf

	EndIf

	GDFieldPut(_cCmp2+"_TOTAL", nQtdInfo * GDFieldGet(_cCmp2+"_VUNIT",, .T.))

	If cCombo1 == "N"
		GDFieldPut(_cCmp2+"_BASEIC", GDFieldGet(_cCmp2+"_TOTAL",, .T.))
		GDFieldPut(_cCmp2+"_VALICM" , GDFieldGet(_cCmp2+"_BASEIC",, .T.) * GDFieldGet(_cCmp2+"_PICM",, .T.) / 100)
		GDFieldPut(_cCmp2+"_BASEIP", GDFieldGet(_cCmp2+"_TOTAL",, .T.))
		GDFieldPut(_cCmp2+"_VALIPI" , GDFieldGet(_cCmp2+"_BASEIP",, .T.) * GDFieldGet(_cCmp2+"_IPI",, .T.) / 100)
	EndIf

Return .T.

///////////////////////////////////////////

User Function SMSTES()

LOCAL cCmpTes 	:= _cCmp2+"_TES"
Local cCmpCf 	:= _cCmp2+"_CF"
Local cCmpCst 	:= _cCmp2+"_CLASFI"
Local cCmpProd	:= _cCmp2+"_COD"

Local _cCfop 	:= SPACE(04)
Local _cCst		:= SPACE(03)
Local _cProd	:= ""
LOCAL nPosTes 	:= 0
LOCAL nPosCf 	:= 0
LOCAL nPosCst 	:= 0
Local nPosProd	:= 	aScan(aHeader,{|x| Alltrim(x[2]) == cCmpProd })

Local xRetuTes
Local xRetuCf
Local xRetuCst

Local cTes := GDFieldGet(_cCmp2+"_TES",, .T.)

_cProd := aCols[n][nPosProd]

	If !MAAVALTES("E", cTes)
		Return .F.
	EndIf

	If cCombo1 == "D" .And. Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_PODER3") # "N"
		Help( ,, 'Help',, "Em uma devolução a TES informada deve possuir poder de terceiros igual a N=Não controla.", 1, 0 )
		Return .F.
	ElseIf cCombo1 == "B" .And. Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_PODER3") # "D"
		Help( ,, 'Help',, "Em um beneficiamento a TES informada deve possuir poder de terceiros igual a D=Devolução.", 1, 0 )
		Return .F.
	EndIf

	_cCfop 	:= RetCF(cTes, IIf(cCombo1 == "N", cEstado, M->&(_cCmp1+"_EST")))
	_cCst 	:= RetCst(cTes, _cProd)
	
	GDFieldPut(_cCmp2+"_CF",_cCfop )
	GDFieldPut(_cCmp2+"_CLASFI",_cCst )

// regra para replicar o tes

//Variavel padrao para retorno
//////////////////////////////
xRetuTes 	:= &cCmpTes
xRetuCf 	:= _cCfop
xRetuCst	:= _cCst

//Verifico se campo existe e atualizo informacoes
/////////////////////////////////////////////////
If (N == 1)
	nPosTes := aScan(aHeader,{|x| Alltrim(x[2]) == cCmpTes })
	nPosCf 	:= aScan(aHeader,{|x| Alltrim(x[2]) == cCmpCf })
	nPosCst := aScan(aHeader,{|x| Alltrim(x[2]) == cCmpCst })

	// replico a TES
	If (nPosTes > 0).and.(Len(aCols) > 1).and.MsgYesNo("Replicar conteúdo da coluna "+Alltrim(aHeader[nPosTes,1])+" para todas as linhas ? ")

		aEval(aCols,{|x| x[nPosTes] := xRetuTes })
		// replico o CFOP
		If (nPosCf > 0).and.(Len(aCols) > 1)
			aEval(aCols,{|x| x[nPosCf] := _cCfop })
		Endif
		
		If (nPosCST > 0).and.(Len(aCols) > 1)
			aEval(aCols,{|x| x[nPosCST] := _cCst })
		Endif

	Endif

Endif

Return .T.

////////////////////////////////////////////////////
Static Function MenuDef()
Local aRotina := {}

//CHAMADO 436370 - ERRO PROTHEUS OUTRAS EMPRESAS
Default cBrowse := ""
Default _cCmp1 	:= ""

// Parâmetros gerais

	If GetNewPar("MV_XSMS007", .T.)
		ADD OPTION aRotina TITLE "&Parâmetros" 		ACTION "StaticCall(SMS001, TelaParam, .T.)" 				               OPERATION 3 ACCESS 0
	Endif

	ADD OPTION aRotina TITLE "&Atualizar"           ACTION "StaticCall(SMS001, ReCarga)"                                       OPERATION 3 ACCESS 0

// Parâmetros tela Pendentes
	If (cBrowse $ "PEN")
		ADD OPTION aRotina TITLE "Pes&quisar"           ACTION "AxPesqui"                                                          OPERATION 1 ACCESS 0
		ADD OPTION aRotina TITLE "&Recicla"         	ACTION "StaticCall(SMS001, ReciclaXML)"								       OPERATION 4 ACCESS 0
		ADD OPTION aRotina TITLE "&Excluir"         	ACTION "StaticCall(SMS001, ExcluirPEN)"								       OPERATION 4 ACCESS 0
		IF __cUserId == '000000'
			ADD OPTION aRotina TITLE "&Cad.E-mail"         	ACTION "U_CadMail()"											       OPERATION 3 ACCESS 0
		ENDIF
	Endif


	If (cBrowse $ "NFE")
		ADD OPTION aRotina TITLE "Retornar"         ACTION "U_SMSRet"                                                          OPERATION 3 ACCESS 0
	EndIf

	If !(cBrowse $ "PEN")
		ADD OPTION aRotina TITLE "&Importar"        ACTION "StaticCall(SMS001, ImportaXML)" 							       OPERATION 4 ACCESS 0
	Endif

	If !(cBrowse $ "PEN")
		ADD OPTION aRotina TITLE "&Visualizar Xml"  ACTION "StaticCall(SMS001, ExibeInfo, '"+_cCmp1+"_XML')"                   OPERATION 4 ACCESS 0
		if((cBrowse $ "CTE"))
			ADD OPTION aRotina TITLE "&Visualizar Erro"  ACTION "StaticCall(SMS001, Exibeinfo, '"+_ccmp1+"_ERRO')"                   OPERATION 4 ACCESS 0
		endif
		ADD OPTION aRotina TITLE "&Excluir"              ACTION "StaticCall(SMS001, ExcluirXML)"								       OPERATION 4 ACCESS 0
		ADD OPTION aRotina TITLE "&Legenda"              ACTION "StaticCall(SMS001, XMLTabLeg)"								       OPERATION 4 ACCESS 0
		ADD OPTION aRotina TITLE "&Excluir XML da Pasta" ACTION "U_SMS001EF"									OPERATION 4 ACCESS 0
								
	Endif

Return aRotina



///////////////////////////////////////////

Static Function TotDocXml()
Local cQuery
Local cAlias := GetNextAlias()
Local aRet   := AFill(Array(6), "0")

	cQuery := " SELECT TAB1."+_cCmp1+"_TIPO TIPO, COUNT(*) TOT FROM " + RetSQLName(_cTab1) + " TAB1 "
	cQuery += " WHERE TAB1."+_cCmp1+"_FILIAL = '" + xFilial("SF1") + "' "
	cQuery += " AND (TAB1."+_cCmp1+"_SIT = '1' OR TAB1."+_cCmp1+"_SIT = '3') AND TAB1.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY TAB1."+_cCmp1+"_TIPO ORDER BY TAB1."+_cCmp1+"_TIPO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
	(cAlias)->( dbGoTop() )
	While !(cAlias)->( Eof() )
		aRet[Val((cAlias)->TIPO)] := cValToChar((cAlias)->TOT)
		(cAlias)->( dbSkip() )
	EndDo

	If (Select("TRB") <> 0 )
		dbSelectArea("TRB")
		dbCloseArea()
	Endif

	cQuery := " SELECT COUNT(*) TOT FROM " + RetSQLName(_cTab4) + " TAB4 WHERE TAB4.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TRB",.F., .T.)
	If !TRB->( Eof() )
		aRet[6] := cValToChar(TRB->TOT)
	EndIf

Return aRet

///////////////////////////////////////////
Static Function VisuImpEvto()

	If (_cTab1)->( Eof() )

		MsgStop("Não há Carta de Correção selecionada para visualizar!", "Cartas de Correção")

		Return .F.

	EndIf

	dbSelectArea("SF1")
	SF1->( dbSetOrder(1) )
	SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

	U_SMSEVNTO(SF1->( Found() ))

Return



///////////////////////////////////////////

Static Function ParamDesc(cPar)

Return AllTrim( Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESCRIC")         + ;
			    Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC1")           + ;
			    RTrim(Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC2"))) + ;
			    " | " + Alltrim(Posicione("SX6",1,xFilial("SX6")+cPar,"X6_VAR") )

///////////////////////////////////////////


//////////////////////////////

User Function MT116GRV()

Local nPosCTe := AScan(aAutoCab, {|x| x[1] == "F1_CHVNFE"})

	If nPosCTe > 0 .And. IsInCallStack("U_SMS001")
		aNfeDanfe[13] := aAutoCab[nPosCTe, 2]
	EndIf

Return

/*
//////////////////////////////
//Botão Documento de Entrada
User Function MTA103MNU()
	AAdd(aRotina, {"Eventos", {{"Cartas de Correção", "U_SMSEVNTO(.T.)",, 2, 0}},, 2, 0})
Return
*/

//////////////////////////////
User Function SMSEVNTO(lFound)

	Local oDlgCCe
	Local oBrowse
	Local aRotinaBkp := IIf(Type("aRotina") != "U", aRotina, Nil)
	Local aCmp := IIf(lFound, {SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA},;
							  {(_cTab1)->&(_cCmp1+"_DOC"), (_cTab1)->&(_cCmp1+"_SERIE"), SA1->A1_COD, SA1->A1_LOJA})

	Default lFound := .T.

	If !Empty(aRotinaBkp)
		ASize(aRotina, 0)
		aRotina := Nil
	EndIf

	dbSelectArea(_cTab3)
	(_cTab3)->( dbSetOrder(1) )
	If (_cTab3)->( dbSeek(xFilial(_cTab3) + "1" + aCmp[1] + aCmp[2] + aCmp[3] + aCmp[4]) )

		If !lFound

			MsgInfo("O Documento de Entrada a que esta carta de correção está vinculada foi excluído do sistema.", "Aviso")

		EndIf

		Define MsDialog oDlgCCe Title "Cartas de Correção" From 0, 0 TO 450, 900 Pixel

			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias(_cTab3)
			oBrowse:SetMenuDef("")
			oBrowse:SetOwner(oDLgCCe)
			oBrowse:SetDescription("Cartas de Correção")
			oBrowse:DisableReport()
			//oBrowse:DisableSeek()
			oBrowse:DisableConfig()
			oBrowse:DisableDetails()
			oBrowse:DisableFilter()
			oBrowse:ForceQuitButton()
			oBrowse:SetWalkThru(.F.)
			oBrowse:SetAmbiente(.F.)
			oBrowse:SetFixedBrowse(.T.)

			oBrowse:SetFilterDefault(_cTab3+"->"+_cCmp3+"_FILIAL == '" + xFilial(_cTab3) + "' .And. "+_cTab3+"->"+_cCmp3+"_DOC    == '" + aCmp[1] + "' .And. " +;
									 _cTab3+"->"+_cCmp3+"_SERIE  == '" + aCmp[2] + "'        .And. "+_cTab3+"->"+_cCmp3+"_FORNEC == '" + aCmp[3] + "' .And. " +;
									 _cTab3+"->"+_cCmp3+"_LOJA   == '" + aCmp[4] + "'")

			oBrowse:AddButton("&Visualizar Correção", "StaticCall(SMS001, ExibeCorr)",, 4, 0)
			oBrowse:Activate()

		Activate MsDialog oDlgCCe Centered

	Else

		MsgStop("Não há Cartas de Correção para o Documento de Entrada selecionado.")

	EndIf

	If !Empty(aRotinaBkp)
		aRotina := aRotinaBkp
	EndIf

Return

//////////////////////////////

Static Function ExibeCorr()
Local oDlgCorr
Local oForm
Local cEnchOld := GetMv("MV_ENCHOLD")

	Define MsDialog oDlgCorr Title "Correção" From 0, 0 TO 400, 600 Pixel

		RegToMemory(_cTab3)

		PutMv("MV_ENCHOLD", "2")

		oForm := MsMGet():New(_cTab3,, MODEL_OPERATION_UPDATE,,,, {_cCmp3+"_DSEVTO", _cCmp3+"_CORREC", _cCmp3+"_CONUSO", "NOUSER"}, {0, 0, 0, 0}, {_cCmp3+"_DSEVTO", _cCmp3+"_CORREC", "ZI_CONDUSO"},;
				   ,,,, oDlgCorr,,.T.,.T.,,.T.,,,,,,,.F.)

		PutMv("MV_ENCHOLD", cEnchOld)

		oForm:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oDlgCorr Centered On Init EnchoiceBar(oDlgCorr, {|| oDlgCorr:End()}, {|| oDlgCorr:End()},,)

Return


///////////////////////////////////
Static Function AddErroXml(cArquivo, cMsg, nTab)
Default nTab := 2

	dbSelectArea(_cTab4)
	(_cTab4)->( dbSetOrder(1) )
	If (_cTab4)->( dbSeek(PadR(Lower(cArquivo), 140)) )

		RecLock(_cTab4, .F.)
		(_cTab4)->&(_cCmp4+"_MSG") += cMsg
		(_cTab4)->( MsUnlock() )

	Else

		RecLock(_cTab4, .T.)
		(_cTab4)->&(_cCmp4+"_SIT") := 2
		(_cTab4)->&(_cCmp4+"_ARQ") := PadR(Lower(cArquivo), 140)
		(_cTab4)->&(_cCmp4+"_MSG") := cMsg
		(_cTab4)->( MsUnlock() )

	EndIf

	lVldErro := .T.
Return

///////////////////////////////////////

User Function SMSDSEMIT()

	dbSelectArea("SA2")
	SA2->( dbSetOrder(3) )
	If U_SMS01CGC((_cTab1)->&(_cCmp1+"_CGCEMI"))//SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1+"_CGCEMI")) )
		Return SA2->A2_NOME
	Else
		dbSelectArea("SA1")
		SA1->( dbSetOrder(3) )
		If SA1->( dbSeek(xFilial("SA1") + (_cTab1)->&(_cCmp1+"_CGCEMI")) )
			Return SA1->A1_NOME
		EndIf
	EndIf

Return ""

//////////////////////////////////////

Static Function CBoxInfo(cNmFld, cValue, nInfoType)
Local cAux
Default nInfoType := 2
cAux := StrTokArr(GetSX3Cache(cNmFld, "X3_CBOX"), ';')[Val(cValue)]
Return If(!Empty(cAux), StrTokArr(cAux, "=")[nInfoType], "")

//////////////////////////////////////

Static Function RetCF(cTes, cEstado)
Return IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + Substr(Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_CF"), 2, 3)

//////////////////////////////////////

Static Function RetCst(cTes, cProduto)

Local _cCodCst 	:= space(03)
Local _cStTes	:= Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_SITTRIB")
Local _cStProd	:= Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_ORIGEM")

_cCodCst := _cStProd + _cStTes

Return(_cCodCst)

///////////////////////////////////////////////
Static Function ExibeErro()

	If !(_cTab1)->(Eof()) .And. (_cTab1)->&(_cCmp1+"_SIT") # "3"
		MsgInfo("Para mostrar um erro, selecione um Xml com problemas de importação.")
		Return
	EndIf
	ExibeInfo(_cCmp1+"_ERRO")

Return

///////////////////////////////////////////////
Static Function MontaErro(aErro)
Local nI
Local cMsg := ""

	For nI := 1 To Len(aErro)
		cMsg += aErro[nI] + CRLF
	Next

Return cMsg

////////////////////////////////////////////////

Static Function AjustaSX6()
Local aSX6    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lInclui := .F.

	aEstrut:= { "X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1",;
				"X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2", "X6_CONTEUD","X6_CONTSPA", "X6_CONTENG",;
				"X6_PROPRI", "X6_PYME"}

	AAdd(aSX6,{cFil,;											  //Filial
			"MV_XSMS001",;										  //Var
			"C",;                 								  //Tipo
			"Local onde os XML que chegarem a empresa devem ser",;//Descric
			"Local onde os XML que chegarem a empresa devem ser",;//DscSpa
			"Local onde os XML que chegarem a empresa devem ser",;//DscEng
			" armazenados.",;									  //Desc1
			" armazenados.",;									  //DscSpa1
			" armazenados.",;									  //DscEng1
			"",;												  //Desc2
			"",;												  //DscSpa2
			"",;												  //DscEng2
			"",;												  //Conteud
			"",;												  //ContSpa
			"",;												  //ContEng
			"U",;												  //Propri
			"S"})

	AAdd(aSX6,{cFil,;										  //Filial
			"MV_XSMS002",;									  //Var
			"C",;                 							  //Tipo
			"Local aonde os XML ja importados serao salvos.",;//Descric
			"Local aonde os XML ja importados serao salvos.",;//DscSpa
			"Local aonde os XML ja importados serao salvos.",;//DscEng
			"",;											  //Desc1
			"",;											  //DscSpa1
			"",;											  //DscEng1
			"",;											  //Desc2
			"",;											  //DscSpa2
			"",;											  //DscEng2
			"",;											  //Conteud
			"",;											  //ContSpa
			"",;											  //ContEng
			"U",;											  //Propri
			"S"})

	AAdd(aSX6,{cFil,;										  //Filial
			"MV_XSMS003",;									  //Var
			"N",;                 							  //Tipo
			"Indica o intervalo em segundos da leitura dos arqu",;//Descric
			"Indica o intervalo em segundos da leitura dos arqu",;//DscSpa
			"Indica o intervalo em segundos da leitura dos arqu",;//DscEng
			"ivos no diretorio de entrada",;				  //Desc1
			"ivos no diretorio de entrada",;				  //DscSpa1
			"ivos no diretorio de entrada",;				  //DscEng1
			"",;											  //Desc2
			"",;											  //DscSpa2
			"",;											  //DscEng2
			"10",;											  //Conteud
			"10",;											  //ContSpa
			"10",;											  //ContEng
			"U",;											  //Propri
			"S"})

	AAdd(aSX6,{cFil,;											  //Filial
			"MV_XSMS004",;										  //Var
			"L",;                 								  //Tipo
			"Marque esta opcao para na efetivacao da importacao",;//Descric
			"Marque esta opcao para na efetivacao da importacao",;//DscSpa
			"Marque esta opcao para na efetivacao da importacao",;//DscEng
			" da NFe mostre a tela de Documento de Entrada para",;//Desc1
			" da NFe mostre a tela de Documento de Entrada para",;//DscSpa1
			" da NFe mostre a tela de Documento de Entrada para",;//DscEng1
			" conferencia de como o Documento sera implantado. ",;//Desc2
			" conferencia de como o Documento sera implantado. ",;//DscSpa2
			" conferencia de como o Documento sera implantado. ",;//DscEng2
			".T.",;												  //Conteud
			".T.",;												  //ContSpa
			".T.",;												  //ContEng
			"U",;												  //Propri
			"S"})												  //Pyme

	AAdd(aSX6,{cFil,;										  //Filial
			"MV_XSMS005",;									  //Var
			"N",;                 							  //Tipo
			"Indica o tamanho do numero do documento de entrada",;				  //Descric
			"Indica o tamanho do numero do documento de entrada",;				  //DscSpa
			"Indica o tamanho do numero do documento de entrada",;				  //DscEng
			"",;											  //Desc1
			"",;											  //DscSpa1
			"",;											  //DscEng1
			"",;											  //Desc2
			"",;											  //DscSpa2
			"",;											  //DscEng2
			"9",;											  //Conteud
			"9",;											  //ContSpa
			"9",;											  //ContEng
			"U",;											  //Propri
			"S"})

	AAdd(aSX6,{cFil,;										  //Filial
			"MV_XSMS006",;									  //Var
			"C",;                 							  //Tipo
			"Local onde os XML processados serao salvos.",;   //Descric
			"Local onde os XML processados serao salvos.",;   //DscSpa
			"Local onde os XML processados serao salvos.",;   //DscEng
			"",;											  //Desc1
			"",;											  //DscSpa1
			"",;											  //DscEng1
			"",;											  //Desc2
			"",;											  //DscSpa2
			"",;											  //DscEng2
			"",;											  //Conteud
			"",;											  //ContSpa
			"",;											  //ContEng
			"U",;											  //Propri
			"S"})

	AAdd(aSX6,{cFil,;										  //Filial
			"MV_XSMS007",;									  //Var
			"L",;                 							  //Tipo
			"Define se será apresentado o botao de parametros",;   //Descric
			"Define se será apresentado o botao de parametros",;   //DscSpa
			"Define se será apresentado o botao de parametros",;   //DscEng
			"",;											  //Desc1
			"",;											  //DscSpa1
			"",;											  //DscEng1
			"",;											  //Desc2
			"",;											  //DscSpa2
			"",;											  //DscEng2
			".T.",;											  //Conteud
			".T.",;											  //ContSpa
			".T.",;											  //ContEng
			"U",;											  //Propri
			"S"})

	AAdd(aSX6,{cFil,;										  //Filial
			"MV_XSMS008",;									  //Var
			"L",;                 							  //Tipo
			"Considera estado do fornecedor do CTE           ",;   //Descric
			"Considera estado do fornecedor do CTE           ",;   //DscSpa
			"Considera estado do fornecedor do CTE           ",;   //DscEng
			"",;											  //Desc1
			"",;											  //DscSpa1
			"",;											  //DscEng1
			"",;											  //Desc2
			"",;											  //DscSpa2
			"",;											  //DscEng2
			".F.",;											  //Conteud
			".F.",;											  //ContSpa
			".F.",;											  //ContEng
			"U",;											  //Propri
			"S"})

	AAdd(aSX6,{cFil,;										  //Filial
			"MV_XSMS009",;									  //Var
			"L",;                 							  //Tipo
			"Na importacao valida a existencia do            ",;   //Descric
			"Na importacao valida a existencia do            ",;   //DscSpa
			"Na importacao valida a existencia do            ",;   //DscEng
			"pedido de compras",;							  //Desc1
			"pedido de compras",;							  //DscSpa1
			"pedido de compras",;							  //DscEng1
			"",;											  //Desc2
			"",;											  //DscSpa2
			"",;											  //DscEng2
			".F.",;											  //Conteud
			".F.",;											  //ContSpa
			".F.",;											  //ContEng
			"U",;											  //Propri
			"S"})


	dbSelectArea("SX6")
	SX6->( dbSetOrder(1) )

	For i := 1 To Len(aSX6)
		If !SX6->( dbSeek(cFil + aSX6[i, 2]) )

			RecLock("SX6", .T.)
			For j := 1 To Len(aSX6[i])
				If FieldPos(aEstrut[j]) > 0
					FieldPut(FieldPos(aEstrut[j]), aSX6[i,j])
				EndIf
			Next j
			MsUnLock()

		EndIf
	Next i

Return



//////////////////////////////////////////
/*User Function MT103CWH()
Local aCmp := aClone(PARAMIXB)

	If IsInCallStack("U_SMS001") .And. AllTrim(aCmp[1]) $ "F1_TIPO/F1_FORMUL/F1_DOC/F1_SERIE/F1_FORNECE/F1_LOJA/F1_EMISSAO/F1_ESPECIE/F1_EST"
		Return .F.
	EndIf

Return .T.*/


User Function SMSRet(cAlias, nReg, nOpcx)

	If Inclui

		If Empty(cEspNFe)
			MsgInfo("Espécie do Documento deve ser informada.", "Aviso")
			Return .F.
		EndIf

		dbSelectArea("SA2")
		SA2->( dbSetOrder(3) )
		If !SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1+"_CGCEMI")) )
			MsgStop("Só é permitido retorno para fornecedores.", "Aviso")
			Return .F.
		EndIf

		GT103Dev(cAlias, nReg, nOpcx)

		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1+"_DOC") + (_cTab1)->&(_cCmp1+"_SERIE") + (_cTab1)->&(_cCmp1+"_CODEMI") + (_cTab1)->&(_cCmp1+"_LOJEMI")) )

			RecLock(_cTab1, .F.)
			(_cTab1)->&(_cCmp1+"_SIT")    := "2"
			(_cTab1)->&(_cCmp1+"_ERRO")   := ""
			(_cTab1)->&(_cCmp1+"_ESPECI") := cEspNFe
			(_cTab1)->&(_cCmp1+"_TIPOEN") := SF1->F1_TIPO
			(_cTab1)->&(_cCmp1+"_DTIMP")  := dDataBase
			(_cTab1)->&(_cCmp1+"_HRIMP")  := Time()
			(_cTab1)->&(_cCmp1+"_USUIMP") := cUserName
			(_cTab1)->( MSUnlock() )
			MsgInfo("Inclusão realizada com sucesso.")

		EndIf
	EndIf

Return .T.

Static Function GT103Dev(cAlias, nReg, nOpcx)

Local _aCampoSX3 := {}
Local _cCampoSX3 := ""
Local _nX        := 0

Local oDlgEsp
Local oLbx
Local lCliente  := .F.
Local aRotina   := {{"&Retornar","U_SMS103DvF(cNomeCdx),U_SMS103PrD",0,4}} //"Retornar"
Local nOpca     := 0
Local aHSF2     := {}
Local aSF2      := {}
Local aCpoSF2   := {}
Local dDataDe   := CToD('  /  /  ')
Local dDataAte  := CToD('  /  /  ')
Local nCnt      := 0
Local nPosDoc   := 0
Local nPosSerie := 0
Local cDocSF2   := ''
Local cIndex    := ''
Local cQuery    := ''
Local cCampos   := ''
Local lMT103CAM	:= Existblock("MT103CAM")
Local lFilCliFor:= .T.
Local lAllCliFor:= .T.
Local lFlagDev	:= SF2->(FieldPos("F2_FLAGDEV")) > 0 .And. GetNewPar("MV_FLAGDEV",.F.)
Local aSize		:= {}

Private cCliente := CriaVar("F2_CLIENTE",.F.)
Private cLoja    := CriaVar("F2_LOJA",.F.)
Private cQrDvF2  := ""


	SF2->(dbSetOrder(1))
	If Inclui
		//-- Valida filtro de retorno de doctos fiscais.
		If GT103FRet(@lCliente,@dDataDe,@dDataAte,@lFilCliFor,@lAllCliFor)
			If lCliente
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ P.E. Utilizado para adicionar novos campos na GetDados       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If lMT103CAM
			    	cCampos := ExecBlock("MT103CAM",.F.,.F.)
			    EndIf
				Aadd( aHSF2, ' ' )

				_aCampoSX3 := U_XAGSX3("SF2", "F2_DOC|F2_SERIE|" + cCampos)

				For _nX := 1 To Len(_aCampoSX3)

					_cCampoSX3 := _aCampoSX3[_nX]

				    If (GetSX3Cache(_cCampoSX3, "X3_BROWSE") == "S")
						Aadd( aHSF2, GetSX3Cache(_cCampoSX3, "X3_TITULO"))
						Aadd( aCpoSF2, _cCampoSX3)

						If AllTrim(_cCampoSX3) == 'F2_DOC'
							nPosDoc := Len(aHSF2)
						ElseIf AllTrim(_cCampoSX3) == 'F2_SERIE'
							nPosSerie := Len(aHSF2)
						EndIf
					EndIf
				End
				//-- Retorna as notas que atendem o filtro.
				aSF2 := GT103RetNF(aCpoSF2,dDataDe,dDataAte,lFilCliFor,lAllCliFor)
				If !Empty(aSF2)
					aSize := {00,12,300,610}
					DEFINE MSDIALOG oDlgEsp TITLE "Retorno de Doctos. de Saída" FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL
					oLbx:= TWBrowse():New( aSize[1], (aSize[2]-12), aSize[3], (aSize[4]-470), NIL, ;
						aHSF2, NIL, oDlgEsp, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
					oLbx:SetArray( aSF2 )
					oLbx:bLDblClick  := { || { aSF2[oLbx:nAT,1] := !aSF2[oLbx:nAT,1] }}
					oLbx:bLine := &('{ || U_SMS103Lin(oLbx:nAT,aSF2) }')
					ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpca := 1, oDlgEsp:End()},{||oDlgEsp:End()}) CENTERED
					//-- Processa Devolucao
					If nOpca == 1
						ASort( aSF2,,,{|x,y| x[1] > y[1] })
						For nCnt := 1 To Len(aSF2)
							If !aSF2[nCnt,1]
								Exit
							EndIf
							#IFDEF TOP
								cDocSF2 += IIF(Len(cDocSF2)>0,",","")+"'"+aSF2[nCnt,nPosDoc]+aSF2[nCnt,nPosSerie]+"'"
							#ELSE
								cDocSF2 += "( SD2->D2_DOC == '" + aSF2[nCnt,nPosDoc] + "' .And. SD2->D2_SERIE == '" + aSF2[nCnt,nPosSerie] + "' ) .Or. "
							#ENDIF
						Next nCnt
						If !Empty(cDocSF2)
							#IFDEF TOP
								cDocSF2 := "("+Subs(cDocSF2,1,Len(cDocSF2))+")"
							#ELSE
								cDocSF2 := SubStr(cDocSF2,1,Len(cDocSF2)-5) + " )"
							#ENDIF
						EndIf
						U_SMS103PrD(cAlias,nReg,nOpcx,lCliente,cCliente,cLoja,cDocSF2)
					EndIf
				EndIf
			Else
				DbSelectArea("SF2")
				cIndex := CriaTrab(NIL,.F.)

	   			If ExistBlock("MT103RET")//Ponto de entrada para complemento de filtro na query
	       		   cQuery := ExecBlock("MT103RET",.F.,.F.,{dDataDe,dDataAte})
	            Else
			       cQuery := "F2_FILIAL == '" + xFilial("SF2") + "' "
			  	   cQuery += ".AND. F2_TIPO <> 'D' "

	               If !lAllCliFor
					   If lFilCliFor
					  	   	cQuery += ".And. F2_TIPO <> 'B' "
		               Else
					  	   	cQuery += ".And. F2_TIPO <> 'N' "
		               EndIf
	               EndIf

				   If !Empty(cCliente)
				      cQuery += " .And. F2_CLIENTE == '" + cCliente + "' "
				   EndIf
				   If !Empty(cLoja)
					  cQuery += " .And. F2_LOJA    == '" + cLoja    + "' "
				   EndIf
				   If !Empty(dDataDe)
					  cQuery += " .And. DtoS(F2_EMISSAO) >= '" + DtoS(dDataDe)  + "'"
				   EndIf
				   If !Empty(dDataAte)
					  cQuery += " .And. DtoS(F2_EMISSAO) <= '" + DtoS(dDataAte) + "' "
				   EndIf
				   If lFlagDev
					   cQuery += " .And. F2_FLAGDEV <> '1' "
				   Endif
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para passar por parametro as informacoes na MaWndBrowse³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRotina[1,2] :=	 StrTran(aRotina[1,2],"cNomeCdx","'" + cIndex + "'")
	   			cQrDvF2 := cQuery

				IndRegua("SF2",cIndex,SF2->(IndexKey()),,cQuery)
				If SF2->(!Eof())
					MaWndBrowse(0,0,300,600, "Retorno de Doctos. de Saída","SF2",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
				EndIf
				RetIndex( "SF2" )
				FErase( cIndex+OrdBagExt() )
			EndIf
		EndIf
	EndIf

	Inclui := !Inclui

Return .T.

Static Function GT103FRet(lCliFor,dDataDe,dDataAte,lFilCliFor,lAllCliFor)
Local oDlgEsp
Local oCliente
Local oFornece
Local oDocto
Local lDocto     := .T.
Local nOpcao     := 0
Local aSize      := MsAdvSize(.F.)
Private cCodCli  := CriaVar("F2_CLIENTE",.F.)
Private cLojCli  := CriaVar("F2_LOJA",.F.)
Private cCodFor  := (_cTab1)->&(_cCmp1+"_CODEMI")
Private cLojFor  := (_cTab1)->&(_cCmp1+"_LOJEMI")

	DEFINE MSDIALOG oDlgEsp From aSize[7],0 To aSize[6]/1.5,aSize[5]/1.5 OF oMainWnd PIXEL TITLE "Retorno de Doctos. de Saída"

	@ 06,005 SAY RetTitle("F1_FORNECE") PIXEL
	@ 05,040 MSGET cCodFor F3 'FOR' SIZE 95, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA2',cCodFor+AllTrim(cLojFor),1) READONLY
	@ 06,145 SAY RetTitle("F1_LOJA") PIXEL
	@ 05,160 MSGET cLojFor SIZE 20, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA2',cCodFor+AllTrim(cLojFor),1) READONLY
	@ 36,05 SAY "Data de" PIXEL
	@ 35,40 MSGET dDataDe PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL
	@ 36,120 SAY "Data até" PIXEL
	@ 35,160 MSGET dDataAte PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL
	@ 060,005 TO __DlgHeight(oDlgEsp)-045,__DlgWidth(oDlgEsp)-5 LABEL "Tipo de Seleção" OF oDlgEsp PIXEL
	@ 85,010 CHECKBOX oCliente VAR lCliFor PROMPT AllTrim(RetTitle("F1_FORNECE")) SIZE 100,010 ON CLICK( lDocto := .F., oDocto:Refresh() ) OF oDlgEsp PIXEL
	@ 85,__DlgWidth(oDlgEsp)-60 CHECKBOX oDocto VAR lDocto PROMPT "Documento" SIZE 50,010 ON CLICK( lCliFor := .F., oCliente:Refresh() ) OF oDlgEsp PIXEL

	DEFINE SBUTTON FROM 05,__DlgWidth(oDlgEsp)-50 TYPE 1 OF oDlgEsp ENABLE PIXEL ACTION ;
	Eval({||cCliente := IIF(Empty(cCodCli),cCodFor,cCodCli),;
	cLoja := IIF(Empty(cLojCli),cLojFor,cLojCli),;
	IIF(Empty(cCliente).And.Empty(cLoja),lAllCliFor:=.T.,lAllCliFor:=.F.),;
	IIF(!Empty(cCodCli),lFilCliFor:=.T.,lFilCliFor:=.F.),.t.});
	.and.If((!Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(dDataDe) .And. !Empty(dDataAte) .And. lCliFor) .Or.;
	lDocto,(nOpcao := 1,oDlgEsp:End()),.F.)

	DEFINE SBUTTON FROM 20,__DlgWidth(oDlgEsp)-50 TYPE 2 OF oDlgEsp ENABLE PIXEL ACTION (nOpcao := 0,oDlgEsp:End())

	ACTIVATE MSDIALOG oDlgEsp CENTERED

Return ( nOpcao == 1 )



Static Function GT103RetNF(aCpoSF2,dDataDe,dDataAte,lFilCliFor,lAllCliFor)

	Local aSF2      := {}
	Local aAux      := {}
	Local nCnt      := 0
	Local cAliasSF2 := 'SF2'
	Local cQuery    := ''
	Local cIndex    := ''
	Local nIndexSF2 := 0
	Local lFlagDev	:= SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)

	#IFDEF TOP
		cAliasSF2 := GetNextAlias()
		If ExistBlock("MT103DEV")//Ponto de entrada para complemento de filtro na query
	       cQuery := ExecBlock("MT103DEV",.F.,.F.,{dDataDe,dDataAte})
	    Else
		   cQuery := " SELECT * "
		   cQuery += "   FROM " + RetSqlName("SF2")
		   cQuery += "   WHERE F2_FILIAL  = '" + xFilial("SF2") + "' "
		   cQuery += "     AND F2_TIPO <> 'D' "

	       If !lAllCliFor
		       If lFilCliFor
		          cQuery += " AND F2_TIPO <> 'B' "
		       Else
		          cQuery += " AND F2_TIPO <> 'N' "
		       EndIf
	       EndIf

		   cQuery += "     AND F2_CLIENTE = '" + cCliente + "' "
		   cQuery += "     AND F2_LOJA    = '" + cLoja    + "' "
		   cQuery += "     AND F2_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
		   If lFlagDev
			   cQuery += "     AND F2_FLAGDEV <> '1' "
		   Endif
		   cQuery += "     AND D_E_L_E_T_ = ' ' "
		   cQuery += "     ORDER BY F2_FILIAL,F2_DOC,F2_SERIE "
		EndIf
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSF2, .F., .T. )
	#ELSE
		DbSelectArea("SF2")
		cIndex := CriaTrab(NIL,.F.)
		If ExistBlock("MT103DEV")//Ponto de entrada para complemento de filtro na query
	       cQuery := ExecBlock("MT103DEV",.F.,.F.,{dDataDe,dDataAte})
	    Else
		   cQuery := " F2_FILIAL == '" + xFilial("SF2") + "' "
		   cQuery += " .And. F2_TIPO <> 'D' "

	       If !lAllCliFor
		       If lFilCliFor
		          cQuery += ".And. F2_TIPO <> 'B' "
		       Else
		          cQuery += ".And. F2_TIPO <> 'N' "
		       EndIf
	       EndIf

		   cQuery += " .And. F2_CLIENTE == '" + cCliente + "' "
		   cQuery += " .And. F2_LOJA    == '" + cLoja    + "' "
		   cQuery += " .And. DtoS(F2_EMISSAO) >= '" + DtoS(dDataDe)  + "'"
		   cQuery += " .And. DtoS(F2_EMISSAO) <= '" + DtoS(dDataAte) + "' "
		   If lFlagDev
			   cQuery += " .And. F2_FLAGDEV <> '1' "
		   Endif
		EndIf
		IndRegua("SF2",cIndex,"F2_FILIAL+F2_DOC+F2_SERIE",,cQuery)
		SF2->(DbGotop())
	#ENDIF

	While (cAliasSF2)->(!Eof())
		aAux := {}
		Aadd( aAux, .F. )
		For nCnt := 1 To Len(aCpoSF2)
			Aadd( aAux, &(aCpoSF2[nCnt]) )
		Next nCnt
		aAdd( aSF2, aClone(aAux) )
		(cAliasSF2)->(DbSkip())
	EndDo

	#IFDEF TOP
		(cAliasSF2)->(DbCloseArea())
	#ELSE
		RetIndex( "SF2" )
		FErase( cIndex+OrdBagExt() )
	#ENDIF

Return aSF2

User Function SMS103Line(nAT,aSF2)

	Static oNoMarked := LoadBitmap( GetResources(),'LBNO'			)
	Static oMarked	  := LoadBitmap( GetResources(),'LBOK'			)
	Local abLine     := {}
	Local nCnt       := 0

	For nCnt := 1 To Len(aSF2[nAT])
		If nCnt == 1
			Aadd( abLine, Iif(aSF2[ nAT, nCnt ] , oMarked, oNoMarked ) )
		Else
			Aadd( abLine, aSF2[ nAT, nCnt ] )
		EndIf
	Next nCnt

Return abLine

User Function SMS103PrD(cAlias,nReg,nOpcx,lCliente,cCliente,cLoja,cDocSF2)
Local aArea     := GetArea()
Local aAreaSF2  := SF2->(GetArea())
Local aCab      := {}
Local aLinha    := {}
Local aItens    := {}
Local cTipoNF   := ""
Local lDevolucao:= .T.
Local lPoder3   := .T.
Local aHlpP		:=	{}
Local aHlpE		:=	{}
Local aHlpS		:=	{}
Local lFlagDev	:= SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)
Local cIndex	:= ""
Local lRestDev	:= .T.
Local nPFreteI  := 0
Local nPFreteC  := 0
Local nPSegurI  := 0
Local nPSegurC  := 0
Local nPDespI   := 0
Local nPDespC   := 0
Local nX        := 0
Local cMvNFEAval :=	GetNewPar( "MV_NFEAFSD", "000" )
Local nHpP3     := 0

Default lCliente := .F.
Default cCliente := SF2->F2_CLIENTE
Default cLoja    := SF2->F2_LOJA
Default cDocSF2  := ''
Default	cQrDvF2  := ''

	If Type("cTipo") == "U"
		PRIVATE cTipo:= ""
	EndIf

	If Empty(cQrDvF2)
		cQrDvF2 := "F2_FILIAL == '" + xFilial("SF2") + "' "
		cQrDvF2 += ".AND. F2_TIPO <> 'D' "
	Endif

	If !SF2->(Eof())

		lDevolucao := GT103FilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,,@nHpP3)

		If lDevolucao .and. Len(aItens)>0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			AAdd( aCab, { "F1_DOC"    , (_cTab1)->&(_cCmp1+"_DOC")    , Nil } )	// Numero da NF : Obrigatorio
			AAdd( aCab, { "F1_SERIE"  , (_cTab1)->&(_cCmp1+"_SERIE")  , Nil } )	// Serie da NF  : Obrigatorio

			If !lPoder3
				AAdd( aCab, { "F1_TIPO"   , "D"                  		, Nil } )	// Tipo da NF   : Obrigatorio
			Else
				AAdd( aCab, { "F1_TIPO"   , IIF(cTipoNF=="B","N","B")	, Nil } )	// Tipo da NF   : Obrigatorio
			EndIf

			AAdd( aCab, { "F1_FORNECE", cCliente    				, Nil } )	// Codigo do Fornecedor : Obrigatorio
			AAdd( aCab, { "F1_LOJA"   , cLoja    	   		   	    , Nil } )	// Loja do Fornecedor   : Obrigatorio
			AAdd( aCab, { "F1_EMISSAO", dDataBase           		, Nil } )	// Emissao da NF        : Obrigatorio
			AAdd( aCab, { "F1_FORMUL" , "N"                 		, Nil } )  // Formulario
			AAdd( aCab, { "F1_ESPECIE", cEspNFe } )  // Especie
			AAdd( aCab, { "F1_FRETE",0,Nil})
			AAdd( aCab, { "F1_SEGURO",0,Nil})
			AAdd( aCab, { "F1_DESPESA",0,Nil})
			AAdd( aCab, { "F1_CHVNFE", (_cTab1)->&(_cCmp1+"_CHAVE"), Nil})

	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Agrega o Frete/Desp/Seguro  referente a NF Retornada  ³
			//| de acordo com o parametro MV_NFEAFSD 				  ³
			//ÀÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPFreteC := aScan(aCab,{|x| AllTrim(x[1])=="F1_FRETE"})
			nPFreteI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_VALFRE"})
	   		nPSegurC := aScan(aCab,{|x| AllTrim(x[1])=="F1_SEGURO"})
			nPSegurI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_SEGURO"})
	   		nPDespC := aScan(aCab,{|x| AllTrim(x[1])=="F1_DESPESA"})
			nPDespI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_DESPESA"})

			For nX = 1 to Len(aItens)
			    If len(cMvNFEAval)>=1
			        If Substr(cMvNFEAval,1,1)=="1"
	  		   			aCab[nPFreteC][2] := aCab[nPFreteC][2] + aItens[nX][nPFreteI][2]
	  		  	    EndIf
	  		  	EndIf
	  		  	If len(cMvNFEAval)>=2
			        If Substr(cMvNFEAval,2,1)=="1"
	  		    		aCab[nPSegurC][2] := aCab[nPSegurC][2] + aItens[nX][nPSegurI][2]
	  		  	    EndIf
	  		  	EndIf
	   		  	If len(cMvNFEAval)=3
			        If Substr(cMvNFEAval,3,1)=="1"
	  		    		aCab[nPDespC][2] := aCab[nPDespC][2] + aItens[nX][nPDespI][2]
	  		  	    EndIf
	  		  	EndIf
			Next nX

			MsExecAuto({|x,y,z,w| Mata103(x,y,z,w)}, aCab, aItens, 3, lConfere)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se nao ha mais saldo para devolucao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFlagDev
				lRestDev := GT103FilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)
				If !lRestDev
					RecLock("SF2",.F.)
					SF2->F2_FLAGDEV := "1"
					MsUnLock()
				Endif
			Endif
		Else
			aHlpP	:=	{}
			aHlpE	:=	{}
			aHlpS	:=	{}
			aAdd (aHlpP, "Nota Fiscal de Devolução já gerada ou o")
			aAdd (aHlpP, "saldo devedor em poder de terceiro está")
			aAdd (aHlpP, "zerado.")
			aAdd (aHlpE, "Nota Fiscal de Devolução já gerada ou o")
			aAdd (aHlpE, "saldo devedor em poder de terceiro está")
			aAdd (aHlpE, "zerado.")
			aAdd (aHlpS, "Nota Fiscal de Devolução já gerada ou o")
			aAdd (aHlpS, "saldo devedor em poder de terceiro está")
			aAdd (aHlpS, "zerado.")
			PutHelp ("PNFDGSPTZ", aHlpP, aHlpE, aHlpS, .F.)
			//
			aHlpP	:=	{}
			aHlpE	:=	{}
			aHlpS	:=	{}
			aAdd (aHlpP, "É necessário excluir a NFcorrespondente")
			aAdd (aHlpP, "para gerar a devolução novamente ou o")
			aAdd (aHlpP, "saldo devedor em poder de terceiro está")
			aAdd (aHlpP, "zerado para o item.")
			aAdd (aHlpE, "É necessário excluir a NFcorrespondente")
			aAdd (aHlpE, "para gerar a devolução novamente ou o")
			aAdd (aHlpE, "saldo devedor em poder de terceiro está")
			aAdd (aHlpE, "zerado para o item.")
			aAdd (aHlpS, "É necessário excluir a NFcorrespondente")
			aAdd (aHlpS, "para gerar a devolução novamente ou o")
			aAdd (aHlpS, "saldo devedor em poder de terceiro está")
			aAdd (aHlpS, "zerado para o item.")
			PutHelp ("SNFDGSPTZ", aHlpP, aHlpE, aHlpS, .F.)

			/*
			nHpP3 = Situacao 0 -> Mostra a mensagem
			nHpP3 = Situacao 1 -> Nao mostra a mensagem
			*/
			If (nHpP3 == 0) .And. lPoder3
				Help(" ",1,"NFDGSPTZ")	//Nota Fiscal de Devolução já gerada ou o saldo devedor em poder de terceiro está zerado.
			EndIf
		EndIf

		MsUnLockAll()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Refaz o filtro quando a selecao e por documento, visto que a tela com os³
		//³documentos que podem ser devolvidos e montada novamente.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lCliente
			DbSelectArea("SF2")
			SF2->(dbSetOrder(1))
			cIndex := CriaTrab(NIL,.F.)
			IndRegua("SF2",cIndex,SF2->(IndexKey()),,cQrDvF2)
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a entrada da rotina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aAreaSF2)
	RestArea(aArea)
Return(.T.)

User Function SMS103DvF(cIndex)

	Local nRecSF2 := SF2->(Recno())
	RetIndex("SF2")
	FErase(cIndex+OrdBagExt())

	SF2->(MsGoto(nRecSF2))

Return

Static Function SMS103FilDv(aLinha,aItens,cDocSF2,cCliente,cLoja,lCliente,cTipoNF,lPoder3,lHelp,nHpP3)

Local cAliasSD2 := "SD2"
Local cAliasSF4 := "SF4"
Local nSldDev   := 0
Local nSldDevAux:= 0
Local nDesc     := 0
Local nTotal	:= 0
Local lDevolucao:= .T.
Local lQuery    := .F.
Local lMt103FDV := ExistBlock("MT103FDV")
Local lDevCode	:= .F.
Local cCfop     := ""
Local cFilSX5   := xFilial("SX5")
Local cNFORI  	:= ""
Local cSERIORI	:= ""
Local cITEMORI	:= ""
Local nVlCompl  := 0
Local aAreaAnt  := {}
Local aSaldoTerc:= {}

Local lCompl    := (GetNewPar("MV_RTCOMPL","S") == "S")

Local nTpCtlBN  := If(FindFunction("A410CtEmpBN"), A410CtEmpBN(), If(SD4->(FieldPos("D4_NUMPVBN")) > 0, 1, 0))
Local aAreaAnt	:= GetArea()
Local cNewDSF2	:= ""
Local cDSF2Aux	:= ""
Local nPosDiv	:= 0
Local nX		:= 0
Local nY		:= 0
Local lTravou	:= .F.
Local lExit		:= .F.

	#IFDEF TOP
		Local aStruSD2 := {}
		Local cQuery   := ""
		Local nX       := 0
		Local cAliasCpl := ""
	#ELSE
		Local cIndex   := ""
		Local cIndexCpl:= ""
		Local aAreaSD2 := {}
	#ENDIF

	Default lHelp := .T.

	If !Empty(cDocSF2)												// Selecao foi feita por "Cliente/Fornecedor"
		#IFDEF TOP
			cNewDSF2 := StrTran(StrTran(cDocSF2,"('",),"')",)		// Retira parêteses e aspas da string do documento, caso houver
		#ELSE
			cDSF2Aux := cDocSF2										// Para ambiente diferente de TOP equaliza string que contem as notas a devolver para continuar a validacao de reserva de registro
			For nY := 1 To Len(cDSF2Aux)
				nPosDiv := At("'",cDSF2Aux)
				If nPosDiv > 0
					cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
					nPosDiv := At("'",cDSF2Aux)
					cNewDSF2 += SubStr(cDSF2Aux,1,(nPosDiv-1))					// Numero
					cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
					nPosDiv := At("'",cDSF2Aux)
					cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
					nPosDiv := At("'",cDSF2Aux)
					cNewDSF2 += SubStr(cDSF2Aux,1,(nPosDiv-1))					// Serie
					cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
					nPosDiv := At("'",cDSF2Aux)
					If nPosDiv > 0
						cNewDSF2 += "','"										// Separador entre notas
					Else
						Exit
					EndIf
				EndIf
			Next nY
		#ENDIF
		nPosDiv := At("','",cNewDSF2)								// String ',' identifica que foi selecionada mais de uma nota de saida
		If nPosDiv == 0												// Se foi selecionada apenas uma nota de saida
			DbSelectArea("SF2")
			DbSetOrder(1)
			If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
				lTravou := SoftLock("SF2")							// Tenta reservar o registro para prosseguir com o processo
			Else
				dbGoTop()
			EndIf
		Else														// Se foi selecionada mais de uma nota de saida
			cDSF2Aux := cNewDSF2
			For nX := 1 to Len(cDSF2Aux)
				nPosDiv := At("','",cDSF2Aux)
				If nPosDiv > 0
					cNewDSF2 := SubStr(cDSF2Aux,1,(nPosDiv-1))		// Extrai a primeira nota/serie da string
					cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+3),Len(cDSF2Aux)) // Grava nova string sem a primeira nota/serie
				Else
					cNewDSF2 := cDSF2Aux
					lExit := .T.
				EndIf
				If !Empty(cNewDSF2)
					DbSelectArea("SF2")
					DbSetOrder(1)
					If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
						lTravou := SoftLock("SF2")					// Tenta reservar todos os registros para prosseguir com o processo
					Else
						dbGoTop()
					EndIf
				EndIf
				If lExit
					Exit
				EndIf
			Next nX
		EndIf
		RestArea(aAreaAnt)
	Else
		lTravou := SoftLock("SF2")
	EndIf

	If lTravou
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem dos itens da Nota Fiscal de Devolucao/Retorno          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SD2")
		DbSetOrder(3)
		#IFDEF TOP
			lQuery    := .T.
			cAliasSD2 := "Oms320Dev"
			cAliasSF4 := "Oms320Dev"
			aStruSD2  := SD2->(dbStruct())
			cQuery    := "SELECT SF4.F4_CODIGO, SF4.F4_CF, SF4.F4_PODER3, SD2.*, SD2.R_E_C_N_O_ SD2RECNO "
			cQuery    += " FROM "+RetSqlName("SD2")+" SD2,"
			cQuery    += RetSqlName("SF4")+" SF4 "
			cQuery    += " WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
			If !lCliente
				cQuery    += "SD2.D2_DOC   = '"+SF2->F2_DOC+"' AND "
				cQuery    += "SD2.D2_SERIE = '"+SF2->F2_SERIE+"' AND "
			Else
				If !Empty(cDocSF2)
					cQuery += " D2_DOC||D2_SERIE IN "+cDocSF2+" AND "
				EndIf
			EndIf
			cQuery    += " SD2.D2_CLIENTE   = '"+cCliente+"' AND "
			cQuery    += " SD2.D2_LOJA      = '"+cLoja+"' AND "
			cQuery    += " ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
			cQuery    += " (SD2.D2_VALDEV  = 0)) AND "
			cQuery    += " SD2.D_E_L_E_T_  = ' ' AND "
			cQuery    += " SF4.F4_FILIAL   = '"+xFilial("SF4")+"' AND "
			cQuery    += " SF4.F4_CODIGO   = (SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
			cQuery    += " F4_FILIAL	   = '"+xFilial("SF4")+"' AND "
			cQuery    += " F4_CODIGO	   = SD2.D2_TES AND "
			cQuery    += " D_E_L_E_T_	   = ' ' ) AND "
			cQuery    += " SF4.D_E_L_E_T_  = ' ' "
			cQuery    += " ORDER BY "+SqlOrder(SD2->(IndexKey()))

			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

			For nX := 1 To Len(aStruSD2)
				If aStruSD2[nX][2]<>"C"
					TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
				EndIf
			Next nX

			If Eof()
				If lHelp
					Help(" ",1,"DSNOTESDT")
					nHpP3 := 1
				Endif
				lDevolucao := .F.
			EndIf
		#ELSE
			If lCliente
				cIndex := CriaTrab(NIL,.F.)
				cQuery := " SD2->D2_FILIAL == '" + xFilial("SD2") + "' "
				cQuery += " .And. SD2->D2_CLIENTE == '" + cCliente + "' "
				cQuery += " .And. SD2->D2_LOJA    == '" + cLoja    + "' "
				If !Empty(cDocSF2)
					cQuery += " .And. ( "
					cQuery += cDocSF2
				EndIf
				IndRegua("SD2",cIndex,SD2->(IndexKey()),,cQuery)
				nIndex := RetIndex("SD2")
				dbSetIndex(cIndex+OrdBagExt())
				dbSetOrder(nIndex+1)
				SD2->(DbGotop())
			Else
				MsSeek( xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+cCliente+cLoja)
			EndIf
		#ENDIF
		While !Eof() .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And.;
				(cAliasSD2)->D2_CLIENTE 		   == cCliente 		  .And.;
				(cAliasSD2)->D2_LOJA			   == cLoja 		  .And.;
				If(!lCliente,(cAliasSD2)->D2_DOC  == SF2->F2_DOC     .And.;
				(cAliasSD2)->D2_SERIE			   == SF2->F2_SERIE,.T.)

			If ((cAliasSD2)->D2_QTDEDEV < (cAliasSD2)->D2_QUANT) .Or. ((cAliasSD2)->D2_VALDEV == 0)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe um tes de devolucao correspondente           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lQuery
					DbSelectArea("SF4")
					DbSetOrder(1)
					If MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
						If Empty(SF4->F4_TESDV) .Or. !(SF4->(MsSeek(xFilial("SF4")+SF4->F4_TESDV)))
							lDevolucao := .F.
							Exit
						EndIf
						If SF4->F4_PODER3<>"D"
							lPoder3 := .F.
						EndIf
						If lPoder3 .And. !cTipo$"B|N"
							cTipo := IIF(cTipoNF=="B","N","B")
						ElseIf !cTipo$"B|N"
							cTipo := "D"
						EndIf
					EndIf
				Else
					If (cAliasSD2)->F4_PODER3<>"D"
						lPoder3 := .F.
					EndIf
					If lPoder3 .And. !cTipo$"B|N"
						cTipo := IIF(cTipoNF=="B","N","B")
					ElseIf !cTipo$"B|N"
						cTipo := "D"
					EndIf
				EndIf
				If !lMt103FDV .Or. ExecBlock("MT103FDV",.F.,.F.,{cAliasSD2})
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Destroi o Array, o mesmo é carregado novamente pela CalcTerc    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aSaldoTerc)>0
						aSize(aSaldoTerc,0)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula o Saldo a devolver                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cTipoNF := (cAliasSD2)->D2_TIPO

					Do Case
						Case (cAliasSF4)->F4_PODER3=="D"
							aSaldoTerc := CalcTerc((cAliasSD2)->D2_COD,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_IDENTB6,(cAliasSD2)->D2_TES,cTipoNF)
							nSldDev :=iif(Len(aSaldoTerc)>0,aSaldoTerc[1],0)
						Case cTipoNF == "N"
							nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
						OtherWise
							nSldDev := 0
					EndCase

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Efetua a montagem da Linha                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If nSldDev > 0 .Or. (cTipoNF$"CIP" .And. (cAliasSD2)->D2_VALDEV == 0) .Or.;
					   ( (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_VALDEV == 0 .And. (cAliasSD2)->D2_TOTAL > 0 )

						lDevCode := .T.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se deve considerar o preco das notas de complemento    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lCompl
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se existe nota de complemento de preco                 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lQuery
								aAreaAnt  := GetArea()
								cAliasCpl := GetNextAlias()
								cQuery    := "SELECT SUM(SD2.D2_PRCVEN) AS D2_PRCVEN "
								cQuery    += "  FROM "+RetSqlName("SD2")+" SD2 "
								cQuery    += " WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
								cQuery    += "   AND SD2.D2_TIPO    = 'C' "
								cQuery    += "   AND SD2.D2_NFORI   = '"+SF2->F2_DOC+"'"
								cQuery    += "   AND SD2.D2_SERIORI = '"+SF2->F2_SERIE+"'"
								cQuery    += "   AND SD2.D2_ITEMORI = '"+(cAliasSD2)->D2_ITEM +"'"
								cQuery    += "   AND ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
								cQuery    += "       (SD2.D2_VALDEV = 0))"
								cQuery    += "   AND SD2.D2_TES         = '"+(cAliasSD2)->D2_TES+"'"
								cQuery    += "   AND SD2.D_E_L_E_T_     = ' ' "

								cQuery    := ChangeQuery(cQuery)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCpl,.T.,.T.)

								TcSetField(cAliasCpl,"D2_PRCVEN","N",TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2])

								If !(cAliasCpl)->(Eof())
									nVlCompl := (cAliasCpl)->D2_PRCVEN
								Else
									nVlCompl := 0
								EndIf

								(cAliasCpl)->(dbCloseArea())
								RestArea(aAreaAnt)
							Else
								aAreaSD2 := SD2->(GetArea())
								SD2->(dbSetOrder(3))
								cIndexCpl := CriaTrab(NIL,.F.)
								cQuery := "       SD2->D2_FILIAL  == '" + xFilial("SD2") + "' "
								cQuery += " .And. SD2->D2_TIPO    == 'C' "
								cQuery += " .And. SD2->D2_NFORI   == '"+SF2->F2_DOC   +"' "
								cQuery += " .And. SD2->D2_SERIORI == '"+SF2->F2_SERIE +"' "
								cQuery += " .And. AllTrim(SD2->D2_ITEMORI) == '"+(cAliasSD2)->D2_ITEM +"' "
								cQuery += " .And. SD2->D2_TES     == '"+(cAliasSD2)->D2_TES+"' "

								IndRegua("SD2",cIndexCpl,SD2->(IndexKey()),,cQuery)
								SD2->(DbGotop())

								nVlCompl := 0
								While !SD2->(Eof())
									nVlCompl += SD2->D2_PRCVEN
									SD2->(dbSkip())
								EndDo

							    nIndex := RetIndex("SD2")
								FErase( cIndexCpl+OrdBagExt() )

							    If lCliente
									dbSetIndex(cIndex+OrdBagExt())
									dbSetOrder(nIndex+1)
	                            EndIf

								RestArea(aAreaSD2)
							EndIf
						EndIf

						aLinha := {}
						nDesc  := 0
		  				AAdd( aLinha, { "D1_COD"    , (cAliasSD2)->D2_COD    , Nil } )
						AAdd( aLinha, { "D1_QUANT"  , nSldDev, Nil } )
						If (cAliasSD2)->D2_QUANT==nSldDev
							If Len(aSaldoTerc)=0   // Nf sem Controle Poder Terceiros
								If (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
								   	AAdd( aLinha, { "D1_VUNIT"  , (cAliasSD2)->D2_PRCVEN, Nil })
								Else
								    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
									AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_TOTAL+nDesc)/(cAliasSD2)->D2_QUANT, Nil })
								EndIf
							Else                   // Nf com Controle Poder Terceiros
								If (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
									AAdd( aLinha, { "D1_VUNIT"  , (aSaldoTerc[5]-aSaldoTerc[4])/nSldDev, Nil })
								Else
								    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
								    nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
									AAdd( aLinha, { "D1_VUNIT"  , ((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev, Nil })
								EndIf
							EndIf
							nTotal:= A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL")
							If nTotal == 0 .And. (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_PRCVEN == (cAliasSD2)->D2_TOTAL
								nTotal:= (cAliasSD2)->D2_TOTAL
							EndIf
		 					AAdd( aLinha, { "D1_TOTAL"  , nTotal,Nil } )
							AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )
							AAdd( aLinha, { "D1_VALFRE", (cAliasSD2)->D2_VALFRE, Nil } )
							AAdd( aLinha, { "D1_SEGURO", (cAliasSD2)->D2_SEGURO, Nil } )
							AAdd( aLinha, { "D1_DESPESA", (cAliasSD2)->D2_DESPESA, Nil } )
						Else
							nSldDevAux:= (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
							If Len(aSaldoTerc)=0	// Nf sem Controle Poder Terceiros
							    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
							    nDesc:=iif(nDesc>0,(nDesc/(cAliasSD2)->D2_QUANT)*IIf(nSldDevAux==0,1,nSldDevAux),0)
							    AAdd( aLinha, { "D1_VUNIT"  ,((((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR))-(cAliasSD2)->D2_VALDEV)/IIf(nSldDevAux==0,1,nSldDevAux), Nil })
						    Else  					// Nf com Controle Poder Terceiros
							    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
							    nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
								AAdd( aLinha, { "D1_VUNIT"  , ((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev, Nil })
						    EndIf

		 					AAdd( aLinha, { "D1_TOTAL"  , A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL"),Nil } )
							AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )
							AAdd( aLinha, { "D1_VALFRE" , A410Arred(((cAliasSD2)->D2_VALFRE/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_VALFRE"),Nil } )
							AAdd( aLinha, { "D1_SEGURO" , A410Arred(((cAliasSD2)->D2_SEGURO/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_SEGURO"),Nil } )
							AAdd( aLinha, { "D1_DESPESA" , A410Arred(((cAliasSD2)->D2_DESPESA/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_DESPESA"),Nil } )
						EndIf
						AAdd( aLinha, { "D1_IPI"    , (cAliasSD2)->D2_IPI    , Nil } )
						AAdd( aLinha, { "D1_LOCAL"  , (cAliasSD2)->D2_LOCAL  , Nil } )
						AAdd( aLinha, { "D1_TES" 	, (cAliasSF4)->F4_CODIGO , Nil } )
						If ("000"$AllTrim((cAliasSF4)->F4_CF) .Or. "999"$AllTrim((cAliasSF4)->F4_CF))
							cCfop := AllTrim((cAliasSF4)->F4_CF)
						Else
	                        cCfop := SubStr("123",At(SubStr((cAliasSD2)->D2_CF,1,1),"567"),1)+SubStr((cAliasSD2)->D2_CF,2)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se existe CFOP equivalente considerando a CFOP do documento de saida  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							SX5->( dbSetOrder(1) )
							If !SX5->(MsSeek( cFilSX5 + "13" + cCfop ))
								cCfop := AllTrim((cAliasSF4)->F4_CF)
							EndIf
						EndIf
						AAdd( aLinha, { "D1_CF"		, cCfop, Nil } )
						AAdd( aLinha, { "D1_UM"     , (cAliasSD2)->D2_UM , Nil } )
	                    If (nTpCtlBN != 0)
	     					AAdd( aLinha, { "D1_OP" 	, A103OPBen(cAliasSD2, nTpCtlBN) , Nil } )
	                    EndIf

						If Rastro((cAliasSD2)->D2_COD)
							AAdd( aLinha, { "D1_LOTECTL", (cAliasSD2)->D2_LOTECTL, ".T." } )
							If (cAliasSD2)->D2_ORIGLAN == "LO"
								If Rastro((cAliasSD2)->D2_COD,"L") .AND. !Empty((cAliasSD2)->D2_NUMLOTE)
									AAdd( aLinha, { "D1_NUMLOTE", Nil , ".T." } )
								Else
									AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )
								EndIf
							Else
								AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )
							EndIf

							AAdd( aLinha, { "D1_DTVALID", (cAliasSD2)->D2_DTVALID, ".T." } )
							AAdd( aLinha, { "D1_POTENCI", (cAliasSD2)->D2_POTENCI, ".T." } )
						EndIf

						cNFORI  := (cAliasSD2)->D2_DOC
						cSERIORI:= (cAliasSD2)->D2_SERIE
						cITEMORI:= (cAliasSD2)->D2_ITEM
						If cTipo == "D"
							SF4->(dbSetOrder(1))
							If SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)) .And. SF4->F4_PODER3$"D|R"
								If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "N"
									cNFORI  := ""
									cSERIORI:= ""
									cITEMORI:= ""
									Help(" ",1,"A100NOTES")
								EndIf
								If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "R"
									cNFORI  := ""
									cSERIORI:= ""
									cITEMORI:= ""
								    Help(" ",1,"A103TESNFD")
								EndIf
							EndIf
						EndIf
						AAdd( aLinha, { "D1_NFORI"  , cNFORI   			      , Nil } )
						AAdd( aLinha, { "D1_SERIORI", cSERIORI  		      , Nil } )
						AAdd( aLinha, { "D1_ITEMORI", cITEMORI   			  , Nil } )
						AAdd( aLinha, { "D1_ICMSRET", (cAliasSD2)->D2_ICMSRET, Nil } )
						If (cAliasSF4)->F4_PODER3=="D"
							AAdd( aLinha, { "D1_IDENTB6", (cAliasSD2)->D2_NUMSEQ, Nil } )
						Endif

						//Obtém o valor do Acrescimo Financeiro na Nota de Origem e faz o rateio //
						If (cAliasSD2)->D2_VALACRS >0
							AAdd( aLinha, { "D1_VALACRS", ((cAliasSD2)->D2_VALACRS / (cAliasSD2)->D2_QUANT )*nSldDev , Nil })
						Endif

						AAdd( aLinha, { "D1_CONTA"  , (cAliasSD2)->D2_CONTA , Nil } )
						AAdd( aLinha, { "D1_CC"     , (cAliasSD2)->D2_CC , Nil } )
						AAdd( aLinha, { "D1_VENCPRV", "" , Nil } )
						AAdd( aLinha, { "D1_VLDDPRV", "", Nil } )
						AAdd( aLinha, { "D1_BRICMS", 0 , Nil } )
						AAdd( aLinha, { "D1_ICMSRET", 0, Nil } )
						AAdd( aLinha, {"D1_ORIIMP"   , "SMS001", Nil})   
						
						If ExistBlock("MT103LDV")
							aLinha := ExecBlock("MT103LDV",.F.,.F.,{aLinha,cAliasSD2})
						EndIf

						AAdd( aLinha, { "D1RECNO",    Iif(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RECNO()) ), Nil } )

						AAdd( aItens, aLinha)
					EndIf
				Endif
			Else
				nHpP3 := 1
			Endif
			DbSelectArea(cAliasSD2)
			dbSkip()
		EndDo
		If lQuery
			DbSelectArea(cAliasSD2)
			dbCloseArea()
		Else
			If lCliente
				RetIndex( "SD2" )
				FErase( cIndex+OrdBagExt() )
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se nenhum item foi processado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lDevCode
			lDevolucao := .F.
		Endif
		DbSelectArea("SD2")

	EndIf

Return lDevolucao

//----------------------------------------------------------------------------------------------------------------------------------------------------------

user Function ProcDocs(nRegs,lNFeAut)

Local oXml
Local aCabec 	:= {}
Local aItens 	:= {}
Local aErro  	:= {}
Local cErro  	:= ""
Local nX	 	:= 0
Local nCount 	:= 0
Local cFilBkp	:= cFilAnt
Local lRet		:= .F.
Local aFatura   := {}
Local aTitulos  := {}
Local aCabec116	 := {}
Local aItens116	 := {}
Local cTipoNF	 := ""
Local cCondPagto := ""
Local lRemet	 := .F.
Local _aRet		:= {}
Local aErros   	:= {}
Local cError   	:= ""
Local cWarning 	:= ""
Local nI := 0       
Local _lContinua := .T.
Local _l116		:= .F.
Local _aSF1
Local nY        := 0 
Default lNFeAut := .F.

Private lMSErroAuto	   := .T.
Private	lAutoErrNoFile := .T.

ProcRegua(nRegs)

While !(_cTab1)->(EOF())
	If ((_cTab1)->&(_cCmp1+"_OKCTE") == cMarca)
		lRet := .T.
		nCount++
		IncProc(STR0024 +AllTrim((_cTab1)->&(_cCmp1+"_DOC")) +"/" +AllTrim((_cTab1)->&(_cCmp1+"_SERIE")) +"(" +StrZero(nCount,2) +STR0025 +StrZero(nRegs,3) +")") //-- Processando documento # de

		//-- Se filial diferente, troca
		If PadR(cFilAnt,Len(AllTrim((_cTab1)->&(_cCmp1+"_FILIAL")))) # AllTrim((_cTab1)->&(_cCmp1+"_FILIAL"))
			Do Case
				Case FWModeAccess("SB2",3) == "E"
					cFilAnt := (_cTab1)->&(_cCmp1+"_FILIAL")
				Case FWModeAccess("SB2",2) == "E" .Or. FWModeAccess("SB2",1) == "E"
					SM0->(dbSetOrder(1))
					SM0->(dbSeek(cEmpAnt+(_cTab1)->&(_cCmp1+"_FILIAL")))
					cFilAnt := Alltrim(SM0->M0_CODFIL)
			EndCase
		EndIf
        IF (_cTab1)->&(_cCmp1+"_ESPECI") == 'CTEAG'
        	cCteAgricopel := .T.
        ENDIF
		//-- Esvazia log
		RecLock((_cTab1),.F.)
		(_cTab1)->&(_cCmp1+"_ERRO") := CriaVar((_cCmp1+"_ERRO"),.F.)
		(_cTab1)->&(_cCmp1+"_ESPECI") := cEspCte
		(_cTab1)->(MsUnLock())

		If Empty((_cTab1)->&(_cCmp1+"_ERRO")) //-- Se nao houve erro na montagem dos dados, continua
			lMSErroAuto := .F.

			if (_cTab1)->&(_cCmp1+"_STCTE") == "S"

				aCabec := MontaSF1()
				aItens := MontaSD1()

				If (_cTab1)->&(_cCmp1+"_TIPO") $ "OCT2" 
             
				   //	MsAguarde({|| MsExecAuto({|x,y,z| Mata103(x,y,z)}, aCabec, aItens, 3, lConfere)}, "Importação", "Importando Conhecimento de Transporte...")
					MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3,.T.)

				Else    

					MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3,.T.)
			   	EndIf
			ELSEIF !EMPTY(cCteAgricopel)
				IF cCteAgricopel .OR. (_cTab1)->&(_cCmp1+"_SERIE") == 'CTEAG'// Especifico Agricopel 
					lRet :=U_InCteSp()
					_l116 := IIF(lRet,.F.,.T.)
				ENDIF
			else
				aAdd(aCabec116,{"",dDataBase-90})       												// Data inicial para filtro das notas
				aAdd(aCabec116,{"",dDataBase})          												// Data final para filtro das notas
				aAdd(aCabec116,{"",2})                  												// 2-Inclusao ; 1=Exclusao
				aAdd(aCabec116,{"",(_cTab1)->&(_cCmp1+"_CODREM")})										// Rementente das notas contidas no conhecimento
				aAdd(aCabec116,{"",(_cTab1)->&(_cCmp1+"_LOJREM")})										// Loja do remetente das notas contidas no conhecimento
				aAdd(aCabec116,{"",val((_cTab1)->&(_cCmp1+"_TIPONF"))})									// 	Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
				aAdd(aCabec116,{"",2})                  												// 1=Aglutina itens ; 2=Nao aglutina itens
				aAdd(aCabec116,{"F1_EST",""})  		  													// UF das notas contidas no conhecimento
				aAdd(aCabec116,{"",(_cTab1)->&(_cCmp1+"_TOTVAL")}) 										// Valor do conhecimento
				aAdd(aCabec116,{"F1_FORMUL",1})															// Formulario proprio: 1=Nao ; 2=Sim
				aAdd(aCabec116,{"F1_DOC",(_cTab1)->&(_cCmp1+"_DOC")})									// Numero da nota de conhecimento
				aAdd(aCabec116,{"F1_SERIE",(_cTab1)->&(_cCmp1+"_SERIE")})								// Serie da nota de conhecimento
				aAdd(aCabec116,{"F1_FORNECE",(_cTab1)->&(_cCmp1+"_CODEMI")}) 							// Fornecedor da nota de conhecimento
				aAdd(aCabec116,{"F1_LOJA",(_cTab1)->&(_cCmp1+"_LOJEMI")})								// Loja do fornecedor da nota de conhecimento
				aAdd(aCabec116,{"",cTESCTe})															// TES a ser utilizada nos itens do conhecimento
				aAdd(aCabec116,{"F1_BASERET",(_cTab1)->&(_cCmp1+"_BASEIC")})							// Valor da base de calculo do ICMS retido
				aAdd(aCabec116,{"F1_ICMRET",(_cTab1)->&(_cCmp1+"_VALICM")})								// Valor do ICMS retido
				aAdd(aCabec116,{"F1_COND",cCondCTe})											   		// Condicao de pagamento
				aAdd(aCabec116,{"F1_EMISSAO",(_cTab1)->&(_cCmp1+"_DTEMIS")}) // Data de emissao do conhecimento
				aAdd(aCabec116,{"F1_ESPECIE",cEspCte})															 // Especie do documento
				//aAdd(aCabec116,{&(_cCmp1+"_PCIM"),nAliqICMS})
				//Campos de origem e destino do frete
				aAdd(aCabec116,{"F1_UFORITR", (_cTab1)->&(_cCmp1+"_UFORIT")	})
				aAdd(aCabec116,{"F1_MUORITR", (_cTab1)->&(_cCmp1+"_MUORIT")	})
				aAdd(aCabec116,{"F1_UFDESTR", (_cTab1)->&(_cCmp1+"_UFDEST")	})
				aAdd(aCabec116,{"F1_MUDESTR", (_cTab1)->&(_cCmp1+"_MUDEST")	})

			   	oXml := XmlParser((_cTab1)->&(_cCmp1+"_XML"), "_", @cError, @cWarning)
		 		_aRet:= U_IMPXML_Cte((_cTab1)->&(_cCmp1+"_ARQUIV"), .T., aErros, oXml:_cteProc:_CTe, .F.,.F.)
				aNotas    := AClone(_aRet[2])
				aItens116 := {}

				For nI := 1 To Len(aNotas)
					dbSelectArea("SF1")
					SF1->( dbSetOrder(1) )
					If SF1->( dbSeek(xFilial("SF1") + aNotas[nI][1][2]) )

						RecLock("SF1", .F.)
						SF1->F1_OK := oBrowseCTe:Mark()
						SF1->( MSUnlock() )
						AAdd(aItens116, {{"PRIMARYKEY", SubStr(SF1->&(IndexKey()), FWSizeFilial() + 1)}})

					EndIf
				Next nI
                
                if len(aNotas) > 0 

					MsExecAuto({|x,y| MATA116(x,y)},aCabec116,aItens116)
			    else
			    	_l116 := .T.
			    endif 
			endif
		endif		    
	Else
		lRet := .F.
	EndIf

	If lRet
	_aSF1 := SF1->(GETAREA())
		DBSELECTAREA("SF1")
		DBSETORDER(8)
		IF !DBSEEK(XFILIAL("SF1")+(_cTab1)->&(_cCmp1+"_CHAVE")) .AND. ALLTRIM((_cTab1)->&(_cCmp1+"_ESPECI")) == "CTE"
				lRet :=U_InCteSp()
				_l116 := IIF(lRet,.F.,.T.)
		ENDIF
	RestArea(_aSF1)
	   	If !lMsErroAuto .and. !_l116
		   	RecLock(_cTab1,.F.)
			(_cTab1)->&(_cCmp1+"_SIT")    := "2"
			(_cTab1)->&(_cCmp1+"_ERRO")   := ""
			(_cTab1)->&(_cCmp1+"_ESPECI") := cEspCTe
			(_cTab1)->&(_cCmp1+"_TES")    := cTESCTe
			(_cTab1)->&(_cCmp1+"_NATFIN") := cNatCTe
			(_cTab1)->&(_cCmp1+"_CONDPG") := cCondCTe
			(_cTab1)->&(_cCmp1+"_DTIMP")  := dDataBase
			(_cTab1)->&(_cCmp1+"_HRIMP")  := Time()
			(_cTab1)->&(_cCmp1+"_USUIMP") := cUserName
		   	Replace (_cTab1)->&(_cCmp1+"_OKCTE")	With ''
			(_cTab1)->(MsUnLock())

			AtuBrowse()

			dbSelectArea("SE2")
			SE2->( dbSetOrder(6) )
			SE2->( dbSeek(xFilial("SE2")+(_cTab1)->&(_cCmp1+"_CODEMI")+(_cTab1)->&(_cCmp1+"_LOJEMI")+(_cTab1)->&(_cCmp1+"_SERIE")+(_cTab1)->&(_cCmp1+"_DOC")) )
			While !SE2->(EOF()) .AND. SE2->E2_FILIAL==xFilial("SE2") .AND. AllTrim(SE2->E2_PREFIXO)==AllTrim((_cTab1)->&(_cCmp1+"_SERIE")) .AND.;
				SE2->E2_FORNECE==(_cTab1)->&(_cCmp1+"_CODEMI") .AND. SE2->E2_LOJA==(_cTab1)->&(_cCmp1+"_LOJEMI") .AND.;
				SE2->E2_NUM==(_cTab1)->&(_cCmp1+"_DOC")
				AAdd(aTitulos,  {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, .F.})
				SE2->(dbSkip())
			Enddo

		Else
			if !_l116
				aErro := GetAutoGRLog()
				cErro := ""
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] +CRLF
				Next nX
			   	RecLock(_cTab1,.F.)
				Replace (_cTab1)->&(_cCmp1+"_ERRO") With cErro
				Replace (_cTab1)->&(_cCmp1+"_STATUS") With 'E'
				(_cTab1)->&(_cCmp1+"_SIT")  := "3"
				(_cTab1)->&(_cCmp1+"_ERRO") := cErro
				ExibeErro()
				(_cTab1)->(MsUnLock())
	        else 
	        	//Chamado 75967 - Estava acusando errorlog 
				iF len(_aRet) >= 3
					aErro := _aRet[3]
				Else
					aErro := {}
				Endif
				
				cErro := ""
				For nX := 1 To Len(aErro)
					for nY := 1 to len(aErro[nX])
						cErro += alltrim(aErro[nX][nY]) + CRLF
					next ny
				Next nX
			   	RecLock((_cTab1),.F.)
				Replace (_cTab1)->&(_cCmp1+"_ERRO") With cErro
				Replace (_cTab1)->&(_cCmp1+"_STATUS") With 'E'
				(_cTab1)->&(_cCmp1+"_SIT")  := "3"
				(_cTab1)->&(_cCmp1+"_ERRO") := cErro
				ExibeErro()
				(_cTab1)->(MsUnLock())
	        endif
		EndIf
	EndIf

	(_cTab1)->(dbSkip())
	cFilAnt := cFilBkp
End

If !lMsErroAuto .and. !_l116                     
	MsgInfo("Conhecimento(s) de Transporte importado(s) com sucesso.", "Aviso")

	If lAglut 

		MsExecAuto( { |x,y| FINA290(x,y)}, 3, aFatura)
		If lMsErroAuto
			DisarmTransaction()
			aErro := GetAutoGRLog()
			cErro := ""
			For nX := 1 To Len(aErro)
				cErro += aErro[nX] +CRLF
			Next nY
			alert("Ocorreu o seguinte erro ao gerar a fatura: "+ cErro)
      		MostraErro()
		Endif
	Endif

Endif


Return

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function MontaSF1()
Local aRet	 	 := {}
Local cTipoNF	 := ""
Local cCondPagto := ""
Local aAreaSDS	 := (_cTab1)->(GetArea())

Do Case
	Case (_cTab1)->&(_cCmp1+"_TIPO") == "2"
		cTipoNF := "C"
	Case (_cTab1)->&(_cCmp1+"_TIPO") == "T"
		cTipoNF := "C"
	Case (_cTab1)->&(_cCmp1+"_TIPO") == "O"
		cTipoNF := "N"
	Otherwise
		cTipoNF := (_cTab1)->&(_cCmp1+"_TIPO")
EndCase

// Quando a empresa for remetente da mercadoria (FOB) nao deve passar F1_TPFRETE na rotina automatica, caso contrario vai cair na validacao A103FRETE que nao permite vincular pedido de compra a documentos com TPFRETE preenchido
If ((_cTab1)->&(_cCmp1+"_TIPO") == "T".or. (_cTab1)->&(_cCmp1+"_TIPO") == "2") .And. (_cTab1)->&(_cCmp1+"_TPFRET") == "F"
	lRemet := .T.
EndIf

aAdd(aRet,{"F1_FILIAL",  (_cTab1)->&(_cCmp1+"_FILIAL"),	Nil})
If AllTrim((_cTab1)->&(_cCmp1+"_ESPECI")) == "CTE"
//	(_cTab1)->(dbSetOrder(2))
//	If lRemet .And. (_cTab1)->(dbSeek(xFilial(_cTab1)+(_cTab1)->(&(_cCmp1+"_CODEMI")+&(_cCmp1+"_LOJEMI")+&(_cCmp1+"_DOC")+&(_cCmp1+"_SERIE")))) .And.  AllTrim((_cTab1)->&(_cCmp1+"_COD")) $ AllTrim(SuperGetMV("MV_XMLPFCT",.F.,""))
	If lRemet
		aAdd(aRet,{"F1_TIPO","N",Nil})
	Else
		aAdd(aRet,{"F1_TIPO",cTipoNF,Nil})
	EndIf
Else
	aAdd(aRet,{"F1_TIPO",  cTipoNF,			Nil})
EndIf

aAdd(aRet,{"F1_FORMUL",  (_cTab1)->&(_cCmp1+"_FORMUL")	,	Nil})
aAdd(aRet,{"F1_DOC",     (_cTab1)->&(_cCmp1+"_DOC")		,	Nil})
aAdd(aRet,{"F1_SERIE",   (_cTab1)->&(_cCmp1+"_SERIE")	,	Nil})
aAdd(aRet,{"F1_EMISSAO", (_cTab1)->&(_cCmp1+"_DTEMIS")	,	Nil})
aAdd(aRet,{"F1_FORNECE", (_cTab1)->&(_cCmp1+"_CODEMI")	,	Nil})
aAdd(aRet,{"F1_LOJA",    (_cTab1)->&(_cCmp1+"_LOJEMI")	,	Nil})
aAdd(aRet,{"F1_ESPECIE", (_cTab1)->&(_cCmp1+"_ESPECI")	,	Nil})
aAdd(aRet,{"F1_DTDIGIT", dDataBase						,	Nil})
aAdd(aRet,{"F1_EST",     (_cTab1)->&(_cCmp1+"_EST")		,	Nil})
aAdd(aRet,{"F1_CHVNFE",  (_cTab1)->&(_cCmp1+"_CHAVE")	,	Nil})
aAdd(aRet,{"F1_FRETE",   (_cTab1)->&(_cCmp1+"_VALFRE")	,	Nil})
aAdd(aRet,{"F1_DESPESA", (_cTab1)->&(_cCmp1+"_DESPES")	,	Nil})
aAdd(aRet,{"F1_DESCONT", (_cTab1)->&(_cCmp1+"_VLDESC")	,	Nil})
aAdd(aRet,{"F1_SEGURO",  (_cTab1)->&(_cCmp1+"_SEGURO")	,	Nil})
aAdd(aRet,{"F1_COND",  	 cCondCTe						,	Nil})
aAdd(aRet,{"F1_PLIQUI",  (_cTab1)->&(_cCmp1+"_PLIQUI")	,	Nil})
aAdd(aRet,{"F1_PBRUTO",  (_cTab1)->&(_cCmp1+"_PBRUTO")	,	Nil})
aAdd(aRet,{"F1_ESPECI1", (_cTab1)->&(_cCmp1+"_ESPEC1")	,	Nil})
aAdd(aRet,{"F1_VOLUME1", (_cTab1)->&(_cCmp1+"_VOLUM1")	,	Nil})
aAdd(aRet,{"F1_ESPECI2", (_cTab1)->&(_cCmp1+"_ESPEC2")	,	Nil})
aAdd(aRet,{"F1_VOLUME2", (_cTab1)->&(_cCmp1+"_VOLUM2")	,	Nil})
aAdd(aRet,{"F1_ESPECI3", (_cTab1)->&(_cCmp1+"_ESPEC3")	,	Nil})
aAdd(aRet,{"F1_VOLUME3", (_cTab1)->&(_cCmp1+"_VOLUM3")	,	Nil})
aAdd(aRet,{"F1_ESPECI4", (_cTab1)->&(_cCmp1+"_ESPEC4")	,	Nil})
aAdd(aRet,{"F1_VOLUME4", (_cTab1)->&(_cCmp1+"_VOLUM4")	,	Nil})

//Campos de origem e destino do frete
aAdd(aRet,{"F1_UFORITR", (_cTab1)->&(_cCmp1+"_UFORIT")	,	Nil})
aAdd(aRet,{"F1_MUORITR", (_cTab1)->&(_cCmp1+"_MUORIT")	,	Nil})
aAdd(aRet,{"F1_UFDESTR", (_cTab1)->&(_cCmp1+"_UFDEST")	,	Nil})
aAdd(aRet,{"F1_MUDESTR", (_cTab1)->&(_cCmp1+"_MUDEST")	,	Nil})

If !lRemet	// Nao deve passar TPFRETE quando for CT-e e a empresa for remetente da mercadoria (FOB). Para os outros casos deve passar,
	aAdd(aRet,{"F1_TPFRETE", (_cTab1)->&(_cCmp1+"_TPFRET"),	Nil})
EndIf
	aAdd(aRet,{"F1_BASEICM", (_cTab1)->&(_cCmp1+"_BASEIC")	, Nil})
	aAdd(aRet,{"F1_VALICM", (_cTab1)->&(_cCmp1+"_VALICM")	, Nil })

//-- Preenche condicao de pagamento para tipos de documento que geram NF
Do Case
	Case (_cTab1)->&(_cCmp1+"_TIPO") == "C" //-- Complemento de preco
		//-- Obtem cond. pagto utilizada na nota origem
		(_cTab1)->(dbSetOrder(2)) 
		(_cTab1)->(dbSeek(xFilial(_cTab1)+(_cTab1)->(&(_cCmp1+"_FORNEC")+&(_cCmp1+"_LOJA")+&(_cCmp1+"_DOC")+&(_cCmp1+"_SERIE"))))
		While Empty(cCondPagto) .And. (_cTab1)->(!EOF()) .And. (_cTab1)->(&(_cCmp1+"_FILIAL")+&(_cCmp1+"_CODEMI")+&(_cCmp1+"_LOJEMI")+&(_cCmp1+"_DOC")+&(_cCmp1+"_SERIE")) == xFilial(_cTab1)+(_cTab1)->(&(_cCmp1+"_CODEMI")+&(_cCmp1+"_LOJEMI")+&(_cCmp1+"_DOC")+&(_cCmp1+"_SERIE"))
			SF1->(dbSetOrder(1))
			If SF1->(dbSeek(xFilial("SF1")+(_cTab1)->(&(_cCmp1+"_NFORI")+&(_cCmp1+"_SERIORI")+&(_cCmp1+"_CODEMI")+&(_cCmp1+"_LOJEMI")))) .And. !Empty(SF1->F1_COND)
				cCondPagto := SF1->F1_COND
			EndIf
			(_cTab1)->(dbSkip())
		End
		aAdd(aRet,{"F1_COND",cCondPagto,Nil})
	Case (_cTab1)->&(_cCmp1+"_TIPO") == "T" .or. (_cTab1)->&(_cCmp1+"_TIPO") == "2" //-- Conhecimento de transporte
		//-- Obtem cond. pagto para utilizacao no CT-e (MV_XMLCPCT)
		aAdd(aRet,{"F1_COND",cCondCTe,Nil})
EndCase

aAdd(aRet,{"E2_NATUREZ", cNatCte	,	Nil})

RestArea(aAreaSDS)
Return aRet
//--------------------------------------------------------------------------------------------------------------------------------------

Static Function MontaSD1()
Local aRet	    := {}
Local cTES_CT	:= ""
Local aAreaSDS	:= (_cTab1)->(GetArea())
local cCfop		:= ""

//(_cTab1)->(dbSetOrder(2))
//(_cTab1)->(dbSeek(xFilial(_cTab1)+(_cTab1)->(&(_cCmp1+"_CODEMI")+&(_cCmp1+"_LOJEMI")+&(_cCmp1+"_DOC")+&(_cCmp1+"_SERIE"))))
// While (_cTab1)->(!EOF()) .AND. (_cTab1)->(&(_cCmp1+"_FILIAL")+&(_cCmp1+"_CODEMI")+&(_cCmp1+"_LOJEMI")+&(_cCmp1+"_DOC")+&(_cCmp1+"_SERIE")) == xFilial(_cTab1)+(_cTab1)->(&(_cCmp1+"_FORNEC")+&(_cCmp1+"_LOJA")+&(_cCmp1+"_DOC")+&(_cCmp1+"_SERIE"))
	aAdd(aRet,{})

	aAdd(aTail(aRet),{"D1_ITEM",   (_cTab1)->&(_cCmp1+"_ITEM")	, 	 NIL})
	aAdd(aTail(aRet),{"D1_COD",    (_cTab1)->&(_cCmp1+"_COD")	,	 NIL})
	If !Empty((_cTab1)->&(_cCmp1+"_PEDIDO"))
		aAdd(aTail(aRet),{"D1_PEDIDO", (_cTab1)->&(_cCmp1+"_PEDIDO"),	 NIL})
		aAdd(aTail(aRet),{"D1_ITEMPC", StrZero(val((_cTab1)->&(_cCmp1+"_ITEMPC")),4) ,	 NIL})
	EndIf
	If !Empty((_cTab1)->&(_cCmp1+"_NFORI"))
		aAdd(aTail(aRet),{"D1_NFORI",  (_cTab1)->&(_cCmp1+"_NFORI"),	 NIL})
		aAdd(aTail(aRet),{"D1_SERIORI",(_cTab1)->&(_cCmp1+"_SERIOR"), NIL})
		aAdd(aTail(aRet),{"D1_ITEMORI",(_cTab1)->&(_cCmp1+"_ITEMOR"), NIL})
	EndIf
	If !(_cTab1)->&(_cCmp1+"_TIPO") $ "C"
		If (_cTab1)->&(_cCmp1+"_TIPO") == "T"
			If (_cTab1)->&(_cCmp1+"_TPFRET") == "F"				// Somente quando a empresa e remetente da mercadoria (FOB) deve gerar nota com quantidade 1, caso contrario nao e para enviar quantidade (ficara zerada)
				aAdd(aTail(aRet),{"D1_QUANT",  (_cTab1)->&(_cCmp1+"_QUANT"), 	 NIL})
			EndIf
			dbSelectArea("SD1")
			dbSetOrder(2)
			If SD1->(dbSeek(xFilial('SD1')+ (_cTab1)->&(_cCmp1+"_COD") + (_cTab1)->&(_cCmp1+"_NFORI") + (_cTab1)->&(_cCmp1+"_SERIOR")))
				aAdd(aTail(aRet),{"D1_CONTA",SD1->D1_CONTA, NIL})
				aAdd(aTail(aRet),{"D1_CC",SD1->D1_CC, NIL})
				aAdd(aTail(aRet),{"D1_VENCPRV",SD1->D1_VENCPRV, NIL})
				aAdd(aTail(aRet),{"D1_VLDDPRV",SD1->D1_VLDDPRV, NIL})
			EndIf
		Else
			aAdd(aTail(aRet),{"D1_QUANT",  (_cTab1)->&(_cCmp1+"_QUANT"), 	 NIL})
		EndIf
	EndIf
	aAdd(aTail(aRet),{"D1_VUNIT",  (_cTab1)->&(_cCmp1+"_TOTVAL"), 	 NIL})
	If (_cTab1)->&(_cCmp1+"_TIPO") $ "CT"
		aAdd(aTail(aRet),{"D1_TOTAL",(_cTab1)->&(_cCmp1+"_TOTVAL"),NIL})
	Else
		aAdd(aTail(aRet),{"D1_TOTAL",Round((_cTab1)->&(_cCmp1+"_TOTVAL") * (_cTab1)->&(_cCmp1+"_QUANT"),TamSX3("D1_TOTAL")[2]),NIL})
	EndIf
	aAdd(aTail(aRet),{"D1_VALFRE",	(_cTab1)->&(_cCmp1+"_VALFRE"),	 NIL})
	aAdd(aTail(aRet),{"D1_SEGURO",	(_cTab1)->&(_cCmp1+"_SEGURO"),	 NIL})
	aAdd(aTail(aRet),{"D1_DESPESA",	(_cTab1)->&(_cCmp1+"_DESPES"), NIL})
	aAdd(aTail(aRet),{"D1_VALDESC",(_cTab1)->&(_cCmp1+"_VLDESC"), NIL})
	aAdd(aTail(aRet),{"D1_PICM", (_cTab1)->&(_cCmp1+"_PICM"), Nil })
	AAdd(aTail(aRet),{"D1_ORIIMP"   , "SMS001", Nil})

	//-- Realiza validacoes pertinentes e preenche TES
	Do Case
		Case (_cTab1)->&(_cCmp1+"_TIPO") == "C" //-- Complemento de preco
			//-- Valida vinculo com documento origem
			If Empty((_cTab1)->&(_cCmp1+"_NFORI"))
				RecLock(_cTab1,.F.)
				Replace (_cTab1)->&(_cCmp1+"_ERRO") With (_cTab1)->&(_cCmp1+"_ERRO") +CRLF+CRLF +STR0026 +(_cTab1)->&(_cCmp1+"_ITEM") +STR0027 //-- Por tratar-se de um documento de complemento de preço, deverá ser realizado o vínculo com o documento origem para o item # deste documento.
				Replace (_cTab1)->&(_cCmp1+"_STATUS") With 'E'
				(_cTab1)->(MsUnlock())
			EndIf
			//-- Obtem TES
			SA5->(dbSetOrder(1))
			If SA5->(dbSeek(xFilial("SA5")+(_cTab1)->(&(_cCmp1+"_FORNEC")+&(_cCmp1+"_LOJA")+&(_cCmp1+"_COD")))) .And. Empty(SA5->A5_TESCP)
				RecLock(_cTab1,.F.)
				Replace (_cTab1)->&(_cCmp1+"_ERRO") With (_cTab1)->&(_cCmp1+"_ERRO") +CRLF+CRLF +;
											STR0028 +AllTrim((_cTab1)->&(_cCmp1+"_COD")) +STR0029 +AllTrim((_cTab1)->&(_cCmp1+"_CODEMI")) +'/' +AllTrim((_cTab1)->&(_cCmp1+"_LOJEMI")) +STR0030 //-- Por tratar-se de um documento de complemento de preço, deverá ser identificado o tipo de entrada para o produto # e fornecedor # no campo "TE p/ Compl." (A5_TESCP) no cadastro de Produto X Fornecedor.
				Replace (_cTab1)->&(_cCmp1+"_STATUS") With 'E'
				(_cTab1)->(MsUnlock())
			Else
				aAdd(aTail(aRet),{"D1_TES",SA5->A5_TESCP,NIL})
				cTesCte := SA5->A5_TESCP
			EndIf
		Case (_cTab1)->&(_cCmp1+"_TIPO") == "T" //-- Conhecimento de transporte
			//-- Obtem cond. pagto para utilizacao no CT-e (MV_XMLCPCT)
				aAdd(aTail(aRet),{"D1_TES",cTESCTe,NIL})
		Case (_cTab1)->&(_cCmp1+"_TIPO") == "2" //-- Conhecimento de transporte
			//-- Obtem cond. pagto para utilizacao no CT-e (MV_XMLCPCT)
				aAdd(aTail(aRet),{"D1_TES",cTESCTe,NIL})
		Case (_cTab1)->&(_cCmp1+"_TIPO") == "O"
			SA5->(dbSetOrder(1))
			If SA5->(dbSeek(xFilial("SA5")+(_cTab1)->&(_cCmp1+"_CODEMI")+(_cTab1)->&(_cCmp1+"_LOJEMI")+(_cTab1)->&(_cCmp1+"_COD"))) .And. Empty(SA5->A5_TESBP)
				RecLock(_cTab1,.F.)
				Replace (_cTab1)->&(_cCmp1+"_ERRO") With STR0032 +AllTrim((_cTab1)->&(_cCmp1+"_COD")) +STR0029 +AllTrim((_cTab1)->&(_cCmp1+"_CODEMI")) +'/' +AllTrim((_cTab1)->&(_cCmp1+"_LOJEMI")) +STR0033 //-- Por tratar-se de um documento de bonificação, deverá ser identificado o tipo de entrada para o produto # e fornecedor # no campo "TE p/ Bonif." (A5_TESBP) no cadastro de Produto X Fornecedor.
				Replace (_cTab1)->&(_cCmp1+"_STATUS") With 'E'
				(_cTab1)->(MsUnlock())
			Else
				aAdd(aTail(aRet),{"D1_TES", SA5->A5_TESBP,  NIL})
				cTesCte := SA5->A5_TESBP
			EndIf
	EndCase

	If GetMv("MV_XSMS008") == .T.
		dbselectarea("SF4")
		dbsetorder(1)
		if dbseek(xFilial("SF4")+cTesCte)
			cCfop := SF4->F4_CF
		endif
		SF4->(dbclosearea())

		dbselectarea("SA2")
		dbsetorder(3)
		if U_SMS01CGC((_cTab1)->&(_cCmp1+"_CGCEMI"))//dbseek(xFilial("SA2")+(_cTab1)->&(_cCmp1+"_CGCEMI"))
			if alltrim(SA2->A2_EST) <> alltrim(SM0->M0_ESTCOB)
				if alltrim(SA2->A2_EST) == "EX"
					cCfop := "3"+substr(cCfop,2,3)
				else
					cCfop := "2"+substr(cCfop,2,3)
				endif
			else
				cCfop := "1"+substr(cCfop,2,3)
			endif
		endif
		SA2->(dbclosearea())
	endif
	
	aAdd(aTail(aRet),{"D1_CF", cCfop, Nil })
	aAdd(aTail(aRet),{"D1_ORIIMP"  , "SMS001", Nil})
	//Grava CC
	If alltrim(cCCCTe) <> ''
		aAdd(aTail(aRet),{"D1_CC", cCCCTe, Nil })
	Endif


//	(_cTab1)->(dbSkip())
//EndDo

RestArea(aAreaSDS)
Return aRet

static Function GdFieldGet( cCampo , nLine , lReadVar , aHeaderPastPar , aColsPastPar )

Local nPos      		:= 0
Local xConteudo 		:= NIL

cCampo 					:= Upper( AllTrim( cCampo ) )
DEFAULT nLine			:= n
DEFAULT lReadVar		:= .F.
DEFAULT aHeaderPastPar	:= aHeader
DEFAULT aColsPastPar	:= aCols

IF ( lReadVar .and. ( nLine == n ) .and. ( ValType( ReadVar() ) == "C" ) .and. ( ReadVar() == "M->" + cCampo ) )
	xConteudo := &( ReadVar() )
Else
	IF !Empty( ( nPos := GdFieldPos( cCampo , aHeaderPastPar ) ) )
		xConteudo := aColsPastPar[ nLine , nPos ]
	EndIF
EndIF

Return( xConteudo )

static Function GdFieldPos( cCampo , aHeadOpc )

Local nRet := 0

DEFAULT aHeadOpc := aHeader

cCampo	 := Upper( AllTrim( cCampo ) )
IF !( cCampo == "GDDELETED" )
	nRet := aScan( aHeadOpc , { |x| Upper( AllTrim( x[2] ) ) == cCampo } )
Else
	nRet := GdPosDeleted( aHeadOpc )
EndIF

Return( nRet )

//---------------------------------------------------------------------------------------------------------------------------------
//
User function SMSG001(cCampo)

LOCAL cCmp := Alltrim(Substr(cCampo,4))
LOCAL nPos
Local xRetu

xRetu := &cCmp

//Verifico se campo existe e atualizo informacoes
/////////////////////////////////////////////////
If (N == 1)
	nPos := aScan(aHeader,{|x| Alltrim(x[2]) == cCmp })
	
	// replico o campo
	If (nPos > 0).and.(Len(aCols) > 1).and.MsgYesNo("Replicar conteúdo da coluna "+Alltrim(aHeader[nPos,1])+" para todas as linhas ? ")
		aEval(aCols,{|x| x[nPos] := xRetu })
	Endif
Endif

return(.T.)   

User Function InCteSp()

Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local Bxml:= XmlParser((_cTab1)->&(_cCmp1+"_XML"),"_",@cError, @cWarning ) 
Local nInicio
Local nFim
Local lRetorno

Private lMsHelpAuto := .T.
PRIVATE lMsErroAuto := .F.

aCabec := {}
aItens := {}  

DBSELECTAREA("SB1")
DBSETORDER(1)
IF !DBSEEK( xFilial("SB1")+GETNEWPAR("MV_XSMSPRO","DES52111102"))
	MSGALERT("O produto "+GETNEWPAR("MV_XSMSPRO","DES52111102")+" não está cadastrado para a filial "+xFilial("SB1")+", verifique o cadastro de produtos ou "+;
	"solicite o cadastro do produto correto no parametro MV_XSMSPRO.","Produto não Cadastrado!!!") 
	RETURN(.F.)
ENDIF

aadd(aCabec,{"F1_TIPO"   ,"N"})
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,(_cTab1)->&(_cCmp1+"_DOC")})
aadd(aCabec,{"F1_SERIE"  ,(_cTab1)->&(_cCmp1+"_SERIE")})
aadd(aCabec,{"F1_EMISSAO",(_cTab1)->&(_cCmp1+"_DTEMIS")})
aadd(aCabec,{"F1_FORNECE",(_cTab1)->&(_cCmp1+"_CODEMI")})
aadd(aCabec,{"F1_LOJA"   ,(_cTab1)->&(_cCmp1+"_LOJEMI")})
aadd(aCabec,{"F1_ESPECIE","CTE"})
aadd(aCabec,{"F1_COND",cCondCTe})
aadd(aCabec,{"F1_CHVNFE",(_cTab1)->&(_cCmp1+"_CHAVE")})
aadd(aCabec,{"E2_NATUREZ",cNatCTe})
aAdd(aCabec,{"F1_BASEICM", (_cTab1)->&(_cCmp1+"_BASEIC")	, Nil})
aAdd(aCabec,{"F1_VALICM", (_cTab1)->&(_cCmp1+"_VALICM")	, Nil })
IF Val(BXML:_Cteproc:_Cte:_InfCte:_VPrest:_VRec:Text) < (_cTab1)->&(_cCmp1+"_TOTVAL") // Se o valor no XML for menor que o valor gravado na tabela
	IF At(cValtoChar((_cTab1)->&(_cCmp1+"_TOTVAL") - Val(BXML:_Cteproc:_Cte:_InfCte:_VPrest:_VRec:Text)),(_cTab1)->&(_cCmp1+"_XML")) > 0 // Se localizar no XML o valor da diferença
		IF At(">Pedagio<",(_cTab1)->&(_cCmp1+"_XML")) > 0  // Se existir a tag Pedagio
			nInicio	:= At('<vComp>',(_cTab1)->&(_cCmp1+"_XML"),At(">Pedagio<",(_cTab1)->&(_cCmp1+"_XML")))+7 // Posição inicial no XML
			nFim	:= len(cvaltochar((_cTab1)->&(_cCmp1+"_TOTVAL") - Val(BXML:_Cteproc:_Cte:_InfCte:_VPrest:_VRec:Text))) // Posição Final no XML
			IF VAL(SUBSTR((_cTab1)->&(_cCmp1+"_XML"),nInicio,nFim)) == ((_cTab1)->&(_cCmp1+"_TOTVAL") - Val(BXML:_Cteproc:_Cte:_InfCte:_VPrest:_VRec:Text)) // Valida novamente o valor
				aAdd(aCabec,{"F1_VALPEDG", Val(SUBSTR((_cTab1)->&(_cCmp1+"_XML"),nInicio,nFim))	, Nil })
			ENDIF
		ENDIF
	ENDIF
ENDIF

//Campos de origem e destino do frete
aAdd(aCabec,{"F1_UFORITR", (_cTab1)->&(_cCmp1+"_UFORIT")})
aAdd(aCabec,{"F1_MUORITR", (_cTab1)->&(_cCmp1+"_MUORIT")})
aAdd(aCabec,{"F1_UFDESTR", (_cTab1)->&(_cCmp1+"_UFDEST")})
aAdd(aCabec,{"F1_MUDESTR", (_cTab1)->&(_cCmp1+"_MUDEST")})

aLinha := {}
aadd(aLinha,{"D1_COD"  ,GETNEWPAR("MV_XSMSPRO","DES52111102") ,Nil}) 
aadd(aLinha,{"D1_QUANT",1,Nil})
aadd(aLinha,{"D1_VUNIT",(_cTab1)->&(_cCmp1+"_TOTVAL"),Nil})
aadd(aLinha,{"D1_TOTAL",(_cTab1)->&(_cCmp1+"_TOTVAL"),Nil})
aadd(aLinha,{"D1_TES",cTesCTe,Nil}) 
//aadd(aLinha,{"D1_LOCAL",POSICIONE("SB1", 1, xFilial("SB1") + GETNEWPAR("MV_XSMSPRO","DES52111102"), "B1_LOCPAD"),Nil})
     
// Chamado 72549 - Obrigar CC
If alltrim(cCCCTe) <> ""
	aadd(aLinha,{"D1_CC",cCCCTe,Nil})                   
Endif
aadd(aItens,aLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//| Inclusao  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
MSExecAuto({|x,y| mata103(x,y)},aCabec,aItens)


If !lMsErroAuto
	ConOut(OemToAnsi("Incluido "+(_cTab1)->&(_cCmp1+"_DOC")+" com sucesso! "))
	lRetorno := .T.
Else
	ConOut(OemToAnsi("Erro na inclusao, Documento "+(_cTab1)->&(_cCmp1+"_DOC")+""))
	//MostraErro()
	lRetorno := .F.
EndIf

Return(lRetorno) 

// ##############################################################
// ### Função destinada a mover de pasta os XMLs Rejeitados.  ###
// ### Também foi criado uma validação, para limpar a pasta   ###
// ### dos Rejeitados após 30 dias, inicialmente foi decidido ###
// ### não limpar esta pasta, desta forma esta função foi     ###
// ### comentada, a função já se encontra validada.           ###
// ### Thiago SLA - 23/06/2016								  ###
// ##############################################################

User Function RemXML()

Local aArqXML
Local nx
Local nz
Local cRejeitados := "\IMPMAIL\Empresa"+cEmpAnt+"\Filial"+cFilAnt+"\Rejeitados"
Local aArqM30

aArqXML := Directory(AllTrim(cEntrada) + "*.XML") 

IF LEN(Directory(cRejeitados,"D") ) == 0  // Cria a pasta se não existir
	Makedir(cRejeitados)
ENDIF
		
// Move o XML para a pasta rejeitados
For nx := 1 to Len(aArqXML)
	IF aArqXML[nx][3] <= (Date()-10) // Se estiver com data igual ou superior a 10 dias
		__CopyFile(cEntrada + alltrim(aArqXML[nx][1]), cRejeitados +"\"+ alltrim(aArqXML[nx][1])) // Copia o arquivo para a pasta Rejeitados
		IF File(cRejeitados +"\"+ alltrim(aArqXML[nx][1])) // Se copiou, apaga o arquivo
			FErase(cEntrada + alltrim(aArqXML[nx][1]))
		ENDIF
    ENDIF
Next


// Deleta o XML da Pasta
/*
cRejeitados += "\"

aArqM30 := Directory(AllTrim(cRejeitados) + "*.XML")

For nz := 1 to Len(aArqM30)
	IF aArqM30[nz][3] <= (Date()-30)
		Ferase(cRejeitados + ALLTRIM(aArqM30[nz][1]))
	ENDIF
Next 
*/
Return

// Chamado 57267 - Spiller
// Busca Customizada por CNPJ 
// Localiza o Cnpj e posiciona primeiro no
// Registro NÃO bloqueado
User Function SMS01CGC(xCgc)

	Local cQuery := ""  
	Local lRet   := .F. 
	
	cQuery := " SELECT R_E_C_N_O_ FROM "+RetSqlName('SA2')+" "   
	cQuery += " WHERE A2_CGC = '"+xCgc+"' AND D_E_L_E_T_ = '' "   
	cQuery += " AND A2_FILIAL = '"+xFilial('SA2')+"' "
	cQuery += " AND A2_MSBLQL <> '1' "
	
	If (Select("SMS01CGC") <> 0)
		dbSelectArea("SMS01CGC")
		SMS01CGC->(dbCloseArea())
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "SMS01CGC"	
	
	SMS01CGC->(dbgotop())
	 
	//Se encontrou desbloqueado posiciona
	If SMS01CGC->(!eof())
   		dbselectarea('SA2')
   		Dbgoto(SMS01CGC->R_E_C_N_O_) 
   		lRet := .T.   
 	// Senão posiciona no registro bloqueado
 	// Mantido por compatibilidade 
 	Else
 	   	dbselectarea('SA2')
 	   	SA2->(dbSetOrder(3))
		If SA2->(dbSeek(xFilial("SA2")+xCgc))
 			lRet := .T.
 		Endif
	Endif
	

Return lRet


//Exclui Arquivos Xml da pasta de Importação
User Function SMS001EF()

    Local lSalvar   := .F.//.F. /*.T. = Salva || .F. = Abre*/
    Local nOpcoes   := GETF_LOCALHARD+GETF_NOCHANGEDIR 
    Local ctargetDir
   	Local cEntFile 	:= "\IMPMAIL\Empresa"+cEmpAnt+"\Filial"+cFilAnt+"\Novos\"
	Local cSaiFile  := "\IMPMAIL\Empresa"+cEmpAnt+"\Filial"+cFilAnt+"\Importados\"
	Local cProcFile := "\IMPMAIL\Empresa"+cEmpAnt+"\Filial"+cFilAnt+"\Log\"

   	cEntFile    := alltrim( IIf(SubStr(AllTrim(cEntFile), Len(AllTrim(cEntFile)), 1) == "\", PadR(cEntFile, 200), PadR(AllTrim(cEntFile) + "\", 200)) )
	cSaiFile    := alltrim( IIf(SubStr(AllTrim(cSaiFile), Len(AllTrim(cSaiFile)), 1) == "\", PadR(cSaiFile, 200), PadR(AllTrim(cSaiFile) + "\", 200)) )
	cProcFile   := alltrim( IIf(SubStr(AllTrim(cProcFile), Len(AllTrim(cProcFile)), 1) == "\", PadR(cProcFile, 200), PadR(AllTrim(cProcFile) + "\", 200)) )

 	//cEntFile := cProcFile
   	ctargetDir := StrTran( AllTrim(cGetFile("Arquivos XML|*.XML", "Importar XML", 0,cEntFile/*"C:\XML"*/, lSalvar,nOpcoes,.T.)) ,'\','')

	If !Empty(ctargetDir)
		If MsgYesNo("Deseja Realmente Excluir o XML: "+ctargetDir)
			If FERASE(cEntFile+ctargetDir) == -1
 				MsgStop('Falha ao excluir o Arquivo')
 	 		Else
  	  			MsgInfo('Arquivo excluído com sucesso.')
  			Endif
		Endif
	Endif	
Return 



//Valida Centro de Custo 
Static Function ValCC()

	Local lRetcc := .F.

	DbSelectarea('CTT')
	DbsetOrder(1)
	If Dbseek(xfilial('CTT') + cCCCTe)

		//Se For Sintetica bloqueia 
		If CTT->CTT_CLASSE == '1'
			Alert('Centro de Custo sintetico não pode ser utilizado!')
		Else
			lRetcc :=  .T.		
		Endif
	Endif


Return lRetcc
