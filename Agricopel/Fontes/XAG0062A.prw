#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062A
Cadastro de parâmetros de preços TRR
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062A()
/*/
User Function XAG0062A()

	Local aArea   := GetArea()
	Local oBrowse := Nil

	Private cTitulo := "Parâmetros de Preços TRR"

	If (!U_XAG0062X())
		Return()
	EndIf

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZDF")
	oBrowse:SetDescription(cTitulo)

	oBrowse:Activate()

	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.XAG0062A' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.XAG0062A' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.XAG0062A' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.XAG0062A' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

	Local oModel := Nil
	Local oStZDF := FWFormStruct(1, "ZDF")

	oModel := MPFormModel():New("ZDF_FM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMZDF",/*cOwner*/,oStZDF)

	oModel:SetPrimaryKey({'ZDF_FILIAL','ZDF_PARAM'})

	oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)
	oModel:GetModel("FORMZDF"):SetDescription("Formulário do Cadastro " + cTitulo)

Return(oModel)

Static Function ViewDef()

	Local oModel   := FWLoadModel("XAG0062A")
	Local oStZDF   := FWFormStruct(2, "ZDF")
	Local oView    := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZDF", oStZDF, "FORMZDF")
	oView:CreateHorizontalBox("TELA", 100)
	oView:EnableTitleView('VIEW_ZDF', 'Dados - '+cTitulo )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_ZDF","TELA")

Return oView

User Function XAG0062X()

	Local lRet     := .T.
    Local _cId     := RetCodUsr()
	Local _cLogin  := ";" + UsrRetName(RetCodUsr()) + ";"
	Local _cLogAut := U_XAG0062G("LOGIN_LIB_ADMIN", .T., .F.)

    _cLogAut := ";" + _cLogAut + ";"

	If (_cId <> "000000") .And. !(Upper(_cLogin) $ Upper(_cLogAut))
		MsgInfo("Usuario nao autorizado a acessar esta rotina!")
		lRet := .F.
	EndIf

Return(lRet)
