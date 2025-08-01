User Function F340LIBT()

Local lRet  := .T.
Local aArea

    If AllTrim(FunName(0)) == "RPC"

        aArea := GetArea()

        SF1->(DBSetOrder(1))
        
        If SF1->(DBSeek(SE2->(E2_FILIAL+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA))) .And. SF1->F1_XCELNF == "S"
            lRet:= .F.
        EndIF

        RestArea(aArea)

    EndIf

Return lRet
