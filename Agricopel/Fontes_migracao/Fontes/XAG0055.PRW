#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XAG0055  ºAutor  ³Osmar Schimitberger  º Data ³  17/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa p/Debito LPs 531-003/531-007 - Credito LP 530-003º±±
±±º          ³  530-007/532-003 e 532-007                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Agricopel                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XAG0055()

PRIVATE cCtaCre:= "55110102" 

DbSelectArea("SD1")
DbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
DbSeek(SE2->E2_FILORIG+SE2->E2_NUM+SUBSTR(SE2->E2_PREFIXO,3,1)+SPACE(2)+SE2->E2_FORNECE+SE2->E2_LOJA) 
While !Eof("SD1") .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SE2->(E2_FILORIG+E2_NUM+SUBSTR(E2_PREFIXO,3,1)+SPACE(2)+E2_FORNECE+E2_LOJA)   
             
   //CO: 51220101
   //LU: 51220105
   //SH: 51220105
   //PA: 51220107
   //AG: 51220106
   //QR: 51220110
   //LO: 51220109

   If SD1->D1_TP == "CO"    
   
      cCtaCre:= "51220101" 
   
   ElseIf SD1->D1_TP $ "LU/SH"

      cCtaCre:= "51220105"
         
   ElseIf SD1->D1_TP == "PA"

      cCtaCre:= "51220107"
      
   ElseIf SD1->D1_TP == "AG"

     cCtaCre:= "51220106"
 
   ElseIf SD1->D1_TP == "QR"

     cCtaCre:= "51220110"
 
   ElseIf SD1->D1_TP == "LO"
 
     cCtaCre:= "51220109"
   
   Endif
   
   DbSkip()  

EndDo

Return(cCtaCre)    