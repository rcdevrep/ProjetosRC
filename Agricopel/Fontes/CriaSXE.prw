#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} CriaSXE
Ponto de entrada para retornar o proximo numero que deve ser utilizado na inicializacao da numeracao
Este ponto de entrada e executado quando nao existir uma numeracao no SXE para o campo especificado.
@author Leandro F Silveira
@since 18/06/2020
@version 1.0
@return cRet. numero que serao utilizado pelo controle de numeracao. Caso seja retornado Nulo ( NIL ), a regra padrÃ£o do sistema serao aplicada. Esta funcao nunca deve retornar uma string vazia.
@param ParamIxb - Vetor contendo as informacoes que poderao ser utilizadas pelo P.E.
@param ParamIxb[1] - cAlias - Nome da tabela;
@param ParamIxb[2] - cCpoSX8 - Nome do campo que serao utilizado para verificar o proximo sequencial;
@param ParamIxb[3] - cAliasSX8 - Filial e nome da tabela na base de dados que serao utilizada para verificar o sequencial;
@param ParamIxb[4] - nOrdSX8 - Indice de pesquisa a ser usada na tabela.
/*/
User Function CriaSXE(lMostraFil)

    Local cNumRet   := Nil

	Local cAlias    := ParamIxb[1]
	// Local cCpoSx8   := ParamIxb[2]
	// Local cAliasSx8 := ParamIxb[3]
	// Local nOrdSX8   := ParamIxb[4]

    Local cAliImpXML := ""

    If (!Empty(cAlias))

        cAliImpXML := GetNewPar("MV_XSMSTB1", "")

        If (cAlias $ "SA1;SA2")
            cNumRet := CalcSA1SA2(cAlias)
        ElseIf (cAlias == cAliImpXML)
            cNumRet := CalcImpXML(cAliImpXML)
        ElseIf (cAlias == "SUA")
            cNumRet := CalcSUA()
        ElseIf (cAlias == "ZZE")
            cNumRet := CalcZZE()
        EndIf
    EndIf

Return(cNumRet)

// Numeração do importador de XML SMS001.prw - Provavelmente esta tabela é ZZ5 em todas as empresas
Static Function CalcImpXML(cAliImpXML)

    Local cNumCalc := Nil

    Local _cQuery := ""
    Local _cCampo := IIf(SubStr(cAliImpXML, 1, 1) == "S", SubStr(cAliImpXML, 2, 2), cAliImpXML)
    Local _cAliasQry := ""

    _cQuery := " SELECT MAX(" + _cCampo + "_SEQIMP) AS ULT_SEQ "
    _cQuery += " FROM " + RetSqlName(cAliImpXML) + " WITH (NOLOCK) "

    _cAliasQry := MpSysOpenQuery(_cQuery)

    cNumCalc := (_cAliasQry)->ULT_SEQ
    cNumCalc := Soma1(cNumCalc)

Return(cNumCalc)

Static Function CalcSA1SA2(cAlias)

    Local cNumCalc := Nil

    Local _cQuery := ""
    Local _cAliasQry := ""
    Local _cCampo := Substr(cAlias, 2,2) + "_COD"
    Local _nTamCampo := TamSX3(_cCampo)[1]

    _cQuery := " SELECT COALESCE(MAX(" + _cCampo + "),'0') AS ULT_SEQ "
    _cQuery += " FROM " + RetSqlName(cAlias) + " WITH (NOLOCK) "
    _cQuery += " WHERE D_E_L_E_T_ = '' "
    _cQuery += " AND " + _cCampo + " < '7' "
    _cQuery += " AND LEN(" + _cCampo + ") = " + Str(_nTamCampo)

    _cAliasQry := MpSysOpenQuery(_cQuery)

    cNumCalc := (_cAliasQry)->ULT_SEQ
    cNumCalc := Soma1(cNumCalc)

Return(cNumCalc)

Static Function CalcSUA(cAlias)

    Local cNumCalc := Nil

    Local _cQuery := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT MAX(UA_NUM) AS ULT_SEQ "
    _cQuery += " FROM " + RetSqlName("SUA") + " (NOLOCK) "
    _cQuery += " WHERE D_E_L_E_T_ = '' "
    _cQuery += " AND   UA_NUM < 'M' "
    _cQuery += " AND   UA_FILIAL = '" + xFilial("SUA") + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

    cNumCalc := (_cAliasQry)->ULT_SEQ
    cNumCalc := Soma1(cNumCalc)

Return(cNumCalc)

Static Function CalcZZE()

    Local cNumCalc := Nil

    Local _cQuery := ""
    Local _cAliasQry := ""

    _cQuery := " SELECT MAX(SUBSTRING(ZZE_ATEND, 2,5)) AS ULT_SEQ "
    _cQuery += " FROM " + RetSqlName("ZZE") + " (NOLOCK) "
    _cQuery += " WHERE SUBSTRING(ZZE_ATEND, 2,1) NOT IN ('Q','M') "
    _cQuery += " AND D_E_L_E_T_ = '' "
    _cQuery += " AND ZZE_FILIAL = '" + xFilial("ZZE") + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

    cNumCalc := (_cAliasQry)->ULT_SEQ
    cNumCalc := Soma1(cNumCalc)

Return(cNumCalc)
