
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460QRY   บAutor  ณJaime Wikanski      บ Data ณ  29/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para avaliar se deve ou nao exibir a       บฑฑ
ฑฑบ          ณos registros de entrega futura                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fusus                                                      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบAltera็๕esณ10/05/2015 - Max Ivan (Nexus) - Ajustado para permitir que  บฑฑ
ฑฑบ          ณseja mostrado em tela apenas os pedidos liberados. LUBTROL  บฑฑ
ฑฑบ          ณ19/10/2015 - Max Ivan (Nexus) - Ajustado para permitir fil- บฑฑ
ฑฑบ          ณtrar os registros a serem mostrados, pelo almoxarifado e    บฑฑ
ฑฑบ          ณcampo customizado C5_XIMPRE. AGRICOPEL                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function M460QRY()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

//CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que estใo liberados para faturamento
/*If nTipo == 1
   If _lSoLiber
      cQuery += " AND C9_BLCRED = '' AND C9_BLOQUEI = '' AND C9_BLEST = '' "
   EndIf
EndIf*/
//FIM - CUSTOMIZADO LUBTROL - 10/05/2015 - Personalizado para trazer somente itens que estใo liberados para faturamento 

////CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE
If !Empty(_cAlmox)
   cQuery += " AND C9_LOCAL = '"+_cAlmox+"' "
EndIf
If SubsTr(_cPedImp,1,1) == "S" .or. SubsTr(_cPedImp,1,1) == "N"
   cQuery += " AND C5_XIMPRE "+If(SubsTr(_cPedImp,1,1) == "S","=","<>")+" 'S' "
EndIf
//FIM - //CUSTOMIZADO AGRICOPEL - 19/10/2015 - Personalizado para filtrar pedidos pro almoxarifado e campo C5_XIMPRE

Return(cQuery)