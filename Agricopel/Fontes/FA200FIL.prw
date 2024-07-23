#include "protheus.ch"
/*/{Protheus.doc} FA200FIL
PE na localização do título
@type function
@version P12
@author Lucilene Mendes
@since 13/07/2023
@history 16/07/2023, Rafael SMS, Alterado a lógica para que o título seja posicionado e para que a baixa ocorra como esperado
/*/
User Function FA200FIL
Local cSE1
Local nRecSE1
Local cChave
Local cNossoNum
Local cBanco

If Type("lRel650") == "L"
	// FINR650
	// aValores := ( { cNumTit, dBaixa, cTipo, cNossoNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nValCc, dCred, cOcorr, xBuffer })
	cBanco := mv_par03
Else
	// FINA200
	// aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, xBuffer, dDtVc, aBuffer })
	cBanco := mv_par06
EndIf

cNossoNum := Right(ParamIXB[4], 12)

dbSelectArea("SE1")
dbSetOrder(19)
//Procura pelo idcnab
If SE1->(dbSeek(cNumTit))
	//se nossonum for diferente, localiza o titulo pelo nossonum
	If SE1->E1_NUMBCO # cNossoNum .and. cBanco $ "001#237"
		cSE1 := GetNextAlias()
		BeginSQL Alias cSE1
		SELECT E1_IDCNAB, SE1.R_E_C_N_O_ AS E1_RECNO
		FROM %table:SE1% SE1
		WHERE SE1.%notdel%
		AND E1_FILIAL = %xfilial:SE1%
		AND E1_NUMBCO = %exp:cNossoNum%
		EndSQL
		nRecSE1 := E1_RECNO
		dbCloseArea()

		dbSelectArea("SE1")
		dbGoTo(nRecSE1) // se 0 joga pra EOF

		If nRecSE1 > 0
			cChave := SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)

			/*
			If getidcnab(SE1->E1_IDCNAB)
				//Atualiza idcnab
				Reclock("SE1",.F.)
				E1_IDCNAB := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt)
				MsUnlock()
				ConfirmSX8()

				cNumTit := SE1->E1_IDCNAB
			Endif
			*/

			dbSetOrder(1)
			dbSeek(cChave)
			lRel650 := .T.
		EndIf
	Else
		lRel650 := .T.
	EndIf
EndIf
Return

/*/{Protheus.doc} getidcnab
Verifica se há mais de um título com o mesmo Id CNAB
@type function
@version P12
@author Lucilene Mendes
@since 13/07/2023
@param cNumId, character, ID CNAB
@return logical, Retorna .T. se há mais de um
/*/
Static Function getidcnab(cNumId)
Local lRet:= .F.
Local cQry

cQry:= "Select E1_IDCNAB, COUNT(*) QTD "
cQry+= "From "+RetSqlName("SE1")+" SE1 "
cQry+= "Where E1_IDCNAB = '"+cNumId+"' " 
cQry+= "And D_E_L_E_T_ = ' ' " 
cQry+= "Group by E1_IDCNAB " 
MPSysOpenQuery(cQry, "QRY")

lRet:= QRY->QTD > 1

QRY->(dbCloseArea())
dbSelectArea("SE1")
Return lRet
