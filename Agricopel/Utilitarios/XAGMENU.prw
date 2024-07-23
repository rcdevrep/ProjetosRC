#include 'Protheus.ch'
#include 'topconn.ch'
#include "fileio.ch"
 
/*/{Protheus.doc} XAGMENU

@author Leandro F Silveira
@since 24/06/2019
@version 1.0
/*/
User Function XAGMENU()

    Local cRetGet   := ""
    Local oProcess  := Nil
    Local _cDirXnu := "\sigaadv\"
    Local _cArqFim := ""

    Private nHandle := 0

	cRetGet := cGetFile("Arq Menu|*.xnu", "Arquivos de menu", 0, _cDirXnu, .T.,GETF_MULTISELECT+GETF_NOCHANGEDIR,.T.)

    If (!Empty(cRetGet))

        _cArqFim := AllTrim(cGetFile("Arquivos CSV|*.CSV", "Escolha o arquivo para ser gerado", 0,"c:\temp\", .T.,GETF_LOCALHARD,.T.))

        If (!Empty(_cArqFim))

            If (File(_cArqFim))
                FErase(_cArqFim)
            EndIf

            nHandle := FCreate(_cArqFim, FC_NORMAL)

            If (nHandle == -1)
                MsgStop("Erro ao ler/abrir arquivo de saída: " + Str(FError(), 4))
            Else
                oProcess := MsNewProcess():New({|lEnd| ProcMenu(@oProcess, @lEnd, cRetGet) },"Varrendo menus","Processando arquivos de Menu",.T.)
                oProcess:Activate()

                FClose(nHandle)
                MsgInfo("Processamento concluido!")
            EndIf
        EndIf
    EndIf

Return()

Static Function ProcMenu(oProcess, lEnd, cRetGet)

    Local nQtdeXnu   := 0
    Local aArqsXnu   := ""
    Local cArqXnu    := ""
    Local iX         := 0

	Default lEnd     := .F.

    cRetGet  := StrTran(cRetGet, "servidor")
    aArqsXnu := StrToKarr2(cRetGet, " | ")

    FWrite(nHandle, "Caminho;Nome;Tipo;Ultimo Acesso")
    FWrite(nHandle, CRLF)

    nQtdeXnu := Len(aArqsXnu)
    oProcess:SetRegua1(nQtdeXnu)

    For iX := 1 To nQtdeXnu
        cArqXnu := aArqsXnu[iX]

        oProcess:IncRegua1("Processando: (" + cValToChar(iX) + "/" + cValToChar(nQtdeXnu) + ") - " + cArqXnu)
        ProcXnu(oProcess, cArqXnu)

		If lEnd
			Return(.T.)
		EndIf
    End

Return(.T.)

Static Function ProcXnu(oProcess, cArqXnu)

    Local oFileRead  := Nil
    Local aLinhasXnu := {}

    oFileRead := FwFileReader():New(cArqXnu)

    If (oFileRead:Open())
        aLinhasXnu := oFileRead:getAllLines()
        oFileRead:Close()

        ProcLinhas(oProcess, aLinhasXnu, cArqXnu)
    Else
        Alert("Não foi possível abrir o arquivo: " + cArqXnu)
    EndIf

Return()

Static Function ProcLinhas(oProcess, aLinhasXnu, cArqXnu)

    Local cLinha     := ""
    Local cLinhaProx := ""
    Local nQtLinhas  := 0
    Local aMenuDesc  := {}
    Local iX         := 0
    Local cNomeFunc  := ""
    Local cTypeFunc  := ""
    
    nQtLinhas := Len(aLinhasXnu)
    oProcess:SetRegua2(nQtLinhas)

    aAdd(aMenuDesc, cArqXnu)

    For iX := 1 To nQtLinhas
        cLinha := aLinhasXnu[iX]
        cLinha := StrTran(cLinha, "	")
        cLinha := StrTran(cLinha, CRLF)
        cLinha := AllTrim(cLinha)

        cLinhaProx := ""

        oProcess:IncRegua2("Linhas: " + cValToChar(iX) + "/" + cValToChar(nQtLinhas))

		If lEnd
			Return()
		EndIf

        If (At("<FUNCTION>", Upper(cLinha)) > 0)
            cLinhaProx := aLinhasXnu[iX+1]
            cLinhaProx := StrTran(cLinhaProx, "	")
            cLinhaProx := StrTran(cLinhaProx, CRLF)
            cLinhaProx := AllTrim(cLinhaProx)

            cNomeFunc := LinhaFunc(cLinha)
            cTypeFunc := LinhaType(cLinhaProx)

            ProcFunc(aMenuDesc, cNomeFunc, cTypeFunc)
        ElseIf (At("</MENU>", Upper(cLinha)) > 0 .Or. At("</MENUITEM>", Upper(cLinha)) > 0)
            aMenuDesc := aSize(aMenuDesc, Len(aMenuDesc)-1)
        ElseIf (At("<MENU ", Upper(cLinha)) > 0 .Or. At("<MENUITEM ", Upper(cLinha)) > 0)

            cLinhaProx := aLinhasXnu[iX+1]
            cLinhaProx := StrTran(cLinhaProx, "	")
            cLinhaProx := StrTran(cLinhaProx, CRLF)
            cLinhaProx := AllTrim(cLinhaProx)

            aAdd(aMenuDesc, LinhaMenu(cLinhaProx))
        EndIf
    End

Return()

Static Function LinhaFunc(cLinha)

    Local cNomeFunc := ""

    cNomeFunc := StrTran(cLinha, "<Function>")
    cNomeFunc := StrTran(cNomeFunc, "</Function>")
    cNomeFunc := StrTran(cNomeFunc, "&")
    cNomeFunc := StrTran(cNomeFunc, "\t")
    cNomeFunc := AllTrim(cNomeFunc)

Return(cNomeFunc)

Static Function LinhaType(cLinha)

    Local cTypeFunc := ""

    cTypeFunc := StrTran(cLinha, "<Type>")
    cTypeFunc := StrTran(cTypeFunc, "</Type>")
    cTypeFunc := AllTrim(cTypeFunc)

Return(cTypeFunc)

Static Function LinhaMenu(cLinha)

    Local cMenuFunc := ""

    cMenuFunc := StrTran(cLinha, '<Title lang="pt">')
    cMenuFunc := StrTran(cMenuFunc, "</Title>")
    cMenuFunc := StrTran(cMenuFunc, "&")
    cMenuFunc := StrTran(cMenuFunc, "\t")
    cMenuFunc := AllTrim(cMenuFunc)

Return(cMenuFunc)

Static Function ProcFunc(aMenuDesc, cNomeFunc, cTypeFunc)

    Local iX := 0
    Local cMenuDesc := ""
    Local cLogRot   := ""

    For iX := 1 To Len(aMenuDesc)
        cMenuDesc += aMenuDesc[iX] + "/"
    End

    cLogRot := GetLogRot(cNomeFunc)

    AddFunc(cMenuDesc, cTypeFunc, cNomeFunc, cLogRot)

Return()

Static Function AddFunc(cMenuDesc, cTypeFunc, cNomeFunc, cLogRot)

    FWrite(nHandle, cMenuDesc+";"+cNomeFunc+";"+cTypeFunc+";"+cLogRot)
    FWrite(nHandle, CRLF)

Return()

Static Function GetLogRot(cNomeFunc)

    Local _cQuery    := ""
    Local _cAliasQry := ""
    Local _cLogRot   := ""

    _cQuery += " SELECT TOP 1 "
    _cQuery += "    DATA + '-' + HORA + ' - ' + NOMEUSR AS ULTIMO_ACESSO "
    _cQuery += " FROM LOG_USO_ROTINA "
    _cQuery += " WHERE ROTINA LIKE '%" + cNomeFunc + "%' "
    _cQuery += " ORDER BY DATA DESC, HORA DESC "

    _cAliasQry := MPSysOpenQuery(_cQuery)

    _cLogRot := (_cAliasQry)->ULTIMO_ACESSO

    (_cAliasQry)->(DbCloseArea())

Return(_cLogRot)