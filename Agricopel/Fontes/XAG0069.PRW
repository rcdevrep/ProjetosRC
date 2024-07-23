#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XAG0069  ºAutor  ³Osmar Schimitberger  º Data ³  16/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa p/Debito LP 610-003                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Agricopel                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XAG0069()
Local _cFilial := cFilAnt

PRIVATE cCtaDeb:= "52111904"
 
/*If SB1->B1_TIPO=="MK"
   cCtaDeb:="51210122" (ALTERADO PARA ATENDER AO CHAMADO 896706)
Endif
*/
If _cFilial == "06" .AND. SB1->B1_TIPO == "MK"
	If !Empty(SB1->B1_CTADESP)
		cCtaDeb := SB1->B1_CTADESP
	Else
		cCtaDeb := "51210122"
	EndIf
ElseIF _cFilial <> "06" .AND. SB1->B1_TIPO == "MK"
 
	cCtaDeb := "51210122"
EndIf	

If SB1->B1_TIPO$"SH"
   cCtaDeb:="51210105"
Endif

If SB1->B1_TIPO$"LU"
   cCtaDeb:="51210102"
Endif

If SB1->B1_TIPO$"UR"
   cCtaDeb:="51210134"
Endif

If SB1->B1_TIPO=="AG"
   cCtaDeb:= "51210106"
Endif

If SB1->B1_TIPO=="PA"
   cCtaDeb:="51210107"
Endif

If SB1->B1_TIPO=="VE"
   cCtaDeb:= "51210108"
Endif

If SB1->B1_TIPO=="LO"
   cCtaDeb:= "51210109"
Endif

If SB1->B1_TIPO=="MM"
   cCtaDeb:= "51210120"
Endif

//Chamado 421146 - LP 610-003 BONIFICAÇÃO SAIDAS - Thaiara
//Gentileza alterar a regra para a CTA DEBITO do LP 610-003 e incluir o tipo AE: 51210123 e o tipo QR: 51210110                       
  
If SB1->B1_TIPO=="QR"
   cCtaDeb:= "51210110"
Endif

If SB1->B1_TIPO=="AE"
   cCtaDeb:= "51210123"
Endif

//Carlos Savio - Chamado 515131 - ALTERAÇÃO DE LANÇAMENTO PADRÃO - Bruna Bassani
//Precisamos alterar a regra e incluir os seguinte dados - Tipo "IA" - Conta 51210132

If SB1->B1_TIPO=="IA"
   cCtaDeb:= "51210132"
Endif

Return(cCtaDeb)    
