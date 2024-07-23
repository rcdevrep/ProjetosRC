#INCLUDE "RWMAKE.CH"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR110    �Autor  �Microsiga           � Data �  04/16/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para validar se o cliente e do Tipo Revendedor,  ���
���          �  para clientes que recebem bonificacao.                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR110()

	If INCLUI	
		If M->A1_BONIFIC == "S" .And. M->A1_TIPO <> "R"
			MsgStop("Cliente nao � Tipo Revendedor, nao podera receber Bonificacao!!!")
			Return .F.
		EndIf
	ElseIf ALTERA
		If M->A1_BONIFIC == "S" .And. SA1->A1_TIPO <> "R"
			MsgStop("Cliente nao � Tipo Revendedor, nao podera receber Bonificacao!!!")
			Return .F.
		EndIf	
	EndIf

Return .T.