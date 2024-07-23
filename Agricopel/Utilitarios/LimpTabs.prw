#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function LimpTabs()

	Local cEmpresa  := ""
	Local aEmpresas := {}
	Local nContEmp  := 0

	RPCSetType(3)
	RPCSetEnv("01", "01")

	aEmpresas := GetEmpr()

	For nContEmp := 1 to Len(aEmpresas)

		cEmpresa := aEmpresas[nContEmp] + "0"
		Conout(Time() + " - " + DtoC(Date()) + " - INICIO EMPRESA - " + cValToChar(nContEmp) + "/" + cValToChar(Len(aEmpresas)) + " - " + cEmpresa)

		LimpArray(cEmpresa)
		LimpCTK(cEmpresa)
		LimpCV3(cEmpresa)
		LimpCSs(cEmpresa)

		Conout(Time() + " - " + DtoC(Date()) + " - FIM EMPRESA - " + cValToChar(nContEmp) + "/" + cValToChar(Len(aEmpresas)) + " - " + cEmpresa)

	Next nContEmp

	RpcClearEnv()

	Conout("FIM PROCESSO DE LIMPEZA DAS TABELAS")
	Conout(Replicate("-", 30))
Return()

Static Function GetEmpr()

	Local aEmpresa := {}
	Local aAreaSM0 := SM0->(GetArea())
	Local cEmpresa := ""

	SM0->(DbGoTop())
	While SM0->(!EOF())

		cEmpresa := SM0->M0_CODIGO

		If (!SM0->(Deleted()) .And. AScan(aEmpresa, cEmpresa) = 0)
			Aadd(aEmpresa, cEmpresa)
		EndIf

		SM0->(DbSkip())
	EndDo

	RestArea(aAreaSM0)

Return(aEmpresa)

Static Function LimpArray(cEmpresa)

	Local cTabela  := ""
	Local nContTab := 0

	Local aTabelas := { "SF3", "WF6", "CTV", "TRB", "AD7", ;
	"SFT", "CT2", "CSB", "CTK", "CV3", "SBK", "ZZ8", ;
	"CD2", "SD5", "SE3", "SEA", "WFA", "SC7", "SDA", ;
	"SD3", "SUB", "SBJ", "SC9", "SD1", "CTF",        ;
	"CTC", "SC6", "SUA", "SEF", "DCR", "SA7", "SZC", ;
	"SN4", "CDH", "CS4", "SE5", "SYP", "SF1",        ;
	"DCF", "SB9", "SDC", "SE1", "SL4", "CT4", "WF3", ;
	"SCY", "CVX", "CT7", "SU6", "SU4", "CS3", "SDB", ;
	"CVY", "CV8", "SD4", "SCR", "CTU", "DT6", "FI8"}

	For nContTab := 1 To Len(aTabelas)

		cTabela := aTabelas[nContTab] + cEmpresa

		If (MsFile(cTabela))

			Conout(Replicate("-", 30))
			Conout(Time() + " - " + DtoC(Date()) + " - INICIO TABELA - " + cTabela + " - " + cValToChar(nContTab) + "/" + cValToChar(Len(aTabelas)))

			LimparTab(cTabela, " WHERE D_E_L_E_T_ = '*' ")

			Conout(Time() + " - " + DtoC(Date()) + " - FIM TABELA - " + cTabela + " - " + cValToChar(nContTab) + "/" + cValToChar(Len(aTabelas)))
		Else
			Conout(Time() + " - " + DtoC(Date()) + " - TABELA NÃO EXISTE - " + cValToChar(nContTab) + "/" + cValToChar(Len(aTabelas)) + " - " + cTabela)
		EndIf

	Next nContTab

Return()

Static Function LimpCSs(cEmpresa)

	Local aTabsCS := {}
	Local cNome   := ""
	Local cWhere  := ""
	Local nX      := 0

	aAdd(aTabsCS, {"CSA", " WHERE CSA_DTLANC < '20180101' "})
	aAdd(aTabsCS, {"CSB", " WHERE CSB_DTLANC < '20180101' "})
	aAdd(aTabsCS, {"CSC", " WHERE CSC_DTFIM < '20180101' "})
	aAdd(aTabsCS, {"CSD", " WHERE CSD_DTFIN < '20180101' "})
	aAdd(aTabsCS, {"CSF", " WHERE CSF_DTFIM < '20180101' "})

	For nX := 1 To Len(aTabsCS)

		cNome  := aTabsCS[nX][1] + cEmpresa
		cWhere := aTabsCS[nX][2]

		If (MsFile(cNome))
			Conout(Time() + " - " + DtoC(Date()) + " - INICIO LIMPEZA ANTIGOS - " + cNome)

			LimparTab(cNome, cWhere)

			Conout(Time() + " - " + DtoC(Date()) + " - FIM LIMPEZA ANTIGOS - " + cNome)
			Conout(Replicate("-", 30))
		Else
			Conout(Time() + " - " + DtoC(Date()) + " - TABELA NÃO EXISTE P/ LIMPEZA ANTIGOS - " + cNome)
		EndIf

	Next nX

Return()

Static Function LimpCTK(cEmpresa)

	Local cTabCTK := "CTK" + cEmpresa

	If (MsFile(cTabCTK))
		Conout(Time() + " - " + DtoC(Date()) + " - INICIO LIMPEZA ANTIGOS - " + cTabCTK)

		LimparTab(cTabCTK, " WHERE CTK_DATA < '20180101' ")

		Conout(Time() + " - " + DtoC(Date()) + " - FIM LIMPEZA ANTIGOS - " + cTabCTK)
		Conout(Replicate("-", 30))
	Else
		Conout(Time() + " - " + DtoC(Date()) + " - TABELA NÃO EXISTE P/ LIMPEZA ANTIGOS - " + cTabCTK)
	EndIf

Return()

Static Function LimpCV3(cEmpresa)

	Local cTabCV3 := "CV3" + cEmpresa

	If (MsFile(cTabCV3))
		Conout(Time() + " - " + DtoC(Date()) + " - INICIO LIMPEZA ANTIGOS - " + cTabCV3)

		LimparTab(cTabCV3, " WHERE CV3_DTSEQ < '20180101' ")

		Conout(Time() + " - " + DtoC(Date()) + " - FIM LIMPEZA ANTIGOS - " + cTabCV3)
		Conout(Replicate("-", 30))
	Else
		Conout(Time() + " - " + DtoC(Date()) + " - TABELA NÃO EXISTE P/ LIMPEZA ANTIGOS - " + cTabCV3)
	EndIf

Return

Static Function LimparTab(cTabela, cWhere)

	Local cQuery     := ""
	Local nRegDel    := 10000 // Registros por delete
	Local nContReg   := 0
	Local nQtdeReg   := 0
	Local nX         := 0

	If (Empty(cWhere))
		Conout("Tentativa de delete sem WHERE - Cancelando - " + cTabela)
		Return()
	EndIf

	nQtdeReg := ContarReg(cTabela, cWhere)

	Conout(Time() + " - " + DtoC(Date()) + " - " + cTabela + " - Total de Registros: " + cValToChar(nQtdeReg))

	If (nQtdeReg > 0)

		cQuery := " DELETE TOP (" + cValToChar(nRegDel) + ")"
		cQuery += " FROM " + cTabela
		cQuery += cWhere

		While (nContReg < nQtdeReg)

			Conout(Time() + " - " + DtoC(Date()) + " - [SQL] - " + cQuery)

			Begin Transaction

				If (TCSQLExec(cQuery) < 0)
					Conout("Falha ao executar SQL: " + cQuery)
					Conout("TCSQLError() - " + TCSQLError())

					DisarmTransaction()
					Break
				EndIf

			End Transaction

			nContReg += nRegDel

			If (nContReg > nQtdeReg)
				nContReg := nQtdeReg
			EndIf

			Conout(Time() + " - " + DtoC(Date()) + " - " + cTabela + " - Deletados : " + cValToChar(nContReg) + "/" + cValToChar(nQtdeReg))
		End
	EndIf

Return

Static Function ContarReg(cTabela, cWhere)

	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local nQtdeReg   := 0

	cQuery := "SELECT COUNT(R_E_C_N_O_) AS QTREG "
	cQuery += "FROM " + cTabela + " WITH (NOLOCK) "
	cQuery += cWhere

	Conout(Time() + " - " + DtoC(Date()) + " - [SQL] - " + cQuery)

	TCQuery cQuery NEW ALIAS (cAliasQry)

	nQtdeReg := (cAliasQry)->(QTREG)
	(cAliasQry)->(dbCloseArea())

Return(nQtdeReg)