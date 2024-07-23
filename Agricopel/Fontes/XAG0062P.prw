#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062N
Valida se dados passados pelo parâmetro estão de acordo com o preço existente em ACP/ACO
Caso sejam divergentes, rotina retorna o valor existente em ACP/ACO usado na validação, se preço estiver ok retornará 0
Rotina só irá validar se o produto possuir informação em SB5.B5_XTPTRR
@author Leandro F Silveira
@since 13/11/2020
@example u_XAG0062N("000097")
@param nrsolic, chave
/*/
User Function XAG0062P(cCodProd, cCodCli, cLojaCli, cCodCond, cTabPreco, nPreco)

    Local _cRet    := {}
    Local _nPrcReg := 0

    If (SB5TpTrr(cCodProd))
        _nPrcReg := GetPrcReg(cCodProd, cCodCli, cLojaCli, cCodCond, cTabPreco)

        If (_nPrcReg > 0)
            If (_nPrcReg <> nPreco)
                _cRet := "Produto: " + AllTrim(cCodProd) + " - Preço correto: R$" + AllTrim(Transform(_nPrcReg, GetSX3Cache("UB_VRUNIT", "X3_PICTURE")))
            EndIf
        Else
            _cRet := "Produto: " + AllTrim(cCodProd) + " - Não possui regra de preço cadastrada!"
        EndIf
    EndIf

Return(_cRet)

Static Function SB5TpTrr(cCodProd)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _lRet      := .F.

    _cQuery := " SELECT SB5.B5_XTPTRR "
    _cQuery += " FROM " + RetSqlName("SB5") + " SB5 WITH (NOLOCK) "
    _cQuery += " WHERE SB5.D_E_L_E_T_ = '' "
    _cQuery += " AND   SB5.B5_COD = '" + cCodProd + "'"
    _cQuery += " AND   SB5.B5_FILIAL = '" + xFilial("SB5") + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

    _lRet := !Empty((_cAliasQry)->B5_XTPTRR)

    (_cAliasQry)->(DbCloseArea())

Return(_lRet)

Static Function GetPrcReg(cCodProd, cCodCli, cLojaCli, cCodCond, cTabPreco)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _nRet      := 0

    _cQuery := " SELECT COALESCE(ACP.ACP_PRECO,0) AS ACP_PRECO "
    _cQuery += " FROM " + RetSqlName("ACO") + " ACO WITH (NOLOCK), " + RetSqlName("ACP") + " ACP WITH (NOLOCK) "
    _cQuery += " WHERE ACP.ACP_CODREG = ACO.ACO_CODREG "

    _cQuery += " AND   ACO.D_E_L_E_T_ = '' "
    _cQuery += " AND   ACP.D_E_L_E_T_ = '' "
    _cQuery += " AND   ACO.ACO_FILIAL = '" + xFilial("ACO") + "'"
    _cQuery += " AND   ACP.ACP_FILIAL = '" + xFilial("ACP") + "'"

    _cQuery += " AND   ACO.ACO_CODCLI = '" + cCodCli + "'"
    _cQuery += " AND   ACO.ACO_LOJA   = '" + cLojaCli + "'"
    _cQuery += " AND   ACO.ACO_CODTAB = '" + cTabPreco + "'"
    _cQuery += " AND   ACO.ACO_CONDPG = '" + cCodCond + "'"

    _cQuery += " AND   ACP.ACP_CODPRO = '" + cCodProd + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

    _nRet := (_cAliasQry)->ACP_PRECO

    (_cAliasQry)->(DbCloseArea())

Return(_nRet)
