#Include "Totvs.ch"
 
/*/{Protheus.doc} zCCHWizard
    @description: Gera��o de Tela do Wizard Exemplo
    @author Caio C�sar Henrique
    @since 14/08/2019
    @version version
/*/
 
User Function zCCHWizard()

    Local oStepWiz:= FWWizardControl():New(oOwner)
 
    /* Vari�veis Locais */
    Local oPanel
    Local oNewPag
   // Local oStepWiz  := Nil
    Local oDlg      := Nil
    Local oPanelBkg
     
    /* Vari�veis Privadas */
    Private cFile    := ''
    Private cProduto := Space(15)
    Private cCombo1 := ''
 
    Private oFont1
    Private oFontCabec
    Private oBrwTrb
     
    /* Define o tipo e tamanho da fonte */
    Define Font oFont1     Name "Verdana" Size 9,18
    Define Font oFontCabec Name "Verdana" Bold Size 7,18 
     
    /* Tela Inicial do Wizard */
    DEFINE DIALOG oDlg TITLE 'zCCHWizard - Exemplo de Utiliza��o' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
 
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
    // 1 - Pagina de Introdu��o //
    //**************************//
    /* Define a p�gina 1 com a fun��o de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("1")
 
    /* Altera a descri��o do step */
    oNewPag:SetStepDescription("Par�metros")
 
    /* Define o bloco de constru��o */
    oNewPag:SetConstruction({|Panel|CteXml_Pg1(Panel)})
 
    /* Define o bloco ao clicar no bot�o Pr�ximo */
    oNewPag:SetNextAction({|| CteVal_Pg1()})
     
    /* Define o bloco ao clicar no bot�o Cancelar */
    oNewPag:SetCancelAction({|| .T., oDlg:End()})
 
    //**************************//
    // 2 - Pagina de Resultado  //
    //**************************//
     
    /* Define a p�gina 2 com a fun��o de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("2", {|Panel|CteXml_Pg2(Panel)})
     
    /* Altera a descri��o do step */
    oNewPag:SetStepDescription("Resultado")
     
    /* Define o bloco ao clicar no bot�o Pr�ximo */
    oNewPag:SetNextAction({|| .T., oDlg:End()})
     
    /* Define o bloco ao clicar no bot�o Cancelar */
    oNewPag:SetCancelAction({|| .T., .F.})
     
    /* Define o que ser� executado se clicar em Cancelar ou Voltar */
    oNewPag:SetPrevAction({|| ConOut('A��o n�o permitida'), .F.})
     
    /* Define o t�tulo da tela anterior */
    oNewPag:SetPrevTitle(" -- ") 
     
    /* Define se permite cancelar */
    oNewPag:SetCancelWhen({||.F.})
     
    /* Ativa o Wizard */
    oStepWiz:Activate()
 
    ACTIVATE DIALOG oDlg CENTER
     
    /* Destr�i o objeto no fechamento total do Wizard */
    oStepWiz:Destroy()
Return
 
/*/{Protheus.doc} zCCHWizard
    @description: Gera��o de Tela do Wizard Exemplo
    @author Caio C�sar Henrique
    @since 14/08/2019
    @version version
/*/
Static Function CteXml_Pg1(oPanel)
 
    /* Vari�veis Locais */
    Local cDesc    := ''
    Local nQuant   := 0 
    Local oSay1 
    Local oSay2 
    Local oSay3 
    Local oSay4 
    Local oSay5
    Local oSay6
    Local oGet
    Local oGet2
    Local oButton1
    Local oCombo1
    Local oCheck
    Local aItens  := {'1=N�o','2=Sim'}
     
    /* Vari�veis Privadas */
    Private cColorBackGround     := "#FFFFFF"       
    Private cColorSeparator     := "#C0C0C0"       
    Private cGradientTop         := "#FFFFFF"
 
    /* Gradiente inicial do bot�o selecionado */   
    Private cGradientBottom     := "#FFFFFF"
     
    /* Gradiente final do bot�o selecionado */       
    Private cColorText        := "#990000"        
     
    dbSelectArea('SB1')
 
    /* Determina objetos da Tela (TSay, TButton, TGet) */
    oSay1    := TSay():New(10,10,{||'Por favor, selecione a pasta dos arquivos XML'},oPanel,,oFontCabec,,,,.T.,,,200,20)
 
    oSay2    := TSay():New(26,10,{|| 'Caminho: '       },oPanel,,oFont1,,,,.T.,CLR_RED,CLR_WHITE,70,30)
    oGet     := TGet():New(25,55,{|u| If(PCount() > 0,cFile := ' ',cFile)},oPanel,120,10,'@!S100',,,,,,,.T.,,,,,,,.T.,,,'cFile')
    oButton1 := TButton():New(25,179,'Pesquisar',oPanel,{|| cFile:=AllTrim(cGetFile("Arquivo (*.xml)|*.xml","Selecione o "+; 
    "arquivo",,"C:\",.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY))},40,12,,,,.T.)
 
    oSay3    := TSay():New(50,10,{||'Defina a parametriza��o'},oPanel,,oFontCabec,,,,.T.,,,200,20)
 
    oSay4    := TSay():New(66,10,{|| 'Produto: '       },oPanel,,oFont1,,,,.T.,CLR_RED,CLR_WHITE,70,30)
    oGet2    := TGet():New(65,55,{|x| If(PCount() > 0,cProduto := x,cProduto)},oPanel,120,10,PesqPict("SB1","B1_COD"),{|| CTeValProd(@cProduto,@cDesc)},,,/*font*/,,,.T.,,,{|| .T.},,,/*change*/,.F.,.F.,,"cProduto")
    oGet2:bF3 := &('{|| IIf(ConPad1(,,,"SB1",,,.F.),Eval({|| cProduto := SB1->B1_COD,cDesc := SB1->B1_DESC, oGet2:Refresh()}),.T.)}')
 
    oSay5    := TSay():New(67,180,{|| IIf(!Empty(cProduto),'-> '+AllTrim(cDesc),cProduto := Space(15))      },oPanel,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,200,30)
 
    oSay6    := TSay():New(91,10,{|| 'Relat�rio: '       },oPanel,,oFont1,,,,.T.,CLR_RED,CLR_WHITE,70,30)
    oCombo1  := TComboBox():New(90,55,{|u|if(PCount() > 0, cCombo1 := u,cCombo1)},aItens,120,10,oPanel,,{||.T.},,,,.T.,,,,,,,,,'cCombo1')
Return ( Nil )
 
/*/{Protheus.doc} zCCHWizard
    @description: Gera��o de Tela do Wizard Exemplo
    @author Caio C�sar Henrique
    @since 14/08/2019
    @version version
/*/
Static Function CteVal_Pg1(oPanel)
 
    Local lRet := .T.
 
    /* Valida preenchimento do campo Produto e Arquivo */
    If Empty(cFile) .or. Empty(cProduto)
        Alert('Por favor, preencher Caminho e/ou Produto')
        lRet := .F.
    EndIf 
 
Return ( lRet )
 
/*/{Protheus.doc} zCCHWizard
    @description: Gera��o de Tela do Wizard Exemplo
    @author Caio C�sar Henrique
    @since 14/08/2019
    @version version
/*/
Static Function CteXml_Pg2(oPanel)
     
    Local oSay
 
    /* Encerra mensagem final */
    oSay    := TSay():New(70,100,{||'Wizard Encerrado'},oPanel,,oFontCabec,,,,.T.,,,200,20)
 
Return ( Nil )
 
/*/{Protheus.doc} zCCHWizard
    @description: Gera��o de Tela do Wizard Exemplo
    @author Caio C�sar Henrique
    @since 14/08/2019
    @version version
/*/
 
Static Function CTeValProd(cProduto,cDesc)
 
    Local cProd := cProduto 
    Local aArea := GetArea()
    Local lRet  := .F. 
 
    /* Carrega descri��o do Produto ao gatilhar o c�digo */
    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))
 
    If SB1->(dbSeek(xFilial("SB1")+AllTrim(cProd)))
        lRet := .T. 
        cDesc := SB1->B1_DESC
    Else 
        lRet := .F.
    EndIf 
 
    RestArea(aArea)
 
Return ( lRet )
