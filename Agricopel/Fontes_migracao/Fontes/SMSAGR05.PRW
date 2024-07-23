#Include "rwmake.ch" 
#Include "protheus.ch"  
#Include "Topconn.ch"  

  
User Function SMSAGR05(xPedidos)
 
	Local cQry 		:= ""
	Private nCol 	:= 0
	Private nCol1 	:= 20
	Private nCol2 	:= 400-150
	Private nCol3 	:= 1100-40
	Private nCol4 	:= 1300-80
	Private nCol5 	:= 1500-80
	Private nCol6 	:= 1800-80
	Private nCol7 	:= 2100-80	
	Private nQuebra := 3000
		
	Private nLin 	:= 30 
	Private aPedImp := {}     
	Private oFont1,oFont2,oFontC,oFontD,oPrn   
	Private nmax := 800
	Private Ncaixas  :=  0  
	Private nPage := 0; npageWidth := 200; nPageHeigth := 200; nWidth := 200; nHeigth := 200; nHeightPage := 200; nWidthPage := 200
	                    
	oFont1 := TFont():New( "Arial",,12,,.f.,,,,,.F.)
	oFont2 := TFont():New( "Arial",,13,,.T.,,,,,.F.)
	oFont3 := TFont():New( "Arial",,10,,.f.,,,,,.F.)
	
	oFontC := TFont():New( "Arial",,11,,.T.,,,,,.F.)
	oFontCb:= TFont():New( "Arial",,13,,.T.,,,,,.F.)
	oFontD := TFont():New( "Arial",,12,,.F.,,,,,.F.)
	oFont8 := TFont():New( "Arial",,9,,.F.,,,,,.F.)
	oFont10 := TFont():New("Arial",,10,,.F.,,,,,.F.)         
	    
	aPedImp := xPedidos

	cPedidos := ""
	For i := 1 to len(aPedImp)
		cPedidos += "'"+aPedImp[i][2]+"',"
		_cFilAnt := aPedImp[i][1]
	Next i             
	
	cPedidos := substr(cPedidos,1,len(cPedidos)-1)  
	cQuery := " SELECT CASE WHEN (C9_LOCAL = '20') THEN B1_XLOCAL4 ELSE (B1_XRUA+B1_XBLOCO+B1_XNIVEL+B1_XAPTO) END AS B1_XLOCAL1, C9_PEDIDO,B1_DESC,B1_UM,B1_XLOCAL2,B1_XLOCAL3,B1_XRUA,B1_XBLOCO,B1_XNIVEL,B1_XAPTO,C9_PRODUTO, C5_OBS,C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,SUM(C9_QTDLIB)AS C9_QTDLIB,C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_NOMECLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB,C5_XIMPRE FROM "+RetSqlName('SC9')+" SC9" 
	cQuery += " INNER JOIN "+RetSqlName('SC5')+" SC5 ON (C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ = '' AND SC5.C5_FILIAL = SC9.C9_FILIAL ) "	
	cQuery += " INNER JOIN "+RetSqlName('SB1')+" SB1 ON (B1_COD = C9_PRODUTO AND SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = SC9.C9_FILIAL ) "	
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6 ON (C9_PEDIDO = C6_NUM AND C6_ITEM = C9_ITEM AND C9_FILIAL = C6_FILIAL AND SC6.D_E_L_E_T_ = '' AND C9_PRODUTO = C6_PRODUTO ) "//LEANDRO 24.02.2016
	cQuery += " INNER JOIN "+RetSqlName('SF4')+" SF4 ON (F4_CODIGO = C6_TES AND F4_FILIAL = C6_FILIAL AND SF4.D_E_L_E_T_ = '') "//LEANDRO 24.02.2016

	cQuery += " Where "
	cQuery += " (C9_BLEST  = '' And C9_BLCRED = '') "//And C9_FILIAL ='" + xFilial("SC9") + "' "
	//cQuery += " AND C9_PEDIDO >=' " +mv_par01+ "' AND C9_PEDIDO <= '" +mv_par02+ "' " 
	cQuery += " And C9_DATALIB  >= '" +DTOS(mv_par03) + "' AND C9_DATALIB <= '" +DTOS(mv_par04)+ "' "   
	cQuery += " AND C9_LOCAL = '" +mv_par05+ "' "//AND C9_LOCAL <= '" + mv_par06 + "' " 	
	cQuery += "AND C9_PEDIDO IN ("+cPedidos+")"//'"+mv_par05+"' AND '"+mv_par06+"' "
	cQuery += " AND SC9.D_E_L_E_T_ = ''"
	If Alltrim(MV_PAR06) <> ""
		cQuery += " AND C5_TRANSP = '" +mv_par06+ "' "//AND C5_TRANSP <= '" + mv_par08 + "' " 	
	Endif 
	
	cQuery += " AND C9_FILIAL = '" + _cFilAnt + "'"// AND C9_FILIAL <='" + mv_par10 + "' " 
	//cQuery += " OR C9_PEDIDO = '402787' " //LEANDRO RETIRAR, TESTE
	
	//Leandro Spiller - 24/02/2016
	cQuery += " AND F4_ESTOQUE <> 'N' "  
	
		  
	cQuery += " GROUP BY B1_XLOCAL4, C9_LOCAL,B1_XLOCAL1,C9_PEDIDO,B1_DESC,B1_UM, B1_XLOCAL2,B1_XLOCAL3,B1_XRUA,B1_XBLOCO,B1_XNIVEL,B1_XAPTO,"
	cQuery += " C5_OBS, C5_NOMECLI, C5_XIMPRE, C9_PRODUTO, C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,C5_FILIAL,C5_NUM,"
 	cQuery += " C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB"
 	cQuery += " ORDER BY C9_PEDIDO,B1_XLOCAL1,B1_XRUA,B1_XBLOCO,B1_XNIVEL,B1_XAPTO,C9_PRODUTO " 
	         	 
	If (Select("ALA") <> 0)
		dbSelectArea("ALA")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "ALA"
	TCSETFIELD("ALA","C9_DATALIB" 		  ,"D",08,0)
	TCSETFIELD("ALA","C5_EMISSAO" 		  ,"D",08,0)


	cControla := ""//ALA->C9_PEDIDO
	nregs := 0      

	oPrn:= TMSPrinter():New()
	oPrn:Setup()

	dbSelectArea("ALA")
	ALA->(dbGoTop())
	Procregua(Reccount())
	
	While 	ALA->(!EOF())
    
		If nregs == 0  
			Cabec()
			ITEM()
			cControla := ALA->C9_PEDIDO
			nregs++ 
			oPrn:StartPage()     
		Endif      
          
		nLin := nLin+50
		oPrn:Say (0005+nLin+5, 0005+nCol1,ALLTRIM(ALA->C9_PRODUTO)  ,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0035+nCol2,ALLTRIM(ALA->B1_DESC) ,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0065+nCol3,ALA->B1_UM,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0065+nCol4,TRANSFORM(ALA->C9_QTDLIB,"@E 999,999.99")	/*PICTURE "@E 999,999.99"*/  ,oFont3,100,3) 
		oPrn:Say (0005+nLin+5, 0125+nCol5,ALA->B1_XLOCAL1/*ALA->B1_XRUA+ALA->B1_XBLOCO+ALA->B1_XNIVEL+ALA->B1_XAPTO*/ ,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0155+nCol6,ALA->B1_XLOCAL2  ,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0185+nCol7,ALA->B1_XLOCAL3  ,oFont3,100) 	
		    
		cControla := ALA->C9_PEDIDO
		ALA->(DbSkip())
		
		If  (ccontrola <>  ALA->C9_PEDIDO) .and. ALA->(!EOF())  
			 oPrn:EndPage() 
			 oPrn:StartPage() 
		     nLin 	:= 30
			 Cabec()
			 ITEM()
		Endif 
		
		//Quebra de página
		If nLin >= 3200  
			 oPrn:EndPage() 
			 oPrn:StartPage() 
		     nLin 	:= 30
			 Cabec()
			 ITEM()   
		Endif  
	
	Enddo 

	oPrn:EndPage() 
	oPrn:Preview() 
	MS_FLUSH()  
	
Return

       
Static Function Cabec()
	
	cNome    :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_NOME")
	cCid     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_MUN")
	cEst     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_EST")
	cDDD     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_DDD")
	cTEL     :=	Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_TEL")
	cBairro  := Posicione("SA1",1,xFilial("SA1")+ALA->C5_CLIENTE+ALA->C5_LOJACLI,"SA1->A1_BAIRRO")
		
	//Linha 1
	oPrn:Say (0005+nLin+5, 0030+nCol,"Pedido: " + ALA->C5_NUM ,oFont2,100)//;nLin := nLin+50  
	oPrn:Say (0005+nLin+5, 1930+nCol,"Data: " + DTOC(ALA->C5_EMISSAO) ,oFont1,100) //;nLin := nLin+50 
	oPrn:Say (0005+nLin+5, 0630+nCol,"Peso Total: " + AllTrim(Transform(GetPeso(ALA->C5_NUM), "@E 99,999,999.99")) + " KG" );nLin := nLin+50
    
	//linha 2
	oPrn:Say (0005+nLin+5, 0030+nCol,"Cliente: " + ALA->C5_CLIENTE + "/" + ALA->C5_LOJACLI + " - " + Alltrim(SubStr(cNome,1,32)) + " | " + Alltrim(cCid) + ' / ' + cEst)//;nLin := nLin+50
	oPrn:Say (0005+nLin+5, 1730+nCol,"Bairro: " + AllTrim(cBairro));nLin := nLin+50
	
	//Linha 3
	oPrn:Say (0005+nLin+5, 0030+nCol,"Fone       : " + cDDD + " " + cTEL);nLin := nLin+50 
	
	//Linha 4
	oPrn:Say (0005+nLin+5, 0030+nCol,"Obs: "+SUBSTR(ALA->C5_OBS,1,70));nLin := nLin+50
	
	
	oPrn:Say (0005+nLin+5, 0030+nCol,"Representantes: ");nLin := nLin+50
	oPrn:Say (0005+nLin+5, 0030+nCol,"    "+ALA->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+ALA->C5_VEND1,"A3_NREDUZ"));nLin := nLin+50
	
	If   alltrim(ALA->C5_VEND2 )<> ""
		oPrn:Say (0005+nLin+5, 0030+nCol,"    "+ALA->C5_VEND2 + " - " + Posicione("SA3",1,xFilial("SA3")+ALA->C5_VEND2,"A3_NREDUZ"));nLin := nLin+50		
	Endif
	
	If   alltrim(ALA->C5_VEND3 )<> ""
		oPrn:Say (0005+nLin+5, 0030+nCol,"    "+ALA->C5_VEND3 + " - " + Posicione("SA3",1,xFilial("SA3")+ALA->C5_VEND3,"A3_NREDUZ"));nLin := nLin+50
	Endif
	oPrn:Say (0005+nLin+5, 0030+nCol,"Transportadora: ");nLin := nLin+50
	oPrn:Say (0005+nLin+5, 0030+nCol,"    "+ALA->C5_TRANSP + " - " + Posicione("SA4",1,xFilial("SA4")+ALA->C5_TRANSP,"A4_NREDUZ"));nLin := nLin+50

Return

Static Function ITEM()
                                                                   
	
	oPrn:line(0005+nLin+5, 0005+nCol1,0005+nLin+5  ,0185+nCol7+250); nLin := nLin+10 
	                  
	oPrn:Say (0005+nLin+5, 0005+nCol1,"PRODUTO"  ,oFont3,100) 
	oPrn:Say (0005+nLin+5, 0035+nCol2,"DESCRICAO"  ,oFont3,100) 
	oPrn:Say (0005+nLin+5, 0065+nCol3,"UM" ,oFont3,100) 
	oPrn:Say (0005+nLin+5, 0095+nCol4,"QTDE"  ,oFont3,100,3) 
	oPrn:Say (0005+nLin+5, 0125+nCol5,"ENDERECO1" ,oFont3,100) 
	oPrn:Say (0005+nLin+5, 0155+nCol6,"ENDERECO2"  ,oFont3,100) 
	oPrn:Say (0005+nLin+5, 0185+nCol7,"ENDERECO3"  ,oFont3,100)  
   
	nLin := nLin+45

	oPrn:line(0005+nLin+5, 0005+nCol1,0005+nLin+5  ,0185+nCol7+250) 
Return


Static Function GetPeso(NrPed)

	Local cQryPeso := ""
	Local cAlias   := GetNextAlias()
	Local nPeso    := 0

	cQryPeso += " SELECT SUM(C6_QTDVEN * COALESCE(B1_PESO,0)) AS PESO "
	cQryPeso += " FROM " + RetSQLName("SC6") + " SC6, " + RetSQLName("SB1") + " SB1 "
	cQryPeso += " WHERE C6_PRODUTO = B1_COD "
	cQryPeso += " AND   C6_FILIAL  = B1_FILIAL "
	cQryPeso += " AND   SC6.D_E_L_E_T_ <> '*' "
	cQryPeso += " AND   SB1.D_E_L_E_T_ <> '*' "
	cQryPeso += " AND   C6_NUM = '" + NrPed + "'" 
	cQryPeso += " AND   C6_FILIAL = '" + xFilial("SC6") + "'"

	If Select(cAlias) <> 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif
	
	cQryPeso := ChangeQuery(cQryPeso)
	TCQuery cQryPeso NEW ALIAS &cAlias

	nPeso := (cAlias)->PESO

	If Select(cAlias) <> 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif

Return(nPeso)
