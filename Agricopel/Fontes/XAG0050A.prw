#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0050A
Rotina chamada através de XAG0050
Gera arquivo para enviar ao SERASA
@author Leandro Silveira
@since 12/12/2019
@version 1
@type function
/*/
User Function XAG0050A()

	If (ProcPerg())
		ProcArq()
	EndIf

Return()

Static Function ProcArq()

	Local _cFile     := ""
    Local cAliasQry  := ""
    Local _cLin      := ""
    Local cValor     := ""
	Local cUltA1Cgc  := ""
	Local _nHdl      := 0
    Local nAux       := 0
	Local nTotSA1    := 0
	Local nTotSE1    := 0
	Local nTotRegs   := 0

	Private cDtCorte   := "20191115"

	If (At(".txt", MV_PAR03) > 0)
		_cFile  := AllTrim(MV_PAR03)
	Else
		_cFile  := AllTrim(MV_PAR03) + ".txt"
	EndIf

	_nHdl := FCreate(_cFile)

	If _nHdl == -1
		MsgAlert("O arquivo " + _cFile + " não pode ser gerado! Verifique os parametros.", "Atenção!")
		Return
	Endif

	// O bloco Abaixo tem como objetivo montar o arquivo com os dados do cliente
	// A primeira parte gravara cabecalho do arquivo
	_cLin := "00RELATO COMP NEGOCIOS81632093000179" + DTOS(MV_PAR01) + DTOS(MV_PAR02) + "S" + Space(15) + Space(3) + Space(29) + "V.01" + Space(26) + CRLF

	FWrite(_nHdl,_cLin)

	ProcRegua(0)

	nTotRegs  := QryCount()
	cAliasQry := QryExport()

	DbSelectArea(cAliasQry)
	ProcRegua(nTotRegs)
	Do While !Eof()

		If ((cAliasQry)->A1_CGC != cUltA1Cgc)
			_cLin := "01" + (cAliasQry)->A1_CGC + "01" + (cAliasQry)->A1_PRICOM

			IF  DDATABASE - STOD((cAliasQry)->A1_PRICOM)  >= 365
				_cLin += '1'
			Elseif AllTrim(STOD((cAliasQry)->A1_PRICOM)) <> '' .And. DDATABASE - STOD((cAliasQry)->A1_PRICOM) < 365
				_cLin += '2'
			Elseif AllTrim(STOD((cAliasQry)->A1_PRICOM)) == ""
				_cLin += '3'
			Endif

			_cLin += Space(38) + Space(34) + Space(1) +  Space(30) + CRLF

			FWrite(_nHdl, _cLin)

			cUltA1Cgc := (cAliasQry)->A1_CGC
			nTotSA1++
		EndIf

		If AllTrim((cAliasQry)->DELET) <> "*"
			cValor  := StrZero(((cAliasQry)->E1_VALOR*100),13)
		Else
			cValor := "9999999999999"
		EndIf

		_cLin  := "01"

		nAux := 14 - Len(AllTrim((cAliasQry)->A1_CGC))

		// Data de Corte para títulos com Prefixo de 3 posições
		If (cAliasQry)->E1_EMISSAO >= cDtCorte  //Chave completa
			cTitulo := (cAliasQry)->E1_PREFIXO + (cAliasQry)->E1_NUM + (cAliasQry)->E1_PARCELA
		Else
			cTitulo := AllTrim((cAliasQry)->E1_PREFIXO) + AllTrim((cAliasQry)->E1_NUM) + AllTrim((cAliasQry)->E1_PARCELA)
		Endif

		nEspAux := 32 - Len(AllTrim(cTitulo))

		_cLin  += AllTrim((cAliasQry)->A1_CGC)  + Space(nAux) //CNPJ
		_cLin  += '05' // Tipo de dados
		_cLin  += Space(10) //numero do titulo com 10 posicoes
		_cLin  += (cAliasQry)->E1_EMISSAO //Data de Emissao  '
		_cLin  += cValor // Valor Saldo
		_cLin  += (cAliasQry)->E1_VENCREA  // Data vencimento
		_cLin  += (cAliasQry)->E1_BAIXA   //Data Pagamento
		_cLin  += "#D" // Numero de titulos com mais de 10 posicoes
		_cLin  += AllTrim(cTitulo) + Space(nEspAux) + Space(1) + Space(24) + Space(2) + Space(1) + Space(1) + Space(2)
		_cLin  += CRLF

		FWrite(_nHdl, _cLin)

		nTotSE1++
		DbSelectArea(cAliasQry)
		(cAliasQry)->(DbSkip())

		IncProc("Exportando registros: " + cValToChar(nTotSE1) + " / " + cValToChar(nTotRegs))
	Enddo

	(cAliasQry)->(DbCloseArea())

	_cLin := '99'+ StrZero(nTotSA1 , 11 ) + Space(44) + StrZero(nTotSE1, 11) + Space(32) + Space(30) + CRLF

	FWrite(_nHdl, _cLin)
	FClose(_nHdl)

	MsgInfo("Exportacao concluida, arquivo gerado em: " + CRLF + _cFile)

Return

Static Function QryExport()

    Local cQuery    := ""
    Local cAliasQry := ""

    cQuery += " SELECT "

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

	cQuery += QryWhere()

	cQuery += " ORDER BY A1_COD, A1_LOJA, A1_PRICOM, A1_CGC, A1_NOME, E1_EMISSAO, E1_NUM, E1_PARCELA "

    cAliasQry := MPSysOpenQuery(cQuery)

Return(cAliasQry)

Static Function QryCount()

    Local cQuery    := ""
    Local cAliasQry := ""
	Local nQtdRegs  := 0

	cQuery := " SELECT COUNT(*) AS QTDREGS "
	cQuery += QryWhere()

	cAliasQry := MPSysOpenQuery(cQuery)
	nQtdRegs := (cAliasQry)->QTDREGS

	(cAliasQry)->(DbCloseArea())

Return(nQtdRegs)

Static Function QryWhere()

	Local cQuery := ""

    cQuery += " FROM " + RetSqlname("SE1") + " SE1 WITH (NOLOCK), " + RetSqlName("SA1") + " SA1 WITH (NOLOCK) "

    cQuery += " WHERE SA1.A1_COD  = SE1.E1_CLIENTE "
    cQuery += " AND   SA1.A1_LOJA = SE1.E1_LOJA "

    cQuery += " AND ( "
    cQuery += "      (SE1.E1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '"  + DTOS(MV_PAR02) + "' AND SE1.E1_BAIXA = '') "
    cQuery += "   OR (SE1.E1_BAIXA BETWEEN   '" + DTOS(MV_PAR01) + "' AND '"  + DTOS(MV_PAR02) + "')"
    cQuery += " )

    cQuery += " AND SA1.D_E_L_E_T_ = '' "
    cQuery += " AND SE1.E1_TIPO = 'NF' "
    cQuery += " AND SA1.A1_COD NOT IN ('00368','00382') "
    cQuery += " AND SA1.A1_PESSOA = 'J' "

	// SubQuery faz-se necessária porque cliente precisa ter pelo menos um SE1 ativo (D_E_L_E_T_ = '')
	cQuery += " AND EXISTS (SELECT SE1_SUB.R_E_C_N_O_ "
	cQuery += "             FROM " + RetSqlname("SE1") + " SE1_SUB WITH (NOLOCK) "
    cQuery += "             WHERE SA1.A1_COD  = SE1_SUB.E1_CLIENTE "
    cQuery += "             AND   SA1.A1_LOJA = SE1_SUB.E1_LOJA "
	cQuery += "             AND   SE1_SUB.D_E_L_E_T_ = '' "
    cQuery += "             AND   SE1_SUB.E1_TIPO = 'NF' "
    cQuery += "             AND ( "
    cQuery += "                  (SE1_SUB.E1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '"  + DTOS(MV_PAR02) + "' AND SE1_SUB.E1_BAIXA = '') "
    cQuery += "               OR (SE1_SUB.E1_BAIXA BETWEEN   '" + DTOS(MV_PAR01) + "' AND '"  + DTOS(MV_PAR02) + "')"
    cQuery += "             ) "
	cQuery += "     ) "

Return(cQuery)

Static Function ProcPerg()

	Local _aRegs  := {}
	Local _cPerg  := "XAG0050A"
	Local _lRetOk := .F.

	aAdd(_aRegs,{_cPerg,"01","Data Inicial     ","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(_aRegs,{_cPerg,"02","Data Final       ","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(_aRegs,{_cPerg,"03","Destino          ","mv_ch3","C",40,0,0,"G","","mv_par03","","","","","","","","","","","","","","","DIR"})

	U_CriaPer(_cPerg, _aRegs)

	_lRetOk := Pergunte(_cPerg, .T.)

Return(_lRetOk)