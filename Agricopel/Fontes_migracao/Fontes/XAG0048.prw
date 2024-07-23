#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0048
Sincronizador de registros de grupos de produtos (SBM) com Autosystem
@author Leandro F Silveira
@since 21/02/2019
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0048()
/*/
User Function XAG0048()

	Local _aRegSBM  := {}
	Local _aEmpRepl := {}

	Private oXagCon := XagConexao():New()
	Private _aLog48 := {}

	If (oXagCon:ConecATS())

		MsgRun("Carregando Grupos do Autosystem", "Aguarde - Processando",{|| _aRegSBM := GetGrupATS()})

		If (Len(_aRegSBM) > 0)
			_aEmpRepl := U_XAGEMP(.F.)

			If (Len(_aEmpRepl) > 0)
				SincSBM(_aRegSBM, _aEmpRepl)
			EndIf
		EndIf
	EndIf

Return()

Static Function GetGrupATS()

	Local aRegs     := {}
	Local aLinha    := {}
	Local cSQL      := ""
	Local cCampo    := ""
	Local cAliasATS := GetNextAlias()
	Local nFCount   := 0
	Local nX        := 0
	Local xValor    := ""

	cSQL += " with grupos_subgrupos_union as ( "
	cSQL += "     select "
	cSQL += "        CONCAT(grupo.codigo, '-', subgrupo.codigo)::varchar(100) as BM_XCODOBC, "
	cSQL += "        subgrupo.nome::varchar(30) as BM_DESC, "
	cSQL += "        grupo.codigo::varchar(100) as BM_XGRUPAI, "
	cSQL += "        subgrupo.flag::varchar(1) AS STATUS, "
	cSQL += "        grupo.codigo::integer as cod_grupo, "
	cSQL += "        subgrupo.codigo::integer as cod_subgrupo "
	cSQL += "     from subgrupo_produto subgrupo, grupo_produto grupo "
	cSQL += "     where subgrupo.grupo = grupo.grid "

	cSQL += "     union all "

	cSQL += "     select "
	cSQL += "        grupo.codigo::varchar(100) as BM_XCODOBC, "
	cSQL += "        grupo.nome::varchar(30) as BM_DESC, "
	cSQL += "        ''::varchar(100) as BM_XGRUPAI, "
	cSQL += "        grupo.flag::varchar(1) AS STATUS, "
	cSQL += "        grupo.codigo::integer as cod_grupo, "
	cSQL += "        0::integer as cod_subgrupo "
	cSQL += "     from grupo_produto grupo "
	cSQL += " ), "

	cSQL += " grupos_subgrupos_rownumber as ( "
	cSQL += "     select "
	cSQL += "        BM_XCODOBC, "
	cSQL += "        BM_DESC, "
	cSQL += "        BM_XGRUPAI, "
	cSQL += "        STATUS, "
	cSQL += "        cod_grupo, "
	cSQL += "        cod_subgrupo, "
	cSQL += "        row_number() over(partition by bm_xcodobc order by status) as rownumber "
	cSQL += "     from grupos_subgrupos_union "
	cSQL += " ) "

	cSQL += " select "
	cSQL += "    BM_XCODOBC, "
	cSQL += "    BM_DESC, "
	cSQL += "    BM_XGRUPAI, "
	cSQL += "    STATUS, "
	cSQL += "    row_number() over(partition by bm_xcodobc order by status) as rownumber "
	cSQL += " from grupos_subgrupos_rownumber "
	cSQL += " where rownumber = 1 "
	cSQL += " order by cod_grupo, cod_subgrupo "

	TCQuery cSQL NEW ALIAS (cAliasATS)

	nFCount := (cAliasATS)->(FCount())

	While (!(cAliasATS)->(Eof()))

		aLinha := {}

		For nX := 1 To nFCount
			cCampo := (cAliasATS)->(FieldName(nX))
			xValor := (cAliasATS)->&(cCampo)

			If (ValType(xValor) == "C")
				xValor := AllTrim(xValor)
			EndIf

			aAdd(aLinha, {cCampo, xValor})
		End

		aAdd(aRegs, aLinha)

		(cAliasATS)->(DbSkip())
	End

	(cAliasATS)->(DbCloseArea())
	oXagCon:DescATS()

Return(aRegs)

Static Function SincSBM(_aRegSBM, _aEmpRepl)

	Local nX       := 0
	Local nCount   := Len(_aEmpRepl)
	Local cCodEmp  := ""
	Local cDescEmp := ""

	For nX := 1 To nCount

		cCodEmp := _aEmpRepl[nX][1]
		cDescEmp := _aEmpRepl[nX][2]

		MsgRun(cValToChar(nX) + "/" + cValToChar(nCount) + " - Empresa: " + cCodEmp + " - " + cDescEmp, ;
		"Sincronizando grupos",{|| ReplEmpre(_aRegSBM, cCodEmp, cDescEmp)})
	End

	MostrarLog("Fim da sincronização!")

Return()

Static Function ReplEmpre(_aRegSBM, cCodEmp, cDescEmp)

	Local aLogRet := {}

	AddLog(Replicate("-", 20))
	AddLog("Empresa: " + cCodEmp + "-" + cDescEmp + IIf(cCodEmp == cEmpAnt, " - (Mesma empresa que a origem)", ""))

	aLogRet := StartJob("U_XAG0048A", GetEnvServer(), .T., _aRegSBM, cCodEmp, cDescEmp)
	AddLog(aLogRet)

Return()

Static Function AddLog(xMsgLog)

	Local nX := 0

	If (ValType(xMsgLog) == "A")
		For nX := 1 To Len(xMsgLog)
			AddLog(xMsgLog[nX])
		End
	Else
		aAdd(_aLog48, xMsgLog)
	EndIf

Return()

Static Function MostrarLog(cTitulo)

	Local oDlgMemo   := Nil
	Local oButton1   := Nil
	Local oMultiGet1 := Nil
	Local cLogRepl   := ""
	Local nX         := 0

	bError := ErrorBlock({|oError| MsgAlert("Log excedeu o limite de tamanho e não será mostrado por inteiro! Erro:" + oError:Description) })
	BEGIN SEQUENCE
		For nX := 1 to Len(_aLog48)
			cLogRepl += _aLog48[nX] + CRLF
		End
	END SEQUENCE
	ErrorBlock(bError)

	DEFINE MSDIALOG oDlgMemo TITLE cTitulo FROM 000, 000  TO 555, 650 COLORS 0, 16777215 PIXEL

	@ 005, 005 GET oMultiGet1 VAR cLogRepl OF oDlgMemo MULTILINE SIZE 315, 250 COLORS 0, 16777215 READONLY HSCROLL PIXEL
	@ 260, 280 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgMemo PIXEL Action(lRetMemo := .T. , oDlgMemo:End() )

	ACTIVATE MSDIALOG oDlgMemo CENTERED

Return Nil