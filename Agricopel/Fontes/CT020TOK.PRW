/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CT020TOK  �Autor  Leandro F Silveira   � Data �  11/20/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Executar regra de n�o permitir cadastrar conta anal�tica   ���
���          � sem regra de NV1 e n�o permitir cadastrar uma conta sint�  ���
���          � tica com uma regra de NV1. Regra feita por Elaine da Contab���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function CT020TOK()

	If SM0->M0_CODIGO == "01" .Or. SM0->M0_CODIGO == "20"

		If AllTrim(M->CT1_CLASSE) == "1" .And. !Empty(M->CT1_RGNV1)
			Alert("N�o � permitido cadastrar uma conta sint�tica com uma regra de n�vel 1!")
			Return(.F.)
		EndIf
	
		If M->CT1_CLASSE == "2" .And. Empty(M->CT1_RGNV1)
			Alert("N�o � permitido cadastrar uma conta anal�tica sem uma regra de n�vel 1!")
			Return(.F.)
		EndIf

	EndIf

Return(.T.)