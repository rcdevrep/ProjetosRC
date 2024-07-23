#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGR241   บAutor  ณ Marcelo da Cunha   บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Produtos no Especifica (Agricopel)             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AGR241()
*******************
PRIVATE oDlg  := Nil, oPesq := Nil, oBrw := Nil, oCmb := Nil
PRIVATE aSeg  := GetArea(), aIndice := {}, aCampos := {}, aLixo := {}
PRIVATE aRotina := {{"","",0 ,1},{"","",0,2}}, aTela[0][0], aGets[0][0]
PRIVATE cCliente := Space(6), cLoja := Space(2), cProduto := Space(15)
PRIVATE cPesq := Space(100), cIndice := "", cCadastro := "", cNomCli := ""
PRIVATE nOpca := 0, nRecno := 0, lRetu := .F., lOk := .F., M->M_PROD := Space(15)

//Alimento variaveis com os produtos
////////////////////////////////////
cCliente := M->UA_cliente
cLoja    := M->UA_loja

If Empty(cCliente)
	MsgInfo(">>> Voce precisa informar um cliente!!!")
	Return
Endif                      

//Busco valor informado
///////////////////////
cPesq := &(ReadVar())
cPesq := Alltrim(cPesq) + Space(100-Len(Alltrim(cPesq)))

//Limpo filtros no arquivo SB1
//////////////////////////////
dbSelectArea("SA7")
dbClearFilter()
RetIndex("SA7")    

MsFilter("(A7_FILIAL='"+xFilial("SA7")+"').and.(A7_CLIENTE='"+cCliente+"').and.(A7_LOJA='"+cLoja+"')") 
dbSetOrder(3)
dbGotop()

//Busco informacao se necessario
////////////////////////////////
If !Empty(cPesq)                                                                                    
	dbSelectArea("SA7")
	dbSetOrder(2)
	dbSeek(xFilial("SA7")+cPesq,.T.)
Endif             

//Indice customizado
////////////////////
cIndice := "BUSCA PARCIAL POR DESCRICAO"
Aadd(aIndice,cIndice)

//Busca indices do SB1
//////////////////////
dbSelectArea("SIX")
dbSeek("SA7",.T.)
While !Eof().and.(SIX->INDICE == "SA7") 
	Aadd(aIndice,Alltrim(SIX->descricao))
	dbSkip()
Enddo            
                      
//Monto campos q serao exibidos
///////////////////////////////
aCampos := {}      
Aadd(aCampos,{"A7_PRODUTO"  ,"Produto"     ,"@K!" })
Aadd(aCampos,{"A7_DESCRI"   ,"Descricao"   ,"@K!" })
Aadd(aCampos,{"A7_QUANT"    ,"Quantidade"  ,"@E 9,999,999.99" })
Aadd(aCampos,{"A7_PRCVEN"   ,"Prc.Venda"   ,"@E 999,999,999.99" })
Aadd(aCampos,{"A7_EMISSAO"  ,"Emissao"     ,"@E"  })
Aadd(aCampos,{"A7_PRCTAB"   ,"Prc.Tabela"  ,"@E 999,999,999.99" })
Aadd(aCampos,{"A7_CONDPGT"   ,"Cond.Pgto","@!" })   // Alterado devido a solicita็ใo da Saionara, chamado 40125 - Thiago SLA - 02/06/2016

//Monto tela para exibir registros
//////////////////////////////////
cNomCli := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME"))
dbSelectArea("SA7") ; dbSetOrder(3) ; dbGotop()
//DEFINE MSDIALOG oDlg TITLE OemToAnsi("Consulta ultimas compras do cliente: "+cNomCli) FROM 000,000 TO 320,655 OF oMainWnd PIXEL
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Consulta ultimas compras do cliente: "+cNomCli) FROM 000,000 TO 320,955 OF oMainWnd PIXEL
//@ 005,005 TO 118,323 BROWSE "SA7" FIELDS aCampos OBJECT oBrw
@ 005,005 TO 118,470 BROWSE "SA7" FIELDS aCampos OBJECT oBrw
oBrw:oBrowse:bLDblClick := { || (nOpca:=1,Close(oDlg))}
@ 130,005 SAY OemToAnsi("Pesquisar por:") SIZE 40,8
@ 129,045 COMBOBOX cIndice ITEMS aIndice SIZE 120,8 OBJECT oCmb
oCmb:Refresh(.F.)    
oCmb:nAt := iif(Empty(cPesq),1,3)
oCmb:bChange := { || R241Pesquisa(Alltrim(cPesq))}
@ 145,005 SAY OemToAnsi("Localizar:") SIZE 40,8
@ 144,045 GET cPesq SIZE 120,8 VALID R241Pesquisa(Alltrim(cPesq)) OBJECT oPesq
oPesq:SetFocus()
oPesq:bGotFocus := { || R241Limpa(Alltrim(cPesq)) } 
@ 134,175 BMPBUTTON TYPE 1 ACTION (nOpca:=1,Close(oDlg))       // Botao Ok
@ 134,205 BMPBUTTON TYPE 2 ACTION (nOpca:=0,Close(oDlg))       // Botao Cancelar                               	
@ 134,235 BMPBUTTON TYPE 15 ACTION (R241Visual(1))             // Botao Visualizar
//@ 134,265 BMPBUTTON TYPE 14 ACTION (lOk:=R241Prod(),iif(lOk,Close(oDlg),))     // Botao Abrir
@ 134,235 BMPBUTTON TYPE 14 ACTION (lOk:=R241Prod(),iif(lOk,Close(oDlg),))     // Botao Abrir
//@ 134,295 BMPBUTTON TYPE 17 ACTION (R241Saldo(1))  // Comentado nao eh para ter Botao Filtro na tela - Deco 22/11/2005
ACTIVATE MSDIALOG oDlg ON INIT (R241Pesquisa(Alltrim(cPesq))) CENTERED

lRetu := (nOpca==1).or.(lOk)

//Alimento variavel de retorno
//////////////////////////////
If (lRetu)
	dbSelectArea("SB1")
	dbSetOrder(1)
	If (nOpca == 1)
		dbSeek(xFilial("SB1")+SA7->A7_produto,.T.)
	Else
		dbSeek(xFilial("SB1")+M->M_PROD,.T.)
	Endif
Endif

For _i := 1 to Len(aLixo)
	If File(aLixo[_i])
		FErase(aLixo[_i])
	Endif
Next _i

nRecno := SB1->(Recno())
RestArea(aSeg)
SB1->(dbGoto(nRecno))
SB1->(dbSetOrder(1))

Return (lRetu)
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241PesquisaบAutor  ณ Marcelo da Cunha บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que realiza a pesquisa no Browse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241Pesquisa(xPesq)
*******************************
LOCAL cIndex := "", cKey := "", cFiltro := ""
LOCAL nInd := 0, nIndex := 0

If Empty(xPesq)
	dbSelectArea("SA7")
	dbClearFilter()
	RetIndex("SA7")     
	SET FILTER TO A7_FILIAL== xFilial("SA7") .and. A7_CLIENTE== cCliente .and. A7_EMISSAO >= stod('20130101') .and. A7_LOJA == cLoja
 
	dbSetOrder(4)
	dbGotop()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()                                                   
		
	Endif
	//SysRefresh()
	Return (.T.)
Endif

dbSelectArea("SA7")
dbClearFilter()
RetIndex("SA7")
//MsFilter("(A7_FILIAL='"+xFilial("SA7")+"').and.(A7_CLIENTE='"+cCliente+"').and.(A7_LOJA='"+cLoja+"') .and. (dtos(A7_EMISSAO) >='"+(datacli)+"')") 
	SET FILTER TO A7_FILIAL== xFilial("SA7") .and. A7_CLIENTE= = cCliente .and. A7_EMISSAO >= stod('20130101') .and. A7_LOJA == cLoja
// MsFilter("A7_EMISSAO >='"+DTOS(datacli)+"')")
dbSetOrder(4)
dbGotop()

nInd := aScan(aIndice,Alltrim(cIndice))

If (nInd == 1)
   dbSelectArea("SA7")
   cIndex  := CriaTrab(Nil,.f.)
   Aadd(aLixo,cIndex)
   cKey    := IndexKey()                
   cFiltro := "('"+Alltrim(xPesq)+"' $ A7_DESCRI)"
   IndRegua("SA7",cIndex,cKey,,cFiltro,OemToAnsi("Selecionando Registros..."))
   nIndex:=RetIndex("SA7") 
	#IFNDEF TOP
   	dbSetIndex(cIndex)
	#ENDIF
   dbSetOrder(nIndex+1)
   dbGotop()
Else    
	nInd--
	If !Empty(nInd)
		dbSelectArea("SA7")
		dbSetOrder(nInd)
		dbSeek(xFilial("SA7")+xPesq,.T.)
	Endif
Endif

If (oBrw <> Nil)
	oBrw:oBrowse:Refresh()
Endif
//SysRefresh()

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241VisualบAutor  ณ Marcelo da Cunha   บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para visualizar os registros                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241Visual(xOpc)
*****************************
LOCAL aSegSB1 := {}
           
If (xOpc == 1)
	aSegSB1 := SB1->(GetArea())
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+SA7->A7_produto)
		AxVisual("SB1",Recno(),1,,,,)        
	Endif
	RestArea(aSegSB1)
Else
	AxVisual("SB1",Recno(),1,,,,)        
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241Limpa บAutor  ณ Marcelo da Cunha   บ Data ณ  11/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241Limpa(xPesq)
****************************
If Empty(xPesq)
	dbSelectArea("SA7")
	dbClearFilter()
	RetIndex("SA7")     
	MsFilter("(A7_FILIAL='"+xFilial("SA7")+"').and.(A7_CLIENTE='"+cCliente+"').and.(A7_LOJA='"+cLoja+"')") 	
	dbSetOrder(3)
	dbGotop()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
	//SysRefresh()		
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241Prod  บAutor  ณ Marcelo da Cunha   บ Data ณ  11/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241Prod()
***********************
PRIVATE oDlgN  := Nil, oPesqN := Nil, oBrwN := Nil, oCmbN := Nil
PRIVATE aSegN  := GetArea(), aIndiceN := {}, aCamposN := {}
PRIVATE cPesqN := Space(100), cIndiceN := "", cCadastroN := ""
PRIVATE nOpcb  := 0
PRIVATE __lRetu:= .F.
                                             
//Limpo filtros no arquivo SB1
//////////////////////////////
dbSelectArea("SB1")
dbClearFilter()
RetIndex("SB1")    
//MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
MsFilter("B1_FILIAL='"+xFilial("SB1")+"' .and. B1_SITUACA = '1'")
dbSetOrder(1)
dbGotop()

//Define o aCampos
//////////////////
aCamposN := {}
AADD(aCamposN,{"B1_COD"   ,"Codigo"    ,"@!"})
AADD(aCamposN,{"B1_DESC"  ,"Descricao" ,"@!"})
AADD(aCamposN,{"B1_GRUPO" ,"Grupo"     ,"@!"})
AADD(aCamposN,{"B1_PROC"  ,"Fornecedor","@!"})
AADD(aCamposN,{"B1_TIPO"  ,"Tipo"      ,"@!"})
AADD(aCamposN,{"B1_LOCPAD","Local"     ,"@!"})

//Indice customizado
////////////////////
cIndiceN := "BUSCA PARCIAL POR DESCRICAO"
Aadd(aIndiceN,cIndiceN)

//Busca indices do SB1
//////////////////////
dbSelectArea("SIX")
dbSeek("SB1",.T.)
While !Eof().and.(SIX->INDICE == "SB1") 
	Aadd(aIndiceN,Alltrim(SIX->descricao))
	dbSkip()
Enddo            

//Monta tela
////////////
DEFINE MSDIALOG oDlgN TITLE OemToAnsi("Consulta de Produtos") FROM 000,000 TO 320,655 OF oMainWnd PIXEL
@ 005,005 TO 118,323 BROWSE "SB1" FIELDS aCamposN OBJECT oBrwN
oBrwN:oBrowse:bLDblClick := { || (nOpcb:=1,Close(oDlgN))}
@ 130,005 SAY OemToAnsi("Pesquisar por:") SIZE 40,8
@ 129,045 COMBOBOX cIndiceN ITEMS aIndiceN SIZE 120,8 OBJECT oCmbN
oCmbN:Refresh(.F.)    
oCmbN:nAt := iif(Empty(cPesqN),1,2)
oCmbN:bChange := { || R241ProdPesq(Alltrim(cPesqN))}
@ 145,005 SAY OemToAnsi("Localizar:") SIZE 40,8
@ 144,045 GET cPesqN SIZE 120,8 VALID R241ProdPesq(Alltrim(cPesqN)) OBJECT oPesqN
oPesqN:SetFocus()
oPesqN:bGotFocus := { || R241ProdLimpa(Alltrim(cPesqN)) }
@ 134,175 BMPBUTTON TYPE 1 ACTION (nOpcb:=1,Close(oDlgN))   // Botao Ok
@ 134,205 BMPBUTTON TYPE 2 ACTION (nOpcb:=0,Close(oDlgN))   // Botao Cancelar
//@ 134,235 BMPBUTTON TYPE 4 ACTION (R241Inclui())            // Botao Incluir
@ 134,265 BMPBUTTON TYPE 15 ACTION (R241Visual(2))          // Botal Visualizar
//@ 134,295 BMPBUTTON TYPE 17 ACTION (R241Saldo(2))  // Comentado nao eh para ter Botao Filtro na tela - Deco 22/11/2005
ACTIVATE MSDIALOG oDlgN ON INIT (R241ProdPesq(Alltrim(cPesqN))) CENTERED
             
__lRetu := iif(nOpcb==1,.T.,.F.)

//Posicione no arquivo de produtos
//////////////////////////////////
M->M_PROD := Space(15)
If (__lRetu)
	dbSelectArea("SA7")
	RetIndex("SA7")
	dbClearFilter()
	MsFilter("A7_FILIAL='"+xFilial("SA7")+"'")
	dbSetOrder(2)
	dbSeek(xFilial("SA7")+SB1->B1_cod,.T.)
	M->M_PROD := SB1->B1_cod
Endif

dbSelectArea("SB1")
RetIndex("SB1")    
dbClearFilter()
MsFilter("B1_FILIAL='"+xFilial("SB1")+"' .and. B1_SITUACA = '1'")

Return __lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241IncluiบAutor  ณ Marcelo da Cunha   บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241Inclui()
*************************
LOCAL nOK := 0
dbSelectarea("SB1")
SETAPILHA()
nOK := AxInclui("SB1")
If (nOK == 1)
	If (oBrwN <> Nil)
		oBrwN:oBrowse:Refresh()
	Endif
	//SysRefresh()		
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241ProdPeบAutor  ณ Marcelo da Cunha   บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241ProdPesq(xPesq)
********************************
LOCAL cIndex := "", cKey := "", cFiltro := ""
LOCAL nInd := 0, nIndex := 0

If Empty(xPesq)
	dbSelectArea("SB1")
	dbClearFilter()
	RetIndex("SB1")    
//	MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
	MsFilter("B1_FILIAL='"+xFilial("SB1")+"' .and. B1_SITUACA = '1'")
	dbSetOrder(1)
	dbGotop()
	If (oBrwN <> Nil)
		oBrwN:oBrowse:Refresh()
	Endif
	//SysRefresh()
	Return (.T.)
Endif

dbSelectArea("SB1")
dbClearFilter()
RetIndex("SB1")    
//MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
MsFilter("B1_FILIAL='"+xFilial("SB1")+"' .and. B1_SITUACA = '1'")
dbSetOrder(1)
dbGotop()

nInd := aScan(aIndiceN,Alltrim(cIndiceN))

If (nInd == 1)
   dbSelectArea("SB1")
   cIndex  := CriaTrab(Nil,.f.)
   Aadd(aLixo,cIndex)
   cKey    := IndexKey()                
   cFiltro := "('"+Alltrim(xPesq)+"' $ B1_DESC)"
   IndRegua("SB1",cIndex,cKey,,cFiltro,OemToAnsi("Selecionando Registros..."))
   nIndex:=RetIndex("SB1") 
	#IFNDEF TOP
   	dbSetIndex(cIndex)
	#ENDIF
   dbSetOrder(nIndex+1)
   dbGotop()
Else    
	nInd--
	If !Empty(nInd)
		dbSelectArea("SB1")
		dbSetOrder(nInd)
		dbSeek(xFilial("SB1")+xPesq,.T.)
	Endif
Endif

If (oBrwN <> Nil)
	oBrwN:oBrowse:Refresh()
Endif
//SysRefresh()

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241Limpa บAutor  ณ Marcelo da Cunha   บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para limpar filtro nos produtos                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241ProdLimpa(xPesq)
*********************************
If Empty(xPesq)
	dbSelectArea("SB1")
	dbClearFilter()
	RetIndex("SB1")    
//	MsFilter("B1_FILIAL='"+xFilial("SB1")+"'")
	MsFilter("B1_FILIAL='"+xFilial("SB1")+"' .and. B1_SITUACA = '1'")
	dbSetOrder(1)
	dbGotop()
	If (oBrwN <> Nil)
		oBrwN:oBrowse:Refresh()
	Endif
	//SysRefresh()		
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241Saldo บAutor  ณ Marcelo da Cunha   บ Data ณ  08/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar o saldo do produto                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241Saldo(xTipo)
*****************************
LOCAL aSegH := aClone(aHeader), aSegC := aClone(aCols), nNSeg := N
LOCAL cQuery := "", cDescricao := "", cProd := Space(15)
PRIVATE oDlgS := Nil, oGetS := Nil, oCanS := Nil

//Busco codigo do produto
/////////////////////////
If (xTipo == 1)
	cProd := SA7->A7_produto
Elseif (xTipo == 2)
	cProd := SB1->B1_cod
Endif
cDescricao := cProd+" - "+Alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC"))

//Define o aHeader
//////////////////
aHeader := {}
N := 1  // Incluido por Valdecir em 17.01.05.

Aadd(aHeader,{"Filial"           ,"B2_FILIAL"  ,"@K!"              ,02,0,"","๛","C","SB2",""})
Aadd(aHeader,{"Almoxarifado"     ,"B2_LOCAL"   ,"@K!"              ,02,0,"","๛","C","SB2",""})
Aadd(aHeader,{"Saldo Atual"      ,"B2_QATU"    ,"@E 999,999,999.99",14,2,"","๛","C","SB2",""})
Aadd(aHeader,{"Disponivel"       ,"B2_QATU2"   ,"@E 999,999,999.99",14,2,"","๛","C","SB2",""})
Aadd(aHeader,{"Qtda Prv.Entrar"  ,"B2_SALPEDI" ,"@E 9,999,999.9999",14,4,"","๛","C","SB2",""})
Aadd(aHeader,{"Qtda Reservada"   ,"B2_RESERVA" ,"@E 999,999,999.99",12,2,"","๛","C","SB2",""})
Aadd(aHeader,{"Ped.Venda Aberto" ,"B2_QPEDVEN" ,"@E 999,999,999.99",12,2,"","๛","C","SB2",""})
Aadd(aHeader,{"Qtda Empenhada"   ,"B2_QEMP"    ,"@E 9,999,999.9999",14,4,"","๛","C","SB2",""})
                    
//Monto Query para buscar saldos dos produtos
/////////////////////////////////////////////
cQuery := ""
cQuery += "SELECT B2_FILIAL,B2_LOCAL,B2_QPEDVEN,B2_QEMP,B2_SALPEDI,B2_RESERVA,B2_QATU "
cQuery += "FROM "+RetSqlName("SB2")+" (NOLOCK) WHERE D_E_L_E_T_ = '' AND B2_COD = '"+cProd+"' "
cQuery += "ORDER BY B2_FILIAL,B2_LOCAL "
If (Select("MB2") <> 0)
	dbSelectArea("MB2")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MB2"
TCSetField("MB2","B2_QPEDVEN",  "N",12,2)
TCSetField("MB2","B2_QEMP"   ,  "N",14,4)
TCSetField("MB2","B2_SALPEDI",  "N",14,4)
TCSetField("MB2","B2_RESERVA",  "N",12,2)
TCSetField("MB2","B2_QATU"   ,  "N",12,2) 

//Monta aCols e aHeader
///////////////////////
aCols := {}
dbSelectArea("MB2")
dbGotop()
While !Eof()
	Aadd(aCols,{MB2->B2_filial,MB2->B2_local,MB2->B2_qatu,MB2->B2_qatu-MB2->B2_reserva,MB2->B2_salpedi,MB2->B2_reserva,MB2->B2_qpedven,MB2->B2_qemp,.T.})
	dbSkip()
Enddo
If (Select("MB2") <> 0)
	dbSelectArea("MB2")
	dbCloseArea()
Endif
If Empty(aCols)
	MsgInfo(">>> Nao existe movimentacao para este produto!!!")
	aHeader := aClone(aSegH)
	aCols := aClone(aSegC)
	N := nNSeg
	Return
Endif


//Monta tela do MsGetDados
//////////////////////////
DEFINE MSDIALOG oDlgS TITLE OemToAnsi("Saldo do Produto: "+cDescricao) FROM 000,000 TO 320,655 OF oMainWnd PIXEL
oGetS := MsGetDados():New(005,005,125,325,2,"AllwaysTrue","AllwaysTrue","",.F.)
@ 134,205 BMPBUTTON TYPE 2 ACTION (Close(oDlgS))
ACTIVATE MSDIALOG oDlgS CENTERED

//Retorno dados do MsGetDados
/////////////////////////////
aHeader := aClone(aSegH)
aCols := aClone(aSegC)
N := nNSeg

Return