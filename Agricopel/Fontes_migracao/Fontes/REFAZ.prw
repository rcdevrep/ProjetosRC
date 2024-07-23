
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"


User Function REFAZ()

cQuery := " SELECT C6_CLI,C6_LOJA,SUM(C6_PRCVEN*(C6_QTDVEN-C6_QTDENT)) AS TOT "
cQuery += " FROM SC6010, SC5010, SF4010 "
cQuery += " WHERE C6_NFORI = ' ' AND C6_BLQ = ' ' AND C6_QTDENT< C6_QTDVEN AND (C6_QTDEMP > 0) " 
cQuery += " AND C6_NUM = C5_NUM AND C6_CLI = C5_CLIENTE AND C5_LIBEROK = 'S' AND F4_DUPLIC = 'S' AND F4_CODIGO = C6_TES AND F4_FILIAL = C6_FILIAL "
cQuery += " AND C5_CLIENTE = '06518' 
cQuery += " GROUP BY C6_CLI,C6_LOJA "


TCQUERY cQuery NEW ALIAS "TC6"
TCSETFIELD("TC6","TOT","N",12,2)

While !Eof()

dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+TC6->C6_CLI+TC6->C6_LOJA,.F.)
If RecLock("SA1",.F.)
SA1->A1_SALPEDL := TC6->TOT
MsUnLock("SA1")
Endif
EndIf

dbSelectArea("TC6")
dbSkip()
Loop

End

msgstop("Finalizado com Sucesso!!!")

Return