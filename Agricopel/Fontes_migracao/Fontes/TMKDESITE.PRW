#INCLUDE "RWMAKE.CH"        
#IFNDEF DEFAULT
	#xcommand DEFAULT	<uVar1> := <uVal1> ;
						[, <uVarN> := <uValN> ] => ;
    					<uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
   						[ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]
#Endif

Static aUltResult
Static aDescEsca
#DEFINE MAXGETDAD 4096
#DEFINE MAXSAVERESULT 4096
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmkDesIte ºAutor  ³Microsiga           º Data ³  07/31/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Sugestao de desconto baseado no cadastro das REGRAS DE DESC.º±±
±±º          ³A regra de desconto deve estar cadastrada com uma data      º±±
±±º          ³final vencida para que o CALL CENTER nao imponha o calculo  º±±
±±º          ³na navegacao dos itens do Televendas                        º±±
±±º          ³                                                            º±±
±±º          ³O valor do desconto de cada produto e o calculo nos itens   º±±
±±º          ³esta sendo feito nas FUNCOES abaixo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 - Somente TELEVENDAS                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKDESITE(nLinha,cCodPro)

Local aRegrasExc:={}
Local lRet		:=.F.					                // Retorno da funcao
Local nPQtd		:= Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_QUANT"})
Local nPVrUnit	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_VRUNIT"})
Local nPVlrItem := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_VLRITEM"})
Local nPDesc 	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_DESC"})
Local nPValDesc := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_VALDESC"})
Local nPTes	    := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_TES"})
Local nPValAcre := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_VALACRE"})
Local nPPrctab  := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_PRCTAB"})
Local nValDesc  := 0
Local nValUni   := 0
Local nVlrTab   := 0
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")	// Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local nCont		:= 0
Local cTesBonus := GetMv("MV_BONUSTS") 					// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]
Local nValor	:= 0 


If M->UA_OPER == "3"   // Somente Atendimento (Agenda) - Incluido por Deco 29/06/06
   Return .t.
EndIf	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica a regra da TABELA DE DESCONTOS no item      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValor := TmkRegra(1,aValores[6],0,NIL,M->UA_CONDPG)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So pode dar desconto se o Posto de venda estiver configurado para Item ou Ambos						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Desconto = Total ou Desconto = Nao
	If nValor > 0 
		Help( " ", 1, "NAO_DESCON")
		aCols[nLinha][nPDesc] := 0
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O valor de deconto (%) nao pode ser maior ou igual a 100%  			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValor >= 100
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc] := 0
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no preco de tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab] + ( aCols[nLinha][nPValAcre] / aCols[nLinha][nPQtd] )
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

aCols[nLinha][nPDesc]:= nValor
nValUni 			 := A410Arred(nVlrTab * (1-(nValor/100)),"UB_VRUNIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda do operador estiver com preco fiscal bruto = NAO  ³
//³o valor unitario do produto sera recalculado com desconto 		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(cPrcFiscal) == "2"  //NAO
	aCols[nLinha][nPVrUnit] := nValUni
//	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM") Comentado por Valdecir em 16.02.05
	aCols[nLinha][nPVlrItem]:= Round(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],4)
	aCols[nLinha][nPValDesc]:= A410Arred(aCols[nLinha][nPQtd]*nVlrTab,"UB_VALDESC") - aCols[nLinha][nPVlrItem]
Else
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]:= aCols[nLinha][nPVlrItem] - A410Arred(aCols[nLinha][nPQtd]*nValUni,"UB_VALDESC")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Jogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		For nCont := 1 To Len(aCols)
			If !aCols[nCont][Len(aHeader)+1]		// Se a linha for valida
				aValores[DESCONTO] += aCols[nCont][nPValDesc]
			Endif	
		Next nCont
	Endif
	aValores[1]:= MaFisRet(,"NF_VALMERC")
	aValores[6]:= MaFisRet(,"NF_TOTAL")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O desconto nao pode ser maior que o valor de Tabela		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPValDesc] >= (aCols[nLinha][nPPrcTab]*aCols[nLinha][nPQtd]) .AND. nValor > 0
	Help(" ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPValDesc]:= 0
	Return(lRet)
Endif

lRet := .T.

// Atualiza o Rodape

If nValor > 0 
	TMKTrigger("UB_VLRITEM")
Endif

Return(nValor)

                              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKREGRA  ºAutor  ³Microsiga           º Data ³  07/31/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Procura pela regra de desconto do produto selecionado na   º±±
±±º          ³ GetDados                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 - Somente Televendas                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TmkRegra(nTipo,nTotDoc,nDescCab,aRegrasExc,cCodPagto)

Local aArea     := GetArea()
Local nDesconto := 0
Local nPosProd  := 0
Local nPQtdVen  := 0
Local nPDescont := 0

If nTipo == 1 //Item do TELEVENDAS
	If ACO->(MsSeek(xFilial("AC0")))
		nPosProd  := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_PRODUTO"})
		nPQtdVen  := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_QUANT"})
		nDesconto := TmkDesconto(aCols[n][nPosProd],M->UA_CLIENTE,M->UA_LOJA,M->UA_TABELA,aCols[n,nPQtdVen],cCodPagto,,1,,aRegrasExc)
	Else
		nPDescont := Ascan(aHeader,{|x| Alltrim(x[2]) == "UB_DESCONT"})
		If nPDescont <> 0
			nDesconto := aCols[n][nPDescont]
		Endif
	Endif
Endif

RestArea(aArea)
Return(nDesconto)
                 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmkDesconto³ Autor ³Microsiga             ³ Data ³29/07/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de avaliacao da regra de desconto para os modulos    ³±±
±±³          ³que possuem pedido de venda                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Produto                                              ³±±
±±³          ³ExpC2: Cliente                                              ³±±
±±³          ³ExpC3: Loja                                                 ³±±
±±³          ³ExpC4: Tabela                                               ³±±
±±³          ³ExpN5: Faixa de desconto                                    ³±±
±±³          ³ExpC6: Condicao de Pagamento                                ³±±
±±³          ³ExpC7: Forma de Pagamento                                   ³±±
±±³          ³ExpN8: Tipo de Desconto                                     ³±±
±±³          ³       1 - Desconto por Item                                ³±±
±±³          ³       2 - Desconto por Total                               ³±±
±±³          ³ExpA8: Array contendo a seguinte estrutura :                ³±±
±±³          ³       [n][1] : Codigo do produto                           ³±±
±±³          ³       [n][2] : Grupo  do produto                           ³±±
±±³          ³       [n][3] : Quantidade                                  ³±±
±±³          ³       Devem ser passados tods os produtos e as suas Qtdes. ³±±
±±³          ³       para ocalculo de descontos escalaveis.               ³±±
±±³          ³ExpA9: Array contendo as regras que NAO devem ser considera-³±±
±±³          ³       das.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Percentual de Desconto da Regra                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar a regra de descontos  ³±±
±±³          ³conforme os parametros da rotina                            ³±±
±±³          ³MESMO FORA DA DATA DA VALIDADE                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TmkDesconto(cProduto,cCliente,cLoja,cTabPreco,nFaixa,cCondPg,cFormPg,nTipo,aProds,aExc)

Static nRegPrior
Static aPesq

Local aArea     := GetArea()
Local aComp		:= {}
Local aCodReg   := {}
Local cPesq     := ""
Local cCampo    := ""
Local cCaracter := ""
Local cSeek     := ""
Local cCompara  := ""
Local cQuery    := ""
Local cKeySql   := ""
Local cAliasQry := ""
Local nDesconto := 0
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local nW        := 0
Local lValido   := .F.
Local nOrdIndex := 0
Local nQuantTot := 0
Local lExistCpo := ACO->(FieldPos("ACO_GRPVEN")) > 0
Local aDescontos:= {}
Local cPeso	    :=	""
Local lExistEsca:=	(ACO->(FieldPos('ACO_ESCALA'))*ACO->(FieldPos('ACO_LOTE')) > 0).AND.	GetNewPar("MV_DESCLOT",.F.)
Local nDescs	:=	0
Local cCnt		:=	""
Local aCpos		:=	{}
Local nCntFor	:=	1

If ACO->(Reccount()) > 0
	If Type("nStack")=="U"
		PRIVATE nStack := 1
		PRIVATE cUltRegra := ""
	Else
		nStack++
	Endif
	
	DEFAULT cProduto  := Space(Len(SB1->B1_COD))
	DEFAULT cCliente  := Space(Len(SA1->A1_COD))
	DEFAULT cLoja     := Space(Len(SA1->A1_LOJA))
	DEFAULT cTabPreco := Space(Len(DA0->DA0_CODTAB))
	DEFAULT cCondPg   := Space(Len(DA0->DA0_CONDPG))
	DEFAULT cFormPg   := Space(Len(ACO->ACO_FORMPG))
	DEFAULT nFaixa    := 0
	DEFAULT nTipo     := 1
	DEFAULT nRegPrior := GetMV("MV_REGDPRI")
	DEFAULT aUltResult:= {}
	DEFAULT aPesq     := {}
		
	nX := Ascan(aUltResult,{|x| (nTipo == 2 .OR. x[1] == cProduto) 	.AND.;
												 x[2] == cCliente 	.AND.;
												 x[3] == cLoja 		.AND.;
												 x[4] == cTabPreco 	.AND.;
												 x[5] == nFaixa 	.AND.;
												 x[6] == cCondPg 	.AND.;
												 x[7] == cFormPg 	.AND.;
												 x[8] == nTipo 		.AND.;
												 x[12]== cFilAnt})
	DbSelectArea("ACO")
	DbSetorder(1)
	If (nX == 0) .OR. (Ascan(aExc,aUltResult[nX][10]) > 0) .OR. (!Empty(aUltResult[nX][10]) .AND. MsSeek(xFilial("ACO")+aUltResult[nX][10]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificar a ordem de pesquisa da Regra de Desconto                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("ACO")
		DbSetOrder(nRegPrior)
		If Empty(aPesq)
			cPesq := IndexKey()
			nY := Len(cPesq)+1
			For nX := 1 To nY
				cCaracter := SubStr(cPesq,nX,1)
				If ( cCaracter == "+" .OR. nX == nY )
					aadd(aPesq,AllTrim(cCampo))
					cCampo := ""
				Else
					cCampo += cCaracter
				Endif
			Next nX
		Endif
	
		nY := Len(aPesq)
	
		For nX := 1 To nY
			Do Case
				Case Len(aPesq)<nX
					
				Case aPesq[nX] == "ACO_CODCLI"
					aadd(aComp,cCliente)
					cKeySql += "+"+aPesq[nX]
					
				Case aPesq[nX] == "ACO_LOJA"
					aadd(aComp,cLoja)
					cKeySql += "+"+aPesq[nX]
					
				Case aPesq[nX] == "ACO_FILIAL"
					aadd(aComp,xFilial("ACO"))
					cKeySql += "+"+aPesq[nX]
					
				Case aPesq[nX] == "ACO_CODTAB"
					aadd(aComp,cTabPreco)
					cKeySql += "+"+aPesq[nX]
					
				Case aPesq[nX] == "ACO_CONDPG"
					aadd(aComp,cCondPg)
					cKeySql += "+"+aPesq[nX]
					
				Case aPesq[nX] == "ACO_FORMPG"
					aadd(aComp,cFormPg)
					cKeySql += "+"+aPesq[nX]
					
				OtherWise
					aPesq := aDel(aPesq,nX)
					aPesq := aSize(aPesq,Len(aPesq)-1)
					nX--
					nY--
			EndCase
		Next nX
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retira os campos da ordem para encontrar os descontos genericos         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := nY To 2 STEP -1
			
			#IFDEF TOP
				cAliasQry := "MARGRDESC"
				
				cQuery := "SELECT ACO.ACO_PERDES "
				cQuery += "DESCONTO , ACO_CODREG"
				If lExistEsca
					cQuery += ", ACO_ESCALA"
				Endif
	
				If lExistCpo
					cQuery += ", ACO_GRPVEN"
				Endif
	
				If ACO->(FieldPos("ACO_DATDE")) * ACO->(FieldPos("ACO_DATATE")) * ACO->(FieldPos("ACO_HORADE")) * ;
					ACO->(FieldPos("ACO_HORATE")) * ACO->(FieldPos("ACO_TPHORA"))  > 0
					cQuery	+=	",ACO_DATDE,ACO_DATATE,ACO_HORADE,ACO_HORATE,ACO_TPHORA "
					aCpos	:=	{ {'ACO_DATDE',"D",8,0},{'ACO_DATATE',"D",8,0}}
				Endif
	
				cQuery += "FROM "+RetSqlName("ACO")+" ACO "
	
				If nTipo == 1
					cQuery += ", " + RetSqlName("ACP")+" ACP "
				Endif
	
				cQuery += "WHERE ACO.ACO_FILIAL='"+xFilial("ACO")+"' AND "
				cQuery += "(ACO.ACO_CODCLI='"+Space(Len(SA1->A1_COD))+"' OR ACO.ACO_CODCLI='"+cCliente+"') AND "
				cQuery += "(ACO.ACO_LOJA='"+Space(Len(SA1->A1_LOJA))+"' OR ACO.ACO_LOJA='"+cLoja+"') AND "
				cQuery += "(ACO.ACO_CODTAB='"+Space(Len(DA0->DA0_CODTAB))+"' OR ACO.ACO_CODTAB = '"+cTabPreco+"') AND "
				cQuery += "(ACO.ACO_CONDPG='"+Space(Len(DA0->DA0_CONDPG))+"' OR ACO.ACO_CONDPG='"+cCondPg+"') AND "
				cQuery += "(ACO.ACO_FORMPG='"+Space(Len(ACO->ACO_FORMPG))+"' OR ACO.ACO_FORMPG='"+cFormPg+"') AND "
				cQuery += "ACO.D_E_L_E_T_=' ' AND "
	
				If nTipo == 2
					If !lExistEsca
						cQuery += " ACO.ACO_PERDES > 0 AND "
					Endif
					cQuery += "ACO.ACO_FAIXA<="+Alltrim(StrZero(nFaixa,18,2))+" "
				Else
					cQuery += "ACP.ACP_FILIAL='"+xFilial("ACP")+"' AND "
					cQuery += "ACP.ACP_CODREG=ACO.ACO_CODREG AND "
					cQuery += "(ACP.ACP_CODPRO='"+Space(Len(SB1->B1_COD))+"' OR ACP.ACP_CODPRO='"+cProduto+"') AND "
					cQuery += "ACP.ACP_FAIXA>="+Alltrim(StrZero(nFaixa,18,2))+" AND "
					cQuery += "ACP.D_E_L_E_T_=' ' "
				Endif
	
				cQuery += "ORDER BY "+StrTran(SubStr(cKeySql,2),"+"," DESC,")
				cQuery := ChangeQuery(cQuery)
				
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
				For nCntFor := 1 To Len(aCpos)
					TcSetField(cAliasQry,aCpos[nCntFor][1],aCpos[nCntFor][2],aCpos[nCntFor][3],aCpos[nCntFor][4])
				Next nCntFor
	
				While !Eof()
					If Ascan(aExc,(cAliasQry)->ACO_CODREG) == 0
						cPeso	:=	If(lExistCpo, FtIsGrpOk((cAliasQry)->ACO_GRPVEN,SA1->A1_GRPVEN),"00")
						If !Empty(cPeso)
							nDesconto := If(MARGRDESC->DESCONTO==0,-1,MARGRDESC->DESCONTO)
							If nTipo == 1 .OR. (nTipo == 2 .AND. lExistEsca .AND. (cAliasQry)->ACO_ESCALA == '1')
								If Ascan(aCodReg,{|x| x[1]==(cAliasQry)->ACO_CODREG}) == 0
									Aadd(aCodReg,{(cAliasQry)->ACO_CODREG,cPeso,IIf(lExistEsca,(cAliasQry)->ACO_ESCALA,"")})
								Endif
							Endif
							If nDesconto <> 0 .AND. !lExistCpo
								cUltRegra	:=	(cAliasQry)->ACO_CODREG
								Exit
							Else
								AAdd(aDescontos, {cPeso,StrZero(999-Len(aDescontos),3),nDesconto,(cAliasQry)->ACO_CODREG} )
							Endif
						Endif
					Endif
					DbSkip()
				End
				
				DbSelectArea("MARGRDESC")
				DbCloseArea()
				DbSelectArea("ACO")
				Exit
				
			#ELSE
				cSeek    := ""
				cCompara := ""
				For nZ := 2 To nX
					cCompara += "+"+aPesq[nZ]
					cSeek += aComp[nZ]
				Next nZ
			
				cCompara := SubStr(cCompara,2)
			
				If cSeek <> ""
					If !Empty(cSeek)
						nW++
					Endif
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetua a pesquisa do desconto                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("ACO")
					//Ordem setada acima
					MsSeek(xFilial("ACO")+cSeek,.T.)
					While !Eof() .AND. xFilial("ACO") == ACO->ACO_FILIAL .AND. cSeek == &cCompara
						cPeso	:=	 If(lExistCpo, FtIsGrpOk(ACO->ACO_GRPVEN,SA1->A1_GRPVEN) ,"00")
						If !Empty(cPeso) .AND. Ascan(aExc,ACO->ACO_CODREG) == 0
							lValido := .T.
							For nZ := 2 To nY
								If FieldGet(FieldPos(aPesq[nZ])) <> aComp[nZ] .AND. !Empty(FieldGet(FieldPos(aPesq[nZ])))
									lValido := .F.
								Endif
							Next nX

							If lValido
								If nTipo == 1 .OR. (nTipo == 2 .AND. lExistEsca .AND. ACO->ACO_ESCALA == '1')
									If Ascan(aCodReg,{|x| x[1] == ACO->ACO_CODREG}) == 0
										Aadd(aCodReg,{ACO->ACO_CODREG,cPeso,IIf(lExistEsca,ACO->ACO_ESCALA,"")})
									Endif
								Else
									IF nFaixa >= ACO->ACO_FAIXA
										nDesconto := If(ACO->ACO_PERDES==0,-1,ACO->ACO_PERDES)
										If nDesconto > 0
											cUltRegra	:=	ACO->ACO_CODREG
										Endif
										AAdd(aDescontos,{cPeso,StrZero(999-Len(aDescontos),3),nDesconto,ACO->ACO_CODREG})
									Endif
								Endif
							Else
								If ( nDesconto <> 0 .AND. nTipo == 2 ) .AND.!lExistCpo
									Exit
								Endif
							Endif

							If lValido .AND. nTipo == 2    .AND. !lExistCpo
								If nFaixa >= ACO->ACO_FAIXA
									cUltRegra	:=	ACO->ACO_CODREG
									Exit
								Endif
							Endif
						Endif

						DbSelectArea("ACO")
						DbSkip()
					End
					If ( nDesconto <> 0 .AND. nTipo == 2 ).AND.!lExistCpo
						Exit
					Endif
				Endif
			#Endif
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A ordem para escolher os descontos sera determinada pelo peso do grupo  ³
		//³de vendas mas a ordem em que foi achado                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExistCpo .AND. Len(aDescontos) > 0
			aSort(aDescontos,,,{|x,y| x[1]+x[2] > y[1]+y[2] })
			nDesconto	:=	If(aDescontos[1][3] == 0,-1,aDescontos[1][3])
			If nDesconto > 0
				cUltRegra	:=	If(aDescontos[1][3] == 0,cUltRegra,aDescontos[1][4])
			Endif
			aDescontos	:=	{}
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa o Desconto por Item                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nTipo == 1 .AND. !Empty(aCodReg) )
			For nX := 1 To Len(aCodReg)
				DbSelectArea("SB1")
				DbSetOrder(1)
				MsSeek(xFilial("SB1")+cProduto)
				DbSelectArea("ACP")
				DbSetOrder(2)
				If MsSeek(xFilial("ACP")+aCodReg[nX][1]+Space(Len(SB1->B1_GRUPO))+cProduto)
					While ( !Eof() .AND. ACP->ACP_CODREG == aCodReg[nX][1] .AND. ACP->ACP_GRUPO == Space(Len(SB1->B1_GRUPO)) .AND.	ACP->ACP_CODPRO == cProduto )
						If nFaixa <= ACP->ACP_FAIXA
							nDesconto := If(ACP->ACP_PERDES==0,-1,ACP->ACP_PERDES)
							If nDesconto <> 0 .AND.!lExistCpo
								Exit
							Else
								AAdd(aDescontos, {aCodReg[nX][2],StrZero(999-Len(aDescontos),3),nDesconto,aCodReg[nX][2]} )
							Endif
						Endif
						DbSelectArea("ACP")
						DbSkip()
					End
					If nDesconto <> 0.And.!lExistCpo
						cUltRegra	:=	ACO->ACO_CODREG
						Exit
					Endif
				Endif
				DbSelectArea("ACP")
				DbSetOrder(2)
				If MsSeek(xFilial("ACP")+aCodReg[nX][1]+SB1->B1_GRUPO)
					While ( !Eof() .AND. ACP->ACP_CODREG == aCodReg[nX][1] .AND. ACP->ACP_GRUPO == SB1->B1_GRUPO .AND. ACP->ACP_CODPRO == Space(Len(cProduto)) )
						If nFaixa <= ACP->ACP_FAIXA
							nDesconto := If(ACP->ACP_PERDES==0,-1,ACP->ACP_PERDES)
							If nDesconto <> 0 .AND. !lExistCpo
								Exit
							Else
								AAdd(aDescontos, {aCodReg[nX][2],StrZero(999-Len(aDescontos),3),nDesconto,aCodReg[nX][2]} )
							Endif
						Endif
						DbSelectArea("ACP")
						DbSkip()
					End
					If nDesconto <> 0.And.!lExistCpo
						cUltRegra	:=	aCodReg[nX][2]
						Exit
					Endif
				Endif
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A ordem para escolher os descontos sera determinada pelo peso do grupo  ³
			//³de vendas mas a ordem em que foi achado                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExistCpo .AND. Len(aDescontos) > 0
				aSort(aDescontos,,,{|x,y| x[1]+x[2] > y[1]+y[2] })
				nDesconto	:=	If(aDescontos[1][3] == 0,-1,aDescontos[1][3])
				If nDesconto > 0
					cUltRegra	:=	If(aDescontos[1][3] == 0,cUltRegra,aDescontos[1][4])
				Endif
				aDescontos	:=	{}
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa o desconto por total para o desconto escalavel                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (nTipo == 2 .AND. !Empty(aCodReg) )
			For nX := 1 To Len(aCodReg)
				If lExistEsca.And. aCodReg[nX][3] == "1"
					DbSelectArea("ACO")
					nOrdIndex:=IndexOrd()
					DbSetOrder(1)
					MsSeek(xFilial("ACO")+aCodReg[nX])
					DbSetOrder(nOrdIndex)
					DbSelectArea("ACP")
					DbSetOrder(2)
					If MsSeek(xFilial("ACP")+aCodReg[nX])
						cPeso	:=	If(lExistCpo, FtIsGrpOk(ACO->ACO_GRPVEN,SA1->A1_GRPVEN),"00")
						nQuantTot	:=	0
						While ( !Eof() .AND. ACP->ACP_CODREG == aCodReg[nX] ) .AND. !Empty(cPeso)
							nPosProd	:=	If(Empty(ACP->ACP_CODPRO), Ascan(aProds,{|x| ACP->ACP_GRUPO == X[2]}), Ascan(aProds,{|x| ACP->ACP_CODPRO == X[1]}) )
							If nPosProd > 0
								nQuantTot	+=	aProds[nPosProd][3]
							Endif
							DbSelectArea("ACP")
							DbSkip()
						End
						If nQuantTot >= ACO->ACO_LOTE
							nDesconto	:=	ACO->ACO_PERDES
							cCnt	:=	'2'
							While ACO->(FieldPos('ACO_LOTE'+cCnt)) > 0  .AND. ;
								nQuantTot >= ACO->(FieldGet(FieldPos('ACO_LOTE'+cCnt))) .AND. ;
								ACO->(FieldGet(FieldPos('ACO_LOTE'+cCnt)))  > 0
								nDesconto	:=	ACO->(FieldGet(FieldPos('ACO_PERDE'+cCnt)))
								cCnt	:=	SOMA1(cCnt)
							End
							AAdd(aDescontos, {cPeso,StrZero(999-Len(aDescontos),3),nDesconto,ACO->ACO_CODREG} )
						Else
							nDesconto	:=	0
						Endif
						If nDesconto <> 0.And.!lExistCpo
							cUltRegra	:=	ACO->ACO_CODREG
							Exit
						Endif
					Endif
				Endif
			Next nX
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A ordem para escolher os descontos sera determinada pelo peso do grupo  ³
			//³de vendas mas a ordem em que foi achado                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExistCpo .AND. Len(aDescontos) > 0
				aSort(aDescontos,,,{|x,y| x[1]+x[2] > y[1]+y[2] })
				nDesconto	:=	If(aDescontos[1][3] == 0,-1,aDescontos[1][3])
				If nDesconto > 0
					cUltRegra	:=	If(aDescontos[1][3] == 0,cUltRegra,aDescontos[1][4])
				Endif
			Endif
			aDescontos	:=	{}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Determina para cada produto ou grupo a % de desconto                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ACP->(MsSeek(xFilial()+cUltRegra))
			While ACP->ACP_CODREG == cUltRegra .AND. !ACP->(EOF())
				nDescs	:=	0
				If Empty(ACP->ACP_CODPRO)
					While  (nDescs   := Ascan(aProds,{|x| x[2] == ACP->ACP_GRUPO },nDescs+1  ) ) > 0
						aProds[nDescs][4] := nDesconto
						aProds[nDescs][5] := .F.
					End
				Else
					While  (nDescs   := Ascan(aProds,{|x| x[1] == ACP->ACP_CODPRO},nDescs+1  ) ) > 0
						aProds[nDescs][4] := nDesconto
					End
				Endif
				ACP->(DbSkip())
			End
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retira o primeiro campo da chave e continua a busca recursiva           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nDesconto == 0 )
			For nX := nY-nW+1 To nY
				Do Case
					Case aPesq[nX] == "ACO_CODCLI"
						cCliente := Nil
					Case aPesq[nX] == "ACO_LOJA"
						cLoja := Nil
					Case aPesq[nX] == "ACO_CODTAB"
						cTabPreco := Nil
					Case aPesq[nX] == "ACO_CONDPG"
						cCondPg := Nil
					Case aPesq[nX] == "ACO_FORMPG"
						cFormPg := Nil
				EndCase
				nDesconto := MaRgrDesc(cProduto,cCliente,cLoja,cTabPreco,nFaixa,cCondPg,cFormPg,nTipo,aProds,aExc)
				If nDesconto <> 0
					Exit
				Endif
			Next nX
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os ultimos resultados                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aUltResult,{cProduto,cCliente,cLoja,cTabPreco,nFaixa,cCondPg,cFormPg,nTipo,nDesconto,cUltRegra,aClone(aProds),cFilAnt})
		If Len(aUltResult) > MAXSAVERESULT
			aUltResult := aDel(aUltResult,1)
			aUltResult := aSize(aUltResult,MAXSAVERESULT)
		Endif
	Else
		nDesconto	:= aUltResult[nX][09]
		aProds		:=	aClone(aUltResult[nX][11])
		If nDesconto > 0
			cUltRegra	:=	aUltResult[nX][10]
		Endif
	Endif
	RestArea(aArea)
	If nStack == 1
		nDesconto := Max(0,nDesconto)
	Else
		nStack--
	Endif
Endif

Return(nDesconto)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKTriger ºAutor  ³Microsiga           º Data ³  08/13/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao indica ao sistema que uma referencia de imposto º±±
±±º          ³foi alterado em um gatilho                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Somente TELEVENDAS                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMKTrigger(cCampo)

Local aArea 	:= GetArea()
Local aRefer    := {}
Local lRetorno	:= .T.
Local nPosCpo	:= Ascan(aHeader,{|x| AllTrim(x[2])==AllTrim(cCampo)})

If nPosCpo > 0
	nVlrItem := aCols[n][nPosCpo]   // Foi incluido por Valdecir em 16.02.05, pois ao retornar da funcao MAFISREF, 
	                                // nao estava trazendo o numero de casas decimais corretas.
	                                // Sr. Deco acompanhou esta alteracao.
	aRefer := MaFisGetRF(aHeader[nPosCpo][6])
	If !Empty(aRefer[1])
		MaFisRef(aRefer[1],aRefer[2],aCols[N,nPosCpo])
		If cPaisLoc <>"BRA"
			ModxAtuObj()
		EndIf
	EndIf
	aCols[n][nPosCpo]	:= nVlrItem  // Incluido por Valdecir conforme texto acima.
Else
	lRetorno := .F.
EndIf

RestArea(aArea)
Return(lRetorno)
