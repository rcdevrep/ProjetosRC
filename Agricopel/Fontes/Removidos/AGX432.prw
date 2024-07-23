#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

User Function AGX432()

	cPerg := "AGX432"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Tipo Nota       ?","mv_ch1","N",01,0,0,"C","","MV_PAR01","NF Entrada","","","NF Saida","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data Digit de   ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Data Digit ate  ?","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Produto de      ?","mv_ch4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"05","Produto ate     ?","mv_ch5","C",15,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"06","Filial de       ?","mv_ch6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Filial ate      ?","mv_ch7","C",02,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","NF de           ?","mv_ch8","C",TamSX3("F1_DOC")[1],0,0,"G","","MV_PAR08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","NF ate          ?","mv_ch9","C",TamSX3("F1_DOC")[1],0,0,"G","","MV_PAR09","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If Pergunte(cPerg,.T.)
		Processa({|| fProcNf()})
		ApMsgInfo("Dados processados com sucesso !")
	Else
		Alert("Operação Cancelada!")
	EndIf

Return()

Static Function fProcNf()

	Local cQuery := ""

	If MV_PAR01 == 1

		cQuery := " UPDATE " + RetSQLName("SD1") + " SET "

		cQuery += "    D1_ALQIMP5 = B1_PCOFINS, "
		cQuery += "    D1_ALQIMP6 = B1_PPIS, "
		cQuery += "    D1_BASIMP5 = ROUND(D1_TOTAL,2), "
		cQuery += "    D1_BASIMP6 = ROUND(D1_TOTAL,2), "
		cQuery += "    D1_VALIMP5 = ROUND((D1_TOTAL * B1_PCOFINS)/100,2), "
		cQuery += "    D1_VALIMP6 = ROUND((D1_TOTAL * B1_PPIS)   /100,2) "

		cQuery += " FROM " + RetSQLName("SB1") + " (NOLOCK), " + RetSQLName("SF4") + " (NOLOCK) "

		cQuery += " WHERE D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
		cQuery += " AND   D1_FILIAL  BETWEEN '" + MV_PAR06       + "' AND '" + MV_PAR07       + "'"
		cQuery += " AND   D1_COD     BETWEEN '" + MV_PAR04       + "' AND '" + MV_PAR05       + "'"
		cQuery += " AND   D1_DOC     BETWEEN '" + MV_PAR08       + "' AND '" + MV_PAR09       + "'"

		cQuery += " AND (B1_PPIS > 0  OR B1_PCOFINS > 0) "

		cQuery += " AND B1_COFINS = '1' "
		cQuery += " AND B1_COD    = D1_COD "

		If Empty(xFilial("SB1")) == Empty(xFilial("SD1"))
			cQuery += " AND B1_FILIAL = D1_FILIAL "
		EndIf

		If Empty(xFilial("SF4")) == Empty(xFilial("SD1"))
			cQuery += " AND F4_FILIAL = D1_FILIAL "
		EndIf

		cQuery += " AND F4_CODIGO = D1_TES "
		cQuery += " AND F4_PISCOF = '3' "

		cQuery += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = '' "
		cQuery += " AND " + RetSQLName("SF4") + ".D_E_L_E_T_ = '' "
		cQuery += " AND " + RetSQLName("SD1") + ".D_E_L_E_T_ = '' "
	Else
		cQuery := " UPDATE " + RetSQLName("SD2") + " SET "

		cQuery += "    D2_ALQIMP5 = B1_PCOFINS, "
		cQuery += "    D2_ALQIMP6 = B1_PPIS, "
		cQuery += "    D2_BASIMP5 = ROUND(D2_TOTAL,2), "
		cQuery += "    D2_BASIMP6 = ROUND(D2_TOTAL,2), "
		cQuery += "    D2_VALIMP5 = ROUND((D2_TOTAL * B1_PCOFINS)/100,2), "
		cQuery += "    D2_VALIMP6 = ROUND((D2_TOTAL * B1_PPIS)   /100,2)  "

		cQuery += " FROM " + RetSQLName("SB1") + " (NOLOCK), " + RetSQLName("SF4") + " (NOLOCK) "

		cQuery += " WHERE D2_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
		cQuery += " AND   D2_FILIAL  BETWEEN '" + MV_PAR06       + "' AND '" + MV_PAR07       + "'"
		cQuery += " AND   D2_COD     BETWEEN '" + MV_PAR04       + "' AND '" + MV_PAR05       + "'"
		cQuery += " AND   D2_DOC     BETWEEN '" + MV_PAR08       + "' AND '" + MV_PAR09       + "'"

		cQuery += "	AND (B1_PPIS > 0  OR B1_PCOFINS > 0) "

		cQuery += "	AND B1_COFINS = '1' "
		cQuery += " AND B1_COD    = D2_COD "

		If Empty(xFilial("SB1")) == Empty(xFilial("SD2"))
			cQuery += " AND B1_FILIAL = D2_FILIAL "
		EndIf

		If Empty(xFilial("SF4")) == Empty(xFilial("SD2"))
			cQuery += " AND F4_FILIAL = D2_FILIAL "
		EndIf

		cQuery += " AND F4_CODIGO = D2_TES "
		cQuery += " AND F4_PISCOF = '3' "

		cQuery += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = '' "
		cQuery += " AND " + RetSQLName("SF4") + ".D_E_L_E_T_ = '' "
		cQuery += " AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = '' "
	EndIf

	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

Return()