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
	//Private lReproc      := xReproc  
	Private aItens116    := {}       
	Private aLogs		 := {} //Array de Logs 
	Private cAnoMesRel   := Substr(xAnoMes,1,4) +'-'+ Substr(xAnoMes,6,2)  
	Private cErro        := ""   
	Private cMovDbg   := "MOVDBG"    
	Private cMovPrt   := "MOVPRT"                                      
	Private cMovDbg2  := "MOVDBG2"
	
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
			  	     			  		    
				cMovimenta := SelectMOV(nEmpDe,nFilde)
			  	InserirMOV(cMovimenta)
    
			 	RPCClearEnv()
				dbCloseAll()
				RESET ENVIRONMENT
		Next nCountPara
           
		FErase(cArqTmp + GetDbExtension())
		FErase(cArqTmp + OrdBagExt())
	Next nCountDe 
	
	MostraLog(cErro,'RELATORIO MOVIMENTACOES ESTOQUE',.F.)     
	
	//End Sequence
	//ErrorBlock(bError)	
		
Return(aEmpDePara)  

//Mostra Log em Tela
Static function MostraLog(xErro,xMsg,lErroSys)    
   
	Local clog := "" 
	               
	If lErroSys
		MemoWrite( "Rel_MOVIMENTACOES_DBGINT.csv", xMsg+'('+ xErro +')' ) 
	Else
		MemoWrite( "Rel_MOVIMENTACOES_DBGINT.csv", xErro )   
	Endif  
	
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

    Local cMovTran  := "AGX635MR2"//GetNextAlias()
    Local cQuery    := "" 
	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1    


	// ET - Entrada de Transferência
	// ST - Saída de Transferencia
	// M  - Demais Movimentações  
	cQuery := " SELECT 'ET' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2,"+/*EST_MOVEST_Emp_Cod AS EMPDB,"*/"EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO   " 
	cQuery += " FROM EST_MOVEST "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/" SUBSTRING(EST_MOVEST_DATA,1,7) =  '"+cAnoMesRel+"' AND EST_MOVEST_Mov_Cod = '10' "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2')   "  
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LG'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif
	//cQuery += " AND EST_MOVEST_DHIntTotvs IS NOT NULL "   
		//*****TESTES RETIRAAAAARRRR
	//cQuery += "  AND EST_MOVEST_Fil_Cod = '14' "
	
	cQuery += " UNION ALL "
			                          
	cQuery += " SELECT 'ST' AS TPMOVDB,EST_MOVEST_CCIntegracao as DBCC,EST_MOVEST_CentroCusto AS DBCC2,"+/*EST_MOVEST_Emp_Cod AS EMPDB,"*/"EST_MOVEST_Fil_Cod AS DBFIL,EST_MOVEST_Data AS DATADB,CAST(EST_MOVEST_Mov_Cod AS  CHAR) AS CODMOVDB, "
	cQuery += " EST_MOVEST_Documento AS DOCDB,EST_MOVEST_Serie AS SERIEDB, CAST(GEN_TABENT_Codigo AS  CHAR) AS CGCDB, GEN_ENDENT_Codigo AS ENDDB,EST_MOVEST_Pro_Cod AS DBPROD, "
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO " 
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
	cQuery += " EST_MOVEST_Quantidade AS QTDDB,EST_MOVEST_Valor AS VALORDB, EST_MOVEST_Saldo AS SALDODB, EST_MOVEST_CustoMed AS CUSTOMDB, CAST(EST_MOVEST_Created AS CHAR) AS DBCRIADO   " 
	cQuery += " FROM EST_MOVEST  "
	cQuery += " WHERE "+/*EST_MOVEST_Pro_Cod = 'DBP00129'*/" SUBSTRING(EST_MOVEST_DATA,1,7) = '"+cAnoMesRel+"' AND EST_MOVEST_Mov_Cod NOT IN('509','10','1','508','9','507','511','510') "
	cQuery += " AND EST_MOVEST_Emp_Cod = '"+cValToChar(nEmpOrigem)+"' AND EST_MOVEST_Ori_Cod NOT IN ('1','2')  "  
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LG'
	If nFilOrigem == 4
		cQuery += " AND ( EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"' OR EST_MOVEST_Fil_Cod = '14'  )"  	                 
	Else
		cQuery += " AND  EST_MOVEST_Fil_Cod = '"+cValToChar(nFilOrigem)+"'  "                              	
	Endif	

	//*****TESTES RETIRAAAAARRRR
	//cQuery += "  AND EST_MOVEST_Fil_Cod = '14' "  
	//cQuery += " limit 2300 "
	conout('AGX635MR - QUERY DBGINT')
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
	                        
	Local   aMovOk    := {} 	  
	
	cErro += "FILIAL ; DOC. PRT ; TM ; QUANT; CUSTO ; CC ; PRODUTO; - ; TM DBG ; DOC DBG; PROD.DBG ; CUSTO IMPORT. ; CUSTO MED.; CUSTO. UNIT.  ; CC ; DATA ; QUANT"+ chr(13) + chr(10)
	
   	(cMovimenta)->(dbgotop()) 
   	
   	//bError := ErrorBlock({|oError| MostraLog('ROTINA COM ERRO,VERIFIQUE COM A TI',oError:Description,.T.) })   
   	     
   	_iii := 0                                
   	U_AGX635CN("PRT")  
    //BEGIN SEQUENCE                       
	While (cMovimenta)->(!eof())   
       
         _iii++     
                                                  
		 // CHAVE DBGINT
		 // Codigo Movimento | Documento | Serie | Cgc | Produto
		 cChaveDB := alltrim( (cMovimenta)->DBCRIADO)+alltrim( (cMovimenta)->CODMOVDB )+alltrim( (cMovimenta)->DOCDB )+alltrim( (cMovimenta)->DBPROD )
		 conout(cvaltochar(_iii)+' -> '  + cChaveDB)
 	     Requisitar((cMovimenta)->TPMOVDB,cChaveDB )                        	
	
		(cMovimenta)->(dbskip())
	Enddo    
	
	If Select(cMovimenta) <> 0
		dbSelectArea(cMovimenta)
		(cMovimenta)->(dbCloseArea())
	Endif 
	        

	//Busca dados do Protheus no DBGint
	cQuery := " SELECT D3_FILIAL,D3_DOC,D3_TM,D3_QUANT,D3_CUSTO1,D3_CC, D3_COD , D3_XCHVDBG  FROM "+RetSqlname('SD3')+" (NOLOCK) "      
	cQuery += " WHERE D3_XCHVDBG <> '' AND D_E_L_E_T_ = '' "
	cQuery += " AND   SUBSTRING(D3_EMISSAO,1,6) = '"+SUBSTR(cAnoMesRel,1,4)+SUBSTR(cAnoMesRel,6,2)+"' "  
	cQuery += " AND   D3_FILIAL = '"+xfilial('SD3')+"' AND D3_ESTORNO <> 'S' "
	 
	conout(cQuery)
	If Select(cMovPrt) <> 0
		dbSelectArea(cMovPrt)
		(cMovPrt)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cMovPrt)  
             
    U_AGX635CN("DBG")    
        
	_ii := 0 
	(cMovPrt)->(DbGoTop()) 
	While (cMovPrt)->(!Eof())
	
		_ii++   
		conout(_ii)

		BuscaDBG((cMovPrt)->D3_XCHVDBG) 

		(cMovPrt)->(DbSkip())
	Enddo 
	
	U_AGX635CN("PRT")
 
Return 
            
        
//Busca Registros no DBgint
Static Function BuscaDBG(xChaveDB)
	
	Local cQuery := ""

	cQuery := " SELECT EST_MOVEST_Mov_Cod "
	cQuery += " FROM EST_MOVEST  "
	cQuery += " WHERE concat(EST_MOVEST_Created,EST_MOVEST_Mov_Cod ,EST_MOVEST_Documento,EST_MOVEST_Pro_Cod ) ='"+xChaveDB+"' " 
    cQuery += " AND EST_MOVEST_Ori_Cod NOT IN ('1','2') "
     
    conout('BuscaDBG - '+xChaveDB)    
	If Select(cMovDbg2) <> 0
		dbSelectArea(cMovDbg2)
		(cMovDbg2)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS(cMovDbg2)    
	
	(cMovDbg2)->(Dbgotop())   
 
	If (cMovDbg2)->(Eof()) 
		
		cErro += (cMovPrt)->D3_FILIAL+';'+;  				//[1] fILIAL 
		 		 (cMovPrt)->D3_DOC +';'+;    				//[2] Doc Prt
		 		 (cMovPrt)->D3_TM +';'+;     				//[3] TM Prt
		   		  STRTRAN( cvaltochar((cMovPrt)->D3_QUANT),'.',',') +';'+; //[4] Quant Prt
		     	  STRTRAN( cvaltochar((cMovPrt)->D3_CUSTO1),'.',',') +';'+;//[5]custo Prt
		      	  (cMovPrt)->D3_CC  +';'+;  				//[6] CC PRT
		      	  (cMovPrt)->D3_COD  +';'+;  				//[7] Produto PR
		      	  ' - '  +';'+'NÃO EXISTE NO DBGINT '+ chr(13) + chr(10)
	Endif

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
	LOCAL nTotCM     := 0 
	Local nTotUnit   := 0 
	Local _ncusto1    := 0 
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	
	Default xOpcao := 'M'  

	// Se for Lages Grava no almoxarifado LG
	If(cMovimenta)->DBFIL == 14
		_cArmDes   := 'LG'	
	Else
   		_cArmDes   := 'DB'			
	Endif                                                                                                                         
	
	_cDoc := iif( alltrim((cMovimenta)->DOCDB)<>'',STRTRAN((cMovimenta)->DOCDB,'-',''),'DB'+dtos(date())+STRTRAN(time(),':','' )) 
	_cProduto    := (cMovimenta)->DBPROD
	_nQuant      := (cMovimenta)->QTDDB
	_nValor      := (cMovimenta)->VALORDB
	_dDateMov    := (cMovimenta)->DATADB  
	_nValCM	     := (cMovimenta)->CUSTOMDB 
	
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
		_nCusto1     := ROUND( IIF(_nQuant < 0 ,iif( (cMovimenta)->TPMOVDB <> 'ST', ABS(_nQuant)*_nValCM , ABS(_nQuant)*_nValor) ,  ABS(_nQuant)*_nValor) , 4 )
	Else
		_nCusto1     :=  ROUND( _nValor , 4 )
	Endif
    //Fim regra Custo
     
   //regra CC
	_cCC         := alltrim(str(val(  (cMovimenta)->DBCC  ) ) ) //"7001" //Gravar aqui o CC  alltrim(str(val( (cAliasPROD)->(D1_CC) ) ) ) 
 	If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
		_cCC := alltrim(str(val(  (cMovimenta)->DBCC2 ) ) )
	Endif  
	If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
		_cCC := ""
	Endif  
	//Fim regra CC
	              
	
	//VERIFICA SE Já existe o Movimento
	cQuery := " SELECT R_E_C_N_O_ as RECNO,* FROM "+RetSqlName('SD3')+'(NOLOCK) SD3'
	cQuery += " WHERE  D3_FILIAL = '"+xfilial('SD3')+"' AND D3_XCHVDBG = '"+xChvDB+"' AND D_E_L_E_T_ = '' AND D3_TM <> '999' AND D3_ESTORNO <> 'S' "      
	//conout(cQuery)
	If Select('XREQUI') <> 0
		dbSelectArea('XREQUI')
		('XREQUI')->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ('XREQUI')
	
	('XREQUI')->(DbGotop())   
	
	If ('XREQUI')->(!eof()) 
		cErro += ('XREQUI')->D3_FILIAL+';'+;  				//[1] fILIAL 
		 		 ('XREQUI')->D3_DOC +';'+;    				//[2] Doc Prt
		 		 ('XREQUI')->D3_TM +';'+;     				//[3] TM Prt
		   		  StrTran( cvaltochar(('XREQUI')->D3_QUANT),'.',',') +';'+; //[4] Quant Prt
		     	  StrTran( cvaltochar(('XREQUI')->D3_CUSTO1),'.',',') +';'+;//[5]custo Prt
		      	  ('XREQUI')->D3_CC  +';'+;  				//[6] CC PRT
		      	  ('XREQUI')->D3_COD  +';'+;  				//[7] Produto PR
		      	  ' - '  +';'	  							//[8] Separador
	Else
		cErro += ''+';'+; 	 //[1]
		 		 ''+';'+;	 //[2]
		 		 ''+';'+; 	 //[3]
		   		 ''+';'+;	 //[4]
		     	 ''+';'+;	 //[5]
		      	 ''+';'+; 	 //[6] 
		      	 ''+';'+;    //[7]
		      	 ' - '+';' //[8] Separador
	Endif 
	
	cErro += alltrim((cMovimenta)->CODMOVDB) +';' //[9] tipo Movimento DB 
	cErro += alltrim((cMovimenta)->DOCDB)+';' 		   //[10] Documento DBGint
	cErro += _cProduto+';' 							   //[11] Produto DBgint 
	cErro += STRTRAN( cvaltochar(_nCusto1),'.',',' ) +';'				   //[12]    CUSTO DbGint
	cErro += STRTRAN( cvaltochar( nTotCM)  ,'.',',' )+';'				   //[13] CUSTO MÉDIO 
	cErro += STRTRAN( cvaltochar( nTotUnit) ,'.',',' )+';'			   //[14] CUSTO Unitário 
	cErro += _cCC+';'      							   //[15]    CC DbGint  
	cErro += dtoc(_dDateMov)+';'      				   //[16]    DATA DbGint 
	cErro += STRTRAN(cvaltochar( _nQuant),'.',',')+';'      			   //[17]    Quant DbGint
	cErro += chr(13) + chr(10)
		
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

Return          
  */   