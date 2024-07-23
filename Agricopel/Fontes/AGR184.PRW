#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR184  ³ Autor ³ Deco                  ³ Data ³ 06/06/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para buscar ultimo preco de compra pedido  compras ´±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR184()

	Local nPosPro     := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRODUTO"})
	Local nPosTot     := aScan(aHeader,{|x| alltrim(x[2])=="C7_TOTAL"})
	Local nPosPre     := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRECO"})
	Local nPosPrecoT  := aScan(aHeader,{|x| alltrim(x[2])=="C7_PRECOT"})

	Local cProduto    := aCols[N,nPosPro]
    Local nC7_PRECO   := aCols[N,nPosPre]
    Local nC7_PRECOT  := aCols[N,nPosPrecoT]

  	*
  	* Calculo para obter preco unitario liquido para Nf Entrada Cfe Ademir/Alexandre 28/09/2005
  	*

    If SM0->M0_codigo = "01" .And. (Alltrim(SM0->M0_CODFIL) == '01' .Or. Alltrim(SM0->M0_CODFIL) == '02' .OR. Alltrim(SM0->M0_CODFIL) == "06") // Agricopel Matriz // Pien // Atacado

	  	nB1_PICMENT := Posicione("SB1",1,xFilial("SB1")+cProduto,"SB1->B1_PICMENT")

		If !Empty(nB1_PICMENT)  // Somente qdo houver Icms Solidario/Subst. Tributaria

		  	nFixo := 1.0000 // Valor Fixo

		  	nB1_PICMENT := (nB1_PICMENT / 100) // Icms solidario do cadastro produto

			If Alltrim(SM0->M0_CODFIL) == '01' .Or. Alltrim(SM0->M0_CODFIL) == '06'
				nIcms := 0.17 // Aliquota ICMS SC
			Else
				nIcms := 0.18 // Aliquota ICMS PR
	  		EndIf

			nIndice := ((nFixo + nB1_PICMENT) * nIcms) + nFixo

			nC7_PRECO := nC7_PRECOT / nIndice

	  	Else

	  		nC7_PRECO := nC7_PRECOT

	  	EndIf

  	EndIf

Return nC7_PRECO