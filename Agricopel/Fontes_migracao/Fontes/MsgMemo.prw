#Include "PROTHEUS.CH"

// Mensagem de Alert com Memo
// Leandro Spiller - 29/05/2015
User Function MsgMemo(xTitulo,xMsg,xlYesNo)

	Local lretMemo 		:= .F.
	Static oDlgMemo
	Static oButton1
	Static oButton2
	Static oMultiGet1
	Static cMultiGet1 	:= ""

	cMultiGet1 := xMsg

	DEFINE MSDIALOG oDlgMemo TITLE xTitulo FROM 000, 000  TO 350, 400 COLORS 0, 16777215 PIXEL

	    @ 005, 005 GET oMultiGet1 VAR cMultiGet1 OF oDlgMemo MULTILINE SIZE 193, 150 COLORS 0, 16777215 READONLY HSCROLL PIXEL

		if xlYesNo
			@ 160, 150 BUTTON oButton1 PROMPT "Não" SIZE 037, 012 OF oDlgMemo PIXEL Action(lRetMemo := .F., oDlgMemo:End() )
	   		@ 160, 095 BUTTON oButton2 PROMPT "Sim" SIZE 037, 012 OF oDlgMemo PIXEL Action(lRetMemo := .T. , oDlgMemo:End() )
	   	else
	   		@ 160, 083 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oDlgMemo PIXEL Action(lRetMemo := .T. , oDlgMemo:End() )
	    endif

	ACTIVATE MSDIALOG oDlgMemo CENTERED

Return lRetMemo