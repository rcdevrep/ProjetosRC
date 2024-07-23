#INCLUDE "PROTHEUS.CH"   
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UPDPREF	    ³ Autor ³Osmar Schimitberger    ³ Data ³18/07/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao dos campos de prefixo - muda de 3 para 5 caracteres³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agricopel                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                    

User Function UPDPREF()
Local _cMsg 		:= ""			// Mensagem de Abertura do update

cArqEmp := "SIGAMAT.emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Set Dele On
                                                                                      
_cMsg += "Este programa tem como objetivo ajustar os dicionários de dados em função do aumento do tamanho dos campos de Prefixo "
_cMsg += "Esta rotina deve ser processada em modo exclusivo! "
_cMsg += "Faça um backup dos dicionários e base de dados antes do processamento!"

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
								( Processa({|lEnd|xAPREFI(@lEnd)} , "Atualizacao de Base" ), oMainWnd:End() ), ;	// "Atualizador de Base"
								( MsgAlert( "Operaçao cancelada!" ), oMainWnd:End() ) ) }	// "Operaçao cancelada!"

oMainWnd:Activate()
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ xAPREF   ³Autor  ³ Osmar Schimitberger  ³ Data ³ 18/07/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada para a criação dos dicionários para todas as empre-³±±
±±³          ³ sas e filiais                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agricopel                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*
/*/
Static Function xAPREFI(lEnd)
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
IncProc( "Verificando integridade dos dicionários..." )			// "Verificando integridade dos dicionários..."
Conout( "Verificando integridade dos dicionários..." )			// "Verificando integridade dos dicionários..."
                                
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
			Aadd( aArqUpd, "ABC")
            //ABC_PREFIX
            Aadd( aArqUpd, "ACG")
            //ACG_PREFIX
            Aadd( aArqUpd, "AD6")
            //AD6_PREFIX
            Aadd( aArqUpd, "AFP")  
            //AFP_PREFIX
			Aadd( aArqUpd, "AFR")  
			//AFR_PREFIX
			Aadd( aArqUpd, "AFT")  
			//AFT_PREFIX
			Aadd( aArqUpd, "AH3")  
			//AH3_PREFIX
			Aadd( aArqUpd, "BD5")  
			//BD5_PREFIX
			Aadd( aArqUpd, "BD6")  
			//BD6_PREFIX
			Aadd( aArqUpd, "BEA")  
			//BEA_PREFIX
			Aadd( aArqUpd, "BK2")  
			//BK2_PREFIX
			Aadd( aArqUpd, "BKD")  
			//BKD_PREFIX
			Aadd( aArqUpd, "BM1")  
			//BM1_PREFIX
			Aadd( aArqUpd, "CKY")  
			//CKY_PREFIX
			Aadd( aArqUpd, "CL2")  
			//CL2_PREFIX
			Aadd( aArqUpd, "CNX")  
			//CNX_PREFIX
			Aadd( aArqUpd, "DAM")  
			//DAM_PREFIX
			Aadd( aArqUpd, "DAP")  
			//DAP_PREFIX
			Aadd( aArqUpd, "DT6")  
			//DT6_PREFIX
			Aadd( aArqUpd, "DVV")  
			//DVV_PREFIX
			Aadd( aArqUpd, "EC6")  
			//EC6_PREFIX
			Aadd( aArqUpd, "EEQ")  
			//EEQ_PREFIX
			Aadd( aArqUpd, "EF3")  
			//EF3_PREFIX
			Aadd( aArqUpd, "F0T")  
			//F0T_PREFIX
			Aadd( aArqUpd, "FI2")  
			//FI2_PREFIX
			Aadd( aArqUpd, "FI9")  
			//FI9_PREFIX
			Aadd( aArqUpd, "FIA")  
			//FIA_PREFIX
			Aadd( aArqUpd, "FIE")  
			//FIE_PREFIX
			Aadd( aArqUpd, "FIF")  
			//FIF_PREFIX
			Aadd( aArqUpd, "FIH")  
			//FIH_PREFDE  
			//FIH_PREFOR
			Aadd( aArqUpd, "FII")  
			//FII_PREFDE  
			//FII_PREFOR
			Aadd( aArqUpd, "FIK")  
			//FIK_PREFIX
			Aadd( aArqUpd, "FIN")  
			//FIN_PREFIX
			Aadd( aArqUpd, "FIP")  
			//FIP_PREFIX
			Aadd( aArqUpd, "FIQ")  
			//FIQ_PREFIX
			Aadd( aArqUpd, "FIS")  
			//FIS_PREFIX
			Aadd( aArqUpd, "FJA")  
			//FJA_PREFIX
			Aadd( aArqUpd, "FJU")  
			//FJU_PREFIX
			Aadd( aArqUpd, "FLF")  
			//FLF_PREFIX
			Aadd( aArqUpd, "FO2")  
			//FO2_PREFIX
			Aadd( aArqUpd, "FO7")  
			//FO7_PREFIX
			Aadd( aArqUpd, "FR3")  
			//FR3_PREFIX
			Aadd( aArqUpd, "FRD")  
			//FRD_PREFIX
			Aadd( aArqUpd, "FW9")  
			//FW9_PREFIX
			Aadd( aArqUpd, "FWA")  
			//FWA_PREFIX
			Aadd( aArqUpd, "JMM")  
			//JMM_PREFIX
			Aadd( aArqUpd, "LEM")  
			//LEM_PREFIX
			Aadd( aArqUpd, "MF5")  
			//MF5_ECPREF
			Aadd( aArqUpd, "N01")  
			//N01_PREFIX
			Aadd( aArqUpd, "N04")  
			//N04_PREFIX
			Aadd( aArqUpd, "N43")  
			//N43_PREFIX
			Aadd( aArqUpd, "RC0")  
			//RC0_PREFIX
			Aadd( aArqUpd, "RC1")  
			//RC1_PREFIX
			Aadd( aArqUpd, "SA3")  
			//A3_PREFIXO
			Aadd( aArqUpd, "SE1")  
			//E1_FATPREF 
			//E1_PREFIXO  
			//E1_PREFORI
			Aadd( aArqUpd, "SE2")  
			//E2_FATPREF 
			//E2_PREFIXO
			Aadd( aArqUpd, "SE3")  
			//E3_PREFIXO
			Aadd( aArqUpd, "SE5")  
			//E5_FATPREF 
			//E5_PREFIXO
			Aadd( aArqUpd, "SE6")  
			//E6_PREFIXO
			Aadd( aArqUpd, "SEA")  
			//EA_PREFIXO
			Aadd( aArqUpd, "SEF")  
			//EF_PREFIXO
			Aadd( aArqUpd, "SEL")  
			//EL_PREFIXO
			Aadd( aArqUpd, "SEV")  
			//EV_PREFIXO
			Aadd( aArqUpd, "SEZ")  
			//EZ_PREFIXO
			Aadd( aArqUpd, "SF1")  
			//F1_PREFIXO
			Aadd( aArqUpd, "SF2")  
			//F2_PREFIXO 
			//F2_PREFORI
			Aadd( aArqUpd, "SFQ")  
			//FQ_PREFDES 
			//FQ_PREFORI
			Aadd( aArqUpd, "SK0")  
			//K0_PREFIXO
			Aadd( aArqUpd, "SK1")  
			//K1_PREFIXO
			Aadd( aArqUpd, "SLV")  
			//LV_PREFIXO
			Aadd( aArqUpd, "SW6")  
			//W6_PREFIXF  
			//W6_PREFIXS
			Aadd( aArqUpd, "SWB")  
			//WB_PREFIXO
			Aadd( aArqUpd, "SWD")  
			//WD_PREFIXO
			Aadd( aArqUpd, "SYB")  
			//YB_PREFIX
			Aadd( aArqUpd, "SZG")  
			//ZG_PREFIXO
			Aadd( aArqUpd, "SZP")  
			//ZP_PREFIXO
			Aadd( aArqUpd, "TRX")  
			//TRX_PREFIX
			Aadd( aArqUpd, "TS1")  
			//TS1_PREFIX
			Aadd( aArqUpd, "TS8")  
			//TS8_PREFIX
			Aadd( aArqUpd, "VER")  
			//VER_PREFIX
			Aadd( aArqUpd, "F0J")  
			//F0J_PRFTIT
	        Aadd( aArqUpd, "FI7")  
            //FI7_PRFDES
            //FI7_PRFORI
	        Aadd( aArqUpd, "FI8")  
            //FI8_PRFDES
            //FI8_PRFORI
	        Aadd( aArqUpd, "JA1")  
            //JA1_PRFTIT

			_cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			_cTexto += "Empresa : " +SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)		// "Empresa : "

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionario de arquivos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcRegua(_nI)
			IncProc( "Empresa : " +SM0->M0_CODIGO+SM0->M0_NOME )			// "Empresa : "


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionario de dados.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc( dtoc( Date() )+" "+Time()+" "+ "Inicio - Dicionario de Dados" )			// "Inicio - Dicionario de Dados"
			Conout( dtoc( Date() )+" "+Time()+" "+"Inicio - Dicionario de Dados" )		   		// "Inicio - Dicionario de Dados"
			_cTexto += "Analisando Dicionario de Dados..." +CHR(13)+CHR(10)							// "Analisando Dicionario de Dados..."
			  
			U_XSX3PREF(@_cTexto) // ALTERA CAMPOS SX3
			
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

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chamar o alias de todas as tabelas alteradas para forçar a criação  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			IncProc( dtoc( Date() )+" "+Time()+" "+ "Atualização Concluída." ) 	   		// "Atualização Concluída." 
			Conout( dtoc( Date() )+" "+Time()+" "+ "Atualização Concluída." ) 	   		// "Atualização Concluída." 
			
			_cTexto := "Log da Atualização " +CHR(13)+CHR(10)+_cTexto		// "Log da Atualização "
			___cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",_cTexto)
			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
			DEFINE MSDIALOG oDlg TITLE "Atualizacao Concluída."  From 3,0 to 340,417 PIXEL		// "Atualizacao Concluída."
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

//Função para alterar tamanho dos campos

User Function XSX3PREF()              

Local _aSX3:= {} 
Local _aSX1:= {} 

aAdd(_aSX3 ,{"ABC_PREFIX" })
aAdd(_aSX3 ,{"ACG_PREFIX" })
aAdd(_aSX3 ,{"AD6_PREFIX" })
aAdd(_aSX3 ,{"AFP_PREFIX" })
aAdd(_aSX3 ,{"AFR_PREFIX" })
aAdd(_aSX3 ,{"AFT_PREFIX" })
aAdd(_aSX3 ,{"AH3_PREFIX" })
aAdd(_aSX3 ,{"BD5_PREFIX" })
aAdd(_aSX3 ,{"BD6_PREFIX" })
aAdd(_aSX3 ,{"BEA_PREFIX" })
aAdd(_aSX3 ,{"BK2_PREFIX" })
aAdd(_aSX3 ,{"BKD_PREFIX" })
aAdd(_aSX3 ,{"BM1_PREFIX" })
aAdd(_aSX3 ,{"CKY_PREFIX" })
aAdd(_aSX3 ,{"CL2_PREFIX" })
aAdd(_aSX3 ,{"CNX_PREFIX" })
aAdd(_aSX3 ,{"DAM_PREFIX" })
aAdd(_aSX3 ,{"DAP_PREFIX" })
aAdd(_aSX3 ,{"DT6_PREFIX" })
aAdd(_aSX3 ,{"DVV_PREFIX" })
aAdd(_aSX3 ,{"EC6_PREFIX" })
aAdd(_aSX3 ,{"EEQ_PREFIX" })
aAdd(_aSX3 ,{"EF3_PREFIX" })
aAdd(_aSX3 ,{"F0T_PREFIX" })
aAdd(_aSX3 ,{"FI2_PREFIX" })
aAdd(_aSX3 ,{"FI9_PREFIX" })
aAdd(_aSX3 ,{"FIA_PREFIX" })
aAdd(_aSX3 ,{"FIE_PREFIX" })
aAdd(_aSX3 ,{"FIF_PREFIX" })
aAdd(_aSX3 ,{"FIH_PREFDE" })
aAdd(_aSX3 ,{"FIH_PREFOR" })
aAdd(_aSX3 ,{"FII_PREFDE" })
aAdd(_aSX3 ,{"FII_PREFOR" })
aAdd(_aSX3 ,{"FIK_PREFIX" })
aAdd(_aSX3 ,{"FIN_PREFIX" })
aAdd(_aSX3 ,{"FIP_PREFIX" })
aAdd(_aSX3 ,{"FIQ_PREFIX" })
aAdd(_aSX3 ,{"FIS_PREFIX" })
aAdd(_aSX3 ,{"FJA_PREFIX" })
aAdd(_aSX3 ,{"FJU_PREFIX" })
aAdd(_aSX3 ,{"FLF_PREFIX" })
aAdd(_aSX3 ,{"FO2_PREFIX" })
aAdd(_aSX3 ,{"FO7_PREFIX" })
aAdd(_aSX3 ,{"FR3_PREFIX" })
aAdd(_aSX3 ,{"FRD_PREFIX" })
aAdd(_aSX3 ,{"FW9_PREFIX" })
aAdd(_aSX3 ,{"FWA_PREFIX" })
aAdd(_aSX3 ,{"JMM_PREFIX" })
aAdd(_aSX3 ,{"LEM_PREFIX" })
aAdd(_aSX3 ,{"MF5_ECPREF" })
aAdd(_aSX3 ,{"N01_PREFIX" })
aAdd(_aSX3 ,{"N04_PREFIX" })
aAdd(_aSX3 ,{"N43_PREFIX" })
aAdd(_aSX3 ,{"RC0_PREFIX" })
aAdd(_aSX3 ,{"RC1_PREFIX" })
aAdd(_aSX3 ,{"A3_PREFIXO" })
aAdd(_aSX3 ,{"E1_FATPREF" })
aAdd(_aSX3 ,{"E1_PREFIXO" })
aAdd(_aSX3 ,{"E1_PREFORI" })
aAdd(_aSX3 ,{"E2_FATPREF" })
aAdd(_aSX3 ,{"E2_PREFIXO" })
aAdd(_aSX3 ,{"E3_PREFIXO" })
aAdd(_aSX3 ,{"E5_FATPREF" })
aAdd(_aSX3 ,{"E5_PREFIXO" })
aAdd(_aSX3 ,{"E6_PREFIXO" })
aAdd(_aSX3 ,{"EA_PREFIXO" })
aAdd(_aSX3 ,{"EF_PREFIXO" })
aAdd(_aSX3 ,{"EL_PREFIXO" })
aAdd(_aSX3 ,{"EV_PREFIXO" })
aAdd(_aSX3 ,{"EZ_PREFIXO" })
aAdd(_aSX3 ,{"F1_PREFIXO" })
aAdd(_aSX3 ,{"F2_PREFIXO" })
aAdd(_aSX3 ,{"F2_PREFORI" })
aAdd(_aSX3 ,{"FQ_PREFDES" })
aAdd(_aSX3 ,{"FQ_PREFORI" })
aAdd(_aSX3 ,{"K0_PREFIXO" })
aAdd(_aSX3 ,{"K1_PREFIXO" })
aAdd(_aSX3 ,{"LV_PREFIXO" })
aAdd(_aSX3 ,{"W6_PREFIXF" })
aAdd(_aSX3 ,{"W6_PREFIXS" })
aAdd(_aSX3 ,{"WB_PREFIXO" })
aAdd(_aSX3 ,{"WD_PREFIXO" })
aAdd(_aSX3 ,{"YB_PREFIX " })
aAdd(_aSX3 ,{"ZG_PREFIXO" })
aAdd(_aSX3 ,{"ZP_PREFIXO" })
aAdd(_aSX3 ,{"TRX_PREFIX" })
aAdd(_aSX3 ,{"TS1_PREFIX" })
aAdd(_aSX3 ,{"TS8_PREFIX" })
aAdd(_aSX3 ,{"VER_PREFIX" })
aAdd(_aSX3 ,{"F0J_PRFTIT" })
aAdd(_aSX3 ,{"FI7_PRFDES" })
aAdd(_aSX3 ,{"FI7_PRFORI" })
aAdd(_aSX3 ,{"FI8_PRFDES" })
aAdd(_aSX3 ,{"FI8_PRFORI" })
aAdd(_aSX3 ,{"JA1_PRFTIT" })

//alterados somente na SX3 - nao tem tabela criada no Banco de Dados
aAdd(_aSX3 ,{"B44_PREFIX" })
aAdd(_aSX3 ,{"B78_PREFIX" })
aAdd(_aSX3 ,{"BBT_PREFIX" })
aAdd(_aSX3 ,{"BDF_PREFIX" })
aAdd(_aSX3 ,{"BDH_PREFIX" })
aAdd(_aSX3 ,{"BE4_PREFIX" })
aAdd(_aSX3 ,{"BED_PREFIX" })
aAdd(_aSX3 ,{"BGQ_PREFIX" })
aAdd(_aSX3 ,{"BMN_PREFIX" })
aAdd(_aSX3 ,{"BMO_PREFIX" })
aAdd(_aSX3 ,{"BMW_PREFIX" })
aAdd(_aSX3 ,{"BMZ_PREFIX" })
aAdd(_aSX3 ,{"BOW_PREFIX" })
aAdd(_aSX3 ,{"BRJ_PREFIX" })
aAdd(_aSX3 ,{"BSQ_PREFIX" })
aAdd(_aSX3 ,{"BTO_PREFIX" })
aAdd(_aSX3 ,{"BTV_PREFIX" })
aAdd(_aSX3 ,{"BXQ_PREFIX" })
aAdd(_aSX3 ,{"BXQ_E2PREF" })
aAdd(_aSX3 ,{"CNY_PREFIX" })
aAdd(_aSX3 ,{"DD8_PREFIX" })
aAdd(_aSX3 ,{"EET_PREFIX" })
aAdd(_aSX3 ,{"FRA_PREFIX" })
aAdd(_aSX3 ,{"FRU_PREFIX" })
aAdd(_aSX3 ,{"FTR_PREFIX" })
aAdd(_aSX3 ,{"HE1_PREFIX" })
aAdd(_aSX3 ,{"HEL_PREFIX" })
aAdd(_aSX3 ,{"HF2_PREFIX" })
aAdd(_aSX3 ,{"JI7_PREFIX" })
aAdd(_aSX3 ,{"MAL_PREFIX" })
aAdd(_aSX3 ,{"MDK_PREFIX" })
aAdd(_aSX3 ,{"MDM_PREFIX" })
aAdd(_aSX3 ,{"MDN_PREFIX" })
aAdd(_aSX3 ,{"MEP_PREFIX" })
aAdd(_aSX3 ,{"MEQ_PREFIX" })
aAdd(_aSX3 ,{"N0C_PREF " })
aAdd(_aSX3 ,{"N15_PREFIX" })
aAdd(_aSX3 ,{"NO3_PREFIX" })
aAdd(_aSX3 ,{"NO8_PREFIX" })
aAdd(_aSX3 ,{"NOA_PREFIX" })
aAdd(_aSX3 ,{"NT2_PREFIX" })
aAdd(_aSX3 ,{"NT3_PREFIX" })
aAdd(_aSX3 ,{"NV3_PREFIX" })
aAdd(_aSX3 ,{"NVR_PREFIX" })
aAdd(_aSX3 ,{"LP_PREFIXO" })
aAdd(_aSX3 ,{"TS0_PREFIX" })
aAdd(_aSX3 ,{"VE4_PREFAB" })
aAdd(_aSX3 ,{"CH3_PREFIX" })
aAdd(_aSX3 ,{"CH4_PREFIX" })
aAdd(_aSX3 ,{"DYU_PREFIX" })
aAdd(_aSX3 ,{"FJZ_PREFIX" })
aAdd(_aSX3 ,{"FLD_PREFIX" })
aAdd(_aSX3 ,{"FLQ_PREFIX" })
aAdd(_aSX3 ,{"FR4_PREFIX" })
aAdd(_aSX3 ,{"FR6_PREFIX" })
aAdd(_aSX3 ,{"FV1_PREFIX" })
aAdd(_aSX3 ,{"FVP_PREFIX" })
aAdd(_aSX3 ,{"GIA_PREFIX" })
aAdd(_aSX3 ,{"GTJ_PREFIX" })
aAdd(_aSX3 ,{"MFI_PREFIX" })
aAdd(_aSX3 ,{"MG8_PREFIX" })
aAdd(_aSX3 ,{"NKC_PREFIX" })
aAdd(_aSX3 ,{"NOB_PREFIX" })
aAdd(_aSX3 ,{"NOB_PREFPR" })
aAdd(_aSX3 ,{"FOA_PREFIX" })
aAdd(_aSX3 ,{"FOB_PREFIX" })
aAdd(_aSX3 ,{"G4C_PREFIX" })
aAdd(_aSX3 ,{"G81_PREFIX" })
aAdd(_aSX3 ,{"G84_PREFIX" })
aAdd(_aSX3 ,{"G85_PREFIX" })
aAdd(_aSX3 ,{"G86_PREFIX" })
aAdd(_aSX3 ,{"G8E_PREFIX" })
aAdd(_aSX3 ,{"G8G_RAPREF" })
aAdd(_aSX3 ,{"G8X_PREFIX" })
aAdd(_aSX3 ,{"G8Y_PREFIX" })
aAdd(_aSX3 ,{"G90_PREFIX" })
aAdd(_aSX3 ,{"G9J_PREFIX" })
aAdd(_aSX3 ,{"FTL_PRFTIT" })
aAdd(_aSX3 ,{"JIF_PRFTIT" })
aAdd(_aSX3 ,{"JJ2_PRFTIT" })
aAdd(_aSX3 ,{"ME4_PRFTIT" })
aAdd(_aSX3 ,{"G81_PRFFOR" })
aAdd(_aSX3 ,{"G85_PRFATU" })
//VER 12.1.25
aAdd(_aSX3 ,{"DEB_PREFIX" })
aAdd(_aSX3 ,{"FKL_PREFIX" })
aAdd(_aSX3 ,{"GZC_PREFIX" })
aAdd(_aSX3 ,{"GZK_PREFIX" })
aAdd(_aSX3 ,{"LG_PREFIXO" })
aAdd(_aSX3 ,{"N8L_PREFIX" })
aAdd(_aSX3 ,{"N8M_PREFIX" })
aAdd(_aSX3 ,{"N9G_PREFIX" })
aAdd(_aSX3 ,{"N9K_PREFIX" })
aAdd(_aSX3 ,{"N9M_PREFIC" })
aAdd(_aSX3 ,{"N9M_PREFIX" })
aAdd(_aSX3 ,{"NBX_PREFIX" })
aAdd(_aSX3 ,{"NK7_MPREFI" })
aAdd(_aSX3 ,{"OHD_PREFIX" })
aAdd(_aSX3 ,{"OHH_PREFIX" })
aAdd(_aSX3 ,{"RJ1_PREFIX" })


//sx1
aAdd(_aSX1 ,{"DSR060    03" }) //Prefixo De ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch3C 301G                                                            mv_par03                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"DSR060    04" }) //Prefixo Ate ?                 ¿A Prefijo ?                  To Prefix ?                   mv_ch4C 301G                                                            mv_par04                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIC010    06" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch6C 300G                                                            mv_par06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIC01006.                                                  
aAdd(_aSX1 ,{"FIC010    07" }) //Até Prefixo ?                 ¿A Prefijo ?                  To Prefix ?                   mv_ch7C 300G                                                            mv_par07                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .FIC01007.                                                  
aAdd(_aSX1 ,{"FIN130    03" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch3C 300G                                                            mv_pre_de                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                S   .FIN13003.                                                  
aAdd(_aSX1 ,{"FIN130    04" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_ch4C 300G                                                            mv_pre_ate                                                  ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .FIN13004.                                                  
aAdd(_aSX1 ,{"FIN140    09" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch9C 300G                                                            mv_par09                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIN14009.                                                  
aAdd(_aSX1 ,{"FIN140    10" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_chaC 300G                                                            mv_par10                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .FIN14010.                                                  
aAdd(_aSX1 ,{"FIN150    03" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch3C 300G                                                            mv_prfde                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN150    04" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_ch4C 300G                                                            mv_prfate                                                   ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN320    04" }) //Prefixo Inicial ?             ¿Prefijo Inicial ?            Start Prefix ?                mv_ch4C 300G                                                            mv_par04                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIN32004.                                                  
aAdd(_aSX1 ,{"FIN320    05" }) //Prefixo Final ?               ¿Prefijo Final ?              End Prefix ?                  mv_ch5C 300G                                                            mv_par05                                                    ZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           S   .FIN32005.                                                  
aAdd(_aSX1 ,{"FIN510    12" }) //Prefixo de ?                  ¿De Prefijo ?                 Prefix from ?                 mv_chcC 300G                                                            mv_par12                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIN51012.                                                  
aAdd(_aSX1 ,{"FIN510    13" }) //Prefixo Ate ?                 ¿A Prefijo ?                  Prefix Until ?                mv_chdC 300G                                                            mv_par13                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .FIN51013.                                                  
aAdd(_aSX1 ,{"FIN550    08" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch8C 300G                                                            mv_par08                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN550    09" }) //Até o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_ch9C 300G                                                            mv_par09                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN551    08" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch8C 300G                                                            mv_par08                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN551    09" }) //Ate Prefixo ?                 ¿A Prefijo ?                  To Prefix ?                   mv_ch9C 300G                                                            mv_par09                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN750    01" }) //Do prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch1C 300G                                                            mv_par01                                                    011                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN750    02" }) //Ate o prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_ch2C 300G                                                            mv_par02                                                    011                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN760    01" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch1C 300G                                                            mv_par01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN760    02" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_ch2C 300G                                                            mv_par02                                                    zzz                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"MTA996    06" }) //Prefixo (PIS) ?               ¿Prefijo (PIS) ?              Prefix (PIS) ?                mv_ch6C 300G                                                            mv_par06                                                    PIS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .MTA99606.                                                  
aAdd(_aSX1 ,{"MTA996    09" }) //Prefixo (COFINS) ?            ¿Prefijo (COFINS) ?           Prefix (COFINS) ?             mv_ch9C 300G                                                            mv_par09                                                    COF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .MTA99609.                                                  
aAdd(_aSX1 ,{"TMK062    01" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch1C 300G                                                            mv_par01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"TMK062    02" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_ch2C 300G                                                            mv_par02                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"ATA480    01" }) //Prefixo do Cta.Pag. ?         ¿Prefijo de Ctas. Pagar ?     Accounts Pay. Prefix ?        mv_ch1C 300G                                                            mv_par01                                                    TEC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FI415A    05" }) //De Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FI415A    06" }) //Ate Prefixo ?                 ¿A Prefijo ?                  To Prefix ?                   mv_ch6C 300GNaoVazio()                                                  mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FI415B    05" }) //De Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FI415B    06" }) //Ate Prefixo ?                 ¿A Prefijo ?                  To Prefix ?                   mv_ch6C 300GNaoVazio()                                                  mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN195    05" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 MV_CH5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIN19505.                                                  
aAdd(_aSX1 ,{"FIN195    06" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   MV_CH6C 300G                                                            mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .FIN19506.                                                  
aAdd(_aSX1 ,{"FTA350    01" }) //Prefixo do Cta.Pag. ?         ¿Prefijo Cuentas a Pagar ?    Accounts Pay. Prefix ?        mv_ch1C 300G                                                            mv_par01                                                    FAT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"AGR019    13" }) //Do Prefixo ?                                                                              mv_chcC 300G                                                            mv_par13                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"AGR019    14" }) //Ate o Prefixo ?                                                                           mv_chdC 300G                                                            mv_par14                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"BACA16    03" }) //Prefixo           ?                                                                       mv_ch1C 300G                                                            mv_par03                                                    031                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"FIR330    04" }) //Prefixo inicial ?             ¿Prefijo inicial ?            Initial prefix ?              MV_CH4C 300G                                                            mv_par04                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIR330    05" }) //Prefixo final ?               ¿Prefijo final ?              Final prefix ?                MV_CH5C 300G                                                            mv_par05                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIR590    05" }) //Prefixo De ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIR590    06" }) //Prefixo Ate ?                 ¿A Prefijo ?                  To Prefix ?                   mv_ch6C 300G                                                            mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"GSPA71    08" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH8C 300G                                                            MV_PAR08                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPA7108                                                    
aAdd(_aSX1 ,{"GSPA71    09" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH9C 300G                                                            MV_PAR09                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPA7109                                                    
aAdd(_aSX1 ,{"GSPA73    10" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CHAC 300G                                                            MV_PAR10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPA7310                                                    
aAdd(_aSX1 ,{"GSPA73    11" }) //Até o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CHBC 300G                                                            MV_PAR11                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPA7311                                                    
aAdd(_aSX1 ,{"GSPC04    01" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           01    N   GSPC0401                                                    
aAdd(_aSX1 ,{"GSPC04    02" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPC0402                                                    
aAdd(_aSX1 ,{"GSPC10    19" }) //Prefixo dos Titulos ?         ¿Prefijo de los Titulos ?     Bill Prefix ?                 MV_CHJC 300G                                                            MV_PAR19                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPC1019                                                    
aAdd(_aSX1 ,{"GSPC11    01" }) //Prefixo da Divida ?           ¿Prefijo de la Deuda ?        Debt Prefix....... ?          MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPC1101                                                    
aAdd(_aSX1 ,{"GSPR37    04" }) //Prefixo ?                     ¿Prefijo ?                    Prefix....... ?               MV_CH4C 300G                                                            MV_PAR04                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR3704                                                    
aAdd(_aSX1 ,{"GSPR38    05" }) //Do Prefixo     . ?            ¿De Prefijo ?                 From Prefix....... ?          MV_CH5C 300G                                                            MV_PAR05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR3805                                                    
aAdd(_aSX1 ,{"GSPR38    06" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix........ ?           MV_CH6C 300G                                                            MV_PAR06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR3806                                                    
aAdd(_aSX1 ,{"GSPR40    01" }) //Do Prefixo     . ?            ¿De Prefijo ?                 From Prefix.......... ?       MV_CH1C 300G                                                            MV_PAR01                                                    IPT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          N   GSPR4001                                                    
aAdd(_aSX1 ,{"GSPR40    02" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix............. ?      MV_CH2C 300G                                                            MV_PAR02                                                    IPT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          N   GSPR4002                                                    
aAdd(_aSX1 ,{"GSPR41    01" }) //Do Prefixo     . ?            ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4101                                                    
aAdd(_aSX1 ,{"GSPR41    02" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4102                                                    
aAdd(_aSX1 ,{"GSPR42    01" }) //Do Prefixo     . ?            ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4201                                                    
aAdd(_aSX1 ,{"GSPR42    02" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4202                                                    
aAdd(_aSX1 ,{"GSPR43    01" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4301                                                    
aAdd(_aSX1 ,{"GSPR43    02" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4302                                                    
aAdd(_aSX1 ,{"GSPR44    01" }) //Do Prefixo     . ?            ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4401                                                    
aAdd(_aSX1 ,{"GSPR44    02" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N   GSPR4402                                                    
aAdd(_aSX1 ,{"GSPR45    01" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR4501                                                    
aAdd(_aSX1 ,{"GSPR45    02" }) //Até o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR4502                                                    
aAdd(_aSX1 ,{"GSPR47    03" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH3C 300G                                                            MV_PAR03                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR4703                                                    
aAdd(_aSX1 ,{"GSPR47    04" }) //Até o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH4C 300G                                                            MV_PAR04                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR4704                                                    
aAdd(_aSX1 ,{"GSPR56    01" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR5601                                                    
aAdd(_aSX1 ,{"GSPR56    02" }) //Até o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR5602                                                    
aAdd(_aSX1 ,{"GSPR57    01" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR5701                                                    
aAdd(_aSX1 ,{"GSPR57    02" }) //Até o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH2C 300G                                                            MV_PAR02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     GSPR5702                                                    
aAdd(_aSX1 ,{"ACX001    30" }) //Prefixo de ?                  ¿De Prefijo ?                 From Prefix ?                 MV_CHUC 300Gempty(mv_par30).or.(ascan(acprefixo(),mv_par30))#0          mv_par30                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"ACX001    31" }) //Prefixo ate ?                 ¿De Prefijo ?                 To Prefix ?                   MV_CHVC 300Gupper(mv_par31)='ZZZ'.or.(ascan(acprefixo(),mv_par31))#0    mv_par31                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"DAC010    06" }) //Do Prefixo ?                  ¿De Prefijo ?                 From prefix ?                 MV_CH6C 300G                                                            MV_PAR06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .DAC01006.                                                  
aAdd(_aSX1 ,{"DAC010    07" }) //Ate Prefixo ?                 ¿A Prefijo ?                  To prefix ?                   MV_CH7C 300G                                                            MV_PAR07                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .DAC01007.                                                  
aAdd(_aSX1 ,{"HSM38A    01" }) //Prefixo ?                     ¿Prefijo ?                    Prefix ?                      MV_CH1C 300GHS_VldTit()                                                 mv_par01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N                                                               
aAdd(_aSX1 ,{"FIN190    26" }) //Do prefixo ?                  ¿De prefijo ?                 From Prefix ?                 mv_chpC 300G                                                            mv_par26                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIN19026.                                                  
aAdd(_aSX1 ,{"FIN190    27" }) //Ate o prefixo ?               ¿A prefijo ?                  To Prefix ?                   mv_chqC 300G                                                            mv_par27                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .FIN19027.                                                  
aAdd(_aSX1 ,{"FIX190    26" }) //Do prefixo ?                  ¿De prefijo ?                 From Prefix ?                 mv_chpC 300G                                                            mv_par26                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIX190    27" }) //Ate o prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_chqC 300G                                                            mv_par27                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN139    03" }) //Do Prefixo ?                  ¿De Prefijo ?                 From prefix ?                 MV_CH3C 300G                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     S                                                               
aAdd(_aSX1 ,{"FIN139    04" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To prefix ?                   MV_CH4C 300G                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     S                                                               
aAdd(_aSX1 ,{"FIN74A    02" }) //Prefixo ?                     ¿Prefijo ?                    Prefix ?                      MV_CH2C 300G                                                            mv_par02                                                    DC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           S   .FIN74A02.                                                  
aAdd(_aSX1 ,{"FIN74B    05" }) //De prefixo ?                  ¿De prefijo ?                 From prefix ?                 MV_CH5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN74B    06" }) //A prefixo ?                   ¿A prefijo ?                  To prefix ?                   MV_CH6C 300G                                                            mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN84A    02" }) //Prefixo ?                     ¿Prefijo ?                    Prefix ?                      MV_CH2C 300G                                                            mv_par02                                                    DC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           S                                                               
aAdd(_aSX1 ,{"FIN84B    05" }) //De prefixo ?                  ¿De prefijo ?                 From prefix ?                 MV_CH5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN84B    06" }) //A prefixo ?                   ¿A prefijo ?                  To prefix ?                   MV_CH6C 300G                                                            mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIR074    03" }) //De prefixo ?                  ¿De prefijo ?                 From prefix ?                 MV_CH3C 300G                                                            mv_par03                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIR074    04" }) //A prefixo ?                   ¿A prefijo ?                  To prefix ?                   MV_CH4C 300G                                                            mv_par04                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIR084    03" }) //De prefixo ?                  ¿De prefijo ?                 From prefix ?                 mv_ch3C 300G                                                            mv_par03                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIR084    04" }) //A prefixo ?                   ¿A prefijo ?                  To prefix ?                   mv_ch4C 300G                                                            mv_par04                                                    ZZZZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       S                                                               
aAdd(_aSX1 ,{"PLR678    05" }) //Prefixo De ?                  ¿De prefijo ?                 From prefix ?                 mv_ch5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N                                                               
aAdd(_aSX1 ,{"PLR678    06" }) //Prefixo Ate ?                 ¿A prefijo ?                  To prefix ?                   mv_ch6C 300G                                                            mv_par06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N                                                               
aAdd(_aSX1 ,{"PLR760    07" }) //Prefixo De ?                  ¿De Prefijo ?                 From prefix ?                 MV_CH7C 300G                                                            mv_par07                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"PLR760    08" }) //Prefixo Ate ?                 ¿A Prefijo ?                  To prefix ?                   MV_CH8C 300G                                                            mv_par08                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"PLR761    05" }) //Prefixo De ?                  ¿De Prefijo ?                 From prefix ?                 MV_CH5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"PLR761    06" }) //Prefixo Ate ?                 ¿A Prefijo ?                  To prefix ?                   MV_CH6C 300G                                                            mv_par06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"PLSU07    13" }) //Prefixo Titulo De ?           ¿De prefijo de titulo ?       From bill prefix ?            mv_chdC 300G                                                            mv_par13                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 N                                                               
aAdd(_aSX1 ,{"PLSU07    14" }) //Prefixo Titulo Ate ?          ¿A prefijo de titulo ?        To bill prefix ?              mv_cheC 300G                                                            mv_par14                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          N                                                               
aAdd(_aSX1 ,{"FIX150    03" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 mv_ch3C 300G                                                            mv_prfde                                                    03                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           S                                                               
aAdd(_aSX1 ,{"FIX150    04" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   mv_ch4C 300G                                                            mv_prfate                                                   06Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FIN014    13" }) //Prefixo Titulo ?              ¿Prefijo Titulo ?             Bill prefix ?                 MV_CHDC 300G                                                            mv_par13                                                    COB                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FINA65000103" }) //Prefixo de ?                  ¿De Prefijo ?                 From Prefix ?                 MV_CH3C 300G                                                            mv_par03                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FINA65000104" }) //Prefixo ate ?                 ¿A Prefijo ?                  To Prefix ?                   MV_CH4C 300G                                                            mv_par04                                                    zzz                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S                                                               
aAdd(_aSX1 ,{"FINR295   07" }) //De prefixo ?                  ¿De prefijo ?                 From Prefix ?                 mv_ch7C 301G                                                            mv_par07                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FINR29507.                                                 
aAdd(_aSX1 ,{"FINR295   08" }) //Até prefixo ?                 ¿A prefijo ?                  To Prefix ?                   mv_ch8C 301G                                                            mv_par08                                                    zzz                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          S   .FINR29508.                                                 
aAdd(_aSX1 ,{"FIP703    01" }) //Prefixo ?                     ¿Fecha Disponibilidad ?       Availability Date ?           MV_CH1C 300R                                                            MV_PAR01                                                    E2_PREFIXO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   N                                                               
aAdd(_aSX1 ,{"FIP704    01" }) //Prefixo ?                     ¿Fecha Disponibilidad ?       Availability Date ?           MV_CH1C 300R                                                            MV_PAR01                                                    E1_PREFIXO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   N                                                               
aAdd(_aSX1 ,{"FIP706    03" }) //Prefixo ?                     ¿Prefijo ?                    Prefix ?                      MV_CH3C 300R                                                            MV_PAR03                                                    EL_PREFIXO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   N                                                               
aAdd(_aSX1 ,{"AGX322A   01" }) //Prefixo de        ?                                                                       mv_ch1C 300G                                                            mv_par01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"AGX322A   02" }) //Prefixo até       ?                                                                       mv_ch2C 300G                                                            mv_par02                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"AGX322C   01" }) //Prefixo de        ?                                                                       mv_ch1C 300G                                                            mv_par01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"AGX322C   02" }) //Prefixo até       ?                                                                       mv_ch2C 300G                                                            mv_par02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"AGX322B   01" }) //Prefixo de        ?                                                                       mv_ch1C 300G                                                            mv_par01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"AGX322B   02" }) //Prefixo até       ?                                                                       mv_ch2C 300G                                                            mv_par02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"AGX322    01" }) //Prefixo de        ?                                                                       mv_ch1C 300G                                                            mv_par01                                                    1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
aAdd(_aSX1 ,{"AGX322    02" }) //Prefixo até       ?                                                                       mv_ch2C 300G                                                            mv_par02                                                    1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
aAdd(_aSX1 ,{"AGX471    01" }) //Prefixo               ?                                                                   mv_ch1C 300G                                                            mv_par01                                                    999                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"AGX485    01" }) //Prefixo               ?                                                                   mv_ch1C 300G                                                            mv_par01                                                    SAd                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"FIN402A   06" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 MV_CH6C 300G                                                            mv_par06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .FIN402A06.                                                 
aAdd(_aSX1 ,{"FIN402A   07" }) //Até Prefixo ?                 ¿A Prefijo ?                  To Prefix ?                   MV_CH7C 300G                                                            mv_par07                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .FIN402A07.                                                 
aAdd(_aSX1 ,{"FIN905    04" }) //Prefixo De ?                  ¿De Prefijo ?                 Prefix from ?                 MV_CH4C 300G                                                            MV_PAR04                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN905    05" }) //Prefixo Ate ?                 ¿A Prefijo ?                  Prefix to ?                   MV_CH5C 300G                                                            MV_PAR05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN907    04" }) //Prefixo De ?                  ¿De Prefijo ?                 Profix from ?                 MV_CH4C 300G                                                            MV_PAR04                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FIN907    05" }) //Prefixo Até ?                 ¿A Prefijo ?                  Prefix to ?                   MV_CH5C 300G                                                            MV_PAR05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S                                                               
aAdd(_aSX1 ,{"FINR585R0101" }) //De Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 MV_CH1C 300G                                                            mv_par01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FINR585R0101.                                              
aAdd(_aSX1 ,{"FINR585R0102" }) //Ate Prefixo ?                 ¿A Prefijo ?                  To Prefix ?                   MV_CH2C 300G                                                            mv_par02                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FINR585R0102.                                              
aAdd(_aSX1 ,{"FIN402    06" }) //Do prefixo ?                  ¿De prefijo ?                 From Prefix ?                 MV_CH6C 300G                                                            mv_par06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIN40206.                                                  
aAdd(_aSX1 ,{"FIN402    07" }) //Até prefixo ?                 ¿A prefijo ?                  To Prefix ?                   MV_CH7C 300G                                                            mv_par07                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .FIN40207.                                                  
aAdd(_aSX1 ,{"FIN138    05" }) //Do Prefixo ?                  ¿Del Prefijo ?                From Prefix ?                 MV_CH5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .FIN13805.                                                  
aAdd(_aSX1 ,{"FIN138    06" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH6C 300G                                                            mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              .FIN13806.                                                  
aAdd(_aSX1 ,{"FIN158    05" }) //Do Prefixo ?                  ¿De prefijo ?                 From Prefix ?                 MV_CH4C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .FIN15805.                                                  
aAdd(_aSX1 ,{"FIN158    06" }) //Ate o Prefixo ?               ¿Al Prefijo ?                 To Prefix ?                   MV_CH5C 300G                                                            mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              .FIN15806.                                                  
aAdd(_aSX1 ,{"FIN198    05" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 MV_CH4C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .FIN19805.                                                  
aAdd(_aSX1 ,{"FIN198    06" }) //Ate o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   MV_CH5C 300G                                                            mv_par06                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              .FIN19806.                                                  
aAdd(_aSX1 ,{"BOLCOBBRAD03" }) //Prefixo            ?                                                                      mv_ch3C 300G                                                            mv_par03                                                    033                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"WM002     05" }) //Prefixo?                	                                                               mv_ch5C 300G                                                            mv_par05                                                    061                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"FINR112   07" }) //Prefixo de ?                  ¿De Prefijo ?                 Prefix from ?                 MV_CH7C 300G                                                            mv_par07                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"FINR112   08" }) //Prefixo até ?                 ¿A  Prefijo ?                 Prefix to ?                   MV_CH8C 300G                                                            mv_par08                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"LOJC851   05" }) //Prefixo De ?                  ¿De prefijo ?                 Prefix From ?                 MV_CH5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .LOJC85105.                                                 
aAdd(_aSX1 ,{"LOJC851   06" }) //Prefixo Ate ?                 ¿A prefijo ?                  Prefix To ?                   MV_CH6C 300G                                                            mv_par06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .LOJC85106.                                                 
aAdd(_aSX1 ,{"TMSR650   01" }) //Prefixo ?                     ¿Prefijo ?                    Prefix ?                      MV_CH1C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     .TMSR65001.                                                 
aAdd(_aSX1 ,{"TURA066A  11" }) //Do Prefixo ?                  ¿De Prefijo ?                 From Prefix ?                 MV_CHEC 300G                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
aAdd(_aSX1 ,{"TURA066A  12" }) //Até o Prefixo ?               ¿A Prefijo ?                  To Prefix ?                   MV_CHFC 300G                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
aAdd(_aSX1 ,{"TURR012   05" }) //Do Prefixo ?                  ¿De prefijo ?                 From Prefix ?                 MV_CH5C 300G                                                            mv_par05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           G84PFX    .TURR01205.                                                 
aAdd(_aSX1 ,{"TURR012   07" }) //Ate o Prefixo ?               ¿A prefijo ?                  To Prefix ?                   MV_CH7C 300G                                                            mv_par07                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           G84PFX    .TURR01206.                                                 
aAdd(_aSX1 ,{"KRI140    09" }) //Do Prefixo                                                                                mv_ch9C 300G                                                            mv_par09                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"KRI140    10" }) //Ate o Prefixo                                                                             mv_chaC 300G                                                            mv_par10                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"AFI460    08" }) //Prefixo titulo a ser gerado ? ¿Prefijo titulo por generar ? Prefix bill to generate ?     MV_CH8C 300G                                                            mv_par08                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 S   .AFI46008.                                                  
aAdd(_aSX1 ,{"XAG0046   01" }) //Prefixo De        ?                                                                       MV_CH0C 300G                                                            MV_PAR01                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"XAG0046   02" }) //Prefixo Ate       ?                                                                       MV_CH0C 300G                                                            MV_PAR02                                                    ZZZ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
aAdd(_aSX1 ,{"FINA720   05" }) //Prefixo De ?                  ¿De prefijo ?                 From Prefix ?                 MV_CH5C 300G                                                            MV_PAR05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd(_aSX1 ,{"FINA720   06" }) //Prefixo Ate ?                 ¿A prefijo ?                  To Prefix ?                   MV_CH6C 300G                                                            MV_PAR06                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 


dbSelectArea("SX3")
dbSetOrder(2)   
ProcRegua(Len(_aSX3))

For i:= 1 To Len(_aSX3)     

   If dbSeek(_aSX3[i][1]) 
      RecLock("SX3",.f.)
      Replace X3_TAMANHO with 5
      UnLock
   Endif

   IncProc("Atualizando Dicionario de Dados...")
		
Next i

dbSelectArea("SX1")
dbSetOrder(1)   
ProcRegua(Len(_aSX1))

For x:= 1 To Len(_aSX1)     

   If dbSeek(_aSX1[x][1]) 
      RecLock("SX1",.f.)
      Replace X1_TAMANHO with 5
      UnLock
   Endif

   IncProc("Atualizando Perguntas...")
		
Next x


Return(.T.)
                                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ MyOpenSM º Autor ³ Microsiga          º Data ³  25/07/2011   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento abertura do SM0 modo exclusivo     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ MyOpenSM - Gerado por EXPORDIC / Upd. V.4.01 EFS           ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	ApMsgStop( 'Não foi possível a abertura da tabela ' + ;
		'de empresas de forma exclusiva.', 'ATENÇÃO' )
EndIf

Return lOpen
