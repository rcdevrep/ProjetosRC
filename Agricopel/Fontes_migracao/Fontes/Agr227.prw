#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR227   �Autor  � Marcelo da Cunha   � Data �  06/12/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho no Televendas no campo C5_CLIENTE para buscar      ���
���          � vendedores do cadastro de clientes                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGR227()
********************
LOCAL cCliente := M->C5_cliente, cLoja := M->C5_lojacli, cRetu := &(ReadVar()), aSeg := GetArea(), aSegSA1 := SA1->(GetArea())
              
dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+cCliente+cLoja)
	M->C5_vend1 := SA1->A1_vend
	M->C5_vend2 := SA1->A1_vend2
	M->C5_vend3 := SA1->A1_vend3
Endif

//Retorno area original do arquivo
//////////////////////////////////
RestArea(aSegSA1)
RestArea(aSeg)

Return cRetu