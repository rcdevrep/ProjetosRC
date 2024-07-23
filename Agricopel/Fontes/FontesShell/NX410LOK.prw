#Include "rwmake.ch"

//User Function M410LIOK()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Função (PE) de M410LIOK p/ NX410LOK, e criado a chamada deste PE dentro do PE M410LIOK original da Shell.³
//³ATENÇÃO: Este PE somente é chamado caso as validações do PE M410LIOK, padrões da Shell, retornem Verdadeiro.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function NX410LOK()

	Private cAliaAnte, nAreaAnte,nRegiAnte, nTES, _TES, nTIPBON, _TIPBON, cTexto, nNotaOrig, _NotaOrig, nSerieOrig, _SerieOrig
	Private nCodPro, _CodPro, nItemOri, _ItemOri
	Private nPosProduto, nPosPerDesc, nPosPrUnit, nPosPrcVen, nPosBlDesc, nPosPrUnit2, nTipoBonif
	Private nRetorno := .T.

	cAliaAnte := Alias()
	nAreaAnte := IndexOrd()
	nRegiAnte := RecNo()

	// Se a empresa for diferente de 44- farol , retorna true

	If cEmpAnt <> "44"
		Return(.t.)
	EndIf

	nPosProduto := aScan(aHeader,{|COLUNA| AllTrim(Upper(COLUNA[2]))=="C6_PRODUTO" })
	nPosPerDesc := aScan(aHeader,{|COLUNA| AllTrim(Upper(COLUNA[2]))=="C6_PERDESC" })
	nPosPrUnit := aScan(aHeader,{|COLUNA| AllTrim(Upper(COLUNA[2]))=="C6_PRUNIT" })
	nPosPrcVen := aScan(aHeader,{|COLUNA| AllTrim(Upper(COLUNA[2]))=="C6_PRCVEN" })
	//nPosBlDesc := aScan(aHeader,{|COLUNA| AllTrim(Upper(COLUNA[2]))=="C6_BLDESC" })
	//nPosPrUnit2 := aScan(aHeader,{|COLUNA| AllTrim(Upper(COLUNA[2]))=="C6_PRUNIT2" })
	//ipoBonif := aScan(aHeader,{|COLUNA| AllTrim(Upper(COLUNA[2]))=="C6_TIPOBON" })

	If ACOLS[N,LEN(ACOLS[N])] // Entra se a linha estiver apagada

		nRetorno := .T.
		dbSelectArea(cAliaAnte)
		dbSetOrder(nAreaAnte)
		dbGoTo(nRegiAnte)
		Return(nRetorno)
	EndIf

	//nTIPBON := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_TIPOBON"})
	//_TIPBON := aCols[n,nTIPBON]

	nTES     := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_TES"})
	_TES := aCols[n,nTES]

	cCodPro := aCols[n,nPosProduto]

	nPreList := aCols[n,nPosPrUnit]
	nPreVen  := aCols[n,nPosPrcVen]

	If alltrim(cCodPro) == "000001" .or. alltrim(cCodPro) == "000002"
		Return(.T.)
	EndIf

	If nPreList  == 0
		Alert("Atenção! Produto sem preço de tabela! Verifique a condição de pagamento e tabela de preço!")
		Return(.f.)
	EndIf

	If nPreVen < nPreList
		nPerc := 0

		nPerc := 100- ROUND(((nPreVen * 100)/nPreList),2)

		//	aCols[n,nPosPerDesc] :=  nPerc

		If nPerc > SA1->A1_MAXDESC
			Alert("Atenção! Desconto acima do permitido! Máximo " + alltrim(str(SA1->A1_MAXDESC)) + "%")
			lRet := .f.
			Return(lRet)
		EndIf
	EndIf

	dbSelectArea(cAliaAnte)
	dbSetOrder(nAreaAnte)
	dbGoTo(nRegiAnte)
Return(nRetorno)

