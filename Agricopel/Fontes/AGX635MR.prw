#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ROTINA DE INTEGRAÇÃO COM DBGINT - Nota de Entrada
*/
/*/{Protheus.doc} AGX635MR
//RELATORIO DE INTEGRAÇÃO COM DBGINT - MOVIMENTAÇÕES
@author Spiller
@since 18/03/2019
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/         
User Function AGX635MR(aEmpDePara,xAnoMes )

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local cEmpPara       := ""
	Local cFilialPara    := ""
	Local aImprime       := "" 
	Private nEmpDe       := 0  
	Private lClearEnv    := .F.         
	Private cAnoMesRel   := Substr(xAnoMes,1,4) +'-'+ Substr(xAnoMes,6,2)  
	Private cImprime        := ""   
	
	//bError := ErrorBlock({|oError| MostraLog(oError:Description,'ERRO EXECUCAO DA ROTINA' ,.T.) }) 
    //Begin Sequence 
	       
	For nCountDe := 1 To Len(aEmpDePara)
		conout('Iniciando AGX635MR - '+time())
		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3] 
				nFilde       := aEmpPara[nCountPara][1] 

				lClearEnv := .T.

				PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SB2","SD3","SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","XXS"
			   	
			   	conout(cEmpPara+'/'+cFilialPara)   

				RPCSetType(3)
			  	RPCSetEnv(cEmpPara, cFilialPara)       
			  	     			  		    
				SelectDBG(nEmpDe,nFilde)//Busca dados do DBgint

				SelectPRT(nEmpDe,nFilde)//Busca Dados do Protheus

				aImprime := ComparaQry()

				Imprime(aImprime)
			  	

				If Select('REQDBG') <> 0
					dbSelectArea('REQDBG')
					('REQDBG')->(dbCloseArea())
				Endif  

				If Select('REQPRT') <> 0
					dbSelectArea('REQPRT')
					('REQPRT')->(dbCloseArea())
				Endif  

			 	RPCClearEnv()
				dbCloseAll()
				RESET ENVIRONMENT
		Next nCountPara
           
	Next nCountDe 
	
	MostraLog(cImprime,'RELATORIO MOVIMENTACOES ESTOQUE',.F.)     
	
	//End Sequence
	//ErrorBlock(bError)	
		
Return(aEmpDePara)  


//Mostra Log em Tela
Static function MostraLog(xErro,xMsg,lErroSys)    
                 
	If lErroSys
		MemoWrite( "Rel_MOVIMENTACOES_DBGINT.csv", xMsg+'('+ xErro +')' ) 
	Else
		MemoWrite( "Rel_MOVIMENTACOES_DBGINT.csv", xErro )   
	Endif  
	
Return 


//Busca dados da Movimentação DBGint
Static Function SelectDBG(nEmpOrigem,nFilOrigem)

    Local cQuery    := "" 
	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1    

	// ET - Entrada de Transferência
	// ST - Saída de Transferencia
	// M  - Demais Movimentações  
	cQuery := " SELECT 'ET' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2,"+/*EST_MOVEST_Emp_Cod AS EMPDB,"*/"EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO   " 
	cQuery += " ,CONCAT( /*TRIM( CAST(EST_MOVEST_Created AS CHAR) ),*/ TRIM( CAST(EST_MOVEST_Mov_Cod AS CHAR) ),TRIM( EST_MOVEST_Documento ),TRIM( EST_MOVEST_Pro_Cod ) ) AS CHAVEDB "
	cQuery += " FROM EST_MOVEST "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/" SUBSTRING(EST_MOVEST_DATA,1,7) =  '"+cAnoMesRel+"' AND EST_MOVEST_Mov_Cod = '10' "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2')   "  
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LG'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif


	
	cQuery += " UNION ALL "
			                          
	cQuery += " SELECT 'ST' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2,"+/*EST_MOVEST_Emp_Cod AS EMPDB,"*/"EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO " 
	cQuery += " ,CONCAT( /*TRIM( CAST(EST_MOVEST_Created AS CHAR) ),*/ TRIM( CAST(EST_MOVEST_Mov_Cod AS CHAR) ),TRIM( EST_MOVEST_Documento ),TRIM( EST_MOVEST_Pro_Cod ) ) AS CHAVEDB "
	cQuery += " FROM EST_MOVEST "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/"  SUBSTRING(EST_MOVEST_DATA,1,7) = '"+cAnoMesRel+"' AND EST_MOVEST_Mov_Cod = '509' "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2')  " 
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LG'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif
   //	cQuery += " AND EST_MOVEST_DHIntTotvs IS NOT NULL " 
	//*****TESTES RETIRAAAAARRRR
   //	cQuery += "  AND EST_MOVEST_Fil_Cod = '14' "
	
	cQuery += " UNION ALL "

	cQuery += " SELECT 'M' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2,"+/*EST_MOVEST_Emp_Cod AS EMPDB,"*/"EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO    " 
	cQuery += " ,CONCAT( /*TRIM( CAST(EST_MOVEST_Created AS CHAR) ),*/TRIM( CAST(EST_MOVEST_Mov_Cod AS CHAR) ),TRIM( EST_MOVEST_Documento ),TRIM( EST_MOVEST_Pro_Cod ) ) AS CHAVEDB "
	cQuery += " FROM EST_MOVEST  "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/" SUBSTRING(EST_MOVEST_DATA,1,7) = '"+cAnoMesRel+"' AND EST_MOVEST_Mov_Cod NOT IN('12','509','10','1','508','9','507','511','510') "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2')  "  
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LG'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif	

	cQuery += "ORDER BY 17,4 "


	conout('AGX635MR - QUERY DBGINT')
	conout(cQuery)
			
	U_AGX635CN("DBG")   
	
	If Select('REQDBG') <> 0
		dbSelectArea('REQDBG')
		('REQDBG')->(dbCloseArea())
	Endif  

	TCQuery cQuery NEW ALIAS ('REQDBG')  

Return()       

//Busca Movimentos no Protheus
Static Function SelectPRT(nEmpOrigem,nFilOrigem)

	//Busca dados no Protheus
	cQuery := " SELECT RTRIM(LTRIM(D3_XCHVDBG)) AS CHAVEPRT, R_E_C_N_O_ as RECNO,D3_LOCAL  AS LOCAL,* FROM "+RetSqlName('SD3')+'(NOLOCK) SD3'
	cQuery += " WHERE  D3_FILIAL = '"+xfilial('SD3')+"' AND D3_XCHVDBG <> '' AND D_E_L_E_T_ = '' "      
	cQuery += " AND D3_TM <> '999' AND D3_ESTORNO <> 'S' AND SUBSTRING(D3_EMISSAO,1,6) = '"+strTran(cAnoMesRel,'-','')+"' "
	cQuery += " ORDER BY 1,3" 
	conout('query Protheus')
	conout(cQuery)
	

	U_AGX635CN("PRT")  
	If Select('REQPRT') <> 0
		dbSelectArea('REQPRT')
		('REQPRT')->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ('REQPRT')


Return() 


//Compara Protheus x DBgint
Static Function ComparaQry()

	Local aDados := {}

	DbSelectarea('REQDBG')
	REQDBG->(dbgotop())

	//Enquanto nao terminar de varrer as duas tabelas não Finaliza
	While REQDBG->(!eof()) .OR. REQPRT->(!eof())

		// Se for Lages Grava no almoxarifado LG
		If REQDBG->DBFIL == 14
			_cArmDes   := 'LG'	
		Else
			_cArmDes   := 'DB'			
		Endif                                                                                                                         
		
		_cDoc := iif( alltrim(REQDBG->DOCDB)<>'',STRTRAN(REQDBG->DOCDB,'-',''),'DB'+dtos(date())+STRTRAN(time(),':','' )) 
		_cProduto    := REQDBG->DBPROD
		_nQuant      := REQDBG->QTDDB
		_nValor      := REQDBG->VALORDB
		_dDateMov    := REQDBG->DATADB  
		_nValCM	     := REQDBG->CUSTOMDB 
		
		//Conout('AGX635MR - ComparaQry '+ _cDoc +' - ' + _cProduto)
		//Conout( alltrim(REQPRT->CHAVEPRT) +' - '+ alltrim(REQDBG->CHAVEDB) )

		//Totalizadores
		If  _nQuant <> 0  
			nTotCM       := Round( ABS(_nQuant)*_nValCM , 4 )
			nTotUnit     := Round( ABS(_nQuant)*_nValor , 4 ) 
		Else
			nTotCM       := Round( _nValCM , 4 )
			nTotUnit     := Round( _nValor , 4 )
		Endif
				
		//Regra de Preenchimento do custo 	      
		//Se o valor estiver zerado Grava custo médio
		If _nValor == 0 
			_nValor := _nValCM
		Endif 
		//Adequa caso seja uma requisição de acerto de custo
		If  _nQuant <> 0 
			_nCusto1     := ROUND( IIF(_nQuant < 0 ,iif( REQDBG->TPMOVDB <> 'ST', ABS(_nQuant)*_nValCM , ABS(_nQuant)*_nValor) ,  ABS(_nQuant)*_nValor) , 4 )
		Else
			_nCusto1     :=  ROUND( _nValor , 4 )
		Endif
		//Fim regra Custo
		
		//regra CC
		_cCC         := alltrim(str(val(  REQDBG->DBCC  ) ) ) //"7001" //Gravar aqui o CC  alltrim(str(val( (cAliasPROD)->(D1_CC) ) ) ) 
		If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
			_cCC := alltrim(str(val(  REQDBG->DBCC2 ) ) )
		Endif  
		If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
			_cCC := ""
		Endif  
		//Fim regra CC
		

		//Se Estiver posicionado no mesmo registro, grava
		If alltrim(REQPRT->CHAVEPRT)+REQPRT->D3_LOCAL == alltrim(REQDBG->CHAVEDB)+_cArmDes 
			//FILIAL 	 DOC. PRT 	 TM 	 QUANT	 CUSTO 	 CC 	 PRODUTO	 - 	 TM DBG 	 DOC DBG	 PROD.DBG 	 CUSTO IMPORT. 	 CUSTO MED.	 CUSTO. UNIT.  	 CC 	 DATA 	 QUANT

			AADD( aDados,{;
				  REQPRT->D3_FILIAL ,; //[1]
			 	  REQPRT->D3_DOC	,;//[2]
			  	  REQPRT->D3_TM ,;//[3]
			   	  STRTRAN( cvaltochar(REQPRT->D3_QUANT),'.',','),;//[4]
			      STRTRAN( cvaltochar(REQPRT->D3_CUSTO1),'.',','),;//[5]
				  REQPRT->D3_CC,;//[6]
				  REQPRT->D3_COD  ,;//[7]
				  " - " ,;//[8]
				  alltrim(REQDBG->CODMOVDB),;//[9]
				  alltrim(REQDBG->DOCDB),;//[10]
				  _cProduto,;//[11]
				  STRTRAN( cvaltochar(_nCusto1),'.',',' ),;//[12]
				  STRTRAN( cvaltochar( nTotCM)  ,'.',',' ),;//[13]
				  STRTRAN( cvaltochar( nTotUnit) ,'.',',' ),;//[14]
				  _cCC,;//[15]
				  dtoc(_dDateMov),;//[16]
				  STRTRAN(cvaltochar( _nQuant),'.',',');//[17]
			})

			 	REQPRT->(DbSkip())
			 	REQDBG->(DbSkip())
				LOOP

		// Se a chave do Protheus for MENOR Que a do DBGint
		// significa que existe no PROTHEUS e não Existe no DBGINT
		ElseIf (alltrim(REQPRT->CHAVEPRT)+REQPRT->D3_LOCAL < alltrim(REQDBG->CHAVEDB)+_cArmDes  .or. REQDBG->(eof()) .or. alltrim(REQDBG->CHAVEDB) == '') ;
				.AND. alltrim(REQPRT->CHAVEPRT) <> '' 
			AADD( aDados,{;
				  REQPRT->D3_FILIAL ,;//[1]
			 	  REQPRT->D3_DOC	,;//[2]
			  	  REQPRT->D3_TM ,;//[3]
			   	  STRTRAN( cvaltochar(REQPRT->D3_QUANT),'.',','),;//[4]
			      STRTRAN( cvaltochar(REQPRT->D3_CUSTO1),'.',','),;//[5]
				  REQPRT->D3_CC,;//[6]
				  REQPRT->D3_COD ,;//[7]
				  " - "  ,;//[8]
				  "NÃO EXISTE NO DBGINT" ,;//[9]
				   "",;//[10]
				   "",;//[11]
				   "",;//[12]
				   "",;//[13]
				   "",;//[14]
				   "",;//[15]
				   "",;//[16]
				   "";//[17
				   })

					conout('NÃO EXISTE DBGINT')
					CONOUT(alltrim(REQPRT->CHAVEPRT))
					Conout(alltrim(REQDBG->CHAVEDB))
					conout('****************')

				   REQPRT->(DbSkip())
				   LOOP
				
	
		// Se o Protheus for MAIOR que o DBgint
		// significa que existe no DBGINT e não Existe no PROTHEUS
		Elseif  (alltrim(REQPRT->CHAVEPRT)+REQPRT->D3_LOCAL  > alltrim(REQDBG->CHAVEDB)+_cArmDes  .or. REQPRT->(eof())  .or. alltrim(REQPRT->CHAVEPRT) == '')
			AADD( aDados,{;
				    "" ,; //[1]
			 	    "",;//[2]
			  	    "",;//[3]
			   	    "",;//[4]
			        "",;//[5]
				    "",;//[6]
				    "NÃO EXISTE NO PROTHEUS" ,;//[7]
				    " - ",;//[8]
					alltrim(REQDBG->CODMOVDB),;//[9]
					alltrim(REQDBG->DOCDB),;//[10]
					_cProduto,;//[11]
					STRTRAN( cvaltochar(_nCusto1),'.',',' ),;//[12]
					STRTRAN( cvaltochar( nTotCM)  ,'.',',' ),;//[13]
					STRTRAN( cvaltochar( nTotUnit) ,'.',',' ),;//[14]
					_cCC,;//[15]
					dtoc(_dDateMov),;//[16]
					STRTRAN(cvaltochar( _nQuant),'.',',');//[17]
					})
					conout('NÃO EXISTE PROTHEUS')
					CONOUT(alltrim(REQPRT->CHAVEPRT))
					Conout(alltrim(REQDBG->CHAVEDB))
					conout('****************')

					REQDBG->(DbSkip())
					LOOP
			Endif 

		//REQPRT->(DbSkip())
	Enddo

Return aDados


// Imprime os Dados 
Static Function Imprime(xImprime)
	
	//Local cImprime := ""
	Local _x := 0 
	Local _z := 0 
	
	cImprime += "FILIAL ; DOC. PRT ; TM ; QUANT; CUSTO ; CC ; PRODUTO; - ; TM DBG ; DOC DBG; PROD.DBG ; CUSTO IMPORT. ; CUSTO MED.; CUSTO. UNIT.  ; CC ; DATA ; QUANT"+ chr(13) + chr(10)
	
	For _x := 1 to len(xImprime)

		For _z := 1 to len(xImprime[_x])
			
			//conout(xImprime[_x][_z])
			cImprime += xImprime[_x][_z]+";"
			
		Next _z

		cImprime += chr(13) + chr(10)

	Next _x 

Return 
