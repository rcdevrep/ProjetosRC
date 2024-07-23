#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047E
Replicador de registros de tabelas entre empresas
- Browse de pergunta da tabela a ser replicada
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return String, Primeira tabela que encontrada marcada no Browse
@example U_XAG0047E()
/*/
User Function XAG0047E()

	Private aRet47E     := ""
	Private oArqTrb47E  := Nil
	Private oBrowse47E  := Nil

	CriaBrw()

	oArqTrb47E:Delete()

Return(aRet47E)

Static Function CriaBrw()

	Local lMarcar := .F.

	Processa({|| oArqTrb47E := CriaTRB()}, "Aguarde, carregando registros", "", .F.)

	oBrowse47E := FWMarkBrowse():New()
	oBrowse47E:SetAlias(oArqTrb47E:GetAlias())
	oBrowse47E:SetDescription("Selecione as empresas de destino para replicar")
	oBrowse47E:SetFieldMark("TAB_OK")
	oBrowse47E:DisableDetails()
	oBrowse47E:SetTemporary(.T.)
	oBrowse47E:SetWalkThru(.F.)
	oBrowse47E:SetIgnoreARotina(.T.)
	oBrowse47E:oBrowse:SetFixedBrowse(.T.)
	oBrowse47E:oBrowse:SetDBFFilter(.F.)
	oBrowse47E:oBrowse:SetUseFilter(.T.)
	oBrowse47E:oBrowse:SetFilterDefault("")

	oBrowse47E:AddButton("Confirmar", { || U_XAG0047F()},,,, .F., 2 )

	oBrowse47E:bAllMark := { || CheckAll(oBrowse47E:Mark() ,lMarcar := !lMarcar), oBrowse47E:Refresh(.T.)}

    oBrowse47E:SetColumns(MontaColunas("M0_CODIGO",  "Código Empresa", 1, "", 1,  2, 0))
	oBrowse47E:SetColumns(MontaColunas("M0_NOMECOM", "Nome Empresa"  , 1, "", 1, 60, 0))

	oBrowse47E:Activate()

Return()

Static Function CriaTRB()

	Local aAreaSM0    := SM0->(GetArea())
	Local aCampos     := {}
	Local cUltCod     := ""
	Local cAliasArea  := ""
	Local nRecCount   := 0
	Local oTrb        := Nil

    Aadd(aCampos,{ "TAB_OK", "C", TamSx3("C5_OK")[1], 0 } )
	Aadd(aCampos,{ "M0_CODIGO", "C", 2, 0 } )
	Aadd(aCampos,{ "M0_NOMECOM", "C", 60, 0 } )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	oTrb:AddIndex("IDX1", {"M0_CODIGO"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	nRecCount := SM0->(RecCount())
	ProcRegua(nRecCount)

	SM0->(DbSetOrder(1))
    SM0->(DbGoTop())
	While !SM0->(Eof())

		If (cUltCod <> SM0->M0_CODIGO)
			RecLock((cAliasArea), .T.)

			(cAliasArea)->M0_CODIGO := SM0->M0_CODIGO
			(cAliasArea)->M0_NOMECOM := SM0->M0_NOMECOM

			MsUnlock((cAliasArea))

			cUltCod := SM0->M0_CODIGO
		EndIf

		SM0->(DbSkip())
		IncProc("Carregando ...")
	End

	RestArea(aAreaSM0)

Return(oTrb)

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse47E:DataArray[oBrowse47E:At(),"+STR(nArrData)+"]}")
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

	Local cAliasTRB := oArqTrb47E:GetAlias()
	Local aAreaTRB  := (cAliasTRB)->(GetArea())
	Local cTAB_OK   := IIf(lMarcar, cMarca, '  ')

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())

	While !(cAliasTRB)->(Eof())
		RecLock((cAliasTRB), .F.)
		(cAliasTRB)->TAB_OK := cTAB_OK
		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)

Return(.T.)