#include "rwmake.ch"

User Function AGR254()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("RAZAO,")

/////  PROGRAMA PARA SEPARAR BUSCAR A RAZAO CORRETA DA CONTA CORRENTE COM BASE NO PERFIL DEVIDO FINANCEIRO SER 
/////  COMPARTILHADO E NAO BUSCAR CORRETAMENTE SM0
////   PAGFOR - POSICOES ( 26 - 65 )

 

IF Alltrim(SEE->EE_CODEMP) == '79459' // Agricopel Matriz - CC 27720
   RAZAO  :=  'AGRICOPEL COM. DERIV. DE PETROLEO LTDA  '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '101258' // Agricopel Base - CC 52922
   RAZAO  :=  'AGRICOPEL COM. DERIV. DE PETROLEO LTDA  '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '101259' // Mime Distrib - CC 42849
   RAZAO  :=  'MIME DISTRIBUIDORA DE PETROLEO LTDA     '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '40455' // Posto Mime Matriz - CC 10277
   RAZAO  :=  'POSTO MIME LTDA                         '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '101260' // Posto Mime - CC 30861
   RAZAO  :=  'POSTO MIME LTDA                         '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '159491' // Agricopel Diesel Parana - CC 00002305
   RAZAO  :=  'AGRICOPEL DIESEL PARANA LTDA            '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '0004743271' // Petrolium Combustiveis - CC 00441244
   RAZAO  :=  'PETROLIUM COMBUSTIVEIS LTDA             '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '0004901245' // Luparco Distribuidora - CC 00002011
   RAZAO  :=  'LUPARCO DISTRIBUIDORA LTDA              '
EndIf
IF Alltrim(SEE->EE_CODEMP) == '0000315539' // Posto Farol - CC 3769
   RAZAO  :=  'POSTO NAUTICO FAROL LTDA                '
EndIf

IF Alltrim(SEE->EE_CODEMP) == '321123' // PETROLIUM COMBUSTIVEIS LTDA - CC  44124-4 
   RAZAO  :=  'PETROLIUM COMBUSTIVEIS LTDA             '
EndIf

IF Alltrim(SEE->EE_CODEMP) == '??????' // LUPARCO DISTRIBUIDORA LTDA  - CC  201-1
   RAZAO  :=  'LUPARCO DISTRIBUIDORA LTDA              '
EndIf

Return(RAZAO)