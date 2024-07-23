#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR162    �Autor  �Microsiga           � Data �  02/15/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �   Programa para recalcular os itens, quando houver         ���
���              alteracao na condicao de pagamento. 			          ���
���             														  ���
���             														  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function AGX555()    
LOCAL lEnt := .f. 




		
	nPProduto	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})


	If Len(aCols) > 0 .And. Len(aCols) == 1 .And. Empty(aCols[1][nPProduto])
		Return .T.
	EndIf
	

  //	For aa := 1 to Len(Acols)   
	
	nPPrcTab	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRCTAB"})
	nPQuant		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
	nPVrUnit	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
	nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
	nPPDesTab 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESTAB"})	
	nPPdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})		
	nPDesc    	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
	nPVlrDesc 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VALDESC"})
	nPVdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VDESCOM"})
	nPosTabAux 	 :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_AUXTAB"})  
	nPTpVlr     :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPVLR"})  
	
	nPCodPai    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_CODPAI"})	                        


	For aa := 1 to Len(Acols)  
		nPCodPai    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_CODPAI"})                        
		cTpPai      := "" 
	  
		
		CONOUT("ANTES SB1")
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbseek(xFilial("SB1")+aCols[aa][nPCodPai])
			cTpPai := SB1->B1_TIPO
		EndIf
		
			
	  	If !Empty(aCols[aa][nPCodPai]) .and. cTpPai == "SH"  //.and. aCols[aa,nPosTabAux] == 0   
	  				nPPrcTab	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRCTAB"})
					nPQuant		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
					nPVrUnit	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
					nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
					nPPDesTab 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESTAB"})	
					nPPdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})		
					nPDesc    	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
					nPVlrDesc 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VALDESC"})
					nPVdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VDESCOM"})
					nPosTabAux  :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_AUXTAB"})     
					nPTpVlr     :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPVLR"})  
					
	                        

				// Busco Preco da estrutura       
				lEnt := .t.
				cALiasSG1 := GetNextAlias()
				cCodPai   := aCols[aa][nPCodPai]
				cProduto   := aCols[aa][nPProduto]
				
				BeginSql Alias cAliasSG1  
					SELECT G1_XPVENDA, G1_QUANT
					FROM %Table:SG1% (NOLOCK) SG1
					WHERE                                                                                          
					SG1.G1_FILIAL = %xFilial:SG1% AND 
					SG1.G1_COD    = %Exp:cCodPai% AND 
					SG1.G1_COMP   = %Exp:cProduto% AND
					SG1.%notdel%
				EndSql
				                                                              
				dbSelectArea(cAliasSG1)
				dbGotop()
				While !eof()
				
					nPreComp   := (cALiasSG1)->G1_XPVENDA
					nQuantComp := (cALiasSG1)->G1_QUANT
					
		
				
				
	           
					aCols[aa][nPPrcTab] := nPreComp    
					aCols[aa,nPosTabAux]	:= aCols[aa,nPPrcTab]  
					
					If 	aCols[aa,nPTpVlr] <> "S" 
						aCols[aa,nPPrcTab]   := aCols[aa,nPPrcTab] + ROUND(((aCols[aa,nPPrcTab]* M->UA_X_ACRES) / 100),4)
					EndIf
					
					
					aCols[aa][nPVrUnit] 	:= (aCols[aa][nPPrcTab] 	- (aCols[aa][nPPrcTab] 	* aCols[aa][nPDesc] / 100))
					aCols[aa][nPVlrItem] 	:= ((aCols[aa][nPPrcTab] 	- (aCols[aa][nPPrcTab] 	* aCols[aa][nPDesc] / 100))) * aCols[aa][nPQuant]     
					
							
		  			aCols[aa][nPPrcTab]   := aCols[aa,nPosTabAux] + ROUND(((aCols[aa,nPosTabAux]* M->UA_X_ACRES) / 100),4)
			
	
					aCols[aa][nPVrUnit]	:= aCols[aa][nPPrcTab] - Round(((aCols[aa][nPPrcTab] * aCols[aa][nPDesc] /100)),4)
					aCols[aa][nPVlrItem] := aCols[aa][nPVrUnit] * aCols[aa][nPQuant]
					aCols[aa][nPVlrDesc]	:= Round(((aCols[aa][nPPrcTab] * aCols[aa][nPDesc] /100)),4) * aCols[aa][nPQuant]
					aCols[aa][nPVdescom] := Round(((aCols[aa][nPPrcTab] * aCols[aa][nPPdescom] /100)),4) * aCols[aa][nPQuant]       
					
					dbSelectArea(cAliasSG1)
					dbSkip()
				EndDo
				
				(cAliasSG1)->( dbCloseArea() )      		
				
		EndIf
		
		    
	Next aa
				

        
		Do Case 
			Case (Alltrim(ReadVar()) == "M->UB_PRODUTO")          
				If 	aCols[n,nPTpVlr] <> "S" 
			   		aCols[n,nPPrcTab]   := aCols[n,nPPrcTab] + ROUND(((aCols[n,nPPrcTab]* M->UA_X_ACRES) / 100),4)
			 	EndIf
				
				
				aCols[n][nPVrUnit] 	:= (aCols[n][nPPrcTab] 	- (aCols[n][nPPrcTab] 	* aCols[n][nPDesc] / 100))
				aCols[n][nPVlrItem] 	:= ((aCols[n][nPPrcTab] 	- (aCols[n][nPPrcTab] 	* aCols[n][nPDesc] / 100))) * aCols[n][nPQuant]     
				
						
	  			aCols[n][nPPrcTab]   := aCols[n,nPosTabAux] + ROUND(((aCols[n,nPosTabAux]* M->UA_X_ACRES) / 100),4)
		

				aCols[n][nPVrUnit]	:= aCols[n][nPPrcTab] - Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4)
				aCols[n][nPVlrItem] := aCols[n][nPVrUnit] * aCols[n][nPQuant]
				aCols[n][nPVlrDesc]	:= Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4) * aCols[n][nPQuant]
				aCols[n][nPVdescom] := Round(((aCols[n][nPPrcTab] * aCols[n][nPPdescom] /100)),4) * aCols[n][nPQuant] 
			Case (Alltrim(ReadVar()) == "M->UB_QUANT")  
//				aCols[n][nPVlrItem] 	:= ((aCols[n][nPPrcTab] 	- (aCols[n][nPPrcTab] 	* aCols[n][nPDesc] / 100))) * aCols[n][nPQuant]     
				
						
//	  			aCols[n][nPPrcTab]   := aCols[n,nPosTabAux] + ROUND(((aCols[n,nPosTabAux]* M->UA_X_ACRES) / 100),4)
		

//				aCols[n][nPVrUnit]	:= aCols[n][nPPrcTab] - Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4)
				aCols[n][nPVlrItem] := aCols[n][nPVrUnit] * aCols[n][nPQuant]
				aCols[n][nPVlrDesc]	:= Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4) * aCols[n][nPQuant]
				aCols[n][nPVdescom] := Round(((aCols[n][nPPrcTab] * aCols[n][nPPdescom] /100)),4) * aCols[n][nPQuant] 
			/*OtherWise 
				aCols[n,nPPrcTab]   := aCols[n,nPPrcTab] + ROUND(((aCols[n,nPPrcTab]* M->UA_X_ACRES) / 100),4)
				
				
				aCols[n][nPVrUnit] 	:= (aCols[n][nPPrcTab] 	- (aCols[n][nPPrcTab] 	* aCols[n][nPDesc] / 100))
				aCols[n][nPVlrItem] 	:= ((aCols[n][nPPrcTab] 	- (aCols[n][nPPrcTab] 	* aCols[n][nPDesc] / 100))) * aCols[n][nPQuant]     
				
						
	  			aCols[n][nPPrcTab]   := aCols[n,nPosTabAux] + ROUND(((aCols[n,nPosTabAux]* M->UA_X_ACRES) / 100),4)
		

				aCols[n][nPVrUnit]	:= aCols[n][nPPrcTab] - Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4)
				aCols[n][nPVlrItem] := aCols[n][nPVrUnit] * aCols[n][nPQuant]
				aCols[n][nPVlrDesc]	:= Round(((aCols[n][nPPrcTab] * aCols[n][nPDesc] /100)),4) * aCols[n][nPQuant]
				aCols[n][nPVdescom] := Round(((aCols[n][nPPrcTab] * aCols[n][nPPdescom] /100)),4) * aCols[n][nPQuant]           */
		EndCase
							
//	Next n
   
    If lEnt
		nVlrMerc := 0
		nVlrPedi	:= 0
		nVlrFat  := 0  //aqui
		For xx := 1 to Len(aCols)
			If !( aCols[xx][Len(aCols[xx])] )//Deletado												
				nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
				nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem]		
				nVlrFat  := nVlrFat + aCols[xx][nPVlrItem]		//aqui
	
			EndIf			
		Next xx
	
		aValores[1] := Round(NoRound(nVlrMerc,4),2)
		aValores[6] := Round(NoRound(nVlrPedi,4),2)
		aValores[8] := Round(NoRound(nVlrFat,4),2)   // aqui
	   
	
		oGettlv:oBrowse:Refresh()   
	EndIf
	
Return .T.