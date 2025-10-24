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

    cFilAnt := cFilIni 

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
