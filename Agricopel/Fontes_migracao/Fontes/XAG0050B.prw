#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0050B
Rotina de CONCILIAÇÃO de arquivo SERASA
Refatoração de "dserasa.prw"
@author Leandro F Silveira
/*/
//-------------------------------------------------------------------
User Function XAG0050B()

	If (ConfPerg())
		Processa( {|| IniProc() }, "Processando arquivo", "Carregando dados para leitura e processamento", .F.)

		MsgInfo("Arquivo de conciliação gerado", "Fim do processamento")
	EndIf

Return()

Static Function ConfPerg()

	Local _aPerg := {}
	Local _cPerg := "XAG0050B"
	Local lRet   := .F.

	AADD(_aPerg,{_cPerg,"01","Destino      ?","mv_ch1","C",50,0,0,"G","","mv_par01","","","","","","","","","","","","","","","DIR"})

	U_CriaPer(_cPerg, _aPerg)

	lRet := Pergunte(_cPerg,.T.)

Return(lRet)

Static Function IniProc()

	Local cArquivo    := MV_PAR01
	Local nQtdeLinhas := QtdeLinhas(cArquivo)

	If (nQtdeLinhas > 0)
		Conciliar(cArquivo, nQtdeLinhas)
	Else
		Alert("Arquivo de concilição vazio ou não existente!")
	EndIf

Return()

Static Function QtdeLinhas(cArquivo)

	Local nHandle := 0
	Local nRet    := 0

	nHandle := Ft_Fuse(cArquivo)

	If nHandle <> -1
   		Ft_FGoTop()
		nRet := FT_FLastRec() -1
		Ft_Fuse()
	EndIf

Return(nRet)

Static Function Conciliar(cArquivo, nQtdeLinhas)

	Local oFWriter   := Nil
	Local oFReader   := Nil
	Local cDataHead  := ""
	Local cLinha     := ""
	Local cDigVerif  := ""
	Local nCount     := 0
	Local nCountProc := 0

	ProcRegua(nQtdeLinhas)

	oFReader := CriarReader(cArquivo)
	oFWriter := CriarWriter(cArquivo)

	While (oFReader:HasLine())
		cLinha := oFReader:GetLine()
		cDigVerif := Substr(cLinha,1,2)

		If (cDigVerif == "00")
			If (Substr(cLinha,37,8) == "CONCILIA")
				cDataHead := Substr(cLinha,45,8)
			Else
				Alert("Arquivo não é de conciliação!") 
				Exit
			EndIf
		Else
			If (cDigVerif == "01")
				cLinha := ProcLinha(cDataHead, cLinha)
			EndIf
		EndIf

		cLinha := AllTrim(cLinha) + CRLF
		oFWriter:Write(cLinha)

		nCount++
		IncProc("Conciliando títulos: [" + cValToChar(nCount) + "/" + cValToChar(nQtdeLinhas) + "]")
	End

	oFReader:Close()
	oFWriter:Close()

Return()

Static Function CriarWriter(cArquivo)

	Local oFile    := Nil
	Local cNomeArq := AllTrim(cArquivo) + ".env"

	oFile := FwFileWriter():New(AllTrim(cNomeArq), .T.)

	If (oFile:Exists())
		oFile:Erase()
	EndIf

	If !(oFile:Create())
		MsgAlert("O arquivo [" + AllTrim(cNomeArq) + "] nao pode ser gerado!","Atencao!")
		Return
	Endif

Return(oFile)

Static Function CriarReader(cArquivo)

	Local oFile := Nil
	Local oRet  := Nil

	oFile := FwFileReader():New(cArquivo)

	If (oFile:Open())
		oRet := oFile
	Else
		Alert("Falha no carregamento do arquivo para conciliação.")
	EndIf

Return(oRet)

Static Function ProcLinha(cDataHead, cLinha)

	Local cRet       := ""
	Local cPref      := ""
	Local cNum       := ""
	Local cParc      := ""
	Local cTitAux    := ""
	Local cInfoAux   := ""
	Local cDataBaixa := ""
	Local nCount     := 0

	cInfoAux := AllTrim(Substr(cLinha,68,32))

	If Empty(cInfoAux)
		cTitAux := Substr(cLinha,19,10)
		cPref   := Substr(cTitAux,1,3)
		cNum    := Substr(cTitAux,4,6)
		cParc   := Substr(cTitAux,10,1)
	Else
		cTitAux := cInfoAux
		cPref   := Substr(cTitAux,1,3)
		cNum    := Substr(cTitAux,4,9)
		cParc   := Substr(cTitAux,13,1)
	EndIf

	cDataBaixa := GetBaixaTit(cDataHead, cPref, cNum, cParc)

	If Empty(cDataBaixa)
		cDataBaixa := Space(8)
	EndIf

	cRet := Substr(cLinha,01,57) + cDataBaixa + Substr(cLinha,66,61)

Return(cRet)

Static Function GetBaixaTit(cDataHead, cPref, cNum, cParc)

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cRet      := ""

	cQuery := " SELECT E1_BAIXA "
	cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK) "
	cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
	cQuery += "   AND E1_PREFIXO = '" + cPref + "' "
	cQuery += "   AND E1_NUM = '" + cNum + "' "
	cQuery += "   AND E1_PARCELA = '" + cParc + "' "
	cQuery += "   AND E1_TIPO = 'NF'"
	cQuery += "   AND E1_BAIXA <= '" + cDataHead + "' "
	cQuery += "   AND E1_BAIXA <> '' "
	cQuery += "   AND D_E_L_E_T_ = '' "

	TCQuery cQuery NEW ALIAS (cAliasQRY)

	Do While !(cAliasQRY)->(Eof())
		cRet := (cAliasQRY)->E1_BAIXA
		(cAliasQRY)->(dbskip())
	EndDo

	(cAliasQRY)->(dbCloseArea())

Return(cRet)