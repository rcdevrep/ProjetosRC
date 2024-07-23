#Include 'Protheus.ch' 
#Include "topconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "colors.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/04/01
#include "sigawin.ch"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 09/11/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Preenchimento automatico itens da planilha.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0011()

	Local oBrwCNB		:= Nil 
	Local oCNBMaster	:= Nil 

	oBrwCNB		:= FWModelActive()
	oCNBMaster	:= oBrwCNB:getModel("CNBDETAIL")
	_oAHead 	:= oCNBMaster:AHEADER
	_oAcols 	:= oCNBMaster:ADATAMODEL
	_nLinha 	:= oCNBMaster:NLINE

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += " WHERE SD2.D_E_L_E_T_ = ' ' "
	cQuery += " AND D2_FILIAL	= '" + xFilial("SD2") + "' " 
	cQuery += " AND D2_CLIENTE	= '" + FWFldGet('CNA_CLIENT') + "' "
	cQuery += " AND D2_LOJA  	= '" + FWFldGet('CNA_LOJACL') + "' "
	cQuery += " AND D2_DOC		= '" + FWFldGet('CNA_XNFSAI') + "' " 
	cQuery += " AND D2_SERIE  	= '" + FWFldGet('CNA_XSESAI') + "' "	
	cQuery += " ORDER BY D2_ITEM "
	cQuery := ChangeQuery(cQuery)			

	If (Select("QRYT1") <> 0)
		dbSelectArea("QRYT1")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "QRYT1"

	DBSELECTAREA("QRYT1")
	QRYT1->(DBGOTOP())

	_nPAcol := _nLinha

	If QRYT1->(!EOF())

		WHILE QRYT1->(!EOF())	

			// Adiciona novas linhas
			If _nPAcol > 1
				oCNBMaster:AddLine()
			EndIf

			FwFldPut("CNB_FILIAL"	,cFilAnt			,_nPAcol,,,.T.)
			FwFldPut("CNB_ITEM"		,STRZERO(_nPAcol,3)	,_nPAcol,,,.T.)
			FwFldPut("CNB_PRODUT"	,QRYT1->D2_COD		,_nPAcol,,,.T.)
			FwFldPut("CNB_DESCRI"	,Substr(Posicione("SB1",1,xfilial("SB1")+QRYT1->D2_COD,"B1_DESC"),1,30),_nPAcol,,,.T.)
			FwFldPut("CNB_UM"		,QRYT1->D2_UM		,_nPAcol,,,.T.)
			FwFldPut("CNB_QUANT"	,QRYT1->D2_QUANT	,_nPAcol,,,.T.)
			FwFldPut("CNB_VLUNIT"	,QRYT1->D2_PRCVEN	,_nPAcol,,,.T.)
			FwFldPut("CNB_VLTOT"	,QRYT1->D2_TOTAL	,_nPAcol,,,.T.)
			FwFldPut("CNB_CONTRA"	,FWFldGet('CNA_CONTRA')	,_nPAcol,,,.T.)
			FwFldPut("CNB_DTCAD"	,dDataBase			,_nPAcol,,,.T.)
			FwFldPut("CNB_CONTA"	,QRYT1->D2_CONTA	,_nPAcol,,,.T.)
			FwFldPut("CNB_FLGCMS"	,"1"				,_nPAcol,,,.T.)
			FwFldPut("CNB_TS"		,QRYT1->D2_TES		,_nPAcol,,,.T.)
			FwFldPut("CNB_GERBIN"	,"2"				,_nPAcol,,,.T.)
			FwFldPut("CNB_BASINS"	,"2"				,_nPAcol,,,.T.)
			FwFldPut("CNB_RJRTO"	,.F.				,_nPAcol,,,.T.)

			_nPAcol++
			QRYT1->(DbSkip())

		EndDo

		oCNBMaster:NLINE:=_nLinha

	Else

		If !IsBlind()
			MsgInfo("Não encontrou dados para esta nota fiscal!")
		EndIf

	EndIf

Return(FWFldGet('CNA_XSESAI'))