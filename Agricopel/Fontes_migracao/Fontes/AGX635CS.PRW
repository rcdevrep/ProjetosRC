#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} AGX635CS
//ROTINA DE INTEGRAÇÃO COM DBGINT - CTE de Saída
@author Spiller
@since 11/09/2017
@version undefined
@param aEmpDePara, array, Empresas
@type function
/*/
User Function AGX635CS(aEmpDePara,xReproc)

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local nQtdeNE        := 0
	Local cArqTmp		 := ""
	Local cEmpPara       := ""
	Local cFilialPara    := "" 
	Private nEmpDe       := 0
	Private cCapaCTS     := ""    
	Private cAliasNFE    := ""  
	Private aIntCAPA	 := {} //Array com Notas que foram integradas
	Private aIntITENS	 := {} //Array com os itens das notas que foram integradas  
	Private aLogs		 := {} //Array de Logs  
	Private lClearEnv    := .F.
	Default xReproc      := .F.
	Private lReproc      := xReproc   
	//Private cMailNyke    := "" //Retirado, pois execuções por Job não gerar PDf
	Private aItens116    := {}  
	Private cProjeto     := ""
    
//	conout('Iniciou AGX635CS '+time())

	For nCountDe := 1 To Len(aEmpDePara)

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3] 
				nFilde       := aEmpPara[nCountPara][1] 
				
				lClearEnv := .T.
				conout(' AGX635CS '+cEmpPara+' / '+cFilialPara)
			  	PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5","XXS"

				   	RPCSetType()
			  		RPCSetEnv(cEmpPara, cFilialPara)
				
					//Busca dados e Grava no Arq de trabalho por Filial
					cArqTmp := CriaArqCS(nEmpDe,nFilde)

					cCapaCTS := GetNextAlias()
					DbUseArea(.T., Nil, cArqTmp, (cCapaCTS))
					nQtdeCTS := (cCapaCTS)->(RecCount())
					  
					//Caso tenha algum CTE
					//Inclui dados no Protheus
					If nQtdeCTS > 0
						InserirCTS(cCapaCTS)
	                Endif
	                
				 	RPCClearEnv()
					dbCloseAll()
				
			   	RESET ENVIRONMENT
			
		Next nCountPara
           
  		FErase(cArqTmp + GetDbExtension())
		FErase(cArqTmp + OrdBagExt())
	Next nCountDe 
	   
	//Grava dados de LOG
	If len(aLogs) > 0     
 		//Grava Log
		U_AGX635LO(aLogs,'AGX635CS','IMPORTACAO CTE SAIDA')
 	Endif
 	 //U_AGX635CN("PRT")
Return(aEmpDePara)
  
  
//Busca CTE´S para importação
Static Function SelectCTS(nEmpOrigem,nFilOrigem)

    Local cCapaCTS := GetNextAlias()
    Local cQuery    := "" 	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1     
	
	//CTE´S
	cQuery := " SELECT  "
	cQuery += " CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo     AS DBEMP,     "+CHR(13)
	cQuery += " CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo     AS DBFIL,     "+CHR(13) 
	cQuery += " CAST(CTE_MOVCTE_TipoCTE AS  CHAR) AS TIPOCTE,  "+CHR(13)
	cQuery += " CTE_MOVCTE_ChaveDocAnt AS CHAVEANT  ,  "+CHR(13)   
	cQuery += " CTE_MOVCTE.CTE_MOVCTE_ID		  AS IDCTE,     "+CHR(13)     
	cQuery += " GEN_NATOPE_Codigo                AS NATOPE, "+CHR(13)
	cQuery += " GEN_NATOPE_TES 			      AS D2_TES,    "+CHR(13) 
	cQuery += " ENDENT.GEN_ENDENT_IF 	      AS CNPJ_CPF,  "+CHR(13) 
	cQuery += " REMETENTE.GEN_ENDENT_IF       AS REM_CNPJ,  "+CHR(13) 
	cQuery += " STG_GEN_ESTMUN_Ini_Estado     AS EST_INI,  "+CHR(13) 
	cQuery += " STG_GEN_ESTMUN_Fim_Estado     AS EST_FIM,  "+CHR(13) 
	//cQuery += " STG_CTE_UNIMED_CTe_Codigo     AS UNMED,		"+CHR(13)
	cQuery += " CTE_TABPRO.CTE_UNIMED_Codigo  AS UNMED,		"+CHR(13)
	cQuery += " CAST(CTE_MOVCTE_Serie AS  CHAR) AS F2_SERIE,  "+CHR(13)
	cQuery += " CAST(CTE_MOVCTE_Numero AS  CHAR)AS F2_DOC,    "+CHR(13)
	cQuery += " CTE_MOVCTE_Emissao 		      AS F2_EMISSAO,"+CHR(13)
	cQuery += " CTE_MOVCTE_Chave 		      AS F2_CHVCONH,"+CHR(13)
	cQuery += " CTE_MOVCTE_BCICMS 		      AS F2_BASEICM,"+CHR(13)
	cQuery += " CTE_MOVCTE_AICMS 		      AS D2_PICM,   "+CHR(13)
	cQuery += " CTE_MOVCTE_ICMS 		  	  AS F2_VALICM, "+CHR(13)
	cQuery += " CTE_MOVCTE_ValorServico       AS F2_VALMERC,"+CHR(13) 
	cQuery += " STG_FRT_TABCAR_Tra_Codigo     AS F2_PLACA, "+CHR(13)
	cQuery += " CTE_MOVCTE_CanDataHora        AS DT_CANC, "+CHR(13)
	cQuery += " CAST(STG_CTE_TABPRJ_Cte_Codigo AS  CHAR)     AS F2_XPROJ, "+CHR(13)    
	cQuery += " CAST(STG_GEN_TABENT_CTe_Rem_Codigo AS  CHAR) AS REM_COD,   "+CHR(13)
	cQuery += " CAST(STG_GEN_ENDENT_CTe_Rem_Codigo AS  CHAR) AS REM_LOJA,  "+CHR(13)
	cQuery += " CAST(STG_GEN_TABENT_CTe_Des_Codigo AS  CHAR) AS DEST_COD,   "+CHR(13)
	cQuery += " CAST(STG_GEN_ENDENT_CTe_Des_Codigo AS  CHAR) AS DEST_LOJA,  "+CHR(13)//CAST(COM_NOTCOM_Numero AS  CHAR)
    cQuery += " CAST(STG_GEN_TABENT_CTe_Tom_Codigo AS  CHAR) AS TOMA_COD,  "+CHR(13)
	cQuery += " CAST(STG_GEN_ENDENT_CTe_Tom_Codigo AS  CHAR) AS TOMA_LOJA, "+CHR(13)
	cQuery += " CTE_MOVCTE_SituacaoCTe		  AS SITUA_CTE,  "+CHR(13) 
	cQuery += " CAST(STG_GEN_TABENT_CTe_Des_Codigo AS  CHAR) AS CODDEST, "+CHR(13) 
	cQuery += " CAST(STG_GEN_ENDENT_CTe_Des_Codigo AS  CHAR) AS LOJADEST, "+CHR(13) 
	cQuery += " CTE_MOVCTE_AliqPIS    AS F2_ALQIMP6,   "
	cQuery += "	CTE_MOVCTE_BasePIS    AS F2_BASIMP6, "        
	cQuery += " CTE_MOVCTE_ValorPIS   AS F2_VALIMP6, "
	cQuery += " CTE_MOVCTE_AliqCOFINS AS F2_ALQIMP5, "
	cQuery += " CTE_MOVCTE_BaseCOFINS  AS F2_BASIMP5,"
	cQuery += " CTE_TABPRO.CTE_TABPRO_NCM AS NCM, "
	cQuery += " CTE_MOVCTE_ValorCOFINS AS F2_VALIMP5, "
	cQuery += " CTE_MOVCTE_TipoComplemento AS TIPOCOM, "
	cQuery += " CTE_MOVCTE_NegocioTracao AS NEGOCIO  "
	//cQuery += " STG_GEN_NATOPE_CTe_Codigo, "
	//cQuery += " CTE_MOVCTE_ValorServico, "
	//cQuery += " CTE_MOVCTE_ValorReceber, "	
	cQuery += " FROM CTE_MOVCTE CTE_MOVCTE "+CHR(13)
   	//cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Des_Codigo "+CHR(13)  //AQUI
 	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Tom_Codigo "+CHR(13) 
   	//cQuery += " AND GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Des_Codigo  "+CHR(13) //AQUI
   	cQuery += " AND GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Tom_Codigo  "+CHR(13) 
   	cQuery += " INNER JOIN GEN_ENDENT REMETENTE ON REMETENTE.GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Rem_Codigo "
 	cQuery += " AND REMETENTE.GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Rem_Codigo "+chr(13)
 	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON STG_GEN_NATOPE_CTe_Codigo = GEN_NATOPE_Codigo  "+chr(13)
   	cQuery += " LEFT JOIN CTE_TABPRO CTE_TABPRO ON CTE_TABPRO.GEN_TABEMP_Codigo = CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo "+chr(13)
	cQuery += " AND CTE_TABPRO.CTE_TABPRO_ID = CTE_MOVCTE.STG_CTE_TABPRO_CTe_ID  "+chr(13)
     
   	//cQuery += " INNER JOIN CTE_QTDCAR QTDCAR ON"
   	//cQuery += " QTDCAR.STG_GEN_TABEMP_CTe_Codigo = CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo AND" 
	//cQuery += " QTDCAR.STG_GEN_TABFIL_CTe_Codigo = CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo AND"
	//cQuery += " QTDCAR.CTE_MOVCTE_ID             = CTE_MOVCTE.CTE_MOVCTE_ID             AND"
	//cQuery += " CTE_QTDCAR_Sequencia    		 = CTE_MOVCTE_SeqQtd"//PRODUTO PREDOMINANTE STG_CTE_TABPRO_CTe_ID     ""***VERIFICAR		
   	cQuery += " WHERE CTE_MOVCTE_DHIntTotvs IS NULL AND "+CHR(13)
	cQuery += "   CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo = " + cValToChar(nEmpOrigem)+""+CHR(13) 
	                                                             
	//Somente Cte´s com chave e cancelados ou trnasmitidos
	cQuery += " AND CTE_MOVCTE_Chave <> '' "  
   	cQuery += " AND (CTE_MOVCTE_SituacaoCTe =  4 OR CTE_MOVCTE_SituacaoCTe =  5)"  
   	//cQuery += " AND CTE_MOVCTE_SituacaoCTe =  5  "
	
	//Plano de testes - RETIRAR  
	//cQuery += "  AND STG_CTE_TABPRJ_Cte_Codigo = 2 "
	//cQuery += "  AND CTE_MOVCTE_Numero IN('31239')  AND CTE_MOVCTE_ChaveDocAnt <> ''


	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0  
		cQuery += " AND  CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo = " + cValToChar(nFilOrigem)
    Endif         
    cQuery += " LIMIT 100 " 
    U_AGX635CN("DBG")    
    //conout('AGX635CS - QUERY PRINCIPAL') 
	//conout(cquery)
  	If Select(cCapaCTS) <> 0
  		dbSelectArea(cCapaCTS)
   		(cCapaCTS)->(dbCloseArea())
  	Endif

 	TCQuery cQuery NEW ALIAS (cCapaCTS) 
 	
  	TCSETFIELD(cCapaCTS,"F2_VALMERC"   ,"N",14,2)   
 	TCSETFIELD(cCapaCTS,"F2_ALQIMP6"   ,"N",6,2) 
	TCSETFIELD(cCapaCTS,"F2_BASIMP6"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"F2_VALIMP6"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"F2_ALQIMP5"   ,"N",6,2) 
	TCSETFIELD(cCapaCTS,"F2_BASIMP5"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"F2_VALIMP5"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"F2_BASEICM"   ,"N",14,2) 

Return(cCapaCTS)


//Inserir Dados no Protheus
Static Function InserirCTS(cCapaCTS)

	Local lNovo    := .T.
	Local lRegOK   := .T. 
	Local cFil     := '' 
	Local cTipoCli := ""
	Local cEst     := "" 
	Local cTpFrete := ""
    	  
	U_AGX635CN("PRT") 
	
	(cCapaCTS)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cCapaCTS)->(!eof())
		   
		cProjeto := ""
		
		//Marca Projeto como Nyke  
		If Alltrim((cCapaCTS)->F2_XPROJ) == '2'
			cProjeto := "( NYKE )"
		Endif                
		            
		//conout('VALIDA NEGOCIO')
		//conout( Valtype( (cCapaCTS)->NEGOCIO )  ) 
		//conout( (cCapaCTS)->NEGOCIO )
				
		//Valida se Existe o Produto para o Negocio
		If Valtype( (cCapaCTS)->NEGOCIO ) == 'C'    
	    	If 	alltrim( (cCapaCTS)->NEGOCIO ) <> ''
	        	cCodPro := GetProdNeg( alltrim( (cCapaCTS)->NEGOCIO ), "" )
	        	If Alltrim(cCodPro) <> ""
		        	DbSelectarea('SB1')
		        	DbSetorder(1)
		        	If !DbSeek(xFilial('SB1') + cCodPro) 
		        			lRegOK := .F. 
											// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
							//GRAVA Array de LOG
			        		AADD(aLogs,{;
								 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
									{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
									{'ZDB_MSG'	  ,' PRODUTO DO NEGOCIO NAO CADASTRADO:'+(cCapaCTS)->NEGOCIO },;
									{'ZDB_DATA'	  ,ddatabase},;
									{'ZDB_HORA'	  ,time()},;
									{'ZDB_EMP'	  ,cEmpant},;
									{'ZDB_FILIAL' ,cFilAnt},;
									{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))+'+'+alltrim((cCapaCTS)->(DEST_COD))+'+'+alltrim((cCapaCTS)->(DEST_LOJA))},; 
									{'ZDB_TAB' 	  ,'SB1'},; 
									{'ZDB_INDICE' ,3},;  
									{'ZDB_TIPOWF' ,2},; 
									{'ZDB_CHAVE'  ,(cCapaCTS)->(REM_CNPJ)};
									})     
									  
						(cCapaCTS)->(dbskip()) 
						LOOP  
		        	Endif
	            Endif
	        Endif
	     Endif
		
		
		// Valida se o Remetente está Cadastrado 
		// Somente a Empresa 01 gera DT6, portanto 
		// apenas ela deve ser verificada
		If cEmpAnt == '01'
			SA1->(DbSetOrder(3))
			SA1->(DbGoTop())
			If !SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(REM_CNPJ)))
			
				//Inclui Cliente 
				U_AGX635CF((cCapaCTS)->(REM_CNPJ),'SA1')
				
				If alltrim(SA1->A1_CONTA) == ''  
					lRegOK := .F. 
										// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
					//GRAVA Array de LOG
		        	AADD(aLogs,{;
							 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
								{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
								{'ZDB_MSG'	  ,cProjeto + 'Cliente Sem Conta Cadastrada:'+(cCapaCTS)->(REM_CNPJ)},;
								{'ZDB_DATA'	  ,ddatabase},;
								{'ZDB_HORA'	  ,time()},;
								{'ZDB_EMP'	  ,cEmpant},;
								{'ZDB_FILIAL' ,cFilAnt},;
								{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))+'+'+alltrim((cCapaCTS)->(DEST_COD))+'+'+alltrim((cCapaCTS)->(DEST_LOJA))},; 
								{'ZDB_TAB' 	  ,'SA1'},; 
								{'ZDB_INDICE' ,3},;  
								{'ZDB_TIPOWF' ,2},; 
								{'ZDB_CHAVE'  ,(cCapaCTS)->(REM_CNPJ)};
								})     
								  
					(cCapaCTS)->(dbskip()) 
					LOOP  
				Endif
			Endif
		Endif
		
		SA1->(DbSetOrder(3))
		SA1->(DbGoTop())
		If !SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(CNPJ_CPF)))
			 
			//Inclui Cliente 
			U_AGX635CF((cCapaCTS)->(CNPJ_CPF),'SA1')
			
			lRegOK := .F. 
								// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
			If alltrim(SA1->A1_CONTA) == ''  
				//GRAVA Array de LOG
        		AADD(aLogs,{;
					 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
						{'ZDB_MSG'	  ,cProjeto + 'Cliente Sem Conta Cadastrada:'+(cCapaCTS)->(CNPJ_CPF)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))+'+'+alltrim((cCapaCTS)->(DEST_COD))+'+'+alltrim((cCapaCTS)->(DEST_LOJA))},; 
						{'ZDB_TAB' 	  ,'SA1'},; 
						{'ZDB_INDICE' ,3},;  
						{'ZDB_TIPOWF' ,2},; 
						{'ZDB_CHAVE'  ,(cCapaCTS)->(CNPJ_CPF)};
						})     
						  
				(cCapaCTS)->(dbskip()) 
				LOOP  
			Endif
		Else
	  		cEst     := SA1->A1_EST 
	  		cTipoCli := SA1->A1_TIPO 
		Endif    
		
		
		//Grava LOG de Conta e Retorna
		If alltrim(SA1->A1_CONTA) == '' .OR. alltrim(SA1->A1_CONTA) == '0'
			//GRAVA Array de LOG
        	AADD(aLogs,{;
				 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
					{'ZDB_MSG'	  ,cProjeto + 'Cliente Sem Conta Cadastrada:'+(cCapaCTS)->(CNPJ_CPF)},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))+'+'+alltrim((cCapaCTS)->(DEST_COD))+'+'+alltrim((cCapaCTS)->(DEST_LOJA))},; 
					{'ZDB_TAB' 	  ,'SA1'},; 
					{'ZDB_INDICE' ,3},; 
					{'ZDB_TIPOWF' ,2},;
					{'ZDB_CHAVE'  ,(cCapaCTS)->(CNPJ_CPF)};
					})     
				(cCapaCTS)->(dbskip()) 
			LOOP  
		Endif
		          		          
		aTam    := {}
		aTam    := TamSX3("F2_DOC")
		_cDoc   := PADL(alltrim((cCapaCTS)->(F2_DOC)),aTam[1],'0')
        
        aTam    := {}
		aTam    := TamSX3("F2_SERIE")	
        _cSerie := PADR(alltrim((cCapaCTS)->(F2_SERIE)),aTam[1],' ') 
        
        
        conout('CTE '+xfilial('SF2')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA)
		//Verifica se já existe no Protheus
		dbselectarea('SF2')
		dbsetorder(1)
		If dbseek(xfilial('SF2')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA) .AND. alltrim((cCapaCTS)->(TIPOCTE)) <> '2'
		  
		   //Se for Cancelado, Reprocessa e EXclui
	   	   If (cCapaCTS)->(SITUA_CTE) == 5    //AQUI  mudar pra 5
					//Reprocessa e EXclui 
					//ReprocSF2(SF2->F2_EMISSAO, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_FILIAL)   
					If ValExcTit(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_FILIAL)
			  	  		ExcluirSF2(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_FILIAL, (cCapaCTS)->DT_CANC) 
		   			Else
		     		
		     			//GRAVA Array de LOG
    	    			AADD(aLogs,{;
 							 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
			 					{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
								{'ZDB_MSG'	  ,cProjeto + 'Cancelamento CTE: Titulo ja Baixado ou em Fatura: '+_cDoc+'-'+_cSerie+'/('+SA1->A1_COD+'-'+SA1->A1_LOJA+')'},;
								{'ZDB_DATA'	  ,ddatabase},;
								{'ZDB_HORA'	  ,time()},;
								{'ZDB_EMP'	  ,cEmpant},;
								{'ZDB_FILIAL' ,cFilAnt},;
								{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))+'+'+alltrim((cCapaCTS)->(DEST_COD))+'+'+alltrim((cCapaCTS)->(DEST_LOJA))},; 
								{'ZDB_TAB' 	  ,'SF2'},; 
								{'ZDB_INDICE' ,1},; 
								{'ZDB_TIPOWF' ,9},;
								{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA};
							}) 
							(cCapaCTS)->(dbskip()) 
							LOOP     
 
		   			Endif
		   Else
	   	   									// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
		  		CONOUT('AGX635CS - CTE JA EXISTE '+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA)
			   
					//GRAVA Array de LOG
        		AADD(aLogs,{;
						 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
							{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
							{'ZDB_MSG'	  ,cProjeto + 'CTE ja Existe: '+_cDoc+'-'+_cSerie+'/('+SA1->A1_COD+'-'+SA1->A1_LOJA+')'},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,cEmpant},;
							{'ZDB_FILIAL' ,cFilAnt},;
							{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))+'+'+alltrim((cCapaCTS)->(DEST_COD))+'+'+alltrim((cCapaCTS)->(DEST_LOJA))},; 
							{'ZDB_TAB' 	  ,'SF2'},; 
							{'ZDB_INDICE' ,1},; 
							{'ZDB_TIPOWF' ,7},;
							{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA};
							})     
 
		 
	 		Endif 
	 		
	 		(cCapaCTS)->(dbskip()) 
			LOOP 
	 	
	 	Elseif alltrim((cCapaCTS)->(TIPOCTE)) == '2'
	 		
	 		dbselectarea('SF1')
			dbsetorder(1)
			If dbseek(xfilial('SF1')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA) 
			   If (cCapaCTS)->(SITUA_CTE) <> 5 
			   		
			   		AADD(aLogs,{;
						 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
					 		{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
							{'ZDB_MSG'	  ,cProjeto + 'CTE ja Existe: '+_cDoc+'-'+_cSerie+'/('+SA1->A1_COD+'-'+SA1->A1_LOJA+')'},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,cEmpant},;
							{'ZDB_FILIAL' ,cFilAnt},;
							{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))+'+'+alltrim((cCapaCTS)->(DEST_COD))+'+'+alltrim((cCapaCTS)->(DEST_LOJA))},; 
							{'ZDB_TAB' 	  ,'SF1'},; 
							{'ZDB_INDICE' ,1},; 
							{'ZDB_TIPOWF' ,7},;
							{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA};
							})  
			   
			   	 	(cCapaCTS)->(dbskip()) 
					LOOP 
				Else          
					ExcluiSD1()
			   Endif 
			Endif
	 	
	 	Endif
	 	          
	 	//Valida se é CIF ou FOB de acordo com o Tomador do Serviço            
	    
	    If (cCapaCTS)->(REM_COD) == (cCapaCTS)->(TOMA_COD) .AND.  (cCapaCTS)->(REM_LOJA) = (cCapaCTS)->(TOMA_LOJA)
	 		cTpFrete := "C"
	 	Else
	 		cTpFrete := "F"
	 	Endif
	 	 
	 	cTes := (cCapaCTS)->(D2_TES)             
	 	
	 	//Posiciona na TES
		dbselectarea('SF4')
		dbsetorder(1)
		If !(dbseek(xfilial('SF4')+alltrim(cTes)) .OR. alltrim(cTes) == '') .and. (cEmpAnt <> '50')
						   		// {'ZDB_EMP'              ,'ZDB_FIL'              ,'ZDB_MSG'          ,'ZDB_DATA','ZDB_HORA'}  
			If !lReproc
				/*AADD(aLogs,{;
				 	(cAliasPROD)->(DBEMP),;
				 	(cAliasPROD)->(DBFIL),;
				 	'TES invalida:'+alltrim((cAliasPROD)->(D1_TES)),;
				 	ddatabase,;
				 	time() ,;
				 	cEmpant,;
				 	cFilAnt,;
				 	(cAliasCapa)->(F1_DOC)+(cAliasCapa)->(F1_SERIE)+(cAliasCapa)->(DBFORN)}) */
				 		//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,cProjeto + 'Doc: '+SF2->F2_DOC+'-'+SF2->F2_SERIE+', TES invalida:'+alltrim((cCapaCTS)->(D2_TES))},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_INDICE' ,1},;
						{'ZDB_TAB'  ,'SF4'},;
						{'ZDB_TIPOWF' ,5},;   
						{'ZDB_DBCHAV' ,alltrim((cCapaCTS)->(F2_DOC))+'+'+alltrim((cCapaCTS)->(F2_SERIE))},; 
						{'ZDB_CHAVE'  ,cTes};
						})   	 
			Else
				Alert('TES invalida:'+alltrim((cAliasPROD)->(D2_TES)))
			Endif
			
			lRegOK := .F.	 	
			(cCapaCTS)->(dbskip()) 
			LOOP   
		Endif          
	 	                                                                                                                            
		cFil := xFilial('SF2') 
		cEspecie := "CTE"  

		conout('Inserindo CTE - '+_cDoc+' - '+time())
 		
 		//Somente inclui se não for um cancelamento  
	   	If	(cCapaCTS)->(SITUA_CTE) <> 5 
	   		
	   		//Quando For CTE de Anulação, deve ser realizada uma entrada
	   		If  alltrim((cCapaCTS)->(TIPOCTE)) <> '2'                   
				Begin Transaction 
			
					RecLock("SF2",.T.)
						SF2->F2_FILIAL  := cFil
						SF2->F2_DOC     := _cDoc
						SF2->F2_SERIE   := _cSerie
						SF2->F2_CLIENTE := SA1->A1_COD
						SF2->F2_LOJA    := SA1->A1_LOJA
						SF2->F2_COND    := "001"
						SF2->F2_DUPL    := _cDoc
						SF2->F2_EMISSAO := (cCapaCTS)->(F2_EMISSAO)//STOD(cDataEmis)
						SF2->F2_EST     := cEst
						SF2->F2_TIPOCLI := cTipoCli
						SF2->F2_VALBRUT := (cCapaCTS)->(F2_VALMERC)//MSF2->F2_VALFAT
						SF2->F2_VALICM  := (cCapaCTS)->(F2_VALICM)//nValIcms  //MSF2->F2_VALICM
						SF2->F2_BASEICM := (cCapaCTS)->(F2_BASEICM)//nBaseIcms //MSF2->F2_BASEICM
						SF2->F2_VALMERC := (cCapaCTS)->(F2_VALMERC)//MSF2->F2_VALFAT 
						SF2->F2_VALFAT  := (cCapaCTS)->(F2_VALMERC)
						If alltrim((cCapaCTS)->(TIPOCOM)) == 'I'
							SF2->F2_TIPO    := "I" 
						ElseIf alltrim((cCapaCTS)->(TIPOCOM )) == 'V'
							SF2->F2_TIPO    := "C" 
						Else
							SF2->F2_TIPO    := "N"  
						Endif
						SF2->F2_VOLUME1 := 1
						SF2->F2_PLIQUI  := 1
						SF2->F2_PBRUTO  := 1
						SF2->F2_ESPECIE := cEspecie
						SF2->F2_PREFIXO := cFil + substr(_cSerie,1,1)
						SF2->F2_MOEDA   := 1
						SF2->F2_RECFAUT := "1"
						SF2->F2_TPFRETE := cTpFrete
						SF2->F2_ORIIMP  := "AGX635CS"
						SF2->F2_CHVCONH := ALLTRIM(cValToChar((cCapaCTS)->(F2_CHVCONH))) 
						SF2->F2_BASIMP6 := (cCapaCTS)->(F2_BASIMP6)      
						SF2->F2_VALIMP6 := (cCapaCTS)->(F2_VALIMP6)
						SF2->F2_BASIMP5 := (cCapaCTS)->(F2_BASIMP5)
						SF2->F2_VALIMP5 := (cCapaCTS)->(F2_VALIMP5)
				   		SF2->F2_PLACA   := SUBSTR(alltrim((cCapaCTS)->F2_PLACA),1,3)+SUBSTR(alltrim((cCapaCTS)->F2_PLACA),5,4) 
				   		SF2->F2_XPROJ   := alltrim((cCapaCTS)->(F2_XPROJ))
					SF2->(MsUnLock())
		
					cCodPro := ""   
				    
				   //Chamado 68501 - Se for Nyke Grava produto 00120041N                          
			  	   If alltrim((cCapaCTS)->(F2_XPROJ)) == '2'
			  	   		cCodPro := "00120041N"
				   Else	
					   // Tratamento para produto == Gas Natural(00120040)
				  	   // Determinação do Alexandre		  	   
				  	   If !empty((cCapaCTS)->(NCM) )
				 	       If alltrim((cCapaCTS)->(NCM)) == '27112100' .and. cFil == '01' .and. cEmpant == '01'
			   		  	    	cCodPro := "00120040"
			   		 	   Else
			  		   	    	cCodPro := "00120041"
			  		  	   Endif
			  	   	   Else
			  	        	cCodPro := "00120041"
			  	       Endif		
	               Endif
	               
	        	   //Centrolog utiliza esse produto
	          	   if cEmpant == '50'
	          	  		cCodPro := "REC31110102"   
	           	   Endif     
	           	    
	           	   If Valtype( (cCapaCTS)->NEGOCIO ) == 'C'    
	           	   		If 	alltrim( (cCapaCTS)->NEGOCIO ) <> ''
	           	   			cCodPro := GetProdNeg( alltrim ( (cCapaCTS)->NEGOCIO ), cCodPro )
	           	        Endif
	           	   Endif
	           	   
		           Begin Transaction
		       	   		RecLock("SD2",.T.)			   
							SD2->D2_FILIAL  := cFil
							SD2->D2_ITEM    := "01"
							SD2->D2_COD     := cCodPro
							SD2->D2_UM      := "L"
							SD2->D2_QUANT   := 1
							SD2->D2_PRCVEN  := (cCapaCTS)->(F2_VALMERC)
				   		   	SD2->D2_TOTAL   := (cCapaCTS)->(F2_VALMERC)
				   	 		SD2->D2_VALICM  := (cCapaCTS)->(F2_VALICM) //MSF2->F2_VALIC
							SD2->D2_PICM    := (cCapaCTS)->D2_PICM//nPIcms   //MSF2->D2_ALIQICM
							SD2->D2_CONTA   := "112070003"
							SD2->D2_CLIENTE := SA1->A1_COD
							SD2->D2_LOJA    := SA1->A1_LOJA
							SD2->D2_LOCAL   := "01"
							SD2->D2_DOC     := _cDoc
							SD2->D2_EMISSAO := (cCapaCTS)->(F2_EMISSAO)
	//						SD2->D2_TP      := "N"
							SD2->D2_SERIE   := _cSerie
							SD2->D2_PRUNIT  := (cCapaCTS)->(F2_VALMERC)
							SD2->D2_EST     := cEst
							SD2->D2_TIPO    := SF2->F2_TIPO //"N"
							SD2->D2_BASEICM := (cCapaCTS)->(F2_BASEICM) //MSF2->F2_BASEICM
							SD2->D2_CLASFIS := "000"
							SD2->D2_VALBRUT := (cCapaCTS)->(F2_VALMERC)
							SD2->D2_ORIIMP  := "AGX635CS" 
						   
							//Regra para Empresa 50 Originada do Datatransp e conferida pela Vanderleia/Vanessa
							If cEmpAnt == '50'
								SD2->D2_TES     := '501' 
								If substr(alltrim((cCapaCTS)->(NATOPE)),1,4) == '6932' .or. substr(alltrim((cCapaCTS)->(NATOPE)),1,4) == '5932' 
								 	SD2->D2_TES     := '504'
								Endif
								dbselectarea('SF4')
								dbsetorder(1)
								dbseek(xfilial('SF4')+alltrim(SD2->D2_TES))				
								
							Else
								SD2->D2_TES     := SF4->F4_CODIGO 
							Endif          
						 
							// Tratamento para CF com destino Fora do Estado 
							// Deve iniciar com 6    
							cCFOP := SF4->F4_CF
							If (cCapaCTS)->(EST_INI) <> (cCapaCTS)->(EST_FIM)
								cCFOP := '6'+substr(alltrim(SF4->F4_CF),2,3) 
							Endif
						
							SD2->D2_CF      := cCFOP  
							SD2->D2_ALQIMP5 := (cCapaCTS)->(F2_ALQIMP5)
							SD2->D2_ALQIMP6 := (cCapaCTS)->(F2_ALQIMP6)
							SD2->D2_BASIMP5 := (cCapaCTS)->(F2_BASIMP5)
							SD2->D2_VALIMP5 := (cCapaCTS)->(F2_VALIMP5)
							SD2->D2_VALIMP6 := (cCapaCTS)->(F2_VALIMP6)
							SD2->D2_BASIMP6 := (cCapaCTS)->(F2_BASIMP6) 
							
							//Campos de fundo de combate a pobreza nfe 4.0 
							SD2->D2_BSFCCMP := 0 
							SD2->D2_FCPAUX  := 0 
							SD2->D2_BASFECP := 0 
							SD2->D2_BSFCPST := 0 
						
						SD2->(MsUnLock())		
			   		End Transaction
			
					ReprocSF2(SF2->F2_EMISSAO, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_FILIAL)
			  	 
				  	//Se NÃO for um CANCELAMENTO, Gera Financeiro 
			   		if (cCapaCTS)->(SITUA_CTE) <> 5 
						ProcCR((cCapaCTS)->(IDCTE))
					Endif
				
					//Destrava todas as conexões
			 		MsUnlockAll() 
				End Transaction  
		  	
		  	//Se FOR um CANCELAMENTO, Exclui Tabelas.
	  	   /*	If (cCapaCTS)->(SITUA_CTE) == 5 
				ExcluirSF2(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_FILIAL, (cCapaCTS)->DT_CANC)
		   	Endif*/     
		   	
		   //Quando for uma ANULAÇÃO	
		   Else  
		   		  
		   		_aNotaOri := {'','',''}// 'NF','ITEM','SERIE' 		   		
		   		_aNotaOri := BuscanfOri((cCapaCTS)->(CHAVEANT))

				Begin Transaction 
			
					RecLock("SF1",.T.)
						SF1->F1_FILIAL  := cFil
						SF1->F1_DOC     := _cDoc
						SF1->F1_SERIE   := _cSerie
						SF1->F1_FORNECE := SA1->A1_COD
						SF1->F1_LOJA    := SA1->A1_LOJA  
						SF1->F1_TIPO    := "D" 
						SF1->F1_ESPECIE := cEspecie
						SF1->F1_EMISSAO := (cCapaCTS)->(F2_EMISSAO)//STOD(cDataEmis)
						SF1->F1_DTDIGIT := (cCapaCTS)->(F2_EMISSAO)
						SF1->F1_RECBMTO := (cCapaCTS)->(F2_EMISSAO)   
						SF1->F1_EST     := cEst
						//SF1->F1_FRETE   := (cAliasCapa)->(F1_FRETE)
						//SF1->F1_DESPESA := (cAliasCapa)->(F1_DESPESA)  
						SF1->F1_BASEICM := (cCapaCTS)->(F2_BASEICM)//nBaseIcms //MSF1->F1_BASEICM
						SF1->F1_VALICM  := (cCapaCTS)->(F2_VALICM)//nValIcms  //MSF1->F1_VALICM
						SF1->F1_VALMERC := (cCapaCTS)->(F2_VALMERC)//MSF1->F1_VALFAT 
						SF1->F1_VALBRUT := (cCapaCTS)->(F2_VALMERC)//MSF1->F1_VALFAT
						//SF1->F1_DESCONT := (cAliasCapa)->(F1_DESCONT)	 
						//SF1->F1_BRICMS  := (cAliasCapa)->(F1_BRICMS)
						//SF1->F1_ICMSRET := (cAliasCapa)->(F1_ICMSRET)
						//SF1->F1_ICMS    := (cAliasCapa)->(F1_ICMS)
					 	//SF1->F1_SEGURO	:= (cAliasCapa)->(F1_SEGURO)
					 	SF1->F1_CHVCONH := ALLTRIM(cValToChar((cCapaCTS)->(F2_CHVCONH)))
					 	SF1->F1_ORIIMP  := "AGX635CS"  
					 	SF1->F1_PREFIXO :=  cFil + substr(alltrim(_cSerie),1,1)											
						SF1->F1_DUPL    := _cDoc 
						SF1->F1_STATUS  := "A" 						
						SF1->F1_COND    := "001"  
						
						//SF1->F1_BASEIPI := (cAliasCapa)->(F1_BASEIPI)
						//SF1->F1_VALIPI  := (cAliasCapa)->(F1_VALIPI) //ValOUTIPI outros IPI
						//SF1->F1_ISS 	:= (cAliasCapa)->(F1_ISS) 
						//PIS/COFINS APURAÇÃO
						SF1->F1_BASIMP6 := (cCapaCTS)->(F2_BASIMP6)      
						SF1->F1_VALIMP6 := (cCapaCTS)->(F2_VALIMP6)
						SF1->F1_BASIMP5 := (cCapaCTS)->(F2_BASIMP5)
						SF1->F1_VALIMP5 := (cCapaCTS)->(F2_VALIMP5)
						//SF1->F1_VALCSLL := (cAliasCapa)->(F1_VALCSLL)
						//SF1->F1_VALIRF  := (cAliasCapa)->(F1_VALIRF)
						//SF1->F1_INSS 	:= (cAliasCapa)->(F1_INSS)

					SF1->(MsUnLock())
		
					cCodPro := ""   
				    
				   //Chamado 68501 - Se for Nyke Grava produto 00120041N                          
			  	   If alltrim((cCapaCTS)->(F2_XPROJ)) == '2'
			  	   		cCodPro := "00120041N"
				   Else	
					   // Tratamento para produto == Gas Natural(00120040)
				  	   // Determinação do Alexandre		  	   
				  	   If !empty((cCapaCTS)->(NCM) )
				 	       If alltrim((cCapaCTS)->(NCM)) == '27112100' .and. cFil == '01' .and. cEmpant == '01'
			   		  	    	cCodPro := "00120040"
			   		 	   Else
			  		   	    	cCodPro := "00120041"
			  		  	   Endif
			  	   	   Else
			  	        	cCodPro := "00120041"
			  	       Endif		
	               Endif
	               
	        	   //Centrolog utiliza esse produto
	          	   if cEmpant == '50'
	          	  		cCodPro := "REC31110102"   
	           	   Endif 
	           	   
	           	   dbselectarea('SB1')
	           	   dbsetorder(1)
	           	   dbSeek(xfilial('SB1')+cCodPro)
	           	   
		           Begin Transaction
		       	   		RecLock("SD1",.T.)			   
							SD1->D1_FILIAL  := cFil  
							SD1->D1_COD     := cCodPro
							SD1->D1_UM      := "L" 
							SD1->D1_LOCAL   := "01"
							SD1->D1_ITEM    := "0001"
			   				SD1->D1_RATEIO  := "2"   
			   				if !(alltrim(cEmpant) $ '50/03')//alltrim(cEmpant) <> '50'
								SD1->D1_DESCRI  := SB1->B1_DESC
							Endif
			   				SD1->D1_QUANT   := 1
			   				SD1->D1_VUNIT   := (cCapaCTS)->(F2_VALMERC)
			   				SD1->D1_TOTAL   := (cCapaCTS)->(F2_VALMERC)
			   				SD1->D1_VALICM  := (cCapaCTS)->(F2_VALICM) //MSF2->F2_VALIC
							SD1->D1_PICM    := (cCapaCTS)->D2_PICM//nPIcms   //MSF2->D2_ALIQICM                                           
			   				SD1->D1_FORNECE := SF1->F1_FORNECE
							SD1->D1_LOJA    := SF1->F1_LOJA
			   				SD1->D1_DOC     := _cDoc 
			   				SD1->D1_EMISSAO := (cCapaCTS)->(F2_EMISSAO)
			   				SD1->D1_DTDIGIT := (cCapaCTS)->(F2_EMISSAO)
							SD1->D1_SERIE   := SF1->F1_SERIE			   				
			   				//SD1->D1_ICMSRET := (cAliasPROD)->(D1_ICMSRET)//MSD1->D1_ICMSRET
							SD1->D1_BASEICM := (cCapaCTS)->(F2_BASEICM) //MSF2->F2_BASEICM
			   				SD1->D1_TIPO    := "D"
							SD1->D1_ORIIMP  := "AGX635CS"  
							SD1->D1_TES     := SF4->F4_CODIGO
							// Tratamento para CF com destino Fora do Estado 
							// Deve iniciar com 6    
							cCFOP := SF4->F4_CF
							If (cCapaCTS)->(EST_INI) <> (cCapaCTS)->(EST_FIM)
								cCFOP := '2'+substr(alltrim(SF4->F4_CF),2,3) 
							Endif						
							SD1->D1_CF      := cCFOP 
							SD1->D1_CONTA   := "112070003" 	
							SD1->D1_ALQIMP5 := (cCapaCTS)->(F2_ALQIMP5)
							SD1->D1_ALQIMP6 := (cCapaCTS)->(F2_ALQIMP6)
							SD1->D1_BASIMP5 := (cCapaCTS)->(F2_BASIMP5)
							SD1->D1_VALIMP5 := (cCapaCTS)->(F2_VALIMP5)
							SD1->D1_VALIMP6 := (cCapaCTS)->(F2_VALIMP6)
							SD1->D1_BASIMP6 := (cCapaCTS)->(F2_BASIMP6)  
							
							//Dados da nota de Origem    
							IF Len(_aNotaOri) > 0 
								SD1->D1_NFORI   := _aNotaOri[1]
								SD1->D1_ITEMORI := _aNotaOri[2]
								SD1->D1_SERIORI := _aNotaOri[3] 
								SD1->D1_FILORI  := _aNotaOri[4]
							Endif
							//Campos de IPI
							//SD1->D1_VALIPI 	:= (cAliasPROD)->(D1_VALIPI) 
		   					//SD1->D1_BASEIPI := (cAliasPROD)->(D1_BASEIPI) 
							//SD1->D1_IPI 	:= (cAliasPROD)->(D1_IPI) //ALIQUOTA LEMBRAR  	
			   									   				
							//Campos NFE 4.0 
							SD1->D1_BFCPANT := 0 
							SD1->D1_BSFCCMP := 0  
							SD1->D1_FCPAUX  := 0 
							SD1->D1_BASFECP := 0 
							SD1->D1_BSFCPST := 0 
						
						SD1->(MsUnLock())		
			   		End Transaction
			
					ReprocSF1(SF1->F1_EMISSAO, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_FILIAL)
			  	 
				  	//Se NÃO for um CANCELAMENTO, Gera Financeiro 
			   		if (cCapaCTS)->(SITUA_CTE) <> 5 
						ProcANULA((cCapaCTS)->(IDCTE))
					Endif
				
					//Destrava todas as conexões
			 		MsUnlockAll() 
				End Transaction     
		   
		   Endif
	    Endif
    
    	AADD(aIntCAPA,{(cCapaCTS)->DBEMP, (cCapaCTS)->DBFIL, (cCapaCTS)->IDCTE  })
          
		(cCapaCTS)->(dbskip())  
	Enddo	                         
	//CONOUT('AGX635CS - Antes LOG')
    // MARCA DATA/HORA PARA IDENTIFICAR QUE REGISTRO FOI IMPORTADOS 
    If Len(aIntCAPA) > 0 
		BaixarCTS(aIntCAPA)
		aIntCAPA := {} 
    Endif            
    CONOUT('AGX635CS - Fim')
Return()

 
//Cria Arquivo de trabalho
Static Function CriaArqCS(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectCTS(nEmpOrigem,nFilOrigem)

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
	Enddo

   	//RPCClearEnv()

Return(cArqTmp)            


//Grava Data/hora da Importação
Static Function BaixarCTS(xIntCapa)

	Local cCTSIN   := ""    
	Local nQtdeIN  := 0

	U_AGX635CN("DBG") 

    For i := 1 to len(xIntCapa)
        
       //Monta Clausula Where do documento 
        If nQtdeIN == 0
       		 cCTSIN := " AND (" 
       	Else
      		 cCTSIN += " ) OR ("  	
        Endif  
        
        cCTSIN += " STG_GEN_TABEMP_CTe_Codigo 	  =  "+alltrim(str(xIntCapa[i][1]))+""
		cCTSIN += " AND STG_GEN_TABFIL_CTe_Codigo =  "+alltrim(str(xIntCapa[i][2]))+""
		cCTSIN += " AND CTE_MOVCTE_ID		  =  "+alltrim(str(xIntCapa[i][3]))+""

		nQtdeIN += 1

		If (nQtdeIN >= 10) .Or. len(xIntCapa) == i 
			
			cCTSIN += ") " 
			
			UpdateCTS(cCTSIN)

			nQtdeIN := 0
			cCTSIN := ""
			
		EndIf 
		
	Next i 

Return()
              

//Atualiza campo de importação do DBGint
Static Function UpdateCTS(cCTSIN)

	Local cQuery   := ""
    
	//Atualiza CAPA
	cQuery += " UPDATE CTE_MOVCTE SET "
	cQuery += " CTE_MOVCTE_DHIntTotvs = current_timestamp() "
	cQuery += " WHERE CTE_MOVCTE_DHIntTotvs IS NULL "
	cQuery += cCTSIN

	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao executar SQL: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf   
		           
Return()       
                 

//  Contas a Receber 
Static Function ProcCR(xIDCTS)  

	Local lRet      := .F.
	Local _aCabec   := {}
	Local cPrefixo  := "" 	
	Local cAliasSE1 := "AGX635SE1F"
	Local cQuery     := "" 
	Local lRegOK     := .T.  
	Local lGerouReg  := .F. 
	Local aBaixa 	 := {}   
	    
	cQuery := " SELECT  "	
	cQuery += "	STG_GEN_TABEMP_CTe_Codigo AS DBEMP, "  
	cQuery += " STG_GEN_TABFIL_CTe_Codigo AS DBFIL, "
	cQuery += " CTE_MOVCTE_ID             AS ID_CTE, "
	cQuery += " CTE_FINCTE_Parcela        AS E1_PARCELA,"
	cQuery += " CXB_TABBAN_Codigo         AS E1_BANCO, "
	cQuery += " CTE_FINCTE_Valor 	      AS E1_VALOR, "
	cQuery += " CTE_FINCTE_Vencimento     AS E1_VENCTO "
	//cQuery += "CTE_FINCTE_Created
	//cQuery += "CTE_FINCTE_Updated  
	cQuery += "FROM CTE_FINCTE "
	cQuery += "WHERE " 
	cQuery += " STG_GEN_TABEMP_CTe_Codigo  		   = '"+alltrim(str((cCapaCTS)->DBEMP))+"' "+chr(13)
	cQuery += " AND STG_GEN_TABFIL_CTe_Codigo  = '"+alltrim(str((cCapaCTS)->DBFIL))+"' "+chr(13)  
	cQuery += " AND CTE_MOVCTE_ID			   = '"+alltrim(str(xIDCTS))+"' "  
	 
	//CONOUT(cQuery)
	//CONOUT('*** ID CTE ***')
	//CONOUT(xIDCTS)
  
	U_AGX635CN("DBG")    
	
	If Select(cAliasSE1) <> 0
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAliasSE1)  
	        
	cFil := cFilant//STRZERO((cAliasSE1)->DBEMP,2) 
   
	U_AGX635CN("PRT")       
		
	//** Adequa Campo Doc e Serie         
	aTam    := {};aTam    := TamSX3("F2_DOC");     _cDoc   := PADL(alltrim((cCapaCTS)->(F2_DOC)),aTam[1],'0')     
    aTam    := {};aTam    := TamSX3("F2_SERIE")	;  _cSerie := PADR(alltrim((cCapaCTS)->(F2_SERIE)),aTam[1],' ') 
    
    //Posiciona CLIENTE
   	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(CNPJ_CPF)))
     
    //Posiciona no Documento    
    dbselectarea('SF2')
	SF2->(dbsetorder(1));SF2->(DbGoTop())
	SF2->(dbseek(xfilial('SF2')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA)) 
    
    CONOUT('*TIT* SF2: '+_cDoc+'-'+_cSerie+'-'+SA1->A1_COD+SA1->A1_LOJA)          
    lTitBaixad := .F.                                                                                             

	//Verifica se Existe Título Gerado  
    lTitBaixad := VerifTit(xfilial('SE1'),SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_PREFIXO,SF2->F2_DOC,SF2->F2_TIPO )// (X_FILIAL,X_CLIENTE,X_LOJA,X_PREFIXO,X_NUM,X_TIPO)
	
	/*dbselectarea('SE1')
    SE1->(dbsetorder(2))  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
    If SE1->(!dbseek(xfilial('SE1')+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC+SF2->F2_TIPO))       
    	If SE1->(dbseek(xfilial('SE1')+SF2->F2_CLIENTE+SF2->F2_LOJA+cFilAnt+substr(alltrim(SF2->F2_SERIE),1,1)+SF2->F2_DOC))        
          	If Empty(SE1->E1_BAIXA)
          		Reclock('SE1',.F.)
          			dbdelete()
          		SE1->(Msunlock()) 
          	Else
          		lTitBaixad := .T.
          	Endif
    	Endif  
    Else
    	If Empty(SE1->E1_BAIXA)
     		Reclock('SE1',.F.)
       			dbdelete()
       		Msunlock() 
        Else
       		lTitBaixad := .T.
       	Endif		
    Endif   
    */            
    
    //Se Título já foi baixado
    If lTitBaixad
			 
		//GRAVA Array de LOG
    	AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,	'CTE com Tit.Baixado ou n Originario do DBGINT: '+SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie},; 
			{'ZDB_TAB' 	  ,'SE1'},; 
			{'ZDB_INDICE' ,1	},; 
			{'ZDB_TIPOWF' ,4},;
			{'ZDB_CHAVE'  , SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM};
			})  
		Return .F.   
    Endif
	
	DbSelectArea(cAliasSE1)
	(cAliasSE1)->(dbGotop())
	While (cAliasSE1)->(!eof())

		aTam     := {}
		aTam     := TamSX3("E1_NUM")
		cTitulo  := ""
		cTitulo  := SF2->F2_DOC//StrZero(MSE1->E1_NUM,aTam[1])
		cSerie   := ""
		cSerie   := substr(alltrim(SF2->F2_SERIE),1,3)        
		cForCod	 := SF2->F2_CLIENTE
		cForLoja := SF2->F2_LOJA
		cForNome := POSICIONE('SA1',1,xfilial('SA1')+cForCod+cForLoja,'A1_NOME')

		cFilEnt  := SF2->F2_FILIAL
		cPrefixo := ""
		cPrefixo := cFilEnt + substr(cSerie,1,1)
		cParcela := alltrim(cValToChar((cAliasSE1)->E1_PARCELA)) //StrZero(MSE1->E1_PARCELA,3) 
		
		dEmissao := SF2->F2_EMISSAO
		dVencto  := (cAliasSE1)->E1_VENCTO
		dDtDigit := SF2->F2_EMISSAO
        
   	    dbselectarea('SE1')
  	    dbsetorder(2)  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
    	//If !dbseek(xfilial('SE1')+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC+SF2->F2_TIPO)   
            CONOUT('*TIT* TITULO: '+cPrefixo+'-'+cTitulo+'-'+cParcela)
	   		Begin Transaction 
				RecLock("SE1",.T.)
					SE1->E1_PREFIXO		:= cPrefixo
					SE1->E1_NUM			:= cTitulo
					SE1->E1_PARCELA  	:= cParcela
					SE1->E1_CLIENTE		:= cForCod
					SE1->E1_LOJA		:= cForLoja
					SE1->E1_NOMCLI		:= cForNome
					SE1->E1_EMISSAO  	:= dEmissao
					SE1->E1_VENCTO 		:= dVencto
					SE1->E1_VENCREA		:= dVencto
					SE1->E1_VALOR		:= (cAliasSE1)->E1_VALOR
					SE1->E1_EMIS1 		:= dDtDigit//STOD(cAliasSE1)->E1_EMIS1)
					SE1->E1_HIST		:= "AGX635CS"
					SE1->E1_LA			:= ""
					SE1->E1_SALDO		:= (cAliasSE1)->E1_VALOR
					SE1->E1_VALLIQ		:= (cAliasSE1)->E1_VALOR
					SE1->E1_VENCORI		:= dVencto
					SE1->E1_MOEDA		:= 1
					SE1->E1_VLCRUZ		:= (cAliasSE1)->E1_VALOR
					SE1->E1_ORIGEM		:= "MATA460"
					SE1->E1_TIPO 		:= "NF"
					SE1->E1_NATUREZ  	:= "101010" //Chamado 67848 - Alterada natureza pois estava gerando IR "101009"  // "101011"
					SE1->E1_LA 			:= 'S'
					SE1->E1_SITUACA 	:= '0'
	   				SE1->E1_STATUS 		:= 'A'
					SE1->E1_FILORIG		:= cFilEnt 
					SE1->E1_FILIAL		:= xfilial('SE1')
				SE1->(MsUnLock())
        	End Transaction 
        	
        	
			If dEmissao == dVencto// dDtDigit == dVencto    //Realizo baixa automatica se o titulo for a vista.
				lRet    := .F.    
				aBaixa := {}
 				aBaixa := {{"E1_PREFIXO"  ,cPrefixo               ,Nil    },;
          			   {"E1_NUM"      ,cTitulo                ,Nil    },;
			           {"E1_TIPO"     ,"NF "                  ,Nil    },;
			           {"AUTMOTBX"    ,"NOR"                  ,Nil    },;
			           {"AUTBANCO"    ,"CX1"                  ,Nil    },;
			           {"AUTAGENCIA"  ,"00001"                ,Nil    },;
			           {"AUTCONTA"    ,"0000000001"           ,Nil    },;
			           {"AUTDTBAIXA"  ,dDtDigit               ,Nil    },;
			           {"AUTDTCREDITO",dDtDigit               ,Nil    },;
			           {"AUTHIST"     ,'Baixa Automatica'     ,Nil    },;
			           {"AUTJUROS"    ,0                      ,Nil,.T.},;
			           {"AUTVALREC"   ,700                    ,Nil    }}
 
		 		dbSelectArea("SE1")
				SE1->(dbSetOrder(1))
				SE1->(dbGoTop())
				If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cTitulo + cParcela + "NF " ))
			  
					lMsErroAuto := .F.
				//Begin Transaction
					MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 
					IF lMsErroAuto
						MOSTRAERRO()
				   //	DisarmTransaction()
				   //	Break
					Else
						//SUCESSO
					lRet := .T.
				Endif
		  		//	End Transaction

					If lRet
						cQuery := " UPDATE " + RETSQLNAME("SE5")
						cQuery += " SET E5_BANCO = 'CX1', E5_AGENCIA = '00001', E5_CONTA = '0000000001' "
						cQuery += " WHERE E5_PREFIXO = '"  +  cPrefixo        + "' "
						cQuery += "   AND E5_NUMERO     = '"  +  cTitulo        + "' "
						cQuery += "   AND E5_DATA = '"  +  dDtDigit + "' "
						cQuery += "   AND E5_CLIFOR = '"  +  cForCod        + "' "
						cQuery += "   AND E5_LOJA    = '"  +  cForLoja      + "' "
						cQuery += "   AND D_E_L_E_T_ <> '*' "
						cQuery += "   AND E5_PARCELA = '" + alltrim(cParcela) + "' "
	
					TcSqlExec(cQuery)
					EndIf
	       	     Endif
			/* 
			// Projeto Nyke, realiza o Envio do Boleto
			// foi Retirado, pois execuções por Job não gera arquivos fisicos, 
			// rotina colocada em schedule XAG0031
			Else      
			    //Se for Projeto Nyke, faz o Envio do Boleto
			    If alltrim(SF2->F2_XPROJ) == '2' .and. dDatabase < dVencto  		    
					conout('ENTROU') 
   					//Busca E-mail para envio de Boleto do Projeto NYKE
					cMailNyke := EMailNyke((cCapaCTS)->DBEMP,(cCapaCTS)->TOMA_COD,(cCapaCTS)->TOMA_LOJA)//xCodEmp,xEntDes,xEndDes)      
		       
			        //XAG0031(xEmp   ,xFil          ,xDoc       ,xSerie       ,xCliente       ,xLoja       ,xMail                 ,xFrom)   
      				U_XAG0031(cEmpAnt,;       				//xEmp
      	                      SF2->F2_FILIAL,; 				//xFil
      	                      SF2->F2_DOC,;    				//xDoc
      	                      SF2->F2_SERIE,;  				//xSerie
      	                      SF2->F2_CLIENTE,;				//xCliente
      	                      SF2->F2_LOJA,;  			    //xLoja
      	                      cMailNyke  ,;    				//xMail //'leandrohey@gmail.com'
      	                      'frete.nyke@agricopel.com.br')//xFrom
				Endif  */
	
			EndIf
        //Endif
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbskip())
	EndDo

Return()  

//Insere Título NCC
Static Function ProcANULA(xIDCTS)  

	Local lRet      := .F.
	Local _aCabec   := {}
	Local cPrefixo  := "" 	
	Local cAliasSE1 := "AGX635SE1F"
	Local cQuery     := "" 
	Local lRegOK     := .T.  
	Local lGerouReg  := .F. 
	Local aBaixa 	 := {}   
	    
	cQuery := " SELECT  "	
	cQuery += "	STG_GEN_TABEMP_CTe_Codigo AS DBEMP, "  
	cQuery += " STG_GEN_TABFIL_CTe_Codigo AS DBFIL, "
	cQuery += " CTE_MOVCTE_ID             AS ID_CTE, "
	cQuery += " CTE_FINCTE_Parcela        AS E1_PARCELA,"
	cQuery += " CXB_TABBAN_Codigo         AS E1_BANCO, "
	cQuery += " CTE_FINCTE_Valor 	      AS E1_VALOR, "
	cQuery += " CTE_FINCTE_Vencimento     AS E1_VENCTO "
	//cQuery += "CTE_FINCTE_Created
	//cQuery += "CTE_FINCTE_Updated  
	cQuery += "FROM CTE_FINCTE "
	cQuery += "WHERE " 
	cQuery += " STG_GEN_TABEMP_CTe_Codigo  	   = '"+alltrim(str((cCapaCTS)->DBEMP))+"' "+chr(13)
	cQuery += " AND STG_GEN_TABFIL_CTe_Codigo  = '"+alltrim(str((cCapaCTS)->DBFIL))+"' "+chr(13)  
	cQuery += " AND CTE_MOVCTE_ID			   = '"+alltrim(str(xIDCTS))+"' "  
	 
	//CONOUT(cQuery)
	//CONOUT('*** ID CTE ***')
	//CONOUT(xIDCTS)
  
	U_AGX635CN("DBG")    
	
	If Select(cAliasSE1) <> 0
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAliasSE1)  
	        
	cFil := cFilant//STRZERO((cAliasSE1)->DBEMP,2) 
   
	U_AGX635CN("PRT")       
		
	//** Adequa Campo Doc e Serie         
	aTam    := {};aTam    := TamSX3("F2_DOC");     _cDoc   := PADL(alltrim((cCapaCTS)->(F2_DOC)),aTam[1],'0')     
    aTam    := {};aTam    := TamSX3("F2_SERIE")	;  _cSerie := PADR(alltrim((cCapaCTS)->(F2_SERIE)),aTam[1],' ') 
    
    //Posiciona CLIENTE
   	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(CNPJ_CPF)))
     
    //Posiciona no Documento    
    dbselectarea('SF1')
	SF1->(dbsetorder(1));SF1->(DbGoTop())
	SF1->(dbseek(xfilial('SF1')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA)) 
    
     CONOUT('*TIT* SF2: '+_cDoc+'-'+_cSerie+'-'+SA1->A1_COD+SA1->A1_LOJA)          
     lTitBaixad := .F.                                                                                             
	
	//Verifica se Existe Título Gerado
    lTitBaixad := VerifTit(xfilial('SE1'),SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_PREFIXO,SF1->F1_DOC,'NCC' )// (X_FILIAL,X_CLIENTE,X_LOJA,X_PREFIXO,X_NUM,X_TIPO)
    
    //Se Título já foi baixado
    If lTitBaixad
			 
		//GRAVA Array de LOG
    	AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,	'CTE com Tit.Baixado ou n Originario do DBGINT: '+SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie},; 
			{'ZDB_TAB' 	  ,'SE1'},; 
			{'ZDB_INDICE' ,1	},; 
			{'ZDB_TIPOWF' ,4},;
			{'ZDB_CHAVE'  , SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM};
			})  
		Return .F.   
    Endif
	
	DbSelectArea(cAliasSE1)
	(cAliasSE1)->(dbGotop())
	While (cAliasSE1)->(!eof())

		aTam     := {}
		aTam     := TamSX3("E1_NUM")
		cTitulo  := ""
		cTitulo  := SF1->F1_DOC//StrZero(MSE1->E1_NUM,aTam[1])
		cSerie   := ""
		cSerie   := substr(alltrim(SF1->F1_SERIE),1,3)        
		cForCod	 := SF1->F1_FORNECE
		cForLoja := SF1->F1_LOJA
		cForNome := POSICIONE('SA1',1,xfilial('SA1')+cForCod+cForLoja,'A1_NOME')

		cFilEnt  := SF1->F1_FILIAL
		cPrefixo := ""
		cPrefixo := cFilEnt + substr(cSerie,1,1)
		cParcela := alltrim(cValToChar((cAliasSE1)->E1_PARCELA)) //StrZero(MSE1->E1_PARCELA,3) 
		
		dEmissao := SF1->F1_EMISSAO
		dVencto  := (cAliasSE1)->E1_VENCTO
		dDtDigit := SF1->F1_DTDIGIT
        
   	    dbselectarea('SE1')
  	    dbsetorder(2)  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
    	//If !dbseek(xfilial('SE1')+SF1->F1_FORNECEE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC)   
        CONOUT('*TIT* TITULO: '+cPrefixo+'-'+cTitulo+'-'+cParcela)
	   	Begin Transaction 
			RecLock("SE1",.T.)
				SE1->E1_PREFIXO		:= cPrefixo
				SE1->E1_NUM			:= cTitulo
				SE1->E1_PARCELA  	:= cParcela
				SE1->E1_CLIENTE		:= cForCod
				SE1->E1_LOJA		:= cForLoja
				SE1->E1_NOMCLI		:= cForNome
				SE1->E1_EMISSAO  	:= dEmissao
				SE1->E1_VENCTO 		:= dVencto
				SE1->E1_VENCREA		:= dVencto
				SE1->E1_VALOR		:= (cAliasSE1)->E1_VALOR
				SE1->E1_EMIS1 		:= dDtDigit//STOD(cAliasSE1)->E1_EMIS1)
				SE1->E1_HIST		:= "AGX635CS"
				SE1->E1_LA			:= ""
				SE1->E1_SALDO		:= (cAliasSE1)->E1_VALOR
				SE1->E1_VALLIQ		:= (cAliasSE1)->E1_VALOR
				SE1->E1_VENCORI		:= dVencto
				SE1->E1_MOEDA		:= 1
				SE1->E1_VLCRUZ		:= (cAliasSE1)->E1_VALOR
				SE1->E1_ORIGEM		:= "MATA460"
				SE1->E1_TIPO 		:= "NCC"
				SE1->E1_NATUREZ  	:= "101010" //Chamado 67848 - Alterada natureza pois estava gerando IR "101009"  // "101011"
				SE1->E1_LA 			:= 'S'
				SE1->E1_SITUACA 	:= '0'
	   			SE1->E1_STATUS 		:= 'A'
				SE1->E1_FILORIG		:= cFilEnt 
				SE1->E1_FILIAL		:= xfilial('SE1')
			SE1->(MsUnLock())
   		End Transaction 
        	
        //Endif
        
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbskip())
	EndDo

Return()
                

//Executa Rotina de Reprocessamento
Static Function ReprocSF2(dData, cNrDoc, cSerieDoc, cClieForn, cLojaCli, cNrFil)

	Local aPerg930  := {}
	Local nRegSM0   := 0
	Local aSegSM0   := SM0->(GetArea())
	Local lOutraFil := .F.         
	
//	CONOUT('Reprocessando Nota '+cNrDoc+'-'+cSerieDoc+'/'+cClieForn+'-'+cLojaCli+'-'+cNrFil)

	If (AllTrim(cNrFil) <> AllTrim(cFilAnt))
		dbSelectArea("SM0")
		nRegSM0 := RecNo()
		cFilAnt := cNrFil

		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt,.T.)

		lOutraFil := .T.
	EndIf

	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, 2)

	aAdd(aPerg930, cNrDoc)
	aAdd(aPerg930, cNrDoc)

	aAdd(aPerg930, cSerieDoc)
	aAdd(aPerg930, cSerieDoc)

	aAdd(aPerg930, cClieForn)
	aAdd(aPerg930, cClieForn)

	aAdd(aPerg930, cLojaCli)
	aAdd(aPerg930, cLojaCli)

	MSExecAuto({|x,y|MATA930(x,y)}, .T., aPerg930)

	If (lOutraFil)
		dbSelectArea("SM0")
		dbGoTo(nRegSM0)
		cFilAnt := SM0->M0_CODFIL
		RestArea(aSegSM0)
	EndIf
Return()  
  

//Executa Rotina de Reprocessamento
Static Function ReprocSF1(dData, cNrDoc, cSerieDoc, cClieForn, cLojaCli, cNrFil)

	Local aPerg930  := {}
	Local nRegSM0   := 0
	Local aSegSM0   := SM0->(GetArea())
	Local lOutraFil := .F.         
	
	CONOUT('Reprocessando Nota '+cNrDoc+'-'+cSerieDoc+'/'+cClieForn+'-'+cLojaCli+'-'+cNrFil)

	If (AllTrim(cNrFil) <> AllTrim(cFilAnt))
		dbSelectArea("SM0")
		nRegSM0 := RecNo()
		cFilAnt := cNrFil

		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt,.T.)

		lOutraFil := .T.
	EndIf

	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, 1)

	aAdd(aPerg930, cNrDoc)
	aAdd(aPerg930, cNrDoc)

	aAdd(aPerg930, cSerieDoc)
	aAdd(aPerg930, cSerieDoc)

	aAdd(aPerg930, cClieForn)
	aAdd(aPerg930, cClieForn)

	aAdd(aPerg930, cLojaCli)
	aAdd(aPerg930, cLojaCli)

	MSExecAuto({|x,y|MATA930(x,y)}, .T., aPerg930) 

	If (lOutraFil)
		dbSelectArea("SM0")
		dbGoTo(nRegSM0)
		cFilAnt := SM0->M0_CODFIL
		RestArea(aSegSM0)
	EndIf
Return()       


//Exclui SF2    
Static Function ExcluirSF2(cNrDoc, cSerieDoc, cClieForn, cLoja, cNrFilial, cDtCanc)

	Local cQuery := ""
     
	CONOUT('** Excluindo Nota '+cNrDoc+'-'+cSerieDoc+'/'+cClieForn+'-'+cLoja+'-'+cNrFilial)
	//CONOUT(SF2->(RECNO()))
	//cDtCanc := STRTRAN(cDtCanc, "-", "") 
	//	CONOUT(VALTYPE(cDtCanc))
	cDtCanc := DTOS(cDtCanc)
  	//  CONOUT(cDtCanc)
    // CONOUT(VALTYPE(cDtCanc))   
    
	cQuery := " UPDATE " + RETSQLNAME("SF2") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += "  WHERE F2_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND F2_DOC      = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND F2_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND F2_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND F2_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	cQuery += "    AND F2_TIPO     = 'N'   "
	cQuery += "    AND F2_ESPECIE  = 'CTE' "
	cQuery += "    AND D_E_L_E_T_  <> '*'  "
   //	CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF2: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf  
	

	cQuery := " UPDATE " + RETSQLNAME("SD2") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += "  WHERE D2_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND D2_DOC      = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND D2_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND D2_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND D2_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	//cQuery += "    AND D2_TP       = 'N' "
	cQuery += "    AND D_E_L_E_T_ <> '*' "
	//CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SD2: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf  

	cQuery := " UPDATE " + RETSQLNAME("SE1") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += "  WHERE E1_FILORIG  = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND E1_NUM      = '" + ALLTRIM(cNrDoc)    + "' "
    //cQuery += "    AND E1_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
    cQuery += "    AND E1_PREFIXO    = '" + ALLTRIM(cNrFilial)+SUBSTR(ALLTRIM(cSerieDoc),1,1) + "' "
	cQuery += "    AND E1_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND E1_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	cQuery += "    AND E1_TIPO     = 'NF' "
	cQuery += "    AND D_E_L_E_T_ <> '*'  "
	//CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SE1: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf  

   	cQuery := " UPDATE " + RETSQLNAME("SF3") + " SET "
	cQuery += "        F3_OBSERV   = 'NF CANCELADA', "
	cQuery += "        F3_DTCANC   = '" + cDtCanc + "' "
	cQuery += "  WHERE F3_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND F3_NFISCAL  = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND F3_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND F3_CLIEFOR  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND F3_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	cQuery += "    AND F3_ESPECIE  = 'CTE' "
    //	CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF3: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf  

	cQuery := " UPDATE " + RETSQLNAME("SFT") + " SET "
	cQuery += "        FT_OBSERV   = 'NF CANCELADA', "
	cQuery += "        FT_DTCANC   = '" + cDtCanc + "' "
	cQuery += "  WHERE FT_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND FT_NFISCAL  = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND FT_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND FT_CLIEFOR  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND FT_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	cQuery += "    AND FT_ESPECIE  = 'CTE' "
	//CONOUT(cQuery)	
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SFT: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf       
	
	
	cQuery := " UPDATE " + RETSQLNAME("DT6") + " SET "
	cQuery += "        D_E_L_E_T_   = '*' "
	//cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += "  WHERE DT6_FILDOC   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND DT6_DOC      = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND DT6_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	//cQuery += "    AND F2_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
	//cQuery += "    AND F2_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	//cQuery += "    AND F2_TIPO     = 'N'   "
	//cQuery += "    AND F2_ESPECIE  = 'CTE' "
	cQuery += "    AND D_E_L_E_T_  <> '*'  "
	//CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar DT6: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf  
	
Return() 

           
//Valida se Pode Excluir o Titulo
Static Function ValExcTit(cNrDoc, cSerieDoc, cClieForn, cLoja, cNrFilial)

	Local lRet      := .T.
	Local cQuery    := ""
	Local cTitBaixa := "TITBAIXA"
	
	cQuery := " SELECT * FROM " + RETSQLNAME("SE1") + " "
	cQuery += " WHERE E1_FILORIG  = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND E1_NUM      = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND E1_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND E1_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND E1_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	cQuery += "    AND E1_BAIXA     <> ''  
	cQuery += "    AND D_E_L_E_T_ <> '*'  "
	       
	
	If Select(cTitBaixa) <> 0
  		dbSelectArea(cTitBaixa)
   		(cTitBaixa)->(dbCloseArea())
  	Endif

 	TCQuery cQuery NEW ALIAS (cTitBaixa) 
	
	If (cTitBaixa)->(!eof())
		lRet := .F.
	Endif    
	
Return lRet       


//Retorna documento original
Static function BuscanfOri(xCHVCONH)
      
	Local _aRet := {}
	Local _cQry := ""
	
	_cQry := " SELECT F2_DOC,F2_SERIE,D2_ITEM,D2_FILIAL FROM "+RetSqlName('SF2')+"(nolock) F2"
	_cQry += " INNER JOIN  "+RetSqlName('SD2')+"(nolock) D2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND "
	_cQry += " D2.D_E_L_E_T_ = '' "
	_cQry += " WHERE F2_CHVCONH ='"+xCHVCONH+"' AND F2.D_E_L_E_T_ = '' " 
	
	 If Select('BuscanfOri') <> 0
  		dbSelectArea('BuscanfOri')
   		('BuscanfOri')->(dbCloseArea())
  	Endif

 	TCQuery _cQry NEW ALIAS ('BuscanfOri') 
	 
	BuscanfOri->(dbgotop())  
	If BuscanfOri->(!eof())
		_aRet :=  {BuscanfOri->F2_DOC,BuscanfOri->D2_ITEM,BuscanfOri->F2_SERIE, BuscanfOri->D2_FILIAL}
	Endif
	
	
Return _aRet
                         
                  
//Busca Produto do Negocio                  
Static function GetProdNeg(xNegocio, xProdAnt )
	
	Local cProdNegoc := xProdAnt
  
	 Do Case
		Case xNegocio $ "03.01-03.02-03.04-03.05-03.06"	
			cProdNegoc := "00120041"
       	Case xNegocio $ "03.03"	
       		cProdNegoc := "00120188"
        Case xNegocio $  "05.01" 
           	cProdNegoc := "00120189"
       	Case xNegocio $ "06.01"	
       		cProdNegoc := "00120040"
		Case xNegocio $ "17.01"	
			cProdNegoc := "00120041N"   
		Case xNegocio $ "01.01-01.02-01.03-01.04-01.05"	
			cProdNegoc := "00120041"//"00120042N"   
		Case xNegocio $ "13.01"	
			cProdNegoc := "00120041"//"00120043N"  
		Case xNegocio $ "04.01-04.02-04.03-04.04" 
			cProdNegoc := "00120041"//"00120044N"

	EndCase
	
			
Return cProdNegoc
                    

//Função para Exclusão dos dados de nota de entrada                
Static function ExcluiSD1()  

	Local cQuery := ""

	cQuery := " UPDATE " + RETSQLNAME("SD1") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
	cQuery += " WHERE "
	cQuery += "   D1_DOC     =  '" + SF1->F1_DOC + "' "
	cQuery += "   AND D1_SERIE     =  '"+SF1->F1_SERIE+"' "
	cQuery += "   AND D1_FORNECE  =  '" + SF1->F1_FORNECE + "' "
	cQuery += "   AND D1_LOJA     =  '" + SF1->F1_LOJA + "' " 
	cQuery += "   AND D1_FILIAL   =  '" + SF1->F1_FILIAL + "' "
	cQuery += "   AND D_E_L_E_T_  <> '*'  "  
//		conout(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SD1: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf                                        
	                                               
	
	cQuery := " UPDATE " + RETSQLNAME("SF3") + " SET "
	cQuery += "        D_E_L_E_T_   = '*' "
	  //	cQuery += "        ,R_E_C_D_E_L_ = R_E_C_N_O_ " 
	cQuery += "  WHERE F3_FILIAL   = '" + SF1->F1_FILIAL + "' "
	cQuery += "    AND F3_NFISCAL  = '" + SF1->F1_DOC    + "' "
	cQuery += "    AND F3_SERIE    = '" + SF1->F1_SERIE + "' "
	cQuery += "    AND F3_CLIEFOR  = '" + SF1->F1_FORNECE  + "' "
	cQuery += "    AND F3_LOJA     = '" + SF1->F1_LOJA      + "' "
	  //	cQuery += "    AND F3_ESPECIE  = '"	+SF1->F1_ESPECIE+"' "  
//	   conout(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF3: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf       
	
	
	cQuery := " UPDATE " + RETSQLNAME("SFT") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
	cQuery += "  WHERE FT_FILIAL   = '" +SF1->F1_FILIAL + "' "
	cQuery += "    AND FT_NFISCAL  = '" + SF1->F1_DOC     + "' "
	cQuery += "    AND FT_SERIE    = '" + SF1->F1_SERIE + "' "
	cQuery += "    AND FT_CLIEFOR  = '" +  SF1->F1_FORNECE  + "' "
	cQuery += "    AND FT_LOJA     = '" + SF1->F1_LOJA      + "' "
   	cQuery += "    AND FT_ESPECIE  = '"	+SF1->F1_ESPECIE+"' "   
//  		conout(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SFT: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf  
			
	cQuery := " UPDATE " + RETSQLNAME("SF8") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
	cQuery += " WHERE "
	cQuery += "   F8_NFDIFRE     =  '" + SF1->F1_DOC + "' "
	cQuery += "   AND F8_SEDIFRE     =  '"+SF1->F1_SERIE+"' "
	cQuery += "   AND F8_TRANSP  =  '" + SF1->F1_FORNECE + "' "
	cQuery += "   AND F8_LOJTRAN =  '" + SF1->F1_LOJA + "' "
	cQuery += "   AND D_E_L_E_T_  <> '*'  "   
	//conout(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF8: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf    
	
	
	cQuery := " UPDATE " + RETSQLNAME("SF1") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
	cQuery += " WHERE "
	cQuery += "   F1_DOC     =  '" + SF1->F1_DOC + "' "
	cQuery += "   AND F1_SERIE     =  '"+SF1->F1_SERIE+"' "
	cQuery += "   AND F1_FORNECE  =  '" + SF1->F1_FORNECE + "' "
	cQuery += "   AND F1_LOJA     =  '" + SF1->F1_LOJA + "' " 
	cQuery += "   AND F1_FILIAL   =  '" + SF1->F1_FILIAL + "' " 
	cQuery += "   AND D_E_L_E_T_  <> '*'  "   
//	conout(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF1: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf 
	     
Return    
         
//Verifica se ja temtítulo gerado, excluí se necessário
Static Function VerifTit(X_FILIAL,X_CLIENTE,X_LOJA,X_PREFIXO,X_NUM,X_TIPO)

	Local lBaixado  := .F.
	Local cQuery    := "" 
	Local cWhere    := ""
	local aRecnoSE1 := {}
	
	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
	cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM "+RetSqlName('SE1')+'(NOLOCK) SE1'
	cWhere += " WHERE "
	cWhere += " E1_NUM 		= '"+X_NUM+"' 	  AND "
	cWhere += " E1_PREFIXO  = '"+X_PREFIXO+"' AND "
	cWhere += " E1_TIPO 	= '"+X_TIPO+"' 	  AND "       
	cWhere += " E1_CLIENTE  = '"+X_CLIENTE+"' AND "
	cWhere += " E1_LOJA 	= '"+X_LOJA+"' 	  AND "    
	cWhere += " E1_FILIAL	= '"+X_FILIAL+"'  AND "
	cWhere += " D_E_L_E_T_  = ''  "    
	cQuery += cWhere
	
	If Select("TVERSE1") <> 0
  		dbSelectArea("TVERSE1")
   		TVERSE1->(dbCloseArea())
  	Endif
    CONOUT(cQuery)
 	TCQuery cQuery NEW ALIAS ("TVERSE1") 
	     
	TVERSE1->(dbgotop()) 
	
	While TVERSE1->(!eof())
	     
	    //Verfica se Alguma parcela já está baixada
		If TVERSE1->E1_BAIXA <> ''
	    	lBaixado := .T.  
		Endif
	
		TVERSE1->(DbSkip())
	Enddo
	 
	//Se não houveram baixas Exclui Títulos 
	If !lBaixado
		cQuery := " UPDATE "+RetSqlName('SE1')+" SET R_E_C_D_E_L_ = R_E_C_N_O_, D_E_L_E_T_ = '*' "
   		cQuery += cWhere
   		
   		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SE1: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf 	
	
	Endif
	
	

Return lBaixado

// Projeto Nyke, realiza o Envio do Boleto
// foi Retirado, pois execuções por Job não gera arquivos fisicos, 
// rotina colocada em schedule XAG0031
/*Static Function EMailNyke(xCodEmp,xEntDes,xEndDes)
            
	Local cQuery   := ""
	Local cMailRet := ""   
	
	U_AGX635CN("DBG")
	
	cQuery  += " SELECT CTE_CLINYK_EmailBoleto as EMAIL " 
	cQuery  += " FROM CTE_CLINYK  "
	cQuery  += " WHERE STG_GEN_TABEMP_CTe_Codigo = '"+alltrim(str(xCodEmP))+"' AND "
	cQuery  += " STG_GEN_TABENT_NYK_Codigo ='"+xEntDes+"' AND "
	cQuery  += " STG_GEN_ENDENT_NYK_Codigo ='"+xEndDes+"' "
	
	If Select("EMailNyke") <> 0
  		dbSelectArea("EMailNyke")
   		EMailNyke->(dbCloseArea())
  	Endif
    CONOUT(cQuery)
 	TCQuery cQuery NEW ALIAS ("EMailNyke") 
	     
	EMailNyke->(dbgotop())
	
	If EMailNyke->(!eof())
		cMailRet := EMailNyke->EMAIL
	Endif   
	 
	//Se não achar no E-mail específico, Pega da Tabela de Clientes
	If alltrim(cMailRet) == ''
		
		cQuery  := " SELECT GEN_ENDENT_EmailNFe FROM GEN_ENDENT
		cQuery  += " WHERE GEN_TABENT_Codigo = '"+xEntDes+"' AND "
		cQuery  += " GEN_ENDENT_Codigo = '"+xEndDes+"' " 
		CONOUT(cQuery)
		If Select("EMailNyke") <> 0
  			dbSelectArea("EMailNyke")
   			EMailNyke->(dbCloseArea())
  		Endif

 		TCQuery cQuery NEW ALIAS ("EMailNyke") 
	     
		EMailNyke->(dbgotop())  
		
		If EMailNyke->(!eof())
			cMailRet := EMailNyke->EMAIL
		Endif   

	Endif     
	
	Conout('AGX635CS - E-MAIL NYKE: '+cMailRet) 
	
	U_AGX635CN("PRT")

Return cMailRet */