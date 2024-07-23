#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} XAG0040A
- Replicador de cadastro de produtos entre empresas 
   - Mostra grid das empresas
   - Monta Array com as informações do produto a ser replicado
   - Chama XAG0040B passando array do produto (SB1) e array de complemento (SB5), para cada empresa escolhida
@author Leandro F Silveira
@since 03/09/2018
@return sem retorno
@type function
/*/
User Function XAG0040A()

    Local _aEmpre  := EscEmpresa()
    Local _aArea   := {}

    If (Len(_aEmpre) > 0 .And. MsgYesNo("Confirma a replicação do cadastro do produto para a(s) empresa(s) selecionadas?" + CRLF + ;
                                        "Produto: " + AllTrim(SB1->B1_COD) + " - " + AllTrim(SB1->B1_DESC), "Replicação de produto"))
        _aArea := GetArea()

        ExecRepl(_aEmpre)

        RestArea(_aArea)
    EndIf

Return()

Static Function EscEmpresa()

    Local _aEmpresas := {}
    Local _aRet      := {}
    Local nX         := 0
    Local nRetScan   := 0

    _aEmpresas := U_XAGEMP(.T.)

    For nX := 1 To Len(_aEmpresas)
        nRetScan := IIf(Len(_aRet) > 0, aScan(_aRet, {|x| x[1] == _aEmpresas[nX, 1]} ), 0)

        If (nRetScan > 0)
            aAdd(_aRet[nRetScan][2], _aEmpresas[nX, 2])
        Else
            aAdd(_aRet, {_aEmpresas[nX, 1], {_aEmpresas[nX, 2]}})
        EndIf
    End

Return(_aRet)

Static Function ExecRepl(_aEmpre)

    Local _aSB1      := Nil
    Local _aSB5      := Nil
    Local _aLog      := {}
    Local _cLog      := ""
    Local _cCGCSA2   := ""
    Local nI         := 0
    Local nX         := 0
    Local nQtdEmp    := Len(_aEmpre)

    _aSB1 := MontarSB1()
    _aSB5 := MontarSB5()
    _cCGCSA2 := GetCGCForn()

    For nI := 1 to nQtdEmp        
        MsgRun('Replicando produto - ' + cValToChar(nI) + "/" + cValToChar(nQtdEmp) + " - Empresa: " + _aEmpre[nI][1], "Aguarde - Processando",{|| _aLog := ReplEmpre(_aEmpre[nI], _cCGCSA2, _aSB1, _aSB5)})

        For nX := 1 to Len(_aLog)
            _cLog := _cLog + _aLog[nX] + CRLF
        End
    End

    MostrarLog("Fim da replicação de produtos!", _cLog)

Return Nil

Static Function ReplEmpre(_aEmpDest, _cCGCSA2, _aSB1, _aSB5)

    Local _aLog      := {}
    Local _cLogJob   := {}

    aAdd(_aLog, Replicate("-", 20))
    aAdd(_aLog, "Empresa: " + _aEmpDest[1] + IIf(_aEmpDest[1] == cEmpAnt, " - Mesma empresa que a origem", ""))

    _cLogJob := StartJob("U_XAG0040B", GetEnvServer(), .T., cEmpAnt, _aEmpDest, _cCGCSA2, _aSB1, _aSB5)

    aAdd(_aLog, _cLogJob)

Return _aLog

Static Function MontarSB1()

	Local _aSB1      := {}
	Local nI         := 0
	Local nQtdeCampo := SB1->(FCount())
	Local cNomeCampo := ""

	For nI := 1 to nQtdeCampo
		cNomeCampo := SB1->(FieldName(nI))
        aAdd(_aSB1, {cNomeCampo, SB1->&(cNomeCampo)})
	End

    SetOrigem(_aSB1)

Return _aSB1

Static Function MontarSB5()

    Local aAreaSB5   := {}
	Local _aSB5      := {}
	Local nI         := 0
	Local nQtdeCampo := SB5->(FCount())
	Local cNomeCampo := ""

    aAreaSB5 := SB5->(GetArea())

    SB5->(DbSetOrder(1))
    SB5->(DbGoTop())
    If (SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD)))

        For nI := 1 to nQtdeCampo
            cNomeCampo := SB5->(FieldName(nI))
            aAdd(_aSB5, {cNomeCampo, SB5->&(cNomeCampo)})
        End
    EndIf

    RestArea(aAreaSB5)

Return _aSB5

Static Function MostrarLog(cTitulo, cMsg)

	Local oDlgMemo
	Local oButton1
	Local oMultiGet1
	Local cMultiGet1 := ""

	cMultiGet1 := cMsg

	DEFINE MSDIALOG oDlgMemo TITLE cTitulo FROM 000, 000  TO 555, 650 COLORS 0, 16777215 PIXEL

	    @ 005, 005 GET oMultiGet1 VAR cMultiGet1 OF oDlgMemo MULTILINE SIZE 315, 250 COLORS 0, 16777215 READONLY HSCROLL PIXEL
   		@ 260, 280 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgMemo PIXEL Action(lRetMemo := .T. , oDlgMemo:End() )

	ACTIVATE MSDIALOG oDlgMemo CENTERED

Return Nil

Static Function SetOrigem(_aSB1)

    Local _cCampo := "B1_TITORIG"
    Local _cValor := ""
    Local _nPos   := 0

    _nPos := aScan(_aSB1, {|Reg| Reg[1] == _cCampo})

    _cValor := "XAG0040 - " + cEmpAnt + "-" + cFilial + "-" + AllTrim(SB1->B1_COD)

    _aSB1[_nPos, 2] := _cValor

Return Nil

Static Function GetCGCForn()

    Local _cRet     := ""
    Local _aAreaSA2 := SA2->(GetArea())

    SA2->(DbSetOrder(1))
    SA2->(DbGoTop())
    If (SA2->(DbSeek(xFilial("SA2")+SB1->B1_PROC+SB1->B1_LOJPROC)))
        _cRet := SA2->A2_CGC
    EndIf

    RestArea(_aAreaSA2)

Return _cRet