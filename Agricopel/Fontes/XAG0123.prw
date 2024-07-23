#Include "rwmake.ch"
#Include "protheus.ch"
#Include "Topconn.ch"
#INCLUDE "FWPrintSetup.ch"
#include "TOTVS.CH"   
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} XAG0123.PRW
Programa Impressão de Mapa de separação
@author Leandro Spiller	
@since Nov/2023
@version 1.0
/*/

//Função de Impressão de Mapa de Separacao
User Function XAG0123(xPedidos,xAuto,xDatabase,xLocalde,xLocalate,xPrinter,Lbrw)
 
	Default xAuto     := .F.
	Default xDatabase := dDatabase
	Default xLocalde    := ''
	Default xLocalate   := ''
	Default xPrinter  := "Microsoft Print to PDF" 
	Default xPedidos  := {} 
	Default Lbrw      := .F.

	Local cQuery    := ""
	Local cAliasQry := ""
	//Local i         := 0
	Local _i        := 0 
	  

	Private nCol 	:= 40
	Private nCol1 	:= 55
	Private nCol2 	:= 230//DESCRICAO 
	Private nCol3 	:= 1195// UM 
	Private nCol4 	:= 1275 // QTDE 
	Private nCol5 	:= 1440-20// ENDERECO1
	Private nCol6 	:= 1660-20// ENDERECO 2
	Private nCol7 	:= 1880-20//ENDERECO 3
	Private nQuebra := 3000
		
	Private nLin 	:= 70 
	Private aPedImp := {}     
	Private nmax    := 800
	Private Ncaixas :=  0  
	Private nPage   := 0; npageWidth := 200; nPageHeigth := 200; nWidth := 200; nHeigth := 200; nHeightPage := 200; nWidthPage := 200
	Private oFont1,oFont2,oFontC,oFontD,oPrn,oFont3  
	Private cComboBlq  := ''
	Private cPedidos   := ''
	Private aRecnoSC9  := {}
	Private aRecnoSC5  := {}
	Private _SeqPed    := '' 
	Private cPedidoSep := ""
	Private cSeqPed    := ""
	
	//Se for automatico 
	/*If xAuto 

		_cFilAnt := xfilial('SC5')
		
		Pergunte("SMSAGR04",.F.)
	
		mv_par03 := xDatabase - 365//C9_DATALIB de
		mv_par04 := xDatabase//C9_DATALIB ate
		mv_par05 := xLocal//C9_LOCAL
		mv_par06 := ''//C5_TRANSP
		mv_par08 := 2 //C5_XIMPRE
		mv_par09 := 1//C5_XIMPRE
		mv_par10 := xDatabase - 365//C6_ENTREG
		mv_par11 := xDatabase//C6_ENTREG

	Endif */

	oFont1 := TFont():New( "Arial",,13,,.f.,,,,,.F.)
	oFont2 := TFont():New( "Arial",,16,,.T.,,,,,.F.)
	oFont3 := TFont():New( "Arial",,11,,.f.,,,,,.F.)
	
	oFontC := TFont():New( "Arial",,15,,.F.,,,,,.F.)
	oFontCb:= TFont():New( "Arial",,14,,.T.,,,,,.F.)
	oFontD := TFont():New( "Arial",,13,,.F.,,,,,.F.)
	oFont8 := TFont():New( "Arial",,10,,.F.,,,,,.F.)
	oFont10 := TFont():New("Arial",,11,,.F.,,,,,.F.)   
  


	//Se foi gerado via Browse pega só os pedidos que foram marcados
	If Lbrw
	
	  	cMarca :=     oBrowseSC9:Mark()
        dbselectarea('XAG0124')
        XAG0124->(dbGotop())
        While XAG0124->(!eof())
            If alltrim(XAG0124->(C9_XOKSEP)) = alltrim(cMarca)
                cPedidos +=  "'"+XAG0124->C9_PEDIDO + XAG0124->C9_XSREDI+"',"
                //AADD(aPedidos,XAG0124->C9_PEDIDO + C9_XSREDI)
            Endif  
            XAG0124->(dbskip())
        Enddo 

		cPedidos := subst(cPedidos,1, len(cPedidos)-1)

        If cPedidoS == ""
            MSGSTOP( "Nenhum pedido foi marcado!!", "ATENCAO" )
            Return
        Endif 

		cComboBlq := U_XAG123BL(cPedidos, .T.,xLocalde,xlocalate) 

	Endif 

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
	//cCabec += "    C5_TRANSP, "
	cCabec += "    C9_DATALIB, "
	cCabec += "    C5_XIMPRE, "
	cCabec += "    SC9.R_E_C_N_O_ AS RECSC9, "
	cCabec += "    SC5.R_E_C_N_O_ AS RECSC5, "
	cCabec += "    C9_XSREDI "

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
	iF !Lbrw
		cWhere += "  AND C9_DATALIB  >= '" +DTOS(xDatabase - 365) + "' AND C9_DATALIB <= '" +DTOS(xDatabase)+ "' "
		cWhere += "  AND C6_ENTREG   >= '" +DTOS(xDatabase) + "' AND C6_ENTREG <= '" +DTOS(xDatabase)+ "' "
	Endif
	
	cWhere += "  AND C9_LOCAL BETWEEN '" +xLocalde+ "'  AND '" +xLocalate+ "' " 
	
	If Lbrw
		cWhere += "  AND C9_PEDIDO + C9_XSREDI IN ("+cPedidos+")"
	Endif 
	cWhere += "  AND (C9_PRODUTO  NOT LIKE '%801' OR C9_PRODUTO IN ('49067801','49167801') ) "
	cWhere += "  AND SC9.D_E_L_E_T_ = '' "

	/*If Alltrim(MV_PAR06) <> ""
		cWhere += " AND C5_TRANSP = '" +mv_par06+ "' "
	Endif 
	
	If mv_par08 == 1 .or. mv_par09 == 2//sim
		cWhere += " AND C5_XIMPRE = 'S' "
	Elseif mv_par08 == 2 //nao
		cWhere += " AND C5_XIMPRE <> 'S' "
	Endif
	*/
	cWhere += "   AND C9_FILIAL = '" + xFilial('SC9') + "'"	
	cWhere += "   AND F4_ESTOQUE <> 'N' "  	
	If cComboBlq <> ''
		cWhere += "   AND C6_FILIAL + C6_NUM + C6_CODPAI + C6_COMBO NOT IN ("+cComboBlq+") "
	Endif 
		  
	cQueryGrp := " GROUP BY B1_XLOCAL4, C9_LOCAL,B1_XLOCAL1,C9_PEDIDO,B1_DESC,B1_UM, B1_XLOCAL2,B1_XLOCAL3,B1_XRUA,B1_XBLOCO,B1_XNIVEL,B1_XAPTO, "
	cQueryGrp += "          C5_OBS, C5_NOMECLI, C5_XIMPRE, C9_PRODUTO, C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,C5_FILIAL,C5_NUM, "
 	cQueryGrp += "          C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB, SC9.R_E_C_N_O_,SC5.R_E_C_N_O_,C9_XSREDI "

 	cQueryGrp += " ORDER BY C9_PEDIDO,B1_XLOCAL1,B1_XRUA,B1_XBLOCO,B1_XNIVEL,B1_XAPTO,C9_PRODUTO,C9_XSREDI " 

	cQuery := cCabec + cFrom + cWhere + cQueryGrp

	cAliasQry := MpSysOpenQuery(cQuery)

	TCSETFIELD(cAliasQry,"C9_DATALIB","D",08,0)
	TCSETFIELD(cAliasQry,"C5_EMISSAO","D",08,0)

	cControla := ""
	nregs := 0      

	oPrn := FwMsPrinter():New('XAG0123',, .T., ,.T., , ,xPrinter, .F., Nil, Nil,.F. ) 
	
	oPrn:SetPortrait()
	oPrn:SetPaperSize(DMPAPER_A4) 

	If !xAuto 
		oPrn:Setup()
		If OPRN:NMODALRESULT == 2 
			Return
		Endif 
	Endif 

	cTimeGer   := SUBSTR(time(),1,5)
	cDtGer     := Date()

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	Procregua(Reccount())
	
	While (cAliasQry)->(!EOF())

		   
		If nregs == 0  
			oPrn:StartPage()
			Cabec(cAliasQry)
			ITEM(cAliasQry)
			cControla := (cAliasQry)->C9_PEDIDO
			nregs++ 
		Endif      
        
		/* For i := 5 to 1000 
			oPrn:Say(0005+i+5, 0005+nCol1,ALLTRIM((cAliasQry)->C9_PRODUTO),oFont3,100) 
		Next i*/
		nLin := nLin+50
		oPrn:Say(0005+nLin+5, 0005+nCol1,ALLTRIM((cAliasQry)->C9_PRODUTO),oFont3,100) 
		oPrn:Say(0005+nLin+5, 0035+nCol2,ALLTRIM((cAliasQry)->B1_DESC),oFont3,100) 
		oPrn:Say(0005+nLin+5, 0075+nCol3,(cAliasQry)->B1_UM,oFont3,100) 
		oPrn:Say(0005+nLin+5, 0065+nCol4,TRANSFORM((cAliasQry)->C9_QTDLIB,"@E 999,999.99"),oFont3,100,3) 
		oPrn:Say(0005+nLin+5, 0125+nCol5,(cAliasQry)->B1_XLOCAL1,oFont3,100) 
		oPrn:Say(0005+nLin+5, 0155+nCol6,(cAliasQry)->B1_XLOCAL2,oFont3,100) 
		oPrn:Say(0005+nLin+5, 0185+nCol7,(cAliasQry)->B1_XLOCAL3,oFont3,100) 	

		//nAdjuste1 := 23
		oPrn:line(nLin+23, 0005+nCol1,nLin+23,0185+nCol7+200) 
		
		//AADD(aRecnoSC9, (cAliasQry)->RECSC9 ) 
		
		cControla := (cAliasQry)->C9_PEDIDO
		
		
		//Gravo dados da impressão 
		DbSelectarea('SC9')
		DbGoto((cAliasQry)->RECSC9)
		Reclock('SC9',.F.)
			SC9->C9_XDTEDI := cDtGer
            SC9->C9_XHREDI := cTimeGer   
			SC9->C9_XSREDI := cSeqPed 	
		SC9->(MSUNLOCK())
		
		(cAliasQry)->(DbSkip())

		If  (ccontrola <>  (cAliasQry)->C9_PEDIDO) .And. (cAliasQry)->(!EOF())  
			 oPrn:EndPage() 
			 oPrn:StartPage() 
		     nLin 	:= 70
			 Cabec(cAliasQry)
			 ITEM(cAliasQry)
		Endif 

		If nLin >= 2800//3200  
			 oPrn:EndPage() 
			 oPrn:StartPage() 
		     nLin := 70
			 Cabec(cAliasQry)
			 ITEM(cAliasQry)   
		Endif  
	Enddo 

	(cAliasQry)->(DbCloseArea())

	oPrn:EndPage()
	
	If !xAuto 
		oPrn:Preview()
	Else
		oPrn:Print()
	Endif 


	/*cPedidoSep := ""//Variavel de controle
	cTimeGer   := SUBSTR(time(),1,5)
	cDtGer     := Date()

	//Grava data hora de impressão 
	For _i := 1 to len(aRecnoSC9)
		Dbselectarea('SC9')
		Dbgoto(aRecnoSC9[_i])
		
		//Busca Proxima sequencia de separação
		If cPedidoSep <> SC9->C9_PEDIDO
			cSeqPed := U_XAG123SQ(SC9->C9_FILIAL , SC9->C9_PEDIDO )
		Endif 
		
		Reclock('SC9',.F.)
			SC9->C9_XDTEDI := cDtGer
            SC9->C9_XHREDI := cTime   //SUBSTR(time(),1,5)
			SC9->C9_XSREDI := cSeqPed //SUBSTR(time(),1,5)
		SC9->(MsUnlock())

		cPedidoSep := SC9->C9_PEDIDO
	Next _i
	*/

	//Grava pedido como impresso 
	//If xAuto 
		For _i := 1 to len(aRecnoSC5)
			Dbselectarea('SC5')
			Dbgoto(aRecnoSC5[_i])
			If alltrim(SC5->C5_XIMPRE) <> 'S'
				Reclock('SC5',.F.)
					SC5->C5_XIMPRE := 'S'
 				SC5->(MsUnlock())
			Endif 
		Next _i
	//Endif 

	MS_FLUSH()


Return()

Static Function Cabec(cAliasQry)

	cNome    :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_NOME")
	cCid     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_MUN")
	cEst     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_EST")
	cDDD     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_DDD")
	cTEL     :=	Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_TEL")
	cBairro  := Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI,"SA1->A1_BAIRRO")

	cCode := (cAliasQry)->C5_NUM	

	If alltrim((cAliasQry)->C9_XSREDI) == ''
		cSeqPed := U_XAG123SQ(xFilial('SC9') , cCode   )
	Else
		cSeqPed := (cAliasQry)->C9_XSREDI 
	Endif 

	oPrn:Say(0005+nLin+5, 0030+nCol,"Pedido: " + (cAliasQry)->C5_NUM +' - ' +cSeqPed,oFont2,100)
	oPrn:Say(0005+nLin+5, 1230+nCol,"Data Ped.: " + DTOC((cAliasQry)->C5_EMISSAO) ,oFont1,100)
	oPrn:Say(0005+nLin+5, 1530+nCol,"Data Lib.: " + DTOC((cAliasQry)->C9_DATALIB) ,oFont1,100)
	oPrn:Say(0005+nLin+5, 1830+nCol,"Dth Mapa: " + dtoc(cDtGer) +'-' +cTimeGer ,oFont1,100)
	oPrn:Say(0005+nLin+5, 0630+nCol,"Peso Total: " + AllTrim(Transform(GetPeso((cAliasQry)->C5_NUM), "@E 99,999,999.99")) + " KG" ,oFontC,100)
	nLin := nLin+50
	


	oPrn:Say(0005+nLin+5, 0030+nCol,"Cliente: " + (cAliasQry)->C5_CLIENTE + "/" + (cAliasQry)->C5_LOJACLI + " - " + Alltrim(SubStr(cNome,1,32)) + " | " + Alltrim(cCid) + ' / ' + cEst ,oFontC,100)
	oPrn:Say(0005+nLin+5, 00125+nCol5/*1730+nCol*/,"Bairro: " + AllTrim(cBairro) ,oFontC,100)
	nLin := nLin+50
	oPrn:Say(0005+nLin+5, 0030+nCol,"Fone       : " + cDDD + " " + cTEL ,oFontC,100)
	nLin := nLin+50 
	oPrn:Say(0005+nLin+5, 0030+nCol,"Obs: "+SUBSTR((cAliasQry)->C5_OBS,1,70) ,oFontC,100)
	nLin := nLin+50	
	
	oPrn:Say(0005+nLin+5, 0030+nCol,"Representantes: " ,oFontC,100)

	//oPrn:Int25(3040+nAjust3+170,60,(cAliasQry)->C5_NUM,0.73,40,.F.,.F., oFont)
	//oPrn:Ean13(0005+nLin+5/*nRow*/ ,280/*nCol*/,"876543210987"/*cCode*/,100/*nWidth*/,95/*nHeigth*/)
	//oPrn:Ean13(0005+nLin+50/*nRow*/ ,280/*nCol*/,alltrim((cAliasQry)->C5_NUM)/*cCode*/,100/*nWidth*/,95/*nHeigth*/)
	nRow := nLin//470
	nColbar := 1730+nCol
	nWidth := 1
	nHeigth:= 50
	lSay := .F.
	NtotWidth := 120
		
	

	oPrn:Code128(nRow ,nColbar, cCode + cSeqPed ,nWidth,nHeigth,lSay,,NtotWidth)

	nLin := nLin+50
	oPrn:Say(0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+(cAliasQry)->C5_VEND1,"A3_NREDUZ") ,oFontC,100)
	nLin := nLin+50
	
	If alltrim((cAliasQry)->C5_VEND2)<> ""
		oPrn:Say(0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_VEND2 + " - " + Posicione("SA3",1,xFilial("SA3")+(cAliasQry)->C5_VEND2,"A3_NREDUZ") ,oFontC,100)
		nLin := nLin+50		
	Endif

	If alltrim((cAliasQry)->C5_VEND3 ) <> ""
		oPrn:Say(0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_VEND3 + " - " + Posicione("SA3",1,xFilial("SA3")+(cAliasQry)->C5_VEND3,"A3_NREDUZ") ,oFontC,100)
		nLin := nLin+50
	Endif

	oPrn:Say(0005+nLin+5, 0030+nCol,"Transportadora: " ,oFontC,100)
	nLin := nLin+50
	oPrn:Say(0005+nLin+5, 0030+nCol,"    "+(cAliasQry)->C5_TRANSP + " - " + Posicione("SA4",1,xFilial("SA4")+(cAliasQry)->C5_TRANSP,"A4_NREDUZ") ,oFontC,100)
	nLin := nLin+50

	AADD(aRecnoSC5, (cAliasQry)->RECSC5 )

	//Grava Log de Impressao de Mapa 
	U_XAG0124E( (cAliasQry)->C5_NUM+cSeqPed,'Impressão de Mapa','I'  , .F.  , cDtGer , ctimeGer )
	//U_XAG0124E(cPedidoSep                ,cMsg               ,xOpc, lBrw,dDate, cTime )

Return()

Static Function ITEM(cAliasQry)

	oPrn:line(nLin-10, 0005+nCol1,nLin-10,0185+nCol7+200)

	nLin := nLin+20 

	oPrn:Say(0005+nLin+5, 0005+nCol1,"PRODUTO",oFont3,100) 
	oPrn:Say(0005+nLin+5, 0035+nCol2,"DESCRICAO",oFont3,100) 
	oPrn:Say(0005+nLin+5, 0075+nCol3,"UM",oFont3,100) 
	oPrn:Say(0005+nLin+5, 0095+nCol4,"QTDE",oFont3,100,3) 
	oPrn:Say(0005+nLin+5, 0125+nCol5,"ENDERECO1",oFont3,100) 
	oPrn:Say(0005+nLin+5, 0155+nCol6,"ENDERECO2",oFont3,100) 
	oPrn:Say(0005+nLin+5, 0185+nCol7,"ENDERECO3",oFont3,100)  

	nLin := nLin+35

	oPrn:line(nLin, 0005+nCol1,nLin,0185+nCol7+200) 

	nLin := nLin-15
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
User Function XAG123BL(xPedidos,xBloquear,xLocalde,xLocalate )

	
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
	cQryBlq    += " WHERE C9_FILIAL = '"+xFilial('SC9') + "' AND (C9_BLEST  <> '' AND C9_BLEST <> '10') "
	cQryBlq    += "   AND C9_BLCRED = '' AND C6_BLQ  = ''  "
	//cQryBlq    += "   AND C9_DATALIB  >= '" +DTOS(mv_par03) + "' AND C9_DATALIB <= '" +DTOS(mv_par04)+ "' "
	//cQryBlq    += "   AND C6_ENTREG  >= '" +DTOS(mv_par10) + "' AND C6_ENTREG <= '" +DTOS(mv_par11)+ "' "
	cQryBlq    += "   AND C9_LOCAL between '" +xLocalde+ "'  AND  '" +xLocalate+ "' "
	cQryBlq    += "   AND C6_CODPAI <> '' AND C6_COMBO <>'' "
	
	//If xPedidos = ''
	//	cQryBlq += "  AND C9_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	//Else 
		cQryBlq += "   AND C9_PEDIDO+C9_XSREDI IN ("+xPedidos+")"
	//Endif 
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



User Function XAG123SQ(xfilial , xPedido)

	Default xSeq  := ""
	Local cSeqPed := "000"
	Local cQuery  := ""

	cQuery +=  " SELECT ISNULL(MAX(C9_XSREDI),'000') AS SEQ "
	cQuery +=  " FROM " + RETSQLNAME("SC9") + " C9 "
	cQuery +=  " WHERE   C9.D_E_L_E_T_<> '*'      "
	cQuery +=  " AND C9.C9_FILIAL =  '"+xfilial+"' "
	cQuery +=  " AND C9.C9_PEDIDO =  '"+xPedido+"' "
	//cQuery +=  " AND C9.C9_XSREDI <> '' "

	If Select("XAG123SQ") > 0
		dbSelectArea("XAG123SQ")                   
		DbCloseArea()
	EndIf

	//* Cria a Query e da Um Apelido

	TCQuery cQuery NEW ALIAS "XAG123SQ"

	dbSelectArea("XAG123SQ")

	IF XAG123SQ->(!EOF() )  

		cSeqPed := SOMA1(XAG123SQ->SEQ)
		XAG123SQ->(DBSKIP() ) 
	
	Endif

	If Select("XAG123SQ") > 0
		dbSelectArea("XAG123SQ")                   
		DbCloseArea()
	EndIf


Return  cSeqPed


User Function XAG0123S()

	Local 	_aImpress := {} 
	Local   _I := 0  
	Local  lImpOk := .F.
	Private _cPrinter := "" 

 	RPCSetType(3)
	RPCSetEnv('01', '06')

		_cPrinter := SuperGetMV( "MV_XPRMAPA" , .F. , "Microsoft Print to PDF" ) 
		_aImpress :=			GetImpWindows(.F.)
		
		//Valida se a impressora está cadastrada
		For _I := 1 to len(_aImpress)
			If _cPrinter $ UPPER(_aImpress[_I])
				lImpOk := .T. 
				Exit
			Endif 
		NExt _I 

		If lImpOk
			u_XAG0123(/*xPedidos*/,.t./*xAuto*/,dDatabase/*xDatabase*/,'01'/*xLocal de*/,'01'/*xLocal ate*/,_cPrinter,/*Via Browse? */.F.)
		Else
			CONOUT('XAG0123 - Impressora não cadastrada'+_cPrinter)
		Endif 
	RPCClearEnv()
	dbCloseAll() 

	//Cadastro de operadores - ACDA010.PRW  
	
Return 

//Estorno de mapa de separação 
User Function XAG0123E(xPedido,Lbrw)

	Default xPedido  := ""
	Default Lbrw      := .F.

	Local cUpdSC5    := ""
	Local cUpdSC9    := ""
	Local _aPedidos  := {}
	Local cPedidos   := ""
	Local cPedidosC9 := ""

	//Se foi gerado via Browse pega só os pedidos que foram marcados
	If Lbrw
	
	  	cMarca :=     oBrowseSC9:Mark()
        dbselectarea('XAG0124')
        XAG0124->(dbGotop())
        While XAG0124->(!eof())
            If alltrim(XAG0124->(C9_XOKSEP)) = alltrim(cMarca)
                cPedidos +=  "'"+XAG0124->C9_PEDIDO+"',"
				cPedidosC9 +=  "'"+XAG0124->C9_PEDIDO + XAG0124->C9_XSREDI+"',"
                AADD(_aPedidos,XAG0124->C9_PEDIDO + C9_XSREDI)
            Endif  
            XAG0124->(dbskip())
        Enddo 

		cPedidos   := subst(cPedidos,1, len(cPedidos)-1)
		cPedidosC9 := subst(cPedidosC9,1, len(cPedidosC9)-1)

        If cPedidoS == ""
            MSGSTOP( "Nenhum pedido foi marcado!!", "ATENCAO" )
            Return
        Endif 

	Else

		cPedidos := xPedido
		AADD(_aPedidos,cPedidos)

		If cPedidoS == ""
            MSGSTOP( "Nenhum pedido foi marcado!!", "ATENCAO" )
            Return
        Endif 
	Endif 


	If MsgYesno(" Deseja Estornar Mapa do(s) pedido(s) "+cPedidos+ "? ") 

		//atualiza SC5 para comercial poder excluir ou alterar o pedido
		cUpdSC5 := " UPDATE " + RetSqlName('SC5') + " SET C5_XIMPRE = 'E' "
		cUpdSC5 += " WHERE C5_FILIAL = '"+xFilial('SC5')+"' AND  C5_NUM IN ("+cPedidos+") "
		cUpdSC5 += " AND D_E_L_E_T_ = '' "

		If (TCSQLExec(cUpdSC5) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		Else

			//Atualiza status da SC9 para mudar legenda do pedido
			cUpdSC9 := " UPDATE " + RetSqlName('SC9') + " SET C9_XSTSSEP = 'E' "
			cUpdSC9 += " WHERE C9_FILIAL = '"+xFilial('SC9')+"' AND  C9_PEDIDO + C9_XSREDI IN ("+cPedidosC9+") "
			cUpdSC9 += " AND D_E_L_E_T_ = '' "

			If (TCSQLExec(cUpdSC9) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			Else
				U_XAG0124E(_aPedidos,'Estorno de Mapa de Separação','E', .T.,date(),substr(time(), 1, 5)  )//(xPedidos,xMsg,xOpc, lBrw)
				MsgInfo("Pedido(s) estornados com sucesso! ")
			Endif 
			
		Endif 
	Endif 

	//TcSqlExec(cUpdSC5)

Return 
