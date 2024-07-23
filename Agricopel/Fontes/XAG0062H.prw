#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062H
Processa as alterações de preços TRR
Se aprovadas, grava ACO / ACP chamando XAG0062I
Se não aprovadas, chama XAG0062J para enviar e-mail de aprovação
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062D(cCodCli)
@param cNumSolic, varchar, Codigo da solicitação
/*/
User Function XAG0062H(cNumSolic)

    If (IsAprov(cNumSolic))
        UpdPrecos(cNumSolic)
    Else
        EnviarWF(cNumSolic)
    EndIf

Return()

Static Function IsAprov(cNumSolic)

    Local _lRet   := .F.
    Local _cAlias := ""
    Local _cQuery := ""

    _cQuery += " SELECT COUNT(ZDI_NUM) AS QTDE "
    _cQuery += " FROM " + RetSQLName("ZDI") + " ZDI (NOLOCK), " + RetSQLName("ZDH") + " ZDH (NOLOCK) "
    _cQuery += " WHERE ZDI.ZDI_NUM = '" + cNumSolic + "'"
    _cQuery += "   AND ZDI.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDI.ZDI_FILIAL = '" + FWFilial("ZDI") + "'"
    _cQuery += "   AND ZDH.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH.ZDH_FILIAL = '" + FWFilial("ZDH") + "'"
    _cQuery += "   AND ZDI.ZDI_NUM = ZDH.ZDH_NUM "
    _cQuery += "   AND ZDI.ZDI_CODCLI = ZDH.ZDH_CODCLI "
    _cQuery += "   AND ZDI.ZDI_LOJA = ZDH.ZDH_LOJA "
    _cQuery += "   AND ZDI.ZDI_MOTIVO != '' "
    _cQuery += "   AND ZDH.ZDH_STATUS != 'P' " // Se status = "P" é porque foi aprovado pelo workflow

    _cAlias := MpSysOpenQuery(_cQuery)

    _lRet := (_cAlias)->QTDE == 0

    (_cAlias)->(DbCloseArea())

Return(_lRet)

Static Function UpdPrecos(cNumSolic)

    U_XAG0062I(cNumSolic)

Return()

Static Function EnviarWF(cNumSolic)

    U_XAG0062J(cNumSolic)

Return()
