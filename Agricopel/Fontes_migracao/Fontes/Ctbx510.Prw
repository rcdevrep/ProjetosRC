#INCLUDE "ctbr510.ch"
#Include "PROTHEUS.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ Ctbx510	³ Autor ³ Wagner Mobile Costa	 ³ Data ³ 15.10.01 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Demonstracao de Resultados                 			  	   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum													   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Ctbx510() 

LOCAL cString		:= "CT1"
Local titulo 		:= ""                                           

PRIVATE nLastKey 	:= 0
PRIVATE cPerg	 	:= "CTR510"
PRIVATE nomeProg 	:= "CTBX510"  

SetPrvt("i,titulo,cProcesso,lLandScape")

CTR510SX1()

If ! CtrVld500(cPerg)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		³
//³ mv_par01				// Exercicio contabil             		³
//³ mv_par02				// Configuracao de livros				³
//³ mv_par03				// Moeda?          			     	    ³
//³ mv_par04				// Posicao Ant. L/P? Sim / Nao         	³
//³ mv_par05				// Data Lucros/Perdas?                 	³
//³ mv_par06				// Dem. Periodo Anterior?               ³
//³ mv_par07				// Folha Inicial        ?             	³
//³ mv_par08				// Data de Referencia   ?             	³
//³ mv_par09				// Considera ? (Calendario/Periodo)   	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par09 == 1												/// SE DEVE CONSIDERAR TODO O CALENDARIO
	If Empty(mv_par08)
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		dFinal	:= mv_par08
	EndIf
	dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	mv_par01    := dFinal
Else															/// SE DEVE CONSIDERAR O PERIODO CONTABIL
	If Empty(mv_par08)
		MsgInfo(STR0007,STR0008)//"É necessário informar a data de referência !"#"Parametro Considera igual a Periodo."
		Return
	Endif
    
	dFinal := mv_par08
	dFinalA	:= CTOD("  /  /  ")
	dbSelectArea("CTG")
	dbSetOrder(1)
	MsSeek(xFilial("CTG")+mv_par01,.T.)
	While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
		If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
			dFinalA	:= CTG->CTG_DTINI
			Exit
		Endif
		CTG->(DbSkip())
	EndDo
    
	If Empty(dFinalA)
		MsgInfo(STR0009,STR0010)//"Data fora do calendário !"#"Data de referência."
		Return
	Endif
Endif
*
* Para Gerar em Disco
*
Limite   := 132
cString  :="CT2"
cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o relatorio")
cDesc2   := OemToAnsi("de Demonstrativo de Resultados")
cDesc3   := ""
nChar    := 18
cTamanho := "M"

aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
cNomeProg:= "CTBX510"
aLinha   := {}
nLastKey := 0

Titulo   := "Demonstrativo Resultado"
cCabec1  := ""
cCabec2  := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1        //Variavel que acumula numero da pagina
wnrel    := "CTBX510" //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif
SET PRINTER TO "CTBX510.##R"  // VERIFICAR DEOC
SET DEVICE TO PRINT
#IFDEF WINDOWS
  RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   RptStatus({|| Execute(RptDetail)})
  Return
  // Funcao Linha Detalhe do Relatorio
// Substituido pelo assistente de conversao do AP5 IDE em 29/09/00 ==>   Function RptDetail
Static Function RptDetail()
#ENDIF
//RptStatus({|lEnd| Ctr510Det(@lEnd,wnrel,cString)},Titulo)
//RptStatus({|lEnd| Ctr510Det(oPrint,i,titulo,cProcesso,lLandScape)})
//RptStatus({|| Ctr510Det()})
//Return

wnrel 		:= "CTBX510"            //Nome Default do relatorio em Disco
titulo 		:= STR0001 //"DEMONSTRACAO DE RESULTADOS"



MsgRun(	STR0002,"",; //"Gerando relatorio, aguarde..."
		{|| CursorWait(), Ctr500Cfg(@titulo, "Ctr510Det", STR0001, .F.) ,CursorArrow()}) //"Demonstracao de resultados"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em Disco, chama Spool.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If aReturn[5] == 1
     Set Printer To 
     dbCommitAll()
     ourspool(wnrel)
//Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctr510Det ³ Autor ³ Simone Mie Sato       ³ Data ³ 28.06.01 ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Detalhe do Relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr510Det(ExpO1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ParC1 = Titulo do relatorio                                ³±±
±±³          ³ ParC2 = Titulo da caixa do processo                        ³±±
±±³          ³ ParL1 = Indica se imprime em Paisagem (.T.) ou Retrato .F. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr510Det(oPrint,i,titulo,cProcesso,lLandScape)
//Static Function RptDetail(oPrint,i,titulo,cProcesso,lLandScape)
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local lin 			:= 2811
Local cArqTmp
Local lRet 			:= .T.
Local cSeparador	:= ""
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo
Local nTamLin		:= 2350
Local aPosCol		:= { 1800, 2075 }

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

Titulo		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], Titulo)		// Titulo definido SetOfBook
cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)

cPicture 	:= aSetOfBook[4]
If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

m_pag := mv_par07
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dFinalA+1,dFinal,"","", "",Repl("Z", Len(CT1->CT1_CONTA)),;
			"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
			"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
			"1",aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30),,,,,;
			mv_par04 = 1, mv_par05)},STR0006, cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")           
dbGoTop()

While ! Eof()

	If lin > 2810		
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
		EndIf	
		i++                                                
		oPrint:EndPage() 	 								// Finaliza a pagina
		CtbCbcDem(oPrint,titulo,lLandScape)					// Funcao que monta o cabecalho padrao 
		If mv_par06 == 2									// Demonstra periodo anterior = Nao
			Ctr510Atu(oPrint, cDescMoeda,aPosCol,nTamLin)	// Cabecalho de impressão do Saldo atual.
		Else
			Ctr510Esp(oPrint, cDescMoeda,aPosCol,nTamLin)
		EndIf
		lin := 304        
		lFirstPage := .F.		
	End
    
	If DESCCTA = "-"
		oPrint:Line(lin,150,lin,nTamLin)   	// horizontal
	Else

		oPrint:Line( lin,150,lin+50, 150 )   	// vertical

// Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)

		oPrint:Say(lin+15,195,DESCCTA, If(IDENTIFI $ "3469", oCouNew08N, oFont08))

		
		For nPosCol := 1 To Len(aPosCol)
			If mv_par06 == 2 .And. nPosCol == 1
				aPosCol := {2075}
			Else
				aPosCol	:= { 1800, 2075 }	           
			EndIf
			oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical 
    	  
    		If IDENTIFI < "5"
    			If mv_par06 == 1 .Or. (mv_par06 == 2 .And. nPosCol == 1)
				    nSaldo := If(nPosCol = 1, SALDOATU, SALDOANT)
				       
		            ValorCTB(nSaldo,lin+15,aPosCol[nPosCol] + 5,15,0,.T.,cPicture,;
					NORMAL,CONTA,.T.,oPrint, "P",IDENTIFI)
				EndIf					 
			Endif 
			
		Next

		oPrint:Line(lin,nTamLin,lin+50,nTamLin)   	// Separador vertical
		lin +=47

	Endif

	nTraco := lin + 1
	DbSkip()
EndDo
oPrint:Line(lin,150,lin,nTamLin)   	// horizontal

lin += 10

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	
dbselectArea("CT2")

Return lin


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTR500ESP ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho Especifico do relatorio CTBR041.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTR500ESP(ParO1,ParC1)			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpC1 = Descricao da moeda sendo impressa                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR510Esp(oPrint,cDescMoeda,aPosCol,nTamLin)

Local cColuna  		:= "(Em " + cDescMoeda + ")"
Local aCabecalho    := { Dtoc(dFinal, "ddmmyyyy"), Dtoc(dFinalA, "ddmmyyyy") }
Local nPosCol                                                                     

oPrint:Line(250,150,300,150)   	// vertical

oPrint:Say(260,195,cColuna,oArial10)

For nPosCol := 1 To Len(aCabecalho)
	oPrint:Say(260,aPosCol[nPosCol] + 30,aCabecalho[nPosCol],oArial10)
Next

oPrint:Line(250,nTamLin,300,nTamLin)   	// vertical

oPrint:Line(300,150,300,nTamLin)   	// horizontal

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTR510SX1    ³Autor ³  Lucimara Soares     ³Data³ 23/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria as perguntas do relatorio                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTR510SX1()

Local aPergs 		:= {}    

aHelpPor	:= {} 
aHelpEng	:= {}	
aHelpSpa	:= {}

Aadd(aHelpPor,"Informe se deseja imprimir o")			
Aadd(aHelpPor,"saldo do periodo anterior ao ")
Aadd(aHelpPor,"solicitado")

Aadd(aHelpEng,"Inform here whether you want")
Aadd(aHelpEng,"the balance of the previous")
Aadd(aHelpEng,"period to be printed.")

Aadd(aHelpSpa,"Informe se desea imprimir el")
Aadd(aHelpSpa,"saldo del periodo anterior.")
   
Aadd(aPergs,{"Dem. Periodo Anterior?","Previous Period?","Dem. Periodo Anterior?","mv_ch6","N",1,0,0,"C",,"mv_par06","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","",""})                    
Aadd(aPergs,{"Folha Inicial      ?","¨Pagina Inicial    ?","Initial Page       ?","mv_ch7","N",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Data Referencia    ?","¨Fecha Referencia  ?","Reference Date     ?","mv_ch8","D",8,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Periodo    ?"		   ,"¨Periodo  ?"		  ,"Period     ?"		 ,"mv_ch9","N",1,0,0,"C","","mv_par09","Calendario","Calendario","Calendar","","","Periodo","Periodo","Period","","","","","","","","","","","","","","","","","",""})

AjustaSx1("CTR510",aPergs) 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTR510ATU ³ Autor ³ Lucimara Soares       ³ Data ³ 03.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho para impressao apenas da coluna de Saldo Atual.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTR510ESP(ParO1,ParC1)			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpC1 = Descricao da moeda sendo impressa                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR510ATU(oPrint,cDescMoeda,aPosCol,nTamLin)

Local cColuna  		:= "(Em " + cDescMoeda + ")"
Local aCabecalho    := { Dtoc(dFinal, "ddmmyyyy") }
Local nPosCol       := 1

oPrint:Line(250,150,300,150)   	// vertical

oPrint:Say(260,195,cColuna,oArial10)

oPrint:Say(260,aPosCol[nPosCol+1] + 30,aCabecalho[nPosCol],oArial10)


oPrint:Line(250,nTamLin,300,nTamLin)   	// vertical

oPrint:Line(300,150,300,nTamLin)   	// horizontal

Return Nil  
