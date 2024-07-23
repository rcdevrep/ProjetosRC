//Bibliotecas
#Include "Protheus.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | Fonte.:  XAG0087                                                                                             |
 | Desc:  Relacionar RA com Pedido de venda                                                                     |
 | Autor: GroundWork                                                                                            |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function XAG0087

Local cPedido	:= Alltrim(SUA->UA_NUMSC5)

If !Empty(cPedido)

     SETFUNNAME("MATA410")
     DbSelectArea("SC5")
     SC5->(dbSetOrder(1)) //Ordeno no índice 1

     If SC5->(dbSeek(xFilial("SC5")+cPedido)) //Localizo o meu pedido
          MatA410(Nil, Nil, Nil, Nil, "A410Altera") //executo a função padrão MatA410
     EndIf

Else
    FWAlertError("Atendimento não tem pedido criado!!!","AGRICOPEL")
EndIf  

Return
