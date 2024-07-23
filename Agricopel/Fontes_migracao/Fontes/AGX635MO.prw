#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ROTINA DE INTEGRAÇÃO COM DBGINT - Nota de Entrada
*/
/*/{Protheus.doc} AGX635MO
//ROTINA DE INTEGRAÇÃO COM DBGINT - MOVIMENTAÇÕES
@author Spiller
@since 18/03/2019
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/         
User Function AGX635MO(aEmpDePara,XREPROC )

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local nQtdeMOV       := 0
	Local cArqTmp		 := ""
	Local cEmpPara       := ""
	Local cFilialPara    := "" 
	Private nEmpDe       := 0
	Private cMovimenta   := ""  
	Private cExclui		 := ""  
	Private aIntCAPA	 := {} //Array com Notas que foram integradas
	Private aIntITENS	 := {} //Array com Notas que foram integradas  
	Private aLogs		 := {} //Array de Logs  
	Private lClearEnv    := .F.   
	Private lReproc      := xReproc  
	Private aItens116    := {}       
	Private cUlMesBKP    := ""  
	Private cMesAtual    := ""                                                    
	
	bError := ErrorBlock({|oError| MostraLog(oError:Description,.T.) }) 
	//bError := ErrorBlock({|oError|LogErroIni(oError)})
    Begin Sequence 

	For nCountDe := 1 To Len(aEmpDePara)
		conout('Iniciando AGX635MO - '+time())
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
			  	     
			  	                                         
			  		//Realiza a Integração das Exclusões
					cArqTmp    := CriaArqEXC(nEmpDe,nFilde) 
					cUlMesBKP  := dtos(GetMv("MV_ULMES")) 
					cMesAtual  := dtos( MonthSum( GetMv("MV_ULMES"),1 ) ) 					
					
					cExclui := GetNextAlias()
					DbUseArea(.T., Nil, cArqTmp, (cExclui))
					nQtdeEXC := (cExclui)->(RecCount())
				    
					If nQtdeEXC > 0
					   	InserirEXC(cExclui)
					Endif
			  	                  
			  	    //Realiza a Integração dos Movimentos
			  		//Cria Arquivo de Trabalho com dados do DBGint
					cArqTmp    := CriaArqMOV(nEmpDe,nFilde)       
					
					cMovimenta := GetNextAlias()
					DbUseArea(.T., Nil, cArqTmp, (cMovimenta))
					nQtdeMOV := (cMovimenta)->(RecCount())
				    
					If nQtdeMOV > 0
					  	InserirMOV(cMovimenta)
					Else
						AADD(aLogs,"("+cEmpAnt+'/'+cFilAnt+") - Não foram encontrados Requisições no Período!" )
					Endif
                	
                
                	
			 	RPCClearEnv()
				dbCloseAll()
				RESET ENVIRONMENT 
				
		Next nCountPara
           
		FErase(cArqTmp + GetDbExtension())
		FErase(cArqTmp + OrdBagExt())
	Next nCountDe 
	
	MostraLog('MOVIMENTACOES ESTOQUE',.F.)   
	
	End Sequence
	ErrorBlock(bError)	
	
Return(aEmpDePara)  

//Mostra Log em Tela
Static function MostraLog(xMsg,lErroSys)    
   
	Local clog := "" 
	//clog += xMsg + chr(13) + chr(10) 
	                  
	If  len(aLogs) == 0 .AND. !lErroSys
		clog := "Importação dos Movimentos do Mês('SD3') concluída com sucesso! " 
	Else
		clog := "Erro na Geração das Movimentações: "+ chr(13) + chr(10)+xMsg	
		//Return
	Endif           
	 
	clog  += chr(13) + chr(10)
	     
	For i := 1 to len(aLogs) 
	   clog +=  '['+aLogs[i][12][2]+']'+';'+'('+aLogs[i][6][2] +' - '+ aLogs[i][7][2]+')'+';'+ aLogs[i][3][2] +''+ chr(13) + chr(10)
	Next i 
	  
	MemoWrite( "Log_MOVIMENTACOES_DBGINT.txt", clog )  

Return              


//Cria Arquivo de dados
Static Function CriaArqMOV(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	cAliasQry := SelectMOV(nEmpOrigem,nFilOrigem)

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


Return(cArqTmp)  
                
//Busca dados da Movimentação DBGint
Static Function SelectMOV(nEmpOrigem,nFilOrigem)

    Local cMovTran  := GetNextAlias()
    Local cQuery    := "" 
	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1    
	
	cUlMesBKP :=  Substr(cUlMesBKP,1,4) +'-'+ Substr(cUlMesBKP,5,2) //+'-'+ Substr(cUlMesBKP,7,2) 
	cMesAtual :=  Substr(cMesAtual,1,4) +'-'+ Substr(cMesAtual,5,2) //+'-'+ Substr(cUlMesBKP,7,2)

	// ET - Entrada de Transferência
	// ST - Saída de Transferencia
	// M  - Demais Movimentações  
	cQuery := " SELECT 'ET' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2, EST_MOVEST_Emp_Cod AS EMPDB,EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO   " 
	cQuery += " FROM EST_MOVEST "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/" SUBSTRING(EST_MOVEST_DATA,1,7) =  '"+cMesAtual+"' AND EST_MOVEST_Mov_Cod = '10' "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2') "  
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LJ'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif
	//cQuery += " AND EST_MOVEST_DHIntTotvs IS NULL "   
		//*****TESTES RETIRAAAAARRRR
	//cQuery += "  AND EST_MOVEST_Fil_Cod = '14' "
	
	cQuery += " UNION ALL "
			                          
	cQuery += " SELECT 'ST' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2, EST_MOVEST_Emp_Cod AS EMPDB,EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO " 
	cQuery += " FROM EST_MOVEST "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/"  SUBSTRING(EST_MOVEST_DATA,1,7) = '"+cMesAtual+"' AND EST_MOVEST_Mov_Cod = '509' "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2') " 
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LJ'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif
   	//cQuery += " AND EST_MOVEST_DHIntTotvs IS NULL " 
	//*****TESTES RETIRAAAAARRRR
   //	cQuery += "  AND EST_MOVEST_Fil_Cod = '14' "
	
	cQuery += " UNION ALL "

	cQuery += " SELECT 'M' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2,EST_MOVEST_Emp_Cod AS EMPDB,EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO   " 
	cQuery += " FROM EST_MOVEST  "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/" SUBSTRING(EST_MOVEST_DATA,1,7) = '"+cMesAtual+"' AND EST_MOVEST_Mov_Cod NOT IN('509','10','1','508','9','507','511','510') "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2')  "  
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LJ'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif	
	//cQuery += " AND EST_MOVEST_DHIntTotvs IS NULL "  
	//*****TESTES RETIRAAAAARRRR
	//cQuery += "  AND EST_MOVEST_Fil_Cod = '14' "  

	conout('**AGX635MO - QUERY DBGINT')
	conout(cQuery)
			
	U_AGX635CN("DBG")    

	If Select(cMovTran) <> 0
		dbSelectArea(cMovTran)
		(cMovTran)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cMovTran)

Return(cMovTran)       

                   
       
//Inserir Movimento
Static function InserirMOV() 
	
	Local aMovOk   := {}  
	
   	(cMovimenta)->(dbgotop()) 
   	
   	//bError := ErrorBlock({|oError| MostraLog(aLogs,oError:Description,.T.) })   
   	                               
   	U_AGX635CN("PRT")  
    //BEGIN SEQUENCE                       
	While (cMovimenta)->(!eof())   
                                                                      
		// CHAVE DBGINT
		// Codigo Movimento | Documento | Serie | Cgc | Produto
		 cChaveDB := alltrim( (cMovimenta)->DBCRIADO)+alltrim( (cMovimenta)->CODMOVDB )+alltrim( (cMovimenta)->DOCDB )+alltrim( (cMovimenta)->DBPROD )
		
 	    If Requisitar((cMovimenta)->TPMOVDB,cChaveDB )                        	
			AADD(aMovOk,{(cMovimenta)->DBCRIADO,alltrim((cMovimenta)->CODMOVDB),alltrim((cMovimenta)->DOCDB),alltrim((cMovimenta)->DBPROD) })			
		Endif
				
		(cMovimenta)->(dbskip())
	Enddo 
	       
	//Baixar Registro DBGint  
	If Len(aMovOk) > 0 
		BaixarDB(aMovOk)
    Endif 
    //END SEQUENCE
   	//ErrorBlock(bError)
    
Return 
          

//Realiza os Movimentos
Static Function Requisitar(xOpcao,xChvDB)

	Local _aSD3      := {}  
	Local _cProduto  := ""
	Local _nQuant    := 0 
	Local _nValor    := 0 
	Local _cArmDes   := 'DB' 
	Local _cTM       := ""  
	Local _cCC       := ""  
	Local _dDateMov  := dDatabase  
	Local _nSaldoAtu := 0 
	Local _laRetOK   := .F. 
	Local _lTransf   := .F.
	Local _cDoc      := ""
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	
	Default xOpcao := 'M'  

	// Se for Lajes Grava no almoxarifado LG
	If(cMovimenta)->DBFIL == 14
		_cArmDes   := 'LG'	
	Endif                                                                                                                         
	
	_cDoc := iif( alltrim((cMovimenta)->DOCDB)<>'',STRTRAN((cMovimenta)->DOCDB,'-',''),'DB'+dtos(date())+STRTRAN(time(),':','' )) 
	_cProduto    := (cMovimenta)->DBPROD
	_nQuant      := (cMovimenta)->QTDDB
	_nValor      := (cMovimenta)->VALORDB
	_dDateMov    := (cMovimenta)->DATADB  
	_nValCM	     := (cMovimenta)->CUSTOMDB 
	   
	//Se o valor estiver zerado Grava custo médio
	If _nValor == 0 
		_nValor := _nValCM
	Endif 
	
	//Adequa caso seja uma requisição de acerto de custo
	If  _nQuant <> 0 
		_nCusto1     := ROUND( IIF(_nQuant < 0 ,iif( (cMovimenta)->TPMOVDB <> 'ST', ABS(_nQuant)*_nValCM , ABS(_nQuant)*_nValor) ,  ABS(_nQuant)*_nValor) , 4 ) 
	Else
		_nCusto1     :=  ROUND( _nValor , 4 )
	Endif

	_cCC         := alltrim(str(val(  (cMovimenta)->DBCC  ) ) ) //"7001" //Gravar aqui o CC  alltrim(str(val( (cAliasPROD)->(D1_CC) ) ) ) 
 
	If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
		_cCC := alltrim(str(val(  (cMovimenta)->DBCC2 ) ) )
	Endif  
	
	If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
		_cCC := ""
	Endif
	Dbselectarea('SB1')
	Dbsetorder(1)                
	SB1->(dbSeek(xfilial("SB1")+_cProduto))
	
	//Saída de Transferência
	If (cMovimenta)->TPMOVDB == 'ST'  	   
		_cTM     := "730"//"710" 
		_lTransf := .T.         	
	//Entrada de Transferência
	ElseIF (cMovimenta)->TPMOVDB == 'ET'	 	
	 	_cTM     := "130"//"110"             
		_lTransf := .T.
	Else	//Demais Movimentações
	  	If _nQuant	== 0 //
	  	   If 	alltrim((cMovimenta)->CODMOVDB) > '500'
	  	   		_cTM	:= "710"  	   
	  	   Else
	  	   		_cTM    := "110"
	  	   Endif
	  	Else
		  	If _nQuant	< 0  
			 	_cTM	:= "710"  
			Else
		  		_cTM    := "110"		 
			Endif 
		Endif  	  
		_lTransf := .F.
	Endif  
	
	Dbselectarea('SF5')
	DbSetOrder(1)
	If !(DbSeek(xfilial('SF5') + _cTM ))
	    AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cMovimenta)->(EMPDB)},;
			{'ZDB_DBFIL'  ,(cMovimenta)->(DBFIL)},;
			{'ZDB_MSG'	  ,'MOV ('+cEmpAnt+'/'+cFilAnt+') Tipo de Movimento não encontrado ('+_cTM+'): '+alltrim(_cDoc)+' / '+alltrim(_cProduto)+''},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,xChvDB},; 
			{'ZDB_TAB' 	  ,'SD3'},; 
			{'ZDB_INDICE' ,1},;   
			{'ZDB_TIPOWF' ,10},; 
			{'ZDB_CHAVE'  ,alltrim(_cDoc)+alltrim(_cProduto)};
			})   				  
		Return .F.
	Endif  
	
	//VERIFICA SE Já existe o Movimento
	cQuery := " SELECT R_E_C_N_O_ as RECNO,* FROM "+RetSqlName('SD3')+'(NOLOCK) SD3'
	cQuery += " WHERE  D3_FILIAL = '"+xfilial('SD3')+"' AND D3_XCHVDBG = '"+xChvDB+"' AND D_E_L_E_T_ = '' AND D3_TM <> '999' AND D3_ESTORNO <> 'S' "   
	   
	If Select('XREQUI') <> 0
		dbSelectArea('XREQUI')
		('XREQUI')->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ('XREQUI')
	
	('XREQUI')->(DbGotop())   
	
	If ('XREQUI')->(!eof())
	       
			
			if ('XREQUI')->D3_FILIAL  == xFilial("SD3") .AND.;
			   alltrim(('XREQUI')->D3_LOCAL)   == alltrim(_cArmDes)       .AND.;
			   alltrim(('XREQUI')->D3_COD)     == alltrim(SB1->B1_COD)    .AND.;
			   ('XREQUI')->D3_QUANT   == ABS(_nQuant)   .AND.;
			   ('XREQUI')->D3_EMISSAO == dtos(_dDateMov).AND.;
			   alltrim(('XREQUI')->D3_UM )     == alltrim(SB1->B1_UM)     .AND.;
			   alltrim(('XREQUI')->D3_TIPO )   == alltrim(SB1->B1_TIPO)   .AND.;
			   alltrim(('XREQUI')->D3_TM )     == alltrim(_cTM)           .AND.;
			   ('XREQUI')->D3_CUSTO1  == _nCusto1 		.AND.;  
			   alltrim(('XREQUI')->D3_CC  )	  == alltrim(_cCC)			.AND.;   
			   alltrim(('XREQUI')->D3_XCHVDBG) == alltrim(xChvDB)		 
				//CONOUT('XREQUI - IGNOROU '+ xChvDB )  
			    Return .T.               
			Else 
				//CONOUT('XREQUI - ATUALIZOU '+ xChvDB )                  
				dbselectarea('SD3')
				dbgoto(('XREQUI')->RECNO)  
		        IF _nCusto1 >= 0 .AND. ABS(_nQuant) >= 0 
					// aqui descomentar
				   	RecLock('SD3',.F.)   
						SD3->D3_QUANT  := ABS(_nQuant)
						SD3->D3_CUSTO1 := _nCusto1
						SD3->D3_XCMDBG := _nCusto1   
						SD3->D3_CC     :=  _cCC	 
						SD3->D3_TM     := alltrim(_cTM)
					SD3->(MsUnlock()) 
				Endif	  	 
				Return .T.  	
			Endif   
	Endif
	
	//cCodDbGint := "xxxxxxx"
	//cIteDbGint := "1"
	_nOpc := 3 //Inclusão 5=Estorno        

	  
	// Se não For uma Transferência e for um Consumo 
	// Valida se CC está preenchido
	If !_lTransf .and. _nQuant	< 0 
		If  alltrim(_cCC) == '' .or.  alltrim(_cCC) == '0'
			CONOUT('** ERRO AGX635MO***')
       		CONOUT(cEmpAnt+'/'+cFilAnt+': CC não preenchido para '+_cDoc+' / '+_cProduto+'')
       		//GRAVA Array de LOG
        	AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cMovimenta)->(EMPDB)},;
						{'ZDB_DBFIL'  ,(cMovimenta)->(DBFIL)},;
						{'ZDB_MSG'	  ,dtos(_dDateMov)+' MOV ('+cEmpAnt+'/'+cFilAnt+') CC não preenchido para '+alltrim(_cDoc)+' / '+alltrim(_cProduto)+''},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,xChvDB},; 
						{'ZDB_TAB' 	  ,'SD3'},; 
						{'ZDB_INDICE' ,1},;   
						{'ZDB_TIPOWF' ,10},; 
						{'ZDB_CHAVE'  ,alltrim(_cDoc)+alltrim(_cProduto)};
						})   				  
		
  		
			Return .F.			  
		Endif  
	Endif      
	
	Dbselectarea('SB1')
	Dbsetorder(1)                
	If SB1->(dbSeek(xfilial("SB1")+_cProduto))  
	      
		//Valida se Existe almoxarifado 
		Dbselectarea('SB2')
		Dbsetorder(1) 
		If !MsSeek(xFilial("SB2")+SB1->B1_COD+_cArmDes/*SB1->B1_LOCPAD*/)
			CriaSB2(SB1->B1_COD,_cArmDes/*SB1->B1_LOCPAD*/)
		Endif        
	
		//Se for um Consumo, Verifica Estoque
		If _nQuant	< 0 
		                   
			Dbselectarea('SB2')
			Dbsetorder(1)                
			If SB2->(dbSeek(xfilial("SB2")+SB1->B1_COD+_cArmDes/*SB1->B1_LOCPAD*/)) 
   				_nSaldoAtu := SaldoSB2() 
 				If _nSaldoAtu <  ABS(_nQuant)     
 				    CONOUT('** ERRO AGX635MO***')
       		  		CONOUT(cEmpAnt+'/'+cFilAnt+': PRODUTO '+SB1->B1_COD+' SEM SALDO PARA CONSUMO')
          			//GRAVA Array de LOG
		        	AADD(aLogs,{;
								{'ZDB_DBEMP'  ,(cMovimenta)->(EMPDB)},;
								{'ZDB_DBFIL'  ,(cMovimenta)->(DBFIL)},;
								{'ZDB_MSG'	  ,dtos(_dDateMov)+' MOV ('+cEmpAnt+'/'+cFilAnt+') PRODUTO '+alltrim(SB1->B1_COD)+' SEM SALDO PARA CONSUMO! '},;
								{'ZDB_DATA'	  ,ddatabase},;
								{'ZDB_HORA'	  ,time()},;
								{'ZDB_EMP'	  ,cEmpant},;
								{'ZDB_FILIAL' ,cFilAnt},;
								{'ZDB_DBCHAV' ,xChvDB},; 
								{'ZDB_TAB' 	  ,'SD3'},; 
								{'ZDB_INDICE' ,1},;   
								{'ZDB_TIPOWF' ,10},; 
								{'ZDB_CHAVE'  ,alltrim(_cDoc)+alltrim(_cProduto)};
							})   
									    
       		  		Return .F. 
       			Endif
       		Else
       		  	CONOUT('** ERRO AGX635MO***')
       		  	CONOUT(cEmpAnt+'/'+cFilAnt+': PRODUTO '+SB1->B1_COD+' SEM ALMOXARIFADO CRIADO!') 
       			//GRAVA Array de LOG
	        	AADD(aLogs,{;
							{'ZDB_DBEMP'  ,(cMovimenta)->(EMPDB)},;
							{'ZDB_DBFIL'  ,(cMovimenta)->(DBFIL)},;
							{'ZDB_MSG'	  ,dtos(_dDateMov)+' MOV ('+cEmpAnt+'/'+cFilAnt+')PRODUTO '+alltrim(SB1->B1_COD)+' SEM ALMOXARIFADO CRIADO!'},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,cEmpant},;
							{'ZDB_FILIAL' ,cFilAnt},;
							{'ZDB_DBCHAV' ,xChvDB},; 
							{'ZDB_TAB' 	  ,'SD3'},; 
							{'ZDB_INDICE' ,1},;   
							{'ZDB_TIPOWF' ,10},; 
							{'ZDB_CHAVE'  ,alltrim(_cDoc)+alltrim(_cProduto)};
						})   		    
      		 	Return .F.
 			Endif
	    Endif
	                
		//DBGInt Grava operações de saída como NEGATIVO
		_nQuant := ABS(_nQuant)            
	
		_aSD3:={{"D3_FILIAL"     ,xFilial("SD3")    ,NIL},;
				{"D3_LOCAL"      ,_cArmDes          ,NIL},;
				{"D3_COD"        ,SB1->B1_COD       ,NIL},;
				{"D3_QUANT"      ,_nQuant           ,NIL},;
				{"D3_EMISSAO"    ,_dDateMov		    ,NIL},;
				{"D3_UM"         ,SB1->B1_UM        ,NIL},;
				{"D3_TIPO"       ,SB1->B1_TIPO      ,NIL},;
				{"D3_TM"         ,_cTM              ,NIL},;
				{"D3_CUSTO1"     ,_nCusto1 		    ,NIL},;  
				{"D3_CC"  	     ,_cCC			    ,NIL},;   
				{"D3_XCHVDBG"    ,xChvDB		    ,NIL},;  
				{"D3_XCMDBG"     ,_nCusto1		    ,NIL},;
				{"D3_DOC"        ,""/*_cDocProxnum()*/,NIL}} 
				//D3_XNREQDB
  				//D3_XIREQDB
		//aqui descomentar	
		MSExecAuto({|x,y| mata240(x,y)},_aSD3,_nOpc)  
		
		IF lMsErroAuto            
			// Aqui Gravar LOG
			conout(" * AGX635MO * ERRO EXECAUTO")  
		
        	cRet  := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO Mostraerro() 
            //Conout(' *** cret *** ')
            conout(cRet)                          
			 
	   		//GRAVA Array de LOG
	     	AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cMovimenta)->(EMPDB)},;
					{'ZDB_DBFIL'  ,(cMovimenta)->(DBFIL)},;
					{'ZDB_MSG'	  ,cRet/*'MOV ('+cEmpAnt+'/'+cFilAnt+')ERRO NA GERAÇÃO REQUISIÇÃO:'+alltrim(_cDoc)+'/'+alltrim(SB1->B1_COD)+'/'+alltrim(str(_nQuant))*/},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' ,xChvDB},; 
					{'ZDB_TAB' 	  ,'SD3'},; 
					{'ZDB_INDICE' ,1},;   
					{'ZDB_TIPOWF' ,10},; 
					{'ZDB_CHAVE'  ,alltrim(_cDoc)+alltrim(SB1->B1_COD)};
					})   		    
	   		
	   		Return .F. 
		Else  
			conout('Inclusão OK '+alltrim(_cDoc)+'/'+alltrim(SB1->B1_COD) )  
			_lRetOK := .T.
		Endif
		
    Else
    	CONOUT(" * AGX635MO * Produto não cadastrado: "+_cProduto ) 
   		//GRAVA Array de LOG
     	AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cMovimenta)->(EMPDB)},;
				{'ZDB_DBFIL'  ,(cMovimenta)->(DBFIL)},;
				{'ZDB_MSG'	  ,dtos(_dDateMov)+' MOV ('+cEmpAnt+'/'+cFilAnt+')Produto não cadastrado: '+alltrim(_cProduto)},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_DBCHAV' ,xChvDB},; 
				{'ZDB_TAB' 	  ,'SD3'},; 
				{'ZDB_INDICE' ,1},;   
				{'ZDB_TIPOWF' ,10},; 
				{'ZDB_CHAVE'  ,alltrim(_cDoc)+alltrim(SB1->B1_COD)};
				})   		    
   		Return .F. 
    Endif  
    
   	ErrorBlock(bError)
  

Return _lRetOK      

//Atualiza Flag de Importação
Static function BaixarDB(xMovOk)

	Local cQuery 	:= ""
	Local cRegBaixa := ""  
	Default xMovOk 	:= {}
	   
	cQuery += " UPDATE EST_MOVEST SET "
	cQuery += " EST_MOVEST_DHIntTotvs  = current_timestamp() "
	cQuery += " WHERE EST_MOVEST_DHIntTotvs IS NULL AND  "
	
	For i := 1 to len(xMovOk)
		//AADD(aMovOk,{(cMovimenta)->DBCRIADO,(cMovimenta)->CODMOVDB,(cMovimenta)->DOCDB,(cMovimenta)->DBPROD })
		        
		//Monta Filtro de Query
		If i == 1 
			cRegBaixa += " concat(EST_MOVEST_Created,EST_MOVEST_Mov_Cod,EST_MOVEST_Documento,EST_MOVEST_Pro_Cod) IN( '"
		Else
			cRegBaixa += ",'"
		Endif 			
	      
		cRegBaixa += xMovOk[i][1]//(cMovimenta)->DBCRIADO//EST_MOVEST_Created  
		cRegBaixa += xMovOk[i][2]//(cMovimenta)->CODMOVDB//EST_MOVEST_Mov_Cod
		cRegBaixa += xMovOk[i][3]//(cMovimenta)->DOCD //EST_MOVEST_Documento
		cRegBaixa += xMovOk[i][4]//(cMovimenta)->DBPROD//EST_MOVEST_Pro_Cod       
		cRegBaixa += "'"
	Next i 
	
	If alltrim(cRegBaixa) <> ""
		cQuery += cRegBaixa+" )"
	Endif  
	  
	U_AGX635CN("DBG") 
	//Realiza a gravação da Flag no DBGint
	//Aqui descomentar
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao executar SQL: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf  
	
	U_AGX635CN("PRT")  
	
Return 
            
//Cria Arquivo de dados
Static Function CriaArqEXC(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	Local cArqTmp      := ""
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	cAliasQry := SelectEXC(nEmpOrigem,nFilOrigem)

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


Return(cArqTmp)  
                
//Busca dados da Movimentação DBGint
Static Function SelectEXC(nEmpOrigem,nFilOrigem)

    Local cMovEXC  := GetNextAlias()
    Local cQuery    := "" 
	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1    


	// ST - Saída de Transferencia
	// ET - Entrada de Transferência
	// M  - Demais Movimentações		                          
	cQuery += " SELECT "
	cQuery += " EST_MOVEST_EXC_Empresa    AS DBEMP , " //SMALLINT(6)NOT NULL
	cQuery += " EST_MOVEST_EXC_Filial     AS DBFIL, "  //SMALLINT(6)NOT NULL
	cQuery += " EST_MOVEST_EXC_Produto    AS DBPROD , " //VARCHAR(13)NOT NULL
	cQuery += " EST_MOVEST_EXC_Deposito   AS DBLOCAL , " //SMALLINT(6) NOT NULL
	cQuery += " EST_MOVEST_EXC_Data       AS DBDATA, "      //DATE NOT NULL
	cQuery += " CAST(EST_MOVEST_EXC_Movimento AS  CHAR) AS CODMOVDB  , " //SMALLINT(6) NOT NULL
	cQuery += " EST_MOVEST_EXC_Documento  AS DOCDB, "//VARCHAR(20) NOT NULL
	cQuery += " EST_MOVEST_EXC_Serie      AS DBSERIE, "    //CHAR(3) NOT NULL
	//cQuery += " EST_MOVEST_EXC_Entidade   AS DBENTIDAD, " //BIGINT(20) NOT NULL
	cQuery += " EST_MOVEST_EXC_Endereco   AS DBENDEREC, " //SMALLINT(6) NOT NULL
	cQuery += " CAST(EST_MOVEST_EXC_Created AS CHAR) AS DBCRIADO, "  //DATETIME NOT NULL
	cQuery += " EST_MOVEST_EXC_DHIntTotvs AS DBDATAIMP "//DATETIME DEFAULT NULL 
	cQuery += " FROM EST_MOVEST_EXC " 
	//cQuery += " LEFT JOIN EST_MOVEST  AS ESTMOV ON (EST_MOVEST_EXC_Empresa = EST_MOVEST_Emp_Cod AND EST_MOVEST_Fil_Cod = EST_MOVEST_EXC_Filial AND  "
	//cQuery += " EST_MOVEST_EXC_Documento = EST_MOVEST_Documento AND EST_MOVEST_Pro_Cod = EST_MOVEST_EXC_Produto) "	
	cQuery += " WHERE EST_MOVEST_EXC_DHIntTotvs IS NULL "  
	cQuery += " AND EST_MOVEST_EXC_Empresa = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_EXC_Data >= '2019-06-01'"  
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LJ'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_EXC_Filial = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_EXC_Filial = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_EXC_Filial = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif	
	
	cQuery += " AND EST_MOVEST_EXC_Movimento NOT IN('1','508','9','507','511','510') "  
	//cQuery += "	AND ESTMOV.EST_MOVEST_Documento IS NULL   "
	
	//TESTES RETIRAR
	//cQuery += "	AND EST_MOVEST_EXC_Produto = 'DBP00115' " 
	//cQuery += "	AND EST_MOVEST_EXC_Documento = '20190613-00005104' "
	
	conout(cQuery)

	U_AGX635CN("DBG")    

	If Select(cMovEXC) <> 0
		dbSelectArea(cMovEXC)
		(cMovEXC)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cMovEXC)

Return(cMovEXC)       

                   
       
//Inserir Movimento
Static function InserirEXC() 
	
	Local aMovOk   := {}  
	Local cQuery   := "" 
	Local cMovEXC2 := "MOVEXC2" 
	Local _aSD3    := {} 
	Local _nOpc    := 5
	
   	(cExclui)->(dbgotop())
   	                               
   	U_AGX635CN("PRT")  
                           
	While (cExclui)->(!eof())   
         
         _aSD3 := {}
                                                                      
		// CHAVE DBGINT
		// Codigo Movimento | Documento | Serie | Cgc | Produto
		cChaveDB := /*(cExclui)->DBCRIADO +*/ alltrim( (cExclui)->CODMOVDB ) + alltrim( (cExclui)->DOCDB ) + alltrim( (cExclui)->DBPROD )  
		 
		cQuery := " SELECT R_E_C_N_O_ AS RECNO,SD3.* FROM "+RetSqlName('SD3')+"(NOLOCK) SD3 "
		cQuery += " WHERE D3_XCHVDBG LIKE '%"+cChaveDB+"' AND D_E_L_E_T_ = '' AND D3_FILIAL = '"+xFilial('SD3')+"' "   
		cQuery += " AND SUBSTRING(D3_XCHVDBG,1,19) <= SUBSTRING('"+(cExclui)->DBCRIADO+"', 1,19 ) AND D3_ESTORNO <> 'S' "
		//CONOUT(cQuery)
		If Select(cMovEXC2) <> 0
			dbSelectArea(cMovEXC2)
			(cMovEXC2)->(dbCloseArea())
		Endif

		TCQuery cQuery NEW ALIAS(cMovEXC2)
		  
		(cMovEXC2)->(dbgotop())
		
		If (cMovEXC2)->(!eof()) 
			
			DbSelectarea('SD3')
			DbSetOrder(3)
			Dbgoto((cMovEXC2)->RECNO)
			
			DbSelectarea('SB1')
			DbSetOrder(1)
			DbSeek(xFilial('SB1') + xfilial('SB1')+SD3->D3_COD)   
			
			_cDoc        := SD3->D3_DOC
			_nQuant      := SD3->D3_QUANT
			_cProduto    := SD3->D3_COD
			cNumSeq 	 := SD3->D3_NUMSEQ  
			cTPMovimento := SD3->D3_TM 
			cUnidade	 := SD3->D3_UM 
			cArmazem     := SD3->D3_LOCAL
			dEmissao     := SD3->D3_EMISSAO
			
			aadd(_aSD3,{"D3_TM",cTPMovimento,})	
			aadd(_aSD3,{"D3_COD",_cProduto,})	
			aadd(_aSD3,{"D3_UM",cUnidade,})			
			aadd(_aSD3,{"D3_LOCAL",cArmazem,})	
			aadd(_aSD3,{"D3_QUANT",_nQuant,})	
			aadd(_aSD3,{"D3_EMISSAO",dEmissao,})					
			aadd(_aSD3,{"D3_NUMSEQ",cNumSeq,})    	// aqui deverá ser colocado o D3_NUMSEQ do registro que foi incluido e agora
		 	aadd(_aSD3,{"INDEX",3,})	
				
			lMsErroAuto := .F.	

			MSExecAuto({|x,y| mata240(x,y)},_aSD3,_nOpc)  
					
			IF lMsErroAuto            
			
				conout(" * EXCLUSAO AGX635MO * ERRO EXECAUTO")  
				//conout(Mostraerro())  
				cRet  := MostraErro("/dirdoc", "error.log")
		   		//GRAVA Array de LOG
		     	AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cExclui)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cExclui)->(DBFIL)},;
						{'ZDB_MSG'	  ,'EXCLUSAO MOV ('+cEmpAnt+'/'+cFilAnt+')ERRO NA GERAÇÃO REQUISIÇÃO:'+cRet/*+_cDoc+'/'+_cProduto+'/'+alltrim(str(_nQuant))*/},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,cChaveDB},; 
						{'ZDB_TAB' 	  ,'SD3'},; 
						{'ZDB_INDICE' ,1},;   
						{'ZDB_TIPOWF' ,10},; 
						{'ZDB_CHAVE'  ,_cDoc+_cProduto};
						})   		    
		   		_lRetOK :=  .F. 
			Else
				_lRetOK := .T.
				AADD(aMovOk,{(cExclui)->DBCRIADO,alltrim((cExclui)->CODMOVDB),alltrim((cExclui)->DOCDB),alltrim((cExclui)->DBPROD) })
			Endif
		Else
			_lRetOK := .T.
			AADD(aMovOk,{(cExclui)->DBCRIADO,alltrim((cExclui)->CODMOVDB),alltrim((cExclui)->DOCDB),alltrim((cExclui)->DBPROD) })		
		Endif
		
		(cExclui)->(dbskip())
	Enddo 
	       
	//Baixar Registro DBGint  
	If Len(aMovOk) > 0 
		BaixarEXC(aMovOk)
    Endif 
    
Return      

//Atualiza Flag de Importação
Static function BaixarEXC(xMovOk)

	Local cQuery 	:= ""
	Local cRegBaixa := ""  
	Local lControla := .F.
	Local nCont     := 0 
	Default xMovOk 	:= {}  
	
	U_AGX635CN("DBG") 
	   
	cQuery := " UPDATE EST_MOVEST_EXC SET "
	cQuery += " EST_MOVEST_EXC_DHIntTotvs  = current_timestamp() "
	cQuery += " WHERE EST_MOVEST_EXC_DHIntTotvs IS NULL AND  "
	
	For i := 1 to len(xMovOk) 
		        
		//Monta Filtro de Query
		If i == 1 
			cRegBaixa += " concat(EST_MOVEST_EXC_Created,EST_MOVEST_EXC_Movimento,EST_MOVEST_EXC_Documento,EST_MOVEST_EXC_Produto) IN( '"
		Else
			cRegBaixa += ",'"
		Endif 	      
	      
		cRegBaixa += xMovOk[i][1]//(cMovimenta)->DBCRIADO//EST_MOVEST_Created  
		cRegBaixa += xMovOk[i][2]//(cMovimenta)->CODMOVDB//EST_MOVEST_Mov_Cod
		cRegBaixa += xMovOk[i][3]//(cMovimenta)->DOCD //EST_MOVEST_Documento
		cRegBaixa += xMovOk[i][4]//(cMovimenta)->DBPROD//EST_MOVEST_Pro_Cod       
		cRegBaixa += "'"
		
		nCont ++             
		
		//quebra de 50 em 50 
		If  nCont >=  50 .or.  i == len(xMovOk)

			If alltrim(cRegBaixa) <> ""
				cQuery += cRegBaixa+" )"
			Endif  
			//conout(cQuery)  
			
			//Realiza a gravação da Flag no DBGint
			If (TCSQLExec(cQuery) < 0)
				Conout("Falha ao executar SQL: " + cQuery)
				Conout("TCSQLError() - " + TCSQLError())
			EndIf  
	    	nCont := 0 
	    	
	    	cQuery := " UPDATE EST_MOVEST_EXC SET "
			cQuery += " EST_MOVEST_EXC_DHIntTotvs  = current_timestamp() "
			cQuery += " WHERE EST_MOVEST_EXC_DHIntTotvs IS NULL AND  "

		Endif
		
	Next i 
	

	
	U_AGX635CN("PRT")  
	
Return      
	
// **** AQUI ALIMENTAR VARIÁVEIS**** //
//Estoque Inicial
/*xOpcao     := 'REQ'
_cProduto   := 'DBP00129       '
_nQuant     := 37
_nValor     := 386.91 
_cTM        := "003"
_cCC       := "7001" 
 */

//Requisição para Mesma Filial 
 /*	xOpcao     := 'REQ'
_cProduto   := 'DBP00129       '
_nQuant     := 3	
//nValor     := 386.91 
_cTM        := "710" 
_cCC       := "7001"*/
//Transferência para Outra Filial
/*xOpcao     := 'REQ'
	_cProduto   := 'DBP00129       '
	_nQuant     := 3	
	//nValor     := 386.91 
	_cTM        := "710" 
	lTransf    := .t. 
	_cCC       := "7001"
*/

//Realização de testes de Requisição
/*User Function 635MOREQ()   

    Local cProd := 'DBP00129'
    Local _nQuant := 5    
    Local _dDateMov := ctod('09/07/18')
    Local _cTM      :=  '110' 
    Local _nCusto1  := 1975.5885 
    Local _cCC  := '7001'   
    Local _cDoc := ""//'316-1' 
    Local _nOpc := 3  
    Private lMsErroAuto := .F.
    
    
    DbSelectarea('SB1')
    DbSetOrder(1)
    Dbseek(xfilial('SB1')+cProd )
	

	//DBGInt Grava operações de saída como NEGATIVO
		_nQuant := ABS(_nQuant)
	
		_aSD3:={{"D3_FILIAL"     ,xFilial("SD3")   ,NIL},;
				{"D3_LOCAL"      ,"DB"             ,NIL},;
				{"D3_COD"        ,SB1->B1_COD       ,NIL},;
				{"D3_QUANT"      ,_nQuant          ,NIL},;
				{"D3_EMISSAO"    ,_dDateMov		   ,NIL},;
				{"D3_UM"         ,SB1->B1_UM       ,NIL},;
				{"D3_TIPO"       ,SB1->B1_TIPO     ,NIL},;
				{"D3_TM"         ,_cTM             ,NIL},;
				{"D3_CUSTO1"     ,_nCusto1		   ,NIL},;  
				{"D3_CC"  	     ,_cCC			   ,NIL},;   
				{"D3_DOC"        ,_cDoc,NIL}} 
				//D3_XNREQDB
  				//D3_XIREQDB
			
	   	MSExecAuto({|x,y| mata240(x,y)},_aSD3,_nOpc)  
		
		IF lMsErroAuto            
			// Aqui Gravar LOG
			conout(" * AGX635MO * ERRO EXECAUTO")  
			conout(Mostraerro()) 
			_lRetOK := .T.
		Else
			_lRetOK := .F.
		Endif

Return           */   
  
/*  //Inserir Movimento de ESTORNO
User Function TESTESD3() 
	
	Local aMovOk   := {}  
	Local cQuery   := "" 
	Local cMovEXC2 := "MOVEXC2" 
	Local _aSD3    := {} 
	Local _nOpc    := 5  
	LOCAL cNumSeq  := ""
       
    _aSD3 := {}
                                                                       
	cQuery := " SELECT R_E_C_N_O_ AS RECNO,SD3.* FROM "+RetSqlName('SD3')+"(NOLOCK) SD3 "
	cQuery += " WHERE D3_XCHVDBG LIKE '%20190604-00005200DBP00115' AND D_E_L_E_T_ = '' AND D3_FILIAL = '"+xFilial('SD3')+"' "   
	cQuery += " AND SUBSTRING(D3_XCHVDBG,1,19) <= SUBSTRING('2019-06-05 10:27:43', 1,19 ) AND D3_ESTORNO <> 'S' "
	CONOUT(cQuery)
	If Select(cMovEXC2) <> 0
		dbSelectArea(cMovEXC2)
		(cMovEXC2)->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS(cMovEXC2)
	  
	(cMovEXC2)->(dbgotop())
		
	If (cMovEXC2)->(!eof()) 
			
		DbSelectarea('SD3')
		DbSetOrder(3)
		Dbgoto((cMovEXC2)->RECNO)
	
		
		
		DbSelectarea('SB1')
		DbSetOrder(1)
		DbSeek(xFilial('SB1') + xfilial('SB1')+SD3->D3_COD)   
		
		_cDoc        := SD3->D3_DOC
		_nQuant      := SD3->D3_QUANT
		_cProduto    := SD3->D3_COD
		cNumSeq 	 := SD3->D3_NUMSEQ  
		cTPMovimento := SD3->D3_TM 
		cUnidade	 := SD3->D3_UM 
		cArmazem     := SD3->D3_LOCAL
		dEmissao     :=  SD3->D3_EMISSAO
				
				 aadd(_aSD3,{"D3_TM",cTPMovimento,})	
				 aadd(_aSD3,{"D3_COD",_cProduto,})	
				 aadd(_aSD3,{"D3_UM",cUnidade,})			
				 aadd(_aSD3,{"D3_LOCAL",cArmazem,})	
				 aadd(_aSD3,{"D3_QUANT",_nQuant,})	
				 aadd(_aSD3,{"D3_EMISSAO",dEmissao,})					
				 aadd(_aSD3,{"D3_NUMSEQ",cNumSeq,})    	// aqui deverá ser colocado o D3_NUMSEQ do registro que foi incluido e agora
			 	 aadd(_aSD3,{"INDEX",3,})	                    // Aqui deverá ser indicado o número do indice da tabela SD3 que será utilizado.Desta forma, o movimento será estornado.
			
				
		
		lMsErroAuto := .F.	
		//Aqui descomentar
		MSExecAuto({|x,y| mata240(x,y)},_aSD3,_nOpc)  
				
		IF lMsErroAuto            
			MostraErro()	
		Else
			ALERT('FUNFOU! ')
		Endif

	EndIF
	          
Return   */   