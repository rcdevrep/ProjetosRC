#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0010
Função para ajustar preços dos produtos do TRR
@author Leandro F Silveira
@since 30/10/2017
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0010()
/*/
User Function XAG0010()

	Private nMenu      := 0
	Private cFiltroSB1 := ""
	Private cFiltroSA3 := ""

	If (CriarPerg())

		MsgRun('Aguarde - Carregando os produtos para filtro', "Processando",{|| cFiltroSB1 := U_XAG0010A()})

		If (!Empty(cFiltroSB1))
			nMenu += 1

			MsgRun('Aguarde - Carregando os vendedores para filtro', "Processando",{|| cFiltroSA3 := U_XAG0010C()})

			If (!Empty(cFiltroSA3))
				nMenu += 1
				MsgRun('Aguarde - Carregando os preços para alteração', "Processando",{|| CriaBrowse()})
			EndIf
		EndIf
	EndIf

Return()

Static Function CriarPerg()

	Local cPerg      := "XAG0010"
	Local aRegistros := {}
	Local lOk        := .F.

	AADD(aRegistros,{cPerg,"01","Codigo Tabela   ?","mv_ch1","C",03,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","DA0",""})
	AADD(aRegistros,{cPerg,"02","Cond Pagto      ?","mv_ch2","C",03,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","SE4",""})
	AADD(aRegistros,{cPerg,"03","Tipo do produto ?","mv_ch3","C",02,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","02",""})
	AADD(aRegistros,{cPerg,"04","Grupo do produto?","mv_ch4","C",04,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SBM",""})
	AADD(aRegistros,{cPerg,"05","Preço inicial   ?","mv_ch5","N",09,4,0,"G","","MV_PAR05","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Preço final     ?","mv_ch6","N",09,4,0,"G","","MV_PAR06","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Valor Reajuste  ?","mv_ch7","N",09,4,0,"G","","MV_PAR07","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Vendedor Arla   ?","mv_ch8","N",01,0,0,"C","","MV_PAR08","Não","","","Sim","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Armazém Pad Prod?","mv_ch9","C",02,0,0,"C","","MV_PAR09","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg, aRegistros)

	lOk := Pergunte(cPerg, .T.)

	If (lOk .And. MV_PAR07 == 0)
		MsgStop("Valor de reajuste precisa ser diferente de zero!")
		lOk := .F.
	EndIf

Return(lOk)

Static Function CriaBrowse()

	Local oArqTrab  := Nil
	Local cAliasQry := ""

	Private oBrowse := Nil

	cAliasQry := SqlDados()
	oArqTrab  := CriarArqTrab(cAliasQry)

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias(oArqTrab:Getalias())
	oBrowse:SetDescription("Lista de regras de desconto para reajuste")

	oBrowse:SetWalkThru(.F.)
	oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetDBFFilter(.F.)
	oBrowse:SetUseFilter(.F.)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetFilterDefault("")
	oBrowse:DisableDetails()

	oBrowse:SetColumns(MontaColunas("A1CODLOJA",  "Cód-Loja"          ,01,"@!",1,TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1],0))
	oBrowse:SetColumns(MontaColunas("A1_NOME",    "Nome Cliente"      ,02,"@!",1,TamSX3("A1_NOME")[1],0))
	oBrowse:SetColumns(MontaColunas("A1_VEND3",   "Rep Líquidos"      ,03,"@!",1,TamSX3("A1_VEND3")[1],0))
	oBrowse:SetColumns(MontaColunas("A1_VEND7",   "RC Arla"           ,04,"@!",1,TamSX3("A1_VEND7")[1],0))
	oBrowse:SetColumns(MontaColunas("A1_VEND8",   "RL Arla"           ,04,"@!",1,TamSX3("A1_VEND8")[1],0))
	oBrowse:SetColumns(MontaColunas("ACO_CODTAB", "Tabela"            ,05,"@!",1,TamSX3("ACO_CODTAB")[1],0))
	oBrowse:SetColumns(MontaColunas("CONDPAGTO",  "Cond Pagto"        ,06,"@!",1,TamSX3("E4_CODIGO")[1]+TamSX3("E4_DESCRI")[1],0))
	oBrowse:SetColumns(MontaColunas("PRODUTO",    "Produto"           ,07,"@!",1,TamSX3("B1_COD")[1]+TamSX3("B1_DESC")[1],0))

	oBrowse:SetColumns(MontaColunas("PRC_ATUA",   "Preço Atual"       ,08,"@E 99999.9999",1,009,4))
	oBrowse:SetColumns(MontaColunas("PRC_NOVO",   "Preço Novo"        ,09,"@E 99999.9999",1,009,4))

	oBrowse:SetColumns(MontaColunas("PDESC_ATUA", "% Desc. Atual"     ,10,"@E 99999.9999",1,009,4))
	oBrowse:SetColumns(MontaColunas("PDESCNOVO",  "% Desc. Novo"      ,11,"@E 99999.9999",1,009,4))

	oBrowse:SetColumns(MontaColunas("PRC_TABELA", "Preço Tabela"      ,12,"@E 99999.9999",1,009,4))

	oBrowse:Activate()

	(cAliasQry)->(DbCloseArea())
	oArqTrab:Delete()

Return()

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return({aColumn})

Static Function MenuDef()

	Local aRot := {}

	If (Type("nMenu") <> "U")
		Do Case
			Case (nMenu == 0)
			ADD OPTION aRot TITLE 'Confirmar Produtos' ACTION 'U_XAG0010B' OPERATION 6 ACCESS 0

			Case (nMenu == 1)
			ADD OPTION aRot TITLE 'Confirmar Vendedores' ACTION 'U_XAG0010D' OPERATION 6 ACCESS 0

			Case (nMenu == 2)
			ADD OPTION aRot TITLE 'Atualizar preços' ACTION 'U_XAG0010E' OPERATION 6 ACCESS 0
		EndCase
	EndIf

Return(aRot)

User Function XAG0010E()

	Local cAliasUpd := oBrowse:GetAlias()
	Local nQtdeReg  := 0

	nQtdeReg := (cAliasUpd)->(RecCount())

	If (MsgYesNo("Confirma a atualização dos preços listados? Registros: " + cValToChar(nQtdeReg), "Confirmação"))
		Processa({|lEnd| UpdPrecos(@lEnd)}, "Aguarde, processando ...", "", .T.)
	EndIf

Return()

Static Function SqlDados()

	Local cQuery    := ""
	Local cAliasQRY := GetNextAlias()

	cQuery += " SELECT RTRIM(SA1.A1_COD) + ' - ' + RTRIM(SA1.A1_LOJA) AS A1CODLOJA, "
	cQuery += "        SA1.A1_NOME, SA1.A1_VEND3, SA1.A1_VEND7, SA1.A1_VEND8, ACO.ACO_CODTAB, "

	cQuery += "        COALESCE((SELECT RTRIM(SE4.E4_CODIGO) + ' - ' + RTRIM(SE4.E4_DESCRI) "
	cQuery += "                  FROM " + RetSQLName("SE4") + " SE4 WITH (NOLOCK) "
	cQuery += "                  WHERE SE4.E4_CODIGO  = ACO.ACO_CONDPG "
	cQuery += "                  AND   SE4.D_E_L_E_T_ = '' "
	cQuery += "                  AND   SE4.E4_FILIAL  = '" + xFilial("SE4") + "')"
	cQuery += "        , '') AS CONDPAGTO,

	cQuery += " 	   RTRIM(SB1.B1_COD) + ' - ' + RTRIM(SB1.B1_DESC) AS PRODUTO, "
	cQuery += " 	   ACP.R_E_C_N_O_ AS RECNO_ACP, "

	cQuery += "        DA1.DA1_PRCVEN AS PRC_TABELA, "
	cQuery += "        CAST(ACP.ACP_PRECO AS NUMERIC(10,3)) AS PRC_ATUA, "
	cQuery += " 	   ACP.ACP_PERDES AS PDESC_ATUA, "

	cQuery += "        CAST((((DA1.DA1_PRCVEN - (CAST(ACP.ACP_PRECO + " + cValToChar(MV_PAR07) + " AS NUMERIC(10,3)))) / DA1.DA1_PRCVEN) * 100) AS NUMERIC(10,4)) AS PDESCNOVO, "
	cQuery += "        CAST(ACP.ACP_PRECO + " + cValToChar(MV_PAR07) + " AS NUMERIC(10,3)) AS PRC_NOVO "

	cQuery += " FROM " + RetSQLName("SA1") + " SA1 WITH (NOLOCK), " + RetSQLName("ACO") + " ACO WITH (NOLOCK), "
	cQuery +=            RetSQLName("ACP") + " ACP WITH (NOLOCK), " + RetSQLName("DA1") + " DA1 WITH (NOLOCK), "
	cQuery +=            RetSQLName("SB1") + " SB1 WITH (NOLOCK) "

	cQuery += " WHERE ACO.ACO_CODCLI = SA1.A1_COD "
	cQuery += "   AND ACO.ACO_LOJA   = SA1.A1_LOJA "
	cQuery += "   AND ACO.ACO_CODREG = ACP.ACP_CODREG "
	cQuery += "   AND DA1.DA1_CODTAB = ACO.ACO_CODTAB "
	cQuery += "   AND DA1.DA1_CODPRO = ACP.ACP_CODPRO "
	cQuery += "   AND SB1.B1_COD     = ACP.ACP_CODPRO "

	If (!Empty(MV_PAR01))
		cQuery += " AND DA1.DA1_CODTAB = '" + MV_PAR01 + "'"
	EndIf

	If (!Empty(MV_PAR02))
		cQuery += " AND ACO.ACO_CONDPG = '" + MV_PAR02 + "'"
	EndIf

	If (!Empty(MV_PAR03))
		cQuery += " AND SB1.B1_TIPO = '" + MV_PAR03 + "'"
	EndIf

	If (!Empty(MV_PAR04))
		cQuery += " AND SB1.B1_GRUPO = '" + MV_PAR04 + "'"
	EndIf

	If (MV_PAR05 > 0)
		cQuery += " AND ACP.ACP_PRECO >= " + cValToChar(MV_PAR05)
	EndIf

	If (MV_PAR06 > 0)
		cQuery += " AND ACP.ACP_PRECO <= " + cValToChar(MV_PAR06)
	EndIf

	If (MV_PAR08 == 1)
		cQuery += "   AND SA1.A1_VEND3 IN (" + cFiltroSA3 + ")"
	Else
		cQuery += "   AND ( "
		cQuery += "        SA1.A1_VEND7 IN (" + cFiltroSA3 + ")"
		cQuery += "    OR "
		cQuery += "        SA1.A1_VEND8 IN (" + cFiltroSA3 + ")"
		cQuery += "       ) "
	EndIf

	If (!Empty(MV_PAR09))
		cQuery += " AND SB1.B1_LOCPAD = '" + MV_PAR09 + "'"
	EndIf

	cQuery += " AND ACP.ACP_CODPRO IN (" + cFiltroSB1 + ")"

	cQuery += " AND SB1.B1_MSBLQL  = '2' "
	cQuery += " AND SB1.B1_SITUACA = '1' "

	cQuery += " AND SA1.A1_MSBLQL  = '2' "
	cQuery += " AND SA1.A1_SITUACA = '1' "

	cQuery += " AND ACP.ACP_FILIAL = '" + xFilial("ACP") + "'"
	cQuery += " AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "'"
	cQuery += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "'"
	cQuery += " AND ACO.ACO_FILIAL = '" + xFilial("ACO") + "'"
	cQuery += " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"

	cQuery += " AND ACP.D_E_L_E_T_ = '' "
	cQuery += " AND SA1.D_E_L_E_T_ = '' "
	cQuery += " AND DA1.D_E_L_E_T_ = '' "
	cQuery += " AND ACO.D_E_L_E_T_ = '' "
	cQuery += " AND SB1.D_E_L_E_T_ = '' "

	cQuery += " ORDER BY 1,2 "

	TCQuery cQuery NEW ALIAS (cAliasQRY)

Return(cAliasQRY)

Static Function CriarArqTrab(cAliasQry)

	Local aStructQry  := {}
	Local oArqTrab    := Nil
	Local cAliasArea  := ""
	Local nFieldCount := 0
	Local nX          := 0

	aStructQry := (cAliasQry)->(DbStruct())

	oArqTrab   := FWTemporaryTable():New()
	oArqTrab:SetFields(aStructQry)

	oArqTrab:AddIndex("IDX1", {"A1CODLOJA","PRODUTO"})

	oArqTrab:Create()
	cAliasArea := oArqTrab:GetAlias()

	nFieldCount := (cAliasQry)->(FCount())

	While !(cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		For nX := 1 To nFieldCount
			cFieldName := (cAliasArea)->(FieldName(nX))
			(cAliasArea)->&(cFieldName) := (cAliasQry)->&(cFieldName)
		Next nX

		MsUnlock((cAliasArea))
		(cAliasQry)->(DbSkip())
	End

Return(oArqTrab)

Static Function UpdPrecos(lEnd)

	Local cAliasUpd := oBrowse:GetAlias()
	Local nQtdeReg  := 0
	Local nContReg  := 1
	Local cTime     := Time()
	Local _lOk      := .T.

	nQtdeReg := (cAliasUpd)->(RecCount())
	ProcRegua(nQtdeReg)
	(cAliasUpd)->(DbGoTop())

	Begin Transaction

		While !((cAliasUpd)->(Eof()))
			IncProc("Atualizando Preços - " + cValToChar(nContReg) + " / " + cValToChar(nQtdeReg))

			ACP->(DbGoTo((cAliasUpd)->(RECNO_ACP)))
			If (ACP->(Recno()) == (cAliasUpd)->(RECNO_ACP))
				RecLock("ACP", .F.)
				ACP->ACP_XPRCAN := ACP->ACP_PRECO
				ACP->ACP_XDTPRC := Date()
				ACP->ACP_XHRPRC := cTime
				ACP->ACP_PRECO  := Round((cAliasUpd)->(PRC_NOVO), 3)
				ACP->ACP_PERDES := (cAliasUpd)->(PDESCNOVO)
				ACP->(MsUnlock())
			Else
				DisarmTransaction()
				MsgStop("Não foi possível encontrar registro para aplicar atualização de preço! Recno: " + cValToChar((cAliasUpd)->(RECNO_ACP)))
				_lOk := .F.
			EndIf

			(cAliasUpd)->(DbSkip())

			If lEnd
				DisarmTransaction()
				MsgStop("Cancelado pelo usuário!")
				_lOk := .F.
			EndIf

			nContReg += 1
		End

	End Transaction

	If (_lOk)
		MsgInfo("Fim da atualização dos preços", "Concluído")
		CloseBrowse()
	EndIf

Return()