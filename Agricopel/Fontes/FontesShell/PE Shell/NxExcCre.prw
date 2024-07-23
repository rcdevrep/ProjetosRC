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

	Local _lRet      := .T.
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

				DbSelectarea('SA1')
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())
				If (SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)))

					// SE CLIENTE FOR DA REDE POSTO AGRICOPEL
					// OU CLIENTE FOR HOSPITAL (27324)
					If (SA1->A1_POSTOAG == "1" .Or. SA1->A1_COD == "27324")

						// SE O PEDIDO NAO POSSUI ITENS FORA DO ARMAZEM 02
						_cQuery := " SELECT COUNT(SC6.C6_PRODUTO) AS QTDE_ITEM "
						_cQuery += " FROM " + RetSQLNAme("SC6") + " SC6 (NOLOCK) "
						_cQuery += " WHERE SC6.C6_LOCAL  != '02' "
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

	if _lRet .AND. (cEmpAnt == "01" .OR. cEmpAnt == "11" .OR. cEmpAnt == "15" )

		//Quando Querosene e pedido oriundo do CallCenter, debita Valor de St. 
		If FunName() == "TMKA271" .Or. FunName() == "TMKA380"

			PrcListQR(_cNumPV)

		Endif
	Endif 

Return(_lRet)


// Verifica se Existem itens com querosene e debita valor de ST 
// do preço de lista caso ainda nao tenha debitado
Static Function PrcListQR(xNumPV)

	Local _cQuery    := ""
	Local _cAliasQry := ""

	_cQuery := " SELECT C6.R_E_C_N_O_ as RECNOSC6,ROUND(UB_PRCTAB -( ROUND(UB_XVLST/UB_QUANT,2) ),2 ) AS PRCLISTQR "
	_cQuery += " FROM "+RetSqlName('SUB')+"(NOLOCK) UB "
	_cQuery += " INNER JOIN  "+RetSqlName('SB1')+"(NOLOCK) B1 ON B1_COD = UB_PRODUTO AND  "
	_cQuery += " B1_FILIAL = UB_FILIAL AND B1.D_E_L_E_T_ = '' AND B1_TIPO = 'QR'  "
	_cQuery += " INNER JOIN  "+RetSqlName('SC6')+"(NOLOCK) C6 ON C6_FILIAL = UB_FILIAL AND C6_NUM = UB_NUMPV AND C6_ITEM = UB_ITEMPV "
	_cQuery += " AND C6.D_E_L_E_T_ = '' "
	_cQuery += " WHERE UB_NUMPV  = '"+xNumPV+"' "
	_cQuery += " AND UB_XVLST > 0  "
	_cQuery += " AND ROUND(UB_PRCTAB -( ROUND(UB_XVLST/UB_QUANT,2) ),2 ) <> C6_PRCLIST "
	_cQuery += " AND UB.D_E_L_E_T_ = ''   "

	_cAliasQry := GetNextAlias()
	
	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	While (_cAliasQry)->(!eof())

		DbSelectarea('SC6')
		dbgoto((_cAliasQry)->RECNOSC6)
		Reclock('SC6',.F.)
			SC6->C6_PRCLIST := (_cAliasQry)->PRCLISTQR
		SC6->(MsUnlock())
		
		(_cAliasQry)->(dbskip())
	Enddo

	(_cAliasQry)->(DbCloseArea())

Return
