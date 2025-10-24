#include 'protheus.ch'
#include 'topconn.ch'
#include 'parmtype.ch'

user function XADTBCO(cTab)
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local cBco		:= ""

	cQuery := "SELECT * FROM "+RETSQLNAME("SA6")+" WHERE "
	cQuery += "D_E_L_E_T_ = '' AND "
	if cTab == "CNX"
		cQuery += "A6_FILIAL = '"+XFILIAL("SA6")+"' AND "
	Elseif cTab == "ZZ0"
		cQuery += "A6_FILIAL = '"+Substr(aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'ZZ0_FILDES'})],1,2)+"' AND "
	EndIf

	cQuery += "A6_XADTGCT = 'S'"
	TCQuery cQuery NEW ALIAS (cAlias)

	if !(cAlias)->(Eof())
		if (cAlias)->A6_BLOCKED == '1'
			Aviso("Conta","O Banco/Agencia/Conta "+(cAlias)->A6_COD+"/"+(cAlias)->A6_AGENCIA+"/"+(cAlias)->A6_NUMCON+" está bloqueado para uso. Contatar o Financeiro.",{"OK"})
			(cAlias)->(dbCloseArea())
			RestArea(aArea)
			Return(cBco)
		EndIf

		SA6->(dbSetOrder(1))
		SA6->(dbSeek((cAlias)->(A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON)))

		if cTab == "CNX"
			FWFldPut("CNX_BANCO" ,(cAlias)->A6_COD)
			FWFldPut("CNX_AGENCI",(cAlias)->A6_AGENCIA)
			FWFldPut("CNX_CONTA" ,(cAlias)->A6_NUMCON)
		Elseif cTab == "ZZ0"
			acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'ZZ0_BANCO'})] := (cAlias)->A6_COD 
			acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'ZZ0_AGENCI'})] := (cAlias)->A6_AGENCIA
			acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'ZZ0_CONTA'})] := (cAlias)->A6_NUMCON
		EndIf
		cBco := (cAlias)->A6_COD
	Else
		Aviso("Conta","Não há Banco/Agencia/Conta definido para uso em Adiantamento de Contratos. Contatar o Financeiro.",{"OK"})
		(cAlias)->(dbCloseArea())
		RestArea(aArea)
		Return(cBco)
	EndIf

	(cAlias)->(dbCloseArea())
	RestArea(aArea)

return(cBco)

User Function xPcoEncMed(nOpc)
	Local aArea		:= GetArea()
	Local xRet		:= ""
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local lCNX		:= .T.
	Local nVrMed	:= 0
	Local cFornec	:= CND->CND_FORNEC
	Local cLojaFor	:= CND->CND_LJFORN

	If Empty(cFornec)
		CXN->(DbSetOrder(1))
		CXN->(DBSeek(CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED)))

		While !CXN->(Eof()) .And.;
			CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED) == CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED)

			If CXN->CXN_CHECK
				cFornec		:= CXN->CXN_FORNEC
				cLojaFor	:= CXN->CXN_LJFORN

				Exit
			EndIf			
			
			CXN->(DBSkip())
		EndDo
	EndIf

	if !(nOpc == 4) .And. !(nOpc == 5) .And. !(nOpc == 6) //Não é Valor

		cQuery := "SELECT Z7_ORCAMEN,CNX_XCC,CNX_XITEMC FROM "+RETSQLNAME("CNX")+" CNX, "
		cQuery += RETSQLNAME("CZY")+" CZY, "+RETSQLNAME("SZ7")+" SZ7  WHERE "
		cQuery += "CNX.D_E_L_E_T_ = '' AND CZY.D_E_L_E_T_ = '' AND SZ7.D_E_L_E_T_ = '' AND "
		cQuery += "CNX_FILIAL = '"+XFILIAL("CNX")+"' AND CZY_FILIAL = '"+cFilAnt+"' AND Z7_FILIAL = '"+XFILIAL("SZ7")+"' AND "
		cQuery += "CZY_CONTRA = CNX_CONTRA AND CZY_REVISA = CNX_REVGER AND CZY_NUMERO = CNX_NUMERO AND "
		cQuery += "CZY_CONTRA = '"+CND->CND_CONTRA+"' AND "
		cQuery += "CZY_REVISA = '"+CND->CND_REVISA+"' AND CZY_NUMMED = '"+CND->CND_NUMMED+"' AND "
		cQuery += "CZY_NUMPLA = '"+CND->CND_NUMERO+"' AND "
		cQuery += "CNX_FORNEC = '"+cFornec+"' AND CNX_LJFORN = '"+cLojaFor+"' AND "
		cQuery += "Z7_NATUREZ = CNX_XNATUR AND Z7_CC = CNX_XCC AND Z7_TPOPER = CNX_XITEMC"
		TCQuery cQuery NEW ALIAS (cAlias)

		if (cAlias)->(Eof())
			lCNX := .F.
			(cAlias)->(dbCloseArea())

			cQuery := "SELECT Z7_ORCAMEN,ZZ0_CC,ZZ0_ITEMC FROM "+RETSQLNAME("ZZ0")+" ZZ0, "
			cQuery += RETSQLNAME("ZZ1")+" ZZ1, "+RETSQLNAME("SZ7")+" SZ7  WHERE "
			cQuery += "ZZ0.D_E_L_E_T_ = '' AND ZZ1.D_E_L_E_T_ = '' AND SZ7.D_E_L_E_T_ = '' AND "
			cQuery += "Z7_FILIAL = '"+XFILIAL("SZ7")+"' AND "
			cQuery += "ZZ1_CONTRA = ZZ0_CONTRA AND ZZ1_REVISA = ZZ0_REVISA AND ZZ1_NUMERO = ZZ0_NUMERO AND "
			cQuery += "ZZ1_CONTRA = '"+CND->CND_CONTRA+"' AND "

			//Comentado para que contratos revisados possam ter seus lançamentos realizados no PCO
//			cQuery += "ZZ1_REVISA = '"+CND->CND_REVISA+"'  "
//			cQuery += "ZZ1_NUMPLA = '"+CND->CND_NUMERO+"' AND "
			cQuery += "ZZ1_NUMMED = '"+CND->CND_NUMMED+"' AND "
			cQuery += "ZZ0_FORNEC = '"+cFornec+"' AND ZZ0_LOJA = '"+cLojaFor+"' AND "
			cQuery += "Z7_NATUREZ = ZZ0_NATURE AND Z7_CC = ZZ0_CC AND Z7_TPOPER = ZZ0_ITEMC"
			TCQuery cQuery NEW ALIAS (cAlias)

			if (cAlias)->(Eof())
				(cAlias)->(dbCloseArea())
				RestArea(aArea)			
				Return(xRet)
			EndIf
		EndIf
	EndIF

	if nOpc == 1 //CO
		xRet := (cAlias)->Z7_ORCAMEN
	EndIF

	if nOpc == 2 //CC
		if lCNX
			xRet := (cAlias)->CNX_XCC
		Else
			xRet := (cAlias)->ZZ0_CC
		EndIf
	EndIF

	if nOpc == 3 //TpOper
		if lCNX
			xRet := (cAlias)->CNX_XITEMC
		Else
			xRet := (cAlias)->ZZ0_ITEMC
		EndIf
	EndIF

	if nOpc == 4 //Valor

		//Se for Processo Invertido (PM) não tem lançamento no encerramento da mediçao

		cQuery := "SELECT CNE_XNF FROM "+RETSQLNAME("CNE")+" WHERE D_E_L_E_T_ = '' AND CNE_FILIAL = '"+XFILIAL("CNE")+"' AND "
		cQuery += "CNE_CONTRA = '"+CND->CND_CONTRA+"' AND CNE_REVISA = '"+CND->CND_REVISA+"' AND "
		cQuery += "CNE_NUMMED = '"+CND->CND_NUMMED+"' AND CNE_NUMERO = '"+CND->CND_NUMERO+"' AND CNE_XNF <> ''"
		TCQuery cQuery NEW ALIAS (cAlias)

		if !(cAlias)->(Eof())
			xRet := 0
			(cAlias)->(dbCloseArea())
			RestArea(aArea)
			Return(xRet)
		EndIF

		(cAlias)->(dbCloseArea())

		cQuery := "SELECT ISNULL(SUM(CZY_VALOR),0) VLRADT FROM "+RETSQLNAME("CZY")+" WHERE D_E_L_E_T_ = '' AND "
		cQuery += "CZY_FILIAL = '"+cFilAnt+"' AND CZY_CONTRA = '"+CND->CND_CONTRA+"' AND "
		cQuery += "CZY_REVISA = '"+CND->CND_REVISA+"' AND CZY_NUMMED = '"+CND->CND_NUMMED+"' AND "
		cQuery += "CZY_NUMPLA = '"+CND->CND_NUMERO+"'
		TCQuery cQuery NEW ALIAS (cAlias)

		if !(cAlias)->(Eof()) .And. ((cAlias)->VLRADT > 0)
			xRet := (cAlias)->VLRADT
		Else
			(cAlias)->(dbCloseArea())
			cQuery := "SELECT ISNULL(SUM(ZZ1_VLCOMP),0) VLRADT FROM "+RETSQLNAME("ZZ1")+" WHERE D_E_L_E_T_ = '' AND "
			cQuery += "ZZ1_FILIAL = '"+XFILIAL("ZZ1")+"' AND ZZ1_CONTRA = '"+CND->CND_CONTRA+"' AND "
			cQuery += "ZZ1_NUMMED = '"+CND->CND_NUMMED+"' "

			//Comentado para desconsiderar a planilha e a revisão, pois o numero da medição é compartilhado e
			//é caso seja realizada uma revisão em um contrato o sistema não se perde.
			//cQuery += "ZZ1_REVISA = '"+CND->CND_REVISA+"' AND "
			//cQuery += "ZZ1_NUMPLA = '"+CND->CND_NUMERO+"'

			TCQuery cQuery NEW ALIAS (cAlias)
			if !(cAlias)->(Eof())
				xRet := (cAlias)->VLRADT
			Else
				xRet := 0
			EndIf
		EndIF

	EndIf

	if nOpc == 5 //Valor Na Nota Fiscal

		cQuery := "SELECT CND_VLTOT "
		cQuery += " FROM "+RETSQLNAME("CND")+" CND "
		cQuery += "   LEFT JOIN "+RETSQLNAME("SC7")+" SC7 ON (CND_FILIAL = C7_FILIAL AND CND_CONTRA = C7_CONTRA AND CND_NUMMED = C7_MEDICAO) "
		cQuery += " WHERE CND.D_E_L_E_T_ = '' "
		cQuery += "   AND SC7.D_E_L_E_T_ = '' "
		cQuery += "   AND SC7.C7_FILIAL = '"+SD1->D1_FILIAL+"' AND SC7.C7_NUM = '"+SD1->D1_PEDIDO+"' "
		cQuery += "   AND SC7.C7_ITEM = '"+SD1->D1_ITEMPC+"'"
		TCQuery cQuery NEW ALIAS (cAlias)

		if !(cAlias)->(Eof())
			nVrMed := (cAlias)->CND_VLTOT
		EndIF

		(cAlias)->(dbCloseArea())


		cQuery := "SELECT CND_RETCAC "
		cQuery += " FROM "+RETSQLNAME("CND")+" CND "
		cQuery += "   LEFT JOIN "+RETSQLNAME("SC7")+" SC7 ON (CND_FILIAL = C7_FILIAL AND CND_CONTRA = C7_CONTRA AND CND_NUMMED = C7_MEDICAO) "
		cQuery += "   LEFT JOIN "+RETSQLNAME("CXN")+" CXN ON (CXN_FILIAL = C7_FILIAL AND CXN_CONTRA = C7_CONTRA AND CXN_NUMMED = C7_MEDICAO) "
		cQuery += " WHERE CND.D_E_L_E_T_ = '' "
		cQuery += "   AND CXN.D_E_L_E_T_ = '' "
		cQuery += "   AND SC7.D_E_L_E_T_ = '' "
		cQuery += "   AND SC7.C7_FILIAL = '"+SD1->D1_FILIAL+"' AND SC7.C7_NUM = '"+SD1->D1_PEDIDO+"' "
		cQuery += "   AND SC7.C7_ITEM = '"+SD1->D1_ITEMPC+"'"
		TCQuery cQuery NEW ALIAS (cAlias)

		if !(cAlias)->(Eof())
			nVrMed += (cAlias)->CND_RETCAC
		EndIF

		(cAlias)->(dbCloseArea())


		cQuery := " SELECT ISNULL(SUM(ZZ1_VLCOMP),0) VLRADT "
		cQuery += " FROM "+RETSQLNAME("ZZ1")+" ZZ1 "
		cQuery += "   LEFT JOIN "+RETSQLNAME("SC7")+" SC7 ON (ZZ1_FILIAL = C7_FILIAL AND ZZ1_CONTRA = C7_CONTRA AND ZZ1_NUMMED = C7_MEDICAO) "
		cQuery += " WHERE ZZ1.D_E_L_E_T_ = '' "
		cQuery += "   AND SC7.D_E_L_E_T_ = '' "
		cQuery += "   AND SC7.C7_FILIAL = '"+SD1->D1_FILIAL+"' AND SC7.C7_NUM = '"+SD1->D1_PEDIDO+"' AND SC7.C7_ITEM = '"+SD1->D1_ITEMPC+"' "

		TCQuery cQuery NEW ALIAS (cAlias)
		if !(cAlias)->(Eof()) .And. nVrMed > 0
			xRet := (cAlias)->VLRADT * ( SD1->((D1_TOTAL+D1_VALIPI+D1_ICMSRET) - D1_DESC) / nVrMed )
		Else
			xRet := 0
		EndIf

	EndIf

	if nOpc == 6 //Valor do Pedido

		//Se for Processo Invertido (PM) não tem lançamento no encerramento da mediçao

		cQuery := "SELECT CNE_XNF FROM "+RETSQLNAME("CNE")+" WHERE D_E_L_E_T_ = '' AND CNE_FILIAL = '"+XFILIAL("CNE")+"' AND "
		cQuery += "CNE_CONTRA = '"+CND->CND_CONTRA+"' AND CNE_REVISA = '"+CND->CND_REVISA+"' AND "
		cQuery += "CNE_NUMMED = '"+CND->CND_NUMMED+"' AND CNE_NUMERO = '"+CND->CND_NUMERO+"' AND CNE_XNF <> ''"
		TCQuery cQuery NEW ALIAS (cAlias)

		if !(cAlias)->(Eof())
			xRet := 0
			(cAlias)->(dbCloseArea())
			RestArea(aArea)
			Return(xRet)
		EndIF

		(cAlias)->(dbCloseArea())

		cQuery := "SELECT ISNULL(SUM(CZY_VALOR),0) VLRADT FROM "+RETSQLNAME("CZY")+" WHERE D_E_L_E_T_ = '' AND "
		cQuery += "CZY_FILIAL = '"+cFilAnt+"' AND CZY_CONTRA = '"+CND->CND_CONTRA+"' AND "
		cQuery += "CZY_REVISA = '"+CND->CND_REVISA+"' AND CZY_NUMMED = '"+CND->CND_NUMMED+"' AND "
		cQuery += "CZY_NUMPLA = '"+CND->CND_NUMERO+"'
		TCQuery cQuery NEW ALIAS (cAlias)

		if !(cAlias)->(Eof()) .And. ((cAlias)->VLRADT > 0)
			xRet := (cAlias)->VLRADT
		Else
			(cAlias)->(dbCloseArea())
			cQuery := "SELECT ISNULL(SUM(ZZ1_VLCOMP),0) VLRADT FROM "+RETSQLNAME("ZZ1")+" WHERE D_E_L_E_T_ = '' AND "
			cQuery += "ZZ1_FILIAL = '"+XFILIAL("ZZ1")+"' AND ZZ1_CONTRA = '"+CND->CND_CONTRA+"' AND "
			cQuery += "ZZ1_REVISA = '"+CND->CND_REVISA+"' AND ZZ1_NUMMED = '"+CND->CND_NUMMED+"' AND "
			cQuery += "ZZ1_NUMPLA = '"+CND->CND_NUMERO+"'
			TCQuery cQuery NEW ALIAS (cAlias)
			if !(cAlias)->(Eof())
				xRet := (cAlias)->VLRADT * ( ((SC7->C7_TOTAL+SC7->C7_VALIPI+SC7->C7_ICMSRET) - SC7->C7_VLDESC) / CND->CND_VLTOT )
			Else
				xRet := 0
			EndIf
		EndIF

	EndIf

	(cAlias)->(dbCloseArea())
	RestArea(aArea)

Return(xRet)


User Function xMedComp()

Local nret 		 	:=  0
Local aGetArea17 	:= getarea()
Local cQry	   		:= ""
Local aTipos   		:= {"NF "}
Local CNFISCAL 		:= SUBSTR(STRLCTPAD,4,9)
LOCAL CSERIE   		:= SUBSTR(STRLCTPAD,1,3)
LOCAL CA100FOR 		:= SUBSTR(STRLCTPAD,18,6)
LOCAL CLOJA    		:= SUBSTR(STRLCTPAD,24,2)
Local aNF 			:= {}
Local aPA	 		:= {}
Local aValCmp		:= {}
Local nY		



		cQry := " SELECT TOP 1 "
		cQry += " E2_TIPO TIPO, R_E_C_N_O_ R_E_C_N_O_NF,E2_VALOR VALOR, '0' ZZ1RECNO "
		cQry += " FROM "+RetSqlName("SE2")+" SE2"
		cQry += " WHERE SUBSTRING(E2_FILIAL,1,2) = '"+substring(cFilAnt,1,2)+"'"
		cQry += " AND E2_NUM      = '"+CNFISCAL+"'"
		cQry += " AND E2_PREFIXO  = '"+CSERIE+"'"
		cQry += " AND E2_FORNECE  = '"+CA100FOR+"'"
		cQry += " AND E2_LOJA     = '"+CLOJA+"'"
		cQry += " AND E2_ORIGEM   = 'MATA100'"
		cQry += " AND E2_TIPO IN (?)"
		cQry += " AND SE2.D_E_L_E_T_ = ''"
		cQry += " UNION ALL "

		cQry += "SELECT DISTINCT "
		cQry += "E2_TIPO TIPO, SE2.R_E_C_N_O_ R_E_C_N_O_A,ZZ1_VLCOMP VALOR,  ZZ1.R_E_C_N_O_ ZZ1RECNO "
		cQry += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("SC7")+" SC7, "+RETSQLNAME("ZZ0")+" ZZ0, "+RETSQLNAME("ZZ1")+" ZZ1, "+RETSQLNAME("SD1")+" SD1 "
		cQry += "WHERE "
		cQry += "SE2.D_E_L_E_T_ = '' AND SC7.D_E_L_E_T_ = '' AND ZZ0.D_E_L_E_T_ = '' AND ZZ1.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND "

		cQry += "E2_FILIAL = ZZ0_FILDES AND SUBSTRING(C7_FILENT,1,2) = '"+SUBSTRING(cFilAnt,1,2)+"' AND ZZ1_FILDES = ZZ0_FILDES AND "
		cQry += "SUBSTRING(D1_FILIAL,1,2) = '"+SUBSTRING(cFilAnt,1,2)+"' AND " // ZZ1_FILIAL = '"+XFILIAL("ZZ1")+"' AND "

		cQry += "D1_DOC = '"+CNFISCAL+"' AND D1_SERIE = '"+CSERIE+"' AND D1_FORNECE = '"+CA100FOR+"' AND D1_LOJA = '"+CLOJA+"' AND "
		cQry += "C7_ITEM = D1_ITEMPC AND C7_NUM = D1_PEDIDO AND C7_FORNECE = D1_FORNECE AND C7_LOJA = D1_LOJA AND C7_PRODUTO = D1_COD AND "
		//cQry += "C7_CONTRA = ZZ0_CONTRA AND ZZ0_REVISA = C7_CONTREV AND C7_FORNECE = ZZ0_FORNEC AND C7_LOJA = ZZ0_LOJA AND "
		cQry += "C7_CONTRA = ZZ0_CONTRA AND "
		cQry += "C7_MEDICAO = ZZ1_NUMMED AND "
//		cQry += "C7_PLANILH = ZZ1_NUMPLA AND "
		cQry += "ZZ1_CONTRA = C7_CONTRA AND ZZ1_REVISA = ZZ0_REVISA AND ZZ0_NUMERO = ZZ1_NUMERO AND "
		cQry += "E2_XCHVZZ0 = ZZ0_CONTRA+ZZ0_REVISA+SUBSTRING(ZZ0_FILIAL,1,2)+ZZ0_NUMERO "
		cQry += "AND ZZ1_NFHOLD = ' ' "
		cQry += "ORDER BY R_E_C_N_O_NF"

		cQry := ChangeQuery(cQry)
		__COMPAUT := FWPreparedStatement():New(cQry)

		__COMPAUT:SetIn(1, aTipos)
		cQry := __COMPAUT:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)

		While (cTblTmp)->(!Eof())
			If ((cTblTmp)->TIPO $ "PA ")
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aPA, {(cTblTmp)->R_E_C_N_O_NF})
					aAdd(aValCmp,{(cTblTmp)->VALOR,(cTblTmp)->ZZ1RECNO})
				EndIf
			Else
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aNF, (cTblTmp)->R_E_C_N_O_NF)
				EndIf
			EndIf

			(cTblTmp)->(DbSkip())
			lRet := .T.
		EndDo
	
	nret := 0
	For nY := 1 to Len(aPA)
		nret += aValCmp[nY][1]
	Next nY

	Restarea(aGetArea17)

Return nret

