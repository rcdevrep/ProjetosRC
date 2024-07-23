#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

User Function AGR059()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CONTA,LABORTPRINT,LEND,BBLOCO,CITEM,CSEQUEN")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/09/00 ==>    #DEFINE PSAY SAY
#ENDIF
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � MSG Cliente/loja Inativo� Deco        � Data �Wed  28/07/03 ��
�������������������������������������������������������������������������͹��
���Descri��o � Mensagem de aviso se cliente/loja inativo                  ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico para clientes Microsiga                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
