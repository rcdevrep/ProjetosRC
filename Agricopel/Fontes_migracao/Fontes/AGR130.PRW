#INCLUDE "RWMAKE.CH"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR130    �Autor  �Deco                � Data �  09/09/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para CCD do lancamento padrao 530-01             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR130()

PRIVATE cCCD

cCCD := ''

*
* Postos Mime
*
If SM0->M0_CODIGO == "20"
	If Alltrim(SA2->A2_CONTA) == '4509' 
	   cCCD := '305'
	EndIf
	If Alltrim(SA2->A2_CONTA) == '4511' 
	   cCCD := '305'
	EndIf
	If Alltrim(SA2->A2_CONTA) == '4708' 
	   cCCD := '505'
	EndIf
EndIf
	

Return(cCCD)