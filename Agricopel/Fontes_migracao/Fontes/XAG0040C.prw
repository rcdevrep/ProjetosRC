#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} XAG0040C
Replicador de cadastro de produtos entre empresas
Esta rotina realiza a inserção do produto conforme informações vindas do array
@author Leandro F Silveira
@since 24/09/2018
@return sem retorno
@type function
/*/
User Function XAG0040C(_cB1_COD, _cB1_FILIAL, _cCGCSA2, _aSB1, _aSB5, _lMesmaEmp)

	Local cFilTemp := cFilial

	If (!Empty(_cB1_FILIAL))
		SM0->(DbSeek(cEmpAnt+_cB1_FILIAL))
		cFilial := _cB1_FILIAL
	EndIf

	AddSB1(_cB1_COD, _cB1_FILIAL, _cCGCSA2, _aSB1, _lMesmaEmp)
	AddSB5(_cB1_COD, _cB1_FILIAL, _aSB5)

	cFilial := cFilTemp

Return Nil

Static Function AddSB1(_cB1_COD, _cB1_FILIAL, _cCGCSA2, _aSB1, _lMesmaEmp)

	Local aCamposSB1 := CamposSB1(_lMesmaEmp)

	DbSelectArea("SB1")
	RecLock("SB1", .T.)

	SetArrTab("SB1", aCamposSB1, _aSB1)

	SetValCampo("SB1", "B1_COD", _cB1_COD)
	SetValCampo("SB1", "B1_FILIAL", _cB1_FILIAL)

	SetValCampo("SB1", "B1_MSBLQL", "2") // Bloqueado = NÃO
	SetValCampo("SB1", "B1_SITUACA", "1") // Situação = Ativo
	SetValCampo("SB1", "B1_EXPORTA", "N") // Exporta = Não
	SetValCampo("SB1", "B1_GARANT", "2") // Garantia extendida = Não

	SetValCampo("SB1", "B1_CABCMIN", "N") // ABC Estoque Mínimo = Não Calcula
	SetValCampo("SB1", "B1_CABCMAX", "N") // ABC Estoque Máximo = Não Calcula

	SetValCampo("SB1", "B1_ORIGIMP", "XAG0040")

	SetFornPad(_cCGCSA2, _cB1_FILIAL)

	MsUnlock("SB1")

Return Nil

Static Function AddSB5(_cB1_COD, _cB1_FILIAL, _aSB5)

	Local aCamposSB5 := {}

	If (Len(_aSB5) > 0)
		aCamposSB5 := CamposSB5()

		DbSelectArea("SB5")
		RecLock("SB5", .T.)

		SetArrTab("SB5", aCamposSB5, _aSB5)

		SetValCampo("SB5", "B5_COD", _cB1_COD)
		SetValCampo("SB5", "B5_FILIAL", _cB1_FILIAL)

		MsUnlock("SB1")
	EndIf

Return Nil

Static Function SetArrTab(_cTabela, _aCampos, _aValores)

	Local xValor
	Local cCampo := ""
	Local nI     := 0

	For nI := 1 To Len(_aCampos)
		cCampo := _aCampos[nI]

		If (PosArray(cCampo, _aValores) > 0)
			xValor := GetValArr(cCampo, _aValores)
			SetValCampo(_cTabela, cCampo, xValor)
		EndIf
	End

Return Nil

Static Function SetValCampo(_cTabela, _cCampo, _xValor)

	If ((_cTabela)->(FieldPos(_cCampo)) > 0)
		&(_cTabela+"->"+_cCampo) := _xValor
	EndIf

Return Nil

Static Function CamposSB1(_lMesmaEmp)

	Local _aRet     := {}
	Local _aAreaSX3 := {}
	Local _nFCount  := 0
	Local nX        := 0
	Local cCampoTab := ""

	If (_lMesmaEmp)

		_aAreaSX3 := SX3->(GetArea())

		_nFCount := SB1->(FCount())
		SX3->(DbSetOrder(2))

		For nX := 1 To _nFCount
			cCampoTab  := AllTrim(SB1->(FieldName(nX)))

			SX3->(DbGoTop())
			If (SX3->(DbSeek(cCampoTab)) .And. SX3->X3_CONTEXT <> "V") 
				aAdd(_aRet, cCampoTab)
			End
		End

		RestArea(_aAreaSX3)
	Else
		aAdd(_aRet, "B1_DESC")
		aAdd(_aRet, "B1_UM")
		aAdd(_aRet, "B1_POSIPI")
		aAdd(_aRet, "B1_CEST")
		aAdd(_aRet, "B1_PESO")
		aAdd(_aRet, "B1_CONV")
		aAdd(_aRet, "B1_TIPCONV")
		aAdd(_aRet, "B1_CODBAR")
		aAdd(_aRet, "B1_PRVALID")
		aAdd(_aRet, "B1_TROCA")
		aAdd(_aRet, "B1_QE")
		aAdd(_aRet, "B1_LE")
		aAdd(_aRet, "B1_PE")
		aAdd(_aRet, "B1_EXPORTA")
		aAdd(_aRet, "B1_VOLUME")
		aAdd(_aRet, "B1_EMBTKE")
		aAdd(_aRet, "B1_TITORIG")'
	EndIf

Return _aRet

Static Function CamposSB5()

	Local _aRet := {}

	aAdd(_aRet, "B5_CEME")
	aAdd(_aRet, "B5_EMB1")
	aAdd(_aRet, "B5_QE1")
	aAdd(_aRet, "B5_UMIND")
	aAdd(_aRet, "B5_ECCARAC")

Return _aRet

Static Function GetValArr(_cCampo, _aValores)

	Local nPosReg := 0
	Local xValor

	nPosReg := PosArray(_cCampo, _aValores)

	If (nPosReg > 0)
		xValor := _aValores[nPosReg, 2]
	Else
		xValor :=  &('ER_'+_cCampo) // Força geração de erro caso não encontre campo
	EndIf

Return xValor

Static Function PosArray(_cCampo, _aValores)

	Local _nRet := 0

	_nRet := aScan(_aValores, {|Reg| Reg[1] == _cCampo})

Return _nRet

Static Function SetFornPad(_cCGCSA2, _cB1_FILIAL)

	Local _aAreaSA2 := SA2->(GetArea())
	Local _cFilSA2  := xFilial("SA2")

	If !Empty(_cFilSA2) .And. !Empty(_cB1_FILIAL)
		_cFilSA2 := _cB1_FILIAL
	EndIf

	SA2->(DbSetOrder(3))
	SA2->(DbGoTop())
	If (SA2->(DbSeek(_cFilSA2+_cCGCSA2)))
		SetValCampo("SB1", "B1_PROC", SA2->A2_COD)
		SetValCampo("SB1", "B1_LOJPROC", SA2->A2_LOJA)
	EndIf

	RestArea(_aAreaSA2)

Return Nil