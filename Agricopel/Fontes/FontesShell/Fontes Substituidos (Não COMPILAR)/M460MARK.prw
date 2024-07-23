#include "topconn.ch"

/*/{Protheus.doc} M460MARK
Ponto de entrada para validar as notas de remessa
selecionadas
@author Jaime Wikanski
@since 29/11/06
@version P11
@uso Fusus
@type function
/*/
User Function M460MARK()

Local lReturn := .T.

//@ticket 945882 - T10532 - José Carlos Jr. - Validação adicionada conforme enviada pelo cliente.
If SuperGetMv("FS_VLDDTB", , "0") == "1" .AND. !ValDataBase()
	lReturn := .F.
EndIf

If lReturn .AND. SC5->(FieldPos("C5_TPPVREM")) > 0 .and. SC5->(FieldPos("C5_CLIREM")) > 0 .and. SC5->(FieldPos("C5_LJREM")) > 0 .and. SC5->(FieldPos("C5_PVREM")) > 0
	MsgRun("Validando pedidos selecionados","Pedidos de Venda", { || lReturn := ValPvSel()} )
EndIf

Return(lReturn)


/*/{Protheus.doc} ValPvSel
Valida os pedidos selecionados
@author Jaime Wikanski
@since 29/11/06
@version P11
@uso Fusus
@type function
/*/
Static Function ValPvSel()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lReturn		:= .T.
Local aArea			:= GetArea()
Local aAreaSC9		:= {}
Local lMarked		:= .F.
Local cPedido		:= ""
Local cItem			:= ""
Local cPvRelac		:= ""
Local aPvInv		:= {}
Local cMsg			:= ""
Local nX			:= 0

DbSelectArea("SC9")
DbGoTop()
While !EOF()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o item foi marcado                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SC9->C9_OK == ThisMark()
		lMarked := .T.
	Else
		lMarked := .F.
	Endif
	cPedido		:= SC9->C9_PEDIDO
	cItem		:= SC9->C9_ITEM
	aAreaSC9	:= SC9->(GetArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no cabecalho do pedido de vendas                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC5")
	DbSetOrder(1)
	MsSeek(xFilial("SC5")+cPedido,.F.)
	If SC5->C5_TPPVREM == "V" .or. SC5->C5_TPPVREM == "R"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o item amarrado esta no browse                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPvRelac := SC5->C5_PVREM
		If !Empty(cPvRelac)
			DbSelectArea("SC9")
			DbSetOrder(1)
			If !DbSeek(xFilial("SC9")+cPvRelac+cItem,.F.) .and. lMarked
				If aScan(aPvInv,{|x| x[1] == cPedido+"-"+cItem}) == 0 .and. aScan(aPvInv,{|x| x[2] == cPedido+"-"+cItem}) == 0
					Aadd(aPvInv, {cPedido+"-"+cItem,cPvRelac+"-"+cItem})
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reposiciona o SC9                                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SC9")
				RestArea(aAreaSC9)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Desmarca o item selecionado                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SC9",.f.)
				SC9->C9_OK 	:= Space(4)
				MsUnlock()
				lReturn 	:= .F.
			ElseIf lMarked .and. SC9->C9_OK <> ThisMark()
				If aScan(aPvInv,{|x| x[1] == cPedido+"-"+cItem}) == 0 .and. aScan(aPvInv,{|x| x[2] == cPedido+"-"+cItem}) == 0
					Aadd(aPvInv, {cPedido+"-"+cItem,cPvRelac+"-"+cItem})
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Desmarca o item selecionado                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SC9",.f.)
				SC9->C9_OK 	:= ThisMark()
				MsUnlock()
				lReturn 	:= .F.
			Endif
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reposiciona o SC9                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC9")
	RestArea(aAreaSC9)

	DbSelectArea("SC9")
	DbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera a mensagem a ser exibida                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lReturn
	For nX := 1 to Len(aPvInv)
     	cMsg += "Pedido "+aPvInv[nX,1]+" - Pedido relacionado "+aPvInv[nX,2]+chr(13)+Chr(10)
	Next nX
	Aviso("Aviso","Existem pedidos de venda e remessa que não estavam selecionados. Geração não permitida."+Chr(13)+Chr(10)+cMsg,{"Ok"},3,"Atenção:",,"NOCHECKED")
Endif
RestArea(aArea)
Return(lReturn)


/*/{Protheus.doc} ValDataBase
Valida se a data do sistema foi alterada.
@author shell.mansur
@since 12/06/2017
@version P11
@uso Fusus
@type function
/*/
Static Function ValDataBase()

Local cMsg := ""
Local lRet := .T.

If Date() <> dDataBase
	cMsg += "Atenção! Data base do sistema diferente da data do servidor, não será possível processar faturamento!" + CHR(13)
	cMsg += "Data atual: " + DTOC(Date()) + CHR(13)
	cMsg += "Data base logada: " + DTOC(dDataBase)

	Alert(cMsg)
	lRet := .F.
EndIf

Return lRet