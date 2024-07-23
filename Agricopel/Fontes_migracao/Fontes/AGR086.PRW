#include "rwmake.ch"

User Function AGR086()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("RETCAR,")

////  PROGRAMA PARA SELECIONAR A CARTEIRA NO CODIGO DE BARRAS QUANDO
////  NAO TIVER TEM QUE SER COLOCADO "00"


 
IF SUBS(SE2->E2_CODBAR,01,3) == "237"
   //invertido cfe orientacao do sr paulo do bradesco
   Retcar := "0" + SUBS(SE2->E2_CODBAR,24,2)   
   //Retcar := "000"
Else
   //Retcar := "0" + SUBS(SE2->E2_CODBAR,24,2)   
   Retcar := "000"
EndIf

Return(Retcar)