#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XAGPIVEN
Exportação de arquivos para Pirelli
Esta rotina efetua a exportação do arquivo de Posição de estoques
Documentação presente no chamado 446663 do DOX
@author Leandro F Silveira
@since 19/01/2021
@example u_XAGPIVEN()
/*/
User Function XAGPIVEN(cDirDest, cDiaRetIni, cDiaRetFim)

    Local cNomeArq := ""
    Local cDataIni := DTOS(DaySum(Date(), (Val(cDiaRetIni) * -1)))
    Local cDataFim := DTOS(DaySum(Date(), (Val(cDiaRetFim) * -1)))

    Conout("XAGPIVEN - De: " + cDataIni + " - Fim: " + cDataFim)

    cNomeArq := "ACC_SELLOUT_" + DTOS(DATE())

    U_XAGPIARQ(cDirDest, cNomeArq, GetSql(cDataIni, cDataFim), MontaCab(cDataIni, cDataFim))

Return(.T.)

Static Function GetSql(cDataIni, cDataFim)

    Local _cQuery := ""

    _cQuery += " WITH VENDAS AS ( "
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
    _cQuery += "   , '') AS NUMIP, " // 4: Número do IP (IP = Interno Pirelli)

    _cQuery += "   '' AS NUMLOTE, " // 5: Número do Lote
    _cQuery += "   '' AS VALLOTE, " // 6: Data de Validade do Lote

    _cQuery += "   SD2.D2_QUANT * 1000 AS QUANT, " // 7: Quantidade - Deve ser multiplicado por 1.000 (mil).
    _cQuery += "   (SD2.D2_TOTAL + SD2.D2_VALIPI + SD2.D2_ICMSRET) * 100 AS VLTOTAL, " // 8: Valor Final da Transação (Valor do produto + impostos) - Deve-se enviar obrigatoriamente as casas decimais sem separador decimal (multiplicado por 100).

    _cQuery += "   'BRL' AS MOEDA, " // 9: Moeda - Fixo: BRL
    _cQuery += "   SD2.D2_DOC AS IDTRANS,  " //10: Identificador da transação - Utilizar o número da NF
    _cQuery += "   SD2.D2_EMISSAO, " //11: Data da transação
    _cQuery += "   CASE WHEN F4_DUPLIC = 'N' THEN 'B' ELSE 'V' END AS TPTRANS, " //12: Tipo da transação V – Venda / SU – Venda Supermercado / DV – Devolução / C – Cancelamento / B – Bonificação / T – Transferência
    _cQuery += "   SD2.D2_CF, " //13: CFOP

    _cQuery += "   CASE WHEN SA1.A1_PESSOA = 'F' "
    _cQuery += "      THEN '1'
    _cQuery += "      ELSE '2'
    _cQuery += "   END AS TPPESSOA, " //14: Tipo de identificador do Cliente - “1” para CPF; “2” para CNPJ

    _cQuery += "   SA1.A1_CGC, " //15: Identificador do Cliente
    _cQuery += "   SUBSTRING(SA1.A1_NOME,1,60) AS RAZAO, " //16: Razao Cliente
    _cQuery += "   SA1.A1_CEP, " //17: CEP do Cliente
    _cQuery += "   'MOTOPECAS' AS CLASSIF, " //18: Classificação do Cliente - CONCESSIONARIA/ATACADO/VAREJO/E-COMMERCE/MOTOPECAS
    _cQuery += "   COALESCE(CONCAT(SA3.A3_COD, ' - ', A3_NOME), 'NÃO INFORMADO') AS VEND, " //19: Nome do vendedor
    _cQuery += "   '' AS IDLIVRE, " //20: Identificação do Campo Livre 1 - Nome que define o que será enviado no campo livre. Ex.: Código Promocional
    _cQuery += "   '' AS VLLIVRE " //21: Campo Livre 1 - Campo livre para informações complementares

    _cQuery += " FROM " + RetSqlName("SD2") + " SD2 WITH (NOLOCK) "

    _cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 WITH (NOLOCK) "
    _cQuery += " ON  SF2.F2_DOC = SD2.D2_DOC "
    _cQuery += " AND SF2.F2_SERIE = SD2.D2_SERIE "
    _cQuery += " AND SF2.F2_FILIAL = '" + FwFilial("SF2") + "'"
    _cQuery += " AND SF2.D_E_L_E_T_ = '' "

    _cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 WITH (NOLOCK) "
    _cQuery += " ON  SA1.A1_COD = SD2.D2_CLIENTE "
    _cQuery += " AND SA1.A1_LOJA = SD2.D2_LOJA "
    _cQuery += " AND SA1.A1_FILIAL = '" + FwFilial("SA1") + "'"
    _cQuery += " AND SA1.D_E_L_E_T_ = '' "

    _cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) "
    _cQuery += " ON  SB1.B1_COD = SD2.D2_COD "
    _cQuery += " AND SB1.B1_FILIAL = '" + FwFilial("SB1") + "'"
    _cQuery += " AND SB1.D_E_L_E_T_ = '' "
    _cQuery += " AND SB1.B1_PROC = '014075' "
    _cQuery += " AND SB1.B1_COD NOT IN ('PLLPB', 'PLLIPB') "

    _cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 WITH (NOLOCK) "
    _cQuery += " ON  SF4.F4_CODIGO = SD2.D2_TES "
    _cQuery += " AND SF4.F4_FILIAL = '" + FwFilial("SF4") + "'"
    _cQuery += " AND SF4.D_E_L_E_T_ = '' "

    _cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 WITH (NOLOCK) "
    _cQuery += " ON  SB1.B1_PROC = SA2.A2_COD "
    _cQuery += " AND SB1.B1_LOJPROC = SA2.A2_LOJA "
    _cQuery += " AND SA2.A2_FILIAL = '" + FwFilial("SA2") + "'"
    _cQuery += " AND SA2.D_E_L_E_T_ = '' "

    _cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SA3 WITH (NOLOCK) "
    _cQuery += " ON  SA3.A3_COD = SF2.F2_VEND1 "
    _cQuery += " AND SA3.A3_FILIAL = '" + FwFilial("SA3") + "'"
    _cQuery += " AND SA3.D_E_L_E_T_ = '' "

    _cQuery += " WHERE SD2.D2_EMISSAO BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
    _cQuery += " AND   SD2.D2_FILIAL = '" + FwFilial("SD2") + "'"
    _cQuery += " AND   SD2.D_E_L_E_T_ = '' "
    _cQuery += " AND   SD2.D2_TIPO = 'N' "

    _cQuery += " UNION ALL "

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
    _cQuery += "   , '') AS NUMIP, " // 4: Número do IP (IP = Interno Pirelli)

    _cQuery += "   '' AS NUMLOTE, " // 5: Número do Lote
    _cQuery += "   '' AS VALLOTE, " // 6: Data de Validade do Lote

    _cQuery += "   SD1.D1_QUANT * 1000 AS QUANT, " // 7: Quantidade - Deve ser multiplicado por 1.000 (mil).
    _cQuery += "   (SD1.D1_TOTAL + SD1.D1_VALIPI + SD1.D1_ICMSRET) * 100 AS VLTOTAL, " // 8: Valor Final da Transação (Valor do produto + impostos) - Deve-se enviar obrigatoriamente as casas decimais sem separador decimal (multiplicado por 100).

    _cQuery += "   'BRL' AS MOEDA, " // 9: Moeda - Fixo: BRL
    _cQuery += "   SD1.D1_DOC AS IDTRANS,  " //10: Identificador da transação - Utilizar o número da NF
    _cQuery += "   SD1.D1_EMISSAO, " //11: Data da transação
    _cQuery += "   'DV' AS TPTRANS, " //12: Tipo da transação V – Venda / SU – Venda Supermercado / DV – Devolução / C – Cancelamento / B – Bonificação / T – Transferência
    _cQuery += "   SD1.D1_CF, " //13: CFOP

    _cQuery += "   CASE WHEN SA1.A1_PESSOA = 'F' "
    _cQuery += "      THEN '1'
    _cQuery += "      ELSE '2'
    _cQuery += "   END AS TPPESSOA, " //14: Tipo de identificador do Cliente - “1” para CPF; “2” para CNPJ

    _cQuery += "   SA1.A1_CGC, " //15: Identificador do Cliente
    _cQuery += "   SUBSTRING(SA1.A1_NOME,1,60) AS RAZAO, "//16: Razao do Cliente
    _cQuery += "   SA1.A1_CEP, " //17: CEP do Cliente
    _cQuery += "   'MOTOPECAS' AS CLASSIF, " //18: Classificação do Cliente - CONCESSIONARIA/ATACADO/VAREJO/E-COMMERCE/MOTOPECAS

    _cQuery += "   COALESCE((SELECT CONCAT(SA3.A3_COD, ' - ', A3_NOME) "
    _cQuery += "             FROM " + RetSqlName("SA3") + " SA3 WITH (NOLOCK), " + RetSqlName("SF2") + " SF2 WITH (NOLOCK) "
    _cQuery += "             WHERE SA3.A3_COD = SF2.F2_VEND1 "
    _cQuery += "             AND   SA3.A3_FILIAL = '" + FwFilial("SA3") + "'"
    _cQuery += "             AND   SF2.F2_FILIAL = '" + FwFilial("SF2") + "'"
    _cQuery += "             AND   SA3.D_E_L_E_T_ = '' "
    _cQuery += "             AND   SF2.D_E_L_E_T_ = '' "
    _cQuery += "             AND   SF2.F2_DOC = SD1.D1_NFORI "
    _cQuery += "             AND   SF2.F2_SERIE = SD1.D1_SERIORI "
    _cQuery += "             AND   SF2.F2_CLIENTE = SD1.D1_FORNECE "
    _cQuery += "             AND   SF2.F2_LOJA = SD1.D1_LOJA)  "
    _cQuery += "   , 'NÃO INFORMADO') AS VEND, " //19: Nome do vendedor

    _cQuery += "   'NFORIGEM' AS IDLIVRE, " //20: Identificação do Campo Livre 1 - Nome que define o que será enviado no campo livre. Ex.: Código Promocional
    _cQuery += "   SD1.D1_NFORI AS VLLIVRE " //21: Campo Livre 1 - Campo livre para informações complementares

    _cQuery += " FROM " + RetSqlName("SD1") + " SD1 WITH (NOLOCK) "

    _cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 WITH (NOLOCK) "
    _cQuery += " ON  SF1.F1_DOC = SD1.D1_DOC "
    _cQuery += " AND SF1.F1_SERIE = SD1.D1_SERIE "
    _cQuery += " AND SF1.F1_FORNECE = SD1.D1_FORNECE "
    _cQuery += " AND SF1.F1_LOJA = SD1.D1_LOJA "
    _cQuery += " AND SF1.F1_FILIAL = '" + FwFilial("SF2") + "'"
    _cQuery += " AND SF1.D_E_L_E_T_ = '' "
    _cQuery += " AND SF1.F1_STATUS = 'A' "

    _cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 WITH (NOLOCK) "
    _cQuery += " ON  SA1.A1_COD = SD1.D1_FORNECE "
    _cQuery += " AND SA1.A1_LOJA = SD1.D1_LOJA "
    _cQuery += " AND SA1.A1_FILIAL = '" + FwFilial("SA1") + "'"
    _cQuery += " AND SA1.D_E_L_E_T_ = '' "

    _cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) "
    _cQuery += " ON  SB1.B1_COD = SD1.D1_COD "
    _cQuery += " AND SB1.B1_FILIAL = '" + FwFilial("SB1") + "'"
    _cQuery += " AND SB1.D_E_L_E_T_ = '' "
    _cQuery += " AND SB1.B1_PROC = '014075' "
    _cQuery += " AND SB1.B1_COD NOT IN ('PLLPB', 'PLLIPB') "

    _cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 WITH (NOLOCK) "
    _cQuery += " ON  SB1.B1_PROC = SA2.A2_COD "
    _cQuery += " AND SB1.B1_LOJPROC = SA2.A2_LOJA "
    _cQuery += " AND SA2.A2_FILIAL = '" + FwFilial("SA2") + "'"
    _cQuery += " AND SA2.D_E_L_E_T_ = '' "

    _cQuery += " WHERE SD1.D1_DTDIGIT BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
    _cQuery += " AND   SD1.D1_FILIAL = '" + FwFilial("SD1") + "'"
    _cQuery += " AND   SD1.D_E_L_E_T_ = '' "
    _cQuery += " AND   SD1.D1_TIPO = 'D' "

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

    _cQuery += " SELECT TIPO, CODCD, A2_CGC, NUMIP, NUMLOTE, VALLOTE, "
    _cQuery += " SUM(QUANT) AS QUANT, "
    _cQuery += " SUM(VLTOTAL) AS VLTOTAL, "
    _cQuery += " MOEDA, IDTRANS, D2_EMISSAO, TPTRANS, D2_CF, TPPESSOA, A1_CGC, RAZAO, "
    _cQuery += " A1_CEP, CLASSIF, VEND, IDLIVRE, VLLIVRE "
    _cQuery += " FROM VENDAS "
    _cQuery += " GROUP BY TIPO, CODCD, A2_CGC, NUMIP, NUMLOTE, VALLOTE, MOEDA, IDTRANS, D2_EMISSAO, TPTRANS, D2_CF, "
    _cQuery += "          TPPESSOA, A1_CGC, RAZAO, A1_CEP, CLASSIF, VEND, IDLIVRE, VLLIVRE "

Return(_cQuery)

Static Function MontaCab(cDataIni, cDataFim)

    Local _cCabec := ""

    _cCabec += "H" //1: Tipo de registro - Fixo: H
    _cCabec += ";"
    _cCabec += SM0->M0_CGC //2: Código da Revenda
    _cCabec += ";"
    _cCabec += cDataIni //3: Data inicial dos registros
    _cCabec += ";"
    _cCabec += cDataFim //4: Data final dos registros

Return(_cCabec)
