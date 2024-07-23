#INCLUDE "RWMAKE.CH"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR133    ºAutor  ³Deco                º Data ³  29/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Credito lancamento padrao 520-05            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR133()

PRIVATE cCtaCre := SA1->A1_CONTA  

/*
 * Qdo baixa normal credita duplicatas a receber
 */
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Empty(SE1->E1_TIPOLIQ) 
   cCtaCre := SA1->A1_CONTA 
EndIF 

/*
 * Qdo baixa liquidacao correspondente a baixa com cheques credita cfe abaixo dupl a receber
 */
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Alltrim(SE1->E1_TIPOLIQ) = 'CH'
   cCtaCre := SA1->A1_CONTA 
EndIf

/*
 * Qdo baixa cheque proveniente da liquidacao de um titulo com cheque credita caixa
 */
//Onde estiver 112010004 na Agricopel preencher:
//11 Diesel: 112019998
//12 Martendal: 112010003
//15 Petrolium: 112040006
//16 Luparco: 112019998
//Onde estiver 112010003 na Agricopel preencher:
//11 Diesel: 112010002
//12 Martendal: 112010002
//15 Petrolium: 112040007
//16 Luparco: 112010003

If alltrim(SE1->E1_TIPO) == 'CH' .and. alltrim(SE1->E1_NATUREZ) == "101006"

   If SM0->M0_CODIGO == "01"
      cCtaCre := '112010004'   
   ElseIf SM0->M0_CODIGO == "11"
      cCtaCre := '112019998'
   ElseIf SM0->M0_CODIGO == "12"
      cCtaCre := '112010003'
   ElseIf SM0->M0_CODIGO == "15"
      cCtaCre := '112040006'
   ElseIf SM0->M0_CODIGO == "16"
      cCtaCre := '112019998'
   Endif      

Elseif alltrim(SE1->E1_TIPO) == 'CH' .and. alltrim(SE1->E1_NATUREZ) == "101014"

   If SM0->M0_CODIGO == "01"
      cCtaCre := '112010003'   
   ElseIf SM0->M0_CODIGO == "11"
      cCtaCre := '112010002'
   ElseIf SM0->M0_CODIGO == "12"
      cCtaCre := '112010002'
   ElseIf SM0->M0_CODIGO == "15"
      cCtaCre := '112040007'
   ElseIf SM0->M0_CODIGO == "16"
      cCtaCre := '112010003'
   Endif      

EndIf
   
/*
 * Qdo for empresa 44 Posto Farol, 
 */
if cEmpAnt == "44"
   cCtaCre := '110301010'
EndIf              

//Contabilizao RA chamado 71354 e NCC chamado 72441  
if alltrim(SE1->E1_TIPO) $ 'RA/NCC'
   cCtaCre := SA6->A6_CONTA   //Banco 
Endif         


//Chamado[143641] - Boleto p/ devoluções
If alltrim(SE1->E1_TIPO) $ 'NCF'
 
   If SM0->M0_CODIGO == "01"
      cCtaCre := '112040026'   
   ElseIf SM0->M0_CODIGO == "11"
      cCtaCre := '112040002'
   ElseIf SM0->M0_CODIGO == "15"
      cCtaCre := '112040015'
   Endif
   
Endif         



Return(cCtaCre)    