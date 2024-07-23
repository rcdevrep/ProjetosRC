#INCLUDE "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"

/*
########################################################
### Rotina para importação do XML da conta de e-mail ###
### Thiago SLA - 16/06/2016							 ###
########################################################
*/

User Function ImpMail()

Local cUser := "", cPass := "", cRecvSrv := ""
Local cIniFile := "", cIniConf := "", cMsg := "", cProtocol := ""
Local nMessages := 0, nX := 0, nRecv := 0, nTimeout := 0
Local lConnected := .F., lIsPop := .T., lRecvSec := .F.
Local xRet
Local oServer, oMessage

Local lWeb := .F.
Local aFileAtch := {}
Local cServer
Local lOk := .T.
Local lRelauth
Local cFrom
Local cConta
Local cSenhaa
Local cIniFile
Local cStartPath
Local nMessages		:= 0
Local aContas		:= {} //{{'thiagoleonardo@sapo.pt'}} // ZZ4_EMAIL
Local lLoop := .F.
Local nAnexos := 0, cAttach := ""

Local _cDlocal	:= '\IMPMAIL'
Local aDirL		:= Directory(_cDlocal,"D")

//VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE
If Select("SX6") == 0
	lWeb := .T.
	RpcSetType(3)
	RpcSetEnv("01","01")
EndIf

//############################################################################
if select("QRY") <> 0
	QRY-> (DBCLOSEAREA())
ENDIF

cQuery := " SELECT * FROM " + RetSQLName("ZZ4") + " "
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND ZZ4_MSBLQL <> '1' "
cQuery += " AND ZZ4_EMP = "+cEmpAnt+" " // Empresa
cQuery += " AND ZZ4_FIL = "+cFilAnt+" " // Filial
cQuery += " ORDER BY ZZ4_EMP,ZZ4_FIL "

TcQuery cQuery New Alias "QRY"

WHILE !QRY->(EOF())
	
	aadd(aContas,{QRY->ZZ4_EMP,; 		// [1]  Empresa
	QRY->ZZ4_FIL,; 		// [2]  Filial
	QRY->ZZ4_EMAIL,; 	// [3]  E-mail
	QRY->ZZ4_USER,; 	// [4]  Usuário
	QRY->ZZ4_SENHA,; 	// [5]  Senha
	QRY->ZZ4_SERVER,; 	// [6]  Servidor
	QRY->ZZ4_PORTA,; 	// [7]  Porta do servidor
	QRY->ZZ4_POP,; 		// [8]  Pop 1- Sim 2- Não
	QRY->ZZ4_AUTENT,; 	// [9]  Autenticação 1- Sim 2- Não
	QRY->ZZ4_SSL,; 		// [10] Usa SSL 1- Sim 2- Não
	QRY->ZZ4_TLS}) 		// [11] Usa TLS 1- Sim 2- Não
	QRY->(DbSkip())
	
ENDDO

nTimeout := 60  // define the timout to 60 seconds

cIniFile	:= GetADV97()
cStartPath 	:= GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\ENTRADA\'

// Cria as pastas no Servidor se não existir
IF LEN(Directory("\IMPMAIL","D") ) == 0
	Makedir("\IMPMAIL") // Diretório mestre
ENDIF

FOR na := 1 to Len(aContas)
	IF LEN(Directory("\IMPMAIL\Empresa"+aContas[na][1]+"","D") ) == 0 // Diretório da Empresa
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"")
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"") // Diretório da Filial
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"\Novos")
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"\Importados")
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"\LOG")
	ELSEIF LEN(Directory("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"","D") ) == 0 // Se não existir o diretório da Filial
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"") // Diretório da Filial
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"\Novos")
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"\Importados")
		Makedir("\IMPMAIL\Empresa"+aContas[na][1]+"\Filial"+aContas[na][2]+"\LOG")
	ENDIF
NEXT

For zX:=1 To Len(aContas)
	
	IF aContas[zx][8] == '1'
		cProtocol := "POP3"
	ELSE
		cProtocol := "IMAP"
	ENDIF
	
	cIniFile := GetSrvIniName()
	cIniConf := GetPvProfString( "MAIL", "Protocolo", "", cIniFile )
	
	xRet := WritePProString( "MAIL", "Protocolo", cProtocol, cIniFile )
	If xRet == .F.
		cMsg := "Não foi possível definir " + cProtocol + " em " + cIniFile + CRLF
		conout( cMsg )
		return
	EndIf
	
	oServer := TMailManager():New()
	
	IF aContas[zx][10] == '1'
		oServer:SetUseSSL( .T. )
	ELSE
		oServer:SetUseSSL( .F. )
	ENDIF
	
	IF aContas[zx][11] == '1'
		oServer:SetUseTLS( .T. )
	ELSE
		oServer:SetUseTLS( .F. )
	ENDIF

	// once it will only receives messages, the SMTP server will be passed as ""
	// and the SMTP port number won't be passed, once it is optional
	//	xRet := oServer:Init( SERVIDOR, "", USUÁRIO, SENHA, PORTA )
	xRet := oServer:Init(ALLTRIM(aContas[zx][6]), "", ALLTRIM(aContas[zx][4]), ALLTRIM(aContas[zx][5]), aContas[zx][7] )
	If xRet != 0
		cMsg := "Não foi possível inicializar o servidor de e-mail: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		RestoreConf( cIniConf, cIniFile )
		return .F.
	EndIf
	
	// the method works for POP and IMAP, depending on the INI configuration
	xRet := oServer:SetPOPTimeout( nTimeout )
	If xRet != 0
		cMsg := "Não foi possível definir " + cProtocol + " tempo esgotado " + cValToChar( nTimeout )
		conout( cMsg )
	EndIf
	
	IF aContas[zx][8] == '1' 
		xRet := oServer:POPConnect()
	ELSE
		xRet := oServer:IMAPConnect()
	ENDIF
	
	If xRet <> 0
		cMsg := "Não foi possível conectar em " + cProtocol + " servidor: " + oServer:GetErrorString( xRet )
		alert(oServer:GetErrorString( xRet )) 
		conout( cMsg )
		ALERT(cMsg)
	else
		lConnected := .T.
	EndIf
	
	If lConnected == .T.

		oServer:GetNumMsgs( @nMessages )
		
		cMsg := "Número de mensagens: " + cValToChar( nMessages )
		conout( cMsg )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conta quantas mensagens existem                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nMessages > 0
			
			oMessage := TMailMessage():New()
			
			conout(" ")
			conout(Replicate("=",80))
			conout(OemtoAnsi("A conta "+aContas[zx][10]+" contem "+StrZero(nMessages,8)+" mensagem(s)") ) //###
			conout(Replicate("=",80))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recebe as mensagens e grava os arquivos XML           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nXml := 0
			For nX := 1 to nMessages
				If lLoop
					lLoop := .F.
				EndIf
				aFileAtch := {}
				
				cMsg := "Receiving message " + cValToChar( nX )
				conout( cMsg )
				
				oMessage:Clear()
				xRet := oMessage:Receive( oServer, nX )
				If xRet <> 0
					cMsg := "Não foi possível obter mensagem " + cValToChar( nX ) + ": " + oServer:GetErrorString( xRet )
					conout( cMsg )
					
					If xRet == 6 // error code for "No Connection"
						//RestoreConf( cIniConf, cIniFile )
						Loop
					EndIf
				EndIf
				
				nAnexos := oMessage:GetAttachCount()
				
				If lLoop
					Loop
				EndIf
				
				For nY := 1 to nAnexos
					cStartPath 	:= "\IMPMAIL\Empresa"+aContas[ZX][1]+"\Filial"+aContas[ZX][2]+"\Novos\" //GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\ENTRADA\'
					aAttInfo := oMessage:GetAttachInfo( nY )
					
					If aAttInfo[1] == ""
						//cStartPath += "message." + SubStr( aAttInfo[2], At( "/", aAttInfo[2] ) + 1, Len( aAttInfo[2] ) )
						aAttInfo[1] := aAttInfo[4] //Spiller - Caso não consiga pegar o nome do anexo, pega o Nome do tipo de arquivo. 
						cStartPath += aAttInfo[1]
					else
						cStartPath += aAttInfo[1]
					EndIf
					
					If ".XML" $ Upper(aAttInfo[1]) .and. !(".PDF" $ Upper(aAttInfo[1])) .and. !(".DAT" $ Upper(aAttInfo[1])) .and. !(".JPG" $ Upper(aAttInfo[1])) .and. !(".PNG" $ Upper(aAttInfo[1]))
						
						conout( "Salvando anexo " + cValToChar( nY ) + ": " + cStartPath )
						cAttach := oMessage:GetAttach( nY )
						
						xRet := MemoWrite( cStartPath, cAttach )
						If !xRet
							conout( "Não foi possível salvar o anexo " + cValToChar( nY ) )
						EndIf
						
						nXml++
						ConOut(" ")
						ConOut(Replicate("=",80))
						ConOut("Recebido o arquivo " + aAttInfo[1]) //
						ConOut(Replicate("=",80))
						
						cStrAtch := Memoread(aAttInfo[1])
						
						CREATE oXML XMLSTRING cStrAtch
						//QUANDO TIVER 400 XML SAI DA ROTINA, SENAO ESTOURA O ARRAY DO XML
						If nXml == 400
							Return
						EndIf
					Else
						Ferase(aAttInfo[1])
					EndIf
				Next nY

				oServer:DeleteMsg( nX ) // deleta mensagem do servidor de e-mail
			Next nX
		Else
			Conout(Replicate("=",80))
			ConOut( Time()+" - Nao existem arquivos a serem recebidos" )
			Conout(Replicate("=",80))
		EndIf
		
		If lWeb
			RpcClearEnv()
		EndIf
		
		If aContas[zx][8] == '1' //lIsPop == .T.
			xRet := oServer:POPDisconnect()
		else
			xRet := oServer:IMAPDisconnect()
		EndIf
		
		If xRet <> 0
			cMsg := "Não foi possível desconectar " + cProtocol + " servidor: " + oServer:GetErrorString( xRet )
			conout( cMsg )
		EndIf
	EndIf
Next

RestoreConf( cIniConf, cIniFile )
Return

Static function RestoreConf( conf, iniFile )

Local xRet
Local cMsg := ""

If conf == ""
	xRet := DeleteKeyINI( "MAIL", "Protocol", iniFile )
else
	xRet := WritePProString( "MAIL", "Protocol", conf, iniFile )
EndIf

If xRet == .F.
	cMsg := "Could not restore configuration. Initial configuration: " + conf + CRLF
	conout( cMsg )
EndIf

RETURN

/*
#################################################
### Rotina para cadastro das contas de e-mail ###
#################################################*/

User Function CadMail()

AxCadastro("ZZ4","Cadastro das Contas de E-mail",".T.",".T.")

Return()