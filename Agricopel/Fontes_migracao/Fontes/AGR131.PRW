#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#INCLUDE "TOPCONN.CH"

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR131()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

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
굇쿛rograma     � AGR131           � Responsavel � Deco                   낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escri뇙o    � Lista Lctos de baixa de cheques na ctb                  낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Data        � 28.09.04         � Implantacao �                        낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Programador � Deco                                                    낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Objetivos   � Listar Lcto de baixa de cheques na ctb                  낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Arquivos    � Se1  ct2                                                낢�
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
cDesc1   := "Este programa ira emitir Lctos de baixas de cheques"
cDesc2   := "AGRICOPEL"
cDesc3   := ""
cString  := "SE1"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR131"
nLastKey := 0
cPerg    := "AGR131"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := "Data  cheque     Lancamento contabil"
cabec2   := ""
wnrel    := "AGR131"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� AJUSTE NO SX1 - PAR턒ETROS                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR131","01","Data de           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR131","02","Data ate          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
//AADD(aRegistros,{"AGR131","03","1-Entrada/2-Saida ?","mv_ch3","C",01,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
*
* Cria perguntas
*
TBVSX108("AGR131",aRegistros)

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
nTotal   := 0
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
titulo := "Lista Lctos de baixa de cheques"
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
CT2->(DbSetOrder(11))              // filial+sequen+lp


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Declaracoes de arrays                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

cQuery := ""
cQuery += "SELECT E1.E1_TIPO, E1.E1_NUM, E1.E1_VALOR, CT2.CT2_SEQUEN, CT2.CT2_DATA "
cQuery += "FROM "+RetSqlName("SE1")+" E1 (NOLOCK), "
cQuery +=         RetSqlName("CT2")+" CT2 (NOLOCK), "
cQuery += "WHERE E1.E1_FILIAL = '"+xFilial("SE1")+"' AND E1.D_E_L_E_T_ = '' "
cQuery += "AND  CT2.CT2_FILIAL = '"+xFilial("CT2")+"' AND CT2.D_E_L_E_T_ = '' "
cQuery += "AND E1.E1_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
cQuery += "AND E1.E1_BAIXA   BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
cQuery += "AND SUBSTRING(E1.E1_TIPO,1,2) = 'CH' "
cQuery += "AND CT2.CT2_DATA  BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
cQuery += "AND SUBSTRING(CT2.CT2_LP,1,3) = '520' "
cQuery += "AND SUBSTRING(CT2.CT2_ORIGEM,1,6) = E1.E1_NUM "                     
cQuery += "AND CT2.CT2_VALOR = E1.E1_VALOR "                     
If SM0->M0_CODIGO == '01' 
   cQuery += "AND (SUBSTRING(CT2.CT2_DEBITO,1,9) = '111010001' OR SUBSTRING(CT2.CT2_CREDIT,1,9) = '112010001') "                     
EndIf
If SM0->M0_CODIGO == '02' 
   cQuery += "AND (SUBSTRING(CT2.CT2_DEBITO,1,9) = '111010001' OR SUBSTRING(CT2.CT2_CREDIT,1,9) = '112010002') "                     
EndIf
cQuery += "GROUP BY CT2.CT2_SEQUEN, CT2.CT2_DATA, E1.E1_TIPO, E1.E1_NUM, E1.E1_vALOR " 
cQuery += "ORDER BY CT2.CT2_SEQUEN, CT2.CT2_DATA "

If (Select("MCT2") <> 0)
	dbSelectArea("MCT2")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "MCT2"  
TCSETFIELD("MCT2","CT2_DATA"   ,"D",08,0)
TCSETFIELD("MCT2","E1_VALOR"   ,"N",14,2)

dbSelectArea("MCT2")
dbGoTop()
Procregua(Reccount())
While !EOF()
	
	IncProc()
   
   *
   * Verifica se lacto debito e credito cfe alexandre para pode eliminar
   *
   cLP     := '520'
   cDebito := ''
   cCredit := '' 
   nLctos  := 0
   DbSelectArea("CT2")
   DbSetOrder(11)
   DbGotop()
   SetRegua(RecCount())		
   DbSeek(xFilial("CT2")+MCT2->CT2_SEQUEN+cLP) 
   While !Eof() .And. CT2->CT2_SEQUEN 	== MCT2->CT2_SEQUEN;
        			 .And. CT2->CT2_LP      == cLP
      IF CT2->CT2_DATA             == MCT2->CT2_DATA .and.;
         SUBS(CT2->CT2_ORIGEM,1,6) == MCT2->E1_NUM   .and.;
         CT2->CT2_VALOR            == MCT2->E1_VALOR
	      If !Empty(CT2->CT2_DEBITO)
	         cDebito := CT2->CT2_DEBITO
	      Endif
	      If !Empty(CT2->CT2_CREDITD)
	         cCredit := CT2->CT2_CREDIT
	      Endif           
	      nLctos := nLctos + 1
	   Endif
    	DbSelectArea("CT2")
  	   CT2->(DbSkip())
   End
	If SM0->M0_CODIGO == '01' 
	   If cDebito <> '111010001' .or. cCredit <> '112010001'
        DbSelectArea("MCT2")
        MCT2->(DbSkip())
        Loop
      EndIf
	EndIf
	If SM0->M0_CODIGO == '02' 
	   If cDebito <> '111010001' .or. cCredit <> '112010002'
        DbSelectArea("MCT2")
        MCT2->(DbSkip())
        Loop
      EndIf
	EndIf

   IF li > 60
      cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
      li := li + 2
   ENDIF
   
   @ li,000 PSAY MCT2->CT2_DATA
   @ li,010 PSAY ALLTRIM(MCT2->E1_NUM)
   @ li,020 PSAY ALLTRIM(MCT2->E1_TIPO)
   @ li,025 PSAY TRANSFORM(nLctos,'@E 999')  
   @ LI,030 PSAY TRANSFORM(MCT2->E1_VALOR,'@E 999,999,999.99')  
   nTotal := nTotal + MCT2->E1_VALOR
   @ LI,050 PSAY ALLTRIM(cDebito)
   @ LI,070 PSAY ALLTRIM(cCredit)
   @ LI,110 PSAY ALLTRIM(MCT2->CT2_SEQUEN)
   *
   * Deleta lacto contabil cfe alexandre 05/10/2004
   *
   DbSelectArea("CT2")
   DbSetOrder(11)
   DbGotop()
   SetRegua(RecCount())		
   DbSeek(xFilial("CT2")+MCT2->CT2_SEQUEN+cLP) 
   While !Eof() .And. CT2->CT2_SEQUEN 	== MCT2->CT2_SEQUEN;
        			 .And. CT2->CT2_LP      == cLP
      IF CT2->CT2_DATA             == MCT2->CT2_DATA .and.;
         SUBS(CT2->CT2_ORIGEM,1,6) == MCT2->E1_NUM   .and.;
         CT2->CT2_VALOR            == MCT2->E1_VALOR
//			RecLock("CT2",.F.)
//			DBDELETE()
//			MsUnLock("CT2")
	   Endif
    	DbSelectArea("CT2")
  	   CT2->(DbSkip())
   End
   
   li := li + 1
   IF li > 60
      cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
      li := li + 2
   ENDIF
   DbSelectArea("MCT2")
   MCT2->(DbSkip())
End  
li := li + 2
IF li > 60
   cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
   li := li + 2
ENDIF
@ li,000 PSAY 'Total.............'
@ LI,030 PSAY TRANSFORM(nTotal,'@E 999,999,999.99')  


//IF LI!=80
//   RODA(cBCONT,cBTXT,"P")
//ENDIF

set device to screen
cEmp := sm0->m0_codigo
dbcloseall()
OpenFile(cEmp)
set device to print
*
//dele file AGR1311.IDX
//dele file AGR1311.CDX

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
