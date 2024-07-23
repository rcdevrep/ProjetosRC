#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR096()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1,CSAVSCR1,CBTXT")
SetPrvt("CBCONT,CABEC1,CABEC2,CABEC3,WNREL,NORDEM")
SetPrvt("TAMANHO,LIMITE,CDESC1,CDESC2,CDESC3,CSTRING")
SetPrvt("ARETURN,NOMEPROG,NLASTKEY,CPERG,CBTEXT,XGRUPO")
SetPrvt("NQUANT,NVAL,NTQUAN,NTVAL,NLIN,NDESCRI")
SetPrvt("ACQUANT,ACVAL,XCLI,XLOJA,NTOTCLI,NTOTVAL")
SetPrvt("GRAVOU,T500,T900,T1599,T3599,TV500")
SetPrvt("TV900,TV1599,TV3599,T999,TV999,TA999")
SetPrvt("TAV999,ASVALIAS,AREGISTROS,I,J,M_PAG")
SetPrvt("LI,CNOME,TITULO,AORD,CCOD,CTIPO")
SetPrvt("ASTRU,CARQ,XVEND1,CTIPGRU,CGRUPO,CDESC,CDESCGRU,CDESCG")
SetPrvt("NQUANT,NPRCVEN,NTOTAL,NVALICM,NCUSTO1,NRENTAB,NITENS")
SetPrvt("NQUANTG,NPRCVENG,NTOTALG,NVALICMG,NCUSTO1G,NRENTABG,NITENSG")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/09/00 ==> #DEFINE PSAY SAY
#ENDIF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Cliente      ³ AGRICOPEL                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa     ³ AGR096           ³ Responsavel ³ Deco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Demonstrativo de Mercadorias Vendidas por Item          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data        ³ 02.12.03         ³ Implantacao ³                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Deco                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Objetivos   ³ Relatorio de Demonst. Mercadorias Vendidas por Item     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Arquivos    ³ SC6  SC5  SB1 SF4 SX5 SA1                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Indices     ³ SC6(3) SC5(2) SB1(1) SF4(1) SX5(1) SA1(1)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ mv_par01-data  de  mv_par02-data  ate                   ³±±
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
tamanho  := "G"
limite   := 220
cDesc1   := "Este programa ira emitir DEMONST. MERCADORIAS VENDIDAS POR ITEM"
cDesc2   := "AGRICOPEL"
cDesc3   := ""
cString  := "SD2"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR096"
nLastKey := 0
cPerg    := "AGR096"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := "Grupo                                              Quant.         Vlr. Unit.     Vlr. Total     Vlr. ICMS      Custo Uni.     Custo Total      Resultado Oper.     Rentab."
wnrel    := "AGR096"

gravou   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NO SX1 - PAR¶METROS                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR096","01","Data de            ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR096","02","Data ate           ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR096","03","Produto de         ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SB1",""})
AADD(aRegistros,{"AGR096","04","Produto ate        ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SB1",""})
*
* Cria as perguntas para a versao 5.08
*
TBVSX108("AGR096",aRegistros)

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
cNOME    := SPACE(30)
NQUANT   := 0
NPRCVEN  := 0
NTOTAL   := 0
NVALICM  := 0
NCUSTO1  := 0
NRENTAB  := 0
NQUANTG  := 0
NPRCVENG := 0
NTOTALG  := 0
NVALICMG := 0
NCUSTO1G := 0
NRENTABG := 0
NITENS   := 0
NITENSG  := 0
CGRUPO   := SPACE(4)
CDESC    := SPACE(30)
CDESCGRU := SPACE(30)
CDESCG   := SPACE(30)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas, busca o padrao da PRE-NOTA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                            ³
//³ mv_par01             // Da Data                                                 ³
//³ mv_par02             // Ate a Data                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Demonstrativo Custo Mercadoria Vendida por Item "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aOrd :={"Numero","Razao soc. Fornec."}
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

If LastKey() == 27 .or. nLastKey == 27
//   RestScreen(3,0,24,79,cSavScr1)
   Return
Endif
SetDefault(aReturn,cString)
If LastKey() == 27 .OR. nLastKey == 27
//   RestScreen(3,0,24,79,cSavScr1)
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
CCOD  := SPACE(7)
CNOME := SPACE(30)
CTIPO := SPACE(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao de Chaves para os arquivos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SD2->(DbSetOrder(5))               // filial+dtos(emissao)+numseq
SBM->(DbSetOrder(1))               // filial+grupo
SB9->(DbSetOrder(1))               // filial+cod+local+dtos(data)
SB2->(DbSetOrder(1))               // filial+cod+local
SB1->(DbSetOrder(1))               // filial+cod
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru:={}
aadd(aStru,{'GRUPO','C',04,0})
aadd(aStru,{'DESCG','C',30,0})
aadd(aStru,{'COD','C',15,0})
aadd(aStru,{'DESC','C',30,0})
aadd(aStru,{'QUANT','N',14,2})
aadd(aStru,{'PRCVEN','N',14,3})
aadd(aStru,{'TOTAL','N',14,2})
aadd(aStru,{'VALICM','N',14,2})
aadd(aStru,{'CUSTO1','N',14,3})
aadd(aStru,{'RENTAB','N',14,5})
cArq :=CriaTrab(aStru,.t.)
use &cArq alias AGR096 new
Index on GRUPO+COD to AGR0961
*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Geracao do Arquivo de Trabalho                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SELE SD2
dbgotop()
setregua(SD2->(reccount()))
DbSeek(xFilial("SD2") + dtos(mv_par01),.T.)
While !SD2->(eof()) .AND. SD2->D2_emissao >= mv_par01 .and. ;
                          SD2->D2_emissao <= mv_par02
   IF LastKey()==286
      Exit
   Endif
   IF SD2->D2_emissao < mv_par01 .or. SD2->D2_emissao > mv_par02
      SELE SD2
      incregua()
      dbskip()
      loop
   ENDIF
   IF SD2->D2_COD < mv_par03 .or. SD2->D2_COD > mv_par04
      SELE SD2
      incregua()
      dbskip()
      loop
   ENDIF
   SELE SBM
   if !DbSeek(xFilial("SBM")+SD2->D2_GRUPO)
      sele SD2
      incregua()
      dbskip()
      loop
   ENDIF
   SELE SB1
   if !DbSeek(xFilial("SB1")+SD2->D2_COD)
      sele SD2
      incregua()
      dbskip()
      loop
   ENDIF
   *
   * Busca custo medio produto
   *
   NCUSTO1 := 0
   SELE SB9
   dbgotop()
   DbSeek(xFilial("SB9")+SD2->D2_COD+SD2->D2_LOCAL,.T.)
   While !SB9->(eof()) .AND. SB9->B9_COD   == SD2->D2_COD .and. ;
                             SB9->B9_LOCAL == SD2->D2_LOCAL
      IF month(SB9->B9_DATA) == month(SB9->B9_DATA) .and.;
         year(SB9->B9_DATA)  == year(SB9->B9_DATA)
         NCUSTO1 := (SB9->B9_VINI1 / SB9->B9_QINI)
      ENDIF
      dbskip()
      loop
   END
   IF NCUSTO1 == 0
      SELE SB2
      dbgotop()
      DbSeek(xFilial("SB2")+SD2->D2_COD+SD2->D2_LOCAL,.T.)
      While !SB2->(eof()) .AND. SB2->B2_COD   == SD2->D2_COD .and. ;
                                SB2->B2_LOCAL == SD2->D2_LOCAL
         NCUSTO1 := (SB2->B2_VATU1 / SB2->B2_QATU)
         dbskip()
         loop
      END
   ENDIF
   SELE SD2
   SELE AGR096
   If !DbSeek(SD2->D2_GRUPO+SD2->D2_COD)
      AGR096->(dbappend())
      AGR096->GRUPO   := SD2->D2_grupo
      AGR096->DESCG   := SBM->BM_DESC
      AGR096->COD     := SD2->D2_COD
      AGR096->DESC    := SB1->B1_DESC
      AGR096->QUANT   := SD2->D2_QUANT
      AGR096->PRCVEN  := SD2->D2_PRCVEN
      AGR096->TOTAL   := SD2->D2_TOTAL
      AGR096->VALICM  := SD2->D2_VALICM
      AGR096->CUSTO1  := NCUSTO1
      AGR096->RENTAB  := SD2->D2_RENTAB
      MSUNLOCK('AGR096')
   Else
     	RecLock("AGR096",.F.)
      AGR096->QUANT   := AGR096->QUANT  + SD2->D2_QUANT
      AGR096->PRCVEN  := (AGR096->PRCVEN + SD2->D2_PRCVEN) / 2
      AGR096->TOTAL   := AGR096->TOTAL  + SD2->D2_TOTAL
      AGR096->VALICM  := AGR096->VALICM + SD2->D2_VALICM
      AGR096->CUSTO1  := (AGR096->CUSTO1 + NCUSTO1) / 2
      AGR096->RENTAB  := (AGR096->RENTAB + SD2->D2_RENTAB) / 2
      MSUNLOCK('AGR096')
   EndIf
   gravou := 1
   sele SD2
   incregua()
   dbskip()
END
SELE AGR096
setregua(AGR096->(reccount()))
dbgotop()
if LI >= 60
   LI := 0
   LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
   li := li + 1
endif
if gravou == 1
   NCUSTO1 := 0
   CGRUPO  := AGR096->GRUPO
   CDESCG  := AGR096->DESCG
   IF SUBSTR(AGR096->GRUPO,1,1) == '1'
      CDESCGRU := 'COMBUSTIVEIS.......................'
   ENDIF   
   IF SUBSTR(AGR096->GRUPO,1,1) == '2'
      CDESCGRU := 'LUBRIFICANTES......................'
   ENDIF   
   IF SUBSTR(AGR096->GRUPO,1,1) == '3'
      CDESCGRU := 'PECAS E ACESSORIOS AUTOMOTIVOS.....'
   ENDIF   
   IF SUBSTR(AGR096->GRUPO,1,1) == '4'
      CDESCGRU := 'MATERIAIS DE CONSUMO OPERACIONAL...'
   ENDIF   
   @ LI,00 PSAY 'Grupo: ' + SUBSTR(AGR096->GRUPO,1,1) + '  ' + CDESCGRU
   Li := li + 2
   if LI >= 60
      LI := 0
      LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
      li := li + 1
   endif
   @ LI,00 PSAY 'Subgrupo: ' + ALLTRIM(AGR096->GRUPO) + '  ' + AGR096->DESCG
endif
While !EOF()
   if AGR096->GRUPO <> CGRUPO
      Li := li + 1
      if LI >= 60
         LI := 0
         LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
         li := li + 1
      endif
      @ LI,000 PSAY 'Total do Subgrupo...................: '
      @ LI,045 PSAY TRANSF(NQUANT,'@E 999,999,999.99') 
      @ LI,063 PSAY TRANSF((NPRCVEN/NITENS),'@E 999,999.999')
      @ LI,075 PSAY TRANSF(NTOTAL,'@E 999,999,999.99')
      @ LI,090 PSAY TRANSF(NVALICM,'@E 999,999,999.99')
      @ LI,107 PSAY TRANSF((NCUSTO1/NITENS),'@E 999,999.999')
      @ LI,120 PSAY TRANSF(((NCUSTO1/NITENS)*NQUANT),'@E 999,999,999.99')
      @ LI,140 PSAY TRANSF((NTOTAL-((NCUSTO1/NITENS)*NQUANT)),'@E 999,999,999.99')
      @ LI,155 PSAY TRANSF((NRENTAB/NITENS),'@E 999,999.99999')
      *
      NQUANTG  := NQUANTG  + NQUANT
      NPRCVENG := NPRCVENG + (NPRCVEN/NITENS)
      NTOTALG  := NTOTALG  + NTOTAL 
      NVALICMG := NVALICMG + NVALICM
      NCUSTO1G := NCUSTO1G + (NCUSTO1/NITENS)
      NRENTABG := NRENTABG + (NRENTAB/NITENS)
      NITENSG  := NITENSG  + 1
      *
      NQUANT  := 0
      NPRCVEN := 0
      NTOTAL  := 0
      NVALICM := 0
      NCUSTO1 := 0
      NRENTAB := 0
      NITENS  := 0
      *
      if SUBSTR(AGR096->GRUPO,1,1) <> SUBSTR(CGRUPO,1,1)
         Li := li + 1
         if LI >= 60
            LI := 0
            LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
            li := li + 1
         endif
         @ LI,00 PSAY 'Total do Grupo....................: '
         @ LI,045 PSAY TRANSF(NQUANTG,'@E 999,999,999.99') 
         @ LI,063 PSAY TRANSF((NPRCVENG/NITENSG),'@E 999,999.999')
         @ LI,075 PSAY TRANSF(NTOTALG,'@E 999,999,999.99')
         @ LI,090 PSAY TRANSF(NVALICMG,'@E 999,999,999.99')
         @ LI,107 PSAY TRANSF((NCUSTO1G/NITENSG),'@E 999,999.999')
         @ LI,120 PSAY TRANSF(((NCUSTO1G/NITENSG)*NQUANTG),'@E 999,999,999.99')
         @ LI,140 PSAY TRANSF((NTOTALG-((NCUSTO1G/NITENSG)*NQUANTG)),'@E 999,999,999.99')
         @ LI,155 PSAY TRANSF((NRENTABG/NITENSG),'@E 999,999.99999')
         *
         NQUANTG  := 0
         NPRCVENG := 0
         NTOTALG  := 0
         NVALICMG := 0
         NCUSTO1G := 0
         NRENTABG := 0
         NITENSG  := 0
         *
         LI := LI + 2
         if LI >= 60
            LI := 0
            LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
            li := li + 1
         endif
         IF SUBSTR(AGR096->GRUPO,1,1) == '1'
            CDESCGRU := 'COMBUSTIVEIS.......................'
         ENDIF   
         IF SUBSTR(AGR096->GRUPO,1,1) == '2'
            CDESCGRU := 'LUBRIFICANTES......................'
         ENDIF   
         IF SUBSTR(AGR096->GRUPO,1,1) == '3'
            CDESCGRU := 'PECAS E ACESSORIOS AUTOMOTIVOS.....'
         ENDIF   
         IF SUBSTR(AGR096->GRUPO,1,1) == '4'
            CDESCGRU := 'MATERIAIS DE CONSUMO OPERACIONAL...'
         ENDIF   
         @ LI,00 PSAY 'Grupo: ' + SUBSTR(AGR096->GRUPO,1,1) + '  ' + CDESCGRU
         *
      EndIf
      LI := LI + 2
      if LI >= 60
         LI := 0
         LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
         li := li + 1
      endif
      @ LI,00 PSAY 'Subgrupo: ' + ALLTRIM(AGR096->GRUPO) + '  ' + AGR096->DESCG
      CGRUPO  := AGR096->GRUPO
      CDESCG  := AGR096->DESCG
   EndIf
   *
   LI := LI + 1
   if LI >= 60
      LI := 0
      LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
      li := li + 1
   endif
   @ LI,000 PSAY ALLTRIM(AGR096->COD)
   @ LI,010 PSAY ALLTRIM(AGR096->DESC)
   @ LI,045 PSAY TRANSF(AGR096->QUANT,'@E 999,999,999.99') 
   @ LI,063 PSAY TRANSF(AGR096->PRCVEN,'@E 999,999.999')
   @ LI,075 PSAY TRANSF(AGR096->TOTAL,'@E 999,999,999.99')
   @ LI,090 PSAY TRANSF(AGR096->VALICM,'@E 999,999,999.99')
   @ LI,107 PSAY TRANSF(AGR096->CUSTO1,'@E 999,999.999')
   @ LI,120 PSAY TRANSF((AGR096->CUSTO1*AGR096->QUANT),'@E 999,999,999.99')
   @ LI,140 PSAY TRANSF((AGR096->TOTAL-(AGR096->CUSTO1*AGR096->QUANT)),'@E 999,999,999.99')
   @ LI,155 PSAY TRANSF(AGR096->RENTAB,'@E 999,999.99999')
   *
   NQUANT  := NQUANT   + AGR096->QUANT
   NPRCVEN := NPRCVEN  + AGR096->PRCVEN
   NTOTAL  := NTOTAL   + AGR096->TOTAL
   NVALICM := NVALICM  + AGR096->VALICM
   NCUSTO1 := NCUSTO1  + AGR096->CUSTO1
   NRENTAB := NRENTAB  + AGR096->RENTAB
   NITENS  := NITENS   + 1
   *
   SELE AGR096
   incregua()
   dbskip()
   loop
END
LI := LI + 1
if LI >= 60
   LI := 0
   LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
   li := li + 1
endif
@ LI,000 PSAY 'Total do Subgrupo...................: '
@ LI,045 PSAY TRANSF(NQUANT,'@E 999,999,999.99') 
@ LI,063 PSAY TRANSF((NPRCVEN/NITENS),'@E 999,999.999')
@ LI,075 PSAY TRANSF(NTOTAL,'@E 999,999,999.99')
@ LI,090 PSAY TRANSF(NVALICM,'@E 999,999,999.99')
@ LI,107 PSAY TRANSF((NCUSTO1/NITENS),'@E 999,999.999')
@ LI,120 PSAY TRANSF(((NCUSTO1/NITENS)*NQUANT),'@E 999,999,999.99')
@ LI,140 PSAY TRANSF((NTOTAL-((NCUSTO1/NITENS)*NQUANT)),'@E 999,999,999.99')
@ LI,155 PSAY TRANSF((NRENTAB/NITENS),'@E 999,999.99999')
*
NQUANTG  := NQUANTG  + NQUANT
NPRCVENG := NPRCVENG + (NPRCVEN/NITENS)
NTOTALG  := NTOTALG  + NTOTAL 
NVALICMG := NVALICMG + NVALICM
NCUSTO1G := NCUSTO1G + (NCUSTO1/NITENS)
NRENTABG := NRENTABG + (NRENTAB/NITENS)
NITENSG  := NITENSG  + 1
*
LI := LI + 1
if LI >= 60
   LI := 0
   LI := cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
   li := li + 1
endif
@ LI,00 PSAY 'Total do Grupo....................: '
@ LI,045 PSAY TRANSF(NQUANTG,'@E 999,999,999.99') 
@ LI,063 PSAY TRANSF((NPRCVENG/NITENSG),'@E 999,999.999')
@ LI,075 PSAY TRANSF(NTOTALG,'@E 999,999,999.99')
@ LI,090 PSAY TRANSF(NVALICMG,'@E 999,999,999.99')
@ LI,107 PSAY TRANSF((NCUSTO1G/NITENSG),'@E 999,999.999')
@ LI,120 PSAY TRANSF(((NCUSTO1G/NITENSG)*NQUANTG),'@E 999,999,999.99')
@ LI,140 PSAY TRANSF((NTOTALG-((NCUSTO1G/NITENSG)*NQUANTG)),'@E 999,999,999.99')
@ LI,155 PSAY TRANSF((NRENTABG/NITENSG),'@E 999,999.99999')
*
IF LI != 80
   RODA(cBCONT,cBTXT,"P")
ENDIF
SELE AGR096
USE

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



