#INCLUDE "rwmake.ch"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ XAG0090 º Autor ³ Geyson Albano GW   º Data ³  18/08/22    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Workflow de NFe canceladas ou denegadas                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AGRICOPEL                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function XAG0090(aParams)

Default aParams := {"01", "01"}

RPCSetType(3)
RPCSetEnv(aParams[1], aParams[2])
FwLogMsg("INFO", /*cTransactionId*/, "WFFAT", FunName(), "", "01", "NFEs nao utilizadas - Empresa: " + aParams[1] + "/" + aParams[2] + " - " + DtoC(Date()),,, {})

XAG0090A()

RpcClearEnv()

Return


Static Function XAG0090A()

Local _cMsg		:= ""
Local _cEmail	:= ""
Local lBl1 := .T.
Local _cFrom   := "protheus@agricopel.com.br"
Local _cSubject	:= "NFS's REJEITADAS E DENEGADAS"
Local aCNPJSM0 := {}
Local nX	:= 0


dbSelectArea("SM0")
nRecnoM0 := RECNO()
dbGoTop()

While !EOF()
	If SM0->M0_CODIGO==cEmpAnt
		AADD(aCNPJSM0,{Alltrim(SM0->M0_CODFIL),SM0->M0_CGC})
	EndIf
	dbSelectArea("SM0")
	dbSkip()
EndDo

If lBl1

	For nx := 1 to len(aCNPJSM0)
		cQuery := " SELECT F3_CODRSEF,F3_DESCRET, * FROM "+RetSqlName("SF3")+" (NOLOCK) WHERE F3_CODRSEF NOT IN ( '','100','101','102') "
		//cQuery := " SELECT F3_CODRSEF,F3_DESCRET, * FROM "+RetSqlName("SF3")+" (NOLOCK) WHERE F3_CODRSEF IN ('302','306') "
		//cQuery += " AND D_E_L_E_T_ = '' AND LEFT(F3_EMISSAO,4) >= '2022' AND F3_FILIAL = '"+Alltrim(aCNPJSM0[Nx][1])+"' "
		cQuery += " AND D_E_L_E_T_ = '' AND F3_EMISSAO = '"+Dtos(Date()-1)+"' AND F3_FILIAL = '"+Alltrim(aCNPJSM0[Nx][1])+"' "
		cQuery += " ORDER BY F3_EMISSAO "

		If (Select("QRY") <> 0)
			dbSelectArea("QRY")
			dbCloseArea()
		EndIf
		
		TCQuery cQuery NEW ALIAS "QRY"

		_cMsgCab	:= ""
		_cMsg	:= ""
		
		dbSelectArea("QRY")
		dbGoTop()
		If QRY->(!EOF())
			_cMsgCab	+= "<P>CONCILIAÇÃO AGRICOPELXSEFAZ</P>"
			_cMsgCab	+= "<table border='1'>"
			_cMsgCab	+= "<tr>"
			_cMsgCab	+= "<td>FILIAL</td>"
			_cMsgCab	+= "<td>NOTA FISCAL</td>"
			_cMsgCab	+= "<td>SÉRIE</td>"
			_cMsgCab	+= "<td>TIPO</td>"
			_cMsgCab	+= "<td>ESPÉCIE</td>"
			_cMsgCab	+= "<td>DT EMISSÃO</td>"
			_cMsgCab	+= "<td>DT CANCELAMENTO</td>"
			_cMsgCab	+= "<td>STATUS NA SEFAZ</td>"
			_cMsgCab	+= "<td>CHAVE NFE</td>"
			_cMsgCab	+= "</tr>"
		
			While QRY->(!EOF())
					
				_cMsg	+= "<tr>"
				_cMsg	+= "<td>"+QRY->F3_FILIAL+"</td>"
				_cMsg	+= "<td>"+QRY->F3_NFISCAL+"</td>"
				_cMsg	+= "<td>"+QRY->F3_SERIE+"</td>"
				_cMsg	+= "<td>"+QRY->F3_TIPO+"</td>"
				_cMsg	+= "<td>"+'NF-e'+"</td>"
				_cMsg	+= "<td>"+DTOC(STOD(QRY->F3_EMISSAO))+"</td>"
				_cMsg	+= "<td>"+DTOC(STOD(QRY->F3_DTCANC))+"</td>"
				_cMsg	+= "<td>"+ALLTRIM(QRY->F3_DESCRET)+"</td>"
				_cMsg	+= "<td>"+QRY->F3_CHVNFE+"</td>"
				_cMsg	+= "</tr>"
		
				dbSelectArea("QRY")
				dbSkip()
			EndDo
		EndIf

		If !empty(_cMsg)
			_cMsg	+= "</table>"
			_cMsg := _cMsgCab + _cMsg
		Else
			_cMsg	:= IIF(EMPTY(_cMsg),"NENHUMA INCONSISTÊNCIA ENCONTRADA",_cMsg)		
		EndIf
		
		If (Select("QRY") <> 0)
			dbSelectArea("QRY")
			dbCloseArea()
		EndIf
		
		cEnv := " SELECT ZZR_EMAIL FROM "+RetSqlName("ZZR")+" WHERE ZZR_FILIAL = '"+Alltrim(aCNPJSM0[Nx][1])+"' AND "
		cEnv += " ZZR_EVENTO = 'NOTA_REJEITADA' AND D_E_L_E_T_ = '' "

		If (Select("QRX") <> 0)
			dbSelectArea("QRX")
			dbCloseArea()
		EndIf
		
		TCQuery cEnv NEW ALIAS "QRX"
		While QRX->(!EOF())
			_cEmail += Alltrim(QRX->ZZR_EMAIL)+";"
			QRX->(DBSKIP())
		EndDo
		_cSubject	:= "NFS's REJEITADAS E DENEGADAS FILIAL "+Alltrim(aCNPJSM0[Nx][1])+" " 

		// TRANSMITE WORKFLOW
		If !Empty(_cEmail)
			lEnvioMail := SendMail(_cFrom, Substring(_cEmail,1,len(_cEmail)-1),"", _cSubject, _cMsg,"" )
			_cEmail := ""
		EndIf
	Next Nx	
EndIf


Return

// Envio de E-mail, alterado para essa funçã devido a poder escolher 
// o campo FROM
Static Function SendMail(cFrom, cTo, cCC, cSubject, cMsg, cAttach)
********************************************************************

	Local cServer    := GetMV("MV_RELSERV"),;
		  cAccount   := GetMV("MV_RELACNT"),;
		  cPassword  := GetMV("MV_RELPSW"),;
		  lAutentica := GetMv("MV_RELAUTH")
	Local lEmOk, cError    
	
	Begin Sequence 
	
	// conout('OpenSendMail')
	
	If !Empty(cServer) .and. !Empty(cAccount)
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lEmOk
		If lEmOk
			If lAutentica
				If !MailAuth(cAccount, cPassword)
					DISCONNECT SMTP SERVER
					MsgInfo("Falha na Autenticacao do Usuario","Alerta")
					lEmOk := .F.
					Break
				EndIf
			EndIf
				
			If cAttach <> Nil
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg ATTACHMENT cAttach Result lEmOk
			Else
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg Result lEmOk
			Endif
				
			If !lEmOk
				GET MAIL ERROR cError
				// Conout("Erro no envio de Email - "+cError+" O e-mail '"+cSubject+"' não pôde ser enviado.", "Alerta")
			Else
				//MsgInfo(STR0046, STR0056)//
				// Conout("E-mail enviado com sucesso - "+cTo)
			EndIf
			DISCONNECT SMTP SERVER
		Else
			GET MAIL ERROR cError
			DISCONNECT SMTP SERVER
			// Conout("Erro na conexão com o servidor de Email - "+cError+"O e-mail '"+cSubject+"' não pôde ser enviado.","Alerta")
		EndIf
	Else
		// Conout("Não foi possível enviar o e-mail porque o as informações de servidor e conta de envio não estão configuradas corretamente.", "Alerta")  
		lEmOk := .F.
	EndIf
	
	End Sequence

Return lEmOk
