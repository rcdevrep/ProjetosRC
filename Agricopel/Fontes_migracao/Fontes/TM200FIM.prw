#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TM200FIM     �Autor  �Alan Leandro    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada chamado no final do processo de calculo   ���
���          � de conhecimento de frete.                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function TM200FIM()
**********************

// Rdmake que prepara as informacoes para a geracao do documento de entrada na empresa que deu a entrada da NF na empresa transportadora
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ExecBlock("AGR886",.F.,.F.,ParamIxb)                                                           



Return