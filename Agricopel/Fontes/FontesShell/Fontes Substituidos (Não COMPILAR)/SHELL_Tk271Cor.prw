#include "TOTVS.CH"
#include "topconn.ch"

User Function Tk271Cor(cPasta)

Local aArea  := GetArea()
Local aCores := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza status dos registros do cabeçalho do Call Center³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "UPDATE SUA "
cQuery += "SET UA_STATUS = (CASE WHEN C5_BLQ = '' THEN 'LIB' ELSE 'SUP' END) "
cQuery += "FROM "+RetSqlName("SUA")+ " AS SUA, "+RetSqlName("SC5")+ " AS SC5 (NOLOCK) "
cQuery += "WHERE SUA.D_E_L_E_T_ = '' AND SC5.D_E_L_E_T_ = '' "
cQuery += "  AND UA_FILIAL = '"+xFilial("SUA")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery += "  AND UA_NUMSC5 = C5_NUM "
cQuery += "  AND UA_OPER = '1' AND UA_DOC = '' "
cQuery += "  AND UA_EMISSAO >= '"+DtoS(dDataBase-30)+"' "
TCSQLExec(cQuery)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a regra para legenda.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPasta == '2' //Televendas
   aCores    := { {' VAL(SUA->UA_OPER) == 1 .AND. AllTrim(SUA->UA_STATUS) == "NF." ' , 'BR_VERMELHO'   },;
                  {' VAL(SUA->UA_OPER) == 1 .AND. AllTrim(SUA->UA_STATUS) == "SUP" ' , 'BR_AZUL'   },;
                  {' VAL(SUA->UA_OPER) == 1 .AND. AllTrim(SUA->UA_STATUS) == "LIB" ' , 'BR_AMARELO'   },;
                  {' VAL(SUA->UA_OPER) == 2 ' , 'BR_VERDE'   },;
                  {' VAL(SUA->UA_OPER) == 3 ' , 'BR_MARRON' },;
                  {'(!EMPTY(SUA->UA_CODCANC))', 'BR_PRETO'  }}
EndIf

RestArea(aArea)

Return(aCores)