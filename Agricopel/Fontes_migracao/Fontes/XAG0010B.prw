#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0010C
Filtro dos vendedores para ajustar preços dos produtos do TRR
@author Leandro F Silveira
@since 30/10/2017
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0010C()
/*/
User Function XAG0010C()

	Private cRetSA3     := ""
	Private oArqTrbSA3  := Nil
	Private oBrowseSA3  := Nil

	CriaBrw()

Return(cRetSA3)

User Function XAG0010D()

	Local cAliasTRB := oArqTrbSA3:GetAlias()

	cRetSA3 := ""

	(cAliasTRB)->(DbGoTop())
	While !((cAliasTRB)->(Eof()))

		If (Empty((cAliasTRB)->(SA3_OK)) == oBrowseSA3:IsInvert())
			cRetSA3 += IIf(!Empty(cRetSA3), ", ", "") + "'" + AllTrim((cAliasTRB)->(A3_COD)) + "'"
		EndIf

		(cAliasTRB)->(DbSkip())
	End

	If (Empty(cRetSA3))
		MsgStop("É necesário confirmar pelo menos um Vendedor para prosseguir!")
	Else
		CloseBrowse()
	EndIf

Return()

Static Function CriaBrw()

	Local lMarcar := .F.

	oArqTrbSA3 := CriaTRB()

	oBrowseSA3 := FWMarkBrowse():New()
	oBrowseSA3:SetAlias(oArqTrbSA3:GetAlias())
	oBrowseSA3:SetDescription("Selecione os Vendedores")
	oBrowseSA3:SetFieldMark("SA3_OK")
	oBrowseSA3:DisableDetails()
	oBrowseSA3:SetTemporary(.T.)
	oBrowseSA3:SetWalkThru(.F.)
	oBrowseSA3:oBrowse:SetFixedBrowse(.T.)
	oBrowseSA3:oBrowse:SetDBFFilter(.F.)
	oBrowseSA3:oBrowse:SetUseFilter(.F.)
	oBrowseSA3:oBrowse:SetFilterDefault("")

	oBrowseSA3:bAllMark := { || CheckAll(oBrowseSA3:Mark() ,lMarcar := !lMarcar), oBrowseSA3:Refresh(.T.)}

	oBrowseSA3:SetColumns(MontaColunas("A3_COD",  "Cód. Vendedor"  ,01,"@!",1,TamSx3("A3_COD")[1],0))
	oBrowseSA3:SetColumns(MontaColunas("A3_NOME", "Desc. Vendedor" ,02,"@!",1,TamSx3("A3_NOME")[1],0))

	oBrowseSA3:Activate()

Return()

Static Function CriaTRB()

	Local aCampos     := {}
	Local cAliasQry   := ""
	Local cAliasArea  := ""
	Local nX    	  := 0

	Local oTrb := Nil

	Aadd(aCampos,{ "SA3_OK",  "C", TamSx3("C5_OK")[1]  , 0 } )
	Aadd(aCampos,{ "A3_COD",  "C", TamSx3("A3_COD")[1] , 0 } )
	Aadd(aCampos,{ "A3_NOME", "C", TamSx3("A3_NOME")[1], 0 } )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	oTrb:AddIndex("IDX1", {"A3_COD", "A3_NOME"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	cAliasQry := DadosTRB()

	While !(cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		(cAliasArea)->A3_COD  := (cAliasQry)->A3_COD
		(cAliasArea)->A3_NOME := (cAliasQry)->A3_NOME

		MsUnlock((cAliasArea))
		(cAliasQry)->(DbSkip())
	End

Return(oTrb)

Static Function DadosTRB()

	Local cQuery    := ""
	Local cAliasQRY := GetNextAlias()

	cQuery += " SELECT SA3.A3_COD, SA3.A3_NOME "

	cQuery += " FROM " + RetSQLName("SA1") + " SA1 WITH (NOLOCK), " + RetSQLName("ACO") + " ACO WITH (NOLOCK), "
	cQuery +=            RetSQLName("ACP") + " ACP WITH (NOLOCK), " + RetSQLName("DA1") + " DA1 WITH (NOLOCK), "
	cQuery +=            RetSQLName("SB1") + " SB1 WITH (NOLOCK), " + RetSQLName("SA3") + " SA3 WITH (NOLOCK) "

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
		cQuery += "   AND SA1.A1_VEND3   = SA3.A3_COD "
	Else
		cQuery += "   AND SA3.A3_COD IN (SA1.A1_VEND7, SA1.A1_VEND8) "
	EndIf

	If (!Empty(MV_PAR09))
		cQuery += " AND SB1.B1_LOCPAD = '" + MV_PAR09 + "'"
	EndIf

	cQuery += " AND ACP.ACP_CODPRO IN (" + cFiltroSB1 + ")"

	cQuery += " AND ACP.ACP_FILIAL = '" + xFilial("ACP") + "'"
	cQuery += " AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "'"
	cQuery += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "'"
	cQuery += " AND ACO.ACO_FILIAL = '" + xFilial("ACO") + "'"
	cQuery += " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery += " AND SA3.A3_FILIAL  = '" + xFilial("SA3") + "'"

	cQuery += " AND ACP.D_E_L_E_T_ = '' "
	cQuery += " AND SA1.D_E_L_E_T_ = '' "
	cQuery += " AND DA1.D_E_L_E_T_ = '' "
	cQuery += " AND ACO.D_E_L_E_T_ = '' "
	cQuery += " AND SB1.D_E_L_E_T_ = '' "
	cQuery += " AND SA3.D_E_L_E_T_ = '' "

	cQuery += " GROUP BY SA3.A3_COD, SA3.A3_NOME "

	cQuery += " ORDER BY SA3.A3_COD "

	TCQuery cQuery NEW ALIAS (cAliasQRY)

Return(cAliasQRY)

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowseSA3:DataArray[oBrowseSA3:At(),"+STR(nArrData)+"]}")
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

	ADD OPTION aRot TITLE 'Confirmar' ACTION 'U_XAG0010A' OPERATION 6 ACCESS 0 //OPERATION X

Return(aRot)

Static Function CheckAll(cMarca, lMarcar)

	Local cAliasTRB := oArqTrbSA3:GetAlias()
	Local aAreaTRB  := (cAliasTRB)->(GetArea())

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())

	While !(cAliasTRB)->(Eof())
		RecLock((cAliasTRB), .F.)
		(cAliasTRB)->SA3_OK := IIf(lMarcar, cMarca, '  ')
		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)

Return(.T.)