#INCLUDE "RWMAKE.CH"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR135    ºAutor  ³Deco                º Data ³  29/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para credito lancamento padrao 527-01            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR135()

PRIVATE cCtaCre:= SA6->A6_CONTA

*
* Qdo cancelamento baixa normal Credita caixa/banco
*
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Empty(SE1->E1_TIPOLIQ)
   cCtaCre := SA6->A6_CONTA 
Endif

*
* Qdo cancelamento baixa liquidacao correspondente a baixa com cheques Credita cfe abaixo
*
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Alltrim(SE1->E1_TIPOLIQ) = 'CH'
   cCtaCre := '112010003'
EndIf

*
* Qdo cancelamento baixa cheque proveniente da liquidacao de um titulo com cheque Credita caixa
*
If alltrim(SE1->E1_TIPO) == 'CH' 
   cCtaCre := SA6->A6_CONTA
EndIf    

//Contabilizao RA chamado 71354 e NCC chamado 72441  
if alltrim(SE1->E1_TIPO) $ 'RA/NCC'
   cCtaCre := SA1->A1_CONTA   //Cliente 
Endif

	
Return(cCtaCre)