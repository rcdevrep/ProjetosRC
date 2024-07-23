#Include 'Protheus.ch'
#Include 'RestFul.CH'
 
/*/{Protheus.doc} XAGDBG
Web Service de integração com DBGINT, DBGINT sempre "chamará" este webservice para acessar as rotinas de integração, com base no parâmetro
rotina do Json do corpo da requisição
@author Leandro Spiller
@since 29/04/2021
@version 1.0
/*/
User Function XAGDBG()

    Local _cJson := ""
    Local _cRet  := ""

    _cJson += '{ '
    _cJson += '   "rotina": "XAGDBG01",'
    _cJson += '	 "data": "20210429", '
    _cJson += '	 "cnpj": "81632093000411", '
    _cJson += '    "obs": "Teste ", '
    _cJson += '	 "pedidos": [{"num_pedido": "302635","num_programacao": "0001","placa": "MFF0000","status": "A","cod_condutor":"0008","nome_condutor": "jose","viagem":"1","itens":[{"item":"01","compartimento":"1","quantidade":"2000"},{"item":"01","compartimento":"2","quantidade":"2000"},{"item":"02","compartimento":"5","quantidade":"5000"}] },{"num_pedido": "302636","num_programacao":"0002","placa": "MFF0001","status": "A" ,"cod_condutor":"0008","nome_condutor": "jose","viagem":"1","itens":[{"item":"01","compartimento":"1","quantidade":"2000"}] }]'
    _cJson += '} '

     u_msgmemo("Json",_cJson,.f.)

    _cRet := ProcReq(_cJson)

    //MsgInfo(_cRet)

Return()

Static Function ProcReq(_cJson)

   Local _oJsonDBG  := Nil
   Local _cRotina   := ""
   Local _cRetJson  := ""

   Private _oRet    := Nil

	bError := ErrorBlock({|oError|LogErroIni(oError)})
	BEGIN SEQUENCE
      _oJsonDBG := JsonObject():new()
      _oJsonDBG:fromJson(_cJson)

      _cRotina := "U_" + _oJsonDBG:GetJsonText("rotina") + "(_oJsonDBG)"
      _oRet := &(_cRotina)
	END SEQUENCE
	ErrorBlock(bError)

   _cRetJson := EncodeUtf8(SerialRet(_oRet))

   FreeObj(_oRet)

Return(_cRetJson)

WSRESTFUL DBG_INTEGRACAO DESCRIPTION "Serviço REST para integração com DBGINT"

WSMETHOD POST DESCRIPTION "Envia dados para serem executados via ExecAuto no Protheus"

END WSRESTFUL
 
WSMETHOD POST WSSERVICE DBG_INTEGRACAO

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
	_oRetJson["sucesso"]      := If(_oRet:sucesso, .T., .F.)

   _cRet := _oRetJson:toJSON()
   FreeObj(_oRetJson)

Return(_cRet)

Class DBGWsRetorno

Data sucesso as Boolean
Data msgSucesso as String
Data errorCode as String
Data errorMessage as String

Method New() Constructor

EndClass

Method New() Class DBGWsRetorno

   ::sucesso      := .F.
   ::msgSucesso   := ""
	::errorCode    := ""
	::errorMessage := ""

Return(Self)

Static Function LogErroIni(oError)

   Local _cMsgErro := oError:ErrorStack
   Default _oRet := DBGWsRetorno():New()

	_oRet:errorMessage += _cMsgErro
	_oRet:Sucesso      := .F.

   Break

Return()
