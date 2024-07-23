#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  AGX435    บAutor  ณ Leandro             บ Data ณ  27/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dele็ใo de Nota Fiscal                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX435()

	Private	cCadastro  := "Nota fiscal a deletar"
	Private aCamposArq := {}

	Private cNumeroNF         := ""
	Private cSerieNF          := ""
	Private cCodigoForn       := ""
	Private cPrefixoNF        := ""
	Private cPrefixoAlteracao := ""
	Private dEmissaoNF        := ""
	Private cNomeForn         := ""
	Private nValorNF          := 0.00

	Private nQtdeProdutos           := 0
	Private nQtdeLivrosFiscais      := 0
	Private nQtdeItensLivrosFiscais := 0
	Private nQtdeContasPagar        := 0
	Private	nQtdeMovBancaria        := 0

	if !CriarPerg()
		Return
	EndIf

	if mv_par05 == 2
		if CarCapaNota(mv_par06)
			ALERT("S้rie a ser aplicada na nota fiscal jแ existe!")
			Return()
		EndIf
	EndIf

	if CarCapaNota(mv_par02)
		cNumeroNF   := AllTrim(mv_par01)
		cSerieNF    := AllTrim(mv_par02)
		cCodigoForn := AllTrim(mv_par03)
		dEmissaoNF  := mv_par04

		if Len(AllTrim(mv_par06)) == 2
			cPrefixoAlteracao := Substr(AllTrim(mv_par06), 2, 3)
		Else
			cPrefixoAlteracao := Substr(AllTrim(mv_par06), 1, 3)
		EndIf

		CarItensNota()
		CarLivrosFiscais()
		CarItensLivrosFiscais()
		CarContasPagar()
		CarMovBancaria()

	    cMensagem := ""
		cMensagem := "Fornecedor:             " + Chr(9) + cNomeForn	+ "                       "         + Chr(13) + Chr(10)
		cMensagem += "Valor:                  " + Chr(9) + AllTrim(Transform(nValorNF,"@E 99999999.99"))	+ Chr(13) + Chr(10)
		cMensagem += "Produtos:               " + Chr(9) + AllTrim(Str(nQtdeProdutos)) 						+ Chr(13) + Chr(10)
		cMensagem += "Livros Fiscais Capa:    " + Chr(9) + AllTrim(Str(nQtdeLivrosFiscais))					+ Chr(13) + Chr(10)
		cMensagem += "Livros Fiscais Itens:   " + Chr(9) + AllTrim(Str(nQtdeItensLivrosFiscais))			+ Chr(13) + Chr(10)
		cMensagem += "Contas a Pagar:         " + Chr(9) + AllTrim(Str(nQtdeContasPagar))					+ Chr(13) + Chr(10)
		cMensagem += "Mov. Bancแria:          " + Chr(9) + AllTrim(Str(nQtdeMovBancaria))					+ Chr(13) + Chr(10)

		if mv_par05 == 2
			cRetorno := Aviso("Dados da Nota Fiscal a alterar:", cMensagem, {"Sim","Nใo"})
		Else
			cRetorno := Aviso("Dados da Nota Fiscal a deletar:", cMensagem, {"Sim","Nใo"})
		EndIf

		if cRetorno == 1
			Processa( {|| AtualizarDados() } )
		EndIf

		CloseAreas()
	Else
		ALERT("Nota fiscal nใo encontrada!")
	Endif

Return()

Static Function CriarPerg()

	cPerg := "AGX435"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Nota Nr          ?","mv_ch1","C",TamSX3("F1_DOC")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Serie NF         ?","mv_ch2","C",TamSX3("F1_SERIE")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Fornecedor       ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA2"})
	AADD(aRegistros,{cPerg,"04","Data Emissใo De  ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Tipo Opera็ใo    ?","mv_ch5","N",01,0,0,"C","","mv_par05","DELETAR","","","ALTERAR","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Nova S้rie NF    ?","mv_ch6","C",TamSX3("F1_SERIE")[1],0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg, aRegistros)
	
	Return Pergunte(cPerg, .T.)

Return()

Static Function CarMovBancaria()

	// CARREGANDO REGISTROS DA TABELA DE MOVIMENTAวรO BANCมRIA (SE5)
    cQuery := ""
	cQuery += " SELECT R_E_C_N_O_ "

	cQuery += " FROM " + RetSqlName("SE5") + " (NOLOCK) "

	cQuery += " WHERE E5_NUMERO = '" + mv_par01 + "'"
	cQuery += " AND   E5_PREFIXO = '" + cPrefixoNF + "'"
	cQuery += " AND   (E5_FORNECE = '" + mv_par03 + "' OR E5_CLIFOR = '" + mv_par03 + "')"

	cQuery += " AND   E5_FILIAL = '" + xFilial("SE5") + "'"
	cQuery += " AND   D_E_L_E_T_ <> '*' "

    If Select("QRY_SE5") <> 0
       dbSelectArea("QRY_SE5")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SE5"

	nQtdeMovBancaria := 0
	dbSelectArea("QRY_SE5")
	dbGoTop()
	While !Eof()

		nQtdeMovBancaria++

		dbSelectArea("QRY_SE5")
		Skip()
	EndDo
Return

Static Function CarContasPagar()

	// CARREGANDO REGISTROS DA TABELA DE CONTAS A PAGAR (SE2)
    cQuery := ""
	cQuery += " SELECT R_E_C_N_O_ "

	cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK) "

	cQuery += " WHERE E2_NUM = '" + mv_par01 + "'"
	cQuery += " AND   E2_PREFIXO = '" + cPrefixoNF + "'"
	cQuery += " AND   E2_FORNECE = '" + mv_par03 + "'"
	cQuery += " AND   E2_EMISSAO = '" + DTOS(mv_par04) + "'"

	cQuery += " AND   E2_FILIAL = '" + xFilial("SE2") + "'"
	cQuery += " AND   D_E_L_E_T_ <> '*' "

    If Select("QRY_SE2") <> 0
       dbSelectArea("QRY_SE2")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SE2"

	nQtdeContasPagar := 0
	dbSelectArea("QRY_SE2")
	dbGoTop()
	While !Eof()

		nQtdeContasPagar++

		dbSelectArea("QRY_SE2")
		Skip()
	EndDo
Return

Static Function CarItensLivrosFiscais()

	// CARREGANDO REGISTROS DA TABELA DE LIVROS FISCAIS POR ITEM DE NOTA FISCAL (SFT)
    cQuery := ""
	cQuery += " SELECT R_E_C_N_O_ "

	cQuery += " FROM " + RetSqlName("SFT") + " (NOLOCK) "

	cQuery += " WHERE FT_NFISCAL = '" + mv_par01 + "'"
	cQuery += " AND   FT_SERIE = '" + mv_par02 + "'"
	cQuery += " AND   FT_CLIEFOR = '" + mv_par03 + "'"
	cQuery += " AND   FT_EMISSAO = '" + DTOS(mv_par04) + "'"

	cQuery += " AND   FT_FILIAL = '" + xFilial("SFT") + "'"
	cQuery += " AND   D_E_L_E_T_ <> '*' "

    If Select("QRY_SFT") <> 0
       dbSelectArea("QRY_SFT")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SFT"

	nQtdeItensLivrosFiscais := 0
	dbSelectArea("QRY_SFT")
	dbGoTop()
	While !Eof()

		nQtdeItensLivrosFiscais++

		dbSelectArea("QRY_SFT")
		Skip()
	EndDo
Return

Static Function CarLivrosFiscais()

	// CARREGANDO REGISTROS DA TABELA DE LIVROS FISCAIS (SF3)
    cQuery := ""
	cQuery += " SELECT R_E_C_N_O_ "

	cQuery += " FROM " + RetSqlName("SF3") + " (NOLOCK) "

	cQuery += " WHERE F3_NFISCAL = '" + mv_par01 + "'"
	cQuery += " AND   F3_SERIE = '" + mv_par02 + "'"
	cQuery += " AND   F3_CLIEFOR = '" + mv_par03 + "'"
	cQuery += " AND   F3_EMISSAO = '" + DTOS(mv_par04) + "'"

	cQuery += " AND   F3_FILIAL = '" + xFilial("SF3") + "'"
	cQuery += " AND   D_E_L_E_T_ <> '*' "

    If Select("QRY_SF3") <> 0
       dbSelectArea("QRY_SF3")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SF3"

	nQtdeLivrosFiscais := 0
	dbSelectArea("QRY_SF3")
	dbGoTop()
	While !Eof()

		nQtdeLivrosFiscais++

		dbSelectArea("QRY_SF3")
		Skip()
	EndDo
Return

Static Function CarItensNota()

	// CARREGANDO OS ITENS DA NOTA FISCAL (SD1)
    cQuery := ""
	cQuery += " SELECT R_E_C_N_O_ "

	cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK) "

	cQuery += " WHERE D1_DOC = '" + mv_par01 + "'"
	cQuery += " AND   D1_SERIE = '" + mv_par02 + "'"
	cQuery += " AND   D1_FORNECE = '" + mv_par03 + "'"
	cQuery += " AND   D1_EMISSAO = '" + DTOS(mv_par04) + "'"

	cQuery += " AND   D1_FILIAL = '" + xFilial("SD1") + "'"
	cQuery += " AND   D_E_L_E_T_ <> '*' "

    If Select("QRY_SD1") <> 0
       dbSelectArea("QRY_SD1")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SD1"

	nQtdeProdutos := 0
	dbSelectArea("QRY_SD1")
	dbGoTop()
	While !Eof()

		nQtdeProdutos++

		dbSelectArea("QRY_SD1")
		Skip()
	EndDo
Return

Static Function CarCapaNota(cSerie)

	// CARREGANDO A CAPA DA NOTA FISCAL (SF1)
    cQuery := ""
	cQuery += " SELECT SF1.R_E_C_N_O_, "
	cQuery += "        A2_NOME, "
	cQuery += "        F1_VALMERC, "
	cQuery += "        F1_PREFIXO "

	cQuery += " FROM " + RetSqlName("SF1") + " SF1 (NOLOCK), " + RetSqlName("SA2") + " SA2 (NOLOCK) "
	cQuery += " WHERE F1_DOC = '" + mv_par01 + "'"
	cQuery += " AND   F1_SERIE = '" + cSerie + "'"
	cQuery += " AND   F1_FORNECE = '" + mv_par03 + "'"
	cQuery += " AND   F1_EMISSAO = '" + DTOS(mv_par04) + "'"

	cQuery += " AND   A2_COD = F1_FORNECE "
	cQuery += " AND   A2_LOJA = F1_LOJA "
	cQuery += " AND   A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += " AND   SA2.D_E_L_E_T_ <> '*' "

	cQuery += " AND   F1_FILIAL = '" + xFilial("SF1") + "'"
	cQuery += " AND   SF1.D_E_L_E_T_ <> '*' "

    If Select("QRY_SF1") <> 0
       dbSelectArea("QRY_SF1")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SF1"

	if AllTrim(QRY_SF1->A2_NOME) <> ""
		cNomeForn  := QRY_SF1->A2_NOME
		nValorNF   := QRY_SF1->F1_VALMERC
		cPrefixoNF := QRY_SF1->F1_PREFIXO

		Return(.T.)
	Else
		Return(.F.)
	EndIf
Return

Static Function AtualizarDados()

	// DELETANDO A CAPA DA NOTA FISCAL (SF1)
    cQuerySF1 := ""
	cQuerySF1 += " UPDATE " + RetSqlName("SF1") + " SET "

	if mv_par05 == 2
		cQuerySF1 += " F1_SERIE = '" + mv_par06 + "',"
		cQuerySF1 += " F1_PREFIXO = '" + cPrefixoAlteracao + "'"
	Else
		cQuerySF1 += " D_E_L_E_T_ = '*', "
		cQuerySF1 += " R_E_C_D_E_L_ = R_E_C_N_O_ "
	EndIf

	cQuerySF1 += " WHERE R_E_C_N_O_ = '" + Str(QRY_SF1->R_E_C_N_O_) + "'"

	If (TCSQLExec(cQuerySF1) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	// DELETANDO OS ITENS DA NOTA FISCAL (SD1)
	if nQtdeProdutos > 0

		dbSelectArea("QRY_SD1")
		dbGoTop()
		While !Eof()

		    cQuerySD1 := ""
			cQuerySD1 += " UPDATE " + RetSqlName("SD1") + " SET "

			if mv_par05 == 2
				cQuerySD1 += " D1_SERIE = '" + mv_par06 + "'"
			Else
				cQuerySD1 += " D_E_L_E_T_ = '*', "
				cQuerySD1 += " R_E_C_D_E_L_ = R_E_C_N_O_ "
			EndIf

			cQuerySD1 += " WHERE R_E_C_N_O_ = '" + Str(QRY_SD1->R_E_C_N_O_) + "'"

			If (TCSQLExec(cQuerySD1) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			dbSelectArea("QRY_SD1")
			Skip()
		EndDo
	EndIf

	// DELETANDO REGISTROS DA TABELA DE LIVROS FISCAIS (SF3)
	if nQtdeLivrosFiscais > 0

		dbSelectArea("QRY_SF3")
		dbGoTop()
		While !Eof()

		    cQuerySF3 := ""
			cQuerySF3 += " UPDATE " + RetSqlName("SF3") + " SET "

			if mv_par05 == 2
				cQuerySF3 += " F3_SERIE = '" + mv_par06 + "'"
			Else
				cQuerySF3 += " D_E_L_E_T_ = '*' "
			EndIf

			cQuerySF3 += " WHERE R_E_C_N_O_ = '" + Str(QRY_SF3->R_E_C_N_O_) + "'"

			If (TCSQLExec(cQuerySF3) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			dbSelectArea("QRY_SF3")
			Skip()
		EndDo
	EndIf

	// DELETANDO REGISTROS DA TABELA DE LIVROS FISCAIS POR ITEM DE NOTA FISCAL (SFT)
	if nQtdeItensLivrosFiscais > 0

		dbSelectArea("QRY_SFT")
		dbGoTop()
		While !Eof()

		    cQuerySFT := ""
			cQuerySFT += " UPDATE " + RetSqlName("SFT") + " SET "

			if mv_par05 == 2
				cQuerySFT += " FT_SERIE = '" + mv_par06 + "'"
			Else
				cQuerySFT += " D_E_L_E_T_ = '*', "
				cQuerySFT += " R_E_C_D_E_L_ = R_E_C_N_O_ "
			EndIf

			cQuerySFT += " WHERE R_E_C_N_O_ = '" + Str(QRY_SFT->R_E_C_N_O_) + "'"

			If (TCSQLExec(cQuerySFT) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			dbSelectArea("QRY_SFT")
			Skip()
		EndDo
	EndIf

	// DELETANDO REGISTROS DA TABELA DE CONTAS A PAGAR (SE2)
	if nQtdeContasPagar > 0

		dbSelectArea("QRY_SE2")
		dbGoTop()
		While !Eof()

		    cQuerySE2 := ""
			cQuerySE2 += " UPDATE " + RetSqlName("SE2") + " SET "

			if mv_par05 == 2
				cQuerySE2 += " E2_PREFIXO = '" + cPrefixoAlteracao + "'"
			Else
				cQuerySE2 += " D_E_L_E_T_ = '*', "
				cQuerySE2 += " R_E_C_D_E_L_ = R_E_C_N_O_ "
			EndIf

			cQuerySE2 += " WHERE R_E_C_N_O_ = '" + Str(QRY_SE2->R_E_C_N_O_) + "'"

			If (TCSQLExec(cQuerySE2) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			dbSelectArea("QRY_SE2")
			Skip()
		EndDo
	EndIf

	// DELETANDO REGISTROS DA TABELA DE MOVIMENTAวรO BANCมRIA (SE5) 
	if nQtdeMovBancaria > 0

		dbSelectArea("QRY_SE5")
		dbGoTop()
		While !Eof()

		    cQuerySE5 := ""
			cQuerySE5 += " UPDATE " + RetSqlName("SE5") + " SET "

			if mv_par05 == 2
				cQuerySE5 += " E5_PREFIXO = '" + cPrefixoAlteracao + "'"
			Else
				cQuerySE5 += " D_E_L_E_T_ = '*' "
			EndIf

			cQuerySE5 += " WHERE R_E_C_N_O_ = '" + Str(QRY_SE5->R_E_C_N_O_) + "'"

			If (TCSQLExec(cQuerySE5) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			dbSelectArea("QRY_SE5")
			Skip()
		EndDo
	EndIf

	MsgInfo("Grava็ใo concluํda!", "Sucesso")
Return(nil)

Static Function CloseAreas()

    If Select("QRY_SE5") <> 0
       dbSelectArea("QRY_SE5")
   	   dbCloseArea()
    Endif
	
    If Select("QRY_SE2") <> 0
       dbSelectArea("QRY_SE2")
   	   dbCloseArea()
    Endif
	
    If Select("QRY_SFT") <> 0
       dbSelectArea("QRY_SFT")
   	   dbCloseArea()
    Endif
	
    If Select("QRY_SF3") <> 0
       dbSelectArea("QRY_SF3")
   	   dbCloseArea()
    Endif
	
    If Select("QRY_SD1") <> 0
       dbSelectArea("QRY_SD1")
   	   dbCloseArea()
    Endif
	
    If Select("QRY_SF1") <> 0
       dbSelectArea("QRY_SF1")
   	   dbCloseArea()
    Endif

Return()
