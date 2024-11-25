#INCLUDE "PROTHEUS.CH"


// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTECR1 - RELATORIO DE PRODUCAO TETO METEOR
// PROJETO - TETO METEOR
// DATA - 24/09/2024
USER Function RCTECR2()

	Local oReport as Object
	Local oSection1 as Object
    Local oSection2 as Object
    Local oSection3 as Object
	Local oSection4 as Object

//Classe TREPORT
	oReport := TReport():New('TETO METEOR',"Relatorio Qualidade",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection1)})

//Seção 1 
	oSection1 := TRSection():New(oReport,'TETO METEOR')
	oSection2 := TRSection():New(oReport,'SETUP')
	oSection3 := TRSection():New(oReport,'MOLDAGEM')
	oSection4 := TRSection():New(oReport,'DUREZA')

//Definição das colunas de impressão da seção 1
	TRCell():New(oSection1, "ZT0_CODIGO" , "TRB", "Teto", /*Picture*/, 4, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "ZT0_STATUS", "TRB", "Status" , /*Picture*/, 1, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "ZT0_DATA" , "TRB", "Data Geracao"    , /*Picture*/, 8, /*lPixel*/, /*{|| code-block de impressao }*/)
//Definição das colunas de impressão da seção 2	
	TRCell():New(oSection2, "ZT2_CAV" , "TRB2", "Cavidade"    , /*Picture*/, 1, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "ZT2_TURNO" , "TRB2", "Turno"    , /*Picture*/, 1, /*lPixel*/, /*{|| code-block de impressao }*/)
//Definição das colunas de impressão da seção 3
	TRCell():New(oSection3, "ZT3_CAV" , "TRB", "Cavidade"    , /*Picture*/, 1, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection3, "ZT3_TURNO" , "TRB", "Turno"    , /*Picture*/, 1, /*lPixel*/, /*{|| code-block de impressao }*/)
//Definição das colunas de impressão da seção 4	
	TRCell():New(oSection4, "ZT4_CAV" , "TRB", "Cavidade"    , /*Picture*/, 1, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection4, "ZT4_TURNO" , "TRB", "Turno"    , /*Picture*/, 1, /*lPixel*/, /*{|| code-block de impressao }*/)

	//TRCell():New(oSection, "D1_CONTA" , "TRB", "Item Estoque?"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	//TRCell():New(oSection, "D1_PEDIDO" , "TRB", "Pedido"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	//TRCell():New(oSection, "F1_SOLICIT" , "TRB", "Solicitante"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
	//TRCell():New(oSection, "C7_DATPRF" , "TRB", "Entrega"    , /*Picture*/, 20, /*lPixel*/, /*{|| code-block de impressao }*/)
    
    oReport:PrintDialog()

Return

Static Function ReportPrint(oReport,oSection1)

	#IFDEF TOP

		Local cAlias := "TRB"
		Local cAlias2 := "TRB2"
		Local cTeto := ZT0->ZT0_CODIGO
		Local cStatus := ZT0->ZT0_STATUS
		Local cData := DTOS(ZT0->ZT0_DATA)

		BEGIN REPORT QUERY oSection1

			BeginSql alias cAlias

           SELECT ZT0_CODIGO, ZT0_STATUS
			FROM %Table:ZT0% ZT0
			//INNER JOIN %Table:ZT2% ZT2 ON ZT2_CTETO = ZT0_CODIGO AND ZT2.%NotDel%
			//INNER JOIN %Table:ZT3% ZT3 ON ZT3_CTETO = ZT0_CODIGO AND ZT3.%NotDel%
			//INNER JOIN %Table:ZT4% ZT4 ON ZT4_CTETO = ZT0_CODIGO AND ZT4.%NotDel%
			WHERE ZT0_CODIGO = %Exp:cTeto%	

			EndSql

		END REPORT QUERY oSection1

		BEGIN REPORT QUERY oSection2

			BeginSql alias cAlias2

           SELECT ZT2_CAV, ZT2_TURNO
			FROM %Table:ZT2% ZT2
			INNER JOIN %Table:ZT0% ZT0 ON ZT0_CODIGO = ZT2_CTETO AND ZT0.%NotDel%
			//INNER JOIN %Table:ZT3% ZT3 ON ZT3_CTETO = ZT0_CODIGO AND ZT3.%NotDel%
			//INNER JOIN %Table:ZT4% ZT4 ON ZT4_CTETO = ZT0_CODIGO AND ZT4.%NotDel%
			WHERE ZT0_CODIGO = %Exp:cTeto%	

			EndSql

		END REPORT QUERY oSection2

		oSection1:Print()
		oSection2:Print()

	#ENDIF

return
