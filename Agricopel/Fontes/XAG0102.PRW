#Include "TopConn.ch"
#Include "Protheus.ch"

#DEFINE cEOL Chr(13)+Chr(10) // Fim de linha e pr�xima linha

// Utilizado para os numeros de casas decimais dos campos do tipo NUMBER do Lay-out
// que atualmente s�o 9 casas decimais
#DEFINE NDECIMAL 1000000000 


#Define DIRRET  "RETORNO\"


/* OBSERVA��ES: Definido que os arquivos de confirma��o ser�o individuais pedido
ou seja, somente um pedido por confirma��o de recebimento.
*/

/*
Recebe: 
cFOpen = Arquivo para ser analisado

Retorno:
_aRet543[1] = .T. - Processado sem problemas / .F. - Problema
_aRet543[2] = Observa��es
_aRet543[3] = Nome do Arquivo
*/

// Verificar como ser� aleitura dos arquivos para importar os dados
**************************************************
User Function XAG0102(cFOpen)
**************************************************
**************************************************

// �reas
Local _aArea := GetArea()



// Auxiliares
Local cSql := ""
Local _i := 0 

// Padr�o em branco
Default cFOpen := ""

// Retorno de fun��o
Private _aRet543 := {.T.,"[XAG0102]"," "}
// Nome do arquivo
Private _cNomArq543	:= "" 
// Chave para a gera��o do LOG
Private _cChaveLog 	:= ""

// Retorno da leitura do arquivo
Private _aCab543 	:= ARRAY(13) //  Campos do Lay-Out do cabe�alho
Private _aItem543 	:= {} // Campos do Lay-Out dos itens



// Arquivo n�o informado
If Empty(cFOpen)
	_aRet543[1] := .F. 
	_aRet543[2] += cEOL+"Arquivo N�o Informado para a Importa��o"
EndIF


// Continua somente se n�o teve erro
If _aRet543[1]
	
	// Obtem o nome do arquivo sem o caminho
	For _i := len(cFOpen) to 1 step -1
		If substr(cFOpen,_i,1) = "\" .OR. substr(cFOpen,_i,1) = "/" 
			exit 
		Else
			_cNomArq543 := substr(cFOpen,_i,1)+_cNomArq543
		EndIf	
	Next _i
	
	// Padroniza para tudo maiusculo
	_cNomArq543 := UPPER(_cNomArq543)
	
	// Nome do arquivo para retorno de fun��o
	_aRet543[3] := _cNomArq543
	
	
	// Recebe: cFOpen = arquivo a ser realizado a leitura com o caminho completo.
	// Retorno: carrega vari�veis privadas _aCab543 e _aItem543
	sfLerTXT(cFOpen)

EndIF




// Restaura �reas
RestArea(_aArea)

Return(_aRet543)

// Fun��o para gerar o arquivo

Static Function sfLerTXT(cFOpen)
********************************

// Numero da Linha
Local _nLinha := 0

// Retorno da fun��o

// Controle de Abertura do Arquivo
Local nHandle := FT_FUse(cFOpen) 
// Linha do arquivo
Local cBuffer  := ""


// FAlha na abertura do arquivo
If nHandle = -1
	MsgStop("Erro ao Abrir arquivo "+cFOpen+" . Favor Verificar...","[XAG0102] - Erro")
	_aRet543[1] := .F.
	_aRet543[2] += cEOL+"Erro ao Abrir arquivo "+cFOpen
	Return()
EndIF


// Total da regua de processamento
//ProcRegua(FT_FLastRec())

// Leitura do arquivo
If FT_FLastRec() <> 0

	// In�cio do arquivo
	FT_FGoTop()
	
	While !FT_FEof()
	
		// Leitura da linha
		cBuffer  := FT_FReadLn()
		_nLinha++
			
			Do Case 
			
				// Cabe�alho
				Case  ALLTRIM(SUBSTR(cBuffer,1,1)) == "2"
						
						cPedido := PADR( SUBSTR(cBuffer,25,6) , TAMSX3("C5_NUM")[1] )

						cSerie  := SUBSTR(cBuffer,197,3)


						DbSelectArea("SC9")
						DbSetOrder(1)
						IF DBSEEK(xFilial("SC9") + cPedido )
							
							WHILE SC9->(!EOF()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. ALLTRIM( SC9->C9_PEDIDO )  == ALLTRIM(cPedido)
								
								if Alltrim(SC9->C9_XSREDI) == cSerie
									
									RecLock("SC9", .F. )
										SC9->C9_XDTSEP   :=  ddatabase
										SC9->C9_XHRSEP   :=  substr(time(), 1, 5)
									MsUnlock()

									DbSelectArea("SC6")
									DbSetOrder(1)
									IF DBSEEK(xFilial("SC6") + cPedido + SC9->C9_ITEM + SC9->C9_PRODUTO )
										//WHILE SC6->(!EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. ALLTRIM(SC6->C6_NUM ) == ALLTRIM(cPedido)
											RecLock("SC6", .F. )
												SC6->C6_XDTSEP  :=  ddatabase
												SC6->C6_XHRSEP  :=  substr(time(), 1, 5)
											MsUnlock()
											//SC6->(dbSkip())
										//ENDDO

									ENDIF


								

								endif

								SC9->(dbSkip())
							ENDDO

						ENDIF


						DbSelectArea("SC5")
						DbSetOrder(1)
						if DBSEEK(xFilial("SC5") + cPedido  )
							RecLock("SC5", .F.)
								SC5->C5_XIMPRE := "S"
							MsUnlock()
						endif

						


						

				Otherwise
					
					//_aRet543[1] := .F.
					//_aRet543[2] += cEOL+"Estrutura nao corresponde a cabecalho ou item na linha "+alltrim(str(_nLinha))+" do arquivo "+cFOpen
					
					//--Fecha arquivo utilizado para importacao:
					//FT_FUse()
					
					//Return()
					
			EndCase
			
			// Pr�xima linha do arquivo
			FT_FSkip()
			
		EndDo
		
		_aRet543[2] := alltrim(str(_nLinha))+" linha(s) processada(s)."
		
Else // Sem Registros
	
	_aRet543[1] := .F.
	_aRet543[2] := "[XAG0102] - Sem Registros no arquivo "+cFOpen
	
EndIF

//--Fecha arquivo utilizado para importacao:
FT_FUse()

Return()



// Recebe: _lSchedule = Define se � execu��o via Scheduler
*********************************
User Function XAG0102S()
*********************************
*********************************

// Auxiliares
Local _i := 0
Local _aRetAux		:= {}

// Padr�o chamado pelo sistema
Default  _lSchedule := .T.

// Verifica se � Scheduler para iniciar o ambiente e as tabelas
If _lSchedule
	If (isBlind() .OR. alltrim(FUNNAME()) <> 'XAG0102S')
		RpcSetEnv("01","19","","","","",{"SC5","SC6","SC9"})
		conout(Replicate("-",60))
		conout("XAG0102S - Importacao Arquivos CONF Inicio: "+DTOC(Date())+" "+Time())
		conout(Replicate("-",60))
	Endif 
EndIF

// Caminho padr�o para a leitura dos arquivos
Private _cDirCONF := "\maxton\retorno\" 
// Lita de arquivos do diret�rio
Private _aArqs	:= {}

// Erros para o WorkFlow
//_aErrosWF[1] = Nome do Arquivo
//_aErrosWF[2] = Descri��o dos Erros
Private _aErrosWF 	:= {}
Private _lErroWF	:= .F. // Indica se houve (.T.) ou n�o (.F.) erro nas leituras dos arquivos para controle de disparo do WorkFlow

// Realiza o bloqueio para evitar schedule e usu�rio processar ao mesmo tempo a rotina.
If !LockByName(xFilial("SC5")+"agrimp01",.T.,.T.)
	If _lSchedule
		conout("Esta Opcao Esta Sendo Executada por Outro Usuario ou Automaticamente pelo Sistema. Aguarde Finalizar e Tente Novamente.")
		conout(Replicate("-",60))
		conout("[agrimp01] - Fim Importacao Arquivos CONF : "+DTOC(Date())+" "+Time())
		conout(Replicate("-",60))
	Else
		MsgStop("Esta Op��o Est� Sendo Executada por Outro Usu�rio ou Automaticamente pelo Sistema. Aguarde Finalizar e Tente Novamente.","[XAG0102] - Em Execu��o:")
	EndIF
	Return()			
EndIF

// Realiza o download dos arquivos no FTP 
If _lSchedule .and. isBlind()
	U_XAG0101(.T.)    
Else
	msAguarde( { || U_XAG0101(.T.) }, "Recebendo Arquivos do FTP, Aguarde...")
EndIF

// Leitura dos arquivos do diret�rio "_cDirCONF" utilizando a fun��o padr�o Directory
/*
Cada subarray fornecido pela fun��o DIRECTORY() 
traz informa��es de um arquivo e possui os seguintes elementos:

Elemento 	S�mbolo 	Directry.ch
1			Nome		F_NAME
2			Tamanho		F_SIZE
3			Data		F_DATE
4			Hora		F_TIME
5			Atributos	F_ATT
*/

//-- Cria os diretorios de importacao
If !ExistDir(_cDirCONF)
	// Garante Cria��o das pastas de lidas, erro e pendentes
	MAKEDIR(_cDirCONF)
	MAKEDIR(_cDirCONF + "Pendentes\")			
	MAKEDIR(_cDirCONF + "Processados\")
EndIF

_aArqs := Directory( _cDirCONF + "Pendentes\" + '*.*' )
//AEVAL(_aArqs, { | aFile | MsgAlert(_aArqs[1]) } )

// Confirma��o para o Usu�rio
If Len(_aArqs) = 0
	
	//termina o semaforo 
	UnLockByName(xFilial("SC5")+"agrimp01",.T.,.T.)
	
	If _lSchedule .and. isBlind()
		conout("Sem Arquivo no Diretorio "+_cDirCONF+" para ser Processado.")
		conout(Replicate("-",60))
		conout("[agrimp01] - Fim Importacao Arquivos CONF : "+DTOC(Date())+" "+Time())
		conout(Replicate("-",60))
	Else
		MsgInfo("Sem Arquivo no Diret�rio "+_cDirCONF+ " para ser Processado.","[agrimp01] - Sem Arquivos:")
	EndIF	
	Return()
Else
	
	// Sempre processo quando for scheduler
	If !_lSchedule
	
		If !MsgYesNo("Deseja Processar o(s) "+alltrim(str(len(_aArqs)))+" Arquivo(s) com Confirma��o de Confer�ncia do Maxtons?","[agrimp01] - Confirma��o:")
			
			//termina o semaforo 
			UnLockByName(xFilial("SC5")+"agrimp01",.T.,.T.)
			Return()
		EndIF
	
	EndIF
EndIf

// Processamento
If _lSchedule .and. isBlind()
	sfProcARQ(_lSchedule)
Else
	Processa( {|| sfProcARQ(_lSchedule) }, "Aguarde...","Lendo Arquivo(s)...")
EndIF

//termina o semaforo 
UnLockByName(xFilial("SC5")+"agrimp01",.T.,.T.)

// Verifica os erros
If _lErroWF
	
	// Envia alertando o erro para o respons�vel.
	//sfMandaWF()	
	
	// Mensagem para scheduler
	If _lSchedule .and. isBlind()
	
		conout("ATENCAO: Erro(s) Encontrado(s) na Leitura do(s) "+alltrim(str(len(_aArqs)))+" Arquivos(s) com Retorno de Conferencia. E-mail Enviado.")
		conout(Replicate("-",60))
		conout("[agrimp01] - Fim Importacao Arquivos CONF : "+DTOC(Date())+" "+Time())
		conout(Replicate("-",60))
		
	Else // Mostra mensagem para usu�rio somente se n�o for Scheduler
		
		MsgAlert("ATEN��O: Erro(s) Encontrado(s) na Leitura do(s) "+alltrim(str(len(_aArqs)))+" Arquivos(s) com Retorno de Conferencia.","[XAG0102] - Erro:")
		
		If MsgYesNo("Deseja Visualizar o Log da Leitura do(s) "+alltrim(str(len(_aArqs)))+" Arquivo(s) do Retorno de Conferencia ?","[XAG0102] - Ver Log:")
			
			// Prepara a rela��o de arquivos processados para a fun��o do log
			_aRetAux := {}
			For _i := 1 to len(_aArqs)
				aadd(_aRetAux,_aArqs[_i][1])
			Next _i
			
		
		
		EndIF
	
	EndIF

Else

	If _lSchedule .and. isBlind()
		conout(alltrim(str(len(_aArqs)))+" Arquivos(s) Processado(s) com Sucesso.")
		conout(Replicate("-",60))
		conout("[agrimp01] - Fim Importacao Arquivos CONF : "+DTOC(Date())+" "+Time())
		conout(Replicate("-",60))	
	Else
		MsgInfo(alltrim(str(len(_aArqs)))+" Arquivos(s) Processado(s) com Sucesso.","[XAG0102] - Processamento OK:")	
	EndIF

EndIf

Return()


// Fun��o para Processar os arquivos
// Recebe: _lSchedule = Define se � execu��o via Scheduler
Static Function sfProcARQ(_lSchedule)
*************************************

// Auxiliares
Local _i 		:= 0
Local _aRetAux	:= {}
Local _cFile 	:= ""

If !_lSchedule
	//Tamanho Barra de Progress�o 
	ProcRegua(len(_aArqs))
EndIF


// Percorre todos os arquivos e realiza a leitura
For _i := 1 to len(_aArqs)
	
	// Nome do arquivo
	_cFile := alltrim(_aArqs[_i][1])
	
	If !_lSchedule
		IncProc("Lendo Arquivo "+_cFile)
	EndIF	
	
	// Fun��o para Leitura das Confirma��es de recebimento
	/*
	Recebe: 
	cFOpen = Arquivo para ser analisado
	
	Retorno:
	_aRet543[1] = .T. - Processado sem problemas / .F. - Problema
	_aRet543[2] = Observa��es
	_aRet543[2] = Observa��es
	_aRet543[3] = Nome do Arquivo
	*/
	_aRetAux := {}
	_aRetAux := U_XAG0102(_cDirCONF + "Pendentes\"+ _cFile)
	
	// Verifica��es para o WorkFlow
	If !_aRetAux[1]
		
		_lErroWF := .T.
		// Carrega os erros para o WorkFlow
		AADD(_aErrosWF,{_aRetAux[3],; // Nome do Arquivo
			_aRetAux[2]}) // Observa��es
			
		//-- Move arquivo para pasta dos erros
	//	Copy File &(_cDirCONF +_cFile) To &(_cDirCONF+_cFile)
	//	FErase(_cDirCONF+DIRRET+DIRALER+_cFile)
			
	Else
		
		//-- Move arquivo para pasta dos processados
		Copy File &(_cDirCONF+ "Pendentes\"+_cFile) To &(_cDirCONF+ "Processados\"+_cFile)
		FErase(_cDirCONF+ "Pendentes\"+_cFile)	
		
	EndIF	
	
Next _i


Return()



