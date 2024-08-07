#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OM010DA1 �Autor  �Emerson - SLA   � Data �  18/08/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava campos especificos na Tabela DA1                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user Function OM010DA1()

	Dbselectarea("DA1")
	IF DA1->(FieldPos("DA1_ZCSTCO")) > 0
		Dbselectarea("SB1")
		Dbsetorder(1)
		Dbseek(xFilial("SB1")+DA1->DA1_CODPRO)

		nVlrCpr := 0
		nPerVds := 0
		nPerMgr := 0
		Pergunte( "MTC010", .F. )
		nVlrCpr := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGRS","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
		nPerVds := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGRS","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
		nPerMgr := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGRS","PERC_REF_MARGEM",0)        //PORCENTUAL MARGEM CONTRIBUICAO (j)

		Dbselectarea("DA1")
		Reclock("DA1",.F.)
		DA1->DA1_ZCSTCO   :=nVlrCpr
		DA1->DA1_ZPVEND   :=nPerVds
		DA1->DA1_ZPMARG   :=nPerMGR
		MsUnlock()
	EndIf

	Dbselectarea("DA1")
Return