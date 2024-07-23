#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT140TOK  บ Autor ณ Leandro F Silveira บ Data ณ  12/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida็ใo dos itens da pre nota.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MT140TOK()

Local aAreaAnt := GetArea()
Local lUpd     := .F.
Local nX
Local cCondicao:= ""
Local nPercQtd := 0
Local nPercVal := 0
Local nDifVal  := 0.00
Local nDifQtd  := 0.00
Local _cMsg    := ""
Local _aMsg    := {}
Local nQtCla   := 0       



If Type("CNFISCAL") == "C" .And. !Empty(CNFISCAL) 
	If !Len(AllTrim(CNFISCAL)) == TamSX3("F1_DOC")[1] .AND. cFormul <> "S"
		Aviso("Aten็ใo: n๚mero do documento invแlido!", "N๚mero do documento possui [" + AllTrim(Str(Len(AllTrim(CNFISCAL)))) + "] caracteres ao inv้s de [" + AllTrim(Str(TamSX3("F1_DOC")[1])) + "]!", {"Ok"})
		Return .F.
	EndIf
EndIf

If SM0->M0_CODIGO == "01" .And. (Alltrim(SM0->M0_CODFIL) == "06" .or. Alltrim(SM0->M0_CODFIL) == "14"  ).And. AllTrim(CTIPO) == "N" .And. AllTrim(CESPECIE) <> "CTE"

	nPercQtd := GetMV("MV_PERCQTD")
	nPercVal := GetMV("MV_PERCPR")

	nPosProd  := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_COD"    })
	nPosPed   := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_PEDIDO" })
	nPosIt    := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_ITEMPC" })
	nPosQtd   := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_QUANT"  })
	nPosQtdS  := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_QTSEGUM"})
	nPosVal   := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_VUNIT"  })
	nPosNfBon := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_NFBONIF"})
	nPosQtCla := aScan( aHeader , { |x| AllTrim(x[2]) == "D1_QTDACLA"})

	For nX := 1 To (Len(aCols))

		If !aCols[nX,(Len(aCols[nX]))]

			nDifPre  := 0.00
			nDifQtd  := 0.00
			lUpd     := .F.

			If AllTrim(aCols[nX,nPosPed]) <> "" .And. AllTrim(aCols[nX,nPosIt]) <> ""

				dbSelectArea("SC7")
				dbSetOrder(4)
				If SC7->(dbSeek(xFilial("SC7")+aCols[nX,nPosProd]+aCols[nX,nPosPed]+aCols[nX,nPosIt]))
	            	
					If (SC7->C7_QUANT - SC7->C7_QUJE) < aCols[nX,nPosQtd]
						// verifica o percentual da quantidade
						nQtdPerc:= Round( ((nPercQtd/100)*(SC7->C7_QUANT)) , 2)
						nQtdMax := (SC7->C7_QUANT - SC7->C7_QUJE) + nQtdPerc
						nDifQtd := IIf(Round(aCols[nX,nPosQtd]-nQtdMax, 2) < 0 , 0, Round(aCols[nX,nPosQtd]-nQtdMax, 2) )
	
						if nDifQtd > 0
							aADD(_aMsg, "Produto: " + AllTrim(aCols[nX,nPosProd]) +;
										" - Qtde NF: " + AllTrim(Transform(aCols[nX,nPosQtd], "@E 999,999.99")) +;
										"  Qtde Ped: " + AllTrim(Transform((SC7->C7_QUANT - SC7->C7_QUJE), "@E 999,999.99")))
						EndIf
					EndIf

					If Inclui
						nQtCla := SC7->C7_QTDACLA + aCols[nX,nPosQtd]
					Else
						If aCols[nX,nPosQtCla] > 0
							nQtCla := SC7->C7_QTDACLA + aCols[nX,nPosQtd] - aCols[nX,nPosQtCla]
						Else
							nQtCla := SC7->C7_QTDACLA + aCols[nX,nPosQtd]
						EndIf
					EndIf

					If (SC7->C7_QUJE + nQtCla) > SC7->C7_QUANT

						nQtdPerc:= Round( ((nPercQtd/100)*(SC7->C7_QUANT)), 2)
						nQtdMax := (SC7->C7_QUANT - SC7->C7_QUJE) + nQtdPerc
						nDifQtd := IIf(Round(nQtCla-nQtdMax, 2) < 0 , 0, Round(nQtCla-nQtdMax, 2) )

						aADD(_aMsg, "Produto: " + AllTrim(aCols[nX,nPosProd]) + "/ Pedido: " + SC7->C7_NUM +;
									" - Qtde Ped: " + AllTrim(Transform(SC7->C7_QUANT, PesqPict("SC7","C7_QUANT"))) +;
									"  Qtde Jแ Entregue: " + AllTrim(Transform((SC7->C7_QUJE), PesqPict("SC7","C7_QUJE"))) +;
									"  Qtde a Classificar: " + AllTrim(Transform((If(Inclui,nQtCla,SC7->C7_QTDACLA)), PesqPict("SC7","C7_QTDACLA"))))
					EndIf

					If SC7->C7_PRECOT < aCols[nX,nPosVal]
						// verifica o percentual do valor
						nValPerc := Round( ((nPercVal/100)*SC7->C7_PRECOT) , 2)
						nValMax  := SC7->C7_PRECOT + nValPerc
						nDifPre  := IIf( Round(aCols[nX,nPosVal]-nValMax, 2) < 0, 0, Round(aCols[nX,nPosVal]-nValMax, 2))
	
						if nDifPre > 0
							aADD(_aMsg, "Produto: " + AllTrim(aCols[nX,nPosProd]) +;
										" - Valor NF: " + AllTrim(Transform(aCols[nX,nPosVal], PesqPict("SD1","D1_VUNIT"))) +;
										"  Valor Ped: " + AllTrim(Transform(SC7->C7_PRECOT, PesqPict("SC7","C7_PRECOT"))))
						EndIf
					EndIf
	
					Begin Transaction
						RecLock("SC7",.F.)
							SC7->C7_DIFQTD := nDifQtd
							SC7->C7_DIFPR  := nDifPre
						SC7->(MsUnlock())
					End Transaction

					dbCloseArea("SC7")
				EndIf
			Else
				aADD(_aMsg, "Produto: " + AllTrim(aCols[nX,nPosProd]) + " nใo possui pedido de compra!")
			EndIf
		EndIf

		// D1_QTDACLA SEMPRE SERม IGUAL AO CAMPO D1_QUANT, Sำ SERม DIFERENTE SE USUมRIO ALTERAR D1_QUANT E ENQUANTO NรO GRAVAR
		aCols[nX,nPosQtCla] := aCols[nX,nPosQtd]

	Next nX

	If Len(_aMsg) > 0 .And. !IsInCallStack("U_GOX008")

		_cMsg += "Um ou mais produtos estใo inconsistentes com seu pedido de compra:" + Chr(13) + Chr(10)

		For _iX := 1 To Len(_aMsg)
			_cMsg += _aMsg[_iX] + Chr(13) + Chr(10)
		Next _iX

		MsgAlert(AllTrim(_cMsg))

	EndIf

EndIf

	If !U_GOXIPNPX()
        
        Return .F.
        
    EndIf

Return .T.