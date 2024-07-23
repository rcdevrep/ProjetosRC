//#include "rwmake.ch"
#include "protheus.ch"
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AGR540	³ Autor ³ Wagner Mobile Costa	   ³ Data ³ 20.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Income Statement                           			  	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       										   	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR540()
********************

LOCAL cString := "CT1"
LOCAL titulo  := ""
LOCAL aPergs  := {}

PRIVATE nLastKey 	:= 0
PRIVATE cPerg	 	:= "CTR540"
PRIVATE nomeProg 	:= "AGR540"

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

//Cria as perguntas
AGR540SX1()

If ! Pergunte(cPerg,.T.) .Or. ! ExistCpo("CTN", mv_par02)
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		        ³
//³ mv_par01				// Data referencia                		     ³
//³ mv_par02				// Configuracao de livros			           ³
//³ mv_par03				// Moeda?          			     	           ³
//³ mv_par04				// Usa Data referencia ou periodo De Ate*
//³ mv_par05				// Periodo De            				        ³
//³ mv_par06				// Periodo Ate     			     	           ³ 
//³ mv_par07				// Folha Inicial    			     	           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par04 == 2  //Por periodo
	dInicio  	:= mv_par05
	dFinal		:= mv_par06                              
	dPeriodo0	:= CtbPeriodos(mv_par03,dInicio,dFinal,.F.,.F.)[1][2]
	titulo 		:= "INCOME STATEMENT" + " de " + dToc(dInicio) + " até " + dToc(dFinal)
Else //Por referencia
	dInicio  	:= Ctod("01/" + Subs(Dtoc(mv_par01), 4))
	dFinal		:= mv_par01
	dPeriodo0 	:= Ctod(Str(Day(LastDay(mv_par01)), 2) + "/" + Subs(Dtoc(mv_par01), 4))
	//titulo 		:= "INCOME STATEMENT"
	titulo 		:= "INCOME STATEMENT" + " de " + dToc(dInicio) + " até " + dToc(dFinal)
EndIf	
wnrel 		:= "AGR540"            //Nome Default do relatorio em Disco

MsgRun("Gerando relatorio, aguarde...","",{|| CursorWait(),Ctr500Cfg(@titulo,"Agr540Det","Incoment Statement",.F.) ,CursorArrow()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Agr540Det ³ Autor ³ Simone Mie Sato       ³ Data ³ 28.06.01 ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Detalhe do Relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Agr540Det(ExpO1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ParC1 = Titulo do relatorio                                ³±±
±±³          ³ ParC2 = Titulo da caixa do processo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AGR540Det(oPrint,i,titulo,cProcesso,lLandScape)
*********************************************************
Local lin 			:= 2811
Local cArqTmp
Local lRet 			:= .T.
Local cSeparador	:= "", cChave := ""
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local aTotal 		:= {}, nTotal, nTotMes, nTotAtu
Local aColunas		:= {}, nColuna
Local nTotRec     := 0, nTotPer := 0
Local cSegFil     := cFilAnt
Local aSM0        := {}

Private aSetOfBook	:= CTBSetOf(mv_par02)
Private aCtbMoeda		:= {}

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

//If mv_par04 == 2
	aSetOfBook[10] += " de " + dToc(dInicio) + " até " + dToc(dFinal)
//EndIf

Titulo		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], Titulo)		// Titulo definido SetOfBook
cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)

cPicture 	:= aSetOfBook[4]
If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 15		// Bops 59240
	cPicture := ""
Endif 
cPicture := "@E 9999,999,999.99"  // Alterado devido estouro de campo  Deco 10/01/2005

m_pag	:= mv_par07

//Busco acumulado
/////////////////               
aAcumulado := {} ; dPerAux := dPeriodo0
For _l := 1 to Month(dFinal)
	dIni := ctod("01/"+Strzero(_l,2)+"/"+Strzero(Year(dFinal),4))
	dFim := ctod(Strzero(Day(LastDay(dIni)))+"/"+Strzero(_l,2)+"/"+Strzero(Year(dFinal),4))
	If (dFim > dFinal)
		dFim := dFinal    
	Endif
	dPeriodo0 := CtbPeriodos(mv_par03,dIni,dFim,.F.,.F.)[1][2]
	If (Select("cArqTmp") <> 0)
		dbSelectArea("cArqTmp")
		dbCloseArea()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Arquivo Temporario para Impressao							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dIni,dFim,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
				"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
				"1",aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30))},;
				"Criando Arquivo Temporario...", cProcesso) //"Criando Arquivo Temporario..."
		  
	//Alimento matriz com acumulado
	///////////////////////////////
	dbSelectArea("cArqTmp")
	dbGoTop()
	While ! Eof()
		nPos := aScan(aAcumulado, { |x| x[1] = CONTA })
		If Empty(nPos)
			Aadd(aAcumulado,{CONTA,0})
			nPos := Len(aAcumulado)
		Endif
		//aAcumulado[nPos,2] += SALDOPER
		aAcumulado[nPos,2] += (SALDOATU - SALDOANT)
		dbSkip()
	Enddo
	
Next _l            
dPeriodo0 := dPerAux
If (Select("cArqTmp") <> 0)
	dbSelectArea("cArqTmp")
	dbCloseArea()
Endif
/////////////////

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dInicio,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
				"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
				"1",aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30))},;
				"Criando Arquivo Temporario...", cProcesso) //"Criando Arquivo Temporario..."
                                  
dbSelectArea("cArqTmp")
dbGoTop()
While ! Eof()     
	nPos := aScan(aAcumulado, { |x| x[1] = CONTA })
	If !Empty(nPos)
		Reclock("cArqTmp",.F.)
		SALDOPER := aAcumulado[nPos,2]
		MsUnlock("cArqTmp")
	Endif
	Aadd(aColunas, Recno())
	If IDENTIFI = "4"
		nTotal := Ascan(aTotal, { |x| x[1] = CONTA })
		If nTotal = 0
			Aadd(aTotal, { CONTA, 0, 0 })
			nTotal := Len(aTotal)
		Endif
		aTotal[nTotal][2] += SALDOPER
		aTotal[nTotal][3] += SALDOATU - SALDOANT
	Endif          
	If (Alltrim(CONTA) == "RECVEN")
		nTotRec += (SALDOATU - SALDOANT)
		nTotPer += (SALDOPER)
	Endif
	DbSkip()
EndDo
If Len(aTotal) = 0
	aTotal := { {"", 0, 0 }}
Endif

For nColuna := 1 To Len(aColunas)
	MsGoto(aColunas[nColuna])

	If lin > 2810		
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,2350 )   	// horizontal                          			
		EndIf	
		i++                                                
		oPrint:EndPage() 	 	 				// Finaliza a pagina
		CtbCbcDem(oPrint,titulo,lLandScape)		// Funcao que monta o cabecalho padrao 
		Agr540Esp(oPrint, cDescMoeda)			// Cabecalho especifico do CTBR500
		lin := 304        
		lFirstPage := .F.		
	End
    
	If DESCCTA = "-"
		oPrint:Line(lin,150,lin,2350)   	// horizontal
	Else
		nTotal := Ascan(aTotal, { |x| x[1] = SUPERIOR })
		If Empty(SUPERIOR) .Or. IDENTIFI = "4"
			nTotMes := SALDOPER
			nTotAtu := SALDOATU - SALDOANT
		ElseIf nTotal = 0
			nTotMes := nTotAtu := 0
		Else
			nTotMes := aTotal[nTotal][2]
			nTotAtu := aTotal[nTotal][3]
		Endif

		oPrint:Line( lin,150,lin+50, 150 )   	// vertical

		oPrint:Say(lin+15,165,DESCCTA, 	If(IDENTIFI = "4", oArial08N,;
										If(IDENTIFI $ "36", oCouNew08N, oFont08)))

// Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)


		oPrint:Line(lin,1350,lin+50,1350 )   	// Separador vertical 
		If IDENTIFI < "5"
			ValorCTB(SALDOATU - SALDOANT,lin+15,1410,15,0,.T.,cPicture,;
					 NORMAL, CONTA,.T.,oPrint, "P",IDENTIFI)
					 
			//oPrint:Say(Lin + 15,1730,Trans(((SALDOATU - SALDOANT) / nTotAtu) * 100, "@E 999.99"),oFont08)
			If (SALDOATU < SALDOANT)
				oPrint:Say(Lin + 15,1730,Trans(((SALDOATU - SALDOANT) / nTotRec) * -100, "@E 9999.99"),oFont08)
			Else
				oPrint:Say(Lin + 15,1730,Trans(((SALDOATU - SALDOANT) / nTotRec) * 100, "@E 9999.99"),oFont08)
			Endif
		Endif

		oPrint:Line(lin,1720,lin+50,1720)   	// Separador vertical 
		oPrint:Line(lin,1860,lin+50,1860)   	// Separador vertical 

		If IDENTIFI < "5"
			ValorCTB(SALDOPER,lin+15,1910,15,0,.T.,cPicture, NORMAL,CONTA,.T.,oPrint,"P",IDENTIFI)
			//oPrint:Say(Lin + 15,2210,Trans((SALDOPER / nTotMes) * 100, "@E 999.99"),oFont08)
			If (SALDOPER >= 0)
				oPrint:Say(Lin + 15,2210,Trans((SALDOPER / nTotPer) * 100, "@E 9999.99"),oFont08)
			Else
				oPrint:Say(Lin + 15,2210,Trans((SALDOPER / nTotPer) * -100, "@E 9999.99"),oFont08)
			Endif
		Endif
		oPrint:Line(lin,2190,lin+50,2190)   	// Separador vertical 
		oPrint:Line(lin,2350,lin+50,2350)   	// Separador vertical
		lin +=47

	Endif

	nTraco := lin + 1
Next
oPrint:Line(lin,150,lin,2350)   	// horizontal

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
±±³Funcao    ³AGR540ESP ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho Especifico do relatorio CTBR041.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AGR540ESP(ParO1,ParC1)			                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpC1 = Descricao da moeda sendo impressa                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AGR540Esp(oPrint,cDescMoeda)
****************************************

oPrint:Line(250,150,300,150)   	// vertical

//If mv_par04 == 2
	oPrint:Say(260,1490,"Periodo ",oArial10)
	oPrint:Say(260,1755,"% ",oArial10)

	oPrint:Say(260,1950,"Acumulado",oArial10) 
	oPrint:Say(260,2240,"% ",oArial10)
/*
Else
	oPrint:Say(260,1450,"Mes " + Subs(Dtoc(mv_par01), 4),oArial10)
	oPrint:Say(260,1755,"% Tot",oArial10)

	oPrint:Say(260,1980,Dtoc(mv_par01),oArial10)  
	oPrint:Say(260,2235,"% Tot",oArial10)
EndIf
*/

oPrint:Line(250,2350,300,2350)   	// vertical
oPrint:Line(300,150,300,2350)   	// horizontal

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR540SX1    ³Autor ³  Simone Mie Sato     ³Data³ 05/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria as perguntas ref. o relatorio CTBR420.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGR540SX1()
************************

Local aArea 	:= GetArea()
Local aPergs	:= {}
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

Local nTamCta	:= Len(CriaVar("CT1_CONTA"))
Local nTamCC	:= Len(CriaVar("CTT_CUSTO"))
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamClVl	:= Len(CriavAr("CTH_CLVL"))


//Grupo de perguntas do relatorio Razao Conta/Doc.Fiscal(CTR540)
aPergs 		:= {}    

aHelpPor	:= {} 
aHelpEng	:= {}	
aHelpSpa	:= {}

Aadd(aHelpPor,"Tipo de checagem dos resultados.")			
Aadd(aHelpPor,"Checagem por data de referencia ")
Aadd(aHelpPor,"ou por periodo")

Aadd(aHelpEng,"Results mode check.")
Aadd(aHelpEng,"Check by referency date or period.")

Aadd(aHelpSpa,"Tipo de verificacion de los resultados.")
Aadd(aHelpSpa,"Verificacion por fecha de referencia")
Aadd(aHelpspa,"o periodo.")                             

Aadd(aPergs,{  "Considera          ?","¨Considera         ?","Consider           ?","mv_ch4","N",1,0,0,"C","","mv_par04","Data Referencia","Fecha Referencia","Referency Date","","","Perido","Periodo","Periodo","","","","","","","","","","","","","","","","","","","S","",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {} 
aHelpEng	:= {}	
aHelpSpa	:= {}
Aadd(aHelpPor,"Data do inicio do periodo.")				//Portugues
Aadd(aHelpEng,"Initial period date.")					//Ingles
Aadd(aHelpSpa,"Fecha inicio del perido.")				//Espanhol
Aadd(aPergs,{  "Periodo De         ?","¨De Periodo        ?","From Period        ?","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S","",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {} 
aHelpEng	:= {}	
aHelpSpa	:= {}
Aadd(aHelpPor,"Data final do periodo.")					//Portugues
Aadd(aHelpEng,"Final Period date.")						//Ingles
Aadd(aHelpSpa,"Fecha final del periodo.")				//Espanhol
Aadd(aPergs,{  "Periodo Ate        ?","¨Ate Periodo       ?","To Period          ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","S","",aHelpPor,aHelpEng,aHelpSpa})

Aadd(aPergs,{"Folha Inicial      ?","¨Pagina Inicial    ?","Initial Page       ?","mv_ch7","N",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1("CTR540",aPergs)

RestArea(aArea)

Return

Static Function A540Acumulado(xArqTmp)
**********************************
LOCAL dIni := ctod("//"), dFim := ctod("//")
LOCAL _l := 1

dIni := ctod("01/"+Strzero(_l,2)+"/"+Strzero(Year(dFinal),2))
dFim := ctod(Strzero(Day(LastDay(dIni)))+"/"+Strzero(_l,2)+"/"+Strzero(Year(dFinal),2))
If (dFim > dFinal)
	dFim := dFinal    
Endif

//Alimento arquivo mestre com valores acumulados
////////////////////////////////////////////////
dbSelectArea(xArqTmp)
dbGotop()
While !Eof()

	//Busco o saldo das contas
	//////////////////////////
	nValor := 0
	/*
	dbSelectArea("CT2")
	dbSetOrder(1)
	dbSeek(xFilial("CT2")+dtos(dIni),.T.)
	While !Eof().and.
	
	
		dbSelectArea("CT2")
		dbSkip()
	Enddo	  
	*/
	        
	//Gravo acumulado
	/////////////////
	dbSelectArea(xArqTmp)
	Reclock(xArqTmp,.F.)
	SALDOPER := nValor
	MsUnlock(xArqTmp)
	dbSkip()
Enddo  

Return