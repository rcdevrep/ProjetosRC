#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

User function AGX500(cNumConf)

	Private aCols      := {}
	Private aHeader    := {}
	Private aCampos    := {}
	Private aRegistros := {}
	Private cNrConf    := ""

	cNrConf := cNumConf

	cTitulo := "Digitação das quantidades da conferência cega"

	if ValidarConf()
		CarConf()
		MontarTela()
	EndIf

Return

Static Function ValidarConf()

    dbSelectArea("ZZI")
    dbSetOrder(1)
    ZZI->(dbSeek(xFilial("ZZI")+cNrConf))

    if ZZI->ZZI_STATUS = "B"
		MsgAlert("Conferência já baixada!")
		Return .F.
    EndIf

    cQuery := ""
    cQuery += " SELECT F1_DOC "

    cQuery += " FROM SF1010, ZZK010 "

    cQuery += " WHERE F1_DOC     = ZZK_DOC "
    cQuery += " AND   F1_FORNECE = ZZK_FORNEC "
    cQuery += " AND   F1_LOJA    = ZZK_LOJA "
    cQuery += " AND   F1_EMISSAO = ZZK_EMISSA "
    cQuery += " AND   F1_FILIAL  = ZZK_FILIAL "

    cQuery += " AND   ZZK_NUM    = '" + cNrConf + "'"
    cQuery += " AND   ZZK_FILIAL = '" + xFilial("ZZK") + "'"

    cQuery += " AND   F1_STATUS <> '' "

    cQuery += " AND   SF1010.D_E_L_E_T_ <> '*' "
    cQuery += " AND   ZZK010.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_ZZK") <> 0
       dbSelectArea("QRY_ZZK")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZK"

	if AllTrim(QRY_ZZK->F1_DOC) <> ""
		ALERT("Conferência Cega não disponível para digitação das quantidades! Uma ou mais notas já foram classificadas! [" + AllTrim(QRY_ZZK->F1_DOC) + "]")
		Return .F.
	EndIf

Return .T.

Static Function MontarTela()

	Local oGetVal
	Private dGetVal := CtoD("  /  /  ")

	@ 000,000 TO 650, 1100 DIALOG oDlog TITLE "Digitação das quantidades da conferência cega"

	@ 015,010 Say "Conferência:"
	@ 015,050 Say cNrConf

	@ 015,100 Say "Fornecedor:"
	@ 015,140 Say QRY_ZZI->ZZI_FORNEC + " - " + QRY_ZZI->NOME_PESSOA

	@ 030,010 Say "Nota(s):"
	@ 030,050 Say StrNotas()

	@ 260,010 Say "Validade:"
	@ 260,035 GET dGetVal object oGetVal size 40,80
	@ 260,080 BUTTON "Aplicar" SIZE 40,12 ACTION AplicVal()

	CarItens()
	MontarItens()

	oDlog:bInit := {|| EnchoiceBar(oDlog, {||oGravar() }, {||oDlog:End()},,{} )}

	ACTIVATE DIALOG oDlog CENTERED

Return

Static Function MontarItens()

Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aFields := {"ZZJ_PRODUT", "B1_DESC", "ZZJ_UM", "Lote", "ZZJ_QTDECF", "ZZJ_DTVALI", "LOCAL_NF"}
Local aAlterFields := {"ZZJ_QTDECF", "ZZJ_DTVALI"}
Static oMSNewGe1

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)

		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
							 SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		ElseIf aFields[nX] = "Lote"
			Aadd(aHeaderEx, {"Lote","USA_LOTE","",3,0,,SX3->X3_USADO,"C",,,,})
		ElseIf aFields[nX] = "LOCAL_NF"
			Aadd(aHeaderEx, {"Armazém NF","LOCAL_NF","",3,0,,SX3->X3_USADO,"C",,,,})
		Endif

	Next nX

	DbSelectArea("QRY_ZZJ")
	dbGoTop()
	While !Eof()

		AADD(aColsEx,{QRY_ZZJ->ZZJ_PRODUT, ;
                      QRY_ZZJ->B1_DESC, ;
                      QRY_ZZJ->ZZJ_UM, ;
                      IIF(QRY_ZZJ->B1_RASTRO = "L", "SIM", "NAO"), ;
                      QRY_ZZJ->ZZJ_QTDECF, ;
                      QRY_ZZJ->ZZJ_DTVALI, ;
                      QRY_ZZJ->LOCAL_NF, ;
					  QRY_ZZJ->ZZJ_QTDENF, ;
					  QRY_ZZJ->RECNO_ZZJ, ;
					  .F.})

		DbSkip()

	EndDo

	oMSNewGe1 := MsNewGetDados():New( 040, 010, 250, 545, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlog, aHeaderEx, aColsEx)

	dbSelectArea("QRY_ZZJ")
	dbCloseArea()
Return

Static Function oGravar()

	Local nX
	Local aColsEx := {}
	Local nRecnoZZJ := 0
	Local nQuant := 0
	Local nQuant_NF := 0
	Local dDtValidade := CTOD("  /  /  ")
	Local lConfOK := .T.

	aColsEx := oMSNewGe1:aCols

	If ValidarGravacao()
		For nX := 1 to Len(aColsEx)

			nQuant      := aColsEx[nX, 5]
			dDtValidade := aColsEx[nX, 6]
			nQuant_NF   := aColsEx[nX, 8]
			nRecnoZZJ   := aColsEx[nX, 9]

			DbSelectArea("ZZJ")
			ZZJ->(DbGoTo(nRecnoZZJ))

			RecLock("ZZJ",.F.)
			ZZJ->ZZJ_QTDECF := nQuant
			ZZJ->ZZJ_DTVALI := dDtValidade
			MsUnLock()

			If Round(nQuant, 4) <> Round(nQuant_NF, 4)
				lConfOK := .F.
			EndIf

		Next nX

		DbSelectArea("TRB")
		RecLock("TRB",.F.)
		TRB->STATUSCONF := IIF(lConfOK, "B","I")
		MsUnLock()

		dbSelectarea("ZZI")
		dbSetOrder(1)
		ZZI->(dbSeek(xFilial("ZZI")+cNrConf))
		RecLock("ZZI", .F.)
		ZZI->ZZI_STATUS := IIF(lConfOK, "B","I")
		MsUnLock()

		if lConfOK
			ValidadeNF()
			EnvEmail()
			MsgInfo("Conferência finalizada com sucesso!", "Conferência Cega")
		Else
			MsgAlert("Conferência digitada possui inconsistências!", "Conferência Cega")
		EndIf
		
		Close(oDlog)
	EndIf

Return

Static Function ValidarGravacao()

	Local dDtValidade := CTOD("  /  /  ")
	Local dDataNula   := CTOD("  /  /  ")
	Local aProdErro   := {}
	Local dDtValidMin := DTOS(Date() + 5)

	aColsEx := oMSNewGe1:aCols

	For nX := 1 to Len(aColsEx)

	    If aColsEx[nX, 4] = "SIM"
			dDtValidade := aColsEx[nX, 6]

			If dDtValidade = dDataNula

				cMsg := "É necessário digitar a data de validade para produtos que possuem lote." + Chr(13) + Chr(10)
				cMsg += "Produto: " + AllTrim(aColsEx[nX, 1]) + " - " + AllTrim(aColsEx[nX, 2])
				ALERT(cMsg)
				Return .F.
			Else
			
				If DTOS(dDtValidade) <= dDtValidMin
					AADD(aProdErro, AllTrim(aColsEx[nX, 1]) + " - " + AllTrim(aColsEx[nX, 2]))
				EndIf

			EndIf
	    EndIf

	Next nX

	If Len(aProdErro) > 0

		cMensagem := "Há um ou mais produtos com a validade inferior a " + dDtValidMin + Chr(13) + Chr(10)

		For nX := 1 To Len(aProdErro)
			cMensagem += "- " + aProdErro[nX] + Chr(13) + Chr(10)
		Next nX
		
		cMensagem += "Deseja continuar com a operação?"

		If Aviso("ATENÇÃO!", cMensagem, {"Sim","Não"}, 3) == 2
			Return .F.
		EndIf

	EndIf

Return .T.

Static Function CarItens()

    cQuery := ""
    
    cQuery += " SELECT ZZJ_PRODUT, "
    cQuery += "        ZZJ_UM, "
    cQuery += "        ZZJ_QTDENF, "
    cQuery += "        ZZJ_QTDECF, "
    cQuery += "        ZZJ_DTVALI, "

    cQuery += "        ZZJ010.R_E_C_N_O_ AS RECNO_ZZJ, "

    cQuery += "        (SELECT TOP 1 D1_LOCAL "
    cQuery += "         FROM SD1010, ZZK010 "
    cQuery += "         WHERE D1_COD     = ZZJ_PRODUT "
    cQuery += "         AND   D1_FILIAL  = ZZJ_FILIAL "
    cQuery += "         AND   D1_DOC     = ZZK_DOC "
    cQuery += "         AND   D1_SERIE   = ZZK_SERIE "
    cQuery += "         AND   D1_EMISSAO = ZZK_EMISSA "
    cQuery += "         AND   D1_FORNECE = ZZK_FORNEC "
    cQuery += "         AND   D1_LOJA    = ZZK_LOJA "
    cQuery += "         AND   ZZJ_NUM    = ZZK_NUM "
    cQuery += "         AND   ZZJ_FILIAL = ZZK_FILIAL "
    cQuery += "         AND   SD1010.D_E_L_E_T_ <> '*' "
    cQuery += "         AND   ZZK010.D_E_L_E_T_ <> '*') AS LOCAL_NF, "

    cQuery += "        B1_DESC, "
    cQuery += "        B1_PESO, "
    cQuery += "        B1_RASTRO "

    cQuery += " FROM ZZJ010, SB1010 "

    cQuery += " WHERE ZZJ_NUM = '" + cNrConf + "'"
    cQuery += " AND   ZZJ_FILIAL = '" + xFilial("ZZJ") + "'"

    cQuery += " AND   B1_FILIAL = ZZJ_FILIAL "
    cQuery += " AND   B1_COD = ZZJ_PRODUT "

    cQuery += " AND ZZJ010.D_E_L_E_T_ <> '*' "
    cQuery += " AND SB1010.D_E_L_E_T_ <> '*' "

    cQuery += " ORDER BY ZZJ_SEQUEN "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_ZZJ") <> 0
       dbSelectArea("QRY_ZZJ")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZJ"
	TCSetField("QRY_ZZJ", "ZZJ_DTVALI", "D", 08, 0)

Return

Static Function CarConf()

    cQuery := ""

    cQuery += " SELECT ZZI_NUM, "
    cQuery += "        ZZI_FORNEC + ' / ' + ZZI_LOJA AS ZZI_FORNEC, "
    cQuery += "        ZZI_EMISSA,

    cQuery += "        CASE WHEN ZZI_TIPO = 'D' "
    cQuery += "             THEN (SELECT A1_NOME "
    cQuery += "                   FROM SA1010 "
    cQuery += "                   WHERE A1_COD    = ZZI_FORNEC "
    cQuery += "                   AND   A1_LOJA   = ZZI_LOJA "
    cQuery += "                   AND   A1_FILIAL = '" + xFilial("SA1") + "'"
    cQuery += "                   AND   D_E_L_E_T_ <> '*') "

    cQuery += "             ELSE (SELECT A2_NOME "
    cQuery += "                   FROM SA2010 "
    cQuery += "                   WHERE A2_COD    = ZZI_FORNEC "
    cQuery += "                   AND   A2_LOJA   = ZZI_LOJA "
    cQuery += "                   AND   A2_FILIAL = '" + xFilial("SA2") + "'"
    cQuery += "                   AND   D_E_L_E_T_ <> '*') "
    cQuery += "        END AS NOME_PESSOA "

    cQuery += " FROM ZZI010 "

    cQuery += " WHERE ZZI_NUM = '" + cNrConf + "'"
    cQuery += " AND   ZZI_FILIAL = '" + xFilial("ZZI") + "'"
    cQuery += " AND   D_E_L_E_T_ <> '*'

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_ZZI") <> 0
       dbSelectArea("QRY_ZZI")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZI"
	TCSetField("QRY_ZZI", "ZZI_EMISSA", "D", 08, 0)

Return

Static Function StrNotas()

	cNotas := ""
    cQuery := ""

    cQuery += " SELECT ZZK_DOC, "
    cQuery += "        ZZK_SERIE "
    cQuery += " FROM ZZK010 "

    cQuery += " WHERE ZZK_NUM = '" + cNrConf + "'"
    cQuery += " AND   ZZK_FILIAL = '" + xFilial("ZZK") + "'"
    cQuery += " AND   D_E_L_E_T_ <> '*' "

    cQuery += " ORDER BY ZZK_DOC "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_ZZK") <> 0
       dbSelectArea("QRY_ZZK")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZK"

	dbSelectArea("QRY_ZZK")
	While !Eof()

		if AllTrim(cNotas) <> ""
			cNotas += " / " + AllTrim(QRY_ZZK->ZZK_DOC) + "-" + AllTrim(QRY_ZZK->ZZK_SERIE)
		Else
			cNotas := AllTrim(QRY_ZZK->ZZK_DOC) + "-" + AllTrim(QRY_ZZK->ZZK_SERIE)
		EndIf

		dbSkip()
	End

    If Select("QRY_ZZK") <> 0
       dbSelectArea("QRY_ZZK")
   	   dbCloseArea()
    Endif

Return cNotas

Static Function ValidadeNF()

	cQuery := ""
	cQuery += " UPDATE SD1010 SET "
	
	cQuery += " D1_DTVALID = ZZJ_DTVALI "

	cQuery += " FROM SB1010, ZZJ010, ZZK010 "

	cQuery += " WHERE ZZK_NUM    = '" + cNrConf + "'"
	cQuery += " AND   ZZK_FILIAL = '" + xFilial("ZZK") + "'"

	cQuery += " AND   ZZK_DOC    = D1_DOC "
	cQuery += " AND   ZZK_SERIE  = D1_SERIE "
	cQuery += " AND   ZZK_EMISSA = D1_EMISSAO "
	cQuery += " AND   ZZK_FILIAL = D1_FILIAL "

	cQuery += " AND   ZZJ_FILIAL = D1_FILIAL "
	cQuery += " AND   ZZJ_PRODUT = D1_COD "
	cQuery += " AND   ZZJ_NUM    = ZZK_NUM "

	cQuery += " AND   ZZJ_UM     = B1_UM "
	cQuery += " AND   B1_COD     = D1_COD "
	cQuery += " AND   B1_FILIAL  = D1_FILIAL "
	cQuery += " AND   B1_RASTRO  = 'L' "

	cQuery += " AND   SD1010.D_E_L_E_T_ <> '*' "
	cQuery += " AND   ZZJ010.D_E_L_E_T_ <> '*' "
	cQuery += " AND   ZZK010.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SB1010.D_E_L_E_T_ <> '*' "
	
	If TCSQLExec(cQuery) < 0
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

Return

Static Function EnvEmail()

	Local nTotal := 0
	Local _x     := 0
	Local cDest  := ""
	Local cBCC   := ""
	Local lEnvTeste := .F.

	oProcess := TWFProcess():New( "EMAILCONF", "Confirmação de Conferência Cega" )
	oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\BAIXA_CONFCEGA.HTM" )

	lEnvTeste := GetEnvServer() == "envteste2"

	If lEnvTeste
		oProcess:cSubject := "[TESTE] [BAIXA] de Conferência Cega Nr.: " + cFilAnt + "-" + cNrConf
	Else
		oProcess:cSubject := "[BAIXA] de Conferência Cega Nr.: " + cFilAnt + "-" + cNrConf
	EndIf

	oHtml := oProcess:oHTML

	oHtml:ValByName("nrconf", cFilAnt + "-" + cNrConf )
	oHtml:ValByName("emissao", QRY_ZZI->ZZI_EMISSA )
	oHtml:ValByName("fornecedor", QRY_ZZI->ZZI_FORNEC + " - " + QRY_ZZI->NOME_PESSOA )

	CarEmail()

	If AllTrim(QRY_EMAIL->B1_LOCPAD) == "02" .Or. AllTrim(QRY_EMAIL->B1_LOCPAD) == "91"
		U_DestEmail(oProcess, "DIGITACAO_CONFCEGA_CONV")
	Else
		If AllTrim(QRY_EMAIL->B1_LOCPAD) == "01" 
			U_DestEmail(oProcess, "DIGITACAO_CONFCEGA_LUB")
		EndIf
	EndIf

	While QRY_EMAIL->(!Eof())

		aAdd( (oHtml:ValByName( "produto.nrnota" )),     QRY_EMAIL->D1_DOC + " - " + QRY_EMAIL->D1_SERIE)
		aAdd( (oHtml:ValByName( "produto.coddesc" )),    QRY_EMAIL->D1_COD + " - " + QRY_EMAIL->B1_DESC)
		aAdd( (oHtml:ValByName( "produto.quantidade" )), Transform(QRY_EMAIL->D1_QUANT,'@E 999,999.99' ))
		aAdd( (oHtml:ValByName( "produto.embalagem" )),  QRY_EMAIL->D1_UM)
		aAdd( (oHtml:ValByName( "produto.validade" )),   QRY_EMAIL->D1_DTVALID)

		QRY_EMAIL->(dbSkip())

	End

	U_DestEmail(oProcess, "DIGITACAO_CONFCEGA")

	oProcess:Start()
	oProcess:Finish()

	If Select("QRY_EMAIL") <> 0
		dbSelectArea("QRY_EMAIL")
		dbCloseArea()
	Endif

Return

Static Function CarEmail()

	cQuery := ""

	cQuery += " SELECT D1_DOC, "
	cQuery += "        D1_SERIE, "
	cQuery += " 	   D1_COD, "
	cQuery += " 	   D1_QUANT, "
	cQuery += " 	   B1_DESC, "
	cQuery += " 	   B1_LOCPAD, "
	cQuery += " 	   D1_DTVALID, "
	cQuery += " 	   D1_UM "

	cQuery += " FROM SB1010 SB1, SD1010 SD1, ZZK010 ZZK "

	cQuery += " WHERE ZZK_NUM     = '" + cNrConf + "'"
	cQuery += " AND   ZZK_FILIAL  = '" + xFilial("ZZK") + "'"

	cQuery += " AND   ZZK_DOC     = D1_DOC "
	cQuery += " AND   ZZK_SERIE   = D1_SERIE "
	cQuery += " AND   ZZK_FORNEC  = D1_FORNECE "
	cQuery += " AND   ZZK_LOJA    = D1_LOJA "
	cQuery += " AND   ZZK_FILIAL  = D1_FILIAL "

	cQuery += " AND   B1_COD      = D1_COD "
	cQuery += " AND   B1_FILIAL   = D1_FILIAL "

	cQuery += " AND   SB1.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SD1.D_E_L_E_T_ <> '*' "
	cQuery += " AND   ZZK.D_E_L_E_T_ <> '*' "

	cQuery += " ORDER BY D1_DOC, D1_ITEM "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_EMAIL") <> 0
       dbSelectArea("QRY_EMAIL")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_EMAIL"
	TCSetField("QRY_EMAIL", "D1_DTVALID", "D", 08, 0)

Return

Static Function AplicVal()

	Local nX
	Local aColsEx := {}

	aColsEx := oMSNewGe1:aCols

	For nX := 1 to Len(aColsEx)

		aColsEx[nX, 6] := dGetVal

	Next nX

Return