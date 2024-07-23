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
	Local cFilBkp := ""

	Private oRetDox    := DOXWsRetorno():New()
	Private TAB_PRECO  := "003"
	Private CNPJ_PED   := "81632093001574" // Agricopel Manutenção (Filial 14 do Protheus)
	Private _cTipo 	   := _oJsonDOX:GetJsonText("tipo")


	//Caso não tenha o Tipo considera que é um Pedido
	If _cTipo  == 'null'
		_cTipo := 'PEDIDO'
	Endif 
	
	Conout(' XAGDOX01 -> '+'Gerando '+  _cTipo)
	_aEmpresa := GetEmpresa()

	If (!Empty(_aEmpresa))
		//RPCSetType(3)
		//RPCSetEnv(_aEmpresa[1], _aEmpresa[2])
		
		RPCClearEnv()
		RPCSetEnv(_aEmpresa[1],_aEmpresa[2],"USERREST","*R3st2021","","")
		cFilant := _aEmpresa[2]
        If _cTipo = 'PEDIDO'
			InserirPed(_oJsonDOX)
		Elseif _cTipo = 'BAIXATIT'
			BaixaTit(_oJsonDOX)
		Endif 

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
	Local nCont

	//OpenSM0()
	//SET DELETE ON
	//SM0->(DbGoTop())
	aSM0 := FWLoadSM0()

	For nCont:=1 to Len(aSM0)
		If Alltrim(aSM0[nCont][18]) ==  Alltrim(CNPJ_PED)
			_aEmpresa := {Alltrim(aSM0[nCont][1]),Alltrim(aSM0[nCont][2])}
		EndIf
	Next

	/*While (!SM0->(Eof()))
		If (SM0->M0_CGC == CNPJ_PED)
			_aEmpresa := {SM0->M0_CODIGO, Alltrim(SM0->M0_CODFIL)}
			Exit
		EndIf()

		SM0->(DbSkip())
	End

	dbCloseAll()*/

Return(_aEmpresa)


Static Function BaixaTit(_oJsonDOX)

	Local _cCnpjCli 	:= _oJsonDOX:GetJsonText("cnpjClientePedido")
	Local _NotaFiscal   := _oJsonDOX:GetJsonText("NotaFiscal")
	Local _cSerie 		:= _oJsonDOX:GetJsonText("Serie")

	Dbselectarea('SA1')
	DbSetorder(3)
	Dbseek(xFilial('SA1') + _cCnpjCli )

	DbSelectarea('SF2')
	DbSetorder(1)
	DbSeek( xfilial('SF2') + _NotaFiscal + _cSerie )

	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	SE1->(dbGoTop())
	If SE1->(dbSeek(xFilial("SE1") + SF2->F2_PREFIXO + SF2->F2_DUPL  ))

		aBaixa := {{"E1_PREFIXO"  ,SF2->F2_PREFIXO        ,Nil    },;
        		   {"E1_NUM"      ,SF2->F2_DUPL           ,Nil    },;
			       {"E1_TIPO"     ,SE1->E1_TIPO           ,Nil    },;
			       {"AUTMOTBX"    ,"NOR"                  ,Nil    },;
			       {"AUTBANCO"    ,'997'         	         ,Nil    },;
			       {"AUTAGENCIA"  ,"997  "                ,Nil    },;
			       {"AUTCONTA"    ,"52110308  "           ,Nil    },;
			       {"AUTDTBAIXA"  ,dDatabase               ,Nil    },;
			       {"AUTDTCREDITO",dDatabase               ,Nil    },;
			       {"AUTHIST"     ,'Baixa Automatica'     ,Nil    },;
			       {"AUTJUROS"    ,0                      ,Nil,.T.},;
			       {"AUTVALREC"   ,SE1->E1_VALOR          ,Nil    }} 
			  
		lMsErroAuto := .F.

		//Begin Transaction
		MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 

		If lMsErroAuto
			RetErro("Erro ao baixar TÍTULO: " + LerLogErro())
		Else
			RetSucesso(_NotaFiscal)
		Endif

    Endif
	
Return

Static Function InserirPed(_oJsonDOX)

	Local _aSC5     := {}
	Local _aSC6     := {}

	Private lMsErroAuto := .F.

	_aSC5 := getSC5(_oJsonDOX)
	_aSC6 := getSC6(_oJsonDOX)

	If (!Empty(_aSC6) .And. !Empty(_aSC5))
		MsExecAuto({|w,x,y,z|MATA410(w,x,y,z)}, _aSC5, _aSC6, 3, .F.)

		If lMsErroAuto
			RetErro("Erro ao gerar pedido: " +xfilial('SC5')+' - ' + LerLogErro())
			//conout('XAG0001 - Erro ao gerar pedido: '+xfilial('SC5')+' - '  + LerLogErro()) 
		Else
			RetSucesso(SC5->C5_NUM)
			//Conout('XAG0001 - Pedido gerado '+SC5->C5_FILIAL + ' - ' + SC5->C5_NUM ) 
		EndIf
	EndIf

Return()

Static Function getSC5(_oJsonDOX)

	Local _aSC5     := {}
	Local _cCnpjCli := _oJsonDOX:GetJsonText("cnpjClientePedido")
	Local _cObsNF   := _oJsonDOX:GetJsonText("obsNotaFiscal")
	Local _nQtdePar := _oJsonDOX:GetJsonText("qtdeParcelas")

	If (!ValidSC5(_cCnpjCli, _nQtdePar))
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
	Aadd(_aSC5, {"C5_CONDPAG" , SE4->E4_CODIGO   , Nil})
	Aadd(_aSC5, {"C5_TRANSP"  , SA1->A1_TRANSP   , Nil})
	Aadd(_aSC5, {"C5_VEND1"   , SA1->A1_VEND     , Nil})
	Aadd(_aSC5, {"C5_IMPORTA" , "N"              , Nil})
	Aadd(_aSC5, {"C5_TIPLIB"  , "1"              , Nil})
	Aadd(_aSC5, {"C5_X_ORIG"  , "XAGDOX01"       , Nil})
	Aadd(_aSC5, {"C5_BLQ"     , ""               , Nil})
	Aadd(_aSC5, {"C5_TPCARGA" , "2"              , Nil})
	Aadd(_aSC5, {"C5_TABELA"  , TAB_PRECO        , Nil})
	Aadd(_aSC5, {"C5_MENS1"   , _cObsNF          , Nil})

Return(_aSC5)

Static Function getSC6(_oJsonDOX)

	Local _aSC6      := {}
	Local _aLinha    := {}
	Local _aItJson   := _oJsonDOX:GetJsonObject("itens")
	Local _oLiJson   := Nil

	Local _cCodTes   := ""
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
		AAdd(_aLinha, {"C6_CLI"         , SA1->A1_COD         , Nil})
		AAdd(_aLinha, {"C6_ENTREG"      , dDataBase           , Nil})
		AAdd(_aLinha, {"C6_HRCAPTA"     , Time()              , Nil})

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

Static Function ValidSC6(_cB1_COD, _cCodTes)

	Local _lValidOk := .T.

	dbSelectarea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	If (!SB1->(DbSeek(xFilial("SB1")+_cB1_COD)))
		RetErro("Produto nao encontrado! Prod: " + AllTrim(_cB1_COD))
		_lValidOk := .F.
	EndIf

	If (Empty(_cCodTes))
		_cCodTes := SB1->B1_TS
	EndIf

	Dbselectarea('SF4')
	SF4->(DbSetOrder(1))
	SF4->(DbGoTop())
	If (!SF4->(DbSeek(xFilial("SF4")+_cCodTes)))
		RetErro("TES do produto errada ou nao configurada! Prod: " + AllTrim(_cB1_COD) + " TES: " + AllTrim(_cCodTes))
		_lValidOk := .F.
	EndIf

	Dbselectarea('DA1')
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

Static Function ValidSC5(_cCnpjCli, _nQtdePar)

	Local _lValidOk := .T.

	DbSelectarea('SA1')
	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	If (!SA1->(DbSeek(xFilial("SA1")+_cCnpjCli)))
		RetErro("Cliente nao encontrado pelo CNPJ informado! CNPJ: " + _cCnpjCli)
		_lValidOk := .F.
	Endif 
	/*Else
		// Validacao se faz necessaria porque se nao houver uma tabela (pode ser de fachada) para o grupo de vendas do cliente
		// uma customizacao da Shell ira gerar erro ao gerar o pedido
		If (!Empty(SA1->A1_GRPVEN) .And. !ValidDA0(SA1->A1_GRPVEN))
			RetErro("Nao foi encontrada uma tabela de vendas para o grupo de vendas do cliente informado! Grupo: " + SA1->A1_GRPVEN + " - Solução: Cadastre uma tabela de vendas (vazia) para este grupo, pois há validações da Shell que obrigam este cadastro.")
			_lValidOk := .F.
		EndIf
	EndIf*/

	Dbselectarea('DA0')
	DA0->(DbSetOrder(1))
	DA0->(DbGoTop())
	If (!DA0->(DbSeek(xFilial("DA0")+TAB_PRECO)))
		RetErro("Tabela de vendas nao encontrada! TabPreco: " + TAB_PRECO)
		_lValidOk := .F.
	EndIf

	If (!CalcSE4(_nQtdePar))
		_lValidOk := .F.
	EndIf

Return(_lValidOk)

Static Function CalcSE4(_nQtdePar)

	Local _lRetOk    := .T.
	Local _cQuery    := ""
	Local _cAliasQry := ""
	Local _cCond     := ""

	Default _nQtdePar := 0

	If (ValType(_nQtdePar) == "C")
		_nQtdePar := Val(_nQtdePar)
	EndIf

	If (Empty(_nQtdePar))
		_nQtdePar := 1
	EndIf

	If (_nQtdePar == 1)
		_cCond := "30"
	ElseIf (_nQtdePar == 2)
		_cCond := "30,60"
	ElseIf (_nQtdePar == 3)
		_cCond := "30,60,90"
	End

	If (!Empty(_cCond))
		_cQuery += " SELECT E4_CODIGO "
		_cQuery += " FROM SE4010 SE4 (NOLOCK) "
		_cQuery += " WHERE SE4.E4_FILIAL = '" + xFilial("SE4") + "'"
		_cQuery += " AND   SE4.E4_COND = '" + _cCond + "'"
		_cQuery += " AND   SE4.E4_FORMA = 'BL' "
		_cQuery += " AND   SE4.E4_TIPO = '1' "
		_cQuery += " AND   SE4.D_E_L_E_T_ = '' "

		_cAliasQry := MPSysOpenQuery(_cQuery)

		_cCond := (_cAliasQry)->E4_CODIGO

		(_cAliasQry)->(DbCloseArea())

		Dbselectarea('SE4')
		SE4->(DbSetOrder(1))
		If (!SE4->(DbSeek(xFilial("SE4")+_cCond)))
			RetErro("Não foi possível encontrar uma condição de pagamento (com forma de pagamentoto BOLETO) conforme quantidade de parcelas informada! [" + cValToChar(_nQtdePar) + "]")
			_lRetOk := .F.
		EndIf
	Else
		RetErro("Não foi possível definir uma condição de pagamento conforme quantidade de parcelas informada (que deve ser 1,2 ou 3)! [" + cValToChar(_nQtdePar) + "]")
		_lRetOk := .F.
	EndIf

Return(_lRetOk)

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
