


USer Function MSGWFAC()

Local aMsg 	:= Paramixb[1]
Local cCGC	:= Paramixb[2]
Local nVal	:= Paramixb[3]
Local cMot	:= Paramixb[4]

/*Local aMsg 	:= {}
Local cCGC	:= ""
Local nVal	:= 0
Local cMot	:= ""
    RpcSetType(3)
	RPCSetEnv("01","06","","","","",{"ZZD"})      */            


//CONOUT("ENTROU NO MSGWFAC")



AADD(aMsg, " ")
AADD(aMsg, " ")
AADD(aMsg, "---------------------------------------------------------------------------")
AADD(aMsg, "CGC: "+cCGC+" "+SA1->A1_NOME )
AADD(aMsg, "Valor Pedido: "+TRansform(nVal,"@E 99,999,999,999.99"))
AADD(aMsg, " ")
AADD(aMsg, "---------------------------------------------------------------------------")


IF( "TITULO" $ cMot .or. "LIMITE" $ cMot ) .AND. SA1->A1_CONSER == "1"
//IF 1=1
//	AADD(aMsg, "Relatorio Serasa")
//	AADD(aMsg, "---------------------------------------------------------------------------")
	AADD(aMsg, " ")
	AADD(aMsg, "----------------------RETORNO SERASA GESTOR CREDITO------------------------")
	AADD(aMsg, " ")
  //	AADD(aMsg, "PEDIDO : "  + SC5->C5_NUM)
	AADD(aMsg, " ")
	AADD(aMsg, " ")	
	cStatus := ""  
   	dbSelectArea("ZZD")
	dbSetOrder(1)
	If !dbseek(xFilial("ZZD")+SC5->C5_NUM )   
//	If !dbseek(xFilial("ZZD")+"105429" )     
	  	AADD(aMsg, "Pedido não consultado no SERASA!")
	  cStatus = "NÃO APROVADO"                                                          
	else
	                           
	    
		cTexto   := "" 
		cTexto   := ZZD->ZZD_RET
		cStatus  := "" 
		cDescRet := "" 
			     
		cTxtLinha := "" 
		cLinha    := ""
		nLinhas := MLCount(cTexto,70) 
		For nXi:= 1 To nLinhas
			cTxtLinha := MemoLine(cTexto,70,nXi)
			If ! Empty(cTxtLinha)		        
				cLinha+= cTxtLinha		        
			EndIf
		Next nXi               
		
		cResult := "" 
	    cResult := SUBSTR(cLinha,At("MSGE_DESC",cLinha)+11,At("LIMITE =",cLinha)-(At("MSGE_DESC",cLinha)+11))
	    
	    AADD(aMsg, "")
   	    AADD(aMsg, "")
		AADD(aMsg, "RESULTADO CRÉDITO: " + alltrim(cResult) )	    
	    AADD(aMsg, "")	    
	    
		cLinha := SUBSTR(cLinha,At("DADOSPOLITICA",cLinha)+16,At("TIPO_DEC",cLinha)-At("DADOSPOLITICA",cLinha))
	                  		
	
		nTamStr := 0
		nTamStr := len(cLinha)
		
	
		cPergu := "" 
		cRespo := ""      
		nCont  := 1  
		
		For nXi := 1 To nTamStr   	    
			If substr(cLinha,nXi,1) == "@"    		 
		       cPergu := alltrim(STRTRAN(SubStr(cLinha , nCont,  (nXi) - nCont),CHR(8),"")) 
		       
		       
		       nx := 0
			   while (nx := At("  ",cPergu)) > 0
	              cPergu     := strtran(cPergu,"  "," ")
	           Enddo
	           //Alert(cPergu)
		       
		       nCont := nXi + 1
		    EndIf
		    If substr(cLinha,nXi,1) == "|" 
		       If substr(cPergu,1,4) == "DATA"
			      cRespo := dtoc((stod(alltrim(SubStr(cLinha , nCont,  (nXi) - nCont  )))))
			   else
			      cRespo := alltrim(SubStr(cLinha , nCont,  (nXi) - nCont  ))
			   EndIf    
	            nCont := nXi + 1  
                

				cTESTE:= "" 
				cTESTE:= alltrim(cPergu)+ replicate(" ",40-LEN(alltrim(cPergu))) + " - " + cRespo
				
				CONOUT(cTESTE)
			   	AADD(aMsg, alltrim(cPergu)+ replicate(" ",40-LEN(alltrim(cPergu))) + " - " + cRespo)
			   
		    EndIf
   
		Next nXi            
	
	EndIf 
	
EndIF   

//    RpcClearEnv()
Return(aMsg)

