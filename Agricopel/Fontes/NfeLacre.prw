#Include "Rwmake.ch"
#include "Colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ NfeLacre บAutor  ณ Alan Leandro       บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Botao para informar o numero e a cor do Lacre.             บฑฑ
ฑฑบ          ณ ROTINA JA VERIFICADA VIA XAGLOGRT                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function NfeLacre()
************************
Local oDlgLacre
Local nOpca				:= 0
Local cLacreNr	  		:= GetMv("MV_LACRENR")
Local cLacreCor			:= GetMv("MV_LACRECO")

cLacreNr	:= Padr(cLacreNr,30)
cLacreCor	:= Padr(cLacreCor,30)

DEFINE MSDIALOG oDlgLacre TITLE "Informacoes do Lacre" FROM 9,0 TO 25,47 OF oMainWnd
@ 018, 010  SAY "Numero: " size 100,010
@ 018, 100  GET cLacreNr PICTURE "@!" SIZE 45,8 
@ 033, 010  SAY "Cor: " size 100,010
@ 033, 100  GET cLacreCor PICTURE "@!" SIZE 45,8 
DEFINE SBUTTON oCon FROM 070,060 TYPE 1 ACTION (nOpca := 1,Close(oDlgLacre)) ENABLE OF oDlgLacre
DEFINE SBUTTON oCan FROM 070,090 TYPE 2 ACTION (Close(oDlgLacre)) ENABLE OF oDlgLacre
                                     
ACTIVATE MSDIALOG oDlgLacre CENTERED 

If ( nOpca == 1 )
	PutMv("MV_LACRENR",cLacreNr)
	PutMv("MV_LACRECO",cLacreCor)
Endif

Return
