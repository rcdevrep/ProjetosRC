#Include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.CH"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 16/11/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Consulta de Curto e Longo Prazo.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0012() 

	_cFilial	:= CN9->CN9_FILIAL
	_cContra	:= CN9->CN9_NUMERO
	_cRevisa	:= CN9->CN9_REVISA 
	_cSldEmp	:= CN9->CN9_XSLDEM

	cQuery := ""
	cQuery += " SELECT COUNT(*) AS TOTPARC"
	cQuery += " FROM "+RetSqlName("CNA")+" CNA, "+RetSqlName("CNF")+" CNF"
	cQuery += " WHERE CNA.D_E_L_E_T_ = ' '  AND CNF.D_E_L_E_T_ = ' ' "
	cQuery += " AND CNA_FILIAL = '"+_cFilial+"'" 
	cQuery += " AND CNA_CONTRA = '"+_cContra+"'"
	cQuery += " AND CNA_REVISA  = '"+_cRevisa+"'"  
	cQuery += " AND CNA_XSLDCL = 'S'"  
	cQuery += " AND CNA_FILIAL = CNF_FILIAL" 
	cQuery += " AND CNA_CONTRA = CNF_CONTRA"
	cQuery += " AND CNA_REVISA = CNF_REVISA"
	cQuery += " AND CNA_CRONOG = CNF_NUMERO"
	cQuery += " AND CNF_DTREAL = ' '"

	cQuery := ChangeQuery(cQuery)  			

	If (Select("QRYT1") <> 0)
		dbSelectArea("QRYT1")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "QRYT1"

	DBSELECTAREA("QRYT1")
	QRYT1->(DBGOTOP()) 
	_i:= 0   

	If QRYT1->TOTPARC <> 0

		WHILE QRYT1->(!EOF()) 

			If QRYT1->TOTPARC > 12

				_VlrParc := (_cSldEmp/QRYT1->TOTPARC)

				DEFINE FONT oFont1 NAME "Calibri" SIZE 0,25 BOLD


				@ 003,001 TO 250,350 DIALOG oDlg1 TITLE "Saldo a Curto e Longo Prazo"

				@ 010,015 Say "SALDO: "+AllTrim(Str(_cSldEmp))+""      					SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
				@ 025,015 Say "Tot Parc a Vencer: "+AllTrim(Str(Round(QRYT1->TOTPARC,2)))+""     	SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
				@ 040,015 Say "Vlr Médio Parcela: "+AllTrim(Str(Round(_VlrParc,2)))+""     		SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
				@ 055,015 Say "Curto Prazo: "+AllTrim(Str(Round(_VlrParc*12,2)))+""    				SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
				@ 070,015 Say "Lonto Prazo: "+AllTrim(Str(Round(_VlrParc*(QRYT1->TOTPARC-12),2)))+""  	SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 

				@ 100,135 BUTTON "_Sair"           	SIZE 30,15 ACTION Close(oDlg1)

				ACTIVATE DIALOG oDlg1 CENTERED	 

			Else
				If !IsBlind()
					MsgInfo("Apenas Saldo a Curto Prazo!")   

					_VlrParc := (_cSldEmp/QRYT1->TOTPARC)

					DEFINE FONT oFont1 NAME "Calibri" SIZE 0,25 BOLD


					@ 003,001 TO 250,350 DIALOG oDlg1 TITLE "Saldo a Curto Prazo"

					@ 010,015 Say "SALDO: "+AllTrim(Str(_cSldEmp))+""      					SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
					@ 025,015 Say "Tot Parc a Vencer: "+AllTrim(Str(Round(QRYT1->TOTPARC,2)))+""     	SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
					@ 040,015 Say "Vlr Médio Parcela: "+AllTrim(Str(Round(_VlrParc,2)))+""     		SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
					@ 055,015 Say "Curto Prazo: "+AllTrim(Str(Round(_cSldEmp,2)))+""    				SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 

					@ 100,135 BUTTON "_Sair"           	SIZE 30,15 ACTION Close(oDlg1)

					ACTIVATE DIALOG oDlg1 CENTERED
				EndIf
			EndIf

			QRYT1->(DBSKIP())
		ENDDO   
	Else
		If !IsBlind()
			MsgInfo("Não encontrou dados!")
		EndIf
	EndIf	

Return()