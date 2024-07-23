
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460QRY   �Autor  �Jaime Wikanski      � Data �  29/11/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para avaliar se deve ou nao exibir a       ���
���          �os registros de entrega futura                              ���
�������������������������������������������������������������������������͹��
���Uso       � Fusus                                                      ���
�������������������������������������������������������������������������͹��
���Altera��es�10/05/2015 - Max Ivan (Nexus) - Ajustado para permitir que  ���
���          �seja mostrado em tela apenas os pedidos liberados. LUBTROL  ���
���          �19/10/2015 - Max Ivan (Nexus) - Ajustado para permitir fil- ���
���          �trar os registros a serem mostrados, pelo almoxarifado e    ���
���          �campo customizado C5_XIMPRE. AGRICOPEL                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M460QRY()
//��������������������������������������������������������������������������������Ŀ
//�Declaracao de variaveis                                                         �
//����������������������������������������������������������������������������������
Local cQuery	:= PARAMIXB[1]
Local nTipo		:= PARAMIXB[2]

If !lM460MKBTodos
	If nTipo == 1
		cQuery += " AND (SELECT COUNT(*)"
		cQuery += "      FROM "+RetSqlName("SC6")+" SC6"
		cQuery += "      WHERE C6_FILIAL = '"+xFilial("SC6")+"'"
		cQuery += "      AND C6_NUM = C9_PEDIDO"
		cQuery += "      AND C6_ITEM = C9_ITEM"
		cQuery += "      AND C6_ENTREG <= '"+Dtos(dDatabase)+"'"
		cQuery += "      AND SC6.D_E_L_E_T_ <> '*') > 0"
	Endif
Endif

//CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que est�o liberados para faturamento
/*If nTipo == 1
   If _lSoLiber
      cQuery += " AND C9_BLCRED = '' AND C9_BLOQUEI = '' AND C9_BLEST = '' "
   EndIf
EndIf*/
//FIM - CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que est�o liberados para faturamento 

////CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
If !Empty(_cAlmox)
   cQuery += " AND C9_LOCAL = '"+_cAlmox+"' "
EndIf
If SubsTr(_cPedImp,1,1) == "S" .or. SubsTr(_cPedImp,1,1) == "N"
   cQuery += " AND C5_XIMPRE "+If(SubsTr(_cPedImp,1,1) == "S","=","<>")+" 'S' "
EndIf
//FIM - //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE

Return(cQuery)