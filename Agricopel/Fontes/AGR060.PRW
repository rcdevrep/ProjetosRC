#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
//#IFNDEF WINDOWS
//#DEFINE PSAY SAY
//#ENDIF

User Function AGR060()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
SetPrvt("NPARC,NVALOR,CDATA,NVLCRE,NVLMES,NVLAPRO")


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿎liente      � Agricopel                                               낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rograma     � AGR060           � Responsavel � Deco                   낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escri뇙o    � Lista Relatorio Resumo das Fichas CIAP                  낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Data        � 04.08.03         � Implantacao �                        낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Programador � Deco                                                    낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Objetivos   � Listar Relatorio Resumo das Fichas CIAP                 낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Arquivos    � SF9  SFA                                                낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Parametros  � mv_par01-dias                                           낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Observacoes �                                                         낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Cuidados na �                                                         낢�
굇� Atualizacao �                                                         낢�
굇� de versao   �                                                         낢�
굇읕컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cSavCur1 := "";cSavRow1:="";cSavCol1:="";cSavCor1:="";cSavScr1:="";CbTxt:=""
CbCont   := "";cabec1:="";cabec2:="";cabec3:="";wnrel:=""
nOrdem   := 0
tamanho  := "M"
limite   := 132
cDesc1   := "Este programa ira emitir Relatorio Resumo das fichas CIAP"
cDesc2   := "AGRICOPEL"
cDesc3   := ""
cString  := "SF9"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR060"
nLastKey := 0
cPerg    := "AGR060"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := "                                                                                   Apropriacao   -------- Apropriado ----------   "
cabec2   := "codigo  Aquisicao   NF        Descricao Reduzida                 Valor Credito             Mes   Parcela                Valor     "
wnrel    := "AGR060"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� AJUSTE NO SX1 - PAR턒ETROS                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR060","01","Data de           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR060","02","Data ate          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
*
* Cria perguntas
*
U_CriaPer("AGR060",aRegistros)

dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� FIM DO AJUSTE                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
m_pag    := 1
LI       := 80 
cNOME    := SPACE(30)
CHIST    := SPACE(40)
NPARC    := 0
NVALOR   := 0
NVLCRE   := 0
NVLMES   := 0
NVLAPRO  := 0
CDATA    := SPACE(10)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifica as perguntas selecionadas, busca o padrao da PRE-NOTA�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
pergunte(cPerg,.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Variaveis utilizadas para parametros                                            �
//� mv_par01             // Do Grupo                                                �
//� mv_par02             // Ate o Grupo                                             � 
//� mv_par03             // Da Data                                                 �
//� mv_par04             // Ate a Data                                              �
//� mv_par05             // Do Cliente                                              �
//� mv_par06             // Ate o Cliente                                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
titulo := "Relatorio Resumo das Fichas CIAP"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
//#IFDEF WINDOWS
  RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   RptStatus({|| Execute(RptDetail)})
  Return
  // Funcao Linha Detalhe do Relatorio
// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   Function RptDetail
Static Function RptDetail()
//#ENDIF

//nOrdem:=aReturn[8]
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞elecao de Chaves para os arquivos                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SF9->(DbSetOrder(1))               // filial+codigo
SFA->(DbSetOrder(1))               // filial+codigo+data+tipo

//cArq :=CriaTrab(NIL,.F.)
//dbSELECTAREA("CT2")
//IndRegua("CT2",cArq,"CT2_FILORI+DTOS(CT2_DATA)",,,"Selecionando registros...")

//cArq :=CriaTrab(NIL,.F.)
//dbSELECTAREA("SF2")
//IndRegua("SF2",cArq,"F2_FILIAL+DTOS(F2_DTDIGIT)",,,"Selecionando registros...")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Declaracoes de arrays                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*
* Busca Bens e apropriacao
*
DbSelectArea("SF9")
DbGotop()
SetRegua(RecCount())		
DbSeek(xFilial("SF9"),.T.)
While !Eof("SF9") .AND. SF9->F9_FILIAL  == xFilial("SF9") 
   Sele SFA
   DbGotop()
   DbSeek(xFilial("SFA")+SF9->F9_CODIGO,.T.)
   While !Eof("SFA") .AND. SFA->FA_FILIAL  == xFilial("SFA");
                     .AND. SFA->FA_CODIGO  == SF9->F9_CODIGO;
                     

      IF SFA->FA_DATA <= MV_PAR02
         NPARC  := NPARC + 1
         NVALOR := NVALOR + SFA->FA_VALOR
      ENDIF
      IF SFA->FA_DATA == MV_PAR02
 	      *
	      *  Lista o Bem
         *       
         IF li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            li := li + 2
         ENDIF
         
         CDATA := STRZERO(DAY(SF9->F9_DTENTNE),2)+'/'+STRZERO(MONTH(SF9->F9_DTENTNE),2)+'/'+STRZERO(YEAR(SF9->F9_DTENTNE),4)            
         @ li,000 PSAY SF9->F9_CODIGO
		 @ li,008 PSAY CDATA
		 @ li,020 PSAY SF9->F9_DOCNFE
		 @ li,030 PSAY ALLTRIM(Substr(SF9->F9_DESCRI, 1, 30))
		 @ LI,065 PSAY TRANSFORM(SF9->F9_VALICMS,'@E 999,999,999.99')
		 @ LI,080 PSAY TRANSFORM(SFA->FA_VALOR,'@E 999,999,999.99')
		 @ li,105 PSAY TRANSFORM(NPARC,'@E 9999')
		 @ li,110 PSAY TRANSFORM(NVALOR,'@E 999,999,999.99')
		 
	     NVLCRE  := NVLCRE + SF9->F9_VALICMS
	     NVLMES  := NVLMES + SFA->FA_VALOR
	     NVLAPRO := NVLAPRO + NVALOR
  	     li := li + 1
  	     
         IF li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            li := li + 2                       
         ENDIF
         EXIT
      ENDIF
      DbSelectArea("SFA")
      SFA->(DbSkip())
   END
   NPARC  := 0
   NVALOR := 0
   DbSelectArea("SF9")
   SF9->(DbSkip())
End
li := li + 2
IF li > 60
   cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
   li := li + 2
ENDIF       
@ LI,030 PSAY 'Total.........:'
@ LI,065 PSAY TRANSFORM(NVLCRE,'@E 999,999,999.99')
@ LI,080 PSAY TRANSFORM(NVLMES,'@E 999,999,999.99')
@ li,110 PSAY TRANSFORM(NVLAPRO,'@E 999,999,999.99')

//IF LI!=80
//   RODA(cBCONT,cBTXT,"P")
//ENDIF

set device to screen
cEmp := sm0->m0_codigo
dbcloseall()
OpenFile(cEmp)
set device to print
*
//dele file AGR0601.IDX
//dele file AGR0601.CDX

Set Device To Screen
//RestScreen(3,0,24,79,cSavScr1)

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
   Set Printer TO 
   dbcommitAll()
   ourspool(wnrel)
Endif
