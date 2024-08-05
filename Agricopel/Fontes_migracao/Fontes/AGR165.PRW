#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function AGR165()        // incluido pelo assistente de conversao do AP5 IDE em 29/09/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

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
SetPrvt("ASTRU,CARQ,XVEND1,VLCOMISS,CVEZ,CMES,CANO,CCLI,CLOJA,NMESES")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/09/00 ==> #DEFINE PSAY SAY
#ENDIF

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Cliente      � AGRICOPEL                                               ���
�������������������������������������������������������������������������Ĵ��
���Programa     � AGR165           � Responsavel � Deco                   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o    � Atuliza Teto maximo Desconto do cliente para um produto ���
�������������������������������������������������������������������������Ĵ��
��� Data        � 03.03.05         � Implantacao �                        ���
�������������������������������������������������������������������������Ĵ��
��� Programador � DECO                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Objetivos   � Atualizar teto maximo desconto cliente para produto     ���
�������������������������������������������������������������������������Ĵ��
��� Arquivos    � SA1                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Parametros  � mv_par01                                                ���
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
cDesc1   := "Este programa ira Atualiza teto maximo Desconto do Cliente"
cDesc2   := ""
cDesc3   := ""
cString  := "SA1"
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "AGR165"
nLastKey := 0
cPerg    := "AGR165"
               
cbText   := space(10)
cbCont   := 0                                                                                                            
cabec1   := ""
cabec2   := ""
wnrel    := "AGR165"

//��������������������������������������������������������������Ŀ
//� AJUSTE NO SX1 - PAR�METROS                                   �
//����������������������������������������������������������������
aSvAlias:={Alias(),IndexOrd(),Recno()}
aRegistros:={}
AADD(aRegistros,{"AGR165","01","Teto Maximo Industria  ?","mv_ch1","N",05,2,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR165","02","Teto Maximo Revendedor ?","mv_ch2","N",05,2,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{"AGR165","03","Teto Maximo Cons.Final ?","mv_ch3","N",05,2,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
*
* Cria perguntas 
*
TBVSX108("AGR165",aRegistros)

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
//� mv_par01             // Teto maximo Industria                                   �
//� mv_par02             // Teto maximo Revendedor                                  � 
//� mv_par03             // Teto maximo Cons.Final                                  �
//�����������������������������������������������������������������������������������
titulo := "Atuliza Teto maximo Desconto cliente"
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
SA1->(DbSetOrder(1))               // filial+cod+loja


//��������������������������������������������������������������Ŀ
//� Declaracoes de arrays                                        �
//����������������������������������������������������������������
* 
SELE SA1
dbgotop()
setregua(SA1->(reccount()))
DbSeek(xFilial("SA1"),.T.)
While !eof() .AND. xFilial("SA1")     == SA1->A1_FILIAL 

   IF LastKey()==286
      Exit
   Endif   
   
   If SA1->A1_SATIV1 == '999999'  // Industria
      If !Empty(MV_PAR01)
			RecLock("SA1",.F.)
   		SA1->A1_MAXDESC := MV_PAR01
			MsUnLock("SA1")					 
      Endif
   Else
      If SA1->A1_TIPO == 'R' .And. !Empty(MV_PAR02) // Revendedor
			RecLock("SA1",.F.)
   		SA1->A1_MAXDESC := MV_PAR02
			MsUnLock("SA1")					 
      Endif
      If SA1->A1_TIPO == 'F' .And. !Empty(MV_PAR03) // Cons. Final
			RecLock("SA1",.F.)
   		SA1->A1_MAXDESC := MV_PAR03
			MsUnLock("SA1")					 
      Endif
   Endif
   
   sele SA1
   incregua()
   dbskip()
END

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