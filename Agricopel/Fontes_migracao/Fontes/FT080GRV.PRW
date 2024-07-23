#INCLUDE "RWMAKE.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FT080GRV    ºAutor  ³Microsiga           º Data ³  10/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Log alterações das tabelas ACO E ACP para 						º±±
                MIME DISTRIBUIDORA  (Regras de Desconto)                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ=ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                         1
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION FT080GRV()   
   if 1 == 2 
   	DbSelectArea("SZE")
		DbGoTop()
		Do While SZE->(!Eof())   
      	DbSelectArea("SB1")
			DbSetOrder(1)   
			DbGotop()
			DbSeek(xFilial("SB1")+SZE->ZE_CODPROD) 
			
			cProdAntigo := SB1->B1_DESC
			DbGotop()
			DbSeek(xFilial("SB1")+SZE->ZE_PRODNOV) 			
		   cProdNovo := SB1->B1_DESC		   	                            
         
	   	DbSelectArea("SZE")   
	   	RecLock("SZE",.F.)     
   	 		SZE->ZE_PRODESA  := cProdAntigo
   	 		SZE->ZE_PRODESN  := cProdNovo
			MsUnLock("SZE")
   		DbSkip()  	   	
      EndDo
     ALERT('Fim do Processo')
   endif


	if CEMPANT == '02'
		nProxNum := GetMv("MV_SEQREG")
		PutMv("MV_SEQREG",nProxNum+1)       
		//	ALERT(nProxNum)
	
	   cGrava := 'N'
   
		DbSelectArea("ACO")  
		DbSeek(xFilial("ACO") + M->ACO_CODREG ,.T.)	 
   
	   If M->ACO_DESCRI <> ACO->ACO_DESLOG
   	   cGrava := 'S'
	   EndIf 
   
   	If M->ACO_FILIAL <> ACO->ACO_FILLOG
	      cGrava := 'S'
	   EndIf
   
	   If M->ACO_CODCLI <> ACO->ACO_CLILOG
   	   cGrava := 'S'
	   EndIf                            
   
   	If M->ACO_LOJA <> ACO->ACO_LOJLOG
      	cGrava := 'S'
	   EndIf  
   
   	If M->ACO_CONDPG <> ACO->ACO_CONLOG
      	cGrava := 'S'
	   EndIf     
      
   	if cGrava == 'S'     
			RecLock("SZE",.T.)
			SZE->ZE_SEQLOG   := nProxNum
			SZE->ZE_CODREG   := M->ACO_CODREG
			SZE->ZE_TABALT   := 'ACO'
			SZE->ZE_DESCRI   := M->ACO_DESLOG
			SZE->ZE_DESCNOV  := M->ACO_DESCRI
			SZE->ZE_CODCLI   := M->ACO_CLILOG
			SZE->ZE_CODCNOV  := M->ACO_CODCLI
			SZE->ZE_LOJA     := M->ACO_LOJLOG
			SZE->ZE_LOJANOVA := M->ACO_LOJA
			SZE->ZE_CONDPG   := M->ACO_CONLOG
			SZE->ZE_CONDNOV  := M->ACO_CONDPG
   	   SZE->ZE_DATALOG  := Date()       
			SZE->ZE_HORALOG  := Time()    
			SZE->ZE_USUARIO  := Substr(cUsuario,7,15)
			MsUnLock("SZE")	   
	   endif

		//************* GRAVAÇÃO LOG ITENS REGRAS DE DESCONTO ********************//

	   cQuery := ""
		cQuery += "SELECT ACP_CODPRO AS PRODUTO, ACP_PRECO AS PRECO, ACP_PROLOG, ACP_PRELOG,ACP_ITEM"   
		cQuery += "FROM "+RetSqlName("ACP")+" "
		cQuery += "WHERE ACP_FILIAL = '" +xFilial("ACP")    +"' "
		cQuery += "AND ACP_CODREG   = '" + M->ACO_CODREG    + "' 
   	cQuery += " AND D_E_L_E_T_ = ' ' ""
		
		cQuery := ChangeQuery(cQuery)  
	
		If Select("ACPQ") <> 0
			dbSelectArea("ACPQ")
			dbCloseArea()
		Endif    
	
	   TCQuery cQuery NEW ALIAS "ACPQ"   
   	
		nX := 0
   	DbSelectArea("ACPQ")
		DbGoTop()
		Do While ACPQ->(!Eof())   
		   nX := nX + 1
   	   pGrava := 'N'
  // 	   alert(nX)
//			      ALERT(aCols[nX][2])
//			      ALERT(aCols[nX][6])                                                  
			//	   If ACPQ->PRODUTO <> ACPQ->ACP_PROLOG
			If aCols[nX][2] <> ACPQ->ACP_PROLOG
				pGrava := 'S'	      
	   	EndIf                                                        
	   	
	   
			//		If ACPQ->PRECO <> ACPQ->ACP_PRELOG
			If aCols[nX][6] <> ACPQ->ACP_PRELOG
				pGrava := 'S'	      
	   	EndIf	 

			DbSelectArea("SB1")
			DbSetOrder(1)   
			DbGotop()
			DbSeek(xFilial("SB1")+ACPQ->ACP_PROLOG) 
			
			cProdAntigo := SB1->B1_DESC
			DbGotop()
			DbSeek(xFilial("SB1")+aCols[nX][2]) 			
		   cProdNovo := SB1->B1_DESC		   	                            
         
	   	DbSelectArea("ACPQ")
	  //    alert(cProdAntigo)
	  //    alert(cProdNovo)
	      
		   if pGrava == 'S'     
		   	RecLock("SZE",.T.)     
				//	   	ALERT('ENTROU')  
		  		SZE->ZE_SEQLOG   := nProxNum
		 		SZE->ZE_CODREG  := ACO->ACO_CODREG
				SZE->ZE_TABALT  := 'ACP'
				SZE->ZE_CODCLI  := ACO->ACO_CLILOG
				SZE->ZE_CODCNOV := ACO->ACO_CODCLI
				SZE->ZE_LOJA    := ACO->ACO_LOJLOG
				SZE->ZE_CODPROD := ACPQ->ACP_PROLOG
				SZE->ZE_PRODNOV := aCols[nX][2]
				SZE->ZE_PRECO   := ACPQ->ACP_PRELOG
				SZE->ZE_PRECNOV := aCols[nX][6] 
   			SZE->ZE_DATALOG := Date()
				SZE->ZE_HORALOG := Time()
				SZE->ZE_USUARIO := Substr(cUsuario,7,15)  
   	 		SZE->ZE_PRODESA  := cProdAntigo
   	 		SZE->ZE_PRODESN  := cProdNovo
				MsUnLock("SZE")	   
	   	endif                   
	   
			DbSelectArea("ACP")  
			DbSeek(xFilial("ACP") + ACO->ACO_CODREG + ACPQ->ACP_ITEM,.T.)	 
	   	
			RecLock("ACP",.F.)		   
			ACP->ACP_PROLOG  := aCols[nX][2]
			ACP->ACP_PRELOG  := aCols[nX][6]
			MsUnLock("ACP")	   
	   
	
			DbSelectArea("ACPQ")
			DbSkip()          
		EndDo

		DbSelectArea("ACO")  
		DbSeek(xFilial("ACO") + M->ACO_CODREG ,.T.)	 

   	RecLock("ACO",.F.)
	   ACO->ACO_DESLOG := ACO->ACO_DESCRI 
   	ACO->ACO_FILLOG := ACO->ACO_FILIAL   
	   ACO->ACO_CLILOG := ACO->ACO_CODCLI
   	ACO->ACO_LOJLOG := ACO->ACO_LOJA
	   ACO->ACO_CONLOG := ACO->ACO_CONDPG
		MsUnLock("ACO")
	EndIf	   	
Return()