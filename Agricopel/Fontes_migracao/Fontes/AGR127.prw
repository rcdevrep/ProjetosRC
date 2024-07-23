#include "FINC021.CH"
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH" // VERIFICAR DECO

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE DATAFLUXO					1
#DEFINE ENTRADAS					2
#DEFINE SAIDAS						3
#DEFINE SALDODIA					4
#DEFINE VARIACAODIA				5
#DEFINE ENTRADASACUMULADAS		6
#DEFINE SAIDASACUMULADAS 		7
#DEFINE SALDOACUMULADO 			8 
#DEFINE VARIACAOACUMULADA		9 
#DEFINE CHEQUESRECEBER		  10 
#DEFINE ATRASOAPAGAR		  	  11 
#DEFINE ATRASOARECEBER	  	  12 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FINC021	³ Autor ³ Claudio D. de Souza   ³ Data ³ 04/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fluxo de Caixa 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINC021()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR127()
Local	nCaixas     := 0,; // Total em caixa
		nBancos	   := 0,; // Total em bancos
		oDlg			,;
		oGet01		,;
		oGetFilDe   ,;
		oGetValMin  ,;
		oGetDatIni ,;
		oGetTpSld ,;
		lReceber	  := .T.,;
		lPagar     := .T.,;
		lComissoes := .T.,;
		lPedVenda  := .T.,;
		lPedCompra := .T.,;
		lAplicacoes:= .F.,;
		lSaldoBanc := .F.,;
		lEstouro	  := .T.,;           
		lAnalitico := .F.,;
		lTitAtraso := .F.,;
		cFilDe     := "  ",;
		cFilAte    := "ZZ",;
		nMoeda     := 1   ,;
		aMoedas	  := {}  ,;
		cMoeda			   ,;				
		cPeriodo          ,;
		nPeriodos  := 10  ,;
		nDias             ,;
		nValMin    := 0   ,;		
		nOpcA      := 0   ,;
		cBancos    := ""  ,;
		oFnt              ,;
		nAtrReceber := 0  ,;
		nAtrPagar   := 0  ,;
		cAlias := Alias()
		
Local oGet02,;
		aBancos := {},;
		aAplic  := {},;		
		aCposAna,;
		cAliasPc,;
		cAliasPv,;
		cArqAnaPc,;
		oMenu   ,;
		aCmbPer,;
		aTpSld,;
		cFilterSe1,;
		cFilterSe2
		
Local cBancoCx := GetMV("MV_CARTEIR")

SetPrvt("dDatIni,lConsFil,cTpSld")
dDatIni		:= Ctod("01/01/01")
lConsFil   	:= .F.
cTpSld		:= "1"

aCmbPer := {STR0001,; //"01 Diario"
		      STR0002,; //"07 Semanal"
				STR0003,; //"10 Decendial"
			  	STR0004,; //"15 Quinzenal"
			  	STR0005 } //"30 Mensal"

aTpSld := {"1-Normal","2-Reconciliado","3-Ambos"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com as moedas existentes.	Para montar o combo de moedas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			  
aMoedas := GetMoedas()
ASort(aMoedas)

DEFINE MSDIALOG oDlg TITLE STR0006 FROM 0,0 TO 340,450 OF oMainWnd PIXEL FONT oMainWnd:oFont //"Selecione opçoes do Fluxo de Caixa"
@ 05, 05 CHECKBOX oGet01 VAR lReceber    PROMPT STR0007 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Titulos a Receber"
@ 18, 05 CHECKBOX oGet01 VAR lPagar      PROMPT STR0008 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Titulos a Pagar"
@ 31, 05 CHECKBOX oGet01 VAR lComissoes  PROMPT STR0009 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Comissões"
@ 44, 05 CHECKBOX oGet01 VAR lPedVenda   PROMPT STR0010 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Pedido de Venda"
@ 57, 05 CHECKBOX oGet01 VAR lPedCompra  PROMPT STR0011 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Pedido de Compra"
If !__lPyme
	@ 70, 05 CHECKBOX oGet01 VAR lAplicacoes PROMPT STR0012 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9; //"Aplicacoes/Emprestimos"
			ON CLICK If( lAplicacoes, (nMoeda := Val(Left(cMoeda,2)), aAplic := Aplicacoes(lConsFil,nMoeda)), NIL)
Endif			

@ 83, 05 CHECKBOX oGet01 VAR lSaldoBanc  PROMPT STR0013  FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9; //"Saldos Bancarios"
         ON CLICK If( lSaldoBanc, (nMoeda := Val(Left(cMoeda,2)), aBancos := Bancos( lConsFil, nMoeda, @nBancos, @nCaixas )), NIL )
@ 83,130 MSGET oGet01 VAR cBancos FONT oDlg:oFont PIXEL OF oDlg
@ 83,100 SAY "Tipo de Saldo"  FONT oDlg:oFont PIXEL OF oDlg  //"Valor minimo"
@ 83,150 COMBOBOX oGetTpSld VAR cTpSld ITEMS aTpSld  FONT oDlg:oFont PIXEL OF oDlg SIZE 50,54 Valid (IIF(lSaldoBanc, (nMoeda := Val(Left(cMoeda,2)), aBancos := Bancos( lConsFil, nMoeda, @nBancos, @nCaixas )), NIL ))

@ 96, 05 CHECKBOX oGet01 VAR lTitAtraso  PROMPT STR0014 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 //"Titulos em Atraso"
@ 96,100 SAY "Data Inicial"  FONT oDlg:oFont PIXEL OF oDlg  //"Valor minimo"
@ 96,150 MSGET oGetDatIni VAR dDatIni FONT oDlg:oFont PIXEL OF oDlg SIZE 60,9 PICTURE "99/99/99 " WHEN lTitAtraso

/*
@109, 05 CHECKBOX oGet01 VAR lEstouro    PROMPT STR0015 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 ON CLICK oGetValMin:SetFocus() //"Controla estouro de caixa"
@109,100 SAY STR0016 FONT oDlg:oFont PIXEL OF oDlg  //"Valor minimo"
@109,150 MSGET oGetValMin VAR nValMin FONT oDlg:oFont PIXEL OF oDlg SIZE 60,9 PICTURE "@E 999,999,999.99" WHEN lEstouro
  */
  
@121, 05 CHECKBOX oGet01 VAR lConsFil PROMPT STR0017 FONT oDlg:oFont PIXEL OF oDlg SIZE 50,9 ON CLICK oGetFilDe:SetFocus() //"Considera filiais"
@121, 80 SAY STR0018 FONT oDlg:oFont PIXEL OF oDlg //"Filial de"
@121,110 MSGET oGetFilDe VAR cFilDe FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "!!" WHEN lConsFil F3 "SM0"
@121,140 SAY STR0019 FONT oDlg:oFont PIXEL OF oDlg //"Ate"
@121,160 MSGET oGet01 VAR cFilAte FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "!!" WHEN lConsFil F3 "SM0"

@134, 05 SAY STR0020    FONT oDlg:oFont PIXEL OF oDlg //"Periodicidade"
@134, 50 COMBOBOX oGet01 VAR cPeriodo ITEMS aCmbPer FONT oDlg:oFont PIXEL OF oDlg SIZE 50,54
@134,100 SAY STR0021 FONT oDlg:oFont PIXEL OF oDlg  //"Quantos periodos"
@134,150 MSGET  oGet01 VAR nPeriodos   FONT oDlg:oFont PIXEL SIZE 30, 09 OF oDlg PICTURE "9999"

@147, 05 SAY STR0022 FONT oDlg:oFont PIXEL OF oDlg //"Moeda"
@147, 30 COMBOBOX oGet01 VAR cMoeda ITEMS aMoedas SIZE 60, 54 FONT oDlg:oFont PIXEL OF oDlg

@147, 100 CHECKBOX oGet01 VAR lAnalitico PROMPT STR0023 FONT oDlg:oFont PIXEL OF oDlg SIZE 70,9 //"Processa analitico"

DEFINE SBUTTON FROM 05,190 TYPE 17 ENABLE OF oDlg ACTION Fc021Filtro(@cFilterSe1,@cFilterSe2)
DEFINE SBUTTON FROM 20,190 TYPE  1 ENABLE OF oDlg ACTION (nOpcA := 1, oDlg:End())
DEFINE SBUTTON FROM 35,190 TYPE  2 ENABLE OF oDlg ACTION (nOpcA := 0, oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcA == 1
	// Recalcula o saldo em Bancos/Caixas de acordo com a moeda escolhida
	nMoeda	:= Val(Left(cMoeda,2))
	nBancos	:= 0
	nCaixas	:= 0
	aEval( aBancos, { |e| If( e[1], (e[6] := Transform(xMoeda(Val(StrTran(StrTran(e[6],".",""),",",".")),e[7],nMoeda),"@E 999,999,999.99"),;
									If( Left(e[2],2)=="CX" .Or. Left(e[2],3) $ cBancoCx,;
									nCaixas += Val(StrTran(StrTran(e[6],".",""),",",".")),;
								  	nBancos += Val(StrTran(StrTran(e[6],".",""),",",".")))),Nil)})

	Processa({|lEnd| Fc021Proc(lEnd,cMoeda,cPeriodo,nPeriodos,cFilDe,cFilAte,lReceber,;
										 lPagar,lComissoes,lPedVenda,lPedCompra,lAplicacoes,;
										 lSaldoBanc,lEstouro,lAnalitico,lConsFil,lTitAtraso,nValMin,;
										 nCaixas,nBancos,aBancos,aAplic,cFilterSe1,cFilterSe2)})
Endif
If !Empty(cAlias)
   DbSelectArea(cAlias)
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc021Proc ³ Autor ³ Claudio D. de Souza   ³ Data ³ 17/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa Fluxo de Caixa                			  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc021Proc												  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Financeiro												  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION Fc021Proc(lEnd,cMoeda,cPeriodo,nPeriodos,cFilDe,cFilAte,lReceber,lPagar,;
						 lComissoes,lPedVenda,lPedCompra,lAplicacoes,lSaldoBanc,;
						 lEstouro,lAnalitico,lConsFil,lTitAtraso,nValMin,nCaixas,nBancos,;
						 aBancos,aAplic,cFilterSe1,cFilterSe2)
						 
Local aCampos    ,; // Campos do arquivo temporario de trabalho
		aArqTmp    ,; // Nome do arquivo temporario e alias criado aleatoriamente
		aArqCo     ,; // Nome do arquivo temporario e alias para comissões
		cSavFil    ,; // Salva a Filial atual
		aCalc      ,; // Calculo de aplicacao
		aAreaSM0 := SM0->(GetArea())   ,; // Salva a area do SM0
		dDataTrab  ,; // Data de trabalho
		nAplicacao  := 0,; // Valor da aplicacao
		nEmprestimo := 0,; // Valor do emprestimo
		nDias          ,;
		nX			      ,;	  // Contador de loop for...next
		nAtrReceber := 0 ,;
		nAtrPagar   := 0 ,;
		cAlias := Alias(),;
		aTmpAnaEmp,;
		aTmpAnaApl,;
		cAliasEmp,;
		cAliasApl,;
		oDlg
		
Local oGet02,;
		aCposAna,;
		cAliasPc,;
		cAliasPv,;
		cArqAnaPc,;
		aTotais := {{},{},{},{},{},{},{},{},{}},;
		aPeriodo := {},;
		aFluxo   := {},;
		oFluxo,;
		nAscan,;
		nRecSeh,;
		cAplCotas := GetMv("MV_APLCAL4")
		
LOCAL aSize, aObjects := {}, aInfo, aPosObj, nTotRegs := 0

Local aTit := {{"01",STR0177 },{"07",STR0178},{"10",STR0179},{"15",STR0180},{"30",STR0181}},; //"Dia"###"Semana"###"Decendio"###"Quinzena"###"Mes"
		cTit

aCols := {} //	Declara a Cols Aqui, pois sera utilizada na rotina de simulacao
				//	e seu conteudo deve permanecer o mesmo toda vez que o usuario clicar
				//	no botao simulacao.
aHeader := {}

// Utilizada na simulacao
aHeader := {}
Aadd( aHeader, { STR0024	, "_SI_DATA"  , "", 8, 0, ".T.", USADO, "D",, "V" } ) //"Data"
Aadd( aHeader, { STR0025	, "_SI_TIPO"  , "!", 1, 0, "Fc021Tipo()", USADO, "C",, "V" } ) //"Receita/Despesa"
Aadd( aHeader, { STR0026	, "_SI_VALOR" , "@E 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
Aadd( aHeader, { STR0027	, "_SI_HISTOR", "@!", 40, 0, ".T.", USADO, "C",, "V" } ) //"Historico"
Aadd( aHeader, { "", ""          , ""  , 1, 0, ".F.", USADO, "C",, "V" } )

// Pega o titulo da primeira coluna de acordo com o periodo selecionado
cTit := aTit[Ascan(aTit,{|e|e[1]==Left(cPeriodo,2)})][2]

nMoeda := Val(Left(cMoeda,2))
nDias  := Val(Left(cPeriodo,2))*nPeriodos // Calcula quantos dias
If nDias <= 0
   nDias := 1
EndIf

// Gera os registros para todas as datas do periodo, inclusive a database
For nX := 1 To nDias
	dDataTrab := dDataBase+nX-1
	TemFluxoData(dDataTrab,aFluxo)
	TemFluxoData(dDataTrab,aPeriodo)
Next
// Monta os periodos na matriz para ser utilizada na simulacao e na projecao
MontaPeriodo(aPeriodo,cPeriodo)

// Inicia o total de registros a srem processados para incrementar a regua
If lReceber
	nTotRegs += SE1->(RecCount())
Endif
If lPagar 
	nTotRegs +=  SE2->(RecCount())
Endif
If lComissoes 
	nTotRegs += SE3->(RecCount())
Endif
If lPedVenda 
	nTotRegs += SC6->(RecCount())
Endif
If lPedCompra
	nTotRegs += SC7->(RecCount())
Endif
If lAplicacoes 
	nTotRegs += SEH->(RecCount())
Endif
If lSaldoBanc
	nTotRegs += SE8->(RecCount())
Endif

ProcRegua(nTotRegs)
	
If lAplicacoes
	If lAnalitico
	   aTmpAnaEmp := CriaTmpAna(1) // Cria o arquivo temporario analitico de emprestimos
	   cAliasEmp  := aTmpAnaEmp[1]
	   aTmpAnaApl := CriaTmpAna(2) // Cria o arquivo temporario analitico de aplicacoes
	   cAliasApl  := aTmpAnaApl[1]
   Endif
	For j:=1 To nDias
		dDataTrab := dDataBase+j-1
		cSavFil := cFilAnt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a Disponibilidade Financeira                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SM0")
		dbSetOrder(1)
		dbSeek(cEmpAnt+cFilDe,.T.)
		While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL <= cFilAte
			cFilAnt := SM0->M0_CODFIL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe Emprestimo a ser resgatado no dia ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SEH")
			dbSetOrder(2)
			dbSeek(xFilial("SEH")+"A",.T.)
			nRecSeh := Recno()
			While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )
				If SEH->EH_APLEMP == "EMP"
					If (Empty(SEH->EH_DATARES) .And. J==1 ) .Or.;
						(SEH->EH_DATARES == dDataTrab)
						nEmprestimo := xMoeda(SEH->EH_SALDO,SEH->EH_MOEDA,nMoeda,dDataTrab)
					Else
						nEmprestimo := 0
					Endif
					If (Empty(SEH->EH_DATARES) .And. J==1) .Or.;
						(SEH->EH_DATARES == dDataTrab)
						aCalc := Fa171Calc(dDataTrab)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Converte-se o valor dos juros de aplica‡Æo da moeda 1 ³
						//³para a moeda do nMoeda. Isto se d  devido ao retorno  ³
						//³da fun‡Æo Fa171Calc() ser em reais.                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nEmprestimo += xMoeda(aCalc[2,2],1,nMoeda,dDataTrab)
					EndIf
					// Verifica se esta no periodo solicitado
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
					If nAscan > 0
						aFluxo[nAscan][SAIDAS] += nEmprestimo
					Endif	
					If lAnalitico .And. nEmprestimo > 0
						// Pesquisa na matriz de totais, os totais de contas a pagar
						nAscan := Ascan( aTotais[6], {|e| e[1] == dDataTrab})
						If nAscan == 0
							Aadd( aTotais[6], {dDataTrab,nEmprestimo})
						Else	
							aTotais[6][nAscan][2] += nEmprestimo // Contabiliza os totais de emprestimos 
						Endif
						// Verifica se esta no periodo solicitado
						nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
						If nAscan > 0
							RecLock(cAliasEmp,.T.)
							(cAliasEmp)->DataX	:= dDataTrab
							(cAliasEmp)->Periodo	:= aPeriodo[nAscan][2]
							(cAliasEmp)->NUMERO	:= SEH->EH_NUMERO
							(cAliasEmp)->BANCO	:= SEH->EH_BANCO
							(cAliasEmp)->AGENCIA	:= SEH->EH_AGENCIA
							(cAliasEmp)->CONTA	:= SEH->EH_CONTA
							(cAliasEmp)->EMISSAO	:= SEH->EH_DATA
							(cAliasEmp)->SALDO	:= nEmprestimo
							(cAliasEmp)->APELIDO	:= "SEH"
							(cAliasEmp)->CHAVE	:= xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
							MsUnlock()
						Endif	
					Endif
				EndIf
				dbSelectArea("SEH")
				dbSkip()
			EndDo
			DbGoTo(nRecSeh) // Para evitar outro SEEK
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe Aplicacoes a serem resgatadas no dia ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )
				If SEH->EH_APLEMP == "APL"
			  		If (Empty(SEH->EH_DATARES) .And. J==1) .Or.;
			  			(SEH->EH_DATARES == dDataTrab)
						nAplicacao := xMoeda(SEH->EH_SALDO,SEH->EH_MOEDA,nMoeda,dDataTrab)
					Else
						nAplicacao := 0
					EndIf
					DbSelectArea("SE9")
					DbSetOrder(1)
					DbSeek(xFilial()+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
					DbSelectArea("SEH")
					If (Empty(SEH->EH_DATARES) .And. J==1) .Or.;
						(SEH->EH_DATARES == dDataTrab)
						If !SEH->EH_TIPO $ cAplCotas
							aCalc :=	Fa171Calc(dDataTrab)
						Else
							aCalc := {0,0,0,0,0,0}
							nAscan := Ascan(aAplic, {|e|	e[1] == SEH->EH_CONTRAT .And.;
																   e[2] == SEH->EH_BCOCONT .And.;
																   e[3] == SEH->EH_AGECONT})
							If nAscan > 0																	   
								aCalc	:=	Fa171Calc(dDataTrab,SEH->EH_SLDCOTA,,,,SE9->E9_VLRCOTA,aAplic[nAscan][6],(SEH->EH_SLDCOTA * aAplic[nAscan][6]))
							Endif	
						EndIf
						nAplicacao += xMoeda((aCalc[5]-aCalc[2]-aCalc[3]-aCalc[4]),;
												    1,nMoeda,dDataTrab)
					EndIf
					// Verifica se esta no periodo solicitado
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
					If nAscan > 0
						aFluxo[nAscan][ENTRADAS] += nAplicacao
					Endif	
					If lAnalitico .And. nAplicacao > 0
						// Pesquisa na matriz de totais, os totais de contas a pagar
						nAscan := Ascan( aTotais[7], {|e| e[1] == dDataTrab})
						If nAscan == 0
							Aadd( aTotais[7], {dDataTrab,nAplicacao})
						Else	
							aTotais[7][nAscan][2] += nAplicacao // Contabiliza os totais de Aplicacoes
						Endif
						// Verifica se esta no periodo solicitado
						nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
						If nAscan > 0
							RecLock(cAliasApl,.T.)
							(cAliasApl)->DataX	:= dDataTrab
							(cAliasApl)->Periodo	:= aPeriodo[nAscan][2]
							(cAliasApl)->NUMERO	:= SEH->EH_NUMERO
							(cAliasApl)->BANCO	:= SEH->EH_BANCO
							(cAliasApl)->AGENCIA	:= SEH->EH_AGENCIA
							(cAliasApl)->CONTA	:= SEH->EH_CONTA
							(cAliasApl)->EMISSAO	:= SEH->EH_DATA
							(cAliasApl)->SALDO	:= nAplicacao
							(cAliasApl)->APELIDO	:= "SEH"
							(cAliasApl)->CHAVE	:= xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
							MsUnlock()
						Endif	
					Endif
				Endif
				dbSelectArea("SEH")
				dbSkip()
			EndDo
			dbSelectArea("SEH")
			dbSetOrder(1)
			dbSelectArea("SM0")
			dbSkip()
		EndDo
		cFilAnt := cSavFil
		SM0->(RestArea(aAreaSM0))
	Next	
Endif	
aArqTmp := Array(4)
If lReceber
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os titulos a receber                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArqTmp := GeraTmp("SE1",7,dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,,,nMoeda,aTotais,aPeriodo,cFilterSe1)
Endif	
If lPagar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os titulos a pagar  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArqTmp := GeraTmp("SE2",3,dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,If(aArqTmp!=Nil,aArqTmp[1],Nil),If(aArqTmp!=Nil,aArqTmp[3],Nil),nMoeda,aTotais,aPeriodo,cFilterSe2)
Endif
If lPedCompra
	// Variaveis utilizadas pela rotina Fc020Compra()
	aCompras  := {}
	adCompras := {}
	MV_PAR03 := If( lConsFil, 2, 1 )
	MV_PAR02 := nMoeda
	
	// Analitico
	If lAnalitico
		aTmpAna := CriaTmpAna(3) // Cria o arquivo temporario analitico
		cAliasPc:= aTmpAna[1]
		cArqAnaPc:=aTmpAna[2]
     Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os pedidos de compra³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fc020Compra(cAliasPc,aTotais,.T.,nMoeda,aPeriodo)
	For nX := 1 To Len(aCompras)
		IncProc(STR0028) //"Processando Pedidos de compras"
		// Verifica se esta no periodo solicitado
		nAscan := Ascan(aPeriodo, {|e| e[1] == aCompras[nX][1]})
		If nAscan > 0
			aFluxo[nAscan][SAIDAS] += aCompras[nX][2]
		Endif	
	Next
Endif	
	
If lPedVenda
	// Variaveis utilizadas pela rotina Fc020Compra()
	aVendas  := {}
	adVendas := {}
	MV_PAR03 := If( lConsFil, 2, 1 )
	MV_PAR02 := nMoeda
	// Analitico
	If lAnalitico
		aTmpAna := CriaTmpAna(4)// Cria o arquivo temporario analitico
		cAliasPv:= aTmpAna[1]
		cArqAnaPv:=aTmpAna[2]
     Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os pedidos de venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fc020Venda(,cAliasPv,aTotais,.T.,nMoeda,aPeriodo)
	For nX := 1 To Len(aVendas)
		IncProc(STR0029) //"Processando Pedidos de vendas"
		nAscan := Ascan(aPeriodo, {|e| e[1] == aVendas[nX][1]})
		If nAscan > 0
			aFluxo[nAscan][ENTRADAS] += aVendas[nX][2]
		Endif	
	Next
Endif
aArqCo := Array(4)
If lComissoes
	aArqCo := Fc021Comis(dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,aFluxo,nMoeda,lAnalitico,aTotais,aPeriodo)
Endif
If aArqTmp == Nil .And. aArqco == Nil
	ApMsgAlert(STR0030) //"E necessario escolher ao menos um tipo"
Else
	aRotina :=	{ {"","", 0 , 1},; 
				 	  {STR0031,"", 0 , 2},; // "Visualizar"
				 	  {"","", 0 , 3},; 
				 	  {"","", 0 , 4},; 
				 	  {"","", 0 , 5},; 
				 	  {"","", 0 , 3} } 
	If lTitAtraso
		nAtrReceber := Fc021Vencidos("SE1",lConsFil,cFilDe,cFilAte,nMoeda,aFluxo,lAnalitico,aPeriodo,aTotais)
		nAtrPagar   := Fc021Vencidos("SE2",lConsFil,cFilDe,cFilAte,nMoeda,aFluxo,lAnalitico,aPeriodo,aTotais)
		nAtrPagar   += Fc021Vencidos("SE3",lConsFil,cFilDe,cFilAte,nMoeda,aFluxo,lAnalitico,aPeriodo,aTotais)
	Endif	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordena aFluxo pela data³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	aFluxo := aSort(aFluxo,,,{|x,y| x[1] < y[1]})
	aEval(aTotais, {|e| aSort(e,,, {|x,y| x[1] < y[1] })}) // Ordena pela data de cada sub-total
	Consolida(aFluxo,aTotais,cPeriodo)
	CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar)
	
	aSize := MsAdvSize()
	aadd( aObjects, {  30,  70, .T., .T.} )
	aadd( aObjects, {  20, 180, .T., .T., .T. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects )
	DEFINE MSDIALOG oDlg TITLE STR0032 + STR0193 + Capital(SubStr(cMoeda,3)) FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Fluxo de Caixa" //"Fluxo de Caixa" //" em "
	@  0,  1 TO 48,399 OF oDlg PIXEL
	@  6,  6 TO 44,152 PROMPT STR0033 OF oDlg PIXEL //"Titulos Atrasados"
	@  6,156 TO 44,311 PROMPT STR0034 OF oDlg PIXEL //"Saldos"
	@ 16, 11 SAY STR0035   OF oDlg PIXEL //"A Pagar"
	@ 29, 11 SAY STR0036 OF oDlg PIXEL //"A Receber"
	@ 16,162 SAY STR0037  OF oDlg PIXEL //"Em &Caixa"
	@ 29,162 SAY STR0038 OF oDlg PIXEL //"Em &Bancos"
	@ 14, 73 MSGET nAtrPagar   SIZE 76,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999.99" PIXEL
	@ 29, 73 MSGET nAtrReceber SIZE 76,10 OF oDlg WHEN .F. PICTURE "@E 999,999,999.99" PIXEL
	@ 14,231 MSGET oGet01 VAR nCaixas     SIZE 76,10 OF oDlg WHEN .T. VALID { || If(oGet01:lModified,;
																				 (CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar),oFluxo:Refresh(.T.)), Nil), .T. } PICTURE "@E 999,999,999.99" PIXEL
	@ 29,231 MSGET oGet02 VAR nBancos     SIZE 76,10 OF oDlg WHEN .T. VALID { || If(oGet02:lModified,;
																				 (CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar),oFluxo:Refresh(.T.)),Nil), .T. } PICTURE "@E 999,999,999.99" PIXEL
	
	@ 06,315 BUTTON STR0039 SIZE 32, 20 OF oDlg PIXEL ACTION Grafico(oDlg,aFluxo,nMoeda,cTit) //"&Grafico"
	@ 06,351 BUTTON STR0040 SIZE 32, 20 OF oDlg PIXEL ACTION oDlg:End() //"&Sair"
	@ 26,315 BUTTON STR0041 SIZE 32, 20 OF oDlg PIXEL ACTION Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo) //"Si&mulação"
	@ 26,351 BUTTON STR0042 SIZE 32, 20 OF oDlg PIXEL ACTION Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda) //"&Relatório"
	
	@ aPosObj[2,1]-63, aPosObj[2,2] LISTBOX oFluxo FIELDS ;
		HEADER cTit   ,; //"Dia","Semana","Decendio","Quinzena","Mes"
				 STR0043,; //"Entradas"
				 STR0044,; //"Saidas"
				 STR0045,; //"Saldo do Dia"
				 STR0046,; //"Var.Dia"
				 STR0047,; //"Entr.Acumul."
				 STR0048,; //"Saida Acumul."
				 STR0049,; //"Saldo Acumul."
				 STR0050,;
				 "Cheq. a Receber",;
				 "Atraso a Pagar",;
				 "Atraso a Receber"  SIZE aPosObj[2,3],aPosObj[2,4]+60; //"Var. Acumul."
		COLSIZES If(Left(cPeriodo,2)="01",30,45),;
	      GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;			
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB"),;
			GetTextWidth(0,"BBBBB");						
		OF oDlg ON DBLCLICK (If(lAnalitico, FluxoAna(aArqTmp[2], aArqTmp[4], cAliasPc, cAliasPv, aArqCo[4],cAliasEmp,cAliasApl,aFluxo[oFluxo:nAt][DATAFLUXO],aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo), ApMsgAlert(STR0051 + STR0023))) PIXEL //"Não foi selecionado Processa analitico! Impossivel consultar."
	
	oFluxo:SetArray(aFluxo)
	oFluxo:bLine := { || {xPadC(Transform(aFluxo[oFluxo:nAt,DATAFLUXO],""),45),;
							  	  Transform(aFluxo[oFluxo:nAt,ENTRADAS				]	,"@e 99,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,SAIDAS				]	,"@e 99,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,SALDODIA				]	,"@e 9,999,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,VARIACAODIA			]	,"@r 9999999.99%"),;
								  Transform(aFluxo[oFluxo:nAt,ENTRADASACUMULADAS]	,"@e 999,999,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,SAIDASACUMULADAS	]	,"@e 999,999,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,SALDOACUMULADO		]	,"@e 9,999,999,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,VARIACAOACUMULADA	]	,"@r 9999999.99%"),;
								  Transform(aFluxo[oFluxo:nAt,CHEQUESRECEBER		]	,"@e 99,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,ATRASOAPAGAR		]	,"@e 99,999,999.99"),;
								  Transform(aFluxo[oFluxo:nAt,ATRASOARECEBER	   ]	,"@e 99,999,999.99")}}
	oFluxo:bRClicked       := { |o,nX,nY| oMenu:Activate(nX,nY,oFluxo) }								  
	oFluxo:oWnd:bRClicked  := { |o,nX,nY| oMenu:Activate(nX,nY,oFluxo) }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os itens do Menu PopUp                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MENU oMenu POPUP 
		MENUITEM STR0039	Action Grafico(oDlg,aFluxo,nMoeda,cTit) //"&Grafico"
		MENUITEM STR0041  Action Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,nDias,aPeriodo) //"Si&mulação"
		MENUITEM STR0042 	Action Fc021ImpFlx(aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo,cTit,cMoeda) //"&Relatório"
		MENUITEM STR0052 	Action (If(lAnalitico, FluxoAna(aArqTmp[2], aArqTmp[4], cAliasPc, cAliasPv, aArqCo[4],cAliasEmp,cAliasApl,aFluxo[oFluxo:nAt][DATAFLUXO],aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo), ApMsgAlert(STR0051 + STR0023))) //"Visualiza etapa" //"Fluxo Analitico"###"Não foi selecionado Processa analitico! Impossivel consultar."
	ENDMENU
		
	ACTIVATE MSDIALOG oDlg
	
	If cAliasPc != Nil
		(cAliasPc)->(DbCloseArea())
		fErase(cArqAnaPc+GetDbExtension())
	Endif	
	If cAliasPv != Nil
		(cAliasPv)->(DbCloseArea())
		fErase(cArqAnaPv+GetDbExtension())
	Endif	
   If aArqTmp[2] != Nil .And. Select(aArqTmp[2]) > 0
		(aArqTmp[2])->(DbCloseArea())
     	fErase(aArqTmp[1]+GetDbExtension())
		fErase(aArqTmp[1]+OrdBagExt())
		(aArqTmp[4])->(DbCloseArea())
     	fErase(aArqTmp[3]+GetDbExtension())
		fErase(aArqTmp[3]+OrdBagExt())
	Endif	
	If aArqCo != Nil
		// Apaga o arquivo sintético de comissões
		If aArqCo[2] != Nil .And. Select(aArqCo[2]) > 0
			(aArqCo[2])->(DbCloseArea())
			fErase(aArqCo[1]+GetDbExtension())
			fErase(aArqCo[1]+OrdBagExt())
		Endif	
		// Apaga o arquivo analitico gerado para comissões
		If aArqCo[4] != Nil .And. Select(aArqCo[4]) > 0
			(aArqCo[4])->(DbCloseArea())
     		fErase(aArqCo[3]+GetDbExtension())
			fErase(aArqCo[3]+OrdBagExt())
		Endif
	Endif
	If cAliasEmp != Nil
		(cAliasEmp)->(DbCloseArea())
		fErase(aTmpAnaEmp[2]+GetDbExtension())
	Endif	
	If cAliasApl != Nil
		(cAliasApl)->(DbCloseArea())
		fErase(aTmpanaApl[2]+GetDbExtension())
	Endif	
Endif
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³GeraTmp   ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera dados no arquivo temporario, a partir do arquivo de   º±±
±±º          ³ titulos a receber ou do arquivo de titulos a pagar         º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cAlias     -> Alias do arquivo (SE1/SE2)                   º±±
±±º          ³ nOrdem     -> Ordem de Vencto.                             º±±
±±º          ³ dUltData   -> Ultima data do periodo                       º±±
±±º          ³ lConsFil   -> Considera filiais                            º±±
±±º          ³ cFilDe     -> Filial inicial                               º±±
±±º          ³ cFilAte    -> Filial final                                 º±±
±±º          ³ lAnalitico -> Gera dados analiticos                        º±±
±±º          ³ aFluxo     -> Matriz que contera os dados do fluxo         º±±
±±º          ³ cArqAnaP   -> Nome do arquivo temporario Analitico CP      º±±
±±º          ³ cArqAnaR   -> Nome do arquivo temporario Analitico CR      º±±
±±º          ³ nMoeda     -> Codigo da Moeda                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GeraTmp(cAlias,nOrdem,dUltData,lConsFil,cFilDe,cFilAte,lAnalitico,;
							   aFluxo,cArqAnaP,cArqAnaR,nMoeda,aTotais,aPeriodo,cFilterUser)
LOCAL cAliasAnaP,;
		cAliasAnaR,;
		cAliasAna ,;
		cAliasTrb ,;
		nSaldoTit ,;
		aStru	    ,;
		aCposAna  ,;
		aCposSin  ,;
		aTamSx3   ,;
		cQuery	 ,;
		cFiltro   ,;
		dDataTrab ,;
		cIndTmp	 ,;
		nX		    ,;
		cTipo     := If(Upper(cAlias)=="SE1", MVRECANT+"/"+MV_CRNEG, MVPAGANT+"/"+MV_CPNEG),;
		cAbatim   := If(Upper(cAlias)=="SE1", MVRECANT + "/"+;
														    MVIRABT  + "/"+;
														    MVCSABT  + "/"+;
													       MVCFABT  + "/"+;
														    MVPIABT, MVPAGANT ),;
		cCampo    := Right(cAlias,2),;
		nCampSin  := If(Upper(cAlias)=="SE1", ENTRADAS, SAIDAS),;
		nSldTitAc := 0,;
		nSaldoAnt := 0,;
		cCliFor       ,;
		nAscan
		
cAlias   := Upper(cAlias)

cAliasAnaP := "cArqAnaP"  // Alias do arquivo analitico
cAliasAnaR := "cArqAnaR"  // Alias do arquivo analitico
cAliasAna  := If(cAlias=="SE1","cArqAnaR","cArqAnaP")

// Analitico
If lAnalitico .And. (cArqAnaP == Nil .Or. cArqAnaR == Nil)
	aCposAna := {}
	Aadd( aCposAna, { "Periodo", "C",  15, 0 } )
	Aadd( aCposAna, { "DATAX"  , "D" , 08, 0} )
	Aadd( aCposAna, { "PREFIXO", "C", TamSx3(cCampo+"_PREFIXO")[1], 0 } )
	Aadd( aCposAna, { "NUM"    , "C", TamSx3(cCampo+"_NUM")[1], 0 } )
	Aadd( aCposAna, { "PARCELA", "C", TamSx3(cCampo+"_PARCELA")[1], 0 } )
	Aadd( aCposAna, { "TIPO"   , "C", TamSx3(cCampo+"_TIPO")[1], 0 } )
	Aadd( aCposAna, { "CLIFOR" , "C", TamSx3("E5_CLIFOR")[1], 0 } )
	Aadd( aCposAna, { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
	Aadd( aCposAna, { "LOJA"   , "C", TamSx3(cCampo+"_LOJA")[1], 0 } )
	Aadd( aCposAna, { "SALDO"  , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "CHAVE"  , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido", "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )
	cArqAnaP := CriaTrab(aCposAna,.T.) // Nome do arquivo temporario
	cArqAnaR := CriaTrab(aCposAna,.T.) // Nome do arquivo temporario
	dbUseArea(.T.,__LocalDriver,cArqAnaP,cAliasAnaP,.F.)
	dbUseArea(.T.,__LocalDriver,cArqAnaR,cAliasAnaR,.F.)
   IndRegua ( cAliasAnaP,cArqAnaP,"Dtos(DataX)",,,STR0054) //"Selecionando Registros..."
	IndRegua ( cAliasAnaR,cArqAnaR,"Dtos(DataX)",,,STR0054) //"Selecionando Registros..."
Endif

aCposSin:={{"DATAX"   , "D" , 08, 0},;
		      {"ENTR"    , "N" , 17, 2},;
			   {"SAID"    , "N" , 17, 2},;
			   {"SALDO"   , "N" , 17, 2},;
			   {"ENTRAC"  , "N" , 17, 2},;
			   {"SAIDAC"  , "N" , 17, 2},;
			   {"SALDOAC" , "N" , 17, 2},;
			   {"VARIACAO", "N" ,  9, 2},;
			   {"VARIACAC", "N" ,  9, 2},;
			   {"CHEQUES", "N" ,  17, 2},;
			   {"FLAG"    , "L" , 1, 0 }}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConsFil
   cFilDe  := xFilial(cAlias)
	cFilAte := xFilial(cAlias)
Endif	
#IFDEF TOP
	If TcSrvType() != "AS/400"
		aStru     := (cAlias)->(dbStruct())
		cAbatim   := FormatIn(cAbatim,"/")
		cAliasTrb := "FINC021"
		cQuery := ""
		aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
		cQuery := "SELECT "+SubStr(cQuery,2)
		cQuery +=         ","+cAlias+".R_E_C_N_O_ TITRECNO "
		cQuery += "FROM "+RetSqlName(cAlias)+ " "+ cAlias + " "
		cQuery += "WHERE "
		If !lConsFil
			cQuery += cAlias + "." + cCampo + "_FILIAL>='"+cFilDe+"' AND "
			cQuery += cAlias + "." + cCampo + "_FILIAL<='"+cFilAte+"' AND "
		Else 
			cQuery += cAlias + "." + cCampo + "_MSFIL>='"+cFilDe+"' AND "
			cQuery += cAlias + "." + cCampo + "_MSFIL<='"+cFilAte+"' AND "		
		EndIf	
		cQuery += cAlias + "." + cCampo + "_VENCREA >= '"+Dtos(dDataBase)+"' AND "
		cQuery += cAlias + "." + cCampo + "_VENCREA <= '"+Dtos(dUltData)+"' AND "
		cQuery += cAlias + "." + cCampo + "_SALDO > 0 AND "
		cQuery += cAlias + "." + cCampo + "_FLUXO<>'N' AND "
		cQuery += cAlias + ".D_E_L_E_T_=' ' "
	
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
		aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})
	Else
#ENDIF		
		cFiltro := cCampo + "_FILIAL>='"+cFilDe+"'.And."
		cFiltro += cCampo + "_FILIAL<='"+cFilAte+"'.And."
		cFiltro += "Dtos(" + cCampo + "_VENCREA)>='"+Dtos(dDataBase)+"'.And."
		cFiltro += "Dtos(" + cCampo + "_VENCREA)<='"+Dtos(dUltData)+"'.And."
		cFiltro += cCampo + "_SALDO>0.And."
		cFiltro += cCampo + "_FLUXO<>'N'"
	
		dbSelectArea(cAlias)
		dbSetOrder(nOrdem)
		cIndTmp := CriaTrab(,.F.)
		IndRegua(cAlias,cIndTmp,IndexKey(),,cFiltro)
		dbGotop()
		cAliasTrb := cAlias
#IFDEF TOP
	Endif
#ENDIF		
While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc(STR0055 + If(cAlias=="SE1", STR0056, STR0057)) //"Processando titulos a "###"Receber"###"Pagar"
	dDataTrab := DataValida((cAliasTrb)->&(cCampo+"_VENCREA"),.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a data de vencto. nao ultrapassar a ultima data da consulta ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dDataTrab <= dUltData
		#IFDEF TOP
			// Posiciona SE1 ou SE2 se for TOP e nao AS400, pois o filtro de usuario e
			// feito sobre o arquivo original.
			If TcSrvType() != "AS/400"
				DbSelectArea(cAlias)
				MsGoto((cAliasTrb)->TITRECNO)
			Endif
		#ENDIF
		DbSelectArea(cAlias)
		// Se nao existir filtro de usuario, ou se o filtro retornar uma expressao
		// valida para o registro atual do titulo, entao processsa o registro.
		If Empty(cFilterUser) .Or. (&cFilterUser)
			nSaldoTit := xMoeda((cAliasTrb)->&(cCampo+"_SALDO")   +	 ;
									  ((cAliasTrb)->&(cCampo+"_SDACRES")-	 ;
								 	   (cAliasTrb)->&(cCampo+"_SDDECRE"))	,;
									   (cAliasTrb)->&(cCampo+"_MOEDA")		,;
									  nMoeda                            ,;
							    	  dDataTrab)
			If Abs(nSaldoTit) > 0.0001
				// Verifica a situacao, somente se nao for Contas a Receber.
				If cAlias == "SE2" .Or.;
					((cAliasTrb)->e1_situaca != "2" .And. (cAliasTrb)->e1_situaca != "7")
					// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
					nAscan := TemFluxoData(dDataTrab,aFluxo)
					If (cAliasTrb)->&(cCampo+"_TIPO") $ MVABATIM + "/" + cTipo
						aFluxo[nAscan][nCampSin] -= nSaldoTit
					Else
						aFluxo[nAscan][nCampSin] += nSaldoTit
						
						If Alltrim((cAliasTrb)->&(cCampo+"_TIPO")) == "CH"
							aFluxo[nAscan][CHEQUESRECEBER] += nSaldoTit
						EndIf							

					EndIf
					If lAnalitico .And. !(cAliasTrb)->&(cCampo+"_TIPO") $ MVABATIM // Analitico
						cCliFor := (cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))
						// Posiciona no cliente ou fornecedor para buscar o nome
						DbSelectArea(StrTran(cAlias,"E","A"))
						DbSetOrder(1)
						MsSeek(xFilial(StrTran(cAlias,"E","A"))+cCliFor+(cAliasTrb)->&(cCampo+"_LOJA"))
						DbSelectArea(cAliasTrb)
						RecLock(cAliasAna,.T.)
						nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
						(cAliasAna)->DataX   := dDataTrab
						(cAliasAna)->Periodo := aPeriodo[nAscan][2]
						(cAliasAna)->PREFIXO := (cAliasTrb)->&(cCampo+"_PREFIXO")
						(cAliasAna)->NUM     := (cAliasTrb)->&(cCampo+"_NUM")
						(cAliasAna)->PARCELA := (cAliasTrb)->&(cCampo+"_PARCELA")
						(cAliasAna)->TIPO    := (cAliasTrb)->&(cCampo+"_TIPO")
						(cAliasAna)->CLIFOR  := cCliFor
						(cAliasAna)->NOMCLIFOR := (StrTran(cAlias,"E","A"))->&(Right(StrTran(cAlias,"E","A"),2)+"_NOME")
						(cAliasAna)->LOJA    := (cAliasTrb)->&(cCampo+"_LOJA")
						cIdentific :=	xFilial(cAlias)+;
										(cAliasTrb)->&(cCampo+"_PREFIXO") +;
										(cAliasTrb)->&(cCampo+"_NUM")     +;
										(cAliasTrb)->&(cCampo+"_PARCELA") +;
										(cAliasTrb)->&(cCampo+"_TIPO")    +;
										(cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))+;
										(cAliasTrb)->&(cCampo+"_LOJA")
						(cAliasAna)->Chave      := cIdentific
						(cAliasAna)->Apelido    := cAlias
						(cAliasAna)->SALDO      := nSaldoTit
						MsUnlock()
						// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
						// da data de trabalho.
						nAscan := Ascan( aTotais[If(cAlias=="SE1",2,1)], {|e| e[1] == dDataTrab})
						nTotCheq := 0
						nTotNorm := 0
						
						If Alltrim((cAliasTrb)->&(cCampo+"_TIPO")) == "CH"
							nTotCheq := (cAliasAna)->SALDO
						Else 
							nTotNorm := (cAliasAna)->SALDO
						EndIf	
						
						If nAscan == 0 
							Aadd( aTotais[If(cAlias=="SE1",2,1)], {dDataTrab,(cAliasAna)->SALDO,nTotCheq,nTotNorm})
						Else	
							If (cAliasTrb)->&(cCampo+"_TIPO") $ cTipo
								aTotais[If(cAlias=="SE1",2,1)][nAscan][2] -= (cAliasAna)->SALDO // Contabiliza os totais de titulos 
								aTotais[If(cAlias=="SE1",2,1)][nAscan][3] -= nTotCheq  
								aTotais[If(cAlias=="SE1",2,1)][nAscan][4] -= nTotNorm								
							Else
								aTotais[If(cAlias=="SE1",2,1)][nAscan][2] += (cAliasAna)->SALDO // Contabiliza os totais de titulos 
								aTotais[If(cAlias=="SE1",2,1)][nAscan][3] += nTotCheq  
								aTotais[If(cAlias=="SE1",2,1)][nAscan][4] += nTotNorm
							EndIf
						Endif	
					Endif	
				EndIf
			EndIf
		Endif	
	Endif
	(cAliasTrb)->(dbSkip())
Enddo
#IFDEF TOP
	If TcSrvType() != "AS/400"
		dbSelectArea(cAliasTrb)
		dbCloseArea()
		dbSelectArea(cAlias)
	Else
#ENDIF
		dbSelectArea(cAlias)
		dbClearFil(NIL)
		RetIndex(cAlias)
		If !Empty(cIndTmp)
			FErase (cIndTmp+OrdBagExt())
		Endif
		dbSetOrder(1)
#IFDEF TOP
	Endif
#ENDIF		

Return { cArqAnaP, cAliasAnaP, cArqAnaR, cAliasAnaR }


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CalcSaldo ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcular o saldo no arquivo temporario                      º±±
±±º          ³Parametros:                                                 º±±
±±º          ³aFluxo      -> Matriz contendo os dados do fluxo            º±±
±±º          ³nBancos     -> Saldo em bancos                              º±±
±±º          ³nCaixas     -> Saldo em caixas                              º±±
±±º          ³nAtrReceber -> Valor dos titulos atrasados a Receber        º±±
±±º          ³nAtrPagar   -> Valor dos titulos atrasados a Pagar          º±±
±±º          ³Retorno:                                                    º±±
±±º          ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcSaldo(aFluxo, nBancos, nCaixas, nAtrReceber, nAtrPagar)
Local nEntrAnt  := 0,;
	  nSaidAnt  := 0,;
	  aArea     := GetArea()
		
// Calcula o saldo inicial
aFluxo[1][SALDOACUMULADO] := (nBancos + nCaixas + nAtrReceber - nAtrPagar)
nSaldoAc := aFluxo[1][SALDOACUMULADO]
ProcRegua(Len(aFluxo))
For nX := 1 to Len(aFluxo)

	IncProc(STR0058)  //"Calculando saldos"
	// Calcula o saldo da data
	aFluxo[nX][SALDODIA] := aFluxo[nX][ENTRADAS]-aFluxo[nX][SAIDAS]
	
	// Calcula a variacao do dia
	aFluxo[nX][VARIACAODIA] := (aFluxo[nX][SAIDAS]/aFluxo[nX][ENTRADAS]) * 100
	
	// Calcula os creditos acumulados ate a data
	aFluxo[nX][ENTRADASACUMULADAS] := (nEntrAnt + aFluxo[nX][ENTRADAS])
	nEntrAnt := aFluxo[nX][ENTRADASACUMULADAS]
	
	// Calcula os debitos acumulados ate a data
	aFluxo[nX][SAIDASACUMULADAS] := (nSaidAnt + aFluxo[nX][SAIDAS])
	nSaidAnt := aFluxo[nX][SAIDASACUMULADAS]
	
	// Calcula o saldo acumulado ate a data
	aFluxo[nX][SALDOACUMULADO] := (aFluxo[nX][ENTRADAS]-aFluxo[nX][SAIDAS])+nSaldoAc
	nSaldoAc := aFluxo[nX][SALDOACUMULADO]
	
	// Calcula a variacao acumulada
	aFluxo[nX][VARIACAOACUMULADA] := (aFluxo[nX][SAIDASACUMULADAS]/aFluxo[nX][ENTRADASACUMULADAS])*100
		
Next

RestArea(aArea)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Consolida ºAutor  ³Claudio D. de Souza º Data ³  15/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcular o saldo no arquivo temporario                      º±±
±±º          ³Parametros:                                                 º±±
±±º          ³aArray      -> Matriz contendo os dados do fluxo            º±±
±±º          ³cPeriodos   -> Codigos dos periodos								  º±±
±±º          ³07 - Semanal                                                º±±
±±º          ³10 - Decendial                                              º±±
±±º          ³15 - Quinzenal                                              º±±
±±º          ³30 - Mensal                                                 º±±
±±º          ³Retorno:                                                    º±±
±±º          ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Consolida(aArray,aTotais,cPeriodos)
Local nX,;
		nY,;
		nZ,;
		nPeriodo := Val(Left(cPeriodos,2)),;
		nResto		  	,;
		aCopia := {}	,;
		nEntradas := 0	,;
		nSaidas	 := 0	,;
		nSoma     := 0	,;
		dDataTrab		,;
		cPer           ,;
		aCopiaTot := {}

If nPeriodo != 1		
	aEval(aTotais, {|e|Aadd(aCopiaTot, {})}) // Inicializa aCopiaTot com Array em todos os elementos
Else
	// Transforma a Data para Caracter pois assim sera usada nas rotinas sequintes
	aEval(aArray, {|e| e[DATAFLUXO] := Dtoc(e[DATAFLUXO])})
	For nX := 1 To Len(aTotais)
		For nY := 1 To Len(aTotais[nX])
			aTotais[nX][nY][1] := Dtoc(aTotais[nX][nY][1])
		Next
	Next
Endif	
If nPeriodo != 1
	For nX := 1 TO Len(aArray)
		dDataTrab := aArray[nX][DATAFLUXO]
		Do Case
		Case nPeriodo == 7  // Semanal
			// Verifica quantos dias faltam para a proxima semana
			nResto := 6
			If Dow(dDataTrab) != 1
				nResto := 7-Dow(dDataTrab)
			EndIf
		Case nPeriodo == 10 // Decendial
			nResto := 9
			// Verifica quantos dias faltam para o proximo decendio
			If Day(dDataTrab) < 10
				nResto := 10-Day(dDataTrab)
			ElseIf Day(dDataTrab) > 10 .And. Day(dDataTrab) < 20
				nResto := 20-Day(dDataTrab)
			ElseIf Day(dDataTrab) > 20
				nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
			Endif
		Case nPeriodo == 15 // Quinzenal
			nResto := 14
			// Verifica quantos dias faltam para a proxima quinzena
			If Day(dDataTrab) < 15
				nResto := 15-Day(dDataTrab)
			Else	
				nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
			Endif
		Case nPeriodo == 30 // Mensal
			// Verifica quantos dias faltam para o proximo mes
			nResto := LastDay(dDataTrab)-dDataTrab
		EndCase
		For nY := nX To (nResto+nX)
			If nY > Len(aArray)
				Exit
			Endif
			nEntradas += aArray[nY][ENTRADAS]
			nSaidas 	 += aArray[nY][SAIDAS]
		Next
		nX := (nY-1)
		If nPeriodo != 1
			cPer := Left(Dtoc(dDataTrab),5)+ STR0182 + Left(Dtoc(aArray[nX][DATAFLUXO]),5) //" a "
		Endif	
		Aadd(aCopia, {cPer,nEntradas, nSaidas,0,0,0,0,0,0})
		// Consolida aTotais
		For nY := 1 To Len(aTotais)
			For nZ := 1 to Len(aTotais[nY])
				// Se os totais tiverem dentro das datas do periodo, acumula os valores
				If aTotais[nY][nZ][1] >= dDataTrab .And. aTotais[nY][nZ][1] <= aArray[nX][DATAFLUXO]
					nSoma += aTotais[nY][nZ][2]
				ElseIf aTotais[nY][nZ][1] > aArray[nX][DATAFLUXO]
					// Senao forca a saida por nao ser amis necessario processar, para nao
					// perder tempo.
					Exit
				Endif
			Next
			If nSoma > 0
				Aadd(aCopiaTot[nY], {cPer, nSoma})
			Endif	
			nSoma := 0
		Next
		nEntradas := nSaidas := 0
	Next
	aArray  := aClone(aCopia)
	aTotais := aClone(aCopiaTot)
Endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MontaPerioºAutor  ³Claudio D. de Souza º Data ³  18/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar os periodos na matriz de periodos para ser utilizada º±±
±±º          ³na simulacao e na projecao do fluxo								  º±±
±±º          ³Parametros:                                                 º±±
±±º          ³aArray      -> Matriz contendo as datas do periodo          º±±
±±º          ³cPeriodos   -> Codigos dos periodos								  º±±
±±º          ³07 - Semanal                                                º±±
±±º          ³10 - Decendial                                              º±±
±±º          ³15 - Quinzenal                                              º±±
±±º          ³30 - Mensal                                                 º±±
±±º          ³Retorno:                                                    º±±
±±º          ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaPeriodo(aArray,cPeriodos)
Local nX,;
		nY,;
		nInicio := 0,;
		nFim,;
		nPeriodo := Val(Left(cPeriodos,2)),;
		nResto		  	,;
		aCopia := {}	,;
		dDataTrab		,;
		cPer           
		
For nX := 1 TO Len(aArray)
	dDataTrab := aArray[nX][DATAFLUXO]
	Do Case
	Case nPeriodo == 1  // Diario
		nResto := 0
		cPer := Dtoc(dDataTrab)
	Case nPeriodo == 7  // Semanal
		// Verifica quantos dias faltam para a proxima semana
		nResto := 6
		If Dow(dDataTrab) != 1
			nResto := 7-Dow(dDataTrab)
		EndIf
	Case nPeriodo == 10 // Decendial
		nResto := 9
		// Verifica quantos dias faltam para o proximo decendio
		If Day(dDataTrab) < 10
			nResto := 10-Day(dDataTrab)
		ElseIf Day(dDataTrab) > 10 .And. Day(dDataTrab) < 20
			nResto := 20-Day(dDataTrab)
		ElseIf Day(dDataTrab) > 20
			nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
		Endif
	Case nPeriodo == 15 // Quinzenal
		nResto := 14
		// Verifica quantos dias faltam para a proxima quinzena
		If Day(dDataTrab) < 15
			nResto := 15-Day(dDataTrab)
		Else	
			nResto := LastDay(dDataTrab)-dDataTrab // Processa até o ultimo dia do mes
		Endif
	Case nPeriodo == 30 // Mensal
		// Verifica quantos dias faltam para o proximo mes
		nResto := LastDay(dDataTrab)-dDataTrab
	EndCase
	nInicio := nX
	nFim    := (nResto+nX)
	nFim    := If(nFim <= Len(aArray),nFim,Len(aArray))
	nX 	  := nFim
	If nPeriodo != 1
		cPer := Left(Dtoc(dDataTrab),5)+ STR0182 + Left(Dtoc(aArray[nX][DATAFLUXO]),5) //" a "
	Endif	
	For nY := nInicio To nFim
		If aArray[nY][1] <= aArray[nX][DATAFLUXO]
			Aadd(aCopia,{aArray[nY][1],cPer})
		Else
			Exit	
		Endif
	Next
Next
aArray  := aClone(aCopia)
Return		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetMoedas ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obter as moedas utilizadas pelo sistema                    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ Nenhum                                                     º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = Codigo da moeda + Descricao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetMoedas
Local aRet     := {}       ,;
		aArea    := GetArea(),;
		aAreaSx6 := Sx6->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com as moedas existentes.						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX6")
DbSeek( xFilial("SX6") + "MV_MOEDA", .T. )
While Substr(SX6->X6_VAR,1,8) == "MV_MOEDA" .And. SX6->(!Eof()) 
	If Substr(SX6->X6_VAR,9,1) != "P"  // Desconsiderar plural
		Aadd( aRet, StrZero(Val(Substr(SX6->X6_VAR,9,2)),2) + " " + GetMv(SX6->X6_VAR) )
	Endif
	DbSkip()
EndDo

Sx6->(RestArea(aAreaSx6))
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetBancos ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obter os bancos do SA6                                     º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetBancos( lConsFil, nMoeda )
Local aRet     := {},;
		aArea    := GetArea(),;
		aAreaSa6 := Sa6->(GetArea()),;
		aAreaSe8 := Se8->(GetArea()),;
		cTrbBanco                   ,;
		cTrbAgencia                 ,;
		cTrbConta                   ,;
		cTrbNome                    ,;
		dTrbData                    ,;
		nTrbSaldo                   ,;
		lSldBco    := .F.           ,;
		nIndSe8                     ,;
		cIndSE8  := ""					 ,;
		cBancoCx := GetMV("MV_CARTEIR")

DbSelectArea("SA6")
If !lConsFil
	dbSeek( xFilial("SA6") )
	nIndSE8 := 1
Else
	dbGotop()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra o arquivo de saldos bancarios								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE8")
	cIndSE8 := CriaTrab(,.F.)
	IndRegua("SE8",cIndSE8,"E8_BANCO+E8_AGENCIA+E8_CONTA+Dtos(E8_DTSALAT)",,,)
	nIndSE8 := RetIndex("SE8")	
	nIndSE8++
	#IFNDEF TOP
		dbSetIndex(cIndSE8+ordBagExt())
	#ENDIF
EndIf

While !Eof() .and. If( !lConsfil,A6_FILIAL == xFilial("SA6"),.T.)
	If SA6->A6_FLUXCAI $ "S "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica banco a banco a disponibilidade imediata				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE8")
		dbSetOrder( nIndSE8 )

		cTrbBanco  := SA6->A6_COD
		cTrbAgencia:= SA6->A6_AGENCIA
		cTrbConta  := SA6->A6_NUMCON
		cTrbNome   := SA6->A6_NREDUZ
		lSldBco    := .F.
		If ! dbSeek(If(!lConsFil,xFilial("SE8"),"")+;
						SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+;
						DtoS(dDataBase),.T.)
			dbSkip(-1)
			dTrbData := SE8->E8_DTSALAT
			While ( !Bof() .And. If(!lConsFil,xFilial("SE8") == SE8->E8_FILIAL,.T.) .And.;
					SA6->a6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON ==;
					SE8->E8_BANCO+SE8->E8_AGENCIA+SE8->E8_CONTA .And.;
					SE8->E8_DTSALAT == dTrbData )
				dbSkip( -1 )
				lSldBco := .T.
			End				
			If ( lSldBco )
				dbSkip(1)
			EndIf		
		EndIf
		If ( !Eof() .And. SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON == ;
				            SE8->E8_BANCO+SE8->E8_AGENCIA+SE8->E8_CONTA .And.;
				            If(!lConsFil,xFilial("SE8") == SE8->E8_FILIAL,.T.) .And. ;
				            SE8->E8_DTSALAT <= dDataBase )
			If Substr(cTpSld,1,1) = "1"
				nTrbSaldo := xMoeda(SE8->E8_SALATUA,1,nMoeda)
			ElseIf Substr(cTpSld,1,1) = "2"	
				nTrbSaldo := xMoeda(SE8->E8_SALRECO,1,nMoeda)
			ElseIf Substr(cTpSld,1,1) = "3"
				nTrbSaldo := xMoeda(SE8->E8_SALATUA + SE8->E8_SALRECO,1,nMoeda)
			EndIf
			Aadd(aRet,{.F.,cTrbBanco,cTrbAgencia,cTrbConta,cTrbNome,Transform(nTrbSaldo,"@E 999,999,999.99"),nMoeda})
		EndIf
	Endif
	dbSelectArea("SA6")
	dbSkip()
End

If ( !Empty(cIndSE8) )
	dbSelectArea("SE8")
	RetIndex("SE8")
	dbClearFilter()	
	Ferase(cIndSE8+OrdBagExt())
EndIf

Sa6->(RestArea(aAreaSa6))
Se8->(RestArea(aAreaSe8))
RestArea(aArea)

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Bancos    ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe os bancos para selecao dos saldos                    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ nBancos     -> Saldo em bancos (por referencia)            º±±
±±º          ³ nCaixas     -> Saldo em caixas (por referencia)            º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Bancos( lConsFil, nMoeda, nBancos, nCaixas )
Local oDlgBanc
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local cBancoCx := GetMV("MV_CARTEIR")
Local oGet01, lInverter
Local aBancos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com os bancos existentes.						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			  
aBancos := GetBancos(lConsFil, nMoeda)
If Len(aBancos) == 0
	ApMsgAlert(STR0059) //"Nao existem saldos bancarios"
Else
	ASort(aBancos)                                       
		
	DEFINE MSDIALOG oDlgBanc TITLE STR0060+" "+Substr(cTpSld,3,11) From 5,5 To 20,70 OF oMainWnd //"Selecione os bancos"
	@	 .8, .5 LISTBOX oBancos FIELDS HEADER "",STR0061,STR0062,STR0063,STR0064,STR0065 FIELDSIZES 14,25,31,31,60,40 SIZE 210, 100 OF oDlgBanc //"Banco"###"Agencia"###"Conta"###"Nome"###"Saldo"
	@   .6,  4 CHECKBOX oGet01 VAR lInverter PROMPT STR0066 FONT oDlgBanc:oFont PIXEL OF oDlgBanc SIZE 50,9 ON CLICK (oGet01:cCaption := If( lInverter, STR0067, STR0068)+STR0069, oGet01:Refresh(), aEval(aBancos, {|e| e[1] := lInverter}), oBancos:Refresh()) //"Marcar todos"###"Desmarcar"###"Marcar"###" todos"
	oBancos:SetArray(aBancos)
	oBancos:bLine      := {|| {If(aBancos[oBancos:nAt,1],oOk,oNo),;
							   aBancos[oBancos:nAt,2],;
							   aBancos[oBancos:nAt,3],;
							   aBancos[oBancos:nAt,4],;
							   aBancos[oBancos:nAt,5],;
							   aBancos[oBancos:nAt,6]}}
							   
	oBancos:bLDblClick := {|| aBancos[oBancos:nAt][1] := !aBancos[oBancos:nAt][1], oBancos:DrawSelect()}
	DEFINE SBUTTON FROM 05, 220 TYPE 1 ACTION oDlgBanc:End() ENABLE OF oDlgBanc
	ACTIVATE MSDIALOG oDlgBanc
	
	// Calcula o saldo em Bancos/Caixas
	aEval( aBancos, { |e| If( e[1], If( Left(e[2],2)=="CX" .Or. Left(e[2],3) $ cBancoCx,;
										nCaixas += Val(StrTran(StrTran(e[6],".",""),",",".")),;
									  	nBancos += Val(StrTran(StrTran(e[6],".",""),",","."))),Nil)})
Endif
	
Return aBancos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetAplic  ºAutor  ³Claudio D. de Souza º Data ³  03/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obter as aplicacoes do SEH                                 º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetAplic(lConsFil)
Local aRet     := {},;
		aArea    := GetArea(),;
		aAreaSeh := Seh->(GetArea()),;
		aAreaSe9 := Se9->(GetArea()),;
		cAplCotas:= GetMv("MV_APLCAL4"),;
		cIndSEH  := "",;
		cFiltro
DbSelectArea("SEH")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra o arquivo de aplicacoes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEH")
cIndSEH := CriaTrab(,.F.)
If lConsFil
	cFiltro := "EH_TIPO$'"+&cAplCotas+"' .And. EH_FILIAL='"+xFilial("SEH")+"'"
Else
	cFiltro := "EH_TIPO$'"+&cAplCotas+"'"
Endif	
IndRegua("SEH",cIndSEH,If(lConsFil, xFilial("SEH"),"")+"EH_NUMERO+EH_REVISAO",,cFiltro)
nIndSEH := RetIndex("SEH")	
nIndSEH++
#IFNDEF TOP
	dbSetIndex(cIndSEH+ordBagExt())
#ENDIF

While !Eof() // Processa arquivo filtrado
	dbSelectArea("SE9")
	dbSetOrder(1)
	MsSeek(xFilial("SE9")+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
	dbSelectArea("SEH")
	Aadd(aRet,{	SEH->EH_CONTRAT,SEH->EH_BCOCONT,SEH->EH_AGECONT,Transform(SEH->EH_SALDO,"@E 999,999,999.99"),Transform(SE9->E9_VLRCOTA,PesqPict("SE9","E9_VLRCOTA",18)),;
					If(se9->(FieldPos("E9_COTADIA"))>0 .And. SE9->E9_COTADIA > 0,;
						Transform(SE9->E9_COTADIA,PesqPict("SE9","E9_COTADIA",18)),;
						Transform(SE9->E9_VLRCOTA,PesqPict("SE9","E9_VLRCOTA",18)))})
	DbSkip()
End

If !Empty(cIndSEH)
	dbSelectArea("SEH")
	RetIndex("SEH")
	dbClearFilter()	
	Ferase(cIndSEH+OrdBagExt())
EndIf

SeH->(RestArea(aAreaSeh))
Se9->(RestArea(aAreaSe9))
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AplicacoesºAutor  ³Claudio D. de Souza º Data ³  03/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe aplicacoes para selecao/informacao das cotas diarias º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Aplicacoes(lConsFil, nMoeda)
Local oDlgAplic
Local aAplic
Local nX
Local aArea    := GetArea()
Local aAreaSe9 := SE9->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com os bancos existentes.						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			  
aAplic := GetAplic(lConsFil)
If Len(aAplic) == 0
	ApMsgAlert(STR0086) //"Nao existem aplicações financeiras"
Else
	ASort(aAplic)
		
	DEFINE MSDIALOG oDlgAplic TITLE STR0070 From 5,5 To 20,87 OF oMainWnd //"Informe os valores das cotas diarias"
	@	.8, .5 LISTBOX oAplic FIELDS HEADER STR0071,STR0061,STR0062,STR0065,STR0072,STR0073 FIELDSIZES 14,25,31,31,60,40,40 SIZE 275, 100 OF oDlgAplic //"Contrato"###"Banco"###"Agencia"###"Saldo"###"Vlr. Cota Atual"###"Vlr. Cota do dia"
	oAplic:SetArray(aAplic)
	oAplic:bLine      := {|| {	aAplic[oAplic:nAt,1],;
							   		aAplic[oAplic:nAt,2],;
							   		aAplic[oAplic:nAt,3],;
							   		aAplic[oAplic:nAt,4],;
							   		aAplic[oAplic:nAt,5],;
							   		aAplic[oAplic:nAt,6]}}
							   
	oAplic:bLDblClick := {|| EditAplic(6,@oAplic,@aAplic),oAplic:GoRight(),oAplic:GoLeft()}

	DEFINE SBUTTON FROM 05, 290 TYPE 1 ACTION oDlgAplic:End() ENABLE OF oDlgAplic
	ACTIVATE MSDIALOG oDlgAplic
	
Endif
// Transforma o ultimo elemento da matriz (Valor da cota do dia) para numerico
// Eliminando a picture deste campo e grava valor da cota do dia, caso exista o campo
For nX := 1 To Len(aAplic)
	aAplic[nX][6] := Val(StrTran(StrTran(aAplic[nX][6],".",""),",","."))
	If SE9->(FieldPos("E9_COTADIA"))>0
		dbSelectArea("SE9")
		dbSetOrder(1)
		MsSeek(xFilial("SE9")+aAplic[nX][1]+aAplic[nX][2]+aAplic[nX][3])
		If Str(SE9->E9_COTADIA,17,4) != Str(aAplic[nX][6],17,4)
			RecLock("SE9")
			SE9->E9_COTADIA := aAplic[nX][6]
		Endif	
	Endif
Next
SE9->(RestArea(aAreaSe9))
RestArea(aArea)
	
Return aAplic

Static Function EditAplic(nCol,oAplic,aAplic)
Local nClick := 0

nClick := oAplic:nAtCol(nCol)

If nClick <> 1
	// Transforma para numerico para que o usuario possa editar o campo com entrada
	// de numeros apenas.
	aAplic[oAplic:nAt][nCol] := Val(StrTran(StrTran(aAplic[oAplic:nAt][nCol],".",""),",","."))
	lEditCell(@aAplic,oAplic,PesqPict("SE9","E9_VLRCOTA",18),nCol)
	// Volta para caracter o numero editado para que possa ser exibido corretamente
	// pela LISTBOX.
	aAplic[oAplic:nAt][nCol] := Transform(aAplic[oAplic:nAt][nCol],PesqPict("SE9","E9_VLRCOTA",18))
	oAplic:SetFocus()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021ComisºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera dados no arquivo temporario, a partir do arquivo de   º±±
±±º          ³ comissoes																  º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ dUltData   -> Ultima data do periodo                       º±±
±±º          ³ lConsFil   -> Considera filiais                            º±±
±±º          ³ cFilDe     -> Filial inicial                               º±±
±±º          ³ cFilAte    -> Filial final                                 º±±
±±º          ³ aFluxo     -> Matriz que contera os dados do fluxo         º±±
±±º          ³ nMoeda     -> Codigo da Moeda                              º±±
±±º          ³ lAnalitico -> Gera dados analiticos                        º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[1] =                                                  º±±
±±º          ³ cArqAnaCo -> Nome do arquivo analitico                     º±±
±±º          ³ cAliasCo  -> Alias do arquivo analitico                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION Fc021Comis(dUltData,lConsFil,cFilDe,cFilAte,aFluxo,nMoeda,;
									lAnalitico,aTotais,aPeriodo)
LOCAL cAliasCo  ,;
		cArqAnaCo ,;
		aCposAna  ,;
		aCposSin  ,;
		cAliasTrb ,;
		nSaldoTit ,;
		aStru		 ,;
		aTamSx3	 ,;
		cQuery	 ,;
		cFiltro   ,;
		dDataTrab ,;
		cIndTmp	 ,;
		nX			 ,;
		nAscan
		
// Analitico
If lAnalitico
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C",  15, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "PREFIXO" , "C", TamSx3("E3_PREFIXO")[1], 0 } )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("E3_NUM")[1], 0 } )
	Aadd( aCposAna, { "PARCELA" , "C", TamSx3("E3_PARCELA")[1], 0 } )
	Aadd( aCposAna, { "VEND"    , "C", TamSx3("E3_VEND")[1], 0 } )
	Aadd( aCposAna, { "NOMEVEND", "C", TamSx3("A3_NOME")[1], 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					             TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
		
	cAliasCo := "cArqAnaCo"  // Alias do arquivo analitico
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqAnaCo := CriaTrab(aCposAna,.T.) // Nome do arquivo temporario
	dbUseArea(.T.,__LocalDriver,cArqAnaCo,cAliasCo,.F.)
   IndRegua ( cAliasCo,cArqAnaCo,"Dtos(DataX)",,,STR0054)  //"Selecionando Registros..." //"Selecionando Registros..."
Endif		

aCposSin:={{"DATAX"   , "D" , 08, 0},;
		    	{"ENTR"    , "N" , 17, 2},;
			 	{"SAID"    , "N" , 17, 2},;
			 	{"SALDO"   , "N" , 17, 2},;
			 	{"ENTRAC"  , "N" , 17, 2},;
			 	{"SAIDAC"  , "N" , 17, 2},;
			 	{"SALDOAC" , "N" , 17, 2},;
			 	{"VARIACAO", "N" ,  9, 2},;
			 	{"VARIACAC", "N" ,  9, 2},;
			 	{"CHEQUES", "N" ,  17, 2},;			 	
			 	{"FLAG"    , "L" ,  1, 0 }}
			 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConsFil
   cFilDe  := xFilial("SE3")
   cFilAte := xFilial("SE3")
Endif

#IFDEF TOP
	If TcSrvType() != "AS/400" 
		aStru     := SE3->(dbStruct())
		cAliasTrb := "FINC021"
	
		cQuery := "SELECT * "
		cQuery += "FROM "+RetSqlName("SE3")+ " SE3 (NOLOCK) "
		cQuery += "WHERE "
		cQuery += "SE3.E3_FILIAL>='"+cFilDe+"' AND "
		cQuery += "SE3.E3_FILIAL<='"+cFilAte+"' AND "
		cQuery += "SE3.E3_VENCTO >= '"+Dtos(dDataBase)+"' AND "
		cQuery += "SE3.E3_VENCTO <= '"+Dtos(dUltData)+"' AND "
		cQuery += "SE3.E3_DATA = ' ' AND "
		cQuery += "SE3.D_E_L_E_T_=' ' "

	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
		aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})
	Else
#ENDIF		
		cFiltro := "E3_FILIAL>='"+cFilDe+"'.And."
		cFiltro += "E3_FILIAL<='"+cFilAte+"'.And."
		cFiltro += "Dtos(E3_VENCTO)>='"+Dtos(dDataBase)+"'.And."
		cFiltro += "Dtos(E3_VENCTO)<='"+Dtos(dUltData)+"'.And."
		cFiltro += "Dtos(E3_DATA)='"+Dtos(Ctod(""))+"'"
	
		dbSelectArea("SE3")
		cIndTmp := CriaTrab(,.F.)
		IndRegua("SE3",cIndTmp,IndexKey(),,cFiltro)
		dbGotop()
		cAliasTrb := "SE3"
#IFDEF TOP
	Endif
#ENDIF		
While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc(STR0087) //"Processando Comissäes"
	dDataTrab := DataValida((cAliasTrb)->E3_VENCTO,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a data de vencto. nao ultrapassar a ultima data do relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dDataTrab <= dUltData
		nSaldoTit := xMoeda(SE3->E3_COMIS,1,nMoeda)
		If Abs(nSaldoTit) > 0.0001
			// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
			nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
			// Verifica se esta no periodo solicitado
			If nAscan > 0
				aFluxo[nAscan][SAIDAS] += nSaldoTit
			Endif
			If lAnalitico .And. nAscan > 0
				RecLock(cAliasCo,.T.)
				(cAliasCo)->Datax		:= dDataTrab
				(cAliasCo)->Periodo	:= aPeriodo[nAscan][2]
				(cAliasCo)->PREFIXO	:= (cAliasTrb)->E3_PREFIXO
				(cAliasCo)->NUMERO	:= (cAliasTrb)->E3_NUM
				(cAliasCo)->PARCELA	:= (cAliasTrb)->E3_PARCELA
				(cAliasCo)->VEND		:= (cAliasTrb)->E3_VEND
				DbSelectArea("SA3")
				dbSetOrder(1)
				MsSeek(xFilial("SA3")+(cAliasTrb)->E3_VEND)
				DbSelectArea(cAliasTrb)
				(cAliasCo)->NOMEVEND:= SA3->A3_NOME
				cIdentific :=	xFilial("SE3")+;
								   (cAliasTrb)->E3_PREFIXO +;
								   (cAliasTrb)->E3_NUM     +;
								   (cAliasTrb)->E3_PARCELA +;
								   (cAliasTrb)->E3_SEQ
				(cAliasCo)->Chave     := cIdentific
				(cAliasCo)->SALDO     := nSaldoTit
				(cAliasCo)->Apelido   := "SE3"
				MsUnlock()
				// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
				// da data de trabalho.
				nAscan := Ascan( aTotais[5], {|e| e[1] == dDataTrab})
				If nAscan == 0
					Aadd( aTotais[5], {dDataTrab,nSaldoTit})
				Else	
					aTotais[5][nAscan][2] += nSaldoTit // Contabiliza os totais de comissões
				Endif	
			Endif
		EndIf
	Endif
	(cAliasTrb)->(dbSkip())
Enddo
#IFDEF TOP
	If TcSrvType() != "AS/400" 
		dbSelectArea(cAliasTrb)
		dbCloseArea()
		dbSelectArea("SE3")
	Else
#ENDIF		
		dbSelectArea("SE3")
		dbClearFil(NIL)
		RetIndex("SE3")
		If !Empty(cIndTmp)
			FErase (cIndTmp+OrdBagExt())
		Endif
		dbSetOrder(1)
#IFDEF TOP
	Endif
#ENDIF

Return { ,, cArqAnaCo, cAliasCo }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021VenciºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula os titulos vencidos do SE1/SE2                     º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cAlias   -> Alias do arquivo de titulos SE1 ou SE2         º±±
±±º          ³ lConsFil -> Considera filiais                              º±±
±±º          ³ cFilDe   -> Filial inicial                                 º±±
±±º          ³ cFilAte  -> Filial final                                   º±±
±±º          ³ nMoeda   -> Codigo da moeda                                º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ nRet -> Valor total dos titulos vencidos                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Vencidos(cAlias, lConsFil, cFilDe, cFilAte,nMoeda,aFluxo,lAnalitico,aPeriodo,aTotais)
Local nRet := 0 ,;
		cQuery    ,;
		cFiltro   ,;
		cAliasTmp ,;
		cAliasTrb ,;
		cCampo    := Right(cAlias,2),;
		nOrdem    ,;
		cRecPagAnt,;
		nSaldo    ,;
		aArea  := GetArea()
		aArea1 := (cAlias)->(GetArea())

cRecPagAnt := If( cAlias == "SE1", MVRECANT+"/"+MVIRF, MVPAGANT )
nOrdem     := If( cAlias == "SE1", 7, 3 )
DbSelectArea(cAlias)
DbSetOrder(nOrdem)

If !lConsFil
   cFilDe  := xFilial(cAlias)
   cFilAte := xFilial(cAlias)
Endif			

cAliasTmp := "cArqTmp" // Alias do arquivo

#IFDEF TOP
	If TcSrvType() != "AS/400" 
		aStru     := (cAlias)->(dbStruct())
		cRecPagAnt := FormatIn(cRecPagAnt,"/")
		cAliasTrb := "VENCIDOS"
		
		If cAlias == "SE3" // Comissoes
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SE3")+ " SE3 (NOLOCK) "
			cQuery += "WHERE "
			If !lConsFil
				cQuery += "SE3.E3_FILIAL>='"+cFilDe+"' AND "
				cQuery += "SE3.E3_FILIAL<='"+cFilAte+"' AND "            
			Else 
				cQuery += "SE3.E3_MSFIL>='"+cFilDe+"' AND "
				cQuery += "SE3.E3_MSFIL<='"+cFilAte+"' AND "            			
			EndIf	
			cQuery += "SE3.E3_VENCTO >= '"+Dtos(dDatIni)+"' AND "			
			cQuery += "SE3.E3_VENCTO <= '"+Dtos(dDataBase-1)+"' AND "
			cQuery += "SE3.E3_DATA = ' ' AND "
			cQuery += "SE3.D_E_L_E_T_=' ' "
		Else
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName(cAlias) + " " + cAlias + " (NOLOCK) "
			cQuery += "WHERE "
			If !lConsFil
				cQuery += cAlias + "." + cCampo + "_FILIAL>='"+cFilDe+"' AND "
				cQuery += cAlias + "." + cCampo + "_FILIAL<='"+cFilAte+"' AND "
			Else 
				cQuery += cAlias + "." + cCampo + "_MSFIL>='"+cFilDe+"' AND "
				cQuery += cAlias + "." + cCampo + "_MSFIL<='"+cFilAte+"' AND "
			EndIf	
			cQuery += cAlias + "." + cCampo + "_VENCREA >= '"+Dtos(dDatIni)+"' AND "			
			cQuery += cAlias + "." + cCampo + "_VENCREA <= '"+Dtos(dDataBase-1)+"' AND "
			cQuery += cAlias + "." + cCampo + "_TIPO NOT IN " + cRecPagAnt + " AND "
			cQuery += cAlias + "." + cCampo + "_SALDO > 0 AND "
			cQuery += cAlias + "." + cCampo + "_FLUXO <> 'N' AND "
			If cAlias == "SE1"
				cQuery += cAlias + "." + cCampo + "_SITUACA NOT IN ('2','7') AND "
			Endif
			cQuery += cAlias + ".D_E_L_E_T_=' ' "
		Endif	

	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
		aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})
	Else	
#ENDIF		
		If cAlias == "SE3"
			cFiltro := "E3_FILIAL>='"+cFilDe+"'.And."
			cFiltro += "E3_FILIAL<='"+cFilAte+"'.And."
			cFiltro += "Dtos(E3_VENCTO)<='"+Dtos(dDataBase-1)+"'.And."
			cFiltro += "Dtos(E3_DATA)='"+Dtos(Ctod(""))+"'"
		Else
			cFiltro := cCampo + "_FILIAL>='"+cFilDe+"'.And."
			cFiltro += cCampo + "_FILIAL<='"+cFilAte+"'.And."
			cFiltro += "Dtos("+cCampo+"_VENCREA)<='"+Dtos(dDataBase-1)+"'.And."
			cFiltro += ".Not. " + cCampo+"_TIPO $ '"+cRecPagAnt+"'.And."
			cFiltro += cCampo+"_SALDO > 0.And."
			If cAlias == "SE1"
				cFiltro += ".Not. "+ cCampo + "_SITUACA $ '27'.And."
			Endif
			cFiltro += cCampo+"_FLUXO != 'N'"
		Endif	
			
		dbSelectArea(cAlias)
		cIndTmp := CriaTrab(,.F.)
		IndRegua(cAlias,cIndTmp,IndexKey(),,cFiltro)
		dbGotop()
		cAliasTrb := cAlias
#IFDEF TOP
	Endif
#ENDIF		
While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc(STR0074 + If(cAlias=="SE1", STR0056,STR0057)) //"Processando titulos vencidos a "###"Receber"###"Pagar"
	If cAlias == "SE3"
		nRet := xMoeda(SE3->E3_COMIS,1,nMoeda)
	Else
		nSaldo:=xMoeda((cAliasTrb)->&(cCampo+"_SALDO")+;
							((cAliasTrb)->&(cCampo+"_SDACRES")-;
							(cAliasTrb)->&(cCampo+"_SDDECRE")),;
							(cAliasTrb)->&(cCampo+"_MOEDA")  ,;
							nMoeda,(cAliasTrb)->&(cCampo+"_VENCREA"))
	
		If (cAliasTrb)->&(cCampo+"_TIPO") $ MVABATIM + MV_CPNEG 
			nRet -= nSaldo
		Else			
			nRet += nSaldo      

			CalcAtraso(cAliasTrb,cCampo,aFluxo,nSaldo,cAlias,lAnalitico,MVABATIM,aPeriodo,aTotais)
			
		Endif
	Endif	
	(cAliasTrb)->(dbSkip())
Enddo
#IFDEF TOP
	If TcSrvType() != "AS/400"
		dbSelectArea(cAliasTrb)
		dbCloseArea()
		dbSelectArea(cAlias)
	Else
#ENDIF
		dbSelectArea(cAlias)
		dbClearFil(NIL)
		RetIndex(cAlias)
		If !Empty(cIndTmp)
			FErase (cIndTmp+OrdBagExt())
		Endif
		dbSetOrder(1)
#IFDEF TOP
	Endif
#ENDIF

RestArea(aArea)
(cAlias)->(RestArea(aArea1))

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FormatIn  ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Formatar uma string para ser utilizada no clausula IN do    º±±
±±º          ³comando SELECT em ambiente SQL.                             º±±
±±º          ³Exemplo:                                                    º±±
±±º          ³FormatIn("BA /AB-/CA-/XX+", "/")= "('BA','AB-','CA-','XX+')"º±±
±±º          ³Parametros:                                                 º±±
±±º          ³cString  -> String a ser formatada                          º±±
±±º          ³cSep     -> Separador das strings                           º±±
±±º          ³Retorno:                                                    º±±
±±º          ³cRet  -> String formatada, conforme exemplo                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION FormatIn( cString, cSep, nTam )
   LOCAL cRet := "('",; // array de string separadas
         nPoSep         // posicao do separador da string
	DEFAULT nTam := 0
   WHILE .T.
      // localiza a posicao do separador e separa a string encontrada
      If nTam > 0  
      	nPoSep := nTam
      Else
	      nPoSep := AT(cSep,cString)
	   Endif 
      cRet   += IF(nPoSep#0, LEFT(cString,nPoSep-If(nTam>0,0,1))+"','", cString)
      // verifica se existem mais separadores
      IF nPoSep#0 
      	If Len(cString) > nTam
         	cString := SUBSTR(cString,nPoSep+1)
         Else
         	cRet := Left(cRet,Len(cRet)-3)
     			cRet += "')"
   	      EXIT
   	   Endif	
      ELSE
			cRet += "')"
         EXIT
      ENDIF
   ENDDO

RETURN cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³FluxoAna  ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe o fluxo analitico, ou seja, os dados que compem os   º±±
±±º          ³ valores do fluxo sintetico                                 º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cArqAnaP   -> Nome do arquivo temporario CP                º±±
±±º          ³ cAliasP    -> Alias do arquivo temporario CP               º±±
±±º          ³ cArqAnaR   -> Nome do arquivo temporario CR                º±±
±±º          ³ cAliasR    -> Alias do arquivo temporario CR               º±±
±±º          ³ cAliasPc   -> Alias do arquivo temporario Pedido de compra º±±
±±º          ³ cAliasPv   -> Alias do arquivo temporario Pedido de Venda  º±±
±±º          ³ cAliasEmp  -> Alias do arquivo temporario Emprestimos      º±±
±±º          ³ cAliasCo   -> Alias do arquivo temporario Comissões        º±±
±±º          ³ dData      -> Data a exibir                                º±±
±±º          ³ aTotais    -> Matriz de totais por folder/data             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION FluxoAna(cAliasP,cAliasR,cAliasPc,cAliasPv,cAliasCo,cAliasEmp,;
								 cAliasApl,cPeriodo,aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,;
								 nAtrPagar,aPeriodo)
Local aReceber := {},;
		aPagar   := {},;
		aArea    := GetArea(),;
		aOldHeader := aClone(aHeader),;
		oGetDb1 ,;
		oGetDb2 ,;
		oGetDb3 ,;
		oGetDb4 ,;
		oGetDb5 ,;
		oGetDb6 ,;			
		oGetDb7 ,;
		oFolder ,;
		aHeader1,;
		aHeader2,;
		aHeader3,;
		aHeader4,;
		aHeader5,;
		aHeader6,;
		aHeader7,;
		nAscan  ,;
		oSayTotal,;
		oGetTotal,;
		oSayCheq,;
		oGetCheq,;		
		nTotal := 0
LOCAL oDlg,oCursor, oBold, aGetDb, aAlias
LOCAL aSize, aObjects := {}, aInfo, aPosObj
LOCAL cFiltro := "Periodo='"+Transform(cPeriodo,"")+"'" // Filtro para a GetDb

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

aSize := MsAdvSize()
aadd( aObjects, { 100, 100, .T., .T., .T. } )  
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
aPosObj := MsObjSize( aInfo, aObjects )  

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE OemToAnsi(STR0075 + cPeriodo) PIXEL of oMainWnd //"Detalhes do Dia" //"Detalhes do dia "
@ aPosObj[1,1],aPosObj[1,2] FOLDER oFolder SIZE aPosObj[1,3],aPosObj[1,4]-15 OF oDlg PROMPTS STR0035,STR0036,STR0011,STR0010,STR0009,STR0076,STR0077 PIXEL //"A Pagar"###"A Receber"###"Pedido de Compra"###"Pedido de Venda"###"Comissões"###"Emprestimos"###"Aplicações"
oFolder:bSetOption:={|nAtu| Fc021ChFol(nAtu,oFolder:nOption,oFolder,oDlg,aTotais,oSayTotal,oGetTotal, @nTotal,cPeriodo,aGetDb, aAlias,aHeader1,aHeader2,aHeader3,aHeader4,aHeader5,aHeader6,aHeader7)}

If cAliasP != Nil .And. Select(cAliasP) > 0

	nAscan := Ascan( aTotais[oFolder:nOption], {|e|Transform(e[1],"") = cPeriodo})
	If nAscan > 0
		nTotal := aTotais[oFolder:nOption][nAscan][2]
	Endif

	@ aPosObj[1,4]+4, aPosObj[1,2]+  1   SAY oSayTotal VAR STR0078 PIXEL OF oDlg FONT oBold //"Total de titulos a Pagar"
	@ aPosObj[1,4]+4, aPosObj[1,2]+100 MSGET oGetTotal VAR nTotal PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold

EndIf

nTotNorm := 0
nTotCheq := 0

@ aPosObj[1,4]+4, aPosObj[1,2]+170   SAY "Total de Cheques " PIXEL OF oDlg FONT oBold
@ aPosObj[1,4]+4, aPosObj[1,2]+245 MSGET nTotCheq PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold

@ aPosObj[1,4]+4, aPosObj[1,2]+350   SAY "Total de Titulos" PIXEL OF oDlg FONT oBold
@ aPosObj[1,4]+4, aPosObj[1,2]+424 MSGET nTotNorm PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold

	
If cAliasR != Nil .And. Select(cAliasR) > 0

	nAscan 	:= Ascan( aTotais[2], {|e|Transform(e[1],"") = cPeriodo})
	nTotCheq := 0
	nTotNorm := 0
	If nAscan > 0
		nTotCheq := aTotais[2][nAscan][3]   // VAVA
		nTotNorm := aTotais[2][nAscan][4]
	Endif	
	
	@ aPosObj[1,4]+4, aPosObj[1,2]+170   SAY "Total de Cheques " PIXEL OF oDlg FONT oBold
	@ aPosObj[1,4]+4, aPosObj[1,2]+245 MSGET nTotCheq PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold

	@ aPosObj[1,4]+4, aPosObj[1,2]+350   SAY "Total de Titulos" PIXEL OF oDlg FONT oBold
	@ aPosObj[1,4]+4, aPosObj[1,2]+424 MSGET nTotNorm PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold

Else
	nTotNorm := 0
	nTotCheq := 0

	@ aPosObj[1,4]+4, aPosObj[1,2]+170   SAY "Total de Cheques " PIXEL OF oDlg FONT oBold
	@ aPosObj[1,4]+4, aPosObj[1,2]+245 MSGET nTotCheq PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold

	@ aPosObj[1,4]+4, aPosObj[1,2]+350   SAY "Total de Titulos" PIXEL OF oDlg FONT oBold
	@ aPosObj[1,4]+4, aPosObj[1,2]+424 MSGET nTotNorm PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold
	
EndIf

If cAliasP != Nil .And. Select(cAliasP) > 0
	DbSelectArea(cAliasP)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0079, "Prefixo"   , "", Len((cAliasP)->Prefixo), 0, ".F.", USADO, "C",, "V" } ) //"Prefixo"
	Aadd( aHeader, { STR0080, "Num"       , "", Len((cAliasP)->Num)    , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0081, "Parcela"   , "", Len((cAliasP)->Parcela), 0, ".F.", USADO, "C",, "V" } ) //"Parc"
	Aadd( aHeader, { STR0082, "Tipo"      , "", Len((cAliasP)->Tipo)   , 0, ".F.", USADO, "C",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0083, "CliFor"    , "", Len((cAliasP)->CliFor) , 0, ".F.", USADO, "C",, "V" } ) //"Fornecedor"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasP)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0084, "Loja"      , "", Len((cAliasP)->Loja)   , 0, ".F.", USADO, "C",, "V" } ) //"Loja"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader1 := aClone(aHeader)
	oGetDb1 := (cAliasP)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasP,"AllwaysTrue",,,oFolder:aDialogs[1],.F.,.T.))
	oGetDb1:oBrowse:lHScroll := .F.
	oGetDb1:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[1]:Cargo := {"P",{||Fc021Visual("SE2",(cAliasP)->Chave,STR0085)}} //"Contas a Pagar"
Endif
If cAliasR != Nil .And. Select(cAliasR) > 0
	DbSelectArea(cAliasR)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0079, "Prefixo"   , "", Len((cAliasR)->Prefixo), 0, ".F.", USADO, "C",, "V" } ) //"Prefixo"
	Aadd( aHeader, { STR0080, "Num"       , "", Len((cAliasR)->Num)    , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0081, "Parcela"   , "", Len((cAliasR)->Parcela), 0, ".F.", USADO, "C",, "V" } ) //"Parc"
	Aadd( aHeader, { STR0082, "Tipo"      , "", Len((cAliasR)->Tipo)   , 0, ".F.", USADO, "C",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0088, "CliFor"    , "", Len((cAliasR)->CliFor) , 0, ".F.", USADO, "C",, "V" } ) //"Cliente"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasR)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0084, "Loja"      , "", Len((cAliasR)->Loja)   , 0, ".F.", USADO, "C",, "V" } ) //"Loja"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader2 := aClone(aHeader)
	oGetDb2 := (cAliasR)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasR,"AllwaysTrue",,,oFolder:aDialogs[2],.F.,.T.))
	oGetDb2:oBrowse:lHScroll := .F.
	oGetDb2:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[2]:Cargo := {"R",{||Fc021Visual("SE1",(cAliasR)->Chave,STR0089)}} //"Contas a Receber"
Endif	
If cAliasPc != Nil .And. Select(cAliasPc) > 0
	DbSelectArea(cAliasPc)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasPc)->numero)   , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0090, "Emissao"   , "",              8, 0, ".F.", USADO, "D",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0083, "Clifor"    , "", Len((cAliasPc)->CliFor)   , 0, ".F.", USADO, "C",, "V" } ) //"Fornecedor"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasPc)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0082, "Tipo"      , "", TamSx3("C7_TIPO")[1], 0, ".F.", USADO, "N",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0091, "Item"      , "", Len((cAliasPc)->Item)     , 0, ".F.", USADO, "C",, "V" } ) //"Item"
	Aadd( aHeader, { STR0092, "Produto"   , "", Len((cAliasPc)->Produto)  , 0, ".F.", USADO, "C",, "V" } ) //"Produto"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader3 := aClone(aHeader)
	oGetDb3 := (cAliasPc)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasPc,"AllwaysTrue",,,oFolder:aDialogs[3],.F.,.T.))
	oGetDb3:oBrowse:lHScroll := .F.
	oGetDb3:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[3]:Cargo := {"P",{||Fc021Visual("SC7",(cAliasPc)->Chave,STR0093)}} //"Pedidos de Compras"
Endif
If cAliasPv != Nil .And. Select(cAliasPv) > 0	
	DbSelectArea(cAliasPv)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasPv)->Numero) , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0082, "Tipo"      , "", Len((cAliasPv)->Tipo)   , 0, ".F.", USADO, "C",, "V" } ) //"Tipo"
	Aadd( aHeader, { STR0090, "Emissao"   , "",  			  8, 0, ".F.", USADO, "C",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0088, "CliFor"    , "", Len((cAliasPv)->CliFor) , 0, ".F.", USADO, "C",, "V" } ) //"Cliente"
	Aadd( aHeader, { STR0064, "NomCliFor" , "", Len((cAliasPv)->NomCliFor), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0094, "LojaCli" , "", Len((cAliasPv)->LojaCli) , 0, ".F.", USADO, "C",, "V" } ) //"Loja Cliente"
	Aadd( aHeader, { STR0095, "LojaEnt" , "", Len((cAliasPv)->LojaEnt) , 0, ".F.", USADO, "C",, "V" } ) //"Loja Entrega"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader4 := aClone(aHeader)
	oGetDb4 := (cAliasPv)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasPv,"AllwaysTrue",,,oFolder:aDialogs[4],.F.,.T.))
	oGetDb4:oBrowse:lHScroll := .F.
	oGetDb4:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[4]:Cargo := {"R",{||Fc021Visual("SC5",(cAliasPv)->Chave,STR0096)}} //"Pedidos de Venda"
Endif
If cAliasCo != Nil .And. Select(cAliasCo) > 0
	DbSelectArea(cAliasCo)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0079, "Prefixo"  , "", Len((cAliasCo)->prefixo) , 0, ".F.", USADO, "C",, "V" } ) //"Prefixo"
	Aadd( aHeader, { STR0080, "Numero"   , "", Len((cAliasCo)->numero)  , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0097, "Parcela"  , "", Len((cAliasCo)->Parcela) , 0, ".F.", USADO, "C",, "V" } ) //"Parcela"
	Aadd( aHeader, { STR0098, "Vend"     , "", Len((cAliasCo)->Vend)    , 0, ".F.", USADO, "C",, "V" } ) //"Vendedor"
	Aadd( aHeader, { STR0064, "NomeVend" , "", Len((cAliasCo)->NomeVend), 0, ".F.", USADO, "C",, "V" } ) //"Nome"
	Aadd( aHeader, { STR0026, "Saldo"    , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo", "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader5 := aClone(aHeader)
	oGetDb5 := (cAliasCo)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.F.,,,.F.,,cAliasCo,"AllwaysTrue",,,oFolder:aDialogs[5],.F.,.T.))
	oGetDb5:oBrowse:lHScroll := .F.
	oGetDb1:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[5]:Cargo := {"P",{||Fc021Visual("SE3",(cAliasCo)->Chave,STR0009)}} //"Comissões"
Endif
If cAliasEmp != Nil .And. Select(cAliasEmp) > 0
	DbSelectArea(cAliasEmp)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasEmp)->numero) , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0061, "Banco"     , "", Len((cAliasEmp)->Banco)  , 0, ".F.", USADO, "C",, "V" } ) //"Banco"
	Aadd( aHeader, { STR0062, "Agencia"   , "", Len((cAliasEmp)->Agencia), 0, ".F.", USADO, "C",, "V" } ) //"Agencia"
	Aadd( aHeader, { STR0063, "Conta"     , "", Len((cAliasEmp)->Conta)  , 0, ".F.", USADO, "C",, "V" } ) //"Conta"
	Aadd( aHeader, { STR0090, "Emissao"   , "", 8,0, ".F.", USADO, "D",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader6 := aClone(aHeader)
	oGetDb6  := (cAliasEmp)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.T.,{},,.T.,,cAliasEmp,"AllwaysTrue",,,oFolder:aDialogs[6],.F.,.T.))
	oGetDb6:oBrowse:lHScroll := .F.
	oGetDb6:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[6]:Cargo := {"P",{||Fc021Visual("SEH",(cAliasEmp)->Chave,STR0076)}} //"Emprestimos"
Endif
If cAliasApl != Nil .And. Select(cAliasApl) > 0
	DbSelectArea(cAliasApl)
	Set Filter To &cFiltro
	DbGoTop()
	aHeader := {}
	Aadd( aHeader, { STR0080, "Numero"    , "", Len((cAliasApl)->numero) , 0, ".F.", USADO, "C",, "V" } ) //"Numero"
	Aadd( aHeader, { STR0061, "Banco"     , "", Len((cAliasApl)->Banco)  , 0, ".F.", USADO, "C",, "V" } ) //"Banco"
	Aadd( aHeader, { STR0062, "Agencia"   , "", Len((cAliasApl)->Agencia), 0, ".F.", USADO, "C",, "V" } ) //"Agencia"
	Aadd( aHeader, { STR0063, "Conta"     , "", Len((cAliasApl)->Conta)  , 0, ".F.", USADO, "C",, "V" } ) //"Conta"
	Aadd( aHeader, { STR0090, "Emissao"   , "", 8,0, ".F.", USADO, "D",, "V" } ) //"Emissao"
	Aadd( aHeader, { STR0026, "Saldo"     , "@e 999,999,999.99", 15, 2, ".T.", USADO, "N",, "V" } ) //"Valor"
	Aadd( aHeader, { ""     , "CampoNulo" , "", 1, 0, ".T.", USADO, "C",, "V" } )
	aHeader7 := aClone(aHeader)
	oGetDb7  := (cAliasApl)->(MsGetDb():New(1,2,aPosObj[1,4]-30,aPosObj[1,3]-5,2,,,,.T.,{},,.T.,,cAliasApl,"AllwaysTrue",,,oFolder:aDialogs[7],.F.,.T.))
	oGetDb7:oBrowse:lHScroll := .F.
	oGetDb7:oBrowse:lDisablePaint := .T.
	oFolder:aDialogs[7]:Cargo := {"R",{||Fc021Visual("SEH",(cAliasApl)->Chave,STR0077)}} //"Aplicações"
Endif

aGetDb := {oGetDb1,oGetDb2,oGetDb3,oGetdb4,oGetDb5,oGetDb6,oGetDb7}
aAlias := {cAliasP,cAliasR,cAliasPc,cAliasPv,cAliasCo,cAliasEmp,cAliasApl}

// Posiciona no primeiro folder valido
For nX := 1 To Len(aAlias)
	Do Case
	Case nX == 1 .And. ValType(aHeader1) == "A"
		aHeader := aClone(aHeader1)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 2 .And. ValType(aHeader2) == "A"
		aHeader := aClone(aHeader2)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 3 .And. ValType(aHeader3) == "A"
		aHeader := aClone(aHeader3)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 4 .And. ValType(aHeader4) == "A"
		aHeader := aClone(aHeader4)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 5 .And. ValType(aHeader5) == "A"
		aHeader := aClone(aHeader5)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 6 .And. ValType(aHeader6) == "A"
		aHeader := aClone(aHeader6)
		DbSelectArea(aAlias[nX])
		Exit
	Case nX == 7 .And. ValType(aHeader7) == "A"
		aHeader := aClone(aHeader7)
		DbSelectArea(aAlias[nX])
		Exit	
	EndCase
Next

ACTIVATE MSDIALOG oDlg ON INIT (aEval(aGetDb, {|e| If(ValType(e)=="0",(e:oBrowse:lDisablePaint := .F., e:oBrowse:Refresh(.T.)),Nil)}),;
									  	  Fc021Bar(oDlg, {|| oDlg:End() }, {|| oDlg:End()},oFolder,aGetDb,aTotais,aFluxo,aAlias,nBancos,nCaixas,nAtrReceber,nAtrPagar,@nTotal,aPeriodo),;
										  oFolder:SetOption(2))

// Limpa os filtros dos arquivos temporarios
For nX := 1 To Len(aAlias)
	If aAlias[nX] != Nil .And. Select(aAlias[nX]) > 0
		DbSelectArea(aAlias[nX])
		(aAlias[nX])->(DbClearFil())
	EndIf
Next

RestArea(aArea)
aHeader := aClone(aOldHeader)
               
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc020visua³ Autor ³ Claudio d. de Souza   ³ Data ³ 21/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Detalhe do t¡tulo da tela anal¡tica					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Fc020Visual(cAlias,cChave) 										  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ Gen‚rico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Visual(cAlias,cChave,cTitulo)
Local aArea      := GetArea()

If !Empty(cChave)
	dbSelectArea(cAlias)
	dbSetOrder( 1 )
	dbseek( cChave )
	If !(cAlias)->( Eof() )
		cCadastro := OemToAnsi(cTitulo)
		Do Case
		Case cAlias == "SC7"
			// Necessaria para visualizar o pedido de compra
			aRotina   := {{ "","PesqBrw", 0 , 1},;
							  { "","A120Pedido", 0 , 2} }
		 	l120Auto := .F.
			Inclui := .F.
			A120Pedido(cAlias,RECNO(),2)
		Case cAlias == "SC5"
			aRotina   := {{ "","AxPesqui", 0 , 1},;	
							   { "","A410Visual", 0 , 2} }
			a410Visual(cAlias,RECNO(),2)
		OtherWise
			AxVisual(cAlias,Recno(),2)
		EndCase
	Endif
	RestArea(aArea)
Endif	

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Grafico   ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar o tipo da serie de dados e o tipo de grafico    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ oDlg   -> Objeto dialog onde sera exibido a tela do graficoº±±
±±º          ³ cAlias -> Alias do arquivo temporario que sera processado  º±±
±±º          ³ nMoeda -> Codigo da moeda                                  º±±
±±º          ³ cTit   -> Titulo do eixo X                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grafico(oDlg,aFluxo,nMoeda,cTit)
Local oDlgSer
Local oSer
Local oVisual
Local cCbx := STR0099 //"Linha"
Local cVisual := STR0100 //"Projeção do Saldo"
Local nCbx := 1
Local aCbx := { STR0099, STR0101, STR0102, STR0103, STR0104, STR0105,; //"Linha"###"Área"###"Pontos"###"Barras"###"Piramid"###"Cilindro"
					 STR0106, STR0107, STR0108,; //"Barras Horizontal"###"Piramid Horizontal"###"Cilindro Horizontal"
					 STR0109, STR0110, STR0111, STR0112, STR0113, STR0114 } //"Pizza"###"Forma"###"Linha rápida"###"Flexas"###"GANTT"###"Bolha"
Local aVisual := { STR0115, STR0100 } //"Receitas x Despesas"###"Projeção do Saldo"
Local nVisual := 2

DEFINE MSDIALOG oDlgSer TITLE STR0116 FROM 0,0 TO 100,280 PIXEL OF oDlg //"Tipo do gráfico"

@ 008, 005 SAY STR0117 PIXEL OF oDlgSer //"Escolha o tipo de série:"
@ 008, 063 MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nCbx := oSer:nAt
@ 022, 005 SAY STR0118 PIXEL OF oDlgSer //"Tipo de Visualização   :"
@ 022, 063 MSCOMBOBOX oVisual VAR cVisual ITEMS aVisual SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nVisual := oVisual:nAt
@ 035, 045 BUTTON "&Ok"  SIZE 30,12 OF oDlgSer PIXEL ACTION (oDlgSer:End(),MontaGrafico(aFluxo,nCbx,nVisual,nMoeda,cTit))
@ 035, 075 BUTTON STR0040 SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End() //"&Sair"

ACTIVATE MSDIALOG oDlgSer CENTER

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MontaGraf ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa os dados necessarios para montagem do grafico e   º±±
±±º          ³ exibe o grafico.                                           º±±
±±º          ³ cAlias  -> Alias do arquivo temporario que sera processado º±±
±±º          ³ nCbx    -> Codigo da serie de dados que sera utilizada peloº±±
±±º          ³            objeto grafico                                  º±±
±±º          ³ nVisual -> Tipo de visualizacao 1-Contas a pagar x Ctas Recº±±
±±º          ³                                 2-Projecao do saldo        º±±
±±º          ³ nMoeda  -> Codigo da moeda                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaGrafico(aFluxo,nCbx,nVisual,nMoeda,cTit)
Local oDlg
Local obmp
Local oBold
Local oGraphic
Local nSerie      := 0
Local nSerie2     := 0
Local aArea       := GetArea()
Local aTabela

aTabela		:= {{	cTit   ,; //"Dia","Semana","Decendio","Quinzena","Mes"
		 			   STR0043,; //"Entradas"
		 				STR0044,; //"Saidas"
		 				STR0045,; //"Saldo do Dia"
		 				STR0046,; //"Var.Dia"
		 				STR0047,; //"Entr.Acumul."
		 				STR0048,; //"Saida Acumul."
		 				STR0049,; //"Saldo Acumul."
		 				STR0050}}
For nX := 1 To Len(aFluxo)
	Aadd(aTabela,{	Pad(Transform(aFluxo[nX,DATAFLUXO],""),17),;
					 	Transform(aFluxo[nX,ENTRADAS				]	,"@e 99,999,999,999.99"),;
						Transform(aFluxo[nX,SAIDAS		  		   ]	,"@e 99,999,999,999.99"),;
						Transform(aFluxo[nX,SALDODIA				]	,"@e 99,999,999,999.99"),;
						Transform(aFluxo[nX,VARIACAODIA			]	,"@r 9999999999999.99%"),;
						Transform(aFluxo[nX,ENTRADASACUMULADAS]	,"@e 99,999,999,999.99"),;
						Transform(aFluxo[nX,SAIDASACUMULADAS	]	,"@e 99,999,999,999.99"),;
						Transform(aFluxo[nX,SALDOACUMULADO		]	,"@e 99,999,999,999.99"),;
						Transform(aFluxo[nX,VARIACAOACUMULADA	]	,"@r 9999999999999.99%")})
Next		 				

DEFINE MSDIALOG oDlg FROM 0,0 TO 450,700 PIXEL TITLE STR0119 //"Representação gráfica do Fluxo de Caixa"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Layout da janela
@ 000, 000 BITMAP oBmp RESNAME "ProjetoAP" oF oDlg SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 003, 060 SAY STR0120 + If( nVisual == 1, STR0115, STR0121) FONT oBold PIXEL //"Fluxo de Caixa - "###"Receitas x Despesas"###"Projeção de Saldo"

@ 014, 050 TO 16 ,400 LABEL '' OF oDlg  PIXEL

@ 014, 050 TO 16 ,400 LABEL '' OF oDlg  PIXEL

@ 020, 055 MSGRAPHIC oGraphic SIZE 285, 158 OF oDlg PIXEL  // VERICAR DECO
oGraphic:SetMargins( 2, 6, 6, 6 )
oGraphic:bRClicked := {|o,x,y| oMenu:Activate(x,y,oGraphic) } // Posição x,y em relação a Dialog 
MENU oMenu POPUP
	MENUITEM STR0188 Action ConsDadGraf(aTabela) //"Consulta dados do grafico"
ENDMENU

// Habilita a legenda, apenas se houver mais de uma serie de dados.
oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)
nSerie  := oGraphic:CreateSerie(nCbx)

// Adiciona mais uma série de dados, conforme o tipo do grafico
If nVisual == 1 // Contas a Pagar x Contas a Receber
   nSerie2 := oGraphic:CreateSerie(nCbx)
   @ 185, 57 SAY STR0122 OF oDlg COLOR CLR_HBLUE FONT oBold PIXEL //"Receitas"
   @ 195, 57 SAY STR0123 OF oDlg COLOR CLR_HRED  FONT oBold PIXEL //"Despesas"
Endif   
   
If nSerie != GRP_CREATE_ERR .And. nSerie2 != GRP_CREATE_ERR 
	aEval(aFluxo,{|e|If(nVisual==1,(oGraphic:Add(nSerie ,e[ENTRADASACUMULADAS],Transform(e[DATAFLUXO],""),CLR_HBLUE),;
										  	   oGraphic:Add(nSerie2,e[SAIDASACUMULADAS]  ,Transform(e[DATAFLUXO],""),CLR_HRED)),;
										  		oGraphic:Add(nSerie ,e[SALDOACUMULADO]    ,Transform(e[DATAFLUXO],""),If(e[SALDOACUMULADO]<0,CLR_HRED,CLR_HBLUE)))})
Else
	ApMsgAlert(STR0124) //"Não foi possível criar a série."
Endif
                             
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( GetMv("MV_SIMB"+Alltrim(Str(nMoeda,2))),"", CLR_HRED , A_LEFTJUST , GRP_TITLE )
oGraphic:SetTitle( "", cTit, CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //"Datas"

@ 190, 254 BUTTON o3D PROMPT "&2D" SIZE 40,14 OF oDlg PIXEL ACTION (oGraphic:l3D := !oGraphic:l3D, o3d:cCaption := If(oGraphic:l3D, "&2D", "&3D"))
@ 190, 295 BUTTON STR0126   SIZE 40,14 OF oDlg PIXEL ACTION GrafSavBmp( oGraphic ) //"&Salva BMP"
@ 190, 170 BUTTON STR0127   SIZE 40,14 OF oDlg WHEN oGraphic:l3D PIXEL ACTION oGraphic:ChgRotat( nSerie, 1, .T. ) // nRotation tem que estar entre 1 e 30 passos //"Rotação &-"
@ 190, 212 BUTTON STR0128   SIZE 40,14 OF oDlg WHEN oGraphic:l3D PIXEL ACTION oGraphic:ChgRotat( nSerie, 1, .F. ) // nRotation tem que estar entre 1 e 30 passos //"Rotação &+"

@ 207, 050 TO 209 ,400 LABEL '' OF oDlg  PIXEL
If !__lPyme
	@ 213, 254 BUTTON STR0187 SIZE 40,12 OF oDlg PIXEL ACTION PmsGrafMail(oGraphic,STR0119,{STR0120 + If( nVisual == 1, STR0115, STR0121)},aTabela,1) // E-Mail
Endif
@ 213, 295 BUTTON STR0040 SIZE 40,12 OF oDlg PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021ImpFlx³ Autor ³ Claudio Donizete 	  ³ Data ³ 23/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime o Fluxo de Caixa											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021ImpFlx(	aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,;
										nAtrReceber,aFluxo,cTit,cMoeda)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 														  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1 :=OemToAnsi(STR0132) //"Este programa ir  imprimir o Fluxo de Caixa."s //"Este programa imprimirá o Fluxo de Caixa."
Local cDesc2 :=""
Local cDesc3 :=""

Private aReturn:={STR0133,1,STR0134,1,2,1,"",1} //"Zebrado"###"Administracao" //"Zebrado"###"Administracao"
Private cabec1,cabec2,nLastKey:=0,titulo,wnrel,tamanho:="P"
Private nomeprog :="FINC021"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo:= STR0032 + STR0193 + Capital(SubStr(cMoeda,3)) // "Fluxo de Caixa" //" em "
cabec1:= Pad(cTit,18)+STR0135 //"Data             " + "A Pagar       A Receber      Disponivel"
cabec2:= ""

wnrel:="FINC021"            //Nome Default do relatorio em Disco
wnrel:=SetPrint("SE1",wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| Fc021ImpOk(@lEnd,wnRel,aBancos,lSaldoBanc,nCaixas,nBancos,nAtrPagar,nAtrReceber,aFluxo)},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021ImpOk ³ Autor ³ Claudio Donizete 	  ³ Data ³ 23/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime o Fluxo de Caixa.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021ImpOk(lEnd,wnRel,aBancos,lSaldoBanc,nCaixas,nBancos,;
									nAtrPagar,nAtrReceber,aFluxo)
Local nX := 0
Local nTotReceitas := 0
Local nTotDespesas := 0
Local nTotCheques	 := 0
Local nDisponivel  := 0
Local cBancoCx		 := GetMV("MV_CARTEIR")
Local aArea := GetArea()
Local cPeriodo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt  := Space(10)
cbcont := 00
li  := 80
m_pag  := 01

SetRegua(Len(aFluxo)+Len(aBancos))

If lSaldoBanc
	For nX := 1 To Len(aBancos)
		IncRegua()
		If Val(StrTran(StrTran(aBancos[nX,6],".",""),",",".")) != 0
			If ( li > 58 )
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
			EndIf
			li++
			@li, 0 PSAY Substr(aBancos[nX,5],1,30)
			@li,61 PSAY aBancos[nX,6]
		EndIf
	Next
	If ( li > 55 )
		li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
	EndIf
	If ( nBAncos != 0)
		li++
		@li, 0 PSAY STR0136 //"Total em Bancos : "
		@li,57 PSAY nBancos	 Picture tm(nBancos,18)
	EndIf
	If ( nCaixas != 0 )
		li++
		@li, 0 PSAY STR0137 //"Total em Caixa : "
		@li,57 PSAY nCaixas	 Picture tm(nCaixas,18)
	EndIf
	If ( nBancos != 0 .and. nCaixas != 0 )
		li++
		@li, 0 PSAY STR0138 //"Total Disponivel : "
		@li,57 PSAY nBancos+nCaixas	Picture tm(nBancos+nCaixas,18)
		li++
	EndIf
	@++li,00 PSay Repl("-",80)
EndIf

nDisponivel := (nBancos+nCaixas)
nDisponivel += (nAtrReceber - nAtrPagar)

li++
For nX := 1 TO Len(aFluxo)
	IF lEnd
		@PROW()+1,001 PSAY STR0139 //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF

	IncRegua()

	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
	End

	nDisponivel -= aFluxo[nX][SAIDAS]
	nDisponivel += aFluxo[nX][ENTRADAS]

	If aFluxo[nX][SAIDAS]+aFluxo[nX][ENTRADAS] != 0
		@li,00 PSay Left(aFluxo[nX][DATAFLUXO],13)
		@Prow(),PCOL()+1 PSay aFluxo[nX][SAIDAS]    picture TM(aFluxo[nX][SAIDAS],18)
		@Prow(),PCOL()+1 PSay aFluxo[nX][ENTRADAS]  picture TM(aFluxo[nX][ENTRADAS],18)
		@Prow(),PCOL()+1 Psay (aFluxo[nX][SAIDAS]/aFluxo[nX][ENTRADAS])*100 Picture "@E 99999.99%"
		@Prow(),PCOL()+1 PSay nDisponivel  picture TM(nDisponivel,18)
		li ++
	Endif

	nTotDespesas += aFluxo[nX][SAIDAS]
	nTotReceitas += aFluxo[nX][ENTRADAS]
	nTotCheques	 += aFluxo[nX][CHEQUESRECEBER] 

Next

If li+8 > 55
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
End

@li++,00 PSay Repl("-",80)
@li++,00 PSay STR0186 + Transform(nAtrReceber,"@E 999,999,999,999.99") //"Total de Atrasados a Receber : "
@li++,00 PSay "Total Atrasados Titulos      : " + Transform((nAtrReceber - nTotCheques),"@E 999,999,999,999.99") //"Saldo             : "
@li++,00 PSay "Total Atrasados Cheques      : " + Transform(nTotCheques,"@E 999,999,999,999.99") //"Saldo             : "
@li++,00 PSay STR0140 + Transform(nAtrPagar,"@E 999,999,999,999.99") //"Total de Atrasados a Pagar   : "
@li++,00 PSay STR0141 + Transform(nBancos+nCaixas+nAtrReceber-nAtrPagar,"@E 999,999,999,999.99") //"Disponibilidade   : "
@li++,00 PSay STR0142 + Transform((nTotReceitas),"@E 999,999,999,999.99") //"Total A Receber   : "
@li++,00 PSay STR0143 + Transform(nTotDespesas,"@E 999,999,999,999.99") //"Total A Pagar     : "
@li++,00 PSay STR0144 + Transform(nDisponivel,"@E 999,999,999,999.99") //"Saldo             : "

@li++,00 PSay Repl("-",80)

roda(cbcont,cbtxt)

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021SimulºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Simulacao do fluxo de caixa                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Simul(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,;
									nMoeda,nDias,aPeriodo)
Local oGet					 ,;
		aArea := GetArea(),;
		aOldHeader := aClone(aHeader),;
		oDlg              ,;
		nOpca					,;
		lNaoTemSimul	   ,;
		nIndPer				,;
		nAscan
Local aSize, aObjects := {}, aInfo, aPosObj
		
LocaL	aButSimul := {	{"SALVAR",{||Fc021GrvSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda)},STR0145},; //"Grava Simulação"
						  	{"ALTERA",{||Fc021RstSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda,lNaoTemSimul,nDias,aPeriodo)},STR0146}} //"Restaura Simulação"
		
lNaoTemSimul := (aCols == Nil .Or. Empty(aCols) .Or. Empty(aCols[1][3]))
// Cria aCols caso nao exista, ou esteja vazia e nao permite a opcao de
// nova simulacao pois os valores da simulacao atual sao abatidos do Fluxo.
If lNaoTemSimul
	LimpaACols()
Else
	Aadd(aButSimul,{"EDIT"  ,{||Fc021NovSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lNaoTemSimul,aPeriodo)},STR0151}) //"Nova"
Endif	

DEFINE MSDIALOG oDlg TITLE STR0147 From 9,0 To 28,80 OF oMainWnd //"Fluxo de Caixa - Simulação"
oGet := MSGetDados():New(12,2,140,315,3,"Fc021LinOk",,,.T.,{"_SI_DATA","_SI_TIPO","_SI_VALOR","_SI_HISTOR"})
// Utilizada pela LinhaOk, para nao ter que criar uma Private de aPeriodo
oGet:oBrowse:Cargo := aPeriodo 
oGet:oBrowse:lHScroll := .F.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
														 {||nOpca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca := 0)},;
														 {||nOpca:=0,oDlg:End()},,;
														 aButSimul) CENTER

If nOpca == 1
	For nX := 1 To Len(aCols)
		// Se a linha nao estiver deletada
		If !aCols[nX][Len(aCols[nX])] .And. !Empty(aCols[nX][3])
			// Pesquisa a Data da Simulacao
			nIndPer := Ascan(aPeriodo,{|e| e[1] == aCols[nX][1]})
			If nIndPer > 0
				nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPer][2] $ e[DATAFLUXO]})
				If aCols[nX][2] == "R"
					aFluxo[nAscan][ENTRADAS] += aCols[nX][3]
				Else
					aFluxo[nAscan][SAIDAS]   += aCols[nX][3]
				Endif	
			Endif	
		EndIf
	Next
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula o saldo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar)
	oFluxo:Refresh()
Else
	LimpaAcols()
Endif

// Restaura ambiente
RestArea(aArea)
aHeader := aClone(aOldHeader)
		
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021LinOkºAutor  ³Claudio D. de Souza º Data ³  11/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a linha da GetDados da Simulacao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Fc021LinOk(oGetDad)
Local lRet := .F.

Do Case
Case !aCols[n][Len(aCols[1])] .And. (Empty(aCols[n][1]) .Or. aCols[n][1] < dDataBase)
	ApMsgAlert(STR0148 + DTOC(dDataBase)) //"E necessario informar uma data maior ou igual a "
Case !aCols[n][Len(aCols[1])] .And. !aCols[n][2] $ "RD"
	ApMsgAlert(STR0149)	 //"E necessario informar um tipo válido de simulação (R=Receita ou D=Despesa)"
Case !aCols[n][Len(aCols[1])] .And. aCols[n][3] <= 0
	ApMsgAlert(STR0150) //"E necessario informar um valor maior que zero"
Case !aCols[n][Len(aCols[1])] .And. (Ascan(oGetDad:Cargo,	{|e| e[1] == aCols[n][1]}) == 0)
	ApMsgAlert(STR0183 + DTOC(oGetDad:Cargo[Len(oGetDad:Cargo)][1])) //"E necessario informar uma data menor ou igual a "
OtherWise
	lRet := .T.
EndCase
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021GrvSim³ Autor ³ Claudio D. de Souza  ³ Data ³ 11/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Salva 	simula‡äes em disco. 				       		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021GrvSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda)
LOCAL oDlg
LOCAL oText
LOCAL cArquivo := space(8)
LOCAL nX := 0
LOCAL nHdl	:= 0
LOCAL cDate := SET(_SET_DATEFORMAT)

If !Empty(aCols[1,3])

	cArquivo := cGetFile(STR0152, STR0153) //"Simulação | *.SIM"###"Informe o arquivo de simulação"
	
	If !Empty( cArquivo ) .and. Left( Alltrim( cArquivo ) ,1) # "*"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Verifica se o arquivo j  existe e pergunta se   ³
		//³	quer sobrepor. 										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArquivo := Alltrim( cArquivo )
	
		If Upper(Right(cArquivo,4)) # ".SIM"
			cArquivo += ".SIM"
		Endif
	
		IF File(cArquivo)
			IF !MsgYesNo( STR0154 + cArquivo + "?" , STR0155 ) //"Sobregrava "###"Arquivo J  Existe !" //"Sobregravar "###"Arquivo já existe!"
				Return Nil
			Endif
		Endif
		nHdl:=fCreate(cArquivo)
		If nHdl == -1
			ApMsgAlert(STR0156 + Str(fError(),2)) //"Erro na criação do arquivo - Erro DOS Nº"
		Else	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ao se gravar o arquivo de simula‡Æo, desligo a op‡Æo de ano³
			//³	com 4 digitos para que uma simula‡Æo possa ser restaurada³
			//³	por qualquer usu rio, utilizando ele 2 ou 4 digitos/ano  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SET(_SET_DATEFORMAT, "DD/MM/YY")
			For nX := 1 to Len( aCols )
				If !aCols[nX][Len(aCols[1])] // Se a Linha nao estiver deletada
					cCampo := dtoc(acols[nX,1]) + Str(aCols[nX,3],10,2) + ;
								 aCols[nX,2] + aCols[nX,4] + Str(nMoeda,1,0)
					fWrite( nHdl,cCampo,Len(cCampo) )
				Endif	
			Next
			fClose(nHdl)
			SET(_SET_DATEFORMAT,cDate)
		Endif	
	Endif
Endif
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021RstSim³ Autor ³ Claudio D. de Souza  ³ Data ³ 11/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Restaura 	simula‡äes do disco. 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021RstSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,;
									 nMoeda,lGravado,nDias,aPeriodo)
Local cFile 	:= ""
Local cArquivo := ""
Local nElemen  := 0
Local xBuffer  := ""
Local nX 		:= 0
Local nY  		:= 0
Local dData 	:= Ctod("")
Local nValor	:= 0
Local cTipo 	:= ""
Local cHistor  := ""

cFile := cGetFile(STR0152, STR0157) //"Simulação | *.SIM"###"Selecione o arquivo de simulação"
If !Empty(cFile) .and. File( cFile )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Se j  houver uma simula‡…o em mem¢ria, pergunta se ³
	//³  haver  sobreposi‡Æo.									     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Empty(aCols[1,3])
		IF MsgYesNo( STR0158, STR0159) //"Salva simulação existente"###"Existe simulação"
			Fc021GrvSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,nMoeda)
		Endif
		If lGravado
			For nX := 1 to Len(aCols)
				If !aCols[nX][Len(aCols[1])] // Se a linha nao estiver deletada
					For nY := 1 to Len(aPeriodo)
						If aPeriodo[nY,1] == aCols[nX,1]
							IF Left(aCols[nX,2],1) == "D"
								aFluxo[nY][SAIDAS]   -= aCols[nX,3]
							Else
								aFluxo[nY][ENTRADAS] -= aCols[nX,3]
							EndIf
						Endif
					Next
				Endif	
			Next
		Endif	
	Endif
	LimpaAcols()
	nHdl:=fOpen(cFile,0+64)
	nLidos:=0
	fSeek(nHdl,0,0)
	nTamArq:=fSeek(nHdl,0,2)
	FSEEK(nHdl,0,0)
	While nLidos < nTamArq
		xBuffer:=Space(60)
		fRead(nHdl,@xBuffer,60)
		dData 	:= ctod( Subst( xBuffer,01,08),"ddmmyy" )
		nValor	:= val( Subst( xBuffer,09,09) )
		cTipo 	:= Subst( xBuffer,19,01 )
		cHistor  := Subst( xBuffer,20,40 )
		cSimMoeda:= Subst( xBuffer,60,01 )

		If (dData >= dDataBase .And. dData <= dDataBase+nDias-1)
			If Len(aCols) == 1
				If Empty(aCols[1,3])
					nPointer := 1
				Else
					LimpaACols(.F.)
					nPointer := 2
				Endif
			Else
				LimpaACols(.F.)
				nPointer := Len(aCols)
			Endif
			aCols[nPointer,1] := dData
			aCols[nPointer,2] := cTipo
			aCols[nPointer,3] := xMoeda(nValor,Int(Val(cSimMoeda)),nMoeda)
			aCols[nPointer,4] := cHistor
		EndIf	
		nLidos += 60
	EndDo
	fClose(nHdl)
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula o saldo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar)
	oFluxo:Refresh(.f.)
Endif


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021NovSim³ Autor ³ Claudio D. de Souza  ³ Data ³ 10/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reseta simulacoes da mem¢ria. 				   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021NovSim(aFluxo,oFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar,lGravado)
Local nX    := 0
Local nAscan:= 0
Local nIndPer

If !Empty(aCols[1,3])
	IF MsgYesNo(STR0160,	STR0161) //"Confirma ?"###"Nova Simula‡„o" //"Confirma?"###"Nova Simulação"
		If lGravado
			For nX := 1 to Len(aCols)
				If !aCols[nX][Len(aCols[1])] // Se a linha nao estiver deletada
					nIndPer := Ascan(aPeriodo,{|e| e[1] == aCols[nX][1]})
					If nIndPer > 0
						nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPer][2] $ e[DATAFLUXO]})
						IF aCols[nX][2] == "R"
							aFluxo[nAscan][ENTRADAS] -= aCols[nX][3]
						Else
							aFluxo[nAscan][SAIDAS] -= aCols[nX][3]
						End
					Endif	
				Endif	
			Next
		Endif	
		LimpaAcols()
		CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar)
		oFluxo:Refresh(.f.)
	Endif
Endif	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TemFluxoDat³ Autor ³ Claudio D. de Souza  ³ Data ³ 10/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe dados para a data na matriz de periodos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TemFluxoData(dData, aFluxo)
Local nAscan
	nAscan := Ascan(aFluxo, {|e|e[DATAFLUXO]==dData})
	If nAscan == 0
		Aadd(aFluxo, {dData,0,0,0,0,0,0,0,0,0,0,0})
		nAscan := Len(aFluxo)
	Endif
Return nAscan

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LimpaACols ³ Autor ³ Claudio D. de Souza  ³ Data ³ 10/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa a variavel aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LimpaAcols(lZera)
Local nLenaCols
DEFAULT lZera := .T. // Indica se deve zerar a matriz

	If lZera
		aCols := {}
	Endif	
	Aadd(aCols,Array(Len(aHeader)+1))
	nLenaCols := Len(aCols)
	Aeval(aHeader, { |e,nX|	If(e[8] == "D", aCols[nLenaCols][nX] := dDataBase,;
									If(e[8] == "N", aCols[nLenaCols][nX] := 0       ,;
									If(e[8] == "C" .And. !Empty(e[1])       ,;
								   	aCols[nLenaCols][nX] := Space(e[4])           ,;
										aCols[nLenaCols][nX] := "")))})
	aCols[nLenaCols][Len(aCols[1])] := .F. // Indica que a linha nao esta deletada
	
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fc021ChFol³ Autor ³Claudio D. de Souza    ³ Data ³03.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento dos Folders da consulta analitica Fluxo³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fc021ChFol(nFldDst,nFldAtu,oFolder,oDlg,aTotais,oSayTotal,oGetTotal,;
									nTotal,cPeriodo,aGetDb,aAlias,aHeader1,aHeader2,aHeader3,;
									aHeader4,aHeader5,aHeader6,aHeader7)
Local nCntFor := 0
Local lRetorno:= .T.
Local oBold
Local nAscan

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Se o Folder Destino puder ser exibido, seleciona o arquivo
If aAlias[nFldDst] != Nil .And. Select(aAlias[nFldDst]) > 0
	DbSelectArea(aAlias[nFldDst])
	DbGoTop()
Else
	lRetorno := .F. // Desabilita o Folder
EndIf
If lRetorno
	IF ValType(aGetDb[nFldAtu]) == "O"
		aGetDb[nFldAtu]:oBrowse:lDisablePaint := .T.
	Endif	
	Do Case
		Case ( nFldDst == 1 )
			aHeader := aClone(aHeader1)
			oSayTotal:cCaption := STR0078 //"Total de Titulos a Pagar"
		Case ( nFldDst == 2 )
			aHeader := aClone(aHeader2)
			oSayTotal:cCaption := STR0162 //"Total de Titulos a Receber"
		Case ( nFldDst == 3 )
			aHeader := aClone(aHeader3)
			oSayTotal:cCaption := STR0163 //"Total de Pedidos de Compra"
		Case ( nFldDst == 4 )
			aHeader := aClone(aHeader4)
			oSayTotal:cCaption := STR0164 //"Total de Pedidos de Venda"
		Case ( nFldDst == 5 )
			aHeader := aClone(aHeader5)
			oSayTotal:cCaption := STR0165 //"Total de Comissões"
		Case ( nFldDst == 6 )
			aHeader := aClone(aHeader6)
			oSayTotal:cCaption := STR0166 //"Total de Empréstimos"
		Case ( nFldDst == 7 )
			aHeader := aClone(aHeader7)
			oSayTotal:cCaption := STR0167 //"Total de Aplicações"
	EndCase         
	
	If ( nFldDst <> 2 )
		nTotCheq := 0
		nTotNorm := 0

		@ 282.5, 173   SAY "Total de Cheques " PIXEL OF oDlg FONT oBold
		@ 282.5, 248 MSGET nTotCheq PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold
		
		@ 282.5, 353   SAY "Total de Titulos" PIXEL OF oDlg FONT oBold
		@ 282.5, 427 MSGET nTotNorm PICTURE "@E 999,999,999,999.99" WHEN .F. PIXEL OF oDlg SIZE 60,10 FONT oBold
		
	Else
		nAscan 	:= Ascan( aTotais[2], {|e|Transform(e[1],"") = cPeriodo})
		nTotCheq := 0
		nTotNorm := 0

		If nAscan > 0
			nTotCheq := aTotais[2][nAscan][3]   // VAVA
			nTotNorm := aTotais[2][nAscan][4]
		Endif	
	EndIf
	
	nAscan := Ascan( aTotais[nFldDst], {|e|Transform(e[1],"") = cPeriodo})
	nTotal := 0
	If nAscan > 0
		nTotal := aTotais[nFldDst][nAscan][2]   // VAVA
	Endif	
	oGetTotal:Refresh()
	oSayTotal:Refresh()
	If ValType(aGetDb[nFldDst]) == "O"
		aGetDb[nFldDst]:oBrowse:lDisablePaint := .F.
		aGetDb[nFldDst]:oBrowse:Refresh(.T.)
	Endif	
Endif	
Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc021Bar	³ Autor ³ Claudio D. de Souza   ³ Data ³03.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela - WINDOWS 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fc021Bar(oDlg,bOk,bCancel,oFolder,aGetDb,aTotais,aFluxo,aAliasAna,;
						nBancos,nCaixas,nAtrReceber,nAtrPagar,nTotal,aPeriodo)
Local oBar, bSet15, bSet24, lOk

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0168  //"Calculadora..." //"Calculadora"
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP STR0169  //"Gerenciador de ImpressÆo..." //"Genciador de Impressao"
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar GROUP ACTION HelProg() TOOLTIP STR0170  //"Help de Programa..." //"Help de Programa"
DEFINE BUTTON oBtnEdt RESOURCE "SIMULACAO" OF oBar ACTION If(ValType(aGetDb[oFolder:nOption])=="O" .And. !Empty(DataX),(Fc021Proj(oDlg,aFluxo,aAliasAna,oFolder,aGetDb,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,@nTotal,aPeriodo),aGetDb[oFolder:nOption]:oBrowse:Refresh()), .T.) TOOLTIP STR0171 //"Projeção"
SetKey(5,oBtnEdt:bAction)

DEFINE BUTTON oBtnVisual RESOURCE "ANALITICO" OF oBar ACTION If(ValType(oFolder:aDialogs[oFolder:nOption])=="O" .And.;
																			       ValType(oFolder:aDialogs[oFolder:nOption]:Cargo[2]) == "B", Eval(oFolder:aDialogs[oFolder:nOption]:Cargo[2]), .T.);
		TOOLTIP STR0172   //"Visualizar"

SetKey(16,oBtnVisual:bAction)
oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "OK" OF oBar GROUP ACTION (lLoop:=.F.,lOk:=Eval(bOk)) TOOLTIP "Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( lLoop:=.F.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP STR0173 //"Cancelar - <Ctrl-X>"

SetKEY(24,oBtCan:bAction)
oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}
Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc021Edit ºAutor  ³Claudio D. de Souza º Data ³  04/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite a alteracao da data do credito/debito de um titulo º±±
±±º          ³ simulando a entrada/saida em nova data                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Proj(oDlg,aFluxo,aAliasAna,oFolder,aGetDb,aTotais,nBancos,;
								  nCaixas,nAtrReceber,nAtrPagar,nTotal,aPeriodo)
Local oDlgProj,dNovaData := dDataBase, nOpcA
LOCAL oBold
LOCAL cCarteira := oFolder:aDialogs[oFolder:nOption]:Cargo[1]
LOCAL nCampSin  := If(cCarteira=="R", ENTRADAS, SAIDAS)
LOCAL cAliasAna := aAliasAna[oFolder:nOption]
LOCAL dDataProj := (cAliasAna)->DataX
LOCAL aArea 	 := GetArea()
LOCAL nAscan, nIndPerAtu, nIndPerProj
LOCAL nValor    := (cAliasAna)->Saldo

DEFINE MSDIALOG oDlgProj FROM 0,0 TO 140,304 TITLE STR0174 Of oMainWnd PIXEL  //"Fluxo de Caixa - Projeção"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgProj SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgProj PIXEL
@ 3  ,37  SAY STR0175 Of oDlgProj PIXEL SIZE 35 ,9 FONT oBold //"Projeção de fluxo de caixa"
@ 19,050 SAY STR0026 			  OF oDlgProj PIXEL //"Valor"
@ 19,090 MSGET nValor WHEN .F. OF oDlgProj SIZE 60,9 PIXEL PICTURE "@E 999,999,999.99"
@ 29,050 SAY STR0184 		  OF oDlgProj PIXEL //"Data Atual"
@ 29,110 MSGET DataX WHEN .F.  OF oDlgProj SIZE 40,9 PIXEL
@ 39,050 SAY STR0176 	  OF oDlgProj PIXEL //"Projetar Para"
@ 39,110 MSGET dDataProj		  OF oDlgProj SIZE 40,9 PIXEL VALID dDataProj != DataX

DEFINE SBUTTON FROM 55,52 TYPE 1 ENABLE OF oDlgProj ACTION (nOpcA := 1, oDlgProj:End())
DEFINE SBUTTON FROM 55,90 TYPE 2 ENABLE OF oDlgProj ACTION (nOpcA := 0, oDlgProj:End())

ACTIVATE MSDIALOG oDlgProj CENTERED

If nOpcA == 1
	// Pesquisa a data na matriz de referencia de periodos para localizar o fluxo pelo periodo
	// e nao pela data, se projetou para uma data dentro do periodo do Fluxo, atualiza as
	// informacoes na matriz de Fluxo, Totais e no arquivo temporario de fluxo analitico
	nIndPerAtu := Ascan(aPeriodo, {|e| e[1] == DataX})
	nIndPerProj:= Ascan(aPeriodo, {|e| e[1] == dDataProj})
	If nIndPerAtu > 0 .And. nIndPerProj > 0
		aGetDb[oFolder:nOption]:oBrowse:lDisablePaint := .T.
		// Subtrai da data atual
		nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPerAtu][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aFluxo[nAscan][nCampSin] -= nValor
		Endif	
		// Subtrai a matriz de totais do fluxo analitico tambem
		nAscan := Ascan(aTotais[oFolder:nOption], {|e|aPeriodo[nIndPerAtu][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aTotais[oFolder:nOption][nAscan][2] -= nValor
			nTotal -= nValor
		Endif
		// Transfere o valor para a nova data
		nAscan := Ascan(aFluxo,	{|e| aPeriodo[nIndPerProj][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aFluxo[nAscan][nCampSin] += nValor
		Endif	
		nAscan := Ascan( aTotais[oFolder:nOption], {|e|aPeriodo[nIndPerAtu][2] $ e[DATAFLUXO]})
		If nAscan > 0
			aTotais[oFolder:nOption][nAscan][2] += nValor
		Endif
		DbSelectArea(cAliasAna)
		nOrder := IndexOrd()
		DbSetOrder(0)
		RecLock(cAliasAna, .F.)
		// Transfere o fluxo analitico para o novo periodo/Data
		(cAliasAna)->DataX   := dDataProj				 
		(cAliasAna)->Periodo := aPeriodo[nIndPerProj][2]
		MsUnlock()
		DbSetOrder(nOrder)
		CalcSaldo(aFluxo,nBancos,nCaixas,nAtrReceber,nAtrPagar)
		aGetDb[oFolder:nOption]:oBrowse:lDisablePaint := .F.
		aGetDb[oFolder:nOption]:ForceRefresh()
	Else
		ApMsgAlert(STR0185) //"Nao eh possivel projetar para uma data fora do periodo do fluxo de caixa"
	Endif
	/*
	If oDlg != Nil
   	aEval(oDlg:aControls, {|e| If(ValType(e) == "O", e:Refresh(), Nil) } )
	Endif
	*/
Endif
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaTmpAnaºAutor  ³Claudio D. de Souza º Data ³  08/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criar os arquivos analiticos do Fluxo de Caixa             º±±
±±º          ³ Parametro:                                                 º±±
±±º          ³ nArquivo   Numero do arquivo que sera criado               º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet                                                       º±±
±±º          ³ aRet[1] - Alias do arquivo temporario							  º±±
±±º          ³ aRet[2] - Nome do arquivo temporario                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION CriaTmpAna(nArquivo)
LOCAL aCposAna,;
		cAliasAna,;
		cArqAna
Do Case
Case nArquivo == 1 // Emprestimos
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C",  15, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EH_NUMERO")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EH_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EH_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EH_CONTA")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EH_SALDO")[1], TamSx3("EH_SALDO")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
		
	cAliasAna := "cArqAnaEmp"  // Alias do arquivo analitico
Case nArquivo == 2 // Aplicacoes
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C",  15, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EH_NUMERO")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EH_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EH_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EH_CONTA")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EH_SALDO")[1], TamSx3("EH_SALDO")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
		
	cAliasAna := "cArqAnaApl"  // Alias do arquivo analitico
Case nArquivo == 3 // Pedidos de compras
	aCposAna := {}
	Aadd( aCposAna, { "Periodo", "C",  15, 0 } )
	Aadd( aCposAna, { "DATAX"  , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO" , "C", TamSx3("C7_NUM")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO", "D",  8, 0 } )
	Aadd( aCposAna, { "CLIFOR" , "C", TamSx3("E5_CLIFOR")[1], 0 } )
	Aadd( aCposAna, { "TIPO"   , "N", TamSx3("C7_TIPO")[1], 0 } )
	Aadd( aCposAna, { "ITEM"   , "C", TamSx3("C7_ITEM")[1], 0 } )
	Aadd( aCposAna, { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
	Aadd( aCposAna, { "PRODUTO", "C", TamSx3("C7_PRODUTO")[1], 0 } )
	Aadd( aCposAna, { "SALDO"  , "N", Max(TamSx3("E1_SALDO")[1]  ,;
				 					            	TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "CHAVE"  , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido", "C", 10, 0 } )
	cAliasAna := "cArqAnaPc"  // Alias do arquivo analitico
Case nArquivo == 4 // Pedidos de vendas
	aCposAna := {}
	Aadd( aCposAna, { "Periodo", "C",  15, 0 } )
	Aadd( aCposAna, { "DATAX"  , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO" , "C", TamSx3("C5_NUM")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO", "D",  8, 0 } )
	Aadd( aCposAna, { "CLIFOR" , "C", TamSx3("E5_CLIFOR")[1], 0 } )
	Aadd( aCposAna, { "TIPO"   , "C", TamSx3("C5_TIPO")[1], 0 } )
	Aadd( aCposAna, { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
	Aadd( aCposAna, { "LOJAENT", "C", TamSx3("C5_LOJAENT")[1], 0 } )
	Aadd( aCposAna, { "LOJACLI", "C", TamSx3("C5_LOJAENT")[1], 0 } )
	Aadd( aCposAna, { "SALDO"  , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "CHAVE"  , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido", "C", 10, 0 } )
		
	cAliasAna := "cArqAnaPv"  // Alias do arquivo analitico
	
EndCase			
Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera arquivo de Trabalho      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqAna := CriaTrab(aCposAna,.T.) // Nome do arquivo temporario
dbUseArea(.T.,__LocalDriver,cArqAna,cAliasAna,.F.)
IndRegua ( cAliasAna,cArqAna,"Dtos(DataX)",,,STR0054) //"Selecionando Registros..."
		   
Return {cAliasAna,cArqAna}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fc021Tipo ºAutor  ³Wagner Mobile Costa º Data ³  06/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se o tipo indicado na simulacao eh Receita/Despesa  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Tipo

Local lRet := .T.

If ! M->_SI_TIPO $ "RD"
	ApMsgAlert(STR0149) //"E necessario informar um tipo válido de simulação (R=Receita ou D=Despesa)"
	lRet := .F.	
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fc021Filtro³ Autor ³ Claudio D. de Souza  ³ Data ³ 18/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem o filtro do usuario para os dados do SE1 e do SE2.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	    ³ FINC021																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc021Filtro(cFilterSe1,cFilterSe2)
Local nOpc := 1
Local oDLg, cAlias

DEFINE MSDIALOG oDlg FROM 90,11 TO 260,321 TITLE STR0189 PIXEL

@ 10,13 TO 53, 142 LABEL STR0190 OF oDlg	PIXEL
@ 24,27 RADIO nOpc PROMPT STR0191,STR0192 SIZE  60,9 OF oDlg PIXEL

DEFINE SBUTTON FROM 60, 85 TYPE 1 ENABLE OF oDlg ACTION (cAlias := If(nOpc=1,"SE1","SE2"), dbSelectArea(cAlias), If(nOpc=1,cFilterSe1,cFilterSe2) := BuildExpr(cAlias,oDlg ),oDlg:End())
DEFINE SBUTTON FROM 60,115 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg

Return nil

Static Function CalcAtraso(cAliasTrb,cCampo,aFluxo,nSaldo,cAlias,lAnalitico,MVABATIM,aPeriodo,aTotais)
	
	cAliasAna  := If(cAlias=="SE1","cArqAnaR","cArqAnaP")
	cTipo     := If(Upper(cAlias)=="SE1", MVRECANT+"/"+MV_CRNEG, MVPAGANT+"/"+MV_CPNEG)
	
	dDataTrab := DataValida((cAliasTrb)->&(cCampo+"_VENCREA"),.T.)
	nAscan := TemFluxoData(dDataTrab,aFluxo)
	
	If cAlias == "SE1"
		aFluxo[nAscan][ATRASOARECEBER] += nSaldo
	ElseIf cAlias == "SE2"	
		aFluxo[nAscan][ATRASOAPAGAR] += nSaldo				
	EndIf

	If Alltrim((cAliasTrb)->&(cCampo+"_TIPO")) == "CH"
		aFluxo[nAscan][CHEQUESRECEBER] += nSaldo
	EndIf							
			
	If lAnalitico .And. !(cAliasTrb)->&(cCampo+"_TIPO") $ MVABATIM // Analitico
		cCliFor := (cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))
		// Posiciona no cliente ou fornecedor para buscar o nome
		DbSelectArea(StrTran(cAlias,"E","A"))
		DbSetOrder(1)
		MsSeek(xFilial(StrTran(cAlias,"E","A"))+cCliFor+(cAliasTrb)->&(cCampo+"_LOJA"))
		DbSelectArea(cAliasTrb)
		RecLock(cAliasAna,.T.)
		nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
		(cAliasAna)->DataX   := dDataTrab
		(cAliasAna)->Periodo := Dtoc(dDataTrab)
		(cAliasAna)->PREFIXO := (cAliasTrb)->&(cCampo+"_PREFIXO")
		(cAliasAna)->NUM     := (cAliasTrb)->&(cCampo+"_NUM")
		(cAliasAna)->PARCELA := (cAliasTrb)->&(cCampo+"_PARCELA")
		(cAliasAna)->TIPO    := (cAliasTrb)->&(cCampo+"_TIPO")
		(cAliasAna)->CLIFOR  := cCliFor
		(cAliasAna)->NOMCLIFOR := (StrTran(cAlias,"E","A"))->&(Right(StrTran(cAlias,"E","A"),2)+"_NOME")
		(cAliasAna)->LOJA    := (cAliasTrb)->&(cCampo+"_LOJA")
		cIdentific :=	xFilial(cAlias)+;
						(cAliasTrb)->&(cCampo+"_PREFIXO") +;
						(cAliasTrb)->&(cCampo+"_NUM")     +;
						(cAliasTrb)->&(cCampo+"_PARCELA") +;
						(cAliasTrb)->&(cCampo+"_TIPO")    +;
						(cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))+;
						(cAliasTrb)->&(cCampo+"_LOJA")
		(cAliasAna)->Chave      := cIdentific
		(cAliasAna)->Apelido    := cAlias
		(cAliasAna)->SALDO      := nSaldo
		MsUnlock()
		// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
		// da data de trabalho.

		nAscan := Ascan( aTotais[If(cAlias=="SE1",2,1)], {|e| e[1] == dDataTrab})
		nTotCheq := 0
		nTotNorm := 0
		
		If Alltrim((cAliasTrb)->&(cCampo+"_TIPO")) == "CH"
			nTotCheq := (cAliasAna)->SALDO
		Else 
			nTotNorm := (cAliasAna)->SALDO
		EndIf	
		
		If nAscan == 0 
			Aadd( aTotais[If(cAlias=="SE1",2,1)], {dDataTrab,(cAliasAna)->SALDO,nTotCheq,nTotNorm})
		Else	
			If (cAliasTrb)->&(cCampo+"_TIPO") $ cTipo
				aTotais[If(cAlias=="SE1",2,1)][nAscan][2] -= (cAliasAna)->SALDO // Contabiliza os totais de titulos 
				aTotais[If(cAlias=="SE1",2,1)][nAscan][3] -= nTotCheq  
				aTotais[If(cAlias=="SE1",2,1)][nAscan][4] -= nTotNorm								
			Else
				aTotais[If(cAlias=="SE1",2,1)][nAscan][2] += (cAliasAna)->SALDO // Contabiliza os totais de titulos 
				aTotais[If(cAlias=="SE1",2,1)][nAscan][3] += nTotCheq  
				aTotais[If(cAlias=="SE1",2,1)][nAscan][4] += nTotNorm
			EndIf
		Endif	

	Endif				

Return