#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} XAG0040B
- Replicador de cadastro de produtos entre empresas
- � chamado via Job por XAG0040A
- Monta environment com empresa vinda de par�metro (_cEmp)
- Insere dados do produto recebido (_aSB1Repl)
- Se controla por filial (xFilial("SB1") != "") ir� inserir para cada filial
- Se n�o controlar por filial (xFilial("SB1") == "") ir� inserir somente um produto
@author Leandro F Silveira
@since 03/09/2018
@return sem retorno
@type function
/*/
User Function XAG0040B(_cEmpOrig, _aEmpDest, _cCGCSA2, _aSB1, _aSB5)

	Local bError
	Local oError

	Private _aReplLog  := {}
	Private _lMesmaEmp := _cEmpOrig == _aEmpDest[1]
	Private _lCompSB1  := .F.

	bError := ErrorBlock({|oError|AddLogErro(oError)})
	BEGIN SEQUENCE

		RpcSetType(3)
		RPCSetEnv(_aEmpDest[1],"01","","","","",{"SB1,SB5"})

		_lCompSB1 := IsEmpty(xFilial("SB1"))

		If (_lCompSB1)
			AddLog("Empresa compartilha produto por filial")
		Else
			AddLog("Empresa N�O compartilha produto por filial")
		End

		If (_lMesmaEmp)
			ReplMsmEmp(_aEmpDest[2], _cCGCSA2, _aSB1, _aSB5)
		Else
			ReplOutEmp(_aEmpDest[2], _cCGCSA2, _aSB1, _aSB5)
		EndIf

		RpcClearEnv()
	END SEQUENCE
	ErrorBlock(bError)

Return MontaLog()

Static Function ReplMsmEmp(_aFiliais, _cCGCSA2, _aSB1, _aSB5)

	Local _cB1_COD    := ""
	Local _cB1_FILIAL := ""
	Local _aFilRepl   := {}
	Local nI          := 0

	If (_lCompSB1)
		AddLog("Produto n�o inserido, pois a empresa j� possui o produto (1 por empresa)!")
	Else
		_aFilRepl := _aFiliais
		_cB1_COD  := GetValArr("B1_COD", _aSB1)

		For nI := 1 To Len(_aFilRepl)
			_cB1_FILIAL := _aFilRepl[nI]

			AddLog(" --- Filial: " + _cB1_FILIAL + " --- ")

			If (SeekSB1(_cB1_COD, _cB1_FILIAL))
				AddLog("Produto de c�digo " + AllTrim(_cB1_COD) + " j� existe!")
			Else
				U_XAG0040C(_cB1_COD, _cB1_FILIAL, _cCGCSA2, _aSB1, _aSB5, .T.)
				AddLog("Produto inserido: " + AllTrim(_cB1_COD))
			EndIf

		End
	EndIf

Return Nil

Static Function ReplOutEmp(_aFiliais, _cCGCSA2, _aSB1, _aSB5)

	Local _cB1_COD    := ""
	Local _cB1_FILIAL := ""
	Local _aFilRepl   := {}
	Local nI          := 0

	If (_lCompSB1)
		aAdd(_aFilRepl, xFilial("SB1"))
	Else
		_aFilRepl := _aFiliais
	EndIf

	_cB1_COD := GetValArr("B1_COD", _aSB1)
	_cB1_COD := GetCodSB1(_cB1_COD, _aFilRepl)

	For nI := 1 To Len(_aFilRepl)
		_cB1_FILIAL := _aFilRepl[nI]

		If (!Empty(_cB1_FILIAL))
			AddLog(" --- Filial: " + _cB1_FILIAL + " --- ")
		EndIf

		U_XAG0040C(_cB1_COD, _cB1_FILIAL, _cCGCSA2, _aSB1, _aSB5, .F.)
		AddLog("Produto inserido: " + _cB1_COD)
	End

	If __lSX8
		ConfirmSX8()
	EndIf

Return Nil

Static Function GetCodSB1(_cB1_COD, _aFilRepl)

	Local cX3_Relacao := ""
	Local lJaExiste   := .T.
	Local _cRet       := _cB1_COD

	lJaExiste := SeekSB1Arr(_cRet, _aFilRepl)

	If (lJaExiste)

		AddLog("Produto de c�digo " + AllTrim(_cB1_COD) + " j� existe!")

		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("A1_COD"))
			cX3_Relacao := SX3->X3_RELACAO
		Endif

		While (lJaExiste)

			If __lSX8
				ConfirmSX8()
			EndIf

			If !(Empty(cX3_Relacao))
				_cRet := (&cX3_Relacao)
			Else
				_cRet := GetSXENum("SB1", "B1_COD")
			EndIf

			lJaExiste := SeekSB1Arr(_cRet, _aFilRepl)
		End

		AddLog("Novo c�digo gerado: " + _cRet)
	Else
		AddLog("Utilizando o mesmo c�digo de produto: " + _cRet)
	EndIf

Return(_cRet)

Static Function GetFiliais()

	Local _aAreaSMO := SM0->(GetArea())
	Local _aSM0Repl := {}

	While (!SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt)
		aAdd(_aSM0Repl, SM0->M0_CODFIL)
		SM0->(DbSkip())
	End

	RestArea(_aAreaSMO)

Return _aSM0Repl

Static Function GetValArr(_cCampo, _aValores)

	Local nPosReg := 0
	Local xValor

	nPosReg := aScan(_aValores, {|Reg| Reg[1] == _cCampo})

	If (nPosReg > 0)
		xValor := _aValores[nPosReg, 2]
	Else
		xValor :=  &('ER_'+_cCampo) // For�a gera��o de erro caso n�o encontre campo
	EndIf

Return xValor

Static Function SeekSB1(_cB1_COD, _cB1_FILIAL)

	Local lRet := .F.

	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	lRet := SB1->(DbSeek(_cB1_FILIAL+_cB1_COD))

Return lRet

Static Function SeekSB1Arr(_cB1_COD, _aFiliais)

	Local lRet     := .F.
	Local _cFilial := ""
	Local nI       := 0

	For nI := 1 To Len(_aFiliais)
		_cFilial := _aFiliais[nI]

		If (SeekSB1(_cB1_COD, _cFilial))
			lRet := .T.
			Exit
		End
	End

Return lRet

Static Function AddLog(cMsgLog)
	aAdd(_aReplLog, AllTrim(cMsgLog))
Return Nil

Static Function AddLogErro(oError)

	AddLog("Erro: " + AllTrim(oError:Description))
	AddLog("Stack: " + AllTrim(oError:ERRORSTACK))

	Break

Return Nil

Static Function MontaLog()

	Local _cRet := ""
	Local nI    := 0

	_cRet := _aReplLog[1]

	For nI := 2 To Len(_aReplLog)
		_cRet := _cRet + CRLF + _aReplLog[nI]
	End

Return _cRet