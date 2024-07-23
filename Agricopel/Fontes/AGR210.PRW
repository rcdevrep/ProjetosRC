#Include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AGR210     ³ Autor ³ALAN LEANDRO           ³ Data ³07.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³VALIDA OS DESCONTOS POR ITEM                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³01/10/2015 - Max Ivan - Criado variável _nSalv que armazena ³±±
±±³          ³           - variável N e depois restaura no final do pro-  ³±±
±±³          ³           - grama, para que o programa AGX300 seja executa-³±±
±±³          ³           - do corretamente na "explosão" do combo curinga.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR210()
**********************
LOCAL aSeg := GetArea(), aSegSB1 := SB1->(GetArea()), aSegACO := ACO->(GetArea())
LOCAL cTabela := Space(3), cCliente := Space(6), cLoja := Space(2), cProduto := Space(15), cCondPg := Space(03), cFormPg := Space(02)
LOCAL aSegACP := ACP->(GetArea())//, nSeg := N
LOCAL nPProd := 0, nPDesc := 0, nPProdD := 0, nDesc := 0
LOCAL cMsg:= ""
LOCAL lDesCli := .T.
Local _nSalv := N //Implementado por Max Ivan (Nexus) em 01/10/2015 - Salva a variável N para restaurar no final do programa

If M->UA_OPER == "2"
	//N := nSeg
	//RestArea(aSegSB1)
	//RestArea(aSegACO)
	//RestArea(aSegACP)
	RestArea(aSeg)
	//SysRefresh()
	Return .T.
Endif
                    
nPDesc  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
nPProdD := aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESCRI"})
nPProd  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})

nPPDescom  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})

// Verifica se o orcamento esta cancelado
If (M->UA_CANCEL == "S")
	cMsg := "Este orcamento foi cancelado por um superior!!! Nao pode ser alterado!!!"
	MsgStop(cMsg)
	
	//N := nSeg
	//RestArea(aSegSB1)
	//RestArea(aSegACO)
	//RestArea(aSegACP)
	RestArea(aSeg)                         
	//SysRefresh()    
	Return .F.
EndIf

/*
If  (AllTrim(SE4->E4_Cond) $ "0/00/000") .AND. (SE4->E4_TIPO <> "9")
	nDesc += 2.00
Endif
*/

// Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 
lCombust := .F.
DbSelectArea("SB1")
DbSetOrder(1)
//DbGotop()
If(DbSeek(xFilial("SB1")+aCols[n][nPProd]))
	If SB1->B1_TIPO == "CO"
		lCombust := .T.
	EndIf
EndIf

cCondPg	 := M->UA_CONDPG
cFormPg	 := M->UA_FORMPG
cCliente  := M->UA_CLIENTE
cLoja	    := M->UA_LOJA
cTabela   := M->UA_TABELA  
cProduto  := aCols[n][nPProd]

If !lCombust     // Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 
	// Verifica se o produto esta em promocao
    
    // Esta parte de leitura ACO/ACP substitui a outra abaixo com dbseek para ganho de performance - Deco 19/07/2006
    aSX3ACP := ACP->(DbStruct())	
	cQuery := ""
	cQuery += "SELECT * " 
	cQuery += "FROM "+RetSqlName("ACO")+" ACO (NOLOCK), "+RetSqlName("ACP")+" ACP (NOLOCK) "
	cQuery += "WHERE ACO.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACO.ACO_FILIAL = '"+xFilial("ACO")+"' "  
	cQuery += "AND ACO.ACO_CODTAB = '"+cTabela+"' "
	cQuery += "AND ACO.ACO_PROMOC = 'S' "
	cQuery += "AND ACP.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACP.ACP_FILIAL = '"+xFilial("ACP")+"' "  		
	cQuery += "AND ACP.ACP_CODREG = ACO.ACO_CODREG "
	cQuery += "AND ACP.ACP_CODPRO = '"+cProduto+"' "

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
	   nDesc   += TRB01->ACP_perdes
	   DbSelectArea("TRB01")
	   TRB01->(DbSkip())
   EndDo
   // Esta parte de leitura ACO/ACP foi substituida pelo acima para ganho de performance - Deco 19/07/2006
   /*
	dbSelectArea("ACO")
	dbSetOrder(2)              
	//dbGoTop()
	dbSeek(xFilial("ACO")+M->UA_TABELA)
	While !EOF() .and. (ACO->ACO_FILIAL == xFilial("ACO")) .and. (ACO->ACO_CODTAB == M->UA_TABELA)

		If ACO->ACO_PROMOC == "S"
			dbSelectArea("ACP")
			dbSetOrder(1)      
			//dbGoTop()
			dbSeek(xFilial("ACP")+ACO->ACO_CODREG)          
			While !EOF() .and. (ACP->ACP_FILIAL == xFilial("ACP")) .and. (ACP->ACP_CODREG == ACO->ACO_CODREG)
				If (aCols[n][nPProd] == ACP->ACP_CODPRO)
					lDesCli := .F.
					nDesc   += ACP->ACP_PERDES
				Endif
			
				dbSelectArea("ACP")
				dbSkip()		
			End			    
		Endif
		
		dbSelectArea("ACO")
		dbSkip()
	End         
	*/
	
Else // Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 
	// Incluido por Valdecir em 24.07, alteracao neste ponto devera ser alterado repassado para o programa AGR249 / AGR210 / TKGRPED. 
    
    // Esta parte de leitura ACO/ACP substitui a outra abaixo com dbseek para ganho de performance - Deco 19/07/2006
    aSX3ACP := ACP->(DbStruct())	
	cQuery := ""
	cQuery += "SELECT * " 
	cQuery += "FROM "+RetSqlName("ACO")+" ACO (NOLOCK), "+RetSqlName("ACP")+" ACP (NOLOCK)"
	cQuery += "WHERE ACO.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACO.ACO_FILIAL = '"+xFilial("ACO")+"' "  
	cQuery += "AND ACO.ACO_CODTAB = '"+cTabela+"' "
	cQuery += "AND ACO.ACO_CONDPG = '"+cCondPg+"' "
	cQuery += "AND ACO.ACO_FORMPG = '"+cFormPg+"' "
	cQuery += "AND ACO.ACO_CODCLI = '"+cCliente+"' "
	cQuery += "AND ACO.ACO_LOJA   = '"+cLoja+"' "
	cQuery += "AND ACP.D_E_L_E_T_ <> '*' "
	cQuery += "AND ACP.ACP_FILIAL = '"+xFilial("ACP")+"' "  		
	cQuery += "AND ACP.ACP_CODREG = ACO.ACO_CODREG "
	cQuery += "AND ACP.ACP_CODPRO = '"+cProduto+"' "

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
	   nDesc   += TRB01->ACP_perdes
	   DbSelectArea("TRB01")
	   TRB01->(DbSkip())
   EndDo
   // Esta parte de leitura ACO/ACP foi substituida pelo acima para ganho de performance - Deco 19/07/2006
   /*
	DbSelectArea("ACO")
	DbSetOrder(2)              
	DbSeek(xFilial("ACO")+M->UA_TABELA+M->UA_CONDPG+M->UA_FORMPG+M->UA_CLIENTE+M->UA_LOJA,.T.)
	While !Eof().And.(ACO->ACO_FILIAL 	== xFilial("ACO"));
					.And.(ACO->ACO_CODTAB 	== M->UA_TABELA);
					.And.(ACO->ACO_CONDPG	== M->UA_CONDPG);
					.And.(ACO->ACO_FORMPG	== M->UA_FORMPG);
					.And.(ACO->ACO_CODCLI	== M->UA_CLIENTE); 
					.And.(ACO->ACO_LOJA		== M->UA_LOJA)		

		DbSelectArea("ACP")
		DbSetOrder(1)      
		//DbGoTop()
		DbSeek(xFilial("ACP")+ACO->ACO_CODREG)          
		While !EOF() .And. (ACP->ACP_FILIAL == xFilial("ACP"));
						 .And. (ACP->ACP_CODREG == ACO->ACO_CODREG)
						 
			If (aCols[n][nPProd] == ACP->ACP_CODPRO)
				lDesCli := .F.
				nDesc   += ACP->ACP_PERDES
			Endif
		
			dbSelectArea("ACP")
			dbSkip()		
		End		
		
		dbSelectArea("ACO")
		dbSkip()
	End         
    */
EndIf

	
If lDesCli
	nDesc    += SA1->A1_MAXDESC
Endif                        

/*If (aCols[n][nPDesc] > nDesc)
	cMsg := "Este produto esta com o desconto acima do permitido: "+chr(13)+chr(13)
	cMsg += Alltrim(aCols[n][nPProd])+" - "+Alltrim(aCols[n][nPProdD])+chr(13)
	cMsg += chr(13) + "Desconto permitido para este produto: " + Alltrim(Str(nDesc,10,4)) + " %"
	MsgStop(cMsg)

	//N := nSeg
	RestArea(aSegSB1)
	RestArea(aSegACO)
	RestArea(aSegACP)
	RestArea(aSeg)
	//SysRefresh()  
	Return .F.
Endif				

aCols[n][nPPDescom] := M->UA_DESCCOM*/

//N := nSeg

RestArea(aSegSB1)
RestArea(aSegACO)
RestArea(aSegACP)
RestArea(aSeg)
oGetTlv:oBrowse:Refresh()
//SysRefresh()

N := _nSalv  //Implementado por Max Ivan (Nexus) em 01/10/2015 - Restaura o N conforme salvo no início do programa, já que o comando oGetTlv:oBrowse:Refresh()
             //volta ele pra 1, e assim o Combo Curinga não funciona bem.

Return .T.