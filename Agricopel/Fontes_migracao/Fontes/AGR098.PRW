#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR098()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

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
±±³Programa     ³ AGR098           ³ Responsavel ³ Deco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Altera Agencia de determinado banco e conta corrente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data        ³ 12.01.04         ³ Implantacao ³                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Deco                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Objetivos   ³ Altera Agencia de determinado banco e conta corrente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Arquivos    ³ SA6                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ mv_par01                                                ³±±
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
cDesc1   := "Este programa Altera Agencia de determinado banco/conta corrente"
cDesc2   := "AGRICOPEL"
cDesc3   := ""
cString  := "SA6"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR098"
nLastKey := 0
cPerg    := "AGR098"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := "AGENCIA"
cabec2   := ""
wnrel    := "AGR098"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1 - PAR¶METROS                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR098","01","Agencia Antiga     ?","mv_ch1","C",05,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR098","02","Nova Agencia       ?","mv_ch2","C",05,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR098","03","Conta Corrente     ?","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR098","04","Conta Corrente     ?","mv_ch4","C",10,0,0,"G","","mv_par04","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR098","05","Conta Corrente     ?","mv_ch5","C",10,0,0,"G","","mv_par05","","","","","","","","","","","","","","","",""})
*
* Cria perguntas
*
TBVSX108("AGR098",aRegistros)

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
//³ mv_par01             // Debito-Credito                                          ³
//³ mv_par02             // Data de                                                 ³ 
//³ mv_par03             // Data ate                                                ³
//³ mv_par04             // Conta contabil                                          ³
//³ mv_par05             // Novo Centro Custo                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Altera Altera Agencia de determinado banco/conta corrente"
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
//SA6->(DbSetOrder(2))               // filial



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*
* Altera Agencia de determinado banco/conta corrente SA6
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SA6")
IndRegua("SA6",cArq,"A6_NUMCON",,,"Selecionando registros...")
*
DbSelectArea("SA6")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SA6->A6_AGENCIA <> MV_PAR01 
      DbSelectArea("SA6")
      SA6->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SA6->A6_NUMCON)
      DbSelectArea("SA6")
      SA6->(DbSkip())
      loop
   ENDIF
   IF SA6->A6_NUMCON == MV_PAR03 .OR.;
      SA6->A6_NUMCON == MV_PAR04 .OR.;
      SA6->A6_NUMCON == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SA6",.F.)                
      SA6->A6_AGENCIA := MV_PAR02
      Msunlock("SA6")
      *
   EndIF
   DbSelectArea("SA6")
   SA6->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SE8
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SE8")
IndRegua("SE8",cArq,"E8_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SE8")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SE8->E8_AGENCIA <> MV_PAR01 
      DbSelectArea("SE8")
      SE8->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SE8->E8_CONTA)
      DbSelectArea("SE8")
      SE8->(DbSkip())
      loop
   ENDIF
   IF SE8->E8_CONTA == MV_PAR03 .OR.;
      SE8->E8_CONTA == MV_PAR04 .OR.;
      SE8->E8_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SE8",.F.)                
      SE8->E8_AGENCIA := MV_PAR02
      Msunlock("SE8")
      *
   EndIF
   DbSelectArea("SE8")
   SE8->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SE1
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SE1")
IndRegua("SE1",cArq,"E1_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SE1")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SE1->E1_AGEDEP <> MV_PAR01 
      DbSelectArea("SE1")
      SE1->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SE1->E1_CONTA)
      DbSelectArea("SE1")
      SE1->(DbSkip())
      loop
   ENDIF
   IF SE1->E1_CONTA == MV_PAR03 .OR.;
      SE1->E1_CONTA == MV_PAR04 .OR.;
      SE1->E1_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SE1",.F.)                
      SE1->E1_AGEDEP := MV_PAR02
      Msunlock("SE1")
      *
   EndIF
   DbSelectArea("SE1")
   SE1->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SE5
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SE5")
IndRegua("SE5",cArq,"E5_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SE5")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SE5->E5_AGENCIA <> MV_PAR01 
      DbSelectArea("SE5")
      SE5->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SE5->E5_CONTA)
      DbSelectArea("SE5")
      SE5->(DbSkip())
      loop
   ENDIF
   IF SE5->E5_CONTA == MV_PAR03 .OR.;
      SE5->E5_CONTA == MV_PAR04 .OR.;
      SE5->E5_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SE5",.F.)                
      SE5->E5_AGENCIA := MV_PAR02
      Msunlock("SE5")
      *
   EndIF
   DbSelectArea("SE5")
   SE5->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SE9
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SE9")
IndRegua("SE9",cArq,"E9_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SE9")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SE9->E9_AGENCIA <> MV_PAR01 
      DbSelectArea("SE9")
      SE9->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SE9->E9_CONTA)
      DbSelectArea("SE9")
      SE9->(DbSkip())
      loop
   ENDIF
   IF SE9->E9_CONTA == MV_PAR03 .OR.;
      SE9->E9_CONTA == MV_PAR04 .OR.;
      SE9->E9_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SE9",.F.)                
      SE9->E9_AGENCIA := MV_PAR02
      Msunlock("SE9")
      *
   EndIF
   DbSelectArea("SE9")
   SE9->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SEA
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SEA")
IndRegua("SEA",cArq,"EA_NUM",,,"Selecionando registros...")
*
DbSelectArea("SEA")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SEA->EA_AGEDEP <> MV_PAR01 
      DbSelectArea("SEA")
      SEA->(DbSkip())
      loop
   ENDIF
   *
   * Altera para Novo codigo da agencia
   *
   Reclock("SEA",.F.)                
   SEA->EA_AGEDEP := MV_PAR02
   Msunlock("SEA")
   *
   DbSelectArea("SEA")
   SEA->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SEE
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SEE")
IndRegua("SEE",cArq,"EE_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SEE")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SEE->EE_AGENCIA <> MV_PAR01 
      DbSelectArea("SEE")
      SEE->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SEE->EE_CONTA)
      DbSelectArea("SEE")
      SEE->(DbSkip())
      loop
   ENDIF
   IF SEE->EE_CONTA == MV_PAR03 .OR.;
      SEE->EE_CONTA == MV_PAR04 .OR.;
      SEE->EE_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SEE",.F.)                
      SEE->EE_AGENCIA := MV_PAR02
      Msunlock("SEE")
      *
   EndIF
   DbSelectArea("SEE")
   SEE->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SEF
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SEF")
IndRegua("SEF",cArq,"EF_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SEF")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SEF->EF_AGENCIA <> MV_PAR01 
      DbSelectArea("SEF")
      SEF->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SEF->EF_CONTA)
      DbSelectArea("SEF")
      SEF->(DbSkip())
      loop
   ENDIF
   IF SEF->EF_CONTA == MV_PAR03 .OR.;
      SEF->EF_CONTA == MV_PAR04 .OR.;
      SEF->EF_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SEF",.F.)                
      SEF->EF_AGENCIA := MV_PAR02
      Msunlock("SEF")
      *
   EndIF
   DbSelectArea("SEF")
   SEF->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SEG
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SEG")
IndRegua("SEG",cArq,"EG_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SEG")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SEG->EG_AGENCIA <> MV_PAR01 
      DbSelectArea("SEG")
      SEG->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SEG->EG_CONTA)
      DbSelectArea("SEG")
      SEG->(DbSkip())
      loop
   ENDIF
   IF SEG->EG_CONTA == MV_PAR03 .OR.;
      SEG->EG_CONTA == MV_PAR04 .OR.;
      SEG->EG_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SEG",.F.)                
      SEG->EG_AGENCIA := MV_PAR02
      Msunlock("SEG")
      *
   EndIF
   DbSelectArea("SEG")
   SEG->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SEH
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SEH")
IndRegua("SEH",cArq,"EH_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SEH")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SEH->EH_AGENCIA <> MV_PAR01 
      DbSelectArea("SEH")
      SEH->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SEH->EH_CONTA)
      DbSelectArea("SEH")
      SEH->(DbSkip())
      loop
   ENDIF
   IF SEH->EH_CONTA == MV_PAR03 .OR.;
      SEH->EH_CONTA == MV_PAR04 .OR.;
      SEH->EH_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SEH",.F.)                
      SEH->EH_AGENCIA := MV_PAR02
      Msunlock("SEH")
      *
   EndIF
   DbSelectArea("SEH")
   SEH->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SEI
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SEI")
IndRegua("SEI",cArq,"EI_CONTA",,,"Selecionando registros...")
*
DbSelectArea("SEI")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SEI->EI_AGENCIA <> MV_PAR01 
      DbSelectArea("SEI")
      SEI->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SEI->EI_CONTA)
      DbSelectArea("SEI")
      SEI->(DbSkip())
      loop
   ENDIF
   IF SEI->EI_CONTA == MV_PAR03 .OR.;
      SEI->EI_CONTA == MV_PAR04 .OR.;
      SEI->EI_CONTA == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SEI",.F.)                
      SEI->EI_AGENCIA := MV_PAR02
      Msunlock("SEI")
      *
   EndIF
   DbSelectArea("SEI")
   SEI->(DbSkip())
END
*
* Altera Agencia de determinado banco/conta corrente SET
*
cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("SET")
IndRegua("SET",cArq,"ET_CTABCO",,,"Selecionando registros...")
*
DbSelectArea("SET")
DbGotop()
SetRegua(RecCount())		
While !Eof() 
   IF SET->ET_AGEBCO <> MV_PAR01 
      DbSelectArea("SET")
      SET->(DbSkip())
      loop
   ENDIF
   IF EMPTY(SET->ET_CTABCO)
      DbSelectArea("SET")
      SET->(DbSkip())
      loop
   ENDIF
   IF SET->ET_CTABCO == MV_PAR03 .OR.;
      SET->ET_CTABCO == MV_PAR04 .OR.;
      SET->ET_CTABCO == MV_PAR05
      *
      * Altera para Novo codigo da agencia
      *
      Reclock("SET",.F.)                
      SET->ET_AGEBCO := MV_PAR02
      Msunlock("SET")
      *
   EndIF
   DbSelectArea("SET")
   SET->(DbSkip())
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
//dele file AGR0981.IDX
//dele file AGR0981.CDX

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
