#INCLUDE "PROTHEUS.CH"   
//#INCLUDE "SPEDNFE.CH"
#INCLUDE "APWIZARD.CH"  

//##########################################################//
//  Manifesta��o manual adequada para utiliza��o via JOB    //
//  Utilizado inicilamente pela Rotina AGX518               //
//  Leandro Spiller - 27.12.2016          				    //
//##########################################################//
User Function SLAManif(cAlias,nReg,nOpcx)

	Local cChaveTeste := ""   
	Local _aArea := getArea()
	Local _nREc  := nReg //387045
	          
	CONOUT('SLAManif - Acesso a rotina')
	
	dbselectarea('SF1')
	dbsetorder(1)
	dbgoto(_nREc)
	
	If SF1->F1_FORMUL <> "S" .and. !Empty(SF1->F1_CHVNFE) .and. Alltrim(SF1->F1_ESPECIE) == "SPED"
		CONOUT('SLAManif Nota: '+SF1->F1_DOC+'-'+SF1->F1_SERIE )
		U_SLAMd103(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_EMISSAO,SF1->F1_VALBRUT,SF1->F1_TIPO,SF1->F1_CHVNFE,SF1->F1_DAUTNFE)
		CONOUT('SLAManif - Fim da Manifesta��o')
	EndIf

	Restarea(_aArea)
Return

//----------------------------------------------------------------------
/*/@param 
 	cNumNFe - Número da NF-e (SF1->F1_DOC)
	cSerie	 - Série da NF-e (SF1->SERIE)
	cClieFor - Codigo Cliente/Fornecedor (SF1->FORNECE)
	cLoja - Codigo Loja (SF1->F1_LOJA)
	dDtEmis - Data de Emissão da NF-e (SF1->F1_EMISSAO)			
	nValNFe - Valor total da NF-e (SF1->F1_VALBRUT)
	cTipoNFe - Tipo da NF-e (SF1->F1_TIPO)
	cChave	 - Chave da NF-e (SF1->F1_CHVNFE)
	cDtAut  - Data de autorização da NF-e (SF1->F1_DAUTNFE)
@Return Nil
/*/
//-----------------------------------------------------------------------
User Function SLAMd103(cNumNFe,cSerie,cClieFor,cLoja,dDtEmis,nValNFe,cTipoNFe,cChave,dDtAut)

Local aArea	:= GetArea()
Local aAreaSA1:= SA1->(GetArea())
Local aAreaSA2:= SA2->(GetArea())

Local cRazao	:= ""
Local cCNPJEM	:= ""
Local cIEemit	:= ""

Default cNumNFe	:= ""
Default cSerie	:= ""
Default cClieFor	:= ""
Default cLoja		:= ""
Default cTipoNFe	:= ""
Default cChave	:= ""

Default nValNFe	:= 0
Default dDtEmis	:= CtoD("  /  /    ")
Default dDtAut	:= CtoD("  /  /    ")

cSerie := substr(cChave,23,3)
cNumNfe:= substr(cChave,26,9)

// Validar se o emitente da NF-e a ser manifestada é o cliente ou fornecedor
If (!Empty(cClieFor) .and. !Empty(cLoja) .and. !Empty(cTipoNFe))
	If cTipoNFe $ "DB" 
		dbSelectArea("SA1")
		dbSetOrder(1)
		MsSeek(xFilial("SA1")+cClieFor+cLoja)
		cRazao  := Alltrim(SA1->A1_NOME)
		cCNPJEM := AllTrim(SA1->A1_CGC)
		cIEemit := Alltrim(SA1->A1_INSCR)
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)  				
		MsSeek(xFilial("SA2")+cClieFor+cLoja)
		cRazao  := Alltrim(SA2->A2_NOME)
		cCNPJEM := AllTrim(SA2->A2_CGC)
		cIEemit := Alltrim(SA2->A2_INSCR)
	EndIf
EndIf

If ReadyTSS()
	u_SlaManual(0,cChave,cSerie,cNumNFe,nValNFe,dDtEmis,dDtAut,cRazao,cCNPJEM,cIEemit)
Else
	CONOUT("TSS","O TSS está inativo."+CRLF+CRLF+"Para utilizar esta funcionalidade, inicialize o servidor TSS e execute as configurações do serviço através da rotina de Manifestação do Destinatário !!!!",{'OK'},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
	
RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaSA2)

Return


/*----------------------------------------------------------------------
@param
	nOpc    - 1=Inclusão/2=Alteração/3=Exclusão	
	cChave	 - Chave da NF-e
	cSerie	 - Série da NF-e
	cNumNFe - Número da NF-e
	nValNFe - Valor total da NF-e
	dDtEmis - Data de Emissão da NF-e
	cDtAut  - Data de autorização da NF-e
	cRazao  - Razao Social emitente da NF-e
	cCNPJEM - CNPJ Emitente da NF-e			
	cIEemit - IE do emitente da NF-e	
@Return	lRet
/*/
//-----------------------------------------------------------------------
User Function SlaManual(nOpc,cChave,cSerie,cNumNFe,nValNFe,dDtEmis,dDtAut,cRazao,cCNPJEM,cIEemit)
	
	Local aDados		:= {}
	Local aMata103	:= {}
	Local aDadosC00	:= {}
	
	Local cMsg		:= ""
	Local cRetorno	:= ""
	
	Local dData		:= CtoD("  /  /    ")
	Local lRet			:= .F.
	Local lOk			:= .F.
	Local lMata103	:= .T.//IIf(FunName()$"MATA103",.T.,.F.)
		
	Default cChave	:= ""
	Default cSerie	:= ""
	Default cNumNFe	:= ""
	Default nValNFe	:= 0
	Default dDtEmis		:= CtoD("  /  /    ")
	Default dDtAut		:= CtoD("  /  /    ")
	Default cRazao	:= ""
	Default cCNPJEM	:= ""
	Default cIEemit	:= ""	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define a mensagem de CONOUTa ao usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 1 .or. lMata103
		cMsg := "Confirma a inclusão"
		cMsg += IIF(lMata103," da manifestação manual?"+CRLF+CRLF+"Ao confirmar será transmitida a 'Ciência da Operação'.","?")
	ElseIf nOpc == 2
		cMsg := 'Confirma a alteração?'
	ElseIf nOpc == 3
		cMsg := 'Confirma a exclusão?'
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a operação³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValidFields(cChave,nValNFe,dDtEmis,dDtAut,nOpc,lMata103,@aDadosC00)
		dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
			CONOUT('Inicio manifestação, chave: '+cChave)
			//If MsgYesNo(cMsg)
				
				//Inclusao
				If nOpc == 1 .or. lMata103

					If Len(aDadosC00) == 0
						aAdd(aDados,{"C00_FILIAL"	,	cFilAnt	})
						aAdd(aDados,{"C00_CHVNFE"	,	cChave		})
						aAdd(aDados,{"C00_SERNFE"	,	cSerie		})
						aAdd(aDados,{"C00_NUMNFE"	,	cNumNFe	})
						aAdd(aDados,{"C00_VLDOC"		,	nValNFe	})
						aAdd(aDados,{"C00_DTEMI"		,	dDtEmis	})
						aAdd(aDados,{"C00_DTREC"		,	dDtAut		})
						aAdd(aDados,{"C00_NOEMIT"	,	Alltrim(cRazao)})
						aAdd(aDados,{"C00_CNPJEM"	,	cCNPJEM	})
						aAdd(aDados,{"C00_IEEMIT"	,	Alltrim(cIEemit)})
						aAdd(aDados,{"C00_STATUS"	,	'0'			})
						aAdd(aDados,{"C00_CODRET"	,	'999'		})
						aAdd(aDados,{"C00_DESRES"	,	'Documento incluido manualmente'})
						aAdd(aDados,{"C00_MESNFE"	,	Strzero(Month(dData),2)})
						aAdd(aDados,{"C00_ANONFE"	,	Strzero(Year(dData),4)})
						aAdd(aDados,{"C00_SITDOC"	,	'1'}) //"Uso autorizado da NFe"
						aAdd(aDados,{"C00_CODEVE"	,	'1'}) //"Envio de Evento não realizado"

						lRet:= RecInC00(.T.,aDados)
					Else
						/*lMata103 - Alimenta variáveis com os dados já existentes na C00 para
						que o xml do evento de ciencia seja montado corretamente*/
						cChave		:= aDadosC00[1]
						cSerie		:= aDadosC00[2]
						cNumNFe	:= aDadosC00[3]
						nValNFe	:= aDadosC00[4]
						cCNPJEM	:= aDadosC00[5]
						cRazao		:= aDadosC00[6]
						cIEemit	:= aDadosC00[7]
						dDtEmis	:= aDadosC00[8]
						dDtAut		:= aDadosC00[9]
						
						lRet := .T.
					EndIf

					If lRet .and. lMata103
						aadd(aMata103,{,cChave,cSerie,cNumNFe,nValNFe,cCNPJEM,Alltrim(cRazao),Alltrim(cIEemit),dDtEmis,dDtAut,.T.,'0','1'})
						lOk:= MontaXmlManif("210210",aMata103,@cRetorno,"") 
					EndIf									
					
					If lOk // Transmissão da Ciencia da Operação Concluída - lMata103
						CONOUT("Envio Manifesto",cRetorno,{"OK"},3)
					EndIF
					
			    //Alteracao
				ElseIf nOpc == 2
					aAdd(aDados,{"C00_FILIAL"	,	cFilAnt	})
					aAdd(aDados,{"C00_CHVNFE"	,	cChave		})
					aAdd(aDados,{"C00_SERNFE"	,	cSerie		})
					aAdd(aDados,{"C00_NUMNFE"	,	cNumNFe	})
					aAdd(aDados,{"C00_VLDOC"		,	nValNFe	})
					aAdd(aDados,{"C00_DTEMI"		,	dDtEmis	})
					aAdd(aDados,{"C00_DTREC"		,	dDtAut		})
					aAdd(aDados,{"C00_NOEMIT"	,	cRazao		})
					aAdd(aDados,{"C00_CNPJEM"	,	cCNPJEM	})
					aAdd(aDados,{"C00_IEEMIT"	,	cIEemit	})
					aAdd(aDados,{"C00_STATUS"	,	'0'			})
					aAdd(aDados,{"C00_CODRET"	,	'999'		})
					aAdd(aDados,{"C00_DESRES"	,	'Documento incluido manualmente'})
					aAdd(aDados,{"C00_MESNFE"	,	Strzero(Month(dData),2)})
					aAdd(aDados,{"C00_ANONFE"	,	Strzero(Year(dData),4)})
					aAdd(aDados,{"C00_SITDOC"	,	'1'	}) //"Uso autorizado da NFe"
					aAdd(aDados,{"C00_CODEVE"	,	'1'}) //"Envio de Evento não realizado"
                 
					lRet := RecInC00(.F.,aDados)

				//Exclusao
				ElseIf nOpc == 3
					//Apaga da C00
					RecLock('C00',.F.)
					C00->(dbDelete())
					C00->(msUnlock())
					lRet := .T.
				EndIf
			//Else
			//	lRet := .F.
			//EndIf
	EndIf		

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} RecInC00 
    Inclui/Altera registro de manifesto na C00/*/
//-----------------------------------------------------------------------
Static Function RecInC00(lInclui,aDados)
	Local nI		:= 1
	Local lRet		:= .F.
	Default aDados	:= {}
	
	If len(aDados) > 0
		
		//Grava na Tabela
		BeginTran()
			RecLock("C00",lInclui)
			For nI := 1 to len(aDados)				
				C00->(FieldPut(FieldPos(aDados[nI][1]),aDados[nI][2]))
			Next nI
			C00->(msUnlock())
			lRet := .T.
		EndTran()
	Else
		lRet := .F.
	EndIf
	
Return lRet


/*
@param 	cCbCpo     - Evento Selecionado no listbox
		aMontXml   - Dados da nota que deve ser transmitida
		cRetorno   - Chaves de acesso das notas transmitidas
		cJustific  - Justificativa da Operação não realizada

@Return lRetOk	   - Se a transmissão foi concluída ou não		
*/
Static Function MontaXmlManif(cCbCpo,aMontXml,cRetorno,cJustific) 

Local aRet			:={}
Local lUsaColab	:= .F.//UsaColaboracao("4")

Local cAmbiente	:= "" 
Local cXml			:= ""
Local cTpEvento	:= SubStr(cCbCpo,1,6)
Local cIdEnt		:= RetIdEnti(lUsaColab)
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cChavesMsg	:= ""
Local cMsgManif	:= ""
Local cIdEven		:= ""
Local cErro		:= ""
Local cRetPE		:= ""

Local aNfe			:= {}

Local lRetOk		:= .T. 
Local lManiEven	:= ExistBlock("MANIEVEN")
Local lMata103	:= .T.//IIf(FunName()$"MATA103",.T.,.F.)

Local nX 			:= 0
Local nZ 			:= 0

Private oWs			:= Nil

Default cJustific 	:= ""

If ReadyTSS()
	If lUsaColab	
		cAmbiente := ColGetPar("MV_AMBIENT")
		lRetOk := .F.
		
		For nX:=1 To Len(aMontXml)
			aNfe := {}
			aNfe := {aMontXml[nX][2],"","",""}
			cIdEven := ""
			cXML	 := ""
			cXml := SpedCCeXml(aNfe,cJustific,cTpEvento)		
			//Adiciona a CHAVE da nota para solicitar o envio.
			
			If ColEnvEvento("MDE",aNfe,cXml,@cIdEven,@cErro)
				lRetOk := .T.
				aadd(aRet,cIdEven)
			else
				CONOUT("MD-e TOTVS Colaboração 2.0",cErro,{'OK'},3)	
			EndIf
		Next
	else
		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := cIdEnt
		oWs:cAMBIENTE	 := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
		
		If oWs:CONFIGURARPARAMETROS()
			cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
			
			cXml+='<envEvento>'
			cXml+='<eventos>'
			
			For nX:=1 To Len(aMontXml)
				cXml+='<detEvento>'
				If lManiEven
					cRetPE := ExecBlock("MANIEVEN",.F.,.F.,{cTpEvento,aMontXml[nX][2]})
					If cRetPE <> Nil .And. !Empty(cRetPE)
						cTpEvento := cRetPE
					EndIf
				EndIf	
				cXml+='<tpEvento>'+cTpEvento+'</tpEvento>'
				cXml+='<chNFe>'+Alltrim(aMontXml[nX][2])+'</chNFe>'
				cXml+='<ambiente>'+cAmbiente+'</ambiente>'
				If '210240' $ cTpEvento .and. !Empty(cJustific)
					cXml+='<xJust>'+Alltrim(cJustific)+'</xJust>'
				EndIf		
				cXml+='</detEvento>'
			Next
			cXml+='</eventos>'
			cXml+='</envEvento>'
			
			lRetOk:= EnvioManif(cXml,cIdEnt,cUrl,@aRet)
		
		Else                                                                               
			CONOUT("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		endif	
	endif

	If lRetOk .And. Len(aRet) > 0
		For nZ:=1 to Len(aRet)
		    aRet[nZ]:= Substr(aRet[nZ],9,44)
		    cChavesMsg += aRet[nZ] + Chr(10) + Chr(13)	    	    
		Next
		cMsgManif := "Transmissão da Manifestação concluída com sucesso!"+ Chr(10) + Chr(13)//"Transmissão da Manifestação concluída com sucesso!"
		cMsgManif += cCbCpo + Chr(10) + Chr(13)
		cMsgManif += "Chave(s): "+ Chr(10) + Chr(13)
		cMsgManif += cChavesMsg
		IF lMata103
			cMsgManif += Chr(10) + Chr(13)+ "Consulte a rotina de Manifestação do Destinatário para verificar o resultado!"
		EndIf
		cRetorno := Alltrim(cMsgManif)
		
	EndIf
		
	AtuStatus(aRet,cTpEvento)			
	
Else
	CONOUT("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{'OK'},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
		
Return lRetOk 

//-----------------------------------------------------------------------
/*/{Protheus.doc} EnvioManif()
Envia o xml para transmissão da manifestação
@param 	cXmlReceb  - String com o XML a ser transmitido
		cIdEnt	   - Codigo da Entidade
		cUrl	   - URL
		aRetorno   - Retorno do RemessaEvento

@Return lRetOk	   - Se a transmissão foi concluída ou não		
/*/
//-----------------------------------------------------------------------    
Static Function RetEnvManif(cXmlReceb,cIdEnt,cUrl,aRetorno,cModel)
Return EnvioManif(cXmlReceb,cIdEnt,cUrl,aRetorno,cModel)

Static Function EnvioManif(cXmlReceb,cIdEnt,cUrl,aRetorno,cModel)

Local lRetOk		:= .T.

Default cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Default cIdEnt		:= RetIdEnti(lUsaColab)
Default aRetorno	:= {}
Default cModel		:= ""

If ReadyTSS()
	// Chamada do metodo e envio
	oWs:= WsNFeSBra():New()
	oWs:cUserToken	:= "TOTVS"
	oWs:cID_ENT		:= cIdEnt
	oWs:cXML_LOTE	:= cXmlReceb
	oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
	If !Empty(cModel)
		oWS:cModelo := cModel
	EndIf
	//oWs:RemessaEvento()
	
	If oWs:RemessaEvento()
		If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
			If Type("oWS:oWsRemessaEventoResult:cString") <> "A"
				aRetorno:={oWS:oWsRemessaEventoResult:cString}
			Else
				aRetorno:=oWS:oWsRemessaEventoResult:cString
			EndIf
		EndIf
	Else
		lRetOk := .F.	
		CONOUT("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	Endif
Else
	CONOUT("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{'OK'},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return lRetOk


//----------------------------------------------------------------------
/*/{Protheus.doc} ValidFields Valida campos da dialog de MD-e Manual e verifica se já existe chave na C00 */
//-----------------------------------------------------------------------
Static Function ValidFields(cChave,nValNFe,dDtEmis,dDtAut,nOpc,lMata103,aDadosC00)

Local aArea	:= GetArea()
Local lReturn := .T.
Local cMesEmis := ""
Local cAnoEmis := ""
Local dData	:= CtoD("  /  /    ")
Local cNewChave := ""

Default aDadosC00:= {}

If !lMata103
	If nOpc <> 3
		If 	len(Alltrim(cChave)) == 44
			cNewChave:= validcDVNFe(Substr(cChave,1,43))
		EndIf
		Do Case
			Case len(Alltrim(cChave)) < 44
				CONOUT("Chave informada deve ter 44 dígitos.")
				lReturn := .F.
			Case len(Alltrim(cChave)) == 44 .and. Substr(cChave,21,2) <> '55'
				CONOUT("Chave informada não se refere a uma NF-e (modelo 55).")
				lReturn := .F.
			Case len(Alltrim(cChave)) == 44 .and. cChave <> cNewChave
				CONOUT("Dígito verificador que compõe a chave de acesso está incorreto.")
				lReturn := .F.
			Case Empty(dDtEmis)
				CONOUT("Data de emissão da NF-e não informada.")
				lReturn := .F.
			Case (!Empty(dDtAut) .and. dDtAut < dDtEmis)
				CONOUT("Data de autorização da NF-e não pode ser menor que a data de emissão da NF-e.")
				lReturn := .F.
			Case !Empty(dDtEmis)
				dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
				cMesEmis := Strzero(Month(dData),2)
				cAnoEmis := Strzero(Year(dData),4)
		
				If (Substr(DtoC(dDtEmis),4,2) <> cMesEmis) .or. (Substr(DtoC(dDtEmis),7,4) <> cAnoEmis) .and. (Substr(DtoC(dDtEmis),7,4) <> Substr(cAnoEmis,3,2))
					CONOUT("Mês e/ou Ano informado no campo 'Data emissão' não confere com o Mês e/ou Ano informado no campo 'Chave'")
					lReturn := .F.
				EndIf
		EndCase
	EndIf
EndIf

If lReturn
	C00->(DbsetOrder(1))
	If C00->( DbSeek( xFilial("C00") + cChave) )
		If nOpc == 1 .or. lMata103
			If lMata103
				If C00->C00_STATUS <> '0'
					CONOUT('Já existe Manifestação para este documento!!'+CRLF+CRLF+'Consulte a rotina de Manifestação do Destinatário.')
					lReturn := .F.
				Else
					//Se já existir registro na C00 sem manifestação monta array com dados da C00 e não executa a função RecInC00
					aadd(aDadosC00,C00->C00_CHVNFE)
					aadd(aDadosC00,C00->C00_SERNFE)
					aadd(aDadosC00,C00->C00_NUMNFE)
					aadd(aDadosC00,C00->C00_VLDOC)
					aadd(aDadosC00,C00->C00_CNPJEM)
					aadd(aDadosC00,C00->C00_NOEMIT)
					aadd(aDadosC00,C00->C00_IEEMIT)
					aadd(aDadosC00,C00->C00_DTEMI)
					aadd(aDadosC00,C00->C00_DTREC)
				EndIf
			Else
				CONOUT('Já existe MD-e cadastrado com a mesma chave!')
				lReturn := .F.
			EndIf
		EndIf
	Else
		If !lMata103
			If nOpc <> 1
				lReturn := .F.
			EndIf
		EndIf
	EndIf		
EndIf

RestArea(aArea)
Return lReturn

//Verifica status do TSS
Static Function ReadyTSS(cURL,nTipo,lHelp,lUsaColab)
Return (CTIsReady(cURL,nTipo,lHelp,lUsaColab))


/*/{Protheus.doc} AtuStatus()
Atualiza o Status da Manifestação de acordo com o Tipo de Evento

@param 	aRet   	   - Chaves de acesso das notas transmitidas
		cTpEvento  - Tipo do Evento em que a nota foi transmitida
	
/*/
//----------------------------------------------------------------------- 
Static Function AtuStatus(aRet,cTpEvento)

Local aAreas	:= {}

Local cStat		:= "0"
Local nX		:= 0

If cTpEvento $ '210200'
	cStat:= "1"  //Confirmada operação
ElseIf cTpEvento $ '210220'
	cStat:= "2"  //Desconhecimento da Operação
ElseIf cTpEvento $ '210240' 
	cStat:= "3"  //Operação não Realizada		 
ElseIf cTpEvento $ '210210' 
	cStat:= "4"  //Ciência da operação
EndIf

If Len(aRet) > 0
	aAreas := GetArea()
	For nX:=1 to Len(aRet)
		C00->(DbSetOrder(1))
		If C00->(DBSEEK(xFilial("C00")+aRet[nX]))
			RecLock("C00")
			C00->C00_STATUS := cStat
			C00->C00_CODEVE := "2"
			MsUnlock()
		EndIf
	Next
	RestArea(aAreas)	
EndIf	

Return 