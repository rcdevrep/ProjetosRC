#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'RESTFUL.CH'

WSRESTFUL dupli_fornece DESCRIPTION 'Consulta Duplicatas Fornecedor' //SECURITY 'CRMA980' FORMAT 'APPLICATION_JSON,TEXT,HTML'
    WSDATA cod        AS CHARACTER
    WSDATA cnpj       As CHARACTER
    WSDATA Page       AS INTEGER      OPTIONAL
    WSDATA PageSize    AS INTEGER      OPTIONAL

    WSMETHOD GET  DESCRIPTION 'Exemplo de retorno de entidade(s)'  WSSYNTAX '/cnpj'
END WSRESTFUL

WsMethod Get WSRECEIVE cnpj,Page,PageSize WsService dupli_fornece

    Local cQry          := ""
    Local oResponse     := NIL
    Local cAliasSA2
    Local nRecord       := 0
    Local nCount        := 0
    Local nValor        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0
    Local nParcela      := 1
    Local cDuplicata    := ""
    Local aData         := {}
    Local nCNPJ         := aScan(Self:aQueryString, { |x| Upper(Alltrim(x[1])) == "CNPJ"})

    Default Self:Page   := 1
    Default Self:PageSize := 1000

    If !Empty(nCNPJ)
        cCnpj := Self:aQueryString[nCNPJ][2]
    EndIf


    cQry := " SELECT SA2.A2_COD, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_EMAIL, SA2.A2_TEL, SA2.A2_LC, SA2.A2_EQPTAC, SA2.A2_CGC, SE2.E2_NUM ,SE2.E2_VENCREA, SE2.E2_VALOR, SE2.R_E_C_N_O_ " + CRLF
    cQry += " FROM " + RetSqlName('SA2')+" SA2 " + CRLF
    cQry += " JOIN " + RetSqlName('SE2')+" SE2 ON SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA"
    IF !empty(nCNPJ)
        cQry += " WHERE SA2.A2_CGC = '"+self:aQueryString[nCNPJ][2]+"' "
    else
        cQry += " WHERE SA2.D_E_L_E_T_ = '' " + CRLF
    ENDIF
    cQry += " AND SE2.D_E_L_E_T_ = '' AND SE2.E2_BAIXA = ' ' " + CRLF
    cQry += " GROUP BY SE2.E2_NUM, SA2.A2_COD, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_EMAIL, SA2.A2_TEL, SA2.A2_LC, SA2.A2_EQPTAC, SA2.A2_CGC,SE2.E2_VENCREA, SE2.E2_VALOR, SE2.R_E_C_N_O_ " + CRLF
    cQry += " ORDER BY SE2.R_E_C_N_O_ " + CRLF



    cAliasSA2 := GetNextAlias()

    PlsQuery(cQry, cAliasSA2)

    oResponse := JsonObject():New()

    IF ! Empty((cAliasSA2))

        COUNT TO nRecord

        IF Self:Page > 1
            nStart  := ((Self:Page-1)*Self:PageSize)+1
            nReg    := nRecord-nStart+1
        ELSE
            nReg := nRecord
        EndIF

        (cAliasSA2)->(dbGoTop())

        IF nReg > Self:PageSize
            oResponse['hasNext'] := .T.
        ELSE
            oResponse['hasNext'] := .F.
        EndIF
    else
        oResponse['hasNext'] := .F.

    endif

    WHILE !(cAliasSA2)->(EoF())

        IF !EMPTY((cAliasSA2)->E2_VALOR) 
            nValor := REPLACE(REPLACE(ALLTRIM(TRANSFORM((cAliasSA2)->E2_VALOR, "@E 999,999,999.99")), ".", ""), ",", ".")
        ELSE
            nValor := 0
        ENDIF
        
        IF cDuplicata <> Alltrim((cAliasSA2)->E2_NUM)
            cDuplicata := Alltrim((cAliasSA2)->E2_NUM)
            nParcela := 1
        ELSE 
            nParcela++
        ENDIF
        nCount++
        IF nCount >= nStart
            nAux++
            aAdd(aData,JsonObject():New())
            aData[nAux]["duplicataFornecedorCNPJ"]  := Alltrim((cAliasSA2)->A2_CGC)
            aData[nAux]["duplicataNota"]            := cDuplicata + "/" + cValToChar(nParcela)
            aData[nAux]["duplicataVencimento"]      := DtoS((cAliasSA2)->E2_VENCREA)
            aData[nAux]["duplicataValor"]           := nValor

            IF Len(aData) >= Self:PageSize
                Exit
            EndIF
        EndIF

        cDuplicata := Alltrim((cAliasSA2)->E2_NUM)
        (cAliasSA2)->(DBSkip())
    end
    (cAliasSA2)->(DbCloseArea())

    oResponse['Retorno'] := aData

    self:SetResponse( EncodeUTF8(oResponse:ToJson()))

    FreeObj(oResponse)

Return


