#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#INCLUDE "TOPCONN.CH"  

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR128()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1,CSAVSCR1,CBTXT")
SetPrvt("CBCONT,CABEC1,CABEC2,CABEC3,WNREL,NORDEM,CACHOU")
SetPrvt("TAMANHO,LIMITE,CDESC1,CDESC2,CDESC3,CSTRING")
SetPrvt("ARETURN,NOMEPROG,NLASTKEY,CPERG,CBTEXT,XGRUPO")
SetPrvt("NQUANT,NVAL,NTQUAN,NTVAL,NLIN,NDESCRI")
SetPrvt("ACQUANT,ACVAL,XCLI,XLOJA,NTOTCLI,NTOTVAL")
SetPrvt("GRAVOU,T500,T900,T1599,T3599,TV500")
SetPrvt("TV900,TV1599,TV3599,T999,TV999,TA999")
SetPrvt("TAV999,ASVALIAS,AREGISTROS,I,J,M_PAG")
SetPrvt("LI,CNOME,TITULO,AORD,CCOD,CTIPO,CHIST")
SetPrvt("ASTRU,CARQ,XVEND1,VLCOMISS,CVEZ,CMES,CANO,CCLI,CLOJA,NMESES")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/09/00 ==> #DEFINE PSAY SAY
#ENDIF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Cliente      ³ Agricopel                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa     ³ AGR128           ³ Responsavel ³ Deco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Alterar codificacao de Repres.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data        ³ 08.09.04         ³ Implantacao ³                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ DECO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Objetivos   ³ Alterar Codificacao Vendedores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Arquivos    ³ SA1,SA3,SE3,SUA,SC5,SF2,SE1,SU7,SZ8                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cuidados na ³                                                         ³±±
±±³ Atualizacao ³                                                         ³±±
±±³ de versao   ³                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSavCur1 := "";cSavRow1:="";cSavCol1:="";cSavCor1:="";cSavScr1:="";CbTxt:=""
CbCont   := "";cabec1:="";cabec2:="";cabec3:="";wnrel:=""
nOrdem   := 0
tamanho  := "M"
limite   := 132
cDesc1   := "Este programa ira Recodificar Vendedores"
cDesc2   := "AGRICOPEL"
cDesc3   := ""
cString  := "SA3"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR128"
nLastKey := 0
cPerg    := "AGR128"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := "FUNCAO"
cabec2   := ""
wnrel    := "AGR128"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1 - PAR¶METROS                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR128","01","Vendedor de  ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA3",""})
AADD(aRegistros,{"AGR128","02","Vendedor Ate ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SA3",""})
*
* Cria perguntas
*
TBVSX108("AGR128",aRegistros)

dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FIM DO AJUSTE                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag    := 1
LI       := 80 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas, busca o padrao da PRE-NOTA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                            ³
//³ mv_par01             // Vendedor de                                             ³
//³ mv_par02             // Vendedor Ate                                            ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Recodifica Vendedores"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aOrd :={"Numero","Razao soc. Fornec."}
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

If LastKey() == 27 .or. nLastKey == 27
   RestScreen(3,0,24,79,cSavScr1)
   Return
Endif
SetDefault(aReturn,cString)
If LastKey() == 27 .OR. nLastKey == 27
   RestScreen(3,0,24,79,cSavScr1)
   Return
Endif
#IFDEF WINDOWS
  RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   RptStatus({|| Execute(RptDetail)})
  Return
  // Funcao Linha Detalhe do Relatorio
// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   Function RptDetail
Static Function RptDetail()
#ENDIF

//nOrdem:=aReturn[8]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao de Chaves para os arquivos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSetOrder(1))               // filial+cod+loja
SA3->(DbSetOrder(1))               // filial+cod
SE3->(DbSetOrder(1))               // filial+vend+prefixo+num+parcela+seq
SE1->(DbSetOrder(1))               // filial+prefixo+num+parcela+tipo
SU7->(DbSetOrder(1))               // filial+cod
SZ8->(DbSetOrder(1))               // filial+repre+seq
SUA->(DbSetOrder(1))               // filial+num
SC5->(DbSetOrder(1))               // filial+num
SF2->(DbSetOrder(1))               // filial+doc+serie+cliente+form   
SU6->(DbSetOrder(1))               // filial+lista+codigo

//cArq :=CriaTrab(NIL,.F.)
//dbSELECTAREA("SUA")
//IndRegua("SUA",cArq,"UA_VEND",,,"Selecionando registros...")

//cArq :=CriaTrab(NIL,.F.)
//dbSELECTAREA("SC5")
//IndRegua("SC5",cArq,"C5_VEND1",,,"Selecionando registros...")

//cArq :=CriaTrab(NIL,.F.)
//dbSELECTAREA("SF2")
//IndRegua("SF2",cArq,"F2_VEND1",,,"Selecionando registros...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*
* Recodificar Vendedores
*
DbSelectArea("SA3")
DbGotop()
SetRegua(RecCount())		
DbSeek(xFilial("SA3"),.T.)
While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL
   IncRegua()
   If SA3->a3_COD < MV_PAR01 .or.;
      SA3->a3_COD > MV_PAR02   
      DbSkip()
      Loop
   Endif
   If Empty(SA3->a3_CODANT)
      DbSkip()
      Loop
   Endif
   cCod    := SA3->A3_COD
   cCodAnt := SA3->A3_CODANT
   *
   * Recodifica Vendedor no SA1
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SA1")+" "
	cQuery += "WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND A1_VEND = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SA101") <> 0
		dbSelectArea("SA101")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SA101"
	DbSelectArea("SA101")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SA1")
		DbGoto(SA101->nIdRecno)
		RecLock("SA1",.F.)
			SA1->A1_VEND := cCodAnt
		MsUnLock("SA1")
		DbSelectArea("SA101")
	   DbSkip()
	EndDo 
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SA1")+" "
	cQuery += "WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND A1_VEND2 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SA102") <> 0
		dbSelectArea("SA102")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SA102"
	DbSelectArea("SA102")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SA1")
		DbGoto(SA102->nIdRecno)
		RecLock("SA1",.F.)
			SA1->A1_VEND2 := cCodAnt
		MsUnLock("SA1")
		DbSelectArea("SA102")
	   DbSkip()
	EndDo               
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SA1")+" "
	cQuery += "WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND A1_VEND3 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SA103") <> 0
		dbSelectArea("SA103")
		dbCloseArea()
	Endif	
	TCQuery cQuery NEW ALIAS "SA103"
	DbSelectArea("SA103")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SA1")
		DbGoto(SA103->nIdRecno)
		RecLock("SA1",.F.)
			SA1->A1_VEND3 := cCodAnt
		MsUnLock("SA1")
		DbSelectArea("SA103")
	   DbSkip()
	EndDo
   
   *
   * Recodifica Vendedor no SE3
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SE3")+" "
	cQuery += "WHERE E3_FILIAL = '"+xFilial("SE3")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND E3_VEND = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SE301") <> 0
		dbSelectArea("SE301")
		dbCloseArea()
	Endif	
	TCQuery cQuery NEW ALIAS "SE301"
	DbSelectArea("SE301")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SE3")
		DbGoto(SE301->nIdRecno)
		RecLock("SE3",.F.)
			SE3->E3_VEND := cCodAnt
		MsUnLock("SE3")
		DbSelectArea("SE301")
	   DbSkip()
	EndDo
	
   *
   * Recodifica Vendedor no SUA
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SUA")+" "
	cQuery += "WHERE UA_FILIAL = '"+xFilial("SUA")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND UA_VEND = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SUA01") <> 0
		dbSelectArea("SUA01")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SUA01"
	DbSelectArea("SUA01")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SUA")
		DbGoto(SUA01->nIdRecno)
		RecLock("SUA",.F.)
			SUA->UA_VEND := cCodAnt
		MsUnLock("SUA")
		DbSelectArea("SUA01")
	   DbSkip()
	EndDo
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SUA")+" "
	cQuery += "WHERE UA_FILIAL = '"+xFilial("SUA")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND UA_VEND2 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SUA02") <> 0
		dbSelectArea("SUA02")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SUA02"
	DbSelectArea("SUA02")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SUA")
		DbGoto(SUA02->nIdRecno)
		RecLock("SUA",.F.)
			SUA->UA_VEND2 := cCodAnt
		MsUnLock("SUA")
		DbSelectArea("SUA02")
	   DbSkip()
	EndDo               
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SUA")+" "
	cQuery += "WHERE UA_FILIAL = '"+xFilial("SUA")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND UA_VEND3 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SUA03") <> 0
		dbSelectArea("SUA03")
		dbCloseArea()
	Endif	
	TCQuery cQuery NEW ALIAS "SUA03"
	DbSelectArea("SUA03")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SUA")
		DbGoto(SUA03->nIdRecno)
		RecLock("SUA",.F.)
			SUA->UA_VEND3 := cCodAnt
		MsUnLock("SUA")
		DbSelectArea("SUA03")
	   DbSkip()
	EndDo

	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SUA")+" "
	cQuery += "WHERE UA_FILIAL = '"+xFilial("SUA")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND UA_OPERADO = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SUA04") <> 0
		dbSelectArea("SUA04")
		dbCloseArea()
	Endif	
	TCQuery cQuery NEW ALIAS "SUA04"
	DbSelectArea("SUA04")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SUA")
		DbGoto(SUA04->nIdRecno)
		RecLock("SUA",.F.)
			SUA->UA_OPERADO := cCodAnt
		MsUnLock("SUA")
		DbSelectArea("SUA04")
	   DbSkip()
	EndDo
   
   *
   * Recodifica Vendedor no SE1
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SE1")+" "
	cQuery += "WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND E1_VEND1 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SE101") <> 0
		dbSelectArea("SE101")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SE101"
	DbSelectArea("SE101")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SE1")
		DbGoto(SE101->nIdRecno)
		RecLock("SE1",.F.)
			SE1->E1_VEND1 := cCodAnt
		MsUnLock("SE1")
		DbSelectArea("SE101")
	   DbSkip()
	EndDo
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SE1")+" "
	cQuery += "WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND E1_VEND2 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SE102") <> 0
		dbSelectArea("SE102")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SE102"
	DbSelectArea("SE102")
	DbGoTop()
	While !Eof()  
		DbSelectArea("SE1")
		DbGoto(SE102->nIdRecno)
		RecLock("SE1",.F.)
			SE1->E1_VEND2 := cCodAnt
		MsUnLock("SE1")
		DbSelectArea("SE102")
	   DbSkip()
	EndDo               
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SE1")+" "
	cQuery += "WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND E1_VEND3 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SE103") <> 0
		dbSelectArea("SE103")
		dbCloseArea()
	Endif	
	TCQuery cQuery NEW ALIAS "SE103"
	DbSelectArea("SE103")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SE1")
		DbGoto(SE103->nIdRecno)
		RecLock("SE1",.F.)
			SE1->E1_VEND3 := cCodAnt
		MsUnLock("SE1")
		DbSelectArea("SE103")
	   DbSkip()
	EndDo
	
   *
   * Recodifica Vendedor no SC5
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SC5")+" "
	cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND C5_VEND1 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SC501") <> 0
		dbSelectArea("SC501")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SC501"
	DbSelectArea("SC501")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SC5")
		DbGoto(SC501->nIdRecno)
		RecLock("SC5",.F.)
			SC5->C5_VEND1 := cCodAnt
		MsUnLock("SC5")
		DbSelectArea("SC501")
	   DbSkip()
	EndDo
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SC5")+" "
	cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND C5_VEND2 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SC502") <> 0
		dbSelectArea("SC502")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SC502"
	DbSelectArea("SC502")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SC5")
		DbGoto(SC502->nIdRecno)
		RecLock("SC5",.F.)
			SC5->C5_VEND2 := cCodAnt
		MsUnLock("SC5")
		DbSelectArea("SC502")
	   DbSkip()
	EndDo               
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SC5")+" "
	cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND C5_VEND3 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SC503") <> 0
		dbSelectArea("SC503")
		dbCloseArea()
	Endif	
	TCQuery cQuery NEW ALIAS "SC503"
	DbSelectArea("SC503")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SC5")
		DbGoto(SC503->nIdRecno)
		RecLock("SC5",.F.)
			SC5->C5_VEND3 := cCodAnt
		MsUnLock("SC5")
		DbSelectArea("SC503")
	   DbSkip()
	EndDo

   *
   * Recodifica Vendedor no SF2
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SF2")+" "
	cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND F2_VEND1 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SF201") <> 0
		dbSelectArea("SF201")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SF201"
	DbSelectArea("SF201")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SF2")
		DbGoto(SF201->nIdRecno)
		RecLock("SF2",.F.)
			SF2->F2_VEND1 := cCodAnt
		MsUnLock("SF2")
		DbSelectArea("SF201")
	   DbSkip()
	EndDo
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SF2")+" "
	cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND F2_VEND2 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SF202") <> 0
		dbSelectArea("SF202")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SF202"
	DbSelectArea("SF202")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SF2")
		DbGoto(SF202->nIdRecno)
		RecLock("SF2",.F.)
			SF2->F2_VEND2 := cCodAnt
		MsUnLock("SF2")
		DbSelectArea("SF202")
	   DbSkip()
	EndDo               
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SF2")+" "
	cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND F2_VEND3 = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SF203") <> 0
		dbSelectArea("SF203")
		dbCloseArea()
	Endif	
	TCQuery cQuery NEW ALIAS "SF203"
	DbSelectArea("SF203")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SF2")
		DbGoto(SF203->nIdRecno)
		RecLock("SF2",.F.)
			SF2->F2_VEND3 := cCodAnt
		MsUnLock("SF2")
		DbSelectArea("SF203")
	   DbSkip()
	EndDo
	
   *
   * Recodifica Vendedor no SU6
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SU6")+" "
	cQuery += "WHERE U6_FILIAL = '"+xFilial("SU6")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND U6_OPERAD = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SU601") <> 0
		dbSelectArea("SU601")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SU601"
	DbSelectArea("SU601")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SU6")
		DbGoto(SU601->nIdRecno)
		RecLock("SU6",.F.)
			SU6->U6_OPERAD := cCodAnt
		MsUnLock("SU6")
		DbSelectArea("SU601")
	   DbSkip()
	EndDo
	
   *
   * Recodifica Vendedor no SU7
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SU7")+" "
	cQuery += "WHERE U7_FILIAL = '"+xFilial("SU7")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND U7_COD = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SU701") <> 0
		dbSelectArea("SU701")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SU701"
	DbSelectArea("SU701")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SU7")
		DbGoto(SU701->nIdRecno)
		RecLock("SU7",.F.)
			SU7->U7_COD := cCodAnt
		MsUnLock("SU7")
		DbSelectArea("SU701")
	   DbSkip()
	EndDo
	
   *
   * Recodifica Contatos no SU5
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SU5")+" "
	cQuery += "WHERE U5_FILIAL = '"+xFilial("SU5")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND U5_OPERADO = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SU501") <> 0
		dbSelectArea("SU501")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SU501"
	DbSelectArea("SU501")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SU5")
		DbGoto(SU501->nIdRecno)
		RecLock("SU5",.F.)
			SU5->U5_OPERADO := cCodAnt
		MsUnLock("SU5")
		DbSelectArea("SU501")
	   DbSkip()
	EndDo

   *
   * Recodifica Metas no SCT
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SCT")+" "
	cQuery += "WHERE CT_FILIAL = '"+xFilial("SCT")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND CT_VEND = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SCT01") <> 0
		dbSelectArea("SCT01")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SCT01"
	DbSelectArea("SCT01")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SCT")
		DbGoto(SCT01->nIdRecno)
		RecLock("SCT",.F.)
			SCT->CT_VEND := cCodAnt
		MsUnLock("SCT")
		DbSelectArea("SCT01")
	   DbSkip()
	EndDo
	
   *
   * Recodifica Vendedor no SZ8
   *
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
	cQuery += "FROM "+RetSqlName("SZ8")+" "
	cQuery += "WHERE Z8_FILIAL = '"+xFilial("SZ8")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND Z8_REPRE = '"+cCod+"' "
	cQuery := ChangeQuery(cQuery)
	If Select("SZ801") <> 0
		dbSelectArea("SZ801")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "SZ801"
	DbSelectArea("SZ801")
	DbGoTop()               
	While !Eof()  
		DbSelectArea("SZ8")
		DbGoto(SZ801->nIdRecno)
		RecLock("SZ8",.F.)
			SZ8->Z8_REPRE := cCodAnt
		MsUnLock("SZ8")
		DbSelectArea("SZ801")
	   DbSkip()
	EndDo
	
   Sele SA3
   DbSkip()
END

//IF LI!=80
//   RODA(cBCONT,cBTXT,"P")
//ENDIF

set device to screen
cEmp := sm0->m0_codigo
dbcloseall()
OpenFile(cEmp)
set device to print
*
//dele file AGR1281.IDX
//dele file AGR1281.CDX

Set Device To Screen
//RestScreen(3,0,24,79,cSavScr1)

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
   Set Printer TO 
   dbcommitAll()
   ourspool(wnrel)
Endif

Static Function TBVSX108(cGrupo,aPer)
*************************************
LOCAL lRetu := .T.
LOCAL aReg  := {}

dbSelectArea("SX1")
If (FCount() == 41)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
	Next _l
Elseif (FCount() == 26)
	aReg := aPer
Endif

dbSelectArea("SX1")
For _l := 1 to Len(aReg)
	If !dbSeek(cGrupo+StrZero(_l,02,00))
		RecLock("SX1",.T.)
		For _m := 1 to FCount()
			FieldPut(_m,aReg[_l,_m])
		Next _m
		MsUnlock("SX1")
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
		RecLock("SX1",.F.)
		For _k := 1 to FCount()
			FieldPut(_k,aReg[_l,_k])
		Next _k
		MsUnlock("SX1")
	Endif
Next _l

Return lRetu
