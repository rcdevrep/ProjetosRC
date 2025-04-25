#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

user function MT120FIM()
	Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario. Visualiza=2; Inclui=3; Altera=4; Exclui=5; Copia=9
	Local cNumPC := PARAMIXB[2]   // Numero do Pedido de Compras
	Local nConfirma := PARAMIXB[3]   // Indica se a ação foi Cancelada = 0  ou Confirmada = 1
	Local lEnviaEmail := .F., lAprovAuto := .F.
	
	
    Local nPosItem   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEM"})
    Local nPosVlr    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
	Local nPosConta    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONTA"})
	Local nLinAtu 	 := 1
	
	Private _cPedido := "", _cItem := ""
	
	DbSelectArea('SC7')
    SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
    For nLinAtu := 1 To Len(aCols)
        If SC7->(DbSeek(FWxFilial("SC7")+cA120Num+aCols[nLinAtu][nPosItem]))
            RecLock('SC7', .F.)
			
			
			cQuery := "SELECT SFM.* FROM "+RetSqlName("SFM")+" SFM "
			cQuery += "WHERE FM_CONTA = '"+ALLTRIM(aCols[nLinAtu][nPosConta])+ "' "
			cQuery += "AND SFM.D_E_L_E_T_ <> '*'  "

			If (Select("SFMT") <> 0)
				dbSelectArea("SFMT")
				dbCloseArea()
			Endif
			
			TCQuery cQuery NEW ALIAS "SFMT"

			dbSelectArea("SFMT")
			dbGoTop()
			WHILE !(SFMT->(Eof()))

				//SC7->C7_OPER := SFMT->FM_TIPO
				SC7->C7_TES := SFMT->FM_TE

				SFMT->(dbSkip())
			END

            SC7->(MsUnlock())
        EndIf
    Next

	DbSelectArea("SC7")
	DbSetOrder(1)

	If 	DbSeek(xFilial("SC7")+cA120Num) .AND. nConfirma=1 .AND. !(nOpcao=2 .OR. nOpcao=5)
		WHILE SC7->C7_NUM == cA120Num .and. SC7->(!EOF())
			cConta := ALLTRIM(SC7->C7_CONTA)
			_cPedido := Alltrim( SC7->C7_NUM)
			_cItem := Alltrim( SC7->C7_ITEM)
			If	cConta == "11310001" .or. cConta == "11310002" .or. cConta ==  "11310003";
				.or. cConta == "11310011" .or. cConta == "11310012" .or. cConta == "11310013";
				.or. cConta == "11310014" .or. cConta == "11310015" .or. cConta == "11310016";
				.OR. cConta == "41220045"	//Chamado 3117 - 27/11/2024 - Matheus Silva
				
				lEnviaEmail := .T.
				lAprovAuto := .T.

				EXIT
			EndIf
			DbSkip()
		EndDo
	EndIf
	If lAprovAuto
		MT120SCR()
	EndIf 
	If lEnviaEmail
		MT120FIMWF(cA120Num)
	EndIf
	If !lAprovAuto .AND. !(nOpcao=2 .OR. nOpcao=5) .AND. nConfirma = 1
		AvisaAprov(nOpcao, AllTrim(cNumPC), nConfirma)
	EndIf

	If (nOpcao=4 .OR. nOpcao=5) .AND. SC7->C7_FORIGEM = "TCOMA03" .AND. nConfirma = 1
		ALTEZB5(nOpcao)
	EndIf
return

/*	-- MT120SCR --	
	Aprova automaticamente o pedido de compra/autorização de entrega
*/
Static Function MT120SCR()
	Local cQuery  := ""
	Local cSql    := ""
	Local cUSRSCR := ""
	Local cEol    := chr(10)
	cQuery := "EXEC stp_Protheus_Compras02 "+valtosql(cA120Num) +" , "+valtosql( xFilial("SC7"))

	If (Select("_USR") <> 0)

		dbSelectArea("_USR")
		dbCloseArea()

	Endif
	conout(cQuery)
	TCQuery cQuery NEW ALIAS "_USR"


	cUSRSCR := _USR->CD_USR_SC
	
	cSql  :="EXEC dbo.stp_Protheus_Compras04  " +  cEol
	cSql +="  @NUMPEDIDO =    " +  valtosql(cA120Num)
	cSql +=" ,@FILIAL    =    " +  valtosql(xFilial("SC7"))
	cSql +=" ,@USER    =    " +  valtosql(cUSRSCR)
	
	CONOUT(cSql)
	
	TcSqlExec(cSql)

	cSql := " UPDATE SC7010 SET C7_CONAPRO = 'L' "
	cSql += " WHERE	D_E_L_E_T_ = '' "
	cSql += " and C7_NUM = "+valtosql(cA120Num)+" "
	cSql += " and C7_FILIAL = "+valtosql(xFilial("SC7"))

	CONOUT(cSql)
	TcSqlExec(cSql)
Return


Static Function MT120FIMWF( cPedido)
	LOCAL oProcess, cDir := GetMV("MV_WFDIR"), cArquivo := "WfAaprov.htm"
	LOCAL cProcess := "100000", cStatus  := "100100", cEmail := "", _x

	//Coloco a barra no final do parametro do diretorio
	///////////////////////////////////////////////////
	If Substr(cDir,Len(cDir),1) != "\"
		cDir += "\"
	Endif

	//Verifico se existe o arquivo de workflow
	//////////////////////////////////////////
	If !File(cDir+cArquivo)
		Msgstop(">>> Nao foi encontrar o arquivo "+cDir+cArquivo)
		Return
	Endif

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(xFilial("SC7")+cPedido))
	nTipo 	:= SC7->C7_TIPO
	cSolic  := SC7->C7_NUMSC
	cData   := DtoC(msdate())
	cHora   := Substr(Time(),1,5)
	cUser   := SC7->C7_USER

	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SC7->C7_FORNECE))
	cFor := Alltrim(SA2->A2_NOME)


	//Memnsagem Automatica: Liberacao do Pedido: XXXXXX
	//Memnsagem Automatica: Liberacao da Autorizacao de Entrega: XXXXXX

	// Solicitacao: XXXXXX
	// Fornecedor: 	XXXXXXXXXXXXXXX
	// Data: 		99/99/99
	// Hora: 		99:99

	// Contrato  :  XXXXXX
	// Fornecedor: 	XXXXXXXXXXXXXXX
	// Data: 		99/99/99
	// Hora: 		99:99

	//Inicializo os emails
	//////////////////////
	oProcess := TWFProcess():New(cProcess,OemToAnsi("Aviso de Aprovacao de Compras"))
	oProcess:NewTask(cStatus,cDir+cArquivo)
	//oProcess:cSubject := OemToAnsi(dtoc(MsDate())+" >>> Aviso de Reprovacao da Solicitacao Compras "+xSolicit+"/"+xItem)

	If nTipo == 1
		cDescTp := "Solicitacao"
		oProcess:cSubject := " >>> Mensagem Automatica: Aprovacao do Pedido: "+cPedido
		SC1->(dbSetOrder(1))
		If SC1->(dbSeek(xFilial("SC1")+cSolic))

			PswOrder(2)
			If PswSeek(SC1->C1_SOLICIT)
				//If !PswRet(1)[1,17] //Inserido em 09.10.2012 - Cezar
				cEmail := Alltrim(PswRet(1)[1,14])
				//Incluido em 08/05/2015, pois o Rogel tem mais de uma conta e o protheus nao permite cadastrar o mesmo email
				If Alltrim(cEmail) == "rdcan2@tecnofibras.com.br"
					cEmail := "rdcani@tecnofibras.com.br"
				Endif
				//Endif
			Endif
		Endif

		If Empty(cEmail)
			PswOrder(2)
			If !PswSeek(cUser)
				cEmail := Alltrim(PswRet(1)[1,14])
				If Alltrim(cEmail) == "rdcan2@tecnofibras.com.br"
					cEmail := "rdcani@tecnofibras.com.br"
				Endif
			Endif
		EndIf

	Else
		cDescTp := "Contrato"
		oProcess:cSubject := " >>> Mensagem Automatica: Aprovacao da Autorizacao de Entrega: "+cPedido

		PswOrder(1)
		If PswSeek(cUser)
			//If !PswRet(1)[1,17] //Inserido em 09.10.2012 - Cezar
			cEmail := Alltrim(PswRet(1)[1,14])
			//Incluido em 08/05/2015, pois o Rogel tem mais de uma conta e o protheus nao permite cadastrar o mesmo email
			If Alltrim(cEmail) == "rdcan2@tecnofibras.com.br"
				cEmail := "rdcani@tecnofibras.com.br"
			Endif
			//Endif
		Endif

	Endif


	If Empty(cEmail)
		cEmail :="sistemas@tecnofibras.com.br"
	Endif

	lAmbProd := .F.	
	aTemp := GetUserInfoArray()	
	For _x := 1 To Len(aTemp)
		If !Empty(aTemp[_x,6])
			If UPPER(AllTrim(aTemp[_x,6])) $ "ENVIRONMENT"
				lAmbProd := .T.
			Endif
		Endif
	Next _x
	cEmail := Alltrim(cEmail+";compras@tecnofibras.com.br")
	If !lAmbProd
		//Alert(cEmail + " Caso apareca essa mensagem, favor contatar a TI")
		cEmail := "sistemas@tecnofibras.com.br"
	EndIf
	//Fim
	//oProcess:cTo := (Alltrim(cNewmail))
	//oProcess:cTo := (Alltrim(cNewmail+";compras@tecnofibras.com.br"))
	oProcess:cTo := (cEmail)
	//oProcess:cTo := Alltrim(cEmail)
	oProcess:oHtml:ValByName("cDescTp",cDescTp)
	oProcess:oHtml:ValByName("cSolic",cSolic)
	oProcess:oHtml:ValByName("cFor",cFor)
	oProcess:oHtml:ValByName("cData",cData)
	oProcess:oHtml:ValByName("cHora",cHora)



	//Envia os emails
	/////////////////
	oProcess:Start()
	oProcess:Finish()

Return

/*/{Protheus.doc} AvisaAprov(cA120Num)
	Avisa o Aprovador de pedido de compra que ele tem um pedido aguardando aprovação.
	@type  Static Function
	@author Adriano Zanella Junior
	@since 20/10/2021
	@version 0.0
	@param nOpcao, Numerico, Opção Selecionada: Visualiza=2; Inclui=3; Altera=4; Exclui=5; Copia=9
	@param cNumPed, Caracteres, Numero do Pedido de Compra Criado
	@param nConfirma, Numerico, Indica se a ação foi Cancelada = 0  ou Confirmada = 1
	@return Nil, Nil, Nada
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function AvisaAprov(nOpcao, cNumPed, nConfirma)
	Local cMsgResp := "Pedido de Compras criado por "+AllTrim(UsrFullName(__cUserID))+"."
	Local aItens := {}, aSolic := {}, aUsSolic := {}
	Local i, nTotalPedido := 0
	Local cTabRejeicao := "hidden"
	Local cMsgAprov := ""
	
	Private oProcess, oHTML, cDir := GetMV("MV_WFDIR"), cArquivo := "wf_AprovPedido_v1.html"


	//cText := ">> MT120FIM >> Numero do Pedido de Compras: "+cNumped+"; Opção: "+STR(nOpcao,2)+"; Confirmado: "+STR(nConfirma,1)+"."
	//MsgInfo(cText, "MT120FIM")
	If nConfirma = 1 .AND. (nOpcao = 3 .OR. nOpcao = 4 .OR. nOpcao = 9)// .AND. .F.
		//MsgInfo("Iniico email Aprovador", "MT120FIM")
		//Envia email
		cEmailTo := ""
		cEmailCC := AllTrim(UsrRetMail(__cUserID))
		cNomAprov := ""

		cRespTitu := "Aviso para aprova&ccedil;&atilde;o"
		cResposta := "EM APROVA&Ccedil;&Atilde;O"

		cTipo := ""
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek(xFilial("SC7")+cNumPed)
		If SC7->C7_TIPO = 1
			cTipo := "PC"
		Else
			cTipo := "AE"
		EndIf
		While SC7->(C7_NUM) == cNumPed
			aItem := {AllTrim(SC7->C7_PRODUTO), AllTrim(SC7->C7_DESCRI), SC7->C7_QUANT, SC7->C7_PRECO, SC7->C7_TOTAL}
			nTotalPedido += SC7->C7_TOTAL
			If Len(SC7->C7_NUMSC) > 0 .AND. AScan(aSolic, ALLTRIM(SC7->C7_NUMSC)) = 0
				Aadd(aSolic, ALLTRIM(SC7->C7_NUMSC))
			EndIf
			Aadd(aItens, aItem)
			DbSelectArea("SC7")
			DbSkip()
		EndDo

		// Email Solicitantes
		If Len(aSolic) > 0
			DbSelectArea("SC1")
			DbSetOrder(1)
			For i := 1 To Len(aSolic)
				If DbSeek(xFilial("SC1")+aSolic[i])
					If AScan(aUsSolic, AllTrim(SC1->C1_USER)) = 0
						Aadd(aUsSolic, AllTrim(SC1->C1_USER))
					EndIf
				/*
				Else
					MsgAlert("Solicitação de Compra não existe", "MT120FIM")
				*/	
				EndIf
			Next i
			DbCloseArea()
			If Len(aUsSolic) > 0
				cEmUsSol := AllTrim(UsrRetMail(aUsSolic[1]))
				For i := 2 To Len(aUsSolic)
					cEmUsSol += ";"+AllTrim(UsrRetMail(aUsSolic[1]))
				Next i
				cEmailCC += ";"+cEmUsSol
			EndIf
		EndIf
		//Email do Aprovador
		aAprovs := {}
		DbSelectArea("SCR")
		DbSetOrder(1)
		DbSeek(xFilial("SCR")+cTipo+cNumPed)
		//MsgInfo("SCR: "+xFilial("SCR")+cTipo+cNumPed+". Encontrado: "+AllTrim(SCR->CR_NUM), "MT120FIM Buscando SCR")
		While AllTrim(SCR->CR_NUM) == cNumPed
			If SCR->CR_STATUS == "02"
				Aadd(aAprovs, AllTrim(SCR->CR_USER))
				//Alert(AllTrim(SCR->CR_USER) + " com email " + UsrRetMail( AllTrim(SCR->CR_USER)))
			EndIf
			DbSelectArea("SCR")
			DbSkip()
		EndDo
		DbSelectArea("SCR")
		DbCloseArea()
		If Len(aAprovs) > 0
			cEmailTo := AllTrim( UsrRetMail( aAprovs[1]))
			cNomAprov := AllTrim( UsrFullName(aAprovs[1]))
			For i := 2 To Len(aAprovs)
				cEmailTo += ";"+AllTrim( UsrRetMail( aAprovs[i]))
				cNomAprov := ", "+AllTrim( UsrFullName(aAprovs[i]))
			Next
			cMsgAprov := "Aprovadore(s): "+cNomAprov+"."
		Else
			MsgAlert("SEM APROVADOR!!!", "MT120FIM")
		EndIf
		/*
		If !(UPPER(AllTrim(GetEnvServer())) $ "ENVIRONMENT")
			MsgAlert("Emails aprovador(es) "+cEmailTo+", substituido para teste.", "MT120FIM - Ambiente de Teste")
			cEmailTo := "ti@tecnofibras.com.br"
			MsgAlert("Emails solicitantes/compradores(es) "+cEmailCC+", substituido para teste.", "MT120FIM - Ambiente de Teste")
		Endif
		*/
		/*	-- Inicio do Email de Aprovação --	*/
		If Substr(cDir,Len(cDir),1) != "\"
			cDir += "\"
		Endif
		If !File(cDir+cArquivo)
			MsgStop(">> MT120FIM >> Arquivo "+cArquivo+" não encontrado no diretório "+cDir+".", "Aquivo HTML não encontrado!")
			Return
		EndIf
		cProcess := "100000"
		cStatus := "100100"
		oProcess := TWFProcess():New(cProcess, OemToAnsi("Pedido de Compra "+cNumPed+" para Aprovação"))
		oProcess:NewTask(cStatus, cDir+cArquivo)
		//oProcess:cSubject := OemToAnsi("MT094END > "+DToC(MsDate())+" > Resposta Pedido de Compra "+cNumPed)
		oProcess:bReturn	:= "U_RET120WF(1)"
		oProcess:bTimeOut	:= {{"U_RET120WF(2)",5,0,0}}
		oHTML	:= oProcess:oHTML

		oProcess:cTo := AllTrim(cEmailTo)
		oProcess:cCC := AllTrim(cEmailCC)
		//oProcess:cBCC := "adriano@asinc.com.br"	//para testes
		
		oProcess:cSubject := OemToAnsi("Pedidos de Compras "+cNumPed+" para Aprovação")
		
		oHTML:ValByName("RESPTITLE",cRespTitu)
		oHTML:ValByName("NUMPED",cNumPed)
		oHTML:ValByName("RESPOSTA",cResposta)

		For i := 1 To Len(aItens)
			oHtml:ValByName("WFSEQ", AllTrim(STR(i)))
			Aadd(oHTML:ValByName("IT.COD"),	aItens[i][1])
			Aadd(oHTML:ValByName("IT.DESC"),	aItens[i][2])
			Aadd(oHTML:ValByName("IT.QNT"),	AllTrim( Str( aItens[i][3],12)))
			Aadd(oHTML:ValByName("IT.VALUN"),	AllTrim( Str( aItens[i][4],12,2)))
			Aadd(oHTML:ValByName("IT.VALTOT"),AllTrim( Str( aItens[i][5],12,2)))
		Next

		oHTML:ValByName("VALPED",	AllTrim( Str( nTotalPedido,12,2)))
		oHTML:ValByName("TABREJ",cTabRejeicao)
		oHTML:ValByName("MOTIVREJ","MOTIVO")
		oHTML:ValByName("MSGRESPONSAVEL",cMsgResp)
		oHTML:ValByName("MSGAPROVADOR",cMsgAprov)

		
		oProcess:Start()
		//MsgInfo("MT094END > Email sendo enviado...", "MT094END")
		oProcess:Finish()
		/*	-- Fim Email Aprovação --	*/
		
		//MsgInfo("Fim email Aprovador", "MT120FIM")
	EndIf
Return

User Function RET120WF(xOpcao, oProcess)
	If xOpcao == 1
		MsgInfo("RET120WF > SUCESSO??", "MT094END")
	Else
		MsgInfo("RET120WF > TIMEOUT??", "MT094END")
	EndIf
	oProcess:Finish()
Return (.T.)

Static Function ALTEZB5(nOpcao)
	Local cPCAE := cFornece := cProduto := cTipo := cItem := ""
	DbSelectArea("SC7")
	DbSetOrder(1)
	
	cPCAE := SC7->C7_NUM
	cFornece := SC7->C7_FORNECE + SC7->C7_LOJA
	cTipo := "F"	//Firme

	DbSelectArea("ZB5")
	ZB5->(DbSetOrder(2))

	If SC7->(DbSeek(xFilial("SC7")+cA120Num))
		While SC7->C7_NUM == cA120Num .and. SC7->(!EOF())
			If SC7->C7_QUANT > SC7->C7_QUJE .AND. AllTrim(SC7->C7_RESIDUO) == ""	//Pedido já entregue
				cItem := SC7->C7_ITEM
				cProduto := SC7->C7_PRODUTO

				If ZB5->(DbSeek(xFilial("SC7")+cFornece+cProduto+cTipo+cPCAE+cItem))
					If nOpcao = 4 //Altera - Ajuste de Quantidade ou Data de Entrega
						Reclock( "ZB5", .F. )
						//MsgAlert("Altera","MT120FIM")
							ZB5->ZB5_QUANT := SC7->C7_QUANT
							ZB5->ZB5_DATA := SC7->C7_DATPRF
						MsUnlock()
					ElseIf nOpcao = 5 //Deleta - Demanda deve ser revisada
						//MsgAlert("Deleta","MT120FIM")
						Reclock( "ZB5", .F. )
						//MsgAlert("Altera","MT120FIM")
							ZB5->ZB5_PCAE := ""
							ZB5->ZB5_TIPO := "P"
							ZB5->ZB5_QUJE := 0
						MsUnlock()
					EndIf
				EndIf

			EndIf
			
			//DbSelectArea("SC7")
			SC7->(DbSkip())
		EndDo
	EndIf

	ZB5->(DBCloseArea())
Return
