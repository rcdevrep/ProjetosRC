#INCLUDE "AGR243.CH"
#INCLUDE "FIVEWIN.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR243  ³ Autor ³ Claudinei M. Benzi       ³ Data ³ 13.04.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Comissoes.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AGR243(void)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DATA   ³ BOPS ³Programad.³ALTERACAO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05.02.03³XXXXXX³Eduardo Ju³Inclusao de Queries para filtros em TOPCONNECT.³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AGR243()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local titulo    := STR0001  //"Relatorio de Comissoes"
Local cDesc1    := STR0002  //"Emissao do relatorio de Comissoes."
Local tamanho   := "G"
Local limite    := 220
Local cString   := "SE3"
Local cAliasAnt := Alias()
Local cOrdemAnt := IndexOrd()
Local nRegAnt   := Recno()
Private aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nomeprog:= "AGR243"
Private aLinha  := { },nLastKey := 0
Private cPerg   := "AGR243"

PRIVATE cVend   := TKOPERADOR()

cPerg   :="AGR243"
aRegistros := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Pela <E>missao,<B>aixa ou <A>mbos        ³
//³ mv_par02        	// A partir da data                         ³
//³ mv_par03        	// Ate a Data                               ³
//³ mv_par04 	    	// Do Vendedor                              ³
//³ mv_par05	     	// Ao Vendedor                              ³
//³ mv_par06	     	// Quais (a Pagar/Pagas/Ambas)              ³
//³ mv_par07	     	// Incluir Devolucao ?                      ³
//³ mv_par08	     	// Qual moeda                               ³
//³ mv_par09	     	// Comissao Zerada ?                        ³
//³ mv_par10	     	// Abate IR Comiss                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AADD(aRegistros,{cPerg,"01","Aliquota I.Renda  ?","mv_ch5","N",5,2,0,"G","","mv_par05","","","","","","","","","","","","","","",""})


CriaPerguntas(cPerg,aRegistros)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)               // Pergunta no SX1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "AGR243"
wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,"","",.F.,"",.F.,Tamanho)

If nLastKey==27
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey ==27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C540Imp(@lEnd,wnRel,cString)},Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna para area anterior, indice anterior e registro ant.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(caliasAnt)
DbSetOrder(cOrdemAnt)
DbGoto(nRegAnt)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C540IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGR243			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C540Imp(lEnd,WnRel,cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbCont,cabec1,cabec2
Local tamanho  := "G"
Local limite   := 220
Local nomeprog := "AGR243"
Local imprime  := .T.
Local cPict    := ""
Local cTexto,j :=0,nTipo:=0
Local cCodAnt,nCol:=0
Local nAc1:=0,nAc2:=0,nAg1:=0,nAg2:=0,nAc3:=0,nAg3:=0,lFirstV:=.T.
Local nTregs,nMult,nAnt,nAtu,nCnt,cSav20,cSav7
Local lContinua:= .T.
Local cNFiscal :=""
Local aCampos  :={}
Local lImpDev  := .F.
Local cBase    := ""
Local cNomArq, cCondicao, cFilialSE1, cFilialSE3, cChave, cFiltroUsu
Local nDecs    := GetMv("MV_CENT"+(IIF(1 > 1 , STR(1,1),"")))
Local	nBasePrt :=0, nComPrt:=0 
Local aStru    := SE3->(dbStruct()), ni

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

nTipo := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 3 == 1
	titulo := OemToAnsi(STR0005)+OemToAnsi(STR0006)+ " - " + GetMv("MV_MOEDA" + STR(1,1)) //"RELATORIO DE COMISSOES "###"(PGTO PELA EMISSAO)"
Elseif 3 == 2
	titulo := OemToAnsi(STR0005)+OemToAnsi(STR0007)+ " - " + GetMv("MV_MOEDA" + STR(1,1))  //"RELATORIO DE COMISSOES "###"(PGTO PELA BAIXA)"
Else
	titulo := OemToAnsi(STR0008)+ " - " + GetMv("MV_MOEDA" + STR(1,1))  //"RELATORIO DE COMISSOES"
Endif

cabec1:=OemToAnsi(STR0009)	//"PRF NUMERO   PARC. CODIGO DO              LJ  NOME                                 DT.BASE     DATA        DATA        DATA       NUMERO          VALOR           VALOR      %           VALOR    TIPO"
cabec2:=OemToAnsi(STR0010)	//"    TITULO         CLIENTE                                                         COMISSAO    VENCTO      BAIXA       PAGTO      PEDIDO         TITULO            BASE               COMISSAO   COMISSAO"
									// XXX XXXXXXxxxxxx X XXXXXXxxxxxxxxxxxxxx   XX  012345678901234567890123456789012345 XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx XXXXXX 12345678901,23  12345678901,23  99.99  12345678901,23     X       AJUSTE
									// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
									// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta condicao para filtro do arquivo de trabalho            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dtinicial := CTOD("01/01/01")
dtfinal   := ddatabase

DbSelectArea("SE3")	// Posiciona no arquivo de comissoes
DbSetOrder(2)			// Por Vendedor
cFilialSE3 := xFilial()
cNomArq :=CriaTrab("",.F.)

cCondicao := "SE3->E3_FILIAL=='" + cFilialSE3 + "'"
cCondicao += ".And.SE3->E3_VEND>='" + cVend + "'"
cCondicao += ".And.SE3->E3_VEND<='" + cVend + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)>='" + DtoS(dtinicial) + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)<='" + DtoS(dtfinal) + "'" 

If 3 == 1
	cCondicao += ".And.SE3->E3_BAIEMI!='B'"  // Baseado pela emissao da NF
Elseif 3 == 2
	cCondicao += " .And.SE3->E3_BAIEMI=='B'"  // Baseado pela baixa do titulo
Endif 

If 1 == 1 		// Comissoes a pagar
	cCondicao += ".And.Dtos(SE3->E3_DATA)=='"+Dtos(Ctod(""))+"'"
ElseIf 1 == 2 // Comissoes pagas
	cCondicao += ".And.Dtos(SE3->E3_DATA)!='"+Dtos(Ctod(""))+"'"
Endif

If 2 == 2 		// Nao Inclui Comissoes Zeradas
   cCondicao += ".And.SE3->E3_COMIS<>0"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria expressao de filtro do usuario                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ! Empty(aReturn[7]) )
	cFiltroUsu := &("{ || " + aReturn[7] +  " }")
Else
	cFiltroUsu := { || .t. }
Endif

nAg1 := nAg2 := 0

#IFDEF TOP
	If TcSrvType() != "AS/400"
		cQuery := "SELECT * "
		cQuery += "  FROM "+	RetSqlName("SE3")
		cQuery += " WHERE E3_FILIAL = '" + xFilial("SE3") + "' AND "
	  	cQuery += "	E3_VEND >= '"  + cVend + "' AND E3_VEND <= '"  + cVend + "' AND " 
		cQuery += "	E3_EMISSAO >= '" + Dtos(dtinicial) + "' AND E3_EMISSAO <= '"  + Dtos(dtfinal) + "' AND " 
		
		If 3 == 1
			cQuery += "E3_BAIEMI <> 'B' AND "  //Baseado pela emissao da NF
		Elseif 3 == 2
			cQuery += "E3_BAIEMI =  'B' AND "  //Baseado pela baixa do titulo  
		EndIf	
		
		If 1 == 1 		//Comissoes a pagar
			cQuery += "E3_DATA = '" + Dtos(Ctod("")) + "' AND "
		ElseIf 1 == 2 //Comissoes pagas
  			cQuery += "E3_DATA <> '" + Dtos(Ctod("")) + "' AND "
		Endif 
		
		If 2 == 2 		//Nao Inclui Comissoes Zeradas
   		cQuery+= "E3_COMIS <> '0' AND "
		EndIf  
		
		cQuery += "D_E_L_E_T_ <> '*' "   

		cQuery := ChangeQuery(cQuery)
											
		dbSelectArea("SE3")
		dbCloseArea()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE3', .F., .T.)
			
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE3', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next 
	Else
	
#ENDIF	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria arquivo de trabalho                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave := IndexKey()
		cNomArq :=CriaTrab("",.F.)
		IndRegua("SE3",cNomArq,cChave,,cCondicao, OemToAnsi(STR0016)) //"Selecionando Registros..."
		nIndex := RetIndex("SE3")
		DbSelectArea("SE3") 
		DbSetIndex(cNomArq+OrdBagExT())
		DbSetOrder(nIndex+1)

#IFDEF TOP
	EndIf
#ENDIF	

SetRegua(RecCount())		// Total de Elementos da regua 
DbGotop()
While !Eof()
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0011)  //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF
	IncRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa condicao do filtro do usuario                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Eval(cFiltroUsu)
		Dbskip()
		Loop
	Endif
	
	nAc1   := nAc2 := nAc3 := 0
	lFirstV:= .T.
	cVend  := SE3->E3_VEND
	
	While !Eof() .AND. SE3->E3_VEND == cVend
		IncRegua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa condicao do filtro do usuario                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Eval(cFiltroUsu)
			Dbskip()
			Loop
		Endif  

		If SE3->E3_PREFIXO <> "011" .And. SE3->E3_PREFIXO <> "021"
			DbSelectArea("SE3")
			SE3->(DbSkip())
			Loop
		EndIf

		
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o Codigo do Vendedor e Imprime o seu Nome          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lFirstV
			dbSelectArea("SA3")
			dbSeek(xFilial()+SE3->E3_VEND)
			@li, 00 PSAY OemToAnsi(STR0012) + SE3->E3_VEND + " " + A3_NOME //"Vendedor : "
			li+=2
			dbSelectArea("SE3")
			lFirstV := .F.
		EndIF
		
		@li, 00 PSAY SE3->E3_PREFIXO
		@li, 04 PSAY SE3->E3_NUM
		@li, 17 PSAY SE3->E3_PARCELA
		@li, 19 PSAY SE3->E3_CODCLI
		@li, 42 PSAY SE3->E3_LOJA
		
		dbSelectArea("SA1")
		dbSeek(xFilial()+SE3->E3_CODCLI+SE3->E3_LOJA)
		@li, 46 PSAY Substr(A1_NOME,1,35)
		
		dbSelectArea("SE3")
		@li, 83 PSAY SE3->E3_EMISSAO
		
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbSeek(xFilial()+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO)
		nVlrTitulo := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,nDecs+1),nDecs)
		dVencto    := SE1->E1_VENCTO  
		
		/*
		Nas comissoes geradas por baixa pego a data da emissao da comissao que eh igual a data da baixa do titulo.
		Isto somente dara diferenca nas baixas parciais
		*/	 
		
      If SE3->E3_BAIEMI == "B"
			dBaixa     := SE3->E3_EMISSAO
    	Else
			dBaixa     := SE1->E1_BAIXA
		Endif
		
		If Eof()
			dbSelectArea("SF2")
			dbSetorder(1)
			dbSeek(xFilial()+SE3->E3_NUM+SE3->E3_PREFIXO) 
			If ( cPaisLoc=="BRA" )
				nVlrTitulo := Round(xMoeda(F2_VALMERC+F2_VALIPI+F2_FRETE+F2_SEGURO,1,1,SF2->F2_EMISSAO,nDecs+1),nDecs)
			Else
				nVlrTitulo := Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,1,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
			Endif 
			
			dVencto    := " "
			dBaixa     := " "
			
			If Eof()
				nVlrTitulo := 0
				dbSelectArea("SE1")
				dbSetOrder(1)
				cFilialSE1 := xFilial()
				dbSeek(cFilialSE1+SE3->E3_PREFIXO+SE3->E3_NUM)
				While ( !Eof() .And. SE3->E3_PREFIXO == SE1->E1_PREFIXO .And.;
						SE3->E3_NUM == SE1->E1_NUM .And.;
						SE3->E3_FILIAL == cFilialSE1 )
					If ( SE1->E1_TIPO == SE3->E3_TIPO  .And. ;
						SE1->E1_CLIENTE == SE3->E3_CODCLI .And. ;
						SE1->E1_LOJA == SE3->E3_LOJA )
						nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,nDecs+1),nDecs)
						dVencto    := " "
						dBaixa     := " "
					EndIf
					dbSelectArea("SE1")
					dbSkip()
				EndDo
			EndIf
		Endif

		//Preciso destes valores para pasar como parametro na funcao TM(), e como 
		//usando a xmoeda direto na impressao afetaria a performance (deveria executar
		//duas vezes, uma para imprimir e outra para pasar para a picture), elas devem]
		//ser inicializadas aqui. Bruno.

		nBasePrt	:=	Round(xMoeda(SE3->E3_BASE ,1,1,SE1->E1_EMISSAO,nDecs+1),nDecs)
		nComPrt	:=	Round(xMoeda(SE3->E3_COMIS,1,1,SE1->E1_EMISSAO,nDecs+1),nDecs)

		@ li, 95 PSAY dVencto
		@ li,107 PSAY dBaixa  
		
		dbSelectArea("SE3")
		@ li,119 PSAY SE3->E3_DATA
		@ li,130 PSAY SE3->E3_PEDIDO	Picture "@!"
		@ li,137 PSAY nVlrTitulo		Picture tm(nVlrTitulo,14,nDecs)
		@ li,153 PSAY nBasePrt 			Picture tm(nBasePrt,14,nDecs)
		@ li,169 PSAY SE3->E3_PORC		Picture tm(SE3->E3_PORC,6)
		@ li,176 PSAY nComPrt			Picture tm(nComPrt,14,nDecs)
		@ li,195 PSAY SE3->E3_BAIEMI

		nAc1 += nBasePrt
		nAc2 += nComPrt
		nAc3 += nVlrTitulo
		li++
		dbSkip()
	EndDo
	
	If (nAc1+nAc2+nAc3) != 0
		li++
		
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		
		@ li, 00  PSAY OemToAnsi(STR0013)  //"TOTAL DO VENDEDOR --> "
		@ li,136  PSAY nAc3 	PicTure tm(nAc3,15,nDecs)
		@ li,152  PSAY nAc1 	PicTure tm(nAc1,15,nDecs)
		
		If nAc1 != 0
			@ li, 169 PSAY (nAc2/nAc1)*100   PicTure "999.99"
		Endif
		
		@ li, 175  PSAY nAc2 PicTure tm(nAc2,15,nDecs)
		li++
		
		If mv_par01 > 0 .And. (nAc2 * mv_par01 / 100) > GetMV("MV_VLRETIR") //IR
			@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
			@ li, 175  PSAY (nAc2 * mv_par01 / 100) PicTure tm(nAc2 * mv_par01 / 100,15,nDecs)
			li ++
			@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR      --> "
			@ li, 175 PSAY nAc2 - (nAc2 * mv_par01 / 100) PicTure tm(nAc2,15,nDecs)
			li ++
		EndIf
		
		@ li, 00  PSAY __PrtThinLine()
		li := 60  
		
	EndIF
	
	dbSelectArea("SE3")
	nAg1 += nAc1
	nAg2 += nAc2
 	nAg3 += nAc3
EndDo

IF (nAg1+nAg2+nAg3) != 0
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)

	@li,  00 PSAY OemToAnsi(STR0014)  //"TOTAL  GERAL      --> "
	@li, 136 PSAY nAg3	Picture tm(nAg3,15,nDecs)
	@li, 152 PSAY nAg1	Picture tm(nAg1,15,nDecs)
	@li, 169 PSAY (nAg2/nAg1)*100														Picture "999.99"
	@li, 175 PSAY nAg2 Picture tm(nAg2,15,nDecs)
	
	If mv_par01 > 0 .And. (nAg2 * mv_par01 / 100) > GetMV("MV_VLRETIR")//IR
		li ++
		@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
		@ li, 175  PSAY (nAg2 * mv_par01 / 100) PicTure tm((nAg2 * mv_par01 / 100),15,nDecs)
		li ++
		@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR       --> "
		@ li, 175  PSAY nAg2 - (nAg2 * mv_par01 / 100) Picture tm(nAg2,15,nDecs)
	EndIf
	roda(cbcont,cbtxt,"G")
EndIF
    
#IFDEF TOP
	If TcSrvType() != "AS/400"
  		dbSelectArea("SE3")
		DbCloseArea()
		chkfile("SE3")
	Else	
#ENDIF
		fErase(cNomArq+OrdBagExt())
#IFDEF TOP
	Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE3")
RetIndex("SE3")
DbSetOrder(2)
Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()
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


