#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} AGX635D6
//ROTINA DE INTEGRAÇÃO COM DBGINT - Geração de Tabela DT6
@author Spiller
@since 26/12/2017
@version undefined
@param aEmpDePara, array, Empresas
@type function
/*/   
User Function AGX635D6(aEmpDePara,aParamDT6)

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
	//Default xReproc      := .F.  
	Default aParamDT6    := {}
	//Private lReproc      := xReproc  
	Private aItens116    := {} 
	Private cNumLote     := ''
    
	conout('Iniciou AGX635D6 '+time())

	For nCountDe := 1 To Len(aEmpDePara)

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3] 
				nFilde       := aEmpPara[nCountPara][1] 
				
				
				//Valida Filial e caso esteja sendo rodado via Schedule(len(aParamDT6) == 0) 
				If ( (cFilialPara >= aParamDT6[7] .and.  cFilialPara <= aParamDT6[8]) .or. len(aParamDT6) == 0 ).and. cEmpPara == '01'
				/*.and. (cEmpPara >= aParamDT6[9] .and.  cEmpPara <= aParamDT6[10])//cFilialPara = '07'*/
					lClearEnv := .T.
					conout(' AGX635D6 '+cEmpPara+' / '+cFilialPara)
				  	PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5","DT6","DTC","XXS"
	
					   	RPCSetType(3)
				  		RPCSetEnv(cEmpPara, cFilialPara)
					
						//Busca dados e Grava no Arq de trabalho por Filial
						cArqTmp := CriaArqD6(nEmpDe,nFilde,aParamDT6)
	
						cCapaCTS := GetNextAlias()
						DbUseArea(.T., Nil, cArqTmp, (cCapaCTS))
						nQtdeDT6 := (cCapaCTS)->(RecCount()) 
						
						//Caso tenha algum CTE
						//Inclui dados no Protheus
						If nQtdeDT6 > 0
							INSERIRDT6(cCapaCTS)
		                Endif
		                
					 	RPCClearEnv()
						dbCloseAll()
					
				   	RESET ENVIRONMENT 
				 Endif
			
		Next nCountPara
           
  		FErase(cArqTmp + GetDbExtension())
		FErase(cArqTmp + OrdBagExt())
	Next nCountDe 
	   
	//Grava dados de LOG
	If len(aLogs) > 0     
 		//Grava Log
		U_AGX635LO(aLogs,'AGX635D6','IMPORTACAO DE TABELA DT6')
 	Endif
 	 //U_AGX635CN("PRT")
Return(aEmpDePara)
  
  
//Busca CTE´S para importação
Static Function SelectCTS(nEmpOrigem,nFilOrigem,aParamDT6)

    Local cCapaCTS := GetNextAlias()
    Local cQuery    := "" 
    Local cDatade   := ""
	Local cDataAte  := ""
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1     
	
	//CTE´S
	cQuery := " SELECT  " 
	cQuery += " SUM(QTDCAR.CTE_QTDCAR_Quantidade) 		 AS QTDVOL,"
	cQuery += " CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo     AS DBEMP,     "+CHR(13)
	cQuery += " CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo     AS DBFIL,     "+CHR(13)
	cQuery += " CAST(CTE_MOVCTE_TipoCTE AS  CHAR) AS TIPOCTE,  "+CHR(13)
	cQuery += " CTE_MOVCTE.CTE_MOVCTE_ID		  AS IDCTE,     "+CHR(13) 
	cQuery += " GEN_NATOPE_TES 			      AS D2_TES,    "+CHR(13) 
	//cQuery += " ENDENT.GEN_ENDENT_IF 	      AS CNPJ_CPF,  "+CHR(13)
	cQuery += " TOMADOR.GEN_ENDENT_IF 	      AS TOMA_CNPJ, "+CHR(13) 
	cQuery += " REMETENTE.GEN_ENDENT_IF 	  AS REM_CNPJ, "+CHR(13) 
	cQuery += " DESTINAT.GEN_ENDENT_IF 	      AS DES_CNPJ, "+CHR(13) 	
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
	cQuery += " CTE_MOVCTE_ValorCOFINS AS F2_VALIMP5 "
	//cQuery += " STG_GEN_NATOPE_CTe_Codigo, "
	//cQuery += " CTE_MOVCTE_ValorServico, "
	//cQuery += " CTE_MOVCTE_ValorReceber, "	
	cQuery += " FROM CTE_MOVCTE CTE_MOVCTE "+CHR(13)
   	//cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Des_Codigo "+CHR(13)  //AQUI
 	cQuery += " INNER JOIN GEN_ENDENT DESTINAT ON DESTINAT.GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Des_Codigo   "
 	cQuery += " AND DESTINAT.GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Des_Codigo "+chr(13) 
 	cQuery += " INNER JOIN GEN_ENDENT REMETENTE ON REMETENTE.GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Rem_Codigo "
 	cQuery += " AND REMETENTE.GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Rem_Codigo "+chr(13)
 	cQuery += " INNER JOIN GEN_ENDENT TOMADOR ON TOMADOR.GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Tom_Codigo  "
 	cQuery += " AND TOMADOR.GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Tom_Codigo "+chr(13)
 	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON STG_GEN_NATOPE_CTe_Codigo = GEN_NATOPE_Codigo  "+chr(13)
   	cQuery += " LEFT JOIN CTE_TABPRO CTE_TABPRO ON CTE_TABPRO.GEN_TABEMP_Codigo = CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo "+chr(13)
	cQuery += " AND CTE_TABPRO.CTE_TABPRO_ID = CTE_MOVCTE.STG_CTE_TABPRO_CTe_ID  "+chr(13)
   	cQuery += " LEFT JOIN CTE_QTDCAR QTDCAR ON "
   	cQuery += " QTDCAR.STG_GEN_TABEMP_CTe_Codigo = CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo AND " 
	cQuery += " QTDCAR.STG_GEN_TABFIL_CTe_Codigo = CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo AND "
	cQuery += " QTDCAR.CTE_MOVCTE_ID = CTE_MOVCTE.CTE_MOVCTE_ID  "
   	cQuery += " WHERE CTE_MOVCTE_DHIntTotvs IS NOT NULL AND "+CHR(13)
	cQuery += "   CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo = " + cValToChar(nEmpOrigem)+""+CHR(13) 
	
	//Retira Ctes de Anulação 
	cQuery += " AND  CTE_MOVCTE_TipoCTE <> 2 "
	
	//Somente Cte´s com chave e cancelados ou trnasmitidos
	cQuery += " AND CTE_MOVCTE_Chave <> '' "  
   	cQuery += " AND (CTE_MOVCTE_SituacaoCTe =  4 )" //OR CTE_MOVCTE_SituacaoCTe =  5)"  
   	//cQuery += " AND CTE_MOVCTE_SituacaoCTe =  5  "
	    	      
    //Se Tem os parâmetros preenchidos Filtra, senão Filtra o Mês corrente
	If Len(aParamDT6) > 5
		cQuery += " AND CTE_MOVCTE_Serie   >=  '"+aParamDT6[1]+"' "   //Serie De
		cQuery += " AND CTE_MOVCTE_Serie   <=  '"+aParamDT6[2]+"' "  //Serie Ate
   		cQuery += " AND CTE_MOVCTE_Numero  >=  '"+alltrim(str(val(aParamDT6[3])))+"' "   //Documento de 
   		cQuery += " AND CTE_MOVCTE_Numero  <=  '"+alltrim(str(val(aParamDT6[4])))+"' "   //documento Ate
		cQuery += " AND CTE_MOVCTE_Emissao >=  '"+aParamDT6[5]+"' "  //Emissao de 
		cQuery += " AND CTE_MOVCTE_Emissao <=  '"+aParamDT6[6]+"' "  //Emissao Ate
	Else                                                                                
	    cDatade := Substr(dtos(ddatabase),1,6)+'01'  //Captura primeiro dia do Mês
		cDataAte := Substr(dtos(ddatabase),1,6)+'31' //Captura ultimo dia do Mês
	
		cQuery += " AND CTE_MOVCTE_Emissao >=  '"+DateMySql(stod(cDatade),'00')+"' "  //Emissao de 
		cQuery += " AND CTE_MOVCTE_Emissao <=  '"+DateMySql(stod(cDataAte),'99')+"' "  //Emissao Ate	
	Endif	
	//cQuery += " AND CTE_MOVCTE_Numero  NOT IN ('61021','61022','11570','25843')    "
	//cQuery += " AND CTE_MOVCTE_Numero > 61022 "  
	//cQuery += " AND CTE_MOVCTE_SituacaoCTe =  5 "
	//cQuery += " AND (CTE_MOVCTE_Numero = '11570' OR CTE_MOVCTE_Numero = '25843')"
   	//cQuery += " AND CTE_MOVCTE_Numero IN ('31397','31346') "
    //cQuery += " AND (ENDENT.GEN_ENDENT_IF LIKE '%7631686%' OR "
	//cQuery += " ENDENT.GEN_ENDENT_IF LIKE '92577550%' OR "
 	//cQuery += " ENDENT.GEN_ENDENT_IF LIKE '15083929%' OR "
    //cQuery += " ENDENT.GEN_ENDENT_IF LIKE '%511844%' OR "
    //cQuery += " ENDENT.GEN_ENDENT_IF LIKE '97248389%' OR "
    //cQuery += " ENDENT.GEN_ENDENT_IF LIKE '89506604%')

	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0  
		cQuery += " AND  CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo = " + cValToChar(nFilOrigem)
    Endif      
    
    cQuery += " Group by DBEMP, DBFIL, IDCTE, D2_TES, TOMA_CNPJ, REM_CNPJ, DES_CNPJ, UNMED, F2_SERIE, F2_DOC, F2_EMISSAO, F2_CHVCONH, F2_BASEICM, D2_PICM,"
    cQuery += " F2_VALICM, F2_VALMERC, F2_PLACA, DT_CANC, REM_COD, REM_LOJA, DEST_COD, DEST_LOJA, TOMA_COD, TOMA_LOJA, SITUA_CTE, CODDEST, LOJADEST, "
    cQuery += " F2_ALQIMP6, F2_BASIMP6, F2_VALIMP6, F2_ALQIMP5, F2_BASIMP5, NCM, F2_VALIMP5"  
    //cQuery += " LIMIT 1000 " 
    
    U_AGX635CN("DBG")    
	//conout('AGX635D6') 
   	//conout(cquery)
  	If Select(cCapaCTS) <> 0
  		dbSelectArea(cCapaCTS)
   		(cCapaCTS)->(dbCloseArea())
  	Endif

 	TCQuery cQuery NEW ALIAS (cCapaCTS)   
 	TCSETFIELD(cCapaCTS,"F2_VALMERC"   ,"N",14,2)   
 	TCSETFIELD(cCapaCTS,"QTDVOL"       ,"N",7 ,0)  
 	TCSETFIELD(cCapaCTS,"F2_ALQIMP6"   ,"N",6,2) 
	TCSETFIELD(cCapaCTS,"F2_BASIMP6"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"F2_VALIMP6"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"F2_ALQIMP5"   ,"N",6,2) 
	TCSETFIELD(cCapaCTS,"F2_BASIMP5"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"NCM"   	   ,"N",10,0) 
	TCSETFIELD(cCapaCTS,"F2_VALIMP5"   ,"N",14,2) 
	TCSETFIELD(cCapaCTS,"F2_BASEICM"   ,"N",14,2)  


Return(cCapaCTS)


//Inserir Dados no Protheus
Static Function INSERIRDT6(cCapaCTS)

	Local lRegOK      := .T. 
	Local cFil        := '' 
	Local cTipoCli    := ""
	Local cEst        := "" 
	Local cTpFrete 	  := ""   
	Local cCliCodRem  := ""
    Local cCliLojRem  := ""
    Local cCliCodDes  := ""
    Local cCliLojDes  := ""
    Local cCliCodTom  := ""
    Local cCliLojTom  := "" 
    Local cDT6_CDRORI := "" 	
    Local cDT6_CDRDES := "" 	
    Local cDT6_CDRCAL := "" 
    Local lNovo       := .F.
    	  
	U_AGX635CN("PRT") 
	
	cNumLote := U_AGX635DC(1,cFilAnt) 
	CONOUT(cFilAnt + ' ' + cNumLote)  
	
	//conout('INSERIRDT6')
	(cCapaCTS)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cCapaCTS)->(!eof())
		 
		//Valida TOMADOR
		SA1->(DbSetOrder(3))
		SA1->(DbGoTop())  		
		If !SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(TOMA_CNPJ)))			 			
			lRegOK := .F. 
			//GRAVA Array de LOG
       		AADD(aLogs,{;
					 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Tomador Nao Cadastrado:'+(cCapaCTS)->(TOMA_CNPJ)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cCapaCTS)->(F2_DOC)+'+'+(cCapaCTS)->(F2_SERIE)+'+'+(cCapaCTS)->(TOMA_COD)+'+'+(cCapaCTS)->(TOMA_LOJA)},; 
						{'ZDB_TAB' 	  ,'SA1'},; 
						{'ZDB_INDICE' ,3},;  
						{'ZDB_TIPOWF' ,2},;
						{'ZDB_CHAVE'  ,(cCapaCTS)->(TOMA_CNPJ)};
						})     
												  
			(cCapaCTS)->(dbskip()) 
			LOOP  
		Else
	  		cEst        := SA1->A1_EST 
	  		cTipoCli    := SA1->A1_TIPO   
	  		cCliCodTom  := SA1->A1_COD 
    	    cCliLojTom  := SA1->A1_LOJA
		Endif        		
		 
	  	cEst    	:= '' 
	  	cTipoCli 	:= ''   
	  	cCliCodRem  := '' 
        cCliLojRem  := ''
        cDT6_CDRORI := ''		
		
		//Valida REMETENTE
		SA1->(DbSetOrder(3))
		SA1->(DbGoTop())  		
		If !SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(REM_CNPJ)))			 			
			lRegOK := .F.      
			
			//Inclui Cliente 
			U_AGX635CF((cCapaCTS)->(REM_CNPJ),'SA1')
			
			//GRAVA Array de LOG
       	   /*	AADD(aLogs,{;
					 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Remetente Nao Cadastrado:'+(cCapaCTS)->(REM_CNPJ)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cCapaCTS)->(F2_DOC)+'+'+(cCapaCTS)->(F2_SERIE)+'+'+(cCapaCTS)->(DEST_COD)+'+'+(cCapaCTS)->(DEST_LOJA)},; 
						{'ZDB_TAB' 	  ,'SA1'},; 
						{'ZDB_INDICE' ,3},;  
						{'ZDB_TIPOWF' ,2},;
						{'ZDB_CHAVE'  ,(cCapaCTS)->(REM_CNPJ)};
						})     
												  
			(cCapaCTS)->(dbskip()) 
			LOOP  
		Else     */
		Endif
	  		cEst    	:= SA1->A1_EST 
	  		cTipoCli 	:= SA1->A1_TIPO   
	  		cCliCodRem  := SA1->A1_COD 
    	    cCliLojRem  := SA1->A1_LOJA
    	    cDT6_CDRORI := SA1->A1_COD_MUN
		//Endif     
		
		//Valida DESTINATÁRIO
		SA1->(DbSetOrder(3))
		SA1->(DbGoTop())  		
		If !SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(DES_CNPJ)))			 			
			lRegOK := .F.     
			
			//Inclui Cliente 
			U_AGX635CF((cCapaCTS)->(DES_CNPJ),'SA1')
			
			//GRAVA Array de LOG
       		/*AADD(aLogs,{;
					 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Destinatario Sem conta:'+(cCapaCTS)->(DES_CNPJ)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cCapaCTS)->(F2_DOC)+'+'+(cCapaCTS)->(F2_SERIE)+'+'+(cCapaCTS)->(DEST_COD)+'+'+(cCapaCTS)->(DEST_LOJA)},; 
						{'ZDB_TAB' 	  ,'SA1'},; 
						{'ZDB_TIPOWF' ,2},;
						{'ZDB_INDICE' ,3},; 
						{'ZDB_CHAVE'  ,(cCapaCTS)->(DES_CNPJ)};
						})     
												  
			(cCapaCTS)->(dbskip()) 
			LOOP  
		Else     */
		Endif
	  		cEst        := SA1->A1_EST 
	  		cTipoCli    := SA1->A1_TIPO   
	  		cCliCodDes  := SA1->A1_COD 
    	    cCliLojDes  := SA1->A1_LOJA 
    	    cDT6_CDRDES := SA1->A1_COD_MUN  
    	    cDT6_CDRCAL := SA1->A1_COD_MUN 
	//	Endif    		
		
		          		          
		aTam    := {}
		aTam    := TamSX3("F2_DOC")
		_cDoc   := PADL(alltrim((cCapaCTS)->(F2_DOC)),aTam[1],'0')
        
        aTam    := {}
		aTam    := TamSX3("F2_SERIE")	
        _cSerie := PADR(alltrim((cCapaCTS)->(F2_SERIE)),aTam[1],' ') 
        
        
        //conout('CTE '+xfilial('SF2')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA)
		//Verifica se já existe no Protheus
		dbselectarea('SF2')
		dbsetorder(1)
		If !dbseek(xfilial('SF2')+_cDoc+_cSerie+cCliCodTom+cCliLojTom) 
	
									// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
		  		//CONOUT('AGX635D6 - Nao tem SF2 '+_cDoc+_cSerie+cCliCodTom+cCliLojTom)
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
							{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
							{'ZDB_MSG'	  ,'Nao tem SF2 '+_cDoc+_cSerie+'/('+cCliCodTom+'-'+cCliLojTom+')'},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,cEmpant},;
							{'ZDB_FILIAL' ,cFilAnt},;
							{'ZDB_DBCHAV' ,(cCapaCTS)->(F2_DOC)+'+'+(cCapaCTS)->(F2_SERIE)+'+'+(cCapaCTS)->(DEST_COD)+'+'+(cCapaCTS)->(DEST_LOJA)},; 
							{'ZDB_TAB' 	  ,'SF2'},; 
							{'ZDB_INDICE' ,1},; 
							{'ZDB_CHAVE'  ,_cDoc+_cSerie+cCliCodTom+cCliLojTom};
							})     
 	 		
	 		(cCapaCTS)->(dbskip()) 
			LOOP 
	 	Endif
	 	          
	 	//Valida se é CIF ou FOB de acordo com o Tomador do Serviço            
	    
	    If (cCapaCTS)->(REM_COD) == (cCapaCTS)->(TOMA_COD) .AND.  (cCapaCTS)->(REM_LOJA) = (cCapaCTS)->(TOMA_LOJA)
	 		cTpFrete := "C"
	 	Else
	 		cTpFrete := "F"
	 	Endif
	 	 
	 	cTes := (cCapaCTS)->(D2_TES)             
	 	                                                                                                                            
		cFil := xFilial('SF2') 
		cEspecie := "CTE"  

		conout(cEmpAnt+'/'+cFilAnt+' * Inserindo DT6 * '+_cDoc+' - '+time())
 		  
 		lNovo := .F. 
 		//Verifica se já existe o Regitro
 		dbselectarea('DT6')
 		dbsetorder(1)   
 		//DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
 		If !(dbseek(xFilial('DT6')+cFil+_cDoc+_cSerie))
 	 		lNovo := .T.                               
 	 	Endif
		//conout( 'lNovo') ;conout( lNovo)                
	   	Begin Transaction  
		   
			RecLock('DT6',lNovo) 
				DT6->DT6_FILIAL := xfilial('DT6') 
				DT6->DT6_FILORI := cFil
				DT6->DT6_FILDOC := cFil
				DT6->DT6_DOC    := _cDoc
				DT6->DT6_SERIE  := _cSerie
				DT6->DT6_DATEMI := (cCapaCTS)->(F2_EMISSAO)
				DT6->DT6_VALMER := (cCapaCTS)->(F2_VALMERC)
				DT6->DT6_VALFRE := (cCapaCTS)->(F2_VALMERC)
				DT6->DT6_VALIMP := (cCapaCTS)->(F2_VALICM)
				DT6->DT6_VALTOT := (cCapaCTS)->(F2_VALMERC)
				DT6->DT6_PRIPER := '2'
				DT6->DT6_CLIREM := cCliCodRem
				DT6->DT6_LOJREM := cCliLojRem
				DT6->DT6_CLIDES := cCliCodDes
				DT6->DT6_LOJDES := cCliLojDes
				DT6->DT6_CLIDEV := cCliCodTom
				DT6->DT6_LOJDEV := cCliLojTom
				DT6->DT6_DEVFRE := IIf(cTpFrete == 'C', '1','2')//Se for CIF == 1(REMETENTE)
				DT6->DT6_SERVIC := '010'//Transporte Rodoviario Servico x Tarefa
				DT6->DT6_STATUS := '1'//(cAliasQRY1)->DT6_STATUS
				DT6->DT6_VENCTO := (cCapaCTS)->(F2_EMISSAO)//STOD((cAliasQRY1)->DT6_VENCTO)
				DT6->DT6_FILDEB := cFil
				DT6->DT6_TIPO   := 'CTE'
				DT6->DT6_MOEDA  := 1
				DT6->DT6_VALFAT := (cCapaCTS)->(F2_VALMERC)
				DT6->DT6_CHVCTE :=  ALLTRIM(cValToChar((cCapaCTS)->(F2_CHVCONH)))                                                  
				DT6->DT6_VOLORI := (cCapaCTS)->(QTDVOL)//(cAliasQRY1)->DT6_VOLORI         
				DT6->DT6_QTDVOL := (cCapaCTS)->(QTDVOL)//ROUND((cAliasQRY1)->DT6_QTDVOL,0)	
				
				//Campos vindo da Planilha e nao gravados por AGX599
				DT6->DT6_CDRORI := cDT6_CDRORI
				DT6->DT6_CDRDES := cDT6_CDRDES
				DT6->DT6_CDRCAL := cDT6_CDRCAL  
				 
				//Gera numeração de Lote para o Cte
				If alltrim(DT6->DT6_LOTNFC) == ''             
					cNumLote := SOMA1(cNumLote)
					DT6->DT6_LOTNFC:=  cNumLote//U_AGX635DC(1)
		  		Endif     
		  				  	
		  	DT6->(MsUnlock()) 
		  	
		  	//Grava dados na tabela DTC 
			U_AGX635DC(2)  
		  	
		End Transaction 
		

		                  
		(cCapaCTS)->(dbskip())  
	Enddo
	                         
Return()

 
//Cria Arquivo de trabalho
Static Function CriaArqD6(nEmpOrigem,nFilOrigem,aParamDT6)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectCTS(nEmpOrigem,nFilOrigem,aParamDT6)

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

//Transforma em DATA/HORA do Myql
Static Function DateMySql(xData,xTime) 

	Local cDateMSql := "" 

	cDateMSql := dtos(xData)
	cDateMSql := substr(cDateMSql,1,4)+'-'+substr(cDateMSql,5,2)+'-'+substr(cDateMSql,7,2)+' '+xTime


Return cDateMSql 
                     
                   
// ################################################## //
//  Rotina de Geração da Tabela DT6 (*VIA SCHEDULE*)  //
// ################################################## //
User Function AGX635DS()
	
	Local aParamDT6  := {}     
	Local cDataINI

	cDataINI := dtos(date())
	cDataINI := substr(cDataINI,1,6)+'01'      
	
	AADD(aParamDT6,'   ')   //Serie de 
	AADD(aParamDT6,'ZZZ') //Serie ate 
	AADD(aParamDT6,'         ')//Cte de  
	AADD(aParamDT6,'999999999')//Cte ate 
	AADD(aParamDT6,DateMySql(stod(cDataINI),'00')) //Emissao de 
	AADD(aParamDT6,DateMySql(date(),'99')) //Emissao ate
	AADD(aParamDT6,'01')   
	AADD(aParamDT6,'99')  
	AADD(aParamDT6,'01')   
	AADD(aParamDT6,'01')  
	
	aEmpDePara := U_AGX635EM()
    
	If Len(aEmpDePara) > 0 
  		aEmpDePara := startjob("U_AGX635D6",getenvserver(),.T.,@aEmpDePara,aParamDT6) 
  	//  aEmpDePara := U_AGX635D6(@aEmpDePara,aParamDT6) 
    Endif
    
Return  

      
// Cria registro na Tabela DTC
// Se fez necessário devido a DIME buscar 
// dados de remetente dessa TABELA 
// xOpc == 1, Retorna o Proximo numero Valido de Lote
// xOpc == 2, Grava tabela DTC 
// xFilDT6 , Filial corrente para buscar Prox Numero
User Function AGX635DC(xOPC,xFilDT6)

    Local   cQuery   := "" 
    Local   cTABDTC  := "AGX635DC"   
    Local   cRetLote := "" 
    Local   lNovoDTC := .F.
    Default xOPC   	 := 1   
    Default xFilDT6  := ''
       
    //Retorna proximo lote válido na tabela DTC
    If xOPC == 1     
   		cQuery += " SELECT MAX(DTC_LOTNFC) AS NEXTNUM FROM "+RetSqlName('DTC')+"(NOLOCK) "   
    	cQuery += " WHERE DTC_FILORI = '"+xFilDT6+"' " 
   		CONOUT(cQuery)
   		If Select(cTABDTC) <> 0
  			dbSelectArea(cTABDTC)
 	  		(cTABDTC)->(dbCloseArea())
   		Endif

   		TCQuery cQuery NEW ALIAS (cTABDTC) 

 		cRetLote := (cTABDTC)->NEXTNUM

 	//Grava tabela DTC	  			   	
   	ElseIf xOPC == 2
   		dbselectarea('DTC')
   		dbsetorder(7)
   		If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILORI + DT6_LOTNFC)))//dbseek(DT6->DT6_FILIAL+DT6->DT6_DOC+DT6->DT6_SERIE+DT6->DT6_FILDOC)//+DTC_NUMNFC+DTC_SERNFC ////Dbseek(xFilial('DTC') + DT6->DT6_FILDOC + DT6->DT6_LOTNFC )
   			lNovoDTC := .F.	
   		Else
   			lNovoDTC := .T.	
   		Endif 
   		      
   		Begin Transaction    
   			Dbselectarea('DTC')
   	   		Reclock('DTC',.T.) 
   	   			DTC->DTC_FILIAL := xfilial('DTC')
	   			DTC->DTC_FILORI := DT6->DT6_FILORI
	   			DTC->DTC_DOC    := DT6->DT6_DOC 
				DTC->DTC_LOTNFC := DT6->DT6_LOTNFC
				DTC->DTC_SERIE	:= DT6->DT6_SERIE
				DTC->DTC_CLIREM	:= DT6->DT6_CLIREM
				DTC->DTC_LOJREM	:= DT6->DT6_LOJREM
				DTC->DTC_CLIDES	:= DT6->DT6_CLIDES
				DTC->DTC_LOJDES	:= DT6->DT6_LOJDES
				DTC->DTC_SELORI	:= '2'
				DTC->DTC_EMINFC := DT6->DT6_DATEMI
				DTC->DTC_DATENT := DT6->DT6_DATEMI  
				DTC->DTC_VALOR  := DT6->DT6_VALTOT  		
   			DTC->(MsUnlock()) 
   		End Transaction  
   	Endif
   	
Return cRetLote   