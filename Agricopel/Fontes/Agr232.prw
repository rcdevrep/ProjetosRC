#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGR232   บAutor  ณ Marcelo da Cunha   บ Data ณ  05/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Clientes Especifica (Agricopel)                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AGR232()
*******************
LOCAL cOper := TkOperador(), cFiltro := "", aSegSU7 := SU7->(GetArea()), lRetu := .F.

If SM0->M0_CODIGO <> "02"
	If (Posicione("SU7",1,xFilial("SU7")+cOper,"U7_VEND") == "1")
		lRetu := R232Tela()
	Else
	   lRetu := U_AGR231()
	Endif
Else                                                            
	DbSelectArea("SU7")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SU7")+cOper)
		If SU7->U7_AGENDA == "S"
			lRetu := R232Tela()		
		Else
		   lRetu := U_AGR231()		
		EndIf
	EndIf
   /*
	If (Posicione("SU7",1,xFilial("SU7")+cOper,"U7_AGENDA") == "S")
		lRetu := R232Tela()
	Else
	   lRetu := U_AGR231()
	Endif*/
EndIf

RestArea(aSegSU7)

Return (lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGR232   บAutor  ณ Marcelo da Cunha   บ Data ณ  05/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Clientes Especifica (Agricopel)                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232Tela()
************************
LOCAL cOper := TkOperador(), cFiltro := ""
PRIVATE oDlg  := Nil, oPesq := Nil, oBrw := Nil, oCmb := Nil
PRIVATE aSeg  := GetArea(), aIndice := {}, aCampos := {}
PRIVATE aRotina := {{"","",0 ,1},{"","",0,2}}, aTela[0][0], aGets[0][0]
PRIVATE cPesq := Space(100), cIndice := "", cCadastro := "", cVar := Alltrim(ReadVar())
PRIVATE nOpca := 0, nRecno := 0, lRetu := .F., lOk := .F.
PRIVATE bCodCli  := {|| Substr(SU6->U6_codent,1,6)}
PRIVATE bLojCli  := {|| Substr(SU6->U6_codent,7,2)}
   
//Busco valor informado
///////////////////////
//cPesq := &(ReadVar())
//cPesq := Alltrim(cPesq) + Space(100-Len(Alltrim(cPesq)))

//Seleciono indice de trabalho
//////////////////////////////
dbSelectArea("SU6")
If Empty(cPesq)
	dbSetOrder(6) //Por data de atendimento 
Endif    

//Filtro arquivo de agenda pelo operador
////////////////////////////////////////  
cFiltro := "(U6_OPERAD = '"+cOper+"').and.(U6_ENTIDA = 'SA1').and.(U6_STATUS = '1')"
MsFilter(cFiltro)

//Define o aCampos
//////////////////
aCampos := {}
AADD(aCampos,{"U6_DATA"          ,"Data"      ,"@D"})
//AADD(aCampos,{"U6_HRINI"         ,"Hora"      ,"@!"})
AADD(aCampos,{{||Eval(bCodCli)}  ,"Cliente"   ,"@R 999999"})
AADD(aCampos,{{||Eval(bLojCli)}  ,"Loja"      ,"@R 99"})
AADD(aCampos,{"U6_NOMECLI"       ,"Nome"      ,"@!"})
AADD(aCampos,{"U6_ESTADO"        ,"Estado"    ,"@!"})
AADD(aCampos,{"U6_DDD"           ,"DDD"       ,"@!"})
AADD(aCampos,{"U6_TELCLI"        ,"Telefone"  ,"@!"})
AADD(aCampos,{"U6_NOMECON"       ,"Contato"   ,"@!"})
AADD(aCampos,{"U6_CIDADE"        ,"Cidade"    ,"@!"})

//Busca indices do SU6
//////////////////////
dbSelectArea("SIX")
dbSeek("SU6",.T.)
While !Eof().and.(SIX->INDICE == "SU6") 
	Aadd(aIndice,Alltrim(SIX->descricao))
	If (SIX->ORDEM == "6")
		cIndice := Alltrim(SIX->descricao)
	Endif
	dbSkip()
Enddo 
               
//Monta tela
////////////
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Consulta de Cliente - Agenda 1") FROM 000,000 TO 465,765 OF oMainWnd PIXEL
@ 005,005 TO 200,380 BROWSE "SU6" FIELDS aCampos OBJECT oBrw
//oBrw:oBrowse:bLDblClick := { || (nOpca:=1,Close(oDlg))}
@ 206,005 SAY OemToAnsi("Pesquisar por:") SIZE 40,8
@ 205,045 COMBOBOX cIndice ITEMS aIndice SIZE 120,8 OBJECT oCmb
oCmb:Refresh(.F.)
oCmb:nAt := 6
oCmb:bChange := { || R232Pesquisa(Alltrim(cPesq),1)}
@ 221,005 SAY OemToAnsi("Localizar:") SIZE 40,8
@ 220,045 GET cPesq SIZE 120,8 VALID R232Pesquisa(Alltrim(cPesq),1) OBJECT oPesq
oPesq:SetFocus()
oPesq:bGotFocus := { || R232Limpa(Alltrim(cPesq)) }
@ 210,175 BMPBUTTON TYPE 1 ACTION (nOpca:=1,Close(oDlg))
@ 210,205 BMPBUTTON TYPE 2 ACTION (nOpca:=0,Close(oDlg))
@ 210,235 BMPBUTTON TYPE 15 ACTION (R232Visual(1))
@ 210,265 BMPBUTTON TYPE 14 ACTION (lOk:=R232Cliente(),iif(lOk,Close(oDlg),))
//ACTIVATE MSDIALOG oDlg ON INIT (R232Pesquisa(Alltrim(cPesq),2)) CENTERED
ACTIVATE MSDIALOG oDlg CENTERED
             
lRetu := (nOpca==1).or.(lOk)
                     
If (lRetu)
	If (!lOk)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+Substr(SU6->U6_codent,1,8),.T.)
		M->UA_agenda  := SU6->U6_lista+SU6->U6_codigo
		M->UA_proxlig := SU6->U6_data
	Else
		M->UA_agenda  := Space(12)
// Comentado por Valdecir e Deco		M->UA_proxlig := DataValida(dDatabase+7)
	Endif
Endif

//Limpo filtro no arquivo de lista
//////////////////////////////////
dbSelectArea("SU6")
RetIndex("SU6")
dbClearFilter()
dbGotop()

dbSelectArea("SA1")
nRecno := Recno()
RetIndex("SA1")
dbClearFilter()
RestArea(aSeg)           
SA1->(dbSetOrder(1))
SA1->(dbGoto(nRecno))

Return (lRetu)
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR232PesquisaบAutor  ณ Marcelo da Cunha บ Data ณ  07/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que realiza a pesquisa no Browse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232Pesquisa(xPesq,xOpc)
************************************
LOCAL cAux := ""
LOCAL nInd := 0, nPos := 0

dbSelectArea("SU6")
nInd := aScan(aIndice,Alltrim(cIndice))
If !Empty(nInd)
	dbSetOrder(nInd)
Endif

If (xOpc == 1)
	If Empty(xPesq)
	   //	dbSelectArea("SU6")
//		dbGotop()
	Else
		nPos := AT("/",xPesq)
		If !Empty(nPos)
			While !Empty(nPos)
				cAux += dtos(ctod(Substr(xPesq,nPos-2,8)))+Substr(xPesq,nPos+6)
				nPos := AT("/",cAux)
			Enddo
		Else
			cAux := Alltrim(xPesq)
		Endif
		dbSelectArea("SU6")  
		dbSeek(xFilial("SU6")+cAux,.T.)
	Endif
Elseif (xOpc == 2)
	dbSelectArea("SU6")  
	If Empty(M->UA_agenda)
		dbGotop()
	Else                                
		dbSetOrder(1)
		dbSeek(xFilial("SU6")+M->UA_agenda)
		nRecno := Recno()
		dbSetOrder(6)
		dbGoto(nRecno)
	Endif
Endif
	
If (oBrw <> Nil)
	oBrw:oBrowse:Refresh()
Endif

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR232IncluiบAutor  ณ Marcelo da Cunha   บ Data ณ  07/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para incluir os registros                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232Inclui()
***********************
//LOCAL nOK := 0, aSeg3 := GetArea()
//dbSelectarea("SA1")
//SETAPILHA()
//nOK := AxInclui("SA1")
//If (nOK == 1)
//	If (oBrw <> Nil)
//		oBrw:oBrowse:Refresh()
//	Endif
//Endif
//RestArea(aSeg3)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR232VisualบAutor  ณ Marcelo da Cunha   บ Data ณ  07/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para visualizar os registros                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232Visual(xOp)
****************************
LOCAL aSeg2 := GetArea()
If (xOp == 1)
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+Substr(SU6->U6_codent,1,8))
		AxVisual("SA1",Recno(),1,,,,)
	Endif
Elseif (xOp == 2)
	AxVisual("SA1",Recno(),1,,,,)
Endif
RestArea(aSeg2)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR232Limpa บAutor  ณ Marcelo da Cunha   บ Data ณ  07/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232Limpa(xPesq)
****************************
If Empty(xPesq)
	dbSelectArea("SU6")
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR232Clien บAutor  ณ Marcelo da Cunha   บ Data ณ  07/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232Cliente()
*************************
PRIVATE oDlg1  := Nil, oPesq1 := Nil, oBrw1 := Nil, oCmb1 := Nil
PRIVATE aCampos1 := {}, aIndice1 := {}
PRIVATE cPesq1 := Space(100), cIndice1:= "", cVar1 := Alltrim(ReadVar())
PRIVATE nOpcb := 0, nRecno1 := 0, __lRetu := .F.
                  
//Define o aCampos
//////////////////
aCampos1 := {}
AADD(aCampos1,{"A1_COD"   ,"Codigo"    ,"@!"})
AADD(aCampos1,{"A1_LOJA"  ,"Loja"      ,"@!"})
AADD(aCampos1,{"A1_NOME"  ,"Nome"      ,"@!"})
AADD(aCampos1,{"A1_CGC"   ,"Cnpj/Cpf"  ,"@R 999.999.999/9999-99"})
AADD(aCampos1,{"A1_DDD"   ,"DDD"  ,"@!"})
AADD(aCampos1,{"A1_TEL"   ,"Telefone"  ,"@!"})
AADD(aCampos1,{"A1_MUN"   ,"Municipio" ,"@!"})
AADD(aCampos1,{"A1_NREDUZ","N.Reduzido","@!"})


//Indice customizado
////////////////////
cIndice1 := "BUSCA PARCIAL POR DESCRICAO"
Aadd(aIndice1,cIndice1)

//Busca indices do SA1
//////////////////////
dbSelectArea("SIX")
dbSeek("SA1",.T.)
While !Eof().and.(SIX->INDICE == "SA1") 
	Aadd(aIndice1,Alltrim(SIX->descricao))
	dbSkip()
Enddo            

//Monta tela
////////////
DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Consulta de Clientes") FROM 000,000 TO 465,640 OF oMainWnd PIXEL
@ 005,005 TO 200,316 BROWSE "SA1" FIELDS aCampos1 OBJECT oBrw1
oBrw1:oBrowse:bLDblClick := { || (nOpcb:=1,Close(oDlg1))}
@ 206,005 SAY OemToAnsi("Pesquisar por:") SIZE 40,8
@ 205,045 COMBOBOX cIndice1 ITEMS aIndice1 SIZE 120,8 OBJECT oCmb1
oCmb1:Refresh(.F.)    
oCmb1:nAt := iif(Empty(cPesq1),1,2)
oCmb1:bChange := { || R232CliPesq(Alltrim(cPesq1))}
@ 221,005 SAY OemToAnsi("Localizar:") SIZE 40,8
@ 220,045 GET cPesq1 SIZE 120,8 VALID R232CliPesq(Alltrim(cPesq1)) OBJECT oPesq1
oPesq1:SetFocus()
oPesq1:bGotFocus := { || R232CliLimpa(Alltrim(cPesq1)) }
@ 210,175 BMPBUTTON TYPE 1 ACTION (nOpcb:=1,Close(oDlg1))
@ 210,205 BMPBUTTON TYPE 2 ACTION (nOpcb:=0,Close(oDlg1))
//@ 210,235 BMPBUTTON TYPE 4 ACTION (R232Inclui())
@ 210,235 BMPBUTTON TYPE 15 ACTION (R232Visual(2))
ACTIVATE MSDIALOG oDlg1 ON INIT (R232CliPesq(Alltrim(cPesq1)))CENTERED
             
__lRetu := iif(nOpcb==1,.T.,.F.)

//Posicione no arquivo de produtos
//////////////////////////////////
If (__lRetu)
	dbSelectArea("SA1")
	dbClearFilter()
	dbSetOrder(1)
	dbSelectArea("SU6")
	dbSetOrder(3) //Por cliente
	dbSeek(xFilial("SU6")+SA1->A1_cod+SA1->A1_loja,.T.)
Endif

If (oBrw <> Nil)
	oBrw:oBrowse:Refresh()
Endif

Return (__lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR232CliPesบAutor  ณ Marcelo da Cunha   บ Data ณ  06/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que realiza a pesquisa no Browse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232CliPesq(xPesq)
*******************************
LOCAL nInd := 0

If Empty(xPesq)
	dbSelectArea("SA1")
	RetIndex("SA1")
	dbClearFilter()
   dbSetOrder(1)
	dbGotop()
	If (oBrw1 <> Nil)
		oBrw1:oBrowse:Refresh()
	Endif
	Return (.T.)
ENdif

nInd := aScan(aIndice1,Alltrim(cIndice1))

If (nInd == 1)
  	dbSelectArea("SA1")
	dbClearFilter()
	RetIndex("SA1")    
	MsFilter("('"+Alltrim(xPesq)+"' $ A1_NOME)")
   dbSetOrder(1)
	dbGotop()
Else    
	dbSelectArea("SA1")
	dbClearFilter()
	RetIndex("SA1")    
	dbSetOrder(1)
	dbGotop()
	nInd--
	If !Empty(nInd)
		dbSelectArea("SA1")
		dbSetOrder(nInd)
		dbSeek(xFilial("SA1")+xPesq,.T.)
	Endif
Endif

If (oBrw1 <> Nil)
	oBrw1:oBrowse:Refresh()
Endif
        
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR232CliLimบAutor  ณ Marcelo da Cunha   บ Data ณ  07/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para buscar as ultimas notas                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R232CliLimpa(xPesq)
****************************
If Empty(xPesq)
	dbSelectArea("SA1")
	If (oBrw1 <> Nil)
		oBrw1:oBrowse:Refresh()
	Endif
Endif
Return