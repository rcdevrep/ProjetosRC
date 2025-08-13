#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

User Function F241BTN()

Local aBotao    := {}


    Aadd(aBotao,{"BUDGET",		{|| ShowVlLiq()},"Ver Total Líquido","Ver Total Líquido"})


Return aBotao




Static Function ShowVlLiq()
Local nVlLiq := 0

    dbselectarea(cAliasSE2)
    dbGoTop()

    While !(cAliasSE2)->( EOF() )
        nVlLiq += (cAliasSE2)->E2_XVLIQ
    (cAliasSE2)->(DbSkip())
    End

    MsgInfo( "Valor Total Líquido: R$ "+Alltrim(Transform(nVlLiq,"@E 999,999,999.99")), "Valor Líquido" )
    
    dbGoTop()

Return
