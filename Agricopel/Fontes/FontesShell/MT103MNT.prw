#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"

// Ponto de entrada para permitir que o rateio de múltiplas naturezas venha automaticamente.

User Function MT103MNT()

	Local aHeaderMN := PARAMIXB[1]
	Local aColsMN   := PARAMIXB[2]
	Local aRet      := Nil

	Local nPosConta := AScan(aHeader, {|x| AllTrim(x[2] == "D1_CONTA")})
	Local lContaDif := .F.
	Local nI
	Local nTotIt    := 0

	If IsInCallStack("U_GOX008") .And. cTipo == "N" .And. (IsInCallStack("ImpClassNf") .Or. IsInCallStack("ImportarNFe"))

		If IsInCallStack("ImpClassNf")

			nTotIt := GetTotD1()

		Else

			nTotIt := Len(oGetD:aCols)

		EndIf

		If (Empty(aColsMN) .Or. Empty(aColsMN[1][1])) .And. N == nTotIt

			For nI := 2 To Len(aCols)

				If aCols[1][nPosConta] # aCols[nI][nPosConta]

					lContaDif := .T.

				EndIf

			Next nI

			If lContaDif .And. MsgYesNo("Deseja carregar o rateio de naturezas automaticamente de acordo com as contas contábeis dos itens?")

				aRet := DeParaConta()

				//{{"2188      ", 50, Space(TamSX3("EV_IDDOC")[1]), "SEV", 0, .F.}}

				//AAdd(aRet, {"21543     ", 50, Space(TamSX3("EV_IDDOC")[1]), "SEV", 0, .F.})

			EndIf

		EndIf

	EndIf

Return aRet

Static Function DeParaConta()

	Local nI
	Local nPosConta := AScan(aHeader, {|x| AllTrim(x[2]) == "D1_CONTA"})
	Local nPosTotal := AScan(aHeader, {|x| AllTrim(x[2]) == "D1_TOTAL"})
	Local aContas   := {}
	Local cConta
	Local nTotal    := 0
	Local nPos
	Local nTotRat   := 0
	Local aRetNat   := {}

	Private aHeaderNat := {}
	Private aColsNat   := {}
	Private aSize := MsAdvSize(.F., .F.)
	Private oDlgNat
	Private oLayNat
	Private oGetNat

	For nI := 1 To Len(aCols)

		cConta := aCols[nI][nPosConta]

		If (nPos := AScan(aContas, {|x| x[1] == cConta})) == 0

			AAdd(aContas, {cConta, aCols[nI][nPosTotal]})

		Else

			aContas[nPos][2] += aCols[nI][nPosTotal]

		EndIf

		nTotal += aCols[nI][nPosTotal]

	Next nI

	For nI := 1 To Len(aContas)

		aContas[nI][2] := Round(100 * aContas[nI][2] / nTotal, 2)

		nTotRat += aContas[nI][2]

	Next nI

	If 100 - nTotRat > 0

		ATail(aContas)[2] += (100 - nTotRat)

	EndIf

	DEFINE MSDIALOG oDlgNat FROM aSize[7], 0 TO aSize[6]/2, aSize[5]/2 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL

	oDlgNat:lEscClose := .F.

	oLayNat := FWLayer():New()
	oLayNat:Init(oDlgNat, .F.)

	oLayNat:AddLine('LIN1', 90, .F.)

	oLayNat:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')

	oLayNat:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Rateio Naturezas", 100, .F., .T., , 'LIN1',)


	//dbSelectArea("SX3")
	//SX3->( dbSetOrder(2) )

	aSD1 := FWSX3Util():GetAllFields( "SD1" , .F. )
	nX := 0

	For nX := 1 To Len(aSD1)
		if Alltrim(GetSx3Cache(aSD1[nX],"X3_CAMPO")) $ "D1_CONTA"
			AAdd(aHeaderNat, {Trim(X3Titulo()), GetSx3Cache(aSD1[nX],"X3_CAMPO"), GetSx3Cache(aSD1[nX],"X3_PICTURE"), GetSx3Cache(aSD1[nX],"X3_TAMANHO"), GetSx3Cache(aSD1[nX],"X3_DECIMAL"), "", GetSx3Cache(aSD1[nX],"X3_USADO"), GetSx3Cache(aSD1[nX],"X3_TIPO"), GetSx3Cache(aSD1[nX],"X3_F3"), GetSx3Cache(aSD1[nX],"X3_CONTEXT")})
		Endif
	next


	aCT1 := FWSX3Util():GetAllFields( "CT1" , .F. )
	nX := 0

	For nX := 1 To Len(aCT1)
		if Alltrim(GetSx3Cache(aCT1[nX],"X3_CAMPO")) $ "CT1_DESC01" 
			AAdd(aHeaderNat, {Trim(X3Titulo()), GetSx3Cache(aCT1[nX],"X3_CAMPO"), GetSx3Cache(aCT1[nX],"X3_PICTURE"), GetSx3Cache(aCT1[nX],"X3_TAMANHO"), GetSx3Cache(aCT1[nX],"X3_DECIMAL"), "", GetSx3Cache(aCT1[nX],"X3_USADO"), GetSx3Cache(aCT1[nX],"X3_TIPO"), GetSx3Cache(aCT1[nX],"X3_F3"), GetSx3Cache(aCT1[nX],"X3_CONTEXT")})
		Endif
	next

	aSE2 := FWSX3Util():GetAllFields( "SE2" , .F. )
	nX := 0

	For nX := 1 To Len(aSE2)
		if Alltrim(GetSx3Cache(aSE2[nX],"X3_CAMPO")) $ "E2_NATUREZ" 
			AAdd(aHeaderNat, {Trim(X3Titulo()), GetSx3Cache(aSE2[nX],"X3_CAMPO"), GetSx3Cache(aSE2[nX],"X3_PICTURE"), GetSx3Cache(aSE2[nX],"X3_TAMANHO"), GetSx3Cache(aSE2[nX],"X3_DECIMAL"), "", GetSx3Cache(aSE2[nX],"X3_USADO"), GetSx3Cache(aSE2[nX],"X3_TIPO"), GetSx3Cache(aSE2[nX],"X3_F3"), GetSx3Cache(aSE2[nX],"X3_CONTEXT")})
		Endif
	next

	aSEV := FWSX3Util():GetAllFields( "SEV" , .F. )
	nX := 0

	For nX := 1 To Len(aSEV)
		if Alltrim(GetSx3Cache(aSEV[nX],"X3_CAMPO")) $ "EV_PERC" 
			AAdd(aHeaderNat, {Trim(X3Titulo()), GetSx3Cache(aSEV[nX],"X3_CAMPO"), GetSx3Cache(aSEV[nX],"X3_PICTURE"), GetSx3Cache(aSEV[nX],"X3_TAMANHO"), GetSx3Cache(aSEV[nX],"X3_DECIMAL"), "", GetSx3Cache(aSEV[nX],"X3_USADO"), GetSx3Cache(aSEV[nX],"X3_TIPO"), GetSx3Cache(aSEV[nX],"X3_F3"), GetSx3Cache(aSEV[nX],"X3_CONTEXT")})
		Endif
	next
	
	For nI := 1 To Len(aContas)

		AAdd(aColsNat, {aContas[nI][1], ;
			Posicione("CT1", 1, xFilial("CT1") + aContas[nI][1], "CT1_DESC01"), ;
			Space(TamSX3("ED_CODIGO")[1]), ;
			aContas[nI][2], ;
			.F.})

	Next nI

	oGetNat := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", {"E2_NATUREZ"}, 000, 999, Nil, Nil, "AlwaysFalse", oLayNat:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), aHeaderNat, aColsNat)
	oGetNat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oLayNat:AddLine('LIN2', 10, .F.)

	oLayNat:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')

	oPanelBot := tPanel():New(0, 0, "", oLayNat:GetColPanel('COL1_LIN2', 'LIN2'), , , , , RGB(239, 243, 247), 000, 015)
	oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT

	oQuit := THButton():New(0, 0, "Ca&ncelar", oPanelBot, {|| oDlgNat:End()}, , , )
	oQuit:nWidth  := 80
	oQuit:nHeight := 10
	oQuit:Align   := CONTROL_ALIGN_RIGHT
	oQuit:SetColor(RGB(002, 070, 112), )

	oImp := THButton():New(0, 0, "&Confirmar", oPanelBot, {|| IIf(ConfNat(aRetNat), oDlgNat:End(), )}, , , )
	oImp:nWidth  := 80
	oImp:nHeight := 10
	oImp:Align := CONTROL_ALIGN_RIGHT
	oImp:SetColor(RGB(002, 070, 112), )

	ACTIVATE MSDIALOG oDlgNat CENTERED

Return aRetNat

Static Function ConfNat(aRetNat)

	Local nI
	Local aColAux := aClone(oGetNat:aCols)

	dbSelectArea("SED")
	SED->( dbSetOrder(1) )

	For nI := 1 To Len(aColAux)

		If Empty(aColAux[nI][3])

			MsgAlert("Todas as naturezas precisam ser preenchidas!")

			Return .F.

		EndIf

		If !SED->( dbSeek(xFilial("SED") + aColAux[nI][3]) )

			MsgAlert("A natureza informada na linha " + cValToChar(nI) + " é inválida!")

			Return .F.

		EndIf

	Next nI

	For nI := 1 To Len(aColAux)

		AAdd(aRetNat, {aColAux[nI][3], aColAux[nI][4], Space(TamSX3("EV_IDDOC")[1]), "SEV", 0, .F.})

	Next nI

Return .T.

Static Function GetTotD1()

	Local aAreaSD1 := SD1->( GetArea() )
	Local nTotD1   := 0

	dbSelectArea("SD1")
	SD1->( dbSetOrder(1) )
	SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )

	While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
			SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA

		nTotD1++

		SD1->( dbSkip() )

	EndDo

	RestArea(aAreaSD1)

Return nTotD1
