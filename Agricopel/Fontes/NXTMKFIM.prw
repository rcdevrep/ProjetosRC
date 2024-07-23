#include "Protheus.ch"
#include "Topconn.ch"

User Function NXTMKFIM()

Local lRet := .T.
Local cPedido	:= Alltrim(SUA->UA_NUMSC5)



     DbSelectArea("SC5")
     SC5->(dbSetOrder(1)) //Ordeno no índice 1
     SC5->(dbSeek(xFilial("SC5")+cPedido)) //Localizo o meu pedido
     
    Reclock("SC5",.F.)
        SC5->C5_XNRTRAN := SUA->UA_XNRTRAN
    MsUnlock("SC5")


Return(lRet)
