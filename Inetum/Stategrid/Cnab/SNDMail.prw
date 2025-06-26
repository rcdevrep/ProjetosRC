#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#include 'tbiconn.ch'
#include 'topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSNDMail บAutor  ณRafael Ramos Lavinasบ Data ณ  05/21/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para envio de e-mail com anexos.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ STATEGRID                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SNDMail(cPara,cCopia,cConhCopia,cAssunto,cDe,cTexto,lHtml,aArqs)
Local lHtml		:= Iif(ValType(lHtml)="U",.T.,lHtml)
Local lOk		:= .F.
Local cAccount	:= GetMv("MV_XXCTAEM")
Local cPassword := GetMv("MV_XXPSSEM")
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
					//Help("",1,"AVG0001056",,"Erro ao anexar o arquivo ["+AllTrim(aArqs[nI])+"].",2,0)
					Return .F.
				EndIf
			Next
			nRet := oMessage:Send( oMail )
			If nRet <> 0
				//Help("",1,"AVG0001056",,"Error: "+oMail:GetErrorString( nRet ),2,0)
			    Return .F.
			EndIf
		Else
			//Help("",1,"AVG0001056",,"Error: "+oMail:GetErrorString( nRet ),2,0)
		    Return .F.
		EndIf
	Else
		//Help("",1,"AVG0001056",,"Error: "+oMail:GetErrorString( nRet ),2,0)
		Return .F.
	EndIf
	oMail:SmtpDisconnect()

Return (.T.)


User Function TSTMail()
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"
	U_SNDMail("cladimir@korusconsultoria.com.br","","","Titulo","","Email de teste TSTMail",.F.,{})
	RESET ENVIRONMENT	
Return
