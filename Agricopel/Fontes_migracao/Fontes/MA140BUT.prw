#Include "PROTHEUS.CH"
	
/*  	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMA140BUT  บAutor  Leandro F. Silveira  บ Data ณ  05/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para alterar lote/armaz้m na pr้-nota de entrada  บฑฑ
ฑฑบ          ณ quando a nota ้ de devolu็ใo                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MA140BUT()

	Local aBotoes := {}

	Private oDlgLote
	Private cGetLote  := ""
	Private cGetArmaz := ""

	AADD(aBotoes, {"NOTE", {|| AltLoteArmaz()}, "Lote/Armaz"})

Return aBotoes

Static Function AltLoteArmaz()

	If AllTrim(CTIPO) == "D"
		AbrirTela()
	Else
		MsgAlert("Nota fiscal nใo ้ de devolu็ใo!")
	EndIf

Return .T.

Static Function AbrirTela()

	Local aTam := {}
	Local oButton1
	Local oButton2
	Local oGet1
	Local oGet2
	Local oSay1
	Local oSay2

	aTam := TamSX3("D1_LOTECTL")
	cGetLote := Space(aTam[1])
	
	aTam := TamSX3("D1_LOCAL")
	cGetArmaz := Space(aTam[1])

    DEFINE MSDIALOG oDlgLote TITLE "Altera็ใo de Lote / Armaz้m" FROM 000, 000  TO 150, 250 COLORS 0, 16777215 PIXEL

    @ 014, 019 SAY oSay1 PROMPT "Lote" SIZE 025, 007 OF oDlgLote COLORS 0, 16777215 PIXEL
    @ 031, 019 SAY oSay2 PROMPT "Armaz้m" SIZE 025, 007 OF oDlgLote COLORS 0, 16777215 PIXEL
    @ 012, 050 MSGET oGet1 VAR cGetLote SIZE 060, 010 OF oDlgLote COLORS 0, 16777215 PIXEL
    @ 030, 050 MSGET oGet2 VAR cGetArmaz SIZE 060, 010 OF oDlgLote COLORS 0, 16777215 PIXEL
    @ 049, 017 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgLote ACTION ExecAlt() PIXEL
    @ 049, 073 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlgLote ACTION oDlgLote:End() PIXEL

    ACTIVATE MSDIALOG oDlgLote CENTERED

Return .T.

Static Function ExecAlt()

	Local cD1_LOTECTL := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOTECTL"})
	Local cD1_LOCAL   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL"})
	Local _iX := 1

	If AllTrim(cGetLote) <> "" .Or. AllTrim(cGetArmaz) <> ""

		For _iX := 1 To Len(aCols)

			If AllTrim(cGetLote) <> ""
				aCols[_iX, cD1_LOTECTL] := cGetLote
			EndIf

			If AllTrim(cGetArmaz) <> ""
				aCols[_iX, cD1_LOCAL] := cGetArmaz
			EndIf

		Next _iX

		Eval(bRefresh)
		Eval(bGdRefresh)
		oDlgLote:End()
	Else
		MsgAlert("ษ necessแrio informar pelo menos um valor a alterar!")
	EndIf

Return .T.