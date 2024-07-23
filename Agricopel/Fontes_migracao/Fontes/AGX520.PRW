#INCLUDE "TOPCONN.CH"
#INCLUDE "FIVEWIN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ AGX520 ³ Autor ³ Leandro F Silveira      ³Data  ³25/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressão de Separação X Faturamento                       ´±±
±±³            Comparativo entre o que foi separado e o que foi Faturado  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function AGX520()

	Private cAliasQry  := ""
	Private aImprime   := {}

	Private lEnd       := .F.// Controle de cancelamento do relatorio

	CONTFL      	:= 01
	m_pag       	:= 01
	Cabec1 			:= "Cod.Prod           Quant      UN   Descricao                                         Pedido/Item         Nota                    Endereço"
	Cabec2 			:= ""
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo imprimir ")
	cDesc2        	:= OemToAnsi("uma comparação entre o que foi separado ")
	cDesc3        	:= OemToAnsi("e o que foi faturado ")
	aOrd 			:= ""
	Tamanho         := "G"
	NomeProg        := "AGX520"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	Wnrel       	:= "AGX520"
	aRegistros  	:= {}
	cPerg		    := "AGX520"
	cString 	   	:= ""
	Titulo  	    := "Comparação - Separação X Faturamento"
	aRegistros      := {}
	cAliasQry       := GetNextAlias()
	limite          := 132

	Criar_Perg()
    Wnrel := SetPrint(cString,NomeProg,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	Processa({|| GeraDados() })
	RptStatus({|| RptDetail() })

Return

Static Function GeraDados()

	Local cQuery := ""

	cQuery := " SELECT "

	cQuery += "    C6_NOTA, "
	cQuery += "    C6_ITEM, "

	cQuery += "   (SELECT BE_CODCFG "
	cQuery += "    FROM " + RetSqlName("SBE") + " SBE "
	cQuery += "    WHERE BE_LOCAL = DB_LOCAL "
	cQuery += "    AND   BE_LOCALIZ = DB_LOCALIZ "
	cQuery += "    AND   SBE.D_E_L_E_T_ <> '*' "
	cQuery += "    AND   BE_FILIAL = '" + xFilial("SBE") + "') AS BE_CODCFG, "

	cQuery += "    DB_DOC, "
	cQuery += "    DB_PRODUTO, "
	cQuery += "    DB_QUANT, "
	cQuery += "    DB_CARGA, "
	cQuery += "    DB_LOCALIZ, "

	cQuery += "    B1_UM, "
	cQuery += "    B1_DESC, "
	cQuery += "    B1_PESO "

	cQuery += " FROM SDB010 SDB, SB1010 SB1, SC6010 SC6 "

	cQuery += " WHERE DB_SERVIC  = '001' "
	cQuery += " AND   DB_TM      > '500' "
	cQuery += " AND   DB_ESTORNO = ' ' "
//	cQuery += " AND   DB_ORIGEM = 'SC9' "

	cQuery += " AND   DB_DOC   BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQuery += " AND   DB_CARGA BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"

	cQuery += " AND   DB_PRODUTO = B1_COD "

	If MV_PAR05 <> 3
		cQuery += " AND C6_NOTA " + If(MV_PAR05 == 1, "= '' ", "<> '' ")
	EndIf

	cQuery += " AND   C6_NUM     = DB_DOC "
	cQuery += " AND   C6_ITEM    = DB_SERIE "
	cQuery += " AND   C6_PRODUTO = DB_PRODUTO "

	cQuery += " AND   SDB.D_E_L_E_T_ <> '*' "
	cQuery += " AND   SC6.D_E_L_E_T_ <> '*' "

	cQuery += " AND   DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += " AND   B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += " AND   C6_FILIAL = '" + xFilial("SC6") + "'"

	cQuery += " ORDER BY DB_LOCALIZ, DB_CARGA, DB_DOC, C6_ITEM "

	cQuery := ChangeQuery(cQuery)

    If Select(cAliasQry) <> 0
       dbSelectArea(cAliasQry)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS &cAliasQry

Return

Static Function RptDetail

	Local nLin    := 80
	Local cPicCFG := ""

	dbSelectArea(cAliasQry)
	dbGoTop()

	While !Eof()

		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
			nLin := 8
		EndIf

		@ nLin,000 PSay AllTrim((cAliasQry)->DB_PRODUTO)
		@ nLin,015 Psay Transform((cAliasQry)->DB_QUANT, '@E 999,999.99')

		@ nLin,030 PSay AllTrim((cAliasQry)->B1_UM)
		@ nLin,035 PSay Trim(SubStr((cAliasQry)->B1_DESC, 1, 60))

		@ nLin,085 PSay AllTrim((cAliasQry)->DB_DOC) + "/" + AllTrim((cAliasQry)->C6_ITEM)
		@ nLin,105 PSay If(AllTrim((cAliasQry)->C6_NOTA) <> "", AllTrim((cAliasQry)->C6_NOTA), "------")

		cPicCFG  := DLXPicEnd((cAliasQry)->BE_CODCFG)
		@ nLin,129 PSay AllTrim((cAliasQry)->DB_LOCALIZ) Picture cPicCFG

		nLin++
		nLin++

		dbSelectArea(cAliasQry)
		DbSkip()

	EndDo

	dbSelectArea(cAliasQry)
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool(wnrel) //Chamada do Spool de Impressao
	Endif

	MS_FLUSH() //Libera fila de relatorios em spool

Return .T.

Static Function Criar_Perg()

	cPerg := "AGX520"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Pedido De         ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Pedido Ate        ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Carga De          ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Carga Ate         ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Status            ?","mv_ch5","N",01,0,0,"C","","mv_par05","Não Faturados","","","Faturados","","","Todos","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	Pergunte(cPerg, .F.)

Return()