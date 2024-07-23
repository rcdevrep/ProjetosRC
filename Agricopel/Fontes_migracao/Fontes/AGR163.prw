#INCLUDE "RWMAKE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR163   � Autor � Valdecir E. Santos � Data �  28/02/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para manutencao na tabela de descontos            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function AGR163()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
LOCAL cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
LOCAL cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

dbSelectArea("SZ7")
dbSetOrder(1)

AxCadastro("SZ7","Manutencao do Vlr Total Pedido",cVldAlt,cVldExc)

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
User Function R163GetSeq()
***********************
//LOCAL cRepre := &(ReadVar()), 
Local aSeg := GetArea(), lAchei := .F., cSeq := "01"
cZ7_TPCLIEN := M->Z7_TPCLIEN
              
//Busco proxima sequencia
/////////////////////////
dbSelectArea("SZ7")
dbSetOrder(1)
dbSeek(xFilial("SZ7")+cZ7_TPCLIEN,.T.)
While!Eof().and.(xFilial("SZ7") == SZ7->Z7_filial) .And. (SZ7->Z7_TPCLIEN == cZ7_TPCLIEN)
	cSeq   := SZ7->Z7_seq
	lAchei := .T.
	dbSkip()
Enddo
If (lAchei)
	M->Z7_SEQ := Strzero(Val(cSeq)+1,2)
Else
	M->Z7_SEQ := "01"
Endif

//Retorno status original das tabelas
/////////////////////////////////////
RestArea(aSeg)

Return cZ7_TPCLIEN

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
User Function R163Valid()
***********************
LOCAL nDesc := &(ReadVar()), aSeg := GetArea(), lRetu := .T.
LOCAL cZ7_TPCLIEN := M->Z7_TPCLIEN              
//Verifico se desconto esta Ok
//////////////////////////////
dbSelectArea("SZ7")
dbSetOrder(1)
dbSeek(xFilial("SZ7")+cZ7_TPCLIEN,.T.)
While!Eof().and.(xFilial("SZ7") == SZ7->Z7_filial) .And. (SZ7->Z7_TPCLIEN == cZ7_TPCLIEN)
   If (nDesc >= SZ7->Z7_VlrMin).and.(nDesc <= SZ7->Z7_VlrMax)
   	lRetu := .F.
   	MsgInfo(">>> Este intervalo ja esta cadastrado!!! Tente novamente.")
   	Exit
   Endif
	dbSelectArea("SZ7")
	dbSkip()
Enddo

//Retorno status original das tabelas
/////////////////////////////////////
RestArea(aSeg)

Return lRetu