#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

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
User Function AGR249()
********************
LOCAL aSeg := GetArea()
LOCAL cTabela := Space(3), cCliente := Space(6), cLoja := Space(2), cProduto := Space(15), cCondPg := Space(03)
LOCAL cPrcFiscal:= TkPosto(M->UA_OPERADO, " U0_PRECOF" ) //Preco fiscal bruto 1=SIM / 2=NAO
LOCAL nPosPro := 0, nPosQua := 0, nPosUni := 0, nPosTab := 0, nPosIte := 0, nPosDes := 0
LOCAL nPosVDe := 0, nPosAcr := 0, nPosVAc := 0, nPosPDe := 0, nPosTes := 0
LOCAL nPreco  := 0, nDesc   := 0, nMoeda  := 1
LOCAL lRetu   := .T., lTeleven := .T. 

//Verifico se esta sendo chamado pela tela de Televendas ou Pedido
//////////////////////////////////////////////////////////////////

//If (Alltrim(ReadVar()) == "M->UB_VRUNIT")
If IsInCallStack("TMKA271") //Chamada pela Rotina de Televendas
	nPosPro   := aScan(aHeader,{|x| alltrim(x[2])=="UB_PRODUTO"})
	nPosPDe   := aScan(aHeader,{|x| alltrim(x[2])=="UB_DESCRI"})
	nPosQua   := aScan(aHeader,{|x| alltrim(x[2])=="UB_QUANT"})
	nPosUni   := aScan(aHeader,{|x| alltrim(x[2])=="UB_VRUNIT"})
	nPosTab   := aScan(aHeader,{|x| alltrim(x[2])=="UB_PRCTAB"})
	nPosIte   := aScan(aHeader,{|x| alltrim(x[2])=="UB_VLRITEM"})
	nPPDesTab := aScan(aHeader,{|x| alltrim(x[2])=="UB_PDESTAB"})		
	nPPDesCom := aScan(aHeader,{|x| alltrim(x[2])=="UB_PDESCOM"})	
	nPosDes   := aScan(aHeader,{|x| alltrim(x[2])=="UB_DESC"})
    nPosVDe   := aScan(aHeader,{|x| alltrim(x[2])=="UB_VALDESC"})
    nPosAcr   := aScan(aHeader,{|x| alltrim(x[2])=="UB_ACRE"})
    nPosVAc   := aScan(aHeader,{|x| alltrim(x[2])=="UB_VALACRE"})
	nPosTes   := aScan(aHeader,{|x| alltrim(x[2])=="UB_TES"})
	nPVDesCom := aScan(aHeader,{|x| alltrim(x[2])=="UB_VDESCOM"})	
	nPProvelh := aScan(aHeader,{|x| alltrim(x[2])=="UB_PROVELH"})
	nPAuxTab  := aScan(aHeader,{|x| alltrim(x[2])=="UB_AUXTAB"})  
	nPTpVlr   := aScan(aHeader,{|x| alltrim(x[2])=="UB_TPVLR"})
	
	nPreco   := M->UB_vrunit
	cProduto := aCols[N,nPosPro]
	cTabela  := M->UA_TABELA            
	
	cCliente := M->UA_CLIENTE
	cLoja    := M->UA_LOJA
	nMoeda   := M->UA_MOEDA
	cCondPg	 := M->UA_CONDPG
Endif                        

If !Empty(aCols[N,nPosTab])
	If (nPreco > aCols[N,nPosTab])
	    If cEmpAnt # "16" //Condição criada por Max Ivan em 18/07/2018, para não alterar o preço de tabela - ideia é sempre alterar os campos de Desconto e Acrescimo somente
		   aCols[N,nPosTab]   := nPreco
 	  	   aCols[N,nPAuxTab]  := nPreco
 	  	Else
 	  	   aCols[N][nPosTab]   := aCols[N,nPAuxTab] + ROUND(((aCols[N,nPAuxTab]* M->UA_X_ACRES) / 100),4)
	    EndIf
 		aCols[N,nPTpVlr]   :=  'S' 
 		
		aCols[N,nPosIte]   := A410Arred(nPreco*aCols[N,nPosQua],"UB_VLRITEM")
//		aCols[N,nPosDes]   := 0
        aCols[N,nPosDes]   := aCols[N,nPPDesCom] // Desconto do prazo mantem cfe Ademir 
//		aCols[N,nPosVDe]   := 0
		aCols[N,nPosVDe]   := A410Arred(((aCols[N,nPosTab]*aCols[N,nPPDesCom])/100)*aCols[N,nPosQua],"UB_VALDESC") // Calcular valor do desconto com base no desconto do prazo
		aCols[N,nPPDesTab] := 0 // Zera desconto de tabela devido preco acima do preco de tabela de preco
		If cEmpAnt == "16" //Incluído por Max Ivan (Nexus) em 19/07/2018 - ideia é sempre alterar os campos de Desconto e Acrescimo somente
   		   aCols[N,nPosAcr]   := A410Arred(Round(((nPreco/aCols[N,nPosTab])-1)*100,2),"UB_ACRE")
		   aCols[N,nPosVAc]   := A410Arred(Round(nPreco-aCols[N,nPosTab],2),"UB_VALACRE")
		EndIf
	ElseIf (nPreco < aCols[N,nPosTab])
	    If cEmpAnt == "16" //Condição criada por Max Ivan em 18/07/2018, para não alterar o preço de tabela - ideia é sempre alterar os campos de Desconto e Acrescimo somente
 	  	   aCols[N][nPosTab]   := aCols[N,nPAuxTab] + ROUND(((aCols[N,nPAuxTab]* M->UA_X_ACRES) / 100),4)
	    EndIf
	   If nPreco <> aCols[N,nPosUni]
			aCols[N][nPProvelh]	:= ""	   	
	   EndIf
	   // aCols[N,nPPAcres]   :=  M->UA_X_ACRES        
	    
		nDescPrz	:= (aCols[N,nPosTab] - Round(((aCols[N,nPosTab] * aCols[N,nPPDescom]) / 100),4))
		nDescTab := 100-(Round(nPreco/nDescPrz,6)*100)
		nDesc    := (aCols[N,nPPDesCom] + nDescTab) - Round(((nDescTab * aCols[n][nPPDescom]) / 100),4)		
		// nMaxDesc := R248MaxDesc(cCliente,cLoja,cTabela,cProduto,cCondPg)

		//		If (nDesc>nMaxDesc).and.(M->UA_oper != "2") Comentado por Valdecir em 15.02.05
		//		If ((aCols[n][nPPDesTab] ) > nMaxDesc ).and.(M->UA_oper != "2")
		//COMENTADO EM 02/12/2010 POR RODRIGO, ONDE DEVE FAZER A VERIFICAÇÃO SOMENTE NA HORA DA GRAVAÇÃO 
		//DO PEDIDO. 
        // If cEmpAnt == "02" .OR. cEmpAnt == "11" .OR. cEmpAnt == "12" .OR. cEmpAnt == "15" .OR. (cEmpAnt == "01" .AND. (cFilAnt == "03" .or. cFilAnt == "15")) //SM0->M0_CODIGO == "02" .or. (SMO->M0_CODIGO =="01" .and. Alltrim(SM0->M0_CODFIL) == "03")
		// 	If (nDescTab > nMaxDesc ).and.(M->UA_oper != "2")  // Linha cima deixa colocar preco menor que permitido na primeira vez Deco 23/06/2005.
		// 		cMsg := "Este produto esta com o desconto acima do permitido: "+chr(13)+chr(13)
		// 		cMsg += Alltrim(cProduto)+" - "+Alltrim(aCols[N,nPosPDe])+chr(13)
		// 		cMsg += chr(13) + "Desconto permitido para este produto: " + Alltrim(Str(nMaxDesc,10,4)) + " %"
		// 		MsgStop(cMsg)
		// 		Return (lRetu := .F.)
		// 	Endif
        // EndIf

		aCols[N,nPosIte] 	:= A410Arred(nPreco*aCols[N,nPosQua],"UB_VLRITEM")                
		aCols[N,nPosDes] 	:= nDesc
		aCols[N,nPosVDe] 	:= A410Arred(((aCols[N,nPosTab]*nDesc)/100)*aCols[N,nPosQua],"UB_VALDESC")
//		aCols[N,nPPDesTab]:= nDescTab
	Endif
   
Endif

MaFisAlt("IT_TES",aCols[N,nPosTes],N)
If MaFisFound()
  	MaColsToFis(aHeader,aCols,N,"TK273",.T.)
Endif

If (M->UA_PDESCAB > 0)
 	Tk273CalcDesc()
Endif

nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})

nVlrMerc := 0
nVlrPedi	:= 0
For xx := 1 to Len(aCols)
	If !( aCols[xx][Len(aCols[xx])] )//Deletado												
   	nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
	   nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem]		
	Endif
Next xx

aValores[1] := Round(NoRound(nVlrMerc,4),2)
aValores[6] := Round(NoRound(nVlrPedi,4),2)

aBkp		:= {}
aBkp 		:= aClone(aCols)	  // Backup dados do Browse Principal.	
//TKCLIENTE() - Chamado 291463 / 284608
aCols := aClone(aBkp)

If (oGettlv <> Nil)
	oGettlv:oBrowse:Refresh()
Endif
//SysRefresh()	

//Retorno as areas anteriores
/////////////////////////////
RestArea(aSeg)

                      
Return lRetu

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
	cQuery += "FROM "+RetSqlName("ACO")+" ACO (NOLOCK), "+RetSqlName("ACP")+" ACP (NOLOCK) "
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
	cQuery += "FROM "+RetSqlName("ACO")+" ACO (NOLOCK), "+RetSqlName("ACP")+" ACP (NOLOCK) "
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
