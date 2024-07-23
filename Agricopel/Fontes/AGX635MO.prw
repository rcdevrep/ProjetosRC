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
User Function AGX635MO(aEmpDePara,xInTINC,xInTEXC )

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local nQtdeMOV       := 0
	//Local oTmpTable		 := Nil
	Local cEmpPara       := ""
	Local cFilialPara    := "" 
	Private nEmpDe       := 0
	Private cMovimenta   := ""  
	Private cExclui		 := ""  
	Private aIntCAPA	 := {} //Array com Notas que foram integradas
	Private aIntITENS	 := {} //Array com Notas que foram integradas  
	Private aLogs		 := {} //Array de Logs  
	Private lClearEnv    := .F.   
	//Private lReproc      := xReproc  
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

					cUlMesBKP  := DtoS(GetMvUltMes()) 
					cMesAtual  := DtoS( MonthSum(GetMvUltMes(),1 ) ) 					
					
					//Realiza a Integração das Exclusões
					If xInTEXC
						/*oTmpTable := CriaArqEXC(nEmpDe,nFilde) 
						cExclui := oTmpTable:GetAlias()*/

						cExclui := CriaArqEXC(nEmpDe,nFilde) 

						nQtdeEXC := (cExclui)->(RecCount())
						
						If nQtdeEXC > 0
							InserirEXC(cExclui)
						Endif

						(cExclui)->(DbCloseArea())
						//oTmpTable:Delete()
						//FreeObj(oTmpTable)
					Endif


			  	    //Realiza a Integração dos Movimentos
			  		//Cria Arquivo de Trabalho com dados do DBGint
					If xInTINC
						/*oTmpTable := CriaArqMOV(nEmpDe,nFilde)       

						cMovimenta := oTmpTable:GetAlias()*/

						cMovimenta := CriaArqMOV(nEmpDe,nFilde)   
						nQtdeMOV := (cMovimenta)->(RecCount())

						If nQtdeMOV > 0
							InserirMOV()
						Else
							AADD(aLogs,"("+cEmpAnt+'/'+cFilAnt+") - Não foram encontrados Requisições no Período!" )
						Endif

						(cMovimenta)->(DbCloseArea())
						//oTmpTable:Delete()
						//FreeObj(oTmpTable)
                	Endif

			 	RPCClearEnv()
				dbCloseAll()
				RESET ENVIRONMENT 
				
		Next nCountPara
	Next nCountDe 
	
	MostraLog('MOVIMENTACOES ESTOQUE',.F.)   
	
	End Sequence
	ErrorBlock(bError)	
	
Return(aEmpDePara)  

//Mostra Log em Tela
Static function MostraLog(xMsg,lErroSys)    
   
	Local clog := "" 
	Local i    := 0

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
	Local oTmpTable    := Nil
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	cAliasQry := SelectMOV(nEmpOrigem,nFilOrigem)

	aStruTmp := (cAliasQry)->(DbStruct())

	/*oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aStruTmp)
	oTmpTable:AddIndex("1", {aStruTmp[1][1]})
	oTmpTable:Create()

	cAliasArea := oTmpTable:GetAlias()*/
	cAliasArea := GetNextAlias()
	cArquivo := CriaTrab(,.F.)
	dbCreate(cArquivo,aStruTmp)
	dbUseArea(.T.,__LocalDriver,cArquivo,cAliasArea,.F.,.F.)
	
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

Return(cAliasArea)  
                
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
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,UPPER(EST_MOVEST_Pro_Cod) AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO   " 
	cQuery += " ,EST_MOVEST_Mov_Cod AS TPMOV "
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
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,UPPER(EST_MOVEST_Pro_Cod) AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO " 
	cQuery += " ,EST_MOVEST_Mov_Cod AS TPMOV "
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
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,UPPER(EST_MOVEST_Pro_Cod) AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO   " 
	cQuery += " ,EST_MOVEST_Mov_Cod AS TPMOV "
	cQuery += " FROM EST_MOVEST  "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/" SUBSTRING(EST_MOVEST_DATA,1,7) = '"+cMesAtual+"' AND EST_MOVEST_Mov_Cod NOT IN('12','509','10','1','508','9','507','511','510') "
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
		 cChaveDB := /*alltrim( (cMovimenta)->DBCRIADO)+*/alltrim( (cMovimenta)->CODMOVDB )+alltrim( (cMovimenta)->DOCDB )+alltrim( (cMovimenta)->DBPROD )
		
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
	cQuery += " WHERE  D3_FILIAL = '"+xfilial('SD3')+"' AND D3_XCHVDBG LIKE '%"+xChvDB+"%' AND D_E_L_E_T_ = '' AND D3_TM <> '999' AND D3_ESTORNO <> 'S' "   
	cQuery += " AND D3_LOCAL = '"+_cArmDes+"' "
	If Select('XREQUI') <> 0
		dbSelectArea('XREQUI')
		('XREQUI')->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ('XREQUI')

	If ('XREQUI')->(!eof())
	       
		   	//Chamado 674423 - Caso não tenha cc preenchido sugere o CC da filial
		    If alltrim(_cCC) == '' .AND. (cMovimenta)->(TPMOV) == 12
		    	_cCC := u_AGX635CC(  cEmpAnt , ('XREQUI')->D3_FILIAL )
			Endif

			if ('XREQUI')->D3_FILIAL  == xFilial("SD3") .AND.;
			   alltrim(('XREQUI')->D3_LOCAL)   == alltrim(_cArmDes)       .AND.;
			   alltrim(('XREQUI')->D3_COD)     == alltrim(SB1->B1_COD)    .AND.;
			   ROUND( ('XREQUI')->D3_QUANT, 2)   == ROUND( ABS(_nQuant),2)   .AND.;
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
				If alltrim(('XREQUI')->D3_LOCAL)   == alltrim(_cArmDes) .AND.  ROUND( ('XREQUI')->D3_QUANT, 2) == ROUND( ABS(_nQuant) ,2)
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
	Endif
	
	//cCodDbGint := "xxxxxxx"
	//cIteDbGint := "1"
	_nOpc := 3 //Inclusão 5=Estorno        

	  
	// Se (não For uma Transferência e for um Consumo) ou (uma entrada com movimento 13)
	// Valida se CC está preenchido
	If (!_lTransf .and. _nQuant	< 0) .OR. (_nQuant	> 0 .and. (cMovimenta)->(TPMOV) == 13)
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


		//Chamado 674423 - Caso não tenha cc preenchido sugere o CC da filial
		If alltrim(_cCC) == '' .AND. (cMovimenta)->(TPMOV) == 12
		   	_cCC := u_AGX635CC(  cEmpAnt , ('XREQUI')->D3_FILIAL )
		Endif       
	
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
	Local i         := 0
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
	Local oTmpTable    := Nil
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	cAliasQry := SelectEXC(nEmpOrigem,nFilOrigem)

	aStruTmp := (cAliasQry)->(DbStruct())

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aStruTmp)
	oTmpTable:AddIndex("1", {aStruTmp[1][1]})
	oTmpTable:Create()

	cAliasArea := oTmpTable:GetAlias()

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

Return(oTmpTable)  
                
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
	cQuery += " UPPER(EST_MOVEST_EXC_Produto)    AS DBPROD , " //VARCHAR(13)NOT NULL
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
	cQuery += " AND EST_MOVEST_EXC_Empresa = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_EXC_Data >= '"+cUlMesBKP+"' "  
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

                   
       
//Exclui Movimento
Static function InserirEXC(cExclui) 
	
	Local aMovOk   := {}  
	Local cQuery   := "" 
	Local cMovEXC2 := "MOVEXC2" 
	Local _aSD3    := {} 
	Local _nOpc    := 5
	Local _cArmDes := 'DB'

   	(cExclui)->(dbgotop())
   	                               
   	U_AGX635CN("PRT")  
                           
	While (cExclui)->(!eof())   
         
         _aSD3 := {}

		// Se for Lajes Grava no almoxarifado LG
		If(cExclui)->DBFIL == 14
			_cArmDes   := 'LG'	
		Else
			_cArmDes   := 'DB'	
		Endif  
	                                                                      
		// CHAVE DBGINT
		// Codigo Movimento | Documento | Serie | Cgc | Produto
		cChaveDB := /*(cExclui)->DBCRIADO +*/ alltrim( (cExclui)->CODMOVDB ) + alltrim( (cExclui)->DOCDB ) + alltrim( (cExclui)->DBPROD )  
		 
		cQuery := " SELECT R_E_C_N_O_ AS RECNO,SD3.* FROM "+RetSqlName('SD3')+"(NOLOCK) SD3 "
		cQuery += " WHERE D3_XCHVDBG LIKE '%"+cChaveDB+"%' AND D_E_L_E_T_ = '' AND D3_FILIAL = '"+xFilial('SD3')+"' "   
		cQuery += " AND SUBSTRING(D3_XCHVDBG,1,19) <= SUBSTRING('"+(cExclui)->DBCRIADO+"', 1,19 ) AND D3_ESTORNO <> 'S' "
		cQuery += " AND D3_LOCAL = '"+_cArmDes+"' "
		
		//CONOUT(cQuery)
		If Select(cMovEXC2) <> 0
			dbSelectArea(cMovEXC2)
			(cMovEXC2)->(dbCloseArea())
		Endif

		TCQuery cQuery NEW ALIAS(cMovEXC2)

		_lRetOK :=  .T. 
		
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

			// Se tiver emissao de mês ja fechado bloqueia  
			If Dtos(SD3->D3_EMISSAO) < cUlMesBKP//GetMv('MV_ULMES')
			
				AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cExclui)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cExclui)->(DBFIL)},;
						{'ZDB_MSG'	  ,'EXCLUSAO MOV ('+cEmpAnt+'/'+cFilAnt+')Exclusão de Requisição Mês anterior:'+_cDoc+'/'+_cProduto+'/'+alltrim(str(_nQuant))},;
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

			Endif
			
			If _lRetOK
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
	Local nCont     := 0
	Local i         := 0
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

Static Function GetMvUltMes()
Return(GetMv("MV_ULMES"))

//Chamado 463901 - FUNÇÃO UTILIZADA PARA CORREÇÃO DE REGISTROS EM DUPLICIDADE
User Function X635MOZ()

	Local cQuery   := ""
	Local cMovEXC2 :="X635MOZ"
	Local _nOpc    := 5

	cQuery := " SELECT R_E_C_N_O_ AS RECNO, *   FROM SD3010(NOLOCK) "
	cQuery += " WHERE D3_FILIAL = '03' AND D_E_L_E_T_ = '' AND D3_EMISSAO >= '20200201' "
	cQuery += " AND D3_DOC IN ('WACERUILL','WACERUIWG','WACERUIXX','WACERUKAQ','WACERUJ4N','WACERUIY1','WACERUJYB','WACERUJ8F','WACERUJUB','WACERUJSE','WACERUJOI','WACERUINQ','WACERUIO9','WACERUJYD','WACERUIX4','WACERUIX3',"
	cQuery += " 'WACERUK7K','WACERUJ9C','WACERUIV1','WACERUJ9X','WACERUJ9R','WACERUJ9N','WACERUJ9V','WACERUJ9P','WACERUJ9L','WACERUJ9T','WACERUJ9Z','WACERUJLS','WACERUJMI','WACERUK1O','WACERUIN7','WACERUIOX',"
	cQuery += " 'WACERUJA1','WACERUJA4','WACERUJ9B','WACERUJPS','WACERUK7M','WACERUKBG','WACERUKB9','WACERUJYF','WACERUJBR','WACERUILN','WACERUIMV','WACERUK70','WACERUKAB','WACERUJCA','WACERUJCC','WACERUJC4',"
	cQuery += " 'WACERUJC6','WACERUJCE','WACERUJCG','WACERUJC8','WACERUKC7','WACERUJI9','WACERUJI7','WACERUJIB','WACERUJI5','WACERUJYH','WACERUJ8H','WACERUJYJ','WACERUJ8J','WACERUJUD','WACERUJ8L','WACERUKDH',"
	cQuery += " 'WACERUJA7','WACERUJB7','WACERUJBJ','WACERUJU3','WACERUJMK','WACERUJ9E','WACERUJMT','WACERUITI','WACERUJLZ','WACERUJV3','WACERUK1L','WACERUJQQ','WACERUIW5','WACERUJ4X','WACERUIZI','WACERUIYE',"
	cQuery += " 'WACERUIZQ','WACERUJ04','WACERUJ00','WACERUJ6O','WACERUIZA','WACERUJ0Q','WACERUJ6H','WACERUJ65','WACERUJQL','WACERUJQG','WACERUJVS','WACERUJW7','WACERUJWI','WACERUJXE','WACERUJXS','WACERUK8X',"
	cQuery += " 'WACERUIIQ','WACERUJ1K','WACERUJ3E','WACERUIXJ','WACERUIS2','WACERUIQZ','WACERUIRS','WACERUIFQ','WACERUIWV','WACERUIK9','WACERUIGM','WACERUIP1','WACERUJ2J','WACERUIF1','WACERUIFX','WACERUIY2',"
	cQuery += " 'WACERUIJX','WACERUJ1Y','WACERUJ33','WACERUJ1A','WACERUJ5P','WACERUIHQ','WACERUILB','WACERUII7','WACERUIW3','WACERUIKQ','WACERUIL0','WACERUINW','WACERUILP','WACERUISU','WACERUIPB','WACERUIGE',"
	cQuery += " 'WACERUIQL','WACERUIQ9','WACERUIPX','WACERUIVP','WACERUIKS','WACERUILR','WACERUIQB','WACERUIGA','WACERUJ7Q','WACERUIW1','WACERUJU5','WACERUK85','WACERUK8U','WACERUJT5','WACERUJCI','WACERUJCN',"
	cQuery += " 'WACERUJCP','WACERUJCK','WACERUKC9','WACERUJIH','WACERUJIL','WACERUJIF','WACERUJID','WACERUJIJ','WACERUJYL','WACERUJ8N','WACERUJA9','WACERUK0F','WACERUJC2','WACERUK0A','WACERUITS','WACERUITU',"
	cQuery += " 'WACERUJM0','WACERUK7X','WACERUKDJ','WACERUJVL','WACERUITW','WACERUJ1M','WACERUIR1','WACERUJ8P','WACERUJ1O','WACERUIPZ','WACERUJ3X','WACERUJQS','WACERUJQT','WACERUIJF','WACERUIOB','WACERUJBH',"
	cQuery += " 'WACERUK0E','WACERUIJ0','WACERUJ7M','WACERUK1M','WACERUKB1','WACERUJD1','WACERUJCT','WACERUJCX','WACERUJCR','WACERUJCZ','WACERUJD3','WACERUJCV','WACERUJCQ','WACERUKCB','WACERUKCD','WACERUKCF',"
	cQuery += " 'WACERUJIP','WACERUJIR','WACERUJIS','WACERUJIT','WACERUJIN','WACERUKDL','WACERUKDN','WACERUIVV','WACERUIXV','WACERUIX5','WACERUKBY','WACERUJUU','WACERUJYQ','WACERUJYO','WACERUK74','WACERUJAB',"
	cQuery += " 'WACERUIKA','WACERUJ3G','WACERUIR3','WACERUIRL','WACERUIRE','WACERUIQW','WACERUIRZ','WACERUISG','WACERUIRU','WACERUK8M','WACERUK0Y','WACERUJUH','WACERUJSG','WACERUIWI','WACERUIWK','WACERUJO6',"
	cQuery += " 'WACERUJRE','WACERUK6E','WACERUK72','WACERUJ79','WACERUJR3','WACERUJUF','WACERUJYS','WACERUIIS','WACERUJD9','WACERUJD7','WACERUJDB','WACERUJDD','WACERUJD5','WACERUKCH','WACERUKCL','WACERUKCJ',"
	cQuery += " 'WACERUJIW','WACERUJIU','WACERUJIY','WACERUIO3','WACERUKDR','WACERUKDT','WACERUKDP','WACERUKA1','WACERUJ7S','WACERUJ26','WACERUIP3','WACERUJ2L','WACERUIF3','WACERUIET','WACERUIFY','WACERUIY4',"
	cQuery += " 'WACERUIJZ','WACERUJ20','WACERUJ34','WACERUIHS','WACERUILD','WACERUII9','WACERUJ5R','WACERUK0P','WACERUJ5T','WACERUITK','WACERUK0O','WACERUJ1Q','WACERUK11','WACERUJAD','WACERUIP5','WACERUJ2N',"
	cQuery += " 'WACERUIF5','WACERUIEV','WACERUIG0','WACERUIY6','WACERUIK1','WACERUJ22','WACERUJ35','WACERUJ1C','WACERUJ5V','WACERUIYY','WACERUJ1S','WACERUIRM','WACERUIRF','WACERUIFS','WACERUJ3I','WACERUJVV',"
	cQuery += " 'WACERUIU0','WACERUJ8R','WACERUJ7N','WACERUJMZ','WACERUJLT','WACERUJMW','WACERUJDN','WACERUJDP','WACERUJDH','WACERUJDJ','WACERUJDT','WACERUJDF','WACERUJDL','WACERUJDR','WACERUJJ4','WACERUJJ0',"
	cQuery += " 'WACERUJJ5','WACERUJJ2','WACERUJJ7','WACERUKCM','WACERUIOD','WACERUJAF','WACERUJAH','WACERUJT3','WACERUKC0','WACERUJDV','WACERUJDX','WACERUJDZ','WACERUJE1','WACERUJJ9','WACERUJJB','WACERUIU2',"
	cQuery += " 'WACERUIHC','WACERUIJH','WACERUJ9F','WACERUJP9','WACERUJO4','WACERUJSH','WACERUIN8','WACERUK78','WACERUJTL','WACERUJTD','WACERUJTM','WACERUJ7T','WACERUJTB','WACERUK76','WACERUJTN','WACERUK7O',"
	cQuery += " 'WACERUK0H','WACERUK7B','WACERUIVD','WACERUIOH','WACERUISY','WACERUIQF','WACERUIJ3','WACERUIUX','WACERUIJL','WACERUIV3','WACERUIHE','WACERUJ2A','WACERUIOF','WACERUISW','WACERUIQD','WACERUIJ1',"
	cQuery += " 'WACERUIUW','WACERUIVB','WACERUIJJ','WACERUIHD','WACERUJ28','WACERUJTP','WACERUJTG','WACERUJQ5','WACERUJ7U','WACERUJYV','WACERUJM1','WACERUJLV','WACERUJP0','WACERUKB3','WACERUJQ2','WACERUJPJ',"
	cQuery += " 'WACERUJRO','WACERUK9T','WACERUJC0','WACERUJBU','WACERUIIJ','WACERUIXL','WACERUJRW','WACERUJSI','WACERUJSS','WACERUISK','WACERUISI','WACERUJ18','WACERUJ4F','WACERUJ4H','WACERUJEA','WACERUJEC',"
	cQuery += " 'WACERUJE3','WACERUJE5','WACERUJEE','WACERUJE8','WACERUJEG','WACERUJEI','WACERUJJJ','WACERUJJH','WACERUJJP','WACERUJJN','WACERUJJL','WACERUJJF','WACERUJJD','WACERUKCN','WACERUJQB','WACERUK0I',"
	cQuery += " 'WACERUJSY','WACERUIMX','WACERUJ3R','WACERUJVQ','WACERUKEO','WACERUKEM','WACERUKEU','WACERUKEZ','WACERUKF0','WACERUKF1','WACERUKF2','WACERUKF3','WACERUKEQ','WACERUKER','WACERUKEV','WACERUJYX',"
	cQuery += " 'WACERUJ3T','WACERUJ73','WACERUJ3V','WACERUJ75','WACERUJ77','WACERUITY','WACERUILT','WACERUILX','WACERUIGW','WACERUIT4','WACERUIT6','WACERUILV','WACERUIU4','WACERUJ7Y','WACERUK7P','WACERUK7Q',"
	cQuery += " 'WACERUK6R','WACERUK1E','WACERUKAI','WACERUIMZ','WACERUIJN','WACERUJ2B','WACERUIO5','WACERUIX7','WACERUJBK','WACERUJBP','WACERUJTX','WACERUJBW','WACERUK0J','WACERUJAJ','WACERUJUW','WACERUJV5',"
	cQuery += " 'WACERUJBL','WACERUJBQ','WACERUJBY','WACERUJAL','WACERUJTZ','WACERUK8O','WACERUIS3','WACERUIXN','WACERUKEP','WACERUIX9','WACERUIXB','WACERUK6J','WACERUJVP','WACERUJ7W','WACERUIR5','WACERUK1T',"
	cQuery += " 'WACERUJPU','WACERUJOF','WACERUIJ7','WACERUIN1','WACERUIOJ','WACERUIPD','WACERUIQU','WACERUIT0','WACERUIT8','WACERUITM','WACERUIU6','WACERUJ2D','WACERUJ8B','WACERUJ3Z','WACERUJ14','WACERUIER',"
	cQuery += " 'WACERUK6T','WACERUJ80','WACERUJTI','WACERUJNM','WACERUIH8','WACERUJOY','WACERUJOU','WACERUJYZ','WACERUJQU','WACERUJEO','WACERUJES','WACERUJEM','WACERUJEU','WACERUJEK','WACERUJEZ','WACERUJEX',"
	cQuery += " 'WACERUJEQ','WACERUJJS','WACERUJJU','WACERUJPK','WACERUJQ0','WACERUINA','WACERUK8Q','WACERUITA','WACERUIR7','WACERUJ3J','WACERUJ4Z','WACERUJ6I','WACERUJ67','WACERUIKB','WACERUIEG','WACERUIGO',"
	cQuery += " 'WACERUJWZ','WACERUJWK','WACERUK8Z','WACERUIP7','WACERUJ2P','WACERUIF7','WACERUIEX','WACERUIG2','WACERUIY8','WACERUIK3','WACERUJ36','WACERUJ1E','WACERUIHU','WACERUILF','WACERUIIB','WACERUJB5',"
	cQuery += " 'WACERUJ7B','WACERUJPL','WACERUJRM','WACERUIJ9','WACERUIU8','WACERUIXP','WACERUJOG','WACERUJQ6','WACERUIFB','WACERUIVT','WACERUJAN','WACERUILZ','WACERUIMT','WACERUIUA','WACERUIQM','WACERUIIU',"
	cQuery += " 'WACERUJZ1','WACERUJ87','WACERUK0Q','WACERUJVG','WACERUK6G','WACERUJTR','WACERUIIH','WACERUIKK','WACERUIM1','WACERUINS','WACERUIT2','WACERUJ1I','WACERUJ3A','WACERUK1F','WACERUK87','WACERUJ47',"
	cQuery += " 'WACERUK1V','WACERUJPM','WACERUJUJ','WACERUK9J','WACERUKBA','WACERUKBI','WACERUJO7','WACERUKBR','WACERUK1G','WACERUKAE','WACERUK7F','WACERUJAR','WACERUJBN','WACERUJAP','WACERUJUX','WACERUJV7',"
	cQuery += " 'WACERUJY7','WACERUJBM','WACERUJF7','WACERUJF9','WACERUJFB','WACERUJF2','WACERUJF1','WACERUJZ3','WACERUJ8T','WACERUKCT','WACERUKCV','WACERUKCX','WACERUJAT','WACERUJY9','WACERUJBT','WACERUJBS',"
	cQuery += " 'WACERUK0L','WACERUKDV','WACERUKDX','WACERUJM2','WACERUJN1','WACERUJLX','WACERUJZ5','WACERUJN3','WACERUJPN','WACERUJ9J','WACERUJBI','WACERUK0G','WACERUIZ0','WACERUJ51','WACERUIJP','WACERUIOT',"
	cQuery += " 'WACERUIW6','WACERUIM3','WACERUIUC','WACERUITC','WACERUJ9D','WACERUJ99','WACERUJZ7','WACERUK0T','WACERUJT7','WACERUJRF','WACERUJPW','WACERUJPP','WACERUJPC','WACERUJP7','WACERUJT8','WACERUJOW',"
	cQuery += " 'WACERUJQZ','WACERUJFF','WACERUJFJ','WACERUJFH','WACERUJFD','WACERUJFN','WACERUJFL','WACERUJFP','WACERUKCZ','WACERUJK3','WACERUJK7','WACERUJK5','WACERUJK9','WACERUJ16','WACERUJMM','WACERUKE0',"
	cQuery += " 'WACERUKE1','WACERUJM4','WACERUIFD','WACERUJZ8','WACERUJN5','WACERUJMN','WACERUIOL','WACERUJ3K','WACERUIR8','WACERUIRO','WACERUIL3','WACERUKAU','WACERUKAW','WACERUJR7','WACERUK7U','WACERUJQE',"
	cQuery += " 'WACERUJR5','WACERUIL2','WACERUKC5','WACERUJ7D','WACERUJLQ','WACERUJB9','WACERUJAV','WACERUJUZ','WACERUJV9','WACERUJ4R','WACERUJVN','WACERUJPE','WACERUIUE','WACERUJ1U','WACERUIJD','WACERUJZ9',"
	cQuery += " 'WACERUJ8V','WACERUJ1W','WACERUJ8X','WACERUJ3C','WACERUJ7O','WACERUJ8Z','WACERUJPX','WACERUJUL','WACERUK1N','WACERUJO8','WACERUKBS','WACERUKBK','WACERUJUN','WACERUJ7F','WACERUIO7','WACERUIVX',"
	cQuery += " 'WACERUJZA','WACERUIS5','WACERUIIL','WACERUJ5X','WACERUJMA','WACERUJM8','WACERUJM7','WACERUJMP','WACERUIRH','WACERUIXD','WACERUJZC','WACERUIPL','WACERUJN8','WACERUJM6','WACERUIVE','WACERUIVJ',"
	cQuery += " 'WACERUIVL','WACERUIVQ','WACERUIW7','WACERUIWN','WACERUIV9','WACERUIGY','WACERUIHK','WACERUIJ5','WACERUINY','WACERUJ6T','WACERUJ71','WACERUIG3','WACERUIKU','WACERUJ4P','WACERUJ4T','WACERUIZS',"
	cQuery += " 'WACERUJ0W','WACERUJ53','WACERUJNK','WACERUJNO','WACERUJNT','WACERUIGC','WACERUIGG','WACERUINC','WACERUJFT','WACERUJFR','WACERUJFY','WACERUJKA','WACERUJKE','WACERUJKC','WACERUJKI','WACERUJKG',"
	cQuery += " 'WACERUJG9','WACERUJG0','WACERUJG6','WACERUJG4','WACERUJGB','WACERUJG2','WACERUJGD','WACERUJG8','WACERUKD1','WACERUK1Q','WACERUJGF','WACERUJKP','WACERUIM4','WACERUIQH','WACERUJAX','WACERUIK4',"
	cQuery += " 'WACERUJAZ','WACERUKE3','WACERUIXF','WACERUJOK','WACERUJOP','WACERUIS6','WACERUJ8D','WACERUJVB','WACERUIHA','WACERUJ49','WACERUJ55','WACERUIYG','WACERUJ0S','WACERUJQI','WACERUJQN','WACERUJ05',"
	cQuery += " 'WACERUJ6Q','WACERUIZU','WACERUJZE','WACERUJ4B','WACERUION','WACERUIJR','WACERUINE','WACERUJMC','WACERUJMD','WACERUING','WACERUIV7','WACERUKCP','WACERUKCR','WACERUJZG','WACERUIV5','WACERUIVN',"
	cQuery += " 'WACERUIWM','WACERUJKM','WACERUJKL','WACERUJKN','WACERUIFE','WACERUJ0A','WACERUK88','WACERUK8D','WACERUK8F','WACERUK8J','WACERUJ08','WACERUJ0U','WACERUJ10','WACERUJ12','WACERUJ4K','WACERUJ5N',"
	cQuery += " 'WACERUJT2','WACERUJTA','WACERUK7J','WACERUJNN','WACERUJNP','WACERUJNR','WACERUK0D','WACERUJX1','WACERUK91','WACERUIGI','WACERUIGU','WACERUIIW','WACERUJ2Z','WACERUJ6N','WACERUJ6V','WACERUJ6X',"
	cQuery += " 'WACERUJ6Z','WACERUIFG','WACERUIKD','WACERUIWR','WACERUJ2R','WACERUJ4V','WACERUJ0Y','WACERUK9M','WACERUKBC','WACERUKBU','WACERUK9Z','WACERUJP2','WACERUJPG','WACERUJNV','WACERUJB0','WACERUIUG',"
	cQuery += " 'WACERUJGR','WACERUJGN','WACERUJGU','WACERUJGG','WACERUJGL','WACERUJGP','WACERUJGW','WACERUKD3','WACERUKD5','WACERUJKS','WACERUJKV','WACERUJKX','WACERUIEH','WACERUII5','WACERUJ32','WACERUJ31',"
	cQuery += " 'WACERUJ91','WACERUJ6J','WACERUJ69','WACERUIZK','WACERUJ0I','WACERUIYI','WACERUIZ2','WACERUJ57','WACERUIM6','WACERUIW8','WACERUIM7','WACERUIQ1','WACERUIWX','WACERUJXU','WACERUJXG','WACERUJX3',"
	cQuery += " 'WACERUJWM','WACERUJW9','WACERUK93','WACERUJOR','WACERUINU','WACERUJ3L','WACERUIRV','WACERUIRQ','WACERUIR9','WACERUIRJ','WACERUIQX','WACERUIS1','WACERUISM','WACERUIS8','WACERUIFU','WACERUJON',"
	cQuery += " 'WACERUIKE','WACERUISA','WACERUIKG','WACERUJSJ','WACERUJRY','WACERUJS5','WACERUJRS','WACERUJNX','WACERUK1P','WACERUIEJ','WACERUIKI','WACERUISB','WACERUIFV','WACERUJNA','WACERUJQ7',"
	cQuery += " 'WACERUJ3M','WACERUJUP','WACERUK9R','WACERUJRQ','WACERUJQX','WACERUKBM','WACERUKBW','WACERUJOB','WACERUK9O','WACERUIIN','WACERUISC','WACERUJH2','WACERUJGY','WACERUJH0','WACERUJKZ','WACERUJL4',"
	cQuery += " 'WACERUKD9','WACERUKD7','WACERUKDD','WACERUKDB','WACERUKE5','WACERUKE8','WACERUKE7','WACERUJBO','WACERUJV2','WACERUIWA','WACERUK08','WACERUJ2T','WACERUIID','WACERUJ1G','WACERUIP9','WACERUIYA',"
	cQuery += " 'WACERUIEZ','WACERUIF9','WACERUJ5Z','WACERUJ24','WACERUIHW','WACERUILH','WACERUJ38','WACERUIK7','WACERUIH0','WACERUJZI','WACERUJ93','WACERUJZJ','WACERUJL0','WACERUJ0C','WACERUJRG','WACERUIEL',"
	cQuery += " 'WACERUK16','WACERUJ0E','WACERUK6L','WACERUK1H','WACERUKAK','WACERUK7H','WACERUKAG','WACERUJ4D','WACERUK9H','WACERUK8S','WACERUIN3','WACERUIUI','WACERUITO','WACERUIKM','WACERUJRI','WACERUJQY',"
	cQuery += " 'WACERUK8A','WACERUIUM','WACERUJHD','WACERUJH9','WACERUJH7','WACERUJHJ','WACERUJHB','WACERUJHH','WACERUJHF','WACERUJLA','WACERUJL8','WACERUJLC','WACERUJLD','WACERUJL6','WACERUK8T','WACERUKE9',"
	cQuery += " 'WACERUJST','WACERUJSL','WACERUISE','WACERUIUK','WACERUJZL','WACERUINI','WACERUIUO','WACERUJZN','WACERUIM9','WACERUJBF','WACERUJBB','WACERUJBD','WACERUIOP','WACERUIMB','WACERUIPN',"
	cQuery += " 'WACERUITE','WACERUITQ','WACERUK1K','WACERUJVE','WACERUK0N','WACERUIXZ','WACERUIYC','WACERUJT0','WACERUJQ8','WACERUJP4','WACERUJNZ','WACERUJRK','WACERUJPZ','WACERUKA3','WACERUK18',"
	cQuery += " 'WACERUJRT','WACERUJS9','WACERUJS7','WACERUJHX','WACERUJHP','WACERUJHT','WACERUJHL','WACERUJHN','WACERUJHZ','WACERUJHR','WACERUJHV','WACERUJLJ','WACERUJLL','WACERUJLH','WACERUJLF','WACERUJSV',"
	cQuery += " 'WACERUJSQ','WACERUJSN','WACERUJRU','WACERUJS0','WACERUINM','WACERUINK','WACERUKEA','WACERUIFK','WACERUIH4','WACERUIQK','WACERUIPR','WACERUIQQ','WACERUIQ5','WACERUIEA','WACERUIGS',"
	cQuery += " 'WACERUIMG','WACERUIO2','WACERUISQ','WACERUIPF','WACERUIHO','WACERUIKY','WACERUIVO','WACERUIG8','WACERUIFI','WACERUIH2','WACERUIQJ','WACERUIPP','WACERUIQO','WACERUIQ3','WACERUISO','WACERUIGQ',"
	cQuery += " 'WACERUIMD','WACERUIO0','WACERUIHM','WACERUIL5','WACERUIKW','WACERUIVZ','WACERUIGK','WACERUIME','WACERUIWT','WACERUIY0','WACERUII0','WACERUIMI','WACERUIH6','WACERUK9X','WACERUKAM',"
	cQuery += " 'WACERUK6W','WACERUK1I','WACERUJXI','WACERUIHY','WACERUJU7','WACERUJZP','WACERUK8V','WACERUIMK','WACERUIIY','WACERUIQV','WACERUIKO','WACERUIMM','WACERUIPT','WACERUK1X','WACERUJOD','WACERUK83',"
	cQuery += " 'WACERUJZR','WACERUK9F','WACERUJZT','WACERUJZV','WACERUKAS','WACERUII2','WACERUJ61','WACERUJ2V','WACERUJO0','WACERUJ2X','WACERUIG5','WACERUII4','WACERUK7S','WACERUJ82',"
	cQuery += " 'WACERUISS','WACERUJ43','WACERUJLN','WACERUJ4M','WACERUKC3','WACERUIEN','WACERUIRB','WACERUINO','WACERUIVH','WACERUKEB','WACERUIOR','WACERUIWP','WACERUITG','WACERUJQO',"
	cQuery += " 'WACERUIXH','WACERUJ59','WACERUJ06','WACERUJ02','WACERUIZC','WACERUKF4','WACERUJ6R','WACERUK1A','WACERUJ89','WACERUK80','WACERUJUQ','WACERUJU9','WACERUIJB','WACERUIFM','WACERUJ7H','WACERUJUR','WACERUIPV','WACERUIXR','WACERUIRC','WACERUIRX','WACERUJ63','WACERUJ3N','WACERUJS2',"
	cQuery += " 'WACERUK1Z','WACERUJI1','WACERUKEC','WACERUKED','WACERUJB1','WACERUK0B','WACERUJTV','WACERUJZY','WACERUJ95','WACERUJ45','WACERUK6B','WACERUIQS','WACERUIUQ','WACERUIUZ','WACERUIHG',"
	cQuery += " 'WACERUJ2F','WACERUIJT','WACERUIXT','WACERUIZG','WACERUIZE','WACERUJSO','WACERUIRD','WACERUK00','WACERUIWC','WACERUK0C','WACERUJB2','WACERUK1S','WACERUJSB','WACERUIEP','WACERUIIF',"
	cQuery += " 'WACERUJRA','WACERUJRC','WACERUKBO','WACERUJ7J','WACERUIJV','WACERUJ2H','WACERUIQ7','WACERUIOV','WACERUIHI','WACERUKFA','WACERUKF6','WACERUKF8','WACERUKES','WACERUKBQ','WACERUJVJ',"
	cQuery += " 'WACERUIL7','WACERUJ27','WACERUIUS','WACERUILJ','WACERUJR1','WACERUK6C','WACERUJT9','WACERUK9V','WACERUJ97','WACERUJI3','WACERUKEE','WACERUKB5','WACERUJSP','WACERUIMO','WACERUK02',"
	cQuery += " 'WACERUIMP','WACERUIWE','WACERUIFO','WACERUIVR','WACERUJ07','WACERUJ03','WACERUJQP','WACERUJQK','WACERUJ6S','WACERUIYK','WACERUJ5B','WACERUIYM','WACERUK6N','WACERUK6Y','WACERUKAO',"
	cQuery += " 'WACERUK7D','WACERUK0S','WACERUJQA','WACERUKA5','WACERUKBP','WACERUJO2','WACERUIOZ','WACERUIMQ','WACERUJND','WACERUJNF','WACERUJMF','WACERUJMG','WACERUJB3','WACERUK1J',"
	cQuery += " 'WACERUK03','WACERUJNH','WACERUJXW','WACERUJX4','WACERUJ6K','WACERUJ6B','WACERUIZM','WACERUJ0K','WACERUIYO','WACERUIZ4','WACERUJ5D','WACERUIZW','WACERUIWZ','WACERUJWO',"
	cQuery += " 'WACERUJWA','WACERUJVX','WACERUK95','WACERUIX1','WACERUJXY','WACERUJXK','WACERUJX6','WACERUJWQ','WACERUJWB','WACERUJVZ','WACERUK97','WACERUJMR','WACERUJ9H',"
	cQuery += " 'WACERUJY0','WACERUJXM','WACERUJX8','WACERUJWS','WACERUJWC','WACERUJW1','WACERUK99','WACERUJ5F','WACERUIZ6','WACERUIYQ','WACERUJ0M','WACERUIZN','WACERUJ6D','WACERUJ6L','WACERUJ5H',"
	cQuery += " 'WACERUIYS','WACERUKEI','WACERUKEJ','WACERUJ3P','WACERUJSW','WACERUJSD','WACERUK04','WACERUKDG','WACERUKEK','WACERUKEL','WACERUJPI','WACERUIUU','WACERUIYU','WACERUJ5J',"
	cQuery += " 'WACERUJ0G','WACERUIN5','WACERUK05','WACERUJW3','WACERUJY2','WACERUJXO','WACERUJXA','WACERUJWU','WACERUJWE','WACERUK9B','WACERUKA9','WACERUJY3','WACERUJXQ','WACERUJXC','WACERUJWW','WACERUJWG',"
	cQuery += " 'WACERUJW5','WACERUK9D','WACERUIZO','WACERUJ6F','WACERUJ6M','WACERUIYW','WACERUJ5L','WACERUIZY','WACERUIZ8','WACERUJ0O','WACERUK6P','WACERUJVH','WACERUKA7','WACERUJ84','WACERUJQC',"
	cQuery += " 'WACERUJ7L','WACERUK1D','WACERUK06','WACERUJ41','WACERUIL9','WACERUKAZ','WACERUJQ4','WACERUK07','WACERUJQV','WACERUKEF','WACERUJJW','WACERUJJZ','WACERUJK1','WACERUJJY','WACERUKEG','WACERUKEH') "

	If Select(cMovEXC2) <> 0
		dbSelectArea(cMovEXC2)
		(cMovEXC2)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS(cMovEXC2)

	While (cMovEXC2)->(!eof())

		CONOUT(D3_DOC+'-'+D3_COD+'-'+D3_XCHVDBG)
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

		
		If (cMovEXC2)->RECNO == SD3->(RECNO())
			_aSD3 := {}
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
				_lRetOK :=  .F. 
			Else
				_lRetOK := .T.
			Endif
		Endif
		
		(cMovEXC2)->(dbskip())
	Enddo

	If Select(cMovEXC2) <> 0
		dbSelectArea(cMovEXC2)
		(cMovEXC2)->(dbCloseArea())
	Endif

Return	

User Function AGX635CC(xEmp,xFil) //GetCCFil(xEmp,xFil)

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

Return cRetcc
