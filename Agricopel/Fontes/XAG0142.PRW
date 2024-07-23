#INCLUDE 'Totvs.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'RESTFUL.CH'


WSRESTFUL consultaCliente_law DESCRIPTION 'Serviço de clientes ' //SECURITY 'CRMA980' FORMAT 'APPLICATION_JSON,TEXT,HTML'
	WSDATA cod        AS CHARACTER
	WSDATA cnpj       As CHARACTER
	WSDATA Page       AS INTEGER      OPTIONAL
	WSDATA PageSize    AS INTEGER      OPTIONAL

	WSMETHOD GET  DESCRIPTION 'Exemplo de retorno de entidade(s)'  WSSYNTAX '/cnpj'
END WSRESTFUL

WsMethod Get WSRECEIVE cod,cnpj,Page,PageSize WsService consultaCliente_law

	Local cQry      	:= ""
	Local oResponse 	:= NIL
	Local cAliasSA1
	Local nRecord 		:= 0
	Local nCount 		:= 0
	Local nStart 		:= 1
	Local nReg   		:= 0
	Local nAux   		:= 0
	Local aData  		:= {}
	Local nCNPJ			:= aScan(Self:aQueryString, { |x| Upper(Alltrim(x[1])) == "CNPJ"})
	Local aEmail 		:= {}
	Local nLimite		:= 0
	Local nPos 			:= 0 
	Local cEmail	    := ""


	Default Self:Page   := 1
	Default Self:PageSize := 1000

	If !Empty(nCNPJ)
		cCnpj := Self:aQueryString[nCNPJ][2]
	EndIf

	cAliasSA1 := GetNextAlias()

	cQry := "  SELECT SA1.A1_COD,SA1.A1_LOJA ,SA1.A1_NOME , SA1.A1_CGC, SA1.A1_EMAIL, SA1.A1_TEL, SA1.A1_LC, SA1.R_E_C_N_O_ " + CRLF
	cQry += " FROM " + RetSqlName('SA1')+" SA1" + CRLF
	IF !empty(nCNPJ)
		cQry += " WHERE SA1.A1_CGC = '"+self:aQueryString[nCNPJ][2]+"' AND SA1.D_E_L_E_T_ = '' "
	else
		cQry += " WHERE SA1.D_E_L_E_T_ = '' " + CRLF
	ENDIF

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

	endif


	WHILE !(cAliasSA1)->(EOF())

		nCount++
		IF nCount >= nStart
			nAux++

			//Retirando os dois emails
			IF ";" $ Alltrim((cAliasSA1)->A1_EMAIL)
				nPos    := AT(";",Alltrim((cAliasSA1)->A1_EMAIL)) 
                cEmail  := Substr(Alltrim((cAliasSA1)->A1_EMAIL),1,nPos-1)
			ELSEIF ":" $ Alltrim((cAliasSA1)->A1_EMAIL)
				nPos 	:= AT(":",Alltrim((cAliasSA1)->A1_EMAIL)) 
                cEmail  := Substr(Alltrim((cAliasSA1)->A1_EMAIL),1,nPos-1)
			Else
				cEmail := ALLTRIM((cAliasSA1)->A1_EMAIL)
			ENDIF

			IF !EMPTY((cAliasSA1)->A1_LC) 
                nLimite := REPLACE(REPLACE(ALLTRIM(TRANSFORM((cAliasSA1)->A1_LC, "@E 999,999,999.99")), ".", ""), ",", ".")
            ELSE
                nLimite := 0
            ENDIF


			aAdd(aData,JsonObject():New())
			aData[nAux]["clienteEmail"] 		:= {}
			aData[nAux]["clienteRazao"] 		:= Alltrim((cAliasSA1)->A1_NOME)
			aData[nAux]["clienteCNPJ"] 			:= Alltrim((cAliasSA1)->A1_CGC)
			aData[nAux]["clienteEmail"]	        := IIF(EMPTY(cEmail),ALLTRIM((cAliasSA1)->A1_COD)+ALLTRIM((cAliasSA1)->A1_LOJA)+"@alteraremail.com",cEmail)
			aData[nAux]["clienteTelefone"] 		:= Alltrim((cAliasSA1)->A1_TEL)
			aData[nAux]["clienteLimite"]  		:= nLimite
			aData[nAux]["clienteTaxaJuros"] 	:= (cAliasSA1)->R_E_C_N_O_
			aData[nAux]["clienteCustoBoleto"] 	:= (cAliasSA1)->R_E_C_N_O_
			aData[nAux]["clienteTAC"] 			:= (cAliasSA1)->R_E_C_N_O_
			aData[nAux]["clienteTED"] 			:= (cAliasSA1)->R_E_C_N_O_
			aData[nAux]["titulos"] 				:=  {}

			IF Len(aData) >= Self:PageSize
				Exit
			EndIF
		EndIF
		(cAliasSA1)->(DBSkip())
	end
	(cAliasSA1)->(DbCloseArea())

	oResponse['Retorno'] := aData

	self:SetResponse( EncodeUTF8(oResponse:ToJson()))

	FreeObj(oResponse)

Return

