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

User Function AGX313()

	SetPrvt("aImprime")
   
	aImprime := {}   
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo,listar as vendas ")
	cDesc2        	:= OemToAnsi("de lubrificantes em litros.")
	cDesc3        	:= ""
	cPict         	:= ""
	nLin         	:=  9
	imprime      	:= .T.
	aOrd 				:= ""
	lEnd           := .F.
	lAbortPrint    := .F.
	CbTxt          := ""
	limite         := 220
	tamanho        := "G"
	nomeprog       := "AGX313"
	nTipo          := 0
	aReturn        := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey       := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX313"
	aRegistros  	:= {}
	cPerg		 	   := "AGX313"
	cString 	   	:= "SD1"  
	titulo  	      :="Fat. Lubrificantes em Litros"
   cCancel 	      := "***** CANCELADO PELO OPERADOR *****"
	aRegistros     := {}            

	
	AADD(aRegistros,{cPerg,"01","Ano 1 ?","mv_ch1","C",04,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Ano 2 ?","mv_ch2","C",04,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})   
	AADD(aRegistros,{cPerg,"03","Familia de    ?","mv_ch3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","SA2"})
	AADD(aRegistros,{cPerg,"04","Familia até   ?","mv_ch4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SA2"})
	AADD(aRegistros,{cPerg,"05","Produto de    ?","mv_ch5","C",15,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"06","Produto até   ?","mv_ch6","C",15,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"07","Representante de   ?","mv_ch7","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","SA3"})
	AADD(aRegistros,{cPerg,"08","Representante até  ?","mv_ch8","C",6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","SA3"})
	AADD(aRegistros,{cPerg,"09","Televendas de      ?","mv_ch9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","SA3"})
	AADD(aRegistros,{cPerg,"10","Televendas até     ?","mv_ch10","C",6,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","SA3"})	   
	AADD(aRegistros,{cPerg,"11","Emissão de  ?","mv_ch11","D",08,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Emissão até ?","mv_ch12","D",08,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","",""})  	                                                                                                                                               
	AADD(aRegistros,{cPerg,"13","Representante/Televendas    ?","mv_ch13","N",01,0,0,"C","","MV_PAR13","REPRESENTANTE","","","TELEVENDAS","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"14","Estado de  ?","mv_ch11","C",02,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"15","Estado até ?","mv_ch12","C",02,0,0,"G","","MV_PAR15","","","","","","","","","","","","","","",""})  
	AADD(aRegistros,{cPerg,"16","Cidade de  ?","mv_ch11","C",07,0,0,"G","","MV_PAR16","","","","","","","","","","","","","","","CC2"})
	AADD(aRegistros,{cPerg,"17","Cidade até ?","mv_ch12","C",07,0,0,"G","","MV_PAR17","","","","","","","","","","","","","","","CC2"})  
	
	
//	AADD(aRegistros,{cPerg,"13","Filial de    ?","mv_ch13","C",02,0,0,"G","","MV_PAR13","","","","","","","","","","","","","","",""})
//	AADD(aRegistros,{cPerg,"14","Filial até   ?","mv_ch14","C",02,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","",""})


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
	If MV_PAR13 == 1
		cQuery := "SELECT D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND2,A3.A3_NREDUZ, "                                              
	else
	   cQuery := "SELECT D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND1,A3.A3_NREDUZ, "                                              
	endif   
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '1' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS JAN1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '2' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS FEV1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '3' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS MAR1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '4' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS ABR1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '5' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS MAI1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '6' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS JUN1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '7' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS JUL1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '8' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS AGO1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '9' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS SET1,"  	                        
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '10' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS OUT1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '11' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS NOV1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '12' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS DEZ1,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '1' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS JAN2,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '2' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS FEV2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '3' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS MAR2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '4' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS ABR2,"  		                                                                                                                                                            
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '5' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS MAI2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '6' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS JUN2,"  	
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '7' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS JUL2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '8' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS AGO2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '9' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS SET2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '10' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS OUT2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '11' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS NOV2,"  		
	cQuery += "ROUND(SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(MONTH,D2_EMISSAO)))) = '12' AND LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "  
	cQuery += "THEN D2_QUANT * B1_CONV END),0) AS DEZ2,"  			
   cQuery += "SUM(D2_QUANT)AS TOTAL_QUANT, SUM(D2_QUANT * B1_CONV) AS TOTAL_CONV, SUM(D2_TOTAL ) AS TOTAL_RS "    	   
	cQuery += "FROM " + RetSqlName("SD2") + " AS D2, " + RetSqlName("SB1") + " AS B1, " + RetSqlName("SA2") + " AS A2, " + RetSqlName("SF2") + " AS F2, " ;
				+ RetSqlName("SA3") + " AS A3, " + RetSqlName("SA1") + " AS A1 "
	cQuery += "WHERE D2.D2_FILIAL  = '" + xFilial("SD2")   + "' "    
	cQuery += "AND B1.B1_FILIAL  = '" + xFilial("SB1")   + "' "    
	cQuery += "AND D2.D2_COD  >= '" + MV_PAR05 + "' "  
	cQuery += "AND D2.D2_COD  <= '" + MV_PAR06 + "' "  
	cQuery += "AND B1.B1_PROC >= '" + MV_PAR03 + "' "  
	cQuery += "AND B1.B1_PROC <= '" + MV_PAR04 + "' "  
	cQuery += "AND B1.B1_PROC <> '000109' "  
	cQuery += "AND B1.B1_PROC <> '001449' "  
	cQuery += "AND (LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 +  "' OR LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "')"
	cQuery += "AND B1_COD = D2_COD AND A2_COD = B1_PROC  AND A2_CLASSIF = '00' AND A2_LOJA = '01' "  
	cQuery += "AND D2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*' AND A2.D_E_L_E_T_ <> '*' AND D2_TP = 'LU' AND F2.F2_FILIAL = D2.D2_FILIAL "
	cQuery += "AND F2.F2_DOC = D2.D2_DOC  AND F2.F2_SERIE = D2.D2_SERIE  AND F2.D_E_L_E_T_ <> '*' "
	cQuery += "AND F2.F2_EST >= '" + MV_PAR14 + "' "
	cQuery += "AND F2.F2_EST <= '" + MV_PAR15 + "' "
	cQuery += "AND A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA AND A1.D_E_L_E_T_ <> '*' "	
	cQuery += "AND A1.A1_COD_MUN >= '" + MV_PAR16 + "' "
	cQuery += "AND A1.A1_COD_MUN <= '" + MV_PAR17 + "' "
	cQuery += "AND A1.D_E_L_E_T_ <> '*'
	
	
	if MV_PAR13 == 1                                                                              
	   cQuery += "AND LTRIM(RTRIM(F2.F2_VEND2)) <> ''  "  
   	cQuery += "AND A3.A3_COD = F2.F2_VEND2  AND A3.D_E_L_E_T_ <> '*' "	
		cQuery += "AND F2.F2_VEND2 >= '" + MV_PAR07 + "' "  
		cQuery += "AND F2.F2_VEND2 <= '" + MV_PAR08 + "' "   
		cQuery += "AND D2_EMISSAO >= '" + DTOS(MV_PAR11) + "' "
		cQuery += "AND D2_EMISSAO <= '" + DTOS(MV_PAR12) + "' "
		cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ,F2.F2_VEND2,A3.A3_NREDUZ "  
		cQuery += "ORDER BY D2_FILIAL,F2_VEND2,B1_PROC	 "        
	else                                                   
	   cQuery += "AND LTRIM(RTRIM(F2.F2_VEND1)) <> ''  "  
   	cQuery += "AND A3.A3_COD = F2.F2_VEND1  AND A3.D_E_L_E_T_ <> '*' "	
		cQuery += "AND SUBSTRING(F2.F2_VEND1,1,2) = 'RT'  " 
		cQuery += "AND F2.F2_VEND1 >= '" + MV_PAR09 + "' "  
		cQuery += "AND F2.F2_VEND1 <= '" + MV_PAR10 + "' "  
		cQuery += "AND D2_EMISSAO >= '" + DTOS(MV_PAR11) + "' "
		cQuery += "AND D2_EMISSAO <= '" + DTOS(MV_PAR12) + "' "
		cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ,F2.F2_VEND1,A3.A3_NREDUZ "  
		cQuery += "ORDER BY D2_FILIAL,F2_VEND1,B1_PROC	 "        	
	end
	
	

   cQuery := ChangeQuery(cQuery)
   If Select("MTEMP") <> 0
      dbSelectArea("MTEMP")
	   dbCloseArea()
   Endif

   TCQuery cQuery NEW ALIAS "MTEMP"
//   TCSetField("MTEMP","ZE_DATALOG","D",08,0)   

         
   dbSelectArea("MTEMP")
   dbGoTop()                   
   While !Eof()  
  	     
  	     cVEND := ''                          
        If MV_PAR13 == 1
           cVEND := MTEMP->F2_VEND2
        else 
           cVEND := MTEMP->F2_VEND1 
        EndIf             	   
  	   
	  		Aadd(aImprime,{cVEND ,; //1
	  		   	       		MTEMP->A3_NREDUZ,; //2		
   	  	   	       		MTEMP->A2_NREDUZ,;    //3
  	   							MTEMP->B1_PROC,;      //4
  			   					MTEMP->JAN1,;         //5
	  			   				MTEMP->FEV1,;         //6
									MTEMP->MAR1,;	  		 //7	   				
									MTEMP->ABR1,;			 //8						
									MTEMP->MAI1,;         //9
									MTEMP->JUN1,;         //10
									MTEMP->JUL1,;         //11
									MTEMP->AGO1,;         //12
									MTEMP->SET1,;         //13
									MTEMP->OUT1,;         //14
									MTEMP->NOV1,;         //15
									MTEMP->DEZ1,;         //16
									MTEMP->JAN2,;         //17
									MTEMP->FEV2,;		    //18							
									MTEMP->MAR2,;			 //19						
									MTEMP->ABR2,;         //20
									MTEMP->MAI2,;         //21
									MTEMP->JUN2,;         //22
									MTEMP->JUL2,;         //23
									MTEMP->AGO2,;         //24
									MTEMP->SET2,;         //25
									MTEMP->OUT2,;         //26
									MTEMP->NOV2,;         //27
									MTEMP->DEZ2})        //28
  	      MTEMP->(DbSkip())	                  
   EndDo                                     


Return

Static Function RptDetail	
   
   cabec1  		   := "|      JAN       |       FEV       |       MAR       |       ABR       |       MAI       |       JUN       |       JUL       |       AGO       |       SET      |       OUT       |       NOV     |       DEZ       |"
   cabec2       	:= "|   2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008    2009|    2008     2009|    2008   2009|    2008     2009|"

	
   
   
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
	cRepre  := ''                
	nTotUnF := 0
	nTotConvF := 0	
	nTotValF := 0	
	nTotUnG := 0
	nTotConvG := 0	
	nTotValG := 0		
  
   nTotJan1 := 0
   nTotJan2 := 0
   nTotFev1 := 0
   nTotFev2 := 0
   nTotMar1 := 0
   nTotMar2 := 0
   nTotAbr1 := 0
   nTotAbr2 := 0 
   nTotMai1 := 0 
   nTotMai2 := 0 
   nTotJun1 := 0
   nTotJun2 := 0 
   nTotJul1 := 0 
   nTotJul2 := 0 
   nTotAgo1 := 0 
   nTotAgo2 := 0 
   ntotSet1 := 0
   nTotSet2 := 0
   nTotOut1 := 0 
   nTotOut2 := 0 
   nTotNov1 := 0
   nTotNov2 := 0 
   nTotDez1 := 0 
   nTotDez2 := 0 
   

   nTotJan1g := 0
   nTotJan2g := 0
   nTotFev1g := 0
   nTotFev2g := 0
   nTotMar1g := 0
   nTotMar2g := 0
   nTotAbr1g := 0
   nTotAbr2g := 0 
   nTotMai1g := 0 
   nTotMai2g := 0 
   nTotJun1g := 0
   nTotJun2g := 0 
   nTotJul1g := 0 
   nTotJul2g := 0 
   nTotAgo1g := 0 
   nTotAgo2g := 0 
   ntotSet1g := 0
   nTotSet2g := 0
   nTotOut1g := 0 
   nTotOut2g := 0 
   nTotNov1g := 0
   nTotNov2g := 0 
   nTotDez1g := 0 
   nTotDez2g := 0 
   
   nTotJan1T := 0
   nTotJan2T := 0
   nTotFev1T := 0
   nTotFev2T := 0
   nTotMar1T := 0
   nTotMar2T := 0
   nTotAbr1T := 0
   nTotAbr2T := 0 
   nTotMai1T := 0 
   nTotMai2T := 0 
   nTotJun1T := 0
   nTotJun2T := 0 
   nTotJul1T := 0 
   nTotJul2T := 0 
   nTotAgo1T := 0 
   nTotAgo2T := 0 
   ntotSet1T := 0
   nTotSet2T := 0
   nTotOut1T := 0 
   nTotOut2T := 0 
   nTotNov1T := 0
   nTotNov2T := 0 
   nTotDez1T := 0 
   nTotDez2T := 0       
   
   nTotalF1 := 0
   nTotalF2 := 0
	     
	

	
	For I := 1 to Len(aImprime)
	   If lEnd
	      Exit
	   endif
		
	   IncRegua() //Incrementa a posicao da regua de relatorios
	               
	   
	   
	   if nLin = 50
      	Roda(cBCont,cBTxt,Tamanho) 		
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
			nLin :=9
		EndIf      
  						   	

		if cRepre <> aImprime[I,1]	 
			    If PriVez <> "N"
			    
			       While nLin <=  80 
			         @ nLin,000 PSAY ""
			         nLin++
			       Enddo

			       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
			       
			       nLin:= 9
//			       @ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"		 		 	       
  	      	 	 nLin++                        
  	      	 	 nLin++                        
  	      	 	 nLin++                      
  	      	 	 If MV_PAR13 == 1  
					    @ nLin,000 PSAY "TOTAIS DO REPRESENTANTE : " 		    
                ELSE
                   @ nLin,000 PSAY "TOTAIS DA TELEVENDAS : " 		                      
                ENDIF
					 nLin++     
 				    @ nLin,000 PSAY "-------------------------" 		    
 				    
  					 nLin++     
					 
				 	cQuery := ""  
				 	if MV_PAR13 == 1 
						cQuery := "SELECT D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND2,A3.A3_NREDUZ, "    
               else
						cQuery := "SELECT D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND1,A3.A3_NREDUZ, "                   
               endif
					
					cQuery += "SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "
					cQuery += "THEN D2_QUANT * B1_CONV END) AS SOMA2008, 
					cQuery += "SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "
					cQuery += "THEN D2_QUANT * B1_CONV END) AS SOMA2009, "
					cQuery += "SUM(D2_QUANT)AS TOTAL_QUANT, SUM(D2_QUANT * B1_CONV) AS TOTAL_CONV, SUM(D2_TOTAL ) AS TOTAL_RS, " 				
					cQuery += "SUM(D2_QUANT)AS TOTAL_QUANT, SUM(D2_QUANT * B1_CONV) AS TOTAL_CONV, SUM(D2_TOTAL ) AS TOTAL_RS " 				
					cQuery += "FROM " + RetSqlName("SD2") + " AS D2, " + RetSqlName("SB1") + " AS B1, " + RetSqlName("SA2") + ;
					           " AS A2, " + RetSqlName("SF2") + " AS F2, " + RetSqlName("SA3") + " AS A3, " + RetSqlName("SA1") + " AS A1 "
					cQuery += "WHERE D2.D2_FILIAL  = '" + xFilial("SD2")   + "' "    
					cQuery += "AND B1.B1_FILIAL  = '" + xFilial("SB1")   + "' "    
					cQuery += "AND D2.D2_COD  >= '" + MV_PAR05 + "' "  
					cQuery += "AND D2.D2_COD  <= '" + MV_PAR06 + "' "  
					cQuery += "AND B1.B1_PROC >= '" + MV_PAR03 + "' "  
					cQuery += "AND B1.B1_PROC <= '" + MV_PAR04 + "' "    
					cQuery += "AND B1.B1_PROC <> '000109' "  
					cQuery += "AND B1.B1_PROC <> '001449' "  
					cQuery += "AND D2_EMISSAO >= '" + DTOS(MV_PAR11) + "' "
					cQuery += "AND D2_EMISSAO <= '" + DTOS(MV_PAR12) + "' "
					cQuery += "AND (LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 +  "' OR LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "')"
					cQuery += "AND B1_COD = D2_COD AND A2_COD = B1_PROC  AND A2_CLASSIF = '00' AND A2_LOJA = '01' "  
					cQuery += "AND D2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*' AND A2.D_E_L_E_T_ <> '*' AND D2_TP = 'LU' AND F2.F2_FILIAL = D2.D2_FILIAL "
					cQuery += "AND F2.F2_DOC = D2.D2_DOC  AND F2.F2_SERIE = D2.D2_SERIE  AND F2.D_E_L_E_T_ <> '*'  "
					cQuery += "AND F2.F2_EST >= '" + MV_PAR14 + "' "
					cQuery += "AND F2.F2_EST <= '" + MV_PAR15 + "' "
					cQuery += "AND A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA AND A1.D_E_L_E_T_ <> '*' "	
					cQuery += "AND A1.A1_COD_MUN >= '" + MV_PAR16 + "' "
					cQuery += "AND A1.A1_COD_MUN <= '" + MV_PAR17 + "' "
					cQuery += "AND A1.D_E_L_E_T_ <> '*'
               if MV_PAR13 == 1
						cQuery += "AND LTRIM(RTRIM(F2.F2_VEND2)) <> '' AND A3.A3_COD = F2.F2_VEND2  AND A3.D_E_L_E_T_ <> '*' "	
						cQuery += "AND F2.F2_VEND2 = '" + alltrim(cRepre) + "' "  
						cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND2,A3.A3_NREDUZ "  
						cQuery += "ORDER BY D2_FILIAL,F2_VEND2,B1_PROC	 "  
					ELSE               
						cQuery += "AND SUBSTRING(F2.F2_VEND1,1,2) = 'RT'  " 
						cQuery += "AND LTRIM(RTRIM(F2.F2_VEND1)) <> '' AND A3.A3_COD = F2.F2_VEND1  AND A3.D_E_L_E_T_ <> '*' "	
						cQuery += "AND F2.F2_VEND1 = '" + alltrim(cRepre) + "' "  
						cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND1,A3.A3_NREDUZ "  
						cQuery += "ORDER BY D2_FILIAL,F2_VEND1,B1_PROC	 "  
					ENDIF
					
				   cQuery := ChangeQuery(cQuery)
				   If Select("QRY2") <> 0
				      dbSelectArea("QRY2")
					   dbCloseArea()
				   Endif

				   TCQuery cQuery NEW ALIAS "QRY2"

              	@ nLin,000 PSAY "FAMILIA                                              " //+ MV_PAR01   + "                        " +  MV_PAR02                        
              	@ nLin,061 PSAY MV_PAR01
              	@ nLin,081 PSAY MV_PAR02
              	nlin++
              	@ nLin,000 PSAY "-------------------------------------------------------------------------------------"   
           		nlin++                     
           		
            //  	@ nLin,000 PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"                        
				   nLin++         
			   	dbSelectArea("QRY2")
				   dbGoTop()                   
				   While !Eof()        	
						   @ nLin,000 PSAY QRY2->B1_PROC
						   @ nLin,010 PSAY QRY2->A2_NREDUZ
						   @ nLin,054 PSAY Transform(QRY2->SOMA2008,"@E 999,999,999") 
						   @ nLin,074 PSAY Transform(QRY2->SOMA2009,"@E 999,999,999") 
						   nLin++
						   
                     nTotalF1 += QRY2->SOMA2008
                     nTotalF2 += QRY2->SOMA2009
						   
						   QRY2->(DbSkip())	  
				   
				   
				   EndDo                           
				   
				   nLin++
					@ nLin,000 PSAY "-------------------------------------------------------------------------------------"   
					nLin++					                                        
   			   @ nLin,054 PSAY Transform(nTotalF1 ,"@E 999,999,999") 
				   @ nLin,074 PSAY Transform(nTotalF2 ,"@E 999,999,999") 
				   
				   nTotalF1 := 0
					nTotalF2 := 0
					
					nlin++
   				nlin++
   				If MV_PAR13 == 1         
   				   @ nLin,000 PSAY "TOTAL MENSAL REPRESENTANTE TODAS AS FAMILIAS
   				else
   				   @ nLin,000 PSAY "TOTAL MENSAL TELEVENDAS TODAS AS FAMILIAS   				
   				endif
					nlin++
					@ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"	 
					nlin++
               @ nLin,000 PSAY "|      JAN       |       FEV       |       MAR       |       ABR       |       MAI       |       JUN       |       JUL       |       AGO       |       SET      |       OUT       |       NOV     |       DEZ       |"
               nLin++
	            @ nLin,000 PSAY "|   2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008    2009|    2008     2009|    2008   2009|    2008     2009|"
  				   nlin++
  					@ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"	 
					nlin++ 
				 	@ nLin,003 PSAY Transform(nTotJan1,"@E 999999")   
				 	@ nLin,011 PSAY Transform(nTotJan2,"@E 999999")   
				 	@ nLin,020 PSAY Transform(nTotFev1,"@E 999999")   		 	
				 	@ nLin,029 PSAY Transform(nTotFev2,"@E 999999")   		 	
				 	@ nLin,038 PSAY Transform(nTotMar1,"@E 999999")   		 	
				 	@ nLin,047 PSAY Transform(nTotMar2,"@E 999999")   		 			 			 	
				 	@ nLin,057 PSAY Transform(nTotAbr1,"@E 999999")   		 	
				 	@ nLin,065 PSAY Transform(nTotAbr2,"@E 999999")   		 	
				 	@ nLin,074 PSAY Transform(nTotMai1,"@E 999999")   		 	
				 	@ nLin,083 PSAY Transform(nTotMai2,"@E 999999")   		 	
				 	@ nLin,092 PSAY Transform(nTotJun1,"@E 999999")   		 	
				 	@ nLin,101 PSAY Transform(nTotJun2,"@E 999999")   		 	
				 	@ nLin,110 PSAY Transform(nTotJul1,"@E 999999")   		 	
				 	@ nLin,119 PSAY Transform(nTotJul2,"@E 999999")   		 	
				 	@ nLin,128 PSAY Transform(nTotAgo1,"@E 999999")   		 	
				 	@ nLin,137 PSAY Transform(nTotAgo2,"@E 999999")   		 	
				 	@ nLin,146 PSAY Transform(nTotSet1,"@E 999999")   		 	//AQUI
			 	
				 	@ nLin,154 PSAY Transform(nTotSet2,"@E 999999")   		 	
				 	@ nLin,163 PSAY Transform(nTotOut1,"@E 999999")   		 			 	
				 	@ nLin,172 PSAY Transform(nTotOut2,"@E 999999")   		 			 	
				 	@ nLin,181 PSAY Transform(nTotNov1,"@E 999999")   		 			 	
				 	@ nLin,188 PSAY Transform(nTotNov2,"@E 999999")   		 			 	
				 	@ nLin,197 PSAY Transform(nTotDez1,"@E 999999")   		 			 	
				 	@ nLin,206 PSAY Transform(nTotDez2,"@E 999999")   		 			
   		
					 nTotJan1 := 0
				  	 nTotJan2 := 0
                nTotFev1 := 0
  			       nTotFev2 := 0
                nTotMar1 := 0
			       nTotMar2 := 0
                nTotAbr1 := 0
                nTotAbr2 := 0 
                nTotMai1 := 0 
                nTotMai2 := 0 
                nTotJun1 := 0
                nTotJun2 := 0 
                nTotJul1 := 0 
                nTotJul2 := 0 
                nTotAgo1 := 0 
                nTotAgo2 := 0 
                ntotSet1 := 0
                nTotSet2 := 0
                nTotOut1 := 0 
                nTotOut2 := 0 
                nTotNov1 := 0
                nTotNov2 := 0 
                nTotDez1 := 0 
                nTotDez2 := 0 
                While nLin <=  80 
			         @ nLin,000 PSAY ""
			         nLin++
			       Enddo                                                                                 
       			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
 		         nLin := 9
		   	 EndIf                                                                                    
	          nLin++                                                                                   
   	       nLin++
      	    nLin++                                                                                  
             If MV_PAR13 == 1
     	          cQuebra := "REPRESENTANTE : "  + alltrim(aImprime[I,1]) + " - " + alltrim(aImprime[I,2])
     	       Else
     	          cQuebra := "TELEVENDAS : "  + alltrim(aImprime[I,1]) + " - " + alltrim(aImprime[I,2])
     	       EndIf
          
			    @ nLin,000 PSAY cQuebra    	 
      	   	 
      		 cRepre := aImprime[I,1]	     
	      	 nLin++                
   	   	 cLinha := ""
      		 For C := 1 to Len(cQuebra)
      		    cLinha := cLinha + "-"
	      	 Next
      	 
      	                        
   	   	 @ nLin,000 PSAY cLinha
      	    nLin++          
         	 PriVez := "S"
	      endif 	
	      
   	   @ nLin,000 PSAY aImprime[I,4]			      
		 	@ nLin,013 PSAY aImprime[I,3]			      
		 	nLin++
		 	@ nLin,003 PSAY Transform(aImprime[I,05],"@E 999999")   
		 	@ nLin,011 PSAY Transform(aImprime[I,17],"@E 999999")   
		 	@ nLin,020 PSAY Transform(aImprime[I,06],"@E 999999")   		 	
		 	@ nLin,029 PSAY Transform(aImprime[I,18],"@E 999999")   		 	
		 	@ nLin,038 PSAY Transform(aImprime[I,07],"@E 999999")   		 	
		 	@ nLin,047 PSAY Transform(aImprime[I,19],"@E 999999")   		 			 			 	
		 	@ nLin,057 PSAY Transform(aImprime[I,08],"@E 999999")   		 	
		 	@ nLin,065 PSAY Transform(aImprime[I,20],"@E 999999")   		 	
		 	@ nLin,074 PSAY Transform(aImprime[I,09],"@E 999999")   		 	
		 	@ nLin,083 PSAY Transform(aImprime[I,21],"@E 999999")   		 	
		 	@ nLin,092 PSAY Transform(aImprime[I,10],"@E 999999")   		 	
		 	@ nLin,101 PSAY Transform(aImprime[I,22],"@E 999999")   		 	
		 	@ nLin,110 PSAY Transform(aImprime[I,11],"@E 999999")   		 	
		 	@ nLin,119 PSAY Transform(aImprime[I,23],"@E 999999")   		 	
		 	@ nLin,128 PSAY Transform(aImprime[I,12],"@E 999999")   		 	
		 	@ nLin,137 PSAY Transform(aImprime[I,24],"@E 999999")   		 	
		 	@ nLin,146 PSAY Transform(aImprime[I,13],"@E 999999")   		 	//AQUI
		 	
		 	@ nLin,154 PSAY Transform(aImprime[I,25],"@E 999999")   		 	
		 	@ nLin,163 PSAY Transform(aImprime[I,14],"@E 999999")   		 			 	
		 	@ nLin,172 PSAY Transform(aImprime[I,26],"@E 999999")   		 			 	
		 	@ nLin,181 PSAY Transform(aImprime[I,15],"@E 999999")   		 			 	
		 	@ nLin,188 PSAY Transform(aImprime[I,27],"@E 999999")   		 			 	
		 	@ nLin,197 PSAY Transform(aImprime[I,16],"@E 999999")   		 			 	
		 	@ nLin,206 PSAY Transform(aImprime[I,28],"@E 999999")   		 			 	

         

		
			nTotJan1 += aImprime[I,05]
			nTotJan2 += aImprime[I,17]
         nTotFev1 += aImprime[I,06]
         nTotFev2 += aImprime[I,18]
         nTotMar1 += aImprime[I,07]
         nTotMar2 += aImprime[I,19]
         nTotAbr1 += aImprime[I,08]
         nTotAbr2 += aImprime[I,20]
         nTotMai1 += aImprime[I,09]
         nTotMai2 += aImprime[I,21]
         nTotJun1 += aImprime[I,10]
         nTotJun2 += aImprime[I,22]
         nTotJul1 += aImprime[I,11]
         nTotJul2 += aImprime[I,23]
         nTotAgo1 += aImprime[I,12]
         nTotAgo2 += aImprime[I,24]
         ntotSet1 += aImprime[I,13]
         nTotSet2 += aImprime[I,25]
         nTotOut1 += aImprime[I,14]
         nTotOut2 += aImprime[I,26]
         nTotNov1 += aImprime[I,15]
         nTotNov2 += aImprime[I,27]
         nTotDez1 += aImprime[I,16]
         nTotDez2 += aImprime[I,28]
         
         
  			nTotJan1g += aImprime[I,05]
			nTotJan2g += aImprime[I,17]
         nTotFev1g += aImprime[I,06]
         nTotFev2g += aImprime[I,18]
         nTotMar1g += aImprime[I,07]
         nTotMar2g += aImprime[I,19]
         nTotAbr1g += aImprime[I,08]
         nTotAbr2g += aImprime[I,20]
         nTotMai1g += aImprime[I,09]
         nTotMai2g += aImprime[I,21]
         nTotJun1g += aImprime[I,10]
         nTotJun2g += aImprime[I,22]
         nTotJul1g += aImprime[I,11]
         nTotJul2g += aImprime[I,23]
         nTotAgo1g += aImprime[I,12]
         nTotAgo2g += aImprime[I,24]
         ntotSet1g += aImprime[I,13]
         nTotSet2g += aImprime[I,25]
         nTotOut1g += aImprime[I,14]
         nTotOut2g += aImprime[I,26]
         nTotNov1g += aImprime[I,15]
         nTotNov2g += aImprime[I,27]
         nTotDez1g += aImprime[I,16]
         nTotDez2g += aImprime[I,28]  
         
  			nTotJan1T += aImprime[I,05]
			nTotJan2T += aImprime[I,17]
         nTotFev1T += aImprime[I,06]
         nTotFev2T += aImprime[I,18]
         nTotMar1T += aImprime[I,07]
         nTotMar2T += aImprime[I,19]
         nTotAbr1T += aImprime[I,08]
         nTotAbr2T += aImprime[I,20]
         nTotMai1T += aImprime[I,09]
         nTotMai2T += aImprime[I,21]
         nTotJun1T += aImprime[I,10]
         nTotJun2T += aImprime[I,22]
         nTotJul1T += aImprime[I,11]
         nTotJul2T += aImprime[I,23]
         nTotAgo1T += aImprime[I,12]
         nTotAgo2T += aImprime[I,24]
         ntotSet1T += aImprime[I,13]
         nTotSet2T += aImprime[I,25]
         nTotOut1T += aImprime[I,14]
         nTotOut2T += aImprime[I,26]
         nTotNov1T += aImprime[I,15]
         nTotNov2T += aImprime[I,27]
         nTotDez1T += aImprime[I,16]
         nTotDez2T += aImprime[I,28]         
         
		 	nLin++
         @ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"		 		 	       
		 	nLin++       
		 	
	Next
      
      While nLin <=  80 
         @ nLin,000 PSAY ""
         nLin++
      Enddo

      Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
			       
      nLin:= 9
   	nLin++	
	 	nLin++
 		nLin++    
		
		If MV_PAR13 == 1
      	@ nLin,000 PSAY "TOTAIS DO REPRESENTANTE : " 		    
      else
 	      @ nLin,000 PSAY "TOTAIS DA TELEVENDAS : " 		    
      EndIf
      
		nLin++     
 		@ nLin,000 PSAY "-------------------------" 		    
 				    
  					 nLin++     
					 
				 	cQuery := ""                                                                
				 	if MV_PAR13 == 1
						cQuery := "SELECT D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND2,A3.A3_NREDUZ, "    
			      else
						cQuery := "SELECT D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND1,A3.A3_NREDUZ, "    			      
			      endif
					cQuery += "SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "
					cQuery += "THEN D2_QUANT * B1_CONV END) AS SOMA2008, 
					cQuery += "SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "
					cQuery += "THEN D2_QUANT * B1_CONV END) AS SOMA2009, "
					cQuery += "SUM(D2_QUANT)AS TOTAL_QUANT, SUM(D2_QUANT * B1_CONV) AS TOTAL_CONV, SUM(D2_TOTAL ) AS TOTAL_RS, " 				
					cQuery += "SUM(D2_QUANT)AS TOTAL_QUANT, SUM(D2_QUANT * B1_CONV) AS TOTAL_CONV, SUM(D2_TOTAL ) AS TOTAL_RS " 				
					cQuery += "FROM " + RetSqlName("SD2") + " AS D2, " + RetSqlName("SB1") + " AS B1, " + RetSqlName("SA2") + ;
					           " AS A2, " + RetSqlName("SF2") + " AS F2, " + RetSqlName("SA3") + " AS A3, " + RetSqlName("SA1") + " AS A1 "
					cQuery += "WHERE D2.D2_FILIAL  = '" + xFilial("SD2")   + "' "    
					cQuery += "AND B1.B1_FILIAL  = '" + xFilial("SB1")   + "' "    
					cQuery += "AND D2.D2_COD  >= '" + MV_PAR05 + "' "  
					cQuery += "AND D2.D2_COD  <= '" + MV_PAR06 + "' "  
					cQuery += "AND B1.B1_PROC >= '" + MV_PAR03 + "' "  
					cQuery += "AND B1.B1_PROC <= '" + MV_PAR04 + "' "   
					cQuery += "AND B1.B1_PROC <> '000109' "  
					cQuery += "AND B1.B1_PROC <> '001449' " 					
					cQuery += "AND D2_EMISSAO >= '" + DTOS(MV_PAR11) + "' "
					cQuery += "AND D2_EMISSAO <= '" + DTOS(MV_PAR12) + "' "
					cQuery += "AND (LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 +  "' OR LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "')"
					cQuery += "AND B1_COD = D2_COD AND A2_COD = B1_PROC  AND A2_CLASSIF = '00' AND A2_LOJA = '01' "  
					cQuery += "AND D2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*' AND A2.D_E_L_E_T_ <> '*' AND D2_TP = 'LU' AND F2.F2_FILIAL = D2.D2_FILIAL "
					cQuery += "AND F2.F2_DOC = D2.D2_DOC  AND F2.F2_SERIE = D2.D2_SERIE  AND F2.D_E_L_E_T_ <> '*'   "                   
					cQuery += "AND F2.F2_EST >= '" + MV_PAR14 + "' "
					cQuery += "AND F2.F2_EST <= '" + MV_PAR15 + "' "
					cQuery += "AND A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA AND A1.D_E_L_E_T_ <> '*' "	
					cQuery += "AND A1.A1_COD_MUN >= '" + MV_PAR16 + "' "
					cQuery += "AND A1.A1_COD_MUN <= '" + MV_PAR17 + "' "
					cQuery += "AND A1.D_E_L_E_T_ <> '*'
					If MV_PAR13 == 1
						cQuery += "AND LTRIM(RTRIM(F2.F2_VEND2)) <> '' AND A3.A3_COD = F2.F2_VEND2  AND A3.D_E_L_E_T_ <> '*' "	
						cQuery += "AND F2.F2_VEND2 = '" + alltrim(cRepre) + "' "  
						cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND2,A3.A3_NREDUZ "  
						cQuery += "ORDER BY D2_FILIAL,F2_VEND2,B1_PROC	 "  
					else               
    					cQuery += "AND SUBSTRING(F2.F2_VEND1,1,2) = 'RT'  " 
						cQuery += "AND LTRIM(RTRIM(F2.F2_VEND1)) <> '' AND A3.A3_COD = F2.F2_VEND1  AND A3.D_E_L_E_T_ <> '*' "	
						cQuery += "AND F2.F2_VEND1 = '" + alltrim(cRepre) + "' "  
						cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, F2.F2_VEND1,A3.A3_NREDUZ "  
						cQuery += "ORDER BY D2_FILIAL,F2_VEND1,B1_PROC	 "  										
					endif
					
				   cQuery := ChangeQuery(cQuery)
				   If Select("QRY2") <> 0
				      dbSelectArea("QRY2")
					   dbCloseArea()
				   Endif

				   TCQuery cQuery NEW ALIAS "QRY2"

              	@ nLin,000 PSAY "FAMILIA                                              " //+ MV_PAR01   + "                        " +  MV_PAR02                        
              	@ nLin,060 PSAY MV_PAR01
              	@ nLin,083 PSAY MV_PAR02
              	nlin++
              	@ nLin,000 PSAY "----------------------------------------------------------------------------------------"  
           		nlin++                     
           		
            //  	@ nLin,000 PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"                        
				   nLin++         
			   	dbSelectArea("QRY2")
				   dbGoTop()                   
				   While !Eof()        	
						   @ nLin,000 PSAY QRY2->B1_PROC
						   @ nLin,010 PSAY QRY2->A2_NREDUZ
						   @ nLin,054 PSAY Transform(QRY2->SOMA2008,"@E 999,999,999") 
						   @ nLin,074 PSAY Transform(QRY2->SOMA2009,"@E 999,999,999") 
						   nLin++
						   
                     nTotalF1 += QRY2->SOMA2008
                     nTotalF2 += QRY2->SOMA2009
						   
						   QRY2->(DbSkip())	  
				   
				   
				   EndDo                           
				   
				   nLin++
					@ nLin,000 PSAY "----------------------------------------------------------------------------------------"   
					nLin++					                                        
   			   @ nLin,054 PSAY Transform(nTotalF1 ,"@E 999,999,999") 
				   @ nLin,074 PSAY Transform(nTotalF2 ,"@E 999,999,999") 
				   
				   nTotalF1 := 0
					nTotalF2 := 0
					
					nlin++
   				nlin++                                                       
               If MV_PAR13 == 1
	   				@ nLin,000 PSAY "TOTAL MENSAL REPRESENTANTE TODAS AS FAMILIAS
	   	      Else
        				@ nLin,000 PSAY "TOTAL MENSAL TELEVENDAS TODAS AS FAMILIAS
               endif
					nlin++
					@ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"	 
					nlin++
               @ nLin,000 PSAY "|      JAN       |       FEV       |       MAR       |       ABR       |       MAI       |       JUN       |       JUL       |       AGO       |       SET      |       OUT       |       NOV     |       DEZ       |"
               nLin++
	            @ nLin,000 PSAY "|   2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008    2009|    2008     2009|    2008   2009|    2008     2009|"
  				   nlin++
  					@ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"	 
					nlin++ 
				 	@ nLin,003 PSAY Transform(nTotJan1,"@E 999999")   
				 	@ nLin,011 PSAY Transform(nTotJan2,"@E 999999")   
				 	@ nLin,020 PSAY Transform(nTotFev1,"@E 999999")   		 	
				 	@ nLin,029 PSAY Transform(nTotFev2,"@E 999999")   		 	
				 	@ nLin,038 PSAY Transform(nTotMar1,"@E 999999")   		 	
				 	@ nLin,047 PSAY Transform(nTotMar2,"@E 999999")   		 			 			 	
				 	@ nLin,057 PSAY Transform(nTotAbr1,"@E 999999")   		 	
				 	@ nLin,065 PSAY Transform(nTotAbr2,"@E 999999")   		 	
				 	@ nLin,074 PSAY Transform(nTotMai1,"@E 999999")   		 	
				 	@ nLin,083 PSAY Transform(nTotMai2,"@E 999999")   		 	
				 	@ nLin,092 PSAY Transform(nTotJun1,"@E 999999")   		 	
				 	@ nLin,101 PSAY Transform(nTotJun2,"@E 999999")   		 	
				 	@ nLin,110 PSAY Transform(nTotJul1,"@E 999999")   		 	
				 	@ nLin,119 PSAY Transform(nTotJul2,"@E 999999")   		 	
				 	@ nLin,128 PSAY Transform(nTotAgo1,"@E 999999")   		 	
				 	@ nLin,137 PSAY Transform(nTotAgo2,"@E 999999")   		 	
				 	@ nLin,146 PSAY Transform(nTotSet1,"@E 999999")   		 	//AQUI
			 	
				 	@ nLin,154 PSAY Transform(nTotSet2,"@E 999999")   		 	
				 	@ nLin,163 PSAY Transform(nTotOut1,"@E 999999")   		 			 	
				 	@ nLin,172 PSAY Transform(nTotOut2,"@E 999999")   		 			 	
				 	@ nLin,181 PSAY Transform(nTotNov1,"@E 999999")   		 			 	
				 	@ nLin,188 PSAY Transform(nTotNov2,"@E 999999")   		 			 	
				 	@ nLin,197 PSAY Transform(nTotDez1,"@E 999999")   		 			 	
				 	@ nLin,206 PSAY Transform(nTotDez2,"@E 999999")   		  		
 		
 		
 		
 		
//-------------------------------------------------------------------
      
      While nLin <=  80 
         @ nLin,000 PSAY ""
         nLin++
      Enddo

      Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
			       
      nLin:= 9
   	nLin++	
	 	nLin++
 		nLin++    


       	    @ nLin,000 PSAY "TOTAIS GERAIS : " 		    
  					 nLin++     
 				    @ nLin,000 PSAY "-------------------------" 		    
 				    
  					 nLin++     
					 
				 	cQuery := "" 
					cQuery := "SELECT D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ, "    
					cQuery += "SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 + "' "
					cQuery += "THEN D2_QUANT * B1_CONV END) AS SOMA2008, 
					cQuery += "SUM(CASE WHEN LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "' "
					cQuery += "THEN D2_QUANT * B1_CONV END) AS SOMA2009, "
					cQuery += "SUM(D2_QUANT)AS TOTAL_QUANT, SUM(D2_QUANT * B1_CONV) AS TOTAL_CONV, SUM(D2_TOTAL ) AS TOTAL_RS, " 				
					cQuery += "SUM(D2_QUANT)AS TOTAL_QUANT, SUM(D2_QUANT * B1_CONV) AS TOTAL_CONV, SUM(D2_TOTAL ) AS TOTAL_RS " 				
					cQuery += "FROM " + RetSqlName("SD2") + " AS D2, " + RetSqlName("SB1") + " AS B1, " + RetSqlName("SA2") + ;
					           " AS A2, " + RetSqlName("SF2") + " AS F2, " + RetSqlName("SA3") + " AS A3, " + RetSqlName("SA1") + " AS A1 "
					cQuery += "WHERE D2.D2_FILIAL  = '" + xFilial("SD2")   + "' "    
					cQuery += "AND B1.B1_FILIAL  = '" + xFilial("SB1")   + "' "    
					cQuery += "AND D2.D2_COD  >= '" + MV_PAR05 + "' "  
					cQuery += "AND D2.D2_COD  <= '" + MV_PAR06 + "' "  
					cQuery += "AND B1.B1_PROC >= '" + MV_PAR03 + "' "  
					cQuery += "AND B1.B1_PROC <= '" + MV_PAR04 + "' "    
					cQuery += "AND B1.B1_PROC <> '000109' "  
					cQuery += "AND B1.B1_PROC <> '001449' " 					
					cQuery += "AND D2_EMISSAO >= '" + DTOS(MV_PAR11) + "' "
					cQuery += "AND D2_EMISSAO <= '" + DTOS(MV_PAR12) + "' "					
					cQuery += "AND (LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR01 +  "' OR LTRIM(RTRIM(STR(DATEPART(YEAR,D2_EMISSAO)))) = '" + MV_PAR02 + "')"
					cQuery += "AND B1_COD = D2_COD AND A2_COD = B1_PROC  AND A2_CLASSIF = '00' AND A2_LOJA = '01' "  
					cQuery += "AND D2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*' AND A2.D_E_L_E_T_ <> '*' AND D2_TP = 'LU'  "
  				   cQuery += "AND F2.F2_EST >= '" + MV_PAR14 + "' "
					cQuery += "AND F2.F2_EST <= '" + MV_PAR15 + "' "            
					cQuery += "AND A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA AND A1.D_E_L_E_T_ <> '*' "	
					cQuery += "AND A1.A1_COD_MUN >= '" + MV_PAR16 + "' "
					cQuery += "AND A1.A1_COD_MUN <= '" + MV_PAR17 + "' "
					cQuery += "AND A1.D_E_L_E_T_ <> '*'

					If MV_PAR13 == 1
						cQuery += "AND F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC = D2.D2_DOC  AND F2.F2_SERIE = D2.D2_SERIE  AND F2.D_E_L_E_T_ <> '*'  AND LTRIM(RTRIM(F2.F2_VEND2)) <> '' "
						cQuery += "AND A3.A3_COD = F2.F2_VEND2  AND A3.D_E_L_E_T_ <> '*' "	
						cQuery += "AND F2.F2_VEND2 >= '" + MV_PAR07 + "' "  
						cQuery += "AND F2.F2_VEND2 <= '" + MV_PAR08 + "' "  
						cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ "  
						cQuery += "ORDER BY D2_FILIAL,B1_PROC	 "  
					Else
						cQuery += "AND SUBSTRING(F2.F2_VEND1,1,2) = 'RT'  " 
						cQuery += "AND F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC = D2.D2_DOC  AND F2.F2_SERIE = D2.D2_SERIE  AND F2.D_E_L_E_T_ <> '*'  AND LTRIM(RTRIM(F2.F2_VEND1)) <> '' "
						cQuery += "AND A3.A3_COD = F2.F2_VEND1  AND A3.D_E_L_E_T_ <> '*' "	
						cQuery += "AND F2.F2_VEND1 >= '" + MV_PAR09 + "' "  
						cQuery += "AND F2.F2_VEND1 <= '" + MV_PAR10 + "' "  
						cQuery += "GROUP BY D2_FILIAL,B1_PROC,A2_COD,A2_LOJA,A2_NREDUZ "  
						cQuery += "ORDER BY D2_FILIAL,B1_PROC	 "  				
					endif					
				   cQuery := ChangeQuery(cQuery)
				   If Select("QRY2") <> 0
				      dbSelectArea("QRY2")
					   dbCloseArea()
				   Endif

				   TCQuery cQuery NEW ALIAS "QRY2"

              	@ nLin,000 PSAY "FAMILIA                                              " //+ MV_PAR01   + "                        " +  MV_PAR02                        
              	@ nLin,060 PSAY MV_PAR01
              	@ nLin,080 PSAY MV_PAR02
              	nlin++
              	@ nLin,000 PSAY "-------------------------------------------------------------------------------------"   
           		nlin++                     
           		
//              	@ nLin,000 PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"                        
				   nLin++         
  			      nTotalF1 := 0 
               nTotalF2 := 0
						  
			   	dbSelectArea("QRY2")
				   dbGoTop()                   
				   While !Eof()        	
						   @ nLin,000 PSAY QRY2->B1_PROC
						   @ nLin,010 PSAY QRY2->A2_NREDUZ
						   @ nLin,054 PSAY Transform(QRY2->SOMA2008,"@E 999,999,999") 
						   @ nLin,074 PSAY Transform(QRY2->SOMA2009,"@E 999,999,999") 
						   nLin++
						   
				         nTotalF1 += QRY2->SOMA2008
                     nTotalF2 += QRY2->SOMA2009
						   
						   QRY2->(DbSkip())	  
				   
				   
				   EndDo                           
				   
				   nLin++
					@ nLin,000 PSAY "-------------------------------------------------------------------------------------"   
					nLin++					                                        
   			   @ nLin,054 PSAY Transform(nTotalF1 ,"@E 999,999,999") 
				   @ nLin,074 PSAY Transform(nTotalF2 ,"@E 999,999,999") 
					nLin++					                                        
					nLin++					                                        				   
				   
   				@ nLin,000 PSAY "TOTAL GERAL FAMILIAS
					nlin++
					@ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"	 
					nlin++
               @ nLin,000 PSAY "|      JAN       |       FEV       |       MAR       |       ABR       |       MAI       |       JUN       |       JUL       |       AGO       |       SET      |       OUT       |       NOV     |       DEZ       |"
               nLin++
	            @ nLin,000 PSAY "|   2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008     2009|    2008    2009|    2008     2009|    2008   2009|    2008     2009|"
  				   nlin++
					@ nLin,000 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"	 
					nlin++ 
				 	@ nLin,003 PSAY Transform(nTotJan1T,"@E 999999")   
				 	@ nLin,011 PSAY Transform(nTotJan2T,"@E 999999")   
				 	@ nLin,020 PSAY Transform(nTotFev1T,"@E 999999")   		 	
				 	@ nLin,029 PSAY Transform(nTotFev2T,"@E 999999")   		 	
				 	@ nLin,038 PSAY Transform(nTotMar1T,"@E 999999")   		 	
				 	@ nLin,047 PSAY Transform(nTotMar2T,"@E 999999")   		 			 			 	
				 	@ nLin,057 PSAY Transform(nTotAbr1T,"@E 999999")   		 	
				 	@ nLin,065 PSAY Transform(nTotAbr2T,"@E 999999")   		 	
				 	@ nLin,074 PSAY Transform(nTotMai1T,"@E 999999")   		 	
				 	@ nLin,083 PSAY Transform(nTotMai2T,"@E 999999")   		 	
				 	@ nLin,092 PSAY Transform(nTotJun1T,"@E 999999")   		 	
				 	@ nLin,101 PSAY Transform(nTotJun2T,"@E 999999")   		 	
				 	@ nLin,110 PSAY Transform(nTotJul1T,"@E 999999")   		 	
				 	@ nLin,119 PSAY Transform(nTotJul2T,"@E 999999")   		 	
				 	@ nLin,128 PSAY Transform(nTotAgo1T,"@E 999999")   		 	
				 	@ nLin,137 PSAY Transform(nTotAgo2T,"@E 999999")   		 	
				 	@ nLin,146 PSAY Transform(nTotSet1T,"@E 999999")   		 	//AQUI
			 	
				 	@ nLin,154 PSAY Transform(nTotSet2T,"@E 999999")   		 	
				 	@ nLin,163 PSAY Transform(nTotOut1T,"@E 999999")   		 			 	
				 	@ nLin,172 PSAY Transform(nTotOut2T,"@E 999999")   		 			 	
				 	@ nLin,181 PSAY Transform(nTotNov1T,"@E 999999")   		 			 	
				 	@ nLin,188 PSAY Transform(nTotNov2T,"@E 999999")   		 			 	
				 	@ nLin,197 PSAY Transform(nTotDez1T,"@E 999999")   		 			 	
				 	@ nLin,206 PSAY Transform(nTotDez2T,"@E 999999")   	




                          
//-------------------------------




//	Set Filter To

//  SetPgEject(.T.)
//

	If aReturn[5] == 1
		Set Printer To
		Commit
	   ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool   
Return           




                                                                       
                                                                       