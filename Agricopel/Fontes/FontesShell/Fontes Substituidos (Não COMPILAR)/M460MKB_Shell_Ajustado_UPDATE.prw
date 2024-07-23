#include "topconn.ch"

/*/{Protheus.doc} M460MKB
Ponto de entrada para avaliar se deve ou nao permitir a
selecao para geracao da NFS
@author Jaime Wikanski
@since 29/11/06
@version P11
@uso Fusus
@type function
/*/

User Function M460MKB()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCondicao			:= "DTOS(Posicione('SC6',1,xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM,'C6_ENTREG')) <= DTOS(dDataBase) .AND. U_M460VLMK()"
//Local cCondicao			:= "DTOS(Posicione('SC6',1,xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM,'C6_ENTREG')) <= DTOS(dDataBase)"
Local cQuery			:= ""
Local cPVBloq			:= ""
Local nX				:= 0
Public lM460Exibe    	:= .F.
Public lM460MKBTodos    := .F.       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o campo C9_ENTREG                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " UPDATE "+RetSqlName("SC9")+" SET C9_ENTREG = C6_ENTREG"
cQuery += " FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)"
cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
cQuery += " AND C9_ENTREG <> C6_ENTREG"
cQuery += " AND "+RetSqlName("SC9")+".D_E_L_E_T_ <> '*'"
cQuery += " AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQuery += " AND C6_NUM = C9_PEDIDO"
cQuery += " AND C6_ITEM = C9_ITEM"
cQuery += " AND SC6.D_E_L_E_T_ <> '*'"
MsgRun('Atualizando Data de Entrega, aguarde...',,{|| TcSqlExec(cQuery)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida os pedidos bloqueados                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	If cNivel == 9 .or. SuperGetMv("FS_FATFUTU", , "N") == "S"
		lM460Exibe   	:= .T.
		If Aviso("Aviso","Deseja permitir a seleção dos pedidos com data de entrega futura?",{"Sim","Náo"},,"Atenção:",,"CHECKED") == 1
			//cCondicao		:= ".T."
			cCondicao		:= ".T. .AND. U_M460VLMK()"
			lM460MKBTodos	:= .T.
		Endif
	Else
		If Aviso("Aviso","Deseja exibir os pedidos com data de entrega futura?",{"Sim","Náo"},,"Atenção:",,"CHECKED") == 1
			lM460MKBTodos		:= .F.
			lM460Exibe	   	:= .T.
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MAX IVAN (Nexus) - 04/12/2017                                    ³
//³PE criado dentro deste PE, para atender necessidade da Agricopel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("U_NX460MKB")
   cCondicao := cCondicao + U_NX460MKB()
Endif
//---------------------------------------

Return(cCondicao)

/*/{Protheus.doc} M460VLMK
Valida o markbrowse
@author Jaime Wikanski
@since 29/11/06
@version P11
@uso Fusus
@type function
/*/

User Function M460VLMK()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lReturn	:= .T.
/*
Local aArea		:= GetArea()        
Local aAreaSC9	:= SC9->(GetArea())
Local cPedido	:= SC9->C9_PEDIDO
Local cItem		:= SC9->C9_ITEM
Local cPvRelac	:= ""

If U_VerRot("A460Avalia")                                   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o item foi marcado                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SC9->C9_OK == ThisMark()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona no cabecalho do pedido de vendas                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SC5")
		DbSetOrder(1)
		MsSeek(xFilial("SC5")+cPedido,.F.)
		If SC5->C5_TPPVREM == "V" .or. SC5->C5_TPPVREM == "R"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o item amarrado esta no browse                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reposiciona o SC9                                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC9")
			RestArea(aAreaSC9)
		Endif
	Endif
Endif
If !lReturn
	Aviso("Aviso","Seleção do ítem do pedido inválida. Selecione o pedido "+cPvRelac+" relacionado a esse pedido de venda.",{"Ok"},,"Atenção:",,"CHECKED")
Endif                   

SysRefresh()
RestArea(aArea)
*/
Return(lReturn)