#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/* SIGAVILLE
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Cliente      � Agricopel Com. Derivados de Petr�leo Ltda               ���
�������������������������������������������������������������������������Ĵ��
���Programa     � AGR190           � Responsavel � Deco                   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o    � Gatilho que Valida cliente associado ao vendedor        ���
�������������������������������������������������������������������������Ĵ��
��� Data        � 13/12/05         � Implantacao �                        ���
�������������������������������������������������������������������������Ĵ��
��� Programador � Deco                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR190()
                          	              
cCodCli := M->AD5_CODCLI
cLoja   := M->AD5_LOJA

DbSelectArea("SA1")
DbSetOrder(1)
If dbSeek(xFilial("SA1")+cCodcli+cLoja)
	IF SA1->A1_VEND  <> M->AD5_VEND .AND.;
	   SA1->A1_VEND2 <> M->AD5_VEND .AND.;
	   SA1->A1_VEND3 <> M->AD5_VEND 
	   MSGSTOP("Cliente nao Associado a Este Vendedor !")
	   Return .f.
	ENDIF   
Endif
	
Return .T.
