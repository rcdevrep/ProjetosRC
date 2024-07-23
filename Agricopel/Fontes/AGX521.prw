#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"

User Function AGX521(aCargas)

	Local oPrn      := TMSPrinter():New("Informacoes despacho de pedido")
	Local oFont     := TFont():New("Arial Black",50,50,,.T.,,,,.T.,.F.)
	Local oFont2    := TFont():New("Arial Black",80,80,,.T.,,,,.T.,.F.)

	Local cArqTrab  := ""
	Local cCargas   := ""
	Local _nX       := 0
	Local cAliasTRB := GetNextAlias()

	oPrn:SetPage(9)
	lAbortPrint := .F.

	For _nX := 1 to Len(aCargas)

		if AllTrim(cCargas) <> ""
			cCargas += ","
		Endif

		cCargas += "'" + aCargas[_nX] + "'"
	End

	cQuery := ""
	cQuery += " SELECT "

	cQuery += "   DISTINCT(DB_CARGA), "
	cQuery += "   SUBSTRING(DB_LOCALIZ,1,3) AS RUA, "

	cQuery += "   (SELECT TOP 1 A1_NREDUZ "
	cQuery += "    FROM " + RetSQLName("SA1") + " SA1 "

	cQuery += "    WHERE SA1.A1_COD    = SDB.DB_CLIFOR "
	cQuery += "    AND   SA1.A1_LOJA   = SDB.DB_LOJA "
	cQuery += "    AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += "    AND   SA1.D_E_L_E_T_ <> '*') AS CLIENTE "

	cQuery += " FROM " + RetSQLName("SDB") + " SDB "

	cQuery += " WHERE DB_FILIAL = '" + xFilial("SDB") + "' "
	cQuery += " AND   DB_SERVIC = '001' "
	cQuery += " AND   DB_TM     > '500' "
	cQuery += " AND   DB_ATUEST = 'N' "
	cQuery += " AND   DB_CARGA IN (" + cCargas + ")"

	cQuery += " AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += " ORDER BY DB_CARGA, RUA "

	cQuery := ChangeQuery(cQuery)

    If Select(cAliasTRB) <> 0
       dbSelectArea(cAliasTRB)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS &cAliasTRB

	While !Eof()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

	    nLin := GPixel(01)

     	oPrn:Say(nLin,GPixel(01),"Carga: " + AllTrim((cAliasTRB)->DB_CARGA),oFont)
		nLin+=GPixel(30)

     	oPrn:Say(nLin,GPixel(01),"Rua: " + AllTrim((cAliasTRB)->RUA),oFont)
		nLin+=GPixel(15)

		oPrn:Say(nLin,GPixel(01),REPLICATE("-", 32),oFont2)
		nLin+=GPixel(25)

     	oPrn:Say(nLin,GPixel(01),SUBSTR(AllTrim((cAliasTRB)->CLIENTE),1,15),oFont2)
		nLin+=GPixel(30)

	   	oPrn:Say(nLin,GPixel(01),SUBSTR(AllTrim((cAliasTRB)->CLIENTE),16,15),oFont2)
		nLin+=GPixel(15)

		oPrn:Say(nLin,GPixel(01),REPLICATE("-", 32),oFont2)
		nLin+=GPixel(25)

     	oPrn:Say(nLin,GPixel(01),"Carga: " + AllTrim((cAliasTRB)->DB_CARGA),oFont)
		nLin+=GPixel(30)

     	oPrn:Say(nLin,GPixel(01),"Rua: " + AllTrim((cAliasTRB)->RUA),oFont)

		oPrn:EndPage()
		(cAliasTRB)->(dbSkip())
	EndDo

	oPrn:SetLandscape()
	oPrn:Preview()

    If Select(cAliasTRB) <> 0
       dbSelectArea(cAliasTRB)
   	   dbCloseArea()
    Endif

Return

Static Function GPixel(_nMm) // Transforma Pixel p Milimetro
	_nRet := (_nMm/25.4) * 300
Return(_nRet)