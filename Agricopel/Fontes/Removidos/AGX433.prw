#INCLUDE "rwmake.ch"
//#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

User Function AGX433()

	Local cTipo := ""

	cPerg := "AGX433"
	aRegistros:= {}

	AADD(aRegistros,{cPerg,"01","Tipo Nota       ?","mv_ch1","N",01,0,0,"C","","MV_PAR01","NF Entrada","","","NF Saida","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Periodo de      ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Periodo ate     ?","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Docto de        ?","mv_ch4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Docto ate       ?","mv_ch5","C",06,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Produto de      ?","mv_ch6","C",15,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"07","Produto ate     ?","mv_ch7","C",15,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"08","TES de          ?","mv_ch8","C",03,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","SF4"})
	AADD(aRegistros,{cPerg,"09","TES ate         ?","mv_ch9","C",03,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","SF4"})
	AADD(aRegistros,{cPerg,"10","Filial de       ?","mv_ch10","C",02,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"11","Filial ate      ?","mv_ch11","C",02,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","CFOP de         ?","mv_ch12","C",05,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"13","CFOP ate        ?","mv_ch13","C",05,0,0,"G","","MV_PAR13","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"14","NF de           ?","mv_ch14","C",TamSX3("F1_DOC")[1],0,0,"G","","MV_PAR14","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"15","NF ate          ?","mv_ch15","C",TamSX3("F1_DOC")[1],0,0,"G","","MV_PAR15","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If Pergunte(cPerg,.T.)

		If MV_PAR01 == 1
			cTipo := "NF Entrada"
		Else
			cTipo := "NF Saida"
		EndIf

		Processa({|| fProcZero()}, cTipo)
		ApMsgInfo("Dados processados com sucesso !")
	Else
		Alert("Operação Cancelada!")
	EndIf

Return()

Static Function fProcZero()

	Local cQuery := ""

	If MV_PAR01 == 1

		cQuery := " UPDATE " + RetSQLName("SD1") + " SET "

		cQuery += "    D1_ALQIMP5 = 0,"
		cQuery += "    D1_ALQIMP6 = 0,"
		cQuery += "    D1_BASIMP5 = 0,"
		cQuery += "    D1_BASIMP6 = 0,"
		cQuery += "    D1_VALIMP5 = 0,"
		cQuery += "    D1_VALIMP6 = 0 "

		cQuery += " FROM " + RetSQLName("SB1") + " (NOLOCK), " + RetSQLName("SF4") + " (NOLOCK) "

		cQuery += " WHERE B1_COD    = D1_COD "
		cQuery += " AND   F4_CODIGO = D1_TES "

		If Empty(xFilial("SB1")) == Empty(xFilial("SD1"))
			cQuery += " AND B1_FILIAL = D1_FILIAL "
		EndIf

		If Empty(xFilial("SF4")) == Empty(xFilial("SD1"))
			cQuery += " AND F4_FILIAL = D1_FILIAL "
		EndIf

		cQuery += " AND   D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
		cQuery += " AND   D1_FILIAL  BETWEEN '" + MV_PAR10       + "' AND '" + MV_PAR11       + "'"
		cQuery += " AND   D1_COD     BETWEEN '" + MV_PAR06       + "' AND '" + MV_PAR07       + "'"
		cQuery += " AND   D1_TES     BETWEEN '" + MV_PAR08       + "' AND '" + MV_PAR09       + "'"
		cQuery += " AND   D1_DOC     BETWEEN '" + MV_PAR04       + "' AND '" + MV_PAR05       + "'"
		cQuery += " AND   D1_CF      BETWEEN '" + MV_PAR12       + "' AND '" + MV_PAR13       + "'"
		cQuery += " AND   D1_DOC     BETWEEN '" + MV_PAR14       + "' AND '" + MV_PAR15       + "'"

		cQuery += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = '' "
		cQuery += " AND " + RetSQLName("SF4") + ".D_E_L_E_T_ = '' "
		cQuery += " AND " + RetSQLName("SD1") + ".D_E_L_E_T_ = '' "
	Else
		cQuery := " UPDATE " + RetSQLName("SD2") + " SET "

		cQuery += "    D2_ALQIMP5 = 0, "
		cQuery += "    D2_ALQIMP6 = 0, "
		cQuery += "    D2_BASIMP5 = 0, "
		cQuery += "    D2_BASIMP6 = 0, "
		cQuery += "    D2_VALIMP5 = 0, "
		cQuery += "    D2_VALIMP6 = 0  "

		cQuery += " FROM " + RetSQLName("SB1") + " (NOLOCK), " + RetSQLName("SF4") + " (NOLOCK) "

		cQuery += " WHERE B1_COD    = D2_COD "
		cQuery += " AND   F4_CODIGO = D2_TES "

		If Empty(xFilial("SB1")) == Empty(xFilial("SD2"))
			cQuery += " AND B1_FILIAL = D2_FILIAL "
		EndIf

		If Empty(xFilial("SF4")) == Empty(xFilial("SD2"))
			cQuery += " AND F4_FILIAL = D2_FILIAL "
		EndIf

		cQuery += "AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
		cQuery += "AND D2_FILIAL  BETWEEN '" + MV_PAR10       + "' AND '" + MV_PAR11       + "'"
		cQuery += "AND D2_COD     BETWEEN '" + MV_PAR06       + "' AND '" + MV_PAR07       + "'"
		cQuery += "AND D2_TES     BETWEEN '" + MV_PAR08       + "' AND '" + MV_PAR09       + "'"
		cQuery += "AND D2_DOC     BETWEEN '" + MV_PAR04       + "' AND '" + MV_PAR05       + "'"
		cQuery += "AND D2_CF      BETWEEN '" + MV_PAR12       + "' AND '" + MV_PAR13       + "'"
		cQuery += "AND D2_DOC     BETWEEN '" + MV_PAR14       + "' AND '" + MV_PAR15       + "'"

		cQuery += "AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = '' "
		cQuery += "AND " + RetSQLName("SF4") + ".D_E_L_E_T_ = '' "
		cQuery += "AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = '' "
	EndIf

	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

Return()