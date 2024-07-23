/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120LOK  º Autor ³ TSC 422 - Rodrigo  º Data ³  05/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validar o código do pedido                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Agricopel - SIGACOM                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SH120LOK
           
Local cFornec   := ""
Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
Local nPosTab   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CODTAB"})
Local nPosPrc   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
Local nPosBonif := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_BONIF"})
Local nPosPedBon:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PEDBON"})
Local lRet	:= .T.   

If SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06"

	If !aCols[n][Len(aCols[n])]  // Verifica se esta deletado
	  
		If aCols[n][nPosBonif] == "S" 
			IF  Empty(aCols[n][nPosPedBon])
				MsgAlert("ATENÇÃO: preencha o pedido a bonificar!")
				lRet := .F.
			Else
				cFornec := Posicione("SC7",1, xFilial("SC7")+aCols[n][nPosPedBon], "C7_FORNECE")		
				If cFornec <> cA120Forn
					MsgAlert("ATENÇÃO: o fornecedor do pedido a faturar não é o mesmo do pedido a bonificar !")
					lRet := .F.               
				EndIf
			EndIf
		ElseIf aCols[n][nPosBonif] == "N" .AND. !Empty(aCols[n][nPosPedBon])
			MsgAlert("ATENÇÃO: este pedido não é de bonificação!")
			lRet := .F.
		EndIf
		
	EndIf                                

EndIf

Return lRet