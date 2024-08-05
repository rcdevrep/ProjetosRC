
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIL   ºAutor  ³Jaime Wikanski      º Data ³  29/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para avaliar se deve ou nao exibir a       º±±
±±º          ³os registros de entrega futura                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fusus                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterações³10/05/2015 - Max Ivan (Nexus) - Ajustado para permitir que  º±±
±±º          ³seja mostrado em tela apenas os pedidos liberados. LUBTROL  º±±
±±º          ³19/10/2015 - Max Ivan (Nexus) - Ajustado para permitir fil- º±±
±±º          ³trar os registros a serem mostrados, pelo almoxarifado e    º±±
±±º          ³campo customizado C5_XIMPRE. AGRICOPEL                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M460FIL()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCondicao		:= " .T."

If lM460Exibe
	cCondicao	:= " .T."
Else
	If !lM460MKBTodos
		cCondicao := " DTOS(Posicione('SC6',1,xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM,'C6_ENTREG')) <= DTOS(dDataBase)"	
	Endif
Endif

//CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que estão liberados para faturamento
/*If _lSoLiber
   cCondicao := cCondicao + " .AND. Empty(C9_BLCRED) .AND. Empty(C9_BLOQUEI) .AND. Empty(C9_BLEST) "
EndIf*/
//FIM - CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que estão liberados para faturamento

////CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
If !Empty(_cAlmox)
   cCondicao := cCondicao + " .AND. C9_LOCAL == '"+_cAlmox+"' "
EndIf
If SubsTr(_cPedImp,1,1) == "S" .or. SubsTr(_cPedImp,1,1) == "N"
   cCondicao := cCondicao + " .AND. Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_XIMPRE') "+If(SubsTr(_cPedImp,1,1) == "S","==","#")+" 'S' "
EndIf
//FIM - //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE

Return(cCondicao)