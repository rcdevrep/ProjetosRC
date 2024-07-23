#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062C
Listagem das alterações de preços TRR (ACO / ACP)
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062C()
/*/
User Function XAG0062C()

    Local aArea        := GetArea()
    Local oBrowse      := Nil

    oBrowse := FWMBrowse():New()

//	Desabilita opção Ambiente do menu Ações Relacionadas.
	oBrowse:SetAmbiente(.F.)
//	Desabilita opção WalkThru do menu Ações Relacionadas.
	oBrowse:SetWalkThru(.F.)
//	Desabilita a exibição dos detalhes do registro posicionado.
	// oBrowse:DisableDetails()

    oBrowse:AddLegend("ZDH_STATUS=='E'","BR_AZUL","Aguardando aprovação")
    oBrowse:AddLegend("ZDH_STATUS=='B'","BR_VERDE","Baixado")
    oBrowse:AddLegend("ZDH_STATUS=='R'","BR_VERMELHO","Reprovado")
    oBrowse:AddLegend("ZDH_STATUS<>'E'.AND.ZDH_STATUS<>'B'.AND.ZDH_STATUS<>'R'","BR_BRANCO","Erro")

    oBrowse:SetAlias("ZDH")
    oBrowse:SetDescription("Solicitação de reajuste de preços")
    oBrowse:SetMenuDef("XAG0062C")

    oBrowse:Activate()

    RestArea(aArea)
Return()

Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Solicitar reajuste' ACTION 'VIEWDEF.XAG0062D' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.XAG0062E" OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina
