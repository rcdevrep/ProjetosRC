#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} TMPLFS
- Rotina criada para alterar os registros de ACP/ACO da agricopel para serem exclusivas por filial
@author Leandro F Silveira
@since 31/05/2021
@return sem retorno
@type function
/*/
User Function TMPLFS()

	//RPCSetType(3)
	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "03" MODULO "SIGAFAT" TABLES "ACO","ACP"

	Processa({|lEnd| ProcSX2()}, "Alterando SX2")
	Processa({|lEnd| UpdACP()}, "Exec update ACP")
	Processa({|lEnd| UpdACO()}, "Exec update ACO")

	Processa({|lEnd| AjustaACP("15")}, "Atualizando ACP")

	//RPCClearEnv()

Return()

Static Function ACONovoCod(_cFilDest)

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
		lJaExiste := ACO->(DbSeek(_cFilDest+cCodNovo))
	End

	If __lSX8
		ConfirmSX8()
	EndIf

Return(cCodNovo)

Static Function ACPNovoIte(cCodRegra, _cFilDest)

	Local _cQuery := ""
	Local _cAlias := ""
	Local _cRet   := ""
	Local _nTamItem := GetSX3Cache("ACP_ITEM", "X3_TAMANHO")

	_cRet := StrZero(1,_nTamItem)

	_cQuery := " SELECT MAX(ACP_ITEM) AS MAXITEM "
	_cQuery += " FROM ACP010 ACP (NOLOCK) "
	_cQuery += " WHERE ACP_FILIAL = '" + _cFilDest + "'"
	_cQuery += " AND   D_E_L_E_T_ = '' "
	_cQuery += " AND   ACP_CODREG = '" + cCodRegra + "'"
	_cQuery += " AND   ACP_FILIAL = '" + _cFilDest + "'"

	_cAlias := MpSysOpenQuery(_cQuery)

	While !((_cAlias)->(Eof()))
		_cRet := Soma1((_cAlias)->MAXITEM)

		(_cAlias)->(DbSkip())
	End

	(_cAlias)->(DbCloseArea())

Return(_cRet)

Static Function ProcSX2()

	SX2->(DbSetOrder(1))
	SX2->(DbGoTop())
	If (SX2->(DbSeek("ACO")))
		RecLock("SX2")
		SX2->X2_MODO    := "E"
		SX2->X2_MODOUN  := "E"
		SX2->X2_MODOEMP := "E"
		MsUnlock()
	Else
		MsStop("Falha ao alterar ACO")
	EndIf

	SX2->(DbSetOrder(1))
	SX2->(DbGoTop())
	If (SX2->(DbSeek("ACP")))
		RecLock("SX2")
		SX2->X2_MODO    := "E"
		SX2->X2_MODOUN  := "E"
		SX2->X2_MODOEMP := "E"
		MsUnlock()
	Else
		MsStop("Falha ao alterar ACP")
	EndIf

Return()

Static Function UpdACP()

	Local _cQuery := ""

	_cQuery += " UPDATE ACP010 SET "
	_cQuery += "    ACP_FILIAL = '03' "
	_cQuery += " WHERE ACP_CODPRO NOT IN ('44380001','00020340','00338','00020305') "
	_cQuery += " AND ACP_FILIAL = '' "
	_cQuery += " AND D_E_L_E_T_ = '' "

	If (TCSQLExec(_cQuery) < 0)
		MsgStop("Erro ao executar update em ACO/ACP")
	EndIf

	_cQuery += " UPDATE ACP010 SET "
	_cQuery += "    ACP_FILIAL = '15' "
	_cQuery += " WHERE ACP_CODPRO IN ('44380001','00020340','00338','00020305') "
	_cQuery += " AND ACP_FILIAL = '' "
	_cQuery += " AND D_E_L_E_T_ = '' "

	If (TCSQLExec(_cQuery) < 0)
		MsgStop("Erro ao executar update em ACO/ACP")
	EndIf

Return()

Static Function UpdACO()

	Local _cQuery := ""

	_cQuery += " UPDATE ACO SET "
	_cQuery += "    ACO_FILIAL = '03' "
	_cQuery += " FROM ACO010 ACO, ACP010 ACP (NOLOCK) "
	_cQuery += " WHERE ACP_FILIAL = '03' "
	_cQuery += " AND   ACP_CODREG = ACO_CODREG "
	_cQuery += " AND   ACP.D_E_L_E_T_ = '' "
	_cQuery += " AND   ACO.D_E_L_E_T_ = '' "
	_cQuery += " AND   ACO_FILIAL = '' "

	If (TCSQLExec(_cQuery) < 0)
		MsgStop("Erro ao executar update em ACO/ACP")
	EndIf

	_cQuery += " UPDATE ACO SET "
	_cQuery += "    ACO_FILIAL = '15' "
	_cQuery += " FROM ACO010 ACO "
	_cQuery += " WHERE ACO.D_E_L_E_T_ = '' "
	_cQuery += " AND   ACO_FILIAL = '' "

	If (TCSQLExec(_cQuery) < 0)
		MsgStop("Erro ao executar update em ACO/ACP")
	EndIf

Return()

Static Function ReplACO(cCodReg, _cFilOri, _cFilDest)

	Local _cAliasACO := ""
	Local _cCodReg   := ""

	_cAliasACO := ACOGetAll(cCodReg, _cFilOri)
	_cCodReg   := ACONovoCod(_cFilDest)

	RecLock("ACO", .T.)

	ACO->ACO_FILIAL := _cFilDest
	ACO->ACO_CODREG := _cCodReg

	ACO->ACO_DESCRI := (_cAliasACO)->ACO_DESCRI
	ACO->ACO_CODCLI := (_cAliasACO)->ACO_CODCLI
	ACO->ACO_LOJA   := (_cAliasACO)->ACO_LOJA
	ACO->ACO_CODTAB := (_cAliasACO)->ACO_CODTAB
	ACO->ACO_CONDPG := (_cAliasACO)->ACO_CONDPG
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

	(_cAliasACO)->(DbCloseArea())

Return(_cCodReg)

Static Function ACOGetAll(cCodReg, _cFilOri)

	Local _cQuery    := ""
	Local _cAliasQry := ""

	_cQuery := " SELECT ACO_DESCRI, ACO_CODCLI, ACO_LOJA, ACO_CODTAB, ACO_CONDPG "
	_cQuery += " FROM ACO010 ACO (NOLOCK) "
	_cQuery += " WHERE ACO.ACO_CODREG = '" + cCodReg + "'"
	_cQuery += " AND   ACO.ACO_FILIAL = '" + _cFilOri + "'"
	_cQuery += " AND   ACO.D_E_L_E_T_ = '' "

	_cAliasQry := MpSysOpenQuery(_cQuery)

	TCSetField(_cAliasQry,"ACO_DATDE","D",08,0)
	TCSetField(_cAliasQry,"ACO_DATATE","D",08,0)

Return(_cAliasQry)

Static Function AjustaACP(_cFilProc)

	Local _cFilDest  := _cFilProc
	Local _cFilOri   := IIf(_cFilProc == "03","15","03")
	Local nTamRegua  := QtdAjuACP(_cFilDest)
	Local _cAliasACP := ACPGetProc(_cFilDest)
	Local _cCodReg   := ""

	ProcRegua(nTamRegua)

	While (!(_cAliasACP)->(Eof()))

		_cCodReg := FindACO((_cAliasACP)->ACP_CODREG, _cFilDest, _cFilOri)

		If Empty(_cCodReg)
			_cCodReg := ReplACO((_cAliasACP)->ACP_CODREG, _cFilOri, _cFilDest)
		EndIf

		UpdRegACP((_cAliasACP)->RECNO, _cCodReg)

		IncProc()
		(_cAliasACP)->(DbSkip())
	End

Return()

Static Function QtdAjuACP(_cFilProc)

	Local _cQuery    := ""
	Local _cAliasQry := ""
	Local _nRet      := 0

	_cQuery += " SELECT COUNT(*) AS QTDE "
	_cQuery += " FROM ACP010 ACP (NOLOCK) "
	_cQuery += " WHERE NOT EXISTS (SELECT R_E_C_N_O_ "
	_cQuery += "                   FROM ACO010 ACO (NOLOCK) "
	_cQuery += "                   WHERE ACO_FILIAL = ACP_FILIAL "
	_cQuery += "                   AND ACO.D_E_L_E_T_ = '' "
	_cQuery += "                   AND ACO.ACO_CODREG = ACP.ACP_CODREG) "
	_cQuery += " AND ACP_FILIAL = '" + _cFilProc + "'"

	_cAliasQry := MpSysOpenQuery(_cQuery)

	_nRet := (_cAliasQry)->QTDE

	(_cAliasQry)->(DbCloseArea())

Return(_nRet)

Static Function ACPGetProc(_cFilProc)

	Local _cQuery    := ""
	Local _cAliasQry := ""

	_cQuery += " SELECT ACP_CODREG, R_E_C_N_O_ AS RECNO "
	_cQuery += " FROM ACP010 ACP (NOLOCK) "
	_cQuery += " WHERE NOT EXISTS (SELECT R_E_C_N_O_ "
	_cQuery += "                   FROM ACO010 ACO (NOLOCK) "
	_cQuery += "                   WHERE ACO_FILIAL = ACP_FILIAL "
	_cQuery += "                   AND ACO.D_E_L_E_T_ = '' "
	_cQuery += "                   AND ACO.ACO_CODREG = ACP.ACP_CODREG) "
	_cQuery += " AND ACP_FILIAL = '" + _cFilProc + "'"

	_cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function FindACO(cCodReg, _cFilDest, _cFilOri)

	Local _cQuery := ""
	Local _cRet   := ""
	Local _cAliasACO := ""

	_cQuery := "SELECT ACO_DEST.ACO_CODREG "
	_cQuery += "FROM ACO010 ACO_ORI (NOLOCK), ACO010 ACO_DEST (NOLOCK) "
	_cQuery += "WHERE ACO_ORI.D_E_L_E_T_ = '' "
	_cQuery += "AND   ACO_ORI.D_E_L_E_T_ = '' "
	_cQuery += "AND   ACO_ORI.ACO_CODREG = '" + cCodReg + "'"
	_cQuery += "AND   ACO_ORI.ACO_FILIAL = '" + _cFilOri + "'"
	_cQuery += "AND   ACO_DEST.ACO_FILIAL = '" + _cFilDest + "'"
	_cQuery += "AND   ACO_DEST.ACO_CODCLI = ACO_ORI.ACO_CODCLI "
	_cQuery += "AND   ACO_DEST.ACO_LOJA = ACO_ORI.ACO_LOJA "
	_cQuery += "AND   ACO_DEST.ACO_CODTAB = ACO_ORI.ACO_CODTAB "
	_cQuery += "AND   ACO_DEST.ACO_CONDPG = ACO_ORI.ACO_CONDPG "

	_cAliasACO := MpSysOpenQuery(_cQuery)

	_cRet := (_cAliasACO)->ACO_CODREG

	(_cAliasACO)->(DbCloseArea())

Return(_cRet)

Static Function UpdRegACP(_nRecno, _cCodRegra)

	ACP->(DbGoTo(_nRecno))

	RecLock("ACP", .F.)
	ACP->ACP_CODREG := _cCodRegra
	MsUnlock()

Return()
