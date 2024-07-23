#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XAG0043
Rotina de integração com OBC, para emitir os pedidos de compra da integração, chamada pela rotina de WS XAG0043
@author Leandro F Silveira
@since 08/08/2019
@version 1.0
/*/
User Function XAG0043A(cJson)

	Local oPedidoObc := nil

	Private oRetObc := RetornoOBC():New()
	Private lInsSA2 := .F.

	FWJsonDeserialize(cJson, @oPedidoObc)

	If Len(oPedidoObc:Itens) = 0
		oRetObc:errorMessage := "Pedido sem itens!"
		oRetObc:Sucesso      := .F.
	EndIf

	RPCSetType(3)
	RPCSetEnv(oPedidoObc:empresa, oPedidoObc:filial)

	If (Validar(oPedidoObc))
		SC7Inserir(oPedidoObc)
	EndIf

	RPCClearEnv()

Return(oRetObc)

Static Function Validar(oPedidoObc)

	Local aRetValid := {}
	Local nX        := 0
	Local cRetValid := ""

	Private cErrorCode := ""

	cRetValid := SB1Valid(oPedidoObc)
	aAdd(aRetValid, cRetValid)

	cRetValid := SA2Valid(oPedidoObc)
	aAdd(aRetValid, cRetValid)

	cRetValid := SE4Valid(oPedidoObc)
	aAdd(aRetValid, cRetValid)

	cRetValid := CTTValid(oPedidoObc)
	aAdd(aRetValid, cRetValid)

	cRetValid := ""
	For nX := 1 To Len(aRetValid)
		If (!Empty(aRetValid[nX]))
			cRetValid += IIf(Empty(cRetValid), "", " | ") + aRetValid[nX]
		EndIf
	End

	oRetObc:errorMessage := Alltrim(cRetValid)
	oRetObc:errorCode    := cErrorCode
	oRetObc:Sucesso      := Empty(oRetObc:errorMessage)

Return(oRetObc:Sucesso)

Static Function CTTValid(oPedidoObc)

	Local aAreaCTT := CTT->(GetArea())
	Local cRet     := ""
	Local nX       := 0
	Local nY       := 0
	Local oRatCCusto := Nil

	For nX := 1 to Len(oPedidoObc:Itens)

		oItPedido := oPedidoObc:Itens[nX]

		If Len(oItPedido:ratCCusto) == 1
			If !CTTDbSeek(oItPedido:centroCusto)
				cRet += IIf(Empty(cRet), "", " | ") + "Centro de custo de código [" + oItPedido:centroCusto + "] não encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
			EndIf
		Else
			For nY := 1 To Len(oItPedido:ratCCusto)

				oRatCCusto := oItPedido:ratCCusto[nY]

				If !CTTDbSeek(oRatCCusto:centroCusto)
					cRet += IIf(Empty(cRet), "", " | ") + "Centro de custo de código [" + oRatCCusto:centroCusto + "] não encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
				EndIf
			End
		EndIf
	End

	RestArea(aAreaCTT)

Return(cRet)

Static Function CTTDbSeek(cCTT_CUSTO)

	Local _lRet := .F.

	CTT->(DbSetOrder(1))
	CTT->(DbGoTop())
	_lRet := CTT->(DbSeek(xFilial("CTT")+cCTT_CUSTO))

Return(_lRet)

Static Function SB1Valid(oPedidoObc)

	Local cRet    := ""
	Local cRetSF4 := ""
	Local cCodSB1 := ""
	Local nX      := 0

	For nX := 1 to Len(oPedidoObc:Itens)

		cCodSB1 := AllTrim(oPedidoObc:Itens[nX]:codProduto)

		SB1->(dbSetOrder(1))
		SB1->(DbGoTop())
		If !SB1->(DbSeek(xFilial("SB1")+cCodSB1))
			cRet += IIf(Empty(cRet), "", " | ") + "Produto de código [" + cCodSB1 + "] não encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
		Else
			If (SB1->B1_MSBLQL == "1")
				cRet += IIf(Empty(cRet), "", " | ") + "Produto de código [" + cCodSB1 + "] encontra-se bloqueado para uso!"
			Else
				cRetSF4 := SF4Valid(SB1->B1_COD, SB1->B1_TE)

				If !(Empty(cRetSF4))
					cRet += IIf(Empty(cRet), "", " | ") + cRetSF4
				EndIf
			EndIf
		EndIf
	End

Return(cRet)

Static Function SF4Valid(cCodSB1, cCodSF4)

	Local cRet := ""

	If (Empty(cCodSF4))
		cRet := "Produto [" + cCodSB1 + "] na empresa [" + cEmpAnt + "-" + cFilAnt + "] não possui TES cadastrada!"
	Else
		SF4->(DbSetOrder(1))
		If !(SF4->(DbSeek(xFilial("SF4")+cCodSF4)))
			cRet := "Não foi encontrada a TES [" + cCodSF4 + "] " + " para o produto [" + cCodSB1 + "] na empresa [" + cEmpAnt + "-" + cFilAnt + "]"
		Else
			If (SF4->F4_MSBLQL == "1")
				cRet := "TES [" + cCodSF4 + "] " + " para o produto [" + cCodSB1 + "] na empresa [" + cEmpAnt + "-" + cFilAnt + "] encontra-se bloqueada para uso!"
			EndIf
		EndIf
	EndIf

Return(cRet)

Static Function SA2Valid(oPedidoObc)

	Local cRet     := ""
	Local cCgc     := oPedidoObc:cnpjFornecedor
	Local lBloq    := .T.
	Local cRetBloq := ""

	SA2->(DbSetOrder(3))
	SA2->(DbGoTop())
	If !(SA2->(DbSeek(xFilial("SA2")+AllTrim(cCgc))))

		If (oPedidoObc:temFornecedor)
			SA2Inserir(oPedidoObc)

			SA2->(DbSetOrder(3))
			SA2->(DbGoTop())
			If !(SA2->(DbSeek(xFilial("SA2")+AllTrim(cCgc))))
				cRet := "Fornecedor de CPF/CNPJ [" + cCgc + "] não encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
				cErrorCode := "CNPJ_NAO_ENCONTRADO"
			EndIf
		Else
			SA2->(DbGoTop())
			If !(SA2->(DbSeek(xFilial("SA2")+AllTrim(cCgc))))
				cRet := "Fornecedor de CPF/CNPJ [" + cCgc + "] não encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
				cErrorCode := "CNPJ_NAO_ENCONTRADO"
			EndIf
		EndIf
	Else
		While (lBloq .And. SA2->A2_CGC == cCgc)
			lBloq    := SA2->A2_MSBLQL == "1"

			If (lBloq)
				If (!Empty(cRetBloq))
					cRetBloq += "| "
				EndIf

				cRetBloq += "Fornecedor encontra-se bloqueado! CPF/CNPJ [" + cCgc + "] / Cód-Loja [" + SA2->A2_COD + "-" + SA2->A2_LOJA + "]"
				SA2->(DbSkip())
			EndIf
		End

		If (lBloq)
			cRet += cRetBloq
		EndIf
	EndIf

Return(cRet)

Static Function SE4Valid(oPedidoObc)

	Local cRet      := ""
	Local lAchouSE4 := .F.
	Local cCond     := oPedidoObc:condPagto

	lAchouSE4 := SE4FindObc(cCond)

	If !lAchouSE4 .And. cEmpAnt <> "01"
		lAchouSE4 := SE4Replic(cCond)
	EndIf

	If !lAchouSE4
		cRet := "Condição de pagamento [" + cCond + "] não encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"

		If (cEmpAnt <> "01")
			cRet += " - Nem na empresa Agricopel (01) para copiar!"
		EndIf
	EndIf

Return(cRet)

Static Function SE4FindObc(cCondOBC)

	Local _lRet      := .F.
	Local _cQuery    := ""
	Local _cAliasSE4 := GetNextAlias()

	_cQuery := " SELECT R_E_C_N_O_ AS RECNO "
	_cQuery += " FROM " + RetSQLName("SE4") + " SE4 "
	_cQuery += " WHERE SE4.D_E_L_E_T_ = '' "
	_cQuery += " AND E4_XCODOBC = '" + AllTrim(cCondOBC) + "'"

	TCQuery _cQuery NEW ALIAS (_cAliasSE4)

	If (!Empty((_cAliasSE4)->RECNO))
		_lRet := .T.
		SE4->(DbGoTo((_cAliasSE4)->RECNO))
	EndIf

	(_cAliasSE4)->(DbCloseArea())

Return(_lRet)

Static Function SE4FindCnd(cCond)

	Local _lRet      := .F.
	Local _cQuery    := ""
	Local _cAliasSE4 := GetNextAlias()

	_cQuery := " SELECT R_E_C_N_O_ AS RECNO "
	_cQuery += " FROM " + RetSQLName("SE4") + " SE4 "
	_cQuery += " WHERE SE4.D_E_L_E_T_ = '' "
	_cQuery += " AND E4_COND = '" + AllTrim(cCond) + "'"
	_cQuery += " AND E4_TIPO = '1' "

	TCQuery _cQuery NEW ALIAS (_cAliasSE4)

	If (!Empty((_cAliasSE4)->RECNO))
		_lRet := .T.
		SE4->(DbGoTo((_cAliasSE4)->RECNO))
	EndIf

	(_cAliasSE4)->(DbCloseArea())

Return(_lRet)

Static Function LerLogErro()

	Local cRet       := ""
	Local nX         := 0
	Local aErroLog   := GetAutoGRLog()

	If Len(aErroLog) > 0

		cRet := "Lendo erro: "

		For nX := 1 to Len(aErroLog)
			cRet += AllTrim(aErroLog[nX])
		End
	Else
		cRet := "MostraErro(): " + MostraErro("/dirdoc", "error.log")
	EndIf

Return(cRet)

Static Function SC7NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("C7_NUM"))
		cX3_Relacao := SX3->X3_RELACAO
	Endif

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SC7", "C7_NUM", "C7_NUM" + cEmpAnt)
		EndIf

		SC7->(DbSetOrder(1))
		SC7->(DbGoTop())
		lJaExiste := SC7->(DbSeek(xFilial("SA1")+cCodNovo))
	End

Return(cCodNovo)

Static Function SE4NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("E4_CODIGO"))
		cX3_Relacao := SX3->X3_RELACAO
	Endif

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SE4", "E4_CODIGO")
		EndIf

		SE4->(DbSetOrder(1))
		SE4->(DbGoTop())
		lJaExiste := SE4->(DbSeek(xFilial("SE4")+cCodNovo))
	End

Return(cCodNovo)

Static Function SE4Replic(cCond)

	Local _lRet      := .F.
	Local _cAliasSE4 := ""
	Local _cE4_COD   := ""

	_cAliasSE4 := SE4GetAgr(cCond)

	If !Empty((_cAliasSE4)->E4_DESCRI)

		If (SE4FindCnd((_cAliasSE4)->E4_COND))
			RecLock("SE4", .F.)
		Else
			_cE4_COD := SE4NovoCod()

			RecLock("SE4", .T.)

			SE4->E4_CODIGO   := _cE4_COD
			SE4->E4_DESCRI   := "[OBC] - " + (_cAliasSE4)->E4_DESCRI
			SE4->E4_COND     := (_cAliasSE4)->E4_COND
			SE4->E4_ACRES    := (_cAliasSE4)->E4_ACRES
			SE4->E4_DDD      := (_cAliasSE4)->E4_DDD
			SE4->E4_IPI      := (_cAliasSE4)->E4_IPI
			SE4->E4_AGRACRS  := (_cAliasSE4)->E4_AGRACRS
			SE4->E4_LIMACRS  := (_cAliasSE4)->E4_LIMACRS
			SE4->E4_CCORREN  := (_cAliasSE4)->E4_CCORREN
			SE4->E4_FORMA    := (_cAliasSE4)->E4_FORMA
			SE4->E4_MSBLQL   := "2"
			SE4->E4_FILIAL   := xFilial("SE4")
			SE4->E4_TIPO     := (_cAliasSE4)->E4_TIPO

			If (SE4->(FieldPos("E4_X_ACRES")) > 0)
				SE4->E4_X_ACRES := (_cAliasSE4)->E4_X_ACRES
			EndIf

			If (SE4->(FieldPos("E4_USADO")) > 0)
				SE4->E4_USADO := ""
			EndIf
		EndIf

		SE4->E4_XCODOBC := (_cAliasSE4)->E4_XCODOBC

		MsUnlock("SE4")

		If __lSX8
			ConfirmSX8()
		EndIf

		_lRet := .T.
	EndIf

	(_cAliasSE4)->(DbCloseArea())

Return(_lRet)

Static Function SE4GetAgr(cCond)

	Local _cAlias := GetNextAlias()
	Local _cQuery := ""

	_cQuery += " SELECT "
	_cQuery += "    E4_DESCRI, E4_X_ACRES, E4_ACRES, E4_DDD, E4_TIPO, "
	_cQuery += "    E4_IPI, E4_AGRACRS, E4_LIMACRS, E4_CCORREN, E4_FORMA, "
	_cQuery += "    E4_COND, E4_XCODOBC "
	_cQuery += " FROM SE4010 (NOLOCK) "
	_cQuery += " WHERE D_E_L_E_T_ = '' "
	_cQuery += " AND E4_XCODOBC = '" + AllTrim(cCond) + "'"

	TCQuery _cQuery NEW ALIAS (_cAlias)

Return(_cAlias)

Static Function SC7Inserir(oPedidoObc)

	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}
	Local aRatCC    := {}
	Local aItRatCC  := {}
	Local nX        := 0
	Local cCodSC7   := ""
	Local cC7_ITEM  := "0001"
	Local oItPedido := Nil;

	Private lMsErroAuto := .F.

	cCodSC7 := SC7NovoCod()

	aAdd(aCabec,{"C7_FILIAL", xFilial("SC7")})
	aAdd(aCabec,{"C7_TIPO", 1})
	aAdd(aCabec,{"C7_FORNECE", SA2->A2_COD})
	aAdd(aCabec,{"C7_LOJA", SA2->A2_LOJA})
	aAdd(aCabec,{"C7_COND", SE4->E4_CODIGO})
	aAdd(aCabec,{"C7_NUM", cCodSC7})
	aAdd(aCabec,{"C7_EMISSAO", dDataBase})
	aAdd(aCabec,{"C7_FILENT", oPedidoObc:filial})
	aAdd(aCabec,{"C7_TPFRETE", IIf(oPedidoObc:tipoFrete == "1", "C", "F")})
	aAdd(aCabec,{"C7_FLUXO", "S", Nil})
	aAdd(aCabec,{"C7_ORIGEM", "XAG0043", Nil})

	For nX := 1 To Len(oPedidoObc:Itens)

		oItPedido := oPedidoObc:Itens[nX]
		aLinha := {}

		aAdd(aLinha,{"C7_ITEM", cC7_ITEM, Nil})
		aAdd(aLinha,{"C7_PRODUTO", oItPedido:codProduto, Nil})
		aAdd(aLinha,{"C7_QUANT", oItPedido:quantidade, Nil})
		aAdd(aLinha,{"C7_PRECO", oItPedido:valorUnit, Nil})

		If (SC7->(FieldPos("C7_PRECOT")) > 0)
			aAdd(aLinha,{"C7_PRECOT", oItPedido:valorUnit, Nil})
		EndIf

		aAdd(aLinha,{"C7_TES", SB1->B1_TE, Nil})
		aAdd(aLinha,{"C7_TXMOEDA", 0, Nil})
		aAdd(aLinha,{"C7_FLUXO", "S", Nil})
		aAdd(aLinha,{"C7_DATPRF", StoD(oItPedido:dtEntrega), Nil})
		aAdd(aLinha,{"C7_EMITIDO", "S", Nil})
		aAdd(aLinha,{"C7_SOLICIT", oItPedido:solicitante, Nil})

		aAdd(aLinha,{"C7_OBS", oPedidoObc:observacao, Nil})
		aAdd(aLinha,{"C7_XRECOBC", oPedidoObc:recno, Nil})

		aAdd(aLinha,{"C7_XPEDOBC", oItPedido:codPedidoObc, Nil})
		aAdd(aLinha,{"C7_XSDCOBC", oItPedido:codSdcv, Nil})

		If Len(oItPedido:ratCCusto) == 1
			aAdd(aLinha,{"C7_CONTA", SB1->B1_CONTA, Nil})
			aAdd(aLinha,{"C7_CC", oItPedido:centroCusto, Nil})
			aAdd(aLinha,{"C7_RATEIO", "2", Nil})
		Else
			aAdd(aLinha,{"C7_RATEIO", "1", Nil})
			aAdd(aLinha,{"C7_CONTA", "", Nil})
			aAdd(aLinha,{"C7_CC", "", Nil})
			aItRatCC := CalcRatCC(oItPedido)
			aAdd(aRatCC,{cC7_ITEM, aClone(aItRatCC)})
		EndIf

		aAdd(aItens,aLinha)

		cC7_ITEM := SOMA1(cC7_ITEM)
	Next nX

	MSExecAuto({|a,b,c,d,e,f| MATA120(a,b,c,d,e,f)},1,aCabec,aItens,3   ,.F.,aRatCC)

	If lMsErroAuto
		oRetObc:errorMessage := "Pedido: [" + cCodSC7 + "]["+ cEmpAnt + "-" + cFilAnt + "] - Erro: " + LerLogErro()
		oRetObc:Sucesso      := .F.
	Else
		oRetObc:CodPedido := cCodSC7
		oRetObc:Sucesso   := .T.
		oRetObc:errorMessage := ""
	EndIf

	If (lInsSA2)
		RecLock("SA2", .F.)
		SA2->A2_MSBLQL := "1"
		MsUnlock("SA2")
	EndIf

Return()

Static Function CalcRatCC(oItPedido)

	Local aItRatCC   := {}
	Local aRatCC     := {}
	Local nTamanho   := TamSX3("CH_ITEM")[1]
	Local nX         := 0
	Local oRatCCusto := Nil

	For nX := 1 To Len(oItPedido:ratCCusto)
		oRatCCusto := oItPedido:ratCCusto[nX]

		aItRatCC   := {}

		aAdd(aItRatCC,{"CH_FILIAL", xFilial("SCH"), Nil})
		aAdd(aItRatCC,{"CH_ITEM", StrZero(nX, nTamanho), Nil})
		aAdd(aItRatCC,{"CH_PERC", oRatCCusto:pRateio, Nil})
		aAdd(aItRatCC,{"CH_CC", oRatCCusto:centroCusto, Nil})
		aAdd(aItRatCC,{"CH_CONTA", SB1->B1_CONTA, Nil})

		aAdd(aRatCC, aClone(aItRatCC))
	End

Return(aRatCC)

Static Function SA2Inserir(oPedidoObc)

	Local cCodNovo    := ""
	Local cLojaNovo   := ""
	Local cTpPessoa   := ""
	Local cCGCBase    := ""
	Local nX          := 0
	Local aUltCdLj    := {}
	Local oFornCont   := Nil
	Local oFornObc    := oPedidoObc:fornecedorPrt

	If (CGC(oFornObc:cpfCnpj)) // Validação de CPF/CNPJ

		cTpPessoa := IIf(Len(oFornObc:cpfCnpj) == 11, "F", "J")

		If (cTpPessoa == "F")
			cCodNovo   := SA2NovoCod()
			cLojaNovo  := "01"
		Else
			cCGCBase := SubStr(oFornObc:cpfCnpj, 1, 8)
			aUltCdLj := SA2UltLoja(cCGCBase)

			If (Len(aUltCdLj) == 2)
				cCodNovo   := aUltCdLj[1]
				cLojaNovo  := aUltCdLj[2]
			Else
				cCodNovo   := SA2NovoCod()
				cLojaNovo  := "01"
			EndIf
		EndIf

		RecLock("SA2", .T.)

		SA2->A2_COD        := cCodNovo
		SA2->A2_LOJA       := cLojaNovo
		SA2->A2_FILIAL     := xFilial("SA2")
		SA2->A2_NOME       := NoAcento(AnsiToOem(oFornObc:razaoSocial))
		SA2->A2_NREDUZ     := NoAcento(AnsiToOem(oFornObc:nomeFantasia))
		SA2->A2_CEP        := oFornObc:cep
		SA2->A2_END        := oFornObc:endereco

		If !Empty(oFornObc:numEndereco)
			SA2->A2_END += ", " + oFornObc:numEndereco
		EndIf

		SA2->A2_BAIRRO     := oFornObc:bairro
		SA2->A2_EST        := oFornObc:estado
		SA2->A2_COD_MUN    := oFornObc:codigoCidadeIBGE
		SA2->A2_MUN        := oFornObc:cidade
		SA2->A2_INSCR      := oFornObc:inscEstadual
		SA2->A2_INSCRM     := oFornObc:inscMunicipal
		SA2->A2_CGC        := oFornObc:cpfCnpj

		If (cTpPessoa == "F") // Pessoa Física
			SA2->A2_TPESSOA := "PF" // CI - Comercio/Industria; PF - Pessoa Fisica; OS - Prestacäo de Servico
			SA2->A2_TIPO    := "F"  // F - Fisico; J - Juridico; X - Outros
		Else
			SA2->A2_TPESSOA := "CI" // CI - Comercio/Industria; PF - Pessoa Fisica; OS - Prestacäo de Servico
			SA2->A2_TIPO    := "J"  // F - Fisico; J - Juridico; X - Outros
		EndIf

		SA2->A2_MSBLQL  := "2"
		SA2->A2_TRANSP  := ""
		SA2->A2_CONTA   := ""
		SA2->A2_SIMPNAC := IIf(oFornObc:optanteSimples == "N", "2", "1")

		If (oFornObc:pais == "BRASIL")
			SA2->A2_CODPAIS := "01058"
		EndIf

		If (SA2->(FieldPos("A2_CLASSIF")) > 0)
			SA2->A2_CLASSIF := "00"
		EndIf

		If (SA2->(FieldPos("A2_MUN_ANP")) > 0)
			SA2->A2_MUN_ANP := oFornObc:codigoCidadeIBGE
		EndIf

		If (SA2->(FieldPos("A2_ORIIMP")) > 0)
			SA2->A2_ORIIMP := "XAG0043"
		EndIf

		If (Len(oFornObc:fornecedorContatos) > 0)
			For nX := 1 to Len(oFornObc:fornecedorContatos)
				oFornCont := oFornObc:fornecedorContatos[nX]

				If (oFornCont:padrao == "S")
					Exit
				EndIf
			End

			SA2->A2_EMAIL    := oFornCont:email
			SA2->A2_TEL      := oFornCont:telefone
			SA2->A2_CONTATO  := oFornCont:email
		EndIf

		SA2->(MsUnLock())

		lInsSA2 := .T.

		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf

Return()

Static Function SA2UltLoja(cCGCBase)

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cLoja     := ""
	Local aRet      := {}

	cQuery += " SELECT SA2.A2_COD, "
	cQuery += " MAX(SA2.A2_LOJA) AS A2_LOJA "
	cQuery += " FROM " + RetSQLName("SA2") + " SA2 (NOLOCK) "
	cQuery += " WHERE SA2.D_E_L_E_T_ = '' "
	cQuery += " AND   SA2.A2_CGC LIKE '" + cCGCBase + "%' "
	cQuery += " GROUP BY SA2.A2_COD "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If !Empty((cAliasQry)->(A2_COD)) .And. !Empty((cAliasQry)->(A2_LOJA))
		aAdd(aRet, (cAliasQry)->(A2_COD))

		cLoja := Soma1((cAliasQry)->(A2_LOJA))
		aAdd(aRet, cLoja)
	EndIf

Return(aRet)

Static Function SA2NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("A2_COD"))
		cX3_Relacao := SX3->X3_RELACAO
	Endif

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA2", "A2_COD")
		EndIf

		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
		lJaExiste := SA2->(DbSeek(xFilial("SA2")+cCodNovo))
	End

Return(cCodNovo)