#include "rwmake.ch"

User Function AGR082()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("BENEFICIARIO")


/////  PROGRAMA PARA SEPARAR o NOME DO BENEFICIARIO
/////  PAGFOR - POSICOES ( 18 - 047 )

 
Beneficiario := " "

IF !EMPTY(SE2->E2_BENEF)
   Beneficiario := SUBSTR(SE2->E2_BENEF,1,30)
Else
   Beneficiario := SUBSTR(SA2->A2_NOME,1,30)
EndIf

Return(Beneficiario)