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
     SC5->(dbSetOrder(1)) //Ordeno no �ndice 1

     If SC5->(dbSeek(xFilial("SC5")+cPedido)) //Localizo o meu pedido
          MatA410(Nil, Nil, Nil, Nil, "A410Altera") //executo a fun��o padr�o MatA410
     EndIf

Else
    FWAlertError("Atendimento n�o tem pedido criado!!!","AGRICOPEL")
EndIf  

Return
