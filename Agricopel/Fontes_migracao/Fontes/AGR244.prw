#INCLUDE "RWMAKE.CH"
#INCLUDE "AGR244.CH"
//#INCLUDE "FIVEWIN.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR244  ³ Autor ³ Wagner Xavier         ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faturamento por Cliente                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AGR244(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcello     ³28/08/00³oooooo³Impressao de casas decimais de acordo   ³±±
±±³              ³        ³      ³com a moeda selecionada.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR244()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL aOrd    := {}
LOCAL titulo     := OemToAnsi(STR0001)  //"Faturamento por Cliente"
LOCAL cDesc1     := OemToAnsi(STR0002)	//"Este relatorio emite a relacao de faturamento. Podera ser"
LOCAL cDesc2     := OemToAnsi(STR0003)	//"emitido por ordem de Cliente ou por Valor (Ranking).     "
LOCAL cDesc3     := OemToAnsi(STR0004)	//"Se no TES estiver gera duplicata (N), nao sera computado."
LOCAL tamanho    := "M"
LOCAL limite     := 132


PRIVATE aReturn  := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE aCodCli  := {}
PRIVATE aLinha   := {}
PRIVATE nomeprog := "AGR244"
PRIVATE cPerg    := "AGR244"
PRIVATE nLastKey := 0
PRIVATE CbTxt    := Space(10)
PRIVATE wnrel    := "AGR244"
PRIVATE cString  := "SF2"
PRIVATE LEND     := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
li       := 80
m_pag    := 01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Ajusta grupo de perguntas
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//AjustaSx1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg   :="AGR244"
aRegistros := {}

AADD(aRegistros,{cPerg,"01","Data de           	?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Data ate          	?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Cliente de        	?","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"04","Cliente ate       	?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"05","Estado de         	?","mv_ch5","C",2,0,0,"G","","mv_par05","","","","","","","","","","","","","","","12"})
AADD(aRegistros,{cPerg,"06","Estado ate        	?","mv_ch6","C",2,0,0,"G","","mv_par06","","","","","","","","","","","","","","","12"})
AADD(aRegistros,{cPerg,"07","Lista Por  		?","mv_ch7","N",1,0,2,"C","","mv_par07","Cliente","","","Ranking","","","Estado","","","","","","","",""})
AADD(aRegistros,{cPerg,"08","Moeda             	?","mv_ch8","N",1,0,1,"C","","mv_par08","1a Moeda","","","2a Moeda","","","3a Moeda","","","4a Moeda","","","5a Moeda","",""})
AADD(aRegistros,{cPerg,"09","Inclui Devolucao   ?","mv_ch9","N",1,0,1,"C","","mv_par09","Sim","","","Nao","","","Por N.F.","","","","","","","",""})
AADD(aRegistros,{cPerg,"10","TES Qto Faturamento?","mv_chA","N",1,0,3,"C","","mv_par10","Gera Financeiro","","","Nao Gera","","","Considera Ambos","","","","","","","",""})
AADD(aRegistros,{cPerg,"11","TES Qto Estoque	?","mv_chB","N",1,0,3,"C","","mv_par11","Movimenta","","","Nao Movimenta","","","Considera Ambos","","","","","","","",""})
AADD(aRegistros,{cPerg,"12","Abatimento 		?","mv_chC","N",1,0,1,"C","","mv_par12","Sim","","","Nao","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"13","Vendedor de       	?","mv_chD","C",6,0,0,"G","","mv_par13","","","","","","","","","","","","","","","VEN"})
AADD(aRegistros,{cPerg,"14","Vendedor ate      	?","mv_chE","C",6,0,0,"G","","mv_par14","","","","","","","","","","","","","","","VEN"})
aadd(aRegistros,{cPerg,"15","Salta pag.p/Repr.  ?","mv_chF","N",1,0,0,"C","","mv_par15","Sim","","","Nao","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        // Data de                  		         ³
//³ mv_par02        // Data ate  					       		 ³
//³ mv_par03        // Cliente de                                ³
//³ mv_par04 	    // Cliente ate                               ³
//³ mv_par05	    // Estado de                                 ³
//³ mv_par06	    // Estado ate                                ³
//³ mv_par07	    // Cliente  Valor  Estado                    ³
//³ mv_par08	    // Moeda                                     ³
//³ mv_par09        // Devolucao				                 ³
//³ mv_par10        // Duplicatas  			                     ³
//³ mv_par11        // Estoque   				                 ³
//³ mv_par12        // Abatimento  				                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel  := "AGR244"
wnrel  := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey==27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C590Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C590IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGR244  		                                       	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C590Imp(lEnd,WnRel,cString)

LOCAL titulo   := OemToAnsi(STR0001)
LOCAL cDesc1   := OemToAnsi(STR0002)
LOCAL cDesc2   := OemToAnsi(STR0003)
LOCAL cDesc3   := OemToAnsi(STR0004)
LOCAL cEstoq   := If( (MV_PAR11== 1),"S",If( (MV_PAR11== 2),"N","SN" ) )
LOCAL cDupli   := If( (MV_PAR10== 1),"S",If( (MV_PAR10== 2),"N","SN" ) )
LOCAL nAbto    := MV_PAR12
LOCAL cPict	   := ""
LOCAL CbTxt    := ""
LOCAL CbCont   := ""
LOCAL cabec1   := "" 
LOCAL cabec2   := ""
LOCAL cCliente := ""
LOCAL cLoja    := ""
LOCAL cEst     := ""
LOCAL cMoeda   := ""
LOCAL tamanho  := "M"
LOCAL limite   := 132
LOCAL nRank    := 0
LOCAL nMoeda   := 0
LOCAL nAg1     := 0
LOCAL nAg2     := 0
LOCAL nAg3     := 0
LOCAL nAg4     := 0
LOCAL nAg5     := 0
LOCAL nAg6     := 0
LOCAL nValor1  := 0
LOCAL nValor2  := 0
LOCAL nValor3  := 0
LOCAL nValor4  := 0
LOCAL nValor5  := 0
LOCAL nValor6  := 0
LOCAL nEstV1   := 0
LOCAL nEstV2   := 0
LOCAL nEstV3   := 0
LOCAL nEstV4   := 0
LOCAL nEstV5   := 0
LOCAL nEstV6   := 0
LOCAL aCampos  := {}
LOCAL aTam	   := {}

PRIVATE nDecs:=msdecimais(mv_par08)

cPict	:= "@E) 99,999,999,999" + IIf(nDecs > 0,"."+replicate("9",nDecs),"")

nTipo:=IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 00
li       := 80
m_pag    := 01

nMoeda := mv_par08
cMoeda := GetMv("MV_MOEDA"+Ltrim(STR(nMoeda)))

IF mv_par07 = 1
	titulo := OemToAnsi(STR0007)+cmoeda 	//"FATURAMENTO POR CLIENTE  (CODIGO) - "
ElseIf mv_par07 == 2
	titulo := OemToAnsi(STR0008)+cmoeda		//"FATURAMENTO POR CLIENTE  (RANKING) - "
Else
	titulo := OemToAnsi(STR0009)+cmoeda		//"FATURAMENTO POR CLIENTE  (ESTADO) - "
EndIF

cabec1 := OemToAnsi(STR0010)	//"CODIGO/LOJA               RAZAO SOCIAL                                   FATURAMENTO          VALOR DA             VALOR RANKING"
cabec2 := OemToAnsi(STR0011)	//"                                                                             SEM ICM        MERCADORIA             TOTAL"
// 999999xxxxxxxxxxxxxx/XXxx XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999,999,999.99 99,999,999,999.99 99,999,999,999.99    9999 DEV
//           1         2         3         4         5         6         7         8         9         10        11        12        13
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901


// Incluido por Valdecir. 
// Devera ser retirado ao final da alteracao.
mv_par09 := 2
mv_par12 := 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria array para gerar arquivo de trabalho                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("F2_VEND1")
AADD(aCampos,{ "TB_VEND"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_CLIENTE")
AADD(aCampos,{ "TB_CLI"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_LOJA")
AADD(aCampos,{ "TB_LOJA"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("A1_EST")
AADD(aCampos,{ "TB_EST"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_EMISSAO")
AADD(aCampos,{ "TB_EMISSAO","D",aTam[1],aTam[2] } )
AADD(aCampos,{ "TB_VALOR1 ","N",18,nDecs } )		// Valores de Faturamento
AADD(aCampos,{ "TB_VALOR2 ","N",18,nDecs } )
AADD(aCampos,{ "TB_VALOR3 ","N",18,nDecs } )
AADD(aCampos,{ "TB_VALOR4 ","N",18,nDecs } )		// Valores para devolucao
AADD(aCampos,{ "TB_VALOR5 ","N",18,nDecs } )
AADD(aCampos,{ "TB_VALOR6 ","N",18,nDecs } )
AADD(aCampos,{ "TB_RANKIN ","N",18 } )        // Ranking conforme Valor faturamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := CriaTrab(aCampos)
dbUseArea( .T.,, cNomArq,cNomArq, if(.T. .OR. .F., !.F., NIL), .F. )
cNomArq1 := SubStr(cNomArq,1,7)+"1"
cNomArq2 := SubStr(cNomArq,1,7)+"2"
cNomArq3 := SubStr(cNomArq,1,7)+"3"

IndRegua(cNomArq,cNomArq1,"TB_VEND+TB_CLI+TB_LOJA",,,OemToAnsi(STR0012))	//"Selecionando Registros..."

dbSelectArea("SF2")
dbSetOrder(2)

SetRegua(RecCount())		// Total de Elementos da regua
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao para gerar arquivo de Trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if mv_par09 == 3
	cKey:="D1_FILIAL+D1_SERIORI+D1_NFORI+D1_FORNECE+D1_LOJA"
	cFiltro :="D1_FILIAL=='"+xFilial("SD1")+"'.And.!Empty(D1_NFORI)"
	cFiltro += ".And. !("+IsRemito(2,"SD1->D1_TIPODOC")+")"		

	#IFDEF SHELL
		cFiltro += '.And. D1_CANCEL <> "S"'
	#ENDIF
	IndRegua("SD1",cNomArq3,cKey,,cFiltro,OemToAnsi(STR0012))	//"Selecionando Registros..."
	nIndex:=RetIndex("SD1")
	#IFNDEF TOP
		dbSetIndex(cNomArq3+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbGotop()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de trabalho.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTrab(cEstoq,cDupli,nMoeda)

If mv_par09 == 1
	dbSelectArea("SF1")
	dbSetOrder(2)
	IncRegua()
	GeraTrab1(cEstoq,cDupli,nMoeda)
Endif

dbSelectArea(cNomArq)
dbClearIndex()

IndRegua(cNomArq,cNomArq2,"TB_VEND+StrZero(1000000000000 - TB_VALOR3 + TB_VALOR6,18,2)",,,"Indexando Ranking")
dbGoTop()
nRank:=1
While !Eof()

	cVendRank := TB_VEND
	While !Eof().and.(cVendRank == TB_VEND)
		RecLock(cNomArq,.F.)
			Replace TB_RANKIN With nRank
		MsUnlock()
		nRank++
		dbSkip()
	Enddo
	nRank := 1
		
Enddo
nRank:=0

dbClearIndex()

If mv_par07 == 1	
	IndRegua(cNomArq,cNomArq1,"TB_VEND+TB_CLI+TB_LOJA",,,"Indexando por Vend Cliente Loja")
ElseIf mv_par07 == 2
//	IndRegua(cNomArq,cNomArq2,"TB_VEND+StrZero(1000000000000 - TB_VALOR3 + TB_VALOR6,18,nDecs)",,,OemToAnsi(STR0012))
	IndRegua(cNomArq,cNomArq2,"TB_VEND+StrZero(TB_RANKIN,6)",,,"Indexando por Vend Ranking")
Else
	IndRegua(cNomArq,cNomArq1,"TB_VEND+TB_EST+TB_CLI+TB_LOJA",,,"Indexando por Vend Est Cliente Loja")
Endif

dbSelectArea(cNomArq)
dbGoTop()

While !Eof()
	IncRegua()
	
	If lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0013)	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If (Li > 55).or.(mv_par15 == 1)
		If (Li != 80)                              
	   		Roda(cbcont,cbtxt,tamanho)
	   	Endif
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		Li := 9
   Endif	

   cVend  := TB_VEND
   cRepre := Alltrim(Posicione("SA3",1,xFilial("SA3")+cVend,"A3_NOME"))
   @ Li,000 PSAY "Vendedor: "+cVend+" - "+cRepre
   Li++
   @ Li,000 PSAY Replicate("-",220)
   Li++

	nTotVen1 := 0
	nTotVen2 := 0
	nTotVen3 := 0		

	nTotUF1 := 0
	nTotUF2 := 0
	nTotUF3 := 0

	lPrim := .T.
	cEst  := ""	
	dbSelectArea(cNomArq)
	While !Eof().and.(cVend == TB_VEND)
	
		If mv_par07 == 3
		
			If Empty(cEst)
				cEst := TB_EST
			ElseIf cEst != TB_EST
				lPrim := .T.			
				li++
				@li, 00 PSAY OemToAnsi(STR0014) + cEst + "--->"	//"Total do Estado de "
				@li, 67 PSAY nTotUF1		PicTure cPict
				@li, 85 PSAY nTotUF2		PicTure cPict
				@li,103 PSAY nTotUF3		PicTure cPict

				nTotUF1 := 0
				nTotUF2 := 0
				nTotUF3 := 0
				
				If nEstv4+nEstv5+nEstv6!=0
					li++
					@li, 67 PSAY nEstV4		PicTure cPict
					@li, 85 PSAY nEstV5		PicTure cPict
					@li,103 PSAY nEstV6		PicTure cPict
					@li,129 PSAY "DEV"
					If nAbto == 1
						li++
						@li, 67 PSAY nEstV1+nEstV4  PICTURE cPict
						@li, 85 PSAY nEstV2+nEstV5  PICTURE cPict
						@li,103 PSAY nEstV3+nEstV6  PICTURE cPict
						@li,129 PSAY "ABT"
					Endif
				Endif
				cEst := TB_EST
				li++
				nEstV1:=0
				nEstV2:=0
				nEstV3:=0
				nEstV4:=0
				nEstV5:=0
				nEstV6:=0
				li++
			EndIf
			
			If lPrim     
				lPrim := .F.
				@ li,00 PSAY OemToAnsi(STR0015) + cEst 	//"Estado: "
				li++
			Endif
			
		EndIf
		
		cCliente := TB_CLI
		cLoja    := TB_LOJA
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+cCliente+cLoja)

   	If (Li > 55)            
   		If (Li != 80)
   			Roda(cbcont,cbtxt,tamanho)
   		Endif
	     	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      	Li := 8
   	Endif
		
		@li,00 PSAY SA1->A1_COD + "/"+ SA1->A1_LOJA
		@li,26 PSAY Substr(SA1->A1_NOME,1,40)
		
		dbSelectArea(cNomArq)
		
		nValor1:= TB_VALOR1
		nValor2:= TB_VALOR2
		nValor3:= TB_VALOR3
		nValor4:= TB_VALOR4
		nValor5:= TB_VALOR5
		nValor6:= TB_VALOR6
		
		nValor4*=(-1)
		nValor5*=(-1)
		nValor6*=(-1)
		
		@li, 67 PSAY nValor1  PICTURE cPict
		@li, 85 PSAY nValor2  PICTURE cPict
		@li,103 PSAY nValor3  PICTURE cPict

/*		
		IF mv_par07 = 1
			nRank:=TB_RANKIN
//			@li,124 PSAY nRank	PICTURE "9999"
			@li,124 PSAY TRANSFORM(nRank,"9999")
		ELSEIF mv_par07 = 2
		  //	nRank++
//			@li,124 PSAY nRank	PICTURE "9999"
			@li,124 PSAY TRANSFORM(TB_RANKIN,"9999")
		EndIF
  */

		@li,124 PSAY TRANSFORM(TB_RANKIN,"9999")  		
		
		If nValor4+nValor5+nValor6!=0	
			li++                      

	   	If (Li > 55)            
	   		If (Li != 80)
	   			Roda(cbcont,cbtxt,tamanho)
	   		Endif
		     	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      	Li := 8
	   	Endif
			
			@li, 67 PSAY nValor4  PICTURE cPict
			@li, 85 PSAY nValor5  PICTURE cPict
			@li,103 PSAY nValor6  PICTURE cPict
			@li,129 PSAY "DEV"
			If nAbto == 1
				li++
				
		   	If (Li > 55)            
		   		If (Li != 80)
		   			Roda(cbcont,cbtxt,tamanho)
		   		Endif
			     	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		      	Li := 8
		   	Endif
				
				@li, 67 PSAY nValor1+nValor4  PICTURE cPict
				@li, 85 PSAY nValor2+nValor5  PICTURE cPict
				@li,103 PSAY nValor3+nValor6  PICTURE cPict
				@li,129 PSAY "ABT"
			Endif
		Endif
		
		nEstV1+= nValor1
		nEstV2+= nValor2
		nEstV3+= nValor3
		nEstV4+= nValor4
		nEstV5+= nValor5
		nEstV6+= nValor6
		
		li++
		
		nAg1 += nValor1
		nAg2 += nValor2
		nAg3 += nValor3
		nAg4 += nValor4
		nAg5 += nValor5
		nAg6 += nValor6     
		
		nTotVen1 := nTotVen1 + TB_VALOR1
		nTotVen2 := nTotVen2 + TB_VALOR2
		nTotVen3 := nTotVen3 + TB_VALOR3

		nTotUF1 := nTotUF1 + TB_VALOR1
		nTotUF2 := nTotUF2 + TB_VALOR2
		nTotUF3 := nTotUF3 + TB_VALOR3

		dbSelectarea(cNomArq)
		dbSkip()
	Enddo	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@Li,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Li > 55)            
		If (Li != 80)
			Roda(cbcont,cbtxt,tamanho)
		Endif
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		Li := 8
	Endif
                   
	If mv_par07 == 3
	
		li++
		@li, 00 PSAY OemToAnsi(STR0014) + cEst + "--->"
		@li, 67 PSAY nTotUF1		PicTure cPict
		@li, 85 PSAY nTotUF1		PicTure cPict
		@li,103 PSAY nTotUF1		PicTure cPict
		
		If (nEstV4+nEstV5+nEstV6)!=0
			li++
			@li, 67 PSAY nEstV4		PicTure cPict
			@li, 85 PSAY nEstV5		PicTure cPict
			@li,103 PSAY nEstV6		PicTure cPict
			@li,129 PSAY "DEV"
			If nAbto == 1
				li++
				@li, 67 PSAY nEstV1+nEstV4  PICTURE cPict
				@li, 85 PSAY nEstV2+nEstV5  PICTURE cPict
				@li,103 PSAY nEstV3+nEstV6  PICTURE cPict
				@li,129 PSAY "ABT"
			Endif
		Endif
		
		li:=li + 2
	EndIf
	
	li++	
	@li, 00 PSAY OemToAnsi("T O T A L  D O  V E N D E D O R --->")	//"T O T A L --->"
	@li, 67 PSAY nTotVen1	PicTure cPict
	@li, 85 PSAY nTotVen2	PicTure cPict
	@li,103 PSAY nTotVen3	PicTure cPict
	
	If (nAg4+nAg5+nAg6)!=0
		li++
		@li, 67 PSAY nAg4		PicTure cPict
		@li, 85 PSAY nAg5		PicTure cPict
		@li,103 PSAY nAg6		PicTure cPict
		@li,129 PSAY "DEV"
		If nAbto == 1
			li++
			@li, 67 PSAY nAg1+nAg4  PICTURE cPict
			@li, 85 PSAY nAg2+nAg5  PICTURE cPict
			@li,103 PSAY nAg3+nAg6  PICTURE cPict
			@li,129 PSAY "ABT"
		Endif
	Endif
	
	dbselectarea(cNomArq)		
EndDo
/*
IF li != 80
	If mv_par07 == 3
		li++
		@li, 00 PSAY OemToAnsi(STR0014) + cEst + "--->"
		@li, 67 PSAY nTotUF1		PicTure cPict
		@li, 85 PSAY nTotUF2		PicTure cPict
		@li,103 PSAY nTotUF3		PicTure cPict
		
		If (nEstV4+nEstV5+nEstV6)!=0
			li++
			@li, 67 PSAY nEstV4		PicTure cPict
			@li, 85 PSAY nEstV5		PicTure cPict
			@li,103 PSAY nEstV6		PicTure cPict
			@li,129 PSAY "DEV"
			If nAbto == 1
				li++
				@li, 67 PSAY nEstV1+nEstV4  PICTURE cPict
				@li, 85 PSAY nEstV2+nEstV5  PICTURE cPict
				@li,103 PSAY nEstV3+nEstV6  PICTURE cPict
				@li,129 PSAY "ABT"
			Endif
		Endif
		
		li:=li + 2
	EndIf
	*/
	li := li + 4
	@li, 00 PSAY OemToAnsi("T O T A L  G E R A L --->")	//"T O T A L --->"
	@li, 67 PSAY nAg1		PicTure cPict
	@li, 85 PSAY nAg2		PicTure cPict
	@li,103 PSAY nAg3		PicTure cPict
	
	If (nAg4+nAg5+nAg6)!=0
		li++
		@li, 67 PSAY nAg4		PicTure cPict
		@li, 85 PSAY nAg5		PicTure cPict
		@li,103 PSAY nAg6		PicTure cPict
		@li,129 PSAY "DEV"
		If nAbto == 1
			li++
			@li, 67 PSAY nAg1+nAg4  PICTURE cPict
			@li, 85 PSAY nAg2+nAg5  PICTURE cPict
			@li,103 PSAY nAg3+nAg6  PICTURE cPict
			@li,129 PSAY "ABT"
		Endif
	Endif
	
	roda(cbcont,cbtxt,tamanho)
	
//EndIF

dbSelectArea(cNomArq)
dbCloseArea()

cDelArq := cNomArq+GetDBExtension()

If File(cDelArq)
	fErase(cDelArq)
Endif
fErase(cNomArq1+OrdBagExt())
If mv_par07 <> 3
	Ferase(cNomarq2+OrdBagExt())
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par09 == 3
	dbSelectArea("SD1")
	Set Filter To
	RetIndex()
	fErase(cNomArq3+OrdBagExt())
	dbSetOrder(1)
Endif

dbSelectArea("SF2")
Set Filter To
dbSetOrder(1)
dbSelectArea("SD2")
dbSetOrder(1)

SET DEVICE TO SCREEN

SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

If aReturn[5] == 1
	dbCommitAll()
	Set Printer TO
	ourspool(wnrel)
Endif
MS_FLUSH()
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraTrab  ³ Autor ³ Wagner Xavier         ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GeraTrab()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GeraTrab(cEstoq,cDupli,nMoeda)

Local cChaven    := ""
Local nTOTAL     := 0
Local nVALICM    := 0
Local nVALIPI    := 0
Local ImpNoInc   := 0    
Local nImpInc    := 0    
Local nTB_VALOR1 := 0
Local nTB_VALOR2 := 0
Local nTB_VALOR3 := 0
Local aImpostos	 := {}
Local lAvalTes   := .F.
LOCAL aVend := {"SA1->A1_VEND","SA1->A1_VEND2","SA1->A1_VEND3"}, aAchou := {}

Private cCampImp

dbSelectArea("SF2")
dbSeek(xFilial()+mv_par03,.T.)

While !Eof() .And. xFilial()=SF2->F2_FILIAL .And.;
	SF2->F2_CLIENTE <= mv_par04
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek ( xFilial() + SF2->F2_CLIENTE+SF2->F2_LOJA )
	dbSelectArea("SF2")
	
	#IFDEF SHELL
		If SF2->F2_CANCEL == "S"
			SF2->(dbSkip())
			Loop
		Endif
	#ENDIF
	
	If IsRemito(1,"SF2->F2_TIPODOC")
		dbSkip()
		Loop
	Endif	
	
	IF SF2->F2_EMISSAO < mv_par01 .Or. SF2->F2_EMISSAO > mv_par02 .Or.;
		SA1->A1_EST 	 < mv_par05 .Or. SA1->A1_EST     > mv_par06
		dbSkip()
		Loop
	EndIF
	
	If At(SF2->F2_TIPO,"DB") != 0
		Dbskip()
		Loop
	Endif
	
	IncRegua()
	
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial()+SF2->F2_DOC+SF2->F2_SERIE)
	nTOTAL 		:=0
	nVALICM		:=0
	nVALIPI		:=0
	nImpNoInc	:=0
	nImpInc  	:=0
	lAvalTes    := .F.
	While !Eof() .And. xFilial()==SD2->D2_FILIAL .And.;
		SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
		
		#IFDEF SHELL
			If SD2->D2_CANCEL == "S" .Or. !(Substr(SD2->D2_CF,2,2)$"12|73|74")
				SD2->(dbSkip())
				Loop
			Endif
		#ENDIF
		
		dbSelectArea("SF4")
		dbSeek(xFilial()+SD2->D2_TES)
		
		dbSelectArea("SD2")
		
		If AvalTes(D2_TES,cEstoq,cDupli)
			
			lAvalTes := .T.
			
			If cPaisLoc <> "BRA" .and. Type("SF2->F2_TXMOEDA")#"U"
				nTOTAL  += xMoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
			Else
				nTOTAL  += xMoeda(SD2->D2_TOTAL,1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
			Endif
			If ( cPaisLoc=="BRA")
				nVALICM += xMoeda(SD2->D2_VALICM,1,nMoeda,SF2->F2_EMISSAO)
				nVALIPI += xMoeda(SD2->D2_VALIPI,1,nMoeda,SF2->F2_EMISSAO)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquiso pelas caracteristicas de cada imposto               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aImpostos:=TesImpInf(SD2->D2_TES)
				For nY:=1 to Len(aImpostos)
					cCampImp:="SD2->"+(aImpostos[nY][2])
					If ( aImpostos[nY][3]=="1" )
						nImpInc 	+= xMoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
					Else
						nImpNoInc 	+= xmoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
					Endif
				Next
			EndIf
		Endif
		
		dbSelectArea("SD2")
		dbSkip()
	EndDo
	
	dbSelectArea("SF2")
	
	If lAvalTes
		nTOTAL  += xMoeda(SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_DESPESA,1,nMoeda,SF2->F2_EMISSAO)
	Endif
	
	If nTOTAL > 0
		For _i := 1 to 3
			cVend    := &("SF2->F2_VEND"+Str(_i,1,0))		
			nPos := aScan(aAchou,cVend)			
			If Empty(nPos)
				Aadd(aAchou,cVend)			 		
				If !Empty(cVend).and.(cVend >= mv_par13).and.(cVend <= mv_par14)				
					dbSelectArea(cNomArq)
					If dbSeek(cVend+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
						RecLock(cNomArq,.F.)
					Else
						RecLock(cNomArq,.T.)
						Replace TB_VEND	   With cVend
						Replace TB_CLI     With SF2->F2_CLIENTE
						Replace TB_LOJA    With SF2->F2_LOJA
					EndIF
					Replace TB_EST     With SA1->A1_EST
					Replace TB_EMISSAO With SF2->F2_EMISSAO
					
					nTB_VALOR2 := IIF(SF2->F2_TIPO == "P",0,nTOTAL)
					If ( cPaisLoc=="BRA" )
						nTB_VALOR1 := nTOTAL-nVALICM
						nTB_VALOR3 := IIF(SF2->F2_TIPO == "P",0,nTOTAL);
						+ nVALIPI+xMoeda(SF2->F2_ICMSRET+SF2->F2_FRETAUT,1,nMoeda,SF2->F2_EMISSAO)
					Else
						nTB_VALOR1 := nTOTAL-nImpNoInc
						nTB_VALOR3 := IIF(SF2->F2_TIPO == "P",0,nTOTAL)+ nImpInc+xMoeda(SF2->F2_FRETAUT,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
					EndIf
					
					Replace TB_VALOR1  With TB_VALOR1+ nTB_VALOR1
					Replace TB_VALOR2  With TB_VALOR2+ nTB_VALOR2
					Replace TB_VALOR3  With TB_VALOR3+ nTB_VALOR3
				EndIf		
			EndIf
		Next _i
		aAchou := {}
			
		// Sergio Fuzinaka - 16.10.01
		If Ascan( aCodCli, SF2->F2_CLIENTE+SF2->F2_LOJA ) == 0
			Aadd( aCodCli, SF2->F2_CLIENTE+SF2->F2_LOJA )
		Endif
		
		MsUnlock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Devolucao ref a Nota Fiscal posicionada                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par09 == 3
			GravaDev(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,nMoeda,cEstoq,cDupli)
		Endif
	Endif
	
	dbSelectArea("SF2")
	dbSkip()
EndDo

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraTrab1 ³ Autor ³ Adriano Sacomani      ³ Data ³ 09.08.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GeraTrab1)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GeraTrab1(cEstoq,cDupli,nMoeda)
Local nTOTAL     := 0
Local nVALICM    := 0
Local nVALIPI    := 0
Local nImpNoInc  := 0
Local nImpInc    := 0
Local nTB_VALOR4 := 0
Local nTB_VALOR5 := 0
Local nTB_VALOR6 := 0
Local aImpostos	 := {}
Local lAvalTes   := .F.

dbSeek(xFilial()+mv_par03,.T.)
While !Eof() .And. xFilial()==F1_FILIAL .And. F1_FORNECE <= mv_par04
	
	#IFDEF SHELL
		If SF1->F1_CANCEL == "S"
			SF1->(dbSkip())
			Loop
		Endif
	#ENDIF
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek( xFilial() + SF1->F1_FORNECE + SF1->F1_LOJA)
	dbSelectArea("SF1")
	
	If IsRemito(1,"SF1->F1_TIPODOC")
		dbSkip()
		Loop
	Endif
		
	If SF1->F1_DTDIGIT < mv_par01 .Or. SF1->F1_DTDIGIT > mv_par02 .Or.;
		SA1->A1_EST     < mv_par05 .Or. SA1->A1_EST     > mv_par06
		dbSkip()
		Loop
	EndIf
	
	If SF1->F1_TIPO != "D"
		Dbskip()
		Loop
	Endif
	
	IncRegua()
	
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	nTOTAL 		:=0.00
	nVALICM		:=0.00
	nVALIPI		:=0.00
	nImpNoInc	:=0.00
	nImpInc 	:=0.00
	lAvalTes    := .F.
	
	dbSelectArea("SF4")
	dbSeek(xFilial()+SD1->D1_TES)
	dbSelectArea("SD1")
	
	While !Eof() .and. xFilial()==SD1->D1_FILIAL .And.;
		SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
		SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		
		If SD1->D1_TIPO != "D"
			dbSkip()
			Loop
		Endif
		
		#IFDEF SHELL
			If SD1->D1_CANCEL == "S"
				SD1->(dbSkip())
				Loop
			Endif
		#ENDIF
		
		dbSelectArea("SF4")
		dbSeek(xFilial()+SD1->D1_TES)
		dbSelectArea("SD1")
		
		If AvalTes(D1_TES,cEstoq,cDupli)
			
			lAvalTes := .T.
			
			nTOTAL  +=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,nMoeda,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
			
			If ( cPaisLoc=="BRA" )
				nVALICM += xMoeda(SD1->D1_VALICM,1,nMoeda,SF1->F1_DTDIGIT)
				nVALIPI += xMoeda(SD1->D1_VALIPI,1,nMoeda,SF1->F1_DTDIGIT)
			Else
				aImpostos:=TesImpInf(SD1->D1_TES)
				For nY:=1 to Len(aImpostos)
					cCampImp:="SD1->"+(aImpostos[nY][2])
					If ( aImpostos[nY][3]=="1" )
						nImpInc 	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
					Else
						nImpNoInc	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
					Endif
				Next
			Endif
			
		Endif
		
		dbSelectArea("SD1")
		dbSkip()
	EndDo
	
	dbSelectArea("SF1")
	
	If lAvalTes == .T.
		nTOTAL  += xMoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,1,nMoeda,SF1->F1_DTDIGIT)
	Endif
	
	If nTOTAL > 0
		dbSelectArea(cNomArq)
		If dbSeek(SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
			RecLock(cNomArq,.F.)
		Else
			RecLock(cNomArq,.T.)
			Replace TB_CLI     With SF1->F1_FORNECE
			Replace TB_LOJA	 With SF1->F1_LOJA
		EndIf
		Replace TB_EST     With SA1->A1_EST
		Replace TB_EMISSAO With SF1->F1_EMISSAO
		
		nTB_VALOR5 := nTOTAL
		
		If ( cPaisLoc=="BRA")
			nTB_VALOR4 := nTOTAL-nVALICM
			nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF1->F1_ICMSRET,1,nMoeda,SF1->F1_DTDIGIT)
		Else
			nTB_VALOR4 := nTOTAL-nImpNoInc
			nTB_VALOR6 := nTotal + nImpInc
		Endif
		
		Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
		Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
		Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
	Endif
	
	dbSelectArea("SF1")
	dbSkip()
	
Enddo

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaDev  ³Revisor³Alexandre Inacio Lemes ³ Data ³ 27/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava item da devolucao ref a nota fiscal posicionada.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GravaDev                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GravaDev(cNumOri,cSerieOri,cClienteOri,cLojaOri,nMoeda,cEstoq,cDupli)
Local cNum        := ""
Local cSerie      := ""
Local cFornece    := ""
Local cLoja       := ""
Local cNumDocNfe  := ""
Local nX          := 0
Local nTOTAL      := 0
Local nVALICM     := 0
Local nVALIPI     := 0
Local nImpNoInc   := 0
Local nImpInc     := 0
Local nTB_VALOR4  := 0
Local nTB_VALOR5  := 0
Local nTB_VALOR6  := 0
Local aImpostos   := {}
Local aNotDev     := {}
Local lAvalTes    := .F.

dbSelectArea("SD1")
dbSetOrder(nIndex+1)
If dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)
	
	cNumDocNfe := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	
	Aadd( aNotDev, cNumDocNfe )
	
	Do While !Eof() .And. xFilial()==SD1->D1_FILIAL .And. cSerieOri+cNumOri+cClienteOri+cLojaOri;
		== SD1->D1_SERIORI+SD1->D1_NFORI+SD1->D1_FORNECE+SD1->D1_LOJA
		
		If cNumDocNfe <> SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			If Ascan( aCodCli, SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) == 0
				Aadd( aNotDev, SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
				cNumDocNfe := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			Endif
		Endif
		
		dbSelectArea("SD1")
		dbSkip()
	Enddo
	
	dbSelectArea("SD1")
	dbSetOrder(nIndex+1)
	dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)
	
	For nX :=1 to Len(aNotDev)
		
		dbSelectArea("SD1")
		cNum		:=D1_DOC
		cSerie	    :=D1_SERIE
		cFornece	:=D1_FORNECE
		cLoja		:=D1_LOJA
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek( xFilial() + cFornece + cLoja)
		dbSelectArea("SF1")
		dbSetOrder(1)
		
		If dbSeek(aNotDev[nX])
			
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek(aNotDev[nX])
			
			dbSelectArea("SF1")
			dbSetOrder(1)
			If SF1->F1_DTDIGIT < mv_par01 .Or. SF1->F1_DTDIGIT > mv_par02 .Or.;
				SA1->A1_EST < mv_par05 .Or. SA1->A1_EST > mv_par06 .Or. SF1->F1_TIPO != "D"
				SD1->(dbSkip())
				Loop
			EndIf
			
			If IsRemito(1,"SF1->F1_TIPODOC")
				dbSkip()
				Loop
			Endif

			#IFDEF SHELL
				If SF1->F1_CANCEL == "S"
					SD1->(dbSkip())
					Loop
				Endif
			#ENDIF
			
			nTOTAL 		:=0.00
			nVALICM		:=0.00
			nVALIPI		:=0.00
			nImpNoInc	:=0.00
			nImpInc 	:=0.00
			lAvalTes    := .F.
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD1->D1_TES)
			dbSelectArea("SD1")
			
			While !Eof() .and. xFilial()==SD1->D1_FILIAL .And.SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
				
				If SD1->D1_TIPO != "D"
					dbSkip()
					Loop
				Endif
				
				If IsRemito(1,"SD1->D1_TIPODOC")
					dbSkip()
					Loop
				Endif

				#IFDEF SHELL
					If SD1->D1_CANCEL == "S"
						SD1->(dbSkip())
						Loop
					Endif
				#ENDIF
				
				dbSelectArea("SF4")
				dbSeek(xFilial()+SD1->D1_TES)
				
				If AvalTes(SD1->D1_TES,cEstoq,cDupli)
					
					lAvalTes := .T.
					
					dbSelectArea(cNomArq)
					nTOTAL  +=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,nMoeda,TB_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
					If ( cPaisLoc=="BRA" )
						nVALICM += xMoeda(SD1->D1_VALICM,1,nMoeda,TB_EMISSAO)
						nVALIPI += xMoeda(SD1->D1_VALIPI,1,nMoeda,TB_EMISSAO)
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Pesquiso pelas caracteristicas de cada imposto               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aImpostos:=TesImpInf(SD1->D1_TES)
						For nY:=1 to Len(aImpostos)
							cCampImp:="SD1->"+(aImpostos[nY][2])
							If ( aImpostos[nY][3]=="1" )
								nImpInc 	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,TB_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
							Else
								nImpNoInc	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,TB_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
							EndIf
						Next
					EndIf
					
				Endif
				
				dbSelectArea("SD1")
				dbSkip()
			EndDo
			
			dbSelectArea("SF1")
			If lAvalTes == .T.
				nTOTAL  += xMoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,1,nMoeda,SF1->F1_EMISSAO)
			Endif
			
			If nTOTAL > 0
				dbSelectArea(cNomArq)
				If dbSeek(SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
					RecLock(cNomArq,.F.)
				Else
					RecLock(cNomArq,.T.)
					Replace TB_CLI     With SF1->F1_FORNECE
					Replace TB_LOJA	 With SF1->F1_LOJA
				EndIf
				
				Replace TB_EST     With SA1->A1_EST
				Replace TB_EMISSAO With SF1->F1_EMISSAO
				
				nTB_VALOR5 := nTOTAL
				If ( cPaisLoc=="BRA" )
					nTB_VALOR4 := nTOTAL-nVALICM
					nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF1->F1_ICMSRET,1,nMoeda,SF1->F1_DTDIGIT)
				Else
					nTB_VALOR4 := nTOTAL-nImpInc
					nTB_VALOR6 := nTotal+nImpInc
				Endif
				
				Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
				Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
				Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
			EndIf
			
		Endif
		
	Next nX
	
endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³Eduardo J. Zanardo     ³ Data ³05/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acerta o arquivo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION AjustaSx1()
Local aArea := GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

RestArea(aArea)

Aadd( aHelpPor, "Informe se imprime a  abatimento        " )
Aadd( aHelpPor, "referente a devolução.					 " )
Aadd( aHelpPor, "										 " )

Aadd( aHelpEng, "                                        " )
Aadd( aHelpEng, "                                        " )
Aadd( aHelpEng, "                                        " )

Aadd( aHelpSpa, "                                        " )
Aadd( aHelpSpa, "                                        " )
Aadd( aHelpSpa, "                                        " )

PutSx1("AGR244","12","Abatimento ?","Descuento ?","Discount ?","mv_chc","N",1,0,1,"C","","","","","mv_par12","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return

Static Function CriaPergunta(cGrupo,aPer)

	LOCAL lRetu := .T., aReg  := {}
	LOCAL _l := 1, _m := 1, _k := 1
	
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

Return (lRetu)

