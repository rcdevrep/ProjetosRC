#Include "rwmake.ch" 
#Include "protheus.ch"  
#Include "Topconn.ch"  

// ROTINA JA VERIFICADA VIA XAGLOGRT

User Function SMSAGR05(xPedidos)
 
	Local cQuery    := ""
	Local cAliasQry := ""
	Local i         := 0

	Private nCol 	:= 0
	Private nCol1 	:= 20
	Private nCol2 	:= 250//400-150
	Private nCol3 	:= 1230//1150 + 40 + 30 + 10 //1100-40
	Private nCol4 	:= 1315//1300-80 + 20 + 30 +30 + 10 + 5 
	Private nCol5 	:= 1480//1500-80 + 20 + 10 + 20 +10
	Private nCol6 	:= 1710//1730//1800-80 + 10
	Private nCol7 	:= 1980//2005//2100-95  	
	Private nQuebra := 3000
		
	Private nLin 	:= 30 
	Private aPedImp := {}     
	Private nmax    := 800
	Private Ncaixas :=  0  
	Private nPage   := 0; npageWidth := 200; nPageHeigth := 200; nWidth := 200; nHeigth := 200; nHeightPage := 200; nWidthPage := 200
	Private oFont1,oFont2,oFontC,oFontD,oPrn  
	Private cComboBlq := ''
	Private cPedidos  := ''

	oFont1 := TFont():New( "Arial",,12,,.f.,,,,,.F.)
	oFont2 := TFont():New( "Arial",,13,,.T.,,,,,.F.)
	oFont3 := TFont():New( "Arial",,9,,.f.,,,,,.F.)
	
	oFontC := TFont():New( "Arial",,11,,.T.,,,,,.F.)
	oFontCb:= TFont():New( "Arial",,13,,.T.,,,,,.F.)
	oFontD := TFont():New( "Arial",,12,,.F.,,,,,.F.)
	oFont8 := TFont():New( "Arial",,9,,.F.,,,,,.F.)
	oFont10 := TFont():New("Arial",,10,,.F.,,,,,.F.)         
	    
	aPedImp := xPedidos

	cPedidos := ""
	For i := 1 to Len(aPedImp)
		cPedidos += "'"+aPedImp[i][2]+"',"
		_cFilAnt := aPedImp[i][1]
	Next i             
	
	cPedidos := Substr(cPedidos,1,Len(cPedidos)-1)


	//Marca combos Como Bloqueado Manualmente caso um dos itens estejam Bloqueados  
	cComboBlq := U_AGR05BLQ(cPedidos, .T.) 



	cCabec := " SELECT "
	cCabec += "    CASE WHEN (C9_LOCAL = '20') "
	cCabec += "       THEN B1_XLOCAL4 "
	cCabec += "       ELSE (B1_XRUA+B1_XBLOCO+B1_XNIVEL+B1_XAPTO) "
	cCabec += "    END AS B1_XLOCAL1, "

	cCabec += "    C9_PEDIDO, "
	cCabec += "    B1_DESC, "
	cCabec += "    B1_UM, "
	cCabec += "    B1_XLOCAL2, "
	cCabec += "    B1_XLOCAL3, "
	cCabec += "    B1_XRUA, "
	cCabec += "    B1_XBLOCO, "
	cCabec += "    B1_XNIVEL, "
	cCabec += "    B1_XAPTO, "
	cCabec += "    C9_PRODUTO, "
	cCabec += "    C5_OBS, "
	cCabec += "    C5_VEND1, "
	cCabec += "    C5_VEND2, "
	cCabec += "    C5_TRANSP, "
	cCabec += "    C5_VEND3, "
	cCabec += "    SUM(C9_QTDLIB)AS C9_QTDLIB, "
	cCabec += "    C5_FILIAL, "
	cCabec += "    C5_NUM, "
	cCabec += "    C5_CLIENTE, "
	cCabec += "    C5_LOJACLI, "
	cCabec += "    C5_NOMECLI, "
	cCabec += "    C5_EMISSAO, "
	cCabec += "    C5_TRANSP, "
	cCabec += "    C9_DATALIB, "
	cCabec += "    C5_XIMPRE "
	
	cFrom  := " FROM " + RetSqlName('SC9') + " SC9 (NOLOCK) " 

	cFrom += " INNER JOIN "+RetSqlName('SC5')+" SC5 (NOLOCK) ON (C5_NUM = C9_PEDIDO "
    cFrom +=                                               " AND SC5.D_E_L_E_T_ = '' "
	cFrom +=												" AND SC5.C5_FILIAL = SC9.C9_FILIAL) "

	cFrom += " INNER JOIN "+RetSqlName('SB1')+" SB1 (NOLOCK) ON (B1_COD = C9_PRODUTO "
	cFrom +=                                               " AND SB1.D_E_L_E_T_ = '' "
	cFrom +=												" AND SB1.B1_FILIAL = SC9.C9_FILIAL) "	

	cFrom += " INNER JOIN "+RetSqlName('SC6')+" SC6 (NOLOCK) ON (C9_PEDIDO = C6_NUM "
	cFrom +=                                               " AND C6_ITEM = C9_ITEM "
	cFrom +=												" AND C9_FILIAL = C6_FILIAL "
	cFrom +=												" AND SC6.D_E_L_E_T_ = '' "
	cFrom +=												" AND C9_PRODUTO = C6_PRODUTO) "

	cFrom += " INNER JOIN "+RetSqlName('SF4')+" SF4 (NOLOCK) ON (F4_CODIGO = C6_TES "
	cFrom +=                                               " AND F4_FILIAL = C6_FILIAL "
	cFrom +=                                               " AND SF4.D_E_L_E_T_ = '') "

	cWhere := " WHERE C9_BLEST  = '' "
	cWhere += "  AND C9_BLCRED = '' "
	cWhere += "   AND C9_DATALIB  >= '" +DTOS(mv_par03) + "' AND C9_DATALIB <= '" +DTOS(mv_par04)+ "' "
	cWhere += "   AND C9_LOCAL = '" +mv_par05+ "' "
	cWhere += "   AND C9_PEDIDO IN ("+cPedidos+")"
	cWhere += "   AND SC9.D_E_L_E_T_ = '' "

	If Alltrim(MV_PAR06) <> ""
		cWhere += " AND C5_TRANSP = '" +mv_par06+ "' "
	Endif 
	
	cWhere += "   AND C9_FILIAL = '" + _cFilAnt + "'"	
	cWhere += "   AND F4_ESTOQUE <> 'N' "  	
	If cComboBlq <> ''
		cWhere += "   AND C6_FILIAL + C6_NUM + C6_CODPAI + C6_COMBO NOT IN ("+cComboBlq+") "
	Endif 
	//cQueryCmbo := " AND (SC6.C6_CODPAI = '' OR ( SC6.C6_CODPAI <> '' AND NOT EXISTS( SELECT C6_NUM FROM "+RetSqlName('SC6')+" (nolock) COMBO "
	//cQueryCmbo += " 			INNER JOIN "+RetSqlName('SC9')+" (nolock) SC92 ON  SC92.C9_FILIAL = COMBO.C6_FILIAL AND SC92.C9_PEDIDO = COMBO.C6_NUM "
	//cQueryCmbo += " 			AND (C9_BLEST <> ''AND C9_BLEST <> '10') AND SC92.D_E_L_E_T_ = '' "
	//cQueryCmbo += " 			WHERE COMBO.C6_FILIAL = SC6.C6_FILIAL AND COMBO.C6_NUM = SC6.C6_NUM AND COMBO.D_E_L_E_T_ = '' "
	//cQueryCmbo += " 			AND SC6.C6_CODPAI <> '' AND SC6.C6_CODPAI  = COMBO.C6_CODPAI AND SC6.C6_COMBO = COMBO.C6_COMBO))) "
		  
	cQueryGrp := " GROUP BY B1_XLOCAL4, C9_LOCAL,B1_XLOCAL1,C9_PEDIDO,B1_DESC,B1_UM, B1_XLOCAL2,B1_XLOCAL3,B1_XRUA,B1_XBLOCO,B1_XNIVEL,B1_XAPTO, "
	cQueryGrp += "          C5_OBS, C5_NOMECLI, C5_XIMPRE, C9_PRODUTO, C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,C5_FILIAL,C5_NUM, "
 	cQueryGrp += "          C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB "

 	cQueryGrp += " ORDER BY C9_PEDIDO,B1_XLOCAL1,B1_XRUA,B1_XBLOCO,B1_XNIVEL,B1_XAPTO,C9_PRODUTO " 

	cQuery := cCabec + cFrom + cWhere + cQueryGrp

	cAliasQry := MpSysOpenQuery(cQuery)

	TCSETFIELD(cAliasQry,"C9_DATALIB","D",08,0)
	TCSETFIELD(cAliasQry,"C5_EMISSAO","D",08,0)

	cControla := ""
	nregs := 0      

	oPrn:= TMSPrinter():New()
	oPrn:Setup()

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	Procregua(Reccount())
	
	While (cAliasQry)->(!EOF())

		   
		If nregs == 0  
			Cabec(cAliasQry)
			ITEM()
			cControla := (cAliasQry)->C9_PEDIDO
			nregs++ 
			oPrn:StartPage()     
		Endif      
          
		nLin := nLin+50
		oPrn:Say (0005+nLin+5, 0005+nCol1,ALLTRIM((cAliasQry)->C9_PRODUTO),oFont3,100) 
		oPrn:Say (0005+nLin+5, 0035+nCol2,ALLTRIM((cAliasQry)->B1_DESC),oFont3,100) 
		oPrn:Say (0005+nLin+5, 0075+nCol3,(cAliasQry)->B1_UM,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0065+nCol4,TRANSFORM((cAliasQry)->C9_QTDLIB,"@E 999,999.99"),oFont3,100,3) 
		oPrn:Say (0005+nLin+5, 0125+nCol5,(cAliasQry)->B1_XLOCAL1,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0155+nCol6,(cAliasQry)->B1_XLOCAL2,oFont3,100) 
		oPrn:Say (0005+nLin+5, 0185+nCol7,(cAliasQry)->B1_XLOCAL3,oFont3,100) 	

		cControla := (cAliasQry)->C9_PEDIDO
		(cAliasQry)->(DbSkip())

		If  (ccontrola <>  (cAliasQry)->C9_PEDIDO) .And. (cAliasQry)->(!EOF())  
			 oPrn:EndPage() 
			 oPrn:StartPage() 
		     nLin 	:= 30
			 Cabec(cAliasQry)
			 ITEM()
		Endif 

		If nLin >= 3200  
			 oPrn:EndPage() 
			 oPrn:StartPage() 
		     nLin := 30
			 Cabec(cAliasQry)
			 ITEM()   
		Endif  
	Enddo 

	(cAliasQry)->(DbCloseArea())

	oPrn:EndPage()
	oPrn:Preview()
	MS_FLUSH()


Return()

Static Function Cabec(cAliasQry)

	cNome    :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_NOME")
	cCid     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_MUN")
	cEst     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_EST")
	cDDD     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_DDD")
	cTEL     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_TEL")
	cBairro  := Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_BAIRRO")

	oPrn:Say (0005+nLin+5, 0030+nCol,"Pedido: " + (cAliasQry)->C5_NUM ,oFont2,100)
	oPrn:Say (0005+nLin+5, 1930+nCol,"Data: " + DTOC((cAliasQry)->C5_EMISSAO) ,oFont1,100)
	oPrn:Say (0005+nLin+5, 0630+nCol,"Peso Total: " + AllTrim(Transform(GetPeso((cAliasQry)->C5_NUM), "@E 99,999,999.99")) + " KG" )
	nLin := nLin+50

	oPrn:Say (0005+nLin+5, 0030+nCol,"Cliente: " + (cAliasQry)->C5_CLIENTE + "/" + (cAliasQry)->C5_LOJACLI + " - " + Alltrim(SubStr(cNome,1,32)) + " | " + Alltrim(cCid) + ' / ' + cEst)
	oPrn:Say (0005+nLin+5, 1730+nCol,"Bairro: " + AllTrim(cBairro))
	nLin := nLin+50
	oPrn:Say (0005+nLin+5, 0030+nCol,"Fone       : " + cDDD + " " + cTEL)
	nLin := nLin+50 
	oPrn:Say (0005+nLin+5, 0030+nCol,"Obs: "+SUBSTR((cAliasQry)->C5_OBS,1,70))
	nLin := nLin+50	
	
	oPrn:Say (0005+nLin+5, 0030+nCol,"Representantes: ")
	nLin := nLin+50
	oPrn:Say (0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+(cAliasQry)->C5_VEND1,"A3_NREDUZ"))
	nLin := nLin+50
	
	If alltrim((cAliasQry)->C5_VEND2)<> ""
		oPrn:Say (0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_VEND2 + " - " + Posicione("SA3",1,xFilial("SA3")+(cAliasQry)->C5_VEND2,"A3_NREDUZ"))
		nLin := nLin+50		
	Endif

	If alltrim((cAliasQry)->C5_VEND3 ) <> ""
		oPrn:Say (0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_VEND3 + " - " + Posicione("SA3",1,xFilial("SA3")+(cAliasQry)->C5_VEND3,"A3_NREDUZ"))
		nLin := nLin+50
	Endif

	oPrn:Say (0005+nLin+5, 0030+nCol,"Transportadora: ")
	nLin := nLin+50
	oPrn:Say (0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_TRANSP + " - " + Posicione("SA4",1,xFilial("SA4")+(cAliasQry)->C5_TRANSP,"A4_NREDUZ"))
	nLin := nLin+50

Return()

Static Function ITEM()

	oPrn:line(0005+nLin+5, 0005+nCol1,0005+nLin+5,0185+nCol7+250)

	nLin := nLin+10 

	oPrn:Say (0005+nLin+5, 0005+nCol1,"PRODUTO",oFont3,100) 
	oPrn:Say (0005+nLin+5, 0035+nCol2,"DESCRICAO",oFont3,100) 
	oPrn:Say (0005+nLin+5, 0075+nCol3,"UM",oFont3,100) 
	oPrn:Say (0005+nLin+5, 0095+nCol4,"QTDE",oFont3,100,3) 
	oPrn:Say (0005+nLin+5, 0125+nCol5,"ENDERECO1",oFont3,100) 
	oPrn:Say (0005+nLin+5, 0155+nCol6,"ENDERECO2",oFont3,100) 
	oPrn:Say (0005+nLin+5, 0185+nCol7,"ENDERECO3",oFont3,100)  

	nLin := nLin+45

	oPrn:line(0005+nLin+5, 0005+nCol1,0005+nLin+5,0185+nCol7+250) 
Return()


Static Function GetPeso(NrPed)

	Local cQryPeso := ""
	Local cAlias   := ""
	Local nPeso    := 0

	cQryPeso += " SELECT SUM(C6_QTDVEN * COALESCE(B1_PESO,0)) AS PESO "
	cQryPeso += " FROM " + RetSQLName("SC6") + " SC6 (NOLOCK), " + RetSQLName("SB1") + " SB1 (NOLOCK) "
	cQryPeso += " WHERE C6_PRODUTO = B1_COD "
	cQryPeso += " AND   C6_FILIAL  = B1_FILIAL "
	cQryPeso += " AND   SC6.D_E_L_E_T_ = '' "
	cQryPeso += " AND   SB1.D_E_L_E_T_ = '' "
	cQryPeso += " AND   C6_NUM = '" + NrPed + "'" 
	cQryPeso += " AND   C6_FILIAL = '" + xFilial("SC6") + "'"

	cAlias := MpSysOpenQuery(cQryPeso)
	nPeso  := (cAlias)->PESO

	(cAlias)->(DbCloseArea())

Return(nPeso)


//Se 1 item do Combo estiver bloqueado, bloqueia todos 
User Function AGR05BLQ(xPedidos,xBloquear)

	
	Local cQryBlq     := ""
	Local cRetBlq     := ""
	Local cUpdBlq     := ""

	Default xPedidos  := ""
	Default xBloquear := .F.
	
	cQryBlq    := " SELECT C6_FILIAL,C6_NUM,C6_CODPAI,C6_COMBO " //" SELECT R_E_C_N_O_ FROM  "+RetSqlName('SC9')+"(NOLOCK) "
	cQryBlq    += " FROM " + RetSqlName('SC9') + " SC9 (NOLOCK) "
	cQryBlq    += " INNER JOIN "+RetSqlName('SC6')+" SC6 (NOLOCK) ON (C9_PEDIDO = C6_NUM "
	cQryBlq    +=                                               " AND C6_ITEM = C9_ITEM "
	cQryBlq    +=												" AND C9_FILIAL = C6_FILIAL "
	cQryBlq    +=												" AND SC6.D_E_L_E_T_ = '' "
	cQryBlq    +=												" AND C9_PRODUTO = C6_PRODUTO) "
	cQryBlq    += " WHERE C9_FILIAL = '"+xFilial('SC9') + "' "
	cQryBlq    += "   AND (C9_BLEST  <> '' AND C9_BLEST <> '10') "
	cQryBlq    += "   AND C9_BLCRED = '' AND C6_BLQ  = ''  "
	cQryBlq    += "   AND C9_DATALIB  >= '" +DTOS(mv_par03) + "' AND C9_DATALIB <= '" +DTOS(mv_par04)+ "' "
	cQryBlq    += "   AND C6_ENTREG  >= '" +DTOS(mv_par10) + "' AND C6_ENTREG <= '" +DTOS(mv_par11)+ "' "
	cQryBlq    += "   AND C9_LOCAL = '" +mv_par05+ "'  AND C6_CODPAI <> '' AND C6_COMBO <>'' "
	
	If xPedidos == ''
		cQryBlq += "  AND C9_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	Else 
		cQryBlq += "   AND C9_PEDIDO IN ("+xPedidos+")"
	Endif 
	cQryBlq += "   AND SC9.D_E_L_E_T_ = '' "
	cQryBlq += "   GROUP BY C6_FILIAL,C6_NUM,C6_CODPAI,C6_COMBO "
	
	cAliasBlq := MpSysOpenQuery(  cQryBlq  )


	While (cAliasBlq)->(!eof())

		cRetBlq += "'"+(cAliasBlq)->C6_FILIAL  + (cAliasBlq)->C6_NUM + (cAliasBlq)->C6_CODPAI + (cAliasBlq)->C6_COMBO+"'"
		
	
		(cAliasBlq)->(DbSkip())
	
		If (cAliasBlq)->(!eof())
			cRetBlq += ","
		Endif 
	Enddo

	If xBloquear .and. cRetBlq <> ''
		cUpdBlq := " UPDATE " + RetSqlName('SC9') + " SET C9_BLEST = '03' "
		cUpdBlq += " WHERE  C9_FILIAL + C9_PEDIDO + C9_ITEM IN (
		cUpdBlq += " 		SELECT C6_FILIAL + C6_NUM + C6_ITEM  FROM " + RetSqlName('SC6') + "(NOLOCK) SC6"
		cUpdBlq += "		WHERE C6_FILIAL + C6_NUM + C6_CODPAI + C6_COMBO IN ("+cRetBlq+") AND SC6.D_E_L_E_T_ = '')"
		cUpdBlq += "		AND C9_BLEST = '' AND D_E_L_E_T_ = '' "
		TcSqlExec(cUpdBlq)
	Endif 


Return cRetBlq
