#Include 'Protheus.ch'
#Include 'RestFul.CH'

/*/{Protheus.doc} XAG0043
Rotina do Web Service de integração com OBC, para emitir os pedidos de compra da integração
@author Leandro F Silveira
@since 08/08/2019
@version 1.0
/*/
User Function XAG0043()

		/*
	Local cJson := '{"codPedidoObc":"1590819","empresa":"01","filial":"03","cnpjFornecedor":"18307731000140","codTransportadora":"81632093000411","comprador":"eduardo.jensen","tipoFrete":"2","observacao":"","condPagto":"OBC7","dataCompra":"20191017","recno":"42671","temFornecedor":false,"itens":[{"codPedidoObc":"1590819","codPedidoErp":"","codProduto":"404143","quantidade":1.0,"dtEntrega":"20191018","valorUnit":10000.0,"pIcms":0.0,"pIpi":0.0,"codSdcv":"2362419","tipoSdcv":"SDCV TESTE","armazem":"01","solicitante":"silvio.goudim","centroCusto":"5401","contaContabil":"52110599","desSdcv":"MANUTENCAO PATIO","unMedida":"UN","ratCCusto":[{"centroCusto":"5400","contaContabil":"52110599","pRateio":80.0},{"centroCusto":"5401","contaContabil":"52110599","pRateio":20.0}]}]}'

	U_XAG0043A(cJson)
		*/

Return

WSRESTFUL PEDIDO_OBC DESCRIPTION "Serviço REST para inserção de Pedido de Compra OBC"

WSMETHOd POST DESCRIPTION "Insere o pedido de compra (SC7) na empresa informada e retorna o número do pedido"

END WSRESTFUL

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE PEDIDO_OBC

	Private cJson      := Self:GetContent()
	Private cRetJson   := ""
	Private oRetRest := nil

	//conout(cJson)

	bError := ErrorBlock({|oError|U_xag0043E(oError)})
	BEGIN SEQUENCE
		oRetRest := U_XAG0043A(cJson)
	END SEQUENCE
	ErrorBlock(bError)

	cRetJson := EncodeUtf8(FWJsonSerialize(oRetRest, .F., .F.))
	//conout(cRetJson)
	::SetContentType("application/json; charset=utf-8")
	::SetResponse(cRetJson)

Return (.T.)

Class RetornoOBC

Data sucesso as Boolean
Data codPedido as String
Data errorCode as String
Data errorMessage as String
Data email        as String

Method New() Constructor

EndClass

Method New() Class RetornoOBC

	::CodPedido    := ""
	::errorCode    := ""
	::errorMessage := ""
	::email        := ""

Return()

User  Function XAG0043E(oError)
	
	oRetRest := RetornoOBC():New()
	//conout('RegErro')
	oRetRest:errorMessage := oError:Description
	oRetRest:Sucesso      := .F.
	conout(oRetRest:errorMessage)
	cRetJson := EncodeUtf8(FWJsonSerialize(oRetRest, .F., .F.))

	//::SetContentType("application/json; charset=utf-8")
	//::SetResponse(cRetJson)

	//Break

Return
