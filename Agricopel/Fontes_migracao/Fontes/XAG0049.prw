#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0049
Sincronizador de registros de produtos com autosystem, sincroniza campo B1_GRUPO
@author Leandro F Silveira
@since 05/03/2019
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0049()
/*/
User Function XAG0049()

	Local _aProdsATS := {}

	Private oXagCon := XagConexao():New()
	Private _aLog49 := {}

	If (PergInicial()) .And. (oXagCon:ConecATS())

		MsgRun("Carregando Grupos do Autosystem", "Aguarde - Processando",{|| _aProdsATS := GetProdATS()})

		If (Len(_aProdsATS) > 0)
            Processa( {|| SincRegs(_aProdsATS)}, "Sincronizando produtos com Autosystem","", .F.)
			MostrarLog("Sincronização concluída!")
        Else
            MsgAlert("Nenhum produto para sincronizar a partir da data do dia retroativo informado!")
		EndIf
	EndIf

Return()

Static Function PergInicial()

	Local aRegistros := {}
	Local cPerg      := "XAG0049"

	AADD(aRegistros,{cPerg,"01","Dias retroativos de alteração","mv_ch1","N",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg, aRegistros)

Return Pergunte(cPerg, .T.)

Static Function GetProdATS()

	Local aRegs     := {}
	Local cSQL      := ""
	Local cAliasATS := GetNextAlias()

	cSQL += " select "
	cSQL += "    produto.codigo::varchar(8) as B1_CODTKE, "
	cSQL += "    CONCAT(grupo.codigo, '-', subgrupo.codigo)::varchar(100) as BM_XCODOBC "
	cSQL += " from produto "

	cSQL += " join grupo_produto grupo on grupo.grid = produto.grupo "
	cSQL += " join subgrupo_produto subgrupo on subgrupo.grid = produto.subgrupo "

	If (MV_PAR01 > 0)
		cSQL += " where exists (select grid "
		cSQL += "               from produto_flow flow "
		cSQL += "               where produto.grid = flow.grid "
		cSQL += "               and flow.pgd_when >= (current_date - " + cValToChar(MV_PAR01) + "))"
	EndIf

	cSQL += " order by produto.codigo "

	TCQuery cSQL NEW ALIAS (cAliasATS)

	While (!(cAliasATS)->(Eof()))

		aAdd(aRegs, {(cAliasATS)->B1_CODTKE, (cAliasATS)->BM_XCODOBC})

		(cAliasATS)->(DbSkip())
	End

	(cAliasATS)->(DbCloseArea())
	oXagCon:DescATS()

Return(aRegs)

Static Function SincRegs(_aProdsATS)

    Local nTotalReg := Len(_aProdsATS)
    Local nX        := 0

    ProcRegua(nTotalReg)

    For nX := 1 To nTotalReg
        SincSB1(_aProdsATS[nX])
        IncProc("Processando: " + cValToChar(nX) + "/" + cValToChar(nTotalReg))
    End

Return()

Static Function SincSB1(aProdATS)

	Local cB1_CODTKE  := aProdATS[1]
	Local cBM_XCODOBC := aProdATS[2]
	Local cB1_GRUPO   := ""
	Local cBM_GRUPO   := ""
	Local cAliasSB1   := ""

	cAliasSB1 := GetSB1(cB1_CODTKE)

	While !(cAliasSB1)->(Eof())

		If (AllTrim((cAliasSB1)->BM_XCODOBC) <> AllTrim(cBM_XCODOBC))

			cBM_GRUPO := GetCodSBM((cAliasSB1)->B1_FILIAL, cBM_XCODOBC)

			If (!Empty(cBM_GRUPO))
				UpdSB1((cAliasSB1)->R_E_C_N_O_, cBM_GRUPO, (cAliasSB1)->B1_FILIAL, (cAliasSB1)->B1_COD, cBM_XCODOBC)
			Else
				AddLog((cAliasSB1)->B1_FILIAL, (cAliasSB1)->B1_COD, cBM_XCODOBC, "Grupo não encontrado")
			EndIf
		EndIf

		(cAliasSB1)->(DbSkip())
	End

	(cAliasSB1)->(DbCloseArea())

Return()

Static Function GetSB1(cB1_CODTKE)

	Local cSQL      := ""
	Local cAliasSB1 := GetNextAlias()

	cSQL += " SELECT "
	cSQL += "    SB1.R_E_C_N_O_, "
	cSQL += "    SB1.B1_FILIAL, "
	cSQL += "    SB1.B1_COD, "
	cSQL += "    SBM.BM_XCODOBC "
	cSQL += " FROM " + RetSqlName("SB1") + " SB1 (NOLOCK) "
	cSQL += "    LEFT JOIN " + RetSqlName("SBM") + " SBM (NOLOCK) ON (SBM.BM_GRUPO = SB1.B1_GRUPO "
	cSQL += "                                                     AND SBM.BM_FILIAL IN (SB1.B1_FILIAL, '') "
	cSQL += "                                                     AND SBM.D_E_L_E_T_ = '') "
	cSQL += " WHERE SB1.B1_CODTKE = '" + AllTrim(cB1_CODTKE) + "'"
	cSQL += " AND   SB1.D_E_L_E_T_ = '' "

	TCQuery cSQL NEW ALIAS (cAliasSB1)

	TCSetField((cAliasSB1), "R_E_C_N_O_" , "N", 18, 0)

Return(cAliasSB1)

Static Function UpdSB1(_nRecNo, cBM_GRUPO, cB1_FILIAL, cB1_COD, cBM_XCODOBC)

	Local cSQL := ""

	cSQL += " UPDATE " + RetSqlName("SB1") + " SET "
	cSQL += "    B1_GRUPO = '" + cBM_GRUPO + "'"
	cSQL += " WHERE R_E_C_N_O_ = " + cValToChar(_nRecNo)

	If (TCSQLExec(cSQL) >= 0)
		AddLog(cB1_FILIAL, cB1_COD, cBM_XCODOBC, "Atualizado")
	Else
		AddLog(cB1_FILIAL, cB1_COD, cBM_XCODOBC, "Erro: " + TCSQLError())
	EndIf

Return()

Static Function GetCodSBM(cB1_FILIAL, cBM_XCODOBC)

	Local cBM_GRUPO := ""
	Local cSQL      := ""
	Local cAliasSBM := GetNextAlias()

	cSQL += " SELECT SBM.BM_GRUPO "
	cSQL += " FROM " + RetSqlName("SBM") + " SBM (NOLOCK) "
	cSQL += " WHERE SBM.BM_XCODOBC = '" + AllTrim(cBM_XCODOBC) + "'"
	cSQL += " AND   SBM.BM_FILIAL IN ('', '" + AllTrim(cB1_FILIAL) + "')"
	cSQL += " AND   SBM.D_E_L_E_T_ = '' "

	TCQuery cSQL NEW ALIAS (cAliasSBM)

	cBM_GRUPO := (cAliasSBM)->BM_GRUPO
	(cAliasSBM)->(DbCloseArea())

Return(cBM_GRUPO)

Static Function AddLog(cB1_FILIAL, cB1_COD, cBM_XCODOBC, cMsg)

	Local nX      := 0
	Local cMsgLog := "Prod: " + AllTrim(cB1_FILIAL) + "-" + AllTrim(cB1_COD) + " / Grupo: " + AllTrim(cBM_XCODOBC) + " - " + cMsg

	aAdd(_aLog49, cMsgLog)

Return()

Static Function MostrarLog(cTitulo)

	Local oDlgMemo   := Nil
	Local oButton1   := Nil
	Local oMultiGet1 := Nil
	Local cLogRepl   := ""
	Local nX         := 0

	bError := ErrorBlock({|oError| MsgAlert("Log excedeu o limite de tamanho e não será mostrado por inteiro! Erro:" + oError:Description) })
	BEGIN SEQUENCE
		For nX := 1 to Len(_aLog49)
			cLogRepl += _aLog49[nX] + CRLF
		End
	END SEQUENCE
	ErrorBlock(bError)

	DEFINE MSDIALOG oDlgMemo TITLE cTitulo FROM 000, 000  TO 555, 650 COLORS 0, 16777215 PIXEL

	@ 005, 005 GET oMultiGet1 VAR cLogRepl OF oDlgMemo MULTILINE SIZE 315, 250 COLORS 0, 16777215 READONLY HSCROLL PIXEL
	@ 260, 280 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgMemo PIXEL Action(lRetMemo := .T. , oDlgMemo:End() )

	ACTIVATE MSDIALOG oDlgMemo CENTERED

Return Nil