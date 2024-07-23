#INCLUDE 'MATR425.CH'
#INCLUDE 'PROTHEUS.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR425  ³ Autor ³Alexandre Inacio Lemes ³ Data ³26/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Estoque por Lote                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR425(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AGX446()
	MATR425R3()
Return

Static Function MATR425R3()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1     := OemToAnsi(STR0001) //"Este programa emitira' uma relacao com a posi‡„o de "
Local cDesc2     := OemToAnsi(STR0002)	//"estoque por Lote/Sub-Lote."
Local cDesc3     := ''
Local cString    := 'SB8'
Local Titulo	  := OemToAnsi(STR0003)	//"Posicao de Estoque por Lote/Sub-Lote"
Local Tamanho    := 'M'
Local wnRel      := 'MATR425'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aOrd       := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0018), 'Por Data de Validade'}	//" Por Produto"###" Por Lote/Sub-Lote"###" Por Armazem"
Private aReturn    := {OemToAnsi(STR0006),1,OemToAnsi(STR0007), 1, 2, 1, '',1 }	//"Zebrado"###"Administracao"
Private cPerg      := 'MR425A'
Private nLastKey   := 0
Private nTipo      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a Pergunta Nova no Sx1                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte('MR425A', .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01        	// Do  Produto                          ³
//³ mv_par02        	// Ate Produto                          ³
//³ mv_par03        	// De  Lote                             ³
//³ mv_par04        	// Ate Lote			         		    ³
//³ mv_par05        	// De  Sub-Lote                         ³
//³ mv_par06        	// Ate Sub-Lote			         	  	³
//³ mv_par07        	// De  Local			        	    ³
//³ mv_par08        	// Ate Local				            ³
//³ mv_par09        	// Lista Saldo Zerado ? Lista/Nao Lista ³
//³ mv_par10        	// Do Tipo  				            ³
//³ mv_par11        	// Ate o Tipo  			                ³
//³ mv_par12        	// Do Grupo 				            ³
//³ mv_par13        	// Ate o Grupo		                    ³
//³ mv_par14        	// QTDE na 2a.U.M. ?	                ³
//| mv_par15			// Imprime descricao do Armazem ?       |
//| mv_par16			// Da Data de Validade ?	 		    |
//| mv_par17			// Ate a Data de Validade ? 			|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnRel := SetPrint(cString,wnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)
nTipo := If(aReturn[4]==1,GetMv('MV_COMP'),GetMv('MV_NORM'))

If mv_par14==1 .Or. mv_par15==1  //Aumentar relatorio quando for 2a. U.M. ou quando imprimir descricao do armazem
    Tamanho :="G"
EndIf    

If nLastKey == 27
	dbClearFilter()
	Return Nil
EndIf
SetDefault(aReturn,cString)
If nLastKey == 27
	dbClearFilter()
	Return Nil
EndIf

RptStatus({|lEnd| C425Imp(@lEnd,wnRel,Tamanho,Titulo)},Titulo)

Return Nil

Static Function C425Imp(lEnd, wnRel, Tamanho, Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis especificas do Relatorio                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cIndex     := ''
Local cCond      := ''
Local cLoteAnt   := ''
Local cProdAnt   := ''
Local cDescAnt   := ''
Local cSLotAnt   := ''
Local cAlmoAnt   := ''
Local cSeekSB8   := ''
Local cCondSB8   := ''
Local dDtValid   := ''
Local cNomArq    := ''
Local cDescArm   := ''
Local cPicSld    := PesqPict('SB8', 'B8_SALDO',18)
Local cPicEmp    := PesqPict('SB8', 'B8_EMPENHO',18)
Local dDataAnt   := CtoD('  /  /  ')
Local dValiAnt   := CtoD('  /  /  ')
Local nSaldo     := 0
Local nEmpenho   := 0
Local nSaldoT    := 0
Local nEmpenhoT  := 0
Local nSaldo2    := 0
Local nEmpenho2  := 0
Local nSaldoT2   := 0
Local nEmpenhoT2 := 0
Local nCntImpr   := 0
Local nIndSB8    := 0
Local lSubLote   := .F.
Local lEmpPrev   := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aLinha    := {}
Private Cabec1    := ''
Private Cabec2    := ''
Private cBTxt     := Space(10)
Private cBCont    := 0
Private Li        := 80
Private M_PAG     := 01

//-- Condi‡Æo de Filtragem da IndRegua
cCond := 'B8_FILIAL=="'+xFilial('SB8')+'".And.'
cCond += 'B8_PRODUTO>="'+mv_par01+'".And.B8_PRODUTO<="'+mv_par02+'".And.'
cCond += 'B8_LOTECTL>="'+mv_par03+'".And.B8_LOTECTL<="'+mv_par04+'".And.'
cCond += 'B8_NUMLOTE>="'+mv_par05+'".And.B8_NUMLOTE<="'+mv_par06+'".And.'
cCond += 'B8_LOCAL>="'+mv_par07+'".And.B8_LOCAL<="'+mv_par08+'".And.'
cCond += 'DTOS(B8_DTVALID)>= "'+DTOS(mv_par16)+'".And. DTOS(B8_DTVALID)<= "'+DTOS(mv_par17)+'"'

If aReturn[8]==1
	cIndex := 'B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE'
	Titulo := OemToAnsi(STR0008)	//"POSICAO DE ESTOQUE POR LOTE/SUBLOTE (POR PRODUTO)"
    If mv_par14==1
       Cabec1 := OemToAnsi(STR0020)	//"PRODUTO         DESCRICAO                     SUB-LOTE     LOTE    ARMZ    SALDO           EMPENHO           SALDO 2a.UM       EMPENHO 2a.UM          DATA      DATA   "		
       Cabec2 := OemToAnsi(STR0021)	//"    VALIDADE "
    Else
	   Cabec1 := OemToAnsi(STR0009)	//"PRODUTO         DESCRICAO                     SUB-LOTE     LOTE    ARMZ      SALDO       EMPENHO       DATA       DATA   "
       Cabec2 := OemToAnsi(STR0014)	//"    VALIDADE "
    EndIf
ElseIf aReturn[8] == 2
	cIndex := 'B8_FILIAL+B8_LOTECTL+B8_NUMLOTE+B8_PRODUTO+B8_LOCAL'
	Titulo := OemToAnsi(STR0010)	//"POSICAO DE ESTOQUE POR LOTE/SUB-LOTE (POR LOTE)"
    If mv_par14 == 1
	   Cabec1 := OemToAnsi(STR0022)	//"SUB-LOTE  LOTE    PRODUTO         DESCRICAO                      AL    SALDO       EMPENHO       DATA       DATA   "
	   Cabec2 := OemToAnsi(STR0021)	//"                                                                                                          VALIDADE "
    Else
	   Cabec1 := OemToAnsi(STR0011)	//"SUB-LOTE  LOTE    PRODUTO         DESCRICAO                      AL    SALDO       EMPENHO       DATA       DATA   "
	   Cabec2 := OemToAnsi(STR0014)	//"                                                                                                          VALIDADE "
	Endif   
ElseIf aReturn[8] == 3
	cIndex := 'B8_FILIAL+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+B8_PRODUTO'
	Titulo := OemToAnsi(STR0019)	//"POSICAO DE ESTOQUE POR LOTE/SUB-LOTE (POR ARMAZEM)"
    If mv_par14 == 1
       Cabec1 := OemToAnsi(STR0020)	//"PRODUTO         DESCRICAO                     SUB-LOTE     LOTE    ARMZ    SALDO           EMPENHO           SALDO 2a.UM       EMPENHO 2a.UM          DATA      DATA   "		
       Cabec2 := OemToAnsi(STR0021)	//"    VALIDADE "
    Else
	   Cabec1 := OemToAnsi(STR0009)	//"PRODUTO         DESCRICAO                     SUB-LOTE     LOTE    ARMZ      SALDO       EMPENHO       DATA       DATA   "
	   Cabec2 := OemToAnsi(STR0014)	//"                                                                                                                  VALIDADE "
	Endif
ElseIf aReturn[8] == 4
	cIndex := 'B8_FILIAL+B8_DTVALID+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE'
	Titulo := OemToAnsi("POSICAO DE ESTOQUE POR LOTE/SUBLOTE (POR DATA DE VALIDADE)")	
    If mv_par14==1
       Cabec1 := OemToAnsi(STR0020)	//"PRODUTO         DESCRICAO                     SUB-LOTE     LOTE    ARMZ    SALDO           EMPENHO           SALDO 2a.UM       EMPENHO 2a.UM          DATA      DATA   "		
       Cabec2 := OemToAnsi(STR0021)	//"    VALIDADE "
    Else
	   Cabec1 := OemToAnsi(STR0009)	//"PRODUTO         DESCRICAO                     SUB-LOTE     LOTE    ARMZ      SALDO       EMPENHO       DATA       DATA   "
       Cabec2 := OemToAnsi(STR0014)	//"    VALIDADE "
    EndIf
EndIf
If mv_par15 == 1
	Cabec1 += OemToAnsi(STR0023)	//"    DESCR. ARMAZ."
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o nome do arquivo de indice de trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := CriaTrab('', .F.)

//-- Seta a Ordem Correta no Arquivo SB1
dbSelectArea('SB1')
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB8')
IndRegua('SB8', cNomArq, cIndex,, cCond, STR0017) //"Selecionando Registros..."
#IFNDEF TOP
	dbSetIndex(cNomArq+OrdBagExt())
#ENDIF
dbGoTop()
SetRegua(LastRec())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa o La‡o para ImpressÆo                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While !Eof()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cancela a ImpressÆo                                	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		@ PRow()+1, 001 PSay OemToAnsi(STR0012)	//"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	lSubLote := Rastro(B8_PRODUTO,'S')

	dDtValid := ''

	//-- Define a Quebra por Produto ou Lote
	If aReturn[8] == 1
		cSeekSB8 := B8_FILIAL+B8_PRODUTO+B8_LOCAL
		cCondSB8 := 'B8_FILIAL+B8_PRODUTO+B8_LOCAL'
	ElseIf aReturn[8] == 2
		cSeekSB8 := B8_FILIAL+B8_LOTECTL+If(lSubLote,B8_NUMLOTE,'')+B8_PRODUTO+B8_LOCAL
		cCondSB8 := 'B8_FILIAL+B8_LOTECTL+'+If(lSubLote,'B8_NUMLOTE+','')+'B8_PRODUTO+B8_LOCAL'
	ElseIf aReturn[8] == 3
		cSeekSB8 := B8_FILIAL+B8_LOCAL+B8_PRODUTO
		cCondSB8 := 'B8_FILIAL+B8_LOCAL+B8_PRODUTO'
	ElseIf aReturn[8] == 4
		cSeekSB8 := B8_FILIAL+B8_PRODUTO+B8_LOCAL
		cCondSB8 := 'B8_FILIAL+B8_PRODUTO+B8_LOCAL'
		dDtValid := DTOS(B8_DTVALID)
	EndIf

	nSaldo    := 0
	nEmpenho  := 0
	nSaldoT   := 0
	nEmpenhoT := 0
	nSaldo2   := 0
	nEmpenho2 := 0
	nSaldoT2  := 0
	nEmpenhoT2:= 0

	//-- Processa o La‡o da Quebra
	Do While !Eof() .And. If(aReturn[8] <> 4,cSeekSB8 == &(cCondSB8), dDtValid == DTOS(B8_DTVALID))

		//-- Atualiza a Regua de ImpressÆo
		IncRegua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancela a ImpressÆo                                	         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnd
			@ PRow()+1, 001 PSay OemToAnsi(STR0012)	//"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		
		//-- Posiciona-se na Descri‡Æo Correta do SB1
		If !(cProdAnt==B8_PRODUTO)
			SB1->(dbSeek(xFilial('SB1')+SB8->B8_PRODUTO, .F.))
		EndIf	
		
		If SB1->B1_TIPO < mv_par10 .Or. SB1->B1_TIPO > mv_par11
			dbSkip()
			Loop
		EndIf
		
		If SB1->B1_GRUPO < mv_par12 .Or. SB1->B1_GRUPO > mv_par13
			dbSkip()
			Loop
		EndIf

		//-- Saldo do Lote ou Lote/Sublote
		nSaldo   += SB8SALDO(,,,,,lEmpPrev,,,.T.)
		nEmpenho += SB8SALDO(.T.,,,,,lEmpPrev,,,.T.)
		nSaldo2  += SB8SALDO(,,,.T.,,lEmpPrev,,,.T.) // Quando passado .T. no 4o. Parametro a funcao retorna a 2a. UM.
		nEmpenho2+= SB8SALDO(.T.,,,.T.,,lEmpPrev,,,.T.)
		
		//-- Saldo Total da Quebra
		nSaldoT   += SB8SALDO(,,,,,lEmpPrev,,,.T.)
		nEmpenhoT += SB8SALDO(.T.,,,,,lEmpPrev,,,.T.)
		nSaldoT2  += SB8SALDO(,,,.T.,,lEmpPrev,,,.T.)
		nEmpenhoT2+= SB8SALDO(.T.,,,.T.,,lEmpPrev,,,.T.)
				
		//-- Salva Dados do Registro Atual / Passa para o Pr¢ximo Registro
		cProdAnt := B8_PRODUTO
		cDescAnt := SubS(SB1->B1_DESC,1,30)
		cSLotAnt := If(lSubLote,B8_NUMLOTE,Space(Len(B8_NUMLOTE)))
		cLoteAnt := B8_LOTECTL
		cAlmoAnt := B8_LOCAL
		dDataAnt := B8_DATA
		dValiAnt := B8_DTVALID

		If mv_par15 == 1
			If SB2->(MsSeek(xFilial("SB2")+cProdAnt+cAlmoAnt)) .And. !Empty(SB2->B2_LOCALIZ)
				cDescArm := SB2->B2_LOCALIZ
			Else
				cDescArm := ""
			EndIf
		EndIf	
		dbSkip()
		
		//-- Imprime Saldo do Lote ou Lote/Sublote
		If !(cSeekSB8==&(cCondSB8)) .Or. lSubLote .Or. !(cLoteAnt==B8_LOTECTL)
			
			//-- Verifica se Lista Saldo Zerado
			If mv_par09==2 .And. QtdComp(nSaldo)==QtdComp(0)
				Loop
			EndIf
			If Li > 58
				Cabec(Titulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
			EndIf
			nCntImpr ++
			If aReturn[8] == 1 .Or. aReturn[8] == 3 .Or. aReturn[8] == 4
				@ Li, 000 PSay cProdAnt
				@ Li, 016 PSay cDescAnt
				@ Li, 049 PSay cSLotAnt
				@ Li, 056 PSay cLoteAnt
			ElseIf aReturn[8] == 2
				@ Li, 000 PSay cSLotAnt
				@ Li, 007 PSay cLoteAnt
				@ Li, 018 PSay cProdAnt
				@ Li, 034 PSay cDescAnt
			EndIf
			@ Li, 068 PSay cAlmoAnt
			@ Li, 072 PSay nSaldo   Picture cPicSld
			@ Li, 092 PSay nEmpenho Picture cPicEmp
			
			If mv_par14==1
			   @ Li, 112 PSay nSaldo2   Picture cPicSld			   
			   @ Li, 132 PSay nEmpenho2 Picture cPicEmp
  			   @ Li, 152 Psay dDataAnt
			   @ Li, 162 Psay dValiAnt
			   If mv_par15==1
			       @ Li, 172 Psay cDescArm
			   EndIf
			Else
			   @ Li, 112 Psay dDataAnt
			   @ Li, 122 Psay dValiAnt
  			   If mv_par15==1
			       @ Li, 132 Psay cDescArm
			   EndIf    
			EndIf
			Li ++
			nSaldo   := 0
			nEmpenho := 0
			nSaldo2  := 0
			nEmpenho2:= 0
		EndIf
	EndDo
	
	//-- Imprime Saldo Total da Quebra
	If nCntImpr > 0
		If Li > 58
			Cabec(Titulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
		EndIf

		if aReturn[8] == 4
			@ Li, 000 PSay "Total da Data de Validade ->"
		Else
			@ Li, 000 PSay If(aReturn[8]==1,STR0013,If(lSubLote,STR0016,STR0015)) //"Total do Produto ->"###"Total do Lote ->"###'Total do Lote/SubLote ->'
		EndIf

		@ Li, 072 PSay nSaldoT   Picture cPicSld
		@ Li, 092 PSay nEmpenhoT Picture cPicEmp
		
		If mv_par14==1
           @ Li, 112 PSay nSaldoT2   Picture cPicSld
		   @ Li, 132 PSay nEmpenhoT2 Picture cPicEmp		
		EndIf
		
		Li++
		@ Li, 000 PSay __PrtThinLine()
		Li++
		nCntImpr  := 0
		nSaldoT   := 0
		nEmpenhoT := 0
		nSaldoT2  := 0
		nEmpenhoT2:= 0
	EndIf
EndDo

If !(Li==80)
	Roda(cBCont,cBTxt,Tamanho)
EndIf

//-- Restaura a Integridade do SB8
dbSelectArea('SB8')
RetIndex('SB8')
dbClearFilter()
If File(cNomArq+OrdBagExt())
	fErase(cNomArq+OrdBagExt())
EndIf

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnRel)
EndIf
MS_Flush()
        
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³ Nereu Humberto Junior ³ Data ³23.11.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as perguntas necesarias para o programa                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

Local aHelpPor :={} 
Local aHelpEng :={} 
Local aHelpSpa :={} 

/*-----------------------MV_PAR14--------------------------*/
PutSx1("MR425A","14","QTDE. na 2a. U.M. ?","CTD. EN 2a. U.M. ?","QTTY. in 2a. U.M. ?", "mv_che", "N", 1, 0, 2,"C", "", "", "", "","MV_PAR14","Sim","Si","Yes", "","Nao","No","No", "", "", "", "", "", "", "", "", "", "", "", "", "")

/*-----------------------MV_PAR15--------------------------*/
Aadd( aHelpPor, "Imprime descricao do Armazem. Sim ou Nao" )
Aadd( aHelpEng, "Print warehouse description. Yes or No  " )
Aadd( aHelpSpa, "Imprime descripcion del almacen. Si o No" ) 

PutSx1( "MR425A","15","Imprime descricao do Armazem ?","Imprime descripc. del almacen?","Print warehouse description ?","mv_chf","N",1,0,2,"C","","","","","mv_par15","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR16--------------------------*/
aHelpPor := {"Data de Validade inicial a ser ",	"considerada na filtragem do cadastro","de saldos por lote (SB8)." }
aHelpEng := {"Initial Validity date to ",	"consider in the filtering of","Balances by Lot file (SB8)." }
aHelpSpa := {"Fecha de Validez inicial a ser ",	"considerado en filtro del archivo","de Saldos por Lote   (SB8)." }

PutSx1( "MR425A","16","Da Data de Validade ?","De la Fecha de Validez ?","Of Validity date ?","mv_chg","D",8,0,0,"G","","","","","mv_par16","","","","'01/01/01'","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR17--------------------------*/
aHelpPor := {"Data de Validade final a ser ",	"considerada na filtragem do cadastro","de saldos por lote (SB8)." }
aHelpEng := {"Final Validity date to ",	"consider in the filtering of","Balances by Lot file (SB8)." }
aHelpSpa := {"Fecha de Validez final a ser ",	"considerado en filtro del archivo","de Saldos por Lote   (SB8)." }

PutSx1( "MR425A","17","Ate a Data de Validade ?","A fecha de Validez ?","To Validity date ?","mv_chh","D",8,0,0,"G","","","","","mv_par17","","","","31/12/06","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return
