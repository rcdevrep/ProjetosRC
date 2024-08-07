#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR212   �Autor  � Marcelo da Cunha   � Data �  06/12/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho no Televendas nos campos UB_PRODUTO, UB_DESC e     ���
���          �  UA_TABELA                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGR212()
********************
LOCAL aSeg := GetArea(), aSegSB1 := SB1->(GetArea()), aSegSZ5 := SZ5->(GetArea())
              
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+M->UB_PRODUTO)

dbSelectArea("SZ5")
dbSetOrder(1)
dbSeek(xFilial("SZ5")+SB1->B1_GRUPO)

_cTaxas := SZ5->Z5_TAXAS                                                                                   

//Retorno area original do arquivo
//////////////////////////////////
RestArea(aSegSB1)
RestArea(aSegSZ5)
RestArea(aSeg)             

SysRefresh()

Return _cTaxas