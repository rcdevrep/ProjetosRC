#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

User Function AGR059()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CONTA,LABORTPRINT,LEND,BBLOCO,CITEM,CSEQUEN")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/09/00 ==>    #DEFINE PSAY SAY
#ENDIF
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튔un뇙o    � MSG Cliente/loja Inativo� Deco        � Data 쿥ed  28/07/03 굇
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒escri뇙o � Mensagem de aviso se cliente/loja inativo                  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Espec죉ico para clientes Microsiga                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
SA1->(DbSetOrder(1))               // filial+cliente+loja
*
* Mensagem cliente/loja inativo
*                                                 
IF !EMPTY(M->C5_CLIENTE) .AND.;
   !EMPTY(M->C5_LOJACLI)
   SELE SA1
   DBSEEK(xfilial('SA1')+M->C5_CLIENTE+M->C5_LOJACLI)
   IF FOUND()
      IF SA1->A1_SITUACA = '2'
         Msgstop('ATENCAO! Cliente/loja Inativo'+SA1->A1_COD+'/'+SA1->A1_LOJA)
      ENDIF
   ENDIF
ENDIF

// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==> __RETURN()
Return(M->C5_CLIENTE)        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
