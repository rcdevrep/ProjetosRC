#include "rwmake.ch"

User Function AGR253()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CGC,")

/////  PROGRAMA PARA SEPARAR BUSCAR O CGC CORRETO DA CONTA CORRENTE COM BASE NO PERFIL DEVIDO FINANCEIRO SER 
/////  COMPARTILHADO E NAO BUSCAR CORRETAMENTE SM0
////   PAGFOR - POSICOES ( 11 - 25 ) 

IF Alltrim(SEE->EE_CODEMP) == '79459' // Agricopel Matriz - CC 27720
   CGC  :=  '081632093000179'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '101258' // Agricopel Base - CC 52922
   CGC  :=  '081632093000411'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '101259' // Mime Distrib - CC 42849
   CGC  :=  '001799935000142'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '40455' // Posto Mime Matriz - CC 10277
   CGC  :=  '083488882000103'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '101260' // Posto Mime - CC 30861
   CGC  :=  '083488882000456'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '159491' // Agricopel Diesel Parana
   CGC  :=  '008091710000186'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '0004743271' // Petrolium Combustiveis - CC 00441244
   CGC  :=  '00179490000135'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '0004901245' // Luparco Distribuidora - CC 00002011
   CGC  :=  '23926167000183'
EndIf
IF Alltrim(SEE->EE_CODEMP) == '0000315539' // Posto Farol - CC 3769
   CGC  :=  '03991286000102'
EndIf

IF Alltrim(SEE->EE_CODEMP) == '321123' // PETROLIUM COMBUSTIVEIS LTDA - CC  44124-4 
   CGC  :=  '000179490000135'
EndIf

IF Alltrim(SEE->EE_CODEMP) == '????' // LUPARCO DISTRIBUIDORA LTDA - CC  201-1
   CGC  :=  '023926167000183'
EndIf

Return(CGC)