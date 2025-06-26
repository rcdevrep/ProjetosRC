#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'

#DEFINE QUEBRA Chr(13)+Chr(10)
 
User Function STX099CF()
 
    /* Variáveis Locais */
    Local oNewPag
    Local oStepWiz      := Nil
    Local oPanelBkg
    Local aArea		    := GetArea()
     
    /* Variáveis Privadas */
    Private oDlg        := Nil

    Private nVlrProds   := 0
    Private nVlrPCorr   := 0

    Private nVlrCOF     := 0
    Private nVlrCOFCorr := 0

    Private oGetTOrig
    Private oGetTCorr
    Private oGetDOrig
    Private oGetCOF

    Private oFont1
    Private oFontCabec

    Private bValCOF   := {|| fVldImp()}

	Static oMSGridProd
	Static oMSGridImp
     
    /* Define o tipo e tamanho da fonte */
    Define Font oFont1     Name "Arial" Size 9,18
    Define Font oFontCabec Name "Arial" Bold Size 7,18 
     
    /* Tela Inicial do Wizard */
    DEFINE DIALOG oDlg TITLE 'Rotina de Ajuste de COF do lançamento do documento fiscal' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

    If Empty(SF1->F1_STATUS)
        Help("",1,"Status NF",,"A nota fiscal selecionada ainda não foi classificada!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"A Nota fiscal pode ser ajustada no momento da classificação."})
        RestArea(aArea)
        Return
    EndIf
 
    /* Define tamanho da Dialog que comportará o Wizard */
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
    /* Define a página 1 com a função de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("1")
 
    /* Altera a descrição do step */
    oNewPag:SetStepDescription("Bem Vindo")
 
    /* Define o bloco de construção */
    oNewPag:SetConstruction({|Panel|cria_pg1(Panel)})
 
    /* Define o bloco ao clicar no botão Próximo */
    oNewPag:SetNextAction({||.T.})
     
    /* Define o bloco ao clicar no botão Cancelar */
    oNewPag:SetCancelAction({|| lOk:= MsgYesNo("Tem certeza que deseja cancelar?", "Confirmação"), If(lOk,oDlg:End(),.F.)})
 
 
    //**************************//
    // 2 - Pagina de Impostos   //
    //**************************//
    /* Define a página 3 com a função de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("2")
     
    /* Altera a descrição do step */
    oNewPag:SetStepDescription("Impostos")

    /* Define o bloco de construção */
    oNewPag:SetConstruction({|Panel|cria_pg2(Panel)})
     
    /* Define o bloco ao clicar no botão Próximo */
    oNewPag:SetNextAction({|| lOk:= processa_pg2(), If(lOk,oDlg:End(),.F.)})
     
    /* Define o bloco ao clicar no botão Cancelar */
    oNewPag:SetCancelAction({|| lOk:= MsgYesNo("Tem certeza que deseja cancelar?", "Confirmação"), If(lOk,oDlg:End(),.F.)})
     
    /* Ativa o Wizard */
    oStepWiz:Activate()
 
    ACTIVATE DIALOG oDlg CENTER
     
    /* Destrói o objeto no fechamento total do Wizard */
    oStepWiz:Destroy()

    RestArea(aArea)
Return
 

//--------------------------
// Construção da página 1
//--------------------------
Static Function cria_pg1(oPanel)
    
    oSay1	:= TSay():New(010,010,{|| 'Bem vindo...'},oPanel,,oFontCabec,,,,.T.,,,200,20)	
    oSay2	:= TSay():New(025,010,{|| 'A rotina a seguir irá disponibilizar os produtos da Nota Fiscal para os devidos ajustesde COF no lançamento.'},oPanel,,,,,,.T.,,,400,20)
    oSay3  	:= TSay():New(040,010,{|| 'Favor preencher os dados com atenção.'},oPanel,,,,,,.T.,,,400,20)
    oSay4	:= TSay():New(060,010,{|| 'Nota Fiscal/Série selecionada: ' + SF1->F1_DOC + '/' + SF1->F1_SERIE},oPanel,,oFontCabec,,,,.T.,,,200,20)	
    oSay4	:= TSay():New(075,010,{|| 'Fornecedor: ' + SF1->F1_FORNECE + ' - ' + Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")},oPanel,,oFontCabec,,,,.T.,,,300,20)	
    
Return


//--------------------------
// Construção da página 2
//--------------------------
Static Function cria_pg2(oPanel)
   
	Local aArea			:= GetArea()
	Local aAreaX3		:= SX3->(GetArea())
	Local nX			:= 0
	Local aHeaderEx		:= {}
	Local aColsEx		:= {}
	Local aFieldFill	:= {}
	Local aFields		:= {"D1_ITEM","D1_COD","D1_XDESCR","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_BASECOF","D1_ALQCOF","D1_VALCOF","NEW_BASECOF","NEW_ALIQ_COF","NEW_VAL_COF","PIS_COFINS"}
	Local aAlterFields	:= {"NEW_BASECOF","NEW_ALIQ_COF"}
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
    Local cDicCampo     := ""

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
        cDicCampo := If(aFields[nX] == "NEW_ALIQ_COF","D1_ALQCOF",If(aFields[nX] == "NEW_VAL_COF","D1_VALCOF",If(aFields[nX] == "PIS_COFINS","D1_VALCOF",If(aFields[nX] == "NEW_BASECOF","D1_BASECOF",aFields[nX]))))

        Aadd(aHeaderEx, {If(aFields[nX]=="NEW_ALIQ_COF","Aliq Correta",If(aFields[nX]=="NEW_VAL_COF","Val Correto",;
                                If(aFields[nX]=="PIS_COFINS","Diferença",If(aFields[nX]=="NEW_BASECOF","Base COFINS Correta",GetSX3Cache(cDicCampo, "X3_TITULO"))))),;
            If(aFields[nX] $ "NEW_ALIQ_COF/NEW_VAL_COF/PIS_COFINS/NEW_BASECOF",aFields[nX],GetSX3Cache(cDicCampo, "X3_CAMPO")),;
            GetSX3Cache(cDicCampo, "X3_PICTURE"),GetSX3Cache(cDicCampo, "X3_TAMANHO"),GetSX3Cache(cDicCampo, "X3_DECIMAL"),;
            If(aFields[nX] $ "NEW_ALIQ_COF/NEW_BASECOF","Eval(bValCOF)",GetSX3Cache(cDicCampo, "X3_VALID")),;
            If(aFields[nX] $ "NEW_ALIQ_COF/NEW_BASECOF",NIL,GetSX3Cache(cDicCampo, "X3_USADO")),;
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
                If aFields[nX] $ "NEW_ALIQ_COF"
                    Aadd(aFieldFill, (cAlias)->D1_ALQCOF)
                ElseIf aFields[nX] $ "NEW_VAL_COF"
				    Aadd(aFieldFill, (cAlias)->D1_VALCOF)
                ElseIf aFields[nX] $ "NEW_BASECOF"
				    Aadd(aFieldFill, (cAlias)->D1_BASECOF)
                ElseIf aFields[nX] $ "PIS_COFINS"
				    Aadd(aFieldFill, 0)
                Else
				    Aadd(aFieldFill, (cAlias)->&(aFields[nX]))
                EndIf
			Next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aFieldFill := {}
            nVlrCOF  += (cAlias)->D1_VALCOF
            nVlrCOFCorr  += (cAlias)->D1_VALCOF
			(cAlias)->(dbSkip())
		EndDo
	Else
		For nX := 1 to Len(aFields)
            If aFields[nX] $ "NEW_ALIQ_COF/NEW_VAL_COF/PIS_COFINS/NEW_BASECOF"
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

    oSay1	:= TSay():New(004,004,{|| 'Realize nesta tela as correções a respeito aos impostos dos produtos:'},oPanel,,oFontCabec,,,,.T.,,,300,20)

	oMSGridImp := MsNewGetDados():New( 014, 004, 160, 397, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",, aAlterFields,, 9999, "AllwaysTrue", "", "AllwaysTrue", oPanel, aHeaderEx, aColsEx)

    oSay2       := TSay():New(162,004,{|| 'Valor Cofins Informado:'},oPanel,,,,,,.T.,,,300,20)
    oGetDOrig   := TGet():New(169,004, bSetGet(nVlrCOF),oPanel, 080, 010, "@E 999,999,999.99", {|| .F.},,,,,, .T.,,, {||  .F.},,, {|| .F.}, .F., .F.,, "nVlrCOF",,,, .T.)
    oSay3	    := TSay():New(182,004,{|| 'Valor Cofins Corrigido:'},oPanel,,,,,,.T.,,,300,20)
    oGetCOF     := TGet():New(189,004, bSetGet(nVlrCOFCorr),oPanel, 080, 010, "@E 999,999,999.99", {|| .F.},,,,,, .T.,,, {||  .F.},,, {|| .F.}, .F., .F.,, "nVlrCOFCorr",,,, .T.)

	RestArea(aAreaX3)
	RestArea(aArea)

Return


//----------------------------------------
// Validação do botão Próximo da página 2
//----------------------------------------
Static Function processa_pg2()

    Local lReturn:= MsgYesNo("Confirma as alterações realizadas?", "Confirmação")

    If lReturn
        If nVlrProds == nVlrPCorr .And. nVlrCOF == nVlrCOFCorr
            MsgInfo("Nenhuma alteração foi realizada!" + QUEBRA + "Processo finalizado!", "Conclusão")
        Else
            oProcess := MsNewProcess():New({|| lReturn:= fAjustaNF(oProcess)}, "Realizando os ajustes na Nota Fiscal...", "Aguarde...", .T.)
            oProcess:Activate()

            If lReturn
                MsgInfo("Ajustes realizados com sucesso!" + QUEBRA + "Processo finalizado!", "Conclusão")
            Else
                MsgStop("Devido ao erro apresentado, todas as alterações foram descartadas!" + QUEBRA +;
                        "Em caso de dúvidas, favor abrir um chamado junto ao SGDesk.", "Atenção")
            EndIf
        EndIf
    EndIf

Return lReturn


//----------------------------------------------
// Função para validação dos impostos informados
// e atualização dos totalizadores
//----------------------------------------------
Static Function fVldImp()

    Local nX
    Local lRet      := .T.
	Local nPosVCOF	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'D1_VALCOF'})
    Local nPosNVCOF := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_VAL_COF'})
    Local nPosNACOF := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_COF'})
    Local nPosNBCOF := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASECOF'})
	Local nPosPISCOF:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'PIS_COFINS'})
    Local nAliqCOF  := If(ValType(M->NEW_ALIQ_COF) <> "U", M->NEW_ALIQ_COF,oMSGridImp:aCols[oMSGridImp:nAt][nPosNACOF])
    Local nValorBase:= If(ValType(M->NEW_BASECOF) <> "U", M->NEW_BASECOF, oMSGridImp:aCols[oMSGridImp:nAt][nPosNBCOF])
    
    If lRet .And. Valtype(oMSGridImp) <> "U"

        If ValType(M->NEW_ALIQ_COF) <> "U" .And. M->NEW_ALIQ_COF < 0
            MsgStop("O valor informado deve ser maior do que zero!", "Valor informado inválido")
            lRet    := .F.
        ElseIf ValType(M->NEW_BASECOF) <> "U" .And. M->NEW_BASECOF < 0
            MsgStop("O valor informado deve ser maior do que zero!", "Valor informado inválido")
            lRet    := .F.
        Else
            //oMSGridImp:aCols[oMSGridImp:nAt][nPosNVCOF] := oMSGridImp:aCols[oMSGridImp:nAt][nPosNBCOF] * M->NEW_ALIQ_COF / 100
            oMSGridImp:aCols[oMSGridImp:nAt][nPosNVCOF] := nValorBase * nAliqCOF / 100
            oMSGridImp:aCols[oMSGridImp:nAt][nPosPISCOF]:= oMSGridImp:aCols[oMSGridImp:nAt][nPosNVCOF] - oMSGridImp:aCols[oMSGridImp:nAt][nPosVCOF]

            nVlrCOFCorr := 0

            For nX := 1 To Len(oMSGridImp:aCols)
                nVlrCOFCorr  += oMSGridImp:aCols[nX][nPosVCOF] + oMSGridImp:aCols[nX][nPosPISCOF]
            Next nX

            oGetCOF:CtrlRefresh()
        EndIf
        
    EndIf
 
Return ( lRet )


//-----------------------------------------------
// Função para realizar os ajustes na Nota Fiscal
//-----------------------------------------------
Static Function fAjustaNF(oProcess)

    Local nX
	Local nPosCod	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'D1_COD'})
	Local nPosItem	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'D1_ITEM'})
	Local nPosDifDf	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'PIS_COFINS'})
    Local nValorTot := 0
    Local aArea		:= GetArea()
    Local lReturn 	:= .T.
    LOCAL oAjusteNF	:= NIL

    oProcess:SetRegua1(1)
    oProcess:IncRegua1("Processando ajustes relativos a impostos - COF...")

    If nVlrCOF <> nVlrCOFCorr

        //IncProc("Realizando ajustes relativos ao COF")
        oProcess:SetRegua2(3)

        SF4->(DbSetOrder(1))
        SD1->(DbSetOrder(1))
        oAjusteNF	:= Ajus99_NF():New()

        Begin Transaction

            // Percorro o Grid de Impostos
            For nX := 1 To Len(oMSGridImp:aCols)

                // Verifico se há ajuste de COF para realizar
                If oMSGridImp:aCols[nX][nPosDifDf] <> 0

                    // Localizo o Item na SD1
                    If SD1->(DBSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+oMSGridImp:aCols[nX][nPosCod]+oMSGridImp:aCols[nX][nPosItem]))

                        // Confirmo se a TES está preenchida, e se localizo a mesma na SF4
                        If !Empty(SD1->D1_TES) .And. SF4->(DBSeek(xFilial("SF4")+SD1->D1_TES))

                            //Passo 1 - Atualização dos Livros Fiscais
                            oProcess:IncRegua2("Processando ajustes nos livros fiscais...")
                            lReturn:= oAjusteNF:AtuLivro99(oMSGridImp, nX, "COFINS")

                            If !lReturn
                                DisarmTransaction()
                                Break
                            EndIf
                            
                            //Passo 2 - Atualização da Contabilidade
                            oProcess:IncRegua2("Processando ajustes na contabilidade...")
                            If !Empty(SF1->F1_DTLANC)
                                
                                // Só gero a contabilização de ajuste se a NF já tiver sido contabilida,
                                // pois se ela ainda não foi contabilizada, a mesma será realizada corretamente.
                                lReturn:= oAjusteNF:AtuCont99(oMSGridImp, nX, "COFINS")
                                //lReturn:= U_AtuCont99(oMSGridImp, nX, "COFINS")

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

                //Passo 3 - Atualização do Financeiro
                oProcess:IncRegua2("Processando ajustes no Financeiro...")
                lReturn:= oAjusteNF:AtuCtPag99(nValorTot, "COFINS")
                //lReturn:= U_AtuCtPag99(nValorTot, "COFINS")

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
