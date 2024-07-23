#INCLUDE "PROTHEUS.CH"

User Function AGX498()

	Private	cCadastro := "Conferência Cega"

	Private oTmpTable := {}
	Private cAliasTRB := ""

	if !CriarPerg()
		Return
	EndIf

	MsgRun("Carregando dados","Processando...",{|| CriarTRB() })
	MsgRun("Carregando dados","Processando...",{|| DadosTRB() })
	CriarBrowse()

	(cAliasTRB)->(DBCloseArea())
	oTmpTable:Delete()

Return

Static Function CriarTRB()

	Local aCampos := {}
	Local aTam    := {}
	
	AADD(aCampos,{"OK"    ,"C",2,0 } )

	aTam:=TamSX3("ZZI_NUM")
	AADD(aCampos,{"NUM_CONF"    ,"C",aTam[1],aTam[2] } )

	AADD(aCampos,{"QTDE_PROD"   ,"N",15     ,0       } )

	AADD(aCampos,{"NOMEPESSOA"  ,"C",80     ,0       } )

	AADD(aCampos,{"NOTAS"       ,"C",200    ,0       } )

	aTam:=TamSX3("ZZI_FORNEC")
	AADD(aCampos,{"FORNECE"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("ZZI_EMISSA")
	AADD(aCampos,{"DTEMISSAO"   ,"D",aTam[1],aTam[2] } )

	aTam:=TamSX3("ZZI_STATUS")
	AADD(aCampos,{"STATUSCONF"  ,"C",aTam[1],aTam[2] } )

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {"NUM_CONF"})
	oTmpTable:Create()

	cAliasTRB := oTmpTable:GetAlias()

Return()

Static Function CriarPerg()

	Local aRegistros := {}
	Local cPerg      := "AGX498"

	AADD(aRegistros,{cPerg,"01","Fornecedor       ?","mv_ch1","C",12,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Codigo De        ?","mv_ch2","C",12,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Codigo Ate       ?","mv_ch3","C",12,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Dt Emissão De    ?","mv_ch4","D",8 ,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Dt Emissão Até   ?","mv_ch5","D",8 ,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Status           ?","mv_ch6","N",1 ,0,0,"C","","mv_par06","Todas","","","Em Aberto","","","Digitadas OK","","","Inconsistentes","","","","",""})
	AADD(aRegistros,{cPerg,"07","Armazem Produto  ?","mv_ch7","C",2 ,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

Return Pergunte(cPerg,.T.)

Static Function LimparTRB()

	Local cQuery := ""

	cQuery := " DELETE FROM " + oTmpTable:GetRealName()

	If TCSqlExec(cQuery) < 0
		Alert(TCSqlError(), "Falha ao carregar dados")
	EndIf

	(cAliasTRB)->(DBGoTop())

Return()

Static Function DadosTRB()

	Local cQuery  := ""

	LimparTRB()

	cQuery += " SELECT ZZI_NUM, "
	cQuery += "        ZZI_FORNEC + ' / ' + ZZI_LOJA AS ZZI_FORNEC, "
	cQuery += "        ZZI_EMISSA, "
	cQuery += "        ZZI_STATUS, "

	cQuery += "        CASE WHEN ZZI_TIPO = 'D' "
	cQuery += "             THEN (SELECT A1_NOME "
	cQuery += "                   FROM " + RetSqlName("SA1") + " (NOLOCK) "
	cQuery += "                   WHERE A1_COD = ZZI_FORNEC "
	cQuery += "                   AND   A1_LOJA = ZZI_LOJA "
	cQuery += "                   AND   A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += "                   AND   D_E_L_E_T_ = '')

	cQuery += "             ELSE (SELECT A2_NOME "
	cQuery += "                   FROM " + RetSqlName("SA2") + " (NOLOCK) "
	cQuery += "                   WHERE A2_COD = ZZI_FORNEC "
	cQuery += "                   AND   A2_LOJA = ZZI_LOJA "
	cQuery += "                   AND   A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += "                   AND   D_E_L_E_T_ = '') "
	cQuery += "        END AS NOME_PESSOA, "

	cQuery += "        (SELECT COUNT(ZZJ_PRODUT) "
	cQuery += "         FROM " + RetSqlName("ZZJ") + " (NOLOCK) "
	cQuery += "         WHERE ZZJ_NUM = ZZI_NUM "
	cQuery += "         AND   ZZJ_FILIAL = ZZI_FILIAL "
	cQuery += "         AND   D_E_L_E_T_ = '') AS QTDE_PROD "

	cQuery += " FROM " + RetSqlName("ZZI")

	cQuery += " WHERE D_E_L_E_T_ = ''
	cQuery += " AND   ZZI_FILIAL = '" + xFilial("ZZI") + "'"

	if AllTrim(mv_par01) <> ""
		cQuery += " AND   ZZI_FORNEC = '" + mv_par01 + "'"
	EndIf

	if AllTrim(mv_par02) <> "" .Or. AllTrim(mv_par03) <> ""
		cQuery += " AND   ZZI_NUM BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "'"
	EndIf

	cQuery += " AND   ZZI_EMISSA BETWEEN '" + Dtos(mv_par04) + "' AND '" + Dtos(mv_par05) + "'"

	Do Case
		Case mv_par06 = 2
			cQuery += " AND   ZZI_STATUS = 'A' "
		Case mv_par06 = 3
			cQuery += " AND   ZZI_STATUS = 'B' "
		Case mv_par06 = 4
			cQuery += " AND   ZZI_STATUS = 'I' "
	End Case

	if AllTrim(mv_par07) <> ""
		cQuery += " AND EXISTS(SELECT TOP 1 B1_COD "
		cQuery += "            FROM " + RetSqlName("SB1") + " SB1 (NOLOCK), " + RetSqlName("ZZJ") + " (NOLOCK) "
		cQuery += "            WHERE B1_FILIAL  = ZZJ_FILIAL "
		cQuery += "            AND   B1_COD     = ZZJ_PRODUT "
		cQuery += "            AND   ZZJ_FILIAL = ZZI_FILIAL "
		cQuery += "            AND   ZZJ_NUM    = ZZI_NUM "
		cQuery += "            AND   SB1.D_E_L_E_T_ = '' "
		cQuery += "            AND   B1_LOCPAD  = '" + mv_par07 + "')"
	EndIf

    If Select("QRY_ZZI") <> 0
       dbSelectArea("QRY_ZZI")
   	   dbCloseArea()
    Endif

	MpSysOpenQuery(cQuery, "QRY_ZZI")
	TCSetField("QRY_ZZI", "ZZI_EMISSA", "D", 08, 0)

	dbSelectArea("QRY_ZZI")
	While !Eof()

		dbSelectArea(cAliasTRB)
		RecLock(cAliasTRB, .T.)

		REPLACE NUM_CONF    WITH QRY_ZZI->ZZI_NUM
		REPLACE QTDE_PROD   WITH QRY_ZZI->QTDE_PROD
		REPLACE NOMEPESSOA  WITH QRY_ZZI->NOME_PESSOA
		REPLACE FORNECE     WITH QRY_ZZI->ZZI_FORNEC
		REPLACE DTEMISSAO   WITH QRY_ZZI->ZZI_EMISSA
		REPLACE STATUSCONF  WITH QRY_ZZI->ZZI_STATUS

		MsUnLock()

		dbSelectArea("QRY_ZZI")
		dbSkip()
	EndDo

	dbSelectArea("QRY_ZZI")
	dbCloseArea()

	CarregarNotas()

	dbSelectArea(cAliasTRB)
	dbGoTop()
Return

Static Function CriarBrowse()

	Private  aRotina   := { { "Imprimir Conf" ,"U_AGX498I()"  , 0, 1},;
        	                { "Digitar Qtde" ,"U_AGX500('" + (cAliasTRB) + "')"   , 0, 1},;
							{ "Imprimir Diverg" ,"U_AGX502(" + cAliasTRB + "->NUM_CONF)"  , 0, 1},;
							{ "Excluir" ,"U_AGX498Exc()"  , 0, 1},;
							{ "Estornar" ,"U_AGX498Est()"  , 0, 1},;
            	            { "Parâmetros" ,"U_AGX498Param()"  , 0, 1},;
              		        { "Legenda"  ,"U_AGX498_Leg()" , 0, 1}}

    Private	aCores		:= {{"STATUSCONF = 'A'",'BR_AZUL'    } ,;
               				{"STATUSCONF = 'B'",'BR_VERDE'   } ,;
               				{"STATUSCONF = 'I'",'BR_VERMELHO'}}
                                                                   
	Private	cMarca     := GetMark() 

	aCamposArq := {}
	AADD(aCamposArq,{"OK"			,"","Imprimir ?"		,"@!"  		})
	AADD(aCamposArq,{"NOMEPESSOA"	,"","Cliente/Fornecedor","@!"  		})
	AADD(aCamposArq,{"QTDE_PROD"	,"","Quantidade Itens"	,"999999"	})
	AADD(aCamposArq,{"FORNECE"		,"","Codigo Cli/For"	,"@!"		})  
	AADD(aCamposArq,{"NUM_CONF"		,"","Nr Nota"			,"@!"		})  
	AADD(aCamposArq,{"DTEMISSAO"	,"","Dt Emissão"		,"@!"  		})  
	AADD(aCamposArq,{"NOTAS"		,"","Notas Fiscais"		,"@!"		})

	MarkBrow(cAliasTRB,"OK","",aCamposArq,, cMarca     ,"U_AGX498T()",         ,           ,            ,        ,             ,               ,          ,  aCores )
Return

User Function AGX498_Leg()

	BrwLegenda(cCadastro,"Legenda",    {{"BR_AZUL"       ,"A Conferir" },;
										{"BR_VERDE"      ,"Baixada"    },;
										{"BR_VERMELHO"   ,"Divergente" }})

Return(.T.)

User Function AGX498Param()

	if CriarPerg()
		MsgRun("Carregando dados","Processando...",{|| DadosTRB() })
	EndIf

Return

Static Function CarregarNotas()

	Local cNotas := ""

	dbSelectArea(cAliasTRB)
	dbGoTop()
	While !Eof()
		
		cQuery := ""

		cQuery += " SELECT ZZK_DOC
		cQuery += " FROM " + RetSqlName("ZZK") + " (NOLOCK) "
		cQuery += " WHERE ZZK_FILIAL = '" + xFilial("ZZK") + "'"
		cQuery += " AND   ZZK_NUM = '" + (cAliasTRB)->NUM_CONF + "'"
		cQuery += " AND   D_E_L_E_T_ = '' "
		cQuery += " ORDER BY ZZK_DOC "
	
	    If Select("QRY_ZZK") <> 0
	       dbSelectArea("QRY_ZZK")
	   	   dbCloseArea()
	    Endif

		MpSysOpenQuery(cQuery, "QRY_ZZK")

		dbSelectArea(cAliasTRB)
		RecLock(cAliasTRB, .F.)

		dbSelectArea("QRY_ZZK")
		While !Eof()

			cNotas := AllTrim((cAliasTRB)->NOTAS)

			if AllTrim(cNotas) == ""
				cNotas := AllTrim(QRY_ZZK->ZZK_DOC)
			Else
				cNotas += " / " + AllTrim(QRY_ZZK->ZZK_DOC)
			EndIf

			dbSelectArea(cAliasTRB)
			REPLACE NOTAS WITH cNotas

			dbSelectArea("QRY_ZZK")
			dbSkip()
		EndDo

		dbSelectArea(cAliasTRB)
		MsUnLock()

		dbSelectArea("QRY_ZZK")
		dbCloseArea()

		dbSelectArea(cAliasTRB)
		dbSkip()
	End

Return

User Function AGX498Exc()

Local cNumConf := (cAliasTRB)->NUM_CONF

	if MsgNoYes("CONFIRMA A EXCLUSÃO DA CONFERÊNCIA CEGA? [" + AllTrim(cNumConf) + "]")

        cQuery := ""
        cQuery += " UPDATE " + RetSqlName("ZZK") + " SET "
        cQuery += " D_E_L_E_T_ = '*' "
        cQuery += " WHERE ZZK_NUM = '" + cNumConf + "'"
        cQuery += " AND   ZZK_FILIAL = '" + xFilial("ZZK") + "'"
        cQuery += " AND   D_E_L_E_T_ = '' "

		If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

        cQuery := ""
        cQuery += " UPDATE " + RetSqlName("ZZJ") + " SET "
        cQuery += " D_E_L_E_T_ = '*' "
        cQuery += " WHERE ZZJ_NUM = '" + cNumConf + "'"
        cQuery += " AND   ZZJ_FILIAL = '" + xFilial("ZZJ") + "'"
        cQuery += " AND   D_E_L_E_T_ = '' "

		If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

        cQuery := ""
        cQuery += " UPDATE " + RetSqlName("ZZI") + " SET "
        cQuery += " D_E_L_E_T_ = '*' "
        cQuery += " WHERE ZZI_NUM = '" + cNumConf + "'"
        cQuery += " AND   ZZI_FILIAL = '" + xFilial("ZZI") + "'"
        cQuery += " AND   D_E_L_E_T_ = '' "

		If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

		MsgInfo("EXCLUSAO EFETUADA COM SUCESSO!")

		U_AGX498Param()
	Else
		MsgInfo("EXCLUSAO NÃO EFETUADA!")
	EndIf

Return

User Function AGX498Est()

Local cNumConf := (cAliasTRB)->NUM_CONF

	if MsgNoYes("CONFIRMA O ESTORNO DA CONFERÊNCIA CEGA? [" + AllTrim(cNumConf) + "]")

        cQuery := ""
        cQuery += " UPDATE " + RetSqlName("ZZI") + " SET "
        cQuery += " ZZI_STATUS = 'A' "
        cQuery += " WHERE ZZI_NUM = '" + cNumConf + "'"
        cQuery += " AND   ZZI_FILIAL = '" + xFilial("ZZI") + "'"
        cQuery += " AND   D_E_L_E_T_ = '' "

		If (TCSQLExec(cQuery) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

		DbSelectArea(cAliasTRB)
		RecLock(cAliasTRB,.F.)
		(cAliasTRB)->STATUSCONF := "A"
		MsUnLock()

		MsgInfo("ESTORNO EFETUADO COM SUCESSO!")
	Else
		MsgInfo("ESTORNO NÃO EFETUADO!")
	EndIf

Return
      

// Função de Impressão de várias conferências 
// ao mesmo tempo
User Function AGX498I()

	Private aArrayCONF := {}         
   
    (cAliasTRB)->(dbgotop())
    
    While (cAliasTRB)->(!eof())
         
    	//Adiciona no Array somente o que foi marcado
    	If alltrim((cAliasTRB)->OK) <> '' 
   			AADD(aArrayCONF, (cAliasTRB)->NUM_CONF )
   		Endif
   		
		(cAliasTRB)->(dbskip())
    Enddo
             
    //Se marcou ao menos um item Gera a Impressão
    If len(aArrayCONF) > 0  
    	U_AGX499(/*'',*/aArrayCONF)      		
	Else
		Alert('Selecione ao menos uma conferência!')
	Endif
Return                          


//Marcar todos 
User Function AGX498T()

	Local nRecno := (cAliasTRB)->(Recno())

	DbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbGotop())
	While (cAliasTRB)->(!Eof())
		RecLock(cAliasTRB,.F.)
			If Empty((cAliasTRB)->OK)
				(cAliasTRB)->OK := cMarca
			Else
				(cAliasTRB)->OK := ""
			Endif
		(cAliasTRB)->(MsUnlock())
		(cAliasTRB)->(dbSkip())
	Enddo
	dbGoto(nRecno)
Return .T.