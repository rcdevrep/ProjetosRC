#include "rwmake.ch"

User Function AGR087()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("RETANO,")

////  PROGRAMA PARA SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB QUANDO NAO
////  NAO TIVER TEM QUE SER COLOCADO "00"

 
/*IF SUBS(SE2->E2_CODBAR,01,3) == "237"
   RETANO := "000"
Else
   RETANO := "0" + SUBS(SE2->E2_CODBAR,26,2)
EndIf*/
//ALTERADO POR ALEXANDRE CONFORME ORIENTACAO DO SR PAULO DO BRADESCO
IF SUBS(SE2->E2_CODBAR,01,3) == "237"
   RETANO := "0" + SUBS(SE2->E2_CODBAR,26,2)
Else
   RETANO := "000"   
EndIf

Return(RETANO)
