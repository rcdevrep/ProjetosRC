#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062M
Rotina chamada quando é aprovada a solicitação pelo workflow. 
Atualiza o status da solicitação para "P" (próvisório) e chama XAG0062H para atualizar os preços (irá atualizar status para 'B')
@author Leandro F Silveira
@since 13/11/2020
@example u_XAG0062M("000097")
@param nrsolic, chave
/*/
User Function XAG0062M(_cNrSolic, _cObsApr, _aPrecos)

	ZDHUpdSt(_cNrSolic, _cObsApr)
    ZDIUpdPrc(_cNrSolic, _aPrecos)
    U_XAG0062H(_cNrSolic)

Return(.T.)

Static Function ZDHUpdSt(_cNrSolic, _cObsApr, _aPrecos)

    Local _cQuery := ""
    Local _cObs   := StrTran(_cObsApr, "'", "")

    If Len(_cObsApr) > 250
        _cObsApr := Substr(_cObsApr, 1, 250)
    EndIf

    _cQuery += " UPDATE " + RetSqlName("ZDH") + " SET "
    _cQuery += "   ZDH_STATUS = 'P', "
    _cQuery += "   ZDH_OBSAPR = '" + AllTrim(_cObs) + "'"
    _cQuery += " WHERE ZDH_NUM = '" + _cNrSolic + "'"
    _cQuery += "   AND D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH_FILIAL = '" + FWFilial("ZDH") + "'"

    TCSQLExec(_cQuery)

Return(.T.)

Static Function ZDIUpdPrc(_cNrSolic, _aPrecos)

    Local _cQuery := ""
    Local nCount  := 1

    For nCount := 1 To Len(_aPrecos)

        _cQuery := " UPDATE " + RetSqlName("ZDI") + " SET "
        _cQuery += "   ZDI_PRCAPR = " + _aPrecos[nCount][2]
        _cQuery += " WHERE ZDI_NUM = '" + _cNrSolic + "'"
        _cQuery += "   AND D_E_L_E_T_ = '' "
        _cQuery += "   AND ZDI_FILIAL = '" + FWFilial("ZDI") + "'"
        _cQuery += "   AND ZDI_TPPROD = '" + _aPrecos[nCount][1] + "'"

        TCSQLExec(_cQuery)
    End

Return()
