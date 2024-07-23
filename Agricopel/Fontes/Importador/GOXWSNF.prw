#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://brgde.brproj.com.br/Urbano.svc?singleWsdl
Gerado em        02/18/19 14:35:41
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _MSPNHEO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSUrbano
------------------------------------------------------------------------------- */

WSCLIENT WSUrbano

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ListaDocumentos
	WSMETHOD ConsultaManifEmit

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   clogin                    AS string
	WSDATA   csenha                    AS string
	WSDATA   ccnpj                     AS string
	WSDATA   cdataEmissao              AS string
	WSDATA   cTipoDoc                  AS string
	WSDATA   oWSListaDocumentosResult  AS Urbano_ArrayOfDocumentos
	WSDATA   cchave                    AS string
	WSDATA   cConsultaManifEmitResult  AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSUrbano
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSUrbano
	::oWSListaDocumentosResult := Urbano_ARRAYOFDOCUMENTOS():New()
Return

WSMETHOD RESET WSCLIENT WSUrbano
	::clogin             := NIL 
	::csenha             := NIL 
	::ccnpj              := NIL 
	::cdataEmissao       := NIL 
	::cTipoDoc           := NIL 
	::oWSListaDocumentosResult := NIL 
	::cchave             := NIL 
	::cConsultaManifEmitResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSUrbano
Local oClone := WSUrbano():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:clogin        := ::clogin
	oClone:csenha        := ::csenha
	oClone:ccnpj         := ::ccnpj
	oClone:cdataEmissao  := ::cdataEmissao
	oClone:cTipoDoc      := ::cTipoDoc
	oClone:oWSListaDocumentosResult :=  IIF(::oWSListaDocumentosResult = NIL , NIL ,::oWSListaDocumentosResult:Clone() )
	oClone:cchave        := ::cchave
	oClone:cConsultaManifEmitResult := ::cConsultaManifEmitResult
Return oClone

// WSDL Method ListaDocumentos of Service WSUrbano

WSMETHOD ListaDocumentos WSSEND clogin,csenha,ccnpj,cdataEmissao,cTipoDoc WSRECEIVE oWSListaDocumentosResult WSCLIENT WSUrbano
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListaDocumentos xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataEmissao", ::cdataEmissao, cdataEmissao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TipoDoc", ::cTipoDoc, cTipoDoc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListaDocumentos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IUrbano/ListaDocumentos",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://brgde.brproj.com.br/Urbano.svc")

::Init()
::oWSListaDocumentosResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTADOCUMENTOSRESPONSE:_LISTADOCUMENTOSRESULT","ArrayOfDocumentos",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaManifEmit of Service WSUrbano

WSMETHOD ConsultaManifEmit WSSEND clogin,csenha,ccnpj,cchave WSRECEIVE cConsultaManifEmitResult WSCLIENT WSUrbano
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaManifEmit xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpj", ::ccnpj, ccnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaManifEmit>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IUrbano/ConsultaManifEmit",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://brgde.brproj.com.br/Urbano.svc")

::Init()
::cConsultaManifEmitResult :=  WSAdvValue( oXmlRet,"_CONSULTAMANIFEMITRESPONSE:_CONSULTAMANIFEMITRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfDocumentos

WSSTRUCT Urbano_ArrayOfDocumentos
	WSDATA   oWSDocumentos             AS Urbano_Documentos OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Urbano_ArrayOfDocumentos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Urbano_ArrayOfDocumentos
	::oWSDocumentos        := {} // Array Of  Urbano_DOCUMENTOS():New()
Return

WSMETHOD CLONE WSCLIENT Urbano_ArrayOfDocumentos
	Local oClone := Urbano_ArrayOfDocumentos():NEW()
	oClone:oWSDocumentos := NIL
	If ::oWSDocumentos <> NIL 
		oClone:oWSDocumentos := {}
		aEval( ::oWSDocumentos , { |x| aadd( oClone:oWSDocumentos , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Urbano_ArrayOfDocumentos
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DOCUMENTOS","Documentos",{},NIL,.T.,"O",NIL,"xs") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDocumentos , Urbano_Documentos():New() )
			::oWSDocumentos[len(::oWSDocumentos)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Documentos

WSSTRUCT Urbano_Documentos
	WSDATA   cAutorizacao              AS string OPTIONAL
	WSDATA   cChave                    AS string OPTIONAL
	WSDATA   cEmitente                 AS string OPTIONAL
	WSDATA   cIntegracao               AS string OPTIONAL
	WSDATA   cManifestacao             AS string OPTIONAL
	WSDATA   cNumero                   AS string OPTIONAL
	WSDATA   cSerie                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Urbano_Documentos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Urbano_Documentos
Return

WSMETHOD CLONE WSCLIENT Urbano_Documentos
	Local oClone := Urbano_Documentos():NEW()
	oClone:cAutorizacao         := ::cAutorizacao
	oClone:cChave               := ::cChave
	oClone:cEmitente            := ::cEmitente
	oClone:cIntegracao          := ::cIntegracao
	oClone:cManifestacao        := ::cManifestacao
	oClone:cNumero              := ::cNumero
	oClone:cSerie               := ::cSerie
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Urbano_Documentos
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAutorizacao       :=  WSAdvValue( oResponse,"_AUTORIZACAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cChave             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cEmitente          :=  WSAdvValue( oResponse,"_EMITENTE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cIntegracao        :=  WSAdvValue( oResponse,"_INTEGRACAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cManifestacao      :=  WSAdvValue( oResponse,"_MANIFESTACAO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cNumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cSerie             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return
