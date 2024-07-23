#INCLUDE "FINA470.CH"
#include "fileio.ch"
#Include "Protheus.ch"
#Include "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinA470  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reconcilia‡ao Bancaria Extra                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fina470()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR123()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("AFI470",.F.)

PRIVATE aRotina:= { { STR0001 ,"U_AGR123PAR()" , 0 , 1},;  // "Parƒmetros"
                    { STR0002 ,"AxVisual" , 0 , 2},;  // "Visualizar"
                    { STR0003 ,"U_AGR123GERA()", 0 , 4} }  // "Reconcilia‡„o"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de baixas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//PRIVATE cCadastro := STR0006  //"Reconcilia‡„o Banc ria Autom tica" 
Private cCadastro := "Reconciliacao Bancaria Extra" 
Private cMv_par01 := mv_par01 
Private cMv_par02 := mv_par02 
Private cMv_par03 := mv_par03 
Private cMv_par04 := mv_par04 
Private cMv_par05 := mv_par05 
Private cMv_par06 := mv_par06 
Private cMv_par07 := mv_par07 
Private cMv_par08 := mv_par08 
Private cMv_par09 := mv_par09 
Private cMv_par10 := mv_par10 
Private cMv_par11 := mv_par11 
Private cMv_par12 := mv_par12 
Private cMv_par13 := mv_par13 
Private cMv_par14 := mv_par14 
Private cMv_par15 := mv_par15 
 

mBrowse( 6, 1,22,75,"SE5")
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fA470Ger ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reconcilia‡„o Banc ria Extra                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA470Ger()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA470                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR123GERA(cAlias)

Processa({|lEnd| fa470Ger(cAlias)})  // Chamada com regua
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fA470Gera³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reconciliacao Bancaria Extra                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA470Ger()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FinA470                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fA470Ger(cAlias)
Local cPosNum,cPosData,cPosValor,cPosOcor,cPosDescr,cPosDif
Local cColorAnt
Local lPosNum  :=.F.,lPosData  :=.F.,lPosValor :=.F.
Local lPosOcor :=.F.,lPosDescr :=.F.,lPosDif   :=.F.
Local lPosBco  :=.F.,lPosAge   :=.F.,lPosCta   :=.f.
Local nLidos,nLenNum,nLenData,nLenValor,nLenDescr,nLenOcor,nLenDif
Local nLenBco,nLenAge,nLenCta
Local cArqConf,cArqEnt,xBuffer, cRecTRB
Local dDtaCred := CRIAVAR("E5_DTDISPO")
Local cData, cDebCred
Local nSavRecno:= Recno()
Local nPos
Local aTabela 	:= {}
Local cIndex	:= " "					
Local cMotSist	:= Space(3)				// motivo da ocorrencia no sistema
Local cMotBan	:= Space(3)				// motivo da ocorrencia no banco
Local nSeq		:= 0						// controle sequencial de lancto do Banco
Local lSaida	:= .F.
Local nValBco
Local nOpca := 0
Local aTam:=TamSX3("E5_CONTA")
Local nTamConta := aTam[1]  			// Tamanho do campo de C.Corrente no sistema
Local aCores 	:= {}
Local nCont, li
Local nHdlBco := 0
Local aAC := { STR0004,STR0005 }  //"Abandona"###"Confirma"
Local cBanco
Local cAgencia
Local cConta
Local cDifer
Local lReconc := .F.
Local oOk	:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oNo	:= LoadBitmap( GetResources(), "DISABLE" )
Local oParc	:= LoadBitmap( GetResources(), "BR_AMARELO" )
LOCAL oJaRec	:= LoadBitmap( GetResources(), "BR_CINZA" )
LOCAL cVarQ   	:= "  "
LOCAL oTitulo, oBtn
LOCAL oDlg
Local lPosVSI	:=.F.,lPosDSI :=.F.,lPosDCI :=.F.
Local nLenVSI,nLenDSI,nLenDCI
Local cPosVSI,cPosDSI,cPosDCI
Local aPosicoes := {}
Local lFa470Cta := ExistBlock("FA470CTA")
Local aConta, dDtIniA, dDtFinA
Local lFebraban := .F.
Local dOldDispo := Ctod("//")
Local lGrava := .T.
Local lF470Grv := ExistBlock("F470GRV")
Local nTipoDat := 1
Private lF470AtuDt := ExistBlock("F470ATUDT")//chamado 54826- Historico conciliação bancária									   
Private cMsnCodMot:= ""

Aadd(aCores,oOk)
Aadd(aCores,oNo)
Aadd(aCores,oParc)
Aadd(aCores,oJaRec)

Private cArqRec1, cArqRec2, cArqRec3, cArqRec4 := ""
Private lMarca  	  := 1
Private dDtIni		  := CTOD("01/01/2099","ddmmyy")
Private dDtFin		  := CTOD("01/01/1980","ddmmyy")  

//inicializa Variaveis para gravação da descrição
Private lFirstExec    := .T.
Private aRecon        := {}   
Private _nPosRecon 	  := 0 
Private _cDescReco    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Banco indicado                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SA6")
If dbSeek(xFilial("SA6")+cMv_par03+cMv_par15+cMv_par13)   // Banco+Agencia+Conta
	dbSelectArea("SEE")
	DbSetOrder(1)
	If dbSeek(xFilial("SEE")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON)
		If cMv_par14 == 1 // Tipo Banco
			lFebraban := IIF(SEE->EE_BYTESXT > 200 , .t., .f.)
		Endif
		nTamDet	 := IIF(SEE->EE_BYTESXT > 0, SEE->EE_BYTESXT + 2, 202 )
	Else
		Help(" ",1,"PAR150")
		Return .F.
	Endif
Else
	Help(" ",1,"FA100BCO")
	Return(.f.)
Endif
nTipoDat := IIF(nTamDet > 202, 4,1)		//1 = ddmmaa		4= ddmmaaaa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqConf:=cMv_par02
IF !FILE(cArqConf)
	Help(" ",1,"A470NOPAR")
	Return .F.
Else
	nHdlConf:=FOPEN(cArqConf,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlConf,0,0)
nTamArq:=FSEEK(nHdlConf,0,2)
FSEEK(nHdlConf,0,0)

While nLidos <= nTamArq
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o tipo de qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(85)
	FREAD(nHdlConf,@xBuffer,85)
	If cMv_par14 == 1	// Bancos
		IF SubStr(xBuffer,1,1) == CHR(1)  // Header
			nLidos+=85
			Loop
		EndIF

		IF SubStr(xBuffer,1,1) == CHR(4) // Saldo Final
			nLidos+=85
			Loop
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados do Saldo Inicial (Bco/Ag/Cta)       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !lPosBco  //Nro do Banco
			cPosBco:=Substr(xBuffer,17,10)
			nLenBco:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosBco:=.T.
			nLidos+=85
			Loop
		EndIF
		IF !lPosAge  //Agencia
			cPosAge :=Substr(xBuffer,17,10)
			nLenAge :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosAge :=.T.
			nLidos+=85
			Loop
		End
		IF !lPosCta  //Nro Cta Corrente
			cPosCta=Substr(xBuffer,17,10)
			nLenCta=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosCta=.T.
			nLidos+=85
			Loop
		Endif
		IF !lPosDif   // Diferencial de Lancamento
			cPosDif  :=Substr(xBuffer,17,10)
			nLenDif  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDif  :=.t.
			nLidos+=85
			Loop
		EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Os dados abaixo nÆo sÆo utilizados na reconcilia‡Æo. ³
		//³ EstÆo ai apenas p/leitura do arquivo de configura‡Æo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !lPosVSI   // Valor Saldo Inicial
			cPosVSI  :=Substr(xBuffer,17,10)
			nLenVSI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosVSI  :=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDSI   // Data Saldo Inicial
			cPosDSI  :=Substr(xBuffer,17,10)
			nLenDSI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDSI  :=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDCI   // Identificador Deb/Cred do Saldo Inicial
			cPosDCI  :=Substr(xBuffer,17,10)
			nLenDCI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDCI  :=.t.
			nLidos+=85
			Loop
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados dos Movimentos                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !lPosNum  // Nro do Lancamento no Extrato
			cPosNum:=Substr(xBuffer,17,10)
			nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosNum:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosData  // Data da Movimentacao
			cPosData:=Substr(xBuffer,17,10)
			nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosData:=.t.
			nLidos+=85
			Loop
		End
		IF !lPosValor  // Valor Movimentado
			cPosValor=Substr(xBuffer,17,10)
			nLenValor=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosValor=.t.
			nLidos+=85
			Loop
		End
		IF !lPosOcor // Ocorrencia do Banco
			cPosOcor	:=Substr(xBuffer,17,10)
			nLenOcor :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosOcor	:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDescr  // Descricao do Lancamento
			cPosDescr:=Substr(xBuffer,17,10)
			nLenDescr:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDescr:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDif   // Diferencial de Lancamento
			cPosDif  :=Substr(xBuffer,17,10)
			nLenDif  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDif  :=.t.
			nLidos+=85
			Loop
		EndIF
	ElseIf cMv_par14 == 2   // Febraban
		Aadd( aPosicoes, { Substr(xBuffer,2,15),Val(Substr(xBuffer,17,3)),;
							1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3))) })
		nLidos +=85
		Loop
	Endif
	Exit
EndDo
If cMv_par14 == 2 // Febraban
	cPosBco	:= STRZERO(aPosicoes[1,2],3)
	nLenBco	:= aPosicoes[1,3]
	cPosDif	:= STRZERO(aPosicoes[2,2],3)
	nLenDif	:= aPosicoes[2,3]
	cPosAge	:=	STRZERO(aPosicoes[6,2],3)
	nLenAge	:= aPosicoes[6,3]
	cPosCta	:= STRZERO(aPosicoes[7,2],3)
	nLenCta	:= aPosicoes[7,3]
	cPosNum	:= STRZERO(aPosicoes[8,2],3)
	nLenNum	:= aPosicoes[8,3]
	cPosData	:= STRZERO(aPosicoes[9,2],3)
	nLenData	:= aPosicoes[9,2]
	cPosValor:= STRZERO(aPosicoes[10,2],3)
	nLenValor:= aPosicoes[10,3]
	cPosOcor	:= STRZERO(aPosicoes[11,2],3)
	nLenOcor := aPosicoes[11,3]
	cPosDescr:= STRZERO(aPosicoes[12,2],3)
	nLenDescr:= aPosicoes[12,3]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ fecha arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Fclose(nHdlConf)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se constam dados banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cPosBco) .or. Empty(cPosAge)   .or. Empty(cPosCta)  .or.;
	Empty(cPosDif) .or. Empty(cPosValor) .or. Empty(cPosOcor) .or.;
	Empty(cPosData) 
	Help(" ",1,"A470NOCFG")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqEnt:=alltrim(cMv_par01)
IF !FILE(cArqEnt)
	Help(" ",1,"A470NOBCO")
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF

//Verifica se o arquivo de retorno bancafio ja foi processado
If !(Chk470File())
	If nHdlBco > 0
		FClose(nHdlBco)
	Endif
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
F470CRIARQ()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha o cursor e o salva para poder moviment -lo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua( nTamArq / nTamDet , 24 )
nLidos := 0
While nLidos <= nTamArq
	IncProc()
	nValor  :=0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipo qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(nTamDet)
	FREAD(nHdlBco,@xBuffer,nTamDet)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o diferencial do registro de Lancamento 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMv_par14 == 1	
		cDifer :=Substr(xBuffer,Int(Val(Substr(cPosDif, 1,3))),nLenDif )
	Else
		cDifer := "xx"
	Endif

	// Header do arquivo
	If cMv_par03 == "237"
		IF (SubStr(xBuffer,1,1) == "0" .and. cMv_par14 == 1 .and. !lFebraban) .or. ;   // Bancos
			( cDifer == "0" .and. lFebraban) .or. ; //Bancos 240 bytes/linha
			(Substr(xBuffer,8,1) == "0" .and. cMv_par14 == 2 )	// Febraban
			cDataArq := SubStr(xBuffer,95,2)+'/'+SubStr(xBuffer,97,2)+'/'+SubStr(xBuffer,99,2)
			dDataArq := ctod(cDataArq)
			nLidos+=nTamDet
			Loop
		EndIF
	ElseIf cMv_par03 == "001"
		IF (SubStr(xBuffer,1,1) == "0" .and. cMv_par14 == 1 .and. !lFebraban) .or. ;   // Bancos
			( cDifer == "0" .and. lFebraban) .or. ; //Bancos 240 bytes/linha
			(Substr(xBuffer,8,1) == "0" .and. cMv_par14 == 2 )	// Febraban
			cDataArq := SubStr(xBuffer,144,2)+'/'+SubStr(xBuffer,146,2)+'/'+SubStr(xBuffer,148,4)
			dDataArq := ctod(cDataArq)
			nLidos+=nTamDet
			Loop
		EndIf
	ElseIf cMv_par03 == "246"
		IF (SubStr(xBuffer,1,1) == "0" .and. cMv_par14 == 1 .and. !lFebraban) .or. ;   // Bancos
			( cDifer == "0" .and. lFebraban) .or. ; //Bancos 240 bytes/linha
			(Substr(xBuffer,8,1) == "0" .and. cMv_par14 == 2 )	// Febraban
			cDataArq := SubStr(xBuffer,144,2)+'/'+SubStr(xBuffer,146,2)+'/'+SubStr(xBuffer,148,4)
			dDataArq := ctod(cDataArq)
			nLidos+=nTamDet
			Loop
		EndIf
    ElseIf cMv_par03 == "033"
		IF (SubStr(xBuffer,1,1) == "0" .and. cMv_par14 == 1 .and. !lFebraban) .or. ;   // Bancos
			( cDifer == "0" .and. lFebraban) .or. ; //Bancos 240 bytes/linha
			(Substr(xBuffer,8,1) == "0" .and. cMv_par14 == 2 )	// Febraban
			cDataArq := SubStr(xBuffer,144,2)+'/'+SubStr(xBuffer,146,2)+'/'+SubStr(xBuffer,14839,4)
			dDataArq := ctod(cDataArq)
			nLidos+=nTamDet
			Loop
		EndIf
	EndIf

	//Trailer do arquivo
	IF (SubStr(xBuffer,1,1) == "9" .and. cMv_par14 == 1 .and. !lFebraban) .or. ;	// Bancos
		( cDifer == "9" .and. lFebraban) .or. ;  //Bancos 240 pos
		(Substr(xBuffer,8,1) == "9" .and. cMv_par14==2)			// Febraban
		nLidos+=nTamDet
		dbSelectArea("TRB")
		dbGoTop()
		IF BOF() .and. EOF()
			lSaida := .T.
		Endif
		Exit
	EndIF

	// Saldo Inicial - Exceto Febraban
	IF cMv_par14 == 1 .and. ;
		((SubStr(xBuffer,1,1) == "1" .and. cDifer == "0" .and. !lFebraban ) .or. ;
		 (cDifer == "1" .and. lFebraban))
		cBanco   :=Substr(xBuffer,Int(Val(Substr(cPosBco, 1,3))),nLenBco )
		cAgencia :=Substr(xBuffer,Int(Val(Substr(cPosAge, 1,3))),nLenAge )
		cConta   :=Substr(xBuffer,Int(Val(Substr(cPosCta, 1,3))),nLenCta )
		If lFa470Cta
			aConta   := ExecBlock("FA470CTA", .F., .F., {cBanco, cAgencia, cConta} )
			cBanco   := aConta[1]
			cAgencia := aConta[2]
			cConta   := aConta[3]
		Endif
		If AllTrim(cBanco)+AllTrim(cAgencia)+AllTrim(cConta) != AllTrim(cMv_par03)+AllTrim(cMv_par15)+AllTrim(cMv_par13)
			Help(" ",1,"FA470CONTA")
			lSaida := .T.
			Exit
		Endif
		nLidos+=nTamDet
		Loop
	EndIF

	// Saldo Final - Exceto Febraban
	IF cMv_par14 == 1 .and. ;
		((SubStr(xBuffer,1,1) == "1" .and. cDifer == "2" .and. !lFebraban) .or. ;
		 ( cDifer == "5" .and. lFebraban))
		nLidos+=nTamDet
		Loop
	EndIF

	//Lancamentos	- Todos
	IF (SubStr(xBuffer,1,1) == "1" .and. cDifer == "1" .and. !lFebraban ) .or. ; // Bancos
		( cDifer == "3" .and. lFebraban) .or. ; // Bancos 240 pos
		cMv_par14 == 2		// Febraban

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lˆ os valores do arquivo Retorno ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMv_par14 == 2	// Febraban
			cBanco   :=Substr(xBuffer,Int(Val(Substr(cPosBco, 1,3))),nLenBco )
			cAgencia :=Substr(xBuffer,Int(Val(Substr(cPosAge, 1,3))),nLenAge )
			cConta   :=Substr(xBuffer,Int(Val(Substr(cPosCta, 1,3))),nLenCta )
			If lFa470Cta
				aConta   := ExecBlock("FA470CTA", .F., .F., {cBanco, cAgencia, cConta} )
				cBanco   := aConta[1]
				cAgencia := aConta[2]
				cConta   := aConta[3]
			Endif
			If AllTrim(cBanco)+AllTrim(cAgencia)+AllTrim(cConta) != AllTrim(cMv_par03)+AllTrim(cMv_par15)+AllTrim(cMv_par13)
				Help(" ",1,"FA470CONTA")
				lSaida := .T.
				Exit
			Endif
		Endif
		cCodMot	:= Space(04)
		cNumMov 	:=Substr(xBuffer,Int(Val(Substr(cPosNum,1,3))),nLenNum)
		cDataBco :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
		cDataBco :=ChangDate(cDataBco,nTipoDat)
		dDataMov	:=Ctod(Substr(cDataBco,1,2)+"/"+Substr(cDataBco,3,2)+"/"+Substr(cDataBco,5,2),"ddmmyy")
		cDataMov	:=dToc(dDataMov)
		dDtIni 	:=MIN(dDtIni,dDataMov)
		dDtFin 	:=MAX(dDtFin,dDataMov)
		cValorMov:=Transform(Round(Val(Substr(xBuffer,Int(Val(Substr(cPosValor,1,3))),nLenValor))/100,2),"@E 999,999,999,999.99")
		cCodMov	:=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
		cDescrMov:=Substr(xBuffer,Int(Val(Substr(cPosDescr,1,3))),nLenDescr)
		If cMv_par03 == "237"
			cCodMot	:= Substr(xBuffer,(46),4)
			//cSeqExt2	:= Substr(xBuffer,(198),3)
			cSeqExt2	:= Substr(xBuffer,(196),5)
		ElseIf cMv_par03 == "001"   
			cCodMot	:= "0" + Substr(xBuffer,(170),3)
			//cSeqExt2	:= Substr(xBuffer,(11),3)
			cSeqExt2	:= Substr(xBuffer,(9),5)
		ElseIf cMv_par03 == "246"   
			cCodMot	:= "0" + Substr(xBuffer,(170),3)
			//cSeqExt2	:= Substr(xBuffer,(11),3)
			cSeqExt2	:= Substr(xBuffer,(9),5)
		ElseIf cMv_par03 == "033"   
			cCodMot	:= "0" + Substr(xBuffer,(170),3)
			//cSeqExt2	:= Substr(xBuffer,(11),3)
			cSeqExt2	:= Substr(xBuffer,(9),5)
		EndIf
      
      cNomDep  := ""
		If cCodMot == "0598" .or.;
		   cCodMot == "1321" 
		   cNomDep  := Substr(xBuffer,(106),20)
		Endif
		CONOUT(cSeqExt2)
		dbSelectArea("SEJ") 
		If dbSeek(xFilial("SEJ")+cBanco+cCodMov)
			cTipoMov 	:= SEJ->EJ_OCORSIS
			cDebCred 	:= SEJ->EJ_DEBCRE
		Else
			Help(" ",1,"FA470OCOR")
			lSaida := .T.
	  		Exit
		Endif

		lGrava := .T.
		If lF470GRV
			lGrava := ExecBlock("F470GRV",.F.,.F.,xBuffer)
		Endif
      
		lGeraReg := .F.
		DbSelectArea("SZD")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SZD")+CMV_PAR03+CMV_PAR15+CMV_PAR13+cCodMot)
			lGeraReg := .T.		
		Else
		    cMsnCodMot+=xFilial("SZD")+CMV_PAR03+CMV_PAR15+CMV_PAR13+cCodMot+"-"+cDescrMov+" ->"+Transform(Round(Val(Substr(xBuffer,Int(Val(Substr(cPosValor,1,3))),nLenValor))/100,2),"@E 999,999,999,999.99")+chr(13)    
		EndIf
		
		If lGrava .And. lGeraReg
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava dados no arquivo de trabalho³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("TRB",.T.)
			cRecTRB := STR(TRB->(Recno()))
			TRB->SEQMOV 	:= SUBSTR(cRecTRB,-4)
			TRB->DATAMOV  	:= cDataMov
			TRB->NUMMOV   	:= cNumMov
			TRB->VALORMOV 	:= cValorMov
			TRB->TIPOMOV	:= cTipoMov
			TRB->DEBCRED	:= cDebCred
			TRB->DESCRMOV	:= cDescrMov
			TRB->CODMOT		:= cCodMot
			TRB->OK     	:= 2		// N„O RECONCILIADO
			TRB->SEQEXT		:= cSeqExt2
			TRB->NOMDEP    := cNomDep
			TRB->DATARQ    := dDataArq
			MSUnlocK()
		Endif
	Endif
	nLidos += nTamDet
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo do Banco        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Fclose(nHdlBco)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa dados, caso tudo Ok      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
If BOf() .and. EOF() .and. !lSaida
	Help(" ",1,"ERROCONF")
	lSaida := .T.
Endif

dbSelectArea("TRB")
dbGoTop()

If alltrim(cMsnCodMot) <> ''	
   u_msgmemo("LOG",cMsnCodMot,.f.)
Endif             

//tratamento para arquivo com temporario vazio -> erro de array
If Empty(TRB->DATAMOV)
  MsgInfo("Parâmetros incorretos, favor verificar") 
  dbSelectArea("TRB")
  Set Filter To
  dbCloseArea()
  Return(.F.)
Endif
                      


DEFINE MSDIALOG oDlg TITLE cCadastro From 8.5,0 To 31.7,89.5 OF oMainWnd
@ 00.6,0 TO 10.3 , 44 LABEL cCadastro OF oDlg
@ 01.0,.5 	LISTBOX oTitulo VAR cVarQ FIELDS ;
		 		HEADER "", 	STR0010,;  //"Seq."
								STR0011,;  //"Data"
							 	STR0012,;  //"Docto.Bco."
								STR0013,;  //"Valor Extrato"
								STR0014,;  //"Tipo"
								STR0015,;  //"D/C"
								STR0016,;  //"Docto.SE5"
								STR0017;   //"Valor SE5"
				 COLSIZES 12,GetTextWidth(0,"BBB"),;
			 	 				 GetTextWidth(0,"BBBBB"),;
								 GetTextWidth(0,"BBBBBB"),;
								 GetTextWidth(0,"BBBBBBBBB"),;
 										 GetTextWidth(0,"BBB"),;
								 GetTextWidth(0,"BBB"),;
								 GetTextWidth(0,"BBBBBB"),;
								 GetTextWidth(0,"BBBBBBBBB");
SIZE 345,125.6 ON DBLCLICK	(FA470marca(oTitulo),oTitulo:Refresh()) NOSCROLL 
                                  

oTitulo:bLine := { || {aCores[TRB->OK],;
								TRB->SEQMOV 	,;
								TRB->DATAMOV	,;
								TRB->NUMMOV		,;
								PADR(TRB->VALORMOV,18)	,;
								TRB->TIPOMOV	,;
								TRB->DEBCRED	,;
								TRB->NUMSE5		,;
								PADR(TRB->VALORSE5,18) }}

DEFINE SBUTTON FROM 145.5,195 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 145.5,225 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oDlg
//DEFINE SBUTTON oBtn FROM 145.5,255 TYPE 4 ACTION (FA470EFET(oTitulo)) ENABLE PIXEL OF oDLG
//oBtn:cToolTip := STR0036 //"Efetiva Lancto."
DEFINE SBUTTON oBtn FROM 145.5,285 TYPE 11 ACTION (FA470LEG()) ENABLE PIXEL OF oDLG
oBtn:cToolTip := STR0019  //"Legenda"

ACTIVATE MSDIALOG oDlg 	

If nOpca == 1

	If FA470OK()
		DbSelectArea("TRB")
		DbGoTop()
		While !(TRB->(Eof()))
			DbSelectArea("SZD")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SZD")+CMV_PAR03+CMV_PAR15+CMV_PAR13+TRB->CODMOT)
				cNaturEfet		:= SZD->ZD_NATUREZA
				cCCC			:= SZD->ZD_CCC
				cCCD			:= SZD->ZD_CCD
				cItemD			:= ""
				cItemC			:= ""
				cClVlDb			:= ""
				cClVlCr			:= ""
				cCCrd			:= SZD->ZD_CREDITO
				cCDeb			:= SZD->ZD_DEBITO
				cHistor			:= ALLTRIM(SZD->ZD_HISTOR)+" DOC. "+ALLTRIM(TRB->NUMMOV)+" "+ALLTRIM(TRB->NOMDEP)

				FA470GrvEf(cNaturEfet,cCCC,cCCD,cItemD,cItemC,cClVlDb,cClVlCr,cCCrd,cCDeb,cHistor)
				

			EndIf
			
		
			DbSelectArea("TRB")
			DbSkip()
			Loop
		Enddo
	Endif	
EndIf

dbSelectArea("TRB")
Set Filter To
dbCloseArea()
Ferase(cArqRec1+ GetDBExtension())
Ferase(cArqRec1+OrdBagExt())
Ferase(cArqRec2+OrdBagExt())
Ferase(cArqRec3+OrdBagExt())
Ferase(cArqRec4+OrdBagExt())
IF SELECT("NEWSE5") != 0
   dbSelectArea( "NEWSE5" )
   dbCloseArea()
   If !Empty(cIndex)
	   FErase (cIndex+OrdBagExt())
   Endif
ENDIF	
dbSelectArea("SE5")
dbSetOrder(1)
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fA470Par  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aciona parametros do Programa                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR123PAR()
Pergunte( "AFI470" )
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F470CriArq³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 04/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria Estrutura do arquivo de trabalho   						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³F470CriArq() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function F470CriArq()
Local aDbStru	:= aTamSX3 := {}
aadd(aDbStru,{"SEQMOV    ","C",04,0})
aadd(aDbStru,{"SEQRECON  ","C",04,0})
aadd(aDbStru,{"DATAMOV   ","C",10,0})
aadd(aDbStru,{"NUMMOV    ","C",15,0})
aadd(aDbStru,{"VALORMOV  ","C",18,0})
aadd(aDbStru,{"TIPOMOV   ","C",03,0})
aadd(aDbStru,{"DEBCRED   ","C",01,0})
aadd(aDbStru,{"DESCRMOV  ","C",25,0})
aadd(aDbStru,{"NUMSE5    ","C",15,0})
aadd(aDbStru,{"VALORSE5  ","C",18,0})
aadd(aDbStru,{"RECSE5    ","N",09,0})
aadd(aDbStru,{"OK        ","N",01,0})
aadd(aDbStru,{"RECONSE5  ","C",01,0})
aadd(aDbStru,{"CODMOT    ","C",04,0})
aadd(aDbStru,{"SEQEXT    ","C",05,0})
aadd(aDbStru,{"NOMDEP    ","C",20,0})
aadd(aDbStru,{"DATARQ    ","D",08,0})

cArqRec1 := CriaTrab(aDbStru, .T. )
cArqRec2 := Left(CriaTrab(Nil, .F. ),7)+"A"
cArqRec3 := Left(CriaTrab(Nil, .F. ),7)+"B"
cArqRec4 := Left(CriaTrab(Nil, .F. ),7)+"C"
dbUseArea(.T.,,cArqRec1,"TRB",.F.,.F.)
IndRegua("TRB",cArqRec1,"DATAMOV+SEQMOV",,,STR0007)  //"Selecionando Registros..."
IndRegua("TRB",cArqRec2,"DATAMOV+NUMMOV+VALORMOV+DEBCRED",,,STR0007)  //"Selecionando Registros..."
IndRegua("TRB",cArqRec3,"DATAMOV+VALORMOV+DEBCRED",,,STR0007)  //"Selecionando Registros..."
If cMv_par04 # 0 .Or. cMv_par05 # 0
	IndRegua("TRB",cArqRec4,"NUMMOV+VALORMOV+DEBCRED",,,STR0007)  //"Selecionando Registros..."
	DbClearIndex()
	DbSetIndex(cArqRec1 + OrdBagExt())
	DbSetIndex(cArqRec2 + OrdBagExt())
	DbSetIndex(cArqRec3 + OrdBagExt())
	DbSetIndex(cArqRec4 + OrdBagExt())
Else
	DbClearIndex()
	DbSetIndex(cArqRec1 + OrdBagExt())
	DbSetIndex(cArqRec2 + OrdBagExt())
	DbSetIndex(cArqRec3 + OrdBagExt())
Endif

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470Marca³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Troca o flag para marcado ou nao,aceitando valor.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470Marca																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470Marca(oTitulo)
MsgStop("Funcao Desabilitada!!!")
oTitulo:Refresh()
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470Leg	³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Legenda da Reconcilia‡Æo Extra             			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470Leg 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470Leg()
Local oDlg2
Local nOpca2 	:= 0
Local lRet		:= .T.
DEFINE MSDIALOG oDlg2 FROM  69,70 TO 165,331 TITLE STR0026 PIXEL  //"Legenda - Reconcilia‡„o Autom tica"
@ 05 , 5 BITMAP NAME "BR_VERDE" 		SIZE 8,8 of Odlg2 PIXEL
@ 15 , 5 BITMAP NAME "BR_AMARELO" 	SIZE 8,8 of Odlg2 PIXEL
@ 25 , 5 BITMAP NAME "BR_CINZA" 		SIZE 8,8 of Odlg2 PIXEL
@ 35 , 5 BITMAP NAME "DISABLE" 		SIZE 8,8 of Odlg2 PIXEL
@ 05 , 19 SAY STR0023  	SIZE 115, 7 OF oDlg2 PIXEL  //"  Reconciliado"
@ 15 , 19 SAY STR0024  	SIZE 100, 7 OF oDlg2 PIXEL  //"  Reconciliado Parcial"
@ 25 , 19 SAY STR0035  	SIZE 100, 7 OF oDlg2 PIXEL  //"  Reconciliado Anteriormente"
@ 35 , 19 SAY STR0025  	SIZE 100, 7 OF oDlg2 PIXEL  //"  N„o Reconciliado"
DEFINE SBUTTON FROM 20, 100 TYPE 1 ENABLE ACTION (oDlg2:End()) OF oDlg2
ACTIVATE MSDIALOG oDlg2 CENTERED
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470GrvEf³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Efetivacao                                  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470GrvEf()															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470GrvEf(cNaturEfet,cCCC,cCCD,cItemD,cItemC,cClVlDb,cClVlCr,cCCrd,cCDeb,cHistor)
Local cValorMov, nPosPto
Local aFINA100 := {}
Private lMsErroAuto := .F.

If cMv_par03 == "237"
	//cArqCnab := Substr(CMV_PAR01,11,9)+TRB->SEQEXT
	cArqCnab := Substr(CMV_PAR01,11,7)+TRB->SEQEXT
	dE5_DATA := Ctod(TRB->DATAMOV,"ddmmyy")
	cE5_DATA := Dtos(dE5_DATA)
ElseIf cMv_par03 == "001"
	//cArqCnab := Substr(CMV_PAR01,15,9)+TRB->SEQEXT
	cArqCnab := Substr(CMV_PAR01,15,7)+TRB->SEQEXT
	dE5_DATA := Ctod(TRB->DATAMOV,"ddmmyyyy")
	cE5_DATA := Dtos(dE5_DATA)
ElseIf cMv_par03 == "246"
	//cArqCnab := Substr(CMV_PAR01,15,9)+TRB->SEQEXT
	cArqCnab := Substr(CMV_PAR01,15,7)+TRB->SEQEXT
	dE5_DATA := Ctod(TRB->DATAMOV,"ddmmyyyy")
	cE5_DATA := Dtos(dE5_DATA)
ElseIf cMv_par03 == "033"
	//cArqCnab := Substr(CMV_PAR01,15,9)+TRB->SEQEXT
	cArqCnab := Substr(CMV_PAR01,15,7)+TRB->SEQEXT
	dE5_DATA := Ctod(TRB->DATAMOV,"ddmmyyyy")
	cE5_DATA := Dtos(dE5_DATA)
EndIF
           
_cValor := ALLTRIM(STRTRAN(STRTRAN(TRB->VALORMOV,'.',''),',','.'))
cQuery1 := ""
cQuery1 += "SELECT R_E_C_N_O_ AS nIdRecno "
cQuery1 += "FROM "+RetSqlName("SE5")+" (NOLOCK) "
cQuery1 += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
cQuery1 += "AND D_E_L_E_T_ <> '*' "
cQuery1 += "AND E5_BANCO = '"+CMV_PAR03+"' "       
cQuery1 += "AND E5_AGENCIA = '"+CMV_PAR15+"' "	
cQuery1 += "AND E5_CONTA = '"+CMV_PAR13+"' "	
cQuery1 += "AND E5_DTDISPO = '"+cE5_DATA+"' "	
cQuery1 += "AND E5_ARQCNAB = '"+cArqCnab+"' "
cQuery1 += "AND E5_VALOR = "+_cValor+"" 
cQuery1 += "AND E5_ORIGEM <> 'AGR208' " // para não conciliar TALAO Chamado 72322	


If Select("F47001") <> 0
	dbSelectArea("F47001")
	dbCloseArea()
Endif

TCQuery cQuery1 NEW ALIAS "F47001"

nCont := 0
DbSelectArea("F47001")
DbGoTop()
While !Eof()  


	nCont := nCont + 1
	
	DbSelectArea("F47001")
   DbSkip()
EndDo
 
If cMv_par03 == "237"
	If nCont <> 0 .or. dE5_DATA >= TRB->DATARQ
		Return .F.
	EndIf
ElseIf cMv_par03 == "001"  
	If nCont <> 0 
		Return .F.
	EndIf
ElseIf cMv_par03 == "246"  
	If nCont <> 0 
		Return .F.
	EndIf
ElseIf cMv_par03 == "033"  
	If nCont <> 0 
		Return .F.
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma TRB->VALORMOV (em formato europeu) para formato Americano  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cValorMov := ConValor(TRB->VALORMOV,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Movimentacao da efetivacao no SE5.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

//Chamado 54826	- Historico conciliação bancária
//Se For a primeira execução lê o arquivo de Reconc.
If lFirstExec//lF470AtuDt 
	u_AGR123LE()
	lFirstExec := .F.
Endif 

_nPosRecon := 0 ;_cDescReco := ""

//Busca numero de movimento no array 
_nPosRecon := aScan(aRecon,{|x| Val(x[1]) == Val(TRB->SEQEXT)})
If _nPosRecon > 0 
	_cDescReco := aRecon[_nPosRecon][3]
Endif
           
aFINA100:={}

If TRB->DEBCRED == "D" //,"P" -> Pagar
  
   aFINA100 := { {"E5_FILIAL", xFilial("SE5") ,Nil},;
   {"E5_BANCO" ,cMv_par03 ,Nil},;
   {"E5_AGENCIA" ,cMv_par15 ,Nil},;
   {"E5_CONTA" ,cMv_par13 ,Nil},;
   {"E5_DATA"	, CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_DTDISPO", CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_VENCTO"	, CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_DTDIGIT", CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_HISTOR" , IIF(Empty(cHistor),TRB->DESCRMOV,cHistor),Nil},;
   {"E5_VALOR"	, Val(cValorMov),Nil},;
   {"E5_NATUREZ", cNaturEfet,Nil},;
   {"E5_MOEDA"  , IIF(TRB->TIPOMOV=="CHQ","C1","M1"),Nil},;
   {"E5_RECPAG" , IIF(TRB->DEBCRED=="D","P","R"),Nil},;
   {"E5_CCC"	, cCCC,Nil},;
   {"E5_CCD"	, cCCD,Nil},;
   {"E5_CREDITO", cCCrd,Nil},;
   {"E5_DEBITO"	, cCDeb,Nil},;
   {"E5_ARQCNAB", cArqCnab,Nil},;
   {"E5_RECONC" , "x",Nil},;
   {"E5_TIPOLAN", 'X',Nil},;      
   {"E5_MODSPB" , IIF(TRB->TIPOMOV=="CHQ","3","1"),Nil},;            
   {"E5_DTRECON", dDataBase,Nil},;
   {"E5_ITEMD"	, IIF(CtbInUse(),cItemD,""),Nil},;
   {"E5_ITEMC"	, IIF(CtbInUse(),cItemC,""),Nil},;
   {"E5_CLVLDB",  IIF(CtbInUse(),cClVlDb,""),Nil},;
   {"E5_CLVLCR",  IIF(CtbInUse(),cClVlCr,""),Nil},;
   {"E5_NUMCHEQ", IIF(TRB->TIPOMOV $ "CHQ",TRB->NUMMOV,""),Nil},;
   {"E5_HISTOR" , IIF(alltrim(_cDescReco) <> '',_cDescReco,""),Nil}}
  
   MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
   
   If lMsErroAuto

      MostraErro()

   EndIf 

//Endif

Else
//If TRB->DEBCRED <> "D" //,"R" -> Receber
  
   aFINA100 := { {"E5_FILIAL", xFilial("SE5") ,Nil},;
   {"E5_BANCO" ,cMv_par03 ,Nil},;
   {"E5_AGENCIA" ,cMv_par15 ,Nil},;
   {"E5_CONTA" ,cMv_par13 ,Nil},;
   {"E5_DATA"	, CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_DTDISPO", CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_VENCTO"	, CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_DTDIGIT", CTOD(TRB->DATAMOV,"ddmmyy"),Nil},;
   {"E5_HISTOR" , IIF(Empty(cHistor),TRB->DESCRMOV,cHistor),Nil},;
   {"E5_VALOR"	, Val(cValorMov),Nil},;
   {"E5_NATUREZ", cNaturEfet,Nil},;
   {"E5_MOEDA"  , IIF(TRB->TIPOMOV=="CHQ","C1","M1"),Nil},;
   {"E5_RECPAG" , IIF(TRB->DEBCRED=="D","P","R"),Nil},;
   {"E5_CCC"	, cCCC,Nil},;
   {"E5_CCD"	, cCCD,Nil},;
   {"E5_CREDITO", cCCrd,Nil},;
   {"E5_DEBITO"	, cCDeb,Nil},;
   {"E5_ARQCNAB", cArqCnab,Nil},;
   {"E5_RECONC" , "x",Nil},;
   {"E5_TIPOLAN", 'X',Nil},;   
   {"E5_MODSPB" , IIF(TRB->TIPOMOV=="CHQ","3","1"),Nil},;      
   {"E5_DTRECON", dDataBase,Nil},;
   {"E5_ITEMD"	, IIF(CtbInUse(),cItemD,""),Nil},;
   {"E5_ITEMC"	, IIF(CtbInUse(),cItemC,""),Nil},;
   {"E5_CLVLDB",  IIF(CtbInUse(),cClVlDb,""),Nil},;
   {"E5_CLVLCR",  IIF(CtbInUse(),cClVlCr,""),Nil},;
   {"E5_NUMCHEQ", IIF(TRB->TIPOMOV $ "CHQ",TRB->NUMMOV,""),Nil},;
   {"E5_HISTOR", IIf(alltrim(_cDescReco) <> '',_cDescReco,"") ,Nil}}
  
   MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,4)
 
   If lMsErroAuto

      MostraErro()

   EndIf 

Endif

/*/
RecLock("SE5",.T.)

	SE5->E5_FILIAL 	:= xFilial("SE5")
	SE5->E5_BANCO		:= mv_par03
	SE5->E5_AGENCIA	:= mv_par15
	SE5->E5_CONTA		:= mv_par13
	SE5->E5_DATA		:= CTOD(TRB->DATAMOV,"ddmmyy")
	SE5->E5_DTDISPO	:= CTOD(TRB->DATAMOV,"ddmmyy")
	SE5->E5_VENCTO		:= CTOD(TRB->DATAMOV,"ddmmyy")
	SE5->E5_DTDIGIT	:= CTOD(TRB->DATAMOV,"ddmmyy")
	SE5->E5_HISTOR 	:= IIF(Empty(cHistor),TRB->DESCRMOV,cHistor)
	SE5->E5_VALOR		:= Val(cValorMov)
	SE5->E5_NATUREZ	:= cNaturEfet
	SE5->E5_MOEDA  	:= IIF(TRB->TIPOMOV=="CHQ","C1","M1")
	SE5->E5_RECPAG 	:= IIF(TRB->DEBCRED=="D","P","R")
	SE5->E5_CCC			:= cCCC
	SE5->E5_CCD			:= cCCD
	SE5->E5_CREDITO	:= cCCrd
	SE5->E5_DEBITO		:= cCDeb
	SE5->E5_ARQCNAB	:= cArqCnab
	
	SE5->E5_RECONC  	:= "x"
	SE5->E5_TIPOLAN 	:= 'X'   
	SE5->E5_DTRECON     := dDataBase
	
	If CtbInUse()
		SE5->E5_ITEMD	:= cItemD
		SE5->E5_ITEMC	:= cItemC
		SE5->E5_CLVLDB	:= cClVlDb
		SE5->E5_CLVLCR	:= cClVlCr
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o movimento ‚ referente a um cheque e grava nro do cheque.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF TRB->TIPOMOV $ "CHQ"  
		SE5->E5_NUMCHEQ	:= TRB->NUMMOV
	Endif        
	
	//Grava historico da reconciliação
	If alltrim(_cDescReco) <> '' 
		SE5->E5_HISTOR	:= _cDescReco
	Endif

MsUnlock()        

/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza saldo bancario quando da efetivação de movimento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AtuSalBco(mv_par03,mv_par15,mv_par13,SE5->E5_DATA,SE5->E5_VALOR,iif(SE5->E5_RECPAG == "R","+","-"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava dados da Reconciliacao no TRB											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("TRB",.F.)
Replace TRB->RECSE5		With SE5->(RECNO())
Replace TRB->OK 		With 1
Replace TRB->VALORSE5	With Transform(SE5->E5_VALOR,"@E 999,999,999,999.99")
Replace TRB->NUMSE5		With SE5->E5_NUMCHEQ  
If _cDescReco <> ""
	Replace TRB->NUMSE5		With _cDescReco 
Endif
MsUnLock()


Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470OK	³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 13/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma ou nao a efetivacao.                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470OK																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470OK()
Return (MsgYesNo(STR0033,STR0034))  //"Confirma Efetiva‡„o ?"###"Aten‡„o"



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Chk470File³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 24/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa se arquivo de TB j  foi processado anteriormente		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Chk470File()  															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Fina470																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Chk470File()
LOCAL cFile := "CB"+cNumEmp+".VRF"
LOCAL lRet	:= .F.
LOCAL aFiles:= {}
LOCAL cString
LOCAL nTam
LOCAL nHdlFile

If !FILE(cFile)
	nHdlFile := fCreate(cFile)
ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tenta abrir o arquivo em modo exclusivo e Leitura/Gravacao ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (nHdlFile := fOpen(cFile,FO_READWRITE+FO_EXCLUSIVE))==-1 .AND. ;
			MsgYesNo( STR0013+cNumEmp+STR0014, STR0012 )
	End
Endif

If nHdlFile > 0

	nTam := TamSx1("AFI470","01")[1] // Tamanho do parametro
	xBuffer := SPACE(nTam)
	// Le o arquivo e adiciona na matriz
	While fReadLn(nHdlFile,@xBuffer,nTam) 
		Aadd(aFiles, Trim(xBuffer))
	Enddo	

	If ASCAN(aFiles,Trim(CMV_PAR15)) > 0
		lRet := MSGYESNO(STR0045,STR0034)		//"Arquivo de Conciliação já processado anteriormente. Deseja proseguir ?"###"Atenção"
	Else
		fSeek(nHdlFile,0,2) // Posiciona no final do arquivo
		cString := Alltrim(cMv_par15)+Chr(13)+Chr(10)
		fWrite(nHdlFile,cString)	// Grava nome do arquivo a ser processado
		lRet := .T.
	endif	
	fClose (nHdlFile)
Else
   Help(" ", 1, "CHK200ERRO") // Erro na leitura do arquivo de entrada
EndIf	
Return lRet 


//Lê arquivo de Reconciliação
User Function AGR123LE()

	Local cArqCNB := cMv_par01
	Local nTamDet := 202
	Local nHldBco
	Local nLidos
	Local nTamArq
	Local cNumMov
    
	cLeitura := TIME()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lˆ arquivo enviado pelo banco ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHdlBco := FOPEN(cArqCNB,0+64)
	nLidos  := 0

	FSEEK(nHdlBco,0,0)
	nTamArq := FSEEK(nHdlBco,0,2)
	FSEEK(nHdlBco,0,0)

	While nLidos <= nTamArq

		xBuffer:=Space(nTamDet)
		FREAD(nHdlBco,@xBuffer,nTamDet)

		// Lancamentos
		IF SubStr(xBuffer,1,1) == "1"   
			cSeqMov := Substr(xBuffer,195,006)
			cNumMov := Substr(xBuffer,075,006)  
			
	   		//Chamado: 54826 - Gravar historico conforme arquivo
	   		If alltrim(Substr(xBuffer,106,30)) <> ""
				AADD(aRecon,{  cSeqMov, cNumMov , Substr(xBuffer,106,30) } )
			Endif
		Endif
		nLidos += nTamDet
	Enddo
       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha arquivo do Banco        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fclose(nHdlBco) 
	
	cLeitura += ' ate '+time()  
	
	alert(cLeitura)
	
Return .T.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fclose(nHdlBco) 
	
	cLeitura += ' ate '+time()  
	
	alert(cLeitura)
	
Return .T.
