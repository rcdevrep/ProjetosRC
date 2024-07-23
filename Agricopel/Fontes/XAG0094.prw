#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} XAG0094
//ROTINA PARA ALTERAR O CAMPO PREFIXO NO FATURAMENTO
@author groundwork
@since 05/11/2022
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/


User Function XAG0094()

	Local cPrefx  := ""
	Local cQuery  := ""
	Local cAlias  := GetNextAlias()
	Local cSerie  := ""


	do Case
	Case Alltrim(SM0->M0_CODFIL) == "01"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"A"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "02"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"B"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "03"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"C"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "04"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"D"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "05"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"E"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "06"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"F"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "07"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"G"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "08"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"H"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "09"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"I"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "10"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"J"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "11"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"K"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "12"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"L"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "13"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"M"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "14"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"N"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "15"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"O"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "16"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"P"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "17"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"Q"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "18"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"R"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "19"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"S"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "20"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"T"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "21"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"U"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "22"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"V"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "23"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"W"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "24"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"X"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "25"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"Y"+SF2->F2_SERIE)
	Case Alltrim(SM0->M0_CODFIL) == "26"
		cPrefx := IIF(LEN(ALLTRIM(SF2->F2_SERIE))=3,SF2->F2_SERIE,"Z"+SF2->F2_SERIE)
	EndCase

	cQuery := " SELECT E1_SERIE,E1_CLIENTE,E1_LOJA,E1_MSFIL FROM "+RetSqlName("SE1")+"  WITH(NOLOCK) WHERE E1_NUM = '"+Alltrim(SF2->F2_DOC)+"' AND D_E_L_E_T_ = '' AND E1_PREFIXO = '"+Alltrim(cPrefx)+"' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)

	If (cAlias)->(!EOF())

		do Case
		Case (cAlias)->E1_MSFIL == "01"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"A"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "02"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"B"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "03"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"C"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "04"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"D"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "05"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"E"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "06"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"F"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "07"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"G"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "08"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"H"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "09"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"I"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "10"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"J"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "11"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"K"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "12"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"L"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "13"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"M"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "14"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"N"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "15"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"O"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "16"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"P"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "17"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"Q"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "18"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"R"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "19"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"S"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "20"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"T"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "21"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"U"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "22"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"V"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "23"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"W"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "24"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"X"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "25"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"Y"+(cAlias)->E1_SERIE)
		Case (cAlias)->E1_MSFIL == "26"
			cSerie := IIF(LEN(ALLTRIM((cAlias)->E1_SERIE))=3,(cAlias)->E1_SERIE,"Z"+(cAlias)->E1_SERIE)
		EndCase

		cQry := " UPDATE "+RetSqlName("SE1")+" SET E1_PREFIXO = '"+cSerie+"' WHERE E1_NUM = '"+Alltrim(SF2->F2_DOC)+"' AND D_E_L_E_T_ = '' AND E1_PREFIXO = '"+Alltrim(cPrefx)+"' AND E1_CLIENTE = '"+(cAlias)->E1_CLIENTE+"' AND E1_LOJA = '"+(cAlias)->E1_LOJA+"' "
		TcSqlExec(cQry)

		cQry := " UPDATE "+RetSqlName("SE5")+" SET E5_PREFIXO = '"+cSerie+"' WHERE E5_NUMERO = '"+Alltrim(SF2->F2_DOC)+"' AND D_E_L_E_T_ = '' AND E5_PREFIXO = '"+Alltrim(cPrefx)+"' AND E5_CLIFOR = '"+(cAlias)->E1_CLIENTE+"' AND E5_LOJA = '"+(cAlias)->E1_LOJA+"' "
		TcSqlExec(cQry)

		cQry := " UPDATE "+RetSqlName("SF2")+" SET F2_PREFIXO = '"+cSerie+"' WHERE F2_DOC = '"+Alltrim(SF2->F2_DOC)+"' AND D_E_L_E_T_ = '' AND F2_PREFIXO = '"+Alltrim(cPrefx)+"' AND F2_CLIENTE = '"+(cAlias)->E1_CLIENTE+"' AND F2_LOJA = '"+(cAlias)->E1_LOJA+"' "
		TcSqlExec(cQry)

	endif

Return cPrefx
