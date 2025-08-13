#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"


/* ===============================================================================
WSDL Location    http://www.ahgora.com.br/ws/service.php?wsdl
Gerado em        06/09/14 16:52:52
Observações      Código-Fonte gerado por Victor Andrade
=============================================================================== */

User Function _QNPYKOF ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSAhgoraService
------------------------------------------------------------------------------- */

WSCLIENT WSAhgoraService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD obterBatidas
	WSMETHOD obterBatidasReps
	WSMETHOD sincFuncionarios
	WSMETHOD obterResultados

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cempresa                  AS string
	WSDATA   cdatai                    AS string
	WSDATA   cdataf                    AS string
	WSDATA   oWSobterBatidasBatidas    AS AhgoraService_Batidas
	WSDATA   cposicao                  AS string
	WSDATA   oWSobterBatidasRepsBatidas AS AhgoraService_BatidasRepsArray
	WSDATA   oWSsincFuncionariosfuncionarios AS AhgoraService_FuncionariosArray
	WSDATA   oWSsincFuncionariostotais AS AhgoraService_totaisFuncionarios
	WSDATA   cmatricula                AS string
	WSDATA   oWSobterResultadosopcoes  AS AhgoraService_OpcoesArray
	WSDATA   oWSobterResultadosResultados AS AhgoraService_ResultadosArray

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSAhgoraService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSAhgoraService
	::oWSobterBatidasBatidas := AhgoraService_BATIDAS():New()
	::oWSobterBatidasRepsBatidas := AhgoraService_BATIDASREPSARRAY():New()
	::oWSsincFuncionariosfuncionarios := AhgoraService_FUNCIONARIOSARRAY():New()
	::oWSsincFuncionariostotais := AhgoraService_TOTAISFUNCIONARIOS():New()
	::oWSobterResultadosopcoes := AhgoraService_OPCOESARRAY():New()
	::oWSobterResultadosResultados := AhgoraService_RESULTADOSARRAY():New()
Return

WSMETHOD RESET WSCLIENT WSAhgoraService
	::cempresa           := NIL 
	::cdatai             := NIL 
	::cdataf             := NIL 
	::oWSobterBatidasBatidas := NIL 
	::cposicao           := NIL 
	::oWSobterBatidasRepsBatidas := NIL 
	::oWSsincFuncionariosfuncionarios := NIL 
	::oWSsincFuncionariostotais := NIL 
	::cmatricula         := NIL 
	::oWSobterResultadosopcoes := NIL 
	::oWSobterResultadosResultados := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSAhgoraService
Local oClone := WSAhgoraService():New()
	oClone:_URL          := ::_URL 
	oClone:cempresa      := ::cempresa
	oClone:cdatai        := ::cdatai
	oClone:cdataf        := ::cdataf
	oClone:oWSobterBatidasBatidas :=  IIF(::oWSobterBatidasBatidas = NIL , NIL ,::oWSobterBatidasBatidas:Clone() )
	oClone:cposicao      := ::cposicao
	oClone:oWSobterBatidasRepsBatidas :=  IIF(::oWSobterBatidasRepsBatidas = NIL , NIL ,::oWSobterBatidasRepsBatidas:Clone() )
	oClone:oWSsincFuncionariosfuncionarios :=  IIF(::oWSsincFuncionariosfuncionarios = NIL , NIL ,::oWSsincFuncionariosfuncionarios:Clone() )
	oClone:oWSsincFuncionariostotais :=  IIF(::oWSsincFuncionariostotais = NIL , NIL ,::oWSsincFuncionariostotais:Clone() )
	oClone:cmatricula    := ::cmatricula
	oClone:oWSobterResultadosopcoes :=  IIF(::oWSobterResultadosopcoes = NIL , NIL ,::oWSobterResultadosopcoes:Clone() )
	oClone:oWSobterResultadosResultados :=  IIF(::oWSobterResultadosResultados = NIL , NIL ,::oWSobterResultadosResultados:Clone() )
Return oClone

// WSDL Method obterBatidas of Service WSAhgoraService

WSMETHOD obterBatidas WSSEND cempresa,cdatai,cdataf WSRECEIVE oWSobterBatidasBatidas WSCLIENT WSAhgoraService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterBatidas xmlns:q1="http://www.ahgora.com.br/ws">'
cSoap += WSSoapValue("empresa", ::cempresa, cempresa , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("datai", ::cdatai, cdatai , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("dataf", ::cdataf, cdataf , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterBatidas>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ahgora.com.br/ws/service.php/obterBatidas",; 
	"RPCX","http://www.ahgora.com.br/ws",,,; 
	"http://www.ahgora.com.br/ws/service.php")

::Init()
::oWSobterBatidasBatidas:SoapRecv( WSAdvValue( oXmlRet,"_BATIDAS","Batidas",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterBatidasReps of Service WSAhgoraService

WSMETHOD obterBatidasReps WSSEND cempresa,cposicao WSRECEIVE oWSobterBatidasRepsBatidas WSCLIENT WSAhgoraService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterBatidasReps xmlns:q1="http://www.ahgora.com.br/ws">'
cSoap += WSSoapValue("empresa", ::cempresa, cempresa , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("posicao", ::cposicao, cposicao , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterBatidasReps>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ahgora.com.br/ws/service.php/obterBatidasReps",; 
	"RPCX","http://www.ahgora.com.br/ws",,,; 
	"http://www.ahgora.com.br/ws/service.php")

::Init()
::oWSobterBatidasRepsBatidas:SoapRecv( WSAdvValue( oXmlRet,"_BATIDAS","BatidasRepsArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method sincFuncionarios of Service WSAhgoraService

WSMETHOD sincFuncionarios WSSEND cempresa,oWSsincFuncionariosfuncionarios WSRECEIVE oWSsincFuncionariostotais WSCLIENT WSAhgoraService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:sincFuncionarios xmlns:q1="http://www.ahgora.com.br/ws">'
cSoap += WSSoapValue("empresa", ::cempresa, cempresa , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("funcionarios", ::oWSsincFuncionariosfuncionarios, oWSsincFuncionariosfuncionarios , "FuncionariosArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:sincFuncionarios>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ahgora.com.br/ws/service.php/sincFuncionarios",; 
	"RPCX","http://www.ahgora.com.br/ws",,,; 
	"http://www.ahgora.com.br/ws/service.php")

::Init()
::oWSsincFuncionariostotais:SoapRecv( WSAdvValue( oXmlRet,"_TOTAIS","totaisFuncionarios",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterResultados of Service WSAhgoraService

WSMETHOD obterResultados WSSEND cempresa,cmatricula,cdatai,cdataf,oWSobterResultadosopcoes WSRECEIVE oWSobterResultadosResultados WSCLIENT WSAhgoraService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:obterResultados xmlns:q1="http://www.ahgora.com.br/ws">'
cSoap += WSSoapValue("empresa", ::cempresa, cempresa , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("matricula", ::cmatricula, cmatricula , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("datai", ::cdatai, cdatai , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("dataf", ::cdataf, cdataf , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("opcoes", ::oWSobterResultadosopcoes, oWSobterResultadosopcoes , "OpcoesArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:obterResultados>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.ahgora.com.br/ws/service.php/obterResultados",; 
	"RPCX","http://www.ahgora.com.br/ws",,,; 
	"http://www.ahgora.com.br/ws/service.php")

::Init()
::oWSobterResultadosResultados:SoapRecv( WSAdvValue( oXmlRet,"_RESULTADOS","ResultadosArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Batidas

WSSTRUCT AhgoraService_Batidas
	WSDATA   oWSDados                  AS AhgoraService_Dados OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_Batidas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_Batidas
	::oWSDados             := {} // Array Of  AhgoraService_DADOS():New()
Return

WSMETHOD CLONE WSCLIENT AhgoraService_Batidas
	Local oClone := AhgoraService_Batidas():NEW()
	oClone:oWSDados := NIL
	If ::oWSDados <> NIL 
		oClone:oWSDados := {}
		aEval( ::oWSDados , { |x| aadd( oClone:oWSDados , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_Batidas
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSDados , AhgoraService_Dados():New() )
  			::oWSDados[len(::oWSDados)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Dados

WSSTRUCT AhgoraService_Dados
	WSDATA   oWSDados                  AS AhgoraService_DadosBatida
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_Dados
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_Dados
Return

WSMETHOD CLONE WSCLIENT AhgoraService_Dados
	Local oClone := AhgoraService_Dados():NEW()
	oClone:oWSDados             := IIF(::oWSDados = NIL , NIL , ::oWSDados:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_Dados
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","DadosBatida",NIL,"Property oWSDados as tns:DadosBatida on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDados := AhgoraService_DadosBatida():New()
		::oWSDados:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure BatidasRepsArray

WSSTRUCT AhgoraService_BatidasRepsArray
	WSDATA   oWSbatidas_reps           AS AhgoraService_batidas_reps OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_BatidasRepsArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_BatidasRepsArray
	::oWSbatidas_reps      := {} // Array Of  AhgoraService_BATIDAS_REPS():New()
Return

WSMETHOD CLONE WSCLIENT AhgoraService_BatidasRepsArray
	Local oClone := AhgoraService_BatidasRepsArray():NEW()
	oClone:oWSbatidas_reps := NIL
	If ::oWSbatidas_reps <> NIL 
		oClone:oWSbatidas_reps := {}
		aEval( ::oWSbatidas_reps , { |x| aadd( oClone:oWSbatidas_reps , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_BatidasRepsArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSbatidas_reps , AhgoraService_batidas_reps():New() )
  			::oWSbatidas_reps[len(::oWSbatidas_reps)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure batidas_reps

WSSTRUCT AhgoraService_batidas_reps
	WSDATA   cNSR                      AS string OPTIONAL
	WSDATA   cNREP                     AS string OPTIONAL
	WSDATA   cPIS                      AS string OPTIONAL
	WSDATA   cData                     AS string OPTIONAL
	WSDATA   cHora                     AS string OPTIONAL
	WSDATA   cSentido                  AS string OPTIONAL
	WSDATA   cposicao                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_batidas_reps
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_batidas_reps
Return

WSMETHOD CLONE WSCLIENT AhgoraService_batidas_reps
	Local oClone := AhgoraService_batidas_reps():NEW()
	oClone:cNSR                 := ::cNSR
	oClone:cNREP                := ::cNREP
	oClone:cPIS                 := ::cPIS
	oClone:cData                := ::cData
	oClone:cHora                := ::cHora
	oClone:cSentido             := ::cSentido
	oClone:cposicao             := ::cposicao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_batidas_reps
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNSR               :=  WSAdvValue( oResponse,"_NSR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNREP              :=  WSAdvValue( oResponse,"_NREP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPIS               :=  WSAdvValue( oResponse,"_PIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cHora              :=  WSAdvValue( oResponse,"_HORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSentido           :=  WSAdvValue( oResponse,"_SENTIDO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cposicao           :=  WSAdvValue( oResponse,"_POSICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure FuncionariosArray

WSSTRUCT AhgoraService_FuncionariosArray
	WSDATA   oWSfuncionario            AS AhgoraService_funcionario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_FuncionariosArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_FuncionariosArray
	::oWSfuncionario       := {} // Array Of  AhgoraService_FUNCIONARIO():New()
Return

WSMETHOD CLONE WSCLIENT AhgoraService_FuncionariosArray
	Local oClone := AhgoraService_FuncionariosArray():NEW()
	oClone:oWSfuncionario := NIL
	If ::oWSfuncionario <> NIL 
		oClone:oWSfuncionario := {}
		aEval( ::oWSfuncionario , { |x| aadd( oClone:oWSfuncionario , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT AhgoraService_FuncionariosArray
	Local cSoap := ""
	aEval( ::oWSfuncionario , {|x| cSoap := cSoap  +  WSSoapValue("funcionario", x , x , "funcionario", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure funcionario

WSSTRUCT AhgoraService_funcionario
	WSDATA   cmatricula                AS string OPTIONAL
	WSDATA   cpis                      AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   ccodBarras                AS string OPTIONAL
	WSDATA   cbiometria                AS string OPTIONAL
	WSDATA   cpasswd                   AS string OPTIONAL
	WSDATA   oWSlocalizacoes           AS AhgoraService_ArrayOfString OPTIONAL
	WSDATA   cdataAdmissao             AS string OPTIONAL
	WSDATA   cdataDemissao             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_funcionario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_funcionario
Return

WSMETHOD CLONE WSCLIENT AhgoraService_funcionario
	Local oClone := AhgoraService_funcionario():NEW()
	oClone:cmatricula           := ::cmatricula
	oClone:cpis                 := ::cpis
	oClone:cnome                := ::cnome
	oClone:ccodBarras           := ::ccodBarras
	oClone:cbiometria           := ::cbiometria
	oClone:cpasswd              := ::cpasswd
	oClone:oWSlocalizacoes      := IIF(::oWSlocalizacoes = NIL , NIL , ::oWSlocalizacoes:Clone() )
	oClone:cdataAdmissao        := ::cdataAdmissao
	oClone:cdataDemissao        := ::cdataDemissao
Return oClone

WSMETHOD SOAPSEND WSCLIENT AhgoraService_funcionario
	Local cSoap := ""
	cSoap += WSSoapValue("matricula", ::cmatricula, ::cmatricula , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("pis", ::cpis, ::cpis , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("nome", ::cnome, ::cnome , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("codBarras", ::ccodBarras, ::ccodBarras , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("biometria", ::cbiometria, ::cbiometria , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("passwd", ::cpasswd, ::cpasswd , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("localizacoes", ::oWSlocalizacoes, ::oWSlocalizacoes , "ArrayOfString", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("dataAdmissao", ::cdataAdmissao, ::cdataAdmissao , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("dataDemissao", ::cdataDemissao, ::cdataDemissao , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure totaisFuncionarios

WSSTRUCT AhgoraService_totaisFuncionarios
	WSDATA   ninseridos                AS int OPTIONAL
	WSDATA   nalterados                AS int OPTIONAL
	WSDATA   ndemitidos                AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_totaisFuncionarios
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_totaisFuncionarios
Return

WSMETHOD CLONE WSCLIENT AhgoraService_totaisFuncionarios
	Local oClone := AhgoraService_totaisFuncionarios():NEW()
	oClone:ninseridos           := ::ninseridos
	oClone:nalterados           := ::nalterados
	oClone:ndemitidos           := ::ndemitidos
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_totaisFuncionarios
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ninseridos         :=  WSAdvValue( oResponse,"_INSERIDOS","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nalterados         :=  WSAdvValue( oResponse,"_ALTERADOS","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::ndemitidos         :=  WSAdvValue( oResponse,"_DEMITIDOS","int",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure OpcoesArray

WSSTRUCT AhgoraService_OpcoesArray
	WSDATA   oWSOpcao                  AS AhgoraService_Opcoes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_OpcoesArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_OpcoesArray
	::oWSOpcao             := {} // Array Of  AhgoraService_OPCOES():New()
Return

WSMETHOD CLONE WSCLIENT AhgoraService_OpcoesArray
	Local oClone := AhgoraService_OpcoesArray():NEW()
	oClone:oWSOpcao := NIL
	If ::oWSOpcao <> NIL 
		oClone:oWSOpcao := {}
		aEval( ::oWSOpcao , { |x| aadd( oClone:oWSOpcao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT AhgoraService_OpcoesArray
	Local cSoap := ""
	aEval( ::oWSOpcao , {|x| cSoap := cSoap  +  WSSoapValue("Opcao", x , x , "Opcoes", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure Opcoes

WSSTRUCT AhgoraService_Opcoes
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_Opcoes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_Opcoes
Return

WSMETHOD CLONE WSCLIENT AhgoraService_Opcoes
	Local oClone := AhgoraService_Opcoes():NEW()
	oClone:cnome                := ::cnome
	oClone:cvalor               := ::cvalor
Return oClone

WSMETHOD SOAPSEND WSCLIENT AhgoraService_Opcoes
	Local cSoap := ""
	cSoap += WSSoapValue("nome", ::cnome, ::cnome , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("valor", ::cvalor, ::cvalor , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ResultadosArray

WSSTRUCT AhgoraService_ResultadosArray
	WSDATA   oWSResultado              AS AhgoraService_Resultados
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_ResultadosArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_ResultadosArray
	::oWSResultado         := {} // Array Of  AhgoraService_RESULTADOS():New()
Return

WSMETHOD CLONE WSCLIENT AhgoraService_ResultadosArray
	Local oClone := AhgoraService_ResultadosArray():NEW()
	oClone:oWSResultado := NIL
	If ::oWSResultado <> NIL 
		oClone:oWSResultado := {}
		aEval( ::oWSResultado , { |x| aadd( oClone:oWSResultado , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_ResultadosArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	If nTElem1 = 0 ; UserException("WSCERR015 / Node Resultado as tns:Resultados on SOAP Response not found.") ; Endif 
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSResultado , AhgoraService_Resultados():New() )
  			::oWSResultado[len(::oWSResultado)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Resultados

WSSTRUCT AhgoraService_Resultados
	WSDATA   cmatricula                AS string OPTIONAL
	WSDATA   ccod_contabil             AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_Resultados
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_Resultados
Return

WSMETHOD CLONE WSCLIENT AhgoraService_Resultados
	Local oClone := AhgoraService_Resultados():NEW()
	oClone:cmatricula           := ::cmatricula
	oClone:ccod_contabil        := ::ccod_contabil
	oClone:cnome                := ::cnome
	oClone:cvalor               := ::cvalor
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_Resultados
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cmatricula         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccod_contabil      :=  WSAdvValue( oResponse,"_COD_CONTABIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DadosBatida

WSSTRUCT AhgoraService_DadosBatida
	WSDATA   cNSR                      AS string OPTIONAL
	WSDATA   cNREP                     AS string OPTIONAL
	WSDATA   cPIS                      AS string OPTIONAL
	WSDATA   dData                     AS string OPTIONAL //modificado
	WSDATA   cHora                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_DadosBatida
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_DadosBatida
Return

WSMETHOD CLONE WSCLIENT AhgoraService_DadosBatida
	Local oClone := AhgoraService_DadosBatida():NEW()
	oClone:cNSR                 := ::cNSR
	oClone:cNREP                := ::cNREP
	oClone:cPIS                 := ::cPIS
	oClone:dData                := ::dData
	oClone:cHora                := ::cHora
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AhgoraService_DadosBatida
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNSR               :=  WSAdvValue( oResponse,"_NSR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNREP              :=  WSAdvValue( oResponse,"_NREP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPIS               :=  WSAdvValue( oResponse,"_PIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::dData              :=  WSAdvValue( oResponse,"_DATA","string",NIL,NIL,NIL,"S",NIL,NIL) //modificado para retornar string
	::cHora              :=  WSAdvValue( oResponse,"_HORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfString

WSSTRUCT AhgoraService_ArrayOfString
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AhgoraService_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AhgoraService_ArrayOfString
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT AhgoraService_ArrayOfString
	Local oClone := AhgoraService_ArrayOfString():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT AhgoraService_ArrayOfString
	Local cSoap := ""
	aEval( ::cstring , {|x| cSoap := cSoap  +  WSSoapValue("string", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap


