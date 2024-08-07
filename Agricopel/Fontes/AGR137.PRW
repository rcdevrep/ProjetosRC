#INCLUDE "RWMAKE.CH"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR137    �Autor  �Deco                � Data �  29/09/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para historico lacto padrao 527-01 527-05       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR137()

PRIVATE cHistor:= "EST VAL REC.NF. "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)


*
* Qdo baixa normal 
*
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Empty(SE1->E1_TIPOLIQ)
   cHistor := "EST VAL REC.NF. "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)
EndIf

*
* Qdo baixa por liquidacao correspondente a baixa com cheques 
*
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Alltrim(SE1->E1_TIPOLIQ) = 'CH'
   cHistor := "EST BAIXA NF. "+SE1->E1_NUM+" LIQ. "+SE1->E1_NUMLIQ+" "+ALLTRIM(SA1->A1_NREDUZ)
EndIf

*
* Qdo baixa cheque proveniente da liquidacao de um titulo com cheque
*
If alltrim(SE1->E1_TIPO) == 'CH' 
   cHistor := "EST VAL REC.CHQ. "+SE1->E1_NUM+" LIQ. "+SE1->E1_NUMLIQ+" "+ALLTRIM(SA1->A1_NREDUZ)
EndIf

If alltrim(SE1->E1_TIPO) == 'RA' 
   cHistor := "EST VAL DEV. RA "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)
EndIf

If alltrim(SE1->E1_TIPO) == 'NCC' 
   cHistor := "EST VAL DEV. NCC "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)
EndIf

Return(cHistor)