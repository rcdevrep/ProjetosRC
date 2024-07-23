#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function SLAAGR12()  

Local _cNum := ""

_cNum:= (SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)+Subst(SE2->E2_LOJA,2,1)                 


