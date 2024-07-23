#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR231   �Autor  � Marcelo da Cunha   � Data �  11/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Consulta de Clientes Especifica (Agricopel)                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGR231()
*******************
PRIVATE oDlg  := Nil, oPesq := Nil, oBrw := Nil, oCmb := Nil
PRIVATE aSeg  := GetArea(), aIndice := {}, aCampos := {}, aLixo := {}
PRIVATE aRotina := {{"","",0 ,1},{"","",0,2}}, aTela[0][0], aGets[0][0]
PRIVATE cPesq := Space(100), cIndice := "", cCadastro := "", cVar := Alltrim(ReadVar())
PRIVATE nOpca := 0, nRecno := 0, lRetu := .F.
                                             
//Busco valor informado
///////////////////////
cPesq := &(ReadVar())
cPesq := Alltrim(cPesq) + Space(100-Len(Alltrim(cPesq)))

If !Empty(cPesq)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cPesq,.T.)
Endif
                             
//Define o aCampos
//////////////////
aCampos := {}
AADD(aCampos,{"A1_COD"   ,"Codigo"    ,"@!"})
AADD(aCampos,{"A1_LOJA"  ,"Loja"      ,"@!"})
AADD(aCampos,{"A1_NOME"  ,"Nome"      ,"@!"})
AADD(aCampos,{"A1_CGC"   ,"Cnpj/Cpf"  ,"@R 999.999.999/9999-99"})
AADD(aCampos,{"A1_TEL"   ,"Telefone"  ,"@!"})
AADD(aCampos,{"A1_MUN"   ,"Municipio" ,"@!"})
AADD(aCampos,{"A1_NREDUZ","N.Reduzido","@!"})

//Indice customizado
////////////////////
cIndice := "BUSCA PARCIAL POR DESCRICAO"
Aadd(aIndice,cIndice)

//Busca indices do SA1
//////////////////////
dbSelectArea("SIX")
dbSeek("SA1",.T.)
While !Eof().and.(SIX->INDICE == "SA1") 
	Aadd(aIndice,Alltrim(SIX->descricao))
	dbSkip()
Enddo            

//Monta tela
////////////
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Consulta de Clientes") FROM 000,000 TO 320,590 OF oMainWnd PIXEL
@ 005,005 TO 110,290 BROWSE "SA1" FIELDS aCampos OBJECT oBrw
oBrw:oBrowse:bLDblClick := { || (nOpca:=1,Close(oDlg))}
@ 126,005 SAY OemToAnsi("Pesquisar por:") SIZE 40,8
@ 125,045 COMBOBOX cIndice ITEMS aIndice SIZE 120,8 OBJECT oCmb
oCmb:Refresh(.F.)    
oCmb:nAt := iif(Empty(cPesq),1,2)
oCmb:bChange := { || R231Pesquisa(Alltrim(cPesq))}
@ 141,005 SAY OemToAnsi("Localizar:") SIZE 40,8
@ 140,045 GET cPesq SIZE 120,8 VALID R231Pesquisa(Alltrim(cPesq)) OBJECT oPesq
oPesq:SetFocus()
oPesq:bGotFocus := { || R231Limpa(Alltrim(cPesq)) }
@ 130,175 BMPBUTTON TYPE 1 ACTION (nOpca:=1,Close(oDlg))
@ 130,205 BMPBUTTON TYPE 2 ACTION (nOpca:=0,Close(oDlg))
@ 130,235 BMPBUTTON TYPE 4 ACTION (R231Inclui())
@ 130,265 BMPBUTTON TYPE 15 ACTION (R231Visual())
ACTIVATE MSDIALOG oDlg ON INIT (R231Pesquisa(Alltrim(cPesq)))CENTERED
             
lRetu := iif(nOpca==1,.T.,.F.)

For _i := 1 to Len(aLixo)
	If File(aLixo[_i])
		FErase(aLixo[_i])
	Endif
Next _i

nRecno := SA1->(Recno())
RestArea(aSeg)           
SA1->(dbGoto(nRecno))
SA1->(dbSetOrder(1))

If (lRetu)
	&(cVar) := SA1->A1_cod
Endif

Return (lRetu)
      
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R231Pesquisa�Autor  � Marcelo da Cunha � Data �  11/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que realiza a pesquisa no Browse                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R231Pesquisa(xPesq)
****************************
LOCAL cIndex := "", cKey := "", cFiltro := ""
LOCAL nInd := 0, nIndex := 0

If Empty(xPesq)
	dbSelectArea("SA1")
	RetIndex("SA1")
	dbClearFilter()
	dbGotop()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
	Return (.T.)
ENdif

dbSelectArea("SA1")
RetIndex("SA1")    
dbClearFilter()

nInd := aScan(aIndice,Alltrim(cIndice))

If (nInd == 1)
   dbSelectArea("SA1")
   cIndex  := CriaTrab(Nil,.f.)
   Aadd(aLixo,cIndex)
   cKey    := IndexKey()                
   cFiltro := "('"+Alltrim(xPesq)+"' $ A1_NOME)"
   IndRegua("SA1",cIndex,cKey,,cFiltro,OemToAnsi("Selecionando Registros..."))
   nIndex:=RetIndex("SA1") 
	#IFNDEF TOP
   	dbSetIndex(cIndex)
	#ENDIF
   dbSetOrder(nIndex+1)
   dbGotop()
Else    
	nInd--
	If !Empty(nInd)
		dbSelectArea("SA1")
		dbSetOrder(nInd)
		dbSeek(xFilial("SA1")+xPesq,.T.)
	Endif
Endif

If (oBrw <> Nil)
	oBrw:oBrowse:Refresh()
Endif

Return (.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R231Inclui�Autor  � Marcelo da Cunha   � Data �  11/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para incluir os registros                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R231Inclui()
***********************
LOCAL nOK := 0
dbSelectarea("SA1")
SETAPILHA()
nOK := AxInclui("SA1")
If (nOK == 1)
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
Endif
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R231Visual�Autor  � Marcelo da Cunha   � Data �  11/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para visualizar os registros                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R231Visual()
***********************
AxVisual("SA1",Recno(),1,,,,)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R231Limpa �Autor  � Marcelo da Cunha   � Data �  11/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para buscar as ultimas notas                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R231Limpa(xPesq)
****************************
If Empty(xPesq)
	dbSelectArea("SA1")
	RetIndex("SA1")
	dbClearFilter()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
Endif
Return