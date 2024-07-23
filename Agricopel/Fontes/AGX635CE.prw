#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} AGX635CE
//ROTINA DE INTEGRAÇÃO COM DBGINT - CTE de Entrada
@author Spiller
@since 11/09/2017
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/
User Function AGX635CE(aEmpDePara,xReproc)

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local cEmpPara       := ""
	Local cFilialPara    := "" 
	//Local oTmpTable      := Nil
	Private nEmpDe       := 0
	Private cCapaCTE     := ""    
	Private cAliasNFE    := ""  
	Private aIntCAPA	 := {} //Array com Notas que foram integradas
	Private aIntITENS	 := {} //Array com Notas que foram integradas  
	Private aLogs		 := {} //Array de Logs  
	Private lClearEnv    := .F.   
	Default xReproc      := .F.
	Private lReproc      := xReproc  
	Private aItens116    := {}
	Private  oError := ErrorBlock({|e| GVErrorlog(e)})
	Private  cENTouSAI := "E" //Variavel para controlar se é de nota de entrada ou saída


	For nCountDe := 1 To Len(aEmpDePara)
		conout('Iniciando AGX635CE - '+time())
		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3] 
				nFilde       := aEmpPara[nCountPara][1] 
				
				lClearEnv := .T.

				PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","XXS"
			   	
				RPCSetType(3)
			  	If RPCSetEnv(cEmpPara, cFilialPara)

					/*oTmpTable := CriaArqCE(nEmpDe, nFilde)
					cCapaCTE := oTmpTable:GetAlias()*/
					cCapaCTE := CriaArqCE(nEmpDe, nFilde)
					If Select(cCapaCTE) <> 0
						nQtdeCTE := (cCapaCTE)->(RecCount())
						
						If nQtdeCTE > 0
							InserirCTE(cCapaCTE)
						Endif
						
						(cCapaCTE)->(DbCloseArea())
						//oTmpTable:Delete()
						//FreeObj(oTmpTable)

						RPCClearEnv()
						dbCloseAll()
					Else
						conout("AGX635CE - Nao foi Possivel select: "+cCapaCTE)
					Endif 
				Else
					conout("AGX635CE - Nao foi Possivel abrir o ambiente: "+cEmpPara+"-"+cFilialPara)
				Endif
				RESET ENVIRONMENT
		Next nCountPara

	Next nCountDe 
	
	If len(aLogs) > 0     
 		//Grava Log
		U_AGX635LO(aLogs,'AGX635CE','IMPORTACAO CTE ENTRADA')
 	Endif
	
	ErrorBlock(oError)
		
Return(aEmpDePara)
  

//Busca dados do CTE
Static Function SelectCTE(nEmpOrigem,nFilOrigem)

    Local cCapaCTE  := "SelectCTE"//GetNextAlias()
    Local cQuery    := "" 
	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1   
		
	
	//CTE´S
	cQuery := " SELECT  "
	cQuery += " STG_GEN_TABEMP_Codigo  AS DBEMP	   "+CHR(13)
	cQuery += " ,GEN_NATOPE_TES AS D1_TES  	"+CHR(13)//  TES Protheus     
	cQuery += " ,STG_GEN_NATOPE_Codigo AS NATOPER "+CHR(13)//  TES Protheus    
	cQuery += " ,STG_GEN_TABFIL_Codigo AS DBFIL   " +CHR(13)
	cQuery += " ,ENDENT.GEN_ENDENT_IF AS CNPJ_CPF  "+CHR(13)
	//cQuery += " ,COM_CONFRE_Numero     AS F1_DOC   "+CHR(13)
	cQuery += ",CAST(COM_CONFRE_Numero AS  CHAR) AS F1_DOC   "+chr(13)//Número da Nota Fiscal de Entrada
	cQuery += " ,COM_CONFRE_Serie      AS F1_SERIE "+CHR(13)
	cQuery += " ,COM_CONFRE_Emissao    AS F1_EMISSAO "+CHR(13)
	//cQuery += " ,STG_COM_CONFRE_Tra_Codigo AS DBFORN "+CHR(13) 
	cQuery += " ,CAST(STG_COM_CONFRE_Tra_Codigo AS  CHAR) AS DBFORN "+chr(13)//Código da Entidade - Fornecedor
   //	cQuery += " ,STG_COM_CONFRE_Etr_Codigo AS DBENT "+CHR(13) 
   	cQuery += ",CAST(STG_COM_CONFRE_Etr_Codigo AS  CHAR) AS DBENT    "+chr(13)//Endereço da Entidade - Fornecedor
	cQuery += " ,COM_CONFRE_Entrada    AS F1_DTDIGIT "+CHR(13)
	cQuery += " ,COM_CONFRE_TipoFrete  AS TPFRETE    "+CHR(13)
	//cQuery += " ,STG_GEN_TABCPG_Codigo     "
	//cQuery += " ,GEN_TABUSU_Login          "
	//cQuery += " ,STG_GEN_NATOPE_Codigo AS NATOP    "+CHR(13)
	cQuery += " ,COM_CONFRE_Valor    AS F1_VALBRUT "+CHR(13)
	cQuery += " ,COM_CONFRE_Pedagio  AS F1_VALPEDG "+CHR(13)
	cQuery += " ,COM_CONFRE_BICMS    AS F1_BASEICM "+CHR(13)
	cQuery += " ,COM_CONFRE_ICMS     AS F1_VALICM  "+CHR(13)
	cQuery += " ,COM_CONFRE_AICMS    AS D1_PICM     "+CHR(13)
	cQuery += " ,COM_CONFRE_OICMS    AS OICMS      "+CHR(13)
	cQuery += " ,COM_CONFRE_IICMS    AS IICMS      "+CHR(13)
	//cQuery += " ,COM_CONFRE_Placa          "
	//cQuery += " ,STG_GEN_TABORG_Codigo     "
	//cQuery += " ,COM_CONFRE_Created        "
	//cQuery += " ,COM_CONFRE_Updated        "
	//cQuery += " ,COM_CONFRE_AltFinanc      "
	//cQuery += " ,COM_CONFRE_Atualizado     "
	//cQuery += " ,COM_CONFRE_IDFiscal       "
	//cQuery += " ,COM_CONFRE_IDContabil     "
	//cQuery += " ,STG_GEN_TABMOD_Codigo     "
	cQuery += " ,STG_GEN_TABESP_Codigo  AS F1_ESPECIE "+CHR(13)
	cQuery += " ,COM_CONFRE_ChaveCTe    AS F1_CHVNFE   "+CHR(13)
	//cQuery += " ,STG_GEN_TIPPAG_Codigo     "
	//cQuery += " ,COM_CONFRE_DHIntTotvs     "
	//cQuery += " ,COM_CONFRE_IntContabilAlt "
	cQuery += " ,COM_CONFRE_ValorCOFINS  AS F1_VALCOFI  "+CHR(13)
	cQuery += " ,COM_CONFRE_ValorPIS   	 AS F1_VALPIS   "+CHR(13)
	cQuery += " ,COM_CONFRE_AliqCOFINS   AS AliqCOF "+CHR(13)
	cQuery += " ,COM_CONFRE_AliqPIS      AS AliqPIS  "+CHR(13)
	cQuery += " ,COM_CONFRE_BaseCOFINS   AS F1_BASCOFI "+CHR(13)
	cQuery += " ,COM_CONFRE_BasePIS      AS F1_BASPIS "+CHR(13)
	cQuery += " ,COM_CONFRE_CSTCOFINS    AS CSTCOF   "+CHR(13)
	cQuery += " ,COM_CONFRE_CSTPIS       AS CSTPIS   "+CHR(13)
	cQuery += " ,COM_CONFRE_CC           AS D1_CC "
	cQuery += " FROM COM_CONFRE            "	+CHR(13)
   	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON   GEN_TABENT_CODIGO = STG_COM_CONFRE_Tra_Codigo "+CHR(13)
   	cQuery += " AND STG_COM_CONFRE_Etr_Codigo   = GEN_ENDENT_Codigo "+CHR(13)
   	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON STG_GEN_NATOPE_Codigo = GEN_NATOPE_Codigo  "+chr(13)
   	cQuery += " AND STG_COM_CONFRE_Etr_Codigo = GEN_ENDENT_Codigo"+CHR(13)
	cQuery += " WHERE "
	cQuery += " COM_CONFRE_DHIntTotvs IS NULL AND "+CHR(13)
	cQuery += "  STG_GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)        
	
	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0  
		cQuery += " AND  STG_GEN_TABFIL_Codigo = " + cValToChar(nFilOrigem)
    Endif          
    
    //Testes 

    //cQuery += " AND COM_CONFRE_Numero = 29526051 " //OK 
    //cQuery += " AND COM_CONFRE_Numero = 1787298 "  OK
    //cQuery += " AND COM_CONFRE_Numero = 1237091 "    OK
    //cQuery += " AND COM_CONFRE_Numero = 1188317 "
    //conout(cQuery)
	U_AGX635CN("DBG")    

	If Select(cCapaCTE) <> 0
		dbSelectArea(cCapaCTE)
		(cCapaCTE)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cCapaCTE)

Return(cCapaCTE)


//Grava dados do CTE
Static Function InserirCTE(cCapaCTE)

	Local lRegOK 	:= .T. 
	Local cFil   	:= '' 
	Local cContaCF  := ""
	//Local cCCPadrao := ""
	
	cENTouSAI := "E" //Variavel para controlar se é de nota de entrada ou saída
    	                  
 	U_AGX635CN("PRT") 

	//cCCPadrao := GetCCFil(cEmpant,cFilant)
	
	(cCapaCTE)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cCapaCTE)->(!eof())

		SA2->(DbSetOrder(3))
		SA2->(DbGoTop())
		If !SA2->(DbSeek(xFilial("SA2")+(cCapaCTE)->(CNPJ_CPF)))
			              
			//Inclui fornecedor  
	   		cContaCF  := U_AGX635CF((cCapaCTE)->(CNPJ_CPF),'SA2')
			
			lRegOK := .F. 
								// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
		  
			
				DBSELECTAREA('SA2') 
	 			SA2->(DbGoTop())
				SA2->(DbSetOrder(3))
	 			SA2->(DbSeek(xFilial("SA2")+(cAliasCapa)->(CNPJ_CPF)))
   			If alltrim(SA2->A2_CONTA) == ''  .or. alltrim(cContaCF) == "" 
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Fornecedor sem conta: '+(cAliasCapa)->(CNPJ_CPF)+'('+alltrim(SA2->A2_NOME)+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SA2'},; 
						{'ZDB_INDICE' ,3},; 
						{'ZDB_TIPOWF' ,8},; 
						{'ZDB_CHAVE'  ,(cAliasCapa)->(CNPJ_CPF)};
						})     
						  
				(cCapaCTE)->(dbskip()) 
				LOOP  
			Endif
		Endif
		
		
		//Valida preenchimento de conta
		//Posteriormente será incluído automáticamente
		If alltrim(SA2->A2_CONTA) == ''      
		
				If !lReproc
						  
			   		//GRAVA Array de LOG
        			AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Fornecedor sem conta:'+(cCapaCTE)->(CNPJ_CPF)+'('+alltrim(SA2->A2_NOME)+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cCapaCTE)->(F1_DOC))+'+'+alltrim((cCapaCTE)->(F1_SERIE))+'+'+alltrim((cCapaCTE)->(DBFORN))+'+'+alltrim((cCapaCTE)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SA2'},; 
						{'ZDB_INDICE' ,3},; 
						{'ZDB_TIPOWF' ,1},; 
						{'ZDB_CHAVE'  ,(cCapaCTE)->(CNPJ_CPF)};
						})   		  
				Else
					Alert('Fornecedor Nao Existe:'+(cCapaCTE)->(CNPJ_CPF))
				Endif	

			(cCapaCTE)->(dbskip()) 		
			LOOP  
		Endif
		          
		aTam    := {}
		aTam    := TamSX3("F1_DOC")
		_cDoc   := PADL(alltrim((cCapaCTE)->(F1_DOC)),aTam[1],'0')
        
        aTam    := {}
		aTam    := TamSX3("F1_SERIE")	
        _cSerie := PADR(alltrim((cCapaCTE)->(F1_SERIE)),aTam[1],' ') 
        
		lErroFrete := .F.

		//Verifica se já existe no Protheus
		dbselectarea('SF1')
		dbsetorder(1)
		If dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA) 

			// Chamado 413146 - Provisório até resolver questão de Frete sem Nota
			If alltrim(SF1->F1_ORIIMP) == ''
				(cCapaCTE)->(dbskip()) 
				LOOP  
			Endif 

	   										// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
			Conout('AGX635CE - Já Existe no Protheus: '+xfilial('SF1')+' '+_cDoc+' '+_cSerie+' '+SA2->A2_COD+' '+SA2->A2_LOJA)
			// Verifica se título já foi baixado no Protheus,
	   		// Se ainda nao foi baixado,exclui para gerar novamente, 
	   		// Senão Gera Log 
	   		If U_AGX635JB((cCapaCTE)->(F1_VALBRUT))	
			
				If !lReproc
					//GRAVA Array de LOG
	        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)},;
						{'ZDB_MSG'	  ,'CTE com Tit.Baixado com Valor Diferente:: '+_cDoc+'-'+_cSerie+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cCapaCTE)->(F1_DOC))+'+'+alltrim((cCapaCTE)->(F1_SERIE))+'+'+alltrim((cCapaCTE)->(DBFORN))+'+'+alltrim((cCapaCTE)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1},; 
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
						})   		
 
				Else	
					Alert('CTE ja Existe: '+SF1->F1_DOC+SF1->F1_SERIE+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')')
				Endif
				
				(cCapaCTE)->(dbskip()) 
				LOOP 
			Endif
	 	Endif          
	 	                                                                                                                            
		cFil := xFilial('SF1')//STRZERO((cCapaCTE)->(DBFIL),2) 
		
		cEspecie := ""  
		If alltrim((cCapaCTE)->F1_ESPECIE) == 'NFE'
			cEspecie := "SPED"
		Else
			cEspecie := alltrim((cCapaCTE)->F1_ESPECIE)
		Endif
		    
		DbSelectArea( "SX5" )
   		DbSetOrder(1)
		IF !(DbSeek( xFilial( "SX5" ) + "42" + cEspecie )) 
			
			If !lReproc

				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,'Natureza Invalida: '+cEspecie},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cCapaCTE)->(F1_DOC))+'+'+alltrim((cCapaCTE)->(F1_SERIE))+'+'+alltrim((cCapaCTE)->(DBFORN))+'+'+alltrim((cCapaCTE)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SX5'},; 
						{'ZDB_INDICE' ,1},;  
						{'ZDB_TIPOWF' ,5},;
						{'ZDB_CHAVE'  , "42" + cEspecie};
						})   
		 	Else
		   		Alert('Natureza Invalida: '+cEspecie)
		 	Endif
		 	(cCapaCTE)->(dbskip()) 
			LOOP 
		Endif   
		
		conout('Inserindo CTE '+cEmpant+'/'+cfilAnt+' - '+_cDoc+' - '+time()) 
		
		//Busca se a nf é de entrada ou saída
   		cENTouSAI := ENTouSAI() 	  
   	
	    If  cENTouSAI == 'E'
	    
			//Inicia a Transação
			BEGIN TRANSACTION //Begintran()	 
		         
		        ddataOLD  :=   dDatabase
				dDatabase := (cCapaCTE)->(F1_DTDIGIT)
		        //conout(dDatabase)
		
				//Cria cabeçalho do CTE
				aCabec116 := {}       
				aAdd(aCabec116,{"",dDataBase-365})       												// Data inicial para filtro das notas
				aAdd(aCabec116,{"",date()})          												// Data final para filtro das notas
				aAdd(aCabec116,{"",2})                  												// 2-Inclusao ; 1=Exclusao
				aAdd(aCabec116,{"REMETENTE",""/*SA2->A2_COD*/})							   				// Rementente das notas contidas no conhecimento
				aAdd(aCabec116,{"LOJAREM",""/*SA2->A2_LOJA*/})									  		// Loja do remetente das notas contidas no conhecimento
				aAdd(aCabec116,{"TIPO","1" })  								   							// Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
				aAdd(aCabec116,{"",2})                  												// 1=Aglutina itens ; 2=Nao aglutina itens
				aAdd(aCabec116,{"F1_EST",""})  		  													// UF das notas contidas no conhecimento
				aAdd(aCabec116,{"",(cCapaCTE)->(F1_VALBRUT)}) 											// Valor do conhecimento
				aAdd(aCabec116,{"F1_FORMUL",1})															// Formulario proprio: 1=Nao ; 2=Sim
				aAdd(aCabec116,{"F1_DOC",_cDoc  })							   			    	 		// Numero da nota de conhecimento
				aAdd(aCabec116,{"F1_SERIE",(cCapaCTE)->(F1_SERIE) })							   		// Serie da nota de conhecimento
				aAdd(aCabec116,{"F1_FORNECE",SA2->A2_COD}) 		 										// Fornecedor da nota de conhecimento
				aAdd(aCabec116,{"F1_LOJA",SA2->A2_LOJA})												// Loja do fornecedor da nota de conhecimento
				aAdd(aCabec116,{"",(cCapaCTE)->(D1_TES)})												// TES a ser utilizada nos itens do conhecimento
				aAdd(aCabec116,{"F1_BASEICM",0/*(cCapaCTE)->(F1_BASEICM)*/})						   			// Valor da base de calculo do ICMS retido
				aAdd(aCabec116,{"F1_VALICM",0/*(cCapaCTE)->(F1_VALICM)*/})							 		// Valor do ICMS retido
				aAdd(aCabec116,{"F1_COND",'001'})										 		   		// Condicao de pagamento
				aAdd(aCabec116,{"F1_EMISSAO",(cCapaCTE)->(F1_EMISSAO)}) 						 		// Data de emissao do conhecimento
				aAdd(aCabec116,{"F1_ESPECIE",cEspecie})		
				aAdd(aCabec116,{"F1_CHVNFE",(cCapaCTE)->(F1_CHVNFE)}) 
				aAdd(aCabec116,{"F1_DTDIGIT",(cCapaCTE)->(F1_DTDIGIT)})   
				aAdd(aCabec116,{"F1_ORIIMP","AGX635CE"}) 
				aAdd(aCabec116,{"F1_TPCTE","N"}) 
				
				aAdd(aCabec116,{"F1_BFCPANT",0}) 
				aAdd(aCabec116,{"F1_VFCPANT",0}) 
				aAdd(aCabec116,{"F1_BASFECP",0}) 
				aAdd(aCabec116,{"F1_BSFCPST",0}) 
				aAdd(aCabec116,{"F1_BSFCCMP",0})  
			    aItens116 := {}                      
			     
			    //conout('aCabec116') 
				//conout(_cDoc) 
				//conout((cCapaCTE)->(F1_SERIE)) 
				//conout(SA2->A2_COD )      
				//conout(SA2->A2_LOJA ) 
				//conout((cCapaCTE)->(F1_CHVNFE))

				//For i := 1 to len(aCabec116)
				//	conout(i)
				//	conout(aCabec116[i][1]) 
				//	conout(aCabec116[i][2])
				//Next i
			
				//Insere produtos referentes a Nota Fiscal
				lOkNfe := InserirNfe(_cDoc,(cCapaCTE)->(F1_SERIE),SA2->A2_COD,SA2->A2_LOJA )  
			    dDatabase := ddataOLD 
				// Se inseriu corretamente o produto, Grava Array de Atualização dos dados,Senão desarma a Transação
				If lOkNfe   		
								//Empresa           ,  Filial          , Documento     , Serie               , Fornece			  , Loja                           
					AADD(aIntCAPA,{(cCapaCTE)->DBEMP, (cCapaCTE)->DBFIL, (cCapaCTE)->F1_DOC,(cCapaCTE)->F1_SERIE , (cCapaCTE)->DBFORN , (cCapaCTE)->DBENT  })
				Else
					DisarmTransaction()//Faz rollBack da transação
				Endif        
			
				//Destrava todas as conexões
		 		MsUnlockAll() 
		   	 
		   	END TRANSACTION //EndTran() //Finaliza Transação  
		Endif 

		If  cENTouSAI == 'S' //Cte de Entrada + NF de Saída

			//Ajusta produto de acordo com o Tipo 
			If (cCapaCTE)->(TPFRETE) = 'U'//Subcontratado
				cProduto := 'DES52111102'
			Else
				cProduto := 'DES52111101'
			Endif 
		
			//Captura dados da Empresa, posicao 22 é UF  
			aArrayEmp := FWArrFilAtu()
			cUFEmp    := substr( alltrim(aArrayEmp[22]) ,  len(alltrim(aArrayEmp[22]))-1,  len(alltrim(aArrayEmp[22]) )) 
			cUFForn   := SA2->A2_EST
			
			BEGIN TRANSACTION     
			
				Reclock('SF1',.T.)  
					SF1->F1_FILIAL  := xFilial('SF1')
					SF1->F1_DOC     := _cDoc//",_cDoc  })							   			    	 		// Numero da nota de conhecimento
					SF1->F1_SERIE   := (cCapaCTE)->(F1_SERIE)//",(cCapaCTE)->(F1_SERIE) })							   		// Serie da nota de conhecimento
					SF1->F1_FORNECE := SA2->A2_COD//",SA2->A2_COD}) 		 										// Fornecedor da nota de conhecimento
					SF1->F1_LOJA    := SA2->A2_LOJA//",SA2->A2_LOJA})												// Loja do fornecedor da nota de conhecimento
					SF1->F1_COND    := '001'//",'001'})	
					SF1->F1_DUPL    := _cDoc 
					SF1->F1_PREFIXO := SUBSTR(ALLTRIM( (cCapaCTE)->(F1_SERIE) ),1,3)
					SF1->F1_EMISSAO := (cCapaCTE)->(F1_EMISSAO)//",(cCapaCTE)->(F1_EMISSAO)}) 						 		// Data de emissao do conhecimento
					SF1->F1_EST     := SA2->A2_EST   
					SF1->F1_VALMERC := (cCapaCTE)->(F1_VALBRUT)
					SF1->F1_VALBRUT := (cCapaCTE)->(F1_VALBRUT)
					SF1->F1_DTDIGIT := (cCapaCTE)->(F1_DTDIGIT)
					SF1->F1_RECBMTO := (cCapaCTE)->(F1_DTDIGIT)					
					SF1->F1_BASEICM := (cCapaCTE)->(F1_BASEICM)//",(cCapaCTE)->(F1_BASEICM)})						   			// Valor da base de calculo do ICMS retido
					SF1->F1_VALICM  := (cCapaCTE)->(F1_VALICM)//",(cCapaCTE)->(F1_VALICM)})
					SF1->F1_TIPO    := 'N'	 
					SF1->F1_ESPECIE := cEspecie
					SF1->F1_CHVNFE  := (cCapaCTE)->(F1_CHVNFE)//",(cCapaCTE)->(F1_CHVNFE)}) 
					SF1->F1_ORIIMP  := "AGX635CE"//","AGX635CE"}) 
					SF1->F1_TPCTE   := "N" 
					SF1->F1_STATUS  := "A" 					
			    SF1->(MsUnlock())  
			    
			    dbselectarea('SF4')
				dbsetorder(1)
				dbseek(xfilial('SF4')+alltrim((cCapaCTE)->(D1_TES))) 
				
		    	dbselectarea('SB1')
				dbsetorder(1) 	
			    dbseek(xfilial('SB1')+cProduto ) 
			    
			    BEGIN TRANSACTION        
			    Reclock('SD1',.T.)
			    	SD1->D1_FILIAL  := SF1->F1_FILIAL 
			    	SD1->D1_ITEM    := '0001' 
			    	SD1->D1_COD     := cProduto//'DES52111101' 
					if !(alltrim(cEmpant) $ '50/03')
						SD1->D1_DESCRI  := SB1->B1_DESC
			    	Endif
					SD1->D1_UM      := SB1->B1_UM
			    	SD1->D1_QUANT   := 1 
			    	SD1->D1_VUNIT   := SF1->F1_VALMERC
			    	SD1->D1_TOTAL   := SF1->F1_VALBRUT
			    	SD1->D1_BASEICM := SF1->F1_BASEICM  
			    	SD1->D1_VALICM  := SF1->F1_VALICM
					SD1->D1_PICM	:= (cCapaCTE)->(D1_PICM)	
			    	SD1->D1_TES     := (cCapaCTE)->(D1_TES)
			    	cCFOP := SF4->F4_CF
					If alltrim(cUFEmp) <> alltrim(cUFForn)  
						cCFOP := '2'+substr(alltrim(SF4->F4_CF),2,3) 
					Endif   
			    	SD1->D1_CF      := cCFOP 
			    	SD1->D1_FORNECE := SF1->F1_FORNECE
					SD1->D1_LOJA    := SF1->F1_LOJA
			    	SD1->D1_DOC 	:= SF1->F1_DOC 
					SD1->D1_SERIE   := SF1->F1_SERIE
			    	SD1->D1_EMISSAO := SF1->F1_EMISSAO   
			    	SD1->D1_CONTA   := SB1->B1_CONTA 
			    	SD1->D1_RATEIO  := '2' 
			    	SD1->D1_CODISS  := SB1->B1_CODISS
			    	SD1->D1_LOCAL   := SB1->B1_LOCPAD
			    	SD1->D1_DTDIGIT := SF1->F1_DTDIGIT	
			    	SD1->D1_TP      := SB1->B1_TIPO	
			    	SD1->D1_TIPO    := 'N'
					SD1->D1_ORIIMP  := 'AGX635CE'

					iF Val( (cCapaCTE)->D1_CC ) > 0 
			    		SD1->D1_CC     := alltrim(str(val( (cCapaCTE)->D1_CC ) ) ) 
					//Else
					//	SD1->D1_CC     := cCCPadrao//GetCCFil(SD1->D1_FILIAL)
					Endif 
			    
			    SD1->(MsUnlock())
			    
			    END TRANSACTION 
		
				ProcCP(dDatabase) 
			    
						
				MsUnlockAll()
				
			END TRANSACTION 
			
			AADD(aIntCAPA,{(cCapaCTE)->DBEMP, (cCapaCTE)->DBFIL, (cCapaCTE)->F1_DOC,(cCapaCTE)->F1_SERIE , (cCapaCTE)->DBFORN , (cCapaCTE)->DBENT  })
			ReprocSF1(SF1->F1_EMISSAO, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_FILIAL)   
			
		Endif
		
		(cCapaCTE)->(dbskip())  
	Enddo	                         
	
   // MARCA DATA/HORA PARA IDENTIFICAR QUE REGISTRO FOI IMPORTADOS 
    If Len(aIntCAPA) > 0 
		BaixarCTE(aIntCAPA)
		aIntCAPA := {} 
    Endif 
Return()
        
//Cria Arquivo de dados
Static Function CriaArqCE(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0
	//Local oTmpTable    := Nil

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectCTE(nEmpOrigem,nFilOrigem)

	aStruTmp := (cAliasQry)->(DbStruct())
	
	/*oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aStruTmp)
	oTmpTable:AddIndex("1", {aStruTmp[1][1]})
	oTmpTable:Create()*/

	cAliasArea := "CriaArqCE"//GetNextAlias()
	cArquivo := CriaTrab(,.F.)
	dbCreate(cArquivo,aStruTmp)
	dbUseArea(.T.,__LocalDriver,cArquivo,cAliasArea,.F.,.F.)
	//cAliasArea := oTmpTable:GetAlias()

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

Return(cAliasArea)            

//Inserir Arquivo de Trabalho
Static Function InserirNfe(xDocCab,xSerCab,xFornCab,xLojaCab)

	Local cAliasNFE := "InserirNfe"//GetNextAlias()
	Local cQuery      := "" 
	Local lRegOK      := .T.  
	Local _cTipoNF    := ""
	Local _i          := 0
	Local lGerouReg   := .F.
	
	//NOTAS REFERENTES AO CTE 
	cQuery := " SELECT " 
	cQuery += " STG_GEN_TABEMP_Codigo	   AS  DBEMP   "
	cQuery += " ,STG_GEN_TABFIL_Codigo     AS  DBFIL  "  
	cQuery += " ,ENDENT.GEN_ENDENT_IF 	   AS CNPJ_CPF  "
	//cQuery += " ,COM_CONFRE_Numero         AS F1_DOCTE   "
	cQuery += ",CAST(COM_CONFRE_Numero AS  CHAR) AS F1_DOCTE   "+chr(13)//Número do CTE
	cQuery += " ,COM_CONFRE_Serie          AS F1_SERCTE "
	cQuery += " ,COM_CONFRE_Emissao        AS F1_EMISCTE  "
	//cQuery += " ,STG_COM_CONFRE_Tra_Codigo AS DBFORN "  
	cQuery += " ,CAST(STG_COM_CONFRE_Tra_Codigo AS  CHAR) AS DBFORN "+chr(13)//Código da Entidade - Fornecedor
	//cQuery += " ,STG_COM_CONFRE_Etr_Codigo AS DBENT " 
	cQuery += ",CAST(STG_COM_CONFRE_Etr_Codigo AS  CHAR) AS DBENT    "+chr(13)//Endereço da Entidade - Fornecedor
	//cQuery += " ,COM_NOTCOM_Numero         AS F1_DOC " 
	cQuery += ",CAST(COM_NOTCOM_Numero AS  CHAR) AS F1_DOC "+chr(13)//Número da Nota Fiscal de Entrada
	cQuery += " ,COM_NOTCOM_Serie          AS F1_SERIE "
	cQuery += " ,COM_NOTCOM_Emissao        AS F1_EMISSAO "
	//cQuery += " ,STG_GEN_TABENT_For_Codigo  "
	//cQuery += " ,STG_GEN_ENDENT_For_Codigo  "
	//cQuery += " ,COM_ENTFRE_Created         "
	//cQuery += " ,COM_ENTFRE_Updated         "
	cQuery += " FROM COM_ENTFRE             " 
	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON   GEN_TABENT_CODIGO = STG_GEN_TABENT_For_Codigo "
	cQuery += " AND STG_GEN_ENDENT_For_Codigo = GEN_ENDENT_Codigo "
	//cQuery += " WHERE COM_CONFRE_DHIntTotvs IS NULL "
	//cQuery += " AND  STG_GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)        
	cQuery += " WHERE " 
	//cQuery += " COM_CONFRE_DHIntTotvs IS NULL "                         
	cQuery += " STG_GEN_TABEMP_Codigo = "+alltrim(str((cCapaCTE)->(DBEMP)))
	cQuery += " AND STG_GEN_TABFIL_Codigo = "+alltrim(str((cCapaCTE)->(DBFIL))) 
	cQuery += " AND COM_CONFRE_Numero     = "+(cCapaCTE)->(F1_DOC)
	cQuery += " AND COM_CONFRE_Serie      = '"+(cCapaCTE)->(F1_SERIE)+"'"
	//cQuery += " AND COM_CONFRE_Emissao    = "+(cCapaCTE)->(F1_EMISSAO)
	cQuery += " AND STG_COM_CONFRE_Tra_Codigo = "+(cCapaCTE)->(DBFORN)
	cQuery += " AND STG_COM_CONFRE_Etr_Codigo = "+(cCapaCTE)->(DBENT)  
	 
	//conout(cQuery)
	U_AGX635CN("DBG")    
	
	If Select(cAliasNFE) <> 0
		dbSelectArea(cAliasNFE)
		(cAliasNFE)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAliasNFE)  
	        	
	U_AGX635CN("PRT")	
	
	cFil := xFilial('SF1') 
	
	lRegOK := .T.      
	
	(cAliasNFE)->(dbgotop())
	While (cAliasNFE)->(!eof())  
		  
		 lGerouReg := .T. 
		    
	    //** Valida campo TES no dbGint 
	    If Empty( (cCapaCTE)->(D1_TES))
			
			If !lReproc

				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,'DOC: '+(cCapaCTE)->(F1_DOC)+'-'+(cCapaCTE)->(F1_SERIE)+', Natureza sem TES cadastrada: '+(cCapaCTE)->(NATOPER)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cCapaCTE)->(NATOPER)},; 
						{'ZDB_TAB' 	  ,'SF4'},; 
						{'ZDB_INDICE' ,1},;   
						{'ZDB_TIPOWF' ,6},;
						{'ZDB_CHAVE'  , (cCapaCTE)->(D1_TES)};
						})      
			Else
				Alert('Natureza sem TES cadastrada: '+(cCapaCTE)->(NATOPER))
			Endif	 
	   
	   		(cAliasNFE)->(dbskip()) 
			Return  .F. 
	    Endif              
	    
	    //** Valida se TES Existe
	    dbselectarea('SF4')
		dbsetorder(1)
		If !dbseek(xfilial('SF4')+alltrim((cCapaCTE)->(D1_TES)))  	
						   		// {'ZDB_EMP'              ,'ZDB_FIL'              ,'ZDB_MSG'          ,'ZDB_DATA','ZDB_HORA'}  
			If !lReproc
					
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,	'TES não cadastrada: :'+alltrim((cCapaCTE)->(D1_TES)),},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cCapaCTE)->(NATOPER)},; 
						{'ZDB_TAB' 	  ,'SF4'},;  
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_INDICE' ,1},; 
						{'ZDB_CHAVE'  , (cCapaCTE)->(D1_TES)};
						})  
			Else
				Alert('TES invalida:'+alltrim((cCapaCTE)->(D1_TES)))
			Endif
				 	
			Return  .F.   
		Endif 
		
		//** Valida se fornecedor Existe		
		SA2->(DbSetOrder(3))
		SA2->(DbGoTop())
		If !SA2->(DbSeek(xFilial("SA2")+(cAliasNFE)->(CNPJ_CPF)))
			
			lRegOK := .F. 
								// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
			If !lReproc

				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,'Fornecedor Nao Existe:'+(cAliasNFE)->(CNPJ_CPF),},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cAliasNFE)->(F1_DOC)+'+'+(cAliasNFE)->(F1_SERIE)+'+'+(cAliasNFE)->(DBFORN)+'+'+(cCapaCTE)->(DBENT)},; 
						{'ZDB_TAB' 	  ,'SA2'},; 
						{'ZDB_INDICE' ,3},; 
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  , (cAliasNFE)->(CNPJ_CPF)};
						})     
			Else
				Alert('Fornecedor Nao Existe:'+(cAliasNFE)->(CNPJ_CPF))
			Endif	
						  
			(cAliasNFE)->(dbskip()) 
			Return  .F.  
		Endif
		 
		//** Adequa Campo Doc e Serie         
		aTam    := {};aTam    := TamSX3("F1_DOC");     _cDoc2   := PADL(alltrim((cAliasNFE)->(F1_DOC)),aTam[1],'0')     
        _cSerie2 := PADR(alltrim((cAliasNFE)->(F1_SERIE)),3,' ') 

		//CONOUT('DOCUMENTO DO CTE')     
		//CONOUT(xfilial('SF1')+_cDoc2+_cSerie2+SA2->A2_COD+SA2->A2_LOJA)

        //CONOUT('604TESTE '+xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)	                 
		//** Valida Se existe o Documento no Protheus,
		//Caso exista Grava Array com Itens
		dbselectarea('SF1')
		dbsetorder(1)
		If dbseek(xfilial('SF1')+_cDoc2+_cSerie2+SA2->A2_COD+SA2->A2_LOJA) 
			//CONOUT(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
			_cTipoNF := SF1->F1_TIPO 				
			AAdd(aItens116, {{"PRIMARYKEY", SubStr(SF1->&(IndexKey()), FWSizeFilial() + 1)}})  
		    //CONOUT('aItens116'); CONOUT(SubStr(SF1->&(IndexKey()), FWSizeFilial() + 1))
		Else 
			lRegOK := .F. 
								// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
			If !lReproc

				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,'Nota Entrada Nao Existe: '+_cDoc2+'-'+_cSerie2},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,_cDoc2+'+'+_cSerie2+'+'+alltrim((cCapaCTE)->(DBFORN))+'+'+alltrim((cCapaCTE)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1	},; 
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  , _cDoc2+_cSerie2+SA2->A2_COD+SA2->A2_LOJA};
						})    
			Else
				Alert('Nota Entrada Nao Existe: '+_cDoc2+_cSerie2)
			Endif	
						  
			(cAliasNFE)->(dbskip()) 
			Return  .F.   	
		Endif  
	
		(cAliasNFE)->(dbskip())
	Enddo   
	 
	//Se Não deu erro.       
	If lRegOK  .and. len(aItens116) > 0  .and. len(aCabec116) > 0  	    
		For _i := 1 to len(aCabec116)
	   		If alltrim(aCabec116 [_i][1]) == "REMETENTE"
	   			aCabec116 [_i][2] := SA2->A2_COD							   				// Rementente das notas contidas no conhecimento
	   	        //aCabec116 [_i][1] := ""
	   	    Elseif alltrim(aCabec116 [_i][1]) == "LOJAREM"
	   			aCabec116 [_i][2] := SA2->A2_LOJA									  		// Loja do remetente das notas contidas no conhecimento
	   			//aCabec116 [_i][1] := ""
	   		Elseif alltrim(	aCabec116 [_i][1]) == "TIPO"	
	   	   		aCabec116 [_i][2] := iif(_cTipoNF == 'N' .OR. alltrim(_cTipoNF) == '',1,2)	// Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef 
	   			//aCabec116 [_i][1] := ""                                        	
	   		Elseif alltrim(	aCabec116 [_i][1]) == "F1_EST"
	   			aCabec116 [_i][2] := SA2->A2_EST				 				   			// Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef 
	   			//aCabec116 [_i][1] := ""
	   		Endif	
	   		
	   		//conout('Campos dos itens')
	   		//conout(aCabec116 [_i][1])  
	   		//conout(aCabec116 [_i][2])
	   	Next _i 
	   
	   	lMsErroAuto := .F.   
		conout('AGX635CE - MSEXECAUTO' )
	   	conout(xDocCab+'-'+xSerCab+'-'+xFornCab+'-'+xLojaCab) 
	   	VerifSF8(xDocCab,xSerCab,xFornCab,xLojaCab) 
	   	MsExecAuto({|x,y| MATA116(x,y)},aCabec116,aItens116)
	   
	   	SF1->(dbClearFilter())
	    ddatabase := ddataOLD 
	   
	   	if lMsErroAuto

			If (!IsBlind()) // COM INTERFACE GRÁFICA
        		MostraErro()
    		Else // EM ESTADO DE JOB
        		cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERROR
        		ConOut("Error: "+ cError)
    		EndIf  

			nPosErro := 0 
			cMsgErro := ""
			cPesq 	 := "Error:"
  			nPosErro := AT( UPPER(cPesq), UPPER(cError) )			

			If nPosErro == 0 
				cPesq 	 := "AJUDA:"
  				nPosErro := AT( UPPER(cPesq), UPPER(cError) )			
			Endif 
			cMsgErro := 'Erro MATA116: '+(cCapaCTE)->(F1_DOC)+'-'+(cCapaCTE)->(F1_SERIE)+;	
			Iif(nPosErro == 0," Verifique se estoque está aberto e Doc contido no Cte esta lancado.",Substr(cError,nPosErro,60) )


			//GRAVA Array de LOG
        	AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,	cMsgErro},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,""},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1	},; 
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  , (cCapaCTE)->(F1_DOC)+(cCapaCTE)->(F1_SERIE)+SA2->A2_COD+SA2->A2_LOJA};
						})
			conout('AGX635CE - Erro MATA116:')		  
			lRegOK := .F.       
			
		Else                                                           

		    //Gravação da origem da importação  
		    dbselectarea('SF1')
			SF1->(dbsetorder(1));SF1->(DbGoTop())
			If SF1->(dbseek(xfilial('SF1')+xDocCab+xSerCab+xFornCab+xLojaCab/*_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA*/))   
				Reclock('SF1',.F.)
		    		SF1->F1_ORIIMP := 'AGX635CE'
		    	SF1->(Msunlock())
		    Else
		     		//GRAVA Array de LOG
        	  		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,	'Erro MATA116: '+alltrim((cCapaCTE)->(F1_DOC))+'-'+alltrim((cCapaCTE)->(F1_SERIE))+" Verifique se a Nota do CTE possui CC!"},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,""},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1	},;  
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  , alltrim((cCapaCTE)->(F1_DOC))+alltrim((cCapaCTE)->(F1_SERIE))+SA2->A2_COD+SA2->A2_LOJA};
						}) 
					lRegOK := .F. 
		    Endif   
		                     		    
			//Insere Título a pagar 
			If lRegOK
	   			ProcCP(dDatabase)
		    Endif
		Endif
	   									   							
	Endif
	 
	//Cte se notas
	If !lGerouReg
		cENTouSAI := 'S'
		
		//GRAVA Array de LOG
    	/*AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,'Cte não contém NF: '+_cDoc+_cSerie},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie+'+'+(cCapaCTE)->(DBFORN)+'+'+(cCapaCTE)->(DBENT)},; 
			{'ZDB_TAB' 	  ,'SF1'},; 
			{'ZDB_INDICE' ,1	},;
			{'ZDB_TIPOWF' ,8},;  
			{'ZDB_CHAVE'  , _cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
			})    
		*/	 
		lRegOK := .F.   
	Endif
	
	
Return lRegOK     


//*********************
//   Contas a Pagar 
//*********************
Static Function ProcCP(xDtDigit)  

	Local lRet      := .F.
	Local _aCabec   := {}
	Local cPrefixo  := ""   
	
	Local cAliasSE2 := "AGX635SE2F"
	Local cQuery     := ""

	cQuery := "SELECT "
	cQuery += "STG_GEN_TABEMP_Codigo AS DBEMP"
	cQuery += ",STG_GEN_TABFIL_Codigo AS DBFIL "
	cQuery += ",COM_CONFRE_Numero AS E2_NUM "
	cQuery += ",COM_CONFRE_Serie AS E2_SERIE "
	cQuery += ",COM_CONFRE_Emissao AS E2_EMISSAO "
	cQuery += ",STG_COM_CONFRE_Tra_Codigo AS DBFORN	"
	cQuery += ",STG_COM_CONFRE_Etr_Codigo AS DBENT "
	cQuery += ",COM_FINFRE_Parcela AS E2_PARCELA"
	cQuery += ",CXB_TABBAN_Codigo AS CODBAN "
	cQuery += ",COM_FINFRE_Valor AS E2_VALOR "
	cQuery += ",COM_FINFRE_Vencimento AS E2_VENCTO "
  	cQuery += ",COM_FINFRE_Created as E2_EMIS1 "
	//	cQuery += ",COM_FINNOT_Updated "
	cQuery += "FROM COM_FINFRE "
	cQuery += "WHERE " 
	cQuery += "STG_GEN_TABEMP_Codigo     	  =  '"+alltrim(str((cCapaCTE)->DBEMP))+"' "+chr(13)
	cQuery += " AND STG_GEN_TABFIL_Codigo     =  '"+alltrim(str((cCapaCTE)->DBFIL))+"' "+chr(13)
	cQuery += " AND COM_CONFRE_Numero         =  '"+(cCapaCTE)->F1_DOC+"' "+chr(13)
	cQuery += " AND COM_CONFRE_Serie          =  '"+(cCapaCTE)->F1_SERIE+"' "+chr(13)
	cQuery += " AND STG_COM_CONFRE_Tra_Codigo =  '"+(cCapaCTE)->DBFORN+"' "+chr(13)
	cQuery += " AND STG_COM_CONFRE_Etr_Codigo =  '"+(cCapaCTE)->DBENT+"' "+chr(13)  
	//conout(cQuery)
	U_AGX635CN("DBG")    
	
	If Select(cAliasSE2) <> 0
		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAliasSE2)  
	        
	cFil := cFilant//STRZERO((cAliasSE2)->DBEMP,2) 
   
	U_AGX635CN("PRT")       
		
	//** Adequa Campo Doc e Serie         
	aTam    := {};aTam    := TamSX3("F1_DOC");     _cDoc   := PADL(alltrim((cCapaCTE)->(F1_DOC)),aTam[1],'0')     
    aTam    := {};aTam    := TamSX3("F1_SERIE")	;  _cSerie := PADR(alltrim((cCapaCTE)->(F1_SERIE)),aTam[1],' ') 
    
    //Posiciona fornecedor
   	SA2->(DbSetOrder(3))
	SA2->(DbGoTop())
	SA2->(DbSeek(xFilial("SA2")+(cCapaCTE)->(CNPJ_CPF)))
    
    //Posiciona no Documento    
    dbselectarea('SF1')
	SF1->(dbsetorder(1));SF1->(DbGoTop())
	SF1->(dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)) 
               
     lTitBaixad := .F.                                                                                             
	// Caso exista  Título Gerado e não esteja baixado, 
	// Exclui para gerar novamente  
	// AQUI RETORNAR
    dbselectarea('SE2')
    dbsetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO                                                                                               
    If dbseek(xfilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC)        
    	If Empty(SE2->E2_BAIXA)
     		Reclock('SE2',.F.)
       			dbdelete()
       		Msunlock() 
        Else
       		lTitBaixad := .T.
       	Endif
    Else 
       //Verifica se não havia gerado com prefixo errado
       If dbseek(xfilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+cFilAnt+SF1->F1_PREFIXO+SF1->F1_DOC)        
          	If Empty(SE2->E2_BAIXA)
          		Reclock('SE2',.F.)
          			dbdelete()
          		Msunlock() 
          	Else
          		lTitBaixad := .T.
          	Endif
    	Endif  
    Endif   
    //*/ 
    
    
    //Se Título já foi baixado
    If lTitBaixad
			 
		//GRAVA Array de LOG
    	AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cCapaCTE)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cCapaCTE)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,	'Título já baixado: '+SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie+'+'+alltrim((cCapaCTE)->(DBFORN))+'+'+alltrim((cCapaCTE)->(DBENT))},; 
			{'ZDB_TAB' 	  ,'SE2'},; 
			{'ZDB_INDICE' ,1	},; 
			{'ZDB_TIPOWF' ,4},; 
			{'ZDB_CHAVE'  , SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM};
			})  
			 Return .F.   
    Endif
	
	
	DbSelectArea(cAliasSE2)
	dbGotop()
	While (cAliasSE2)->(!eof())
	

		aTam     := {}
		aTam     := TamSX3("E2_NUM")
		cTitulo  := ""
		cTitulo  := SF1->F1_DOC//StrZero(MSE2->E2_NUM,aTam[1])
		cSerie   := ""
		cSerie   := substr(alltrim(SF1->F1_SERIE),1,3)        
		cForCod	 := SF1->F1_FORNECE
		cForLoja := SF1->F1_LOJA
		cForNome := POSICIONE('SA2',1,xfilial('SA2')+cForCod+cForLoja,'A2_NOME')

		cFilEnt  := SF1->F1_FILIAL
		cPrefixo := ""
		cPrefixo := SF1->F1_PREFIXO// cFilEnt + substr(cSerie,1,3)
		cParcela := alltrim(cValToChar((cAliasSE2)->E2_PARCELA)) //StrZero(MSE2->E2_PARCELA,3) 
		
		dEmissao := (cAliasSE2)->E2_EMISSAO
		dVencto  := (cAliasSE2)->E2_VENCTO
		dDtDigit := (cAliasSE2)->E2_EMIS1

		//Verifico se o titulo nao foi gerado anteriormente pela entrada do sistema
		cQuery := ""
		cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("SE2") + "(NOLOCK) "
		cQuery += " WHERE E2_PREFIXO = '" +cPrefixo + "' "
		//cQuery += "   AND (E2_NUM     = '" + cTitulo + "' OR E2_NUM = '"  + cTitulo6 + "') "
		cQuery += "   AND (E2_NUM     = '" + cTitulo + "') "
		cQuery += "   AND E2_TIPO    = 'NF' "
		cQuery += "   AND E2_FORNECE =  '" +  cForCod + "' "
		cQuery += "   AND E2_LOJA    = '" + cForLoja + "' "
		//cQuery += "   AND E2_PARCELA = '" + cParcela + "' "
		cQuery += "   AND E2_ORIGEM = 'MATA100' "
		cQuery += "   AND E2_ORIIMP = ''  "
		cQuery += "   AND D_E_L_E_T_ = ''  "

		If Select("QRYSE2") <> 0
			dbSelectArea("QRYSE2")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "QRYSE2"

		lTemTitulo := .f.
		dbSelectArea("QRYSE2")
		While !eof()
			lTemTitulo := .t.
			QRYSE2->(dbskip())
		EndDo

		If lTemTitulo == .t. //.OR. QRYSD1->R_E_C_N_O_ == 0
			//Conout("Titulo ->" + cPrefixo + "/" + cTitulo + " - Fornecedor: ->" + cForCod + " Loja->" + cForLoja + " - " + cForNome + " ja cadastrado!")
			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSkip())
			loop
		EndIf

		//Verifico se o titulos no contas a pagar nao esta cadastrado
		cQuery := ""
		cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("SE2") + " (NOLOCK)"
		cQuery += " WHERE E2_PREFIXO = '" +cPrefixo + "' "
		cQuery += "   AND (E2_NUM     = '" + cTitulo + "') "
		cQuery += "   AND E2_TIPO    = 'NF' "
		cQuery += "   AND E2_FORNECE =  '" + cForCod + "' "
		cQuery += "   AND E2_LOJA    = '" + cForLoja + "' "
		cQuery += "   AND E2_PARCELA = '" + cParcela + "' "
		cQuery += "   AND D_E_L_E_T_ <> '*'  "

		If Select("QRYSE2") <> 0
			dbSelectArea("QRYSE2")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "QRYSE2"

		lJaExiste := .f.
		dbSelectArea("QRYSE2")
		While !eof()
			lJaExiste := .t.
			QRYSE2->(dbskip())
		EndDo

		If lJaExiste == .t. //.OR. QRYSD1->R_E_C_N_O_ == 0
			//Conout("Titulo ->" + cPrefixo + "/" + cTitulo + " - Fornecedor: ->" + cForCod + " Loja->" + cForLoja + " - " + cForNome + " ja cadastrado!")
			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSkip())
			loop
			Return
		EndIf
        
// AQUI RETORNAR
		Begin Transaction
		RecLock("SE2",.T.)
			SE2->E2_PREFIXO		:= cPrefixo
			SE2->E2_NUM			:= cTitulo
			SE2->E2_PARCELA  	:= cParcela
			SE2->E2_FORNECE		:= cForCod
			SE2->E2_LOJA		:= cForLoja
			SE2->E2_NOMFOR		:= cForNome
			SE2->E2_EMISSAO  	:= dEmissao
			SE2->E2_VENCTO 		:= dVencto
			SE2->E2_VENCREA		:= DataValida(dVencto,.T.)
			SE2->E2_VALOR		:= (cAliasSE2)->E2_VALOR
			SE2->E2_EMIS1 		:= xDtDigit//STOD(cAliasSE2)->E2_EMIS1)
			//SE2->E2_HIST		:= MSE2->E2_HIST
			SE2->E2_LA			:= ""
			SE2->E2_SALDO		:= (cAliasSE2)->E2_VALOR
			SE2->E2_VALLIQ		:= (cAliasSE2)->E2_VALOR
			SE2->E2_VENCORI		:= dVencto
			SE2->E2_MOEDA		:= 1
			SE2->E2_VLCRUZ		:= (cAliasSE2)->E2_VALOR
			SE2->E2_ORIGEM		:= "MATA100"
			SE2->E2_TIPO 		:= "NF"
			SE2->E2_ORIIMP  	:= "AGX635CE"
			SE2->E2_FILORIG		:= cFilEnt
			
			//Se foi a Vista, Baixa Título
			//If dEmissao == dVencto
			//  	SE2->E2_BAIXA   := 	dEmissao 
			 // 	SE2->E2_SALDO   :=    0 
			 // 	SE2->E2_MOVIMEN :=  dEmissao
			//Endif     
		SE2->(MsUnLock())
		End Transaction 
       
       If dEmissao == dVencto// dDtDigit == dVencto    //Realizo baixa automatica se o titulo for a vista.

			//Marco parâmetro para não mostrar Lançamento em tela 
			aPergAux    := {}
			nBkpMV_PAR  := 0
			PergFIN080(@aPergAux)
			If MV_PAR01 <> 2
				nBkpMV_PAR  := MV_PAR01
				MV_PAR01 	:= 2
			Endif	
			__SaveParam("FIN080", aPergAux)

		   	lRet    := .F.
			_aCabec := {}
			Aadd(_aCabec, {"E2_FILIAL",   iif( cEmpant == '50', xFilial("SE2"),''),     Nil})
			Aadd(_aCabec, {"E2_PREFIXO",   cPrefixo,           Nil})
			Aadd(_aCabec, {"E2_NUM",       cTitulo,            Nil})
			Aadd(_aCabec, {"E2_PARCELA",   cParcela,           Nil})
			Aadd(_aCabec, {"E2_TIPO",      "NF ",              Nil})
			Aadd(_aCabec, {"E2_FORNECE",   cForCod,            Nil})
			Aadd(_aCabec, {"E2_LOJA",      cForLoja,           Nil})
			Aadd(_aCabec, {"AUTBANCO",     "CX1",              Nil})
			Aadd(_aCabec, {"AUTAGENCIA",   "00001",            Nil})
			Aadd(_aCabec, {"AUTCONTA",     "0000000001",       Nil})
			Aadd(_aCabec, {"AUTHIST",      'Baixa Automatica', Nil})//12 //'Baixa Automatica'
			Aadd(_aCabec, {"AUTDESCONT",   0,                  Nil})//13
			Aadd(_aCabec, {"AUTMULTA",     0,                  Nil})//14
			Aadd(_aCabec, {"AUTJUROS",     0,                  Nil})//15
			Aadd(_aCabec, {"AUTOUTGAS",    0,                  Nil})//16
			Aadd(_aCabec, {"AUTVLRPG",     0,                  Nil})//17
			Aadd(_aCabec, {"AUTVLRME",     0,                  Nil})//18
			Aadd(_aCabec, {"AUTCHEQUE",    "",                 Nil})//19
			Aadd(_aCabec, {"AUTTXMOEDA",   0,                  Nil})//20
			Aadd(_aCabec, {"AUTMOTBX",     "NOR",             Nil})
			Aadd(_aCabec, {"AUTDTBAIXA",   dDtDigit,  		   Nil})
			Aadd(_aCabec, {"AUTDTCREDITO", dDtDigit,   		   Nil})

			lMsErroAuto := .F.
			lRetExec := .F.
			RpcSettype(1)
		   	MSExecAuto({|x,y| fina080(x,y)},_aCabec, 3 )
			If lMsErroAuto
				CONOUT(' AGX635NE - ERRO FINA080')
				MOSTRAERRO()  
				AADD(aLogs,{;
							{'ZDB_DBEMP'  ,''},;
							{'ZDB_DBFIL'  ,''},;
							{'ZDB_MSG'	  ,'AGX635CE ERRO FINA080(TÍTULO À VISTA): '+cPrefixo+'-'+cTitulo},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,''},;
							{'ZDB_FILIAL' ,''},;
							{'ZDB_DBCHAV' ,''},; 
							{'ZDB_TAB' 	  ,''},; 
							{'ZDB_INDICE' ,1},;  
							{'ZDB_TIPOWF' ,8},; 
							{'ZDB_CHAVE'  ,''};
			   				})  
			Else
				//SUCESSO 
							AADD(aLogs,{;
							{'ZDB_DBEMP'  ,''},;
							{'ZDB_DBFIL'  ,''},;
							{'ZDB_MSG'	  ,'TÍTULO IMPORTADO À VISTA: '+cPrefixo+'-'+cTitulo},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,''},;
							{'ZDB_FILIAL' ,''},;
							{'ZDB_DBCHAV' ,''},; 
							{'ZDB_TAB' 	  ,''},; 
							{'ZDB_INDICE' ,1},;  
							{'ZDB_TIPOWF' ,7},; 
							{'ZDB_CHAVE'  ,''};
			   				})  
			
				CONOUT(' AGX635NE - SUCESSO FINA080')
				//lRet := .T.
			Endif

			//Volta parâmetro para seu estado original 
			If nBkpMV_PAR > 0 
				MV_PAR01 := nBkpMV_PAR
				__SaveParam("FIN080", aPergAux)
			Endif
		  	
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
	
		EndIf         
		//*/
		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbskip())
	EndDo

Return()
	
Static Function BaixarCTE(xIntCapa)

	Local cCTEIN   := ""
	Local nQtdeIN  := 0
	Local i        := 0

	U_AGX635CN("DBG") 

	  				 //Empresa           ,  Filial              , Documento                        , Serie,  Fornece    			, Loja                           
	//AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })


    For i := 1 to len(xIntCapa)
        
       //Monta Clausula Where do documento 
        If nQtdeIN == 0
       		 cCTEIN := " AND (" 
       	Else
      		 cCTEIN += " ) OR ("  	
        Endif
        cCTEIN += " STG_GEN_TABEMP_Codigo 	  =  "+alltrim(str(xIntCapa[i][1]))+""
		cCTEIN += " AND STG_GEN_TABFIL_Codigo	  =  "+alltrim(str(xIntCapa[i][2]))+""
		cCTEIN += " AND COM_CONFRE_Numero 		  =  "+xIntCapa[i][3]+""
		cCTEIN += " AND COM_CONFRE_Serie 		  =  '"+xIntCapa[i][4]+"' "
		cCTEIN += " AND STG_COM_CONFRE_Tra_Codigo =  "+xIntCapa[i][5]+""
		cCTEIN += " AND STG_COM_CONFRE_Etr_Codigo =  "+xIntCapa[i][6]+""
		
   		//cCTEIN += ",'" + AllTrim((cAliasCapa)->(F1_DOC)+(cAliasCapa)->(F1_SERIE)) + "'"
		nQtdeIN += 1

		If (nQtdeIN >= 10) .Or. len(xIntCapa) == i 
			
			cCTEIN += ") " 
			
			UpdateCTE(cCTEIN)

			nQtdeIN := 0
			cCTEIN := ""
		EndIf
	Next i 

Return()

Static Function UpdateCTE(cCTEIN)

	Local cQuery   := ""
    
	//Atualiza CAPA
	cQuery += " UPDATE COM_CONFRE SET "
	cQuery += " COM_CONFRE_DHIntTotvs = current_timestamp() "
	cQuery += " WHERE COM_CONFRE_DHIntTotvs IS NULL "
	cQuery += cCTEIN
	//cQuery += " AND  STG_GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)
	//cQuery += " AND  STG_GEN_TABFIL_Codigo = " + cValToChar(nFilOrigem)
	//cQuery += " AND  COM_NOTCOM_NUMERO+COM_NOTCOM_SERIE IN ( " + cNFEIN + ")"

	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao executar SQL: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf   

Return()       
                     
//Verifica/Exclui se já existe na SF8
Static function VerifSF8(xDoc,xSerie,xFornece,xLoja)   

	Local _aArea := GetArea()  
	                           
	Dbselectarea('SF8')
	SF8->(dbgotop())
	DbsetOrder(3)
	If Dbseek(xfilial('SF8')+xDoc+xSerie+xFornece+xLoja )
		
		While SF8->(!Eof()) .AND.;
		 	alltrim(xfilial('SF8')+xDoc+xSerie+xFornece+xLoja) == alltrim(SF8->F8_FILIAL+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_TRANSP+SF8->F8_LOJTRAN)
	 		Reclock('SF8',.F.)
	  			dbdelete()
	  		SF8->(MsUnlock())
	  		
	  		SF8->(dbskip())
		Enddo
	
	Endif

    Restarea(_aArea) 
    
    /*cQuery := " UPDATE " + RETSQLNAME("SF8") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
	cQuery += " WHERE "
	cQuery += "   F8_NFDIFRE     =  '" + xDoc + "' "
	cQuery += "   AND F8_SEDIFRE     =  '"+xSerie+"' "
	cQuery += "   AND F8_TRANSP  =  '" + xFornece + "' "
	cQuery += "   AND F8_LOJTRAN =  '" + xLoja + "' "
	cQuery += "   AND D_E_L_E_T_  <> '*'  "   
	conout(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF8: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf    
    */
	
Return    


Static Function ENTouSAI()

	Local cRetES     := "E"
	Local cQueryES   := "" 
	Local cAliasTipo := "ENTouSAI"//GetNextAlias()
	
	//Busca se o cte tem uma nota de saída
	cQueryES := " SELECT " 
	cQueryES += " * FROM COM_SAIFRE "  
	cQueryES += " WHERE " 
	cQueryES += " STG_GEN_TABEMP_Codigo = "+alltrim(str((cCapaCTE)->(DBEMP)))
	cQueryES += " AND STG_GEN_TABFIL_Codigo = "+alltrim(str((cCapaCTE)->(DBFIL))) 
	cQueryES += " AND COM_CONFRE_Numero     = "+(cCapaCTE)->(F1_DOC)
	cQueryES += " AND COM_CONFRE_Serie      = '"+(cCapaCTE)->(F1_SERIE)+"'"
	cQueryES += " AND STG_COM_CONFRE_Tra_Codigo = "+(cCapaCTE)->(DBFORN)
	cQueryES += " AND STG_COM_CONFRE_Etr_Codigo = "+(cCapaCTE)->(DBENT)  
	
	//CONOUT(cQueryES)
	U_AGX635CN("DBG")    

	If Select(cAliasTipo) <> 0
		dbSelectArea(cAliasTipo)
		(cAliasTipo)->(dbCloseArea())
	Endif

	TCQuery cQueryES NEW ALIAS (cAliasTipo)
	
	If (cAliasTipo)->(!eof())
		cRetES   := "S"
	endif
	
	U_AGX635CN("PRT")
	
	If Select(cAliasTipo) <> 0
		dbSelectArea(cAliasTipo)
		(cAliasTipo)->(dbCloseArea())
	Endif


Return cRetES


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
		cFilAnt := Alltrim(SM0->M0_CODFIL)
		RestArea(aSegSM0)
	EndIf
Return()

Static Function PergFIN080(aPergAux) 
	Pergunte("FIN080", .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
Return()


Static Function GVErrorlog(xError)

	CONOUT('*******************')
	CONOUT('GRERRORLOG')
	CONOUT(xError:Description) 
	CONOUT('*******************')

	//GRAVA Array de LOG
	AADD(aLogs,{;
			{'ZDB_DBEMP'  ,''},;
			{'ZDB_DBFIL'  ,''},;
			{'ZDB_MSG'	  ,'ERRORLOG '+xError:Description},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,'ERRORLOG'},; 
			{'ZDB_TAB' 	  ,''},; 
			{'ZDB_INDICE' ,1},;   
			{'ZDB_TIPOWF' ,8},; 
			{'ZDB_CHAVE'  ,'ERRORLOG'};
			})   

//		DisarmTransaction()

Return


/*Static Function GetCCFil(xEmp,xFil)

	Local cQrycc   := ""
	Local cAliascc := "GETCCFIL"
	Local cRetcc   := ""

	cQrycc := " SELECT EMP_CC FROM EMPRESAS "
	cQrycc += " WHERE EMP_COD = '"+xEmp+"' AND EMP_FIL = '"+xFil+"' "

	If Select(cAliascc) <> 0
		dbSelectArea(cAliascc)
		(cAliascc)->(dbCloseArea())
	Endif

	TCQuery cQrycc NEW ALIAS (cAliascc)


	If (cAliascc)->(!eof())
		cRetcc := (cAliascc)->EMP_CC
	Endif 

	If Select(cAliascc) <> 0
		dbSelectArea(cAliascc)
		(cAliascc)->(dbCloseArea())
	Endif

Return cRetcc*/
