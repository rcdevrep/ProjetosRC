#include "Protheus.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"   
#include "fileio.ch"

#DEFINE TMSGCONS "WFAC*"

/*/{Protheus.doc} AC_1
PEDIDO DE VENDAS
@author
@since
@version P11
@type function
/*/
User Function AC_1()       	// 1 - ENVIO DE EMAIL - PARA APROVACAO
	U_AC({'01',1}) 
Return

/*/{Protheus.doc} AC
Workflow Fusus - Pedido Vendas 
Fábio S. 	 15/04/07		 Apo´s todas as liberações enviar e-mail 
			 		  		 para o endereço cadastrado no parâmetro:
			 		  		 MV_EMAIL.								  
@author Adriano Luis Brandão
@since 15/02/07
@version P11
@uso Especíifico Shell
@param aParam, array
@type function
/*/
User Function AC(aParam)  // Agendamento U_AC("01',1)
Local nHandler 
Local cMsg		:= ""
Local cLCKFile	:= "\semaforo\wfac" +aParam[1]+".lck"

If aParam == Nil .OR. VALTYPE(aParam) == "U"
	U_CONSOLE("Parametros nao recebidos => PV()")
	RETURN
EndIf

// travando...
If ( nHandler := fCreate( cLCKFile, FC_NORMAL ) ) <> -1  // se conseguir, trava automaticamente ...
	cMsg := "Data: " + DtoC( MsDate() ) + " - Hora: " + Time()
	fWrite( nHandler, cMsg, Len( cMsg ) )
Else
	Return .F.// se nao conseguir... cai fora !
EndIf

//Prepare Environment Empresa aParam[1] Filial '01'
//RpcSetEnv(aParam[1],'01',,'FAT')
WFPREPENV(aParam[1],"01")

/*If !MayIUseCode( 'WFAC' + aParam[1] )
	U_CONSOLE( 'Job WFAC - Empresa ' + aParam[1] + ' - Já Está Em Andamento.') //

	Return NIL
EndIf*/

CHKFILE("SM0")

DBSelectArea("SM0")
DBSetOrder(1)
DBSeek(aParam[1],.F.)

U_CONSOLE('AC() /' + aParam[1] )

WHILE !SM0->(EOF()) .AND. SM0->M0_CODIGO == aParam[1]
	cFilAnt	:= SM0->M0_CODFIL

	U_CONSOLE("aParam[1]: " + aParam[1] + " - cFilAnt:" + cFilAnt)
	U_CONSOLE("aParam[2]: " + StrZero(aParam[2], 2))
	U_WFAC(aParam[2])
	SM0->(DBSkip())                                                       
END
//FreeUsedCode() 
fclose(nHandler)
FErase(cLCKFile)
RETURN

/*/{Protheus.doc} WFAC
1 - ENVIO DE EMAIL PARA APROVADORES
2 - RETORNO DE EMAIL COM RESPOSTA DE APROVADORES
3 - ENVIO de Email - Pedido Reprovado
4 - ENVIO de Email - Pedido Aprovado
5 - ENVIO de Email - NOTIFICACAO DE PRAZO DE VALIDADE
@author Microsiga
@since 08/15/02
@version P11
@uso AP6
@param _nOpc, numeric
@param  oProcess, object
@type function
/*/
User Function WFAC(_nOpc, oProcess)

Local _lProcesso 	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ{¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ{Ù
Local _aWF	 		:= {}
Local cObs 			:= ""
Local nTotal    	:= 0
Local lLiberou		:= .F.
Local cPath			:= "\WORKFLOW\HTML\TEMP\FACINFOCHEFE.HTM"

DO CASE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1 - Prepara os DADOS a serem enviados para aprovacao	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CASE _nOpc == 1
	
		U_CONSOLE(TMSGCONS + cValtoChar(ProcLine()) + " Prepara registros Aprovacao de Credito")
		

		CHKFile("SCR")  // Documentos com alçadas
		CHKFile("SA3")  //@ticket 285911 - T10532 - José Carlos Jr. - Query não retornava resultados pois a SA3 não estava aberta para consulta.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona os registros do SCR - DBF / INDREGUA                         ³
		//³ Abre um novo Alias para evitar problemas com filtros ja existentes.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	_cQuery := ""
      	_cQuery += " SELECT"
	  	_cQuery += " CR_FILIAL,"
	  	_cQuery += " CR_TIPO,"
	  	_cQuery += " CR_NUM,"
	  	_cQuery += " CR_NIVEL,"
	  	_cQuery += " CR_TOTAL,"
	  	_cQuery += " CR_USER,"
	  	_cQuery += " CR_MOTIVO,"
	  	_cQuery += " A3_AXTIPO,"
	  	_cQuery += " SCR.R_E_C_N_O_ SCRRECNO, "
	  	_cQuery += " CR_APROV"
	  	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
	  	_cQuery += "    INNER JOIN " + RetSqlName("SA3") + " A3 "
	  	_cQuery += "            ON A3_FILIAL = '" + xFilial("SA3") + "' AND CR_APROV = A3_COD "
	  	_cQuery += "               AND A3.D_E_L_E_T_ = ' ' AND A3_AXTIPO IN ('E','L') "
	  	_cQuery += " WHERE SCR.D_E_L_E_T_ = ' '"
	  	_cQuery += " AND CR_FILIAL = '" + xFilial("SCR") + "'"
	  	_cQuery += " AND LEFT(CR_TIPO,1) IN ('R','S','D') "
	  	_cQuery += " AND CR_MOTIVO <> '' "
	  	_cQuery += " AND CR_STATUS = '02'"  								// Em aprovacao
	  	_cQuery += " AND CR_WF = ' '"
	  	_cQuery += " ORDER BY"
	  	_cQuery += " CR_FILIAL,"
	  	_cQuery += " CR_NUM,"
	  	_cQuery += " CR_NIVEL,"
	  	_cQuery += " CR_USER"

		TcQuery _cQuery New Alias "TMP"

		dbSelectArea("TMP")
		dbGotop()
		While !TMP->(Eof())
			
			dbSelectArea("SCR")
			dbGoTo(TMP->SCRRECNO)

			Begin Transaction

				If Reclock("SCR",.F.)
				   	SCR->CR_WF	 := "1"  	// Status 1 - envio para aprovadores 
			    	MSUnlock()
			 	EndIf
	 	
				_aWF	 	:= EnviaAC(TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER , TMP->CR_APROV, TMP->(CR_FILIAL+CR_NUM), TMP->CR_TOTAL,TMP->CR_MOTIVO,,TMP->A3_AXTIPO)
				_lProcesso 	:= .T.
				dbSelectArea("SCR")
				dbGoTo(TMP->SCRRECNO)

				If Empty(SCR->CR_WFID)
					Reclock("SCR",.F.)
			    	SCR->CR_WFID := _aWF[1]		// Rastreabilidade
			    	MSUnlock()
				EndIf

			End Transaction

			dbSelectArea("TMP")
			DBSkip()
		EndDo
		dbSelectArea("TMP")
		dbCloseArea()
	
		
	CASE _nOpc	== 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³2 - Processa O RETORNO DO EMAIL                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_CONSOLE("2 - Processa O RETORNO DO EMAIL")
		U_CONSOLE("2 - Semaforo Vermelho" )

		nWFAC2 := U_Semaforo("WFAC2")

		ChkFile("SCR")
		ChkFile("SAL")
		ChkFile("SC9")
		ChkFile("SCS")
		ChkFile("SAK")
		ChkFile("SM2")

		IF oProcess <> NIL
			cFilAnt		:= alltrim(oProcess:oHtml:RetByName("CFILANT"))
			cChaveSCR	:= alltrim(oProcess:oHtml:RetByName("CHAVE"))
			cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))   
 //			cCob     	:= alltrim(oProcess:oHtml:RetByName("COB")) //POLLI - 17102007
			cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
			cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))

			oProcess:Finish() // FINALIZA O PROCESSO

			U_CONSOLE("2 - Chave :" + cChaveSCR)
			U_CONSOLE("2 - Opc   :" + cOpc)
//			U_CONSOLE("2 - Desp  :" + cCob)
		ENDIF 
		//se na aprovaçao do pedido foi escolhido para náo cobrar a despesa Acessória, zera-se o campo despesa do pedido de venda.

		IF cOpc $ "S|N"  // Aprovacao S-Sim N-Nao
			U_CONSOLE("Liberacao Status tipo 3A" + cWFID+" - "+cChaveSCR)

			CHKFile("SCR")  // Documentos com alçadas

		  	_cQuery := ""
   	  	  	_cQuery += " SELECT"
		  	_cQuery += " CR_FILIAL,"
		  	_cQuery += " CR_TIPO,"
		  	_cQuery += " CR_NUM,"
		  	_cQuery += " CR_NIVEL,"
		  	_cQuery += " CR_TOTAL,"
		  	_cQuery += " CR_USER,"
		  	_cQuery += " CR_WFID,"
		  	_cQuery += " CR_MOTIVO,"
		  	_cQuery += " R_E_C_N_O_, "
		  	_cQuery += " CR_APROV"
		  	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
		  	_cQuery += " WHERE CR_FILIAL+CR_NUM = '" + cChaveSCR + "'"
		  	_cQuery += " AND LEFT(CR_TIPO,1) IN ('R','D') "
		  	_cQuery += " AND CR_MOTIVO <> '' "
		  	_cQuery += " AND CR_STATUS = '03'"  								//aprovado
		  	_cQuery += " AND CR_WF <> '2'"
		  	_cQuery += " AND SCR.D_E_L_E_T_ <> '*'"
		  	_cQuery += " ORDER BY"
		  	_cQuery += " CR_FILIAL,"
		  	_cQuery += " CR_NUM,"
		  	_cQuery += " CR_NIVEL,"
		  	_cQuery += " CR_USER"

			TcQuery _cQuery New Alias "TMP"

			dbSelectArea("TMP")
			dbGotop()
			While !TMP->(Eof())
				dbSelectArea("SCR")
				dbGoTo(TMP->R_E_C_N_O_)
				U_CONSOLE("X - Processo ja respondido via Sistema:" +SCR->CR_WFID+" - "+cChaveSCR)
				U_CONSOLE("X - Semaforo Verde" )
				WFKillProcess(SCR->CR_WFID)
				dbSelectArea("TMP")
				dbSkip()
            End
			U_CONSOLE("Liberacao Status tipo 2" + cWFID+" - "+cChaveSCR)
			dbSelectArea("TMP")
			dbCloseArea()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleciona os registros do SCR - DBF / INDREGUA                         ³
			//³ Abre um novo Alias para evitar problemas com filtros ja existentes.    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  	_cQuery := ""
   	  	  	_cQuery += " SELECT"
		  	_cQuery += " CR_FILIAL,"
		  	_cQuery += " CR_TIPO,"
		  	_cQuery += " CR_NUM,"
		  	_cQuery += " CR_NIVEL,"
		  	_cQuery += " CR_TOTAL,"
		  	_cQuery += " CR_USER,"
		  	_cQuery += " CR_WFID,"
		  	_cQuery += " CR_MOTIVO,"
		  	_cQuery += " R_E_C_N_O_, "
		  	_cQuery += " CR_APROV"
		  	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
		  	_cQuery += " WHERE CR_FILIAL+CR_NUM = '" + cChaveSCR + "'"
		  	_cQuery += " AND LEFT(CR_TIPO,1) IN ('R','S','D') "
		  	_cQuery += " AND CR_MOTIVO <> '' "
		  	_cQuery += " AND CR_STATUS = '02'"  								// Em aprovacao
		  	_cQuery += " AND CR_WF <> '2'"
		    _cQuery += " AND CR_WFID Like ('"+TRIM(cWFID)+"%')
		  	_cQuery += " AND SCR.D_E_L_E_T_ <> '*'"
		  	_cQuery += " ORDER BY"
		  	_cQuery += " CR_FILIAL,"
		  	_cQuery += " CR_NUM,"
		  	_cQuery += " CR_NIVEL,"
		  	_cQuery += " CR_USER"

			TcQuery _cQuery New Alias "TMP"

			dbSelectArea("TMP")
			dbGotop()
			If EOF()
				U_CONSOLE("Y - Processo ja respondido via Sistema: - "+cChaveSCR)
				U_CONSOLE("Y - Semaforo Verde" )
				Return .T.
			Endif

			While !TMP->(Eof())
				If TRIM(TMP->CR_WFID) <> TRIM(cWFID)
					//"Este processo nao foi encontrado e portanto deve ser descartado
					// abre uma notificacao a pessoa que respondeu
					U_CONSOLE("2 - Processo nao encontrado :" + cWFID + " Processo atual :" + TMP->CR_WFID)
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFAC2)
					Return .T.
				Else
					dbSelectArea("SCR")
					dbGoTo(TMP->R_E_C_N_O_)
					Reclock("SCR",.F.)
					SCR->CR_WF		:= "2"			// Status 2 - respondido
					MSUnlock()
					Exit
				EndIf
				dbSkip()
			EndDo

			dbSelectArea("SCR")
			dbGoTo(TMP->R_E_C_N_O_)
			If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#04#05"
				U_CONSOLE("3 - Processo ja respondido :" + cWFID+" - "+cChaveSCR)
				U_CONSOLE("3 - Semaforo Verde" )
				U_Semaforo(nWFAC2)
				Return .T.
			EndIf
			dbSelectArea("SCR")
			dbGoTo(TMP->R_E_C_N_O_)
         	IF cOpc == "N" .AND. TMP->CR_TIPO == "D1"
           		U_CONSOLE("Liberacao bloqueio tipo D:" + cWFID)
         		dbSelectArea("SC5")
           		if dbseek (cChaveSCR)
	           		SC5->(Reclock("SC5",.F.))
	           		SC5->C5_DESPESA := 0
	           		SC5->(MsUnlock())
           		EndIf
           		cOpc := "S"
        	EndIF
				U_CONSOLE("Liberacao bloqueio tipo R:" + cWFID)
				// Verifica se o pedido esta aprovado por credito
				// Se estiver, finaliza o processo

				dbSelectArea("SC9")
				DBSetOrder(1)
				MSSeek(xFilial("SC9")+Alltrim(SCR->CR_NUM),.T.)
				_lCredito := .F.
				While !SC9->(Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. ALLTRIM(SC9->C9_PEDIDO) == Alltrim(SCR->CR_NUM)
					_lCredito 	:= IIF(!SC9->C9_BLCRED=='  ' .And. SC9->C9_BLCRED<>'10', .T., .F.)
					IF _lCredito
						EXIT
					ENDIF
					SC9->(DBSkip())
				EndDo

				IF ! _lCredito  // NAO ESTIVER BLOQUEADO
					U_CONSOLE("4 - Processo ja respondido via sistema :" + cWFID)
					U_CONSOLE("4 - Semaforo Verde" )
					U_Semaforo(nWFAC2)
					Return .T.
				ENDIF


			nTotal 		:= SCR->CR_TOTAL
			_lProcesso 	:= .T.

			lLiberou := U_AlcDoc2({SCR->CR_NUM,LEFT(SCR->CR_TIPO,1),SCR->CR_TOTAL,SCR->CR_APROV,,,,,,,cObs},dDataBase,If(cOpc=="S",4,6),,,)

			U_CONSOLE("5 - Liberado :" + IIF(lLiberou, "Sim", "Nao"))

			If lLiberou

                   	U_CONSOLE(" U_A450Grava")
                   	If SuperGetMv("ES_SHEA456",,"S") == "S"
					   U_A450Grava(Alltrim(SCR->CR_NUM))
                    EndIf
					EnviaAC(TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER , TMP->CR_APROV, TMP->(CR_FILIAL+CR_NUM), TMP->CR_TOTAL,TMP->CR_MOTIVO,cPath,"A", .T.)//inclusão - fábio
					U_CONSOLE("5 - U_A450Grava EnviaAC Processado" )
			EndIf
		EndIf
		U_CONSOLE("Fim - Semaforo Verde" )
		U_Semaforo(nWFAC2)
END CASE

IF 	_lProcesso
	U_CONSOLE(" Mensagem processada " )
ELSE
	U_CONSOLE(" Nao houve processamento ")
ENDIF

RETURN

/*/{Protheus.doc} EnviaAC
_cWF ' ' - Envia email para aprovador  
Fábio S. 	 15/04/07		 Incluído o link da aprovação do pedido.
@author Microsiga
@since 10/22/02
@version P11
@uso Especifico Shell
@param _cFilial, characters
@param _cNum, characters
@param  _cUser, characters
@param  _cAprov, characters
@param  _cChave, characters
@param  _nTotal, numeric
@param  _cMotivo, characters
@param  cHtml, characters
@param  _cTipo, characters
@param  lLiberado, logical
@type function
/*/
Static Function EnviaAC(_cFilial,_cNum, _cUser, _cAprov, _cChave, _nTotal, _cMotivo, cHtml, _cTipo, lLiberado)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aReturn 		:= {}
Local _aViewTA 		:= {}
Local _aViewTR 		:= {}
Local _aViewPV 		:= {}
Local nI 			:= 0
Local _nLin 		:= 0
Local nEstouro 		:= 0
Local nSomaPed 		:= 0
Local lInfoChefe    := .F.
Local cTipoLim 		:= SuperGetMv("MV_CREDCLI")
Local aLC			:= {}
Local aArea			:= GetArea()
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local aAreaSC9		:= SC9->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSA3		:= SA3->(GetArea())
Local aAreaPB1		:= PB1->(GetArea())
Local nMargemC3		:= 0
Local cDespesas		:= '' 
Local cBanding		:= Space(08)

//porta do link do workflow, cada distribuidor tem o sua porta
//Local cPorta		:= GetNewPar("MV_PORTA","8085")

Private nFrete		:= 0 

If TMP->CR_TIPO == "D1"
	Default cHtml	:= "\WORKFLOW\HTML\TEMP\FACAPROVD.HTM"
Else
	Default cHtml	:= "\WORKFLOW\HTML\TEMP\FACAPROV7.HTM"
EndIf

Default lLiberado	:= .F.		//inclusão - fábio
Default _cTipo		:= "***" 	//285911
        
If At("FACINFOCHEFE.HTM",Upper(cHtml)) > 0
	lInfoChefe := .T.
Endif

_cNum 	:= TRIM(_cNum)



U_CONSOLE(TMSGCONS + cValtoChar(ProcLine()) + " EnviaAC - CR_NUM: " + _cNum)

ChkFile("SC9")
ChkFile("SE1")
ChkFile("SE4")
ChkFile("SE5")
ChkFile("SC5")
ChkFile("SC6")
ChkFile("SA1")
ChkFile("SA3")
ChkFile("SB1")
ChkFile("SBM")
ChkFile("SX5")
ChkFile("ACY")
ChkFile("SX5")
ChkFile("SM0")
DBSelectArea("SX5")

DBSelectArea("SC5")
DBSetOrder(1)
DBSeek(xFilial("SC5")+_cNum)

DBSelectArea("SM0")
DBSetOrder(1)
DBSeek(cEmpAnt+cFilAnt)

DBSelectArea("SA3")
DBSetOrder(1)
DBSeek(xFilial("SA3")+SC5->C5_VEND1)

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)

DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+SC5->C5_CONDPAG)

DBSelectArea("SC6")
DBSetOrder(1)
DBSeek(xFilial("SC6")+_cNum,.F.)

nValMerc := 0
nValTotal:= 0
nDesconto:= 0
nPerDes  := 0

While ! SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == _cNum
	If Empty(SC6->C6_PRCFIN) .or. SC6->C6_PRCFIN == 0.00
		nValMerc	+= SC6->C6_QTDVEN * SC6->C6_PRCLIST
		nValTotal 	+= SC6->C6_QTDVEN * SC6->C6_PRCVEN
		nDesconto   += (SC6->C6_QTDVEN * SC6->C6_PRCLIST)-(SC6->C6_QTDVEN * SC6->C6_PRCVEN)
	Else
		nValMerc	+= SC6->C6_QTDVEN * SC6->C6_PRCLIST
		nValTotal 	+= SC6->C6_QTDVEN * SC6->C6_PRCFIN
		nDesconto   += (SC6->C6_QTDVEN * SC6->C6_PRCLIST)-(SC6->C6_QTDVEN * SC6->C6_PRCFIN)		
	EndIf
	SC6->(DBskip())
EndDo    


nPerDes := (1 - (nValTotal/nValMerc)) * 100

DBSelectArea("SC9")
DBSetOrder(1)
DBSeek(xFilial("SC9")+SC5->C5_NUM)

ConOut("(533) _cUser: "+_cUser)
_cTo := "000000"

If _cTipo == "E"
	_cTo	:= UsrRetMail(_cUser)
EndIf

If lLiberado
	_cTo := GetMv("MV_EMAIL")
EndIf
ConOut("(543) _cTo: "+_cTo)

//-------------------------------------VALIDACAO-------------------
_lError := .F.
if Empty(_cTo)
	cTitle  := "Administrador do Workflow : NOTIFICAÇÃO"
	cBody	:= REPLICATE('*',80) + CHR(10) + CHR(13)
	cBody	+= Dtoc(MSDate()) + " - " + Time() + ' * Ocorreu um ERRO no envio da mensagem :' + CHR(10) + CHR(13)
	cBody	+= "Pedido Numero : " + _cNum + " Filial : " + cFilAnt + " Usuário : " + UsrRetName(_cUser) + CHR(10) + CHR(13)
	cBody	+= "Campo EMAIL do cadastro de usuário NAO PREENCHIDO" + CHR(10) + CHR(13)
	cBody	+= REPLICATE('*',80)

	_lError := .T.
Endif
IF EMPTY(SC9->C9_PEDIDO)
	cTitle  := "Administrador do Workflow : NOTIFICAÇÃO"
	cBody	:= REPLICATE('*',80) + CHR(10) + CHR(13)
	cBody	+= Dtoc(MSDate()) + " - " + Time() + ' * Ocorreu um ERRO no envio da mensagem :' + CHR(10) + CHR(13)
	cBody	+= "Pedido Numero : " + _cNum + " Filial : " + _cFilial + " Usuário : " + UsrRetName(_cUser) + CHR(10) + CHR(13)
	cBody	+= "REGISTRO NAO ENCONTRADO NO ARQUIVO SC9" + CHR(10) + CHR(13)
	cBody	+= REPLICATE('*',80)
	_lError := .T.
ENDIF
                            
//frete por pedido
nFrete := U_WFACFRTPED(SC5->C5_NUM, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_TRANSP, SC5->C5_EMISSAO)

DBSelectArea("SC5")
DBSetOrder(1)
DBSeek(xFilial("SC5")+_cNum)

//------------------------------ MONTA OS TITULOS EM ABERTO E RECEBIDOS
_aViewTA	:= MontaTitulo(1)
_aViewTR	:= MontaTitulo(2)
_aViewPV	:= MontaItemPV(SC5->C5_FILIAL,SC5->C5_NUM)

DBSelectArea("SM0")
DBSetOrder(1)
DBSeek(cEmpAnt+cFilAnt)

DBSelectArea("SA3")
DBSetOrder(1)
DBSeek(xFilial("SA3")+SC5->C5_VEND1)

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)

DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+SC5->C5_CONDPAG)

DBSelectArea("SC6")
DBSetOrder(1)
DBSeek(xFilial("SC6")+_cNum,.F.)

IF Len(_aViewPV) > 0
	nMargemC3 := 0
	For _nLin := 1 TO Len(_aViewPV)
		nMargemC3	:= nMargemC3 + _aViewPV[_nLin][12]
	Next
EndIf

nMargemC3 := nMargemC3 / (_nLin - 1)

//Tratamento do Periodo de Inatividade do Cliente
d_DATAINI	:=	If( Empty(AllTrim(dtos(SA1->A1_ULTCOM))),Val(dtos(MSDATE())), Val(dtos(SA1->A1_ULTCOM)))
d_DATAFIM	:=	Val(dtos(MSDATE()))
c_RESULT	:=	d_DATAFIM - d_DATAINI

_cBLCRED	:= ""
For nI := 1 To Len(Alltrim(_cMotivo)) Step 2
	If SX5->(dbSeek(xFilial("SX5")+"P4"+Substring(_cMotivo,nI,2)))
		_cBlCred += SX5->X5_DESCRI +"/"
	Endif
Next
_cBlCred := Substring(_cBlCred,1,Len(_cBlCred)-1)

//TRATAMENTO DAS VARIAVEIS DE CREDITO
nMcusto   	:= Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(GetMv("MV_MCUSTO")))
aTab1Cred	:= {}
aTab2Cred	:= {}
aTab3Cred	:= {}
aTab4Cred	:= {}

// PRIMEIRA TABELA
If cTipoLim == "L"
	AADD( aTab1Cred, Transform(xMoeda(SA1->A1_LC, nMcusto, 1,dDataBase),"@E 999,999,999.99")) 								// LIMITE DE CREDITO
	AADD( aTab1Cred, TRansform(SA1->A1_SALDUP,"@E 99,999,999,999.99"))														// SALDO ATUAL
	AADD( aTab1Cred, TRansform(xMoeda(SA1->A1_LCFIN,nMcusto,1,dDatabase,MsDecimais(1)),"@E 999,999,999.99"))				// LIMITE CREDITO SEC
	AADD( aTab1Cred, TRansform(SA1->A1_SALFIN,"@E 99,999,999,999.99"))														// SALDO LC CRED
	AADD( aTab1Cred, TRansform(xMoeda(SA1->A1_MCOMPRA, nMcusto ,1, dDataBase,MsDecimais(1) ),"@E 99,999,999,999.99"))		// MAIOR COMPRA
	AADD( aTab1Cred, TRansform(SA1->A1_SALPEDL,"@E 99,999,999,999.99"))													// SALDO Pedidos Liberados pendendte de estoque
	AADD( aTab1Cred, TRansform(SA1->A1_SALPEDB,"@E 99,999,999,999.99"))													// Saldo de pedidos bloqueados de credito
	AADD( aTab1Cred, TRansform(SA1->A1_SALPED,"@E 99,999,999,999.99"))
	nSomaped := (SA1->A1_SALPED+SA1->A1_SALPEDB+SA1->A1_SALPEDL)
	AADD( aTab1Cred, TRansform(nSomaped,"@E 99,999,999,999.99"))    														// Saldos de Pedidos
	nEstouro := (((SA1->A1_LC+SA1->A1_LCFIN)-SA1->A1_SALDUP)-nSomaped)
	If nEstouro < 0
		AADD( aTab1Cred, "Estouro de Limite")
		AADD( aTab1Cred, TRansform((nEstouro*(-1)),"@E 99,999,999,999.99"))
	Else	   														// Saldos de Pedidos
		AADD( aTab1Cred, "Limite Disponivel")
		AADD( aTab1Cred, TRansform(nEstouro,"@E 99,999,999,999.99"))
	EndIf
Else
	aLC	:= {0,0,0,0,0,0,0,0}
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+SC5->C5_CLIENTE,.F.)
	While !EOF() .and. SA1->A1_FILIAL+SA1->A1_COD == xFilial("SA1")+SC5->C5_CLIENTE
		aLC[1]	+= xMoeda(SA1->A1_LC, nMcusto, 1,dDataBase)
		aLC[2]	+= SA1->A1_SALDUP
		aLC[3]	+= xMoeda(SA1->A1_LCFIN,nMcusto,1,dDatabase,MsDecimais(1))
		aLC[4]	+= SA1->A1_SALFIN
		aLC[5]	+= xMoeda(SA1->A1_MCOMPRA, nMcusto ,1, dDataBase,MsDecimais(1) )
		aLC[6]	+= SA1->A1_SALPEDL
		aLC[7]	+= SA1->A1_SALPEDB
		aLC[8]	+= SA1->A1_SALPED

		DbSelectArea("SA1")
		DbSkip()
	Enddo
	AADD( aTab1Cred, Transform(aLC[1],"@E 999,999,999.99")) 													// LIMITE DE CREDITO
	AADD( aTab1Cred, TRansform(aLC[2],"@E 99,999,999,999.99"))			   										// SALDO ATUAL
	AADD( aTab1Cred, TRansform(aLC[3],"@E 999,999,999.99"))	   												// LIMITE CREDITO SEC
	AADD( aTab1Cred, TRansform(aLC[4],"@E 99,999,999,999.99"))													// SALDO LC CRED
	AADD( aTab1Cred, TRansform(aLC[5],"@E 99,999,999,999.99"))	   												// MAIOR COMPRA
	AADD( aTab1Cred, TRansform(aLC[6],"@E 99,999,999,999.99"))													// SALDO Pedidos Liberados pendendte de estoque
	AADD( aTab1Cred, TRansform(aLC[7],"@E 99,999,999,999.99"))													// Saldo de pedidos bloqueados de credito
	AADD( aTab1Cred, TRansform(aLC[8],"@E 99,999,999,999.99"))
	nSomaped := (aLC[8]+aLC[7]+aLC[6])
	AADD( aTab1Cred, TRansform(nSomaPed,"@E 99,999,999,999.99"))    											// Saldos de Pedidos
	nEstouro := (((aLC[1]+aLC[4])-aLC[2])-nSomaPed)
	If nEstouro < 0
		AADD( aTab1Cred, "Estouro de Limite")
		AADD( aTab1Cred, TRansform((nEstouro*(-1)),"@E 99,999,999,999.99"))
	Else	   									  																// Saldos de Pedidos
		AADD( aTab1Cred, "Limite Disponivel")
		AADD( aTab1Cred, TRansform(nEstouro,"@E 99,999,999,999.99"))
	EndIf

	DBSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
Endif

// SEGUNDA TABELA
AADD( aTab2Cred, DtoC(SA1->A1_VENCLC)) 																			// Vencto Limite Credito
AADD( aTab2Cred, Transform(SA1->A1_MATR,"9999")) 																	// Maior Atraso
AADD( aTab2Cred, Transform(SA1->A1_METR,"@E 9999.99")) 															// Media Atraso
AADD( aTab2Cred, TRansform(xMoeda(SA1->A1_MSALDO, nMcusto ,1, dDataBase,MsDecimais(1) ),"@E 99,999,999,999.99")) 	// Maior Saldo
AADD( aTab2Cred, DtoC(SA1->A1_PRICOM)) // Primeira Compra
AADD( aTab2Cred, DtoC(SA1->A1_ULTCOM)) // Ultima Compra
AADD( aTab2Cred, RetCBox("A1_RISCO",SA1->A1_CLASVEN)) // Risco

// TERCEIRA TABELA
AADD( aTab3Cred, Transform(SA1->A1_CHQDEVO,"999")) 	// Cheque Devolvido Quantidade
AADD( aTab3Cred, DtoC(SA1->A1_DTULCHQ))		 		// Cheque Devolvido Ultimo

// QUARTA TABELA
AADD( aTab4Cred, Transform(SA1->A1_TITPROT,"999")) 	// Titulo Protestado Quantidade
AADD( aTab4Cred, DtoC(SA1->A1_DTULTIT))			    // Titulo Protestado Ultimo

//---------------------
//OPROCESS  - WORKFLOW
If !lInfoChefe
	oProcess  := TWFProcess():New( "000001", "Envio Aprovacao de Credito do Pedido :" + SM0->M0_NOME + "/" +  TRIM(_cNum) )
Else
	//inclusão - fábio - início
	If SCR->CR_STATUS == "03"
		oProcess  := TWFProcess():New( "000001", "Envio Informe de Aprovação de Credito do Pedido :" + SM0->M0_NOME + "/" +  TRIM(_cNum) )
	Else
		oProcess  := TWFProcess():New( "000001", "Envio Informe de Rejeição de Credito do Pedido :" + SM0->M0_NOME + "/" +  TRIM(_cNum) )
	EndIf
	//fim
Endif
oProcess:NewTask( "Envio AC : "+_cFilial + _cNum, cHtml )
If !lInfoChefe 
	If TMP->CR_TIPO == "D1"
		oProcess:cSubject 	:= "Aprovacao de Taxa Surcharge " + _cFilial + "/" +  _cNum
	Else
		oProcess:cSubject 	:= "Aprovacao de Delegacao do Pedido de Venda :" + _cFilial + "/" +  _cNum
	EndIf	
Else
	//inclusão - fábio - início
	If SCR->CR_STATUS == "03"
		oProcess:cSubject 	:= "Informe de Aprovação de Delegacao do Pedido de Venda :" + _cFilial + "/" +  _cNum
	Else
		oProcess:cSubject 	:= "Informe de Rejeição de Delegacao do Pedido de Venda :" + _cFilial + "/" +  _cNum
	EndIf
	//fim
Endif
oProcess:bReturn  	:= "U_WFAC(2)"
oProcess:cTo      	:= _cTo
ConOut("(736) _cTo: "+_cTo)
oProcess:NewVersion(.T.)

DBSelectArea("SC5")
DBSetOrder(1)
DBSeek(xFilial("SC5")+_cNum)

DBSelectArea("SM0")
DBSetOrder(1)
DBSeek(cEmpAnt+cFilAnt)

DBSelectArea("SA3")
DBSetOrder(1)
DBSeek(xFilial("SA3")+SC5->C5_VEND1)

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)

DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+SC5->C5_CONDPAG)

DBSelectArea("SC6")
DBSetOrder(1)
DBSeek(xFilial("SC6")+_cNum,.F.)

oHtml := oProcess:oHTML

// Hidden Fields
If !lInfoChefe
	oHtml:ValByName( "CHAVE"	    , _cChave)
	oHtml:ValByName( "CFILANT"	    , cFilAnt)
	oHtml:ValByName( "WFID"			, oProcess:fProcessId)
Endif

//Cabeçalho
//DADOS DO PEDIDO
//inclusão - fábio - início
If lInfoChefe
	oHtml:ValByName( "cTexto"		, IIf(SCR->CR_STATUS=="03","Aprovação","Reprovação" ) )
EndIf
//fim
oHtml:ValByName( "Interest"		, IIf(SA1->A1_EST <> GetMV("MV_ESTADO"),"Interestadual",GetMV("MV_ESTADO") ) )
oHtml:ValByName( "C9_FILIAL"	, SM0->M0_NOME )
oHtml:ValByName( "C9_PEDIDO"	, _cNum)
oHtml:ValByName( "E4_DESCRI"    , SE4->E4_DESCRI +Iif(SE4->E4_TIPO <> "9"," // "+ StrZero(u_PrzMedio(SC5->C5_CONDPAG),3),"") + " ("+SE4->E4_CODIGO+") ")
oHtml:ValByName( "nValMerc"		, TRANSFORM(nValMerc,'@E 999,999,999.99'))
oHtml:ValByName( "nDesconto"	, TRANSFORM(nDesconto,'@E 999,999,999.99'))
oHtml:ValByName( "nPerDes"	    , TRANSFORM(nPerDes,'@E 9,999.99'))
oHtml:ValByName( "A3_NOME"		, SA3->A3_NOME )
oHtml:ValByName( "cTmk"			, POSICIONE("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_NOME" ))
oHtml:ValByName( "CR_TOTAL"		, TRANSFORM(nValTotal,'@E 999,999,999.99'))
oHtml:ValByName( "CR_Margem"	, TRANSFORM(SC5->C5_MARGEM,'@E 999,999.99'))
oHtml:ValByName( "nMargemC3"	, TRANSFORM(nMargemC3,'@E 999,999.99'))
oHtml:ValByName( "cNegoc"		, IIf(SC5->(FieldPos("C5_ZZNEGOC")) > 0,SC5->C5_ZZNEGOC,""))

//DADOS DO CLIENTE
oHtml:ValByName( "A1_NOME"		, SA1->A1_NOME + " " + SA1->A1_COD + "-"+ SA1->A1_LOJA + " - " + SA1->A1_NREDUZ)
If SA1->A1_BANDING == "E"
	cBanding	:= "VINHO" 
ElseIf SA1->A1_BANDING == "N"
	cBanding    := "VERDE"
ElseIf SA1->A1_BANDING == "S"
	cBanding    := "AZUL"
Else
	cBanding	:= Space(8)	
Endif 
oHtml:ValByName( "A1_BANDING"	, cBanding) 
oHtml:ValByName( "A1_CGC"		, SA1->A1_CGC )
oHtml:ValByName( "A1_TEL"		, SA1->A1_TEL )
oHtml:ValByName( "A1_GRVVEN"	, POSICIONE("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI" ))
oHtml:ValByName( "C5_OBS"  		, SC5->C5_OBS )
//MOTIVO DO BLOQUEIO
oHtml:ValByName( "A1_CGC1"	, _cBLCRED )

//ANALISE DE CREDITO
//TABELA 1
oHtml:ValByName( "t10"	, aTab1Cred[1] )
oHtml:ValByName( "t11"	, aTab1Cred[2] )
oHtml:ValByName( "t12"	, aTab1Cred[3] )
oHtml:ValByName( "t13"	, aTab1Cred[4] )
oHtml:ValByName( "t14"	, aTab1Cred[5] )
oHtml:ValByName( "t15"	, aTab1Cred[6] )
oHtml:ValByName( "t16"	, aTab1Cred[7] )
oHtml:ValByName( "t17"	, aTab1Cred[8] )
oHtml:ValByName( "t18"	, aTab1Cred[9] )
oHtml:ValByName( "t19"	, aTab1Cred[10] )
oHtml:ValByName( "t20"	, aTab1Cred[11] )

//TABELA 2
oHtml:ValByName( "t21"	, aTab2Cred[1] )
oHtml:ValByName( "t22"	, aTab2Cred[2] )
oHtml:ValByName( "t23"	, aTab2Cred[3] )
oHtml:ValByName( "t24"	, aTab2Cred[4] )
oHtml:ValByName( "t25"	, aTab2Cred[5] )
oHtml:ValByName( "t26"	, aTab2Cred[6] )
oHtml:ValByName( "t27"	, aTab2Cred[7] )

//TABELA 3
oHtml:ValByName( "t31"	, aTab3Cred[1] )
oHtml:ValByName( "t32"	, aTab3Cred[2] )

//TABELA 4
oHtml:ValByName( "t41"	, aTab4Cred[1] )
oHtml:ValByName( "t42"	, aTab4Cred[2] )

// ITENS DO PEDIDO
If Len(_aViewPV) > 0
	For _nLin := 1 TO Len(_aViewPV)
		AAdd( (oHtml:ValByName( "t4.1" )), _aViewPV[_nLin][1])
		AAdd( (oHtml:ValByName( "t4.2" )), _aViewPV[_nLin][2])
		AAdd( (oHtml:ValByName( "t4.3" )), _aViewPV[_nLin][3])
		AAdd( (oHtml:ValByName( "t4.4" )), _aViewPV[_nLin][4])
		AAdd( (oHtml:ValByName( "t4.5" )), Transform(_aViewPV[_nLin][5],"@E 999999999"))
		AAdd( (oHtml:ValByName( "t4.6" )), Transform(_aViewPV[_nLin][6],"@E 999,999,999,999.99"))
		AAdd( (oHtml:ValByName( "t4.7" )), Transform(_aViewPV[_nLin][7],"@E 999,999,999,999.99"))
		AAdd( (oHtml:ValByName( "t4.8" )), Transform(_aViewPV[_nLin][8],"@E 9,999.99"))
		AAdd( (oHtml:ValByName( "t4.9" )), Transform(_aViewPV[_nLin][9],"@E 999.99"))
		AAdd( (oHtml:ValByName( "t4.10" )),Transform(_aViewPV[_nLin][10],"@E 999,999.99"))
		AAdd( (oHtml:ValByName( "t4.11" )),Transform(_aViewPV[_nLin][11],"@E 99,999"))
		AAdd( (oHtml:ValByName( "t4.12" )),Transform(_aViewPV[_nLin][12],"@E 999,999.99")) 
		AAdd( (oHtml:ValByName( "t4.13" )),Transform(_aViewPV[_nLin][13],"@E 999999"))
		AAdd( (oHtml:ValByName( "t4.14" )),Transform(_aViewPV[_nLin][14],"@E 999,999.99"))
		AAdd( (oHtml:ValByName( "t4.15" )),_aViewPV[_nLin][15])
		AAdd( (oHtml:ValByName( "t4.16" )),_aViewPV[_nLin][16])
		AAdd( (oHtml:ValByName( "t4.17" )),_aViewPV[_nLin][17])
	Next
Else
	AAdd( (oHtml:ValByName( "t4.1" )), " ")
	AAdd( (oHtml:ValByName( "t4.2" )), " ")
	AAdd( (oHtml:ValByName( "t4.3" )), " ")
	AAdd( (oHtml:ValByName( "t4.4" )), " ")
	AAdd( (oHtml:ValByName( "t4.5" )), " 0")
	AAdd( (oHtml:ValByName( "t4.6" )), " 0,00 ")
	AAdd( (oHtml:ValByName( "t4.7" )), " 0,00")
	AAdd( (oHtml:ValByName( "t4.8" )), " 0,00 ")
	AAdd( (oHtml:ValByName( "t4.9" )), " 0,00")
	AAdd( (oHtml:ValByName( "t4.10" )), "0,00")
	AAdd( (oHtml:ValByName( "t4.11" )), "0")
	AAdd( (oHtml:ValByName( "t4.12" )), "0,00")
		AAdd( (oHtml:ValByName( "t4.13" )), "0")                   
		AAdd( (oHtml:ValByName( "t4.14" )), "0,00")
	
EndIf

// TITULOS A RECEBER
If Len(_aViewTA) > 0
	For _nLin := 1 TO Len(_aViewTA)
		AAdd( (oHtml:ValByName( "t1.1" )), _aViewTA[_nLin][1])
		AAdd( (oHtml:ValByName( "t1.2" )), _aViewTA[_nLin][2])
		AAdd( (oHtml:ValByName( "t1.3" )), DTOC(_aViewTA[_nLin][3]))
		AAdd( (oHtml:ValByName( "t1.4" )), DTOC(_aViewTA[_nLin][4]))
		AAdd( (oHtml:ValByName( "t1.5" )), Transform(_aViewTA[_nLin][5],"@E 999,999,999,999.99"))
		AAdd( (oHtml:ValByName( "t1.6" )), Transform(_aViewTA[_nLin][6],"@E 999,999,999,999.99"))
		AAdd( (oHtml:ValByName( "t1.7" )), _aViewTA[_nLin][7])
		AAdd( (oHtml:ValByName( "t1.8" )), Transform(_aViewTA[_nLin][8],"@E 999"))
		AAdd( (oHtml:ValByName( "t1.9" )), _aViewTA[_nLin][9])
		AAdd( (oHtml:ValByName( "t1.10" )), _aViewTA[_nLin][10])
	Next
Else
	AAdd( (oHtml:ValByName( "t1.1" )), " ")
	AAdd( (oHtml:ValByName( "t1.2" )), " ")
	AAdd( (oHtml:ValByName( "t1.3" )), "   /  /  ")
	AAdd( (oHtml:ValByName( "t1.4" )), "   /  /  ")
	AAdd( (oHtml:ValByName( "t1.5" )), " 0,00 ")
	AAdd( (oHtml:ValByName( "t1.6" )), " 0,00 ")
	AAdd( (oHtml:ValByName( "t1.7" )), " ")
	AAdd( (oHtml:ValByName( "t1.8" )), " 0 ")
	AAdd( (oHtml:ValByName( "t1.9" )), " ")
	AAdd( (oHtml:ValByName( "t1.10" )), " ")
EndIf

// TITULOS RECEBIDOS
If Len(_aViewTR) > 0
	For _nLin := 1 TO Len(_aViewTR)
		AAdd( (oHtml:ValByName( "t2.1" )), _aViewTR[_nLin][1])
		AAdd( (oHtml:ValByName( "t2.2" )), _aViewTR[_nLin][2])
		AAdd( (oHtml:ValByName( "t2.3" )), DTOC(_aViewTR[_nLin][3]))
		AAdd( (oHtml:ValByName( "t2.4" )), DTOC(_aViewTR[_nLin][4]))
		AAdd( (oHtml:ValByName( "t2.5" )), Transform(_aViewTR[_nLin][5],"@E 999,999,999,999.99"))
		AAdd( (oHtml:ValByName( "t2.6" )), Transform(_aViewTR[_nLin][6],"@E 999,999,999,999.99"))
		AAdd( (oHtml:ValByName( "t2.7" )), _aViewTR[_nLin][7])
		AAdd( (oHtml:ValByName( "t2.8" )), Transform(_aViewTR[_nLin][8],"@E 999"))
		AAdd( (oHtml:ValByName( "t2.9" )), _aViewTR[_nLin][9])
		AAdd( (oHtml:ValByName( "t2.10" )), _aViewTR[_nLin][10])
	Next
Else
	AAdd( (oHtml:ValByName( "t2.1" )), " - ")
	AAdd( (oHtml:ValByName( "t2.2" )), " - ")
	AAdd( (oHtml:ValByName( "t2.3" )), "   /  /  ")
	AAdd( (oHtml:ValByName( "t2.4" )), "   /  /  ")
	AAdd( (oHtml:ValByName( "t2.5" )), " 0,00 ")
	AAdd( (oHtml:ValByName( "t2.6" )), " 0,00 ")
	AAdd( (oHtml:ValByName( "t2.7" )), " - ")
	AAdd( (oHtml:ValByName( "t2.8" )), " 0 ")
	AAdd( (oHtml:ValByName( "t2.9" )), " - ")
	AAdd( (oHtml:ValByName( "t2.10" )), " - ")
EndIf   

If TMP->CR_TIPO == "D1" .AND. !lInfoChefe
	U_CONSOLE("Despesa Acessória:"+STR(SC5->C5_DESPESA))
	//DESPESA ACESSÓRIA - incluido por Polli - 17/10/07
	cDespesas :=  Transform(SC5->C5_DESPESA,"@E 999,999,999,999.99") 
	oHtml:ValByName( "C5_DESPESA", cDespesas)
EndIF

// OBS
If !lInfoChefe
	oHtml:ValByName( "OBS", "" )
Endif

//-------------------------------------------------------------
// ALIMENTA A TELA DE PROCESSO DE APROVAÇÃO DE PEDIDO DE VENDAS
//-------------------------------------------------------------
DBSelectarea("SCR")
SCR->(DbOrderNickname("SCRNUM")) //CR_FILIAL + CR_NUM //285911 //@ticket 324242 - T10532 - José Carlos Jr. - Alterado o índice numérico para Nickname.
If !SCR->(DBSeek(xFilial("SCR")+_cNum))
	AAdd( (oHtml:ValByName( "t3.2"    )), "")
	AAdd( (oHtml:ValByName( "t3.3"    )), "")
	AAdd( (oHtml:ValByName( "t3.5"    )), "")
	AAdd( (oHtml:ValByName( "t3.6"    )), "")
Endif
WHILE !SCR->(EOF()) .AND. Rtrim(SCR->(CR_FILIAL+CR_NUM)) == Rtrim(xFilial("SCR")+_cNum)
	If TMP->CR_TIPO == "D1"
		If SCR->CR_TIPO <> "D1"
			dbSkip()
			Loop
		EndIf
	EndIf
	If Left(SCR->CR_TIPO,1) <> "R" .And. Left(SCR->CR_TIPO,1) <> "S" .And. Left(SCR->CR_TIPO,1) <> "D"
		dbSkip()
		Loop
	EndIf
	cSituaca := ""
	Do Case
		Case SCR->CR_STATUS == "01"
			cSituaca := "Aguardando"
		Case SCR->CR_STATUS == "02"
			cSituaca := "Em Aprovacao"
		Case SCR->CR_STATUS == "03"
			cSituaca := "Aprovado"
		Case SCR->CR_STATUS == "04"
			cSituaca := "Bloqueado"
			lBloq := .T.
		Case SCR->CR_STATUS == "05"
			cSituaca := "Nivel Liberado"
	EndCase
	
	_cT4 := UsrRetName(SCR->CR_USERLIB)
	_cT6 := SCR->CR_ZZOBS
	
	AAdd( (oHtml:ValByName( "t3.2"    )), UsrFullName(SCR->CR_USER))
	AAdd( (oHtml:ValByName( "t3.3"    )), cSituaca    )
	AAdd( (oHtml:ValByName( "t3.5"    )), DTOC(SCR->CR_DATALIB))
	AAdd( (oHtml:ValByName( "t3.6"    )), IIF(EMPTY(_cT6),"", _cT6))
	
	SCR->(DBSkip())
ENDDO

// ARRAY DE RETORNO
AADD(_aReturn, oProcess:fProcessId+oProcess:fTaskId)
ConOut("(998) oProcess:cTo: "+oProcess:cTo)

cProcess := oProcess:Start()
U_CONSOLE(cProcess)
IF !"@" $ oProcess:cTO
	_cNome := Posicione("SA3",1,xFilial("SA3")+_cAprov,"A3_NOME")
	aMsg := {}
	aaDD(aMsg, "Sr.(a) " + _cNome )
	AADD(aMsg, " Enviamos o email com o link abaixo para visualização do pedido. ")
	AADD(aMsg, " Referente a analise do Pedido No. " + _cNum )
	AADD(aMsg, " ")
	AADD(aMsg, " ")
	AADD(aMsg, "Atenciosamente ")
	AADD(aMsg, " ")
	AADD(aMsg, "Workflow Protheus")
	AADD(aMsg, " ")
	AADD(aMsg, '<A href=http://'+Alltrim(GetNewPar("MV_WFBRWSR","200.182.30.6:8085"))+'/messenger/emp' + cEmpAnt  + '/' + _cUser + '/' + alltrim(cProcess) + '.htm'+'> Clique aqui ou no link abaixo </A>')
	AADD(aMsg, 'http://' + Alltrim(GetNewPar("MV_WFBRWSR","200.182.30.6:8085"))+'/messenger/emp' + cEmpAnt  + '/' + _cUser + '/' + alltrim(cProcess) + '.htm')// adicionado para mostrar o link

    IF Existblock("MSGWFAC") //adiciona mensagem ao corpo do email
    aMsg := Execblock("MSGWFAC",.F.,.F.,{aMSG,SA1->A1_CGC,nValTotal,_CBLCRED})
    EndIf 

	_cTo := UsrRetMail(_cTo)
	U_CONSOLE(_cTo)
	U_Notifica( _cTo, oProcess:cSubject , aMsg )
ENDIF

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aAreaPB1)
RestArea(aArea)
return aClone( _aReturn )

/*/{Protheus.doc} MontaTitulo

@author Microsiga
@since 08/15/02
@version P11
@uso AP6
@param nOpc, numeric
@type function
/*/

Static Function MontaTitulo(nOpc)	// cOpc=1 Titulos em Aberto / 2=Titulos Recebidos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ{¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ{Ù
Local cQuery 	:= ""
Local cQry 		:= ""
Local cChave 	:= ""
Local aQuery 	:= {}
Local aStru		:= {}
Local aAlias	:= {}
Local aParam 	:= {}
Local aPergunte := {}
Local nI 		:=0
Local nCntfor
Local lCnt		:= .F.
Local cTipoLim 	:= SuperGetMv("MV_CREDCLI")         

CHKFILE("SX1")
DbSelectArea("SX1")
DbSeek("FIC010")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Array com perguntas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    
   
While !Eof() .and. x1_grupo = "FIC010"

    AADD(aPergunte,{X1_PERGUNT,X1_TIPO,X1_TAMANHO,X1_DECIMAL,If(X1_PRESEL==0,1,X1_PRESEL),X1_GSC,X1_VALID,X1_CNT01,AllTrim(X1_DEF01),AllTrim(X1_DEF02),AllTrim(X1_DEF03),AllTrim(X1_DEF04),AllTrim(X1_DEF05),X1_VAR01,If(X1_PRESEL==0,1,X1_PRESEL),X1_F3})
		
    DbSkip()
End
AEVAL(aPergunte,{|x| x[8] := If(x[2]=="N",Val(AllTrim(x[8])),If(x[2]=="D",CTOD(x[8]),Substr(x[8],1,x[3])))})
For nI := 1 to Len(aPergunte)
	AADD(aParam,aPergunte[nI,8])
Next               

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Titulo em Aberto                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( nOpc == 1 )
		aView := {}
	
		dbSelectArea("SX3")
		dbSetOrder(2)

		dbSeek("E1_PREFIXO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_NUM")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_PARCELA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_TIPO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_CLIENTE")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_LOJA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_EMISSAO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VENCTO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VENCREA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VLCRUZ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VALJUR")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aStru ,{"E1_ABT","N",14,2})

		dbSeek("E1_SALDO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_PORCJUR")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_HIST")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aStru ,{"E1_ATR","N",5,0})
		aadd(aStru ,{"XX_RECNO","N",12,0})

		aadd(aQuery,{"E1_MOEDA","N",02,0})

		dbSeek("E1_VALOR")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("X5_DESCRI")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		SX3->(dbSetOrder(1))

	
		cAlias	:= 'FC010QRY01'

	
		If ( Select(cAlias) ==	0 )
			cArquivo := CriaTrab(,.F.)
				aadd(aAlias,{ cAlias , cArquivo })
				aadd(aStru,{"FLAG","L",01,0})
			dbCreate(cArquivo,aStru)
			dbUseArea(.T.,__LocalDriver,cArquivo,cAlias,.F.,.F.)
			If cTipoLim == "L"
				IndRegua(cAlias,cArquivo,"E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")
			Else
				IndRegua(cAlias,cArquivo,"E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")
			Endif
	   		If ( TcSrvType()!="AS/400" )
				lQuery := .T.
				cQuery := ""
				aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
					
				cQuery := "SELECT "+SubStr(cQuery,2)
				cQuery +=         ",SE1.R_E_C_N_O_ SE1RECNO "

				cQuery += " FROM "+RetSqlName("SE1")+" SE1,"
				cQuery += "      "+RetSqlName("SX5")+" SX5"
				cQuery += " WHERE "
					cQuery += "SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
					cQuery += "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
				If cTipoLim == "L"
					cQuery +=        "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery += "SE1.E1_LCWF <> 'N' AND "

				If ( aParam[5] == 2 )
					cQuery +=   "SE1.E1_TIPO<>'PR ' AND "
				EndIf

				cQuery += 		"SE1.E1_FATURA IN('"+Space(Len(SE1->E1_FATURA))+"','NOTFAT') AND "
				cQuery +=      	"SE1.E1_SALDO > 0 AND "
				cQuery +=		"SE1.D_E_L_E_T_<>'*' AND "
				cQuery +=      	"SX5.X5_FILIAL='"+xFilial("SX5")+"' AND "
				cQuery +=		"SX5.X5_TABELA='07' AND "
				cQuery +=		"SX5.X5_CHAVE=SE1.E1_SITUACA AND "
				cQuery +=		"SX5.D_E_L_E_T_<>'*' "

				cQuery += " AND SE1.E1_TIPO NOT LIKE '__-' UNION ALL "+cQuery
				cQuery += " AND SE1.E1_TIPO LIKE '__-'"

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"A"

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
						aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
				
		  	Else
				cQry := "SE1"
			EndIf
            
			If !Eof()
				dbSelectArea(cQry)
			EndIf
			//para a consulta da posição de clientes histórica
			//essa parte não foi alterada, pois o cliente usa TOP - SQL
			If ( !lQuery )
				dbSetOrder(2)
				If cTipoLim == "L"
					dbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
												SA1->A1_COD    == SE1->E1_CLIENTE .And.;
												SA1->A1_LOJA   == SE1->E1_LOJA }
				Else
					dbSeek(xFilial("SE1")+SA1->A1_COD)
					bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
												SA1->A1_COD    == SE1->E1_CLIENTE }
				Endif
				bFiltro:= {|| !(SE1->E1_TIPO $ MVABATIM) .And.;
									If(aParam[5]==2,SE1->E1_TIPO!="PR ",.T.) .And.;
									SE1->E1_SALDO   > 0 }
			Else
				bWhile := {|| !Eof() }
				bFiltro:= {|| .T. }
			EndIf

			While ( Eval(bWhile) )
				If ( Eval(bFiltro) )
					If ( !lQuery )
						dbSelectArea("SX5")
						dbSetOrder(1)
						MsSeek(xFilial("SX5")+"07"+SE1->E1_SITUACA)
					EndIf
					dbSelectArea(cAlias)
					dbSetOrder(1)
					cChave := (cQry)->(E1_CLIENTE)+(cQry)->(E1_LOJA) +;
								 (cQry)->(E1_PREFIXO)+(cQry)->(E1_NUM)+;
								 (cQry)->(E1_PARCELA)
					cChave += If((cQry)->(E1_TIPO)	$ MVABATIM, "",;
					              (cQry)->(E1_TIPO))
					If ( !dbSeek(cChave) )
						RecLock(cAlias,.T.)
					Else
						RecLock(cAlias,.F.)
					EndIf
					DbSetOrder(1)
					nTotAbat := 0
					For nCntFor := 1 To Len(aStru)
						Do Case
							Case ( AllTrim(aStru[nCntFor][1])=="X5_DESCRI" )
								If ( lQuery )
									(cAlias)->X5_DESCRI := (cQry)->X5_DESCRI
								Else
									(cAlias)->X5_DESCRI := SX5->X5_DESCRI
								EndIf

							Case ( AllTrim(aStru[nCntFor][1])=="E1_VALJUR" )

							Case ( AllTrim(aStru[nCntFor][1])=="E1_ABT" )
								nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
								If ( (cQry)->(E1_TIPO)	$ MVABATIM )
									(cAlias)->E1_ABT := (nTotAbat := xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,(cQry)->(E1_EMISSAO),,nTaxaM))
								Endif
								If ( !lQuery )
									(cAlias)->E1_ABT := (nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA))
								Endif

							Case ( AllTrim(aStru[nCntFor][1])=="E1_SALDO" )
								nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
								If ( (cQry)->(E1_TIPO)	$ MVABATIM )
									(cAlias)->E1_SALDO -= nTotAbat
								Else
									(cAlias)->E1_SALDO += xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,(cQry)->(E1_EMISSAO),,ntaxaM)
								EndIf
								If ( !lQuery )
									(cAlias)->E1_SALDO -= nTotAbat
								EndIf

							Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
								If !( (cQry)->(E1_TIPO)	$ MVABATIM )
									If ( lQuery )
										(cAlias)->XX_RECNO := (cQry)->SE1RECNO
									Else
										(cAlias)->XX_RECNO := SE1->(RecNo())
									EndIf
								Endif

							Case ( AllTrim(aStru[nCntFor][1])=="E1_TIPO" )
								If ( Empty((cAlias)->E1_TIPO) )
									(cAlias)->E1_TIPO := (cQry)->E1_TIPO
								EndIf
							Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
								If dDataBase > DataValida((cQry)->E1_VENCTO)
									(cAlias)->E1_ATR := dDataBase - (cQry)->E1_VENCTO
								Else
									(cAlias)->E1_ATR := dDataBase - DataValida((cQry)->E1_VENCTO,.T.)
								Endif
							Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )

							OtherWise
								If ( lQuery )
									If !( (cQry)->(E1_TIPO)	$ MVABATIM )
										(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
									Endif
								Else
									(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
								Endif
						EndCase
					Next nCntFor
					dbSelectArea(cAlias)
					If nTotAbat = 0
						If ( (cAlias)->E1_SALDO <= 0 )
							dbDelete()
						EndIf
					Endif
					(cAlias)->E1_VALJUR := xMoeda(FaJuros((cQry)->E1_VALOR,(cAlias)->E1_SALDO,(cAlias)->E1_VENCTO,(cQry)->E1_VALJUR,(cQry)->E1_PORCJUR,(cQry)->E1_MOEDA,(cQry)->E1_EMISSAO),(cQry)->E1_MOEDA,1)
					MsUnLock()
				EndIf
				dbSelectArea(cQry)
				dbSkip()
			EndDo
			If ( lQuery ) .And. !Eof()
				dbSelectArea(cQry)
				dbCloseArea()
			EndIf
			dbSelectArea(cAlias)
			IndRegua(cAlias,cArquivo,"DTOS(E1_VENCREA)")
		EndIf

		//aView := {}
		dbSelectArea(cAlias)
		dbGotop()
		While !EOF()
			AADD( aView, {E1_PREFIXO + '-' + E1_NUM + '/' + E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_SALDO, X5_DESCRI, E1_ATR, E1_HIST, E1_LOJA})
			dbSkip()
		Enddo
		
		(cAlias)->(dbCloseArea())
		Ferase(cArquivo+GetDBExtension())
		Ferase(cArquivo+OrdBagExt())

	Case ( nOpc == 2 )
	aView := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Titulos Recebidos                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek("E1_PREFIXO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_NUM")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_PARCELA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_TIPO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E1_LOJA  ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_MOEDA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VALOR")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VLCRUZ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		For nCntFor := 1 To 4
			dbSeek(	Iif(nCntFor==1,	"E5_VLJUROS",;
						Iif(nCntFor==2,	"E5_VLMULTA",;
						Iif(nCntFor==3,	"E5_VLCORRE",;
										"E5_VLDESCO"))))
			aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Next

		dbSeek("E5_VALOR")
		aadd(aStru ,{"E1_PAGO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VALOR")
		aadd(aStru ,{"E1_VLMOED2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_VLMOED2")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_TXMOEDA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_EMISSAO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VENCTO")
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_VENCREA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E5_DATA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E5_DTDISPO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_NATUREZ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E1_NUMLIQ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_BANCO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_AGENCIA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_CONTA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_HISTOR")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_MOTBX")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_CNABOC")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSeek("E5_TIPODOC")
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aStru ,{"E1_ATR","N",5,0})

		dbSeek("E1_VALJUR")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aadd(aStru,{"XX_RECNO","N",12,0})

		aadd(aQuery,{"E1_TXMOEDA","N",17,4})

	
	
		cAlias	:= 'FC010QRY02'
	
		SX3->(DbSetOrder(1))

		If ( Select(cAlias) ==	0 )
			cArquivo := CriaTrab(,.F.)
			aadd(aAlias,{ cAlias , cArquivo })
			aadd(aStru,{"FLAG","L",01,0}) 
			dbCreate(cArquivo,aStru)
			dbUseArea(.T.,__LocalDriver,cArquivo,cAlias,.F.,.F.)
			IndRegua(cAlias,cArquivo,"E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")

		
			If ( TcSrvType()!="AS/400" )
				cQuery := ""
				aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
				cQuery := "SELECT TOP 10 "+SubStr(cQuery,2)+",SE5.R_E_C_N_O_ SE5RECNO , SE5.E5_DOCUMEN E5_DOCUMEN "
				cQuery += "FROM "+RetSqlName("SE1")+" SE1,"
				cQuery +=         RetSqlName("SE5")+" SE5 "
				cQuery += "WHERE "
					cQuery	+= "SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
					cQuery 	+= "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
				If cTipoLim == "L"
					cQuery +=       "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
				Endif
				cQuery  += "SE1.E1_LCWF <> 'N' AND "

				If ( aParam[5] == 2 )
					cQuery +=   "SE1.E1_TIPO<>'PR ' AND "
				EndIf
				If aParam[8] == 2
					cQuery += " SE1.E1_FATURA IN('"+Space(Len(SE1->E1_FATURA))+"','NOTFAT') AND "
				Endif

				If cPaisLoc != "BRA"
					cQuery += "SE1.E1_TIPO NOT IN" + FormatIn(cCheques,"|") + " AND "
				Endif
				If aParam[09] == 2
					cQuery += "( SE1.E1_NUMLIQ ='"+Space(Len(SE1->E1_NUMLIQ))+"' OR "
					cQuery += "( SE1.E1_NUMLIQ <>'"+Space(Len(SE1->E1_NUMLIQ))+"' AND "
					cQuery += " SE1.E1_TIPOLIQ ='"+Space(Len(SE1->E1_TIPOLIQ))+"')) AND "
				Endif
				cQuery +=		"SE1.E1_TIPO NOT LIKE '__-' AND "
				cQuery +=		"SE1.E1_TIPO NOT IN ('RA ','PA ','"+MV_CRNEG+"','"+MV_CPNEG+"') AND "
				cQuery +=		"SE1.D_E_L_E_T_<>'*' AND " 
					cQuery +=       "SE5.E5_FILIAL='"+xFilial("SE5")+"' AND "
				cQuery +=		"SE5.E5_NATUREZ=SE1.E1_NATUREZ AND "
				cQuery +=		"SE5.E5_PREFIXO=SE1.E1_PREFIXO AND "
				cQuery +=		"SE5.E5_NUMERO=SE1.E1_NUM AND "
				cQuery +=		"SE5.E5_PARCELA=SE1.E1_PARCELA AND "
				cQuery +=		"SE5.E5_TIPO=SE1.E1_TIPO AND "
				cQuery +=		"SE5.E5_CLIFOR=SE1.E1_CLIENTE AND "
				cQuery +=		"SE5.E5_LOJA=SE1.E1_LOJA AND "
				cQuery +=		"SE5.E5_RECPAG='R' AND "
				cQuery +=		"SE5.E5_SITUACA<>'C' AND "
				cQuery +=		"SE5.D_E_L_E_T_<>'*' AND NOT EXISTS ("
				cQuery += "SELECT A.E5_NUMERO "
				cQuery += "FROM "+RetSqlName("SE5")+" A "
				cQuery += "WHERE 
					cQuery += 		"A.E5_FILIAL='"+xFilial("SE5")+"' AND "
				cQuery +=		"A.E5_NATUREZ=SE5.E5_NATUREZ AND "
				cQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
				cQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
				cQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
				cQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
				cQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
				cQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
				cQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
				cQuery +=		"A.E5_TIPODOC='ES' AND "
				cQuery +=		"A.E5_RECPAG<>'R' AND "
				cQuery +=		"A.D_E_L_E_T_<>'*')"
				cQuery +=		" ORDER BY E5_DATA DESC"

				cQuery := ChangeQuery(cQuery)
				cQry   := cArquivo+"A"

			        	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)

				aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})

				dbSelectArea(cQry)
				bWhile := {|| !Eof() }
				bFiltro:= {|| (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" }
				cAnterior := ""
				While ( Eval(bWhile) )
					If ( Eval(bFiltro) )
						dbSelectArea(cAlias)
						dbSetOrder(1)
						RecLock(cAlias,.T.)
						For nCntFor := 1 To Len(aStru)
							Do Case
								Case ( AllTrim(aStru[nCntFor][1])=="E1_PAGO" )
									If ( (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
										(cAlias)->E1_PAGO += (cQry)->E5_VALOR
									EndIf
								Case ( AllTrim(aStru[nCntFor][1])=="E1_VLMOED2" )
									If ( (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" ) .And. (cQry)->E1_MOEDA > 1
										(cAlias)->E1_VLMOED2 := If((cQry)->E1_MOEDA > 1, (cQry)->E5_VLMOED2, (cQry)->E5_VALOR)
									EndIf
								Case ( AllTrim(aStru[nCntFor][1])=="E1_SALDO2" )
									If ( (cQry)->(E1_TIPO)	$ MVABATIM )
										(cAlias)->E1_SALDO2 -= nTotAbat
									Else
										(cAlias)->E1_SALDO2 += (cQry)->(E1_SALDO)
										(cAlias)->E1_SALDO2 += (cAlias)->E1_SDACRES - (cAlias)->E1_SDDECRE
									EndIf
									If ( !lQuery )
										(cAlias)->E1_SALDO2 -= nTotAbat
									EndIf
								Case ( AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ" )
									If ( (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
										If cAnterior != (cQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
											(cAlias)->E1_VLCRUZ := (cQry)->E1_VLCRUZ
											cAnterior := (cQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
										Endif
									EndIf
								Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
									If (cQry)->E5_DATA > DataValida((cQry)->E1_VENCTO,.T.)
										(cAlias)->E1_ATR := (cQry)->E5_DATA - (cQry)->E1_VENCTO
									Else
										(cAlias)->E1_ATR := (cQry)->E5_DATA - DataValida((cQry)->E1_VENCTO,.T.)
									Endif
								Case cPaisLoc=="BRA" .And. ( AllTrim(aStru[nCntFor][1])=="E5_TXMOEDA" )
									If (cQry)->E1_MOEDA == 1
										(cAlias)->E5_TXMOEDA := 1
	                  				Else
										If (cQry)->E5_TXMOEDA == 0
											(cAlias)->E5_TXMOEDA := ((cQry)->E5_VALOR /(cQry)->E5_VLMOED2)
										Else
											(cAlias)->E5_TXMOEDA := (cQry)->E5_TXMOEDA
										Endif
									Endif
								Case ( AllTrim(aStru[nCntFor][1])=="E1_NUMLIQ" )
									If (cQry)->E5_MOTBX == "LIQ"
										If Empty( (cQry)->E1_NUMLIQ )
											(cAlias)->E1_NUMLIQ := SUBSTR((cQry)->E5_DOCUMEN,1,TamSx3("E1_NUMLIQ")[1])
										Else
											(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
										Endif
									Endif
								Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
									(cAlias)->XX_RECNO := (cQry)->SE5RECNO

								Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )

								OtherWise
									(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
							EndCase
						Next nCntFor
						(cAlias)->(MsUnLock())
					EndIf
					dbSelectArea(cQry)
					dbSkip()
				EndDo
				dbSelectArea(cQry)
				dbCloseArea()
			//para a consulta da posição de clientes histórica
			//essa parte não foi alterada, pois o cliente usa TOP - SQL
			Else
				dbSelectArea("SE1")
				dbSetOrder(2)
				dbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
				bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
									SA1->A1_COD    == SE1->E1_CLIENTE .And.;
									SA1->A1_LOJA   == SE1->E1_LOJA }
				bFiltro:= {|| 	SubStr(SE1->E1_TIPO,3,1)!="-" .And.;
									If(aParam[5]==2,SE1->E1_TIPO!="PR ",.T.) .And.;
									IIf(cPaisLoc == "BRA",.T.,!(SE1->E1_TIPO$cCheques)) .And.;
									If(!Empty(SE1->E1_FATURA) .And. Substr(SE1->E1_FATURA,1,6) != "NOTFAT",aParam[8]==1, .T.).AND.;
									IIF(aParam[09] == 2, Empty(SE1->E1_NUMLIQ) .OR. (!Empty(SE1->E1_NUMLIQ) .And. Empty(SE1->E1_TIPOLIQ)),.T.)}
	
				While ( Eval(bWhile) )
					If ( Eval(bFiltro) )
						dbSelectArea("SE5")
						dbSetOrder(7)
						dbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA)
	
						While ( !Eof() .And. xFilial("SE5") == SE5->E5_FILIAL .And.;
								SE1->E1_PREFIXO == SE5->E5_PREFIXO .And.;
								SE1->E1_NUM == SE5->E5_NUMERO      .And.;
								SE1->E1_PARCELA == SE5->E5_PARCELA .And.;
								SE1->E1_TIPO == SE5->E5_TIPO       .And.;
								SE1->E1_CLIENTE == SE5->E5_CLIFOR	.And.;
								SE1->E1_LOJA == SE5->E5_LOJA )
	
							If ((!SE5->E5_TIPO $ "RA /PA /"+MV_CRNEG+"/"+MV_CPNEG) .And. !TemBxCanc() .and. ;
										SE5->E5_SITUACA <> "C" .And. SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
								RecLock(cAlias,.T.)
								For nCntFor := 1 To Len(aStru)
									Do Case
									Case ( AllTrim(aStru[nCntFor][1])=="E1_PAGO" )
										If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
											(cAlias)->E1_PAGO += SE5->E5_VALOR
										EndIf
									Case ( AllTrim(aStru[nCntFor][1])=="E1_VLMOED2" )
										If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" ) .And. SE1->E1_MOEDA > 1
											(cAlias)->E1_VLMOED2 := If(SE1->E1_MOEDA > 1, SE5->E5_VLMOED2, SE5->E5_VALOR)
										EndIf
									Case ( AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ" )
										If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
											If cAnterior != SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
												(cAlias)->E1_VLCRUZ := SE1->E1_VLCRUZ
												cAnterior := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
											Endif
										Endif
									Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
										If SE5->E5_DATA > DataValida(SE1->E1_VENCTO,.T.)
											(cAlias)->E1_ATR := SE5->E5_DATA - SE1->E1_VENCTO
										Else
											(cAlias)->E1_ATR := SE5->E5_DATA - DataValida(SE1->E1_VENCTO,.T.)
										Endif
									Case cPaisLoc=="BRA" .And. ( AllTrim(aStru[nCntFor][1])=="E5_TXMOEDA" )
		                     			If SE1->E1_MOEDA == 1
	        		             				(cAlias)->E5_TXMOEDA := 1
	            							Else
											If SE5->E5_TXMOEDA == 0
												(cAlias)->E5_TXMOEDA := (SE5->E5_VALOR /SE5->E5_VLMOED2)
											Else
												(cAlias)->E5_TXMOEDA := SE5->E5_TXMOEDA
											Endif
										Endif
									Case ( AllTrim(aStru[nCntFor][1])=="E1_NUMLIQ" )
										If SE5->E5_MOTBX == "LIQ"
											If Empty(SE1->E1_NUMLIQ)
												(cAlias)->E1_NUMLIQ := SUBSTR(SE5->E5_DOCUMEN,1,TamSx3("E1_NUMLIQ")[1])
											Else
												(cAlias)->(FieldPut(nCntFor,SE1->(FieldGet(FieldPos(aStru[nCntFor][1])))))
											Endif
										Endif
									Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
										(cAlias)->XX_RECNO := SE5->(RecNo())
									Case ( "E5_"$AllTrim(aStru[nCntFor][1]) )
										(cAlias)->(FieldPut(nCntFor,SE5->(FieldGet(FieldPos(aStru[nCntFor][1])))))
									Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )
									OtherWise
										(cAlias)->(FieldPut(nCntFor,SE1->(FieldGet(FieldPos(aStru[nCntFor][1])))))
									EndCase
								Next nCntFor
								(cAlias)->(MsUnLock())
							EndIf
							dbSelectArea("SE5")
							dbSkip()
						EndDo
					EndIf
					dbSelectArea("SE1")
					dbSkip()
				EndDo
			
			EndIf
			
			dbSelectArea(cAlias)
			IndRegua(cAlias,cArquivo,"DTOS(E1_VENCREA)")
		EndIf

		
		dbSelectArea(cAlias)
		dbGotop()
		While !EOF()
			AADD( aView, {E1_PREFIXO + '-' + E1_NUM + '/' + E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_PAGO, E5_MOTBX, E1_ATR, E5_HISTOR, E1_LOJA})
			dbSkip()
		Enddo
		
		(cAlias)->(dbCloseArea())
		Ferase(cArquivo+GetDBExtension())
		Ferase(cArquivo+OrdBagExt())
	
EndCase

Return(aView)

/*/{Protheus.doc} MontaItemPV

@author Microsiga
@since 08/15/02
@version P11
@uso AP6
@param _cFilial, characters
@param _cPedido, characters
@type function
/*/

Static Function MontaItemPV(_cFilial,_cPedido)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aReturn 		:= {}
Local _nC9_TOTAL 	:= 0
Local cQuery		:= ""
//margem c3
Local nFreteItem	:= 0
Local nTotPedido	:= 0
Local nPerPed		:= 0
Local nTotal		:= 0
Local nPis			:= 0
Local nCofins		:= 0
Local nIpi			:= 0
Local nIcm			:= 0
Local nTotImp		:= 0
Local nValIcm		:= 0 
Local nCusto		:= 0
Local nPrecoVen		:= 0
Local nItem			:= 1
//Local nC6Margem   := 0

DBSelectArea("SC6")
DBSetOrder(1)
DBSeek(xFilial("SC6")+_cPedido)
While ! SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == _cPedido
    
	DbSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(xFilial("SB1")+SC6->C6_PRODUTO)

	If Empty(SC6->C6_PRCFIN) .OR. (SC6->C6_PRCFIN)== 0
		nValor1 := SC6->C6_PRCVEN
		nDescPed 	:= (SC6->C6_QTDVEN * SC6->C6_PRCVEN)-(SC6->C6_QTDVEN * SC6->C6_PRCLIST)
		nDescperped := (1 - ((SC6->C6_QTDVEN * SC6->C6_PRCVEN)/(SC6->C6_QTDVEN * SC6->C6_PRCLIST))) * 100
	else
		nValor1 := SC6->C6_PRCFIN
		nDescPed 	:= (SC6->C6_QTDVEN * SC6->C6_PRCFIN)-(SC6->C6_QTDVEN * SC6->C6_PRCLIST)
		nDescperped := (1 - ((SC6->C6_QTDVEN * SC6->C6_PRCFIN)/(SC6->C6_QTDVEN * SC6->C6_PRCLIST))) * 100
	Endif 

	_nC9_TOTAL	:= SC6->C6_QTDVEN * SC6->C6_PRCVEN
	nTotal 		:= SC6->C6_VALOR
	dbSelectArea("DAI")
	dbSetOrder(3)
	If MsSeek(xFilial("DAI")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC5->C5_NUM)
		DbSelectArea("PAD")
		DbSetOrder(1)
		If DbSeek(xFilial("PAD")+SC5->C5_TRANSP+DAI->DAI_PERCUR)
			If PAD->PAD_TPCALC == "F" .Or. PAD->PAD_TPCALC == "V"
				nFreteItem := 0
				nTotPedido := 0
		        cQuery := "SELECT SUM(C6_VALOR) TOTAL "
		        cQuery += "FROM " + RetSqlName("SC6")+" SC6 "
		        cQuery += "WHERE "
		        cQuery += "SC6.C6_FILIAL = '" + xFilial("SC6") +"' "
		      	cQuery += "AND SC6.C6_NUM = '" + SC5->C5_NUM + "' "
		      	cQuery += "AND SC6.D_E_L_E_T_ = '' "

		      	cQuery := ChangeQuery(cQuery)
		      	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .T., .T.)
			  	nTotPedido  :=  TRB->TOTAL
			  	nPerPed		:=  SC6->C6_VALOR / nTotPedido
			  	nFreteItem	:=  nFrete * nPerPed
			EndIf
			If PAD->PAD_TPCALC == "P"
				nFreteItem := 0
				nTotPedido := 0
				cQuery := "SELECT C6_PRODUTO, C6_QTDVEN "
				cQuery := "FROM " + RetSqlName("SC6")+" SC6 "
				cQuery += "WHERE "
				cQuery += "SC6.C6_FILIAL = '" + xFilial("SC6") +"' "
				cQuery += "AND SC6.C6_NUM = '" + SC5->C5_NUM + "' "
				cQuery += "AND SC6.D_E_L_E_T_ = '' "

				cQuery := ChangeQuery(cQuery)
		      	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TEMP", .T., .T.)

				While !EOF()
					SB1->(DBSeek(xFilial("SB1")+TEMP->C6_PRODUTO))
					nTotPedido  := nTotPedido + (SB1->B1_PESBRU * TEMP->C6_QTDVEN)
					DBSkip()
				EndDo
			  	nPerPed		:=  nTotal / nTotPedido
			  	nFreteItem	:=  nFrete * nPerPed
			EndIf
		Endif
	EndIf

	U_RetImpos(SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,SC6->C6_VALOR,SC6->C6_VALDESC,SC6->C6_CLI,SC6->C6_LOJA,@nPis, @nCofins, @nIpi, @nIcm)	
	
	cQuery := "SELECT TOP 1 (D1_VALIMP5 / D1_QUANT) + (D1_VALIMP6 / D1_QUANT)  AS TOTAL  FROM " + RetSqlName("SD1")+ " SD1 "  
	cQuery += "WHERE D1_FILIAL = '" + xFilial("SD1") +"' AND D1_COD = '" + SC6->C6_PRODUTO + "' "
	cQuery += "AND D1_LOCAL = '" + SC6->C6_LOCAL + "' AND D1_TIPO = 'N' AND D_E_L_E_T_ = '' AND D1_QUANT <> '0' " // - TQZZWL
    cQuery += "ORDER BY D1_EMISSAO DESC, D1_DOC DESC"
    cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRBSD1", .T., .T.)
	TCSetField("TRBSD1","TOTAL", "N",10,2)				  		                                     
	nTotImp := (TRBSD1->TOTAL) - ((nPis/SC6->C6_QTDVEN)+(nCofins/SC6->C6_QTDVEN))
	
	
	DbSelectArea("SB2")
	DBSetOrder(1)
	DBSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
	
	SB1->(DBSeek(xFilial("SB1")+SC6->C6_PRODUTO))
	If SB1->B1_PROC == AllTrim(GetMv("MV_CODSHEL"))	
		               
		nCusto		:= Round(SB2->B2_CM1 / SB1->B1_VOLUME,2)
		//nC6Margem   := Round(SC6->C6_MARGEM / SB1->B1_VOLUME, 2)
        nPrecoVen	:= Round(SC6->C6_PRCVEN / SB1->B1_VOLUME,2)
		nValIcm		:= Round(nIcm / SB1->B1_VOLUME,2)
		nFreteItem	:= Round(nFreteItem / SB1->B1_VOLUME,2)
		nTotImp		:= Round(nTotImp / SB1->B1_VOLUME,2)        
		If nTotImp < 0
			nTotImp := (-1) * nTotImp
		EndIf	

		/*If GetMV("MV_MRGBRUT") == "S"
			nMargem := Round(nC6Margem - nValIcm - nFreteItem,2)
		Else
			nMargem := Round(nC6Margem - nFreteItem,2)
		EndIf */
		
		If GetMV("MV_MRGBRUT") == "S"
			nMargem := Round((nPrecoVen  - nCusto) - nValIcm - nFreteItem,2)
		Else
			nMargem := Round((nPrecoVen - nCusto) - nFreteItem,2)
		EndIf 
	
		nMargem := Round(nMargem - nTotImp,2)	 
		
	Else
		nCusto		:= Round(SB2->B2_CM1,2)
        nPrecoVen	:= Round(SC6->C6_PRCVEN,2)	
//	    nC6Margem   := Round(SC6->C6_MARGEM / SC6->C6_QTDVEN, 2)
		nValIcm		:= Round(nIcm / SC6->C6_QTDVEN,2)
		nFreteItem	:= Round(nFreteItem / SC6->C6_QTDVEN,2)
		nTotImp		:= Round(nTotImp / SC6->C6_QTDVEN,2)
		If nTotImp < 0
			nTotImp := (-1) * nTotImp
		EndIf	
							
		If GetMV("MV_MRGBRUT") == "S"
			nMargem := Round((nPrecoVen  - nCusto) - nValIcm - nFreteItem,2)
		Else
			nMargem := Round((nPrecoVen - nCusto) - nFreteItem,2)
		EndIf 
	
		nMargem := Round(nMargem - nTotImp,2)	 	  		
	EndIf
	SF4->(DbSetOrder(1))
	SF4->(xFilial("SF4")+SC6->C6_TES)
	TRBSD1->(dbCloseArea())                    	
		AADD(aReturn,{SC6->C6_ITEM,SC6->C6_PRODUTO,SB1->B1_DESC,SB1->B1_UM,SC6->C6_QTDVEN,SC6->C6_PRCVEN,_nC9_TOTAL,nDescPed,nDescperped,SC6->C6_MARGEM,SaldoSB2(), nMargem, SC6->C6_QTDMED, SC6->C6_PRCMED, SC6->C6_LOCAL, SC6->C6_CODPAI, SF4->F4_DUPLIC})
	nItem++
	SC6->(DBskip())
EndDo
Return(aReturn)

/*/{Protheus.doc} AlcDoc2
Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios)
@author Aline Correa do Vale
@since 07.08.2001
@version P11
@uso Generico
@param aDocto, array,ExpA1 = Array com informacoes do documento 
      [1] Numero do documento              
      [2] Tipo de Documento                
      [3] Valor do Documento               
      [4] Codigo do Aprovador              
      [5] Codigo do Usuario                
      [6] Grupo do Aprovador               
      [7] Aprovador Superior               
      [8] Moeda do Documento               
      [9] Taxa da Moeda                    
     [10] Data de Emissao do Documento     
     [11] Grupo de Compras                  
@param dDataRef, date, Data de referencia para o saldo 
@param nOper, numeric,Operacao a ser executada       
1 = Inclusao do documento        
2 = Estorno do documento         
3 = Exclusao do documento        
4 = Aprovacao do documento       
5 = Estorno da Aprovacao         
6 = Bloqueio Manual da Aprovacao 
@param  cWF, characters, Respondido a 1 Vez ou a 2
@param  lMENU, logical, Chamado via Menu do Sistema .T. or .F. 
@type function
/*/
User Function AlcDoc2(aDocto,dDataRef,nOper, cWF, lMENU)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDocto	:= aDocto[1]
Local cTipoDoc	:= aDocto[2]
Local cAprov	:= If(aDocto[4]==Nil,"",aDocto[4])
Local cUsuario	:= If(aDocto[5]==Nil,"",aDocto[5])
Local aArea		:= GetArea()
Local aAreaSCR  := SCR->(GetArea())
Local cAuxNivel	:= ""
Local nRec		:= 0
Local lRetorno	:= .T.

dDataRef 	:= dDataBase
cDocto 		:= cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))
cWF	   		:= IIF(cWF==Nil,  "", cWF)
lMENU  		:= IIF(lMENU==Nil, .F., lMENU)  // SE .T. UTILIZADA VIA MENU DO SISTEMA

IF !lMENU
	CHKFile("SAK")
	CHKFile("SC5")
	CHKFile("SCR")
	CHKFile("SAL")
ENDIF


If nOper == 1  //Inclusao do Documento
EndIf

If nOper == 3  //exclusao do documento
EndIf

If nOper == 4 //Aprovacao do documento
	U_CONSOLE(" 6 - Operacao 4 -Aprovacao ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera o pedido pelo aprovador.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SCR")
	cAuxNivel := CR_NIVEL

	// SE OPCAO FOR PELO MENU - EXECUTA KILLPROCESS PARA O WF
	IF !EMPTY(SCR->CR_WFID) .AND. lMENU
		WFKillProcess(SCR->CR_WFID)
	ENDIF

	U_CONSOLE(" 6 -Aprovacao - CR STATUS = 03")

	Reclock("SCR",.F.)
	SCR->CR_STATUS	:= "03"
	SCR->CR_ZZOBS	:= If(Len(aDocto)>10,aDocto[11],"")
	SCR->CR_DATALIB	:= dDataBase
	SCR->CR_USERLIB	:= cUsuario
	SCR->CR_LIBAPRO	:= cAprov

	SCR->(MsUnlock())

	dbSelectArea("SCR")
	SCR->(DbOrderNickname("SCRNUM")) //CR_FILIAL + CR_NUM //285911 //@ticket 324242 - T10532 - José Carlos Jr. - Alterado o índice numérico para Nickname.
	SCR->(dbSeek(xFilial("SCR")+cDocto))

	nRec := RecNo()
	While !Eof() .And. xFilial("SCR")+cDocto== CR_FILIAL+CR_NUM
		//Retirado por Max Ivan (Nexus) em 07/11/2018, após análise de que quando existiam bloqueios de S1 (Doação) e R? (Outros bloqueios), não seguia para
		//os próximos apos liberação da primeira alçada. Conforme CHAMADO aberto pelo Thiago da Agricopel, pelo número 25
		/*If Left(SCR->CR_TIPO,1) <> Left(cTipoDoc,1)
			dbSkip()
			Loop
		EndIf*/

		U_CONSOLE(" 6 -Aprovacao - LOOP SCR " + CR_FILIAL+CR_NUM+CR_TIPO + CR_NIVEL + CR_STATUS )

		If CR_STATUS != "03"
			Reclock("SCR",.F.)
			CR_STATUS := "02"
			MsUnlock()
			Exit
		Endif
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reposiciona e verifica se ja esta totalmente liberado.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	U_CONSOLE(" 4 -Aprovacao - Reposiciona e verifica se ja esta totalmente liberado. ")

	dbSelectArea("SCR")
	dbGoto(nRec)
	While !Eof() .And. xFilial("SCR")+cDocto == CR_FILIAL+CR_NUM
		//If Left(SCR->CR_TIPO,1) <> Left(cTipoDoc,1)
		//	dbSkip()
		//	Loop
		//EndIf

		If CR_STATUS != "03" .And. CR_STATUS != "05"
			lRetorno := .F.
			Exit
		EndIf
		dbSkip()
	EndDo
EndIf

If nOper == 5  //Estorno da Aprovacao
EndIf

If nOper == 6  //Bloqueio manual
	U_CONSOLE(TMSGCONS + cValtoChar(ProcLine()) + " nOper: 6 - Bloqueio")

	dbSelectArea("SCR")
	cAuxNivel := CR_NIVEL

	// SE OPCAO FOR PELO MENU - EXECUTA KILLPROCESS PARA O WF
	IF !EMPTY(SCR->CR_WFID) .AND. lMENU
		WFKillProcess(SCR->CR_WFID)
	ENDIF
	
	U_CONSOLE(TMSGCONS + cValtoChar(ProcLine()) + " nOper: 6 - Bloqueio")
	
	Reclock("SCR",.F.)
	SCR->CR_STATUS	:= "04"
	SCR->CR_ZZOBS	:= If(Len(aDocto)>10,aDocto[11],"Reprovaçao manual")
	SCR->CR_DATALIB	:= dDataBase
	SCR->CR_USERLIB	:= cUsuario	//SAK->AK_USER
	SCR->CR_LIBAPRO	:= cAprov 	//SAK->AK_COD
	SCR->(MsUnlock())
	
	cNome			:= UsrRetName(cUsuario)
	
	//@ticket 285911 - T10532 - José Carlos Jr. - Padrão adicionou novo índice na V12 que passou a ser o "3". O customizado passa a ser "4".
	dbSelectArea("SCR")
	SCR->(DbOrderNickname("SCRNUM")) //CR_FILIAL + CR_NUM //285911 //@ticket 324242 - T10532 - José Carlos Jr. - Alterado o índice numérico para Nickname.
	SCR->(dbSeek(xFilial("SCR")+cDocto))

	nRec := SCR->(RecNo())
	While !Eof() .And. xFilial("SCR")+cDocto == CR_FILIAL+CR_NUM
		If Left(SCR->CR_TIPO,1) <> Left(cTipoDoc,1)
			dbSkip()
			Loop
		EndIf

		U_CONSOLE(" 6 - Bloqueio - LOOP SCR " + CR_FILIAL+CR_NUM+CR_TIPO + CR_NIVEL + CR_STATUS )

		If  CR_STATUS != "04"
			Reclock("SCR",.F.)
			CR_STATUS	:= "04"
			CR_DATALIB	:= dDataBase
			CR_USERLIB	:= cUsuario //SAK->AK_USER
			CR_ZZOBS	:= "Reprovado por " + ALLTRIM(cNome)
			MsUnlock()

			// SE OPCAO FOR PELO MENU - EXECUTA KILLPROCESS PARA O WF
			IF !EMPTY(SCR->CR_WFID) .AND. lMENU
				WFKillProcess(SCR->CR_WFID)
			ENDIF
		EndIf
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia email informando a rejeicao da aprovacao               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SCR")
	SCR->(DbOrderNickname("SCRNUM")) //CR_FILIAL + CR_NUM //285911 //@ticket 324242 - T10532 - José Carlos Jr. - Alterado o índice numérico para Nickname.
	SCR->(DbSeek(xFilial("SCR")+cDocto))
	While !Eof() .And. xFilial("SCR")+cDocto == CR_FILIAL+CR_NUM
		If Left(SCR->CR_TIPO,1) <> Left(cTipoDoc,1)
			U_CONSOLE(TMSGCONS + cValtoChar(ProcLine()) + " CR_TIPO: " + SCR->CR_TIPO + " | cTipoDoc: " + cTipoDoc)
			dbSkip()
			Loop
		EndIf

		DbSelectArea("SC5")
		DbSetOrder(1)
		If DbSeek(xFilial("SC5")+Alltrim(SCR->CR_NUM),.f.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Muda a legenda no pedido de venda                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_BLQ := "9"
			MsUnlock()

			If !Empty(SC5->C5_VEND1)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa o aprovador obrigatorio                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PB1")
				DbSetOrder(1)
				DbSeek(xFilial("PB1")+SC5->C5_VEND1+"1",.f.)
				While !EOF() .and. PB1->PB1_FILIAL+PB1->PB1_VEND+PB1->PB1_TPALC == xFilial("SC5")+SC5->C5_VEND1+"1"
					U_CONSOLE(TMSGCONS + cValtoChar(ProcLine()) + " PB1_MAILIN: " + PB1->PB1_MAILIN + " | PB1_APROV: " + AllTrim(AllToChar(PB1->PB1_APROV)))
					
					If PB1->PB1_MAILIN == "S" .or. PB1->PB1_APROV == SC5->C5_VEND1						
						DbSelectArea("SA3")
						DbSetOrder(1)
						If DbSeek(xFilial("SA3")+PB1->PB1_APROV,.F.)
							//@ticket 285911 - T10532 - José Carlos Jr. - Tipo (A3_AXTIPO) é obrigatório para o envio de e-mail na função EnviaAC().
							/*================================================================
							  Envia o email de rejeição (referente à solicitação de aprovação)
							================================================================*/
							aAreaSCR := SCR->(GetArea())
							EnviaAC(SCR->CR_FILIAL, Alltrim(SCR->CR_NUM), SA3->A3_CODUSR, PB1->PB1_APROV, SCR->(CR_FILIAL+CR_NUM), SCR->CR_TOTAL, SCR->CR_MOTIVO, "\WORKFLOW\HTML\TEMP\FACInfoChefe.htm", SA3->A3_AXTIPO)
							RestArea(aAreaSCR)
						Endif

					Endif
					PB1->(DbSkip())
				Enddo
				Exit
			Endif
		Endif
		DbSelectArea("SCR")
		dbSkip()
	EndDo
	lRetorno := .F.
EndIf

dbSelectArea("SCR")
RestArea(aAreaSCR)
RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} RetCBox
Funcao que monta um array com todas as opcoes do combo
box a partir da leitura do dicionario de dados SX3.
@author 
@since 
@version P11
@param cCampo, characters
@param cConteudo, characters
@type function
/*/
Static Function RetCBox(cCampo,cConteudo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		:= GetArea()
Local aItens	:= {}
Local cReturn	:= ""
Local nPosArr	:= 0

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek(AllTrim(cCampo))
	aItens   	:= RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )
	nPosArr 	:= Ascan( aItens, { |aBox| aBox[2] = cConteudo} )
	If nPosArr > 0
		cReturn := Upper(AllTrim(aItens[nPosArr][3]))
	Endif
EndIf


RestArea(aArea)

Return(cReturn)

/*/{Protheus.doc} Notifica
Funcao de notificacao.
@author Adriano Luis Brandao
@since 08/02/07
@version P11
@uso AP - SHELL
@param cTo, characters
@param  cTitle, characters
@param  aMsg, array
@param  aFiles , array
@type function
/*/
USER FUNCTION Notifica(cTo, cTitle, aMsg, aFiles )
Local cBody, nInd

cBody := '<html>'
cBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
cBody += 'size=2><STRONG>Workflow - Serviço Envio de Mensagens</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 TO Len(aMsg)
	cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
Next
cBody += '</html>'

WFNotifyAdmin( cTo , cTitle, cBody, aFiles )

RETURN