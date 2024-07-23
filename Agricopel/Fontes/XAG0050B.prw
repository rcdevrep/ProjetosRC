#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0050B
Rotina chamada através de XAG0050
Gera arquivo para enviar ao SERASA a partir de outro arquivo que vem do SERASA
@author Leandro Silveira
@since 12/12/2019
@version 1
@type function
/*/
User Function XAG0050B()

	Local oProcess := Nil

	Private cArquivo := ""
	Private cDtCorte := "20191115"

	cArquivo := AllTrim(cGetFile("Arquivos SERASA|*.*", "Selecione o arquivo do SERASA para conciliar", 0,"C:\Temp", .T.,GETF_LOCALHARD,.T.))

	If File(cArquivo)
        oProcess := MsNewProcess():New({|lEnd| ProcConcil(@oProcess, @lEnd) },"Processando conciliação","Processando",.T.)
        oProcess:Activate()
	Else
		Alert("Arquivo não encontrado! (" + cArquivo + ")")
	EndIf

Return()

Static Function ProcConcil(oProcess, lEnd)

    Local oArqImp  := Nil

	oProcess:SetRegua1(3)

	oArqImp := ImpArq(@lEnd, oProcess)

	If !Empty(oArqImp)
		If (TratArq(oArqImp, @lEnd, oProcess))
			If GeraArq(oArqImp, @lEnd, oProcess)
				MsgInfo("Processamento finalizado! Arquivo de conciliação gerado em: " + CRLF + cArquivo)
			EndIf
		EndIf

		oArqImp:Delete()
	EndIf

Return(.T.)

Static Function ImpArq(lEnd, oProcess)

	Local nTotal    := 0
    Local nRec      := 0
    Local aImpArq   := {}
    Local oArqImp   := Nil
    Local cAliasArq := ""
	Local cLinha    := ""

	oProcess:IncRegua1("(1/3) - Lendo arquivo do SERASA")

	Aadd(aImpArq,{"INFO", "C", 200, 0})  //INFO
	Aadd(aImpArq,{"REC" , "N", 10 , 0})  //REC
	Aadd(aImpArq,{"REG" , "C", 10 , 0})  //REGISTRO

	oArqImp := FWTemporaryTable():New()

	oArqImp:SetFields(aImpArq)
	oArqImp:AddIndex("IDX1", {"REC"})
	oArqImp:Create()

	cAliasArq := oArqImp:GetAlias()

	If (lEnd)
		oArqImp:Delete()
		Return(Nil)
	EndIf

	FT_FUse(cArquivo)
	nTotal := FT_FLastRec()

	oProcess:SetRegua2(nTotal)

	While !FT_FEof()
		If (lEnd)
			oArqImp:Delete()
			Return(Nil)
		EndIf

		cLinha := FT_FReadLn()

		RecLock(cAliasArq, .T.)
		(cAliasArq)->INFO := cLinha
		(cAliasArq)->REC  := nRec
		(cAliasArq)->REG  := Substr(cLinha,1,2)
		MsUnLock()

		FT_FSkip()
		nRec++

		oProcess:IncRegua2("Processando: " + cValToChar(nRec) + " / " + cValToChar(nTotal))
	EndDo

	FT_FUse()
    (cAliasArq)->(DbGoTop())

Return(oArqImp)

Static Function TratArq(oArqImp, lEnd, oProcess)

	Local nRec       := 0
	Local nTotal     := 0
	Local cDataHead  := ""
	Local cPref      := ""
	Local cNum       := ""
	Local cParc      := ""
	Local cTitAux    := ""
	Local cPrefNovo  := ""
	Local cNumNovo   := ""
	Local cParcNovo  := ""
	Local cDataBaixa := ""
	Local cInfoArq   := ""
	Local cAliasArq  := ""

	cAliasArq  := oArqImp:GetAlias()

	oProcess:IncRegua1("(2/3) - Conciliando informações do arquivo")
	nTotal := (cAliasArq)->(RecCount())
	oProcess:SetRegua2(nTotal)

	DbSelectArea(cAliasArq)
	DbGoTop()
	Do While !Eof()
		If Substr((cAliasArq)->INFO,1,2) == "00" .and. Substr((cAliasArq)->INFO,37,8) <> "CONCILIA"
			Alert("Arquivo não é de conciliação. Verifique.")
			Return(.F.)
		Endif

		If Substr((cAliasArq)->INFO,1,2) == "00"
			cDataHead := Substr((cAliasArq)->INFO,45,8)
		EndIf

		cPref     := ""
		cNum      := ""
		cParc     := ""
		cTitAux   := ""
		cPrefNovo := ""
		cNumNovo  := ""
		cParcNovo := ""

		If Substr((cAliasArq)->INFO,1,2) == "01"

			If AllTrim(Substr((cAliasArq)->INFO,68,32)) == ""
				cTitAux := Substr((cAliasArq)->INFO,19,10)
				cPref := Substr(cTitAux,1,3)//Mantido 3 casas devido que com 5 casas ultrapassa
				//10 caracteres caindo sempre no primeiro IF
				cNum  := Substr(cTitAux,4,6)
				cParc := Substr(cTitAux,10,1)
			EndIf

			If AllTrim(Substr((cAliasArq)->INFO, 68, 32)) <> ""
				cTitAux := Substr((cAliasArq)->INFO, 68, 32)
				cPref := Substr(cTitAux,1,3)
				cNum  := Substr(cTitAux,4,9)
				cParc := Substr(cTitAux,13,1)

				//Variaveis para tiulos com prefixo de 5 posições
				cPrefNovo := Substr(cTitAux,1,5)
				cNumNovo  := Substr(cTitAux,6,9)
				cParcNovo := Substr(cTitAux,15,1)
			EndIf

			//Busco Informacoes do titulo para ver se houve pagamento.
			cDataBaixa := GetDtBaixa(cPref, cNum, cParc, cPrefNovo, cNumNovo, cParcNovo, cDataHead)
			cInfoArq   := Substr((cAliasArq)->INFO, 01, 57) + cDataBaixa + Substr((cAliasArq)->INFO, 66, 61)

			RecLock(cAliasArq, .F.)
			(cAliasArq)->INFO := cInfoArq
			MsUnlock()

			If (lEnd)
				Return(.F.)
			EndIf

		EndIf

		nRec++
		oProcess:IncRegua2("Processando: " + cValToChar(nRec) + " / " + cValToChar(nTotal))

		DbSelectArea(cAliasArq)
		(cAliasArq)->(DbSkip())
	EndDo

Return(.T.)

Static Function GeraArq(oArqImp, lEnd, oProcess)

	Local nTotal    := 0
	Local nRec      := 0
	Local cAliasArq := ""
	Local cLinha    := ""
	Local nStatus   := 0
	Local nHandle   := 0

	nStatus := FRename(cArquivo, cArquivo + "_old" )

	IF nStatus == -1
		MsgStop('Falha ao renomear arquivo antigo! FError: '+ Str(FError(), 4))
		Return(.F.)
	Endif

	If File(cArquivo)
		FErase(cArquivo)
	Endif

	cAliasArq := oArqImp:GetAlias()
	nHandle   := MSFCreate(cArquivo)
	cLinha    := ""

	oProcess:IncRegua1("(3/3) - Escrevendo arquivo conciliado")
	nTotal := (cAliasArq)->(RecCount())
	oProcess:SetRegua2(nTotal)

	DbSelectArea(cAliasArq)
	DbGoTop()
	While !Eof()
		cLinha := AllTrim((cAliasArq)->INFO) + CRLF
		FWrite(nHandle, cLinha, Len(cLinha))
		(cAliasArq)->(Dbskip())

		If (lEnd)
			Return(.F.)
		EndIf

		nRec++
		oProcess:IncRegua2("Processando: " + cValToChar(nRec) + "/" + cValToChar(nTotal))
	EndDo

	FClose(nHandle)

Return(.T.)

Static Function GetDtBaixa(cPref, cNum, cParc, cPrefNovo, cNumNovo, cParcNovo, cDataHead)

	Local cQuery     := ""
	Local cAliasQRY1 := ""
	Local cDataRet   := ""

	cQuery := " SELECT E1_BAIXA "
	cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)"
	cQuery += " WHERE E1_EMISSAO < '" + cDtCorte + "'"
	cQuery += " AND   E1_PREFIXO = '" + cPref + "'"
	cQuery += " AND   E1_NUM = '" + cNum + "'"
	cQuery += " AND   E1_PARCELA = '" + cParc + "'"
	cQuery += " AND   E1_TIPO = 'NF'"
	cQuery += " AND   E1_BAIXA <= '" + cDataHead + "'"
	cQuery += " AND   E1_BAIXA <> ''"
	cQuery += " AND   D_E_L_E_T_ = ''"

	iF !Empty(cNumNovo)
		cQuery += " UNION ALL "

		cQuery += " SELECT E1_BAIXA "
		cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)"
		cQuery += " WHERE E1_EMISSAO >= '" + cDtCorte + "'"
		cQuery += " AND   E1_PREFIXO = '" + cPrefNovo + "'"
		cQuery += " AND   E1_NUM = '" + cNumNovo + "'"
		cQuery += " AND   E1_PARCELA = '" + cParcNovo + "'"
		cQuery += " AND   E1_TIPO = 'NF'"
		cQuery += " AND   E1_BAIXA <= '" + cDataHead + "'"
		cQuery += " AND   E1_BAIXA <> ''"
		cQuery += " AND   D_E_L_E_T_ = ''"
	EndIf

	cAliasQRY1 := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQRY1)

	cDataRet := (cAliasQRY1)->E1_BAIXA
	(cAliasQRY1)->(DbCloseArea())

	If Empty(cDataRet)
		cDataRet := Space(8)
	EndIf

Return(cDataRet)