#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0050A
Rotina de GERAÇÃO de arquivo SERASA
Refatoração de "dserasa.prw"
@author Leandro F Silveira
/*/
//-------------------------------------------------------------------
User Function XAG0050A()

	If (ConfPerg())
		Processa( {|| GerarArq() }, "Gerando arquivo semanal", "Carregando dados para geração do arquivo", .F.)
	EndIf

Return()

Static Function ConfPerg()

	Local _aPerg := {}
	Local _cPerg := "XAG0050A"
	Local lRet   := .F.

	AADD(_aPerg,{_cPerg,"01","Data Inicial  ?","mv_ch1","D",8 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(_aPerg,{_cPerg,"02","Data Final    ?","mv_ch2","D",8 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(_aPerg,{_cPerg,"03","Destino       ?","mv_ch3","C",50,0,0,"G","","mv_par03","","","","","","","","","","","","","","","DIR"})

	U_CriaPer(_cPerg, _aPerg)

	lRet := Pergunte(_cPerg,.T.)

Return(lRet)

Static Function GerarArq()

	Local cAliasQRY  := ""
	Local cUltimoCGC := ""
	Local nQtdReg    := 0
	Local nQtdSA1    := 0
	Local nQtdSE1    := 0

	Local oFile := Nil

	oFile := FwFileWriter():New(AllTrim(MV_PAR03), .T.)

	If (oFile:Exists())
		oFile:Erase()
	EndIf

	If !(oFile:Create())
		MsgAlert("O arquivo [" + AllTrim(MV_PAR03) + "] nao pode ser gerado! Verifique os parametros.","Atencao!")
		Return
	Endif

	WriteCab(oFile)

	nQtdReg  := GetQtdCli()

	If (nQtdReg == 0)
		MsgInfo("Não há dados gerados a partir dos parâmetros informados!")
		Return
	EndIf

	cAliasQRY := SqlDados()

	ProcRegua(nQtdReg)
	Do While !(cAliasQRY)->(Eof())

		If (cUltimoCGC <> (cAliasQRY)->A1_CGC)
			WriteSA1(oFile, cAliasQRY)

			cUltimoCGC := (cAliasQRY)->A1_CGC
			nQtdSA1++
		EndIf

		WriteSE1(oFile, cAliasQRY)
		nQtdSE1++

		(cAliasQRY)->(DbSkip())

		DoIncProc(cAliasQRY, nQtdSE1, nQtdReg)
	Enddo

	(cAliasQRY)->(DbCloseArea())

	WriteRod(oFile, nQtdSA1, nQtdSE1)
	oFile:Close()

	MsgInfo("Arquivo gerado com sucesso!", "Fim do processamento")

Return

Static Function DoIncProc(cAliasQRY, nQtdSE1, nQtdReg)

	Local cIncProc := ""

	cIncProc := "[" + cValToChar(nQtdSE1) + "/" + cValToChar(nQtdReg) +  "] - "
	cIncProc += "Cliente: " + AllTrim((cAliasQRY)->A1_COD) + ' - ' + AllTrim((cAliasQRY)->A1_NOME)
	cIncProc += "Tit: " + AllTrim((cAliasQRY)->E1_NUM) + " - "
	cIncProc += "Pref: " + AllTrim((cAliasQRY)->E1_NUM) + " - "
	cIncProc += "Parc: " + AllTrim((cAliasQRY)->E1_PARCELA) + " - "

	IncProc(cIncProc)

Return

Static Function WriteRod(oFile, nQtdSA1, nQtdSE1)

	Local _cLin := ""

	_cLin := "99"
	_cLin += StrZero(nQtdSA1, 11)
	_cLin += Space(44)
	_cLin += StrZero(nQtdSE1, 11)
	_cLin += Space(32)
	_cLin += Space(30)
	_cLin += CRLF

	oFile:Write(_cLin)

Return

Static Function WriteCab(oFile)

	Local _cLin := ""

	// O bloco Abaixo tem como objetivo montar o arquivo com os dados do cliente
	// A primeira parte gravará o cabecalho do arquivo
	_cLin := "00RELATO COMP NEGOCIOS81632093000179"
	_cLin += DtoS(MV_PAR01)
	_cLin += DtoS(MV_PAR02)
	_cLin += "S"
	_cLin += Space(15)
	_cLin += Space(3)
	_cLin += Space(29)
	_cLin += "V.01"
	_cLin += Space(26)
	_cLin += CRLF

	oFile:Write(_cLin)

Return

Static Function WriteSA1(oFile, cAliasQRY)

	Local _cLin := ""

	_cLin := "01"
	_cLin += (cAliasQRY)->A1_CGC
	_cLin += "01"
	_cLin += (cAliasQRY)->A1_PRICOM

	If (Empty((cAliasQRY)->A1_PRICOM))
		_cLin += '3'
	Else
		If ((dDataBase - StoD((cAliasQRY)->A1_PRICOM)) >= 365)
			_cLin += '1'
		Else
			_cLin += '2'
		EndIf
	EndIf

	_cLin += Space(38)
	_cLin += Space(34)
	_cLin += Space(1)
	_cLin += Space(30)
	_cLin += CRLF

	oFile:Write(_cLin)

Return()

Static Function WriteSE1(oFile, cAliasQRY)

	Local _cLin   := ""
	Local cValor  := ""
	Local nAux    := 0
	Local nEspAux := 0

	If Empty((cAliasQRY)->DELET)
		cValor  := StrZero(((cAliasQRY)->E1_VALOR * 100), 13)
	Else
		cValor := "9999999999999"
	EndIf

	nAux  := 14 - Len(AllTrim((cAliasQRY)->A1_CGC))

	cTitulo := AllTrim((cAliasQRY)->E1_PREFIXO) + AllTrim((cAliasQRY)->E1_NUM) + AllTrim((cAliasQRY)->E1_PARCELA)
	nEspAux := 32 - Len(AllTrim(cTitulo))

	_cLin := "01"
	_cLin  += AllTrim((cAliasQRY)->A1_CGC)
	_cLin  += Space(nAux)
	_cLin  += "05"
	_cLin  += Space(10)
	_cLin  += (cAliasQRY)->E1_EMISSAO
	_cLin  += cValor
	_cLin  += (cAliasQRY)->E1_VENCREA
	_cLin  += (cAliasQRY)->E1_BAIXA
	_cLin  += "#D"
	_cLin  += AllTrim(cTitulo)
	_cLin  += Space(nEspAux)
	_cLin  += Space(1)
	_cLin  += Space(24)
	_cLin  += Space(2)
	_cLin  += Space(1)
	_cLin  += Space(1)
	_cLin  += Space(2)
	_cLin  += CRLF

	oFile:Write(_cLin)

Return()

Static Function GetQtdCli()

	Local cQuery     := ""
	Local cAliasQRY  := GetNextAlias()
	Local nQtdCli    := 0
	Local _cDataIni  := DtoS(MV_PAR01)
	Local _cDataFim  := DtoS(MV_PAR02)

	cQuery := " SELECT COUNT(SA1.A1_COD) AS QTDECLI "

	cQuery += " FROM " + RetSqlname("SE1") + " SE1 (NOLOCK) "
	cQuery += "    JOIN " + RetSqlname("SA1") + " SA1 (NOLOCK) "
	cQuery += "       ON (SE1.E1_CLIENTE = SA1.A1_COD "
	cQuery += "       AND SE1.E1_LOJA = SA1.A1_LOJA "
	cQuery += "       AND SA1.A1_PESSOA = 'J' "
	cQuery += "       AND SA1.A1_COD NOT IN ('00368','00382') "
	cQuery += "       AND SA1.D_E_L_E_T_ = '') "

	cQuery += " WHERE SE1.E1_TIPO = 'NF' "

	cQuery += "    AND ( "
	cQuery += "       (SE1.E1_EMISSAO BETWEEN '" + _cDataIni + "' AND '" + _cDataFim + "'"
	cQuery += "        AND SE1.E1_BAIXA = '') "
	cQuery += "       OR (SE1.E1_BAIXA BETWEEN '" + _cDataIni + "' AND '" + _cDataFim + "')"
	cQuery += "    ) "

	TCQuery cQuery NEW ALIAS (cAliasQRY)

	nQtdCli := (cAliasQRY)->QTDECLI

	(cAliasQRY)->(DbCloseArea())

Return(nQtdCli)

Static Function SqlDados()

	Local cQuery     := ""
	Local cAliasQRY  := GetNextAlias()
	Local _cDataIni  := DtoS(MV_PAR01)
	Local _cDataFim  := DtoS(MV_PAR02)

	cQuery := " SELECT "
	cQuery += "    SA1.A1_COD, "
	cQuery += "    SA1.A1_LOJA, "
	cQuery += "    SA1.A1_PRICOM, "
	cQuery += "    SA1.A1_CGC, "
	cQuery += "    SA1.A1_NOME, "
	cQuery += "    SE1.E1_PREFIXO, "
	cQuery += "    SE1.E1_NUM, "
	cQuery += "    SE1.E1_PARCELA, "
	cQuery += "    SE1.E1_EMISSAO, "
	cQuery += "    SE1.E1_SALDO, "
	cQuery += "    SE1.E1_VENCREA, "
	cQuery += "    SE1.E1_BAIXA, "
	cQuery += "    SE1.E1_VALOR, "
	cQuery += "    SE1.D_E_L_E_T_ AS DELET "

	cQuery += " FROM " + RetSqlname("SE1") + " SE1 (NOLOCK) "
	cQuery += "    JOIN " + RetSqlname("SA1") + " SA1 (NOLOCK) "
	cQuery += "       ON (SE1.E1_CLIENTE = SA1.A1_COD "
	cQuery += "       AND SE1.E1_LOJA = SA1.A1_LOJA "
	cQuery += "       AND SA1.A1_PESSOA = 'J' "
	cQuery += "       AND SA1.A1_COD NOT IN ('00368','00382') "
	cQuery += "       AND SA1.D_E_L_E_T_ = '') "

	cQuery += " WHERE SE1.E1_TIPO = 'NF' "

	cQuery += "    AND ( "
	cQuery += "       (SE1.E1_EMISSAO BETWEEN '" + _cDataIni + "' AND '" + _cDataFim + "'"
	cQuery += "        AND SE1.E1_BAIXA = '') "
	cQuery += "       OR (SE1.E1_BAIXA BETWEEN '" + _cDataIni + "' AND '" + _cDataFim + "')"
	cQuery += "    ) "

	cQuery += " ORDER BY SA1.A1_CGC, SE1.E1_EMISSAO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_PREFIXO "

	TCQuery cQuery NEW ALIAS (cAliasQRY)

Return(cAliasQRY)