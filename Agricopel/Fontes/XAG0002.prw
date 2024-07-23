#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

/*/{Protheus.doc} XAG0002
- Sugere TES de venda para empresa LUPARCO (CallCenter e Pedidos)
- Chamado a partir do fontes gatilho AGR100 para aplicar a sugestão
- Chamado a partir do fonte ponto de entrada TK271BOK para validar se TES estão de acordo com regra
@author Leandro F Silveira
@since 12/09/2017
@version 1
@param xA1Est    , caractere  , UF do cliente - (A1_EST)
@param xTipoCli  , caractere  , Tipo do cliente - (C5_TIPOCLI/UA_TIPOCLI)
@param xB1Cod    , caractere  , Código do produto - (B1_COD / C6_PRODUTO / UB_PRODUTO)
@return caractere, TES conforme regra e parâmetros recebidos
@type function
/*/
User Function XAG0002(xA1Est, xTipoCli, xB1Cod)

	Local aSegSB1 := {}
	Local cTes    := ""
	Local nPICM   := 0

	Default xA1Est   := ""
	Default xTipoCli := ""
	Default xB1Cod   := ""

	If (AllTrim(xA1Est) == "PR" .And. AllTrim(xTipoCli) == "R")

		aSegSB1 := SB1->(GetArea())

		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+xB1Cod))

			nPICM := IIf(SB1->B1_PICM > 0, SB1->B1_PICM, GetMV("MV_ICMPAD"))

			If (SB1->B1_TS == "503")
				If (nPICM == 18)
					cTes := "520"
				Else
					If (nPICM == 25)
						cTes := "518"
					EndIf
				EndIf
			Else
				If (SB1->B1_TS == "516")
					If (nPICM == 18)
						cTes := "524"
					Else
						If (nPICM == 25)
							cTes := "526"
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		RestArea(aSegSB1)
	EndIf

Return(cTes)