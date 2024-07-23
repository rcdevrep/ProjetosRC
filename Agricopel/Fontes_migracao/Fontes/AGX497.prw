#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥AGX497    ∫Autor  Leandro              ∫ Data ≥  12/13/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Tela de GeraÁ„o de ConferÍncia Cega                        π±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function AGX497()

	Local   cRet 	   := ""
	Private	cCadastro  := "GeraÁ„o de ConferÍncia Cega"
	Private	cMarca     := GetMark() 
	Private bFiltraBrw := {|| Nil }	  
	Private aCamposArq := {}  

	Private  aRotina   := { { "Gerar Conf Cega" ,"U_AGX497GeraConf"  , 0, 1},;
    	                    { "Par‚metros" ,"U_AGX497Param()"  , 0, 1}}

	If !CriarPerguntas()
		Return
	EndIf

	CriaArqTrab()
	CarregarDadosBrowse()
	CriarBrowse()

Return

Static Function CriarPerguntas

	Private aRegistros := {}
	Private cPerg      := "AGX497"

	AADD(aRegistros,{cPerg,"01","Dt Digitacao De  ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Dt Digitacao Ate ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Armazem Produto  ?","mv_ch3","C",2,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Fornecedor       ?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Loja             ?","mv_ch5","C",2,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Status           ?","mv_ch6","N",1,0,0,"C","","mv_par06","Emitidas","","","N„o Emitidas","","","Todas","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Tipo da Nota     ?","mv_ch7","N",1,0,0,"C","","mv_par07","Normal","","","DevoluÁ„o","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	Return Pergunte(cPerg,.T.)

Return

Static Function CarregarDadosBrowse()

	Local cStatus := ""

	cQuery := ""
	cQuery += " SELECT CASE WHEN F1_TIPO = 'D' "
	cQuery += "             THEN (SELECT A1_NOME "
	cQuery += "                   FROM " + RetSqlName("SA1")
	cQuery += "                   WHERE A1_COD = F1_FORNECE "
	cQuery += "                   AND   A1_LOJA = F1_LOJA "
	cQuery += "                   AND   A1_FILIAL = '" + xFilial('SA1') + "'"
	cQuery += "                   AND   D_E_L_E_T_ <> '*') "

	cQuery += "             ELSE (SELECT A2_NOME "
	cQuery += "                   FROM " + RetSqlName("SA2")
	cQuery += "                   WHERE A2_COD = F1_FORNECE "
	cQuery += "                   AND   A2_LOJA = F1_LOJA "
	cQuery += "                   AND   A2_FILIAL = '" + xFilial('SA2') + "'"
	cQuery += "                   AND   D_E_L_E_T_ <> '*') "
	cQuery += "        END AS NOME_PESSOA, "

	cQuery += "        COALESCE((SELECT COUNT(D1_DOC) "
	cQuery += "                  FROM " + RetSqlName("SD1")
	cQuery += "                  WHERE D1_DOC     = F1_DOC "
	cQuery += "                  AND   D1_SERIE   = F1_SERIE "
	cQuery += "                  AND   D1_FORNECE = F1_FORNECE "
	cQuery += "                  AND   D1_LOJA    = F1_LOJA "
	cQuery += "                  AND   D1_FILIAL = '" + xFilial("SD1") + "'"
	cQuery += "                  AND   D_E_L_E_T_ <> '*') "
	cQuery += "        , 0) AS QTDE_ITENS, "

	if mv_par06 <> 2
		cQuery += "    COALESCE((SELECT ZZK_NUM
		cQuery += "              FROM " + RetSqlName("ZZK") + " ZZK "
		cQuery += "              WHERE ZZK_FILIAL = '" + xFilial("ZZK") + "'"
		cQuery += "              AND   ZZK_DOC    = F1_DOC "
		cQuery += "              AND   ZZK_SERIE  = F1_SERIE "
		cQuery += "              AND   ZZK_EMISSA = F1_EMISSAO "
		cQuery += "              AND   ZZK_FORNEC = F1_FORNECE "
		cQuery += "              AND   ZZK.D_E_L_E_T_ <> '*') 
		cQuery += "    , '') AS ZZK_NUM, "
	Else
		cQuery += "    '' AS ZZK_NUM, "
	EndIf

	cQuery += "        F1_FORNECE, "
	cQuery += "        F1_LOJA, "
	cQuery += "        F1_DOC, "
	cQuery += "        F1_SERIE, "
	cQuery += "        F1_DTDIGIT, "
	cQuery += "        F1_EMISSAO "

	cQuery += " FROM " + RetSqlName("SF1")
	cQuery += " WHERE F1_DTDIGIT BETWEEN '" + Dtos(mv_par01) + "' AND '" + Dtos(mv_par02)+ "'"
	cQuery += " AND   F1_FILIAL = '" + xFilial('SF1') + "'"

	If AllTrim(mv_par03) <> ""
		cQuery += " AND EXISTS(SELECT TOP 1 D1_DOC "
		cQuery += "            FROM " + RetSqlName("SD1")
		cQuery += "            WHERE D1_DOC     = F1_DOC "
		cQuery += "            AND   D1_SERIE   = F1_SERIE "
		cQuery += "            AND   D1_FORNECE = F1_FORNECE "
		cQuery += "            AND   D1_LOJA    = F1_LOJA "
		cQuery += "            AND   D1_LOCAL   = '" + mv_par03 + "'"
		cQuery += "            AND   D1_FILIAL = '" + xFilial("SD1") + "'"
		cQuery += "            AND   D_E_L_E_T_ <> '*') "
	EndIf

	if AllTrim(mv_par04) <> ""
		cQuery += " AND F1_FORNECE = '" + mv_par04 + "'"
	EndIf

	If AllTrim(mv_par05) <> ""
		cQuery += " AND F1_LOJA = '" + mv_par05 + "'"
	EndIf

	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " AND F1_ESPECIE <> 'CTR' "
	cQuery += " AND F1_STATUS = '' "

	If mv_par07 == 1
		cQuery += " AND F1_TIPO = 'N' "
	Else
		cQuery += " AND F1_TIPO = 'D' "
	EndIf

	If mv_par06 <> 3

		if mv_par06 == 1
			cQuery += " AND EXISTS ( "
		ElseIf mv_par06 == 2
			cQuery += " AND NOT EXISTS ( "
		EndIf

		cQuery += "  (SELECT ZZK_NUM "
		cQuery += "   FROM " + RetSqlName("ZZK") + " ZZK "
		cQuery += "   WHERE ZZK_FILIAL = '" + xFilial("ZZK") + "'"
		cQuery += "   AND   ZZK_DOC    = F1_DOC "
		cQuery += "   AND   ZZK_SERIE  = F1_SERIE "
		cQuery += "   AND   ZZK_EMISSA = F1_EMISSAO "
		cQuery += "   AND   ZZK_FORNEC = F1_FORNECE "
		cQuery += "   AND   ZZK_LOJA   = F1_LOJA "
		cQuery += "   AND   ZZK.D_E_L_E_T_ <> '*')) "

	EndIf

	cQuery += " ORDER BY F1_EMISSAO, F1_FORNECE, F1_DOC "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SF1") <> 0
       dbSelectArea("QRY_SF1")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SF1"
	TCSetField("QRY_SF1", "F1_DTDIGIT", "D", 08, 0)
	TCSetField("QRY_SF1", "F1_EMISSAO", "D", 08, 0)

	dbSelectArea("QRY_SF1")
	dbGoTop()
	While !Eof()

		dbSelectArea("TRB")
		RecLock("TRB", .T.)

		REPLACE NOMEPESSOA	WITH QRY_SF1->NOME_PESSOA
		REPLACE FORNECE		WITH QRY_SF1->F1_FORNECE
		REPLACE LOJA		WITH QRY_SF1->F1_LOJA
		REPLACE DOC			WITH QRY_SF1->F1_DOC
		REPLACE SERIE		WITH QRY_SF1->F1_SERIE
		REPLACE DTDIGIT		WITH QRY_SF1->F1_DTDIGIT
		REPLACE EMISSAO		WITH QRY_SF1->F1_EMISSAO
		REPLACE QTDEITENS   WITH QRY_SF1->QTDE_ITENS
		REPLACE NUM_CONF    WITH QRY_SF1->ZZK_NUM

		MsUnLock()

		dbSelectArea("QRY_SF1")
		dbSkip()
	EndDo

	dbSelectArea("QRY_SF1")
	dbCloseArea()

	DbSelectArea("TRB")
	dbGoTop()
Return

Static Function CriarBrowse()

	AADD(aCamposArq,{"OK"			,"","Imprimir ?"		,"@!"  		})
	AADD(aCamposArq,{"NOMEPESSOA"	,"","Cliente/Fornecedor","@!"  		})
	AADD(aCamposArq,{"QTDEITENS"	,"","Quantidade Itens"	,"999999"	})
	AADD(aCamposArq,{"FORNECE"		,"","Codigo Cli/For"	,"@!"		})
	AADD(aCamposArq,{"LOJA"			,"","Loja Cli/For"		,"@!"		})
	AADD(aCamposArq,{"DOC"			,"","Nr Nota"			,"@!"		})
	AADD(aCamposArq,{"SERIE"		,"","SÈrie Nota"		,"@!"		})
	AADD(aCamposArq,{"DTDIGIT"		,"","Dt DigitaÁ„o"		,"@!"  		})
	AADD(aCamposArq,{"EMISSAO"		,"","Dt Emiss„o"		,"@!"  		})
	AADD(aCamposArq,{"NUM_CONF"		,"","Nr Conferencia"	,"@!"		})

	MarkBrow("TRB","OK","",aCamposArq,, cMarca)

Return

User Function AGX497Param()

	if CriarPerguntas()
		CriaArqTrab()
		CarregarDadosBrowse()
	EndIf

Return

Static Function CriaArqTrab()

	aCampos := {}

	aTam:=TamSX3("A1_NOME")
	AADD(aCampos,{"NOMEPESSOA" ,"C",aTam[1],aTam[2] } )

	AADD(aCampos,{"QTDEITENS"  ,"N",15     ,0       } )

	aTam:=TamSX3("F1_FORNECE")
	AADD(aCampos,{"FORNECE"    ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_LOJA")
	AADD(aCampos,{"LOJA"       ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_DOC")
	AADD(aCampos,{"DOC"        ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_SERIE")
	AADD(aCampos,{"SERIE"      ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_DTDIGIT")
	AADD(aCampos,{"DTDIGIT"    ,"D",aTam[1],aTam[2] } )

	aTam:=TamSX3("F1_EMISSAO")
	AADD(aCampos,{"EMISSAO"    ,"D",aTam[1],aTam[2] } )

	aTam:=TamSX3("ZZK_NUM")
	AADD(aCampos,{"NUM_CONF"   ,"C",aTam[1],aTam[2] } )

	AADD(aCampos,{ "OK"        ,"C",2      ,0       } )

    If Select("TRB") <> 0
       dbSelectArea("TRB")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"TRB",.T.,.F.)

	IndRegua("TRB", cArqTrab, "DOC+SERIE",,,"Indexando registros..." )

Return

User Function AGX497GeraConf()

	Local cNumConf  := "" 
	Local aConferen := {} 

	if ValidarConf()
		cNumConf := GravarZZI()
		GravarZZK(cNumConf)
		GravarZZJ(cNumConf)

		EnvEmail(cNumConf)
		MsgInfo("ConferÍncia gerada com sucesso! Nr: " + cNumConf)
                          
		AADD(aConferen,cNumConf)

		U_AGX499(aConferen/*cNumConf*/)
		aConferen := {}
		CriaArqTrab()
		CarregarDadosBrowse()
	EndIf

Return

Static Function ValidarConf()

	Private lGravOK := .T.
	Private lPossuiItem := .F.
	Private cFornece := ""
	Private cQuery := ""

	dbSelectArea("TRB")
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)

        	lPossuiItem := .T.

			if cFornece == ""
				cFornece := TRB->FORNECE
			Else
				if cFornece <> TRB->FORNECE
					lGravOK := .F.
				EndIf
			EndIf

			cQuery := ""
			cQuery += "    SELECT ZZK_NUM "
			cQuery += "    FROM " + RetSqlName("ZZK") + " ZZK "
			cQuery += "    WHERE ZZK_FILIAL = '" + xFilial("ZZK") + "'"
			cQuery += "    AND   ZZK_DOC    = '" + TRB->DOC + "'"
			cQuery += "    AND   ZZK_SERIE  = '" + TRB->SERIE + "'"
			cQuery += "    AND   ZZK_EMISSA = '" + DtoS(TRB->EMISSAO) + "'"
			cQuery += "    AND   ZZK_FORNEC = '" + TRB->FORNECE + "'"  
            cQuery += "    AND   ZZK_LOJA   = '" + TRB->LOJA + "'"			
			cQuery += "    AND   D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery(cQuery)

		    If Select("TMP_497") <> 0
		       dbSelectArea("TMP_497")
		   	   dbCloseArea()
		    Endif

			TCQuery cQuery NEW ALIAS "TMP_497"

			If AllTrim(TMP_497->ZZK_NUM) <> ""
				Alert("Nota fiscal " + TRB->DOC + " j· possui conferÍncia cega gerada! N˙mero: " + TMP_497->ZZK_NUM)
				Return .F.
			EndIf

		Endif

		DbSelectArea("TRB")
		DbSkip()
	EndDo

    If Select("TMP_497") <> 0
       dbSelectArea("TMP_497")
   	   dbCloseArea()
    Endif

	if !lPossuiItem
			Alert("Nenhum item selecionado!")
			lGravOK := .F.
	Else
		if !lGravOK
			Alert("N„o È possÌvel gerar conferÍncias a partir de notas de diferentes fornecedores!")
		EndIf
	EndIf

Return lGravOK

Static Function GravarZZI()

	Private cNumConf := ""
	
	cNumConf := GetSXENum("ZZI","ZZI_NUM") // GETSXENUM("SC5","C5_NUM")                                                                                                       
	ConfirmSX8()	

	dbSelectArea("TRB")
	dbGoTop()
	Do While !Eof()
		
		If IsMark("OK", cMarca)

			dbSelectArea("ZZI")
			RecLock("ZZI", .T.)
			REPLACE ZZI_FILIAL   WITH cFilial
			REPLACE ZZI_NUM      WITH cNumConf
			REPLACE ZZI_FORNEC   WITH TRB->FORNECE
			REPLACE ZZI_LOJA     WITH TRB->LOJA
			REPLACE ZZI_EMISSA   WITH dDataBase
			REPLACE ZZI_TIPO     WITH If(mv_par07 == 1, 'N', 'D')
			REPLACE ZZI_STATUS   WITH "A"
			MsUnLock()

			Return cNumConf
		
		Else
			dbSelectArea("TRB")
			dbSkip()
		Endif
	EndDo

Return cNumConf

Static Function GravarZZJ(cNumConf)

	Local nSequencia := 0
    cQuery := ""

    cQuery += " SELECT D1_COD, "
    cQuery += "        D1_UM, "
    cQuery += "        SUM(D1_QUANT) AS QTDE "

    cQuery += " FROM " + RetSQLName("SD1") + " SD1 (NOLOCK), " + RetSQLName("ZZK") + " ZZK (NOLOCK) "

    cQuery += " WHERE D1_DOC     = ZZK_DOC "
    cQuery += " AND   D1_SERIE   = ZZK_SERIE "
    cQuery += " AND   D1_FORNECE = ZZK_FORNEC "
    cQuery += " AND   D1_LOJA    = ZZK_LOJA "
    cQuery += " AND   D1_EMISSAO = ZZK_EMISSA "
    cQuery += " AND   D1_FILIAL  = ZZK_FILIAL "	
    cQuery += " AND   ZZK_FILIAL = '" + xFilial("ZZK") + "' "
    cQuery += " AND   ZZK.D_E_L_E_T_ <> '*' "
    cQuery += " AND   SD1.D_E_L_E_T_ <> '*' "

    cQuery += " AND   ZZK_NUM = '" + cNumConf + "'"

    cQuery += " GROUP BY D1_COD, D1_UM "
    cQuery += " ORDER BY D1_COD "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_ZZJ") <> 0
       dbSelectArea("QRY_ZZJ")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZJ"

	dbSelectArea("QRY_ZZJ")
	dbGoTop()
	While !Eof()

		nSequencia += 1

		dbSelectArea("ZZJ")
		RecLock("ZZJ", .T.)
			
		REPLACE ZZJ_FILIAL   WITH cFilial
		REPLACE ZZJ_NUM      WITH cNumConf
		REPLACE ZZJ_PRODUT   WITH QRY_ZZJ->D1_COD
		REPLACE ZZJ_UM       WITH QRY_ZZJ->D1_UM
		REPLACE ZZJ_QTDENF   WITH QRY_ZZJ->QTDE
		REPLACE ZZJ_QTDECF   WITH 0
		REPLACE ZZJ_SEQUEN   WITH Replicate("0", 3 - Len(AllTrim(Str(nSequencia)))) + AllTrim(Str(nSequencia))

		MsUnLock()

		dbSelectArea("QRY_ZZJ")
		dbSkip()
	End

Return cNumConf

Static Function GravarZZK(cNumConf)

	dbSelectArea("TRB")
	dbGoTop()
	Do While !Eof()

		If IsMark("OK", cMarca)

			dbSelectArea("ZZK")
			RecLock("ZZK", .T.)

			REPLACE ZZK_FILIAL   WITH cFilial
			REPLACE ZZK_NUM      WITH cNumConf
			REPLACE ZZK_DOC      WITH TRB->DOC
			REPLACE ZZK_SERIE    WITH TRB->SERIE
			REPLACE ZZK_EMISSA   WITH TRB->EMISSAO
			REPLACE ZZK_FORNEC   WITH TRB->FORNECE
			REPLACE ZZK_LOJA     WITH TRB->LOJA

			MsUnLock()
		Endif

		dbSelectArea("TRB")
		dbSkip()
	EndDo

Return

Static Function EnvEmail(cNumConf)

	Local nTotal := 0
	Local _x     := 0
	Local cDest  := ""
	Local cBCC   := ""
	Local lEnvTeste := .F.

	oProcess := TWFProcess():New( "EMAILCONF", "GeraÁ„o de ConferÍncia Cega" )
	oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\GERACAO_CONFCEGA.HTM" )

	lEnvTeste := GetEnvServer() == "envteste2"

	If lEnvTeste
		oProcess:cSubject := "[AMBIENTE TESTE] [GERA«√O] ConferÍncia Cega Nr.: " + cFilAnt + "-" + cNumConf
	Else
		oProcess:cSubject := "[GERA«√O] ConferÍncia Cega Nr.: " + cFilAnt + "-" + cNumConf
	EndIf

	oHtml := oProcess:oHTML

	CarEmail(cNumConf)

	oHtml:ValByName("nrconf", cFilAnt + "-" + cNumConf )
	oHtml:ValByName("emissao", QRY_EMAIL->ZZI_EMISSA )
	oHtml:ValByName("fornecedor", QRY_EMAIL->ZZI_FORNEC + " - " + QRY_EMAIL->NOME_PESSOA )

	If AllTrim(QRY_EMAIL->B1_LOCPAD) == "02" .Or. AllTrim(QRY_EMAIL->B1_LOCPAD) == "91"
		U_DestEmail(oProcess, "GERACAO_CONFCEGA_CONV")
	Else
		If AllTrim(QRY_EMAIL->B1_LOCPAD) == "01"
			U_DestEmail(oProcess, "GERACAO_CONFCEGA_LUB")
		EndIf
	EndIf

	While QRY_EMAIL->(!Eof())

		aAdd( (oHtml:ValByName( "produto.nrnota" )),     QRY_EMAIL->D1_DOC + " - " + QRY_EMAIL->D1_SERIE)
		aAdd( (oHtml:ValByName( "produto.coddesc" )),    QRY_EMAIL->D1_COD + " - " + QRY_EMAIL->B1_DESC)
		aAdd( (oHtml:ValByName( "produto.embalagem" )),  QRY_EMAIL->D1_UM)

		QRY_EMAIL->(dbSkip())

	End

	U_DestEmail(oProcess, "GERACAO_CONFCEGA")

	oProcess:Start()
	oProcess:Finish()

	If Select("QRY_EMAIL") <> 0
		dbSelectArea("QRY_EMAIL")
		dbCloseArea()
	Endif

Return

Static Function CarEmail(cNumConf)

	cQuery := ""

	cQuery += " SELECT D1_DOC, "
	cQuery += "        D1_SERIE, "
	cQuery += " 	   D1_COD, "
	cQuery += " 	   B1_DESC, "
	cQuery += " 	   B1_LOCPAD, "
	cQuery += " 	   D1_UM, "

    cQuery += "        ZZI_NUM, "
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

	cQuery += " FROM SB1010 SB1, SD1010 SD1, ZZK010 ZZK, ZZI010 ZZI "

	cQuery += " WHERE ZZK_NUM     = '" + cNumConf + "'"
	cQuery += " AND   ZZK_FILIAL  = '" + xFilial("ZZK") + "'"

	cQuery += " AND   ZZK_DOC     = D1_DOC "
	cQuery += " AND   ZZK_SERIE   = D1_SERIE "
	cQuery += " AND   ZZK_FORNEC  = D1_FORNECE "
	cQuery += " AND   ZZK_LOJA    = D1_LOJA "
	cQuery += " AND   ZZK_FILIAL  = D1_FILIAL "

    cQuery += " AND   ZZI_NUM     = ZZK_NUM "
    cQuery += " AND   ZZI_FILIAL  = '" + xFilial("ZZI") + "'"

	cQuery += " AND   B1_COD      = D1_COD "
	cQuery += " AND   B1_FILIAL   = D1_FILIAL "

	cQuery += " AND   SB1.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SD1.D_E_L_E_T_ <> '*' "
	cQuery += " AND   ZZK.D_E_L_E_T_ <> '*' "
	cQuery += " AND   ZZI.D_E_L_E_T_ <> '*' "

	cQuery += " ORDER BY D1_DOC, D1_ITEM "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_EMAIL") <> 0
       dbSelectArea("QRY_EMAIL")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_EMAIL"
	TCSetField("QRY_EMAIL", "D1_DTVALID", "D", 08, 0)

Return