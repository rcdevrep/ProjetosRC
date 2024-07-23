#INCLUDE "RWMAKE.CH"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR136    ºAutor  ³Deco                º Data ³  29/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Debito lancamento padrao 527-05             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR136()

PRIVATE cCtaDeb:= SA1->A1_CONTA

//*
//* Qdo Cancelamento baixa normal Debita duplicatas a receber
//*
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Empty(SE1->E1_TIPOLIQ)
   cCtaDeb := SA1->A1_CONTA 
Endif

//*
//* Qdo Cancelamento baixa liquidacao correspondente a baixa com cheques Debita cfe abaixo dupl a receber
//*
If alltrim(SE1->E1_TIPO) <> 'CH' .and. Alltrim(SE1->E1_TIPOLIQ) = 'CH'
   cCtaDeb := SA1->A1_CONTA 
EndIf

//*
//* Qdo Cancelamento baixa cheque proveniente da liquidacao de um titulo com cheque Debita caixa
//*

If alltrim(SE1->E1_TIPO) == 'CH' .and. alltrim(SE1->E1_NATUREZ) == "101006"
   
   If SM0->M0_CODIGO == "01"
      cCtaDeb := '112010004'   
   ElseIf SM0->M0_CODIGO == "11"
      cCtaDeb := '112019998'
   ElseIf SM0->M0_CODIGO == "12"
      cCtaDeb := '112010003'
   ElseIf SM0->M0_CODIGO == "15"
      cCtaDeb := '112040006'
   ElseIf SM0->M0_CODIGO == "16"
      cCtaDeb := '112019998'
   Endif      

Elseif alltrim(SE1->E1_TIPO) == 'CH' .and. alltrim(SE1->E1_NATUREZ) == "101014"
   
   If SM0->M0_CODIGO == "01"
      cCtaDeb := '112010003'   
   ElseIf SM0->M0_CODIGO == "11"
      cCtaDeb := '112010002'
   ElseIf SM0->M0_CODIGO == "12"
      cCtaDeb := '112010002'
   ElseIf SM0->M0_CODIGO == "15"
      cCtaDeb := '112040007'
   ElseIf SM0->M0_CODIGO == "16"
      cCtaDeb := '112010003'
   Endif      

EndIf
                          
//Contabilizao RA chamado 71354 e NCC chamado 72441  
if alltrim(SE1->E1_TIPO) $ 'RA/NCC'
   cCtaDeb := SA6->A6_CONTA   //Banco 
Endif            


//Chamado[143641] - Boleto p/ devoluções
If alltrim(SE1->E1_TIPO) $ 'NCF'
 
   If SM0->M0_CODIGO == "01"
      cCtaDeb := '112040026'   
   ElseIf SM0->M0_CODIGO == "11"
      cCtaDeb := '112040002'
   ElseIf SM0->M0_CODIGO == "15"
      cCtaDeb := '112040015'
   Endif
   
Endif  
	
Return(cCtaDeb)