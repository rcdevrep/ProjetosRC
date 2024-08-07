#Include "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR157    �Autor  �Deco                � Data �  09/02/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para Debito lancamento padrao 530-01             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR157()

	Private cCtaDeb                                                                                  	

	IF SE5->E5_PREFIXO == "MED"
		dbSelectArea("CN9")
		CN9->(dbSetOrder(1))
		If dbSeek(xFilial("CN9")+SE2->E2_MDCONTR)
			cCtaDeb := Alltrim(CN9->CN9_XCTCUR)
		EndIf
	ElseIf SE5->E5_MOTBX == "CMP"
		cCtaDeb := SA6->A6_CONTA                   	
	Else
		dbSelectArea("SA2")  // Posiciona Fornecedor  Deco 09/02/2005
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
		cCtaDeb := SA2->A2_CONTA
	Endif

Return(cCtaDeb)