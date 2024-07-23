#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} CN120ENCMD->CN121ENC()
P.E. Padrão CNTA120 -> CNTA121
Funcao criada para realizar a inclusao de notas de saida para as medicoes, inclusao do contas a pagar caso o 
cliente do contrato seja uma empresa do grupo e envio de e-mails de notificacoes
@author SLA Consultoria
@since 21/03/2018
@version 1.0
@return Nil.
@type function
/*/
//User Function CN120ENCMD()
User Function CN121ENC()

	Local _cPlnLocV	:= SuperGetMv("MV_XPLNLOC",.F.,"004")
	Local _cPlnLocC	:= SuperGetMv("MV_XPLNVLC",.F.,"005")
	Local _cMailGCT	:= SuperGetMv("MV_XMAIL69",.F.,"sistemas@agricopel.com.br")
	Local _cMailTI	:= SuperGetMv("MV_XERRO69",.F.,"sistemas@agricopel.com.br")//"carlos.s@agricopel.com.br"
	Local _lGerSf2	:= SuperGetMv("MV_XGCGSF2",.F.,.F.)
	Local _cCnpjCli := ""
	Local _cDoc		:= ""
	Local cError	:= ""
	Local _cSerie	:= "1  "
	Local aParamHtm	:= {}
	Local aParamDet	:= {}
	Local _lAchou	:= .F.
	Local aDadosTit	:= {}
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local _nX
	Local _nY
	Private _lEncmd := PARAMIXB[1]
	Private lMsErroAuto := .F.
	Private	cMensg		:= ""
	Private cHtml		:= ""
	Private	lAutoErrNoFile	:= .T.
	

	// Verificacoes gerais
	IF _lEncmd
		If _cPlnLocV == CN9->CN9_TPCTO

			// Gera email de alerta
			xGeraMail("MEDICAO DE CONTRATO (CNTA121)",_cMailGCT,CN9->CN9_NUMERO,CND->CND_NUMMED,"a RECEBER (SE1)","Cliente: ",CNA->CNA_CLIENT," / Loja: ",CNA->CNA_LOJACL,Posicione("SA1",1,xFilial("SA1")+CNA->CNA_CLIENT+CNA->CNA_LOJACL,"A1_NOME"),CXJ->CXJ_NUMTIT,CND->CND_PARCEL,CND->CND_VLTOT,CNF->CNF_DTVENC,CN9->CN9_XTPPAG,CN9->CN9_XMSGPG)
			u_xHtmlPad("Medicao de Contrato Realizada",cMensg)
			u_envMailA(_cMailGCT,"GCT - Medicao de Contrato Realizada (CNTA121)",cHtml,2/*,_cMailTI,"carlos.s@agricopel.com.br"*/)

			// Busca CNPJ do cliente do contrato 
			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1")+CNA->CNA_CLIENT+CNA->CNA_LOJACL)
				_cCnpjCli := SA1->A1_CGC
			EndIf

			// Verifica qual o cnpj da filial atual no sigamat
			For _nX:=1 to Len(FWLoadSM0())
				If FWLoadSM0()[_nX][01] == cEmpAnt .and. FWLoadSM0()[_nX][02] == cFilAnt
					aAdd(aDadosTit,FWLoadSM0()[_nX][18]) // CNPJ Empresa Origem
				EndIf
			Next _nX

			// Verifica se existe o cliente como filial do grupo pelo CNPJ
			For _nY:=1 to Len(FWLoadSM0())
				If FWLoadSM0()[_nY][18] == _cCnpjCli
					_lAchou	 := .T.
					aAdd(aDadosTit,FWLoadSM0()[_nY][01]) // Codigo Empresa Destino
					aAdd(aDadosTit,FWLoadSM0()[_nY][02]) // Codigo Filial Destino
				EndIf
			Next _nY

			// Se localizou o cliente como empresa do grupo executa
			If _lAchou .and. !Empty(CXJ->CXJ_NUMTIT) 

				// Adiciona no array demais campos necessarios
				aAdd(aDadosTit,Substr(CND->CND_CONTRA,1,3)+Substr(CND->CND_CONTRA,10,6)) // Numero contrato
				aAdd(aDadosTit,CND->CND_PARCEL)  // Parcela 
				aAdd(aDadosTit,CND->CND_DTINIC)  // Data emissao
				aAdd(aDadosTit,CNF->CNF_DTVENC)  // Data vencimento
				aAdd(aDadosTit,CND->CND_VLTOT)   // Valor titulo
				aAdd(aDadosTit,CND->CND_CONTRA)  // Numero Contrato
				aAdd(aDadosTit,CND->CND_NUMMED)  // Numero Medição
				aAdd(aDadosTit,CN9->CN9_XTPPAG)  // Tipo Pagamento/Recebimento
				aAdd(aDadosTit,CN9->CN9_XMSGPG)  // Historico Titulo
				aAdd(aDadosTit,Alltrim(CN9->CN9_XCCFIN))  // Centro de Custo
				aAdd(aDadosTit,CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED) // Chave de Busca

				// Chama rotina para criar titulo no destino
				lReturn := StartJob("U_GERTITDS",GetEnvServer(),.T.,aDadosTit,_cMailGCT)

				// Aguarda 5 segundos
				sleep(5000)

			EndIf

			If _lGerSf2

				// Gera NF Manual de Saída
				// Melhoria realizada em 02/11 conforme email trocado com Thiago Padilha
				//_cDoc 	:= CND->CND_NUMTIT
				_cDoc 	:= CXJ->CXJ_NUMTIT
				_cSerie	:= CND->CND_FILCTR
				

				// Cabecalho
				aadd(aCabec,{"F2_TIPO"   ,"N"})
				aadd(aCabec,{"F2_FORMUL" ,"S"})
				aadd(aCabec,{"F2_DOC"    ,_cDoc})
				aadd(aCabec,{"F2_SERIE"  ,_cSerie})
				aadd(aCabec,{"F2_EMISSAO",dDataBase})
				//aadd(aCabec,{"F2_CLIENTE",CND->CND_CLIENT}) - CARLOS 16/05
				aadd(aCabec,{"F2_CLIENTE",CNA->CNA_CLIENT})
				//aadd(aCabec,{"F2_LOJA"   ,CND->CND_LOJACL})  - CARLOS 16/05
				aadd(aCabec,{"F2_LOJA"   ,CNA->CNA_LOJACL})
				aadd(aCabec,{"F2_ESPECIE","RPS"})
				aadd(aCabec,{"F2_COND"	 ,""})
				aadd(aCabec,{"F2_DESCONT",0})
				aadd(aCabec,{"F2_FRETE"	 ,0})
				aadd(aCabec,{"F2_SEGURO" ,0})
				aadd(aCabec,{"F2_DESPESA",0})
				aadd(aCabec,{"F2_CHVNFE",CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED})
				// Itens
				aadd(aLinha,{"D2_COD"	 ,"000000000000001"	,Nil})
				aadd(aLinha,{"D2_ITEM"	 ,"01"				,Nil})
				aadd(aLinha,{"D2_QUANT"	 ,1					,Nil})
				aadd(aLinha,{"D2_PRCVEN" ,CND->CND_VLTOT	,Nil})
				aadd(aLinha,{"D2_TOTAL"	 ,CND->CND_VLTOT	,Nil})
				aadd(aLinha,{"D2_TES"	 ,"531"				,Nil})
				aadd(aItens,aLinha)

				MSExecAuto ({|x,y| MATA920(aCabec,aItens)}, aCabec, aItens, 3)	

				If !lMsErroAuto		
					ConOut("NF Incluido com sucesso! "+_cDoc)
					// Comentado dia 20/02/2019 conforme chamado 19633
					/*
					// atualiza campo D2_ORIGLAN
					DbSelectArea("SD2")
					DbSetOrder(3)
					If DbSeek(xFilial("SD2")+_cDoc+Space(TamSX3("D2_DOC")[1]-len(_cDoc))+_cSerie+Space(TamSX3("D2_SERIE")[1]-len(_cSerie))+CND->CND_CLIENT+CND->CND_LOJACL+"000000000000001")
						RecLock("SD2",.F.)
						SD2->D2_ORIGLAN := "LF"
						MsUnlock("SD2")
					EndIf
					*/		
				Else
					AEVal(GetAutoGRLog(),{|x| cError += x + "<br>"})
					u_xHtmlPad("Erro ao gerar NF Saida Manual",cError)
					u_envMailA(_cMailTI,"GCT - Erro ao gerar NF Saida Manual (MATA920)",cHtml,2/*,"","carlos.s@agricopel.com.br"*/)
				EndIf

			EndIf

		ElseIf _cPlnLocC == CN9->CN9_TPCTO

			// Gera email de alerta
			xGeraMail("MEDICAO DE CONTRATO (CNTA121)",_cMailGCT,CN9->CN9_NUMERO,CND->CND_NUMMED,"a PAGAR (SE2)","Fornecedor: ",CNA->CNA_FORNEC," / Loja: ",CNA->CNA_LJFORN,Posicione("SA2",1,xFilial("SA2")+CNA->CNA_FORNEC+CNA->CNA_LJFORN,"A2_NOME"),CXJ->CXJ_NUMTIT,CND->CND_PARCEL,CND->CND_VLTOT,CNF->CNF_DTVENC,CN9->CN9_XTPPAG,CN9->CN9_XMSGPG)
			u_xHtmlPad("Medicao de Contrato Realizada",cMensg)
			u_envMailA(_cMailGCT,"GCT - Medicao de Contrato Realizada (CNTA121)",cHtml,2/*,_cMailTI,"carlos.s@agricopel.com.br"*/)

		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} GERTITDS
Funçao para execauto na empresa destino do titulo a pagar
@author SLA Consultoria
@since 21/03/2018
@version 1.0
@return Nil.
@type function
/*/
User Function GERTITDS(aDadosTit,_cMailGCT)

	Local 	_cNatzPg	:= ""
	Local	_cCodFor	:= ""
	Local	_cLojFor	:= ""
	Local	cError		:= ""
	Local	aArray		:= {}
	Local 	aParamHtm	:= {}
	Local 	aParamDet	:= {}
	Local	cParcela	:= ""
	Local 	_cMailTI	:= SuperGetMv("MV_XERRO69",.F.,"sistemas@agricopel.com.br")//"leandro.h@agricopel.com.br"
	Private cHtml		:= ""
	Private cMensg		:= ""	
	Private lMsErroAuto := .F.
	Private	lAutoErrNoFile	:= .T.

	// Prepara o ambiente na empresa e filial para realizar a cópia.
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv(aDadosTit[02],aDadosTit[03])
	
	// Busca a natureza na empresa destino
	_cNatzPg := SuperGetMv("MV_XNATPGL",.F.,"211002")

	// Busca dados do Fornecedor 
	dbSelectArea("SA2")
	dbSetOrder(3)
	If dbSeek(xFilial("SA2")+aDadosTit[01])
		_cCodFor := SA2->A2_COD
		_cLojFor := SA2->A2_LOJA
	EndIf
	
	If aDadosTit[02] == "01"
		_cTipoE2 := "DP"
	Else
		_cTipoE2 := "BOL"
	EndIf
	
	// Verifica campo parcela
	If TamSX3("E2_PARCELA")[1] == 3
		cParcela := aDadosTit[05]
	Else
		cParcela := cValtoChar(Val(aDadosTit[05]))
	EndIf
	
	// Array com os dados SE2
	aArray := { { "E2_PREFIXO"  , aDadosTit[03]		, NIL },;
				{ "E2_NUM"		, aDadosTit[04]		, NIL },;
				{ "E2_PARCELA"	, cParcela			, NIL },;
				{ "E2_TIPO"		, _cTipoE2			, NIL },;
				{ "E2_NATUREZ"	, _cNatzPg			, NIL },;
				{ "E2_FORNECE"	, _cCodFor			, NIL },;
				{ "E2_LOJA"		, _cLojFor			, NIL },;
				{ "E2_HIST"		, aDadosTit[12]		, NIL },;
				{ "E2_CCUSTO"	, aDadosTit[13]		, NIL },;
				{ "E2_EMISSAO"	, aDadosTit[06]		, NIL },;
				{ "E2_VENCTO"	, aDadosTit[07]		, NIL },;
				{ "E2_VENCREA"	, aDadosTit[07]		, NIL },;
				{ "E2_VALOR"	, aDadosTit[08]		, NIL },;
				{ "E2_NOMERET"	, CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED	, NIL } }

	// Verifica se encontrou fornecedor
	If !Empty(_cCodFor) .and. !Empty(_cLojFor)

		// Executa rotina de inclusão de contas a pagar
		dDatabase := aDadosTit[06]
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)

		// Verifica se deu erro
		If lMsErroAuto
			AEVal(GetAutoGRLog(),{|x| cError += x + "<br>"})
			u_xHtmlPad("Erro ao gerar Contas a Pagar",cError)
			u_envMailA(_cMailTI,"GCT - Erro ao gerar Contas a Pagar (GERTITDS)",cHtml,2/*,"","carlos.s@agricopel.com.br"*/)
		Else
			xGeraMail("MEDICAO DE CONTRATO (CNTA121)",_cMailGCT,aDadosTit[09],aDadosTit[10],"a PAGAR (SE2)","Fornecedor: ",_cCodFor," / Loja: ",_cLojFor,Posicione("SA2",1,xFilial("SA2")+_cCodFor+_cLojFor,"A2_NOME"),aDadosTit[04],aDadosTit[05],aDadosTit[08],aDadosTit[07],aDadosTit[11],aDadosTit[12])
			u_xHtmlPad("Medicao de Contrato Realizada",cMensg)
			u_envMailA(_cMailGCT,"GCT - Medicao de Contrato Realizada (CNTA121)",cHtml,2/*,_cMailTI,"carlos.s@agricopel.com.br"*/)
		Endif

	EndIf

Return !lMsErroAuto

// Gera corpo do email
Static Function xGeraMail(cRotina,cTo,cNumCon,cNumMed,cTipTit,cCliFor,cCodCF,cLoja,cLjCF,cNome,cNumTit,cNumPrc,nValor,dDtVenc,cTpPag,cHist)

	Local 	cTitulo 	:= ""
	Default cTo			:= ""

	If !Empty(cTo)
		cTitulo := OemToAnsi(cRotina + " - DATA: " + DToC(Date()))
		// Monta uma breve mensagem para ser colocada no e-mail.
		cMensg :=  "EMPRESA/FILIAL: " + cEmpAnt + "-" + cFilAnt + " | CONTRATO: " + cNumCon + " / MEDICAO: " + cNumMed;
					+ "<br><br>Medição realizada e gerado titulo financeiro " + cTipTit;
					+ "<br>";
					+ cCliFor + cCodCF + cLoja + cLjCF + " - " + cNome;
					+ "<br>";
					+ "Titulo/Parcela: " + cNumTit + "-" + cNumPrc;
					+ "<br>";
					+ "Valor: " + TRANSFORM(nValor,PesqPict("SE2","E2_VALOR"));
					+ "<br>";
					+ "Vencimento: " + DtoC(dDtVenc);
					+ "<br>";
					+ "Historico: " + Iif(cTpPag=="1","Boleto","Deposito") + ". " + cHist;
					+ "<br>";
					+ "<br>E-mail gerado automaticamente, nao responder.";
					+ "<br>Enviado para: " + cTo
	EndIf

Return
/*
// Envia email
Static Function xNewMail(cTo,cTitle,cMensagem,cPathHTML,aParHTML,aAnexos,cCC,cCCo)

	Local cHtmTemp		:= "wftemp"
	Local cMsg			:= ""
	Local cFrom			:= ""
	Local nX			:= 0
	Local nY			:= 0
	Local oMail   		:= Nil
	Local oMessage		:= Nil
	Local oHtml			:= Nil
	Local oServer		:= Nil
	Default cMensagem	:= ""
	Default cTo			:= ""
	Default cTitle		:= ""
	Default cPathHTML	:= ""
	Default aParHTML	:= {}
	Default aAnexos		:= {}
	Default cCC			:= ""
	Default cCCo		:= ""

	DBSelectArea("WF7")
	WF7->(DBSetOrder(1))

	lSSL := .F.
	lTLS := .F.
	cSMTP := AllTrim(WF7->WF7_SMTPSR)  
	cUser := AllTrim(WF7->WF7_CONTA)
	cPass := AllTrim(WF7->WF7_SENHA)
	nPort := WF7->WF7_SMTPPR
	cUserAut := AllTrim(WF7_AUTUSU)
	cPassAut := AllTrim(WF7_AUTSEN)

	// 	Conecta com o Sexvidor SMTP.
	oServer := TMailManager():New()
	oServer:SetUseSSL(lSSL)
	oServer:SetUseTLS(lTLS)
	nError := oServer:Init("", cSMTP, cUser, cPass, 0, nPort)
	If nError == 0
		oServer:SetSmtpTimeOut(60)
		nError := oServer:SMTPConnect()
		If nError == 0
			oServer:SMTPAuth(cUserAut, cPassAut)
			If nError == 0
				// 				Usado para ocultar o endereço original do remetente.
				cFrom := "nao_responda@agricopel.com.br"
				oMessage := TMailMessage():New()
				oMessage:Clear()
				oMessage:cFrom := cFrom
				oMessage:cTo := cTo
				oMessage:cCc := cCC
				oMessage:cBcc := cCCo
				oMessage:cSubject := cTitle
				// 				Adiciona no corpo da mensagem os arquivos em anexo.
				For nX := 1 To Len(aAnexos)
					If oMessage:AttachFile(aAnexos[nX]) < 0
						ConOut("Nao foi possivel anexar/encontrar o seguinte arquivo " + aAnexos[nX])
					EndIf
				Next nX
				If !Empty(cPathHTML)
					// Cria o objeto HTML e popula de acordo com os parametros.
					oHTML := TWFHTML():New(cPathHTML)
					For nX := 1 To Len(aParHTML)
						If	ValType(aParHTML[nX][1]) <> "A"
							oHTML:ValByName(aParHTML[nX][1],aParHTML[nX][2])
						Else
							For nY := 1 To Len(aParHTML[nX][1])
								aAdd(oHTML:ValByName(aParHTML[nX][1][nY][1]),aParHTML[nX][1][nY][2])
							Next nY
						EndIf
					Next nX
					oHTML:SaveFile(cHtmTemp)
					// Verifica a mensagem do HTML para colocar no corpo do e-mail
					cMsg := WFLoadFile(cHtmTemp + ".htm")
					cMsg := StrTran(cMsg, CHR(13), "")
					cMsg := StrTran(cMsg, CHR(10), "")
				EndIf
				// 				Troca o corpo do e-mail (mensagem) e faz o envio (disparo)
				oMessage:cBody := cMensagem + cMsg
				nError := oMessage:Send(oServer)
			EndIf
		EndIf
	EndIf

	//	Verifica se ocorreu erro.
	If nError == 0
		lRetorno := .T.
		ConOut(ProcName() + " [" + DToC(Date()) + " " + Time() + "] " + "E-mail enviado com sucesso para " + cTo)
	Else
		lRetorno := .F.
		ConOut(ProcName() + " [" + DToC(Date()) + " " + Time() + "] " + oServer:GetErrorString(nError))
	EndIf
	oServer:SMTPDisconnect()
	//	Apaga arquivo .htm gerado temporariamente.
	FErase(cHtmTemp)
	WF7->(DBCloseArea())

Return lRetorno
*/
