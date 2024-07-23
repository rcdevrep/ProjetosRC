/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120ISC     ºAutor  Leandro Silveira  º Data ³  12/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada chamado na hora que clica em ok na consul º±±
±±º          ³ ta de sol. de compra, para calcular preços e totais        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT120ISC()

	Local cC7_PRECO   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "C7_PRECO"})
	Local cC7_QUANT   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "C7_QUANT"})
	Local cC7_TOTAL   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "C7_TOTAL"})
	Local cC7_PRODUTO := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "C7_PRODUTO"})
	Local cProduto    := aCols[n, cC7_PRODUTO]

	If SM0->M0_CODIGO == "01" .And. (Alltrim(SM0->M0_CODFIL) == "06" .Or. Alltrim(SM0->M0_CODFIL) == "02")

		RunTrigger(2, n, nil,, "C7_PRODUTO")

		aCols[N,cC7_PRECO] := EXECBLOCK("AGR177",.F.,.F.)
		aCols[N,cC7_PRECO] := EXECBLOCK("AGR184",.F.,.F.)

		aCols[N,cC7_TOTAL] := NoRound(aCols[N,cC7_PRECO] * aCols[N,cC7_QUANT],TamSX3("C7_TOTAL")[2])

	EndIf

Return