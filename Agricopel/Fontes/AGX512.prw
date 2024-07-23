#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX512    ºAutor  ³Microsiga           º Data ³  05/15/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna tabela atendimento Call Center                    º±±
±±º          ³ ROTINA JA VERIFICADA VIA XAGLOGRT                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX512()
LOCAL cVend    := TKOPERADOR()

Private cTabela := "001" 
    If cEmpAnt == "01" 
      // limpar campo UA_TIPOCLI, usuária preenche manualmente para atender situação DRCST
      // M->UA_TIPOCLI := ""

    	If cFilAnt == "06" .or. cFilAnt == "19" 
	        If ALLTRIM(SA1->A1_GRPVEN) <> "" 
		    	cQuery := ""    	        
    			cQuery := "SELECT DA0_CODTAB FROM " + RetSqlName("DA0") + " (NOLOCK) "
    			cQuery += " WHERE DA0_FILIAL  = '" + xFilial("DA0") + "' " 
	    		cQuery += "   AND DA0_GRPCLI  = '" + SA1->A1_GRPVEN + "' " 
	    		cQuery += "   AND DA0_ATIVO <> '2' AND D_E_L_E_T_ <> '*' "
    
    	  		If Select("QRY_DA0") <> 0
					dbSelectArea("QRY_DA0")
		  			dbCloseArea()
		   		Endif               	

				TCQuery cQuery NEW ALIAS "QRY_DA0"
		                     
				dbSelectArea("QRY_DA0")
				dbGoTop()   
				
				If ALLTRIM(QRY_DA0->DA0_CODTAB) <> "" 
		   	       cTabela := QRY_DA0->DA0_CODTAB
		   	    EndIf
		  	Else
		  		Alert("Tabela de preço não encontrada para grupo de vendas! Entre em contato com a coordenação de vendas!")
		  		cTabela := ""
		  	EndIf      
		Else 
		  If (cFilAnt == "03" .or. cFilAnt $ "11/15/16/17/18/05" )
            cTabela := "888" 
          //Else
          //  If cFilAnt == "02"
          //   cTabela := "777"
          //  EndIf
          EndIf  
		EndIf
	EndIf
	
	If (cEmpAnt == "11" .or. cEmpAnt == "15") //cEmpAnt == "12" .or.
      cTabela := "888"
	EndIf

   //Selecao vendedores
   If SU7->U7_ARMAZEM <> "02"
      M->UA_vend    := SA1->A1_vend
      M->UA_descven := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend,"A3_NOME")
      M->UA_vend3   := SA1->A1_vend3
      M->UA_descve3 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend3,"A3_NOME")

      if (cEmpAnt == "01" .and. (cFilAnt == "03" .or. cFilAnt == "16")) .or. (cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15")
         M->UA_VEND2   := SA1->A1_VEND5
         M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND5,"A3_NOME")
      Else
         M->UA_vend2   := SA1->A1_vend2
         M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend2,"A3_NOME")
      endif
	Else
       If  AllTrim(SA1->A1_VEND4) == "" 
          M->UA_vend    := SA1->A1_VEND
          M->UA_descven := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend,"A3_NOME")
       Else
          M->UA_vend    := SA1->A1_VEND4
          M->UA_descven := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND4,"A3_NOME")
       EndIf

       if (cEmpAnt == "01" .and. (cFilAnt == "03" .or. cFilAnt == "15" .or. cFilAnt == "16" .or.  cFilAnt == "17" .or.  cFilAnt == "18" .or.  cFilAnt == "05")) .or. (cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15")
          M->UA_vend2   := SA1->A1_VEND5
          M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND5,"A3_NOME")
       Else
          M->UA_vend2   := SA1->A1_vend2
          M->UA_descve2 := Posicione("SA3",1,xFilial("SA3")+SA1->A1_vend2,"A3_NOME")
       endif
	EndIf   
	
Return(cTabela)
