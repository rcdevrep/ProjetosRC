#include 'totvs.ch'

/*/{Protheus.doc} envMailA
(long_description)
@author SLA
@since 09/01/2019
@version 1.0
@example
Função para enviar email
@see (links_or_references)
/*/
User function envMailA(cEmail,cAssunto,cMensagem,nOpcao,cCCO,cBcc,aAtt,cFile)

	#DEFINE EMAIL_SMTPSERVER       "smtp.agricopel.com.br" //Alltrim(SuperGetMv("MV_RELSERV",.F.,"smtp.agricopel.com.br",))
	#DEFINE EMAIL_ACCOUNT          "protheus@agricopel.com.br" //Alltrim(SuperGetMv("MV_RELACNT",.F.,"protheus@agricopel.com.br",))
	#DEFINE EMAIL_PASSWORD         "123!@#as" //Alltrim(SuperGetMv("MV_RELAPSW",.F.,"123!@#as",))

	Local oMail 	:= TMailManager():NEW()
	Local nRet 		:= 0
	Local nX 		:= 0
	Local cBody		:= ""

	Default nOpcao 	:= 0
	Default cCCO	:= ""
	Default cBcc	:= ""
	Default cFile	:= ""
	Default aAtt	:= {}

	//Usa SSL-TSL
	oMail:SetUseTLS( SuperGetMv("MV_RELAUTH",.T.,.T.,) )

	//Inicia Servidor
	oMail:Init( "", EMAIL_SMTPSERVER, EMAIL_ACCOUNT, EMAIL_PASSWORD,0,587)

	// Informa o Time Out
	nret := oMail:SetSMTPTimeout( 60 ) //1 min

	//Se der erro no SetSMTPTimeout
	If nRet == 0
		conout( "Time Out configurado com Sucesso" )
	Else
		If nOpcao == 1
			MsgInfo("Problema ao configurar Time out: "+oMail:GetErrorString( nret ))
		EndIf
		conout( oMail:GetErrorString( nret ) )
		Return .F.
	Endif
	// Realiza a conexao do SMTP
	Conout( "realiza a conexao SMTP" )
	nret := oMail:SMTPConnect()
	//Se der erro no SMTPConnect
	If nRet == 0
		conout( "Conectando o Servidor de Email com Sucesso" )
	Else
		If nOpcao == 1
			MsgInfo("Problema ao Conectar SMTP: "+oMail:GetErrorString( nret ))
		EndIf
		conout( oMail:GetErrorString( nret ) )
		Return .F.
	Endif

	// Realiza autenticacao no servidor
	nret := oMail:smtpAuth(EMAIL_ACCOUNT, EMAIL_PASSWORD)
	//Se der erro no smtpAuth
	If nRet == 0
		conout( "Smtp autenticado" )
	Else
		If nOpcao == 1
			MsgInfo("Problema na autenticação: "+oMail:GetErrorString( nret ))
		EndIf
		conOut("[ERROR]Falha ao autenticar: " + oMail:getErrorString(nRet))
		oMail:smtpDisconnect()
		Return .F.
	Endif

	//Se não houve erro envia Email
	If nRet == 0
		If File(cFile)
			cBodyHtml	:= WFLoadFile(cFile)
			cBody		:= cBodyHtml
		EndIf

		oMailMessage := tMailMessage():new()
		oMailMessage:clear()
		oMailMessage:cFrom    := EMAIL_ACCOUNT
		oMailMessage:cTo      := alltrim(cEmail)
		oMailMessage:cCC      := cCCO
		oMailMessage:cBcc     := cBcc
		//Assunto do e-mail
		oMailMessage:cSubject := cAssunto
		//GRAVA OS DADOS DO HTML NO CORPO DO E-MAIL
		oMailMessage:cBody   := Iif(Empty(cBody),cMensagem,cBody)

		// Adiciona anexos ao email
		If Len(aAtt) > 0
			For _nk := 1 to Len(aAtt)
				Conout("Adiciona Anexo.")
				Conout(aAtt[_nk])
				If oMailMessage:AttachFile( aAtt[_nk] ) < 0
					Conout( "Erro ao atachar o arquivo" )
					Return( .F. )
				Else
					//adiciona uma tag informando que um attach e o nome do arq
					oMailMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+aAtt[_nk])
				EndIf
			Next _nk
		EndIf

		//FIM DAS INFORMAÇÕES DO CORPO DO E-MAIL
		nErr := oMailMessage:send(oMail)
		//Se houve erro no envio
		If nErr <> 0
			Conout("[ERROR]Falha ao enviar: " + oMail:getErrorString(nErr))
			oMail:smtpDisconnect()
			Conout("E-mail automatico não enviado. Comunique o setor de TI ")
			Return .F.
		Else
			If nOpcao == 1
				MsgInfo("Enviado E-mail para: "+Alltrim(cEmail))
			EndIf
		Endif
	Else
		Conout( nret )
		Conout( oMail:GetErrorString( nret ) )
		Return .F.
	Endif
	//Disconecta
	oMail:SmtpDisconnect()

Return .T.

// Html padrão para inclusão do erro
User Function xHtmlPad(cTitulo,cError)
	
	// gera padrao
	cHtml := ''
	cHtml += '<HTML><HEAD><TITLE></TITLE>'
	cHtml += '<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
	cHtml += '<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
	cHtml += '<BODY>'
	cHtml += '<TABLE width="650" border=1 bordercolor="#000000" align="center" cellPadding=3 cellSpacing=0 background="">'
	cHtml += '<TBODY>'
	cHtml += '    <TR>'
	cHtml += '      <TD height="110" align="center" valign="middle" bgcolor="#FFFFFF"><TABLE width="100%" border=0 align="center" cellPadding=3 cellSpacing=0 background="">'
	cHtml += '        <TBODY>'
	cHtml += '          <TR>'
	cHtml += '            <TD align="center" valign="middle" bgcolor="#FFFFFF"><img src="http://agricopel.com.br/img/logo_agricopel.jpg	" width="176" height="37	" alt=""/></TD>'
	cHtml += '            <TD height="110" align="center" valign="middle" bgcolor="#FFFFFF"><FONT color=#000 style="font-size: 22px"><strong>'+cTitulo+'</strong></FONT></TD>'
	cHtml += '          </TR>'
	cHtml += '        </TBODY>'
	cHtml += '      </TABLE></TD>'
	cHtml += '    </TR>'
	cHtml += '  </TBODY>'
	cHtml += '</TABLE>'
	cHtml += '<TABLE width="650" border=0 align="center" cellPadding=0 cellSpacing=0 background="" bgColor=#elelel>'
	cHtml += '  <TBODY>'
	cHtml += '    <TR>'
	cHtml += '      <TD width="110" height="3" bgcolor="#000000" style="font-size: 2px">&nbsp;</TD>'
	cHtml += '      <TD height="3" bgcolor="#000000" style="font-size: 2px">&nbsp;</TD>'
	cHtml += '    </TR>'
	cHtml += '  </TBODY>'
	cHtml += '</TABLE>'
	cHtml += '<TABLE width="650" border=1 bordercolor="#000000" align="center" cellPadding=5 cellSpacing=0 background="" bgColor=#elelel>'
	cHtml += '  <TBODY>'
	cHtml += '    <TR>'
	cHtml += '      <TD width="100%">'+cError+'</TD>'
	cHtml += '    </TR>'
	cHtml += '  </TBODY>'
	cHtml += '</TABLE>'
	cHtml += '<TABLE width="650" border=0 align="center" cellPadding=0 cellSpacing=0 background="" bgColor=#elelel>'
	cHtml += '  <TBODY>'
	cHtml += '    <TR>'
	cHtml += '      <TD width="110" height="1" bgcolor="#000000" style="font-size: 2px">&nbsp;</TD>'
	cHtml += '      <TD  height="1" bgcolor="#000000" style="font-size: 2px">&nbsp;</TD>'
	cHtml += '    </TR>'
	cHtml += '  </TBODY>'
	cHtml += '</TABLE>'
	cHtml += '<TABLE width="650" border=1 bordercolor="#000000" align="center" cellPadding=5 cellSpacing=0 background="" bgColor=#elelel>'
	cHtml += '  <TBODY>'
	cHtml += '    <TR>'
	cHtml += '      <TD width="100%">Colaborador Inclus&atilde;o/Altera&ccedil;&atilde;o: '+cUserName+'<br>Ambiente: '+ GetEnvServer() +'</TD>'
	cHtml += '    </TR>'
	cHtml += '  </TBODY>'
	cHtml += '</TABLE>'
	cHtml += '</BODY>'
	cHtml += '</HTML>'

Return