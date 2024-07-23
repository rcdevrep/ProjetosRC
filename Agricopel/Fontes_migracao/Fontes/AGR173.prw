#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR173    ºAutor  ³Microsiga           º Data ³  05/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado para calcular o valor real do desconto.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function AGR173()

	LOCAL cTabela := Space(3), cCliente := Space(6), cLoja := Space(2), cProduto := Space(15), cCondPg := Space(03)

	nPPDesTab 	:=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_PDESTAB"})	
	nPPDesCom 	:=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_PDESCOM"})		
	nPDesc    	:=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_DESC"})
	nPosPDe     := aScan(aHeader,{|x| alltrim(x[2])  == "UB_DESCRI"})

	nPProduto	:= aScan(aHeader,{|x| alltrim(x[2])  == "UB_PRODUTO"})
	nPPrcTab	   :=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_PRCTAB"})
	nPQuant		:=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_QUANT"})
	nPVrUnit	   :=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_VRUNIT"})
	nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_VLRITEM"})
	nPVlrDesc 	:=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_VALDESC"})
	nPVdescom 	:=	aScan(aHeader,{|x| alltrim(x[2])  == "UB_VDESCOM"})	
	nPProvelh	:= aScan(aHeader,{|x| alltrim(x[2])  == "UB_PROVELH"})	

	If (Alltrim(ReadVar()) == "M->UB_PDESTAB")

		cTabela  := M->UA_TABELA      // Colocado esta consistencia para nao aceitar desconto(UB_PDESTAB) acima 
		cCliente := M->UA_CLIENTE     // do que esta no cadastro do cliente como ja funciona no AGR249 para consistir
		cLoja    := M->UA_LOJA        // qdo dado preco unitario com desconto superior ao do cadastro cliente.
		nMoeda   := M->UA_MOEDA       // Deco 07/12/2005
		cCondPg	:= M->UA_CONDPG

		nMaxDesc := R248MaxDesc(cCliente,cLoja,cTabela,cProduto,cCondPg)
        
        If cEmpAnt == "02" .OR. cEmpAnt == "11" .OR. cEmpAnt == "12" .OR. cEmpAnt == "15" .OR. (cEmpAnt == "01" .AND. (cFilAnt == "03" .or. cFilAnt == "15")) //SM0->M0_CODIGO == "02" .or. (SMO->M0_CODIGO =="01" .and. SM0->M0_CODFIL == "03")
			If (M->UB_PDESTAB > nMaxDesc ).and.(M->UA_oper != "2")  
				cMsg := "Este produto esta com o desconto acima do permitido: "+chr(13)+chr(13)
				cMsg += Alltrim(cProduto)+" - "+Alltrim(aCols[N,nPosPDe])+chr(13)
				cMsg += chr(13) + "Desconto permitido para este produto: " + Alltrim(Str(nMaxDesc,10,4)) + " %"
				MsgStop(cMsg)
				Return  .F.
			Endif                        
		EndIf
	
		aCols[n][nPDesc] := (M->UB_PDESTAB+aCols[n][nPPDescom]) - Round(((M->UB_PDESTAB * aCols[n][nPPDescom]) / 100),4)
		If M->UB_PDESTAB <> aCols[n][nPPDesTab]
			aCols[n][nPProvelh]	:= ""
		EndIf

	ElseIf (Alltrim(ReadVar()) == "M->UB_PDESCOM")

		If (M->UB_PDESCOM > M->UA_DESCCOM)
			MsgStop("Atencao: Desconto do Prazo Informado, superior a Condicao de Pagamento!!!")
			Return .F.
		EndIf
		aCols[n][nPDesc] := (aCols[n][nPPDesTab] + M->UB_PDESCOM) - Round(((aCols[n][nPPDesTab] * M->UB_PDESCOM) / 100),4)
		aCols[n][nPVdescom] 	:= Round(((aCols[n][nPPrcTab] * M->UB_PDESCOM /100)),4) * aCols[n][nPQuant]		
		If M->UB_PDESCOM <> aCols[n][nPPDescom]
			aCols[n][nPProvelh]	:= ""
		EndIf		
	EndIf


	aCols[n][nPVrUnit]	:= aCols[n][nPPrcTab] - Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4)
	aCols[n][nPVlrItem] 	:= aCols[n][nPVrUnit] * aCols[n][nPQuant]
	aCols[n][nPVlrDesc]	:= Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4) * aCols[n][nPQuant]

	nVlrMerc := 0
	nVlrPedi	:= 0
	For xx := 1 to Len(aCols)
		If !( aCols[xx][Len(aCols[xx])] )//Deletado												
			nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
			nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem]		
		EndIf			
	Next xx

	aValores[1] := Round(NoRound(nVlrMerc,4),2)
	aValores[6] := Round(NoRound(nVlrPedi,4),2)

	If (oGettlv <> Nil)
		oGettlv:oBrowse:Refresh()
	Endif
	//SysRefresh()	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR249   ºAutor  ³ Marcelo da Cunha   º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao no campo de preco unitario na tela do            º±±
±±º          ³  tele vendas e na tela do pedido de venda                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R248MaxDesc(xCliente,xLoja,xTabela,xProduto,xCondPg)
******************************************************
LOCAL aSegSA1  := SA1->(GetArea())
LOCAL aSegACO  := ACO->(GetArea())
LOCAL aSegACP  := ACP->(GetArea())
LOCAL aSegSB1  := SB1->(GetArea())
LOCAL nMaxDesc := 0, lDesCli := .T.

// Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 
lCombust := .F.
DbSelectArea("SB1")
DbSetOrder(1)
//DbGotop()
If(DbSeek(xFilial("SB1")+xProduto))
	If SB1->B1_TIPO == "CO"
		lCombust := .T.		
	EndIf
EndIf


If !lCombust // Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 
    // Esta parte de leitura ACO/ACP substitui a outra abaixo com dbseek para ganho de performance - Deco 19/07/2006
    aSX3ACP := ACP->(DbStruct())	
	cQuery := ""
	cQuery += "SELECT * " 
	cQuery += "FROM "+RetSqlName("ACO")+" ACO, "+RetSqlName("ACP")+" ACP "
	cQuery += "WHERE ACO.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACO.ACO_FILIAL = '"+xFilial("ACO")+"' "  
	cQuery += "AND ACO.ACO_CODTAB = '"+xTabela+"' "
	cQuery += "AND ACO.ACO_PROMOC = 'S' "
	cQuery += "AND ACP.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACP.ACP_FILIAL = '"+xFilial("ACP")+"' "  		
	cQuery += "AND ACP.ACP_CODREG = ACO.ACO_CODREG "
	cQuery += "AND ACP.ACP_CODPRO = '"+xProduto+"' "

	If (Select("TRB01") <> 0)
		DbSelectArea("TRB01")
		DbCloseArea()
	Endif       
	
	cQuery := ChangeQuery(cQuery)  
	TCQuery cQuery NEW ALIAS "TRB01"
	
	For aa := 1 to Len(aSX3ACP)
		If aSX3ACP[aa,2] <> "C"
			TcSetField("TRB01",aSX3ACP[aa,1],aSX3ACP[aa,2],aSX3ACP[aa,3],aSX3ACP[aa,4])		
		EndIf
	Next aa

	DbSelectArea("TRB01")
	DbGoTop()
	While !Eof()	
	   lDesCli := .F.
	   nMaxDesc += TRB01->ACP_perdes
	   DbSelectArea("TRB01")
	   TRB01->(DbSkip())
   EndDo
   // Esta parte de leitura ACO/ACP foi substituida pelo acima para ganho de performance - Deco 19/07/2006
   /*
	DbSelectArea("ACO")
	DbSetOrder(2)              
	DbSeek(xFilial("ACO")+xTabela,.T.)
	While !Eof().and.(ACO->ACO_filial == xFilial("ACO")).And.(ACO->ACO_codtab == xTabela)
		If (ACO->ACO_promoc == "S")
			DbSelectArea("ACP")
			DbSetOrder(1)      
			DbSeek(xFilial("ACP")+ACO->ACO_codreg)          
			While !Eof().and.(ACP->ACP_filial == xFilial("ACP")).and.(ACP->ACP_codreg == ACO->ACO_codreg)
				If (xProduto == ACP->ACP_codpro)
					lDesCli := .F.
					nMaxDesc += ACP->ACP_perdes
				Endif
				DbSelectArea("ACP")
				DbSkip()		
			Enddo
		Endif

		DbSelectArea("ACO")
		DbSkip()
	Enddo         
	*/
Else // Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 
	// Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 

    // Esta parte de leitura ACO/ACP substitui a outra abaixo com dbseek para ganho de performance - Deco 19/07/2006
    aSX3ACP := ACP->(DbStruct())	
	cQuery := ""
	cQuery += "SELECT * " 
	cQuery += "FROM "+RetSqlName("ACO")+" ACO, "+RetSqlName("ACP")+" ACP "
	cQuery += "WHERE ACO.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACO.ACO_FILIAL = '"+xFilial("ACO")+"' "  
	cQuery += "AND ACO.ACO_CODTAB = '"+xTabela+"' "
	cQuery += "AND ACO.ACO_CONDPG = '"+xCondPg+"' "
	cQuery += "AND ACO.ACO_FORMPG = '  ' "
	cQuery += "AND ACO.ACO_CODCLI = '"+xCliente+"' "
	cQuery += "AND ACO.ACO_LOJA   = '"+xLoja+"' "
	cQuery += "AND ACP.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACP.ACP_FILIAL = '"+xFilial("ACP")+"' "  		
	cQuery += "AND ACP.ACP_CODREG = ACO.ACO_CODREG "
	cQuery += "AND ACP.ACP_CODPRO = '"+xProduto+"' "

	If (Select("TRB01") <> 0)
		DbSelectArea("TRB01")
		DbCloseArea()
	Endif       
	
	cQuery := ChangeQuery(cQuery)  
	TCQuery cQuery NEW ALIAS "TRB01"
	
	For aa := 1 to Len(aSX3ACP)
		If aSX3ACP[aa,2] <> "C"
			TcSetField("TRB01",aSX3ACP[aa,1],aSX3ACP[aa,2],aSX3ACP[aa,3],aSX3ACP[aa,4])		
		EndIf
	Next aa

	DbSelectArea("TRB01")
	DbGoTop()
	While !Eof()	
	   lDesCli := .F.
	   nMaxDesc += TRB01->ACP_perdes
	   DbSelectArea("TRB01")
	   TRB01->(DbSkip())
   EndDo
   // Esta parte de leitura ACO/ACP foi substituida pelo acima para ganho de performance - Deco 19/07/2006
   /*
	DbSelectArea("ACO")
	DbSetOrder(2)              
	DbSeek(xFilial("ACO")+xTabela+xCondPg+"  "+xCliente+xLoja,.T.)
	While !Eof().And.(ACO->ACO_FILIAL 	== xFilial("ACO"));
					.And.(ACO->ACO_CODTAB 	== xTabela);
					.And.(ACO->ACO_CONDPG	== xCondPg);
					.And.(ACO->ACO_FORMPG	== "  ");
					.And.(ACO->ACO_CODCLI	== xCliente); 
					.And.(ACO->ACO_LOJA		== xLoja)
	
		DbSelectArea("ACP")
		DbSetOrder(1)      
		DbSeek(xFilial("ACP")+ACO->ACO_CODREG)
		While !Eof().And.(ACP->ACP_FILIAL == xFilial("ACP"));
						.And.(ACP->ACP_CODREG == ACO->ACO_CODREG)
						
			If (xProduto == ACP->ACP_CODPRO)
				lDesCli := .F.
				nMaxDesc += ACP->ACP_PERDES
			Endif
			dbSelectArea("ACP")
			dbSkip()		
		Enddo	     
		
		DbSelectArea("ACO")
		DbSkip()
	Enddo         
	*/
EndIf	

If (lDesCli)
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+xCliente+xLoja)
		nMaxDesc += SA1->A1_maxdesc
	Endif
Endif

//Retorna areas
///////////////
RestArea(aSegACP)
RestArea(aSegACO)
RestArea(aSegSA1)
RestArea(aSegSB1)

Return nMaxDesc