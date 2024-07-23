/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460FIL   �Autor  �Jaime Wikanski      � Data �  29/11/06   ���
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

//User Function M460FIL()
//����������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//�04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Fun��o (PE) de M460FIL p/ NX460FIL, e criado esta chamada dentro do fonte original da Shell.             �
//������������������������������������������������������������������������������������������������������������������������������������������������������������
User Function NX460FIL()
	//��������������������������������������������������������������������������������Ŀ
	//�Declaracao de variaveis                                                         �
	//����������������������������������������������������������������������������������
	Local cCondicao	:= ""

	////CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
	If !Empty(_cAlmox)
		cCondicao := cCondicao + " .AND. C9_LOCAL == '"+_cAlmox+"' "

		If (cEmpAnt == '01' .AND. cFilAnt == '06' .AND. _cAlmox == "20" .AND. !Empty(_cPedAlvor))
			If (SubsTr(_cPedAlvor,1,1) == "S")
				cCondicao := cCondicao + " .AND. Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_VEND1') $ '000048|000051' "
			ElseIf (SubsTr(_cPedAlvor,1,1) == "N")
				cCondicao := cCondicao + " .AND. !Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_VEND1') $ '000048|000051' "
			EndIf	
		EndIf
	EndIf
	
	If SubsTr(_cPedImp,1,1) == "S" .or. SubsTr(_cPedImp,1,1) == "N"
		If cFilAnt == '19' 
			//Permite somente faturamento do que foi separado 
			iF SubsTr(_cPedImp,1,1) == "S"
				cCondicao := cCondicao + " .AND. alltrim(C9_XDTEDI) <> '' .AND. alltrim(C9_XHREDI) <> ''  .AND. alltrim(C9_XDTSEP) <> '' .AND. alltrim(C9_XHRSEP) <> '' " 
			Else
				cCondicao := cCondicao + " .AND. alltrim(C9_XDTSEP) = '' .AND. alltrim(C9_XHRSEP) = '' " 
			Endif 
		Else
			cCondicao := cCondicao + " .AND. Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_XIMPRE') "+If(SubsTr(_cPedImp,1,1) == "S","==","#")+" 'S' "
		Endif 
		
	
	EndIf
	//FIM - //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE

	//Se tiver fitro de Programa��o, aplica 
	If !empty(_cPedProg)
		cCondicao +=  _cPedProg
	Endif 

	
Return(cCondicao)
