#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062E
Cadastro das alterações de preços TRR (ACO / ACP) - Contem a View para visualizar registros na ZDH inseridos pela rotina XAG0062C
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062E()
/*/
User Function XAG0062E()

Return()

Static Function ViewDef()

	Local oModel      := FWLoadModel("XAG0062D")

	Local oStViewZDH  := GetViewZDH()
	Local oStGridZDH  := GetGridZDH()

	Local oStGridZDI  := FWFormStruct(2, 'ZDI') // Cria classe FWFormViewStruct

	Local oView       := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB",oStViewZDH,"MCABEC")
	oView:AddGrid('VGRID_ZDH',oStGridZDH,'MGRID_ZDH')
	oView:AddGrid('VGRID_ZDI',oStGridZDI,'MGRID_ZDI')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('DADOS_CLI',25)
	oView:CreateHorizontalBox('GRID_CLI',50)
	oView:CreateHorizontalBox('GRID_PRECOS_CLIENTE',25)

	oView:SetOwnerView('VIEW_CAB','DADOS_CLI')
	oView:SetOwnerView('VGRID_ZDH','GRID_CLI')
	oView:SetOwnerView('VGRID_ZDI','GRID_PRECOS_CLIENTE')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Dados da solicitação de reajuste')
	oView:EnableTitleView('VGRID_ZDH','Dados dos Clientes')
	oView:EnableTitleView('VGRID_ZDI','Preços do cliente')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

Return oView

Static Function GetViewZDH()

	Local aFieldsCab  := {"ZDH_FILIAL", "ZDH_NUM", "ZDH_CODTAB", "ZDH_CONDPG", "ZDH_DATA", "ZDH_HORA", "ZDH_OBSSOL", "ZDH_OBSAPR"}
	Local oStViewZDH  := FWFormStruct(2,"ZDH",{|cCampo| AScan(aFieldsCab,AllTrim(cCampo)) > 0}) // Cria classe FWFormViewStruct

	oStViewZDH:SetProperty("ZDH_CODTAB", MVC_VIEW_LOOKUP, "")
	oStViewZDH:SetProperty("ZDH_CONDPG", MVC_VIEW_LOOKUP, "")

Return(oStViewZDH)

Static Function GetGridZDH()

	Local aFieldsZDH  := {"ZDH_NUM", "ZDH_CODTAB", "ZDH_CONDPG", "ZDH_DATA", "ZDH_HORA", "ZDH_STATUS", "ZDH_VEND2", "ZDH_OBSAPR", "ZDH_OBSSOL"}
	Local oStGridZDH  := FWFormStruct(2,"ZDH",{|cCampo| AScan(aFieldsZDH,AllTrim(cCampo)) = 0}) // Cria classe FWFormViewStruct

Return(oStGridZDH)
