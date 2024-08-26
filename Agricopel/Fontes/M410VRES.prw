#include"topconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa �M410VRES �Autor �Thiago Padilha Bottaro � Data �  13/04/2020 ���
�������������������������������������������������������������������������͹��
���Desc. �Ponto de entrada na eliminacao do residuo do pedido de venda    ���
���      � para impedir a altera��o de pedidos impressos                  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function M410VRES()

//���������������������������������������������������������������������������������Ŀ
//�Declaracao de variaveis                                                          �
//�����������������������������������������������������������������������������������
Local aArea			:= GetArea()
Local cNumPv		:= SC5->C5_NUM
Local cXimpresso    := SC5->C5_XIMPRE
Local lRet          := .T.


lRet := .T.
IF (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06") .AND. !(FWIsInCallStack("U_XAG0155")) 
	IF Alltrim(cXimpresso) == "S"
		APMSGALERT("O Pedido " +cNumPv+ " se encontra impresso, para efetivar a altera��o, entre em contato com setor de faturamento! ")
		lRet := .F.  
	EndIf
EndIf	

//���������������������������������������������������������������������������������Ŀ
//�Restaura a area das tabelas utilizadas                                           �
//�����������������������������������������������������������������������������������
RestArea(aArea)

Return(lRet)
