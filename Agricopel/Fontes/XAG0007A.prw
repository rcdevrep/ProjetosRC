#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} XAG0007A
//Função de quebra galho - manutenções na SF1 (Exclusão - Desviínculação/Revinculação com Tít a Pagar)
//Esta função desvincula os títulos
@author Leandro F Silveira
@since 05/10/2017
@version 1
@type function
/*/
User Function XAG0007A(nRecnoSF1)

	Local _lOk := .T.

	If Validar(nRecnoSF1)
		Begin Transaction

			If (!DesvincSF1(nRecnoSF1)) .Or. (!DesvincSE2(nRecnoSF1)) .Or. (!DesvincSE5(nRecnoSF1))
				DisarmTransaction()
				_lOk := .F.
			EndIf

		End Transaction

		If (_lOk)
			MsgInfo("Títulos desvinculados com sucesso!")
			U_XAG0007C()
		EndIf
	EndIf

Return()

Static Function Validar(nRecnoSF1)

	Local _lRetOK    := .T.
	Local _cQuery    := ""
	Local _cAliasQry := GetNextAlias()

	_cQuery += " SELECT "
	_cQuery += "   F1_DUPL "
	_cQuery += " FROM " +  RetSQLName("SF1") + " SF1 (NOLOCK) "
	_cQuery += " WHERE SF1.R_E_C_N_O_ = " + cValToChar(nRecnoSF1)

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	If (Empty((_cAliasQry)->F1_DUPL))
		Alert("Nota fiscal já encontra-se desvinculada de seu(s) título(s), ou não possui título para desvincular, ou é de devolução!")
		Return(.F.)
	EndIf

	(_cAliasQry)->(DbCloseArea())

	_cQuery := " SELECT COUNT(SE2.R_E_C_N_O_) AS QTDE
	_cQuery += " FROM " + RetSQLName("SE2") + " SE2 (NOLOCK), " +  RetSQLName("SF1") + " SF1 (NOLOCK) "
	_cQuery += " WHERE SE2.D_E_L_E_T_ = '' "
	_cQuery += " AND   SF1.F1_DOC     = SE2.E2_NUM "
	_cQuery += " AND   SF1.F1_PREFIXO = SE2.E2_PREFIXO "
	_cQuery += " AND   SF1.F1_FORNECE = SE2.E2_FORNECE "
	_cQuery += " AND   SF1.F1_LOJA    = SE2.E2_LOJA "
	_cQuery += " AND   SF1.F1_EMISSAO = SE2.E2_EMISSAO "
	_cQuery += " AND   SE2.E2_TIPO    = 'NF' "
	_cQuery += " AND   (SE2.E2_NUMBOR != '' OR SE2.E2_SALDO != E2_VALOR) "
	_cQuery += " AND   SF1.R_E_C_N_O_ = " + cValToChar(nRecnoSF1)

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	If ((_cAliasQry)->QTDE = 0)
		Alert("Nota fiscal não possui títulos movimentados, favor utilizar a rotina de exclusão padrão do sistema!")
		Return(.F.)
	EndIf

	(_cAliasQry)->(DbCloseArea())

Return(_lRetOK)

Static Function DesvincSF1(nRecnoSF1)

	Local _cQuery := ""

	_cQuery := " UPDATE " + RetSQLName("SF1") + " SET "
	_cQuery += "   F1_DUPL = '' "
	_cQuery += " WHERE R_E_C_N_O_ = " + cValToChar(nRecnoSF1)
	_cQuery += "   AND F1_DUPL    = F1_DOC "

	If (TCSQLExec(_cQuery) < 0)
		Alert("TCSQLError() " + TCSQLError())
		Return .F.
	EndIf

Return(.T.)

Static Function DesvincSE2(nRecnoSF1)

	Local _cQuery := ""

	_cQuery := " UPDATE " + RetSQLName("SE2") + " SET "
	_cQuery += "   E2_TIPO = 'LFS' "
	_cQuery += " FROM " + RetSQLName("SF1") + " SF1 "
	_cQuery += " WHERE SF1.R_E_C_N_O_ = " + cValToChar(nRecnoSF1)
	_cQuery += " AND   SF1.F1_DOC     = E2_NUM "
	_cQuery += " AND   SF1.F1_PREFIXO = E2_PREFIXO "
	_cQuery += " AND   SF1.F1_FORNECE = E2_FORNECE "
	_cQuery += " AND   SF1.F1_LOJA    = E2_LOJA "
	_cQuery += " AND   SF1.F1_EMISSAO = E2_EMISSAO "
	_cQuery += " AND   E2_TIPO = 'NF' "

	If (TCSQLExec(_cQuery) < 0)
		Alert("TCSQLError() " + TCSQLError())
		Return .F.
	EndIf

Return(.T.)

Static Function DesvincSE5(nRecnoSF1)

	Local _cQuery := ""

	_cQuery := " UPDATE " + RetSQLName("SE5") + " SET "
	_cQuery += "   E5_TIPO = 'LFS' "
	_cQuery += " FROM " + RetSQLName("SF1") + " SF1 "
	_cQuery += " WHERE SF1.R_E_C_N_O_ = " + cValToChar(nRecnoSF1)
	_cQuery += " AND   SF1.F1_DOC     = E5_NUMERO "
	_cQuery += " AND   SF1.F1_PREFIXO = E5_PREFIXO "
	_cQuery += " AND   SF1.F1_FORNECE = E5_FORNECE "
	_cQuery += " AND   SF1.F1_LOJA    = E5_LOJA "
	_cQuery += " AND   E5_DATA       >= SF1.F1_EMISSAO "
	_cQuery += " AND   E5_TIPO        = 'NF' "

	If (TCSQLExec(_cQuery) < 0)
		Alert("TCSQLError() " + TCSQLError())
		Return .F.
	EndIf

Return(.T.)