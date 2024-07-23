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
   
   ElseIf SD2->D2_TP $ "SH"

      cCtaDeb:= "51120205"   

   ElseIf SD2->D2_TP $ "LU"

      cCtaDeb:= "51120217" 

   ElseIf SD2->D2_TP $ "UR"

      cCtaDeb:= "51120218"    
   
   ElseIf SD2->D2_TP == "PA"

      cCtaDeb:= "51120207"   

   ElseIf SD2->D2_TP == "AG"

      cCtaDeb:= "51120206"   

   ElseIf SD2->D2_TP == "QR"

      cCtaDeb:= "51120210"   

   ElseIf SD2->D2_TP == "LO"

      cCtaDeb:= "51120209"   

   ElseIf SD2->D2_TP == "FR"

      cCtaDeb:= "51120213"   

   //Carlos Savio - Chamado 515131 - ALTERAÇÃO DE LANÇAMENTO PADRÃO - Bruna Bassani
   //Precisamos alterar a regra e incluir os seguinte dados - Tipo "IA" - Conta 51210132.
   ElseIf SD2->D2_TP == "IA"

      cCtaDeb:= "51210132"   

   ElseIf SD2->D2_TP == "AE" .AND. SD2->D2_FILIAL == "06" //Carlos Savio - Chamado 606631

      cCtaDeb:= "51120214"   

   ElseIf SD2->D2_TP == "AE" .AND. SD2->D2_FILIAL == "15" //Carlos Savio - Chamado 606631

      cCtaDeb:= "51120216"   


   Endif
   
   DbSkip()

EndDo

Return(cCtaDeb)    

//Centro de Custo Debito LPs 520-001 e 521-001 - Chamado 132535 - Baixa Recebimento Cartão de Crédito
User Function XAG54CC()

PRIVATE cCCDeb:= "1005" 

//Caso seja Uniformes para Agregados grava CC do Almoxarifado Central 

//Carlos Savio - Chamado 469067 - verificar regra LP 520-01 banco 997 uniforme
//Alterado o banco para 997 - If alltrim(SE5->E5_BANCO) == '998' .and. SE5->E5_FILORIG == '14'
If alltrim(SE5->E5_BANCO) == '997' .and. SE5->E5_FILORIG == '14'
   cCCDeb := '6100'
   Return(cCCDeb)
Endif 

DbSelectArea("SD2")
DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA) 
While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA)
    
//-> Agricopel obedecer a seguinte regra: Se o produto for tipo: LU,PA,SH,QR - Centro de Custo 4005 CO - Centro de Custo 5000 
//Conforne pesquisa Tipo de produto Tipo AG iguak a AG - Arla Granel  Arla - Centro de Custo 5104
// chamado 314015 - substituir centro de custo 5104 pelo centro de custo 12001
   
   If SD2->D2_TP $ "LU/PA/SH/QR"

      cCCDeb:= "4005"   
 
   ElseIf SD2->D2_TP == "CO"    
   
      cCCDeb:= "5000" 
   
   ElseIf SD2->D2_TP $ "AG"
                     
      cCCDeb:= "12001"
     
   ElseIf SD2->D2_TP $ "LO"
                     
      cCCDeb:= "4006"
   ElseIf SD2->D2_TP $ "FR"
                     
      cCCDeb:= "6002"
   Endif                 
   
   DbSkip()

EndDo

Return(cCCDeb)


//Centro de Custo Debito LPs 520-009, 521-009, 527-009 e 51A-001 - Chamado 234840 - AJUSTE DE CENTRO DE CUSTO EM PDD
//Provisao PDD
User Function XAG54CP()

PRIVATE cCCDeb:= "1005" 

DbSelectArea("SE1")
DbSetOrder(1)
DbSeek(FIA->FIA_FILIAL+FIA->FIA_PREFIX+FIA->FIA_NUM+FIA->FIA_PARCEL+FIA->FIA_TIPO) 

DbSelectArea("SD2")
DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
//DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SUBSTR(SE1->E1_PREFIXO,3,3)+SE1->E1_CLIENTE+SE1->E1_LOJA) 
//While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+SUBSTR(SE1->E1_PREFIXO,3,3)+E1_CLIENTE+E1_LOJA)
DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA) 

While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA) //Substr(FIA->FIA_PREFIX,1,2)+FIA->FIA_NUM+Padr(Substr(FIA->FIA_PREFIX,3,1),3,"")+Padr(FIA->FIA_CLIENT,6,"")+FIA->FIA_LOJA
    
//Regra PDD chamado Chamado 234840
//gentileza incluir nessa lista o tipo MM: 7004
//LO: 4006 VE: 4006 CO: 5001 FR: 6002 AG: FILIAL DIFERENTE DE 06: 5104 AG: E FILIAL 06: 4000 LU: 4000 SH: 4000 PA: 4000 QR: 4000 
// chamado 314015 - substituir centro de custo 5104 pelo centro de custo 12001

   If SD2->D2_TP == "MM" 
       cCCDeb:= "7004"   
   Endif

   If SD2->D2_TP == "LO" 
       cCCDeb:= "4006"   
   Endif

   If SD2->D2_TP == "VE" 
       cCCDeb:= "4006"   
   Endif

   //Carlos Savio - Chamado 587110 - Ajustar LP de PDD na empresa 01
   If SD2->D2_TP == "CO" .AND. SD2->D2_FILIAL <> "16"   
      cCCDeb:= "5001" 
   Endif      
   
   If SD2->D2_TP == "CO" .AND. SD2->D2_FILIAL == "16"
      cCCDeb:= "5200" 
   Endif
   
   If SD2->D2_TP == "FR"
      cCCDeb:= "6002"
   Endif
     
   If SD2->D2_TP == "AG" .AND. SD2->D2_FILIAL <> "06" 
      cCCDeb:= "12001"
   Endif
   
   If SD2->D2_TP == "AG" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "LU" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "SH" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "PA" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "QR" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 
   
   DbSkip()

EndDo

Return(cCCDeb)  
                    
//Centro de Custo Debito LPs 520-009, 521-009, 527-009 e 51A-001 - Chamado 234840 - AJUSTE DE CENTRO DE CUSTO EM PDD
//Baixa PDD
User Function XAG54CB()

PRIVATE cCCDeb:= "1005" 

DbSelectArea("SD2")
DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

//Ajuste para LP 596 - Estorno PDD
if CT5->CT5_LANPAD == '596'

   nRecSE1 := SE1->(RECNO())
   SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
   SE1->(dbSeek('  '+cPrefixo+cNum+cParcela+cTipoor))
endif

if CT5->CT5_LANPAD == '588'

   nRecSE1 := SE1->(RECNO())
   SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
   SE1->(dbSeek('  '+cPrefixo+cNum+cParcela+cTipoTit))

endif
   
//DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SUBSTR(SE1->E1_PREFIXO,3,3)+SE1->E1_CLIENTE+SE1->E1_LOJA) 
DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA) 



//While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+SE1->E1_SERIE+E1_CLIENTE+E1_LOJA)
While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA) //Substr(FIA->FIA_PREFIX,1,2)+FIA->FIA_NUM+Padr(Substr(FIA->FIA_PREFIX,3,1),3,"")+Padr(FIA->FIA_CLIENT,6,"")+FIA->FIA_LOJA
    
//Regra PDD chamado Chamado 234840
//gentileza incluir nessa lista o tipo MM: 7004
//LO: 4006 VE: 4006 CO: 5001 FR: 6002 AG: FILIAL DIFERENTE DE 06: 5104 AG: E FILIAL 06: 4000 LU: 4000 SH: 4000 PA: 4000 QR: 4000 
// chamado 314015 - substituir centro de custo 5104 pelo centro de custo 12001
   
   If SD2->D2_TP == "MM" 
       cCCDeb:= "7004"   
   Endif

   If SD2->D2_TP == "LO" 
       cCCDeb:= "4006"   
   Endif

   If SD2->D2_TP == "VE" 
       cCCDeb:= "4006"   
   Endif

   //Carlos Savio - Chamado 587110 - Ajustar LP de PDD na empresa 01
   If SD2->D2_TP == "CO" .AND. SD2->D2_FILIAL <> "16"   
      cCCDeb:= "5001" 
   Endif      
   
   If SD2->D2_TP == "CO" .AND. SD2->D2_FILIAL == "16"
      cCCDeb:= "5200" 
   Endif
   
   If SD2->D2_TP == "FR"
      cCCDeb:= "6002"
   Endif
     
   If SD2->D2_TP == "AG" .AND. SD2->D2_FILIAL <> "06" 
      cCCDeb:= "12001"
   Endif
   
   If SD2->D2_TP == "AG" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "LU" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "SH" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "PA" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 

   If SD2->D2_TP == "QR" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= "4000"
   Endif                 
   
   DbSkip()

EndDo

if CT5->CT5_LANPAD == '596' .or. CT5->CT5_LANPAD == '588'
   SE1->(dbGoTo(nRecSE1))
endif

Return(cCCDeb)

//CHAMADO 288535 - AJUSTAR LP DE DESCONTO OBTIDO E CONCEDIDO PARA CONTABILIZAR CENTRO DE CUSTO DO NEGOCIO288535 - AJUSTAR LP DE DESCONTO OBTIDO E CONCEDIDO PARA CONTABILIZAR CENTRO DE CUSTO DO NEGOCIOS
User Function XAG54CR()

PRIVATE cCCDeb:= "1005" 

If alltrim(SE1->E1_TIPO) $'RA'
   cCCDeb:= ""
Endif

DbSelectArea("SD2")
DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
DbSeek(SE1->E1_FILORIG+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA) 
//While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+SE1->E1_PREFIXO+E1_CLIENTE+E1_LOJA)
While !Eof("SD2") .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SE1->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA) //Substr(FIA->FIA_PREFIX,1,2)+FIA->FIA_NUM+Padr(Substr(FIA->FIA_PREFIX,3,1),3,"")+Padr(FIA->FIA_CLIENT,6,"")+FIA->FIA_LOJA

//Regra PDD chamado Chamado 234840
//gentileza incluir nessa lista o tipo MM: 7004
//LO: 4006 VE: 4006 CO: 5001 FR: 6002 AG: FILIAL DIFERENTE DE 06: 5104 AG: E FILIAL 06: 4000 LU: 4000 SH: 4000 PA: 4000 QR: 4000 
   
   If SD2->D2_TP == "MM" 
       cCCDeb:= ""   
   Endif

   If SD2->D2_TP == "LO" 
       cCCDeb:= ""   
   Endif

   If SD2->D2_TP == "VE" 
       cCCDeb:= ""   
   Endif

   If SD2->D2_TP == "CO"    
      cCCDeb:= "" 
   Endif
   
   If SD2->D2_TP == "FR"
      cCCDeb:= ""
   Endif

   //Carlos Savio - Chamado 515131 - ALTERAÇÃO DE LANÇAMENTO PADRÃO - Bruna Bassani
   If SD2->D2_TP == "IA"
      cCCDeb:= ""
   Endif

    If SD2->D2_TP == "UR"
      cCCDeb:= ""
   Endif

   If SD2->D2_TP == "AE" //Carlos Savio - Chamado 606631
      cCCDeb:= ""
   Endif               

     
   If SD2->D2_TP == "AG" .AND. SD2->D2_FILIAL <> "06" 
      cCCDeb:= ""
   Endif
   
   If SD2->D2_TP == "AG" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= ""
   Endif                 

   If SD2->D2_TP == "LU" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= ""
   Endif                 

   If SD2->D2_TP == "SH" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= ""
   Endif                 

   If SD2->D2_TP == "PA" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= ""
   Endif                 

   If SD2->D2_TP == "QR" .AND. SD2->D2_FILIAL == "06" 
      cCCDeb:= ""
   Endif     


   DbSkip()

EndDo

Return(cCCDeb)
