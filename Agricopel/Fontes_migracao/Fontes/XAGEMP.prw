#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGEMP.prw
Abre um Mark Browse para marcar empresas
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return Array, contendo as empresas selecionadas
@example U_XAGEMP(.T.)
/*/
User Function XAGEMP(lMostraFil)

	Private aRetEmp     := ""
	Private oArqTrbEmp  := Nil
	Private oBrowseEmp  := Nil

	CriaBrw(lMostraFil)
	oArqTrbEmp:Delete()

Return(aRetEmp)

Static Function Confirmar()

	Local cAliasEmp := oArqTrbEmp:GetAlias()
	Local nFCount   := 0
	Local nX        := 0
	Local aLinha    := {}

	aRetEmp := {}
	nFCount := (cAliasEmp)->(FCount())

	(cAliasEmp)->(DbGoTop())

	While !((cAliasEmp)->(Eof()))

		If (!Empty((cAliasEmp)->(TAB_OK)))

			aLinha := {}
			For nX := 2 To nFCount
				aAdd(aLinha, (cAliasEmp)->(FieldGet(nX)))
			End

			aAdd(aRetEmp, aLinha)
		EndIf

		(cAliasEmp)->(DbSkip())
	End

	If (Empty(aRetEmp))
		MsgStop("É necesário confirmar um dos registros para prosseguir!")
		(cAliasEmp)->(DbGoTop())
	Else
		CloseBrowse()
	EndIf

Return

Static Function CriaBrw(lMostraFil)

	Local lMarcar := .F.

	If (lMostraFil)
		Processa({|| oArqTrbEmp := CriaTRBFil()}, "Aguarde, carregando registros", "", .F.)
	Else
		Processa({|| oArqTrbEmp := CriaTRBEmp()}, "Aguarde, carregando registros", "", .F.)
	EndIf

	oBrowseEmp := FWMarkBrowse():New()
	oBrowseEmp:SetAlias(oArqTrbEmp:GetAlias())
	oBrowseEmp:SetDescription("Selecione as empresas de destino para replicar")
	oBrowseEmp:SetFieldMark("TAB_OK")
	oBrowseEmp:DisableDetails()
	oBrowseEmp:SetTemporary(.T.)
	oBrowseEmp:SetWalkThru(.F.)
	oBrowseEmp:SetIgnoreARotina(.T.)
	oBrowseEmp:SetMenuDef("")
	oBrowseEmp:oBrowse:SetFixedBrowse(.T.)
	oBrowseEmp:oBrowse:SetDBFFilter(.F.)
	oBrowseEmp:oBrowse:SetUseFilter(.F.)
	oBrowseEmp:oBrowse:SetFilterDefault("")
	oBrowseEmp:oBrowse:SetIgnoreARotina(.T.)
	oBrowseEmp:oBrowse:SetMenuDef("")

	oBrowseEmp:AddButton("Confirmar", { || Confirmar(lMostraFil)},,,, .F., 2 )

	oBrowseEmp:bAllMark := { || CheckAll(oBrowseEmp:Mark() ,lMarcar := !lMarcar), oBrowseEmp:Refresh(.T.)}

	If (lMostraFil)
    	oBrowseEmp:SetColumns(MontaColunas("M0_CODIGO",  "Código Empresa", 1, "", 1,  2, 0))
		oBrowseEmp:SetColumns(MontaColunas("M0_CODFIL",  "Código Filial", 1, "", 1,  2, 0))
		oBrowseEmp:SetColumns(MontaColunas("M0_NOMECOM", "Nome Empresa"  , 1, "", 1, 60, 0))
		oBrowseEmp:SetColumns(MontaColunas("M0_NOME", "Fantasia"  , 1, "", 1, 60, 0))
		oBrowseEmp:SetColumns(MontaColunas("M0_FILIAL", "Nome Filial"  , 1, "", 1, 60, 0))
	Else
    	oBrowseEmp:SetColumns(MontaColunas("M0_CODIGO",  "Código Empresa", 1, "", 1,  2, 0))
		oBrowseEmp:SetColumns(MontaColunas("M0_NOMECOM", "Nome Empresa"  , 1, "", 1, 60, 0))
	EndIf

	oBrowseEmp:Activate()

Return()

Static Function CriaTRBEmp()

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

Static Function CriaTRBFil()

	Local aAreaSM0    := SM0->(GetArea())
	Local aCampos     := {}
	Local cUltCod     := ""
	Local cAliasArea  := ""
	Local nRecCount   := 0
	Local oTrb        := Nil

    Aadd(aCampos,{ "TAB_OK", "C", TamSx3("C5_OK")[1], 0 } )
	Aadd(aCampos,{ "M0_CODIGO", "C", 2, 0 } )
	Aadd(aCampos,{ "M0_CODFIL", "C", 2, 0 } )
	Aadd(aCampos,{ "M0_NOMECOM", "C", 60, 0 } )
	Aadd(aCampos,{ "M0_NOME", "C", 60, 0 } )
	Aadd(aCampos,{ "M0_FILIAL", "C", 60, 0 } )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	oTrb:AddIndex("IDX1", {"M0_CODIGO", "M0_CODFIL"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	nRecCount := SM0->(RecCount())
	ProcRegua(nRecCount)

	SM0->(DbSetOrder(1))
    SM0->(DbGoTop())
	While !SM0->(Eof())

		RecLock((cAliasArea), .T.)

		(cAliasArea)->M0_CODIGO := SM0->M0_CODIGO
		(cAliasArea)->M0_CODFIL := SM0->M0_CODFIL
		(cAliasArea)->M0_NOMECOM := SM0->M0_NOMECOM
		(cAliasArea)->M0_NOME := SM0->M0_NOME
		(cAliasArea)->M0_FILIAL := SM0->M0_FILIAL

		MsUnlock((cAliasArea))

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
		bData := &("{||" + cCampo +"}") //&("{||oBrowseEmp:DataArray[oBrowseEmp:At(),"+STR(nArrData)+"]}")
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

	Local cAliasTRB := oArqTrbEmp:GetAlias()
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