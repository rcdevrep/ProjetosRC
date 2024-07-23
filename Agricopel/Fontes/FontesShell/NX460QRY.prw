#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

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

//User Function M460QRY()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Fun็ใo (PE) de M460QRY p/ NX460QRY, e criado esta chamada dentro do fonte original da Shell.             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
User Function NX460QRY()

	Local 	 cQuery := ""
	Local	 _cRotDBGin :=  SuperGetMv( "MV_XROTDBG" , .F. , ""  ) 
	Private  _cFilDtEmb :=  SuperGetMv( "MV_XDTEMB"  , .F. , ""  ) 

	If !Empty(_cAlmox)
		cQuery += " AND C9_LOCAL = '" + _cAlmox + "' "

		If (cEmpAnt == '01' .AND. cFilAnt == '06' .AND. _cAlmox == "20" .AND. !Empty(_cPedAlvor))

			// VENDEDORES DE CODIGO 000048 E 000051 - VENDEDORES ALVORADA
			If (SubsTr(_cPedAlvor,1,1) == "S")
				cQuery += " AND C5_VEND1 IN ('000048','000051') " 
			ElseIf (SubsTr(_cPedAlvor,1,1) == "N")
				cQuery += " AND C5_VEND1 NOT IN ('000048','000051') " 
			EndIf
		EndIf
	EndIf

	If SubsTr(_cPedImp,1,1) == "S" .or. SubsTr(_cPedImp,1,1) == "N"
		If cFilAnt == '19' 
			//Permite somente faturamento do que foi separado 
			If SubsTr(_cPedImp,1,1) == "S"
				cQuery += " AND C9_XDTEDI <> '' AND C9_XHREDI <> ''  AND C9_XDTSEP <> '' AND C9_XHRSEP <> '' " 
			Else
				cQuery += "  AND C9_XDTSEP = '' AND C9_XHRSEP = '' " 
			Endif 
		Else 
			cQuery += " AND C5_XIMPRE "+If(SubsTr(_cPedImp,1,1) == "S","=","<>")+" 'S' "
		Endif
	EndIf

	// Verificar se filial utiliza Roteirizador do DBGint, para fazer Filtro para 
	//somente mostrar pedidos programados
	If alltrim(cFilAnt) <> '' .and. cFilAnt $ alltrim(_cRotDBGin)
   		cQuery += FiltraProg()
	else
		_cPedProg   := ""			
	Endif 


Return(cQuery)


//Tela com Filtro de Programa็ใo	
Static Function FiltraProg()

	Local _lOk  := .F.
	Local _oButton1
	Local _dDataProg := ctod('')
	Local   _cRet      := ""
	Private _oRadMenu1
	Private _nRadMenu1 := 1
	Private _oDlgProg
	Private _oDataProg
	Private _oSay1
	
    DEFINE MSDIALOG _oDlgProg TITLE "Filtrar Pedidos" FROM 000, 000  TO 130, 220 COLORS 0, 16777215 PIXEL

		@ 004, 007 RADIO _oRadMenu1 VAR _nRadMenu1 ITEMS "Programados","Nใo Programados","Todos" SIZE 092, 029 OF _oDlgProg COLOR 0, 16777215 PIXEL ON CHANGE ValRad() 
		@ 035, 039 MSGET _oDataProg VAR _dDataProg SIZE 046, 009 OF _oDlgProg COLORS 0, 16777215 PIXEL
		@ 035, 007 SAY _oSay1 PROMPT "Data Prog." SIZE 029, 007  OF _oDlgProg COLORS 0, 16777215 PIXEL 
		
		DEFINE SBUTTON _oButton1 FROM 050, 070 TYPE 01 OF _oDlgProg ENABLE  ACTION(_lOk := .T., _oDlgProg:End())
	
	ACTIVATE MSDIALOG _oDlgProg

	If _lOk
		If _nRadMenu1 == 1//Programados 
			If !Empty(_dDataProg) //Data Preenchida
				_cRet := " AND C5_XDTPRG ='"+dtos(_dDataProg)+"' " 
				_cPedProg := " .AND. dtos(Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_XDTPRG')) = '"+dtos(_dDataProg)+"' "
				If cFilAnt $ _cFilDtEmb .and. _cFilDtEmb <> ''
					_cRet += " AND C5_XDTEMB='"+dtos(_dDataProg)+"' " 
					_cPedProg += " .AND. dtos(Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_XDTEMB')) = '"+dtos(_dDataProg)+"' "
				Endif 
			else //data nใo preenchida
				_cRet := " AND C5_XDTPRG <> '' " 
				_cPedProg := " .AND. alltrim(dtos(Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_XDTPRG'))) <> '' "
				If cFilAnt $ _cFilDtEmb .and. _cFilDtEmb <> ''
					_cRet += " AND C5_XDTEMB <> '' " 
					_cPedProg += " .AND. alltrim(dtos(Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_XDTEMB'))) <> '' "
				Endif 
			Endif 
		Elseif _nRadMenu1 == 2//Nใo Programados 
			_cRet := " AND C5_XDTPRG ='' "
			_cPedProg := " .AND. alltrim(dtos(Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_XDTPRG')))  == '' " 
		Endif 
	Endif 

	//_cPedProg := _cRet

Return _cRet


Static Function ValRad()

	If _nRadMenu1 = 1
		_oDataProg:LVISIBLE := .T.
		_oSay1:LVISIBLE := .T.
	Else
		_oDataProg:LVISIBLE := .F.
		_oSay1:LVISIBLE := .F.
	Endif 
	
Return 
