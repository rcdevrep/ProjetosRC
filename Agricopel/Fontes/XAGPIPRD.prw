#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XAGPIPRD
Exportação de arquivos para Pirelli
Esta rotina efetua a exportação do arquivo de produtos
Documentação presente no chamado 446663 do DOX
@author Leandro F Silveira
@since 19/01/2021
@example u_XAGPIPRD()
/*/
User Function XAGPIPRD(cDirDest)

    Local cNomeArq := ""

    cNomeArq := "ACC_CADPROD_" + DTOS(DATE())

    U_XAGPIARQ(cDirDest, cNomeArq, GetSql(), MontaCab())

Return(.T.)

Static Function GetSql()

    Local _cQuery := ""

    _cQuery += " WITH MAIN_SQL AS ( "

    _cQuery += " SELECT "
    _cQuery += "    'V' AS TIPO, " // 1: Tipo de registro - Fixo: V
    _cQuery += "    SA2.A2_CGC, " // 2: Código do Fornecedor
    _cQuery += "    SA2.A2_NOME, " // 3: Descrição do Fornecedor 
    _cQuery += "    SB1.B1_COD, " // 4: Código do produto
    _cQuery += "    SB1.B1_DESC, " // 5: Descrição do produto
    _cQuery += "    'NI' AS CDGRUPO, " // 6: Código do grupo do produto
    _cQuery += "    'NÃO INFORMADO' AS DSGRUPO, " // 7: Descrição do produto
    _cQuery += "    '' AS CDFAMILIA, " // 8: Código da família do produto
    _cQuery += "    '' AS DSFAMILIA, " // 9: Descrição da família do produto
    _cQuery += "    '' AS CDSUBFAMI, " //10: Código da subfamília do produto
    _cQuery += "    '' AS DSSUBFAMI, " //11: Descrição da subfamília do produto
    _cQuery += "    'E' AS TPCODBAR, " //12: Tipo do código de barras - Fixo: E (Código EAN)

    _cQuery += "    COALESCE( "
    _cQuery += "       (SELECT TOP 1 A5_CODPRF "
    _cQuery += "        FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += " 	    WHERE SA5.A5_FORNECE = SA2.A2_COD "
    _cQuery += " 	    AND   SA5.A5_LOJA = SA2.A2_LOJA "
    _cQuery += " 	    AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += " 	    AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += " 	    AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "'), "
    _cQuery += "       (SELECT TOP 1 A5_CODPRF "
    _cQuery += "        FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += " 	    WHERE SA5.A5_FORNECE = SA2.A2_COD "
    _cQuery += " 	    AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += " 	    AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += " 	    AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += "    , '') AS NUMIP, " //13: Número do IP (IP = Interno Pirelli)

    _cQuery += "    'PEÇA' AS TPEMB, " //14: Tipo da embalagem de venda - Fixo: PEÇA
    _cQuery += "    'UN' AS UNPROD, " //15: Unidade do produto - Fixo: UN
    _cQuery += "    '1000' AS VOLEMB, " //16: Volume da embalagem de venda - Fixo: 1000

    _cQuery += "    CASE WHEN B1_MSBLQL = 2 AND B1_SITUACA = 1 "
    _cQuery += "      THEN 'A' "
    _cQuery += " 	  ELSE 'I' "
    _cQuery += "    END AS STATUSPRD, " //17: Status do produto - A - Ativo / I - Inativo

    _cQuery += "    CASE WHEN SB1.B1_DTCAD <> '' "
    _cQuery += "       THEN SB1.B1_DTCAD "
    _cQuery += " 	  ELSE '20190130' "
    _cQuery += "    END AS B1_DTCAD " //18: Data do cadastro

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
    _cQuery += "   	    AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += " ) "

    _cQuery += " ), "

    _cQuery += " SUB_SQL AS ( "
    _cQuery += " SELECT  "
    _cQuery += " ROW_NUMBER() OVER(PARTITION BY MAIN_SQL.NUMIP ORDER BY MAIN_SQL.B1_COD) AS SEQ, "
    _cQuery += " MAIN_SQL.* "
    _cQuery += " FROM MAIN_SQL) "

    _cQuery += " SELECT " 
    _cQuery += "    TIPO, "
    _cQuery += "    A2_CGC, "
    _cQuery += "    A2_NOME, "
    _cQuery += "    B1_COD, "
    _cQuery += "    B1_DESC, "
    _cQuery += "    CDGRUPO, "
    _cQuery += "    DSGRUPO, "
    _cQuery += "    CDFAMILIA, "
    _cQuery += "    DSFAMILIA, "
    _cQuery += "    CDSUBFAMI, "
    _cQuery += "    DSSUBFAMI, "
    _cQuery += "    TPCODBAR, "
    _cQuery += "    NUMIP, "
    _cQuery += "    TPEMB, "
    _cQuery += "    UNPROD, "
    _cQuery += "    VOLEMB, "
    _cQuery += "    STATUSPRD, "
    _cQuery += "    B1_DTCAD "
    _cQuery += " FROM SUB_SQL "
    _cQuery += " WHERE SUB_SQL.SEQ = 1 AND NUMIP <> '' "

Return(_cQuery)

Static Function MontaCab()

    Local _cCabec := ""

    _cCabec += "H" //1: Tipo de registro - Fixo: H
    _cCabec += ";"
    _cCabec += SM0->M0_CGC //2: Código da Revenda
    _cCabec += ";"
    _cCabec += DTOS(DATE()) //3: Data de criação do arquivo

Return(_cCabec)
