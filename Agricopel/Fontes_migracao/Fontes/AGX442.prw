#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX442    บAutor  ณLeandro             บ Data ณ  01/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RELAวรO DOS SERVIวOS E SEUS EXECUTORES                     นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ                      
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX442()

	SetPrvt("aImprime")

	aImprime := {}
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo, listar ")
	cDesc2        	:= OemToAnsi("os servi็os de estoque e seus executores ")
	cDesc3        	:= ""
	cPict         	:= ""
	nLin         	:= 80
	cabec1       	:= ""
    cabec2  	    := ""

	imprime      	:= .T.
	aOrd 			:= ""
	lEnd            := .F.
	lAbortPrint     := .F.
	CbTxt           := ""
	limite          := 132
	tamanho         := "G"
	nomeprog        := "AGX442"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX442"
	aRegistros  	:= {}
	cPerg		    := "AGX442"
	cString 	   	:= ""
	titulo  	    :="Servi็os de estoque e seus executores"
    cCancel 	    := "***** CANCELADO PELO OPERADOR *****"
	aRegistros      := {}

	CriaPerg()
    wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracoes de arrays                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	if mv_par06 == 1

		if mv_par07 == 1
			cabec1 := "          PRODUTO        DESCRIวรO                                                   QUANTIDADE    UM     PESO UNIT     PESO TOTAL     DOCUMENTO      CARGA           DATA "
		EndIf

		Processa({|| GeraDados() })
		RptStatus({|| RptDetail() })
	Else

		cabec1 := "EXECUTOR                                                   QTDE ITENS          QTDE TOTAL            PESO TOTAL "

		Processa({|| GeraDados2() })
		RptStatus({|| RptDetail2() })
	EndIf

Return

Static Function CriaPerg()

	cPerg := "AGX442"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Pedido De         ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Pedido Ate        ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Data De           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Data Ate          ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Executor          ?","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","ZZA"})
	AADD(aRegistros,{cPerg,"06","Mostrar Servi็os  ?","mv_ch6","N",01,0,0,"C","","mv_par06","SIM","","","NรO","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Mostrar Produtos  ?","mv_ch7","N",01,0,0,"C","","mv_par07","SIM","","","NรO","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Armazem           ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Carga De          ?","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Carga Ate         ?","mv_chA","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return()

Static Function GeraDados()

	cQuery := ""
	cQuery += "  SELECT SDB.R_E_C_N_O_, "
	cQuery += "         DB_DOC, "
	cQuery += "         DB_CARGA, "
	cQuery += "         DB_DATA, "
	cQuery += "         DB_QUANT, "
	cQuery += "         DB_SERVIC, "
	cQuery += "         DB_CDEXEC, "
	cQuery += "         DB_PRODUTO, "
	cQuery += "         B1_DESC, "
	cQuery += "         B1_PESO, "
	cQuery += "         B1_UM, "
	cQuery += "         ZZA_NOME, "

	cQuery += "        (SELECT X5_DESCRI "
	cQuery += "         FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += "         WHERE X5_TABELA = 'L4' "
	cQuery += "         AND   X5_FILIAL = '" + xFilial("SX5") + "'"
	cQuery += "         AND   X5_CHAVE  = DB_SERVIC) "
	cQuery += "        AS X5_DESCRI "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB, " + RetSqlName("SB1") + " SB1, "
	cQuery +=             RetSqlName("ZZA") + " ZZA, " + RetSqlName("SC6") + " SC6 "

	cQuery += "  WHERE B1_COD = DB_PRODUTO "

	cQuery += "  AND   SDB.DB_SERVIC = '001' "
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += "  AND   SDB.DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
	cQuery += "  AND   SDB.DB_DATA   BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "'"
	cQuery += "  AND   SDB.DB_LOCAL = '" + mv_par08 + "'"
	cQuery += "  AND   ZZA.ZZA_COD = SDB.DB_CDEXEC "

	cQuery += "  AND   SDB.DB_DOC = SC6.C6_NUM "
	cQuery += "  AND   SDB.DB_PRODUTO = SC6.C6_PRODUTO "
	cQuery += "  AND   SC6.C6_NOTA != '' "

	if AllTrim(mv_par05) <> ""
		cQuery += "  AND   DB_CDEXEC = '" + mv_par05 + "'"
	EndIf

	cQuery += "  AND   ZZA.ZZA_FILIAL = '" + xFilial("ZZA") + "'"
	cQuery += "  AND   ZZA.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
	cQuery += "  AND   SC6.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "  AND   SB1.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_TM      > '500' "
	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "

	cQuery += " UNION ALL "

	cQuery += "  SELECT SDB.R_E_C_N_O_, "
	cQuery += "         DB_DOC, "
	cQuery += "         DB_CARGA, "
	cQuery += "         DB_DATA, "
	cQuery += "         DB_QUANT, "
	cQuery += "         DB_SERVIC, "
	cQuery += "         DB_CDEXEC, "
	cQuery += "         DB_PRODUTO, "
	cQuery += "         B1_DESC, "
	cQuery += "         B1_PESO, "
	cQuery += "         B1_UM, "
	cQuery += "         ZZA_NOME, "

	cQuery += "        (SELECT X5_DESCRI "
	cQuery += "         FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += "         WHERE X5_TABELA = 'L4' "
	cQuery += "         AND   X5_FILIAL = '" + xFilial("SX5") + "'"
	cQuery += "         AND   X5_CHAVE  = DB_SERVIC) "
	cQuery += "        AS X5_DESCRI "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB, " + RetSqlName("SB1") + " SB1, " + RetSqlName("ZZA") + " ZZA "

	cQuery += "  WHERE B1_COD = DB_PRODUTO "

	cQuery += "  AND   SDB.DB_SERVIC = '016' "
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += "  AND   SDB.DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
	cQuery += "  AND   SDB.DB_DATA   BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "'"
	cQuery += "  AND   SDB.DB_LOCAL = '" + mv_par08 + "'"
	cQuery += "  AND   ZZA.ZZA_COD = SDB.DB_CDEXEC "

	if AllTrim(mv_par05) <> ""
		cQuery += "  AND   DB_CDEXEC = '" + mv_par05 + "'"
	EndIf

	cQuery += "  AND   ZZA.ZZA_FILIAL = '" + xFilial("ZZA") + "'"
	cQuery += "  AND   ZZA.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "  AND   SB1.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "

	cQuery += " ORDER BY DB_CDEXEC, DB_SERVIC, DB_DOC, DB_PRODUTO "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SDB") <> 0
       dbSelectArea("QRY_SDB")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"
	TCSetField("QRY_SDB", "DB_DATA", "D", 08, 0)

Return

Static Function RptDetail	
//	titulo   := titulo

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
         
	nLin 	 := 9
	nTotVol	 := 0
	nTotFat	 := 0
	RepCod   := ''
	GruCod   := ''
	PriVez   := 'N'  
	dDataC   := CtoD('  /  /  ')   
	Nota     := ''
	Serie    := ''         
	Usuario  := '' 
	cUltExec := ""
	cUltServ := ""

	nItens_q1 := 0
	nQtde_q1  := 0
	nPeso_q1  := 0
	nItens_q2 := 0
	nQtde_q2  := 0
	nPeso_q2  := 0

	dbSelectArea("QRY_SDB")   	
	dbGoTop() 		                  
	While !Eof() 

		If lEnd
			Exit
		endif

		if nLin > 55
//			Roda(0,"","P")
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
			nLin := 9
		EndIf

		if cUltExec <> QRY_SDB->DB_CDEXEC

			@ nLin, 000 PSAY "Executor: " + AllTrim(QRY_SDB->DB_CDEXEC) + " - " + AllTrim(QRY_SDB->ZZA_NOME)
			nLin++

			@ nLin, 000 PSAY Replicate("-", 215)
			nLin++

			if nLin > 55
//				Roda(0,"","P")
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
				nLin := 9
			EndIf

			cUltExec := QRY_SDB->DB_CDEXEC
			cUltServ := ""
		endif

		if cUltServ <> QRY_SDB->DB_SERVIC

			@ nLin,005 PSAY "Servi็o: " + QRY_SDB->DB_SERVIC + " - " + QRY_SDB->X5_DESCRI
			 
			if mv_par07 == 1
				nLin++
				nLin++
			EndIf

			cUltServ := QRY_SDB->DB_SERVIC
		EndIf

	    nPesoTotItem := 0
	    nPesoTotItem := Round(QRY_SDB->B1_PESO, 2) * Round(QRY_SDB->DB_QUANT, 2)
                
		if mv_par07 == 1 
			@ nLin,010 PSAY AllTrim(QRY_SDB->DB_PRODUTO)
			@ nLin,025 PSAY AllTrim(QRY_SDB->B1_DESC)
			@ nLin,084 PSAY Transform(QRY_SDB->DB_QUANT,"@E 99999999.99")
			@ nLin,099 PSAY QRY_SDB->B1_UM
			@ nLin,104 PSAY Transform(QRY_SDB->B1_PESO,"@E 99999999.99")
			@ nLin,119 PSAY Transform(nPesoTotItem,"@E 99999999.99")
			@ nLin,135 PSAY QRY_SDB->DB_DOC
			@ nLin,150 PSAY QRY_SDB->DB_CARGA
			@ nLin,166 PSAY QRY_SDB->DB_DATA
			
		 	nLin++
		EndIf

		nItens_q1 += 1
		nQtde_q1  += Round(QRY_SDB->DB_QUANT, 2)
		nPeso_q1  += Round(nPesoTotItem, 2)

		nItens_q2 += 1
		nQtde_q2  += Round(QRY_SDB->DB_QUANT, 2)
		nPeso_q2  += Round(nPesoTotItem, 2)

		dbSelectArea("QRY_SDB")
		skip()

		if cUltServ <> QRY_SDB->DB_SERVIC .Or. cUltExec <> QRY_SDB->DB_CDEXEC .Or. Eof()

			nLin++
			@ nLin,005 PSay "Totais do Servi็o -->     Qtde Itens: " + Transform(nItens_q2, '@E 999,999') +;
                                                 "     Qtde Total: " + Transform(nQtde_q2,  '@E 999,999.99') +;
                                                 "     Peso Total: " + Transform(nPeso_q2,  '@E 999,999.99')

			nItens_q2 := 0
			nQtde_q2  := 0
			nPeso_q2  := 0

			nLin++
			@ nLin, 000 PSAY Replicate("-", 215)
			nLin++
		EndIf

		if cUltExec <> QRY_SDB->DB_CDEXEC .Or. Eof()

			@ nLin,000 PSay "Totais do Executor -->     Qtde Itens: " + Transform(nItens_q1, '@E 999,999') +;
                                                  "     Qtde Total: " + Transform(nQtde_q1,  '@E 999,999.99') +;
                                                  "     Peso Total: " + Transform(nPeso_q1,  '@E 999,999.99')

			nItens_q1 := 0
			nQtde_q1  := 0
			nPeso_q1  := 0

			nLin++
			@ nLin, 000 PSAY Replicate("_", 215)
			nLin++

			if nLin > 55
//				Roda(0,"","P")
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
				nLin := 9
			EndIf
		endif
	Enddo

	dbSelectArea("QRY_SDB")
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool
Return

Static Function RptDetail2

  	titulo   := titulo

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
         
	nLin 	 := 9
	nTotVol	 := 0
	nTotFat	 := 0
	RepCod   := ''
	GruCod   := ''
	PriVez   := 'N'  
	dDataC   := CtoD('  /  /  ')   
	Nota     := ''
	Serie    := ''         
	Usuario  := '' 

	dbSelectArea("QRY_SDB")   	
	dbGoTop() 		                  
	While !Eof() 

		If lEnd
			Exit
		endif

		if nLin > 55
//			Roda(0,"","P")
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
			nLin := 9
		EndIf

		@ nLin, 000 PSAY "Executor: " + AllTrim(QRY_SDB->DB_CDEXEC) + " - " + AllTrim(QRY_SDB->ZZA_NOME)
		@ nLin, 062 PSAY Transform(QRY_SDB->QTDE_REG,   '@E 999,999')
		@ nLin, 079 PSAY Transform(QRY_SDB->QTDE_TOTAL, '@E 999,999.99')
		@ nLin, 101 PSAY Transform(QRY_SDB->PESO_TOTAL, '@E 999,999.99')
		nLin++

		dbSelectArea("QRY_SDB")
		skip()
	Enddo

	dbSelectArea("QRY_SDB")
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool

Return

Static Function GeraDados2
                                            
	cQuery := ""

	cQuery += "  SELECT 

	cQuery += "  SUM(QTDE_REG) AS QTDE_REG, 
	cQuery += "  SUM(ROUND(QTDE_TOTAL,2)) AS QTDE_TOTAL, 
	cQuery += "  SUM(ROUND(PESO_TOTAL,2)) AS PESO_TOTAL, 
	cQuery += "  DB_CDEXEC, 
	cQuery += "  ZZA_NOME

	cQuery += "  FROM (

	cQuery += "  SELECT COUNT(SDB.R_E_C_N_O_) AS QTDE_REG, "
	cQuery += "         SUM(ROUND(DB_QUANT, 2)) AS QTDE_TOTAL, "
	cQuery += "         SUM(ROUND(DB_QUANT, 2) * ROUND(B1_PESO, 2)) AS PESO_TOTAL, "
	cQuery += "         DB_CDEXEC, "
	cQuery += "         ZZA_NOME "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB, " + RetSqlName("SB1") + " SB1, "
	cQuery +=             RetSqlName("ZZA") + " ZZA, " + RetSqlName("SC6") + " SC6 "

	cQuery += "  WHERE B1_COD = DB_PRODUTO "

	cQuery += "  AND   SDB.DB_SERVIC = '001' "
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += "  AND   SDB.DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
	cQuery += "  AND   SDB.DB_DATA   BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "'"
	cQuery += "  AND   SDB.DB_LOCAL = '" + mv_par08 + "'"
	cQuery += "  AND   ZZA.ZZA_COD = SDB.DB_CDEXEC "

	cQuery += "  AND   SDB.DB_DOC = SC6.C6_NUM "
	cQuery += "  AND   SDB.DB_PRODUTO = SC6.C6_PRODUTO "
	cQuery += "  AND   SC6.C6_NOTA != '' "

	if AllTrim(mv_par05) <> ""
		cQuery += "  AND   DB_CDEXEC = '" + mv_par05 + "'"
	EndIf

	cQuery += "  AND   ZZA.ZZA_FILIAL = '" + xFilial("ZZA") + "'"
	cQuery += "  AND   ZZA.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
	cQuery += "  AND   SC6.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "  AND   SB1.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_TM      > '500' "
	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "

	cQuery += " GROUP BY DB_CDEXEC, ZZA_NOME "

	cQuery += " UNION "

	cQuery += "  SELECT COUNT(SDB.R_E_C_N_O_) AS QTDE_REG, "
	cQuery += "         SUM(ROUND(DB_QUANT, 2)) AS QTDE_TOTAL, "
	cQuery += "         SUM(ROUND(DB_QUANT, 2) * ROUND(B1_PESO, 2)) AS PESO_TOTAL, "
	cQuery += "         DB_CDEXEC, "
	cQuery += "         ZZA_NOME "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB, " + RetSqlName("SB1") + " SB1, " + RetSqlName("ZZA") + " ZZA "

	cQuery += "  WHERE B1_COD = DB_PRODUTO "

	cQuery += "  AND   SDB.DB_SERVIC = '016' "
	cQuery += "  AND   SDB.DB_DOC    BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += "  AND   SDB.DB_CARGA  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
	cQuery += "  AND   SDB.DB_DATA   BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "'"
	cQuery += "  AND   SDB.DB_LOCAL = '" + mv_par08 + "'"
	cQuery += "  AND   ZZA.ZZA_COD = SDB.DB_CDEXEC "

	if AllTrim(mv_par05) <> ""
		cQuery += "  AND   DB_CDEXEC = '" + mv_par05 + "'"
	EndIf

	cQuery += "  AND   ZZA.ZZA_FILIAL = '" + xFilial("ZZA") + "'"
	cQuery += "  AND   ZZA.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "  AND   SB1.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "

	cQuery += " GROUP BY DB_CDEXEC, ZZA_NOME "

	cQuery += " ) SDB_PRINCIPAL
	cQuery += " GROUP BY SDB_PRINCIPAL.DB_CDEXEC, SDB_PRINCIPAL.ZZA_NOME

	cQuery += " ORDER BY DB_CDEXEC "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SDB") <> 0
       dbSelectArea("QRY_SDB")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"

Return