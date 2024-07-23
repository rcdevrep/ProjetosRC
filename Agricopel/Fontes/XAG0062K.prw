#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} XAG0062K
WebService para aprovação / reprovação das solicitações de reajuste de preço (ZDH / ZDI)
@author Leandro F Silveira
@since 26/10/2020
@example u_XAG0062K(cNumSolic)
@param nrsolic, chave
/*/
User Function XAG0062K()
Return()

WSRESTFUL RestPrcTRR DESCRIPTION "Aprovação/reprovação da solicitação de alteração de preços TRR"

WSMETHOD GET DESCRIPTION "Formulário de aprovação de alteração de preços TRR" PATH "/RestPrcTRR/{empresa}/{filial}/{nrsolic}/{chave}" PRODUCES TEXT_HTML

WSMETHOD POST APROV DESCRIPTION "Aprovação da solicitação de alteração de preços TRR" PATH "/RestPrcTRR/aprov/{empresa}/{filial}/{nrsolic}/{chave}" PRODUCES TEXT_HTML
WSMETHOD POST REPROV DESCRIPTION "Reprovação da solicitação de alteração de preços TRR" PATH "/RestPrcTRR/reprov/{empresa}/{filial}/{nrsolic}/{chave}" PRODUCES TEXT_HTML

END WSRESTFUL

WSMETHOD GET WSSERVICE RestPrcTRR

    Local cRetHTML  := ""
    Local _cNrSolic := ""
    Local _cChave   := ""
    Local _cEmpre   := ""
    Local _cFilial  := ""

    _cEmpre   := ::aURLParms[1]
    _cFilial  := ::aURLParms[2]
    _cNrSolic := ::aURLParms[3]
    _cChave   := ::aURLParms[4]

	//RPCSetType(3)
	//RPCSetEnv(_cEmpre, _cFilial)

	RPCClearEnv()
	RPCSetEnv(_cEmpre, _cFilial,"USERREST","*R3st2021","","",{"ZDH"})

	bError := ErrorBlock({|oError|cRetHTML := RetErro(oError)})
	BEGIN SEQUENCE

        cRetHTML := ValSolic(_cNrSolic, _cChave)

        If Empty(cRetHTML)
            cRetHTML := u_XAG0062L(_cEmpre, _cFilial, _cNrSolic, _cChave)
        EndIf

	END SEQUENCE
	ErrorBlock(bError)

    RPCClearEnv()

    ::SetContentType("text/html; charset=iso-8859-1")
    ::SetResponse(cRetHTML)
    ::SetStatus(200)

Return(.T.)

WSMETHOD POST APROV WSSERVICE RestPrcTRR

    Local cRetHTML   := ""
    Local _cNrSolic  := ""
    Local _cChave    := ""
    Local _cEmpre    := ""
    Local _cFilial   := ""
    Local bError     := Nil
    Local _cObsApr   := ""
    Local _cJsonReq  := ""
    Local _oJsonReq  := Nil
    Local _cProds    := ""
    Local _aPrecos   := {}

    _cEmpre   := ::aURLParms[2]
    _cFilial  := ::aURLParms[3]
    _cNrSolic := ::aURLParms[4]
    _cChave   := ::aURLParms[5]

    _cJsonReq  := ::GetContent()

    _oJsonReq := JsonObject():new()
    _oJsonReq:fromJson(_cJsonReq)

    _cObsApr := _oJsonReq:GetJsonText("observacao")
    _cProds  := _oJsonReq:GetJsonText("produtos")

    _aPrecos := CalcAPreco(_cProds)

    RPCClearEnv()
	RPCSetEnv(_cEmpre, _cFilial,"USERREST","*R3st2021","","")

	bError := ErrorBlock({|oError|cRetHTML := RetErro(oError)})
	BEGIN SEQUENCE

        cRetHTML := ValSolic(_cNrSolic, _cChave)

        If Empty(cRetHTML)

            IF (U_XAG0062M(_cNrSolic, _cObsApr, _aPrecos))
                cRetHTML := "A solicita&ccedil;&atilde;o Nr " + _cNrSolic + " foi aprovada com sucesso!"
            Else
                cRetHTML := "Não foi possível concluir a opera&ccedil;&atilde;o de aprova&ccedil;&atilde;o da solicita&ccedil;&atilde;o Nr " + _cNrSolic + "!"
            EndIf
        EndIf

	END SEQUENCE
	ErrorBlock(bError)

    ::SetContentType("text/html; charset=iso-8859-1")
    ::SetResponse(cRetHTML)
    ::SetStatus(200)

    RPCClearEnv()

Return(.T.)

WSMETHOD POST REPROV WSSERVICE RestPrcTRR

    Local cRetHTML   := ""
    Local _cNrSolic  := ""
    Local _cChave    := ""
    Local _cEmpre    := ""
    Local _cFilial   := ""
    Local bError     := Nil
    Local _cJsonReq  := ""
    Local _oJsonReq  := Nil

    _cEmpre   := ::aURLParms[2]
    _cFilial  := ::aURLParms[3]
    _cNrSolic := ::aURLParms[4]
    _cChave   := ::aURLParms[5]

    _cJsonReq := ::GetContent()

    _oJsonReq := JsonObject():new()
    _oJsonReq:fromJson(_cJsonReq)

    _cObsApr := _oJsonReq:GetJsonText("observacao")

   // RPCSetType(3)
    //RPCSetEnv(_cEmpre, _cFilial)
    
	RPCClearEnv()
	RPCSetEnv(_cEmpre, _cFilial,"USERREST","*R3st2021","","",{"ZDH"})

	bError := ErrorBlock({|oError|cRetHTML := RetErro(oError)})
	BEGIN SEQUENCE

        cRetHTML := ValSolic(_cNrSolic, _cChave)

        If Empty(cRetHTML)

            IF (U_XAG0062N(_cNrSolic, _cObsApr))
                cRetHTML := "A solicita&ccedil;&atilde;o Nr " + _cNrSolic + " foi reprovada com sucesso!"
            Else
                cRetHTML := "Não foi possível concluir a opera&ccedil;&atilde;o de reprova&ccedil;&atilde;o da solicita&ccedil;&atilde;o Nr " + _cNrSolic + "!"
            EndIf
        EndIf

	END SEQUENCE
	ErrorBlock(bError)

    ::SetContentType("text/html; charset=iso-8859-1")
    ::SetResponse(cRetHTML)
    ::SetStatus(200)

    RPCClearEnv()

Return(.T.)

Static Function ValSolic(_cNrSolic, _cChave)

    Local cAliasZDH := ""
    Local cRetHTML  := ""

    cAliasZDH := GetZDH(_cNrSolic)

    If ((cAliasZDH)->ZDH_CHVAPR == _cChave)
        If ((cAliasZDH)->ZDH_STATUS <> "E")
            cRetHTML := "Solicita&ccedil;&atilde;o não está pendente de aprova&ccedil;&atilde;o!"
        EndIf
    Else
        cRetHTML := "Chave de aprova&ccedil;&atilde;o inválida para a solicita&ccedil;&atilde;o informada!"
    EndIf

    (cAliasZDH)->(DbCloseArea())

Return(cRetHTML)

Static Function GetZDH(cNumSolic)

    Local _cQuery    := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT "
    _cQuery += "    ZDH_STATUS, "
    _cQuery += "    ZDH_CHVAPR  "
    _cQuery += " FROM " + RetSqlName("ZDH") + " ZDH (NOLOCK) "
    _cQuery += " WHERE ZDH.ZDH_NUM = '" + cNumSolic + "'"
    _cQuery += "   AND ZDH.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH.ZDH_FILIAL = '" + FWFilial("ZDH") + "'"

    conout(" FILIAL " + FwFilial("ZDH") + " CfILANT" +cFilAnt+ " cEmpAnt" + cEmpAnt)

    _cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function RetErro(oError)

   Local cRet := oError:ErrorStack

Return(cRet)

Static Function CalcAPreco(_cProds)

    Local cTagTpProd := "tpprod_"
    Local nCount     := 1
    Local _aPrecos   := {}
    Local _oJsonTmp  := Nil
    Local _aNomes    := {}
    Local _cNome     := ""

    _oJsonTmp := JsonObject():new()
    _oJsonTmp:fromJson(_cProds)

    _aNomes := _oJsonTmp:GetNames()

    For nCount := 1 To Len(_aNomes)
        _cNome := _aNomes[nCount]
        aAdd(_aPrecos, {StrTran(_cNome, cTagTpProd, ""), _oJsonTmp:GetJsonText(_cNome)})
    End

Return(_aPrecos)
