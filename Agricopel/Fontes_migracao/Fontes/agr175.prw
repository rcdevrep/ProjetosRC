#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#INCLUDE "TOPCONN.CH"  

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR175()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Cliente      � Agricopel                                               ���
�������������������������������������������������������������������������Ĵ��
���Programa     � AGR175           � Responsavel � Deco                   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o    � Alterar Numeracao de cheque devido sistema bloquear     ���
�������������������������������������������������������������������������Ĵ��
��� Data        � 25.05.05         � Implantacao �                        ���
�������������������������������������������������������������������������Ĵ��
��� Programador � DECO                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Objetivos   � Alterar Numeracao cheque                                ���
�������������������������������������������������������������������������Ĵ��
��� Arquivos    � SEF,SE5                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Observacoes �                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Cuidados na �                                                         ���
��� Atualizacao �                                                         ���
��� de versao   �                                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
cSavCur1 := "";cSavRow1:="";cSavCol1:="";cSavCor1:="";cSavScr1:="";CbTxt:=""
CbCont   := "";cabec1:="";cabec2:="";cabec3:="";wnrel:=""
nOrdem   := 0
tamanho  := "M"
limite   := 132
cDesc1   := "Este programa ira Renumerar Cheque"
cDesc2   := "AGRICOPEL"
cDesc3   := ""
cString  := "SEF"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR175"
nLastKey := 0
cPerg    := "AGR175"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := ""
cabec2   := ""
wnrel    := "AGR175"

//��������������������������������������������������������������Ŀ
//� AJUSTE NO SX1 - PAR�METROS                                   �
//����������������������������������������������������������������
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR175","01","Cheque nr  ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
*
* Cria perguntas
*
TBVSX108("AGR175",aRegistros)

dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])
//��������������������������������������������������������������Ŀ
//� FIM DO AJUSTE                                                �
//����������������������������������������������������������������


//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
m_pag    := 1
LI       := 80 
//���������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas, busca o padrao da PRE-NOTA�
//�����������������������������������������������������������������
pergunte(cPerg,.F.)
//���������������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                            �
//� mv_par01             // Vendedor de                                             �
//� mv_par02             // Vendedor Ate                                            � 
//�����������������������������������������������������������������������������������
titulo := "Renumera Cheque"
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
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
//��������������������������������������������������������������Ŀ
//�Selecao de Chaves para os arquivos                            �
//����������������������������������������������������������������
SEF->(DbSetOrder(1))               // filial+cod+loja
SE5->(DbSetOrder(1))               // filial+cod

//cArq :=CriaTrab(NIL,.F.)
//dbSELECTAREA("SF2")
//IndRegua("SF2",cArq,"F2_VEND1",,,"Selecionando registros...")

//��������������������������������������������������������������Ŀ
//� Declaracoes de arrays                                        �
//����������������������������������������������������������������

cNumChq := '0'+mv_par01

*
* Renumera Cheque SEF
*                       
cQuery := ""
cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
cQuery += "FROM "+RetSqlName("SEF")+" "
cQuery += "WHERE EF_FILIAL = '"+xFilial("SEF")+"' "
cQuery += "AND D_E_L_E_T_ <> '*' "
cQuery += "AND EF_NUM = '"+mv_par01+"' "
cQuery := ChangeQuery(cQuery)
If Select("SEF01") <> 0
	dbSelectArea("SEF01")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "SEF01"
DbSelectArea("SEF01")
DbGoTop()
While !Eof()  
	DbSelectArea("SEF")
	DbGoto(SEF01->nIdRecno)
	RecLock("SEF",.F.)
		SEF->EF_NUM := cNumChq
	MsUnLock("SEF")
	DbSelectArea("SEF01")
   DbSkip()
EndDo 
*
* Renumera Cheque SE5
*                       
cQuery := ""
cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "  
cQuery += "FROM "+RetSqlName("SE5")+" "
cQuery += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
cQuery += "AND D_E_L_E_T_ <> '*' "
cQuery += "AND E5_NUMCHEQ = '"+mv_par01+"' "
cQuery := ChangeQuery(cQuery)
If Select("SE501") <> 0
	dbSelectArea("SE501")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "SE501"
DbSelectArea("SE501")
DbGoTop()
While !Eof()  
	DbSelectArea("SE5")
	DbGoto(SE501->nIdRecno)
	RecLock("SE5",.F.)
		SE5->E5_NUMCHEQ := cNumChq
	MsUnLock("SE5")
	DbSelectArea("SE501")
   DbSkip()
EndDo 

set device to screen
cEmp := sm0->m0_codigo
dbcloseall()
OpenFile(cEmp)
set device to print
*
Set Device To Screen
//RestScreen(3,0,24,79,cSavScr1)


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
