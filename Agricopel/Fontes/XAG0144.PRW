#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'RESTFUL.CH'

WSRESTFUL dupli_cli DESCRIPTION 'Serviço de Duplicatas Clientes ' //SECURITY 'CRMA980' FORMAT 'APPLICATION_JSON,TEXT,HTML'
	WSDATA cod        AS CHARACTER
	WSDATA cnpj       As CHARACTER
	WSDATA Page       AS INTEGER      OPTIONAL
	WSDATA PageSize    AS INTEGER      OPTIONAL

	WSMETHOD GET  DESCRIPTION 'Exemplo de retorno de entidade(s)'  WSSYNTAX '/cnpj'
END WSRESTFUL

WsMethod Get WSRECEIVE cnpj,Page,PageSize WsService dupli_cli

	Local cQry      		:= ""
	Local oResponse 		:= NIL
	Local cAliasSA1
    Local nRecord 			:= 0
	Local nCount 			:= 0
	Local nStart 			:= 1
	Local nReg   			:= 0
	Local nAux   			:= 0
	Local nParcela 			:= 0
	Local cDuplicata 		:= ""
	Local nValor 			:= 0
	Local aData  			:= {}
	Local nCNPJ				:= aScan(Self:aQueryString, { |x| Upper(Alltrim(x[1])) == "CNPJ"})

    Default Self:Page   := 1
	Default Self:PageSize := 1000

    If !Empty(nCNPJ)
		cCnpj := Self:aQueryString[nCNPJ][2]
	EndIf

	cAliasSA1 := GetNextAlias()

	cQry := "  SELECT SA1.A1_COD, SA1.A1_NOME , SA1.A1_CGC, SA1.A1_EMAIL, SA1.A1_TEL, SA1.A1_LC, SE1.E1_NUM ,SE1.E1_VENCREA, SE1.E1_VALOR, SE1.R_E_C_N_O_  " + CRLF
	cQry += " FROM " + RetSqlName('SA1')+" SA1" + CRLF
	cQry += " JOIN " + RetSqlName('SE1')+" SE1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA" + CRLF
	IF !empty(nCNPJ)
		cQry += " WHERE SA1.A1_CGC = '"+self:aQueryString[nCNPJ][2]+"'  "
	else
		cQry += " WHERE SA1.D_E_L_E_T_ = '' " + CRLF
	ENDIF
	cQry += " AND SE1.E1_BAIXA = ' ' " + CRLF
	cQry += " AND SE1.D_E_L_E_T_ = '' " + CRLF
	cQry += " AND SA1.D_E_L_E_T_ = '' " + CRLF
	cQry += " GROUP BY SE1.E1_NUM, SA1.A1_COD, SA1.A1_NOME , SA1.A1_CGC, SA1.A1_EMAIL, SA1.A1_TEL, SA1.A1_LC, SE1.E1_VENCREA, SE1.E1_VALOR, SE1.R_E_C_N_O_ " + CRLF
	cQry += " ORDER BY SE1.R_E_C_N_O_ " + CRLF


	PlsQuery(cQry, cAliasSA1)

    
	oResponse := JsonObject():New()

	IF ! Empty((cAliasSA1))

        COUNT TO nRecord

		IF Self:Page > 1
			nStart  := ((Self:Page-1)*Self:PageSize)+1
			nReg    := nRecord-nStart+1
		ELSE
			nReg := nRecord
		EndIF

		(cAliasSA1)->(dbGoTop())

        IF nReg > Self:PageSize
			oResponse['hasNext'] := .T.
		ELSE
			oResponse['hasNext'] := .F.
		EndIF
	else
		oResponse['hasNext'] := .F.
    ENDIF    

		WHILE !((cAliasSA1)->(EoF()))

			IF !EMPTY((cAliasSA1)->E1_VALOR) 
				nValor := REPLACE(REPLACE(ALLTRIM(TRANSFORM((cAliasSA1)->E1_VALOR, "@E 999,999,999.99")), ".", ""), ",", ".")
			ELSE
				nValor := 0
			ENDIF

			IF cDuplicata <> Alltrim((cAliasSA1)->E1_NUM)
				cDuplicata := Alltrim((cAliasSA1)->E1_NUM)
				nParcela := 1
			ELSE 
				nParcela++
			ENDIF

            nCount++
		    IF nCount >= nStart
			nAux++
			aAdd(aData,JsonObject():New())

            aData[nAux]["duplicataclienteCNPJ"] 	:= Alltrim((cAliasSA1)->A1_CGC)
			aData[nAux]["duplicataNota"] 			:= Alltrim((cAliasSA1)->E1_NUM) + "/" + cValToChar(nParcela)
			aData[nAux]["duplicataVencimento"] 		:= DtoS((cAliasSA1)->E1_VENCREA)
			aData[nAux]["duplicataValor"] 			:= nValor
            
            IF Len(aData) >= Self:PageSize
				Exit
			EndIF
		EndIF

		cDuplicata := Alltrim((cAliasSA1)->E1_NUM)
		(cAliasSA1)->(DBSkip())
	end
	(cAliasSA1)->(DbCloseArea())
	
	oResponse['Retorno'] := aData

	self:SetResponse( EncodeUTF8(oResponse:ToJson()))

	FreeObj(oResponse)
Return
