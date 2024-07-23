#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} CHKEXEC
Ponto de entrada disparado ao executar uma rotina no menu. 
@author Leandro F Silveira
@since 22/08/2019
@return Caso seu retorno seja .F. a rotina não é executada.
/*/
User Function CHKEXEC()

    Local _lRet    := .T. // Sempre retornar .T. se nao a rotina nao sera executada.
    Local _cFuncao := SubStr(ParamIXB,1,At('(',ParamIXB)-1)

    MsgRun("Processando dados","Aguarde",{|| U_XAGLOGRT(_cFuncao, "S") })

Return(_lRet) // Caso retorno seja .F. a rotina não é executada