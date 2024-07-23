#Include 'Protheus.ch' 
#Include "topconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "colors.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "sigawin.ch"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 04/08/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Preenchimento automatico CNF_XCAREN, usado por gatilho.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0003()

	Local oBrwCNF	:= Nil 
	Local oCNFDetl	:= Nil 
	Local _i

	oBrwCNF		:= FWModelActive()
	oCNFDetl	:= oBrwCNF:getModel("CNFDETAIL")
	_oAHead 	:= oCNFDetl:AHEADER
	_oAcols 	:= oCNFDetl:ADATAMODEL
	_nLinha 	:= oCNFDetl:NLINE
	_nVlrPlani	:= nTotPlan 
	_nNumTotParc:= Len(aCols)
	_nNumAbaixo	:= Len(aCols)-N 
	_nNumAcima	:= (_nNumTotParc-_nNumAbaixo)
	_nVlrAbaixo	:= 0
	_nVlrAcima	:= 0  
	_nSldDistri := 0 
	_nValPorParc:= 0 
	lTodasJur 	:= .F.

	If MsgYesNo("Todas as abaixo tambem são apenas juros?")
		lTodasJur:= .T.
	EndIf

	For _i:=1 To _nNumAcima
		_nVlrAcima += aCols[_i,nPosVlPrev] 	
	Next

	For _i:=1 To _nNumAbaixo
		_nVlrAbaixo += aCols[_i+N,nPosVlPrev] 	
	Next

	_nSldDistri := _nVlrPlani-(_nVlrAcima+_nVlrAbaixo)  
	_nValPorParc := (_nVlrAbaixo+_nSldDistri)/(Len(aCols)-N)

	For _i:=2  to Len(oCNFDetl:ADATAMODEL) 
		If lTodasPgEfe 
			FwFldPut("CNF_XPGEFE","1",_i,,,.T.)
		EndIf
	Next _i

	oCNFDetl:NLINE:=_nLinha

Return(FWFldGet('CNF_XCAREN'))