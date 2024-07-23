#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"


User function AGX447()

	Private aCols      := {}
	Private aHeader    := {}
	Private aCampos    := {}
	Private aRegistros := {}
	Private aRotina    := {}
	Private cPerg      := "AGX447"

	cTitulo := "Tela de apontamento de motivos de devolução."

	AADD(aRegistros,{cPerg,"01","Nota Nr ?","mv_ch1","C",TamSX3("F1_DOC")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Serie   ?","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Cliente ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"04","Loja    ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If Pergunte(cPerg,.T.)

		if !CarregarCapa()
			U_AGX447()
		EndIF
	
		MontarTela()

	EndIf

Return

Static Function CarregarCapa()

	// LOCALIZANDO A CAPA DA NOTA FISCAL
	cQuery := ""
	cQuery += " SELECT SF1.R_E_C_N_O_, "
	cQuery += "        F1_DOC, "
	cQuery += "        F1_SERIE, "
	cQuery += "        F1_FORNECE, "
	cQuery += "        A1_NOME, "
	cQuery += "        A1_LOJA, "
	cQuery += "        ROUND(F1_VALBRUT, 2) AS F1_VALBRUT, "
	cQuery += "        ROUND(F1_VALMERC, 2) AS F1_VALMERC "

	cQuery += " FROM " + RetSqlName("SF1") + " SF1, " + RetSqlName("SA1") + " SA1 "
	cQuery += " WHERE F1_DOC = '" + mv_par01 + "'"
	cQuery += " AND   F1_SERIE = '" + mv_par02 + "'"
	cQuery += " AND   F1_FORNECE = '" + mv_par03 + "'"
	cQuery += " AND   F1_LOJA = '" + mv_par04 + "'"

	cQuery += " AND   A1_COD = F1_FORNECE "
	cQuery += " AND   A1_LOJA = F1_LOJA "

	cQuery += " AND   A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND   SA1.D_E_L_E_T_ <> '*' "

	cQuery += " AND   F1_FILIAL = '" + xFilial("SF1") + "'"
	cQuery += " AND   SF1.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SF1") <> 0
       dbSelectArea("QRY_SF1")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SF1"

	if AllTrim(QRY_SF1->F1_DOC) <> ""
		CarregarItens()
		Return(.T.)
	Else
		ALERT("Nota Fiscal de Devolução não encontrada!")
		Return(.F.)
	EndIf

Return

Static Function CarregarItens()

    cQuery := ""
	cQuery += " SELECT SD1.R_E_C_N_O_, "
	cQuery += "        D1_COD, "
	cQuery += "        B1_DESC, "
	cQuery += "        D1_QUANT, "
	cQuery += "        D1_VUNIT, "
	cQuery += "        D1_TOTAL, "
	cQuery += "        D1_MOTDEV "

	cQuery += " FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SB1") + " SB1 "

	cQuery += " WHERE D1_DOC = '" + mv_par01 + "'"
	cQuery += " AND   D1_SERIE = '" + mv_par02 + "'"
	cQuery += " AND   D1_FORNECE = '" + mv_par03 + "'"
	cQuery += " AND   D1_LOJA = '" + mv_par04 + "'"

	cQuery += " AND   B1_COD = D1_COD "

	cQuery += " AND   D1_FILIAL = '" + xFilial("SD1") + "'"
	cQuery += " AND   SD1.D_E_L_E_T_ <> '*' "

	cQuery += " AND   B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += " AND   SB1.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SD1") <> 0
       dbSelectArea("QRY_SD1")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SD1"

Return

Static Function MontarTela()

	MV_PAR05 := SPACE(03)

	@ 000,000 TO 550, 1100 DIALOG oDlg TITLE "Apontamento de Motivo de devoluções"

	@ 005,010 Say "Nota:"
	@ 005,050 Say QRY_SF1->F1_DOC + " / " + QRY_SF1->F1_SERIE

	@ 005,250 Say "Valor Total NF:"
	@ 005,300 Say AllTrim(Transform(QRY_SF1->F1_VALBRUT,"@E 999,999.99"))

	@ 015,010 Say "Fornecedor:"
	@ 015,050 Say QRY_SF1->F1_FORNECE + " / " + QRY_SF1->A1_LOJA + " - " + QRY_SF1->A1_NOME

	@ 015,350 Say "Aplicar a Todos: "
	@ 015,400 Get MV_PAR05 Size 30,80 F3 "ZZC" 
	@ 015,450 BUTTON "Aplicar" SIZE 40,12 ACTION ApliTodos()

	MontarItens()

	@ 255,400 BUTTON "Gravar" SIZE 40,12 ACTION oGravar()
	@ 255,450 BUTTON "Sair" SIZE 40,12 ACTION Close(oDlg)

	dbSelectArea("QRY_SF1")
	dbCloseArea()

	dbSelectArea("QRY_SD1")
	dbCloseArea()

	ACTIVATE DIALOG oDlg CENTERED

Return

Static Function MontarItens()

Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aFields := {"D1_COD", "B1_DESC", "D1_QUANT", "D1_VUNIT", "D1_TOTAL", "D1_MOTDEV"}
Local aAlterFields := {"D1_MOTDEV"}
Static oMSNewGe1

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							 SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX                  	

	DbSelectArea("QRY_SD1")
	dbGoTop()
	While !Eof()

		AADD(aColsEx,{QRY_SD1->D1_COD, ;
				      QRY_SD1->B1_DESC, ;
					  QRY_SD1->D1_QUANT, ;
					  QRY_SD1->D1_VUNIT, ;
					  QRY_SD1->D1_TOTAL, ;
					  QRY_SD1->D1_MOTDEV, ;
					  QRY_SD1->R_E_C_N_O_, ;
					  .F.})

		DbSkip()

	EndDo

	oMSNewGe1 := MsNewGetDados():New( 030, 010, 250, 545, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

Static Function oGravar()

	Local nX
	Local aColsEx := {}
	Local nRecno := 0
	Local nMotivoDev := 0

	if ValidarGravacao()
		aColsEx := oMSNewGe1:aCols
	
		DbSelectArea("SD1")
		SD1->(DbSetOrder(2))
	
		For nX := 1 to Len(aColsEx)
	
			nRecno := aColsEx[nX, 7]
			nMotivoDev := aColsEx[nX, 6]
	
			SD1->(DbGoTo(nRecno))
	
			RecLock("SD1",.F.)
			SD1->D1_MOTDEV := nMotivoDev
			MsUnLock()
	
		Next nX
	
		Close(oDlg)
		MsgInfo("Gravação Concluída!")
		U_AGX447()
	EndIf
Return

Static Function ValidarGravacao()

	Local nX
	Local aColsEx := {}
	Local cCdMotivo := ""

	aColsEx := oMSNewGe1:aCols

	For nX := 1 to Len(aColsEx)

		cCdMotivo := aColsEx[nX, 6]
		
		DbSelectArea("ZZC")
		ZZC->(DbSetOrder(1))

		If AllTrim(cCdMotivo) <> "" .And. !DbSeek(cCdMotivo)
			ALERT("Código de motivo inválido! (" + cCdMotivo + ")")
			Return .F.
		EndIf

	Next nX

Return .T.

Static Function ApliTodos()

	Local nX
	Local aColsEx := {}

	aColsEx := oMSNewGe1:aCols

	For nX := 1 to Len(aColsEx)

		aColsEx[nX, 6] := MV_PAR05

	Next nX

Return