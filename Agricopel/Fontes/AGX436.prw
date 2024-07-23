#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  AGX436    �Autor  � Leandro           � Data �  28/04/2011   ���
�������������������������������������������������������������������������͹��
���Desc.     � Impress�o de Mapa de Reabastecimento                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGX436()

	Private	cCadastro  := "Impress�o de Mapa de Reabastecimento"
	Private	cMarca     := GetMark()
	Private bFiltraBrw := {|| Nil }
	Private aCamposArq := {}

	Private	aRotina    := {{ "Imprimir Mapa", "U_AGX436ImpMapa()",    0, 1},;
	                       { "Par�metros"   , "U_AGX436Parametros()", 0, 2},;
	                       { "Legenda"      , "U_AGX436Legenda()",    0, 3}}

	Private aCores     := {}

	Private oTmpTable := Nil
	Private cAliasTRB := ""

	If !CriarPerg()
		Return
	EndIf

	MsgRun("Carregando dados","Processando...",{|| CriarTRB() })
	MsgRun("Carregando dados","Processando...",{|| DadosTRB() })

	AADD(aCamposArq,{"OK"			,"","Imprimir ?"		,"@!"		})
	AADD(aCamposArq,{"DB_DOC"		,"","N�mero"			,"@!"		})
	AADD(aCamposArq,{"B1_COD"		,"","C�d Produto"		,"@!"		})
	AADD(aCamposArq,{"B1_DESC"		,"","Descri��o Produto"	,"@!"		})
	AADD(aCamposArq,{"DB_LOCALIZ"	,"","End. Origem"		,"@!"		})
	AADD(aCamposArq,{"DB_ENDDES"	,"","End. Destino"		,"@!"		})
	AADD(aCamposArq,{"DB_QUANT"		,"","Quantidade"		,"99999.99"	})

	DbSelectArea(cAliasTRB)
	DBGoTop()

	AADD(aCores,{cAliasTRB + "->DB_IMPMAP <> 'S'" ,'BR_VERDE' })
	AADD(aCores,{cAliasTRB + "->DB_IMPMAP == 'S'" ,'BR_VERMELHO' })

	MarkBrowse(cAliasTRB,"OK","",aCamposArq,, cMarca,,,,,,,,,aCores)

	(cAliasTRB)->(DbCloseArea())
	oTmpTable:Delete()
	FreeObj(oTmpTable)

Return ()

Static Function CriarPerg()

	cPerg := "AGX436"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Servico De        ?","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","L4"})
	AADD(aRegistros,{cPerg,"02","Servico Ate       ?","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","L4"})
	AADD(aRegistros,{cPerg,"03","Tarefa De         ?","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","L2"})
	AADD(aRegistros,{cPerg,"04","Tarefa Ate        ?","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","L2"})
	AADD(aRegistros,{cPerg,"05","Atividade De      ?","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","L3"})
	AADD(aRegistros,{cPerg,"06","Atividade Ate     ?","mv_ch6","C",03,0,0,"G","","mv_par06","","","","","","","","","","","","","","","L3"})
	AADD(aRegistros,{cPerg,"07","Documento De      ?","mv_ch7","C",TamSX3("DB_DOC")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Documento Ate     ?","mv_ch8","C",TamSX3("DB_DOC")[1],0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Serie De          ?","mv_ch9","C",03,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Serie Ate         ?","mv_chA","C",03,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"11","Data De           ?","mv_chB","D",08,0,0,"C","","mv_par11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Data Ate          ?","mv_chC","D",08,0,0,"C","","mv_par12","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"13","Quantidade        ?","mv_chD","N",01,0,0,"C","","mv_par13","1a.UM","","","2a.UM","","","U.M.I.","","","N�o Imprime","","","","",""})
	AADD(aRegistros,{cPerg,"14","Tipo de Documento ?","mv_chE","N",01,0,0,"C","","mv_par14","Doc/Ser WMS","","","oc/Ser Ori. CQ","","","Carga/Unitiz.","","","","","","","",""})
	AADD(aRegistros,{cPerg,"15","Mostrar Impressos ?","mv_chF","N",01,0,0,"C","","mv_par15","Sim","","","N�o","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"16","Executor Servi�o  ?","mv_chG","C",04,0,0,"G","","mv_par16","","","","","","","","","","","","","","","ZZA"})
	AADD(aRegistros,{cPerg,"17","Armazem           ?","mv_chH","C",02,0,0,"G","","mv_par17","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	if Pergunte(cPerg, .T.)
		Return LocalizarExecutor()
	Else
		Return .F.
	EndIf

Return()

Static Function CriarTRB()

	Local aCampos   := {}
	Local aTam      := {}

	aTam:=TamSX3("DB_DOC")
	AADD(aCampos,{ "DB_DOC"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("B1_COD")
	AADD(aCampos,{ "B1_COD"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("B1_DESC")
	AADD(aCampos,{ "B1_DESC"    ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("DB_LOCALIZ")
	AADD(aCampos,{ "DB_LOCALIZ" ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("DB_ENDDES")
	AADD(aCampos,{ "DB_ENDDES"  ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("DB_QUANT")
	AADD(aCampos,{ "DB_QUANT"   ,"N",aTam[1],aTam[2] } )

	aTam:=TamSX3("DB_IMPMAP")
	AADD(aCampos,{ "DB_IMPMAP"  ,"C",aTam[1],aTam[2] } )

	AADD(aCampos,{ "OK"  		,"C",2		,0 		 } )

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {"DB_DOC", "B1_COD", "DB_LOCALIZ"})
	oTmpTable:Create()

	cAliasTRB := oTmpTable:GetAlias()

Return()

Static Function LimparTRB()

	Local cQuery := ""

	cQuery := " DELETE FROM " + oTmpTable:GetRealName()

	If TCSqlExec(cQuery) < 0
		Alert(TCSqlError(), "Falha ao carregar dados")
	EndIf

	(cAliasTRB)->(DBGoTop())

Return()

Static Function DadosTRB()

	Local cQuery := ""

	LimparTRB()

	cQuery += "  SELECT DB_DOC,		  "
	cQuery += "			DB_IMPMAP,    "
	cQuery += "         DB_LOCALIZ,   "
	cQuery += "         DB_ENDDES,    "
	cQuery += "         DB_QUANT,     "
	cQuery += "         B1_COD,       "
	cQuery += "         B1_DESC       "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "

	cQuery += "  WHERE SDB.DB_SERVIC BETWEEN '" + mv_par01 		 + "' AND '" + mv_par02 + "'"
	cQuery += "  AND   SDB.DB_TAREFA BETWEEN '" + mv_par03 		 + "' AND '" + mv_par04 + "'"
	cQuery += "  AND   SDB.DB_ATIVID BETWEEN '" + mv_par05 		 + "' AND '" + mv_par06 + "'"
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par07 		 + "' AND '" + mv_par08 + "'"
	cQuery += "  AND   SDB.DB_SERIE  BETWEEN '" + mv_par09 		 + "' AND '" + mv_par10 + "'"
	cQuery += "  AND   SDB.DB_DATA   BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"

	cQuery += "  AND   SDB.DB_LOCAL = '" + mv_par17 + "'"

	cQuery += "  AND   SB1.B1_COD = SDB.DB_PRODUTO "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ = '' "

	cQuery += "  AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "  AND   SB1.D_E_L_E_T_ = '' "

	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "
	cQuery += "  AND   SDB.DB_ATUEST  = 'N' "

	if mv_par15 == 2
		cQuery += " AND SDB.DB_IMPMAP <> 'S' "
	endif

	cQuery += " ORDER BY DB_DATA, DB_DOC "

	If Select("QRY_SDB") <> 0
		dbSelectArea("QRY_SDB")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"
	TCSetField("QRY_SDB", "DB_DATA", "D", 08, 0)

	dbSelectArea("QRY_SDB")
	While !Eof()

		dbSelectArea(cAliasTRB)
		RecLock(cAliasTRB,.T.)

		REPLACE DB_DOC		WITH	QRY_SDB->DB_DOC
		REPLACE DB_IMPMAP	WITH	QRY_SDB->DB_IMPMAP
		REPLACE DB_LOCALIZ	WITH	QRY_SDB->DB_LOCALIZ
		REPLACE DB_ENDDES	WITH	QRY_SDB->DB_ENDDES
		REPLACE DB_QUANT	WITH	QRY_SDB->DB_QUANT
		REPLACE B1_COD		WITH	QRY_SDB->B1_COD
		REPLACE B1_DESC		WITH	QRY_SDB->B1_DESC

		MsUnLock()

		DBSelectArea("QRY_SDB")
		Skip()
	Enddo

	dbSelectArea("QRY_SDB")
	dbCloseArea()

Return(.T.)

User Function AGX436Legenda()

	BrwLegenda(cCadastro,"Legenda", {{'BR_VERDE', "N�o Impresso" }, {'BR_VERMELHO', "Impresso"}})

Return(.T.)

User Function AGX436ImpMapa()

	cPedidos := ""

	dbSelectArea(cAliasTRB)
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)

			if cPedidos <> ""
				cPedidos += " .Or. "
			Endif

			cPedidos += " DB_DOC == '" + (cAliasTRB)->DB_DOC + "'"
		Endif

		DbSelectArea(cAliasTRB)
		(cAliasTRB)->(DbSkip())
	EndDo

	dbSelectArea(cAliasTRB)
	dbGoTop()

	if cPedidos <> ""

		cPedidos := " (" + cPedidos + ")"

		U_AGX449(cPedidos)
		SetarImpressos()
	Else
		ALERT("Nenhum item selecionado!")
	Endif

Return(nil)

Static Function SetarImpressos()

	cPedidos := ""

	dbSelectArea(cAliasTRB)
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)

			if cPedidos <> ""
				cPedidos += ","
			Endif

			cPedidos += "'" + (cAliasTRB)->DB_DOC + "'"
		Endif

		DbSelectArea(cAliasTRB)
		(cAliasTRB)->(DbSkip())
	EndDo

	if cPedidos <> ""

		cQuery := ""
		cQuery += "  UPDATE " + RetSqlName("SDB") + " SET"
		cQuery += "			DB_IMPMAP = 'S',    "
		cQuery += "			DB_CDEXEC = '" + mv_par16 + "'"

		cQuery += "  WHERE DB_SERVIC BETWEEN '" + mv_par01       + "' AND '" + mv_par02 + "'"
		cQuery += "  AND   DB_TAREFA BETWEEN '" + mv_par03       + "' AND '" + mv_par04 + "'"
		cQuery += "  AND   DB_ATIVID BETWEEN '" + mv_par05       + "' AND '" + mv_par06 + "'"
		cQuery += "  AND   DB_SERIE  BETWEEN '" + mv_par09 		 + "' AND '" + mv_par10 + "'"
		cQuery += "  AND   DB_DATA   BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"

		cQuery += "  AND   DB_DOC IN (" + cPedidos + ")"

		cQuery += "  AND   DB_FILIAL = '" + xFilial("SDB") + "'"
		cQuery += "  AND   D_E_L_E_T_ = '' "

		cQuery += "  AND   DB_ESTORNO = ' ' "
		cQuery += "  AND   DB_ATUEST  = 'N' "
		cQuery += "  AND   DB_IMPMAP <> 'S' "

		If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		Else
			MsgRun("Carregando dados","Processando...",{|| DadosTRB() })
		EndIf
	endif

Return(nil)

User Function AGX436Parametros()

	if CriarPerg()
		MsgRun("Carregando dados","Processando...",{|| DadosTRB() })
	EndIf

Return(nil)

Static Function LocalizarExecutor()

	cQuery := ""
	cQuery += "     SELECT ZZA_NOME "
	cQuery += "     FROM " + RetSqlName("ZZA") + " (NOLOCK) "
	cQuery += "     WHERE ZZA_COD = '" + mv_par16 + "'"
	cQuery += "     AND   ZZA_FILIAL = '" + xFilial('ZZA') + "'"
	cQuery += "     AND   D_E_L_E_T_ = '' "

	If Select("QRY_ZZA") <> 0
		dbSelectArea("QRY_ZZA")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZA"

	if AllTrim(QRY_ZZA->ZZA_NOME) == ""
		Aviso("Aten��o","C�digo de executor informado inv�lido!",{"&OK"})
		Return .F.
	Else
		Return .T.
	EndIf

Return(nil)