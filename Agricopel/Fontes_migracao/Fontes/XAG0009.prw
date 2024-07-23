#Include "topconn.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Notas fiscais - manutenção de vendedores"

/*/{Protheus.doc} XAG0009
Função para alterar/ajustar/corrigir informações de RT/RC/RL nas notas fiscais de saída (SF2)
@author Leandro F Silveira
@since 23/10/2015
@version 1.0
@return Função não tem retorno
@example U_XAG0009()
@obs Não se pode executar função MVC dentro do fórmulas
/*/
User Function XAG0009()

	Local aArea := GetArea()

	CriarTela()

	RestArea(aArea)

Return()

Static Function CriarTela()

	Local oBrowse    := Nil;

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SF2")
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails();

	oBrowse:Activate()

Return()

Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Alterar' ACTION 'VIEWDEF.XAG0009' OPERATION MODEL_OPERATION_UPDATE ACCESS 0

Return aRot

Static Function ModelDef()

	Local oModel := Nil
	Local oStSF2 := FWFormStruct(1, "SF2")
	Local cValid := ""

	oStSF2:SetProperty('F2_DOC'     , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStSF2:SetProperty('F2_SERIE'   , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStSF2:SetProperty('F2_CLIENTE' , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStSF2:SetProperty('F2_LOJA'    , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStSF2:SetProperty('F2_EMISSAO' , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))

	oStSF2:SetProperty('F2_VEND6'   , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .or. ExistCpo("SA3",M->F2_VEND6)'))

	oStSF2:SetProperty('F2_VEND7'   , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .or. ExistCpo("SA3",M->F2_VEND7)'))

	oStSF2:SetProperty('F2_VEND8'   , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .or. ExistCpo("SA3",M->F2_VEND8)'))

	oModel := MPFormModel():New("XAG0009M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	oModel:AddFields("FORMSF2",,oStSF2)
	oModel:SetPrimaryKey({"F2_FILIAL","F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA","F2_FORMUL","F2_TIPO"})
	oModel:SetDescription("Vendedores da nota fiscal "+ cTitulo)

	oModel:GetModel("FORMSF2"):SetDescription("Vendedores da nota fiscal "+ cTitulo)

Return oModel

Static Function ViewDef()

	Local nAtual     := 0
	Local cCamposSF2 := "F2_DOC|F2_SERIE|F2_CLIENTE|F2_LOJA|F2_EMISSAO|F2_VEND1|F2_VEND2|F2_VEND3|F2_VEND4|F2_VEND5|F2_VEND6|F2_VEND7|F2_VEND8|"
	Local oModel     := FWLoadModel("XAG0009")
	Local oStSF2     := FWFormStruct(2, "SF2", { |cCampo| AllTrim(cCampo) + "|" $ cCamposSF2})
	Local oView      := Nil

	oStSF2:SetProperty("F2_VEND6", MVC_VIEW_LOOKUP, "SA3")

	oStSF2:SetProperty("F2_VEND7", MVC_VIEW_LOOKUP, "SA3")

	oStSF2:SetProperty("F2_VEND8", MVC_VIEW_LOOKUP, "SA3")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_SF2", oStSF2, "FORMSF2")
	oView:CreateHorizontalBox("TELA", 100)

	oView:EnableTitleView('VIEW_SF2', 'Capas de notas fiscais' )

	oView:SetCloseOnOk({||.T.})
	oView:SetViewAction( 'BUTTONOK' ,{ |oView| UpdSE1(oView) } )
	oView:SetOwnerView("VIEW_SF2","TELA")

Return oView

Static Function UpdSE1(oView)

	Local cQuery    := ""
	Local cAliasSE1 := GetNextAlias()
	Local aAreaSE1  := SE1->(GetArea())

	cQuery += " SELECT SE1.R_E_C_N_O_ as RecNoSE1 "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
	cQuery += " WHERE SE1.E1_NUM     = '" + SF2->F2_DOC      + "'"
	cQuery += " AND   SE1.E1_PREFIXO = '" + SF2->F2_PREFIXO  + "'"
	cQuery += " AND   SE1.E1_CLIENTE = '" + SF2->F2_CLIENTE  + "'"
	cQuery += " AND   SE1.E1_LOJA    = '" + SF2->F2_LOJA     + "'"
	cQuery += " AND   SE1.E1_EMISSAO = '" + DtoS(SF2->F2_EMISSAO)  + "'"
	cQuery += " AND   SE1.D_E_L_E_T_ = '' "

	TCQuery cQuery NEW ALIAS (cAliasSE1)

	While !(cAliasSE1)->(Eof())

		SE1->(DbGoTop())
		SE1->(DbGoTo((cAliasSE1)->(RecNoSE1)))

		If !(cAliasSE1)->(Eof())
			RecLock("SE1",.F.)

			SE1->E1_VEND1  := SF2->F2_VEND1
			SE1->E1_VEND2  := SF2->F2_VEND2
			SE1->E1_VEND3  := SF2->F2_VEND3
			SE1->E1_VEND4  := SF2->F2_VEND4
			SE1->E1_VEND5  := SF2->F2_VEND5
			SE1->E1_XVEND6 := SF2->F2_VEND6
			SE1->E1_XVEND7 := SF2->F2_VEND7
			SE1->E1_XVEND8 := SF2->F2_VEND8

			MsUnLock("SE1")
		EndIf

		(cAliasSE1)->(DbSkip())
	EndDo

	RestArea(aAreaSE1)
	MsgInfo("Nota fiscal e seu(s) título(s) atualizados com sucesso!")

Return()