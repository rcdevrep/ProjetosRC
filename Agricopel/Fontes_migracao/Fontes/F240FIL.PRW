
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F240FIL   �Autor  �Microsiga           � Data �  31/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtro para Considerar somentes titulos a pagar no vecto   ���
���          � parametrizado e com codigo de barras.                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function F240FIL() 
    // DVENINI240 e DVENFIM240 Sao parametros passados pela gera�ao do Bordero
    // Basta dar F1 para ver o nome dos campos nestes parametros de gera�ao de bordero de pagamentos
	cRet := Space(50)
//	cRet := '(E2_CODBAR <> "" .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240)'
	cRet := '(!Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240)'
Return cRet