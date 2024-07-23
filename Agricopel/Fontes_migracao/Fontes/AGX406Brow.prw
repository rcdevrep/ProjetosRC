#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  AGX460B    ºAutor  ³ Leandro             º Data ³  04/2011   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão de Mapa de Separação                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX460B(pcFiltro)

	Local   cRet 	   := ""
	Private	cCadastro  := "Pedido(s) para Mapa de Separação"
	Private	cMarca     := GetMark()
	Private bFiltraBrw := {|| Nil }
	Private aCamposArq := {}

	Private	aRotina    := {{ "Imprimir Mapa"		, "U_ImpMapa_AGX406Brow()" 	, 0, 1},;
					       { "Imprimir Identif."	, "U_ImpIdent_AGX406Brow()"	, 0, 2},;
						   { "Legenda"				, "U_Legenda_AGX406Brow()" 	, 0, 3}}

	If !Criar_Perg(.T.)
		Return
	EndIf

	CriarArqTrab()

	if mv_par11 == 1
		Car_Pedido()
	Else
		Car_Carga()
	EndIf

	AADD(aCamposArq,{"OK"			,"","Imprimir ?"		                   ,"@!" 	 })
	AADD(aCamposArq,{"DB_DOC"		,"",If(mv_par11 == 1, "Pedido", "Carga")   ,"@!"     })
	AADD(aCamposArq,{"A1_NOME"		,"","Cliente"			                   ,"@!"	 })
	AADD(aCamposArq,{"QTDE_PROD"	,"","Qtde. Produtos"	                   ,"999999" })
	AADD(aCamposArq,{"DB_DATA"		,"","Data"				                   ,"@!" 	 })

	DbSelectArea("ARQ_TRAB_TEMP")
	dbgotop()

	MarkBrowse("ARQ_TRAB_TEMP","OK","ARQ_TRAB_TEMP->DB_IMPMAP",aCamposArq,, cMarca)

Return()

Static Function Criar_Perg()

	cPerg := "AGX406B"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Servico De        ?","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","L4"})
	AADD(aRegistros,{cPerg,"02","Servico Ate       ?","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","L4"})
	AADD(aRegistros,{cPerg,"03","Tarefa De         ?","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","L2"})
	AADD(aRegistros,{cPerg,"04","Tarefa Ate        ?","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","L2"})
	AADD(aRegistros,{cPerg,"05","Atividade De      ?","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","L3"})
	AADD(aRegistros,{cPerg,"06","Atividade Ate     ?","mv_ch6","C",03,0,0,"G","","mv_par06","","","","","","","","","","","","","","","L3"})
	AADD(aRegistros,{cPerg,"07","Pedido De         ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Pedido Ate        ?","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Carga De          ?","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Carga Ate         ?","mv_chA","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"11","Tipo de Separacao ?","mv_chB","N",01,0,0,"C","","mv_par11","Pedido","","","Carga","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Imprimir Lote     ?","mv_chC","N",01,0,0,"C","","mv_par12","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"13","Imprimir U.M.I.   ?","mv_chD","N",01,0,0,"C","","mv_par13","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"14","Quebra por Estrut ?","mv_chE","N",01,0,0,"C","","mv_par14","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"15","Oculta Quantidades?","mv_chF","N",02,0,0,"C","","mv_par15","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"16","Mostrar Impressos ?","mv_chG","N",01,0,0,"C","","mv_par16","Sim","","","Não","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	Return Pergunte(cPerg, .T.)

Return()

Static Function CriarArqTrab()

	aCampos := {}

	aTam:=TamSX3("DB_DOC")
	AADD(aCampos,{ "DB_DOC"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("A1_COD")
	AADD(aCampos,{"A1_COD"      ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("A1_NOME")
	AADD(aCampos,{"A1_NOME"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("DB_DATA")
	AADD(aCampos,{ "DB_DATA"    ,"D",aTam[1],aTam[2] } )

	aTam:=TamSX3("DB_IMPMAP")
	AADD(aCampos,{ "DB_IMPMAP"  ,"C",aTam[1],aTam[2] } )

	AADD(aCampos,{ "QTDE_PROD"  ,"N",10		,0		 } )
	AADD(aCampos,{ "OK"  		,"C",2		,0 		 } )

    If Select("ARQ_TRAB_TEMP") <> 0
       dbSelectArea("ARQ_TRAB_TEMP")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"ARQ_TRAB_TEMP",.T.,.F.)

Return()

Static Function Car_Pedido()

	cQuery := ""
	cQuery += "  SELECT COUNT(SDB.R_E_C_N_O_) AS QTDE_PROD, "
	cQuery += "  		DB_DOC,		  "
	cQuery += "			DB_DATA,      "
	cQuery += "			DB_IMPMAP,    "
	cQuery += "			A1_COD,       "
	cQuery += "			A1_NOME       "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB, " + RetSqlName("SC5") + " SC5, " + RetSqlName("SA1") + " SA1 "

//	cQuery += "  WHERE SDB.DB_SERVIC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += "  WHERE SDB.DB_TAREFA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	cQuery += "  AND   SDB.DB_ATIVID BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
	cQuery += "  AND   SDB.DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"

	cQuery += "  AND RTRIM(SDB.DB_DOC) <> '' "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SC5.C5_NUM = SDB.DB_DOC "
	cQuery += "  AND   SC5.C5_FILIAL = '" + xFilial("SC5") + "'"
	cQuery += "  AND   SC5.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SA1.A1_COD   = SC5.C5_CLIENTE "
	cQuery += "  AND   SA1.A1_LOJA  = SC5.C5_LOJACLI "
	cQuery += "  AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += "  AND   SA1.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_SERVIC  = '001' "
	cQuery += "  AND   SDB.DB_TM      > '500' "
	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "
	cQuery += "  AND   SDB.DB_ATUEST  = 'N' "

	if mv_par16 == 2
		cQuery += " AND SDB.DB_IMPMAP <> 'S' "
	endif

	cQuery += " GROUP BY DB_DOC, DB_DATA, DB_IMPMAP, A1_COD, A1_NOME "
	cQuery += " ORDER BY DB_DOC "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SDB") <> 0
       dbSelectArea("QRY_SDB")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"
	TCSetField("QRY_SDB", "DB_DATA", "D", 08, 0)

	dbSelectArea("QRY_SDB")
	dbGoTop()
	While !Eof()

		dbSelectArea("ARQ_TRAB_TEMP")
		RecLock("ARQ_TRAB_TEMP",.T.)

		REPLACE QTDE_PROD	WITH	QRY_SDB->QTDE_PROD
		REPLACE DB_DOC		WITH	QRY_SDB->DB_DOC
		REPLACE DB_DATA		WITH	QRY_SDB->DB_DATA
		REPLACE DB_IMPMAP	WITH	QRY_SDB->DB_IMPMAP
		REPLACE A1_COD		WITH	QRY_SDB->A1_COD
		REPLACE A1_NOME		WITH	QRY_SDB->A1_NOME

		MsUnLock()

        dbSelectArea("QRY_SDB")
       	DbSkip()
	Enddo

	dbSelectArea("QRY_SDB")
	dbCloseArea()

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()

Return(.T.)

Static Function Car_Carga()

	cQuery := ""
	cQuery += "  SELECT COUNT(SDB.R_E_C_N_O_) AS QTDE_PROD, "
	cQuery += "  		DB_CARGA,	  "
	cQuery += "			DB_DATA,      "
	cQuery += "			DB_IMPMAP     "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB "

//	cQuery += "  WHERE SDB.DB_SERVIC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += "  WHERE SDB.DB_TAREFA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	cQuery += "  AND   SDB.DB_ATIVID BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
	cQuery += "  AND   SDB.DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"

	cQuery += "  AND RTRIM(SDB.DB_CARGA) <> '' "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_SERVIC  = '001' "
	cQuery += "  AND   SDB.DB_TM      > '500' "
	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "
//	cQuery += "  AND   SDB.DB_ATUEST  = 'N' "

	if mv_par16 == 2
		cQuery += " AND SDB.DB_IMPMAP <> 'S' "
	endif

	cQuery += " GROUP BY DB_CARGA, DB_DATA, DB_IMPMAP "
	cQuery += " ORDER BY DB_CARGA "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SDB") <> 0
       dbSelectArea("QRY_SDB")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"
	TCSetField("QRY_SDB", "DB_DATA", "D", 08, 0)

	dbSelectArea("QRY_SDB")
	dbGoTop()
	While !Eof()

		dbSelectArea("ARQ_TRAB_TEMP")
		RecLock("ARQ_TRAB_TEMP",.T.)

		REPLACE QTDE_PROD	WITH	QRY_SDB->QTDE_PROD
		REPLACE DB_DOC		WITH	QRY_SDB->DB_CARGA
		REPLACE DB_DATA		WITH	QRY_SDB->DB_DATA
		REPLACE DB_IMPMAP	WITH	QRY_SDB->DB_IMPMAP
		REPLACE A1_COD		WITH	""
		REPLACE A1_NOME		WITH	""

		MsUnLock()

        dbSelectArea("QRY_SDB")
       	skip()
	Enddo

	dbSelectArea("QRY_SDB")
	dbCloseArea()

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()

Return(.T.)

User Function Legenda_AGX406Brow()

	BrwLegenda(cCadastro,"Legenda", {{'BR_VERDE', "Não Impresso" }, {'BR_VERMELHO', "Impresso"}})

Return(.T.)

User Function ImpIdent_AGX406Brow()

	If mv_par11 == 1
		ImpIdentP()
	Else
		ImpIdentC()
	EndIf

Return(nil)

User Function ImpMapa_AGX406Brow()

	If mv_par11 == 1
		ImpMapaP()
	Else
		ImpMapaC()
	EndIf

Return(nil)

Static Function SetImpPed()

	Local cPedidos := ""

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)

			if cPedidos <> ""
				cPedidos += ","
			Endif

			cPedidos += "'" + ARQ_TRAB_TEMP->DB_DOC + "'"
		Endif

		DbSelectArea("ARQ_TRAB_TEMP")
		ARQ_TRAB_TEMP->(DbSkip())
	EndDo

	if cPedidos <> ""

	    cQuery := ""
		cQuery += "  UPDATE " + RetSqlName("SDB") + " SET"
		cQuery += "			DB_IMPMAP = 'S'    "

		cQuery += "  WHERE DB_SERVIC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
		cQuery += "  AND   DB_TAREFA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		cQuery += "  AND   DB_ATIVID BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"

		cQuery += "  AND   DB_DOC IN (" + cPedidos + ")"

		cQuery += "  AND   DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"

		cQuery += "  AND   DB_FILIAL = '" + xFilial("SDB") + "'"
		cQuery += "  AND   D_E_L_E_T_ <> '*' "

		cQuery += "  AND   DB_SERVIC  = '001' "
		cQuery += "  AND   DB_TM      > '500' "
		cQuery += "  AND   DB_ESTORNO = ' ' "
		cQuery += "  AND   DB_ATUEST  = 'N' "
		cQuery += "  AND   DB_IMPMAP <> 'S' "

 	    If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		Else
			CriarArqTrab()
			Car_Pedido()
        EndIf 	        	    
	endif  

Return(nil)

Static Function ImpMapaP()

	Local cPedidos := ""

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)

/*			if cPedidos <> ""
				cPedidos += " .Or. "
			Endif    */

//			cPedidos += If(mv_par11 == 1, " DB_DOC == '", " DB_CARGA == '") + ARQ_TRAB_TEMP->DB_DOC + "'"
			if cPedidos <> ""
				cPedidos += ","
			Endif

			cPedidos += "'" + ALLTRIM(ARQ_TRAB_TEMP->DB_DOC) + "'"

		Endif

		DbSelectArea("ARQ_TRAB_TEMP")
		ARQ_TRAB_TEMP->(DbSkip())
	EndDo

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()

	if cPedidos <> ""
		//cPedidos := " .And. (" + cPedidos + ")"
		U_AGX406(cPedidos)

		SetImpPed()
	Else
		ALERT("Nenhum item selecionado!")
	Endif

Return

Static Function ImpMapaC()

	Local aCargas := {}

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)
            AADD(aCargas, ARQ_TRAB_TEMP->DB_DOC)
		Endif

		DbSelectArea("ARQ_TRAB_TEMP")
		ARQ_TRAB_TEMP->(DbSkip())
	EndDo

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()

	if Len(aCargas) > 0
		U_AGX514(aCargas)

		CriarArqTrab()
		Car_Carga()
	Else
		ALERT("Nenhum item selecionado!")
	Endif

Return

Static Function ImpIdentC()

	Local aCargas := {}

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()
	While !Eof()

		If IsMark("OK", cMarca)
			AADD(aCargas, ARQ_TRAB_TEMP->DB_DOC)
		Endif

		ARQ_TRAB_TEMP->(DbSkip())
	EndDo

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()

	if Len(aCargas) > 0
		U_AGX521(aCargas)
	Else
		ALERT("Nenhum item selecionado!")
	Endif

Return

Static Function ImpIdentP()

	Local cPedidos := ""

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)

			if cPedidos <> ""
				cPedidos += ","
			Endif

			cPedidos += "'" + ARQ_TRAB_TEMP->DB_DOC + "'"
		Endif

		DbSelectArea("ARQ_TRAB_TEMP")
		ARQ_TRAB_TEMP->(DbSkip())
	EndDo

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()

	if cPedidos <> ""
		U_AGX407(cPedidos)
	Else
		ALERT("Nenhum item selecionado!")
	Endif

Return