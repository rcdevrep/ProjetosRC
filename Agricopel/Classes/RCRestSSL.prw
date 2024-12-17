
#include "totvs.ch"
#include "protheus.ch"
#include "restful.ch"
#include "topconn.ch"

user function RCRestSSL(cURL, cParam, cJson, aHeadOut )

	Local nTimeOut := 120
	Local cHeadRet := ""
	Local cPostRet := ""
	Local cDirServ      := "\cert APIs bancos\Pix\"
	Local cCert     := cDirServ+"certificado.pem"
	Local cPrivate    := cDirServ+"private.key"
	Local cPassword := GetNewPar("MV_XCERTPS","p3tro_@632")
	Local cCodResp, cStatus := ""
	Local aRet := {}
	Private oJsonRet:= JsonObject():new()

	cPostRet := HttpSPost(cURL,cCert, cPrivate ,cPassword,cParam,cJson,,aHeadOut,@cHeadRet )
	cStatus:= HTTPGetStatus(cHeadRet)

	if Empty( cPostRet )

		AADD(aRet, .F.)
		AADD(aRet, cPostRet )
		AADD(aRet, "01" ) // HTTP ERROR

	else

		ret := oJsonRet:FromJson(cPostRet)
 
		if ValType(ret) == "U"
			Conout("JsonObject populado com sucesso")
			AADD(aRet, .T.)
			AADD(aRet, cPostRet )
			AADD(aRet, "05" ) // SUCESSO
			AADD(aRet, oJsonRet)		
		else
			Conout("Falha ao popular JsonObject. Erro: " + ret)
			AADD(aRet, .F.)
			AADD(aRet, cPostRet )
			AADD(aRet, "02" ) //"NAO FOI POSSIVEL DESEREALIZAR O RETORNO
			AADD(aRet, oJsonRet)
		endif
		varinfo( "WebPage", cPostRet )
	endif

	varinfo( "Header", cPostRet )

return aRet


user function RCRestGet(cURL, cParam, cJson, aHeadOut )

	Local nTimeOut := 120
	Local cHeadRet := ""
	Local cRetGet := ""
	Local nCodResp := 0
	Local aRet := {}
	Local cDirServ      := "\cert APIs bancos\Pix\"
	Local cCert     := cDirServ+"certificado.pem"
	Local cPrivate    := cDirServ+"private.key"
	Local cPassword := GetNewPar("MV_XCERTPS","p3tro_@632")
	Default cParam := ""
	Private oJsonRet:= JsonObject():new()

    //cRetGet := HTTPGet(cURL, , nTimeOut, aHeadOut, @cHeadRet)    
	cRetGet := HTTPSGet(cURL,cCert,cPrivate,cPassword,cParam,nTimeOut, aHeadOut, @cHeadRet)    
	//cPostRet := HttpSPost(cURL,cCert, cPrivate ,cPassword,cParam,nTimeOut,,aHeadOut,@cHeadRet )
    nCodResp:= HTTPGetStatus(cHeadRet)
	ret := oJsonRet:FromJson(cRetGet)

	if Empty( cRetGet )

		AADD(aRet, .F.)
		AADD(aRet, cRetGet )
		AADD(aRet, "01" ) // HTTP ERROR
		AADD(aRet, oJsonRet)
		
	else

		
 
		if ValType(ret) == "U"
			Conout("JsonObject populado com sucesso")
			AADD(aRet, .T.)
			AADD(aRet, cRetGet )
			AADD(aRet, "05" ) // SUCESSO
			AADD(aRet, oJsonRet)		
		else
			Conout("Falha ao popular JsonObject. Erro: " + ret)
			AADD(aRet, .F.)
			AADD(aRet, cRetGet )
			AADD(aRet, "02" ) //"NAO FOI POSSIVEL DESEREALIZAR O RETORNO
			AADD(aRet, oJsonRet)
		endif
		varinfo( "WebPage", cRetGet )
	endif

	varinfo( "Header", cRetGet )

return aRet
