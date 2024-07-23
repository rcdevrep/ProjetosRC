//#INCLUDE "MATA805.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
//#INCLUDE "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MA805Process³ Autor ³ Rodrigo de A. Sartorio³ Data ³13/09/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a inclusao de saldos por localizacao fisica no SBF³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA805                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGX456()
// Obtem numero sequencial do movimento
LOCAL cNumSeq:=ProxNum(),i
// Numero do Item do Movimento
Local cCounter	:= '0001'	//StrZero(0,TamSx3('DB_ITEM')[1])   


Private cPerg := "AGX456"
	
	
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Produto            ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"}) 
	AADD(aRegistros,{cPerg,"02","Armazem            ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})  
	AADD(aRegistros,{cPerg,"03","Quantidade         ?","mv_ch3","N",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""}) 
	AADD(aRegistros,{cPerg,"04","Endereco           ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SBE"})  
	AADD(aRegistros,{cPerg,"05","Lote               ?","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})  
	AADD(aRegistros,{cPerg,"06","Documento          ?","mv_ch6","C",06,0,0,"G","","mv_par06","","INVACT","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Serie              ?","mv_ch7","C",03,0,0,"G","","mv_par07","","ACT","","","","","","","","","","","","",""})     
	AADD(aRegistros,{cPerg,"08","Entrada Inf.       ?","mv_ch8","N",01,0,0,"C","","mv_par08","Importacao","","","Manual","","","","","","","","","","",""}) 
	AADD(aRegistros,{cPerg,"09","Arquivo Inventario ?","mv_ch9","C",30,0,0,"G","","mv_par09","","c:\","","","","","","","","","","","","",""})
 

	U_CriaPer(cPerg,aRegistros)  
	
    cTipoMov := ""         

	Pergunte(cPerg,.T.)     
	
	If MsgYesNo("Deseja atualizar saldos gerenciais (SBF/SB2) ?" ,"Acerto Saldos SBF") 
		If mv_par08 == 1
			cQuery := "      SELECT CODIGO,ENDERECO,SUM(CONT1) SALDO FROM TMP  GROUP BY CODIGO,ENDERECO"
			If (Select("QRY") <> 0)
				dbSelectArea("QRY")	
				dbClseArea()
			Endif
	
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "QRY"
	
			dbSelectArea("QRY")
			ProcRegua(500)
			dbGoTop()
			While !Eof()              
					Processa({|| ActSBF(QRY->CODIGO,mv_par05,"01",QRY->ENDERECO,QRY->SALDO,mv_par06,mv_par07)}, "Inventario SBF! Aguarde...")		        
		    		Processa({|| ActSB2(QRY->CODIGO)}, "Inventario SBF! Aguarde...") 
   					dbSelectArea("QRY")		        		    
			       QRY->(dbskip())
		    enddo
        else        
			Processa({|| ActSBF(mv_par01,mv_par05,mv_par02,mv_par04,mv_par03,mv_par06,mv_par07)}, "Inventario SBF! Aguarde...")		        
    		Processa({|| ActSB2(mv_par01)}, "Inventario SB2! Aguarde...")		        
			

	    EndIf

	EndIf	

Return()



Static Function ImpArq()



Return()
	

Static Function ActSBF(cProduto,cLot,cLocal,cEnd,nQtd,cDoc,cSerie)    
// Obtem numero sequencial do movimento
LOCAL cNumSeq:=ProxNum(),i
// Numero do Item do Movimento
Local cCounter	:= '0001'	//StrZero(0,TamSx3('DB_ITEM')[1])   
	
	cCounter := Soma1(cCounter)  
				
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÌ¿
	//³Busco Informações dos produtos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÌÙ
	ENDDOC*/           
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbgoTop()
	if !dbseek(xFilial("SB1")+cProduto)
		Alert("Atenção! Produto não encontrado!")
	    return()
	EndIf
		    
	cContLot := ""
	cContEnd := ""    
	cLote    := ""
		   
	cContLot := SB1->B1_RASTRO
	cContEnd := SB1->B1_LOCALIZ    
	cLote    := cLot  
	
	
/*	If cContLot == "L"    
			//Verifico se o produto possui lote informado
			
			cQuery := ""
			cQuery += "SELECT * "   
			cQuery += "FROM " + RETSQLNAME("SB8") + " "    
			cQuery += "WHERE D_E_L_E_T_ <> '*' "        
			cQuery += "  AND B8_FILIAL = '"  + xFilial("SB8") + "' " 
			cQuery += "  AND B8_LOCAL   = '"   + cLocal + "' "  
			cQuery += "  AND B8_PRODUTO = '"   + cProduto + "' "  
			cQuery += "  AND B8_LOTECTL = '"   + cLote + "' "  
			
			
			If (Select("QRY") <> 0)
				dbSelectArea("QRY")
				dbCloseArea()
			Endif
		
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "QRY"
			
		    cExisLot := "N"
			dbSelectArea("QRY")
			dbGoTop()
			While !Eof()   
			   cExisLot := "S"
			   QRY->(dbSkip())
			EndDo
		    if cExisLot == "N"  
		      Alert("Atenção! Lote não cadastrado!")
		      Return()
		    EndIf   
		 else
		    cLote := ""
		 EndIf*/
	    
			    
		/*BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco Saldo no endereço³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ENDDOC*/             
		
		
		cQuery := ""
		cQuery += "SELECT * "   
		cQuery += "FROM " + RETSQLNAME("SBF") + " "    
		cQuery += "WHERE D_E_L_E_T_ <> '*' "        
		cQuery += "  AND BF_FILIAL = '"  + xFilial("SBF") + "' " 
		cQuery += "  AND BF_LOCAL   = '"   + cLocal + "' "  
		cQuery += "  AND BF_PRODUTO = '"   + cProduto + "' "  
		cQuery += "  AND BF_LOCALIZ = '"   + cEnd + "' "  
		
		
		If (Select("QRY_SBF") <> 0)
			dbSelectArea("QRY_SBF")
			dbCloseArea()
		Endif
	
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRY_SBF"
        
        nQtdEnd := 0   
        		
		dbSelectArea("QRY_SBF")
		dbGoTop()
		Do While !eof()
		   nQtdEnd := QRY_SBF->BF_QUANT
		   QRY_SBF->(dbSkip())		
		EndDo
			
		 nQtdDif := 0
         //Verifico o valor que deve estar em estoque
         
         Do Case
            Case nQtdEnd < 0 
	            nQtdDif := nQtd + (nQtdEnd*(-1)) 
	            cTipoMov := "100" //Entrada
	        Case nQtd > nQtdEnd
	            nQtdDif := nQtd - nQtdEnd 
	            cTipoMov := "100" //Entrada
	        Case nQtd < nQtdEnd
				nQtdDif := nQtdEnd - nQtd
	            cTipoMov := "600" //saida           
	     EndCase

            	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria registro de movimentacao por Localizacao (SDB)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			
			  
	
		CriaSDB(cProduto,;	// Produto
				cLocal,;	// Armazem
			    nQtdDif,;	// Quantidade
				cEnd,;	// Localizacao
				"",;	// Numero de Serie
				cDoc,;		// Doc
				cSerie,;		// Serie
				"",;			// Cliente / Fornecedor
				"",;			// Loja
				"",;			// Tipo NF
				"ACT",;			// Origem do Movimento
				dDataBase,;		// Data
				cLote,;	// Lote
				"",; // Sub-Lote
				cNumSeq,;		// Numero Sequencial
				cTipoMov,;			// Tipo do Movimento
				"M",;			// Tipo do Movimento (Distribuicao/Movimento)
				cCounter,;		// Item
				.F.,;			// Flag que indica se e' mov. estorno
				0,;		// Quantidade empenhado
				0)		// Quantidade segunda UM
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma saldo em estoque por localizacao fisica (SBF)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GravaSBF("SDB")

Return()    


Static Function ActSB2(cProduto)

		aMov		:= {}
		cTipoMov := ""  
		lentrou := .f.       
		

		
		cQuery := ""
		cQuery += "SELECT BF_PRODUTO,BF_LOCAL ,SUM(BF_QUANT) SALDO "   
		cQuery += "FROM " + RETSQLNAME("SBF") + " "    
		cQuery += "WHERE D_E_L_E_T_ <> '*' "        
		cQuery += "  AND BF_FILIAL = '"  + xFilial("SBF") + "' " 
		cQuery += "  AND BF_PRODUTO = '"   + cProduto + "' "  
		cQuery += " GROUP BY BF_PRODUTO,BF_LOCAL  "

		
		If (Select("QRY_SBF") <> 0)
			dbSelectArea("QRY_SBF")
			dbCloseArea()
		Endif
	
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRY_SBF"
        
        nQtdEnd := 0   
        		
		dbSelectArea("QRY_SBF")
		dbGoTop()
		Do While !eof()
		   nQtdEnd := QRY_SBF->SALDO    
           lentrou := .t.
		   
		     dbSelectArea("SB2")
		     dbSetOrder(1)
		     dbSeek(xFilial("SB2")+QRY_SBF->BF_PRODUTO+QRY_SBF->BF_LOCAL)
			
			 nQtdDif := 0
    	     //Verifico o valor que deve estar em estoque
         
        	 Do Case
            	Case SB2->B2_QATU < 0 
	            	nQtdDif := nQtdEnd + (SB2->B2_QATU*(-1)) 
		            cTipoMov := "100" //Entrada
		        Case nQtdEnd > SB2->B2_QATU
	    	        nQtdDif := nQtdEnd - SB2->B2_QATU 
	        	    cTipoMov := "100" //Entrada
		        Case nQtdEnd < SB2->B2_QATU
					nQtdDif := SB2->B2_QATU  - nQtdEnd
	    	        cTipoMov := "600" //saida           
		     EndCase

   
			 dbSelectArea("SB1")
  		     dbSetOrder(1)
			 dbgoTop()
			 if !dbseek(xFilial("SB1")+cProduto)
			    Alert("Atenção! Produto não encontrado!")
			    return()
  		     EndIf
			    
			 cContLot := ""
			 cContEnd := ""
			   
		     cContLot := SB1->B1_RASTRO
		     cContEnd := SB1->B1_LOCALIZ            
		
		   
		   RecLock("SB1",.F.)
		      SB1->B1_RASTRO := "N"
		      SB1->B1_LOCALIZ := "N"
		   MsUnlock( )  
		   
		
		   AAdd(aMov,{'D3_FILIAL'		,xFilial("SB2")				,Nil})		
		   AAdd(aMov,{'D3_TM'		,cTipoMov				,Nil})
		   AAdd(aMov,{'D3_COD'		,QRY_SBF->BF_PRODUTO		,Nil})
		   AAdd(aMov,{'D3_QUANT'	    ,nQtdDif								,Nil})
		   AAdd(aMov,{'D3_LOCAL'	    ,QRY_SBF->BF_LOCAL	,Nil})

		   AAdd(aMov,{'D3_EMISSAO'	,dDataBase		  								,Nil})
		   
		
		
		   lMsErroAuto := .F.
			Begin Transaction
			   MSEXECAUTO({|x|MATA240(x)},aMov)  
				If lMsErroAuto
					// Gravo o log de erro com 'LOT', mais o numero e serie da nota fiscal que nao conseguiu ser dado entrada
					////////////////////////////////////////////////////////////////////////////////////////////////////////////
					MostraErro("c:\" ,"aaa.txt")
					DisarmTransaction()
					break
				Endif
			End Transaction                    
			   RecLock("SB1",.F.)
			      SB1->B1_RASTRO := cContLot
			      SB1->B1_LOCALIZ := cContEnd
			   MsUnlock( )  
		   dbSelectArea("QRY_SBF")
  		   QRY_SBF->(dbSkip())		
	  EndDo		            
	  if !lentrou
	  	   nQtdEnd := 0
           lentrou := .t.          

		   
		     dbSelectArea("SB2")
		     dbSetOrder(1)
		     dbSeek(xFilial("SB2")+cProduto+"01")
			
			 nQtdDif := 0
    	     //Verifico o valor que deve estar em estoque
         
        	 Do Case
            	Case SB2->B2_QATU < 0 
	            	nQtdDif := nQtdEnd + (SB2->B2_QATU*(-1)) 
		            cTipoMov := "100" //Entrada
		        Case nQtdEnd > SB2->B2_QATU
	    	        nQtdDif := nQtdEnd - SB2->B2_QATU 
	        	    cTipoMov := "100" //Entrada
		        Case nQtdEnd < SB2->B2_QATU
					nQtdDif := SB2->B2_QATU  - nQtdEnd
	    	        cTipoMov := "600" //saida           
		     EndCase

   
			 dbSelectArea("SB1")
  		     dbSetOrder(1)
			 dbgoTop()
			 if !dbseek(xFilial("SB1")+cProduto)
			    Alert("Atenção! Produto não encontrado!")
			    return()
  		     EndIf
			    
			 cContLot := ""
			 cContEnd := ""
			   
		     cContLot := SB1->B1_RASTRO
		     cContEnd := SB1->B1_LOCALIZ            
		
		   
		   RecLock("SB1",.F.)
		      SB1->B1_RASTRO := "N"
		      SB1->B1_LOCALIZ := "N"
		   MsUnlock( )  
		   
		
		   AAdd(aMov,{'D3_FILIAL'		,xFilial("SB2")				,Nil})		
		   AAdd(aMov,{'D3_TM'		,cTipoMov				,Nil})
		   AAdd(aMov,{'D3_COD'		,cProduto		,Nil})
		   AAdd(aMov,{'D3_QUANT'	    ,nQtdDif								,Nil})
		   AAdd(aMov,{'D3_LOCAL'	    ,"01"	,Nil})

		   AAdd(aMov,{'D3_EMISSAO'	,dDataBase		  								,Nil})
		   
		
		
		   lMsErroAuto := .F.
			Begin Transaction
			   MSEXECAUTO({|x|MATA240(x)},aMov)  
				If lMsErroAuto
					// Gravo o log de erro com 'LOT', mais o numero e serie da nota fiscal que nao conseguiu ser dado entrada
					////////////////////////////////////////////////////////////////////////////////////////////////////////////
					MostraErro("c:\" ,"aaa.txt")
					DisarmTransaction()
					break
				Endif
			End Transaction                    
			   RecLock("SB1",.F.)
			      SB1->B1_RASTRO := cContLot
			      SB1->B1_LOCALIZ := cContEnd
			   MsUnlock( )  
	  	  
	  EndIf

Return()                                                         



