#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR172    �Autor  �Microsiga           � Data �  05/10/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para trazer como default o desconto comercial,    ���
���          � para condicao de pagamento a vista. Chamado UA_CLIENTE X3_VLDUSER ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR172()

	LOCAL nUA_DESCOM := 0

	nUA_DESCCOM := 0

	DbSelectArea("SE4")
	DbSetOrder(1)
	//DbGotop()
	If DbSeek(xFilial("SE4")+"001")
		If !Empty(SE4->E4_DESCCOM) 
			nUA_DESCCOM := SE4->E4_DESCCOM		
		Else
			nUA_DESCCOM := 0
		EndIf
	EndIf                

	M->UA_DESCCOM := nUA_DESCCOM

Return .T.