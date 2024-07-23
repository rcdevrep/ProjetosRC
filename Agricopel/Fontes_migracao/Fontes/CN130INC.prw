#include 'protheus.ch'
#include 'parmtype.ch'

User Function CN130Inc()

	Local aExp1 := PARAMIXB[1]
	Local aExp2 := PARAMIXB[2]
	Local aExp3 := PARAMIXB[3]
	Local aExp4 := PARAMIXB[4]

	// Busca posicao dos campos
	For _nX:=1 to Len(aExp1)
		If Alltrim(aExp1[_nX][02]) == "CNE_PERC"
			nPosPerc := _nX
		ElseIf Alltrim(aExp1[_nX][02]) == "CNE_VLTOT"
			nPosVUnt := _nX
		ElseIf Alltrim(aExp1[_nX][02]) == "CNE_VLUNIT"
			nPosVTOT := _nX
		ElseIf Alltrim(aExp1[_nX][02]) == "CNE_QUANT"
			nPosQunt := _nX
		EndIf
	Next _nX

	// Busca valor da parcela para a medicao e gera o percentual corretamente
	For _nY:=1 to Len(aExp2)
		dbSelectArea("CNF")
		dbSetOrder(3)
		If dbSeek(xFilial("CNF",cFilCTR)+cContra+cRevisa+CNA->CNA_CRONOG+cParcel)
			aExp2[_nY][nPosQunt] := CNF->CNF_VLPREV / aExp2[_nY][nPosVTOT] 
			nTotVlMed := M->CND_VLTOT := aExp2[_nY][nPosVUnt] := CNF->CNF_VLPREV
		EndIf
	Next _nY

Return {aExp1,aExp2,aExp3,aExp4}