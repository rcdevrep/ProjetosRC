#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR882       ºAutor  ³Alan Leandro    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que faz a logica para validar se precisa            º±±
±±º          ³ chamar o JOB para conectar a empresa transportadora        º±±
±±º          ³ para validar remetente e destinatario.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR882()
********************
Local aSeg		:= GetArea()
Local aSegSA1	:= SA1->(GetArea())
Local aSegSA4	:= SA4->(GetArea())
Local aSegSC5	:= SC5->(GetArea())
Local aSegSC9	:= SC9->(GetArea())
Local aSegSM0	:= SM0->(GetArea())
Local lRet		:= .T., lChamaJob, cCgcCli, cCgcEmp := SM0->M0_cgc, cMsg
Local cMarcAux	:= ParamIxb[1]
Local lInvAux	:= ParamIxb[2]

// Verifica se a empresa atual deve gerar automaticamente a entrada da NF na empresa transportadora
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
If GetMv("MV_GERADTC") <> "S"
	Return lRet
EndIf

// Varro o SC9 para verificar quais pedidos serao processados
/////////////////////////////////////////////////////////////////////////////////////
SC9->(dbGoTop())
While !SC9->(EOF())
	
	lChamaJob := .F.
	
	// Verifico se o pedido esta selecionado para gerar nota
	///////////////////////////////////////////////////////////////////////////////////
	If lInvAux
		If SC9->C9_ok <> cMarcAux
			lChamaJob := .T.
		EndIf
	Else
		If SC9->C9_ok == cMarcAux
			lChamaJob := .T.
		EndIf
	EndIf
	
	If lChamaJob
		// Procuro a transportadora e verifico se ela esta dentro do sigamat
		//////////////////////////////////////////////////////////////////////////////////////////////
		SC5->(dbSetOrder(1))
		If SC5->(dbSeek(xFilial("SC5")+SC9->C9_pedido))
			If !Empty(SC5->C5_transp)
				SA4->(dbSetOrder(1))
				If SA4->(dbSeek(xFilial("SA4")+SC5->C5_transp)) .and. !Empty(SA4->A4_cgc)
					SM0->(dbGoTop())
					While !SM0->(EOF())
						If Alltrim(SA4->A4_cgc) == Alltrim(SM0->M0_cgc)
							SA1->(dbSetOrder(1))
							SA1->(dbSeek(xFilial("SA1")+SC9->C9_cliente+SC9->C9_loja))
							cCgcCli	:= SA1->A1_cgc
							// Se achar uma empresa no sistema para a transportadora informada,
							// chamo o JOB que vai validar os dados do cliente para o TMS
							/////////////////////////////////////////////////////////////////////////////////
							lRet	:= StartJob("U_AGR883",GetEnvServer(),.T.,cCgcCli,cCgcEmp,SM0->M0_codigo,SM0->M0_codfil)
							If !lRet
								cMsg := "Nao e possivel gerar a entrada da NF referente ao pedido "+SC9->C9_pedido+" "
								cMsg += "no TMS da empresa "+Alltrim(SA4->A4_nome)+". "
								cMsg += "Verifique os dados do cliente "+Alltrim(SA1->A1_nome)+" nesta empresa!!! "
								Aviso("Atencao",cMsg,{"Cancelar"})
							EndIf
							Exit
						EndIf
						SM0->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf
	SC9->(dbSkip())
EndDo

RestArea(aSeg)
RestArea(aSegSA1)
RestArea(aSegSA4)
RestArea(aSegSC5)
RestArea(aSegSC9)
RestArea(aSegSM0)

Return lRet
