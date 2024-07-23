#Include "rwmake.ch"
#Include "protheus.ch"
#Include "Topconn.ch"

User Function SMSAGR07()

	Local nI          := 0
	Local _cCampo     := ""

	Private nCol 	  := 0
	Private _CPERG    := "SMSAGR07"
	Private cMark     := ""
	Private aBrw 	  := {}
	Private lMarcados := .F.
	Private oMB
	Private aRotina   := {}
	Private xLocaliz  := ""
	Private aCampos   := {}
	Private cAliasSDA := ""
	Private oTmpTable := Nil

	ValPerg(_CPERG)

	If !(Pergunte(_CPERG))
		Return
	Endif

	aRotina   := { { "Confirmar"	,"U_SMS07OK" , 0, 4},;
	               { "Recarregar"   ,"U_SMS07REC" , 0, 4}}

	//Gera Query de dados
	GeraQry()

	//Gera arquivo de Trabalho
	oTmpTable := GeraTRB()
	cAliasSDA := oTmpTable:GetAlias()

	//Grava arquivo de trabalho
	GravaTRB()

	aBRW := {}

	dbSelectArea("SX3")
	dbSetOrder(2)

	For nI := 1 To Len(aCampos)

		_cCampo := Alltrim(aCampos[nI][1])

		If dbSeek(_cCampo)
			If GetSX3Cache(_cCampo, "X3_TITULO") == 'Nome'
				AADD(aBRW,{_cCampo,"",IIF(nI==1,"",PADR(GetSX3Cache(_cCampo, "X3_TITULO"),40)),Trim(GetSX3Cache(_cCampo, "X3_PICTURE"))})
			Else
				AADD(aBRW,{_cCampo,"",IIF(nI==1,"",Trim(GetSX3Cache(_cCampo, "X3_TITULO"))),Trim(GetSX3Cache(_cCampo, "X3_PICTURE"))})
			Endif
		EndIf
	Next

	cMark := GetMark(,cAliasSDA,"DA_OK")
	oMB   := MarkBrow(cAliasSDA,"DA_OK","",aBRW,.F.,cMark,'U_MarkTd()')

	(cAliasSDA)->(DbCloseArea())
	oTmpTable:Delete()
	FreeObj(oTmpTable)

Return()

Static Function GeraTRB()

	Local oTmpTable := Nil

	Aadd(aCampos,{ "DA_OK"		, "C", 02, 0 } )
	Aadd(aCampos,{ "DA_PRODUTO"	, "C", 15, 0 } )
	Aadd(aCampos,{ "DA_LOTECTL"	, "C", 10, 0 } )
	Aadd(aCampos,{ "DA_NUMLOTE"	, "C", 06, 0 } )
	Aadd(aCampos,{ "DA_LOCAL"	, "C", 02, 0 } )
	Aadd(aCampos,{ "DA_DOC"		, "C", 09, 0 } )
	Aadd(aCampos,{ "DA_SERIE"	, "C", 03, 0 } )
	Aadd(aCampos,{ "DA_DATA"	, "D", 08, 0 } )
	Aadd(aCampos,{ "DA_ORIGEM"	, "C", 03, 0 } )
	Aadd(aCampos,{ "RECNO"		, "N", 09, 0 } )

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aCampos)
	oTmpTable:AddIndex("1", {"DA_PRODUTO", "DA_LOCAL"})
	oTmpTable:Create()

Return(oTmpTable)

Static Function LimparTRB()

	Local cQuery := ""

	cQuery := " DELETE FROM " + oTmpTable:GetRealName()

	If TCSqlExec(cQuery) < 0
		Alert(TCSqlError(), "Falha ao carregar dados")
	EndIf

	(oTmpTable:GetAlias())->(DBGoTop())

Return()

Static Function GravaTRB()

	LimparTRB()

	While QRYSMS07->(!EOF())

		Dbselectarea(cAliasSDA)
		Reclock(cAliasSDA,.T.)
		(cAliasSDA)->DA_OK  	 := "  "//QRYSMS07->DA_OK
		(cAliasSDA)->DA_PRODUTO  := QRYSMS07->DA_PRODUTO
		(cAliasSDA)->DA_LOTECTL  := QRYSMS07->DA_LOTECTL
		(cAliasSDA)->DA_NUMLOTE  := QRYSMS07->DA_NUMLOTE
		(cAliasSDA)->DA_LOCAL    := QRYSMS07->DA_LOCAL
		(cAliasSDA)->DA_DOC      := QRYSMS07->DA_DOC
		(cAliasSDA)->DA_SERIE    := QRYSMS07->DA_SERIE
		(cAliasSDA)->DA_DATA     := StoD(QRYSMS07->DA_DATA)
		(cAliasSDA)->DA_ORIGEM   := QRYSMS07->DA_ORIGEM
		(cAliasSDA)->RECNO   	 := QRYSMS07->RECNO

		(cAliasSDA)->(MSUNLOCK())

		QRYSMS07->(dbskip())
	Enddo

	(cAliasSDA)->(DBGOTOP())
Return

User Function MarkTd()

	Local cGravar := "  "

	lMarcados := !lMarcados

	If lMarcados
		cGravar := cMark
	Endif

	(cAliasSDA)->(DBGOTOP())
	While (cAliasSDA)->(!Eof())
		Reclock(cAliasSDA,.F.)
		(cAliasSDA)->DA_OK := cGravar
		(cAliasSDA)->(MSUNLOCK())
		(cAliasSDA)->(Dbskip())
	Enddo

Return

Static function GeraQry()

	Local cQuery := ""

	cQuery := " SELECT DA_PRODUTO,DA_LOTECTL,DA_NUMLOTE,DA_LOCAL,DA_DOC,DA_SERIE,DA_DATA,DA_LOTECTL,DA_ORIGEM, R_E_C_N_O_ AS RECNO "
	cQuery += " FROM "+RetSqlname('SDA')+" (NOLOCK) "
	cQuery += " WHERE "
	cQuery += " D_E_L_E_T_ = '' AND DA_FILIAL = '"+xFilial('SDA')+"' "
	cQuery += " AND DA_SALDO > 0 AND DA_LOCAL = '"+MV_PAR01+"'"
	cQuery += " AND DA_DATA >= '"+DtoS(MV_PAR02)+"' "
	cQuery += " AND DA_DATA <= '"+DtoS(MV_PAR03)+"' "
	cQuery += " ORDER BY DA_DATA "

	If (Select("QRYSMS07") <> 0)
		dbSelectArea("QRYSMS07")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "QRYSMS07"

	dbSelectArea("QRYSMS07")
Return

//Recarrega dados em tela
User Function SMS07REC()

	Pergunte(_CPERG)

	//Gera Query de dados
	GeraQry()

	//Grava arquivo de trabalho
	GravaTRB()

	MarkBRefresh()
Return

//Confirma dados
User Function SMS07OK()

	Local aSMS07Ped := {}

	If !MsgYesNo("Confirma Endereçamento com Data Base: " + DtoC(dDataBase)+" ?")
		Return()
	EndIf

	//Chama Janela para colocar os dados
	If !U_SMS07END()
		Return
	Endif

	Dbselectarea(cAliasSDA)
	(cAliasSDA)->(DbGoTop())

	While (cAliasSDA)->(!Eof())

		If cMark == (cAliasSDA)->DA_OK
			AADD(aSMS07Ped,(cAliasSDA)->RECNO )
		Endif

		(cAliasSDA)->(dbskip())
	Enddo

	If len(aSMS07Ped) > 0

		//Grava TABELA SDA
		GravaSDA(aSMS07Ped)
		U_SMS07REC()

	Else
		Alert('Selecione ao menos um item!')
	Endif

Return

//Grava dados e gera Rotina automática
Static function GravaSDA(xPedG)

	Local aErro    := {}
	Local aGerados := {}
	Local _cDoc    := ""
	Local _cProd   := ""
	Local cMsg     := ""
	Local _lRastro := .F.
	Local i        := 0

	For i := 1 to len(xPedG)

		DbSelectarea('SDA')
		DbsetOrder(1)
		DbGoto(xPedG[i])

		lmsErroAuto := .F.

		aItem := {}

		//DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
		//xLocaliz := cLocaliz
		_cProd   := SDA->DA_PRODUTO
		_cDoc    := SDA->DA_DOC
		_lRastro  := Rastro(SDA->DA_PRODUTO)//_cRastro := POSICIONE('SB1',1,xfilial('SB1')+SDA->DA_PRODUTO,"B1_RASTRO")

		aCab := {{"DA_PRODUTO"	,SDA->DA_PRODUTO,NIL},;
		{"DA_QTDORI"	,SDA->DA_QTDORI	,NIL},;
		{"DA_SALDO"		,SDA->DA_SALDO	,NIL},;
		{"DA_DATA"		,SDA->DA_DATA	,NIL},;
		{"DA_LOTECTL"	,iif(_lRastro, SDA->DA_LOTECTL,""),NIL},;
		{"DA_DOC"		,SDA->DA_DOC	,NIL},;
		{"DA_LOCAL"		,SDA->DA_LOCAL	,NIL},;
		{"DA_ORIGEM"	,SDA->DA_ORIGEM	,NIL},;
		{"DA_NUMSEQ"	,SDA->DA_NUMSEQ	,NIL}}
		//	{"DA_NUMLOTE"	,SDA->DA_NUMLOTE,NIL},;

		nItem := 1

		//Trata itens estornados
		DBSELECTAREA('SDB')
		DBSETORDER(1)
		_cSeek    := xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ+SDA->DA_DOC+SDA->DA_SERIE+SDA->DA_CLIFOR+SDA->DA_LOJA
		if DBSEEK(_cSeek)
			while SBD->(!EOF()) .AND. _cSeek == SDB->DB_FILIAL+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA
				IF SDB->DB_TM <= "500" .And. SDB->DB_TIPO == "D"
					Aadd(aItem, {	{"DB_ITEM"		,StrZero(nItem,4)	,NIL},;
					{"DB_ESTORNO"	,SDB->DB_ESTORNO	,NIL},;
					{"DB_TIPO"		,SDB->DB_TIPO		,NIL},;
					{"DB_LOCAL"		,SDB->DB_LOCAL		,NIL},;
					{"DB_LOCALIZ"	,SDB->DB_LOCALIZ	,NIL},;//{"DB_ESTFIS"	,SBE->BE_ESTFIS		,NIL},;
					{"DB_LOTECTL"	,SDB->DB_LOTECTL	,NIL},;//{"DB_NUMLOTE"	,SDA->DA_NUMLOTE	,NIL},;
					{"DB_QUANT "	,SDB->DB_QUANT      ,NIL},;
					{"DB_DATA"		,SDB->DB_DATA		,NIL}})

					nItem++
				ENDIF
				SDB->(dbskip())
			Enddo
		Endif

		Aadd(aItem, {	{"DB_ITEM"		,StrZero(nItem,4)	,NIL},;
		{"DB_LOCAL"		,SDA->DA_LOCAL		,NIL},;
		{"DB_LOCALIZ"	,xLocaliz			,NIL},;//{"DB_ESTFIS"	,SBE->BE_ESTFIS		,NIL},;
		{"DB_LOTECTL"	,iif(_lRastro, SDA->DA_LOTECTL,"")				,NIL	},;//{"DB_NUMLOTE"	,SDA->DA_NUMLOTE	,NIL},;
		{"DB_QUANT "	,SDA->DA_SALDO      ,NIL},;
		{"DB_DATA"		,ddatabase			,NIL}})

		nItem++

		//{"DB_TIPO"		,'D'				,NIL},;
		//{"DB_NUMSEQ"	,ProxNum()			,NIL},;
		//{"DB_ORIGEM"	,'SD3'				,NIL},;
		//{"DB_ALI_WT"	,"SDB"				,NIL},;
		//{"DB_QUANT"		,nQuant  			,NIL}})

		MSExecAuto({|x,y,z| mata265(x,y,z)},aCab,aItem,3) //Distribui

		If lmsErroAuto
			MostraErro()
			aAdd(aErro,{ _cDoc , _cProd })
		Else
			aAdd(aGerados,{_cDoc , _cProd})
		Endif
	Next i

	//Mensagem de Errados
	If len(aerro) > 0
		cMsg := "Os Itens Abaixo NÃO foram Endereçados: "+chr(10)+chr(13)
	Endif
	For i := 1 to len(aErro)
		cMsg += " Produto: "+alltrim(aErro[i][2])+", Doc: "+alltrim(aErro[i][1])+chr(10)+chr(13)
	Next i
	If alltrim(cMsg) <> ""
		Alert(cMsg)
		cMsg := ""
	Endif

	//Mensagem de Gerados
	If len(aGerados) > 0
		cMsg := "Os Itens Abaixo foram Endereçados COM SUCESSO: "+chr(10)+chr(13)
	Endif
	For i := 1 to len(aGerados)
		cMsg += " Produto: "+alltrim(aGerados[i][2])+", Doc: "+alltrim(aGerados[i][1])+chr(10)+chr(13)
	Next i
	If alltrim(cMsg) <> ""
		MSGINFO(cMsg,"Informacao")
		cMsg := ""
	Endif

Return

//Tela para colocação do endereço e Armazem
User Function SMS07END()

	Local oDlg1
	Local oButton1
	Local oLocaliz
	Local cLocaliz := "               "
	Local oSay2
	Local lRetu := .F.

	DEFINE MSDIALOG oDlg1 TITLE "Informe os Campos" FROM 000, 000  TO 145, 250 COLORS 0, 16777215 PIXEL

	@ 022-10, 011 SAY oSay2 PROMPT "Endereco" SIZE 025, 007 OF oDlg1 COLORS 0, 16777215 PIXEL
	@ 021-10, 043 MSGET oLocaliz VAR cLocaliz SIZE  060, 010 F3 'SBE' OF oDlg1 COLORS 0, 16777215 PIXEL

	@ 056, 067 BUTTON oButton1 PROMPT "Confirmar"  ACTION( lRetu := .T., oDlg1:End() )SIZE 037, 012 OF oDlg1 PIXEL

	ACTIVATE MSDIALOG oDlg1

	If  lRetu
		xLocaliz := cLocaliz
	Else
		xLocaliz  := ""
	Endif

Return lRetu

//Pergunte
Static Function ValPerg(_CPERG)

	PutSx1(_CPERG,"01","Armazem  ","", "", "mv_ch1","C",02,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(_CPERG,'02','Data de  ','', '', 'mv_ch2','D',08,0,0,'G','','','','','mv_par02','','','','','','','','','','','','','','','','','','','')
	PutSx1(_CPERG,'03','Data Até ','', '', 'mv_ch3','D',08,0,0,'G','','','','','mv_par03','','','','','','','','','','','','','','','','','','','')

Return  