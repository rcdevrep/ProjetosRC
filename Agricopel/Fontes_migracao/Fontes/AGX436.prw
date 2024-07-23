#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  AGX436    ºAutor  ³ Leandro           º Data ³  28/04/2011   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão de Mapa de Reabastecimento                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX436()

	Local   cRet 	   := ""
	Private	cCadastro  := "Impressão de Mapa de Reabastecimento"
	Private	cMarca     := GetMark()
	Private bFiltraBrw := {|| Nil }
	Private aCamposArq := {}

	Private	aRotina    := {{ "Imprimir Mapa", "U_AGX436ImpMapa()",    0, 1},;
						   { "Parâmetros"   , "U_AGX436Parametros()", 0, 2},;
						   { "Legenda"      , "U_AGX436Legenda()",    0, 3}}  
						   
	Private aCores     := {}

	If !CriarPerg()
		Return
	EndIf

	CriarArqTrab()
	CarregarArqTrab()

	AADD(aCamposArq,{"OK"			,"","Imprimir ?"		,"@!"		})
	AADD(aCamposArq,{"DB_DOC"		,"","Número"			,"@!"		})
	AADD(aCamposArq,{"B1_COD"		,"","Cód Produto"		,"@!"		})
	AADD(aCamposArq,{"B1_DESC"		,"","Descrição Produto"	,"@!"		})
	AADD(aCamposArq,{"DB_LOCALIZ"	,"","End. Origem"		,"@!"		})
	AADD(aCamposArq,{"DB_ENDDES"	,"","End. Destino"		,"@!"		})
	AADD(aCamposArq,{"DB_QUANT"		,"","Quantidade"		,"99999.99"	})

	DbSelectArea("ARQ_TRAB_TEMP")
	DBGoTop()                     

	AADD(aCores,{"ARQ_TRAB_TEMP->DB_IMPMAP <> 'S'" ,'BR_VERDE' })     
    AADD(aCores,{"ARQ_TRAB_TEMP->DB_IMPMAP == 'S'" ,'BR_VERMELHO' })
	
	MarkBrowse("ARQ_TRAB_TEMP","OK"     ,""/*"ARQ_TRAB_TEMP->DB_IMPMAP"*/,aCamposArq,   , cMarca                  ,,,,,,,,,aCores)

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
	AADD(aRegistros,{cPerg,"13","Quantidade        ?","mv_chD","N",01,0,0,"C","","mv_par13","1a.UM","","","2a.UM","","","U.M.I.","","","Não Imprime","","","","",""})
	AADD(aRegistros,{cPerg,"14","Tipo de Documento ?","mv_chE","N",01,0,0,"C","","mv_par14","Doc/Ser WMS","","","oc/Ser Ori. CQ","","","Carga/Unitiz.","","","","","","","",""})
	AADD(aRegistros,{cPerg,"15","Mostrar Impressos ?","mv_chF","N",01,0,0,"C","","mv_par15","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"16","Executor Serviço  ?","mv_chG","C",04,0,0,"G","","mv_par16","","","","","","","","","","","","","","","ZZA"})
	AADD(aRegistros,{cPerg,"17","Armazem           ?","mv_chH","C",02,0,0,"G","","mv_par17","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	if Pergunte(cPerg, .T.)
		Return LocalizarExecutor()
	Else
		Return .F.
	EndIf

Return()

Static Function CriarArqTrab()

	aCampos := {}    

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

    If Select("ARQ_TRAB_TEMP") <> 0
       dbSelectArea("ARQ_TRAB_TEMP")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"ARQ_TRAB_TEMP",.T.,.F.)

Return()

Static Function CarregarArqTrab()

	cQuery := ""
	cQuery += "  SELECT DB_DOC,		  "
	cQuery += "			DB_IMPMAP,    "
	cQuery += "         DB_LOCALIZ,   "
	cQuery += "         DB_ENDDES,    "
	cQuery += "         DB_QUANT,     "
	cQuery += "         B1_COD,       "
	cQuery += "         B1_DESC       "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB, " + RetSqlName("SB1") + " SB1 "

	cQuery += "  WHERE SDB.DB_SERVIC BETWEEN '" + mv_par01 		 + "' AND '" + mv_par02 + "'"
	cQuery += "  AND   SDB.DB_TAREFA BETWEEN '" + mv_par03 		 + "' AND '" + mv_par04 + "'"
	cQuery += "  AND   SDB.DB_ATIVID BETWEEN '" + mv_par05 		 + "' AND '" + mv_par06 + "'"
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par07 		 + "' AND '" + mv_par08 + "'"
	cQuery += "  AND   SDB.DB_SERIE  BETWEEN '" + mv_par09 		 + "' AND '" + mv_par10 + "'"
	cQuery += "  AND   SDB.DB_DATA   BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"

	cQuery += "  AND   SDB.DB_LOCAL = '" + mv_par17 + "'"

	cQuery += "  AND   SB1.B1_COD = SDB.DB_PRODUTO "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "  AND   SB1.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "
	cQuery += "  AND   SDB.DB_ATUEST  = 'N' "

	if mv_par15 == 2
		cQuery += " AND SDB.DB_IMPMAP <> 'S' "
	endif

	cQuery += " ORDER BY DB_DATA, DB_DOC "

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

	BrwLegenda(cCadastro,"Legenda", {{'BR_VERDE', "Não Impresso" }, {'BR_VERMELHO', "Impresso"}})

Return(.T.)

User Function AGX436ImpMapa()

	cPedidos := ""  

	dbSelectArea("ARQ_TRAB_TEMP")
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)

			if cPedidos <> ""
				cPedidos += " .Or. "
			Endif

			cPedidos += " DB_DOC == '" + ARQ_TRAB_TEMP->DB_DOC + "'"
		Endif

		DbSelectArea("ARQ_TRAB_TEMP")
		ARQ_TRAB_TEMP->(DbSkip())
	EndDo

	dbSelectArea("ARQ_TRAB_TEMP")
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
		cQuery += "			DB_IMPMAP = 'S',    "
		cQuery += "			DB_CDEXEC = '" + mv_par16 + "'"

		cQuery += "  WHERE DB_SERVIC BETWEEN '" + mv_par01       + "' AND '" + mv_par02 + "'"
		cQuery += "  AND   DB_TAREFA BETWEEN '" + mv_par03       + "' AND '" + mv_par04 + "'"
		cQuery += "  AND   DB_ATIVID BETWEEN '" + mv_par05       + "' AND '" + mv_par06 + "'"
		cQuery += "  AND   DB_SERIE  BETWEEN '" + mv_par09 		 + "' AND '" + mv_par10 + "'"
		cQuery += "  AND   DB_DATA   BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"

		cQuery += "  AND   DB_DOC IN (" + cPedidos + ")"

		cQuery += "  AND   DB_FILIAL = '" + xFilial("SDB") + "'"
		cQuery += "  AND   D_E_L_E_T_ <> '*' "

		cQuery += "  AND   DB_ESTORNO = ' ' "
		cQuery += "  AND   DB_ATUEST  = 'N' "
		cQuery += "  AND   DB_IMPMAP <> 'S' "		

 	    If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())   
		Else
			CriarArqTrab()
			CarregarArqTrab()
        EndIf 	        	    
	endif  

Return(nil)

User Function AGX436Parametros()

	if CriarPerg()
		CriarArqTrab()
		CarregarArqTrab()
	EndIf

Return(nil)

Static Function LocalizarExecutor()

	cQuery := ""
	cQuery += "     SELECT ZZA_NOME "
	cQuery += "     FROM " + RetSqlName("ZZA") 
	cQuery += "     WHERE ZZA_COD = '" + mv_par16 + "'"
	cQuery += "     AND   ZZA_FILIAL = '" + xFilial('ZZA') + "'"
	cQuery += "     AND   D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_ZZA") <> 0
       dbSelectArea("QRY_ZZA")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_ZZA"

	if AllTrim(QRY_ZZA->ZZA_NOME) == ""
		Aviso("T.I. Informa:","Código de executor informado inválido!",{"&OK"})
		Return .F.
	Else
		Return .T.
	EndIf

Return(nil)