#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XAGPIALL
Exporta��o de arquivos para Pirelli
Esta rotina efetua execu��o de todas as exporta��es. Ser� acionada pelo Schedule
Documenta��o presente no chamado 446663 do DOX
@author Leandro F Silveira
@since 19/01/2021
@example u_XAGPIALL()
/*/
User Function XAGPIALL(cDirDest, cDiaRetIni, cDiaRetFim)

    Default cDirDest   := "C:\Totvs\arquivospirelli"
    Default cDiaRetIni := "8"
    Default cDiaRetFim := "1"

    Conout("XAGPIALL - cDirDest: " + cDirDest + " - cDiaRetIni: " + cDiaRetIni + " - cDiaRetFim: " + cDiaRetFim)

    RpcSetType(3)
    RPCSetEnv("01","06")

    U_XAGPIPRD(cDirDest)
    U_XAGPICDS(cDirDest)
    U_XAGPIEST(cDirDest)
    U_XAGPIVEN(cDirDest, cDiaRetIni, cDiaRetFim)
    U_XAGPICLI(cDirDest)

    RpcClearEnv()

Return(.T.)
