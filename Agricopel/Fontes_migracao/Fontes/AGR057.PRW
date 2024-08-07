#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR057()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

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

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/09/00 ==> #DEFINE PSAY SAY
#ENDIF

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿎liente      � Agricopel                                               낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rograma     � AGR057           � Responsavel � Deco                   낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escri뇙o    � Lista nfs fiscal que nao ctb                            낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Data        � 18.07.03         � Implantacao �                        낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Programador � Deco                                                    낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Objetivos   � Listar nfs fiscal nao ctb                               낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Arquivos    � SF2  ct2                                                낢�
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
cDesc1   := "Este programa ira emitir Nfs fiscal nao ctb"
cDesc2   := "AGRICOPEL"
cDesc3   := ""
cString  := "SF2"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR057"
nLastKey := 0
cPerg    := "AGR057"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := "NF"
cabec2   := ""
wnrel    := "AGR057"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� AJUSTE NO SX1 - PAR턒ETROS                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR057","01","Data de           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR057","02","Data ate          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR057","03","1-Entrada/2-Saida ?","mv_ch3","C",01,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
*
* Cria perguntas
*
TBVSX108("AGR057",aRegistros)

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
titulo := "Lista Nfs fiscal nao ctb"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞elecao de Chaves para os arquivos                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SF2->(DbSetOrder(7))               // filial+emissao+cliente
SF1->(DbSetOrder(1))               // filial+doc+serie+fornece+loja+tipo

cArq :=CriaTrab(NIL,.F.)
dbSELECTAREA("CT2")
IndRegua("CT2",cArq,"CT2_FILORI+DTOS(CT2_DATA)",,,"Selecionando registros...")

//cArq :=CriaTrab(NIL,.F.)
//dbSELECTAREA("SF2")
//IndRegua("SF2",cArq,"F2_FILIAL+DTOS(F2_DTDIGIT)",,,"Selecionando registros...")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Declaracoes de arrays                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*
* Verifica Notas de Entrada
*
IF MV_PAR03 == '1'
   DbSelectArea("SF1")
   DbGotop()
   SetRegua(RecCount())		
   DbSeek(xFilial("SF1"),.T.)
   While !Eof() .AND. SF1->F1_FILIAL  == xFilial("SF1")
      IF SF1->F1_EMISSAO < MV_PAR01 .OR.;
         SF1->F1_EMISSAO > MV_PAR02
         DbSelectArea("SF1")
         SF1->(DbSkip())
         loop
      ENDIF
      IF SF1->F1_EMISSAO >= MV_PAR01 .AND.;
         SF1->F1_EMISSAO <= MV_PAR02
  	      If DTOS(SF1->F1_EMISSAO) < DTOS(MV_PAR01) .OR. DTOS(SF1->F1_EMISSAO) > DTOS(MV_PAR02)
		      DbSelectArea("SF1")
   		   SF1->(DbSkip())		
	   	   Loop
	      EndIf
   	   IncRegua()
	      *
	      *  VERIFICA nf esta na contabilidade
   	   *       
	      CACHOU := 'N'
	      DbSelectArea("CT2")
   	   DbGotop()
	      DbSeek(SF1->F1_FILIAL+DTOS(SF1->F1_DTLANC))
	      While !Eof() .And. CT2->CT2_FILORI 	== SF1->F1_FILIAL;
		      			 .And. CT2->CT2_DATA   	<= SF1->F1_DTLANC
   	      CHIST := CT2->CT2_HIST
        	   IF ALLTRIM(SF1->F1_DOC) $ ALLTRIM(CHIST)
     	         CACHOU := 'S'
     	      ENDIF
   		   DbSelectArea("CT2")
	   	   CT2->(DbSkip())
	      End
         IF li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            li := li + 2
         ENDIF
         IF CACHOU == 'N'
	         @ li,010 PSAY SF1->F1_DOC
   	      @ LI,030 PSAY TRANSFORM(SF1->F1_VALBRUT,'@E 999,999,999.99')
   	      @ LI,050 PSAY 'NF ENTRADA'
  	   	   li := li + 1
            IF li > 60
               cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
               li := li + 2
            ENDIF
         ENDIF
      ENDIF
      DbSelectArea("SF1")
      SF1->(DbSkip())
   End
ENDIF
*
* Verifica Notas de Saida
*
IF MV_PAR03 == '2'
   DbSelectArea("SF2")
   //DbSetOrder(1)
   //SELE SF2
   DbGotop()
   SetRegua(RecCount())		
   DbSeek(xFilial("SF2")+DTOS(MV_PAR01),.T.)
   While !Eof() .AND. SF2->F2_FILIAL  == xFilial("SF2");
                .AND. SF2->F2_EMISSAO <= MV_PAR02
      IF SF2->F2_EMISSAO >= MV_PAR01 .AND.;
         SF2->F2_EMISSAO <= MV_PAR02
  	      If DTOS(SF2->F2_EMISSAO) < DTOS(MV_PAR01) .OR. DTOS(SF2->F2_EMISSAO) > DTOS(MV_PAR02)
		      DbSelectArea("SF2")
   		   SF2->(DbSkip())		
	   	   Loop
	      EndIf
   	   IncRegua()
	      *
	      *  VERIFICA nf esta na contabilidade
   	   *       
	      CACHOU := 'N'
	      DbSelectArea("CT2")
   	   DbGotop()
	      DbSeek(SF2->F2_FILIAL+DTOS(SF2->F2_DTLANC))
	      While !Eof() .And. CT2->CT2_FILORI 	== SF2->F2_FILIAL;
		      			 .And. CT2->CT2_DATA   	<= SF2->F2_DTLANC
   	      CHIST := CT2->CT2_HIST
        	   IF ALLTRIM(SF2->F2_DOC) $ ALLTRIM(CHIST)
     	         CACHOU := 'S'
     	      ENDIF
   		   DbSelectArea("CT2")
	   	   CT2->(DbSkip())
	      End
         IF li > 60
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
            li := li + 2
         ENDIF
         IF CACHOU == 'N'
	         @ li,010 PSAY SF2->F2_DOC
   	      @ LI,030 PSAY TRANSFORM(SF2->F2_VALBRUT,'@E 999,999,999.99')
   	      @ LI,050 PSAY 'NF SAIDA'
  	   	   li := li + 1
            IF li > 60
               cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
               li := li + 2
            ENDIF
         ENDIF
      ENDIF
      DbSelectArea("SF2")
      SF2->(DbSkip())
   End
ENDIF

//IF LI!=80
//   RODA(cBCONT,cBTXT,"P")
//ENDIF

set device to screen
cEmp := sm0->m0_codigo
dbcloseall()
OpenFile(cEmp)
set device to print
*
//dele file AGR0571.IDX
//dele file AGR0571.CDX

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
