#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062N
Efetua o envio de e-mail para notificar se a solicitação foi aprovada ou reprovada
@author Leandro F Silveira
@since 13/11/2020
@example u_XAG0062N("000097")
@param nrsolic, chave
/*/
User Function XAG0062O(_cNrSolic)

    Local _cAliasZDH := ""
    Local _cAliasZDI := ""
    Local _cHTML     := ""
    Local _cTitulo   := ""
    Local _cBCC      := ""
    Local aDest      := {}
    Local cDest      := ""
    Local nCount     := 0
    CONOUT('XAG0062O: INICIO '+_cNrSolic)
    _cAliasZDH := GetZDH(_cNrSolic)
    _cAliasZDI := GetZDI(_cNrSolic)

    If ((_cAliasZDH)->ZDH_STATUS == "B")
        _cTitulo += "Aprovação de solicitação de alteração de Preços TRR - Nr: " + _cNrSolic + " - Emp: " + cEmpAnt + "-" + FwFilial()
        _cHTML  := ProcHTML(.T., _cAliasZDH, _cAliasZDI)
    Else
        _cTitulo += "Reprovação de solicitação de alteração de Preços TRR - Nr: " + _cNrSolic + " - Emp: " + cEmpAnt + "-" + FwFilial()
        _cHTML  := ProcHTML(.F., _cAliasZDH, _cAliasZDI)
    EndIf

    aDest := CalcDest(_cNrSolic)
    CONOUT('XAG0062O ' +_cNrSolic + ' adest:') 
    CONOUT(len(aDest)) 
    If Len(aDest) > 0
        cDest := aDest[1]

        For nCount := 2 To Len(aDest)
            cDest += ";" + aDest[nCount]
        End
    End

    If (U_XAGAMB() <> 0)
        _cTitulo := "[AMBIENTE DE TESTES] - " + _cTitulo
    EndIf

    //Se não tem destinatario manda para meu email  
    If alltrim(cDest) == ""
        cDest := 'dox.price@agricopel.com.br'
        _cTitulo := '(ERRO:DESTINATARIO VAZIO) '+_cTitulo 
    Endif

    _cBCC := U_XAG0062G("EMAIL_CC_NOTIFICACAO", .T., .F.)
    CONOUT('XAG0062O ' +_cNrSolic +' - _cBCC ' +  _cBCC) 
    CONOUT('XAG0062O ' +_cNrSolic +' - cDest ' +  cDest) 
    CONOUT('XAG0062O ' +_cNrSolic +' - _cTitulo ' +  _cTitulo) 
    u_envMailA(cDest ,_cTitulo,_cHTML   ,2     ,    ,_cBCC,    ,    ,  "dox.price@agricopel.com.br"    )
  
    (_cAliasZDH)->(DbCloseArea())
    (_cAliasZDI)->(DbCloseArea())

Return(.T.)

Static Function GetZDH(_cNrSolic)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _aCateg    := CBoxToArr("ZDH_CATEGO")
    Local nCount     := 1

    _cQuery := " SELECT "
    _cQuery += "    ZDH_FILIAL, "
    _cQuery += "    ZDH_NUM, "
    _cQuery += "    ZDH_CODCLI, "
    _cQuery += "    ZDH_LOJA, "
    _cQuery += "    ZDH_HORA, "
    _cQuery += "    ZDH_DATA, "
    _cQuery += "    ZDH_CONDPG, "
    _cQuery += "    ZDH_CODTAB, "
    _cQuery += "    ZDH_STATUS, "
    _cQuery += "    ZDH_NOMCLI, "
    _cQuery += "    ZDH_VEND, "

    _cQuery += "    ZDH_CATEGO, "

    _cQuery += "    CASE ZDH_CATEGO "
    For nCount := 1 to Len(_aCateg)
        _cQuery += "   WHEN '" + _aCateg[nCount][1] + "' THEN '" + _aCateg[nCount][2] + "'"
    End
    _cQuery += "    END AS DSCATEGO, "

    _cQuery += "    ZDH_FAIXA, "
    _cQuery += "    ZDH_MOTIVO, "
    _cQuery += "    ZDH_CHVAPR, "
    _cQuery += "    ZDH_USERGI, "
    _cQuery += "    ZDH_USERGA, "
    _cQuery += "    ZDH_OBSAPR, "
    _cQuery += "    ZDH_OBSSOL, "
    _cQuery += "    D_E_L_E_T_, "
    _cQuery += "    R_E_C_N_O_, "
    _cQuery += "    R_E_C_D_E_L_ "
    _cQuery += " FROM " + RetSqlName("ZDH") + " ZDH (NOLOCK) "
    _cQuery += " WHERE ZDH.ZDH_NUM = '" + _cNrSolic + "'"
    _cQuery += "   AND ZDH.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH.ZDH_FILIAL = '" + FWFilial("ZDH") + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function GetZDI(_cNrSolic)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _aTpProd   := CBoxToArr("ZDI_TPPROD")
    Local nCount     := 1

    _cQuery := " SELECT DISTINCT(ZDI_PRCNOV), "
    _cQuery += "    ZDI_PRCAPR, "

    _cQuery += "    CASE ZDI_TPPROD "
    For nCount := 1 to Len(_aTpProd)
        _cQuery += "   WHEN '" + _aTpProd[nCount][1] + "' THEN '" + _aTpProd[nCount][2] + "'"
    End
    _cQuery += "    END AS DSTPPROD "

    _cQuery += " FROM " + RetSqlName("ZDI") + " ZDI (NOLOCK) "
    _cQuery += " WHERE ZDI.ZDI_NUM = '" + _cNrSolic + "'"
    _cQuery += "   AND ZDI.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDI.ZDI_FILIAL = '" + FWFilial("ZDI") + "'"

    _cQuery += " ORDER BY DSTPPROD "

    _cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function ProcHTML(_lAprov, _cAliasZDH, _cAliasZDI)

    Local _cHtmlRet := ""
    Local _cObsSol  := AllTrim((_cAliasZDH)->ZDH_OBSSOL)
    Local _cObsApr  := AllTrim((_cAliasZDH)->ZDH_OBSAPR)
    Local _cNrSolic := (_cAliasZDH)->ZDH_NUM
    Local _cHtmlApr := ""
    Local _cHtmlZDH := ""
    Local _cHtmlZDI := ""
    Local _cEnvSer  := GetEnvServer()

    If (_lAprov)
        _cHtmlApr += "<h1 class='title-result-aproved'>APROVADA!</h1>"
    Else
        _cHtmlApr += "<h1 class='title-result-reproved'>REPROVADA!</h1>"
    EndIf

    _cHtmlZDH := HtmlZDH(_cAliasZDH)
    _cHtmlZDI := HtmlZDI(_cAliasZDI, _lAprov)

    BeginContent var _cHtmlRet

        <!DOCTYPE html>
        <html lang="pt_BR">
        <head>
            <meta charset="iso-8859-1">
            <style type="text/css">
                /* Geral */
                * {
                    font-family: "Verdana", Geneva, sans-serif;
                }
                section {
                    margin: 6px 0;
                }
                /* Resultado da Aprovação */
                .title-result-reproved {
                    color: #BA262B;
                }
                .title-result-aproved {
                    color: #0F9200;
                }
                /* Tabelas */
                .table-main-header {
                    border: 1px solid black;
                    background-color: #393938;
                    color: #F5F5F5;
                }
                .table-main-header td {
                    border: 1px solid black;
                    background-color: #393938;
                    color: #F5F5F5;
                }
                .table-main-header tr {
                    border: 1px solid black;
                    background-color: #393938;
                    color: #F5F5F5;
                }
                .table-second-header {
                    border: 1px solid black;
                    background-color: #C6C6C6;
                }
                .table-second-header td {
                    border: 1px solid black;
                    background-color: #C6C6C6;
                }
                .table-second-header tr {
                    border: 1px solid black;
                    background-color: #C6C6C6;
                }
                .table-agricopel td {
                    border: 1px solid black;
                    border-collapse: collapse;
                    padding: 5px;
                }
                .gray-line {
                    background-color: #f0f0f0;
                }
            </style>
        </head>
        <body>
            <main>
                <section>
                    <p>Notificação de que a solicitação de alteração de Preços TRR Número %Exp:_cNrSolic% foi: </p>
                    %Exp:_cHtmlApr%
                </section>
                <section>
                    <table class='table-agricopel'>
                        <thead>
                            <tr class='table-main-header'>
                                <th colspan="4">Clientes da solicitação</th>
                            </tr>
                            <tr class='table-second-header'>
                                <th>Código</th>
                                <th>Loja</th>
                                <th>Descrição</th>
                                <th>Categoria</th>
                            </tr>
                        </thead>
                        <tbody>
                            %Exp:_cHtmlZDH%
                        </tbody>
                    </table>
                </section>
                <BR>
                <section>
                    <table class='table-agricopel'>
                        <thead>
                            <tr class='table-main-header'>
                                <th colspan="3">Preços</th>
                            </tr>
                            <tr class='table-second-header'>
                                <th>Tipo de produto</th>
                                <th>Solicitado (R$)</th>
                                <th>Aprovado (R$)</th>
                            </tr>
                        </thead>
                        <tbody>
                            %Exp:_cHtmlZDI%
                        </tbody>
                    </table>
                </section>
                <section>
                    <h2>Observação do solicitante</h2>
                    <p>%Exp:_cObsSol%</p>
                </section>
                <BR>
                <section>
                    <h2>Observação do aprovador</h2>
                    <p>%Exp:_cObsApr%</p>
                </section>
                <BR>
                <BR>
                <section>
                    <h2>Ambiente Protheus</h2>
                    <p>%Exp:_cEnvSer%</p>
                </section>
            </main>
        </body>
        </html>

    EndContent

Return(_cHtmlRet)

Static Function CBoxToArr(cCampo)

    Local aArrCbox  := {}
    Local aCboxTmp  := {}
    Local aCboxTmp2 := {}
    Local cX3Cbox   := ""
    Local nX        := 0

    cX3Cbox := GetSX3Cache(cCampo, "X3_CBOX")

    aCboxTmp := StrToKArr(AllTrim(cX3Cbox), ";")

    For nX := 1 To Len(aCboxTmp)
        aCboxTmp2 := StrToKArr(aCboxTmp[nX],"=")
        Aadd(aArrCBox, {aCboxTmp2[1], aCboxTmp2[2]})
    Next nX

Return(aArrCBox)

Static Function CalcDest(_cNrSolic)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _aRet      := {}

    _cQuery := " SELECT "
    _cQuery += "    DISTINCT(SA3.A3_EMAIL) AS A3_EMAIL "
    _cQuery += " FROM " + RetSqlName("ZDH") + " ZDH (NOLOCK),  " + RetSqlName("SA3") + " SA3 (NOLOCK) "
    _cQuery += " WHERE ZDH.ZDH_NUM = '" + _cNrSolic + "'"
    _cQuery += "   AND ZDH.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH.ZDH_FILIAL = '" + FWFilial("ZDH") + "'"
    _cQuery += "   AND SA3.A3_COD IN (ZDH.ZDH_VEND, ZDH.ZDH_VEND2) "
    _cQuery += "   AND SA3.D_E_L_E_T_ = '' "
    _cQuery += "   AND SA3.A3_FILIAL = '" + FWFilial("SA3") + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

    While !((_cAliasQry)->(Eof()))

        aAdd(_aRet, AllTrim((_cAliasQry)->A3_EMAIL))

        (_cAliasQry)->(DbSkip())
    End

Return(_aRet)

Static Function HtmlZDH(_cAliasZDH)

    Local _cHtmlRet  := ""
    Local _cHtmlTmp  := ""
    Local _cCodCli   := ""
    Local _cLojCli   := ""
    Local _cNomCli   := ""
    Local nCalc      := 0
    Local _cTagGray  := ""
    Local _cDsCateg  := ""

    While !((_cAliasZDH)->(Eof()))

        nCalc++;

        _cCodCli  := AllTrim((_cAliasZDH)->ZDH_CODCLI)
        _cLojCli  := AllTrim((_cAliasZDH)->ZDH_LOJA)
        _cNomCli  := AllTrim((_cAliasZDH)->ZDH_NOMCLI)
        _cDsCateg := AllTrim((_cAliasZDH)->DSCATEGO)

        If (Mod(nCalc, 2) == 0)
            _cTagGray := "class='gray-line'"
        Else
            _cTagGray := ""
        EndIf

        BeginContent var _cHtmlTmp

            <tr %Exp:_cTagGray%>
                <td>%Exp:_cCodCli%</td>
                <td>%Exp:_cLojCli%</td>
                <td>%Exp:_cNomCli%</td>
                <td>%Exp:_cDsCateg%</td>
            </tr>

        EndContent

        _cHtmlRet += _cHtmlTmp

        ((_cAliasZDH)->(DbSkip()))
    End

Return(_cHtmlRet)

Static Function HtmlZDI(_cAliasZDI, _lAprov)

    Local _cPicPrc   := GetSX3Cache("ZDI_PRCNOV", "X3_PICTURE")
    Local _cHtmlRet  := ""
    Local _cDsTpProd := ""
    Local _cPrcNov   := ""
    Local _cPrcApr   := ""
    Local nCalc      := 0
    Local _cTagGray  := ""

    While (!(_cAliasZDI)->(Eof()))

        nCalc++;

        _cDsTpProd := AllTrim((_cAliasZDI)->DSTPPROD)
        _cPrcNov   := AllTrim(Transform((_cAliasZDI)->ZDI_PRCNOV, _cPicPrc))

        If (_lAprov)
            _cPrcApr := AllTrim(Transform((_cAliasZDI)->ZDI_PRCAPR, _cPicPrc))
        Else
            _cPrcApr := AllTrim(Transform(0, _cPicPrc))
        EndIf

        If (Mod(nCalc, 2) == 0)
            _cTagGray := "class='gray-line'"
        Else
            _cTagGray := ""
        EndIf

        BeginContent var _cHtmlTmp

            <tr %Exp:_cTagGray%>
                <td>%Exp:_cDsTpProd%</td>
                <td>%Exp:_cPrcNov%</td>
                <td>%Exp:_cPrcApr%</td>
            </tr>

        EndContent

        _cHtmlRet += _cHtmlTmp
        (_cAliasZDI)->(DbSkip())
    End

Return(_cHtmlRet)

//Utilizar para simular envio de email da aprovação
/*User Function XAG62TST(_cNrSolic)
    
    Default _cNrSolic := '019132'

    _cEmpre  := '15'
    _cFilial := '01'

    RPCClearEnv()
   // PREPARE ENVIRONMENT EMPRESA _cEmpre FILIAL _cFilial TABLES "ZDH","ZDI"
	RPCSetEnv(_cEmpre, _cFilial,"USERREST","*R3st2021","","")
    
        U_XAG0062O(_cNrSolic)

    RPCClearEnv()
    //RESET ENVIRONMENT 


Return*/ 
