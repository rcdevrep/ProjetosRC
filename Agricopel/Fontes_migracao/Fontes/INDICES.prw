#Include 'totvs.ch'
#Include 'protheus.ch'

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 21/08/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Busca Indices Economicos.
Módulo (Uso) : SIGAGCT
=============================================================
/*/ 

CLASS INDICES

	Data aID
	Data cUrl

	METHOD New() CONSTRUCTOR
	METHOD GetIndices()
	METHOD GetIndice(cID)

ENDCLASS


//-------------------------------------------------------------------------------------------------------
METHOD New() CLASS INDICES

	::aID	:= {}
	::cUrl	:= "https://www.globsecure.com.br/indices/ClienteBCB.php"

Return

//-------------------------------------------------------------------------------------------------------
METHOD GetIndices(cUrl) CLASS INDICES

	Local nTimeOut	:= 120
	Local aHeadOut	:= {}
	Local aRetorno	:= {}
	Local cHeadRet	:= ""
	Local cPostRet	:= ""
	Local cParam	:= ""
	Local nNextPage	:= 1
	Local oPostRet
	Default cUrl		:= ::cUrl

	cPostRet	:= HttpPost(cUrl,cParam,'',nTimeOut,aHeadOut,@cHeadRet)
	oPostRet	:= XmlParser(cPostRet,"","","")

	If !Empty(cPostRet)
		oPostRet 	:= oPostRet:_NODES:_INDECES
	EndIf

Return aRetorno

//-------------------------------------------------------------------------------------------------------
METHOD GetIndice(cId,cDtIni,cDtFim,cUrl) CLASS INDICES

	Local nTimeOut	:= 60
	Local aHeadOut	:= {}
	Local aRetorno	:= {}
	Local cHeadRet	:= ""
	Local cPostRet	:= ""
	Local cParam	:= ""
	Local oPostRet
	Default cUrl	:= ::cUrl     

	cUrl		:=cUrl+"?indice="+AllTrim(cId)+"&dataInicio="+AllTrim(cDtIni)+"&dataFim="+AllTrim(cDtFim)+""    

	cPostRet	:= HttpPost(cUrl,'','',nTimeOut,aHeadOut,@cHeadRet)
	oPostRet	:= XmlParser(cPostRet,"","","")

	If !Empty(cPostRet)
		AADD(aRetorno,oPostRet:_INDICE)
	EndIf

Return aRetorno