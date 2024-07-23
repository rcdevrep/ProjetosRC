#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function AGRUPDAT()

	Local cEmpresa  := ""
	Local aEmpresas := {}
	Local nContEmp  := 0

	aEmpresas := GetEmpr()

    Conout("INICIO PROCESSAMENTO - AGRUPD")

	For nContEmp := 1 to Len(aEmpresas)

		cEmpresa := aEmpresas[nContEmp]
		Conout(Time() + " - " + DtoC(Date()) + " - INICIO EMPRESA - " + cValToChar(nContEmp) + "/" + cValToChar(Len(aEmpresas)) + " - " + cEmpresa)

        RPCSetType(3)
        RPCSetEnv(cEmpresa, "01")

        DoUpd()

	    RpcClearEnv()

		Conout(Time() + " - " + DtoC(Date()) + " - FIM EMPRESA - " + cValToChar(nContEmp) + "/" + cValToChar(Len(aEmpresas)) + " - " + cEmpresa)

	Next nContEmp

	Conout("FIM PROCESSAMENTO")
	Conout(Replicate("-", 30))

Return()

Static Function GetEmpr()

	Local aEmpresa := {}
	Local cEmpresa := ""

    OpenSM0()

	SM0->(DbGoTop())
	While SM0->(!EOF())

		cEmpresa := SM0->M0_CODIGO

		If (!SM0->(Deleted()) .And. AScan(aEmpresa, cEmpresa) = 0)
			Aadd(aEmpresa, cEmpresa)
		EndIf

		SM0->(DbSkip())
	EndDo

	DbCloseAll()

Return(aEmpresa)

Static Function DoUpd()

	Local cCodSA2 := SA2NovoCod()

	Conout("Emp: " + cEmpAnt + " / Filial: " + cFilAnt + " / Código: " + cCodSA2)

Return()

Static Function SA2NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("A2_COD"))
		cX3_Relacao := SX3->X3_RELACAO
	Endif

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA2", "A2_COD")
		EndIf

		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
		lJaExiste := SA2->(DbSeek(xFilial("SA2")+cCodNovo))
	End

Return(cCodNovo)