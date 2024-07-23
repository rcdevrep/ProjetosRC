#INCLUDE "rwmake.ch"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 19/09/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Preenchimento automatico CNF_XPGEFE, usado por gatilho.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0006()

	Local oBrwCNF	:= Nil 
	Local oCNFDetl	:= Nil 
	Local oView 	:= FWViewActive()
	Local oBrwCNF	:= FWModelActive()
	Local _x

	oCNFDetl	:= oBrwCNF:getModel("CNFDETAIL")
	_oAcols 	:= oCNFDetl:ADATAMODEL
	_nLinha 	:= oCNFDetl:NLINE

	If (_nVarCtl == _nLinha)
		If MsgYesNo("Todas as abaixo tambem são pagamentos efetivos?")
			lTdPgEfe := .T.
		EndIf
	EndIf

	For _x := 2 to Len(oCNFDetl:ADATAMODEL)
		If lTdPgEfe
			oCNFDetl:SetValue("CNF_XPGEFE","1")
			oCNFDetl:NLINE:=_x
		EndIf
	Next _x

	oView:Refresh()

Return(FWFldGet('CNF_XPGEFE'))