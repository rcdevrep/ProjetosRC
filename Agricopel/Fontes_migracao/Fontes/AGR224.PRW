#INCLUDE "RWMAKE.CH"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR224    �Autor  �Deco                � Data �  06/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para historico lacto padrao 568-01              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR224()

PRIVATE cHistor


//Qdo Lan�amento cheque Salario (Tesouraria/Cecilia)

If alltrim(SE5->E5_NATUREZ) == '219124'
   cHistor := "CANC. CHEQUE SALARIO NR. "+SEF->EF_NUM
Endif


//Qdo Lan�amento cheque pagtos diversos (Tesouraria/Cecilia)

If alltrim(SE5->E5_NATUREZ) <> '219124' .And. alltrim(SE5->E5_HISTOR) == 'TALAO'
   cHistor := "CANC.CHEQUE NR. "+SEF->EF_NUM
EndIf


//Qdo Lan�amento cheque avulsos/Troco (Tesouraria/Inauria)

If alltrim(SE5->E5_NATUREZ) <> '219124' .And. alltrim(SE5->E5_HISTOR) <> 'TALAO'
   cHistor := "CANC.CH.AVULSO/TROCO NR. "+SEF->EF_NUM
EndIf

Return(cHistor)