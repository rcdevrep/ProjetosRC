#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062I
Grava ACO / ACP a partir das solicitações gravadas em ZDH / ZDI
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062I(cNumSolic)
@param cNumSolic, varchar, Codigo da solicitação
/*/
User Function XAG0062I(cNumSolic)

    Local _cAliasZDH := ""
    Local _cAliasZDI := ""
    Local _cAliasACO := ""
    Local _nPrcTab   := 0

    Begin Transaction

        _cAliasZDH := GetZDH(cNumSolic)

        While !((_cAliasZDH)->(Eof()))

            ACOInsert(_cAliasZDH)
            _cAliasZDI := GetZDI(_cAliasZDH)

            _cAliasACO := GetACO(_cAliasZDH)

            While !((_cAliasZDI)->(Eof()))
                _nPrcTab := GetPrcTab((_cAliasZDH)->ZDH_CODTAB, (_cAliasZDI)->B5_COD)

                While !((_cAliasACO)->(Eof()))
                    ACPInsUpd(_cAliasACO, _cAliasZDI, _nPrcTab)
                    (_cAliasACO)->(DbSkip())
                End

                (_cAliasZDI)->(DbSkip())
                (_cAliasACO)->(DbGoTop())
            End

            (_cAliasACO)->(DbCloseArea())
            (_cAliasZDI)->(DbCloseArea())
            (_cAliasZDH)->(DbSkip())
        End

        (_cAliasZDH)->(DbCloseArea())
        ZDHUpdSt(cNumSolic)
        EnvWfConf(cNumSolic)

    End Transaction

Return()

Static Function GetZDH(cNumSolic)

    Local _cQuery    := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT "
    _cQuery += "    ZDH_FILIAL, "
    _cQuery += "    ZDH_NUM, "
    _cQuery += "    ZDH_CODCLI, "
    _cQuery += "    ZDH_LOJA, "
    _cQuery += "    ZDH_HORA, "
    _cQuery += "    ZDH_DATA, "
    _cQuery += "    ZDH_CONDPG, "
    _cQuery += "    ZDH_CODTAB, "
    _cQuery += "    ZDH_STATUS, "
    _cQuery += "    ZDH_NOMCLI, "
    _cQuery += "    ZDH_VEND, "
    _cQuery += "    ZDH_CATEGO, "
    _cQuery += "    ZDH_FAIXA, "
    _cQuery += "    ZDH_MOTIVO, "
    _cQuery += "    ZDH_CHVAPR, "
    _cQuery += "    ZDH_USERGI, "
    _cQuery += "    ZDH_USERGA, "
    _cQuery += "    D_E_L_E_T_, "
    _cQuery += "    R_E_C_N_O_, "
    _cQuery += "    R_E_C_D_E_L_ "
    _cQuery += " FROM " + RetSqlName("ZDH") + " ZDH (NOLOCK) "
    _cQuery += " WHERE ZDH.ZDH_NUM = '" + cNumSolic + "'"
    _cQuery += "   AND ZDH.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH.ZDH_FILIAL = '" + FWFilial("ZDH") + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function GetZDI(_cAliasZDH)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _aProdNov  := StrTokArr(U_XAG0062G("COD_PRODUTO_NOVO", .T., .F.),";")
    Local nX         := 0

    _cQuery := " SELECT SB5.B5_COD, ZDI.ZDI_PRCAPR,ZDI_TPPROD "

    _cQuery += " FROM " + RetSqlName("SB5") + " SB5 (NOLOCK), " + RetSqlName("SA1") + " SA1 (NOLOCK), " + RetSqlName("ZDI") + " ZDI (NOLOCK) "

    _cQuery += " WHERE SB5.D_E_L_E_T_ = '' "
    _cQuery += " AND   SA1.D_E_L_E_T_ = '' "
    _cQuery += " AND   ZDI.D_E_L_E_T_ = '' "

    _cQuery += " AND   SB5.B5_FILIAL = '" + FWFilial("SB5") + "'"
    _cQuery += " AND   ZDI.ZDI_FILIAL = '" + FWFilial("ZDI") + "'"
    _cQuery += " AND   SA1.A1_FILIAL = '" + FWFilial("SA1") + "'"

    _cQuery += " AND  SB5.B5_XTPTRR = ZDI.ZDI_TPPROD "
    _cQuery += " AND  ZDI.ZDI_CODCLI = SA1.A1_COD "

    _cQuery += " AND ZDI.ZDI_NUM = '" + (_cAliasZDH)->ZDH_NUM + "'"
    _cQuery += " AND SA1.A1_COD = '" + (_cAliasZDH)->ZDH_CODCLI + "'"

    _cQuery += " AND ZDI.ZDI_LOJA = SA1.A1_LOJA "
    _cQuery += " AND SA1.A1_LOJA = '" + (_cAliasZDH)->ZDH_LOJA + "'"

    _cQuery += " AND ( "
    _cQuery += "      SB5.B5_XUFTRR IN (SA1.A1_EST, SA1.A1_ESTE) "
    _cQuery += "   OR EXISTS (SELECT ACP.ACP_CODPRO "
    _cQuery += "              FROM " + RetSqlName("ACP") + " ACP (NOLOCK), " + RetSqlName("ACO") + " ACO (NOLOCK) "
    _cQuery += "              WHERE ACO.D_E_L_E_T_ = '' "
    _cQuery += "              AND   ACP.D_E_L_E_T_ = '' "
    _cQuery += "              AND   ACO.ACO_FILIAL = '" + FWFilial("ACO") + "'"
    _cQuery += "              AND   ACP.ACP_FILIAL = '" + FWFilial("ACP") + "'"
    _cQuery += "			  AND   ACP.ACP_CODREG = ACO.ACO_CODREG "
    _cQuery += "              AND   ACP.ACP_CODPRO = SB5.B5_COD "
    _cQuery += "			  AND   ACO.ACO_CODCLI = SA1.A1_COD "
    _cQuery += "			  AND   ACO.ACO_LOJA = SA1.A1_LOJA) "

    If (!Empty(_aProdNov))
        _cQuery += " OR SB5.B5_COD IN ( "

        For nX := 1 To Len(_aProdNov)
            If (nX > 1)
                _cQuery += ","
            EndIf

            _cQuery += "'" + _aProdNov[nX] + "'"
        Next nX

        _cQuery += " ) "
    EndIf

    _cQuery += " ) "

    _cQuery += " ORDER BY SB5.B5_COD "

    _cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function ACOFind(_cAliasZDH)

    Local _nRecNoACO := 0
    Local _cQuery    := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT R_E_C_N_O_ "
    _cQuery += " FROM " + RetSqlName("ACO") + " ACO (NOLOCK) "
    _cQuery += " WHERE ACO.ACO_CODCLI = '" + (_cAliasZDH)->ZDH_CODCLI + "'"
    _cQuery += " AND   ACO.ACO_CONDPG = '" + (_cAliasZDH)->ZDH_CONDPG + "'"
    _cQuery += " AND   ACO.ACO_CODTAB = '" + (_cAliasZDH)->ZDH_CODTAB + "'"
    _cQuery += " AND   ACO.ACO_FILIAL = '" + FWFilial("ACO") + "'"
    _cQuery += " AND   ACO.D_E_L_E_T_ = '' "
    _cQuery += " AND   ACO.ACO_LOJA = '" + (_cAliasZDH)->ZDH_LOJA + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

    _nRecNoACO := (_cAliasQry)->R_E_C_N_O_

    (_cAliasQry)->(DbCloseArea())

Return(_nRecNoACO)

Static Function ACOInsert(_cAliasZDH)

    Local _nRecNoACO := 0
    Local _cCodReg   := ""
    Local _cDsCondPg := ""

    _nRecNoACO := ACOFind(_cAliasZDH)

    If (_nRecNoACO == 0)

        _cCodReg   := ACONovoCod()
        _cDsCondPg := SE4Descri((_cAliasZDH)->ZDH_CONDPG)

        RecLock("ACO", .T.)

            ACO->ACO_FILIAL := FWFilial("ACO")
            ACO->ACO_CODREG := _cCodReg
            ACO->ACO_DESCRI := _cDsCondPg
            ACO->ACO_CODCLI := (_cAliasZDH)->ZDH_CODCLI
            ACO->ACO_LOJA   := (_cAliasZDH)->ZDH_LOJA
            ACO->ACO_CODTAB := (_cAliasZDH)->ZDH_CODTAB
            ACO->ACO_CONDPG := (_cAliasZDH)->ZDH_CONDPG
            ACO->ACO_FORMPG := ""
            // ACO->ACO_FAIXA  := 0
            ACO->ACO_MOEDA  := 1
            // ACO->ACO_PERDES := 0
            ACO->ACO_CFAIXA := "YYYYYYYYYYYYYYY.YY  "
            ACO->ACO_TPHORA := "1"
            ACO->ACO_HORADE := "00:00"
            ACO->ACO_HORATE := "23:59"
            ACO->ACO_DATDE  := dDataBase
            // ACO->ACO_DATATE := "  "
            ACO->ACO_PROMOC := "N"
            ACO->ACO_GRPVEN := ""
            // ACO->ACO_DESCPR := .F.
            ACO->ACO_VLRDES := 0
            ACO->ACO_MSBLQL := "2"

        MsUnlock()

		If __lSX8
			ConfirmSX8()
		EndIf
    EndIf

Return()

Static Function ACPInsUpd(_cAliasACO, _cAliasZDI, _nPrcTab)

    Local _nRecNoACP := 0
    Local _cACPItem  := ""
    Local _nTamPDesc := 0
    Local _nValDesc  := 0

    _nTamPDesc := TamSX3("ACP_PERDES")[1]

    _nRecNoACP := ACPFind((_cAliasACO)->ACO_CODREG, (_cAliasZDI)->B5_COD)

    If (_nRecNoACP == 0)

        _cACPItem := ACPNovoIte((_cAliasACO)->ACO_CODREG)

        RecLock("ACP", .T.)

        ACP->ACP_FILIAL := FWFilial("ACP")
        ACP->ACP_CODREG := (_cAliasACO)->ACO_CODREG
        ACP->ACP_ITEM   := _cACPItem
        ACP->ACP_CODPRO := (_cAliasZDI)->B5_COD
        ACP->ACP_FAIXA  := 999999.99
        ACP->ACP_DESMAX := 0
        ACP->ACP_COMIS  := 0
        ACP->ACP_COMIS2 := 0
        ACP->ACP_COMIS3 := 0
        ACP->ACP_TPDESC := "1"
        ACP->ACP_XFINTR := "S"
    Else
        ACP->(DbGoTo(_nRecNoACP))
        RecLock("ACP", .F.)
    EndIf

    //If (ACP->ACP_XFINTR == "S" .And. (_cAliasACO)->ACR_CP > 0) .And. ( alltrim((_cAliasZDI)->ZDI_TPPROD) == '5' .or. dtos(date()) > '20211201')
    If (ACP->ACP_XFINTR == "S" .And. (_cAliasACO)->ACR_CP > 0) //.And. ( alltrim((_cAliasZDI)->ZDI_TPPROD) == '5')
        ACP->ACP_PRECO := (_cAliasZDI)->ZDI_PRCAPR + (_cAliasACO)->ACR_CP
    Else
        ACP->ACP_PRECO := (_cAliasZDI)->ZDI_PRCAPR
    EndIf

    _nValDesc       := _nPrcTab - ACP->ACP_PRECO
    ACP->ACP_VLRDES := _nValDesc
    ACP->ACP_PERDES := Round(_nValDesc / _nPrcTab * 100,_nTamPDesc)

    MsUnlock()

Return()

Static Function ACPFind(cCodReg, cCodProd)

    Local _nRecNoACP := 0
    Local _cQuery    := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT R_E_C_N_O_ "
    _cQuery += " FROM " + RetSqlName("ACP") + " ACP (NOLOCK) "
    _cQuery += " WHERE ACP.ACP_CODPRO = '" + cCodProd + "'"
    _cQuery += " AND   ACP.ACP_CODREG = '" + cCodReg + "'"
    _cQuery += " AND   ACP.ACP_FILIAL = '" + FWFilial("ACP") + "'"
    _cQuery += " AND   ACP.D_E_L_E_T_ = '' "

    _cAliasQry := MpSysOpenQuery(_cQuery)

    _nRecNoACP := (_cAliasQry)->R_E_C_N_O_

    (_cAliasQry)->(DbCloseArea())

Return(_nRecNoACP)

Static Function GetPrcTab(_cCodTab, _cCodProd)

    Local _nPrcTab   := 0
    Local _cQuery    := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT DA1.DA1_PRCVEN "
    _cQuery += " FROM " + RetSqlName("DA1") + " DA1 (NOLOCK)
	_cQuery += " WHERE DA1.DA1_CODTAB = '" + _cCodTab + "'"
	_cQuery += "   AND DA1.DA1_CODPRO = '" + _cCodProd + "'"
    _cQuery += "   AND DA1.DA1_FILIAL = '" + FWFilial("DA1") + "'"
    _cQuery += "   AND DA1.D_E_L_E_T_ = '' "

    _cAliasQry := MpSysOpenQuery(_cQuery)

    _nPrcTab := (_cAliasQry)->DA1_PRCVEN

    (_cAliasQry)->(DbCloseArea())

Return(_nPrcTab)

Static Function SE4Descri(cCodSE4)

    Local _cDecsSE4  := ""
    Local _cQuery    := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT E4_DESCRI "
    _cQuery += " FROM " + RetSqlName("SE4") + " SE4 (NOLOCK)
    _cQuery += " WHERE SE4.E4_CODIGO = '" + cCodSE4 + "'"
    _cQuery += " AND   SE4.E4_FILIAL = '" + FWFilial("SE4") + "'"
    _cQuery += " AND   SE4.D_E_L_E_T_ = '' "

    _cAliasQry := MpSysOpenQuery(_cQuery)

    _cDecsSE4 := (_cAliasQry)->E4_DESCRI

    (_cAliasQry)->(DbCloseArea())

Return(_cDecsSE4)

Static Function ZDHUpdSt(cNumSolic)

    Local _cQuery := ""

    _cQuery += " UPDATE " + RetSqlName("ZDH") + " SET "
    _cQuery += "   ZDH_STATUS = 'B', "
    _cQuery += "   ZDH_DTAPRP = CONVERT(VARCHAR(30),CURRENT_TIMESTAMP,20 )"
    _cQuery += " WHERE ZDH_NUM = '" + cNumSolic + "'"
    _cQuery += "   AND D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH_FILIAL = '" + FWFilial("ZDH") + "'"

    TCSQLExec(_cQuery)

Return()

Static Function ACONovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	cX3_Relacao := GetSX3Cache("ACO_CODREG", "X3_RELACAO")

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("ACO", "ACO_CODREG")
		EndIf

		ACO->(DbSetOrder(1))
		ACO->(DbGoTop())
		lJaExiste := ACO->(DbSeek(FWFilial("ACO")+cCodNovo))
	End

	If __lSX8
		ConfirmSX8()
	EndIf

Return(cCodNovo)

Static Function ACPNovoIte(cCodRegra)

    Local _cQuery := ""
    Local _cAlias := ""
    Local _cRet   := ""
    Local _nTamItem := GetSX3Cache("ACP_ITEM", "X3_TAMANHO")

    _cRet := StrZero(1,_nTamItem)

    _cQuery := " SELECT MAX(ACP_ITEM) AS MAXITEM "
    _cQuery += " FROM " + RetSqlName("ACP") + " (NOLOCK) "
    _cQuery += " WHERE ACP_FILIAL = '" + FWFilial("ACP") + "'"
    _cQuery += " AND   D_E_L_E_T_ = '' "
    _cQuery += " AND   ACP_CODREG = '" + cCodRegra + "'"

    _cAlias := MpSysOpenQuery(_cQuery)

    While !((_cAlias)->(Eof()))
        _cRet := Soma1((_cAlias)->MAXITEM)

        (_cAlias)->(DbSkip())
    End

    (_cAlias)->(DbCloseArea())

Return(_cRet)

Static Function GetACO(_cAliasZDH)

    Local _cQuery    := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT ACO.ACO_CODREG, ACO.ACO_CONDPG, "

    _cQuery += " COALESCE((SELECT E4_XACRTRR "
    _cQuery += "           FROM " + RetSqlName("SE4") + " SE4 (NOLOCK) "
    _cQuery += "           WHERE SE4.E4_CODIGO = ACO.ACO_CONDPG "
    _cQuery += "           AND   SE4.E4_FILIAL = '" + FWFilial("SE4") + "'"
    _cQuery += "           AND   SE4.D_E_L_E_T_ = ''), 0) AS ACR_CP "

    _cQuery += " FROM " + RetSqlName("ACO") + " ACO (NOLOCK) "
    _cQuery += " WHERE ACO.ACO_CODCLI = '" + (_cAliasZDH)->ZDH_CODCLI + "'"
    _cQuery += " AND   ACO.ACO_CODTAB = '" + (_cAliasZDH)->ZDH_CODTAB + "'"
    _cQuery += " AND   ACO.ACO_FILIAL = '" + FWFilial("ACO") + "'"
    _cQuery += " AND   ACO.D_E_L_E_T_ = '' "
    _cQuery += " AND ACO.ACO_LOJA = '" + (_cAliasZDH)->ZDH_LOJA + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function EnvWfConf(cNumSolic)

    U_XAG0062O(cNumSolic)

Return()
