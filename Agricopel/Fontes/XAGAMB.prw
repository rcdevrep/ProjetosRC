#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGAMB
Identifica se é o ambiente de produção ou de teste
Retorna 0 se for ambiente de produção, caso contrário retornará 1
@author Leandro F Silveira
@since 20/11/2020
@example u_XAGAMB()
/*/
User Function XAGAMB()

    Local _nRet   := 1
    Local _cNomeDB := ""

    _cNomeDB := GetNomeBD()

   If ( _cNomeDB == "PROTHEUS_PROD")
        _nRet := 0
   Elseif (_cNomeDB == "PROTHEUS_MIGRA")
        _nret := 2
   EndIf

Return(_nRet)

Static Function GetNomeBD()

    Local cChave  := "DBAlias"
    Local cNomeBD := ""

    cNomeBD := AllTrim(GetSrvProfString(cChave, ""))

Return(cNomeBD)
