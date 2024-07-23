#include 'Totvs.ch'
#Include "AP5MAIL.CH"
#Include "TBICONN.CH"





/***************************************************
*	INICIO FUN��ES PARA O FTP COM A MAXTON	   *
****************************************************/

//-------------------------------------------------------------------
/*/{Protheus.doc} KEPENFTP
Fun��o para enviar todos arquivos pendentes para FTP da Maxton

@author J�NIOR CONTE
@since 15/12/2022
@version 1.0

Recebe:
_lScheduler = .T. - Rotina Disparada pelo Scehduler / .F. - Rotina Disparada Manualmente

Retorna:
_aRet[1] = .T. - Fez Upload dos arquivos com sucesso. / .F. - Problema ao fazer Upload
_aRet[2] = Mensagem para usu�rio 

/*/
//-------------------------------------------------------------------
***********************************
User Function XAG0099(_lScheduler)
***********************************
***********************************
/*

Na pasta do FTP da MaxTon existe tres pastas fixas para troca dos arquivos:

enviados = Arquivos enviados pelo ERP 
gerados  = Arquivos de retorno do WMS para leitura no ERP


Existe tamb�m um outro diret�rio no FTP (backup) onde os arquivos processados e copiados
s�o movidos para os mesmos.

*/

// Retorno de fun��o
Local _aRet := {.T.," "}

Local _cDirCREC  := SUPERGETMV("ML_XDIRPDR",.F.,'C:\MAXTON\') //local padrao
Local _cEmailArq := SuperGetMV("MV_XMAXARQ",.F.,"") //Emails que receber�o o aquivo EDI 


// Parametros para conex�o do FTP Maxton
Local cFTPServ := SUPERGETMV("MV_XPFTPSE",.F.,'ftp.maxtonlog.com.br') // Endere�o do Servidor FTP Maxton
Local nFTPPort := SUPERGETMV("MV_XPFTPPO",.F.,21) // Porta do Servidor FTP Maxton
Local cFTPUser := SUPERGETMV("MV_XPFTPUS",.F.,"agricopel") // Usu�rio para FTP Maxton
Local cFTPPass := SUPERGETMV("MV_XPFTPPA",.F.,"agri@2022") // Senha para FTP Maxton
Local cFTPDire := "/enviados/" //SUPERGETMV("MV_XPFTPDI",.F.,' ') // Diret�rio raiz do FTP Maxton
//Local cFTPDiBk := SUPERGETMV("ML_XPFTPDB",.F.,' ') // Diret�rio de backup do FTP Maxton (para arquivos processados)

// Auxiliares
Local _aArqs 	:= {}

Local i		 	:= 0
Local _cFile	:= ""

// Metodo para conectar FTP
Local _oFTP := FTPMAXTON():New()
Local lEnvTeste := "_HOM" $ GetEnvServer() .Or. "_MIG" $ GetEnvServer()

// Padr�o Disparado pelo menu
Default _lScheduler := .F.

// Auxiliares para o Log
PRIVATE cFileLog := ""
PRIVATE cPath := ""

//Se For base de Homologa��o nao envia para o Ftp 
If  lEnvTeste
	Return 
Endif 

DIRLIDO := "old\"
DIRERRO := "err\"
DIRALER := "new\"

// Diret�rios para remessa e retorno
 DIRREM  := "remessa\"

 //CpyT2S(_cDirCREC, "\Maxton\remessa\new\")

// Verifica se existe dirert�rio no ERP para envio ao FTP
If !ExistDir("\maxton\remessa\new\")
 	_aRet[1] := .F.
 	_aRet[2] += "Diretorio no ERP de envio para FTP nao localizado \maxton\remessa\new\ - [XAG0099]"
 	If !_lScheduler
 		MsgStop(_aRet[2],"[XAG0099] - Problema:")
 	EndIF
 	Return(_aRet)
EndIF

// Verifica se existe dirert�rio no ERP para envio ao FTP
If !ExistDir("\maxton\remessa\old\")
 	_aRet[1] := .F.
 	_aRet[2] += "Diretorio no ERP de arquivos enviados para FTP nao localizado \maxton\remessa\old\ - [XAG0099]"
 	If !_lScheduler
 		MsgStop(_aRet[2],"[XAG0099] - Problema:")
 	EndIF
 	Return(_aRet)
EndIF

// Confirma��o do usu�rio
If !_lScheduler
	If !MsgYesNo("Confirma Enviar Todos os Arquivos Pendentes para FTP da Maxton?","[XAG0099] - Confirma��o")
		_aRet[1] := .T.
	 	_aRet[2] += "Cancelado Pelo Usu�rio - [XAG0099]"+cEOL
	 	Return(_aRet)	
	EndIF
EndIF


// Obtem os arquivos do diret�rio
_aArqs 		:= Directory( "\maxton\remessa\new\" +  '*.*' )



// Sem Arquivos para Enviar
If Len(_aArqs) = 0
	_aRet[1] := .T.
 	_aRet[2] += "Sem Arquivos no ERP \maxton\remessa\new\ Para Enviar ao FTP Maxton. - [XAG0099]"
 	If !_lScheduler
 		MsgInfo(_aRet[2],"[XAG0099] - Sem Arquivo:")
 	EndIF
 	
 	//termina o semaforo 
	//UnLockByName(xFilial("SF2")+"KEPENFTP",.T.,.T.)
 	
 	Return(_aRet)
EndIF

// Conex�o FTP Maxton
If !_oFTP:ConectarFTP(cFTPServ,; // Endere�o
					  nFTPPort,; // Porta
					  cFTPUser,; // Usu�rio
					  cFTPPass,; // Senha
					  ,; // Numero de tentativas
					  .T.) // Endere�o � por IP?
	
	_aRet[1] := .F.
 	_aRet[2] += "Erro ao Conectar FTP ("+cFTPServ+":"+alltrim(str(nFTPPort))+") - [XAG0099]."
 	If !_lScheduler
 		MsgStop(_aRet[2],"[XAG0099] - Problema:")
 	else
		EmailErro( "Erro conex�o ftp Maxton", _aRet[2] )

	endif
 	
 	//termina o semaforo 
	//UnLockByName(xFilial("SC9")+"XAG0099",.T.,.T.)
 	
 	//Return(_aRet)				  

EndIF


// Envia todos os arquivos da pasta para o FTP
For i := 1 to len(_aArqs)
	
	// Nome do arquivo
	_cFile := alltrim(_aArqs[i][1])
	
	If !_oFTP:UpLoadFTP("\maxton\remessa\new\" + _cFile,; // arquivo o ser enviado para FTP
					IIF(!Empty(cFTPDire),cFTPDire,"/Enviados/")+_cFile) // arquivo destino no FTP
						
	
		_aRet[1] := .F.
	 	_aRet[2] += "Erro ao Enviar Arquivo (\maxton\remessa\new\"+_cFile+") para FTP - [XAG0099]."

		 //gravo status no documento

         /*
		 dbSelectArea("SF2")
		 dbSetOrder(1)
		 If dbSeek( xFilial("SF2") + substr(_cFile, 1, TamSX3("F2_DOC")[1] )  +  substr(_cFile, 10, TamSX3("F2_SERIE")[1] ) )
			RecLock("SF2", .F.)
				SF2->F2_XSTMULT := "0"
			SF2->(MsUnlock())
		 EndIf
         */

		 Copy File &("\maxton\remessa\new\"+_cFile) To &("\maxton\remessa\err\"+_cFile)
		 FErase("\maxton\remessa\new\" +_cFile)

		 FErase(_cDirCREC +_cFile)	

		//Envia arquivo para a MAxton
		If !Empty(_cEmailArq)
			_cAttach := "\maxton\remessa\err\"+_cFile
			EmailArq(_cAttach,_cEmailArq,_cFile, .T.)
		Endif 
	 	
	 	// ATEN��O: N�o movo o arquivo para pastas de erro para o pr�prio usu�rio poder enviar novamente o arquivo
	
	Else
	
		// Move o arquivo para pasta de controle do ERP de arquivo enviados para o FTP
		//gravo status no documento

        /*
		 dbSelectArea("SF2")
		 DbSetOrder(1)
		 If dbSeek( xFilial("SF2") + substr(_cFile, 1, TamSX3("F2_DOC")[1] )  +  substr(_cFile, 10, TamSX3("F2_SERIE")[1] ) )
			RecLock("SF2", .F.)
				SF2->F2_XSTMULT := "1"
			SF2->(MsUnlock())
		 EndIf
         */
	 	
		Copy File &("\maxton\remessa\new\"+_cFile) To &("\maxton\remessa\old\"+_cFile)
		FErase("\maxton\remessa\new\" +_cFile)



		//Envia arquivo para a MAxton
		If !Empty(_cEmailArq)
			_cAttach := "\maxton\remessa\old\"+_cFile
			EmailArq(_cAttach,_cEmailArq,_cFile,.F.)
		Endif 


		FErase(_cDirCREC +_cFile)		
	
	EndIF					

Next i

// Desconecta
_oFTP:DesconecFTP(2)

// Mostra o log de processamento para usu�rio
If !_lScheduler
	
	AutoGrLog(replicate("-",80))
	AutoGrLog("Envio de Arquivos para FTP MaxTon: "+IIF(_aRet[1],"SUCESSO","PROBLEMA OCORREU"))
	AutoGrLog(replicate("-",80))
	AutoGrLog(_aRet[2])
	
	// Mostra o log
	cFileLog := NomeAutoLog()
	MostraErro(cPath,cFileLog)
	
EndIf 


//termina o semaforo 
//UnLockByName(xFilial("SC9")+"XAG0099",.T.,.T.)

Return(_aRet)



//fun��o para enviar email quando houver falha na conexao com FTP.
Static Function EmailErro( _cSubject, _cTexto)

		_cTo := SuperGetMV("MV_XERRFTP",.F.,"suporte.sistemas@agricopel.com.br")

 		oProcess := TWFProcess():New("WORKFLOW", "NOTIFICA")
        oProcess:NewTask("NOTIFICA",'\workflow\WFERROFTP.htm')
        oHtml     := oProcess:oHtml
        oHtml:ValByName("Titulo", "Workflow de Notifica��o (" + DTOC(Date()) + " - " + Time() + ")")

        oHtml:ValByName( "MENSAGEM"	, "Integra��o Protheus x Maxton")

      

        oHtml:ValByName( "TEXTO", _cTexto + "<br>" )

        oProcess:ClientName(cUserName)
        oProcess:cTo := _cTo 
        oProcess:cSubject := "Workflow de Notifica��o - Falha Conex�o FTP MaxTon (" + DTOC(Date()) + " - " + Time() + ")"
        oProcess:Start()
        oProcess:Free()
Return		



//fun��o para enviar email quando houver falha na conexao com FTP.
Static Function EmailArq( _cAttach, _cTo , _cFile,_lErro)

		Default _lErro := .T.

		Local _cSubject := ""
		//_cTo := SuperGetMV("MV_XMAXARQ",.F.,"suporte.sistemas@agricopel.com.br")

 		oProcess := TWFProcess():New("WORKFLOW", "NOTIFICA")
        oProcess:NewTask("NOTIFICA",'\workflow\WFERROFTP.htm')
        oHtml     := oProcess:oHtml
		If !(_lErro)
			oHtml:ValByName("Titulo", "Workflow de Notifica��o (" + DTOC(Date()) + " - " + Time() + ")")
			oHtml:ValByName( "MENSAGEM"	, "Envio de Pedidos Protheus x Maxton")
			oHtml:ValByName( "TEXTO", "Arquivo	"+_cFile+" enviado para FTP Maxton - [XAG0099]." + "<br>" )

			_cSubject := "Envio de Pedidos p/ FTP MaxTon (" + DTOC(Date()) + " - " + Time() + ")"
		Else

			oHtml:ValByName("Titulo", " ERRO  - Workflow de Notifica��o (" + DTOC(Date()) + " - " + Time() + ")")
			oHtml:ValByName( "MENSAGEM"	, "  ERRO  - Envio de Pedidos Protheus x Maxton")
			oHtml:ValByName( "TEXTO", " *** ERRO ***  - Arquivo	"+_cFile+" enviado para FTP Maxton - [XAG0099]." + "<br>" )
			_cSubject := "Houve erro no Envio de Pedidos p/ FTP MaxTon (" + DTOC(Date()) + " - " + Time() + ")"
		Endif 

        oProcess:ClientName(cUserName)
        oProcess:cTo := _cTo 
        oProcess:cSubject := "Envio de Pedidos p/ FTP MaxTon (" + DTOC(Date()) + " - " + Time() + ")"
		oProcess:AttachFile(_cAttach/*"\impORC\"+cFile+".pdf"*/)
        oProcess:Start()
        oProcess:Free()
Return	



/***************************************************
*	 FIM FUN��ES PARA O FTP COM A Maxton		   *
****************************************************/

