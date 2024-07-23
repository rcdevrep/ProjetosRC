#INCLUDE "AGR242.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR610  � Autor � Paulo Boschetti       � Data � 13.07.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Previs�o de Comiss�es                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR610(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��� Andreia    �05/10/98�xxxxxx� Ajuste no lay-out para ativar set Century���
��� Mauricio   �16/12/98�xxxxxx� Tratamento para RA no relatorio (Comisso-���
���            �        �      � es geradas na Ver.2.05.			           ���
��� Mauricio   �17/12/98�18751A� Considerar comissoes de Faturas na relat.���
��� Pilar      �18/02/99�      � Ajuste nos percentuais totais            ���
��� Julio      �31.03.99�20532A� Pergunta e Tratamento "Comissao Zero"    ���
��� Mauricio   �25/08/99�23470A� Corrigir calculo comissao emissao e tra- ���
���            �        �      � tar abatimentos e pagamentos j� efetuados���
��� Julio      �21.10.99�XXXXXX� Corre��o ao procurar vendedores ...      ���
��� Julio      �25.10.99�XXXXXX� Retirar AjustaSx1                        ���
��� Julio      �16.11.99�XXXXXX� Corre��o de Macro (&) p/ Protheus        ���
�������������������������������������������������������������������������Ĵ��
��� Julio W.   �16.11.99�META  � Revis�o de Fontes p/ Protheus            ���
��� Claudio    �14.07.00�004644� Respeitar o parametro MV_VALRETIR no cal-���
���            �        �      � culo do IR                               ���
���Rubens Pante�26.08/00�oooooo� Implementacao multimoeda                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function AGR242()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL wnrel
LOCAL limite  :=220
LOCAL cString :="SE1"
LOCAL cDesc1  :=OemToAnsi( STR0001 ) // "Este relatorio ir� emitir a Previs�o das"
LOCAL cDesc2  :=OemToAnsi( STR0002 ) // "Comiss�es a Serem pagas."
LOCAL cDesc3  :=""
LOCAL tamanho := "G"

PRIVATE titulo  := STR0003 //"Previsao de Comissoes"
PRIVATE cabec1
PRIVATE cabec2
PRIVATE aReturn := {	OemToAnsi(STR0004),1,OemToAnsi(STR0005),2,2,1,"",1}	//"Zebrado"### //"Administracao"
PRIVATE nomeprog:="AGR242"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="AGR242"
PRIVATE cVend   := TKOPERADOR()

cPerg   :="AGR242"
aRegistros := {}

AADD(aRegistros,{cPerg,"01","Do Vencimento     ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Ate Vencimento    ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Da Emissao        ?","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Ate Emissao       ?","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Aliquota I.Renda  ?","mv_ch5","N",5,2,0,"G","","mv_par05","","","","","","","","","","","","","","",""})


CriaPerguntas(cPerg,aRegistros)

//��������������������������������������������������������������Ŀ
//� Vari�veis utilizadas para parametros                         �
//� mv_par01         // Do Vendedor                              �
//� mv_par02         // At� o Vendedor                           �
//� mv_par03         // Vencto de                                �
//� mv_par04         // Vencto At�                               �
//� mv_par05         // Qual Moeda                               �
//� mv_par06         // Da emiss�o                               �
//� mv_par07         // At� a emiss�o                            �
//� mv_par08         // Comiss�o Zero                            �
//� mv_par09         // Considera P.Venda                        �
//� mv_par10         // Abate IR Comiss                          �
//� mv_par11         // Outras Moedas                            �
//� mv_par12         // Salta Pagina por Vendedor                �
//� mv_par13         // Do Prefixo 				                 �
//� mv_par14         // Ate o Prefixo			                 �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a fun��o SETPRINT                        �
//����������������������������������������������������������������

Pergunte(cPerg,.F.)               // Pergunta no SX1


wnrel:="AGR242"
wnrel:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,"",.F.)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif
RptStatus({|lEnd| Fa610Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FA610Imp � Autor � Paulo Boschetti       � Data � 13.07.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Previs�o de Comiss�es                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FA610Imp(lEnd,wnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - A��o do Codeblock                                ���
���          � wnRel   - T�tulo do relat�rio                              ���
���          � cString - Mensagem                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FA610Imp(lEnd,wnRel,cString)

LOCAL CbTxt,CbCont
LOCAL tamanho :="G"
LOCAL aCampos :={}
LOCAL cVendAnt:=Space(6)
LOCAL aTotComSE3:=ARRAY(2)
LOCAL nComissao:=0.00
LOCAL nVlrTitulo:=0.00
LOCAL nValTit :=0.00
LOCAL nComEnt :=0.00
LOCAL nComVen :=0.00
LOCAL nValBas :=0.00
LOCAL nPorc   :=0.00
LOCAL nVendComis :=0.00
LOCAL nTotTit :=0.00
LOCAL nTotEnt :=0.00
LOCAL nTotVen :=0.00
LOCAL nTotBas :=0.00
LOCAL nTotComis :=0.00
LOCAL lFirst:=.T.
LOCAL lPVen := .F.		// Flag diferenciador de pedido de venda
LOCAL aParcelas := {}	// Array das comissoes (geral)
LOCAL aParcItem := {}	// Array das comissoes (item)	
LOCAL nVendSC5 := 0		// Codigo do vendedor no pedido
LOCAL nComiSC5 := 0		// Percentual Comissao no pedido
LOCAL nComiSC6 := 0		// Percentual comissao no item do pedido
LOCAL nPerComE := 0		// Percentual comissao na emissao vendedor
LOCAL nPerComB	:= 0		// Percentual comissao na Baixa vendedor
LOCAL nRegSC6	:= 0		// Registro do item de pedido
LOCAL nQtdItem := 0		// Quantidade de produtos nao entregues
LOCAL nPercItem:= 0		// Percentual a ser usado (pedido ou item)
LOCAL nVlTotPed:= 0		// Valor total do pedido nao entregue
LOCAL nIrEnt	:= 0		// Ir na Emissao
LOCAL nIrVen	:= 0		// Ir na Baixa
LOCAL nVendIr	:= 0		// total de Ir do vendedor
LOCAL nTotIrE	:= 0		// Total geral de IR na emissao
LOCAL nTotIrB	:= 0		// Total geral de IR na Baixa
LOCAL nTotIrVen:= 0		// Total geral de IR do relatorio
LOCAL nTotPorc := 0		// Percentual medio de comissoes do relatorio
LOCAL nTotCount:= 0
LOCAL nCount	:= 0
LOCAL nTotAbat := 0
LOCAL aTam		:= {}
LOCAL aColu		:= {}
LOCAL nValMinRet := 0   // Valor minimo para retencao do IR
Local nMoedaBco :=1, dDataConv
Local cTipo
Local cParcela
Local cPrefixo
Local cNum
Local cTipoFat

Private nDecs   := MsDecimais(1)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

//��������������������������������������������������������������Ŀ
//� Define array para arquivo de trabalho                        �
//����������������������������������������������������������������
aTam:=TamSX3("E1_VEND1")
AADD(aCampos,{ "CODIGO" ,"C",aTam[1],aTam[2] } )
AADD(aCampos,{ "CHAVE"  ,"N",6,0 } )
AADD(aCampos,{ "NVEND"  ,"N",01,0 } )
AADD(aCampos,{ "PVEND"  ,"C",01,0 } )

aTam := TamSX3("E1_CLIENTE")

//��������������������������������������������������������������Ŀ
//� Cria arquivo de Trabalho                                     �
//����������������������������������������������������������������
cNomArq := CriaTrab(aCampos)
dbUseArea( .T.,, cNomArq, "Trb", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("TRB",cNomArq,"CODIGO",,,OemToAnsi(STR0023))

//��������������������������������������������������������������Ŀ
//� Defini��o dos cabe�alhos                                     �
//����������������������������������������������������������������
titulo+=  OemToAnsi(STR0022)+GetMV("MV_MOEDA"+Str(1,1))
cabec1:= IIF(aTam[1] > 6, STR0017,STR0006) // "PRF TITULO       P CODIGO               LJ   NOME                 DATA DE    DATA               VALOR      COMISSAO      COMISSAO    VALOR BASE %COMIS   VALOR TOTAL P/T"###"PRF NUMERO       P CODIGO  LJ NOME      DATA DE  DATA           VALOR          COMISSAO        COMISSAO    VALOR BASE  %COMIS  VALOR TOTAL"
cabec2:= IIF(aTam[1] > 6, STR0018,STR0007) // "    PEDIDO         CLIENTE                                        EMISSAO    VENCTO            TITULO     P/EMISSAO       P/BAIXA      P/ BAIXA  TOTAL   DA COMISSAO    "### "    TITULO         CLIENTE              EMISSAO  VENCTO         TITULO         P/EMISSAO       P/BAIXA     P/ BAIXA    TOTAL   DA COMISSAO"

dbSelectarea("TRB")
dbSetOrder(1)
dbGoTop()

dbSelectarea("SE1")
dbsetOrder(7)

SetRegua(Reccount())
dbSeek(cFilial+DtoS(mv_par01),.T.)

While !Eof() .and. cFilial == E1_FILIAL .and. E1_VENCREA <= mv_par02
	lPVen := .F.
	
	IF lEnd
		@PROW()+1,001 PSAY STR0008 // "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	IncRegua()
	
	If E1_TIPO $ MVABATIM
		dbSkip()
		Loop
	Endif


	If ( E1_SALDO == 0  .and. Empty(SE1->E1_FATURA) ) .or. SE1->E1_FATURA == "NOTFAT"
		dbSkip()
		Loop
	Endif
	
	If E1_EMISSAO < mv_par03 .or. E1_EMISSAO > mv_par04
		dbSkip()
		Loop
	Endif

	// Incluido por Valdecir em 05.03.02.
	// Necessario este filtro, pois o programa nao estava diferenciando na impressao as filiais.
	If E1_PREFIXO <> "011" .And. E1_PREFIXO <> "021"
		dbSkip()
		Loop
	EndIf

	// Despreza registros de outra moeda se escolhido nao imprimir
	If 1 == 2 .AND. E1_MOEDA != 1 
		dbSkip()
		Loop
	Endif
	
	For JX:=1 TO 5
		nx := Str(JX,1)
		IF !EMPTY(E1_VEND&nx.)
			If E1_VEND&nx. >= cVend .and. E1_VEND&nx. <= cVend
				GravaCom(nX,lPVen)
			End
		End
	Next
	dbSkip()
Enddo

//��������������������������������������������������������������Ŀ
//� Verifica se considera pedidos de venda                       �
//����������������������������������������������������������������
If 2 == 1  // Considera Ped. Venda
	lPVen := .T.
	dbSelectarea("SC5")
	dbsetOrder(2)
	SetRegua(Reccount())
	dbSeek(cFilial+DtoS(mv_par01),.T.)
	While !Eof() .and. cFilial == C5_FILIAL .and. C5_EMISSAO <= mv_par02
		IF lEnd
			@PROW()+1,001 PSAY STR0008 // "CANCELADO PELO OPERADOR"
			Exit
		Endif
		IncRegua()
		If C5_EMISSAO < mv_par03 .or. C5_EMISSAO > mv_par04
			dbSkip()
			Loop
		Endif
		For JX:=1 TO 5  // grava vendedores no arq TRB
			nx := Str(JX,1)
			IF !EMPTY(C5_VEND&nx.)
				If C5_VEND&nx. >= cVend .and. C5_VEND&nx. <= cVend
					GravaCom(nX,lPVen)
				End
			End
		EndFor
		dbSkip()
	Enddo
Endif

dbSelectarea("TRB")
dbGotop()
SetRegua(RecCount())

While !Eof()
	
	lFirst  := .T.
	cVendAnt:= CODIGO
	nCount	:= 0
	While !Eof() .and. cVendAnt == CODIGO
		IF lEnd
			@PROW()+1,001 PSAY STR0008 // "CANCELADO PELO OPERADOR"
			Exit
		Endif
		IncRegua()
		nComissao := 0
		//��������������������������������������������������������������Ŀ
		//� Verifica se a previsao sera calculada por titulo ja gerado   �
		//� ou pedido de vendas.                                         �
		//����������������������������������������������������������������
		If TRB->PVEND == "N"		
			dbSelectArea("SE1")
			dbSetOrder(1)
			dbGOTO(TRB->CHAVE)
			//��������������������������������������������������������������Ŀ
			//� Calculo Bases, valores e percentuais de comissao.            �
			//� Constituicao de aBases{} retornada por FA440COMIS()          �
			//� Coluna 01    Vendedor        	       		                 �
			//� Coluna 02    Valor do Titulo    		                       �
			//� Coluna 03    Base Comissao Emissao			                    �
			//� Coluna 04    Base Comissao Baixa	                          �
			//� Coluna 05    Comissao Emissao										  �
			//� Coluna 06    Comissao Baixa                                  �
			//� Coluna 07    % Total da comissao                             �
			//����������������������������������������������������������������
			aBases   := Fa440Comis(SE1->(Recno()),.F.,.T.)
			nBases 	:= aScan(aBases,{|x| x[1] == TRB->CODIGO })
			If nBases = 0
				//������������������������������������������������Ŀ
				//� Caso vendedor n�o seja encontrado...           �
				//��������������������������������������������������
				dbSelectArea("TRB")
				dbSkip()
				LOOP
			Endif
			aBases[nBases][2]	:=	SE1->E1_VLCRUZ
			cChaveSE3 := aBases[nBases,1]+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)
			cTipo 	 := SE1->E1_TIPO
			cParcela	 := SE1->E1_PARCELA
			If !Empty(SE1->E1_FATURA) .And. SE1->E1_FATURA != "NOTFAT"
	         cTipoFat	:= SE1->E1_TIPOFAT
  				// Localiza o titulo de fatura, pois no SE3 eh gerado o titulo de fatura
            // para verificar as comissoes que ja foram pagas.
	         SE1->(MsSeek(xFilial("SE1")+E1_FATPREF+E1_FATURA)) // Localiza o titulo de
              																	 // fatura
            cPrefixo := SE1->E1_PREFIXO
	         cNum	   := SE1->E1_NUM
            // Processar todas as parcelas da fatura gerada e verificar se a comissao
            // para a parcela nao foi paga.
	         While xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM) == xFilial("SE1")+cPrefixo+cNum .And.;
            		SE1->(!Eof())
            	If SE1->E1_TIPO == cTipoFat
	   	         //��������������������������������������������������������������Ŀ
		            //� Verificar comissoes ja pagas                                 �
	            	//����������������������������������������������������������������
	            	cChaveSE3 := aBases[nBases,1]+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)
	            	cTipo 	 := SE1->E1_TIPO
						cParcela	 := SE1->E1_PARCELA
	            	FA610ComPg(@aBases,cChaveSE3,nBases,cTipo,cParcela)
	            Endif	
            	SE1->(DbSkip())
            End
				dbGOTO(TRB->CHAVE)
			Else
				FA610ComPg(@aBases,cChaveSE3,nBases,cTipo,cParcela)
			Endif
			//��������������������������������������������������������������Ŀ
			//� Verificar abatimentos dos titulos                            �
			//����������������������������������������������������������������
			nTotAbat := SumAbatRec(SE1->E1_PREFIXO, SE1->E1_NUM,SE1->E1_PARCELA,;
										  SE1->E1_MOEDA,"V",dDataBase)
			If nTotAbat > 0
				SA3->(dbSeek(xFilial()+aBases[nBases,1]))
				aBases[nBases,4] -= ((aBases[nBases,4] * nTotAbat) / SE1->E1_VALOR)
				aBases[nBases,6] := (aBases[nBases,4] * (SA3->A3_ALBAIXA/100)) / SA3->A3_COMIS
			Endif

			//��������������������������������������������������������������Ŀ
			//� Caso percentual de comissao seja retornado == a zero, devo   �
			//� calcular a media (Faturamento com comissao no item <> percen-�
			//� tual do vendedor)                                            �
			//����������������������������������������������������������������
			If aBases[nBases,7] == 0
				aBases[nBases,7] := (((aBases[nBases,5]+aBases[nBases,6])*100)/aBases[nBases,2])
			Endif
			//��������������������������������������������������������������Ŀ
			//� Verifica tamanho do campo E1_CLIENTE para posicionamento das �
			//� colunas do relatorio                                         �
			//����������������������������������������������������������������
			aColu := IIF (aTam[1] > 6,;
								{000,004,017,019,040,045,066,077,088,102,116,130,144,151,166},;
								{000,004,017,019,026,029,050,061,072,086,100,114,128,135,150})

			//��������������������������������������������������������������Ŀ
			//� Imprime o Vendedor caso possa imprimir Comiss�o Zero ou      �
			//� exista alguma comiss�o para o Vendedor                       �
			//����������������������������������������������������������������
			If 2 == 1 .or. aBases[nBases,6] != 0 .Or. aBases[nBases,5] != 0 
				IF li > 55
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
				EndIF
				If lFirst
					Li++
					dbSelectArea("SA3")
					dbSeek(cFilial+TRB->CODIGO)
					@li,  0 PSAY STR0009 + TRB->CODIGO //"CODIGO : "
					@li, 16 PSAY STR0010 + SA3->A3_NOME //"NOME : "
					dbSelectArea("TRB")
					Li+=2
					lFirst := .F.
				Endif
				dbSelectArea("SE1")
				dbSetOrder(1)
				dbGOTO(TRB->CHAVE)
				
				If cPaisLoc == "BRA"
				   nMoedaBco := 1
				   dDataConv := dDataBase
				Else
				   nMoedaBco := SE1->E1_MOEDA
				   dDataConv := SE1->E1_EMISSAO
				EndIf

    			nComissao := xMoeda(aBases[nBases,5] + aBases[nBases,6],nMoedaBco,1,dDataConv,nDecs+1)
    			aBases[nBases,2] := xMoeda(aBases[nBases,2],nMoedaBco,1,dDataConv,nDecs+1)
    			aBases[nBases,4] := xMoeda(aBases[nBases,4],nMoedaBco,1,dDataConv,nDecs+1)
    			aBases[nBases,5] := xMoeda(aBases[nBases,5],nMoedaBco,1,dDataConv,nDecs+1)
    			aBases[nBases,6] := xMoeda(aBases[nBases,6],nMoedaBco,1,dDataConv,nDecs+1)

				@li, aColu[1] PSAY E1_PREFIXO
				@li, aColu[2] PSAY E1_NUM
				@li, aColu[3] PSAY E1_PARCELA
				@li, aColu[4] PSAY E1_CLIENTE
				@li, aColu[5] PSAY E1_LOJA
				dbSelectArea("SA1")
				dbSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
				@li, aColu[6] PSAY SubStr(A1_NREDUZ,1,20)
				dbSelectArea("SE1")
				@li, aColu[7] PSAY E1_EMISSAO
				@li, aColu[8] PSAY E1_VENCREA
				@li, aColu[9]  PSAY aBases[nBases,2]	Picture tm(aBases[nBases,2],13,nDecs)
				@li, aColu[10] PSAY aBases[nBases,5]	Picture tm(aBases[nBases,5],13,nDecs)
				@li, aColu[11] PSAY aBases[nBases,6]	Picture tm(aBases[nBases,6],13,nDecs)
				@li, aColu[12] PSAY aBases[nBases,4]	Picture tm(aBases[nBases,4],13,nDecs)
				@li, aColu[13] PSAY aBases[nBases,7]	Picture "999.99"
				@li, aColu[14] PSAY nComissao			Picture tm(nComissao,13,nDecs)
				@li, aColu[15] PSAY "T"     // identificador de Titulo ou Pedido
				li++
            nValMinRet := GetMv( "MV_VLRETIR" )
				nValTit		+= aBases[nBases,2]
				nComEnt		+= aBases[nBases,5]
				nIrEnt		+= If(aBases[nBases,2] > nValMinRet,aBases[nBases,5] * (mv_par05/100),0)
				nComVen		+= aBases[nBases,6]
				nIrVen		+= If(aBases[nBases,2] > nValMinRet, aBases[nBases,6] * (mv_par05/100),0)
				nValBas		+= aBases[nBases,4]
				nPorc		+= aBases[nBases,7]
				nVendComis	+= nComissao
				nVendIr		+= If(aBases[nBases,2] > nValMinRet,(aBases[nBases,5]+aBases[nBases,6])* (mv_par05/100),0)
				nCount++
			EndIf
		Else
			// calculo das comissoes p/ pedido venda
			dbSelectArea("SC5")
			dbSetOrder(1)
			DbGoto(TRB->CHAVE)

			nComissao	:= 0
			nVlTotPed	:= 0
			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek(xFilial("SC6")+SC5->C5_NUM)
				aParcelas	:= {}
				nVendSC5		:= SC5->(FieldPos("C5_VEND"+STR(TRB->NVEND,1)))
				nComiSC5		:= SC5->(FieldPos("C5_COMIS"+STR(TRB->NVEND,1)))
				nComiSC6		:= SC6->(FieldPos("C6_COMIS"+STR(TRB->NVEND,1)))
				dbSelectArea("SA3")
				dbSeek(xFilial("SA3")+SC5->(FieldGet(nVendsc5)))
				nPerComE		:= (SA3->A3_ALEMISS/100)
				nPerComB		:= (SA3->A3_ALBAIXA/100)
				dbSelectArea("SC6")
				nRegSC6 := Recno()
				// valor de nao entregues total no pedido
				bAcao:= {|| nVlTotPed += SC6->(C6_PRCVEN * (C6_QTDVEN - C6_QTDENT))}
				dbEval(bAcao,,{||!Eof() .and. SC6->C6_NUM == SC5->C5_NUM},,,.T.)
				dbGoto(nRegSC6)
				//��������������������������������������������������������������Ŀ
				//� Constituicao de aParcelas{}				                       �
				//� Coluna 01    Data Vencto da Parcela			                 �
				//� Coluna 02    Valor da Parcela			                       �
				//� Coluna 03    Valor Comissao Emissao		                    �
				//� Coluna 04    Valor Comissao Baixa                            �
				//� Coluna 05    Base da Baixa                                   �
				//� Coluna 06    % Total da comissao                             �
				//����������������������������������������������������������������
				aParcelas := Condicao (nVlTotPed,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
				aEval(aParcelas,{|elem| aadd(elem,0),aadd(elem,0),aadd(elem,0),aadd(elem,0)})
				dbSelectArea("SC6")
				While !Eof() .and. SC6->C6_NUM == SC5->C5_NUM
					If SC6->C6_QTDENT >= SC6->C6_QTDVEN .Or.;
						!Empty(SC6->C6_BLOQUEI)          .Or.;
						Left(SC6->C6_BLQ,1) $ "RS"
						dbskip()
						Loop
					Endif
					nQtdItem := SC6->(C6_QTDVEN - C6_QTDENT)  // Qtde nao entregue
					nBasItem := SC6->(C6_PRCVEN * nQtdItem) 	// Valor ref. nao entregue
					nPercItem:= IIF(SC6->(FieldGet(nComiSC6))== 0,;
										 SC5->(FieldGet(nComiSC5)),	 ;	// Percentual no Pedido
										 SC6->(FieldGet(nComiSC6)))		// Percentual no Item
					aParcItem:= Condicao(nBasItem,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
					dbSelectArea("SC6")
					For nCond := 1 to Len(aParcItem)
						aParcelas[nCond,3] += ((aParcItem[nCond,2] * (nPercItem/100)) * nPerComE)
						aParcelas[nCond,4] += ((aParcItem[nCond,2] * (nPercItem/100)) * nPerComB)
						aParcelas[nCond,5] += (aParcItem[nCond,2] * nPerComB)
					Next
					dbskip()
				Enddo
				For nCond := 1 to	Len(aParcelas)
					aParcelas[nCond,6] += (((aParcelas[nCond,3]+aParcelas[nCond,4]) * 100) / aParcelas[nCond,2])
					nComissao += (aParcelas[nCond,3]+aParcelas[nCond,4])
				Next
				//������������������������������������������������������Ŀ
				//� Verifica tamanho do campo C5_CLIENTE para posiciona- �
				//� mento das colunas do relatorio                       �
				//��������������������������������������������������������
				aColu := IIF (aTam[1] > 6,;
									{000,004,017,019,040,045,066,077,088,102,116,130,144,151,166},;
									{000,004,017,019,026,029,050,061,072,086,100,114,128,135,150})
		
				// impressao das previsoes de comiss do ped venda
				If ( nComissao != 0 )
					IF li > 55
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
					EndIF
					If lFirst
						Li++
						@li,  0 PSAY STR0009 + TRB->CODIGO //"CODIGO : "
						@li, 16 PSAY STR0010 + SA3->A3_NOME //"NOME : "
						dbSelectArea("TRB")
						Li+=2
						lFirst := .F.
					Endif
					dbSelectArea("SC5")
					dbSetOrder(1)
					dbGOTO(TRB->CHAVE)
					
					If cPaisLoc == "BRA"
					   nMoedaBco := 1
					   dDataConv := dDataBase
					Else
					   nMoedaBco := SC5->C5_MOEDA
					   dDataConv := SC5->C5_EMISSAO
					Endif
		
					For nCond := 1 to Len(aParcelas)
						If aParcelas[nCond,1] > mv_par01 .and.  ;
							aParcelas[nCond,1] < mv_par02

							aParcelas[nCond,2] := xMoeda(aParcelas[nCond,2],nMoedaBco,1,dDataConv,nDecs+1)
							aParcelas[nCond,3] := xMoeda(aParcelas[nCond,3],nMoedaBco,1,dDataConv,nDecs+1)
							aParcelas[nCond,4] := xMoeda(aParcelas[nCond,4],nMoedaBco,1,dDataConv,nDecs+1)
							aParcelas[nCond,5] := xMoeda(aParcelas[nCond,5],nMoedaBco,1,dDataConv,nDecs+1)
				
							@li, aColu[2] PSAY C5_NUM
							@li, aColu[3] PSAY Str(nCond,1)
							@li, aColu[4] PSAY C5_CLIENTE
							@li, aColu[5] PSAY C5_LOJACLI
							dbSelectArea("SA1")
							dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
							@li, aColu[6] PSAY SubStr(A1_NREDUZ,1,20)
							dbSelectArea("SC5")
							@li, aColu[7] PSAY C5_EMISSAO
							@li, aColu[8] PSAY aParcelas[nCond,1]
							@li, aColu[9]  PSAY aParcelas[nCond,2] Picture tm(aParcelas[nCond,2],13,nDecs)
							@li, aColu[10] PSAY aParcelas[nCond,3] Picture tm(aParcelas[nCond,3],13,nDecs)
							@li, aColu[11] PSAY aParcelas[nCond,4] Picture tm(aParcelas[nCond,4],13,nDecs)
							@li, aColu[12] PSAY aParcelas[nCond,5] Picture tm(aParcelas[nCond,5],13,nDecs)
							@li, aColu[13] PSAY aParcelas[nCond,6] Picture "999.99"
							@li, aColu[14] PSAY aParcelas[nCond,3]+aParcelas[nCond,4] ;
							                Picture tm(aParcelas[nCond,3]+aParcelas[nCond,4],13,nDecs)
							@li, aColu[15] PSAY "P"     // identificador de Titulo ou Pedido

							li++
							nValMinRet := GetMv( "MV_VLRETIR" )
							nValTit		+= aParcelas[nCond,2]
							nComEnt		+= aParcelas[nCond,3]
							nIrEnt		+= If(aParcelas[nCond,2] > nValMinRet, aParcelas[nCond,3] * (mv_par05/100),0)
							nComVen		+= aParcelas[nCond,4]
							nIrVen		+= If(aParcelas[nCond,2] > nValMinRet, aParcelas[nCond,4] * (mv_par05/100),0)
							nValBas		+= aParcelas[nCond,5]
							nPorc		+= aParcelas[nCond,6]
							nVendComis	+= aParcelas[nCond,3]+aParcelas[nCond,4]
							nVendIr		+= If(aParcelas[nCond,2] > nValMinRet, aParcelas[nCond,3]+aParcelas[nCond,4] * (mv_par05/100),0)
							nCount++
						Endif
					Next
				Endif
			Endif
		EndIf
		dbSelectArea("TRB")
		dbSkip()
	End
	nTotTit  +=nValTit
	nTotEnt  +=nComEnt
	nTotIrE  +=nIrEnt
	nTotVen  +=nComVen
	nTotIrB  +=nIrVen
	nTotBas  +=nValBas
	nTotComis+=nVendComis
	nTotIrVen+=nVendIr
	nTotPorc += nPorc	
	nTotCount+= nCount
	If (nVendComis <> 0 .or. nTotCount > 0) .or. 2 == 1
		ImpSub610(nValTit,nComEnt,nComVen,nValBas,nPorc,nVendComis,nIrEnt,;
						nIrVen,nVendIr,nCount,aColu)
	Endif
	nValTit		:= 0.00
	nComEnt		:= 0.00
	nIrEnt		:= 0.00
	nComVen		:= 0.00
	nIrVen		:= 0.00
	nValBas		:= 0.00
	nPorc 		:= 0
	nVendComis 	:= 0.00
	nVendIr		:= 0.00
	If 1 == 1
		li := 80
	Endif
Enddo
If nTotComis <> 0
	ImpTot610(nTotTit,nTotEnt,nTotVen,nTotBas,nTotComis,nTotIrE,;
					nTotIrB,nTotIrVen,nTotPorc,nTotCount,aColu)
Endif
IF li != 80
	li++
	roda(cbcont,cbtxt,"G")
End

dbSelectarea("Trb")
dbCloseArea( )
Ferase(cNomArq+GetDBExtension())         //arquivo de trabalho
Ferase(cNomArq+OrdBagExt())    //indice gerado

dbSelectArea("SE3")
dbSetOrder(1)
DbSelectarea("SE1")
DbsetOrder(1)
dbClearFilter(NIL)
Set Device To Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GRAVACOM � Autor �  Paulo Boschetti      � Data � 13.07.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Arquivo de Trabalho                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GRAVACOM(void)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function GRAVACOM(nX,lPVen)
LOCAL cVend :=""
Local cAlias := Alias()

dbSelectarea("TRB")
RecLock("TRB",.T.)
cVend := IIf(lPVen,"SC5->C5_VEND","SE1->E1_VEND")+nX
Replace CODIGO With &cVend
Replace CHAVE  With &(cAlias+"->(RECNO())")
Replace NVEND  With VAL(nX)
Replace PVEND  With IIF(lPVen,"S","N")
MsUnlock()
DbSelectarea(cAlias)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPSUB610� Autor �  Paulo Boschetti      � Data � 13.07.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Sub-Total                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpSub610(void)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpSub610(nValTit,nComEnt,nComVen,nValBas,nPorc,nVendComis,nIrEnt,nIrVen,nVendIr,nCount, aColu)

If mv_par05 > 0  // Aliquota IRRF
	Li++

	@li, aColu[1]  PSAY STR0013  //"SUBTOTAL DO VENDEDOR --->"
	@li, aColu[9]  PSAY nValTit          Picture tm(nValTit,13,nDecs)
	@li, aColu[10] PSAY nComEnt          Picture tm(nComEnt,13,nDecs)
	@li, aColu[11] PSAY nComVen          Picture tm(nComVen,13,nDecs)
	@li, aColu[12] PSAY nValBas		  Picture tm(nValBas,13,nDecs)
	@li, aColu[13] PSAY nPorc/nCount	  Picture "999.99"
	@li, aColu[14] PSAY nVendComis       PicTure tm(nVendComis,13,nDecs)
	Li++
	@li, aColu[1]  PSAY STR0014  //"TOTAL IR VENDEDOR    --->"
	@li, aColu[10] PSAY nIrEnt				Picture tm(nIrEnt,13,nDecs)
	@li, aColu[11] PSAY nIrVen				Picture tm(nIrVen,13,nDecs)
	@li, aColu[13] PSAY mv_par05   		Picture "999.99"
	@li, aColu[14] PSAY nVendIr			PicTure tm(nVendIr,13,nDecs)
Endif

Li++
@li, aColu[1]  PSAY STR0011 // "TOTAL DO VENDEDOR    --->"
@li, aColu[9]  PSAY nValTit          Picture tm(nValTit,13,nDecs)
@li, aColu[10] PSAY nComEnt          Picture tm(nComEnt,13,nDecs)
@li, aColu[11] PSAY nComVen          Picture tm(nComVen,13,nDecs)
@li, aColu[12] PSAY nValBas		  Picture tm(nValBas,13,nDecs)
@li, aColu[13] PSAY nPorc/nCount	  Picture "999.99"
@li, aColu[14] PSAY nVendComis       PicTure tm(nVendComis,13,nDecs)
Li++
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPTOT610� Autor �  Paulo Boschetti      � Data � 13.07.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Total De Comiss�es                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpTot610(void)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ImpTot610(nTotTit,nTotEnt,nTotVen,nTotBas,nTotComis,nTotIrE,;
									nTotIrB,nTotIrVen,nTotPorc,nTotCount,aColu)

Li++
If mv_par05 > 0  // Aliquota IRRF
	Li++

	@li, aColu[1]  PSAY STR0015   //"SUBTOTAL GERAL    --->"
	@li, aColu[9]  PSAY nTotTit			Picture tm(nTotTit,13,nDecs)
	@li, aColu[10] PSAY nTotEnt 	        Picture tm(nTotEnt,13,nDecs)
	@li, aColu[11] PSAY nTotVen    	    Picture tm(nTotVen,13,nDecs)
	@li, aColu[12] PSAY nTotBas		   	Picture tm(nTotBas,13,nDecs)
	@li, aColu[13] PSAY nTotPorc/nTotCount	Picture "999.99"
	@li, aColu[14] PSAY nTotComis			PicTure tm(nTotComis,13,nDecs)
	Li++
	@li, aColu[1]  PSAY STR0016  //"TOTAL GERAL IR    --->"
	@li, aColu[10] PSAY nTotIrE			Picture tm(nTotIrE,13,nDecs)
	@li, aColu[11] PSAY nTotIrB			Picture tm(nTotIrB,13,nDecs)
	@li, aColu[13] PSAY mv_par05   		Picture "999.99"
	@li, aColu[14] PSAY nTotIrVen			PicTure tm(nTotIrVen,13,nDecs)
Endif

Li++
@li, aColu[1]  PSAY STR0012  //"TOTAL  GERAL         --->"
@li, aColu[9]  PSAY nTotTit          	Picture tm(nTotTit,13,nDecs)
@li, aColu[10] PSAY nTotEnt          	Picture tm(nTotEnt,13,nDecs)
@li, aColu[11] PSAY nTotVen          	Picture tm(nTotVen,13,nDecs)
@li, aColu[12] PSAY nTotBas		    Picture tm(nTotBas,13,nDecs)
@li, aColu[13] PSAY nTotPorc/nTotCount	Picture "999.99"
@li, aColu[14] PSAY nTotComis        	PicTure tm(nTotComis,13,nDecs)
Li++

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA610COMPG� Autor � Mauricio Pequim jr    � Data � 30.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica comissoes j� pagas								        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FA610COMPG(aBases,cChaveSE3)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                         	  	              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FA610ComPg(aBases,cChaveSE3,nBases,cTipo,cParcela)
Local nBaseEm	:= 0
Local nComisEm := 0

DEFAULT cTipo    := SE1->E1_TIPO
DEFAULT cParcela := SE1->E1_PARCELA
//��������������������������������������������������������������Ŀ
//� Caso percentual de comissao seja retornado == a zero, devo   �
//� calcular a media (Faturamento com comissao no item <> percen-�
//� tual do vendedor)                                            �
//����������������������������������������������������������������
If aBases[nBases,7] == 0 
	aBases[nBases,7] := (((aBases[nBases,5]+aBases[nBases,6])*100)/aBases[nBases,2])
Endif

dbSelectArea("SE3")
dbSetOrder(3)
If dbSeek(xFilial("SE3")+cChaveSE3)
	While !Eof() .and. xFilial("SE3")== E3_FILIAL .and.;
		E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM == cChaveSE3
		If !Empty(E3_DATA) .or. E3_COMIS < 0
		   If E3_BAIEMI == "E" 
            If E3_COMIS < 0
					aBases[nBases,3] += E3_BASE
					aBases[nBases,5] += E3_COMIS
				Else
					aBases[nBases,3] -= E3_BASE
					aBases[nBases,5] -= E3_COMIS
				Endif
	   	Else
				If E3_BAIEMI == "B" .and. cTIPO+cPARCELA == SE3->E3_TIPO+SE3->E3_PARCELA .and. E3_COMIS > 0
					aBases[nBases,4] -= E3_BASE
					aBases[nBases,6] -= E3_COMIS
				Endif
		   Endif
		EndIf
		dbSkip()
	EndDo
EndIf
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

