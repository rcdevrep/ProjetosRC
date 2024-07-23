#include "rwmake.ch" 
#INCLUDE "TOPCONN.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F460UTIL  ºAutor  ³Microsiga           º Data ³  09/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PONTOS DE ENTRADA F460SE1 E F460VAL PARA TRATAMENTO DE      º±±
±±º          ³COMISSAO NA ROTINA DE LIQUIDACAO                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AGRICOPEL                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PONTO DE ENTRADA F460SE1 - AGLUTINACAO DOS VENDODORES UTILIZADOS NOS TITULOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function F460SE1()
/*
Local aVendedores := {} 
Local nVend := fa440CntVen() // Retorna o numero de campos VENDx no SX3

aVendedores := PARAMIXB // Recebe a situacao atual do array aComplem no FINA460

cVend := "1" 

For nCntFor := 1 To nVend 	

	cVendedor := SE1->(FieldGet(SE1->(FieldPos("E1_VEND"+cVend))))
	nPerComis := SE1->(FieldGet(SE1->(FieldPos("E1_COMIS"+cVend))))

	If (nPerComis != 0) .And.;// !Empty(cVendedor)) .and.; 
		( If(Len(aVendedores)>0, aScan(aVendedores,{|x| AllTrim(x[1]) == cVendedor}) = 0, .T.))

		// Verifica se o vendedor nao existe no array
		// Parte do principio de que a comissao do vendedor e fixa. 
		// Caso a mesma seja variavel, a montagem do array devera tratar Vendedor + Comissao
		
		aAdd( aVendedores,	{ cVendedor, nPerComis})

	EndIf
	cVend := Soma1(cVend,1)
Next nCntFor

Return aVendedores
*/
Return


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PONTO DE ENTRADA F460VAL - GRAVACAO DOS VENDEDORES AGLUTINADOS NO NOVO TIT. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function F460VAL()

/*
Local aVendedores := {}
Local nVend := fa440CntVen() // Retorna o numero de campos VENDx no SX3

aVendedores := PARAMIXB


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para nao exceder o numero de campos de vendedores em uso         ³
//³Devera ser definido no cliente a regra para este tratamento de forma        ³
//³a atender as necessidades do mesmo e garantir a integridade da base         ³		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If Len(aVendedores) > 0 .and. Len(aVendedores) <= nVend

	cVend := "1" 
	For nCntFor:= 1 to Len(aVendedores)
	
		RecLock("SE1",.F.)
		SE1->&("E1_VEND"+cVend)  := aVendedores[nCntFor][1]
		SE1->&("E1_COMIS"+cVend) := aVendedores[nCntFor][2]		
		MsUnlock()

		cVend := Soma1(cVend,1)

	Next nCntFor 

Endif
*/

*
* Grava CMC7 Cheque  // CMC7 Cheque  - Deco 29/12/2004
*  
For nCntFor := 1 To Len(aCols)
    
   cNum    := aCols[nCntFor,6] // nro. do cheque
   cBcoChq := aCols[nCntFor,3] // banco
   cAgeChq := aCols[nCntFor,4] // agencia
   cCtaChq := aCols[nCntFor,5] // conta
   cTipo   := aCols[nCntFor,2] // tipo
   dVencto := aCols[nCntFor,7] // data de vencimento
   nValor  := aCols[nCntFor,8] // valor do cheque 
   
	If	alltrim(SE1->E1_NUM)	   == alltrim(cNum)	   .and.;	// nro. do cheque
		alltrim(SE1->E1_BCOCHQ) == alltrim(cBcoChq)	.and.;	// banco
		alltrim(SE1->E1_AGECHQ) == alltrim(cAgeChq)	.and.;	// agencia
		alltrim(SE1->E1_CTACHQ) == alltrim(cCtaChq)  .and.; 	// conta
		alltrim(SE1->E1_TIPO)   == alltrim(cTipo)  	.and.;	// Tipo
		alltrim(SE1->E1_VALOR)	== alltrim(nValor)	.and.;	// valor do cheque
   	Dtoc(SE1->E1_VENCTO)	   == Dtoc(dVencto)	          	// data de vencimento

		RecLock("SE1",.F.)
		SE1->E1_CMC7 := aCols[nCntFor,12]		// CMC7 Cheque  - Deco 29/12/2004
		SE1->(MsUnlock())

	Endif
	
Next nCntFor 

Return

