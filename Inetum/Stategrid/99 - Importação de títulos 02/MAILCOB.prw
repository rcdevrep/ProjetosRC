#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#include 'tbiconn.ch'
#include 'topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MAILCOB ºAutor  ³Jader Bertoº Data ³  03/01/25     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para envio de e-mail com anexos.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATEGRID                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAILCOB(cPara,cCopia,cConhCopia,cAssunto,cDe,cTexto,lHtml,aArqs)
Local lHtml		:= Iif(ValType(lHtml)="U",.T.,lHtml)
Local lOk		:= .F.
Local cAccount	:= GetMv("MV_XUSUCOB")
Local cPassword := GetMv("MV_XSENCOB")
Local cServer	:= GetMv("MV_XXSEREM")
Local nPorta	:= GetMV("MV_XXPORTM")
Local oMail		:= TMailManager():New()
Local nRet		:= 0
Local oMessage	:= TMailMessage():New()
Local lSSL        	:= SuperGetMV("MV_RELSSL" , .F., .F.)  	// VERIFICA O USO DE SSL
Local lTLS        	:= SuperGetMV("MV_RELTLS" , .F., .F.)  	// VERIFICA O USO DE TLS
Local nI 		:= 0
Default aArqs	:= {}

	oMail:SetUseSSL(lSSL)
	oMail:SetUseTLS(lTLS)
	oMail:Init("",cServer,cAccount,cPassword,,nPorta)
	nRet := oMail:SMTPConnect()
	If nRet == 0
		nRet := oMail:SmtpAuth(cAccount,cPassword)
		If nRet == 0
			//Limpa o objeto
			oMessage:Clear()   
			//Popula com os dados de envio
			oMessage:cFrom              := cAccount
			oMessage:cTo                := cPara
			oMessage:cCc                := cCopia
			oMessage:cBcc               := cConhCopia
			oMessage:cSubject           := cAssunto
			oMessage:cBody              := cTexto
			//Adiciona um attach
			For nI := 1 To Len(aArqs)
				If oMessage:AttachFile(aArqs[nI]) < 0
					Help("",1,"AVG0001056",,"Erro ao anexar o arquivo ["+AllTrim(aArqs[nI])+"].",2,0)
					Return .F.
				EndIf
			Next
			nRet := oMessage:Send( oMail )
			If nRet <> 0
				Help("",1,"AVG0001056",,"Error: "+oMail:GetErrorString( nRet ),2,0)
			    Return .F.
			EndIf
		Else
			Help("",1,"AVG0001056",,"Error: "+oMail:GetErrorString( nRet ),2,0)
		    Return .F.
		EndIf
	Else
		Help("",1,"AVG0001056",,"Error: "+oMail:GetErrorString( nRet ),2,0)
		Return .F.
	EndIf
	oMail:SmtpDisconnect()

Return (.T.)
