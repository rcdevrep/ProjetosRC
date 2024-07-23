#INCLUDE "PROTHEUS.CH"




User Function AGX610()
Local cCusto
Local lInvertMov := .F.
Local lPriApropri:=.T.
Local lLocProc   := mv_par08 == GetMv("MV_LOCPROC")
Local lRemInt    := SuperGetMv("MV_REMINT",.F.,.F.)
Local cTrbSD1    := ""
Local nInd2      := 0
Local cTrbSD2    := ""
Local nInd3      := 0
Local cTrbSD3    := ""
Local lVersao    := (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11)
Local cLocaliz   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Local para SIGAVEI, SIGAPEC e SIGAOFI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArq1	     := "" 
Local lT		 := .F.
Local nForFilial := 0
Local i			 := 0
Local nInd1	     := 0
Local cFilBack   := cFilAnt
Local aSalAlmox	 :={},aArea:={}
Local cSeek		 :=""
Local cProdMNT   := GetMv("MV_PRODMNT")
Local cProdTER   := GetMv("MV_PRODTER")
Local aProdsMNT  := {}   
Local lDev  // Flag que indica se nota ‚ devolu‡ao (.T.) ou nao (.F.)   
Local lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),GetMV("MV_CUSFIL",.F.))
cFilBack :=   cFilAnt


If Pergunte("MTR420",.T.)


cProdMNT := cProdMNT + Space(15-Len(cProdMNT))
cProdTER := cProdTER + Space(15-Len(cProdTER))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis especificas deste relatorio                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cProdAnt  := ""
PRIVATE cAnt 	  := ""
PRIVATE lFirst1   := .T.
PRIVATE aSalAtu   := {}
PRIVATE nEntPriUM,nSaiPriUM,nEntSegUM,nSaiSegUM,nEntraVal,nSaidaVal
PRIVATE nRec1,nRec2,nRec3,nRecCN,nRecCM,nSavRec
PRIVATE dDataIni,dDataFim,dCntData
PRIVATE cPicB2Qt  := PesqPictQt("B2_QATU"   ,16)
PRIVATE cPicB2Qt2 := PesqPictQt("B2_QTSEGUM",16)
PRIVATE nEntrada  := nSaida :=0
PRIVATE nCEntrada := nCSaida:=0
PRIVATE cPicD1Cust:= PesqPict("SD1","D1_CUSTO",18,mv_par10)

aFilsCalc := MatFilCalc((mv_par12 == 1))

dDataIni:= mv_par05
dDataFim:= mv_par06

For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[ nForFilial, 1 ]
	
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se utiliza custo unificado por empresa              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCusUnif:=lCusUnif .And. Trim(mv_par08) == "**" 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cbtxt := SPACE(10)
		cbcont:= 0
		li    := 80
		m_pag := 01
		

		*------------------------- Pega a data inicial ideal no SD1
		dbSelectArea("SD1")
		nSavRec := recno()
		dbSetOrder(6)
		dbSeeK(xFilial("SD1")+DTOS(mv_par05),.T.)
		If Day(D1_DTDIGIT) > 0
			dDataIni := D1_DTDIGIT
		EndIf
		*------------------------- Pega a data final ideal no SD1
		dbSeeK(xFilial("SD1")+DTOS(mv_par06)+"zzzz",.T.)
		If !BOF()
			dbSkip(-1)
		EndIf
		If Day(D1_DTDIGIT) > 0 .and. D1_DTDIGIT <= mv_par06
			dDataFim := D1_DTDIGIT
		EndIf
		GoTo nSavRec

		// Caso utilize custo unificado por empresa, cria indice temporario
		dbSelectArea("SD1")
		If lCusUnif
			cTRBSD1 := CriaTrab(,.F.)
			INDREGUA("SD1",cTrbSD1,"D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_NUMSEQ",,DBFilter())
			nInd1 := RetIndex("SD1")
			#IFNDEF TOP
				dbSetIndex(cTrbSD1+OrdBagExt())
			#ENDIF
			dbSetOrder(nInd1+1)
		Else
			dbSetOrder(7)
		EndIf
		*--------------------------------------------------------------
		
		*------------------------- Pega a data inicial ideal no SD2
		dbSelectArea("SD2")
		nSavRec := recno()
		dbSetOrder(5)
		dbSeeK(xFilial("SD2")+DTOS(mv_par05),.T.)
		If !EOF() .And. D2_EMISSAO < dDataIni
			If Day(D2_EMISSAO) > 0
				dDataIni := D2_EMISSAO
			EndIf
		EndIf
		*------------------------- Pega a data final ideal no SD2
		dbSeeK(xFilial("SD2")+DTOS(mv_par06)+"zzzz",.T.)
		If !BOF()
			dbSkip(-1)
		EndIf
		If D2_EMISSAO > dDataFim .and. D2_EMISSAO <= mv_par06
			dDataFim := D2_EMISSAO
		EndIf
		GoTo nSavRec

		// Caso utilize custo unificado por empresa, cria indice temporario
		If lCusUnif
			cTRBSD2 := CriaTrab(,.F.)
			INDREGUA("SD2",cTrbSD2,"D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)+D2_NUMSEQ",,DBFilter())
			nInd2 := RetIndex("SD2")
			#IFNDEF TOP
				dbSetIndex(cTrbSD2+OrdBagExt())
			#ENDIF
			dbSetOrder(nInd2+1)
		Else
			dbSetOrder(6)
		EndIf
		*--------------------------------------------------------------
		
		*------------------------- Pega a data inicial ideal no SD3
		dbSelectArea("SD3")
		nSavRec := recno()
		dbSetOrder(6)
		dbSeeK(xFilial("SD3")+DTOS(mv_par05),.T.)
		If !EOF() .And. D3_EMISSAO < dDataIni
			If Day(D3_EMISSAO) > 0
				dDataIni := D3_EMISSAO
			EndIf
		EndIf
		*------------------------- Pega a data final ideal no SD3
		dbSeeK(xFilial("SD3")+DTOS(mv_par06)+"zzzz",.T.)
		If !BOF()
			dbSkip(-1)
		EndIf
		If D3_EMISSAO > dDataFim .and. D3_EMISSAO <= mv_par06
			dDataFim := D3_EMISSAO
		EndIf
		GoTo nSavRec
		*--------------------------------------------------------------
		
		If dDataIni < mv_par05
			dDataIni := mv_par05
		EndIF
		
		If dDataFim > mv_par06
			dDataFim := mv_par06
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se utiliza custo unificado por empresa              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCusUnif:=lCusUnif .And. Trim(mv_par08) == "**"
		
		// Caso imprima armazem de processo cria indice de trabalho
		If lLocProc .Or. lCusUnif
			cTRBSD3 := CriaTrab(,.F.)
			INDREGUA("SD3",cTrbSD3,"D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_NUMSEQ",,DBFilter())
			nInd3 := RetIndex("SD3")
			#IFNDEF TOP
				dbSetIndex(cTrbSD3+OrdBagExt())
			#ENDIF
			dbSetOrder(nInd3+1)
		Else
			dbSetOrder(7)
		EndIf

		dbSelectArea("SB2")
		dbSetOrder(1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a Ordem do Relatorio a ser impresso                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis para controlar cursor de progressao     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcRegua( RecCount() )
		
		While !Eof() .and. SB1->B1_FILIAL == xFilial("SB1") .and. &cCond1 <= &cCond2
			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Não imprimir o produto MANUTENCAO (MV_PRDMNT) qdo integrado com MNT.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (FindFunction("MTR420IsMNT"))
				If MTR420IsMNT()
					If FindFunction("NGProdMNT")
						aProdsMNT := aClone(NGProdMNT())
						If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim(SB1->B1_COD) }) > 0
							dbSkip()
							Loop
						EndIf
					ElseIf AllTrim(SB1->B1_COD) == AllTrim(cProdMNT) .and. AllTrim(SB1->B1_COD) == AllTrim(cProdTER)
						dbSkip()
						Loop
					EndIf
				EndIf
			EndIf                 
			
			
			dbSelectArea("SB1")
			// Filtra por Tipo
			If B1_TIPO < mv_par03 .or. B1_TIPO > mv_par04
				dbSkip()
				Loop
			EndIf
			
			// Filtra por Produto
			lT := .F.
		   	If ! lVEIC
				If B1_COD < mv_par01 .or. B1_COD > mv_par02
					lT := .T.
				EndIf
			Else
				If B1_CODITE < mv_par01 .or. B1_CODITE > mv_par02
					lT := .T.
				EndIf
			EndIf
			If lT
				dbSkip()
				Loop
			EndIf  
			
			dbSelectArea("SB2")
			dbSeek(xFilial("SB2")+SB1->B1_COD+If( lCusUnif, "", mv_par08))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao encontrar no arquivo de saldos ,nao lista ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Eof()
				dbSelectArea("SB1")
				dbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Saldo Inicial do Produto             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEntrada := nSaida  := 0
			nCEntrada:= nCSaida := 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Saldo Inicial do Produto             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCusUnif
				aArea:=GetArea()
				aSalAtu  := { 0,0,0,0,0,0,0 }
				dbSelectArea("SB2")
				dbSetOrder(1)
				dbSeek(cSeek:=xFilial("SB2") + (SB1->B1_COD))
				While !Eof() .And. B2_FILIAL+B2_COD == cSeek
					aSalAlmox := CalcEst(SB1->B1_COD,SB2->B2_LOCAL,mv_par05)
					For i:=1 to Len(aSalAtu)
						aSalAtu[i] += aSalAlmox[i]
					Next i
					dbSkip()
				End
				RestArea(aArea)
			Else
				aSalAtu := CalcEst(SB1->B1_COD,mv_par08,mv_par05)
			EndIf
			
			cProdAnt  := SB1->B1_COD
			cLocalAnt := IIf(lCusUnif,SB2->B2_LOCAL,mv_par08)
			dCntData  := dDataIni
			Store 0 To nRec1,nRec2,nRec3,nRecCM,nRecCN
			lFirst1  := .T.
			
			// Posiciona pela Data mais Proxima no Movimento de Entrada
			dbSelectArea("SD1")
			If !lCusUnif
				dbSeek(xFilial("SD1")+SB1->B1_COD+mv_par08+dtos(mv_par05),.T.) // dbSetOrder(7)
			Else
				dbSeek(xFilial("SD1")+SB1->B1_COD+dtos(mv_par05),.T.) // indice temporario criado
			EndIf
			
			// Posiciona pela Data mais Proxima no Movimento de Saida
			dbSelectArea("SD2")
			If !lCusUnif
				dbSeek(xFilial("SD2")+SB1->B1_COD+mv_par08+dtos(mv_par05),.T.) // dbSetOrder(6)
			Else
				dbSeek(xFilial("SD2")+SB1->B1_COD+dtos(mv_par05),.T.) // indice temporario criado
			EndIf
			
			// Posiciona pela Data mais Proxima na Movimentacao Interna
			dbSelectArea("SD3")
			If lLocProc .Or. lCusUnif
				dbSeek(xFilial("SD3")+SB1->B1_COD+dtos(mv_par05),.T.) // indice temporario criado
			Else
				dbSeek(xFilial("SD3")+SB1->B1_COD+mv_par08+dtos(mv_par05),.T.) // dbSetOrder(7)
			EndIf
			
			While .T.
				
				Store 0 To nEntPriUM,nSaiPriUM,nEntSegUM,nSaiSegUM,nEntraVal,nSaidaVal
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le as entradas do dia                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SD1")
				While !eof() .And. d1_filial == xFilial("SD1") .and. d1_dtdigit <= dDataFim .and. d1_dtdigit = dCntData .and. d1_cod = cProdAnt .and. If(lLocProc .Or. lCusUnif,.T.,D1_LOCAL == cLocalAnt)
					
					dbSelectArea("SF4")
					dbSeek(xFilial("SF4")+SD1->D1_TES)
					dbSelectArea("SD1")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If D1_ORIGLAN $ "LF" .Or. SF4->F4_ESTOQUE != "S"
						dbSkip()
						Loop
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Entradas quando armazem for diferente			     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  	 	If !lCusUnif .And. lLocProc
						If SD1->D1_LOCAL <> cLocalAnt  
  			 				dbSkip() 
						EndIf
				  	EndIf	 
					If cPaisLoc != "BRA"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Desconsiderar notas de remito e notas geradas pelo EIC       ³
						//| com excecao da nota de FOB.									 |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(SD1->D1_REMITO) .Or. SD1->D1_TIPO_NF $ '6789AB'
							SD1->(dbSkip())
							Loop
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Desconsiderar notas de entrada tipo 10 quando o cliente uti_ |
						//| lizar o conceito de remito interno com importacao (SIGAEIC)  |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lRemInt
							If !Empty(SD1->D1_CONHEC) .And. SD1->D1_TIPO_NF $ '5' .And. SD1->D1_TIPODOC $ '10'
								SD1->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
					
					lDev:=MTR420Dev()
					If D1_TES <= "500" .And. !lDev 
						nEntrada  += D1_QUANT
						nEntPriUM += D1_QUANT
						nEntSegUM += D1_QTSEGUM
						nCEntrada += &(Eval(bBloco,"D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
						nEntraVal += &(Eval(bBloco,"D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
					Else
						If !lDev
							nSaida    += D1_QUANT
							nSaiPriUM -= D1_QUANT
							nSaiSegUM -= D1_QTSEGUM
							nCSaida   += &(Eval(bBloco,"D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
							nSaidaVal -= &(Eval(bBloco,"D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
						Else
							nSaida    -= D1_QUANT
							nSaiPriUM += D1_QUANT
							nSaiSegUM += D1_QTSEGUM
							nCSaida   -= &(Eval(bBloco,"D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
							nSaidaVal += &(Eval(bBloco,"D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
						EndIf
					EndIf
					nRec1++
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le as movimentacoes internas do dia            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SD3")
				While !Eof() .And. D3_FILIAL == xFilial("SD3") .And. D3_EMISSAO <= dDataFim .And. D3_EMISSAO == dCntData .And. D3_COD == cProdAnt .And. If(lLocProc .Or. lCusUnif,.T.,D3_LOCAL == cLocalAnt)
					
					If D3_ESTORNO == 'S' 
						dbSkip()
						Loop
					EndIf   
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quando movimento ref apropr. indireta, so considera os         ³
					//³ movimentos com destino ao almoxarifado de apropriacao indireta.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lInvertMov := .F.
					If D3_LOCAL != cLocalAnt .Or. lCusUnif
						If !(Substr(SD3->D3_CF,3,1) == "3")
							If !lCusUnif
								dbSkip()
								Loop
							EndIf
						ElseIf lPriApropri
							lInvertMov:=.T.
						EndIf
					EndIf
					
					dbSelectArea("SF5")
					dbSeek(xFilial("SF5")+SD3->D3_TM)
					dbSelectArea("SD3")
					
					If lInvertMov
						If D3_TM > "500"
							nEntrada  += D3_QUANT
							nEntPriUM += D3_QUANT
							nEntSegUM += D3_QTSEGUM
							nCEntrada += &(Eval(bBloco,"D3_CUSTO",mv_par10))
							nEntraVal += &(Eval(bBloco,"D3_CUSTO",mv_par10))
							If lCusUnif
								lPriApropri:=.F.
							EndIf
						Else
							nSaida    += D3_QUANT
							nSaiPriUM -= D3_QUANT
							nSaiSegUM -= D3_QTSEGUM
							nCSaida   += &(Eval(bBloco,"D3_CUSTO",mv_par10))
							nSaidaVal -= &(Eval(bBloco,"D3_CUSTO",mv_par10))
						EndIf
					Else
						If D3_TM <= "500"
							nEntrada  += D3_QUANT
							nEntPriUM += D3_QUANT
							nEntSegUM += D3_QTSEGUM
							nCEntrada += &(Eval(bBloco,"D3_CUSTO",mv_par10))
							nEntraVal += &(Eval(bBloco,"D3_CUSTO",mv_par10))
						Else
							nSaida    += D3_QUANT
							nSaiPriUM -= D3_QUANT
							nSaiSegUM -= D3_QTSEGUM
							nCSaida   += &(Eval(bBloco,"D3_CUSTO",mv_par10))
							nSaidaVal -= &(Eval(bBloco,"D3_CUSTO",mv_par10))
						EndIf
						If lCusUnif
							lPriApropri:=.T.
						EndIf
					EndIf
					nRec3++
					If !lInvertMov .Or. (lInvertMov .And. lPriApropri)
						dbSkip()
					EndIf
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le as saidas do dia                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SD2")
				While !Eof() .And. D2_FILIAL == xFilial("SD2") .And. D2_EMISSAO <= dDataFim .And. D2_EMISSAO == dCntData;
					  .And. D2_COD == cProdAnt .And. If(lLocProc .Or. lCusUnif,.T.,D2_LOCAL == cLocalAnt)
					
					dbSelectArea("SF4")
					dbSeek(xFilial("SF4")+SD2->D2_TES)
					dbSelectArea("SD2")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If D2_ORIGLAN == "LF" .Or. SF4->F4_ESTOQUE != "S"
						dbSkip()
						Loop
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais com Remito(Localizacao)                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(cPaisLoc $ "BRA|CHI")
						If ! Empty(SD2->D2_REMITO) .AND. !(SD2->D2_TPDCENV $ "1A")
							dbSkip()
							Loop
						EndIf
					EndIf
					If cPaisLoc == "CHI" .And.IsRemito(1,'SD2->D2_TIPODOC') .And. SD2->D2_QTDEFAT > 0
						dbSkip()
						Loop
					EndIf
					
					lDev:=MTR420Dev()
					If D2_TES <= "500" .Or. lDev
						If !lDev
							nEntrada  += D2_QUANT
							nEntPriUM += D2_QUANT
							nEntSegUM += D2_QTSEGUM
							nCEntrada += &(Eval(bBloco,"D2_CUSTO",mv_par10))
							nEntraVal += &(Eval(bBloco,"D2_CUSTO",mv_par10))
						Else
							nEntrada  -= D2_QUANT
							nEntPriUM -= D2_QUANT
							nEntSegUM -= D2_QTSEGUM
							nCEntrada -= &(Eval(bBloco,"D2_CUSTO",mv_par10))
							nEntraVal -= &(Eval(bBloco,"D2_CUSTO",mv_par10))
						EndIf
					Else
						nSaida    += D2_QUANT
						nSaiPriUM -= D2_QUANT
						nSaiSegUM -= D2_QTSEGUM
						nCSaida   += &(Eval(bBloco,"D2_CUSTO",mv_par10))
						nSaidaVal -= &(Eval(bBloco,"D2_CUSTO",mv_par10))
					EndIf
					nRec2++
					dbSkip()
				EndDo
				
		
				If nEntPriUM != 0 .Or. nEntraVal != 0 .Or. nEntSegUM != 0 .Or.;
					nSaiPriUM != 0 .Or. nSaidaVal != 0 .Or. nSaiSegUM != 0
					
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ele soma as saidas porque elas estao com valores negativos ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aSalAtu[1] := aSalAtu[1] + nEntPriUM + nSaiPriUM
					aSalAtu[mv_par10+1] := aSalAtu[mv_par10+1] + nEntraVal + nSaidaVal
					aSalAtu[7] := aSalAtu[7] + nEntSegUM + nSaiSegUM   
					
					//alert(aSalAtu[1])
					
		 			@ Li,000 PSay dCntData
					@ Li,011 PSay "|"
					@ Li,015 PSay nEntPriUM Picture cPicB2Qt
					@ Li,032 PSay nEntraVal Picture cPicD1Cust
					
					@ Li,051 PSay "|"
					@ Li,055 PSay IIf(nSaiPriUM<0,nSaiPriUM*-1,nSaiPriUM) Picture cPicB2Qt
					@ Li,072 PSay IIf(nSaidaVal<0,nSaidaVal*-1,nSaidaVal) Picture cPicD1Cust
					@ Li,091 PSay "|"
					@ Li,096 PSay aSalAtu[1] Picture cPicB2Qt
					@ Li,114 PSay aSalAtu[mv_par10+1] Picture cPicD1Cust
					Li++
				EndIf
				
				
			EndDo
			
			dbSelectArea("SB1")
			dbSkip()
			
		EndDo
		
	
	EndIf
		
Next nForFilial

cFilAnt := cFilBack

dbSelectArea("SB1")
dbClearFilter()
If !Empty(cArq1) .And. File(cArq1 + OrdBagExt())
	RetIndex('SB1')
	FERASE(cArq1 + OrdBagExt())
EndIf

dbSetOrder(1)
dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SD1")
If lCusUnif
	dbClearFilter()
	RetIndex("SD1")
	If File(cTrbSD1+OrdBagExt())
		Ferase(cTrbSD1+OrdBagExt())
	EndIf
EndIf
dbSetOrder(1)

dbSelectArea("SD2")
If lCusUnif
	dbClearFilter()
	RetIndex("SD2")
	If File(cTrbSD2+OrdBagExt())
		Ferase(cTrbSD2+OrdBagExt())
	EndIf
EndIf
dbSetOrder(1)

dbSelectArea("SD3")
If lLocProc .Or. lCusUnif
	dbClearFilter()
	RetIndex("SD3")
	If File(cTrbSD3+OrdBagExt())
		Ferase(cTrbSD3+OrdBagExt())
	EndIf
EndIf
dbSetOrder(1) 




EndIF



Return()


