#Include 'Protheus.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGDELME
Rotina que serve para testes diversos, deve ser mantida em branco para ser alterada nos testes e em seguida desfazer as alterações (não comitar)
@author Leandro F Silveira
@since 04/09/2019
@version 1.0
/*/
User Function XAGDELME(cTab)

    Default cTab := ""

    If (Empty(cTab))
        cTab := CriaTab()
        SelectTab(cTab)
    Else
        SelectTab(cTab)
    EndIf

Return

Static Function SelectTab(cTab)

    Local cQuery    := ""
    Local cAliasQry := ""
    Local cLinha    := ""
    Local nX        := 0

    cQuery := " SELECT * FROM  " + cTab

    cAliasQry := MPSysOpenQuery(cQuery)

    DbSelectArea(cAliasQry)
    While !Eof()
        cLinha := ""
        For nX := 0 To FCount()
            cLinha += FieldName(nX) + ":" + cValToChar(FieldGet(nX)) + CRLF
        Next nX

        MsgInfo(cTab + CRLF + CRLF + cLinha)
        DbSkip()
    EndDo

    (cAliasQry)->(DbCloseArea())
Return()

Static Function CriaTab()

    Local aFields := {}
    Local oTable  := Nil
    Local cAlias  := ""

    oTable := FWTemporaryTable():New("TRETA")

    aAdd(aFields,{"DESCR","C",30,0})
    aAdd(aFields,{"CONTR","N",3,1})
    aAdd(aFields,{"ALIAS","C",3,0})

    oTable:SetFields( aFields )
    oTable:AddIndex("idx1", {"DESCR"} )

    oTable:Create()

    cAlias := oTable:GetAlias()

    RecLock(cAlias, .T.)
    (cAlias)->DESCR := "DESCRICAO 1"
    (cAlias)->CONTR := 1
    (cAlias)->ALIAS := "alias 1"
    MsUnlock(cAlias)

    RecLock(cAlias, .T.)
    (cAlias)->DESCR := "DESCRICAO 2"
    (cAlias)->CONTR := 2
    (cAlias)->ALIAS := "alias 2"
    MsUnlock(cAlias)

Return(oTable:GetRealName())