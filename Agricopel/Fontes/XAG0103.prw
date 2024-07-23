#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "MsObject.ch"


User Function XAG0103()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} KOM556
M�todo para Manipula��o de FTP

@author J�nior Conte
@since 15/12/22
@version 1.0

Documenta��o completa das Fun��es Padr�es de FTP
TDN: http://tdn.totvs.com/display/public/mp/FTP

/*/
//-------------------------------------------------------------------

Class FTPMAXTON
	Method New() Constructor
	Method ConectarFTP()
	Method DesconecFTP()
	Method ListaDirFTP()
	Method TrocaDirFTP()
	Method UpLoadFTP()
	Method DownloadFTP()
	Method ApagaArqFTP()
	Method RenomArqFTP()
Endclass            


Method New() Class FTPMAXTON
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} Conectar
M�todo para conectar em um ftp

@author J�nior Conte
@since 15/12/22
@version 1.0


Recebe:
cFTPServ - Nome do Servidor FTP                
nFTPPort - Porta para acesso ao Servidor FTP   
cFTPUser - Usuario para acesso ao Servidor FTP 
cFTPPass - Senha para acesso ao Servidor FTP   
nTenta   - Numero de Tentativas para conex�o  
lUsaIP   - Define se utiliza conex�o por IP    

Retorna:
lRet - .T. = Conectou / .F. = Erro conex�o


/*/
//-------------------------------------------------------------------

Method ConectarFTP(cFTPServ,nFTPPort,cFTPUser,cFTPPass,nTenta,lUsaIP) Class FTPMAXTON
***********************************************************************************

// Retorna de fun��o
Local lRet 	:= .F.

// Auxiliares
Local nX	:= 0

// Padr�es das vari�veis
Default nFTPPort := 21 // Porta padr�o de ftp 21
Default nTenta	 := 1 // 1 unica tentativa
Default lUsaIP	 := .F. // N�o utiliza conex�o por IP

// For�a Fechar a conex�o atual.
FTPDisconnect()

// Tenta a conex�o conforme numero de tentativas desejada
For nX := 1 To nTenta
	
	
	// Estabelece uma conex�o com o servidor de FTP especificado nos par�metros.
	/*
	Par�metros:
	Nome			Tipo			Descri��o																		Default			Obrigat�rio
	cServer			Caracter		Nome ou IP do servidor de FTP a estabelecer a conex�o.						   					X
	nPorta			Num�rico		N�mero da porta utilizada pelo servidor especificado em cServer para conex�o. 	21				X
									A Porta default para este tipo de informa��o � a porta 21.
	cUser			Caracter		String identificando o usu�rio a realizar o login no FTP.										X
	cPass			Caracter		String com a senha de login do usu�rio para o FTP.												X
	lUsesIPConn		L�gico			Define se utiliza conex�o por IP												.F.
	
	Retorno:
	lSucesso(logico)
	Havendo sucesso na conex�o, a fun��o retornar� .T.	
	*/
	If FTPConnect( cFTPServ, nFTPPort, cFTPUser, cFTPPass, lUsaIP )
		
		FTPSetPasv( .T. )
		
		lRet  := .T.
		Exit
	EndIf
	
	conout("*************** TENTATIVA CONEXAO FTP FTPMAXTON:Conectar AGFTPOBJ ***********")
	conout( 'Falhou ' + Alltrim( Str( nX, 2 ) ) + 'a. tentativa de conecao com FTP '+DTOC(DATE())+" - "+TIME() )
	Sleep( 3000 ) // Aguarda 3 segundos
Next

// Mensagem de conex�o
If lRet
	conout("*************** CONEXAO FTP FTPMAXTON:Conectar AGFTPOBJ ***********")
	conout( 'Conectado no FTP = '+cFTPServ+":"+alltrim(str(nFTPPort))+" Usuario: "+cFTPUser+' '+DTOC(DATE())+" - "+TIME() )
EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Desconectar
M�todo para desconectar uma conex�o ftp

@author J�nior Conte
@since 15/12/22
@version 1.0


Recebe:  
nTenta   - Numero de Tentativas para encerrar conex�o  
    
Retorna:
lRet - .T. = Encerrou / .F. = N�o Encerrou conex�o


/*/
//-------------------------------------------------------------------

Method DesconecFTP(nTenta) Class FTPMAXTON
******************************************

// Retorna de fun��o
Local lRet := .F.

// Auxiliares
Local nX	:= 0

// Padr�es das vari�veis
Default nTenta	 := 1 // 1 unica tentativa

For nX := 1 To  nTenta
	
	// Fecha a conex�o atual.
	/*
	Retorno:
	lSuccess(logico)
	Retorna se a opera��o foi efetuada com sucesso
	
	lSucess
	A fun��o FTPDisconnect() retornar� verdadeiro (.T.) se a opera��o for realizada com sucesso. 
	Se n�o existir uma conex�o a fun��o retornar� falso(.F.).
	*/
	
	If FtpDisconnect()
		lRet := .T.
		Exit
	EndIf
	conout("*************** TENTATIVA DESCONECTAR FTP FTPMAXTON:Desconectar AGFTPOBJ ***********")
	conout( 'Falhou' + Alltrim( Str( nX, 2 ) ) + 'a. tentativa de desconexao do FTP ou nao exisita conexao ativa. '+DTOC(DATE())+" - "+TIME() )
	Sleep( 3000 )// Aguarda 3 segundos
Next

// Mensagem de Desconectado
If lRet
	conout("*************** DESCONECTADO FTP FTPMAXTON:Desconectar AGFTPOBJ ***********")
	conout( 'Desconectado FTP '+DTOC(DATE())+" - "+TIME() )
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ListaDirFTP
M�todo para listar o local correte do FTP

@author J�nior Conte
@since 15/12/22
@version 1.0

Recebe:
cMASCARA - M�scara dos arquivos a serem pesquisados         
cATTR - Se for informado "D" a fun��o retornar� somente diret�rios, se n�o for informado retornar� somente arquivos  
 
Retorna:
aRetDir = arrey com o Conte�do do diret�rio listado

/*/
Method ListaDirFTP(cMASCARA, cATTR) Class FTPMAXTON
***************************************************

// Retorno da fun��o
Local aRetDir := {} 

// Padr�es das vari�veis
Default cMASCARA := "*.*" // Mascara todos os arquivos
Default cATTR	 := nil // Mostra somente os arquivos


// Cria um vetor com informa��es de diret�rios e arquivos do FTP.
/*
Nome			Tipo				Descri��o														Default			Obrigat�rio	
cMASCARA		Caracter			M�scara dos arquivos a serem pesquisados										X
cATTR			Caracter			Se for informado "D" a fun��o retornar� somente 								X
									diret�rios, se n�o for informado retornar� somente arquivos
lPreservaCaixa	Logico				Indica se o nome de arquivos e diret�rios devem ser retornados 	.T.							
									respeitando caixa alta e baixa

Retorno:
aRetDir
A fun��o FTPDirectory() retorna um vetor contendo informa��es dos diret�rios e arquivos contidos no FTP.

aRetDir[i][1] = nome do arquivo / diret�rio
aRetDir[i][2] = tamanho arquivo
aRetDir[i][3] = data arquivo
aRetDir[i][4] = hora arquivo
aRetDir[i][5] = "D" - Diret�rio / "" - Arquivo

*/
//aRetDir := FTPDIRECTORY( cMASCARA , cATTR )
aRetDir := FTPDIRECTORY( cMASCARA )

Return(aRetDir)

//-------------------------------------------------------------------
/*/{Protheus.doc} TrocaDirFTP
Troca a Pasta no FTP conectado 

@author J�nior Conte
@since 19/06/22
@version 1.0

Recebe:
cDirFTP - Nome do diret�rio do servidor FTP  (Ex.: temp)       
  
Retorna:
lRet - .T. = Trocou / .F. = N�o Trocou 

/*/
Method TrocaDirFTP(cDirFTP) Class FTPMAXTON
*******************************************

// Retorno da fun��o
Local lRet := .F.

//Troca de diret�rio no servidor FTP
/*
Parametros:

Nome			Tipo			Descri��o								Default			Obrigat�rio	
cDirFTP			Caracter		Nome do diretorio do servidor FTP.						X

Retorno:
lSuccess(logico)
Retorna se a opera��o foi efetuada com sucesso.
*/
If FTPDirChange( cDirFTP )
	lRet := .T.
EndIf

// Mensagem de Erro troca do diret�rio
If !lRet
	conout("*************** Troca Diretorio FTP FTPMAXTON:TrocaDirFTP AGFTPOBJ ***********")
	conout( 'Erro Tentativa de trocar diretorio FTP '+cDirFTP )
EndIF

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} UpLoadFTP
Envia Arquivo para FTP 

@author J�nior Conte
@since 15/12/20
@version 1.0

Recebe:
cFILELOCAL - caminho e nome do arquivo a ser enviado para FTP
cFILEFTP - caminho e nome do arquivo onde ser� copiado no servidor FTP        
  
Retorna:
lRet - .T. = Enviou / .F. = N�o Enviou 

/*/
Method UpLoadFTP(cFILELOCAL, cFILEFTP) Class FTPMAXTON
******************************************************

// Retorno da fun��o
Local lRet := .F.

// Envia arquivo para FTP
/*

Copia um arquivo da m�quina local para o servidor FTP.
A fun��o FTPUpload() copia um arquivo da m�quina local para o diret�rio corrente no servidor FTP. 
O arquivo a ser copiado deve estar abaixo do RootPath do Protheus.

Parametros:
Nome			Tipo			Descri��o									Default			Obrigat�rio	
cFILELOCAL		Caracter		Caminho e nome do arquivo na m�quina a 						X
								ser copiado para o servidor FTP
cFILEFTP		Caracter		Caminho e nome do arquivo no servidor FTP 					X
								onde ser� copiado.
								
Retorno:
lSuccess(logico)
Retorna se o upload foi efetuado com sucesso

*/
If FTPUpLoad( cFILELOCAL, cFILEFTP )
	lRet  := .T.
EndIf

If !lRet
	conout("*************** Upload Arquivo FTP UpLoadFTP AGFTPOBJ ***********")
	conout( 'Erro Tentativa de enviar arquivo Origem:'+cFILELOCAL+' Destino no FTP: '+cFILEFTP )
EndIF

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} DownloadFTP
Baixa o arquivo do FTP 

@author J�nior Conte
@since 15/12/20
@version 1.0

Recebe:
cFILELOCAL - caminho e nome do arquivo a ser gravado na m�quina que receber� o arquivo do FTP
cFILEFTP -  arquivo que ser� copiado do servidor FTP        
  
Retorna:
lRet - .T. = Baixou / .F. = N�o Baixou 

/*/
Method DownloadFTP(cFILELOCAL, cFILEFTP) Class FTPMAXTON
********************************************************

// Retorno da fun��o
Local lRet := .F.

// Obtem arquivo para FTP
/*

Copia um arquivo no servidor FTP para o servidor local.

Parametros:
Nome			Tipo			Descri��o									Default			Obrigat�rio	
cFILELOCAL		Caracter		Caminho e nome do arquivo a ser gravado 					X
								na m�quina
cFILEFTP		Caracter		Arquivo no servidor a ser copiado							X	

Retorno:

lSucess
A fun��o FTPDownload() copia um arquivo no servidor FTP para uma m�quina local em um diret�rio (informado no par�metro cArqDest) abaixo do RootPath do Protheus.

*/
If FTPDownLoad( cFILELOCAL, cFILEFTP )
	lRet  := .T.
EndIf

If !lRet
	conout("*************** Download Arquivo FTP DownloadFTP AGFTPOBJ ***********")
	conout( 'Erro Tentativa de baixar arquivo. Arquivo no FTP:'+cFILEFTP+' Onde Seria Copiado: '+cFILELOCAL)
EndIF

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} ApagaArqFTP
Apaga  arquivo do FTP 

@author J�nior Conte
@since 15/12/20
@version 1.0

Recebe:
cFILEFTP -  arquivo que ser� apagado do servidor FTP        
  
Retorna:
lRet - .T. = Apagou / .F. = N�o Apagou 

/*/
Method ApagaArqFTP(cFILEFTP) Class FTPMAXTON
********************************************

// Retorno da fun��o
Local lRet := .F.


//Apaga arquivo no servidor FTP.
/*

A fun��o FTPErase() apaga arquivo no diret�rio corrente do FTP.

Paraemtros:
Nome			Tipo			Descri��o			Default			Obrigat�rio	
cFILEFTP		Caracter		Nome do arquivo						X

Retorno:
lSuccess(logico)
Retorna se a opera��o foi efetuada com sucesso
*/
If FTPErase( cFILEFTP )
	lRet := .T.
EndIf


If !lRet
	conout("*************** Apagar Arquivo FTP ApagaArqFTP AGFTPOBJ ***********")
	conout( 'Erro Tentativa de apagar arquivo. Arquivo no FTP:'+cFILEFTP)
EndIF

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RenomArqFTP
Renomeia arquivo do FTP 

@author J�nior Conte
@since 15/12/20
@version 1.0

Recebe:
cSOURCEFILE -  nome do arquivo a ser renomeado        
cDESTFILE - novo nome do arquivo  
  
Retorna:
lRet - .T. = Renomeou / .F. = N�o Renomeou 

/*/
Method RenomArqFTP(cSOURCEFILE, cDESTFILE) Class FTPMAXTON
**********************************************************

// Retorno da fun��o
Local lRet := .F.


//Renomeia Arquivo do FTP
/*

A fun��o FTPRenameFile() renomeia um arquivo no diret�rio corrente do servidor FTP.

Paraemtros:
Nome			Tipo			Descri��o						Default			Obrigat�rio	
cSOURCEFILE		Caracter		Nome do arquivo a ser renomeado					X	
cDESTFILE		Caracter		Novo nome do arquivo							X

Retorno:
lSuccess(logico)
Retorna se a opera��o foi executada com sucesso
*/
If FTPRenamefile( cSOURCEFILE, cDESTFILE )
	lRet := .T.
EndIf


If !lRet
	conout("*************** Renomeia Arquivo FTP RenomArqFTP AGFTPOBJ ***********")
	conout( 'Erro Tentativa de renomear arquivo. Arquivo no FTP: '+cSOURCEFILE+' Nome que seria Renomeado: '+cDESTFILE)
EndIF

Return(lRet)
