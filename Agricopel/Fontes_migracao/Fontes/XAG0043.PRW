#Include 'Protheus.ch'
#Include 'RestFul.CH'

/*/{Protheus.doc} XAG0043
Rotina do Web Service de integração com OBC, para emitir os pedidos de compra da integração
@author Leandro F Silveira
@since 08/08/2019
@version 1.0
/*/
User Function XAG0043()

	Local cJson := '{"codPedidoObc":"815519","empresa":"30","filial":"01","cnpjFornecedor":"73989956000131","codTransportadora":"0","comprador":"eduardo.jensen","tipoFrete":"1","observacao":"Teste digitado na hora de gerar o pedido de compra","condPagto":"OBC75","dataCompra":"20190814","recno":"11555","temFornecedor":false,"itens":[{"codPedidoObc":"815519","codPedidoErp":"","codProduto":"358720","quantidade":10.0,"dtEntrega":"20190828","valorUnit":57.89,"pIcms":0.0,"pIpi":0.0,"codSdcv":"1163719","solicitante":"admin","centroCusto":"1009","contaContabil":"52110701","desSdcv":"CHAPA DE ACO 1200X2000X2,65MM","unMedida":"UN","ratCCusto":[{"centroCusto":"1009","contaContabil":"52110701","pRateio":100.0}]}]}'

	U_XAG0043A(cJson)

Return

WSRESTFUL PEDIDO_OBC DESCRIPTION "Serviço REST para inserção de Pedido de Compra OBC"

WSMETHOd POST DESCRIPTION "Insere o pedido de compra (SC7) na empresa informada e retorna o número do pedido"

END WSRESTFUL

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE PEDIDO_OBC

	Local cJson      := Self:GetContent()
	Local cRetJson   := ""

	Private oRetRest := nil

	bError := ErrorBlock({|oError|RegErro(oError)})
	BEGIN SEQUENCE
		oRetRest := U_XAG0043A(cJson)
	END SEQUENCE
	ErrorBlock(bError)

	cRetJson := EncodeUtf8(FWJsonSerialize(oRetRest, .F., .F.))

	::SetContentType("application/json; charset=utf-8")
	::SetResponse(cRetJson)

Return (.T.)

Class RetornoOBC

Data sucesso as Boolean
Data codPedido as String
Data errorCode as String
Data errorMessage as String

Method New() Constructor

EndClass

Method New() Class RetornoOBC

	::CodPedido    := ""
	::errorCode    := ""
	::errorMessage := ""

Return(Self)

Static Function RegErro(oError)

	oRetRest := RetornoOBC():New()

	oRetRest:errorMessage := oError:Description
	oRetRest:Sucesso      := .F.

	Break

Return()