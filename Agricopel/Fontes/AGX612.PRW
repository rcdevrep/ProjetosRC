#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "TOPCONN.CH"

User Function AGX612()

	Local aArea := GetArea()

	Private oTmpTable := Nil
	Private cAliasTrb := ""

	If !CriaSx1()
		Return
	EndIf

	oTmpTable := CriaTab()
	cAliasTrb := oTmpTable:GetAlias()

	MsgRun("Processando...","Buscando dados",{|| Carga() })

	CriarBrwPed()

	RestArea(aArea)

	(cAliasTrb)->(DbCloseArea())
	oTmpTable:Delete()

Return

Static Function CriarBrwPed()

	Local nI        := 0
	Local aCampos   := {}
	Local aButton   := {}
	Local oBrowse   := Nil
	Local oColumn   := Nil
	Local oDlg      := Nil

	Define MsDialog oDlg FROM 0, 0 To 800, 1900 Pixel style DS_MODALFRAME
	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS (cAliasTrb) OF oDlg

	oBrowse:DisableConfig ( )
	oBrowse:SetDoubleClick({||BrwItPed()})

	SetKey(VK_F12, {|| RefreshBrw(),oBrowse:Refresh(),oBrowse:GoTop(.T.)})

	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->LIBPARCIAL) =  "S"   '  COLOR "WHITE"   TITLE "Pedido Liberado Parcial" OF oBrowse
	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->BLQEST)  <> "" .AND. ALLTRIM(' + cAliasTrb + '->BLQWMS)  == "" .AND. ALLTRIM(' + cAliasTrb + '->BLQCRED) == "" '  COLOR "BLACK"  TITLE "Bloqueio Estoque" OF oBrowse
	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->BLQCRED) <> "" .AND. ALLTRIM(' + cAliasTrb + '->BLQEST)  == "" .AND. ALLTRIM(' + cAliasTrb + '->BLQWMS)  == "" '  COLOR "BLUE"   TITLE "Bloqueio Credito" OF oBrowse
	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->BLQWMS)  <> "" .AND. ALLTRIM(' + cAliasTrb + '->BLQEST)  == "" .AND. ALLTRIM(' + cAliasTrb + '->BLQCRED) == "" '  COLOR "YELLOW" TITLE "Bloqueio WMS"     OF oBrowse
	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->BLQEST)  <> "" .AND. ALLTRIM(' + cAliasTrb + '->BLQCRED) <> ""  '  COLOR "PINK" TITLE "Bloqueio Credito/Estoque"  OF oBrowse
	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->NOTA)    <> "" .AND. PARCIAL == "S" ' COLOR "ORANGE" TITLE "Faturado Parcial" OF oBrowse
	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->NOTA)    <> "" .AND. PARCIAL == "N" ' COLOR "RED" TITLE "Pedido Faturado" OF oBrowse
	ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->NOTA)    == "" .AND. ALLTRIM(' + cAliasTrb + '->BLQEST) == ""  .AND. ALLTRIM(' + cAliasTrb + '->BLQWMS) == "" .AND. ALLTRIM(' + cAliasTrb + '->BLQCRED) == "" '  COLOR "GREEN"   TITLE "Liberado Faturamento" OF oBrowse
	//ADD LEGEND DATA 'ALLTRIM(' + cAliasTrb + '->LIBPARCIAL) =  "S"   '  COLOR "WHITE"   TITLE "Pedido Parcial" OF oBrowse


	AADD(aCampos,{"PEDIDO"			,"Pedido"     		     , "@!"})
	AADD(aCampos,{"CLIENTE"	     	,"Cliente"     		     , "@!"})
	AADD(aCampos,{"LOJA "		    ,"Loja"     		     , "@!"})
	AADD(aCampos,{"NOME"		    ,"Nome"                  , "@!"})
	AADD(aCampos,{"CIDADE "		    ,"Cidade"                , "@!"})
	AADD(aCampos,{"DTEMISSAO"   	,"Dt Emissao"     		 , "@!"})
	AADD(aCampos,{"HREMISSAO"   	,"Hr Emissao"     		 , "@!"})
	AADD(aCampos,{"BLQEST"	     	,"Bloq.Estoque"          , ""})
	AADD(aCampos,{"BLQCRED"	     	,"Bloq.Credito"          , ""})
	AADD(aCampos,{"BLQWMS"	     	,"Bloq.WMS"     		 , ""})
	AADD(aCampos,{"NOTA"	     	,"Nota Fiscal"     		 , ""})
	AADD(aCampos,{"LIBPARCIAL"	    ,"Liberado Parcial"      , ""})
	AADD(aCampos,{"PARCIAL"	     	,"Fat. Parcial"    		 , ""})
	AADD(aCampos,{"CREDITO"	     	,"Status Aprov Cred"     , ""})
	AADD(aCampos,{"PRICING"	     	,"Status Aprov Pricing"  , ""})
	AADD(aCampos,{"ORIGEMPED"	    ,"Origem Ped "           , ""})
	AADD(aCampos,{"NRATEND"	        ,"Nr Atendimento"        , ""})
	AADD(aCampos,{"IMPMAPA"	        ,"Mapa Sep"              , ""})
	AADD(aCampos,{"DTHRCRED"	    ,"DtHr Lib Credito"      , ""})
	AADD(aCampos,{"DTHRPRIC"	    ,"DtHr Lib Pricing"      , ""})
	AADD(aCampos,{"VEND1"	        ,"Cód RL"                , ""})
	AADD(aCampos,{"VEND2"	        ,"Cód RT"                , ""})
	AADD(aCampos,{"VEND3"	        ,"Cód RC"                , ""})
	AADD(aCampos,{"VEND6"	        ,"Cód RT Arla"           , ""})
	AADD(aCampos,{"VEND7"	        ,"Cód Rep Arla"          , ""})
	


	For nI := 1 To Len( aCampos )
		ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2] PICTURE aCampos[nI][3] Of oBrowse
	Next

	Activate FWBrowse oBrowse
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButton)

Return()

Static Function CriaSx1()

	Local cPerg  := "AGX612"
	Local aRegs  := {}

	aAdd(aRegs,{cPerg,"01","Cliente De         ?","mv_ch1","C",GetSX3Cache("A1_COD", "X3_TAMANHO"),0,0,"G","","mv_par01","","","","","","","","","","","","","","","CLI"})
	aAdd(aRegs,{cPerg,"02","Cliente até        ?","mv_ch2","C",GetSX3Cache("A1_COD", "X3_TAMANHO"),0,0,"G","","mv_par02","","","","","","","","","","","","","","","CLI"})
	aAdd(aRegs,{cPerg,"03","Loja até           ?","mv_ch3","C",GetSX3Cache("A1_LOJA", "X3_TAMANHO"),0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Loja até           ?","mv_ch4","C",GetSX3Cache("A1_LOJA", "X3_TAMANHO"),0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Emissao de         ?","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Emissao até        ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Armazém            ?","mv_ch7","C",2,0,0,"G","","mv_par07","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Bloqueios          ?","mv_ch8","N",1,0,0,"C","","mv_par08","Todos Pedidos","","","Credito","","","Estoque","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Arla.              ?","mv_ch9","N",1,0,0,"C","","mv_par09","Sim","","","Nao","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Filtrar por.       ?","mv_ch10","N",1,0,0,"C","","mv_par10","Todos","","","RC","","","RT","","","RL","","","","",""})
	aAdd(aRegs,{cPerg,"11","Vendedor De        ?","mv_ch11","C",GetSX3Cache("A1_VEND", "X3_TAMANHO"),0,0,"G","","mv_par11","","","","","","","","","","","","","","","SA3"})
	aAdd(aRegs,{cPerg,"12","Vendedor Ate       ?","mv_ch12","C",GetSX3Cache("A1_VEND", "X3_TAMANHO"),0,0,"G","","mv_par12","","","","","","","","","","","","","","","SA3"})
	aAdd(aRegs,{cPerg,"13","Filtrar vendedor   ?","mv_ch13","N",1,0,0,"C","","mv_par13","Do Cliente","","","Do Pedido","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Pedidos Blink/Orus ?","mv_ch14","N",1,0,0,"C","","mv_par14","Todos","","","Somente SIM","","","Somente NÃO","","","","","","","",""})

	U_CriaPer(cPerg, aRegs)

Return Pergunte(cPerg,.T.)

Static Function LimparTRB()

	Local cQuery := ""

	cQuery := " DELETE FROM " + oTmpTable:GetRealName()

	If TCSqlExec(cQuery) < 0
		Alert(TCSqlError(), "Falha ao carregar dados")
	EndIf

	(cAliasTRB)->(DBGoTop())

Return()

Static Function Carga()

	Local cQuery    := ""
	Local cAliasQry := ""

	LimparTRB()

	cQuery += " SELECT C5_NUM, "
	cQuery += "        C5_CLIENTE, "
	cQuery += "        C5_LOJACLI, "
	cQuery += "        A1_NOME, "
	cQuery += "        A1_MUN, "
	cQuery += "        C5_VEND1, "
	cQuery += "        C5_VEND2, "
	cQuery += "        C5_VEND3, "
	cQuery += "        C5_VEND6, "
	cQuery += "        C5_VEND7, "
	cQuery += "        C5_EMISSAO, "

	cQuery += "        CASE WHEN C5_XIMPRE = 'S' "
	cQuery += "           THEN 'S' "
	cQuery += "           ELSE 'N' "
	cQuery += "        END AS C5_XIMPRE, "

	cQuery += "        CASE WHEN C5_IMPORTA = 'S' AND C5_ZZBLINK <> '' "
	cQuery += "           THEN 'BLINK' "
	cQuery += "           ELSE CASE WHEN C5_X_ORIG = 'XAG0038' "
	cQuery += "                   THEN 'REP.AUT.'
	cQuery += "                   ELSE C5_X_ORIG "
	cQuery += "                   END "
	cQuery += "        END AS C5_X_ORIG, "

	cQuery += "        ISNULL((SELECT TOP 1 C9_BLEST "
	cQuery += "                FROM " + RetSqlName('SC9') + " SC9 (NOLOCK) "
	cQuery += "                WHERE C9_FILIAL = C5_FILIAL "
	cQuery += "                AND C9_PEDIDO = C5_NUM "
	cQuery += "                AND C9_BLEST = '02' "
	cQuery += "                AND SC9.D_E_L_E_T_ = '') "
	cQuery += "        , '') AS BLQ_EST, "

	cQuery += "        ISNULL((SELECT TOP 1 C9_BLCRED "
	cQuery += "                FROM " + RetSqlName('SC9') + " SC9 (NOLOCK) "
	cQuery += "                WHERE C9_FILIAL = C5_FILIAL "
	cQuery += "                AND C9_PEDIDO = C5_NUM "
	cQuery += "                AND C9_BLCRED in ('01','04') "
	cQuery += "                AND SC9.D_E_L_E_T_ = '') "
	cQuery += "        , '') AS BLQ_CRED, "

	cQuery += "        ISNULL((SELECT TOP 1 C9_BLWMS "
	cQuery += "                FROM " + RetSqlName('SC9') + " SC9 (NOLOCK) "
	cQuery += "                WHERE C9_FILIAL = C5_FILIAL "
	cQuery += "                AND C9_PEDIDO = C5_NUM "
	cQuery += "                AND C9_BLWMS IN ('01', '02') "
	cQuery += "                AND SC9.D_E_L_E_T_ = '') "
	cQuery += "        , '') AS BLQ_WMS, "

	cQuery += "        ISNULL((SELECT TOP 1 C6_NOTA "
	cQuery += "                FROM " + RetSqlName('SC6') + " SC6 (NOLOCK) "
	cQuery += "                WHERE C6_FILIAL = C5_FILIAL "
	cQuery += "                AND C6_NUM = C5_NUM "
	cQuery += "                AND C6_NOTA <> '' "
	cQuery += "                AND SC6.D_E_L_E_T_ = '') "
	cQuery += "        , '') AS NOTA, "

	cQuery += "        CASE WHEN EXISTS(SELECT C6_NUM "
	cQuery += "                         FROM " + RetSqlName('SC6') + " SC6 (NOLOCK) "
	cQuery += "                         WHERE C6_FILIAL = C5_FILIAL "
	cQuery += "                         AND C6_NUM = C5_NUM "
	cQuery += "                         AND C6_NOTA <> '' AND SC6.D_E_L_E_T_ = '' "
	cQuery += "                         AND   ((C6_QTDENT <> C6_QTDVEN "
	cQuery += "                         AND   C6_QTDENT > 0 )"
	cQuery += "                         OR (SELECT TOP 1 C6_NUM FROM " + RetSqlName('SC6') + " (NOLOCK) AS PEDPARC "
	cQuery += "                        		WHERE PEDPARC.C6_FILIAL = C5_FILIAL "	
	cQuery += "                         	AND PEDPARC.C6_NUM = C5_NUM  "
	cQuery += "                         	AND PEDPARC.C6_NOTA = ''   AND PEDPARC.D_E_L_E_T_ = '' "
	cQuery += "                         ) <> '' "
	cQuery += "                         ) )	 "
	cQuery += "        THEN 'S' "
	cQuery += "        ELSE 'N' "
	cQuery += "        END AS PARCIAL, "

	cQuery += "        ISNULL((SELECT TOP 1 C6_HRCAPTA "
	cQuery += "                FROM " + RetSqlName('SC6') + " SC6 (NOLOCK) "
	cQuery += "                WHERE C6_FILIAL = C5_FILIAL "
	cQuery += "                AND C6_NUM = C5_NUM "
	cQuery += "                AND SC6.D_E_L_E_T_ = '') "
	cQuery += "        , '') AS HREMISSAO, "

	cQuery += "        ISNULL((SELECT TOP 1 CR_STATUS "
	cQuery += "                FROM " + RetSqlName('SCR') + " SCR (NOLOCK) "
	cQuery += "                INNER JOIN " + RetSqlName('PB2') + " PB2 (NOLOCK) ON PB2_FILIAL = CR_FILIAL "
	cQuery += "                                                                 AND PB2_APROV = CR_APROV "
	cQuery += "                                                                 AND PB2_NIVEL > '01' "
	cQuery += "                                                                 AND PB2_VEND = C5_VEND1 "
	cQuery += "                                                                 AND PB2_DELEG = 'S' "
	cQuery += "                WHERE CR_FILIAL = C5_FILIAL "
	cQuery += "                AND PB2.D_E_L_E_T_ = '' "
	cQuery += "                AND SCR.D_E_L_E_T_ = '' "
	cQuery += "                AND CR_NUM = C5_NUM) "
	cQuery += "        , '') AS CREDITO, "

	cQuery += "        ISNULL((SELECT TOP 1 CR_STATUS "
	cQuery += "                FROM " + RetSqlName('SCR') + " SCR (NOLOCK) "
	cQuery += "                INNER JOIN " + RetSqlName('PB4') + " PB4 (NOLOCK) ON PB4_FILIAL = CR_FILIAL "
	cQuery += "                                                                 AND PB4_APROV = CR_APROV "
	cQuery += "                                                                 AND PB4_NIVEL > '01' "
	cQuery += "                                                                 AND PB4_VEND = C5_VEND1 "
	cQuery += "                                                                 AND PB4_DELEG = 'S' "
	cQuery += "                WHERE CR_FILIAL = C5_FILIAL "
	cQuery += "                AND PB4.D_E_L_E_T_ = '' "
	cQuery += "                AND SCR.D_E_L_E_T_ = '' "
	cQuery += "                AND CR_NUM = C5_NUM) "
	cQuery += "        ,'') AS PRICING, "

	If (SCR->(FieldPos("CR_ZZHORA") > 0))

		cQuery += "        ISNULL((SELECT TOP 1 CONCAT(CR_DATALIB,'-',CR_ZZHORA) "
		cQuery += "                FROM " + RetSqlName('SCR') + " SCR (NOLOCK) "
		cQuery += "                INNER JOIN " + RetSqlName('PB2') + " PB2 (NOLOCK) ON PB2_FILIAL = CR_FILIAL "
		cQuery += "                                                                 AND PB2_APROV = CR_APROV "
		cQuery += "                                                                 AND PB2_NIVEL > '01' "
		cQuery += "                                                                 AND PB2_VEND = C5_VEND1 "
		cQuery += "                                                                 AND PB2_DELEG = 'S' "
		cQuery += "                WHERE CR_FILIAL = C5_FILIAL "
		cQuery += "                AND PB2.D_E_L_E_T_ = '' "
		cQuery += "                AND SCR.D_E_L_E_T_ = '' "
		cQuery += "                AND CR_NUM = C5_NUM) "
		cQuery += "        , '') AS DTHRCRED, "

		cQuery += "        ISNULL((SELECT TOP 1 CONCAT(CR_DATALIB,'-',CR_ZZHORA) "
		cQuery += "                FROM " + RetSqlName('SCR') + " SCR (NOLOCK) "
		cQuery += "                INNER JOIN " + RetSqlName('PB4') + " PB4 (NOLOCK) ON PB4_FILIAL = CR_FILIAL "
		cQuery += "                                                                 AND PB4_APROV = CR_APROV "
		cQuery += "                                                                 AND PB4_NIVEL > '01' "
		cQuery += "                                                                 AND PB4_VEND = C5_VEND1 "
		cQuery += "                                                                 AND PB4_DELEG = 'S' "
		cQuery += "                WHERE CR_FILIAL = C5_FILIAL "
		cQuery += "                AND PB4.D_E_L_E_T_ = '' "
		cQuery += "                AND SCR.D_E_L_E_T_ = '' "
		cQuery += "                AND CR_NUM = C5_NUM) "
		cQuery += "        ,'') AS DTHRPRIC, "
	Else
		cQuery += "        '' AS DTHRCRED, "
		cQuery += "        '' AS DTHRPRIC, "
	EndIf

	cQuery += "        ISNULL((SELECT TOP 1 C6_LOCAL "
	cQuery += "                FROM " + RetSqlName('SC6') + " SC6 (NOLOCK) "
	cQuery += "                WHERE C6_FILIAL = C5_FILIAL "
	cQuery += "                AND C6_NUM = C5_NUM "
	cQuery += "                AND SC6.D_E_L_E_T_ = '') "
	cQuery += "        , '') AS LOCALEST, "

	cQuery += "        ISNULL((SELECT TOP 1 UA_NUM "
	cQuery += "                FROM " + RetSqlName('SUA') + " SUA (NOLOCK) "
	cQuery += "                WHERE UA_FILIAL = C5_FILIAL "
	cQuery += "                AND UA_NUMSC5 = C5_NUM "
	cQuery += "                AND SUA.D_E_L_E_T_ = '') "
	cQuery += "        , '') AS NRATEND,  "
	cQuery += " (
	cQuery += " SELECT TOP 1 'S' FROM "+ RetSqlName('SC9') + "(NOLOCK) C91 "
	cQuery += " WHERE C91.C9_FILIAL = C5_FILIAL "		 
	cQuery += " AND C91.C9_PEDIDO = C5_NUM "
	cQuery += " AND C91.D_E_L_E_T_ = '' "
	cQuery += " AND (  (C91.C9_BLCRED = '' AND C91.C9_BLEST = '') ) "//--TRAGO CASO TENHA 1 TOTALMENTE LIBERADO
	cQuery += "          AND ( SELECT TOP 1 C92.C9_PEDIDO FROM "+ RetSqlName('SC9') + "(NOLOCK) C92 "//--Verifico se tem algum bloqueado
	cQuery += " 			WHERE C92.C9_FILIAL = C5_FILIAL	AND C92.C9_PEDIDO = C5_NUM AND  "
	cQuery += " 				  (C92.C9_BLCRED <> '' OR C92.C9_BLEST  <> '') AND C92.D_E_L_E_T_ = '' ) <> '' "
	cQuery += " GROUP BY C9_PEDIDO "
	cQuery += " ) AS LIBPARCIAL "
	cQuery += " FROM " + RetSqlName('SC5') + " C5 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName('SA1') + " SA1 (NOLOCK) ON A1_COD = C5_CLIENTE "
	cQuery += "                                                AND A1_LOJA = C5_LOJACLI "

	If (MV_PAR13 == 1)
		//NÃO ARLA
		If MV_PAR09 == 2
			If MV_PAR10 == 1 //Todos
				cQuery += " AND (A1_VEND3 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   A1_VEND5 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   A1_VEND2 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   A1_VEND  BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "')"
			Elseif MV_PAR10 == 2 //RC
				cQuery += " AND  A1_VEND3 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Elseif MV_PAR10 == 3 //RT
				cQuery += " AND  (A1_VEND5 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR    A1_VEND2 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "')"
			Elseif MV_PAR10 == 4 //RL
				cQuery += " AND  A1_VEND  BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Endif
			//SIM ARLA
		Else
			If MV_PAR10 == 1 //Todos
				cQuery += " AND (A1_VEND7 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   A1_VEND6 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   A1_VEND8 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "')"
			Elseif MV_PAR10 == 2 //RC
				cQuery += " AND  A1_VEND7 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Elseif MV_PAR10 == 3 //RT
				cQuery += " AND  A1_VEND6 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Elseif MV_PAR10 == 4 //RL
				cQuery += " AND  A1_VEND8 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Endif
		Endif
	Else
		//NÃO ARLA
		If MV_PAR09 == 2
			If MV_PAR10 == 1 //Todos
				cQuery += " AND (C5_VEND3 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   C5_VEND5 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   C5_VEND2 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   C5_VEND1 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "')"
			Elseif MV_PAR10 == 2 //RC
				cQuery += " AND  C5_VEND3 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Elseif MV_PAR10 == 3 //RT
				cQuery += " AND  (C5_VEND5 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR    C5_VEND2 BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "')"
			Elseif MV_PAR10 == 4 //RL
				cQuery += " AND  C5_VEND1 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Endif
			//SIM ARLA
		Else
			If MV_PAR10 == 1 //Todos
				cQuery += " AND (C5_VEND7 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   C5_VEND6 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
				cQuery += " OR   C5_VEND8 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "')"
			Elseif MV_PAR10 == 2 //RC
				cQuery += " AND  C5_VEND7 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Elseif MV_PAR10 == 3 //RT
				cQuery += " AND  C5_VEND6 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Elseif MV_PAR10 == 4 //RL
				cQuery += " AND  C5_VEND8 BETWEEN  '" + mv_par11 + "' AND '" + mv_par12 + "'"
			Endif
		Endif
	EndIf

	cQuery += " WHERE C5_FILIAL = '" + xFilial('SC5') + "'"
	cQuery += " AND C5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_EMISSAO BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06) + "'"
	cQuery += " AND C5_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += " AND C5_LOJACLI BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"

	If (cEmpAnt == "01" .And. FwFilial() == "06")
		If (MV_PAR14 == 2)
			cQuery += " AND ((C5_ZZBLINK <> '' AND C5_IMPORTA = 'S') OR C5_X_ORIG = 'ORUS') "
		ElseIf (MV_PAR14 == 3)
			cQuery += " AND C5_ZZBLINK = '' AND C5_IMPORTA <> 'S' AND C5_X_ORIG <> 'ORUS' "
		EndIf
	EndIf

	cQuery += " AND SA1.D_E_L_E_T_ = '' "
	cQuery += " AND C5_NOTA <> 'XXXXXXXXX' "
	cQuery += " ORDER BY C5_NUM "

	cAliasQry := MpSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	While !eof()

		If mv_par08 == 2 .And. Empty((cAliasQry)->BLQ_CRED) // Filtro por bloqueio de credito
			dbSelectArea(cAliasQry)
			dbSkip()
			LOOP
		EndIf

		If mv_par08 == 3 .And. (Empty((cAliasQry)->BLQ_EST) .Or. !Empty((cAliasQry)->NOTA)) // Filtro por bloqueio de estoques
			dbSelectArea(cAliasQry)
			dbSkip()
			LOOP
		EndIf

		If !Empty(mv_par07) .And. AllTrim(mv_par07) <> (cAliasQry)->LOCALEST //Filtro por Local
			dbSelectArea(cAliasQry)
			dbSkip()
			LOOP
		EndIf

		If !Empty((cAliasQry)->NOTA)
			cPricing := ""
			cCredito := ""
		Else
			Do Case
			Case (cAliasQry)->PRICING == "01" .And. !Empty((cAliasQry)->BLQ_CRED)
				cPricing := "Aguardando"
			Case (cAliasQry)->PRICING == "02" .And. !Empty((cAliasQry)->BLQ_CRED)
				cPricing := "Em Aprovação"
			Case (cAliasQry)->PRICING == "04".And. !Empty((cAliasQry)->BLQ_CRED)
				cPricing := "Rejeitado"
			otherwise
				cPricing := ""
			EndCase

			Do Case
			Case (cAliasQry)->CREDITO == "01" .And. !Empty((cAliasQry)->BLQ_CRED)
				cCredito := "Aguardando"
			Case (cAliasQry)->CREDITO == "02" .And. !Empty((cAliasQry)->BLQ_CRED)
				cCredito := "Em Aprovação"
			Case (cAliasQry)->CREDITO == "04" .And. !Empty((cAliasQry)->BLQ_CRED)
				cCredito := "Rejeitado"
			otherwise
				cCredito := ""
			EndCase
		EndIf

		dbSelectArea(cAliasTrb)
		RecLock(cAliasTrb, .T.)
		(cAliasTrb)->PEDIDO    := (cAliasQry)->C5_NUM
		(cAliasTrb)->CLIENTE   := (cAliasQry)->C5_CLIENTE
		(cAliasTrb)->LOJA      := (cAliasQry)->C5_LOJACLI
		(cAliasTrb)->NOME      := (cAliasQry)->A1_NOME
		(cAliasTrb)->CIDADE    := (cAliasQry)->A1_MUN
		(cAliasTrb)->BLQEST    := IIf(!Empty((cAliasQry)->BLQ_EST)  .And.  Empty((cAliasQry)->NOTA), "Sim", "")
		(cAliasTrb)->BLQCRED   := IIf(!Empty((cAliasQry)->BLQ_CRED) .And.  Empty((cAliasQry)->NOTA), "Sim", "")
		(cAliasTrb)->BLQWMS    := IIf(!Empty((cAliasQry)->BLQ_WMS)  .And.  Empty((cAliasQry)->NOTA), "Sim", "")
		(cAliasTrb)->NOTA      := (cAliasQry)->NOTA
		(cAliasTrb)->PARCIAL   := (cAliasQry)->PARCIAL
		(cAliasTrb)->PRICING   := cPricing
		(cAliasTrb)->CREDITO   := cCredito
		(cAliasTrb)->LOCALEST  := (cAliasQry)->LOCALEST
		(cAliasTrb)->DTEMISSAO := StoD((cAliasQry)->C5_EMISSAO)
		(cAliasTrb)->HREMISSAO := (cAliasQry)->HREMISSAO
		(cAliasTrb)->ORIGEMPED := (cAliasQry)->C5_X_ORIG
		(cAliasTrb)->NRATEND   := (cAliasQry)->NRATEND
		(cAliasTRB)->IMPMAPA   := (cAliasQry)->C5_XIMPRE
		(cAliasTRB)->DTHRCRED  := (cAliasQry)->DTHRCRED
		(cAliasTRB)->DTHRPRIC  := (cAliasQry)->DTHRPRIC
		(cAliasTrb)->VEND1     := (cAliasQry)->C5_VEND1
		(cAliasTrb)->VEND2     := (cAliasQry)->C5_VEND2
		(cAliasTrb)->VEND3     := (cAliasQry)->C5_VEND3
		(cAliasTrb)->VEND6     := (cAliasQry)->C5_VEND6
		(cAliasTrb)->VEND7     := (cAliasQry)->C5_VEND7
		(cAliasTrb)->LIBPARCIAL := (cAliasQry)->LIBPARCIAL
		MsUnLock()

		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo

	(cAliasQry)->(dbCloseArea())

	dbSelectArea(cAliasTrb)
	dbGoTop()

Return()

Static Function CriaTab()

	Local aCampos := {}
	Local oTmpTab := Nil

	aAdd(aCampos,{"PEDIDO"	   ,"C",06,00})
	aAdd(aCampos,{"CLIENTE"	   ,"C",06,00})
	aAdd(aCampos,{"LOJA"       ,"C",02,00})
	aAdd(aCampos,{"NOME"	   ,"C",40,00})
	aAdd(aCampos,{"CIDADE"	   ,"C",40,00})
	aAdd(aCampos,{"BLQEST"     ,"C",03,00})
	aAdd(aCampos,{"BLQCRED"    ,"C",03,00})
	aAdd(aCampos,{"BLQWMS"     ,"C",03,00})
	aAdd(aCampos,{"NOTA"       ,"C",09,00})
	aAdd(aCampos,{"PARCIAL"    ,"C",01,00})
	aAdd(aCampos,{"PRICING"    ,"C",15,00})
	aAdd(aCampos,{"CREDITO"    ,"C",15,00})
	aAdd(aCampos,{"LOCALEST"   ,"C",02,00})
	aAdd(aCampos,{"DTEMISSAO"  ,"D",08,00})
	aAdd(aCampos,{"HREMISSAO"  ,"C",05,00})
	aAdd(aCampos,{"ORIGEMPED"  ,"C",25,00})
	aAdd(aCampos,{"NRATEND"    ,"C",09,00})
	aAdd(aCampos,{"IMPMAPA"    ,"C",01,00})
	aAdd(aCampos,{"DTHRCRED"   ,"C",15,00})
	aAdd(aCampos,{"DTHRPRIC"   ,"C",15,00})
	aAdd(aCampos,{"VEND1"      ,"C",06,00})
	aAdd(aCampos,{"VEND2"      ,"C",06,00})
	aAdd(aCampos,{"VEND3"      ,"C",06,00})
	aAdd(aCampos,{"VEND6"      ,"C",06,00})
	aAdd(aCampos,{"VEND7"      ,"C",06,00})
	aAdd(aCampos,{"LIBPARCIAL" ,"C",01,00})

	oTmpTab := FwTemporaryTable():New()
	oTmpTab:SetFields(aCampos)
	oTmpTab:AddIndex("IDX1", {"PEDIDO"})
	oTmpTab:Create()

Return(oTmpTab)

Static Function RefreshBrw()

	If CriaSx1()
		Carga()
	EndIf

Return()

Static Function BrwItPed()

	Local aArea2     := GetArea()
	Local nI         := 0
	Local aCampos2   := {}
	Local aButton2   := {}
	Local oBrowse2   := Nil
	Local oColumn2   := Nil
	Local oDlg2      := Nil

	Private oTmpTable2 := Nil
	Private cAliasTrb2 := ""

	oTmpTable2 := TabSC9()
	cAliasTrb2 := oTmpTable2:GetAlias()
	CargaSC9()

	Define MsDialog oDlg2 FROM 0, 0 To 800, 1600 Pixel style DS_MODALFRAME

	DEFINE FWBROWSE oBrowse2 DATA TABLE ALIAS (cAliasTrb2) OF oDlg2

	oBrowse2:DisableConfig ( )

	ADD LEGEND DATA 'ALLTRIM(' + (cAliasTrb2) + '->BLQEST)  <> "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQWMS) == "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQCRED) == "" ' COLOR "BLACK"  TITLE "Bloqueio Estoque" OF oBrowse2
	ADD LEGEND DATA 'ALLTRIM(' + (cAliasTrb2) + '->BLQCRED) <> "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQEST) == "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQWMS)  == "" ' COLOR "BLUE"   TITLE "Bloqueio Credito" OF oBrowse2
	ADD LEGEND DATA 'ALLTRIM(' + (cAliasTrb2) + '->BLQWMS)  <> "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQEST) == "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQCRED) == "" ' COLOR "YELLOW" TITLE "Bloqueio WMS"     OF oBrowse2
	ADD LEGEND DATA 'ALLTRIM(' + (cAliasTrb2) + '->BLQEST)  <> "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQCRED) <> "" ' COLOR "PINK"  TITLE "Bloqueio Credito/Estoque" OF oBrowse2
	ADD LEGEND DATA 'ALLTRIM(' + (cAliasTrb2) + '->NOTA)    <> "" ' COLOR "RED"    TITLE "Pedido Faturado"  OF oBrowse2
	ADD LEGEND DATA 'ALLTRIM(' + (cAliasTrb2) + '->NOTA)    == "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQEST) == "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQWMS) == "" .AND. ALLTRIM(' + (cAliasTrb2) + '->BLQCRED) == "" '  COLOR "GREEN"   TITLE "Liberado Faturamento" OF oBrowse2

	AADD(aCampos2,{"ITEM"			,"Item"     		,"@!"  		})
	AADD(aCampos2,{"PRODUTO"	 	,"Produto"     		,"@!"  		})
	AADD(aCampos2,{"DESCRICAO "		,"Descricao"     	,"@!"  		})
	AADD(aCampos2,{"QTDVEN"		    ,"Qtde Venda"	    ,"@E 999,999.99"  		})
	AADD(aCampos2,{"QTDLIB"		    ,"Qtde Liberada"    ,"@E 999,999.99"  		})
	AADD(aCampos2,{"PRCVEN"			,"Preco Venda"     	,"@E 999,999.99"  		})
	AADD(aCampos2,{"VALOR"	     	,"Total "     		,"@E 999,999.99"  		})
	AADD(aCampos2,{"BLQEST"	     	,"Bloq.Estoque"     ,""  		})
	AADD(aCampos2,{"BLQCRED"	   	,"Bloq.Credito"     ,""  		})
	AADD(aCampos2,{"BLQWMS"	     	,"Bloq.WMS"     	,""  		})
	AADD(aCampos2,{"NOTA"	     	,"Nota"     		,""  		})

	For nI := 1 To Len( aCampos2 )
		ADD COLUMN oColumn2 DATA &( ' { || ' + aCampos2[nI][1] + ' } ' ) Title aCampos2[nI][2] PICTURE aCampos2[nI][3] Of oBrowse2
	Next

	Activate FWBrowse oBrowse2

	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| oDlg2:End()},{|| oDlg2:End()},,aButton2)

	(cAliasTrb2)->(DbCloseArea())
	oTmpTable2:Delete()

	RestArea( aArea2 )
Return()

Static Function TabSC9()

	Local aCampos := {}
	Local oTmp    := Nil

	aAdd(aCampos,{"ITEM"	  ,"C",02,00})
	aAdd(aCampos,{"PRODUTO"	  ,"C",15,00})
	aAdd(aCampos,{"DESCRICAO" ,"C",40,00})
	aAdd(aCampos,{"QTDVEN"	  ,"N",10,4})
	aAdd(aCampos,{"PRCVEN"	  ,"N",10,4})
	aAdd(aCampos,{"VALOR"     ,"N",10,2})
	aAdd(aCampos,{"BLQEST"    ,"C",03,00})
	aAdd(aCampos,{"BLQCRED"   ,"C",03,00})
	aAdd(aCampos,{"BLQWMS"    ,"C",03,00})
	aAdd(aCampos,{"NOTA"      ,"C",09,00})
	aAdd(aCampos,{"QTDLIB"    ,"N",10,4})

	oTmp := FwTemporaryTable():New()
	oTmp:SetFields(aCampos)
	oTmp:AddIndex("IDX1", {"ITEM"})
	oTmp:Create()

Return(oTmp)

Static Function CargaSC9()

	Local cALiasQry := GetNextAlias()

	BeginSql Alias cALiasQry
		SELECT C9_ITEM ITEM, C9_PRODUTO, B1_DESC, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C9_BLEST, C9_BLCRED, C9_BLWMS, C9_NFISCAL, SUM(C9_QTDLIB) QTDELIB
		FROM %table:SC9% C9 (NOLOCK)

		INNER JOIN %table:SC6% C6 (NOLOCK) ON C9_FILIAL = C6_FILIAL
		                                  AND C9_PEDIDO = C6_NUM
		                                  AND C9_ITEM = C6_ITEM

		INNER JOIN %table:SB1% B1 (NOLOCK) ON B1_FILIAL = C9_FILIAL
		                                  AND B1_COD = C9_PRODUTO

		WHERE C9_PEDIDO = %Exp:(cAliasTrb)->PEDIDO%
		AND C9.D_E_L_E_T_ = ''
		AND C6.D_E_L_E_T_ = ''
		AND B1.D_E_L_E_T_ = ''
		AND C9_FILIAL = %xFilial:SC9%
		GROUP BY C9_ITEM, C9_PRODUTO, B1_DESC, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C9_BLEST, C9_BLCRED, C9_BLWMS, C9_NFISCAL
		ORDER BY C9_ITEM
	EndSql

	While !(cALiasQry)->(Eof())
		dbSelectArea(cAliasTrb2)
		RecLock(cAliasTrb2, .T.)
		(cAliasTrb2)->ITEM       := (cALiasQry)->ITEM
		(cAliasTrb2)->PRODUTO    := (cALiasQry)->C9_PRODUTO
		(cAliasTrb2)->DESCRICAO  := (cALiasQry)->B1_DESC
		(cAliasTrb2)->QTDVEN     := (cALiasQry)->C6_QTDVEN
		(cAliasTrb2)->PRCVEN     := (cALiasQry)->C6_PRCVEN
		(cAliasTrb2)->VALOR      := (cALiasQry)->C6_VALOR
		(cAliasTrb2)->BLQEST     := IIf(AllTrim((cALiasQry)->C9_BLEST) <> "" .And. AllTrim((cALiasQry)->C9_NFISCAL) == "" , "Sim", "")
		(cAliasTrb2)->BLQCRED    := IIf(AllTrim((cALiasQry)->C9_BLCRED) <> ""  .And. AllTrim((cALiasQry)->C9_NFISCAL) == "" , "Sim", "")
		(cAliasTrb2)->BLQWMS     := IIf((AllTrim((cALiasQry)->C9_BLWMS) == "01" .Or. AllTrim((cALiasQry)->C9_BLWMS)== "02") .And. AllTrim((cALiasQry)->C9_NFISCAL) == "" , "Sim", "")
		(cAliasTrb2)->NOTA       := (cALiasQry)->C9_NFISCAL
		(cAliasTrb2)->QTDLIB     := (cALiasQry)->QTDELIB
		MsUnLock()

		dbSelectArea(cALiasQry)
		(cALiasQry)->(dbSkip())
	EndDo

	(cALiasQry)->(DbCloseArea())

Return()

User Function AGX612PE()
Return .T.
