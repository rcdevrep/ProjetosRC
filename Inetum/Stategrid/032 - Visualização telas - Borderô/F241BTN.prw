#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

User Function F241BTN()

Local aBotao    := {}


    Aadd(aBotao,{"BUDGET",		{|| ShowVlLiq()},"Ver Total L�quido","Ver Total L�quido"})


Return aBotao




Static Function ShowVlLiq()
Local nVlLiq := 0

    dbselectarea(cAliasSE2)
    dbGoTop()

    While !(cAliasSE2)->( EOF() )
        nVlLiq += (cAliasSE2)->E2_XVLIQ
    (cAliasSE2)->(DbSkip())
    End

    MsgInfo( "Valor Total L�quido: R$ "+Alltrim(Transform(nVlLiq,"@E 999,999,999.99")), "Valor L�quido" )
    
    dbGoTop()

Return
