#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR120    ºAutor  ³Deco                º Data ³  05/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Debito lancamento padrao 650-01             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR120()

PRIVATE cCtaDeb

cCtaDeb := SD1->D1_CONTA

If SD1->D1_TIPO <> 'D'
   If Alltrim(SD1->D1_CF) == '1659' .or.; // Transferencias produtos 9926 9927 9912 9915
      Alltrim(SD1->D1_CF) == '1152' .or.;
      Alltrim(SD1->D1_CF) == '1409' .or.; 
      Alltrim(SD1->D1_TES) == "070"

      cCtaDeb := SB1->B1_CONTA // Contas dos produto de transf. 112070001 112070002 112070004 112070005
   Endif
EndIf   
   

/*If SF4->F4_CODIGO == '051' comentado rodrigo
   cCtaDeb := SD1->D1_CONTA
EndIf*/ 
                                              

If SD1->D1_TIPO == "D" 
	Do Case 
		Case SB1->B1_TIPO == "LU" 
			cCtaDeb := "51120105" 
		Case SB1->B1_TIPO == "PA"
			cCtaDeb := "51120109"
		Case SB1->B1_TIPO == "CO"
			cCtaDeb := "51120101"
		Case SB1->B1_TIPO $"ME/LO"  //CHAMADO CFE CHAMADO 73769 - TRATAR TIPO ME TBM
			cCtaDeb := "51120109"
	EndCase
EndIf 


/*
 * pegar cnpj do fornecedor e comparar com cnpj da filial da nota de entrada
 * se o cnpj do fornecedor for igual ao da filial, fazer as seguintes condicoes
 *  se D1_CF = '1949' e B1_CONTA = '112070001' or B1_CONTA = '112070003'
 *  conta debito: 52111519   
 *
 *  se D1_CF = '1949' e D1_COD = '13285' 
 *  conta debito: 52110715
 *
 *  se D1_CF = '1949' e B1_CONTA = '112070002' ou B1_CONTA = '112070004'
 *  conta debito: 52110715      
 *
 *  se D1_CF = '1927' 
 *  conta debito: 52111531   
 *
 *  tem que verificar a rotina abaixo para liberar em producao, pois esta estourando erro.
 *  quando estiver solucionado, tem que remover a validacao .and. "1"=="3"
 */

if cEmpAnt == "20"
PRIVATE cFilCNPJ   := ''
PRIVATE cA2PJ      := ''
PRIVATE cContaProd := ''
Private _aareaSM0 := SM0->(getarea())

DbSelectArea("SM0")
DbGotop()
While !Eof()
   If SM0->M0_CODIGO == cEmpAnt
      If  Alltrim(SD1->D1_FILIAL) == SM0->M0_CODFIL
         cFilCNPJ := Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") 
         
         If !Empty(ALLTRIM(SD1->D1_FORNECE))
            cPessoa:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
            cA2PJ := ALLTRIM(cPessoa)
	     EndIf

	     if ((!empty(ALLTRIM(cFilCNPJ)) .and. !empty(ALLTRIM(cA2PJ))) .and. (ALLTRIM(cFilCNPJ) == ALLTRIM(cA2PJ)))
            if ALLTRIM(SB1->B1_CONTA) <> ""
               cContaProd := SB1->B1_CONTA
            EndIf   

            If (Alltrim(SD1->D1_CF) == '1949')
               If (((Alltrim(cContaProd) == '112070001') .or. (Alltrim(cContaProd) == '112070003')) .and. (Alltrim(SD1->D1_COD) <> '13285'))
                  cCtaDeb := "52111519"
               EndIf   

               If (((Alltrim(cContaProd) == '112070002') .or. (Alltrim(cContaProd) == '112070004') .or. (Alltrim(cContaProd) == '112070005')) .or. (Alltrim(SD1->D1_COD) == '13285'))
                  cCtaDeb := "52110715"
               EndIF
            Else
               If (Alltrim(SD1->D1_CF) == '1927')
                  cCtaDeb := "52111531"
               EndIf
            EndIf
	     EndIf
      EndIf
   EndIf
   DbSelectArea("SM0")
   DbSkip()
EndDo

Restarea(_aareaSM0)
EndIf

Return(cCtaDeb)