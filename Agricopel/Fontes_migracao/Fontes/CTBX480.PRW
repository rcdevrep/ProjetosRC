#Include "CTBR480.Ch"
#Include "PROTHEUS.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBX480  ³ Autor ³ Simone Mie Sato       ³ Data ³ 02.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Razao por Item Contabil                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBX480                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CTBX480(cItemIni, cItemFim, dDataIni, dDataFim, cMoeda, cSaldo,;
			cBook, cContaIni, cContaFim, lCusto, cCustoIni, cCustoFim, lCLVL,;
			cCLVLIni, cCLVLFim)

Local aCtbMoeda		:= {}
Local WnRel			:= "CTBX480" 
Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")
Local cDesc1		:= STR0001 + Alltrim(cSayItem)	//"Este programa ira imprimir o Razao por "
Local cDesc2		:= STR0002	//" de acordo com os parametros sugeridos pelo usuario. "
Local cString		:= "CT2"
Local titulo		:= STR0006 + Alltrim(cSayItem)	//"Emissao do Razao Contabil por Item"
Local lRet			:= .T.
Local nTamLinha	:= 220
Local lExterno		:= cItemIni <> Nil

Default lCusto		:= .F.
Default lCLVL		:= .F.

Private aReturn		:= { STR0004, 1,STR0005, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private nomeprog	:= "CTBX480"
Private aLinha		:= {}
Private nLastKey	:= 0
Private cPerg		:= "CTR480"
Private Tamanho	:= "G"

/*
If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf
*/

If !lExterno
	If ! Pergunte("CTR480", .T. )
		Return
	Endif
Else
	Pergunte("CTR480", .F.)
Endif
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Do Item Contabil                      ³
//³ mv_par02            // Ate o Item Contabil                   ³
//³ mv_par03            // da data                               ³
//³ mv_par04            // Ate a data                            ³
//³ mv_par05            // Moeda			                     ³   
//³ mv_par06            // Saldos		                         ³   
//³ mv_par07            // Set Of Books                          ³
//³ mv_par08            // Analitico ou Resumido dia (resumo)    ³
//³ mv_par09            // Imprime conta sem movimento?          ³
//³ mv_par10            // Imprime Cod (Normal / Reduzida)       ³
//³ mv_par11            // Totaliza tb por Conta?                ³
//³ mv_par12            // Da Conta                              ³
//³ mv_par13            // Ate a Conta                           ³
//³ mv_par14            // Imprime Centro de Custo?		         ³	
//³ mv_par15            // Do Centro de Custo                    ³
//³ mv_par16            // Ate o Centro de Custo                 ³
//³ mv_par17            // Imprime Classe de Valor?              ³	
//³ mv_par18            // Da Classe de Valor                    ³
//³ mv_par19            // Ate a Classe de Valor                 ³
//³ mv_par20            // Salta folha por Item?                 ³
//³ mv_par21            // Pagina Inicial                        ³
//³ mv_par22            // Pagina Final                          ³
//³ mv_par23            // Numero da Pag p/ Reiniciar            ³	   
//³ mv_par24            // Imprime Cod. CCusto(Normal/Reduzido)  ³
//³ mv_par25            // Imprime Cod. Item (Normal/Reduzido)   ³
//³ mv_par26            // Imprime Cod. Cl.Valor(Normal/Reduzido)³	   	   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAnalitico	:= Iif(mv_par08 == 1,.T.,.F.)
Tamanho		:= If( lAnalitico, Tamanho, "M")
nTamLinha	:= If( lAnalitico, 220, 132)

wnrel := SetPrint(cString,wnrel,If (!lExterno,cPerg,),@titulo,cDesc1,cDesc2,,.F.,"",,Tamanho)

//Verifica se o relatorio foi chamado a partir de outro programa. Ex. CTBC480
If !lExterno
	lCusto	:= Iif(mv_par14 == 1,.T.,.F.)
	lCLVL	:= Iif(mv_par17 == 1,.T.,.F.)
Else //Caso seja externo, atualiza os parametros do relatorio com os dados passados como parametros.
	mv_par01 := cItemIni
	mv_par02 := cItemFim
	mv_par03 := dDataIni
	mv_par04 := dDataFim
	mv_par05 := cMoeda
	mv_par06 := cSaldo
	mv_par07 := cBook
	mv_par12 := cContaIni
	mv_par13 := cContaFim
	mv_par14 := If(lCusto =.T.,1,2)
	mv_par15 := cCustoIni
	mv_par16 := cCustoFim
	mv_par17 := If(lClVl =.T.,1,2)
	mv_par18 := cClVlIni
	mv_par19 := cClVlFim
Endif	

lAnalitico	:= Iif(mv_par08 == 1,.T.,.F.)
Tamanho		:= If( lAnalitico, Tamanho, "M")
nTamLinha	:= If( lAnalitico, 220, 132)

If nLastKey = 27
	Set Filter To
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books -> Conf. da Mascara / Valores   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Ct040Valid(mv_par07)
	lRet := .F.
Else
	aSetOfBook := CTBSetOf(mv_par07)
EndIf

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par05)
   If Empty(aCtbMoeda[1])
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif

If !lRet	
	Set Filter To
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR480Imp(@lEnd,wnRel,cString,aSetOfBook,lCusto,lCLVL,;
		lAnalitico,Titulo,nTamlinha,aCtbMoeda,cSayCusto,cSayItem,cSayClVl)})
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTR480Imp ³ Autor ³ Simone Mie Sato       ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Razao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³Ctr480Imp(lEnd,wnRel,cString,aSetOfBook,lCusto,;            ³±±
±±³           ³          lCLVL,lAnalitico,Titulo,nTamLinha,aCtbMoeda)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd       - A‡ao do Codeblock                             ³±±
±±³           ³ wnRel      - Nome do Relatorio                             ³±±
±±³           ³ cString    - Mensagem                                      ³±±
±±³           ³ aSetOfBook - Array de configuracao set of book             ³±±
±±³           ³ lCusto     - Imprime Centro de Custo?                      ³±±
±±³           ³ lCLVL      - Imprime Classe de Valor?                      ³±±
±±³           ³ lAnalitico - Imprime Analitico ou Sintetico?               ³±±
±±³           ³ Titulo     - Titulo do Relatorio                           ³±±
±±³           ³ nTamLinha  - Tamanho da linha                              ³±±
±±³           ³ aCtbMoeda  -  Array da Moeda                               ³±±
±±³           ³ cSayCusto  - Nomenclatura utilizada para o Centro de Custo ³±±
±±³           ³ cSayItem   - Nomenclatura utilizada para o Item            ³±±
±±³           ³ cSayClVl   - Nomenclatura utilizada para a Classe de valor ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR480Imp(lEnd,WnRel,cString,aSetOfBook,lCusto,lCLVL,lAnalitico,Titulo,;
				   nTamlinha,aCtbMoeda,cSayCusto,cSayItem,cSayClvl)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""

Local aSaldo		:= {}
Local aSaldoAnt		:= {}
Local cDescMoeda
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cPicture
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cSaldo		:= mv_par06
Local cItemIni		:= mv_par01
Local cItemFim		:= mv_par02
Local cContaIni	:= mv_par12
Local cContaFIm	:= mv_par13
Local cCustoIni	:= mv_par15
Local cCustoFim	:= mv_par16
Local cCLVLIni		:= mv_par18
Local cCLVLFim		:= mv_par19
Local cContaAnt	:= ""
Local dDataAnt		:= CTOD("  /  /  ")
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem 	:= ""
Local cResCLVL		:= ""		
Local cDescSint	:= ""
Local cMoeda		:= mv_par05
Local cContaSint	:= ""
Local cArqTmp
Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04
Local lNoMov		:= Iif(mv_par09==1,.T.,.F.)
Local lSalto		:= Iif(mv_par20==1,.T.,.F.)
Local lFirst		:= .T.

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nReinicia 	:= mv_par23
Local nPagFim		:= mv_par22
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0, aColunas, lTotConta, cNormal := ""
Local l1StQb := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt				:= SPACE(10)
cbcont			:= 0
li       		:= 80
m_pag    		:= 1

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

// Mascara do Item Contabil
If Empty(aSetOfBook[7])
	cMascara3 := ""
Else
	cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
EndIf

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf
 
// Mascara do Centro de Custo
If lCusto
	If Empty(aSetOfBook[6])
		cMascara2 := GetMv("MV_MASCCUS")
	Else
		cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf                                                
Endif 

// Mascara da Classe de Valor
If lCLVL
	If Empty(aSetOfBook[8])
		cMascara4 := ""
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

cPicture 	:= aSetOfBook[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Titulo do Relatorio                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")== "U"
	Titulo	:=	STR0007	+ Upper(Alltrim(cSayItem))//"RAZAO POR ITEM  "
	IF lAnalitico
		Titulo	+= STR0008		//"ANALITICO EM"
	Else
		Titulo	+=	STR0021		//" SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + space(01)+STR0009 + space(01)+DTOC(dDataIni) +;	// "DE"
					space(01)+STR0010 + space(01)+DTOC(dDataFim)						// "ATE"
	
	If mv_par06 > "1"
		Titulo += " (" + Tabela("SL", mv_par06, .F.) + ")"
	EndIf
Else
	Titulo := NewHead
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Resumido                                  						         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA                         					                                DEBITO               CREDITO            SALDO ATUAL
// XX/XX/XXXX 			                                 		     99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Conta                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA
// LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL"
// XX/XX/XXXX         
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9999999999999.99 9999999999999.99 9999999999999.99D
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Conta + Item + Classe de Valor											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA
// LOTE/DOC/LINHA  H I S T O R I C O                        C/PARTIDA                      CENTRO DE CUSTO      CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL"
// XX/XX/XXXX 
// XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22

#DEFINE 	COL_NUMERO 				1
#DEFINE 	COL_HISTORICO			2
#DEFINE 	COL_CONTRA_PARTIDA	3
#DEFINE 	COL_CENTRO_CUSTO  	4
#DEFINE 	COL_CLASSE_VALOR  	5 
#DEFINE 	COL_VLR_DEBITO			6
#DEFINE 	COL_VLR_CREDITO		7
#DEFINE 	COL_VLR_SALDO  		8
#DEFINE 	TAMANHO_TM       		9
#DEFINE 	COL_VLR_TRANSPORTE  10

If ! lAnalitico
	aColunas := { 000, 019,    ,    ,    , 069, 091, 113, 18, 090 }
Else
	aColunas := { 000, 019, 060, 131, 152, 172, 188, 204, 14,176 }
Endif

If lAnalitico							// Relatorio Analitico
	Cabec1  := STR0019					// "DATA"
	Cabec2 	:= Iif (cPaisLoc<>"MEX" ,STR0013,STR0028)			// "LOTE/DOC/LINHA    H I S T O R I C O                        C/PARTIDA                    C.CUSTO              CLASSE DE VALOR                      DEBITO                CREDITO            SALDO ATUAL"
	Cabec2	+= Upper(cSayCusto)+Space(11)+Upper(cSayClvl)+Space(18)
	Cabec2 	+= Iif (cPaisLoc<>"MEX" ,STR0026,STR0031)
Else
	lCusto := .F.
	lCLVL  := .F.
	Cabec1 := Iif (cPaisLoc<>"MEX" ,STR0025,STR0030)				// "DATA			                    		                   					                                               DEBITO           CREDITO       SALDO ATUAL"
EndIf	
m_pag    			:= mv_par21
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,.t.,"3",lAnalitico)},;				
				STR0018,;		// "Criando Arquivo Temporario..."
				STR0006+(Alltrim(cSayItem)))						// "Emissao do Razao"

dbSelectArea("cArqTmp")
SetRegua(RecCount())
dbGoTop()

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If RecCount("cArqTmp") == 0 .And. !Empty(aSetOfBook[5])                                       
	dbCloseArea("cArqTmp")
	FErase("cArqTmp"+GetDBExtension())
	FErase("cArqTmp"+OrdBagExt())	
	Return
Endif


While !Eof()

	IF lEnd
		@Prow()+1,0 PSAY STR0015  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF

	IncRegua()

	// Calcula o saldo anterior do centro de custo atual                                 
	// No saldo anterior, soh serah considerado ITEM/CONTA.O filtro de Centro de Custo
	// eh utilizado somente para filtro de impressao. 
	aSaldoAnt := SaldTotCT4(cArqTmp->ITEM,cArqTmp->ITEM,space(Len(CTT->CTT_CUSTO)),Repl('Z',Len(CTT->CTT_CUSTO)),cContaIni,cContaFim,;
						 dDataIni,cMoeda,cSaldo)
	
	aSaldo := SaldTotCT4(cArqTmp->ITEM,cArqTmp->ITEM,space(Len(CTT->CTT_CUSTO)),Repl('Z',Len(CTT->CTT_CUSTO)),cContaIni,cContaFim,;
						 cArqTmp->DATAL,cMoeda,cSaldo)
						 						
	If !lNoMov //Se imprime sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		Endif	
	Endif             

	If li > 56 .Or. lSalto              
		If m_pag > nPagFim
			nPagFim := m_pag+nPagFim
			If l1StQb							//// SE FOR A 1ª QUEBRA
				m_pag := nReinicia
				l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
			Endif
		EndIf	
		CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
	EndIf

	nSaldoAtu	:= 0
	nTotDeb		:= 0
	nTotCrd		:= 0

	@li,011 PSAY Upper(cSayItem) + " - " 		//"ITEM  - "		

	dbSelectArea("CTD")
	dbSetOrder(1)
	dbSeek(xFilial()+cArqTMP->ITEM)  
	cResItem := CTD->CTD_RES		
	If mv_par25 == 1 //Se imprime cod. normal item
		EntidadeCTB(cArqTmp->ITEM,li,pcol()+2,20,.F.,cMascara3,cSepara3)	
	Else
		EntidadeCTB(cResItem,li,pcol()+2,20,.F.,cMascara3,cSepara3)		
	Endif

	@ li, pCol()+2 PSAY "- " + CtbDescMoeda("CTD->CTD_DESC"+cMoeda)                 	
	                                                                                    
	If lAnalitico
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0027) - 1;
			 PSAY STR0027	//"SALDO ANTERIOR: "		
	Else
		@li,aColunas[COL_VLR_CREDITO]  PSAY STR0027	//"SALDO ANTERIOR: "		
	EndIf	
	// Impressao do Saldo Anterior do Item.
	ValorCTB(aSaldoAnt[6],li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
							         .T.,cPicture)

	nSaldoAtu := aSaldoAnt[6]
	li += 2         
   *
   * Busca descricao conta para imprimir apos o item contabil
   *                                                         
   dbSelectArea("CT1")
   dbSetOrder(1)
   If dbSeek(xFilial()+cContaIni)
     	cDescConta  := CT1->CT1_DESC01
   EndIf	
	@ li, 011 PSAY cContaIni + "- " + cDescConta + cMoeda                	
	li += 2         
   *
	dbSelectArea("cArqTmp")
	
	cItemAnt := cArqTmp->ITEM
	While cArqTmp->(!Eof()) .And. cArqTmp->ITEM == cItemAnt
	
		cContaAnt	:= cArqTmp->CONTA
		dDataAnt	:= cArqTmp->DATAL                      
		If lAnalitico
			nTotCtaDeb  := 0
			nTotCtaCrd	:= 0
		
			If ! Empty(cArqTmp->CONTA)
				li++
				@li,000 PSAY STR0024				// "CONTA - "
			
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbSeek(xFilial()+cArqTmp->CONTA)
				cCodRes := CT1->CT1_RES
				cNormal := CT1->CT1_NORMAL
		
				If mv_par10 == 1							// Imprime Cod Normal
					EntidadeCTB(cArqTmp->CONTA,li,pcol()+2,70,.F.,cMascara1,cSepara1)
				Else
					EntidadeCTB(cCodRes,li,pcol()+2,20,.F.,cMascara1,cSepara1)
				EndIf

				@ li, pCol()+2 PSAY CtbDescMoeda("CT1->CT1_DESC"+cMoeda)
			
				li+=2
			Endif

			@li,000 PSAY cArqTmp->DATAL
			If ! Empty(cArqTmp->CONTA)
				li++
			Endif
					
			lTotConta := .F.
			While cArqTmp->(!Eof()) .And. cArqTmp->ITEM == cItemAnt .And. cArqTmp->CONTA == cContaAnt
		
				If li > 56  
					If m_pag > nPagFim
						nPagFim := m_pag+nPagFim
						If l1StQb							//// SE FOR A 1ª QUEBRA
							m_pag := nReinicia
							l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
						Endif
					EndIf	
					li++
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1;
								 PSAY STR0022	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    .T.,cPicture,cNormal)
					CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
			
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1;
								 PSAY STR0023	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    .T.,cPicture,cNormal)
					li++
				EndIf            
				nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
				nTotDeb		+= cArqTmp->LANCDEB
				nTotCrd		+= cArqTmp->LANCCRD
				nTotCtaDeb  += cArqTmp->LANCDEB
				nTotCtaCrd  += cArqTmp->LANCCRD
	
				// Imprime os lancamentos para a conta 
				If dDataAnt != cArqTmp->DATAL
					li+=2
					@li,000 PSAY cArqTmp->DATAL
					li++
				EndIf	
				
				@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+;
											   cArqTmp->DOC+cArqTmp->LINHA
				@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,40)                        
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbSeek(xFilial()+cArqTmp->XPARTIDA)
				cCodRes := CT1->CT1_RES

				If mv_par10 == 1
					EntidadeCTB(cArqTmp->XPARTIDA,li,aColunas[COL_CONTRA_PARTIDA],;
								70,.F.,cMascara1,cSepara1)
				Else
					EntidadeCTB(cCodRes,li,aColunas[COL_CONTRA_PARTIDA],20,.F.,;
								cMascara1,cSepara1)				
				Endif                              

				If lCusto 				//Se imprime centro de custo
					If mv_par24 == 1 	//Se imprime cod. normal centro de custo
						EntidadeCTB(cArqTmp->CCUSTO,li,aColunas[COL_CENTRO_CUSTO],20,.F.,cMascara2,cSepara2)
					Else
						dbSelectArea("CTT")
						dbSetOrder(1)
						dbSeek(xFilial()+cArqTMP->CCUSTO)  
						cResCC := CTT->CTT_RES
						EntidadeCTB(cResCC,li,aColunas[COL_CENTRO_CUSTO],20,.F.,cMascara2,cSepara2)
					Endif
				Endif
				
				If lCLVL						//Se imprime classe de valor
					If mv_par26 == 1
						EntidadeCTB(cArqTmp->CLVL,li,aColunas[COL_CLASSE_VALOR],20,.F.,cMascara4,cSepara4)
					Else
						dbSelectArea("CTH")
						dbSetOrder(1)
						dbSeek(xFilial()+cArqTmp->CLVL)				
						cResClVl := CTH->CTH_RES						
						EntidadeCTB(cResClVl,li,aColunas[COL_CLASSE_VALOR],20,.F.,cMascara4,cSepara4)
					Endif					
				Endif
				
				ValorCTB(cArqTmp->LANCDEB,li,aColunas[COL_VLR_DEBITO],;
											  aColunas[TAMANHO_TM],nDecimais,.F.,;
											  cPicture,"1")
				ValorCTB(cArqTmp->LANCCRD,li,aColunas[COL_VLR_CREDITO],;
											  aColunas[TAMANHO_TM],nDecimais,.F.,;
											  cPicture,"2")
				ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
									   aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
				
				// Procura pelo complemento de historico
				dbSelectArea("CT2")
				dbSetOrder(10)
				If dbSeek(xFilial()+DTOS(cArqTMP->DATAL)+	cArqTmp->LOTE+;
															cArqTmp->SUBLOTE+;
															cArqTmp->DOC+;
										  					cArqTmp->SEQLAN)
					dbSkip()
					If CT2->CT2_DC == "4"
						While !Eof() .And. CT2->CT2_FILIAL == xFilial() 			.And.;
											CT2->CT2_LOTE == cArqTMP->LOTE 		.And.;
											CT2->CT2_SBLOTE == cArqTMP->SUBLOTE 	.And.;
											CT2->CT2_DOC == cArqTmp->DOC 			.And.;
											CT2->CT2_SEQLAN == cArqTmp->SEQLAN 	.And.;
											CT2->CT2_DC == "4" 					.And.;
									   DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)                        
							li++
							@li,aColunas[COL_NUMERO] 	 PSAY	CT2->CT2_LOTE+;
																	  	CT2->CT2_SBLOTE+;
										        						CT2->CT2_DOC+;
										        						CT2->CT2_LINHA
							@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,40)
							dbSkip()
						EndDo	
					EndIf	
				EndIf	
				dbSelectArea("cArqTmp")
				li++
			
				If li > 56
					If m_pag > nPagFim
						nPagFim := m_pag+nPagFim
						If l1StQb							//// SE FOR A 1ª QUEBRA
							m_pag := nReinicia
							l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
						Endif
					EndIf	
					li++
					
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1;
								 PSAY STR0022	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    			   .T.,cPicture,cNormal)
					CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
			
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1;
								 PSAY STR0023	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    			   .T.,cPicture,cNormal)
					li++
	   		EndIf
         	lTotConta := ! Empty(cArqTmp->CONTA)
				dbSelectArea("cArqTmp")
				dDataAnt := cArqTmp->DATAL
      		dbSkip()
			EndDo      	
   
			If lTotConta .And. mv_par11 == 1						// Totaliza tb por Conta
				li += 1
				@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY STR0020  //"T o t a i s  d a  C o n t a  ==> " 
				ValorCTB(nTotCtaDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],;
					     nDecimais,.F.,cPicture,"1")
				ValorCTB(nTotCtaCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],;
					     nDecimais,.F.,cPicture,"2")
			
				nTotCtaDeb := 0
				nTotCtaCrd := 0
			
				li++
				@li, 00 PSAY Replicate("-",nTamLinha)
			EndIf	
			If lTotConta
				li++
			Endif
		Else					//Se for resumido
			dbSelectArea("cArqTmp")
			If ! Empty(cArqTmp->CONTA)
				CT1->(dbSeek(xFilial()+cArqTmp->CONTA))
				cCodRes := CT1->CT1_RES
				cNormal := CT1->CT1_NORMAL
			Else
				cNormal := ""
			Endif

			If li > 56
				If m_pag > nPagFim
					nPagFim := m_pag+nPagFim
					If l1StQb							//// SE FOR A 1ª QUEBRA
					m_pag := nReinicia
					l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
					Endif
				EndIf	
				li++
					
				@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1 PSAY STR0022	//"A TRANSPORTAR : "
				ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO], aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
				CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		
				@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1 PSAY STR0023	//"A TRANSPORTAR : "
	 			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal)
				li++
			EndIf
	
			@li,000 PSAY cArqTmp->DATAL
				
			While  dDataAnt == cArqTmp->DATAL .And. cItemAnt == cArqTmp->ITEM
				nVlrDeb	+= cArqTmp->LANCDEB		                                         
				nVlrCrd	+= cArqTmp->LANCCRD		                                         
				dbSkip()                                                                    				
			End		   
			
			nSaldoAtu	:= nSaldoAtu - nVlrDeb + nVlrCrd
			ValorCTB(nVlrDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],;
					 nDecimais,.F.,cPicture,"1")
			ValorCTB(nVlrCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],;
					 nDecimais,.F.,cPicture,"2")
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],;
					 nDecimais,.T.,cPicture,cNormal)
			nTotDeb		+= nVlrDeb
			nTotCrd		+= nVlrCrd
			nVlrDeb	:= 0
			nVlrCrd	:= 0
		Endif				
		dbSelectArea("cArqTmp")
		li++		
	EndDo	

	li += If(lAnalitico, 0, 1)                                    
	
	If li > 56
		If m_pag > nPagFim
			nPagFim := m_pag+nPagFim
			If l1StQb							//// SE FOR A 1ª QUEBRA
				m_pag := nReinicia
				l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
			Endif
		EndIf	
		li++
					
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1;
					 PSAY STR0022	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
							   aColunas[TAMANHO_TM],nDecimais,;
	    	    			   .T.,cPicture,cNormal)
		CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1;
					 PSAY STR0023	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
							   aColunas[TAMANHO_TM],nDecimais,;
		   	    			   .T.,cPicture,cNormal)
		li++
	EndIf

	@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY STR0017 + Upper(Alltrim(cSayItem)) + " ==> " //"T o t a i s   I t e m  ==> " 
    
	@li, pcol()+1 PSAY "( " 	
	
	If mv_par25 ==1 //Imprime cod. normal Item 
		EntidadeCTB(cItemAnt,li,pcol()+2,20,.F.,cMascara3,cSepara3)
	Else
		dbSelectArea("CTD")
		dbSetOrder(1)
		dbSeek(xFilial()+cItemAnt)  
		cResItem := CTD->CTD_RES
		EntidadeCTB(cResItem,li,pcol()+2,20,.F.,cMascara3,cSepara3)		
	Endif                   		
	@li, pcol()+1 PSAY " )"

	ValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"1")
	ValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"2")
	ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
			 .T.,cPicture)
//	li+=2
		
//	If lAnalitico
		li++
		@li, 00 PSAY Replicate("=",nTamLinha)
		li+=2
//	Endif
	dbSelectArea("cArqTmp")
EndDo	

If li != 80
	roda(cbcont,cbtxt,Tamanho)
EndIf

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") = 0
	FErase("cArqTmp"+GetDBExtension())
	FErase("cArqTmp"+OrdBagExt())
EndIf	

dbselectArea("CT2")

MS_FLUSH()
