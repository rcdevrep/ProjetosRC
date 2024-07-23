#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM010DA1 ºAutor  ³Emerson - SLA   º Data ³  18/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava campos especificos na Tabela DA1                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user Function OM010DA1()
Dbselectarea("DA1")
IF DA1->(FieldPos("DA1_ZCSTCO")) > 0
	Dbselectarea("SB1")
	Dbsetorder(1)
	Dbseek(xFilial("SB1")+DA1->DA1_CODPRO)
	
	nVlrCpr := 0
	nPerVds := 0
	nPerMgr := 0
	Pergunte( "MTC010", .F. )
	nVlrCpr := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
	nPerVds := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
	nPerMgr := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGR","PERC_REF_MARGEM",0)        //PORCENTUAL MARGEM CONTRIBUICAO (j)
	
	Dbselectarea("DA1")
	Reclock("DA1",.F.)
	DA1->DA1_ZCSTCO   :=nVlrCpr
	DA1->DA1_ZPVEND   :=nPerVds
	DA1->DA1_ZPMARG   :=nPerMGR
	msunlock()
Endif
Dbselectarea("DA1")
//U_CORRDA1()
Return


User Function CORRDA1()

PROCESSA({|LEND|PROCPLAN()},"ATUALIZANDO CAMPOS","AGUARDE. DA1...",.T.)
Return

Static Function PROCPLAN()

cquery:=" SELECT DA1.R_E_C_N_O_ RECNOX FROM "
cquery+= RETSQLNAME("DA0")+" DA0,"+ RETSQLNAME("DA1")+" DA1 "
cquery+=" WHERE DA0_DATATE > '20151231'"
cquery+=" AND DA0.D_E_L_E_T_ =  ' '"   
cquery+=" AND DA1.D_E_L_E_T_ =  ' '"   
cquery+=" AND DA1.DA1_FILIAL = DA0.DA0_FILIAL"
cquery+=" AND DA1.DA1_CODTAB = DA0.DA0_CODTAB"
cquery+=" AND DA1.DA1_CODTAB = '001' "
cquery+=" ORDER BY DA1.DA1_CODPRO"
TCQUERY cQuery NEW ALIAS "TRB"


Dbselectarea("TRB")
Procregua(reccount())

While !EOF()

Dbselectarea("DA1")
dbgoto(TRB->RECNOX)

	
	incproc('aguarde'+DA1->DA1_FILIAL+' '+DA1->DA1_CODPRO)
	
	Dbselectarea("SB1")
	Dbsetorder(1)
	Dbseek(DA1->DA1_FILIAL+DA1->DA1_CODPRO)

	nVlrCpr := 0
	nPerVds := 0
	nPerMgr := 0
	
	Pergunte("MTC010", .F. )
	
	nVlrCpr := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)
	nPerVds := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
	nPerMgr := MaPrcPlan(DA1->DA1_CODPRO,"SLA_AGR","PERC_REF_MARGEM",0)  //PORCENTUAL MARGEM CONTRIBUICAO (j)
	
	//cmens:='nVlrCpr '+alltrim(str(nVlrCpr,2))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
	//cmens+='nPervds '+alltrim(str(nPervds,2))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
	//cmens+='nPerMgr '+alltrim(str(nPerMgr,2))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
	//MSGalert(cmens)
	
	Dbselectarea("DA1")
	Reclock("DA1",.F.)
	DA1->DA1_ZCSTCO   :=nVlrCpr
	DA1->DA1_ZPVEND   :=nPerVds
	DA1->DA1_ZPMARG   :=nPerMGR
	msunlock()

	Dbselectarea("TRB")
	Dbskip()
ENDDO
Return
