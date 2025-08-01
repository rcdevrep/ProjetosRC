#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
 
User Function CompAuto( _aParametrosJob, nTaxAcord)

    Local cFilCmp	:= _aParametrosJob[01]
    Local aNF       := _aParametrosJob[02] // Rencno titulo
    Local aPA_NDF   := _aParametrosJob[03] // Recno titulo
    Local aContabil := _aParametrosJob[04]
    Local nVrComp   := _aParametrosJob[05]
    Local dDataComp := _aParametrosJob[06]
    Local _cFilNF   := _aParametrosJob[07]
    Local lRet      := .F.
    Local bBlock    := Nil
    Local aEstorno  := {}
    Local nTaxaNF   := 0
    Local nTaxaPA   := 0
    Local nHdl      := 0
    Local nOperacao := 0
    Local aRecSE5   := {}
    Local aNDFDados := {}
    Local lHelp     := .T.
    Local nI        := 0
    Local cIdFK2    := ""
    Local cFilIni   := cFilAnt
    Default nTaxAcord := 0
    Default nTaxaADT := 0
    
    If nTaxAcord <> 0
        nTaxaPA := nTaxAcord
    EndIf

    //PREPARE ENVIRONMENT EMPRESA "01" FILIAL cFilCmp MODULO "FIN"
    cFilAnt  := cFilCmp
    Pergunte("AFI340", .F.)
    lContabiliza := MV_PAR11 == 1
    lAglutina := MV_PAR08 == 1
    lDigita := MV_PAR09 == 1

    //lRet := FinCmpAut(aNF, aPA_NDF, aContabil, bBlock, aEstorno, nVrComp, dDataComp, nTaxaPA ,nTaxaNF,;
    //     nHdl, nOperacao, aRecSE5, aNDFDados, lHelp)
    //nVrTaxa := (nVrComp / nTaxaPA) - nVrComp
    //nVrComp := nVrComp + nVrTaxa

    if FinCmpAut(aNF, aPA_NDF, {lContabiliza,lAglutina,lDigita}, /*bBlock*/, aEstorno, nVrComp, dDataComp, nTaxaPA ,/*nTaxaNF*/, nHdl, nOperacao, /*aRecSE5*/, /*aNDFDados*/, lHelp)          
    //if FinCmpAut(aNF, aPA_NDF, {lContabiliza,lAglutina,lDigita}, /*bBlock*/, aEstorno, , dDataComp, nTaxaPA, , nHdl, nOperacao, /*aRecSE5*/, /*aNDFDados*/, lHelp)          
        MSGALERT("Processo concluido com exito.")
        lRet := .T.
    else
        MSGSTOP("Processo nao concluido.")    
        lRet := .F.       
    endif

    //ANF[1] = 452537
    //APA_NDF[1] = 443195
    //74491113.9550163

    /*If lRet .And. Len(aRecSE5) > 0
        If Len(aRecSE5[1]) > 0
            For nI:= 1 To Len(aRecSE5[1])
                SE5->(DbGoTo(aRecSE5[1][nI]))
                cIdFK2:= SE5->E5_IDORIG

                SE5->(RecLock("SE5",.F.))
                SE5->E5_FILIAL := _cFilNF

                If nTaxaPA <> 0
                    SE5->E5_TXMOEDA := nTaxaPA
                EndIf

                SE5->E5_ORIGEM := "FINA340"
                SE5->(MsUnLock())

                FK2->(DbSetOrder(1))
                IF(FK2->(DBSeek(xFilial("FK2")+cIdFK2)))
                    FK2->(RecLock("FK2",.F.))
                    FK2->FK2_FILIAL:= _cFilNF
                    FK2->FK2_ORIGEM:= "FINA340"
                    FK2->(MsUnLock())
                ENDIF
            Next nI
            ConOut("Compensação realizada com sucesso")
        Else
            ConOut("1 - Ocorreu um erro no processo de compensação")
        Endif
    Else
        ConOut("2 - Ocorreu um erro no processo de compensação")
    EndIf
    */
    cFilAnt := cFilIni 
//    RESET ENVIRONMENT

Return lRet
 
User Function EstCompAuto( _aParametrosJob )

    Local cFilCmp	:= _aParametrosJob[01]
    Local aNF       := _aParametrosJob[02] // Rencno titulo
    Local aPA_NDF   := _aParametrosJob[03] // Recno titulo
    Local aContabil := _aParametrosJob[04]
    Local nVrComp   := _aParametrosJob[05]
    Local dDataComp := _aParametrosJob[06]
    Local lRet      := .F.
    Local bBlock    := Nil
    Local aEstorno  := {}
    Local nTaxaPA   := 0
    Local nTaxaNF   := 0
    Local nHdl      := 0
    Local nOperacao := 0
    Local aRecSE5   := {}
    Local aNDFDados := {}
    Local lHelp     := .T.

    Public _cFilNF  := _aParametrosJob[07]

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL cFilCmp MODULO "FIN"
 
    Pergunte("AFI340", .F.)
    lContabiliza := MV_PAR11 == 1
    lAglutina := MV_PAR08 == 1
    lDigita := MV_PAR09 == 1

    lRet := FinCmpAut(aNF, aPA_NDF, aContabil, bBlock, aEstorno, nVrComp, dDataComp, nTaxaPA ,nTaxaNF,;
         nHdl, nOperacao, aRecSE5, aNDFDados, lHelp)

    If lRet
        ConOut("Estorno da Compensação realizada com sucesso")
    Else
        ConOut("Ocorreu um erro no processo de estorno da compensação")
    EndIf

    RESET ENVIRONMENT

    _cFilNF  := ""

Return lRet

User Function RepClass()

Return .T.
