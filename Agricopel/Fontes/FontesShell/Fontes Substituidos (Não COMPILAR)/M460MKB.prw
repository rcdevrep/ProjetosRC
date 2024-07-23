#include "topconn.ch"
#include "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460MKB   �Autor  �Jaime Wikanski      � Data �  29/11/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para avaliar se deve ou nao permitir a     ���
���          �selecao para geracao da NFS                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Fusus                                                      ���
�������������������������������������������������������������������������͹��
���Altera��es�10/05/2015 - Max Ivan (Nexus) - Ajustado para permitir que  ���
���          �seja mostrado em tela apenas os pedidos liberados. LUBTROL  ���
���          �19/10/2015 - Max Ivan (Nexus) - Ajustado para permitir fil- ���
���          �trar os registros a serem mostrados, pelo almoxarifado e    ���
���          �campo customizado C5_XIMPRE. AGRICOPEL                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M460MKB()
//��������������������������������������������������������������������������������Ŀ
//�Declaracao de variaveis                                                         �
//����������������������������������������������������������������������������������
Local cCondicao			:= "DTOS(Posicione('SC6',1,xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM,'C6_ENTREG')) <= DTOS(dDataBase) .AND. U_M460VLMK()"
//Local cCondicao			:= "DTOS(Posicione('SC6',1,xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM,'C6_ENTREG')) <= DTOS(dDataBase)"
Local cQuery			:= ""
Local cPVBloq			:= ""
Local nX				:= 0
Local _oPedImp          := Nil
Local _aPedImp          := {"TODOS","SIM","N�O"}
Local oDlg2             := Nil
Public lM460Exibe    	:= .F.
Public lM460MKBTodos    := .F.       
//Public _lSoLiber        := .F. //CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que est�o liberados para faturamento
Public _cAlmox          := Space(TamSX3("C9_LOCAL")[1]) //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Filtrar pedidos pro almoxarifado e campo C5_XIMPRE
Public _cPedImp         := "T"

//��������������������������������������������������������������������������������Ŀ
//�Atualiza o campo C9_ENTREG                                                      �
//����������������������������������������������������������������������������������
cQuery := " UPDATE "+RetSqlName("SC9")+" SET C9_ENTREG = C6_ENTREG "
cQuery += " FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)"
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
cQuery += " AND C9_ENTREG <> C6_ENTREG"
cQuery += " AND "+RetSqlName("SC9")+".D_E_L_E_T_ <> '*'"
cQuery += " AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQuery += " AND C6_NUM = C9_PEDIDO"
cQuery += " AND C6_ITEM = C9_ITEM"
cQuery += " AND SC6.D_E_L_E_T_ <> '*'"
MsgRun('Atualizando Data de Entrega, aguarde...',,{|| TcSqlExec(cQuery)})

//���������������������������������������������������������������������������������������Ŀ
//�Atualiza o campo C9_ZZTOTIT - Feito por Max Ivan (Nexus) em 20/06/2015 para Lubtrol    �
//�����������������������������������������������������������������������������������������
/*If SC9->(FieldPos("C9_ZZTOTIT"))> 0
   cQuery := " UPDATE "+RetSqlName("SC9")+" SET C9_ZZTOTIT = C9_QTDLIB*C9_PRCVEN "
   cQuery += " FROM "+RetSqlName("SC9")+" SC9 (NOLOCK)"
   cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
   cQuery += " AND C9_QTDLIB > 0 AND C9_NFISCAL = '' "
   cQuery += " AND C9_ZZTOTIT <> C9_QTDLIB*C9_PRCVEN "
   cQuery += " AND SC9.D_E_L_E_T_ <> '*'"
   MsgRun('Atualizando Total do Item, aguarde...',,{|| TcSqlExec(cQuery)})
EndIf*/

//��������������������������������������������������������������������������������Ŀ
//�Valida os pedidos bloqueados                                                    �
//����������������������������������������������������������������������������������
/*
cQuery := " SELECT C9_PEDIDO"
cQuery += " FROM "+RetSqlName("SC9")+" SC9 (NOLOCK)"
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
cQuery += " AND C9_BLEST = '  '"
cQuery += " AND C9_BLCRED = '  '"
cQuery += " AND >C9_BLWMS IN('05','06','07','  ')"
If (MV_PAR03 == 1)
	cQuery += " AND SC9.C9_PEDIDO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	cQuery += " AND SC9.C9_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'"
	cQuery += " AND SC9.C9_LOJA BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'"
	cQuery += " AND SC9.C9_DATALIB BETWEEN '"+Dtos(MV_PAR11)+"'AND '"+Dtos(MV_PAR12)+"'"			
EndIf
cQuery += " AND D_E_L_E_T_ <> '*'"
cQuery += " GROUP BY C9_PEDIDO"
*/
If Upper(Alltrim(FunName())) == "MATA460B"
	cCondicao		:= ".T. .AND. U_M460VLMK()"
	//cCondicao		:= ".T."
	lM460MKBTodos	:= .T.
Else
	If .T. //cNivel == 9
		lM460Exibe   	:= .T.
		If Aviso("Aviso","Deseja permitir a sele��o dos pedidos com data de entrega futura?",{"Sim","N�o"},,"Aten��o:",,"CHECKED") == 1
			//cCondicao		:= ".T."
			cCondicao		:= ".T. .AND. U_M460VLMK()"
			lM460MKBTodos	:= .T.
		Endif

		////CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
		If SC5->(FieldPos("C5_XIMPRE"))> 0
		   DEFINE MSDIALOG oDlg2 TITLE "Filtrar" FROM 0,0 TO 200,400 OF oDlg2 PIXEL
           @ 005,001 Say "Almoxarifado: " SIZE 65, 8 PIXEL OF oDlg2
           @ 005,055 MSGET _cAlmox Size 10,10 PIXEL OF oDlg2
           @ 020,001 Say "Pedidos Impressos? " SIZE 65, 8 PIXEL OF oDlg2
           @ 020,055 COMBOBOX _oPedImp VAR _cPedImp ITEMS _aPedImp SIZE 45,10 PIXEL OF oDlg2
           @ 040,070 BUTTON "&OK"     SIZE 26,12 PIXEL ACTION oDlg2:End()
           ACTIVATE MSDIALOG oDlg2 CENTER
		EndIf
		//FIM - //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
	Else
		If Aviso("Aviso","Deseja exibir os pedidos com data de entrega futura?",{"Sim","N�o"},,"Aten��o:",,"CHECKED") == 1
			lM460MKBTodos	:= .F.
			lM460Exibe	   	:= .T.
		Endif
		//CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que est�o liberados para faturamento
		/*If Aviso("Aviso","Deseja exibir apenas pedidos liberados para faturamento?",{"Sim","N�o"},,"Aten��o:",,"CHECKED") == 1
		   _lSoLiber := .T.
		   cCondicao := cCondicao + " .AND. Empty(C9_BLCRED) .AND. Empty(C9_BLOQUEI) .AND. Empty(C9_BLEST) "
		EndIf*/
		//FIM - CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que est�o liberados para faturamento

		////CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
		If SC5->(FieldPos("C5_XIMPRE"))> 0
		   DEFINE MSDIALOG oDlg2 TITLE "Filtrar" FROM 0,0 TO 200,400 OF oDlg2 PIXEL
           @ 005,001 Say "Almoxarifado: " SIZE 65, 8 PIXEL OF oDlg2
           @ 005,055 MSGET _cAlmox Size 10,10 PIXEL OF oDlg2
           @ 020,001 Say "Pedidos Impressos? " SIZE 65, 8 PIXEL OF oDlg2
           @ 020,055 COMBOBOX _oPedImp VAR _cPedImp ITEMS _aPedImp SIZE 45,10 PIXEL OF oDlg2
           @ 040,070 BUTTON "&OK"     SIZE 26,12 PIXEL ACTION oDlg2:End()
           ACTIVATE MSDIALOG oDlg2 CENTER
		EndIf
		//FIM - //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
	Endif
Endif

Return(cCondicao)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460VLMK  �Autor  �Jaime Wikanski      � Data �  29/11/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida o markbrowse                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Fusus                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M460VLMK()

//��������������������������������������������������������������������������������Ŀ
//�Declaracao de variaveis                                                         �
//����������������������������������������������������������������������������������
Local lReturn	:= .T.
/*
Local aArea		:= GetArea()        
Local aAreaSC9	:= SC9->(GetArea())
Local cPedido	:= SC9->C9_PEDIDO
Local cItem		:= SC9->C9_ITEM
Local cPvRelac	:= ""

If U_VerRot("A460Avalia")                                   
	//��������������������������������������������������������������������������������Ŀ
	//�Valida se o item foi marcado                                                    �
	//����������������������������������������������������������������������������������
	If SC9->C9_OK == ThisMark()
		//��������������������������������������������������������������������������������Ŀ
		//�Posiciona no cabecalho do pedido de vendas                                      �
		//����������������������������������������������������������������������������������
		DbSelectArea("SC5")
		DbSetOrder(1)
		MsSeek(xFilial("SC5")+cPedido,.F.)
		If SC5->C5_TPPVREM == "V" .or. SC5->C5_TPPVREM == "R"
			//��������������������������������������������������������������������������������Ŀ
			//�Valida se o item amarrado esta no browse                                        �
			//����������������������������������������������������������������������������������
			cPvRelac := SC5->C5_PVREM
			If !Empty(cPvRelac)			
				DbSelectArea("SC9")
				DbSetOrder(1)
				If !DbSeek(xFilial("SC9")+cPvRelac+cItem,.F.)
					lReturn := .F.
				ElseIf SC9->C9_OK <> ThisMark()
					lReturn := .F.
				Endif            
			Else
				lReturn := .F.
			Endif
			
			//��������������������������������������������������������������������������������Ŀ
			//�Reposiciona o SC9                                                               �
			//����������������������������������������������������������������������������������
			DbSelectArea("SC9")
			RestArea(aAreaSC9)
		Endif
	Endif
Endif
If !lReturn
	Aviso("Aviso","Sele��o do �tem do pedido inv�lida. Selecione o pedido "+cPvRelac+" relacionado a esse pedido de venda.",{"Ok"},,"Aten��o:",,"CHECKED")
Endif                   

SysRefresh()
RestArea(aArea)
*/
Return(lReturn)