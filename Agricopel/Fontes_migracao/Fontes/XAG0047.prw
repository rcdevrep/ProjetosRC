#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0047
Replicador de registros de tabelas entre empresas
@author Leandro F Silveira
@since 30/01/2019
@version 1.0
@return Nil, Função não tem retorno
@example U_XAG0047() 
/*/
User Function XAG0047()

    Local aTabRepl   := {"SF4", "CT1", "CVD", "CTS", "CTT", "SA3", "SED", "SB5","SA6"}
    Local aRetTabRep := {}
    Local cTabRepl   := ""
    Local aRegRepl   := {}
    Local aEmpRepl   := {}

    Private aLog47   := {}

    aRetTabRep := U_XAG0047A(aTabRepl)

    If !Empty(aRetTabRep)
        cTabRepl   := aRetTabRep[1]

        AddLog("Replicando registros de: " + aRetTabRep[1] + " - " + aRetTabRep[2])

        If !Empty(cTabRepl)
            aRegRepl := U_XAG0047C(cTabRepl)

            If (!Empty(aRegRepl))
                aEmpRepl := U_XAG0047E()

                If (!Empty(aEmpRepl))
                    Replicar(cTabRepl, aRegRepl, aEmpRepl)
                EndIf
            EndIf
        EndIf
    EndIf

Return()

Static Function Replicar(cTabRepl, aRegRepl, aEmpRepl)

    Local nX       := 0
    Local nCount   := Len(aEmpRepl)
    Local cCodEmp  := ""
    Local cDescEmp := ""

    For nX := 1 To nCount

        cCodEmp := aEmpRepl[nX][1]
        cDescEmp := aEmpRepl[nX][2]

        MsgRun('Replicando - ' + cValToChar(nX) + "/" + cValToChar(nCount) + ;
                " - Empresa: " + cCodEmp + " - " + cDescEmp, ;
                "Aguarde - Processando",{|| ReplEmpre(cTabRepl, aRegRepl, cCodEmp, cDescEmp)})
    End

    MostrarLog("Fim da replicação!")

Return()

Static Function ReplEmpre(cTabRepl, aRegRepl, cCodEmp, cDescEmp)

    Local aLogRet  := {}

    AddLog(Replicate("-", 20))
    AddLog("Empresa: " + cCodEmp + "-" + cDescEmp + IIf(cCodEmp == cEmpAnt, " - (Mesma empresa que a origem)", ""))

    aLogRet := StartJob("U_XAG0047G", GetEnvServer(), .T., cTabRepl, aRegRepl, cCodEmp, __cUserID)
    AddLog(aLogRet)

Return()

Static Function MostrarLog(cTitulo)

	Local oDlgMemo   := Nil
	Local oButton1   := Nil
	Local oMultiGet1 := Nil
    Local cLogRepl   := ""
    Local nX         := 0

	bError := ErrorBlock({|oError| MsgAlert("Log excedeu o limite de tamanho e não será mostrado por inteiro!") })
	BEGIN SEQUENCE
        For nX := 1 to Len(aLog47)
            cLogRepl += aLog47[nX] + CRLF
        End
	END SEQUENCE
	ErrorBlock(bError)

	DEFINE MSDIALOG oDlgMemo TITLE cTitulo FROM 000, 000  TO 555, 650 COLORS 0, 16777215 PIXEL

	    @ 005, 005 GET oMultiGet1 VAR cLogRepl OF oDlgMemo MULTILINE SIZE 315, 250 COLORS 0, 16777215 READONLY HSCROLL PIXEL
   		@ 260, 280 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgMemo PIXEL Action(lRetMemo := .T. , oDlgMemo:End() )

	ACTIVATE MSDIALOG oDlgMemo CENTERED

Return Nil

Static Function AddLog(xMsgLog)

    Local nX := 0

    If (ValType(xMsgLog) == "A")
        For nX := 1 To Len(xMsgLog)
            AddLog(xMsgLog[nX])
        End
    Else
        aAdd(aLog47, xMsgLog)
    EndIf

Return()