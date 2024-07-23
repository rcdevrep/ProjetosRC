#INCLUDE "CTBR010.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctbz010  ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 10/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Impressao do Plano de Contas              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbz010()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Ctbz010(wnRel,dDataRef,cMoeda)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cString	:="CT1"
LOCAL aOrd	 	:= {OemToAnsi(STR0004),OemToAnsi(STR0005)}  //"Conta"###"Descri‡„o"
LOCAL cDesc1 	:= OemToAnsi(STR0001)  //"Este programa ir  imprimir o Plano de Contas."
LOCAL cDesc2 	:= OemToAnsi(STR0002)  //"Ser  impresso de acordo com os parƒmetros solicitados pelo"
LOCAL cDesc3 	:= OemToAnsi(STR0003)  //"usu rio."
Local lExterno 	:= wnRel <> Nil
Local aCtbMoeda	:= {}

DEFAULT dDataRef:= dDataBase

//PRIVATE Tamanho	:=If(lExterno, "M", "G")
PRIVATE Tamanho	:= "M"
PRIVATE aReturn := { OemToAnsi(STR0006), 1,OemToAnsi(STR0007), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog:="CTBZ010"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="CTR010"

li       := 80
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta grupo de perguntas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

pergunte("CTR010",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01		// da conta                             	³
//³ mv_par02      	// ate a conta                          	³
//³ mv_par03      	// imprime centro de custo               	³ 
//³ mv_par04      	// folha inicial		         			³
//³ mv_par05		// Analitica - Sintetica - Todas        	³ 
//³ mv_par06		// Desc na Moeda						   	³ 
//³ mv_par07		// Imprime Bloqueadas?         	       		³ 
//³ mv_par08		// Mascara                    	       		³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE titulo:= OemToAnsi(STR0008)  //"Listagem do Plano de Contas"
PRIVATE cabec1 := OemToAnsi(STR0009)  //"CONTA                          DC COD.RES.   D E N O M I N A C A O                    CLASSE COND NORMAL CTA SUPERIOR         BLOQ"
PRIVATE cabec2 := " "
PRIVATE cCancel:= OemToAnsi(STR0010)  //"***** CANCELADO PELO OPERADOR *****"

If ! lExterno
	wnrel:="CTBZ010"            //Nome Default do relatorio em Disco
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)
Else
	mv_par01 := Repl(" ", Len(mv_par01))
	mv_par02 := Repl("Z", Len(mv_par02))
	mv_par06 := cMoeda
Endif

//Verifica moeda 
aCtbMoeda  	:= CtbMoeda(mv_par06)
If Empty(aCtbMoeda[1])                       
     Help(" ",1,"NOMOEDA")
	 Return
Endif

If nLastKey == 27
	Set Filter To
	Return
Endif

If ! lExterno
	SetDefault(aReturn,cString)
Else
	Cabec1 := Left(Cabec1, 126) + STR0018 //"CL/CON"
Endif

If Empty(mv_par06)
	Set Filter To        	
	Help(" ",1,"NOMOEDA")
	Return
EndIf

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTr010Imp(@lEnd,wnRel,cString,lExterno)})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctr010Imp³ Autor ³ Pilar S Albaladejo    ³ Data ³ 10/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Impressao do Plano de Contas              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbz010(lEnd,wnRel,cString)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBZ010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr010Imp(lEnd,WnRel,cString,lExterno)

LOCAL limite := 222
LOCAL cClasse
Local cMascara
Local cSeparador 	:= "", nImprime := 1

If Empty(mv_par08)
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(mv_par08,@cSeparador)
EndIf

// Verifica ordem a ser impressa                                
nOrdem := aReturn[8]

dbSelectArea("CT1")
IF nOrdem == 2
	cChave 	:= "CT1_FILIAL+CT1_DESC"+mv_par06
	cIndex	:= CriaTrab(nil,.f.)
	IndRegua("CT1",cIndex,cChave,, "CT1_CONTA >= '" + mv_par01 + "' .And. " +;
									"CT1_CONTA <= '" + mv_par02 + "'",OemToAnsi(STR0011)) //"Selecionando Registros..."
	nIndex	:= RetIndex("CT1")
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbSeek(xFilial("CT1"))
Else
	dbSetOrder( 1 )
	dbSeek( xFilial("CT1")+mv_par01,.T. )
End

SetRegua(RecCount())   						// Total de elementos da regua

If nOrdem == 1
	dbSelectArea("CT1")
	dbSetOrder(1)
	cCondicao:=	"CT1_FILIAL == xFilial('CT1') .And. CT1_CONTA <= mv_par02 .And. !Eof()"
	If SuperGetMv("MV_CTASUP") = "S"
		cIndex := CriaTrab({ 	{ "CONTA", "C", Len(CT1->CT1_CONTA), 0 },;
								{ "SUPERIOR", "C", Len(CT1->CT1_CONTA), 0 },;
								{ "ORDEMPRN", "N", 6, 0 }, { "RECNO", "N", 6, 0 } },.T.)
		dbUseArea( .T.,, cIndex, "cArqTmp", .F., .F. )
		IndRegua("cArqTmp",Left(cIndex, 7) + "A","CONTA",,,OemToAnsi(STR0011)) //"Selecionando Registros..."
		IndRegua("cArqTmp",Left(cIndex, 7) + "B","ORDEMPRN",,,OemToAnsi(STR0011)) //"Selecionando Registros..."
		IndRegua("cArqTmp",Left(cIndex, 7) + "C","SUPERIOR",,,OemToAnsi(STR0011)) //"Selecionando Registros..."
		DbClearIndex()
		dbSetIndex(Left(cIndex,7)+"A"+OrdBagExt())
		dbSetIndex(Left(cIndex,7)+"B"+OrdBagExt())
		dbSetIndex(Left(cIndex,7)+"C"+OrdBagExt())
		DbSetOrder(1)
		dbSelectArea("CT1")
		While &cCondicao
			DbSelectArea("cArqTmp")
			DbAppend()
			Replace CONTA With CT1->CT1_CONTA, SUPERIOR With CT1->CT1_CTASUP,;
					RECNO With CT1->(Recno())
			dbSelectArea("CT1")
			DbSkip()
		EndDo
		
		cCondicao := "! Eof()"
		DbSelectArea("cArqTmp")
		DbGoTop()
		While ! Eof()
			If Empty(SUPERIOR)
				CtGerSup(CONTA, @nImprime)
			Endif
			DbSkip()
		Enddo
		DbSetOrder(2)
		DbGoTop()
	Endif
Else
	dbSelectarea("CT1")
	dbSetOrder(nIndex+1)
	cCondicao := "CT1_FILIAL == xFilial('CT1') .And. !Eof()"
EndIF

If ! lExterno
	m_pag:=mv_par04
Endif

While &cCondicao

	If lEnd 	
		@Prow()+1,001 PSAY cCancel
		Exit
	EndIF
     
	IncRegua()
	
	If Select("cArqTmp") > 0
		CT1->(DbGoto(cArqTmp->RECNO))
	Endif
	
	IF mv_par03 == 2
		IF CT1->CT1_NCUSTO > 0
			dbSkip()
			Loop
		EndIF
	EndIF

	If mv_par07 == 2
		If CT1->CT1_BLOQ == "1"				// Conta Bloqueada
			dbSkip()
			Loop
		EndIf
	EndIf

	If mv_par05 == 1							// Imprime Analiticas
		If CT1->CT1_CLASSE == "1"
			dbSkip()
			Loop
		EndIf
	ElseIF mv_par05 ==2						// Imprime Sinteticas
		IF CT1->CT1_CLASSE = "2"
			dbSkip()
			Loop
		EndIf
	EndIf
		
	IF li > MV_PAR09 // Qtde linhas impressao parametrizada
		CtCGCCabec(,,,Cabec1,Cabec2,dDataBase,Titulo,,"2",Tamanho)
		li--
	EndIF

	cCodigo	:=	Alltrim(CT1->CT1_CONTA)
	cDesc := &('CT1->CT1_DESC'+mv_par06)

	li++

	EntidadeCTB(CT1->CT1_CONTA,li,000,070,.F.,cMascara,cSeparador)
	@li, 071 PSAY CT1->CT1_DC        
	@li, 074 PSAY CT1->CT1_RES
	@li, 085 PSAY cDesc              
	
	If CT1->CT1_CLASSE == '1'
		@li, 126 PSAY STR0014
	ElseIf CT1->CT1_CLASSE == '2'
		@li, 126 PSAY STR0015
	EndIf

	If ! lExterno	
		If CT1->CT1_NORMAL == '1'
			@li, 133 PSAY STR0016
		ElseIf CT1->CT1_NORMAL =='2'
			@li, 133 PSAY STR0017
		EndIf
		
		@li, 146 PSAY CT1->CT1_CTASUP
		If CT1->CT1_BLOQ == "1"	
			@li, 217 PSAY OemToAnsi(STR0012)	//Sim
		ElseIf CT1->CT1_BLOQ == "2"	
			@li, 217 PSAY OemToAnsi(STR0013)	// Nao
		EndIf
	Else
		If CT1->CT1_NORMAL == '1'
			@li, 128 PSAY "- " + STR0016
		ElseIf CT1->CT1_NORMAL =='2'
			@li, 128 PSAY "- " + STR0017
		EndIf
	Endif
	If Select("cArqTmp") > 0
		("cArqTmp")->(DbSkip())
	Else
		dbSkip( )
	Endif

EndDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se emissao foi alfabetica, deleta arquivo de trabalho        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 2
	dbSelectArea("CT1")
	dbClearFil(NIL)
	RetIndex( "CT1" )
	If !Empty(cIndex)
		FErase (cIndex+OrdBagExt())
	Endif
	dbSetOrder(1)
EndIf

dbSelectarea( "CT1" )
dbSetOrder( 1 )
IF ! lExterno .And. li != 80
	roda(0,"","M")
EndIF

Set Filter To
If aReturn[5] = 1 .And. ! lExterno
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

If Select("cArqTmp") > 0
	("cArqTmp")->(DbCloseArea())
Endif

If ! lExterno
	MS_FLUSH()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³Deco                   ³ Data ³04/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acerta o arquivo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION AjustaSx1()

Local cAlias	:=	Alias()
PutSx1("CTR010","09","Qtde Linhas Impressao  ?","","","mv_chj","N",02,0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","")
Return

