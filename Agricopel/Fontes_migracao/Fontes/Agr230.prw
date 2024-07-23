#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGR230   บAutor  ณ Marcelo da Cunha   บ Data ณ  31/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Produtos no Especifica (Agricopel)             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AGR230()
*******************
PRIVATE oDlg  := Nil, oPesq := Nil, oBrw := Nil, oCmb := Nil
PRIVATE aSeg  := GetArea(), aIndice := {}, aCampos := {}
PRIVATE aRotina := {{"","",0 ,1},{"","",0,2}}, aTela[0][0], aGets[0][0]
PRIVATE cPesq := Space(100), cIndice := "", cCadastro := ""
PRIVATE nOpca := 0, nRecno := 0, lRetu := .F., lOk := .F.
                                             
//Busco valor informado
///////////////////////
cPesq := &(ReadVar())
cPesq := Alltrim(cPesq) + Space(100-Len(Alltrim(cPesq)))

//Limpo filtros no arquivo SB1
//////////////////////////////
dbSelectArea("SB1")
dbClearFilter()
RetIndex("SB1")    
MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
dbSetOrder(1)
dbGotop()

//Busco informacao se necessario
////////////////////////////////
If !Empty(cPesq)
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+cPesq,.T.)
Endif
                             
//Define o aCampos
//////////////////
aCampos := {}
AADD(aCampos,{"B1_COD"   ,"Codigo"    ,"@!"})
AADD(aCampos,{"B1_DESC"  ,"Descricao" ,"@!"})
AADD(aCampos,{"B1_GRUPO" ,"Grupo"     ,"@!"})
AADD(aCampos,{"B1_PROC"  ,"Fornecedor","@!"})
AADD(aCampos,{"B1_TIPO"  ,"Tipo"      ,"@!"})
AADD(aCampos,{"B1_LOCPAD","Local"     ,"@!"})
AADD(aCampos,{"B1_UPRC"  ,"Ult.Compra","@E 999,999,999.99"})

//Indice customizado
////////////////////
cIndice := "BUSCA PARCIAL POR DESCRICAO"
Aadd(aIndice,cIndice)

//Busca indices do SB1
//////////////////////
dbSelectArea("SIX")
dbSeek("SB1",.T.)
While !Eof().and.(SIX->INDICE == "SB1") 
	Aadd(aIndice,Alltrim(SIX->descricao))
	dbSkip()
Enddo            

//Monta tela
////////////
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Consulta de Produtos-teste") FROM 000,000 TO 320,655 OF oMainWnd PIXEL
@ 005,005 TO 118,323 BROWSE "SB1" FIELDS aCampos OBJECT oBrw
oBrw:oBrowse:bLDblClick := { || (nOpca:=1,Close(oDlg))}
@ 130,005 SAY OemToAnsi("Pesquisar por:") SIZE 40,8
@ 129,045 COMBOBOX cIndice ITEMS aIndice SIZE 120,8 OBJECT oCmb
oCmb:Refresh(.F.)    
oCmb:nAt := iif(Empty(cPesq),1,2)
oCmb:bChange := { || R230Pesquisa(Alltrim(cPesq))}
@ 145,005 SAY OemToAnsi("Localizar:") SIZE 40,8
@ 144,045 GET cPesq SIZE 120,8 VALID R230Pesquisa(Alltrim(cPesq)) OBJECT oPesq
oPesq:SetFocus()
oPesq:bGotFocus := { || R230Limpa(Alltrim(cPesq)) }
@ 134,175 BMPBUTTON TYPE 1 ACTION (nOpca:=1,Close(oDlg))
@ 134,205 BMPBUTTON TYPE 2 ACTION (nOpca:=0,Close(oDlg))
//@ 134,235 BMPBUTTON TYPE 4 ACTION (R230Inclui())
@ 134,265 BMPBUTTON TYPE 15 ACTION (R230Visual()) //03/10/2017 - chamado 59011
If (cModulo == "TMK")
	@ 134,295 BMPBUTTON TYPE 14 ACTION (lOk:=R230Notas(),iif(lOk,Close(oDlg),))
Endif
ACTIVATE MSDIALOG oDlg ON INIT (R230Pesquisa(Alltrim(cPesq))) CENTERED
             
lRetu := (nOpca==1).or.(lOk)

dbSelectArea("SB1")
nRecno := Recno()
dbClearFilter()
RetIndex("SB1")    
//MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
//RestArea(aSeg)           
SB1->(dbSetOrder(1))
SB1->(dbGoto(nRecno))

Return (lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR230PesquisaบAutor  ณ Marcelo da Cunha บ Data ณ  31/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que realiza a pesquisa no Browse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R230Pesquisa(xPesq)
****************************
LOCAL cIndex := "", cKey := "", cFiltro := ""
LOCAL nInd := 0, nIndex := 0

If Empty(xPesq)
	dbSelectArea("SB1")
	dbClearFilter()
	RetIndex("SB1")    
	MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
	dbSetOrder(1)
	dbGotop()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
//	SysRefresh() // Comentado Deco 04/01/2006
	Return (.T.)
Endif

nInd := aScan(aIndice,Alltrim(cIndice))

If (nInd == 1)
	dbSelectArea("SB1")
	dbClearFilter()
	RetIndex("SB1")    
	MsFilter("(B1_FILIAL='"+xFilial("SB1")+"').and.('"+Alltrim(xPesq)+"' $ B1_DESC)")
	dbSetOrder(1)
	dbGotop()
Else    
	dbSelectArea("SB1")
	dbClearFilter()
	RetIndex("SB1")    
	MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
	dbSetOrder(1)
	dbGotop()
	nInd--
	If !Empty(nInd)
		dbSelectArea("SB1")
		dbSetOrder(nInd)
		dbSeek(xFilial("SB1")+xPesq,.T.)
	Endif
Endif

If (oBrw <> Nil)
	oBrw:oBrowse:Refresh()
Endif
//SysRefresh() // Comentado Deco 04/01/2006

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR230IncluiบAutor  ณ Marcelo da Cunha   บ Data ณ  31/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para incluir os registros                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R230Inclui()
***********************
LOCAL nOK := 0
dbSelectarea("SB1")
SETAPILHA()
nOK := AxInclui("SB1")
If (nOK == 1)
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
//	SysRefresh()		// Comentado Deco 04/01/2006
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR230VisualบAutor  ณ Marcelo da Cunha   บ Data ณ  31/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para visualizar os registros                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R230Visual()
***********************
AxVisual("SB1",Recno(),1,,,,)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR230Notas บAutor  ณ Marcelo da Cunha   บ Data ณ  11/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R230Limpa(xPesq)
****************************
If Empty(xPesq)
	dbSelectArea("SB1")
	dbClearFilter()
	RetIndex("SB1")    
	MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
	dbSetOrder(1)
	dbGotop()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
//	SysRefresh()		// Comentado Deco 04/01/2006
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR230Notas บAutor  ณ Marcelo da Cunha   บ Data ณ  11/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R230Notas()
************************
PRIVATE __lRetu := .F.
Processa({|| R230BuscaNota()})
Return __lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR230Notas บAutor  ณ Marcelo da Cunha   บ Data ณ  11/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R230BuscaNota()
***************************
LOCAL cCliente := Space(6), cLoja := Space(2), cProduto := Space(15), cTabela := Space(3)
LOCAL cQuery := "", cNomArq := "", cNomCli := ""
LOCAL aCamposN := {}
LOCAL nPrcPro := 0, nPrcTab := 0

PRIVATE oDlgN  := Nil, oBrwN := Nil, nOpcb := 0
                        
//Verifico se existem dados
///////////////////////////
If (SB1->(Bof())).and.(SB1->(Eof()))
	Return
Endif
                     
//Alimento variaveis com os produtos
////////////////////////////////////
cCliente := M->UA_cliente
cLoja    := M->UA_loja
cTabela  := M->UA_tabela

If Empty(cCliente)
	MsgInfo(">>> Voce precisa informar um cliente!!!")
	Return
Endif                      

//Seta regua de processamento
/////////////////////////////
Procregua(1) ; Incproc(">>> Aguarde...")

//Filtro o arquivo de amarracao
///////////////////////////////
dbSelectArea("SA7")
MsFilter("(A7_FILIAL='"+xFilial("SA7")+"').and.(A7_CLIENTE='"+cCliente+"').and.(A7_LOJA='"+cLoja+"')") 
                      
//Monto campos q serao exibidos
///////////////////////////////
aCamposN := {}      
Aadd(aCamposN,{"A7_PRODUTO"  ,"Produto"     ,"@K!" })
Aadd(aCamposN,{"A7_DESCRI"   ,"Descricao"   ,"@K!" })
Aadd(aCamposN,{"A7_QUANT"    ,"Quantidade"  ,"@E 9,999,999.99" })
Aadd(aCamposN,{"A7_PRCVEN"   ,"Prc.Venda"   ,"@E 999,999,999.99" })
Aadd(aCamposN,{"A7_EMISSAO"  ,"Emissao"     ,"@E"  })
Aadd(aCamposN,{"A7_PRCTAB"   ,"Prc.Tabela"  ,"@E 999,999,999.99" })
Aadd(aCamposN,{"A7_PRCPRO"   ,"Prc.Promocao","@E 999,999,999.99" })

//Monto tela para exibir registros
//////////////////////////////////
cNomCli := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME"))
dbSelectArea("SA7") ; dbSetOrder(3) ; dbGotop()
DEFINE MSDIALOG oDlgN TITLE OemToAnsi("Consulta de Notas Fiscais: "+cNomCli) FROM 000,000 TO 320,655 OF oMainWnd PIXEL
@ 005,005 TO 137,323 BROWSE "SA7" FIELDS aCamposN OBJECT oBrwN
oBrwN:oBrowse:bLDblClick := { || (nOpcb:=1,Close(oDlgN))}
@ 142,200 BMPBUTTON TYPE 1 ACTION (nOpcb:=1,Close(oDlgN))
@ 142,240 BMPBUTTON TYPE 2 ACTION (nOpcb:=0,Close(oDlgN))
ACTIVATE MSDIALOG oDlgN CENTERED

__lRetu := iif(nOpcb==1,.T.,.F.)

//Posicione no arquivo de produtos
//////////////////////////////////
If (__lRetu)
	dbSelectArea("SB1")
	RetIndex("SB1")    
	dbClearFilter()
	MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SA7->A7_produto,.T.)
Endif

dbSelectArea("SA7")
RetIndex("SA7")    
dbClearFilter()
MsFilter("A7_FILIAL='"+xFilial("SA7")+"'")

Return