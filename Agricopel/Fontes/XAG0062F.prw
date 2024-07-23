#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0062F
Cálculo das aprovações dos preços digitados na solicitação de reajuste de preços TRR
Legendas dos Motivos:
M1=Preço menor que o da faixa
M2=Desconto máximo nível 1 (parâmetro DESC_MAX_NV1)
M3=Desconto máximo nível 2 (parâmetro DESC_MAX_NV2)
MG=Diferença de preços (Evolux/Não-Evolux) menor que Gap mínimo
MZ=Preço de faixa e/ou preço solicitado zerado
@author Leandro F Silveira
@since 20/07/2020
@example u_XAG0062F()
ZDI_TPPROD=1=S10;2=S10 EVOLUX;3=S500;4=S500 EVOLUX
aPrecos={{cTpProd,nPrcFxa,nPrcNov},{cTpProd,nPrcFxa,nPrcNov}}
Retorno={cMotZDH, {cTpProd, cMotZDI}, {cTpProd, cMotZDI}, {cTpProd, cMotZDI}, {cTpProd, cMotZDI}}
/*/
User Function XAG0062F(aPrecos, nGapS10, nGapS500, nMaxNv1, nMaxNv2)

    Local aPrcRet     := {}
    Local aRet        := {}
    Local cMotCli     := ""
    Local nX          := 0
    Local aPreco      := {}
    Local cMotivo     := ""
    Local cTpProd     := ""
    Local nPosTpProd  := 1

    Local nPosS10     := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "1"})
    Local nPosS10Evo  := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "2"})
    Local nPosS500    := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "3"})
    Local nPosS500Evo := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "4"})

    Private nPosPrcNov  := 3

    Default nGapS10  := Val(U_XAG0062G("GAP_S10"))
    Default nGapS500 := Val(U_XAG0062G("GAP_S500"))
    Default nMaxNv1  := Val(U_XAG0062G("DESC_MAX_NV1"))
    Default nMaxNv2  := Val(U_XAG0062G("DESC_MAX_NV2"))

    For nX := 1 To Len(aPrecos)

        aPreco  := aPrecos[nX]
        cTpProd := aPreco[nPosTpProd]

        cMotivo := MotivoPrc(aPreco, nMaxNv1, nMaxNv2)

        If (cTpProd == "2" .And. nPosS10 > 0 .And. nPosS10Evo > 0 .And. nGapS10 > 0)
            cMotivo += MotivoGap(aPrecos[nPosS10],aPrecos[nPosS10Evo], nGapS10)
        ElseIf (cTpProd == "4" .And. nPosS500 > 0 .And. nPosS500Evo > 0 .And. nGapS500 > 0)
            cMotivo += MotivoGap(aPrecos[nPosS500],aPrecos[nPosS500Evo], nGapS500)
        EndIf

        aAdd(aPrcRet, {cTpProd, cMotivo})
    Next nX

    cMotCli := MotivoCli(aPrcRet)

    aAdd(aRet, cMotCli)
    aAdd(aRet, aPrcRet)

Return(aRet)

/*
User Function XAG0062F(aPrecos, nGapS10, nGapS500, nMaxNv1, nMaxNv2)

    Local aPrcRet     := {}
    Local aRet        := {}
    Local cMotCli     := ""

    Local nPosTpProd  := 1

    Local nPosS10     := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "1"})
    Local nPosS10Evo  := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "2"})
    Local nPosS500    := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "3"})
    Local nPosS500Evo := aScan(aPrecos, {|aPreco| aPreco[nPosTpProd] == "4"})

    Private nPosPrcNov  := 3

    Default nGapS10  := Val(U_XAG0062G("GAP_S10"))
    Default nGapS500 := Val(U_XAG0062G("GAP_S500"))
    Default nMaxNv1  := Val(U_XAG0062G("DESC_MAX_NV1"))
    Default nMaxNv2  := Val(U_XAG0062G("DESC_MAX_NV2"))

    aPrcRet := Array(4)
    aPrcRet[nPosS10]      := {"1", MotivoPrc(aPrecos[nPosS10])}
    aPrcRet[nPosS10Evo]   := {"2", MotivoPrc(aPrecos[nPosS10Evo]) + MotivoGap(aPrecos[nPosS10],aPrecos[nPosS10Evo], nGapS10)}
    aPrcRet[nPosS500]     := {"3", MotivoPrc(aPrecos[nPosS500])}
    aPrcRet[nPosS500Evo]  := {"4", MotivoPrc(aPrecos[nPosS500Evo]) + MotivoGap(aPrecos[nPosS500],aPrecos[nPosS500Evo], nGapS500)}

    cMotCli := MotivoCli(aPrcRet)

    aAdd(aRet, cMotCli)
    aAdd(aRet, aPrcRet)

Return(aRet)
*/

Static Function MotivoPrc(aPreco, nMaxNv1, nMaxNv2)

    Local nPosPrcFxa := 2
    Local cMotPrc    := ""
    Local nVlDesc    := 0

    If (aPreco[nPosPrcFxa] <= 0 .Or. aPreco[nPosPrcNov] <= 0)
        cMotPrc := "MZ"
    ElseIf (aPreco[nPosPrcFxa] > aPreco[nPosPrcNov])

        nVlDesc := aPreco[nPosPrcFxa] - aPreco[nPosPrcNov]

        If (nVlDesc > nMaxNv2)
            cMotPrc := "M3"
        ElseIf (nVlDesc > nMaxNv1)
            cMotPrc := "M2"
        Else
            cMotPrc := "M1"
        EndIf
    EndIf

Return(cMotPrc)

Static Function MotivoGap(aPreco, aPrecoEvo, nGapMinimo)

    Local cMotGap    := ""
    Local nGap       := 0

    nGap := aPrecoEvo[nPosPrcNov] - aPreco[nPosPrcNov]

    If (nGapMinimo > nGap)
        cMotGap := "MG"
    EndIf

Return(cMotGap)

Static Function MotivoCli(aPrecos)

    Local aMotivos   := {"M1", "M2", "M3", "MG", "MZ"}
    Local cMotCli    := ""
    Local cMotTotal  := ""
    Local nPosMotivo := 2
    Local nI         := 1

    aEval(aPrecos, {|aPreco| cMotTotal += aPreco[nPosMotivo]})

    If (!Empty(cMotTotal))
        For nI := 1 To Len(aMotivos)
            If (At(aMotivos[nI], cMotTotal) > 0)
                cMotCli += aMotivos[nI]
            EndIf
        End
    EndIf

Return(cMotCli)
