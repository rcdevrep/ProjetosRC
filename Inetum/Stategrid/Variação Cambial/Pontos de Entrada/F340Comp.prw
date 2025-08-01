User Function F340Comp()

    Local lReturn := .T.

    If SE2->E2_TIPO == "NDF" .AND. AllTrim(SE2->E2_ORIGEM)== "MATA460"
        MsgAlert('Favor posicionar na Nota Fiscal para realizar a compensa��o.', 'Aten��o')
        lReturn := .F.
    EndIf

    If ALLTRIM(SE2->E2_TIPO) == "PA" .AND. AllTrim(SE2->E2_PREFIXO)== "SPG"
        MsgAlert('Foi selecionado o t�tulo de adiantamento de SP, favor posicionar no t�tulo de SP ser compensado (PCA) para realizar a compensa��o.', 'Aten��o')
        lReturn := .F.
    EndIf

Return lReturn
