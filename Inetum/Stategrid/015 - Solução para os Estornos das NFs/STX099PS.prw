#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'

#DEFINE QUEBRA Chr(13)+Chr(10)
 
User Function STX099PS()
 
    /* Vari�veis Locais */
    Local oNewPag
    Local oStepWiz      := Nil
    Local oPanelBkg
    Local aArea		    := GetArea()
     
    /* Vari�veis Privadas */
    Private oDlg        := Nil

    Private nVlrProds   := 0
    Private nVlrPCorr   := 0

    Private nVlrPIS     := 0
    Private nVlrPISCorr := 0

    Private oGetTOrig
    Private oGetTCorr
    Private oGetDOrig
    Private oGetPIS

    Private oFont1
    Private oFontCabec

    Private bValPIS   := {|| fVldImp()}

	Static oMSGridProd
	Static oMSGridImp
     
    /* Define o tipo e tamanho da fonte */
    Define Font oFont1     Name "Arial" Size 9,18
    Define Font oFontCabec Name "Arial" Bold Size 7,18 
     
    /* Tela Inicial do Wizard */
    DEFINE DIALOG oDlg TITLE 'Rotina de Ajuste de PIS do lan�amento do documento fiscal' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

    If Empty(SF1->F1_STATUS)
        Help("",1,"Status NF",,"A nota fiscal selecionada ainda n�o foi classificada!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"A Nota fiscal pode ser ajustada no momento da classifica��o."})
        RestArea(aArea)
        Return
    EndIf
 
    /* Define tamanho da Dialog que comportar� o Wizard */
    oDlg:nWidth := 800
    oDlg:nHeight := 620

    /* Define o tamanho do painel do Wizard */
    oPanelBkg:= tPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT

    /* Instancia a classe FWWizard */
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
 
    //**************************//
    // 1 - Boas Vindas          //
    //**************************//
    /* Define a p�gina 1 com a fun��o de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("1")
 
    /* Altera a descri��o do step */
    oNewPag:SetStepDescription("Bem Vindo")
 
    /* Define o bloco de constru��o */
    oNewPag:SetConstruction({|Panel|cria_pg1(Panel)})
 
    /* Define o bloco ao clicar no bot�o Pr�ximo */
    oNewPag:SetNextAction({||.T.})
     
    /* Define o bloco ao clicar no bot�o Cancelar */
    oNewPag:SetCancelAction({|| lOk:= MsgYesNo("Tem certeza que deseja cancelar?", "Confirma��o"), If(lOk,oDlg:End(),.F.)})
 
 
    //**************************//
    // 2 - Pagina de Impostos   //
    //**************************//
    /* Define a p�gina 3 com a fun��o de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("2")
     
    /* Altera a descri��o do step */
    oNewPag:SetStepDescription("Impostos")

    /* Define o bloco de constru��o */
    oNewPag:SetConstruction({|Panel|cria_pg2(Panel)})
     
    /* Define o bloco ao clicar no bot�o Pr�ximo */
    oNewPag:SetNextAction({|| lOk:= processa_pg2(), If(lOk,oDlg:End(),.F.)})
     
    /* Define o bloco ao clicar no bot�o Cancelar */
    oNewPag:SetCancelAction({|| lOk:= MsgYesNo("Tem certeza que deseja cancelar?", "Confirma��o"), If(lOk,oDlg:End(),.F.)})
     
    /* Ativa o Wizard */
    oStepWiz:Activate()
 
    ACTIVATE DIALOG oDlg CENTER
     
    /* Destr�i o objeto no fechamento total do Wizard */
    oStepWiz:Destroy()

    RestArea(aArea)
Return
 

//--------------------------
// Constru��o da p�gina 1
//--------------------------
Static Function cria_pg1(oPanel)
    
    oSay1	:= TSay():New(010,010,{|| 'Bem vindo...'},oPanel,,oFontCabec,,,,.T.,,,200,20)	
    oSay2	:= TSay():New(025,010,{|| 'A rotina a seguir ir� disponibilizar os produtos da Nota Fiscal para os devidos ajustesde PIS no lan�amento.'},oPanel,,,,,,.T.,,,400,20)
    oSay3  	:= TSay():New(040,010,{|| 'Favor preencher os dados com aten��o.'},oPanel,,,,,,.T.,,,400,20)
    oSay4	:= TSay():New(060,010,{|| 'Nota Fiscal/S�rie selecionada: ' + SF1->F1_DOC + '/' + SF1->F1_SERIE},oPanel,,oFontCabec,,,,.T.,,,200,20)	
    oSay4	:= TSay():New(075,010,{|| 'Fornecedor: ' + SF1->F1_FORNECE + ' - ' + Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")},oPanel,,oFontCabec,,,,.T.,,,300,20)	
    
Return


//--------------------------
// Constru��o da p�gina 2
//--------------------------
Static Function cria_pg2(oPanel)
   
	Local aArea			:= GetArea()
	Local aAreaX3		:= SX3->(GetArea())
	Local nX			:= 0
	Local aHeaderEx		:= {}
	Local aColsEx		:= {}
	Local aFieldFill	:= {}
	Local aFields		:= {"D1_ITEM","D1_COD","D1_XDESCR","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_BASEPIS","D1_ALQPIS","D1_VALPIS","NEW_BASEPIS","NEW_ALIQ_PIS","NEW_VAL_PIS","PIS_PIS"}
	Local aAlterFields	:= {"NEW_BASEPIS","NEW_ALIQ_PIS"}
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
    Local cDicCampo     := ""

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
        cDicCampo := If(aFields[nX] == "NEW_ALIQ_PIS","D1_ALQPIS",If(aFields[nX] == "NEW_VAL_PIS","D1_VALPIS",If(aFields[nX] == "PIS_PIS","D1_VALPIS",If(aFields[nX] == "NEW_BASEPIS","D1_BASEPIS",aFields[nX]))))

        Aadd(aHeaderEx, {If(aFields[nX]=="NEW_ALIQ_PIS","Aliq Correta",If(aFields[nX]=="NEW_VAL_PIS","Val Correto",;
                                If(aFields[nX]=="PIS_PIS","Diferen�a",If(aFields[nX]=="NEW_BASEPIS","Base PIS Correta",GetSX3Cache(cDicCampo, "X3_TITULO"))))),;
            If(aFields[nX] $ "NEW_ALIQ_PIS/NEW_VAL_PIS/PIS_PIS/NEW_BASEPIS",aFields[nX],GetSX3Cache(cDicCampo, "X3_CAMPO")),;
            GetSX3Cache(cDicCampo, "X3_PICTURE"),GetSX3Cache(cDicCampo, "X3_TAMANHO"),GetSX3Cache(cDicCampo, "X3_DECIMAL"),;
            If(aFields[nX] $ "NEW_ALIQ_PIS/NEW_BASEPIS","Eval(bValPIS)",GetSX3Cache(cDicCampo, "X3_VALID")),;
            If(aFields[nX] $ "NEW_ALIQ_PIS/NEW_BASEPIS",NIL,GetSX3Cache(cDicCampo, "X3_USADO")),;
            GetSX3Cache(cDicCampo, "X3_TIPO"),GetSX3Cache(cDicCampo, "X3_F3"),GetSX3Cache(cDicCampo, "X3_CONTEXT"),GetSX3Cache(cDicCampo, "X3_CBOX"),;
            GetSX3Cache(cDicCampo, "X3_RELACAO")})
	Next nX

	cQuery := "SELECT * "
	cQuery += "FROM "+RETSQLNAME("SD1")+" (NOLOCK) WHERE "
	cQuery += "D_E_L_E_T_ = '' AND D1_FILIAL = '"+SF1->F1_FILIAL+"' AND "
	cQuery += "D1_DOC = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"' AND "
	cQuery += "D1_FORNECE = '"+SF1->F1_FORNECE+"' AND D1_LOJA = '"+SF1->F1_LOJA+"' "
	cQuery += "ORDER BY D1_ITEM"
	TCQuery cQuery NEW ALIAS (cAlias)

	if !(cAlias)->(Eof())
		While !(cAlias)->(Eof())
			For nX := 1 to Len(aFields)
                If aFields[nX] $ "NEW_ALIQ_PIS"
                    Aadd(aFieldFill, (cAlias)->D1_ALQPIS)
                ElseIf aFields[nX] $ "NEW_VAL_PIS"
				    Aadd(aFieldFill, (cAlias)->D1_VALPIS)
                ElseIf aFields[nX] $ "NEW_BASEPIS"
				    Aadd(aFieldFill, (cAlias)->D1_BASEPIS)
                ElseIf aFields[nX] $ "PIS_PIS"
				    Aadd(aFieldFill, 0)
                Else
				    Aadd(aFieldFill, (cAlias)->&(aFields[nX]))
                EndIf
			Next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aFieldFill := {}
            nVlrPIS  += (cAlias)->D1_VALPIS
            nVlrPISCorr  += (cAlias)->D1_VALPIS
			(cAlias)->(dbSkip())
		EndDo
	Else
		For nX := 1 to Len(aFields)
            If aFields[nX] $ "NEW_ALIQ_PIS/NEW_VAL_PIS/PIS_PIS/NEW_BASEPIS"
                Aadd(aFieldFill, 0)
            Else
                Aadd(aFieldFill, CriaVar(aFields[nX]))
            EndIf
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	EndIf

	(cAlias)->(dbCloseArea())
	RestArea(aAreaX3)
	RestArea(aArea)

    oSay1	:= TSay():New(004,004,{|| 'Realize nesta tela as corre��es a respeito aos impostos dos produtos:'},oPanel,,oFontCabec,,,,.T.,,,300,20)

	oMSGridImp := MsNewGetDados():New( 014, 004, 160, 397, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",, aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oPanel, aHeaderEx, aColsEx)

    oSay2       := TSay():New(162,004,{|| 'Valor PIS Informado:'},oPanel,,,,,,.T.,,,300,20)
    oGetDOrig   := TGet():New(169,004, bSetGet(nVlrPIS),oPanel, 080, 010, "@E 999,999,999.99", {|| .F.},,,,,, .T.,,, {||  .F.},,, {|| .F.}, .F., .F.,, "nVlrPIS",,,, .T.)
    oSay3	    := TSay():New(182,004,{|| 'Valor PIS Corrigido:'},oPanel,,,,,,.T.,,,300,20)
    oGetPIS     := TGet():New(189,004, bSetGet(nVlrPISCorr),oPanel, 080, 010, "@E 999,999,999.99", {|| .F.},,,,,, .T.,,, {||  .F.},,, {|| .F.}, .F., .F.,, "nVlrPISCorr",,,, .T.)

	RestArea(aAreaX3)
	RestArea(aArea)

Return


//----------------------------------------
// Valida��o do bot�o Pr�ximo da p�gina 2
//----------------------------------------
Static Function processa_pg2()

    Local lReturn:= MsgYesNo("Confirma as altera��es realizadas?", "Confirma��o")

    If lReturn
        If nVlrProds == nVlrPCorr .And. nVlrPIS == nVlrPISCorr
            MsgInfo("Nenhuma altera��o foi realizada!" + QUEBRA + "Processo finalizado!", "Conclus�o")
        Else
            oProcess := MsNewProcess():New({|| lReturn:= fAjustaNF(oProcess)}, "Realizando os ajustes na Nota Fiscal...", "Aguarde...", .T.)
            oProcess:Activate()

            If lReturn
                MsgInfo("Ajustes realizados com sucesso!" + QUEBRA + "Processo finalizado!", "Conclus�o")
            Else
                MsgStop("Devido ao erro apresentado, todas as altera��es foram descartadas!" + QUEBRA +;
                        "Em caso de d�vidas, favor abrir um chamado junto ao SGDesk.", "Aten��o")
            EndIf
        EndIf
    EndIf

Return lReturn


//----------------------------------------------
// Fun��o para valida��o dos impostos informados
// e atualiza��o dos totalizadores
//----------------------------------------------
Static Function fVldImp()

    Local nX
    Local lRet      := .T.
	Local nPosVPIS	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'D1_VALPIS'})
    Local nPosNVPIS := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_VAL_PIS'})
    Local nPosNAPIS := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_PIS'})
    Local nPosNBPIS := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASEPIS'})
	Local nPosPISPIS:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'PIS_PIS'})
    Local nAliqPIS  := If(ValType(M->NEW_ALIQ_PIS) <> "U", M->NEW_ALIQ_PIS,oMSGridImp:aCols[oMSGridImp:nAt][nPosNAPIS])
    Local nValorBase:= If(ValType(M->NEW_BASEPIS) <> "U", M->NEW_BASEPIS, oMSGridImp:aCols[oMSGridImp:nAt][nPosNBPIS])
    
    If lRet .And. Valtype(oMSGridImp) <> "U"

        If ValType(M->NEW_ALIQ_PIS) <> "U" .And. M->NEW_ALIQ_PIS < 0
            MsgStop("O valor informado deve ser maior do que zero!", "Valor informado inv�lido")
            lRet    := .F.
        ElseIf ValType(M->NEW_BASEPIS) <> "U" .And. M->NEW_BASEPIS < 0
            MsgStop("O valor informado deve ser maior do que zero!", "Valor informado inv�lido")
            lRet    := .F.
        Else
            //oMSGridImp:aCols[oMSGridImp:nAt][nPosNVPIS] := oMSGridImp:aCols[oMSGridImp:nAt][nPosNBPIS] * M->NEW_ALIQ_PIS / 100
            oMSGridImp:aCols[oMSGridImp:nAt][nPosNVPIS] := nValorBase * nAliqPIS / 100
            oMSGridImp:aCols[oMSGridImp:nAt][nPosPISPIS]:= oMSGridImp:aCols[oMSGridImp:nAt][nPosNVPIS] - oMSGridImp:aCols[oMSGridImp:nAt][nPosVPIS]

            nVlrPISCorr := 0

            For nX := 1 To Len(oMSGridImp:aCols)
                nVlrPISCorr  += oMSGridImp:aCols[nX][nPosVPIS] + oMSGridImp:aCols[nX][nPosPISPIS]
            Next nX

            oGetPIS:CtrlRefresh()
        EndIf
        
    EndIf
 
Return ( lRet )


//-----------------------------------------------
// Fun��o para realizar os ajustes na Nota Fiscal
//-----------------------------------------------
Static Function fAjustaNF(oProcess)

    Local nX
	Local nPosCod	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'D1_COD'})
	Local nPosItem	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'D1_ITEM'})
	Local nPosDifDf	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'PIS_PIS'})
    Local nValorTot := 0
    Local aArea		:= GetArea()
    Local lReturn 	:= .T.
    LOCAL oAjusteNF	:= NIL

    oProcess:SetRegua1(1)
    oProcess:IncRegua1("Processando ajustes relativos a impostos - PIS...")

    If nVlrPIS <> nVlrPISCorr

        //IncProc("Realizando ajustes relativos ao PIS")
        oProcess:SetRegua2(3)

        SF4->(DbSetOrder(1))
        SD1->(DbSetOrder(1))
        oAjusteNF	:= Ajus99_NF():New()

        Begin Transaction

            // Percorro o Grid de Impostos
            For nX := 1 To Len(oMSGridImp:aCols)

                // Verifico se h� ajuste de PIS para realizar
                If oMSGridImp:aCols[nX][nPosDifDf] <> 0

                    // Localizo o Item na SD1
                    If SD1->(DBSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+oMSGridImp:aCols[nX][nPosCod]+oMSGridImp:aCols[nX][nPosItem]))

                        // Confirmo se a TES est� preenchida, e se localizo a mesma na SF4
                        If !Empty(SD1->D1_TES) .And. SF4->(DBSeek(xFilial("SF4")+SD1->D1_TES))

                            //Passo 1 - Atualiza��o dos Livros Fiscais
                            oProcess:IncRegua2("Processando ajustes nos livros fiscais...")
                            lReturn:= oAjusteNF:AtuLivro99(oMSGridImp, nX, "PIS")

                            If !lReturn
                                DisarmTransaction()
                                Break
                            EndIf
                            
                            //Passo 2 - Atualiza��o da Contabilidade
                            oProcess:IncRegua2("Processando ajustes na contabilidade...")
                            If !Empty(SF1->F1_DTLANC)
                                
                                // S� gero a contabiliza��o de ajuste se a NF j� tiver sido contabilida,
                                // pois se ela ainda n�o foi contabilizada, a mesma ser� realizada corretamente.
                                lReturn:= oAjusteNF:AtuCont99(oMSGridImp, nX, "PIS")
                                //lReturn:= U_AtuCont99(oMSGridImp, nX, "PIS")

                                If !lReturn
                                    DisarmTransaction()
                                    Break
                                EndIf
                            EndIf
                            
                        EndIf

                    EndIf

                    nValorTot+= oMSGridImp:aCols[nX][nPosDifDf]

                EndIf

            Next nX

            If nValorTot <> 0

                //Passo 3 - Atualiza��o do Financeiro
                oProcess:IncRegua2("Processando ajustes no Financeiro...")
                lReturn:= oAjusteNF:AtuCtPag99(nValorTot, "PIS")
                //lReturn:= U_AtuCtPag99(nValorTot, "PIS")

                If !lReturn
                    DisarmTransaction()
                    Break
                EndIf

            EndIf

        End Transaction

        FreeObj(oAjusteNF)

    EndIf

    RestArea(aArea)

Return lReturn
