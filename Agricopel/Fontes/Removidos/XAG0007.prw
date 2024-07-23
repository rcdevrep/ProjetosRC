
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} XAG0007
//Função de quebra galho - manutenções na SF1 (Exclusão - Desviínculação/Revinculação com Tít a Pagar)
@author Leandro F Silveira
@since 05/10/2017
@version 1
@type function
/*/
User Function XAG0007()

	Local cAmb      := GetEnvServer()
	Private _F2TipoDesv  := 'LFS'
	Private _cAliasTrb   := ""
	Private oTmpTable    := Nil
	

	//Desbloqueada Rotina apenas para ambiente CUSTOM
	If !("CUSTOM" $ Upper(cAmb))
		Alert("Rotina Liberada apenas para Postos(Ambiente Custom).")
		Return
	Endif 

	If PergInicial()
        MsgRun("Carregando Notas de Entrada", "Aguarde - Processando",{|| DadosBrowse()})
		CriarBrowse()
	EndIf

Return()

Static Function PergInicial()

	Local aRegistros := {}
	Local cPerg      := "XAG0007"

	AADD(aRegistros,{cPerg,"01","Nr. nota de      ?","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Nr. nota até     ?","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Dt digitação de  ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Dt digitação até ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Serie            ?","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Cód Fornecedor   ?","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SA2"})
	AADD(aRegistros,{cPerg,"07","Loja Fornecedor  ?","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Limitar itens    ?","mv_ch8","N",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg, aRegistros)

Return Pergunte(cPerg, .T.)

Static Function DadosBrowse()

	Local _cAliasQry   := ""
	Local _cQuery      := ""
	Local iX           := 0
	Local cFieldName   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	_cQuery += "  SELECT "

	If (!Empty(mv_par08) .And. mv_par08 > 0)
		_cQuery += "  TOP " + cValToChar(mv_par08)
	EndIf

	_cQuery += "    CAST(R_E_C_N_O_ AS INTEGER) AS RECNO, "
	_cQuery += "    F1_DOC, "
	_cQuery += "    F1_SERIE, "
	_cQuery += "    F1_FORNECE, "
	_cQuery += "    F1_LOJA, "
	_cQuery += "    F1_EMISSAO, "
	_cQuery += "    F1_DTDIGIT, "
	_cQuery += "    F1_DUPL, "
	_cQuery += "    F1_VALMERC, "
	_cQuery += "    F1_VALBRUT, "

	_cQuery += "    COALESCE((SELECT COUNT(SD1.R_E_C_N_O_) "
	_cQuery += "              FROM " + RetSQLName("SD1") + " SD1 (NOLOCK) "
	_cQuery += "              WHERE SD1.D_E_L_E_T_ = '' "
	_cQuery += "              AND   SF1.F1_DOC     = SD1.D1_DOC "
	_cQuery += "              AND   SF1.F1_SERIE   = SD1.D1_SERIE "
	_cQuery += "              AND   SF1.F1_FILIAL  = SD1.D1_FILIAL "
	_cQuery += "              AND   SF1.F1_FORNECE = SD1.D1_FORNECE "
	_cQuery += "              AND   SF1.F1_LOJA    = SD1.D1_LOJA "
	_cQuery += "              AND   SF1.F1_EMISSAO = SD1.D1_EMISSAO) "
	_cQuery += "    ,0) AS QTSD1, "

	_cQuery += "    COALESCE((SELECT COUNT(SE2.R_E_C_N_O_) "
	_cQuery += "              FROM " + RetSQLName("SE2") + " SE2 (NOLOCK) "
	_cQuery += "              WHERE SE2.D_E_L_E_T_ = '' "
	_cQuery += "              AND   SF1.F1_DOC     = SE2.E2_NUM "
	_cQuery += "              AND   SF1.F1_PREFIXO = SE2.E2_PREFIXO "
	_cQuery += "              AND   SF1.F1_FORNECE = SE2.E2_FORNECE "
	_cQuery += "              AND   SF1.F1_LOJA    = SE2.E2_LOJA "
	_cQuery += "              AND   SF1.F1_EMISSAO = SE2.E2_EMISSAO "
	_cQuery += "    	      AND   SE2.E2_TIPO = 'NF') "
	_cQuery += "    ,0) AS QTSE2VINC, "

	_cQuery += "    COALESCE((SELECT COUNT(SE2.R_E_C_N_O_) "
	_cQuery += "              FROM " + RetSQLName("SE2") + " SE2 (NOLOCK) "
	_cQuery += "              WHERE SE2.D_E_L_E_T_ = '' "
	_cQuery += "              AND   SF1.F1_DOC     = SE2.E2_NUM "
	_cQuery += "              AND   SF1.F1_PREFIXO = SE2.E2_PREFIXO "
	_cQuery += "              AND   SF1.F1_FORNECE = SE2.E2_FORNECE "
	_cQuery += "              AND   SF1.F1_LOJA    = SE2.E2_LOJA "
	_cQuery += "              AND   SF1.F1_EMISSAO = SE2.E2_EMISSAO "
	_cQuery += "              AND   SE2.E2_TIPO    = '" + _F2TipoDesv + "') "
	_cQuery += "    , 0) AS QTSE2DESV "

	_cQuery += "    FROM " + RetSQLName("SF1") + " SF1 (NOLOCK) "
	_cQuery += "    WHERE SF1.D_E_L_E_T_ = '' "
	_cQuery += "    AND   SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
	_cQuery += "    AND   SF1.F1_DOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	_cQuery += "    AND   SF1.F1_STATUS = 'A' "
	_cQuery += "    AND   SF1.F1_TIPO = 'N' "

	If (!Empty(MV_PAR03))
		_cQuery += " AND SF1.F1_DTDIGIT BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "'"
	EndIf

	If (!Empty(MV_PAR05))
		_cQuery += " AND SF1.F1_SERIE   = '" + MV_PAR05 + "' "
	EndIf

	If (!Empty(MV_PAR06))
		_cQuery += " AND SF1.F1_FORNECE = '" + MV_PAR06 + "' "
	EndIf

	If (!Empty(MV_PAR07))
		_cQuery += " AND SF1.F1_LOJA    = '" + MV_PAR07 + "' "
	EndIf

	_cQuery += " ORDER BY SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_EMISSAO "

	_cAliasQry := MpSysOpenQuery(_cQuery)

	For iX := 1 To (_cAliasQry)->(FCount())
		CfgCampo(_cAliasQry, (_cAliasQry)->(FieldName(iX)))
	End

    TCSetField((_cAliasQry), "RECNO", "N", 14, 0)

	If (Empty(_cAliasTrb))
		CriarTRB((_cAliasQry)->(DBStruct()))
	Else
		LimparTRB()
	EndIf

	nFieldCount := (_cAliasTrb)->(FCount())

	While !(_cAliasQry)->(Eof())

		RecLock((_cAliasTrb), .T.)

		For nX := 1 To nFieldCount
			cFieldName := (_cAliasTrb)->(FieldName(nX))
			(_cAliasTrb)->&(cFieldName) := (_cAliasQry)->&(cFieldName)
		Next nX

		MsUnlock((_cAliasTrb))
		(_cAliasQry)->(DbSkip())
	End

	RefrBrowse()

	(_cAliasQry)->(DbCloseArea())
Return()

Static Function CfgCampo(_cAlias, cCampo)

	Local _aTamSX3 := TamSX3(cCampo)

	If (Len(_aTamSX3) > 0)
		TCSetField((_cAlias), cCampo, _aTamSX3[3], _aTamSX3[1], _aTamSX3[2])
	EndIf

Return()

Static Function CriarTRB(aCampos)

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {aCampos[1][1]})
	oTmpTable:Create()

	_cAliasTrb := oTmpTable:GetAlias()

Return()

Static Function LimparTRB()

	Local cQuery := ""

	cQuery := " DELETE FROM " + oTmpTable:GetRealName()

	If TCSqlExec(cQuery) < 0
		Alert(TCSqlError(), "Falha ao carregar dados")
	EndIf

	(oTmpTable:GetAlias())->(DBGoTop())

Return()

Static Function CriarBrowse()

	Local _aCamposBrw := {}

	Private aRotina := {;
	{"Desvincular Tit", "U_XAG0007A(" + (_cAliasTrb) + "->RECNO)", 0, 1},;
	{"Revincular Tit" , "U_XAG0007B(" + (_cAliasTrb) + "->RECNO)", 0, 1},;
	{"Refresh"        , "U_XAG0007C()", 0, 1};
	}

	AADD(_aCamposBrw, SX3Info("F1_DOC"))
	AADD(_aCamposBrw, SX3Info("F1_SERIE"))
	AADD(_aCamposBrw, SX3Info("F1_FORNECE"))
	AADD(_aCamposBrw, SX3Info("F1_LOJA"))
	AADD(_aCamposBrw, SX3Info("F1_DTDIGIT"))
	AADD(_aCamposBrw, SX3Info("F1_DUPL"))
	AADD(_aCamposBrw, SX3Info("F1_VALMERC"))
	AADD(_aCamposBrw, SX3Info("F1_VALBRUT"))

	AADD(_aCamposBrw, {"Qtde Itens"             ,"QTSD1"     , "N", 10, 0, ""})
	AADD(_aCamposBrw, {"Qtde Tit Vinculados"    ,"QTSE2VINC" , "N", 10, 0, ""})
	AADD(_aCamposBrw, {"Qtde Tit Desvinculados" ,"QTSE2DESV" , "N", 10, 0, ""})

	MBrowse(6,1,22,75, (_cAliasTrb), _aCamposBrw, Nil, Nil, Nil, 2)

Return()

Static Function SX3Info(cCampo)

	Local aSX3Info := {}
	Local lExiste  := .F.

	lExiste := !Empty(GetSX3Cache(cCampo, "X3_CAMPO"))

	If (lExiste)
		AADD(aSX3Info, GetSX3Cache(cCampo, "X3_TITULO"))
		AADD(aSX3Info, cCampo)
		AADD(aSX3Info, GetSX3Cache(cCampo, "X3_TIPO"))
		AADD(aSX3Info, GetSX3Cache(cCampo, "X3_TAMANHO"))
		AADD(aSX3Info, GetSX3Cache(cCampo, "X3_DECIMAL"))
		AADD(aSX3Info, GetSX3Cache(cCampo, "X3_PICTURE"))
	EndIf

Return(aSX3Info)

Static Function RefrBrowse()

	Local _oObj := GetObjBrow()

	If (_oObj <> nil)
		_oObj:GoTop()
		_oObj:Refresh()
		_oObj:GoBottom()
	EndIf

Return()

User Function XAG0007C()

	If PergInicial()
		DadosBrowse()
	Else
		CloseBrowse()
	EndIf

Return()
