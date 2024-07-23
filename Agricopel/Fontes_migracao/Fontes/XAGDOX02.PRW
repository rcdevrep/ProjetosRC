#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TIPO_TIT "DP"
#DEFINE NATUREZA "219012"
#DEFINE CONTA "52111515"

/*/{Protheus.doc} XAGDOX02
Integração DOX - Inclusão de contas a pagar para reembolso de viagem
@author Leandro F Silveira
@since 28/06/2019
@version 1.0
/*/
User Function XAGDOX02(_oJsonDOX)

	Local _aEmpresa := {}
	Local cCNPJ     := ""

	Private oRetDox := DOXWsRetorno():New()

	cCNPJ := _oJsonDOX:GetJsonText("cnpjEmpresaTitulo")

	_aEmpresa := GetEmpresa(cCNPJ)
	
	If (!Empty(_aEmpresa))
		RPCSetType(3)
		RPCSetEnv(_aEmpresa[1], _aEmpresa[2])

		InserirSE2(_oJsonDOX)

		RPCClearEnv()
	Else
		RetErro("Nao foi possivel encontrar a empresa pelo CNPJ [" + cCNPJ + "] - Precisa ser CNPJ sem formatacao!")
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

Static Function GetEmpresa(cCNPJ)

	Local _aEmpresa := {}

	OpenSM0()
	SET DELETE ON
	SM0->(DbGoTop())

	While (!SM0->(Eof()))
		If (SM0->M0_CGC == cCNPJ)
			_aEmpresa := {SM0->M0_CODIGO, SM0->M0_CODFIL}
			Exit
		EndIf()

		SM0->(DbSkip())
	End

	dbCloseAll()

Return(_aEmpresa)

Static Function InserirSE2(_oJsonDOX)

	Local _aSE2 := {}
	Private lMsErroAuto := .F.

	_aSE2 := getSE2(_oJsonDOX)

	If (!Empty(_aSE2))
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, _aSE2,, 3)

		If lMsErroAuto
			RetErro(LerLogErro())
		Else
			RetSucesso("Título gerado: " + SE2->E2_NUM + "/" + SE2->E2_PARCELA)
		EndIf
	EndIf

Return()

Static Function getSE2(_oJsonDOX)

	Local _aSE2     := {}
	Local _cNum     := ""
	Local _cPrefixo := ""
	Local _cParcela := ""
	Local _dVencto  := CToD("  /  /  ")

	If (!ValidSE2(_oJsonDOX))
		Return({})
	EndIf

	_cNum := StrZero(Val(cValToChar(Month(Date())) + cValToChar(Year(Date()))), 9)
	_cPrefixo := cFilAnt
	_cParcela := CalcParcel(_cNum, _cPrefixo)

	_dVencto  := CalcVencto()

	aAdd(_aSE2, {"E2_FILORIG", cFilAnt, Nil})
	aAdd(_aSE2, {"E2_MSFIL", cFilAnt, Nil})
	aAdd(_aSE2, {"E2_FILIAL", xFilial("SE2"), Nil})

	aAdd(_aSE2, {"E2_PREFIXO", _cPrefixo, Nil})
	aAdd(_aSE2, {"E2_NUM", _cNum, Nil})
	aAdd(_aSE2, {"E2_PARCELA", _cParcela, Nil})

	aAdd(_aSE2, {"E2_TIPO", TIPO_TIT, Nil})
	aAdd(_aSE2, {"E2_NATUREZ", NATUREZA, Nil})
	aAdd(_aSE2, {"E2_ORIIMP", "XAGDOX02", Nil})
	aAdd(_aSE2, {"E2_CTA", CONTA, Nil})

	aAdd(_aSE2, {"E2_FORNECE", SA2->A2_COD, Nil})
	aAdd(_aSE2, {"E2_LOJA", SA2->A2_LOJA, Nil})
	aAdd(_aSE2, {"E2_NOMFOR", SA2->A2_NOME, Nil})

	aAdd(_aSE2, {"E2_EMISSAO", dDataBase, Nil})
	aAdd(_aSE2, {"E2_EMIS1", dDataBase, Nil})
	aAdd(_aSE2, {"E2_VENCTO", _dVencto, Nil})
	aAdd(_aSE2, {"E2_VENCREA", DataValida(_dVencto), Nil})
	aAdd(_aSE2, {"E2_VENCORI", _dVencto, Nil})

	aAdd(_aSE2, {"E2_HIST", _oJsonDOX:GetJsonText("observacao"), Nil})
	aAdd(_aSE2, {"E2_CCUSTO", _oJsonDOX:GetJsonText("centroCusto"), Nil})
	aAdd(_aSE2, {"E2_VALOR", Val(_oJsonDOX:GetJsonText("valor")), Nil})
	aAdd(_aSE2, {"E2_SALDO", Val(_oJsonDOX:GetJsonText("valor")), Nil})

	aAdd(_aSE2, {"E2_NOMERET", "", Nil})
	aAdd(_aSE2, {"E2_MOEDA", 1, Nil})
	aAdd(_aSE2, {"E2_ORIGEM", "FINA050", Nil})

	aAdd(_aSE2, {"E2_FLUXO", "S", Nil})
	aAdd(_aSE2, {"E2_LA", "N", Nil})

Return(_aSE2)

Static Function CalcParcel(_cNum, _cPrefixo)

	Local _lExiste   := .T.
	Local _cParcela  := "A"
	Local _cQuery    := ""
	Local _cAliasSE2 := GetNextAlias()

	While (_lExiste)
		_cQuery := " SELECT COUNT(E2_NUM) AS QTDE "
		_cQuery += " FROM " + RetSqlName("SE2") + " SE2 WITH (NOLOCK) "
		_cQuery += " WHERE SE2.E2_FORNECE = '" + SA2->A2_COD + "'"
		_cQuery += " AND   SE2.E2_LOJA = '" + SA2->A2_LOJA + "'"
		_cQuery += " AND   SE2.E2_PREFIXO = '" +_cPrefixo + "'"
		_cQuery += " AND   SE2.E2_NUM = '" +_cNum + "'"
		_cQuery += " AND   SE2.E2_PARCELA = '" + _cParcela + "'"
		_cQuery += " AND   SE2.E2_TIPO = '" + TIPO_TIT + "'"
		_cQuery += " AND   SE2.D_E_L_E_T_ = '' "

		TCQuery _cQuery New Alias (_cAliasSE2)

		If ((_cAliasSE2)->QTDE == 0)
			_lExiste := .F.
		Else
			If (_cParcela <> "Z")
				_cParcela := Soma1(_cParcela)
			Else
				_cParcela := "AA"
			EndIf
		EndIf

		(_cAliasSE2)->(DbCloseArea())
		_cAliasSE2 := GetNextAlias()
	End

Return(_cParcela)

Static Function CalcVencto()

	Local _dVencto   := dDataBase
	Local _nDiaSeman := DoW(dDataBase)

	If (_nDiaSeman) == 1 // Domingo
		_dVencto := DaySum(dDataBase, 4)
	ElseIf (_nDiaSeman) == 2 // Segunda-feira
		_dVencto := DaySum(dDataBase, 3)
	ElseIf (_nDiaSeman) == 3 // Terca-feira
		_dVencto := DaySum(dDataBase, 2)
	ElseIf (_nDiaSeman) == 4 // Quarta-feira
		_dVencto := DaySum(dDataBase, 8)
	ElseIf (_nDiaSeman) == 5 // Quinta-feira
		_dVencto := DaySum(dDataBase, 7)
	ElseIf (_nDiaSeman) == 6 // Sexta-feira
		_dVencto := DaySum(dDataBase, 6)
	ElseIf (_nDiaSeman) == 7 // Sabado
		_dVencto := DaySum(dDataBase, 5)
	EndIf

Return(_dVencto)

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

Static Function ValidSE2(_oJsonDOX)

	Local _lValidOk  := .T.
	Local _cCnpjForn := ""
	Local _cCCusto   := ""

	_cCnpjForn := _oJsonDOX:GetJsonText("cnpjCpfParaReembolso")

	SA2->(DbSetOrder(3))
	SA2->(DbGoTop())
	If (!SA2->(DbSeek(xFilial("SA2")+_cCnpjForn)))
		RetErro("Fornecedor nao encontrado pelo CNPJ/CPF informado! [" + _cCnpjForn + "]")
		_lValidOk := .F.
	EndIf

	_cCCusto := _oJsonDOX:GetJsonText("centroCusto")

	CTT->(DbSetOrder(1))
	CTT->(DbGoTop())
	If (!CTT->(DbSeek(xFilial("CTT")+_cCCusto)))
		RetErro("Centro de custo nao encontrado! [" + _cCCusto + "]")
		_lValidOk := .F.
	Else
		If (CTT->CTT_CLASSE <> "2")
			RetErro("Centro de custo informado não é do tipo analítico! [" + _cCCusto + "]")
			_lValidOk := .F.
		EndIf

		If (CTT->CTT_BLOQ == "1")
			RetErro("Centro de custo informado encontra-se bloqueado para uso! [" + _cCCusto + "]")
			_lValidOk := .F.
		EndIf
	EndIf

Return(_lValidOk)