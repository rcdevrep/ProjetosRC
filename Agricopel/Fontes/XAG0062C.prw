#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062C
Listagem das altera��es de pre�os TRR (ACO / ACP)
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062C()
/*/
User Function XAG0062C()

    Local aArea        := GetArea()
    Local oBrowse      := Nil

    oBrowse := FWMBrowse():New()

//	Desabilita op��o Ambiente do menu A��es Relacionadas.
	oBrowse:SetAmbiente(.F.)
//	Desabilita op��o WalkThru do menu A��es Relacionadas.
	oBrowse:SetWalkThru(.F.)
//	Desabilita a exibi��o dos detalhes do registro posicionado.
	// oBrowse:DisableDetails()

    oBrowse:AddLegend("ZDH_STATUS=='E'","BR_AZUL","Aguardando aprova��o")
    oBrowse:AddLegend("ZDH_STATUS=='B'","BR_VERDE","Baixado")
    oBrowse:AddLegend("ZDH_STATUS=='R'","BR_VERMELHO","Reprovado")
    oBrowse:AddLegend("ZDH_STATUS<>'E'.AND.ZDH_STATUS<>'B'.AND.ZDH_STATUS<>'R'","BR_BRANCO","Erro")

    oBrowse:SetAlias("ZDH")
    oBrowse:SetDescription("Solicita��o de reajuste de pre�os")
    oBrowse:SetMenuDef("XAG0062C")

    oBrowse:Activate()

    RestArea(aArea)
Return()

Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Solicitar reajuste' ACTION 'VIEWDEF.XAG0062D' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.XAG0062E" OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina
