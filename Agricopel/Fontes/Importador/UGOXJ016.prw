#Include 'Protheus.ch'

/*/{Protheus.doc} UGOXJ016
JOB para efetuar o envio do relatorio de documentos manifestados  
@author Crele C. Da Costa
@since 28/09/2018
@version 1.0
@see (links_or_references)
/*/
User Function UGOXJ016( _aParms )

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

	conout("[UGOXJ016] Realizando a manifestação dos documentos com erro - Empresa: " + aRecnoSM0[_e][1] + " - " + DtoC(Date()) + " - " + time())
	U_JBGOX016('E')

	conout("[UGOXJ016] Realizando a verificação da manifestação dos documentos - Empresa: " + aRecnoSM0[_e][1] + " - " + DtoC(Date()) + " - " + time())
	U_JBGOX016()

	RpcClearEnv()
	
Next

Return


/*/{Protheus.doc} JBGOX016
JOB para efetuar o envio do relatorio de documentos manifestados  
@author Crele C. Da Costa
@since 28/09/2018
@version 1.0
@see (links_or_references)
/*/
User Function JBGOX016( cAcao )

Local dDtFilter := dDataBase - 1
Local cDescOper
Local oWFMnf

Default cAcao = ''

if empty(cAcao)

	If File("\workflow\modelos\importador\XML_MNF.htm")
	
		If (Select("QRY") <> 0)
			QRY->(dbCloseArea())
		Endif
		
		BEGINSQL ALIAS "QRY"
		    column F1_EMISSAO as Date, F1_DTDIGIT as Date 
		   
			SELECT ZD7.*, ZD7.R_E_C_N_O_ RECNOZD7, F1.*
			FROM %table:ZD7% ZD7
			INNER JOIN %table:SF1% F1 on f1_filial = zd7_filial and f1_chvnfe = zd7_chave
			WHERE ZD7.%notdel% and F1.%notdel%
			and f1_dtdigit >= %exp:dtos(dDtFilter)%
			//and f1_dtdigit >= '20180801' and f1_dtdigit <= '20181015'
			//and zd7_chave = '42180884432111000167550030005248361007260151'  
			 
			and zd7_tipo = '1' and zd7_sit != '5'
			and F1_ESPECIE = 'SPED'
			and F1_EST <> 'EX'
			and F1_FORMUL <> 'S'
			and F1_STATUS <> ' '
			order by ZD7_FILIAL, ZD7_MNTO2 
			
		ENDSQL
		
		nPri := 0
		QRY->(dbGotop())
		While QRY->(!eof())
	
			if empty(nPri)
				nPri := 1
				
				oWFMnf := TWFProcess():New("000001", OemToAnsi("Manifesto Destinatário Automático"))
				
				oWFMnf:NewTask("000001", "\workflow\modelos\importador\XML_MNF.htm")
				
				oWFMnf:cSubject 	:= "Manifesto Destinatário Automático"
				oWFMnf:bReturn  	:= ""
				oWFMnf:bTimeOut	:= {}
				oWFMnf:fDesc 		:= "Manifesto Destinatário Automático"
				oWFMnf:ClientName(cUserName)
				
			endif
				
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt + QRY->ZD7_FILIAL))
			cFilAnt := QRY->ZD7_FILIAL
			
			
			cChave := QRY->ZD7_CHAVE
			cOper  := "2"
			cJust  := ""
			
			//cMntX  := QRY->ZD7_MNTO2
			cMntX  := ''
	
			/*
			If cOper == "1"
				
				cDescOper := "Ciência da Operação"
				
			ElseIf cOper == "2"
				
				cDescOper := "Confirmação da Operação"
				
			ElseIf cOper == "3"
				
				cDescOper := "Desconhecimento da Operação"
				
			ElseIf cOper == "4"
				
				cDescOper := "Operação não Realizada"
				
			EndIf
			*/
			
			//Serviço de manifestação
			oWSMnf := WSGdeManif():New()
			
			oWSMnf:cCNPJ          := SM0->M0_CGC
			oWSMnf:cChave         := cChave
			oWSMnf:cLogin         := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
			oWSMnf:cSenha         := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
			oWSMnf:cManifestacao  := cOper
			oWSMnf:cJustificativa := cJust
			
			if empty(QRY->ZD7_MNTO1 + QRY->ZD7_MNTO2 + QRY->ZD7_MNTO3 + QRY->ZD7_MNTO4)
			
				If oWSMnf:GetManifestacao()
					
					/*
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
					*/
					ZD7->(dbGoto(QRY->RECNOZD7))
					ZD7->(recLock('ZD7', .F.))
					Do Case
						Case AllTrim(oWSMnf:cGetManifestacaoResult) == '1'
							ZD7->ZD7_MNTO1 := '1'
							ZD7->ZD7_MNTO2 := ''
							ZD7->ZD7_MNTO3 := ''
							ZD7->ZD7_MNTO4 := ''
							cMntX  := '1'
							cOper  := '1'
						Case AllTrim(oWSMnf:cGetManifestacaoResult) == '2'
							ZD7->ZD7_MNTO2 := '1'
							ZD7->ZD7_MNTO1 := ''
							ZD7->ZD7_MNTO3 := ''
							ZD7->ZD7_MNTO4 := ''
							cMntX  := '1'
							cOper  := '2'
						Case AllTrim(oWSMnf:cGetManifestacaoResult) == '3'
							ZD7->ZD7_MNTO3 := '1'
							ZD7->ZD7_MNTO1 := ''
							ZD7->ZD7_MNTO2 := ''
							ZD7->ZD7_MNTO4 := ''
							cMntX  := '1'
							cOper  := '3'
						Case AllTrim(oWSMnf:cGetManifestacaoResult) == '4'
							ZD7->ZD7_MNTO4 := '1'
							ZD7->ZD7_MNTO1 := ''
							ZD7->ZD7_MNTO2 := ''
							ZD7->ZD7_MNTO3 := ''
							cMntX  := '1'
							cOper  := '4'
					EndCase
					ZD7->(msUnlock())
					
					if AllTrim(oWSMnf:cGetManifestacaoResult) == '0'
					
						If oWSMnf:PutManifestacao()
							If oWSMnf:cPutManifestacaoResult == "OK"
							
								//Flag como MANIFESTADO o documento
								ZD7->(dbGoto(QRY->RECNOZD7))
								ZD7->(recLock('ZD7', .F.))
								ZD7->ZD7_MNTO2 := '1'
								ZD7->ZD7_MNTO1 := ''
								ZD7->ZD7_MNTO3 := ''
								ZD7->ZD7_MNTO4 := ''
								ZD7->(msUnlock())
								
								cMntX  := '1'
								cOper  := '2'
								
							endif
						endif

					endif
					
				EndIf
			
			else
			
				Do Case
					Case QRY->ZD7_MNTO4 == '1'
						cOper  := '4'
						cMntX  := '1'
					Case QRY->ZD7_MNTO4 == 'E'
						cMntX  := 'E'
					Case QRY->ZD7_MNTO3 == '1'
						cOper  := '3'
						cMntX  := '1'
					Case QRY->ZD7_MNTO3 == 'E'
						cMntX  := 'E'
					Case QRY->ZD7_MNTO2 == '1'
						cOper  := '2'
						cMntX  := '1'
					Case QRY->ZD7_MNTO2 == 'E'
						cMntX  := 'E'
					Case QRY->ZD7_MNTO1 == '1'
						cOper  := '1'
						cMntX  := '1'
					Case QRY->ZD7_MNTO1 == 'E'
						cMntX  := 'E'
				EndCase
			endif
			
	
			If cOper == "1"
				
				cDescOper := "Ciência da Operação"
				
			ElseIf cOper == "2"
				
				cDescOper := "Confirmação da Operação"
				
			ElseIf cOper == "3"
				
				cDescOper := "Desconhecimento da Operação"
				
			ElseIf cOper == "4"
				
				cDescOper := "Operação não Realizada"
				
			EndIf
			
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
			AAdd(oWFMnf:oHTML:ValByName('xm.cChave') 	, alltrim(QRY->ZD7_CHAVE))
			AAdd(oWFMnf:oHTML:ValByName('xm.cValor') 	, Transform(QRY->F1_VALBRUT, "@E 999,999,999.99"))
			AAdd(oWFMnf:oHTML:ValByName('xm.cUsuario') 	, alltrim(QRY->F1_NOMEUSR))
			
			//Se manifestada
			if cMntX == '1'
	
				AAdd(oWFMnf:oHTML:ValByName('xm.cTipo')  	, "(" + cOper + ") - " + cDescOper)
	
			elseif cMntX == 'E'
	
				AAdd(oWFMnf:oHTML:ValByName('xm.cTipo')  	, "MANIFESTACAO COM ERRO")
	
			else
	
				AAdd(oWFMnf:oHTML:ValByName('xm.cTipo')  	, "DOCUMENTO NAO MANIFESTADO")
	
			endif
			
		
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
	
//manifestar documentos com erro
else

	If (Select("QRY") <> 0)
		QRY->(dbCloseArea())
	Endif
	
	BEGINSQL ALIAS "QRY"
	    column F1_EMISSAO as Date, F1_DTDIGIT as Date 
	   
		SELECT ZD7.*, ZD7.R_E_C_N_O_ RECNOZD7, F1.*
		FROM %table:ZD7% ZD7
		INNER JOIN %table:SF1% F1 on f1_filial = zd7_filial and f1_chvnfe = zd7_chave
		WHERE ZD7.%notdel% and F1.%notdel%
		and zd7_tipo = '1' and zd7_sit != '5'
		and F1_ESPECIE = 'SPED'
		and F1_EST <> 'EX'
		and F1_FORMUL <> 'S'
		and F1_STATUS <> ' '
		and (ZD7_MNTO1 = 'E' or ZD7_MNTO2 = 'E' or ZD7_MNTO3 = 'E' or ZD7_MNTO4 = 'E')
	ENDSQL
	
	nPri := 0
	QRY->(dbGotop())
	While QRY->(!eof())

		conout('Documento: ' + QRY->ZD7_FILIAL + ' - ' + QRY->F1_CHVNFE)
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt + QRY->ZD7_FILIAL))
		cFilAnt := QRY->ZD7_FILIAL

		/*
		_aRetMnf := U_SENX11MD(QRY->F1_CHVNFE)
		
		If _aRetMnf[1] .and. empty(_aRetMnf[2])
			conout('>>> Doc Manifestado que estava com erro: ' + QRY->F1_CHVNFE)
		else
			conout('>>> Doc nao processado que estava com erro: ' + QRY->F1_CHVNFE)
			conout(_aRetMnf[1])
			if !empty(_aRetMnf[2])
				conout('>>> - ' + _aRetMnf[2])
			endif
		endif
		
		//Se documento já manifestado
		If _aRetMnf[1] .and. empty(_aRetMnf[2])
		
			ZD7->(dbGoto(QRY->RECNOZD7))
			ZD7->(recLock('ZD7', .F.))
			ZD7->ZD7_MNTO2 := '1'
			ZD7->(msUnlock())
		
		Endif
		*/
		
		_aRetMnf := U_SENX11GMD(QRY->F1_CHVNFE)
		
		If _aRetMnf[1]

			ZD7->(dbGoto(QRY->RECNOZD7))
			ZD7->(recLock('ZD7', .F.))
			Do Case
				Case _aRetMnf[2] == '1'
					ZD7->ZD7_MNTO1 := '1'
					ZD7->ZD7_MNTO2 := ''
					ZD7->ZD7_MNTO3 := ''
					ZD7->ZD7_MNTO4 := ''
				Case _aRetMnf[2] == '2'
					ZD7->ZD7_MNTO2 := '1'
					ZD7->ZD7_MNTO1 := ''
					ZD7->ZD7_MNTO3 := ''
					ZD7->ZD7_MNTO4 := ''
				Case _aRetMnf[2] == '3'
					ZD7->ZD7_MNTO3 := '1'
					ZD7->ZD7_MNTO1 := ''
					ZD7->ZD7_MNTO2 := ''
					ZD7->ZD7_MNTO4 := ''
				Case _aRetMnf[2] == '4'
					ZD7->ZD7_MNTO4 := '1'
					ZD7->ZD7_MNTO1 := ''
					ZD7->ZD7_MNTO2 := ''
					ZD7->ZD7_MNTO3 := ''
			EndCase
			ZD7->(msUnlock())

		Else
		
			U_SENX11MD(QRY->F1_CHVNFE)
			
		Endif

		QRY->(dbSkip())
	End
	
	If (Select("QRY") <> 0)
		QRY->(dbCloseArea())
	Endif

endif

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
