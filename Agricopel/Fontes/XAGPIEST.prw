#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XAGPIEST
Exportação de arquivos para Pirelli
Esta rotina efetua a exportação do arquivo de Posição de estoques
Documentação presente no chamado 446663 do DOX
@author Leandro F Silveira
@since 19/01/2021
@example u_XAGPIEST()
/*/
User Function XAGPIEST(cDirDest)

    Local cNomeArq := ""

    cNomeArq := "ACC_POSESTQ_" + DTOS(DATE())

    U_XAGPIARQ(cDirDest, cNomeArq, GetSql(), MontaCab())

Return(.T.)

Static Function GetSql()

    Local _cQuery := ""

    _cQuery += " WITH PROD_EST AS ( "
    _cQuery += " SELECT "
    _cQuery += "    'V' AS TIPO, " // 1: Tipo de registro - Fixo: V
    _cQuery += " '" + SM0->M0_CGC + "' AS CODCD, " // 2: Código do CD/Loja
    _cQuery += "   SA2.A2_CGC, " // 3: Código do Fornecedor

    _cQuery += "   COALESCE( "
    _cQuery += "      (SELECT TOP 1 SA5.A5_CODPRF "
    _cQuery += "       FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += " 	   WHERE SA5.A5_FORNECE = SA2.A2_COD "
    _cQuery += " 	   AND   SA5.A5_LOJA = SA2.A2_LOJA "
    _cQuery += " 	   AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += " 	   AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += " 	   AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "'), "
    _cQuery += "      (SELECT TOP 1 SA5.A5_CODPRF "
    _cQuery += "       FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += " 	   WHERE SA5.A5_FORNECE = SA2.A2_COD "
    _cQuery += " 	   AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += " 	   AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += " 	   AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += "   , '') AS NUMIP, " //4: Número do IP (IP = Interno Pirelli)

    _cQuery += "   '' AS NUMLOTE, " // 5: Número do Lote
    _cQuery += "   '' AS VALLOTE, " // 6: Data de Validade do Lote

    _cQuery += "    COALESCE((SELECT SUM(B2_QATU) "
    _cQuery += "              FROM " + RetSqlName("SB2") + " SB2 WITH (NOLOCK) "
    _cQuery += "              WHERE SB1.B1_COD = SB2.B2_COD "
    _cQuery += "              AND   SB2.B2_FILIAL = '" + FwFilial("SB2") + "' "
    _cQuery += "              AND   SB2.B2_QATU > 0 "
    _cQuery += "              AND   SB2.D_E_L_E_T_ = '') "
    _cQuery += "    , 0) * 1000 AS QTDEST, " // 7: Quantidade em estoque - Deve ser multiplicado por 1.000 (mil).

    _cQuery += "    'H' AS TPEST, " // 8: Tipo de estoque - H – Estoque IN HOUSE (estoque disponível existente no armazém)
    _cQuery += "'" + DTOS(DATE()) + "' AS DTEST " // 9: Data do estoque

    _cQuery += " FROM " + RetSqlName("SB1") + " SB1 WITH (NOLOCK), " + RetSqlName("SA2") + " SA2 WITH (NOLOCK) "

    _cQuery += " WHERE SB1.B1_PROC = '014075' "
    _cQuery += " AND   SB1.B1_PROC = SA2.A2_COD "
    _cQuery += " AND   SB1.B1_LOJPROC = SA2.A2_LOJA "
    _cQuery += " AND   SB1.B1_FILIAL = '" + FwFilial("SB1") + "' "
    _cQuery += " AND   SA2.A2_FILIAL = '" + FwFilial("SA2") + "' "
    _cQuery += " AND   SA2.D_E_L_E_T_ = '' "
    _cQuery += " AND   SB1.D_E_L_E_T_ = '' "
    _cQuery += " AND   SB1.B1_COD NOT IN ('PLLPB', 'PLLIPB') "

    _cQuery += " AND NOT EXISTS ( "
    _cQuery += "       (SELECT A5_CODPRF "
    _cQuery += "        FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += " 	    WHERE SA5.A5_FORNECE = SA2.A2_COD "
    _cQuery += " 	    AND   SA5.A5_LOJA = SA2.A2_LOJA "
    _cQuery += " 	    AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += " 	    AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += "        AND   A5_CODPRF = 'INATIVAR' "
    _cQuery += " 	    AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += " ) "

    _cQuery += " AND NOT EXISTS ( "
    _cQuery += "       (SELECT TOP 1 A5_CODPRF "
    _cQuery += "        FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += " 	    WHERE SA5.A5_FORNECE = SA2.A2_COD "
    _cQuery += " 	    AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += " 	    AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += "        AND   A5_CODPRF = 'INATIVAR' "
    _cQuery += " 	    AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += " ) "

    _cQuery += " ) "

    _cQuery += " SELECT  "
    _cQuery += "    TIPO,  "
    _cQuery += "    CODCD,  "
    _cQuery += "    A2_CGC,  "
    _cQuery += "    NUMIP,  "
    _cQuery += "    NUMLOTE,  "
    _cQuery += "    VALLOTE,  "
    _cQuery += "    SUM(QTDEST) AS QTDEST,  "
    _cQuery += "    TPEST,  "
    _cQuery += "    DTEST "
    _cQuery += " FROM PROD_EST "
    _cQuery += " GROUP BY TIPO, CODCD, A2_CGC, NUMIP, NUMLOTE, VALLOTE, TPEST, DTEST "

Return(_cQuery)

Static Function MontaCab()

    Local _cCabec := ""

    _cCabec += "H" //1: Tipo de registro - Fixo: H
    _cCabec += ";"
    _cCabec += SM0->M0_CGC //2: Código da Revenda
    _cCabec += ";"
    _cCabec += DTOS(DATE()) //3: Data inicial dos registros
    _cCabec += ";"
    _cCabec += DTOS(DATE()) //4: Data final dos registros

Return(_cCabec)
