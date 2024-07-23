#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX313    ºAutor  ³Rodrigo             º Data ³  08/12/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faturamento Lubrificantes em Litros                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10                                                       º±±                      
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX314()

	SetPrvt("aImprime")
   
	aImprime := {}   
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo,listar as vendas ")
	cDesc2        	:= OemToAnsi("de combustiveis.")
	cDesc3        	:= ""
	cPict         	:= ""
	nLin         	:= 90
	imprime      	:= .T.
	aOrd 				:= ""
	lEnd           := .F.
	lAbortPrint    := .F.
	CbTxt          := ""
	limite         := 132
	tamanho        := "G"
	nomeprog       := "AGX314"
	nTipo          := 18
	aReturn        := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey       := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX314"
	aRegistros  	:= {}
	cPerg		 	   := "AGX314"
	cString 	   	:= "SD2"  
	titulo  	      :="Faturamento Combustiveis Litros "
   cCancel 	      := "***** CANCELADO PELO OPERADOR *****"
	aRegistros     := {}            

	

	AADD(aRegistros,{cPerg,"01","Emissão de  ?","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Emissão até ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})   
	AADD(aRegistros,{cPerg,"03","Produto de  ?","mv_ch3","C",15,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"04","Produto até ?","mv_ch4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"05","Cliente de  ?","mv_ch5","C",06,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"06","Cliente até ?","mv_ch6","C",06,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","SA1"})   
	AADD(aRegistros,{cPerg,"07","Cidade  de  ?","mv_ch7","C",06,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"08","Cidade  até ?","mv_ch8","C",06,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","SA1"})   
	AADD(aRegistros,{cPerg,"09","Quant. Menor que ?","mv_ch9","C",09,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","",""})   
	
	
	U_CriaPer(cPerg,aRegistros)   
	Pergunte(cPerg,.F.)
	
   wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	
	If nLastKey == 27
	    Set Filter To
	    Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	    Set Filter To
	    Return
	Endif   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracoes de arrays                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
   
	Processa({|| GeraDados() })
     	
   RptStatus({|| RptDetail() })  

  	    
Return

Static Function GeraDados()
	SetPrvt("aSeg,aSegDA1,nRecno,cFiltroUsu")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria expressao de filtro do usuario                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*	cFiltroUsu := aReturn[7]

	aSeg  	:= GetArea()
	aSegSZF	:= SD2->(GetArea())*/

	aImprime := {}                                              

//****************************************************
   cQuery := "" 
	cQuery := "SELECT D2_CLIENTE,D2_LOJA,A1_NREDUZ,A1_MUN,A1_COD_MUN,D2_DOC,D2_SERIE,D2_EMISSAO,D2_COD,B1_DESC,D2_QUANT  "                                              
	cQuery += "FROM " + RetSqlName("SD2") + " AS D2, " + RetSqlName("SA1") + " AS A1, " + RetSqlName("SB1") + " AS B1 "
	cQuery += "WHERE D2_TP = 'CO' "
	cQuery += "AND D2_EMISSAO >= '" + DTOS(MV_PAR01) + "' "
	cQuery += "AND D2_EMISSAO <= '" + DTOS(MV_PAR02) + "' "
	cQuery += "AND D2_CLIENTE >= '" + MV_PAR05 + "' "
	cQuery += "AND D2_CLIENTE <= '" + MV_PAR06 + "' "
	cQuery += "AND D2_COD >= '" + MV_PAR03 + "' "
	cQuery += "AND D2_COD <= '" + MV_PAR04 + "' "		
	cQuery += "AND A1_COD_MUN >= '" + MV_PAR07 + "' "	
	cQuery += "AND A1_COD_MUN <= '" + MV_PAR08 + "' "				
	cQuery += "AND D2_QUANT < " + ALLTRIM(MV_PAR09)
	cQuery += "AND A1.A1_COD = D2_CLIENTE "
	cQuery += "AND A1.A1_LOJA = D2_LOJA "           
	cQuery += "AND B1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "AND B1.B1_COD = D2.D2_COD "           	    
	cQuery += "AND D2.D2_FILIAL = '" + xFilial("SD2") + "' "
	cQuery += "AND D2.D_E_L_E_T_ <> '*' "
	cQuery += "AND B1.D_E_L_E_T_ <> '*' "
	cQuery += "AND A1.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY D2_CLIENTE,D2_LOJA,D2_EMISSAO,D2_DOC "
	
	

   cQuery := ChangeQuery(cQuery)
   If Select("MTEMP") <> 0
      dbSelectArea("MTEMP")
	   dbCloseArea()
   Endif

   TCQuery cQuery NEW ALIAS "MTEMP"
   TCSetField("MTEMP","D2_EMISSAO","D",08,0)   

         
   dbSelectArea("MTEMP")
   dbGoTop()                   
   While !Eof()  

	   
	  		Aadd(aImprime,{MTEMP->D2_CLIENTE ,; //1
	  		   	       		MTEMP->D2_LOJA,; //2		
  	   							MTEMP->A1_NREDUZ,;      //3
  			   					MTEMP->A1_MUN,;         //4
	  			   				MTEMP->D2_DOC,;         //5
									MTEMP->D2_SERIE,;	  		 //6	   				
									MTEMP->D2_EMISSAO,;			 //7						
									MTEMP->D2_COD,;         //8
									MTEMP->B1_DESC,;         //9
									MTEMP->D2_QUANT,;           //10
									MTEMP->A1_COD_MUN})        //11
  	      MTEMP->(DbSkip())	  
   EndDo

Return

Static Function RptDetail	
   
   cabec1  		   := "DATA                NF/SERIE                                PRODUTO                                                        QUANTIDADE "
   cabec2       	:= "                                                                                                                               LITROS "
	
	SetRegua(Len(aImprime)) //Ajusta numero de elementos da regua de relatorios    
	
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
	
	nLin 		:= 9
	nTotVol	:= 0
	nTotFat	:= 0  
	RepCod   := ''
	GruCod   := ''
	PriVez   := 'N'  
	dDataC   := CtoD('  /  /  ')   
	Nota     := ''
	Serie    := ''         
	cCli  := ''                
	nTotUnF := 0
	nTotConvF := 0	
	nTotValF := 0	
	nTotUnG := 0
	nTotConvG := 0	
	nTotValG := 0		

//	nLin 		+= 1
//	@ nLin,000 PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
	For I := 1 to Len(aImprime)
	   If lEnd
	      Exit
	   endif
		
	   IncRegua() //Incrementa a posicao da regua de relatorios
	   
	   if nLin > 55
	   	Roda(0,"","P") 		
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
			nLin := 9			
		EndIf      
  						   	

		if cCli <> aImprime[I,1]	 
			    If PriVez <> "N"              
  		        	 nLin++                                         
  	  	      	 @ nLin,000 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------"
  	      	 	 nLin++                        
				    @ nLin,000 PSAY "TOTAL CLIENTE : " 		    
// 	    	 		 @ nLin,079 PSAY Transform(nTotUnF   ,"@E 9,999,999.99")   
				 	 @ nLin,119 PSAY Transform(nTotConvF ,"@E 99,999,999,999")   	
//					 @ nLin,139 PSAY Transform(nTotValF  ,"@E 9,999,999.99")  
					 nTotUnF   := 0
				 	 nTotConvF := 0
			  	    nTotValF  := 0
		   	 EndIf
	          nLin++     
   	       nLin++
      	    nLin++
         	 nLin++
	          cQuebra := "CLIENTE : "  + alltrim(aImprime[I,1]) + "   LOJA : " + alltrim(aImprime[I,2]) + "  - " + alltrim(aImprime[I,3]) ;
 	                  + "                      CIDADE : " + alltrim(aImprime[I,11])+ ' - ' + alltrim(aImprime[I,4])
          
			    @ nLin,000 PSAY cQuebra    	 
      	   	 
      		 cCli := aImprime[I,1]	     
	      	 nLin++                
   	   	 cLinha := ""
      		 For C := 1 to Len(cQuebra)
      		    cLinha := cLinha + "-"
	      	 Next
      	 
      	                        
   	   	 @ nLin,000 PSAY cLinha
      	    nLin++          
         	 PriVez := "S"
	      endif 	

	   							
      
   	   @ nLin,000 PSAY aImprime[I,7]			      
		 	@ nLin,020 PSAY aImprime[I,5] + "/" + aImprime[I,6] 			      
		 	@ nLin,060 PSAY aImprime[I,8] + " - " + aImprime[I,9]
		 	@ nLin,120 PSAY Transform(aImprime[I,10],"@E 99,999,999,999")   		 			 			 	
		 			 			 			 			 	
		
//			nTotUnF   += aImprime[I,5]
			nTotConvF += aImprime[I,10]
//			nTotValF  += aImprime[I,9]	
//			nTotUnG   += aImprime[I,5]
			nTotConvG += aImprime[I,10]	
//			nTotValG  += aImprime[I,9]
		          
       	nLin++                

	Next

	 	nLin++	
	 	nLin++
 		nLin++    
	   @ nLin,000 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------"
   	nLin++    
	   @ nLin,000 PSAY "TOTAL GERAL : " 		    
//   	@ nLin,079 PSAY Transform(nTotUnG   ,"@E 9,999,999.99")   
		@ nLin,119 PSAY Transform(nTotConvG ,"@E 99,999,999,999")   
//		@ nLin,139 PSAY Transform(nTotValG  ,"@E 9,999,999.99")  */ 

//	Set Filter To

  // SetPgEject(.F.) 

	If aReturn[5] == 1
		Set Printer To
		Commit
	   ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool   
Return     

