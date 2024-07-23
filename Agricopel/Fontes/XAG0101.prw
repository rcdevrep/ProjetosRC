#include 'Totvs.ch'



#Define DIRRET  "RETORNO\"

#DEFINE cEOL Chr(13)+Chr(10) // Fim de linha e próxima linha


//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Júnior Conte
@since 23/12/2022
@version 1.0

@return ( Nil )
/*/
//-------------------------------------------------------------------



User Function XAG0101(_lScheduler)

// Retorno de função
Local _aRet := {.T.," "}


// Parametros para conexão do FTP Maxton
Local cFTPServ :=  SUPERGETMV("ML_XPFTPSE",.F.,"ftp.maxtonlog.com.br") // Endereço do Servidor FTP Maxton
Local nFTPPort :=  SUPERGETMV("ML_XPFTPPO",.F.,21) // Porta do Servidor FTP Maxton
Local cFTPUser :=  SUPERGETMV("ML_XPFTPUS",.F.,"agricopel") // Usuário para FTP Maxton
Local cFTPPass :=  SUPERGETMV("ML_XPFTPPA",.F.,"agri@2022") // Senha para FTP Maxton
Local cFTPDire := "\gerados\" //SUPERGETMV("ML_XPFTPDI",.F.,' ') // Diretório raiz do FTP Maxton
Local cFTPDiBk := "\processados\" // SUPERGETMV("ML_XPFTPDB",.F.,' ') // Diretório de backup do FTP Maxton (para arquivos processados)

// Auxiliares
Local _aArqsFTP	:= {}
Local i		 	:= 0
Local _cFile	:= ""
Local _aArqs	:= {}

// Metodo para conectar FTP
Local _oFTP := FTPMAXTON():New()

// Padrão Disparado pelo menu
Default _lScheduler := .F.

// Auxiliares para o Log
PRIVATE cFileLog := ""
PRIVATE cPath := ""

_cDirCREC := "\maxton\retorno\pendentes\"

// Verifica se existe dirertório no ERP para recebimento do FTP
If !ExistDir(_cDirCREC)
 	_aRet[1] := .F.
 	_aRet[2] += "Diretorio no ERP para retorno do FTP nao localizado ("+_cDirCREC +") - [XAG0101]"+cEOL
 	If !_lScheduler
 		MsgStop(_aRet[2],"[XAG0101] - Problema:")
 	EndIF
 	Return(_aRet)
EndIF

// Confirmação do usuário
If !_lScheduler
	If !MsgYesNo("Confirma Receber Todos os Arquivos Pendentes do FTP da Maxton?","[XAG0101] - Confirmação")
		_aRet[1] := .T.
	 	_aRet[2] += "Cancelado Pelo Usuário - [XAG0101]"+cEOL
	 	Return(_aRet)	
	EndIF
EndIF

// Controle de concorrência de execução
If !LockByName(xFilial("SF1")+"XAG0101",.T.,.T.)
	If _lSchedule
		conout(Replicate("-",60))
		conout("Processo de Recebimento FTP (XAG0101) sendo Executada por outro usuario ou Automaticamente pelo Sistema")
		conout(Replicate("-",60))
	Else
		MsgStop("Esta Opção Está Sendo Executada por Outro Usuário ou Automaticamente pelo Sistema. Aguarde Finalizar e Tente Novamente.","[XAG0101] - Em Execução:")
	EndIF
	_aRet[1] := .F.
	_aRet[2] := "Processo de Recebimento FTP (XAG0101) sendo Executada por outro usuario ou Automaticamente pelo Sistema"
	Return(_aRet)
EndIF

// Conexão FTP Maxton
If !_oFTP:ConectarFTP(cFTPServ,; // Endereço
					  nFTPPort,; // Porta
					  cFTPUser,; // Usuário
					  cFTPPass,; // Senha
					  ,; // Numero de tentativas
					  .T.) // Endereço é por IP?
	
	_aRet[1] := .F.
 	_aRet[2] += "Erro ao Conectar FTP ("+cFTPServ+":"+alltrim(str(nFTPPort))+") - [XAG0101]."+cEOL
 	If !_lScheduler
 		MsgStop(_aRet[2],"[XAG0101] - Problema:")
 	EndIF
 	
 	//termina o semaforo 
	UnLockByName(xFilial("SF1")+"XAG0101",.T.,.T.)
 	
 	Return(_aRet)				  

EndIF

// Entra na pasta do FTP
If !_oFTP:TrocaDirFTP(IIF(!Empty(cFTPDire),cFTPDire,"\gerados\"))
	_aRet[1] := .F.
	_aRet[2] += "Erro ao entrar na pasta do FTP ("+IIF(!Empty(cFTPDire),cFTPDire,"\gerados\")+") - [XAG0101]."+cEOL
	If !_lScheduler
 		MsgStop(_aRet[2],"[XAG0101] - Problema:")
 	EndIF
 	
 	// Desconecta
	_oFTP:DesconecFTP(2)
 	
 	//termina o semaforo 
	UnLockByName(xFilial("SF1")+"XAG0101",.T.,.T.)
	
	Return(_aRet) 	
EndIf

// Obtem os arquivos para fazer o download
/*
_aArqs[i][1] = nome do arquivo / diretório
_aArqs[i][2] = tamanho arquivo
_aArqs[i][3] = data arquivo
_aArqs[i][4] = hora arquivo
_aArqs[i][5] = "D" - Diretório / "" - Arquivo
*/

/*
ATENÇÃO: Foi Necessário trazer todos os arquivos do diretório inclusive os sub-diretórios
devido a uma mensagem de erro que o appserver apresentava no console.log quando o diretório
no ftp estava vazio.

[FATAL][SERVER] [Thread 6900] [THROW] Address length returned 0 from Socket API at file .\sockets.cpp line 527
[ERROR][SERVER] [Thread 6900] [SOCKCLIENT] Error [16] The socket is already opened or in use.
[ERROR][SERVER] [Thread 6900] [SOCKCLIENT] Error [8] Data port could not be opened.
[ERROR][SERVER] [Thread 6900] [SOCKCLIENT] Error [1] Operation failed.

Desta forma, foi criado uma pasta chamada 'erp' no diretório 'out' no ftp da Maxton e realizado o tratamento
para fazer download somente dos arquivos .txt.

Desta forma, sempre vai ter algum arquivo ou diretório para não apresentar o erro.

Não caia serviço nem fazia erro de operação, mas como provavelmente a leitura dos arquivos no FTP será
configurada em um scheduler, pode ocorrer algum problema se ficar ocorrendo este erro direto no appserver.
  
*/
_aArqsFTP := _oFTP:ListaDirFTP("*.*","D")


// Ajusta para varíavel de controle dos arquivos a serem feitos download
For i := 1 to len(_aArqsFTP)

	// É diretório e não arquivo
	If !Empty(_aArqsFTP[i][5])
		loop
	EndIf
	
	// Somente arquivos .txt

    /*
	If lower(RIGHT(_aArqsFTP[i][1],4)) <> ".txt"
		loop
	EndIf
    */
	
	AADD(_aArqs,{alltrim(_aArqsFTP[i][1]),; // nome do arquivo
	.F.,; // Fez Download?
	.F.,; // Copiou para BackUp?
	.F.}) // Apagou do FTP?

Next i


// Sem Arquivos para receber
If Len(_aArqs) = 0
	_aRet[1] := .T.
 	_aRet[2] += "Sem Arquivos no diretorio do FTP ("+IIF(!Empty(cFTPDire),cFTPDire,"\gerados\")+") Para Fazer Download - [XAG0101]"+cEOL
 	If !_lScheduler
 		MsgInfo(_aRet[2],"[XAG0101] - Sem Registros:")
 	EndIF
 	
 	//termina o semaforo 
	UnLockByName(xFilial("SF1")+"XAG0101",.T.,.T.)
	
	// Desconecta
	_oFTP:DesconecFTP(2)
	
 	Return(_aRet)
EndIF


// faz download dos arquivos
For i := 1 to len(_aArqs)
	
	// Nome do arquivo
	_cFile := alltrim(_aArqs[i][1])
	
	If !_oFTP:DownloadFTP(_cDirCREC + _cFile,; // arquivo e caminho o ser recebido para FTP
						_cFile) // arquivo no FTP
	
		_aRet[1] := .F.
	 	_aRet[2] += "Erro ao Baixar Arquivo do FTP ("+IIF(!Empty(cFTPDire),cFTPDire,"\gerados\")+_cFile+") - [XAG0101]."+cEOL
	 	
		// Marca o arquivo como não feito download
		_aArqs[i][2] := .F.
			
	Else
	
		// Marca o arquivo como feito download
		_aArqs[i][2] := .T.
		
	
	EndIF					

Next i


// Desconecta
_oFTP:DesconecFTP(2)

/*
ATENÇÃO: Foi necessário fazer desta forma pois os componentes do FTP não 
permitiram fazer o Download, Upload, trocar de diretório e deletar na mesma 
conexão com o FTP.
*/

If _oFTP:ConectarFTP(cFTPServ,; // Endereço
					  nFTPPort,; // Porta
					  cFTPUser,; // Usuário
					  cFTPPass,; // Senha
					  ,; // Numero de tentativas
					  .T.) // Endereço é por IP?

	For i := 1 to len(_aArqs)
	
		// Nome do arquivo
		_cFile := alltrim(_aArqs[i][1])
		
		// Somente faz backup se existir a configuração para isso
		If !Empty(cFTPDiBk)
		
			// Envia para a pasta de backup
			If !_oFTP:UpLoadFTP(lower(_cDirCREC)+_cFile,; // arquivo o ser enviado para FTP
							cFTPDiBk+_cFile) // arquivo destino no FTP
			
				
				// Marca como não feito backup
				_aArqs[i][3] := .F.
			
			Else
				
				// Marca como feito backup
				_aArqs[i][3] := .T.
				
			EndIF	
		
		Else
		
			// Marca como feito backup, neste caso não tem pasta de backup
			_aArqs[i][3] := .T.
		
		EndIf
		
	Next i
	
	
	// Troca para o diretório raiz onde será apagado o arquivo
	If _oFTP:TrocaDirFTP(IIF(!Empty(cFTPDire),cFTPDire,"\gerados\"))
	
		For i := 1 to len(_aArqs)
			
			// Verifica se foi feito o backup do arquivo no ftp
			If _aArqs[i][3]
			
				// Nome do arquivo
				_cFile := alltrim(_aArqs[i][1])
					
				// Apaga o Arquivo no FTP
				If !_oFTP:ApagaArqFTP(_cFile)
					
					// Marca como não deletado
					_aArqs[i][4] := .F.
					
				Else
					
					// Marca como deletado no FTP
					_aArqs[i][4] := .T.
					
				EndIf
			
			Else
			
				// Marca como não deletado
				_aArqs[i][4] := .F.
			
			EndIf
		
					
		Next i
		
	EndIF

EndIF


// Desconecta
_oFTP:DesconecFTP(2)	

// Retorno para Usuário
For i := 1 to len(_aArqs)
	
	// Problema em fazer download
	If !_aArqs[i][2]
		_aRet[1] := .F.
 		_aRet[2] += "Não Foi Possível Download FTP ("+alltrim(_aArqs[i][1])+") - [XAG0101]"+cEOL
	EndIF
	
	
	// Marca como não feito backup
	If !_aArqs[i][3]
		_aRet[1] := .F.
 		_aRet[2] += "Não Foi Possível Copiar ("+alltrim(_aArqs[i][1])+") para pasta de backup ("+cFTPDiBk+"out\) no FTP  - [XAG0101]"+cEOL
	EndIF
	
	// Marca como não deletado do FTP
	If !_aArqs[i][4]
		_aRet[1] := .F.
 		_aRet[2] += "Não Foi Possível apagar o arquivo ("+alltrim(_aArqs[i][1])+") - [XAG0101]"+cEOL
	EndIF
	
	
Next i


// Mostra o log de processamento para usuário
If !_lScheduler

	AutoGrLog(replicate("-",80))
	AutoGrLog("Recebimento de Arquivos do FTP Maxton: "+IIF(_aRet[1],"SUCESSO","PROBLEMA OCORREU"))
	AutoGrLog(replicate("-",80))
	AutoGrLog(_aRet[2])
	
	// Mostra o log
	cFileLog := NomeAutoLog()
	MostraErro(cPath,cFileLog)
	
EndIf

//termina o semaforo 
UnLockByName(xFilial("SC9")+"XAG0101",.T.,.T.)

Return(_aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} KEPERFTP
Função para enviar e receber arquivos do FTP Maxton e atualizar
pastas do ERP.

@author Júnior Conte
@since 23/12/2022
@version 1.0

Recebe: 
_lScheduler = .T. - Mostra mensagens para usuário / .F. - Não Mostra Mensagens

Retorna:
_aRet[1] = .T. - Todo processo com sucesso. / .F. - Probelma no envio e recebimento
_aRet[2] = Mensagem para usuário 

/*/
//-------------------------------------------------------------------
***********************************
User Function KEPERFTP(_lScheduler)
***********************************
***********************************

// Retorno de função
Local _aRet := {.T.," "}
Local _aRetEnv := {}
Local _aRetRec := {} 

// Padrão Disparado pelo menu
Default _lScheduler := .F.

// Auxiliares para o Log
PRIVATE cFileLog := ""
PRIVATE cPath := ""

// Confirmação do usuário
If !_lScheduler
	If !MsgYesNo("Confirma Enviar\Receber Todos os Arquivos Pendentes do FTP da Maxton?","[KEPERFTP] - Confirmação")
		_aRet[1] := .T.
	 	_aRet[2] += "Cancelado Pelo Usuário - [KEPERFTP]"+cEOL
	 	Return(_aRet)	
	EndIF
EndIF


// Função para obter arquivos para FTP
_aRetRec := U_XAG0101(.T.)

If !_lScheduler

	AutoGrLog(replicate("-",80))
	AutoGrLog("Envio de Arquivos do FTP Maxton: "+IIF(_aRetEnv[1],"SUCESSO","PROBLEMA OCORREU"))
	AutoGrLog(replicate("-",80))
	AutoGrLog(_aRetEnv[2])
	
	// Linha em branco 
	AutoGrLog(" ")
	AutoGrLog(" ")
	
	AutoGrLog(replicate("-",80))
	AutoGrLog("Recebimento de Arquivos do FTP Maxton: "+IIF(_aRetRec[1],"SUCESSO","PROBLEMA OCORREU"))
	AutoGrLog(replicate("-",80))
	AutoGrLog(_aRetRec[2])
	
	// Mostra o log
	cFileLog := NomeAutoLog()
	MostraErro(cPath,cFileLog)

Else
	
	conout(replicate("-",80))
	conout("Envio de Arquivos do FTP Maxton: "+IIF(_aRetEnv[1],"SUCESSO","PROBLEMA OCORREU"))
	conout(replicate("-",80))
	conout(_aRetEnv[2])
	
	conout(replicate("-",80))
	conout("Recebimento de Arquivos do FTP Maxton: "+IIF(_aRetRec[1],"SUCESSO","PROBLEMA OCORREU"))
	conout(replicate("-",80))
	conout(_aRetRec[2])
		
EndIF

// Atualiza retorno
If !_aRetEnv[1] .OR. !_aRetRec[1]
	_aRet[1] := .F.
EndIf

_aRet[2] += _aRetEnv[2]
_aRet[2] += _aRetRec[2]

Return(_aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} KEPSCFTP
Função para colocar no Scheduler o envio e recebimento de arquivos 
do FTP Maxton

@author Júnior Conte
@since 23/12/2022
@version 1.0

/*/
//-------------------------------------------------------------------
************************
User Function KEPSCFTP()
************************
************************

// Específico para filial 17 = KOM21-29
RpcSetEnv("01","19","","","","",{"SC6","SC9"})
conout(Replicate("-",60))
conout("[KOM542P] - Recebendo arquivos FTP Maxton: "+DTOC(Date())+" "+Time())
conout(Replicate("-",60))

// Função para enviar e receber
U_KEPERFTP(.T.)

Return()


