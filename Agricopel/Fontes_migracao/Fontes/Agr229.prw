#include "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR229   � Autor � Marcelo da Cunha   � Data �  06/12/02   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para manutencao na tabela de descontos            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function AGR229()
********************

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
LOCAL cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
LOCAL cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

dbSelectArea("SZ8")
dbSetOrder(1)

AxCadastro("SZ8","Manutencao de Descontos",cVldAlt,cVldExc)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR229   � Autor � Marcelo da Cunha   � Data �  06/12/02   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para manutencao na tabela de comissoes            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function R229GetSeq()
***********************
//LOCAL cRepre := &(ReadVar()), 
Local aSeg := GetArea(), lAchei := .F., cSeq := "01"
cZ8_REPRE	:= M->Z8_REPRE
cZ8_TPCLIEN := M->Z8_TPCLIEN
              
//Busco proxima sequencia
/////////////////////////
dbSelectArea("SZ8")
dbSetOrder(2)
dbSeek(xFilial("SZ8")+cZ8_REPRE+cZ8_TPCLIEN,.T.)
While!Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cZ8_REPRE) .And. (SZ8->Z8_TPCLIEN == cZ8_TPCLIEN)
	cSeq   := SZ8->Z8_seq
	lAchei := .T.
	dbSkip()
Enddo
If (lAchei)
	M->Z8_seq := Strzero(Val(cSeq)+1,2)
Else
	M->Z8_seq := "01"
Endif

//Retorno status original das tabelas
/////////////////////////////////////
RestArea(aSeg)

Return cZ8_TPCLIEN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR229   � Autor � Marcelo da Cunha   � Data �  06/12/02   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para manutencao na tabela de comissoes            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function R229Valid()
***********************
LOCAL cRepre := M->Z8_repre, nDesc := &(ReadVar()), aSeg := GetArea(), lRetu := .T.
LOCAL cZ8_TPCLIEN := M->Z8_TPCLIEN              
//Verifico se desconto esta Ok
//////////////////////////////
dbSelectArea("SZ8")
dbSetOrder(2)
dbSeek(xFilial("SZ8")+cRepre+cZ8_TPCLIEN,.T.)
While!Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cRepre) .And. (SZ8->Z8_TPCLIEN == cZ8_TPCLIEN)
   If (nDesc >= SZ8->Z8_descmin).and.(nDesc <= SZ8->Z8_descmax)
   	lRetu := .F.
   	MsgInfo(">>> Este intervalo ja esta cadastrado!!! Tente novamente.")
   	Exit
   Endif
	dbSelectArea("SZ8")
	dbSkip()
Enddo

//Retorno status original das tabelas
/////////////////////////////////////
RestArea(aSeg)

Return lRetu