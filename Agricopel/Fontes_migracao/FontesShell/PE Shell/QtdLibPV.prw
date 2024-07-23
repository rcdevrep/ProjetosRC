#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"

/*/{Protheus.doc} NxExcCre
Ponto de Entrada que calcula a quantidade disponivel para ser liberada na filial 06 armazem 02
@author Cesar - SLA
@since 08/03/2018
@version P12
@return _lRet
@type function
/*/
User Function QtdLibPV(_cNumPV,_cItemPV,_nQtdSuge)

	Local _nQtdLibPV:= _nQtdSuge
	Local _nSaldo	:= 0

	If (cEmpAnt == "01" .And. cFilAnt == "06")

		_aAreasSC6 := SC6->(GetArea())
		_aAreasSB2 := SB2->(GetArea())

		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(xFilial("SC6")+_cNumPV+_cItemPV)

			If SC6->C6_LOCAL = '02'

				dbSelectArea("SB2")
				dbSetOrder(1)
				If dbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
					_nSaldo:= SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMP)
				EndIf

				If _nSaldo > 0

					If _nSaldo < _nQtdSuge

						_nQtdLibPV := _nSaldo

					Else

						_nQtdLibPV := _nQtdSuge

					EndIf

				Else

					_nQtdLibPV := 0

				EndIf

			EndIf

		EndIf

		RestArea(_aAreasSC6)
		RestArea(_aAreasSB2)

	EndIf

Return(_nQtdLibPV)