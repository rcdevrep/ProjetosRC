#include "rwmake.ch"

User Function AGR090()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_AMODEL,")

/////  PROGRAMA PARA INDICAR A MODALIDADE DO PAGAMENTO POS.264-265

 
IF SUBSTR(SEA->EA_MODELO,1,2) == "01"
   If SA2->A2_BANCO  =="237"
      aModel := "01"
   Else
      aModel := "03"
   Endif
Else
   aModel := SUBSTR(SEA->EA_MODELO,1,2)
EndIf

Return(aModel)
