#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGDOX01
Integração DOX - Inclusão de pedido de venda para uniformes
@author Leandro F Silveira
@since 24/06/2019
@version 1.0
/*/
User Function XAGDOX01(_oJsonDOX)

	Local _aEmpresa := {}

	Private oRetDox    := DOXWsRetorno():New()

	Private TAB_PRECO  := "003"
	Private COND_PAGTO := "001"
	Private CNPJ_PED   := "81632093001574" // Agricopel Manutenção (Filial 14 do Protheus)

	_aEmpresa := GetEmpresa()

	If (!Empty(_aEmpresa))
		RPCSetType(3)
		RPCSetEnv(_aEmpresa[1], _aEmpresa[2])

		InserirPed(_oJsonDOX)

		RPCClearEnv()
	Else
		RetErro("Nao foi possivel encontrar a empresa pelo CNPJ [" + CNPJ_PED + "] - Precisa ser CNPJ sem formatacao!")
	EndIf

Return(oRetDox)

Static Function RetErro(msgErro)

	oRetDox:errorMessage += msgErro + "|"
	oRetDox:Sucesso      := .F.

Return()

Static Function RetSucesso(mensagem)

	oRetDox:errorMessage := ""
	oRetDox:msgSucesso   := mensagem
	oRetDox:Sucesso      := .T.

Return()

Static Function GetEmpresa()

	Local _aEmpresa := {}

	OpenSM0()
	SET DELETE ON
	SM0->(DbGoTop())

	While (!SM0->(Eof()))
		If (SM0->M0_CGC == CNPJ_PED)
			_aEmpresa := {SM0->M0_CODIGO, SM0->M0_CODFIL}
			Exit
		EndIf()

		SM0->(DbSkip())
	End

	dbCloseAll()

Return(_aEmpresa)

Static Function InserirPed(_oJsonDOX)

	Local _aSC5     := {}
	Local _aSC6     := {}

	Private lMsErroAuto := .F.

	_aSC5 := getSC5(_oJsonDOX)
	_aSC6 := getSC6(_oJsonDOX)

	If (!Empty(_aSC6) .And. !Empty(_aSC5))
		MsExecAuto({|w,x,y,z|MATA410(w,x,y,z)}, _aSC5, _aSC6, 3, .F.)

		If lMsErroAuto
			RetErro("Erro ao gerar pedido: " + LerLogErro())
		Else
			RetSucesso("Pedido gerado: " + SC5->C5_NUM)
		EndIf
	EndIf

Return()

Static Function getSC5(_oJsonDOX)

	Local _aSC5     := {}
	Local _cCnpjCli := _oJsonDOX:GetJsonText("cnpjClientePedido")
	Local _ObsNF    := _oJsonDOX:GetJsonText("obsNotaFiscal")

	If (!ValidSC5(_cCnpjCli))
		Return({})
	EndIf

	Aadd(_aSC5, {"C5_FILIAL"  , xFilial("SC5")   , Nil})
	Aadd(_aSC5, {"C5_TIPO"    , "N"              , Nil})
	Aadd(_aSC5, {"C5_CLIENTE" , SA1->A1_COD      , Nil})
	Aadd(_aSC5, {"C5_LOJACLI" , SA1->A1_LOJA     , Nil})
	Aadd(_aSC5, {"C5_LOJAENT" , SA1->A1_LOJA     , Nil})
	Aadd(_aSC5, {"C5_TIPOCLI" , SA1->A1_TIPO     , Nil})
	Aadd(_aSC5, {"C5_EMISSAO" , dDataBase        , Nil})
	Aadd(_aSC5, {"C5_MOEDA"   , 1                , Nil})
	Aadd(_aSC5, {"C5_CONDPAG" , COND_PAGTO       , Nil})
	Aadd(_aSC5, {"C5_TRANSP"  , SA1->A1_TRANSP   , Nil})
	Aadd(_aSC5, {"C5_VEND1"   , SA1->A1_VEND     , Nil})
	Aadd(_aSC5, {"C5_IMPORTA" , "P"              , Nil})
	Aadd(_aSC5, {"C5_TIPLIB"  , "1"              , Nil})
	Aadd(_aSC5, {"C5_X_ORIG"  , "XAGDOX01"       , Nil})
	Aadd(_aSC5, {"C5_BLQ"     , ""               , Nil})
	Aadd(_aSC5, {"C5_TPCARGA" , "2"              , Nil})
	Aadd(_aSC5, {"C5_TABELA"  , TAB_PRECO        , Nil})
	Aadd(_aSC5, {"C5_MENS1"   , _ObsNF           , Nil})

Return(_aSC5)

Static Function getSC6(_oJsonDOX)

	Local _aSC6      := {}
	Local _aLinha    := {}
	Local _aItJson   := _oJsonDOX:GetJsonObject("itens")
	Local _oLiJson   := Nil

	Local _cCodProd  := ""
	Local _nQtdeProd := 0
	Local nCount     := 0

	For nCount := 1 To Len(_aItJson)

		_aLinha  := {}
		_oLiJson := _aItJson[nCount]

		_cCodProd  := _oLiJson:GetJsonText("codProduto")
		_nQtdeProd := Val(_oLiJson:GetJsonText("qtdePedido"))
		_cCodTes   := _oLiJson:GetJsonText("codTes")

		If (!ValidSC6(_cCodProd, _cCodTes))
			Return({})
		EndIf

		AAdd(_aLinha, {"C6_FILIAL"      , xFilial("SC6")      , Nil})
		AAdd(_aLinha, {"C6_ITEM"        , StrZero(nCount, 3)  , Nil})
		AAdd(_aLinha, {"C6_PRODUTO"     , SB1->B1_COD         , Nil})
		AAdd(_aLinha, {"C6_DESCRI"      , SB1->B1_DESC        , Nil})
		AAdd(_aLinha, {"C6_UM"          , SB1->B1_UM          , Nil})
		AAdd(_aLinha, {"C6_QTDVEN"      , _nQtdeProd          , Nil})
		AAdd(_aLinha, {"C6_QTDLIB"      , _nQtdeProd          , Nil})	
		AAdd(_aLinha, {"C6_PRCVEN"      , DA1->DA1_PRCVEN     , Nil})
		AAdd(_aLinha, {"C6_PRUNIT"      , DA1->DA1_PRCVEN     , Nil})
		AAdd(_aLinha, {"C6_TES"         , SF4->F4_CODIGO      , Nil})
		AAdd(_aLinha, {"C6_LOCAL"       , SB1->B1_LOCPAD      , Nil})
		AAdd(_aLinha, {"C6_CF"          , SF4->F4_CF          , Nil})
		AAdd(_aLinha, {"C6_CLI"         , SA1->A1_COD         , Nil})
		AAdd(_aLinha, {"C6_ENTREG"      , dDataBase           , Nil})
//		AAdd(_aLinha, {"C6_TURNO"       , ""                  , Nil})

		AAdd(_aSC6, _aLinha)
	End

Return(_aSC6)

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
		cRet := MostraErro("/dirdoc", "error.log")
	EndIf

Return(cRet)

Static Function ValidSC6(_cB1_COD)

	Local _lValidOk := .T.

	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	If (!SB1->(DbSeek(xFilial("SB1")+_cB1_COD)))
		RetErro("Produto nao encontrado! Prod: " + AllTrim(_cB1_COD))
		_lValidOk := .F.
	EndIf

	If (Empty(_cCodTes))
		_cCodTes := SB1->B1_TS
	EndIf

	SF4->(DbSetOrder(1))
	SF4->(DbGoTop())
	If (!SF4->(DbSeek(xFilial("SF4")+_cCodTes)))
		RetErro("TES do produto errada ou nao configurada! Prod: " + AllTrim(_cB1_COD) + " TES: " + AllTrim(_cCodTes))
		_lValidOk := .F.
	EndIf

	DA1->(DbSetOrder(1))
	DA1->(DbGoTop())
	If (!DA1->(DbSeek(xFilial("DA1")+TAB_PRECO+SB1->B1_COD)))
		RetErro("Produto nao encontrado na tabela de precos! Prod: " + AllTrim(_cB1_COD) + " Tab Preco: " + TAB_PRECO)
		_lValidOk := .F.
	Else
		If (Empty(DA1->DA1_PRCVEN))
			RetErro("Produto está com preço zerado na tabela de precos! Prod: " + AllTrim(_cB1_COD) + " Tab Preco: " + TAB_PRECO)
			_lValidOk := .F.
		EndIf
	EndIf

Return(_lValidOk)

Static Function ValidSC5(_cCnpjCli)

	Local _lValidOk := .T.

	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	If (!SA1->(DbSeek(xFilial("SA1")+_cCnpjCli)))
		RetErro("Cliente nao encontrado pelo CNPJ informado! CNPJ: " + _cCnpjCli)
		_lValidOk := .F.
	Else
		// Validacao se faz necessaria porque se nao houver uma tabela (pode ser de fachada) para o grupo de vendas do cliente
		// uma customizacao da Shell ira gerar erro ao gerar o pedido
		If (!Empty(SA1->A1_GRPVEN) .And. !ValidDA0(SA1->A1_GRPVEN))
			RetErro("Nao foi encontrada uma tabela de vendas para o grupo de vendas do cliente informado! Grupo: " + SA1->A1_GRPVEN + " - Solução: Cadastre uma tabela de vendas (vazia) para este grupo, pois há validações da Shell que obrigam este cadastro.")
			_lValidOk := .F.
		EndIf
	EndIf

	DA0->(DbSetOrder(1))
	DA0->(DbGoTop())
	If (!DA0->(DbSeek(xFilial("DA0")+TAB_PRECO)))
		RetErro("Tabela de vendas nao encontrada! TabPreco: " + TAB_PRECO)
		_lValidOk := .F.
	EndIf

Return(_lValidOk)

Static Function ValidDA0(cGrpVen)

	Local _lValidOk  := .F.
	Local _cQuery    := ""
	Local _cAliasDA0 := GetNextAlias()

	_cQuery := " SELECT COUNT(DA0_CODTAB) AS QTDE "
	_cQuery += " FROM " + RetSqlName("DA0") + " DA0 WITH (NOLOCK) "
	_cQuery += " WHERE DA0.D_E_L_E_T_ = '' "
	_cQuery += " AND   DA0.DA0_FILIAL = '" + xFilial("DA0") + "' "
	_cQuery += " AND   DA0.DA0_GRPCLI = '" + cGrpVen + "' "

	TCQuery _cQuery New Alias (_cAliasDA0)

	_lValidOk := ((_cAliasDA0)->QTDE > 0)

	(_cAliasDA0)->(DbCloseArea())

Return(_lValidOk)