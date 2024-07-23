#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MAT910OK  �Autor  �Leandro F Silveira  � Data �  05/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Objetivo de bloquear a grava��o da Nota Fiscal caso        ���
���          � a mesma tenha sido digitado com caracteres faltantes,      ���
���          � ou seja, precisa preencher todo o campo com "0" � esquerda ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MAT910OK()

	_cNumDoc := AllTrim(ParamIxb[3])

	If !(Len(_cNumDoc) == TamSX3("F1_DOC")[1])

		Aviso("Aten��o: n�mero do T�tulo inv�lido!", "N�mero do T�tulo possui [" + AllTrim(Str(Len(_cNumDoc))) + "] caracteres ao inv�s de [" + AllTrim(Str(TamSX3("F1_DOC")[1])) + "]!", {"Ok"})
		Return .F.

	EndIf

Return .T.