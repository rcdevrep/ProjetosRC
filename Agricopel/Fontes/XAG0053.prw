#include 'Protheus.ch'    
#include 'Topconn.ch'      
   
/*/{Protheus.doc} XAG0053
//Função Cria um titulo na SE1 para a NDF da nota -> chamado Via SHM460FI / M460FIM
@author Leandro Spiller
@since 24/05/2019
@version 1
@type function
/*/
User Function XAG0053()                  
                  
	Local _aAreaSE1  := GetArea()
	Local cCgcForn  := "" 
	Local cChaveSE2 := ""

	/*DBSELECTAREA('SF2')
	Dbsetorder(1)
	dbgoto(1914920)
	ALERT(SF2->F2_DOC)
	DBSELECTAREA('SE2')
	Dbsetorder(1)
	dbgoto(968671)
	ALERT(SE2->E2_NUM)*/
	cChaveSE2 := SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM  
	       
	//Posiciona e Busca CGC   
	DbSelectArea('SA2')
	DbSetOrder(1)
	If DbSeek(xFilial('SA2') + SF2->F2_CLIENTE + SF2->F2_LOJA)                       
		cCgcForn := SA2->A2_CGC    
	Endif      
	    
	//Busca Cliente pelo CNPJ
	DbSelectArea('SA1')
	DbSetOrder(3)
	If !DbSeek(xfilial('SA1') +cCgcForn )
    	//se não localizou, Cria um Novo
    	SA1Inserir()    
	Endif 
	    
	//cChaveSE2 == SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM  
	             
	//Busca Titulo na SE2
	If BuscaSE2(cChaveSE2)  
		GravaSE1(cChaveSE2)	
    Endif

	RestArea(_aAreaSE1)

Return

Static Function BuscaSE2(xChave) 

	Local cQuery  := ""
	Local _lRetSE2 := .F.
	
	cQuery := " SELECT * FROM "+RetSqlName('SE2')+"(NOLOCK) "
	cQuery += " WHERE "    
	cQuery += " E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM = '"+xChave+"' " 
	cQuery += " AND D_E_L_E_T_ = '' AND E2_TIPO = 'NDF' "   
	
	conout(cQuery)
	If Select('XAG0053SE2') <> 0 
		dbSelectArea('XAG0053SE2')
		XAG0053SE2->(dbCloseArea())
	Endif 
	
	TCQuery cQuery NEW ALIAS 'XAG0053SE2' 
	
	XAG0053SE2->(DbGotop())
	
	If XAG0053SE2->(!Eof())
		_lRetSE2 := .T.
	Endif
	
	
Return _lRetSE2      
   

//Grava título na SE1
Static Function GravaSE1(xChave)
      
	//Grava todas as Parcelas
	While XAG0053SE2->(!Eof()) 
	
		Dbselectarea('SE1')
		DbSetOrder(1) 
		If !dbseek(xfilial('SE1') + XAG0053SE2->E2_PREFIXO + XAG0053SE2->E2_NUM + XAG0053SE2->E2_PARCELA + "NCF" ) 
			RecLock("SE1",.T.)   
				SE1->E1_FILIAL      := xfilial('SE1')
				SE1->E1_PREFIXO		:= SE2->E2_PREFIXO
				SE1->E1_NUM			:= SE2->E2_NUM
				SE1->E1_PARCELA  	:= SE2->E2_PARCELA
				SE1->E1_CLIENTE		:= SA1->A1_COD
				SE1->E1_LOJA		:= SA1->A1_LOJA
				SE1->E1_NOMCLI		:= SA1->A1_NOME
				SE1->E1_EMISSAO  	:= SE2->E2_EMISSAO
				SE1->E1_VENCTO 		:= (SE2->E2_EMISSAO + 28)
				SE1->E1_VENCREA		:= DataValida( (SE2->E2_EMISSAO + 28) , .T.)      
				SE1->E1_VALOR		:= SE2->E2_VALOR
				SE1->E1_EMIS1 		:= SE2->E2_EMISSAO//STOD(cAliasSE1)->E1_EMIS1)
				SE1->E1_HIST		:= "NDF:"+xChave
				SE1->E1_LA			:= ""
				SE1->E1_SALDO		:= SE2->E2_VALOR
				SE1->E1_VALLIQ		:= SE2->E2_VALOR
				SE1->E1_VENCORI		:= SE2->E2_VENCTO 
				SE1->E1_MOEDA		:= 1
				SE1->E1_VLCRUZ		:= SE2->E2_VALOR
				SE1->E1_ORIGEM		:= "MATA460"
				SE1->E1_NATUREZ  	:= "219130" // "101011"
				SE1->E1_LA 			:= 'S'
				SE1->E1_SITUACA 	:= '0'
				SE1->E1_STATUS 		:= 'A'
				SE1->E1_TIPO 		:= "NCF"    
				SE1->E1_FILORIG		:= XAG0053SE2->E2_FILORIG    
				SE1->E1_XCHVNDF   	:= SE2->E2_FILIAL +SE2->E2_PREFIXO +SE2->E2_NUM +SE2->E2_PARCELA +SE2->E2_TIPO +SE2->E2_FORNECE +SE2->E2_LOJA
			SE1->(MsUnLock()) 
		
		Else
		
			If 'AGX635' $ alltrim(FUNNAME())
				AADD(aLogs,{;
							{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
							{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)}								,;
							{'ZDB_MSG'	  ,	'Já Existe uma NCF cadastrada: '+SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM},;
							{'ZDB_DATA'	  ,ddatabase},;
							{'ZDB_HORA'	  ,time()},;
							{'ZDB_EMP'	  ,cEmpant},;
							{'ZDB_FILIAL' ,cFilAnt},;
							{'ZDB_DBCHAV' ,""},; 
							{'ZDB_TAB' 	  ,'SE2'},; 
							{'ZDB_INDICE' ,1	},; 
							{'ZDB_TIPOWF' ,4},; 
							{'ZDB_CHAVE'  , SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM};
			})  
			
			Else
				Alert(' Já Existe uma NCF cadastrada para esse Fornecedor - por favor verifique!!! ' )
			Endif
			
		Endif
		
		XAG0053SE2->(DbSkip())	
	Enddo

Return
                 
//Insere Cliente com base no cadastro de Fornecedores
Static Function SA1Inserir()

	Local lNovoCli    := .T.
	Local cCodNovo    := ""
	Local cLojaNovo   := ""
	Local cTpPessoa   := ""
	Local cCGCBase    := ""
	Local aUltCdLj    := {}   	

	cTpPessoa := IIf( alltrim(SA2->A2_TIPO) == "F", "F", "J")
	
	If (cTpPessoa == "F")
   		cCodNovo   := SA1NovoCod()
		cLojaNovo  := "01"
	Else
		cCGCBase := SubStr(SA2->A2_CGC, 1, 8)
		aUltCdLj := SA1UltLoja(cCGCBase)
       	
		If (Len(aUltCdLj) == 2)
			cCodNovo   := aUltCdLj[1]
			cLojaNovo  := aUltCdLj[2]
   		Else
			cCodNovo   := SA1NovoCod()
   			cLojaNovo  := "01"
		EndIf
	EndIf  
     	   
    //Cria uma conta nova somente se for a primeira Loja	 
    If cLojaNovo == '01'
     	_cConta := U_X635CONT(NoAcento(AnsiToOem(SA2->A2_NREDUZ)),"SA1")  
    Else
     	//Localiza Conta no Cadastro de Clientes
       	_cConta := U_X635A1CO(cCodNovo,cLojaNovo,'SA1') 
        If Alltrim(_cConta) == ""
     		_cConta := U_X635CONT(NoAcento(AnsiToOem(SA2->A2_NREDUZ)),"SA1")
     	Endif 
    Endif
    
    DbSelectArea('SA1')
     		     
	RecLock("SA1", lNovoCli) 
	
		SA1->A1_COD     := cCodNovo
		SA1->A1_LOJA    := cLojaNovo
		SA1->A1_FILIAL  := xFilial("SA1")
		SA1->A1_CGC     := SA2->A2_CGC
		SA1->A1_NOME    := SA2->A2_NOME
		SA1->A1_NREDUZ  := SA2->A2_NREDUZ
		SA1->A1_INSCR   := SA2->A2_INSCR
		SA1->A1_END     := SA2->A2_END

		SA1->A1_BAIRRO  := SA2->A2_BAIRRO
		SA1->A1_EST     := SA2->A2_EST
		SA1->A1_COD_MUN := SA2->A2_COD_MUN
		SA1->A1_MUN_ANP := SA2->A2_MUN_ANP
		SA1->A1_MUN     := SA2->A2_MUN 
		SA1->A1_CEP     := SA2->A2_CEP
		SA1->A1_CODPAIS := SA2->A2_CODPAIS
		SA1->A1_PABCB   := SA2->A2_PABCB 
		SA1->A1_ESTE    := SA2->A2_EST 
		
		SA1->A1_TEL     := SA2->A2_TEL
		SA1->A1_DDD     := SA2->A2_DDD
		 	
		SA1->A1_CONTATO := SA2->A2_CONTATO
		SA1->A1_EMAIL   := SA2->A2_EMAIL 
		SA1->A1_VEND    := ""
		SA1->A1_LC      := 0
		SA1->A1_DTINCL  := Date() //CRIAR
		SA1->A1_DTCAD   := Date()
		If (cTpPessoa == "F") // Pessoa Física
			SA1->A1_TIPO    := "F" // L - Produtor Rural; F - Cons.Final; R - Revendedor; S - ICMS Solidário sem IPI na base; X - Exportação.
		Else
			SA1->A1_TIPO    := "R" // L - Produtor Rural; F - Cons.Final; R - Revendedor; S - ICMS Solidário sem IPI na base; X - Exportação.
		EndIf
			
		SA1->A1_PESSOA  := cTpPessoa
		SA1->A1_SITUACA := "1"   
		SA1->A1_MSBLQL  := "2"
		//SA1->A1_BLOQ    := "T" // Campo utilizado para Exportar para BLink(Agricopel Atacado)
		SA1->A1_POSTOAG := "2"  
		SA1->A1_GRPVEN  := "000001"
		SA1->A1_MAXDESC := 0.01    
		SA1->A1_TRANSP  := "000001" 
		SA1->A1_CONTA   := _cConta
		SA1->A1_TPFRET  := "C"
		SA1->A1_OBS     := ""
		SA1->A1_OBSERV  := "XAG0053"
	
	SA1->(MsUnLock())
	
	If __lSX8
		ConfirmSX8()
	EndIf
	
Return()


//Valida ultima Loja 
Static Function SA1UltLoja(cCGCBase)

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cLoja     := ""
	Local aRet      := {}

	cQuery += " SELECT SA1.A1_COD, "
	cQuery += " MAX(SA1.A1_LOJA) AS A1_LOJA "
	cQuery += " FROM " + RetSQLName("SA1") + " SA1 (NOLOCK) "
	cQuery += " WHERE SA1.D_E_L_E_T_ = '' "
	cQuery += " AND   SA1.A1_CGC LIKE '" + cCGCBase + "%' "
	cQuery += " GROUP BY SA1.A1_COD "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If !Empty((cAliasQry)->(A1_COD)) .And. !Empty((cAliasQry)->(A1_LOJA))
		aAdd(aRet, (cAliasQry)->(A1_COD))

		cLoja := Soma1((cAliasQry)->(A1_LOJA))
		aAdd(aRet, cLoja)
	EndIf

Return(aRet)
              

//Pega proximo código válido
Static Function SA1NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	cX3_Relacao := GetSX3Cache("A1_COD", "X3_RELACAO")

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA1", "A1_COD")
		EndIf

		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		lJaExiste := SA1->(DbSeek(xFilial("SA1")+cCodNovo))
	End

Return(cCodNovo)

 
/*/{Protheus.doc} XAG0053E
//Função Valida x Exclui NCF quando o Doc for estornado
@author Leandro Spiller
@since 23/07/2019
@version 1
@type function
/*/
User Function XAG0053E(xExclui)

	Local cQuery  := ""
	Local lRet    := .T.
	Local _aArea  := GetArea() 
	Local _aArray := {} 
	
	Default xExclui := .F.  
		  
	//Busca NCF
	cQuery := " SELECT "
	cQuery += " E1.R_E_C_N_O_ AS E1RECNO,E1_NUM,E1_PREFIXO,E1_TIPO,E1_BAIXA,E1_SITUACA "
	//cQuery += " (E2_FILIAL +E2_PREFIXO +E2_NUM +E2_PARCELA +E2_TIPO +E2_FORNECE +E2_LOJA) AS CHAVE "
	cQuery += " FROM "+RetSqlName('SE2')+" (NOLOCK) E2 " 
	cQuery += " INNER JOIN "+RetSqlName('SE1')+" (NOLOCK) E1 ON  E1_XCHVNDF <> '' AND E1_XCHVNDF = "  
	cQuery += " (E2_FILIAL +E2_PREFIXO +E2_NUM +E2_PARCELA +E2_TIPO +E2_FORNECE +E2_LOJA) AND E1.D_E_L_E_T_ = '' "
	cQuery += " WHERE "
	cQuery += " E2_NUM = '"+ SF2->F2_DUPL +"' AND E2_PREFIXO = '"+ SF2->F2_PREFIXO +"' "
	cQuery += " AND E2_FORNECE = '"+ SF2->F2_CLIENTE +"' AND E2_LOJA = '"+SF2->F2_LOJA+"' "
	cQuery += " AND E2_TIPO = 'NDF' AND E2.D_E_L_E_T_ = '' "
	
	If Select('XAG0053E') <> 0 
		dbSelectArea('XAG0053E')
		XAG0053E->(dbCloseArea())
	Endif 
	
	TCQuery cQuery NEW ALIAS 'XAG0053E'          
	
	XAG0053E->(DbGotop())
	
	While XAG0053E->(!eof())    
	
		//Se tiver alguma Baixa Exibe mensagem e Retorna Falso
		If !Empty(XAG0053E->E1_BAIXA)
			Alert(' Doc: '+SF2->F2_DOC+'/'+SF2->F2_SERIE+' possui uma NCF já BAIXADA e não pode ser excluído, entre em contato com o Financeiro! ')
			lRet := .F.
			Exit
		Endif   

		//Se tiver alguma Baixa Exibe mensagem e Retorna Falso
		If Alltrim(XAG0053E->E1_SITUACA) <> '0'
			Alert(' Doc: '+SF2->F2_DOC+'/'+SF2->F2_SERIE+' possui uma NCF que não está em Carteira, entre em contato com o Financeiro!  ')
			lRet := .F.
			Exit
		Endif   		
		
		XAG0053E->(DbSkip())
	Enddo
	      
	//Se For para Excluir e não tiver baixas, realiza a Exclusão do Título
	If xExclui .AND. lRet  
	
		XAG0053E->(DbGotop())	
		While XAG0053E->(!eof())
			
			DbSelectArea("SE1") 
			DbSetOrder(1)  
			SE1->(DbGoto(XAG0053E->E1RECNO)) 
			
			//Exclui somente a NCF
		  	If alltrim(SE1->E1_TIPO) == 'NCF' 
			  	_aArray := { { "E1_PREFIXO" , SE1->E1_PREFIXO      , NIL },; 
							 { "E1_NUM" 	, SE1->E1_NUM      	   , NIL },; 
				             { "E1_TIPO"    , SE1->E1_TIPO         , NIL } } 
				      
				lMsErroAuto := .F.
				          
				MSExecAuto({|x, y| FINA040(x, y)}, _aArray, 5)  
				       
				If lMsErroAuto 
				   MostraErro() 
				   lRet := .F.
				Endif
			Endif
			
			XAG0053E->(DbSkip())
		Enddo
	Endif
	
	//Fecha arquivo de trabalho
	If Select('XAG0053E') <> 0 
		dbSelectArea('XAG0053E')
		XAG0053E->(dbCloseArea())
	Endif 
	
	RestArea(_aArea)

Return lRet        


/*/{Protheus.doc} XAG0053V
//Função Valida se Executa Rotina de Boletos para Devoluções 
@author Leandro Spiller
@since 05/09/2019
@version 1
@type function
/*/
User Function XAG0053V(xFilCheck)
      
	Local lGeraNCF 	 := .F.   
	Local cFilBolDev := ""   
	Local dDtCorte   := Stod("20190909")
	
	Default xFilCheck := cFilAnt    
	     
	//Data de Corte para Inicio da Validação
	If dDatabase  < dDtCorte
		Return .F.	
	Endif
	
	 
	//Captura parâmetro de geração de Boletos para Dev.     
	cFilBolDev := SUPERGETMV("MV_XBOLDEV", .F., "")
	  
	//Verifica se filial Gera Boletos para Forn. 
	If Alltrim(cFilBolDev) <> ''                                           
		If ( UPPER(xFilCheck) $ UPPER(cFilBolDev) ) .or. ('ZZ' $ UPPER(cFilBolDev) )
	    	lGeraNCF := .T.
		Endif
	Endif   
	

Return lGeraNCF
