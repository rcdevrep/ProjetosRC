#include "Rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MC010GRV  ºAutor  ³Emerson Probst         º Data ³  17/08/16º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gravar campos especificos apos Formação de PRECO           º±±
±±º          ³                                                            º±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


USER Function MC010GRV()

Dbselectarea("DA1")
IF DA1->(FieldPos("DA1_ZCSTCO")) > 0
	nVlrCpr := 0
	nPerVds := 0
	nPerMgr := 0

	Dbselectarea("DA1")
	Dbsetorder(2) //DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
	Dbseek(xfilial("DA1")+SB1->B1_COD,.T.)
	While !EOF() .AND. DA1_CODPRO == SB1->B1_COD .AND. DA1_FILIAL == xFilial("DA1")
		
		nVlrCpr := 0
		nPerVds := 0
		nPerMgr := 0
		Pergunte( "MTC010", .F. )
		nVlrCpr := MaPrcPlan(SB1->B1_COD,"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
		nPerVds := MaPrcPlan(SB1->B1_COD,"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
		nPerMgr := MaPrcPlan(SB1->B1_COD,"SLA_AGR","PERC_REF_MARGEM",0)  //PORCENTUAL MARGEM CONTRIBUICAO (j)

		Dbselectarea("DA1")
		Reclock("DA1",.F.)
		DA1->DA1_ZCSTCO   :=nVlrCpr
		DA1->DA1_ZPVEND   :=nPerVds
		DA1->DA1_ZPMARG   :=nPerMGR
		msunlock()
		Dbselectarea("DA1")
		Dbskip()
	Enddo
	
	//cmens:='nVlrCpr '+alltrim(str(nVlrCpr))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
	//cmens+='nPervds '+alltrim(str(nPervds))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
	//cmens+='nPerMgr '+alltrim(str(nPerMgr))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
	//MSGalert(cmens)
Endif
Return(.T.)
