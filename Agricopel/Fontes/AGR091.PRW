#include "rwmake.ch"

User Function AGR091()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_DOC,")

/////  PROGRAMA GRAVAR AS POSICOES DE 374 A 398


DOC  := "                        "

//IF SUBSTR(SEA->EA_MODELO,1,2) == "01"     // Modalidaded 01 = Credito em CC
//   IF SA2->A2_BANCO == "237"
//      DOC  := "                         "
//   Else
//      DOC  := "C00000001                " // Modalidade diferente 01(Credito em CC) sera considerado DOC
//   Endif
//Else
   Doc  :=  SUBSTR(SE2->E2_CODBAR,20,25)  // Sempre sera modalidade de pagamento 31 cfe Fernando 29/08/2006
//EndIf


Return(DOC)