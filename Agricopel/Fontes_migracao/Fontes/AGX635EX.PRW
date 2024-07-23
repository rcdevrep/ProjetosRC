#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ROTINA DE INTEGRAÇÃO COM DBGINT - Exclusão Nota de Entrada
*/
/*/{Protheus.doc} AGX635EX
//ROTINA DE INTEGRAÇÃO COM DBGINT - Exclusão Nota de Entrada
@author Spiller
@since 11/09/2017
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/   
User Function AGX635EX(aEmpDePara,xReproc)

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local nQtdeNE        := 0
	Local cArqTmp		 := ""
	Local cEmpPara       := ""   
	Local cFilialPara    := "" 
	Private nEmpDe       := 0
	Private cAliasCapa   := ""    
	Private cAliasPROD   := ""  
	Private aIntCAPA	 := {} //Array com Notas que foram integradas
	Private aIntITENS	 := {} //Array com Notas que foram integradas  
	Private aLogs		 := {} //Array de Logs  
	Private lClearEnv    := .F.   
	Default xReproc      := .F.
	Private lReproc      := xReproc

	conout('Iniciando AGX635EX - '+time())
	For nCountDe := 1 To Len(aEmpDePara)

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

			cEmpPara     := aEmpPara[nCountPara][2]
			cFilialPara  := aEmpPara[nCountPara][3] 
			nFilde       := aEmpPara[nCountPara][1] 
							
			lClearEnv := .T.
		  	
		  	PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","XXS"
		          
		   		//EXCLUI Nota de Entrada
			  	RPCSetType(3)
			  	RpcSetEnv(cEmpPara,cFilialPara)		
					cArqTmp := CriaArqNE(nEmpDe,nFilde)	
					cAliasCapa := GetNextAlias()
					DbUseArea(.T., Nil, cArqTmp, (cAliasCapa))
					nQtdeNE := (cAliasCapa)->(RecCount())
						
					If nQtdeNE > 0
						ExcluirNFE(cAliasCapa)
		    	    Endif
			                
			   //	RPCClearEnv()
			//	dbCloseAll()    
				
				//EXCLUI CTE de Entrada
			  //	RPCSetType(3)
			  //	RpcSetEnv(cEmpPara,cFilialPara)		
					cArqTmp := CriaArqCE(nEmpDe,nFilde)	
					cAliasCapa := GetNextAlias()
					DbUseArea(.T., Nil, cArqTmp, (cAliasCapa))
					nQtdeCE := (cAliasCapa)->(RecCount())
						
					If nQtdeCE > 0
						ExcluirCTE(cAliasCapa)
		    	    Endif
			                
			 	RPCClearEnv()
				dbCloseAll()           
			RESET ENVIRONMENT			  	
			 		
		
		Next nCountPara         
              
		FErase(cArqTmp + GetDbExtension())
		FErase(cArqTmp + OrdBagExt())
	Next nCountDe 
	 
	//Grava Logs
	If len(aLogs) > 0     
 		//Grava Log
		U_AGX635LO(aLogs,'AGX635EX','EXCLUSAO NOTA ENTRADA')
 	Endif
		
Return(aEmpDePara)
                            

//Busca dados da NFE de Entrada
Static Function SelectNFE(nEmpOrigem,nFilOrigem)

	Local cAliasCapa := GetNextAlias()
	Local cQuery    := "" 
	Default nFilOrigem := 0  
	
	cQuery := "SELECT "
	cQuery += "COM_NOTCOM_EXC_Empresa AS DBEMP,  "
	cQuery += "COM_NOTCOM_EXC_Filial  AS DBFIL,  "
	cQuery += "CAST(COM_NOTCOM_EXC_Numero AS CHAR) AS F1_DOC,  "  
	cQuery += "COM_NOTCOM_EXC_Serie   AS F1_SERIE, "
	cQuery += "COM_NOTCOM_EXC_Emissao AS F1_EMISSAO, " 
	cQuery += "COM_NOTCOM_ValorNF 	 AS F1_VALBRUT, "
	cQuery += "CAST(COM_NOTCOM_EXC_Fornecedor AS  CHAR) AS DBFORN  , "
	cQuery += "CAST(COM_NOTCOM_EXC_Endereco AS  CHAR) AS DBENT  ,   "
	cQuery += "ENDENT.GEN_ENDENT_IF 			 AS CNPJ_CPF ,      "
	cQuery += "COM_NOTCOM_EXC_Created AS DT_EXC "
	cQuery += "FROM COM_NOTCOM_EXC COM_NOTCOM_EXC "
	cQuery += "LEFT JOIN COM_NOTCOM ON       "
	cQuery += "COM_NOTCOM_EXC_Empresa = STG_GEN_TABEMP_Codigo AND "
	cQuery += "COM_NOTCOM_EXC_Filial  = STG_GEN_TABFIL_Codigo AND "
	cQuery += "COM_NOTCOM_EXC_Numero  = COM_NOTCOM_Numero AND   "
	cQuery += "COM_NOTCOM_EXC_Serie   = COM_NOTCOM_Serie AND   "
	cQuery += "COM_NOTCOM_EXC_Fornecedor = STG_GEN_TABENT_For_Codigo AND "
	cQuery += "COM_NOTCOM_EXC_Endereco   = STG_GEN_ENDENT_For_Codigo "
	cQuery += "INNER JOIN GEN_ENDENT ENDENT ON "
	cQuery += "			ENDENT.GEN_TABENT_CODIGO = COM_NOTCOM_EXC_Fornecedor AND "
	cQuery += "            ENDENT.GEN_ENDENT_Codigo =  COM_NOTCOM_EXC_Endereco  "
	cQuery += "WHERE COM_NOTCOM_NUMERO IS NULL "
	cQuery += "AND COM_NOTCOM_EXC_DHIntTotvs IS NULL "
   
	If nFilOrigem <> 0  
		cQuery += " AND  COM_NOTCOM_EXC_Filial = " + cValToChar(nFilOrigem)
    Endif   
    
    //conout(cQuery)
	U_AGX635CN("DBG")    
	
	If Select(cAliasCapa) <> 0
		dbSelectArea(cAliasCapa)
		(cAliasCapa)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasCapa)

Return(cAliasCapa)                        


//eXCLUI dados no Protheus
Static Function ExcluirNFE(cAliasCapa)

	Local lNovo  := .T.
	Local lRegOK := .T. 
	Local cFil   := '' 
    	  
	U_AGX635CN("PRT") 
	

	
	(cAliasCapa)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cAliasCapa)->(!eof())
		
		  
		//se NÃO encontrou Fornecedor, IGNORA
		DBSELECTAREA('SA2') 
		SA2->(DbGoTop())
		SA2->(DbSetOrder(3))
		If !(SA2->(DbSeek(xFilial("SA2")+(cAliasCapa)->(CNPJ_CPF)))) 	
			//Marca Para Baixar o registro
		   	AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })						  
			(cAliasCapa)->(dbskip()) 
			LOOP  
		Endif
	   
					 
		dbselectarea(cAliasCapa)       
		aTam    := {}
		aTam    := TamSX3("F1_DOC")
		_cDoc   := PADL(alltrim((cAliasCapa)->(F1_DOC)),aTam[1],'0')
        
        aTam    := {}
		aTam    := TamSX3("F1_SERIE")	
        _cSerie := StrTran(PADR(alltrim((cAliasCapa)->(F1_SERIE)),aTam[1],' '),'-','' )   
        
		//Verifica se já existe no Protheus
		dbselectarea('SF1')
		dbsetorder(1)
		If dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)
	
			conout((SF1->F1_DTDIGIT - dDatabase))
			If   (dDatabase - SF1->F1_DTDIGIT  ) < 120
   	    		conout('AGX635EX - Excluindo NF: '+(cAliasCapa)->(F1_DOC)+'/'+(cAliasCapa)->(F1_SERIE)+time())
	   			// Verifica se título já foi baixado no Protheus,
	   			// Se ainda nao foi baixado,exclui, Senão Gera Log 
	   			If U_AGX635JB((cAliasCapa)->(F1_VALBRUT))	 
	   			
	   				// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
		   			If !lReproc   
						//GRAVA Array de LOG
	        			AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'EXCLUSAO: Nfe com Tit.Baixado com Valor Diferente: '+_cDoc+'-'+_cSerie+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cAliasCapa)->(F1_DOC)+'+'+(cAliasCapa)->(F1_SERIE)+'+'+(cAliasCapa)->(DBFORN)+'+'+(cAliasCapa)->(DBENT)},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1},;  
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
						})   		  
							  
			 		Else
			 			Alert('Nfe com Tit.Baixado ou n Imp. do DBGINT: '+SF1->F1_DOC+SF1->F1_SERIE+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')')
			 		Endif
		 		
		 		(cAliasCapa)->(dbskip()) 
				LOOP
			Else
				//Marca Para Baixar o registro
		   		AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })
			Endif
		Else  
				//Marca Para Baixar o registro
		   		AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })
			Endif 
	 	Endif          
	 	

		(cAliasCapa)->(dbskip())  
	Enddo	                         
	
   // MARCA DATA/HORA PARA IDENTIFICAR QUE REGISTRO FOI IMPORTADOS 
    If Len(aIntCAPA) > 0 
		BaixarNFE(aIntCAPA)  
		aIntCAPA := {} 
    Endif 
Return()
                

//Cria Arquivo de Trabalho
Static Function CriaArqNE(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectNFE(nEmpOrigem,nFilOrigem)

	aStruTmp := (cAliasQry)->(DbStruct())
	cArqTmp  := CriaTrab(aStruTmp, .T.)

	cAliasArea := GetNextAlias()
	DbUseArea(.T., Nil, cArqTmp, (cAliasArea))

	nFieldCount := (cAliasArea)->(FCount())

	While !(cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		For nX := 1 To nFieldCount
			cFieldName := (cAliasArea)->(FieldName(nX))
			(cAliasArea)->&(cFieldName) := (cAliasQry)->&(cFieldName)
		Next nX

		MsUnlock((cAliasArea))
		(cAliasQry)->(DbSkip())
	End

   	//RPCClearEnv()

Return(cArqTmp)     

//Cria Arquivo de Trabalho
Static Function CriaArqCE(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectCTE(nEmpOrigem,nFilOrigem)

	aStruTmp := (cAliasQry)->(DbStruct())
	cArqTmp  := CriaTrab(aStruTmp, .T.)

	cAliasArea := GetNextAlias()
	DbUseArea(.T., Nil, cArqTmp, (cAliasArea))

	nFieldCount := (cAliasArea)->(FCount())

	While !(cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		For nX := 1 To nFieldCount
			cFieldName := (cAliasArea)->(FieldName(nX))
			(cAliasArea)->&(cFieldName) := (cAliasQry)->&(cFieldName)
		Next nX

		MsUnlock((cAliasArea))
		(cAliasQry)->(DbSkip())
	End

   	//RPCClearEnv()

Return(cArqTmp)           
  

//Baixa dados no DBGint
Static Function BaixarNFE(xIntCapa)

	Local cNFEIN   := ""              
	Local nQtdeIN  := 0

	U_AGX635CN("DBG") 

	  				 //Empresa           ,  Filial              , Documento                        , Serie,  Fornece    			, Loja                           
	//AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })

    For i := 1 to len(xIntCapa)
        
       //Monta Clausula Where do documento 
        If nQtdeIN == 0
       		 cNFEIN := " AND (" 
       	Else
      		 cNFEIN += " ) OR ("  	
        Endif
        cNFEIN += " COM_NOTCOM_EXC_Empresa 	  =  "+alltrim(str(xIntCapa[i][1]))+""
		cNFEIN += " AND COM_NOTCOM_EXC_Filial	  =  "+alltrim(str(xIntCapa[i][2]))+""
		cNFEIN += " AND COM_NOTCOM_EXC_Numero 		  =  "+xIntCapa[i][3]+""
		cNFEIN += " AND COM_NOTCOM_EXC_Serie 		  =  '"+xIntCapa[i][4]+"'"
		cNFEIN += " AND COM_NOTCOM_EXC_Fornecedor =  "+xIntCapa[i][5]+""
		cNFEIN += " AND COM_NOTCOM_EXC_Endereco =  "+xIntCapa[i][6]+""
		
   		//cNFEIN += ",'" + AllTrim((cAliasCapa)->(F1_DOC)+(cAliasCapa)->(F1_SERIE)) + "'"
		nQtdeIN += 1

		If (nQtdeIN >= 10) .Or. len(xIntCapa) == i 
			
			cNFEIN += ") " 
			
			UpdateNFE(cNFEIN)

			nQtdeIN := 0
			cNFEIN := ""
		EndIf
	Next i 

Return()

Static Function UpdateNFE(cNFEIN)

	Local cQuery   := ""
    
	//Atualiza CAPA
	cQuery += " UPDATE COM_NOTCOM_EXC SET "
	cQuery += " COM_NOTCOM_EXC_DHIntTotvs = current_timestamp() "
	cQuery += " WHERE COM_NOTCOM_EXC_DHIntTotvs IS NULL "
	cQuery += cNFEIN

	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao executar SQL: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf   
		           
Return()         

//Busca dados da NFE de Entrada
Static Function SelectCTE(nEmpOrigem,nFilOrigem)

	Local cAliasCapa := GetNextAlias()
	Local cQuery    := "" 
	Default nFilOrigem := 0  
	
	cQuery := "SELECT "
	cQuery += "COM_CONFRE_EXC_Empresa AS DBEMP, "
	cQuery += "COM_CONFRE_EXC_Filial  AS DBFIL,  " 
	cQuery += "COM_CONFRE_Valor       AS F1_VALBRUT, "
	cQuery += "CAST(COM_CONFRE_EXC_Numero AS CHAR) AS F1_DOC,  "  
	cQuery += "COM_CONFRE_EXC_Serie   AS F1_SERIE, "
	cQuery += "COM_CONFRE_EXC_Emissao AS F1_EMISSAO, "
	cQuery += "CAST(COM_CONFRE_EXC_Transportadora AS  CHAR) AS DBFORN  , "
	cQuery += "CAST(COM_CONFRE_EXC_Endereco AS  CHAR) AS DBENT  ,  " 
	cQuery += "ENDENT.GEN_ENDENT_IF 			 AS CNPJ_CPF ,  "    
	cQuery += "COM_CONFRE_EXC_Created AS DT_EXC "
	cQuery += "FROM COM_CONFRE_EXC "
	cQuery += "INNER JOIN GEN_ENDENT ENDENT ON "
	cQuery += "ENDENT.GEN_TABENT_CODIGO = COM_CONFRE_EXC_Transportadora AND "
	cQuery += "ENDENT.GEN_ENDENT_Codigo =  COM_CONFRE_EXC_Endereco "
	cQuery += "LEFT JOIN COM_CONFRE ON  "     
	cQuery += "COM_CONFRE_EXC_Empresa = STG_GEN_TABEMP_Codigo AND "
	cQuery += "COM_CONFRE_EXC_Filial  = STG_GEN_TABFIL_Codigo AND  "
	cQuery += "COM_CONFRE_EXC_Numero  = COM_CONFRE_Numero AND  "  
	cQuery += "COM_CONFRE_EXC_Serie   = COM_CONFRE_Serie AND   "
	cQuery += "COM_CONFRE_EXC_Transportadora = STG_COM_CONFRE_Tra_Codigo AND "
	cQuery += "COM_CONFRE_EXC_Endereco   = STG_COM_CONFRE_Etr_Codigo "
	cQuery += "WHERE COM_CONFRE_NUMERO IS NULL "
	cQuery += "AND COM_CONFRE_EXC_DHIntTotvs IS NULL "
   
	If nFilOrigem <> 0  
		cQuery += " AND  COM_CONFRE_EXC_Filial = " + cValToChar(nFilOrigem)
    Endif   
    
    //conout(cQuery)
	U_AGX635CN("DBG")    
	
	If Select(cAliasCapa) <> 0
		dbSelectArea(cAliasCapa)
		(cAliasCapa)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasCapa)

Return(cAliasCapa)   
              


//Excluir dados no Protheus
Static Function ExcluirCTE(cAliasCapa)

	Local lNovo  := .T.
	Local lRegOK := .T. 
	Local cFil   := '' 
    	  
	U_AGX635CN("PRT") 
	
	(cAliasCapa)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cAliasCapa)->(!eof())
		
		conout('AGX635EX - Excluindo CTE: '+(cAliasCapa)->(F1_DOC)+'/'+(cAliasCapa)->(F1_SERIE)+time())
		  
		//se NÃO encontrou Fornecedor, IGNORA
		DBSELECTAREA('SA2') 
		SA2->(DbGoTop())
		SA2->(DbSetOrder(3))
		If !(SA2->(DbSeek(xFilial("SA2")+(cAliasCapa)->(CNPJ_CPF)))) 	
			//Marca Para Baixar o registro
		   	AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })						  
			(cAliasCapa)->(dbskip()) 
			LOOP  
		Endif
	   
					 
		dbselectarea(cAliasCapa)       
		aTam    := {}
		aTam    := TamSX3("F1_DOC")
		_cDoc   := PADL(alltrim((cAliasCapa)->(F1_DOC)),aTam[1],'0')
        
        aTam    := {}
		aTam    := TamSX3("F1_SERIE")	
        _cSerie := StrTran(PADR(alltrim((cAliasCapa)->(F1_SERIE)),aTam[1],' '),'-','' )   
        
		//Verifica se já existe no Protheus
		dbselectarea('SF1')
		dbsetorder(1)
		If dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)  
	   	     
	   	    If(dDatabase - SF1->F1_DTDIGIT  ) > 365 
	   	      		(cAliasCapa)->(dbskip()) 
				LOOP 
	   	    Endif
	   	    
	   		// Verifica se título já foi baixado no Protheus,
	   		// Se ainda nao foi baixado,exclui, Senão Gera Log 
	   		If U_AGX635JB((cAliasCapa)->(F1_VALBRUT),.T.)	 
	   			
	   			// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
		   		If !lReproc   
					//GRAVA Array de LOG
	        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'EXCLUSAO: CTE com Tit.Baixado com Valor Diferente: '+_cDoc+'-'+_cSerie+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cAliasCapa)->(F1_DOC)+'+'+(cAliasCapa)->(F1_SERIE)+'+'+(cAliasCapa)->(DBFORN)+'+'+(cAliasCapa)->(DBENT)},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1},;  
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
						})   		  
							  
			 	Else
			 		Alert('CTE com Tit.Baixado ou n Imp. do DBGINT: '+SF1->F1_DOC+SF1->F1_SERIE+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')')
			 	Endif
		 		
		 		(cAliasCapa)->(dbskip()) 
				LOOP
			Else  
				//Marca Para Baixar o registro
		   		AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })
			Endif 
	 	Endif          
	 	

		(cAliasCapa)->(dbskip())  
	Enddo	                         
	
   // MARCA DATA/HORA PARA IDENTIFICAR QUE REGISTRO FOI IMPORTADOS 
    If Len(aIntCAPA) > 0 
		BaixarNFE(aIntCAPA)  
		aIntCAPA := {} 
    Endif 
Return()