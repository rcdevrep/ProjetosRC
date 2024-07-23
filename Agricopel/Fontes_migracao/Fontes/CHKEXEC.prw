#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} CHKEXEC
Ponto de entrada disparado ao executar uma rotina no menu. 
Usado para gravar log de uso das rotinas.
@author Leandro F Silveira
@since 22/08/2019
@param cFuncao = Nome da função que esta sendo executada Ex. MATA460 
@return Caso seu retorno seja F a rotina não é executada.
/*/
User Function CHKEXEC()

    Local _lRet := .T. // Sempre retornar .T. se nao a rotina nao sera executada.

    MsgRun("Processando dados","Aguarde",{|| GravarLog() })

Return(_lRet) // Se retorno nao for .T., nao ira executar a rotina

Static Function GravarLog()

    Local _cFuncao := SubStr(ParamIXB,1,At('(',ParamIXB)-1)
    Local _cTipo   := "P" // Padrao

    If ExistBlock(_cFuncao,,.T.)
        _cTipo := "C" // Customizado
    EndIf

    Inserir(_cTipo, _cFuncao)
                                    
Return()

Static Function Inserir(_cTipo, _cFuncao)

    Local _cQuery    := ""
    Local _cPortaSrv := GetNumPort()

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
    _cQuery += "    PORTA_APPSERVER) "
    _cQuery += " VALUES ( "
    _cQuery += "    '" + cFilAnt + "', " // FILIAL
    _cQuery += "    '" + cEmpAnt + "', " // EMPRESA
    _cQuery += "    '" + _cTipo + "', " // TIPO
    _cQuery += "    '" + RetCodUsr() + "', " // CODUSR
    _cQuery += "    '" + UsrRetName(RetCodUsr()) + "', " // LOGINUSR
    _cQuery += "    '" + UsrFullName(RetCodUsr()) + "', " // NOMEUSR
    _cQuery += "    '" + _cFuncao + "', " // ROTINA
    _cQuery += "    '" + GetEnvServer() + "', " // AMBIENTE
    _cQuery += "    '" + cModulo + "', " // MODULO
    _cQuery += "    '" + DtoS(Date()) + "', " // DATA
    _cQuery += "    '" + Time() + "', " // HORA
    _cQuery += "    '" + _cPortaSrv + "' " // PORTA_APPSERVER
    _cQuery += " ) "

	If (TCSQLExec(_cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

Return()

Static Function GetNumPort()

    Local cServerIni := GetAdv97()
    Local cClientIni := GetRemoteIniName()
    Local cSecao     := "TCP"
    Local cChave     := "Port
    Local nPadrao    := 0

    Local cPortaIni := ""

    cPortaIni := GetPvProfileInt(cSecao, cChave, nPadrao, cServerIni)
    cPortaIni := NToC(cPortaIni, 10)

Return(cPortaIni)