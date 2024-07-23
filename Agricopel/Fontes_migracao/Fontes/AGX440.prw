#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX270      บAutor  ณLEANDRO SILVEIRA  บ Data ณ 06/05/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ CADASTRO PARA INFORMAR SEPARADOR QUE SEPAROU PEDIDO        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX440()

	If CriaPerg()

		If MV_PAR01 = 1
			TelaPed()
		Else    
			TelaCarga()
		EndIf

	EndIf

Return .T.

Static Function OkProcPed()

	If EMPTY(GETSERV) .Or. EMPTY(GETDOC) .Or. EMPTY(GETEXEC)
		Aviso("T.I. Informa:","Hแ um ou mais campos que estใo em branco!",{"&OK"})
	Else
		Processa({|| AtualPed() })
	EndIf

	oGetx2:SetFocus()

Return .T.

Static Function AtualPed()

	cQuery := ""
	cQuery += "     SELECT DB_DOC, "
	cQuery += "            DB_CDEXEC "

	cQuery += "     FROM " + RetSqlName("SDB") + " SDB "

	cQuery += "     WHERE SDB.DB_SERVIC = '" + GETSERV + "'"
	cQuery += "     AND   SDB.DB_DOC    = '" + GETDOC + "'"

	cQuery += "     AND   SDB.DB_FILIAL = '" + xFilial('SDB') + "'"
	cQuery += "     AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "     AND   SDB.DB_ESTORNO = ' ' "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SDB") <> 0
       dbSelectArea("QRY_SDB")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"

	if AllTrim(QRY_SDB->DB_DOC) == ""
		Aviso("T.I. Informa:","Servi็o nใo encontrado!",{"&OK"})
		Return .T.
	EndIf

	if AllTrim(QRY_SDB->DB_CDEXEC) <> ""                  
		Aviso("T.I. Informa:","Jแ foi informado um executor para este servi็o!",{"&OK"})
		Return .T.
	EndIf  

	cQuery2 := ""
	cQuery2 += "     SELECT ZZA_NOME "
	cQuery2 += "     FROM " + RetSqlName("ZZA") 
	cQuery2 += "     WHERE ZZA_COD = '" + GETEXEC + "'"
	cQuery2 += "     AND   ZZA_FILIAL = '" + xFilial('ZZA') + "'"
	cQuery2 += "     AND   D_E_L_E_T_ <> '*' "

	cQuery2 := ChangeQuery(cQuery2)

    If Select("QRY_ZZA") <> 0
       dbSelectArea("QRY_ZZA")
   	   dbCloseArea()
    Endif

	TCQuery cQuery2 NEW ALIAS "QRY_ZZA"

	if AllTrim(QRY_ZZA->ZZA_NOME) == ""
		Aviso("T.I. Informa:","C๓digo de executor invแlido!",{"&OK"})
		Return
	EndIf

    cQuery3 := ""
	cQuery3 += "  UPDATE " + RetSqlName("SDB") + " SET "
	cQuery3 += "			DB_CDEXEC = '" + GETEXEC + "'"

	cQuery3 += "  WHERE DB_SERVIC = '" + GETSERV + "'"
	cQuery3 += "  AND   DB_DOC    = '" + GETDOC + "'"

	cQuery3 += "  AND   DB_FILIAL = '" + xFilial('SDB') + "'"
	cQuery3 += "  AND   D_E_L_E_T_ <> '*' "

	cQuery3 += "  AND   DB_ESTORNO = ' ' "

   	If (TCSQLExec(cQuery3) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	Else
		Aviso("T.I. Informa:","Atualiza็ใo concluํda!",{"&OK"})
		GETDOC:=SPACE(06)
		GETEXEC:=SPACE(04)
	EndIf 

	dbSelectArea("QRY_SDB")
	dbCloseArea()

	dbSelectArea("QRY_ZZA")
	dbCloseArea()

Return .T.

Static Function CriaPerg()

	cPerg := "AGX440"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Tipo Separa็ใo    ?","mv_ch1","N",01,0,0,"C","","mv_par01","Pedido","","","Carga","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

Return Pergunte(cPerg, .T.)

Static Function TelaPed()

	SetPrvt("GETSERV,GETDOC,GETEXEC")

	GETSERV:=SPACE(06)
	GETDOC:=SPACE(06)
	GETEXEC:=SPACE(04)

	@ 96,42 TO 260,455 DIALOG oDlg TITLE "Atualizar executor de servi็os de estoque"
	@ 8,10  TO 60,200
	
	@ 13,14 SAY "Servi็o:    "
	@ 13,68 GET GETSERV object oGetx1 size 40,80
	oGetx1:SetFocus()

	@ 29,14 SAY "C๓d Pedido:    "
	@ 29,68 GET GETDOC object oGetx2 Size 30,80

	@ 45,14 SAY "Executor:    "
	@ 45,68 GET GETEXEC Size 30,80 F3 "ZZA"

	@ 65,140 BMPBUTTON TYPE 1 ACTION OkProcPed()
	@ 65,173 BMPBUTTON TYPE 2 ACTION Close(oDlg)

	ACTIVATE DIALOG oDlg CENTERED

Return .T.

Static Function TelaCarga()

	SetPrvt("GETSERV,GETCARGA,GETLOCALIZ,GETEXEC")

	GETSERV:=SPACE(TamSX3("DB_SERVIC")[1])
	GETCARGA:=SPACE(TamSX3("DB_CARGA")[1])
	GETLOCALIZ:=SPACE(3)
	GETEXEC:=SPACE(TamSX3("DB_CDEXEC")[1])

	@ 96,42 TO 260,455 DIALOG oDlg TITLE "Atualizar executor de servi็os de estoque"
	@ 8,10  TO 60,200

	@ 13,14 SAY "Servi็o:    "
	@ 13,68 GET GETSERV object oGetx1 size 40,80
	oGetx1:SetFocus()

	@ 29,14 SAY "C๓d Carga:    "
	@ 29,68 GET GETCARGA object oGetx2 Size 30,80

	@ 29,120 SAY "C๓d Corredor: "
	@ 29,160 GET GETLOCALIZ object oGetx3 Size 30,50

	@ 45,14 SAY "Executor:    "
	@ 45,68 GET GETEXEC Size 30,80 F3 "ZZA"

	@ 65,140 BMPBUTTON TYPE 1 ACTION OkProcCarga()
	@ 65,173 BMPBUTTON TYPE 2 ACTION Close(oDlg)

	ACTIVATE DIALOG oDlg CENTERED

Return .T.

Static Function OkProcCarga()

	If EMPTY(GETSERV) .Or. EMPTY(GETCARGA) .Or. EMPTY(GETLOCALIZ) .Or. EMPTY(GETEXEC)
		Aviso("T.I. Informa:","Hแ um ou mais campos que estใo em branco!",{"&OK"})
	Else
		Processa({|| AtualCarga() })
	EndIf

	oGetx2:SetFocus()

Return .T.

Static Function AtualCarga()

	cQuery := ""
	cQuery += "     SELECT DB_CARGA, "
	cQuery += "            DB_CDEXEC "

	cQuery += "     FROM " + RetSqlName("SDB") + " SDB "

	cQuery += "     WHERE SDB.DB_SERVIC = '" + GETSERV + "'"
	cQuery += "     AND   SDB.DB_CARGA = '" + GETCARGA + "'"
	cQuery += "     AND   SUBSTRING(SDB.DB_LOCALIZ,1,3) = '" + GETLOCALIZ + "'"

	cQuery += "     AND   SDB.DB_FILIAL = '" + xFilial('SDB') + "'"
	cQuery += "     AND   SDB.D_E_L_E_T_ <> '*' "

	cQuery += "     AND   SDB.DB_ESTORNO = ' ' "

	cQuery := ChangeQuery(cQuery)

    If Select("QRY_SDB") <> 0
       dbSelectArea("QRY_SDB")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SDB"

	if AllTrim(QRY_SDB->DB_CARGA) == ""
		Aviso("T.I. Informa:","Servi็o nใo encontrado!",{"&OK"})
		Return .T.
	EndIf

	if AllTrim(QRY_SDB->DB_CDEXEC) <> ""                  
		Aviso("T.I. Informa:","Jแ foi informado um executor para este servi็o!",{"&OK"})
		Return .T.
	EndIf  

	cQuery2 := ""
	cQuery2 += "     SELECT ZZA_NOME "
	cQuery2 += "     FROM " + RetSqlName("ZZA") 
	cQuery2 += "     WHERE ZZA_COD = '" + GETEXEC + "'"
	cQuery2 += "     AND   ZZA_FILIAL = '" + xFilial('ZZA') + "'"
	cQuery2 += "     AND   D_E_L_E_T_ <> '*' "

	cQuery2 := ChangeQuery(cQuery2)

    If Select("QRY_ZZA") <> 0
       dbSelectArea("QRY_ZZA")
   	   dbCloseArea()
    Endif

	TCQuery cQuery2 NEW ALIAS "QRY_ZZA"

	if AllTrim(QRY_ZZA->ZZA_NOME) == ""
		Aviso("T.I. Informa:","C๓digo de executor invแlido!",{"&OK"})
		Return
	EndIf

    cQuery3 := ""
	cQuery3 += "  UPDATE " + RetSqlName("SDB") + " SET "
	cQuery3 += "  DB_CDEXEC = '" + GETEXEC + "'"

	cQuery3 += "  WHERE DB_SERVIC = '" + GETSERV + "'"
	cQuery3 += "  AND   DB_CARGA = '" + GETCARGA + "'"
	cQuery3 += "  AND   SUBSTRING(DB_LOCALIZ,1,3) = '" + GETLOCALIZ + "'"

	cQuery3 += "  AND   DB_FILIAL = '" + xFilial('SDB') + "'"
	cQuery3 += "  AND   D_E_L_E_T_ <> '*' "

	cQuery3 += "  AND   DB_ESTORNO = ' ' "

	If (TCSQLExec(cQuery3) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	Else
		Aviso("T.I. Informa:","Atualiza็ใo concluํda!",{"&OK"})
//		GETCARGA:=SPACE(06)
		GETLOCALIZ:=SPACE(06)
		GETEXEC:=SPACE(04)
	EndIf

	dbSelectArea("QRY_SDB")
	dbCloseArea()

	dbSelectArea("QRY_ZZA")
	dbCloseArea()

Return