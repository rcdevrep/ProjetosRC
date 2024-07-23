#INCLUDE "rwmake.ch" 
#INCLUDE "PROTHEUS.CH" 

User Function AGX407(cPedidos)                             

	cPerg:= "AGX407"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Pedido de  ?","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Pedido ate ?","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
//	AADD(aRegistros,{cPerg,"03","Data     ?","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
//	AADD(aRegistros,{cPerg,"04","Data ate   ?","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})

//	U_CriaPer(cPerg,aRegistros)

        
	if AllTrim(cPedidos) == ""
		Pergunte(cPerg,.T.)
	Else 
//		Pergunte(cPerg,.F.)
	Endif

	cDEscFun:= ""
	cLocTrab:= ""
	nMarc   := 0
	nTamPag     := 2794 //GetAdvFval("SX5","X5_DESCRI",xFilial("SX5")+"Z2"+MV_PAR05,1)*10
	//nLin     := MV_PAR06*100
	//nMargEsq:= MV_PAR07*100
	//nMargDir:= MV_PAR08*100
	//nMargInf:= MV_PAR09*100
	//cCumpEtq:= MV_PAR10*100
	//nLimite := nTamPag - nMargInf

	oPrn:=TMSPrinter():New("Informacoes despacho de pedido")
	oFont   := TFont():New("Arial Black",50,50,,.T.,,,,.T.,.F.)   
	oFont2   := TFont():New("Arial Black",80,80,,.T.,,,,.T.,.F.)   
	oPrn:SetPage(9)
	lAbortPrint := .F.                                      
	
	cQuery:= "SELECT C5_NUM,C5_CLIENTE,C5_LOJACLI,A1_NREDUZ,A1_MUN,A1_EST ,A4_NREDUZ, A1_BAIRRO ,A1_LOJA FROM " + RetSqlName("SC5") + " C5, " + RetSqlName("SA1") + " A1, "  + RetSqlName("SA4") + " A4 "
	cQuery+= "WHERE A1.A1_COD  = C5.C5_CLIENTE "
	cQuery+= " AND A1.A1_LOJA = C5.C5_LOJACLI "
	cQuery+= " AND A1.D_E_L_E_T_ <> '*' "
	cQuery+= " AND C5.D_E_L_E_T_ <> '*' "
	cQuery+= " AND A4.D_E_L_E_T_ <> '*' "
	cQuery+= " AND A4.A4_COD =  C5.C5_TRANSP "
	cQuery+= " AND C5_FILIAL = '" + xFilial("SC5") + "'" 

	if AllTrim(cPedidos) == ""
		cQuery += " AND C5_NUM BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "  
	Else 
		cQuery += " AND C5_NUM IN (" + cPedidos + ")"
    Endif

	cQuery += " ORDER BY C5_NUM "

	if select("TMP") <> 0
		Dbselectarea("TMP")
		dbCloseArea()
	endif

	dbuseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), "TMP", .T., .F. )

	While !eof()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
	   
	    nLin     := GPixel(01)
	    
		//		If nLin >= GPixel(100) // 
		//	      oPrn:EndPage()
		//		   nLin     := GPixel(10)
		//		Endif

		//nMarc = nLin

     	oPrn:Say(nLin,GPixel(01),ALLTRIM(TMP->A1_MUN),oFont)
     //	oPrn:Say(nLin,GPixel(01),"12345678901234567890123456789012345678901234567890",oFont)
		nLin+=GPixel(30)                                                 

     	oPrn:Say(nLin,GPixel(01),ALLTRIM(TMP->A1_BAIRRO),oFont)
		nLin+=GPixel(15) 
		
		
		oPrn:Say(nLin,GPixel(01),REPLICATE("-", 32),oFont2)
		nLin+=GPixel(25) 

		
     	oPrn:Say(nLin,GPixel(01),SUBSTR(ALLTRIM(TMP->A1_NREDUZ),1,16),oFont2)
		nLin+=GPixel(30)   


	   	oPrn:Say(nLin,GPixel(01),SUBSTR(ALLTRIM(TMP->A1_NREDUZ),17,16),oFont2)
		nLin+=GPixel(15)   

		oPrn:Say(nLin,GPixel(01),REPLICATE("-", 32),oFont2)
		nLin+=GPixel(25) 
		
		
//   	oPrn:Say(nLin,GPixel(01),"LOJA: " + ALLTRIM(TMP->A1_LOJA)) //+ " PEDIDO: " + ALLTRIM(TMP->C5_NUM) ,oFont2) 
//		nLin+=GPixel(30)       
	   
	   	oPrn:Say(nLin,GPixel(01),"PEDIDO: " + ALLTRIM(TMP->C5_NUM) ,oFont) 
		nLin+=GPixel(30)   
     	
		oPrn:Say(nLin,GPixel(01),"TR:" + SUBSTR(ALLTRIM(TMP->A4_NREDUZ),1,10) ,oFont) 
     	
		oPrn:EndPage()	
		TMP->(dbSkip())                                                        
	enddo                                                                     
	
oPrn:SetLandscape()
oPrn:Preview()

Return

Static Function GPixel(_nMm) // Transforma Pixel p Milimetro
	_nRet := (_nMm/25.4) * 300
Return(_nRet)