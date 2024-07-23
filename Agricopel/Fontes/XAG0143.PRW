#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'RESTFUL.CH'


WSRESTFUL Fornecedor_law DESCRIPTION 'Serviço de Fornecedores ' //SECURITY 'CRMA980' FORMAT 'APPLICATION_JSON,TEXT,HTML'
	WSDATA cod        AS CHARACTER
	WSDATA cnpj       As CHARACTER
	WSDATA Page       AS INTEGER      OPTIONAL
	WSDATA PageSize    AS INTEGER      OPTIONAL

	WSMETHOD GET  DESCRIPTION 'Exemplo de retorno de entidade(s)'  WSSYNTAX '/cnpj'
END WSRESTFUL

WsMethod Get WSRECEIVE cod,cnpj,Page,PageSize WsService Fornecedor_law

    Local cQry          := ""
    Local oResponse     := NIL
    Local cAliasSA2
    Local nRecord       := 0
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local aEmail        := {}
    Local cForneceTac   := ""
    Local nLimite       := 0
    Local nAux          := 0
    Local aData         := {}
    Local nCNPJ         := aScan(Self:aQueryString, { |x| Upper(Alltrim(x[1])) == "CNPJ"})
    Local nPos 			:= 0 
	Local cEmail	    := ""

    Default Self:Page   := 1
    Default Self:PageSize := 1000

    If !Empty(nCNPJ)
        cCnpj := Self:aQueryString[nCNPJ][2]
    EndIf

    cQry := " SELECT SA2.A2_COD,SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_EMAIL, SA2.A2_TEL, SA2.A2_LC, SA2.A2_EQPTAC, SA2.R_E_C_N_O_ " + CRLF
    cQry += " FROM " + RetSqlName('SA2')+" SA2 " + CRLF

    IF !empty(nCNPJ)
        cQry += " WHERE SA2.A2_CGC = '"+self:aQueryString[nCNPJ][2]+"' "
    else
        cQry += " WHERE SA2.D_E_L_E_T_ = '' " + CRLF
    ENDIF
    cQry += " ORDER BY SA2.R_E_C_N_O_ " + CRLF

    cAliasSA2 := GetNextAlias()

    PlsQuery(cQry, cAliasSA2)

    oResponse := JsonObject():New()

    IF !Empty((cAliasSA2))

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


        nCount++
        ASIZE(aEmail,0)
        IF nCount >= nStart
            nAux++

            //Retirando os dois emails
            IF ";" $ Alltrim((cAliasSA2)->A2_EMAIL)
                nPos := AT(";",Alltrim((cAliasSA2)->A2_EMAIL)) 
                cEmail := Substr(Alltrim((cAliasSA2)->A2_EMAIL),1,nPos-1)
            ELSEIF ":" $ Alltrim((cAliasSA2)->A2_EMAIL)
                nPos := AT(":",Alltrim((cAliasSA2)->A2_EMAIL)) 
                cEmail := Substr(Alltrim((cAliasSA2)->A2_EMAIL),1,nPos-1)
            Else 
                cEmail := ALLTRIM((cAliasSA2)->A2_EMAIL)
            ENDIF 

            IF !EMPTY((cAliasSA2)->A2_LC) 
                nLimite := REPLACE(REPLACE(ALLTRIM(TRANSFORM((cAliasSA1)->A1_LC, "@E 999,999,999.99")), ".", ""), ",", ".")
            ELSE
                nLimite := 0
            ENDIF

            IF (cAliasSA2)->A2_EQPTAC == '1'
                cForneceTac := "Sim"
            ELSEIF (cAliasSA2)->A2_EQPTAC == '2'
                cForneceTac := "Nao"
            ENDIF

            aAdd(aData,JsonObject():New())
            aData[nAux]["fornecedorEmail"]              := {}
            aData[nAux]["fornecedorRazao"]              := Alltrim((cAliasSA2)->A2_NOME)
            aData[nAux]["fornecedorCNPJ"]               := Alltrim((cAliasSA2)->A2_CGC)
            aData[nAux]["fornecedorTelefone"]           := Alltrim((cAliasSA2)->A2_TEL)
            aData[nAux]["fornecedorLimite"]             := nLimite
            aData[nAux]["fornecedorTAC"]                := cForneceTac
            aData[nAux]["fornecedorCustoBoleto"]        := (cAliasSA2)->R_E_C_N_O_
            aData[nAux]["fornecedorTED"]                := (cAliasSA2)->R_E_C_N_O_
            aData[nAux]["fornecedorTaxaJuros"]          := (cAliasSA2)->R_E_C_N_O_
            aData[nAux]["titulos"]                      := {}
            aData[nAux]["fornecedorEmail"]              := IIF(EMPTY(cEmail),ALLTRIM((cAliasSA2)->A2_COD)+ALLTRIM((cAliasSA2)->A2_LOJA)+"@alteraremail.com",cEmail)

            IF Len(aData) >= Self:PageSize
                Exit
            EndIF
        EndIF
        (cAliasSA2)->(DBSkip())
    end
    (cAliasSA2)->(DbCloseArea())

    oResponse['Retorno'] := aData

    self:SetResponse( EncodeUTF8(oResponse:ToJson()))

    FreeObj(oResponse)
Return

