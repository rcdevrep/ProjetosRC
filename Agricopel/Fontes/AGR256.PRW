#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function AGR256()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("VALOR,nAbat")

/// VALOR DO PAGAMENTO DO SE2 CONSIDERANDO TAMBEM ABATIMENTO SE TIVER      
/// DA POSICAO 205 - 219   

// Este programa Não em uso pois o SOMAVALOR() que esta no trailler do lay-out do Bradesco (Bradesco.cpe) 
// não considera AB- no calculo da soma a pagar total   22/09/2006

nAbat    := 0                

cPrefixo := SE2->E2_PREFIXO
cNum     := SE2->E2_NUM  
cParcela := SE2->E2_PARCELA
cTipo    := 'AB-'         
cFornece := SE2->E2_FORNECE
cLoja    := SE2->E2_LOJA    
dEmissao := SE2->E2_EMISSAO
dVencto  := SE2->E2_VENCTO 
          
cQuery := ""
cQuery := "SELECT SUM(E2_SALDO) AS ABAT "
cQuery += "FROM " + RetSqlName("SE2") + " (NOLOCK) "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND E2_FILIAL   = '" + xFilial("SE2")   + "' "
cQuery += "AND E2_PREFIXO  = '" + cPrefixo         + "' "
cQuery += "AND E2_NUM      = '" + cNum             + "' "
cQuery += "AND E2_PARCELA  = '" + cParcela         + "' "
cQuery += "AND E2_TIPO     = '" + cTipo            + "' "
cQuery += "AND E2_FORNECE  = '" + cFornece         + "' "
cQuery += "AND E2_LOJA     = '" + cLoja            + "' "
cQuery += "AND E2_EMISSAO  = '" + Dtos(dEmissao)   + "' "
cQuery += "AND E2_VENCTO   = '" + Dtos(dVencto)    + "' "

If Select("MSE2") <> 0
   dbSelectArea("MSE2")
   dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MSE2"
TCSetField("MSE2","E2_EMISSAO","D",08,0)
TCSetField("MSE2","E2_VENCTO" ,"D",08,0)

dbSelectArea("MSE2")
dbGoTop()
While !Eof()  
   nAbat  := MSE2->ABAT 

   DbSelectArea("MSE2")
   MSE2->(DbSkip())			
EndDo


VALOR :="               "

VALOR :=  STRZERO(((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE-nAbat)*100),15,0)


Return(VALOR)