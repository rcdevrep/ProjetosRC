#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ROTINA DE INTEGRA플O COM DBGINT - BUSCA EMPRESAS PARA INTEGRA플O
*/

/*/{Protheus.doc} AGX635EMP
//ROTINA DE INTEGRA플O COM DBGINT - BUSCA EMPRESAS PARA INTEGRA플O
@author Leandro Silveira
@since 11/09/2017
@version undefined

@type function
/*/
User Function AGX635EMP(xEmp,xFil,xEmpPRT,xFilPRT)

	Local aEmpDePara := {}
	Local cAliasEmp  := "" 
	Default xFil     := ""
	Default xEmp     := "" 
	Default xEmpPRT  := ""  
	Default xFilPRT  := ""
	
	Private cEmpPrt := xEmpPRT     
	Private cFilPrt := xFilPRT

	cAliasEmp  := GetEmpDBGint(xEmp,xFil)
	aEmpDePara := CalcEmpresa(cAliasEmp)

	DbCloseAll()

Return(aEmpDePara)

Static Function GetEmpDBGint(xEmp,xFil)

	Local cAliasEMP := GetNextAlias()
	Local cQuery    := ""

	cQuery += " SELECT "
	cQuery += "    FILIAL.GEN_TABEMP_Codigo as CODEMP, "
	cQuery += "    FILIAL.GEN_TABFIL_Codigo as CODFIL, "
	cQuery += "    FILIAL.GEN_TABFIL_CNPJ   as CNPJFIL "
	cQuery += " FROM GEN_TABFIL FILIAL "
	cQuery += " WHERE FILIAL.GEN_TABFIL_Ativo = 1 " 
	iF !Empty(xEmp)
   		cQuery += " FILIAL.GEN_TABEMP_Codigo = "+xEmp+" " 
   		If!Empty(xFil)
   			cQuery += " FILIAL.GEN_TABFIL_Codigo = "+xFil+" " 
   		Endif
	Endif	
	cQuery += " ORDER BY CODEMP, CODFIL "

	U_AGX635CN("DBG")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), (cAliasEMP), .F., .T.)

Return(cAliasEMP)

Static Function CalcEmpresa(cAliasEmp)

	Local aEmpDePara := {}
	Local aEmpPara   := {}
	Local aSM0Tmp    := {}
	Local nEmpDe     := 0
	Local cEmpCNPJ   := ""

	(cAliasEmp)->(DbGoTop())
	nEmpDe := (cAliasEmp)->(CODEMP)

	U_AGX635CN("PRT")

	While !(cAliasEmp)->(EOF())

		If (nEmpDe <> (cAliasEmp)->(CODEMP))

			If (Len(aEmpPara) > 0)
				aAdd(aEmpDePara, {nEmpDe, aEmpPara})
			EndIf

			aEmpPara := {}
			nEmpDe   := (cAliasEmp)->(CODEMP)
		EndIf

		cEmpCNPJ := (cAliasEmp)->(CNPJFIL)
		cEmpCNPJ := StrTran(cEmpCNPJ, "/", "")
		cEmpCNPJ := StrTran(cEmpCNPJ, "-", "")
		cEmpCNPJ := StrTran(cEmpCNPJ, ".", "")

		aSM0Tmp  := GetSM0(cEmpCNPJ)

		If (Len(aSM0Tmp) == 2)
			aAdd(aEmpPara, {(cAliasEmp)->(CODFIL), aSM0Tmp[1], aSM0Tmp[2]})
		EndIf

		(cAliasEmp)->(DbSkip())
	End

	If (Len(aEmpPara) > 0)
		aAdd(aEmpDePara, {nEmpDe, aEmpPara})
	EndIf

Return(aEmpDePara)

Static Function GetSM0(cCNPJ)

	Local aSM0Tmp   := {}
	Local cQuery    := ""
	Local cAliasSM0 := GetNextAlias()

	cQuery := " SELECT "
	cQuery += "    EMPRESAS.EMP_COD, "
	cQuery += "    EMPRESAS.EMP_FIL "
	cQuery += " FROM EMPRESAS "
	cQuery += " WHERE INTEGRA_DBGINT = 'S' " 
	
	If alltrim(cEmpPrt) <> ""
		cQuery += " AND EMP_COD = '"+cEmpPrt+"' "
	Endif	   
	If alltrim(cFilPrt) <> ""
		cQuery += " AND EMP_FIL = '"+cFilPrt+"' "
	Endif
	//cQuery += " WHERE EMP_COD IN ('01', '11', '15') "
	cQuery += " AND   EMP_CNPJ = '" + AllTrim(cCNPJ) + "'"

	TCQuery cQuery NEW ALIAS (cAliasSM0)

	If !Empty((cAliasSM0)->(EMP_COD)) .And. !Empty((cAliasSM0)->(EMP_FIL))
		aAdd(aSM0Tmp, (cAliasSM0)->(EMP_COD))
		aAdd(aSM0Tmp, (cAliasSM0)->(EMP_FIL))
	EndIf

	(cAliasSM0)->(DbCloseArea())

Return(aSM0Tmp)