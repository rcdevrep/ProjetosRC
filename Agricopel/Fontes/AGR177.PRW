#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR171  ³ Autor ³ Deco                  ³ Data ³ 06/06/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para buscar ultimo preco de compra pedido  compras ´±± 
±±³          ³ Chamado pelo gatilho do campo C7_PRODUTO
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR177()

	nPosPro     := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRODUTO"})
	nPosTot     := aScan(aHeader,{|x| alltrim(x[2])=="C7_TOTAL"})
	nPosPre     := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRECO"})
	nPosPrecoT  := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRECOT"})

	cProduto    := aCols[N,nPosPro]
    nC7_PRECO   := aCols[N,nPosPre]
    nC7_PRECOT  := aCols[N,nPosPrecoT]

    If SM0->M0_CODIGO = "01" .And. (Alltrim(SM0->M0_CODFIL) == '01' .Or. Alltrim(SM0->M0_CODFIL) == '02' .OR. Alltrim(SM0->M0_CODFIL) == "06") // Agricopel Matriz // Pien // Atacado             
    
    	cQuery := " SELECT D1_COD ND1_COD, "
		cQuery += "        D1_DTDIGIT ND1_DTDIGIT, "
		cQuery += "        D1_VUNIT  ND1_VUNIT, "
		cQuery += "        D1_VALICM ND1_VALICM, "
		cQuery += "        D1_VALIPI ND1_VALIPI, "
		cQuery += "        D1_ICMSRET ND1_ICMSRET, "
		cQuery += "        D1_QUANT ND1_QUANT"
		
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK), " + RetSqlName("SF1") + " SF1 (NOLOCK) "
	
		cQuery += " WHERE D1_FILIAL      = '" + xFilial("SD1") + "'"
		cQuery += " AND   SD1.D_E_L_E_T_ = '' "
		cQuery += " AND   SF1.D_E_L_E_T_ = '' "
		cQuery += " AND   D1_TIPO        = 'N' "
	
		cQuery += " AND   D1_DOC     = F1_DOC "
		cQuery += " AND   D1_SERIE   = F1_SERIE "
		cQuery += " AND   D1_FILIAL  = F1_FILIAL "
		cQuery += " AND   D1_FORNECE = F1_FORNECE "
		cQuery += " AND   D1_TIPO    = F1_TIPO "
		cQuery += " AND   D1_EMISSAO = F1_EMISSAO "
		cQuery += " AND   D1_COD     = '"+cPRODUTO+"' "
	
		cQuery += " AND   F1_STATUS = 'A' "
	
		cQuery += " ORDER BY D1_COD, D1_DTDIGIT DESC, SD1.R_E_C_N_O_ "   

/*S		cQuery := "SELECT D1_VUNIT AS ND1_VUNIT, D1_ICMSRET AS ND1_ICMSRET, D1_QUANT AS ND1_QUANT "
		cQuery += "FROM "+RetSqlName("SD1")+" (NOLOCK) "
		cQuery += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND D_E_L_E_T_ = '' "
		cQuery += "AND D1_COD  = '"+cPRODUTO+"' "
		cQuery += "AND D1_TIPO = 'N' "
		cQuery += "ORDER BY D1_DTDIGIT  DESC "  */
	
		If (Select("MD1") <> 0)
			dbSelectArea("MD1")
			dbCloseArea()
		Endif
	
		TCQuery cQuery NEW ALIAS "MD1"
	
		DbSelectArea("MD1")
	
	 	If MD1->ND1_VUNIT > 0 //.And. nC7_PRECO == 0
	  		//nC7_PRECOT  := NoRound((MD1->ND1_VUNIT+(MD1->ND1_ICMSRET/MD1->ND1_QUANT)),2) // Acrescenta icms retido qdo houver cfe Ademir 21/06/2005
	  		nC7_PRECOT  := NoRound((MD1->ND1_VUNIT+((MD1->ND1_ICMSRET + MD1->ND1_VALIPI) / MD1->ND1_QUANT)),2)
	  		nC7_PRECO   := MD1->ND1_VUNIT
	  	EndIf          
	
		aCols[N,nPosPrecoT] := nC7_PRECOT      // Retorna ao campo C7_PRECOT o valor
	
		dbSelectArea("MD1")
		dbCloseArea()

	EndIf

Return nC7_PRECO  // Retorna ao campo C7_PRECO o valor