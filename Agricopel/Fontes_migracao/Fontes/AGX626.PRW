#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWBROWSE.CH'
#include "rwmake.ch"
#INCLUDE 'FWMVCDEF.CH'

User Function AGX626()
	Local aArea     := GetArea()
	Local cIdBrowse := ''
	Local cIdRodape := ''
	Local cFile     := ''
	Local nI        := 0
	Local nAt       := 0
	Local cTrab     := GetNextAlias()
	Local cQryDoc   := GetNextAlias()
	Local cQuery    := " "
	Local aCampos   := {}
	Local aStru     := {}
	Local aAux      := {}
	Local aButton   := {}
	Local oBrowse
	Local oColumn

	Local oDlg
	Local oGed
	Local aCoord := { 0, 0, 500, 1000 }
	//Local bKeyF12    := SetKey(VK_F12)
	//Local bKeyF5    := SetKey(VK_F5)

	Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Pixel style DS_MODALFRAME

	CriaTabT()
	Carga()

	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TELA" OF oDlg

	oBrowse:DisableConfig ( )
	oBrowse:SetDoubleClick({||TelaIt(),	CriaTabT(),Carga(),	oBrowse:Refresh(),oBrowse:GoTop(.t.)  })

	aButton := { { "Importar Arquivo"   , { || Processa(U_AGX629(),	CriaTabT(),Carga(),	oBrowse:Refresh(),oBrowse:GoTop(.t.) )} , "Importar Arquivo" },;
	{ "Elimina Residuo", { || Residuo(),	CriaTabT(),Carga(),	oBrowse:Refresh(),oBrowse:GoTop(.t.) }, "Residuo" }}

	/*Local aButton := {	{"SIMULACAO",	{|| If(ValType(aGetDb[oFolder:nOption])=="O" .And. !Empty((aAlias[oFolder:nOption])->DataX),(Fc021Proj(oDlg,aFluxo,aAlias,oFolder,aGetDb,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,@nTotal,aPeriodo,nLimCred),aGetDb[oFolder:nOption]:oBrowse:Refresh()), .T.) }, STR0171},;
	{"ANALITICO",	{|| If(ValType(oFolder:aDialogs[oFolder:nOption])=="O"  .And.;
	ValType(oFolder:aDialogs[oFolder:nOption]:Cargo) == "A" .And.;
	ValType(oFolder:aDialogs[oFolder:nOption]:Cargo[2]) == "B", Eval(oFolder:aDialogs[oFolder:nOption]:Cargo[2]), .T.)},STR0172}}*/

	//	AADD(aCampos,{"CONDPAG"		,"Cond Pag"   		,"@!"		})
	//	AADD(aCampos,{"DESCOND"		,"Descricao"   		,"@!"		})
	AADD(aCampos,{"CNPJ"		,"CNPJ                   " ,"@!"		})
	AADD(aCampos,{"CLIENTE"		,"Cliente"   			,"@!"		})
	AADD(aCampos,{"LOJA"		,"Loja"   	   			,"@!"		})
	AADD(aCampos,{"NOME"		,"Razão Social"   		,"@!"		})

	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos )
		ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2] PICTURE aCampos[nI][3] Of oBrowse
	Next

	//ADD MARKCOLUMN oColumn DATA { || If(.T./* Função com a regra*/,'LBOK','LBNO') } DOUBLECLICK { |oBrowse| /* Função que atualiza a regra*/ } HEADERCLICK { |oBrowse| /* Função executada no clique do header */ } OF oBrowse

	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------

	Activate FWBrowse oBrowse

	//     aButton := { { "Importar"   , { || ReImp(),oBrowse:Refresh()}, "Importar" ,"Importar"   }}
	//                  { "RELATORIO", { || fRel() }, "Imprimir","Imprimir" }}

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},,aButton)

	//BusPosto()

	RestArea( aArea )

Return()

Static Function BusPosto()
	Private _cAlias		:= GetNextAlias()
	Private _cAlias2	:= GetNextAlias()

	//Busco os postos que possuem itens para importar

	cQuery := "SELECT DISTINCT ( CNPJ),CAST(CNPJ AS VARCHAR) CCNPJ  FROM PEDPOSTO2 WHERE  DATA_IMP IS NULL "

	If (Select(_cAlias) <> 0)
		dbSelectArea(_cAlias)
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (_cAlias)

	dbSelectArea(_cAlias)
	dbgotop()
	While !eof()
		// Faco nova busca nos pedidos para o posto setado

		//    	ALERT("AQUI")

		cQuery := "SELECT SEQUENCIA,CAST(CODPRO AS VARCHAR) CODPRO, CAST(CODTKE AS VARCHAR) CODTKE, QTDE FROM PEDPOSTO2 WHERE CNPJ = "
		cQuery += ALLTRIM((_cAlias)->CCNPJ) + " AND DATA_IMP IS NULL "

		////Busco os itens do pedido da filial com data nula
		If (Select(_cAlias2) <> 0)
			dbSelectArea(_cAlias2)
			dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS (_cAlias2)

		//		ConvSaldo()

		dbSelectArea(_cAlias2)
		dbgotop()
		Do while !eof()

			//Busco informações ref ao produto
			//Verifico primeiro pelo B1_COD , se nao encontrar no B1_COD

			cQuery := "SELECT * FROM " + RetSqlName("SB1")
			cQuery += "WHERE B1_COD LIKE '" + alltrim((_cAlias2)->CODTKE) + "' "
			cQuery += "AND B1_FILIAL = '" + xFilial("SB1") + "' AND D_E_L_E_T_ <> '*' "

			If (Select("PRODUTO") <> 0)
				dbSelectArea("PRODUTO")
				dbCloseArea()
			Endif

			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS ("PRODUTO")

			dbSelectArea("CONSALD")
			Reclock( "CONSALD", .T.)
			CONSALD->SEQUEN := (_cAlias2)->SEQUENCIA
			CONSALD->CODPRO := (_cAlias2)->CODPRO
			CONSALD->QTDE   := (_cAlias2)->QTDE
			MsUnlock()

			dbSelectArea(_cAlias2)
			(_cAlias2)->(dbSkip())

		EndDo

		dbSelectArea(_cAliasADMI)
		(_cAlias)->(dbSkip())

	EndDo

Return()

Static Function TrabIt()

	aCampos := {}

	AADD(aCampos,{"SEQUEN"    ,"N",10,0} )

	AADD(aCampos,{"CODPRO"   ,"C",15 ,0 } )

	AADD(aCampos,{"CODFOR"   ,"C",15 ,0 } )

	AADD(aCampos,{"QTDE"     ,"N",14 ,2 } )

	AADD(aCampos,{"ATEND"    ,"C",6 ,0  } )

	AADD(aCampos,{"ITEM"     ,"C",4 ,0  } )
	AADD(aCampos,{"PRCVEN"   ,"N",14 ,2 } )
	AADD(aCampos,{"VLRITEM"  ,"N",14 ,2 } )
	AADD(aCampos,{"DESC"     ,"N",5 ,2  } )
	AADD(aCampos,{"VALDESC"  ,"N",14 ,2  } )
	AADD(aCampos,{"TES"      ,"C",3 ,0  } )
	AADD(aCampos,{"CF"       ,"C",5 ,0  } )
	AADD(aCampos,{"LOCPAD"    ,"C",2 ,0  } )
	AADD(aCampos,{"EMISSAO"  ,"C",8 ,0  } )
	AADD(aCampos,{"DTENTRE"  ,"C",8 ,0  } )
	AADD(aCampos,{"TAXAS"    ,"N",5 ,2  } )
	AADD(aCampos,{"CUSTO"    ,"N",14 ,4  } )
	AADD(aCampos,{"SALDO"    ,"N",14 ,4  } )
	AADD(aCampos,{"CBASE"    ,"N",14 ,4  } )

	AADD(aCampos,{"AUXTAB"   ,"N",14 ,4  } )
	AADD(aCampos,{"TIPCAR"    ,"C",2 ,0  } )
	AADD(aCampos,{"DESCAUX"    ,"C",50 ,0  } )
	AADD(aCampos,{"QTDEATEN"    ,"N",14 ,4  } )
	AADD(aCampos,{"OK"    ,"L",1 ,0  } )
	AADD(aCampos,{"MSBLQL"    ,"C",1 ,0  } )

	If Select("TRBIT") <> 0
		dbSelectArea("TRBIT")
		dbCloseArea()
	Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"TRBIT",.T.,.F.)

	IndRegua("TRBIT", cArqTrab, "DESCAUX",,,"Indexando registros..." )

Return()

Static Function CargaIt()
	Private _cAlias2 := GetNextAlias()

	cQuery := "SELECT SEQUENCIA,CAST(CODPRO AS VARCHAR) CODPRO, CAST(CODTKE AS VARCHAR) CODTKE, QTDE FROM PEDPOSTO2 WHERE CNPJ = "
	cQuery += ALLTRIM(TELA->CNPJ) + " AND DATA_IMP IS NULL "

	////Busco os itens do pedido da filial com data nula
	If (Select(_cAlias2) <> 0)
		dbSelectArea(_cAlias2)
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (_cAlias2)

	cItem := "0001"

	//Busco acrescimo da condicao de pagamento para calculo do preco unitario

	nAcres := 0
	dbSelectArea("SE4")
	dbSetOrder(1)
	If dbseek(xFilial("SE4")+"002")
		nAcres := SE4->E4_X_ACRES

	EndIf

	dbSelectArea(_cAlias2)
	dbgotop()
	Do while !eof()

		//Busco informações ref ao produto
		//Verifico primeiro pelo B1_COD , se nao encontrar no B1_COD

		cQuery := "SELECT B1_COD, B1_TIPCAR, B1_LOCPAD,B1_DESC,B1_AGMRKP,B1_MSBLQL FROM " + RetSqlName("SB1") + " (NOLOCK) "
		cQuery += "WHERE (B1_COD LIKE '" + alltrim((_cAlias2)->CODTKE) +  "') "
		cQuery += "AND B1_FILIAL = '" + xFilial("SB1") + "' AND D_E_L_E_T_ <> '*' "

		If (Select("PRODUTO") <> 0)
			dbSelectArea("PRODUTO")
			dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS ("PRODUTO")

		dbSelectArea("PRODUTO")

		If alltrim(PRODUTO->B1_DESC) == ""
			//	   			alert((_cAlias2)->CODTKE)
		EndIf

		cDescricao := PRODUTO->B1_DESC
		cLocal     := PRODUTO->B1_LOCPAD
		cTipoCarga := PRODUTO->B1_TIPCAR
		cProduto   := PRODUTO->B1_COD
		cBloq      := PRODUTO->B1_MSBLQL

		//Busco Estoques
		nSaldo := 0
		dbSelectArea("SB2")
		dbSetorder(1)
		If dbseek(xFilial("SB2")+PRODUTO->B1_COD+PRODUTO->B1_LOCPAD)
			nSaldo := SB2->B2_QATU - SB2->B2_QACLASS - SB2->B2_RESERVA
		EndIf

		If nSaldo < 0
			nSaldo := 0
		EndIf

		// Busco desconto markup

		nDescMkp := 0

		dbSelectArea("SZ5")
		dbSetOrder(1)
		If dbseek(xFilial("SZ5")+PRODUTO->B1_AGMRKP)
			nDescMkp := SZ5->Z5_DESCAGR
		EndIf

		//Busco Preco do produto na tabela master

		cQuery := "SELECT DA1_PRCVEN FROM " + RetSqlName("DA1")
		cQuery += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
		cQuery += "  AND D_E_L_E_T_ <> '*' AND DA1_CODTAB = '001' "
		cQuery += "  AND DA1_CODPRO = '" + PRODUTO->B1_COD + "' "

		If (Select("PRECO") <> 0)
			dbSelectArea("PRECO")
			dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS ("PRECO")

		dbSelectArea("PRECO")
		nPreco := 0

		//Aplico acrescimo financeiro
		nPreco := (PRECO->DA1_PRCVEN + ((PRECO->DA1_PRCVEN * nAcres)/100))

		//desconto mkp
		nPreco := nPreco - ((nPreco * nDescMkp) / 100)

		//Verifico se a quantidade vai conseguir atender o pedido
		nQtdeAten := 0

		Do Case
			Case nSaldo >= (_cAlias2)->QTDE
			nQtdeAten := (_cAlias2)->QTDE
			Case (_cAlias2)->QTDE > nSaldo .and. nSaldo > 0
			nQtdeAten := nSaldo
			Otherwise
			nQtdeAten := 0
		EndCase

		dbSelectArea("TRBIT")
		Reclock( "TRBIT", .T.)
		TRBIT->SEQUEN  := (_cAlias2)->SEQUENCIA
		TRBIT->CODPRO  := PRODUTO->B1_COD
		TRBIT->LOCPAD  := cLocal
		TRBIT->DESCAUX := cDescricao
		TRBIT->QTDE    := (_cAlias2)->QTDE
		TRBIT->SALDO   := nSaldo
		TRBIT->PRCVEN  := nPreco
		TRBIT->VLRITEM := nPreco * (_cAlias2)->QTDE
		TRBIT->TIPCAR  := PRODUTO->B1_TIPCAR
		TRBIT->QTDEATEN:= nQtdeAten
		TRBIT->MSBLQL  := cBloq
		MsUnlock()

		dbSelectArea(_cAlias2)
		(_cAlias2)->(dbSkip())

	EndDo

	dbSelectArea(_cAlias2)
	dbCloseArea()

	dbSelectArea("TRBIT")
	dbGoTop()

Return()

Static Function CriaSx1()
	Private cPerg      := "AGX626"

	PutSx1(cPerg, "05", "Cliente         ?", "" , "", "mv_ch1", "C", 6 , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "06", "Loja            ?", "" , "", "mv_ch2", "C", 6 , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "03", "Importado de    ?", "" , "", "mv_ch3", "D", 8 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "04", "Importado até   ?", "" , "", "mv_ch4", "D", 8 , 0, 2, 'G',"","","","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", "")
	//	PutSx1(cPerg, "09", "Importados      ?",""  , "", "mv_ch5, "N",01,0,1,"C","","","","","mv_par09","Todos Pedidos","Todos Pedidos","Todos Pedidos","","Nao Importados","Nao Importados","Nao Importados","","","" )

Return Pergunte(cPerg,.T.)

Static Function CriaTabT()
	aCamposT := {}

	//	aAdd(aCampos,{"OK"		,"C",02,00})
	aAdd(aCamposT,{"CNPJ"	,"C",14,00})
	//	aAdd(aCamposT,{"NCNPJ"	,"N",14,00})
	aAdd(aCamposT,{"CLIENTE"	,"C",06,00})
	aAdd(aCamposT,{"LOJA"    ,"C",02,00})
	aAdd(aCamposT,{"NOME"	,"C",40,00})

	If Select("TELA") <> 0
		dbSelectArea("TELA")
		dbCloseArea()
	Endif

	cArqTrab := CriaTrab(aCamposT,.T.)
	dbUseArea(.T.,,cArqTrab,"TELA",.T.,.F.)

	IndRegua("TELA", cArqTrab, "LOJA",,,"Indexando registros..." )

Return()

Static Function Carga()
	Private _cAlias		:= GetNextAlias()

	//Busco os postos que possuem itens para importar

	cQuery := "SELECT DISTINCT ( CNPJ),CAST(CNPJ AS VARCHAR) CCNPJ  FROM PEDPOSTO2 WHERE  DATA_IMP IS NULL "

	If (Select(_cAlias) <> 0)
		dbSelectArea(_cAlias)
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (_cAlias)

	DbSelectArea(_cAlias)
	dbGoTop()
	While !eof()

		//Busco Informacoes posto

		dbselectArea("SA1")
		dbSetOrder(3)
		If !dbseek(xFilial("SA1") + (_cAlias)->CCNPJ)
			DbSelectArea(_cAlias)
			(_cAlias)->(dbskip())
			loop
		EndIf

		cCod  := SA1->A1_COD
		cLoja := SA1->A1_LOJA
		cNome := SA1->A1_NOME

		dbSelectArea("TELA")
		RecLock("TELA", .T.)
		CNPJ    := (_cAlias)->CCNPJ
		NCNPJ   := (_cAlias)->CNPJ
		CLIENTE := cCod
		LOJA    := cLoja
		NOME    := cNome
		MsUnLock()

		dbSelectArea(_cAlias)
		dbSkip()
	EndDo

	dbSelectArea(_cAlias)
	dbCloseArea()

	dbSelectArea("TELA")
	dbGoTop()

Return()

Static Function TelaIt()

	Local aArea     := GetArea()
	Local cIdBrowse := ''
	Local cIdRodape := ''
	Local cFile     := ''
	Local nI        := 0
	Local nAt       := 0
	Local cTrab     := GetNextAlias()
	Local cQryDoc   := GetNextAlias()
	Local cQuery    := " "
	Local aCampos   := {}
	Local aStru     := {}
	Local aAux      := {}
	Local aButton   := {}
	Local oBrowse2
	Local oColumn
	Local oDlg2
	Local oGed2
	Local aCoord := { 0, 0, 500, 1000 }
	lTodos := .f.

	Define MsDialog oDlg2 FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Pixel style DS_MODALFRAME

	TrabIt()
	CargaIt()

	DEFINE FWBROWSE oBrowse2 DATA TABLE ALIAS "TRBIT" OF oDlg2

	oBrowse2:DisableConfig ( )

	ADD MARKCOLUMN oColumn DATA { || If(TRBIT->OK,'LBOK','LBNO') } DOUBLECLICK { |oBrowse2| MarkOnOff(),oBrowse2:Refresh()} HEADERCLICK { |oBrowse2| MarkAll(),oBrowse2:Refresh() } OF oBrowse2

	ADD LEGEND DATA 'TRBIT->QTDE == TRBIT->QTDEATEN .AND. TRBIT->MSBLQL <> "1" .AND. TRBIT->PRCVEN > 0'  COLOR "GREEN" TITLE "Atendimento Total"      OF oBrowse2
	ADD LEGEND DATA 'TRBIT->QTDE <> TRBIT->QTDEATEN .AND. TRBIT->SALDO > 0 .AND. TRBIT->MSBLQL <> "1" .AND. TRBIT->PRCVEN > 0 ' COLOR "BR_PINK"  TITLE "Atendimento Parcial"  OF oBrowse2
	ADD LEGEND DATA 'TRBIT->SALDO == 0 .AND. TRBIT->MSBLQL <> "1" ' COLOR "BR_PRETO"  TITLE "Não Atendido"  OF oBrowse2
	ADD LEGEND DATA 'TRBIT->MSBLQL == "1" ' COLOR "BR_VERMELHO"  TITLE "Produto Bloqueado"  OF oBrowse2
	ADD LEGEND DATA 'TRBIT->PRCVEN == 0 ' COLOR "BR_AZUL"  TITLE "Produto sem Preço"  OF oBrowse2

	//	AADD(aCampos,{"OK"			,"","Gerar"     		,"@!"  		})
	//AADD(aCampos,{"OK"      ,""       ,"@!"  		})
	AADD(aCampos,{"CODPRO"      ,"Produto"       ,"@!"  		})
	AADD(aCampos,{"DESCAUX"	    ,"Descrição                          "          	,"@!"	    })
	AADD(aCampos,{"QTDE"	    ,"Qtde Original"	        ,"999999.99"		})
	AADD(aCampos,{"SALDO"	    ,"Saldo Disp."	            ,"999999.99"		})
	AADD(aCampos,{"QTDEATEN"	    ,"Qtde Atendida"	        ,"999999.99"		})
	AADD(aCampos,{"LOCPAD"		,"Armazem       " ,"@!"		})

	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos )
		ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2] PICTURE aCampos[nI][3] Of oBrowse2
	Next

	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------

	Activate FWBrowse oBrowse2

	aButton := { { "Importar"   , { || Processa(Processar()),oDlg2:End() }, "Importar" ,"Importar"   }}
	//                  { "RELATORIO", { || fRel() }, "Imprimir","Imprimir" }}

	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| nOpca := 1,oDlg2:End()},{|| nOpca := 2,oDlg2:End()},,aButton)

	RestArea( aArea )

Return()

Static Function Processar()

	IF MsgYesNo("Deseja gerar pedidos para os itens selecionados?","Atenção!")
		Processa(Importa01())

		Processa(Importa02S())

		Processa(Importa02F())

		Processa(AtuRup())

		MSGBOX("Pedido importado com sucesso.!","Importa Pedido","INFO")

	EndIf
Return()

Static Function AtuBrowIni()		//Atualizo browse inicial
	CriaTabT()
	Carga()
	oBrowse:Refresh()
	oBrowse:GoTop(.t.)
Return()

Static Function MarkOnOff()
	//Local nEntid		:= Val(oTree:aNodes[Val(oTree:CurrentNodeId)][2])-1
	//Local cQuery		:= ""
	//Local lMarca		:= (aAliasOri[__nTmpOri])->MARCA
	//Local nRecno		:= (aAliasOri[__nTmpOri])->(Recno())
	//Default lAll		:= .F.

	dbSelectArea("TRBIT")
	Reclock("TRBIT",.f.)
	Do Case
		Case TRBIT->OK == .T.  .and. TRBIT->SALDO <> 0 .AND. TRBIT->MSBLQL <> "1" .AND. TRBIT->PRCVEN > 0
		TRBIT->OK := .F.
		Case TRBIT->OK ==.F. .AND. TRBIT->SALDO <> 0 .AND. TRBIT->MSBLQL <> "1" .AND. TRBIT->PRCVEN > 0
		TRBIT->OK := .T.
	EndCase
	MsUnlock()

	//oBrwWin01:Refresh()
	//oBrowse2:Refresh()

	//ADD MARKCOLUMN   oColumn DATA { || Iif(( aAliasOri[__nTmpOri] )->MARCA ,'LBOK', 'LBNO' ) } DOUBLECLICK { |oBrwWin01| MarkOnOff(),FiltraDestino() } HEADERCLICK bMarkAll OF oBrwWin01

Return

Static Function MarkAll()

	dbSelectArea("TRBIT")
	dbgotop()
	do While !eof()

		Reclock("TRBIT",.f.)
		Do Case
			Case !lTodos .and. TRBIT->SALDO <> 0 .AND. TRBIT->MSBLQL <> "1" .AND. TRBIT->PRCVEN > 0
			TRBIT->OK := .T.
			Case lTodos .and. TRBIT->SALDO <> 0 .AND. TRBIT->MSBLQL <> "1".AND. TRBIT->PRCVEN > 0
			TRBIT->OK := .F.
		EndCase

		MsUnlock()
		TRBIT->(dbSkip())
	EndDo

	If lTodos
		lTodos := .F.
	else
		lTodos := .T.
	EndIf

Return()

Static Function Importa01()

	//Verifico se possui algum item marcado do armazem 01 para importacao
	lTItem :=  .f.
	nContIt := 1
	aCab := {}
	aItens := {}

	ProcRegua(1)
	IncProc("Analisando armazém 01,aguarde...")

	dbSelectArea("SA1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SA1")+TELA->CLIENTE+TELA->LOJA)
		alert("nao encontrou cliente")
	EndIf

	Aadd(aCab,{"C5_FILIAL"	, xFilial("SC5")	  									,Nil})
	Aadd(aCab,{"C5_TIPO"	, "N"                                		   	   		,Nil})
	Aadd(aCab,{"C5_CLIENTE"	, SA1->A1_COD 					    		  			,Nil})
	Aadd(aCab,{"C5_LOJACLI"	, SA1->A1_LOJA                      		   	 		,Nil})
	Aadd(aCab,{"C5_LOJAENT"	, SA1->A1_LOJA                      		   			,Nil})
	Aadd(aCab,{"C5_TIPOCLI"	, SA1->A1_TIPO                      			  		,Nil})
	Aadd(aCab,{"C5_EMISSAO"	, dDataBase    						   		   	   		,Nil})
	Aadd(aCab,{"C5_MOEDA"	, 1                                 			  		,Nil})
	Aadd(aCab,{"C5_CONDPAG"	, "002" 			  		   			   				,Nil})
	Aadd(aCab,{"C5_TABELA"	, "001"                                 				,Nil})
	//		Aadd(aCab,{"C5_MENNOTA"	, AllTrim((xAlias)->OBS1) + AllTrim((xAlias)->OBS2)	,Nil})
	//		Aadd(aCab,{"C5_MENNOT2"	, AllTrim((xAlias)->OBS3) + AllTrim((xAlias)->OBS4)	,NIL})
	Aadd(aCab,{"C5_TRANSP"	, SA1->A1_TRANSP                    				 	,Nil})
	Aadd(aCab,{"C5_VEND1  "	, SA1->A1_VEND                               		,Nil})
	Aadd(aCab,{"C5_IMPORTA" ,"P"                                  		   			,Nil})
	Aadd(aCab,{"C5_TPCARGA" ,"2"                                  		   			,Nil})

	__i := 1
	TrabSeq()
	dbSelectArea("TRBIT")
	dbGoTop()
	do While !eof()
		If TRBIT->OK .and. TRBIT->LOCPAD == "01" //Importo se estiver marcado
			DbSelectArea("SB1")
			DbSetOrder(1)
			If MsSeek(xFilial("SB1")+TRBIT->CODPRO)

				DbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+SB1->B1_TS)

					cCFO := SF4->F4_CF
					cTES := SF4->F4_CODIGO

					cNumItem := StrZero( Val(Soma1(cValToChar(__i))) , 2 )

					aItAux := {}

					AAdd(aItAux,{"C6_FILIAL"      ,xFilial("SC6")              		,Nil})
					AAdd(aItAux,{"C6_ITEM"        ,cNumItem				     		,Nil})
					AAdd(aItAux,{"C6_PRODUTO"     ,SB1->B1_COD                   	,Nil})
					AAdd(aItAux,{"C6_DESCRI"      ,SB1->B1_DESC             	  	,Nil})
					AAdd(aItAux,{"C6_UM"       	  ,SB1->B1_UM               	  	,Nil})
					AAdd(aItAux,{"C6_QTDVEN"      ,TRBIT->QTDEATEN            		,Nil})
					AAdd(aItAux,{"C6_PRCVEN"      ,TRBIT->PRCVEN	,Nil})
					//					AAdd(aItAux,{"C6_QTDLIB"      ,(cAliasItem)->QUANTIDADE			,Nil})
					AAdd(aItAux,{"C6_TES"         ,cTes                   	  		,Nil})
					AAdd(aItAux,{"C6_LOCAL"       ,SB1->B1_LOCPAD          	  		,Nil})
					AAdd(aItAux,{"C6_CF"       	  ,cCfo                   	  		,Nil})
					AAdd(aItAux,{"C6_CLI"         ,SA1->A1_COD	       	  		,Nil})
					AAdd(aItAux,{"C6_ENTREG"      ,dDataBase              	  		,Nil})
					AAdd(aItAux,{"C6_PRUNIT"      ,TRBIT->PRCVEN  		,Nil})
					AAdd(aItAux,{"C6_CLASFIS"     ,Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB, Nil})
					AAdd(aItAux,{"C6_TURNO"       ,""                     	  		,Nil})

				Else
					MSGInfo("TES: "+SB1->B1_TS+" nao encontrada.", "Importação de pedidos")
				EndIf

			Else
				MSGInfo("Produto: "+ TRBIT->CODPRO +" nao encontrado.", "Importação de pedidos")
			EndIf

			nContIt += 1 //soma itens
			__i     += 1
			aAdd (aItens, aItAux)

			dbSelectArea("TRBSEQ")
			RecLock("TRBSEQ",.T.)
			TRBSEQ->SEQUEN  := TRBIT->SEQUEN
			TRBSEQ->QTDATEN := TRBIT->QTDEATEN
			MsUnlock()

			If nContIt > 60 //se passou de 60 quebro em um pedido
				If !Empty(aCab) .And. !Empty(aItens)

					lMsErroAuto := .F.

					MsExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,3)

					If lMsErroAuto
						MostraErro()
						MSGInfo("O pedido esta com problemas.", "Importação de pedidos")
					EndIf

					If	!lMsErroAuto

						if __lSX8
							ConFirmSX8()
						Endif

						AtuPed()
						TrabSeq()
					EndIf

					__i     := 1
					nContIt := 1
					aItens  := {}

				Endif
			EndIf
		EndIf

		dbSelectArea("TRBIT")
		TRBIT->(dbSkip())
	EndDo

	If !Empty(aCab) .And. !Empty(aItens)

		lMsErroAuto := .F.

		MsExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,3)

		If lMsErroAuto
			MostraErro()
			MSGInfo("O pedido esta com problemas.", "Importação de pedidos")
		EndIf

		If	!lMsErroAuto

			if __lSX8
				ConFirmSX8()
			Endif

			AtuPed()
			TrabSeq()
		EndIf

		aItens:= {}

	Endif

Return()

Static Function Importa02S()

	//Verifico se possui algum item marcado do armazem 01 para importacao
	lTItem :=  .f.
	nContIt := 1
	aCab := {}
	aItens := {}

	ProcRegua(1)
	IncProc("Analisando armazém 02 (CARGA SECA),aguarde...")

	dbSelectArea("SA1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SA1")+TELA->CLIENTE+TELA->LOJA)
		alert("nao encontrou cliente")
	EndIf

	Aadd(aCab,{"C5_FILIAL"	, xFilial("SC5")	  									,Nil})
	Aadd(aCab,{"C5_TIPO"	, "N"                                		   	   		,Nil})
	Aadd(aCab,{"C5_CLIENTE"	, SA1->A1_COD 					    		  			,Nil})
	Aadd(aCab,{"C5_LOJACLI"	, SA1->A1_LOJA                      		   	 		,Nil})
	Aadd(aCab,{"C5_LOJAENT"	, SA1->A1_LOJA                      		   			,Nil})
	Aadd(aCab,{"C5_TIPOCLI"	, SA1->A1_TIPO                      			  		,Nil})
	Aadd(aCab,{"C5_EMISSAO"	, dDataBase    						   		   	   		,Nil})
	Aadd(aCab,{"C5_MOEDA"	, 1                                 			  		,Nil})
	Aadd(aCab,{"C5_CONDPAG"	, "002" 			  		   			   				,Nil})
	Aadd(aCab,{"C5_TABELA"	, "001"                                 				,Nil})
	//		Aadd(aCab,{"C5_MENNOTA"	, AllTrim((xAlias)->OBS1) + AllTrim((xAlias)->OBS2)	,Nil})
	//		Aadd(aCab,{"C5_MENNOT2"	, AllTrim((xAlias)->OBS3) + AllTrim((xAlias)->OBS4)	,NIL})
	Aadd(aCab,{"C5_TRANSP"	, SA1->A1_TRANSP                    				 	,Nil})
	Aadd(aCab,{"C5_VEND1  "	, SA1->A1_VEND                                   		,Nil})
	Aadd(aCab,{"C5_IMPORTA" ,"P"                                  		   			,Nil})
	Aadd(aCab,{"C5_TPCARGA" ,"1"                                  		   			,Nil})

	__i := 1
	aSequen := {}
	TrabSeq()
	dbSelectArea("TRBIT")
	dbGoTop()
	do While !eof()
		If TRBIT->OK .and. TRBIT->LOCPAD == "02" .AND. TRBIT->TIPCAR <> "02" //Importo se estiver marcado
			DbSelectArea("SB1")
			DbSetOrder(1)
			If MsSeek(xFilial("SB1")+TRBIT->CODPRO)

				DbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+SB1->B1_TS)

					cCFO := SF4->F4_CF
					cTES := SF4->F4_CODIGO

					cNumItem := StrZero( Val(Soma1(cValToChar(__i))) , 2 )

					aItAux  := {}
					aSeqAux := {}

					AAdd(aItAux,{"C6_FILIAL"      ,xFilial("SC6")              		,Nil})
					AAdd(aItAux,{"C6_ITEM"        ,cNumItem				     		,Nil})
					AAdd(aItAux,{"C6_PRODUTO"     ,SB1->B1_COD                   	,Nil})
					AAdd(aItAux,{"C6_DESCRI"      ,SB1->B1_DESC             	  	,Nil})
					AAdd(aItAux,{"C6_UM"       	  ,SB1->B1_UM               	  	,Nil})
					AAdd(aItAux,{"C6_QTDVEN"      ,TRBIT->QTDEATEN            		,Nil})
					AAdd(aItAux,{"C6_PRCVEN"      ,TRBIT->PRCVEN	,Nil})
					//					AAdd(aItAux,{"C6_QTDLIB"      ,(cAliasItem)->QUANTIDADE			,Nil})
					AAdd(aItAux,{"C6_TES"         ,cTes                   	  		,Nil})
					AAdd(aItAux,{"C6_LOCAL"       ,SB1->B1_LOCPAD          	  		,Nil})
					AAdd(aItAux,{"C6_CF"       	  ,cCfo                   	  		,Nil})
					AAdd(aItAux,{"C6_CLI"         ,SA1->A1_COD	       	  		,Nil})
					AAdd(aItAux,{"C6_ENTREG"      ,dDataBase              	  		,Nil})
					AAdd(aItAux,{"C6_PRUNIT"      ,TRBIT->PRCVEN  		,Nil})
					AAdd(aItAux,{"C6_CLASFIS"     ,Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB, Nil})
					AAdd(aItAux,{"C6_TURNO"       ,""                     	  		,Nil})

				Else
					MSGInfo("TES: "+SB1->B1_TS+" nao encontrada.", "Importação de pedidos")
				EndIf

			Else
				MSGInfo("Produto: "+ TRBIT->CODPRO +" nao encontrado.", "Importação de pedidos")
			EndIf

			nContIt += 1 //soma itens
			__i     += 1
			aAdd (aItens, aItAux)

			dbSelectArea("TRBSEQ")
			RecLock("TRBSEQ",.T.)
			TRBSEQ->SEQUEN  := TRBIT->SEQUEN
			TRBSEQ->QTDATEN := TRBIT->QTDEATEN
			MsUnlock()

			If nContIt > 60 //se passou de 60 quebro em um pedido
				If !Empty(aCab) .And. !Empty(aItens)

					lMsErroAuto := .F.

					MsExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,3)

					If lMsErroAuto
						MostraErro()
						MSGInfo("O pedido esta com problemas.", "Importação de pedidos")
					EndIf

					If	!lMsErroAuto

						if __lSX8
							ConFirmSX8()

						Endif

						AtuPed()
						TrabSeq()
					EndIf

					__i     := 1
					nContIt := 1
					aItens  := {}

				Endif
			EndIf
		EndIf

		dbSelectArea("TRBIT")
		TRBIT->(dbSkip())
	EndDo

	If !Empty(aCab) .And. !Empty(aItens)

		lMsErroAuto := .F.

		MsExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,3)

		If lMsErroAuto
			MostraErro()
			MSGInfo("O pedido esta com problemas.", "Importação de pedidos")
		EndIf

		If	!lMsErroAuto

			if __lSX8
				ConFirmSX8()
			Endif

			AtuPed()
			TrabSeq()

		EndIf

		aItens:= {}

	Endif

Return()

Static Function Importa02F()

	//Verifico se possui algum item marcado do armazem 01 para importacao
	lTItem :=  .f.
	nContIt := 1
	aCab := {}
	aItens := {}

	ProcRegua(1)
	IncProc("Analisando armazém 02 (CARGA FRIOS) ,aguarde...")

	dbSelectArea("SA1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SA1")+TELA->CLIENTE+TELA->LOJA)
		alert("nao encontrou cliente")
	EndIf

	Aadd(aCab,{"C5_FILIAL"	, xFilial("SC5")	  									,Nil})
	Aadd(aCab,{"C5_TIPO"	, "N"                                		   	   		,Nil})
	Aadd(aCab,{"C5_CLIENTE"	, SA1->A1_COD 					    		  			,Nil})
	Aadd(aCab,{"C5_LOJACLI"	, SA1->A1_LOJA                      		   	 		,Nil})
	Aadd(aCab,{"C5_LOJAENT"	, SA1->A1_LOJA                      		   			,Nil})
	Aadd(aCab,{"C5_TIPOCLI"	, SA1->A1_TIPO                      			  		,Nil})
	Aadd(aCab,{"C5_EMISSAO"	, dDataBase    						   		   	   		,Nil})
	Aadd(aCab,{"C5_MOEDA"	, 1                                 			  		,Nil})
	Aadd(aCab,{"C5_CONDPAG"	, "002" 			  		   			   				,Nil})
	Aadd(aCab,{"C5_TABELA"	, "001"                                 				,Nil})
	//		Aadd(aCab,{"C5_MENNOTA"	, AllTrim((xAlias)->OBS1) + AllTrim((xAlias)->OBS2)	,Nil})
	//		Aadd(aCab,{"C5_MENNOT2"	, AllTrim((xAlias)->OBS3) + AllTrim((xAlias)->OBS4)	,NIL})
	Aadd(aCab,{"C5_TRANSP"	, SA1->A1_TRANSP                    				 	,Nil})
	Aadd(aCab,{"C5_VEND1  "	, SA1->A1_VEND                                   		,Nil})
	Aadd(aCab,{"C5_IMPORTA" ,"P"                                  		   			,Nil})
	Aadd(aCab,{"C5_TPCARGA" ,"1"                                  		   			,Nil})

	__i := 1
	aSequen := {}
	TrabSeq()
	dbSelectArea("TRBIT")
	dbGoTop()
	do While !eof()
		If TRBIT->OK .and. TRBIT->LOCPAD == "02" .AND. TRBIT->TIPCAR == "02" //Importo se estiver marcado
			DbSelectArea("SB1")
			DbSetOrder(1)
			If MsSeek(xFilial("SB1")+TRBIT->CODPRO)

				DbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+SB1->B1_TS)

					cCFO := SF4->F4_CF
					cTES := SF4->F4_CODIGO

					cNumItem := StrZero( Val(Soma1(cValToChar(__i))) , 2 )

					aItAux := {}

					AAdd(aItAux,{"C6_FILIAL"      ,xFilial("SC6")              		,Nil})
					AAdd(aItAux,{"C6_ITEM"        ,cNumItem				     		,Nil})
					AAdd(aItAux,{"C6_PRODUTO"     ,SB1->B1_COD                   	,Nil})
					AAdd(aItAux,{"C6_DESCRI"      ,SB1->B1_DESC             	  	,Nil})
					AAdd(aItAux,{"C6_UM"       	  ,SB1->B1_UM               	  	,Nil})
					AAdd(aItAux,{"C6_QTDVEN"      ,TRBIT->QTDEATEN             		,Nil})
					AAdd(aItAux,{"C6_PRCVEN"      ,TRBIT->PRCVEN	,Nil})
					//					AAdd(aItAux,{"C6_QTDLIB"      ,(cAliasItem)->QUANTIDADE			,Nil})
					AAdd(aItAux,{"C6_TES"         ,cTes                   	  		,Nil})
					AAdd(aItAux,{"C6_LOCAL"       ,SB1->B1_LOCPAD          	  		,Nil})
					AAdd(aItAux,{"C6_CF"       	  ,cCfo                   	  		,Nil})
					AAdd(aItAux,{"C6_CLI"         ,SA1->A1_COD	       	  		,Nil})
					AAdd(aItAux,{"C6_ENTREG"      ,dDataBase              	  		,Nil})
					AAdd(aItAux,{"C6_PRUNIT"      ,TRBIT->PRCVEN  		,Nil})
					AAdd(aItAux,{"C6_CLASFIS"     ,Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB, Nil})
					AAdd(aItAux,{"C6_TURNO"       ,""                     	  		,Nil})

				Else
					MSGInfo("TES: "+SB1->B1_TS+" nao encontrada.", "Importação de pedidos")
				EndIf

			Else
				MSGInfo("Produto: "+ TRBIT->CODPRO +" nao encontrado.", "Importação de pedidos")
			EndIf

			nContIt += 1 //soma itens
			__i     += 1
			aAdd (aItens, aItAux)

			dbSelectArea("TRBSEQ")
			RecLock("TRBSEQ",.T.)
			TRBSEQ->SEQUEN  := TRBIT->SEQUEN
			TRBSEQ->QTDATEN := TRBIT->QTDEATEN
			MsUnlock()

			If nContIt > 60 //se passou de 60 quebro em um pedido
				If !Empty(aCab) .And. !Empty(aItens)

					lMsErroAuto := .F.

					MsExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,3)

					If lMsErroAuto
						MostraErro()
						MSGInfo("O pedido esta com problemas.", "Importação de pedidos")
					EndIf

					If	!lMsErroAuto

						if __lSX8
							ConFirmSX8()
						Endif

						AtuPed()
						TrabSeq()
					EndIf

					__i     := 1
					nContIt := 1
					aItens  := {}

				Endif
			EndIf
		EndIf

		dbSelectArea("TRBIT")
		TRBIT->(dbSkip())
	EndDo

	If !Empty(aCab) .And. !Empty(aItens)

		lMsErroAuto := .F.

		MsExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,3)

		If lMsErroAuto
			MostraErro()
			MSGInfo("O pedido esta com problemas.", "Importação de pedidos")
		EndIf

		If	!lMsErroAuto

			if __lSX8
				ConFirmSX8()
			Endif

			AtuPed()
			TrabSeq()

		EndIf

		aItens:= {}

	Endif

Return()

Static Function TrabSeq()

	aCampos := {}

	AADD(aCampos,{"SEQUEN"    ,"N",10,0} )
	AADD(aCampos,{"QTDATEN"   ,"N",14 ,2 } )

	If Select("TRBSEQ") <> 0
		dbSelectArea("TRBSEQ")
		dbCloseArea()
	Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"TRBSEQ",.T.,.F.)
Return()

Static Function AtuRup()

	ProcRegua(1)
	IncProc("Analisando Ruptura,aguarde...")

	dbSelectArea("TRBIT")
	dbgotop()
	Do while !eof()
		If TRBIT->QTDEATEN == 0

			dbSelectArea("SA1")
			dbSetOrder(1)
			If !dbSeek(xFilial("SA1")+TELA->CLIENTE+TELA->LOJA)
				alert("nao encontrou cliente")
			EndIf

			cQuery := ""
			cQuery := "UPDATE PEDPOSTO2 "
			cQuery += "SET CLIENTE = '" + SA1->A1_COD + "', "
			cQuery += "    LOJA    = '" + SA1->A1_LOJA  + "', "
			cQuery += "    NOMECLI = '" + SA1->A1_NOME  + "', "
			cQuery += "    DATA_IMP = CONVERT(VARCHAR(10),GETDATE(),120), "
			cQuery += "    HORA_IMP = CONVERT(VARCHAR(08),GETDATE(),114),
			cQuery += "    QTDE_ATEN = " + STR(TRBIT->QTDEATEN) + ", "
			cQuery += "    RUPTURA    = 'S', "
			cQuery += " USUARIO = '" + cUserName + "' "
			cQuery += "WHERE SEQUENCIA = " + STR(TRBIT->SEQUEN)

			TcSqlExec(cQuery)
		EndIf

		dbSelectArea("TRBIT")
		TRBIT->(dbskip())
	EndDo

Return()

Static Function AtuPed()

	dbSelectArea("TRBSEQ")
	dbgotop()
	Do while !eof()

		dbSelectArea("SA1")
		dbSetOrder(1)
		If !dbSeek(xFilial("SA1")+TELA->CLIENTE+TELA->LOJA)
			alert("nao encontrou cliente")
		EndIf

		cQuery := ""
		cQuery := "UPDATE PEDPOSTO2 "
		cQuery += "SET CLIENTE = '" + SA1->A1_COD + "', "
		cQuery += "    LOJA    = '" + SA1->A1_LOJA  + "', "
		cQuery += "    NOMECLI = '" + SA1->A1_NOME  + "', "
		cQuery += "    DATA_IMP = CONVERT(VARCHAR(10),GETDATE(),120), "
		cQuery += "    HORA_IMP = CONVERT(VARCHAR(08),GETDATE(),114),
		cQuery += "    QTDE_ATEN = " + STR(TRBSEQ->QTDATEN) + ", "
		cQuery += "    PEDIDO    = '" + SC5->C5_NUM + "', "
		If TRBSEQ->QTDATEN == 0
			cQuery += "    RUPTURA    = 'S', "
		Else
			cQuery += "    RUPTURA    = 'N', "
		EndIf
		cQuery += " USUARIO = '" + cUserName + "' "
		cQuery += "WHERE SEQUENCIA = " + STR(TRBSEQ->SEQUEN)

		TcSqlExec(cQuery)

		dbSelectArea("TRBSEQ")
		TRBSEQ->(dbskip())
	EndDo

Return()

Static Function Residuo()

	IF MsgYesNo("Deseja eliminar residuo do pedido selecionado?","Atenção!")
		cQuery := ""
		cQuery := " DELETE FROM PEDPOSTO2 WHERE DATA_IMP IS NULL AND "
		cQuery += " CNPJ = " + ALLTRIM(TELA->CNPJ)

		TcSqlExec(cQuery)

		MSGBOX("Residuo eliminado com sucesso.!","Eliminar Residuos","INFO")
	EndIf
Return()