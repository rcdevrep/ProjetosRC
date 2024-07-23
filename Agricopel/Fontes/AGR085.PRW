#include "rwmake.ch"

User Function AGR085()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CTACED,RETDIG,DIG1,DIG2,DIG3,DIG4")
SetPrvt("DIG5,DIG6,DIG7,MULT,RESUL,RESTO")
SetPrvt("DIGITO,")

/////  PROGRAMA PARA SEPARAR A C/C DO CODIGO DE BARRA PARA O PROGRAMA DO
/////  PAGFOR - POSICOES ( 105 - 119 )
                                      
CTACED := "0000000000000"            

If trim(SE2->E2_TIPO) # "OP"                         
                                                             
IF SUBSTR(SE2->E2_CODBAR,1,3) == "237"
    Ctaced  :=  STRZERO(VAL(SUBSTR(SE2->E2_CODBAR,37,7)),13,0)
    
    RETDIG := " "
    DIG1   := SUBSTR(SE2->E2_CODBAR,37,1)
    DIG2   := SUBSTR(SE2->E2_CODBAR,38,1)
    DIG3   := SUBSTR(SE2->E2_CODBAR,39,1)
    DIG4   := SUBSTR(SE2->E2_CODBAR,40,1)
    DIG5   := SUBSTR(SE2->E2_CODBAR,41,1)
    DIG6   := SUBSTR(SE2->E2_CODBAR,42,1)
    DIG7   := SUBSTR(SE2->E2_CODBAR,43,1)
    
    MULT   := (VAL(DIG1)*2) +  (VAL(DIG2)*7) +  (VAL(DIG3)*6) +   (VAL(DIG4)*5) +  (VAL(DIG5)*4) +  (VAL(DIG6)*3)  + (VAL(DIG7)*2)
    RESUL  := INT(MULT /11 )
    RESTO  := INT(MULT % 11)
    DIGITO := STRZERO((11 - RESTO),1,0)

    RETDIG := IF( resto == 0,"0",IF(resto == 1,"P",DIGITO))

    Ctaced := Ctaced + RETDIG
Else
    IF SUBSTR(SE2->E2_CODBAR,1,3) == "   "
       //ALTERADO POR ALEXANDRE PARA BUSCAR A CC DO SE2, CASO ESTEJA VAZIO BUSCA DO SA2
       IF !EMPTY(SE2->E2_CCPAG)
          Ctaced  := STRZERO(VAL(SUBSTR(SE2->E2_CCPAG,1,08)),13,0)+SUBSTR(SE2->E2_CCPAG,09,2)
       ELSE
          Ctaced  := STRZERO(VAL(SUBSTR(SA2->A2_NUMCON,1,08)),13,0)+SUBSTR(SA2->A2_NUMCON,09,2)
       ENDIF   
    Else
       Ctaced  := "000000000000000"
    Endif
EndIf
                      
EndIf
Return(Ctaced) 