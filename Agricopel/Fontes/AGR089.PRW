#include "rwmake.ch"

User Function AGR089()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("VALOR,")

/// VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19, NO ARQUIVO E
/// DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DE BARRA VAI O VALOR DO SE2


VALOR :="               "

IF SUBSTR(SE2->E2_CODBAR,1,3) == "   "

    VALOR   :=  STRZERO((SE2->E2_SALDO*100),15,0)

Else

    VALOR  :=  "0" + SUBSTR(SE2->E2_CODBAR,6,14)

Endif

Return(VALOR)