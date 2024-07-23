#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

User Function AGR146()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AGR146   ³ Autor ³ DECO                  ³ Data ³ 29/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho DE CEPS Fornecedores                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a AGRICOPEL/MIME                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
LOCAL xRetu   := &(ReadVar()), aSegSA2 := SA2->(GetArea())
LOCAL cCep    := ''

cCep := M->A2_CEP

DbSelectArea("SZT")
DbSetOrder(1)
If dbSeek(xFilial("SZT")+cCep)
   If Alltrim(SZT->ZT_ENDEREC) <> alltrim(SZT->ZT_CIDADE)
	   M->A2_END := SZT->ZT_ENDEREC
   Endif
   M->A2_MUN    := SZT->ZT_CIDADE
   M->A2_EST    := SZT->ZT_UF
   M->A2_BAIRRO := SZT->ZT_BAIRRO
Endif   

RestArea(aSegSA2)
//SysRefresh() // Comentado Deco 04/01/2006

Return cCep       // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

