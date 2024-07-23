#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx?wsdl
Gerado em        02/22/18 14:13:55
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _UAMPLEN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSwsgestordecisao
------------------------------------------------------------------------------- */

WSCLIENT WSwsgestordecisao

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ReceberSiemens
	WSMETHOD AnalisarCreditoS
	WSMETHOD AnalisarCreditoTeste
	WSMETHOD AnalisarCredito
	WSMETHOD AnalisarCreditoRelatorio
	WSMETHOD AnalisarCreditoRelatorioCoAdquirente
	WSMETHOD AnalisarCreditoCheque
	WSMETHOD AnalisarCreditoW
	WSMETHOD GestorCreditoStatusWorkFlow
	WSMETHOD AnalisarCreditoXML
	WSMETHOD AnalisarLote
	WSMETHOD RetornoLote
	WSMETHOD AnalisarCreditoDLL
	WSMETHOD BuscaRelatorioDLL
	WSMETHOD BuscaPolParametro
	WSMETHOD AnalisarMobile
	WSMETHOD AnalisarCrivo

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   csXML                     AS string
	WSDATA   cReceberSiemensResult     AS string
	WSDATA   csCNPJ                    AS string
	WSDATA   csUsrGC                   AS string
	WSDATA   csPassGC                  AS string
	WSDATA   csUsrSer                  AS string
	WSDATA   csPassSer                 AS string
	WSDATA   csDoc                     AS string
	WSDATA   nVrCompra                 AS double
	WSDATA   csScore                   AS string
	WSDATA   lbSerasa                  AS boolean
	WSDATA   lbAtualizar               AS boolean
	WSDATA   csOnLine                  AS string
	WSDATA   csSociosCNPJ              AS string
	WSDATA   csSociosCPF               AS string
	WSDATA   csIdSocios                AS string
	WSDATA   niQuadroSocial            AS int
	WSDATA   cAnalisarCreditoSResult   AS string
	WSDATA   cAnalisarCreditoTesteResult AS string
	WSDATA   cAnalisarCreditoResult    AS string
	WSDATA   oWSAnalisarCreditoRelatorioResult AS wsgestordecisao_AnalisarCreditoRelatorioRetorno
	WSDATA   cCoAdquirenteCPF1         AS string
	WSDATA   cCoAdquirenteScore1       AS string
	WSDATA   cCoAdquirenteCPF2         AS string
	WSDATA   cCoAdquirenteScore2       AS string
	WSDATA   cCoAdquirenteCPF3         AS string
	WSDATA   cCoAdquirenteScore3       AS string
	WSDATA   cCoAdquirenteCPF4         AS string
	WSDATA   cCoAdquirenteScore4       AS string
	WSDATA   cCoAdquirenteCPF5         AS string
	WSDATA   cCoAdquirenteScore5       AS string
	WSDATA   oWSAnalisarCreditoRelatorioCoAdquirenteResult AS wsgestordecisao_AnalisarCreditoRelatorioRetorno
	WSDATA   csCheque                  AS string
	WSDATA   cAnalisarCreditoChequeResult AS string
	WSDATA   cAnalisarCreditoWResult   AS string
	WSDATA   nControleWF               AS long
	WSDATA   cGestorCreditoStatusWorkFlowResult AS string
	WSDATA   cXMLEnvio                 AS string
	WSDATA   cAnalisarCreditoXMLResult AS string
	WSDATA   cAnalisarLoteResult       AS string
	WSDATA   cCNPJ                     AS string
	WSDATA   cChaveArquivo             AS string
	WSDATA   cRetornoLoteResult        AS string
	WSDATA   cAnalisarCreditoDLLResult AS string
	WSDATA   cCIF                      AS string
	WSDATA   cDoc                      AS string
	WSDATA   cBuscaRelatorioDLLResult  AS string
	WSDATA   cUsuarioGestor            AS string
	WSDATA   cSenhaGestor              AS string
	WSDATA   cUsuarioSerasa            AS string
	WSDATA   cSenhaSerasa              AS string
	WSDATA   cBuscaPolParametroResult  AS string
	WSDATA   cTipoDoc                  AS string
	WSDATA   cDocConsultado            AS string
	WSDATA   nValorCompra              AS int
	WSDATA   cDadoOnline               AS string
	WSDATA   cAnalisarMobileResult     AS string
	WSDATA   cAnalisarCrivoResult      AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSwsgestordecisao
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20171213 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSwsgestordecisao
	::oWSAnalisarCreditoRelatorioResult := wsgestordecisao_ANALISARCREDITORELATORIORETORNO():New()
	::oWSAnalisarCreditoRelatorioCoAdquirenteResult := wsgestordecisao_ANALISARCREDITORELATORIORETORNO():New()
Return

WSMETHOD RESET WSCLIENT WSwsgestordecisao
	::csXML              := NIL 
	::cReceberSiemensResult := NIL 
	::csCNPJ             := NIL 
	::csUsrGC            := NIL 
	::csPassGC           := NIL 
	::csUsrSer           := NIL 
	::csPassSer          := NIL 
	::csDoc              := NIL 
	::nVrCompra          := NIL 
	::csScore            := NIL 
	::lbSerasa           := NIL 
	::lbAtualizar        := NIL 
	::csOnLine           := NIL 
	::csSociosCNPJ       := NIL 
	::csSociosCPF        := NIL 
	::csIdSocios         := NIL 
	::niQuadroSocial     := NIL 
	::cAnalisarCreditoSResult := NIL 
	::cAnalisarCreditoTesteResult := NIL 
	::cAnalisarCreditoResult := NIL 
	::oWSAnalisarCreditoRelatorioResult := NIL 
	::cCoAdquirenteCPF1  := NIL 
	::cCoAdquirenteScore1 := NIL 
	::cCoAdquirenteCPF2  := NIL 
	::cCoAdquirenteScore2 := NIL 
	::cCoAdquirenteCPF3  := NIL 
	::cCoAdquirenteScore3 := NIL 
	::cCoAdquirenteCPF4  := NIL 
	::cCoAdquirenteScore4 := NIL 
	::cCoAdquirenteCPF5  := NIL 
	::cCoAdquirenteScore5 := NIL 
	::oWSAnalisarCreditoRelatorioCoAdquirenteResult := NIL 
	::csCheque           := NIL 
	::cAnalisarCreditoChequeResult := NIL 
	::cAnalisarCreditoWResult := NIL 
	::nControleWF        := NIL 
	::cGestorCreditoStatusWorkFlowResult := NIL 
	::cXMLEnvio          := NIL 
	::cAnalisarCreditoXMLResult := NIL 
	::cAnalisarLoteResult := NIL 
	::cCNPJ              := NIL 
	::cChaveArquivo      := NIL 
	::cRetornoLoteResult := NIL 
	::cAnalisarCreditoDLLResult := NIL 
	::cCIF               := NIL 
	::cDoc               := NIL 
	::cBuscaRelatorioDLLResult := NIL 
	::cUsuarioGestor     := NIL 
	::cSenhaGestor       := NIL 
	::cUsuarioSerasa     := NIL 
	::cSenhaSerasa       := NIL 
	::cBuscaPolParametroResult := NIL 
	::cTipoDoc           := NIL 
	::cDocConsultado     := NIL 
	::nValorCompra       := NIL 
	::cDadoOnline        := NIL 
	::cAnalisarMobileResult := NIL 
	::cAnalisarCrivoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSwsgestordecisao
Local oClone := WSwsgestordecisao():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:csXML         := ::csXML
	oClone:cReceberSiemensResult := ::cReceberSiemensResult
	oClone:csCNPJ        := ::csCNPJ
	oClone:csUsrGC       := ::csUsrGC
	oClone:csPassGC      := ::csPassGC
	oClone:csUsrSer      := ::csUsrSer
	oClone:csPassSer     := ::csPassSer
	oClone:csDoc         := ::csDoc
	oClone:nVrCompra     := ::nVrCompra
	oClone:csScore       := ::csScore
	oClone:lbSerasa      := ::lbSerasa
	oClone:lbAtualizar   := ::lbAtualizar
	oClone:csOnLine      := ::csOnLine
	oClone:csSociosCNPJ  := ::csSociosCNPJ
	oClone:csSociosCPF   := ::csSociosCPF
	oClone:csIdSocios    := ::csIdSocios
	oClone:niQuadroSocial := ::niQuadroSocial
	oClone:cAnalisarCreditoSResult := ::cAnalisarCreditoSResult
	oClone:cAnalisarCreditoTesteResult := ::cAnalisarCreditoTesteResult
	oClone:cAnalisarCreditoResult := ::cAnalisarCreditoResult
	oClone:oWSAnalisarCreditoRelatorioResult :=  IIF(::oWSAnalisarCreditoRelatorioResult = NIL , NIL ,::oWSAnalisarCreditoRelatorioResult:Clone() )
	oClone:cCoAdquirenteCPF1 := ::cCoAdquirenteCPF1
	oClone:cCoAdquirenteScore1 := ::cCoAdquirenteScore1
	oClone:cCoAdquirenteCPF2 := ::cCoAdquirenteCPF2
	oClone:cCoAdquirenteScore2 := ::cCoAdquirenteScore2
	oClone:cCoAdquirenteCPF3 := ::cCoAdquirenteCPF3
	oClone:cCoAdquirenteScore3 := ::cCoAdquirenteScore3
	oClone:cCoAdquirenteCPF4 := ::cCoAdquirenteCPF4
	oClone:cCoAdquirenteScore4 := ::cCoAdquirenteScore4
	oClone:cCoAdquirenteCPF5 := ::cCoAdquirenteCPF5
	oClone:cCoAdquirenteScore5 := ::cCoAdquirenteScore5
	oClone:oWSAnalisarCreditoRelatorioCoAdquirenteResult :=  IIF(::oWSAnalisarCreditoRelatorioCoAdquirenteResult = NIL , NIL ,::oWSAnalisarCreditoRelatorioCoAdquirenteResult:Clone() )
	oClone:csCheque      := ::csCheque
	oClone:cAnalisarCreditoChequeResult := ::cAnalisarCreditoChequeResult
	oClone:cAnalisarCreditoWResult := ::cAnalisarCreditoWResult
	oClone:nControleWF   := ::nControleWF
	oClone:cGestorCreditoStatusWorkFlowResult := ::cGestorCreditoStatusWorkFlowResult
	oClone:cXMLEnvio     := ::cXMLEnvio
	oClone:cAnalisarCreditoXMLResult := ::cAnalisarCreditoXMLResult
	oClone:cAnalisarLoteResult := ::cAnalisarLoteResult
	oClone:cCNPJ         := ::cCNPJ
	oClone:cChaveArquivo := ::cChaveArquivo
	oClone:cRetornoLoteResult := ::cRetornoLoteResult
	oClone:cAnalisarCreditoDLLResult := ::cAnalisarCreditoDLLResult
	oClone:cCIF          := ::cCIF
	oClone:cDoc          := ::cDoc
	oClone:cBuscaRelatorioDLLResult := ::cBuscaRelatorioDLLResult
	oClone:cUsuarioGestor := ::cUsuarioGestor
	oClone:cSenhaGestor  := ::cSenhaGestor
	oClone:cUsuarioSerasa := ::cUsuarioSerasa
	oClone:cSenhaSerasa  := ::cSenhaSerasa
	oClone:cBuscaPolParametroResult := ::cBuscaPolParametroResult
	oClone:cTipoDoc      := ::cTipoDoc
	oClone:cDocConsultado := ::cDocConsultado
	oClone:nValorCompra  := ::nValorCompra
	oClone:cDadoOnline   := ::cDadoOnline
	oClone:cAnalisarMobileResult := ::cAnalisarMobileResult
	oClone:cAnalisarCrivoResult := ::cAnalisarCrivoResult
Return oClone

// WSDL Method ReceberSiemens of Service WSwsgestordecisao

WSMETHOD ReceberSiemens WSSEND csXML WSRECEIVE cReceberSiemensResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReceberSiemens xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sXML", ::csXML, csXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReceberSiemens>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/ReceberSiemens",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cReceberSiemensResult :=  WSAdvValue( oXmlRet,"_RECEBERSIEMENSRESPONSE:_RECEBERSIEMENSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoS of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoS WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine,csSociosCNPJ,csSociosCPF,csIdSocios,niQuadroSocial WSRECEIVE cAnalisarCreditoSResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoS xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::nVrCompra, nVrCompra , "double", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sSociosCNPJ", ::csSociosCNPJ, csSociosCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sSociosCPF", ::csSociosCPF, csSociosCPF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sIdSocios", ::csIdSocios, csIdSocios , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("iQuadroSocial", ::niQuadroSocial, niQuadroSocial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoS",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCreditoSResult :=  WSAdvValue( oXmlRet,"_ANALISARCREDITOSRESPONSE:_ANALISARCREDITOSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoTeste of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoTeste WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine WSRECEIVE cAnalisarCreditoTesteResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoTeste xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::nVrCompra, nVrCompra , "double", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoTeste>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoTeste",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCreditoTesteResult :=  WSAdvValue( oXmlRet,"_ANALISARCREDITOTESTERESPONSE:_ANALISARCREDITOTESTERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCredito of Service WSwsgestordecisao

WSMETHOD AnalisarCredito WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine WSRECEIVE cAnalisarCreditoResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCredito xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::nVrCompra, nVrCompra , "double", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCredito>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCredito",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCreditoResult :=  WSAdvValue( oXmlRet,"_ANALISARCREDITORESPONSE:_ANALISARCREDITORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoRelatorio of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoRelatorio WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine WSRECEIVE oWSAnalisarCreditoRelatorioResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoRelatorio xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::nVrCompra, nVrCompra , "double", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoRelatorio>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoRelatorio",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::oWSAnalisarCreditoRelatorioResult:SoapRecv( WSAdvValue( oXmlRet,"_ANALISARCREDITORELATORIORESPONSE:_ANALISARCREDITORELATORIORESULT","AnalisarCreditoRelatorioRetorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoRelatorioCoAdquirente of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoRelatorioCoAdquirente WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,cVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine,cCoAdquirenteCPF1,cCoAdquirenteScore1,cCoAdquirenteCPF2,cCoAdquirenteScore2,cCoAdquirenteCPF3,cCoAdquirenteScore3,cCoAdquirenteCPF4,cCoAdquirenteScore4,cCoAdquirenteCPF5,cCoAdquirenteScore5 WSRECEIVE oWSAnalisarCreditoRelatorioCoAdquirenteResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoRelatorioCoAdquirente xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::cVrCompra, cVrCompra , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteCPF1", ::cCoAdquirenteCPF1, cCoAdquirenteCPF1 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteScore1", ::cCoAdquirenteScore1, cCoAdquirenteScore1 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteCPF2", ::cCoAdquirenteCPF2, cCoAdquirenteCPF2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteScore2", ::cCoAdquirenteScore2, cCoAdquirenteScore2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteCPF3", ::cCoAdquirenteCPF3, cCoAdquirenteCPF3 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteScore3", ::cCoAdquirenteScore3, cCoAdquirenteScore3 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteCPF4", ::cCoAdquirenteCPF4, cCoAdquirenteCPF4 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteScore4", ::cCoAdquirenteScore4, cCoAdquirenteScore4 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteCPF5", ::cCoAdquirenteCPF5, cCoAdquirenteCPF5 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CoAdquirenteScore5", ::cCoAdquirenteScore5, cCoAdquirenteScore5 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoRelatorioCoAdquirente>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoRelatorioCoAdquirente",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::oWSAnalisarCreditoRelatorioCoAdquirenteResult:SoapRecv( WSAdvValue( oXmlRet,"_ANALISARCREDITORELATORIOCOADQUIRENTERESPONSE:_ANALISARCREDITORELATORIOCOADQUIRENTERESULT","AnalisarCreditoRelatorioRetorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoCheque of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoCheque WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine,csCheque WSRECEIVE cAnalisarCreditoChequeResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoCheque xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::nVrCompra, nVrCompra , "double", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sCheque", ::csCheque, csCheque , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoCheque>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoCheque",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCreditoChequeResult :=  WSAdvValue( oXmlRet,"_ANALISARCREDITOCHEQUERESPONSE:_ANALISARCREDITOCHEQUERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoW of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoW WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine WSRECEIVE cAnalisarCreditoWResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoW xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::nVrCompra, nVrCompra , "double", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoW>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoW",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCreditoWResult :=  WSAdvValue( oXmlRet,"_ANALISARCREDITOWRESPONSE:_ANALISARCREDITOWRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GestorCreditoStatusWorkFlow of Service WSwsgestordecisao

WSMETHOD GestorCreditoStatusWorkFlow WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,nControleWF WSRECEIVE cGestorCreditoStatusWorkFlowResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GestorCreditoStatusWorkFlow xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ControleWF", ::nControleWF, nControleWF , "long", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GestorCreditoStatusWorkFlow>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/GestorCreditoStatusWorkFlow",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cGestorCreditoStatusWorkFlowResult :=  WSAdvValue( oXmlRet,"_GESTORCREDITOSTATUSWORKFLOWRESPONSE:_GESTORCREDITOSTATUSWORKFLOWRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoXML of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoXML WSSEND cXMLEnvio WSRECEIVE cAnalisarCreditoXMLResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoXML xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("XMLEnvio", ::cXMLEnvio, cXMLEnvio , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoXML>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoXML",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCreditoXMLResult :=  WSAdvValue( oXmlRet,"_ANALISARCREDITOXMLRESPONSE:_ANALISARCREDITOXMLRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarLote of Service WSwsgestordecisao

WSMETHOD AnalisarLote WSSEND csXML WSRECEIVE cAnalisarLoteResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarLote xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sXML", ::csXML, csXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarLote>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarLote",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarLoteResult :=  WSAdvValue( oXmlRet,"_ANALISARLOTERESPONSE:_ANALISARLOTERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornoLote of Service WSwsgestordecisao

WSMETHOD RetornoLote WSSEND cCNPJ,cChaveArquivo WSRECEIVE cRetornoLoteResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornoLote xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ChaveArquivo", ::cChaveArquivo, cChaveArquivo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornoLote>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/RetornoLote",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cRetornoLoteResult :=  WSAdvValue( oXmlRet,"_RETORNOLOTERESPONSE:_RETORNOLOTERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCreditoDLL of Service WSwsgestordecisao

WSMETHOD AnalisarCreditoDLL WSSEND csXML WSRECEIVE cAnalisarCreditoDLLResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCreditoDLL xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sXML", ::csXML, csXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCreditoDLL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCreditoDLL",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCreditoDLLResult :=  WSAdvValue( oXmlRet,"_ANALISARCREDITODLLRESPONSE:_ANALISARCREDITODLLRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BuscaRelatorioDLL of Service WSwsgestordecisao

WSMETHOD BuscaRelatorioDLL WSSEND csUsrGC,csPassGC,csUsrSer,csPassSer,cCIF,cDoc WSRECEIVE cBuscaRelatorioDLLResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BuscaRelatorioDLL xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CIF", ::cCIF, cCIF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Doc", ::cDoc, cDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BuscaRelatorioDLL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/BuscaRelatorioDLL",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cBuscaRelatorioDLLResult :=  WSAdvValue( oXmlRet,"_BUSCARELATORIODLLRESPONSE:_BUSCARELATORIODLLRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BuscaPolParametro of Service WSwsgestordecisao

WSMETHOD BuscaPolParametro WSSEND cUsuarioGestor,cSenhaGestor,cUsuarioSerasa,cSenhaSerasa WSRECEIVE cBuscaPolParametroResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BuscaPolParametro xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("UsuarioGestor", ::cUsuarioGestor, cUsuarioGestor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SenhaGestor", ::cSenhaGestor, cSenhaGestor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UsuarioSerasa", ::cUsuarioSerasa, cUsuarioSerasa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SenhaSerasa", ::cSenhaSerasa, cSenhaSerasa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BuscaPolParametro>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/BuscaPolParametro",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cBuscaPolParametroResult :=  WSAdvValue( oXmlRet,"_BUSCAPOLPARAMETRORESPONSE:_BUSCAPOLPARAMETRORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarMobile of Service WSwsgestordecisao

WSMETHOD AnalisarMobile WSSEND cUsuarioGestor,cSenhaGestor,cUsuarioSerasa,cSenhaSerasa,cTipoDoc,cDocConsultado,nValorCompra,cDadoOnline WSRECEIVE cAnalisarMobileResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarMobile xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("UsuarioGestor", ::cUsuarioGestor, cUsuarioGestor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SenhaGestor", ::cSenhaGestor, cSenhaGestor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UsuarioSerasa", ::cUsuarioSerasa, cUsuarioSerasa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SenhaSerasa", ::cSenhaSerasa, cSenhaSerasa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TipoDoc", ::cTipoDoc, cTipoDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DocConsultado", ::cDocConsultado, cDocConsultado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ValorCompra", ::nValorCompra, nValorCompra , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DadoOnline", ::cDadoOnline, cDadoOnline , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarMobile>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarMobile",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarMobileResult :=  WSAdvValue( oXmlRet,"_ANALISARMOBILERESPONSE:_ANALISARMOBILERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AnalisarCrivo of Service WSwsgestordecisao

WSMETHOD AnalisarCrivo WSSEND csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine WSRECEIVE cAnalisarCrivoResult WSCLIENT WSwsgestordecisao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AnalisarCrivo xmlns="https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao">'
cSoap += WSSoapValue("sCNPJ", ::csCNPJ, csCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrGC", ::csUsrGC, csUsrGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassGC", ::csPassGC, csPassGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUsrSer", ::csUsrSer, csUsrSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassSer", ::csPassSer, csPassSer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sDoc", ::csDoc, csDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VrCompra", ::nVrCompra, nVrCompra , "double", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sScore", ::csScore, csScore , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bSerasa", ::lbSerasa, lbSerasa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("bAtualizar", ::lbAtualizar, lbAtualizar , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sOnLine", ::csOnLine, csOnLine , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AnalisarCrivo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao/AnalisarCrivo",; 
	"DOCUMENT","https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao",,,; 
	"https://sitenet05.serasa.com.br/wsgestordecisao/wsgestordecisao.asmx")

::Init()
::cAnalisarCrivoResult :=  WSAdvValue( oXmlRet,"_ANALISARCRIVORESPONSE:_ANALISARCRIVORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AnalisarCreditoRelatorioRetorno

WSSTRUCT wsgestordecisao_AnalisarCreditoRelatorioRetorno
	WSDATA   cResultadoAnalise         AS string OPTIONAL
	WSDATA   lTemRelatorio             AS boolean
	WSDATA   cRelatorio                AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT wsgestordecisao_AnalisarCreditoRelatorioRetorno
	::Init()
Return Self

WSMETHOD INIT WSCLIENT wsgestordecisao_AnalisarCreditoRelatorioRetorno
Return

WSMETHOD CLONE WSCLIENT wsgestordecisao_AnalisarCreditoRelatorioRetorno
	Local oClone := wsgestordecisao_AnalisarCreditoRelatorioRetorno():NEW()
	oClone:cResultadoAnalise    := ::cResultadoAnalise
	oClone:lTemRelatorio        := ::lTemRelatorio
	oClone:cRelatorio           := ::cRelatorio
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT wsgestordecisao_AnalisarCreditoRelatorioRetorno
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cResultadoAnalise  :=  WSAdvValue( oResponse,"_RESULTADOANALISE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lTemRelatorio      :=  WSAdvValue( oResponse,"_TEMRELATORIO","boolean",NIL,"Property lTemRelatorio as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cRelatorio         :=  WSAdvValue( oResponse,"_RELATORIO","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return


