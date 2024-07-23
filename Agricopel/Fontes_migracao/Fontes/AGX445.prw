#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User function AGX445()

	cD2_CTRDOC  := ""
	cD2_CTRSERI := ""
	cD2_CTRFILI := ""

	cD2_CTRDOC  := aCols [1, aScan(aHeader,{|x| alltrim(x[2]) == "D2_CTRDOC"})]
	cD2_CTRSERI := aCols [1, aScan(aHeader,{|x| alltrim(x[2]) == "D2_CTRSERI"})]
	cD2_CTRFILI := aCols [1, aScan(aHeader,{|x| alltrim(x[2]) == "D2_CTRFILI"})]

	if (cD2_CTRDOC <> "") .And. (cD2_CTRSERI <> "") .And. (cD2_CTRFILI <> "")

		cQuery := ""
		cQuery += " SELECT A1_NOME, "
		cQuery += " 	   A1_LOJA, "
		cQuery += " 	   F2_VALMERC, "
		cQuery += " 	   F2_EMISSAO "

		cQuery += " FROM SF2020 SF2, SA1020 SA1 "

		cQuery += " WHERE F2_DOC = '" + cD2_CTRDOC + "'"
		cQuery += " AND   F2_SERIE = '" + cD2_CTRSERI + "'"
		cQuery += " AND   F2_FILIAL = '" + cD2_CTRFILI + "'"

		cQuery += " AND   SF2.D_E_L_E_T_ <> '*' "

		cQuery += " AND   A1_COD = F2_CLIENTE "
		cQuery += " AND   A1_LOJA = F2_LOJA "

		cQuery := ChangeQuery(cQuery)

	    If Select("QRY_SF2") <> 0
	       dbSelectArea("QRY_SF2")
	   	   dbCloseArea()
	    Endif

		TCQuery cQuery NEW ALIAS "QRY_SF2"
		TCSetField("QRY_SF2", "F2_EMISSAO", "D", 08, 0)

		If AllTrim(QRY_SF2->A1_NOME) <> ""

		    cMensagem := "Dados da Nota fiscal informada: " + Chr(13) + Chr(10)
			cMensagem += "Cliente: " + Chr(9) + Chr(9) + AllTrim(QRY_SF2->A1_LOJA) + "-" + AllTrim(QRY_SF2->A1_NOME)+ Chr(13) + Chr(10)
			cMensagem += "Valor:   " + Chr(9) + Chr(9) + AllTrim(Transform(QRY_SF2->F2_VALMERC,"@E 999,999.99"))    + Chr(13) + Chr(10)
			cMensagem += "Data de Emissão:  " + Chr(9) + DTOS(QRY_SF2->F2_EMISSAO)
                 
			ALERT(cMensagem)
		Else
			ALERT("Nota fiscal não encontrada!")
		EndIf

		dbSelectArea("QRY_SF2")
		dbCloseArea()

	EndIf

Return(cD2_CTRFILI)