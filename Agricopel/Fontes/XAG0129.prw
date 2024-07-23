#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'
#include "rwmake.ch"
#include "tbiconn.ch"
#include 'protheus.ch'
#include 'parmtype.ch'

/*
-------------------------------------------------------------------
{Protheus.doc} User Function XAG0129
    Job que realiza a integração dos dados da tabela ZZ9 com o pedido de vendas

    @author Matheus Bussadori
    @since 14/09/2023
    @version 1.00
-------------------------------------------------------------------
*/
User Function XAG0129(cJson, lRetorno, cComando, oJson,cStatus)
	Local aCabec        	:= {}
	Local aItens        	:= {}
	Local aGrid 			:= {}
	Local nAtual        	:= 0
	Local cNumPed       	:= ""
	Local aErroAuto     	:= {}
	Local cCodProduto 		:= ""
	Local cIdPed 			:= ""
	Local cTipoFrete 		:= ""
	Local nPrcItem 			:= 0
	Local aLog 				:= {}
	//Local aDatas    		:= {}
	Local cCondPag  		:= ""
	Local nPosValor			:= 0
	Local cCodCli 			:= ""
	Local cLojaCli 			:= ""
	Local cTransp  			:= ""
	Local nValorTot 		:= 0
	Local cCodTransp 		:= ""
	Local xRetCondPag 		:= .F.
	Local nTotalDesc 		:= 0
	Local cCodMun 			:=  ""
	Local dDtEntreg
	Local cQry 				:= ""
	Local cAliasSA1 		:= GetNextAlias()
	Local cAliasSC5 		:= ""

	PRIVATE cProdFil		:= ""
	PRIVATE cTpProd 		:= ""
	PRIVATE cTipoVend 		:= ""
	//PRIVATE oJson
	PRIVATE lMsErroAuto   	:= .F.
	PRIVATE lAutoErrNoFile	:= .T.
	PRIVATE cLogErro      	:= ""


	//oJson := JsonObject():New()
	//oJsonRet := JsonObject():New()
	//oJson:FromJson(cJson)

	DbSelectArea('SA1')
	SA1->(DbSetOrder(1))

	aAdd(aLog, {Time(), "Carregando o Json"})

	cTipoVend 	:= oJson['capaPedido']['TipoDeVenda']
	cTipoFrete 	:= oJson['capaPedido']['TipoFrete']
	aCabec 		:= {}
	cNumPed 	:= GETSXENUM('SC5','C5_NUM')
	cIdPed 		:= cNumPed
	dDtEntreg 	:= StoD(StrTran(oJson['capaPedido']['DtEntrega'], "-", ""))
	cCondPag 	:= oJson['capaPedido']['CondPagamento']
	cLojaCli 	:= oJson['capaPedido']['LojaCliente']
	cCodCli 	:= oJson['capaPedido']['CodigoCliente']
	cTransp 	:= ""
	xRetCondPag := u_VldCondPag(oJson)
	cCodMun 	:= oJson['capaPedido']['CodCidadeEntrega']

	aAdd(aLog, {Time(), "Declarando as variaveis genericas"})

	cQry := " SELECT A1_COD, A1_LOJA, A1_TIPO FROM " + RetSqlName('SA1') + CRLF
	cQry += " WHERE A1_COD = '" + cCodCli + "'" + CRLF
	cQry += " AND A1_LOJA = '" + cLojaCli + "'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasSA1)


	aAdd(aCabec, {"C5_FILIAL", 	cFilant,																			NIL})
	aAdd(aCabec, {"C5_NUM",     cNumPed,                                            								NIL})
	aAdd(aCabec, {"C5_CLIENTE", oJson['capaPedido']['CodigoCliente'],               								NIL})
	aAdd(aCabec, {"C5_TIPO", 	"N",              									 								NIL})
	aAdd(aCabec, {"C5_TIPOCLI", (cAliasSA1)->A1_TIPO,               												NIL})
	aAdd(aCabec, {"C5_NOMECLI", oJson['capaPedido']['NomeCliente'],                 								NIL})
	aAdd(aCabec, {"C5_LOJACLI", oJson['capaPedido']['LojaCliente'],                 								NIL})
	aAdd(aCabec, {"C5_LOJAENT", oJson['capaPedido']['LojaCliente'],                 								NIL})
	aAdd(aCabec, {"C5_CONDPAG", oJson['capaPedido']['CondPagamento'],               								NIL})
	aAdd(aCabec, {"C5_TPFRETE", cTipoFrete,                  														NIL})
	aAdd(aCabec, {"C5_EMISSAO",	StoD(StrTran(oJson['capaPedido']['DtEmissao'], "-", "")),  							NIL})
	aAdd(aCabec, {"C5_XMARKET",	oJson['capaPedido']['Marketing'],                   								NIL})
	aAdd(aCabec, {"C5_XIDSF",	oJson['capaPedido']['SalesforceId'],												NIL})
	aAdd(aCabec, {"C5_BAIRROE",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['BairroEntrega'])),						NIL})
	aAdd(aCabec, {"C5_CEPE",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['CepEntrega'])),							NIL})
	aAdd(aCabec, {"C5_ENDENT",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['EnderecoEntrega'])),						NIL})
	aAdd(aCabec, {"C5_ESTE",	oJson['capaPedido']['UfEntrega'],													NIL})
	aAdd(aCabec, {"C5_MUNE",	DecodeUtf8(EncodeUtf8(oJson['capaPedido']['MunEntrega'])),							NIL})
	aAdd(aCabec, {"C5_XCODMUN",	DecodeUtf8(EncodeUtf8(SubStr(cCodMun, 3))),										NIL})
	aAdd(aCabec, {"C5_FECENT",  StoD(StrTran(oJson['capaPedido']['DtEntrega'], "-", "")),							NIL})
	aAdd(aCabec, {"C5_XCOMTEL",	oJson['capaPedido']['ComisTeleve'],													NIL})
	aAdd(aCabec, {"C5_XCOMREP",	oJson['capaPedido']['ComisRepres'],													NIL})

	IF !Empty(oJson['capaPedido']['NumTransacao']) .AND. xRetCondPag
		aAdd(aCabec, {"C5_XNRTRAN", oJson['capaPedido']['NumTransacao'],												NIL})
	ENDIF
	IF cTipoFrete = "F"
		IF Empty(oJson['capaPedido']['Transportadora'])
			SetRestFault(400, "Erro - A transportadora precisa ser preenchida quando o frete for do tipo 'FOB' ")
		Else
			aAdd(aCabec, {"C5_TRANSP",  oJson['capaPedido']['Transportadora'],			NIL})
		ENDIF
	ELSE
		//cTransp := Transp(oJson)
		DbSelectArea('SM0')
		SA4->(DbSetOrder(3))
		IF SA4->(DbSeek(FWxFilial('SA4') + SM0->M0_CGC))
			cCodTransp := SA4->A4_COD
			SA4->(DbCloseArea())
		ELSE
			DbSelectArea("SA1")
			DbSetOrder(1) //Filial+Cliente+Loja
			IF DbSeek(xFilial("SA1")+oJson['capaPedido']['CodigoCliente']+oJson['capaPedido']['LojaCliente'])
				cCodTransp := SA1->A1_TRANSP
			ELSE
				cCodTransp := '000001'
			Endif
		ENDIF
		aAdd(aCabec, {"C5_TRANSP", cCodTransp,						NIL})
	ENDIF


	IF ! Empty(oJson['capaPedido']['CodClienteEntrega']) .AND. ! Empty(oJson['capaPedido']['LojaClienteEntrega'])
		aAdd(aCabec, {"C5_XCLIENT",	oJson['capaPedido']['CodClienteEntrega'],											NIL})
		aAdd(aCabec, {"C5_XLOJA",	oJson['capaPedido']['LojaClienteEntrega'],											NIL})
	ENDIF
	//VALIDAÇÕES PARA NÃO ADICIONAR CAMPOS VAZIOS
	IF ! Empty(oJson['capaPedido']['Representante'])
		aAdd(aCabec, {"C5_VEND7",	oJson['capaPedido']['Representante'],						NIL})
	ENDIF

	IF ! Empty(oJson['capaPedido']['Televendas'])
		aAdd(aCabec, {"C5_VEND6",	oJson['capaPedido']['Televendas'],							NIL})
	ENDIF

	IF ! Empty(oJson['capaPedido']['ObsNF'])
		aAdd(aCabec, {"C5_MENNOTA", oJson['capaPedido']['ObsNF'],                       NIL})
	ENDIF
	IF ! Empty(oJson['capaPedido']['CadastroProdutorRural'])
		aAdd(aCabec, {"C5_XRURAL", 	oJson['capaPedido']['CadastroProdutorRural'],		NIL})
	ENDIF
	IF ! Empty(oJson['capaPedido']['OrdemDeCompra'])
		aAdd(aCabec, {"C5_MENS2", 	"Ordem de compra " + oJson['capaPedido']['OrdemDeCompra'],				NIL})
	ENDIF

	aAdd(aCabec, {"C5_TABELA",  oJson['capaPedido']['CodTabelaPreco'],             	NIL})

	IF 	cTipoVend == "TTD" .AND. !Empty(oJson['capaPedido']['ObsTTD'])
		aAdd(aCabec, {"C5_MENS1", 	oJson['capaPedido']['ObsTTD'],                	    NIL})
	ENDIF

	IF U_ValidVnd(cTipoVend)
		aAdd(aCabec, {"C5_XTPVEND",		cTipoVend,                   					NIL})
	ENDIF

	IF cTipoVend == 'TTD'
		aAdd(aCabec, {"C5_OBSERVA", 	"Cliente TTD " + oJson['capaPedido']['ObsLogistica'],		NIL})
	ELSEIF ! Empty(oJson['capaPedido']['ObsLogistica'])
		aAdd(aCabec, {"C5_OBSERVA", 	oJson['capaPedido']['ObsLogistica'],						NIL})
	ENDIF

	aAdd(aLog, {Time(), "Carregou a SC5"})


	For nAtual := 1 to Len(oJson['itemPedido'])
		cCodProduto := oJson['itemPedido'][nAtual]['Produto']
		aItens := {}
		aAdd(aItens, {"C6_FILIAL",     	cFilant,																												NIL})
		aAdd(aItens, {"C6_ITEM",        cValToChar(StrZero(nAtual, 2)),                																			NIL})
		aAdd(aItens, {"C6_PRODUTO",     Alltrim(cCodProduto),             																						NIL})
		aAdd(aItens, {"C6_QTDVEN",      oJson['itemPedido'][nAtual]['Quantidade'],          																	NIL})
		aAdd(aItens, {"C6_XQTDORI",     oJson['itemPedido'][nAtual]['Quantidade'],          																	NIL})
		IF cTipoVend = 'TTD'  .AND. oJson['itemPedido'][nAtual]['ValorDesconto'] > 0
			nPrcItem := calcDesc(oJson['itemPedido'][nAtual]['ValorUnitario'], oJson['itemPedido'][nAtual]['ValorDesconto'])
			aAdd(aItens, {"C6_PRCVEN",       oJson['itemPedido'][nAtual]['ValorUnitario'],																		NIL})
			aAdd(aItens, {"C6_PRUNIT",      oJson['itemPedido'][nAtual]['ValorUnitario'],																		NIL})
		ELSE
			nPrcItem := oJson['itemPedido'][nAtual]['ValorUnitario']
			aAdd(aItens, {"C6_PRCVEN",       oJson['itemPedido'][nAtual]['ValorUnitario'],																		NIL})
			aAdd(aItens, {"C6_PRUNIT",       oJson['itemPedido'][nAtual]['ValorUnitario'],																		NIL})
		ENDIF
		aAdd(aItens, {"C6_LOCAL",       oJson['itemPedido'][nAtual]['Armazem'],             																	NIL})
		aAdd(aItens, {"C6_TES",         u_TipoTes(cCodCli,cLojaCli,cTipoVend,cCodProduto,oJson['capaPedido']['UfEntrega']), 																		NIL})
		aAdd(aItens, {"C6_VALOR",       A410Arred( oJson['itemPedido'][nAtual]['ValorUnitario'] *  oJson['itemPedido'][nAtual]['Quantidade'], "C6_VALOR"),      NIL})
		aAdd(aItens, {"C6_NUM",         cNumPed,                                            																	NIL})
		aAdd(aItens, {"C6_ENTREG",  	StoD(StrTran(oJson['capaPedido']['DtEntrega'], "-", "")),																NIL})
		aAdd(aItens, {"C6_XIDSF",       oJson['itemPedido'][nAtual]['SalesforceId'],             																NIL})

		IF cFilAnt $ "16/03"
			aAdd(aItens, {"C6_CF", 			RegFil(oJson), 																											NIL})
		ENDIF

		IF ! Empty(oJson['capaPedido']['OrdemDeCompra'])
			aAdd(aItens, {"C6_PEDCLIN",         oJson['capaPedido']['OrdemDeCompra'],                                            								NIL})
			aAdd(aItens, {"C6_PEDCLIT",         cValToChar(StrZero(nAtual, 3)),                                            										NIL})
		ENDIF

		IF cTipoVend <> "TTD"
			nPosValor := aScan(aItens,{|x| Alltrim(Upper(x[1])) == "C6_VALOR"})
			nValorTot += aItens[nPosValor][2]
		ELSE
			nPosValor := aScan(aItens,{|x| Alltrim(Upper(x[1])) == "C6_VALOR"})
			nValorTot += aItens[nPosValor][2] - oJson['itemPedido'][nAtual]['ValorDescTot']
		ENDIF


		IF oJson['capaPedido']['Comando'] == 'C' .AND. cTipoVend == "TTD"
			nTotalDesc += oJson['itemPedido'][nAtual]['ValorDescTot']
		ELSE
			oJson['itemPedido'][nAtual]['Tes']  := u_TipoTes(cCodCli,cLojaCli,cTipoVend,cCodProduto,oJson['capaPedido']['UfEntrega'])
		ENDIF


		aAdd(aGrid, aItens)
	Next
	aAdd(aLog, {Time(), "Carregou a SC6"})

	aAdd(aCabec, {'C5_DESCONT', 		nTotalDesc,			NIL})

	cAliasSC5 := GetNextAlias()
	cQry := " SELECT C5_NUM, C5_XIDSF FROM " + RetSqlName('SC5') + CRLF
	cQry += " WHERE C5_XIDSF = '" + oJson['capaPedido']['SalesforceId'] + "'" + CRLF

	PlsQuery(cQry, cAliasSC5)

	IF (cAliasSC5)->(EoF())
		IF oJson['capaPedido']['Comando'] == 'C'
			BEGIN transaction
				MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aGrid, 3)


				//Caso não de certo a inclusão, ira gerar um registro na ZZ9 para log e analise da equipe de TI
				ConfirmSX8()
				If lMsErroAuto
					DisarmTransaction()
					aErroAuto := GetAutoGRLog()
					For nAtual := 1 To Len(aErroAuto)
						cLogErro += StrTran(StrTran(aErroAuto[nAtual], "<", ""), "-", "") + " " + CRLF
					Next
					cIdPed 	:= GetSXENum("ZZ9","ZZ9_ID")
					Reclock("ZZ9",.T.)
					ZZ9->ZZ9_FILIAL := cFilAnt
					ZZ9->ZZ9_ID 	:= cIdPed
					ZZ9->ZZ9_ROTINA := "VENDA"
					ZZ9->ZZ9_DATA 	:= Date()
					ZZ9->ZZ9_LOG  	:= cLogErro
					ZZ9->ZZ9_STATUS := "P"
					ZZ9->ZZ9_JSON 	:= cJson
					ZZ9->(MsUnLock())
					lRetorno := .F.
					aAdd(aLog, {Time(), "Carregou a Log"})
					ConfirmSX8()
				ENDIF
				aAdd(aLog, {Time(), "Pedido gerado com sucesso"})

				cComando := oJson['capaPedido']['Comando']

				cQuery := " SELECT C9_BLCRED, C9_BLEST FROM "+RetSqlName("SC9")+" WHERE C9_PEDIDO = '"+SC5->C5_NUM+"' AND C9_FILIAL = '"+SC5->C5_FILIAL+"' AND D_E_L_E_T_ = '' AND ( C9_BLCRED <> '' OR C9_BLEST <> '' ) "
				cAlias := GetNextAlias()

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAlias, .F., .T.)


				//Customização solicitada pela Camila, sempre que estiver bloquado por estoque e crédito retornar o bloquei de crédito
				IF !Empty((cAlias)->C9_BLCRED) .AND. !Empty((cAlias)->C9_BLEST)
					//cStatus := "Bloqueado por crédito"
					cStatus := "Bloqueado por crédito"
				ELSEIF !Empty((cAlias)->C9_BLEST)
					//cStatus :=  "Bloq Estoque"
					cStatus :=  "Bloqueado por estoque"
				ELSEIF !Empty((cAlias)->C9_BLCRED)
					//cStatus := "Bloq Financeiro"
					cStatus := "Bloqueado por crédito"
				ELSEIF Empty(SC5->C5_LIBEROK)
					cStatus :=  "Em Aberto"
				ELSEIF !Empty(SC5->C5_VEICULO)
					cStatus := "Programado"
				ELSEIF Empty(SC5->C5_NOTA) .and. SC5->C5_LIBEROK == "S"
					cStatus :=  "Liberado"
				ELSEIF !Empty(SC5->C5_NOTA)
					cStatus := "Faturado"
				EndIF

			END Transaction
		ELSE
			cComando := oJson['capaPedido']['Comando']
			oJson['Datas'] :={}
			DtBoleto(nValorTot, cCondPag, dDtEntreg, @oJson)
		ENDIF
	ELSE 
		cIdPed := (cAliasSC5)->C5_NUM
	ENDIF


	aAdd(aLog, {Time(), "Finalização da rotina"})

Return cIdPed

/*
-------------------------------------------------------------------
{Protheus.doc} ValidVnd
	Valida o tipo de venda

	@author Matheus Bussadori
	@since 15/09/2023
	@version 1.00
	@return cLog, "C", Armazena o log de erros se tiver
-------------------------------------------------------------------
*/
User Function ValidVnd(cTipoVenda)
	Local lRet 			:= .T.

	IF cTipoVenda == "TTD" .AND. ! cNumEmp =='0103'
		cLogErro += "Erro - A filial selecionada não pode utilizar este tipo de venda (TTD) " + CRLF
		lRet := .F.
	ELSEIF cTipoVenda $ "RT|VT|RE|VE" .AND. ! UPPER(cProdFil) == "ARLA"
		cLogErro += "Erro - O tipo de venda selecionado só pode ser utilizado por filiais que utilizam o TIPO DE PRODUTO = 'Arla' " + CRLF
		lRet := .F.
	ENDIF

Return lRet


/*
-------------------------------------------------------------------
{Protheus.doc} TipoTes
	Valida o tipo de Tes que precisa ser utilizado a partir do tipo de venda

	@author Matheus Bussadori
	@since 18/09/2023
	@version 1.00
	@param cTipoVenda, 'C', Tipo de venda utilizado no pedido
	@param cCodProd, 'C', Codigo do produto para pegar a TES
	@return cTes, "C", Tipo da Tes utilizada nos produtos
-------------------------------------------------------------------
*/
user Function TipoTes(cCodCli, cLojacli,cTipoVenda, cCodProd,cUfEnt)
	Local cTes 		:= ""
	Local cQry 		:= ""
	Local cAliasSA1 := GetNextAlias()
	Local cAliasSB1 := GetNextAlias()
	Local cTipoCli := ""
	Local cTpPrd := ""

	SA1->(DbSetOrder(1))

	cQry := " SELECT A1_COD, A1_LOJA, A1_TIPO, A1_EST FROM " + RetSqlName('SA1') + CRLF
	cQry += " WHERE A1_COD = '" + cCodCli + "'" + CRLF
	cQry += " AND A1_LOJA = '" + cValToChar(cLojaCli) + "'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasSA1)

	IF !(cAliasSA1)->(EoF())
		cTipoCli := (cAliasSA1)->A1_TIPO
		cUF := (cAliasSA1)->A1_EST
	ENDIF
	


	IF cTipoVenda == 'B'
		cTes := '507'
	ElseIf cTipoVenda == 'N' .OR. cTipoVenda == 'S' .OR. cTipoVenda == 'TTD'
		cTes := POSICIONE('SB1',1,FWxFilial('SB1') + cCodProd, 'B1_TS')
	Elseif cTipoVenda == 'RT'
		cTes := '704'
	Elseif cTipoVenda == 'VT'
		cTes := '703'
	Elseif cTipoVenda == 'RE'
		cTes := '629'
	Elseif cTipoVenda == 'VE'
		cTes := '591'
	Endif


//Regra De GO INICIO
	cQry := " SELECT B1_TIPO FROM " + RetSqlName('SB1') + CRLF
	cQry += " WHERE B1_COD = '" + Alltrim(cCodProd) + "' " + CRLF
	cQry += " AND B1_FILIAL = '" + cFilAnt + "' " + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasSB1)

	IF !(cAliasSB1)->(EoF())
		cTpPrd := (cAliasSB1)->B1_TIPO
	ENDIF

	Conout("TES " + cTes)

	If cFilAnt $ "17" .AND. cTipoCli == 'R' .AND. cUfEnt == "GO" .AND. cUf == "GO" .AND. cTpPrd $ "AE/AG"
		cTes := '616'
	EndIf 
//Regra De GO FIM

	IF Empty(cTes)
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+cCodProd)
			cTes := SB1->B1_TS
		EndIf
	ENDIF

Return cTes

/*
 -------------------------------------------------------------------
 {Protheus.doc} zOpcoes
	Carrega a lista de opções do campo C5_XTPVEND

	@author Matheus Bussadori
	@since 18/09/2023
	@version 1.00
	@return cOpcoes, 'C', Retorna as opções do campo
-------------------------------------------------------------------
*/
user Function zOpcoes()
	Local aArea 	:= GetArea()
	Local cOpcoes 	:= ""

	cOpcoes += "N=Normal;"
	cOpcoes += "B=Bonificação;"
	cOpcoes += "TTD=Tratamento Tributário Diferenciado;"
	cOpcoes += "RT=Remessa Triangular;"
	cOpcoes += "VT=Venda Triangular;"
	cOpcoes += "RE=Remessa Exportação;"
	cOpcoes += "VE=Venda Exportação;"

	RestArea(aArea)
Return cOpcoes

/*
-------------------------------------------------------------------
{Protheus.doc} TabPreco
	Valida a tabela de preço

	@author Matheus Bussadori
	@since 18/09/2023
	@version 1.00
	@param cCodTab, "C", Codigo da tabela de preço
	@return lRet, "L", Retorna .T. ou .F.
-------------------------------------------------------------------
*/
Static Function TabPreco(cCodTab, cCodProd)
	Local lRet 		:= .F.

	//DbSelectArea('DA1')
	DA1->(DbSetOrder(1))
	IF DA1->(DbSeek(FWxFilial('DA1') + cCodTab))
		IF DA1->DA1_DATVIG > Date()
			lRet 	:= .T.
		ENDIF
	ENDIF

Return lRet



/*
-------------------------------------------------------------------
{Protheus.doc} TipoProd
	Verifica qual é o tipo de produto da filial

	@author Matheus Bussadori
	@since 20/09/2023
	@version 1.00
	@return cProdFil, "C", Produto utilizado pela filial
-------------------------------------------------------------------
*/
Static Function TipoProd()
	Local cProdFil 	:= ""

	cTpProd := SuperGetMV("MV_XTPPROD", .F., "")

	cTpProd := StrTokArr(cTpProd,";")

	IF cFilAnt  $ "01|02"
		cProdFil := cTpProd[1]
	ELSEIF cFilAnt $ "15"
		cProdFil := cTpProd[2]
	ENDIF

Return cProdFil


/*
-------------------------------------------------------------------
{Protheus.doc} calcDesc
	Calcula o valor de desconto do item

	@author Matheus Bussadori
	@since 18/10/2023
	@version 1.00
	@param nPreco, "N", preco de venda atual
	@param nDesc, "N", Porcentam de desconto a ser aplicada
	@return nPrcDesc, "N"", Preço final do item
-------------------------------------------------------------------
*/
Static Function calcDesc(nPreco, nDesc)
	Local nPrcRet 	:= 0
	Local nValDesc	:= 0

	nValDesc := nPreco * (nDesc / 100)
	nPrcRet := nPreco - nValDesc

Return nPrcRet


/*/{Protheus.doc} User Function XAG0123
	Rotina para tratar os acentos
	@type  Static Function
	@author weskley.silva
	@since 16/08/2023
	@version 1.0
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

STATIC FUNCTION NoAcento2(cVar)
	
	
	cVar := StrTran(cVar, "-", "") 
	cVar := StrTran(cVar, "Ç", "")
	cVar := StrTran(cVar, "ç", "")
	cVar := StrTran(cVar, "*", "")
	cVar := StrTran(cVar, "&", "")
	cVar := StrTran(cVar, "¨¨", "")
	cVar := StrTran(cVar, ")", "")
	cVar := StrTran(cVar, "(", "")
	cVar := StrTran(cVar, "%", "")
	cVar := StrTran(cVar, "$", "") 
	cVar := StrTran(cVar, "#", "")
	cVar := StrTran(cVar, "!", "")
	cVar := StrTran(cVar, "{", "")
	cVar := StrTran(cVar, "}", "")
	cVar := StrTran(cVar, "/", "")
	cVar := StrTran(cVar, "?", "")
    cVar := StrTran(cVar, "{", "")
    cVar := StrTran(cVar, "}", "")
    cVar := StrTran(cVar, "[", "")
    cVar := StrTran(cVar, "]", "")
    cVar := StrTran(cVar, "/", "")
    cVar := StrTran(cVar, "?", "")
    cVar := StrTran(cVar, ".", "")
    cVar := StrTran(cVar, "\", "")
    cVar := StrTran(cVar, "|", "")
    cVar := StrTran(cVar, ":", "")
    cVar := StrTran(cVar, ";", "")
    cVar := StrTran(cVar, '"', '')
    cVar := StrTran(cVar, '°', '')
    cVar := StrTran(cVar, 'ª', '')
    cVar := StrTran(cVar, "'", '')

	//Retirando acento agudo
    cVar := StrTran(cVar, 'Á', 'A')
    cVar := StrTran(cVar, 'á', 'a')
    cVar := StrTran(cVar, 'É', 'E')
    cVar := StrTran(cVar, 'É', 'e')
    cVar := StrTran(cVar, 'Í', 'I')
    cVar := StrTran(cVar, 'í', 'i')
    cVar := StrTran(cVar, 'Ó', 'O')
    cVar := StrTran(cVar, 'ó', 'o')
    cVar := StrTran(cVar, 'Ú', 'U')
    cVar := StrTran(cVar, 'ú', 'u')

	//Retirando acento circunflexo
    cVar := StrTran(cVar, 'Â', 'A')
    cVar := StrTran(cVar, 'â', 'a')
    cVar := StrTran(cVar, 'Ê', 'E')
    cVar := StrTran(cVar, 'ê', 'e')
    cVar := StrTran(cVar, 'Î', 'I')
    cVar := StrTran(cVar, 'î', 'i')
    cVar := StrTran(cVar, 'Ô', 'O')
    cVar := StrTran(cVar, 'ô', 'o')
    cVar := StrTran(cVar, 'Û', 'U')
    cVar := StrTran(cVar, 'û', 'u')

	//Retirando o ~
	cVar := StrTran(cVar, 'Ã', 'A')
    cVar := StrTran(cVar, 'ã', 'a')
    cVar := StrTran(cVar, 'Õ', 'O')
    cVar := StrTran(cVar, 'õ', 'o')



return cVar




Static Function DtBoleto(nValor, cCondPag, dDataEnt, oJson)
	Local aDatas 		:= {}
	Local cQry 			:= ""
	Local cAliasSE4 	:= GetNextAlias()
	Local nAtual 		:= 0
	Local oJsonData

	cQry := " SELECT E4_CODIGO,E4_XACRTRR, E4_FORMA FROM SE4010 " + CRLF
	cQry += " WHERE E4_CODIGO = '" + cCondPag+ "'" + CRLF
	cQry += " AND D_E_L_E_T_ = ''" + CRLF

	PlsQuery(cQry, cAliasSE4)

	//nValor += (cAliasSE4)->E4_XACRTRR

	aDatas := Condicao(nValor,cCondPag,,dDataEnt)

	For nAtual := 1 to len(aDatas)
		oJsonData := JsonObject():New()
		//aDatas[nAtual][2] += (cAliasSE4)->E4_XACRTRR
		aAdd(aDatas[nAtual], (cAliasSE4)->E4_FORMA)

		oJsonData['DataPrevistaPagamento'] := DTOC(aDatas[nAtual][1])
		oJsonData['Valor'] := aDatas[nAtual][2]
		oJsonData['Forma'] := Alltrim(aDatas[nAtual][3])
		aAdd(oJson['Datas'], oJsonData)
	Next
return

USER FUNCTION VldCondPag(oJson)
	Local cQry 			:= ""
	Local cAliasQry 	:= ""
	Local lRet 			:= .F.

	cAliasQry := GetNextAlias()
	cQry := " SELECT E4_CODIGO, E4_FORMA FROM " +  RetSqlName('SE4') + CRLF
	cQry += "  WHERE E4_CODIGO = '" + oJson['capaPedido']['CondPagamento'] +"'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasQry)

	IF !(cAliasQry)->(EoF())
		IF Alltrim((cAliasQry)->E4_FORMA) == "CC"
			lRet := .T.
		ENDIF
	ENDIF

	(cAliasQry)->(DbCloseArea())

return lRet

STATIC Function RegFil(oJson)

	//Local aArea         := GetArea()
	Local cCodCli       := oJson['capaPedido']['CodigoCliente']
	Local cLojaCli      := oJson['capaPedido']['LojaCliente']
	Local cEstEnt 		:= oJson['capaPedido']['UfEntrega']
	//Local nAtual        := 0
	Local cCfo          := ""
	//LOCAL aSeg          := GetArea()
	//LOCAL aSegSC5       := SC5->(GetArea()), aSegSC6 := SC6->(GetArea()), aSegSUB := SUB->(Getarea())
	//LOCAL aSegSU6       := SU6->(GetArea()), aSegSU5 := SU5->(GetArea()), aSegSA1 := SA1->(GetArea())
	//LOCAL cNumero       := SUA->UA_numsc5, cCliente := Space(8), cOperad := Space(6), cLista := Space(6), cCodTex1 := Space(3)
	//LOCAL cVend1        :=  SUA->UA_vend, cVend2 := SUA->UA_vend2,	cVend3  := SUA->UA_vend3
	//LOCAL cQuery        := ""
	//LOCAL cCfo          := ""
	//LOCAL cTipProd      := ""


	//PRIVATE _cPlaca
	///PRIVATE lTransf := .F.,lLiber := .T. , lSugere := .T.

	//VERIFICA CFOP CORRETA - Chamado 232002 - Verificar situação de venda para cliente no estado SC e manda entregar em estado diferente de SC.
	DbSelectArea("SA1")
	DbSetOrder(1)       //Filial+Cliente+Loja
	SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojaCli))

	If  cEmpAnt == '01' .And. cFilAnt $ '03/16'

		// A = B = C 5656
		If (SM0->M0_ESTCOB == SA1->A1_EST) .AND. (SM0->M0_ESTCOB == cEstEnt)

			cCfo:= "5656"

			// A <> B <> C  .OR. A = B .AND A <> C 6667
		ELSEIF ((SM0->M0_ESTCOB == SA1->A1_EST) .AND. (SM0->M0_ESTCOB <> cEstEnt)) .OR. ((SM0->M0_ESTCOB <>  cEstEnt) .AND.  (cEstEnt <> SA1->A1_EST) .AND. (SM0->M0_ESTCOB  <> SA1->A1_EST))
			cCfo:= "6667"

			// A = C .AND. A <> B 5667
		ELSEIF (SM0->M0_ESTCOB ==  cEstEnt) .AND.  (SM0->M0_ESTCOB  <> SA1->A1_EST)
			cCfo:= "5667"

			//A <> B = C 6656
		ELSEIF (SM0->M0_ESTCOB <>  cEstEnt) .AND.  (cEstEnt == SA1->A1_EST)
			cCfo:= "6656"

		ENDIF

	ENDIF
	//RestArea(aArea)
Return (cCfo)

