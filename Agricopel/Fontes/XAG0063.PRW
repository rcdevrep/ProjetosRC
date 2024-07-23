#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} XAG0063
//Função de Impressão de Separação por Carga, substitui a f8unção AGX514
@author Leandro Spiller
@since 09/01/2020
@version 1 
@param aCargas, cargas que serão impressas 
@type function
/*/
User Function XAG0063(aCargas)

	Private aImprime   := {}
	Private nQtdeItens := 0
	Private nTotalQtde := 0
	Private nPesoTotal := 0
	Private lEnd       := .F.// Controle de cancelamento do relatorio
	Private oPrn
	Private cFile := 'XAG0063'
	Private oFont12 := TFont():New( "Courier New"    ,,08,,.T.,,,,,.f. ) 
	Private oFont10 := TFont():New( "Courier New"    ,,08,,.T.,,,,,.f. ) 
	Private oFont16 := TFont():New( "Courier New"    ,,11,,.T.,,,,,.f. ) 
	Private cAliasQry       := GetNextAlias()
	Private nAjusCol  := 50
	//aCargas := {} 
	//AADD(aCargas, "034948   ")
	//AADD(aCargas, "021551   ")

	Processa({|| GeraDados(aCargas) })
	MsgRun("    Gerando Impressão do Mapa ... ","Mapa de Separação",{||  Imprime()}) 

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

    If Select(cAliasQry) <> 0
       dbSelectArea(cAliasQry)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS &cAliasQry

Return

Static Function Imprime()

	Local cPicCFG := ""
	Local nPesoTotItem := 0

	Local cUltCarga := ""
	Local cUltEnder := ""
	//Local I := 0 
	//Local limpteste := .F.
	Private nQtdeItens := 0
	Private nTotalQtde := 0
	Private nPesoTotal := 0

	Private nTotPag    := 0
	Private nNumPag    := 1
	Private nLin       := 0 
	//Private nLastKey   := 0

	//oPrn  := FWMSPrinter():New(cFile             ,6          ,.T.                ,                 ,.F.             ,             ,               ,             ,            ,            ,        ,     .T.    ,        )
							//( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] ) 
	oPrn := TMSPrinter():New()	
	oPrn:SetLandscape()
	oPrn:SetPaperSize(9)

	oPrn:StartPage() 

	nTotPag := CalcPag()

	CabRod(.T., .F., .T.,.T.)

	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()

		If AllTrim(cUltCarga) <> "" .And. (AllTrim(cUltCarga) <> AllTrim((cAliasQry)->DB_CARGA) .Or. AllTrim(cUltEnder) <> AllTrim((cAliasQry)->END_QUEBRA))
			CabRod(.T., .T., .T., .F.)
		EndIf

		//Querbra de página
		If nLin > 2140
			nLin += 45
			oPrn:Say(nLin,060 , ' **************** CONTINUA NA PRÓXIMA PÁGINA ************** ',oFont12,100)
			CabRod(.T., .F., .F., .F.)
		EndIf
		
		cPicCFG := DLXPicEnd((cAliasQry)->BE_CODCFG)
	    nPesoTotItem := Round((cAliasQry)->B1_PESO, 2) * Round((cAliasQry)->DB_QUANT, 2)

		oPrn:Say(nLin,060 , (cAliasQry)->DB_LOCALIZ /*Picture cPicCFG*/,oFont12,100)
		oPrn:Say(nLin,270 + nAjusCol , AllTrim((cAliasQry)->DB_PRODUTO) /*+ ' -> '+alltrim(str(nLin))*/,oFont12,100)
		oPrn:Say(nLin,480 + nAjusCol + 20, Transform((cAliasQry)->DB_QUANT, '@E 999,999.99'),oFont12,100)

		oPrn:Say(nLin,700 + nAjusCol + 20, AllTrim((cAliasQry)->B1_UM),oFont12,100)
		oPrn:Say(nLin,0800 + nAjusCol + 20, Trim(SubStr((cAliasQry)->B1_DESC, 1, 60)),oFont12,100)

		oPrn:Say(nLin,1650 + nAjusCol + 20, Transform(Round((cAliasQry)->B1_PESO, 2), '@E 999,999.9999'),oFont12,100)
		oPrn:Say(nLin,1850 + nAjusCol + 20, Transform(nPesoTotItem, '@E 999,999.9999'),oFont12,100)
		oPrn:Say(nLin,2100 + nAjusCol + 20, AllTrim((cAliasQry)->DB_DOC),oFont12,100)
		oPrn:Say(nLin,2300 + nAjusCol + 20, Replicate("_", 40),oFont12,100)
		nPesoTotal += Round(nPesoTotItem, 2)
		nTotalQtde += Round((cAliasQry)->DB_QUANT, 2)
		nQtdeItens++

		nLin += 45
		nLin += 45 

		cUltCarga := (cAliasQry)->DB_CARGA
		cUltEnder := (cAliasQry)->END_QUEBRA

		dbSelectArea(cAliasQry)
		DbSkip()

	Enddo

	CabRod(.F., .T., .F., .F.)

	dbSelectArea(cAliasQry)
	dbCloseArea()
	oPrn:EndPage()

	oPrn:Preview()
	//SetPgEject(.F.)
	//MS_Flush()  

	//If nLastKey == 27
	//	Return
	//Endif   
	
	/*If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool(wnrel) //Chamada do Spool de Impressao
	Endif

	MS_FLUSH() //Libera fila de relatorios em spool
	*/
Return .T.
              
Static Function CabRod(lCabec, lRodap, lSepConf, lFirst)

	Local cEscrita := ""
	

	Cabec1 := "Cliente: " + PadR((cAliasQry)->CLIENTE,160," ") + "Página " + PadL(AllTrim(Str(nNumPag)),3,"0") + "/" + PadL(AllTrim(Str(nTotPag)),3,"0")
	//Cabec2 := "Endereco Origem       Cod.Prod           Quant      UN   Descricao                                         Peso Unit.   Peso Total       Pedido         Anormalidades"
	cTitulo := "Mapa de Separação por Carga - Nr: " + (cAliasQry)->DB_CARGA

	If lRodap
		nLin += 45
		oPrn:Say(nLin,050 , "Totais -->     Qtde Itens: " + Transform(nQtdeItens, '@E 999,999.99') + "     Qtde Total: " + Transform(nTotalQtde, '@E 999,999.99') + "     Peso Total: " + Transform(nPesoTotal, '@E 999,999.9999'),oFont12,100)
		nLin += 80

		nQtdeItens := 0
		nTotalQtde := 0
		nPesoTotal := 0
	EndIf

	iF !lFirst .and. !(cAliasQry)->(Eof())
		oPrn:EndPage() 
		oPrn:StartPage() 
	EndIf

	If lCabec
	
		nLin := 170
		nNumPag++
		oPrn:Say(nLin - 25,1200,	cTitulo,oFont16,100)
		oPrn:Say(nLin - 20 ,060,	'Data: '+dtoc(Date()),oFont10,100)
		oPrn:Say(nLin + 5 ,060,	'Hora: '+Time(),oFont10,100)
		oPrn:Say(nLin+10,060 , Replicate("_", 187),oFont10,100) 
		nLin += 50
		oPrn:Say(nLin,060, Cabec1,oFont12,100)
		nLin += 50
		If lSepConf
			cEscrita := " " + Replicate("_", 40) + Replicate(" ", 4) + Replicate("_", 4) + ":" + Replicate("_", 4)
			cEscrita += Replicate(" ", 4) + Replicate("_", 4) + ":" + Replicate("_", 4)

			oPrn:Say(nLin,060 , "Separador :" + cEscrita + Replicate(" ", 5) + "Conferente :" + cEscrita,oFont12,100)  
			nLin += 50
			oPrn:Say(nLin,060 , Replicate("_", 187),oFont10,100)  
			nLin += 50
		EndIf

		oPrn:Say(nLin,060 , 'Endereço',oFont12,100)
		oPrn:Say(nLin,270 + nAjusCol, 'Cod.Prod',oFont12,100)
		oPrn:Say(nLin,480 + nAjusCol + 20, '     Quant.',oFont12,100)

		oPrn:Say(nLin,700  + nAjusCol + 20, 'UM',oFont12,100)
		oPrn:Say(nLin,0800 + nAjusCol + 20 , 'Descrição',oFont12,100)

		oPrn:Say(nLin,1650 + nAjusCol + 20, '  Peso Unit.',oFont12,100)
		oPrn:Say(nLin,1850 + nAjusCol + 20, '  Peso Total',oFont12,100)
		oPrn:Say(nLin,2100 + nAjusCol + 20, 'Pedido',oFont12,100)
		oPrn:Say(nLin,2300 + nAjusCol + 20, 'Anormalidades',oFont12,100)
		nLin += 60
	EndIf

Return .T.

Static Function CalcPag()

	Local nTotPaginas := 1
	Local nLinha      := 430//340 + 80
	Local cUltCarga   := ""
	Local cUltEnder   := ""

	dbSelectArea(cAliasQry)
	dbGoTop()

	While !Eof()

		If AllTrim(cUltCarga) <> "" .And. (AllTrim(cUltCarga) <> AllTrim((cAliasQry)->DB_CARGA) .Or. AllTrim(cUltEnder) <> AllTrim((cAliasQry)->END_QUEBRA))
			//CabRod(.T., .T., .T., .F.)
			nTotPaginas += 1
			nLinha      := 430 //585//340 + 80
		EndIf

		//Querbra de página
		If nLinha > 2140
			//CabRod(.T., .F., .F., .F.)
			nLinha      := 330//190 + 80
			nTotPaginas += 1
		EndIf
		nLinha += 45
		nLinha += 45 

		cUltCarga := (cAliasQry)->DB_CARGA
		cUltEnder := (cAliasQry)->END_QUEBRA

		dbSelectArea(cAliasQry)
		DbSkip()

	Enddo

	dbSelectArea(cAliasQry)
	dbGoTop()

Return nTotPaginas