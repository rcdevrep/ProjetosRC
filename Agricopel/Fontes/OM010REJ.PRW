/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM010REJ   บAutor  ณLeandro F Silveira บ Data ณ  15/05/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada executado no momento da sele็ใo dos        บฑฑ
ฑฑบ          ณregistros da tabela de pre็o que sofreram reajuste de pre็o บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

As quatro perguntas utilizadas neste PE foram adicionadas manualmente no SX1 pelo MPSDU
X1_Grupo = OMS011

MV_PAR17 = Armazem inicial
MV_PAR18 = Armazem final
MV_PAR19 = Forn. Padrใo Ini
MV_PAR20 = Forn. Padrใo Fim

*/

User Function OM010REJ()

	Local _aQueryDA1 := {}
	Local _cQueryDA1 := ""
	Local _cSelect   := ""
	Local _cOrderBy  := ""

	_cQueryDA1 := Paramixb[1]


	If (!Empty(MV_PAR20) .Or. !Empty(MV_PAR21) .Or. !Empty(MV_PAR22) .Or. !Empty(MV_PAR23))

		_aQueryDA1 := Separa(_cQueryDA1, "ORDER BY", .T.)
		_cSelect   := _aQueryDA1[1]
		_cOrderBy  := _aQueryDA1[2]

		_cSelect += " AND EXISTS((SELECT LFS_SB1.B1_COD "
		_cSelect += " FROM " + RETSQLNAME("SB1") + " LFS_SB1 (NOLOCK) "
		_cSelect += "  WHERE LFS_SB1.B1_COD    = DA1.DA1_CODPRO "
		_cSelect += "  AND   LFS_SB1.B1_FILIAL = '" + XFILIAL("SB1") + "'"

		_cSelect += "  AND   LFS_SB1.B1_LOCPAD BETWEEN '" + MV_PAR20 + "' AND '" + MV_PAR21 + "'"
		_cSelect += "  AND   LFS_SB1.B1_PROC   BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "'"

		_cSelect += "  AND   LFS_SB1.D_E_L_E_T_ = '')) "

		_cQueryDA1 := _cSelect + " ORDER BY " + _cOrderBy
	EndIf

Return(_cQueryDA1)
