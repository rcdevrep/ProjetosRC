#INCLUDE "PROTHEUS.CH"

User Function FA430FIG()

    local cQuery := ''
    local cCNPJ := ParamIxb[1]
    local cNum := alltrim(ParamIxb[4])
    local cTRB := getNextAlias()

    Local cCodForn := ParamIxb[2]
    Local cPrefixo := ParamIxb[3]
    Local cParcela:= ParamIxb[5]


    //036853/01 - 62014030000104 - Arquivo DDA
    //036853/02 - 62014030000538 - Titulo lançado no Protheus

    If (Select(cTRB) <> 0)
        dbSelectArea(cTRB)
        dbCloseArea()
    EndIf
    

    cQuery := "SELECT E2.*, A2.* "
    cQuery += "FROM SE2"+cEmpAnt+"0 E2 "
    cQuery += "INNER JOIN SA2"+cEmpAnt+"0 A2 "
    cQuery += "    ON  A2_FILIAL = ' ' "
    cQuery += "    AND A2_COD = E2_FORNECE "
    cQuery += "    AND A2_LOJA = E2_LOJA "					
    cQuery += "    AND A2.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE E2_FILIAL = ' ' "
    cQuery += "AND   E2_NUM = '" + cNum + "' "

    //cQuery += "AND   E2_CODBAR = '" + cCodBar + "' "

    cQuery += "AND   E2_FORNECE = '" + cCodForn + "' "
    cQuery += "AND   E2_PREFIXO = '" + cPrefixo + "' "
    cQuery += "AND   E2_PARCELA = '" + cParcela + "' "
    cQuery += "AND   E2.D_E_L_E_T_ = ' ' "
    
    cQuery := Changequery(cQuery)						
    
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRB,.T.,.T.)				
    dbSelectArea(cTRB)								
    
    While !(cTRB)->(Eof())


        if substr((cTRB)->A2_CGC,1,8) == substr(cCNPJ,1,8)

            return (cTRB)->A2_CGC

        endif            

       cTRB->(dbSkip())

    enddo

    (cTRB)->( dbCloseArea() )

Return cCNPJ
