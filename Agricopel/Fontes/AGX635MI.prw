#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// Implantação de Saldo Inicial em Estoque
// Deverá Ser rodado Por empresa.  
User Function AGX635MI(aEmpDePara,xAnoMes,xAjusta) 

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	Local nQtdeSLD       := 0
	//Local oTmpTable		 := Nil
	Local cEmpPara       := ""
	Local cFilialPara    := "" 
	Default xAnoMes      := ""
	//Private lReproc      := xReproc  
	Private nEmpDe       := 0
	Private cSaldos   	 := ""    
	Private aIntCAPA	 := {} //Array com Notas que foram integradas
	Private aIntITENS	 := {} //Array com Notas que foram integradas   
	Private lClearEnv    := .F.   
	Private aItens116    := {}       
	Private aLogs		 := {} //Array de Logs  
	Private cAnoMes      := xAnoMes//"" 
	Private lAjusta		 := xAjusta       
	
	bError := ErrorBlock({|oError| MostraLog(oError:Description) }) 
    Begin Sequence 

	For nCountDe := 1 To Len(aEmpDePara)
		conout('Iniciando AGX635MI - '+time())
		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := 1 To Len(aEmpPara)

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3] 
				nFilde       := aEmpPara[nCountPara][1] 
				  
				//Roda somente para a empresa corrente  
				//Conout('***AGX635MI - ('+cEmpPara +' - '+ cEmpLogada+')')
				//If cFilialPara <> '05'
				//	Loop	
				//Endif   
				/*
				If !(cFilialPara $'03/04/05/08') 
					loop 
				Endif   
				 */
				lClearEnv := .T.

				PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "NNR","SB9","SB2","SD3","SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","XXS"
			   	
			   	conout(cEmpPara+'/'+cFilialPara)    
			   	
				RPCSetType(3)
			  	RPCSetEnv(cEmpPara, cFilialPara)         	                  
			  	
			  	    //Realiza a Integração dos Movimentos
			  		//Cria Arquivo de Trabalho com dados do DBGint
					/*oTmpTable := CriaArqSLD(nEmpDe,nFilde,cAnoMes)       

					cSaldos := oTmpTable:GetAlias()*/

					cSaldos := CriaArqSLD(nEmpDe,nFilde,cAnoMes) 

					nQtdeSLD := (cSaldos)->(RecCount())

					If nQtdeSLD > 0
					   	InserirSLD(cAnoMes) 
					Else
						AADD(aLogs,"("+cEmpAnt+'/'+cFilAnt+") - VERIFIQUE A DATA DE FECHAMENTO DO DBGINT, Não foram encontrados produtos na tabela de Saldos!" )
					Endif

					(cSaldos)->(DbCloseArea())
					//oTmpTable:Delete()
					//FreeObj(oTmpTable)

			 	RPCClearEnv()
				dbCloseAll()
				RESET ENVIRONMENT
		Next nCountPara
	Next nCountDe 

	//If len(aLogs) > 0     
	MostraLog(/*aLogs,*/'SALDOS INICIAIS')   
 	//Endif
	                                       
	End Sequence
	ErrorBlock(bError)	

Return(aEmpDePara) 	      

//Cria Arquivo de dados
Static Function CriaArqSLD(nEmpOrigem,nFilOrigem,xAnoMes)

	Local aStruTmp     := {}
	//Local oTmpTable    := Nil
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	cAliasQry := SelectSLD(nEmpOrigem,nFilOrigem,xAnoMes)

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
Static Function SelectSLD(nEmpOrigem,nFilOrigem,xAnoMes)

    Local cSLDTran  := GetNextAlias()
    Local cQuery    := "" 
	
   	Default nFilOrigem := 0
	Default nEmpOrigem := 1  
	
	cQuery += " SELECT  EST_SLDEST_Emp_Cod AS  DBEMP,"//smallint(6) - Código da Empresa
	cQuery += " CAST(EST_SLDEST_Fil_Cod AS CHAR)  AS  DBFIL,"//smallint(6) - Código da Filial
	cQuery += " EST_SLDEST_Pro_Cod   AS  DBPROD,"//varchar(13) - Código do Produto
    //cQuery += " EST_SLDEST_Dep_Cod  "//smallint(6) - Código do Depósito
	cQuery += " EST_SLDEST_AnoMes  AS ANOMES, "//varchar(7) - Ano/Mês do fechamento (9999/99)
	cQuery += " EST_SLDEST_Quantidade  AS DBQUANT, "//decimal(14,3)- Saldo do Estoque
	cQuery += " EST_SLDEST_CustoMedio  AS DBCUSMED, "//decimal(14,4) - Custo Médio no final do mês  
	cQuery += " GEN_TABPAR_DTFECEST    AS DTFECHTO "//Data do fechamento 
	//cQuery += " EST_SLDEST_Created  "//datetime - Data de criação do registro
	//cQuery += " EST_SLDEST_Updated  "//datetime - Data da última alteração do registro          
	cQuery += " FROM EST_SLDEST " 
	cQuery += " INNER JOIN GEN_TABPAR ON ( GEN_TABPAR_Empresa_Codigo = EST_SLDEST_Emp_Cod AND EST_SLDEST_Fil_Cod = GEN_TABPAR_Filial_Codigo)"
	cQuery += " WHERE EST_SLDEST_AnoMes = '"+xAnoMes+/*2018/02*/"' "
	cQuery += " AND EST_SLDEST_Emp_Cod = '"+alltrim(str(nEmpOrigem))+"' "                          
	
	//Quando For da base  traz dados junto com a Base, posteriormente é gravado como Armazem 'LJ'
   	If nFilOrigem == 4
	   	cQuery += " AND (EST_SLDEST_Fil_Cod = '"+alltrim(str(nFilOrigem))+"' OR EST_SLDEST_Fil_Cod = '14'  )"  	
	   //	cQuery += " AND ( EST_SLDEST_Fil_Cod = '14'  )"                   
  	Else
		cQuery += " AND EST_SLDEST_Fil_Cod = '"+alltrim(str(nFilOrigem))+"' "                              	
	Endif
	cQuery += " AND (EST_SLDEST_Quantidade <> 0 )"//AND EST_SLDEST_CustoMedio >0 )" 
	  
	//conout(cQuery)
	U_AGX635CN("DBG")    

	If Select(cSLDTran) <> 0
		dbSelectArea(cSLDTran)
		(cSLDTran)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cSLDTran)

Return(cSLDTran)       

                   
       
//Inserir Movimento
Static function InserirSLD(xAnoMes) 

	Local _cArmDes   := 'DB'
	Local _cData     := StrTran(xAnoMes,'/','')
	Local _cDTFEcha  := ""  
	Local lFechado   := .F.
	
	_cDTFEcha := dtos((cSaldos)->DTFECHTO)//substr( dtos((cSaldos)->DTFECHTO),1,6 ) 

   	(cSaldos)->(dbgotop())
   	                               
   	U_AGX635CN("PRT")  
   	/*conout(' - - - - Valida Fechamento  - - - -')   
   	conout(dtos((cSaldos)->DTFECHTO))  
   	conout(substr( dtos((cSaldos)->DTFECHTO),1,6 ) )   
   	conout(	_cData  ) */  

	//conout(_cDTFEcha)
	//conout( _cData) 	
   	If  SUBSTR( _cDTFEcha,1,6) < _cData
   		AADD(aLogs,"("+cEmpAnt+'/'+cFilAnt+") - DBGint esta com ultimo período de fechamento em "+dtoc( (cSaldos)->DTFECHTO)+", Verifique!" )	
   		Return 
   	Endif
   	
   	//cria Armazem caso não Exista
	DbSelectarea('NNR')
	DbsetOrder(1)
	If !DbSeek(xFilial('NNR')+_cArmDes)
		Reclock('NNR',.T.)   
			NNR->NNR_FILIAL := xFilial('NNR')
			NNR->NNR_CODIGO := _cArmDes
			NNR->NNR_DESCRI := 'DBGINT'+IIF(_cArmDes == 'LG', ' LAGES','') 
			NNR->NNR_INTP   := '3'
			NNR->NNR_TIPO   := '1'
			NNR->NNR_MRP    := '1'
			NNR->NNR_ANP45  := .F.   
			NNR->NNR_ARMALT := '2'
			NNR->NNR_VDADMS := '0'
			NNR->NNR_AMZUNI := '2'			
		NNR->(MsUnlock())
	Endif  
                

	DbSelectarea('SB9')
	DbSetOrder(3)
	If DbSeek(xFilial('SB9') + _cDTFEcha)  
		lFechado := .T.
	Endif
	
	//Varre Tabela e Cria Saldo na SB9
	(cSaldos)->(DbGotop())        
	While (cSaldos)->(!eof())  
	
	
	   		// Se for Lajes Grava no almoxarifado LG
		   	If Alltrim( (cSaldos)->DBFIL ) == '14'
				_cArmDes   := 'LG'	
			Else 
				_cArmDes   := 'DB'		
			Endif 
			  
			//Se tiver negativo,Grava LOG 
			If (cSaldos)->DBQUANT < 0
				conout('***NEGATIVO')   
			 	AADD(aLogs,;
   						"("+cEmpAnt+'/'+cFilAnt+") ;"+alltrim( (cSaldos)->DBPROD )+" ";
   					     	+";NEGATIVO;" +_cArmDes +'')
   	   			//Conout(len(aLogs)) 
			Else
				//Se tiver fechado Verifica SB9, Senão SB2
				If lFechado
					VerifSB9(_cArmDes,_cDTFEcha)
				Else   
					VerifSB2(_cArmDes )
				Endif	
			Endif
	
		(cSaldos)->(DbSkip()) 
	
	Enddo
	                	
Return


//Verificar SB2
Static function VerifSB2(xLocal)

	Local cQuery := "" 
	Local lAchou := .F.

	cQuery := ""
	cQuery += " SELECT * FROM " +RetSqlName('SB2') + " SB2 (NOLOCK)"
	cQuery += " WHERE "                
	cQuery += " B2_LOCAL = '"+xLocal+ "' "
	cQuery += " AND B2_COD = '"+alltrim((cSaldos)->DBPROD)+"' "  
	//cQuery += " AND ( SUBSTRING(B9_DATA,1,6) = '"+_cData+"'  )"    
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " AND B2_FILIAL = '"+xFilial('SB2')+"' "
	
	If Select('SALDOSB2') <> 0
		dbSelectArea('SALDOSB2')
		('SALDOSB2')->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS ('SALDOSB2')
	
	If SALDOSB2->(!Eof())
		lAchou := .T. 
		DbSelectarea('SB2')
		Dbsetorder(1)
		DbGoto(SALDOSB2->R_E_C_N_O_)
	Else
		lAchou := .F.
	Endif      

	nCustoTOT := ROUND( (cSaldos)->DBCUSMED  *  (cSaldos)->DBQUANT , 2) 
	//nCustoTOTR:= (cSaldos)->DBCUSMED  *  (cSaldos)->DBQUANT   
     
    If lAchou
    	If SB2->B2_QFIM <> (cSaldos)->DBQUANT .OR. ;
           SB2->B2_VFIM1 <> nCustoTOT 
                  
   		  	AADD(aLogs,;
   				"("+cEmpAnt+'/'+cFilAnt+") ;"+alltrim( (cSaldos)->DBPROD )+" ";
   		     	+iif(!lAchou,";NÃO ACHOU; ",";DIVERGENTE; ") + xLocal +';' + ;
   				STRTRAN( cvaltochar(SB2->B2_QFIM),'.',',') +';'+STRTRAN( cvaltochar( (cSaldos)->DBQUANT ),'.',',') +' ; XXXX;  '+ ;//;//+ ;
   	   			STRTRAN( cvaltochar( SB2->B2_VFIM1 ),'.',',' )+';' + ;
   	   			STRTRAN( cvaltochar(nCustoTOT ),'.',','  ))    
                        
			If lAjusta
			   	RECLOCK('SB2',.F.)
					SB2->B2_QFIM      := (cSaldos)->DBQUANT 	 	   	
				   	SB2->B2_VFIM1     :=  nCustoTOT
				   	SB2->B2_USERLGI   :=  'DBGINTAJUS '+__cUserID
				   	If (cSaldos)->DBQUANT  <> 0 
				   		SB2->B2_CMFIM1    := Round( ( nCustoTOT / (cSaldos)->DBQUANT ) , 4)
				   	Endif
				SB2->(Msunlock()) 
				
				aLogs[len(aLogs)] += " ; **** REGISTRO AJUSTADO **** "
				
			Endif    	   	
   	   	 		 	                    
        	Else 
        		If lAjusta
        	   		RECLOCK('SB2',.F.)
			   			SB2->B2_USERLGI   :=  'DBGINTOK '+__cUserID	
					SB2->(Msunlock())    
				Endif  
        	Endif
        	
    Else  
  		   	AADD(aLogs,;
   						"("+cEmpAnt+'/'+cFilAnt+") ;"+alltrim( (cSaldos)->DBPROD )+" ";
   					     	+iif(!lAchou,";NÃO ACHOU; ",";DIVERGENTE; ") +xLocal +';' +   ;
   							alltrim(str(0)) +';'+STRTRAN( cvaltochar( (cSaldos)->DBQUANT ),'.',',' )+' '+ ;//;//+ ;
   	   						alltrim( str( 0) )+';' + ;
   	   						STRTRAN( cvaltochar( nCustoTOT ),'.',',' ) ) 
    Endif
	       
Return   
               

//Verificar SB9
Static Function VerifSB9(xLocal,xDataFech) 

	Local cQuery := "" 
	Local lAchou := .F.

	cQuery := ""
	cQuery += " SELECT * FROM " +RetSqlName('SB9') + " SB9 (NOLOCK)"
	cQuery += " WHERE "                
	cQuery += " B9_LOCAL = '"+xLocal+ "' "
	cQuery += " AND B9_COD = '"+alltrim((cSaldos)->DBPROD)+"' "  
	cQuery += " AND ( SUBSTRING(B9_DATA,1,6) = SUBSTRING('"+xDataFech+"',1,6)  )"    
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " AND B9_FILIAL = '"+xFilial('SB9')+"' "
	
	If Select('SALDOSB9') <> 0
		dbSelectArea('SALDOSB9')
		('SALDOSB9')->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS ('SALDOSB9')
	//conout(cQuery)
	If SALDOSB9->(!Eof())
		lAchou := .T. 
		DbSelectarea('SB9')
		Dbsetorder(1)
		DbGoto(SALDOSB9->R_E_C_N_O_)
	Else
		lAchou := .F.
	Endif      

	nCustoTOT := ROUND( (cSaldos)->DBCUSMED  *  (cSaldos)->DBQUANT , 2) 
	//nCustoTOTR:= (cSaldos)->DBCUSMED  *  (cSaldos)->DBQUANT   
     
    If lAchou
    	If SB9->B9_QINI <> (cSaldos)->DBQUANT .OR. ;
           SB9->B9_VINI1 <> nCustoTOT 

   		  	AADD(aLogs,;
   				"("+cEmpAnt+'/'+cFilAnt+") ;"+alltrim( (cSaldos)->DBPROD)+" ";
   		     	+iif(!lAchou,";NÃO ACHOU; ",";DIVERGENTE; ") + xLocal +';' + ;
   				STRTRAN( cvaltochar(SB9->B9_QINI),'.',',') +';'+STRTRAN( cvaltochar( (cSaldos)->DBQUANT ),'.',',' )+' ; XXXX;  '+ ;//;//+ ;
   	   			STRTRAN( cvaltochar( SB9->B9_VINI1 ),'.',',' )+';' + ;
   	   			STRTRAN( cvaltochar( nCustoTOT ),'.',',' ) )    

			  	If lAjusta
			   		RECLOCK('SB9',.F.)
			   			SB9->B9_QINI      := (cSaldos)->DBQUANT 	 	   	
				   		SB9->B9_VINI1     :=  nCustoTOT 
				   		If (cSaldos)->DBQUANT <> 0 
						   	SB9->B9_CM1  :=  Round( ( nCustoTOT / (cSaldos)->DBQUANT ) , 4)
				   		Else
				   			SB9->B9_CM1 := 0  
				   		Endif 
				   		SB9->B9_USERLGI  :=  'DBGINTAJUS '+__cUserID	
		  			SB9->(Msunlock()) 
		  			aLogs[len(aLogs)] += " ; **** REGISTRO AJUSTADO **** "    
		  		Endif	   	
   	   	 		 	                    
        	Else
        		If lAjusta
        	    	RECLOCK('SB9',.F.)
				   		SB9->B9_USERLGI   :=  'DBGINTOK '+__cUserID	
					SB9->(Msunlock())
				Endif      
        	Endif
        	
       Else  
  		   	AADD(aLogs,;
   						"("+cEmpAnt+'/'+cFilAnt+") ;"+alltrim((cSaldos)->DBPROD)+" ";
   					     	+iif(!lAchou,";NÃO ACHOU; ",";DIVERGENTE; ") +xLocal +';' +   ;
   							alltrim(str(0)) +';'+STRTRAN( cvaltochar( (cSaldos)->DBQUANT ) ,'.',',' )+' '+ ;//;//+ ;
   	   						alltrim( str( 0) )+';' + ;
   	   						STRTRAN( cvaltochar( nCustoTOT ) ,'.',',' ) ) 
       Endif

Return

//Mostra Log em Tela
Static function MostraLog(/*aLogs,*/xMsg)    

	Local clog := ""
	Local i    := 0

	clog += xMsg + chr(13) + chr(10)  

	conout('MostraLog') 
	conout(len(aLogs))
	//Se Não tiver Log Grava mensagem de OK
	If  len(aLogs) == 0         
		clog := " Verificação de Saldos Iniciais não encontrou Divergências! " 
	Else
		clog := "(Emp/Fil); Produto; Observacao ;Local ; Qtd PRT ;Qtd DBG ;XXXX ;Custo PRT ; Custo DBG; "+ chr(13) + chr(10)
	Endif   

	For i := 1 to len(aLogs) 
	   clog += aLogs[i] + chr(13) + chr(10)
	Next i    
	//conout(cLog)
	MemoWrite( "Log_SALDOINI_DBGINT.csv", clog )  

Return  

//Gera Saldo Inicial do Mes
/*Static Function GeraSB9(xProd,xArmazem,xQtdIni,xCusMed)
	
    Local PARAMIXB1 := {}
    Local PARAMIXB2 := 3
	PRIVATE lMsErroAuto := .F.
	
	//------------------------//| Abertura do ambiente |//------------------------
	//PREPARE ENVIRONMENT EMPRESA "YY" FILIAL "01" MODULO "EST" TABLES "SB9"
	
	//ConOut(Repl("-",80))
	//ConOut(PadC("Teste de Cadastro de Saldos Iniciais",80))
	//ConOut("Inicio: "+Time())
	//------------------------//| Teste de Inclusao    |//------------------------
	
	Begin Transaction 
	
		PARAMIXB1 := {}	 
		aadd(PARAMIXB1,{"B9_FILIAL",xFilial('SB9'),})
		aadd(PARAMIXB1,{"B9_COD",xProd,})	
		aadd(PARAMIXB1,{"B9_LOCAL",xArmazem,})
		aadd(PARAMIXB1,{"B9_CM1",xCusMed,}) 
		aadd(PARAMIXB1,{"B9_QINI",xQtdIni,})	        
	
		MSExecAuto({|x,y| mata220(x,y)},PARAMIXB1,PARAMIXB2)		
		
		If !lMsErroAuto		
			ConOut("("+cEmpAnt+'/'+cFilAnt+")Incluido com sucesso! "+xProd+xArmazem+str(xCusMed)+str(xQtdIni) )	   
		Else		
			ConOut("("+cEmpAnt+'/'+cFilAnt+")Erro na inclusao de saldo "+xProd+xArmazem+str(xCusMed)+str(xQtdIni))
			conout(mostraerro())
			AADD(aLogs,"("+cEmpAnt+'/'+cFilAnt+")Erro na inclusao de saldo: Prod/Armazem "+xProd+xArmazem+',CM:'+str(xCusMed)+',QUANT:'+str(xQtdIni) )	
		
		EndIf	
	//ConOut("Fim  : "+Time())	         
	End Transaction
	//RESET ENVIRONMENT        
	
Return Nil    
*/

/*Static Function VerDocSeq()
    
    Local cQuery 	 := "" 
    Local cVerDocSeq := "VERDOCSEQ" 
    Local cNumSeq    := SUPERGETMV('MV_DOCSEQ', .T., '000001')
    
	cQuery += " SELECT MAX(D2_NUMSEQ) AS NUMSEQ FROM "+RetSqlName('SD2')+"(NOLOCK) WHERE D_E_L_E_T_ = '' AND D2_FILIAL = '"+cFilAnt+"' "
	cQuery += " UNION ALL "
	cQuery += " SELECT MAX(D1_NUMSEQ) AS NUMSEQ FROM "+RetSqlName('SD1')+"(NOLOCK) WHERE D_E_L_E_T_ = '' AND D1_FILIAL = '"+cFilAnt+"' "
	cQuery += " UNION ALL "
	cQuery += " SELECT MAX(D3_NUMSEQ) AS NUMSEQ FROM "+RetSqlName('SD3')+"(NOLOCK) WHERE D_E_L_E_T_ = '' AND D3_FILIAL = '"+cFilAnt+"' "
	cQuery += " ORDER BY NUMSEQ DESC " 
	
	conout(cQuery)
	If Select(cVerDocSeq) <> 0
		dbSelectArea(cVerDocSeq)
		(cVerDocSeq)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cVerDocSeq) 
	(cVerDocSeq)->(dbgotop()) 
	
	conout("**VERDOCSEQ")   
	Conout(cNumSeq)           
	Conout((cVerDocSeq)->NUMSEQ)
	
	If (cVerDocSeq)->(!eof())
	   	If cNumSeq <= (cVerDocSeq)->NUMSEQ 
	   		PUTMV('MV_DOCSEQ', SOMA1((cVerDocSeq)->NUMSEQ))
	   		CONOUT('('+cEmpAnt+cFilAnt+') AJUSTOU DOCSEQ: '+cNumSeq+' -> '+(cVerDocSeq)->NUMSEQ )
	   	Endif
	Endif
   	   
Return      
*/

        /*cQuery := " SELECT * FROM "+RetsqlName('SB9')+"(NOLOCK) "
        cQuery += " WHERE B9_COD = '"+(cSaldos)->DBPROD+"' "                  
        cQuery += " AND B9_LOCAL = '"+_cArmDes+ "' "
        cQuery += " AND (SUBSTRING(B9_DATA,1,6) = '"+_cData+"'  OR  B9_DATA = '' ) "      
        cQuery += " AND D_E_L_E_T_ = '' "
        cQuery += " AND B9_FILIAL = '"+xFilial('SB9')+"' "  
        //conout(cQuery)
        If Select('XSB9') <> 0
			dbSelectArea('XSB9')
			('XSB9')->(dbCloseArea())
		Endif

   		TCQuery cQuery NEW ALIAS ('XSB9')

		XSB9->(Dbgotop()) 

   		//Se encontrou o Registro Altera
   		While XSB9->(!eof())    
   			Dbselectarea('SB9')
   			Dbsetorder(1)          
   			If Dbseek(xFilial('SB9') + XSB9->(B9_COD) + XSB9->(B9_LOCAL) + XSB9->(B9_DATA) )
   				
				conout('AGX635MI -> EXCLUIU '+xFilial('SB9') + XSB9->(B9_COD) + XSB9->(B9_LOCAL) + XSB9->(B9_DATA) ) 
   			   
   		    	Reclock('SB9',.F.)                       
   		    		DbDelete()
   		    		//SB9->B9_COD   	:= (cSaldos)->DBPROD	
					//SB9->B9_LOCAL 	:= _cArmDes
					//SB9->B9_CM1   	:= (cSaldos)->DBCUSMED
					//SB9->B9_QINI  	:= (cSaldos)->DBQUANT  
					//SB9->B9_QISEGUM := (cSaldos)->DBQUANT
   		    	SB9->(MsUnlock())
 	 	    Endif
			XSB9->(dbskip())  
		Enddo   

Static Function ReprocSD1(xDataFec)
	
	Local cQuery := ""
	
	cQuery += " SELECT * FROM "+RetSqlName('SD1')+" SD1 "
	cQuery += " INNER JOIN "+RetSqlName('SF4')+" SF4 ON F4_CODIGO = D1_TES AND F4_FILIAL = D1_FILIAL AND " 
	cQuery += " SF4.D_E_L_E_T_ = '' "
	cQuery += " WHERE D1_DTDIGIT > '"+xDataFec+"'"//= '201905'"//'"+xDataFec+*//*"'  
	cQuery += "  AND SD1.D_E_L_E_T_ = ''  AND F4_ESTOQUE = 'S' "
	cQuery += " AND D1_FILIAL = '"+xFilial('SD1')+"'  AND D1_FILIAL <> '06' AND D1_COD LIKE 'DB%' "
	conout(cQuery)
	 If Select('ReprocSD1') <> 0
		dbSelectArea('ReprocSD1')
		('ReprocSD1')->(dbCloseArea())
	Endif

   	TCQuery cQuery NEW ALIAS ('ReprocSD1')

	ReprocSD1->(dbgotop())

	While ReprocSD1->(!eof())

		DbSelectarea('SD1')
		DbSetorder(1)
		If  DbSeek(xfilial('SD1')+ReprocSD1->D1_DOC+ReprocSD1->D1_SERIE+ReprocSD1->D1_FORNECE+ReprocSD1->D1_LOJA+ ReprocSD1->D1_COD+ReprocSD1->D1_ITEM)  
			IF ALLTRIM(SD1->D1_TIPO) == 'D'
				B2AtuComD1(-1) 
				conout('D '+xfilial('SD1')+ReprocSD1->D1_DOC+ReprocSD1->D1_SERIE+ReprocSD1->D1_FORNECE+ReprocSD1->D1_LOJA+ ReprocSD1->D1_COD+ReprocSD1->D1_ITEM)
			Else
				B2AtuComD1() 
				conout(xfilial('SD1')+ReprocSD1->D1_DOC+ReprocSD1->D1_SERIE+ReprocSD1->D1_FORNECE+ReprocSD1->D1_LOJA+ ReprocSD1->D1_COD+ReprocSD1->D1_ITEM)
			endif	
		Else
			conout('NAO ACHOU '+xfilial('SD1')+ReprocSD1->D1_DOC+ReprocSD1->D1_SERIE+ReprocSD1->D1_FORNECE+ReprocSD1->D1_LOJA+ ReprocSD1->D1_COD+ReprocSD1->D1_ITEM)
		Endif

		ReprocSD1->(dbskip())
	Enddo

	//Exclui Query
	If Select('ReprocSD1') <> 0
		dbSelectArea('ReprocSD1')
		('ReprocSD1')->(dbCloseArea())
	Endif

Return


	*/
