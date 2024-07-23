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

//User Function M460QRY()
//����������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//�04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Fun��o (PE) de M460QRY p/ NX460QRY, e criado esta chamada dentro do fonte original da Shell.             �
//������������������������������������������������������������������������������������������������������������������������������������������������������������
User Function NX460QRY()

	Local cQuery := ""

	////CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
	If !Empty(_cAlmox)
		cQuery += " AND C9_LOCAL = '"+_cAlmox+"' "
	EndIf
	If SubsTr(_cPedImp,1,1) == "S" .or. SubsTr(_cPedImp,1,1) == "N"
		cQuery += " AND C5_XIMPRE "+If(SubsTr(_cPedImp,1,1) == "S","=","<>")+" 'S' "
	EndIf
	//FIM - //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE

Return(cQuery)