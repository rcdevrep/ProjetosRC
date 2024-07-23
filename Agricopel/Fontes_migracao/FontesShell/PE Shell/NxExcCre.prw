#INCLUDE "PROTHEUS.CH"
//#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} NxExcCre
Ponto de Entrada que define se entra no processo de Alçadas Shell
@author Cesar - SLA
@since 09/03/2018
@version P12
@return _lRet
@type function
/*/
User Function NxExcCre(_cNumPV)

	Local _lRet      := .F.
	Local _cQuery    := ""
	Local _cAliasQry := ""
	Local _aAreaSA1  := {}
	Local _aAreaSC5  := {}

	If (cEmpAnt == "01" .And. cFilAnt == "06")
        _lRet := .T.

		// SE FOR AGRICOPEL, OU HOSPITAL JARAGUÁ, NÃO ENTRA NA ALÇADA SHELL
		If (AllTrim(SC5->C5_CLIENTE) = '00382') .Or. (AllTrim(SC5->C5_CLIENTE) = '27324')
			_lRet := .F.
		Else
			_aAreaSA1 := SA1->(GetArea())
			_aAreaSC5 := SC5->(GetArea())
 
			SC5->(DbSetOrder(1))
			SC5->(DbGoTop())
			If SC5->(DbSeek(xFilial("SC5")+_cNumPV))

				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())
				If (SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)))

					// SE CLIENTE FOR DA REDE POSTO AGRICOPEL
					// OU CLIENTE FOR HOSPITAL (27324)
					If (SA1->A1_POSTOAG == "1" .Or. SA1->A1_COD == "27324")

						// SE O PEDIDO NAO POSSUI ITENS FORA DO ARMAZEM 02
						_cQuery := " SELECT COUNT(SC6.C6_PRODUTO) AS QTDE_ITEM "
						_cQuery += " FROM " + RetSQLNAme("SC6") + " SC6 (NOLOCK) "
						_cQuery += " WHERE SC6.C6_LOCAL  != '02'
						_cQuery += " AND   SC6.C6_FILIAL  = '" + xFilial("SC6") + "'"
						_cQuery += " AND   SC6.C6_NUM     = '" + _cNumPV + "'"
						_cQuery += " AND   SC6.D_E_L_E_T_ = '' "

						_cAliasQry := GetNextAlias()
						TCQuery _cQuery NEW ALIAS (_cAliasQry)

						If ((_cAliasQry)->(QTDE_ITEM) == 0)
							_lRet := .F.
						EndIf

						(_cAliasQry)->(DbCloseArea())

					EndIf

				EndIf
			EndIf

			RestArea(_aAreaSA1)
			RestArea(_aAreaSC5)

		EndIf
	EndIf

Return(_lRet)