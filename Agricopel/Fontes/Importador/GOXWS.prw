#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://gdewsvc.azurewebsites.net/GDeWSVC.svc?wsdl
Gerado em        06/02/20 16:24:23
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OOTJSMU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSGDeWService
------------------------------------------------------------------------------- */

WSCLIENT WSGDeWService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD RequestXML
	WSMETHOD RequestNFSeXML
	WSMETHOD RequestPendentes
	WSMETHOD RequestPendentesNFSe
	WSMETHOD UpdateCustom
	WSMETHOD UpdateCustomEmit

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cchave                    AS string
	WSDATA   cRequestXMLResult         AS string
	WSDATA   oWSRequestNFSeXMLResult   AS GDeWService_NFSeProvedor
	WSDATA   clogin                    AS string
	WSDATA   csenha                    AS string
	WSDATA   ccnpj                     AS string
	WSDATA   cstatusdoc                AS string
	WSDATA   oWSRequestPendentesResult AS GDeWService_ArrayOfPendentes
	WSDATA   oWSRequestPendentesNFSeResult AS GDeWService_ArrayOfPendentesNFSe
	WSDATA   cconteudo                 AS string
	WSDATA   nnCustom                  AS int
	WSDATA   cUpdateCustomResult       AS string
	WSDATA   cUpdateCustomEmitResult   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSGDeWService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20200331] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSGDeWService
	::oWSRequestNFSeXMLResult := GDeWService_NFSEPROVEDOR():New()
	::oWSRequestPendentesResult := GDeWService_ARRAYOFPENDENTES():New()
	::oWSRequestPendentesNFSeResult := GDeWService_ARRAYOFPENDENTESNFSE():New()
Return

WSMETHOD RESET WSCLIENT WSGDeWService
	::cchave             := NIL 
	::cRequestXMLResult  := NIL 
	::oWSRequestNFSeXMLResult := NIL 
	::clogin             := NIL 
	::csenha             := NIL 
	::ccnpj              := NIL 
	::cstatusdoc         := NIL 
	::oWSRequestPendentesResult := NIL 
	::oWSRequestPendentesNFSeResult := NIL 
	::cconteudo          := NIL 
	::nnCustom           := NIL 
	::cUpdateCustomResult := NIL 
	::cUpdateCustomEmitResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSGDeWService
Local oClone := WSGDeWService():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:cchave        := ::cchave
	oClone:cRequestXMLResult := ::cRequestXMLResult
	oClone:oWSRequestNFSeXMLResult :=  IIF(::oWSRequestNFSeXMLResult = NIL , NIL ,::oWSRequestNFSeXMLResult:Clone() )
	oClone:clogin        := ::clogin
	oClone:csenha        := ::csenha
	oClone:ccnpj         := ::ccnpj
	oClone:cstatusdoc    := ::cstatusdoc
	oClone:oWSRequestPendentesResult :=  IIF(::oWSRequestPendentesResult = NIL , NIL ,::oWSRequestPendentesResult:Clone() )
	oClone:oWSRequestPendentesNFSeResult :=  IIF(::oWSRequestPendentesNFSeResult = NIL , NIL ,::oWSRequestPendentesNFSeResult:Clone() )
	oClone:cconteudo     := ::cconteudo
	oClone:nnCustom      := ::nnCustom
	oClone:cUpdateCustomResult := ::cUpdateCustomResult
	oClone:cUpdateCustomEmitResult := ::cUpdateCustomEmitResult
Return oClone

// WSDL Method RequestXML of Service WSGDeWService

WSMETHOD RequestXML WSSEND cchave WSRECEIVE cRequestXMLResult WSCLIENT WSGDeWService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RequestXML xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RequestXML>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/GDeWSVC/RequestXML",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://gdewsvc.azurewebsites.net/GDeWSVC.svc")

::Init()
::cRequestXMLResult  :=  WSAdvValue( oXmlRet,"_REQUESTXMLRESPONSE:_REQUESTXMLRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RequestNFSeXML of Service WSGDeWService

WSMETHOD RequestNFSeXML WSSEND cchave WSRECEIVE oWSRequestNFSeXMLResult WSCLIENT WSGDeWService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RequestNFSeXML xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RequestNFSeXML>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/GDeWSVC/RequestNFSeXML",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://gdewsvc.azurewebsites.net/GDeWSVC.svc")

::Init()
::oWSRequestNFSeXMLResult:SoapRecv( WSAdvValue( oXmlRet,"_REQUESTNFSEXMLRESPONSE:_REQUESTNFSEXMLRESULT","NFSeProvedor",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RequestPendentes of Service WSGDeWService

WSMETHOD RequestPendentes WSSEND clogin,csenha,ccnpj,cstatusdoc WSRECEIVE oWSRequestPendentesResult WSCLIENT WSGDeWService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RequestPendentes xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("statusdoc", ::cstatusdoc, cstatusdoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RequestPendentes>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/GDeWSVC/RequestPendentes",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://gdewsvc.azurewebsites.net/GDeWSVC.svc")

::Init()
::oWSRequestPendentesResult:SoapRecv( WSAdvValue( oXmlRet,"_REQUESTPENDENTESRESPONSE:_REQUESTPENDENTESRESULT","ArrayOfPendentes",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RequestPendentesNFSe of Service WSGDeWService

WSMETHOD RequestPendentesNFSe WSSEND clogin,csenha,ccnpj,cstatusdoc WSRECEIVE oWSRequestPendentesNFSeResult WSCLIENT WSGDeWService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RequestPendentesNFSe xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("statusdoc", ::cstatusdoc, cstatusdoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RequestPendentesNFSe>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/GDeWSVC/RequestPendentesNFSe",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://gdewsvc.azurewebsites.net/GDeWSVC.svc")

::Init()
::oWSRequestPendentesNFSeResult:SoapRecv( WSAdvValue( oXmlRet,"_REQUESTPENDENTESNFSERESPONSE:_REQUESTPENDENTESNFSERESULT","ArrayOfPendentesNFSe",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method UpdateCustom of Service WSGDeWService

WSMETHOD UpdateCustom WSSEND clogin,csenha,ccnpj,cchave,cconteudo,nnCustom WSRECEIVE cUpdateCustomResult WSCLIENT WSGDeWService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UpdateCustom xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("conteudo", ::cconteudo, cconteudo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nCustom", ::nnCustom, nnCustom , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</UpdateCustom>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/GDeWSVC/UpdateCustom",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://gdewsvc.azurewebsites.net/GDeWSVC.svc")

::Init()
::cUpdateCustomResult :=  WSAdvValue( oXmlRet,"_UPDATECUSTOMRESPONSE:_UPDATECUSTOMRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method UpdateCustomEmit of Service WSGDeWService

WSMETHOD UpdateCustomEmit WSSEND clogin,csenha,ccnpj,cchave,cconteudo,nnCustom WSRECEIVE cUpdateCustomEmitResult WSCLIENT WSGDeWService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UpdateCustomEmit xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("conteudo", ::cconteudo, cconteudo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nCustom", ::nnCustom, nnCustom , "int", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</UpdateCustomEmit>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/GDeWSVC/UpdateCustomEmit",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://gdewsvc.azurewebsites.net/GDeWSVC.svc")

::Init()
::cUpdateCustomEmitResult :=  WSAdvValue( oXmlRet,"_UPDATECUSTOMEMITRESPONSE:_UPDATECUSTOMEMITRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure NFSeProvedor

WSSTRUCT GDeWService_NFSeProvedor
	WSDATA   cdocumento                AS string OPTIONAL
	WSDATA   cprovedor                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GDeWService_NFSeProvedor
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GDeWService_NFSeProvedor
Return

WSMETHOD CLONE WSCLIENT GDeWService_NFSeProvedor
	Local oClone := GDeWService_NFSeProvedor():NEW()
	oClone:cdocumento           := ::cdocumento
	oClone:cprovedor            := ::cprovedor
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GDeWService_NFSeProvedor
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprovedor          :=  WSAdvValue( oResponse,"_PROVEDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfPendentes

WSSTRUCT GDeWService_ArrayOfPendentes
	WSDATA   oWSPendentes              AS GDeWService_Pendentes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GDeWService_ArrayOfPendentes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GDeWService_ArrayOfPendentes
	::oWSPendentes         := {} // Array Of  GDeWService_PENDENTES():New()
Return

WSMETHOD CLONE WSCLIENT GDeWService_ArrayOfPendentes
	Local oClone := GDeWService_ArrayOfPendentes():NEW()
	oClone:oWSPendentes := NIL
	If ::oWSPendentes <> NIL 
		oClone:oWSPendentes := {}
		aEval( ::oWSPendentes , { |x| aadd( oClone:oWSPendentes , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GDeWService_ArrayOfPendentes
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PENDENTES","Pendentes",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPendentes , GDeWService_Pendentes():New() )
			::oWSPendentes[len(::oWSPendentes)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfPendentesNFSe

WSSTRUCT GDeWService_ArrayOfPendentesNFSe
	WSDATA   oWSPendentesNFSe          AS GDeWService_PendentesNFSe OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GDeWService_ArrayOfPendentesNFSe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GDeWService_ArrayOfPendentesNFSe
	::oWSPendentesNFSe     := {} // Array Of  GDeWService_PENDENTESNFSE():New()
Return

WSMETHOD CLONE WSCLIENT GDeWService_ArrayOfPendentesNFSe
	Local oClone := GDeWService_ArrayOfPendentesNFSe():NEW()
	oClone:oWSPendentesNFSe := NIL
	If ::oWSPendentesNFSe <> NIL 
		oClone:oWSPendentesNFSe := {}
		aEval( ::oWSPendentesNFSe , { |x| aadd( oClone:oWSPendentesNFSe , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GDeWService_ArrayOfPendentesNFSe
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PENDENTESNFSE","PendentesNFSe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPendentesNFSe , GDeWService_PendentesNFSe():New() )
			::oWSPendentesNFSe[len(::oWSPendentesNFSe)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Pendentes

WSSTRUCT GDeWService_Pendentes
	WSDATA   cchave                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GDeWService_Pendentes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GDeWService_Pendentes
Return

WSMETHOD CLONE WSCLIENT GDeWService_Pendentes
	Local oClone := GDeWService_Pendentes():NEW()
	oClone:cchave               := ::cchave
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GDeWService_Pendentes
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cchave             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PendentesNFSe

WSSTRUCT GDeWService_PendentesNFSe
	WSDATA   cchave                    AS string OPTIONAL
	WSDATA   cprovedor                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GDeWService_PendentesNFSe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GDeWService_PendentesNFSe
Return

WSMETHOD CLONE WSCLIENT GDeWService_PendentesNFSe
	Local oClone := GDeWService_PendentesNFSe():NEW()
	oClone:cchave               := ::cchave
	oClone:cprovedor            := ::cprovedor
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GDeWService_PendentesNFSe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cchave             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprovedor          :=  WSAdvValue( oResponse,"_PROVEDOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return
