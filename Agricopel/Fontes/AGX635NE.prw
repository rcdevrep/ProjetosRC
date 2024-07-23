#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ROTINA DE INTEGRAÇÃO COM DBGINT - Nota de Entrada
*/
/*/{Protheus.doc} AGX635NE
//ROTINA DE INTEGRAÇÃO COM DBGINT - Nota de Entrada
@author Spiller
@since 11/09/2017
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/   
User Function AGX635NE(aEmpDePara,xReproc)

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local nQtdeNE        := 0
	//Local oTmpTable		 := Nil
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
	Private  oError := ErrorBlock({|e| GVErrorlog(e)})

	conout('Iniciando AGX635NE - '+time())
	For nCountDe := 1 To Len(aEmpDePara)

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

			cEmpPara     := aEmpPara[nCountPara][2]
			cFilialPara  := aEmpPara[nCountPara][3] 
			nFilde       := aEmpPara[nCountPara][1] 
							
			lClearEnv := .T.
		
		  	PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","XXS"
		   
			  	RPCSetType()
			  	If RpcSetEnv(cEmpPara,cFilialPara)
		
					/*oTmpTable := CriaArqNE(nEmpDe,nFilde)	
					cAliasCapa := oTmpTable:GetAlias()*/
					cAliasCapa := CriaArqNE(nEmpDe,nFilde)	

					If Select(cAliasCapa) <> 0
						nQtdeNE := (cAliasCapa)->(RecCount())
										
						If nQtdeNE > 0
							InserirNFE(cAliasCapa) 
						Endif

						(cAliasCapa)->(DbCloseArea())
						//oTmpTable:Delete()
						//FreeObj(oTmpTable)

						RPCClearEnv()
						dbCloseAll()
					Else 
						conout("AGX635NE - Nao foi Possivel selecionar o TRB : "+cAliasCapa)
					Endif 
				Else
					conout("AGX635NE - Nao foi Possivel abrir o ambiente: "+cEmpPara+"-"+cFilialPara)
				Endif     

			RESET ENVIRONMENT	
		
		Next nCountPara

	Next nCountDe 
	 
	//Grava Logs
	If len(aLogs) > 0     
 		//Grava Log
		U_AGX635LO(aLogs,'AGX635NE','IMPORTACAO NOTA ENTRADA')
 	Endif

	ErrorBlock(oError)	

Return(aEmpDePara)
                            

//Busca dados da NFE de Entrada
Static Function SelectNFE(nEmpOrigem,nFilOrigem)

	Local cAliasCapa := "SelectNFEA"//GetNextAlias()
	Local cQuery    := "" 
	
	Default nFilOrigem := 0
	
    //CAST(DOCUMENTO.DT_MOVIMENTO AS  VARCHAR)    
	cQuery := "SELECT                         "+chr(13)//
	cQuery += "STG_GEN_TABEMP_Codigo 	   	     AS DBEMP "+chr(13)//Código da Empresa (Agricopel = 1)
	cQuery += ",STG_GEN_TABFIL_Codigo 	   		 AS DBFIL "+chr(13)//Código da Filial
	cQuery += ",CAST(COM_NOTCOM_Numero AS  CHAR) AS F1_DOC   "+chr(13)//Número da Nota Fiscal de Entrada
	cQuery += ",COM_NOTCOM_Serie  				 AS F1_SERIE "+chr(13)//Séria da NF
	cQuery += ",COM_NOTCOM_Emissao 				 AS F1_EMISSAO "+chr(13)//Data de emissão da NF
	cQuery += ",CAST(STG_GEN_TABENT_For_Codigo AS  CHAR) AS DBFORN     "+chr(13)//Código da Entidade - Fornecedor
	cQuery += ",CAST(STG_GEN_ENDENT_For_Codigo AS  CHAR) AS DBENT    "+chr(13)//Endereço da Entidade - Fornecedor
	cQuery += ",STG_GEN_TABMOD_Codigo 			 AS MODELO "   +chr(13)//Código do Modelo do Documento (01,55, 08, etc)
	cQuery += ",STG_GEN_TABESP_Codigo 			 AS F1_ESPECIE"+chr(13)//Código da Espécie do Documento (NFE, NFF, NF, etc)
	cQuery += ",COM_NOTCOM_TipoNF 				 AS TIPONF   " +chr(13)//Tipo da NF (E-Entrada Normal, D-Devolução, C-Complementar)
	cQuery += ",COM_NOTCOM_Entrada 				 AS F1_DTDIGIT"+chr(13)//Data de entrada da NF
	cQuery += ",COM_NOTCOM_TipoFrete 			 AS F1_TPFRETE"+chr(13)//Tipo do Frete (C-CIF ou F-FOB)
	cQuery += ",COM_NOTCOM_ChaveNFe 			 AS F1_CHVNFE" +chr(13)//Chave da Nfe
	cQuery += ",COM_NOTCOM_BaseSubs 			 AS F1_BRICMS" +chr(13)//Valor Base Substituição Tributária
	cQuery += ",COM_NOTCOM_SubsTrib 			 AS F1_ICMSRET"+chr(13)//Valor Substituição Tributária
	cQuery += ",COM_NOTCOM_ValorProd 			 AS F1_VALMERC"+chr(13)//Valor dos Produtos
	cQuery += ",COM_NOTCOM_Frete 			  	 AS F1_FRETE  "+chr(13)//Valor do Frete
	cQuery += ",COM_NOTCOM_Seguro 				 AS F1_SEGURO "+chr(13)//Valor do Seguro
	cQuery += ",COM_NOTCOM_DespesasAC 			 AS F1_DESPESA"+chr(13)//Valor de Despesas Acessórias
	cQuery += ",COM_NOTCOM_IPI  				 AS F1_VALIPI "+chr(13)//Valor IPI    
	cQuery += ",COM_NOTCOM_Embalagem 			 AS F1_VALEMB "+chr(13)//Valor Custos Embalagem
	cQuery += ",COM_NOTCOM_Financeiro 			 AS VALENCFIN "+chr(13)//Valor Encargos Financeiros
	cQuery += ",COM_NOTCOM_Servico   			 AS VALSERVI  "+chr(13)//Valor Serviços
	cQuery += ",COM_NOTCOM_Desconto 			 AS F1_DESCONT "+chr(13)//Valor Total Descontos
	cQuery += ",COM_NOTCOM_ValorNF 				 AS F1_VALBRUT "+chr(13)//Valor Total da NF
	cQuery += ",COM_NOTCOM_IDFiscal 			 AS IDFISCAL   "+chr(13)//ID Integração módulo Fiscal
	cQuery += ",COM_NOTCOM_IDContabil 			 AS IDCONT     "+chr(13)//ID Integração módulo Contábil
	cQuery += ",COM_NOTCOM_Atualizada  			 AS ATUALIZ    "+chr(13)//Flag para marcar que nota foi digitada, concluída e integrada ao sistema.
	cQuery += ",COM_NOTCOM_BICMS 				 AS F1_BASEICM "+chr(13)//Valor Base ICMS
	cQuery += ",COM_NOTCOM_AICMS 				 AS ALIQICM    "+chr(13)//Alíquota ICMS
	cQuery += ",COM_NOTCOM_ICMS 				 AS F1_ICMS    "+chr(13)//Valor ICMS
	cQuery += ",COM_NOTCOM_IICMS 				 AS ISENICMS   "+chr(13)//Valor Isento ICMS
	cQuery += ",COM_NOTCOM_OICMS 				 AS OUTICMS    "+chr(13)//Valor Outros ICMS
	cQuery += ",COM_NOTCOM_TipoRedICMS 			 AS TpRedICM   "+chr(13)//Tipo Redução ICMS (N-Não Tem, B-Redução na Base, A-Redução na Alíquota)
	cQuery += ",COM_NOTCOM_PercRedICMS 			 AS PercRedICM "+chr(13)//Percentual de Redução ICMS
	cQuery += ",COM_NOTCOM_BaseDIFA 			 AS TpBaseDif  "+chr(13)//Tipo Base Diferencial de Alíquota (T-Não tem, P-Total Produtos, N-Total NF)
	cQuery += ",COM_NOTCOM_BDIFA 				 AS ValBdifa   "+chr(13)//Valor Base Diferencial de Alíquota
	cQuery += ",COM_NOTCOM_ADIFA 				 AS AliqBdifa  "+chr(13)//Alíquota do Diferencial de Alíquota
	cQuery += ",COM_NOTCOM_DIFA  				 AS ValDifa    "+chr(13)//Valor Diferencial de Alíquota
	cQuery += ",COM_NOTCOM_BIPI 				 AS F1_BASEIPI "+chr(13)//Valor Base IPI
	cQuery += ",COM_NOTCOM_IIPI 				 AS ValISENIP  "+chr(13)//Valor Isento IPI
	cQuery += ",COM_NOTCOM_OIPI 				 AS ValOUTIPI  "+chr(13)//Valor Outros IPI 

	cQuery += ",COM_NOTCOM_ISS 					 AS F1_ISS     "+chr(13)//Valor ISS (retenção) 
	cQuery += ",COM_NOTCOM_CSLL 				 AS F1_VALCSLL "+chr(13)//Valor CSLL (retenção) 
	cQuery += ",COM_NOTCOM_IRRF 				 AS F1_VALIRF  "+chr(13)//Valor IRRF (retenção)    
	cQuery += ",COM_NOTCOM_INSS 				 AS F1_INSS    "+chr(13)//Valor INSS (Retenção)
	
	/*Impostos de retenção, segundo vanderleia não precisa importar
	cQuery += ",COM_NOTCOM_PIS 					 AS F1_VALPIS  "+chr(13)//Valor PIS (retenção)
	cQuery += ",COM_NOTCOM_COFINS 				 AS F1_VALCOFI "+chr(13)//Valor COFINS (retenção)
	cQuery += ",COM_NOTCOM_PICOCS 				 AS VALPISCOF  "+chr(13)//Valor PIS/COFINS/CSLL (retenção) 
	*/
	cQuery += ",COM_NOTCOM_IDFinanceiro			 AS IDFin	   "+chr(13)//ID integração módulo financeiro
	cQuery += ",COM_NOTCOM_DHIntTotvs 			 AS DHIntTotvs "+chr(13)//Data e hora de integração Sistema Protheus
	cQuery += ",COM_NOTCOM_BasePIS 	   			 AS F1_BASIMP6  "+chr(13)//Valor Base PIS
	cQuery += ",COM_NOTCOM_TotalPIS 			 AS F1_VALIMP6  "+chr(13)//Valor PIS
	cQuery += ",COM_NOTCOM_BaseCOFINS 			 AS F1_BASIMP5 "+chr(13)//Valor Base COFINS
	cQuery += ",COM_NOTCOM_TotalCOFINS 			 AS F1_VALIMP5 "+chr(13)//Valor COFINS
	cQuery += ",ENDENT.GEN_ENDENT_IF 			 AS CNPJ_CPF   "+chr(13)//CPF/CNPJ 
	cQuery += ",COM_NOTCOM_ControleContabil		 AS F1_XCTRCON  "+chr(13)//CPF/CNPJ 
    //cQuery += ",COM_NOTCOM_SeqProduto         "+chr(13)//Sequencia controle itens do produto - USO INTERNO
    //cQuery += ",COM_NOTCOM_Created            "+chr(13)//Data de criação do registro
    //cQuery += ",COM_NOTCOM_Updated            "+chr(13)//Data de alteração do registro
	//cQuery += ",COM_NOTCOM_AltFinanc          "+chr(13)//Houve alteração nos dados de parcelamento ? 1-Sim/0-Não
	//cQuery += ",COM_NOTCOM_SeqFinanceiro      "+chr(13)//Sequencia controle parcelas - USO INTERNO
	//cQuery += ",STG_GEN_TABORG_Codigo         "+chr(13)//Código da Origem do Documento
	//cQuery += ",STG_COM_RECPDC_Numero         "+chr(13)//Código do Número do Recebimento (recebimento da NF através de pedido de compra)
	//cQuery += ",COM_NOTCOM_FornExclusivo      "+chr(13)//Fornecedor é Exclusivo ? Controle do módulo de Qualidade
	//cQuery += ",COM_NOTCOM_Log                "+chr(13)//Mensagens de log referente recebimentos emergencias / baixas de solicitação de compras
	//cQuery += ",STG_GEN_TIPPAG_Codigo         "+chr(13)//Código do Tipo de Pagamento
	//cQuery += ",COM_NOTCOM_DANFE              "+chr(13)//Campo para armazenar arquivo da DANFE (PDF)
	//cQuery += ",COM_NOTCOM_XML                "+chr(13)//Campa para armazenar arquivo XML da NF (XML)
	//cQuery += ",COM_NOTCOM_ImpXML             "+chr(13)//Nota foi importada de XML ? 1-Sim / 0-Não
	//cQuery += ",COM_NOTCOM_Emergencial        "+chr(13)//Compra Emergencial ? 1-Sim / 0-Não     
	//cQuery += ",STG_GEN_TABENT_Tra_Codigo     "+chr(13)//Código da Entidade - Transportadora
	//cQuery += ",STG_GEN_ENDENT_Tra_Codigo     "+chr(13)//Endereço da Entidade - Transportadora
	//cQuery += ",GEN_NATOPE_Codigo             "+chr(13)//Natureza da Operação
	//cQuery += ",GEN_TABCPG_Codigo             "+chr(13)//Condição de Pagamento
	//cQuery += ",GEN_TABUSU_Login              "+chr(13)//Login do usuário que digitou a NF
	//cQuery += ",STG_COM_TABCOT_Codigo         "+chr(13)//Código da Tabela de Cotas
	//cQuery += ",STG_GEN_ESTMUN_ISS_Estado     "+chr(13)//UF de recolhimento do ISS (retenção)
	//cQuery += ",STG_GEN_ESTMUN_ISS_Municipio  "+chr(13)//Cidade de recolhimento do ISS (retenção)
	//cQuery += ",COM_NOTCOM_IDAbastecimento    "+chr(13)//ID integração módulo Frota quando houver abastecimento externo
	//cQuery += ",COM_NOTCOM_AbastExterno       "+chr(13)//NF de abastecimento externo ? 1-Sim / 0-Não
    //cQuery += ",COM_NOTCOM_OSTerceiro         "+chr(13)//Número da Ordem de Serviço - OS de terceiros
    //cQuery += ",COM_NOTCOM_IntContabilAlt     "+chr(13)//Integração Contábil alterada manualmente (1-Sim / 0-Não)
	cQuery += " FROM COM_NOTCOM COM_NOTCOM      "+chr(13) 
	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = STG_GEN_TABENT_For_Codigo "
	cQuery += " 								AND STG_GEN_ENDENT_For_Codigo = GEN_ENDENT_Codigo"  
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON GEN_TABEMP_Codigo = STG_GEN_TABEMP_Codigo AND "
	cQuery += " GEN_NATOPE.GEN_NATOPE_Codigo = COM_NOTCOM.GEN_NATOPE_Codigo  "  	
	cQuery += " WHERE COM_NOTCOM_DHIntTotvs IS NULL AND"
	cQuery += " 	  STG_GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem) 
	cQuery += " 	  AND  COM_NOTCOM_Atualizada = 'S' "//Somente Atualizadas
	cQuery += " 	  AND GEN_NATOPE_GeraLivro = 1  " 
	
	//***TESTES 
    //cQuery += " 	  AND  COM_NOTCOM.COM_NOTCOM_Numero IN ('213','214','215','216','217','218') AND COM_NOTCOM.STG_GEN_TABFIL_Codigo = 5 AND COM_NOTCOM.COM_NOTCOM_Emissao >= '2018-10-19'" //,'578452') "

	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0  
		cQuery += " AND  STG_GEN_TABFIL_Codigo = " + cValToChar(nFilOrigem)
    Endif                
    
   
    //conout('AGX635_COM_NOTCOM')
    conout(cQuery)
   	U_AGX635CN("DBG")    
	
	If Select(cAliasCapa) <> 0
		dbSelectArea(cAliasCapa)
		(cAliasCapa)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasCapa)

Return(cAliasCapa)                        


//Insere dados no Protheus
Static Function InserirNFE(cAliasCapa)

	Local lRegOK := .T. 
	Local cFil   := '' 
	Local cContaCF :=  ""
    	  
	U_AGX635CN("PRT") 
	
	(cAliasCapa)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cAliasCapa)->(!eof())
		
		DBSELECTAREA('SA2') 
		SA2->(DbGoTop())
		SA2->(DbSetOrder(3))
		If !(SA2->(DbSeek(xFilial("SA2")+(cAliasCapa)->(CNPJ_CPF))))
				
			lRegOK := .F.  
			
			//Inclui fornecedor  
	   	   	cContaCF :=  U_AGX635CF((cAliasCapa)->(CNPJ_CPF),'SA2')	
			
			DBSELECTAREA('SA2') 
			SA2->(DbGoTop())
			SA2->(DbSetOrder(3))
			SA2->(DbSeek(xFilial("SA2")+(cAliasCapa)->(CNPJ_CPF)))
			
								// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}  
			If alltrim(SA2->A2_CONTA) == ''  .or. alltrim(cContaCF) == "" 
						  
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Fornecedor sem conta: '+(cAliasCapa)->(CNPJ_CPF)+'('+alltrim(SA2->A2_NOME)+')'+', Doc: '+(cAliasCapa)->(F1_DOC)+'-'+(cAliasCapa)->(F1_SERIE)},;
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
	
						  
				(cAliasCapa)->(dbskip()) 
				LOOP
			Endif  
		Endif
		
		
		//Valida preenchimento de conta
		//Posteriormente será incluído automáticamente
		If alltrim(SA2->A2_CONTA) == ''      
		
				If !lReproc
						  
			   		//GRAVA Array de LOG
        			AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Fornecedor sem conta:'+(cAliasCapa)->(CNPJ_CPF)+'('+alltrim(SA2->A2_NOME)+')'+', DOC: '+(cAliasCapa)->(F1_DOC)+'-'+(cAliasCapa)->(F1_SERIE)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SA2'},; 
						{'ZDB_INDICE' ,3},; 
						{'ZDB_TIPOWF' ,1},; 
						{'ZDB_CHAVE'  ,(cAliasCapa)->(CNPJ_CPF)};
						})   		  
				Else
					Alert('Fornecedor Nao Existe:'+(cAliasCapa)->(CNPJ_CPF))
				Endif	

			(cAliasCapa)->(dbskip()) 
			LOOP  
		Endif
		
		 
		dbselectarea(cAliasCapa)       
		aTam    := {}
		aTam    := TamSX3("F1_DOC")
		_cDoc   := PADL(alltrim((cAliasCapa)->(F1_DOC)),aTam[1],'0')
        
        aTam    := {}
		aTam    := TamSX3("F1_SERIE")	
        _cSerie := PADR(alltrim((cAliasCapa)->(F1_SERIE)),aTam[1],' ') //substr(alltrim((cAliasCapa)->F1_SERIE),1,3)   //PADR(StrTran(alltrim((cAliasCapa)->(F1_SERIE)),'-','' ),aTam[1],' ')
		
		
		//Verifica se já existe no Protheus
		dbselectarea('SF1')
		dbsetorder(1)
		If dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)  
	
	   	    //Valida se é nota antiga com o Mesmo Prefixo
			If  /*YEAR(SF1->F1_DTDIGIT) <> Year(ddatabase) .and.*/ ( ddatabase - SF1->F1_DTDIGIT) > 365
				//GRAVA Array de LOG
	        	AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
					{'ZDB_MSG'	  ,'Numero de Nf ANTIGA ja existe com esse prefixo: '+_cDoc+'-'+_cSerie+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')'},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))},; 
					{'ZDB_TAB' 	  ,'SF1'},; 
					{'ZDB_INDICE' ,1},;  
					{'ZDB_TIPOWF' ,4},; 
					{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
					})   		  
				
		 		(cAliasCapa)->(dbskip()) 
				LOOP
			Endif
	   	    
	   	    
	   		// Verifica se título já foi baixado no Protheus,
	   		// Se ainda nao foi baixado,exclui para gerar novamente, 
	   		// Senão Gera Log 
	   		If U_AGX635JB((cAliasCapa)->(F1_VALBRUT))	 
	   				//GRAVA Array de LOG
	        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Tit.Baixado com Valor Diferente ou Numero de Nf ja existe: '+_cDoc+'-'+_cSerie+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1},;  
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
						})   		  
				           //Comentar - Utilizado apenas para marcar notas que estavam com problema, para que não fique validando
							//AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })			  
				
		 		(cAliasCapa)->(dbskip()) 
				LOOP
			Endif 
	 	Else
			
	 		//Valida se já tem título com mesmo PREFIXO
	 		If !ValPrefixo( alltrim((cAliasCapa)->(F1_SERIE)) /*cFil + substr(alltrim((cAliasCapa)->(F1_SERIE)),1,3)*/ , _cDoc , SA2->A2_COD , SA2->A2_LOJA ) 
	 					//GRAVA Array de LOG
	        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Já existe Título com mesmo prefixo,alterar prefixo de nota antiga: '+_cDoc+'-'+_cSerie+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1},;  
						{'ZDB_TIPOWF' ,4},; 
						{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
						})           
						
					(cAliasCapa)->(dbskip()) 
					LOOP
	 		Endif
	 	Endif          
	 	                                                                                                                            
		cFil := xfilial('SF1')//STRZERO((cAliasCapa)->(DBFIL),2) 
		
		cEspecie := ""  
		If alltrim((cAliasCapa)->F1_ESPECIE) == 'NFE'
			cEspecie := "SPED"
		Elseif alltrim((cAliasCapa)->F1_ESPECIE) == 'NFAE'
			cEspecie := "NFA"
		Else
			cEspecie := alltrim((cAliasCapa)->F1_ESPECIE)
		Endif
		    
		DbSelectArea( "SX5" )
   		DbSetOrder(1)
		IF !(DbSeek( xFilial( "SX5" ) + "42" + cEspecie )) 
			
			If !lReproc
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Especie Invalida: '+cEspecie},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},; 
						{'ZDB_TAB'	  ,'SX5'},;
						{'ZDB_INDICE' ,1},;
						{'ZDB_TIPOWF' ,5},;
						{'ZDB_CHAVE'  ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
						})   		 
		 	Else
		   		Alert('Natureza Invalida: '+cEspecie)
		 	Endif
		 	(cAliasCapa)->(dbskip()) 
			LOOP 
		Endif
		    
		ctipoNF := (cAliasCapa)->(TIPONF)
		
		If alltrim((cAliasCapa)->(TIPONF)) == 'E'
			ctipoNF := 'N'
   		Endif
		
		conout('Inserindo NFE '+cEmpant+'/'+cfilAnt+' - '+_cDoc+' - '+time())
		//Inicia a Transação
		BEGIN TRANSACTION //Begintran()		
		
		RecLock("SF1" , .T.)
		
			SF1->F1_FILIAL  := cFil
			SF1->F1_DOC		:= _cDoc//(cAliasCapa)->(F1_DOC)
			SF1->F1_SERIE   := _cSerie//(cAliasCapa)->(F1_SERIE)
			SF1->F1_FORNECE := SA2->A2_COD
			SF1->F1_LOJA    := SA2->A2_LOJA
			SF1->F1_TIPO    := ctipoNF
			SF1->F1_ESPECIE := cEspecie//(cAliasCapa)->(STG_GEN_TABESP_Codigo)
			//SF1->  DOCUMENTO.CD_C
			SF1->F1_EMISSAO := (cAliasCapa)->(F1_EMISSAO)
			SF1->F1_DTDIGIT := (cAliasCapa)->(F1_DTDIGIT)
			SF1->F1_RECBMTO := (cAliasCapa)->(F1_DTDIGIT)
			//SF1->F1_DTLANC  := STOD(cDataDigit)
			SF1->F1_EST   	:= SA2->A2_EST
			SF1->F1_FRETE   := (cAliasCapa)->(F1_FRETE)
			SF1->F1_DESPESA := (cAliasCapa)->(F1_DESPESA)
			SF1->F1_BASEICM := (cAliasCapa)->(F1_BASEICM)
			SF1->F1_VALICM  := (cAliasCapa)->(F1_ICMS)
			SF1->F1_VALMERC := (cAliasCapa)->(F1_VALMERC) //+ (cAliasCapa)->(F1_DESCONT)
			SF1->F1_VALBRUT := (cAliasCapa)->(F1_VALBRUT) //+ (cAliasCapa)->(F1_DESCONT)
			SF1->F1_DESCONT := (cAliasCapa)->(F1_DESCONT)
			SF1->F1_BRICMS  := (cAliasCapa)->(F1_BRICMS)
			SF1->F1_ICMSRET := (cAliasCapa)->(F1_ICMSRET)
			SF1->F1_ICMS    := (cAliasCapa)->(F1_ICMS)
		    //SF1->F1_PESOL   := MSF1->F1_PESOL    
			SF1->F1_SEGURO	:= (cAliasCapa)->(F1_SEGURO)
			SF1->F1_CHVNFE  := (cAliasCapa)->(F1_CHVNFE)
			SF1->F1_ORIIMP  := "AGX635NE"
			SF1->F1_PREFIXO :=  substr(alltrim((cAliasCapa)->(F1_SERIE)),1,3)
			SF1->F1_DUPL    := _cDoc//(cAliasCapa)->(F1_DOC)
			SF1->F1_STATUS  := "A" 
			SF1->F1_COND    := "001" 
			//Campos Novos
			SF1->F1_BASEIPI := (cAliasCapa)->(F1_BASEIPI)
			SF1->F1_VALIPI  := (cAliasCapa)->(F1_VALIPI) //ValOUTIPI outros IPI
			SF1->F1_ISS 	:= (cAliasCapa)->(F1_ISS) 
			//PIS/COFINS APURAÇÃO
	   		SF1->F1_VALIMP6 := (cAliasCapa)->(F1_VALIMP6)
	   		SF1->F1_BASIMP6 := (cAliasCapa)->(F1_BASIMP6)
			SF1->F1_VALIMP5 := (cAliasCapa)->(F1_VALIMP5)
			SF1->F1_BASIMP5 := (cAliasCapa)->(F1_BASIMP5)
			//RETENÇÃO PENDENTE
			//SF1->F1_VALPIS  := (cAliasCapa)->(F1_VALPIS)
			//SF1->F1_VALCOFI := (cAliasCapa)->(F1_VALCOFI)
			//SF1->F1_BASCOFI
			//SF1->F1_VALCOFI
			
			SF1->F1_VALCSLL := (cAliasCapa)->(F1_VALCSLL)
			SF1->F1_VALIRF  := (cAliasCapa)->(F1_VALIRF)
			SF1->F1_INSS 	:= (cAliasCapa)->(F1_INSS)

			//Campo de uso da contabilidade
			SF1->F1_XCTRCON := (cAliasCapa)->(F1_XCTRCON)
            
		SF1->(Msunlock()) 
		
		//Insere produtos referentes a Nota Fiscal
		lOkProd := InserirPro()  
		 
		// Se inseriu corretamente o produto 
		// Grava Array de Atualização dos dados 
		// Senão desarma a Transação
		If lOkProd     
			
							//Empresa           ,  Filial              , Documento                        , Serie, Fornece				, Loja                           
			AADD(aIntCAPA,{(cAliasCapa)->DBEMP, (cAliasCapa)->DBFIL, (cAliasCapa)->F1_DOC,(cAliasCapa)->F1_SERIE , (cAliasCapa)->DBFORN , (cAliasCapa)->DBENT  })
		
			ReprocSF1(SF1->F1_EMISSAO, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_FILIAL)
		
		Else
		   	DisarmTransaction()//Faz rollBack da transação 
		Endif        
		
		//Destrava todas as conexões
	 	MsUnlockAll()   
	    END TRANSACTION //EndTran() //Finaliza Transação  

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
	//Local oTmpTable    := Nil
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectNFE(nEmpOrigem,nFilOrigem)

	If Select(cAliasQry) <> 0

		aStruTmp := (cAliasQry)->(DbStruct())
		/*oTmpTable := FwTemporaryTable():New()
		oTmpTable:SetFields(aStruTmp)
		oTmpTable:AddIndex("1", {aStruTmp[1][1]})
		oTmpTable:Create()*/

		cAliasArea := "CriaArqNEA"//GetNextAlias()
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
	Else
		conout("AGX635PR - CriaArqNE: Nao foi criar alias "+cAliasQry)
	Endif 
   	//RPCClearEnv()

Return(cAliasArea)            
  

// Insere dados na SD1
Static Function InserirPro()

	Local cQuery     := "" 
	Local lRegOK     := .T.  
	Local lGerouReg  := .F. 
	Local aTemRateio := {}
	Local i          := 0
	Local lRecCDA    := .F.
	 
	cAliasPROD := "AGX635PRD"
	//Captura dados da Empresa, posicao 22 é UF  
	aArrayEmp := FWArrFilAtu()
	cUFEmp    := substr( alltrim(aArrayEmp[22]) ,  len(alltrim(aArrayEmp[22]))-1,  len(alltrim(aArrayEmp[22]) )) 
	cUFForn   := SA2->A2_EST
       
	cQuery := "SELECT                       "+chr(13)//
	cQuery +="COM_PRONOT.STG_GEN_TABEMP_Codigo	AS DBEMP"+CHR(13)//Código da Empresa (Agricopel = 1) 
	cQuery +=",COM_PRONOT.STG_GEN_TABFIL_Codigo AS DBFIL"+CHR(13)//Código da Filial                  
	cQuery +=",GEN_NATOPE_TES AS D1_TES  	"+CHR(13)//  TES Protheus 
	cQuery +=",GEN_NATOPE_ExigeCarroCCNF  AS EX_CC "+CHR(13)//Exige centro de custo
	cQuery +=",COM_PRONOT.COM_NOTCOM_Numero AS D1_DOC  "+CHR(13)//Número da Nota Fiscal de Entrada
	cQuery +=",COM_PRONOT.COM_NOTCOM_Serie	 AS D1_SERIE"+CHR(13)//Séria da NF
	cQuery +=",COM_PRONOT.COM_PRONOT_Sequencia AS D1_ITEM"+CHR(13)//Sequencia de Itens da NF
	cQuery +=",STG_EST_TABPRO_Not_Codigo D1_COD  "+CHR(13)//Código do Produto
	cQuery +=",COM_PRONOT_Quantidade AS D1_QUANT"+CHR(13)//Quantidade do Produto
	cQuery +=",COM_PRONOT_Valor AS D1_VUNIT  "+CHR(13)//Valor Unitário
	cQuery +=",COM_PRONOT_BICMS AS D1_BASEICM"+CHR(13)//Valor Base ICMS
	cQuery +=",COM_PRONOT_AICMS	AS D1_PICM  "+CHR(13)//Alíquota do ICMS
	cQuery +=",COM_PRONOT_ICMS AS D1_VALICM "+CHR(13)//Valor do ICMS
	cQuery +=",COM_PRONOT_SubsTrib AS D1_ICMSRET"+CHR(13)//Valor Substituição Tributária
	cQuery +=",COM_PRONOT_Desconto AS D1_VALDESC "+CHR(13)//Valor Rateado Desconto 
	cQuery +=",STG_GEN_TABCEN_Not_Codigo  AS D1_CC  "+CHR(13)//Código do Centro de Custo (quando é uma despesa para um CC)  
	cQuery +=",FRT_TABCAR.FRT_TABCAR_CodigoCC AS PLACA_CC "+CHR(13)//CC da Placa 
	//cQuery +=",COM_CONNFC_CCCarroTotvs AS RAT_CC "+CHR(13)  
   //cQuery +=",COM_CONNFC.STG_FRT_TABCAR_Con_Codigo  AS PLACA_RAT "+CHR(13)// #NOVO
	//cQuery +=",FRT_TABCAR_A.FRT_TABCAR_CodigoCC AS PLACA_CC_A  "+CHR(13)//  
	cQuery +=",COM_PRONOT.COM_PRONOT_CCCarroTotvs AS DOC_CC "
 	//cQuery +=",COM_PEDIDO_Numero		    "+CHR(13)//Número do Pedido de Compra
	//cQuery +=",COM_PROPED_Sequencia		    "+CHR(13)//Sequencia do Item no Pedido de Compra
 	//cQuery +=",STG_GEN_NATOPE_Not_Codigo    "+CHR(13)//Código da Natureza de Operação 
 	//cQuery +=",COM_NOTCOM_Emissao		    "+CHR(13)//Data de emissão da NF
	//cQuery +=",STG_GEN_TABENT_For_Codigo    "+CHR(13)//Código da Entidade - Fornecedor
	//cQuery +=",STG_GEN_ENDENT_For_Codigo    "+CHR(13)//Endereço da Entidade - Fornecedor
	//cQuery +=",COM_PRONOT_SitTrib		    "+CHR(13)//Código de Situação Tributária do Produto
	//cQuery +=",STG_EST_TABDEP_Not_Codigo    "+CHR(13)//Código do Depósito
  	//cQuery +=",VEN_TABTAL_Codigo		    "+CHR(13)//Código da Tabela de Talonários - Notas de Saída (devolução)
	//cQuery +=",VEN_NFSEMI_Numero		    "+CHR(13)//Númer da Nota de Venda (devolução)
	//cQuery +=",VEN_NFSEMI_Serie			    "+CHR(13)//Série da Nota de Venda (devolução)
	//cQuery +=",COM_PRONOT_AltImposto	    "+CHR(13)//Houve alteração manual nos valores de impostos (1-Sim / 0-Não)
	//cQuery +=",COM_PRONOT_TipoRedICMS	    "+CHR(13)//Tipo Redução ICMS
	//cQuery +=",COM_PRONOT_PercRedICMS	    "+CHR(13)//Percentual Redução ICMS
	//cQuery +=",COM_PRONOT_OICMS			    "+CHR(13)//Valor Outros ICMS
	//cQuery +=",COM_PRONOT_IICMS			    "+CHR(13)//Valor Isento ICMS
	cQuery +=",COM_PRONOT_BIPI	AS D1_BASEIPI	    "+CHR(13)//Valor Base IPI
	cQuery +=",COM_PRONOT_PercIPI AS D1_IPI		    "+CHR(13)//Percentual de IPI
	cQuery +=",COM_PRONOT_IPI	AS D1_VALIPI	    "+CHR(13)//Valor do IPI
	//cQuery +=",COM_PRONOT_OIPI			    "+CHR(13)//Valor Outros IPI
	//cQuery +=",COM_PRONOT_IIPI			    "+CHR(13)//Valor Isento IPI
	cQuery +=",COM_PRONOT_Frete	AS D1_VALFRE		    "+CHR(13)//Valor Rateado do Frete 
	cQuery +=",COM_PRONOT_DespesasAC   AS D1_DESPESA   "+CHR(13)//Valor Rateado Despesas Acessórias
	cQuery +=",COM_PRONOT_Seguro	   AS SEGURO       "+CHR(13)//Valor Rateado Seguro
	cQuery +=",COM_PRONOT_Financeiro   AS FINANC	    "+CHR(13)//Valor Rateado Encargos Financeiros
	cQuery +=",COM_PRONOT_Embalagem	   AS EMBALA	    "+CHR(13)//Valor Rateado Custo Embalagem
	cQuery +=",COM_PRONOT_Servico	   AS SERVIC	    "+CHR(13)//Valor Rateado Serviços
	//cQuery +=",COM_PRONOT_Num_Fal_04	    "+CHR(13)//Número do documento da ISO - FAL-04
	//cQuery +=",COM_PRONOT_LoteFabricacao    "+CHR(13)//Número do Lote de Fabricação
	//cQuery +=",COM_PRONOT_DataLF		    "+CHR(13)//Data do lote de fabricação
	//cQuery +=",COM_PRONOT_ValidadeLF	    "+CHR(13)//Data de validade do lote de fabricação
	//cQuery +=",COM_PRONOT_Created		    "+CHR(13)//Data de criação do registro
	//cQuery +=",COM_PRONOT_Updated		    "+CHR(13)//Data de alteração do registro
	//cQuery +=",STG_FRT_TABCAR_Not_Codigo    "+CHR(13)//Código do Carro/Veículo (quando há despesa para um carro da frota)
	//cQuery +=",COM_PRONOT_Observacao	    "+CHR(13)//Observações do Item
	//cQuery +=",COM_PRONOT_PICOCS		    "+CHR(13)//Valor PIS/COFINS/CSLL Rateado (retenção)
	//cQuery +=",COM_PRONOT_IRRF			    "+CHR(13)//Valor IRRF Rateado (retenção)
	//cQuery +=",COM_PRONOT_ISS			    "+CHR(13)//Valor ISS Rateado (retenção)
	//cQuery +=",COM_PRONOT_INSS			    "+CHR(13)//Valor INSS Rateado (retenção)
	//cQuery+=",COM_PRONOT_ValorMaxGaranti    "+CHR(13)//Preço Máximo do Produto (integração com de OS de terceiros)
	//cQuery +=",COM_PRONOT_DiasMinGarantia   "+CHR(13)//Dias Mínimos de Garantia do Produto (integração com OS de terceiros)
	//cQuery +=",COM_PRONOT_DiasGarantia	    "+CHR(13)//Dia de Garantia do Produto (integração com OS de terceiros)
	//cQuery +=",COM_PRONOT_ContaContabilProd "+CHR(13)//Conta Contábil do Produto (parametrizado com código do sistema de contabilidade externo - Conta de Custo)
	cQuery +=",COM_PRONOT_ValorCOFINS AS D1_VALIMP5	    "+CHR(13)//Valor COFINS
	cQuery +=",COM_PRONOT_ValorPIS	 AS D1_VALIMP6	    "+CHR(13)//Valor PIS
	cQuery +=",COM_PRONOT_BaseCOFINS AS D1_BASIMP5	    "+CHR(13)//Valor Base COFINS
	cQuery +=",COM_PRONOT_BasePIS	 AS D1_BASIMP6	    "+CHR(13)//Valor Base PIS
	cQuery +=",COM_PRONOT_AliqCOFINS AS D1_ALIQCOF	    "+CHR(13)//Alíquota de COFINS
	cQuery +=",COM_PRONOT_AliqPIS    AS D1_ALIQPIS	    "+CHR(13)//Alíquota de PIS  
	cQuery +=",CAST( COM_PRONOT.STG_GEN_TABENT_For_Codigo AS  CHAR) AS DBFORN "+CHR(13)//Fornecedor  
	cQuery +=",CAST(COM_PRONOT.STG_GEN_ENDENT_For_Codigo AS  CHAR)  AS DBENT  "+CHR(13)//loja fornececedor  
	cQuery += ", GEN_SPD197_Codigo          AS CDA_CODLAN "+CHR(13)//Campos C197
	cQuery += ", COM_PRONOT_BaseAjuste197   AS CDA_BASE   "+CHR(13)//Campos C197
	cQuery += ", COM_PRONOT_AliqAjuste197   AS CDA_ALIQ   "+CHR(13)//Campos C197
	cQuery += ", COM_PRONOT_ValorAjuste197  AS CDA_VALOR  "+CHR(13)//Campos C197
	cQuery += ",COM_PRONOT_CodObsProtheus   AS CDA_IFCOMP " +CHR(13)//Campos C197    
	
	//cQuery +=",COM_PRONOT_CSTCOFINS		    "+CHR(13)//CST COFINS
	//cQuery +=",COM_PRONOT_CSTPIS		    "+CHR(13)//CST PIS
	//cQuery +=",COM_PRONOT_ContaContabilEstPro"+CHR(13)//Conta Contábil do Produto (parametrizado com código do sistema de contabilidade externo - Conta de Estoque)
	cQuery += " FROM COM_PRONOT              "+CHR(13) 
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON STG_GEN_NATOPE_Not_Codigo = GEN_NATOPE_Codigo "+chr(13)  
	cQuery += " LEFT JOIN FRT_TABCAR FRT_TABCAR ON FRT_TABCAR_CODIGO = STG_FRT_TABCAR_Not_Codigo  "+chr(13)  
	//cQuery += " LEFT JOIN COM_CONNFC COM_CONNFC  ON "+chr(13) 
	//cQuery += " COM_CONNFC.COM_NOTCOM_Numero = COM_PRONOT.COM_NOTCOM_Numero AND "+chr(13) 
	//cQuery += " COM_CONNFC.COM_NOTCOM_Serie   = COM_PRONOT.COM_NOTCOM_Serie AND "+chr(13) 
	//cQuery += " COM_CONNFC.STG_GEN_TABENT_For_Codigo = COM_PRONOT.STG_GEN_TABENT_For_Codigo AND "+chr(13) 
	//cQuery += " COM_CONNFC.STG_GEN_ENDENT_For_Codigo = COM_PRONOT.STG_GEN_ENDENT_For_Codigo AND "+chr(13) 
	//cQuery += " COM_CONNFC.COM_PRONOT_Sequencia      = COM_PRONOT.COM_PRONOT_Sequencia AND "+chr(13)
	//cQuery += " COM_CONNFC.STG_GEN_TABFIL_Codigo     = COM_PRONOT.STG_GEN_TABFIL_Codigo AND "+chr(13)
	//cQuery += " COM_CONNFC.STG_GEN_TABEMP_Codigo	 = COM_PRONOT.STG_GEN_TABEMP_Codigo AND "+chr(13)
	//cQuery += " COM_CONNFC.COM_CONNFC_Sequencia  = '1' "+chr(13)  
	//cQuery += " LEFT JOIN FRT_TABCAR FRT_TABCAR_A ON FRT_TABCAR_A.FRT_TABCAR_CODIGO = COM_CONNFC.STG_FRT_TABCAR_Con_Codigo "+CHR(13) //#NOVO
	cQuery += " WHERE  "//COM_PRONOT_DHIntTotvs IS NULL
	cQuery += " COM_PRONOT.STG_GEN_TABEMP_Codigo =    	'"+alltrim(str((cAliasCapa)->DBEMP))+"' "+chr(13)
	cQuery += " AND COM_PRONOT.STG_GEN_TABFIL_Codigo =  '"+alltrim(str((cAliasCapa)->DBFIL))+"' "+chr(13)
	cQuery += " AND COM_PRONOT.COM_NOTCOM_Numero = 	    '"+(cAliasCapa)->F1_DOC+"' "+chr(13)
	cQuery += " AND COM_PRONOT.COM_NOTCOM_Serie  = 	    '"+(cAliasCapa)->F1_SERIE+"' "+chr(13)
	cQuery += " AND COM_PRONOT.STG_GEN_TABENT_For_Codigo = '"+(cAliasCapa)->DBFORN+"' "+chr(13)
	cQuery += " AND COM_PRONOT.STG_GEN_ENDENT_For_Codigo = '"+(cAliasCapa)->DBENT+"' "+chr(13)
	cQuery += " AND GEN_NATOPE.GEN_NATOPE_GeraLivro = 1 " +chr(13)//SÓ LEVA PARA PROTHEUS O QUE GERA LIVRO FISCAL 
	
	U_AGX635CN("DBG")    
	 
 	//CONOUT('**AGX635_COM_PRO_NOT')
   	//CONOUT(cQuery)
	
	If Select(cAliasPROD) <> 0
		dbSelectArea(cAliasPROD)
		(cAliasPROD)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAliasPROD)  
	
	TCSETFIELD(cAliasPROD,"D1_PICM"   ,"N",6,2)  
	TCSETFIELD(cAliasPROD,"D1_DESPESA","N",14,2) 
	        
	cFil := STRZERO((cAliasPROD)->DBEMP,2) 
	U_AGX635CN("PRT")	
	
	//Valida se deve incluir SD1
	(cAliasPROD)->(dbgotop())
	While (cAliasPROD)->(!eof()) 
				
		//Posiciona no Produto 
		dbselectarea('SB1')
		dbsetorder(1)
		If !dbseek(xfilial('SB1')+alltrim((cAliasPROD)->(D1_COD)) ) 
			   		// {'ZDB_EMP'              ,'ZDB_FIL'              ,'ZDB_MSG'          ,'ZDB_DATA','ZDB_HORA'}  
			If !lReproc
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,'Produto nao Importado ou sem Conta no DBGint:'+alltrim((cAliasPROD)->(D1_COD))},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},; 
						{'ZDB_TAB'	  ,'SB1'},;
						{'ZDB_INDICE' ,1},; 
						{'ZDB_TIPOWF' ,6},;
						{'ZDB_CHAVE'  ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
						})   		 
			Else
				Alert('Produto nao Importado ou Sem Conta no DBGint:'+alltrim((cAliasPROD)->(D1_COD)))
			Endif
			Return  .F.  
		Else 
		    If SB1->B1_LOCPAD == '01'
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,'Produto cadastrado com Local 01 :'+alltrim((cAliasPROD)->(D1_COD))},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},; 
						{'ZDB_TAB'	  ,'SB1'},;
						{'ZDB_INDICE' ,1},; 
						{'ZDB_TIPOWF' ,6},;
						{'ZDB_CHAVE'  ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
						})   
				Return  .F. 	
		    Endif
		Endif  
		
		//Posiciona na TES
		dbselectarea('SF4')
		dbsetorder(1)
		If !dbseek(xfilial('SF4')+alltrim((cAliasPROD)->(D1_TES))).OR.alltrim((cAliasPROD)->(D1_TES)) == ''.OR.alltrim((cAliasPROD)->(D1_TES))=='0'	
						   		// {'ZDB_EMP'              ,'ZDB_FIL'              ,'ZDB_MSG'          ,'ZDB_DATA','ZDB_HORA'}  
			If !lReproc
				//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)}								,;
						{'ZDB_MSG'	  ,'Doc: '+alltrim((cAliasCapa)->(F1_DOC))+'-'+alltrim((cAliasCapa)->(F1_SERIE))+', TES invalida:'+alltrim((cAliasPROD)->(D1_TES))},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_INDICE' ,1},;
						{'ZDB_TAB'  ,'SF4'},;
						{'ZDB_TIPOWF'  ,5},;
						{'ZDB_CHAVE'  ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
						})   	 
			Else
				Alert('TES invalida:'+alltrim((cAliasPROD)->(D1_TES)))
			Endif
		
			Return  .F. 
		Else
			//Se movimentar estoque e for uma nota do Mês 04 trava a importação
			If SF4->F4_ESTOQUE == 'S' .AND. dtos(SF1->F1_DTDIGIT) < '20190501' 
				//GRAVA Array de LOG
        		AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)}								,;
					{'ZDB_MSG'	  ,'Doc: '+alltrim((cAliasCapa)->(F1_DOC))+'-'+alltrim((cAliasCapa)->(F1_SERIE))+', MOVIMENTA ESTOQUE MES 04. '},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_INDICE' ,1},;
					{'ZDB_TAB'  ,'SF4'},;
					{'ZDB_TIPOWF'  ,7},;
					{'ZDB_CHAVE'  ,alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
				}) 

				Return  .F.  
			EndIf
		Endif      
		
		//Valida se Rateio está preenchido
		aTemRateio := SD1RATCC()
		lValRat    := .T.
		cD1_RATEIO  := "2"
		//conout(' ------- TABELA ---- ')
		//Varre Tabela de Rateio
		For i := 1 to len(aTemRateio)
			//conout(' ------- VALORES ---- ')
		//	conout(aTemRateio[i][2])
			if alltrim(aTemRateio[i][2]) == ''
				lValRat := .F.
				cD1_RATEIO  := "1"
			Endif 

			_cCusto := 	alltrim(str(val( aTemRateio[i][2]) ) ) 
			//conout(_cCusto)
			Dbselectarea('CTT')
			DbSetorder(1)
			If !Dbseek(xFilial('CTT')+_cCusto)//alltrim(aTemRateio[i][2]))
				lValRat := .F.
			endif
		Next i 

		//Conout( (cAliasPROD)->PLACA_CC)
		// Conout(VAL( (cAliasPROD)->PLACA_CC ))

		//Conout( (cAliasPROD)->D1_CC ) 
		//Conout( VAL((cAliasPROD)->D1_CC) )
		
		//Se não tiver Centro de custo ou CC na placa Grava Log
		If 	VAL((cAliasPROD)->D1_CC) == 0 .AND.  VAL((cAliasPROD)->PLACA_CC) == 0 /*.AND. VAL((cAliasPROD)->RAT_CC) == 0 */.AND. 	;
					 !lValRat .AND. (cAliasPROD)->(EX_CC) == 1  .AND.  val( (cAliasPROD)->(DOC_CC) ) == 0
	  			AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
					{'ZDB_MSG'	  ,'Nota com Produto sem Centro de Custo ou CC Inválido: '+alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+' - '+alltrim((cAliasPROD)->(D1_COD))+'(ITEM '+ALLTRIM(STR((cAliasPROD)->(D1_ITEM)))+')'},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},; 
					{'ZDB_TAB'	  ,'SB1'},;
					{'ZDB_INDICE' ,1},; 
					{'ZDB_TIPOWF' ,9},; 
					{'ZDB_CHAVE'  ,alltrim( (cAliasPROD)->(D1_COD) )},;
					{'ZDB_DBCHAVE',alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
				})     
	
			Return  .F.							
		Endif   		 
	
	    //Quando a nota é lançada errada pelo usuario com valor de icms no lugar da aliquota ocasiona Errorlog no sistema
	    // Pois campo suporta apenas até 99 			
		If (cAliasPROD)->(D1_PICM)	> 99             
		
			AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
					{'ZDB_MSG'	  ,'% de Icms lançado errado, '+str((cAliasPROD)->(D1_PICM))+': '+SF1->F1_DOC+'-'+SF1->F1_SERIE+' - '+alltrim((cAliasPROD)->(D1_COD))},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},; 
					{'ZDB_TAB'	  ,'SB1'},;
					{'ZDB_INDICE' ,1},; 
					{'ZDB_TIPOWF' ,6},; 
					{'ZDB_CHAVE'  ,alltrim( (cAliasPROD)->(D1_COD) )},;
					{'ZDB_DBCHAVE',alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
				})  
				Return  .F.   
		Endif	 
		
		
		_cCusto :=  ""
		//Verifca se CC existe no Protheus
		If (cAliasPROD)->(EX_CC) == 1 .and.  len(aTemRateio) == 0 
			
			 	_cCusto := 	alltrim(str(val( (cAliasPROD)->(DOC_CC) ) ) )  
			 	
			 	//If VAL(_cCusto) == 0  .OR. alltrim(_cCusto) == ''  
			//		_cCusto := 	alltrim(str(val( (cAliasPROD)->(PLACA_CC_A) ) ) ) //;CONOUT('744')				
			//	Endif 
			 	
			  /*	If VAL(_cCusto) == 0   .OR. alltrim(_cCusto) == ''   
			   		_cCusto := 	alltrim(str(val( (cAliasPROD)->(RAT_CC) ) ) ) // ;CONOUT('746')
			 	Endif*/ 
				If VAL(_cCusto) == 0  .OR. alltrim(_cCusto) == '' 
					_cCusto := alltrim(str(val( (cAliasPROD)->(D1_CC) ) ) )  	
				Endif   
				If VAL(_cCusto) == 0  .OR. alltrim(_cCusto) == ''  
					_cCusto := 	alltrim(str(val( (cAliasPROD)->(PLACA_CC) ) ) ) //;CONOUT('744')				
				Endif 
			   
				 	 
				Dbselectarea('CTT')
				DbSetorder(1)
				If !Dbseek(xFilial('CTT')+alltrim(_cCusto))  .and. alltrim(_cCusto) <> ''
					//CONOUT('(cAliasPROD)->(D1_ITEM)')
					//CONOUT((cAliasPROD)->(D1_ITEM))
					AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Centro de Custo nao existe no Protheus: '+_cCusto+' - '+SF1->F1_DOC+'-'+SF1->F1_SERIE+' - '+alltrim((cAliasPROD)->(D1_COD))+'(ITEM '+ALLTRIM(STR((cAliasPROD)->(D1_ITEM)))+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},; 
						{'ZDB_TAB'	  ,'SB1'},;
						{'ZDB_INDICE' ,1},; 
						{'ZDB_TIPOWF' ,9},; 
						{'ZDB_CHAVE'  ,alltrim( (cAliasPROD)->(D1_COD) )},;
						{'ZDB_DBCHAVE',alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
						})   
					Return  .F.   
				Endif

				If  Val(_cCusto) == 0  .OR.  alltrim(_cCusto) == ''
					AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Centro de Custo NÃO PREENCHIDO: '+' - '+SF1->F1_DOC+'-'+SF1->F1_SERIE+' - '+alltrim((cAliasPROD)->(D1_COD))+'(ITEM '+ALLTRIM(STR((cAliasPROD)->(D1_ITEM)))+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},; 
						{'ZDB_TAB'	  ,'SB1'},;
						{'ZDB_INDICE' ,1},; 
						{'ZDB_TIPOWF' ,9},; 
						{'ZDB_CHAVE'  ,alltrim( (cAliasPROD)->(D1_COD) )},;
						{'ZDB_DBCHAVE',alltrim((cAliasCapa)->(F1_DOC))+'+'+alltrim((cAliasCapa)->(F1_SERIE))+'+'+alltrim((cAliasCapa)->(DBFORN))+'+'+alltrim((cAliasCapa)->(DBENT))};
						})   
					Return  .F.   
				Endif 
		
				      
		Endif	
	
		(cAliasPROD)->(dbskip())
	Enddo   
	        
	
	(cAliasPROD)->(dbgotop())
	While (cAliasPROD)->(!eof()) 	    
	   lGerouReg := .T.   


	   //Valida se Rateio está preenchido
		aTemRateio := SD1RATCC()
		lValRat    := .T.
		cD1_RATEIO  := "2"

		If len(aTemRateio) > 1 
			cD1_RATEIO  := "1"
		Endif 
	   
	   dbselectarea('SB1')
	   dbsetorder(1)
	   dbseek(xfilial('SB1')+alltrim((cAliasPROD)->(D1_COD)) ) 
	   
	   
	   dbselectarea('SF4')
	   dbsetorder(1)
	   dbseek(xfilial('SF4')+alltrim((cAliasPROD)->(D1_TES))) 
	   
	   //CONOUT(SF1->F1_SERIE+' - '+SF1->F1_DOC)
	   Begin Transaction 	           
	 		RecLock("SD1", lRegOK )
				SD1->D1_FILIAL 	:= SF1->F1_FILIAL
				SD1->D1_COD		:= SB1->B1_COD 
				SD1->D1_UM		:= SB1->B1_UM 
				SD1->D1_LOCAL   := SB1->B1_LOCPAD
				SD1->D1_RATEIO  := cD1_RATEIO//"2"
				if !(alltrim(cEmpant) $ '50/03')//alltrim(cEmpant) <> '50'
					SD1->D1_DESCRI  := SB1->B1_DESC
				Endif
				SD1->D1_QUANT   := (cAliasPROD)->(D1_QUANT)
				SD1->D1_VUNIT   := (cAliasPROD)->(D1_VUNIT)
				SD1->D1_TOTAL   := (cAliasPROD)->(D1_QUANT)*(cAliasPROD)->(D1_VUNIT)//MSD1->D1_TOTAL + ROUND(MSD1->D1_DESC ,2)
				SD1->D1_VALICM  := (cAliasPROD)->(D1_VALICM)//MSD1->D1_VALICM
				SD1->D1_VALDESC	:= (cAliasPROD)->(D1_VALDESC)//ROUND(MSD1->D1_DESC ,2)
				SD1->D1_PICM    := (cAliasPROD)->(D1_PICM)//MSD1->D1_PICM
				SD1->D1_FORNECE := SA2->A2_COD
				SD1->D1_LOJA    := SA2->A2_LOJA//cForLoja
				SD1->D1_DOC     := SF1->F1_DOC	//cDoc
				SD1->D1_EMISSAO := SF1->F1_EMISSAO//STOD(cDataEmis)
				SD1->D1_DTDIGIT := SF1->F1_DTDIGIT//STOD(cDataDigit)
				SD1->D1_SERIE   := SF1->F1_SERIE//cSerie
				//SD1->D1_BRICMS  := //MSD1->D1_BRICMS **VER AQUI
				SD1->D1_ICMSRET := (cAliasPROD)->(D1_ICMSRET)//MSD1->D1_ICMSRET
				SD1->D1_BASEICM := (cAliasPROD)->(D1_BASEICM)//MSD1->D1_BASEICM
			   //	SD1->D1_VALDESC := //MSD1->D1_VALDESC  **//VER AQUI
				SD1->D1_ITEM    := STRZERO((cAliasPROD)->(D1_ITEM),4)//cItem
				SD1->D1_TIPO    := SF1->F1_TIPO//"N"
				SD1->D1_ORIIMP  := "AGX635NE"  
				//Ver cadastro de TES NO dbgint 
				SD1->D1_TES     := SF4->F4_CODIGO//cTes 
				 
				cCFOP := SF4->F4_CF
				If alltrim(cUFEmp) <> alltrim(cUFForn)  
					cCFOP := '2'+substr(alltrim(SF4->F4_CF),2,3) 
				Endif        
				SD1->D1_CF      := cCFOP//SF4->F4_CF//cNatureza 
								
				SD1->D1_DESPESA := (cAliasPROD)->(D1_DESPESA)
				SD1->D1_VALFRE  := (cAliasPROD)->(D1_VALFRE)
				//SD1->D1_POSIPI  := SB1->B1_POSIPI     
				                          
				//Flag se Exige CC
				If (cAliasPROD)->(EX_CC) == 1 .AND. SF4->F4_ESTOQUE <> 'S'
					   
				 	SD1->D1_CC := 	alltrim(str(val( (cAliasPROD)->(DOC_CC) ) ) ) 
				 	
				 	//If VAL(SD1->D1_CC) == 0  .OR. alltrim(SD1->D1_CC) == ''  
				//		SD1->D1_CC  := 	alltrim(str(val( (cAliasPROD)->(PLACA_CC_A) ) ) ) //;CONOUT('744')				
				//	Endif 
			 			                             
					//Pega CC da linha do Item 
					If VAL(SD1->D1_CC) == 0  .OR. alltrim(SD1->D1_CC) == '' 
						SD1->D1_CC      := alltrim(str(val( (cAliasPROD)->(D1_CC) ) ) )   	
					Endif 
					
					/*If VAL(SD1->D1_CC) == 0   .OR. alltrim(SD1->D1_CC) == ''   
				   		SD1->D1_CC := 	alltrim(str(val( (cAliasPROD)->(RAT_CC) ) ) ) 
				 	Endif*/	
					
				    //Caso não haja Centro de Custo pega da Placa
					If VAL(SD1->D1_CC) == 0  .OR. alltrim(SD1->D1_CC) == ''  
						SD1->D1_CC := 	alltrim(str(val( (cAliasPROD)->(PLACA_CC) ) ) )  
					Endif     
					     
					// Verifica casos em que Foi criado um rateio mas o mesmo 
					// Soma 100% para um unico CC
					If VAL(SD1->D1_CC) == 0           
						If Len(aTemRateio) == 1  
							If aTemRateio[1][4] == 100
								SD1->D1_CC := alltrim( aTemRateio[1][2] ) 
							Endif 
						Endif                                                    
					Endif 
					
					If VAL(SD1->D1_CC) == 0 
						SD1->D1_CC := ""	
					Endif	
					      
				Endif
				SD1->D1_BASIMP6 := (cAliasPROD)->(D1_BASIMP6)
				SD1->D1_VALIMP6 := (cAliasPROD)->(D1_VALIMP6)
				SD1->D1_ALQIMP6 := (cAliasPROD)->(D1_ALIQPIS)  
				
				SD1->D1_BASIMP5 := (cAliasPROD)->(D1_BASIMP5)
				SD1->D1_VALIMP5 := (cAliasPROD)->(D1_VALIMP5) 
				SD1->D1_ALQIMP5 := (cAliasPROD)->(D1_ALIQCOF)  
				
				//Campos de IPI
				SD1->D1_VALIPI 	:= (cAliasPROD)->(D1_VALIPI) 
		   		SD1->D1_BASEIPI := (cAliasPROD)->(D1_BASEIPI) 
				SD1->D1_IPI 	:= (cAliasPROD)->(D1_IPI) //ALIQUOTA LEMBRAR  
				
				
				//Se movimentar estoque manda para Conta de Estoque 
				If SF4->F4_ESTOQUE == 'S'   
				
					//Valor despesas acessórias: 
					 nDespAc := ((cAliasPROD)->D1_VALIPI + (cAliasPROD)->D1_ICMSRET + (cAliasPROD)->D1_VALFRE + (cAliasPROD)->D1_DESPESA + (cAliasPROD)->SEGURO + (cAliasPROD)->FINANC + (cAliasPROD)->EMBALA + (cAliasPROD)->SERVIC - (cAliasPROD)->D1_VALDESC) / (cAliasPROD)->D1_QUANT
					//Valor Rateado:
					 nValRat := (cAliasPROD)->D1_VUNIT + nDespAc //Valor despesas acessórias
					//Valor ICMS Unitário: 
					nValIcm := ROUND( (cAliasPROD)->D1_VALICM / (cAliasPROD)->D1_QUANT ,4)
					//Valor PIS:
					nValPis := ROUND( (cAliasPROD)->D1_VALIMP6 / (cAliasPROD)->D1_QUANT ,4)
					//Valor COFINS:
					nValCofins := ROUND( (cAliasPROD)->D1_VALIMP5 / (cAliasPROD)->D1_QUANT ,4)
					//Custo Operação para cálculo do custo médio = ValorRateio - Valor ICMS - Valor PIS - Valor COFINS 
					nValCusto :=  nValRat - nValIcm - nValPis -  nValCofins 
					SD1->D1_CONTA  := SB1->B1_CONTA
					SD1->D1_CUSTO  := (ROUND(nValCusto,4) *  (cAliasPROD)->D1_QUANT ) 
				Else
					SD1->D1_CONTA   := SB1->B1_CTADESP   
				Endif
				 
				//Campos NFE 4.0 
				SD1->D1_BFCPANT := 0 
				SD1->D1_BSFCCMP := 0  
				SD1->D1_FCPAUX  := 0 
				SD1->D1_BASFECP := 0 
				SD1->D1_BSFCPST := 0 
				
	  			SD1->(MsUnlock())

				//Se existir Rateio, Grava tabela SDE
				If cD1_RATEIO == "1" .and. len(aTemRateio) > 1
					SD1GrvRat(aTemRateio)
				Endif
		
	  		   //Se controla Estoque Cria Almoxarifado
	   		   If SF4->F4_ESTOQUE == 'S'
		 	
				 	//Valida se Existe almoxarifado 
			   		Dbselectarea('SB2')
					Dbsetorder(1) 
					If !MsSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
						CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
					Endif 
			      
					//ATUALIZA SALDO EM ESTOQUE
					B2AtuComD1() 
	  				
				Endif

				//Se tiver Valor ou Base de C197, Grava tabela CDA 
				If (cAliasPROD)->CDA_BASE > 0  .or. (cAliasPROD)->CDA_VALOR > 0 

					cQuery := " SELECT R_E_C_N_O_, CDA_SEQ, CDA_NUMITE,"  
					cQuery += " (SELECT MAX(CDA_SEQ) FROM "+RetSqlName('CDA')+"(NOLOCK) WHERE D_E_L_E_T_= '' AND CDA_NUMERO = '"+SD1->D1_DOC+"' AND "
					cQuery += " CDA_SERIE = '"+SD1->D1_SERIE+"' AND CDA_CLIFOR = '"+SD1->D1_FORNECE+"' AND "
					cQuery += " CDA_FILIAL  = '"+SD1->D1_FILIAL+"' AND CDA_LOJA  = '"+SD1->D1_LOJA+"'  AND D_E_L_E_T_ = '' AND CDA_TPMOVI = 'E' ) AS MAXSEQ "				
					cQuery += " FROM "+RetSqlName('CDA')+"(NOLOCK)  WHERE "
					cQuery += " CDA_FILIAL  = '"+SD1->D1_FILIAL +"'  AND "
					cQuery += " CDA_NUMERO  = '"+SD1->D1_DOC +"'     AND "
					cQuery += " CDA_SERIE   = '"+SD1->D1_SERIE+"'   AND "
					cQuery += " CDA_CLIFOR = '"+SD1->D1_FORNECE+"' AND "
					cQuery += " CDA_LOJA    = '"+SD1->D1_LOJA+"'    AND "
					cQuery += " CDA_NUMITE  = '"+SD1->D1_ITEM+"'    AND "
					cQuery += " CDA_TPMOVI = 'E' AND D_E_L_E_T_ = '' "

					//conout(cQuery)

					If Select("QRYCDA") <> 0
						dbSelectArea("QRYCDA")
						dbCloseArea()
					Endif

					TCQuery cQuery NEW ALIAS "QRYCDA"

					If QRYCDA->(!eof())
						//Conout('CDA - TEM DADOS')
						lRecCDA := .F.
						DbSelectarea('CDA')
						DbSetOrder(1)
						Dbgoto(QRYCDA->R_E_C_N_O_)
					Else
						//Conout('CDA - NÃO TEM DADOS')
					    lRecCDA := .T.
					Endif 
					//conout(lRecCDA)
					//Conout('CDA - INICIO')
					Begin Transaction 
					Reclock('CDA',lRecCDA )
					
						If lRecCDA
						    CDA->CDA_FILIAL  := SD1->D1_FILIAL 
							CDA->CDA_NUMERO  := SD1->D1_DOC 
							CDA->CDA_SERIE   := SD1->D1_SERIE
							CDA->CDA_CLIFOR  := SD1->D1_FORNECE
							CDA->CDA_LOJA    := SD1->D1_LOJA
							CDA->CDA_NUMITE  := SD1->D1_ITEM
							CDA->CDA_SEQ 	 := SOMA1(QRYCDA->MAXSEQ)
							CDA->CDA_TPMOVI  := 'E'
							CDA->CDA_ESPECI  := 'SPED'
							CDA->CDA_CALPRO  := '2'
							CDA->CDA_TPLANC  := '2'
							CDA->CDA_SDOC    := '1'
						Endif 
						//conout('CDA - RECLOCK')
						CDA->CDA_CODLAN  := (cAliasPROD)->CDA_CODLAN
						CDA->CDA_BASE    := (cAliasPROD)->CDA_BASE
						CDA->CDA_ALIQ    := ROUND((cAliasPROD)->CDA_ALIQ,2)
						CDA->CDA_VALOR   := (cAliasPROD)->CDA_VALOR
						CDA->CDA_IFCOMP  := (cAliasPROD)->CDA_IFCOMP

					CDA->(MsUnlock())

					End Transaction

				Endif   			
	  			//Conout('CDA - FIM')
	  			 
	   	End Transaction 
	
		(cAliasPROD)->(dbskip())
	Enddo   
	     
	// Se não gerou nenhum Registro Suspende a transação
	If !lGerouReg 
		Return  .F.
	Else
		//Insere Contas a pagar do título
		ProcCP(SF1->F1_DTDIGIT)   
	Endif

Return .T.  


//Baixa dados no DBGint
Static Function BaixarNFE(xIntCapa)

	Local cNFEIN   := ""              
	Local nQtdeIN  := 0  
	Local cDoctos  := ""
	Local i        := 0

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
        cNFEIN += " STG_GEN_TABEMP_Codigo 	  =  "+alltrim(str(xIntCapa[i][1]))+""
		cNFEIN += " AND STG_GEN_TABFIL_Codigo	  =  "+alltrim(str(xIntCapa[i][2]))+""
		cNFEIN += " AND COM_NOTCOM_NUMERO 		  =  "+xIntCapa[i][3]+""
		cNFEIN += " AND COM_NOTCOM_SERIE 		  =  '"+xIntCapa[i][4]+"'"
		cNFEIN += " AND STG_GEN_TABENT_For_Codigo =  "+xIntCapa[i][5]+""
		cNFEIN += " AND STG_GEN_ENDENT_For_Codigo =  "+xIntCapa[i][6]+""
		    
		cDoctos += alltrim(xIntCapa[i][3])+'-'+alltrim(xIntCapa[i][4])+'('+alltrim(xIntCapa[i][5])+'-'+alltrim(xIntCapa[i][6])+'),'
   		//cNFEIN += ",'" + AllTrim((cAliasCapa)->(F1_DOC)+(cAliasCapa)->(F1_SERIE)) + "'"
		nQtdeIN += 1

		If (nQtdeIN >= 2) .Or. len(xIntCapa) == i 
			
			cNFEIN += ") )" 
			
			UpdateNFE(cNFEIN,cDoctos)

			nQtdeIN := 0
			cNFEIN  := ""
			cDoctos := ""
		EndIf
	Next i 

Return()

Static Function UpdateNFE(cNFEIN,cDoctos)

	Local cQuery      := ""   
	Local nTentativa := 0 
    
	//Atualiza CAPA
	cQuery += " UPDATE COM_NOTCOM SET "
	cQuery += " COM_NOTCOM_DHIntTotvs = current_timestamp() "
	cQuery += " WHERE (COM_NOTCOM_DHIntTotvs IS NULL "
	cQuery += cNFEIN
          
	
	If (TCSQLExec(cQuery) < 0)  
   		nTentativa := 0 
   		nRetSql := TCSQLExec(cQuery) 
   		While nRetSql < 0  .AND. nTentativa <= 3
			Conout("Falha ao executar SQL("+alltrim(str(nTentativa))+"): " + cQuery)
			Conout("TCSQLError() - " + TCSQLError()) 
			 Sleep( 10000 ) //Espera 10 segundos para executar novamente
			nTentativa++
		Enddo 
		
		//Caso não tenha conseguido gravar, grava Log 
		If nRetSql < 0
	 		AADD(aLogs,{;
				{'ZDB_DBEMP'  ,''},;
				{'ZDB_DBFIL'  ,''},;
				{'ZDB_MSG'	  ,'Erro Update no Documento-Serie(Fornecedor-Loja): '+cDoctos},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,''},;
				{'ZDB_FILIAL' ,''},;
				{'ZDB_DBCHAV' ,cNFEIN},; 
				{'ZDB_TAB' 	  ,''},; 
				{'ZDB_INDICE' ,1},;  
				{'ZDB_TIPOWF' ,8},; 
				{'ZDB_CHAVE'  ,''};
				})  
		Endif
				
	EndIf   
		           
Return()         

      
//   Contas a Pagar 
Static Function ProcCP(xDtDigit)  

	Local cPrefixo  := ""   
	Local cAliasSE2 := "AGX635SE2"
	Local cQuery    := ""   
	      
	cQuery := "SELECT "
	cQuery += "STG_GEN_TABEMP_Codigo AS DBEMP"
	cQuery += ",STG_GEN_TABFIL_Codigo AS DBFIL "
	cQuery += ",COM_NOTCOM_Numero AS E2_NUM "
	cQuery += ",COM_NOTCOM_Serie AS E2_SERIE "
	cQuery += ",COM_NOTCOM_Emissao AS E2_EMISSAO "
	cQuery += ",STG_GEN_TABENT_For_Codigo AS DBFORN	"
	cQuery += ",STG_GEN_ENDENT_For_Codigo AS DBENT "
	cQuery += ",COM_FINNOT_Parcela AS E2_PARCELA"
	cQuery += ",CXB_TABBAN_Codigo AS CODBAN "
	cQuery += ",COM_FINNOT_Valor AS E2_VALOR "
	cQuery += ",COM_FINNOT_Vencimento AS E2_VENCTO "
  	cQuery += ",COM_FINNOT_Created as E2_EMIS1 "
	//	cQuery += ",COM_FINNOT_Updated "
	cQuery += "FROM COM_FINNOT "
	cQuery += "WHERE " 
	cQuery += "STG_GEN_TABEMP_Codigo     	  =  '"+alltrim(str((cAliasCapa)->DBEMP))+"' "+chr(13)
	cQuery += " AND STG_GEN_TABFIL_Codigo     =  '"+alltrim(str((cAliasCapa)->DBFIL))+"' "+chr(13)
	cQuery += " AND COM_NOTCOM_Numero         =  '"+(cAliasCapa)->F1_DOC+"' "+chr(13)
	cQuery += " AND COM_NOTCOM_Serie          =  '"+(cAliasCapa)->F1_SERIE+"' "+chr(13)
	cQuery += " AND STG_GEN_TABENT_For_Codigo =  '"+(cAliasCapa)->DBFORN+"' "+chr(13)
	cQuery += " AND STG_GEN_ENDENT_For_Codigo =  '"+(cAliasCapa)->DBENT+"' "+chr(13)  
	
	//CONOUT(cQuery)
	U_AGX635CN("DBG")    
	
	If Select(cAliasSE2) <> 0
		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAliasSE2)  
	        
	cFil := STRZERO((cAliasSE2)->DBEMP,2) 
   
	U_AGX635CN("PRT")
	
	nCont := 1
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
		cPrefixo := substr(cSerie,1,3)
		cParcela := alltrim(cValToChar((cAliasSE2)->E2_PARCELA)) //StrZero(MSE2->E2_PARCELA,3) 
		
		dEmissao := (cAliasSE2)->E2_EMISSAO
		dVencto  := (cAliasSE2)->E2_VENCTO
		dDtDigit := (cAliasSE2)->E2_EMIS1

		//Verifico se o titulo nao foi gerado anteriormente pela entrada do sistema
		cQuery := ""
		cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("SE2") + " (NOLOCK) "
		cQuery += " WHERE E2_PREFIXO = '" +cPrefixo + "' "
		//cQuery += "   AND (E2_NUM     = '" + cTitulo + "' OR E2_NUM = '"  + cTitulo6 + "') "
		cQuery += "   AND (E2_NUM     = '" + cTitulo + "') "
		cQuery += "   AND E2_TIPO    = 'NF' "
		cQuery += "   AND E2_FORNECE =  '" +  cForCod + "' "
		cQuery += "   AND E2_LOJA    = '" + cForLoja + "' "
		//cQuery += "   AND E2_PARCELA = '" + cParcela + "' "
		cQuery += "   AND E2_ORIGEM = 'MATA100' "
		cQuery += "   AND E2_ORIIMP = ''  "
		cQuery += "   AND D_E_L_E_T_ <> '*'  "

		If Select("QRYSE2") <> 0
			dbSelectArea("QRYSE2")
			dbCloseArea()
		Endif
		//CONOUT(cQuery)
		TCQuery cQuery NEW ALIAS "QRYSE2"

		lTemTitulo := .f.
		dbSelectArea("QRYSE2")
		dbgotop()
		While !eof()
			lTemTitulo := .t.
			QRYSE2->(dbskip())
		EndDo
        
        //Se já tem o título GERADO PELA ROTINA PADRÃO ignora e da loop
		If lTemTitulo  == .t. //.OR. QRYSD1->R_E_C_N_O_ == 0
			//Conout("Titulo ->" + cPrefixo + "/" + cTitulo + " - Fornecedor: ->" + cForCod + " Loja->" + cForLoja + " - " + cForNome + " ja cadastrado!")
			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSkip())
			loop
		EndIf

		//Verifico se já existe titulo no contas a pagar
		cQuery := ""
		cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("SE2") + " (NOLOCK) "
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
		//CONOUT(cQuery)
		TCQuery cQuery NEW ALIAS "QRYSE2"

		lJaExiste := .f.
		dbSelectArea("QRYSE2")
		dbgotop()
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
			SE2->E2_ORIIMP  	:= "AGX635NE"
			SE2->E2_FILORIG		:= cFilEnt 
			SE2->E2_NATUREZ     := '201010'//Orientado pela vanderleia  
			If cEmpant == '50'
		   		SE2->E2_FILIAL      := xfilial('SE2')
			Endif
			//Se foi a Vista, Baixa Título
		    //	If dEmissao == dVencto
			//  	SE2->E2_BAIXA   := 	dEmissao 
			// 	SE2->E2_SALDO   :=    0 
			//	SE2->E2_MOVIMEN :=  dEmissao
			//	Endif  
			
			SE2->(MsUnLock())
            
		   /*conout('SE2->E2_EMIS1')
        	conout(SE2->E2_EMIS1)   
        	conout(dEmissao )
        	conout(dVencto  )     
        	
		   	If dEmissao == dVencto// dDtDigit == dVencto    //Realizo baixa automatica se o titulo for a vista.
					
			   	lRet    := .F.
				_aCabec := {}
				Aadd(_aCabec, {"E2_FILIAL",    SE2->E2_FILIAL ,     Nil})
				Aadd(_aCabec, {"E2_PREFIXO",   SE2->E2_PREFIXO,           Nil})
				Aadd(_aCabec, {"E2_NUM",       SE2->E2_NUM,            Nil})
				Aadd(_aCabec, {"E2_PARCELA",   SE2->E2_PARCELA,           Nil})
				Aadd(_aCabec, {"E2_TIPO",      SE2->E2_TIPO,              Nil})
				Aadd(_aCabec, {"E2_FORNECE",   SE2->E2_FORNECE,            Nil})
				Aadd(_aCabec, {"E2_LOJA",      SE2->E2_LOJA,           Nil})
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
				Aadd(_aCabec, {"AUTMOTBX",     "NOR ",              Nil})
				Aadd(_aCabec, {"AUTDTBAIXA",  IIF(empty(SE2->E2_EMIS1),date(),SE2->E2_EMIS1),  	   Nil})
				Aadd(_aCabec, {"AUTDTCREDITO",IIF(empty(SE2->E2_EMIS1),date(),SE2->E2_EMIS1),      Nil})
	
				lMsErroAuto := .F.
				lRetExec := .F.
				//RpcSettype(1)
				MSExecAuto({|x,y| fina080(x,y)},_aCabec, 3 )
				If lMsErroAuto
					CONOUT(' AGX635NE - ERRO FINA080')
					//MOSTRAERRO()  
					AADD(aLogs,{;
								{'ZDB_DBEMP'  ,''},;
								{'ZDB_DBFIL'  ,''},;
								{'ZDB_MSG'	  ,'AGX635 ERRO FINA080: '+cPrefixo+'-'+cTitulo},;
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
					CONOUT(' AGX635NE - SUCESSO FINA080')
					//lRet := .T.
				Endif
			  	
				If lRet
					cQuery := " UPDATE " + RETSQLNAME("SE5")
					cQuery += " SET E5_BANCO = 'CX1', E5_AGENCIA = '00001', E5_CONTA = '0000000001' "
					cQuery += " WHERE E5_PREFIXO = '"  +  cPrefixo        + "' "
					cQuery += "   AND E5_NUMERO     = '"  +  cTitulo        + "' "
					//cQuery += "   AND E5_DATA = '"  +  dDtDigit + "' "
					cQuery += "   AND E5_CLIFOR = '"  +  cForCod        + "' "
					cQuery += "   AND E5_LOJA    = '"  +  cForLoja      + "' "
					cQuery += "   AND D_E_L_E_T_ <> '*' "
					cQuery += "   AND E5_PARCELA = '" + alltrim(cParcela) + "' "
					TcSqlExec(cQuery)
				EndIf 
		
			EndIf   */
		
		End Transaction       

		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbskip())
	EndDo

Return()

      
//Valida Título já foi baixado no Protheus
User Function AGX635JB(xValor,xCte)    

	Local cQuery 	  := "" 
	Local lJaBaixado  := .F. 
	Local lValorDif   := .F.
	Local lPrefIgual  := .F.
	
	Default xCte 	 := .F.  
	
	//Verifico se já existe titulo no contas a pagar
	cQuery := ""
	cQuery := "SELECT R_E_C_N_O_,E2_BAIXA,E2_ORIIMP,E2_EMISSAO,E2_VENCTO FROM " + RetSqlName("SE2") + " (NOLOCK) "
	cQuery += " WHERE E2_PREFIXO  =  '" +SF1->F1_PREFIXO + "' "
	cQuery += "   AND E2_NUM     =  '" + SF1->F1_DOC + "' "
	//cQuery += "   AND E2_TIPO     =  '" + SF1->F1_TIPO + "' "
	cQuery += "   AND E2_FORNECE  =  '" + SF1->F1_FORNECE + "' "
	cQuery += "   AND E2_LOJA     =  '" + SF1->F1_LOJA + "' "  
	cQuery += "   AND E2_FILORIG  =  '" + SF1->F1_FILIAL+"' "
	//cQuery += "   AND E2_PARCELA  =  '" + cParcela + "' "
	cQuery += "   AND D_E_L_E_T_  = ''  "
	//cQuery += "   AND E2_BAIXA    <> '' "    

	If Select("AGX635JE") <> 0
		dbSelectArea("AGX635JE")
		AGX635JE->(dbCloseArea())
	Endif
	//CONOUT(cQuery)
	TCQuery cQuery NEW ALIAS "AGX635JE"

	dbSelectArea("AGX635JE")
	AGX635JE->(dbgotop())            	
	While  AGX635JE->(!eof())	
   		If !empty( AGX635JE->(E2_BAIXA) ) .AND. AGX635JE->(E2_EMISSAO) <> AGX635JE->(E2_VENCTO)//;.OR. (substr(alltrim(AGX635JE->E2_ORIIMP),1,6) <> 'AGX635')
   				
   				lJaBaixado := .T.	
   				
   				// Se Foi alterado o Valor da NOTA
   				// Marca Flag para não efetuar Alterações 
   				//Conout('xvalor')   
   				//Conout(xvalor)
   				//Conout(SF1->F1_VALBRUT)
   				IF xValor <> SF1->F1_VALBRUT .OR. AGX635JE->(E2_EMISSAO) <> DTOS(SF1->F1_EMISSAO)
   					lValorDif := .T.
   				Endif			
   	    Endif
   		AGX635JE->(dbskip())
	Enddo 
	
	conout('AGX635JB - '+IIF(lJaBaixado, 'Baixado ',' ')+SF1->F1_PREFIXO+' - '+ SF1->F1_DOC+' - '+ SF1->F1_FORNECE+' - '+  SF1->F1_LOJA )   
	 

	// Se título ainda nao foi baixado
	// Realiza as exclusões                             
	// A pedido da Vanderleia foi incluido que caso 
	// o titulo já esteja baixado, mas como o mesmo valor da alteração
	// Exclui SF1/SD1 e não exclui SE2 => (lJaBaixado .and. !lValorDif )
	If !lJaBaixado  .OR. (lJaBaixado .and. !lValorDif ) 
	    	
		// Valida se Mes da digitação é Diferente do 
		// Mes corrente
		If Month(ddatabase) <> Month(SF1->F1_DTDIGIT) 
		
			//GRAVA Array de LOG
        	AADD(aLogs,{;
					{'ZDB_DBEMP'  ,0},;
					{'ZDB_DBFIL'  ,0},;
					{'ZDB_MSG'	  ,'Nota Excluida de Periodo anterior('+dtoc(SF1->F1_DTDIGIT)+'): '+SF1->(F1_DOC)+'-'+SF1->(F1_SERIE)+' - '+SF1->F1_FORNECE+'-'+SF1->F1_LOJA},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' ,SF1->F1_DOC+'+'+SF1->F1_SERIE},; 
					{'ZDB_TAB' 	  ,'SA2'},; 
					{'ZDB_INDICE' ,1},;   
					{'ZDB_TIPOWF' ,4},; 
					{'ZDB_CHAVE'  ,SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA};
					})   
	
	    Endif

		//Valida se é nota antiga com o Mesmo Período
		If  ( ddatabase - SF1->F1_DTDIGIT) > 365//YEAR(SF1->F1_DTDIGIT) <> Year(ddatabase)
			lPrefIgual := .T.
		Endif

		conout('AGX635JB - Excluindo dados: '+SF1->F1_DOC  ) 
		
		// Somente Exclui se o título não sofreu baixas
		iF !lJaBaixado //(lJaBaixado .and. !lValorDif )
			cQuery := " UPDATE " + RETSQLNAME("SE2") + " SET "
			cQuery += "        D_E_L_E_T_   = '*', "
			cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
			cQuery += " WHERE E2_PREFIXO  =  '" +SF1->F1_PREFIXO + "' "
			cQuery += "   AND (E2_NUM     =  '" + SF1->F1_DOC + "') "
			  //	cQuery += "   AND E2_TIPO     =  'NF' "
			cQuery += "   AND E2_FORNECE  =  '" + SF1->F1_FORNECE + "' "
			cQuery += "   AND E2_LOJA     =  '" + SF1->F1_LOJA + "' "
			cQuery += "   AND D_E_L_E_T_  <> '*'  "	 
			//conout(cQuery)
			If (TCSQLExec(cQuery) < 0)
				Conout("Falha ao Atualizar SE2: " + cQuery)
				Conout("TCSQLError() - " + TCSQLError())
			EndIf     
		Endif
		
		//Se tiver ESTOQUE Varre SD1 e debita o Saldo  
		DbSelectarea('SD1')
		DbSetOrder(1)
		If DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
         	DbSelectarea('SF4')
	   		DbSetOrder(1)
	   		If DbSeek(xfilial('SF4') + SD1->D1_TES )
		    	If SF4->F4_ESTOQUE = 'S'
				 	While SD1->(!eof()) .and. SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == ;   
				 				SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA 
				 				B2AtuComD1(-1) 
				    	SD1->(Dbskip()) 
				  	Enddo 
				  	DbSelectarea('SD1')
					DbSetOrder(1)
				 	SD1->(DbSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )	
			 	Endif 
			Endif
		Endif 
			
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
		
		//Exclui tabelas de Rateio
		cQuery := " UPDATE " + RETSQLNAME("SDE") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += " WHERE "
		cQuery += "   DE_DOC     =  '" + SF1->F1_DOC + "' "
		cQuery += "   AND DE_SERIE     =  '"+SF1->F1_SERIE+"' "
		cQuery += "   AND DE_FORNECE  =  '" + SF1->F1_FORNECE + "' "
		cQuery += "   AND DE_LOJA     =  '" + SF1->F1_LOJA + "' " 
		cQuery += "   AND DE_FILIAL   =  '" + SF1->F1_FILIAL + "' "
		cQuery += "   AND D_E_L_E_T_  <> '*'  "  
//		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SDE: " + cQuery)
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
//	    conout(cQuery)
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
//   		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SFT: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf  
				
		If xCte
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
		
		Endif 
		
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
//		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SF1: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf   
		

		cQuery := " UPDATE " + RETSQLNAME("CDA") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ " 
		cQuery += " WHERE "
		cQuery += "   CDA_NUMERO      =  '" + SF1->F1_DOC + "' "
		cQuery += "   AND CDA_SERIE   =  '"+SF1->F1_SERIE+"' "
		cQuery += "   AND CDA_CLIFOR  =  '" + SF1->F1_FORNECE + "' "
		cQuery += "   AND CDA_LOJA    =  '" + SF1->F1_LOJA + "' " 
		cQuery += "   AND CDA_FILIAL  =  '" + SF1->F1_FILIAL + "' "
		cQuery += "   AND CDA_TPMOVI = 'E' AND D_E_L_E_T_  <> '*'  "  
//		conout(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar CDA: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf  

			
	Endif 
	
	//Se Já baixado, mas com mesmo valor não excluí o Título
	If (lJaBaixado .and. !lValorDif ) 
		lJaBaixado := .F.
	Endif  

	//Se Prefixo Igual força Geração de Log
	If lPrefIgual
		lJaBaixado := .T.
	Endif
	
Return lJaBaixado     

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


//Valida se Título ja existe 
Static Function ValPrefixo(xPrefixo,xDoc,xFornece,xLoja)    

	Local cQryTit 	:= "" 
	Local lNaotemTit := .T.
	
	cQryTit := ""
	cQryTit := " SELECT R_E_C_N_O_,E2_BAIXA,E2_ORIIMP,E2_EMISSAO,E2_VENCTO FROM " + RetSqlName("SE2") + " "
	cQryTit += " WHERE E2_PREFIXO  =  '" +xPrefixo /*SF1->F1_PREFIXO*/ + "' "
   	cQryTit += "   AND E2_NUM     =  '" + xDoc /*SF1->F1_DOC*/ + "' "
   	cQryTit += "   AND E2_FORNECE  =  '" + xFornece /*SF1->F1_FORNECE*/ + "' "
   	cQryTit += "   AND E2_LOJA     =  '" + xLoja /*SF1->F1_LOJA*/ + "' "  
	//cQryTit += "   AND E2_FILORIG  =  '" + SF1->F1_FILIAL+"' " 
   	cQryTit += "   AND D_E_L_E_T_  = ''  "	

	If Select("ValTitulo") <> 0
		dbSelectArea("ValTitulo")
		ValTitulo->(dbCloseArea())
	Endif
	CONOUT(cQryTit)
	TCQuery cQryTit NEW ALIAS "ValTitulo"

	dbSelectArea("ValTitulo")
	ValTitulo->(dbgotop())            	
	If ValTitulo->(!eof())	
	     lNaotemTit := .F.
		ValTitulo->(dbskip())
	EndIf


Return lNaotemTit   


//------------------------------------------+
// BUSCA INFORMAÇÃO DE RATEIO POR CC        |
//------------------------------------------+
Static Function SD1RATCC()

	Local cQuery    := ""
	Local cTRBRAT   := "TRBRAT"
	Local aRetRAT   := {}
	Local nTotQuant := 0 
	Local _i        := 0
	Local nPercRat  := 0 

	U_AGX635CN("DBG")  

	// Se xValida estiver Preenchido faz apenas a verificação se todos os CC
	// Estão preenchidos
	cQuery  += " SELECT "
	cQuery  += " COM_CONNFC_CCCarroTotvs AS CC, "
	//cQuery  += " FRT_TABCAR_A.FRT_TABCAR_CodigoCC AS CC,"
	cQuery  += " SUM(COM_CONNFC_QUANTIDADE) AS QUANT, "
	cQuery  += " COM_PRONOT_SEQUENCIA AS SEQ "
	cQuery  += " FROM COM_CONNFC COM_CONNFC "
	//cQuery  += " INNER JOIN FRT_TABCAR FRT_TABCAR_A ON FRT_TABCAR_A.FRT_TABCAR_CODIGO = COM_CONNFC.STG_FRT_TABCAR_Con_Codigo "
	cQuery  += " WHERE "
	cQuery  += " COM_CONNFC.COM_NOTCOM_Numero  	      = '"+cValtochar( (cAliasPROD)->(D1_DOC) )+"'   AND "
	cQuery  += " COM_CONNFC.COM_NOTCOM_Serie   		  = '"+(cAliasPROD)->(D1_SERIE)+"' AND "
	cQuery  += " COM_CONNFC.STG_GEN_TABENT_For_Codigo = '"+(cAliasPROD)->(DBFORN)+"'   AND "
	cQuery  += " COM_CONNFC.STG_GEN_ENDENT_For_Codigo = '"+(cAliasPROD)->(DBENT)+"'    AND "
	cQuery  += " COM_CONNFC.STG_GEN_TABFIL_Codigo     = '"+cValtochar(  (cAliasPROD)->(DBFIL) )+"'    AND "
	cQuery  += " COM_CONNFC.COM_PRONOT_SEQUENCIA = '"+cValtochar( (cAliasPROD)->(D1_ITEM) ) +"' AND "
	cQuery  += " COM_CONNFC.STG_GEN_TABEMP_Codigo	  = '"+cValtochar( (cAliasPROD)->(DBEMP) )+"'  "
	cQuery  += " GROUP BY COM_PRONOT_SEQUENCIA,COM_CONNFC_CCCarroTotvs "
	cQuery  += " ORDER BY COM_PRONOT_SEQUENCIA, COM_CONNFC_CCCarroTotvs "  
	
	conout(cQuery)
	If Select(cTRBRAT) <> 0
		dbSelectArea(cTRBRAT)
		(cTRBRAT)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cTRBRAT)  
	
	(cTRBRAT)->(dbgotop())

	While (cTRBRAT)->(!eof())
	
			AADD(aRetRAT,{ (cTRBRAT)->SEQ,;
						   ALLTRIM(STR(VAL((cTRBRAT)->CC))),;
					   	   (cTRBRAT)->QUANT, ;
							0;
							 })

		nTotQuant += (cTRBRAT)->QUANT
		
		(cTRBRAT)->(dbskip())
	Enddo
	
	// Calcula % de rateio, essa alteração foi necessária devido a existir rateio por parcela
	// para obter o % total da nota é realizado (valor / total) * 100
	For _i := 1 to len(aRetRAT)
		aRetRAT[_i][4] := Round( (aRetRAT[_i][3] / nTotQuant) * 100  ,2)	
		nPercRat += aRetRAT[_i][4]
	Next _i  
	
	//Adequa para ajustar o %
	If nPercRat <> 100  .and. len(aRetRAT) > 0 
		aRetRAT[len(aRetRAT)][4]	+= (100 - nPercRat )
	Endif

	U_AGX635CN("PRT")
		
Return aRetRAT


//------------------------------------------+
// GRAVA RATEIO POR CC NA TABELA SDE        |
//------------------------------------------+
Static Function SD1GrvRat(xTemRateio)

	Local _iRat := 0 
	
	//Varre Array de Rateio e Grava Tabela SDE
	For _iRat := 1 to len(xTemRateio)				
		DbSelectarea('SDE')
		Dbsetorder(1)	
		If _iRat == 1//Se for primeiro registro Verifica se já Existe na Tabela 
			If Dbseek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
				Exit
			Endif
		Endif 
		//Grava tabela SDE
		Reclock('SDE',.T.)
			DE_FILIAL  := SD1->D1_FILIAL
			DE_DOC	   := SD1->D1_DOC
			DE_SERIE   := SD1->D1_SERIE	
			DE_FORNECE := SD1->D1_FORNECE
			DE_LOJA	   := SD1->D1_LOJA
			DE_ITEMNF  := SD1->D1_ITEM
			DE_ITEM	   := cValToChar(StrZero(_iRat,2)) 
			DE_PERC	   := xTemRateio[_iRat][4]//%Rateio
			DE_CC	   := xTemRateio[_iRat][2]//Centro de Custo
			DE_CONTA   := SD1->D1_CONTA
			DE_ITEMCTA := SD1->D1_ITEMCTA
			DE_SDOC    := SD1->D1_SERIE	
			DE_CUSTO1  := ROUND( SD1->D1_CUSTO *(xTemRateio[_iRat][4]/100 ),2)
			//DE_CUSTO2//DE_CUSTO3//DE_CUSTO4//DE_CUSTO5//DE_CLVL
		SDE->(Msunlock())				
	Next _iRat

Return                  

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
