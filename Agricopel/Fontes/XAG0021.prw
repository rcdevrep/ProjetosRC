#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"                       

/*/{Protheus.doc} XAG0021
//Workflow de envio de Produtos incluídos no dia anterior
@author Leandro Spiller
@since 06/02/2018
@version undefined
@type function
/*/
User Function XAG0021()   

   	Local   aEnvia       := {}
	Local   cQuery       := ""  
	Local   aZZR         := {}  
	Local   cRegra       := "" 
	Private cEmpresa   := "01"
	Private dDataAtual := Date()  
 
   	CONOUT('XAG0001 INICIO')
   	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO "SIGAFAT" TABLES "ZZR","SB1"    
   	
	RpcSetType(3)
 	RPCSetEnv("01","01","","","","",{"ZZR","SB1"})   
	
	Conout('XAG0001 PREPARE ENVIRONMENT')        
	
	If Type('dDatabase') == 'D'
		dDataAtual := dDatabase
	Endif
   	dDataAtual := (dDataAtual-1) 
   	
   	
   	// Varre a Tabela ZZR para capturar Regra de Envio
   	// Não foi utilizado RetSQLName devido a estar 
   	// Tudo na empresa 01
	cQuery += " SELECT * FROM ZZR010 "
	cQuery += " WHERE ZZR_EVENTO = 'INCLUSAO_PROD' "
	cQuery += " AND D_E_L_E_T_ = ''"
	cQuery += " "     
	
	If Select("XAG21ZZR") <> 0
       dbSelectArea("XAG21ZZR")
 	   dbCloseArea()
    Endif
	
	Conout('XAG0001 '+cQuery)  
    TCQuery cQuery NEW ALIAS "XAG21ZZR"  
           
    XAG21ZZR->(dbgotop())
    While  XAG21ZZR->(!eof())
                    
        aZZR   := {}
        cRegra := XAG21ZZR->ZZR_REGRA
    		
        //Se tem Regra Cadastrada  
   		If alltrim(cRegra) <> ""
   			aZZR   := Separa(cRegra,";") 
   			cEmail := XAG21ZZR->ZZR_EMAIL 
   			   
   			//Email tem email e Regra cadastrada, envia
   			If cEmail <> "" .AND. len(aZZR) > 0
	 			aEnvia := GetProduto(aZZR) //Buscar NÃO postos 
	 			If len(aEnvia) > 0   	//Envia Email dos Postos 
					EnvMail(aEnvia,cEmail)
				Endif
			Endif      
  		Endif
   	 	
   	 	XAG21ZZR->(dbskip())
    Enddo 
    
   //	RpcClearEnv()	
    	 
Return       

                          
//Busca produtos
//Parametros xPosto S/N
Static function GetProduto(xEmpresas) 

	Local aDados    := {}
	Local cQuery    := "" 
	Local cWhere    := "" 
	Local i         := 0 
	Local lEmp      := .F. 
	
	For i := 1 to len(xEmpresas)
	    
		If i > 1  
			cWhere += " OR "
		Endif     
		
		lEmp := .F. 
		
   		If SUBSTR(alltrim(xEmpresas[i]),1,2) <> "" 	
   	   		If SUBSTR(alltrim(xEmpresas[i]),1,2) <> "ZZ"   
   	   	   		cWhere += "  ( EMP_COD = '"+SUBSTR(alltrim(xEmpresas[i]),1,2)+"' "
   	   	   		lEmp := .T.
   	   		Endif
   		Endif     
   		
   		//Se tiver filial, Filtra Por Filial
   		If SUBSTR(alltrim(xEmpresas[i]),3,2) <> "" 
   			If SUBSTR(alltrim(xEmpresas[i]),3,2) <> "ZZ" 
   	   			cWhere += " EMP_FIL = '"+SUBSTR(xEmpresas[i],3,2)+"' " 
   	  		Endif
   		Endif       
   		
   		//Se Criou Where para empresa, fecha a clausula
   		If lEmp
   	   		cWhere += ") "  
   	 	Endif
   	Next i   
	 
	//Query Principal na Tabela Empresas
	cQuery := " SELECT DISTINCT(EMP_COD) AS EMP_COD FROM EMPRESAS "
		
	If alltrim(cWhere) <> "" 
		cQuery += " WHERE "+cWhere
	Endif
	  	
	If Select("X21EMPRESA") <> 0
       dbSelectArea("X21EMPRESA")
 	   dbCloseArea()
    Endif
    TCQuery cQuery NEW ALIAS "X21EMPRESA"   
          
	X21EMPRESA->(dbgotop())
	While X21EMPRESA->(!eof())	 
	
   		cEmpresa := X21EMPRESA->EMP_COD
                   		
		//Busca dados  
		cQuery := " SELECT EMP_COD,B1_FILIAL,B1_COD,B1_DESC,B1_TS,B1_TE,B1_POSIPI  FROM SB1"+cEmpresa+"0 "
		cQuery += " INNER JOIN EMPRESAS ON EMP_COD = '"+cEmpresa+"' AND (B1_FILIAL =  EMP_FIL OR B1_FILIAL = '') "
		cQuery += " WHERE "   
		cQuery += " CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(B1_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(B1_USERLGI,16,1)) - 50)),'19960101'),112)"
		cQuery += " = '"+DTOS(dDataAtual)+"' AND D_E_L_E_T_ = '' AND( B1_FILIAL =  EMP_FIL OR B1_FILIAL = '') " 
		    
		cQuery += " GROUP BY  EMP_COD,B1_FILIAL,B1_COD,B1_DESC,B1_TS,B1_TE,B1_POSIPI "
		cQuery += " ORDER BY B1_FILIAL,B1_COD "
		If Select("XAG0021") <> 0
	       dbSelectArea("XAG0021")
	 	   dbCloseArea()
	    Endif
	    TCQuery cQuery NEW ALIAS "XAG0021"   
	    
	 	XAG0021->(dbgotop())
	 	While XAG0021->(!eof())    
	 		AADD(aDados,{XAG0021->EMP_COD , XAG0021->B1_FILIAL , XAG0021->B1_COD , XAG0021->B1_DESC , XAG0021->B1_TS , XAG0021->B1_TE , XAG0021->B1_POSIPI})
	 	   	//Conout(XAG0021->EMP_COD+' | '+XAG0021->B1_FILIAL+' | '+XAG0021->B1_COD+' | '+XAG0021->B1_DESC )	
	 		XAG0021->(dbskip())
	 	Enddo
 	   
 	   	X21EMPRESA->(dbskip())        
	Enddo 
Return aDados
                          

//Realiza o Envio do Email
Static Function EnvMail(xdados,xEmail)  
      
    Local cMailEMP	  := alltrim(xEmail)
    
    conout(' XAG0021 EMAIL:'+cMailEMP) 
         
    If alltrim(cMailEMP) <> ''	                	
		oProcess := TWFProcess():New( "EMAILDATA", "Produtos Incluidos" )
		oProcess:NewTask( "Inicio", AllTrim(getmv("MV_WFDIR"))+"\XAG0021.HTM" )
		oHtml := oProcess:oHTML
		oProcess:cSubject := /*cMailEMP+*/"Produtos cadastrados na data de "+dtoc(dDataAtual) 
		                                             	
		if !Empty(Len(xdados))
			For _x := 1 to Len(xdados)// .and.  _x < 50   
				aAdd( (oHtml:ValByName( "produto.Emp" ))   , xdados[_x][1] )
		 		aAdd( (oHtml:ValByName( "produto.Filial" )), xdados[_x][2] )
	   			aAdd( (oHtml:ValByName( "produto.Codigo" )), xdados[_x][3] )
	  			aAdd( (oHtml:ValByName( "produto.Desc" ))  , xdados[_x][4] ) 
	  			aAdd( (oHtml:ValByName( "produto.Ts" ))    , xdados[_x][5] ) //XAG0021->B1_TS,
	  			aAdd( (oHtml:ValByName( "produto.Te" ))    , xdados[_x][6] ) //XAG0021->B1_TE,
	  			aAdd( (oHtml:ValByName( "produto.Ncm" ))   , xdados[_x][7] ) //XAG0021->B1_POSIPI
			Next _x
		EndIf
	        
	    //Envia e-Mail    
		oProcess:cTo := cMailEMP //'leandro.h@agricopel.com.br'//
	    
		If !Empty(oProcess:Start()) 
			oProcess:Finish() 
		Endif
    Endif
Return         
      