#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://brgde.brproj.com.br/GdeManif.svc?wsdl 
Gerado em        07/13/17 14:05:46
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _BUOSJSS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSGdeManif
------------------------------------------------------------------------------- */

WSCLIENT WSGdeManif

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD PutManifestacao
	WSMETHOD GetManifestacao

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   clogin                    AS string
	WSDATA   csenha                    AS string
	WSDATA   ccnpj                     AS string
	WSDATA   cchave                    AS string
	WSDATA   cManifestacao             AS string
	WSDATA   cJustificativa            AS string
	WSDATA   cPutManifestacaoResult    AS string
	WSDATA   cGetManifestacaoResult    AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSGdeManif
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170213 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSGdeManif
Return

WSMETHOD RESET WSCLIENT WSGdeManif
	::clogin             := NIL 
	::csenha             := NIL 
	::ccnpj              := NIL 
	::cchave             := NIL 
	::cManifestacao      := NIL 
	::cJustificativa     := NIL 
	::cPutManifestacaoResult := NIL 
	::cGetManifestacaoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSGdeManif
Local oClone := WSGdeManif():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:clogin        := ::clogin
	oClone:csenha        := ::csenha
	oClone:ccnpj         := ::ccnpj
	oClone:cchave        := ::cchave
	oClone:cManifestacao := ::cManifestacao
	oClone:cJustificativa := ::cJustificativa
	oClone:cPutManifestacaoResult := ::cPutManifestacaoResult
	oClone:cGetManifestacaoResult := ::cGetManifestacaoResult
Return oClone

// WSDL Method PutManifestacao of Service WSGdeManif

WSMETHOD PutManifestacao WSSEND clogin,csenha,ccnpj,cchave,cManifestacao,cJustificativa WSRECEIVE cPutManifestacaoResult WSCLIENT WSGdeManif
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PutManifestacao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Manifestacao", ::cManifestacao, cManifestacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Justificativa", ::cJustificativa, cJustificativa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PutManifestacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IGdeManif/PutManifestacao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://brgde.brproj.com.br/GdeManif.svc")

::Init()
::cPutManifestacaoResult :=  WSAdvValue( oXmlRet,"_PUTMANIFESTACAORESPONSE:_PUTMANIFESTACAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetManifestacao of Service WSGdeManif

WSMETHOD GetManifestacao WSSEND clogin,csenha,ccnpj,cchave WSRECEIVE cGetManifestacaoResult WSCLIENT WSGdeManif
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetManifestacao xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GetManifestacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IGdeManif/GetManifestacao",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://brgde.brproj.com.br/GdeManif.svc")

::Init()
::cGetManifestacaoResult :=  WSAdvValue( oXmlRet,"_GETMANIFESTACAORESPONSE:_GETMANIFESTACAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.
