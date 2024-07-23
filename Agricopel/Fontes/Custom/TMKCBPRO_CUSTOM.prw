#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKCBPRO  �Autor  �Microsiga           � Data �  05/08/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para receber dados adicionais do cliente. ���
���          � Sera necessario criar os seguintes campos:                 ���
���          � SA1->A1_MSG1                                               ���
���          � SA1->A1_MSG2                                               ���
���          � SA1->A1_MSG3                                               ���
���          � SA1->A1_MSG4                                               ���
���          � SA1->A1_MSG5                                               ���
���          � SA1->A1_MSG6                                               ���
���          � SA1->A1_BANCO                                              ���
���          � SA1->A1_PRZPGTO                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TMKCBPRO()

	Local aBtnSup := {}
	
//	Aadd(aBtnSup,{"D5",{||HistCli()},"Historico Clientes"}) 
	Aadd(aBtnSup,{"OBJETIVO",{||HistCli()},"Observa��es Adicionais"})   // Parametros na ordem: Tipo do botao, Procedure, Titulo do Botao

Return aBtnSup

Static Function HistCli()

	If Empty(M->UA_CLIENTE) .Or. Empty(M->UA_LOJA)
		Return
	EndIf
	

	//��������������������������������������������������������������Ŀ
	//� Titulo da Janela                                             �
	//����������������������������������������������������������������
	cTitulo:="Dados Adicionais do Cliente"

	//��������������������������������������������������������������Ŀ
	//� Chamada do comando browse                                    �
	//����������������������������������������������������������������

	@ 000,000 TO 300,800 DIALOG oDlgQtd TITLE cTitulo
	cCliente	:= SA1->A1_COD + " " + SA1->A1_LOJA + " - " + SA1->A1_NOME
	cEmail	:= SA1->A1_EMAIL
	cBanco	:= SA1->A1_BANCO
	cPrzPgto := SA1->A1_PRZPGTO
	Msg1		:= SA1->A1_MSG1
	Msg2		:= SA1->A1_MSG2
	Msg3		:= SA1->A1_MSG3
	Msg4		:= SA1->A1_MSG4
	Msg5		:= SA1->A1_MSG5				
	Msg6		:= SA1->A1_MSG6					
	
	@ 004,005 Say "Cliente:" 
	@ 004,040 Get cCliente  SIZE 240,10 Pict "@!" When .F.
	
	@ 015,005 Say "E-Mail :"      	
	@ 015,040 Get cEmail   SIZE 120,10
	
	@ 026,005 Say "Banco:"
	@ 026,040 Get cBanco SIZE 60,10

	@ 026,100 Say "Prazo Pagto:"
	@ 026,145 Get cPrzPgto SIZE 40,10

	@ 037,005 Say "Observacoes:"
   @ 048,005 Get Msg1 SIZE 240,10
   @ 059,005 Get Msg2 SIZE 240,10
   @ 070,005 Get Msg3 SIZE 240,10
   @ 081,005 Get Msg4 SIZE 240,10
   @ 092,005 Get Msg5 SIZE 240,10            
   @ 103,005 Get Msg6 SIZE 240,10               
    
	@ 130,300 BUTTON "_Gravar" SIZE 38,12 ACTION oGrava()
	@ 130,340 BUTTON "_Sair"   SIZE 38,12 ACTION Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED       
	
Return
                                                
Static Function oGrava()

	DbSelectArea("SA1")
	RecLock("SA1",.F.)       
		SA1->A1_EMAIL		:= cEmail
		SA1->A1_BANCO		:= cBanco
		SA1->A1_PRZPGTO	:= cPrzPgto
		SA1->A1_MSG1		:= Msg1
		SA1->A1_MSG2		:= Msg2
		SA1->A1_MSG3		:= Msg3
		SA1->A1_MSG4		:= Msg4
		SA1->A1_MSG5		:= Msg5
		SA1->A1_MSG6		:= Msg6
	MsUnLock("SA1")

	Close(oDlgQtd)

Return
