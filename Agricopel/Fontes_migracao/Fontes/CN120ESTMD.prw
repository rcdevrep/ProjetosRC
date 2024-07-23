#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} CN120ESTMD
P.E. Padrão CNTA120
Funcao criada para realizar informar sobre estorno de medicao
@author SLA Consultoria
@since 21/03/2018
@version 1.0
@return Nil.
@type function
/*/
User Function CN120ESTMD()

	Local _cPlnLocV	:= SuperGetMv("MV_XPLNLOC",.F.,"004")
	Local _cPlnLocC	:= SuperGetMv("MV_XPLNVLC",.F.,"005")
	Local _cMailGCT	:= SuperGetMv("MV_XMAIL69",.F.,"thiago.padilha@agricopel.com.br")
	Local _cMailTI	:= "thiago.padilha@agricopel.com.br"
	Local _lGerSf2	:= SuperGetMv("MV_XGCGSF2",.F.,.F.)
	Local _cCnpjCli := ""
	Local _cDoc		:= ""
	Local cError	:= ""
	Local _lAchou	:= .F.
	Local aDadosTit	:= {}
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local cQryAux	:= ""
	Local _nX
	Local _nY
	Private lMsErroAuto := .F.
	Private	lAutoErrNoFile	:= .T.
	Private	cMensg		:= ""
	Private cHtml		:= ""

	// Verificacoes gerais
	If _cPlnLocV == CN9->CN9_TPCTO

		// Gera email de alerta
		xGeraMail("ESTORNO MEDICAO DE CONTRATO (CNTA120)",_cMailGCT,CN9->CN9_NUMERO,CND->CND_NUMMED,"a RECEBER (SE1)","Cliente: ",CND->CND_CLIENT," / Loja: ",CND->CND_LOJACL,Posicione("SA1",1,xFilial("SA1")+CND->CND_CLIENT+CND->CND_LOJACL,"A1_NOME"),CND->CND_NUMTIT,CND->CND_PARCEL,CND->CND_VLTOT,CND->CND_DTVENC,CN9->CN9_XTPPAG,CN9->CN9_XMSGPG)
		u_xHtmlPad("Medicao de Contrato Estornada",cMensg)
		u_envMailA(_cMailGCT,"GCT - Medicao de Contrato Estornada (CNTA120)",cHtml,2,_cMailTI,"jackson@sla.inf.br")

		// Busca CNPJ do cliente do contrato 
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+CND->CND_CLIENT+CND->CND_LOJACL)
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
		If _lAchou 

			// Adiciona no array demais campos necessarios
			aAdd(aDadosTit,Substr(CND->CND_CONTRA,1,3)+Substr(CND->CND_CONTRA,10,6)) // Numero contrato
			aAdd(aDadosTit,CND->CND_PARCEL)  // Parcela 
			aAdd(aDadosTit,CND->CND_DTINIC)  // Data emissao
			aAdd(aDadosTit,CND->CND_DTVENC)  // Data vencimento
			aAdd(aDadosTit,CND->CND_VLTOT)   // Valor titulo
			aAdd(aDadosTit,CND->CND_CONTRA)  // Numero Contrato
			aAdd(aDadosTit,CND->CND_NUMMED)  // Numero Medição
			aAdd(aDadosTit,CN9->CN9_XTPPAG)  // Tipo Pagamento/Recebimento
			aAdd(aDadosTit,CN9->CN9_XMSGPG)  // Historico Titulo
			aAdd(aDadosTit,Alltrim(CN9->CN9_XCCFIN))  // Centro de Custo
			aAdd(aDadosTit,CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED) // Chave de Busca

			// Chama rotina para criar titulo no destino
			lReturn := StartJob("U_ESTTITOR",GetEnvServer(),.T.,aDadosTit)
			//sleep(5000)

		EndIf

		If _lGerSf2

			// Busca se existe NF Gerada
			cQryAux	:= " "
			cQryAux	+= " SELECT F2_TIPO, F2_FORMUL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_ESPECIE, F2_COND, F2_DESCONT, F2_FRETE, F2_SEGURO, F2_DESPESA, F2_RECISS, "
			cQryAux	+= "        D2_ITEM, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_TES, D2_ALQIMP1, D2_ALQIMP2, D2_ALQIMP3, D2_ALQIMP4, D2_ALQIMP5, D2_ALQIMP6, D2_CBASE, D2_TPBASE, D2_TES, D2_CF "
			cQryAux	+= " FROM " + RetSqlName("SF2") + " F2 "
			cQryAux	+= " INNER JOIN " + RetSqlName("SD2") + " D2 "
			cQryAux	+= "       ON  ( D2.D_E_L_E_T_ = ' ' AND D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA) "
			cQryAux	+= " WHERE F2.D_E_L_E_T_ = ' ' "
			cQryAux	+= " AND F2_FILIAL = '" + xFilial('SE2') + "' 
			cQryAux	+= " AND F2_CHVNFE = '" + CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED + "'
			If Select("Qry1") <> 0
				Qry1->(dbCloseArea())
			EndIf
			TCQuery cQryAux Alias Qry1 New
			dbSelectArea("QRY1")
			Qry1->(dbGotop()) 
			If !Qry1->(Eof())

				// limpa as variaveis
				aCabec := {}
				aItens := {}
				// Cabecalho
				aadd(aCabec,{"F2_TIPO"   ,Qry1->F2_TIPO})
				aadd(aCabec,{"F2_FORMUL" ,Qry1->F2_FORMUL})
				aadd(aCabec,{"F2_DOC"    ,Qry1->F2_DOC})
				aadd(aCabec,{"F2_SERIE"  ,Qry1->F2_SERIE})
				aadd(aCabec,{"F2_EMISSAO",Qry1->F2_EMISSAO})
				aadd(aCabec,{"F2_CLIENTE",Qry1->F2_CLIENTE})
				aadd(aCabec,{"F2_LOJA"   ,Qry1->F2_LOJA})
				aadd(aCabec,{"F2_ESPECIE",Qry1->F2_ESPECIE})
				aadd(aCabec,{"F2_COND"	 ,Qry1->F2_COND})
				aadd(aCabec,{"F2_DESCONT",Qry1->F2_DESCONT})
				aadd(aCabec,{"F2_FRETE"	 ,Qry1->F2_FRETE})
				aadd(aCabec,{"F2_SEGURO" ,Qry1->F2_SEGURO})
				aadd(aCabec,{"F2_DESPESA",Qry1->F2_DESPESA})
				aadd(aCabec,{"F2_RECISS" ,Qry1->F2_RECISS})
				// Itens
				For nX := 1 To 1
					aLinha := {}
					aAdd(aLinha,{"AUTDELETA"	,"S"    			,Nil})
					aadd(aLinha,{"D2_ITEM"		,Qry1->D2_ITEM		,Nil})
					aadd(aLinha,{"D2_COD"		,Qry1->D2_COD		,Nil})
					aadd(aLinha,{"D2_QUANT"		,Qry1->D2_QUANT		,Nil})
					aadd(aLinha,{"D2_PRCVEN"	,Qry1->D2_PRCVEN	,Nil})
					aadd(aLinha,{"D2_TOTAL"		,Qry1->D2_TOTAL		,Nil})
					aadd(aLinha,{"D2_TES"		,Qry1->D2_TES		,Nil})
					aadd(aLinha,{"D2_CF"		,Qry1->D2_CF		,Nil})
					aadd(aLinha,{"D2_ALQIMP1"	,Qry1->D2_ALQIMP1	,Nil})
					aadd(aLinha,{"D2_ALQIMP2"	,Qry1->D2_ALQIMP2	,Nil})
					aadd(aLinha,{"D2_ALQIMP3"	,Qry1->D2_ALQIMP3	,Nil})
					aadd(aLinha,{"D2_ALQIMP4"	,Qry1->D2_ALQIMP4	,Nil})
					aadd(aLinha,{"D2_ALQIMP5"	,Qry1->D2_ALQIMP5	,Nil})
					aadd(aLinha,{"D2_ALQIMP6"	,Qry1->D2_ALQIMP6	,Nil})
					aadd(aLinha,{"D2_CBASE"  	,Qry1->D2_CBASE		,Nil})
					aadd(aLinha,{"D2_TPBASE"	,Qry1->D2_TPBASE	,Nil})
					aadd(aItens,aLinha)
				Next nX

				// atualiza campo D2_ORIGLAN para realizar a exclusão, adicionado 20/02/2019 conforme chamado 19633
				DbSelectArea("SD2")
				DbSetOrder(3)
				If DbSeek(xFilial("SD2")+Qry1->F2_DOC+Space(TamSX3("D2_DOC")[1]-len(Qry1->F2_DOC))+Qry1->F2_SERIE+Space(TamSX3("D2_SERIE")[1]-len(Qry1->F2_SERIE))+CND->CND_CLIENT+CND->CND_LOJACL+"000000000000001")
					RecLock("SD2",.F.)
					SD2->D2_ORIGLAN := "LF"
					MsUnlock("SD2")
				EndIf
				
				// chama funcao para realizar exclusao
				ConOut(PadC("Execucao exclusao MSExecAuto MATA920",80))
				ConOut("Inicio: "+Time())
				MATA920(aCabec,aItens,5)
				// Verifica se foi possivel excluir
				If !lMsErroAuto		
					ConOut("NF Excluida com sucesso! "+_cDoc)		
				Else
					AEVal(GetAutoGRLog(),{|x| cError += x + "<br>"})
					u_xHtmlPad("Erro ao excluir NF Saida Manual",cError)
					u_envMailA(_cMailTI,"GCT - Erro ao excluir NF Saida Manual (MATA920)",cHtml,2,"","jackson@sla.inf.br")
				EndIf
				ConOut("Fim  : "+Time())
				ConOut(Repl("-",80))

			EndIf

		EndIf

	ElseIf _cPlnLocC == CN9->CN9_TPCTO

		// Gera email de alerta
		xGeraMail("ESTORNO MEDICAO DE CONTRATO (CNTA120)",_cMailGCT,CN9->CN9_NUMERO,CND->CND_NUMMED,"a PAGAR (SE2)","Fornecedor: ",CND->CND_FORNEC," / Loja: ",CND->CND_LJFORN,Posicione("SA2",1,xFilial("SA2")+CND->CND_FORNEC+CND->CND_LJFORN,"A2_NOME"),CND->CND_NUMTIT,CND->CND_PARCEL,CND->CND_VLTOT,CND->CND_DTVENC,CN9->CN9_XTPPAG,CN9->CN9_XMSGPG)
		u_xHtmlPad("Medicao de Contrato Estornada",cMensg)
		u_envMailA(_cMailGCT,"GCT - Medicao de Contrato Estornada (CNTA120)",cHtml,2,_cMailTI,"jackson@sla.inf.br")

	EndIf

Return .T.

// Gera corpo do email
Static Function xGeraMail(cRotina,cTo,cNumCon,cNumMed,cTipTit,cCliFor,cCodCF,cLoja,cLjCF,cNome,cNumTit,cNumPrc,nValor,dDtVenc,cTpPag,cHist)

	Local 	cTitulo 	:= ""
	Default cTo			:= ""

	If !Empty(cTo)
		cTitulo := OemToAnsi(cRotina + " - DATA: " + DToC(Date()))
		// Monta uma breve mensagem para ser colocada no e-mail.
		cMensg :=  "EMPRESA/FILIAL: " + cEmpAnt + "-" + cFilAnt + " | CONTRATO: " + cNumCon + " / MEDICAO: " + cNumMed;
					+ "<br><br>A medição do contrato foi estornada.";
					+ "<br>";
					+ "Excluido titulo financeiro " + cTipTit;
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

// Rotina para estornar nf manual de saida
User Function xEstNfEnt(cEmpAnt,cFilAnt,aCabec,aLinha)

	Local	cError		:= ""
	Local 	_cMailTI	:= "" //"thiago.padilha@agricopel.com.br"
	Private cHtml		:= ""
	Private cMensg		:= ""	
	Private lMsErroAuto := .F.
	Private	lAutoErrNoFile	:= .T.

	// Prepara o ambiente na empresa e filial para realizar a cópia.
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv(cEmpAnt,cFilAnt)

	// Verifica se encontrou fornecedor
	If Len(aCabec) > 0 .and. Len(aLinha) > 0

		// Executa exclusão
		ConOut(PadC("Execucao exclusao MSExecAuto MATA920",80))
		ConOut("Inicio: "+Time())
		MSExecAuto ({|x,y| MATA920(aCabec,aItens)}, aCabec, aItens, 5)
		// Verifica se foi possivel excluir
		If !lMsErroAuto		
			ConOut("NF Excluida com sucesso! "+_cDoc)		
		Else
			AEVal(GetAutoGRLog(),{|x| cError += x + "<br>"})
			u_xHtmlPad("Erro ao excluir NF Saida Manual",cError)
			u_envMailA(_cMailTI,"GCT - Erro ao excluir NF Saida Manual (MATA920)",cHtml,2,"","jackson@sla.inf.br")
		EndIf
		ConOut("Fim  : "+Time())
		ConOut(Repl("-",80))

	EndIf

Return !lMsErroAuto

// Rotina para estornar nf manual de saida
User Function EstNfEnt(cEmpAnt,cFilAnt,aCabec,aLinha)

	Local	cError		:= ""
	Local 	_cMailTI	:= "thiago.padilha@agricopel.com.br"
	Private cHtml		:= ""
	Private cMensg		:= ""	
	Private lMsErroAuto := .F.
	Private	lAutoErrNoFile	:= .T.

	// Prepara o ambiente na empresa e filial para realizar a cópia.
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv(cEmpAnt,cFilAnt)

	// Verifica se encontrou fornecedor
	If Len(aCabec) > 0 .and. Len(aLinha) > 0

		// Executa exclusão
		ConOut(PadC("Execucao exclusao MSExecAuto MATA920",80))
		ConOut("Inicio: "+Time())
		MSExecAuto ({|x,y| MATA920(aCabec,aLinha)}, aCabec, aLinha, 5)
		// Verifica se foi possivel excluir
		If !lMsErroAuto		
			ConOut("NF Excluida com sucesso! "+_cDoc)		
		Else
			AEVal(GetAutoGRLog(),{|x| cError += x + "<br>"})
			u_xHtmlPad("Erro ao excluir NF Saida Manual",cError)
			u_envMailA(_cMailTI,"GCT - Erro ao excluir NF Saida Manual (MATA920)",cHtml,2,"","jackson@sla.inf.br")
		EndIf
		ConOut("Fim  : "+Time())
		ConOut(Repl("-",80))

	EndIf

Return !lMsErroAuto

// Rotina para estornar titulo na empresa de origem
User Function EstTitOr(aDadosTit)

	Local	cError		:= ""
	Local 	_cMailTI	:= "thiago.padilha@agricopel.com.br"
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

	// Verifica se encontrou fornecedor
	If !Empty(_cCodFor) .and. !Empty(_cLojFor)

		DbSelectArea("SE2")  
		DbSetOrder(1)
		// E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If MsSeek(xFilial("SE2")+aDadosTit[03]+Space(TamSX3("E2_PREFIXO")[1]-len(aDadosTit[03]))+aDadosTit[04]+cParcela+_cTipoE2+Space(TamSX3("E2_TIPO")[1]-len(_cTipoE2))+_cCodFor+_cLojFor)

			aArray := { { "E2_PREFIXO"	, SE2->E2_PREFIXO	, NIL },;
						{ "E2_NUM"		, SE2->E2_NUM		, NIL },;
						{ "E2_PARCELA"	, SE2->E2_PARCELA	, NIL },;
						{ "E2_TIPO"		, SE2->E2_TIPO		, NIL },;
						{ "E2_FORNECE"	, SE2->E2_FORNECE	, NIL },;
						{ "E2_LOJA"		, SE2->E2_LOJA		, NIL } }

			// Executa exclusão
			ConOut(PadC("Execucao exclusao MSExecAuto FINA050",80))
			ConOut("Inicio: "+Time())
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)
			// Verifica se foi possivel excluir
			If !lMsErroAuto
				ConOut("Contas a Pagar excluido com sucesso!")		
			Else
				AEVal(GetAutoGRLog(),{|x| cError += x + "<br>"})
				u_xHtmlPad("Erro ao excluir Contas a Pagar",cError)
				u_envMailA(_cMailTI,"GCT - Erro ao excluir Contas a Pagar (FINA050)",cHtml,2,"","jackson@sla.inf.br")
			EndIf
			ConOut("Fim  : "+Time())
			ConOut(Repl("-",80))

		EndIf

	EndIf

Return !lMsErroAuto