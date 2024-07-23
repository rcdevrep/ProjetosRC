#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271BOK  ºAutor  ³Thiago Padilha      º Data ³  27/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa executa algumas validacoes quando pressiona      º±±
±±º          ³  o botao de confirmar no atendimento do Call Center        º±±
±±º          ³  Foi inserida validacao para informar se pedido ja se      º±±
±±º          ³  encontra impresso (C5_XIMPRE = S). Chamado 51183          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TK271BOK()
	Private lRet    := .T.
	Private aSegSUA := SUA->(GetArea())

	dbSelectArea("SUA")
	dbSetOrder(1)
	If dbSeek(xFilial("SUA")+M->UA_NUM,.T.)
		If ((cEmpAnt == "01" .and. cFilAnt == "06") .or. (cEmpAnt == "16")) .and. !empty(Alltrim(SUA->UA_NUMSC5))
			dbSelectArea("SC5")
			dbSetOrder(1)
			//if dbSeek(xFilial("SC5")+M->UA_NUMSC5,.T.)
			If dbSeek(xFilial("SC5")+SUA->UA_NUMSC5,.T.)
				IF Alltrim(SC5->C5_XIMPRE) == "S"
					//alert("entrou no while, pedido impresso: " +M->UA_NUMSC5+ " atend: "+M->UA_NUM)
					//lRet := MsgYesNO("O Pedido " +SUA->UA_NUMSC5+ " se encontra impresso, deseja continuar com o processo? ")
					APMSGALERT("O Pedido " +SUA->UA_NUMSC5+ " se encontra impresso, para efetivar a alteração, entre em contato com setor de faturamento! ")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If (lRet) .And. (SM0->M0_CODIGO == '16' .And. SM0->M0_CODFIL == '01' .And. M->UA_TIPOCLI == 'F')
		lRet := ValTesLuparco()
	EndIf
    
    //Cliente inativo nao pode gerar pedido no TRR
	If (lRet) .And. ((SM0->M0_CODIGO == '01' .And. (SM0->M0_CODFIL == '02' .or. SM0->M0_CODFIL == '03'.or. SM0->M0_CODFIL == '15')) .Or. (SM0->M0_CODIGO == '11').Or.(SM0->M0_CODIGO == '12') .Or. (SM0->M0_CODIGO == '15'))
		lRet := ValClienteInativo()
	EndIf         

	RestArea(aSegSUA)

Return(lRet)

Static Function ValTesLuparco()

	Local lRet        := .T.
	Local nUB_TES     := aScan(aHeader,{|x| alltrim(x[2]) == "UB_TES"})
	Local nUB_Produto := aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
	Local nLenSUB     := Len(aCols)
	Local i           := 0
	Local aSegSB1     := SB1->(GetArea())
	Local cListaPrd   := ""
	Local cProduto    := ""
	Local cTes        := ""

	SB1->(DbSetOrder(1))

	For i := 1 to nLenSUB

		cProduto := aCols[i][nUB_Produto]
		cTes     := aCols[i][nUB_TES]

		If (SB1->(DbSeek(xFilial("SB1")+cProduto)))

			If (AllTrim(SB1->B1_POSIPI) == '33074900') .And. (cTes <> "516")
				cListaPrd += "TES: " + AllTrim(cTes) + " - Produto: " + AllTrim(cProduto) + " - " + AllTrim(SB1->B1_DESC) + Chr(13) + Chr(10)
			EndIf
		EndIf
	Next

	RestArea(aSegSB1)

	If (!Empty(cListaPrd))
		lRet := .F.
		Alert("Atendimento possui um ou mais produtos com a TES inconsistente para venda a consumidor final!" + Chr(13)+Chr(10)+Chr(13)+Chr(10) + cListaPrd + Chr(13)+Chr(10) + "Será necessário corrigir estas inconsistências antes de continuar!")
	EndIf

Return(lRet)


Static Function ValClienteInativo()
	Local lRet        := .T.

	IF (SA1->A1_SITUACA == "2")
		MSGSTOP("CLIENTE INATIVO !")
		lRet := .F.
	ENDIF

Return(lRet)