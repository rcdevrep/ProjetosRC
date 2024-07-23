#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGPIARQ
Exportação de arquivos para Pirelli
Esta rotina recebe o alias do SQL e o utiliza para escrever o arquivo
Documentação presente no chamado 446663 do DOX
@author Leandro F Silveira
@since 19/01/2021
@example u_XAGPIARQ()
/*/
User Function XAGPIARQ(cDirDest, _cNomeArq, _cQuery, _cCabec)

	Local _oFile   := Nil
	Local cDestArq := ""
	Local _cAlias  := ""

	cDestArq := cDirDest + "\" + _cNomeArq + ".txt"

	_cAlias := MpSysOpenQuery(_cQuery)
	_oFile  := FWFileWriter():New(cDestArq, .T.)

    _oFile:SetCaseSensitive(.T.)
    _oFile:CreateDirectory()
	_oFile:Erase()

    If (_oFile:Create())
        _oFile:Write(_cCabec)
        EscrDados(_oFile, _cAlias)
        _oFile:Write(CRLF + "E")
    Else
        Error()
    EndIf

	_oFile:Close()
	(_cAlias)->(DbCloseArea())

Return(.T.)

Static Function EscrDados(_oFile, _cAlias)

	Local cLinha     := ""
	Local cValor     := ""
	Local nQtdCampo  := (_cAlias)->(FCount())
	Local nCount     := 0

	While (!(_cAlias)->(Eof()))

		cValor := (_cAlias)->(FieldGet(1))
		cLinha += cValToChar(cValor)

		For nCount := 2 To nQtdCampo
			cValor := (_cAlias)->(FieldGet(nCount))
			cLinha += ";" + AllTrim(cValToChar(cValor))
		End

		_oFile:Write(CRLF + cLinha)
		cLinha := ""

		(_cAlias)->(DbSkip())
	End

Return()
