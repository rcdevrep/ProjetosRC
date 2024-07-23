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

	Local cPerg      := 'AGX635LO'  
	Local aParamsRE  := {} 
	Private cArq     := "AGX635LO"+dtos(date())+STRTRAN(time(),':','' ) 
	             
	//Se não confirmou, Retorna
	If Pergunte(cPerg) 
	  	AADD(aParamsRE,MV_PAR01)//Rotina	
	  	AADD(aParamsRE,MV_PAR02)//Emissao de 
	  	AADD(aParamsRE,MV_PAR03)//Emissao até 
	Else
		MsgInfo('Pergunta nao encontrada!')
	Endif

   // MsgRun( "Relatorio de Divergências - Aguarde..." , "Executando Relatório" , { || U_635ZREL(@aParamsRE)})  
	MsgRun( "Relatorio de Divergências - Aguarde..." , "Executando Relatório" , { || cArq := startjob("U_635ZREL",getenvserver(),.T.,@aParamsRE)} )
    
	If !ApOleClient("MsExcel")                     	
	 	MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
		Return	
	EndIf
		
	//conout('Copia Arquivo ')
	//conout(cArq)
	//conout(alltrim(GetTempPath())+cArq)
	//Copia para temp e Abre no Excel
	__CopyFIle(cArq , AllTrim(GetTempPath())+cArq)             
		
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cArq)//cArqTrbex+".XLS")
	oExcelApp:SetVisible(.T.)                       
				                 
	fErase(cArq) //Deletando arquivo de trabalho	
Return

User Function 635ZREL(aParamsRE)

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local cEmpPara       := ""   
	Local cFilialPara    := "" 
	Private cCapaCTS     := ""    
	Private nEmpDe       := 0
	Private cAliasCapa   := ""    
	Private cAliasPROD   := ""  
	Private aLogs		 := {} //Array de Logs  
	Private lClearEnv    := .F. 
	Private cTempDBG     := ""  
	Private cChave       := ""	

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
		   	
					
		  	//CTE de Saída 
		  	ElseIf  aParamsRE[1] == 2 //CTE de saída 
		   	
			//Nota de saída 
			ElseIf  aParamsRE[1] == 3 //Nota de Saída

					//RPCSetType()
					RPCSetEnv(cEmpPara, cFilialPara)

					cTempDBG := SelectERP('DBG','NFS')
					cTempPRT := SelectERP('PRT','NFS')	

					aImprime := ComparaQry(cTempDBG, cTempPRT)
					
					(cTempDBG)->(DbCloseArea())
	
	
					RPCClearEnv()
					dbCloseAll()
				
			   	//RESET ENVIRONMENT
			Endif
		  	
		Next nCountPara         
              
	Next nCountDe 
	 
	//Grava Logs
	If len(aLogs) > 0     
 		//Grava Relatorio
		cArq := GeraCSV()
 	Else
 		cArq := GeraCSV() //MsgInfo('Nenhuma divergencia no periodo! ')
 	Endif
		
Return(cArq)


Static Function SelectERP( xERP,xtipo )

	Private cArqTemp := GetNextAlias()
	
	IF xERP = 'DBG'
		If xTipo == 'NFS'
			DBGGetNFS()
		Elseif xTipo == 'NFE'
			DBGGetNFE()
		Elseif xTipo == 'CTS'
			DBGGetCTS()
		Elseif xTipo == 'CTE'
			DBGGetCTE()
		Endif 
	Elseif xERP = 'PRT'
		If xTipo == 'NFS'
			PRTGetNFS()
		Elseif xTipo == 'NFE'
			PRTGetNFE()
		Elseif xTipo == 'CTS'
			PRTGetCTS()
		Elseif xTipo == 'CTE'
			PRTGetCTE()
		Endif 
	Endif 

Return cArqTemp


//Busca NFS´S para importação
Static Function DBGGetNFS(nEmpOrigem,nFilOrigem)

    Local cCapaNFS     := cArqTemp
    Local cQuery       := "" 
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1   
	
	cQuery := " SELECT"
	cQuery += " VEN_NOTSAI.GEN_TABEMP_Codigo	AS 	DBEMP  ,"+CHR(13)
	cQuery += " VEN_NOTSAI.GEN_TABFIL_Codigo	AS 	DBFIL  ,"+CHR(13)
	cQuery += " GEN_ESTMUN_Estado    			AS  UFCLI ,"+CHR(13)
	cQuery += " VEN_NOTSAI.GEN_NATOPE_Codigo    AS  NATOP, "+CHR(13)
	cQuery +="  GEN_NATOPE_TES 					AS D2_TES  ,"+CHR(13)//  TES Protheus 
	cQuery += " ENDENT.GEN_ENDENT_IF     AS  	CNPJ_CPF   ,"+CHR(13)
	cQuery += " VEN_NOTSAI.VEN_NOTSAI_Numero	AS 	ID     ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Emissao		 AS 	F2_EMISSAO ,"+CHR(13)
	cQuery += " VEN_NOTSAI_TipoNF		 AS 	F2_TIPO    ,"+CHR(13)
	cQuery += " VEN_NOTSAI_FilialDest	 AS 	TRANSFER   ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Cli_Cod		 AS 	DBCLI      ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ECL_Cod		 AS 	DBLOJA     ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Tra_Cod		 AS 	DBTRANS    ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ETr_Cod		 AS 	DBTRANSLOJ ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BIPI			 AS 	F2_BASEIPI ,"+CHR(13)
	cQuery += " VEN_NOTSAI_IPI			 AS 	F2_VALIPI  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorProd	 AS 	F2_VALMERC ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorNF		 AS     F2_VALBRUT ,"+CHR(13)
	cQuery += " VEN_NOTSAI_INSS			 AS 	F2_VALINSS ,"+CHR(13)
	cQuery += " VEN_NOTSAI_PIS			 AS 	F2_VALIMP6  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Cofins		 AS 	F2_VALIMP5 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_CSLL			 AS 	F2_VALCSLL ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BaseST		 AS 	F2_BRICMS  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorST		 AS 	F2_ICMSRET ,"+CHR(13)
	cQuery += " VEN_NOTSAI_PesoLiq		 AS 	F2_PLIQUI  ,"+CHR(13)//--F2_PESOL
	cQuery += " VEN_NOTSAI_PesoBruto	 AS 	F2_PBRUTO  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Placa		 AS 	F2_PLACA   ,"+CHR(13)
	cQuery += " VEN_NOTSAI_TipoFrete	 AS 	F2_TPFRETE ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorFrete	 AS 	F2_VALROMA ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorSeguro	 AS 	F2_SEGURO  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ISS			 AS 	F2_VALISS  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_IRRF			 AS 	F2_VALIRRF ,"+CHR(13) 
	cQuery += " VEN_NOTSAI_BPIS			 AS 	F2_BASIMP6  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BCSLL		 AS 	F2_BASCSLL ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BCOFINS		 AS 	F2_BASIMP5 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_QtdVolume	 AS 	F2_VOLUME1 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_EspecieVolume AS 	F2_ESPECI1 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ICMS          AS     F2_VALICM  ,"+CHR(13)  
	cQuery += " VEN_NOTSAI_BICMS 		 AS     F2_BASEICM ,"+CHR(13)  
	cQuery += " CAST(VEN_NFSEMI_Numero AS  CHAR)  AS 	F2_DOC	   ,"+CHR(13)
	cQuery += " CAST(VEN_NFSEMI_Serie AS  CHAR)   AS 	F2_SERIE, "	+CHR(13)  
	cQuery += " VEN_NOTSAI_FilialDest    AS     FILDEST , "	+CHR(13) 
	cQuery += " VEN_NFSEMI_RXMotivo      AS MSG_MOT, "+CHR(13)  
	cQuery += " VEN_NFSEMI_Cancelada     AS CANCELA, "+CHR(13)
	cQuery += " VEN_NFSEMI_NChNFe        AS F2_CHVNFE, "+CHR(13) 
	cQuery += " VEN_NOTSAI_ValorFrete    AS F2_FRETE, "+CHR(13)
	cQuery += " VEN_NOTSAI_ValorDespAc   AS F2_DESPESA, "+CHR(13)
	cQuery += " VEN_NFSEMI_DataCanc      AS DT_CANC,  "+CHR(13)
	
	cQuery += " VEN_NOTSAI_DHIntTotvs 	 AS IMPORT 	"+CHR(13)
	cQuery += " FROM VEN_NOTSAI VEN_NOTSAI" +chr(13)  
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON VEN_NOTSAI.GEN_NATOPE_Codigo = GEN_NATOPE.GEN_NATOPE_Codigo "+chr(13)  
	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = VEN_NOTSAI_Cli_Cod "+CHR(13) 
   	cQuery += " AND GEN_ENDENT_Codigo = VEN_NOTSAI_ECL_Cod   "+CHR(13) 
	cQuery += " INNER JOIN VEN_NFSEMI VEN_NFSEMI ON VEN_NFSEMI.VEN_NOTSAI_Numero = VEN_NOTSAI.VEN_NOTSAI_Numero " +CHR(13)
	cQuery += " AND VEN_NOTSAI.GEN_TABEMP_Codigo = VEN_NFSEMI.GEN_TABEMP_Codigo  "+CHR(13)
	cQuery += " AND VEN_NOTSAI.GEN_TABFIL_Codigo = VEN_NFSEMI.GEN_TABFIL_Codigo  "+CHR(13)
	cQuery += " WHERE "
	//"(VEN_NOTSAI_DHIntTotvs IS NULL OR VEN_NOTSAI_DHIntTotvs = '1000-01-01 00:00:00' )AND " +CHR(13)
	cQuery += " VEN_NOTSAI.GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)  
	cQuery += " AND (VEN_NFSEMI_NCStat IN ('100','101','102') OR ( VEN_NOTSAI_TipoNF = 'S' OR VEN_NOTSAI_TipoNF = 'B' ))"	 +CHR(13) 
	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0  
		cQuery += " AND  VEN_NOTSAI.GEN_TABFIL_Codigo = " + cValToChar(nFilOrigem)
    Endif
	cQuery += " AND  VEN_NOTSAI_Emissao  BETWEEN '"+aParamsRE[2]+"' AND '"+aParamsRE[3]+ "' "

	
	cQuery += " ORDER BY ENDENT.GEN_ENDENT_IF , VEN_NFSEMI_NChNFe ,CAST(VEN_NFSEMI_Numero AS  CHAR),CAST(VEN_NFSEMI_Serie AS  CHAR)   "
	                                                                     
	//Plano de Testes 
	//cQuery += " AND VEN_NOTSAI_TipoNF = 'E' AND VEN_NOTSAI.VEN_NOTSAI_NUMERO = 21 " //VOLTAR O IS NULL
	//cQuery += " AND VEN_NFSEMI_Numero = '16' AND VEN_NFSEMI_Serie = '5' " 
	//cQuery += " AND VEN_NOTSAI.GEN_TABFIL_Codigo = '5' "

	//CONOUT('AGX635NS')
	CONOUT(cQuery)    
   	U_AGX635CN("DBG")    
	
  	If Select(cCapaNFS) <> 0
  		dbSelectArea(cCapaNFS)
   		(cCapaNFS)->(dbCloseArea())
  	Endif

 	TCQuery cQuery NEW ALIAS (cCapaNFS) 
 	
 	TCSETFIELD(cCapaNFS,"DBCLI"   ,"N",14,0) 
 	TCSETFIELD(cCapaNFS,"DBTRANS" ,"N",14,0) 
 	TCSETFIELD(cCapaNFS,"F2_VALMERC"   ,"N",14,2)  
 	TCSETFIELD(cCapaNFS,"F2_VALBRUT"   ,"N",14,2) 	
 	//TCSETFIELD(cCapaCTS,"F2_ALQIMP6"   ,"N",6,2) 
	TCSETFIELD(cCapaNFS,"F2_BASIMP6"   ,"N",14,2) 
	TCSETFIELD(cCapaNFS,"F2_VALIMP6"   ,"N",14,2) 
	//TCSETFIELD(cCapaCTS,"F2_ALQIMP5"   ,"N",6,2) 
	TCSETFIELD(cCapaNFS,"F2_BASIMP5"   ,"N",14,2) 
	TCSETFIELD(cCapaNFS,"F2_VALIMP5"   ,"N",14,2) 

	U_AGX635CN("PRT")    
     
Return  


//Busca Movimentos no Protheus
Static Function PRTGetNFS(nEmpOrigem,nFilOrigem)

	Local cCapaNFS     := cArqTemp

  	Default nFilOrigem := 0
	Default nEmpOrigem := 1  

	cQuery := "  SELECT F2_CHVNFE,* "
	cQuery += " FROM SF2010(NOLOCK) "
	cQuery += " WHERE F2_ORIIMP LIKE 'AGX635%' "
	cQuery += " AND F2_EMISSAO BETWEEN '"+aParamsRE[2]+"' AND  '"+aParamsRE[3]+ "' "
	cQuery += " AND D_E_L_E_T_= '' "


	U_AGX635CN("PRT")  
	If Select(cCapaNFS) <> 0
		dbSelectArea(cCapaNFS)
		(cCapaNFS)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cCapaNFS)


Return() 


//Compara Protheus x DBgint
Static Function ComparaQry(cQueryDBG , cQueryPRT)

	Local aDados := {}

	DbSelectarea(cQueryDBG)
	(cQueryDBG)->(dbgotop())

	//Enquanto nao terminar de varrer as duas tabelas não Finaliza
	While (cQueryDBG)->(!eof()) .OR. (cQueryPRT)->(!eof())

		// Se for Lages Grava no almoxarifado LG
		If (cQueryDBG)->DBFIL == 14
			_cArmDes   := 'LG'	
		Else
			_cArmDes   := 'DB'			
		Endif                                                                                                                         
		
		_cDoc := iif( alltrim((cQueryDBG)->DOCDB)<>'',STRTRAN((cQueryDBG)->DOCDB,'-',''),'DB'+dtos(date())+STRTRAN(time(),':','' )) 
		_cProduto    := (cQueryDBG)->DBPROD
		_nQuant      := (cQueryDBG)->QTDDB
		_nValor      := (cQueryDBG)->VALORDB
		_dDateMov    := (cQueryDBG)->DATADB  
		_nValCM	     := (cQueryDBG)->CUSTOMDB 
		
		//Conout('AGX635MR - ComparaQry '+ _cDoc +' - ' + _cProduto)
		//Conout( alltrim((cQueryPRT)->CHAVEPRT) +' - '+ alltrim((cQueryDBG)->CHAVEDB) )

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
			_nCusto1     := ROUND( IIF(_nQuant < 0 ,iif( (cQueryDBG)->TPMOVDB <> 'ST', ABS(_nQuant)*_nValCM , ABS(_nQuant)*_nValor) ,  ABS(_nQuant)*_nValor) , 4 )
		Else
			_nCusto1     :=  ROUND( _nValor , 4 )
		Endif
		//Fim regra Custo
		
		//regra CC
		_cCC         := alltrim(str(val(  (cQueryDBG)->DBCC  ) ) ) //"7001" //Gravar aqui o CC  alltrim(str(val( (cAliasPROD)->(D1_CC) ) ) ) 
		If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
			_cCC := alltrim(str(val(  (cQueryDBG)->DBCC2 ) ) )
		Endif  
		If Empty(_cCC) .or.  alltrim(_cCC) == '0'   
			_cCC := ""
		Endif  
		//Fim regra CC
		

		//Se Estiver posicionado no mesmo registro, grava
		If alltrim((cQueryPRT)->CHAVEPRT)+(cQueryPRT)->D3_LOCAL == alltrim((cQueryDBG)->CHAVEDB)+_cArmDes 
			//FILIAL 	 DOC. PRT 	 TM 	 QUANT	 CUSTO 	 CC 	 PRODUTO	 - 	 TM DBG 	 DOC DBG	 PROD.DBG 	 CUSTO IMPORT. 	 CUSTO MED.	 CUSTO. UNIT.  	 CC 	 DATA 	 QUANT

			AADD( aDados,{;
				  (cQueryPRT)->D3_FILIAL ,; //[1]
			 	  (cQueryPRT)->D3_DOC	,;//[2]
			  	  (cQueryPRT)->D3_TM ,;//[3]
			   	  STRTRAN( cvaltochar((cQueryPRT)->D3_QUANT),'.',','),;//[4]
			      STRTRAN( cvaltochar((cQueryPRT)->D3_CUSTO1),'.',','),;//[5]
				  (cQueryPRT)->D3_CC,;//[6]
				  (cQueryPRT)->D3_COD  ,;//[7]
				  " - " ,;//[8]
				  alltrim((cQueryDBG)->CODMOVDB),;//[9]
				  alltrim((cQueryDBG)->DOCDB),;//[10]
				  _cProduto,;//[11]
				  STRTRAN( cvaltochar(_nCusto1),'.',',' ),;//[12]
				  STRTRAN( cvaltochar( nTotCM)  ,'.',',' ),;//[13]
				  STRTRAN( cvaltochar( nTotUnit) ,'.',',' ),;//[14]
				  _cCC,;//[15]
				  dtoc(_dDateMov),;//[16]
				  STRTRAN(cvaltochar( _nQuant),'.',',');//[17]
			})

			 	(cQueryPRT)->(DbSkip())
			 	(cQueryDBG)->(DbSkip())
				LOOP

		// Se a chave do Protheus for MENOR Que a do DBGint
		// significa que existe no PROTHEUS e não Existe no DBGINT
		ElseIf (alltrim((cQueryPRT)->CHAVEPRT)+(cQueryPRT)->D3_LOCAL < alltrim((cQueryDBG)->CHAVEDB)+_cArmDes  .or. (cQueryDBG)->(eof()) .or. alltrim((cQueryDBG)->CHAVEDB) == '') ;
				.AND. alltrim((cQueryPRT)->CHAVEPRT) <> '' 
			AADD( aDados,{;
				  (cQueryPRT)->D3_FILIAL ,;//[1]
			 	  (cQueryPRT)->D3_DOC	,;//[2]
			  	  (cQueryPRT)->D3_TM ,;//[3]
			   	  STRTRAN( cvaltochar((cQueryPRT)->D3_QUANT),'.',','),;//[4]
			      STRTRAN( cvaltochar((cQueryPRT)->D3_CUSTO1),'.',','),;//[5]
				  (cQueryPRT)->D3_CC,;//[6]
				  (cQueryPRT)->D3_COD ,;//[7]
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
					CONOUT(alltrim((cQueryPRT)->CHAVEPRT))
					Conout(alltrim((cQueryDBG)->CHAVEDB))
					conout('****************')

				   (cQueryPRT)->(DbSkip())
				   LOOP
				
	
		// Se o Protheus for MAIOR que o DBgint
		// significa que existe no DBGINT e não Existe no PROTHEUS
		Elseif  (alltrim((cQueryPRT)->CHAVEPRT)+(cQueryPRT)->D3_LOCAL  > alltrim((cQueryDBG)->CHAVEDB)+_cArmDes  .or. (cQueryPRT)->(eof())  .or. alltrim((cQueryPRT)->CHAVEPRT) == '')
			AADD( aDados,{;
				    "" ,; //[1]
			 	    "",;//[2]
			  	    "",;//[3]
			   	    "",;//[4]
			        "",;//[5]
				    "",;//[6]
				    "NÃO EXISTE NO PROTHEUS" ,;//[7]
				    " - ",;//[8]
					alltrim((cQueryDBG)->CODMOVDB),;//[9]
					alltrim((cQueryDBG)->DOCDB),;//[10]
					_cProduto,;//[11]
					STRTRAN( cvaltochar(_nCusto1),'.',',' ),;//[12]
					STRTRAN( cvaltochar( nTotCM)  ,'.',',' ),;//[13]
					STRTRAN( cvaltochar( nTotUnit) ,'.',',' ),;//[14]
					_cCC,;//[15]
					dtoc(_dDateMov),;//[16]
					STRTRAN(cvaltochar( _nQuant),'.',',');//[17]
					})
					conout('NÃO EXISTE PROTHEUS')
					CONOUT(alltrim((cQueryPRT)->CHAVEPRT))
					Conout(alltrim((cQueryDBG)->CHAVEDB))
					conout('****************')

					(cQueryDBG)->(DbSkip())
					LOOP
			Endif 

		//(cQueryPRT)->(DbSkip())
	Enddo

Return aDados
