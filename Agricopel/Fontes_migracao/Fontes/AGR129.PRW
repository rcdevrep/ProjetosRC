#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGR129   บAutor  ณ Deco               บ Data ณ  08/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para atualizar Ultimo Preco Compra                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AGR129()

	Local cPerg := "AGR129"

	PutSx1(cPerg, "01", "Produto de      ?", "" , "", "mv_ch1", "C", 15, 0, 2, 'G',"","SB1","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "02", "Produto ate     ?", "" , "", "mv_ch2", "C", 15, 0, 2, 'G',"","SB1","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "03", "Armaz้m de      ?", "" , "", "mv_ch3", "C", 02, 0, 2, 'G',"",""   ,"","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "04", "Armaz้m ate     ?", "" , "", "mv_ch4", "C", 02, 0, 2, 'G',"",""   ,"","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "05", "Forn Padrใo de  ?", "" , "", "mv_ch5", "C", 06, 0, 2, 'G',"","SA2","","", "mv_par05", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "06", "Forn Padrใo ate ?", "" , "", "mv_ch6", "C", 06, 0, 2, 'G',"","SA2","","", "mv_par06", "","", "","" ,"","","","","","","","","","","","", "","", "")

	If Pergunte(cPerg, .T.)
		Processa({|| R129Proc()})
	EndIf

Return

Static Function R129Proc()

	Local cQuery     := ""
	Local cCliente   := Space(6)
	Local cLoja      := Space(2)
	Local cProduto   := Space(15)
	Local cPedido    := Space(6)
	Local cTabela    := Space(3)
	Local nPrcTab    := 0
	Local nUprc      := 0
	Local nValIcm    := 0
	Local nValIPI    := 0
	Local nIcmsRet   := 0
	Local nQuant     := 0
	Local _nCountPrd := 0

	If (!UPRCZerar())
		Return()
	EndIf

	cQuery := " SELECT D1_COD, "
	cQuery += "        D1_DTDIGIT, "
	cQuery += "        D1_VUNIT, "
	cQuery += "        D1_VALICM, "
	cQuery += "        D1_VALIPI, "
	cQuery += "        D1_ICMSRET, "
	cQuery += "        D1_QUANT, "
	cQuery += "        D1_VALDESC, "
	cQuery += "        F4_LFICM "

	cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK), " + RetSqlName("SF1") + " SF1 (NOLOCK), "
	cQuery +=            RetSqlName("SF4") + " SF4 (NOLOCK), " + RetSqlName("SB1") + " SB1 (NOLOCK) "

	cQuery += " WHERE D1_FILIAL      = '" + xFilial("SD1") + "'"
	cQuery += " AND   B1_FILIAL      = '" + xFilial("SB1") + "'"
	cQuery += " AND   SB1.D_E_L_E_T_ = '' "
	cQuery += " AND   SD1.D_E_L_E_T_ = '' "
	cQuery += " AND   SF1.D_E_L_E_T_ = '' "
	cQuery += " AND   D1_TIPO        = 'N' "

	cQuery += " AND   B1_COD     = D1_COD "
	cQuery += " AND   D1_DOC     = F1_DOC "
	cQuery += " AND   D1_SERIE   = F1_SERIE "
	cQuery += " AND   D1_FILIAL  = F1_FILIAL "
	cQuery += " AND   D1_FORNECE = F1_FORNECE "
	cQuery += " AND   D1_TIPO    = F1_TIPO "
	cQuery += " AND   D1_EMISSAO = F1_EMISSAO "
	cQuery += " AND   D1_FILIAL  = F4_FILIAL "
	cQuery += " AND   D1_TES     = F4_CODIGO "
	cQuery += " AND   F4_UPRC    = 'S' "
	cQuery += " AND   F1_STATUS  = 'A' "

	cQuery += " AND   D1_COD    BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += " AND   B1_LOCPAD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += " AND   B1_PROC   BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "

	cQuery += " ORDER BY D1_COD, D1_DTDIGIT DESC, SD1.R_E_C_N_O_ "

	If Select("MD1") <> 0
		DbSelectArea("MD1")
		DbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "MD1"

	TCSetField("MD1","D1_DTDIGIT"  ,"D",08,0)
	TCSetField("MD1","D1_VUNIT"    ,"N",14,2)
	TCSetField("MD1","D1_VALICM"   ,"N",14,2)
	TCSetField("MD1","D1_VALIPI"   ,"N",14,2)
	TCSetField("MD1","D1_ICMSRET"  ,"N",14,2)
	TCSetField("MD1","D1_QUANT"    ,"N",11,2)
	TCSetField("MD1","D1_VALDESC"  ,"N",14,2)

	DbSelectArea("MD1")
	Procregua(1)
	DbGotop()
	While !Eof()

		_nCountPrd += 1
		IncProc("Atualizando produto: " + MD1->D1_COD + CHR(13) + CHR(10) + "Total: " + cValToChar(_nCountPrd))

		cProduto := MD1->D1_COD
		nUPrc    := MD1->D1_VUNIT
		dDtDigit := MD1->D1_DTDIGIT
		nValIcm  := MD1->D1_VALICM
		nValIPI  := MD1->D1_VALIPI
		nIcmsRet := MD1->D1_ICMSRET
		nQuant   := MD1->D1_QUANT
		nValDesc := MD1->D1_VALDESC

		If nValIcm > 0
			nValIcm := (nValIcm / nQuant)
		Endif

		If nValIPI > 0
			nValIPI := (nValIPI / nQuant)
		Endif

		If nIcmsRet > 0
			nIcmsRet := (nIcmsRet / nQuant)
		Endif

		if nValDesc > 0
			nValDesc := (nValDesc / nQuant)
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cProduto)

			RecLock("SB1",.F.)

			If Alltrim(MD1->F4_LFICM) == 'T'
				SB1->B1_UPRC  := nUprc - nValDesc - nValIcm + nValIPI + nIcmsRet
			Else
				SB1->B1_UPRC  := nUprc - nValDesc + nValIPI + nIcmsRet
			EndIf

			SB1->B1_UPRC2 := nUprc
			SB1->B1_UCOM  := dDtDigit

			MsUnlock("SB1")

		EndIf

		DbSelectArea("MD1")
		While !Eof().and.(cProduto == MD1->D1_COD)
			DbSkip()
		EndDo

	EndDo

	If Select("MD1") <> 0
		DbSelectArea("MD1")
		DbCloseArea()
	EndIf

	MsgInfo("Atualiza็ใo finalizada. Um total de [" + cValToChar(_nCountPrd) + "] produtos foram atualizados!")

Return()

Static Function UPRCZerar()

	Local cQuery := ""

	cQuery := " UPDATE " + RetSQLName("SB1") + " SET "
	cQuery += "   B1_UPRC  = 0, "
	cQuery += "   B1_UPRC2 = 0, "
	cQuery += "   B1_UCOM  = '' "
	cQuery += " WHERE B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery += " AND   D_E_L_E_T_ = '' "

	cQuery += " AND   B1_COD    BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += " AND   B1_LOCPAD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += " AND   B1_PROC   BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "

	If (TcSqlExec(cQuery) < 0)
		MsgStop("TCSQLError() " + TCSQLError())
		Return(.F.)
	EndIf

Return(.T.)