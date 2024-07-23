#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'
#include "rwmake.ch"
#include "tbiconn.ch"
#include 'protheus.ch'
#include 'parmtype.ch'


#DEFINE TYPE_INTEGRATION   'api'

WSRESTFUL Pedidos DESCRIPTION 'Serviço de pedido de venda' SECURITY 'MATA410' FORMAT 'APPLICATION_JSON,TEXT,HTML'
	WSDATA Page         AS INTEGER OPTIONAL
	WSDATA PageSize     AS INTEGER OPTIONAL
	WSDATA Order        AS CHARACTER OPTIONAL
	WSDATA Fields       AS CHARACTER OPTIONAL

	WSMETHOD GET Pedidos;
		DESCRIPTION 'Consulta pedido de venda';
		WSSYNTAX '/pedidos_get';
		PATH '/pedidos_get';
		TTALK 'v1';
		PRODUCES APPLICATION_JSON
	WSMETHOD GET Item;
		DESCRIPTION 'Consulta pedido de venda (item)';
		WSSYNTAX '/item_get';
		PATH '/item_get';
		TTALK 'v1';
		PRODUCES APPLICATION_JSON
	WSMETHOD PUT Pedidos;
		DESCRIPTION 'Alteração do pedido de venda';
		WSSYNTAX '/pedidos_put';
		PATH 'pedidos_put';
		TTALK 'v1';
		PRODUCES APPLICATION_JSON
	WSMETHOD POST Pedidos;
		DESCRIPTION 'Inclusão do pedido de venda';
		WSSYNTAX '/pedidos_post';
		PATH '/pedidos_post';
		TTALK 'v1';
		PRODUCES APPLICATION_JSON
	WSMETHOD DELETE Pedidos;
		DESCRIPTION 'Exclusão do pedido de venda';
		WSSYNTAX '/pedidos_delete';
		PATH '/pedidos_delete';
		TTALK 'v1';
		PRODUCES APPLICATION_JSON
ENDWSRESTFUL

WSMETHOD GET Pedidos QUERYPARAM Page WSREST Pedidos
Return GetHeader( Self )

Static Function GetHeader( oWS ) As Logical
	Local lRet      As Logical
	Local oAdapter  As Object

	DEFAULT oWS:Page   := 1
	DEFAULT oWS:PageSize:= 100
	DEFAULT oWS:Fields   := ''

	lRet    := .T.

	oAdapter := PedidoVenda():New( 'GET' )

    /*
    o método SetPage indica qual Page devemos retornar
    exemplo: nossa consulta tem como resultado 1000 PageSize, e retornamos sempre uma listagem de 100 por página
    a Page 1 retorna do 1 ao 100
    a Page 2 retorna do 101 ao 200
    e assim por diante até chegar ao final da nossa consulta
    */
	oAdapter:SetPage( oWS:Page )

    /*
    SetPageSize indica a quantidade de PageSize por Page
    */
	oAdapter:SetPageSize( oWS:PageSize )

    /*
    SetOrderQuery indica a Order definida por QueryString
    */
	oAdapter:SetOrderQuery( oWS:Order )

    /*
    SetUrlFilter indica o filtro QueryString recebido ( pode ser usado um filtr oData )
    */
	oAdapter:SetUrlFilter( oWS:aQueryString )

    /*
    SetFields indica os Fields que serão retornados via QueryString
    */
	oAdapter:SetFields( oWS:Fields )

    /*
    o método abaixo irá processar as informações
    */
	oAdapter:Buscar()

    /*
    Se ocorreu tudo bem, retorna os dados no formato json
    */
	IF oAdapter:lOK

		oWS:SetResponse( oAdapter:GetJsonResponse() )
	ELSE
        /*
        ou retorna o erro encontrado durante o proessamento
        */
		SetRestFault( oAdapter:GetCode(), oAdapter:GetMessage() )
		lRet := .F.
	EndIF

    /*
    faz a desalocação de objetos e arrays utilizados
    */
	oAdapter:DeActivate()
	oAdapter := NIL

	RpcClearEnv()
Return lRet

	WSMETHOD GET Item QUERYPARAM Page WSREST Pedidos
Return GetItem( Self )

Static Function GetItem( oWS ) As Logical
	Local lRet      As Logical
	Local oAdapter    As Object

	DEFAULT oWS:Page   := 1
	DEFAULT oWS:PageSize:= 100
	DEFAULT oWS:Fields   := ''

	lRet    := .T.

    /*
    PedidoVendaItem é nossa classe que fornece os dados para o serviço...
    o primeiro parametro indica que iremos tratar o método GET
    */
	oAdapter := PedidoVendaItem():New( 'GET' )

    /*
    o método SetPage indica qual Page devemos retornar
    exemplo: nossa consulta tem como resultado 1000 PageSize, e retornamos sempre uma listagem de 100 por página
    a Page 1 retorna do 1 ao 100
    a Page 2 retorna do 101 ao 200
    e assim por diante até chegar ao final da nossa consulta
    */
	oAdapter:SetPage( oWS:Page )

    /*
    SetPageSize indica a quantidade de PageSize por Page
    */
	oAdapter:SetPageSize( oWS:PageSize )

    /*
    SetOrderQuery indica a Order definida por QueryString
    */
	oAdapter:SetOrderQuery( oWS:Order )

    /*
    SetUrlFilter indica o filtro QueryString recebido ( pode ser usado um filtr oData )
    */
	oAdapter:SetUrlFilter( oWS:aQueryString )

    /*
    SetFields indica os Fields que serão retornados via QueryString
    */
	oAdapter:SetFields( oWS:Fields )

    /*
    o método abaixo irá processar as informações
    */
	oAdapter:Buscar()

    /*
    Se ocorreu tudo bem, retorna os dados no formato json
    */
	IF oAdapter:lOK
		oWS:SetResponse( oAdapter:GetJsonResponse() )
	ELSE
        /*
        ou retorna o erro encontrado durante o proessamento
        */
		SetRestFault( oAdapter:GetCode(), oAdapter:GetMessage() )
		lRet := .F.
	EndIF

    /*
    faz a desalocação de objetos e arrays utilizados
    */
	oAdapter:DeActivate()
	oAdapter := NIL
	RpcClearEnv()
Return lRet

//WSMETHOD PUT Pedidos WSRECEIVE WSREST Pedidos
	WSMETHOD PUT Pedidos WSREST Pedidos
	Local oJson     	:= JsonObject():New()
	Local oResponse     := JsonObject():New()
	//Local cError        := ''
	Local cAliasSC6 	:= GetNextAlias()
	Local cAlias 		:= GetNextAlias()
	Local cAliasSC9 	:= GetNextAlias()
	Local cTipoFrete    := ''
	Local cLogErro    	:= ''
	Local cNumPed    	:= ''
	Local cCodMun    	:= ''
	Local cIdPed    	:= ''
	Local aItens    	:= {}
	Local aGrid    		:= {}
	Local xRet 			:= .T.
	Local cStatus 		:= ""
	Local cQry 			:= ""
	Local aCabec    	:= {}
	Local cJson     	:= ""
	Local cCodTransp    := ""
	Local nAtual 		:= 0
	Local aErroAuto 	:= {}
	Local cTipoVend 	:= ""

	Private lMsErroAuto     := .F.
	Private lAutoErrNoFile  := .T.
	Private nPeso   := 0


// irá carregar os dados vindos no corpo da requisição
	//cError := oJson:FromJson(Self:GetContent())
	cJson := Self:GetContent()
	oJson:FromJson(cJson)

	/*IF .NOT. Empty(cError)
		SetRestFault(400,'Parser Json com erro')
		xRet    := .F.
		Return(xRet)
	EndIF*/

	IF Empty(oJson['capaPedido']['NumPed'])
		SetRestFault(400,EncodeUTF8('A propriedade NumPed é obrigatória'))
		xRet    := .F.
		Return(xRet)
	EndIF

	cTipoFrete 	:= oJson['capaPedido']['TipoFrete']
	cNumPed 	:= oJson['capaPedido']['NumPed']
	cCodMun 	:= oJson['capaPedido']['CodCidadeEntrega']
	//cCodCli 	:= oJson['capaPedido']['CodigoCliente']
	//cLojacli 	:= oJson['capaPedido']['LojaCliente']
	//xRetCondPag := u_VldCondPag(oJson)

	cQry := " SELECT SC5.C5_XIDSF,SC5.C5_NOTA,SC5.C5_NUM,SC5.C5_FILIAL,SC5.C5_LIBEROK,SC5.C5_VEICULO,SC5.C5_BLQ, SC5.D_E_L_E_T_ AS DELETADO, SC5.C5_XTPVEND " + CRLF
	cQry += " FROM "+RetSqlName("SC5")+" AS  SC5  " + CRLF
	cQry += " WHERE SC5.C5_FILIAL = '" + cFilAnt +"'" + CRLF
	cQry += " AND SC5.C5_NUM = '" + cNumPed + "'" + CRLF

	PlsQuery(cQry, cAlias)

	IF ! (cAlias)->(EoF())
		cQry := " SELECT top 1 C9_BLCRED, C9_BLEST, C9_NFISCAL FROM "+RetSqlName("SC9")+ CRLF 
		cQry += " WHERE C9_FILIAL = '"+cFilAnt+"'" + CRLF 
		cQry += " AND  C9_PEDIDO = '"+cNumPed+"'" + CRLF 
		cQry += " AND D_E_L_E_T_ = '' " + CRLF 
		cQry += " AND ( C9_BLCRED <> '' OR C9_BLEST <> '' ) " + CRLF
		
		cQry := ChangeQuery(cQry)
		dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQry), cAliasSC9, .F., .T.)

		cQry := " SELECT C6_FILIAL, C6_NUM, C6_BLQ FROM " + RetSqlName('SC6') + CRLF
		cQry += " WHERE C6_FILIAL = '" + cFilAnt + "'" + CRLF
		cQry += " AND C6_NUM = '" + cNumPed + "'" + CRLF
		cQry += " AND C6_BLQ <> '' " + CRLF

		PlsQuery(cQry, cAliasSC6)

		IF !Empty((cAliasSC9)->C9_BLEST) .AND. !Empty((cAliasSC9)->C9_BLCRED) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
			cStatus := "Bloqueado por crédito"
		ELSEIF !Empty((cAlias)->C5_VEICULO) .AND. Empty((cAlias)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
			cStatus := "Programado"
		ELSEIF !Empty((cAlias)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
			cStatus := "Faturado"
		ELSEIF !Empty((cAliasSC9)->C9_BLEST) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
			cStatus := "Bloqueado por estoque"
		ELSEIF !Empty((cAliasSC9)->C9_BLCRED) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
			cStatus := "Bloqueado por crédito"
		ELSEIF Empty((cAlias)->C5_NOTA) .and. (cAlias)->C5_LIBEROK == "S" .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAlias)->DELETADO)
			cStatus := "Liberado"
		ELSEIF !(cAliasSC6)->(EoF()) .OR. !Empty((cAlias)->DELETADO) 
			cStatus := "Cancelado"
		EndIF

		IF cStatus $ "Cancelado|Faturado|Programado"
			SetRestFault(400, "O pedido nao pode ser alterado com o status: " + cStatus)
			xRet := .F.
			Return(xRet)
		ENDIF

		cTipoVend := (cAlias)->C5_XTPVEND

		aAdd(aCabec, {"C5_NUM",		cNumPed,																			NIL})
		aAdd(aCabec, {"C5_XMARKET",	oJson['capaPedido']['Marketing'],                   								NIL})
		aAdd(aCabec, {"C5_FECENT",  StoD(StrTran(oJson['capaPedido']['DtEntrega'], "-", "")),							NIL})
		aAdd(aCabec, {"C5_ENDENT",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['EnderecoEntrega'])),						NIL})
		aAdd(aCabec, {"C5_ESTE",	oJson['capaPedido']['UfEntrega'],													NIL})
		aAdd(aCabec, {"C5_CEPE",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['CepEntrega'])),							NIL})
		aAdd(aCabec, {"C5_XCODMUN",	DecodeUtf8(EncodeUtf8(SubStr(cCodMun, 3))),											NIL})
		aAdd(aCabec, {"C5_MUNE",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['MunEntrega'])),							NIL})
		aAdd(aCabec, {"C5_BAIRROE",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['BairroEntrega'])),						NIL})
		aAdd(aCabec, {"C5_TPFRETE", cTipoFrete,                  														NIL})
		aAdd(aCabec, {"C5_XCOMTEL",	oJson['capaPedido']['ComisTeleve'],													NIL})
		aAdd(aCabec, {"C5_XCOMREP",	oJson['capaPedido']['ComisRepres'],													NIL})


		IF cTipoFrete = "F"
			IF Empty(oJson['capaPedido']['Transportadora'])
				SetRestFault(400, "Erro - A transportadora precisa ser preenchida quando o frete for do tipo 'FOB' ")
			Else
				aAdd(aCabec, {"C5_TRANSP",  oJson['capaPedido']['Transportadora'],			NIL})
			ENDIF
		ELSE
			DbSelectArea('SM0')
			SA4->(DbSetOrder(3))
			IF SA4->(DbSeek(FWxFilial('SA4') + SM0->M0_CGC))
				cCodTransp := SA4->A4_COD
				SA4->(DbCloseArea())
			ELSE
				DbSelectArea("SA1")
				DbSetOrder(1) //Filial+Cliente+Loja
				IF DbSeek(xFilial("SA1")+oJson['capaPedido']['CodigoCliente']+oJson['capaPedido']['LojaCliente'])
					cCodTransp := SA1->A1_TRANSP
				ELSE
					cCodTransp := '000001'
				Endif
			ENDIF
			aAdd(aCabec, {"C5_TRANSP", cCodTransp,						NIL})
		ENDIF

		IF ! Empty(oJson['capaPedido']['Representante'])
			aAdd(aCabec, {"C5_VEND7",	oJson['capaPedido']['Representante'],						NIL})
		ENDIF

		IF cTipoVend == 'T'
			aAdd(aCabec, {"C5_OBSERVA", 	"Cliente TTD " + oJson['capaPedido']['ObsLogistica'],		NIL})
		ELSEIF ! Empty(oJson['capaPedido']['ObsLogistica'])
			aAdd(aCabec, {"C5_OBSERVA", 	oJson['capaPedido']['ObsLogistica'],						NIL})
		ENDIF

		IF ! Empty(oJson['capaPedido']['Televendas'])
			aAdd(aCabec, {"C5_VEND6",	oJson['capaPedido']['Televendas'],							NIL})
		ENDIF

		IF ! Empty(oJson['capaPedido']['CadastroProdutorRural'])
			aAdd(aCabec, {"C5_XRURAL", 	oJson['capaPedido']['CadastroProdutorRural'],		NIL})
		ENDIF
		IF ! Empty(oJson['capaPedido']['OrdemDeCompra'])
			aAdd(aCabec, {"C5_MENS2", 	"Ordem de compra " + oJson['capaPedido']['OrdemDeCompra'],				NIL})
		ENDIF

		IF ! Empty(oJson['capaPedido']['ObsNF'])
			aAdd(aCabec, {"C5_MENNOTA", oJson['capaPedido']['ObsNF'],                       NIL})
		ENDIF


		For nAtual := 1 to Len(oJson['itemPedido'])
			aItens := {}

			aAdd(aItens,	{"LINPOS"    , 		"C6_ITEM", cValToChar(StrZero(oJson['itemPedido'][nAtual]['Item'], 2))})
			aAdd(aItens,	{"AUTDELETA" , 		"N"      , 																												Nil})
		
			aAdd(aItens, {"C6_LOCAL",       	oJson['itemPedido'][nAtual]['Armazem'],             																	NIL})
			aAdd(aGrid, aItens)
		Next



		BEGIN transaction
			MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aGrid, 4)


			//Caso não de certo a inclusão, ira gerar um registro na ZZ9 para log e analise da equipe de TI
			If lMsErroAuto
				DisarmTransaction()
				aErroAuto := GetAutoGRLog()
				For nAtual := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(aErroAuto[nAtual], "<", ""), "-", "") + " " + CRLF
				Next
				cIdPed 	:= GetSXENum("ZZ9","ZZ9_ID")
				Reclock("ZZ9",.T.)
				ZZ9->ZZ9_FILIAL := cFilAnt
				ZZ9->ZZ9_ID 	:= cIdPed
				ZZ9->ZZ9_ROTINA := "VENDA"
				ZZ9->ZZ9_DATA 	:= Date()
				ZZ9->ZZ9_LOG  	:= cLogErro
				ZZ9->ZZ9_STATUS := "P"
				ZZ9->ZZ9_JSON 	:= cJson
				ZZ9->(MsUnLock())
				xRet := .F.
				ConfirmSX8()

				SetRestFault(400, "Erro ao alterar o pedido, por favor verificar na tabela de log o registro com ID " + cIdPed)
				Return(xRet)
			ENDIF

			oResponse['code']         	:= 201
			oResponse['message']      	:= "Pedido alterado no Protheus"
			oResponse['numPedido']		:= cNumPed
			oResponse['status']			:= EncodeUtf8(cStatus)
			oResponse['filial'] 		:= cFilAnt
		END Transaction

	ELSE 
		xRet := .F.
		SetRestFault(400, EncodeUtf8('Não foi possivel encontrar um pedido com essas informações: Filial - ' + cFilAnt + " Numero - "+ cNumPed))
		return xRet
	ENDIF

	IF xRet
		Self:SetStatus(201)
		Self:SetContentType(APPLICATION_JSON)
		Self:SetResponse(oResponse:ToJson())
	ENDIF
Return(xRet)

	WSMETHOD POST Pedidos WSREST Pedidos
	Local lRet      := .T.
	Local oJson     := JsonObject():New()


	Local cError       	:= ""
	Local cIdPed 		:= ""
	Local cJson         := ""
	Local lDeuCerto 	:= .T.
	Local cComando 		:= ""
	Local cAliasSC5 	:= ""
	Local cQry 			:= ""
	Local xRet 			:= .T.
	Local cStatus 		:= ""
	Local cAliasSC9 	:= ""
	Local cAliasSC6 	:= ""
	Local cAliasQry 	:= ""

	Private lMsErroAuto   := .F.
	Private lAutoErrNoFile:= .T.
	Private nPeso   := 0

	Public cCodTabela      := ''
	cError := oJson:FromJson(Self:GetContent())
	cJson  := Self:GetContent()
	oJson:FromJson(cJson)

	cNumEmp := cEmpAnt + cFilant

	cAliasQry := GetNextAlias()
	cQry := " SELECT C5_NUM,C5_XIDSF FROM " + RetSqlName('SC5') + CRLF
	cQry += " WHERE C5_XIDSF = '" + oJson['capaPedido']['SalesforceId'] + "'" + CRLF

	PlsQuery(cQry, cAliasQry)

	//Validação de duplicidade do ID SalesForce
	IF (cAliasQry)->(EoF()) .OR.  oJson['capaPedido']['Comando'] == 'S'
	
		//Vai retornar o ZZ9_ID caso não dê certo a inclusão
		cIdPed := U_XAG0129(cJson, @lDeuCerto, @cComando, @oJson,@cStatus)
	ELSE
		cIdPed 		:=  (cAliasQry)->C5_NUM
		cComando 	:= 'C'
		lDeuCerto 	:= .T.

		cAliasSC5 := GetNextAlias()
		cQry := " SELECT C5_XIDSF,C5_NOTA,C5_NUM,C5_FILIAL,C5_LIBEROK,C5_VEICULO,C5_BLQ, D_E_L_E_T_ as DELETADO FROM " + RetSqlName('SC5') + CRLF
		cQry += " WHERE C5_FILIAL = '" + cFilAnt + "'" + CRLF
		cQry += " AND C5_NUM = '" + cIdPed + "'" + CRLF

		PlsQuery(cQry, cAliasSC5)

		IF !(cAliasSC5)->(EoF())

			cAliasSC9 := GetNextAlias()
			cQry := " SELECT top 1 C9_BLCRED, C9_BLEST, C9_NFISCAL FROM "+RetSqlName("SC9") + CRLF
			cQry += " WHERE C9_PEDIDO = '"+(cAliasSC5)->C5_NUM+"'" +CRLF
			cQry += " AND C9_FILIAL = '"+(cAliasSC5)->C5_FILIAL+"'" + CRLF
			cQry += " AND D_E_L_E_T_ = '' " + CRLF
			cQry += " AND ( C9_BLCRED <> '' OR C9_BLEST <> '' ) " + CRLF

			PlsQuery(cQry, cAliasSC9)

			cAliasSC6 := GetNextAlias()
			cQry := " SELECT C6_FILIAL, C6_NUM, C6_BLQ FROM " + RetSqlName('SC6') + CRLF
			cQry += " WHERE C6_FILIAL = '" + (cAliasSC5)->C5_FILIAL + "'" + CRLF
			cQry += " AND C6_NUM = '" + (cAliasSC5)->C5_NUM + "'" + CRLF
			cQry += " AND C6_BLQ <> '' " + CRLF

			PlsQuery(cQry, cAliasSC6)

			IF !Empty((cAliasSC9)->C9_BLEST) .AND. !Empty((cAliasSC9)->C9_BLCRED) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
				cStatus := "Bloqueado por crédito"
			ELSEIF !Empty((cAliasSC5)->C5_VEICULO) .AND. Empty((cAliasSC5)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
				cStatus := "Programado"
			ELSEIF !Empty((cAliasSC5)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
				cStatus := "Faturado"
			ELSEIF !Empty((cAliasSC9)->C9_BLEST) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
				cStatus := "Bloqueado por estoque"
			ELSEIF !Empty((cAliasSC9)->C9_BLCRED) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
				cStatus := "Bloqueado por crédito"
			ELSEIF Empty((cAliasSC5)->C5_NOTA) .and. (cAliasSC5)->C5_LIBEROK == "S" .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
				cStatus := "Liberado"
			ELSEIF !(cAliasSC6)->(EoF()) .OR. !Empty((cAliasSC5)->DELETADO) .OR. !Empty((cAliasSC5)->DELETADO)
				cStatus := "Cancelado"
			EndIF
		ENDIF
	ENDIF

	IF .NOT. Empty(cError)
		SetRestFault(400, "")
		lRet    := .F.
		Return(lRet)
	EndIF

	IF cComando == 'C'
		IF ! lDeuCerto
			SetRestFault(400, "Erro ao incluir o pedido, por favor verificar na tabela de log o registro com ID " + cIdPed)
			lRet    := .F.
			Return(lRet)
		ENDIF

		bObject := {|| JsonObject():New()}
		oJson   := Eval(bObject)

		oJson['code']         	:= 201
		oJson['message']      	:= "Pedido gravado no Protheus"
		oJson['numPedido']		:= cIdPed
		oJson['status']			:= EncodeUtf8(cStatus)
		oJson['filial'] 		:= cFilAnt
	ELSEIF cComando == "S"
		U_XAG0135(@oJson, @xRet)
	ENDIF

	IF xRet
		Self:SetStatus(201)
		Self:SetContentType(APPLICATION_JSON)
		Self:SetResponse(oJson:ToJson())
	ENDIF
Return(xRet)

	WSMETHOD DELETE pedidos_delete WSREST Pedidos
	Local lRet  := .T.
	Local aArea         := FWGetArea()
	Local aAreaSC5      := SC5->(FWGetArea())
	Local aAreaSC6      := SC6->(FWGetArea())
	Local aHeader       := {}
	Local aItems        := {}
	Local oJson     	:= JsonObject():New()
	Local oResponse 	:= JsonObject():New()
	Local cMotivo 		:= ""
	Local cError        := ''
	Local cAliasSC5		:= GetNextAlias()
	Local cAliasSC6		:= GetNextAlias()
	Local cAliasSC9		:= GetNextAlias()
	Local nOpcao        := 5
	Local cIdPed 		:= ""
	Local cJson         := ''
	Local nAtual 		:= 0
	Local cLogErro 		:= ""
	Local aErroAuto 	:= {}
	Local aLinha 		:= {}
	Local aItens 		:= {}
	Local cQry 			:= ""

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .T.
	Private lAutoErrNoFile  := .F.

// irá carregar os dados vindos no corpo da requisição
	cError := oJson:FromJson(Self:GetContent())
	cJson := Self:GetContent()

	IF .NOT. Empty(cError)
		SetRestFault(400,'Objeto jSon com erro')
		lRet    := .F.
		Return(lRet)
	EndIF


	IF Empty(oJson['NumPed'])
		SetRestFault(400,EncodeUTF8('A propriedade "NumPed" é obrigatória'))
		lRet    := .F.
		Return(lRet)
	ELSE
		cNumPedido := oJson['NumPed']
	EndIF

	IF Empty(oJson['Filial'])
		SetRestFault(400,EncodeUTF8('A propriedade "Filial" é obrigatória'))
		lRet    := .F.
		Return(lRet)
	EndIF


	IF Empty(oJson['Cliente'])
		SetRestFault(400,EncodeUTF8('A propriedade "Cliente" é obrigatória'))
		lRet    := .F.
		Return(lRet)
	EndIF

	IF Empty(oJson['Loja'])
		SetRestFault(400,EncodeUTF8('A propriedade "Loja" é obrigatória'))
		lRet    := .F.
		Return(lRet)
	EndIF

	cQry := " SELECT C5_XIDSF,C5_NOTA,C5_NUM,C5_FILIAL,C5_LIBEROK,C5_VEICULO,C5_BLQ, D_E_L_E_T_ as DELETADO FROM " + RetSqlName('SC5') + CRLF
	cQry += " WHERE C5_FILIAL = '" + oJson['Filial'] + "'" + CRLF
	cQry += " AND C5_NUM = '" + oJson['NumPed'] + "'" + CRLF

	PlsQuery(cQry, cAliasSC5)

	IF !(cAliasSC5)->(EoF())
		cQry := " SELECT top 1 C9_BLCRED, C9_BLEST, C9_NFISCAL FROM "+RetSqlName("SC9") + CRLF
		cQry += " WHERE C9_PEDIDO = '"+(cAliasSC5)->C5_NUM+"'" +CRLF
		cQry += " AND C9_FILIAL = '"+(cAliasSC5)->C5_FILIAL+"'" + CRLF
		cQry += " AND D_E_L_E_T_ = '' " + CRLF
		cQry += " AND ( C9_BLCRED <> '' OR C9_BLEST <> '' ) " + CRLF

		PlsQuery(cQry, cAliasSC9)

		cQry := " SELECT C6_FILIAL, C6_NUM, C6_BLQ FROM " + RetSqlName('SC6') + CRLF
		cQry += " WHERE C6_FILIAL = '" + (cAliasSC5)->C5_FILIAL + "'" + CRLF
		cQry += " AND C6_NUM = '" + (cAliasSC5)->C5_NUM + "'" + CRLF
		cQry += " AND C6_BLQ <> '' " + CRLF

		PlsQuery(cQry, cAliasSC6)

		IF !Empty((cAliasSC5)->C5_VEICULO) .AND. Empty((cAliasSC5)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
			lRet := .F.
			cMotivo := "Programado"
		ELSEIF !Empty((cAliasSC5)->C5_NOTA) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
			lRet := .F.
			cMotivo := "Faturado"
		ELSEIF !Empty((cAliasSC9)->C9_BLEST) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
			lRet := .T.
			cMotivo := "Bloqueado por estoque"
		ELSEIF !Empty((cAliasSC9)->C9_BLCRED) .AND. Empty((cAliasSC9)->C9_NFISCAL) .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
			lRet := .T.
			cMotivo := "Bloqueado por crédito"
		ELSEIF Empty((cAliasSC5)->C5_NOTA) .and. (cAliasSC5)->C5_LIBEROK == "S" .AND. (cAliasSC6)->(EoF()) .AND. Empty((cAliasSC5)->DELETADO)
			lRet := .T.
			cMotivo := "Liberado"
		ELSEIF !(cAliasSC6)->(EoF()) .OR. !Empty((cAliasSC5)->DELETADO)
			lRet := .F.
			cMotivo := "Cancelado"
		EndIF

		IF ! lRet
			SetRestFault(400, "O pedido nao pode ser cancelado porque esta com o status: "+ cMotivo)
			return(lRet)
		ENDIF

	ENDIF

	cQry := " SELECT C5_FILIAL, C5_CLIENTE, C5_LOJACLI, C5_NUM, R_E_C_N_O_ FROM " + RetSqlName('SC5') + CRLF
	cQry += " WHERE C5_FILIAL = '" +oJson['Filial'] + "'" + CRLF
	cQry += " AND C5_NUM = '" +oJson['NumPed'] + "'" + CRLF
	cQry += " AND C5_CLIENTE = '" +oJson['Cliente'] + "'" + CRLF
	cQry += " AND C5_LOJACLI = '" + oJson['Loja'] + "'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasSC5)

	IF ! (cAliasSC5)->(EoF())
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) // C5_FILIAL + C5_NUM
		DbSelectArea('SC6')
		SC6->(DbSetOrder(1)) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
		DbSelectArea('SC9')
		SC9->(DbSetOrder(1)) // C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED

		//Somente se encontrar o pedido
		If SC5->(MsSeek(FWxFilial("SC5") + cNumPedido))

			//Posiciona no item do pedido
			If SC6->( MsSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

				//Percorre todos os itens do pedido de venda
				While ! SC6->(EoF()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM

					//Posiciona na liberação do item do pedido e enquanto houver dados estorna a liberação
					SC9->(MsSeek(FWxFilial('SC9') + SC6->C6_NUM + SC6->C6_ITEM))
					While  ! SC9->(EoF()) .And. SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM) == FWxFilial('SC9') + SC6->(C6_NUM + C6_ITEM)
						SC9->(a460Estorna(.T.))
						SC9->(DbSkip())
					EndDo

					SC6->(DbSkip())
				EndDo
			EndIf
		EndIf

		SC5->(DbGoTo((cAliasSC5)->R_E_C_N_O_))

		aHeader := {}
		aItems := {}

		//aAdd(aHeader, {"C5_FILIAL",  SC5->C5_FILIAL,      	Nil})
		aAdd(aHeader, {"C5_NUM",     SC5->C5_NUM,      		Nil})
		aAdd(aHeader, {"C5_TIPO",    SC5->C5_TIPO,       	Nil})
		aAdd(aHeader, {"C5_CLIENTE", SC5->C5_CLIENTE,    	Nil})
		aAdd(aHeader, {"C5_LOJACLI", SC5->C5_LOJACLI,   	Nil})
		aAdd(aHeader, {"C5_LOJAENT", SC5->C5_LOJAENT,  		Nil})
		aAdd(aHeader, {"C5_CONDPAG", SC5->C5_CONDPAG, 		Nil})


		cQry := " SELECT  C6_FILIAL, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_PRCVEN, C6_PRUNIT, C6_VALOR, C6_TES, C6_NUM, R_E_C_N_O_ FROM " + RetSqlName('SC6') + CRLF
		cQry += " WHERE C6_FILIAL = '" +oJson['Filial'] + "'" + CRLF
		cQry += " AND C6_NUM = '" +oJson['NumPed'] + "'" + CRLF
		cQry += " AND D_E_L_E_T_ = '' " + CRLF

		PlsQuery(cQry, cAliasSC6)

		SC6->(DbGoTo((cAliasSC6)->R_E_C_N_O_))

		WHILE ! (cAliasSC6)->(EoF())
			//--- Informando os dados do item do Pedido de Venda
			aLinha := {}
			//aadd(aLinha,{"C6_ITEM",    (cAliasSC6)->C6_FILIAL, 			Nil})
			aadd(aLinha,{"C6_ITEM",    (cAliasSC6)->C6_ITEM, 			Nil})
			aadd(aLinha,{"C6_PRODUTO", (cAliasSC6)->C6_PRODUTO,      	Nil})
			aadd(aLinha,{"C6_QTDVEN",  (cAliasSC6)->C6_QTDVEN,          Nil})
			aadd(aLinha,{"C6_PRCVEN",  (cAliasSC6)->C6_PRCVEN,          Nil})
			aadd(aLinha,{"C6_PRUNIT",  (cAliasSC6)->C6_PRUNIT,          Nil})
			aadd(aLinha,{"C6_VALOR",   (cAliasSC6)->C6_VALOR,          	Nil})
			aadd(aLinha,{"C6_TES",     (cAliasSC6)->C6_TES,        		Nil})
			aadd(aItens, aLinha)

			(cAliasSC6)->(DbSkip())
		ENDDO

		MsExecAuto({|a, b, c| MATA410(a, b, c)},aHeader,aItens,nOpcao)

		If lMsErroAuto
			RollBackSX8()
			DisarmTransaction()
			aErroAuto := GetAutoGRLog()
			For nAtual := 1 To Len(aErroAuto)
				cLogErro += StrTran(StrTran(aErroAuto[nAtual], "<", ""), "-", "") + " " + CRLF
			Next
			cIdPed 	:= GetSXENum("ZZ9","ZZ9_ID")
			Reclock("ZZ9",.T.)
			ZZ9->ZZ9_FILIAL := cFilAnt
			ZZ9->ZZ9_ID 	:= cIdPed
			ZZ9->ZZ9_ROTINA := "VENDA"
			ZZ9->ZZ9_DATA 	:= Date()
			ZZ9->ZZ9_LOG  	:= cLogErro
			ZZ9->ZZ9_STATUS := "P"
			ZZ9->ZZ9_JSON 	:= cJson
			ZZ9->(MsUnLock())
			lRet := .F.
			ConfirmSX8()
			SetRestFault(400, "Erro ao excluir o pedido, por favor verificar na tabela de log o registro com ID " + cIdPed)
			lRet    := .F.
			Return(lRet)
		ELSE

			oResponse := JsonObject():New()
			oResponse['id']       := AllTrim(SC5->C5_NUM)
			oResponse['message']  := EncodeUTF8('Pedido de venda excluído com sucesso')
            /*
                Iremos retornar o json de forma serializada, e definição do codigo htto, com 201, ou seja, criado...
            */
			Self:SetStatus(200)
			Self:SetContentType(APPLICATION_JSON)
			Self:SetResponse(FWJsonSerialize(oResponse))
		EndIF
        /*
            Liberar memória...
        */
		FWRestArea(aAreaSC5)
		FWRestArea(aAreaSC6)
		FWRestArea(aArea)
		FWFreeObj(oJson)
		FWFreeObj(oResponse)
	ELSE
		SetRestFault(400,EncodeUTF8('Pedido de venda não localizado'))
		lRet := .F.
		Return(lRet)
	EndIF

Return(lRet)

Static Function FaixaFrete(cTipTra As Character,;
		cRota As Character,;
		cPorto As Character,;
		dData As Date) As Array
	Local aFaixas 	:= {}
	Local aArea		:= FWGetArea()

	Local cQry      := ''


	cQry := ""
	cQry += "SELECT DTT.DTT_FAIXA,DTT.DTT_VALOR,DTT.DTT_INTERV FROM " + RetSqlName("DTT") + " DTT "
	cQry += "       INNER JOIN " + RetSqlName("DUS") + " DUS "
	cQry += "             ON DUS.D_E_L_E_T_ <> '*' "
	cQry += "             AND DUS.DUS_TABCAR=DTT.DTT_TABCAR "
	cQry += "             AND DUS.DUS_DATDE<='"+DTOS(dData)+"' "
	cQry += "             AND (DUS.DUS_DATATE>='"+DTOS(dData)+"' OR DUS.DUS_DATATE=' ') "
	cQry += "             AND DUS.DUS_TIPTAB='"+cTipTra+"' "

	IF cTipTra<>"01"
		cQry += "             AND DUS.DUS_PORTO='"+cPorto+"' "
	EndIF

	cQry += "WHERE DTT.D_E_L_E_T_ <> '*' "
	cQry += "AND DTT.DTT_ROTA='"+cRota+"' "
	cQry += "AND DTT.DTT_FILIAL='"+cFilAnt+"' "
	cQry += "ORDER BY DTT.DTT_FAIXA "

	IF (Select('QRY') <> 0)
		dbSelectArea('QRY')
		QRY->(dbCloseArea())
	EndIF

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQry), 'QRY', .F., .T.)
	dbSelectArea('QRY')
	dbGoTop()
	While .NOT. Eof()
		aAdd(aFaixas,{QRY->DTT_FAIXA,QRY->DTT_VALOR,QRY->DTT_INTERV})
		dbSelectArea('QRY')
		dbSkip()
	EndDo

	IF (Select('QRY') <> 0)
		dbSelectArea('QRY')
		QRY->(dbCloseArea())
	EndIF

	FWRestArea(aArea)

Return aFaixas


Static Function JsonData(cPedido As Character, cLegenda As Character, lSC5 As Logical) As J
	Local bObject       As CodeBlock
	Local bError        As CodeBlock
	Local bErrorBlock   As Logical
	Local oJson         As Object
	Local oError        As Object
	Local cView         As Character
	Local cQuery        As Character
	Local cTCSqlError   As Character
	Local aItem         As Array
	Local aQuery        As Array

	bObject := {|| JsonObject():New()}
	oJson   := Eval(bObject)

	oJson['pedido']         := cPedido
	oJson['status']         := cLegenda
	IF lSC5
		oJson['mensagem']       := 'pedido criado com sucesso'
	ELSE
		oJson['mensagem']       := 'pedido alterado com sucesso'
	EndIF
	oJson['itemPedido']     := {}

	bError      := { |e| oError := e, BREAK(e) }
	bErrorBlock := ErrorBlock( bError )

	cView   := GetNextAlias()

	BEGIN SEQUENCE

		BEGINSQL Alias cView
            SELECT
                SC6.C6_FILIAL,
                SC6.C6_ITEM,
                SC6.C6_PRODUTO,
                SC6.C6_QTDVEN
            FROM
                %Table:SC6% SC6
            WHERE
                SC6.C6_FILIAL = %xFilial:SC6%
                AND SC6.C6_NUM = %Exp:cPedido%
                AND SC6.%NotDel%
		ENDSQL

		aQuery  := GetLastQuery()
		cQuery  := aQuery[2]

		aItem   := {}

		dbSelectArea(cView)
		(cView)->(dbGoTop())
		IF (cView)->(.NOT. Eof())
			While (cView)->(.NOT. Eof())
				aItem   := JsonObject():New()
				aItem['item']           := AllTrim((cView)->C6_ITEM)
				aItem['produto']        := AllTrim((cView)->C6_PRODUTO)
				aItem['quantidade']     := (cView)->C6_QTDVEN
				aAdd(oJson['itemPedido'],aItem)
				(cView)->(dbSkip())
			End
		ELSE
			(cView)->(dbCloseArea())
		EndIF

		RECOVER

		aQuery  := GetLastQuery()
		cQuery  := aQuery[2]

		cError      := oError:Description
		cTCSqlError := TCSqlError()

	END SEQUENCE

	ErrorBlock( bErrorBlock )

Return(oJson:ToJson())

Static Function Acento(cString)
	Local cChar  := ""
	Local nX     := 0
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
	Local cTio   := "ãõ"
	Local cCecid := "çÇ"

	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTio)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("ao",nY,1))
			EndIf
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next
	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If Asc(cChar) < 32 .Or. Asc(cChar) > 123
			cString:=StrTran(cString,cChar,"")
		Endif
	Next nX
	cString := _NoTags(cString)
Return cString
