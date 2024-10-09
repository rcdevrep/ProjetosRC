
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
	Private oJsonRet:= NIL

	cPostRet := HttpSPost(cURL,cCert, cPrivate ,cPassword,cParam,cJson,,aHeadOut,@cHeadRet )
	cStatus:= HTTPGetStatus(cHeadRet)

	if Empty( cPostRet )

		AADD(aRet, .F.)
		AADD(aRet, cPostRet )
		AADD(aRet, "01" ) // HTTP ERROR

	else


		If !FWJsonDeserialize(cPostRet,@oJsonRet)
			AADD(aRet, .F.)
			AADD(aRet, cPostRet )
			AADD(aRet, "02" ) //"NAO FOI POSSIVEL DESEREALIZAR O RETORNO
			AADD(aRet, oJsonRet)

		ELSE
			AADD(aRet, .T.)
			AADD(aRet, cPostRet )
			AADD(aRet, "05" ) // SUCESSO
			AADD(aRet, oJsonRet)

		Endif

		varinfo( "WebPage", cPostRet )
	endif

	varinfo( "Header", cPostRet )

return aRet
