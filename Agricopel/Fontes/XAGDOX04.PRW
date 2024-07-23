#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGDOX04
Integração DOX - Exclusão de Pedido e Documento de Saída
@author Leandro Spiller
@since 22/07/2020
@version 1.0
/*/
User Function XAGDOX04(_oJsonDOX)

	Private oRetDox    := DOXWsRetorno():New()
	Private _cTipo 	   := _oJsonDOX:GetJsonText("tipo")
	Private CRECOMENDACAOOLOTE := ""

	_cEmpFil  := _oJsonDOX:GetJsonText("empFil")
	Conout(' XAGDOX04 -> '+'Gerando '+  _cTipo)
	
	//If (!Empty(_aEmpresa))
		//RPCSetType(3)
		//RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"","","","",{"SA1","SF2","SD2","SC5","SC6","SB1"})

		
		RPCClearEnv()
		RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"USERREST","*R3st2021","","",{"SA1","SF2","SD2","SC5","SC6","SB1","SF3","SFT"})

        If  _cTipo = 'CANCDOC' 
			CancDoc(_oJsonDOX)
		Elseif _cTipo = 'EXCPEDIDO'
			RetSucesso('Função desabilitada, Excluir pedido ' )
			//ExcPed(_oJsonDOX)		
		Endif 

		RPCClearEnv()
	//Else
//		RetErro("Nao foi possivel encontrar a empresa pelo CNPJ [" + CNPJ_PED + "] - Precisa ser CNPJ sem formatacao!")
//	EndIf

Return(oRetDox)


//Cancela documento 
Static Function CancDoc(_oJsonDOX)

Local _lMostraCTB   := .F.
Local _lAglCTB      := .F.
Local _lContab      := .F.
Local _lCarteira    := .F.
Local aRegSD2       := {}
Local aRegSE1       := {}
Local aRegSE2       := {}
Local lExcTit    	:= .F. 
Local _lExcluida    := .F.
Local _cChave       := ""
Private _cDoc 	   := _oJsonDOX:GetJsonText("documento")
Private _cSerie    := _oJsonDOX:GetJsonText("serie")


//Verifica se a nota ja foi digitada.
SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
SF2->(DbGoTop())
If (SF2->(DbSeek(xfilial("SF2") + PADR(_cDoc,TamSX3('F2_DOC')[1]) + PADR(_cSerie,TamSX3('F2_SERIE')[1]) /*+ SA1->A1_COD  + SA1->A1_LOJA */)))

	_cDoc   := SF2->F2_DOC 
	_cSerie := SF2->F2_SERIE 
	_cChave := SF2->F2_CHVNFE 

	//E1_SITUACA = 0  - Carteira
	lExcTit := VerBaixa(SF2->F2_PREFIXO,SF2->F2_DOC)

	//Se tiver titulo Baixado Aborta e retorna como erro
	iF lExcTit
		RetErro("não foi possível excluir o Título, entre em contato com o financeiro!")
		Return 
	Endif 

	dbselectarea('SA1')
	dbsetorder(1)
	Dbseek(xfilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA )  

	_dDataEmis := SF2->F2_EMISSAO

	_lRetExc := MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
	If _lRetExc
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,_lMostraCTB,_lAglCTB,_lContab,_lCarteira))
		_lExcluida := .T.
	Else
		RetErro("Não foi Possível Excluir o documento, favor realizar o cancelamento manualmente.")
		Return 
	EndIf
	
	If _lExcluida .and. _cChave <> ''
		//AutoNfeEnv(cEmpAnt,cFilAnt,,,_cSerie, _cDoc, _cDoc)
		MV_PAR01 := _cSerie
		AutoNfeTrans()
		RetSucesso("Nota fiscal Excluída com sucesso!")
	EndIf
Else

	cQuery := " SELECT F3_DTCANC FROM "+ RetSqlName('SF3')+ "(NOLOCK)"
	cQuery += " WHERE F3_NFISCAL = '"+PADR(_cDoc,TamSX3('F2_DOC')[1])+"' "
	cQuery += " AND F3_SERIE     = '"+PADR(_cSerie,TamSX3('F2_SERIE')[1])+"' "
	cQuery += " AND D_E_L_E_T_ = '' "

	If Select('XAGDOX04C') <> 0
		dbSelectArea('XAGDOX04C')
		('XAGDOX04C')->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ('XAGDOX04C')

	If XAGDOX04C->(!eof())
		If XAGDOX04C->F3_DTCANC <> ''
			RetSucesso("Nota fiscal Excluída com sucesso!")
		Endif 
	Endif 

	If Select('XAGDOX04C') <> 0
		dbSelectArea('XAGDOX04C')
		('XAGDOX04C')->(dbCloseArea())
	Endif

EndIf

Return 

/*Static Function ExcPed(_oJsonDOX)

	Local _aSC5         := {}
	Local _aSC6         := {}
	Local cQuery        := ""
	Private _cPedido    := _oJsonDOX:GetJsonText("pedido")
	Private lMsErroAuto := .F.


	cfilAnt := xfilial('SC5') 
	DbSelectArea("SC9")
	DbSetOrder(1)
	DbSeek( xFilial("SC9") + _cPedido )
	While !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cPedido
		A460Estorna()
		DbSelectArea("SC9")
		SC9->(DbSkip())
	Enddo
	MsUnlockAll()

	Dbselectarea('SC5')
	DbSetOrder(1)
	If DbSeek( xfilial('SC5') + _cPedido)

		_aSC5 := excSC5(_cPedido)
		_aSC6 := excSC6(_cPedido)

		If (!Empty(_aSC6) .And. !Empty(_aSC5))
			//MsExecAuto({|w,x,y,z|MATA410(w,x,y,z)}, _aSC5, _aSC6, 6, .F.)

			If lMsErroAuto
				RetErro("Erro ao excluir pedido: " + LerLogErro())
			Else
				RetSucesso('Pedido '+SC5->C5_NUM +'excluido com sucesso.' )
			EndIf
		EndIf
	Else 
		
		cQuery := " SELECT C5_NUM  FROM "+RetSqlName('SC5')+" (NOLOCK) "
		cQuery += " WHERE C5_FILIAL = '"+xfilial('SC5')+"' AND C5_NUM =  '"+_cPedido+"' AND D_E_L_E_T_ = '*' "
		If Select('XAGDOX04') <> 0
			dbSelectArea('XAGDOX04')
			('XAGDOX04')->(dbCloseArea())
		Endif

		TCQuery cQuery NEW ALIAS ('XAGDOX04')

		If XAGDOX04->(!eof())
			RetSucesso('Pedido '+SC5->C5_NUM +' Já havia sido excluido ' )
		else
			RetErro("Pedido não encontrado!")
		Endif 

		If Select('XAGDOX04') <> 0
			dbSelectArea('XAGDOX04')
			('XAGDOX04')->(dbCloseArea())
		Endif

	Endif 
Return()
*/
Static Function RetErro(msgErro)

	oRetDox:errorMessage += msgErro + "|"
	oRetDox:Sucesso      := .F.

Return()

Static Function RetSucesso(mensagem)

	oRetDox:errorMessage := ""
	oRetDox:msgSucesso   := mensagem
	oRetDox:Sucesso      := .T.

Return()


/*Static Function excSC5(xpedido)

	Local _aSC5     := {}

	Aadd(_aSC5, {"C5_FILIAL"  , SC5->C5_FILIAL  , Nil})
	Aadd(_aSC5, {"C5_TIPO"    , SC5->C5_TIPO    , Nil})
	Aadd(_aSC5, {"C5_CLIENTE" , SC5->C5_CLIENTE , Nil})
	Aadd(_aSC5, {"C5_LOJACLI" , SC5->C5_LOJACLI , Nil})
	Aadd(_aSC5, {"C5_LOJAENT" , SC5->C5_LOJAENT , Nil})
	Aadd(_aSC5, {"C5_TIPOCLI" , SC5->C5_TIPOCLI , Nil})
	Aadd(_aSC5, {"C5_EMISSAO" , SC5->C5_EMISSAO , Nil})
	Aadd(_aSC5, {"C5_MOEDA"   , SC5->C5_MOEDA   , Nil})
	//Aadd(_aSC5, {"C5_CONDPAG" , SC5->C5_CONDPAG , Nil})
	Aadd(_aSC5, {"C5_TRANSP"  , SC5->C5_TRANSP  , Nil})
	Aadd(_aSC5, {"C5_VEND1"   , SC5->C5_VEND1   , Nil})
	Aadd(_aSC5, {"C5_IMPORTA" , SC5->C5_IMPORTA , Nil})
	Aadd(_aSC5, {"C5_TIPLIB"  , SC5->C5_TIPLIB  , Nil})
	Aadd(_aSC5, {"C5_X_ORIG"  , SC5->C5_X_ORIG  , Nil})
	Aadd(_aSC5, {"C5_BLQ"     , SC5->C5_BLQ     , Nil})
	Aadd(_aSC5, {"C5_TPCARGA" , SC5->C5_TPCARGA , Nil})
	//Aadd(_aSC5, {"C5_TABELA"  , SC5->C5_TABELA  , Nil})
	Aadd(_aSC5, {"C5_MENS1"   , SC5->C5_MENS1   , Nil})

Return(_aSC5)

Static Function excSC6(xpedido)

	Local _aSC6      := {}
	Local _aLinha    := {}

	Dbselectarea('SC6')
	DbSetOrder(1)
	iF Dbseek(xfilial('SC6') + _cPedido) 
		While xfilial('SC6') == SC6->C6_FILIAL .AND. SC6->C6_NUM = xPedido 

			_aLinha  := {}
		
			AAdd(_aLinha, {"C6_FILIAL"      , SC6->C6_FILIAL     , Nil})
			AAdd(_aLinha, {"C6_ITEM"        , SC6->C6_ITEM 		, Nil})
			AAdd(_aLinha, {"C6_PRODUTO"     , SC6->C6_PRODUTO    , Nil})
			AAdd(_aLinha, {"C6_DESCRI"      , SC6->C6_DESCRI     , Nil})
			AAdd(_aLinha, {"C6_UM"          , SC6->C6_UM         , Nil})
			AAdd(_aLinha, {"C6_QTDVEN"      , SC6->C6_QTDVEN     , Nil})
			AAdd(_aLinha, {"C6_QTDLIB"      , SC6->C6_QTDLIB     , Nil})	
			AAdd(_aLinha, {"C6_PRCVEN"      , SC6->C6_PRCVEN     , Nil})
			AAdd(_aLinha, {"C6_PRUNIT"      , SC6->C6_PRUNIT     , Nil})
			AAdd(_aLinha, {"C6_TES"         , SC6->C6_TES        , Nil})
			AAdd(_aLinha, {"C6_LOCAL"       , SC6->C6_LOCAL      , Nil})
			AAdd(_aLinha, {"C6_CLI"         , SC6->C6_CLI        , Nil})
			AAdd(_aLinha, {"C6_ENTREG"      , SC6->C6_ENTREG     , Nil})
			AAdd(_aLinha, {"C6_HRCAPTA"     , SC6->C6_HRCAPTA    , Nil})

			AAdd(_aSC6, _aLinha)
			SC6->(dbskip())
		Enddo 
	Endif 
Return(_aSC6)
*/
/*Static Function LerLogErro()

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
*/
Static function VerBaixa(xPrefixo, xNum)

	Local cQuery 	:= ""
	Local lTemBaixa := .F.

	cQuery := " SELECT E1_PARCELA FROM "+RetSqlName('SE1')+"(NOLOCK) " 
	cQuery += " WHERE E1_PREFIXO = '"+xPrefixo+"'AND E1_NUM = '"+xNum+"' AND D_E_L_E_T_ = '' "
	cQuery += " AND E1_BAIXA <> '' "

	If Select('XAGDOX04B') <> 0
		dbSelectArea('XAGDOX04B')
		('XAGDOX04B')->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ('XAGDOX04B')

	If XAGDOX04B->(!eof())
		lTemBaixa := .T.
	Else
		cQuery := " UPDATE "+RetSqlName('SE1')+" SET E1_SITUACA = '0' , E1_HIST = TRIM(E1_HIST) + ' XAGDOX04' " 
		cQuery += " , E1_NUMBOR = '',E1_DATABOR = '', E1_PORTADO = '', E1_CONTA = '',E1_NUMBCO = '' ,E1_AGEDEP = '' "
		cQuery += " WHERE E1_PREFIXO = '"+xPrefixo+"'AND E1_NUM = '"+xNum+"' AND D_E_L_E_T_ = '' "
		cQuery += " AND E1_BAIXA = '' "	

		If TCSQLExec(cQuery) < 0
			lTemBaixa := .F.
		EndIf
	Endif 	 

	If Select('XAGDOX04B') <> 0
		dbSelectArea('XAGDOX04B')
		('XAGDOX04B')->(dbCloseArea())
	Endif

Return lTemBaixa


/*Static Function ValidSC6(_cB1_COD, _cCodTes)

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
	Else
		// Validacao se faz necessaria porque se nao houver uma tabela (pode ser de fachada) para o grupo de vendas do cliente
		// uma customizacao da Shell ira gerar erro ao gerar o pedido
		If (!Empty(SA1->A1_GRPVEN) .And. !ValidDA0(SA1->A1_GRPVEN))
			RetErro("Nao foi encontrada uma tabela de vendas para o grupo de vendas do cliente informado! Grupo: " + SA1->A1_GRPVEN + " - Solução: Cadastre uma tabela de vendas (vazia) para este grupo, pois há validações da Shell que obrigam este cadastro.")
			_lValidOk := .F.
		EndIf
	EndIf

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
*/
