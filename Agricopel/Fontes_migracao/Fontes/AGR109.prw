#INCLUDE "RWMAKE.CH"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR109    �Autor  �Microsiga           � Data �  04/15/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho para atualizar % de bonificacao para produtos      ���
���          � tributados e clientes revendedores.                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
���          �                                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGR109()
	
	nPerc := 0		      	
	If SA1->A1_TIPO == "R" .And. SA1->A1_BONIFIC == "S"
		If ALLTRIM(SB1->B1_GRTRIB) == "00"
			nPerc := 5			
		EndIf
	EndIf

Return nPerc