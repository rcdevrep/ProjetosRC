#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH"





User Function AGX620()          
   
	Local cPerg 	 := ""   
	Local dDataDigit := ctod('') 
    Private lDesabilit := .T.

 	If lDesabilit
 		Alert('Essa Rotina foi desabilitada, você deverá utilizar SLAAGR10 - Importacao de documentos de Entrada para integrar registros do Auto System!')
    	Return
    Endif

	
	If Alltrim(cEmpAnt) <> "20"
		Alert("Atenção! Essa rotina poderá ser executada na empresa POSTO AGRICOPEL!")
		Return()
	EndIf        
	
	cPerg := "AGX620"
	//PutSx1(cPerg, "01", "Data de          ?", "" , "", "mv_ch1", "D", 8 , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")
	//PutSx1(cPerg, "02", "Data até         ?", "" , "", "mv_ch2", "D", 8 , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")    
	//PutSx1(cPerg, "03", "Preencher DT digit com    
	//PutSx1(cPerg, "04", "Data Importação   
	If Pergunte(cPerg, .t.) 
	      
		//Se o Parametro estiver como data de Importação
	    If MV_PAR03 == 2 
	    	If Empty(MV_PAR04) //Se Data estiver vazio retorna
	    		Alert('Se escolher preencher campo Data Digitação com Data Importação é necessário preencher o Parâmetro Data de importação!')
	    		Return
	    	Else  //Senão solicita a Confirmação do Usuário
	    	 	If !MsgYesNo(" Confirma Preencher Dt. de Digitação com "+dtoc(MV_PAR04)+" ! " ) 
	    	  		Return
	    	 	Endif  
	    	 	dDataDigit := MV_PAR04
	    	Endif      
	    Endif
	
		Processa({||   Importa(dDataDigit)})
	EndIf

	
Return()    




Static Function Importa(xDataDig)  
	cQuery := ""
	
	cQuery := "SELECT  EMP1.EMP_CNPJ CNPJ_POSTO, EMP2.EMP_CNPJ CNPJ_AGRI ,*    FROM SF2010 (NOLOCK) F2 INNER JOIN SA1010  (NOLOCK) A1 "
	cQuery += " ON A1_COD  = F2_CLIENTE AND     A1_LOJA  = F2_LOJA  "
	cQuery += " INNER JOIN EMPRESAS EMP1  ON EMP1.EMP_CNPJ = A1.A1_CGC "	 
	cQuery += " INNER JOIN EMPRESAS EMP2 ON EMP2.EMP_COD = '01' AND EMP2.EMP_FIL = F2_FILIAL  "
	cQuery += " WHERE  F2_ORIIMP = 'AGX635CS' AND F2_ESPECIE = 'CTE' "
	cQuery += "   AND F2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'  "     
	cQuery += "   AND F2.D_E_L_E_T_ <> '*' AND A1.D_E_L_E_T_ <> '*' "
	cQuery += "   AND F2_CLIENTE = '00368'  ORDER BY F2_DOC "
	
	
	
	If Select("CTE") <> 0
		dbSelectArea("CTE")
		dbCloseArea()
	Endif
    
   	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "CTE"      
	
	
	dbSelectArea("CTE")
	dbGoTop()
	do While !eof()      
	
		cCnpj := ""
		
		cCnpj := CTE->CNPJ_AGRI
		
		//Busco fornecedor para insercao
		cQuery := ""
		cQuery := " SELECT A2_COD, A2_LOJA , R_E_C_N_O_ FROM " + RetSqlName("SA2") + "  "
		cQuery += " WHERE A2_CGC = '" + alltrim(cCnpj) + "' AND D_E_L_E_T_ <> '*'  " 
		cQuery += " AND A2_FILIAL = '" + xFilial("SA2") + "' " 



	    If Select("QRYSA2") <> 0
    	   dbSelectArea("QRYSA2")
	   	   dbCloseArea()
	    Endif
    
   		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRYSA2"  
				
				
		lForn    := .F. 
		cForCod  := "" 
		cForLoja := ""   
	   	cForNome := ""

		dbSelectArea("QRYSA2")
		dbGotop()
		Do While !eof()
			cForCod := QRYSA2->A2_COD
			cForLoja := QRYSA2->A2_LOJA     
	 //		cForNome := QRYSA2->A2_NOME
			
			lForn := .T.
			QRYSA2->(dbSkip())
		EndDo    
		
				//Se o representante nao estiver cadastrado realiza loop para proximo 
		If !lForn 
			Alert("Fornecedor CNPJ ->" + alltrim(cCnpj)  + " nao cadastrado na tabela SA2")
			dbSelectArea("CTE")
			CTE->(dbskip())
			loop
		EndIf   
		
		cQuery := ""
		cQuery := "SELECT R_E_C_N_O_, F1_DOC, F1_SERIE FROM " + RetSqlName("SF1") 
		cQuery += " WHERE F1_FILIAL = '" +CTE->EMP_FIL + "' "
		cQuery += "   AND (F1_DOC    = '" + CTE->F2_DOC + "')" // OR F1_DOC = '" + cDoc + "') " 
		cQuery += "   AND F1_SERIE  = '" + CTE->F2_SERIE + "' " 
		cQuery += "   AND F1_FORNECE =  '" +  cForCod + "' " 
		cQuery += "   AND F1_LOJA    = '" + cForLoja + "' "
		cQuery += "   AND F1_TIPO    = 'N' AND D_E_L_E_T_ <> '*' " 
		
	    If Select("QRYSF1") <> 0
    	   dbSelectArea("QRYSF1")
	   	   dbCloseArea()
	    Endif
    
   		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRYSF1"  
		
		
		lNot := .f.
		dbSelectArea("QRYSF1")
		dbgotop()
		While !eof() 
			lNot := .t.
			QRYSF1->(dbskip())			
		EndDo  
		
		If !lNot
			RecLock("SF1" , .T.)
				SF1->F1_FILIAL  := CTE->EMP_FIL
				SF1->F1_DOC		:= CTE->F2_DOC 		
				SF1->F1_SERIE   := CTE->F2_SERIE
				SF1->F1_FORNECE := cForCod
				SF1->F1_LOJA    := cForLoja
				SF1->F1_TIPO    := "N"
				SF1->F1_ESPECIE := CTE->F2_ESPECIE 
	//			SF1->  DOCUMENTO.CD_CONDPGTO AS F1_COND,     
				SF1->F1_EMISSAO := STOD(CTE->F2_EMISSAO)
				If Empty(xDataDig)
					SF1->F1_DTDIGIT := STOD(CTE->F2_EMISSAO)
				Else
					SF1->F1_DTDIGIT := xDataDig
				Endif
				SF1->F1_RECBMTO := STOD(CTE->F2_EMISSAO)
	//			SF1->F1_DTLANC  := STOD(cDataDigit)
				SF1->F1_EST   	:= CTE->F2_EST
				SF1->F1_FRETE   := CTE->F2_FRETE
				SF1->F1_DESPESA := CTE->F2_DESPESA
				SF1->F1_BASEICM := CTE->F2_BASEICM
				SF1->F1_VALICM  := CTE->F2_VALICM
				SF1->F1_VALMERC := CTE->F2_VALMERC 
				SF1->F1_VALBRUT := CTE->F2_VALMERC 
	 		//	SF1->F1_VALBRUT := CTE->F1_VALBRUT 
				SF1->F1_DESCONT := CTE->F2_DESCONT
				SF1->F1_BRICMS  := CTE->F2_BRICMS
				SF1->F1_ICMSRET := CTE->F2_ICMSRET
				SF1->F1_ICMS    := CTE->F2_VALICM
				SF1->F1_PESOL   := CTE->F2_PESOL
				//SF1->F1_  DOCUMENTO.TP_FRETE AS F1_FOB_R,
				SF1->F1_SEGURO	:= CTE->F2_SEGURO
				SF1->F1_CHVNFE  := CTE->F2_CHVCONH
				SF1->F1_ORIIMP := "AGX620"   
				SF1->F1_PREFIXO := CTE->F2_PREFIXO  
				SF1->F1_DUPL    := CTE->F2_DOC        
				SF1->F1_STATUS  := "A" 
				SF1->F1_COND    := "999"
			
			MsUnlock()        
			
			dbSelectArea("SD1")
			RecLock("SD1", .T. )
				SD1->D1_ORIIMP := "AGX620"
				SD1->D1_FILIAL 	:= CTE->EMP_FIL	
				SD1->D1_COD		:= "272779"
				SD1->D1_UM		:= "PC"
				SD1->D1_DESCRI  := "FRETE S/COMPRAS COMBUSTIVEIS  "
				SD1->D1_QUANT   := 1
				SD1->D1_VUNIT   := CTE->F2_VALMERC
				SD1->D1_TOTAL   := CTE->F2_VALMERC
				SD1->D1_VALICM  := CTE->F2_VALICM
				SD1->D1_VALDESC	:= CTE->F2_DESCONT
				SD1->D1_PICM    := 17
				SD1->D1_FORNECE := cForCod      
				SD1->D1_LOJA    := cForLoja
				SD1->D1_DOC     := CTE->F2_DOC
				SD1->D1_EMISSAO := STOD(CTE->F2_EMISSAO)
				If Empty(xDataDig)
					SD1->D1_DTDIGIT := STOD(CTE->F2_EMISSAO)
				Else
			  		SD1->D1_DTDIGIT := xDataDig
				Endif
				SD1->D1_SERIE   := CTE->F2_SERIE
				SD1->D1_BRICMS  := CTE->F2_BRICMS
				SD1->D1_ICMSRET := CTE->F2_ICMSRET
				SD1->D1_BASEICM := CTE->F2_VALMERC
				SD1->D1_VALDESC := CTE->F2_DESCONT
				SD1->D1_ITEM    := "01" 
				SD1->D1_TIPO    := "N"     
				SD1->D1_TES     := "062"
				SD1->D1_CF      := "1353"   
				SD1->D1_CONTA   := "112070001"
				SD1->D1_ITEMCTA := CTE->EMP_FIL	
				SD1->D1_TP      := "FR"
				SD1->D1_NUMSEQ  := ProxNum()
			MsUnlock() 
		
			cQuery := ""
			cQuery := "SELECT * FROM SE1010 " 
			cQuery += " WHERE E1_PREFIXO = '" + CTE->F2_PREFIXO + "' "
			cQuery += "   AND E1_NUM     = '" + CTE->F2_DOC + "' " // OR F1_DOC = '" + cDoc + "') " 
			cQuery += "   AND E1_CLIENTE =  '" +  CTE->F2_CLIENTE  + "' " 
			cQuery += "   AND E1_LOJA    = '" + CTE->F2_LOJA + "' "
			cQuery += "   AND D_E_L_E_T_ <> '*' " 
			
		    If Select("QRYSE1") <> 0
	    	   dbSelectArea("QRYSE1")
		   	   dbCloseArea()
		    Endif
	    
	   		cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "QRYSE1"   
			
			dbSelectArea("QRYSE1")
			dbGoTop()
			Do While !eof()   
			
		   		RecLock("SE2",.T.)  
			   		SE2->E2_HIST    	:= "AGX620"
					SE2->E2_PREFIXO		:= QRYSE1->E1_PREFIXO
					SE2->E2_NUM			:= QRYSE1->E1_NUM
					SE2->E2_PARCELA  	:= QRYSE1->E1_PARCELA
					SE2->E2_FORNECE		:= cForCod 
					SE2->E2_LOJA		:= cForLoja
					SE2->E2_NOMFOR		:= cForNome
					SE2->E2_EMISSAO  	:= STOD(QRYSE1->E1_EMISSAO)
					SE2->E2_VENCTO 		:= STOD(QRYSE1->E1_VENCTO)
					SE2->E2_VENCREA		:= STOD(QRYSE1->E1_VENCREA)
					SE2->E2_VALOR		:= QRYSE1->E1_VALOR  
					SE2->E2_EMIS1 		:= STOD(QRYSE1->E1_EMISSAO)
					SE2->E2_LA			:= ""
					SE2->E2_SALDO		:= QRYSE1->E1_VALOR 
					SE2->E2_VALLIQ		:= QRYSE1->E1_VALOR
					SE2->E2_VENCORI		:= STOD(QRYSE1->E1_VENCTO)
					SE2->E2_MOEDA		:= 1
					SE2->E2_VLCRUZ		:= QRYSE1->E1_VALOR
					SE2->E2_ORIGEM		:= "MATA100"    
					SE2->E2_TIPO 		:= "NF" 				
					SE2->E2_FILORIG		:= CTE->EMP_FIL 
			//		SE2->E2_FILIAL      := "01"
				MsUnLock() 
		  	     
		  		dbSelectArea("QRYSE1")
		  		QRYSE1->(dbskip())
			EndDo    
					
		endif
		

		dbSelectArea("CTE")
		CTE->(dbSkip())
	
	EndDo

Return()





