#INCLUDE "AGR147.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR147    �Autor  �Microsiga           � Data �  21/12/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para Extorno Reconc Cheque Troco                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR147()
	LOCAL nSavRec := RecNo()
	
	PRIVATE aTELA[0][0],aGETS[0]
	PRIVATE aRotina := { {OemToAnsi(STR0001), "AxPesqui", 0 , 1},;     // "Pesquisar" 
								{OemToAnsi(STR0005), "U_AGR147Can", 0 , 3} }  // "Extornar"  
	
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
	mBrowse( 6, 1,22,75,"SE2",,"E2_IMPCHEQ" )
	
	//��������������������������������������������������������������Ŀ
	//� Recupera a Integridade dos dados									  �
	//����������������������������������������������������������������
	dbSelectArea("SE2")
	dbSetOrder(1)
	dbGoTo( nSavRec )
	
	Set Key VK_F12 To
Return

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados									  �
//����������������������������������������������������������������
MsUnlockAll()
dbSelectArea("SE2")
dbSetOrder(1)
dbGoTo( nSavRec )

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fa390Can	� Autor � Alessandro Freire	  � Data � 18/04/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Extorna Reconc cheque troco 										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �fa390can()																  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �FINA390																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function AGR147CAN()

LOCAL oDlg
LOCAL cAlias	 := Alias()
LOCAL nOrder	 := IndexOrd()
LOCAL nRec		 := Recno()
LOCAL lRetorna  := .F.
LOCAL lF390Canc := ExistBlock("F390CANC")
Local lCancelou := .F.

LOCAL nValor390                        // Incluido Deco 14/07/04 para cancelar contabilizacao 
LOCAL lPadrao,  cPadrao := "568"       // Incluido Deco 14/07/04 para cancelar contabilizacao 
LOCAL cArquivo, cComprobX              // Incluido Deco 14/07/04 para cancelar contabilizacao 
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
	//� Procura no SEF o registro correspondente do SE2 posiciona no momento.�
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
	nOpca := 0
	DEFINE MSDIALOG oDlg FROM 10, 5 TO 22, 46 TITLE OemToAnsi(STR0038)  //"Extorna Reconciliacao Cheque"
	@ 1.0,2	Say OemToAnsi(STR0040)  //"Banco : "
	@ 1.0,7.5 MSGET cBanco390 F3 "SA6" Valid Fa390Banco(1)

	@ 2.0,2	Say OemToAnsi(STR0041)  //"Ag�ncia : "
	@ 2.0,7.5 MSGET cAgencia390	Valid Fa390Banco(2)

	@ 3.0,2	Say OemToAnsi(STR0042)  //"Conta : "
	@ 3.0,7.5 MSGET cConta390	Valid Fa390Banco(3)

	@ 4.0,2	Say OemToAnsi(STR0043)  //"N�m Cheque:"
	@ 4.0,7.5 MSGET cCheque390 	Valid Fa390Cheq(2)

	@.3,1 TO 5,20 OF oDlg

	DEFINE SBUTTON FROM 072,097 TYPE 1 ACTION (nOpca := 1,If(!Empty(cBanco390),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 072,124.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED
        

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
 
		cQuery := "SELECT *, R_E_C_N_O_ AS NRECNO  "
		cQuery += "FROM "+RetSqlName("SE5")+" (NOLOCK) "
		cQuery += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
		cQuery += "AND D_E_L_E_T_ = '' "
		cQuery += "AND E5_DATA = '"+Dtos(dDataBase)+"' "
		cQuery += "AND E5_BANCO = '"+cBanco390+"' "
		cQuery += "AND E5_AGENCIA = '"+cAgencia390+"' "
		cQuery += "AND E5_CONTA = '"+cConta390+"' "
		cQuery += "AND E5_NUMCHEQ = '"+cCheque390+"' "		
		cQuery += "AND E5_RECONC = 'x' "
		
		If (Select("MSE5") <> 0)
			dbSelectArea("MSE5")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "MSE5"
	
		DbSelectArea("MSE5")
		DbGotop()
		While !Eof()		
			
			DbSelectArea("SE5")
			DbGoto(MSE5->NRECNO)
			RecLock("SE5",.F.)
				SE5->E5_RECONC := " "
			MsUnLock("SE5")

         MsgStop ("Cheque Extornado Reconciliacao: "+cCheque390)
			
			DbSelectArea("MSE5")
			MSE5->(DbSkip())
		EndDo		

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


