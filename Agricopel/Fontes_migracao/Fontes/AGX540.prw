#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGX540  ³ Autor ³ Leandro F. Silveira  ³ Data ³ 27/03/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para buscar ultimo preco de compra pedido compras  ´±± 
±±³          ³ Chamado pelo gatilho do campo C7_PRODUTO                   ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX540()

	Local nPosCodPro  := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRODUTO"})
	Local nPosTot     := aScan(aHeader,{|x| alltrim(x[2])=="C7_TOTAL"})
	Local nPosPre     := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRECO"})
	Local nPosPrecoT  := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRECOT"})
	Local nPosQuant   := aScan(aHeader,{|x| alltrim(x[2])=="C7_QUANT"})

    Local nC7_PRECO   := 0
    Local nC7_PRECOT  := 0
    Local nC7_TOTAL   := aCols[N,nPosTot]
    Local nC7_QUANT   := aCols[N,nPosQuant]
    Local cC7_PRODUTO := aCols[N,nPosCodPro]

    If SM0->M0_CODIGO = "01"

		DbSelectArea("SB1")
		DbSeek(xFilial("SB1")+cC7_PRODUTO)

	    nC7_PRECOT  := aCols[N,nPosPrecoT]	
	    nC7_PRECO   := aCols[N,nPosPre]

		If nC7_PRECO = 0
			aCols[N,nPosPre] := SB1->B1_UPRC2
			nC7_PRECO        := SB1->B1_UPRC2
		EndIf

		If nC7_PRECOT = 0
			aCols[N,nPosPrecoT] := SB1->B1_UPRC
			nC7_PRECOT          := SB1->B1_UPRC
		EndIf

		nC7_TOTAL := Round(nC7_QUANT * nC7_PRECO, TamSX3("C7_TOTAL")[2])

    EndIf

Return nC7_TOTAL