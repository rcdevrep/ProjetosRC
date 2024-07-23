#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"
#INCLUDE "colors.ch"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX475  ºAutor  Glomer               º Data ³  07/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PONTO DE ENTRADA MTA410T PARA ALTERACAO NOS ITENS DO PEDIDOº±±
±±º          ³ DE VENDA                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function AGX475(cPedido,cCliCod,cCliLoja,nTotalPed) 
Local   cQuery := ""   
cSerasa := "" 


//alert("1")

If SM0->M0_CODIGO <> "01"
   return()
EndIf    
                 
         
cSerasa :=  GetMV("MV_CONSER")  //Consulta Serasa.

//ALERT("TOTAL PED")
//ALERT(nTotalPed)


If cSerasa == "N" 
   return()
EndIf

//alert("2")

If SM0->M0_CODIGO = "01" .and. (SM0->M0_CODFIL = "02" .or. SM0->M0_CODFIL = "06")

	aImpArq  := {} 
	cArq     := ""  
	lConsulta := .f.
	
	Aadd(aImpArq,{"INFO"      ,"C",1000,0,"C"})     //INFO
	Aadd(aImpArq,{"REC"       ,"N",9999999,0,"C"})  //REC               
	Aadd(aImpArq,{"REG"       ,"C",6,0,"C"})        //REGISTRO
	

   //BUSCO CPF/CNPJ CLIENTE
   cCgc := ""  
   cTipoPes := "" 
   dUltComp := "" 
   cRisco   := ""
   nSalCred := 0      
 
   dbSelectArea("SA1")
   dbSetOrder(1)
   If !dbseek(xFilial("SA1")+cCliCod+cCliLoja)
       Alert("Cliente Nao encontrado")
       return()
   Else
   
     //atualizo totalizador no cliente de pedidos liberados
     
      cQuery := "" 
      cQuery := "SELECT C5_CLIENTE,C5_LOJACLI ,SUM(C6_VALOR) TOTAL FROM " + RetSqlName("SC5") + " C5,"  + RetSqlName("SC6") + " C6 "
      cQuery += " WHERE C5_LIBEROK <> ''  AND C5_NOTA = ''  AND C5_BLQ = ''  AND C5.D_E_L_E_T_ <> '*'  AND C6.C6_FILIAL = C5_FILIAL "
      cQuery += "  AND C6_NUM = C5_NUM   AND C6.D_E_L_E_T_ <> '*' AND C5_CLIENTE = '" + SA1->A1_COD + "' AND C5_LOJACLI = '" + SA1->A1_LOJA + "' "
      cQuery += " GROUP BY  C5_CLIENTE,C5_LOJACLI "           
      
      
 	  If  (Select("MSC5") <> 0)
    	  dbSelectArea("MSC5")
	   	  dbCloseArea()
      Endif
      cQuery := ChangeQuery(cQuery)
      TCQuery cQuery NEW ALIAS "MSC5"
      
      
      nTotPedLib := 0
      dbSelectArea("MSC5")
      dbGoTop()
      Do While !eof()
         nTotPedLib := MSC5->TOTAL
         MSC5->(dbSkip())
      EndDo
         
 
      
      // Totaliza pedidos em aberto
      cQuery := "" 
      cQuery := "SELECT C5_CLIENTE,C5_LOJACLI ,SUM(C6_VALOR) TOTAL FROM " + RetSqlName("SC5") + " C5,"  + RetSqlName("SC6") + " C6 "
      cQuery += " WHERE C5_LIBEROK = ''  AND C5_NOTA = ''  AND C5_BLQ = ''  AND C5.D_E_L_E_T_ <> '*'  AND C6.C6_FILIAL = C5_FILIAL "
      cQuery += "  AND C6_NUM = C5_NUM   AND C6.D_E_L_E_T_ <> '*' AND C5_CLIENTE = '" + SA1->A1_COD + "' AND C5_LOJACLI = '" + SA1->A1_LOJA + "' "
      cQuery += " GROUP BY  C5_CLIENTE,C5_LOJACLI "           
      
      
 	  If  (Select("MSC5") <> 0)
    	  dbSelectArea("MSC5")
	   	  dbCloseArea()
      Endif
      cQuery := ChangeQuery(cQuery)
      TCQuery cQuery NEW ALIAS "MSC5"
      
      
      nTotPedAbe := 0
      dbSelectArea("MSC5")
      dbGoTop()
      Do While !eof()
         nTotPedAbe := MSC5->TOTAL
         MSC5->(dbSkip())
      EndDo        
      
      //Atualizo no cadastro de clientes os campos de total liberado pedido e em aberto
      
//       RecLock("SA1",.F.)
//          SA1->A1_SALPEDL := nTotPedLib
//          SA1->A1_SALPED  := nTotPedAbe
//       MsUnLock()  
      
       
     //*******************************************************
     If SA1->A1_RISCO == "A" 
        dbSelectArea("SA1")
        RecLock("SA1",.F.)  
           SA1->A1_RETSER := "CLIENTE RISCO A - PEDIDOS LIBERADOS SEM APROVACAO"        
        MsUnLock()  
        return()
     EndIf   

//alert("3")                   
      dbSelectArea("SA1")
      RecLock("SA1",.F.)    
         SA1->A1_RISCO  := "B"    
         SA1->A1_RETSER := "" 	              
      MsUnLock()
      
      
//      alert("zerou")
      cCgc := alltrim(SA1->A1_CGC)
      cTipoPes := SA1->A1_PESSOA     
      dUltComp := SA1->A1_ULTCOM
      cRisco   := SA1->A1_RISCO                      
      cConSer  := SA1->A1_CONSER
      nSalCred := SA1->A1_LC- SA1->A1_SALDUPM - SA1->A1_SALPEDL - SA1->A1_SALPEDB - nTotalPed 
      cCliCod  := SA1->A1_COD
      cCliLoj  := SA1->A1_LOJA
   Endif
   
   
   
   nDifMes := 0                                                                                                                       
   nDifMes := DateDiffMonth( dUltComp , ddatabase )  
          
   
//   alert("4")
   
   cQuery := ""
   cQuery += "SELECT COALESCE(SUM(E1_VALOR),0) SALDDUP FROM " +RetSqlName("SE1")+ " (NOLOCK) "
   cQuery += "WHERE E1_CLIENTE = '" + cClicod + "' "   
   cQuery += "  AND E1_LOJA    = '" + cCliLoja + "' "      
   cQuery += "  AND E1_SALDO > 0 "
   cQuery += "  AND E1_VENCREA < '" + DTOS(dDataBase-5) +  "' "
   cQuery += "  AND D_E_L_E_T_ <> '*' "   
   cQuery += "  AND E1_TIPO NOT IN('RA','NCC','NCA') "   
   
   
   If  (Select("MSE1") <> 0)
      dbSelectArea("MSE1")
	   dbCloseArea()
   Endif
   cQuery := ChangeQuery(cQuery)
   TCQuery cQuery NEW ALIAS "MSE1"   
 
   nSalDup := 0
   dbSelectArea("MSE1")
   dbgotop()
   While !eof()
      nSalDup := MSE1->SALDDUP
      MSE1->(dbSkip())
   EndDo
 

//   alert("5")

//   alert(dUltComp)   

   If nDifMes > 9    
      dbSelectArea("SA1")    
      RecLock("SA1",.F.)    
         SA1->A1_RISCO  := "E"   
         SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) + "|CLIENTE SEM COMPRA DURANTE " + alltrim(str(nDifMes)) + " MESES!!"	    	              
         lConsulta := .t.
      MsUnLock()               
   elseif alltrim(dtos(dUltComp)) == "" 
          dbSelectArea("SA1")    
          RecLock("SA1",.F.)    
             SA1->A1_RISCO  := "E"   
             SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) +  "|CLIENTE SEM NENHUMA COMPRA"	    	              
             lConsulta := .t.
          MsUnLock()             
        //  Return()   
   EndIf      
             
//   alert("6")          


//  ALERT(nSalDup)
//  Alert(nSalCred)
 
   If nSalDup <= 0 .and. nSalCred > 0 
        dbSelectArea("SA1")  
        RecLock("SA1",.F.)          
           SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) +  "|CLIENTE COM CREDITO INTERNO OU SEM SALDO DEVEDOR"        
        MsUnLock()  
   //     return()                 
   Else
     dbSelectArea("SA1")  
        RecLock("SA1",.F.)  
           SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) +  "|CLIENTE SEM CREDITO INTERNO OU COM SALDO DEVEDOR JUNTO A EMPRESA."    
           lConsulta := .t.    
        MsUnLock()     
   EndIf   
   

   If cConSer == "2"
      dbSelectArea("SA1")    
      RecLock("SA1",.F.)      
         SA1->A1_RISCO  := "B"   
         SA1->A1_RETSER := "|CLIENTE CONFIGURADO PARA NAO CONSULTAR SERASA"	              
      MsUnLock()             
      Return()
   EndIf         
   
   
   If !lConsulta    
      dbSelectArea("SA1")    
      RecLock("SA1",.F.)      
         SA1->A1_RISCO  := "B"   
         SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) + "|NAO CONSULTA SERASA"	              
      MsUnLock()         
      Return()
   EndIf          
   
   dbSelectArea("SA1")    
   RecLock("SA1",.F.)      
      SA1->A1_RISCO  := "E"   
      SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) + "|CONSULTA SERASA|"	              
   MsUnLock()         
   
   
   Processa({|| fGestorCred(cPedido,cCliCod,cCliLoja,nTotalPed)})
   //       ApMsgInfo("Dados processados com sucesso !")
   
//   alert("depois processa")
    //VERIFICO CREDITO NA ZZD PARA BLOQUEAR OS PEDIDOS.
	cStatus := "" 

	dbSelectArea("ZZD")
	dbSetOrder(1)
	If !dbseek(xFilial("ZZD")+cPedido)      
	  alert("Pedido não consultado no SERASA. Crédito bloqueado! Falha na Comunicação!")
	  cStatus = "NÃO APROVADO"                                                          
      dbSelectArea("SA1")    
      RecLock("SA1",.F.)    
	     SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) + "Pedido não consultado no SERASA. Crédito bloqueado! Falha na Comunicação!"
  	     SA1->A1_RISCO := "E"         
      MsUnLock()
	  RETURN()
	else
		cTexto := "" 
		cTexto := ZZD->ZZD_RET
		cStatus := "" 
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
		       
		
		cRetorno := "" 
		       
		CONOUT(SUBSTR(cLinha,At("MSGE_TIPO =",cLinha),At("MSGE_DES",cLinha)-At("MSGE_TIPO =",cLinha)))    
	    cStatus := SUBSTR(cLinha,At("MSGE_TIPO =",cLinha),At("MSGE_DES",cLinha)-At("MSGE_TIPO =",cLinha))    
	    
	           
	    cStatus := ALLTRIM(SUBSTR(cStatus,At("=",cStatus)+1,30))        
	    cRetorno := ""       
	    
	    cRetorno := SUBSTR(cLinha,At("MSGE_DES",cLinha),At("LIMITE =",cLinha)-At("MSGE_DES",cLinha))
	    
	//    alert(cRetorno)                                         
	    
	    cRetorno := ALLTRIM(SUBSTR(cRetorno,At("=",cRetorno)+1,500))        
	    
	    CONOUT(cStatus)                                         
	        
	    If cStatus == "APROVADO" 
	//       alert(cStatus)
	    else 
	//       alert(cStatus)
	    EndIf           
	           
	    CONOUT("==============================================================" )
	    CONOUT(SUBSTR(cLinha,At("MSGE_DES",cLinha),At("LIMITE =",cLinha)-At("MSGE_DES",cLinha)))    
	    CONOUT("==============================================================" )
	    CONOUT(SUBSTR(cLinha,At("LIMITE =",cLinha),At("POLITICA =",cLinha)-At("LIMITE =",cLinha)))   
	    CONOUT("==============================================================" )
	    CONOUT(SUBSTR(cLinha,At("DADOSPOLITICA",cLinha),At("TIPO_DEC",cLinha)-At("DADOSPOLITICA",cLinha)))  
	    
	    
        dbSelectArea("SA1") 
        dbSetOrder(1)
        If dbseek(xFilial("SA1")+cCliCod+cCliLoja)     

	        RecLock("SA1",.F.)    
	             cRet := "" 	             
	             SA1->A1_RETSER := ALLTRIM(SA1->A1_RETSER) + ALLTRIM(substr(cRetorno,1,999))
	  	              SA1->A1_RISCO := "E"
	        MsUnLock()
        EndIf
	
	EndIf
	
	
	
/*	If nDifMes > 9
	   cStatus := "NÃO APROVADO"
	EndIf*/
	
/*   dbSelectArea("SA1") 
   dbSetOrder(1)
   If dbseek(xFilial("SA1")+cCliCod+cCliLoja)     


       RecLock("SA1",.F.)
             cRet := ""
             SA1->A1_RETSER := SA1->A1_RETSER + ALLTRIM(substr(cRetorno,1,999))
  	              SA1->A1_RISCO := "E"
       MsUnLock()
   EndIf   */
EndIf
//EndIf            


//ATUALIZA TABELAS

Return()   

Static Function fGestorCred(cPed,cCli,cLoja,nTot)
Local oWS     := WSwsgestordecisao():New()
Local cResult := ""    
//oWS := WsClassNew( "WSwsgestordecisao" )            

//BUSCO CLIENTE   

cScore := "" 

If cTipoPes == "F"
   cScore := "CSB5"
else     
   cScore := "    "
EndIf

//ALERT(nTot)
         
nTot := round(nTot,0)
//alert(nTotalPed)


//csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine 
//If oWS:AnalisarCredito("81632093000179","86020488","81632093","86014056","5674",MV_PAR02,MV_PAR03,"    ",.F.,.F.,"VALORPEDIDO@1000|DATADOPEDIDO@14/06/2011")

If oWS:AnalisarCredito("81632093000179","RODRIGO","123456","86020488","mime",cCgc,nTot,cScore,.F.,.F.,"")
   cResult:= oWS:cAnalisarCreditoResult
//   alert(cResult)
//   alert("server ok")
   
   
///   alert(xFilial("ZZD"))
   dbSelectArea("ZZD")    
   dbSetOrder(1)
   IF !dbSeek(xFilial("ZZD") + cPed)
      RecLock("ZZD",.T.)  
         ZZD->ZZD_FILIAL := xFilial("ZZD")
         ZZD->ZZD_PEDIDO := cPed
         ZZD->ZZD_CLICOD := cCli
         ZZD->ZZD_CLILOJ := cLoja
         ZZD->ZZD_DTCON  := dDataBase
         ZZD->ZZD_VALOR  := nTot
         ZZD->ZZD_RET    := cResult   
         ZZD->ZZD_SITUAC := alltrim(SUBSTRING(cResult,22,10) )
         ZZD->ZZD_TEXTO  := cResult
      MsUnLock()
   else
      RecLock("ZZD",.F.) 
         ZZD->ZZD_DTCON := dDataBase
         ZZD->ZZD_VALOR  := nTot
         ZZD->ZZD_RET    := cResult                           
         ZZD->ZZD_SITUAC := alltrim(SUBSTRING(cResult,22,10) )
      MsUnLock()
   EndIf
             
Else
   alert('Erro de Execução : '+GetWSCError())
Endif     

 
Return()                   
