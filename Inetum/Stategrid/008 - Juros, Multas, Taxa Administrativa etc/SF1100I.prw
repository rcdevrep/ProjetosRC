//Bibliotecas
#Include "TOTVS.ch"

 
User Function SF1100I()
    Local aArea := GetArea()
 
    //Se a vari�vel p�blica existir
    If Type("_cCamNovo1") != "U"
 
        //Grava o conte�do na SF1
        RecLock("SF1", .F.)
            SF1->F1_XMULTA := _cCamNovo1
            SF1->F1_XJUROS := _cCamNovo2
        SF1->(MsUnlock())
    EndIf
 
    RestArea(aArea)
Return
