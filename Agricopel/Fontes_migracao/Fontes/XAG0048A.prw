#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0048A
Insere/Atualiza em SBM os registros de Grupo de Produtos do Autosystem recebidos, na empresa do parâmetro
@author Leandro F Silveira
@since 21/02/2019
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0048A()
/*/
User Function XAG0048A(aRegsSBM, cCodEmp, cDescEmp)

	Local nX         := 0
	Private aLogRepl := {}

	bError := ErrorBlock({|oError|LogErro(oError)})
	BEGIN SEQUENCE

		RpcSetType(3)
		RPCSetEnv(cCodEmp,"01","","","","",{"SBM"})

		If (IsEmpty(xFilial("SBM")))
			AddLog("Grupos de produtos compartilhados entre as filiais")
			ExecRepl(aRegsSBM)
		Else
			AddLog("Grupos de produtos exclusivos entre filiais")
			While (!SM0->(Eof()) .And. SM0->M0_CODIGO == cCodEmp)
				cFilAnt := SM0->M0_CODFIL
				ExecRepl(aRegsSBM)

				SM0->(DbSkip())
			End
		EndIf

		RpcClearEnv()

	END SEQUENCE
	ErrorBlock(bError)

Return(aLogRepl)

Static Function ExecRepl(aRegsSBM)

	Local nX         := 0
	Local nPosCodOBC := 0
	Local nPosStatus := 0
	Local nPosDescr  := 0
	Local aLinha     := {}
	Local cCodObc    := ""
	Local cPrefLog   := ""

	cPrefLog := AllTrim(xFilial("SBM"))

	If (!Empty(cPrefLog))
		cPrefLog += "-"
	EndIf

	aLinha := aRegsSBM[1]
	nPosCodOBC := aScan(aLinha, {|Reg| Reg[1] == "BM_XCODOBC"})
	nPosDescr  := aScan(aLinha, {|Reg| Reg[1] == "BM_DESC"})
	nPosStatus := aScan(aLinha, {|Reg| Reg[1] == "STATUS"})

	For nX := 1 To Len(aRegsSBM)

		aLinha  := aRegsSBM[nX]
		cCodObc := aLinha[nPosCodOBC, 2]

		SBM->(DbOrderNickName("IDXOBC"))
		SBM->(DbGoTop())
		If (SBM->(DbSeek(xFilial("SBM")+cCodObc)) .And. AllTrim(SBM->BM_XCODOBC) == AllTrim(cCodObc))

			If (aLinha[nPosStatus][2] <> "D")
				If (SBMAtualiz(aLinha, cCodObc))
					AddLog(cPrefLog + cCodObc + " - " + aLinha[nPosDescr][2] + " - [ATUALIZADO]")
				EndIf
			Else
				SBMDeletar(aLinha)
				AddLog(cPrefLog + cCodObc + " - " + aLinha[nPosDescr][2] + " - [REMOVIDO]")
			EndIf
		Else
			If (aLinha[nPosStatus][2] <> "D")
				SBMInserir(aLinha, cCodObc)
				AddLog(cPrefLog + cCodObc + " - " + aLinha[nPosDescr][2] + " - [INSERIDO]")
			EndIf
		EndIf

	End

Return()

Static Function SBMInserir(aLinha)

	Local cNovoCod  := ""
	Local cCampo    := ""
	Local nY        := 0

	cNovoCod := SBMNovoCod()

	RecLock("SBM", .T.)

	For nY := 1 To Len(aLinha)
		cCampo := aLinha[nY][1]
		If (SBM->(FieldPos(cCampo) > 0))
			SBM->&(cCampo) := aLinha[nY][2]
		EndIf
	End

	SBM->BM_FILIAL := xFilial("SBM")
	SBM->BM_GRUPO  := cNovoCod

	MsUnlock()

	If __lSX8
		ConfirmSX8()
	EndIf

Return()

Static Function SBMAtualiz(aLinha)

	Local cCampo     := ""
	Local nY         := 0
	Local lAtualizou := .F.
	Local xValorSBM  := ""
	Local xValorArr  := ""

	RecLock("SBM", .F.)

	For nY := 1 To Len(aLinha)
		cCampo := aLinha[nY][1]

		If (SBM->(FieldPos(cCampo) > 0))

			xValorArr := AllTrim(aLinha[nY][2])
			xValorSBM := AllTrim(SBM->&(cCampo))

			If (xValorArr <> xValorSBM)
				SBM->&(cCampo) := xValorArr
				lAtualizou := .T.
			EndIf
		EndIf
	End

	MsUnlock()

Return(lAtualizou)

Static Function SBMDeletar(aLinha)

	RecLock("SBM", .F.)
	DbDelete()
	MsUnlock()

Return()

Static Function LogErro(oError)

	AddLog("ERRO AO SINCRONIZAR")
	AddLog(Replicate("-", 10) + " INÍCIO DO ERRO " + Replicate("-", 10))
	AddLog(AllTrim(oError:Description))
	AddLog(Replicate("-", 10) + " FIM DO ERRO " + Replicate("-", 10))

	Break

Return Nil

Static Function AddLog(cMsgLog)
	aAdd(aLogRepl, cMsgLog)
Return()

Static Function SBMNovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("BM_GRUPO"))
		cX3_Relacao := SX3->X3_RELACAO
	Endif

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SBM", "BM_GRUPO")
		EndIf

		SBM->(DbSetOrder(1))
		SBM->(DbGoTop())
		lJaExiste := SBM->(DbSeek(xFilial("SBM")+cCodNovo))
	End

Return(cCodNovo)