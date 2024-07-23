#INCLUDE "TOTVS.CH"
User Function XAG0168()

Local oComprovante := FINComprovantes():New()
Local cContaDebito := " "
Local cModelo := "TED"
    //oComprovante:Teste()

    SEA->(dbSetOrder(1))
    If SEA->(dbSeek(xFilial("SEA")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
       cContaDebito := SEA->EA_NUMCON
       cBanco := SEA->EA_PORTADO
    Endif

    
    /*IF(cBanco == "237")
        FWAlertError("Titulo não é da API Bradesco." , "XAG0168")
        return .F.
    ENDIF*/

    IF(SE2->E2_SALDO > 0)
        FWAlertError("Titulo em aberto, não foi feita baixas pela API." , "XAG0168")
        return .F.
    ENDIF

    IF(EMPTY(SE2->E2_CODBAR))
        cModelo := "TED"
       //FWAlertError("Titulo sem codigo de controle. Não é possivel emitir comprovante." , "XAG0168")
       //return .F.
    ELSE
        cModelo := "BOLETO"
    ENDIF

    oComprovante:cNumeroControle := SE2->E2_NUMBCO
    oComprovante:cDocumento := SE2->E2_NUM
    oComprovante:cContaDebito := cContaDebito
    oComprovante:cContaCredito := " "
    oComprovante:cEmpresa := SM0->M0_NOMECOM
    oComprovante:cCodBarras := SE2->E2_CODBAR
    oComprovante:cBancoDest := SE2->E2_PORTADO
    oComprovante:cRazaoSocial := Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NOME")
    oComprovante:cNomeFantasia := Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NREDUZ")
    oComprovante:cCNPJBenef := Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_CGC")
    oComprovante:cRazaoSocialFinal := "Não informado"
    oComprovante:cCNPJBenefFinal := "Não informado"
    oComprovante:cInstituicao := "237 - BANCO BRADESCO S.A."
    oComprovante:cNomePagador := "AGRICOPEL COMERCIO DE DERIVADOS - JARAGUÁ"
    oComprovante:cCNPJPagador := SM0->M0_CGC
    oComprovante:cDataDebito := DTOC(SE2->E2_BAIXA)
    oComprovante:cDataVencimento := DTOC(SE2->E2_VENCREA)
    oComprovante:cValor := TRANSFORM(SE2->E2_VALOR,'@E 999,999,999.99')
    oComprovante:cDesconto := TRANSFORM(SE2->E2_DESCONT,'@E 999,999,999.99')
    oComprovante:cAbatimento := TRANSFORM(0,'@E 999,999,999.99')
    oComprovante:cBonificacao := TRANSFORM(0,'@E 999,999,999.99')
    oComprovante:cMulta := TRANSFORM(SE2->E2_MULTA,'@E 999,999,999.99')
    oComprovante:cJuros := TRANSFORM(SE2->E2_JUROS,'@E 999,999,999.99')
    oComprovante:cValorTotal := TRANSFORM(SE2->E2_VALOR,'@E 999,999,999.99')
    oComprovante:cDescricao := SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA

    oComprovante:ImprimirComprovante(cModelo)

Return()
