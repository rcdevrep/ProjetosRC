#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGX488    �Autor  �Microsiga           � Data �  10/13/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � BUSCA CONTA CAIXA CASO PAGAMENTO A VISTA                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGX488()

	Private cCtaCre := SA6->A6_CONTA

	If FunName() == "MATA103"
		If CCONDICAO == "001" .OR. CCONDICAO == "800"
			cCtaCre := "111010001"
		EndIf
	EndIf   

	If FunName() == "CNTA260"
		cCtaCre := 	CN9->CN9_XCTCUR
	EndIf 

Return(cCtaCre)