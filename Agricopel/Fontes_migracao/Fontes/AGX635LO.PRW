#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} AGX635LO
//ROTINA DE INTEGRAÇÃO COM DBGINT - GERAÇÃO DE LOGS
@author Spiller
@since 28/09/2017
@version undefined
@param xLogs, array, Primeira linha Campos, demais Registros
@param xFuncao, Char, Função
@param xDescFun, Char, Descrição da função
@param xChave, Char , Chave de busca de dados 
@type function
/*/

User Function AGX635LO(xLogs,xFuncao,xDescFun)
     
    Local _cTypeCampo := "" 
    Local _cTypeReg   := ""
         
	Default xLogs    := {}
	Default xFuncao  := ''                        
	Default xDescFun := ''                        
		        
    //Executa SetEnv
    //If lSetEnv 
     PREPARE ENVIRONMENT Empresa '01' Filial '01' Tables "ZDB","SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","SF2","SD2","SF3","SE1"	 
 	 RPCSetType(3)
	 RPCSetEnv('01', '01') 
    //Endif  
       
    //Grava dados 
    For i := 1 to len(xLogs)
   		Reclock('ZDB',.T.) 
   			For z := 1 to len(xLogs[i])  
   	 			 //Formata Registros
   				_cTypeCampo := valtype(&(xLogs[i][z][1])) //xLogs[i][z][1]
		   		_cTypeReg   := valtype(xLogs[i][z][2])   //xLogs[i][z][2]
		   		
		   		If _cTypeCampo == _cTypeReg 		
		   		  &(xLogs[i][z][1]) := xLogs[i][z][2] 
		   		Else
		   			If _cTypeCampo == 'C'
		   			    If _cTypeReg == 'N'
		   				    &(xLogs[i][z][1]) := alltrim(str(xLogs[i][z][2])) 
		   			    ElseIF _cTypeReg == 'D'
		   			  	    &(xLogs[i][z][1]) := dtos(xLogs[i][z][2]) 
		   			    Endif
		   			Elseif _cTypeCampo == 'D' 
		   				if _cTypeReg == 'C'
		   			  	    &(xLogs[i][z][1]) := ctod(xLogs[i][z][2]) 
		   			    Endif
		   			Elseif  _cTypeCampo == 'N' 	
		   		   		if _cTypeReg == 'C' 
		   		   	  		&(xLogs[i][z][1]) := val(xLogs[i][z][2])
		   		   		Endif
		   		    Endif	   		 
	  			Endif  
   	   		
   	   		Next z 
   		ZDB_ROTINA 	   := xFuncao
	  	ZDB_DESCRO 	   := xDescFun  
	  	ZDB->(MsUnlock())   
	   	                  
        //Quando está cadastrado Tipo WF envia E-mail
        //Verificar Regras na Planilha de WF na pasta x\DbGINt da contabilidade
        If ZDB->ZDB_TIPOWF > 0  .and. !( substr(alltrim(GetEnvServer()),1,10) == 'N2SD9W_HOM' .OR. substr(alltrim(GetEnvServer()),1,12) == 'N2SD9W_MIGRA')        
            
           	aEnvWF := {}
			cMens := "("+ZDB->ZDB_EMP+" - "+ZDB->ZDB_FILIAL+") "+ZDB->ZDB_MSG
			Aadd(aEnvWF,cMens)
           	EnvMailDB(aEnvWF,ZDB->ZDB_EMP,ZDB->ZDB_FILIAL,ZDB->ZDB_TIPOWF,ZDB->ZDB_ROTINA)
           
        Endif

	  	
    Next i 
                 
   	RPCClearEnv()
   	RESET ENVIRONMENT
Return       


//Email de LOG do DBGint
Static Function EnvMailDB(aCadPro, cEmpEmail,cFilMail,xTipoWF,xRotina)

	Local nTotal    := 0
	Local _x        := 0
	Local cDest     := ""
	Local EnvEmail  := .T.  
	Local cEventoDB := ""  
	Local cCC       := ""
             
	//Tabela de destinatários
	//DBGINT_LOG_EMPRESA_TIPO
	If EnvEmail .and. xTipoWF  > 0      
	
		Conout(" AGX635LO - ENVIANDO E-MAIL TIPO "+alltrim(str(xTipoWF))) 		

    	//Tabela de destinatários
   		//DBGINT_LOG_EMPRESA_TIPO 
   		cEventoDB := "" 
   		cDest     := ""
       	cEventoDB := 'DBGINT_LOG_'+alltrim(str(xTipoWF))               
       	cDest := RetDest(cEmpEmail,cFilMail,cEventoDB)
       	      
       	//Caso seja do projeto Nyke, Coloca em cópia 
       	If len(aCadPro) > 0 
       		If 'NYKE' $ UPPER(aCadPro[1])
      	 		cEventoDB := 'DBGINT_NYKE' 
       			cCC := RetDest(cEmpEmail,cFilMail,cEventoDB)
			Endif
		Endif
		Conout(cDest)
	   	/*
	   	//De acordo com o Tipo e Empresa, Envia os LOGS  
		//Consultar Planilha DBGInt\LOGXEMAIL no Diretorio x da Contabilidade  
	   	Do Case
			Case  xTipoWF == 1
				If cEmpEmail == '12'  .or. cEmpEmail == '50'
			   		cDest  := "vanessa@agricopel.com.br; compras.cadastro@agricopel.com.br"
				Else
			  		cDest  := "thaiara@agricopel.com.br; compras.cadastro@agricopel.com.br; mara@agricopel.com.br"
				Endif
			Case  xTipoWF == 2
				If cEmpEmail == '12'  .or. cEmpEmail == '50'
					cDest  := "thaiara@agricopel.com.br; compras.cadastro@agricopel"
				Else
		   			cDest  := "thaiara@agricopel.com.br; cadastro@agricopel.com.br;mara@agricopel.com.br"
				Endif
			Case  xTipoWF == 3
				If cEmpEmail == '12'  .or. cEmpEmail == '50'
		   			cDest  := "thaiara@agricopel.com.br;mara@agricopel.com.br"
				Else
		  			cDest  := "thaiara@agricopel.com.br;mara@agricopel.com.br"
				Endif
			Case  xTipoWF == 4
				If cEmpEmail == '12'  .or. cEmpEmail == '50'
		 			cDest  := "vanessa@agricopel.com.br"
				Else
		  			cDest  := "thaiara@agricopel.com.br;mara@agricopel.com.br"
				Endif
			Case  xTipoWF == 5
				If cEmpEmail == '12'  .or. cEmpEmail == '50'
		  			cDest  := "vanderleia@agricopel.com.br;thaiara@agricopel.com.br"
				Else
		  			cDest  := "vanderleia@agricopel.com.br;thaiara@agricopel.com.br"
				Endif
			Case  xTipoWF == 6
				If cEmpEmail == '12'  .or. cEmpEmail == '50'
			 		cDest  := "vanderleia@agricopel.com.br;thaiara@agricopel.com.br"
				Else
		   			cDest  := "vanderleia@agricopel.com.br;thaiara@agricopel.com.br"
				Endif
			Case  xTipoWF == 7
				If cEmpEmail == '12'  .or. cEmpEmail == '50'
		   			cDest  := "vanessa@agricopel.com.br"
				Else
		  			cDest  := "thaiara@agricopel.com.br;mara@agricopel.com.br"
				Endif
			Case  xTipoWF == 8    
		 		cDest  := "spiller@agricopel.com.br"
		Endcase
		
		Conout(cDest)
		*/
		//aqui
	   	If alltrim(cDest) == "" .OR. (substr(alltrim(GetEnvServer()),1,10) == 'N2SD9W_HOM'	.OR. substr(alltrim(GetEnvServer()),1,12) == 'N2SD9W_MIGRA')
			cDest  := 'spiller@agricopel.com.br'
		Endif         

		 
		oProcess := TWFProcess():New( "EMAILDATA", "Produtos DBGInt" )
		oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\dbGintWF.HTML" )
		oHtml := oProcess:oHTML
		oProcess:cSubject := /*cDest+*/"ERRO IMPORTAÇÃO, Empresa: " + cEmpEmail// + cDest //aqui

		aAdd( (oHtml:ValByName( "info.mensagem" )), ""  )
		if !Empty(Len(aCadPro))
			For _x := 1 to Len(aCadPro)
				aAdd( (oHtml:ValByName( "info.mensagem" )), aCadPro[_x] )
			Next
		EndIf
                                                                                        
      	oProcess:cTo := cDest//'spiller@agricopel.com.br'//cDest   
      	
      	//Caso tenha cópia para enviar                       
      	If alltrim(cCC) <> ''
      		oProcess:cCC := cCC
      	Endif
		oProcess:Start()
		oProcess:Finish()
	Else
		LogConsole(" Envio de e-mail desabilitado, verifique a variavel EnvEmail ")
	Endif
Return

                     
Static Function RetDest(xEmp,xFil,xEvento)

	Local cQuery     := ""  
	Local cTabRest   := 'RetDest'
	Local cEmailRest := ""
	
	cQuery := " SELECT * FROM ZZR010"
	cQuery += " Where "
	//ZZR_EMPRES LIKE '%"+xEmp+"%' "
	cQuery += " ZZR_EVENTO = '"+xEvento+"' "
	cQuery += " AND (ZZR_REGRA LIKE '%"+xEmp+xFil+"%' OR ZZR_REGRA LIKE  '%"+xEmp+"ZZ%' OR ZZR_REGRA LIKE  '%ZZZZ%') "
	cQuery += " AND D_E_L_E_T_ = '' " 
	 
	 If Select(cTabRest) <> 0
  		dbSelectArea(cTabRest)
   		(cTabRest)->(dbCloseArea())
  	Endif

 	TCQuery cQuery NEW ALIAS (cTabRest)   
 	
 	      
    (cTabRest)->(dbgotop())
	While (cTabRest)->(!eof())
	    
	    //Inclui ; para separação de e-mails            
	    If  alltrim(cEmailRest) <> "" 
	    	If substr(alltrim(cEmailRest),len(alltrim(cEmailRest)) ,1 ) <> ";"
	       		cEmailRest  += ";"   
	     	Endif
	    Endif
	    
		cEmailRest += AllTrim((cTabRest)->ZZR_EMAIL) 
  
    	(cTabRest)->(dbSkip())
	Enddo       
	
	If alltrim(cEmailRest) = ""
   		cEmailRest := 'spiller@agricopel.com.br'
	Endif   
	
Return cEmailRest                            

