#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR132    ºAutor  ³Deco                º Data ³  29/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Debito lancamento padrao 520-01             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR132()

	Private cCtaDeb:= SA6->A6_CONTA

	/*
	* Qdo baixa normal debita caixa/banco
	*/
	If alltrim(SE1->E1_TIPO) <> 'CH' .and. Empty(SE1->E1_TIPOLIQ)
		cCtaDeb := SA6->A6_CONTA
	Endif

	/*
	* Qdo baixa liquidacao correspondente a baixa com cheques debita cfe abaixo
	*/
	If alltrim(SE1->E1_TIPO) <> 'CH' .and. Alltrim(SE1->E1_TIPOLIQ) = 'CH'
		cCtaDeb := '112010003'
	EndIf

	/*
	* Qdo baixa cheque proveniente da liquidacao de um titulo com cheque debita caixa
	*/
	If alltrim(SE1->E1_TIPO) == 'CH' 
		//cCtaDeb := '111010001'    ALTERADO EM 26012010 CONFORME ALEXANDRE CONTABIL.
		cCtaDeb := SA6->A6_CONTA
	EndIf

	/*
	* Quando for titulo de contrato buscar conta da natureza
	*/
	If !Empty(SE1->E1_MDCONTR)
		If "ALUG" $ UPPER(ALLTRIM(SE1->E1_HIST))
			cCtaDeb := "112010012"
		EndIf
	EndIf

	//Contabilizao RA chamado 71354 e NCC chamado 72441  
	if alltrim(SE1->E1_TIPO) $ 'RA/NCC'
	   cCtaDeb := SA1->A1_CONTA   //Cliente 
	Endif


Return(cCtaDeb)