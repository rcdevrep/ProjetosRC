#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0076
Gatilho que avisa televendas Lubs de que ela estão fazendo mais do que 80 agendamento no mesmo dia
Chamado a partir do campo UA_PROXLIG
@author Leandro F Silveira
@since 28/06/2021
/*/

User Function XAG0076()

    Local _cOper     := TkOperador()
    Local _cDtAgenda := DTOS(M->UA_PROXLIG)
    Local _xRetorno  := &(ReadVar())
    Local _nQtdSU6   := 0
    Local _nQtDias   := 0

    If (!Empty(_cDtAgenda))

        _nQtDias := GetQtDias(_cOper)

        If (!Empty(_nQtDias))
            _nQtdSU6 := GetQtdSU6(_cOper, _cDtAgenda)

            If (_nQtdSU6 > _nQtDias)
                Aviso("Número de agendamentos", "Atenção, já constam " + cValToChar(_nQtdSU6) + " agendamentos para seu operador para a data de " + DTOC(STOD(_cDtAgenda)) + "!")
            EndIf
        EndIf
    EndIf

Return(_xRetorno)

Static Function GetQtdSU6(_cOper, _cDtAgenda)

    Local _nQtdSU6 := 0
    Local _cAlias  := ""
    Local _cQuery  := ""

    _cQuery += " SELECT COUNT(U6_CODIGO) AS QTDE "
    _cQuery += " FROM " + RetSqlName("SU6") + " SU6 (NOLOCK) "
    _cQuery += " WHERE U6_FILIAL = '" + xFilial("SU6") + "' "
    _cQuery += " AND   D_E_L_E_T_ = '' "
    _cQuery += " AND   U6_DATA = '" + _cDtAgenda + "' "
    _cQuery += " AND   U6_ENTIDA = 'SA1' "
    _cQuery += " AND   U6_STATUS = '1' "
    _cQuery += " AND   U6_OPERAD = '" + _cOper + "' "

    _cAlias := MpSysOpenQuery(_cQuery)

    _nQtdSU6 := (_cAlias)->QTDE

    (_cAlias)->(DbCloseArea())

Return(_nQtdSU6)

Static Function GetQtDias(_cOper)

    Local _nRet    := 0
    Local _cAlias  := ""
    Local _cQuery  := ""

    _cQuery += " SELECT U7_XQTAGEN "
    _cQuery += " FROM " + RetSqlName("SU7") + " SU7 (NOLOCK) "
    _cQuery += " WHERE U7_FILIAL = '" + xFilial("SU7") + "' "
    _cQuery += " AND   D_E_L_E_T_ = '' "
    _cQuery += " AND   U7_COD = '" + _cOper + "' "

    _cAlias := MpSysOpenQuery(_cQuery)

    _nRet := (_cAlias)->U7_XQTAGEN

    (_cAlias)->(DbCloseArea())

Return(_nRet)
