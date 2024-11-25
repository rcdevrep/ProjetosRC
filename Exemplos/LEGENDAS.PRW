//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "TopConn.ch"
 
//Variveis Estaticas
Static cTitulo := "Pré-Orçamento"
Static cTabPai := "Z03"
Static cTabFilho := "Z04"
 
/*/{Protheus.doc} User Function AFATA04
Pré-Orçamento
@author Daniel Atilio
@since 15/04/2021
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
User Function AFATA04()
    Local aArea   := GetArea()
    Local oBrowse
    Private aRotina := {}
 
    //Definicao do menu
    aRotina := MenuDef()
 
    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cTabPai)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
 
    //Adicionando as Legendas
    oBrowse:AddLegend( "Z03->Z03_STATUS == '2' .AND. Z03->Z03_NUM != 'XXXXXX'", "GREEN",    "Importado" )
    oBrowse:AddLegend( "Z03->Z03_STATUS == '1' .AND. Empty(Z03->Z03_NUM)", "YELLOW",    "Pendente Importação" )
    oBrowse:AddLegend( "Z03->Z03_STATUS == '1' .AND. Z03->Z03_NUM == 'XXXXXX'", "RED",    "Erro na Importação" )
 
    //Ativa a Browse
    oBrowse:Activate()
 
    RestArea(aArea)
Return Nil
 
/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao AFATA04
@author Daniel Atilio
@since 15/04/2021
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
Static Function MenuDef()
    Local aRotina := {}
 
    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.AFATA04" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"  ACTION "VIEWDEF.AFATA04" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Processar"  ACTION "u_AFORM02()" OPERATION 4 ACCESS 0
 
Return aRotina
 
/*/{Protheus.doc} ModelDef
Modelo de dados na funcao AFATA04
@author Daniel Atilio
@since 15/04/2021
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
Static Function ModelDef()
    Local oStruPai := FWFormStruct(1, cTabPai)
    Local oStruFilho := FWFormStruct(1, cTabFilho)
    Local aRelation := {}
    Local oModel
    Local bPre := Nil
    Local bPos := Nil
    Local bCommit := Nil
    Local bCancel := Nil
 
    oStruFilho:AddField( ;
        AllTrim('') , ;               // [01] C Titulo do campo
        AllTrim('') , ;               // [02] C ToolTip do campo
        'Z04_LEGEND' , ;               // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                      // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de validação do campo
        NIL , ;                     // [08] B Code-block de validação When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
        { || Iif(u_zRetSald(Z04->Z04_FILIAL, Z04->Z04_PRODUT) >= Z04->Z04_QUANT, "BR_BRANCO","BR_PRETO") } , ;           // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
        .T. )                      // [14] L Indica se o campo é virtual 
 
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("AFATA04M", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("Z03MASTER", /*cOwner*/, oStruPai)
    oModel:AddGrid("Z04DETAIL","Z03MASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:SetDescription("Modelo de dados - " + cTitulo)
    oModel:GetModel("Z03MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:GetModel("Z04DETAIL"):SetDescription( "Grid de - " + cTitulo)
    oModel:SetPrimaryKey({})
 
    //Fazendo o relacionamento
    aAdd(aRelation, {"Z04_FILIAL", "FWxFilial('Z04')"} )
    aAdd(aRelation, {"Z04_CODIGO", "Z03_CODIGO"})
    oModel:SetRelation("Z04DETAIL", aRelation, Z04->(IndexKey(1)))
 
Return oModel
 
/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao AFATA04
@author Daniel Atilio
@since 15/04/2021
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
 
Static Function ViewDef()
    Local oModel := FWLoadModel("AFATA04")
    Local oStruPai := FWFormStruct(2, cTabPai)
    Local oStruFilho := FWFormStruct(2, cTabFilho)
    Local oView
 
    oStruFilho:AddField( ;                      // Ord. Tipo Desc.
        'Z04_LEGEND'                        , ;        // [01] C   Nome do Campo
        "00"                             , ;     // [02] C   Ordem
        AllTrim( ''    )        , ;     // [03] C   Titulo do campo
        AllTrim( '' )       , ;     // [04] C   Descricao do campo
        { 'Legenda' }           , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        '@BMP'               , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                             , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo é alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                                        , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior opção do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo é virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha após o campo 
 
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_Z03", oStruPai, "Z03MASTER")
    oView:AddGrid("VIEW_Z04",  oStruFilho,  "Z04DETAIL")
 
    //Partes da tela
    oView:CreateHorizontalBox("CABEC", 30)
    oView:CreateHorizontalBox("GRID", 70)
    oView:SetOwnerView("VIEW_Z03", "CABEC")
    oView:SetOwnerView("VIEW_Z04", "GRID")
 
    //Titulos
    oView:EnableTitleView("VIEW_Z03", "Cabecalho - Z03")
    oView:EnableTitleView("VIEW_Z04", "Grid - Z04")
 
    //Removendo campos
    oStruFilho:RemoveField("Z04_FILIAL")
    oStruFilho:RemoveField("Z04_CODIGO")
 
    //Adicionando campo incremental na grid
    oView:AddIncrementField("VIEW_Z04", "Z04_ITEM")
 
Return oView
 
/*/{Protheus.doc} User Function zRetSald
Função que retorna o saldo do produto
@type  Function
@author Atilio
@since 15/04/2021
@version version
/*/
 
User Function zRetSald(cFilSB2, cCodProd)
    Local aArea := GetArea()
    Local cQrySB2
    Local nSaldo
    Default cFilSB2 := ""
    Default cCodProd := ""
 
    //Busca o Saldo
    cQrySB2 := " SELECT " + CRLF
    cQrySB2 += "    SUM(B2_QATU) AS TOTAL " + CRLF
    cQrySB2 += " FROM " + CRLF
    cQrySB2 += "   " + RetSQLName("SB2") + " SB2 " + CRLF
    cQrySB2 += " WHERE " + CRLF
    cQrySB2 += "   B2_COD = '" + cCodProd + "' " + CRLF
    If ! Empty(cFilSB2)
        cQrySB2 += "   AND B2_FILIAL = '" + cFilSB2 +"' " + CRLF
    EndIf
    cQrySB2 += "   AND SB2.D_E_L_E_T_ = ' ' " + CRLF
    TCQuery cQrySB2 New Alias "QRY_SB2"
 
    //Se houver dados
    If ! QRY_SB2->(EoF())
        nSaldo := QRY_SB2->TOTAL
    EndIf
    QRY_SB2->(DbCloseArea())
 
    RestArea(aArea)
Return nSaldo
