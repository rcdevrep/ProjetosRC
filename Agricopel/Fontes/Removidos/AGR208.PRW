#INCLUDE "AGR208.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"
#Include "Font.ch"
#Include "Colors.ch"
#Include "cheque.ch"
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR208    �Autor  �Microsiga           � Data �  03/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para Inclusao de cheque Troco Individual          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR208()
	LOCAL nSavRec := RecNo()

	PRIVATE LGESTAOCORP := .F.
	PRIVATE aTELA[0][0],aGETS[0]
	PRIVATE aRotina := { {OemToAnsi(STR0001), "AxPesqui", 0 , 1},;  // "Pesquisar"
	{OemToAnsi(STR0003), "U_AGR208AVS", 0 , 3},;  // "Avulsos"
	{OemToAnsi(STR0005), "fa390Can", 0 , 3} }  // "caNcelar" // -> Substuido pela fun��o padr�o para gerar FKs
	//{OemToAnsi(STR0005), "U_AGR208Can", 0 , 3} }  // "caNcelar"

	Private cBanco390, cAgencia390, cConta390, cCheque390, dVencIni, dVencFim
	Private nQtde390   // Incluido por Valdecir em 10.11.03
	Private nLimite, cNatur390, cBenef390, cForn390, cHist390, aTitulos:={}
	Private cFil390,cLojaBen

	//��������������������������������������������������������������Ŀ
	//� Chamada da fun��o pergunte											  �
	//����������������������������������������������������������������
	Set Key VK_F12 To fA390Perg()
	pergunte("FIN390",.F.)

	//��������������������������������������������������������������Ŀ
	//� Define o cabe�alho principal do programa.						  �
	//����������������������������������������������������������������
	PRIVATE cCadastro := OemToAnsi(STR0006)  //"Cheques a Pagar"
	Private cMarca 	:= GetMark()

	//��������������������������������������������������������������Ŀ
	//� Verifica o numero do Lote 											  �
	//����������������������������������������������������������������
	Private cLote
	LoteCont( "FIN" )
	IF ExistBlock("F390BROW")
		ExecBlock("F390BROW",.f.,.f.)
	Endif
	//��������������������������������������������������������������Ŀ
	//� Endereca a Fun��o de BROWSE											  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"SEF",,"EF_IMPRESS" )

	//��������������������������������������������������������������Ŀ
	//� Recupera a Integridade dos dados									  �
	//����������������������������������������������������������������
	dbSelectArea("SEF")
	dbSetOrder(1)
	dbGoTo( nSavRec )

	Set Key VK_F12 To
Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fa390Avu	� Autor � Wagner Xavier 		  � Data � 21/03/94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastra cheque avulso.												  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �fa390Avu()																  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �FINA390																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGR208AVS( cAlias, nRec, nOpcE )

	Local oDlg
	Local nValor390
	Local lPadrao,cPadrao:="567"
	Local cArquivo
	Local nTotal	:= 0
	Local nHdlPrv	:= 0
	Local nOpca 	:= 0
	Local cLiberado := GetMv("MV_LIBCHEQ")
	Local aFINA100  := {}
	Local cChaveCH  := ""
	Local lA390HIST := ExistBlock("A390HIST")
	Local xx        := 0

	Private lMsErroAuto := .F.

	cBanco390		:= CriaVar("EF_BANCO")
	cAgencia390 	:= Criavar("EF_AGENCIA")
	cConta390		:= Criavar("EF_CONTA")
	nValor390		:= 0
	nQtde390		:= 0   // Incluido por Valdecir em 10.11.03
	cBenef390		:= Space(40)
	cHist390 		:= Space(40)
	cNatur390		:= Space(10)
	cCheque390		:= Space(15)
	cForn390		:= Space( 6)
	nSavRec			:= RecNO()

	//��������������������������������������������������������������Ŀ
	//� Verifica se data do movimento n�o � menor que data limite de �
	//� movimentacao no financeiro    										  �
	//����������������������������������������������������������������
	If !DtMovFin()
		Return
	Endif

	While .T.
		cBanco390	:= CriaVar("EF_BANCO")
		cAgencia390 := Criavar("EF_AGENCIA")
		cConta390	:= Criavar("EF_CONTA")
		nValor390  	:= 0
		nQtde390	:= 0	// Incluido por Valdecir em 10.11.03
		cBenef390  	:= Space(40)
		cHist390   	:= Space(40)
		cNatur390  	:= Space(10)
		cCheque390 	:= Space(15)
		cForn390    := Space( 6)
		cLojaBen    := Space( 2)
		nOpca       := 0

		If lA390HIST
			cHist390:=padr(ExecBlock("A390HIST",.f.,.f.),40)
		Endif

		xcCMC7     := ''
		xcCMC7     := Space(34)
		xcTipo1    := Space(03)
		xcBanco    := Space(03)
		xcAgencia  := Space(05)
		xcConta    := Space(10)
		xcCheque   := Space(06)
		xcDigito1  := Space(01)
		xcDigito2  := Space(01)
		xcDigito3  := Space(01)
		xcComp     := Space(03)
		//	xcDtVenc   := CToD("  /  /  ")
		xcDtVenc   := dDataBase
		xcVlCheque := 0
		xcBenef    := Space(30)
		xcVlJuros  := 0
		xlReturn   := .f.
		xlCMC7     := .f.
		xxEscolha  := .f.
		xxEscolha1 := .f.
		xoFnt      := nil
		xcPrefixo  := SM0->M0_CODFIL+'3'
		xcTipo1    := 'CH'
		Private xoV1, xoV2, xoV3, xoV4
		xcTipo     := 'Leitora'
		xlFaz      := .f.
		DEFINE FONT oFnt  NAME "Arial" SIZE 10,13.5 BOLD
		DEFINE FONT oFnt1 NAME "Arial" SIZE 10,13.5 BOLD
		DEFINE FONT oFnt2 NAME "Arial" SIZE 08,11

		_NumCH := 1
		xcVlCheque := 0
		xTotCheque := 0

		DEFINE FONT oFnt  NAME "Arial" SIZE 10,15.5 BOLD
		DEFINE FONT oFnt1 NAME "Arial" SIZE 08,09.5 BOLD

		//	DEFINE MSDIALOG oDlgChq TITLE OemToAnsi("Inclus�o de Cheques Para Compensa��o") FROM 01,01 TO 210,725 PIXEL
		DEFINE MSDIALOG oDlgChq TITLE OemToAnsi("Inclus�o de Cheques Para Compensa��o") FROM 01,01 TO 270,725 PIXEL

		@ 001, 016 SAY 	OemToAnsi(STR0012)                                               SIZE 021, 07 OF oDlg PIXEL  //"Banco"
		@ 010, 016 MSGET	cBanco390 F3 "SA6"   Valid Fa390Banco(1) Picture "@!" SIZE 021, 11 OF oDlg PIXEL
		@ 001, 052 SAY 	OemToAnsi(STR0013)                                    SIZE 028, 07 OF oDlg PIXEL  //"Ag�ncia"
		@ 010, 052 MSGET	cAgencia390 			Valid Fa390Banco(2) Picture "@!" SIZE 028, 11 OF oDlg PIXEL
		@ 001, 087 SAY 	OemToAnsi(STR0014)                                               SIZE 025, 07 OF oDlg PIXEL  //"Conta"
		@ 010, 087 MSGET	cConta390				Valid Fa390Banco(3) Picture "@!" SIZE 039, 11 OF oDlg PIXEL

		@ 001, 133 SAY 	OemToAnsi(STR0021)                                    SIZE 046, 07 OF oDlg PIXEL  //"Natureza"
		@ 010, 133 MSGET	cNatur390 F3 "SED"   Valid fa390Natur() Picture "@!"  SIZE 049, 11 OF oDlg PIXEL

		@ 30,024 SAY xoV3 var OemToAnsi("Vcto: ") of oDlgchq FONT oFnt2 PIXEL SIZE 050,010 COLOR CLR_BLUE
		@ 30,070 Get xcDtVenc Size 040,010 object xoDtVenc

		@ 30,120 SAY xoV4 var OemToAnsi("Valor: ") of oDlgchq FONT oFnt2 PIXEL SIZE 050,010 COLOR CLR_BLUE
		@ 30,146 Get xcVlCheque Picture "@E 999,999,999.99" Size 050,010 object xoVlCheque

		@ 30,200 SAY xoV4 var OemToAnsi("Benef.: ") of oDlgchq FONT oFnt2 PIXEL SIZE 53, 07 COLOR CLR_BLUE
		@ 30,246 Get xcBenef	Picture "@!S30"	SIZE 100,010 object xoBenef

		//@ 07,220 SAY xoV4 var OemToAnsi("Juros: ") of oDlgchq FONT oFnt2 PIXEL SIZE 050,010 COLOR CLR_BLUE
		//@ 07,246 Get xcVlJuros Picture "@E 999,999.99" Size 040,010 object xoVlJuros

		@ 45,038 SAY "CMC7" of oDlgchq FONT oFnt1 PIXEL SIZE 050,010 COLOR CLR_RED
		@ 45,100 GET xcCMC7 valid PegaCMC7() size 120,10 object xoCMC7
		@ 63,014 SAY xoV3 var OemToAnsi("Bco: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
		@ 60,038 GET xcBanco valid NaoVazio() F3 "SA6" When .f. object xoBanco
		@ 63,070 SAY xoV3 var OemToAnsi("Agen.: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
		@ 60,101 GET xcAgencia valid NaoVazio() When .f. object xoAgencia
		@ 63,135 SAY xoV3 var OemToAnsi("Conta: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
		@ 60,165 GET xcConta  valid NaoVazio() When .f. SIZE 060,010 object xoConta
		@ 75,014 SAY xoV3 var OemToAnsi("Num Cheque: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
		@ 75,055 GET xcCheque  valid Jaexiste() When .f. object xoCheque
		@ 75,108 GET xcComp valid Calcdv123() When .f. object xoComp
		@ 78,132 SAY xoV3 var OemToAnsi("Dv.1: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
		@ 75,155 GET xcDigito1  valid CalcDv1() When .f. object xodigito1
		@ 78,175 SAY xoV3 var OemToAnsi("Dv.2: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
		@ 75,192 GET xcDigito2  Valid CalcDv2() When .f. object xodigito2
		@ 78,212 SAY xoV3 var OemToAnsi("Dv.3: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
		@ 75,232 GET xcDigito3 valid CalcDv3() When .f. object xodigito3

		//	@ 80,200 BMPBUTTON TYPE 1   ACTION MaisCheque()
		//	@ 80,230 BMPBUTTON TYPE 2   ACTION Finaliza()

		DEFINE SBUTTON FROM 110, 200 TYPE 1 ACTION (If(Fa390Ok(oDlgChq),(nOpca := 1,oDlgChq:End()),nOpca:=0)) ENABLE OF oDlgChq
		//	DEFINE SBUTTON FROM 07, 204 TYPE 1 ACTION (If(Fa390Ok(oDlg),(nOpca := 1,oDlg:End()),nOpca:=0)) ENABLE OF oDlg

		DEFINE SBUTTON FROM 110, 230 TYPE 2 ACTION oDlgChq:End() ENABLE OF oDlgChq

		ACTIVATE MSDIALOG oDlgChq CENTERED

		//	cBanco390	:= xcBanco
		//	cAgencia390 := xcAgencia
		//	cConta390	:= xcConta
		nValor390  	:= xcVlCheque
		nQtde390		:= 1
		cBenef390  	:= xcBenef
		cHist390   	:= "TALAO"
		//	cNatur390  	:= '205008'
		cCheque390 	:= xcCheque
		cForn390    := Space( 6)
		cLojaBen    := Space( 2)

		If nOpca == 2 .Or. nOpca == 0
			Exit
		ElseIf nOpca == 1
			//��������������������������������������������������������������Ŀ
			//� Grava cheque no sistema.												  �
			//����������������������������������������������������������������

			cINICHEQ := cCheque390
			cFIMCHEQ := Space(15)

			For xx := 1 to nQtde390

				cQuery := ""
				cQuery += "SELECT * "   // Posiciona Cheque SEF para lancamento contabil pela Reconcilia�ao 23/08/2006
				cQuery += "FROM "+RetSqlName("SEF")+" (NOLOCK)"
				cQuery += "WHERE EF_FILIAL = '"+xFilial("SEF")+"' "
				cQuery += "AND D_E_L_E_T_ <> '*' "
				cQuery += "AND EF_BANCO    = '"+cBanco390+"' "
				cQuery += "AND EF_AGENCIA  = '"+cAgencia390+"' "
				cQuery += "AND EF_CONTA    = '"+cConta390+"' "
				cQuery += "AND EF_NUM      = '"+cCheque390+"' "
				cQuery += "AND EF_CMC7     = '"+xcCMC7+"' "
				cQuery += "AND EF_DATA     = '"+DTOS(dDataBase)+"' "
				cQuery += "AND EF_IMPRESS <> 'C' "

				If Select("SEF001") <> 0
					dbSelectArea("SEF001")
					dbCloseArea()
				Endif

				TCQuery cQuery NEW ALIAS "SEF001"

				DbSelectArea("SEF001")
				While !Eof()
					MSGInfo(' >> Cheque ja Existe na Base para esta data !! << ')
					Return
					DbSelectArea("SEF001")
					DbSkip()
				End

				BEGIN TRANSACTION

					cChaveCH := FWUUIDV4()

					Reclock( "SEF", .T. )

					SEF -> EF_FILIAL	:= cFilial
					SEF -> EF_NUM		:= cCheque390
					SEF -> EF_VALOR	    := nValor390
					SEF -> EF_BANCO	    := cBanco390
					SEF -> EF_AGENCIA   := cAgencia390
					SEF -> EF_CONTA	    := cConta390
					SEF -> EF_BENEF	    := cBenef390
					SEF -> EF_DATA 	    := dDataBase
					SEF -> EF_HIST 	    := cHist390
					//SEF -> EF_LIBER     := cLiberado
					SEF -> EF_ORIGEM    := "FINA390AVU" // "AGR093AVS" // AQUI FICA ASSIM PARA CONCILIA�AO OCORRER CORRETAMENTE
					SEF -> EF_FORNECE   := cForn390
					SEF -> EF_LOJA      := cLojaBen
					SEF -> EF_CMC7      := xcCMC7
					SEF -> EF_VENCTO    := xcDtVenc
					SEF -> EF_IMPRESS   := 'S' //Alterado para para n�o deletar  e contabilizar na Rotina padrao Padrao fa390Can -> chamado 75357
					SEF -> EF_LIBER     := 'S'//Alterado para para n�o deletar  e contabilizar na Rotina padrao Padrao fa390Can -> chamado 75357
					SEF -> EF_FILORIG	:= cFilAnt//Alterado para para n�o deletar  e contabilizar na Rotina padrao Padrao fa390Can -> chamado 75357
					SEF -> EF_IDSEF		:= cChaveCH
					SEF -> EF_SEQUENC   := "01"
					//SEF -> EF_TITULO    := cCheque390
					SEF->(MsUnlock())

					//��������������������������������������������������������������Ŀ
					//� Registra na movimenta��o Banc�ria. 								  �
					//����������������������������������������������������������������
					If ( cLiberado == "S" )

						aFINA100:= { {"E5_FILIAL", cFilial ,Nil},;
						{"E5_BANCO" ,cBanco390 ,Nil},;
						{"E5_AGENCIA" ,cAgencia390 ,Nil},;
						{"E5_CONTA" ,cConta390 ,Nil},;
						{"E5_DATA"	, dDataBase,Nil},;
						{"E5_DTDISPO", xcDtVenc ,Nil},;
						{"E5_DTDIGIT", dDataBase,Nil},;
						{"E5_VENCTO", dDataBase,Nil},;
						{"E5_TIPODOC", "CH",Nil},; // Alterado de DH para CH Chamado chamado 75357
						{"E5_VALOR"	, nValor390,Nil},;
						{"E5_NATUREZ", cNatur390,Nil},;
						{"E5_MOEDA"  , "01" ,Nil},;
						{"E5_SEQ"    , "01" ,Nil},; // Chamado chamado 75357
						{"E5_RECPAG" , "P",Nil},;
						{"E5_BENEF",   cBenef390,Nil},;
						{"E5_NUMCHEQ", cCheque390,Nil},;
						{"E5_CLIFOR", cForn390,Nil},;
						{"E5_LOJA", cLojaBen,Nil},;
						{"E5_MODSPB", IIf(SpbInUse(),"3",""),Nil},;
						{"E5_HISTOR" , cHist390,Nil}}

						MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)

						If lMsErroAuto

							MostraErro()

						EndIf

						/*/
						Reclock( "SE5", .T. )
						SE5 -> E5_FILIAL  := cFilial
						SE5 -> E5_BANCO	  := cBanco390
						SE5 -> E5_AGENCIA := cAgencia390
						SE5 -> E5_CONTA	  := cConta390
						SE5 -> E5_RECPAG  := "P"
						SE5 -> E5_DATA 	  := dDataBase
						SE5 -> E5_HISTOR  := cHist390
						SE5 -> E5_BENEF	  := cBenef390
						SE5 -> E5_DTDIGIT := dDataBase
						SE5 -> E5_VALOR	  := nValor390
						SE5 -> E5_NUMCHEQ := cCheque390
						SE5 -> E5_NATUREZ := cNatur390
						SE5 -> E5_TIPODOC := "DH"
						SE5 -> E5_DTDISPO := xcDtVenc //E5_DATA
						SE5 -> E5_CLIFOR  := cForn390
						SE5 -> E5_LOJA    := cLojaBen
						SE5 -> E5_VENCTO  := dDataBase
						If SpbInUse()
						Replace E5_MODSPB With "3"
						Endif
						MsUnlock("SE5")
						//��������������������������������������������������Ŀ
						//� Atualiza saldo bancario.								  �
						//����������������������������������������������������
						// Retirado abaixo Deco 26/02/2004 para nao atualizar saldo Banco de cheque troco. voltado por vava 28/06/2004
						AtuSalBco(cBanco390,cAgencia390,cConta390,SE5->E5_DATA,SE5->E5_VALOR,"-")
						/*/
					EndIf

				END TRANSACTION

				//�����������������������������������������������������Ŀ
				//� Monta Lan�amento contabil.								  �
				//�������������������������������������������������������
				cPadrao := '567'
				If (lPadrao := VerPadrao( cPadrao ) .and. mv_par03 == 1)
					nHdlPrv:=HeadProva(cLote,"FINA390",Substr(cUsuario,7,6),@cArquivo)
					nTotal+=DetProva(nHdlPrv,cPadrao,"FINA390",cLote)
					RodaProva(nHdlPrv,nTotal)
					//�����������������������������������������������������Ŀ
					//� Envia para Lan�amento Contabil 							  �
					//�������������������������������������������������������
					cA100Incl(cArquivo,nHdlPrv,3,cLote,Iif(mv_par02==1,.T.,.F.),.F.)

					RecLock("SEF")
					Replace EF_LA With "S"
					SEF->(MsUnlock())
				EndIf
				cCheque390 := Soma1(cCheque390)
			Next xx

			cFIMCHEQ := cCheque390

			cQuery := "SELECT *, R_E_C_N_O_ AS NRECNO  "
			cQuery += "FROM "+RetSqlName("SE5")+" (NOLOCK) "
			cQuery += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
			cQuery += "AND D_E_L_E_T_ = '' "
			cQuery += "AND E5_DATA = '"+Dtos(dDataBase)+"' "
			cQuery += "AND E5_BANCO = '"+cBanco390+"' "
			cQuery += "AND E5_AGENCIA = '"+cAgencia390+"' "
			cQuery += "AND E5_CONTA = '"+cConta390+"' "
			cQuery += "AND E5_NUMCHEQ BETWEEN '"+cINICHEQ+"' AND '"+cFIMCHEQ+"' "
			cQuery += "AND E5_RECONC = 'x' "

			If (Select("MSE5") <> 0)
				dbSelectArea("MSE5")
				dbCloseArea()
			Endif

			//cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "MSE5"

			DbSelectArea("MSE5")
			While !Eof()

				MsgStop("Registro ja Conciliado, reportar a �rea de TI!"+MSE5->E5_NUMCHEQ)

				DbSelectArea("SE5")
				DbGoto(MSE5->NRECNO)
				RecLock("SE5",.F.)
				SE5->E5_RECONC := " "
				MsUnLock("SE5")

				DbSelectArea("MSE5")
				MSE5->(DbSkip())
			EndDo
		EndIf
	EndDo

	//��������������������������������������������������������������Ŀ
	//� Recupera a Integridade dos dados									  �
	//����������������������������������������������������������������
	MsUnlockAll()
	dbSelectArea("SEF")
	dbSetOrder(1)
	dbGoTo( nSavRec )

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fa390Can	� Autor � Alessandro Freire	  � Data � 18/04/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cancela cheques sobre titulo										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �fa390can()																  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �FINA390																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function AGR208CAN()

	LOCAL oDlg
	LOCAL cAlias	 := Alias()
	LOCAL nOrder	 := IndexOrd()
	LOCAL nRec		 := Recno()
	LOCAL lF390Canc := ExistBlock("F390CANC")

	LOCAL lPadrao,  cPadrao := "568"        // Incluido Deco 14/07/04 para cancelar contabilizacao
	LOCAL cArquivo                          // Incluido Deco 14/07/04 para cancelar contabilizacao
	LOCAL nTotal	:= 0                    // Incluido Deco 14/07/04 para cancelar contabilizacao
	LOCAL nHdlPrv	:= 0                    // Incluido Deco 14/07/04 para cancelar contabilizacao

	PRIVATE cBanco390
	PRIVATE cAgencia390
	PRIVATE cConta390
	PRIVATE cCheque390
	PRIVATE nOpcA

	cBanco390		:= CriaVar("EF_BANCO")
	cAgencia390 	:= Criavar("EF_AGENCIA")
	cConta390		:= Criavar("EF_CONTA")
	cCheque390		:= Space( 15 )

	While .T.

		//��������������������������������������������������������������Ŀ
		//� Verifica se data do movimento n�o � menor que data limite de �
		//� movimentacao no financeiro    										  �
		//����������������������������������������������������������������
		If !DtMovFin()
			Exit
		Endif
		//����������������������������������������������������������������������Ŀ
		//� Procura no SEF o registro correspondente do SEF posiciona no momento.�
		//������������������������������������������������������������������������
		dbSelectArea( "SEF" )
		dbSetOrder( 3 )
		dbSeek( xFilial() 			+;
		SE2->E2_PREFIXO	+;
		SE2->E2_NUM 		+;
		SE2->E2_PARCELA	+;
		SE2->E2_TIPO	)
		//������������������������������������������������������Ŀ
		//� Procura no SEF o registro que contem o No. do Cheque �
		//� Considera Fornecedor na Chave								�
		//��������������������������������������������������������
		While !Eof() .And. ;
		SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO == ;
		SEF->EF_PREFIXO+SEF->EF_TITULO+SEF->EF_PARCELA+SEF->EF_TIPO .And. ;
		(Empty( SEF->EF_NUM ) .or. SE2->E2_FORNECE != SEF->EF_FORNECE )
			dbSkip()
		EndDo
		//��������������������������������������������������������������Ŀ
		//� Recebe dados do cheque a ser cancelado.							  �
		//����������������������������������������������������������������
		cBanco390	:= SEF->EF_BANCO
		cAgencia390 := SEF->EF_AGENCIA
		cConta390	:= SEF->EF_CONTA
		cCheque390	:= SEF->EF_NUM
		dData390 	:= SEF->EF_DATA
		dEmissao    := CTOD('  /  /  ')

		nOpca := 0

		//	DEFINE MSDIALOG oDlg FROM 10, 5 TO 22, 46 TITLE OemToAnsi(STR0038)  //"Cancelar Cheque"
		DEFINE MSDIALOG oDlg FROM 10, 5 TO 25, 46 TITLE OemToAnsi(STR0038)  //"Cancelar Cheque"
		@ 15,20	Say OemToAnsi(STR0040)  //"Banco : "
		@ 1,7.5 MSGET cBanco390 F3 "SA6" Valid Fa390Banco(1)

		@ 27,20	Say OemToAnsi(STR0041)  //"Ag�ncia : "
		@ 2,7.5 MSGET cAgencia390	Valid Fa390Banco(2)

		@ 39,20	Say OemToAnsi(STR0042)  //"Conta : "
		@ 3,7.5 MSGET cConta390	Valid Fa390Banco(3)

		@ 51,20	Say OemToAnsi(STR0043)  //"N�m Cheque:"
		@ 4,7.5 MSGET cCheque390 	Valid Fa390Cheq(2)

		//	@ .3,1 TO 5,20 OF oDlg

		@ 65, 20 SAY OemToAnsi("Emissao : ")
		@ 65, 60 GET dEmissao SIZE 50,50

		DEFINE SBUTTON FROM 092,097 TYPE 1 ACTION (nOpca := 1,If(!Empty(cBanco390),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 092,124.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED

		*
		* Esta parte para buscar o cheque correto para cancelar  Deco 11/07/2006
		*
		cQuery := "SELECT *, R_E_C_N_O_ AS NRECNO  "
		cQuery += "FROM "+RetSqlName("SEF")+" (NOLOCK) "
		cQuery += "WHERE EF_FILIAL = '"+xFilial("SEF")+"' "
		cQuery += "AND D_E_L_E_T_ = '' "
		cQuery += "AND EF_DATA = '"+Dtos(dEmissao)+"' "
		cQuery += "AND EF_BANCO = '"+cBanco390+"' "
		cQuery += "AND EF_AGENCIA = '"+cAgencia390+"' "
		cQuery += "AND EF_CONTA = '"+cConta390+"' "
		cQuery += "AND EF_NUM BETWEEN '"+cCheque390+"' AND '"+cCheque390+"' "

		If (Select("MSEF") <> 0)
			dbSelectArea("MSEF")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "MSEF"

		nCont := 0
		DbSelectArea("MSEF")
		While !Eof()

			nCont := nCont + 1

			DbSelectArea("MSEF")
			DbSkip()
		EndDo

		If nCont <> 1
			MsgStop ("Nao existe Cheque para esta parametriza�ao!!!")
			Exit
		EndIf

		DbSelectArea("MSEF")
		DbGotop()

		DbSelectArea("SEF")
		DbGoto(MSEF->NRECNO) // Posiciona cheque para Cancelamento - Deco 11/07/2006

		If nOpca == 1
			*
			* Caso database difente emissao cheque nao permite cancelamento
			*
			If SEF->EF_DATA <> dDataBase
				MsgStop ("Data emissao cheque diferente Data Base Microsiga")
				Exit
			Endif
			*
			* Verifica cheque ja cancelado
			*
			If SEF->EF_IMPRESS == 'C'
				MsgStop ("Cheque ja Cancelado")
				Exit
			Endif

			//Ponto de entrada para permissao ou nao do cancelamento do cheque
			If lF390Canc
				If !(ExecBlock("F390CANC",.F.,.F.))
					Exit
				Endif
			Endif

			BEGIN TRANSACTION

				//�����������������������������������������������������Ŀ  // Incluido Deco 14/07/04 para cancelar contabilizacao
				//� Monta Lan�amento contabil.								  �
				//�������������������������������������������������������
				cPadrao := '568'
				If (lPadrao := VerPadrao( cPadrao ) .and. mv_par03 == 1)
					nHdlPrv:=HeadProva(cLote,"FINA390",Substr(cUsuario,7,6),@cArquivo)
					nTotal+=DetProva(nHdlPrv,cPadrao,"FINA390",cLote)
					RodaProva(nHdlPrv,nTotal)
					//�����������������������������������������������������Ŀ
					//� Envia para Lan�amento Contabil 							  �
					//�������������������������������������������������������
					cA100Incl(cArquivo,nHdlPrv,3,cLote,Iif(mv_par02==1,.T.,.F.),.F.)
				EndIf                                                        // Incluido Deco 14/07/04 para cancelar contabilizacao

				//  Esta parte para cancelar Movimento bancario(SE5) do Cheque Avulso/Talao pela cecilia - Deco 12/07/2006
				cQuery := "SELECT *, R_E_C_N_O_ AS NRECNO  "
				cQuery += "FROM "+RetSqlName("SE5")+" (NOLOCK) "
				cQuery += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
				cQuery += "AND D_E_L_E_T_ = '' "
				cQuery += "AND E5_DATA = '"+Dtos(dEmissao)+"' "
				cQuery += "AND E5_BANCO = '"+cBanco390+"' "
				cQuery += "AND E5_AGENCIA = '"+cAgencia390+"' "
				cQuery += "AND E5_CONTA = '"+cConta390+"' "
				cQuery += "AND E5_NUMCHEQ BETWEEN '"+cCheque390+"' AND '"+cCheque390+"' "

				If (Select("MSE5") <> 0)
					dbSelectArea("MSE5")
					dbCloseArea()
				Endif

				TCQuery cQuery NEW ALIAS "MSE5"

				DbSelectArea("MSE5")
				While !Eof()

					DbSelectArea("SE5")
					DbGoto(MSE5->NRECNO)
					RecLock("SE5",.F.)
					SE5->E5_RECONC  := " "
					SE5->E5_SITUACA := "C"
					MsUnLock("SE5")

					DbSelectArea("MSE5")
					MSE5->(DbSkip())
				EndDo

				// Grava cheque como nao impresso para ficar somente 1 registro no SE5 e nao aparecer na reconc. manual Feito Deco 22/09/2004
				//          RecLock("SEF",.F.)
				//          SEF->EF_IMPRESS := 'N'
				//          MsUnlock("SEF")

				//			lCancelou := fa390ver() // Comentado esta parte para nao excluir fisicamente do SEF(Postos) o registro Deco 13/07/2006

				// Grava cheque como cancelado para aparecer legenda preta na tela cheques Feito Deco 22/09/2004
				dbSelectArea( "SEF" )
				dbSetOrder(1)
				dbSeek(xFilial()+cBanco390+cAgencia390+cConta390+cCheque390)
				While !Eof() .And. SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_NUM == ;
				cBanco390+cAgencia390+cConta390+cCheque390
					IF SEF->EF_DATA == dEmissao
						// Grava cheque como cancelado para aparecer legenda preta na tela cheques Feito Deco 22/09/2004
						RecLock("SEF",.F.)
						SEF->EF_IMPRESS := 'C'
						SEF->(MsUnlock())
					EndIf
					dbSkip()
				EndDo

			END TRANSACTION

			//		If lCancelou != Nil .And. ! lCancelou
			//			// No retorno da Fa390Ver, o SE2 e o SEF estao posicionados nos
			//			// registros que foram invalidados.
			//			If Empty( SE2->E2_IMPCHEQ )
			//				Help( " ", 1, "AGR208AVS" )
			//			ElseIf SEF->EF_IMPRESS == "C"
			//				Help( " ", 1, "JA CANCELA")
			//			Endif
			//		Endif

		ElseIf nOpca  == 2 .Or. nOpca == 0
			Exit
		Else
			Loop
		EndIf
	EndDo

	dbSelectArea( cAlias )
	dbSetOrder( nOrder )
	dbGoto( nRec )
	Return( Nil )

	****************************************************************************
	*																									*
	*							FUNCOES GENERICAS DO PROGRAMA 								*
	*																									*
	****************************************************************************
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA390Perg � Autor � Wagner Xavier 		  � Data � 26/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Ativa Parametros do Programa										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � 																			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Gen�rico 																  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FA390PERG()
	Pergunte("FIN390",.T.)
Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fa390Natur� Autor � Wagner Xavier 		  � Data � 21/03/94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida natureza digitada.											  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �fa390Natur() 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �FINA390																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FA390NATUR( )
	Local cAlias := Alias( )
	Local lRet	 := .t.

	If Empty( cNatur390 )
		Return ( .f. )
	Endif

	dbSelectArea( "SED" )
	If !(dbSeek( cFilial + cNatur390 ) )
		Help( " ",1,"fa390Natur" )
		lRet := .f.
	Endif

	//Validacao extra do usuario
	If lRet
		IF ExistBlock("F390NATU")
			lRet := ExecBlock("F390NATU",.f.,.f.)
		Endif
	Endif

	dbSelectArea( cAlias )
Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FA390Ok	� Autor � Pilar S. Albaladejo   � Data � 20/12/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se dados essenciais foram digitados 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA390													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fa390Ok(oDlgChq)

	Local lRet := .T.

	/*
	Local nX

	For nX := 1 To Len(oDlg:aControls)
	If ValType(oDlg:aControls[nX]) == "O" .And.;
	!Empty(oDlg:aControls[nX]:bValid)

	lRet:=Eval(oDlg:aControls[nX]:bValid)
	If ValType(lRet) != "L"
	lRet := .T.
	Endif
	If !lRet
	Help(" ",1,"Fa390Erro1")
	Exit // Sai no primeiro campo invalido
	Endif

	Endif
	Next

	If lRet .And. ExistBlock("FA390TOK")
	lRet := Execblock("FA390TOK",.F.,.F.,oDlg)
	Endif
	*/
Return lRet

/*
Static Function MaisCheque()

	Close(oDlgChq)
	_ret := .T.
Return(.T.)

Static Function Finaliza()

	Close(oDlgChq)
	_ret := .F.

Return(.F.)
*/

Static function PegaCMC7()

	Local I := 0

	//xcCmc7   := SubStr(xcCmc7,3,34)

	xcBanco  := Subs(xcCMC7,2,3)
	xcAgencia:= Subs(xcCMC7,5,4)+" "
	xcConta  := StrZero(Val(Subs(xcCMC7,26,7)),10)
	xcConta1 := StrZero(Val(Subs(xcCMC7,23,10)),10)
	xcCheque := Subs(xcCMC7,14,6)+Space(9)
	xcComp   := Subs(xcCMC7,11,3)

	xoBanco:Refresh()
	xoAgencia:Refresh()
	xoConta:Refresh()
	xoCheque:Refresh()

	xx:=0

	xcBancoV := xcBanco+xcAgencia

	nByte11 := 2 * Val(Subs(xcBancoV  ,7,1))
	nByte10 := 1 * Val(Subs(xcBancoV  ,6,1))
	nByte9  := 2 * Val(Subs(xcBancoV  ,5,1))
	nByte8  := 1 * Val(Subs(xcBancoV  ,4,1))
	nByte7  := 2 * Val(Subs(xcBancoV  ,3,1))
	nByte6  := 1 * Val(Subs(xcBancoV  ,2,1))
	nByte5  := 2 * Val(Subs(xcBancoV  ,1,1))
	nByte11 := IIf(nByte11>9,Val(SubStr(AllTrim(Str(nByte11)),1,1))+Val(SubStr(AllTrim(Str(nByte11)),2,1)),nByte11)
	nByte10 := IIf(nByte10>9,Val(SubStr(AllTrim(Str(nByte10)),1,1))+Val(SubStr(AllTrim(Str(nByte10)),2,1)),nByte10)
	nByte9  := IIf(nByte9>9,Val(SubStr(AllTrim(Str(nByte9)),1,1))+Val(SubStr(AllTrim(Str(nByte9)),2,1)),nByte9)
	nByte8  := IIf(nByte8>9,Val(SubStr(AllTrim(Str(nByte8)),1,1))+Val(SubStr(AllTrim(Str(nByte8)),2,1)),nByte8)
	nByte7  := IIf(nByte7>9,Val(SubStr(AllTrim(Str(nByte7)),1,1))+Val(SubStr(AllTrim(Str(nByte7)),2,1)),nByte7)
	nByte6  := IIf(nByte6>9,Val(SubStr(AllTrim(Str(nByte6)),1,1))+Val(SubStr(AllTrim(Str(nByte6)),2,1)),nByte6)
	nByte5  := IIf(nByte5>9,Val(SubStr(AllTrim(Str(nByte5)),1,1))+Val(SubStr(AllTrim(Str(nByte5)),2,1)),nByte5)
	nTotByte:= (nByte5+nByte6+nByte7+nByte8+nByte9+nByte10+nByte11)

	nAchaC1 := mod(nTotByte,10)

	if nAchaC1 == 0
		xcC1 := "0"
	else
		xcC1 := Alltrim(Str((10 - nAchaC1)))
	endif

	xcChequeV := xcComp+AllTrim(xcCheque)+"5"

	nByte11 := 2 * Val(Subs(xcChequeV,10,1))
	nByte10 := 1 * Val(Subs(xcChequeV ,9,1))
	nByte9  := 2 * Val(Subs(xcChequeV ,8,1))
	nByte8  := 1 * Val(Subs(xcChequeV ,7,1))
	nByte7  := 2 * Val(Subs(xcChequeV ,6,1))
	nByte6  := 1 * Val(Subs(xcChequeV ,5,1))
	nByte5  := 2 * Val(Subs(xcChequeV ,4,1))
	nByte4  := 1 * Val(Subs(xcChequeV ,3,1))
	nByte3  := 2 * Val(Subs(xcChequeV ,2,1))
	nByte2  := 1 * Val(Subs(xcChequeV ,1,1))

	nByte11 := IIf(nByte11>9,Val(SubStr(AllTrim(Str(nByte11)),1,1))+Val(SubStr(AllTrim(Str(nByte11)),2,1)),nByte11)
	nByte10 := IIf(nByte10>9,Val(SubStr(AllTrim(Str(nByte10)),1,1))+Val(SubStr(AllTrim(Str(nByte10)),2,1)),nByte10)
	nByte9  := IIf(nByte9>9,Val(SubStr(AllTrim(Str(nByte9)),1,1))+Val(SubStr(AllTrim(Str(nByte9)),2,1)),nByte9)
	nByte8  := IIf(nByte8>9,Val(SubStr(AllTrim(Str(nByte8)),1,1))+Val(SubStr(AllTrim(Str(nByte8)),2,1)),nByte8)
	nByte7  := IIf(nByte7>9,Val(SubStr(AllTrim(Str(nByte7)),1,1))+Val(SubStr(AllTrim(Str(nByte7)),2,1)),nByte7)
	nByte6  := IIf(nByte6>9,Val(SubStr(AllTrim(Str(nByte6)),1,1))+Val(SubStr(AllTrim(Str(nByte6)),2,1)),nByte6)
	nByte5  := IIf(nByte5>9,Val(SubStr(AllTrim(Str(nByte5)),1,1))+Val(SubStr(AllTrim(Str(nByte5)),2,1)),nByte5)
	nByte4  := IIf(nByte4>9,Val(SubStr(AllTrim(Str(nByte4)),1,1))+Val(SubStr(AllTrim(Str(nByte4)),2,1)),nByte4)
	nByte3  := IIf(nByte3>9,Val(SubStr(AllTrim(Str(nByte3)),1,1))+Val(SubStr(AllTrim(Str(nByte3)),2,1)),nByte3)
	nByte2  := IIf(nByte2>9,Val(SubStr(AllTrim(Str(nByte2)),1,1))+Val(SubStr(AllTrim(Str(nByte2)),2,1)),nByte2)
	nTotByte:= (nByte2+nByte3+nByte4+nByte5+nByte6+nByte7+nByte8+nByte9+nByte10+nByte11)

	nAchaC2 := Mod(nTotByte,10)

	if nAchaC2 == 0
		xcC2 := "0"
	else
		xcC2 := Alltrim(Str((10 - nAchaC2)))
	endif

	xcContaV := xcConta1

	nByte11 := 2 * Val(Subs(xcContaV,10,1))
	nByte10 := 1 * Val(Subs(xcContaV ,9,1))
	nByte9  := 2 * Val(Subs(xcContaV ,8,1))
	nByte8  := 1 * Val(Subs(xcContaV ,7,1))
	nByte7  := 2 * Val(Subs(xcContaV ,6,1))
	nByte6  := 1 * Val(Subs(xcContaV ,5,1))
	nByte5  := 2 * Val(Subs(xcContaV ,4,1))
	nByte4  := 1 * Val(Subs(xcContaV ,3,1))
	nByte3  := 2 * Val(Subs(xcContaV ,2,1))
	nByte2  := 1 * Val(Subs(xcContaV ,1,1))
	nByte11 := IIf(nByte11>9,Val(SubStr(AllTrim(Str(nByte11)),1,1))+Val(SubStr(AllTrim(Str(nByte11)),2,1)),nByte11)
	nByte10 := IIf(nByte10>9,Val(SubStr(AllTrim(Str(nByte10)),1,1))+Val(SubStr(AllTrim(Str(nByte10)),2,1)),nByte10)
	nByte9  := IIf(nByte9>9,Val(SubStr(AllTrim(Str(nByte9)),1,1))+Val(SubStr(AllTrim(Str(nByte9)),2,1)),nByte9)
	nByte8  := IIf(nByte8>9,Val(SubStr(AllTrim(Str(nByte8)),1,1))+Val(SubStr(AllTrim(Str(nByte8)),2,1)),nByte8)
	nByte7  := IIf(nByte7>9,Val(SubStr(AllTrim(Str(nByte7)),1,1))+Val(SubStr(AllTrim(Str(nByte7)),2,1)),nByte7)
	nByte6  := IIf(nByte6>9,Val(SubStr(AllTrim(Str(nByte6)),1,1))+Val(SubStr(AllTrim(Str(nByte6)),2,1)),nByte6)
	nByte5  := IIf(nByte5>9,Val(SubStr(AllTrim(Str(nByte5)),1,1))+Val(SubStr(AllTrim(Str(nByte5)),2,1)),nByte5)
	nByte4  := IIf(nByte4>9,Val(SubStr(AllTrim(Str(nByte4)),1,1))+Val(SubStr(AllTrim(Str(nByte4)),2,1)),nByte4)
	nByte3  := IIf(nByte3>9,Val(SubStr(AllTrim(Str(nByte3)),1,1))+Val(SubStr(AllTrim(Str(nByte3)),2,1)),nByte3)
	nByte2  := IIf(nByte2>9,Val(SubStr(AllTrim(Str(nByte2)),1,1))+Val(SubStr(AllTrim(Str(nByte2)),2,1)),nByte2)
	nTotByte:= (nByte2+nByte3+nByte4+nByte5+nByte6+nByte7+nByte8+nByte9+nByte10+nByte11)

	nAchaC3 := Mod(nTotByte,10)

	if nAchaC3 == 0
		xcC3 := "0"
	else
		xcC3 := Alltrim(Str((10 - nAchaC3)))
	endif

	zC1 := SubStr(xcCMC7, 22, 1)
	zC2 := SubStr(xcCMC7,  9, 1)
	zC3 := SubStr(xcCMC7, 33, 1)

	If xcC1 # zC1
		MsgStop("CMC7 Invalido!!! Verifique..Posicao 22 -> " + xcC1)
		xcCMC7 := Space(34)
		xoCmc7:Setfocus()
		Return .f.
	Endif

	If xcC2 # zC2
		MsgStop("CMC7 Invalido!!! Verifique..Posicao 09 -> " + xcC2)
		xcCMC7 := Space(34)
		xoCmc7:Setfocus()
		Return .f.
	Endif

	If xcC3 # zC3
		MsgStop("CMC7 Invalido!!! Verifique..Posicao 33 -> " + xcC3)
		xcCMC7 := Space(34)
		xoCmc7:Setfocus()
		Return .f.
	Endif

	For I := 1 to 34
		If I <>  1 .And.;
		I <> 10 .And.;
		I <> 21 .And.;
		I <> 34
			If !(Subs(xcCMC7,I,1) $ '0/1/2/3/4//5/6/7/8/9')
				MsgStop("CMC7 Invalido!!! Verifique..Posicao... -> " + Str(I))
				xcCMC7 := Space(35)
				xoCmc7 :Setfocus()
				Return .f.
			Endif
		Endif
	Next I

	xcDigito1:= xcC1
	xcDigito2:= xcC2
	xcDigito3:= xcC3

	xoBanco:Refresh()
	xoAgencia:Refresh()
	xoConta:Refresh()
	xoCheque:Refresh()
	xoComp:Refresh()
	xoDigito1:Refresh()
	xoDigito2:Refresh()
	xoDigito3:Refresh()

Return .t.

Static Function fa390Banco( nGet )
	Local cChave := ""
	Local cAlias := Alias( )
	Local lRet   := .t.

	If nGet == 1
		cChave := cBanco390
	Elseif nGet == 2
		cChave := cBanco390+cAgencia390
	Else
		cChave := cBanco390+cAgencia390+cConta390
	Endif
	dbSelectArea( "SA6" )
	If ! (dbSeek( cFilial + cChave ) )
		Help( " ",1,"fa390Banco" )
		lRet := .f.
	ElseIf nGet == 3 .and. SA6->A6_BLOCKED == "1"   // Conta Bloqueada
		Help(" ",1,"CCBLOCKED")
		lRet := .f.
	Endif

	//��������������������������������������������������������������Ŀ
	//� Ponto de Entrada para controle da numeracao do cheque no 	  �
	//� FINA390 e tambem sera retornado o Banco, Agencia e Conta.	  �
	//����������������������������������������������������������������
	If ExistBlock("F390NCHQ") .And. !Empty(cBanco390) .And. !Empty(cAgencia390) .And. !Empty(cConta390)
		cCheque390 := Padr(ExecBlock("F390NCHQ",.F.,.F.,{cBanco390,cAgencia390,cConta390}),TamSX3("EF_NUM")[1])
	EndIf

	dbSelectArea( cAlias )
Return lRet