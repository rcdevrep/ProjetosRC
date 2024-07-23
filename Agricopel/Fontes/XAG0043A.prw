#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0043
Rotina de integracao com OBC, para emitir os pedidos de compra da integracao, chamada pela rotina de WS XAG0043
@author Leandro F Silveira
@since 08/08/2019
@version 1.0
/*/
User Function XAG0043A(cJson)

	Local oPedidoObc := nil
	
	Private oRetObc   := RetornoOBC():New()
	Private lInsSA2   := .F.
	Private lInclusao := .T.

	FWJsonDeserialize(cJson, @oPedidoObc)

	//Verificação se é inclusao ou exclusão 
	//Prenche a Variavel lInclusao
	if '"acao":' $ cJson //TYPE('oPedidoObc:acao') == 'O'  
		If alltrim(oPedidoObc:acao) == 'E'
			lInclusao := .F.
		Endif 
	endif 
	

	cFilAnt := oPedidoObc:filial
	cEmpAnt := oPedidoObc:empresa
	cNumEmp := cEmpAnt + cFilAnt

	//RPCSetType(3)
	//PREPARE ENVIRONMENT EMPRESA oPedidoObc:empresa FILIAL oPedidoObc:filial MODULO "SIGACOM" TABLES "SC7","SCH","SB1","SA2","SE4","CTT","SF4","NNR"
	conout('-----> XAG0043 - inicio '+ cNumEmp)
	RPCClearEnv()
	//conout('XAG0043 RPCClearEnv- 33 '+ cNumEmp)
	If RPCSetEnv(cEmpAnt,cFilAnt,"USERREST","*R3st2021","","",{"SC7","SA2","SB1","CTT","NNR","SF4","SCH","SE4"})
			
		If lInclusao 
			If Len(oPedidoObc:Itens) > 0 
				If (!SC7JaExist(oPedidoObc:Itens[1]:codSdcv) .And. Validar(oPedidoObc))
					SC7Inserir(oPedidoObc)
				EndIf
			Else 
				oRetObc:errorMessage := "Pedido sem itens!"
				oRetObc:Sucesso      := .F.
				oRetObc:email        := "leandro.h@agricopel.com.br"//Chamado 592115
			EndIf
		Else
			SC7Excluir(oPedidoObc)
		Endif 
		 
		//conout('XAG0043 RPCClearEnv - 40 '+ cNumEmp)	
		cFilAnt := oPedidoObc:filial
		cEmpAnt := oPedidoObc:empresa
		cNumEmp := cEmpAnt + cFilAnt
		RPCClearEnv()
		cFilAnt := oPedidoObc:filial
		cEmpAnt := oPedidoObc:empresa
		cNumEmp := cEmpAnt + cFilAnt
		//conout('XAG0043 RPCClearEnv - 48 '+ cNumEmp)
		conout('-----> XAG0043 - fim '+ cNumEmp)
	Else
		oRetObc:errorMessage := "Nao foi Possivel abrir o ambiente: "+oPedidoObc:empresa+' - ' +oPedidoObc:filial
		oRetObc:Sucesso      := .F.
		oRetObc:email        := "leandro.h@agricopel.com.br"
	Endif 
	

Return(oRetObc)

Static Function SC7JaExist(cCodSDCV)

	Local _lRet    := .F.
	Local _cC7_NUM := ""

	_cC7_NUM := SC7Find(cCodSDCV)

	If !Empty(_cC7_NUM)
		_lRet := .T.

		oRetObc:errorMessage := "Encontrado pedido [" + _cC7_NUM + "] a partir da SDCV [" + cCodSDCV + "]"
		oRetObc:CodPedido := _cC7_NUM
		oRetObc:errorCode    := ""
		oRetObc:Sucesso      := .T.
	EndIf

Return(_lRet)

Static Function Validar(oPedidoObc)

	Local aRetValid := {}
	Local nX        := 0
	Local cRetValid := ""
	Local _cEmpJson  := ""
	Local _cFilJson  := ""

	Private cErrorCode := ""

	_cEmpJson := oPedidoObc:empresa
	_cFilJson := oPedidoObc:filial

	If (_cEmpJson == cEmpAnt .And. _cFilJson == FWFilial())
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
	Else
		cRetValid  := "ATENÇÃO: Divergência entre empresa/filial do pedido [" + _cEmpJson + "-" + _cFilJson + "]"
		cRetValid  +=  " e a empresa/filial que o Protheus se logou [" + cEmpAnt + "-" + FWFilial() + "]"
		cErrorCode := "DIVERGENCIA_EMPRESA_FILIAL"
	EndIf

	oRetObc:errorMessage := Alltrim(cRetValid)
	oRetObc:errorCode    := cErrorCode
	oRetObc:Sucesso      := Empty(oRetObc:errorMessage)
	If !Empty(oRetObc:errorMessage)
		oRetObc:email        := "leandro.h@agricopel.com.br"//Chamado 592115
	Endif 

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
			If !("COMPRA_" $ Upper(alltrim(oItPedido:centroCusto)) )//oItPedido:centroCusto <> "COMPRA_REVENDA" .And. oItPedido:centroCusto <> "COMPRA_ESTOQUE"
				If CTTDbSeek(oItPedido:centroCusto)
					If CTT->CTT_BLOQ == "1"
						cRet += IIf(Empty(cRet), "", " | ") + "Centro de custo de codigo [" + oItPedido:centroCusto + "] esta bloqueado para uso!"
					EndIf
				Else
					cRet += IIf(Empty(cRet), "", " | ") + "Centro de custo de codigo [" + oItPedido:centroCusto + "] nao encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
				EndIf
			EndIf
		Else
			For nY := 1 To Len(oItPedido:ratCCusto)

				oRatCCusto := oItPedido:ratCCusto[nY]

				If !(  "COMPRA_" $ Upper(alltrim(oItPedido:centroCusto)) )//oRatCCusto:centroCusto <> "COMPRA_REVENDA" .And. oRatCCusto:centroCusto <> "COMPRA_ESTOQUE"
					If CTTDbSeek(oRatCCusto:centroCusto)
						If CTT->CTT_BLOQ == "1"
							cRet += IIf(Empty(cRet), "", " | ") + "Centro de custo de codigo [" + oRatCCusto:centroCusto + "] esta bloqueado para uso!"
						EndIf
					Else
						cRet += IIf(Empty(cRet), "", " | ") + "Centro de custo de codigo [" + oRatCCusto:centroCusto + "] nao encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
					EndIf
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
	_lRet := CTT->(DbSeek(FWFilial("CTT")+cCTT_CUSTO))

Return(_lRet)

Static Function SB1Valid(oPedidoObc)

	Local cRet    := ""
	Local cRetSF4 := ""
	Local cRetNNR := ""
	Local cCodSB1 := ""
	Local nX      := 0
	Local cQuery  := ""

	For nX := 1 to Len(oPedidoObc:Itens)

		cCodSB1 := AllTrim(oPedidoObc:Itens[nX]:codProduto)
		
		//DbSelectArea('SB1')
		//SB1->(dbSetOrder(1))
		//SB1->(DbGoTop())

		cQuery := " SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_COD = '"+Alltrim(cCodSB1)+"' AND B1_FILIAL = '"+FWFilial("SB1")+"' AND D_E_L_E_T_ = ''  "

		if SELECT("T01") > 0
            T01->(dbCloseArea())
        endif

        TcQuery cQuery new Alias T01

		if T01->(EOF())
			cRet += IIf(Empty(cRet), "", " | ") + "Produto de codigo [" + cCodSB1 + "] nao encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
		Else
			If (T01->B1_MSBLQL == "1")
				cRet += IIf(Empty(cRet), "", " | ") + "Produto de codigo [" + cCodSB1 + "] encontra-se bloqueado para uso!"
			Else
				cRetSF4 := SF4Valid(T01->B1_COD, T01->B1_TE)

				If !(Empty(cRetSF4))
					cRet += IIf(Empty(cRet), "", " | ") + cRetSF4
				EndIf

				cRetNNR := NNRValid(T01->B1_COD, T01->B1_LOCPAD)

				If !(Empty(cRetNNR))
					cRet += IIf(Empty(cRet), "", " | ") + cRetNNR
				EndIf
			EndIf
		EndIf
	End

	if SELECT("T01") > 0
        T01->(dbCloseArea())
    Endif

Return(cRet)

Static Function SF4Valid(cCodSB1, cCodSF4)

	Local cRet := ""

	If (Empty(cCodSF4))
		cRet := "Produto [" + cCodSB1 + "] na empresa [" + cEmpAnt + "-" + cFilAnt + "] nao possui TES cadastrada!"
	Else
		SF4->(DbSetOrder(1))
		If !(SF4->(DbSeek(FWFilial("SF4")+cCodSF4)))
			cRet := "Nao foi encontrada a TES [" + cCodSF4 + "] " + " para o produto [" + cCodSB1 + "] na empresa [" + cEmpAnt + "-" + cFilAnt + "]"
		Else
			If (SF4->F4_MSBLQL == "1")
				cRet := "TES [" + cCodSF4 + "] " + " para o produto [" + cCodSB1 + "] na empresa [" + cEmpAnt + "-" + cFilAnt + "] encontra-se bloqueada para uso!"
			EndIf
		EndIf
	EndIf

Return(cRet)

Static Function NNRValid(cCodSb1, cCodNNR)

	Local cRet := ""

	NNR->(DbSetOrder(1))
	If !(NNR->(DbSeek(FWFilial("NNR")+cCodNNR)))
		cRet := "Nao foi encontrado o armazem [" + cCodNNR + "] " + " do produto [" + cCodSB1 + "] na empresa [" + cEmpAnt + "-" + cFilAnt + "]"
	EndIf

Return(cRet)

Static Function SA2Valid(oPedidoObc)

	Local cRet     := ""
	Local cCgc     := oPedidoObc:cnpjFornecedor
	Local lBloq    := .T.
	Local cRetBloq := ""

	If (Len(cCgc) == 10)
		cAliSA2 := SA2CodOBC(cCgc)

		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
		If (!Empty((cAliSA2)->A2_COD) .And. (SA2->(DbSeek(FWFilial("SA2")+(cAliSA2)->A2_COD+(cAliSA2)->A2_LOJA))))
			If (SA2->A2_MSBLQL == "1")
				cRetBloq += "Fornecedor encontra-se bloqueado! CPF/CNPJ [" + cCgc + "] / Cod-Loja [" + SA2->A2_COD + "-" + SA2->A2_LOJA + "]"
			EndIf
		EndIf
	Else
		SA2->(DbSetOrder(3))
		SA2->(DbGoTop())
		If !(SA2->(DbSeek(FWFilial("SA2")+AllTrim(cCgc))))

			If (oPedidoObc:temFornecedor)
				SA2Inserir(oPedidoObc)

				SA2->(DbSetOrder(3))
				SA2->(DbGoTop())
				If !(SA2->(DbSeek(FWFilial("SA2")+AllTrim(cCgc))))
					cRet := "Fornecedor de CPF/CNPJ [" + cCgc + "] nao encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
					cErrorCode := "CNPJ_NAO_ENCONTRADO"
				EndIf
			Else
				SA2->(DbGoTop())
				If !(SA2->(DbSeek(FWFilial("SA2")+AllTrim(cCgc))))
					cRet := "Fornecedor de CPF/CNPJ [" + cCgc + "] nao encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"
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

					cRetBloq += "Fornecedor encontra-se bloqueado! CPF/CNPJ [" + cCgc + "] / Cod-Loja [" + SA2->A2_COD + "-" + SA2->A2_LOJA + "]"
					SA2->(DbSkip())
				EndIf
			End

			If (lBloq)
				cRet += cRetBloq
			EndIf
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
		cRet := "Condicao de pagamento [" + cCond + "] nao encontrado em [" + cEmpAnt + "-" + cFilAnt + "]"

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

	_cAliasSE4 := MpSysOpenQuery(_cQuery)

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

	_cAliasSE4 := MpSysOpenQuery(_cQuery)

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

	cX3_Relacao := GetSX3Cache("C7_NUM", "X3_RELACAO")

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
		lJaExiste := SC7->(DbSeek(FWFilial("SA1")+cCodNovo))
	End

Return(cCodNovo)

Static Function SE4NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.


	cX3_Relacao := GetSX3Cache("E4_CODIGO", "X3_RELACAO")

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
		lJaExiste := SE4->(DbSeek(FWFilial("SE4")+cCodNovo))
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
			SE4->E4_FILIAL   := FWFilial("SE4")
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

	_cAlias := MpSysOpenQuery(_cQuery)

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
	conout(' ------> Pedido:  '+cCodSC7)
	aAdd(aCabec,{"C7_FILIAL", FWFilial("SC7")})
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
		
		//Caso tenha desconto, soma no valor
		If (oItPedido:descTotalItem > 0)
			aAdd(aLinha,{"C7_PRECO", oItPedido:valorUnit + (oItPedido:descTotalItem /oItPedido:quantidade) , Nil})
			aAdd(aLinha,{"C7_VLDESC", oItPedido:descTotalItem, Nil})
			If (SC7->(FieldPos("C7_PRECOT")) > 0)
				aAdd(aLinha,{"C7_PRECOT", oItPedido:valorUnit + (oItPedido:descTotalItem / oItPedido:quantidade), Nil})
			EndIf
		else
			aAdd(aLinha,{"C7_PRECO", oItPedido:valorUnit , Nil})
			If (SC7->(FieldPos("C7_PRECOT")) > 0)
				aAdd(aLinha,{"C7_PRECOT", oItPedido:valorUnit, Nil})
			EndIf
		EndIf


		/*Conout("************************")	
		Conout("C7_NUM Pedido")
		Conout(cCodSC7)
		Conout("C7_XPEDOBC")
		Conout( oItPedido:codPedidoObc)
		Conout("C7_XSDCOBC")
		Conout(oItPedido:codSdcv)
		Conout('C7_VLDESC descTotalItem:')
		Conout( oItPedido:descTotalItem)
		Conout( 'C7_QUANT oItPedido:quantidade')
		Conout( oItPedido:quantidade)
		Conout('C7_PRECO valorUnit')
		Conout(oItPedido:valorUnit)
		Conout("************************")*/

		//conout(oItPedido:armazem)

		DbSelectArea('SB1')
		DbsetOrder(1)
		DbSeek(xFilial('SB1') + AllTrim(oItPedido:codProduto))

		aAdd(aLinha,{"C7_TES", SB1->B1_TE, Nil})
		aAdd(aLinha,{"C7_TXMOEDA", 0, Nil})
		aAdd(aLinha,{"C7_FLUXO", "S", Nil})
		aAdd(aLinha,{"C7_DATPRF", StoD(oItPedido:dtEntrega), Nil})
		aAdd(aLinha,{"C7_EMITIDO", "S", Nil})
		aAdd(aLinha,{"C7_SOLICIT", oItPedido:solicitante, Nil})
		aAdd(aLinha,{"C7_OBS", oPedidoObc:observacao, Nil})
		If alltrim(oItPedido:armazem) <> ''
			aAdd(aLinha,{"C7_LOCAL", oItPedido:armazem, Nil})
		Endif 
		aAdd(aLinha,{"C7_XRECOBC", oPedidoObc:recno, Nil})
		aAdd(aLinha,{"C7_XPEDOBC", oItPedido:codPedidoObc, Nil})
		aAdd(aLinha,{"C7_XSDCOBC", oItPedido:codSdcv, Nil})
		aAdd(aLinha,{"C7_XTIPOBC", oItPedido:tipoSdcv, Nil})

		If Len(oItPedido:ratCCusto) == 1
			aAdd(aLinha,{"C7_CONTA", SB1->B1_CONTA, Nil})

			If !(  "COMPRA_" $ Upper(alltrim(oItPedido:centroCusto)) )//(oItPedido:centroCusto <> "COMPRA_REVENDA" .And. oItPedido:centroCusto <> "COMPRA_ESTOQUE")
				aAdd(aLinha,{"C7_CC", oItPedido:centroCusto, Nil})
			Else
				aAdd(aLinha,{"C7_CC", "", Nil})
			EndIf

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
		oRetObc:email        := "leandro.h@agricopel.com.br"//Chamado 592115
		Conout(oRetObc:errorMessage)
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


Static Function SC7Excluir(oPedidoObc)

	Local aCabec    := {}
	Local aItens    := {}
	Local cPedido   := ""

	Private lMsErroAuto := .F.

	cPedido := oPedidoObc:codPedidoErp

	//Posiciona no pedido
	dbselectarea('SC7')
	dbsetorder(1)
	If Dbseek(xFilial('SC7') + cPedido )

			cFornece := SC7->C7_FORNECE
			cLoja    := SC7->C7_LOJA 


            //Monta o cabeçalho do pedido de compras apenas se houver itens
            aadd(aCabec,{"C7_NUM"       , cPedido})
            aadd(aCabec,{"C7_FORNECE"   , cFornece})
            aadd(aCabec,{"C7_LOJA"      , cLoja})

            //Executa a inclusão automática de pedido de compras
            //FwLogMsg("INFO",, "ExcluirPedido", "SC7Excluir", "", "01", "MSExecAuto")
			conout('Excluindo pedido: '+cPedido)
            MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCabec,aItens,5,.F.)

            //Se houve erro, gera um arquivo de log dentro do diretório da protheus data
            If lMsErroAuto
                aLogAuto := {}
                aLogAuto := GetAutoGrLog()                
                cError   := GravaLog(cArqLog,aLogAuto)
				Conout("Erro ao excluir Pedido: "+cPedido + " - " + cError)

				oRetObc:errorMessage := "Pedido: [" + cPedido + "]["+ cEmpAnt + "-" + cFilAnt + "] - Erro: " + cError
				oRetObc:Sucesso      := .F.
				oRetObc:email        := "leandro.h@agricopel.com.br"//Chamado 592115

	        Else
                Conout("Pedido Excluido: " + cPedido)
				oRetObc:CodPedido := cPedido
				oRetObc:Sucesso   := .T.
				oRetObc:errorMessage := ""
              
            EndIF
    Else
        conout("Pedido: "+ Alltrim(cPedido) +" nao encontrado!")
		oRetObc:errorMessage := "Pedido: [" + cPedido + "]["+ cEmpAnt + "-" + cFilAnt + "] - Erro: " + cError
		oRetObc:Sucesso      := .F.
		oRetObc:email        := "leandro.h@agricopel.com.br"//Chamado 592115
        //Self:SetResponse('{"noPedido":"", "infoMessage":"", "errorCode":"404",  "errorMessage":"O pedido de compras '+ cPedido +' nao existe" }')
        //FreeObj(oJson)
    	//lRet := .F.
    Endif               


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

		aAdd(aItRatCC,{"CH_FILIAL", FWFilial("SCH"), Nil})
		aAdd(aItRatCC,{"CH_ITEM", StrZero(nX, nTamanho), Nil})
		aAdd(aItRatCC,{"CH_PERC", oRatCCusto:pRateio, Nil})

		If !(  "COMPRA_" $ Upper(alltrim(oItPedido:centroCusto)) )//(oRatCCusto:centroCusto <> "COMPRA_REVENDA" .And. oRatCCusto:centroCusto <> "COMPRA_ESTOQUE")
			aAdd(aItRatCC,{"CH_CC", oRatCCusto:centroCusto, Nil})
		Else
			aAdd(aItRatCC,{"CH_CC", "", Nil})
		EndIf

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

	If (CGC(oFornObc:cpfCnpj)) // Validacao de CPF/CNPJ

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
		SA2->A2_FILIAL     := FWFilial("SA2")
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

	cAliasQry := MpSysOpenQuery(cQuery)

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

	cX3_Relacao := GetSX3Cache("A2_COD", "X3_RELACAO")

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
		lJaExiste := SA2->(DbSeek(FWFilial("SA2")+cCodNovo))
	End

Return(cCodNovo)

Static Function SA2CodOBC(cCodObc)

	Local _cQuery   := ""
	Local cAliasQry := ""

	_cQuery := " SELECT A2_MSBLQL, A2_CGC, A2_NOME, A2_COD, A2_LOJA "
	_cQuery += " FROM " + RetSQLName("SA2") + " SA2 (NOLOCK) "
	_cQuery += " WHERE SA2.D_E_L_E_T_ = '' "
	_cQuery += " AND   SA2.A2_ZCODOBC = '" + cCodObc + "'"

	cAliasQry := MpSysOpenQuery(_cQuery)

Return(cAliasQry)

Static Function SC7Find(cCodSDCV)

	Local _cQuery   := ""
	Local cAliasQry := ""
	Local _cRet     := ""

	_cQuery := " SELECT DISTINCT(SC7.C7_NUM) AS C7_NUM "
	_cQuery += " FROM " + RetSQLName("SC7") + " SC7 (NOLOCK) "
	_cQuery += " WHERE SC7.D_E_L_E_T_ = '' "
	_cQuery += " AND   SC7.C7_XSDCOBC = '" + cCodSDCV + "'"

	cAliasQry := MpSysOpenQuery(_cQuery)

	While !((cAliasQry)->(Eof()))
		_cRet := (cAliasQry)->C7_NUM

		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())

Return(_cRet)


Static Function GravaLog(cArqLog,aLogAuto)
    Local i     := 0
    Local cErro := ""

    For i := 1 To Len(aLogAuto)
        cErro += EncodeUTF8(aLogAuto[i])+CRLF
    Next i

    MemoWrite(PATHLOGSW + "\" + cArqLog,cErro)
Return(cErro)
