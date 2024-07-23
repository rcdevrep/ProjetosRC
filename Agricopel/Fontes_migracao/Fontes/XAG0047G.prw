#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047G
Replicador de registros de tabelas entre empresas
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0047G()

// ArrTokStr()

/*/
User Function XAG0047G(cTabRepl, aRegsRepl, cCodEmp, _IdUsr)

	Local nX          := 0
	Local aRegRepl    := {}

	Private aLogRepl  := {}

	bError := ErrorBlock({|oError|LogErroIni(oError)})
	BEGIN SEQUENCE

		RpcSetType(3)
		RPCSetEnv(cCodEmp,"01","","","","",{cTabRepl})

		__cUserID := _IdUsr

		If (IsEmpty(xFilial(cTabRepl)))
			AddLog("Tabela compartilhada entre filiais")
			ExecRepl(cTabRepl, aRegsRepl)
		Else
			AddLog("Tabela exclusiva entre filiais")
			While (!SM0->(Eof()) .And. SM0->M0_CODIGO == cCodEmp)
				cFilAnt := SM0->M0_CODFIL
				ExecRepl(cTabRepl, aRegsRepl)

				SM0->(DbSkip())
			End
		EndIf

		RpcClearEnv()

	END SEQUENCE
	ErrorBlock(bError)

Return(aLogRepl)

Static Function ExecRepl(cTabRepl, aRegsRepl)

	Local nX       := 0
	Local aRegRepl := {}
	Local cValIdx1 := ""

	For nX := 1 To Len(aRegsRepl)

		bError := ErrorBlock({|oError|LogErroIns(oError, cValIdx1)})
		BEGIN SEQUENCE

			aRegRepl  := aRegsRepl[nX]
			cValIdx1  := GetValIdx1(cTabRepl, aRegRepl)

			If !((cTabRepl)->(DbSeek(cValIdx1)))
				Inserir(cTabRepl, aRegRepl)
				AddLog("Registro: " + AllTrim(cValIdx1) + " - Inserido!")
			Else
				AddLog("Registro: " + AllTrim(cValIdx1) + " - Já existente!")
			EndIf

		END SEQUENCE
		ErrorBlock(bError)
	End

Return()

Static Function Inserir(cTabRepl, aRegRepl)

	Local nX     := 0
	Local nTotal := 0
	Local aCampo := {}
	Local cCampo := ""

	nTotal := Len(aRegRepl)

	RecLock((cTabRepl), .T.)

	For nX := 1 To nTotal
		aCampo := aRegRepl[nX]
		cCampo := aCampo[1]

		If ('_FILIAL' $ cCampo)
			(cTabRepl)->&(cCampo) := xFilial(cTabRepl)
		Else
			If ("USERLGI" $ cCampo) .Or. ("USERGI" $ cCampo)
				//(cTabRepl)->&(cCampo) := _DescUsr
			Else
				If ((cTabRepl)->(FieldPos(cCampo)) > 0) .And. !("USERLGA" $ cCampo) .And. !("USERGA" $ cCampo)
					(cTabRepl)->&(cCampo) := aCampo[2]
				End
			End
		EndIf
	End

	MsUnlock((cTabRepl))

Return()

Static Function GetValIdx1(cTabRepl, aRegRepl)

	Local cRet       := ""
	Local cDescIdx   := ""
	Local cCampoIdx  := ""
	Local nX         := 0
	Local nPosCampo  := 0
	Local aCamposIdx := {}
	Local aCampo     := {}

	cDescIdx   := (cTabRepl)->(IndexKey(1))
	aCamposIdx := Separa(cDescIdx,"+",.T.)

	For nX := 1 To Len(aCamposIdx)
		cCampoIdx := aCamposIdx[nX]

		If !("FILIAL" $ cCampoIdx)
			nPosCampo := aScan(aRegRepl, {|x| x[1] == cCampoIdx})
			cRet += aRegRepl[nPosCampo][2]
		EndIf
	End

	cRet := xFilial(cTabRepl) + cRet

Return(cRet)

Static Function AddLog(cMsgLog)
	aAdd(aLogRepl, cMsgLog)
Return()

Static Function LogErroIns(oError, cValIdx1)

	AddLog("Registro: " + AllTrim(cValIdx1) + " - ERRO AO INSERIR!")
	AddLog(Replicate("-", 10) + " INÍCIO DO ERRO " + Replicate("-", 10))
	AddLog(AllTrim(oError:Description))
	// AddLog("Stack: " + AllTrim(oError:ERRORSTACK))
	AddLog(Replicate("-", 10) + " FIM DO ERRO " + Replicate("-", 10))

	Break

Return Nil

Static Function LogErroIni(oError)

	AddLog("ERRO AO INICIAR PROCESSO NA EMPRESA")
	AddLog(Replicate("-", 10) + " INÍCIO DO ERRO " + Replicate("-", 10))
	AddLog(AllTrim(oError:Description))
	// AddLog("Stack: " + AllTrim(oError:ERRORSTACK))
	AddLog(Replicate("-", 10) + " FIM DO ERRO " + Replicate("-", 10))

	Break

Return Nil