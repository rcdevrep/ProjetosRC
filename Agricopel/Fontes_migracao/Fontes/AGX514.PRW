#INCLUDE "TOPCONN.CH"
#INCLUDE "FIVEWIN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ AGX514 ³ Autor ³ Leandro F Silveira      ³Data  ³26/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressão de Separação por Carga                           ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function AGX514(aCargas)

	Private cAliasQry  := ""
	Private aImprime   := {}

	Private nQtdeItens := 0
	Private nTotalQtde := 0
	Private nPesoTotal := 0
	Private lEnd       := .F.// Controle de cancelamento do relatorio

	CONTFL      	:= 01
	m_pag       	:= 01
	nLin            := 80
	Cabec1          := ""
    Cabec2          := ""
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo imprimir ")
	cDesc2        	:= OemToAnsi("mapas de separação por carga ")
	cDesc3        	:= ""
	cPict         	:= ""
	aOrd 			:= ""
	Tamanho         := "G"
	NomeProg        := "AGX514"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	Wnrel       	:= "AGX514"
	aRegistros  	:= {}
	cPerg		    := "AGX514"
	cString 	   	:= ""
	Titulo  	    := "Mapa de Separação por Carga"
	aRegistros      := {}
	cAliasQry       := GetNextAlias()
	limite          := 132

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

	Processa({|| GeraDados(aCargas) })
	RptStatus({|| RptDetail() })

Return

Static Function GeraDados(aCargas)

	Local cCargas := ""
	Local iX      := 0

	For iX := 1 to Len(aCargas)
		cCargas += If(AllTrim(cCargas) <> "", ",", "") + "'" + aCargas[iX] + "'"
	Next iX

	cQuery := ""
	cQuery += "  SELECT "

	cQuery += "     DB_DOC, "
	cQuery += "     DB_LOCALIZ, "
	cQuery += "     SUBSTRING(DB_LOCALIZ,1,3) AS END_QUEBRA, "
	cQuery += "     DB_PRODUTO, "
	cQuery += "     DB_QUANT, "
	cQuery += "     DB_CARGA, "

	cQuery += "     (SELECT BE_CODCFG "
	cQuery += "      FROM " + RetSqlName("SBE") + " SBE "
	cQuery += "      WHERE BE_LOCAL       = DB_LOCAL "
	cQuery += "      AND   BE_LOCALIZ     = DB_LOCALIZ "
	cQuery += "      AND   SBE.D_E_L_E_T_ <> '*' "
	cQuery += "      AND   BE_FILIAL      = '" + xFilial("SBE") + "') AS BE_CODCFG, "

	cQuery += "     (SELECT TOP 1 A1_NOME "
	cQuery += "      FROM " + RetSqlName("SA1") + " SA1, " + RetSqlName("SDB") + " SDB_SUB "
	cQuery += "      WHERE A1_COD             = SDB_SUB.DB_CLIFOR "
	cQuery += "      AND   A1_LOJA            = SDB_SUB.DB_LOJA "
	cQuery += "      AND   SDB_SUB.DB_FILIAL  = SDB.DB_FILIAL "
	cQuery += "      AND   SDB_SUB.DB_DATA    = SDB.DB_DATA "
	cQuery += "      AND   SDB_SUB.DB_CARGA   = SDB.DB_CARGA "
	cQuery += "      AND   SDB_SUB.DB_CLIFOR  <> '' "
	cQuery += "      AND   SDB_SUB.D_E_L_E_T_ <> '*') AS CLIENTE, "

	cQuery += "     B1_UM, "
	cQuery += "     B1_DESC, "
	cQuery += "     B1_PESO "

	cQuery += "  FROM " + RetSqlName("SDB") + " SDB, " + RetSqlName("SB1") + " SB1 "

	cQuery += "  WHERE DB_SERVIC = '001' "
	cQuery += "  AND   DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "  AND   B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "  AND   DB_PRODUTO = B1_COD "

	cQuery += "  AND   DB_CARGA IN (" + cCargas + ")"

	cQuery += "  AND   SDB.D_E_L_E_T_ <> '*' "
	cQuery += "  AND   SB1.D_E_L_E_T_ <> '*' "

	cQuery += "  AND   SDB.DB_SERVIC  = '001' "
	cQuery += "  AND   SDB.DB_TM      > '500' "
	cQuery += "  AND   SDB.DB_ESTORNO = ' ' "
	cQuery += "  AND   SDB.DB_ATUEST  = 'N' "

	cQuery += "  ORDER BY DB_CARGA, DB_LOCALIZ, B1_DESC "

	cQuery := ChangeQuery(cQuery)

    If Select(cAliasQry) <> 0
       dbSelectArea(cAliasQry)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS &cAliasQry

Return

Static Function RptDetail

	Local cPicCFG := ""
	Local nPesoTotItem := 0

	Local cUltCarga := ""
	Local cUltEnder := ""

	Private nQtdeItens := 0
	Private nTotalQtde := 0
	Private nPesoTotal := 0

	Private nTotPag    := 0
	Private nNumPag    := 1

	nTotPag := CalcPag()

	CabRod(.T., .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()

		If AllTrim(cUltCarga) <> "" .And. (AllTrim(cUltCarga) <> AllTrim((cAliasQry)->DB_CARGA) .Or. AllTrim(cUltEnder) <> AllTrim((cAliasQry)->END_QUEBRA))
			CabRod(.T., .T., .T.)
		EndIf

		If nLin > 55
			CabRod(.T., .F., .F.)
		EndIf

		cPicCFG := DLXPicEnd((cAliasQry)->BE_CODCFG)
	    nPesoTotItem := Round((cAliasQry)->B1_PESO, 2) * Round((cAliasQry)->DB_QUANT, 2)

		@ nLin,000 PSay (cAliasQry)->DB_LOCALIZ Picture cPicCFG
		@ nLin,022 PSay AllTrim((cAliasQry)->DB_PRODUTO)
		@ nLin,036 Psay Transform((cAliasQry)->DB_QUANT, '@E 999,999.99')

		@ nLin,052 PSay AllTrim((cAliasQry)->B1_UM)
		@ nLin,057 PSay Trim(SubStr((cAliasQry)->B1_DESC, 1, 60))

		@ nLin,106 PSay Transform(Round((cAliasQry)->B1_PESO, 2), '@E 999,999.9999')
		@ nLin,120 PSay Transform(nPesoTotItem, '@E 999,999.9999')
		@ nLin,137 PSay AllTrim((cAliasQry)->DB_DOC)
		@ nLin,152 PSay Replicate("_", 40)

		nPesoTotal += Round(nPesoTotItem, 2)
		nTotalQtde += Round((cAliasQry)->DB_QUANT, 2)
		nQtdeItens++

		nLin++
		nLin++

		cUltCarga := (cAliasQry)->DB_CARGA
		cUltEnder := (cAliasQry)->END_QUEBRA

		dbSelectArea(cAliasQry)
		DbSkip()

	Enddo

	CabRod(.F., .T., .F.)

	dbSelectArea(cAliasQry)
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool(wnrel) //Chamada do Spool de Impressao
	Endif

	MS_FLUSH() //Libera fila de relatorios em spool

Return .T.
              
Static Function CabRod(lCabec, lRodap, lSepConf)

	Local cEscrita := ""

	Cabec1 := "Cliente: " + PadR((cAliasQry)->CLIENTE,196," ") + "Página " + PadL(AllTrim(Str(nNumPag)),3,"0") + "/" + PadL(AllTrim(Str(nTotPag)),3,"0")
	Cabec2 := "Endereco Origem       Cod.Prod           Quant      UN   Descricao                                         Peso Unit.   Peso Total       Pedido         Anormalidades"
	Titulo := "Mapa de Separação por Carga - Nr: " + (cAliasQry)->DB_CARGA

	If lRodap
		nLin += 2
		@ nLin,000 PSay "Totais -->     Qtde Itens: " + Transform(nQtdeItens, '@E 999,999.99') + "     Qtde Total: " + Transform(nTotalQtde, '@E 999,999.99') + "     Peso Total: " + Transform(nPesoTotal, '@E 999,999.9999')
		nLin += 4

		nQtdeItens := 0
		nTotalQtde := 0
		nPesoTotal := 0
	EndIf

	If lCabec
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
		nLin := 9
		nNumPag++

		If lSepConf
			cEscrita := " " + Replicate("_", 50) + Replicate(" ", 5) + Replicate("_", 5) + ":" + Replicate("_", 5)
			cEscrita += Replicate(" ", 5) + Replicate("_", 5) + ":" + Replicate("_", 5)

			@ nLin,000 PSay "Separador :" + cEscrita + Replicate(" ", 5) + "Conferente :" + cEscrita
			nLin += 2
			@ nLin,000 PSAY __PrtFatLine()
			nLin += 2
		EndIf
	EndIf

Return .T.

Static Function CalcPag()

	Local nTotPaginas := 1
	Local nLinha      := 13
	Local cUltCarga   := ""
	Local cUltEnder   := ""

	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()

		If AllTrim(cUltCarga) <> "" .And. (AllTrim(cUltCarga) <> AllTrim((cAliasQry)->DB_CARGA) .Or. AllTrim(cUltEnder) <> AllTrim((cAliasQry)->END_QUEBRA))
			nTotPaginas += 1
			nLinha      := 13
		EndIf
		
		If nLinha > 55
			nTotPaginas += 1
			nLinha      := 9
		EndIf

		nLinha += 2

		cUltCarga := (cAliasQry)->DB_CARGA
		cUltEnder := (cAliasQry)->END_QUEBRA

		dbSelectArea(cAliasQry)
		DbSkip()

	Enddo

	dbSelectArea(cAliasQry)
	dbGoTop()

Return nTotPaginas