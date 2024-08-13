#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "rwmake.ch"

#DEFINE CLRF Chr(13)+Chr(10)

/*/{Protheus.doc} DA0_ATIVA
Funcao executada na validacao do campo DA0_ATIVA para nao
permitir que o cadastramento de mais de uma tabela por tipo
de cliente
@author Fabio Cesar
@since 04/02/04
@version P11
@uso SHELL
@type function
/*/
User Function DA0_ATIVA()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis da rotina                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		 := GetArea()
Local lReturn	 := .T.
Local cQuery     := ""
Local aTabela    := {}
Local cTipoCli   := M->DA0_GRPCLI
Local cCondPag   := M->DA0_CONDPG

If &(ReadVar()) == "1"  // Ativando a Tabela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery	+= " SELECT DA0_CODTAB "
	cQuery	+= " FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"
	cQuery	+= " WHERE DA0_FILIAL = '"+xFilial("DA0")+"'"
	cQuery	+= " AND DA0_ATIVO  = '1'"
	cQuery	+= " AND DA0_CODTAB <> '"+M->DA0_CODTAB+"'"
	cQuery	+= " AND DA0_CONDPG = '"+cCondPag+"'"
	cQuery	+= " AND DA0_GRPCLI = '"+cTipoCli+"'"
	cQuery	+= " AND DA0.D_E_L_E_T_ <> '*'"
	aTabela	:= U_QryArr(cQuery)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aTabela) > 0
		Aviso("Tabela de Preço!","Não é permitido existir mais de uma tabela de preços ativa para uma mesma condicao de pagamento e grupo de clientes, favor verificar!",{"Ok"})
		lReturn := .F.
	Endif
Endif
RestArea(aArea)
Return(lReturn)

/*/{Protheus.doc} DA0_GRPCLI
Funcao executada na validacao do campo DA0_GRPCLI para nao
permitir que o cadastramento de mais de uma tabela por tipo
de cliente
@author Fabio Cesar
@since 04/02/04
@version P11
@uso SHELL
@type function
/*/
User Function DA0_GRPCLI()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis da rotina                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		 := GetArea()
Local lReturn	 := .T.
Local cQuery     := ""
Local aTabela    := {}
Local cAtiva     := M->DA0_ATIVO
Local cCondPag   := M->DA0_CONDPG

If cAtiva == "1" .and. Posicione("ACY",1,xFilial("ACY")+&(ReadVar()),"ACY_TABPRC") == "N"  // Tabela ativa
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery	+= " SELECT DA0_CODTAB "
	cQuery	+= " FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"
	cQuery	+= " WHERE DA0_FILIAL = '"+xFilial("DA0")+"'"
	cQuery	+= " AND DA0_ATIVO  = '1'"
	cQuery	+= " AND DA0_CODTAB <> '"+M->DA0_CODTAB+"'"
	cQuery	+= " AND DA0_CONDPG = '"+cCondPag+"'"
	cQuery	+= " AND DA0_GRPCLI = '"+&(ReadVar())+"'"
	cQuery	+= " AND DA0.D_E_L_E_T_ <> '*'"
	aTabela	:= U_QryArr(cQuery)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aTabela) > 0
		Aviso("Tabela de Preço!","Não é permitido existir mais de uma tabela de preços ativa para uma mesma condicao de pagamento e grupo de clientes, favor verificar!",{"Ok"})
		lReturn := .F.
	Endif
Endif
RestArea(aArea)
Return(lReturn)

/*/{Protheus.doc} DA0_CONDPG
Funcao executada na validacao do campo DA0_GRPCLI para nao   ?
permitir que o cadastramento de mais de uma tabela por tipo
de cliente
@author Fabio Cesar
@since 04/02/04
@version P11
@uso SHELL
@type function
/*/
User Function DA0_CONDPG()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis da rotina                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		 := GetArea()
Local lReturn	 := .T.
Local cQuery     := ""
Local aTabela    := {}
Local cAtiva     := M->DA0_ATIVO
Local cGrpCli    := M->DA0_GRPCLI

If cAtiva == "1"  .and. Posicione("ACY",1,xFilial("ACY")+cGrpCli,"ACY_TABPRC") == "N"  // Tabela ativa
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery	+= " SELECT DA0_CODTAB "
	cQuery	+= " FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"
	cQuery	+= " WHERE DA0_FILIAL = '"+xFilial("DA0")+"'"
	cQuery	+= " AND DA0_ATIVO  = '1'"
	cQuery	+= " AND DA0_CONDPG = '"+&(ReadVar())+"'"
	cQuery	+= " AND DA0_GRPCLI = '"+cGrpCli+"'"
	cQuery	+= " AND DA0.D_E_L_E_T_ <> '*'"
	aTabela	:= U_QryArr(cQuery)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aTabela) > 0
		Aviso("Tabela de Preço!","Não é permitido existir mais de uma tabela de preços ativa para uma mesma condicao de pagamento e grupo de clientes, favor verificar!",{"Ok"})
		lReturn := .F.
	Endif
Endif
RestArea(aArea)
Return(lReturn)

/*/{Protheus.doc} QryArr
Funcao para rodar uma Query e retornar como Array
@author Silvio Cazela
@since 21/06/2001
@version P11
@uso AP5
@param cQuery, characters, Query SQL a ser executado
@type function
/*/
User Function QryArr(cQuery)

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Gravacao do Ambiente Atual e Variaveis para Utilizacao                   º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
Local aRet    := {}
Local aRet1   := {}
Local nRegAtu := 0
Local x       := 0

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Ajustes e Execucao da Query                                              º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
//cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "_TRB"

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Montagem do Array para Retorno                                           º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
DbSelectArea("_TRB")
aRet1   := Array(fcount())
nRegAtu := 1

While !eof()
	For x:=1 to fcount()
		aRet1[x] := FieldGet(x)
	Next
	AADD(aRet,aclone(aRet1))
	DbSkip()
	nRegAtu += 1
Enddo

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Encerra Query e Retorna Ambiente                                         º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
DbSelectArea("_TRB")
_TRB->(DbCloseArea())

Return(aRet)

/*/{Protheus.doc} C5_CLIENTE
Gatilha o campo C5_TABELA de acordo com a classificacao do
cliente em relação a isen?o de tributa?o ( ICMS )
@author Fabio Cesar Congilio
@since 10/02/04
@version P11
@uso Exclusivo Connan
@type function
/*/
User Function C5_CLIENTE()
Local lReturn	:= .T.
Local cQuery	:= ""
Local aTabela   := {}
Local cTipoCli 	:= ""
Local Areas		:= {}
Local AreasSA1	:= {}
Local cCliente  := Iif(Alltrim(ReadVar())=="M->C5_CLIENTE" ,&(ReadVar()),M->C5_CLIENTE)
Local cLoja     := Iif(Alltrim(ReadVar())=="M->C5_LOJACLI" ,&(ReadVar()),M->C5_LOJACLI)
Local cCondicao := Iif(Alltrim(ReadVar())=="M->C5_CONDPAG" ,&(ReadVar()),M->C5_CONDPAG)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao valida os pedidos de remessa                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If U_VerRot("M410GerRem") .or. U_VerRot("U_M410GerRem")
	Return(.T.)
Endif
If M->C5_TIPO <> "N"
	Return(.T.)
Endif

Areas		:= GetArea()
dbSelectArea("SA1")
AreasSA1	:= GetArea()
dbSetOrder(1)

dbSeek(xFilial("SA1")+cCliente+cLoja)

If Empty(cCondicao)
   cCondicao := SA1->A1_COND
Endif

If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCondicao)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery	+= " SELECT DA0_CODTAB "
	cQuery	+= " FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"
	cQuery	+= " WHERE DA0_FILIAL = '"+xFilial("DA0")+"'"
	cQuery	+= " AND DA0_ATIVO  = '1'"
	cQuery	+= " AND DA0_GRPCLI = '"+SA1->A1_GRPVEN+"'"
	cQuery	+= " AND DA0_CONDPG = '"+cCondicao+"'"
	cQuery	+= " AND DA0.D_E_L_E_T_ <> '*'"
	aTabela	:= U_QryArr(cQuery)
	If Len(aTabela) <= 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery	:= " SELECT DA0_CODTAB "
		cQuery	+= " FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"
		cQuery	+= " WHERE DA0_FILIAL = '"+xFilial("DA0")+"'"
		cQuery	+= " AND DA0_ATIVO  = '1'"
		cQuery	+= " AND DA0_GRPCLI = '"+SA1->A1_GRPVEN+"'"
		cQuery	+= " AND DA0_CONDPG = ''"
		cQuery	+= " AND DA0.D_E_L_E_T_ <> '*'"
		aTabela	:= U_QryArr(cQuery)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a tabela esta valida                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aTabela) > 0 .And. MaVldTabPrc(Alltrim(aTabela[1][1]),cCondicao,,M->C5_EMISSAO) .And. A410Recalc()
		M->C5_TABELA 	:= Alltrim(aTabela[1][1])
		lReturn 		:= .T.
	Else
		Aviso("Tabela de Preço!","Não existe tabela de preços ativa, favor verificar!",{"Ok"},,"Atencao:")
		lReturn := .F.
	Endif
Endif
RestArea(AreasSA1)
RestArea(Areas)

Return(lReturn)

/*/{Protheus.doc} C5_TABELA
Gatilho no campo C5_CLIENTE  para selecionar a tabela de
preco
@author Fabio Cesar Congilio
@since 10/02/04
@version P11
@uso Exclusivo Shell
@type function
/*/
User Function C5_TABELA()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local cTabela	:= M->C5_TABELA
Local cQuery	:= ""
Local aTabela   := {}
Local Areas		:= {}
Local AreasSA1	:= {}
Local cCliente  := Iif(Alltrim(ReadVar())=="M->C5_CLIENTE" ,&(ReadVar()),M->C5_CLIENTE)
Local cLoja     := Iif(Alltrim(ReadVar())=="M->C5_LOJACLI" ,&(ReadVar()),M->C5_LOJACLI)
Local cCondicao := Iif(Alltrim(ReadVar())=="M->C5_CONDPAG" ,&(ReadVar()),M->C5_CONDPAG)
Local lReturn	:= .T.
Local cProdOri	:= ""
Local nProduto  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPrcVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPrcTab   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCLIST"})
Local nQtdVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nDescont  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local nValDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nValor    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nX := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao valida os pedidos de remessa                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If U_VerRot("M410GerRem") .or. U_VerRot("U_M410GerRem")
	Return(.T.)
Endif
If M->C5_TIPO <> "N"
	Return(.T.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a area dos arquivos                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Areas		:= GetArea()
dbSelectArea("SA1")
AreasSA1	:= GetArea()
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCliente+cLoja)

If Empty(cCondicao)
     cCondicao := SA1->A1_COND
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se esta alterando a tabela                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !Empty(cTabela) //.and. ACY->(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_TABPRC")) <> "S"
//	If Aviso("Confirmacao","Deseja confirmar a alteração da condicao de pagamento ?"+Chr(13)+Chr(10)+"A confirmação afetará os valores informados nos itens do Pedido de Venda.",{"Sim","Nao"},,OemtoAnsi("Atenção:"))  == 2
//		Return(.F.)
//	Endif
//Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery	+= " SELECT DA0_CODTAB "
cQuery	+= " FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"
cQuery	+= " WHERE DA0_FILIAL = '"+xFilial("DA0")+"'"
cQuery	+= " AND DA0_ATIVO  = '1'"
cQuery	+= " AND DA0_GRPCLI = '"+SA1->A1_GRPVEN+"'"
cQuery	+= " AND DA0_CONDPG = '"+cCondicao+"'"
cQuery	+= " AND DA0.D_E_L_E_T_ <> '*'"
aTabela	:= U_QryArr(cQuery)
If Len(aTabela) <= 0
	cQuery	:= " SELECT DA0_CODTAB "
	cQuery	+= " FROM "+RetSqlName("DA0")+" DA0 (NOLOCK)"
	cQuery	+= " WHERE DA0_FILIAL = '"+xFilial("DA0")+"'"
	cQuery	+= " AND DA0_ATIVO  = '1'"
	cQuery	+= " AND DA0_GRPCLI = '"+SA1->A1_GRPVEN+"'"
	cQuery	+= " AND DA0_CONDPG = ''"
	cQuery	+= " AND DA0.D_E_L_E_T_ <> '*'"
	aTabela	:= U_QryArr(cQuery)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a tabela esta valida                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTabela) > 0

	//@ticket 181072 - T08957 – Ricardo Munhoz, Não entrar na condição caso venha do SHEA301I.
	If !IsBlind() .And. !Empty(cTabela) .and. ACY->(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_TABPRC")) <> "S" ;
		.And. cTabela <> Alltrim(aTabela[1][1]) .And. !IsIncallStack("U_SHEA301I") .and. !IsIncallStack("U_SHEA301J")
		If Aviso("Confirmacao","Deseja confirmar a alteração da condicao de pagamento ?"+Chr(13)+Chr(10)+"A confirmação afetará os valores informados nos itens do Pedido de Venda.",{"Sim","Nao"},,OemtoAnsi("Atenção:"))  == 2
			RestArea(AreasSA1)
			RestArea(Areas)
			Return(.F.)
		Endif
	Endif

	If ACY->(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_TABPRC")) == "S"
		If MaVldTabPrc(SA1->A1_TABELA,"",,M->C5_EMISSAO)
			M->C5_TABELA := SA1->A1_TABELA
			A410Recalc()
		Endif
	Else
		If MaVldTabPrc(aTabela[1][1],cCondicao,,M->C5_EMISSAO)
			M->C5_TABELA := Alltrim(aTabela[1][1])

			A410Recalc()
		Endif
	Endif
Else
	Aviso("Tabela de Preço!","Não existe tabela de preços ativa para esta condicao de pagamento, favor verificar com o responsável!",{"Ok"})
	lReturn := .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o aCols                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReturn
	For nX := 1 to Len(aCols)
		aCols[nX,nDescont] 	:= 0.00
		aCols[nX,nValDesc] 	:= 0.00
		aCols[nX,nPrcVen] 	:= A410Tabela(aCols[nX,nProduto],M->C5_TABELA,nX,aCols[nX][nQtdVen],M->C5_CLIENTE,M->C5_LOJACLI,"","",.f.)
		aCols[nX,nPrcTab] 	:= aCols[nX,nPrcVen]
		aCols[nX,nValor] 	:= aCols[nX,nPrcVen] * aCols[nX,nQtdVen]
	Next nX
Endif
RestArea(AreasSA1)
RestArea(Areas)

Return(lReturn)

/*/{Protheus.doc} WC5_TABELA
X3_Whem do campo C5_CLIENTE  para ativar ou naum o campo
@author Jaime Wikanski
@since 10/02/04
@version P11
@uso Exclusivo Shell
@type function
/*/
User Function WC5_TABELA()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local cTabela	:= Space(3)
//Local cQuery	:= ""
//Local aTabela   := {}
Local Areas		:= GetArea()
//Local AreasSA1	:= {}
Local cCliente  := M->C5_CLIENTE
Local cLoja     := M->C5_LOJACLI
Local cGrupo	:= ""
Local lReturn	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a tabela de precos padrao e o grupo do cliente						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabela := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_TABELA")
cGrupo  := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_GRPVEN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ativa o campo C5_TABELA                    						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Posicione("ACY",1,xFilial("ACY")+cGrupo,"ACY_TABPRC") == "S" .or. (Empty(cCliente) .and. Empty(cLoja))
	lReturn := .F.
Else
	lReturn := .T.
Endif
RestArea(Areas)
Return(lReturn)

/*/{Protheus.doc} C5_CONDPAG
Validacao do campo C5_CONDPAG
@author Fabio Cesar Congilio
@since 10/02/04
@version P11
@uso Exclusivo Shell
@type function
/*/
User Function C5_CONDPAG()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local Areas		:= {}
Local AreasSA1	:= {}
Local cCondicao := Iif(Alltrim(ReadVar())=="M->C5_CONDPAG" ,&(ReadVar()),M->C5_CONDPAG)
Local cCliente  := Iif(Alltrim(ReadVar())=="M->C5_CLIENTE" ,&(ReadVar()),M->C5_CLIENTE)
Local cLoja     := Iif(Alltrim(ReadVar())=="M->C5_LOJACLI" ,&(ReadVar()),M->C5_LOJACLI)
Local lReturn	:= .T.

Areas		:= GetArea()
dbSelectArea("SA1")
AreasSA1	:= GetArea()
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCliente+cLoja)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao valida os pedidos de remessa                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If U_VerRot("M410GerRem") .or. U_VerRot("U_M410GerRem")
	Return(.T.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o prazo medio           											    ³                                                          
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty(SA1->A1_COND) .And. !Empty(SA1->A1_TABELA)
	If u_PrzMedio(cCondicao) > u_PrzMedio(SA1->A1_COND) 
		If !IsBlind() //@ticket 1133580 - T08160 – Cintia Helena Koyama– Compatibilização para executar via JOB
			Aviso("Prazo Médio!","O prazo médio do cliente é superior ao selecionado, este pedido ficará bloqueado para liberação de alcada!",{"Ok"})
		Endif
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a tabela de precos      											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReturn
	lReturn := U_C5_TABELA()
Endif

RestArea(AreasSA1)
RestArea(Areas)

Return(lReturn)

/*/{Protheus.doc} C6_PRODUTO
Valid   no campo C6_PRODUTO para verificar se o produto
esta cadastrado na tabela de preco selecionada
@author Fabio Cesar Congilio
@since 10/02/04
@version P11
@uso Exclusivo Connan
@type function
/*/
User Function C6_PRODUTO()
Local lReturn	:= .T.
Local lRetorno	:= .T.
Local cQuery	:= ""
Local aTabela 	:= {}
Local Areas	    := {}
Local AreasSA1  := {}
Local nProduto  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPrcVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
lOCAL nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPrcTabela:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCLIST"})
Local cProduto  := Iif(Alltrim(ReadVar())=="M->C6_PRODUTO" ,&(ReadVar()),aCols[n][nProduto])
Local cCliente  := Iif(Alltrim(ReadVar())=="M->C5_CLIENTE" ,&(ReadVar()),M->C5_CLIENTE)
Local cLoja     := Iif(Alltrim(ReadVar())=="M->C5_LOJACLI" ,&(ReadVar()),M->C5_LOJACLI)
Local cCliEntre := Iif(Alltrim(ReadVar())=="M->C5_CLIENT"  ,&(ReadVar()),M->C5_CLIENT)
Local cLojEntre := Iif(Alltrim(ReadVar())=="M->C5_LOJAENT" ,&(ReadVar()),M->C5_LOJAENT)
Local oGeraTxt
Local cArmazem := ""     // Chamado TQLEZJ

Local cTipoDesc := GETMV("MV_TDESC",,"MD|SH|AG") // Tipos de produtos que calculam desconto
Local lVerifica := .F.
Local nCont		:= 0
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local aSavCols 	:= aClone(aCols[n])
//Local aSavCols 	:= aClone(aCols[nAt])
Local cProdTemp	:= ""
Local _cFilsShl := AllTrim(GetNewPAr("ES_FILSHEL","ALL"))
Areas		:= GetArea() // 

//lReturn	:= U_VerifProd()

If lReturn .and. (cFilAnt $ _cFilsShl .or. _cFilsShl == "ALL")//apenas para filiais da Shell

	dbSelectArea("SA1")
	AreasSA1	:= GetArea()
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cCliente+cLoja)
	IF FieldPos("A1_ARMAZEM") > 0
	cArmazem := IF (!Empty(SA1->A1_ARMAZEM),SA1->A1_ARMAZEM,"01") // Chamado TQLEZJ
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no produto para verificacao se calcula desconto           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto)) .And. SB1->B1_TIPO$cTipoDesc
		lVerifica := .T.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao valida os pedidos de remessa                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If U_VerRot("M410GerRem") .or. U_VerRot("U_M410GerRem")
		Return(.T.)
	Endif
	If M->C5_TIPO == "N" .And. lVerifica
		//@ticket 975925 - T10532 - José Carlos Jr. - Posicionar a ACY para query da DA1.
		Posicione("ACY", 1, xFilial("ACY")+A1_GRPVEN, "ACY_TABPRC")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca a tabela ativa de acordo com o tipo do cliente                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery	+= " SELECT DA1_CODPRO "
		cQuery	+= " FROM "+RetSqlName("DA1")+" DA1 (NOLOCK)"
		cQuery	+= " WHERE DA1_FILIAL = '"+xFilial("DA1")+"'"
		If SB1->B1_TIPO == "SH"
			cQuery	+= " AND DA1_CODTAB = '"+M->C5_TABELA+"'"
		Else
		    cQuery	+= " AND DA1_CODTAB = '"+ACY->ACY_TABAGR+"'"
		EndIf
		cQuery	+= " AND DA1_CODPRO = '"+cProduto+"'"
		cQuery	+= " AND DA1_ATIVO  = '1'"
		cQuery	+= " AND DA1.D_E_L_E_T_ <> '*'"
		aTabela	:= U_QryArr(cQuery)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a tabela esta valida                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Len(aTabela) ==  0 .And. (SB1->B1_TIPO == "SH" .OR. SB1->B1_TIPO == "AG".OR. SB1->B1_TIPO == "HG")) //.Or. (SB1->B1_TIPO <> "SH" .AND. SB1->B1_PRV1 == 0)
			lReturn := .F.
			Aviso("Tabela de Preço!","Este produto não esta cadastrado na tabela de precos, favor verificar!",{"Ok"})
		ElseIf	 Alltrim(ReadVar()) == "M->C6_PRODUTO"
			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial()+cProduto+cArmazem)       // Chamado TQLEZJ

				SB1->(dbSeek(xFilial()+cProduto))
				nStok:= SaldoSb2() //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS)

				@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Posi‡„o de Estoque")
				@ 02,10 TO 080,190
				@ 10,018 Say "Produto: "+Subs(SB1->B1_DESC,1,30) SIZE 200,11

	//			@ 20,018 Say "Preco de Venda :"
	//			@ 20, 100 SAY SB1->B1_PRV1 PICTURE "@e 999,999.99"

				@ 20,018 Say "Pedido de Vendas em Aberto :"
				@ 20, 110 SAY B2_QPEDVEN

				@ 30,018 Say "Qtd.Prevista p/Entrar :"
				@ 30, 110 SAY B2_SALPEDI

				@ 40,018 Say "Quantidade Reservada (A) :"
				@ 40, 110 SAY B2_RESERVA

				@ 50,018 Say "Saldo Atual (B) :"
				@ 50, 110 SAY B2_QATU

				@ 60,018 Say "Dispon¡vel (B - A) :"
				@ 60, 110 SAY nStoK

				@ 76,158 BMPBUTTON TYPE 01 ACTION Close(oGeraTxt)

				Activate Dialog oGeraTxt Centered
			Else
				Aviso("Produto sem Saldo!","Este produto não possui saldo no almaxarifado 01, favor verificar!",{"Ok"})
			Endif
		Endif
	Endif
	RestArea(AreasSA1)
ElseIf (alltrim(GetNewPAr("ES_FUSUS","INVALIDO")) $ SM0->M0_FILIAL)//apenas para filiais Fusus
	If Empty(aCols[n][nProduto])
		//cProduto				:= ""
		For nCont:=1 To Len(aHeader)
			aCols[n][nCont] := Iif(aHeader[nCont][2] = "C6_ITEM", aCols[n][nPosItem], CriaVar(aHeader[nCont][2]))
		Next
		oGetDad:OBROWSE:Refresh()
	Else

		cProdTemp			:= 	M->C6_PRODUTO
		M->C6_PRODUTO		:=	aCols[oGetDad:OBROWSE:nAt][nProduto]
   		aCols[oGetDad:OBROWSE:nAt][nProduto]	:=	cProdTemp
		lRetorno := Iif(!Empty(aHeader[nProduto,6]),&( aHeader[nProduto,6]),.T.)
		aCols[oGetDad:OBROWSE:nAt][nProduto]	:=	M->C6_PRODUTO
		lReturn	:= .T.
	EndIf
EndIf

RestArea(Areas)
Return(lReturn)

/*/{Protheus.doc} DA0_PERDES
Indexa todos os registros da lista de precos
@author Fabio Cesar Congilio
@since 10/02/04
@version P11
@uso Exclusivo Shell
@type function
/*/
User Function DA0_PERDES()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local nIndex := &(ReadVar())

If DA0->DA0_PERDES <> nIndex
	Processa({||u_RunPerDes(nIndex) },"Indexando tabela...") // Substituido pelo assistente de conversao do AP5 IDE em 21/01/03 ==>   Processa({||EXECUTE(RunCont) },"Processando...")
Endif

Return(.T.)

/*/{Protheus.doc} RunPerDes
Indexa todos os registros da lista de precos
@author Fabio Cesar Congilio
@since 10/02/04
@version P11
@uso Exclusivo Shell
@param nIndex, numeric
@type function
/*/
User Function RunPerDes(nIndex)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local lReturn	:= .T.
Local nPrcBas   := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_PRCBAS"})
Local nPrcVen   := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_PRCVEN"})
Local nPerDes   := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_PERDES"})
Local nI

ProcRegua(Len(aCols))            // Numero de registros a processar
For nI := 1 to Len(aCols)
	IncProc()
	aCols[nI][nPrcVen] := aCols[nI][nPrcBas] * nIndex
	aCols[nI][nPerDes] := nIndex
Next
oGetDad:Refresh()
Return(lReturn)

/*/{Protheus.doc} PrzMedio
Prazo Medio de Pagamento
@author Fabio Cesar Congilio
@since 04/02/04
@version P11
@uso Exclusivo Connan
@param  cCond , characters
@type function
/*/
User Function PrzMedio( cCond )
Local nX
Local aCond 	:= {}
Local nDiasPrz := 0
Local aArea    := GetArea()
Local cParcela  := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local nParcelas := GETMV("MV_NUMPARC")
Local cChave := "SC5->C5_DATA"+Subs(cParcela,nParcelas,1)
Local cChave1:= "SC5->C5_PARC"+Subs(cParcela,nParcelas,1)
Local nReg
Local bData := { |x| "M->C5_DATA"+Subs(cParcela,x,1) }
Local i := 0


If ISINCALLSTACK("A456LibAut")
   Return()
EndIf

If SE4->(dbSeek(xFilial("SE4")+cCond)) .And. SE4->E4_TIPO == "9"
	If FunName() == "SHEA300"
		Return(0)
	EndIf
	DbSelectArea("SX3")
	nReg := Recno()
	DbSetOrder(2)
	If nParcelas > 26
		nParcelas := 26
	EndIf
	If nParcelas > 4
		If !DbSeek(cChave) .or. !DbSeek(cChave1)
			nParcelas := 4
		EndIf
	Else
		nParcelas := 4
	EndIf
	DbSetOrder(1)
	// Total das Parcelas
	For i:= 1 to nParcelas
		If Alltrim(ReadVar()) == Alltrim(EVAL(bData,i)) .And. !Empty(&(EVAL(bData,i)))
			AADD(aCond,{&(ReadVar())})
		ElseIf !Empty(&(EVAL(bData,i)))
			AADD(aCond,{&(EVAL(bData,i))})
		Endif
	Next i
Else
	aCond := Condicao(100,cCond,0.00,dDatabase,0)
Endif
// A condicao sempre considerara fora o dia
For nX := 1 to Len(aCond)
//	nDiasPrz += aCond[nX][1] -  dDataBase
	nDiasPrz += aCond[nX][1] -  Iif((aCond[nX][1]-dDataBase==1),dDataBase+1,dDataBase)
Next nX
RestArea(aArea)
Return(nDiasPrz /= Len(aCond))

/*/{Protheus.doc} A1_GRPTRIB
Gatilha o campo A1_GRPTRIB de acordo com a classificacao
tribut?ia do cliente
@author Fabio Cesar Congilio
@since 04/02/04
@version P11
@uso Exclusivo Connan
@type function
/*/
User Function A1_GRPTRIB()
Local cEstado   := Iif(Alltrim(ReadVar())=="M->A1_EST"   ,&(ReadVar()),M->A1_EST)
Local cInscr    := Iif(Alltrim(ReadVar())=="M->A1_INSCR" ,&(ReadVar()),M->A1_INSCR)
Local cTpCli    := Iif(Alltrim(ReadVar())=="M->A1_TIPO"  ,&(ReadVar()),M->A1_TIPO)
Local cPeCli    := Iif(Alltrim(ReadVar())=="M->A1_PESSOA",&(ReadVar()),M->A1_PESSOA)
Local aArea     := GetArea()
Local cMvEstado := GetMv("MV_ESTADO")
Local cMvNorte  := GetMv("MV_NORTE")
Local cTpOper   := ""
Local cEstExc	 := u_BuscaExcec() // Verifica os Estados que estao no grupo "06" da excecao fiscal

If !Empty(cEstado)
	If cEstado$cEstExc .And. cPeCli == "F" .And. cTpCli == "L"
		cTpOper := "06" // Excecao Fiscal para pessoas fisica, produtoras rurais pertencentes ao estado cadastrados na excecao
		M->A1_INSCR := "ISENTO"
	ElseIf Empty(cInscr) // Nao Contribuinte
		If cEstado == cMvEstado
			cTpOper := "02"  // Estadual nao Contribuinte - TRIBUTADO
		Else
			cTpOper := "05"  // InterEstadual nao Contribuinte - TRIBUTADO
		Endif
	Else // Contribuinte
		Do Case
			Case cEstado == cMvEstado
				cTpOper := "01"  // Estadual Contribuinte  - ISENTO
			Case cEstado != cMvEstado
				If cTpCli $"F"
					cTpOper := "03" // InterEstadual Contribuinte S/Reducao
				ElseIf cTpCli $"LR"
					cTpOper := "04" // InterEstadual Contribuinte C/Reducao
				Endif
		EndCase
	Endif
Endif
RestArea(aArea)
Return(cTpOper)

/*/{Protheus.doc} CalcDesc
Funcao de calculo do desconto nos itens do pedido de venda
@author Jaime Wikanski
@since 10/02/04
@version P11
@uso
@param nOpc, numeric
@type function
/*/
User Function CalcDesc(nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local nReturn	:= 0.00
Local nPPrcVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPPrcTab   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCLIST"})
Local nPQtdVen   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPrcVen	 := Iif(Alltrim(ReadVar())=="M->C6_PRCVEN",&(ReadVar()),aCols[n,nPPrcVen])
Local nPrcTab	 := Iif(Alltrim(ReadVar())=="M->C6_PRCLIST",&(ReadVar()),aCols[n,nPPrcTab])
Local nQtdVen	 := Iif(Alltrim(ReadVar())=="M->C6_QTDVEN",&(ReadVar()),aCols[n,nPQtdVen])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o desconto             											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	nReturn := NoRound(((nPrcTab-nPrcVen)*100)/nPrcTab,2)
ElseIf nOpc == 2
	nReturn := NoRound((nPrcTab-nPrcVen)*nQtdVen,2)
Endif
Return(nReturn)

/*/{Protheus.doc} PrzVend
Funcao de calculo do prazo medio do vendedor
@author Jaime Wikanski
@since 10/02/04
@version P11
@uso
@param cVend, characters
@type function
/*/
User Function PrzVend(cVend)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local aArea			:= GetArea()
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local nReturn		:= 0.00
Local nX			:= 0
Local cCodShell		:= GetMv("MV_CODSHEL")
Local nVolume		:= 0
Local lTemProd		:= .F.
Local cPedido		:= Iif(FunName()=="MATA410",M->C5_NUM,SC5->C5_NUM)
Local nPProduto  	:= 0
Local nPQtdVen   	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o volume total        											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(FunName())$"MATA440|MATA450" .OR. Len(aCols) == 0
	cPedido		:= SC5->C5_NUM
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(xFilial("SC6")+cPedido,.F.)
	While !EOF() .and. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+cPedido
		If Alltrim(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PROC")) $ Alltrim(cCodShell)
			nVolume 	+= Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_VOLUME") * SC6->C6_QTDVEN
			lTemProd	:= .T.
		Endif
		DbSelectArea("SC6")
		DbSkip()
	Enddo
Else
	nPProduto  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	nPQtdVen   	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o volume total        											    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aCols)
		If Alltrim(Posicione("SB1",1,xFilial("SB1")+aCols[nX,nPProduto],"B1_PROC")) $ Alltrim(cCodShell)
			nVolume 	+= Posicione("SB1",1,xFilial("SB1")+aCols[nX,nPProduto],"B1_VOLUME") * aCols[nX,nPQtdVen]
			lTemProd	:= .T.
	   	Else
			nVolume 	+=  aCols[nX,nPQtdVen]
			lTemProd	:= .T.
		EndIf
	Next nX
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o prazo medio         											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVolume == 0.00 .and. lTemProd == .F.
	nReturn	:= 99999
ElseIf nVolume == 0.00 .and. lTemProd == .T.
	nReturn := 0.00
Else
	DbSelectArea("PA4")
	DbSetOrder(1)
	DbSeek(xFilial("PA4")+cVend,.F.)
	While !EOF() .and. PA4->PA4_FILIAL+PA4->PA4_VEND == xFilial("PA4")+cVend
	    If PA4->PA4_VOLINI <= nVolume .and. PA4->PA4_VOLFIM >= nVolume
	    	nReturn := PA4->PA4_PRAZO
			Exit
		Endif
		DbSelectArea("PA4")
		DbSkip()
	Enddo
Endif
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)
Return(nReturn)

/*/{Protheus.doc} IniVend2
Funcao de inicializao do vendedor 2 no pedido
@author FABIO CESAR CONGILIO
@since 10/02/04
@version P11
@uso
@type function
/*/
User Function IniVend2()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Verifica o Percentual de desconto do vendedor                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local cReturn :=""
Local aArea	:= GetArea()
SA3->(dbSetOrder(7))
If SA3->(dbSeek(xFilial("SA3")+__cUserId))
	cReturn := SA3->A3_COD
Endif
SA3->(dbSetOrder(1))
RestArea(aArea)
Return(cReturn)

/*/{Protheus.doc} A103TotShell
Esta rotina tem como objetivo verifica se o valor informado
como total do item do documento de entrada eh valido
@author Edson Maricate
@since 07.01.2000
@version P11
@uso Materiais
@param nTotal, numeric, Valor do total digitado
@return lRetorno, logical, Indica se o valor eh valido
@type function
/*/
User Function A103TotShell(nTotal)

Local aArea	   := GetArea()
Local nPQuant  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})
Local nPPreco  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VUNIT"})
Local nPTes    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"  })
Local nPQSegUm := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QTSEGUM"})
Local nQtSegUm := 0
Local nDif	   := 0
Local cTes     := ""
Local lRetorno := .T.
If nPQuant > 0 .And. nPPreco > 0
	nDif := Abs(NoRound(aCols[n][nPQuant]*aCols[n][nPPreco],2)-nTotal)
EndIf
If nPQSegUm > 0
	nQtSegUm := aCols[n][nPQSegUm]
EndIf
If nPTES > 0
	cTes := aCols[n][nPTES]
EndIf

// Total pela segunda unidade de medida
If GetMv("MV_CALC2UM")		// indica se irá recalcular o valor unitario pelo total caso exista 2 unidade de medida
	If nQtSegUm > 0 .And. nDif > 0.49
		aCols[n][nPPreco] := nTotal / aCols[n][nPQuant]
		If	MaFisFound("IT",n)
			MaFisAlt("IT_PRCUNI",aCols[n][nPPreco],n)
		EndIf
		nDif := Abs(NoRound(aCols[n][nPQuant]*aCols[n][nPPreco],2) - nTotal)
	EndIf
Endif


If cTipo$"NDB" .And. !MaTesSel(cTES) .aND. nDif > 0.00
	Help(" ",1,"TOTAL")
	lRetorno := .F.
EndIf

RestArea(aArea)
Return(lRetorno)

/*/{Protheus.doc} A440Grava
Gravacao da Liberacao do Pedido via WorkFlow
Observacao: Deve estar numa transacao
@author
@since 10.03.99
@version P11
@param lLiber, logical, Liberacao Parcial
@param lTransf, logical, Transfere Locais
@param cPedido, characters
@return lGravou, logical
@type function
/*/
User Function A440Grava(lLiber,lTransf,cPedido)

Local nQtdLib  	:= 0
Local lLiberOk 	:= .F.
Local lCredito 	:= .T.
Local lEstoque 	:= .T.
Local lItLib   	:= .F.
Local aEmpenho		:= {}
//Private aHeader	:= {}
//Private aCols   	:= {}

ChkFile("SE4")
ChkFile("SA1")
ChkFile("SB1")
ChkFile("SBM")
ChkFile("SCR")
ChkFile("SAL")
ChkFile("SC5")
ChkFile("SC6")
ChkFile("SCS")
ChkFile("SAK")
ChkFile("SM2")
ChkFile("SC9")
ChkFile("SB6")
ChkFile("SB2")

cPedido := Alltrim(cPedido)

dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+cPedido)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SC6                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC6")
dbSetOrder(1)
MsSeek(xFilial("SC6")+cPedido)
While !EOF() .And. C6_FILIAL+C6_NUM == xFilial("SC6")+cPedido
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a Liberacao do Pedido por Item de Pedido                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SC6->C6_QTDVEN <> 0 .Or. ( MaTesSel(SC6->C6_TES) .Or. Ma440Compl() )
		lItLib := .T.

		If FunName() != "SHEA014"
//			If ( SC5->C5_TIPLIB<>"2" )
                If FindFunction("U_QtdLibPV")
				   nQtdLib := U_QtdLibPV(SC6->C6_NUM,SC6->C6_ITEM,SC6->C6_QTDVEN-(SC6->C6_QTDEMP+SC6->C6_QTDENT),SC6->C6_PRODUTO,SC6->C6_LOCAL)
				Else
				   nQtdLib := SC6->C6_QTDVEN-(SC6->C6_QTDEMP+SC6->C6_QTDENT)
                EndIf

				If nQtdLib > 0
				    Begin Transaction //@ticket TVDSAJ - TI4449 – Ronaldo Carvalho – Inclusão Begin transaction.
						nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.T.,.T.,lLiber,.F.)
					End Transaction
				Endif
//			Endif
		Else
//			MaLibDoFat(nRegSC6,			nQtdaLib,			lCredito,	lEstoque,	lAvCred,	lAvEst,	lLibPar,	lTrfLocal,	aEmpenho,	bBlock,aEmpPronto,lTrocaLot,lOkExpedicao,nVlrCred,nQtdalib2)

			AADD(aEmpenho, SC6->C6_QTDVEN)
			MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,	.T.,			.F.,			.T.,		.F.,		.T.,		.T.,			aEmpenho)
   	Endif
   Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se Todos os Itens foram Liberados                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( SC6->C6_QTDVEN > SC6->C6_QTDEMP + SC6->C6_QTDENT .And. lLiberOk .And. AllTrim(SC6->C6_BLQ)<>"R")
		lLiberOk := .F.
	Else
		lLiberOk := .T.
	EndIf
	dbSelectArea("SC6")
	dbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Liberacao por Pedido                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( SC5->C5_TIPLIB == "2" .And. lItLib )
	MaAvLibPed(cPedido,lLiber,lTransf,@lLiberOk)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza do C5_LIBEROK                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lLiberOk )
	dbSelectArea("SC5")
	RecLock("SC5")
	SC5->C5_LIBEROK := "S"
	MsUnlock()
EndIf
MsUnLockAll()
Return(.T.)

/*/{Protheus.doc} A450Grava
Gravacao da Liberacao do Pedido via WorkFlow
Observacao:Deve estar numa transacao
@author Fabio Cesar Congilio
@since 10.03.99
@version P11
@param cPedido, characters
@type function
/*/

User Function A450Grava(cPedido)
//Local lQuery := .T.
Local cAliasSC9 := "A450LIBMAN"
Local cAliasSC5 := "A450LIBMAN"
Local cAliasSC6 := "A450LIBMAN"
Local cQuery    := ""

DbSelectArea("SC5")
DbSetOrder(1)
If DbSeek(xFilial("SC5")+cPedido,.F.)
	RecLock("SC5",.f.)
	SC5->C5_BLQ := " "
	MsUnlock()
	// 2014-07-02 = JJCONSUTING
	// WEBSALES - FAZ A ATUALIZACAO DO STATUS DO PEDIDO
	IF SC5->(FieldPos('C5_X_IDWS'))>0
		IF !EMPTY(SC5->C5_X_IDWS)
			cToken := U_WSGetToken()
			oWSPedido := WSWsPedido():new()
			IF oWSPedido:GetPedido(cToken,SC5->C5_X_IDWS)
				oPedido 	:= oWsPedido:oWSGetPedidoResult
				oPedido:nIdStatus  := U_JJGetStatusPV() // CAPTURA E RETORNA O STATUS DO PEDIDO
				oWSPedido:SetPedido( cToken, oPedido)
			ENDIF
		ENDIF
	ENDIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Liberacao para todos os itens do SC9                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC9")
dbSetOrder(1)
cQuery := "SELECT C9_FILIAL,C9_PEDIDO,C9_BLCRED,SC9.R_E_C_N_O_ SC9RECNO,SC5.C5_TIPLIB,"
cQuery += "ISNULL(SC5.R_E_C_N_O_,0) SC5RECNO,SC6.R_E_C_N_O_ SC6RECNO "
cQuery += "FROM "+RetSqlName("SC9")+" SC9,"
cQuery += RetSqlName("SC5")+" SC5,"
cQuery += RetSqlName("SC6")+" SC6 "
cQuery += "WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
cQuery += "SC9.C9_PEDIDO = '"+cPedido+"' AND "
cQuery += "SC9.C9_BLCRED <> '"+Space(Len(SC9->C9_BLCRED))+"' AND "
cQuery += "SC9.C9_BLCRED <> '09' AND "
cQuery += "SC9.C9_BLCRED <> '10' AND "
cQuery += "SC9.D_E_L_E_T_ = ' ' AND "
cQuery += "SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
cQuery += "SC5.C5_NUM=SC9.C9_PEDIDO AND "
cQuery += "SC5.D_E_L_E_T_ = ' ' AND "
cQuery += "SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
cQuery += "SC6.C6_NUM=SC5.C5_NUM AND "
cQuery += "SC6.C6_ITEM=SC9.C9_ITEM AND "
cQuery += "SC6.C6_PRODUTO=SC9.C9_PRODUTO AND "
cQuery += "SC6.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)
//Alteração realizada para atendimento ao chamado TFTMV5


//SC9->(DbSeek(xFilial("SC9")+(cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_SEQUEN+(cAliasSC9)->C9_PRODUTO))

While ((cAliasSC9)->( !Eof()) .And. (cAliasSC9)->C9_FILIAL == xFilial("SC9") .And.;
				(cAliasSC9)->C9_PEDIDO == cPedido )

	lProcessa := .T.
     SC9->(dbgoto((cAliasSC9)->SC9RECNO))
	If ( !Empty((cAliasSC9)->C9_BLCRED) .And. (cAliasSC9)->C9_BLCRED <> "10" )

		If (cAliasSC9)->C9_BLCRED == "09"
			lProcessa := .F.
		Endif
	Endif

 aRegSC6 := {}

	If lProcessa
		SC5->(MsGoto((cAliasSC5)->SC5RECNO))
		If (cAliasSC5)->C5_TIPLIB == "2"
			aadd(aRegSC6,(cAliasSC6)->SC6RECNO)
		Else
			SC9->(MsGoto((cAliasSC9)->SC9RECNO))
		EndIf
		a450Grava(1,.T.,.F.)
	EndIf
	dbSelectArea(cAliasSC9)
	dbSkip()
EndDo

dbSelectArea(cAliasSC9)
dbCloseArea()
dbSelectArea("SC9")
Return(.T.)

/*/{Protheus.doc} Delegantes
Retorna um array com os delegantes que deverao receber o
workflow para libera?o
@author Fabio Cesar Congilio
@since 15.08.2004
@version P11
@uso Generico
@param cTipo, characters, Tipo do Bloqueio
@param nValor, numeric, Valor Solicitado para Libera?o
@param aDele, array, Array com os Delegantes
@param cSuper, characters
@param cDoc, characters
@param dEmissao, date
@param cNivel, characters
@param cStatus, characters
@param cVendedor, characters, Vendedor
@param cTpDeleg, characters
@param nPrazoPed, numeric
@param nLimPrzCli, numeric
@param cTpCli, characters
@param nLCCli, numeric
@param nSldLC, numeric
@type function
/*/
User Function Delegantes(cTipo,nValor,aDele,cSuper,cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg,nPrazoPed,nLimPrzCli,cTpCli,nLCCli,nSldLC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de Variaveis                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nLimDoa			:= 0.00
Local nLimPer  	   		:= 0.00
Local nLimRem			:= 0.00
Local nLimDesc			:= 0.00
Local nLimPrzVend		:= 0.00
Local nLimCreVend		:= 0.00
Local nLimCre	 		:= 0.00
Local nLimCred 			:= 0.00
Local aSuper			:= {"","","","","","","","","",""}
Local cNvlAprov			:= ""
Local lAprovObrig		:= .F.
Local lAprovDesp		:= .F.
//Local cTpLC			:= GetMV("MV_TPLCWF",,"1")
Default cTpDeleg		:= "1"
Default nPrazoPed		:= 0
Default nLimPrzCli		:= 0
Default cTpCli			:= " "
Default nLCCli			:= 0.00

// Caso não encontre o superior não gera o SCR
If Empty(cSuper)
	//	aDele := {}
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o superior do aprovador                                       							|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB1")
DbSetOrder(1)
If DbSeek(xFilial("PB1")+cVendedor+cTpDeleg,.f.)
	cNvlAprov := ""
	While !EOF() .and. PB1->PB1_FILIAL+PB1->PB1_VEND+PB1->PB1_TPALC == xFilial("PB1")+cVendedor+cTpDeleg
		If PB1->PB1_APROV == cSuper
			cNvlAprov		:= PB1->PB1_NIVEL
			lAprovObrig		:= PB1->PB1_OBRIG == "S"
			If (alltrim(GetNewPAr("ES_FUSUS","INVALIDO")) $ SM0->M0_FILIAL)
				lAprovDesp		:= PB1->PB1_APDESP == "S"
			EndIf
			aSuper[2]		:= PB1->PB1_APROV
			aSuper[3]		:= Posicione("SA3",1,xFilial("SA3")+PB1->PB1_APROV,"A3_CODUSR")
			Exit
		Endif
		DbSelectArea("PB1")
		DbSkip()
	Enddo
	DbSeek(xFilial("PB1")+cVendedor+cTpDeleg,.f.)
	While !EOF() .and. PB1->PB1_FILIAL+PB1->PB1_VEND+PB1->PB1_TPALC == xFilial("PB1")+cVendedor+cTpDeleg
		If PB1->PB1_NIVEL > cNvlAprov .and. !Empty(cNvlAprov)
			aSuper[1]	:= PB1->PB1_APROV
			Exit
		Endif
		DbSelectArea("PB1")
		DbSkip()
	Enddo
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina o limite de doacao                   						   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB5")
DbSetOrder(2)
If DbSeek(xFilial("PB5")+cTpDeleg+cVendedor+cSuper,.F.)
	nLimDoa		:= PB5->PB5_LIMFIM
	aSuper[4]	:= PB5->PB5_DELEG
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina o limite de remessa                  						   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB6")
DbSetOrder(2)
If DbSeek(xFilial("PB6")+cTpDeleg+cVendedor+cSuper,.F.)
	nLimRem		:= PB6->PB6_LIMFIM
	aSuper[5]	:= PB6->PB6_DELEG
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina o limite de desconto                 						   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB4")
DbSetOrder(2)
If DbSeek(xFilial("PB4")+cTpDeleg+cVendedor+cSuper,.F.)
	nLimDesc	:= PB4->PB4_LIMFIM
	aSuper[6]	:= PB4->PB4_DELEG
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina o prazo medio em dias                						   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB8")
DbSetOrder(2)
If DbSeek(xFilial("PB8")+cTpDeleg+cVendedor+cSuper,.F.)
	// Alterado em 12/12/06 conforme solicitacao Flavio Mansur
	If cTpDeleg == "3"
		nLimPrzVend	:= PB8->PB8_PRZCF
	Else
		If cTpCli <> "F"
			//nLimPrzVend	:= U_PrzVend(aSuper[2])  //SA3->A3_MAXPRZ
			//nLimPrzVend	:= U_PrzValor(aSuper[2])  //SA3->A3_MAXPRZ
			nLimPrzVend	:= PB8->PB8_PRZCF //ALTERADO EM 20/10/2008 SOLICITADO PELO FLÁVIO
		Else
			nLimPrzVend	:= PB8->PB8_PRZCF
		Endif
	Endif
	aSuper[10]	:= PB8->PB8_DELEG
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina o limite de credito                  						   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB7")
DbSetOrder(2)
If DbSeek(xFilial("PB7")+cTpDeleg+cVendedor+cSuper,.F.)
	nLimCreVend	:= ((PB7->PB7_LIMFIM*PB7->PB7_MARGEM)/100)

	/*If cTpLC == "2"
		//nLimCreVend	:= PB7->PB7_LIMFIM+((PB7->PB7_LIMFIM*PB7->PB7_MARGEM)/100)
		// Alterado em 12/12/06 conforme solicitacao Flavio Mansur
		nLimCreVend	:= ((PB7->PB7_LIMFIM*PB7->PB7_MARGEM)/100)
	Else
		// Alterado em 12/12/06 conforme solicitacao Flavio Mansur
		// nLimCreVend	:= nLCCli+(nLCCli*(PB7->PB7_MARGEM/100))
		nLimCreVend	:= (nLCCli*(PB7->PB7_MARGEM/100))
	Endif
	*/
	aSuper[7]	:= PB7->PB7_DELEG
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina o limite em dias                     						   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB2")
DbSetOrder(2)
If DbSeek(xFilial("PB2")+cTpDeleg+cVendedor+cSuper,.F.)
	If cTipo == "R2"
		nLimCre	:= PB2->PB2_LIMVLR
	ElseIf cTipo == "R5"
		nLimCre	:= PB2->PB2_LIMFIM
	Endif
	aSuper[8]	:= PB2->PB2_DELEG
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determina o limite de Perdas                   		                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PB3")
DbSetOrder(2)
If DbSeek(xFilial("PB3")+cTpDeleg+cVendedor+cSuper,.F.)
	nLimPer		:= PB3->PB3_LIMFIM
	aSuper[9]	:= PB3->PB3_DELEG
	If cTpDeleg	== "1" .And. cTipo == "S3"
		If nLimPer < nValor
			aSuper[9]	:= "N"
		EndIf
	EndIf
Endif

/*
If cTpDeleg == "1"
	cStatus := "02"
Else
	cStatus := "01"
Endif
*/

If cTpDeleg == "1" .And. cTipo != "S3"
	cStatus := "02"
ElseIf cTpDeleg	== "4"
	cStatus := "02"
Else
	cStatus := "01"
Endif

Do Case
	Case cTipo == "R3" .and. (cTpDeleg == "1" .or. cTpDeleg == "3")   // Prazo Médio
		//If (nValor > nLimPrzVend .or. (nPrazoPed > nLimPrzCli .and. nLimPrzCli > 0)) .And. !Empty(aSuper[1]) .and. aSuper[10] == "S"
		If (nValor > nLimPrzVend) .And. !Empty(aSuper[1]) .and. aSuper[10] == "S"
			If lAprovObrig
				AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
			 	cStatus:= "01"
			Endif
			u_Delegantes("R3",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg,nPrazoPed,nLimPrzCli,cTpCli) //, nDoaPed, nRemPed, nDescPed)
	  	ElseIf aSuper[10] == "N"
			u_Delegantes("R3",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg,nPrazoPed,nLimPrzCli,cTpCli) //, nDoaPed, nRemPed, nDescPed)
		ElseIf !Empty(aSuper[2])
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"1",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		EndIf
	Case cTipo == "S1" .and. cTpDeleg == "1"   // Doacao
		If nValor > nLimDoa .and. nValor > 0 .And. !Empty(aSuper[1]) .and. aSuper[4] == "S"
			If lAprovObrig
		 		AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
			 	cStatus:= "01"
			Endif
			u_Delegantes("S1",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
	  	ElseIf aSuper[4] == "N"
			u_Delegantes("S1",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
		ElseIf !Empty(aSuper[2])
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"1",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		EndIf
	Case cTipo == "S2" .and. cTpDeleg == "1"    // Remessa
		If nValor > nLimRem .and. nValor > 0 .And. !Empty(aSuper[1]) .and. aSuper[5] == "S"
			If lAprovObrig
				AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
				cStatus:= "01"
  			Endif
			u_Delegantes("S2",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
	  	ElseIf aSuper[5] == "N"
			u_Delegantes("S2",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
		ElseIf !Empty(aSuper[2])
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"1",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		EndIf
	Case cTipo == "S3" .and. (cTpDeleg == "1" .or. cTpDeleg == "2" .or. cTpDeleg == "4")    // Perdas
		If nValor < nLimPer .and. nValor > 0 .And. aSuper[9] == "S" .And. cTpDeleg == "4"
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
			cStatus:= "01"
//		ElseIf nValor > nLimPer .and. nValor > 0 .And. !Empty(aSuper[1]) .and. aSuper[9] == "S"
		ElseIf nValor < nLimPer .and. nValor > 0 .And. !Empty(aSuper[1]) .and. aSuper[9] == "S"
			//If lAprovObrig
				AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
				cStatus:= "01"
  			//Endif
			//u_Delegantes("S3",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
	  	ElseIf aSuper[9] == "N"
			u_Delegantes("S3",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
		ElseIf !Empty(aSuper[2])
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"1",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		EndIf
	Case cTipo == "R4" .and. (cTpDeleg == "1" .or. cTpDeleg == "3")   // Desconto
		If nValor > nLimDesc .And. !Empty(aSuper[1]) .and. aSuper[6] == "S"
  			If lAprovObrig
				AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
	  			cStatus:= "01"
  			Endif
			u_Delegantes("R4",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
	  	ElseIf aSuper[6] == "N"
			u_Delegantes("R4",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
		ElseIf !Empty(aSuper[2])
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"1",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		EndIf
	Case cTipo == "R1"  .and. (cTpDeleg == "1" .or. cTpDeleg == "2") // Limite de credito
	  	//nLimCred := xMoeda(SA1->A1_LC,IIf(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(SuperGetMv("MV_MCUSTO"))),1,dDataBase,2)// + (xMoeda(SA1->A1_LC,IIf(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(SuperGetMv("MV_MCUSTO"))),1,dDataBase,2))// * (nLimCre/100))
	  	nLimCred := nLimCreVend
	  	If (nValor > nSldLC) .and. (nValor-nSldLC > nLimCred .And. !Empty(aSuper[1]) .and. aSuper[7] == "S")
  			If lAprovObrig
				AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
				cStatus:= "01"
  			Endif
			U_Delegantes("R1",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg,,,,nLCCli,nSldLC)
	  	ElseIf aSuper[7] == "N"
			U_Delegantes("R1",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg,,,,nLCCli,nSldLC)
		ElseIf !Empty(aSuper[2])
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"1",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		EndIf
	Case (cTipo == "R2" .or. cTipo == "R5") .and. (cTpDeleg == "1" .or. cTpDeleg == "2")   // Dias Vencidos
  		If nValor > nLimCre .And. !Empty(aSuper[1]) .and. aSuper[8] == "S"
			If lAprovObrig
				AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		  		cStatus:= "01"
  			Endif
			U_Delegantes(cTipo,nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
	  	ElseIf aSuper[8] == "N"
			U_Delegantes(cTipo,nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg)
		ElseIf !Empty(aSuper[2])
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"1",StrZero(99-Val(cNvlAprov),2),Iif(lAprovObrig,"S","N"),cTpDeleg})
		EndIf
	//-------------
	Case cTipo == "D1"
		If lAprovDesp
			AADD(aDele,{cDoc,cTipo,nValor,aSuper[2],aSuper[3],aSuper[1],dEmissao,cNivel,cStatus,"0",StrZero(99-Val(cNvlAprov),2),"S",cTpDeleg})
		 	cStatus:= "01"
		Endif
		u_Delegantes("D1",nValor,@aDele,aSuper[1],cDoc,dEmissao,cNivel,cStatus,cVendedor,cTpDeleg,nPrazoPed,nLimPrzCli,cTpCli) //, nDoaPed, nRemPed, nDescPed)

End Case

Return (.T.)

/*/{Protheus.doc} AlcDoc1
Controla a alcada dos documentos   SCR-Bloqueios
@author Fabio Cesar Congilio
@since 15.08.2004
@version P11
@uso Generico
@param aDocto, array, Array com informacoes do documento
 [1] Numero do documento
 [2] Tipo de Documento
 [3] Valor do Documento
 [4] Codigo do Aprovador
 [5] Codigo do Usuario
 [6] Aprovador Superior
 [7] Data de Emissao do Documento
 [8] Nivel do Aprovador
 [9] Observacao
 [10]Status
 [11]Motivos
@param nOper, numeric, Operacao a ser executada
 1 = Inclusao do documento
 2 = Estorno do documento
 3 = Exclusao do documento
 4 = Aprovacao do documento
 5 = Estorno da Aprovacao
 6 = Bloqueio Manual da Aprovacao
@type function
/*/
User Function AlcDoc1(aDocto,nOper)
Local aArea		:= GetArea()
Local aAreaSCR	:= SCR->(GetArea())
Local cDocto	:= aDocto[1]
Local cTipoDoc	:= aDocto[2]
Local nValDcto	:= aDocto[3]
Local cAprov	:= If(aDocto[4] == Nil, "",   aDocto[4])
Local cUsuario	:= If(aDocto[5] == Nil, "",   aDocto[5])
Local cNivel	:= If(aDocto[8] == Nil, "02", aDocto[8])
Local cStatus	:= aDocto[9]
Local cMotivo	:= aDocto[11]
Local lRetorno	:= .T.
Local lAchou	:= .F.
Local lIncReg	:= .T. //280025

cDocto := cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))

If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial()+cAprov)
	cUsuario :=	A3_CODUSR
EndIf

/*=======================
  Inclusao do Documento
=======================*/
If nOper == 1

	//@ticket 280025 - T10532 - José Carlos Jr. - Gerando SCR a cada "Alterar Pedido".
	If Altera
		SCR->(dbSetOrder(1))
		lIncReg := !(SCR->(dbSeek(xFilial("SCR") + cTipoDoc + cDocto)) .AND. SubStr(SCR->CR_TIPO, 1, 1) $ "SR") //280025 - Lógica de exclusão de dados existente no MAAVCRED(~878) e retirado do MTA410(~388).
	EndIf

	Reclock("SCR", lIncReg)
		SCR->CR_FILIAL	:= xFilial("SCR")
		SCR->CR_NUM		:= cDocto
		SCR->CR_TIPO	:= cTipoDoc
		SCR->CR_NIVEL	:= cNivel
		SCR->CR_USER	:= cUsuario
		SCR->CR_APROV	:= cAprov
		SCR->CR_STATUS	:= cStatus
		SCR->CR_TOTAL	:= nValDcto
		SCR->CR_EMISSAO	:= aDocto[7]
		SCR->CR_MOTIVO	:= IIf(cTipoDoc == "D1",cTipoDoc,cMotivo)
	SCR->(MsUnlock())
EndIf

/*=======================
  Exclusao do documento
=======================*/
If nOper == 3
	dbSelectArea("SCR")
	dbSetOrder(1)
	dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
	While !Eof() .And. SCR->CR_FILIAL+SUBSTRING(SCR->CR_TIPO,1,1)+SCR->CR_NUM == xFilial("SCR")+SUBSTRING(cTipoDoc,1,1)+cDocto
		Reclock("SCR",.F.,.T.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf

/*=======================
  Aprovacao do documento
=======================*/
If nOper == 4
	// Atualiza o saldo do aprovador.
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial()+cAprov)

	// Libera o pedido pelo aprovador.
	dbSelectArea("SCR")
	cAuxNivel := CR_NIVEL
	Reclock("SCR",.F.)
	dbSetOrder(1)
	CR_STATUS	:= "03"
	CR_ZZOBS	:= If(Len(aDocto)>8,aDocto[9],"")
	CR_DATALIB	:= dDataBase
	CR_USERLIB	:= cUsuario
	CR_LIBAPRO	:= SA3->A3_COD
	CR_VALLIB	:= nValDcto
	MsUnlock()
	dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
	nRec := RecNo()
	While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc == CR_FILIAL+CR_NUM+CR_TIPO
		If CR_NIVEL > cAuxNivel .And. CR_STATUS != "03" .And. !lAchou
			lAchou := .T.
			cNextNiv := CR_NIVEL
		EndIf
		If lAchou .And. CR_NIVEL == cNextNiv .And. CR_STATUS != "03"
			Reclock("SCR",.F.)
			CR_STATUS := "02"
			MsUnlock()
		Endif
		dbSkip()
	EndDo

	// Reposiciona e verifica se ja esta totalmente liberado.
	dbGoto(nRec)
	While !Eof() .And. xFilial("SCR")+cTipoDoc+cDocto == CR_FILIAL+CR_TIPO+CR_NUM
		If CR_STATUS != "03"
			lRetorno := .F.
		EndIf
		dbSkip()
	EndDo
EndIf

/*=======================
  Estorno da Aprovacao
=======================*/
//If nOper == 5 //Atualmente sem utilizacao deste trecho
//EndIf

/*=======================
  Bloqueio Manual
=======================*/
If nOper == 6
	Reclock("SCR",.F.)
	CR_STATUS := "04"
	CR_ZZOBS  := If(Len(aDocto)>7,aDocto[8],"")
	CR_DATALIB:= dDataBase
	MsUnlock()
	lRetorno := .F.
EndIf

dbSelectArea("SCR")
RestArea(aAreaSCR)
RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} ConsBloq
Cria uma tela de consulta do status do pedido de vendas.
@author Fabio Cesar Congilio
@since 15.08.2004
@version P11
@uso Generico
@param ctip, characters
@type function
/*/
User Function ConsBloq(ctip)
LOCAL bCampo
LOCAL oDlg, oGet
LOCAL nAcols := 0,nOpca := 0
LOCAL cCampos
LOCAL cSituaca	:= "",lBloq := .F.
LOCAL cPedido
LOCAL cComprador
LOCAL cStatus
LOCAL aSavCols 	:= {}
LOCAL aSavHead 	:= {}
LOCAL nSavN		:= 0
LOCAL oBold
Local aArea 	:= GetArea()
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSCR	:= SCR->(GetArea())
Local nOpcx 	:= 2
Local lAchou	:= .F.
Local lFirst 	:= .T.
Local aMotivo   := {}
Local nCntFor
//Local aCols := {}
//Local aHeader := {}
Local nI := 0
If ctip <> 2
	aSavCols 	:= aClone(aCols)
	aSavHead 	:= aClone(aHeader)
	nSavN		:= n
EndIf
dbSelectArea("SC5")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se existe a area TMP        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TMP") > 0
	DbSelectArea("TMP")
	DbCloseArea()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo SCR sem filtros    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkFile("SCR",.F.,"TMP")
cPedido := SC5->C5_NUM
cComprador := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NREDUZ") //'UsrRetName(SC7->C7_USER)
//cStatus  := IIF(SC7->C7_CONAPRO=="L",OemToAnsi(STR0001),OemToAnsi(STR0002)) //"PEDIDO LIBERADO"#"AGUARDANDO LIB."

aCols := {}
aHeader := {}

dbSelectArea("TMP")
//dbSetOrder(1)
IndRegua("TMP",CriaTrab(Nil,.F.),"CR_FILIAL+CR_NUM+CR_TIPO+CR_NIVEL")
dbSeek(xFilial("SCR") + SC5->C5_NUM,.T.)

While !EOF() .and. AllTrim(CR_NUM) == SC5->C5_NUM
	If !(Substr(TMP->CR_TIPO,1,1))$"SRD"
		Dbskip()
		Loop
	Else
		lAchou := .T.
		Exit
	EndIf
EndDo

If !lAchou
	Aviso("Bloqueios do Pedido","Não foram encontrados bloqueios gerados para este pedido até o momento",{"Ok"})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aTELA[0][0],aGETS[0],Continua,nUsado:=0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem do aHeader com os campos fixos.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aHeader,{ OemToAnsi("Usuario"),"bCR_NOME", "@",15, 0, "","","C","",""} )
	nUsado++
	AADD(aHeader,{ OemToAnsi("Situacao"),"bCR_SITUACA", "@",20, 0, "","","C","",""} )
	nUsado++
	AADD(aHeader,{ OemToAnsi("Usuario Lib."),"bCR_NOMELIB", "@",15, 0, "","","C","",""} )
	nUsado++

	cCampos := "CR_ZZOBS/CR_DATALIB"
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SCR")
	While !EOF() .And. (x3_arquivo == "SCR")
		IF AllTrim(x3_campo)$cCampos
			nUsado++
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
			If AllTrim(x3_campo) == "CR_ZZOBS"
			EndIf
		Endif
		dbSkip()
	End

	dbSelectArea("TMP")
	While	!Eof() .And. CR_FILIAL+Alltrim(CR_NUM) == xFilial("SCR")+SC5->C5_NUM
		If !(Substr(TMP->CR_TIPO,1,1))$"SRD"
			Dbskip()
			Loop
		Endif

		aadd(aCols,Array(nUsado+1))
		nAcols ++

		For nCntFor := 1 To nUsado
			If aHeader[nCntFor][02] == "bCR_NOME"
				aCols[nAcols][nCntFor] := UsrRetName(TMP->CR_USER)
			ElseIf aHeader[nCntFor][02] == "bCR_TIPO"
				aCols[nAcols][nCntFor]	:= Posicione("SX5",1,xFilial("SX5")+"P3"+TMP->CR_TIPO,"X5_DESCRI")
			ElseIf aHeader[nCntFor][02] == "bCR_SITUACA"
				Do Case
					Case TMP->CR_STATUS == "01"
						cSituaca := OemToAnsi("Aguardando")
					Case TMP->CR_STATUS == "02"
						cSituaca := OemToAnsi("Em Aprovacao")
					Case TMP->CR_STATUS == "03"
						cSituaca := OemToAnsi("Aprovado")
					Case TMP->CR_STATUS == "04"
						cSituaca := OemToAnsi("Rejeitado")
						lBloq := .T.
				EndCase
				aCols[nAcols][nCntFor] := cSituaca
			ElseIf aHeader[nCntFor][02] == "bCR_NOMELIB"
				aCols[nAcols][nCntFor] := UsrRetName(TMP->CR_USERLIB)
			ElseIf ( aHeader[nCntFor][10] != "V")
				aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))

			EndIf
		Next nCntFor
		aCols[nAcols][nUsado+1] := .F.

		If lFirst
			lFirst := .T.
			For nI := 1 To Len(Alltrim(CR_MOTIVO)) Step 2
			    If aScan(aMotivo,{|x|  Substring(CR_MOTIVO,nI,2) $ x})== 0
					AADD(aMotivo,Substring(CR_MOTIVO,nI,2)+"-"+Tabela("P4",Substring(CR_MOTIVO,nI,2)))
				EndIf
			Next
		Endif

		dbSkip()
	EndDo

	If Empty(aCols)
		aCols := aClone(aSavCols)
 		aHeader := aClone(aSavHead)
		dbSelectArea("TMP")
		//dbCloseArea("TMP")
		Return nOpca
	EndIf

	If lBloq
		cStatus := OemToAnsi("PEDIDO BLOQUEADO")
	EndIf

	Continua := .F.
	nOpca := 0
	cLegenda := "Bloqueios"
	If cTip <> 2
	n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localizações
	EndIf
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg TITLE "Aprovacao do Pedido de Venda" From 109,95 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra"
	@ 5,3 TO 32,250 LABEL "" OF oDlg PIXEL
	@ 15,7 SAY OemToAnsi("Pedido") Of oDlg FONT oBold PIXEL SIZE 46,9 // "Pedido"
	@ 14,32 MSGET cPedido  Picture "@"  When .F. PIXEL SIZE 38,9 Of oDlg FONT oBold
	@ 15,103 SAY OemToAnsi("Vendedor")  Of oDlg PIXEL SIZE 33,9 FONT oBold //"Comprador"
	@ 14,138 MSGET cComprador Picture "@" When .F. of oDlg PIXEL SIZE 103,9 FONT oBold
	@ 132,8 SAY "Situacao" Of oDlg PIXEL SIZE 52,9 //'Situacao :'
	@ 132,38 SAY cStatus Of oDlg PIXEL SIZE 120,9 FONT oBold
	@ 132,205 BUTTON "Fechar" SIZE 35 ,10  FONT oDlg:oFont ACTION (oDlg:End()) Of oDlg PIXEL  //'Fechar'

//	@ 110,7 LISTBOX oListBox VAR cLegenda ITEMS aMotivo PIXEL SIZE 150, 30 OF oDlg MULTI
	@ 95,4 LISTBOX oListBox VAR cLegenda ITEMS aMotivo PIXEL SIZE 245, 30 OF oDlg //MULTI

//	oGet := MSGetDados():New(38,3,120,250,nOpcx,,,"")
	oGet := MSGetDados():New(38,3,090,250,nOpcx,,,"")
	@ 126,2   TO 127,250 LABEL '' OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

EndIf
If ctip <> 2
aCols :={}
aCols := aClone(aSavCols)
aHeader :={}
aHeader := aClone(aSavHead)
n		:= nSavN
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se existe a area TMP        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TMP") > 0
	DbSelectArea("TMP")
	DbCloseArea()
EndIf

RestArea(aAreaSC5)
RestArea(aAreaSCR)
RestArea(aArea)

Return nOpca

/*/{Protheus.doc} S030VLRFRT
Calculo do frete da nota de saida ou entrada
@author F?io S dos Santos
@since 22/05/07
@version P11
@uso Shell/Fusus
@param nOpcao, numeric
@param  cDoc, characters
@param  cSerie, characters
@param  cCliente, characters
@param  cLoja, characters
@param  cTrans, characters
@param  cCarga, characters
@param  dDataIni, date
@param  dDataFim, date
@type function
/*/
User Function S030VLRFRT(nOpcao, cDoc, cSerie, cCliente, cLoja, cTrans, cCarga, dDataIni, dDataFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cQuery		:= ""
Local cArquivo		:= ""
Local aStru			:= {}
Local nTotCalc		:= 0.00
Local aRotas		:= {}
Local cTransp		:= ""
Local nPosArr		:= 0
Local nPosNota		:= 0
Local nX			:= 0
Local nY			:= 0
Local nTotFat		:= 0.00
Local nTotPeso		:= 0.00
Local nTotFixo		:= 0.00
Local aNotas		:= {}
Local aArred		:= {}
Local nPerc			:= 0.00
Local nFrtDev		:= 0.00
Local nTotNfOri	    := 0.00
Local nPesNfOri		:= 0.00
Local nFrtNfOri		:= 0.00
Local aTotNfOri		:= {0.00,0.00}
Local aIdentDev		:= {}
Local aConhEsp		:= {}
Local aNfEsp		:= {}
Local cIdent		:= "000000"
Local cInd1			:= ""
Local cInd2			:= ""
Local cInd3			:= ""
Local aIdent		:= {}

Private nTotFrete	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a estrutura do arquivo temporario                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aStru, {"PAI_IDENT",	"C",006,000})
Aadd(aStru, {"PAI_NOTA",	"C",006,000})
Aadd(aStru, {"PAI_SERIE",	"C",003,000})
Aadd(aStru, {"PAI_TPNF",	"C",001,000})
Aadd(aStru, {"PAI_CLIENT",	"C",006,000})
Aadd(aStru, {"PAI_LOJA",	"C",002,000})
Aadd(aStru, {"PAI_EMISNF",	"D",008,000})
Aadd(aStru, {"PAI_DTCRG",	"D",008,000})
Aadd(aStru, {"PAI_NOMCLI",	"C",040,000})
Aadd(aStru, {"PAI_OPER",	"C",001,000})
Aadd(aStru, {"PAI_TPCALC",	"C",001,000})
Aadd(aStru, {"PAI_TRANSP",	"C",006,000})
Aadd(aStru, {"PAI_ROTA",	"C",006,000})
Aadd(aStru, {"PAI_REENTR",	"N",002,000})
Aadd(aStru, {"PAI_FATNF",	"N",012,002})
Aadd(aStru, {"PAI_PESONF",	"N",012,004})
Aadd(aStru, {"PAI_FRTMIN",	"N",012,002})
Aadd(aStru, {"PAI_FRETE",	"N",012,002})
Aadd(aStru, {"PAI_SEGURO",	"N",012,002})
Aadd(aStru, {"PAI_PEDAGI",	"N",012,002})
Aadd(aStru, {"PAI_TXENTR",	"N",012,002})
Aadd(aStru, {"PAI_DEVOL",	"N",012,002})
Aadd(aStru, {"PAI_TOTAL",	"N",012,002})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo temporario                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArquivo := CriaTrab(aStru,.T.)
cInd1    := CriaTrab(,.F.)
cInd2    := CriaTrab(,.F.)
cInd3    := CriaTrab(,.F.)
dbUseArea(.T.,,cArquivo,"PAITRB",.F.,.F.)
IndRegua("PAITRB",cInd1,"PAI_IDENT+PAI_NOTA+PAI_SERIE")
IndRegua("PAITRB",cInd2,"PAI_NOTA+PAI_SERIE+PAI_CLIENT+PAI_LOJA+PAI_TPNF")
IndRegua("PAITRB",cInd3,"PAI_TRANSP+PAI_CLIENT+PAI_LOJA+DTOS(PAI_DTCRG)")
DbSelectArea("PAITRB")
DbClearIndex()
DbSetIndex(cInd1+OrdBagExt())
DbSetIndex(cInd2+OrdBagExt())
DbSetIndex(cInd3+OrdBagExt())
If nOpcao == 1//nota de saida
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a query de selecao das notas fiscais a serem processadas           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery  := " SELECT DAI.DAI_DATA, SF2.F2_CLIENTE, SF2.F2_LOJA, F2_TRANSP "+Chr(13)+Chr(10)
	cQuery	+= " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("SD2")+" SD2 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK)"+Chr(13)+Chr(10)
	cQuery	+= " WHERE F2_FILIAL = '"+xFilial("SF2")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_EMISSAO BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_DOC BETWEEN '"+cDoc+"' AND '"+cDoc+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_SERIE BETWEEN '"+cSerie+"' AND '"+cSerie+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_CLIENTE BETWEEN '"+cCliente+"' AND '"+cCliente+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_LOJA BETWEEN '"+cLoja+"' AND '"+cLoja+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_TRANSP BETWEEN '"+cTrans+"' AND '"+cTrans+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_TRANSP <> '      '"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_FILIAL = '"+xFilial("SD2")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_DOC = F2_DOC"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_SERIE = F2_SERIE"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_CLIENTE = F2_CLIENTE"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_LOJA = F2_LOJA"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_COD BETWEEN '"+cCarga+"' AND '"+cCarga	+"'"+Chr(13)+Chr(10)
	//cQuery	+= " AND DAI_COD = F2_CARGA"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_SEQCAR = F2_SEQCAR"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_SEQUEN = F2_SEQENT"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_PEDIDO = D2_PEDIDO"+Chr(13)+Chr(10)
	cQuery	+= " AND SF2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND SD2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery  += " GROUP BY DAI.DAI_DATA, SF2.F2_CLIENTE, SF2.F2_LOJA, F2_TRANSP "

	If Select("SF2TRB") > 0
		DbSelectArea("SF2TRB")
		DbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SF2TRB",.T.,.T.)

	DbSelectArea("SF2TRB")
	dbGoTop()
	While !EOF()
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a query de selecao das notas fiscais a serem processadas           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery	:= " SELECT SF2.R_E_C_N_O_ AS RECSF2"+Chr(13)+Chr(10)
		cQuery	+= " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK),"+Chr(13)+Chr(10)
		cQuery	+= "      "+RetSqlName("SD2")+" SD2 (NOLOCK),"+Chr(13)+Chr(10)
		cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK)"+Chr(13)+Chr(10)
		cQuery	+= " WHERE F2_FILIAL = '"+xFilial("SF2")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_CLIENTE = '"+SF2TRB->F2_CLIENTE+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_LOJA = '"+SF2TRB->F2_LOJA+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_TRANSP  = '"+SF2TRB->F2_TRANSP+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_FILIAL = '"+xFilial("SD2")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_DOC = F2_DOC"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_SERIE = F2_SERIE"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_CLIENTE = F2_CLIENTE"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_LOJA = F2_LOJA"+Chr(13)+Chr(10)
		cQuery	+= " AND SD2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_DATA = '"+SF2TRB->DAI_DATA+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_COD = F2_CARGA"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_SEQCAR = F2_SEQCAR"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_SEQUEN = F2_SEQENT"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_PEDIDO = D2_PEDIDO"+Chr(13)+Chr(10)
		cQuery	+= " AND SF2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " GROUP BY SF2.R_E_C_N_O_"+Chr(13)+Chr(10)
		//cQuery	+= " ORDER BY SF2.F2_DOC, SF2.F2_SERIE"+Chr(13)+Chr(10)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a query retornando os registros                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("SF2NF") > 0
			DbSelectArea("SF2NF")
			DbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SF2NF",.T.,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reinicializa as variaveis utilizadas                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotCalc	:= 0.00
		aRotas		:= {}
		nTotFat		:= 0.00
		nTotPeso	:= 0.00
		nTotFixo	:= 0.00
		cIdent		:= Soma1(cIdent,6)

		DbSelectArea("SF2NF")
		dbGoTop()
		While !EOF()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no SF2                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF2")
			DbGoTo(SF2NF->RECSF2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define a transportadora da nota fiscal                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTransp		:= SF2->F2_TRANSP

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define a rota utilizada por Item da nota fiscal                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SD2")
			DbSetOrder(3)
			DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.f.)
			While !EOF() .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no cadastro de produtos                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SB1")
				DbSetOrder(1)
				MsSeek(xFilial("SB1")+SD2->D2_COD,.f.)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona no array os dados das rotas utilizadas                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("DAI")
				dbSetOrder(1)
				If MsSeek(xFilial("DAI")+SF2->F2_CARGA+SF2->F2_SEQCAR+SF2->F2_SEQENT+SD2->D2_PEDIDO,.F.)
					nPosArr := aScan(aRotas,{|x| x[1] == DAI->DAI_PERCUR .and. x[2] == DAI->DAI_ROTA .and. x[3] == DAI->DAI_ROTEIR})
					If nPosArr == 0
						aNotas	:= {{	SD2->D2_DOC,;														//1 - Nota Fiscal
											SD2->D2_SERIE,;													//2 - Serie
											SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_ICMSRET,;			        //3 - Total Faturado
											SB1->B1_PESBRU * SD2->D2_QUANT,;						     	//4 - Peso
											0.00,;															//5 - Valor do Frete
											0.00,;															//6 - Valor do Pedagio
											0.00,;															//7 - Valor do Seguro
											0.00,;															//8 - Valor da Taxa de Entrega
											0.00,;															//9 - Valor da Devolucao
											SF2->(Recno()),;												//10 - Recno SF2
											0.00}}															//11 - Valor do Frete Minimo

						Aadd(aRotas, {	DAI->DAI_PERCUR,;                                 					//1 - Rota
											DAI->DAI_ROTA,;													//2 - Zona
											DAI->DAI_ROTEIR,;												//3 - Setor
											SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_ICMSRET,;					//4 - Vlr Faturado
											SB1->B1_PESBRU * SD2->D2_QUANT,;								//5 - Peso
											0,;																//6 - Recno tabela de calculo
											0.00,;															//7 - Valor do Frete Minimo
											"",;															//8 - Tipo de calculo do frete
											0.00,;															//9 - Valor do Frete
											0.00,;															//10 - Valor do Pedagio
											0.00,;															//11 - Valor do Seguro
											0.00,;															//12 - Valor da Taxa de Entrega
											0.00,;															//13 - Valor da Devolucao
											aNotas})														//14 - Notas fiscais que compoe a rota
					Else
						aNotas 	:= aClone(aRotas[nPosArr,14])
						nPosNota	:= aScan(aNotas,{|x| x[1] == SD2->D2_DOC .and. x[2] == SD2->D2_SERIE})
						If nPosNota == 0
							Aadd(aNotas, {	SD2->D2_DOC,;														//1 - Nota Fiscal
												SD2->D2_SERIE,;													//2 - Serie
												SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_ICMSRET,;			        //3 - Total Faturado
												SB1->B1_PESBRU * SD2->D2_QUANT,;								//4 - Peso
												0.00,;															//5 - Valor do Frete
												0.00,;															//6 - Valor do Pedagio
												0.00,;															//7 - Valor do Seguro
												0.00,;															//8 - Valor da Taxa de Entrega
												0.00,;															//9 - Valor da Devolucao
												SF2->(Recno()),;												//10 - Recno SF2
												0.00})															//11 - Valor do Frete Minimo
						Else
							aNotas[nPosNota,3] += SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_ICMSRET
							aNotas[nPosNota,4] += SB1->B1_PESBRU * SD2->D2_QUANT
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o array de rotas                                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRotas[nPosArr,4] 	+= SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_ICMSRET
						aRotas[nPosArr,5] 	+= SB1->B1_PESBRU * SD2->D2_QUANT
						aRotas[nPosArr,14] 	:= aClone(aNotas)
					Endif
				Endif
				DbSelectArea("SD2")
				DbSkip()
			Enddo

			DbSelectArea("SF2NF")
		   DbSkip()
		EndDo
		If Select("SF2NF") > 0
			DbSelectArea("SF2NF")
			DbCloseArea()
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existem os dados para calculo do frete                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cTransp) .or. Len(aRotas) == 0
			DbSelectArea("SF2TRB")
		    DbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe tabela de calculo cadastrada para cada rota           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aRotas)
			DbSelectArea("PAA")
			DbSetOrder(2)
			If DbSeek(xFilial("PAA")+cTransp+aRotas[nX,1]+aRotas[nX,2]+aRotas[nX,3],.F.)
				aRotas[nX,6] := PAA->(Recno())
			ElseIf DbSeek(xFilial("PAA")+cTransp+aRotas[nX,1]+aRotas[nX,2],.F.)
				aRotas[nX,6] := PAA->(Recno())
			ElseIf DbSeek(xFilial("PAA")+cTransp+aRotas[nX,1],.F.)
				aRotas[nX,6] := PAA->(Recno())
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona na tabela de dados complementares da rota                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAD")
			DbSetOrder(1)
			If !DbSeek(xFilial("PAD")+cTransp+aRotas[nX,1],.F.)
				aRotas[nX,6] := 0
				Loop
			Endif
			aRotas[nX,8]	:= PAD->PAD_TPCALC

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula os totais pelo tipo de calculo                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotFat 	+= Iif(PAD->PAD_TPCALC == "F", aRotas[nX,4], 0.00)
			nTotPeso    += Iif(PAD->PAD_TPCALC == "P", aRotas[nX,5], 0.00)
	 	Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existem rotas sem tabela cadastrada                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aRotas,{|x| x[6] == 0}) > 0
			DbSelectArea("SF2TRB")
		    DbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o frete para cada rota                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aRotas)
			DbSelectArea("PAA")
			DbGoTo(aRotas[nX,6])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o frete de acordo com o tipo de calculo informado                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aRotas[nX,8] == "V"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula pelo valor fixo                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRotas[nX,9] := PAD->PAD_VLRFIX
			ElseIf aRotas[nX,8] == "F"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula pela faixa de faturamento                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAF")
				DbSetOrder(2)
				DbSeek(xFilial("PAF")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.f.)
				While !EOF() .and. PAF->PAF_FILIAL+PAF->PAF_TRANSP+PAF->PAF_ROTA == xFilial("PAF")+PAA->PAA_TRANSP+PAA->PAA_ROTA
					If aRotas[nX,4] >= PAF->PAF_FXINI .and. aRotas[nX,4] <= PAF->PAF_FXFIM
						aRotas[nX,9] := Round((PAF->PAF_PERCFR * aRotas[nX,4])/100,2)
						Exit
					Endif
					DbSelectArea("PAF")
					DbSkip()
				Enddo
			ElseIf aRotas[nX,8] == "P"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula pela faixa de peso                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAE")
				DbSetOrder(2)
				DbSeek(xFilial("PAE")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.f.)
				While !EOF() .and. PAE->PAE_FILIAL+PAE->PAE_TRANSP+PAE->PAE_ROTA == xFilial("PAE")+PAA->PAA_TRANSP+PAA->PAA_ROTA
					If aRotas[nX,5]/1000 >= (PAE->PAE_FXINI) .and. aRotas[nX,5]/1000 <= (PAE->PAE_FXFIM)
						aRotas[nX,9] := Round((PAE->PAE_VLRFRT/1000)*aRotas[nX,5],2)
						Exit
					Endif
					DbSelectArea("PAE")
					DbSkip()
				Enddo
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula os demais componentes do frete                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAD")
			DbSetOrder(1)
			If DbSeek(xFilial("PAD")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.F.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o frete esta abaixo do minimo                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRotas[nX,9] < PAD->PAD_FRTMIN
					aRotas[nX,9] := PAD->PAD_FRTMIN
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o pedagio                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRotas[nX,10] := Round(((PAD->PAD_PEDAGI/1000) * aRotas[nX,5]),2)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o seguro                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRotas[nX,11] := Round((PAD->PAD_SEGURO * aRotas[nX,4])/100,2)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o frete minimo                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRotas[nX,7] := PAD->PAD_FRTMIN
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula a taxa de entrega                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAH")
			DbSetOrder(2)
			DbSeek(xFilial("PAH")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.f.)
			While !EOF() .and. PAH->PAH_FILIAL+PAH->PAH_TRANSP+PAH->PAH_ROTA == xFilial("PAH")+PAA->PAA_TRANSP+PAA->PAA_ROTA
				If aRotas[nX,5]/1000 >= PAH->PAH_FXINI .and. aRotas[nX,5]/1000 <= PAH->PAH_FXFIM
					aRotas[nX,12] := PAH->PAH_VLRTX
					Exit
				Endif
				DbSelectArea("PAH")
				DbSkip()
			Enddo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Proporcionaliza o frete e seus componentes pelas notas fiscais           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aNotas	:= aClone(aRotas[nX,14])
			aArred	:= {aRotas[nX,9],aRotas[nX,10],aRotas[nX,11],aRotas[nX,12],aRotas[nX,7]}
			For nY := 1 to Len(aNotas)
				If aRotas[nX,8] == "F"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Proporcionaliza o frete pelo valor faturado                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPerc := (aNotas[nY,3] * 100)/aRotas[nX,4]
				ElseIf aRotas[nX,8] == "P"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Proporcionaliza o frete pelo peso                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPerc := (aNotas[nY,4] * 100)/aRotas[nX,5]
				ElseIf aRotas[nX,8] == "V"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Proporcionaliza o frete pelo peso para os valores fixos                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPerc := (aNotas[nY,4] * 100)/aRotas[nX,5]
				Endif

				aNotas[nY,5] 	:=  Round((aRotas[nX,9] * nPerc)/100,2)
				aNotas[nY,6] 	:=  Round((aRotas[nX,10] * nPerc)/100,2)
				aNotas[nY,7] 	:=  Round((aRotas[nX,11] * nPerc)/100,2)
				aNotas[nY,8] 	:=  Round((aRotas[nX,12] * nPerc)/100,2)
				aNotas[nY,11]	:=  Round((aRotas[nX,7] * nPerc)/100,2)
				aArred[1] -= aNotas[nY,5]
				aArred[2] -= aNotas[nY,6]
				aArred[3] -= aNotas[nY,7]
				aArred[4] -= aNotas[nY,8]
				aArred[5] -= aNotas[nY,11]
			Next nY
			If Len(aNotas) > 0
				aNotas[1,5] 	:=  aNotas[1,5] + aArred[1]
				aNotas[1,6] 	:=  aNotas[1,6] + aArred[2]
				aNotas[1,7] 	:=  aNotas[1,7] + aArred[3]
				aNotas[1,8] 	:=  aNotas[1,8] + aArred[4]
				aNotas[1,11] 	:=  aNotas[1,11] + aArred[5]
			Endif
			aRotas[nX,14]	:= aClone(aNotas)
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a tabela de fretes apurados                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aRotas)
			aNotas	:= aClone(aRotas[nX,14])
			For nY := 1 to Len(aNotas)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no SF2                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SF2")
				DbGoTo(aNotas[nY,10])

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a taxa de entrega ja foi calculada                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAITRB")
				DbSetOrder(3)
				DbSeek(cTransp+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2TRB->DAI_DATA,.f.)
	         	While !EOF() .and. PAITRB->PAI_TRANSP+PAITRB->PAI_CLIENT+PAITRB->PAI_LOJA+DTOS(PAITRB->PAI_DTCRG) == cTransp+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2TRB->DAI_DATA
					If PAITRB->PAI_TXENTR > 0 .and. PAITRB->PAI_IDENT <> cIdent
						aNotas[nY,8] := 0.00
						Exit
					Endif
					DbSelectArea("PAITRB")
					DbSkip()
				Enddo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava a tabela de fretes apurados                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAITRB")
				RecLock("PAITRB",.T.)
				PAITRB->PAI_IDENT		:= cIdent
				PAITRB->PAI_NOTA		:= aNotas[nY,1]
				PAITRB->PAI_SERIE		:= aNotas[nY,2]
				PAITRB->PAI_TPNF		:= SF2->F2_TIPO
				PAITRB->PAI_CLIENT  	:= SF2->F2_CLIENTE
				PAITRB->PAI_LOJA		:= SF2->F2_LOJA
				PAITRB->PAI_EMISNF  	:= SF2->F2_EMISSAO
				PAITRB->PAI_DTCRG   	:= Stod(SF2TRB->DAI_DATA)
				If !SF2->F2_TIPO $ "BD"
					PAITRB->PAI_NOMCLI	:= Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
				Else
					PAITRB->PAI_NOMCLI	:= Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_NOME")
				Endif
				PAITRB->PAI_OPER		:= "N"
				PAITRB->PAI_TPCALC		:= aRotas[nX,8]
				PAITRB->PAI_TRANSP		:= cTransp
				PAITRB->PAI_ROTA		:= aRotas[nX,1]
				PAITRB->PAI_FATNF		:= aNotas[nY,3]
				PAITRB->PAI_PESONF 		:= aNotas[nY,4]
				PAITRB->PAI_FRTMIN 		:= aNotas[nY,11]
				PAITRB->PAI_FRETE		:= aNotas[nY,5]
				PAITRB->PAI_SEGURO 		:= aNotas[nY,7]
				PAITRB->PAI_PEDAGI 		:= aNotas[nY,6]
				PAITRB->PAI_TXENTR		:= aNotas[nY,8]
				PAITRB->PAI_DEVOL		:= 0
				PAITRB->PAI_TOTAL		:= aNotas[nY,5]+aNotas[nY,6]+aNotas[nY,7]+aNotas[nY,8]+aNotas[nY,9]
				nTotFrete				:= aNotas[nY,5]+aNotas[nY,6]+aNotas[nY,7]+aNotas[nY,8]+aNotas[nY,9]
				//MsUnlock()
				If aScan(aIdent, cIdent) == 0
					Aadd(aIdent, cIdent)
				Endif
			Next nY
		Next nX

		DbSelectArea("SF2TRB")
	   DbSkip()
	EndDo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa a nota de fretes especiais                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery  := " SELECT PAG.PAG_DTCALC, PAG.PAG_TRANSP, PAG.PAG_CLIENT, PAG.PAG_LOJA "+Chr(13)+Chr(10)
	cQuery	+= " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("SD2")+" SD2 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("PAG")+" PAG (NOLOCK)"+Chr(13)+Chr(10)
	cQuery	+= " WHERE F2_FILIAL = '"+xFilial("SF2")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_DOC BETWEEN '"+cDoc+"' AND '"+cDoc+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_SERIE BETWEEN '"+cSerie+"' AND '"+cSerie+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_CLIENTE BETWEEN '"+cCliente+"' AND '"+cCliente+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_LOJA BETWEEN '"+cLoja+"' AND '"+cLoja+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_TRANSP BETWEEN '"+cTrans+"' AND '"+cTrans+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_TRANSP <> '      '"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_FILIAL = '"+xFilial("SD2")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_DOC = F2_DOC"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_SERIE = F2_SERIE"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_CLIENTE = F2_CLIENTE"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_LOJA = F2_LOJA"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_COD BETWEEN '"+cCarga+"' AND '"+cCarga+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_COD = F2_CARGA"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_SEQCAR = F2_SEQCAR"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_SEQUEN = F2_SEQENT"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_PEDIDO = D2_PEDIDO"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_FILIAL = '"+xFilial("PAG")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_DTCALC = F2_EMISSAO"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_TRANSP = F2_TRANSP"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_CLIENT = F2_CLIENTE"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_LOJA = F2_LOJA"+Chr(13)+Chr(10)
	cQuery	+= " AND SF2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND SD2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery  += " GROUP BY PAG.PAG_DTCALC, PAG.PAG_TRANSP, PAG.PAG_CLIENT, PAG.PAG_LOJA "

	If Select("PAGTRB") > 0
		DbSelectArea("PAGTRB")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PAGTRB",.T.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa as notas fiscais de devolucao de venda                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("PAGTRB")
	DbGoTop()
	While !EOF()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona na tabela de fretes especiais                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("PAG")
		DbSetOrder(2)
		If !DbSeek(xFilial("PAG")+PAGTRB->PAG_TRANSP+PAGTRB->PAG_DTCALC,.F.)
			DbSelectArea("PAGTRB")
			DbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa a nota de fretes especiais                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery  := " SELECT SF2.R_E_C_N_O_ AS RECSF2 "+Chr(13)+Chr(10)
		cQuery	+= " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK),"+Chr(13)+Chr(10)
		cQuery	+= "      "+RetSqlName("SD2")+" SD2 (NOLOCK),"+Chr(13)+Chr(10)
		cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK),"+Chr(13)+Chr(10)
		cQuery	+= "      "+RetSqlName("PAG")+" PAG (NOLOCK)"+Chr(13)+Chr(10)
		cQuery	+= " WHERE F2_FILIAL = '"+xFilial("SF2")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_EMISSAO = '"+PAGTRB->PAG_DTCALC+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_CLIENTE = '"+PAGTRB->PAG_CLIENT+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_LOJA = '"+PAGTRB->PAG_LOJA+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_TRANSP = '"+PAGTRB->PAG_TRANSP+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND F2_TRANSP <> '      '"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_FILIAL = '"+xFilial("SD2")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_DOC = F2_DOC"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_SERIE = F2_SERIE"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_CLIENTE = F2_CLIENTE"+Chr(13)+Chr(10)
		cQuery	+= " AND D2_LOJA = F2_LOJA"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_COD = F2_CARGA"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_SEQCAR = F2_SEQCAR"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_SEQUEN = F2_SEQENT"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_PEDIDO = D2_PEDIDO"+Chr(13)+Chr(10)
		cQuery	+= " AND PAG_FILIAL = '"+xFilial("PAG")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND PAG_DTCALC = F2_EMISSAO"+Chr(13)+Chr(10)
		cQuery	+= " AND PAG_TRANSP = F2_TRANSP"+Chr(13)+Chr(10)
		cQuery	+= " AND PAG_CLIENT = F2_CLIENTE"+Chr(13)+Chr(10)
		cQuery	+= " AND PAG_LOJA = F2_LOJA"+Chr(13)+Chr(10)
		cQuery	+= " AND SF2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " AND SD2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " AND PAG.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a query retornando os registros a serem processados                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("SF2TRB") > 0
			DbSelectArea("SF2TRB")
			DbCloseArea()
		Endif
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SF2TRB",.T.,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona nos conhecimentos que compoe o frete especial                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aConhEsp		:= {0.00,0.00,0.00,0.00}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa as notas fiscais de venda com frete especial                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF2TRB")
		DbGoTop()
		While !EOF()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no SF2                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF2")
			DbGoTo(SF2TRB->RECSF2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se foi calculado o frete no calculo padrao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAITRB")
			DbSetOrder(2)
			If !DbSeek(SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_TIPO,.f.)
				DbSelectArea("SF2TRB")
				DbSkip()
				Loop
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula o frete calculado                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While !EOF() .and. PAITRB->PAI_NOTA+PAITRB->PAI_SERIE+PAITRB->PAI_CLIENT+PAITRB->PAI_LOJA+PAITRB->PAI_TPNF == SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_TIPO
					If PAITRB->PAI_OPER == "N"
						aConhEsp[1] += PAITRB->PAI_FRETE
						aConhEsp[2] += PAITRB->PAI_SEGURO
						aConhEsp[3] += PAITRB->PAI_PEDAGI
						aConhEsp[4] += PAITRB->PAI_TXENTR
						Aadd(aNfEsp, PAITRB->(Recno()))
					Endif
					DbSelectArea("PAITRB")
					DbSkip()
				Enddo
			Endif
			DbSelectArea("SF2TRB")
		   DbSkip()
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o PAI calculado                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aArred := {	PAG->PAG_FRETE,;
						PAG->PAG_PEDAGI,;
						PAG->PAG_SEGURO,;
						PAG->PAG_TXENTR}
		For nX := 1 to Len(aNfEsp)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no PAI                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAITRB")
			DbGoTo(aNfEsp[nX])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o percentual para o frete                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := (PAITRB->PAI_FRETE * 100)/aConhEsp[1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o valor do frete                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("PAITRB",.F.)
			PAITRB->PAI_FRETE 	:= Round((PAG->PAG_FRETE * nPerc)/100,2)
			MsUnlock()
			aArred[1] -= Round((PAG->PAG_FRETE * nPerc)/100,2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o percentual para o pedagio                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := (PAITRB->PAI_PEDAGI * 100)/aConhEsp[3]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o valor do pedagio                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("PAI",.F.)
			PAITRB->PAI_PEDAGI	:= Round((PAG->PAG_PEDAGI * nPerc)/100,2)
			MsUnlock()
			aArred[2] -= Round((PAG->PAG_PEDAGI * nPerc)/100,2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o percentual para o seguro                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := (PAITRB->PAI_SEGURO * 100)/aConhEsp[2]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o valor do seguro                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("PAI",.F.)
			PAITRB->PAI_SEGURO	:= Round((PAG->PAG_SEGURO * nPerc)/100,2)
			MsUnlock()
			aArred[3] -= Round((PAG->PAG_SEGURO * nPerc)/100,2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o percentual para a taxa de entrega                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := (PAITRB->PAI_TXENTR * 100)/aConhEsp[4]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o valor da taxa de entrega                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("PAI",.F.)
			PAITRB->PAI_TXENTR	:= Round((PAG->PAG_TXENTR * nPerc)/100,2)
			MsUnlock()
			aArred[4] -= Round((PAG->PAG_TXENTR * nPerc)/100,2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Zera a devolucao                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("PAI",.F.)
			PAITRB->PAI_DEVOL		:= 0.00
			PAITRB->PAI_OPER 		:= "E"
			PAITRB->PAI_TOTAL		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			nTotFrete       		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			MsUnlock()
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acerta os arredondamentos                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aArred[1] <> 0
			If Len(aNfEsp) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no PAI                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAI")
				DbGoTo(aNfEsp[1])
				RecLock("PAI",.F.)
				PAITRB->PAI_FRETE		+= aArred[1]
				PAITRB->PAI_TOTAL		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				nTotFrete       		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				MsUnlock()
			Endif
		Endif
		If aArred[2] <> 0
			If Len(aNfEsp) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no PAI                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAI")
				DbGoTo(aNfEsp[1])
				RecLock("PAI",.F.)
				PAITRB->PAI_PEDAGI	+= aArred[2]
				PAITRB->PAI_TOTAL	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				nTotFrete       	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				MsUnlock()
			Endif
		Endif
		If aArred[3] <> 0
			If Len(aNfEsp) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no PAI                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAI")
				DbGoTo(aNfEsp[1])
				RecLock("PAI",.F.)
				PAITRB->PAI_SEGURO	+= aArred[3]
				PAITRB->PAI_TOTAL	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				nTotFrete      		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				MsUnlock()
			Endif
		Endif
		If aArred[4] <> 0
			If Len(aNfEsp) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no PAI                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("PAI")
				DbGoTo(aNfEsp[1])
				RecLock("PAI",.F.)
				PAITRB->PAI_TXENTR	+= aArred[4]
				PAITRB->PAI_TOTAL	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				nTotFrete      		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
				MsUnlock()
			Endif
		Endif

		If Select("SF2TRB") > 0
			DbSelectArea("SF2TRB")
			DbCloseArea()
		Endif

		DbSelectArea("PAGTRB")
	   DbSkip()
	Enddo
	If Select("PAGTRB") > 0
		DbSelectArea("PAGTRB")
		DbCloseArea()
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa a nota de devolucao de venda                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery  := " SELECT SF1.R_E_C_N_O_ AS RECSF1 "
	cQuery	+= "  FROM "+RetSqlName("SF2")+" SF2 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "       "+RetSqlName("SD2")+" SD2 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "       "+RetSqlName("DAI")+" DAI (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "       "+RetSqlName("SD1")+" SD1 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "       "+RetSqlName("SF1")+" SF1 (NOLOCK)"+Chr(13)+Chr(10)
	cQuery	+= " WHERE F2_FILIAL = '"+xFilial("SF2")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_DOC BETWEEN '"+cDoc+"' AND '"+cDoc+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_SERIE BETWEEN '"+cSerie+"' AND '"+cSerie+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_CLIENTE BETWEEN '"+cCliente+"' AND '"+cCliente+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_LOJA BETWEEN '"+cLoja+"' AND '"+cLoja+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_TRANSP BETWEEN '"+cTrans+"' AND '"+cTrans+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F2_TRANSP <> '      '"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_FILIAL = '"+xFilial("SD2")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_DOC = F2_DOC"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_SERIE = F2_SERIE"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_CLIENTE = F2_CLIENTE"+Chr(13)+Chr(10)
	cQuery	+= " AND D2_LOJA = F2_LOJA"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_COD BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_COD = F2_CARGA"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_SEQCAR = F2_SEQCAR"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_SEQUEN = F2_SEQENT"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_PEDIDO = D2_PEDIDO"+Chr(13)+Chr(10)
	cQuery	+= " AND D1_FILIAL = '"+xFilial("SD1")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND D1_DTDIGIT BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND SD1.D1_NFORI = F2_DOC"+Chr(13)+Chr(10)
	cQuery	+= " AND SD1.D1_SERIORI = F2_SERIE"+Chr(13)+Chr(10)
	cQuery	+= " AND D1_TIPO = 'D'"+Chr(13)+Chr(10)
	cQuery	+= " AND D1_NFORI <> '      '"+Chr(13)+Chr(10)
	cQuery	+= " AND F1_FILIAL = '"+xFilial("SF1")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND F1_DOC = D1_DOC"+Chr(13)+Chr(10)
	cQuery	+= " AND F1_SERIE = D1_SERIE"+Chr(13)+Chr(10)
	cQuery	+= " AND F1_FORNECE = D1_FORNECE"+Chr(13)+Chr(10)
	cQuery	+= " AND F1_LOJA = D1_LOJA"+Chr(13)+Chr(10)
	cQuery	+= " AND F1_TIPO = D1_TIPO"+Chr(13)+Chr(10)
	cQuery	+= " AND SF2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND SD2.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND SD1.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND SF1.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a query retornando os registros a serem processados                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("SF1TRB") > 0
		DbSelectArea("SF1TRB")
		DbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SF1TRB",.T.,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa as notas fiscais de devolucao de venda                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF1TRB")
	DbGoTop()
	While !EOF()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no cabecalho da nota de entrada                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF1")
		DbGoTo(SF1TRB->RECSF1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa as notas de origem                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nFrtDev 	:= 0.00
		aIdentDev 	:= {}
		aTotNfOri	:= {0.00,0.00}
		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.f.)
		While !EOF() .and. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a nota original foi informada                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(SD1->D1_NFORI)
				DbSelectArea("SD1")
				DbSkip()
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a nota original existe                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF2")
			DbSetOrder(1)
			If !DbSeek(xFilial("SF2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA,.f.)
				DbSelectArea("SD1")
				DbSkip()
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se foi calculado o frete da nota fiscal de origem               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nFrtNfOri	:= 0.00
			DbSelectArea("PAITRB")
			DbSetOrder(2)
			If !DbSeek(SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_TIPO)
				DbSelectArea("SD1")
				DbSkip()
				Loop
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula o frete calculado na emissao da nota fiscal                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While !EOF() .and. PAITRB->PAI_NOTA+PAITRB->PAI_SERIE+PAITRB->PAI_CLIENT+PAITRB->PAI_LOJA+PAITRB->PAI_TPNF == SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_TIPO
					If PAITRB->PAI_OPER $ "N/E"
						nFrtNfOri += PAITRB->PAI_FRETE+PAITRB->PAI_TXENTR+PAITRB->PAI_PEDAGI
						If Len(aIdentDev) == 0
							aIdentDev		:= {"","","","","","","","",PAITRB->PAI_TPCALC,PAITRB->PAI_TRANSP,PAITRB->PAI_ROTA,PAITRB->PAI_IDENT,PAITRB->PAI_DTCRG}
						Endif
					Endif
					DbSelectArea("PAITRB")
					DbSkip()
				Enddo
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa o item da nota fiscal original                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotNfOri	:= 0.00
			nPesNfOri	:= 0.00
			DbSelectArea("SD2")
			DbSetOrder(3)
			If !DbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI,.f.)
				DbSelectArea("SD1")
				DbSkip()
				Loop
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula os totais da nota fiscal para proporcionalizar a devolucao       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA,.f.)
				While !EOF() .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no cadastro de produtos                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SB1")
					DbSetOrder(1)
					MsSeek(xFilial("SB1")+SD2->D2_COD,.f.)

					nTotNfOri	+= SD2->D2_TOTAL
					nPesNfOri	+= SB1->B1_PESBRU * SD2->D2_QUANT

					DbSelectArea("SD2")
					DbSkip()
				Enddo
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Reposiciona no item da nota original                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !DbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI,.f.)
				DbSelectArea("SD1")
				DbSkip()
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no cadastro de produtos                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SB1")
			DbSetOrder(1)
			MsSeek(xFilial("SB1")+SD2->D2_COD,.f.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o percentual sobre a quantidade original                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aIdentDev) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa o item da nota fiscal original                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD2")
				DbSetOrder(3)
				DbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI,.f.)
				If aIdentDev[9] == "F"
					nPerc 			:= ((SD1->D1_QUANT*SD2->D2_PRCVEN) * 100)/nTotNfOri
					nFrtDev			+= Round((nFrtNfOri * nPerc)/100,2)
					aTotNfOri[1] 	+= Round(((SD2->D2_TOTAL) * nPerc)/100,2)
					aTotNfOri[2] 	+= Round(((SB1->B1_PESBRU * SD2->D2_QUANT) * nPerc)/100,2)
				ElseIf aIdentDev[9] $ "P/V"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no cadastro de produtos                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SB1")
					DbSetOrder(1)
					MsSeek(xFilial("SB1")+SD1->D1_COD,.f.)

					nPerc 			:= ((SB1->B1_PESBRU * SD1->D1_QUANT) * 100)/nPesNfOri
					nFrtDev			+= Round((nFrtNfOri * nPerc)/100,2)
					aTotNfOri[1] 	+= Round(((SD2->D2_TOTAL) * nPerc)/100,2)
					aTotNfOri[2] 	+= Round(((SB1->B1_PESBRU * SD2->D2_QUANT) * nPerc)/100,2)
				Endif
			Endif
			DbSelectArea("SD1")
			DbSkip()
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a tabela de fretes apurados                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aIdentDev) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona na tabela de dados complementares da rota                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAD")
			DbSetOrder(1)
			If DbSeek(xFilial("PAD")+aIdentDev[10]+aIdentDev[11],.F.)
				nFrtDev := Round((nFrtDev*PAD->PAD_DEVOL)/100,2)
				nTotFrete       	:= nFrtDev
				If aScan(aIdent, aIdentDev[12]) == 0
					Aadd(aIdent, aIdentDev[12])
				Endif
			Endif
		Endif

		DbSelectArea("SF1TRB")
	   DbSkip()
	Enddo
EndIf
If Select("SF1TRB") > 0
	DbSelectArea("SF1TRB")
	DbCloseArea()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza os arquivos temporarios                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SF2TRB") > 0
	DbSelectArea("SF2TRB")
	DbCloseArea()
Endif
If Select("PAITRB") > 0
	DbSelectArea("PAITRB")
	DbCloseArea()
	FErase(cArquivo+GetDbExtension())
	FErase(cInd1+OrdBagExt())
	FErase(cInd2+OrdBagExt())
	FErase(cInd3+OrdBagExt())
Endif
Return nTotFrete

/*/{Protheus.doc} WFACFRTPED
Calculo do frete
@author F?io S dos Santos
@since 22/05/07
@version P11
@uso Shell/Fusus
@param cPedido, characters
@param  cCliente, characters
@param  cLoja, characters
@param  cTrans, characters
@param  dDataIni, date
@type function
/*/
User Function WFACFRTPED(cPedido, cCliente, cLoja, cTrans, dDataIni)

Local cQuery		:= ""
Local cArquivo		:= ""
Local aStru			:= {}
Local nTotCalc		:= 0.00
Local aRotas		:= {}
Local cTransp		:= ""
Local nPosArr		:= 0
Local nPosNota		:= 0
Local nX			:= 0
Local nY			:= 0
Local nTotFat		:= 0.00
Local nTotPeso		:= 0.00
Local nTotFixo		:= 0.00
Local aNotas		:= {}
Local aArred		:= {}
Local nPerc			:= 0.00
Local nFrtDev		:= 0.00
Local nTotNfOri	    := 0.00
Local nPesNfOri		:= 0.00
Local nFrtNfOri		:= 0.00
Local aTotNfOri		:= {0.00,0.00}
Local aIdentDev		:= {}
Local aConhEsp		:= {}
Local aNfEsp		:= {}
Local cIdent		:= "000000"
Local cInd1			:= ""
Local cInd2			:= ""
Local cInd3			:= ""
Local cInd4			:= ""
Local aIdent		:= {}

Private nTotFrete	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a estrutura do arquivo temporario                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aStru, {"PAI_IDENT",	"C",006,000})
Aadd(aStru, {"PAI_PEDIDO",	"C",006,000})
Aadd(aStru, {"PAI_NOTA",	"C",006,000})
Aadd(aStru, {"PAI_SERIE",	"C",003,000})
Aadd(aStru, {"PAI_TPNF",	"C",001,000})
Aadd(aStru, {"PAI_CLIENT",	"C",006,000})
Aadd(aStru, {"PAI_LOJA",	"C",002,000})
Aadd(aStru, {"PAI_EMISNF",	"D",008,000})
Aadd(aStru, {"PAI_DTCRG",	"D",008,000})
Aadd(aStru, {"PAI_NOMCLI",	"C",040,000})
Aadd(aStru, {"PAI_OPER",	"C",001,000})
Aadd(aStru, {"PAI_TPCALC",	"C",001,000})
Aadd(aStru, {"PAI_TRANSP",	"C",006,000})
Aadd(aStru, {"PAI_ROTA",	"C",006,000})
Aadd(aStru, {"PAI_REENTR",	"N",002,000})
Aadd(aStru, {"PAI_FATNF",	"N",012,002})
Aadd(aStru, {"PAI_PESONF",	"N",012,004})
Aadd(aStru, {"PAI_FRTMIN",	"N",012,002})
Aadd(aStru, {"PAI_FRETE",	"N",012,002})
Aadd(aStru, {"PAI_SEGURO",	"N",012,002})
Aadd(aStru, {"PAI_PEDAGI",	"N",012,002})
Aadd(aStru, {"PAI_TXENTR",	"N",012,002})
Aadd(aStru, {"PAI_DEVOL",	"N",012,002})
Aadd(aStru, {"PAI_TOTAL",	"N",012,002})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo temporario                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArquivo := CriaTrab(aStru,.T.)
cInd1    := CriaTrab(,.F.)
cInd2    := CriaTrab(,.F.)
cInd3    := CriaTrab(,.F.)
cInd4    := CriaTrab(,.F.)
dbUseArea(.T.,,cArquivo,"PAITRB",.F.,.F.)
IndRegua("PAITRB",cInd1,"PAI_IDENT+PAI_NOTA+PAI_SERIE")
IndRegua("PAITRB",cInd2,"PAI_NOTA+PAI_SERIE+PAI_CLIENT+PAI_LOJA+PAI_TPNF")
IndRegua("PAITRB",cInd3,"PAI_TRANSP+PAI_CLIENT+PAI_LOJA+DTOS(PAI_DTCRG)")
IndRegua("PAITRB",cInd4,"PAI_PEDIDO+PAI_CLIENTE+PAI_LOJA")
DbSelectArea("PAITRB")
DbClearIndex()
DbSetIndex(cInd1+OrdBagExt())
DbSetIndex(cInd2+OrdBagExt())
DbSetIndex(cInd3+OrdBagExt())
DbSetIndex(cInd4+OrdBagExt())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a query de selecao das notas fiscais a serem processadas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery	:=	"SELECT DAI.DAI_DATA, "
cQuery	+=	"SC5.C5_CLIENTE, "
cQuery	+=	"SC5.C5_LOJACLI, "
cQuery	+=	"SC5.C5_TRANSP  "
cQuery	+= " FROM "+RetSqlName("SC5")+" SC5 (NOLOCK),"
cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK) "
cQuery	+= " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery	+= " AND DAI.DAI_FILIAL = '"+xFilial("DAI")+"' "
cQuery	+= " AND SC5.C5_NUM = '" + cPedido + "' "
cQuery	+= " AND SC5.C5_EMISSAO = '"+DtoS(dDataIni)+"' "
cQuery	+= " AND SC5.C5_CLIENTE = '" + cCliente + "' "
cQuery	+= " AND SC5.C5_LOJACLI = '" + cLoja + "' "
cQuery	+= " AND SC5.C5_TRANSP = '" + cTrans + "' "
cQuery	+= " AND SC5.C5_TRANSP <> '      ' "
cQuery	+= " AND SC5.C5_FILIAL = DAI.DAI_FILIAL "
cQuery	+= " AND DAI_PEDIDO = SC5.C5_NUM  "
cQuery	+= " AND SC5.D_E_L_E_T_ <> '*'  "
cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'  "
cQuery	+= " GROUP BY DAI.DAI_DATA,  "
cQuery	+= " SC5.C5_CLIENTE,  "
cQuery	+= " SC5.C5_LOJACLI,  "
cQuery	+= " SC5.C5_TRANSP "

If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

DbSelectArea("TRB")
dbGoTop()
While !EOF()

   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a query de selecao das notas fiscais a serem processadas           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery	:= " SELECT SC5.R_E_C_N_O_ AS RECSC5"+Chr(13)+Chr(10)
		cQuery	+= " FROM "+RetSqlName("SC5")+" SC5 (NOLOCK),"+Chr(13)+Chr(10)
		cQuery	+= "      "+RetSqlName("SC6")+" SC6 (NOLOCK),"+Chr(13)+Chr(10)
		cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK)"+Chr(13)+Chr(10)
		cQuery	+= " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND C6_FILIAL = '"+xFilial("SC6")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND C5_CLIENTE = '"+TRB->C5_CLIENTE+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND C5_LOJACLI = '"+TRB->C5_LOJACLI+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND C5_TRANSP  = '"+TRB->C5_TRANSP+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND C6_NUM = C5_NUM"+Chr(13)+Chr(10)
		cQuery	+= " AND C6_CLI = C5_CLIENTE"+Chr(13)+Chr(10)
		cQuery	+= " AND C6_LOJA = C5_LOJACLI"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_DATA = '"+TRB->DAI_DATA+"'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI_PEDIDO = C6_NUM"+Chr(13)+Chr(10)
		cQuery	+= " AND SC5.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " AND SC6.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
		cQuery	+= " GROUP BY SC5.R_E_C_N_O_"+Chr(13)+Chr(10)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a query retornando os registros                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TRBSC5") > 0
		DbSelectArea("TRBSC5")
		DbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSC5",.T.,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reinicializa as variaveis utilizadas                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotCalc	:= 0.00
	aRotas		:= {}
	nTotFat		:= 0.00
	nTotPeso	:= 0.00
	nTotFixo	:= 0.00
	cIdent		:= Soma1(cIdent,6)

	DbSelectArea("TRBSC5")
	dbGoTop()
	While !EOF()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SC5                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SC5")
		DbGoTo(TRBSC5->RECSC5)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define a transportadora da nota fiscal                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTransp		:= SC5->C5_TRANSP

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define a rota utilizada por Item do pedido		                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SC6")
		DbSetOrder(3)

		DbSeek(xFilial("SC6")+SC5->C5_NUM)
		While !EOF() .and. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + SC6->C6_NUM
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no cadastro de produtos                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SB1")
			DbSetOrder(1)
			MsSeek(xFilial("SB1")+SC6->C6_PRODUTO,.f.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona no array os dados das rotas utilizadas                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("DAI")
			dbSetOrder(1)
			If MsSeek(xFilial("DAI")+SC6->C6_NUM,.F.)
				nPosArr := aScan(aRotas,{|x| x[1] == DAI->DAI_PERCUR .and. x[2] == DAI->DAI_ROTA .and. x[3] == DAI->DAI_ROTEIR})
				If nPosArr == 0
					aNotas	:= {{	SC6->C6_NUM,;														//1 - Pedido
										SC6->C6_VALOR+SC6->C6_IPIDEV+SC6->C6_ICMSRET,;			        //2 - Total Faturado
										SB1->B1_PESBRU * SC6->C6_QTDVEN,;						     	//3 - Peso
										0.00,;															//4 - Valor do Frete
										0.00,;															//5 - Valor do Pedagio
										0.00,;															//6 - Valor do Seguro
										0.00,;															//7 - Valor da Taxa de Entrega
										0.00,;															//8 - Valor da Devolucao
										SC6->(Recno()),;												//8 - Recno SC6
										0.00}}															//10 - Valor do Frete Minimo

					Aadd(aRotas, {	DAI->DAI_PERCUR,;                                 					//1 - Rota
										DAI->DAI_ROTA,;													//2 - Zona
										DAI->DAI_ROTEIR,;												//3 - Setor
										SC6->C6_VALOR+SC6->C6_IPIDEV+SC6->C6_ICMSRET,;			        //4 - Total Faturado
										SB1->B1_PESBRU * SC6->C6_QTDVEN,;						     	//5 - Peso
										0,;																//6 - Recno tabela de calculo
										0.00,;															//7 - Valor do Frete Minimo
										"",;															//8 - Tipo de calculo do frete
										0.00,;															//9 - Valor do Frete
										0.00,;															//10 - Valor do Pedagio
										0.00,;															//11 - Valor do Seguro
										0.00,;															//12 - Valor da Taxa de Entrega
										0.00,;															//13 - Valor da Devolucao
										aNotas})														//14 - Pedidos que compoe a rota
				Else
					aNotas 		:= aClone(aRotas[nPosArr,14])
					nPosNota	:= aScan(aNotas,{|x| x[1] == SC6->C6_NUM})
					If nPosNota == 0
						Aadd(aNotas, {SC6->C6_NUM,;														//1 - Pedido
										SC6->C6_VALOR+SC6->C6_IPIDEV+SC6->C6_ICMSRET,;			        //2 - Total Faturado
										SB1->B1_PESBRU * SC6->C6_QTDVEN,;						     	//3 - Peso
										0.00,;															//4 - Valor do Frete
										0.00,;															//5 - Valor do Pedagio
										0.00,;															//6 - Valor do Seguro
										0.00,;															//7 - Valor da Taxa de Entrega
										0.00,;															//8 - Valor da Devolucao
										SC5->(Recno()),;												//8 - Recno SC5
										0.00})															//10 - Valor do Frete Minimo
					Else
						aNotas[nPosNota,2] += SC6->C6_VALOR+SC6->C6_IPIDEV+SC6->C6_ICMSRET
						aNotas[nPosNota,3] += SB1->B1_PESBRU * SC6->C6_QTDVEN
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o array de rotas                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRotas[nPosArr,4] 	+= SC6->C6_VALOR+SC6->C6_IPIDEV+SC6->C6_ICMSRET
					aRotas[nPosArr,5] 	+= SB1->B1_PESBRU * SC6->C6_QTDVEN
					aRotas[nPosArr,14] 	:= aClone(aNotas)
				Endif
			Endif
			DbSelectArea("SC6")
			DbSkip()
		Enddo

		DbSelectArea("TRBSC5")
	   DbSkip()
	EndDo
	If Select("TRBSC5") > 0
		DbSelectArea("TRBSC5")
		DbCloseArea()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem os dados para calculo do frete                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cTransp) .or. Len(aRotas) == 0
		DbSelectArea("TRB")
	    DbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe tabela de calculo cadastrada para cada rota           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aRotas)
		DbSelectArea("PAA")
		DbSetOrder(2)
		If DbSeek(xFilial("PAA")+cTransp+aRotas[nX,1]+aRotas[nX,2]+aRotas[nX,3],.F.)//rota+zona+setor
			aRotas[nX,6] := PAA->(Recno())
		ElseIf DbSeek(xFilial("PAA")+cTransp+aRotas[nX,1]+aRotas[nX,2],.F.)
			aRotas[nX,6] := PAA->(Recno())
		ElseIf DbSeek(xFilial("PAA")+cTransp+aRotas[nX,1],.F.)
			aRotas[nX,6] := PAA->(Recno())
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona na tabela de dados complementares da rota                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("PAD")
		DbSetOrder(1)
		If !DbSeek(xFilial("PAD")+cTransp+aRotas[nX,1],.F.)
			aRotas[nX,6] := 0
			Loop
		Endif
		aRotas[nX,8]	:= PAD->PAD_TPCALC

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula os totais pelo tipo de calculo                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotFat 	+= Iif(PAD->PAD_TPCALC == "F", aRotas[nX,4], 0.00)
		nTotPeso    += Iif(PAD->PAD_TPCALC == "P", aRotas[nX,5], 0.00)
 	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem rotas sem tabela cadastrada                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aScan(aRotas,{|x| x[6] == 0}) > 0
		DbSelectArea("TRB")
	    DbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o frete para cada rota                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aRotas)
		DbSelectArea("PAA")
		DbGoTo(aRotas[nX,6])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o frete de acordo com o tipo de calculo informado                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRotas[nX,8] == "V"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula pelo valor fixo                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRotas[nX,9] := PAD->PAD_VLRFIX
		ElseIf aRotas[nX,8] == "F"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula pela faixa de faturamento                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAF")
			DbSetOrder(2)
			DbSeek(xFilial("PAF")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.f.)
			While !EOF() .and. PAF->PAF_FILIAL+PAF->PAF_TRANSP+PAF->PAF_ROTA == xFilial("PAF")+PAA->PAA_TRANSP+PAA->PAA_ROTA
				If aRotas[nX,4] >= PAF->PAF_FXINI .and. aRotas[nX,4] <= PAF->PAF_FXFIM
					aRotas[nX,9] := Round((PAF->PAF_PERCFR * aRotas[nX,4])/100,2)
					Exit
				Endif
				DbSelectArea("PAF")
				DbSkip()
			Enddo
		ElseIf aRotas[nX,8] == "P"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula pela faixa de peso                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAE")
			DbSetOrder(2)
			DbSeek(xFilial("PAE")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.f.)
			While !EOF() .and. PAE->PAE_FILIAL+PAE->PAE_TRANSP+PAE->PAE_ROTA == xFilial("PAE")+PAA->PAA_TRANSP+PAA->PAA_ROTA
				If aRotas[nX,5]/1000 >= (PAE->PAE_FXINI) .and. aRotas[nX,5]/1000 <= (PAE->PAE_FXFIM)
					aRotas[nX,9] := Round((PAE->PAE_VLRFRT/1000)*aRotas[nX,5],2)
					Exit
				Endif
				DbSelectArea("PAE")
				DbSkip()
			Enddo
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula os demais componentes do frete                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("PAD")
		DbSetOrder(1)
		If DbSeek(xFilial("PAD")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o frete esta abaixo do minimo                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aRotas[nX,9] < PAD->PAD_FRTMIN
				aRotas[nX,9] := PAD->PAD_FRTMIN
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o pedagio                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRotas[nX,10] := Round(((PAD->PAD_PEDAGI/1000) * aRotas[nX,5]),2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o seguro                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRotas[nX,11] := Round((PAD->PAD_SEGURO * aRotas[nX,4])/100,2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o frete minimo                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRotas[nX,7] := PAD->PAD_FRTMIN
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula a taxa de entrega                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("PAH")
		DbSetOrder(2)
		DbSeek(xFilial("PAH")+PAA->PAA_TRANSP+PAA->PAA_ROTA,.f.)
		While !EOF() .and. PAH->PAH_FILIAL+PAH->PAH_TRANSP+PAH->PAH_ROTA == xFilial("PAH")+PAA->PAA_TRANSP+PAA->PAA_ROTA
			If aRotas[nX,5]/1000 >= PAH->PAH_FXINI .and. aRotas[nX,5]/1000 <= PAH->PAH_FXFIM
				aRotas[nX,12] := PAH->PAH_VLRTX
				Exit
			Endif
			DbSelectArea("PAH")
			DbSkip()
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Proporcionaliza o frete e seus componentes pelos pedidos		         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNotas	:= aClone(aRotas[nX,14])
		aArred	:= {aRotas[nX,9],aRotas[nX,10],aRotas[nX,11],aRotas[nX,12],aRotas[nX,7]}
		For nY := 1 to Len(aNotas)
			If aRotas[nX,8] == "F"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Proporcionaliza o frete pelo valor faturado                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPerc := (aNotas[nY,3] * 100)/aRotas[nX,4]
			ElseIf aRotas[nX,8] == "P"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Proporcionaliza o frete pelo peso                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPerc := (aNotas[nY,4] * 100)/aRotas[nX,5]
			ElseIf aRotas[nX,8] == "V"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Proporcionaliza o frete pelo peso para os valores fixos                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPerc := (aNotas[nY,3] * 100)/aRotas[nX,5]
			Endif

			aNotas[nY,4] 	:=  Round((aRotas[nX,9] * nPerc)/100,2)
			aNotas[nY,5] 	:=  Round((aRotas[nX,10] * nPerc)/100,2)
			aNotas[nY,6] 	:=  Round((aRotas[nX,11] * nPerc)/100,2)
			aNotas[nY,7] 	:=  Round((aRotas[nX,12] * nPerc)/100,2)
			aNotas[nY,10]	:=  Round((aRotas[nX,7] * nPerc)/100,2)
			aArred[1] -= aNotas[nY,4]
			aArred[2] -= aNotas[nY,5]
			aArred[3] -= aNotas[nY,6]
			aArred[4] -= aNotas[nY,7]
			aArred[5] -= aNotas[nY,10]
		Next nY
		If Len(aNotas) > 0
			aNotas[1,4] 	:=  aNotas[1,4] + aArred[1]
			aNotas[1,5] 	:=  aNotas[1,5] + aArred[2]
			aNotas[1,6] 	:=  aNotas[1,6] + aArred[3]
			aNotas[1,7] 	:=  aNotas[1,7] + aArred[4]
			aNotas[1,10] 	:=  aNotas[1,10] + aArred[5]
		Endif
		aRotas[nX,14]	:= aClone(aNotas)
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava a tabela de fretes apurados                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aRotas)
		aNotas	:= aClone(aRotas[nX,14])
		For nY := 1 to Len(aNotas)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no SC5                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC5")
			DbGoTo(aNotas[nY,9])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a taxa de entrega ja foi calculada                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAITRB")
			DbSetOrder(3)
			DbSeek(cTransp+SC5->C5_CLIENTE+SC5->C5_LOJACLI+TRB->DAI_DATA,.f.)
         	While !EOF() .and. PAITRB->PAI_TRANSP+PAITRB->PAI_CLIENT+PAITRB->PAI_LOJA+DTOS(PAITRB->PAI_DTCRG) == cTransp+SC5->C5_CLIENTE+SC5->C5_LOJA+TRB->DAI_DATA
				If PAITRB->PAI_TXENTR > 0 .and. PAITRB->PAI_IDENT <> cIdent
					aNotas[nY,7] := 0.00
					Exit
				Endif
				DbSelectArea("PAITRB")
				DbSkip()
			Enddo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava a tabela de fretes apurados                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				DbSelectArea("PAITRB")
				RecLock("PAITRB",.T.)
				PAITRB->PAI_IDENT		:= cIdent
				PAITRB->PAI_PEDIDO		:= aNotas[nY,1]
				PAITRB->PAI_CLIENT  	:= SC5->C5_CLIENTE
				PAITRB->PAI_LOJA		:= SC5->C5_LOJA
				PAITRB->PAI_EMISNF  	:= SC5->C5_EMISSAO
				PAITRB->PAI_DTCRG   	:= Stod(SF2TRB->DAI_DATA)
				If !SF2->F2_TIPO $ "BD"
					PAITRB->PAI_NOMCLI	:= Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJA,"A1_NOME")
				Else
					PAITRB->PAI_NOMCLI	:= Posicione("SA2",1,xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJA,"A2_NOME")
				Endif
				PAITRB->PAI_OPER		:= "N"
				PAITRB->PAI_TPCALC		:= aRotas[nX,8]
				PAITRB->PAI_TRANSP		:= cTransp
				PAITRB->PAI_ROTA		:= aRotas[nX,1]
				PAITRB->PAI_FATNF		:= aNotas[nY,2]
				PAITRB->PAI_PESONF 		:= aNotas[nY,3]
				PAITRB->PAI_FRTMIN 		:= aNotas[nY,10]
				PAITRB->PAI_FRETE		:= aNotas[nY,4]
				PAITRB->PAI_SEGURO 		:= aNotas[nY,6]
				PAITRB->PAI_PEDAGI 		:= aNotas[nY,5]
				PAITRB->PAI_TXENTR		:= aNotas[nY,7]
				PAITRB->PAI_DEVOL		:= 0
				PAITRB->PAI_TOTAL		:= aNotas[nY,4]+aNotas[nY,4]+aNotas[nY,6]+aNotas[nY,7]+aNotas[nY,8]
				nTotFrete := aNotas[nY,4]+aNotas[nY,5]+aNotas[nY,6]+aNotas[nY,7]+aNotas[nY,8]

			If aScan(aIdent, cIdent) == 0
				Aadd(aIdent, cIdent)
			Endif
		Next nY
	Next nX

	DbSelectArea("TRB")
   DbSkip()
EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa o pedido de fretes especiais                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery  := " SELECT PAG.PAG_DTCALC, PAG.PAG_TRANSP, PAG.PAG_CLIENT, PAG.PAG_LOJA "+Chr(13)+Chr(10)
cQuery	+= " FROM "+RetSqlName("SC5")+" SC5 (NOLOCK),"+Chr(13)+Chr(10)
cQuery	+= "      "+RetSqlName("SC6")+" SC6 (NOLOCK),"+Chr(13)+Chr(10)
cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK),"+Chr(13)+Chr(10)
cQuery	+= "      "+RetSqlName("PAG")+" PAG (NOLOCK)"+Chr(13)+Chr(10)
cQuery	+= " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"+Chr(13)+Chr(10)
cQuery	+= " AND SC5.C5_EMISSAO = '"+Dtos(dDataIni)+"' "+Chr(13)+Chr(10)
cQuery	+= " AND SC5.C5_NUM BETWEEN '"+cPedido+"' AND '"+cPedido+"'"+Chr(13)+Chr(10)
cQuery	+= " AND SC5.C5_CLIENTE BETWEEN '"+cCliente+"' AND '"+cCliente+"'"+Chr(13)+Chr(10)
cQuery	+= " AND SC5.C5_LOJACLI BETWEEN '"+cLoja+"' AND '"+cLoja+"'"+Chr(13)+Chr(10)
cQuery	+= " AND SC5.C5_TRANSP BETWEEN '"+cTrans+"' AND '"+cTrans+"'"+Chr(13)+Chr(10)
cQuery	+= " AND SC5.C5_TRANSP <> '      '"+Chr(13)+Chr(10)
cQuery	+= " AND SC6.C6_FILIAL = '"+xFilial("SC6")+"'"+Chr(13)+Chr(10)
cQuery	+= " AND SC6.C6_NUM = SC5.C5_NUM"+Chr(13)+Chr(10)
cQuery	+= " AND SC6.C6_CLI = SC5.C5_CLIENTE"+Chr(13)+Chr(10)
cQuery	+= " AND SC6.C6_LOJA = SC5.C5_LOJACLI"+Chr(13)+Chr(10)
cQuery	+= " AND DAI.DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
cQuery	+= " AND DAI.DAI_PEDIDO = SC5.C5_NUM"+Chr(13)+Chr(10)
cQuery	+= " AND PAG.PAG_FILIAL = '"+xFilial("PAG")+"'"+Chr(13)+Chr(10)
cQuery	+= " AND PAG.PAG_DTCALC = SC5.C5_EMISSAO"+Chr(13)+Chr(10)
cQuery	+= " AND PAG.PAG_TRANSP = SC5.C5_TRANSP"+Chr(13)+Chr(10)
cQuery	+= " AND PAG.PAG_CLIENT = SC5.C5_CLIENTE"+Chr(13)+Chr(10)
cQuery	+= " AND PAG.PAG_LOJA = SC5.C5_LOJACLI"+Chr(13)+Chr(10)
cQuery	+= " AND SC5.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
cQuery	+= " AND SC6.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
cQuery	+= " AND PAG.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
cQuery  += " GROUP BY PAG.PAG_DTCALC, PAG.PAG_TRANSP, PAG.PAG_CLIENT, PAG.PAG_LOJA "

If Select("PAGTRB") > 0
	DbSelectArea("PAGTRB")
	DbCloseArea()
Endif
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PAGTRB",.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os pedidos de devolucao de venda 		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("PAGTRB")
DbGoTop()
While !EOF()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na tabela de fretes especiais                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("PAG")
	DbSetOrder(2)
	If !DbSeek(xFilial("PAG")+PAGTRB->PAG_TRANSP+PAGTRB->PAG_DTCALC,.F.)
		DbSelectArea("PAGTRB")
		DbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa o pedido de fretes especiais                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery  := " SELECT SC5.R_E_C_N_O_ AS RECSC5 "+Chr(13)+Chr(10)
	cQuery	+= " FROM "+RetSqlName("SC5")+" SC5 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("SC6")+" SC6 (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("DAI")+" DAI (NOLOCK),"+Chr(13)+Chr(10)
	cQuery	+= "      "+RetSqlName("PAG")+" PAG (NOLOCK)"+Chr(13)+Chr(10)
	cQuery	+= " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND C5_EMISSAO = '"+PAGTRB->PAG_DTCALC+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND C5_CLIENTE = '"+PAGTRB->PAG_CLIENT+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND C5_LOJACLI = '"+PAGTRB->PAG_LOJA+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND C5_TRANSP = '"+PAGTRB->PAG_TRANSP+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND C5_TRANSP <> '      '"+Chr(13)+Chr(10)
	cQuery	+= " AND C6_FILIAL = '"+xFilial("SC6")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND C6_NUM = C5_NUM"+Chr(13)+Chr(10)
	cQuery	+= " AND C6_CLIENTE = C5_CLIENTE"+Chr(13)+Chr(10)
	cQuery	+= " AND C6_LOJA = C5_LOJA"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_FILIAL = '"+xFilial("DAI")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI_PEDIDO = C6_NUM"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_FILIAL = '"+xFilial("PAG")+"'"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_DTCALC = C5_EMISSAO"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_TRANSP = C5_TRANSP"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_CLIENT = C5_CLIENTE"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG_LOJA = C5_LOJACLI"+Chr(13)+Chr(10)
	cQuery	+= " AND SC5.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND SC6.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND DAI.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)
	cQuery	+= " AND PAG.D_E_L_E_T_ <> '*'"+Chr(13)+Chr(10)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a query retornando os registros a serem processados                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona nos conhecimentos que compoe o frete especial                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aConhEsp		:= {0.00,0.00,0.00,0.00}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa os pedidos de venda com frete especial 		                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	DbGoTop()
	While !EOF()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SC5                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SC5")
		DbGoTo(TRB->RECSC5)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi calculado o frete no calculo padrao                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		DbSelectArea("PAITRB")
		DbSetOrder(4)
		If !DbSeek(SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
			DbSelectArea("TRB")
			DbSkip()
			Loop
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula o frete calculado                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !EOF() .and. PAITRB->PAI_PEDIDO+PAITRB->PAI_CLIENT+PAITRB->PAI_LOJA == SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI
				If PAITRB->PAI_OPER == "N"
					aConhEsp[1] += PAITRB->PAI_FRETE
					aConhEsp[2] += PAITRB->PAI_SEGURO
					aConhEsp[3] += PAITRB->PAI_PEDAGI
					aConhEsp[4] += PAITRB->PAI_TXENTR
					Aadd(aNfEsp, PAITRB->(Recno()))
				Endif
				DbSelectArea("PAITRB")
				DbSkip()
			Enddo
		Endif
		DbSelectArea("TRB")
	   DbSkip()
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o PAI calculado                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArred := {	PAG->PAG_FRETE,;
					PAG->PAG_PEDAGI,;
					PAG->PAG_SEGURO,;
					PAG->PAG_TXENTR}
	For nX := 1 to Len(aNfEsp)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no PAI                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("PAITRB")
		DbGoTo(aNfEsp[nX])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o percentual para o frete                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPerc := (PAITRB->PAI_FRETE * 100)/aConhEsp[1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o valor do frete                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("PAITRB",.F.)
		PAITRB->PAI_FRETE 	:= Round((PAG->PAG_FRETE * nPerc)/100,2)
		MsUnlock()
		aArred[1] -= Round((PAG->PAG_FRETE * nPerc)/100,2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o percentual para o pedagio                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPerc := (PAITRB->PAI_PEDAGI * 100)/aConhEsp[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o valor do pedagio                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("PAI",.F.)
		PAITRB->PAI_PEDAGI	:= Round((PAG->PAG_PEDAGI * nPerc)/100,2)
		MsUnlock()
		aArred[2] -= Round((PAG->PAG_PEDAGI * nPerc)/100,2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o percentual para o seguro                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPerc := (PAITRB->PAI_SEGURO * 100)/aConhEsp[2]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o valor do seguro                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("PAI",.F.)
		PAITRB->PAI_SEGURO	:= Round((PAG->PAG_SEGURO * nPerc)/100,2)
		MsUnlock()
		aArred[3] -= Round((PAG->PAG_SEGURO * nPerc)/100,2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o percentual para a taxa de entrega                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPerc := (PAITRB->PAI_TXENTR * 100)/aConhEsp[4]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o valor da taxa de entrega                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("PAI",.F.)
		PAITRB->PAI_TXENTR	:= Round((PAG->PAG_TXENTR * nPerc)/100,2)
		MsUnlock()
		aArred[4] -= Round((PAG->PAG_TXENTR * nPerc)/100,2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera a devolucao                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("PAI",.F.)
		PAITRB->PAI_DEVOL		:= 0.00
		PAITRB->PAI_OPER 		:= "E"
		PAITRB->PAI_TOTAL		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
		nTotFrete       		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
		MsUnlock()
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acerta os arredondamentos                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aArred[1] <> 0
		If Len(aNfEsp) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no PAI                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAI")
			DbGoTo(aNfEsp[1])
			RecLock("PAI",.F.)
			PAITRB->PAI_FRETE		+= aArred[1]
			PAITRB->PAI_TOTAL		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			nTotFrete       		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			MsUnlock()
		Endif
	Endif
	If aArred[2] <> 0
		If Len(aNfEsp) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no PAI                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAI")
			DbGoTo(aNfEsp[1])
			RecLock("PAI",.F.)
			PAITRB->PAI_PEDAGI	+= aArred[2]
			PAITRB->PAI_TOTAL	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			nTotFrete       	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			MsUnlock()
		Endif
	Endif
	If aArred[3] <> 0
		If Len(aNfEsp) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no PAI                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAI")
			DbGoTo(aNfEsp[1])
			RecLock("PAI",.F.)
			PAITRB->PAI_SEGURO	+= aArred[3]
			PAITRB->PAI_TOTAL	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			nTotFrete      		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			MsUnlock()
		Endif
	Endif
	If aArred[4] <> 0
		If Len(aNfEsp) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no PAI                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("PAI")
			DbGoTo(aNfEsp[1])
			RecLock("PAI",.F.)
			PAITRB->PAI_TXENTR	+= aArred[4]
			PAITRB->PAI_TOTAL	:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			nTotFrete      		:= PAITRB->PAI_FRETE+PAITRB->PAI_SEGURO+PAITRB->PAI_PEDAGI+PAITRB->PAI_TXENTR
			MsUnlock()
		Endif
	Endif

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	Endif

	DbSelectArea("PAGTRB")
   DbSkip()
Enddo
If Select("PAGTRB") > 0
	DbSelectArea("PAGTRB")
	DbCloseArea()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza os arquivos temporarios                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
Endif
If Select("PAITRB") > 0
	DbSelectArea("PAITRB")
	DbCloseArea()
	FErase(cArquivo+GetDbExtension())
	FErase(cInd1+OrdBagExt())
	FErase(cInd2+OrdBagExt())
	FErase(cInd3+OrdBagExt())
	FErase(cInd4+OrdBagExt())
Endif
Return nTotFrete

/*/{Protheus.doc} CPFSOC1
Funcao executada na validacao do campo A1_CPFSOC1 para
alertar o usu?io que o CPF digitado j?foi utilizado nos
campos A1_CGC ou A1_CPFSOC1 ou A1_CPFSOC2.
@author Fabio S. Santos
@since 30/07/07
@version P11
@uso Espec?icos - Fusus
@type function
/*/

User Function CPFSOC1()
Local cQuery	:= ""
Local aArea		:= GetArea("SA1")
//DBSelectArea("SA1")
//DBSetOrder(3)
//DBGoTop()
SA1->(DBGoTop())
SA1->(DBSetOrder(3))
If DBSeek(xFilial("SA1")+M->A1_CPFSOC1)
	Aviso("Dados adicionais", "Esse CPF já foi utilizado no cliente:"+ SA1->A1_COD + " " + AllTrim(SA1->A1_NREDUZ) +"!",{"Ok"},,"Atenção:")
EndIf
cQuery := "SELECT A1_CPFSOC1 FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += "AND A1_CPFSOC1 = '"  + M->A1_CPFSOC1 + "' OR A1_CPFSOC2 = '" + M->A1_CPFSOC1 + "' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T. )
dbSelectArea("TRB")
DBGoTop()
If !EOF()

	//Aviso("Dados adicionais", "Esse CPF já foi utilizado no cliente:"+ SA1->A1_COD + " " + AllTrim(SA1->A1_NREDUZ) + " no campo sócio!",{"Ok"},,"Atenção:")
	Aviso("Dados adicionais", "Esse CPF já foi utilizado no campo sócio!",{"Ok"},,"Atenção:")

EndIf
TRB->(DBCloseArea())
//SA1->(DBCloseArea())
RestArea(aArea)
Return

/*/{Protheus.doc} CPFSOC2
Funcao executada na validacao do campo A1_CPFSOC2 para
alertar o usu?io que o CPF digitado j?foi utilizado nos
campos A1_CGC ou A1_CPFSOC1 ou A1_CPFSOC2.
@author Fabio S. Santos
@since 30/07/07
@version P11
@uso Espec?icos - Fusus
@type function
/*/

User Function CPFSOC2()
Local cQuery	:= ""
Local aArea		:= GetArea("SA1")
If xFilial("SA1")+M->A1_CPFSOC2 == xFilial("SA1")+M->A1_CPFSOC1
	MsgInfo("Esse CPF já está sendo utilizado no campo Sócio 1!","Atenção")
	PesqPict("SA1","A1_CPFSOC2",14)
	Return .F.
EndIf

//DBSelectArea("SA1")
SA1->(DBGoTop())
SA1->(DBSetOrder(3))
If DBSeek(xFilial("SA1")+M->A1_CPFSOC2)
	Aviso("Dados adicionais", "Esse CPF já foi utilizado no cliente:"+ SA1->A1_COD + " " + AllTrim(SA1->A1_NREDUZ) +"!",{"Ok"},,"Atenção:")
EndIf

cQuery := "SELECT A1_CPFSOC2 FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += "AND A1_CPFSOC1 = '"  + M->A1_CPFSOC2 + "' OR A1_CPFSOC2 = '" + M->A1_CPFSOC2 + "' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T. )
dbSelectArea("TRB")
DBGoTop()
If !EOF()

	//Aviso("Dados adicionais", "Esse CPF já foi utilizado no cliente:"+ SA1->A1_COD + " " + AllTrim(SA1->A1_NREDUZ) + "no campo sócio!",{"Ok"},,"Atenção:")
	Aviso("Dados adicionais", "Esse CPF já foi utilizado no campo sócio!",{"Ok"},,"Atenção:")

EndIf
TRB->(DBCloseArea())
//SA1->(DBCloseArea())
RestArea(aArea)
Return  .T.

/*/{Protheus.doc} TESUSER
Verificar o Tes e o usu?io no pedido de vendas.
@author F?io S. dos Santos
@since 06/08/07
@version P11
@uso Espec?ico Fusus
@type function
/*/

User Function TESUSER()
Local aArea		:= GetArea()
Local cTes		:= ""
Local cUserTes	:= GetNewPar("MV_USERTES","000001")
Local cTesUser	:= GetNewPar("MV_TESUSER","501")
Local nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})

DBSelectArea("SB1")
DBSetOrder(1)
//DBSeek(xFilial("SB1")+AllTrim(M->C6_PRODUTO))
// Alterado em 29/07/2007 por Zeca
DBSeek(xFilial("SB1")+AllTrim(aCols[n,nPosItem]))
cTes := SB1->B1_TS

If !l410AUTO
	If ReadVar() == "M->C6_PRODUTO"
		If (cUserTes <> __cUserID) .And. (cTesUser == cTes)
			Alert("Esse usuário não pode usar esse TES: " + SB1->B1_TS + " Digite outro TES!","Alerta")
			aCols[n,nPosTes] := CriaVar("C6_TES")
		EndIf
	ElseIf ReadVar() == "M->C6_TES"
		If (cUserTes <> __cUserID) .And. (cTesUser == M->C6_TES)
			Alert("Esse usuário não pode usar esse TES: " + M->C6_TES + " Digite outro TES!","Alerta")
			aCols[n,nPosTes] := CriaVar("C6_TES")
			M->C6_TES :=""
		EndIf
	EndIf
	oGetDad:oBROWSE:Refresh()
EndIf
RestArea(aArea)

Return cTes

/*/{Protheus.doc} PrdInvSh
Calculo especifico do saldo em estoque no ultimo inventario.
Copia da rotina padrao FsPrdInv, selecionando registros da
tabela SB2 no lugar da tabela SB9. O cliente Shell nao acessa
a rotina de fechamento de estoque, respons?el por popular a
tabela SB9.
Eduardo Riera 15/01/03      Autor da rotina FsPrdInv (mata950.prx)
@author Aline Catarina
@since 29/05/2008
@version P11
@uso Generico
@param cCodPro, characters, Codigo do produto
@param lCliFor, logical, Indica se o saldo em/de terceiro deve ser por CNPJ
@param dUltFec, date
@return aSaldo, array, [.][1] Quantidade do Produto
                       [.][2] Valor do Produto
                       [.][3] 1 - Nosso:2-De terceiros;3-Em terceiros
                       [.][4] Tipo(C/F)+Codigo de Cliente/Fornecedor
@type function
/*/
User Function PrdInvSh(cCodPro,lCliFor,dUltFec)

Local aArea     :=	GetArea()
Local aSaldo    :=	{}
Local aRetorno  :=	{}
Local cQuery    :=	""
Local cAliasSB2 :=	"SB2"
//Local cAliasSB9 :=	"SB9SH"
Local lQuery    :=	.F.
Local nX        :=	0
Local nY        :=	0

Default dUltFec := SuperGetMv("MV_ULMES")

dbSelectArea("SB2")
dbSetOrder(1)

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery := .T.
	Endif
#ENDIF

If lQuery
	cAliasSB2 := "PRDINVSH"
	cQuery := "SELECT B2_FILIAL,B2_COD,B2_LOCAL "
	cQuery += "FROM "+RetSqlName("SB2")+" SB2 "
	cQuery += "WHERE SB2.B2_FILIAL='"+xFilial("SB2")+"' AND "
	cQuery += "SB2.B2_COD='"+cCodPro+"' AND "
	cQuery += "SB2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SB2->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB2)
Else
	MsSeek(xFilial("SB2")+cCodPro)
EndIf

While (!Eof() .And. (cAliasSB2)->B2_FILIAL == xFilial("SB2") .And.;
		(cAliasSB2)->B2_COD == cCodPro )

	aRetorno := CalcEst(cCodPro,(cAliasSB2)->B2_LOCAL,dUltFec+1)
	nY := aScan(aSaldo,{|x| x[3] == 1 .And. x[4]==""})
	If nY==0
		aadd(aSaldo,{aRetorno[1],aRetorno[2],1,""})
	Else
		aSaldo[nY][1] += aRetorno[1]
		aSaldo[nY][2] += aRetorno[2]
		aSaldo[nY][3] := 1
		aSaldo[nY][4] := ""
	EndIf
	aRetorno := SaldoTerc(cCodPro,(cAliasSB2)->B2_LOCAL,"T",dUltFec,(cAliasSB2)->B2_LOCAL,lCliFor) //De terceiro
	If lCliFor
		For nX := 1 To Len(aRetorno)
			nY := aScan(aSaldo,{|x| x[3] == 2 .And. x[4]==aRetorno[nX][1]})
			If nY==0
				aadd(aSaldo,{aRetorno[nX][2],aRetorno[nX][3],2,aRetorno[nX][1]})
			Else
				aSaldo[nY][1] += aRetorno[nX][2]
				aSaldo[nY][2] += aRetorno[nX][3]
				aSaldo[nY][3] := 2
				aSaldo[nY][4] := aRetorno[nX][1]
			EndIf
		Next nX
	Else
		nY := aScan(aSaldo,{|x| x[3] == 2 })
		If nY == 0
			aadd(aSaldo,{aRetorno[1],aRetorno[2],2,""})
		Else
			aSaldo[nY][1] += aRetorno[1]
			aSaldo[nY][2] += aRetorno[2]
		EndIf
	EndIf
	aRetorno := SaldoTerc(cCodPro,(cAliasSB2)->B2_LOCAL,"D",dUltFec,(cAliasSB2)->B2_LOCAL,lCliFor) //Em terceiro
	If lCliFor
		For nX := 1 To Len(aRetorno)
			nY := aScan(aSaldo,{|x| x[3] == 3 .And. x[4]==aRetorno[nX][1]})
			If nY==0
				aadd(aSaldo,{aRetorno[nX][2],aRetorno[nX][3],3,aRetorno[nX][1]})
			Else
				aSaldo[nY][1] += aRetorno[nX][2]
				aSaldo[nY][2] += aRetorno[nX][3]
				aSaldo[nY][3] := 3
				aSaldo[nY][4] := aRetorno[nX][1]
			EndIf
		Next nX
	Else
		nY := aScan(aSaldo,{|x| x[3] == 3 })
		If nY == 0
			aadd(aSaldo,{aRetorno[1],aRetorno[2],3,""})
		Else
			aSaldo[nY][1] += aRetorno[1]
			aSaldo[nY][2] += aRetorno[2]
		EndIf
	EndIf
	dbSelectArea(cAliasSB2)
	dbSkip()
EndDo
If lQuery
	dbSelectArea(cAliasSB2)
	dbCloseArea()
	dbSelectArea("SB2")
EndIf
If Empty(aSaldo)
	aSaldo := {{0,0,1,""},{0,0,2,""},{0,0,3,""}}
EndIf
RestArea(aArea)
Return(aSaldo)

/*/{Protheus.doc} EstInvSh
Calculo do saldo em estoque no ultimo inventario. Copia da
da rotina FsEstInv, chamando a funcao especifica da Shell
PrdInvSh no lugar da rotina padrao FsPrdInv.
@author Aline Catarina
@since 29/05/2008
@version P11
@uso Generico
@param aAlias, array, [1] Alias do Arquivo
                      [2] Nome do arquivo fisico
@param nTipo, numeric,[1] Para Inicializacao
                      [2] Para finalizacao
@param lCliFor, logical, Indica se o saldo em/de terceiro deve ser por CNPJ
@param lMovimen, logical, Indica se os produtos sem saldo devem ser registrados
@param dUltFec, date, Data de fechamento do estoque a ser considerada
@param lNCM, logical, Indica se a codificação deve ser feita por NCM
@param lST, logical
@param lSelB5, logical
@param cFiltraB5, characters
@param aNFsProc, array
@param aProcCod, array
@return Arquivo no formato:
     CODIGO  C 15   Codigo do Produto
     UM      C 02   Unidade de Medida
     SITUACA C 01   1-Proprio;2=Em Terceiro;3=De Terceiro
     QUANT   N 19 3 Quantidade
     CUSTO   N 19 3 Custo Total
     CNPJ    C 14 0 CNPJ  (Ver parametro ExpL3)
@type function
/*/
User Function EstInvSh(aAlias,nTipo,lCliFor,lMovimen,dUltFec,lNCM,lST,lSelB5,cFiltraB5,aNFsProc,aProcCod)

Local aCampos   := {}
Local aSaldo    := {}
Local aTam		:= {}
Local cAliasSB1 := "SB1"
Local cQuery    := ""
Local cCNPJ     := ""
Local cInsc 	:= ""
Local cUf	  	:= ""
Local lQuery    := .F.
Local lCodPro   := .F.
Local nX        := 0
Local cMvEstado := GetMv("MV_ESTADO")
//Local cMvEstado := "SP"
Local cAliasNCM := ""
Local cArqNCM   := ""
Local cNome		:= ""
Local cCodNome	:= ""
Local aUltMov	:= {}
Local cCodInv	:= GetNewPar("MV_CODINV","")
//Local cCodInv	:= ""
Local lA950PRD	:= Existblock("A950PRD")
Local aICMS		:= {}
Local l88STMG	:= GetNewPar("MV_88STMG",.F.)
//Local l88STMG	:= .F.
Local c88Ind	:= ""

#IFDEF TOP
	Local aStru     := {}
#ELSE
	Local c88Chave	:= ""
	Local c88Filtro	:= ""
	Local cIndSB6   := ""
	Local cChave    := ""
#ENDIF

Local lRgEspSt	:= GetNewPar("MV_RGESPST",.F.)
//Local lRgEspSt	:= .F.
Local lUsaSFT	:= AliasInDic("SFT") .And. SFT->(FieldPos("FT_RGESPST")) > 0
//Local lUsaSFT	:= .F.

DEFAULT aAlias	 	:= {"INVSH",""}
DEFAULT lCliFor 	:= .F.
DEFAULT lMovimen	:= .T.
DEFAULT dUltFec 	:= SuperGetMV("MV_ULMES")
DEFAULT lNCM    	:= .F.
DEFAULT lST			:= .F.
DEFAULT lSelB5		:= .F.
DEFAULT cFiltraB5	:= ""
DEFAULT	aNFsProc	:= {}
DEFAULT	aProcCod	:= {}

If !Empty(cFiltraB5)
	lSelB5 := .T.
Endif

If nTipo==1

	If l88STMG
		#IFNDEF TOP
			dbSelectArea("SD1")
			c88Ind		:=	CriaTrab(NIL,.F.)
			c88Chave	:=	"D1_NFORI+D1_SERIORI+D1_ITEMORI"
			c88Filtro	:=	"D1_FILIAL == '" + xFilial("SD1") + "' .And. "
			If !lRgEspSt
				c88Filtro	+=	"D1_TIPO $ 'P/I/C' .And. D1_ICMSRET > 0 .And. Dtos(D1_DTDIGIT) < '" + Dtos(dUltFec) + "'"
			Else
				c88Filtro	+=	"D1_TIPO $ 'P/I/C' .And. Dtos(D1_DTDIGIT) < '" + Dtos(dUltFec) + "'"
			Endif
			IndRegua("SD1",c88Ind,c88Chave,,c88Filtro,Nil,.F.)
			dbClearIndex()
			RetIndex("SD1")
			dbSetIndex(c88Ind+OrdBagExt())
			dbSetOrder(1)
		#ENDIF
	Endif

	PRIVATE nIndSb6 := 0
	#IFNDEF TOP
		dbSelectArea("SB6")
		cIndSB6 := CriaTrab(Nil,.F.)
		cChave := "B6_FILIAL+B6_PRODUTO+B6_LOCAL+B6_TIPO+DTOS(B6_DTDIGIT)"
		cQuery := 'B6_FILIAL="'+xFilial("SB6")+'" .And. DtoS(B6_DTDIGIT)<="'+Dtos(dUltFec)+'"'
		IndRegua("SB6",cIndSB6,cChave,,cQuery,Nil,.F.)
		nIndSB6:=RetIndex("SB6")
		dbSetIndex(cIndSB6+OrdBagExt())
		dbSetOrder(nIndSB6 + 1)
		dbGoTop()
	#ENDIF

	aadd(aCampos,{"CODIGO" ,"C",15,0})
	aadd(aCampos,{"CODPRD" ,"C",15,0})
	aadd(aCampos,{"NCM"    ,"C",14,0})
	aadd(aCampos,{"UM"     ,"C",02,0})
	aadd(aCampos,{"SITUACA","C",01,0})
	aadd(aCampos,{"QUANT"  ,"N",19,3})
	aadd(aCampos,{"CUSTO"  ,"N",19,3})
	aadd(aCampos,{"CNPJ"   ,"C",14,0})
	aTam:=TamSX3("A2_INSCR")
	aadd(aCampos,{"INSCR"  ,"C",aTam[1],0})
	aadd(aCampos,{"UF"     ,"C",02,0})
	aadd(aCampos,{"NOME"   ,"C",40,0})
	aadd(aCampos,{"CODNOME","C",06,0})
	aadd(aCampos,{"BASEST" ,"N",14,2})
	aadd(aCampos,{"VALST"  ,"N",14,2})
	aadd(aCampos,{"VALICMS","N",14,2})	//Valor do ICMS Operacao Propria
	aadd(aCampos,{"ICMSRET","N",14,2})	//Valor do ICMS ST
	aadd(aCampos,{"ALIQST" ,"N",05,2})
	aadd(aCampos,{"CODINV" ,"C",01,0})		//Campo utilizado pelo o SEF-PE
	aadd(aCampos,{"TIPO"   ,"C",TamSX3("B1_TIPO")[1],0}) //Campo com o tipo do produto
	aadd(aCampos,{"DESC_PRD" ,"C",50,0})	//Descricao produto
	aadd(aCampos,{"CLASSFIS" ,"C",02,0})	//Classificacao Fiscal
	aAlias[2] := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,__LocalDrive,aAlias[2],aAlias[1],.F.,.F.)

	dbSelectArea("SB1")
	dbSetOrder(1)
	#IFDEF TOP
		aStru     := SB1->(dbStruct())
		cAliasSB1 := "FSESTINV"
		lQuery    := .T.

		cQuery := "SELECT B1_FILIAL, B1_TIPO, B1_COD, B1_DESC, B1_UM, B1_POSIPI, B1_PICMENT, B1_PICM, B1_CLASFIS, B1_CODBAR "
		cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
		If lSelB5
			cQuery += " , "+RetSqlName("SB5")+" SB5 "
		Endif
		cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		cQuery += "SB1.D_E_L_E_T_=' ' "
		If lSelB5
			cQuery += " AND SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery += " AND SB5.B5_COD = SB1.B1_COD "
			cQuery += " AND SB5.D_E_L_E_T_=' ' "
		Endif
		If !Empty(cFiltraB5)
			cQuery += cFiltraB5 + ' '
		Endif

		cQuery += "ORDER BY "+SqlOrder(SB1->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1)

		For nX := 1 To Len(aStru)
			If aStru[nX][2] <> "C"
				TcSetField(cAliasSB1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX

	#ELSE
		MsSeek(xFilial("SB1"))
	#ENDIF
	While !Eof() .And. (cAliasSB1)->B1_FILIAL == xFilial("SB1")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se devera ser considerado o SB5 na geracao do estoque³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSelB5 .And. !lQuery
			SB5->(dbSetOrder(1))
			If !(SB5->(dbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD)))
				(cAliasSB1)->(dbSkip())
				Loop
			Endif
			If !Empty(cFiltraB5)
				If !(&cFiltraB5)
					(cAliasSB1)->(dbSkip())
					Loop
				Endif
			Endif
		Endif

		If !lCodPro .And. Len(AllTrim((cAliasSB1)->B1_COD))==15 .And. !lA950PRD
			lCodPro := .T.
		EndIf

		aSaldo := U_PrdInvSh((cAliasSB1)->B1_COD,lCliFor,dUltFec)

		For nX := 1 To Len(aSaldo)
			If aSaldo[nX][1]<>0 .Or. aSaldo[nX][3]==1
				If !Empty(aSaldo[nX][4])
					If SubStr(aSaldo[nX][4],1,1)=="C"
						dbSelectArea("SA1")
						dbSetOrder(1)
						MsSeek(xFilial("SA1")+SubStr(aSaldo[nX][4],2))
						cCNPJ 		:= SA1->A1_CGC
						cInsc 		:= SA1->A1_INSCR
						cUf	  		:= SA1->A1_EST
						cNome		:= SubStr(SA1->A1_NOME,1,40)
						cCodNome 	:= SA1->A1_COD
					Else
						dbSelectArea("SA2")
						dbSetOrder(1)
						MsSeek(xFilial("SA2")+SubStr(aSaldo[nX][4],2))
						cCNPJ		:= SA2->A2_CGC
						cInsc 		:= SA2->A2_INSCR
						cUf	  		:= SA2->A2_EST
						cNome 		:= SubStr(SA2->A2_NOME,1,40)
						cCodNome 	:= SA1->A1_COD
					EndIf
				Else
					cCNPJ := SM0->M0_CGC
					cINSC := SM0->M0_INSC
					cUf	  := cMvEstado
				EndIf

				If lMovimen
					RecLock(aAlias[1],.T.)
					(aAlias[1])->DESC_PRD := (cAliasSB1)->B1_DESC
					(aAlias[1])->CODIGO := IIf(lA950PRD,Execblock("A950PRD",.F.,.F.,{cAliasSB1}),(cAliasSB1)->B1_COD)
					(aAlias[1])->CODPRD := (cAliasSB1)->B1_COD
					(aAlias[1])->UM     := (cAliasSB1)->B1_UM
					(aAlias[1])->SITUACA:= StrZero(aSaldo[nX][3],1)
					(aAlias[1])->QUANT  := aSaldo[nX][1]
					(aAlias[1])->CUSTO  := aSaldo[nX][2]
					(aAlias[1])->CNPJ   := cCNPJ
					(aAlias[1])->INSCR  := cINSC
					(aAlias[1])->UF   	 := cUF
					(aAlias[1])->NCM   	 := (cAliasSB1)->B1_POSIPI
					(aAlias[1])->NOME  	 := cNome
					(aAlias[1])->CODNOME := cCodNome
					(aAlias[1])->TIPO	:= (cAliasSB1)->B1_TIPO
					If At((cAliasSB1)->B1_TIPO+"=",cCodInv) > 0
						(aAlias[1])->CODINV := Substr(cCodInv,At((cAliasSB1)->B1_TIPO+"=",cCodInv)+3,1)
					Else
						(aAlias[1])->CODINV := "1"	//Mercadorias
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica o valor do ICMS Subst. Tributaria da ultima entrada, de acordo com o parametro³
					//³Apenas para os produtos que possuem a aliquota do ICMS ST entrada em seu cadastro.     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lST .And. ((!lRgEspSt .And. (cAliasSB1)->B1_PICMENT > 0) .Or. lRgEspSt)
						aICMS := RetTotICMS((cAliasSB1)->B1_COD,dUltFec,aSaldo[nX][1],c88Ind,@aNFsProc,lRgEspSt,lUsaSFT)
						Aadd(aProcCod,(cAliasSB1)->B1_COD)
						(aAlias[1])->VALICMS := aICMS[1]	//ICMS Proprio
						(aAlias[1])->ICMSRET := aICMS[2]	//ICMS ST
					Endif
					(aAlias[1])->CLASSFIS	:= (cAliasSB1)->B1_CLASFIS
					MsUnLock()
				Else
					If aSaldo[nX][1]>0 .And. aSaldo[nX][2]>0
						RecLock(aAlias[1],.T.)
						(aAlias[1])->DESC_PRD := (cAliasSB1)->B1_DESC
						(aAlias[1])->CODIGO := IIf(lA950PRD,Execblock("A950PRD",.F.,.F.,{cAliasSB1}),(cAliasSB1)->B1_COD)
						(aAlias[1])->CODPRD := (cAliasSB1)->B1_COD
						(aAlias[1])->UM     := (cAliasSB1)->B1_UM
						(aAlias[1])->SITUACA:= StrZero(aSaldo[nX][3],1)
						(aAlias[1])->QUANT  := aSaldo[nX][1]
						(aAlias[1])->CUSTO  := aSaldo[nX][2]
						(aAlias[1])->CNPJ   := cCNPJ
						(aAlias[1])->INSCR  := cINSC
						(aAlias[1])->UF   	 := cUF
						(aAlias[1])->NCM     := (cAliasSB1)->B1_POSIPI
						(aAlias[1])->NOME  	  := cNome
						(aAlias[1])->CODNOME := cCodNome
						(aAlias[1])->TIPO	:= (cAliasSB1)->B1_TIPO
						If At((cAliasSB1)->B1_TIPO+"=",cCodInv) > 0
							(aAlias[1])->CODINV := Substr(cCodInv,At((cAliasSB1)->B1_TIPO+"=",cCodInv)+3,1)
						Else
							(aAlias[1])->CODINV := "1"	//Mercadorias
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica o valor do ICMS Subst. Tributaria da ultima entrada, de acordo com o parametro³
						//³Apenas para os produtos que possuem a aliquota do ICMS ST entrada em seu cadastro.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lST .And. ((!lRgEspSt .And. (cAliasSB1)->B1_PICMENT > 0) .Or. lRgEspSt)
							aICMS := RetTotICMS((cAliasSB1)->B1_COD,dUltFec,aSaldo[nX][1],c88Ind,@aNFsProc,lRgEspSt,lUsaSFT)
							Aadd(aProcCod,(cAliasSB1)->B1_COD)
							(aAlias[1])->VALICMS := aICMS[1]	//ICMS Proprio
							(aAlias[1])->ICMSRET := aICMS[2]	//ICMS ST
						Endif
						(aAlias[1])->CLASSFIS	:= (cAliasSB1)->B1_CLASFIS
						MsUnLock()
					Endif
				Endif
			EndIf
		Next nX
		dbSelectArea(cAliasSB1)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSB1)
		dbCloseArea()
		dbSelectArea("SB1")
	EndIf
	#IFNDEF TOP
		dbSelectArea("SB6")
		RetIndex("SB6")
		Ferase(cIndSB6+OrdBagExt())
	#ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se os produtos devem ser aglutinados por NCM                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNCM
		cAliasNCM := GetNextAlias()
		cArqNCM   := CriaTrab(aCampos,.T.)
		dbUseArea(.T.,__LocalDrive,cArqNCM,cAliasNCM,.F.,.F.)

		If lCodPro
			IndRegua(cAliasNCM,cArqNCM,"NCM+SITUACA+CNPJ+INSCR",,,Nil,.F.)	//?Por NCM
		Else
			IndRegua(cAliasNCM,cArqNCM,"CODIGO+SITUACA+CNPJ+INSCR",,,Nil,.F.)	//Por codigo produto
		EndIf

		dbSelectArea(aAlias[1])
		dbGotop()
		While !Eof()
			dbSelectArea(cAliasNCM)
			If MsSeek(Iif (lCodPro, (aAlias[1])->NCM, (aAlias[1])->CODIGO)+(aAlias[1])->SITUACA+(aAlias[1])->CNPJ+(aAlias[1])->INSCR)
				RecLock(cAliasNCM,.F.)
			Else
				RecLock(cAliasNCM,.T.)
			EndIf
			(cAliasNCM)->DESC_PRD	:=	(aAlias[1])->DESC_PRD
			(cAliasNCM)->CODIGO 	:= Iif (lCodPro, (aAlias[1])->NCM, (aAlias[1])->CODIGO)
			(cAliasNCM)->CODPRD 	:= (aAlias[1])->CODPRD
			(cAliasNCM)->UM     	:= (aAlias[1])->UM
			(cAliasNCM)->SITUACA	:= (aAlias[1])->SITUACA
			(cAliasNCM)->QUANT  	+= (aAlias[1])->QUANT
			(cAliasNCM)->CUSTO  	+= (aAlias[1])->CUSTO
			(cAliasNCM)->CNPJ   	:= (aAlias[1])->CNPJ
			(cAliasNCM)->INSCR  	:= (aAlias[1])->INSCR
			(cAliasNCM)->UF   		:= (aAlias[1])->UF
			(cAliasNCM)->NCM   		:= (aAlias[1])->NCM
			(cAliasNCM)->NOME   	:= (aAlias[1])->NOME
			(cAliasNCM)->CODNOME	:= (aAlias[1])->CODNOME
			(cAliasNCM)->BASEST 	+= (aAlias[1])->BASEST
			(cAliasNCM)->VALST		+= (aAlias[1])->VALST
			(cAliasNCM)->ALIQST		:= (aAlias[1])->ALIQST
			(cAliasNCM)->TIPO		:= (aAlias[1])->TIPO
			(cAliasNCM)->VALICMS	+= (aAlias[1])->VALICMS	//ICMS Operacoes Proprias
			(cAliasNCM)->ICMSRET	+= (aAlias[1])->ICMSRET	//ICMS ST
			If At((aAlias[1])->TIPO+"=",cCodInv) > 0
				(cAliasNCM)->CODINV := Substr(cCodInv,At((aAlias[1])->TIPO+"=",cCodInv)+3,1)
			Else
				(cAliasNCM)->CODINV := "1"	//Mercadorias
			Endif
			(cAliasNCM)->CLASSFIS	:= (aAlias[1])->CLASSFIS
			MsUnLock()
			dbSelectArea(aAlias[1])
			dbSkip()
		EndDo
		dbSelectArea(aAlias[1])
		dbCloseArea()
		dbSelectArea(cAliasNCM)
		dbCloseArea()
		FErase(cAliasNCM+OrdBagExt())
		FErase(aAlias[2]+GetDbExtension())
		aAlias[2] := cArqNCM
		dbUseArea(.T.,__LocalDrive,aAlias[2],aAlias[1],.F.,.F.)
	EndIf
	If l88STMG
		#IFNDEF TOP
			dbSelectArea("SD1")
			RetIndex("SD1")
			FErase(c88Ind+OrdBagExt())
		#ENDIF
	Endif
Else
	dbSelectArea(aAlias[1])
	dbCloseArea()
	FErase(aAlias[2]+GetDbExtension())
	dbSelectArea("SM0")
EndIf
Return(.T.)

/*/{Protheus.doc} RetImpos
Calculo de impostos do item
@author F?io S. dos Santos
@since 23/06/2008
@version P11
@param cProduto, characters, Codigo do Produto
@param cTes, characters, codigo do tes
@param nQtd, numeric, Quantidade
@param nTotal, numeric, Valor total do item
@param nDesconto, numeric, Desconto
@param cCliente, characters
@param cLoja, characters
@param nPis, numeric
@param  nCofins, numeric
@param  nIpi, numeric
@param  nIcm, numeric
@type function
/*/
User Function RetImpos(cProduto,cTes,nQtd,nTotal,nDesconto,cCliente,cLoja,nPis, nCofins, nIpi, nIcm)

Local aArea		:= GetArea()
Local cNatureza := posicione("SA1",1,xFilial("SA1")+cCliente+cLOJA,"A1_NATUREZ")

mafissave()
MaFisEnd()

MaFisIni(cCliente,cLoja,"C","N",Nil,,,.T.)

MaFisAlt("NF_NATUREZA",cNatureza)

MaFisAdd( cProduto,;		  // 1-Codigo do Produto ( Obrigatorio )
	  cTes,;		  // 2-Codigo do TES ( Opcional )
	  nQtd,;		     // 3-Quantidade ( Obrigatorio )
	  nTotal,;		  // 4-Preco Unitario ( Obrigatorio )
	  nDesconto,;		  // 5-Valor do Desconto ( Opcional )
	  "",;                    // 6-Numero da NF Original ( Devolucao/Benef )
	  "",;                    // 7-Serie da NF Original ( Devolucao/Benef )
	  0,;			  // 8-RecNo da NF Original no arq SD1/SD2
	  0,;			  // 9-Valor do Frete do Item ( Opcional )
	  0,;			  // 10-Valor da Despesa do item ( Opcional )
	  0,;			  // 11-Valor do Seguro do item ( Opcional )
	  0,;			  // 12-Valor do Frete Autonomo ( Opcional )
	  (nTotal - nDesconto),;  // 13-Valor da Mercadoria ( Obrigatorio )
	  0,;			  // 14-Valor da Embalagem ( Opiconal )
	  Nil,; 		  // 15-RecNo do SB1
	  Nil)			  // 16-RecNo do SF4

nIcm	:= MaFisRet(1,"IT_VALICM")
nIpi	:= MaFisRet(1,"IT_VALIPI")
nCofins := MaFisRet(1,"IT_VALCOF")  	//Valor do COFINS
If nCofins = 0
   nCofins	:= mafisret(1,"IT_VALCF2")		//Valor do COFINS
Endif
nPis	:= maFisRet(1,"IT_VALPIS")		//Valor do PIS
If nPis = 0
   nPis	:= maFisRet(1,"IT_VALPS2")		//Valor do PIS
Endif

MaFisEnd()
mafisrestore()

RestArea(aArea)

Return()

/*/{Protheus.doc} SHEVLACR
Gatilho do campo C5_CLIENTE para analise de acrescimo
financeiro com pesquisa no parametro ES_GRACFIN
J.C.Rocha     01/07/08 		Importacao por PDA ja traz os precos
			  		   		com o acrescimo financeiro.
			  		   		Solucao: Avaliado variavel l410AUTO
			  		   		para nao executar a pesquisa do valor
			  		   		na tabela condicao de pagamento SE4
@author Jose C. Frasson
@since 27/08/08
@version P11
@uso SHELL
@type function
/*/
User Function SHEVLACR()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis        											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cQuery		:= ""
Local Area			:= GetArea()
Local cCliente  	:= Iif(Alltrim(ReadVar())=="M->C5_CLIENTE" ,&(ReadVar()),M->C5_CLIENTE)
Local cLoja     	:= Iif(Alltrim(ReadVar())=="M->C5_LOJACLI" ,&(ReadVar()),M->C5_LOJACLI)
Local cImportado    := Iif(Alltrim(ReadVar())=="M->C5_IMPORTA" ,&(ReadVar()),M->C5_IMPORTA)
Local cGrupos		:= GetMV("ES_GRACFIN")
Local nValAcrFin:= 0
Local nPQtdVen 		:= 0
Local nX			:= 0
Local _nRegs        := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao valida os pedidos de remessa                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If U_VerRot("M410GerRem") .or. U_VerRot("U_M410GerRem")
	Return(.T.)
Endif
If M->C5_TIPO <> "N"
	Return(nValAcrfin)
Endif

If ACY->(FieldPos("ACY_ZZACRE")) > 0 //Verifica se existe o campo de Acrescimo (S=SIM ou N=NÃO) - Feito por Max Ivan (Nexus) em 26/10/2018
   SA1->(DbSetOrder(1))
   If SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
      If !Empty(SA1->A1_GRPVEN)
         ACY->(DbSetOrder(1))
         If ACY->(DbSeek(xFilial("ACY")+SA1->A1_GRPVEN))
            If ACY->ACY_ZZACRE == "S"
               _nRegs := 1
            EndIf
         EndIf
      EndIf
   EndIf
Else
   cQuery	:= "SELECT COUNT(1) REGS"
   cQuery	+= " FROM "+RetSqlName("SA1")+" SA1"
   cQuery	+= " WHERE A1_GRPVEN IN (" + AllTrim(cGrupos) + ")"
   cQuery	+= " AND A1_COD = '" + cCliente + "'"
   cQuery	+= " AND A1_LOJA = '" + cLoja + "'"
   cQuery	+= " AND A1_FILIAL = '" + xFilial("SA1")+"'"
   cQuery	+= " AND SA1.D_E_L_E_T_ <> '*'"
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
   dbSelectArea("TRB")
   _nRegs := TRB->REGS
   TRB->(DbCloseArea())
EndIf

If !Empty(cCliente) .And. !Empty(cLoja) .And. (cImportado == "N" .Or. Empty(cImportado))

	If _nRegs == 0
		// Cliente Nao estah num grupo que permite acrescimo financeiro da tabela...
		// Preencher campo SC5->C5_X_ACRES com zero
		//M->C5_X_ACRES := 0
		nValAcrfin	:= 0
	Else
		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek(xFilial("SE4")+M->C5_CONDPAG)
		nValAcrfin	:= SE4->E4_X_ACRES
	Endif

	dbSelectArea("SE4")
	dbCloseArea()


	For nX := 1 To Len(aCols)
   		GDFieldPut("C6_QTDVEN"	,0	,nX)
   		GDFieldPut("C6_PRCLIST"	,0	,nX)
   	Next nX

	If !IsInCallStack("Mata410") .Or. !l410Auto
		oGetDad:OBROWSE:Refresh()
	EndIf

Endif
If ALTERA .OR. cImportado == "S"
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(xFilial("SC5")+M->C5_NUM)
	//cCondPag	:= SC5->C5_CONDPAG
	//If cCondPag != M->C5_CONDPAG
		If _nRegs == 0
			// Cliente Nao estah num grupo que permite acrescimo financeiro da tabela...
			// Preencher campo SC5->C5_X_ACRES com zero
			//M->C5_X_ACRES := 0
			nValAcrfin	:= 0
		Else
			DbSelectArea("SE4")
			DbSetOrder(1)
			DbSeek(xFilial("SE4")+M->C5_CONDPAG)
		nValAcrfin	:= SE4->E4_X_ACRES
			dbSelectArea("SE4")
			dbCloseArea()
   		Endif
	//EndIf
EndIf

RestArea(Area)
Return(nValAcrfin)

/*/{Protheus.doc} C5_CONDGRP
Validacao do campo C5_CONDPAG - Pesquisar Excessoes
@author Jose C. Frasson
@since 11/08/08
@version P11
@uso Exclusivo Shell
@type function
/*/
User Function C5_CONDGRP()
Local aAreas	:= GetArea()
Local nCondgrp	:= 0
Local lRet		:= .T.

If !Empty(M->C5_CONDPAG)
	SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
	dbSelectArea("PAJ")
	dbSetOrder(1) // PAJ_FILIAL+PAJ_GRPVEN
	dbGotop()
	If dbSeek(xFilial("PAJ") + SA1->A1_GRPVEN)
		While !EOF()
			If (PAJ->PAJ_GRPVEN + PAJ->PAJ_CODPAG) == (SA1->A1_GRPVEN + M->C5_CONDPAG)
				nCondgrp ++
			Endif
			DbSkip()
		Enddo
	Endif
Endif

If nCondgrp > 0
	Aviso('Atenção','Condição de Pagamento não aceita para' +;
		  ' o grupo em que esse cliente está cadastrado. Selecione outra condição!',{'OK'})
	lRet	:= .F.
Endif

RestArea(aAreas)

Return lRet

/*/{Protheus.doc} SHEM050
Função para consulta da posição de clientes hist?ica.
Tiago Malta 	 03/04/09	Tratamento da consulta remota no servidor
				 		 	da fusus do Codigo  de cliente anterior
@author F?io S. dos Santos
@since 21/08/08
@version P11
@uso SHELL
@param cAlias, characters
@param nRecno, numeric
@param nOpc, numeric
@type function
/*/
User Function SHEM050(cAlias,nRecno,nOpc)
Local cSavFil	:= cFilAnt
Local aArea		:= GetArea()
Local lRmtCons      := (( "GRASSI" $ SM0->M0_NOME .AND. cFilAnt == "01" ) .OR. ( "QUITE" $ SM0->M0_NOME .AND. cFilAnt == "02" ) .OR. ( "GT" $ SM0->M0_NOME .AND. cFilAnt == "01" ) .OR. ( "MCA LUB" $ SM0->M0_NOME .AND. cFilAnt == "01" ) .OR. ( "LUBPAR" $ SM0->M0_NOME .AND. cFilAnt == "01" ))
Local cConBanco		:= "MSSQL/CTOR4K"
Local cSrvBanco		:= "192.168.4.195"
Local nPorta   		:= 7890
Private oDBInteg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Conexão com a base da Fusus.		                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRmtCons
	oDBInteg  := ClsDBAccess():New( cConBanco, cSrvBanco , nPorta )

	If !oDBInteg:AbreConexao()
		cMsg :=  'Falha Conexão com a base de integracao - Erro: ' + AllTrim( Str( oDBInteg:nHandle ) )
		Alert(cMsg)
		Return .F.
	EndIf
Endif

dbSelectArea("SA1")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	DbSeek(xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI)
	If !Empty(SA1->A1_CODANT)
	    If lRmtCons .and. ValType(oDbInteg) == "O"
	    	cAliasA1 := "SA1"
	    	cQuery	 := " SELECT * FROM SA1010 WHERE D_E_L_E_T_ = '' "
	    	cQuery	 += " AND A1_FILIAL = '"+SA1->A1_FILANT+"' "
	    	cQuery	 += " AND A1_COD    = '"+SA1->A1_CODANT+"' "
	    	cQuery	 += " AND A1_LOJA   = '"+SA1->A1_LOJAANT+"' "
	   		U_ConnectRem( cAliasA1 , cQuery )
	   		cFilAnt		:=	SA1->A1_FILIAL
 		Else
			dbSeek(SA1->A1_FILANT+SA1->A1_CODANT+SA1->A1_LOJA)
			cFilAnt		:=	SA1->A1_FILIAL
		EndIf

		If ( Pergunte("FIC010",.T.) )
   			Fc010Con()
		EndIf
	Else
		MsgInfo("Esse cliente não possui dados históricos!", "Consulta Cliente")
		Return
	EndIf
Else
	If !Empty(SA1->A1_CODANT)

	    If lRmtCons
 			SA1->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))
			/*
			If !SA1->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))
				MsgAlert("Esse cliente não possui dados históricos", "Consulta Cliente")
			EndIf
			*/
 		Else
		   If SA1->(DbSeek(SA1->A1_FILANT+SA1->A1_CODANT+SA1->A1_LOJA))
			cFilAnt		:=	SA1->A1_FILIAL
		   Else
		   		MsgAlert("Esse cliente não possui dados históricos", "Consulta Cliente")
		   		Return
		   EndIf
		EndIf

		If Pergunte("FIC010",.T.)
		Fc010Con()
	    EndIf

	Else

		If SA1->(DbSeek(xFilial("SA1")+SA1->A1_COD + SA1->A1_LOJA))
			If Pergunte("FIC010",.T.)
			    Fc010Con()
		    EndIf
	    EndIf
	EndIf
EndIf
cFilAnt	:= cSavFil

RestArea(aArea)
//dbSelectArea("SA1")
//dbSetOrder(1)
//dbSeek(xFilial()+SA1->A1_COD+SA1->A1_LOJA)
If lRmtCons
	oDBInteg:Finish()
Endif


Return

/*/{Protheus.doc} PrzValor
Funcao de calculo do prazo medio x valor do vendedor.
@author F?io S. dos Santos
@since 18/09/08
@version P11
@uso Fusus - Shell
@param cVend, characters
@type function
/*/
User Function PrzValor(cVend)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis        											    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Local aArea			:= GetArea()
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local nReturn		:= 0.00
Local nX			:= 0
Local cCodShell		:= GetMv("MV_CODSHEL")
Local nTotPrc		:= 0
Local lTemProd		:= .F.
Local lItemLub		:= .F.
Local cPedido		:= Iif(FunName()=="MATA410",M->C5_NUM,SC5->C5_NUM)
Local nPProduto  	:= 0
Local nPQtdVen   	:= 0
Local lCols			:=  ( Type("aCols") <> "U" ) .AND. ( Type("aHeader") <> "U" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o volume total        											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(FunName())$"MATA440|MATA450" .OR. ( lCols .AND. Len(aCols) == 0 )
	cPedido		:= SC5->C5_NUM
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(xFilial("SC6")+cPedido)
	While !EOF() .And. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+cPedido
		If Alltrim(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PROC")) $ Alltrim(cCodShell)
			nTotPrc 	+= SC6->C6_VALOR
			lTemProd	:= .T.
			lItemLub	:= .T.
		Else
			lTemProd	:= .T.
			nTotPrc 	+= SC6->C6_VALOR
		EndIf
		DbSelectArea("SC6")
		DbSkip()
	Enddo
Else
	If lCols
		nPProduto  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
		nPTotVen   	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o valor total        											    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aCols)
			If Alltrim(Posicione("SB1",1,xFilial("SB1")+aCols[nX,nPProduto],"B1_PROC")) $ Alltrim(cCodShell)//verifica se o produto é lubrificante
				nTotPrc 	+= aCols[nX,nPTotVen]
				lTemProd	:= .T.
				lItemLub	:= .T.
			Else
				lTemProd	:= .T.
				nTotPrc 	+= aCols[nX,nPTotVen]
			EndIf
		Next nX
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o prazo medio         											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotPrc == 0.00 .and. lTemProd == .F.
	nReturn	:= 99999
ElseIf nTotPrc == 0.00 .and. lTemProd == .T.
	nReturn := 0.00
Else
	If lItemLub//considerar a tabela normal de lubricantes, caso no pedido tenha no mínimo um item lubrificante
		DbSelectArea("PA7")
		DbSetOrder(1)
		DbSeek(xFilial("PA7")+cVend)
		While !EOF() .and. PA7->PA7_FILIAL+PA7->PA7_VEND == xFilial("PA7")+cVend
		    If PA7->PA7_PRCINI <= nTotPrc .and. PA7->PA7_PRCATE >= nTotPrc
		    	nReturn := PA7->PA7_PRAZO
				Exit
			Endif
			DbSelectArea("PA7")
			DbSkip()
		Enddo
	Else
		DbSelectArea("PA9")
		DbSetOrder(1)
		DbSeek(xFilial("PA9")+cVend)
		While !EOF() .and. PA9->PA9_FILIAL+PA9->PA9_VEND == xFilial("PA9")+cVend
		    If PA9->PA9_PRCINI <= nTotPrc .and. PA9->PA9_PRCATE >= nTotPrc
		    	nReturn := PA9->PA9_PRAZO
				Exit
			Endif
			DbSelectArea("PA9")
			DbSkip()
		Enddo
	EndIf
Endif
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)
Return(nReturn)

/*/{Protheus.doc} AcresFin
Funcao de calculo do pre? de lista multiplicado pelo
acr?cimo financeiro do pedido
@author F?io S. dos Santos
@since 18/09/08
@version P11
@uso Fusus - Shell
@type function
/*/
User Function AcresFin()
Local nPrecoFin		:= 0
Local nPosPrcList	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCLIST"})
Local nPosProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPosValor	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPosTLiq	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TOTLIQ"})
Local nPosTItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TOTITEM"})
Local nPreco		:= 0
Local nQtVen		:= 0
Local i				:= 0
Local lAtuFaixa		:= SuperGetMv("ES_ATUFAIX",.F.,.F.)
//nPrecoFin	:= aCols[n][nPosPrcList] * (M->C5_X_ACRES/100 + 1)
If M->C5_TIPO == 'N'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A linha abaixo foi comentada devido a customizacao "Tabela Cruzada". Funcao "AtuFaixa()"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//MaTabPrVen(M->C5_TABELA,aCols[n][nPosProduto],aCols[n][nPosQtdVen],M->C5_CLIENTE,M->C5_LOJACLI,1,dDataBase,1,,)//retorna o preço de venda

	IF !lAtuFaixa
		// a Linha foi reativada caso nao seja utilizada faixa no distribuidor, caso contrario continua com o que foi feito anteriormente.
	   	IF SB1->B1_TIPO == "SH"
		   nPrcVen := MaTabPrVen(M->C5_TABELA,aCols[n][nPosProduto],aCols[n][nPosQtdVen],M->C5_CLIENTE,M->C5_LOJACLI,1,dDataBase,1,,)//retorna o preço de venda
		Else
			nPrcVen := MaTabPrVen(ACY->ACY_TABAGR,aCols[n][nPosProduto],aCols[n][nPosQtdVen],M->C5_CLIENTE,M->C5_LOJACLI,1,dDataBase,1,,)
		EndIf
	Else
		nPrcVen := GDFieldGet("C6_PRCVEN",n)
	EndIf
	aCols[n][nPosPrcList]	:= Round(nPrcVen * (M->C5_X_ACRES/100 + 1),2)

	For i:= 1 To Len(aHeader)
		If Trim(aHeader[i][2]) == "C6_PRCVEN"
			aCols[n][i]	:=Round(aCols[n][nPosPrcList],2)
			nPreco		:=Round(aCols[n][nPosPrcList],2)
		ElseIf Trim(aHeader[i][2]) == "C6_QTDVEN"
	 		nQtVen:=aCols[n][i]
		Endif
	Next i

	For i:=1 To Len(aHeader)
		If Trim(aHeader[i][2]) == "C6_VALOR"
			aCols[n][nPosValor] := nPreco * nQtVen
		ElseIf Trim(aHeader[i][2]) == "C6_TOTLIQ"
			aCols[n][nPosTLiq] := nPreco * nQtVen
		ElseIf Trim(aHeader[i][2]) == "C6_TOTITEM"
			aCols[n][nPosTItem] := nPreco * nQtVen
		Endif
	Next i
EndIf
Return (.T.)
//Return(nPrecoFin)

/*/{Protheus.doc} Combo
Funcao de montagem de combo no item do pedido.
Essa função ?chamada pela x3_vlduser do campo C6_QTDVEN.
@author F?io S. dos Santos
@since 23/10/08
@version P11
@uso Fusus - Shell
@type function
/*/
User Function Combo()
Local aArea			:= GetArea()
Local aAreaSG1 		:= SG1->(GetArea())
Local nX				:= n
Local aEstrut		:= {}
Local aValEstrut 	:= {}
Local nDif 			:= 0
Local lCorrigi 		:= .F.
Local nPProduto		:= 0
Local nPTES			:= 0
Local nPQtdVen  	:= 0
Local nPPrcVen  	:= 0
Local nPItem    		:= 0
Local nPTotal   	:= 0
Local nPDescont 	:= 0
Local nPVDesc		:= 0
Local nPvAcre		:= 0
Local nPosTLiq 		:= 0
Local nPosTItem		:= 0
Local nPosICom		:= 0
Local nPosCodPai	:= 0
Local lSemCombo		:= .F.
Local nUltItem		:= 0
Local nQtdItem		:= 0
Local cProdPai		:= ""
Local nY        		:= 0
Local nZ        		:= 0
Local nEst        	:= 0
Local nDesc        	:= 0
Local nItens    		:= 0
Local nEstrut   	:= 0
Local cTesAgrImp	:= GetNewPar("ES_TESIMPOS","711")
Local cTesAgr		:= GetNewPar("ES_TESAGREG","734")
Local cTesLub		:= GetNewPar("ES_TESLUB","510")
Local lCombAcr		:= GetNewPar("FS_COMBACR",.F.)
Local cCodShell		:= GetMv("MV_CODSHELL")
Local cItem     		:= ""
Local cItemOrig		:= ""
Local nCntFor   	:= ""
Local nTotFilho		:= 0
Local nQtdeFilho	:= 0
Local nValor			:= 0
Local _nValUnit		:= 0
Local lTMK			:= .F.
Local cAliasAux   	:= ""
Local cCpoAux		:= ""
Local nLinPai		:= 0
Local nLinIniFilho	:= 0
Local nLinFimFilho	:= 0
Local i				:= 0
Local nSaveLin		:= N
Local nAcres  		:= 0
Local nSeq			:= 0 //Chamado TPPTRK
Local nContSeq		:= 0 //Chamado TPPTRK
Local nTotFilhoDoa	:= 0 //Chamado TQHTOJ

If	Type("aLog") <> "A"
	Private aLog	:={}
EndIf

// Quando importação do segundo combo está vindo uma linha do aCols vazia, neste caso retiramos está linha
If Valtype(aTail( aCols[Len(aCols)] ) ) == "U"
	aSize(aCols, Len(aCols)- 1)
EndIf

If IsInCallStack("MATA410") .or. IsInCallStack("FATA400") //Pedido de Vendas, ou Contrato de Parceria
	nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	nPTES		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
	nPCF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CF"})
	nPQtdVen  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	nPPrcVen  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
	nPItem    	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
	nPTotal   	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
	nPDescont	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_DESCONT"})
	nPVDesc	    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALDESC"})
	nPosTLiq	:= aScan(aHeader,{|x| AllTrim(x[2])	== "C6_TOTLIQ"})
	nPosTItem	:= aScan(aHeader,{|x| AllTrim(x[2])	== "C6_TOTITEM"})
	nPosICom	:= aScan(aHeader,{|x| AllTrim(x[2])	== "C6_COMBO"})
	nPosCodPai	:= aScan(aHeader,{|x| AllTrim(x[2])	== "C6_CODPAI"})
	nPosDtEnt   := aScan(aHeader,{|x| AllTrim(x[2])	== "C6_ENTREG"})// @ticket 1703973 - 416176 – Odair Faria - Adicionado conforme solicitação do cliente Max Ivan
	cProdPai	:= aCols[nX][nPProduto]

//@ticket 235070 - T08957 – Ricardo Munhoz - Adicionado a rotina TK271CALLCENTER e tratando a variável nX.
ElseIf IsInCallStack("TMKA271").Or. IsInCallStack("TMKA380") .Or. IsInCallStack("TK271CALLCENTER") //Chamada pela Rotina de Televendas
	If nX == 0
		If n < 1
			nX := 1
		Else
			nX := n
		EndIf
	EndIf
//235070

	lTMK 		:= .T.
	nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_PRODUTO"})
	nPTES		:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_TES"})
	nPCF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_CF"})
	nPQtdVen  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_QUANT"})
	nPPrcVen  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT"})
	nPItem    	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_ITEM"})
	nPTotal   	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VLRITEM"})
	nPVDesc	    := aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VALDESC"})
	nPvAcre	    := aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VALACRE"})
	nPosDtEnt   := aScan(aHeader,{|x| AllTrim(x[2])	== "UB_DTENTRE"})// @ticket 1703973 - 416176 – Odair Faria - Adicionado conforme solicitação do cliente Max Ivan
	cProdPai	:= aCols[nX][nPProduto]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(1)
DbSeek(xFilial("SB1")+aCols[nX][nPProduto])

DbSelectArea("SG1")
DbSetOrder(1)

If FindFunction("U_CHKCOMBO").AND. U_CHKCOMBO() .AND. SB1->B1_TIPO == "SH"

	If DbSeek(xFilial("SG1")+aCols[n][nPProduto])
		If  SG1->G1_COD == aCols[n][nPProduto]
			aCols[n][Len(aHeader)+1] := .T.	// Deleta linha do produto pai, exibe a linha como deletada, para melhor visualização no momento do cadastro
			//M->C5_QTDPAI += aCols[n][nPQtdVen]
		Else
			aCols[n][Len(aHeader)+1] := .F.
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os produtos do primeiro nível da estrutura  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SG1")
		dbSetOrder(1)
		MsSeek(xFilial("SG1")+aCols[n][nPProduto])
		While !Eof() .And. xFilial("SG1") == SG1->G1_FILIAL .And. aCols[n][nPProduto] == SG1->G1_COD
			If lTMK
				If !lTk271Auto
					oGetTLV:CDELOK := "U_SHELLDELIN()"
    			EndIf
			Else
				If Type("l410Auto") == "U" .or. !l410Auto
					oGetDad:CDELOK := "U_SHELLDELIN()"
    			EndIf
    		Endif

			dbSelectArea("SB1")
			dbSetOrder(1)
			MsSeek(xFilial("SB1")+aCols[n][nPProduto])
			If SB1->B1_FANTASM<>"S"
				aValEstrut := ExplEstrut(aCols[n][nPQtdVen],dDataBase,"",SB1->B1_REVATU,,"")
				aadd(aEstrut,{SG1->G1_COMP,aValEstrut[1],aValEstrut[2],aValEstrut[3],SB1->B1_DESC,SG1->G1_TRT})
			EndIf
			dbSelectArea("SG1")
			dbSkip()
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona os produtos no aCols                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cItemOrig	:= aCols[n][nPItem]

		//Limpa as Variaveis
		cAliasAux	:= ""
		cCpoAux 	:= ""

		If lTMK
			cAliasAux	:= "SUB"
			cCpoAux 	:= "M->UB_CODPAI"
		Else
			cAliasAux	:= "SC6"
			cCpoAux 	:= "M->C6_CODPAI"
		Endif

		nLinPai		:= n
		nLinIniFilho	:= Len(aCOLS)+1
		nLinFimFilho	:= (nLinIniFilho + Len(aEstrut)-1)

		For nZ := 1 To Len(aEstrut)
			cItem := aCols[Len(aCols)][nPItem]
			aadd(aCOLS,Array(Len(aHeader)+1))
			For nY	:= 1 To Len(aHeader)
				If (cAliasAux)->(FieldPos(AllTrim(aHeader[nY][2]))) > 0
					If ( AllTrim(aHeader[nY][2]) == Iif(lTMK,"UB_ITEM","C6_ITEM") )
				 		aCols[Len(aCols)][nY] := Soma1(cItem)
			 	  	ElseIf ( AllTrim(aHeader[nY][2]) == Iif(lTMK,"UB_COMBO","C6_COMBO") )
			   			aCols[Len(aCols)][nY]	:= cItemOrig
			   		ElseIf ( AllTrim(aHeader[nY][2]) == Iif(lTMK,"UB_CODPAI","C6_CODPAI") )
			   			aCols[Len(aCols)][nY]	:= aCols[nLinPai,nPProduto]
			   			&(cCpoAux) := aCols[1,nPProduto]
			        ElseIf ( AllTrim(aHeader[nY][2]) == Iif(lTMK,"UB_QTDPAI","C6_QTDPAI") )
			   			aCols[Len(aCols)][nY]  := aCols[nLinPai,nPQtdVen]
                    // @ticket 1703973 - 416176 – Odair Faria - Adicionado conforme solicitação do cliente Max Ivan
			   		ElseIf ( AllTrim(aHeader[nY][2]) == Iif(lTMK,"UB_DTENTRE","C6_ENTREG") )
			   			aCols[Len(aCols)][nY]	:= aCols[nLinPai,nPosDtEnt]
                    //1703973 
					Else
				 		aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
					EndIf
				EndIf
			Next nY
		 	N  := Len(aCols)
			nX := N
			aCOLS[N][Len(aHeader)+1] :=  .F.

			If lTMK //Televendas
				aCols[nX][nPProduto] := aEstrut[nZ][1]
				M->UB_PRODUTO := aCols[nX][nPProduto]
				TK273Calcula("UB_PRODUTO", N, .F.)
				N := nX
				MaFisRef("IT_PRODUTO","TK273", aCols[nX][nPProduto] )
				If ExistTrigger("UB_PRODUTO")
					RunTrigger(2,N,Nil,,"UB_PRODUTO")
				Endif

				aCols[N][nPQtdVen] := aEstrut[nZ][2]
				M->UB_QUANT := aCols[N][nPQtdVen]
				Tk273Calcula("UB_QUANT", N, .F.)
				N := nX
				If ExistTrigger("UB_QUANT")
					RunTrigger(2,N,Nil,,"UB_QUANT")
				Endif

				aCols[N][nPPrcVen] := aEstrut[nZ][3]
				M->UB_VRUNIT := aCols[N][nPPrcVen]
				TK273Calcula("UB_VRUNIT", N, .F.)
				N := nX
				If ExistTrigger("UB_VRUNIT")
					RunTrigger(2,N,Nil,,"UB_VRUNIT")
				Endif

				aCols[N][nPTotal] := aEstrut[nZ][4]
				M->UB_VLRITEM := aCols[N][nPTotal]
				MaFisRef("IT_VALMERC","TK273",aCols[N][nPTotal])
				If ExistTrigger("UB_VLRITEM")
					RunTrigger(2,N,Nil,,"UB_VLRITEM")
				Endif

				If Empty(aCols[N][nPTotal]) .Or. Empty(aCols[N][nPTES])
					aCOLS[N][Len(aHeader)+1] := .T.
				EndIf
			Else //Pedido de Vendas
				A410Produto(aEstrut[nZ][1],.F.)
				aCols[N][nPProduto]      := aEstrut[nZ][1]
				A410MultT("M->C6_PRODUTO",aEstrut[nZ][1])
				If ExistTrigger("C6_PRODUTO")
					RunTrigger(2,N,Nil,,"C6_PRODUTO")
				Endif

				A410SegUm(.T.)
				A410MultT("M->C6_QTDVEN",aEstrut[nZ][2])
				If ExistTrigger("C6_QTDVEN ")
					RunTrigger(2,N,Nil,,"C6_QTDVEN ")
				Endif

				If Type("l410Auto") # "U" .and. l410Auto
					aCols[n,nPDescont]	:= 0
					aCols[n,nPVDesc]	:= 0
				EndIf

				aCols[N][nPPrcVen] := aEstrut[nZ][3]
				A410MultT("M->C6_PRCVEN",aEstrut[nZ][3])
				If ExistTrigger("C6_PRCVEN")
					RunTrigger(2,N,Nil,,"C6_PRCVEN")
				Endif

				aCols[N][nPTotal] := aEstrut[nZ][4]
				A410MultT("M->C6_TOTAL",aEstrut[nZ][4])
				If ExistTrigger("C6_TOTAL")
					RunTrigger(2,N,Nil,,"C6_TOTAL")
				Endif

				If aCols[N][nPTes] <> aCols[nZ][nPTes]
				   dbSelectArea("SF4")
				   dBSetOrder(1)
				   MsSeek(xFilial("SF4")+SB1->B1_TS)
				   aCols[N][nPTes] := SF4->F4_CODIGO
				   aCols[N][nPCF] := SF4->F4_CF
				EndIf
				If Empty(aCols[N][nPTotal]) .Or. Empty(aCols[N][nPTES])
					aCOLS[N][Len(aHeader)+1] := .T.
				EndIf

				aCols[N][nPosTLiq]	:= aEstrut[nZ][4]
				aCols[N][nPosTItem]	:= aEstrut[nZ][4]

				U_K410Margem()
			Endif
		Next nZ
	Else
	 	Return (.T.)
	EndIf
Else
	Return (.T.)
EndIf

nX	:= nLinIniFilho
For nEstrut:= 1 To Len(aEstrut)
	nTotFilho += aCOLS[nX][nPTotal]
	nQtdeFilho++
	For nItens:=1 To Len(aHeader)
		If ( AllTrim(aHeader[nItens][2]) == Iif(lTMK,"UB_TES","C6_TES") )
		    // Chamado TPPGTB - Verificação de Codigo Pai + Produto + Sequencia
			For nContSeq := 1 to Len(aEstrut)
				If Empty(aEstrut[nContSeq,6]) .Or. AllTrim(aEstrut[nContSeq,6]) == '01'
					nSeq := 2      //  G1_FILIAL + G1_COMP + G1_COD
				Else
					nSeq := 1      //  G1_FILIAL + G1_COD + G1_COMP + G1_TRT
					Exit          // Chamado TPZWNV - Quando verificado que o combo possui item de doação (sequencia) sair do FOR.
				EndIF
			Next nContSeq

			DbSelectArea("SG1")
			DbSetOrder(nSeq)

			If DbSeek( xFilial("SG1")+;
			      IIf( nSeq==1, cProdPai, aEstrut[nEstrut,1] )+;
			      IIf( nSeq==1, aEstrut[nEstrut,1], cProdPai )+;
			      IIf( nSeq==1, aEstrut[nEstrut,6], '' ))
			// Chamado TPPGTB - Fim alteração
				If SG1->G1_TES == "S"  .OR.  SG1->G1_DOACAO == "S"    // Chamado TPZWNV - Adicionar validação do campo G1_DOACAO

					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+aEstrut[nEstrut][1])
					If SB1->B1_PROC $ cCodShell
						aCols[nX][nItens]	:= cTesLub

						//Chamado TQHTOJ - Desconsiderar valores de itens de doação do cálculo de diferença e arredondamento
						nQtdeFilho := nQtdeFilho - 1
						nTotFilho := nTotFilho - aCOLS[nX][nPTotal]
						nTotFilhoDoa := nTotFilhoDoa + aCOLS[nX][nPTotal]
						// Fim alteração

						//Chamado TPNBBU - Codigo Fiscal não estava respeitando a TES, quando selecionada do parametro ES_TESLUB
						DbSelectArea("SF4")
						DbSetOrder(1)
						SF4->(DbSeek(xFilial('SF4')+cTesLub))
						   aCols[nX][nPCF]	:= SF4->F4_CF
						SF4->(DbCloseArea())
						//Fim da alteração - Chamado TPNBBU
					Else
						//Chamado TPYQPK - Codigo Fiscal não estava respeitando a TES, quando selecionada do parametro ES_TESLUB
						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+SB1->B1_TS)
						If SF4->F4_ICM == "S"
							aCols[nX][nItens]	:= cTesAgrImp
						Else
							aCols[nX][nItens]	:= cTesAgr
						EndIf

					    DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+SB1->B1_TS)
						If SF4->F4_ICM == "S"
							aCols[nX][nItens]	:= cTesAgrImp
							DbSelectArea("SF4")
							DbSetOrder(1)
							SF4->(DbSeek(xFilial('SF4')+cTesAgrImp))
						   aCols[nX][nPCF]	:= SF4->F4_CF
							SF4->(DbCloseArea())

						Else
							aCols[nX][nItens]	:= cTesAgr
							DbSelectArea("SF4")
							DbSetOrder(1)
							SF4->(DbSeek(xFilial('SF4')+cTesAgr))
							   aCols[nX][nPCF]	:= SF4->F4_CF
							SF4->(DbCloseArea())
							//Fim da alteração - Chamado TPYQPK

						EndIf

					EndIf
				EndIf
			EndIf
		EndIf
	Next nItens
	nX++
Next nEstrut
//+-------------------------------------------------------------------+
//| Conforme MAN00000240101_EF_001 caso os valores estejam diferentes |
//| Solicita a confirmacao do usuario para continuar o ajuste         |
//+-------------------------------------------------------------------+
//| Rodrigo Guerato - Data: 04/09/2013                                |
//+-------------------------------------------------------------------+
DbSelectArea("SE4")
DbSetOrder(1)
 If lTMK
	DbSeek(xFilial("SE4")+M->UA_CONDPG,.F.)
    nAcres := Round(aCols[nLinPai][nPTotal] * (SE4->E4_X_ACRES/100 + 1),2) - aCols[nLinPai][nPTotal]
  Else
    DbSeek(xFilial("SE4")+M->C5_CONDPAG,.F.)
   nAcres := Round(aCols[nLinPai][nPTotal] * (SE4->E4_X_ACRES/100 + 1),2) - aCols[nLinPai][nPTotal]
 EndIf


  If nTotFilho + nTotFilhoDoa <> aCols[nLinPai][nPTotal]+ nAcres
	If nTotFilho + nTotFilhoDoa > aCols[nLinPai][nPTotal]
		nDif := nTotFilho + nTotFilhoDoa - aCols[nLinPai][nPTotal]
	ElseIf nTotFilho + nTotFilhoDoa < aCols[nLinPai][nPTotal]
		If nSeq == 1
   			nDif := NoRound((nTotFilho + nTotFilhoDoa ) * 0.03,2)
		Else
			nDif := aCols[nLinPai][nPTotal] - nTotFilho - nTotFilhoDoa
		EndIf
	Else
		nDif := (aCols[nLinPai][nPTotal] + nAcres) - nTotFilho - nTotFilhoDoa
	EndIf

    _cMensSoma  := AllTrim(SuperGetMv("MV_ZZMENSO",.F.,"P"))
    If _cMensSoma == "S"
       lCorrigi := .T.
    ElseIf _cMensSoma == "N"
       lCorrigi := .F.
    Else
       lCorrigi := MsgYesNo("O somatório dos produtos filhos esta diferente do informado no produto Pai. Ajustar??" + CLRF + ;
							"Informado: " + Transform(nTotFilho + nDif + nTotFilhoDoa,"@E 999,999,999.99") + CLRF + ;
							"Calculado: " + Transform(nTotFilho + nTotFilhoDoa,"@E 999,999,999.99") + CLRF + ;
							"Acréscimo: " + Transform(nDif,"@E 999,999,999.99","Considera Acréscimo") + CLRF )
							//"Diferença: " + Transform(nDif,"@E 999,999,999.99"),"Ajuste de Valores")
	EndIf
  EndIf


   //If IsInCallStack("SHEA301I") - Chamado TQHTOJ
   //  lCorrigi := .T.
   //EndIf

   // Chamado TQGFTQ -  Em rotina via Job, verifica se terá acrescimo no pedido de venda.
   If lCombAcr
     lCorrigi := .T.
   EndIf

 If lCorrigi
	//Regra de arredondamento (a diferença entre a soma dos filhos e o pai será divida entre os filhos)
	//Alterado em 29/07/2011 por Abramo para calcular no valor unitário além do valor total
	//Alterado em 29/09/2011 por Adriano para os calculos de arredondamento para mais de um combo inserido - variavel aplicada -> val(cItemOrig)
	If (nTotFilho + nTotFilhoDoa) > aCOLS[nLinPai][nPTotal]
		//Recalc valores unitarios e totais

		//Chamado TQHTOJ - Alterado para que o combo não faça acréscimo de pagamento ao item de doação.
		//If nSeq == 1
		//	nLinFimFilho := nLinFimFilho - 1
		//End


		For nEstrut := nLinIniFilho To nLinFimFilho
			_nValUnit := aCOLS[nEstrut][nPTotal] / acols[nEstrut][nPQtdVen]
			aCOLS[nEstrut][nPPrcVen]:= _nValUnit
			aCOLS[nEstrut][nPTotal]:= NoRound(_nValUnit * acols[nEstrut][nPQtdVen],2)
		Next nEstrut



		nTotFilho := nTotFilho + nTotFilhoDoa - aCOLS[nLinPai][nPTotal]
		nDiferenca := NoRound(nTotFilho/nQtdeFilho,2)

		For nEstrut:= nLinIniFilho To nLinFimFilho
			if aCols[nEstrut][nPTES] <> cTesLub //Verificação de doação - Chamado TQHTOJ
				aCOLS[nEstrut][nPPrcVen]:= NoRound(aCOLS[nEstrut][nPPrcVen] - (nDiferenca / acols[nEstrut][nPQtdVen]) ,2)
				aCOLS[nEstrut][nPTotal] := aCols[nEstrut][nPQtdVen] * aCols[nEstrut][nPPrcVen]
				aCOLS[nEstrut][nPVDesc] := nDiferenca
				nValor := NoRound(nValor + aCOLS[nEstrut][nPTotal],2)
			Endif
	  	Next nEstrut

	  	If nValor > aCOLS[nLinPai][nPTotal] .And. nSeq == 2 //Se houver diferença de centavos, joga no ultimo filho

			if aCols[nEstrut][nPTES] <> cTesLub //Verificação de doação - Chamado TQHTOJ
		  		nDiferenca := nValor - aCOLS[nLinPai][nPTotal]
		  		lArred:= .T.
		  		nTotDif 	:= aCOLS[ nLinFimFilho ][nPTotal]
			  	nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
			  	nDifMult	:= (aCOLS[nLinFimFilho][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho ][nPQtdven]
			Else
				nDiferenca := nValor - aCOLS[nLinPai][nPTotal]
		  		lArred:= .T.
		  		nTotDif 	:= aCOLS[ nLinFimFilho - 1 ][nPTotal]
			  	nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
			  	nDifMult	:= (aCOLS[nLinFimFilho - 1][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho - 1][nPQtdven]
			Endif

		  	While lArred
		  		If nDifMult < nTotDif
			  		if aCols[nLinFimFilho][nPTES] <> cTesLub //Verificação de doação - Chamado TQHTOJ
						nTotDif 	:= aCOLS[ nLinFimFilho ][nPTotal]
						nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
						nDifMult	:= (aCOLS[ nLinFimFilho ][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho ] + nDiferenca
					Else
						nTotDif 	:= aCOLS[ nLinFimFilho - 1 ][nPTotal]
						nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
						nDifMult	:= (aCOLS[ nLinFimFilho -1 ][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho - 1 ] + nDiferenca
					Endif
		       Else
			  		if aCols[nLinFimFilho][nPTES] <> cTesLub //Verificação de doação - Chamado TQHTOJ
						nTotDif 	:= nTotDif + nDiferenca
						nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
						nDifMult	:= (aCOLS[ nLinFimFilho ][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho ][nPQtdven]
					Else
						nTotDif 	:= nTotDif + nDiferenca
						nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
						nDifMult	:= (aCOLS[ nLinFimFilho - 1 ][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho -1 ][nPQtdven]
					Endif
		  		EndIf
	  		    If nDifMult == nTotDif
	  		    	lArred := .F.
	  		    	Exit
	  		    Endif
	  			nDiferenca:= NoROund(nDiferenca,2)
	  		EndDo

	  		if aCols[nLinFimFilho][nPTES] <> cTesLub //Verificação de doação - Chamado TQHTOJ
		  		aCOLS[ nLinFimFilho ][nPVDesc]+= nDiferenca
		  	  	aCOLS[ nLinFimFilho ][nPTotal]+= nDiferenca
		  	 	nDiferenca *= Round(nDiferenca / nDifporQtd,2)
		  	 	aCOLS[ nLinFimFilho ][nPPrcVen] += nDiferenca
		  	 Else
				aCOLS[ nLinFimFilho-1 ][nPVDesc]+= nDiferenca
		  	  	aCOLS[ nLinFimFilho-1 ][nPTotal]+= nDiferenca
		  	 	nDiferenca *= Round(nDiferenca / nDifporQtd,2)
		  	 	aCOLS[ nLinFimFilho-1 ][nPPrcVen] += nDiferenca
		  	 Endif

		EndIf

	ElseIf (nTotFilho + nTotFilhoDoa) < aCOLS[nLinPai][nPTotal]

		//Recalc valores unitarios e totais

		//Chamado TQHTOJ - Alterado para que o combo não faça acréscimo de pagamento ao item de doação.
		//If nSeq == 1
		//	nLinFimFilho--
		//End

		For nEstrut := nLinIniFilho To nLinFimFilho
			_nValUnit := aCOLS[nEstrut][nPTotal] / acols[nEstrut][nPQtdVen]
			aCOLS[nEstrut][nPPrcVen]:= _nValUnit
			aCOLS[nEstrut][nPTotal]:= NoRound(_nValUnit * acols[nEstrut][nPQtdVen],2)
		Next nEstrut


	   	nTotFilho	:= aCOLS[nLinPai][nPTotal] - nTotFilho - nTotFilhoDoa
	   	nDiferenca	:= NoRound(nTotFilho/nQtdeFilho,2)

		For nEstrut:= nLinIniFilho To nLinFimFilho
			if aCols[nEstrut][nPTES] <> cTesLub //Verificação de doação - Chamado TQHTOJ
				aCOLS[nEstrut][nPPrcVen]	:= NoRound(aCOLS[nEstrut][nPPrcVen] + (nDiferenca / acols[nEstrut][nPQtdVen]) ,2)
				aCOLS[nEstrut][nPTotal] 	:= aCols[nEstrut][nPQtdVen] * aCols[nEstrut][nPPrcVen]
				nValor 						:= NoRound(nValor + aCOLS[nEstrut][nPTotal],2)
			endif
	    Next nEstrut



		If nValor < aCOLS[nLinPai][nPTotal] .And. nSeq == 2 //Se houver diferença de centavos, joga no ultimo filho

	  		nDiferenca := aCOLS[nLinPai][nPTotal] - nValor
	  		lArred:= .T.
  		    //Alteração efetuada para atendimento do chamado TFGUB1 - anteriormente a alteração a variavel nTotDif estourava conteudo
			if aCols[nLinFimFilho][nPTES] <> cTesLub
	  		    nTotDif 	:= aCOLS[ nLinFimFilho ][nPTotal]
		  		nDifporQtd	:= NoRound(nDiferenca / aCOLS[ nLinFimFilho ][nPQtdVen],2) //Aecio - nDifporQtd 	:= NoRound(nDiferenca / aCOLS[Len(aEstrut) + nLinPai][nPQtdVen],2)
		  		nDifMult	:= (aCOLS[ nLinFimFilho ][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho ][nPQtdVen]
		  		nDiferenca	:= nDifporQtd
		 	Else
				nTotDif 	:= aCOLS[ nLinFimFilho - 1 ][nPTotal]
		  		nDifporQtd	:= NoRound(nDiferenca / aCOLS[ nLinFimFilho -1  ][nPQtdVen],2) //Aecio - nDifporQtd 	:= NoRound(nDiferenca / aCOLS[Len(aEstrut) + nLinPai][nPQtdVen],2)
		  		nDifMult	:= (aCOLS[ nLinFimFilho -1 ][nPPrcVen] + nDifporQtd )* aCOLS[ nLinFimFilho - 1 ][nPQtdVen]
		  		nDiferenca	:= nDifporQtd
		 	Endif

			While lArred

	          	//Alteração efetuada para atendimento do chamado TFGUB1 - anteriormente a alteração a variavel nTotDif estourava conteudo
				If nDifMult < nTotDif
		  			if aCols[nLinFimFilho][nPTES] <> cTesLub
						nTotDif 	:= aCOLS[ nLinFimFilho ][nPTotal]
						nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
						nDifMult	:= (aCOLS[ nLinFimFilho ][nPPrcVen] + nDifporQtd )* aCols[nLinPai][nPQtdVen] + nDiferenca
					Else
						nTotDif 	:= aCOLS[ nLinFimFilho -1 ][nPTotal]
						nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
						nDifMult	:= (aCOLS[ nLinFimFilho -1 ][nPPrcVen] + nDifporQtd )* aCols[nLinPai][nPQtdVen] + nDiferenca
					Endif
				Else
		          nTotDif 	+= nDiferenca
		  	      nDifporQtd 	:= NoRound(nDiferenca / aCols[nLinPai][nPQtdVen],2)
		  		EndIf

	  		    If nDifMult == nTotDif
	  		    	lArred := .F.
	  		    	Exit
	  		    Endif
	  		EndDo


			if aCols[nLinFimFilho][nPTES] <> cTesLub //Verificação de doação - Chamado TQHTOJ
	  			aCOLS[ nLinFimFilho ][nPPrcVen] += nDiferenca
	  		 	aCOLS[ nLinFimFilho ][nPTotal]:= aCOLS[ nLinFimFilho ][nPPrcVen] * aCOLS[ nLinFimFilho ][nPQtdVen]
		  	Else
		  		aCOLS[ nLinFimFilho -1 ][nPPrcVen] += nDiferenca
		  	 	aCOLS[ nLinFimFilho -1 ][nPTotal]:= aCOLS[ nLinFimFilho -1 ][nPPrcVen] * aCOLS[ nLinFimFilho -1 ][nPQtdVen]
		  	Endif


		EndIf

	EndIf
Endif

//@ticket 235070 - T08957 – Ricardo Munhoz - Verifica a exitência da variável ACRESCIMO.
	If Type("ACRESCIMO") <> "U" .And. lTMK

		//Limpa o Acrescimo
		aValores[ACRESCIMO] := 0
		nX := N

		//Atualiza o Folder
		For nEstrut := 1 to Len(aCols)
			N := nEstrut
			TK273DelTlv(0,3)
			If lCorrigi == .F.
			  aValores[ACRESCIMO]:= 0
			EndIf
		Next nEstrut

		TK273Recalc( Len(aCols) ,.F.,.F. )
		N := nX
	Else
		// Rotina espefífica do distribuidor EURO calcula a margem no pedido de vendas.
		If ExistBlock("EUROCUS")
  			ExecBlock("EUROCUS",.F.,.F.)
		EndIf
	Endif



If lTMK
	If !lTk271Auto
		oGetTLV:oBrowse:Refresh()
	Endif
Else
	If Type("l410Auto") == "U" .or. !l410Auto
		oGetDad:OBROWSE:Refresh()
	EndIf
Endif

N := nSaveLin
RestArea(aAreaSG1)
RestArea(aArea)
Return(.T.)

/*/{Protheus.doc} SHELLDELIN
Controle de deleção de linha
@author F?io S. dos Santos
@since SHELLDELIN
@version P11
@uso Fusus - Shell
@type function
/*/
User Function SHELLDELIN()
	Local nCont 		:= 0
	Local lDel 		:= aCols[n][Len(aCols[1])]
	Local nPosProduto	:= 0
	Local nPosCombo	:= 0
	Local nPosItem		:= 0
	Local cProduto		:= ""
	Local cProdPai		:= ""
	Local cItem		:= ""
	Local nOrig		:= N
	Local lCombo   	:= .F.
	Local nX			:= 0

	If IsInCallStack("MATA410") .or. IsInCallStack("FATA400") //Pedido de Vendas, ou Contrato de Parceria
		nPosProduto 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
		nPosCombo		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_COMBO"})
		nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
		cProduto		:= aCols[n,nPosProduto]
	ElseIf IsInCallStack("TMKA271") //Televendas
		nPosProduto 	:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
		nPosCombo		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_COMBO"})
		nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_ITEM"})
		cProduto		:= aCols[n,nPosProduto]
	EndIf

	If Empty( aCols[N][nPosCombo] )
		SG1->( dbSetOrder(1) )
		If SG1->( dbSeek( xFilial("SG1") + cProduto ) )
			lCombo := .T.
			cItem  := aCols[N][nPosItem]
		Endif
	Else
		lCombo := .T.
		cItem  := aCols[N][nPosCombo]
	Endif

	If lCombo


		For nCont := 1 to Len(aCols)
			If aCols[nCont][nPosItem] == cItem
				aCols[nCont][Len(aCols[nCont])] := .T.
			Elseif aCols[nCont][nPosCombo] == cItem
				aCols[nCont][Len(aCols[nCont])] := lDel
			Endif
		Next nCont

		If IsInCallStack("TMKA271")
			For nX := 1 to Len( aValores )
				aValores[nX] := 0
			Next nX

			For nX := 1 to Len( aCols )
			 	N := nX
				//Executa a funcao de calculo
				TK273DelTlv(0,3)
				TK273Recalc( Len(aCols),.F.,.F. )
			Next
		Endif
	Endif

	N := nOrig

	If IsInCallStack("MATA410")
		If !l410Auto
			oGetDad:OBROWSE:Refresh() //Variavel Private
		EndIf
	ElseIf IsInCallStack("TMKA271")
		If !lTk271Auto
			oGetTLV:oBrowse:Refresh() //Variavel Private
		Endif
	EndIf

	SG1->(DbCloseArea())
Return .T.

/*/{Protheus.doc} ValidLin
Funcao de validação da linha pra deixar somente leitura.
Essa função ?colocada no x3_when de todos os campos SC6.
@author F?io S. dos Santos
@since 24/10/08
@version P11
@uso Fusus - Shell
@param aHeader, array
@param aCols, array
@param nX, numeric
@type function
/*/
User Function ValidLin(aHeader,aCols,nX)
	Local lRet	      := .T.
	Local nPosCombo := 0
	Local nPosQtVen := 0
	Local nPosProd	  := 0
	Local aArea		:= GetArea()

	If IsInCallStack("MATA410") .or. IsInCallStack("FATA400") //Pedido de Vendas, ou Contrato de Parceria
		nPosCombo := aScan(aHeader,{|x| AllTrim(x[2])=="C6_COMBO"})
		nPosQtVen := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
		nPosProd  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	ElseIf IsInCallStack("TMKA271") .or. IsInCallStack("TMKA380") .or. IsInCallStack("PesqTMK") //Televendas ou Agenda do Operador
		nPosCombo := aScan(aHeader,{|x| AllTrim(x[2])=="UB_COMBO"})
		nPosQtVen := aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"})
		nPosProd  := aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
	EndIf

	If !Empty(aCols[nX][nPosCombo])
		lRet	:= .F.
	EndIf

	//VALIDA SE FOR O PRODUTO COMBO, NÃO PODE ALTERAR A QUANTIDADE
	SG1->(dbSetOrder(1))
	IF aCols[nX][nPosQtVen] > 0 .AND. SG1->(dbSeek(xFilial("SG1")+aCols[nX][nPosProd]))
	    lRet	:= .F.
	ENDIF

RestArea(aArea)

Return lRet

/*/{Protheus.doc} VerifProd
Funcao de verificação do produto digitado. Caso j?tenha
algum produto no pedido com o mesmo c?igo, o sistema n?
deve permitir a inclus?.
@author F?io S. dos Santos
@since 24/10/08
@version P11
@uso Fusus - Shell
@type function
/*/
User Function VerifProd()
Local lRet			:= .T.
Local lCombo		:= .F.
Local nPosProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosCombo		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_COMBO"})
Local cProduto  	:= &(ReadVar())
Local nCont	    	:= 0
Local nCombo	    := 0
Local aCombo		:= {}
Local aArea			:= GetArea()

SG1->(DbSetOrder(1))
If SG1->(DbSeek(xFilial("SG1")+cProduto))
	While cProduto == SG1->G1_COD
		lCombo	:= .T.
		aAdd(aCombo,SG1->G1_COMP)
		SG1->(DbSkip())
	EndDo
EndIf
If Len(aCols) != 1
	For nCont:= 1 To Len(aCols)
    	If cProduto == aCols[nCont][nPosProduto] .And. Empty(aCols[n][nPosCombo])
    		MsgInfo("Digite outro produto ou altere o existente!","Inconsistência - Produto repetido!")
    		lRet	:= .F.
    		Exit
    	ElseIf lCombo
    		For nCombo:= 1 To Len(aCombo)
    			If (aCombo[nCombo] == &(ReadVar())) .Or. (aCombo[nCombo] == aCols[nCont+1][nPosProduto])
		    		MsgInfo("Digite outro produto ou altere o existente!","Inconsistência - Produto repetido!")
		    		lRet	:= .F.
		    		Exit
    			EndIf
    		Next nCombo
    		Exit
    	EndIf
	Next nCont
EndIf
RestArea(aArea)
Return lRet

/*/{Protheus.doc} ExplEstrut
Calcula a quantidade usada de um componente da estrutura
@author Eveli Morasco
@since 20/08/92
@version P11
@uso Generico
@param nQuant, numeric, Quantidade utilizada pelo componente
@param dDataStru, date, Data para validacao do componente na estrutura
@param cOpcionais, characters, String contendo os opcionais utilizados
@param cRevisao, characters, Revisao da estrutura utilizada
@param nMotivo, numeric, Variavel com valor numerico que justifica o motivo
                         pelo qual a quantidade esta zerada.
 1 - Componente fora das datas inicio / fim
 2 - Componente fora dos grupos de opcionais
 3 - Componente fora das revisoes
@type function
/*/
Static Function ExplEstrut(nQuant,dDataStru,cOpcionais,cRevisao,nMotivo)
LOCAL nQuantItem:=0,cUnidMod,nG1Quant:=0,nQBase:=0,nDecimal:=0,nBack:=0
Local nG1PrcVen := 0
Local nG1Total := 0
LOCAL aTamSX3:={}
LOCAL cAlias:=Alias(),nRecno:=Recno(),nOrder:=IndexOrd()
LOCAL lOk:=.T.
LOCAL nDecOrig:=Set(3,8)

DEFAULT nMotivo:=0

aTamSX3:=TamSX3("G1_QUANT")
nDecimal:=aTamSX3[2]

// Verifica os opcionais cadastrados na Estrutura
cOpcionais:= If((cOpcionais == NIL),"",cOpcionais)

// Verifica a Revisao Atual do Componente
cRevisao:= If((cRevisao == NIL),"",cRevisao)

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial()+SG1->G1_COD)
	If Empty(cOpcionais) .And. !Empty(B1_OPC)
		cOpcionais:=B1_OPC
	EndIf
	If Empty(cRevisao) .And. !Empty(B1_REVATU)
		cRevisao:=B1_REVATU
	EndIf
	If !Empty(cOpcionais) .And. !Empty(SG1->G1_GROPC+SG1->G1_OPC) .And. !(SG1->G1_GROPC+SG1->G1_OPC $  cOpcionais)
		nMotivo:=2  // Componente fora dos grupos de opcionais
		lOk:=.F.
	EndIf
	If lOk .And. !Empty(cRevisao) .And. (SG1->G1_REVINI > cRevisao .Or. SG1->G1_REVFIM < cRevisao)
		nMotivo:=3	// Componente fora das revisoes
		lOk:=.F.
	EndIf
EndIf
dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRecno)

// Verifica a data de validade
dDataStru := If((dDataStru == NIL),dDataBase,dDataStru)
If dDataStru >= SG1->G1_INI .And. dDataStru <= SG1->G1_FIM .And. lOk
   cUnidMod := GetMv("MV_UNIDMOD")
   dbSelectArea("SB1")
   dbSeek(xFilial()+SG1->G1_COD)
	nQBase := B1_QB
   dbSeek(xFilial()+SG1->G1_COMP)
   dbSelectArea("SG1")
   nG1Quant  := G1_QUANT
   nG1PrcVen := G1_XPVENDA
   If IsProdMod(G1_COMP)
      cTpHr := GetMv("MV_TPHR")
      If cTpHr == "N"
			nG1Quant := Int(nG1Quant)
         nG1Quant += ((G1_QUANT-nG1Quant)/60)*100
		EndIf
	EndIf
	/*
	If G1_FIXVAR $ " V"
		 If IsProdMod(G1_COMP) .And. cUnidMOD != "H"
			 nQuantItem := ((nQuant / nG1Quant) / (100 - G1_PERDA)) * 100
		 Else
			 nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
		 EndIf
		 nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
	Else
		 If IsProdMod(G1_COMP) .And. cUnidMOD != "H"
			 nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
		 Else
			 nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
		 EndIf
	Endif
	nQuantItem:=Round(nQuantitem,nDecimal)
	*/
	nQuantItem := (nQuant * nG1Quant) // Multiplica a quantidade digitada no Pai pelo valor definido no Cad. de Estrutura para os filhos
ElseIf lOk
	nMotivo:=1 // Componente fora das datas inicio / fim
EndIf
Do Case
	Case (SB1->B1_TIPODEC == "A")
		nBack := Round( nQuantItem,0 )
	Case (SB1->B1_TIPODEC == "I")
		nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
	Case (SB1->B1_TIPODEC == "T")
		nBack := Int( nQuantItem )
	OtherWise
		nBack := nQuantItem
EndCase

nG1Total := NoRound( nG1PrcVen * nBack, 2 )
Set(3,nDecOrig)
Return( {nBack, nG1PrcVen, nG1Total} )

/*/{Protheus.doc} ShDesc
copia o valor de venda para o campo preco de lista
para deixar os campos de desconto zerados
Funcao utilizada no campo C6_PRCVEN e C6_PRCFIM
esta devera ser sempre a ultima funcao da linha de validacao.
@author Joao Tavares S Junior
@since 08/12/09
@version P11
@uso AP
@type function
/*/
User Function ShDesc()

Local nPosPrUnit 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_PRUNIT"})
Local nPosDesc 		:= ascan(aheader,{|x| alltrim(x[2]) == "C6_DESCONT"})
Local nposValDesv 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_VALDESC"})
Local nPosPrcList 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_PRCLIST"})
Local nPosPrcVen 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_PRCVEN"})
Local nPosValodes 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_VALODES"})
Local nPosPerdes 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_PERDESC"})
Local nPosProd 		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nX				:= 0
Local lRet			:= .T.

IF GetNewPAr("ES_ZERADES",.F.)

	If !IsIncallStack("U_SHEA301I") .and. !IsIncallStack("U_SHEA301J")

		If lRet := U_VldDescPv(n) // Valida percentual de desconto maximo - FSW 01/08/2013
			If Acols[n,nPosPrcList] == 0
				Acols[n,nPosPrcList]	:= Acols[n,nPosPrUnit]
			EndIf

			IF Alltrim(READVAR()) == "M->C6_PRCVEN"
				Acols[n,nPosPrUnit]		:= &(READVAR())
			Else
				Acols[n,nPosPrUnit]		:= Acols[n,nPosPrcVen]
			EndIF

			IF	Acols[n,nPosDesc ] <> 0 .OR. Acols[n,nposValDesv] <> 0
				Acols[n,nPosPerdes ] := 	Acols[n,nPosDesc ]
				Acols[n,nPosValodes ] := Acols[n,nposValDesv]

				Acols[n,nPosDesc ]      := 0
				Acols[n,nposValDesv]    := 0
			EndIf

		EndIf
	Else
		For nX := 1 To Len(aCols)

			If lRet := U_VldDescPv(nX) // Valida percentual de desconto maximo - FSW 01/08/2013

				If Acols[nX,nPosPrcList] == 0
					Acols[nX,nPosPrcList]	:= Acols[nX,nPosPrUnit]
				EndIf

				Acols[nX,nPosPrUnit]		:= Acols[nX,nPosPrcVen]

				IF	Acols[nX,nPosDesc ] <> 0 .OR. Acols[nX,nposValDesv] <> 0
					Acols[nX,nPosPerdes ] := 	Acols[nX,nPosDesc ]
					Acols[nX,nPosValodes ] := 	Acols[nX,nposValDesv]
				EndIf

				Acols[nX,nPosDesc ]      := 0
				Acols[nX,nposValDesv]    := 0
			EndIf

			If !lRet
				Exit
			EndIf

		Next nX

	EndIf

EndIf

Return lRet

/*/{Protheus.doc} ShDelpr
copia o valor de preco lista para campo que fara o controle
dos calculos de desconto
Funcao utilizada nos campos C6_PRODUTO e C6_QTDVEN
esta devera ser sempre a ultima funcao da linha de validacao.
@author Joao Tavares S Junior
@since 08/12/09
@version P11
@uso AP
@type function
/*/
User Function ShDelpr()

Local nPosPrUnit 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_PRUNIT"})
Local nPosPrcList 	:= ascan(aheader,{|x| alltrim(x[2]) == "C6_PRCLIST"})
Local nPosQtd  		:= ascan(aheader,{|x| alltrim(x[2]) == "C6_QTDVEN"})

	IF Alltrim(READVAR()) == "M->C6_QTDVEN"
		If Acols[n,nPosQtd] <> &(READVAR())
			Acols[n,nPosPrcList] := Acols[n,nPosPrUnit]
        EndIf
	EndIf

Return .T.

/*/{Protheus.doc} VlMinPed
Controle de valor minimo do pedido de venda
Verifica se o valor total dos produtos que possuem saldo
em estoque eh maior ou igual ao valor minimo (definido via
parametro) para venda.
@author Marcos R. Pires
@since 06/04/11
@version P11
@uso Especifico Shell - Controle do valor minimo do pedido de venda
@type function
/*/
User Function VlMinPed()
Local LRet		:= .T.
Local nX		:= 0
Local nOpc		:= ParamIXB[1] //Operacao Ex: 3 - Inclusao; 4 - Alteracao; 5 - Exclusao
Local aSaveArea	:= GetArea()
Local nValorTot	:= 0 //Valor Total
Local nQtdDisp	:= 0 //Quantidade disponivel em estoque
Local nDifValor	:= 0 //Valor faltante para atingir o valor minimo
Local nValorMin := SuperGetMv("ES_VALMIN",.T.,0) //Valor minimo para geracao do pedido de venda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a rotina se for definido um valor maior que zero no parametro ES_VALMIN ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValorMin > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso seja inclusao ou alteracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 4

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem o valor total dos itens com base na disponibilidade em estoque ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aCols)

			If aCols[nX][Len(aHeader)+1] //Desconsidera linhas deletedas
				Loop
			EndIf

			/* Parametros da funcao SaldoSB2
			ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»
			ºVariavel      ³Tipo      ³Descricao                                                        ³Defaultº
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º lNecessidade ³ Logico   ³ Flag que indica se chamada da funcao ‚ utilizada p/				³ .F.	º
			º              ³          ³ calculo de necessidade. Caso .T. deve considerar quantidade		³  		º
			º              ³          ³ a distribuir, pois a mesma apenas nao pode ser utilizada,		³       º
			º              ³          ³ porem ja esta em estoque.           							³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º lEmpenho     ³ Logico   ³ Flag que indica se deve substrair o empenho do	saldo a ser		³ .T.	º
			º              ³          ³	retornado														³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º dDataFim     ³ Data     ³ Data final para filtragem de empenhos. Empenhos ate  			³       º
			º              ³          ³	esta data serao considerados no caso de leitura do SD4.			³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º lConsTerc    ³ Logico   ³ Flag que indica se deve considerar o saldo de terceiros     	³ .T.	º
			º              ³          ³ em nosso poder ou nao (B2_QTNP).								³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º lConsNPT     ³ Logico   ³ Flag que indica se deve considerar nosso saldo em        		³ .F.	º
			º              ³          ³	poder de terceiros ou nao (B2_QNPT).							³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º cAliasSB2    ³ Caracter ³ Alias			        										³ "SB2" º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º nQtdEmp      ³ Numerico ³ Qtd empenhada para esse movimento que nao deve ser      		³  0    º
			º              ³          ³	nao deve ser subtraida											³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º nQtdPrj      ³ Numerico ³  Qtd empenhada do Projeto para esse movimento que       		³  0    º
			º              ³          ³	nao deve ser subtraida 											³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º lSaldoSemR   ³ Logico   ³ Subtrai a Reserva do Saldo a ser Retornado?				     	³ .T.	º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º dDtRefSld    ³ Data     ³ Data limite para composicao do saldo MV_TPSALDO="C"        		³       º
			ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ¹
			º lConsEmpSA   ³ Logico   ³ Subtrai a Quantidade Prevista no SA a ser Retornado        		³  .T.	º
			º              ³          ³	Obs.: Somente funciona se o MV_TPSALDO for "C"					³       º
			ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍ¼
			*/

			SB2->(DbSetOrder(1))
			If	SB2->(MsSeek(xFilial("SB2")+GdFieldGet("C6_PRODUTO",nX)))

			    nQtdDisp := 0

				nQtdDisp := SaldoSB2(/*lNecessidade*/, /*lEmpenho*/, dDataBase, /*lConsTerc*/, /*lConsNPT*/, /*cAliasSB2*/,/*nQtdEmp*/, /*nQtdPrj*/, /*lSaldoSemR*/, /*dDtRefSld*/, /*lConsEmpSA*/)

				If nQtdDisp >= GdFieldGet("C6_QTDVEN",nX)
					nValorTot += GdFieldGet("C6_VALOR",nX)
				EndIf

			EndIf

		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compara o valor total dos itens com produtos disponiveis em estoque com o minimo permitido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValorTot < nValorMin
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o valor faltante para alcancar o minimo permitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDifValor	:= nValorMin - nValorTot
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para rotina automatica³
			//³Exibicao da mensagem ao usuario  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("l410Auto") == "U" .OR. !l410Auto
				lRet := MsgYesNo("O valor total dos produtos do pedido com disponibilidade em estoque é inferior "+;
								"ao minimo permitido, diferença de R$ " + AllTrim(TRANSFORM(nDifValor,"@E 999999,999,999.99"))+;
								". Deseja continuar?","Atenção")
			Else
				Conout("O valor total dos produtos do pedido com disponibilidade em estoque é inferior "+;
								"ao minimo permitido, diferença de R$ " + AllTrim(TRANSFORM(nDifValor,"@E 999999,999,999.99"))+;
								". Pedido: "+AllTrim(M->C5_NUM)+".")
			EndIf
		EndIf

	EndIf

EndIf

RestArea(aSaveArea)

Return(lRet)

/*/{Protheus.doc} AtuFaixa
Esta rotina tem como finalidade atualizar o valor dos pro-
dutos de acordo com a faixa com base na maior quantidade
a tabela utilizada para obtencao dos valores eh a DA1
@author Marcos R. Pires
@since 05/04/11
@version P11
@uso Especifico Shell - Tabela Cruzada
@type function
/*/
User Function AtuFaixa()
Local aSaveArea		:= GetArea()
Local lRet			:= .T.
Local nX			:= 0
Local nQtdProd		:= 0	//Armazena a quantidade do produto
Local cFaixaPrc		:= ""	//Armazena o cod da faixa de preco
Local cFxPrdProp	:= ""	//Armazena a maior faixa de preco do pedido dos produtos proprios
Local cFxPrdAgre	:= ""	//Armazena a maior faixa de preco do pedido dos produtos agregados
Local cFaixaMax		:= ""	//Armazena a maior faixa de preco
Local nPrcFaixa		:= 0	//Armazena o preco da faixa
Local nSaveLin		:= N	//Salva a posicao atual do aCols
Local cVldUsrQtd	:= ""	//Armazena as funcoes contidas no X3_VLDUSER do campo C6_QTDVEN
Local cVldUsrPrc	:= ""	//Armazena as funcoes contidas no X3_VLDUSER do campo C6_PRCVEN
Local lAtuFaixa		:= SuperGetMv("ES_ATUFAIX",.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a parametrizacao para execucao da ³
//³ atualizacao de faixa de preco dos itens    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAtuFaixa

	cVldUsrQtd	:= ShellVlUsr("C6_QTDVEN")
	cVldUsrPrc	:= ShellVlUsr("C6_PRCVEN")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa todos os itens do pedido de vendas ³
	//³ para identificar a maior faixa de preco    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aCols)

		If aCols[nX][Len(aHeader)+1] //Ignora linha deletada
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao para obter a quantidade do item em digitacao e dos demais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdProd := If(nX == N, M->C6_QTDVEN, GdFieldGet("C6_QTDVEN",nX))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem a faixa do pedido (campo especifico DA1_XFAIXA) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFaixaPrc := PesqFaixa(M->C5_TABELA,GdFieldGet("C6_PRODUTO",nX),nQtdProd,dDataBase)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o produto eh proprio ou agregado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ShellTpPrd(GdFieldGet("C6_PRODUTO",nX))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Produto Proprio ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Val(cFaixaPrc) > Val(cFxPrdProp)
				cFxPrdProp := cFaixaPrc
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Produto Agregado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Val(cFaixaPrc) > Val(cFxPrdAgre)
				cFxPrdAgre := cFaixaPrc
			EndIf
		EndIf

	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a faixa de preco de todos os itens com base na maior faixa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aCols)

		If aCols[nX][Len(aHeader)+1] //Ignora linha deletada
			Loop
		EndIf

		If !Empty(cFxPrdProp) .Or. !Empty(cFxPrdAgre)

			If ShellTpPrd(GdFieldGet("C6_PRODUTO",nX))
				cFaixaMax := cFxPrdProp //Maior faixa do produto proprio
			Else
				cFaixaMax := cFxPrdAgre //Maior faixa do produto agregado
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem o valor da faixa do preco ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPrcFaixa := PesqPrecFx(M->C5_TABELA,GdFieldGet("C6_PRODUTO",nX),cFaixaMax,dDataBase)

			If !Empty(nPrcFaixa)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os campos de cada item com base na faixa definida ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				GDFieldPut("C6_PRCVEN"	,nPrcFaixa	,nX) //Preco unitario
				GDFieldPut("C6_PRCLIST"	,nPrcFaixa	,nX) //Preco de lista
				GDFieldPut("C6_XFAIXA"	,cFaixaMax	,nX) //Codigo da faixa
				GDFieldPut("C6_PERDESC"	,0			,nX) //Percentual de desconto
				GDFieldPut("C6_VALODES"	,0			,nX) //Valor do desconto

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa as funcoes especificas contidas no X3_VDLUSER do campo C6_PRCVEN para os   ³
				//³ itens do aCols                                                                     ³
				//³ Obs: O tratamento abaixo eh efetuado para nao se alterar as rotinas jah validadas  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³                     !!!ATENCAO!!!                      ³
				//³ Atribui a variavel N a linha que esta sendo atualizada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				N := nX

				If nX == nSaveLin //Validacao para nao executar as funcoes de usuario na linha alterada duas vezes
					IIF(&(cVldUsrQtd),Nil,MsgAlert("Erro na atualização dos itens","Atenção")) //C6_QTDVEN - X3_VLDUSER
				EndIf

				IIF(&(cVldUsrPrc),Nil,MsgAlert("Erro na atualização dos itens","Atenção"))	//C6_PRCVEN - X3_VLDUSER

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³        !!!ATENCAO!!!        ³
				//³ Restaura a posicao do aCols ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				N := nSaveLin

			EndIf
		Else
			MsgAlert("Nao foi possivel localizar a maior faixa","Atenção")
		EndIf

	Next nX

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao esteja efetuando a regra da maior faixa limpa o campo ³
	//³ especifico da faixa para nao deixar registro sem coerencia     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GDFieldPos("C6_XFAIXA") > 0
		For nX := 1 To Len(aCols)
			GDFieldPut("C6_XFAIXA",CriaVar("C6_XFAIXA",.F.),nX)
		Next nX
	EndIf

EndIf

RestArea(aSaveArea)

Return(lRet)

/*/{Protheus.doc} PesqFaixa
Retorna o codigo especifico da faixa do preco(DA1_XFAIXA)
@author Marcos R. Pires
@since 08/04/11
@version P11
@uso Especifico Shell - Tabela Cruzada
@param cTabPreco, characters
@param cProduto, characters
@param nQtde, numeric
@param dDataVld, date
@type function
/*/
Static Function PesqFaixa(cTabPreco,cProduto,nQtde,dDataVld)
Local aSaveArea	:= GetArea()
Local cCodFaixa	:= ""
Local cQuery	:= ""
Local cAliasDA1	:= GetNextAlias()

cQuery += "SELECT DA1.DA1_XFAIXA "
cQuery += " FROM "+RetSqlName("DA1")+ " DA1 "
cQuery += " WHERE "
cQuery += "   DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
cQuery += "   DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
cQuery += "   DA1.DA1_CODPRO = '"+cProduto+"' AND "
cQuery += "   DA1.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
cQuery += "   DA1.DA1_ATIVO = '1' AND  "
cQuery += "   ( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "
cQuery += "   DA1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY "+SqlOrder(DA1->(IndexKey()))

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)

If (cAliasDA1)->(!Eof())
	cCodFaixa := (cAliasDA1)->DA1_XFAIXA
Endif

If Select(cAliasDA1) > 0
	(cAliasDA1)->(DbCloseArea())
EndIf

RestArea(aSaveArea)

Return(cCodFaixa)

/*/{Protheus.doc} PesqPrecFx
Retorna o preco da faixa utilizando o valor do campo espe-
cifico da faixa(DA1_XFAIXA)
@author Marcos R. Pires
@since 08/04/11
@version P11
@uso Especifico Shell - Tabela Cruzada
@param cTabPreco, characters
@param cProduto, characters
@param cCodFaixa, characters
@param dDataVld, date
@type function
/*/
Static Function PesqPrecFx(cTabPreco,cProduto,cCodFaixa,dDataVld)
Local aSaveArea	:= GetArea()
Local nPrcFaixa	:= 0
Local cQuery	:= ""
Local cAliasDA1	:= GetNextAlias()

cQuery += "SELECT DA1.DA1_XFAIXA, DA1.DA1_PRCVEN "
cQuery += " FROM "+RetSqlName("DA1")+ " DA1 "
cQuery += " WHERE "
cQuery += "   DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
cQuery += "   DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
cQuery += "   DA1.DA1_CODPRO = '"+cProduto+"' AND "
cQuery += "   DA1.DA1_XFAIXA = '"+cCodFaixa+"' AND "
cQuery += "   DA1.DA1_ATIVO = '1' AND  "
cQuery += "   ( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "
cQuery += "   DA1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY "+SqlOrder(DA1->(IndexKey()))

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)

If (cAliasDA1)->(!Eof())
	nPrcFaixa := (cAliasDA1)->DA1_PRCVEN
Endif

If Select(cAliasDA1) > 0
	(cAliasDA1)->(DbCloseArea())
EndIf

RestArea(aSaveArea)

Return(nPrcFaixa)

/*/{Protheus.doc} ShellVlUsr
Retorna o conteudo do campo X3_VLDUSER
@author Marcos R. Pires
@since 13/04/11
@version P11
@uso Especifico Shell - Tabela Cruzada
@param cCampo, characters
@type function
/*/
Static Function ShellVlUsr(cCampo)
Local aSaveArea		:= GetArea()
Local aSaveSX3		:= SX3->(GetArea())
Local cX3VldUser	:= ""

cX3VldUser := AllTrim(Posicione("SX3",2,cCampo,"X3_VLDUSER"))

If cCampo == "C6_QTDVEN"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo executado para nao incluir a funcao "U_ATUFAIXA()" evitando loop infinito ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cX3VldUser := SubStr(cX3VldUser, AT("U_ACRESFIN()", cX3VldUser), Len(cX3VldUser))

EndIf

RestArea(aSaveSX3)
RestArea(aSaveArea)

Return(cX3VldUser)

/*/{Protheus.doc} ShellTpPrd
Verifica se o produto eh proprio ou agregado
Retorno:
.T. = Proprio
.F. = Agregado
@author Marcos R. Pires
@since 14/04/11
@version P11
@uso Especifico Shell - Tabela Cruzada
@param cCodProd, characters
@type function
/*/
Static Function ShellTpPrd(cCodProd)
Local lRet		:= .T.
Local aSaveArea	:= GetArea()
Local aSaveSB1	:= SB1->(GetArea())
Local cCodShel	:= AllTrim(GetMv("MV_CODSHEL")) //Codigo do Fornecedor Shell

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compara o codigo do produto B1_PROC com o codigo do fornecedor Shell ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_PROC")) != cCodShel
	lRet := .F. //Produto Agregado
EndIf

RestArea(aSaveSB1)
RestArea(aSaveArea)

Return(lRet)

/*/{Protheus.doc} CHKCOMBO
Função valida se existe os campos necess?ios para a
execução da rotina U_COMBO
@author Microsiga
@since 02/07/12
@version P11
@uso AP
@type function
/*/
User Function CHKCOMBO()
	Local lRet := .F.

	If IsInCallStack("MATA410") .or. IsInCallStack("FATA400") //Pedido de Vendas, ou Contrato de Parceria
		lRet := (SC5->(FieldPos("C5_CODPAI"))>0 .And. SC5->(FieldPos("C5_QTDPAI"))>0 .And. ;
				  SC6->(FieldPos("C6_CODPAI"))>0 .And. SC6->(FieldPos("C6_COMBO"))>0)
	ElseIf IsInCallStack("TMKA271") //Televendas
		lRet := (SUA->(FieldPos("UA_CODPAI")) > 0 .And. SUA->(FieldPos("UA_QTDPAI")) > 0 .And. ;
				  SUB->(FieldPos("UB_CODPAI")) > 0 .And. SUB->(FieldPos("UB_COMBO")) > 0)

	//@ticket 289937 - T08957 – Ricardo Munhoz - Adicionado a rotina TK271CALLCENTER.
	ElseIf IsInCallStack("TK271CALLCENTER")
		lRet := SUA->(FieldPos("UA_CODPAI")) > 0 .And. SUA->(FieldPos("UA_QTDPAI")) > 0

	Endif
Return(lRet)

/*/{Protheus.doc} VldDescPv
Valida Percentual maximo de desconto no Item do pedido de
venda, e permiss? de usu?io para inclus? de valor de
desconto maior que o maximo permitido.
@author Microsiga
@since 01/08/13
@version P11
@uso Shell
@param nLinha, numeric
@type function
/*/
User Function VldDescPv(nLinha)

Local lRet		:=.T.
Local nDescMax	:= GetNewPar("FS_DESCMAX",0) //Armazena o valor do desconto maximo cadastrado
Local cUser		:= GetNewPar("FS_USERDES","") //Armazena os usuários  que poderam incluir/alterar pedido com valor de desconto maior que o maximo permitido
Local nPosPerdes:= ascan(aheader,{|x| alltrim(x[2]) == "C6_DESCONT"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o percentual incluido é maior que o permitido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Acols[nLinha,nPosPerdes ] > nDescMax .And. !l410Auto .And. !__cUserID $ cUser

	Aviso("ATENCAO","O percentual de desconto do item é maior que o permitido, verificar o percentual e/ou permissão de usuário.",{"OK"})
	lRet:= .F.

EndIf

Return lRet

/*/{Protheus.doc} CAMPO
@author
@since
@version P11
@type function
/*/
user function CAMPO()

msgAlet(Readvar())

Return .T.