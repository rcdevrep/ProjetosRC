#include 'protheus.ch'
#include 'PRTOPDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XAG0068   ºAutor  ³Osmar Schimitberger º Data ³  25/06/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Credito - LP 650-009-entradas de bonificaçãoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Agricopel                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XAG0068()

	Private cCtaCre:= "52111923"
                   
    If SB1->B1_TIPO=="CO"
       
       cCtaCre:= "51210101"
       
    Endif   
       
    If SB1->B1_TIPO$"SH"
    
       cCtaCre:= "51210105"
    
    Endif

   If SB1->B1_TIPO$"LU"
    
       cCtaCre:= "51210102"
    
    Endif
    
    If SB1->B1_TIPO$"UR"
    
       cCtaCre:= "51210134"
    
    Endif
    
    If SB1->B1_TIPO=="AG"
    
       cCtaCre:= "51210106"
       
    Endif   
    
    If SB1->B1_TIPO=="PA"
    
       cCtaCre:= "51210107"
       
    Endif   
       
    If SB1->B1_TIPO=="VE"
    
       cCtaCre:= "51210108"
    
    Endif
    
    If SB1->B1_TIPO=="LO"
    
       cCtaCre:= "51210118"
    
    Endif
    
    If SB1->B1_TIPO=="MM"
    
       cCtaCre:= "51210120"
       
    Endif
    
    // gentileza acrescentar tipo QR: 51210110, MK: 51210122, AE: 51210123  E quando o b1_tipo não for nenhum destes a conta será 52111923
   
    If SB1->B1_TIPO=="QR"
    
       cCtaCre:= "51210110"
       
    Endif
   
    If SB1->B1_TIPO=="MK"
    
       cCtaCre:= "51210122"
       
    Endif
    
    If SB1->B1_TIPO=="AE"
    
       cCtaCre:= "51210123"
       
    Endif

   //Carlos Savio - Chamado 515131 - ALTERAÇÃO DE LANÇAMENTO PADRÃO - Bruna Bassani
   //Precisamos alterar a regra e incluir os seguinte dados - Tipo "IA" - Conta 51210132.

    If SB1->B1_TIPO=="IA"
    
       cCtaCre:= "51210132"
       
    Endif
Return(cCtaCre)
