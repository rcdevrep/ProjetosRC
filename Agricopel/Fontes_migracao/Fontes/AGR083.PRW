#include "rwmake.ch"

User Function AGR083()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("BANCO,")

/////  PROGRAMA PARA SEPARAR O BANCO DO FORNECEDOR
//// PAGFOR - POSICOES ( 96 - 98 )        


If trim(SE2->E2_TIPO) == "OP"         
   BANCO  :=  STRZERO(VAL(SE2->E2_BCOPG),3) 
   Return(BANCO)
EndIf


BANCO  :=  SUBSTR(SE2->E2_CODBAR,1,3)

IF SUBSTR(SE2->E2_CODBAR,1,3) == "   "
   //ALTERADO POR ALEXANDRE PARA BUSCAR PRIMEIRO A AGENCIA DO TITULO,CASO ESTEJA VAZIO BUSCA DO FORNECEDOR
   IF !EMPTY(SE2->E2_BCOPG)          
       BANCO  :=  STRZERO(VAL(SE2->E2_BCOPG),3) 
   ELSE    
       BANCO  :=  STRZERO(VAL(SA2->A2_BANCO),3)
   ENDIF    
Else
   BANCO  :=  SUBSTR(SE2->E2_CODBAR,1,3)
EndIf

Return(BANCO)