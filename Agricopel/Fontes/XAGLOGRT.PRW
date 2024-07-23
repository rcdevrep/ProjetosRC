#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGLOGRT
Usado para gravar log de uso das rotinas na tabela LOG_USO_ROTIN
@author Leandro F Silveira
@since 22/08/2019
@param cFuncao = Nome da função que esta sendo executada Ex. MATA460 
@return Sempre .T.
/*/
User Function XAGLOGRT(_cFuncao, _cClickMen)

    Local _cQuery      := ""
    Local _cPortaSrv   := GetNumPort()
    Local _cTipo       := IIf(ExistBlock(_cFuncao,,.T.), "C", "P")

    Local _nCodUsr     := 0
    Local _cLoginUsr   := ""
    Local _cNomeUsr    := ""
    Local _cNomePc     := ""

    Default cUserName  := "Sem usuario"
    Default __cUserId  := "XXXXXX"
    Default cEmpAnt    := "XX"
    Default cFilAnt    := "XX"
    Default cModulo    := "XXX"
    Default _cClickMen := "N"

    _nCodUsr   := RetCodUsr()
    _cLoginUsr := UsrRetName(_nCodUsr)
    _cNomeUsr  := UsrFullName(_nCodUsr)
    _cNomePc   := AllTrim(ComputerName()) + " - " + AllTrim(GetComputerName())

    _cQuery += " INSERT INTO LOG_USO_ROTINA ( "
    _cQuery += "    FILIAL, "
    _cQuery += "    EMPRESA, "
    _cQuery += "    TIPO, "
    _cQuery += "    CODUSR, "
    _cQuery += "    LOGINUSR, "
    _cQuery += "    NOMEUSR, "
    _cQuery += "    ROTINA, "
    _cQuery += "    AMBIENTE, "
    _cQuery += "    MODULO, "
    _cQuery += "    DATA, "
    _cQuery += "    HORA, "
    _cQuery += "    CLICK_MENU, "
    _cQuery += "    PORTA_APPSERVER, "
    _cQuery += "    NOMEPC) "
    _cQuery += " VALUES ( "
    _cQuery += "    '" + cFilAnt + "', " // FILIAL
    _cQuery += "    '" + cEmpAnt + "', " // EMPRESA
    _cQuery += "    '" + _cTipo + "', " // TIPO
    _cQuery += "    '" + _nCodUsr + "', " // CODUSR
    _cQuery += "    '" + _cLoginUsr + "', " // LOGINUSR
    _cQuery += "    '" + _cNomeUsr + "', " // NOMEUSR
    _cQuery += "    '" + Upper(_cFuncao) + "', " // ROTINA
    _cQuery += "    '" + GetEnvServer() + "', " // AMBIENTE
    _cQuery += "    '" + cModulo + "', " // MODULO
    _cQuery += "    '" + DtoS(Date()) + "', " // DATA
    _cQuery += "    '" + Time() + "', " // HORA
    _cQuery += "    '" + _cClickMen + "', " // CLICK_MENU
    _cQuery += "    '" + _cPortaSrv + "', " // PORTA_APPSERVER
    _cQuery += "    '" + _cNomePc + "' " // NOMEPC
    _cQuery += " ) "

	If (TCSQLExec(_cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

Return()

Static Function GetNumPort()

    Local cServerIni := GetAdv97()
    Local cSecao     := "TCP"
    Local cChave     := "Port
    Local nPadrao    := 0

    Local cPortaIni := ""

    cPortaIni := GetPvProfileInt(cSecao, cChave, nPadrao, cServerIni)
    cPortaIni := NToC(cPortaIni, 10)

Return(cPortaIni)
