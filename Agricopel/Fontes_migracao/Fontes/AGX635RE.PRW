#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "RWMAKE.CH"
/*
ROTINA DE INTEGRAÇÃO COM DBGINT - Nota de Entrada
*/
/*/{Protheus.doc} AGX635RE
//ROTINA DE INTEGRAÇÃO COM DBGINT - Relatório de Divergências
@author Spiller
@since 03/01/2018
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/               
User Function AGX635RE()

	Local aEmpDePara := {} 
	Local cPerg      := 'AGX635LO'  
	Local aParamsRE  := {} 
	             
	//Se não confirmou, Retorna
	If Pergunte(cPerg) 
	  	AADD(aParamsRE,MV_PAR01)//Rotina	
	  	AADD(aParamsRE,MV_PAR02)//Emissao de 
	  	AADD(aParamsRE,MV_PAR03)//Emissao até 
	Else
		MsgInfo('Pergunta nao encontrada!')
	Endif

    MsgRun( "Relatorio de Divergências - Aguarde..." , "Executando Relatório" , { || U_635ZREL(@aParamsRE)})  
    
    OpenSM0() //Abrir Tabela SM0 (Empresa/Filial) 
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DBSEEK('0101')) //Restaura Tabela
	cFilAnt := '01' //Restaura variaveis de ambiente
	cEmpAnt := '01'
	OpenFile('01' + '01')  
	//DBSELECTAREA('ZDB')
	//Dbsetorder(2)  
	  
Return
          


User Function 635ZREL(aParamsRE)

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local nQtdeNE        := 0
	Local cArqTmp		 := ""
	Local cEmpPara       := ""   
	Local cFilialPara    := "" 
	Private cCapaCTS     := ""    
	Private nEmpDe       := 0
	Private cAliasCapa   := ""    
	Private cAliasPROD   := ""  
	Private aLogs		 := {} //Array de Logs  
	Private lClearEnv    := .F.   
	
	// Monta Array que mapeia as empresas - DBGint X Protheus - aEmpresas{nEmpresa, {}}
	aEmpDePara := U_AGX635EM()
	                                    
	/* aParamsRE
		1  - Opcão  (1-NE/2-CS/NS/CE)
		2  - Emissao de 
		3  - Emissao ate	
    */
	conout('Iniciando AGX635RE - '+time())
	For nCountDe := 1 To Len(aEmpDePara)

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

			cEmpPara     := aEmpPara[nCountPara][2]
			cFilialPara  := aEmpPara[nCountPara][3] 
			nFilde       := aEmpPara[nCountPara][1] 
							
			lClearEnv := .T.   
			conout(aParamsRE[1])
			//Nota de Entrada  
		  	If aParamsRE[1] == 1 //Nota de entrada 
		   		conout('nota entrada- '+time())
		  		//PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5"
		   
			   		RPCSetType(3)
			  		RpcSetEnv(cEmpPara,cFilialPara)		
			  		    
			  		    // ******************** //
			  			// Verifica Exclusões   //
			  			// ******************** //
			  			cArqTmp := CriaArqEX(nEmpDe,nFilde)	
						cAliasEX := GetNextAlias()
						DbUseArea(.T., Nil, cArqTmp, (cAliasEX))
						nQtdeEx := (cAliasEX)->(RecCount())
						
						If nQtdeEx > 0
							ExcluirNFE(cAliasEX)
		    	   		Endif
			  		
			  		    // ******************** //
			  			// Verifica Inclusões   //
			  			// ******************** //			  			
			  			cArqTmp := CriaArqNE(nEmpDe,nFilde,aParamsRE)	
						cAliasCapa := GetNextAlias()
						DbUseArea(.T., Nil, cArqTmp, (cAliasCapa))
						nQtdeNE := (cAliasCapa)->(RecCount())
						
						If nQtdeNE > 0
							VerifNFE(cAliasCapa)
		    	    	Endif
			                
			 		RPCClearEnv()
					dbCloseAll()              
				//RESET ENVIRONMENT
					
		  	//CTE de Saída 
		  	ElseIf  aParamsRE[1] == 2 //CTE de saída 
		   		conout('Cte de saida- '+time())
		  		//PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5"

				   	RPCSetType(3)
			  		RPCSetEnv(cEmpPara, cFilialPara)
				
					//Busca dados e Grava no Arq de trabalho por Filial
					cArqTmp := CriaArqCS(nEmpDe,nFilde,aParamsRE)

					cCapaCTS := GetNextAlias()
					DbUseArea(.T., Nil, cArqTmp, (cCapaCTS))
					nQtdeCTS := (cCapaCTS)->(RecCount())
					  
					//Caso tenha algum CTE
					//Inclui dados no Protheus
					If nQtdeCTS > 0
						VerifCTS(cCapaCTS)
	                Endif
	                
				 	RPCClearEnv()
					dbCloseAll()
				
			   	//RESET ENVIRONMENT
			Endif
		  	
		Next nCountPara         
              
		FErase(cArqTmp + GetDbExtension())
		FErase(cArqTmp + OrdBagExt())
	Next nCountDe 
	 
	//Grava Logs
	If len(aLogs) > 0     
 		//Grava Relatorio
		GeraCSV(aLogs)
 	Else
 		MsgInfo('Nenhuma divergencia no periodo! ')
 	Endif
		
Return(aEmpDePara)
                            

//Busca dados da NFE de Entrada
Static Function SelectNFE(nEmpOrigem,nFilOrigem,aParamsRE)

	Local cAliasCapa := GetNextAlias()
	Local cQuery    := "" 
	
	Default nFilOrigem := 0
	conout(' AGX635RE SelectNFE')
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
	cQuery += " FROM COM_NOTCOM COM_NOTCOM      "+chr(13) 
	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = STG_GEN_TABENT_For_Codigo "
	cQuery += " 								AND STG_GEN_ENDENT_For_Codigo = GEN_ENDENT_Codigo"  
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON GEN_TABEMP_Codigo = STG_GEN_TABEMP_Codigo AND "
	cQuery += " GEN_NATOPE.GEN_NATOPE_Codigo = COM_NOTCOM.GEN_NATOPE_Codigo  "	
	cQuery += " WHERE "//COM_NOTCOM_DHIntTotvs IS NOT NULL AND"  //somente o que já foi importado
	cQuery += " 	  STG_GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem) 
	cQuery += " 	  AND  COM_NOTCOM_Atualizada = 'S' "//Somente Atualizadas
	cQuery += " 	  AND GEN_NATOPE_GeraLivro = 1  "  
	cQuery += " 	  AND  COM_NOTCOM_Entrada between '"+dtos(aParamsRE[2])+"' AND '"+dtos(aParamsRE[3])+"'
	
	//***TESTES 
   	//cQuery += " 	   AND  COM_NOTCOM_Numero IN ('1009')"//,'578452') "
	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0  
		cQuery += " AND  STG_GEN_TABFIL_Codigo = " + cValToChar(nFilOrigem)
    Endif   
   
   	U_AGX635CN("DBG")    
	
	If Select(cAliasCapa) <> 0
		dbSelectArea(cAliasCapa)
		(cAliasCapa)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasCapa)

Return(cAliasCapa)                        


//Verifica dados da Nota de Entrada
Static Function VerifNFE(cAliasCapa)

	Local lNovo  := .T.
	Local lRegOK := .T. 
	Local cFil   := '' 
    	  
	U_AGX635CN("PRT") 
	
	(cAliasCapa)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cAliasCapa)->(!eof())
		
		DBSELECTAREA('SA2') 
		SA2->(DbGoTop())
		SA2->(DbSetOrder(3))
		If !(SA2->(DbSeek(xFilial("SA2")+(cAliasCapa)->(CNPJ_CPF))))
				
			lRegOK := .F.  			
			DBSELECTAREA('SA2') 
			SA2->(DbGoTop())
			SA2->(DbSetOrder(3))
			SA2->(DbSeek(xFilial("SA2")+(cAliasCapa)->(CNPJ_CPF)))
						  
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
						{'ZDB_CHAVE'  ,(cAliasCapa)->(CNPJ_CPF)};
						})   		  
						  
			(cAliasCapa)->(dbskip()) 
			LOOP  
		Endif
		
		
		//Valida preenchimento de conta
		//Posteriormente será incluído automáticamente
		If alltrim(SA2->A2_CONTA) == ''      
		
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
						{'ZDB_CHAVE'  ,(cAliasCapa)->(CNPJ_CPF)};
						})   		  
		
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
		If !dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)  
	   		//GRAVA Array de LOG
        	AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cAliasCapa)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cAliasCapa)->(DBFIL)},;
				{'ZDB_MSG'	  ,'Doc. não gerado no Protheus: '+(cAliasCapa)->(F1_DOC)+'-'+(cAliasCapa)->(F1_SERIE)+'('+SA2->A2_NOME+')'},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_DBCHAV' ,(cAliasCapa)->(F1_DOC)+'+'+(cAliasCapa)->(F1_SERIE)+'+'+(cAliasCapa)->(DBFORN)+'+'+(cAliasCapa)->(DBENT)},; 
				{'ZDB_TAB' 	  ,'SF1'},; 
				{'ZDB_INDICE' ,3},; 
				{'ZDB_CHAVE'  ,(cAliasCapa)->(CNPJ_CPF)};
				})  
		Endif          	 
	 	                                                                                                                            
		(cAliasCapa)->(dbskip())  
	Enddo	                         
	
Return()
                

//Cria Arquivo de Trabalho
Static Function CriaArqNE(nEmpOrigem,nFilOrigem,aParamsRE)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0
	conout('CriaArqNE AGX635RE - '+time())
   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectNFE(nEmpOrigem,nFilOrigem,aParamsRE)

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
  

//Cria Arquivo de trabalho de CTE
Static Function CriaArqCS(nEmpOrigem,nFilOrigem,aParamsRE)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectCTS(nEmpOrigem,nFilOrigem,aParamsRE)

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

  

//Verificar Dados no Protheus
Static Function VerifCTS(cCapaCTS)

	Local lNovo    := .T.
	Local lRegOK   := .T. 
	Local cFil     := '' 
	Local cTipoCli := ""
	Local cEst     := "" 
    	  
	U_AGX635CN("PRT") 
	
	(cCapaCTS)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cCapaCTS)->(!eof())
		
		SA1->(DbSetOrder(3))
		SA1->(DbGoTop())
		If !SA1->(DbSeek(xFilial("SA1")+(cCapaCTS)->(CNPJ_CPF)))
			//GRAVA Array de LOG
        	AADD(aLogs,{;
				 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
					{'ZDB_MSG'	  ,'Cliente Sem Conta Cadastrada:'+(cCapaCTS)->(CNPJ_CPF)},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' ,(cCapaCTS)->(F2_DOC)+'+'+(cCapaCTS)->(F2_SERIE)+'+'+(cCapaCTS)->(DEST_COD)+'+'+(cCapaCTS)->(DEST_LOJA)},; 
					{'ZDB_TAB' 	  ,'SA1'},; 
					{'ZDB_INDICE' ,3},; 
					{'ZDB_CHAVE'  ,(cCapaCTS)->(CNPJ_CPF)};
					})     
						  
			(cCapaCTS)->(dbskip()) 
			LOOP  
		Else
	  		cEst     := SA1->A1_EST 
	  		cTipoCli := SA1->A1_TIPO 
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
		If dbseek(xfilial('SF2')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA) 
		   
		   //Se estiver cancelado e Existir no Protheus - Grava LOG
	   	   If (cCapaCTS)->(SITUA_CTE) == 5   
	   	   			
	   	   			AADD(aLogs,{;
						 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
							{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
							{'ZDB_MSG'	  ,'CTE Cancelado no DBGInt e Não Excluido no Protheus: '+_cDoc+_cSerie+'/('+SA1->A1_COD+'-'+SA1->A1_LOJA+')'},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,cEmpant},;
							{'ZDB_FILIAL' ,cFilAnt},;
							{'ZDB_DBCHAV' ,(cCapaCTS)->(F2_DOC)+'+'+(cCapaCTS)->(F2_SERIE)+'+'+(cCapaCTS)->(DEST_COD)+'+'+(cCapaCTS)->(DEST_LOJA)},; 
							{'ZDB_TAB' 	  ,'SF2'},; 
							{'ZDB_INDICE' ,1},; 
							{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA};
							})     
 
	   	    		(cCapaCTS)->(dbskip()) 
					LOOP 
	       Endif
	   	Else
	   		//Se não localizou no Protheus e Esteja como Transmitido grava LOG
	   	 	If (cCapaCTS)->(SITUA_CTE) == 4  
	   	 				AADD(aLogs,{;
						 	{'ZDB_DBEMP'  ,(cCapaCTS)->(DBEMP)},;
							{'ZDB_DBFIL'  ,(cCapaCTS)->(DBFIL)},;
							{'ZDB_MSG'	  ,'CTE Existe no DBGInt e não Existe no Protheus: '+_cDoc+_cSerie+'/('+SA1->A1_COD+'-'+SA1->A1_LOJA+')'},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,cEmpant},;
							{'ZDB_FILIAL' ,cFilAnt},;
							{'ZDB_DBCHAV' ,(cCapaCTS)->(F2_DOC)+'+'+(cCapaCTS)->(F2_SERIE)+'+'+(cCapaCTS)->(DEST_COD)+'+'+(cCapaCTS)->(DEST_LOJA)},; 
							{'ZDB_TAB' 	  ,'SF2'},; 
							{'ZDB_INDICE' ,1},; 
							{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA};
							})     
 
	   	    		(cCapaCTS)->(dbskip()) 
					LOOP 
	   		Endif
	   	Endif   
	   	
		(cCapaCTS)->(dbskip()) 
	Enddo  
	   	   
Return()                        


//Busca CTE´S para importação
Static Function SelectCTS(nEmpOrigem,nFilOrigem,aParamsRE )

    Local cCapaCTS := GetNextAlias()
    Local cQuery    := "" 	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1     
	
	//CTE´S
	cQuery := " SELECT  "
	cQuery += " CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo     AS DBEMP,     "+CHR(13)
	cQuery += " CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo     AS DBFIL,     "+CHR(13)
	cQuery += " CTE_MOVCTE.CTE_MOVCTE_ID		  AS IDCTE,     "+CHR(13) 
	cQuery += " GEN_NATOPE_TES 			      AS D2_TES,    "+CHR(13) 
	cQuery += " ENDENT.GEN_ENDENT_IF 	      AS CNPJ_CPF,  "+CHR(13)
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
 	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = STG_GEN_TABENT_CTe_Tom_Codigo "+CHR(13) 
   	//cQuery += " AND GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Des_Codigo  "+CHR(13) //AQUI
   	cQuery += " AND GEN_ENDENT_Codigo = STG_GEN_ENDENT_CTe_Tom_Codigo  "+CHR(13) 
 	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON STG_GEN_NATOPE_CTe_Codigo = GEN_NATOPE_Codigo  "+chr(13)
   	cQuery += " LEFT JOIN CTE_TABPRO CTE_TABPRO ON CTE_TABPRO.GEN_TABEMP_Codigo = CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo "+chr(13)
	cQuery += " AND CTE_TABPRO.CTE_TABPRO_ID = CTE_MOVCTE.STG_CTE_TABPRO_CTe_ID  "+chr(13)

   	cQuery += " WHERE "//CTE_MOVCTE_DHIntTotvs IS NULL AND "+CHR(13)
	cQuery += "   CTE_MOVCTE.STG_GEN_TABEMP_CTe_Codigo = " + cValToChar(nEmpOrigem)+""+CHR(13) 
	
	//Somente Cte´s com chave e cancelados ou trnasmitidos
	cQuery += " AND CTE_MOVCTE_Chave <> '' "  
   	cQuery += " AND (CTE_MOVCTE_SituacaoCTe =  4 OR CTE_MOVCTE_SituacaoCTe =  5)"  
   	cQuery += " AND  CTE_MOVCTE_Emissao between '"+dtos(aParamsRE[2])+"' AND '"+dtos(aParamsRE[3])+"' "	

	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0  
		cQuery += " AND  CTE_MOVCTE.STG_GEN_TABFIL_CTe_Codigo = " + cValToChar(nFilOrigem)
    Endif         
    //cQuery += " LIMIT 100 " 
    
    U_AGX635CN("DBG")    
	 
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

Return(cCapaCTS)


Static Function GeraCSV()
      
      Local nZDB_DBEMP   := 0 
      Local nZDB_DBFIL   := 0    
      Local nZDB_MSG     := 0 
      Local nZDB_DATA    := 0 
      Local nZDB_EMP     := 0 
      Local nZDB_FILIAL  := 0 
      Local nZDB_DBCHAV  := 0 
      Local nZDB_TAB     := 0 
      Local nZDB_INDICE  := 0 
      Local nZDB_CHAVE   := 0
      Local cMSgRel      := "" 
      
      For i := 1 to len(aLogs)
      	     
      		//cabeçalho
	      	If  i == 1	      	
		      
		      nZDB_DBEMP   := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_DBEMP"})  
		      nZDB_DBFIL   := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_DBFIL"})     
		      nZDB_MSG     := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_MSG"})  
		      nZDB_DATA    := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_DATA"})  
		      nZDB_EMP     := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_EMP"})  
		      nZDB_FILIAL  := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_FILIAL"})  
		      nZDB_DBCHAV  := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_DBCHAV"})  
		      nZDB_TAB     := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_TAB"})  
		      nZDB_INDICE  := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_INDICE"}) 
		      nZDB_CHAVE   := aScan(aLogs[i],{|x| alltrim(x[1])=="ZDB_CHAVE"}) 
		      
		      cMSgRel += 'Emp DBGint ;'
		      cMSgRel += 'Fil DBGint ;'
		      cMSgRel += 'Mensagem ; '
		      cMSgRel += 'Emp Prot.; '
		      cMSgRel += 'Fil Prot.; '+chr(13)
		      
	      	Endif  
	      	       	
	       	cMSgRel += alltrim(str(aLogs[i][nZDB_DBEMP][2]))+";"
	      	cMSgRel += alltrim(str(aLogs[i][nZDB_DBFIL][2]))+";"
	      	cMSgRel += aLogs[i][nZDB_MSG][2]+";"
	      	cMSgRel += aLogs[i][nZDB_EMP][2]+";"
	      	cMSgRel += aLogs[i][nZDB_FILIAL][2]+";"+chr(13) 
	      	
      Next i
		      

	cArq := 'AGX635RE'+dtos(ddatabase)+''+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+'.csv'
		
	//Grava Arquivo
	MEMOWRITE(cArq,cMSgRel)
	      
	If !ApOleClient("MsExcel")                     	
	 	MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
		Return	
	EndIf
		
	//Copia para temp e Abre no Excel
	__CopyFIle(cArq , AllTrim(GetTempPath())+cArq)             
		
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cArq)//cArqTrbex+".XLS")
	oExcelApp:SetVisible(.T.)                       
				                 
	fErase(cArq) //Deletando arquivo de trabalho	

Return


//Cria Arquivo de Trabalho
Static Function CriaArqEX(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

   //RPCSetType(3)
   //RPCSetEnv("01", "01")

	cAliasQry := SelectEX(nEmpOrigem,nFilOrigem)

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
                      

//Busca dados da NFE de Entrada
Static Function SelectEX(nEmpOrigem,nFilOrigem)

	Local cAliasCapa := GetNextAlias()
	Local cQuery    := "" 
	Default nFilOrigem := 0  
	
	cQuery := "SELECT "
	cQuery += "COM_NOTCOM_EXC_Empresa AS DBEMP,  "
	cQuery += "COM_NOTCOM_EXC_Filial  AS DBFIL,  "
	cQuery += "CAST(COM_NOTCOM_EXC_Numero AS CHAR) AS F1_DOC,  "  
	cQuery += "COM_NOTCOM_EXC_Serie   AS F1_SERIE, "
	cQuery += "COM_NOTCOM_EXC_Emissao AS F1_EMISSAO, "
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
                           


//Verifica dados no Protheus
Static Function ExcluirNFE(cAliasEX)

	Local lNovo  := .T.
	Local lRegOK := .T. 
	Local cFil   := '' 
    	  
	U_AGX635CN("PRT") 
		
	(cAliasEX)->(dbgotop())
	    
	//Varre o arquivo e Grava SF1
	While (cAliasEX)->(!eof())
		
		conout('AGX635RE - Excluir NF: '+(cAliasEX)->(F1_DOC)+'/'+(cAliasEX)->(F1_SERIE)+time())
		  
		//se NÃO encontrou Fornecedor, IGNORA
		DBSELECTAREA('SA2') 
		SA2->(DbGoTop())
		SA2->(DbSetOrder(3))
		If !(SA2->(DbSeek(xFilial("SA2")+(cAliasEX)->(CNPJ_CPF)))) 	
			(cAliasEX)->(dbskip()) 
			LOOP  
		Endif
	  
	  	dbselectarea(cAliasEX)       
		aTam    := {}
		aTam    := TamSX3("F1_DOC")
		_cDoc   := PADL(alltrim((cAliasEX)->(F1_DOC)),aTam[1],'0')
        
        aTam    := {}
		aTam    := TamSX3("F1_SERIE")	
        _cSerie := StrTran(PADR(alltrim((cAliasEX)->(F1_SERIE)),aTam[1],' '),'-','' )   
        
		//Verifica se já existe no Protheus
		dbselectarea('SF1')
		dbsetorder(1)
		If dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)  
	   	    
					//GRAVA Array de LOG
	        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasEX)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cAliasEX)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Nota Excluida no DBGint e nao Excluida no Protheus: '+_cDoc+_cSerie+'/('+SA2->A2_COD+'-'+SA2->A2_LOJA+')'},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cAliasEX)->(F1_DOC)+'+'+(cAliasEX)->(F1_SERIE)+'+'+(cAliasEX)->(DBFORN)+'+'+(cAliasEX)->(DBENT)},; 
						{'ZDB_TAB' 	  ,'SF1'},; 
						{'ZDB_INDICE' ,1},; 
						{'ZDB_CHAVE'  ,_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA};
						})   		  
		 		
		 		(cAliasEX)->(dbskip()) 
				LOOP
	 	Endif          
	 	
		(cAliasEX)->(dbskip())  
	Enddo	                         
	
Return()