/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DATA   ³ BOPS ³Program.³ALTERACAO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³04.01.00³META  ³Mauricio³Criada Baixa a receber automatica.             ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "PROTHEUS.ch"
#include "FILEIO.CH"
//#INCLUDE "FINA110.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA110  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Baixa Autom tica de Titulos a Receber                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA110()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGX444()

Local nSavRec		:= Recno()

PRIVATE cFil110
PRIVATE aRotina := MenuDef()
//private aRegistros := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabe‡alho da tela de baixas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:= OemToAnsi( "Baixa de Titulos - SEM JUROS" ) // "Baixa de Titulos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o n£mero do Lote                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cLote
       
//MsgInfo("Atenção, Utilizar essa Rotina EXCLUSIVAMENTE para Baixas de Arquivos da Raízen!"," Atenção ")                                                           
alert("Rotina descontinuada-> Favor entrar em contato com a TI")
Return(.F.)   


LoteCont( "FIN" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega fun‡„o Pergunte                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg := "FIN110"

//AADD(aRegistros,{cPerg,"09","Calcula Correcao Monetaria ?","mv_ch9","N",01,0,0,"C","","MV_PAR09","Sim","","","Não","","","","","","","","","","",""})
//ALERT(MV_PAR09)
//U_CriaPer(cPerg,aRegistros)   

SetKey (VK_F12,{|a,b| AcessaPerg("FIN110",.T.)})
SetKey(VK_F4, {|| NIL})
pergunte("FIN110",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parƒmetros          ³
//³ mv_par01	Mostra Lan‡ Contabil               ³
//³ mv_par02   Aglutina Lancamentos               ³
//³ mv_par03   Contabiliza On-Line                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDigita	:= IIF(mv_par01==1,.T.,.F.)
lAglut	:= IIF(mv_par02==1,.T.,.F.)

dbSelectArea("SE1")
dbSetOrder(1)
dbSeek( cFilial )

IF ExistBlock("F110BROW")
	ExecBlock("F110BROW",.f.,.f.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a Fun‡„o de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SE1",,,,,, Fa040Legenda("SE1"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SE1->(DbClearFilter())
dbSelectArea("SE1")
dbSetOrder(1)
dbGoTo( nSavRec )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fA110Aut ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Baixa Autom tica                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa110Aut()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGX444AAA(cAlias,cCampo,nOpcE,xImporta)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg
Local oDlg1
Local oQtda
Local oCbx
Local oCbxIMP //Combobox importação
Local oValor		:= 0
Local lInverte		:= .F.
Local aDescMotbx	:= {}
Local lEof
Local nOpca			:= 0
Local nTotal		:= 0
Local nHdlPrv		:= 0
Local nC				:= 0
Local lDigita		:= IIF(mv_par01==1,.T.,.F.)
Local lAglut		:= IIF(mv_par02==1,.T.,.F.)
Local nSaldoCru		:= 0
Local cIndex		:= ""
Local cChave		:= ""
Local nSavOrd1		:= SE1->(IndexOrd())
Local cDescrMo		:= " "
Local lFa110Desc	:= (ExistBlock("FA110DES"))
Local lFa110Juros	:= (ExistBlock("FA110JUR"))
Local lFa110Mult	:= (ExistBlock("FA110MUL"))
Local lFina110  	:= (ExistBlock("FINA110" ))
Local lTFina110  	:= (ExistTemplate("FINA110" ))
Local nSaldo
Local cArquivo
Local nX := 0
Local lPadrao 		:= .F.
Local cNumero
Local cPrefixo
Local cParcela
Local cCliente
Local nRec
Local lFa110Se5 	:= (ExistBlock("FA110SE5"))
Local nRegAtu
Local nIndex
Local aTipoSeq 		:= {}
Local cSequencia 	:= "00"
Local aMotBx 		:= ReadMotBx()
Local nSE1Rec 		:= 0
Local lDesconto 	:= IIF( mv_par04 == 1, .T., .F. )
Local lJuros  		:= IIF( mv_par05 == 1, .T., .F. )
Local aBaixas 		:= {}
Local nProxReg      
Local nAcresc   	:= 0
Local nDecresc  	:= 0
Local nValAbat  	:= 0
Local lSpbInUse 	:= SpbInUse()
Local nValorTotal 	:= 0
Local lBxCnab  		:= GetMv("MV_BXCNAB") == "S"
Local lGerTotal 	:= .F.
Local lF110Rec 		:= ExistBlock("F110REC")
Local oBanco110
Local nRegPrinc 	:= 0
Local nI
Local oTimer
Local nTimeOut  	:= SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione os titulos a faturar
Local nTimeMsg  	:= SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usuário
                                                      		// informando que a tela fechará automaticamente em XX minutos
Local lAcreDecre 	:= .F.
Local aArea			:= GetArea()
Local nRecnoSe1
Local aButtons 		:= {}          
Local lGravaAglut 	:= .T.

PRIVATE cLoteFin 	:= Space(4)
PRIVATE cBco110 	:= CRIAVAR("A6_COD")
PRIVATE cAge110 	:= CRIAVAR("A6_AGENCIA")
PRIVATE cCta110 	:= CRIAVAR("A6_NUMCON")
PRIVATE cCliDe  	:= CRIAVAR("E1_CLIENTE")
PRIVATE cCliAte 	:= CRIAVAR("E1_CLIENTE")
PRIVATE cMotBx		:= CriaVar("E5_MOTBX")
PRIVATE cMotBxIMP	:= CriaVar("E5_MOTBX")
PRIVATE nMulta		:= 0
PRIVATE nDescont	:= 0
PRIVATE nCorrec		:= 0
PRIVATE nJuros		:= 0
PRIVATE cPadrao		:= "520"
PRIVATE cBord110	:= CriaVar("E1_NUMBOR")
PRIVATE cBcoDe		:= CriaVar("E1_PORTADO")
PRIVATE cBcoAte		:= CriaVar("E1_PORTADO")
PRIVATE cPortado	:= CriaVar("E1_PORTADO")
PRIVATE dVencIni	:= dDataBase
PRIVATE dVencFim	:= dDataBase
PRIVATE cMarca		:= GetMark()
PRIVATE nTotAbat	:= 0				// Utilizada por Fa070Data
PRIVATE dBaixa 		:= dDataBase	// Utilizada por Fa070Data
PRIVATE dDtCredito 	:= dBaixa		// Utilizada por Fa070Data
PRIVATE cBanco		:= cBco110
PRIVATE cAgencia	:= cAge110
PRIVATE cConta		:= cCta110
PRIVATE nCM1 		:= 0
PRIVATE nProRata	:= 0 
PRIVATE lImporta 	:= .F.  // Spiller - Utilizado por importação RAIZEN
Default xImporta     := .F. // Spiller - Utilizado por importação RAIZEN

//Spiller Grava Flag de importação
lImporta :=  xImporta  

//Se importação sugere 01/01 do ano corrente
If  lImporta
	dVencIni	:= ctod('01/01/'+str(year(ddatabase)))//dDataBase 
	dVencFim	:= ctod('31/12/'+str(year(ddatabase)))//dDataBase 
Endif

SetKey(VK_F4, {|| BuscaTit() })

//alert("entrou no automatica ")

// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5 := 0
VALOR6 := 0
VALOR7 := 0

//verifica se existem os campos de valores de acrescimo e decrescimo no SE5
If SE5->(FieldPos("E5_VLACRES")) > 0 .and. SE5->(FieldPos("E5_VLDECRE")) > 0
	lAcreDecre := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A fun‡„o SomaAbat reabre o SE1 com outro nome pela ChkFile para  ³
//³ efeito de performance. Se o alias auxiliar para a SumAbat() n„o  ³
//³ estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,   ³
//³ pois o Filtro do SE1 uptrapassa 255 Caracteres.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SomaAbat("","","","R")

While .T.

	nRec := SE1->( RecNo() )

	nOpca		:= 0
	cMotBx	:= "NORMAL"
	If Empty(cCliAte)
		cCliAte := Replicate("Z",Len(SE1->E1_CLIENTE))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o Array aDescMotBx contendo apenas a descricao do   ³
	//³ motivo das Baixas.									 					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len( aMotBx )
		If Substr(aMotBx[nI],34,01) == "A" .or. Substr(aMotBx[nI],34,01) =="R"
			AADD( aDescMotbx,Substr(aMotBx[nI],07,10))
		EndIf
	Next
	
	UltiLote() 
	DEFINE MSDIALOG oDlg FROM 30,16 To 280, 380  TITLE OemToAnsi("Baixa Automatica") PIXEL //"Baixa Autom tica"

	@ 01.0,01.0 MSGET dVencIni SIZE 40,10 of oDlg HASBUTTON
	@ 01.0,05.9 SAY	OemToAnsi("at‚ " ) SIZE 10,10 of oDlg // "at‚ " 
	@ 01.0,07.0 MSGET dVencFim Valid dVencFim >= dVencIni SIZE 40,10 of oDlg HASBUTTON

	@ 03.2,01.0 MSGET cCliDe	F3 "CLI"  SIZE 70,10 of oDlg HASBUTTON
	@ 03.2,10.0	SAY	OemToAnsi("at‚ ") SIZE 05,10 of oDlg // "at‚ "
	@ 03.2,12.2 MSGET cCliAte	F3 "CLI" VALID cCliAte >= cCliDe SIZE 70,10 of oDlg HASBUTTON

	@ 04.5,00.6 SAY	OemToAnsi("Mot.Baixa") SIZE 10,10 of oDlg // "Mot.Baixa"
	@ 05.0,00.6 COMBOBOX oCbx VAR cMotBx ;
					ITEMS aDescMotBx SIZE 56, 47 OF oDlg ;
					Valid (ShowMotBx("R",.T.), cBco110:= CRIAVAR("A6_COD"),;
												cAge110:= CRIAVAR("A6_AGENCIA"),;
												cCta110:= CRIAVAR("A6_NUMCON"))



	@ 06.0,00.6	Say OemToAnsi("Banco : " ) SIZE 10,10 of oDlg  // "Banco : " 
  	@ 06.5,00.6	MSGET oBanco110 VAR cBco110 F3 "SA6" When MovBcoBx(cMotBx, .T.) Valid CarregaSa6(@cBco110,,,.T.) SIZE 10,10 of oDlg HASBUTTON
	@ 06.0,06.0	Say OemToAnsi( "Agencia : ") SIZE 10,10 of oDlg // "Agˆncia : "
  	@ 06.5,06.0	MSGET cAge110 When MovBcoBx(cMotBx, .T.) Valid CarregaSa6(@cBco110,@cAge110,,.T.) SIZE 15,10 of oDlg HASBUTTON
	@ 06.0,12.0	Say OemToAnsi("Conta : ") SIZE 10,10 of oDlg // "Conta : "
  	@ 06.5,12.0	MSGET cCta110 When MovBcoBx(cMotBx, .T.) Valid If(CarregaSa6(@cBco110,@cAge110,@cCta110,.T.,,.T.),.T.,oBanco110:SetFocus()) SIZE 70,10 of oDlg HASBUTTON
  
	@ 07.5,00.6 SAY	OemToAnsi( "Border“") SIZE 10,10 of oDlg// "Border“"
	@ 08.0,00.6 MSGET cBord110 Picture "@S6" ;
							Valid F110BXBORD() .and. IIF(!MovBcoBx(cMotBx, .T.) ,;
													     Empty(cBord110),;
													     .T.) ;
							HASBUTTON 
	@ 07.5,06.0 SAY "Lote" //"Lote"
	@ 08.0,06.0 MSGET cLoteFin Picture "@!" When !Empty(cBord110) .And. lBxCnab  Valid CheckLote("R") HASBUTTON

	@ 00.5,00.5 TO 02.0, 12 LABEL OemToAnsi("Vencimento") // "Vencimento"
	@ 02.5,00.5 TO 04.0, 22.5 LABEL OemToAnsi("Cliente ") // "Cliente "  
	 
	//Leandro Spiller - 25/09/2017 
	//Foi removido pois será aberta a janela no momento da importação
	//Importação de Arquivos Raizen
	//Combobox de importação 
	/*cMotBxIMP	:= "TODOS"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o Array aDescMotBx contendo apenas a descricao do   ³
	//³ motivo das Baixas.									 					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AIMPMOTBX := {}
	AADD(aIMPMotBx,"TODOS")
	AADD(aIMPMotBx,"SÓ IMPORTADOS") 
	//AADD(aDescMotbx,"TODOS")
	//AADD(aDescMotbx,"SÓ IMPORTADOS") 

	@ 07.5,12.0 SAY	OemToAnsi("Mostrar") SIZE 10,10 of oDlg // "Mot.Baixa"
	@ 08.0,12.0 COMBOBOX oCbxIMP VAR cMotBxIMP ;
					ITEMS aIMPMotBx SIZE 56, 47 OF oDlg //;
				   //	Valid (ShowMotBx("R",.T.), cBco110:= CRIAVAR("A6_COD"),;
					//							cAge110:= CRIAVAR("A6_AGENCIA"),;
					//							cCta110:= CRIAVAR("A6_NUMCON")) */

	DEFINE SBUTTON FROM 05.0,150 TYPE 1 ACTION (nOpca := 1,If(Fa110TudOk(lBxCnab),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 18.5,150 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTER

	If nOpca == 0
		Exit
	EndIf

   nRec := SE1->( RecNo() )
   lGerTotal := (!Empty(cBord110) .And. lBxCnab)

	If !Empty(cBord110)
		// Considerar todos os vencimentos para baixar todos do bordero
		dVencIni := CtoD("01/01/1980","ddmmyy")
		dVencFim := CtoD("31/12/2049","ddmmyy")
		cCliDe  := Space(6)
		cCliAte := "ZZZZZZ"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se bordero pode baixado ou nÆo. 							³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lBxBord := f110BxBord()
		If !lBxBord
			Exit
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PONTO DE ENTRADA F110FIL                                      ³
	//³ ExecBlock que retornara chave complementar do filtro da sele- ³
	//³ ‡Æo de contas a receber a serem baixadas.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF (ExistBlock("F110FIL"))
		cFil110 := ExecBlock("F110FIL",.f.,.f.)
	Else
		cFIl110 := ""
	Endif

	dbSelectArea( cAlias )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta express„o do Filtro para sele‡„o                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIndex		:= CriaTrab(nil,.f.)
	cChave		:= IndexKey()
	nOldIndex	:= IndexOrd()
	IndRegua("SE1",cIndex,cChave,,FA110ChecF(),OemToAnsi( "Selecionando Registros..." ) ) // "Selecionando Registros..."
	nIndex := RetIndex("SE1")
	dbSelectArea("SE1")
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbGoTop()
	If Bof() .And. Eof()
		Help(" ",1,"RECNO")
		RetIndex("SE1")
		Set Filter to
		Exit
	EndIf
	nValor	:= 0    // valor total dos titulos,mostrado no rodap‚ do browse
	nQtdTit	:= 0    // quantidade de titulos,mostrado no rodap‚ do browse
	nOpcA		:= 0
	nValorTotal := 0	

	Fa110Marca("SE1",cMarca)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MSADVSIZE()	

	DEFINE MSDIALOG oDlg1 TITLE "      Baixas Automaticas      " From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL	// "      Baixas Autom ticas      "
	oDlg1:lMaximized := .T.
	oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg1) },oDlg1) // Ativa timer
	oTimer:Activate()

	oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,15,15,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	@003,005	Say "Valor Total:"  SIZE 50,10 PIXEL Of oPanel 	// "Valor Total:"
	@003,060	Say oValor	 VAR nValor		Picture "@E 999,999,999.99" SIZE 50,10  PIXEL Of oPanel 
	@003,150	Say "Quantidade:"  SIZE 50,10 PIXEL Of oPanel 	// "Quantidade:"
	@003,200	Say oQtda	 VAR nQtdTit	Picture "@E 99999" SIZE 50,10  PIXEL Of oPanel 

	oMark		:= MsSelect():New(cAlias,"E1_OK","!E1_SALDO",,@lInverte,@cMarca,{18,oDlg1:nLeft,oDlg1:nBottom,oDlg1:nRight})
	oMark:bMark	:= {||finadisplay(cMarca,lInverte,oValor,oQtda,"R")}
	oMark:bAval	:= {||AGX444bAval(cAlias,cMarca,oValor,oQtda,oMark,@nValor)}
	oMark:oBrowse:lhasMark		:= .t.
	oMark:oBrowse:lCanAllmark	:= .t.
	oMark:oBrowse:bAllMark		:= { || AGX444Inverte(cAlias,cMarca,oValor,oQtda,.T.,oMark,@nValor)}
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Ponto de entrada para inclusao de botao
	If ExistBlock("FA110BUT")
		aButtons := Execblock("FA110BUT",.F.,.F.,)
	Endif
	
	Aadd( aButtons, {"HISTORIC", {|| BuscaTit()}, "Buscar..", "Buscar" , {|| .T.}} ) 
	
	ACTIVATE MSDIALOG oDlg1 ;
	ON INIT EnchoiceBar( oDlg1,{|| Iif( FA110BtOk(), (nOpca := 1,oDlg1:End()), nOpca := 0) },{|| nOpca := 0,ODlg1:End()},,aButtons ) CENTER

	If nOpca <> 1
		If __lSX8
			RollBackSX8()
		Endif
		// Destrava os registros.
		dbSelectArea("SE1")
		dbGoTop()
		While !EOF()
			IF SE1->E1_FILIAL != xFilial("SE1")
				dbSkip()
				Loop
			Endif
			SE1->(MsUnlock())
			dbSkip()
		Enddo
		RetIndex("SE1")
		Set Filter to
		dbSetOrder(nSavOrd1)
		Loop
	Endif

	dbSelectArea( "SE1" )

	IF nValor == 0
		Exit
	EndIF
	
	If __lSX8
		ConfirmSX8()
	Endif

	nI :=  Ascan(aMotBx, {|x| Substr(x,1,3) == TrazCodMot(cMotBx) })
	cDescrMo := if( nI > 0,Substr(aMotBx[nI],07,10),"" )

	dbSelectArea("SE1")
	MsUnlockall()
	ChkFile("SE1",.f.,"ABAT")

	dbSelectArea("SE1")
	dbGoTop()

	IF !Empty(cBord110)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura o primeiro registro com carteira  ³
		//³ igual a "R"                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SEA" )
		If dbSeek( xFilial()+cBord110 )
			While !Eof() .And. EA_NUMBOR == cBord110	.And. EA_FILIAL == xFilial()
				If SEA->EA_CART == "P"
					dbSkip()
					Loop
				Endif
				Exit
			Enddo

			If SEA->EA_NUMBOR != cBord110		// N„o achou o bordero,
				cBord110 := Space(6)				// portanto limpa a vari vel
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no banco para a contabilizacao  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SA6")
				dbSetOrder(1)
				dbSeek(cFilial+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON)
				dbSelectArea("SEA")
				cBco110 := SA6->A6_COD
				cAge110 := SA6->A6_AGENCIA
				cCta110 := SA6->A6_NUMCON
			Endif
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia processo de integracao com o SIGAPCO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PCOIniLan("000012")	
	
	dbSelectArea("SE1")
	lEof := Eof()
   
	//Em situacoes que contabilizar com o LP521, zero a variavel VALOR que pode, 
	//neste caso, conter um carga realizada pelo LP520 em uma baixa anterior.
	Valor := 0
	
	While !lEof
		nRegAtu := Recno()
		dbSkip()
		lEof := Eof()
		nProxReg := Recno()
		While SE1->E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT .and. !Eof()
			dbSkip()
			lEof := Eof()
			nProxReg := Recno()
		Enddo
		dbGoto(nRegAtu)

		aBaixas := {}	
		If E1_FILIAL != cFilial
			dbSkip()
			Loop
		Endif

		If E1_OK == cMarca .and. !(E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT)

			BEGIN TRANSACTION

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no Cadastro de Naturezas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SED")
			dbSetOrder(1)
			dbSeek(xFilial("SED")+SE1->E1_NATUREZ)
			dbSelectArea("SE1")
			nRegAtu     := RecNo()
			nSaldo		:= E1_SALDO
			nSaldoCru	:= E1_SALDO //Round(NoRound(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,,3,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),3),2)
			cNumero		:= E1_NUM
			cPrefixo	:= E1_PREFIXO
			cParcela	:= E1_PARCELA
			cCliente	:= E1_CLIENTE
			cLoja   	:= E1_LOJA
			nTotAbat	:= 0
			nValAbat	:= 0
			nMoeda		:= 2
			nJuros		:= 0
			nMulta		:= 0
			nDescont	:= 0
			nCorrec		:= 0
			nCM1 		:= 0
			nProRata 	:= 0
			If mv_par06 == 1
				cBco110 	:= IIF(!Empty(E1_PORTADO), E1_PORTADO, cBco110)
				cAge110 	:= IIF(!Empty(E1_AGEDEP) , E1_AGEDEP , cAge110)
				cCta110 	:= IIF(!Empty(E1_CONTA)  , E1_CONTA  , cCta110)
			Endif	
			nAcresc		:= 0//Round(NoRound(xMoeda(SE1->E1_SDACRES,SE1->E1_MOEDA,1,,3,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),3),2)
			nDecresc	:= 0//Round(NoRound(xMoeda(SE1->E1_SDDECRE,SE1->E1_MOEDA,1,,3,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),3),2)
			dBaixa 		:= dDataBase // Utilizada por Fa070Data
			nCorrec		:= 0//fa110Correc()
			//as variaveis abaixo sao utilizadas em algumas funcoes chamadas a partir
			//da funcao Fa070Data. A retirada destas causara problemas a rotina.
			cBanco   	:= cBco110
			cAgencia 	:= cAge110
			cConta		:= cCta110
//			fA070Data() // Calcula o desconto e o juros (se houver) e valida a data
//			F110Ret()
            
			If nCM1 > 0
				nJuros += nCM1
			Else
				nDescont -= nCM1
			EndIf
	
			If nProRata > 0
				nJuros += nProRata
			Else
				nDescont -= nProRata
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PONTO DE ENTRADA FA110DES                                     ³
			//³ ExecBlock para calculo de descontos                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFa110Desc
				nDescont := Execblock("FA110DES",.F.,.F.)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PONTO DE ENTRADA FA110JUR                                     ³
			//³ ExecBlock para calculo de Juros                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFa110Juros
				nJuros := Execblock("FA110JUR",.F.,.F.)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PONTO DE ENTRADA FA110MUL                                     ³
			//³ ExecBlock para calculo de Multas                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFa110Mult
				nMulta := Execblock("FA110MUL",.F.,.F.)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Soma Titulos Abatimentos                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea( "ABAT" )
			dbSetOrder( 2 )
			dbSeek( xFilial("SE1")+cCliente+cLoja+cPrefixo+cNumero+cParcela )
			nRecnoSe1 := SE1->(Recno())

			While !Eof() .And. ;
				E1_FILIAL  == xFilial("SE1") .And. E1_CLIENTE == cCliente	.And.;
				E1_LOJA    == cLoja    			.And. E1_PREFIXO == cPrefixo	.And.;
				E1_NUM     == cNumero  			.And. E1_PARCELA == cParcela

				IF E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT .And.;
					E1_SALDO   >  0            .And.;
					E1_CLIENTE == cCLIENTE

					nTotAbat += E1_SALDO //Round(NoRound(xMoeda(E1_SALDO,E1_MOEDA,1,,3,If(cPaisLoc=="BRA",E1_TXMOEDA,0)),3),2)
					nValAbat += E1_SALDO
					ABATIMENTO := nTotAbat
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega variavies para contabilizacao dos    ³
					//³ abatimentos (impostos da lei 10925).         ³			
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If E1_TIPO == MVPIABT
						VALOR5 := E1_VALOR			
					ElseIf E1_TIPO == MVCFABT
						VALOR6 := E1_VALOR
					ElseIf E1_TIPO == MVCSABT
						VALOR7 := E1_VALOR						
					Endif			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza a Baixa do Titulo     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE1->(Msgoto(ABAT->(Recno())))
					RecLock("SE1",.F.)
					Replace E1_SALDO	With 0
					Replace E1_BAIXA	With dDataBase
					Replace E1_MOVIMEN  With dDataBase
					Replace E1_STATUS   With "B"
					MsUnlock( )
					DbSelectArea("ABAT")
				EndIF
				dbSkip()
			Enddo
			DbSetOrder(1)
			dbSelectArea( "SE1" )
			MsGoto(nRecnoSe1)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a Baixa do Titulo                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Os titulos de abatimentos ja foram baixados no processo acima.
			If ! SE1->E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT .And.;
				SE1->E1_SALDO > 0
				RecLock("SE1")
				SE1->E1_SALDO	:= 0
				SE1->E1_BAIXA	:= dDataBase
				SE1->E1_MOVIMEN := dDataBase
				SE1->E1_JUROS	:= 0 //nJuros + nAcresc
				SE1->E1_CORREC	:= 0//nCorrec
				SE1->E1_DESCONT	:= 0//nDescont + nDecresc
				SE1->E1_MULTA  	:= 0//nMulta
				SE1->E1_VALLIQ	:= nSaldoCru//-nTotAbat //+nJuros+nMulta-nDescont+nAcresc-nDecresc
				SE1->E1_STATUS  := Iif(E1_SALDO>0.01,"A","B")
				SE1->E1_SDACRES := 0 
				SE1->E1_SDDECRE := 0 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Salva os campos na tabela SE1 especifico do Template GEM       ³
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistTemplate("GEMSE1Grv")
					ExecTemplate("GEMSE1Grv",.F.,.F.)
				EndIf
				MsUnlock( )
			Endif	
			nValorTotal += SE1->E1_VALLIQ
         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Para numerar as sequencias o sistema precisa procurar os	³
			//³ registros com  tipodoc igual a VL, BA ou CP.					³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTipoSeq := {"CP","BA","VL","V2","LJ"}
			cSequencia := "00"
			dbSelectArea("SE5")
			SE5->(dbSetOrder(2))
			For nX := 1 to len(aTipoSeq)
				SE5->(dbSeek(xFilial("SE5") + aTipoSeq[nX] + SE1->E1_PREFIXO + SE1->E1_NUM + ;
													  SE1->E1_PARCELA + SE1->E1_TIPO) )

				While !SE5->(Eof()) .And. ;
						SE5->E5_FILIAL  == xFilial("SE5")  .And. ;
						SE5->E5_TIPODOC == aTipoSeq[nX]    .And. ;
						SE5->E5_PREFIXO == SE1->E1_PREFIXO .And. ;
						SE5->E5_NUMERO  == SE1->E1_NUM     .And. ;
						SE5->E5_PARCELA == SE1->E1_PARCELA .And. ;
						SE5->E5_TIPO    == SE1->E1_TIPO

					If cSequencia < SE5->E5_SEQ
						cSequencia := SE5->E5_SEQ
					Endif
					SE5->( dbSkip() )
				Enddo
			Next nX
			cSequencia := Soma1(cSequencia,2)
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Joga em variaveis o valor do Acrescimo e Decrescimo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			nJuros   := nJuros   + nAcresc
			nDescont := nDescont + nDecresc
			cPadrao  := fA070Pad()
			lPadrao  := VerPadrao( cPadrao )
	   
			lGravaAglut := ! SE1->E1_SITUACA $ "27"
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registro referente … movimenta‡„o bancaria ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To 5
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a Movimenta‡„o Banc ria									  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nX==1
					cCpoTp  := "SE1->E1_VALLIQ"
					cTpDoc  := Iif(SE1->E1_SITUACA$"27","V2",Iif(!lGerTotal .And. MovBcoBx(cMotBx, .T.),"VL","BA"))
					cHistMov	:= IIF(MovBcoBx(cMotBx, .T.),OemToAnsi( "Valor recebido s /Titulo" ),; // "Valor recebido s /Titulo"
															cDescrMo	)
					nValRec := SE1->E1_VALLIQ
					nSE1Rec := SE1->(Recno())
				Elseif nX==2
					cCpoTp  := "nJuros"
					cTpDoc  :=IIF(SE1->E1_SITUACA$"27","J2","JR")
					cHistMov:=OemToAnsi( "Juros s/Receb.Titulo" ) //"Juros s/Receb.Titulo"
				Elseif nX==3
					cCpoTp  :="nDescont"
					cTpDoc  :=IIF(SE1->E1_SITUACA$"27","D2","DC")
					cHistMov:=OemToAnsi( "Juros s/Receb.Titulo" ) //"Juros s/Receb.Titulo"
				Elseif nX==4
					cCpoTp  := "nCorrec"
					cTpDoc  :=IIF(SE1->E1_SITUACA$"27","C2","CM")
					cHistMov:=OemToAnsi( "Correcao Monet s/Receb.Titulo" )//"Correcao Monet s/Receb.Titulo"
				Elseif nX==5
					cCpoTp  := "nMulta"
					cTpDoc  :=IIF(SE1->E1_SITUACA$"27","M2","MT")
					cHistMov:=OemToAnsi( "Multa s/Receb.Titulo" ) //"Multa s/Receb.Titulo"
				Endif

				If &cCpoTp != 0 .or. nX == 1
					Reclock("SE5",.T.)
					SE5->E5_FILIAL		:= xFilial()
					SE5->E5_PREFIXO		:=	SE1->E1_PREFIXO
					SE5->E5_NUMERO		:= SE1->E1_NUM
					SE5->E5_PARCELA		:= SE1->E1_PARCELA
					SE5->E5_CLIFOR		:= SE1->E1_CLIENTE
					SE5->E5_CLIENTE		:= SE1->E1_CLIENTE
					SE5->E5_LOJA		:= SE1->E1_LOJA
					SE5->E5_BENEF		:= SE1->E1_NOMCLI
					SE5->E5_VALOR		:= &cCpoTp
					SE5->E5_SEQ			:= cSequencia
					SE5->E5_DATA		:= SE1->E1_BAIXA
					SE5->E5_HISTOR		:= cHistMov
					SE5->E5_NATUREZ		:= SE1->E1_NATUREZ
					SE5->E5_RECPAG		:= If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG, "P","R")
					SE5->E5_TIPO		:= SE1->E1_TIPO
					SE5->E5_DOCUMEN		:= SE1->E1_NUMBOR
					SE5->E5_DTDIGIT		:= dDataBase
					SE5->E5_TIPODOC		:= cTpDoc
					SE5->E5_MOTBX		:= Iif(Empty(cMotBx),"NOR",TrazCodMot( cMotBx ))
					SE5->E5_VLMOED2		:= xMoeda(&cCpoTp.,1,SE1->E1_MOEDA,SE1->E1_BAIXA,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
					SE5->E5_DTDISPO 	:= dDtCredito
					SE5->E5_SITCOB 		:= SE1->E1_SITUACA
					If MovBcoBx(cMotBx, .T.)
						SE5->E5_BANCO	:= cBco110
						SE5->E5_AGENCIA	:= cAge110
						SE5->E5_CONTA	:= cCta110
					Endif
					If lGerTotal
						SE5->E5_ARQCNAB := "FINA110"
						SE5->E5_LOTE   	:= cLoteFin
						SE5->E5_BANCO	:= SEA->EA_PORTADO
						SE5->E5_AGENCIA	:= SEA->EA_AGEDEP
						SE5->E5_CONTA	:= SEA->EA_NUMCON
						cBco110			:= SEA->EA_PORTADO
						cAge110			:= SEA->EA_AGEDEP
						cCta110			:= SEA->EA_NUMCON
					Endif
					
					If nx == 1	// registro totalizador
						Replace E5_VLJUROS With nJuros
						Replace E5_VLMULTA With nMulta
						Replace E5_VLCORRE With nCorrec
						Replace E5_VLDESCO With nDescont
						If lAcreDecre
							Replace SE5->E5_VLACRES With nAcresc
							Replace SE5->E5_VLDECRE With nDecresc
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Salva os campos na tabela SE5 especifico do Template GEM       ³
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistTemplate("GEMSE5Grv")
							ExecTemplate("GEMSE5Grv",.F.,.F.)
						EndIf
						
						nRegPrinc := SE5->(Recno())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava o lançamento de integração com o SIGAPCO ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                    PcoDetLan("000012","01","FINA110")
					Endif
					If lSpbInUse
						SE5->E5_MODSPB := "1"
					Endif
					If lPadrao .and. mv_par03 == 1 .and. nX != 1 
						SE5->E5_LA := "S "
					Endif
					MsUnlock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ PONTO DE ENTRADA FA110SE5                                     ³
					//³ ExecBlock para gravar dados complementares a baixa do titulo  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFa110Se5
						Execblock("FA110SE5",.F.,.F.)
					Endif
					aadd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())})
					If !lGerTotal .And. MovBcoBx(cMotBx, .T.) .and. !(SE1->E1_SITUACA $ "27") .and. nX == 1
						AtuSalBco(cBco110,cAge110,cCta110,SE5->E5_DATA,SE5->E5_VALOR,If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG,"-","+"))
					Endif
				EndIf
			Next
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o Cadastro de CLIENTES     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")
			If dbSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
				IF SE1->E1_MOEDA > 1
					nSaldoCru := nSaldo//Round(NoRound(xMoeda(nSaldo-nValAbat,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,3,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)),3),2)
				Else
					nSaldoCru -= nTotAbat				
				Endif
				AtuSalDup("-",nSaldoCru,1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica qual o Lanc Padrao que sera utilizado      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			nC++
			IF nC == 1 .And. lPadrao
				nHdlPrv:=HeadProva(cLote,"FINA110",Substr(cUsuario,7,6),@cArquivo)	
			Endif

			IF lPadrao .and. mv_par03 == 1 .And. nHdlPrv > 0
				dbSelectArea("SE5")
				dbGoto(nRegPrinc)
				Reclock("SE5")
				nTotal		+=	DetProva(nHdlPrv,	cPadrao,"FINA110",cLote	)
				If nTotal > 0
					SE5-> E5_LA	:=	"S"+Substr(E5_LA,2,1)
				Endif
				MsUnlock()
			Endif
			dbSelectArea("SE1")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PONTO DE ENTRADA DE TEMPLATES FA110DES                        ³
			//³ ExecBlock generico anterior a contabiliza‡Æo                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTFINA110
				ExecTemplate("FINA110",.f.,.f.)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PONTO DE ENTRADA FA110DES                                     ³
			//³ ExecBlock generico anterior a contabiliza‡Æo                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFINA110
				Execblock("FINA110",.f.,.f.)
			Endif
			END TRANSACTION
		EndIf

		If GETMV("MV_TPCOMIS") == "O"  .and. ComisBx( TrazCodMot(cMotBx) ) 
			Fa440CalcB(aBaixas,lJuros,lDesconto,"FINA110",,,,.T.,nSE1Rec)
		Endif

		dbSelectArea("SE1")
		If !lEof
			dbGoTo(nProxReg)
		EndIf
	Enddo                      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza processo de integracao com SIGAPCO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PCOFinLan("000012")
	
	//Ponto de entrada para geracao de recibo com todos os titulos baixados
	If lF110Rec
		ExecBlock("F110REC",.F.,.F.)
	Endif

	// vai para EOF() para contabilizar apenas o total
	dbSelectArea( "SE1" )
	dbGoBottom()
	dbSkip()
	// Credito do Banco = Variavel VALOR
	VALOR := nValorTotal
	If lPadrao .and. mv_par03 == 1 .and. nC > 0 .and. nValorTotal > 0  .And. nHdlPrv > 0
		nTotal+=DetProva( nHdlPrv,cPadrao,"FINA110",cLote	)
	EndIF

	If nC > 0 .And. lPadrao .and. mv_par03 == 1 .And. nTotal > 0
		RodaProva(nHdlPrv,nTotal)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lan‡amento Cont bil, se gerado arquivo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lDigita:=IIF(mv_par01==1,.T.,.F.)
	lAglut :=IIF(mv_par02==1,.T.,.F.)
	IF nC > 0 .And. lPadrao .and. mv_par03 == 1 .And. nHdlPrv > 0
		cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
	Endif
	VALOR := 0
	dbSelectArea( "ABAT" )
	dbCloseArea()
	dbSelectArea( "SE1" )
	RetIndex("SE1")
	Set Filter to
   Exit
Enddo

If __lSX8
	RollBackSX8()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera registro totalizador no SE5, caso baixa seja    ³
//³ aglutinada (BX_CNAB=S)   									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValorTotal > 0 .And. lGerTotal .And. lGravaAglut
	Reclock( "SE5" , .T. )
	SE5->E5_FILIAL := xFilial()
	SE5->E5_DATA   := dDataBase
	SE5->E5_VALOR  := nValorTotal
	SE5->E5_RECPAG := "R"
	SE5->E5_DTDIGIT:= dDataBase
	SE5->E5_BANCO  := cBco110
	SE5->E5_AGENCIA:= cAge110
	SE5->E5_CONTA  := cCta110
	SE5->E5_DTDISPO:= dDataBase
	SE5->E5_LOTE   := cLoteFin
	SE5->E5_HISTOR :=  "Baixa Automatica / Lote : " + " / " + "Baixa Automatica / Lote : " + " " + cLoteFin // "Baixa Automatica / Lote : "
	If lSpbInUse
		SE5->E5_MODSPB := "1"
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PONTO DE ENTRADA FA110TOT                                          ³
	//³ ExecBlock para gravar dados complementares ao registro totalizador ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("FA110TOT")
		Execblock("FA110TOT",.F.,.F.)
	Endif
	MsUnlock( )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza saldo bancario.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AtuSalBco(cBco110,cAge110,cCta110,SE5->E5_DATA,SE5->E5_VALOR,"+")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os ¡ndices                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE1")
RetIndex("SE1")
dbSetOrder(nSavOrd1)
dbSeek(xFilial())
FErase (cIndex+OrdBagExt())

RestArea(aArea)
SetKey(VK_F4, {|| NIL})
Return (.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa110blank³ Autor ³ Mauricio Pequim Jr 	  ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Limpa o campo E1_OK para efetuar marca‡„o. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa110blank() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA110																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa110Blank()

Reclock("SE1")
Replace E1_OK with "  "
MsUnlock()


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa110ChecF³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Condi‡„o para Indice Condicional						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa110ChecF() 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa110ChecF()

Local cFiltro

cFiltro := 'E1_SALDO>0.and.'
cFiltro += 'E1_FILIAL=="'+xFilial()+'".and.'
cFiltro += 'DTOS(E1_VENCREA)>="'+DTOS(dVencIni)+'".and.'
cFiltro += 'DTOS(E1_VENCREA)<="'+DTOS(dVencFim)+'".and.' 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o parametro MV_ANTCRED esteja desligado, os titulos com data de       ³
//³emissao inferior a DataBase nao farao parte do filtro, pois nao tem sentido³
//³aparecerem titulos que "ainda nao foram emitidos".                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GetMv("MV_ANTCRED") 
	cFiltro += 'DTOS(E1_EMISSAO)<="'+DTOS(dDataBase)+'".and.'
EndIf
cFiltro += 'E1_CLIENTE >="'+cCliDe        +'".and.'
cFiltro += 'E1_CLIENTE <="'+cCliAte       +'".and.'
If !Empty(cBord110)
	cFiltro += 'E1_NUMBOR=="'+cBord110      +'".and.'
Else
	If mv_par06 == 1 // Filtra pelo banco informado
		cFiltro += 'E1_PORTADO=="'+cBco110 +'".and.'
		cFiltro += 'E1_AGEDEP=="' +cAge110 +'".and.'
		cFiltro += 'E1_CONTA=="'  +cCta110 +'".and.'
	Endif	
Endif
If mv_par08 == 1
	cFiltro += '!(E1_TIPO$"'+MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM+'")'
Else
	cFiltro += '(E1_TIPO$"'+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM+'")'
Endif	
// Verifica integracao com PMS e nao permite baixar titulos que tenham solicitacoes
// de transferencias em aberto.
cFiltro += ' .And. Empty(E1_NUMSOL)'

If !Empty(cFil110)
	cFiltro := '(' +cFiltro+ ').and.(' +cFil110+ ')' 
Endif
//Spiller: 25/09/2017 - FILTRA APENAS IMPORTADOS 
If lImporta//alltrim(cMotBxIMP) == 'SÓ IMPORTADOS'  
	cFiltro +=  ' .And. !(Empty(E1_XDTIMP))'
Endif

Return cFiltro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa110Corre³ Autor ³ Mauricio Pequim Jr 	  ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a corre‡„o monet ria.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa110Corr()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Gen‚rico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa110Correc( )

Local nCorrecao := 0
Local nValAtual := 0
Local nValEmiss := 0

//alert("correcao")

IF SE1->E1_MOEDA > 1
	IF Int(SE1->E1_VLCRUZ) = Int(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0)))
		nValEmiss := SE1->E1_VLCRUZ
	Else
		If(SE1->(FieldPos("E1_TXMDCOR")>0 ) .And. !Empty(SE1->E1_TXMDCOR))
			nValEmiss := xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,Iif(Empty(SE1->E1_DTVARIA),SE1->E1_EMISSAO,SE1->E1_DTVARIA),8,SE1->E1_TXMDCOR)
		Else
			nValEmiss := xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,Iif(Empty(SE1->E1_DTVARIA),SE1->E1_EMISSAO,SE1->E1_DTVARIA),8,Iif(Empty(SE1->E1_DTVARIA),SE1->E1_TXMOEDA,0))
		EndIf
	EndIF
	nValAtual := xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dDataBase)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica atraves do parametro MV_CALCCM se sera calculada a cor-³
	//³ recao monetaria.                                           	  ³
	//³ Caso o parametro nao exista, sera assumido "S"						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	If GetMv("MV_CALCCM") 
//    If MV_PAR09 == 1
//		nCorrecao := nValAtual - nValEmiss
//	Else
		nCorrecao := 0
//	Endif
Endif
Return (nCorrecao)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fA110Par	³ Autor ³ Mauricio Pequim Jr 	  ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ativa Parƒmetros do Programa										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fA110Par()
pergunte("FIN110",.T.)
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa110Marca³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata o valor	para marcar e desmarcar item					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa110Marca(ExpN1,ExpD1,ExpD2) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA110																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa110Marca(cAlias,cMarca)
Local lBxTit := .T.
Local nAbat  := 0

Local nRec
Local cAliasAnt := Alias()

dbSelectArea(cAlias)
nRec	:= Recno()
DbGoTop()
While !Eof()
	nJuros   := 0
	nMulta	 := 0
	nCM1 	 := 0
	nProRata := 0
//	fA070Data() // Calcula o desconto e o juros (se houver) e valida a data
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PONTO DE ENTRADA F110TIT                                      ³
	//³ Verifica se titulo pode ser marcado para baixa ou nÆo. Caso	³
	//³ tenha sido alterada a marca‡Æo do titulo, ExecBlock dever     ³
	//³ retornar .F., para nÆo haver altera‡Æo dos acumuladores de    ³
	//³ valores e numero de titulos.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lBxTit := .T.
	nAbat := SomaAbat(E1_PREFIXO,E1_NUM,E1_PARCELA,"R",E1_MOEDA,dDataBase,E1_CLIENTE,E1_LOJA)
	If SE1->(MsRLock()) // Se conseguir travar o registro		
		SE1->E1_OK := cMarca
		If (ExistBlock("F110TIT"))
			lBxTit := ExecBlock("F110TIT",.F.,.F.)
		Endif
		If lBxTit       
//		    alert("marca")
			nValor += E1_SALDO//xMoeda(E1_SALDO,SE1->E1_MOEDA,1,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
			nQtdTit++
		Endif
	Endif
	dbSkip()
EndDo
dbGoto(nRec)
dbSelectArea(cAliasAnt)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AGX444bAval ³ Autor ³ Mauricio Pequim Jr.  ³ Data ³ 02/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloco de marcacoo       			          						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AGX444bAval()		  													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA110																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AGX444bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,nValor)
Local lRet 		:= .T.

// Verifica se o registro nao esta sendo utilizado em outro terminal
If SE1->(MsRLock())
	AGX444Inverte(cAliasSe1,cMarca,oValor,oQtdTit,.F.,oMark,@nValor) // Marca o registro e trava
	lRet := .T.
Else
	IW_MsgBox("Este titulo está sendo utilizado em outro terminal","Atenção","STOP") //"Este titulo está sendo utilizado em outro terminal"###"Atenção"
	lRet := .F.
Endif	
oMark:oBrowse:Refresh(.t.)
Return lRet



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FA110Inver³ Autor ³ Mauricio Pequim Jr 	  ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca todos os titulos								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA110																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGX444Inverte(cAliasSe1,cMarca,oValor,oQtda,lTodos,oMark,nValor)
Local nReg		:= SE1->(Recno())
Local lBxTit := .T. 
Local nAbat := 0

DEFAULT lTodos  := .T.

dbSelectArea("SE1")
If lTodos
	dbSeek(cFilial)
Endif

While !lTodos .or. (!Eof() .and. cFilial == E1_FILIAL)

	If (lTodos .And. SE1->(MsRLock())) .Or. !lTodos
		nJuros   := 0
		nCM1     := 0
		nProRata := 0
		nMulta   := 0
//		fA070Data() // Calcula o desconto e o ? (se houver) e valida a data
//		nAbat := SomaAbat(E1_PREFIXO,E1_NUM,E1_PARCELA,"R",E1_MOEDA,dDataBase,E1_CLIENTE,E1_LOJA)
		IF SE1->E1_OK == cMarca
			SE1->E1_OK	:= "  "
			SE1->(MsUnlock()) 
//			ALERT(E1_SALDO)
			nValor -= E1_SALDO //xMoeda(E1_SALDO,SE1->E1_MOEDA,1,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
			nQtdTit--
		Else
			lBxTit := .T.
			SE1->E1_OK	:= cMarca
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PONTO DE ENTRADA F110TIT                                      ³
			//³ Verifica se titulo pode ser marcado para baixa ou nÆo. Caso	³
			//³ tenha sido alterada a marca‡Æo do titulo, ExecBlock dever     ³
			//³ retornar .F., para nÆo haver altera‡Æo dos acumuladores de    ³
			//³ valores e numero de titulos.                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF (ExistBlock("F110TIT")) .and. !Empty(E1_OK)
				lBxTit := ExecBlock("F110TIT",.F.,.F.)
			Endif
			If lBxTit
				nValor += E1_SALDO//xMoeda(E1_SALDO,SE1->E1_MOEDA,1,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
				nQtdTit++
			Endif
		Endif
	Endif
	If lTodos
		dbSkip()
	Else
		Exit
	Endif	 
Enddo
nQtdTit:= Iif(nQtdTit<0,0,nQtdTit)
SE1->(dbGoto(nReg))
oValor:Refresh()
oQtda:Refresh()
oMark:oBrowse:Refresh(.t.)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F110BxBord³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controla permissao de baixa automatica de bordero   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA110													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F110BxBord()
Local lBxBord := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA F110BOR                                      ³
//³ Verifica se bordero pode baixado ou nÆo. 							³
//³ ExecBlock dever  retornar .F., para nÆo baixar o bordero em   ³
//³ questao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("F110BOR")
	lBxBord := ExecBlock("F110BOR",.F.,.F.)
Endif
Return lBxBord

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³VerCliFor ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 06/01/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega  as variaveis Cliente/Fornecedor e Loja             ³±±
±±³			 ³Carrega os proximos campos quando valor digitado for encon- ³±±
±±³			 ³trado. 																	  ³±±
±±³			 ³As variaveis cClifor e cLoja deverÆo ser passadas por refe- ³±±
±±³			 ³rencia.         														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³VerCliFor(ExpC1,ExpC2,ExpL1,ExpC3)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cliente/Fornecedor,Loja,Flag para Help no ato (default= .T.)³±±
±±³			 ³Carteira                                						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerCliForn(cCliFor,cLoja,lHelp,cCarteira)
Local cAlias:=Alias()
Local cChave:=cCliFor+Iif(Empty(cLoja),"",cLoja)
Local lRet:=.T.
Local cArea := IIF(cCarteira == "R", "A1","A2")
Local cOpenArq := "S" + cArea

If (cCliFor = NIL) .or. (cCarteira = NIL)
	lRet := .F.
Endif

If lRet
	lHelp := Iif( lHelp=Nil,.T.,lHelp)
	DbSelectArea(cOpenArq)
	DbSetOrder(1)
	If !DbSeek(xFilial()+cChave)
		If lHelp
			Help(" ",1,IIF(cCarteira == "R","NOCLIENTE","NOFORNEC"))
		EndIf
		lRet := .F.
	Else
		cLoja := Iif(cLoja==NIl.or.Empty(cLoja),&cArea._LOJA,cLoja)
	Endif
Endif
DbSelectArea( cAlias )
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa110TudOk³ Autor ³ Claudio D. de Souza   ³ Data ³ 22/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida os gets da tela inicial da baixa automatica          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Fa110TudOk(.T./.F.)        								           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lBxCnab - Se a baixa se aglutinada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA110  																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa110TudOk(lBxCnab)
Local lRet := .T.

// Valida todos os gets
Do Case
Case !(dVencFim >= dVencIni)
	lRet := .F.
Case !(cCliAte >= cCliDe)
	lRet := .F.
Case MovBcoBx(cMotBx, .T.) .and. !(CarregaSa6(@cBco110,,,.T.)) 
	lRet := .F.
Case MovBcoBx(cMotBx, .T.) .and. !(CarregaSa6(@cBco110,@cAge110,,.T.))
	lRet := .F.
Case MovBcoBx(cMotBx, .T.) .and. !(CarregaSa6(@cBco110,@cAge110,@cCta110,.T.,,.T.))
	lRet := .F.
Case !(ShowMotBx("R",.T.))
	lRet := .F.
Case !(F110BXBORD() .and. IIF(!MovBcoBx(cMotBx, .T.),Empty(cBord110),.T.))
	lRet := .F.
Case (!Empty(cBord110) .And. lBxCnab)  .And. !(CheckLote("R"))
	lRet := .F.
EndCase

If lRet .and. ExistBlock("F110TOK")
	lRet := ExecBlock("F110TOK",.F.,.F.,{cBco110,cAge110,cCta110})
Endif

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F110Ret   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 25/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tratamento de retencao na data de credito					 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA110				 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F110Ret()

Local nJ := 0

dDtCredito := dBaixa
If mv_par07 == 1 // Considera retencao bancaria
	SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
	
	If !(SA6->(Eof())) .AND. SA6->A6_RETENCA > 0 .AND. SE1->E1_SITUACA $ "12347"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza data vencto real c/reten‡„o Banc ria³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nj:=1 To SA6->A6_RETENCA
			dDtCredito = DataValida(dDtCredito+1,.T.)
		Next nj
	Else
		dDtCredito := dDataBase
	Endif
Endif	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³22/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina	:= {	{ "Pesquisa"  , "AxPesqui" , 0 , 1,,.F. },; // "Pesquisa"
						{ "Parametros", "fA110Par", 0 , 1},; // "Parƒmetros"
						{ "Automatica", "alert('Desabilitado, Somente Liberado para Importação!')", 0 , 4},; // "Automtica"  "U_AGX444AAA"
						{ "Importar Arq."  , "U_AGX444IM", 0 , 4},; // "Automtica"
						{ OemToAnsi("Legenda")	,"FA040Legenda", 0 , 6, ,.F.} } //"Legenda"
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA110BtOK ³ Autor ³ Gustavo Henrique     ³ Data ³ 11/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao no botao OK da tela de baixa					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA110BtOK()			 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA110													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA110BtOK()

Local lFa110BtOk	:= ExistBlock("F110BtOK")
Local lRet := .T.

If lFa110BtOk
	lRet := ExecBlock("F110BtOK",.F.,.F.)
Endif      

Return lRet

      
//Busca Titulo
Static Function BuscaTit()
                         
 	Local oDlgBusca
	Local oButton1
	Local oGet1
	Local cGet1 := "                    "
	Local oSay1   
	Local lconfirm := .F.
	
    DEFINE MSDIALOG oDlgBusca TITLE "Buscar Títulos" FROM 000, 000  TO 100, 280 COLORS 0, 16777215 PIXEL
	
	    @ 011, 009 SAY oSay1 PROMPT "Prefixo+Título+Parcela" SIZE 074, 007 OF oDlgBusca COLORS 0, 16777215 PIXEL
	    @ 024, 009 MSGET oGet1 VAR cGet1 SIZE 075, 010 OF oDlgBusca COLORS 0, 16777215 PIXEL
	    @ 023, 089 BUTTON oButton1 PROMPT "Buscar" ACTION(oDlgBusca:END(),lconfirm := .T.)SIZE 037, 012 OF oDlgBusca PIXEL
    
    ACTIVATE MSDIALOG oDlgBusca 
     
    //Se confirmou Busca
    If lconfirm 
	 	 nGetRec := SE1->(Recno())
		 dbselectarea('SE1')
		 dbsetorder(1)
	
		 If !(dbseek(xfilial('SE1')+alltrim(cGet1)))
		     Alert('Título não encontrado')
		 	 SE1->(dbgoto(nGetRec))
		 Endif
	Endif
 
Return

              
//Leandro Spiller  -25/09/2017
//Importa .CSV de Pagamentos utilizado pela Raizen
User function AGX444IM()
                  
   	Local lretArq     := .F.
	Private aCab 		  := {}
	Private aItem		  := {}
	Private cNumPedcom  := ''
	Private cCondPgto   := ''
	Private cItem       := '0001'
	Private nOpc        := 3
	Private lMsErroAuto := .F. 
	Private _CPERG 	  := "AGX444IM"    
	Private aDados 	  := {}
	Private aItens    := {} 
	Private cArqIMP   := ""  

	
	PutSx1(_cPerg,"01","Arquivo     "	,"","","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{'Informe o Arquivo a ser Importado!'},{},{})
	
	If !(Pergunte(_CPERG))
	   	//Retorna pergunte da Tela Inicial 
    	pergunte("FIN110",.F.)
	    Return
	Endif          
	 
	//Valida Arquivo
	If Alltrim(MV_PAR01) == ''
   	    MSGINFO("  Selecione o arquivo!","Inválido")
   	    //Retorna pergunte da Tela Inicial 
    	pergunte("FIN110",.F.)
   	    Return                  
 	Else
  		cArqIMP := Alltrim(MV_PAR01)
  	Endif   
   
   	//Retorna pergunte da Tela Inicial 
    pergunte("FIN110",.F.)
    
    If !('.csv' $ Alltrim(cArqIMP))
 		MSGINFO("O arquivo deve estar no formato .CSV!","Inválido")
    	Return
   	Endif
       
   Processa( {|| lretArq := GrvSE1() })  
    
   If lretArq
   	u_AGX444AAA('SE1',SE1->(recno()),3,.T.)      
   Endif
Return    
        

//Lê arquivo e grava SE1
Static Function GrvSE1()  

	Private nposCli    := 0 
    Private nposLoja   := 0
    Private nposLote   := 0
    Private nposPref   := 0
    Private nposNum    := 0
    Private nposParc   := 0
    //Local nposDtEmis := 0
    Private nposSitua  := 0
    Private nposValor  := 0
    Private nposValPG  := 0
    Private nposSitua  := 0
    Private nposStatus := 0 
    Private nPosSaldo  := 0 
    Private nLin       := 0
    Private aMsgErro   := {} 
    Private cMsgErro   := ""
       
	nHandle := FT_FUSE(cArqIMP)
    
    If nHandle < 0
    	MSGINFO("Arquivo vazio ou inválido!","Inválido")
    	Return
    Endif
    
    //Leandro Spiller - 25/09/2017
    //Limpa Data de Importação
    cQryUPd := " UPDATE "+Retsqlname('SE1')+" SET E1_XDTIMP = '' "
    cQryUPd += " WHERE E1_BAIXA = '' AND E1_XDTIMP <> ''"
    cQryUPd += " AND D_E_L_E_T_ = ''"
    If (TCSQLExec(cQryUPd) < 0)
		Conout("Falha ao executar SQL: " + cQryUPd)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf

    ProcRegua((FT_FLASTREC()*2))

    //FT_FGOTOP()

    While !FT_FEOF()
         
      	nLin++
      	
        IncProc("Lendo arquivo...")
     
        cLinha := FT_FREADLN()
                       
        AADD(aDados,Separa(cLinha,";",.T.))
        
        //Lê cabeçalho
     	If nLin == 1
   			nposCli    := aScan(aDados[nLin],"Cod Cliente")
		    nposLoja   := aScan(aDados[nLin],"Loja")
		    nposLote   := aScan(aDados[nLin],"Lote")
		    nposPref   := aScan(aDados[nLin],"Prefixo")
		    nposNum    := aScan(aDados[nLin],"Numero")
		    nposParc   := aScan(aDados[nLin],"Parcela")
		    //nposDtEmis := aScan(aDados,{|x| Alltrim(x[1])=="Data Emissão"})
		    nposSitua  := aScan(aDados[nLin],"Situacao Titulo")
		    nposValor  := aScan(aDados[nLin],"Vlr. Titulo")
		    nposValPG  := aScan(aDados[nLin],"Valor Pago")
		    nposSitua  := aScan(aDados[nLin],"Situacao Titulo")
		    nposStatus := aScan(aDados[nLin],"Status Pagto") 
		  	nPosSaldo  := aScan(aDados[nLin],"Saldo") 
		  	          
		    //Valida se leu todos as colunas do cabeçalho
		    If nposCli== 0 .and. nposLoja== 0 .and. nposLote== 0 .and. nposPref== 0 .and. nposNum== 0 .and. nposParc== 0 .and.;
		     nposSitua== 0 .and. nposValor== 0 .and. nposValPG== 0 .and. nposSitua== 0 .and. nposStatus== 0 
		    	alert(' Não foi possível ler campo da planilha, Verifique o arquivo!  ')
		    	 FT_FUSE()
                Return .F.
       		Endif
       	
       	Endif
     	
     	FT_FSKIP()

    EndDo          
    
    FT_FUSE()         
        
    //Se não há dados Retorna        
    If Len(aDados) == 0 
    	Alert('Não foram encontrados dados no arquivo! ')
   		Return .F.
   	Endif	

	nTamCli  := TAMSX3('E1_CLIENTE')[1]
    nTamLoja := TAMSX3('E1_LOJA')[1]
    nTamPref := TAMSX3('E1_PREFIXO')[1]
    nTamNum  := TAMSX3('E1_NUM')[1]
                                                  
	For i := 2 to len(aDados) 
	    IncProc("Gravando dados...")
		//Busca título para efeturar a baixa
		If alltrim(aDados[i][nposNum]) <> ''
		     
			//Se foi pago valor integral
			//já grava senão verifica se nao foi pago por lote ou a menos
			If StrtoVal(aDados[i][nPosSaldo]) == 0  
				DbSelectarea('SE1')
				DbSetOrder(1)//DbSetOrder(2) 
				         //FILIAL + CLIENTE + LOJA + PREFIXO + NUMERO
				If DbSeek(xFilial('SE1')+;		//PADR(aDados[i][nposCli],nTamCli,'')+;	PADR(aDados[i][nposLoja],nTamLoja,'')+;
					PADR(aDados[i][nposPref],nTamPref,'')+;
			   		PADR(aDados[i][nposNum],nTamNum,''))
			   		If !(EMPTY(SE1->E1_BAIXA))
			   			AADD(aMsgErro,{' Título já baixado: ',aDados[i][nposPref]+aDados[i][nposNum]+' R$ '+alltrim(str(SE1->E1_VALOR))})
			   		Endif
			   					   		
	               Reclock('SE1',.F.)
	                  SE1->E1_XDTIMP := dDataBase
	               SE1->(MsUnlock())  
		    	Else
		    		AADD(aMsgErro,{' Título não encontrado: ',aDados[i][nposPref]+aDados[i][nposNum]}) 
		    	Endif  
		    Else
		    	//Verifica lotes e Só grava se foi pago o valor integral
		    	//Retorna na linha que parou a verificação
		    	i := GrvLote(i)
		    Endif               	
		Endif    

	Next i 
	
	//Mostra Msg de erro
	If Len(aMsgErro) > 0  
		For i := 1 to len(aMsgErro) 
			cMsgErro += aMsgErro[i][1]+aMsgErro[i][2]+chr(13)
		Next i    
		_cArquivo := StrTran( alltrim(cArqIMP),".csv", "_LOG.txt" )
		//_cArquivo := alltrim(MV_PAR01)+'_LOG.TXT'    
		MemoWrite(_cArquivo, cMsgErro ) 
	    alert(' Arquivo importado com divergências, Verifique: '+chr(13)+_cArquivo)
    Else
    	MSGINFO("  Arquivo importado com Sucessso!  ","Importado")
	Endif


Return  .T.
          
         
//Verifica e grava pagamentos por LOTE
Static function GrvLote(_i)
     
  Local nSomaPago := 0  
  Local nSomaVal  := 0     
                                 
  //Captura o lote corrente
  cNumLote := aDados[_i][nposLote]  
  
  //Varre arquivo e valida se pagou todos os títulos
  For x := _i to len(aDados)  
      if alltrim(cNumLote) ==  alltrim(aDados[x][nposLote])
      	 nSomaVal  += StrtoVal(aDados[x][nposValor])
      	 nSomaPago += StrtoVal(aDados[x][nposValPG])
      Else 
      	 x--
         EXIT
      Endif 
  Next x
  
  nDiferenca := 0            
  If nSomaVal > nSomaPago   
  	nDiferenca := (nSomaVal - nSomaPago)
  Elseif  nSomaVal < nSomaPago      
  	nDiferenca :=  (nSomaPago - nSomaVal)     
  Endif
                                       
  // A pedido do Fernando foi colocado uma Margem de R$1,00 
  // para divergencias dee valores para importação.
  If nDiferenca > 1 
  	 AADD(aMsgErro,{' Divergência Valor Pago, Lote: ', cNumLote+' - '+alltrim(str(nSomaVal))+' -> '+alltrim(str(nSomaPago))})
  Else  
  	 //Varre da numeração inicial até final do lote
  	 For y := _i to x
	  	 DbSelectarea('SE1')
		 DbSetOrder(1)//DbSetOrder(2) 
		 			//FILIAL + CLIENTE + LOJA + PREFIXO + NUMERO
		 If DbSeek(xFilial('SE1')+;//	PADR(aDados[y][nposCli],nTamCli,'')+;	PADR(aDados[y][nposLoja],nTamLoja,'')+;
						PADR(aDados[y][nposPref],nTamPref,'')+;
				   		PADR(aDados[y][nposNum],nTamNum,''))  
				   		
				If !(EMPTY(SE1->E1_BAIXA))
			   			AADD(aMsgErro,{' Título já baixado: ',aDados[Y][nposPref]+aDados[Y][nposNum]+' R$ '+alltrim(str(SE1->E1_VALOR))})
			   	Endif
			   	
				Reclock('SE1',.F.)
		   	   		 SE1->E1_XDTIMP := dDataBase
		   	 	SE1->(MsUnlock())  		    
	  	 Else
		
		   		AADD(aMsgErro,{' Título não encontrado: ',aDados[y][nposPref]+aDados[y][nposNum]}) 
		 Endif
	 Next y  
  Endif
  
Return x
    
//Transforma String em Valor
Static function StrtoVal(xValor) 
	
	Local nRetVal := 0                                                  
                                                  

	nRetVal := Val(Strtran(;
	               Strtran(;
	               Strtran(StrTran( xValor,".", "" );
	               ,"R$", "" );
	               ,',','.');
	               ,' ','')) 

Return nRetVal