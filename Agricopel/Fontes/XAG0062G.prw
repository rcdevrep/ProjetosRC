#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062E
Busca de parâmetros das regras de solicitação de reajuste de preço
@author Leandro F Silveira
@since 20/07/2020
@example U_XAG0062G()
/*/
User Function XAG0062G(cNomeParam, ExecTrim, IncAspas)

	Local _cQuery := ""
	Local _cAlias := ""
	Local _xRet   := ""

	Default ExecTrim := .T.
	Default IncAspas  := .F.

	_cQuery := " SELECT ZDF_PROPR1 "
	_cQuery += " FROM " + RetSqlName("ZDF") + " WITH (NOLOCK) "
	_cQuery += " WHERE ZDF_PARAM = '" + cNomeParam + "'"
	_cQuery += " AND D_E_L_E_T_ = '' "
	_cQuery += " AND ZDF_FILIAL = '" + FWFilial("ZDF") + "'"
	conout(_cQuery)
	_cAlias := MpSysOpenQuery(_cQuery)

	_xRet := (_cAlias)->ZDF_PROPR1

	If (ExecTrim)
		_xRet := AllTrim(_xRet)
	EndIf

	If (IncAspas)
		_xRet := "'" + _xRet + "'"
	EndIf

	(_cAlias)->(DbCloseArea())

Return(_xRet)
