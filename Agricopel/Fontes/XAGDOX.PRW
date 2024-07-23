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

    Local _cJson := ""
    Local _cRet  := ""

   // _cJson += '{ '
   // _cJson += '    "rotina": "XAGDOX01",'  
   // _cJson += '	   "cnpjClientePedido": "81632093000764", '
   // _cJson += '    "obsNotaFiscal": "Teste Leandro TI", '
   // _cJson += '	   "itens": [{"codProduto": "302635","qtdePedido": 1}] '
   // _cJson += '} '

   //_cJson += '{ '
   //_cJson += '   "rotina": "XAGDOX02",'
   //_cJson += '  "cnpjEmpresaTitulo": "81632093001655",'
   //_cJson += '  "cnpjCpfParaReembolso": "67318193953", '
   //_cJson += '  "observacao": "Processo DOX Nr: 430780", '
   //_cJson += '  "centroCusto": "5100", '
   //_cJson += '  "tipo": "ADTO", '
   //_cJson += '  "valor": "45" '
   //_cJson += '}'

   
    /*_cJson += '{ '
    _cJson += '    "rotina": "XAGDOX04",'
    _cJson += '	 "empFil": "0103", '
    _cJson += '	 "documento": "051458", '
    _cJson += '	 "serie": "1", '
    _cJson += '	 "tipo": "CANCDOC" '//EXCPEDIDO 
    _cJson += '} '*/

    _cJson += '{ '
    _cJson += '    "rotina": "XAGDOX04",'
    _cJson += '	 "empFil": "0103", '
    _cJson += '	 "pedido": "419573" ,'
    _cJson += '	 "tipo": "EXCPEDIDO" '//EXCPEDIDO 
    _cJson += '} '
    // {"rotina": "XAGDOX04", "empFil": "0103", "pedido": "419573", "tipo": "EXCPEDIDO" }
   
    /*_cJson += '{ '
    _cJson += '    "rotina": "XAGDOX05",'
    _cJson += '	 "empFil": "0103", '
    _cJson += '	 "documento": "378214", '
    _cJson += '	 "serie": "3", '
    _cJson += '	 "chave": "42210981632093000411550030003782141100185818" '
    _cJson += '} '
   */
   /*_cJson += '{ '
    _cJson += '    "rotina": "XAGDOX06",'
    _cJson += '	 "empFil": "0103", '
    _cJson += '	 "centrocusto": "5100", '
    _cJson += '	 "valor": "300.11", '
    _cJson += '	 "quant_parcelas": "3", '
    _cJson += '	 "dt_parcela": "20211010", '
    _cJson += '	 "processo": "405981", '
    _cJson += '	 "cnpjCpf": "05471054954", '
    _cJson += '	 "tipo": "M" '//EXCPEDIDO 
    _cJson += '} '
 */
   /*Private _cCC	    := _oJsonDOX:GetJsonText("centrocusto")
   Private _cTipo 	    := _oJsonDOX:GetJsonText("tipo") // 'M' / 'A' 
   Private _nValor     := Val(__oJsonDOX:GetJsonText("valor"))
   Private _nQtdParc   := Val(_oJsonDOX:GetJsonText("quant_parcelas"))
   Private _cDataParc  := _oJsonDOX:GetJsonText("dt_parcela")
   Private _cProcesso  := _oJsonDOX:GetJsonText("processo")
   Private _cCnpjCli  := _oJsonDOX:GetJsonText("cnpjCpf")*/

    _cRet := ProcReq(_cJson)

    MsgInfo(_cRet)

    

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
   Local _cRetJson  := ""

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
   _oRetJson["observacao"]   := _oRet:observacao
   _oRetJson["arrayRet"]   := _oRet:arrayRet
	_oRetJson["sucesso"]      := If(_oRet:sucesso, .T., .F.)

   _cRet := _oRetJson:toJSON()
   FreeObj(_oRetJson)

Return(_cRet)

Class DOXWsRetorno

Data sucesso as Boolean
Data msgSucesso as String
Data observacao as String
Data errorCode as String
Data errorMessage as String
Data arrayRet   as JsonObject


Method New() Constructor

EndClass

Method New() Class DOXWsRetorno

   ::sucesso      := .F.
   ::msgSucesso   := ""
   ::observacao   := ""
	::errorCode    := ""
	::errorMessage := ""
   ::arrayRet     := {}

Return(Self)

Static Function LogErroIni(oError)

   Local _cMsgErro := oError:ErrorStack
   Default _oRet := DOXWsRetorno():New()

	_oRet:errorMessage += _cMsgErro
	_oRet:Sucesso      := .F.

   Break

Return()
