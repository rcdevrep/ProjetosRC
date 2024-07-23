#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} AGR100
//Sugestão de TES de saída (TMKA271->UB_TES / MATA410->C6_TES)
@author Leandro F Silveira
@since 30/08/2017

@type function
/*/
User Function AGR100()

	Local cTes      := ""
	Local cTipoCli  := ""
	Local nPICM     := 0

	If SM0->M0_CODIGO == '01' .And. AllTrim(SB1->B1_CODANT) <> 'XISTO'
		If (SB1->B1_TIPO == "CO" .Or. SB1->B1_TIPO == "LU") .AND. SB1->B1_PROC <> "010148" //Fornecedor Wickers pega tes do produto
			If SA1->A1_TIPO $ "F/L" //consumidor final e produtor rural - chamado 99348 - TES INCORRETA
				cTes := "685"
			ElseIf SA1->A1_TIPO == "R"
				cTes := "684"
			EndIf
		EndIf
	EndIf

	If (SM0->M0_CODIGO == '16' .And. SM0->M0_CODFIL == '01')

		If (SA1->A1_EST == 'PR')

			If (FunName() == 'MATA410')
				cTipoCli  := M->C5_TIPOCLI
			EndIf

			If (FunName() == 'TMKA271')
				cTipoCli  := M->UA_TIPOCLI
			EndIf

			If (cTipoCli == 'R')

				nPICM := IIf(SB1->B1_PICM > 0, SB1->B1_PICM, GetMV("MV_ICMPAD"))

				If (SB1->B1_TS == '503')
					If (nPICM == 18)
						cTes := '520'
					Else
						If (nPICM == 25)
							cTes := '518'
						EndIf
					EndIf
				Else
					If (SB1->B1_TS == '516')
						If (nPICM == 18)
							cTes := '524'
						Else
							If (nPICM == 25)
								cTes := '526'
							EndIf
						EndIf
					EndIf
				EndIf

				If (FunName() == 'TMKA271' .And. !Empty(cTes))
					MaFisRef("IT_TES", "TK273", cTes)
				EndIf
			EndIf
		EndIf
	EndIf

	If Empty(cTes)
		If SM0->M0_CODIGO == '01' .And. FunName() == "MATA410" .And. M->C5_TIPO == "D"
			Return cTes := ""
		Else
			Return cTes := SB1->B1_TS
		EndIf
	Else
	   If alltrim(FunName()) == 'TMKA271' 
	      MaFisRef("IT_TES", "TK273", cTes)
	    Endif
	    	
		Return cTes
	EndIf
     
	If alltrim(FunName()) == 'TMKA271'  
	   MaFisRef("IT_TES", "TK273", cTes)
	Endif

Return cTes