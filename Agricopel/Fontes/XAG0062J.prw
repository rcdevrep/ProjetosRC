#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062J
Envio e-mail de aprovação das solicitações de reajuste de preços

Motivos de bloqueio X Nível aprovação:
M1=Preço menor que o da faixa -> Aprova N1
M2=Desconto máximo nível 1 (parâmetro DESC_MAX_NV1) -> Aprova N2
M3=Desconto máximo nível 2 (parâmetro DESC_MAX_NV2) -> Aprova N3
MG=Diferença de preços (Evolux/Não-Evolux) menor que Gap mínimo -> Aprova N1
MZ=Preço de faixa e/ou preço solicitado zerado -> Aprova N3

@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0062D(cNumSolic)
@param cNumSolic, varchar, Codigo da solicitação
/*/
User Function XAG0062J(cNumSolic)

    Local aMotNV2 := {"M2"}
    Local aMotNV3 := {"M3","MZ"}

    If TemReprov(cNumSolic, aMotNV3)
        EnvEmail(cNumSolic, 3)
    ElseIf TemReprov(cNumSolic, aMotNV2)
        EnvEmail(cNumSolic, 2)
    Else
        EnvEmail(cNumSolic, 1)
    EndIf

Return()

Static Function TemReprov(cNumSolic, aMotivos)

    Local _lRet    := .T.
    Local _cAlias  := ""
    Local _cQuery  := ""
    Local _cMotQry := ""
    Local _nI      := 0

    _cQuery += " SELECT COUNT(ZDI.ZDI_NUM) AS QTDE "
    _cQuery += " FROM " + RetSQLName("ZDI") + " ZDI (NOLOCK) "
    _cQuery += " WHERE ZDI.ZDI_NUM = '" + cNumSolic + "'"
    _cQuery += "   AND ZDI.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDI.ZDI_FILIAL = '" + FWFilial("ZDI") + "'"

    For _nI := 1 To Len(aMotivos)

        If (!Empty(_cMotQry))
            _cMotQry += " OR "
        EndIf

        _cMotQry += " ZDI.ZDI_MOTIVO LIKE '%" + alltrim(aMotivos[_nI] )+ "%' "
    End

    _cQuery += "AND (" + _cMotQry + ")"

    
    _cAlias := MpSysOpenQuery(_cQuery)

    iF (_cAlias)->QTDE == 0
        _lRet := .F. 
    Endif 

    (_cAlias)->(DbCloseArea())

Return _lRet

Static Function EnvEmail(cNumSolic, nNivelApr)

    Local cChaveApr  := CalcChvApr()
    Local cDestEmail := ""
    Local cHtml      := GerarHTML(cNumSolic, cChaveApr)
    Local cTitulo    := ""

	Do Case 
		Case nNivelApr == 1
			cDestEmail := U_XAG0062G("EMAIL_APROVADOR_NV1", .T., .F.)
		Case nNivelApr == 2
			cDestEmail := U_XAG0062G("EMAIL_APROVADOR_NV2", .T., .F.)
		Case nNivelApr == 3
			cDestEmail := U_XAG0062G("EMAIL_APROVADOR_NV3", .T., .F.)
	End Case

    If (U_XAGAMB() <> 0)
        cTitulo += "[TESTE] - "
    EndIf

    cTitulo += "Solicitação de alteração de Preços TRR - Nr: " + cNumSolic

    u_envMailA(cDestEmail,cTitulo ,cHtml ,2,,"",    ,    ,  "dox.price@agricopel.com.br" )
   
    UpdStatus(cNumSolic, cChaveApr)
Return()

Static Function UpdStatus(cNumSolic, cChaveApr)

    Local _cQuery := ""

    _cQuery += " UPDATE " + RetSqlName("ZDH") + " SET "
    _cQuery += "   ZDH_STATUS = 'E', "
    _cQuery += "   ZDH_CHVAPR = '" + cChaveApr + "'"
    _cQuery += " WHERE ZDH_NUM = '" + cNumSolic + "'"
    _cQuery += "   AND D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH_FILIAL = '" + FWFilial("ZDH") + "'"

    TCSQLExec(_cQuery)

Return()

Static Function CalcChvApr()

    Local _aLetras := {"A","B","C","D","E","F","G","H","I","J","X","Y","Z"}
    Local _cRet    := ""

    While (Len(_cRet) < 10)
        _cRet += AllTrim(Str(Randomize(1,100)))
        _cRet += AllTrim(_aLetras[Randomize(1,Len(_aLetras))])
    End

    _cRet := Substr(_cRet,1,10)

Return(_cRet)

Static Function GerarHTML(cNumSolic, cChaveApr)

    Local _cHTML := ""
    Local _nAmb  := 0 

    _cHTML += "Solicitação de preços pendente de aprovação" + "<BR>"
    _cHTML += "Link para análise e aprovação/reprovação: " + "<BR>"

    _nAmb := U_XAGAMB()

    If (_nAmb == 0)
        _cHTML += "http://protheus.agricopel.com.br:1782/rest_prd/RestPrcTRR/"
    Elseif (_nAmb == 2)
        _cHTML += "http://192.168.0.155:1782/rest_prd/RestPrcTRR/"
    Else
        _cHTML += "http://192.168.0.215:1772/rest_prd/RestPrcTRR/"
    EndIf

    _cHTML += cEmpAnt + "/" + AllTrim(FWFilial()) + "/" + cNumSolic + "/" + cChaveApr

Return(_cHTML)
