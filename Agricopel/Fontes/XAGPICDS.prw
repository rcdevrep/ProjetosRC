#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XAGPICDS
Exporta��o de arquivos para Pirelli
Esta rotina efetua a exporta��o do arquivo de CDs/Lojas
Documenta��o presente no chamado 446663 do DOX
@author Leandro F Silveira
@since 19/01/2021
@example u_XAGPICDS()
/*/
User Function XAGPICDS(cDirDest)

    Local cNomeArq := ""

    cNomeArq := "ACC_CADSITE_" + DTOS(DATE())

    U_XAGPIARQ(cDirDest, cNomeArq, GetSql(), MontaCab())

Return(.T.)

Static Function GetSql()

    Local _cQuery := ""

    _cQuery += " SELECT "
    _cQuery += "    'V' AS TIPO, " // 1: Tipo de registro - Fixo: V
    _cQuery += "    EMP_CNPJ, " // 2: C�digo do CD/Loja
    _cQuery += "    EMP_RAZAO, " // 3: Descri��o do CD/Loja
    _cQuery += "    EMP_ESTADO, " // 4: UF do CD/Loja
    _cQuery += "    EMP_CIDADE, " // 5: Cidade do CD/Loja
    _cQuery += "    EMP_BAIRRO, " // 6: Bairro/Regi�o do CD/Loja
    _cQuery += "    EMP_CEP, " // 7: CEP do CD/Loja
    _cQuery += "    'A' AS STATUS " // 8: Status do CD/Loja
    _cQuery += " FROM EMPRESAS WITH (NOLOCK) "
    _cQuery += " WHERE EMP_CNPJ = '" + SM0->M0_CGC + "' "

Return(_cQuery)

Static Function MontaCab()

    Local _cCabec := ""

    _cCabec += "H" //1: Tipo de registro - Fixo: H
    _cCabec += ";"
    _cCabec += SM0->M0_CGC //2: C�digo da Revenda
    _cCabec += ";"
    _cCabec += DTOS(DATE()) //3: Data de cria��o do arquivo

Return(_cCabec)
