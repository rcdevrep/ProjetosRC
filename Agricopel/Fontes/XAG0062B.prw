#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

Static aFieldsM := {"ZDG_FILIAL", "ZDG_VEND"}

/*/{Protheus.doc} XAG0062B
Cadastro de faixa de preços TRR
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062B()
/*/
User Function XAG0062B()

    Local aArea   := GetArea()
    Local oBrowse := Nil

    Private cTitulo := "Faixa de preços TRR"

    If (!U_XAG0062X())
        Return()
    EndIf

    oBrowse := FWMBrowse():New()

//	Desabilita opção Ambiente do menu Ações Relacionadas.
	oBrowse:SetAmbiente(.F.)
//	Desabilita opção WalkThru do menu Ações Relacionadas.
	oBrowse:SetWalkThru(.F.)
//	Desabilita a exibição dos detalhes do registro posicionado.
	oBrowse:DisableDetails()

    oBrowse:SetAlias("ZDG")
    oBrowse:SetDescription(cTitulo)
    oBrowse:SetMenuDef("XAG0062B")

    oBrowse:Activate()

    RestArea(aArea)

Return()

Static Function MenuDef()

    Local aRot := {}

    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.XAG0062B' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.XAG0062B' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.XAG0062B' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    // ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.XAG0062B' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

    Local oModel   := Nil
    Local oStTmp   := FWFormStruct(1, 'ZDG',{|cCampo| AScan(aFieldsM,AllTrim(cCampo)) > 0})
    Local oStFilho := FWFormStruct(1, 'ZDG')
    Local aZDGRel  := {}
    Local oModM    := Nil
    Local oModD    := Nil

    //Setando as propriedades na grid, o inicializador da Filial e Tabela, para não dar mensagem de coluna vazia
    oStFilho:SetProperty('ZDG_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('ZDG_VEND', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))

    oStTmp:SetProperty('ZDG_VEND', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, 'INCLUI'))

    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel := MPFormModel():New("ZDG_FM")
    oModel:AddFields("MASTER",/*cOwner*/,oStTmp)
    oModel:AddGrid('DETAIL','MASTER',oStFilho)

    //Adiciona o relacionamento de Filho, Pai
    aAdd(aZDGRel, {'ZDG_FILIAL', 'Iif(!INCLUI, ZDG->ZDG_FILIAL, FWFilial("ZDG"))'} )
    aAdd(aZDGRel, {'ZDG_VEND', 'ZDG_VEND'} )

    //Criando o relacionamento
    oModel:SetRelation('DETAIL', aZDGRel, 'ZDG_FILIAL+ZDG_VEND+ZDG_CATEGO+ZDG_FAIXA+ZDG_TPPROD')

    //Setando o campo único da grid para não ter repetição
    oModel:GetModel('DETAIL'):SetUniqueLine({'ZDG_FILIAL', 'ZDG_VEND', 'ZDG_CATEGO', 'ZDG_FAIXA', 'ZDG_TPPROD'})

    //Setando outras informações do Modelo de Dados
    oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)
    oModel:SetPrimaryKey({})
    oModel:GetModel("MASTER"):SetDescription("Formulário do Cadastro " + cTitulo)

    oModM := oModel:GetModel("MASTER")
    oModD := oModel:GetModel("DETAIL")

Return oModel

Static Function ViewDef()

    Local oModel     := FWLoadModel("XAG0062B")
    Local oStTmp     := FWFormStruct(2, 'ZDG',{|cCampo| AScan(aFieldsM,AllTrim(cCampo)) > 0})
    Local oStFilho   := FWFormStruct(2, 'ZDG',{|cCampo| AScan(aFieldsM,AllTrim(cCampo)) = 0})
    Local oView      := Nil
    Local bBtClick   := {|oView| MsgRun("Inserindo as combinações de faixa não existentes","Processando",{|| ProcFaixa(oView)})}

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CAB", oStTmp, "MASTER")
    oView:AddGrid('VIEW_ZDG',oStFilho,'DETAIL')

    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)

    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_CAB','CABEC')
    oView:SetOwnerView('VIEW_ZDG','GRID')

    //Habilitando título
    oView:EnableTitleView('VIEW_CAB','Cabeçalho - Vendedor')
    oView:EnableTitleView('VIEW_ZDG','Itens - Faixas de preço por Produto/Categoria')

    oView:AddUserButton("Carregar Faixas Rep", "MAGIC_BMP", bBtClick, "Carrega todas as combinações de faixa que ainda não estão presentes no GRID de dados")

    //Tratativa padrão para fechar a tela
    oView:SetCloseOnOk({||.T.})

Return oView

Static Function ProcFaixa(oView)

    Local aAreaSX3  := SX3->(GetArea())
	Local oDetail 	:= Nil
	Local oMaster 	:= Nil
	Local oModel	:= FWModelActive()
    Local aCatego   := {}
    Local aFaixa    := {}
    Local aTpProd   := {}
    Local aBusca    := {}
    Local nCatego   := 0
    Local nFaixa    := 0
    Local nTpProd   := 0
    Local cVend     := ""

	oDetail := oModel:GetModel("DETAIL")
	oMaster := oModel:GetModel("MASTER")

    cVend := oMaster:GetValue("ZDG_VEND")

    If (Empty(cVend))
        Alert("Informe um vendedor antes de carregar as faixas!")
        Return(.T.)
    EndIf

    If (!oDetail:IsEmpty() .And. !oDetail:VldLineData())
        Alert("Finalize a digitação da linha atual para poder executar esta ação!")
        Return(.T.)
    EndIf

    SX3->(DbSetOrder(2))
    SX3->(DbSeek("ZDG_CATEGO"))
    aCatego := CBoxToArr(X3CBox())

    SX3->(DbSeek("ZDG_FAIXA"))
    aFaixa := CBoxToArr(X3CBox())

    aTpProd := StrTokArr(U_XAG0062G("TIPOS_PRODUTO"), ";")

    For nCatego := 1 To Len(aCatego)
        For nFaixa := 1 To Len(aFaixa)
            For nTpProd := 1 To Len(aTpProd)

                aBusca := {}
                Aadd(aBusca, {"ZDG_FILIAL", FWFilial("ZDG")})
                Aadd(aBusca, {"ZDG_VEND", cVend})
                Aadd(aBusca, {"ZDG_CATEGO", aCatego[nCatego]})
                Aadd(aBusca, {"ZDG_FAIXA", aFaixa[nFaixa]})
                Aadd(aBusca, {"ZDG_TPPROD", aTpProd[nTpProd]})

                If (!oDetail:SeekLine(aBusca,.T.,.F.))
                    oDetail:AddLine()
                    AEval(aBusca,{|x| oDetail:SetValue(x[1],x[2])})
                    oDetail:SetValue("ZDG_VALOR", 0)
                EndIf
            Next nTpProd
        Next nFaixa
    Next nCatego

    RestArea(aAreaSX3)

Return(.T.)

Static Function CBoxToArr(CBox)

    Local aArrCbox := {}
    Local aCboxTmp := {}
    Local nX       := 0

    aCboxTmp := StrToKArr(AllTrim(CBox), ";")

    For nX := 1 To Len(aCboxTmp)
        Aadd(aArrCBox, StrToKArr(aCboxTmp[nX],"=")[1])
    Next nX

Return(aArrCBox)
