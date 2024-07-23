#Include 'Protheus.ch'
#Include 'RestFul.CH'
 
/*/{Protheus.doc} XAGDOX
Web Service de integração com DOX, DOC sempre "chamará" este webservice para acessar as rotinas de integração, com base no parâmetro
rotina do Json do corpo da requisição
@author Leandro F Silveira
@since 24/06/2019
@version 1.0
/*/
User Function XAGDOX()

   // Local _cJson := ""
   // Local _cRet  := ""

   // _cJson += '{ '
   // _cJson += '    "rotina": "XAGDOX01",'
   // _cJson += '	   "cnpjClientePedido": "81632093000764", '
   // _cJson += '    "obsNotaFiscal": "Teste Leandro TI", '
   // _cJson += '	   "itens": [{"codProduto": "302635","qtdePedido": 1}] '
   // _cJson += '} '

   // _cRet := ProcReq(_cJson)

   // MsgInfo(_cRet)

Return()

Static Function ProcReq(_cJson)

   Local _oJsonDOX  := Nil
   Local _cRotina   := ""
   Local _cRetJson  := ""

   Private _oRet    := Nil

	bError := ErrorBlock({|oError|LogErroIni(oError)})
	BEGIN SEQUENCE
      _oJsonDOX := JsonObject():new()
      _oJsonDOX:fromJson(_cJson)

      _cRotina := "U_" + _oJsonDOX:GetJsonText("rotina") + "(_oJsonDOX)"
      _oRet := &(_cRotina)
	END SEQUENCE
	ErrorBlock(bError)

   _cRetJson := EncodeUtf8(SerialRet(_oRet))

   FreeObj(_oRet)

Return(_cRetJson)

WSRESTFUL DOX_INTEGRACAO DESCRIPTION "Serviço REST para integração com DOX"

WSMETHOD POST DESCRIPTION "Envia dados para serem executados via ExecAuto no Protheus"

END WSRESTFUL
 
WSMETHOD POST WSSERVICE DOX_INTEGRACAO

   Local _cJson     := ::GetContent()
   Local _cRotina   := ""
   Local _cRetJson  := ""
   Local _oRet      := Nil
   Local _oJsonDOX  := Nil

	_cRetJson := ProcReq(_cJson)

	::SetContentType("application/json")
	::SetResponse(_cRetJson)

Return (.T.)

Static Function SerialRet(_oRet)

   Local _oRetJson := Nil
   Local _cRet     := ""

   _oRetJson := JsonObject():new()

   _oRetJson["errorMessage"] := _oRet:errorMessage
   _oRetJson["errorCode"]    := _oRet:errorCode
	_oRetJson["msgSucesso"]   := _oRet:msgSucesso
	_oRetJson["sucesso"]      := If(_oRet:sucesso, .T., .F.)

   _cRet := _oRetJson:toJSON()
   FreeObj(_oRetJson)

Return(_cRet)

Class DOXWsRetorno

Data sucesso as Boolean
Data msgSucesso as String
Data errorCode as String
Data errorMessage as String

Method New() Constructor

EndClass

Method New() Class DOXWsRetorno

   ::sucesso      := .F.
   ::msgSucesso   := ""
	::errorCode    := ""
	::errorMessage := ""

Return(Self)

Static Function LogErroIni(oError)

   Local _cMsgErro := oError:Description
   Default _oRet := DOXWsRetorno():New()

	_oRet:errorMessage += _cMsgErro
	_oRet:Sucesso      := .F.

   Break

Return()