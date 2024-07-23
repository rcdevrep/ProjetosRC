/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT120LOK  � Autor � TSC 422 - Rodrigo  � Data �  05/09/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Validar o c�digo do pedido                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel - SIGACOM                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
				MsgAlert("ATEN��O: preencha o pedido a bonificar!")
				lRet := .F.
			Else
				cFornec := Posicione("SC7",1, xFilial("SC7")+aCols[n][nPosPedBon], "C7_FORNECE")		
				If cFornec <> cA120Forn
					MsgAlert("ATEN��O: o fornecedor do pedido a faturar n�o � o mesmo do pedido a bonificar !")
					lRet := .F.               
				EndIf
			EndIf
		ElseIf aCols[n][nPosBonif] == "N" .AND. !Empty(aCols[n][nPosPedBon])
			MsgAlert("ATEN��O: este pedido n�o � de bonifica��o!")
			lRet := .F.
		EndIf
		
	EndIf                                

EndIf

Return lRet