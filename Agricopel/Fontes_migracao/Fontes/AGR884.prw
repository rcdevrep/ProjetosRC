#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR884       ºAutor  ³Alan Leandro    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que chama o JOB para excluir a entrada da NF        º±±
±±º          ³ na empresa transportadora.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR884()
********************
Local aSeg		:= GetArea()
Local aSegSA1	:= SA1->(GetArea())
Local aSegSA4	:= SA4->(GetArea())
Local aSegSC5	:= SC5->(GetArea())
Local aSegSD2	:= SD2->(GetArea())
Local aSegSM0	:= SM0->(GetArea())
Local cCgcDes, cCgcRem, cPedido, cMsg, lRet := .T., cEmpRem, cFilRem
Local aDados	:= {}

// Verifica se a empresa que gerou o SF2 e SD2 deve excluir automaticamente a entrada da NF na empresa transportadora
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
If GetMv("MV_GERADTC") <> "S"
	Return lRet
EndIf              

SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2")+SF2->F2_doc+SF2->F2_serie,.T.))
While SD2->(!Eof()) .And. SD2->D2_filial == xFilial("SD2") .and. SD2->D2_doc == SF2->F2_doc .and. SD2->D2_serie  == SF2->F2_serie
	
	cPedido		:= SD2->D2_pedido
	//nPesoDTC	+= SD2->D2_peso
	//nQtdDTC		+= SD2->D2_quant
	//nValDTC		+= SD2->D2_total
	
	SD2->(dbSkip())
EndDo

// Busco o cliente destinatario, para pegar o CGC.
// Para depois fazer a busca pelo CGC jah na empresa transportadora
//////////////////////////////////////////////////////////////////////////////////////////////////
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+SF2->F2_cliente+SF2->F2_loja))
cCgcDes := SA1->A1_cgc

// Guardo o Cgc do remetente pelo Cgc do sigamat.
///////////////////////////////////////////////////////////////////////////////////////////////////
cCgcRem := SM0->M0_cgc
cEmpRem := cEmpAnt
cFilRem := cFilAnt

// Procuro a transportadora e verifico se ela esta dentro do sigamat, alem disso ja guardo o Tipo de Frete
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+cPedido))
	cTpFrete := SC5->C5_tpfrete
	If !Empty(SC5->C5_transp)
		SA4->(dbSetOrder(1))
		If SA4->(dbSeek(xFilial("SA4")+SC5->C5_transp)) .and. !Empty(SA4->A4_cgc)
			SM0->(dbGoTop())
			While !SM0->(EOF())
				If Alltrim(SA4->A4_cgc) == Alltrim(SM0->M0_cgc)
					// Alimento o array que sera passado para a rotina que vai gerar o DTC
					///////////////////////////////////////////////////////////////////////////////////////////////////
					aDados := {cCgcRem,cCgcDes,SF2->F2_doc,SF2->F2_serie,cEmpRem,cFilRem,dDataBase}
				
					// Se achar uma empresa no sistema para a transportadora informada,
					// chamo o JOB que vai gerar a entrada da NF no TMS da transportadora
					/////////////////////////////////////////////////////////////////////////////////
					lRet	:= StartJob("U_AGR885",GetEnvServer(),.T.,SM0->M0_codigo,SM0->M0_codfil,aDados)
					If !lRet
						cMsg := "Nao e possivel excluir a entrada da NF na empresa "+Alltrim(SA4->A4_nome)+". "
						cMsg += "Por isso nao sera possivel excluir a NF atual. Contacte o Administrador do sistema!!!"
						Aviso("Atencao",cMsg,{"Cancelar"})
					EndIf
					Exit
				EndIf
				SM0->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aSeg)
RestArea(aSegSA1)
RestArea(aSegSA4)
RestArea(aSegSC5)
RestArea(aSegSD2)
RestArea(aSegSM0)
Return lRet
