/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271CalcValores ³ Autor ³ Marcelo Kotaki       ³ Data ³ 28/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor dos campos de desconto e acrescimo           		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tk271CalcDesc(ExpN1,ExpC1)										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Tipo(1=% 2=Valor), ExpN1 = Valor/Percentual  	    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas - SX3                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  	    ³±±
±±³          ³        ³      ³                                            	    ³±±
±±³          ³        ³      ³                                            	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Agr063Calc(cCampo,nLinha)
Local nValor    := &( ReadVar() )			// Get atual do campo
Local cArea     := GetArea()				// Pega a area atual	
Local nPProd    := aPosicoes[1][2]			// Posicao do Produto
Local nPQtd 	 := aPosicoes[4][2]			// Posicao da Quantidade
Local nPTes	    := aPosicoes[11][2]			// Tes
Local nPItem	 := aPosicoes[20][2]         // Posicao do Item
Local aListaKit := {}						// Itens do cadastro de KIT
Local nCont 	 := 0 						// Contador	de Itens do KIT
Local nAtual  	 := 0						// Linha atual depois da inclusao de KIT 
Local nColuna 	 := 1   						// Contador de colunas do aHeader
Local cItem 	 := ""
Local lRet      := .F.						// Retorno da funcao

STATIC aDescEsca												// Usado na funcao TKREGRADESC 
STATIC lChecaKit  := GetMv("MV_TMKKIT")                         // Indica se o sistema vai lancar automaticamente KIT 

nLinha:= IIF(ValType(nLinha) == "U", n, nLinha )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe os produtos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo <> "UB_PRODUTO"
	If Empty(aCols[nLinha][nPProd])
		Return(lRet)
	Endif
Endif

Do Case
 	Case (cCampo == "UA_TABELA")
 	    nValor := aCols[nLinha][nPProd]
		lRet := TKP000A(nValor,nLinha)

 	Case (cCampo == "UB_PRODUTO")
		lRet := TKP000A(nValor,nLinha)
	
	Case (cCampo == "UB_QUANT")
		lRet := TKP000B(nValor,nLinha)
		
	Case (cCampo == "UB_VRUNIT")
		lRet := TkP000C(nValor,nLinha)
		
	Case (cCampo == "UB_DESC")
		lRet := TkP000D(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_VALDESC")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a TES utilizada e diferente da TES de bonificacao calcula os acrescimos e descontos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := TkP000E(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_ACRE")
		lRet := Agr063G(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
			
	Case (cCampo == "UB_VALACRE")
		lRet := TkP000H(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	

Endcase

Eval(bRefresh)  // Incluido por Valdecir em 18.01.05

//Incluido por Valdecir em 16.02.05.
// Sr. Deco acompanhou esta alteracao.
nPosItem := aScan(aHeader,{|x| Alltrim(x[2])=="UB_VLRITEM"})
nVlrItem := aCols[n][nPosItem]
                                  
MaFisAlt("IT_TES",aCols[nLinha][nPTes],nLinha)

If MaFisFound()
	MaColsToFis(aHeader,aCols,nLinha,"TK273",.T.)
	aCols[n][nPosItem] := nVlrItem  //Incluido por Valdecir em 16.02.05
	TK273REFRESH(aValores)   // Incluido por Valdecir em 18.01.05
Endif


If M->UA_PDESCAB > 0
	Tk273CalcDesc()
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esse TES gera titulos para nao obrigar a selecao das condicoes de pagamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+aCols[nLinha][nPTes])
   If SF4->F4_DUPLIC == "N"
   	  lTesTit := .F.
   Endif	  	  
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o KIT no cadastro de acessorios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lChecaKit) .AND. (cCampo == "UB_PRODUTO")
	
	DbSelectarea("SUG")
	DbSetorder(2)
	If DbSeek(xFilial("SUG") + nValor)
		If nValor == SUG->UG_PRODUTO
			DbSelectarea("SU1")
			DbSetorder(1)
			If DbSeek(xFilial("SU1")+SUG->UG_CODACE)
				While (! Eof()) .AND. (SU1->U1_FILIAL == xFilial("SU1")) .AND. (SU1->U1_CODACE == SUG->UG_CODACE)
					
					If SU1->U1_KIT == "1"  //SIM
						
						AADD(aListaKit,{SU1->U1_ACESSOR,;			//Codigo do Acessorio
										SU1->U1_QTD})				//Quantidade
					Endif
					
					SU1->(DbSkip())
				End
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega o conteudo o ultimo item (Valor)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cItem 	:= aCols[Len(aCols)][nPItem]
			nAtual  := 0
			nAtual	:= LEN(aCols)
			
			For nCont := 1 TO Len(aListaKit)
				AADD(aCols,Array(len(aHeader)+1))
				nAtual ++
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³X3_TITULO   1³
				//³X3_CAMPO    2³
				//³X3_PICTURE  3³
				//³X3_TAMANHO  4³
				//³X3_DECIMAL  5³
				//³X3_VALID    6³
				//³X3_USADO    7³
				//³X3_TIPO     8³
				//³X3_ARQUIVO  9³
				//³X3_CONTEXT 10³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa as variaveis da aCols (tratamento para    ³
				//³campos criados pelo usu rio)							³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nColuna := 1 To LEN( aHeader )
					
					If aHeader[nColuna][8] == "C"
						aCols[nAtual][nColuna] := SPACE(aHeader[nColuna][4])
						
					ElseIf aHeader[nColuna][8] == "D"
						aCols[nAtual][nColuna] := dDataBase
						
					ElseIf aHeader[nColuna][8] == "M"
						aCols[nAtual][nColuna] := ""
						
					ElseIf aHeader[nColuna][8] == "N"
						aCols[nAtual][nColuna] := 0
						
					Else
						aCols[nAtual][nColuna] := .F.
					Endif
					
				Next nColuna
				
				aCols[nAtual][LEN(aHeader)+1] := .F.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o aCols com o acessorio, atualizado o item o produto e a quantidade alem da funcao fiscal ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cItem 			 	  := Soma1(cItem,Len(cItem))
				aCols[nAtual][nPItem] := cItem
				
				M->UB_PRODUTO	 	  := aListaKit[nCont][1]
				aCols[nAtual][nPProd] := aListaKit[nCont][1]
				
				MaColsToFis(aHeader,aCols,nAtual,"TK273",.F.)
				TKP000A(M->UB_PRODUTO,nAtual)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o acols com as quantidades e recalcula os valores do item.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->UB_QUANT  		 := aListaKit[nCont][2]
				aCols[nAtual][nPQtd] := aListaKit[nCont][2]
				TKP000B(M->UB_QUANT,nAtual)
				
			Next nCont
			n := nAtual
			M->UB_PRODUTO := nValor // Inicializa a variavel de memoria com o item pai

			oGetTlv:oBrowse:Refresh()
		Endif
	Endif
Endif

// Comentado por Valdecir em 18.01.05 SysRefresh()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000B  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o valor do item de acordo com quantidade- UB_QUANT³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000B(nValor,nLinha)

Local lRet		:= .F.						// Retorno da funcao
Local nPProd	:= aPosicoes[1][2]			
Local nPQtd     := aPosicoes[4][2]          
Local nPVrUnit  := aPosicoes[5][2]
Local nPVlrItem := aPosicoes[6][2]
Local nPDesc 	:= aPosicoes[9][2]
Local nPValDesc := aPosicoes[10][2]
Local nPAcre 	:= aPosicoes[13][2]
Local nPValAcre := aPosicoes[14][2]
Local nPPrcTab  := aPosicoes[15][2]
Local nDesc		:= 0 
Local cUA_CONDPG:= ""

If (SUA->(FieldPos("UA_CONDPG"))  > 0) 
	cUA_CONDPG := M->UA_CONDPG
Endif	

If !Empty(M->UA_TABELA)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for uma tabela de preço valida calcula o valor unitario do item    ³
	//³Utilizada a funcao de materiais para  calculo da faixa.               ³                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// VAVA	aCols[nLinha][nPVrUnit] := MaTabPrVen(M->UA_TABELA,aCols[nLinha][nPProd],nValor,M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA)
// VAVA	aCols[nLinha][nPPrcTab] := aCols[nLinha][nPVrUnit]
EndIf

aCols[nLinha][nPQtd]    	:= nValor
aCols[nLinha][nPVlrItem]	:= Round((aCols[nLinha][nPQtd] * aCols[nLinha][nPVrUnit]),4)


//MSGSTOP(aCols[nLinha][nPValDesc]) 	:= Round((aCols[nLinha][nPQtd] * aCols[nLinha][nPVrUnit]),4)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os DESCONTOS 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// VAVA aCols[nLinha][nPDesc] 	 := 0 
// VAVA aCols[nLinha][nPValDesc] := 0 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os ACRESCIMOS 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPAcre] 	 := 0 
aCols[nLinha][nPValAcre] := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica a regra da TABELA DE DESCONTOS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// VAVA nDesc := TkRegraDesc(1,aValores[TOTAL],0,NIL,cUA_CONDPG)
// VAVA lRet  := TkP000D(nDesc,nLinha)

// VAVA aCols[nLinha][nPVlrItem]:= (aCols[nLinha][nPQtd] * aCols[nLinha][nPVrUnit])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o ACRESCIMO com valor 0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := Agr063G(0,nLinha)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Recalc     ³Autor ³ Fabio Rogerio    ³ Data ³ 20/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recalcula os valores do pedido 		               	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³29/07/02³710   ³-Se o ACOLS estiver vazio nao executa o 	  ³±±
±±³          ³        ³      ³recalculo dos totais                        ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Agr063Recalc()

Local nLinha	:= 0
Local nPProd 	:= aPosicoes[1][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os valores de desconto, acrescimo, mercadoria e total.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aValores[DESCONTO]  := 0
aValores[MERCADORIA]:= 0
aValores[TOTAL]     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recalcula os valores somente para os itens que nao foram deletados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLinha:=1 To Len(aCols)
	
	If (!aCols[nLinha][Len(aHeader)+1]) .AND. (!Empty(aCols[nLinha][nPProd]))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a rotina que ira calcular os valores de Valor Unitario, Valor Item, Desconto e Acrescimo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Agr063Calc("UA_TABELA",nLinha)
		
	Endif
	
Next nLinha

oGetTlv:oBrowse:Refresh(.T.)
              
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000G  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o Valor do item de acordo com o acrescimo - UB_ACRE³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Agr063G(nValor,nLinha)

Local lRet 	 	:= .F.									// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]
Local nPVrUnit	:= aPosicoes[5][2]
Local nPVlrItem := aPosicoes[6][2]
Local nPDesc	:= aPosicoes[9][2]
Local nPValDesc := aPosicoes[10][2]
Local nPTes	    := aPosicoes[11][2]
Local nPAcre 	:= aPosicoes[13][2]
Local nPValAcre := aPosicoes[14][2]
Local nPPrctab  := aPosicoes[15][2]
Local nValUni   := 0
Local nVlrTab   := 0
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local cAcrescimo:= TkPosto(M->UA_OPERADO,"U0_ACRESCI") 	// Acrescimo 1=ITEM / 2=NAO
Local cTesBonus := GetMv("MV_BONUSTS") 					// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]
Local cCampo 	:= ReadVar()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda nao recalcula o unitario nao pode dar acrescimo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo == "M->UB_ACRE"
	If ALLTRIM(cAcrescimo) == "2"  // Acrescimo = 2 - Nao
		If nValor > 0 
			Help( " ", 1, "NAO_ACRESC")
			aCols[nLinha][nPAcre]:= 0
			Return(lRet)
		Endif	
	ElseIf ALLTRIM(cPrcFiscal) == "1"  // Preco Fiscal Bruto NAO (NAO ALTERA O UNITARIO NAO PODE DAR ACRESCIMO)
		If nValor > 0 
			Help( " ", 1, "NAO_ACRESC")
			aCols[nLinha][nPAcre]:= 0
			Return(lRet)
		Endif	
	Endif
Endif

aCols[nLinha][nPAcre]:= nValor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no preco de tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* VAVA
If aCols[nLinha][nPPrcTab] > 0
   nVlrTab := aCols[nLinha][nPPrcTab] - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

nValUni	 := A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      ³
//³no momento de gerar o SC6 ser  gerado uma DIZIMA PERIODICA consequentemente n„o vai bater o valor liquido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPValAcre]:= A410Arred(((nVlrTab * aCols[nLinha][nPAcre]) / 100) * aCols[nLinha][nPQtd],"UB_VALACRE")
*/                                   
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

lRet := .T.

Return(lRet)



// Chamado 32506 - Calculo para preço unitário, paliativo até que seja analisada a situação
Static Function TkP000C(nValor,nLinha)

Local lRet 		:= .T.									// Retorno da funcao
Local lRecalc	:= .T.									// Indica se os valores devem ser recalculados
Local nPQtd		:= aPosicoes[4][2]						// Quantidade
Local nPVrUnit	:= aPosicoes[5][2]						// Valor unitario
Local nPVlrItem := aPosicoes[6][2]						// Valor do item 
Local nPDesc 	:= aPosicoes[9][2]						// % Desconto
Local nPAcre 	:= aPosicoes[13][2]						// % Acrescimo
Local nPValDesc := aPosicoes[10][2]						// $ Desconto em valor
Local nPValAcre := aPosicoes[14][2]						// $ Acrescimo em valor	
Local nPPrctab  := aPosicoes[15][2]						// Posicao do Preco de Tabela
Local nPProd  := aPosicoes[1][2]						// Posicao do Produto
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local lTk27300C := FindFunction("U_TK27300C")			// P.E. utilizado na alteracao do preco unitario
Local nDesc		:= 0									// Desconto vindo da regra de desconto


//?????????????????????????????????
//Verifica a existencia do ponto de entrada de validacao do preco?
//?????????????????????????????????
If lTk27300C
	lRet := U_TK27300C()
	If ValType(lRet) <> "L"
		lRet := .F.
	Endif	
Endif	

//????????????????????????????????
//Somente ira recalcular o item e zerar os acrescimos/descontos?
//Quando o valor do item realmente for alterado.               ?
//e o usuario apenas pressionar <Enter> sobre o campo sem     ?
//Modificar seu valor, nenhum tratamento se faz necessario     ?
//????????????????????????????????
lRecalc := (aCols[nLinha][nPVrUnit] <> nValor)

//??????????????????????????????????
//Caso seja verdadeira executa os processos de validacao. A        ?
//Variavel lRet e sempre inicializada com .T. para caso nao exista ?
//o ponto de entrada, o processo seja realizado normalmente        ?
//??????????????????????????????????
If lRet .AND. lRecalc
	aCols[nLinha][nPVrUnit] := nValor
	
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPAcre]   := 0
	aCols[nLinha][nPValDesc]:= 0
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	
	//???????????????????????????????
	//?e não tiver preço de tabela, o valor inicialmente digitado?
	//?ubstituir?o preço de tabela que está zerado.             ?
	//???????????????????????????????
	If aCols[nLinha][nPPrctab] == 0
		aCols[nLinha][nPPrctab] := aCols[nLinha][nPVrUnit]
		
		//?????????????????????????????
		//Aplica a regra da TABELA DE DESCONTOS no item j?      ?
		//que quando o mesmo foi incluido a regra não foi        ?
		//Replicada por não ter preço de tabela.                  ?
		//?????????????????????????????
		nDesc := TkRegraDesc(	1			, aValores[TOTAL]	, 0		, NIL	,;
								M->UA_CONDPG, nLinha			)
		nDesc := IIf(nDesc < 0,0,nDesc)
		TkP000D(nDesc,nLinha)
	ElseIf INCLUI
		If SB1->B1_COD <> aCols[nLinha][nPProd] // Verifica se eh o mesmo produto
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aCols[nLinha][nPProd])) // Existe pois passou pela validacao do campo
		EndIf
		nPrcProd := SB1->B1_PRV1
		If Empty(M->UA_TABELA) .And. nPrcProd == 0
			aCols[nLinha][nPPrctab] := aCols[nLinha][nPVrUnit]
		Else
			If !Empty(M->UA_TABELA)
				nPrcProd := 	MaTabPrVen(	M->UA_TABELA,;
													aCols[nLinha][nPProd],;
													aCols[nLinha][nPQtd],;
													M->UA_CLIENTE,;
													M->UA_LOJA,;
													M->UA_MOEDA,;
													NIL,;
													NIL,;
													NIL,;
													.T.,;
													lProspect)
				nPrcProd := nPrcProd*(1+(M->UA_X_ACRES/100))

			EndIf
			aCols[nLinha][nPPrctab] := IIf((nPrcProd == 0) .And. (aCols[nLinha][nPPrctab] > 0),aCols[nLinha][nPVrUnit],nPrcProd)
		EndIf
	EndIf
	
	MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
	If cPrcFiscal == "1"  // Se for Preco fiscal bruto = 1 - Sim
		aValores[DESCONTO] := 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif
Endif

//??????????????????????????????
//Atualiza o valor de memória, para evitar que o refresh da?
//GetDados volte o aCols ao valor digitado inicialmente.   ?
//??????????????????????????????
M->UB_VRUNIT := aCols[nLinha][nPVrUnit]

Return(lRet)


