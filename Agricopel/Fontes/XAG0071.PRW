#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0071
Gatilho de sugestão do armazém no item pedido de venda (SC6->C6_LOCAL), acionado no campo C6_PRODUTO
@author Leandro F Silveira
@since 07/01/2020
@example u_XAG0071()
/*/
User Function XAG0071()

    Local aSeg       := GetArea()
    Local aSegSB1    := SB1->(GetArea())
    Local aSegSA1    := SA1->(GetArea())
    Local cProdArla  := ""
    Local nPosLocal  := 0
    Local _cRet      := ""

    nPosLocal := aScan(aHeader,{|x| Alltrim(x[2]) == "ADB_LOCAL"})
    _cRet     := aCols[n][nPosLocal]

    If SM0->M0_CODIGO == "01" .Or. SM0->M0_CODIGO == "11"

        If (SB1->B1_COD <> M->ADB_CODPRO)
            SB1->(dbSetOrder(1))
            SB1->(DbSeek(xFilial("SB1")+M->ADB_CODPRO))
        EndIf

        If (SA1->A1_COD <> M->ADA_CODCLI .Or. SA1->A1_LOJA <> M->ADA_LOJCLI)
            SA1->(dbSetOrder(1))
            SA1->(DbSeek(xFilial("SA1")+M->ADA_CODCLI+M->ADA_LOJCLI))
        EndIf

        if ((AllTrim(SM0->M0_CODIGO) == '01' .and. (Alltrim(SM0->M0_CODFIL) == '03' .or. Alltrim(SM0->M0_CODFIL) $ '11/15/17/18/05' .or. Alltrim(SM0->M0_CODFIL) == '16')) .or. AllTrim(SM0->M0_CODIGO) == '11') .AND. AllTrim(SB1->B1_TIPO) == "CO"
            if !Empty(SA1->A1_ARMAZEM)
                _cRet := SA1->A1_ARMAZEM
            EndIf
        EndIf

        if (AllTrim(SM0->M0_CODIGO) == '01' .and. (Alltrim(SM0->M0_CODFIL) == '03' .or. Alltrim(SM0->M0_CODFIL) $ '11/15/17/18/05')) //.AND. AllTrim(SB1->B1_TIPO) == "AG"
            cProdArla := SuperGetMV("MV_XPDARLA",.F.,"")
            if !Empty(SA1->A1_XARARLA) .And. !Empty(cProdArla) .And. Alltrim(M->ADB_CODPRO) $ cProdArla
                _cRet := SA1->A1_XARARLA
            EndIf
        EndIf

    EndIf

    RestArea(aSegSB1)
    RestArea(aSegSA1)
    RestArea(aSeg)

Return(_cRet)
