#include "rwmake.ch"

User Function AGR088()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("RETNOS,")

//// RETORNA O NOSSO NUMERO QUANDO COM VALOR NO E2_CODBAR, E ZEROS QUANDO NAO
//// TEM VALOR POSICAO ( 142 - 150 )


/*IF SUBS(SE2->E2_CODBAR,01,3) == "237"
    RETNOS := "000000000"
Else
    RETNOS := SUBS(SE2->E2_CODBAR,28,9)
EndIf*/

//ALTERADO POR ALEXANDRE CONFORME ORIENTACAO DO SR PAULO DO BRADESCO
IF SUBS(SE2->E2_CODBAR,01,3) == "237"
    RETNOS := SUBS(SE2->E2_CODBAR,28,9)    
Else
    RETNOS := "000000000"
EndIf


Return(RETNOS)