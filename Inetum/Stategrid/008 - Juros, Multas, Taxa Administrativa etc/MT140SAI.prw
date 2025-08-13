#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOPCONN.CH"

USER FUNCTION MT140SAI()

	Local nOrdem 	:= SF1->( IndexOrd() )
	Local cRefCode	:= ""
	Local _aArea	:= GetArea()
	Local cQry		:= ""
	Local cAlias	:= CriaTrab(Nil,.F.)
	Local cNUSer	:= ""
	Local cCCMail 	:= ""
	Local cAccount	:= GetMv("MV_XXCTAEM")
	Local nX

//PARAMIXB[1] = Numero da operação - ( 2-Visualização, 3-Inclusão, 4-Alteração, 5-Exclusão )
//PARAMIXB[2] = Número da nota
//PARAMIXB[3] = Série da nota
//PARAMIXB[4] = Fornecedor
//PARAMIXB[5] = Loja
//PARAMIXB[6] = Tipo
//PARAMIXB[7] = Opção de Confirmação (1 = Confirma pré-nota; 0 = Não Confirma pré-nota)

	If (ParamIxb[1] == 3 .And. PARAMIXB[7] == 1)
		SF1->(dbSetOrder(1))
		SF1->(MsSeek(xFilial('SF1')+ParamIxb[2]+ParamIxb[3]+ParamIxb[4]+ParamIxb[5]))

		cQry := "SELECT C7_XOEMLOC FROM "+RETSQLNAME("SC7")+" SC7,"+RETSQLNAME("SD1")+" SD1"
		cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
		cQry += " AND D1_FILIAL   = '"+xFilial("SD1")+"'"
		cQry += " AND C7_ITEM     = D1_ITEMPC"
		cQry += " AND C7_NUM      = D1_PEDIDO"
		cQry += " AND C7_FORNECE  = D1_FORNECE"
		cQry += " AND C7_LOJA     = D1_LOJA"
		cQry += " AND D1_FORNECE  = '"+SF1->F1_FORNECE+"'"
		cQry += " AND D1_LOJA     = '"+SF1->F1_LOJA   +"'"
		cQry += " AND D1_DOC      = '"+SF1->F1_DOC    +"'"
		cQry += " AND D1_SERIE    = '"+SF1->F1_SERIE  +"'"
		cQry += " AND C7_XOEMLOC <> ' '
		cQry += " AND C7_PRODUTO  = D1_COD"
		cQry += " AND SC7.D_E_L_E_T_ <> '*'"
		cQry += " AND SD1.D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cRefCode := (cAlias)->C7_XOEMLOC
			SF1->(RecLock("SF1",.F.))
			SF1->F1_XOEMLOC := cRefCode
			SF1->(MsUnLock("SF1"))
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(_aArea)

		cAlias	:= CriaTrab(Nil,.F.)
		cQry	:= "SELECT D1_CC, D1_XUSER FROM "+RETSQLNAME("SD1")
		cQry	+= " WHERE D1_FILIAL = '"+xFilial("SD1")+"'"
		cQry 	+= " AND D1_FORNECE  = '"+SF1->F1_FORNECE+"'"
		cQry	+= " AND D1_LOJA     = '"+SF1->F1_LOJA   +"'"
		cQry	+= " AND D1_DOC      = '"+SF1->F1_DOC    +"'"
		cQry	+= " AND D1_SERIE    = '"+SF1->F1_SERIE  +"'"
		cQry	+= " AND D_E_L_E_T_ <> '*'"
		TCQUERY cQry ALIAS (cAlias) NEW
		If !(cAlias)->(Eof())
			cNUser	:= (cAlias)->D1_XUSER
			cCCMail := (cAlias)->D1_CC
		EndIf
		(cAlias)->(DbCloseArea())
		RestArea(_aArea)
		cRefCode := "TESTE"
		cTitle := "State Grid - Pre-Invoice Inserted: "+SF1->(F1_DOC+F1_SERIE)
		cCorpo := ""
		cEmail := U_RetMails("PG",U_RetAreaM(cCCMail))
		If !Empty(cEmail)
			cCorpo += cTitle+"<br>"
			cCorpo += "Ref.Code: "+AllTrim(cRefCode)+"<br>"
			cCorpo += "Requester / Soliciante: "+AllTrim(UsrFullName(cNUser))+"<br>"
		/*
		(1)	The final status of the application (Approved or denied). 
		(2)	Ref.Code
		(3)	Requester name
		(4)	Type of request (Purchase request, purchase order or payment request) 
		*/
			U_SNDMail(cEmail,AllTrim(cAccount),"",cTitle,"",cCorpo,.F.,{})
		EndIf
	EndIf

	If (ParamIxb[1] == 3 .Or. ParamIxb[1] == 4) .And. PARAMIXB[7] == 1

		DbSelectArea("SF1")
		SF1->( dbSetOrder( 1 ) )
		SF1->( MsSeek( xFilial( 'SF1' ) + ParamIxb[2] + ParamIxb[3] + ParamIxb[4] + ParamIxb[5] ) )

		Reclock("SF1" , .F. )
		If Type("_cCamNovo1") == "N"
		    SF1->F1_XMULTA := _cCamNovo1
        EndIf

        If Type("_cCamNovo2") == "N"
            SF1->F1_XJUROS := _cCamNovo2
        EndIf

		If Type("cObsEmer") == "C"
			SF1->F1_XOBSEME    := cObsEmer
		EndIf
		If Type("cObsEmer") == "C"
			SF1->F1_XOBSEME    := cObsEmer
		EndIf
		If Type("cFormPagto") == "C"
			SF1->F1_XFORPAG    := cFormPagto
		EndIf
		If Type("dDtSugVenc") == "D"
			SF1->F1_XDTVENC    := dDtSugVenc
		EndIf
		If Type("dDtSugPg") == "D"
			SF1->F1_XDTPGTO    := dDtSugPg
		EndIf
		If Type("cHold") == "C"
			If cHold == "N"
				SF1->F1_XHOLD    := "S"
				SF1->F1_XSALDO	 := "S"
			Else
				SF1->F1_XHOLD    := " "
			EndIf
		EndIf
		If Type("cBanco") == "C"
			SF1->F1_XBANCOF    := cBanco
		EndIf
		If Type("cAgencia") == "C"
			SF1->F1_XAGENCF    := cAgencia
		EndIf
		If Type("cDgAgenc") == "C"
			SF1->F1_XDAGENF    := cDgAgenc
		EndIf
		If Type("cConta") == "C"
			SF1->F1_XCONTAF    := cConta
		EndIf
		If Type("cDgConta") == "C"
			SF1->F1_XDCONTF    := cDgConta
		EndIf
		If Alltrim(upper(funname())) == "STAA062"
			SF1->F1_XCELNF	   := "S"
			SF1->F1_XNFRECO	   := "S"
			SF1->F1_XLIBIMP	   := "S"
		EndIf
		If Type("cRequisit") == "C"
			SF1->F1_XREQUIS	   := cRequisit
		EndIf
		MsUnlock()

		//Zerar variáveis
		cFormPagto 	:= ""
		dDtSugVenc 	:= cTod(Space(8))
		dDtSugPg 	:= cTod(Space(8))
		lFirst		:= .T.

		DbSelectArea("ZZK")
		DbSetOrder(1)
		ZZK->(DBSeek(xFilial("ZZK")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

		While !ZZK->(Eof()) .And. ZZK->(ZZK_DOC+ZZK_SERIE+ZZK_FORNEC+ZZK_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			ZZK->(RecLock("ZZK", .F.))
			ZZK->(DbDelete())
			ZZK->(MsUnLock())
			ZZK->(DbSkip())
		EndDo

		If Type("aNotasRef") == "A"

			For nX := 1 To Len(aNotasRef)

				ZZK->(RecLock("ZZK", .T.))
				ZZK->ZZK_FILIAL	:= xFilial("ZZK")
				ZZK->ZZK_DOC	:= SF1->F1_DOC
				ZZK->ZZK_SERIE	:= SF1->F1_SERIE
				ZZK->ZZK_FORNEC	:= SF1->F1_FORNECE
				ZZK->ZZK_LOJA	:= SF1->F1_LOJA
				ZZK->ZZK_ITEM	:= aNotasRef[nX, 1]
				ZZK->ZZK_PRODUT	:= aNotasRef[nX, 2]
				ZZK->ZZK_DOCREF	:= aNotasRef[nX, 4]
				ZZK->ZZK_SERREF	:= aNotasRef[nX, 5]
				ZZK->ZZK_FORREF	:= aNotasRef[nX, 6]
				ZZK->ZZK_LOJREF	:= aNotasRef[nX, 7]
				ZZK->(MsUnLock())

			Next nX

			FWFREEVAR(@aNotasRef)

		EndIf

		If Alltrim(upper(funname())) == "STAA062"
			ZZM->(RecLock("ZZM",.T.))
			ZZM->ZZM_FILIAL	:= xFilial("ZZM")
			ZZM->ZZM_NOTA	:= SF1->F1_DOC
			ZZM->ZZM_SERIE	:= SF1->F1_SERIE
			ZZM->ZZM_FORNEC	:= SF1->F1_FORNECE
			ZZM->ZZM_LOJA	:= SF1->F1_LOJA
			ZZM->ZZM_DATA	:= DDATABASE
			ZZM->ZZM_HORA	:= Time()
			ZZM->ZZM_OPERAC	:= IF(ParamIxb[1] == 3, "I", IF(ParamIxb[1] == 4, "A", "X"))
			ZZM->ZZM_CODUSE	:= RetCodUsr()
			ZZM->(MsUnLock("ZZM"))
		EndIf

		SF1->( dbSetOrder( nOrdem ) )

		If Alltrim(upper(funname())) == "STAA062"
			EnvAlerta()
		EndIf

	EndIf

	If (ParamIxb[1] == 5 .And. PARAMIXB[7] == 1)

		DbSelectArea("ZZK")
		DbSetOrder(1)
		ZZK->(DBSeek(xFilial("ZZK")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

		While !ZZK->(Eof()) .And. ZZK->(ZZK_DOC+ZZK_SERIE+ZZK_FORNEC+ZZK_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			ZZK->(RecLock("ZZK", .F.))
			ZZK->(DbDelete())
			ZZK->(MsUnLock())
			ZZK->(DbSkip())
		EndDo

	EndIf

	If (ParamIxb[1] == 3 .And. PARAMIXB[7] == 1)
		If U_AvaForCFluig("1", "PNF")
			//MsgInfo("Este fornecedor não foi avaliado neste contrato nos ultimos 60 dias."+CHR(13) + CHR(10)+;
				//		"Foi gerada uma tarefa de avaliação para o mesmo no Fluig. A próxima NF deste fornecedor não poderá ser incluída sem a resposta desta avaliação.", "Avaliação Criada")
			MsgInfo("Este fornecedor não foi avaliado neste contrato nos ultimos 60 dias."+CHR(13) + CHR(10)+;
				"Foi gerada uma tarefa de avaliação para o mesmo no Fluig.", "Avaliação Criada")
		EndIf
	ElseIf (ParamIxb[1] == 5 .And. PARAMIXB[7] == 1)
		u_CanAvForFluig("PNF", SF1->F1_FILIAL,  "", SF1->F1_DOC, SF1->F1_SERIE)
	EndIf

	//Limpeza da ZZ1 em caso de cancelamento da inclusão ou exclusão do documento
	If (ParamIxb[1] == 3 .And. PARAMIXB[7] == 0) .Or. (ParamIxb[1] == 5 .And. PARAMIXB[7] == 1)

		cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM "+RETSQLNAME("ZZ1")+" WHERE "+CRLF
		cQuery += " D_E_L_E_T_ = '' AND ZZ1_SF1 = '"+xFilial("SF1")+CNFISCAL+CSERIE+CA100FOR+CLOJA+CTIPO+"' "+CRLF

		TCQuery cQuery NEW ALIAS (cAlias)

		While !(cAlias)->(Eof())

			ZZ1->(DBGoTo((cAlias)->RECNO))

			ZZ1->(RecLock("ZZ1",.F.))
			ZZ1->(dbDelete())
			ZZ1->(MsUnlock())

			(cAlias)->(DBSkip())
		EndDo

		(cAlias)->(dbCloseArea())		

	EndIf

	RestArea(_aArea)

Return(NIL)


Static Function EnvAlerta()

	Local aFiles := {}

	If UPPER(GetEnvServer()) == 'STATEGRID' .OR. UPPER(GetEnvServer()) == 'STATEGRID_EN'
		cEmailAprov := UsrRetMail(SF1->F1_XREQUIS)
	Else
		cEmailAprov := UsrRetMail(SF1->F1_XREQUIS)+";marcos.silva@stategrid.com.br"
	EndIf

	cTitle	:= OEMTOANSI("Inclusão de Nota Fiscal via Célula - " + LTRIM(SF1->F1_DOC) )

	aMsg := {}

	SA2->(DbSetOrder(1))
	SA2->(DBSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))

	AADD(aMsg, '<font font size="7" color="blue">Pré Nota Incluída</font>' )
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Prezados(a), " + UsrFullName(SF1->F1_XREQUIS))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "A Pré nota foi incluída pelo setor de entrada de nota. Aguarde a classificação da mesma para liberá-la para pagamento.")
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, Dtoc(MSDate()) + " - " + Time() + '</b>')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Usuário Responsável.......... " + UsrFullName(retcodusr()) )
	AADD(aMsg, "Empresa.................................. " + SF1->F1_FILIAL)
	AADD(aMsg, "Número do Documento........... " + LTRIM(SF1->F1_DOC))
	AADD(aMsg, "Série......................................... " + LTRIM(SF1->F1_SERIE))
	AADD(aMsg, "Código do Fornecedor............. " + LTRIM(SF1->F1_FORNECE))
	AADD(aMsg, "Nome do Fornecedor............. " + LTRIM(SA2->A2_NOME))
	AADD(aMsg, "Data de entrega para o fiscal... "+ DTOC(SF1->F1_RECBMTO))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<font font size="7" color="blue">Pre invoice included</font>' )
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Dear, " + UsrFullName(SF1->F1_XREQUIS))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "The Pre invoice was included by the notes entry sector. Wait for the classification to release for payment.")
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, Dtoc(MSDate()) + " - " + Time() + '</b>')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Responsable operator.......... " + UsrFullName(retcodusr()) )
	AADD(aMsg, "Company.............................. " + SF1->F1_FILIAL)
	AADD(aMsg, "Document number............... " + LTRIM(SF1->F1_DOC))
	AADD(aMsg, "Serie...................................... " + LTRIM(SF1->F1_SERIE))
	AADD(aMsg, "Supplier code........................ " + LTRIM(SF1->F1_FORNECE))
	AADD(aMsg, "Supplier name.................. " + LTRIM(SA2->A2_NOME))
	AADD(aMsg, "Delivery Date to TAX............. "+ DTOC(SF1->F1_RECBMTO))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')

	MSGRUN( "Enviando e-mail para o solicitante", "Enviando", {||U_STAAX11(cEmailAprov, cTitle, aMsg, aFiles)} )

Return
