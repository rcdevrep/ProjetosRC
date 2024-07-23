#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062D
Cadastro das alterações de preços TRR (ACO / ACP) - Insere registros na ZDH e ZDI
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062D()
/*/
User Function XAG0062D()
Return()

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Solicitar reajuste' ACTION 'VIEWDEF.XAG0062D' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.XAG0062E" OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina

Static Function ModelDef()

	Local oModel      := Nil
	Local bAfterSTTS  := {|oModel| ProcAprov(oModel)}
	Local bCommit     := {|| FWFormCommit(Self,,,bAfterSTTS,,)}
	Local bPost       := {|oModel| ExecBPost(oModel)}

	Local oStModCab   := GetModCab()
	Local oStModZDH   := GetModZDH()
	Local oStModZDI   := GetModZDI()
	Local oStModPrc   := GetModPrc(oStModZDI)

	Local aZDHRel     := {}
	Local aZDIRel     := {}
	Local aPrcRel     := {}

	Local aTpProd     := StrTokArr(U_XAG0062G("TIPOS_PRODUTO"), ";")

	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("ZDH_FMODEL",/*bPre*/,bPost,bCommit,/*bCancel*/)

	oModel:AddFields("MCABEC",,oStModCab) // Gera classe FWFormFieldsModel
	oModel:AddGrid('MGRID_ZDH','MCABEC',oStModZDH) // Gera classe FWFormGridModel
	oModel:AddGrid('MGRID_ZDI','MGRID_ZDH',oStModZDI) // Gera classe FWFormGridModel
	oModel:AddGrid("MGRID_PRC","MCABEC",oStModPrc)

	//Relacionamento entre MCABEC e MGRID_ZDH
	aAdd(aZDHRel, {'ZDH_FILIAL', 'FWFilial("ZDH")'} )
	aAdd(aZDHRel, {'ZDH_NUM', 'ZDH_NUM'})
	oModel:SetRelation('MGRID_ZDH', aZDHRel, 'ZDH_FILIAL+ZDH_NUM')

	//Relacionamento entre MGRID_ZDH e MGRID_ZDI
	aAdd(aZDIRel, {'ZDI_FILIAL', 'FWFilial("ZDH")'} )
	aAdd(aZDIRel, {'ZDI_NUM', 'ZDH_NUM'})
	aAdd(aZDIRel, {'ZDI_CODCLI', 'ZDH_CODCLI'} )
	aAdd(aZDIRel, {'ZDI_LOJA', 'ZDH_LOJA'} )
	oModel:SetRelation('MGRID_ZDI', aZDIRel, 'ZDI_FILIAL+ZDI_NUM+ZDI_CODCLI+ZDI_LOJA+ZDI_TPPROD')

	aAdd(aZDIRel, {'ZDI_FILIAL', 'FWFilial("ZDH")'} )
	aAdd(aZDIRel, {'ZDI_NUM', 'ZDH_NUM'})
	oModel:SetRelation('MGRID_PRC', aPrcRel, 'ZDI_TPPROD')

	oModel:SetPrimaryKey({"ZDH_FILIAL", "ZDH_NUM", "ZDH_CODCLI", "ZDH_LOJA", "ZDI_TPPROD"})

	oModel:GetModel("MGRID_ZDH"):SetOptional(.F.)
	oModel:GetModel("MGRID_ZDI"):SetOptional(.F.)
	oModel:GetModel("MGRID_ZDI"):SetMaxLine(Len(aTpProd))
	oModel:GetModel("MGRID_PRC"):SetMaxLine(Len(aTpProd))
	oModel:GetModel("MGRID_PRC"):SetOptional(.F.)

	oModel:SetDescription("Solicitação de reajuste de Preços")
	oModel:GetModel("MGRID_ZDH"):SetDescription("Model ZDH")
	oModel:GetModel("MGRID_ZDI"):SetDescription("Model ZDI")
	oModel:GetModel("MGRID_PRC"):SetDescription("Model PRC")

	oModel:GetModel("MGRID_ZDI"):SetNoDeleteLine()
	oModel:GetModel("MGRID_PRC"):SetNoDeleteLine()

Return oModel

Static Function ViewDef()

	Local bAfterView  := {|oView| CarDados(oView)}
	Local oModel      := FWLoadModel("XAG0062D")

	Local oStViewZDH  := GetViewZDH()
	Local oStGridZDH  := GetGridZDH()

	Local oStGridZDI  := GetGridZDI()
	Local oStGridPrc  := GetGridPrc()

	Local oView       := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB",oStViewZDH,"MCABEC")
	oView:AddGrid('VGRID_ZDH',oStGridZDH,'MGRID_ZDH')
	oView:AddGrid('VGRID_ZDI',oStGridZDI,'MGRID_ZDI')
	oView:AddGrid('VGRID_PRC',oStGridPrc,'MGRID_PRC')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('DADOS_CLI',15)
	oView:CreateHorizontalBox('GRID_CLI',50)
	oView:CreateHorizontalBox('BOX_PRECOS',35)

	oView:CreateVerticalBox("GRID_PRECOS_DIGIT", 40, "BOX_PRECOS")
	oView:CreateVerticalBox("GRID_PRECOS_CLIENTE", 60, "BOX_PRECOS")

	oView:SetOwnerView('VIEW_CAB','DADOS_CLI')
	oView:SetOwnerView('VGRID_ZDH','GRID_CLI')
	oView:SetOwnerView('VGRID_ZDI','GRID_PRECOS_CLIENTE')
	oView:SetOwnerView('VGRID_PRC','GRID_PRECOS_DIGIT')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Dados da solicitação de reajuste')
	oView:EnableTitleView('VGRID_ZDH','Dados dos Clientes')
	oView:EnableTitleView('VGRID_ZDI','Preços do cliente')
	oView:EnableTitleView('VGRID_PRC','Preços do reajuste')

	oView:SetAfterViewActivate(bAfterView)

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

Return oView

Static Function TrigDados()

	Local _cRet   := ""
	Local oModel  := FWModelActive()
	Local oModZDH := Nil

	oModZDH := oModel:GetModel("MGRID_ZDH")

	If (!Empty(oModZDH:GetValue("ZDH_CODCLI")) .And. !Empty(oModZDH:GetValue("ZDH_LOJA")))

		MsgRun( "Carregando dados do cliente", "Aguarde", {||_cRet := CalcDados()})
		MsgRun( "Calculando sugestão de preços", "Aguarde", {||SugestPrc()})

		CalcAprov(.F.)
	EndIf

Return(_cRet)

Static Function CalcDados()

	Local oModCab 	:= Nil
	Local oModZDH 	:= Nil
	Local oModZDI   := Nil
	Local oModel	:= FWModelActive()
	// Local oView     := FwViewActive()
	Local cCodCli   := ""
	Local cLoja     := ""
	Local cCdDsVend := ""
	Local cCateg    := ""
	Local cFaixa    := ""
	Local cCgcCli   := ""
	Local cVend3    := ""

	oModCab := oModel:GetModel("MCABEC") // Busca classe FWFormFieldsModel
	oModZDH := oModel:GetModel("MGRID_ZDH") // Busca classe FWFormGridModel
	oModZDI := oModel:GetModel("MGRID_ZDI") // Busca classe FWFormGridModel

	cCodCli := oModZDH:GetValue("ZDH_CODCLI")
	cLoja   := oModZDH:GetValue("ZDH_LOJA")

	CalcInfCli(cCodCli, cLoja, oModZDH)

	cCgcCli := oModZDH:GetValue("CNPJCLI")
	cVend3  := oModZDH:GetValue("ZDH_VEND")

	cCdDsVend := CalcVend(cVend3)

	cCateg := U_CalcCateg(cCgcCli)
	cFaixa := U_CalcFaixa(cCgcCli, cCateg, cVend3)

	CalcPrcCli(cCodCli, cLoja, cVend3, cCateg, cFaixa, oModCab, oModZDH, oModZDI)

	oModZDH:LoadValue("ZDH_CATEGO", cCateg)
	oModZDH:LoadValue("ZDH_FAIXA", cFaixa)

Return(cCdDsVend)

Static Function CalcVend(cCodVend)

	Local _cQuery   := ""
	Local _cAlias   := ""
	Local _cRet     := ""

	_cQuery := " SELECT SA3.A3_COD + ' - ' + A3_NOME AS CDDSVEND "
	_cQuery += " FROM " + RetSqlName("SA3") + " SA3 WITH (NOLOCK) "
	_cQuery += " WHERE SA3.A3_COD = '" + cCodVend + "'"
	_cQuery += " AND   SA3.A3_FILIAL = '" + FWFilial("SA3") + "'"
	_cQuery += " AND   SA3.D_E_L_E_T_ = ''  "

	_cAlias := MpSysOpenQuery(_cQuery)
	_cRet := (_cAlias)->CDDSVEND

	(_cAlias)->(DbCloseArea())

	If (Empty(_cRet))
		_cRet := "VENDEDOR NAO CADASTRADO OU INEXISTENTE"
	EndIf

Return(_cRet)

Static Function CalcInfCli(cCodCli, cLoja, oModZDH)

	Local _cQuery   := ""
	Local _cAlias   := ""

	_cQuery := " SELECT A1_NOME, A1_END, A1_MUN, A1_EST, A1_CGC, A1_VEND3, A1_VEND5, A1_VEND6, A1_VEND7 "
	_cQuery += " FROM " + RetSqlName("SA1") + " SA1 WITH (NOLOCK) "
	_cQuery += " WHERE SA1.A1_FILIAL = '" + FWFilial("SA1") + "'"
	_cQuery += " AND   SA1.D_E_L_E_T_ = ''  "
	_cQuery += " AND   SA1.A1_COD = '" + AllTrim(cCodCli) + "'"
	_cQuery += " AND SA1.A1_LOJA = '" + AllTrim(cLoja) + "'"
	_cQuery += " ORDER BY SA1.A1_COD, SA1.A1_LOJA "

	_cAlias := MpSysOpenQuery(_cQuery)

	oModZDH:LoadValue("ZDH_NOMCLI", SubStr((_cAlias)->A1_NOME,1,TamSX3("ZDH_NOMCLI")[1]))
	oModZDH:LoadValue("ENDCLI", (_cAlias)->A1_END)
	oModZDH:LoadValue("MUNCLI", (_cAlias)->A1_MUN)
	oModZDH:LoadValue("ESTCLI", (_cAlias)->A1_EST)
	oModZDH:LoadValue("CNPJCLI", (_cAlias)->A1_CGC)

	If (cEmpAnt == "01" .And. FWFilial() $ ("11/15/17/18/05"))
		oModZDH:LoadValue("ZDH_VEND", (_cAlias)->A1_VEND7) // RC ARLA
		oModZDH:LoadValue("ZDH_VEND2", (_cAlias)->A1_VEND6) // RT ARLA
	Else
		oModZDH:LoadValue("ZDH_VEND", (_cAlias)->A1_VEND3) // RC DIESEL
		oModZDH:LoadValue("ZDH_VEND2", (_cAlias)->A1_VEND5) // RT DIESEL
	EndIf

	(_cAlias)->(DbCloseArea())

Return()

User Function CalcCateg(cCgcCli)

	Local _cQuery    := ""
	Local _cAlias    := ""
	Local _cRet      := "1"
	Local cRaizCgc   := Substr(cCgcCli,1,10)
	Local _aEmpresas := {"010", "110", "150"}
	Local _cEmpresa  := ""
	Local nCount     := 0

	For nCount := 1 To Len(_aEmpresas)

		_cEmpresa := _aEmpresas[nCount]

		_cQuery := " SELECT COUNT(CNA.CNA_CLIENT) AS QTDE "
		_cQuery += " FROM CN9" + _cEmpresa + " CN9 (NOLOCK), CNA" + _cEmpresa + " CNA (NOLOCK), CNB" + _cEmpresa + " CNB (NOLOCK), "
		_cQuery += "      SA1" + _cEmpresa + " SA1 (NOLOCK), CN1" + _cEmpresa + " CN1 (NOLOCK) "
		_cQuery += " WHERE CNB.CNB_FILIAL = CNA.CNA_FILIAL "
		_cQuery += " AND   CNB.CNB_CONTRA = CNA.CNA_CONTRA "
		_cQuery += " AND   CNB.CNB_REVISA = CNA.CNA_REVISA "
		_cQuery += " AND   CNA.CNA_FILIAL = CN9.CN9_FILIAL "
		_cQuery += " AND   CNA.CNA_CONTRA = CN9.CN9_NUMERO "
		_cQuery += " AND   CNA.CNA_REVISA = CN9.CN9_REVISA "
		_cQuery += " AND   CNA.CNA_TIPPLA = CN9.CN9_TPCTO "
		_cQuery += " AND   SA1.A1_COD = CNA.CNA_CLIENT "
		_cQuery += " AND   CNA.CNA_LOJACL = SA1.A1_LOJA "
		_cQuery += " AND   CN1.CN1_CODIGO = CNA.CNA_TIPPLA "
		//_cQuery += " AND   CN9.CN9_SITUAC <> '07' "
		_cQuery += " AND   CN9.CN9_SITUAC IN ('02','03','04','05') " //CARLOS SAVIO - CHAMADO 577496 - Revisar regra na aprovação de preços - Cliente Comodato ou Spot - PEDRO HERRERA

		If (cEmpAnt == "01" .And. FWFilial() == "15")
			_cQuery += " AND CN1_DESCRI LIKE '%COMODATO ARLA%' "
		Else
			_cQuery += " AND CN1.CN1_DESCRI LIKE '%COMODATO DIESEL%' "
		EndIf

		_cQuery += " AND   CNA.CNA_DTINI <= '" + DtoS(dDataBase) + "'"
		_cQuery += " AND   CN9.D_E_L_E_T_= '' "
		_cQuery += " AND   CNB.D_E_L_E_T_= '' "
		_cQuery += " AND   CNA.D_E_L_E_T_= '' "
		_cQuery += " AND   SA1.D_E_L_E_T_= '' "
		_cQuery += " AND   SA1.A1_CGC LIKE '" + cRaizCgc + "%' "

		_cAlias := MpSysOpenQuery(_cQuery)

		If ((_cAlias)->QTDE > 0)
			_cRet := "2"
			Exit
		EndIf
	End

	(_cAlias)->(DbCloseArea())

Return(_cRet)

User Function CalcFaixa(cCgcCli, cCateg, cVend3)

	Local _cQuery   := ""
	Local _cAlias   := ""
	Local _cRet     := ""
	Local cRaizCgc  := Substr(cCgcCli,1,10)
	Local nMediaFat := 0

	_cQuery := " WITH FAT_EMPRESAS AS ( "

	If (cEmpAnt == "01" .And. FWFilial() == "15")
		_cQuery += "    SELECT "
		_cQuery += "       MIN(D2_EMISSAO) AS PRIMEIRA_COMPRA, "
		_cQuery += "       COALESCE(SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV),0) AS VOL_FAT "
		_cQuery += "    FROM SD2010 SD2 (NOLOCK), SA1010 SA1 (NOLOCK), SB5010 SB5 (NOLOCK) "
		_cQuery += "    WHERE SA1.A1_COD = SD2.D2_CLIENTE "
		_cQuery += "    AND   SA1.A1_LOJA = SD2.D2_LOJA "
		_cQuery += "    AND   SA1.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SD2.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SB5.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SB5.B5_XTPTRR = '5' "
		_cQuery += "    AND   SD2.D2_FILIAL = SB5.B5_FILIAL "
		_cQuery += "    AND   SB5.B5_COD = SD2.D2_COD "
		_cQuery += "    AND   SB5.B5_FILIAL = '" + FWFilial("SB5") + "'"
		_cQuery += "    AND   SD2.D2_EMISSAO >= CONVERT(VARCHAR, DATEADD(MONTH, -6, GETDATE()), 112) "
		_cQuery += "    AND   SA1.A1_CGC LIKE '" + cRaizCgc + "%' "
	Else
		_cQuery += "    SELECT "
		_cQuery += "       MIN(D2_EMISSAO) AS PRIMEIRA_COMPRA, "
		_cQuery += "       COALESCE(SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV),0) AS VOL_FAT "
		_cQuery += "    FROM SD2010 SD2 (NOLOCK), SA1010 SA1 (NOLOCK) "
		_cQuery += "    WHERE SA1.A1_COD = SD2.D2_CLIENTE "
		_cQuery += "    AND   SA1.A1_LOJA = SD2.D2_LOJA "
		_cQuery += "    AND   SA1.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SD2.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SD2.D2_TP = 'CO' "
		_cQuery += "    AND   SD2.D2_EMISSAO >= CONVERT(VARCHAR, DATEADD(MONTH, -6, GETDATE()), 112) "
		_cQuery += "    AND   SA1.A1_CGC LIKE '" + cRaizCgc + "%' "

		_cQuery += "    UNION ALL "

		_cQuery += "    SELECT "
		_cQuery += "       MIN(D2_EMISSAO) AS PRIMEIRA_COMPRA, "
		_cQuery += "       COALESCE(SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV),0) AS VOL_FAT "
		_cQuery += "    FROM SD2110 SD2 (NOLOCK), SA1110 SA1 (NOLOCK) "
		_cQuery += "    WHERE SA1.A1_COD = SD2.D2_CLIENTE "
		_cQuery += "    AND   SA1.A1_LOJA = SD2.D2_LOJA "
		_cQuery += "    AND   SA1.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SD2.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SD2.D2_TP = 'CO' "
		_cQuery += "    AND   SD2.D2_EMISSAO >= CONVERT(VARCHAR, DATEADD(MONTH, -6, GETDATE()), 112) "
		_cQuery += "    AND   SA1.A1_CGC LIKE '" + cRaizCgc + "%' "

		_cQuery += "    UNION ALL "

		_cQuery += "    SELECT "
		_cQuery += "       MIN(D2_EMISSAO) AS PRIMEIRA_COMPRA, "
		_cQuery += "       COALESCE(SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV),0) AS VOL_FAT "
		_cQuery += "    FROM SD2150 SD2 (NOLOCK), SA1150 SA1 (NOLOCK) "
		_cQuery += "    WHERE SA1.A1_COD = SD2.D2_CLIENTE "
		_cQuery += "    AND   SA1.A1_LOJA = SD2.D2_LOJA "
		_cQuery += "    AND   SA1.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SD2.D_E_L_E_T_ = '' "
		_cQuery += "    AND   SD2.D2_TP = 'CO' "
		_cQuery += "    AND   SD2.D2_EMISSAO >= CONVERT(VARCHAR, DATEADD(MONTH, -6, GETDATE()), 112) "
		_cQuery += "    AND   SA1.A1_CGC LIKE '" + cRaizCgc + "%' "
	EndIf

	_cQuery += " ) "

	_cQuery += " SELECT "

	_cQuery += "    CASE DATEDIFF(MONTH, MIN(PRIMEIRA_COMPRA), GETDATE()) "
	_cQuery += "       WHEN 0 THEN SUM(VOL_FAT) "
	_cQuery += "       WHEN 1 THEN SUM(VOL_FAT) "
	_cQuery += "       ELSE ROUND(SUM(VOL_FAT) / DATEDIFF(MONTH, MIN(PRIMEIRA_COMPRA), GETDATE()), 0, 1) "
	_cQuery += "    END AS MEDIA_FAT "

	_cQuery += " FROM FAT_EMPRESAS "
	_cQuery += " WHERE VOL_FAT > 0 "

	_cAlias := MpSysOpenQuery(_cQuery)

	nMediaFat := (_cAlias)->MEDIA_FAT

	(_cAlias)->(DbCloseArea())

	_cQuery := "  SELECT "
	_cQuery += "     MAX(SUBSTRING(ZDF_PARAM, 7,2)) AS FAIXA "
	_cQuery += "  FROM " + RetSqlName("ZDF") + " ZDF (NOLOCK) "
	_cQuery += "  WHERE ZDF.ZDF_FILIAL = '" + FWFilial("ZDF") + "'"
	_cQuery += "  AND   ZDF.D_E_L_E_T_ = '' "
	_cQuery += "  AND   ZDF.ZDF_PARAM LIKE 'FAIXA_%' "
	_cQuery += "  AND   COALESCE(TRY_CAST(ZDF.ZDF_PROPR1 AS NUMERIC(10,4)),0) <= " + cValToChar(nMediaFat)

	_cAlias := MpSysOpenQuery(_cQuery)

	_cRet := (_cAlias)->FAIXA

	(_cAlias)->(DbCloseArea())

Return(_cRet)

Static Function CalcPrcCli(cCodCli, cLoja, cVend3, cCateg, cFaixa, oModCab, oModZDH, oModZDI)

	Local nX       := 0
	Local cTpProd  := ""
	Local nPrcAnt  := 0
	Local nPrcFaix := 0
	Local cCondPagto := oModCab:GetValue("ZDH_CONDPG")
	Local cTabPrec   := oModCab:GetValue("ZDH_CODTAB")
	Local aTpProd    := StrTokArr(U_XAG0062G("TIPOS_PRODUTO"), ";")

	For nX := 1 To Len(aTpProd)

		cTpProd := aTpProd[nX]

		If !(oModZDI:SeekLine({{"ZDI_TPPROD",cTpProd}}))
			If !(Empty(oModZDI:GetValue("ZDI_TPPROD")))
				oModZDI:AddLine()
			EndIf

			oModZDI:LoadValue("ZDI_TPPROD", cTpProd)
		EndIf

		nPrcAnt  := U_GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := U_GetPrcFaix(cFaixa, cCateg, cVend3, cTpProd)

		oModZDI:LoadValue("ZDI_PRCANT", nPrcAnt)
		oModZDI:LoadValue("ZDI_PRCFXA", nPrcFaix)

		oModZDI:LoadValue("ZDI_PRCNOV", 0)

	Next nX

	oModZDI:SetLine(1)

Return()

Static Function SugestPrc()

	Local oModel    := FWModelActive()
	Local oModZDH   := oModel:GetModel("MGRID_ZDH")
	Local oModZDI   := oModel:GetModel("MGRID_ZDI")
	Local oModPrc   := oModel:GetModel("MGRID_PRC")

	Local nLinZDH    := oModZDH:GetLine()
	Local nQtdLinZDH := oModZDH:GetQTDLine()
	Local nQtdLinZDI := 0

	Local nI := 0
	Local nJ := 0

	For nI := 1 To nQtdLinZDH
		oModZDH:SetLine(nI)

		nQtdLinZDI := oModZDI:GetQTDLine()

		For nJ := 1 To nQtdLinZDI
			oModZDI:SetLine(nJ)

			If (oModPrc:SeekLine({{"ZDI_TPPROD", oModZDI:GetValue("ZDI_TPPROD")}}))
				If (oModPrc:GetValue("ZDI_PRCNOV") < oModZDI:GetValue("ZDI_PRCFXA"))
					oModPrc:LoadValue("ZDI_PRCNOV", oModZDI:GetValue("ZDI_PRCFXA"))
				EndIf
			EndIf
		End
	End

	oModZDI:SetLine(1)
	oModZDH:SetLine(nLinZDH)
	oModZDI:SetLine(1)

Return()

User Function GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)

	Local nPrcAnt    := 0
	Local _cQuery    := ""
	Local _cAliasQry := ""

	_cQuery := " SELECT "
	_cQuery += "    ACP.ACP_PRECO "
	_cQuery += " FROM " + RetSqlName("ACO") + " ACO (NOLOCK), "
	_cQuery +=            RetSqlName("ACP") + " ACP (NOLOCK), "
	_cQuery +=            RetSqlName("SB5") + " SB5 (NOLOCK) "

	_cQuery += " WHERE ACO.ACO_CODREG = ACP.ACP_CODREG "
	_cQuery += " AND   SB5.B5_COD = ACP.ACP_CODPRO "

	_cQuery += " AND   ACO.ACO_CONDPG = '" + cCondPagto + "'"
	_cQuery += " AND   ACO.ACO_CODTAB = '" + cTabPrec + "'"
	_cQuery += " AND   ACO.ACO_CODCLI = '" + cCodCli + "'"
	_cQuery += " AND   ACO.ACO_LOJA = '" + cLoja + "'"
	_cQuery += " AND   SB5.B5_XTPTRR = '" + cTpProd + "'"

	_cQuery += " AND   ACO.ACO_FILIAL = '" + FWFilial("ACO") + "'"
	_cQuery += " AND   ACP.ACP_FILIAL = '" + FWFilial("ACP") + "'"
	_cQuery += " AND   SB5.B5_FILIAL = '" + FWFilial("SB5") + "'"

	_cQuery += " AND   ACO.D_E_L_E_T_ = '' "
	_cQuery += " AND   ACP.D_E_L_E_T_ = '' "
	_cQuery += " AND   SB5.D_E_L_E_T_ = '' "

	_cAliasQry := MpSysOpenQuery(_cQuery)

	nPrcAnt := (_cAliasQry)->ACP_PRECO

	(_cAliasQry)->(DbCloseArea())

Return(nPrcAnt)

User Function GetPrcFaix(cFaixa, cCateg, cVend3, cTpProd)

	Local nPrcFaixa  := 0
	Local _cQuery    := ""
	Local _cAliasQry := ""

	_cQuery := " SELECT "
	_cQuery += "    ZDG_VALOR "
	_cQuery += " FROM " + RetSqlName("ZDG") + " ZDG (NOLOCK) "
	_cQuery += " WHERE ZDG.D_E_L_E_T_ = '' "
	_cQuery += " AND   ZDG.ZDG_FILIAL = '" + FWFilial("ZDG") + "'"
	_cQuery += " AND   ZDG.ZDG_CATEGO = '" + cCateg + "'"
	_cQuery += " AND   ZDG.ZDG_FAIXA = '" + cFaixa + "'"
	_cQuery += " AND   ZDG.ZDG_VEND = '" + cVend3 + "'"
	_cQuery += " AND   ZDG.ZDG_TPPROD = '" + cTpProd + "'"

	_cAliasQry := MpSysOpenQuery(_cQuery)

	nPrcFaixa := (_cAliasQry)->ZDG_VALOR

	(_cAliasQry)->(DbCloseArea())

Return(nPrcFaixa)

Static Function ProcAprov(oModel)

	Local oModCab := oModel:GetModel("MCABEC")

	U_XAG0062H(oModCab:GetValue("ZDH_NUM"))

Return()

Static Function ExecBPost(oModel)

	Local oModCab   := oModel:GetModel("MCABEC")
	Local oModZDH   := oModel:GetModel("MGRID_ZDH")
	Local oModZDI   := oModel:GetModel("MGRID_ZDI")
	Local oModPrc   := oModel:GetModel("MGRID_PRC")
	Local nQtdLiZDH := oModZDH:GetQTDLine()
	Local nQtdLiZDI := 0
	Local nI        := 0
	Local nJ        := 0

	oModCab:SetValue("ZDH_HORA", Time())

	For nI := 1 To nQtdLiZDH
		oModZDH:SetLine(nI)

		nQtdLiZDI := oModZDI:GetQTDLine()

		For nJ := 1 To nQtdLiZDI

			oModZDI:SetLine(nJ)

			If (oModPrc:SeekLine({{"ZDI_TPPROD", oModZDI:GetValue("ZDI_TPPROD")}}))
				oModZDI:LoadValue("ZDI_PRCNOV", oModPrc:GetValue("ZDI_PRCNOV"))
				oModZDI:LoadValue("ZDI_PRCAPR", oModPrc:GetValue("ZDI_PRCNOV"))
			Else
				oModZDI:LoadValue("ZDI_PRCNOV", 0)
			EndIf
		End
	End

Return(.T.)

Static Function CarDados(oView)

	Local cTpProd := ""
	Local nI      := 0
	Local oModPrc := oView:GetModel("MGRID_PRC")
	Local oModCab := oView:GetModel("MCABEC")
	Local aTpProd := StrTokArr(U_XAG0062G("TIPOS_PRODUTO"), ";")

	For nI := 1 To Len(aTpProd)
		cTpProd := aTpProd[nI]

		If !(Empty(oModPrc:GetValue("ZDI_TPPROD")))
			oModPrc:AddLine()
		EndIf

		oModPrc:LoadValue("ZDI_TPPROD", cTpProd)
		oModPrc:LoadValue("ZDI_PRCNOV", 0)
	End

	oModCab:LoadValue("ZDH_NUM", GetSXENum('ZDH','ZDH_NUM','ZDHNUM' + cEmpAnt + FWFilial('ZDH')))

	oModPrc:SetLine(1)
	oView:Refresh()

Return(Nil)

Static Function CalcAprov(lDigPrc)

	Local oView   := FWViewActive()
	Local oModel  := FWModelActive()
	Local oModZDH := Nil
	Local oModZDI := Nil
	Local oModPrc := Nil

	Local nLinZDH := 0
	Local nLinPrc := 0

	oModZDH := oModel:GetModel("MGRID_ZDH")
	oModZDI := oModel:GetModel("MGRID_ZDI")
	oModPrc := oModel:GetModel("MGRID_PRC")

	nLinZDH := oModZDH:GetLine()
	nLinPrc := oModPrc:GetLine()

	If (lDigPrc)
		MsgRun("Calculando aprovações","Processando",{|| CalcAprZDH()})

		If (nLinPrc <> oModPrc:GetLine())
			oModPrc:SetLine(nLinPrc)
		EndIf

		oModZDH:SetLine(1)
		oView:Refresh("VGRID_ZDH")
	Else
		MsgRun("Calculando aprovações","Processando",{|| CalcAprZDI()})

		If (nLinZDH <> oModZDH:GetLine())
			oModZDI:SetLine(1)
			oModZDH:SetLine(nLinZDH)
		EndIf

		oModPrc:SetLine(1)
		oView:Refresh("VGRID_PRC")
	End

	oModZDI:SetLine(1)
	oView:Refresh("VGRID_ZDI")

Return(Nil)

Static Function CalcDadPrc()

	CalcAprov(.T.)

Return(FWFilial("ZDI"))

Static Function GetModCab()

	Local aFieldsCab  := {"ZDH_FILIAL", "ZDH_NUM", "ZDH_CODTAB", "ZDH_CONDPG", "ZDH_DATA", "ZDH_HORA", "ZDH_STATUS", "ZDH_OBSSOL", "ZDH_OBSAPR"}
	Local oStModCab   := FWFormStruct(1,"ZDH",{|cCampo| AScan(aFieldsCab,AllTrim(cCampo)) > 0})
	Local cIniPad     := ""

	cIniPad := "'A'"
	oStModCab:SetProperty("ZDH_STATUS",MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

	// cIniPad := "GetSXENum('ZDH','ZDH_NUM','ZDHNUM' + cEmpAnt + FWFilial('ZDH'))"
	// oStModCab:SetProperty("ZDH_NUM",MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

	cIniPad := "Date()"
	oStModCab:SetProperty("ZDH_DATA",MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

	cIniPad := "Time()"
	oStModCab:SetProperty("ZDH_HORA",MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

	cIniPad := U_XAG0062G("TABELA_PADRAO", .T., .T.)
	oStModCab:SetProperty("ZDH_CODTAB",MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

	cIniPad := U_XAG0062G("COND_PAGTO_PADRAO", .T., .T.)
	oStModCab:SetProperty("ZDH_CONDPG",MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

Return(oStModCab)

Static Function GetModZDH()

	Local aFieldsZDH  := {"ZDH_CODTAB", "ZDH_CONDPG", "ZDH_DATA", "ZDH_HORA", "ZDH_STATUS", "ZDH_OBSSOL", "ZDH_OBSAPR"}
	Local oStModZDH   := FWFormStruct(1,"ZDH",{|cCampo| AScan(aFieldsZDH,AllTrim(cCampo)) = 0})
	Local bTriggZDH   := {|| TrigDados()}

	Local cValid      := ""
	Local cIniPad     := ""

	oStModZDH:AddField(;
		"",;                                                // [01]  C   Titulo do campo
	"",;                                                // [02]  C   ToolTip do campo
	"INDAPRZDH",;                                       // [03]  C   Id do Field
	"C",;                                               // [04]  C   Tipo do campo
	50,;                                                // [05]  N   Tamanho do campo
	0,;                                                 // [06]  N   Decimal do campo
	Nil,;                                               // [07]  B   Code-block de validação do campo
	Nil,;                                               // [08]  B   Code-block de validação When do campo
	Nil,;                                               // [09]  A   Lista de valores permitido do campo
	Nil,;                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
	Nil,;                                               // [11]  B   Code-block de inicializacao do campo
	Nil,;                                               // [12]  L   Indica se trata-se de um campo chave
	Nil,;                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	Nil)                                                // [14]  L   Indica se o campo é virtual

	oStModZDH:AddField(;
		"Endereço",;                                        // [01]  C   Titulo do campo
	"Endereço do Cliente",;                             // [02]  C   ToolTip do campo
	"ENDCLI",;                                          // [03]  C   Id do Field
	"C",;                                               // [04]  C   Tipo do campo
	TamSX3("A1_END")[1],;                               // [05]  N   Tamanho do campo
	0,;                                                 // [06]  N   Decimal do campo
	Nil,;                                               // [07]  B   Code-block de validação do campo
	Nil,;                                               // [08]  B   Code-block de validação When do campo
	Nil,;                                               // [09]  A   Lista de valores permitido do campo
	.F.,;                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
	,;                                                  // [11]  B   Code-block de inicializacao do campo
	.F.,;                                               // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.)                                                // [14]  L   Indica se o campo é virtual

	oStModZDH:AddField(;
		"Município Cliente",;                               // [01]  C   Titulo do campo
	"Município Cliente",;                               // [02]  C   ToolTip do campo
	"MUNCLI",;                                          // [03]  C   Id do Field
	"C",;                                               // [04]  C   Tipo do campo
	TamSX3("A1_MUN")[1],;                               // [05]  N   Tamanho do campo
	0,;                                                 // [06]  N   Decimal do campo
	Nil,;                                               // [07]  B   Code-block de validação do campo
	Nil,;                                               // [08]  B   Code-block de validação When do campo
	Nil,;                                               // [09]  A   Lista de valores permitido do campo
	.F.,;                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
	,;                                                  // [11]  B   Code-block de inicializacao do campo
	.F.,;                                               // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.)                                                // [14]  L   Indica se o campo é virtual

	oStModZDH:AddField(;
		"UF",;                                              // [01]  C   Titulo do campo
	"UF do Cliente",;                                   // [02]  C   ToolTip do campo
	"ESTCLI",;                                          // [03]  C   Id do Field
	"C",;                                               // [04]  C   Tipo do campo
	TamSX3("A1_EST")[1],;                               // [05]  N   Tamanho do campo
	0,;                                                 // [06]  N   Decimal do campo
	Nil,;                                               // [07]  B   Code-block de validação do campo
	Nil,;                                               // [08]  B   Code-block de validação When do campo
	Nil,;                                               // [09]  A   Lista de valores permitido do campo
	.F.,;                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
	,;                                                  // [11]  B   Code-block de inicializacao do campo
	.F.,;                                               // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.)                                                // [14]  L   Indica se o campo é virtual

	oStModZDH:AddField(;
		"CNPJ",;                                            // [01]  C   Titulo do campo
	"CNPJ do Cliente",;                                 // [02]  C   ToolTip do campo
	"CNPJCLI",;                                         // [03]  C   Id do Field
	"C",;                                               // [04]  C   Tipo do campo
	TamSX3("A1_CGC")[1],;                               // [05]  N   Tamanho do campo
	0,;                                                 // [06]  N   Decimal do campo
	Nil,;                                               // [07]  B   Code-block de validação do campo
	Nil,;                                               // [08]  B   Code-block de validação When do campo
	Nil,;                                               // [09]  A   Lista de valores permitido do campo
	.F.,;                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
	,;                                                  // [11]  B   Code-block de inicializacao do campo
	.F.,;                                               // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.)                                                // [14]  L   Indica se o campo é virtual

	oStModZDH:AddField(;
		"Vendedor",;                                        // [01]  C   Titulo do campo
	"Vendedor",;                                        // [02]  C   ToolTip do campo
	"CDDSVEND",;                                        // [03]  C   Id do Field
	"C",;                                               // [04]  C   Tipo do campo
	TamSX3("A3_COD")[1]+TamSX3("A3_NOME")[1]+10,;       // [05]  N   Tamanho do campo
	0,;                                                 // [06]  N   Decimal do campo
	Nil,;                                               // [07]  B   Code-block de validação do campo
	Nil,;                                               // [08]  B   Code-block de validação When do campo
	Nil,;                                               // [09]  A   Lista de valores permitido do campo
	.F.,;                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
	,;                                                  // [11]  B   Code-block de inicializacao do campo
	.F.,;                                               // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.)                                                // [14]  L   Indica se o campo é virtual

	cIniPad := "'BR_BRANCO'"
	oStModZDH:SetProperty("INDAPRZDH",MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

	cValid := "ExistCpo('SA1',FwFldGet('ZDH_CODCLI')+IIF(EMPTY(FwFldGet('ZDH_LOJA')),'',RTRIM(FwFldGet('ZDH_LOJA'))))"
	oStModZDH:SetProperty("ZDH_CODCLI",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, cValid))

	cValid := "ExistCpo('SA1',FwFldGet('ZDH_CODCLI')+FwFldGet('ZDH_LOJA'))"
	oStModZDH:SetProperty("ZDH_LOJA",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, cValid))

	oStModZDH:AddTrigger("ZDH_CODCLI","CDDSVEND",,bTriggZDH)
	oStModZDH:AddTrigger("ZDH_LOJA","CDDSVEND",,bTriggZDH)

Return(oStModZDH)

Static Function GetModZDI()

	Local oStModZDI := FWFormStruct(1,"ZDI")
	Local cIniPad   := ""

	oStModZDI:AddField(;
		"",;                                                // [01]  C   Titulo do campo
	"",;                                                // [02]  C   ToolTip do campo
	"INDAPRZDI",;                                       // [03]  C   Id do Field
	"C",;                                               // [04]  C   Tipo do campo
	50,;                                                // [05]  N   Tamanho do campo
	0,;                                                 // [06]  N   Decimal do campo
	Nil,;                                               // [07]  B   Code-block de validação do campo
	Nil,;                                               // [08]  B   Code-block de validação When do campo
	Nil,;                                               // [09]  A   Lista de valores permitido do campo
	Nil,;                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
	Nil,;                                               // [11]  B   Code-block de inicializacao do campo
	Nil,;                                               // [12]  L   Indica se trata-se de um campo chave
	Nil,;                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	Nil)                                                // [14]  L   Indica se o campo é virtual

	cIniPad := "'BR_BRANCO'"
	oStModZDI:SetProperty("INDAPRZDI",MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD, cIniPad))

Return(oStModZDI)

Static Function GetModPrc(oStModZDI)

	Local aFieldsPrc := {"ZDI_FILIAL","ZDI_NUM","ZDI_TPPROD","ZDI_PRCNOV"}
	Local aFldsZDI   := oStModZDI:GetFields()
	Local aFldZDI    := {}
	Local oStModPrc  := Nil
	Local nI         := 0
	Local bTriggPrc  := {|| CalcDadPrc()}

	oStModPrc := FwFormModelStruct():New()

	For nI := 1 To Len(aFieldsPrc)
		aFldZDI := aFldsZDI[oStModZDI:GetFieldPos(aFieldsPrc[nI])]

		oStModPrc:AddField(aFldZDI[1],aFldZDI[2],aFldZDI[3],aFldZDI[4],aFldZDI[5],aFldZDI[6],aFldZDI[7],aFldZDI[8],;
			aFldZDI[9],aFldZDI[10],aFldZDI[11],aFldZDI[12],aFldZDI[13],aFldZDI[14],aFldZDI[15])
	End

	oStModPrc:AddTrigger("ZDI_PRCNOV","ZDI_FILIAL",,bTriggPrc)

Return(oStModPrc)

Static Function GetViewZDH()

	Local aFieldsCab  := {"ZDH_FILIAL", "ZDH_NUM", "ZDH_DATA", "ZDH_HORA", "ZDH_OBSSOL"}
	Local oStViewZDH  := FWFormStruct(2,"ZDH",{|cCampo| AScan(aFieldsCab,AllTrim(cCampo)) > 0}) // Cria classe FWFormViewStruct

Return(oStViewZDH)

Static Function GetGridZDH()

	Local aFieldsZDH  := {"ZDH_NUM", "ZDH_CODTAB", "ZDH_CONDPG", "ZDH_DATA", "ZDH_HORA", "ZDH_STATUS", "ZDH_VEND2", "ZDH_OBSSOL", "ZDH_OBSAPR"}
	Local oStGridZDH  := FWFormStruct(2,"ZDH",{|cCampo| AScan(aFieldsZDH,AllTrim(cCampo)) = 0}) // Cria classe FWFormViewStruct

	oStGridZDH:AddField(;
		'INDAPRZDH', ;                 // [01] C   Nome do Campo
	"00", ;                        // [02] C   Ordem
	AllTrim(''), ;                 // [03] C   Titulo do campo
	AllTrim(''), ;                 // [04] C   Descricao do campo
	{ 'Legenda' }, ;               // [05] A   Array com Help
	'C', ;                         // [06] C   Tipo do campo
	'@BMP', ;                      // [07] C   Picture
	NIL, ;                         // [08] B   Bloco de Picture Var
	'', ;                          // [09] C   Consulta F3
	.T., ;                         // [10] L   Indica se o campo é alteravel
	NIL, ;                         // [11] C   Pasta do campo
	NIL, ;                         // [12] C   Agrupamento do campo
	NIL, ;                         // [13] A   Lista de valores permitido do campo (Combo)
	NIL, ;                         // [14] N   Tamanho maximo da maior opção do combo
	NIL, ;                         // [15] C   Inicializador de Browse
	.T., ;                         // [16] L   Indica se o campo é virtual
	NIL, ;                         // [17] C   Picture Variavel
	NIL)                           // [18] L   Indica pulo de linha após o campo

	//Adicionando campos da estrutura
	oStGridZDH:AddField(;
		"ENDCLI",;                  // [01]  C   Nome do Campo
	"09",;                      // [02]  C   Ordem
	"Endereço Cliente",;        // [03]  C   Titulo do campo
	"Endereço Cliente",;        // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	.T.,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
	// 30)                         // [19]  L   Largura fixa do campo no grid

	//Adicionando campos da estrutura
	oStGridZDH:AddField(;
		"MUNCLI",;                  // [01]  C   Nome do Campo
	"10",;                      // [02]  C   Ordem
	"Município Cliente",;       // [03]  C   Titulo do campo
	"Município Cliente",;       // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	.T.,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
	// 30)                         // [19]  L   Largura fixa do campo no grid

	//Adicionando campos da estrutura
	oStGridZDH:AddField(;
		"ESTCLI",;                  // [01]  C   Nome do Campo
	"11",;                      // [02]  C   Ordem
	"UF Cliente",;              // [03]  C   Titulo do campo
	"UF Cliente",;              // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	.T.,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	//Adicionando campos da estrutura
	oStGridZDH:AddField(;
		"CNPJCLI",;                 // [01]  C   Nome do Campo
	"12",;                      // [02]  C   Ordem
	"CNPJ",;                    // [03]  C   Titulo do campo
	"CNPJ do Cliente",;         // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	.T.,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	//Adicionando campos da estrutura
	oStGridZDH:AddField(;
		"CDDSVEND",;                // [01]  C   Nome do Campo
	"13",;                      // [02]  C   Ordem
	"Vendedor",;                // [03]  C   Titulo do campo
	"Vendedor",;                // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	.T.,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

Return(oStGridZDH)

Static Function GetGridZDI()

	Local oStGridZDI := FWFormStruct(2, 'ZDI', {|cCampo| cCampo <> "ZDI_PRCNOV" .And. cCampo <> "ZDI_PRCAPR"}) // Cria classe FWFormViewStruct

	oStGridZDI:AddField(;
		'INDAPRZDI', ;                 // [01] C   Nome do Campo
	"00", ;                        // [02] C   Ordem
	AllTrim(''), ;                 // [03] C   Titulo do campo
	AllTrim(''), ;                 // [04] C   Descricao do campo
	{ 'Legenda' }, ;               // [05] A   Array com Help
	'C', ;                         // [06] C   Tipo do campo
	'@BMP', ;                      // [07] C   Picture
	NIL, ;                         // [08] B   Bloco de Picture Var
	'', ;                          // [09] C   Consulta F3
	.F., ;                         // [10] L   Indica se o campo é alteravel
	NIL, ;                         // [11] C   Pasta do campo
	NIL, ;                         // [12] C   Agrupamento do campo
	NIL, ;                         // [13] A   Lista de valores permitido do campo (Combo)
	NIL, ;                         // [14] N   Tamanho maximo da maior opção do combo
	NIL, ;                         // [15] C   Inicializador de Browse
	.T., ;                         // [16] L   Indica se o campo é virtual
	NIL, ;                         // [17] C   Picture Variavel
	NIL)                           // [18] L   Indica pulo de linha após o campo

Return(oStGridZDI)

Static Function GetGridPrc()

	Local aFieldsPrc  := {"ZDI_TPPROD", "ZDI_PRCNOV"}
	Local oStGridPrc  := FWFormStruct(2, "ZDI", {|cCampo| AScan(aFieldsPrc,AllTrim(cCampo)) > 0})

Return(oStGridPrc)

Static Function CalcAprZDH()

	Local oModel  := FWModelActive()
	Local oModZDH := Nil

	Local nI      := 0
	Local nLinZDH := 0
	Local nQtdLin := 0

	oModZDH := oModel:GetModel("MGRID_ZDH")

	nQtdLin := oModZDH:GetQTDLine()
	nLinZDH := oModZDH:GetLine()

	For nI := 1 To nQtdLin
		oModZDH:SetLine(nI)

		CalcAprZDI()
	End

	oModZDH:SetLine(nLinZDH)

Return()

Static Function CalcAprZDI()

	Local aAprRet := {}
	Local aPreco  := {}
	Local oModel  := FWModelActive()
	Local oModZDH := Nil
	Local oModZDI := Nil
	Local oModPrc := Nil

	Local nPosTpProd := 1
	Local nPosMotivo := 2

	Local nI      := 0
	Local nQtdLin := 0

	Local cMotZDH := ""
	Local cMotZDI := ""

    Local nGapS10  := Val(U_XAG0062G("GAP_S10"))
    Local nGapS500 := Val(U_XAG0062G("GAP_S500"))
    Local nMaxNv1  := Val(U_XAG0062G("DESC_MAX_NV1"))
    Local nMaxNv2  := Val(U_XAG0062G("DESC_MAX_NV2"))

	oModZDH := oModel:GetModel("MGRID_ZDH")
	oModZDI := oModel:GetModel("MGRID_ZDI")
	oModPrc := oModel:GetModel("MGRID_PRC")

	nQtdLin := oModZDI:GetQTDLine()

	For nI := 1 To nQtdLin
		oModZDI:SetLine(nI)
		oModPrc:SetLine(nI)

		If (oModPrc:GetValue("ZDI_TPPROD") <> oModZDI:GetValue("ZDI_TPPROD"))
			If (oModPrc:SeekLine({{"ZDI_TPPROD", oModZDI:GetValue("ZDI_TPPROD")}}))
				aAdd(aPreco, {oModZDI:GetValue("ZDI_TPPROD"), oModZDI:GetValue("ZDI_PRCFXA"), oModPrc:GetValue("ZDI_PRCNOV")})
			EndIf
		Else
			aAdd(aPreco, {oModZDI:GetValue("ZDI_TPPROD"), oModZDI:GetValue("ZDI_PRCFXA"), oModPrc:GetValue("ZDI_PRCNOV")})
		EndIf
	End

	If !(Empty(aPreco))
		aAprRet := U_XAG0062F(aPreco, nGapS10, nGapS500, nMaxNv1, nMaxNv2)
		cMotZDH := aAprRet[1]
		aPreco  := aAprRet[2]

		For nI := 1 To Len(aPreco)
			oModZDI:SetLine(nI)

			If (aPreco[nI][nPosTpProd] <> oModZDI:GetValue("ZDI_TPPROD"))
				oModZDI:SeekLine({{"ZDI_TPPROD", aPreco[nI][nPosTpProd]}})
			EndIf

			cMotZDI := aPreco[nI][nPosMotivo]
			oModZDI:LoadValue("ZDI_MOTIVO", cMotZDI)

			If Empty(cMotZDI)
				oModZDI:LoadValue("INDAPRZDI", "BR_VERDE")
			Else
				oModZDI:LoadValue("INDAPRZDI", "BR_VERMELHO")
			EndIf
		End

		oModZDH:LoadValue("ZDH_MOTIVO", cMotZDH)

		If Empty(cMotZDH)
			oModZDH:LoadValue("INDAPRZDH", "BR_VERDE")
		Else
			oModZDH:LoadValue("INDAPRZDH", "BR_VERMELHO")
		EndIf
	EndIf

	oModZDI:SetLine(1)

Return()
