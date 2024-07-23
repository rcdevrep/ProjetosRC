#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MSD2460  ºAutor  ³ Marcelo/Jean       º Data ³  01/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na gravacao dos itens da NFS para gravar  º±±
±±º          ³ dados da amarracao e estrutura para poroduto.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function NxD2460()
*********************
LOCAL aSeg := GetArea(), aSegSA7 := SA7->(GetArea())
LOCAL cCliente := Space(6), cLoja   := Space(2), cProduto := Space(15)
LOCAL cPedido  := Space(6), cTabela := Space(3)
LOCAL nPrcTab  := 0 ,nPrcPro := 0
LOCAL nQuant	:= 0
LOCAL aItem		:= {}
LOCAL aTotItem	:= {}
LOCAL cProdSG1	:= space(30)
LOCAL cUMSG1	:= space(02)
LOCAL cProdSD2	:= space(30)
LOCAL cProximo

// REMOVIDA LOGICA PARA GERACAO DE SD3 EM 25.08.
// A LOGICA QUE ESTAVA NESTE PONTO FOI REMOVIDA PARA O FINAL DESTE FONTE.
// VALDECIR.

//Busco dados necessarios para a amarracao
//////////////////////////////////////////
cCliente := SD2->D2_cliente
cLoja    := SD2->D2_loja
cProduto := SD2->D2_cod
cPedido  := SD2->D2_pedido

//Busco tabela de preco
///////////////////////
cTabela := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_TABELA")

//Busco preco de tabela
///////////////////////
nPrcTab := 0
dbSelectArea("DA1")
dbSetOrder(2)
dbSeek(xFilial("DA1")+cProduto+cTabela,.T.)
While !Eof().and.(xFilial("DA1") == DA1->DA1_filial).and.(DA1->DA1_codpro+DA1->DA1_codtab == cProduto+cTabela)
	nPrcTab := DA1->DA1_prcven
	dbSkip()
Enddo

//Busco preco em promocao
/////////////////////////
nPrcPro := 0
dbSelectArea("ACO")
dbSetOrder(2)
dbSeek(xFilial("ACO")+cTabela,.T.)
While !Eof().and.(xFilial("ACO") == ACO->ACO_filial).and.(ACO->ACO_codtab == cTabela)
	If (ACO->ACO_promoc == "S")
		dbSelectArea("ACP")
		dbSetOrder(1)
		dbSeek(xFilial("ACP")+ACO->ACO_codreg,.T.)
		While !Eof().and.(xFilial("ACP") == ACP->ACP_filial).and.(ACP->ACP_codreg == ACO->ACO_codreg)
			If (ACP->ACP_codpro == cProduto)
				nPrcPro := nPrcTab - ((nPrcTab * ACP->ACP_perdes) / 100)
			Endif
			dbSkip()
		Enddo
	Endif
	dbSelectArea("ACO")
	dbSkip()
Enddo

//Gravo no arquivo de amarracao
///////////////////////////////
dbSelectArea("SA7")
dbSetOrder(1)
If dbSeek(xFilial("SA7")+cCliente+cLoja+cProduto)
	Reclock("SA7",.F.)
Else
	Reclock("SA7",.T.)
	SA7->A7_filial  := xFilial("SA7")
	SA7->A7_cliente := cCliente
	SA7->A7_loja    := cLoja
	SA7->A7_produto := cProduto
Endif
SA7->A7_descri  := Alltrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))
SA7->A7_quant   := SD2->D2_quant
SA7->A7_prcven  := SD2->D2_prcven
SA7->A7_emissao := SD2->D2_emissao
SA7->A7_prctab  := nPrcTab
SA7->A7_prcpro  := nPrcPro
SA7->A7_emiinv  := Strzero(99999999-Val(dtos(SD2->D2_emissao)),8)
SA7->A7_CONDPGT := SF2->F2_COND // Solicitação do chamado 40125 - Thiago SLA - 02/06/2016
MsUnlock("SA7")

RestArea(aSegSA7)
RestArea(aSeg)

Return

/*  REMOVIDO POR VALDECIR EM 25.08.
If SM0->M0_CODIGO <> "02"

PRIVATE lMsErroAuto := .F.

lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)

dbSelectArea('SF2')
dbSelectArea('SD2')

//Monta os itens
//               1            2          3           4          5        6         7            8        9           10      11         12           13           14           15           16           17         18           19           20
//aadd(aItem,{SF2->F2_DOC, SF2->F2_EMISSAO})

//If !lPyme
//	aItem :=	{	{SF2->F2_DOC,SF2->F2_EMISSAO, 'D3_COD', 'D3_DESCRI','D3_UM','D3_LOCAL','D3_LOCALIZ','D3_COD','D3_DESCRI','D3_UM','D3_LOCAL','D3_LOCALIZ','D3_NUMSERI','D3_LOTECTL','D3_NUMLOTE','D3_DTVALID','D3_QUANT','D3_QTSEGUM','D3_ESTORNO','D3_NUMSEQ'  }}
//Else
//	aItem :=	{	{SF2->F2_DOC,SF2->F2_EMISSAO, 'D3_COD', 'D3_DESCRI','D3_UM','D3_LOCAL','D3_COD','D3_DESCRI','D3_UM','D3_LOCAL','D3_QUANT','D3_QTSEGUM','D3_ESTORNO','D3_NUMSEQ'  }}
//Endif

dbSelectArea('SG1')
dbSetOrder(1)
IF dbSeek(xFilial('SG1')+SD2->D2_COD,.T.)
While !Eof() .AND. SG1->G1_FILIAL == xFilial('SG1') .AND. SG1->G1_COD == SD2->D2_COD
dbSelectArea('SB1')
dbSetOrder(1)
dbSeek(xFilial('SB1')+SG1->G1_COMP)
nQuant := SD2->D2_QUANT * (SG1->G1_PERUTIL /100)
cProdSG1	:= SB1->B1_DESC
cUMSG1	:= SB1->B1_UM
dbSelectArea('SB1')
dbSetOrder(1)
dbSeek(xFilial('SB1')+SD2->D2_COD)
cProdSD2	:= SB1->B1_DESC
cProximo	:= ProxNum()
If !lPyme
Aadd(aItem,{SG1->G1_COMP,cProdSG1,cUMSG1,SD2->D2_LOCAL,'',SD2->D2_COD,cProdSD2,SD2->D2_UM,SD2->D2_LOCAL,'','','','',CTOD(''),0,nQuant,0,'',''})
Else
Aadd(aItem,{SG1->G1_COMP,cProdSG1,cUMSG1,SD2->D2_LOCAL,SD2->D2_COD,cProdSD2,SD2->D2_UM,SD2->D2_LOCAL,nQuant,0,'',''})
Endif
dbSelectArea('SG1')
dbSkip()
EndDo

//Rota a rotina automática
MSExecAuto({|x| MATA261(x)},aItem)

If lMsErroAuto
MostraErro()
Alert("Verificar e corrigir os erros apontados, excluir a nota e repetir a geracao desta !!!")
Endif
ENDIF

ENDIF // INCLUIDO POR VALDECIR EM 26.06.03
*/
