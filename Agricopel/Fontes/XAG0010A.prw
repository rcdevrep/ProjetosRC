#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0010A
Filtro dos produtos para ajustar preços dos produtos do TRR
@author Leandro F Silveira
@since 30/10/2017
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0010A()
/*/
User Function XAG0010A()

	Private cRetSB1     := ""
	Private oArqTrbSB1  := Nil
	Private oBrowseSB1  := Nil

	CriaBrw()

	oArqTrbSB1:Delete()

Return(cRetSB1)

User Function XAG0010B()

	Local cAliasTRB := oArqTrbSB1:GetAlias()

	cRetSB1 := ""

	(cAliasTRB)->(DbGoTop())
	While !((cAliasTRB)->(Eof()))

		If (!Empty((cAliasTRB)->(SB1_OK)))
			cRetSB1 += IIf(!Empty(cRetSB1), ", ", "") + "'" + AllTrim((cAliasTRB)->(B1_COD)) + "'"
		EndIf

		(cAliasTRB)->(DbSkip())
	End

	If (Empty(cRetSB1))
		MsgStop("É necesário confirmar pelo menos um produto para prosseguir!")
		(cAliasTRB)->(DbGoTop())
	Else
		CloseBrowse()
	EndIf

Return()

Static Function CriaBrw()

	Local lMarcar := .F.

	oArqTrbSB1 := CriaTRB()

	oBrowseSB1 := FWMarkBrowse():New()
	oBrowseSB1:SetAlias(oArqTrbSB1:GetAlias())
	oBrowseSB1:SetDescription("Selecione os produtos")
	oBrowseSB1:SetFieldMark("SB1_OK")
	oBrowseSB1:DisableDetails()
	oBrowseSB1:SetTemporary(.T.)
	oBrowseSB1:SetWalkThru(.F.)
	oBrowseSB1:oBrowse:SetFixedBrowse(.T.)
	oBrowseSB1:oBrowse:SetDBFFilter(.F.)
	oBrowseSB1:oBrowse:SetUseFilter(.F.)
	oBrowseSB1:oBrowse:SetFilterDefault("")

	oBrowseSB1:bAllMark := { || CheckAll(oBrowseSB1:Mark() ,lMarcar := !lMarcar), oBrowseSB1:Refresh(.T.)}

	oBrowseSB1:SetColumns(MontaColunas("B1_COD",    "Cód. Produto"  ,01,"@!",1,TamSx3("B1_COD")[1],0))
	oBrowseSB1:SetColumns(MontaColunas("B1_DESC",   "Desc. Produto" ,02,"@!",1,TamSx3("B1_DESC")[1],0))
	oBrowseSB1:SetColumns(MontaColunas("B1_LOCPAD", "Armazém Prod." ,03,"@!",1,TamSx3("B1_LOCPAD")[1],0))
	oBrowseSB1:SetColumns(MontaColunas("B1_TIPO",   "Tipo"          ,04,"@!",1,TamSx3("B1_TIPO")[1],0))
	oBrowseSB1:SetColumns(MontaColunas("B1_GRUPO",  "Grupo"         ,05,"@!",1,TamSx3("B1_GRUPO")[1],0))

	oBrowseSB1:Activate()

Return()

Static Function CriaTRB()

	Local aCampos     := {}
	Local cAliasQry   := ""
	Local cAliasArea  := ""
	Local oTrb := Nil

	Aadd(aCampos,{ "SB1_OK"   , "C", TamSx3("C5_OK")[1]     , 0 } )
	Aadd(aCampos,{ "B1_COD"   , "C", TamSx3("B1_COD")[1]    , 0 } )
	Aadd(aCampos,{ "B1_DESC"  , "C", TamSx3("B1_DESC")[1]   , 0 } )
	Aadd(aCampos,{ "B1_LOCPAD", "C", TamSx3("B1_LOCPAD")[1] , 0 } )
	Aadd(aCampos,{ "B1_TIPO"  , "C", TamSx3("B1_TIPO")[1]   , 0 } )
	Aadd(aCampos,{ "B1_GRUPO" , "C", TamSx3("B1_GRUPO")[1]  , 0 } )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	oTrb:AddIndex("IDX1", {"B1_COD", "B1_DESC"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	cAliasQry := DadosTRB()

	While !(cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		(cAliasArea)->B1_COD    := (cAliasQry)->B1_COD
		(cAliasArea)->B1_DESC   := (cAliasQry)->B1_DESC
		(cAliasArea)->B1_LOCPAD := (cAliasQry)->B1_LOCPAD
		(cAliasArea)->B1_TIPO   := (cAliasQry)->B1_TIPO
		(cAliasArea)->B1_GRUPO  := (cAliasQry)->B1_GRUPO

		MsUnlock((cAliasArea))
		(cAliasQry)->(DbSkip())
	End

Return(oTrb)

Static Function DadosTRB()

	Local cQuery    := ""
	Local cAliasQRY := GetNextAlias()

	cQuery += " SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_LOCPAD, "
	cQuery += "        SB1.B1_TIPO, SB1.B1_GRUPO "

	cQuery += " FROM " + RetSQLName("SA1") + " SA1 WITH (NOLOCK), " + RetSQLName("ACO") + " ACO WITH (NOLOCK), "
	cQuery +=            RetSQLName("ACP") + " ACP WITH (NOLOCK), " + RetSQLName("DA1") + " DA1 WITH (NOLOCK), "
	cQuery +=            RetSQLName("SB1") + " SB1 WITH (NOLOCK) "

	cQuery += " WHERE ACO.ACO_CODCLI = SA1.A1_COD "
	cQuery += "   AND ACO.ACO_LOJA   = SA1.A1_LOJA "
	cQuery += "   AND ACO.ACO_CODREG = ACP.ACP_CODREG "
	cQuery += "   AND DA1.DA1_CODTAB = ACO.ACO_CODTAB "
	cQuery += "   AND DA1.DA1_CODPRO = ACP.ACP_CODPRO "
	cQuery += "   AND SB1.B1_COD     = ACP.ACP_CODPRO "
	cQuery += "   AND SB1.B1_MSBLQL  = '2' "

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

	If (!Empty(MV_PAR09))
		cQuery += " AND SB1.B1_LOCPAD = '" + MV_PAR09 + "'"
	EndIf

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

	cQuery += " GROUP BY SB1.B1_COD, SB1.B1_DESC, SB1.B1_LOCPAD, SB1.B1_TIPO, SB1.B1_GRUPO "

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
		bData := &("{||" + cCampo +"}") //&("{||oBrowseSB1:DataArray[oBrowseSB1:At(),"+STR(nArrData)+"]}")
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

Static Function CheckAll(cMarca, lMarcar)

	Local cAliasTRB := oArqTrbSB1:GetAlias()
	Local aAreaTRB  := (cAliasTRB)->(GetArea())

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())

	While !(cAliasTRB)->(Eof())
		RecLock((cAliasTRB), .F.)
		(cAliasTRB)->SB1_OK := IIf(lMarcar, cMarca, '  ')
		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)

Return(.T.)
