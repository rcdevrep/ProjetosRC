#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047C
Replicador de registros de tabelas entre empresas
- Browse de pergunta da tabela a ser replicada
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return String, Primeira tabela que encontrada marcada no Browse
@example U_XAG0047C()
/*/
User Function XAG0047C(cTabRepl)

	Private aRet47C     := ""
	Private oArqTrb47C  := Nil
	Private oBrowse47C  := Nil

	CriaBrw(cTabRepl)

	oArqTrb47C:Delete()

Return(aRet47C)

Static Function CriaBrw(cTabRepl)

	Local lMarcar    := .F.
	Local cCampoFil  := ""
	Local cFilterDef := ""

	Processa({|| oArqTrb47C := CriaTRB(cTabRepl)}, "Aguarde - carregando registros", "", .F.)

	oBrowse47C := FWMarkBrowse():New()
	oBrowse47C:SetAlias(oArqTrb47C:GetAlias())
	oBrowse47C:SetDescription("Selecione os registros para replicar")
	oBrowse47C:SetFieldMark("TAB_OK")
	oBrowse47C:DisableDetails()
	oBrowse47C:SetTemporary(.T.)
	oBrowse47C:SetWalkThru(.F.)
	oBrowse47C:SetIgnoreARotina(.T.)
	oBrowse47C:oBrowse:SetFixedBrowse(.T.)
	oBrowse47C:oBrowse:SetDBFFilter(.F.)
	oBrowse47C:oBrowse:SetUseFilter(.F.)

	If (!Empty(xFilial(cTabRepl)))
		cCampoFil := Separa((cTabRepl)->(IndexKey(1)), "+", .F.)[1]
		If ("_FILIAL" $ cCampoFil)
			cFilterDef := cCampoFil + "=='" + xFilial(cTabRepl) + "'"
		EndIf
	EndIf

	oBrowse47C:oBrowse:SetFilterDefault(cFilterDef)
	oBrowse47C:AddButton("Confirmar", { || Processa({|| U_XAG0047D()}, "Aguarde - Processando registros selecionados", "", .F.)},,,, .F., 2 )

	oBrowse47C:bAllMark := { || CheckAll(oBrowse47C:Mark() ,lMarcar := !lMarcar), oBrowse47C:Refresh(.T.)}

    BrowseCols(cTabRepl)

	oBrowse47C:Activate()

Return()

Static Function BrowseCols(cTabRepl)

    Local aSegSX3    := SX3->(GetArea())
	Local lMostraFil := !Empty(xFilial(cTabRepl))

    SX3->(DbSetOrder(1))
    SX3->(DbGoTop())
    SX3->(DbSeek(cTabRepl))
    While (!SX3->(Eof()) .And. SX3->(X3_ARQUIVO) == cTabRepl)

        If ((X3Uso(SX3->X3_USADO) .Or. SX3->X3_BROWSE == "S") .And. SX3->X3_CONTEXT <> "V") .Or. (lMostraFil .And. 'FILIAL' $ SX3->X3_CAMPO)
            oBrowse47C:SetColumns(MontaColunas(AllTrim(SX3->X3_CAMPO), SX3->X3_TITULO, 1, SX3->X3_PICTURE, 1, SX3->X3_TAMANHO, SX3->X3_DECIMAL))
        EndIf

        SX3->(DbSkip())
    End

    RestArea(aSegSX3)

Return()

Static Function CriaTRB(cTabRepl)

	Local aCampos     := {}
    Local aIndexTab   := {}
	Local cAliasArea  := ""
    Local cCampoTab   := ""
    Local nX          := 0
    Local nFCount     := 0
	Local nRecCount   := 0
	Local oTrb        := Nil

    Aadd(aCampos,{ "TAB_OK", "C", TamSx3("C5_OK")[1], 0 } )

    nFCount := (cTabRepl)->(FCount())
    SX3->(DbSetOrder(2))

    For nX := 1 To nFCount
        cCampoTab  := AllTrim((cTabRepl)->(FieldName(nX)))

        SX3->(DbGoTop())
        If (SX3->(DbSeek(cCampoTab)) .And. SX3->X3_CONTEXT <> "V") 
            Aadd(aCampos, {cCampoTab, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
        End
    End

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

    aIndexTab :=  Separa((cTabRepl)->(IndexKey(1)), "+", .F.)
	oTrb:AddIndex("IDX1", aIndexTab)

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

    nFCount   := (cAliasArea)->(FCount())
	nRecCount := (cTabRepl)->(RecCount())
	ProcRegua(nRecCount)

    (cTabRepl)->(DbGoTop())
	While !(cTabRepl)->(Eof())

		RecLock((cAliasArea), .T.)

        For nX := 2 To nFCount

            cCampoTab := AllTrim((cAliasArea)->(FieldName(nX)))
            (cAliasArea)->&(cCampoTab) := (cTabRepl)->&(cCampoTab)
        End

		MsUnlock((cAliasArea))
		(cTabRepl)->(DbSkip())

		IncProc("Carregando ...")
	End

Return(oTrb)

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse47C:DataArray[oBrowse47C:At(),"+STR(nArrData)+"]}")
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

	Local cAliasTRB := oArqTrb47C:GetAlias()
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