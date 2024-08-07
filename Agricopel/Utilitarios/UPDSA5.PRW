#INCLUDE "PROTHEUS.CH"   
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �UPDSA5	    � Autor �Osmar Schimitberger    � Data �18/11/2019���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao do TAMNAHHO A5_NOMPROD de 30 para 50 caracteres     ��
�����������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                         ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Agricopel                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                         ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/                                    

User Function UPDSA5()
Local _cMsg 		:= ""			// Mensagem de Abertura do update

cArqEmp := "SIGAMAT.emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Set Dele On
                                                                                      
_cMsg += "Este programa tem como objetivo ajustar os dicion�rios de dados em fun��o do aumento do tamanho dos campos de Prefixo "
_cMsg += "Esta rotina deve ser processada em modo exclusivo! "
_cMsg += "Fa�a um backup dos dicion�rios e base de dados antes do processamento!"

oMainWnd := MSDIALOG():Create()
oMainWnd:cName := "oMainWnd"
oMainWnd:cCaption := ""
oMainWnd:nLeft := 0
oMainWnd:nTop := 0
oMainWnd:nWidth := 640
oMainWnd:nHeight := 460
oMainWnd:lShowHint := .F.
oMainWnd:lCentered := .T.
oMainWnd:bInit := {|| if( Aviso( "Atualizacao de Base" , _cMsg, { "Cancelar", "Prosseguir" }, 2 ) == 2 , ;	// "Atualizador de Base", "Cancelar", "Prosseguir"   
								( Processa({|lEnd|XPDSA5(@lEnd)} , "Atualizacao de Base" ), oMainWnd:End() ), ;	// "Atualizador de Base"
								( MsgAlert( "Opera�ao cancelada!" ), oMainWnd:End() ) ) }	// "Opera�ao cancelada!"

oMainWnd:Activate()
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � xAPREF   �Autor  � Osmar Schimitberger  � Data � 18/07/2019���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada para a cria��o dos dicion�rios para todas as empre-���
���          � sas e filiais                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Agricopel                                                  ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*
/*/
Static Function XUPDSA5(lEnd)
Local _cTexto    := '' 				// Exibira o log ao final do processo
Local _cFile     :="" 				// Nome do arquivo, caso o usuario deseje salvar o log das operacoes
Local _cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local _nI        := 0				// Contador para laco
Local _nX        := 0	            // Contador para laco
Local _aRecnoSM0 := {}			
Local _lOpen     := .F. 		   		// Retorna se conseguiu acesso exclusivo a base de dados


/********************************************************************************************
Inicia o processamento.
********************************************************************************************/
IncProc( "Verificando integridade dos dicion�rios..." )			// "Verificando integridade dos dicion�rios..."
Conout( "Verificando integridade dos dicion�rios..." )			// "Verificando integridade dos dicion�rios..."
                                
If ( _lOpen := MyOpenSm0EX() )

	DbSelectArea("SM0")
	DbsetOrder(1)
	dbGotop()
	While !Eof() 
  		If ( _nI := Ascan( _aRecnoSM0, {|x| x[2] == M0_CODIGO} ) ) == 0 //--So adiciona no _aRecnoSM0 se a empresa for diferente
			aAdd(_aRecnoSM0,{Recno(),M0_CODIGO,{}})
			_nI := Len(_aRecnoSM0)
		EndIf
		
		aAdd( _aRecnoSM0[_nI,3], FWGETCODFILIAL )
		
		dbSkip()
	EndDo	
		
	If _lOpen
		For _nI := 1 To Len(_aRecnoSM0)
			
			SM0->(dbGoto(_aRecnoSM0[_nI,1]))
			RpcSetType(2) 
			RpcSetEnv(SM0->M0_CODIGO, FWGETCODFILIAL,,,'FRT')
			aArqUpd:= {}
			lMsFinalAuto := .F.
			Aadd( aArqUpd, "SA5")
            //A5_NOMPROD

			_cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			_cTexto += "Empresa : " +SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)		// "Empresa : "

			//����������������������������������Ŀ
			//�Atualiza o dicionario de arquivos.�
			//������������������������������������
			ProcRegua(_nI)
			IncProc( "Empresa : " +SM0->M0_CODIGO+SM0->M0_NOME )			// "Empresa : "


			//�������������������������������Ŀ
			//�Atualiza o dicionario de dados.�
			//���������������������������������
			IncProc( dtoc( Date() )+" "+Time()+" "+ "Inicio - Dicionario de Dados" )			// "Inicio - Dicionario de Dados"
			Conout( dtoc( Date() )+" "+Time()+" "+"Inicio - Dicionario de Dados" )		   		// "Inicio - Dicionario de Dados"
			_cTexto += "Analisando Dicionario de Dados..." +CHR(13)+CHR(10)							// "Analisando Dicionario de Dados..."
			  
			U_XSX3SA5(@_cTexto) // ALTERA CAMPOS SX3
			
			IncProc( dtoc( Date() )+" "+Time()+" "+ "Fim - Dicionario de Dados" )			// "Fim - Dicionario de Dados"      
			Conout( dtoc( Date() )+" "+Time()+" "+ "Fim - Dicionario de Dados" )			// "Fim - Dicionario de Dados" 			

			__SetX31Mode(.F.)
			For _nX := 1 To Len(aArqUpd)
				IncProc( dtoc( Date() )+" "+Time()+" "+ "Inicio Atualizando Estruturas " +aArqUpd[_nX])	  		// "Inicio Atualizando Estruturas "
				Conout( dtoc( Date() )+" "+Time()+" "+ "I_nicio Atualizando Estruturas " +aArqUpd[_nX])			// "I_nicio Atualizando Estruturas "
				Conout(len(_cTexto))
				Conout(_cTexto)
				_cTexto += cEmpAnt+"-"+cFilAnt+"["+aArqUpd[_nX]+"]"+CHR(13)+CHR(10)   			// "Atualizando estruturas. Aguarde... ["
				If Select(aArqUpd[_nX])>0
					DbSelectArea(aArqUpd[_nX])
					dbCloseArea()
				EndIf
				X31UpdTable(aArqUpd[_nX])
				If __GetX31Error()
					Alert(__GetX31Trace())
					// "Atencao!", "Ocorreu um erro desconhecido durante a atualizacao da tabela : ", ". Verifique a integridade do dicionario e da tabela.", "Continuar"
					Aviso("Atencao!", "Ocorreu um erro desconhecido durante a atualizacao da tabela : " + aArqUpd[_nX] + ". Verifique a integridade do dicionario e da tabela." ,{"Continuar"},2)
					_cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : " +aArqUpd[_nX] +CHR(13)+CHR(10)				// "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "
				EndIf
				IncProc( dtoc( Date() )+" "+Time()+" "+"Fim Atualizando Estruturas " +aArqUpd[_nX])		// "Fim Atualizando Estruturas "
				Conout( dtoc( Date() )+" "+Time()+" "+"Fim Atualizando Estruturas "+aArqUpd[_nX])	   		// "Fim Atualizando Estruturas "
			Next _nX

			//��������������������������������������������������������������������Ŀ
			//�Chamar o alias de todas as tabelas alteradas para for�ar a cria��o  �
			//����������������������������������������������������������������������
			IncProc( dtoc( Date() )+" "+Time()+" "+ "I_nicio - Abrindo Tabelas" )			// "I_nicio - Abrindo Tabelas"
			Conout( dtoc( Date() )+" "+Time()+" "+ "I_nicio - Abrindo Tabelas" )			// "I_nicio - Abrindo Tabelas"
			IncProc( dtoc( Date() )+" "+Time()+" "+ "Fim - Abrindo Tabelas" ) 	 		// "Fim - Abrindo Tabelas"
			Conout( dtoc( Date() )+" "+Time()+" "+ "Fim - Abrindo Tabelas" ) 			// "Fim - Abrindo Tabelas"
			
			RpcClearEnv()
			If !( _lOpen := MyOpenSm0EX() )
				Exit 
			EndIf 
		Next _nI 
		   
		If _lOpen
			IncProc( dtoc( Date() )+" "+Time()+" "+ "Atualiza��o Conclu�da." ) 	   		// "Atualiza��o Conclu�da." 
			Conout( dtoc( Date() )+" "+Time()+" "+ "Atualiza��o Conclu�da." ) 	   		// "Atualiza��o Conclu�da." 
			
			_cTexto := "Log da Atualiza��o " +CHR(13)+CHR(10)+_cTexto		// "Log da Atualiza��o "
			___cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",_cTexto)
			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
			DEFINE MSDIALOG oDlg TITLE "Atualizacao Conclu�da."  From 3,0 to 340,417 PIXEL		// "Atualizacao Conclu�da."
			@ 5,5 GET oMemo  VAR _cTexto MEMO SIZE 200,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (_cFile:=cGetFile(_cMask,""),If(_cFile="",.t.,MemoWrite(_cFile,_cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER
			
		EndIf
	EndIf
EndIf 	

Return(.T.)

//Fun��o para alterar tamanho dos campos

User Function XSX3SA5()              

Local _aSX3:= {} 
Local _aSX1:= {} 

aAdd(_aSX3 ,{"A5_NOMPROD" })


dbSelectArea("SX3")
dbSetOrder(2)   
ProcRegua(Len(_aSX3))

For i:= 1 To Len(_aSX3)     

   If dbSeek(_aSX3[i][1]) 
      RecLock("SX3",.f.)
      Replace X3_TAMANHO with 50
      UnLock
   Endif

   IncProc("Atualizando Dicionario de Dados...")
		
Next i

                                    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � MyOpenSM � Autor � Microsiga          � Data �  25/07/2011   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento abertura do SM0 modo exclusivo     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � MyOpenSM - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MyOpenSM0EX()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , 'SIGAMAT.EMP', 'SM0', .F., .F. )

	If !Empty( Select( 'SM0' ) )
		lOpen := .T.
		dbSetIndex( 'SIGAMAT.IND' )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	ApMsgStop( 'N�o foi poss�vel a abertura da tabela ' + ;
		'de empresas de forma exclusiva.', 'ATEN��O' )
EndIf

Return lOpen
