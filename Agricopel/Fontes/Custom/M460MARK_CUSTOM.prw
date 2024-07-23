#INCLUDE "RWMAKE.CH"
#INCLUDE "topconn.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460MARK  �Autor  �Microsiga           � Data �  06/20/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera Ordem de Produao e Apontamento para Gasolina C.       ���
���          �                                                            ���
���          � Ponto de entrada chamado antes da geracao das Nf's.        ���
���          � Utilizado para verificar se os dados de remetente e        ���
���          � destinatario esto corretos na empresa transportadora.      ���
���          � Para isso ele chama o execblock AGR882.                    ���
���          � Especifico para o TMS.                                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M460MARK()

	Local cQrySC9   := ""
	Local cAliasSC6 := ""
	Local cAliasSB2 := ""
	Local oTmpSC6   := Nil
	Local oTmpSB2   := Nil	

	*
	* Considera somente Mime distrib. ou Agricopel Base para geracao OP pela estrutura produto
	*
	//Spiller - Caso venha pela rotina de Cargas ignora
	If alltrim(UPPER(FunName())) == 'MATA460B'
		Return .T.
	Endif

	// Colocado para considerar geracao de OP somente para Agricopel(Todas) e Mime Distrib. Cfe Ademir 09/08/2005.
	//If (SM0->M0_CODIGO <> "02") .And. (SM0->M0_CODIGO <> "01") .And. (SM0->M0_CODIGO <> "44")
	// 16/01/2019 - Thiago deixou ativo para sistema executar a regra de OP somente para empresa 44, outras empresas serao analisadas posteriormente.
	If (SM0->M0_CODIGO <> "44")
		Return .T.
	EndIf

	aSeg 	   := GetArea()
	aSegSB1  := SB1->(GetArea())

	SetPrvt("cPedido,cItem,cSequen")
	SetPrvt("lMsHelpAuto,lMsErroAuto")

	aImprime	:= {}
	lImprime := .F.

	// Arquivo temporario dos pedidos que nao serao faturados.
	oTmpSC6   := CriarTbSC6()
	cAliasSC6 := oTmpSC6:GetAlias()

	// Arquivo Temporario para controle do Saldo em Estoque (SB2)
	oTmpSB2   := CriarTbSB2()
	cAliasSB2 := oTmpSB2:GetAlias()

	cQrySC9 := "SELECT * "
	cQrySC9 += "FROM "+RetSqlName("SC9")+" (NOLOCK) "
	cQrySC9 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQrySC9 += "AND D_E_L_E_T_ = '' AND "
	cQrySC9 += "C9_NFISCAL = '' "

	If (Select("SC9B") <> 0)
		dbSelectArea("SC9B")
		dbCloseArea()
	Endif

	TCQuery cQrySC9 NEW ALIAS "SC9B"

	DbSelectArea("SC9B")
	DbGotop()
	While !Eof()

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SB1")+SC9B->C9_PRODUTO)

		DbSelectArea("SC9B")

		// Limpo conteudo do Campo C9_RETOPER pois cfe Sigaville/Cris este campo vale somente para empresa de autope�as e caso
		// contenha algo preenchido, faz com que o sistema quebre em duas notas a gera�ao (Nf com e sem conteudo deste campo)
		// Feito Deco/Willian 01/11/2007
		//If !Empty(SC9B->C9_RETOPER)
		//	RecLock("SC9",.F.)
		//	SC9->C9_RETOPER := ""
		//	MsUnLock("SC9")
		//EndIf

		//Valdecir 29.09 If SC9->C9_OK == PARAMIXB[1,1] .And. SB1->B1_GERAOP == "S"  // Pedido marcado para faturar.
		If ((Marked("C9_OK") .or. SC9B->C9_OK == PARAMIXB[1]) .And. SB1->B1_GERAOP == "S" )   // Pedido marcado para faturar.

			DbSelectArea('SG1')
			DbSetOrder(1)
			If DbSeek(xFilial('SG1')+SC9B->C9_PRODUTO)
				nQuant 	:= 0
				lGeraOp	:= .T.
				DbSelectArea('SG1')
				DbSetOrder(1)
				DbGotop()
				DbSeek(xFilial('SG1')+SC9B->C9_PRODUTO)
				While !Eof()	.And. SG1->G1_FILIAL	== xFilial('SG1');
				.And. SG1->G1_COD 	== SC9B->C9_PRODUTO

					nSldSB2 := 0
					DbSelectArea("SB2")
					DbSetOrder(1)
					DbGotop()
					If DbSeek(xFilial("SB2")+SG1->G1_COMP)
						nSldSB2	:= SaldoSB2()
					End

					nQuant 	:= SC9B->C9_QTDLIB * SG1->G1_QUANT

					DbSelectArea(cAliasSB2)
					DbSetOrder(1)
					DbGotop()
					If DbSeek(SG1->G1_COMP)
						DbSelectArea(cAliasSB2)
						RecLock(cAliasSB2,.F.)
						(cAliasSB2)->QATU	:= (cAliasSB2)->QATU + nQuant
						MsUnLock()
					Else
						RecLock(cAliasSB2,.T.)
						(cAliasSB2)->COD 	:= SG1->G1_COMP
						(cAliasSB2)->QATU	:= nQuant
						MsUnLock()
					EndIf

					If nSldSB2 < (cAliasSB2)->QATU .And. SG1->G1_COMP <> "00014"  // Segundo Sr. Lauro, o produto 00014 poder ser negativo.
						// VERIFICA NO PARAMETRO ESTNEG, SE PERMITE FATURAR COM SALDO NEGATIVO.
						//						If	cEstNeg == "N"   COMENTADO POR VALDECIR EM 11.08

						lImprime := .T.
						Aadd(aImprime,{"Pedido nao Faturado: "+SC9B->C9_PEDIDO , " Componente: "+ALLTRIM(SG1->G1_COMP)+" Nao possui Saldo Suficiente: "+Transform(nQuant,"@E 9999.99")})

						DbSelectArea(cAliasSC6)
						DbSetOrder(1)
						DbGotop()
						If !DbSeek(SC9B->C9_PEDIDO+SC9B->C9_ITEM+SC9B->C9_PRODUTO)
							DbSelectArea(cAliasSC6)
							RecLock(cAliasSC6,.T.)
							(cAliasSC6)->PEDIDO 	:= SC9B->C9_PEDIDO
							(cAliasSC6)->ITEM		:= SC9B->C9_ITEM
							(cAliasSC6)->PRODUTO	:= SC9B->C9_PRODUTO
							(cAliasSC6)->GERAOP		:= "N"
							MsUnLock()
						Else
							DbSelectArea(cAliasSC6)
							RecLock(cAliasSC6,.F.)
							(cAliasSC6)->GERAOP		:= "N"
							MsUnLock()
						EndIf

						/*		COMENTADO POR VALDECIR EM 11.08
						Else
						DbSelectArea(cAliasSC6)
						DbSetOrder(1)
						DbGotop()
						If !DbSeek(SC9->C9_PEDIDO)
						DbSelectArea(cAliasSC6)
						RecLock(cAliasSC6,.T.)
						(cAliasSC6)->PEDIDO 	:= SC9->C9_PEDIDO
						(cAliasSC6)->ITEM		:= SC9->C9_ITEM
						(cAliasSC6)->PRODUTO	:= SC9->C9_PRODUTO
						(cAliasSC6)->GERAOP		:= "S"
						MsUnLock()
						EndIf
						EndIf
						*/
					Else
						DbSelectArea(cAliasSC6)
						DbSetOrder(1)
						DbGotop()
						If !DbSeek(SC9B->C9_PEDIDO+SC9B->C9_ITEM+SC9B->C9_PRODUTO)
							DbSelectArea(cAliasSC6)
							RecLock(cAliasSC6,.T.)
							(cAliasSC6)->PEDIDO 	:= SC9B->C9_PEDIDO
							(cAliasSC6)->ITEM		:= SC9B->C9_ITEM
							(cAliasSC6)->PRODUTO	:= SC9B->C9_PRODUTO
							(cAliasSC6)->GERAOP		:= "S"
							MsUnLock()
						EndIf
					EndIf

					DbSelectArea("SG1")
					SG1->(DbSkip())

				EndDo
			EndIf
		EndIf

		DbSelectArea("SC9B")
		DbSkip()
	EndDo

	// INCLUIDO POR VALDECIR EM 20.06.03

	DbSelectArea(cAliasSC6)
	DbSetOrder(1)
	DbGotop()
	While !Eof()

		DbSelectArea("SC9")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SC9")+(cAliasSC6)->PEDIDO+(cAliasSC6)->ITEM,.T.)
			//Valdecir 29.09 If SC9->C9_OK == PARAMIXB[1,1]

			If ((Marked("C9_OK")) .or. SC9->C9_OK == PARAMIXB[1])
				DbSelectArea("SG1")
				DbSetOrder(1)
				DbGotop()
				If DbSeek(xFilial("SG1")+SC9->C9_PRODUTO)
					If (cAliasSC6)->GERAOP == "N"

						DbSelectArea("SC5")
						DbSetOrder(1)
						DbGotop()
						If DbSeek(xFilial("SC5")+(cAliasSC6)->PEDIDO)
							RecLock("SC5",.F.)
							SC5->C5_LIBEROK	:= Space(01)
							If EMPTY(SC5->C5_CODTEX1)
								SC5->C5_CODTEX1   := "001"
							EndIf
							If EMPTY(SC5->C5_CODTEX2)
								SC5->C5_CODTEX2   := "002"
							EndIf
							If Alltrim((cAliasSC6)->PRODUTO) == '00072' .Or. Alltrim((cAliasSC6)->PRODUTO) == '00073'
								SC5->C5_CODTEX1 := '004'  // Atualizo o texto padrao caso produto cfe alexandre/Ctb 09/08/2006
							EndIf
							If Alltrim((cAliasSC6)->PRODUTO) == '00083'
								SC5->C5_CODTEX1 := '005'  // Atualizo o texto padrao caso produto cfe alexandre/Ctb 05/07/2007
							EndIf
							MsUnLock("SC5")
						EndIf

						DbSelectArea("SC6")
						DbSetOrder(1)
						DbGotop()
						If DbSeek(xFilial("SC6")+(cAliasSC6)->PEDIDO+(cAliasSC6)->ITEM+(cAliasSC6)->PRODUTO)
							RecLock("SC6",.F.)
							SC6->C6_OP		:= Space(02)
							SC6->C6_QTDEMP	:= 0
							SC6->C6_QTDLIB	:= 0
							MsUnLock("SC6")
						EndIf

						DbSelectArea("SC9")
						RecLock("SC9",.F.)
						// SC9->C9_OK := ""
						DbDelete()
						MsUnLock("SC9")

					EndIf
				EndIf
			EndIf

		EndIf

		DbSelectArea(cAliasSC6)
		(cAliasSC6)->(DbSkip())
	End

	cQrySC9:= ""
	//DbSelectArea("SC9")
	//DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
	//DbGotop()
	cQrySC9:= "SELECT * "
	cQrySC9+= "FROM "+RetSqlName("SC9")+" (NOLOCK) "
	cQrySC9+= "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQrySC9+= "AND D_E_L_E_T_ = '' AND "
	cQrySC9+= "C9_NFISCAL = '' "

	If (Select("SC9A") <> 0)
		dbSelectArea("SC9A")
		dbCloseArea()
	Endif

	TCQuery cQrySC9 NEW ALIAS "SC9A"

	dbSelectArea("SC9A")
	DbGotop()

	While !Eof()

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SB1")+SC9A->C9_PRODUTO)

		DbSelectArea("SC9A")
		// Valdecir 29.09      If SC9->C9_OK == PARAMIXB[1,1] .And. SB1->B1_GERAOP == "S"  // Pedido marcado para faturar.
		If ((Marked("C9_OK") .or. SC9A->C9_OK == PARAMIXB[1]) .And. SB1->B1_GERAOP == "S")   // Pedido marcado para faturar.
			DbSelectArea("SG1")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SG1")+SC9A->C9_PRODUTO)
				Gera()
			EndIf
		EndIf

		DbSelectArea("SC9A")
		DbSkip()
	EndDo

	If lImprime
		Imprime()
	EndIf

	(cAliasSB2)->(DbCloseArea())
	oTmpSB2:Delete()
	FreeObj(oTmpSB2)

	(cAliasSC6)->(DbCloseArea())
	oTmpSC6:Delete()
	FreeObj(oTmpSC6)

	RestArea(aSegSB1)
	RestArea(aSeg)

Return(.T.)

Static Function CriarTbSC6()

	Local oTmpTable := Nil
	Local aCampos   := {}

	Aadd(aCampos,{"PEDIDO"	,"C",06,0})
	Aadd(aCampos,{"ITEM"	,"C",02,0})
	Aadd(aCampos,{"PRODUTO"	,"C",15,0})
	Aadd(aCampos,{"GERAOP"	,"C",01,0})

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {"PEDIDO","ITEM","PRODUTO"})
	oTmpTable:Create()

Return(oTmpTable)

Static Function CriarTbSB2()

	Local oTmpTable := Nil
	Local aCampos   := {}

	Aadd(aCampos,{"COD"	,"C",15,0})
	Aadd(aCampos,{"QATU","N",14,2})

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {"COD"})
	oTmpTable:Create()

Return(oTmpTable)

Static Function Gera()
	GeraOp()
	GeraApont()
Return()

Static Function GeraOP()

	Local aRot650 := {}

	//atualizado quando houver
	//alguma inconsistencia nos parametros
	//cPedido    :=	GetSx8Num("SC2")

	// Alterado por Valdecir em 31.07.03.
	// Conforme sugestao do Sr. Deco, alterei o programa para que o numero da ordem de producao,
	// seja igual ao numero do pedido.  Com isto, facilita a localizacao da ordem de producao.
	//cPedido    :=	cPedSC5  //SC9->C9_PEDIDO

	cPedido    :=	GETSXENUM("SC2",'C2_NUM') //GetSxBNum("SC2")
	ConfirmSx8()
	//Item    :=	"01"         // Valdecir fez para gravar OP para pedido somente com 1 item
	cItem    :=	"01"  //SC9->C9_ITEM // Alterado para pedidos com mais de 1 itens - Deco 07/06/2004.
	cSequen  := "001"

	//ALERT(cPedido)
	//alert(cItem)

	aRot650 := {{"C2_NUM"     ,cPedido           ,Nil},;
	{"C2_ITEM"    ,cItem           ,Nil},;
	{"C2_SEQUEN"  ,cSequen         ,Nil},;
	{"C2_PRODUTO" ,SC9A->C9_PRODUTO ,Nil},;
	{"C2_LOCAL"   ,SB1->B1_LOCPAD  ,Nil},;
	{"C2_QUANT"   ,SC9A->C9_QTDLIB  ,Nil},;
	{"C2_UM"      ,SB1->B1_UM      ,Nil},;
	{"C2_DATPRI"  ,dDatabase       ,Nil},;
	{"C2_DATPRF"  ,dDatabase       ,Nil},;
	{"C2_EMISSAO" ,dDatabase       ,Nil},;
	{"C2_TPOP"    ,"F"              ,Nil},;
	{"C2_GRADE"   ,"N"              ,Nil},;
	{"AUTEXPLODE" ,"S"              ,Nil}}   // Explode a estrutura para gerar SD4 (Empenhos).

	Begin Transaction
		lMsHelpAuto := .t.  // se .t. direciona as mensagens de help
		lMsErroAuto := .f. //necessario a criacao, pois sera
		MSExecAuto({|x,y| mata650(x,y)},aRot650,3)
		If lMsErroAuto
			DisarmTransaction()
			break
		EndIf
	End Transaction

	If lMsErroAuto
		Mostraerro()
		Return .F.
	EndIf
	ConfirmSx8()

	DbSelectArea("SC2")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SC2")+cPedido  +cItem ,.T.)
		RecLock("SC2",.F.)
		SC2->C2_PEDCOD 	:= SC9A->C9_PEDIDO
		SC2->C2_PEDIT   := SC9A->C9_ITEM
		MsUnLock("SC2")
	EndIf

	DbSelectArea("SC6")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SC6")+SC9A->C9_PEDIDO+SC9A->C9_ITEM,.T.)
		RecLock("SC6",.F.)
		SC6->C6_NUMOP 	:= cPedido
		SC6->C6_ITEMOP	:= cItem
		MsUnLock("SC6")
	EndIf

Return .T.

Static Function GeraApont()

	cApOp := cPedido + citem + cSequen + "   "

	// ------------------------------
	// Incluido por valdecir em 08.01.08
	// C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	cD3_PARCTOT := Space(01)
	DbSelectArea("SC2")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SC2")+cPedido+cItem+cSequen,.T.)
		If (SC2->C2_QUJE +	SC9A->C9_QTDLIB) <> SC2->C2_QUANT
			cD3_PARCTOT := "P"
		Else
			cD3_PARCTOT := "T"
		EndIf
	EndIf

	//----------------------------
	/*
	aVetor := {}

	If (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) <> "03")
	aAdd(aVetor, {"D3_TM"     , "001"				, Nil}) // 010 Producao para Agricopel Matriz  Deco 27/02/006
	Else
	aAdd(aVetor, {"D3_TM"     , "010"				, Nil}) // 001 Producao para Agricopal base e mime distrib  Deco 27/02/06
	Endif
	aAdd(aVetor, {"D3_OP"     , cApOp		    , Nil})
	aAdd(aVetor, {"D3_COD"    , SC9->C9_PRODUTO	, Nil})
	aAdd(aVetor, {"D3_QUANT"  , SC9->C9_QTDLIB  , Nil})
	aAdd(aVetor, {"D3_UM"     , SB1->B1_UM		, Nil})

	// Incluido por Valdecir em 08/01/08
	aAdd(aVetor, {"D3_QTSEGUM", 0				, Nil})
	aAdd(aVetor, {"D3_SEGUM"  , SB1->B1_UM   	, Nil})
	aAdd(aVetor, {"D3_PARCTOT", cD3_PARCTOT		, Nil})
	aAdd(aVetor, {"D3_LOCAL"  , SB1->B1_LOCPAD	, Nil})
	aAdd(aVetor, {"D3_CC"     , SB1->B1_CC   	, Nil})
	aAdd(aVetor, {"D3_CONTA"  , SB1->B1_CONTA 	, Nil})
	aAdd(aVetor, {"D3_EMISSAO", dDataBase		, Nil})
	aAdd(aVetor, {"D3_DOC"    , cPedido 		, Nil})
	aAdd(aVetor, {"D3_PERDA"  , 0				, Nil})
	aAdd(aVetor, {"D3_DESCRI" , SB1->B1_DESC	, Nil})

	Begin Transaction
	lMsHelpAuto := .t.  // se .t. direciona as mensagens de help
	lMsErroAuto := .f. 	//necessario a criacao, pois sera
	MsExecAuto({|x,y| Mata250(x,y)},aVetor,3)
	If lMsErroAuto
	Mostraerro()
	EndIf
	End Transaction
	*/
	// Esta rotina abaixo substitui a acima, pois dava erro na inclusao do apontamento do SD3 na migra�ao para o Microsiga Protheus 10
	// Feito Microsiga SP/Valdecir sigaville 11/01/2008.
	aVetor := {}

	If (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) <> "03")
		aAdd(aVetor, {"D3_TM"     , "001"                                              , Nil}) // 001 Producao para Agricopel Matriz  Deco 27/02/006
	ElseIf (SM0->M0_CODIGO == "44")
		aAdd(aVetor, {"D3_TM"     , "002"                                              , Nil}) // 002 Producao para POSTO FAROL - Osmar 28/11/2018
	Else
		aAdd(aVetor, {"D3_TM"     , "010"                                              , Nil}) // 010 Producao para Agricopal base e mime distrib  Deco 27/02/06

	Endif

	aAdd(aVetor, {"D3_COD"    , SC9A->C9_PRODUTO         , Nil})
	aAdd(aVetor, {"D3_UM"     , SB1->B1_UM                     , Nil})
	aAdd(aVetor, {"D3_QUANT"  , SC9A->C9_QTDLIB            , Nil})
	aAdd(aVetor, {"D3_OP"     , cApOp                        , Nil})
	aAdd(aVetor, {"D3_LOCAL"  , SB1->B1_LOCPAD          , Nil})
	aAdd(aVetor, {"D3_DOC"  ,        cPedido, Nil})
	aAdd(aVetor, {"D3_EMISSAO", dDataBase                                , Nil})

	INCLUI := .T.
	lMsHelpAuto := .t.  // se .t. direciona as mensagens de help
	lMsErroAuto := .f.          //necessario a criacao, pois sera
	MsExecAuto({|x,y| Mata250(x,y)},aVetor,3)
	If lMsErroAuto
		Mostraerro()
	EndIf

Return

Static Function Imprime()

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	LOCAL cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	LOCAL cDesc2       := "de acordo com os parametros informados pelo usuario."
	LOCAL cDesc3       := "Inconsistencias na Preparacao da Nota Fiscal"
	LOCAL titulo       := "Inconsistencias na Preparacao da Nota Fiscal"
	LOCAL nLin         := 80
	LOCAL Cabec1       := "*  INCONSISTENCIAS                                                                                                  "
	LOCAL Cabec2       := ""
	LOCAL aOrd         := {}

	PRIVATE lEnd       := .F.
	PRIVATE lAbortPrint:= .F.
	PRIVATE limite     := 132
	PRIVATE tamanho    := "M"
	PRIVATE nomeprog   := "M460MA" // Coloque aqui o nome do programa para impressao no cabecalho
	PRIVATE nTipo      := 18
	PRIVATE aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	PRIVATE nLastKey   := 0
	PRIVATE cbtxt      := Space(10)
	PRIVATE cbcont     := 00
	PRIVATE CONTFL     := 01
	PRIVATE m_pag      := 01
	PRIVATE wnrel      := "M460MA" // Coloque aqui o nome do arquivo usado para impressao em disco
	PRIVATE cString    := "SE1"

	//���������������������������������������������������������������������Ŀ
	//� Ordeno matriz com inconsistencias                                   �
	//�����������������������������������������������������������������������
	aImprime := aSort(aImprime,,,{|x,y| x[1]<y[1]})

	//���������������������������������������������������������������������Ŀ
	//� Monta a interface padrao com o usuario                              �
	//�����������������������������������������������������������������������
	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
	//�����������������������������������������������������������������������
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	LOCAL _nImp := 1, cQuebra := Space(3)

	//���������������������������������������������������������������������Ŀ
	//� Impressao das inconsistencias                                       �
	//�����������������������������������������������������������������������
	Setregua(Len(aImprime))
	While (_nImp <= Len(aImprime))

		//���������������������������������������������������������������������Ŀ
		//� Verifica o cancelamento pelo usuario                                �
		//�����������������������������������������������������������������������
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//���������������������������������������������������������������������Ŀ
		//� Impressao do cabecalho do relatorio                                 �
		//�����������������������������������������������������������������������
		If (nLin > 55)
			If (nLin != 80)
				Roda(0,"","M")
			EndIf
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		cQuebra := aImprime[_nImp,1]
		@ nLin,004 PSAY "DIVERGENCIAS PREPARACAO DA NOTA FISCAL"
		nLin++
		@ nLin,004 PSAY "----------------------------------------------"
		nLin++

		While (_nImp <= Len(aImprime)).and.(aImprime[_nImp,1] == cQuebra)

			//���������������������������������������������������������������������Ŀ
			//� Verifica o cancelamento pelo usuario                                �
			//�����������������������������������������������������������������������
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			//���������������������������������������������������������������������Ŀ
			//� Impressao do cabecalho do relatorio                                 �
			//�����������������������������������������������������������������������
			If (nLin > 55)
				If (nLin != 80)
					Roda(0,"","M")
				EndIf
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif

			@ nLin,006 PSAY aImprime[_nImp,1]+" "+aImprime[_nImp,2]
			nLin++

			_nImp++
		Enddo
		nLin++

	Enddo
	If (nLin != 80)
		Roda(0,"","M")
	EndIf

	//���������������������������������������������������������������������Ŀ
	//� Finaliza a execucao do relatorio                                    �
	//�����������������������������������������������������������������������
	SET DEVICE TO SCREEN

	//���������������������������������������������������������������������Ŀ
	//� Se impressao em disco, chama o gerenciador de impressao             �
	//�����������������������������������������������������������������������
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()

Return
