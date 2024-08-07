#include "rwmake.ch"

User Function AGR084()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("AGENCIA,RETDIG,DIG1,DIG2,DIG3,DIG4")
SetPrvt("MULT,RESUL,RESTO,DIGITO,")

/////  PROGRAMA PARA SEPARAR A AGENCIA DO CODIGO DE BARRA PARA O PROGRAMA DO
/////  PAGFOR - POSICOES ( 99 - 104 )

 
Agencia := "000000" 

If trim(SE2->E2_TIPO) == "OP"         
   Agencia := STRZERO(VAL(SE2->E2_AGPAG),6) 
   Return(Agencia)
EndIf

IF SUBSTR(SE2->E2_CODBAR,1,3) == "237"
   Agencia  :=  "0" + SUBSTR(SE2->E2_CODBAR,20,4)

   RETDIG := " "
   DIG1   := SUBSTR(SE2->E2_CODBAR,20,1)
   DIG2   := SUBSTR(SE2->E2_CODBAR,21,1)
   DIG3   := SUBSTR(SE2->E2_CODBAR,22,1)
   DIG4   := SUBSTR(SE2->E2_CODBAR,23,1)

   MULT   := (VAL(DIG1)*5) +  (VAL(DIG2)*4) +  (VAL(DIG3)*3) +   (VAL(DIG4)*2)
   RESUL  := INT(MULT /11 )
   RESTO  := INT(MULT % 11)
   DIGITO := 11 - RESTO

   RETDIG := IF( RESTO == 0,"0",IF(RESTO == 1,"0",ALLTRIM(STR(DIGITO))))

   Agencia:= Agencia + RETDIG
Else
   If SUBSTR(SE2->E2_CODBAR,1,3) == "   "
//      Agencia := STRZERO(VAL(SA2->A2_AGENCIA),4) + SUBSTR(SA2->A2_AGENCIA,4,1)
      //TRATAMENTO DO CAMPO AGENCIA BUSCANDO DO CONTAS A PAGAR, CASO ESTEJA VAZIO BUSCA DO CADASTRO DE FORNEC.
      IF !EMPTY(SE2->E2_AGPAG)                    
         Agencia := STRZERO(VAL(SE2->E2_AGPAG),6)
      ELSE  
         Agencia := STRZERO(VAL(SA2->A2_AGENCIA),6)
      ENDIF  
   Else
      Agencia := "000000"
   Endif
EndIf

Return(Agencia)