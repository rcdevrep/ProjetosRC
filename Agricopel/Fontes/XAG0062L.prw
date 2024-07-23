#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062L
Produz o HTML de aprovação da solicitação de alteração de preços TRR
@author Leandro F Silveira
@since 13/11/2020
@example u_XAG0062L("01","03", "000097", "ASDFG12345")
@param nrsolic, chave
/*/
User Function XAG0062L(_cEmpre, _cFilial, _cNrSolic, _cChave)

    Local cAliasZDH := ""
    Local cRetHTML  := ""

    cAliasZDH := GetZDH(_cNrSolic)

    cRetHTML := HtmlForm(cAliasZDH, _cEmpre, _cFilial)

    (cAliasZDH)->(DbCloseArea())

Return(cRetHTML)

Static Function GetZDH(cNumSolic)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _aCateg    := CBoxToArr("ZDH_CATEGO")
    Local _aFaixa    := CBoxToArr("ZDH_FAIXA")
    Local nCount     := 1

    _cQuery := " SELECT "
    _cQuery += "    ZDH_FILIAL, "
    _cQuery += "    ZDH_NUM, "
    _cQuery += "    ZDH_CODCLI, "
    _cQuery += "    ZDH_LOJA, "
    _cQuery += "    ZDH_HORA, "
    _cQuery += "    ZDH_DATA, "
    _cQuery += "    ZDH_CONDPG, "
    _cQuery += "    ZDH_OBSSOL, "
 
    _cQuery += "    COALESCE((SELECT TOP 1 CONCAT(RTRIM(CONVERT(CHAR,CAST(SUB_ZDH.ZDH_DATA AS DATE),103)),'-', SUBSTRING(SUB_ZDH.ZDH_HORA,1,5))  "
    _cQuery += "              FROM ZDH010 SUB_ZDH (NOLOCK) "
    _cQuery += "    		  WHERE SUB_ZDH.ZDH_FILIAL = ZDH.ZDH_FILIAL "
    _cQuery += "    		  AND   SUB_ZDH.ZDH_CODCLI = ZDH.ZDH_CODCLI "
    _cQuery += "    		  AND   SUB_ZDH.ZDH_LOJA = ZDH.ZDH_LOJA "
    _cQuery += "    		  AND   SUB_ZDH.ZDH_NUM <> ZDH.ZDH_NUM "
    _cQuery += "    		  AND   SUB_ZDH.D_E_L_E_T_ = '' "
    _cQuery += "    		  ORDER BY SUB_ZDH.ZDH_DATA DESC, SUB_ZDH.ZDH_HORA DESC) "
    _cQuery += "    ,'') AS ULTSOL, "

    _cQuery += "    (SELECT E4_DESCRI "
    _cQuery += "     FROM " + RetSqlName("SE4") + " SE4 (NOLOCK) "
    _cQuery += "     WHERE SE4.E4_CODIGO = ZDH_CONDPG "
    _cQuery += "     AND   SE4.E4_FILIAL = '" + FWFilial("SE4") + "' "
    _cQuery += "     AND   SE4.D_E_L_E_T_ = '') AS DSCONDPG, "

    _cQuery += "    ZDH_CODTAB, "
    _cQuery += "    ZDH_STATUS, "
    _cQuery += "    ZDH_NOMCLI, "
    _cQuery += "    ZDH_VEND, "
    _cQuery += "    A1_ESTENT, "
    _cQuery += "    A1_ESTE, "
	_cQuery += "    A1_MUNE, "
	_cQuery += "    A1_MUNENT,"

    _cQuery += "    (SELECT TOP 1 SA3.A3_NOME "
    _cQuery += "     FROM " + RetSqlName("SA3") + " SA3 (NOLOCK) "
    _cQuery += "     WHERE SA3.A3_COD = ZDH.ZDH_VEND "
    _cQuery += "     AND   SA3.D_E_L_E_T_ = '' "
    _cQuery += "     AND   SA3.A3_FILIAL = '" + FWFilial("SA3") + "') AS DSVEND, "

    _cQuery += "    ZDH_CATEGO, "

    _cQuery += "    CASE ZDH_CATEGO "
    For nCount := 1 to Len(_aCateg)
        _cQuery += " WHEN '" + _aCateg[nCount][1] + "' THEN '" + _aCateg[nCount][2] + "'"
    End
    _cQuery += "     END AS DSCATEGO, "

    _cQuery += "    ZDH_FAIXA, "

    _cQuery += "    CASE ZDH_FAIXA "
    For nCount := 1 to Len(_aFaixa)
        _cQuery += " WHEN '" + _aFaixa[nCount][1] + "' THEN '" + _aFaixa[nCount][2] + "'"
    End
    _cQuery += "     END AS DSFAIXA, "

    _cQuery += "    COALESCE( "
    _cQuery += "       (SELECT TOP 1 ZDF.ZDF_PROPR1 "
    _cQuery += "        FROM " + RetSqlName("ZDF") + " ZDF (NOLOCK) "
    _cQuery += "        WHERE RTRIM(ZDF_PARAM) = CONCAT('FAIXA_', RTRIM(ZDH_FAIXA)) "
    _cQuery += "        AND ZDF_FILIAL =  '" + FWFilial("ZDF") + "'"
    _cQuery += "        AND ZDF.D_E_L_E_T_ = '') "
    _cQuery += "    ,0) AS FAIXAMIN, "

    _cQuery += "    COALESCE( "
    _cQuery += "       (SELECT TOP 1 ZDF.ZDF_PROPR1 "
    _cQuery += "        FROM " + RetSqlName("ZDF") + " ZDF (NOLOCK) "
    _cQuery += "        WHERE RTRIM(ZDF_PARAM) > CONCAT ('FAIXA_', RTRIM(ZDH_FAIXA)) "
    _cQuery += "        AND RTRIM(ZDF_PARAM) LIKE 'FAIXA_%' "
    _cQuery += "        AND ZDF_FILIAL =  '" + FWFilial("ZDF") + "'"
    _cQuery += "        AND ZDF.D_E_L_E_T_ = '' "
    _cQuery += "        ORDER BY ZDF_PARAM) "
    _cQuery += "    ,0) AS FAIXAMAX, "

    _cQuery += "    ZDH_MOTIVO, "
    _cQuery += "    ZDH_CHVAPR, "
    _cQuery += "    ZDH_USERGI, "
    _cQuery += "    ZDH_USERGA "

    _cQuery += " FROM " + RetSqlName("ZDH") + " ZDH (NOLOCK), " + RetSqlName("SA1") + " SA1 (NOLOCK) "

    _cQuery += " WHERE ZDH.ZDH_NUM = '" + cNumSolic + "'"
    _cQuery += "   AND ZDH.D_E_L_E_T_ = '' "
    _cQuery += "   AND SA1.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDH.ZDH_FILIAL = '" + FWFilial("ZDH") + "'"
    _cQuery += "   AND SA1.A1_FILIAL = '" + FWFilial("SA1") + "'"
    _cQuery += "   AND SA1.A1_COD = ZDH.ZDH_CODCLI"
    _cQuery += "   AND SA1.A1_LOJA = ZDH.ZDH_LOJA"
    Conout(_cQuery)
    _cAliasQry := MpSysOpenQuery(_cQuery)

    TCSetField(_cAliasQry,"ZDH_DATA","D",08,0)	

Return(_cAliasQry)

Static Function GetZDI(cAliasZDH)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _aTpProd   := CBoxToArr("ZDI_TPPROD")
    Local nCount     := 1

    _cQuery := " SELECT "
    _cQuery += "    ZDI_TPPROD, "

    _cQuery += "    CASE ZDI_TPPROD "
    For nCount := 1 to Len(_aTpProd)
        _cQuery += "   WHEN '" + _aTpProd[nCount][1] + "' THEN '" + _aTpProd[nCount][2] + "'"
    End
    _cQuery += "    END AS DSTPPROD, "

    _cQuery += "    ZDI_PRCANT, "
    _cQuery += "    ZDI_PRCFXA, "
    _cQuery += "    ZDI_PRCNOV, "
    _cQuery += "    ZDI_PRCAPR "
    _cQuery += " FROM " + RetSqlName("ZDI") + " ZDI (NOLOCK) "
    _cQuery += " WHERE ZDI.ZDI_NUM = '" + (cAliasZDH)->ZDH_NUM + "'"
    _cQuery += "   AND ZDI.ZDI_CODCLI = '" + (cAliasZDH)->ZDH_CODCLI + "'"
    _cQuery += "   AND ZDI.ZDI_LOJA = '" + (cAliasZDH)->ZDH_LOJA + "'"
    _cQuery += "   AND ZDI.D_E_L_E_T_ = '' "
    _cQuery += "   AND ZDI.ZDI_FILIAL = '" + FWFilial("ZDI") + "'"

    _cAliasQry := MpSysOpenQuery(_cQuery)

Return(_cAliasQry)

Static Function HtmlForm(cAliasZDH, _cEmpre, _cFilial)

    Local cNrSolic  := (cAliasZDH)->ZDH_NUM
    Local cDtSolic  := DTOC((cAliasZDH)->ZDH_DATA)
    Local cHrSolic  := (cAliasZDH)->ZDH_HORA
    Local cDsCondPg := (cAliasZDH)->DSCONDPG
    Local cChaveApr := (cAliasZDH)->ZDH_CHVAPR
    Local cObsSol   := (cAliasZDH)->ZDH_OBSSOL
    Local cPrcNovo  := PrcNovo(cAliasZDH)
    Local cDadosCli := DadosCli(cAliasZDH)

    Local cURLApr   := '"/rest_prd/RestPrcTRR/aprov/' + AllTrim(_cEmpre) + "/" + AllTrim(_cFilial) + "/" + AllTrim(cNrSolic) + "/" + AllTrim(cChaveApr) + '"'
    Local cURLRepr  := '"/rest_prd/RestPrcTRR/reprov/'  + AllTrim(_cEmpre) + "/" + AllTrim(_cFilial) + "/" + AllTrim(cNrSolic) + "/" + AllTrim(cChaveApr) + '"'

    BeginContent var cRetHTML

        <!DOCTYPE html>
        <html lang="pt_BR">
        <head>
            <meta charset="iso-8859-1">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <!-- Bootstrap4 - CSS -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap-reboot.min.css" integrity="sha512-UBroJxibXruJBE5gepz9uRmKrOqEpgMKRtQWWti2gMYLMpilui9tM+u+wenk30eW/qHpzY0IoHyIbymVEMnYJA==" crossorigin="anonymous" />
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha512-iQQV+nXtBlmS3XiDrtmL+9/Z+ibux+YuowJjI4rcpO7NYgTzfTOiFNm09kWtfZzEB9fQ6TwOVc8lFVWooFuD/w==" crossorigin="anonymous" />
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap-grid.min.css" integrity="sha512-ecQi9VA/aFka0SjfPAJw8Y9hk/PqvWp5wtN0JkkXWsrQ+l4v0vPplM1JVYrkjnOcoymhGiAeEIolw/LLDqCmgg==" crossorigin="anonymous" />
            <!-- Bootstrap4/jQuery/Popper - JS -->
            <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous" ></script>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ho+j7jyWK8fNQe+A12Hb8AhRq26LrZ/JpcUGGOn+Y7RsweNrtN/tE3MoK7ZeZDyx" crossorigin="anonymous" ></script>

            <title>Solicitação de Reajuste de Preços</title>

            <style type="text/css">
                /* Fonte e background padrão */
                body {
                    background-color: #F5F5F5;
                    font-family: 'Verdana', Geneva, sans-serif;
                }
                /* Fonte para títulos */
                h1, h2 {
                    font-weight: bold;
                }
                /* Header (jumbotron) e Cabeçalho de Cliente */
                .cabecalho, .tabela-cliente-cabecalho {
                    background-color: rgb(57,57,56);
                    color: #F5F5F5;
                }
                /* Cabeçalho das tabelas */
                .tabela-cabecalho {
                    background-color: #c6c6c6;
                    color: black;
                }
                /* Cor de destaque da tabela zebrada */
                .table-striped > tbody > tr:nth-child(2n+1) > td, .table-striped > tbody > tr:nth-child(2n+1) > th {
                    background-color: #F0F0F0;
                }
                /* Ajuste dos Botões de Aprovar e Reprovar */
                button {
                    width: 100%;
                }
            </style>
        </head>
        <body>
            <!-- Conteúdo -->
            <main>

                <!-- Dados de Solicitação -->
                <section class="my-5">
                    <h2 class='h4 font-weight-bold text-center'>Dados da solicitação de Reajuste</h2>
                    <hr>
                    <div class="table-responsive"> 
                        <table class="table table-striped table-bordered shadow-sm">
                            <thead class="tabela-cabecalho">
                                <tr>
                                    <th scope="col">Código de Solicitação</th>
                                    <th scope="col">Data</th>
                                    <th scope="col">Hora</th>
                                    <th scope="col">Condição de Pagamento</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <!-- #TODO: Trocar código por texto -->
                                    <td>%Exp:cNrSolic%</td>
                                    <td>%Exp:cDtSolic%</td>
                                    <td>%Exp:cHrSolic%</td>
                                    <td>%Exp:cDsCondPg%</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- Dados dos Clientes -->
                <section class="my-5">
                    <h2 class='h4 font-weight-bold text-center'>Dados dos Clientes</h2>
                    <hr>
                    <div class="table-responsive"> 
                        %Exp:cDadosCli%
                    </div>
                </section>

                <!-- Preços do Reajuste -->
                <section class="mb-5">
                    <h2 class='h4 font-weight-bold text-center'>Preços do Reajuste</h2>
                    <hr>
                    <div class="table-responsive"> 
                        <table class="table table-striped table-bordered shadow-sm">
                            <thead class="tabela-cabecalho">
                                <tr>
                                    <th scope="col">Tipo do Produto</th>
                                    <th scope="col">Preço Solicitado (R$)</th>
                                    <th scope="col">Preço Aprovado (R$)</th>
                                </tr>
                            </thead>
                            <tbody>
                                %Exp:cPrcNovo%
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- Observação do Solicitante -->
                <section class="my-5">
                    <h2 class="h4 font-weight-bold text-center">
                    Observação do Solicitante
                    </h2>
                    <hr />
                    <p class='mx-5'>
                        %Exp:cObsSol%
                    </p>
                </section>

                <!-- Aprovar Reajuste -->
                <section class="my-5">
                    <h2 class='h4 font-weight-bold text-center'>Aprovar Reajuste</h2>
                    <hr>
                    <form method="post" class="d-flex flex-row justify-content-center flex-wrap" id="form-reajuste">
                        <label for="observacao" class='h5 col-12 text-center'>Observação</label>
                        <textarea id='observacao' name="observacao" rows="8" cols="70" 
                            placeholder="Escreva uma Observação" class='my-2 col-11'></textarea>
                        <button onclick="formSubmit(this)" type="button" value='aprovado' class="btn btn-success btn-lg col-sm-5 mx-3 my-1"
                            formaction=%Exp:cURLApr%>Aprovar</button>
                        <button onclick="formSubmit(this)" type="button" value='reprovado' class="btn btn-danger btn-lg col-sm-5 mx-3 my-1"
                            formaction=%Exp:cURLRepr%>Reprovar</button>
                    </form>

                </section>
            </main>

            <!-- Modal de Erro -->
            <div
            class="modal fade"
            id="modal-error"
            data-backdrop="static"
            data-keyboard="false"
            tabindex="-1"
            >
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Erro!</h5>
                </div>
                <div class="modal-body">
                    <p>
                    Ocorreu um erro durante o envio do formulário! Favor tentar
                    novamente em alguns instantes, caso o problema persista contacte o suporte em TI!
                    </p>
                    <p>Erro: <span id="error-msg"></span></p>
                </div>
                <div class="modal-footer">
                    <button
                    type="button"
                    class="btn btn-secondary"
                    data-dismiss="modal"
                    >
                    Voltar
                    </button>
                </div>
                </div>
            </div>
            </div>
            <!-- Modal de Sucesso -->
            <div
            class="modal fade"
            id="modal-success"
            data-backdrop="static"
            data-keyboard="false"
            tabindex="-1"
            >
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                <div class="modal-body">
                    <p id="success-msg"></p>
                </div>
                <div class="modal-footer">
                    <button
                    type="button"
                    class="btn btn-primary"
                    data-dismiss="modal"
                    onclick="window.close();"
                    >
                    Encerrar
                    </button>
                </div>
                </div>
            </div>
            </div>

            <script type="text/javascript">
            function formSubmit(button) {
                // Pega os dados como formData
                var myForm = document.getElementById('form-reajuste');
                formData = new FormData(myForm);
                // Transforma em Json 
                var object = {produtos: {}};
                formData.forEach(function(value, key){
                if (key == 'observacao') {
                    object[key] = value;
                } else {
                    object['produtos'][key] = value;
                }
                });
                var json = JSON.stringify(object)
                // Pega o endereço pra requisição de acordo com o botão
                var url = button.getAttribute("formaction");
                // Faz requisição
                fetch(url, {
                    method: "POST",
                    body: json,
                    header: { "Content-Type": "application/json; charset=iso-8859-1" },
                }).then(function (res) {
                    if (res.ok) {
                        res.text()
                        .then(function(result){
                            modalSuccess(result);
                        })
                    } else {
                        var errorMsg = `${res.status} - ${res.statusText}`;
                        modalError(errorMsg);
                    }
                }).catch(error => {
                    modalError(error);
                })
            }
            function modalError(errorMsg) {

                $("#error-msg").html(errorMsg);
                $("#modal-error").modal("show");
            }
            function modalSuccess(result) {
                $("#success-msg").html(result);
                $("#modal-success").modal("show");
            }
            </script>
        </body>
        </html>

    EndContent

Return(cRetHTML)

Static Function DadosCli(cAliasZDH)

    Local cRetHTML  := ""
    Local cInfoCli  := ""
    Local cAliasZDI := ""
    Local cHtmlPrc  := ""
    Local _lEndEnt  := FwFilial("SC5") $ SuperGetMv("MV_XENDENT", .F., "ZZ") //Trabalha com End. Entrega Customizado?

    While !((cAliasZDH)->(Eof()))

        cAliasZDI := GetZDI(cAliasZDH)
        cHtmlPrc  := PrecosCli(cAliasZDI)

        cInfoCli := AllTrim((cAliasZDH)->ZDH_CODCLI) + "-" + AllTrim((cAliasZDH)->ZDH_LOJA) + " - " + AllTrim((cAliasZDH)->ZDH_NOMCLI)
        cInfoCli += " - "

        If (!Empty((cAliasZDH)->ZDH_VEND))
            cInfoCli +=  AllTrim((cAliasZDH)->ZDH_VEND) + "-" + AllTrim((cAliasZDH)->DSVEND)
        Else
            cInfoCli +=  "SEM VENDEDOR"
        EndIf

        cInfoCli += " - "
        cInfoCli += AllTrim((cAliasZDH)->DSCATEGO)
        cInfoCli += " - "
        cInfoCli += AllTrim((cAliasZDH)->DSFAIXA)
        cInfoCli += " ("

        If ((cAliasZDH)->FAIXAMAX == 0)
            cInfoCli += "Acima de " + cValToChar((cAliasZDH)->FAIXAMIN)
        Else
            cInfoCli += "De " + cValToChar((cAliasZDH)->FAIXAMIN) + " a " + cValToChar((cAliasZDH)->FAIXAMAX)
        EndIf

        cInfoCli += " litros)"
        cInfoCli += " - "
        cInfoCli += "Ult.Sol.: "
        cInfoCli += AllTrim((cAliasZDH)->ULTSOL)
        cInfoCli += " - "
        cInfoCli += "Cidade - UF Ent.: "

        If (_lEndEnt .And. ( !Empty((cAliasZDH)->A1_ESTENT) .or. !Empty((cAliasZDH)->A1_MUNENT )))
            cInfoCli += alltrim((cAliasZDH)->A1_MUNENT)+' - ' + AllTrim((cAliasZDH)->A1_ESTENT)
        Else
            cInfoCli += alltrim((cAliasZDH)->A1_MUNE) + ' - ' + AllTrim((cAliasZDH)->A1_ESTE)
        EndIf

        BeginContent var cHTMLCli

            <table class="table table-striped table-bordered shadow-sm">
                <thead class="tabela-cabecalho">
                    <tr>
                        <th colspan="3" class='text-center tabela-cliente-cabecalho'>%Exp:cInfoCli%</th>
                    </tr>
                    <tr>
                        <th scope="col">Tipo do Produto</th>
                        <th scope="col">Preço Faixa (R$)</th>
                        <th scope="col">Preço Atual (R$)</th>
                    </tr>
                </thead>
                <tbody>
                    %Exp:cHtmlPrc%
                </tbody>
            </table>

        EndContent

        cRetHTML += cHTMLCli
        (cAliasZDI)->(DbCloseArea())

        (cAliasZDH)->(DbSkip())
    End

Return(cRetHTML)

Static Function PrecosCli(cAliasZDI)

    Local cHtmlRet  := ""
    Local cPicPrcFxa := GetSX3Cache("ZDI_PRCFXA", "X3_PICTURE")
    Local cPicPrcAnt := GetSX3Cache("ZDI_PRCANT", "X3_PICTURE")

    While !(cAliasZDI)->(Eof())
        BeginContent var cHtml
            <tr>
                <td>%Exp:AllTrim((cAliasZDI)->DSTPPROD)%</td>
                <td>%Exp:AllTrim(Transform((cAliasZDI)->ZDI_PRCFXA, cPicPrcFxa))%</td>
                <td>%Exp:AllTrim(Transform((cAliasZDI)->ZDI_PRCANT, cPicPrcAnt))%</td>
            </tr>
        EndContent

        cHtmlRet += cHtml
        (cAliasZDI)->(DbSkip())
    End

Return(cHtmlRet)

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

Static Function PrcNovo(cAliasZDH)

    Local cAliasZDI := ""
    Local cHTMLRet  := ""
    Local cPicPrc   := GetSX3Cache("ZDI_PRCNOV", "X3_PICTURE")
    Local cPrcNov   := ""
    Local cPrcApr   := ""
    Local cNamePrc  := ""

    cAliasZDI := GetZDI(cAliasZDH)

    While !((cAliasZDI)->(Eof()))

        cPrcNov  := AllTrim(Transform((cAliasZDI)->ZDI_PRCNOV, cPicPrc))

        cPrcApr  := AllTrim(Transform((cAliasZDI)->ZDI_PRCAPR, cPicPrc))
        cPrcApr  := StrTran(cPrcApr, ",", ".")

        cNamePrc := "tpprod_" + AllTrim((cAliasZDI)->ZDI_TPPROD)

        BeginContent var cHtml

            <tr>
                <td>%Exp:AllTrim((cAliasZDI)->DSTPPROD)%</td>
                <td>%Exp:cPrcNov%</td>
                <td><input type="number" name="%Exp:cNamePrc%" form="form-reajuste" value="%Exp:cPrcApr%" /></td>
            </tr>

        EndContent

        cHtmlRet += cHtml
        (cAliasZDI)->(DbSkip())
    End

    (cAliasZDI)->(DbCloseArea())

Return(cHtmlRet)
