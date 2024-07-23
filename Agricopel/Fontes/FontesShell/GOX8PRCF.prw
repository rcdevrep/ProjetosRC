#INCLUDE "PROTHEUS.CH"

User Function GOX8PRCF()

    Local cAli := PARAMIXB[1]
    Local cQuery := ""
    Local cTmp
    Local cRet := "Não Gerado"
    
    cQuery := " SELECT * FROM " + RetSqlName("ZZK") + " ZZK "
    cQuery += " INNER JOIN " + RetSqlName("ZZI") + " ZZI ON ZZI.ZZI_FILIAL = ZZK.ZZK_FILIAL AND ZZI.ZZI_NUM = ZZK.ZZK_NUM "
    cQuery += " WHERE ZZK.D_E_L_E_T_ = ' ' AND ZZI.D_E_L_E_T_ = ' ' "
    cQuery += " AND ZZK.ZZK_FILIAL = '" + (cAli)->&(_cCmp1 + "_FILIAL") + "' "
    cQuery += " AND ZZK.ZZK_FORNEC = '" + (cAli)->&(_cCmp1 + "_CODEMI") + "' "
    cQuery += " AND ZZK.ZZK_LOJA = '" + (cAli)->&(_cCmp1 + "_LOJEMI") + "' "
    cQuery += " AND ZZK.ZZK_DOC = '" + (cAli)->&(_cCmp1 + "_DOC") + "' "
    cQuery += " AND ZZK.ZZK_SERIE = '" + (cAli)->&(_cCmp1 + "_SERIE") + "' "

    cTmp := MpSysOpenQuery(cQuery)

    If !(cTmp)->( Eof() )

        cRet := "Gerado"
        
        If (cTmp)->ZZI_STATUS == "B"
            
            cRet := "Conferido"
            
        EndIf

    EndIf

    (cTmp)->( dbCloseArea() )

Return cRet
