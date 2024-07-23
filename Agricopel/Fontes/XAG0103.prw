#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "MsObject.ch"


User Function XAG0103()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} KOM556
Método para Manipulação de FTP

@author Júnior Conte
@since 15/12/22
@version 1.0

Documentação completa das Funções Padrões de FTP
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
Método para conectar em um ftp

@author Júnior Conte
@since 15/12/22
@version 1.0


Recebe:
cFTPServ - Nome do Servidor FTP                
nFTPPort - Porta para acesso ao Servidor FTP   
cFTPUser - Usuario para acesso ao Servidor FTP 
cFTPPass - Senha para acesso ao Servidor FTP   
nTenta   - Numero de Tentativas para conexão  
lUsaIP   - Define se utiliza conexão por IP    

Retorna:
lRet - .T. = Conectou / .F. = Erro conexão


/*/
//-------------------------------------------------------------------

Method ConectarFTP(cFTPServ,nFTPPort,cFTPUser,cFTPPass,nTenta,lUsaIP) Class FTPMAXTON
***********************************************************************************

// Retorna de função
Local lRet 	:= .F.

// Auxiliares
Local nX	:= 0

// Padrões das variáveis
Default nFTPPort := 21 // Porta padrão de ftp 21
Default nTenta	 := 1 // 1 unica tentativa
Default lUsaIP	 := .F. // Não utiliza conexão por IP

// Força Fechar a conexão atual.
FTPDisconnect()

// Tenta a conexão conforme numero de tentativas desejada
For nX := 1 To nTenta
	
	
	// Estabelece uma conexão com o servidor de FTP especificado nos parâmetros.
	/*
	Parâmetros:
	Nome			Tipo			Descrição																		Default			Obrigatório
	cServer			Caracter		Nome ou IP do servidor de FTP a estabelecer a conexão.						   					X
	nPorta			Numérico		Número da porta utilizada pelo servidor especificado em cServer para conexão. 	21				X
									A Porta default para este tipo de informação é a porta 21.
	cUser			Caracter		String identificando o usuário a realizar o login no FTP.										X
	cPass			Caracter		String com a senha de login do usuário para o FTP.												X
	lUsesIPConn		Lógico			Define se utiliza conexão por IP												.F.
	
	Retorno:
	lSucesso(logico)
	Havendo sucesso na conexão, a função retornará .T.	
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

// Mensagem de conexão
If lRet
	conout("*************** CONEXAO FTP FTPMAXTON:Conectar AGFTPOBJ ***********")
	conout( 'Conectado no FTP = '+cFTPServ+":"+alltrim(str(nFTPPort))+" Usuario: "+cFTPUser+' '+DTOC(DATE())+" - "+TIME() )
EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Desconectar
Método para desconectar uma conexão ftp

@author Júnior Conte
@since 15/12/22
@version 1.0


Recebe:  
nTenta   - Numero de Tentativas para encerrar conexão  
    
Retorna:
lRet - .T. = Encerrou / .F. = Não Encerrou conexão


/*/
//-------------------------------------------------------------------

Method DesconecFTP(nTenta) Class FTPMAXTON
******************************************

// Retorna de função
Local lRet := .F.

// Auxiliares
Local nX	:= 0

// Padrões das variáveis
Default nTenta	 := 1 // 1 unica tentativa

For nX := 1 To  nTenta
	
	// Fecha a conexão atual.
	/*
	Retorno:
	lSuccess(logico)
	Retorna se a operação foi efetuada com sucesso
	
	lSucess
	A função FTPDisconnect() retornará verdadeiro (.T.) se a operação for realizada com sucesso. 
	Se não existir uma conexão a função retornará falso(.F.).
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
Método para listar o local correte do FTP

@author Júnior Conte
@since 15/12/22
@version 1.0

Recebe:
cMASCARA - Máscara dos arquivos a serem pesquisados         
cATTR - Se for informado "D" a função retornará somente diretórios, se não for informado retornará somente arquivos  
 
Retorna:
aRetDir = arrey com o Conteúdo do diretório listado

/*/
Method ListaDirFTP(cMASCARA, cATTR) Class FTPMAXTON
***************************************************

// Retorno da função
Local aRetDir := {} 

// Padrões das variáveis
Default cMASCARA := "*.*" // Mascara todos os arquivos
Default cATTR	 := nil // Mostra somente os arquivos


// Cria um vetor com informações de diretórios e arquivos do FTP.
/*
Nome			Tipo				Descrição														Default			Obrigatório	
cMASCARA		Caracter			Máscara dos arquivos a serem pesquisados										X
cATTR			Caracter			Se for informado "D" a função retornará somente 								X
									diretórios, se não for informado retornará somente arquivos
lPreservaCaixa	Logico				Indica se o nome de arquivos e diretórios devem ser retornados 	.T.							
									respeitando caixa alta e baixa

Retorno:
aRetDir
A função FTPDirectory() retorna um vetor contendo informações dos diretórios e arquivos contidos no FTP.

aRetDir[i][1] = nome do arquivo / diretório
aRetDir[i][2] = tamanho arquivo
aRetDir[i][3] = data arquivo
aRetDir[i][4] = hora arquivo
aRetDir[i][5] = "D" - Diretório / "" - Arquivo

*/
//aRetDir := FTPDIRECTORY( cMASCARA , cATTR )
aRetDir := FTPDIRECTORY( cMASCARA )

Return(aRetDir)

//-------------------------------------------------------------------
/*/{Protheus.doc} TrocaDirFTP
Troca a Pasta no FTP conectado 

@author Júnior Conte
@since 19/06/22
@version 1.0

Recebe:
cDirFTP - Nome do diretório do servidor FTP  (Ex.: temp)       
  
Retorna:
lRet - .T. = Trocou / .F. = Não Trocou 

/*/
Method TrocaDirFTP(cDirFTP) Class FTPMAXTON
*******************************************

// Retorno da função
Local lRet := .F.

//Troca de diretório no servidor FTP
/*
Parametros:

Nome			Tipo			Descrição								Default			Obrigatório	
cDirFTP			Caracter		Nome do diretorio do servidor FTP.						X

Retorno:
lSuccess(logico)
Retorna se a operação foi efetuada com sucesso.
*/
If FTPDirChange( cDirFTP )
	lRet := .T.
EndIf

// Mensagem de Erro troca do diretório
If !lRet
	conout("*************** Troca Diretorio FTP FTPMAXTON:TrocaDirFTP AGFTPOBJ ***********")
	conout( 'Erro Tentativa de trocar diretorio FTP '+cDirFTP )
EndIF

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} UpLoadFTP
Envia Arquivo para FTP 

@author Júnior Conte
@since 15/12/20
@version 1.0

Recebe:
cFILELOCAL - caminho e nome do arquivo a ser enviado para FTP
cFILEFTP - caminho e nome do arquivo onde será copiado no servidor FTP        
  
Retorna:
lRet - .T. = Enviou / .F. = Não Enviou 

/*/
Method UpLoadFTP(cFILELOCAL, cFILEFTP) Class FTPMAXTON
******************************************************

// Retorno da função
Local lRet := .F.

// Envia arquivo para FTP
/*

Copia um arquivo da máquina local para o servidor FTP.
A função FTPUpload() copia um arquivo da máquina local para o diretório corrente no servidor FTP. 
O arquivo a ser copiado deve estar abaixo do RootPath do Protheus.

Parametros:
Nome			Tipo			Descrição									Default			Obrigatório	
cFILELOCAL		Caracter		Caminho e nome do arquivo na máquina a 						X
								ser copiado para o servidor FTP
cFILEFTP		Caracter		Caminho e nome do arquivo no servidor FTP 					X
								onde será copiado.
								
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

@author Júnior Conte
@since 15/12/20
@version 1.0

Recebe:
cFILELOCAL - caminho e nome do arquivo a ser gravado na máquina que receberá o arquivo do FTP
cFILEFTP -  arquivo que será copiado do servidor FTP        
  
Retorna:
lRet - .T. = Baixou / .F. = Não Baixou 

/*/
Method DownloadFTP(cFILELOCAL, cFILEFTP) Class FTPMAXTON
********************************************************

// Retorno da função
Local lRet := .F.

// Obtem arquivo para FTP
/*

Copia um arquivo no servidor FTP para o servidor local.

Parametros:
Nome			Tipo			Descrição									Default			Obrigatório	
cFILELOCAL		Caracter		Caminho e nome do arquivo a ser gravado 					X
								na máquina
cFILEFTP		Caracter		Arquivo no servidor a ser copiado							X	

Retorno:

lSucess
A função FTPDownload() copia um arquivo no servidor FTP para uma máquina local em um diretório (informado no parâmetro cArqDest) abaixo do RootPath do Protheus.

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

@author Júnior Conte
@since 15/12/20
@version 1.0

Recebe:
cFILEFTP -  arquivo que será apagado do servidor FTP        
  
Retorna:
lRet - .T. = Apagou / .F. = Não Apagou 

/*/
Method ApagaArqFTP(cFILEFTP) Class FTPMAXTON
********************************************

// Retorno da função
Local lRet := .F.


//Apaga arquivo no servidor FTP.
/*

A função FTPErase() apaga arquivo no diretório corrente do FTP.

Paraemtros:
Nome			Tipo			Descrição			Default			Obrigatório	
cFILEFTP		Caracter		Nome do arquivo						X

Retorno:
lSuccess(logico)
Retorna se a operação foi efetuada com sucesso
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

@author Júnior Conte
@since 15/12/20
@version 1.0

Recebe:
cSOURCEFILE -  nome do arquivo a ser renomeado        
cDESTFILE - novo nome do arquivo  
  
Retorna:
lRet - .T. = Renomeou / .F. = Não Renomeou 

/*/
Method RenomArqFTP(cSOURCEFILE, cDESTFILE) Class FTPMAXTON
**********************************************************

// Retorno da função
Local lRet := .F.


//Renomeia Arquivo do FTP
/*

A função FTPRenameFile() renomeia um arquivo no diretório corrente do servidor FTP.

Paraemtros:
Nome			Tipo			Descrição						Default			Obrigatório	
cSOURCEFILE		Caracter		Nome do arquivo a ser renomeado					X	
cDESTFILE		Caracter		Novo nome do arquivo							X

Retorno:
lSuccess(logico)
Retorna se a operação foi executada com sucesso
*/
If FTPRenamefile( cSOURCEFILE, cDESTFILE )
	lRet := .T.
EndIf


If !lRet
	conout("*************** Renomeia Arquivo FTP RenomArqFTP AGFTPOBJ ***********")
	conout( 'Erro Tentativa de renomear arquivo. Arquivo no FTP: '+cSOURCEFILE+' Nome que seria Renomeado: '+cDESTFILE)
EndIF

Return(lRet)
