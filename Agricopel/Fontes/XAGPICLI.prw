#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XAGPICLI
Exportação de arquivos para Pirelli
Esta rotina efetua a exportação do arquivo de Clientes
Documentação presente no chamado 446663 do DOX
@author Leandro F Silveira
@since 19/01/2021
@example u_XAGPICDS()
/*/
User Function XAGPICLI(cDirDest)

    Local cNomeArq := ""

    cNomeArq := "ACC_PDVS_" + DTOS(DATE())

    U_XAGPIARQ(cDirDest, cNomeArq, GetSql(), MontaCab())

Return(.T.)

Static Function GetSql()

    Local _cQuery := ""

    _cQuery += " SELECT "
    _cQuery += "     'V' AS TIPO, " // 1: Tipo de registro - Fixo: V
    _cQuery += "     SA1.A1_CGC, " // 2: CNPJ/CPF
    _cQuery += "     SA1.A1_NOME, " // 3: Razão Social/Nome
    _cQuery += "     SA1.A1_NREDUZ, " // 4: Nome Fantasia
    _cQuery += " 	'BRA' AS PAIS, " // 5: País
    _cQuery += " 	'', " // 6: Região
    _cQuery += " 	SA1.A1_EST, " // 7: Estado
    _cQuery += " 	SA1.A1_MUN, " // 8: Cidade
    _cQuery += " 	SA1.A1_BAIRRO, " // 9: Bairro
    _cQuery += " 	REPLACE(SA1.A1_END,';','') AS A1_END, " //10: Endereço
    _cQuery += " 	'' AS GRPREDE, " //11: Grupo/Rede
    _cQuery += "     'MOTOPECAS' AS CLASSIF, " //12: Classificação do Cliente

    _cQuery += " 	(SELECT CONCAT(A3_COD, ' - ', A3_NOME) "
    _cQuery += " 	 FROM " + RetSqlName("SA3") + " SA3 WITH (NOLOCK) "
    _cQuery += " 	 WHERE SA3.A3_COD = SA1.A1_VEND "
    _cQuery += " 	 AND   SA3.A3_FILIAL = '" + FwFilial("SA3") + "' "
    _cQuery += " 	 AND   SA3.D_E_L_E_T_ = '') AS VEND, " //13: Nome do vendedor

    _cQuery += " 	 '20190101' AS DTCADASTRO, " //14: Data Cadastro
    _cQuery += " 	 REPLACE(SA1.A1_CEP,'-','') AS CEP, " //15: CEP do Cliente
    _cQuery += " 	 SUBSTRING(REPLACE(SA1.A1_EMAIL,';',' / '), 1 ,60) AS EMAIL, " //16: Contato

    _cQuery += " 	 CASE WHEN A1_MSBLQL = '1' "
    _cQuery += " 	    THEN 'A' "
    _cQuery += " 		ELSE 'I' "
    _cQuery += " 	END AS STATUS " //17: Status

    _cQuery += " FROM " + RetSqlName("SA1") + " SA1 (NOLOCK) "

    _cQuery += " WHERE EXISTS (SELECT TOP 1 SD2.D2_DOC "
    _cQuery += "              FROM " + RetSqlName("SD2") + " SD2 WITH (NOLOCK), " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) "
    _cQuery += " 			  WHERE SD2.D2_CLIENTE = SA1.A1_COD "
    _cQuery += " 			  AND   SD2.D2_LOJA = SA1.A1_LOJA "
    _cQuery += " 			  AND   SD2.D2_COD = SB1.B1_COD "
    _cQuery += " 			  AND   B1_PROC = '014075' "
    _cQuery += "              AND   SB1.B1_COD NOT IN ('PLLPB', 'PLLIPB') "
    _cQuery += " 			  AND   SD2.D2_TIPO = 'N' "

    _cQuery += "              AND NOT EXISTS ( "
    _cQuery += "                  (SELECT A5_CODPRF "
    _cQuery += "                   FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += "                   WHERE SA5.A5_FORNECE = SB1.B1_PROC "
    _cQuery += "           	       AND   SA5.A5_LOJA = SB1.B1_LOJPROC "
    _cQuery += "           	       AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += "           	       AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += "                   AND   SA5.A5_CODPRF = 'INATIVAR' "
    _cQuery += "           	       AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += "              ) "

    _cQuery += "              AND NOT EXISTS ( "
    _cQuery += "                 (SELECT TOP 1 A5_CODPRF "
    _cQuery += "                  FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += "                  WHERE SA5.A5_FORNECE = SB1.B1_PROC "
    _cQuery += "           	      AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += "           	      AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += "                  AND   A5_CODPRF = 'INATIVAR' "
    _cQuery += "           	      AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += "              ) "

    _cQuery += " 			  AND   SB1.B1_FILIAL = '" + FwFilial("SB1") + "' "
    _cQuery += " 			  AND   SD2.D2_FILIAL = '" + FwFilial("SD2") + "' "
    _cQuery += " 			  AND   SB1.D_E_L_E_T_ = '' "
    _cQuery += " 			  AND   SD2.D_E_L_E_T_ = '') "

    _cQuery += " OR EXISTS (SELECT TOP 1 SD1.D1_DOC "
    _cQuery += "            FROM " + RetSqlName("SD1") + " SD1 WITH (NOLOCK), " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) "
    _cQuery += " 		    WHERE SD1.D1_FORNECE = SA1.A1_COD "
    _cQuery += " 		    AND   SD1.D1_LOJA = SA1.A1_LOJA "
    _cQuery += " 		    AND   SD1.D1_COD = SB1.B1_COD "
    _cQuery += " 		    AND   B1_PROC = '014075' "
    _cQuery += "            AND   SB1.B1_COD NOT IN ('PLLPB', 'PLLIPB') "
    _cQuery += " 		    AND   SD1.D1_TIPO = 'D' "

    _cQuery += "            AND NOT EXISTS ( "
    _cQuery += "                 (SELECT A5_CODPRF "
    _cQuery += "                  FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += "                  WHERE SA5.A5_FORNECE = SB1.B1_PROC "
    _cQuery += "           	      AND   SA5.A5_LOJA = SB1.B1_LOJPROC "
    _cQuery += "           	      AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += "           	      AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += "                  AND   SA5.A5_CODPRF = 'INATIVAR' "
    _cQuery += "           	      AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += "           ) "

    _cQuery += "           AND NOT EXISTS ( "
    _cQuery += "                 (SELECT TOP 1 A5_CODPRF "
    _cQuery += "                  FROM " + RetSqlName("SA5") + " SA5 WITH (NOLOCK) "
    _cQuery += "                  WHERE SA5.A5_FORNECE = SB1.B1_PROC "
    _cQuery += "           	      AND   SA5.D_E_L_E_T_ = '' "
    _cQuery += "           	      AND   SA5.A5_PRODUTO = SB1.B1_COD "
    _cQuery += "                  AND   A5_CODPRF = 'INATIVAR' "
    _cQuery += "           	      AND   SA5.A5_FILIAL = '" + FwFilial("SA5") + "') "
    _cQuery += "           ) "

    _cQuery += " 		    AND   SB1.B1_FILIAL = '" + FwFilial("SB1") + "' "
    _cQuery += " 		    AND   SD1.D1_FILIAL = '" + FwFilial("SD1") + "' "
    _cQuery += " 		    AND   SB1.D_E_L_E_T_ = '' "
    _cQuery += " 		    AND   SD1.D_E_L_E_T_ = '') "

Return(_cQuery)

Static Function MontaCab()

    Local _cCabec := ""

    _cCabec += "H" //1: Tipo de registro - Fixo: H
    _cCabec += ";"
    _cCabec += SM0->M0_CGC //2: Código da Revenda
    _cCabec += ";"
    _cCabec += DTOS(DATE()) //3: Data de criação do arquivo

Return(_cCabec)
