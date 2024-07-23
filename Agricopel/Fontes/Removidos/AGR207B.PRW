#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR207B   ºAutor  ³Deco                º Data ³  08/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Excluir        Cheque Extra                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function AGR207B()


   // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   // ³ Define titulo do programa que aparecera na tela             ³
   // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cCad002B  := OemToAnsi("Exclusao Cheque Extra")

//   DbSelectArea("SA1")
//   DbSetOrder(1)
//   DbGotop()
//   DbSeek(xFilial("SA1")+cCod+cLoja)
	
   cCheque	:= "Cheque: "+SEF->EF_NUM+ " Banco: "+ SEF->EF_BANCO + " Agencia: "+SEF->EF_AGENCIA +" Conta: "+SEF->EF_CONTA
// cVencto  := Substr(SEF->EF_VENCTO,7,2)+'/'+Substr(SEF->EF_VENCTO,5,2)+'/'+Substr(SEF->EF_VENCTO,3,2) // dd/mm/aa
   cVencto  := "Vencto: "+DTOC(SEF->EF_VENCTO)
   cValor   := "Valor : "+STR(INT(SEF->EF_VALOR))+'.'+(STRZERO((SEF->EF_VALOR-INT(SEF->EF_VALOR))*100,2))

   cHistx   := Space(30)

   // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   // ³ Solicita Dados                                              ³
   // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   @ 96,42 TO 250,600 DIALOG oMsg TITLE OemToAnsi(cCad002B)

   @ 09, 010 SAY cCheque
   @ 20, 010 SAY cVencto
   @ 30, 010 SAY cValor
   @ 53, 010 SAY OemToAnsi("Historico")
   @ 53, 081 GET cHistx SIZE 100,50 
   
   @ 65,130 BMPBUTTON TYPE 01 ACTION FazExclui()
   @ 65,160 BMPBUTTON TYPE 02 ACTION Close(oMsg)
   ACTIVATE DIALOG oMsg CENTERED
   // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   // ³ Fim da Solicitacao dos dados                                ³
   // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

Static Function FazExclui
   Close(oMsg)
   DbSelectarea("SEF")
   Reclock("SEF",.F.)
	If !Empty(cHistx)
  		SEF->EF_HIST    := cHistx   
	EndIf
   DbDelete()
   Msunlock("SEF")
Return
