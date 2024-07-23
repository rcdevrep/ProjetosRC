#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} XAG0038
- Lê informações de pedido dos postos (ZDC e ZDD) e gera pedido de venda do Protheus (SC5/SC6)
@author Leandro F Silveira
@since 17/08/2018
@return sem retorno
@type function
/*/
User Function XAG0038()

	Private oTmpTable := Nil
	Private _cAliasTrb := ""

	If CriarPerguntas()
		oTmpTable  := CriarTRB()
		_cAliasTrb := oTmpTable:GetAlias()

		MsgRun("Carregando dados","Processando...",{|| CarPed() })
		CriarBrowse()

		(_cAliasTrb)->(DbCloseArea())
		oTmpTable:Delete()
		FreeObj(oTmpTable)
	EndIf

Return()

Static Function CriarPerguntas()

	Local aRegistros := {}
	Local cPerg      := "XAG0038"

	AADD(aRegistros,{cPerg,"01","Nr Ped Posto De  ?","mv_ch1","C",6 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Nr Ped Posto Ate ?","mv_ch2","C",6 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Data Emissão De  ?","mv_ch3","D",8 ,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Data Emissão Até ?","mv_ch4","D",8 ,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Loja De          ?","mv_ch5","C",2 ,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Loja Ate         ?","mv_ch6","C",2 ,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Carregar Abertos ?","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Carregar Baixados?","mv_ch8","N",01,0,0,"C","","mv_par08","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Carregar Cancel. ?","mv_ch9","N",01,0,0,"C","","mv_par09","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Carregar Gerados ?","mv_chA","N",01,0,0,"C","","mv_par10","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"11","Nr Pedido Agricop?","mv_chB","C",6 ,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Armazém          ?","mv_chC","C",2 ,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg, aRegistros)

Return Pergunte(cPerg, .T.)

Static Function CriarTRB()

	Local _aCampos  := {}
	Local _aTamSX3  := {}
	Local oTmpTable := Nil

	_aTamSX3 := TamSX3("A1_NOME")
	AADD(_aCampos,{"NOMEPOSTO", "C", _aTamSX3[1], _aTamSX3[2]})

	AADD(_aCampos,{"ZDC_NUM"     , "C", 10, 0})
	AADD(_aCampos,{"NUMSC5"      , "C",100, 0})
	AADD(_aCampos,{"ZDC_STATUS"  , "C",  1, 0})
	AADD(_aCampos,{"ZDC_DTEMIS"  , "D",  8, 0})
	AADD(_aCampos,{"ZDC_HREMIS"  , "C",  5, 0})
	AADD(_aCampos,{"ZDC_DTBAIX"  , "D",  8, 0})
	AADD(_aCampos,{"ZDC_DTCANC"  , "D",  8, 0})
	AADD(_aCampos,{"QTDE_ITENS"  , "N", 15, 0})

	_aTamSX3 := TamSX3("A1_COD")
	AADD(_aCampos,{"CDPOSTO", "C", _aTamSX3[1], _aTamSX3[2]})

	_aTamSX3 := TamSX3("A1_LOJA")
	AADD(_aCampos,{"LOJAPOSTO", "C", _aTamSX3[1], _aTamSX3[2]})

	AADD(_aCampos,{"ARMAZEM"  , "C", 30, 0})

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(_aCampos)
	oTmpTable:AddIndex("1", {"ZDC_NUM"})
	oTmpTable:Create()

Return(oTmpTable)

Static Function LimparTRB()

	Local cQuery := ""

	cQuery := " DELETE FROM " + oTmpTable:GetRealName()

	If TCSqlExec(cQuery) < 0
		Alert(TCSqlError(), "Falha ao carregar dados")
	EndIf

	(oTmpTable:GetAlias())->(DBGoTop())

Return()

Static Function CarPed()

	Local _cAliasQry := GetNextalias()
	Local _cQuery    := ""
	Local _cFiltStat := ""

	_cQuery += " SELECT "
	_cQuery += "   ZDC.ZDC_NUM, "
	_cQuery += "   ZDC.ZDC_STATUS, "
	_cQuery += "   ZDC.ZDC_DTEMIS, "
	_cQuery += "   ZDC.ZDC_HREMIS, "
	_cQuery += "   ZDC.ZDC_DTBAIX, "
	_cQuery += "   ZDC.ZDC_DTCANC, "

	_cQuery += "   COALESCE((SELECT COUNT(ZDD.R_E_C_N_O_) "
	_cQuery += "             FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
	_cQuery += "             WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
	_cQuery += "             AND   ZDD.ZDD_FILIAL = ZDC.ZDC_FILIAL "
	_cQuery += "             AND   ZDD.D_E_L_E_T_ = '') "
	_cQuery += "   , 0) AS QTDE_ITENS, "

	_cQuery += "   CAST(COALESCE(STUFF((SELECT DISTINCT(' / ' + ZDD.ZDD_NUMSC5) "
	_cQuery += "                        FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
	_cQuery += "                        WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
	_cQuery += "                        AND   ZDD.ZDD_FILIAL = ZDC.ZDC_FILIAL "
	_cQuery += "                        AND   ZDD.D_E_L_E_T_ = '' "
	_cQuery += "                        AND   COALESCE(ZDD.ZDD_NUMSC5, '') != '' "
	_cQuery += "                 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, '') "
	_cQuery += "   ,'') AS VARCHAR(60)) AS NUMSC5, "

	_cQuery += "   CAST(COALESCE(STUFF((SELECT DISTINCT(' / ' + SB1.B1_LOCPAD) "
	_cQuery += "                        FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	_cQuery += "                        WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
	_cQuery += "                        AND   ZDD.ZDD_FILIAL = ZDC.ZDC_FILIAL "
	_cQuery += "                        AND   ZDD.D_E_L_E_T_ = '' "
	_cQuery += "                        AND   SB1.D_E_L_E_T_ = '' "
	_cQuery += "                        AND   SB1.B1_COD = ZDD.ZDD_CODPRT "
	_cQuery += "                        AND   SB1.B1_FILIAL = ZDD.ZDD_FILIAL "
	_cQuery += "                 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, '') "
	_cQuery += "   ,'') AS VARCHAR(60)) AS ARMAZEM, "

	_cQuery += "   SA1.A1_COD, "
	_cQuery += "   SA1.A1_LOJA, "
	_cQuery += "   SA1.A1_NOME "

	_cQuery += " FROM " + RetSqlName("ZDC") + " ZDC (NOLOCK), " + RetSqlName("SA1") + " SA1 (NOLOCK) "
	_cQuery += " WHERE SA1.A1_CGC = ZDC.ZDC_CGC "
	_cQuery += " AND   SA1.A1_POSTOAG = '1' "
	_cQuery += " AND   ZDC.D_E_L_E_T_ = '' "
	_cQuery += " AND   SA1.D_E_L_E_T_ = '' "
	_cQuery += " AND   ZDC.ZDC_FILIAL = '" + xFilial("ZDC") + "'"
	_cQuery += " AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"

	If(!Empty(MV_PAR01) .Or. !Empty(MV_PAR02))
		_cQuery += " AND ZDC.ZDC_NUM BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	EndIf

	If(!Empty(MV_PAR03) .Or. (!Empty(MV_PAR04)))
		_cQuery += " AND ZDC.ZDC_DTEMIS BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "'"
	EndIf

	If(!Empty(MV_PAR05) .Or. (!Empty(MV_PAR06)))
		_cQuery += " AND SA1.A1_LOJA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
	EndIf

	If (!Empty(MV_PAR11))
		_cQuery += " AND EXISTS(SELECT TOP 1 ZDD.ZDD_NUM "
		_cQuery += "            FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
		_cQuery += "            WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
		_cQuery += "            AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
		_cQuery += "            AND   ZDD.D_E_L_E_T_ = '' "
		_cQuery += "            AND   ZDD.ZDD_NUMSC5 = '" + MV_PAR11 + "')"
	Else
		If (MV_PAR07 <> MV_PAR08 .Or. MV_PAR07 <> MV_PAR09 .Or. MV_PAR07 <> MV_PAR10)
			_cQuery += " AND ( "

			If (MV_PAR07 == 1)
				_cFiltStat += " ZDC.ZDC_STATUS = 'A' "
			EndIf

			If (MV_PAR08 == 1)
				_cFiltStat += IIf(Empty(_cFiltStat), "", " OR ")

				_cFiltStat += " (ZDC.ZDC_STATUS = 'B' "
				_cFiltStat += "   AND NOT EXISTS(SELECT TOP 1 ZDD.ZDD_NUM "
				_cFiltStat += "                  FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
				_cFiltStat += "                  WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
				_cFiltStat += "                  AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
				_cFiltStat += "                  AND   ZDD.D_E_L_E_T_ = '' "
				_cFiltStat += "                  AND   ZDD.ZDD_NUMSC5 <> '') "
				_cFiltStat += " ) "
			EndIf

			If (MV_PAR09 == 1)
				_cFiltStat += IIf(Empty(_cFiltStat), "", " OR ")
				_cFiltStat += " ZDC.ZDC_STATUS = 'C' "
			EndIf

			If (MV_PAR10 == 1)
				_cFiltStat += IIf(Empty(_cFiltStat), "", " OR ")
				_cFiltStat += " (ZDC.ZDC_STATUS = 'B' "
				_cFiltStat += "   AND EXISTS(SELECT TOP 1 ZDD.ZDD_NUM "
				_cFiltStat += "              FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
				_cFiltStat += "              WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
				_cFiltStat += "              AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"

				_cFiltStat += "              AND   ZDD.ZDD_NUMSC5 <> '' "
				
				_cFiltStat += "              AND   ZDD.D_E_L_E_T_ = '') "
				_cFiltStat += " ) "
			EndIf

			_cQuery += _cFiltStat

			_cQuery += " ) "
		EndIf	
	EndIf

	If (!Empty(MV_PAR12))
		_cQuery += "  AND EXISTS (SELECT SB1.B1_COD "
		_cQuery += "              FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
		_cQuery += "              WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
		_cQuery += "              AND   ZDD.ZDD_FILIAL = ZDC.ZDC_FILIAL "
		_cQuery += "              AND   ZDD.D_E_L_E_T_ = '' "
		_cQuery += "              AND   SB1.D_E_L_E_T_ = '' "
		_cQuery += "              AND   SB1.B1_COD = ZDD.ZDD_CODPRT "
		_cQuery += "              AND   SB1.B1_FILIAL = ZDD.ZDD_FILIAL "
		_cQuery += "              AND   SB1.B1_LOCPAD = '" + MV_PAR12 + "') "	
	EndIf

	_cQuery += " ORDER BY ZDC.ZDC_NUM "

	LimparTRB()

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	TCSetField((_cAliasQry), "ZDC_DTEMIS" , "D", 08, 0)
	TCSetField((_cAliasQry), "ZDC_DTBAIX" , "D", 08, 0)
	TCSetField((_cAliasQry), "ZDC_DTCANC" , "D", 08, 0)

	While !(_cAliasQry)->(Eof())

		dbSelectArea(_cAliasTrb)
		RecLock(_cAliasTrb, .T.)

		(_cAliasTrb)->NOMEPOSTO      := (_cAliasQry)->A1_NOME
		(_cAliasTrb)->ZDC_NUM        := (_cAliasQry)->ZDC_NUM
		(_cAliasTrb)->ZDC_STATUS     := (_cAliasQry)->ZDC_STATUS
		(_cAliasTrb)->NUMSC5         := (_cAliasQry)->NUMSC5
		(_cAliasTrb)->ZDC_DTEMIS     := (_cAliasQry)->ZDC_DTEMIS
		(_cAliasTrb)->ZDC_HREMIS     := (_cAliasQry)->ZDC_HREMIS
		(_cAliasTrb)->ZDC_DTBAIX     := (_cAliasQry)->ZDC_DTBAIX
		(_cAliasTrb)->ZDC_DTCANC     := (_cAliasQry)->ZDC_DTCANC
		(_cAliasTrb)->QTDE_ITENS     := (_cAliasQry)->QTDE_ITENS
		(_cAliasTrb)->CDPOSTO        := (_cAliasQry)->A1_COD
		(_cAliasTrb)->LOJAPOSTO      := (_cAliasQry)->A1_LOJA
		(_cAliasTrb)->ARMAZEM        := (_cAliasQry)->ARMAZEM

		(_cAliasTrb)->(MsUnLock())

		(_cAliasQry)->(dbSkip())
	End

	(_cAliasQry)->(dbCloseArea())

	(_cAliasTrb)->(DbGoTop())

Return()

Static Function CriarBrowse()

	Local _aTamSX3 := {}
	Local _aCores  := {;
		{"ZDC_STATUS = 'A'"                     ,'BR_AZUL'    } ,;
		{"ZDC_STATUS = 'B' .AND.  EMPTY(NUMSC5)",'BR_VERDE'   } ,;
		{"ZDC_STATUS = 'B' .AND. !EMPTY(NUMSC5)",'BR_VERMELHO'} ,;
		{"ZDC_STATUS = 'C'"                     ,'BR_PRETO'   }}

	Local _aCamposBrw := {}

	Private aRotina := { ;
		{"Legenda"        , "U_XAG038Leg()", 0, 1},;
		{"Listar itens"   , "U_XAG038Ite()", 0, 1},;
		{"Gerar pedido"   , "U_XAG038Ped(" + (_cAliasTrb) + "->ZDC_NUM)", 0, 1},;
		{"Cancelar pedido", "U_XAG038Can(" + (_cAliasTrb) + "->ZDC_NUM)", 0, 1},;
		{"Estornar pedido", "U_XAG038Est(" + (_cAliasTrb) + "->ZDC_NUM)", 0, 1},;
		{"Refresh"        , "U_XAG038Ref()"                             , 0, 1}}

	AADD(_aCamposBrw, {"Cód Ped Posto"       ,"ZDC_NUM"       , "C", 10, 0, ""})
	AADD(_aCamposBrw, {"Data de Emissão"     ,"ZDC_DTEMIS"    , "D", 8,  0, ""})
	AADD(_aCamposBrw, {"Hora de Emissão"     ,"ZDC_HREMIS"    , "C", 5,  0, ""})
	AADD(_aCamposBrw, {"Data de Baixa"       ,"ZDC_DTBAIX"    , "D", 8,  0, ""})
	AADD(_aCamposBrw, {"Data de Cancelamento","ZDC_DTCANC"    , "D", 8,  0, ""})
	AADD(_aCamposBrw, {"Qtde Produtos"       ,"QTDE_ITENS"    , "N", 15, 0, ""})

	_aTamSX3 := TamSX3("A1_COD")
	AADD(_aCamposBrw,{"Cód Cliente Posto", "CDPOSTO", "C", _aTamSX3[1], _aTamSX3[2]})

	_aTamSX3 := TamSX3("A1_LOJA")
	AADD(_aCamposBrw,{"Loja Cliente Posto", "LOJAPOSTO", "C", _aTamSX3[1], _aTamSX3[2]})

	_aTamSX3 := TamSX3("A1_NOME")
	AADD(_aCamposBrw,{"Nome Cliente Posto", "NOMEPOSTO", "C", _aTamSX3[1], _aTamSX3[2]})

	AADD(_aCamposBrw, {"Armazém" ,"ARMAZEM", "C", 30, 0, ""})
	AADD(_aCamposBrw, {"Nr Pedido Agricopel" ,"NUMSC5"        , "C",100, 0, ""})

	mBrowse(6,1,22,75, (_cAliasTrb), _aCamposBrw, Nil, Nil, Nil, 2, _aCores)

Return()

User Function XAG038Leg()

	BrwLegenda("Listagem de Pedidos dos Postos","Legenda",;
		{{"BR_AZUL"      ,"Em digitação no Posto (Aberto)" },;
		{"BR_VERDE"      ,"Pronto para conferir e gerar pedido" },;
		{"BR_VERMELHO"   ,"Gerado"},;
		{"BR_PRETO"      ,"Cancelado" }})

Return(.T.)

Static Function isPedidoAberto(cCdPedido)

	Local _lRet      := .F.
	Local _cQuery    := ""
	Local _cAliasQry := GetNextAlias()

	_cQuery += " SELECT ZDC.ZDC_STATUS, "

	_cQuery += "        COALESCE((SELECT TOP 1 ZDD.ZDD_NUMSC5 "
	_cQuery += "                  FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
	_cQuery += "                  WHERE ZDD.ZDD_NUM = ZDC.ZDC_NUM "
	_cQuery += "                  AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
	_cQuery += "                  AND   ZDD.D_E_L_E_T_ = '' "
	_cQuery += "                  AND   COALESCE(ZDD.ZDD_NUMSC5, '') != '') "
	_cQuery += "        ,'') AS NUMSC5

	_cQuery += " FROM " + RetSqlName("ZDC") + " ZDC (NOLOCK) "
	_cQuery += " WHERE ZDC.ZDC_NUM = '" + AllTrim(cCdPedido) + "'"
	_cQuery += " AND   ZDC.ZDC_FILIAL = '" + xFilial("ZDC") + "'"
	_cQuery += " AND   ZDC.D_E_L_E_T_ = '' "

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	_lRet := (((_cAliasQry)->ZDC_STATUS) == "A") .Or. (((_cAliasQry)->ZDC_STATUS) == "B" .And. Empty((_cAliasQry)->NUMSC5))

	dbSelectArea(_cAliasQry)
	dbCloseArea()

Return(_lRet)

User Function XAG038Can(cCdPedido)

	Local _cQuery := ""

	If (isPedidoAberto(cCdPedido))

		If MsgNoYes("CONFIRMA O CANCELAMENTO DO PEDIDO DO POSTO? [" + AllTrim(cCdPedido) + "]")

			_cQuery += " UPDATE ZDC SET "
			_cQuery += "   ZDC_STATUS = 'C', "
			_cQuery += "   ZDC_DTCANC = " + DtoS(MsDate())
			_cQuery += " FROM " + RetSqlName("ZDC") + " ZDC "
			_cQuery += " WHERE ZDC.ZDC_NUM = '" + AllTrim(cCdPedido) + "'"
			_cQuery += " AND   ZDC.ZDC_FILIAL = '" + xFilial("ZDC") + "'"
			_cQuery += " AND   ZDC.D_E_L_E_T_ = '' "

			If (TCSQLExec(_cQuery) >= 0)
				MsgInfo("CANCELAMENTO EFETUADO COM SUCESSO!")
				MsgRun("Carregando dados","Processando...",{|| CarPed() })
			Else
				MsgStop("TCSQLError() " + TCSQLError())
			EndIf
		EndIf
	Else
		Alert("PEDIDO DE COMPRA DO POSTO NÃO ESTÁ EM ABERTO PARA SER CANCELADO")
	EndIf

Return(.T.)

User Function XAG038Est(cCdPedido)

	Local _cQuery := ""

	If (isPedidoAberto(cCdPedido))

		If MsgNoYes("CONFIRMA O ESTORNO DO PEDIDO DO POSTO? [" + AllTrim(cCdPedido) + "]")

			_cQuery += " UPDATE ZDC SET "
			_cQuery += "   ZDC_STATUS = 'A', "
			_cQuery += "   ZDC_DTBAIX = '' "
			_cQuery += " FROM " + RetSqlName("ZDC") + " ZDC "
			_cQuery += " WHERE ZDC.ZDC_NUM = '" + AllTrim(cCdPedido) + "'"
			_cQuery += " AND   ZDC.ZDC_FILIAL = '" + xFilial("ZDC") + "'"
			_cQuery += " AND   ZDC.D_E_L_E_T_ = '' "

			If (TCSQLExec(_cQuery) >= 0)
				MsgInfo("ESTORNO EFETUADO COM SUCESSO!")
				MsgRun("Carregando dados","Processando...",{|| CarPed() })
			Else
				MsgStop("TCSQLError() " + TCSQLError())
			EndIf
		EndIf
	Else
		Alert("PEDIDO DE COMPRA DO POSTO NÃO ESTÁ BAIXADO E SEM PEDIDO PARA SER ESTORNADO!")
	EndIf

Return(.T.)

User Function XAG038Ped(cCdPedido)

	If MsgNoYes("CONFIRMA A GERAÇÃO DO PEDIDO? [" + AllTrim(cCdPedido) + "]")
		Processa({||GerarPedido(cCdPedido)})
	EndIf

Return(.T.)

Static Function GerarPedido(cCdPedido)

	Local _cAliasPed  := ""
	Local _aItens     := {}
	Local _aSC5       := {}
	Local _aSC5Clone  := {}
	Local _aSC6       := {}
	Local _nLenItens  := 0
	Local _nLoop      := 0
	Local _cSC5s      := ""
	Local nC6_LOCAL   := 0
	Local cC6_LOCAL   := ""
	Local _lOk        := .T.

	ProcRegua(0)
	IncProc()

	_cAliasPed := CarregarPedPosto(cCdPedido)

	If(isGerarSC5OK(_cAliasPed))
		_aSC5   := getSC5(_cAliasPed)
		_aItens := getSC6(_cAliasPed)

		_nLenItens := Len(_aItens)

		If(_nLenItens > 0)

			Begin Transaction
				For _nLoop := 1 To _nLenItens

					_aSC6 := _aItens[_nLoop]
					_aSC5Clone := AClone(_aSC5)

					nC6_LOCAL := aScan(_aSC6[1],{|X| AllTrim(X[1]) == "C6_LOCAL"})
					cC6_LOCAL := AllTrim(_aSC6[1][nC6_LOCAL][2])

					If (cC6_LOCAL == "02")
						Aadd(_aSC5Clone, {"C5_TPCARGA", "1", Nil}) // UTILIZA
						Aadd(_aSC5Clone, {"C5_GERAWMS", "2", Nil}) // NA MONTAGEM DA CARGA
					Else
						Aadd(_aSC5Clone, {"C5_TPCARGA", "2", Nil}) // NÃO UTILIZA
						Aadd(_aSC5Clone, {"C5_GERAWMS", "1", Nil}) // NO PEDIDO
					EndIf

					If (cC6_LOCAL == "01" .Or. cC6_LOCAL == "03" .Or. cC6_LOCAL == "04")
						Aadd(_aSC5Clone, {"C5_TABELA", "002", Nil})
					Else
						Aadd(_aSC5Clone, {"C5_TABELA", "001", Nil})
					EndIf

					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA410(x,y,z)}, _aSC5Clone, _aSC6, 3)

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						_lOk := .F.
						Exit
					EndIf

					If (!BaixarItemPed((_cAliasPed)->ZDC_NUM, SC5->C5_NUM))
						DisarmTransaction()
						_lOk := .F.
						Exit
					EndIf

					_cSC5s += IIf(Empty(_cSC5s), "", " - ") + SC5->C5_NUM

				Next
			End Transaction

			If !(_lOk)
				Return(.F.)
			EndIf

			MsgInfo("Pedido(s) gerados com sucesso! Pedido(s): " + _cSC5s)

			If CriarPerguntas()
				MsgRun("Carregando dados","Processando...",{|| CarPed() })
			Else
				CloseBrowse()
			EndIf
		Else
			Alert("Não há itens para gerar pedido de venda!")
		EndIf
	EndIf

	dbSelectarea(_cAliasPed)
	dbCloseArea()

Return(.T.)

Static Function CarregarPedPosto(cCdPedido)

	Local _cAliasPed := GetNextalias()
	Local _cQuery    := ""

	_cQuery += " SELECT "
	_cQuery += "   ZDC.ZDC_NUM, "
	_cQuery += "   ZDC.ZDC_STATUS, "
	_cQuery += "   ZDC.ZDC_CGC, "
	_cQuery += "   ZDC.ZDC_DTEMIS, "
	_cQuery += "   ZDC.ZDC_HREMIS, "
	_cQuery += "   ZDC.ZDC_DTBAIX, "
	_cQuery += "   ZDC.ZDC_DTCANC, "

	_cQuery += "   SA1.A1_COD, "
	_cQuery += "   SA1.A1_LOJA, "
	_cQuery += "   SA1.A1_LOJA, "
	_cQuery += "   SA1.A1_TIPO, "
	_cQuery += "   SA1.A1_TRANSP, "
	_cQuery += "   SA1.A1_VEND, "
	_cQuery += "   SA1.A1_VEND2 "

	_cQuery += " FROM " + RetSqlName("ZDC") + " ZDC (NOLOCK), " + RetSqlName("SA1") + " SA1 (NOLOCK) "
	_cQuery += " WHERE ZDC.ZDC_NUM = '" + AllTrim(cCdPedido) + "'"
	_cQuery += " AND   ZDC.ZDC_FILIAL = '" + xFilial("ZDC") + "'"
	_cQuery += " AND   SA1.A1_CGC = ZDC.ZDC_CGC "
	_cQuery += " AND   SA1.A1_POSTOAG = '1' "
	_cQuery += " AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	_cQuery += " AND   SA1.D_E_L_E_T_ = '' "
	_cQuery += " AND   ZDC.D_E_L_E_T_ = '' "

	TCQuery _cQuery NEW ALIAS (_cAliasPed)

Return(_cAliasPed)

Static Function isGerarSC5OK(_cAliasPed)

	Local _lOk        := .T.
	Local _cQuery     := ""
	Local _cMsgErro   := "Não foi possível executar a operação."
	Local _cAliasVal  := GetNextAlias()
	Local _cSemProdPr := ""
	Local _cSemCarga  := ""
	Local _cPrecoLub  := ""
	Local _cPrecoCon  := ""

	If !(isPedStatusOk((_cAliasPed)->ZDC_NUM))
		Return(.F.)
	EndIf

	_cQuery := " SELECT ZDD.ZDD_CODATS "
	_cQuery += " FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
	_cQuery += " WHERE ZDD.ZDD_NUM = '" + AllTrim((_cAliasPed)->ZDC_NUM) + "'"
	_cQuery += " AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
	_cQuery += " AND   ZDD.D_E_L_E_T_ = '' "
	_cQuery += " AND   COALESCE(ZDD.ZDD_CODPRT, '') = '' "
	_cQuery += " AND   ZDD.ZDD_NECSC5 > 0 "
	_cQuery += " ORDER BY ZDD.ZDD_CODATS "

	TCQuery _cQuery NEW ALIAS (_cAliasVal)

	While !((_cAliasVal)->(Eof()))
		_cSemProdPr += IIf(_cSemProdPr == "", "", " / ") + (_cAliasVal)->ZDD_CODATS
		(_cAliasVal)->(dbSkip())
	End

	If(AllTrim(_cSemProdPr) <> "")
		_cMsgErro += Chr(13) + Chr(10) + "- Há produtos que não possuem código do Protheus. Cód AutoSystem: " + _cSemProdPr
		_lOk := .F.
	EndIf

	(_cAliasVal)->(dbCloseArea())

	_cQuery := " SELECT ZDD.ZDD_CODPRT "
	_cQuery += " FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	_cQuery += " WHERE ZDD.ZDD_NUM = '" + AllTrim((_cAliasPed)->ZDC_NUM) + "'"
	_cQuery += " AND   SB1.B1_COD = ZDD.ZDD_CODPRT "
	_cQuery += " AND   SB1.B1_LOCPAD = '02' "
	_cQuery += " AND   SB1.B1_TIPCAR = '' "
	_cQuery += " AND   ZDD.ZDD_NECSC5 > 0 "
	_cQuery += " AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	_cQuery += " AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
	_cQuery += " AND   SB1.D_E_L_E_T_ = '' "
	_cQuery += " AND   ZDD.D_E_L_E_T_ = '' "
	_cQuery += " ORDER BY ZDD.ZDD_CODATS "

	TCQuery _cQuery NEW ALIAS (_cAliasVal)

	While !((_cAliasVal)->(Eof()))
		_cSemCarga += IIf(_cSemCarga == "", "", " / ") + (_cAliasVal)->ZDD_CODPRT
		(_cAliasVal)->(dbSkip())
	End

	If(AllTrim(_cSemCarga) <> "")
		_cMsgErro += Chr(13) + Chr(10) + "- Há produtos que são do armazém 2 e não possuem tipo de carga definido (FRIO/SECO). Cód Protheus: " + _cSemCarga
		_lOk := .F.
	EndIf

	(_cAliasVal)->(dbCloseArea())

	_cQuery := " SELECT ZDD.ZDD_CODPRT, "

	_cQuery += "   SB1.B1_LOCPAD,  "

	_cQuery += "   COALESCE((SELECT TOP 1 DA1.DA1_PRCVEN "
	_cQuery += "             FROM " + RetSqlName("DA1") + " DA1 (NOLOCK) "
	_cQuery += "             WHERE DA1.DA1_CODPRO = ZDD.ZDD_CODPRT "
	_cQuery += "             AND DA1.DA1_CODTAB = '001' "
	_cQuery += "             AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "'"
	_cQuery += "             AND DA1.DA1_PRCVEN > 0 "
	_cQuery += "             AND DA1.D_E_L_E_T_ = ''), 0) AS PRECO_001, "

	_cQuery += "   COALESCE((SELECT TOP 1 DA1.DA1_PRCVEN "
	_cQuery += "             FROM " + RetSqlName("DA1") + " DA1 (NOLOCK) "
	_cQuery += "             WHERE DA1.DA1_CODPRO = ZDD.ZDD_CODPRT "
	_cQuery += "             AND DA1.DA1_CODTAB = '002' "
	_cQuery += "             AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "'"
	_cQuery += "             AND DA1.DA1_PRCVEN > 0 "
	_cQuery += "             AND DA1.D_E_L_E_T_ = ''), 0) AS PRECO_002 "

	_cQuery += " FROM  " + RetSqlName("ZDD") + " ZDD (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	_cQuery += " WHERE ZDD.ZDD_NUM = '" + AllTrim((_cAliasPed)->ZDC_NUM)+"' "
	_cQuery += " AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
	_cQuery += " AND   ZDD.D_E_L_E_T_ = '' "
	_cQuery += " AND   ZDD.ZDD_NECSC5 > 0 "
	_cQuery += " AND   SB1.B1_COD = ZDD.ZDD_CODPRT "
	_cQuery += " AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	_cQuery += " AND   SB1.D_E_L_E_T_ = '' "

	_cQuery += " ORDER BY ZDD.ZDD_CODATS "

	TCQuery _cQuery NEW ALIAS (_cAliasVal)

	While !((_cAliasVal)->(Eof()))

		If ((_cAliasVal)->B1_LOCPAD == "01" .Or. (_cAliasVal)->B1_LOCPAD == "03" .Or. (_cAliasVal)->B1_LOCPAD == "04" .Or. (_cAliasVal)->B1_LOCPAD == "20")

			If (Empty((_cAliasVal)->PRECO_002))
				_cPrecoLub += IIf(_cPrecoLub == "", "", " / ") + AllTrim((_cAliasVal)->ZDD_CODPRT)
			EndIf
		Else

			If (Empty((_cAliasVal)->PRECO_001))
				_cPrecoCon += IIf(_cPrecoCon == "", "", " / ") + AllTrim((_cAliasVal)->ZDD_CODPRT)
			EndIf
		EndIf

		(_cAliasVal)->(dbSkip())
	End

	If(!Empty(_cPrecoLub))
		_cMsgErro += Chr(13) + Chr(10) + "- Há produtos dos armazém de Lubs (01/03/04/20) que não possuem preço cadastrado na tabela 002. Cód Protheus: " + _cPrecoLub
		_lOk := .F.
	EndIf

	If(!Empty(_cPrecoCon))
		_cMsgErro += Chr(13) + Chr(10) + "- Há produtos da Conveniência que não possuem preço cadastrado na tabela 001. Cód Protheus: " + _cPrecoCon
		_lOk := .F.
	EndIf

	(_cAliasVal)->(dbCloseArea())

	If(!_lOk)
		Alert(_cMsgErro)
	EndIf

Return(_lOk)

Static Function getSC5(_cAliasPed)

	Local _aSC5  := {}

	Aadd(_aSC5, {"C5_FILIAL"  , xFilial("SC5")          , Nil})
	Aadd(_aSC5, {"C5_TIPO"    , "N"                     , Nil})
	Aadd(_aSC5, {"C5_CLIENTE" , (_cAliasPed)->A1_COD    , Nil})
	Aadd(_aSC5, {"C5_LOJACLI" , (_cAliasPed)->A1_LOJA   , Nil})
	Aadd(_aSC5, {"C5_LOJAENT" , (_cAliasPed)->A1_LOJA   , Nil})
	Aadd(_aSC5, {"C5_TIPOCLI" , (_cAliasPed)->A1_TIPO   , Nil})
	Aadd(_aSC5, {"C5_EMISSAO" , dDataBase               , Nil})
	Aadd(_aSC5, {"C5_MOEDA"   , 1                       , Nil})
	Aadd(_aSC5, {"C5_CONDPAG" , "911"                   , Nil})
	//Aadd(_aSC5, {"C5_TABELA"  , "001"                   , Nil})
	Aadd(_aSC5, {"C5_TRANSP"  , (_cAliasPed)->A1_TRANSP , Nil})
	Aadd(_aSC5, {"C5_VEND1"   , (_cAliasPed)->A1_VEND   , Nil})
	Aadd(_aSC5, {"C5_VEND2"   , (_cAliasPed)->A1_VEND2  , Nil})
	Aadd(_aSC5, {"C5_IMPORTA" , "N"                     , Nil})
	Aadd(_aSC5, {"C5_TIPLIB"  , "1"                     , Nil})
	Aadd(_aSC5, {"C5_X_ORIG"  , "XAG0038"               , Nil})
	Aadd(_aSC5, {"C5_BLQ"     , ""                      , Nil})

Return(_aSC5)

Static Function getSC6(_cAliasPed)

	Local _aItens      := {}
	Local _aSC6        := {}
	Local _aRet        := {}
	Local _cQuery      := ""
	Local _cAliasItPed := GetNextAlias()
	Local _cC6Item     := "00"
	Local _nCount      := 0
	Local _cLocPad     := ""
	Local _cTipCar     := ""
	Local _nC6PrcVen   := 0
	Local _nC6QtdVen   := 0
	Local _nZDQtdNec   := 0
	Local _lPrimeiroIt := .T.
	Local  _cTes       := ""
	Local _cClasFis    := ""

	_cQuery += " SELECT "
	_cQuery += "   SB1.B1_COD, "
	_cQuery += "   SB1.B1_DESC, "
	_cQuery += "   SB1.B1_UM, "
	_cQuery += "   SB1.B1_LOCPAD, "
	_cQuery += "   SB1.B1_TIPCAR, "
	_cQuery += "   SB1.B1_ORIGEM, "
	_cQuery += "   SB1.B1_TIPO, "

	_cQuery += "   SF4.F4_CODIGO, "
	_cQuery += "   SF4.F4_CF, "
	_cQuery += "   SF4.F4_SITTRIB, "

	_cQuery += "   SUBSTRING(SB1.B1_ORIGEM, 1, 1) + SUBSTRING(F4_SITTRIB, 1, 2) AS C6_CLASFIS, "

	_cQuery += "   COALESCE((SELECT SUM(SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QEMP - SB2.B2_QEMPN - SB2.B2_QEMPSA) "
	_cQuery += "             FROM " + RetSqlName("SB2") + " SB2 (NOLOCK) "
	_cQuery += "             WHERE SB2.B2_COD = ZDD.ZDD_CODPRT "
	_cQuery += "	         AND   SB2.B2_LOCAL = SB1.B1_LOCPAD "
	_cQuery += "             AND   SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
	_cQuery += "             AND   SB2.D_E_L_E_T_ = '') "
	_cQuery += "   ,0) "
	_cQuery += "   - "
	_cQuery += "   COALESCE((SELECT SUM(SDA.DA_SALDO) "
	_cQuery += "             FROM " + RetSqlName("SDA") + " SDA (NOLOCK) "
	_cQuery += "             WHERE SDA.DA_PRODUTO = ZDD.ZDD_CODPRT "
	_cQuery += "               AND SDA.DA_FILIAL = '" + xFilial("SDA") + "'"
	_cQuery += "               AND SDA.DA_LOCAL = SB1.B1_LOCPAD "
	_cQuery += "               AND SDA.D_E_L_E_T_ = '') "
	_cQuery += "   ,0) "
	_cQuery += "   AS SALDO_AGR, "

	_cQuery += "   ZDD.ZDD_NUM, "
	_cQuery += "   ZDD.ZDD_NECSC5, "
	_cQuery += "   ZDD.ZDD_CONV,  "

	_cQuery += "   SB1.B1_PROC, "

	_cQuery += "   COALESCE((SELECT TOP 1 DA1.DA1_PRCVEN "
	_cQuery += "   	         FROM " + RetSqlName("DA1") + " DA1 (NOLOCK) "
	_cQuery += "   	         WHERE DA1.DA1_CODPRO = SB1.B1_COD "
	_cQuery += "   	         AND DA1.DA1_CODTAB = '001' "
	_cQuery += "   	         AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "'"
	_cQuery += "   	         AND DA1.D_E_L_E_T_ = '') "
	_cQuery += "   , 0) AS PRECO_001, "

	_cQuery += "   COALESCE((SELECT TOP 1 DA1.DA1_PRCVEN "
	_cQuery += "   	         FROM " + RetSqlName("DA1") + " DA1 (NOLOCK) "
	_cQuery += "   	         WHERE DA1.DA1_CODPRO = SB1.B1_COD "
	_cQuery += "   	         AND DA1.DA1_CODTAB = '002' "
	_cQuery += "   	         AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "'"
	_cQuery += "   	         AND DA1.D_E_L_E_T_ = '') "
	_cQuery += "   , 0) AS PRECO_002, "

	_cQuery += "   COALESCE((SELECT TOP 1 SZ5.Z5_DESCAGR "
	_cQuery += "             FROM " + RetSqlName("SZ5") + "  SZ5 (NOLOCK) "
	_cQuery += "             WHERE SZ5.Z5_FILIAL = '" + xFilial("SZ5") + "'"
	_cQuery += "             AND   SZ5.Z5_MARKUP = SB1.B1_AGMRKP "
	_cQuery += "             AND   SZ5.D_E_L_E_T_ = '') "
	_cQuery += "   ,0) AS Z5_DESCAGR "

	_cQuery += " FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK), " + RetSqlName("SF4") + " SF4 (NOLOCK), "
	_cQuery +=            RetSqlName("SB1") + " SB1 (NOLOCK) "

	_cQuery += " WHERE ZDD.ZDD_NUM = '" + AllTrim((_cAliasPed)->ZDC_NUM) + "'"
	_cQuery += "   AND ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
	_cQuery += "   AND ZDD.D_E_L_E_T_ = '' "
	_cQuery += "   AND SB1.B1_COD = ZDD.ZDD_CODPRT "
	_cQuery += "   AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	_cQuery += "   AND SB1.D_E_L_E_T_ = '' "

	_cQuery += "   AND SF4.F4_CODIGO = SB1.B1_TS "
	_cQuery += "   AND SF4.F4_FILIAL = '" + xFilial("SF4") + "'"
	_cQuery += "   AND SF4.D_E_L_E_T_ = '' "

	_cQuery += "   AND ZDD.ZDD_NECSC5 > 0 "
	_cQuery += "   AND COALESCE(ZDD.ZDD_NUMSC5,'') = '' "

	_cQuery += " ORDER BY SB1.B1_LOCPAD, SB1.B1_TIPCAR, SB1.B1_COD "

	TCQuery _cQuery NEW ALIAS (_cAliasItPed)

	While !((_cAliasItPed)->(Eof()))

		_aSC6      := {}
		_cC6Item   := Soma1(_cC6Item)

		If ((_cAliasItPed)->B1_LOCPAD == "01" .Or. (_cAliasItPed)->B1_LOCPAD == "03" .Or. (_cAliasItPed)->B1_LOCPAD == "04" .Or. (_cAliasItPed)->B1_LOCPAD == "20")
			_nC6PrcVen := (_cAliasItPed)->PRECO_002
		Else
			_nC6PrcVen := (_cAliasItPed)->PRECO_001
		EndIf

		_nZDQtdNec := (_cAliasItPed)->ZDD_NECSC5

		If ((_cAliasItPed)->ZDD_CONV > 0)
			_nZDQtdNec := (_nZDQtdNec / ((_cAliasItPed)->(ZDD_CONV)))
		EndIf

		If ((_cAliasItPed)->SALDO_AGR > _nZDQtdNec)
			_nC6QtdVen := _nZDQtdNec
		Else
			_nC6QtdVen := (_cAliasItPed)->SALDO_AGR
		EndIf

		If (_nC6QtdVen > 0)

			If(_lPrimeiroIt)
				_cLocPad := (_cAliasItPed)->B1_LOCPAD
				_cTipCar := (_cAliasItPed)->B1_TIPCAR
				_lPrimeiroIt := .F.
			EndIf

			If((_nCount >= 60) .Or. (_cLocPad != (_cAliasItPed)->B1_LOCPAD) .Or. (_cTipCar != (_cAliasItPed)->B1_TIPCAR))
				AAdd(_aRet, _aItens)
				_aItens   := {}
				_nCount   := 0
				_cC6Item  := "00"
			EndIf


			If (_cAliasItPed)->B1_TIPO <> 'QR'
				_cTes := (_cAliasItPed)->F4_CODIGO
				_cClasFis := (_cAliasItPed)->C6_CLASFIS
			Else//Busca a TES correta para a Querosene
				_cTes 	  := MaTesInt(2,'01',(_cAliasPed)->A1_COD,(_cAliasPed)->A1_LOJA,"C",(_cAliasItPed)->B1_COD ,NIL,(_cAliasPed)->A1_TIPO)
				_cClasFis := ""
				If Empty(_cTes)
					_cTes := (_cAliasItPed)->F4_CODIGO
					_cClasFis := (_cAliasItPed)->C6_CLASFIS
				Endif

			Endif

			AAdd(_aSC6, {"C6_FILIAL"      , xFilial("SC6")              , Nil})
			AAdd(_aSC6, {"C6_ITEM"        , _cC6Item                    , Nil})
			AAdd(_aSC6, {"C6_PRODUTO"     , (_cAliasItPed)->B1_COD      , Nil})
			AAdd(_aSC6, {"C6_DESCRI"      , (_cAliasItPed)->B1_DESC     , Nil})
			AAdd(_aSC6, {"C6_UM"       	  , (_cAliasItPed)->B1_UM       , Nil})
			AAdd(_aSC6, {"C6_QTDVEN"      , _nC6QtdVen                  , Nil})
			AAdd(_aSC6, {"C6_QTDLIB"      , _nC6QtdVen                  , Nil})
			AAdd(_aSC6, {"C6_PRCVEN"      , _nC6PrcVen                  , Nil})
			AAdd(_aSC6, {"C6_TES"         , _cTes  						, Nil})
			AAdd(_aSC6, {"C6_LOCAL"       , (_cAliasItPed)->B1_LOCPAD   , Nil})
			AAdd(_aSC6, {"C6_CLI"         , (_cAliasPed)->A1_COD        , Nil})
			AAdd(_aSC6, {"C6_ENTREG"      , dDataBase                   , Nil})
			AAdd(_aSC6, {"C6_PRUNIT"      , _nC6PrcVen                  , Nil})
			AAdd(_aSC6, {"C6_TURNO"       , ""                          , Nil})
			AAdd(_aSC6, {"C6_HRCAPTA"     , Time()                      , Nil})

			If !Empty(_cClasFis)
				AAdd(_aSC6, {"C6_CLASFIS"     , _cClasFis					, Nil})
			Endif
			AAdd(_aSC6, {"C6_PRCLIST"     , _nC6PrcVen                  , Nil})

			// Calculo de St para Querosene
			// Calcula o preço de Venda para Querosene = (Preço tabela - Valor de ST)
			If (_cAliasItPed)->B1_TIPO == 'QR'
				AAdd(_aSC6, {"C6_XVLTST"  , Round(_nC6PrcVen * _nC6QtdVen ,2), Nil})
			Endif

			AAdd(_aItens, _aSC6)
			_nCount  += 1

			_cLocPad := (_cAliasItPed)->B1_LOCPAD
			_cTipCar := (_cAliasItPed)->B1_TIPCAR
		EndIf

		(_cAliasItPed)->(dbSkip())
	End

	If(_nCount > 0)
		AAdd(_aRet, _aItens)
	EndIf

	(_cAliasItPed)->(dbCloseArea())
Return(_aRet)

Static Function BaixarItemPed(NumPedPosto, NumSC5)

	Local _cQuery := ""

	_cQuery += " UPDATE ZDD SET "
	_cQuery += "   ZDD_NUMSC5 = SC6.C6_NUM "
	_cQuery += " FROM " + RetSqlName("ZDD") + " ZDD, " + RetSqlName("SC6") + " SC6 (NOLOCK) "
	_cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
	_cQuery += "   AND SC6.C6_NUM = '" + AllTrim(NumSC5) + "'"
	_cQuery += "   AND SC6.D_E_L_E_T_ = '' "
	_cQuery += "   AND SC6.C6_PRODUTO = ZDD.ZDD_CODPRT "
	_cQuery += "   AND COALESCE(ZDD.ZDD_NUMSC5, '') = '' "
	_cQuery += "   AND ZDD.ZDD_NUM = '" + AllTrim(NumPedPosto) + "'"
	_cQuery += "   AND ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
	_cQuery += "   AND ZDD.D_E_L_E_T_ = '' "

	If (TCSQLExec(_cQuery) < 0)
		Alert("Erro ao Baixar Pedido - " + TCSQLError())
		Return(.F.)
	EndIf
Return(.T.)

User Function XAG038Ite()

	Processa({||AbrirItens()})

Return()

Static Function AbrirItens()

	ProcRegua(0)
	IncProc()

	@ 000,000 TO 540, 1200 DIALOG oDlog TITLE "Digitação e conferência dos produtos do Pedido do Posto"

	@ 015,010 Say "Nr Pedido Posto:"
	@ 015,055 Say (_cAliasTrb)->ZDC_NUM

	@ 015,100 Say "Fornecedor:"
	@ 015,135 Say (_cAliasTrb)->NOMEPOSTO

	@ 015,280 Say "Qtde Itens:"
	@ 015,310 Say (_cAliasTrb)->QTDE_ITENS

	@ 015,330 Say "Emissão:"
	@ 015,355 Say DtoC((_cAliasTrb)->ZDC_DTEMIS)

	CarItens()

	oDlog:bInit := {|| EnchoiceBar(oDlog, {||GravarItens() }, {||oDlog:End()},,{} )}

	ACTIVATE DIALOG oDlog CENTERED

Return

Static Function CarItens()

	Local _cQuery      := ""
	Local _cAliasIt    := GetNextAlias()

	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aAlterFields := {"ZDD_NECSC5"}

	Static oMSNewGe1

	_cQuery += " SELECT "
	_cQuery += "   ZDD.ZDD_NUM, "
	_cQuery += "   ZDD.ZDD_CODPRT, "
	_cQuery += "   ZDD.ZDD_CODATS, "
	_cQuery += "   ZDD.ZDD_DESATS, "
	_cQuery += "   ZDD.ZDD_NECEMB, "
	_cQuery += "   ZDD.ZDD_NECDIG, "
	_cQuery += "   ZDD.ZDD_NECSC5, "
	_cQuery += "   ZDD.ZDD_SLDATS, "
	_cQuery += "   ZDD.ZDD_QTDEMB, "
	_cQuery += "   ZDD.ZDD_NUMSC5, "
	_cQuery += "   ZDD.ZDD_CONV, "

	_cQuery += "   CASE WHEN COALESCE(ZDD.ZDD_NUMSC5, '') != '' "
	_cQuery += "     THEN (SELECT TOP 1 SC6.C6_QTDVEN "
	_cQuery += "   	       FROM " + RetSqlName("SC6") + " SC6 (NOLOCK) "
	_cQuery += "   	       WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
	_cQuery += "   	       AND   SC6.C6_NUM = ZDD.ZDD_NUMSC5 "
	_cQuery += "   	       AND   SC6.D_E_L_E_T_ = '' "
	_cQuery += "   	       AND   SC6.C6_PRODUTO = ZDD.ZDD_CODPRT) "
	_cQuery += "     ELSE 0 "
	_cQuery += "   END AS QTDE_SC6, "

	_cQuery += "   COALESCE((SELECT SUM(SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QEMP - SB2.B2_QEMPN - SB2.B2_QEMPSA) "
	_cQuery += "             FROM " + RetSqlName("SB2") + " SB2 (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	_cQuery += "             WHERE SB2.B2_COD = ZDD.ZDD_CODPRT "
	_cQuery += "             AND SB2.B2_LOCAL = SB1.B1_LOCPAD "
	_cQuery += "             AND SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
	_cQuery += "             AND SB1.D_E_L_E_T_ = '' "
	_cQuery += "             AND SB1.B1_COD = ZDD.ZDD_CODPRT "
	_cQuery += "             AND SB1.B1_COD = SB2.B2_COD "
	_cQuery += "             AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	_cQuery += "             AND SB2.D_E_L_E_T_ = '') "
	_cQuery += "   ,0) "
	_cQuery += "   - "
	_cQuery += "   COALESCE((SELECT SUM(SDA.DA_SALDO) "
	_cQuery += "             FROM " + RetSqlName("SDA") + " SDA (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	_cQuery += "             WHERE SDA.DA_PRODUTO = ZDD.ZDD_CODPRT "
	_cQuery += "             AND SDA.DA_FILIAL = '" + xFilial("SDA") + "'"
	_cQuery += "             AND SDA.DA_LOCAL = SB1.B1_LOCPAD "
	_cQuery += "             AND SB1.D_E_L_E_T_ = '' "
	_cQuery += "             AND SB1.B1_COD = ZDD.ZDD_CODPRT "
	_cQuery += "             AND SB1.B1_COD = SDA.DA_PRODUTO "
	_cQuery += "             AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	_cQuery += "             AND SDA.D_E_L_E_T_ = '') "
	_cQuery += "   ,0) "
	_cQuery += "   AS SALDO_AGR, "

	_cQuery += "   COALESCE((SELECT SUM(SB2.B2_QACLASS) "
	_cQuery += "             FROM " + RetSqlName("SB2") + " SB2 (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	_cQuery += "             WHERE SB2.B2_COD = ZDD.ZDD_CODPRT "
	_cQuery += "             AND   SB2.B2_LOCAL = SB1.B1_LOCPAD "
	_cQuery += "             AND   SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
	_cQuery += "             AND   SB2.D_E_L_E_T_ = '' "
	_cQuery += "             AND   SB1.B1_COD = ZDD.ZDD_CODPRT "
	_cQuery += "             AND   SB1.B1_COD = SB2.B2_COD "
	_cQuery += "             AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	_cQuery += "             AND   SB1.D_E_L_E_T_ = '') "
	_cQuery += "   ,0) "
	_cQuery += "   AS QTDE_CLASS "

	_cQuery += " FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
	_cQuery += " WHERE ZDD.ZDD_NUM = '" + (_cAliasTrb)->ZDC_NUM + "'"
	_cQuery += " AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
	_cQuery += " AND   ZDD.D_E_L_E_T_ = '' "

	TCQuery _cQuery NEW ALIAS (_cAliasIt)

	Aadd(aHeaderEx, {"Código"             ,"ZDD_CODPRT" ,"@!"               ,15,0,,Replicate(" ", 15),"C",,,,})
	Aadd(aHeaderEx, {"Descrição"          ,"ZDD_DESATS" ,"@!"               ,50,0,,Replicate(" ", 15),"C",,,,})
	Aadd(aHeaderEx, {"Qtde Necessidade"   ,"ZDD_NECEMB" ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Qtde Solicitada"    ,"ZDD_NECDIG" ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Qtde Revisao"       ,"ZDD_NECSC5" ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Saldo Posto"        ,"ZDD_SLDATS" ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Fator"              ,"ZDD_QTDEMB" ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Número Ped Agr."    ,"ZDD_NUMSC5" ,"@!"               ,10,0,,Replicate(" ", 15),"C",,,,})
	Aadd(aHeaderEx, {"Qtde Pedido"        ,"QTDE_SC6"   ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Saldo Agricopel"    ,"SALDO_AGR"  ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Qtde a Classif."    ,"QTDE_CLASS" ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Qtde Conv Protheus" ,"ZDD_CONV"   ,"@E 999,999,999.99",10,2,,Replicate(" ", 15),"N",,,,})
	Aadd(aHeaderEx, {"Código Repaut"      ,"ZDD_NUM"    ,"@!"               ,50,0,,Replicate(" ", 15),"C",,,,})

	While !(_cAliasIt)->(Eof())

		IncProc()

		AADD(aColsEx,{;
			(_cAliasIt)->ZDD_CODPRT, ;
			(_cAliasIt)->ZDD_DESATS, ;
			(_cAliasIt)->ZDD_NECEMB, ;
			(_cAliasIt)->ZDD_NECDIG, ;
			(_cAliasIt)->ZDD_NECSC5, ;
			(_cAliasIt)->ZDD_SLDATS, ;
			(_cAliasIt)->ZDD_QTDEMB, ;
			(_cAliasIt)->ZDD_NUMSC5, ;
			(_cAliasIt)->QTDE_SC6, ;
			(_cAliasIt)->SALDO_AGR, ;
			(_cAliasIt)->QTDE_CLASS, ;
			(_cAliasIt)->ZDD_CONV, ;
			(_cAliasIt)->ZDD_NUM, ;
			.F.})

		(_cAliasIt)->(DbSkip())
	EndDo

	oMSNewGe1 := MsNewGetDados():New(030, 010, 250, 590, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlog, aHeaderEx, aColsEx)

	oMSNewGe1:oBrowse:lUseDefaultColors := .F.
	oMSNewGe1:oBrowse:SetBlkBackColor({|| CorItens(oMSNewGe1:aCols, oMSNewGe1:nAt, aHeaderEx)})

	(_cAliasIt)->(dbCloseArea())
Return()

Static Function CorItens(aLinha, nLinha, aHeader)

	Local nPosQTDEPEDIDO := aScan(aHeader,{|x| Alltrim(x[2]) == "ZDD_NECSC5"})
	Local nPosSALDO_AGR  := aScan(aHeader,{|x| Alltrim(x[2]) == "SALDO_AGR"})

	Local nCor      := CLR_HGREEN
	Local nQtdPed   := 0
	Local nSaldoAgr := 0

	nQtdPed   := aLinha[nLinha][nPosQTDEPEDIDO]
	nSaldoAgr := aLinha[nLinha][nPosSALDO_AGR]

	If (nSaldoAgr == 0)
		nCor := CLR_HRED
	Else
		If (nQtdPed > nSaldoAgr)
			nCor := CLR_HBLUE
		EndIf
	EndIf

Return(nCor)

Static Function GravarItens()

	Local _aHeader      := oMSNewGe1:aHeader
	Local _aRegistros   := oMSNewGe1:aCols
	Local _nX           := 0
	Local _nLenAReg     := 0
	Local _nQtdePed     := 0
	Local _nZDD_CODPRT  := aScan(_aHeader,{|x| Alltrim(x[2]) == "ZDD_CODPRT"})
	Local _nZDD_NUM     := aScan(_aHeader,{|x| Alltrim(x[2]) == "ZDD_NUM"})
	Local _nZDD_NECSC5  := aScan(_aHeader,{|x| Alltrim(x[2]) == "ZDD_NECSC5"})
	Local _cCodPrt      := ""
	Local _cNum         := ""
	Local _cQuery       := ""

	_nLenAReg := Len(_aRegistros)

	If isPedStatusOK((_cAliasTrb)->ZDC_NUM)
		For _nX := 1 to _nLenAReg

			_cCodPrt  := _aRegistros[_nX, _nZDD_CODPRT]
			_cNum     := _aRegistros[_nX, _nZDD_NUM]
			_nQtdePed := _aRegistros[_nX, _nZDD_NECSC5]

			_cQuery := " UPDATE ZDD SET "
			_cQuery += "   ZDD_NECSC5 = " + cValToChar(_nQtdePed)
			_cQuery += " FROM " + RetSqlName("ZDD") + " ZDD "
			_cQuery += " WHERE ZDD_NUM = '" + _cNum + "'"
			_cQuery += " AND   ZDD_FILIAL = '" + xFilial("ZDD") + "'"
			_cQuery += " AND   ZDD_CODPRT = '" + _cCodPrt + "'"
			_cQuery += " AND   ZDD.D_E_L_E_T_ = '' "

			TCSQLExec(_cQuery)
		End

		MsgInfo("Gravação concluída!")
		Close(oDlog)
	EndIf

Return

Static Function isPedStatusOK(_cCdPedido)

	Local _cQuery    := ""
	Local _cAliasVal := GetNextAlias()
	Local _cProdutos := ""

	_cQuery := " SELECT ZDC.ZDC_STATUS "
	_cQuery += " FROM " + RetSqlName("ZDC") + " ZDC (NOLOCK) "
	_cQuery += " WHERE ZDC.ZDC_NUM = '" + AllTrim(_cCdPedido) + "'"
	_cQuery += " AND   ZDC.ZDC_FILIAL = '" + xFilial("ZDC") + "'"
	_cQuery += " AND   ZDC.D_E_L_E_T_ = '' "

	TCQuery _cQuery NEW ALIAS (_cAliasVal)

	If((_cAliasVal)->ZDC_STATUS == "B")

		_cQuery := " SELECT DISTINCT(ZDD.ZDD_NUMSC5) "
		_cQuery += " FROM " + RetSqlName("ZDD") + " ZDD (NOLOCK) "
		_cQuery += " WHERE ZDD.ZDD_NUM = '" + AllTrim(_cCdPedido) + "'"
		_cQuery += " AND   ZDD.ZDD_FILIAL = '" + xFilial("ZDD") + "'"
		_cQuery += " AND   ZDD.D_E_L_E_T_ = '' "

		(_cAliasVal)->(dbCloseArea())
		TCQuery _cQuery NEW ALIAS (_cAliasVal)

		While !(_cAliasVal)->(Eof())
			_cProdutos += IIf(AllTrim(_cProdutos) = "", "", " / ") + (_cAliasVal)->ZDD_NUMSC5
			(_cAliasVal)->(DbSkip())
		EndDo

		If(AllTrim(_cProdutos) <> "")
			Alert("Não é possível efetuar a operação. Pedido de venda já foi movimentado!" + CHR(13) + "Pedidos gerados: " + _cProdutos)
			Return(.F.)
		EndIf

		(_cAliasVal)->(dbCloseArea())
	Else
		Alert("Não é possível efetuar a operação. Pedido não está baixado!")
		Return(.F.)
	EndIf

Return(.T.)

User Function XAG038Ref()

	If CriarPerguntas()
		MsgRun("Carregando dados","Processando...",{|| CarPed() })
	Else
		CloseBrowse()
	EndIf

Return(.T.)
