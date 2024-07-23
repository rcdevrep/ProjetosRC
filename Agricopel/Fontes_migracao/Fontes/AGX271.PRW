#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX271    ºAutor  ³Rodrigo             º Data ³  03/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista produtos sem venda no período.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX271()

	SetPrvt("aImprime,cForn")

	aImprime := {}   
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo,listar produtos")
	cDesc2        	:= OemToAnsi("sem venda em um período. ")
	cDesc3        	:= ""
	cPict         	:= ""
	titulo       	:= "Produtos Sem Venda"
	nLin         	:= 80
	cabec1  		:= "Código         Descrição                                              U.M.    Última Compra      Última Venda     Preço Venda           Saldo "
	cabec2       	:= ""
	imprime      	:= .T.
	aOrd 			:= ""
	lEnd            := .F.
	lAbortPrint     := .F.
	CbTxt           := ""
	limite          := 132
	tamanho         := "G"
	nomeprog        := "AGX271"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX271"
	aRegistros  	:= {}
	cPerg		 	   := "AGX271"
	cString 	   	:= "DA1"  
	titulo  	      :="Produtos Sem Venda"
   cCancel 	      := "***** CANCELADO PELO OPERADOR *****"
	aRegistros     := {}   
	
	AADD(aRegistros,{cPerg,"01","Fornecedor Inicial        ?","mv_ch1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","SA2"})
	AADD(aRegistros,{cPerg,"02","Fornecedor Final  	       ?","mv_ch2","C",06,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","SA2"})
	AADD(aRegistros,{cPerg,"03","Data Faturamento Inicial  ?","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Data Faturamento Final    ?","mv_ch4","D",08,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Produto Inicial           ?","mv_ch5","C",15,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"06","Produto Final             ?","mv_ch6","C",15,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","SB1"})	
	AADD(aRegistros,{cPerg,"07","Tabela de Preço           ?","mv_ch7","C",03,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","DA0"})	
	AADD(aRegistros,{cPerg,"08","Data Última Compra        ?","mv_ch8","N",01,0,0,"C","","mv_par08","Maior U. Compra","","","Todos","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"09","Sintetico ou Analitico    ?","mv_ch9","N",01,0,0,"C","","mv_par09","Sintetico","","","Analitico","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"10","Armazem de                ?","mv_ch10","C",02,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"11","Armazem ate               ?","mv_ch11","C",02,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"12","Produtos Com Saldo        ?","mv_ch12","N",01,0,0,"C","","mv_par12","Sim","","","Todos","","","","","","","","","","",""})	


	
	U_CriaPer(cPerg,aRegistros)   
	Pergunte(cPerg,.F.)
	
   wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
   
   If MV_PAR09 == 2 
   	cabec1  		   +=	"    Preço Real Venda      Qtde Últ. N.F. Ent."
   endif
	
	
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
/*	aStru:={}
	aadd(aStru,{'COD'  ,'C',15,0})
	aadd(aStru,{'QUANT','N',14,2})
	aadd(aStru,{'TOTAL','N',14,2})
	cArq :=CriaTrab(aStru,.t.)
	use &cArq alias AGR219 new
	Index on COD to AGR2191 */
	
   cForn := ""
   
	Processa({|| GeraDados() })
     	
   RptStatus({|| RptDetail() })  

  	    
Return

Static Function GeraDados()
	SetPrvt("aSeg,aSegDA1,nRecno,cFiltroUsu")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria expressao de filtro do usuario                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltroUsu := aReturn[7]

	aSeg  	:= GetArea()
	aSegDA1	:= DA1->(GetArea())

	
	aImprime := {}  
	
 
	
	/* QUERY PESQUISA   */    
	cQuery := "" 
	cQuery := "SELECT DA1_CODPRO,B1_UCOM,B1_DESC,DA1_PRCVEN,B1_UM,B2_QATU "	
	cQuery += "FROM " + RetSqlName("DA1") + ", " + RetSqlName("SB1") + ", " + RetSqlName("SB2") + " (NOLOCK) "  
	cQuery += "WHERE DA1_FILIAL = '"+ xFilial("DA1") + "' "  
	cQuery += "AND DA1_CODPRO >= '" + MV_PAR05       + "' "
	cQuery += "AND DA1_CODPRO <= '" + MV_PAR06       + "' "
	cQuery += "AND DA1_CODTAB = "   + MV_PAR07       + " "   
	cQuery += "AND B1_COD = DA1_CODPRO "    
	cQuery += "AND B1_FILIAL = '"+ xFilial("SB1") + "' "   
	cQuery += "AND B2_FILIAL = '"+ xFilial("SB2") + "' "   
	cQuery += "AND B2_COD = DA1_CODPRO "
    cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SD2") + " "
    cQuery += "WHERE D2_FILIAL = DA1_FILIAL "
    cQuery += "AND  D2_COD   = DA1_CODPRO " 
    cQuery += "AND  D2_EMISSAO >= '" + DTOS(MV_PAR03) + "' "
    cQuery += "AND  D2_EMISSAO <= '" + DTOS(MV_PAR04) + "'
    cQuery += "AND " + RetSqlName("SD2") + ".D_E_L_E_T_ <> '*')" "
    cQuery += "AND  B2_LOCAL >= '" + MV_PAR10 + "' "
    cQuery += "AND  B2_LOCAL <= '" + MV_PAR11 + "' "
    cQuery += "AND " + RetSqlName("DA1") + ".D_E_L_E_T_ <> '*' "
    cQuery += "AND " + RetSqlName("SB1") + ".D_E_L_E_T_ <> '*' "
    cQuery += "AND " + RetSqlName("SB2") + ".D_E_L_E_T_ <> '*' "  
    If MV_PAR12 == 1                                   
       cQuery += "AND  B2_QATU > 0 " 
    EndIf
         
    cQuery += "ORDER BY DA1_FILIAL, DA1_CODPRO"                                            
   
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
 		If !Empty(cFiltroUsu).and.!(&cFiltroUsu)
	      Dbskip()
		   Loop
	   Endif   
	     
      
     	cQuery := "" 
	   cQuery := "SELECT D2_EMISSAO  "	
    	cQuery += "FROM " + RetSqlName("SD2") + " (NOLOCK) "                                         
      cQuery += "WHERE D2_FILIAL =  '" + xFilial("SD2") + "' "   
      cQuery += "AND  D2_COD   = '" + MTEMP->DA1_CODPRO + "' "   
      cQuery += "AND " + RetSqlName("SD2") + ".D_E_L_E_T_ <> '*' "
      cQuery += "ORDER BY D2_EMISSAO DESC"   
	   cQuery := ChangeQuery(cQuery)
   	If Select("MSD2") <> 0
         dbSelectArea("MSD2")
	      dbCloseArea()
      Endif

      TCQuery cQuery NEW ALIAS "MSD2"
      TCSetField("MSD2","D2_EMISSAO","D",08,0)  
      TCSetField("MTEMP","B1_UCOM","D",08,0)
      
      dbSelectArea("MSD2")
	   dbGoTop() 
	   
	   //*********************** PEGA VALOR PRODUTO NF SAIDA *************************************//  
	   
  
      If MV_PAR09 == 2 // Analítico
	      cQuery := ""
	      cQuery := "SELECT UB_VRUNIT "
	      cQuery += "FROM " + RetSqlName("SUB") + ", " + RetSqlName("SUA") + " (NOLOCK) "   
	      cQuery += "WHERE UB_FILIAL =  '"  + xFilial("SUB") + "' "  
		   cQuery += "AND   UA_FILIAL =  '"  + xFilial("SUA") + "' "  	   
		   cQuery += "AND   UB_PRODUTO =  '" + MTEMP->DA1_CODPRO + "' "   
		   cQuery += "AND   UA_NUM = UB_NUM "
	       cQuery += "AND " + RetSqlName("SUA") + ".D_E_L_E_T_ <> '*' "
           cQuery += "AND " + RetSqlName("SUB") + ".D_E_L_E_T_ <> '*' "
		   cQuery += "ORDER BY UA_EMISSAO DESC"
 		   cQuery := ChangeQuery(cQuery)
   	   If Select("MNFS") <> 0
            dbSelectArea("MNFS")
	         dbCloseArea()
         Endif

         TCQuery cQuery NEW ALIAS "MNFS"
         dbSelectArea("MNFS")
	      dbGoTop()  
	   
	      //*********************** PEGA QTDE ITEM NF ENTRADA *************************************//
		   cQuery := ""
	      cQuery := "SELECT D1_QUANT "
	      cQuery += "FROM " + RetSqlName("SD1")  +" (NOLOCK) "   
	      cQuery += "WHERE D1_FILIAL =  '"  + xFilial("SD1") + "' "  
	   	cQuery += "AND   D1_COD = '" + MTEMP->DA1_CODPRO + "' "   
   	    cQuery += "AND " + RetSqlName("SD1") + ".D_E_L_E_T_ <> '*' "
	   	cQuery += "ORDER BY D1_EMISSAO DESC"
    		cQuery := ChangeQuery(cQuery)
      	If Select("MNFE") <> 0
            dbSelectArea("MNFE")
	         dbCloseArea()
         Endif

         TCQuery cQuery NEW ALIAS "MNFE"
         dbSelectArea("MNFE")
	      dbGoTop() 
		endif      
		
		if MV_PAR08 == 1 .AND. MTEMP->B1_UCOM < MSD2->D2_EMISSAO
			DbSelectArea("MTEMP")  
			Dbskip()
		   Loop   
		endif

  		dUDataComp   := CtoD('  /  /  ')   
  		dUVenda      := CtoD('  /  /  ')   
	   dUDataComp   := MTEMP->B1_UCOM
	   dUVenda      := MSD2->D2_EMISSAO   
      If MV_PAR09 == 2 
      	Aadd(aImprime,{MTEMP->DA1_CODPRO,;
       						MTEMP->B1_DESC,;
   	   					MTEMP->DA1_PRCVEN,;
   		   				dUDataComp,;
   			   			MTEMP->B1_UM,;
   				   		MTEMP->B2_QATU,;
   					   	dUVenda,;        
   			   			MNFS->UB_VRUNIT,;
   		   				MNFE->D1_QUANT})
   	else
      	Aadd(aImprime,{MTEMP->DA1_CODPRO,;
       						MTEMP->B1_DESC,;
   	   					MTEMP->DA1_PRCVEN,;
   		   				dUDataComp,;
   			   			MTEMP->B1_UM,;
   				   		MTEMP->B2_QATU,;
   					   	dUVenda})   	
   	endif

      DbSelectArea("MTEMP")
      MTEMP->(DbSkip())	      					
   EndDo
Return

Static Function RptDetail	
  	titulo      := titulo

	SetRegua(Len(aImprime)) //Ajusta numero de elementos da regua de relatorios    
	
	
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
	
	
	nLin 		:= 9
	nTotVol	:= 0
	nTotFat	:= 0         
	//nLin 		+= 1
	//@1,000 PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
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
		   
		@ nLin,000 PSAY aImprime[I,1]
		@ nLin,015 PSAY aImprime[I,2]	 
   	@ nLin,071 PSAY aImprime[I,5] 
		@ nLin,080 PSAY aImprime[I,4]  
		@ nLin,098 PSAY aImprime[I,7]
		@ nLin,112 PSAY Transform(aImprime[I,3],"@E 9999,999.9999") 
		@ nLin,131 PSAY Transform(aImprime[I,6],"@E 9999999.99")
      If MV_PAR09 == 2 		
		   @ nLin,149 PSAY Transform(aImprime[I,8],"@E 9999,999.9999") 
		   @ nLin,177 PSAY Transform(aImprime[I,9],"@E 9999999.99")
	   endif
		nLin := nLin + 1

	Next

	Set Filter To

   SetPgEject(.F.) 

	If aReturn[5] == 1
		Set Printer To
		Commit
	   ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool   
Return