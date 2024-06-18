#INCLUDE "PROTHEUS.CH"


// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTECR1 - RELATORIO ROMANEIO DE RECEBIMENTO
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 17/06/2024
USER Function RCTECR1()

	Local oReport as Object
	Local oSection as Object

//Classe TREPORT
	oReport := TReport():New('ROMANEIO',"Romaneio Recebimento",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection)})

//Seção 1 
	oSection := TRSection():New(oReport,'Romaneio')

//Definição das colunas de impressão da seção 1
	TRCell():New(oSection, "F1_DOC" , "TRB", "Numero", /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "F1_SERIE", "TRB", "Serie" , /*Picture*/, 10, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_NOME" , "TRB", "Fornecedor"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CGC" , "TRB", "CNPJ"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "D1_COD" , "TRB", "Produto"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "B1_DESC" , "TRB", "Descricao"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "D1_ITEM" , "TRB", "Item"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "D1_QUANT" , "TRB", "Quantidade"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "D1_UM" , "TRB", "UM"    , /*Picture*/, 10, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "D1_CONTA" , "TRB", "Item Estoque?"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "D1_PEDIDO" , "TRB", "Pedido"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "F1_SOLICIT" , "TRB", "Solicitante"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "C7_DATPRF" , "TRB", "Entrega"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
    
    oReport:PrintDialog()

Return

Static Function ReportPrint(oReport,oSection)

	#IFDEF TOP

		Local cAlias := "TRB"
		Local cDoc := SF1->F1_DOC
		Local cSerie := SF1->F1_SERIE
		Local cFornece := SF1->F1_FORNECE
        Local cLoja := SF1->F1_LOJA

		BEGIN REPORT QUERY oSection

			BeginSql alias cAlias

            SELECT F1_DOC,F1_SERIE,A2_NOME,A2_CGC,D1_COD,B1_DESC,D1_ITEM,D1_QUANT,D1_UM,
            CASE WHEN SUBSTRING( D1_CONTA, 1, 4 ) = '1131' THEN 'S' ELSE 'N' END AS D1_CONTA,D1_PEDIDO,F1_SOLICIT,ISNULL(C7_DATPRF,' ') C7_DATPRF
            FROM %Table:SF1% SF1
            INNER JOIN %Table:SD1% SD1 ON D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SD1.%NotDel%
            INNER JOIN %Table:SB1% SB1 ON B1_COD = D1_COD AND SB1.%NotDel%
            INNER JOIN %Table:SA2% SA2 ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA AND SA2.%NotDel%
			LEFT JOIN %Table:SC7% SC7 ON D1_PEDIDO = C7_NUM AND D1_FORNECE = C7_FORNECE AND D1_LOJA = C7_LOJA AND SC7.%NotDel%
            WHERE F1_FILIAL = %xFilial:SF1%  AND F1_DOC = %Exp:cDoc% AND F1_SERIE = %Exp:cSerie% AND F1_FORNECE = %Exp:cFornece% AND F1_LOJA = %Exp:cLoja% AND SF1.%NotDel%
            GROUP BY F1_DOC,F1_SERIE,A2_NOME,A2_CGC,D1_COD,B1_DESC,D1_ITEM,D1_QUANT,D1_UM,D1_CONTA,D1_PEDIDO,F1_SOLICIT,C7_DATPRF
			ORDER BY D1_ITEM

			EndSql

		END REPORT QUERY oSection

		oSection:Print()

	#ENDIF

return
