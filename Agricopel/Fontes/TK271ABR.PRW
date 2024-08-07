#include "Protheus.ch"
#include "Topconn.ch"

User Function TK271ABR()

Local lRet := .T.
Local cPedido	:= Alltrim(SUA->UA_NUMSC5)

//If cFilAnt $ GetMV("MV_XFALTPE") .AND. !Empty(cPedido) .AND. Paramixb[1] == 4
If cFilAnt $ SuperGetMV("MV_XFALTPE",.T.,'') .AND. !Empty(cPedido) .AND. Paramixb[1] == 4

     DbSelectArea("SC5")
     SC5->(dbSetOrder(1)) //Ordeno no �ndice 1
     SC5->(dbSeek(xFilial("SC5")+cPedido)) //Localizo o meu pedido
     
    //If  Alltrim(SC5->C5_VEICULO) != '' .AND. (!__cuserid $ GetMV("MV_XUALTPE") .OR. __cuserid != '000000')
    If  Alltrim(SC5->C5_VEICULO) != '' .AND. !(__cuserid $ SuperGetMV("MV_XUALTPE",.T.,'')  .OR. FWIsAdmin(__cuserid) )
        FWAlertError("Pedido com ve�culo preenchido, usu�rio sem acesso a alterar. Verificar com a Logistica." , "TK271ABR")
         lRet := .F.
    EndIf

EndIf  

Return(lRet)
