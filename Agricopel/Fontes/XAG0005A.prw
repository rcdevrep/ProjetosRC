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

CLASS XAG0005A

	Data aID
	Data cUrl

	METHOD New() CONSTRUCTOR
	METHOD GetIndices()
	METHOD GetIndice(cID)

ENDCLASS


//-------------------------------------------------------------------------------------------------------
METHOD New() CLASS XAG0005A

	::aID	:= {}
	::cUrl	:= "https://www.globsecure.com.br/indices/ClienteBCB.php"

Return

//-------------------------------------------------------------------------------------------------------
METHOD GetIndices(cUrl) CLASS XAG0005A

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
	
	If cPostRet <> "U"
		If !Empty(cPostRet)
			oPostRet := XmlParser(cPostRet,"","","")
			oPostRet := oPostRet:_NODES:_INDECES
		Else
			MsgInfo(OemToAnsi("Indice Economico "+AllTrim(cId)+" não localizado ou já atualizado anteriormente."))
		EndIf
	EndIf

Return aRetorno

//-------------------------------------------------------------------------------------------------------
METHOD GetIndice(cId,cDtIni,cDtFim,cUrl) CLASS XAG0005A

	Local nTimeOut	:= 240
	Local aHeadOut	:= {}
	Local aRetorno	:= {}              
	Local cHeadRet	:= ""
	Local cPostRet	:= ""
	Local cParam	:= ""
	Local oPostRet

	Default cUrl	:= ::cUrl     

	cUrl		:= cUrl+"?indice="+AllTrim(cId)+"&dataInicio="+AllTrim(cDtIni)+"&dataFim="+AllTrim(cDtFim)+""    
	cPostRet	:= HttpPost(cUrl,'','',nTimeOut,aHeadOut,@cHeadRet)

	If cPostRet <> "U"
		If !Empty(cPostRet)
			oPostRet := XmlParser(cPostRet,"","","")
			AADD(aRetorno,oPostRet:_INDICE)
		Else
			MsgInfo(OemToAnsi("Indice Economico "+AllTrim(cId)+" não localizado ou já atualizado anteriormente."))
		EndIf
	EndIf

Return aRetorno