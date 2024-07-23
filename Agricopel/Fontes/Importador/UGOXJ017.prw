#Include 'Protheus.ch'

/*/{Protheus.doc} UGOXJ017
JOB para efetuar a conferencia de manifestações  
@author Crele C. Da Costa
@since 05/11/2018
@version 1.0
@see (links_or_references)
/*/
User Function UGOXJ017( _aParms )

Local aRecnoSM0 := {}
Local _e

Default _aParms := {"01"}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If SM0->M0_CODIGO == _aParms[1]
			aAdd( aRecnoSM0, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
			exit
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

Endif

For _e := 1 to len(aRecnoSM0)

	RPCSetType(3)
	RPCSetEnv(aRecnoSM0[_e][1],aRecnoSM0[_e][2],"","","","",{"ZD7"})

	conout("[UGOXJ017] Realizando a conferência da manifestação dos documentos - Empresa: " + aRecnoSM0[_e][1] + " - " + DtoC(Date()))
	U_JBGOX017()

	RpcClearEnv()
	
Next

Return


/*/{Protheus.doc} JBGOX017
JOB para efetuar a conferencia de manifestações
@author Crele C. Da Costa
@since 05/11/2018
@version 1.0
@see (links_or_references)
/*/
User Function JBGOX017()

Local dDtLimite := dDataBase - 1
Local dDtFilter := dDtLimite - 180
Local cDescOper

If File("\workflow\modelos\importador\XML_MNF_INCO.htm")

	//Pesquisar notas com o campo em branco de controle de manifestação
	If (Select("QRY") <> 0)
		QRY->(dbCloseArea())
	Endif
	
	BEGINSQL ALIAS "QRY"
	    column F1_EMISSAO as Date, F1_DTDIGIT as Date 
	   
		SELECT ZD7.*, ZD7.R_E_C_N_O_ RECNOZD7, F1.*
		FROM %table:ZD7% ZD7
		INNER JOIN %table:SF1% F1 on f1_filial = zd7_filial and f1_chvnfe = zd7_chave
		WHERE ZD7.%notdel% and F1.%notdel%
		and f1_dtdigit between %exp:dtos(dDtFilter)% and %exp:dtos(dDtLimite)% 
		 
		and zd7_tipo = '1' and zd7_sit != '5'
		and F1_ESPECIE = 'SPED'
		and F1_EST <> 'EX'
		and F1_FORMUL <> 'S'
		and F1_STATUS <> ' '
		and ZD7_MNTO2 = ' '
		order by ZD7_FILIAL, ZD7_MNTO2 
		
	ENDSQL
	While QRY->(!eof())

		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt + QRY->ZD7_FILIAL))
		cFilAnt := QRY->ZD7_FILIAL
		
		
		cChave := QRY->ZD7_CHAVE
		cOper  := "2"
		cJust  := ""
		
		cMntX  := QRY->ZD7_MNTO2

		If cOper == "1"
			
			cDescOper := "Ciência da Operação"
			
		ElseIf cOper == "2"
			
			cDescOper := "Confirmação da Operação"
			
		ElseIf cOper == "3"
			
			cDescOper := "Desconhecimento da Operação"
			
		ElseIf cOper == "4"
			
			cDescOper := "Operação não Realizada"
			
		EndIf
		
		//Serviço de manifestação
		oWSMnf := WSGdeManif():New()
		
		oWSMnf:cCNPJ          := SM0->M0_CGC
		oWSMnf:cChave         := cChave
		oWSMnf:cLogin         := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
		oWSMnf:cSenha         := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
		oWSMnf:cManifestacao  := cOper
		oWSMnf:cJustificativa := cJust

		If oWSMnf:GetManifestacao()
		
			//conout('>>> ' + oWSMnf:cGetManifestacaoResult)
			
			If SubStr(oWSMnf:cGetManifestacaoResult, 1, 1) >= cOper
				
				ZD7->(dbGoto(QRY->RECNOZD7))
				ZD7->(recLock('ZD7', .F.))
				ZD7->ZD7_MNTO2 := '1'
				ZD7->(msUnlock())
				
				cMntX  := '1'
			
			elseIf (SubStr(oWSMnf:cGetManifestacaoResult, 1, 1) == '0' .or. SubStr(oWSMnf:cGetManifestacaoResult, 1, 1) == '1') 
			
				If oWSMnf:PutManifestacao()
					If oWSMnf:cPutManifestacaoResult == "OK"
					
						//Flag como MANIFESTADO o documento
						ZD7->(dbGoto(QRY->RECNOZD7))
						ZD7->(recLock('ZD7', .F.))
						ZD7->ZD7_MNTO2 := '1'
						ZD7->(msUnlock())
						
						cMntX  := '1'
						
					endif
				endif
				
			
			EndIf
			
		EndIf
	
		QRY->(dbSkip())
	End
	
	If (Select("QRY") <> 0)
		QRY->(dbCloseArea())
	Endif
	//Fim	
	
	//Checar se documento está nas tabelas corretas 
	If (Select("QRY") <> 0)
		QRY->(dbCloseArea())
	Endif
	
	BEGINSQL ALIAS "QRY"
	    column F1_EMISSAO as Date, F1_DTDIGIT as Date 
	   
		SELECT f1_chvnfe,F1.*
		FROM %table:SF1% F1
		WHERE F1.%notdel%
		and f1_dtdigit >= %exp:dtos(dDtFilter)%
		and F1_ESPECIE = 'SPED'
		and F1_EST <> 'EX'
		and F1_FORMUL <> 'S'
		and F1_STATUS <> ' '
		and not exists (select * from %table:ZD7% zd7 where zd7.%notdel% 
		and zd7_filial = f1_filial and f1_chvnfe = zd7_chave)
		
	ENDSQL
	
	nPri := 0
	QRY->(dbGotop())
	While QRY->(!eof())

		if empty(nPri)
			nPri := 1
			
			oWFMnf := TWFProcess():New("000001", OemToAnsi("Tabela Manifesto Inconsistente"))
			
			oWFMnf:NewTask("000001", "\workflow\modelos\importador\XML_MNF_INCO.htm")
			
			oWFMnf:cSubject 	:= "Tabela Manifesto Inconsistente"
			oWFMnf:bReturn  	:= ""
			oWFMnf:bTimeOut	:= {}
			oWFMnf:fDesc 		:= "Tabela Manifesto Inconsistente"
			oWFMnf:ClientName(cUserName)
			
		endif
			
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt + QRY->F1_FILIAL))
		cFilAnt := QRY->F1_FILIAL
		
		
		oWFMnf:oHTML:ValByName('cEmpresa', cEmpAnt + " - " + AllTrim(FWGrpName()))
		
		cNome := ''
		if QRY->F1_TIPO  $ "D;B"
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial('SA1') + QRY->F1_FORNECE + QRY->F1_LOJA))
			cNome := SA1->A1_NOME
		else
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial('SA2') + QRY->F1_FORNECE + QRY->F1_LOJA))
			cNome := SA2->A2_NOME
		endif
		
		AAdd(oWFMnf:oHTML:ValByName('xm.cFilial')	, cFilAnt)
		AAdd(oWFMnf:oHTML:ValByName('xm.cEspecie')	, QRY->F1_ESPECIE)
		AAdd(oWFMnf:oHTML:ValByName('xm.cDigita')	, dtoc(QRY->F1_DTDIGIT))
		AAdd(oWFMnf:oHTML:ValByName('xm.cEmissao')	, dtoc(QRY->F1_EMISSAO))
		AAdd(oWFMnf:oHTML:ValByName('xm.cNumero')	, QRY->F1_DOC + '/' + QRY->F1_SERIE)
		AAdd(oWFMnf:oHTML:ValByName('xm.cForn')  	, QRY->F1_FORNECE + "/" + QRY->F1_LOJA)
		AAdd(oWFMnf:oHTML:ValByName('xm.cNomFor')  	, alltrim(cNome))
		AAdd(oWFMnf:oHTML:ValByName('xm.cChave') 	, alltrim(QRY->F1_CHVNFE))
		AAdd(oWFMnf:oHTML:ValByName('xm.cValor') 	, Transform(QRY->F1_VALBRUT, "@E 999,999,999.99"))
		AAdd(oWFMnf:oHTML:ValByName('xm.cUsuario') 	, alltrim(QRY->F1_NOMEUSR))
		
		QRY->(dbSkip())
	End
	
	If (Select("QRY") <> 0)
		QRY->(dbCloseArea())
	Endif
	
	
	If ValType(oWFMnf) == "O"
		
		oWFMnf:cTo := GetNewPar("MV_ZSNXMNE", "octaviomac@gmail.com")
		//oWFMnf:cTo := 'crelec@gmail.com'
		
		// Inicia o processo
		oWFMnf:Start()
		// Finaliza o processo
		oWFMnf:Finish()
		
	EndIf
	
	//conout('>>>>> acabou')

Endif

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  10/12/15
@obs    Gerado por EXPORDIC - V.4.25.11.9 EFS / Upd. V.4.20.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

Return lOpen
