#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XAG0054   ºAutor  ³Osmar Schimitberger  º Data ³  17/07/2019º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa p/Debito LPs 520-003/521-003 - Credito LP 527-003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Agricopel                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XAG0054()

PRIVATE cCtaDeb:= "55110201" 

DbSelectArea("SD2")
DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA) 
While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA)
    
    //CO: 51120201
    //LU: 51120205
    //SH: 51120205
    //PA: 51120207
    //AG: 51120206
    //QR: 51120210
    //LO: 51120209
    //FR: 51120213   
   
   If SD2->D2_TP == "CO"    
   
      cCtaDeb:= "51120201" 
   
   ElseIf SD2->D2_TP $ "LU/SH"

      cCtaDeb:= " 51120205"   
   
   ElseIf SD2->D2_TP == "PA"

      cCtaDeb:= " 51120207"   

   ElseIf SD2->D2_TP == "AG"

      cCtaDeb:= " 51120206"   

   ElseIf SD2->D2_TP == "QR"

      cCtaDeb:= " 51120210"   

   ElseIf SD2->D2_TP == "LO"

      cCtaDeb:= " 51120209"   

   ElseIf SD2->D2_TP == "FR"

      cCtaDeb:= " 51120213"   

   Endif
   
   DbSkip()

EndDo

Return(cCtaDeb)    

//Centro de Custo Debito LPs 520-001 e 521-001 - Chamado 132535 - Baixa Recebimento Cartão de Crédito
User Function XAG54CC()

PRIVATE cCCDeb:= "1098" 

DbSelectArea("SD2")
DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA) 
While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA)
    
//-> Agricopel obedecer a seguinte regra: Se o produto for tipo: LU,PA,SH,QR - Centro de Custo 4005 CO - Centro de Custo 5000 
//Conforne pesquisa Tipo de produto Tipo AG iguak a AG - Arla Granel  Arla - Centro de Custo 5104
   
   If SD2->D2_TP $ "LU/PA/SH/QR"

      cCCDeb:= "4005"   
 
   ElseIf SD2->D2_TP == "CO"    
   
      cCCDeb:= "5000" 
   
   ElseIf SD2->D2_TP $ "AG"
                     
      cCCDeb:= "5104"
     
   Endif
   
   DbSkip()

EndDo

Return(cCCDeb)    