#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'

#DEFINE QUEBRA Chr(13)+Chr(10)
 
User Function STX099IN()
 
    /* Variáveis Locais */
    Local oNewPag
    Local oStepWiz      := Nil
    Local oPanelBkg
    Local aArea		    := GetArea()
     
    /* Variáveis Privadas */
    Private oDlg        := Nil

    Private nVlrProds   := 0
    Private nVlrPCorr   := 0

    Private nVlrINS     := 0
    Private nVlrINSCorr := 0

    Private oGetTOrig
    Private oGetTCorr
    Private oGetDOrig
    Private oGetINS

    Private oFont1
    Private oFontCabec

    Private bValINS   := {|| fVldImp()}

	Static oMSGridProd
	Static oMSGridImp
     
    /* Define o tipo e tamanho da fonte */
    Define Font oFont1     Name "Arial" Size 9,18
    Define Font oFontCabec Name "Arial" Bold Size 7,18 
     
    /* Tela Inicial do Wizard */
    DEFINE DIALOG oDlg TITLE 'Rotina de Ajuste de INS do lançamento do documento fiscal' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

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
    oSay2	:= TSay():New(025,010,{|| 'A rotina a seguir irá disponibilizar os produtos da Nota Fiscal para os devidos ajustesde INS no lançamento.'},oPanel,,,,,,.T.,,,400,20)
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
	Local aFields		:= {"D1_ITEM","D1_COD","D1_XDESCR","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_BASEINS","D1_ALIQINS","D1_VALINS","NEW_BASEINS","NEW_ALIQ_INS","NEW_VAL_INS","PIS_INSS"}
	Local aAlterFields	:= {"NEW_BASEINS","NEW_ALIQ_INS"}
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
    Local cDicCampo     := ""

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
        cDicCampo := If(aFields[nX] == "NEW_ALIQ_INS","D1_ALIQINS",If(aFields[nX] == "NEW_VAL_INS","D1_VALINS",If(aFields[nX] == "PIS_INSS","D1_VALINS",If(aFields[nX] == "NEW_BASEINS","D1_BASEINS",aFields[nX]))))

        Aadd(aHeaderEx, {If(aFields[nX]=="NEW_ALIQ_INS","Aliq Correta",If(aFields[nX]=="NEW_VAL_INS","Val Correto",;
                                If(aFields[nX]=="PIS_INSS","Diferença",If(aFields[nX]=="NEW_BASEINS","Base INSS Correta",GetSX3Cache(cDicCampo, "X3_TITULO"))))),;
            If(aFields[nX] $ "NEW_ALIQ_INS/NEW_VAL_INS/PIS_INSS/NEW_BASEINS",aFields[nX],GetSX3Cache(cDicCampo, "X3_CAMPO")),;
            GetSX3Cache(cDicCampo, "X3_PICTURE"),GetSX3Cache(cDicCampo, "X3_TAMANHO"),GetSX3Cache(cDicCampo, "X3_DECIMAL"),;
            If(aFields[nX] $ "NEW_ALIQ_INS/NEW_BASEINS","Eval(bValINS)",GetSX3Cache(cDicCampo, "X3_VALID")),;
            If(aFields[nX] $ "NEW_ALIQ_INS/NEW_BASEINS",NIL,GetSX3Cache(cDicCampo, "X3_USADO")),;
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
                If aFields[nX] $ "NEW_ALIQ_INS"
                    Aadd(aFieldFill, (cAlias)->D1_ALIQINS)
                ElseIf aFields[nX] $ "NEW_VAL_INS"
				    Aadd(aFieldFill, (cAlias)->D1_VALINS)
                ElseIf aFields[nX] $ "NEW_BASEINS"
				    Aadd(aFieldFill, (cAlias)->D1_BASEINS)
                ElseIf aFields[nX] $ "PIS_INSS"
				    Aadd(aFieldFill, 0)
                Else
				    Aadd(aFieldFill, (cAlias)->&(aFields[nX]))
                EndIf
			Next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			aFieldFill := {}
            nVlrINS  += (cAlias)->D1_VALINS
            nVlrINSCorr  += (cAlias)->D1_VALINS
			(cAlias)->(dbSkip())
		EndDo
	Else
		For nX := 1 to Len(aFields)
            If aFields[nX] $ "NEW_ALIQ_INS/NEW_VAL_INS/PIS_INSS/NEW_BASEINS"
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

    oSay2       := TSay():New(162,004,{|| 'Valor INSS Informado:'},oPanel,,,,,,.T.,,,300,20)
    oGetDOrig   := TGet():New(169,004, bSetGet(nVlrINS),oPanel, 080, 010, "@E 999,999,999.99", {|| .F.},,,,,, .T.,,, {||  .F.},,, {|| .F.}, .F., .F.,, "nVlrINS",,,, .T.)
    oSay3	    := TSay():New(182,004,{|| 'Valor INSS Corrigido:'},oPanel,,,,,,.T.,,,300,20)
    oGetINS     := TGet():New(189,004, bSetGet(nVlrINSCorr),oPanel, 080, 010, "@E 999,999,999.99", {|| .F.},,,,,, .T.,,, {||  .F.},,, {|| .F.}, .F., .F.,, "nVlrINSCorr",,,, .T.)

	RestArea(aAreaX3)
	RestArea(aArea)

Return


//----------------------------------------
// Validação do botão Próximo da página 2
//----------------------------------------
Static Function processa_pg2()

    Local lReturn:= MsgYesNo("Confirma as alterações realizadas?", "Confirmação")

    If lReturn
        If nVlrProds == nVlrPCorr .And. nVlrINS == nVlrINSCorr
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
	Local nPosVINS	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'D1_VALINS'})
    Local nPosNVINS := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_VAL_INS'})
    Local nPosNAINS := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_INS'})
    Local nPosNBINS := aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASEINS'})
	Local nPosPISINS:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'PIS_INSS'})
    Local nAliqINS  := If(ValType(M->NEW_ALIQ_INS) <> "U", M->NEW_ALIQ_INS,oMSGridImp:aCols[oMSGridImp:nAt][nPosNAINS])
    Local nValorBase:= If(ValType(M->NEW_BASEINS) <> "U", M->NEW_BASEINS, oMSGridImp:aCols[oMSGridImp:nAt][nPosNBINS])
    
    If lRet .And. Valtype(oMSGridImp) <> "U"

        If ValType(M->NEW_ALIQ_INS) <> "U" .And. M->NEW_ALIQ_INS < 0
            MsgStop("O valor informado deve ser maior do que zero!", "Valor informado inválido")
            lRet    := .F.
        ElseIf ValType(M->NEW_BASEINS) <> "U" .And. M->NEW_BASEINS < 0
            MsgStop("O valor informado deve ser maior do que zero!", "Valor informado inválido")
            lRet    := .F.
        Else
            //oMSGridImp:aCols[oMSGridImp:nAt][nPosNVINS] := oMSGridImp:aCols[oMSGridImp:nAt][nPosNBINS] * M->NEW_ALIQ_INS / 100
            oMSGridImp:aCols[oMSGridImp:nAt][nPosNVINS] := nValorBase * nAliqINS / 100
            oMSGridImp:aCols[oMSGridImp:nAt][nPosPISINS]:= oMSGridImp:aCols[oMSGridImp:nAt][nPosNVINS] - oMSGridImp:aCols[oMSGridImp:nAt][nPosVINS]

            nVlrINSCorr := 0

            For nX := 1 To Len(oMSGridImp:aCols)
                nVlrINSCorr  += oMSGridImp:aCols[nX][nPosVINS] + oMSGridImp:aCols[nX][nPosPISINS]
            Next nX

            oGetINS:CtrlRefresh()
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
	Local nPosDifDf	:= aScan(oMSGridImp:aHeader,{|x| AllTrim(x[2]) == 'PIS_INSS'})
    Local nValorTot := 0
    Local aArea		:= GetArea()
    Local lReturn 	:= .T.
    LOCAL oAjusteNF	:= NIL

    oProcess:SetRegua1(1)
    oProcess:IncRegua1("Processando ajustes relativos a impostos - INS...")

    If nVlrINS <> nVlrINSCorr

        //IncProc("Realizando ajustes relativos ao INS")
        oProcess:SetRegua2(3)

        SF4->(DbSetOrder(1))
        SD1->(DbSetOrder(1))
        oAjusteNF	:= Ajus99_NF():New()

        Begin Transaction

            // Percorro o Grid de Impostos
            For nX := 1 To Len(oMSGridImp:aCols)

                // Verifico se há ajuste de INS para realizar
                If oMSGridImp:aCols[nX][nPosDifDf] <> 0

                    // Localizo o Item na SD1
                    If SD1->(DBSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+oMSGridImp:aCols[nX][nPosCod]+oMSGridImp:aCols[nX][nPosItem]))

                        // Confirmo se a TES está preenchida, e se localizo a mesma na SF4
                        If !Empty(SD1->D1_TES) .And. SF4->(DBSeek(xFilial("SF4")+SD1->D1_TES))

                            //Passo 1 - Atualização dos Livros Fiscais
                            oProcess:IncRegua2("Processando ajustes nos livros fiscais...")
                            lReturn:= oAjusteNF:AtuLivro99(oMSGridImp, nX, "INSS")

                            If !lReturn
                                DisarmTransaction()
                                Break
                            EndIf
                            
                            //Passo 2 - Atualização da Contabilidade
                            oProcess:IncRegua2("Processando ajustes na contabilidade...")
                            If !Empty(SF1->F1_DTLANC)
                                
                                // Só gero a contabilização de ajuste se a NF já tiver sido contabilida,
                                // pois se ela ainda não foi contabilizada, a mesma será realizada corretamente.
                                lReturn:= oAjusteNF:AtuCont99(oMSGridImp, nX, "INSS")
                                //lReturn:= U_AtuCont99(oMSGridImp, nX, "INSS")

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
                lReturn:= oAjusteNF:AtuCtPag99(nValorTot, "INSS")
                //lReturn:= U_AtuCtPag99(nValorTot, "INSS")

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
