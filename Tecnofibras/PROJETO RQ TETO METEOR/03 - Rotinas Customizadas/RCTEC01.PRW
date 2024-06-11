#include "Protheus.ch"
#include "FWMVCDef.ch"

Static cTitulo := "Producao Teto Meteor"

USER FUNCTION RCTEC01()
    Local aArea := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()

    SetFunName("RCTEC01")

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SBM")
    oBrowse:SetDescription(cTitulo)
    //oBrowse:SetOwner(oStPai)
    oBrowse:Activate()

    SetFunName(cFunBkp)
    RestArea(aArea)

RETURN NIL

STATIC FUNCTION MenuDef()
    
    Local aRotina := {}
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RCTEC01' OPERATION 2 ACCESS 0

RETURN (aRotina)

STATIC FUNCTION ModelDef()
    Local oModel := NIL
    Local oStPai := FWFormStruct(1,'SBM')
    Local oStFilho1 := FWFormStruct(1,'SB1')
    Local oStFilho2 := FWFormStruct(1,'SB1')
    Local aRelFilho1 := {}
    Local aRelFilho2 := {}

    oModel := MPFormModel():New('RCTEC01')
    oModel:AddFields('SBM_MASTER', ,oStPai)

    oModel:AddGrid('SB1_FILHO1', 'SBM_MASTER', oStFilho1)
    oModel:AddGrid('SB1_FILHO2', 'SBM_MASTER', oStFilho2)

    aAdd(aRelFilho1, {'B1_FILIAL','BM_FILIAL'})
    aAdd(aRelFilho1, {'B1_GRUPO','BM_GRUPO'})
    aAdd(aRelFilho1, {'B1_LOCPAD','  '})

    aAdd(aRelFilho2, {'B1_FILIAL','BM_FILIAL'})
    aAdd(aRelFilho2, {'B1_GRUPO','BM_GRUPO'})
    aAdd(aRelFilho2, {'B1_LOCPAD','  '})

    oModel:SetRelation('SB1_FILHO1', aRelFilho1, SB1->(IndexKey(1)))
    oModel:GetModel('SB1_FILHO1'):SetUniqueLine({"B1_FILIAL","B1_COD"})

    oModel:SetRelation('SB1_FILHO2', aRelFilho2, SB1->(IndexKey(1)))
    oModel:GetModel('SB1_FILHO2'):SetUniqueLine({"B1_FILIAL","B1_COD"})

    oModel:SetPrimaryKey({})
    oModel:SetDescription("NOME DA TELA")
    oModel:GetModel('SBM_MASTER'):SetDescription('MODELO GRUPO')
    oModel:GetModel('SB1_FILHO1'):SetDescription('MODEL FILHO 1')
    oModel:GetModel('SB1_FILHO2'):SetDescription('MODEL FILHO 2')
RETURN oModel

STATIC FUNCTION ViewDef()
    Local oView := NIL
    Local oModel := FWLoadModel('RCTEC01')
    Local oStPai := FWFormStruct(2,'SBM')
    Local oStFilho1 := FWFormStruct(2,'SB1')
    Local oStFilho2 := FWFormStruct(2,'SB1')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_SBM',oStPai,'SBM_MASTER')

    oView:AddGrid('VIEW_FILHO1',oStFilho1,'SB1_FILHO1')
    oView:AddGrid('VIEW_FILHO2',oStFilho2,'SB1_FILHO2')

    oView:CreateHorizontalBox('SUPERIOR', 30)
    oView:CreateHorizontalBox('INFERIOR', 70)

    oView:CreateFolder('PASTA_FILHOS', 'INFERIOR')
    oView:AddSheet('PASTA_FILHOS', 'ABA_FILHO01', "Armazem 00")
    oView:AddSheet('PASTA_FILHOS', 'ABA_FILHO02', "Armazem 01")

    oView:CreateHorizontalBox('ITENS_FILHO01', 100, , , 'PASTA_FILHOS', 'ABA_FILHO01')
    oView:CreateHorizontalBox('ITENS_FILHO02', 100, , , 'PASTA_FILHOS', 'ABA_FILHO02')

    oView:SetOwnerView('VIEW_SBM', 'SUPERIOR')
    oView:SetOwnerView('VIEW_FILHO1', 'ITENS_FILHO01')
    oView:SetOwnerView('VIEW_FILHO2', 'ITENS_FILHO02')
RETURN oView



