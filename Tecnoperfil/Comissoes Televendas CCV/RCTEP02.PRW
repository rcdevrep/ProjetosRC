//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} User Function RCTEP02
Remuneracao de Vendas
@author Evandro Burlin
@since 03/02/2025
@version 1.0
/*/

//Variveis Estaticas
Static cTitulo := "Remuneracao de Vendas"
Static cAliasMVC := "ZP1"

User Function RCTEP02()
	Local aArea   := FWGetArea()
	Local oBrowse
	Local nIgnore := 1
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(cTitulo)

	//Ativa a Browse
	oBrowse:Activate()

	//Tratativa para ignorar warnings de ViewDef e ModelDef nunca chamados
	If nIgnore == 0
		ModelDef()
		ViewDef()
	EndIf

	FWRestArea(aArea)
Return Nil

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Incluir" ACTION "INCLUIR" OPERATION 1 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("RCTEP02M", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("ZP1MASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZP1MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel("RCTEP02")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZP1", oStruct, "ZP0MASTER")
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:SetOwnerView("VIEW_ZP1", "TELA")

Return oView
