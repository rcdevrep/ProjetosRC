#Include "Totvs.ch"
#Include "FWMVCDef.ch"
 
//Variveis Estaticas
Static cTitulo := "Cadastro de Layouts"
Static cAliasMVC := "SX5"

User Function fLayout()
    Local aArea      := FWGetArea()
    Local oBrowse
    Local aInfoCab   := {}
    Local aColunas   := {}
    Private aRotina  := {}
    Private cTabGen  := ""
    Default cTabela  := "Z9"
    Default cTitTela := "Cadastro de Layouts"
 
    //Somente se tiver tabela
    If ! Empty(cTabela)
        //Atualiza a tabela em uso e o t�tulo
        cTabGen := cTabela
        cTitulo := cTitTela
 
        //Se o t�tulo tiver vazio, busca do cadastro do cabe�alho da tabela
        If Empty(cTitulo)
            aInfoCab := FWGetSX5("00", cTabGen)
            cTitulo  := Alltrim(Capital(aInfoCab[1][4]))
        EndIf
 
        //Definicao do menu
        aRotina := MenuDef()
 
        //Adiciona as colunas que v�o ser apresentadas no browse
        aAdd(aColunas, { 'C�digo',    'X5_CHAVE',     'C',  TamSX3('X5_CHAVE')[1],  0, ''})
        aAdd(aColunas, { 'Descri��o', 'X5_DESCRI',    'C',  TamSX3('X5_DESCRI')[1], 0, ''})
 
        //Instanciando o browse
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias(cAliasMVC)
        oBrowse:SetOnlyFields({"X5_FILIAL"})
        oBrowse:SetFields(aColunas)
        oBrowse:SetDescription(cTitulo)
        oBrowse:DisableDetails()
 
        //Filtrando conforme a tabela que veio
        oBrowse:SetFilterDefault("SX5->X5_TABELA == '" + cTabGen + "'")
 
        //Ativa a Browse
        oBrowse:Activate()
    EndIf
 
    FWRestArea(aArea)
Return Nil
 

 
Static Function MenuDef()
    Local aRotina := {}
 
    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.fLayout" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.fLayout" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.fLayout" OPERATION 4 ACCESS 0
    //ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.fLayout" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.fLayout" OPERATION 9 ACCESS 0
 
Return aRotina
 

 
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, cAliasMVC)
    Local oModel
    Local bPre := Nil
    Local bPos := {|| u_zSX5Vld()}
    Local bCancel := Nil
 
    //Editando caracter�sticas do dicion�rio
    oStruct:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edi��o
    oStruct:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabGen'))                   //Ini Padr�o
    oStruct:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edi��o
    oStruct:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'u_zSX5Vld()'))               //Valida��o de Campo
    oStruct:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigat�rio
    oStruct:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigat�rio
 
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("fLayoutM", bPre, bPos, /*bCommit*/, bCancel)
    oModel:AddFields("SX5MASTER", /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})
    oModel:SetDescription("Modelo de dados - " + cTitulo)
    oModel:GetModel("SX5MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({})
Return oModel
 

 
Static Function ViewDef()
    Local cCamposPrin := "X5_CHAVE|X5_DESCRI|"
    Local oModel := FWLoadModel("fLayout")
    Local oStructPrin := FWFormStruct(2, cAliasMVC, {|cCampo| AllTrim(cCampo) $ cCamposPrin})
    Local oStructOutr := FWFormStruct(2, cAliasMVC, {|cCampo| ! AllTrim(cCampo) $ cCamposPrin})
    Local oView
 
    //Retira as abas padr�es
    oStructPrin:SetNoFolder()
    oStructOutr:SetNoFolder()
 
    //Altera o t�tulo dos campos principais
    oStructPrin:SetProperty('X5_CHAVE',   MVC_VIEW_TITULO, 'C�digo')
    oStructPrin:SetProperty('X5_DESCRI',  MVC_VIEW_TITULO, 'Descri��o')
 
    //Altera o t�tulo dos outros campos
    oStructOutr:SetProperty('X5_TABELA',  MVC_VIEW_TITULO, 'C�digo Interno Tabela')
    oStructOutr:SetProperty('X5_DESCSPA', MVC_VIEW_TITULO, 'Descri��o Espanhol')
    oStructOutr:SetProperty('X5_DESCENG', MVC_VIEW_TITULO, 'Descri��o Ingl�s')
  
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_PRIN", oStructPrin, "SX5MASTER")
    oView:AddField("VIEW_OUTR", oStructOutr, "SX5MASTER")
  
    //Cria o controle de Abas
    oView:CreateFolder('ABAS')
    oView:AddSheet('ABAS', 'ABA_PRIN', 'Cadastro')
    oView:AddSheet('ABAS', 'ABA_OUTR', 'Outros Campos')
  
    //Cria os Box que ser�o vinculados as abas
    oView:CreateHorizontalBox('BOX_PRIN' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_PRIN')
    oView:CreateHorizontalBox('BOX_OUTR' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_OUTR')
  
    //Amarra as Abas aos Views de Struct criados
    oView:SetOwnerView('VIEW_PRIN', 'BOX_PRIN')
    oView:SetOwnerView('VIEW_OUTR', 'BOX_OUTR')
 
Return oView
 

  
User Function zSX5Vld()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cX5Chave := FWFldGet("X5_CHAVE")
    Local oModel   := FWModelActive()
    Local nOper    := oModel:GetOperation()
 
    //Se for opera��o de inclus�o (ou a c�pia)
    If nOper == 3
      
        DbSelectArea('SX5')
        SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
        SX5->(DbGoTop())
         
        //Se conseguir posicionar, j� existe
        If SX5->(DbSeek(FWxFilial('SX5') + cTabGen + cX5Chave))
            ExibeHelp("Help", "C�digo j� existe!", "Informe um c�digo diferente.")
            lRet := .F.
        EndIf
    EndIf
      
    RestArea(aArea)
Return lRet
