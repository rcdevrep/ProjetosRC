#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062N
Rotina chamada quando é reprovada a solicitação pelo workflow. 
Atualiza o status da solicitação para "R"
@author Leandro F Silveira
@since 13/11/2020
@example u_XAG0062M("000097")
@param nrsolic, chave
/*/
User Function XAG0062N(_cNrSolic, _cObsApr)

    UpdStatus(_cNrSolic, _cObsApr)
    EnvWFRepr(_cNrSolic)

Return(.T.)

Static Function UpdStatus(_cNrSolic, _cObsApr)

    Local _cQuery := ""

    _cQuery += " UPDATE " + RetSqlName("ZDH") + " SET "
    _cQuery += "   ZDH_STATUS = 'R', "
    _cQuery += "   ZDH_OBSAPR = '" + _cObsApr + "',"
    _cQuery += "   ZDH_DTAPRP = CONVERT(VARCHAR(30),CURRENT_TIMESTAMP,20 ) "
    _cQuery += " WHERE ZDH_NUM = '" + _cNrSolic + "'"
    _cQuery += "   AND D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH_FILIAL = '" + FWFilial("ZDH") + "'"

    TCSQLExec(_cQuery)

Return(.T.)

Static Function EnvWFRepr(_cNrSolic)

    U_XAG0062O(_cNrSolic)

Return()
