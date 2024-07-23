#INCLUDE "TOPCONN.CH"

/*         \

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGR202   บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de Aprovacao ou Cancelamento de orcamentos que    บฑฑ
ฑฑบ    .     ณ nao passaram na analise de rentabilidade.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AGR202()
	********************
	PRIVATE cFiltro  	:= ""
	PRIVATE cCadastro := OemToAnsi("Manutencao de Orcamentos")
	PRIVATE aRotina	:= {}

	PRIVATE aStru := SUA->(dbStruct()), ni


	SetPrvt("cFormPg,cGrupo,nFaixa,cRegra")


	cFormPg := "  "
	cGrupo  := "    "
	nFaixa  := 0.00
	cRegra  := "N"


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ AJUSTE NO SX1                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPerg := "AGR202"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Atendimento De  ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Atendimento Ate ?","mv_ch2","C",06,0,0,"G","","mv_par02","","ZZZZZZ","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Emissao De      ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Emissao Ate     ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Cliente De      ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"06","Cliente Ate     ?","mv_ch6","C",06,0,0,"G","","mv_par06","","ZZZZZZ","","","","","","","","","","","","","SA1"})
	AADD(aRegistros,{cPerg,"07","Loja De         ?","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Loja Ate        ?","mv_ch8","C",02,0,0,"G","","mv_par08","","ZZ","","","","","","","","","","","","",""})

	S202CriaPerguntas(cPerg, aRegistros)

	If	!Pergunte(cPerg,.T.)
		return
	Endif

	aRotina :=	{{ "Pesquisar" ,'AxPesqui', 0, 1 },;
	{ OemToAnsi("Imprimir")  ,'U_S202IMPINI' , 0, 4, 20 },;
	{ OemToAnsi("Aprovar")  ,'U_S202ABRE' , 0, 4, 20 },;
	{ OemToAnsi("Cancelar") ,'U_S202CANC' , 0, 4, 20 },;
	{ OemToAnsi("Legenda"),'U_S202Legend' ,0,3,0} }

	//Seleciono indice de trabalho
	//////////////////////////////
	dbSelectArea("SUA")
	If Empty(cFiltro)
		dbSetOrder(1) //Por Numero Atendimento
	Endif

	cIndexSUA	:= CriaTrab(NIL,.F.)
	cKey		:= IndexKey()	
	cFiltro 	:= "UA_NUM >= '"+mv_par01+"'.AND.UA_NUM <= '"+mv_par02+"'"
	//cFiltro 	:= "(UA_NUM >= '"+mv_par01+"') .AND. (UA_NUM <= '"+mv_par02+"') .AND. "
	//cFiltro 	+= "(DTOS(UA_EMISSAO) >= '"+DTOS(mv_par03)+"') .AND. (DTOS(UA_EMISSAO) <= '"+DTOS(mv_par04)+"') .AND. "
	//cFiltro 	+= "(UA_CLIENTE >= '"+mv_par05+"') .AND. (UA_CLIENTE <= '"+mv_par06+"') .AND. "
	//cFiltro 	+= "(UA_LOJA >= '"+mv_par07+"') .AND. (UA_LOJA <= '"+mv_par08+"') .AND. (UA_OPER <> '3') "

	IndRegua("SUA",cIndexSUA,cKey,,cFiltro,"Selecionando Registros...")
	DbGoTop()

	/*
	cFiltro 	:= "(UA_NUM >= '"+mv_par01+"') .AND. (UA_NUM <= '"+mv_par02+"') .AND. "
	cFiltro 	+= "(DTOS(UA_EMISSAO) >= '"+DTOS(mv_par03)+"') .AND. (DTOS(UA_EMISSAO) <= '"+DTOS(mv_par04)+"') .AND. "
	cFiltro 	+= "(UA_CLIENTE >= '"+mv_par05+"') .AND. (UA_CLIENTE <= '"+mv_par06+"') .AND. "
	cFiltro 	+= "(UA_LOJA >= '"+mv_par07+"') .AND. (UA_LOJA <= '"+mv_par08+"') .AND. (UA_OPER <> '3') "

	dbSelectArea("SUA")
	MsFilter(cFiltro)
	*/

	aSema := {{"U_S888MAR()","BR_VERMELHO"},;
	{"U_S888AMA()","BR_AMARELO"},;
	{"U_S888VER()","BR_VERDE"}}

	MBrowse(6,1,22,75,"SUA",,,,,2,aSema)


	//dbSelectArea("SUA")
	//RetIndex("SUA")
	//dbClearFil()
	//dbSetOrder(1)
	//dbGotop()

	dbSelectArea("SUA")
	RetIndex("SUA")
	Ferase(cIndexSUA+OrdBagExt())
	dbSelectArea("SUA")
	Set Filter To
	dbSetOrder(1)
	dbGotop()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202ABRE บAutor  ณ ALAN LEANDRO       บ Data ณ  26/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a janela de Orcamento                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function S202ABRE(cAlias,nReg,nOpc)
	************************************
	//xCampo,xConteud
	Local i
	Local lInit
	Local cCampo
	LOCAL _lRet1  := .F.
	LOCAL aUser1  := {}
	LOCAL cUserId := ""
	LOCAL cComiss := ""
	PRIVATE oDlg, oGet1,aCols
	PRIVATE oMsMGet

	xCampo := "UA_OPER"

	cTitulo	:= "Atendimento"
	nOpcE	:= 2
	nOpcG	:= 2

	If SUA->UA_CANCEL <> " " .OR. (!EMPTY(SUA->UA_NUMSC5) .AND. SUA->UA_OPER == "1")
		MsgStop("Este orcamento nao pode ser alterado pois ja foi atendido ou esta cancelado!!!")
		Return
	ElseIf Empty(SUA->UA_CONDPG) .AND. xCampo == "UA_OPER"
		cMsg := "A condicao de pagamento nao foi definida pelo operador na inclusao do atendimento." + chr(13)
		cMsg += "Inclua a condicao atraves do televendas para que possa ser aprovado."
		MsgStop(cMsg)
		Return
	Endif

	// Verifica se o usuario e superior do usuario que incluiu o atendimento
	_lAcess := .F.
	aUser1  := ALLUSERS()
	For _x  := 1 To Len(aUser1)
		If Alltrim(aUser1[_x][1][2]) == alltrim(substr(cUsuario,7,15))
			For _z := 1 To Len(aUser1[_x][1][10])
				aGroup1 := {}
				aGroup1 := ALLGROUPS()
				For _w := 1 To Len(aGroup1)
					If Alltrim(aUser1[_x][1][10][_z]) == Alltrim(aGroup1[_w][1][1])
						If Upper(Alltrim(aGroup1[_w][1][2])) == "APROVADORES"
							_lAcess := .T.
						Endif
					Endif
				Next _w
			Next _z
		Endif
	Next _x

	/*If !_lAcess
	cMsg := "Usuario sem permissao para aprovar ou cancelar esse atendimento!!!"
	MsgStop(cMsg)
	Return
	Endif    */

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria variaveis M->????? da Enchoice                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RegToMemory("SUA")

	M->UA_CONDPG  := SUA->UA_CONDPG
	M->UA_CLIENTE := SUA->UA_CLIENTE
	M->UA_LOJA    := SUA->UA_LOJA
	M->UA_TABELA  := SUA->UA_TABELA   
	M->UA_DTENTRE := date()


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aHeader e aCols da GetDados                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nUsado:=0
	dbSelectArea("SX3") 
	dbSetOrder(1)
	dbSeek("SUB")
	aHeader:={}
	While !Eof().And.(x3_arquivo=="SUB")
		If (Alltrim(SX3->X3_campo) <> "UB_PRODUTO") .and. (Alltrim(SX3->X3_campo) <> "UB_DESCRI");
		.and. (Alltrim(SX3->X3_campo) <> "UB_QUANT") .and. (Alltrim(SX3->X3_campo) <> "UB_VRUNIT");
		.and. (Alltrim(SX3->X3_campo) <> "UB_PRCTAB");
		.and. (Alltrim(SX3->X3_campo) <> "UB_VLRITEM") .and. (Alltrim(SX3->X3_campo) <> "UB_DESC");
		.and. (Alltrim(SX3->X3_campo) <> "UB_PDESTAB") .and. (Alltrim(SX3->X3_campo) <> "UB_PDESCOM");
		.and. (Alltrim(SX3->X3_campo) <> "UB_COMIS")   .and. (Alltrim(SX3->X3_campo) <> "UB_COMIS2");
		.and. (Alltrim(SX3->X3_campo) <> "UB_COMIS3")  .and. (Alltrim(SX3->X3_campo) <> "UB_TAXAS");
		.and. (Alltrim(SX3->X3_campo) <> "UB_CUSTO")   .and. (Alltrim(SX3->X3_campo) <> "UB_TES");
		.and. (Alltrim(SX3->X3_campo) <> "UB_CBASE")   .and. (Alltrim(SX3->X3_campo) <> "UB_TPBASE");
		.and. (Alltrim(SX3->X3_campo) <> "UB_RENTAB")
			dbSelectArea("SX3")
			dbSkip()
			loop
		Endif

		//If X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado := nUsado + 1
		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,"AllwaysTrue()",;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		//	Endif 
		dbSkip()
	End

	aCols:={}
	dbSelectArea("SUB")
	dbSetOrder(1)
	dbSeek(xFilial("SUB")+M->UA_NUM,.T.)
	While !eof().and.UB_NUM==M->UA_NUM
		cRegra := "N"
		dbSelectArea("SUB")
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			dbSelectArea("SUB")
			If Alltrim(aHeader[_ni,2]) == "UB_PRCTAB"
				dbSelectArea("ACO")
				dbSetOrder(3)
				dbSeek(xFilial("ACO")+M->UA_CLIENTE+M->UA_LOJA+M->UA_TABELA)
				WHILE !eof() .and. ACO->ACO_FILIAL  == XFILIAL("ACO");
				.AND. ACO->ACO_CODCLI  == M->UA_CLIENTE;
				.AND. ACO->ACO_LOJA    == M->UA_LOJA;
				.AND. ACO->ACO_CODTAB  == M->UA_TABELA
					IF ACO->ACO_CONDPGTO == M->UA_CONDPG
						dbSelectArea("ACP")
						dbSetOrder(2)
						dbSeek(xFilial("ACP")+ACO->ACO_CODREG,.T.)
						WHILE !eof() .and. ACP->ACP_FILIAL  == XFILIAL("ACP");
						.AND. ACP->ACP_CODREG  == ACO->ACO_CODREG
							If ACP->ACP_CODPRO == SUB->UB_PRODUTO
								cRegra := "S"
								aCols[Len(aCols),_ni]  := ACP->ACP_PRECO
							ENDIF
							dbSelectArea("ACP")
							dbSkip()
						END
					ENDIF
					dbSelectArea("ACO")
					dbSkip()
				END
				dbSelectArea("SUB")
				IF cRegra == "N"
					aCols[Len(aCols),_ni]  := FieldGet(FieldPos(aHeader[_ni,2]))
				Endif
			Endif
			If Alltrim(aHeader[_ni,2]) == "UB_DESCRI"
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+SUB->UB_PRODUTO)
				aCols[Len(aCols),_ni]  := SB1->B1_DESC
			endif
			dbSelectArea("SUB")
			if Alltrim(aHeader[_ni,2]) <> "UB_DESCRI" .and. Alltrim(aHeader[_ni,2]) <> "UB_PRCTAB"
				aCols[Len(aCols),_ni]  := FieldGet(FieldPos(aHeader[_ni,2]))
			Endif
			//		Else
			//			aCols[Len(aCols),_ni]  := FieldGet(FieldPos(aHeader[_ni,2]))
			//		Endif
			If SUB->UB_COMIS == 0 .Or. SUB-> UB_COMIS2 == 0
				cComiss := 'N'
			EndIf
		Next
		aCols[Len(aCols),nUsado+1] := .F.
		dbSelectArea("SUB")
		dbSkip()
	End

	If cComiss == 'N'
		MsgStop("Este orcamento possui Comissao Zero para Televendas ou Representantes - Aten็ao!!!")
	Endif

	aMostra := {}
	AADD(aMostra,"UA_NUM")
	AADD(aMostra,"UA_CLIENTE")
	AADD(aMostra,"UA_LOJA")
	AADD(aMostra,"UA_DESCCLI")
	AADD(aMostra,"UA_CONDPG")
	AADD(aMostra,"UA_OPERADO")
	AADD(aMostra,"UA_DESCOPE")
	AADD(aMostra,"UA_TABELA")
	AADD(aMostra,"UA_VEND")
	AADD(aMostra,"UA_DESCVEN")
	AADD(aMostra,"UA_VEND2")
	AADD(aMostra,"UA_DESCVE2")
	AADD(aMostra,"UA_VEND3")
	AADD(aMostra,"UA_DESCVE3")
	AADD(aMostra,"UA_RENTAB")
	AADD(aMostra,"UA_PDESCAB")
	AADD(aMostra,"UA_OBSERVA")

	aAlter := {}   
	AADD(aAlter,"UB_COMIS")
	AADD(aAlter,"UB_COMIS2")
	AADD(aAlter,"UB_COMIS3")

	aEnc := {}
	AADD(aEnc,"UA_CONDPG")

	nOpca := 0

	//DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 TO 30,80
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 TO 34,100
	//oMsmget := Msmget():New("SUA",nReg,nOpc,,,,aMostra,{12,1,100,315},aEnc,,,,,,,.T.)
	oMsmget := Msmget():New("SUA",nReg,nOpc,,,,aMostra,{10,1,115,315},aEnc,,,,,,,.T.)     



	//MsMGet():New("SA1",nReg,nOpc,,,,aMostra,{8,1,140,315},,3,,,,oFolder:aDialogs[nOr1Scr],,,.T.)
	//oGet1   := MsGetDados():New(155,1,275,315,3,"AllwaysTrue","AllwaysTrue","",.F.,aAlter)
	oGet1   := MsGetDados():New(130,1,250,390,3,"AllwaysTrue","AllwaysTrue","",.F.,aAlter)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| S202INI()},{|| oDlg:End()})


Return


Static Function S202INI()
	*************************
	nTPRent := S202Calc() // alterado nRent para nTPRent

	cMsg := "A Rentabilidade esta em "+ Alltrim(Str(nTPRent,10,4))+ " %" + chr(13)//Alterado de nRent e 30/06/2016 por SLA
	cMsg += "Deseja continuar gerar o pedido com as informacoes atuais???"
	If MsgYesNo(cMsg)

		dbSelectArea("SUA")
		RecLock("SUA",.F.)
		SUA->UA_CONDPG := M->UA_CONDPG
		SUA->UA_OPER   := "1"
		SUA->UA_RENTAB := nTPRent // Alterado em 30/06/2016 por SLA de nRent 
		MsUnlock("SUA")

		S202GrvSub()

		S202GrvSc5()
		oDlg:End()

		//	SYSREFRESH() // Comentado Deco 04/01/2006
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202CANC บAutor  ณ ALAN LEANDRO       บ Data ณ  26/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancelamento do Orcamento                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function S202CANC(cAlias,nReg,nOpc)
	************************************
	Local i
	Local oDlg, oGet1
	Local oMsMGet
	Local lInit
	Local cCampo
	LOCAL _lRet1  := .F.
	LOCAL aUser1  := {}
	LOCAL cUserId := ""

	xCampo := "UA_CANCEL"

	cTitulo	:= "Atendimento"
	nOpcE	:= 2
	nOpcG	:= 2

	If SUA->UA_CANCEL <> " " .OR. (!EMPTY(SUA->UA_NUMSC5) .AND. SUA->UA_OPER == "1")
		MsgStop("Este orcamento nao pode ser alterado pois ja foi atendido ou esta cancelado!!!")
		Return
	ElseIf Empty(SUA->UA_CONDPG) .AND. xCampo == "UA_OPER"
		cMsg := "A condicao de pagamento nao foi definida pelo operador na inclusao do atendimento." + chr(13)
		cMsg += "Inclua a condicao atraves do televendas para que possa ser aprovado."
		MsgStop(cMsg)
		Return
	Endif

	// Verifica se o usuario e superior do usuario que incluiu o atendimento
	PswOrder(2)
	If PswSeek(substr(cUsuario,7,15),.T.)
		cUserId := PSWID()
	Endif

	aUser1 := ALLUSERS()
	For _x := 1 To Len(aUser1)
		If Alltrim(aUser1[_x][1][2]) == Alltrim(SUA->UA_USUARIO)
			If Alltrim(aUser1[_x][1][11]) <> Alltrim(cUserId)
				cMsg := "Usuario sem permissao para aprovar ou cancelar esse atendimento!!!" //+ chr(13)
				//cMsg += "Para dar manutenc."
				MsgStop(cMsg)
				Return
			Endif
		Endif
	Next _x

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria variaveis M->????? da Enchoice                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RegToMemory("SUA")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aHeader e aCols da GetDados                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nUsado:=0
	dbSelectArea("SX3")
	dbSeek("SUB")
	aHeader:={}
	While !Eof().And.(x3_arquivo=="SUB")
		If (Alltrim(SX3->X3_campo) <> "UB_PRODUTO") .and. (Alltrim(SX3->X3_campo) <> "UB_DESCRI");
		.and. (Alltrim(SX3->X3_campo) <> "UB_QUANT")   .and. (Alltrim(SX3->X3_campo) <> "UB_VRUNIT");
		.and. (Alltrim(SX3->X3_campo) <> "UB_VLRITEM") .and. (Alltrim(SX3->X3_campo) <> "UB_DESC");
		.and. (Alltrim(SX3->X3_campo) <> "UB_PDESTAB") .and. (Alltrim(SX3->X3_campo) <> "UB_PDESCOM");
		.and. (Alltrim(SX3->X3_campo) <> "UB_COMIS")   .and. (Alltrim(SX3->X3_campo) <> "UB_COMIS2");
		.and. (Alltrim(SX3->X3_campo) <> "UB_COMIS3")  .and. (Alltrim(SX3->X3_campo) <> "UB_TAXAS");
		.and. (Alltrim(SX3->X3_campo) <> "UB_CUSTO")   .and. (Alltrim(SX3->X3_campo) <> "UB_TES");
		.and. (Alltrim(SX3->X3_campo) <> "UB_CBASE")   .and. (Alltrim(SX3->X3_campo) <> "UB_TPBASE");
		.and. (Alltrim(SX3->X3_campo) <> "UB_RENTAB")
			dbSelectArea("SX3")
			dbSkip()
			loop
		Endif

		If X3USO(x3_usado).And.cNivel>=x3_nivel
			nUsado := nUsado + 1
			Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,"AllwaysTrue()",;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End

	aCols:={}
	dbSelectArea("SUB")
	dbSetOrder(1)
	dbSeek(xFilial("SUB")+M->UA_NUM,.T.)
	While !eof().and.UB_NUM==M->UA_NUM
		dbSelectArea("SUB")
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			dbSelectArea("SUB")
			If Alltrim(aHeader[_ni,2]) == "UB_DESCRI"
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+SUB->UB_PRODUTO)
				aCols[Len(aCols),_ni]  := SB1->B1_DESC
			Else
				aCols[Len(aCols),_ni]  := FieldGet(FieldPos(aHeader[_ni,2]))
			Endif
		Next
		aCols[Len(aCols),nUsado+1] := .F.
		dbSelectArea("SUB")
		dbSkip()
	End

	aMostra := {}
	AADD(aMostra,"UA_NUM")
	AADD(aMostra,"UA_CLIENTE")
	AADD(aMostra,"UA_LOJA")
	AADD(aMostra,"UA_DESCCLI")
	AADD(aMostra,"UA_CONDPG")
	AADD(aMostra,"UA_OPERADO")
	AADD(aMostra,"UA_DESCOPE")
	AADD(aMostra,"UA_TABELA")
	AADD(aMostra,"UA_VEND")
	AADD(aMostra,"UA_DESCVEN")
	AADD(aMostra,"UA_VEND2")
	AADD(aMostra,"UA_DESCVE2")
	AADD(aMostra,"UA_VEND3")
	AADD(aMostra,"UA_DESCVE3")
	AADD(aMostra,"UA_RENTAB")
	AADD(aMostra,"UA_PDESCAB")
	AADD(aMostra,"UA_OBSERVA") 

	aAlter := {}
	aEnc := {}
	nOpca := 0

	//DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 TO 30,80
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 TO 34,100

	//oMsmget := Msmget():New("SUA",nReg,nOpc,,,,aMostra,{12,1,100,315},aEnc,,,,,,,.T.)
	oMsmget := Msmget():New("SUA",nReg,nOpc,,,,aMostra,{10,1,110,315},aEnc,,,,,,,.T.)


	//MsMGet():New("SA1",nReg,nOpc,,,,aMostra,{8,1,140,315},,3,,,,oFolder:aDialogs[nOr1Scr],,,.T.)
	//oGet1   := MsGetDados():New(155,1,275,315,3,"AllwaysTrue","AllwaysTrue","",.F.,aAlter)
	oGet1   := MsGetDados():New(130,1,250,390,3,"AllwaysTrue","AllwaysTrue","",.F.,aAlter)


	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},{|| oDlg:End()})


	If nOpca == 1
		dbSelectArea("SUA")
		RecLock("SUA",.F.)
		SUA->UA_CANCEL := "S"
		MsUnlock("SUA")

		//	SYSREFRESH() // Comentado Deco 04/01/2006
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202Cria บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function S202CriaPerguntas(cGrupo,aPer)
	*****************************************
	LOCAL lRetu := .T.
	LOCAL aReg  := {}

	dbSelectArea("SX1")
	If (FCount() == 41)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
		Next _l
	ElseIf (FCount() == 39)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
		Next _l
	Elseif (FCount() == 26)
		aReg := aPer
	Endif

	dbSelectArea("SX1")
	For _l := 1 to Len(aReg)
		If !dbSeek(cGrupo+StrZero(_l,02,00))
			RecLock("SX1",.T.)
			For _m := 1 to FCount()
				FieldPut(_m,aReg[_l,_m])
			Next _m
			MsUnlock("SX1")
		Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
			RecLock("SX1",.F.)
			For _k := 1 to FCount()
				FieldPut(_k,aReg[_l,_k])
			Next _k
			MsUnlock("SX1")
		Endif
	Next _l

Return lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202Cria บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function S888VER()
	*********************
	LOCAL lRetu := .F.

	If SUA->UA_CANCEL == " " .AND. EMPTY(SUA->UA_NUMSC5) .AND. SUA->UA_OPER == "2"
		lRetu := .T.
	Endif

Return lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202Cria บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function S888MAR()
	************************
	LOCAL lRetu := .F.

	If SUA->UA_CANCEL == "S"
		lRetu := .T.
	Endif

Return lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202Cria บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function S888AMA()
	*********************
	LOCAL lRetu := .F.

	If !EMPTY(SUA->UA_NUMSC5) .AND. SUA->UA_OPER == "1" .AND. SUA->UA_CANCEL == " "
		lRetu := .T.
	Endif

Return lRetu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202Cria บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function S202Legend()
	************************
	BrwLegenda(cCadastro,"Legenda",{	{"BR_VERDE","Atendimento em aberto"},; 		//Pedido em aberto
	{"BR_VERMELHO","Atendimento cancelado"},;      //Pedido encerrado
	{"BR_AMARELO","Atendimento encerrado"}})   //Pedido Liberado
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202Cria บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function S202GrvSc5()
	*************************
	LOCAL cTipoCli := Posicione("SA1",1,xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,"A1_TIPO")

	Dbselectarea("SC5")
	DbSetorder(1)
	cNumSC5 := GetSxeNum("SC5","C5_NUM")

	cMay := "SC5"+ALLTRIM(xFilial("SC5"))+cNumSC5
	While (MsSeek(xFilial("SC5")+cNumSC5) .OR. !MayIUseCode(cMay))
		cNumSC5 := Soma1(cNumSC5,Len(cNumSC5))
		cMay 	:= "SC5"+ALLTRIM(xFilial("SC5"))+cNumSC5
	End




	DbSelectarea("SC5")
	RecLock("SC5",.T.)
	SC5->C5_FILIAL		:= xFilial("SC5")
	SC5->C5_NUM			:= cNumSC5
	SC5->C5_TIPO		:= "N"
	SC5->C5_CLIENTE 	:= SUA->UA_CLIENTE
	SC5->C5_LOJACLI 	:= SUA->UA_LOJA
	SC5->C5_LOJAENT	:= SUA->UA_LOJA
	SC5->C5_TRANSP  	:= SUA->UA_TRANSP
	SC5->C5_TIPOCLI	:= cTipoCli
	SC5->C5_CONDPAG   := SUA->UA_CONDPG
	SC5->C5_TABELA   	:= SUA->UA_TABELA
	SC5->C5_VEND1    	:= SUA->UA_VEND
	SC5->C5_ACRSFIN  	:= SUA->UA_JUROS
	SC5->C5_EMISSAO  	:= dDataBase
	SC5->C5_MOEDA    	:= SUA->UA_MOEDA
	SC5->C5_LIBEROK  	:= ""
	SC5->C5_FRETE    	:= SUA->UA_FRETE
	SC5->C5_TPFRETE    	:= SUA->UA_TPFRETE
	SC5->C5_DESPESA  	:= SUA->UA_DESPESA
	SC5->C5_TIPLIB   	:= "1"
	SC5->C5_vend1  		:= SUA->UA_vend
	SC5->C5_vend2  		:= SUA->UA_vend2
	SC5->C5_vend3  		:= SUA->UA_vend3
	SC5->C5_vend4  		:= Space(6)
	SC5->C5_vend5  		:= Space(6)
	SC5->C5_comis1 		:= 0
	SC5->C5_comis2 		:= 0
	SC5->C5_comis3 		:= 0
	SC5->C5_comis4 		:= 0
	SC5->C5_comis5 		:= 0
	SC5->C5_RENTAB 		:= SUA->UA_RENTAB 
	SC5->C5_NOMECLI     := SA1->A1_NOME

	If cEmpAnt == "02" // Busco transportadora do cliente para o pedido de venda da Mime Distribuidora
		dbSelectArea("SA1")
		dbSetOrder(1)	
		If DbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA)	
			SC5->C5_TRANSP := SA1->A1_TRANSP
		EndIf
	EndIf  


	If EMPTY(SC5->C5_CODTEX1)
		SC5->C5_CODTEX1   := "001"
	EndIf
	If EMPTY(SC5->C5_CODTEX2)
		SC5->C5_CODTEX2   := "002"
	EndIf
	If (SC5->(FieldPos("C5_PDESCAB"))  > 0) .AND. (SUA->(FieldPos("UA_PDESCAB")) > 0)
		SC5->C5_PDESCAB := SUA->UA_PDESCAB
	Endif   

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+SUA->UA_CONDPG)

	If SE4->E4_TIPO == "9"
		If "%" $ SE4->E4_COND
			nTX := 0
			dbSelectArea("SL4")
			dbSetOrder(1)
			dbSeek(xFilial("SL4")+SUA->UA_NUM+"SIGATMK ")
			While !EOF() .and. SL4->L4_FILIAL == xFilial("SL4") .and. SL4->L4_NUM == SUA->UA_NUM;
			.and. Alltrim(SL4->L4_ORIGEM) == "SIGATMK"
				nTX += SL4->L4_VALOR
				dbSelectArea("SL4")
				dbSkip()
			End
		Endif
		nX := 0
		dbSelectArea("SL4")
		dbSetOrder(1)
		dbSeek(xFilial("SL4")+SUA->UA_NUM+"SIGATMK ")
		While !EOF() .and. SL4->L4_FILIAL == xFilial("SL4") .and. SL4->L4_NUM == SUA->UA_NUM;
		.and. Alltrim(SL4->L4_ORIGEM) == "SIGATMK"
			nX++
			&("SC5->C5_DATA"+strzero(nX,1)) := SL4->L4_DATA
			If "%" $ SE4->E4_COND
				&("SC5->C5_PARC"+strzero(nX,1)) := (SL4->L4_VALOR/nTX) * 100
			Else
				&("SC5->C5_PARC"+strzero(nX,1)) := SL4->L4_VALOR
			Endif
			//Else
			//	Replace &("SC5->C5_PARC"+Substr(cParcela,nX,1)) With aParcelas[nX][2] //Valor em R$
			//Endif
			dbSelectArea("SL4")
			dbSkip()
		End
	Endif

	MsUnlock()
	Dbcommit()
	ConfirmSx8()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualizo o numero do pedido no arq. de oramento SUA ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SUA")
	RecLock("SUA",.F.)
	SUA->UA_NUMSC5 := cNumSC5
	MsUnlock()
	Dbcommit()

	cI := "00"
	cNovoItem := "00"
	cGeraWMS  := ""      

	nTotIt := 0
	dbSelectArea("SUB")
	dbSetOrder(1)
	dbSeek(xFilial("SUB")+SUA->UA_NUM)
	While !EOF() .and. SUB->UB_FILIAL == xFilial("SUB") .and. SUB->UB_NUM == SUA->UA_NUM

		cI := SomaIt(cI)
		cNovoItem := SomaIt(cNovoItem)

		SB1->(DbSeek(xFilial("SB1")+SUB->UB_PRODUTO))
		SF4->(DbSeek(xFilial("SF4")+SUB->UB_TES))

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualizo o texto padrao caso produto cfe alexandre/Ctb 09/08/2006
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Alltrim(SUB->UB_PRODUTO) == '00072' .Or. Alltrim(SUB->UB_PRODUTO) == '00073'
			dbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_CODTEX1 := "004"
			MsUnlock()
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualizo o texto padrao caso produto cfe alexandre/Ctb 05/07/2007
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Alltrim(SUB->UB_PRODUTO) == '00083'
			dbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_CODTEX1 := "005"
			MsUnlock()
		EndIf

		DbSelectArea("SC6")
		DbSetorder(1)
		If DbSeek(xFilial("SC6") + cNumSc5 + cI)
			lNovo := .F.
		Else
			lNovo := .T.
		Endif                                 

		//REVISO A CFOP CONFORME A TES DO ATENDIMENTO  
		cCF := SUB->UB_CF

		If cEmpAnt == "01" .and. (SUB->UB_TES == "684" .OR. SUB->UB_TES == "685")
			dbSelectArea("SF4")
			dbSetOrder(1)
			If dbSeek(xFilial("SF4")+SUB->UB_TES)
				cCF := SubStr(SUB->UB_CF,1,1) + SubStr(SF4->F4_CF,2,3)
				RecLock("SUB",.F.)
				SUB->UB_CF := cCF
				MsUnLock()
			EndIf
		EndIf 


		Reclock("SC6",lNovo)
		SC6->C6_FILIAL		:= xFilial("SC6")
		SC6->C6_ITEM		:= cNovoItem
		SC6->C6_NUM			:= cNumSC5
		SC6->C6_CLI			:= SC5->C5_CLIENTE
		SC6->C6_LOJA		:= SC5->C5_LOJACLI
		SC6->C6_PRODUTO	    := SUB->UB_PRODUTO
		SC6->C6_comis1    	:= SUB->UB_comis
		SC6->C6_comis2 	    := SUB->UB_comis2
		SC6->C6_comis3 	    := SUB->UB_comis3
		SC6->C6_comis4    	:= 0
		SC6->C6_comis5   	:= 0
		SC6->C6_RENTAB 	    := SUB->UB_RENTAB
		SC6->C6_DESCRI		:= SB1->B1_DESC
		SC6->C6_UM			:= SUB->UB_UM
		SC6->C6_QTDVEN		:= SUB->UB_QUANT
		SC6->C6_PRUNIT		:= SUB->UB_PRCTAB
		SC6->C6_PRCVEN		:= SUB->UB_VRUNIT
		SC6->C6_VALDESC	:= SUB->UB_VALDESC
		SC6->C6_DESCONT	:= SUB->UB_DESC
		SC6->C6_VALOR		:= SUB->UB_VLRITEM
		SC6->C6_TES			:= SUB->UB_TES
		SC6->C6_CF			:= cCF
		SC6->C6_LOCAL		:= SUB->UB_LOCAL
		SC6->C6_ENTREG		:= SUB->UB_DTENTRE
		SC6->C6_ITEMORI	:= ""
		SC6->C6_QTDEMP		:= 0
		//	SC6->C6_QTDLIB		:= 0
		SC6->C6_CLASFIS	:= Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
		SC6->C6_CBASE		:= SUB->UB_CBASE
		SC6->C6_TPBASE		:= SUB->UB_TPBASE
		nTotIt              += SUB->UB_VLRITEM

		/*BEGINDOC
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAlteracoes realizadas para atender a AGRICOPEL ATACADOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ENDDOC*/             

		If	SM0->M0_CODIGO == "01" .and. SM0->M0_CODFIL == "06"  //SE FOR AGRICOPEL ATACADO		  		
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณBuscamos o tipo de enstrutura, endereco padrao das tabelas PAJ,PAKณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			ENDDOC*/

			// INFORMAวีES PARA WMS GetMV("MV_VLRETIR")

			SC6->C6_SERVIC = GetMV("MV_SERVWMS")
			cQuery := ""
			cQuery += "SELECT B1.B1_COD,B1.B1_TIPO,B1.B1_UM,B1_LOCALIZ,R_E_C_N_O_ FROM " + RetSqlName("SB1")+ " B1 (NOLOCK) "
			cQuery += "WHERE LTRIM(RTRIM(B1.B1_FILIAL))  = '" + xFilial("SB1") + "' "
			cQuery += "  AND LTRIM(RTRIM(B1.B1_COD))     = '" + trim(SUB->UB_produto)  + "' "
			cQuery += "  AND B1.D_E_L_E_T_ <> '*'"          	
			cQuery := ChangeQuery(cQuery)
			If (Select("MSB1") != 0)
				dbSelectArea("MSB1")
				dbCloseArea()
			Endif
			TCQuery cQuery NEW ALIAS "MSB1"

			lAchou := .F.
			cTipoPro := ""
			cUMPro   := "" 
			cLocaliz := ""
			dbSelectArea("MSB1")
			dbGoTop()                   
			While !Eof()  
				cTipoPro := MSB1->B1_TIPO
				cUMPro   := MSB1->B1_UM                    
				cLocaliz := MSB1->B1_LOCALIZ     
				MSB1->(dbskip())						          
			EndDo	                     

			/*

			cQuery := ""
			cQuery += "SELECT PAK_ESTRU FROM " + RetSqlName("PAK")+ " PAK (NOLOCK) "
			cQuery += "WHERE LTRIM(RTRIM(PAK.PAK_FILIAL)) = '" + xFilial("PAK")    + "' "
			cQuery += "  AND LTRIM(RTRIM(PAK.PAK_TIPO))   = '" + trim(cTipoPro) + "' "   
			cQuery += "  AND LTRIM(RTRIM(PAK.PAK_UNIDAD)) = '" + trim(cUMPro) + "' "
			cQuery += "  AND PAK.D_E_L_E_T_ <> '*'"          

			cQuery := ChangeQuery(cQuery)
			If (Select("MPAK") != 0)
			dbSelectArea("MPAK")
			dbCloseArea()
			EndIf
			TCQuery cQuery NEW ALIAS "MPAK"

			cTipoEstru := ""
			dbSelectArea("MPAK")
			dbGoTop()                   
			While !Eof()  
			cTipoEstru := MPAK->PAK_ESTRU
			MPAK->(dbskip())						
			EndDo	

			cQuery := ""
			cQuery += "SELECT PAJ_DOCA FROM " + RetSqlName("PAJ")+ " PAJ (NOLOCK) "
			cQuery += "WHERE LTRIM(RTRIM(PAJ.PAJ_FILIAL)) = '" + xFilial("PAJ")    + "' "
			cQuery += "  AND LTRIM(RTRIM(PAJ.PAJ_REG))   = '" + trim( SA1->A1_REGWMS) + "' "   
			cQuery += "  AND PAJ.D_E_L_E_T_ <> '*'"          

			cQuery := ChangeQuery(cQuery)
			If (Select("MPAJ") != 0)
			dbSelectArea("MPAJ")
			dbCloseArea()
			EndIf
			TCQuery cQuery NEW ALIAS "MPAJ"

			cEndereco := ""
			dbSelectArea("MPAJ")
			dbGoTop()                   
			While !Eof()  
			cEndereco := MPAJ->PAJ_DOCA
			MPAJ->(dbskip())						
			EndDo	                  
			If alltrim(cEndereco) == ""
			cEndereco := "DS1"    
			EndIf   	   	      				*/

			If cLocaliz == "S"  					      	   	      				
				SC6->C6_SERVIC = GetMV("MV_SERVWMS")
				SC6->C6_TPESTR := "000009" 
				SC6->C6_ENDPAD := "DS1"         			   
				SC6->C6_TPOP   := "F"
				SC6->C6_SUGENTR   := DDATABASE
				cGeraWMS := "S"
			EndIf		 
		EndIf			      
		//Fim WMS				
		/*BEGINDOC
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFim das Customizacoes realizadas para o WMSณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ENDDOC*/

		MsUnlock()
		Dbcommit()    


		Reclock("SC5",.F.)            
		If cGeraWMS == "S" .AND. SM0->M0_CODIGO == "01" .AND. SM0->M0_CODFIL == "06"
			SC5->C5_GERAWMS = "1"
		EndIf 
		MsUnlock()
		Dbcommit()    

		dbSelectArea("SUB")
		dbSkip()
	End                   

	//alert(nTotIt)
	U_AGX475(cNumSC5, SUA->UA_CLIENTE,SUA->UA_LOJA,nTotIt)


	*
	* Sugere Impressao pedido Palm
	*
	If (SubStr(SUA->UA_NUM,1,1) == 'P' .OR. SubStr(SUA->UA_NUM,1,1) == 'R') .And. 	SUA->UA_OPER  == "1"
		cMsg := "Deseja imprimir o pedido do Palm ? "
		If MsgYesNo(cMsg)
			S202Imp()
		Endif
	Endif

Return

Static Function S202Calc()
	**************************
	LOCAL nTxM := GetMv("MV_TXFIN")

	// Inicia os calculos da Analise da Rentabilidade
	nPProd   	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
	nPQtd    	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
	nPTotIt  	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
	nPTes1   	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_TES"})
	nPComis  	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS"})
	nPComis2 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS2"})
	nPComis3 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS3"})
	nPTx     	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_TAXAS"})
	nPIRent  	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_RENTAB"})
	nPCB		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_CBASE"})      //Incluido por Valdecir em 02.03.04
	nPTB		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPBASE"})	 //Incluido por Valdecir em 02.03.04

	// Busca a Taxa de Acrescimo Financeiro
	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+M->UA_CONDPG)
	cString:=SE4->E4_COND

	aElem  := {}
	nDias  := 0
	nTProd := 0
	nTRent := 0

	While Len(cString) > 0
		AADD(aElem,Parse(@cString))
	End

	For _x := 1 To Len(aElem)
		nDias += Val(aElem[_x])
	Next

	nDiasM := nDias / Len(aElem)
	nTxFin := (nTxM * nDiasM) / 30

	// Incluido em 20.07.04 por Valdecir.

	// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
	// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW, AGX528.PRW, AGX603.PRW.
	//
	/*
	TRECHO ABAIXO COMENTADO POR SLA EM 30/06/2016 PARA UTILIZAR CมLCULO COM BASE EM CUSTO DE PLANILHA DE FORMAวรO DE PREวOS
	nTotTxFin	:= 0
	nTotPis		:= 0
	nTotCofins	:= 0
	*/
	For _i := 1 To Len(aCols)
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+aCols[_i][nPProd])
		
		nTxIcm := TKCALCICM(_i)	//(j)			

		aOldaCols := aClone(aCols)
		aOldHeader := aClone(aHeader)
		nBackup	:= n
//Emerson SLA inser็ใo de Cadastro devido a performance
//08.2016
	   	nVlrCpr  :=0              
    	nPerVds  :=0
		nPerMgr  := 0
IF DA1->(FieldPos("DA1_ZCSTCO")) > 0											
	DbSelectArea("DA1")
	DbSetOrder(1)
		If	DbSeek(xFilial("DA1")+M->UA_TABELA+aCols[_i][nPProd],.T.)
	   	nVlrCpr  :=DA1_ZCSTCO    //=CstTotCompra                      
    	nPerVds  :=DA1_ZPVEND    //=PercRefVenda
		nPerMgr  := DA1_ZPMARG   //=PercRefMarge
    Endif
Else
	Pergunte( "MTC010", .F. ) 
    nVlrCpr := MaPrcPlan(aCols[_i][nPProd],"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)	
	nPerVds := MaPrcPlan(aCols[_i][nPProd],"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
 	nPerMgr := MaPrcPlan(aCols[_i][nPProd],"SLA_AGR","PERC_REF_MARGEM",0)  //PORCENTUAL MARGEM CONTRIBUICAO (j)  
Endif   
		
		n := nBackup
		aCols := aClone(aOldaCols)
		aHeader := aClone(aOldHeader)

		_nPreco  := aCols[_i][nPTotIt] - (aCols[_i][nPTotIt] * (M->UA_PDESCAB / 100)) //Atualiza Pre็o Unitแrio com Descontos
		_nPercVd := aCols[_i][nPComis]  // Percentual de comissao Vendedor   (j)
	    _nPercTl := aCols[_i][nPComis2] // Percentual de comissao Televendas (j)
	    
        nVlrVds := (_nPreco * (nPerVds/100))  //CUSTO DA VENDA (j) 
        nVlrMgr := (_nPreco * (nPerMgr/100))  //VALOR MARGEM CONTRIBUICAO (j)                                    
	         			
		_nVComV := (_nPreco * (_nPercVd/100))  //Valor de Comissao Vendedor (j) 
		_nVComT := (_nPreco * (_nPercTl/100))  //Valor de Comissao Televendas (j) 
		_nIcmsS := (_nPreco * (nTxIcm/100  ))  //Valor de Icms sobre as vendas nTxIcm (j) 
		
		//nTProd  += _nPreco 
		//nRent   := _nPreco - nCusto // Atualiza Valor Unitแrio da Rentabilidade
		
		nTProd  += _nPreco //(j) 
		nRent   := (_nPreco - nVlrCpr - (nVlrVds+_nVComV+_nVComT+_nIcmsS) + nVlrMgr ) // Atualiza Valor Unitแrio da Rentabilidade (j) 

		aCols[_i][nPIRent] := ((nRent / _nPreco ) * 100) //ATUALIZA UB_RENTAB

		nCbase := 0
		cTpBase:= ""
		DbSelectArea("DA1")
		DbSetOrder(1)
		DbGotop()
		If	DbSeek(xFilial("DA1")+M->UA_TABELA+aCols[_i][nPProd],.T.)
			nCbase := DA1->DA1_CBASE
			cTpBase:= DA1->DA1_TPBASE
		Else
			nCbase := 0
		EndIf

		aCols[_i][nPCB] := nCbase  //ATUALIZA UB_CBASE
		acols[_i][nPTB] := cTpBase //ATUALIZA UB_TPBASE

		nTRent  += nRent

		cGrupo := SB1->B1_GRUPO
		/*
		TRECHO ABAIXO COMENTADO POR SLA EM 30/06/2016 PARA UTILIZAR CมLCULO COM BASE EM CUSTO DE PLANILHA DE FORMAวรO DE PREวOS

		nTxIcm := TKCALCICM(_i)

		// Incluido por Valdecir em 01.03.04
		nCbase := 0
		xCbase := 0
		cTpBase:= ""
		DbSelectArea("DA1")
		DbSetOrder(1)
		DbGotop()
		If	DbSeek(xFilial("DA1")+SUA->UA_TABELA+aCols[_i][nPProd],.T.)
		nCbase := DA1->DA1_CBASE
		cTpBase:= DA1->DA1_TPBASE
		Else
		nCbase := 0
		EndIf

		//	nCT1  := aCols[_i][nPQtd] * Max(SB1->B1_CUSTD,SB1->B1_UPRC) Comentado por Valdecir em 01.03.04
		dbSelectArea("SZ5")
		dbSetOrder(1)
		dbSeek(xFilial("SZ5")+SB1->B1_AGMRKP)

		xCbase := nCbase // Feita esta salva para gravar no CUSTO base usado no calculo da rentabilidade o valor Original Cfe Ademir 27/02/2008.
		nCbase := nCbase - (nCbase * (SZ5->Z5_CUFICOM / 100)) // Deduz custo financeiro compra cfe Ademir  17/06/2005


		nZ5_PIS 		:= (nCbase * (SZ5->Z5_PIS / 100))
		nZ5_COFINS 	:= (nCbase * (SZ5->Z5_COFINS / 100))

		//	nVlrTxIcm   := 0                                 // Eliminado esta parte cfe ademir 17/06/2005
		//	nB1_IPI     := 0
		//	if cTpBase == 'U' // considera icm e ipi somente para ultimo preco compra cfe ademir 14/09/2004
		//      If Alltrim(SB1->B1_GRTRIB) <> '60' // somente para clasfis diferente de 60 cfe ademir 28/10/2004
		//	      nVlrTxIcm	:= (nCbase * (nTxIcm / 100))
		//   	Endif
		//      nB1_IPI		:= (nCbase * (SB1->B1_IPI / 100)) // Eliminado esta parte cfe ademir 17/06/2005
		//   EndIf

		nCT1  := aCols[_i][nPQtd] * ((nCbase - (nZ5_PIS+nZ5_COFINS)))  // Novo Calculo cfe Ademir 17/06/2005.
		//	nCT1  := aCols[_i][nPQtd] * ((nCbase - (nZ5_PIS+nZ5_COFINS+nVlrTxIcm))+nB1_IPI)
		//	nCT1  := aCols[_i][nPQtd] * nCbase

		nPerc := aCols[_i][nPTx] + nTxFin + nTxIcm + aCols[_i][nPComis] + aCols[_i][nPComis2] + aCols[_i][nPComis3]

		_nPreco := aCols[_i][nPTotIt] - (aCols[_i][nPTotIt] * (M->UA_PDESCAB / 100))

		nVlrTxFin	:= (_nPreco * (nTxFin / 100))
		nZ5_PIS 		:= (_nPreco * (SZ5->Z5_PIS / 100))
		nZ5_COFINS 	:= (_nPreco * (SZ5->Z5_COFINS / 100))


		nTotTxFin	:= nTotTxFin + nVlrTxFin
		nTotPis		:= nTotPis	 + nZ5_PIS
		nTotCofins	:= nTotCofins+ nZ5_COFINS

		nTxProd := _nPreco * (nPerc / 100)
		nRent   := _nPreco - nCT1 - nTxProd
		nTProd  += _nPreco

		//	aCols[_i][nPIRent] := ((nRent / ( _nPreco - nVlrTxFin - nZ5_PIS - nZ5_COFINS)) * 100)
		aCols[_i][nPIRent] := ((nRent / _nPreco ) * 100) // considera preco venda bruto cfe ademir 14/09/2004

		//	aCols[_i][nPCB] := nCBase
		aCols[_i][nPCB] := xCBase // Feita esta salva para gravar no CUSTO base usado no calculo da rentabilidade o valor Original Cfe Ademir 27/02/2008.
		acols[_i][nPTB] := cTpBase

		nTRent  += nRent
		*/

	Next

	//nTPRent 		:= ((nTRent /  (nTProd - nTotTxFin - nTotPis - nTotCofins)) * 100)
	nTPRent 		:= ((nTRent / nTProd ) * 100) // considera preco venda bruto cfe ademir 14/09/2004
	M->UA_RENTAB	:= nTPRent

	// SYSREFRESH() // Comentado Deco 04/01/2006

Return nTPRent

/*
FONTE UTILIZADO PELOS GATILHOS DA SUB -- GATILHO UB_VUNIT -- 002
*/

User Function AGR202G()

	// Inicia os calculos da Analise da Rentabilidade
	nPProd   	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
	nPQtd    	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
	nPTotIt  	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
	nPTes1   	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_TES"})
	nPComis  	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS"})
	nPComis2 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS2"})
	nPComis3 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS3"})
	nPTx     	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_TAXAS"})
	nPIRent  	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_RENTAB"})
	nPCB		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_CBASE"})    //Incluido por Valdecir em 02.03.04
	nPTB		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPBASE"})	 //Incluido por Valdecir em 02.03.04

	// ATENCAO: QUALQUER ALTERACAO FEITA DESTE PONTO PARA BAIXO, DEVERA SER REPASSADO AOS PROGRAMAS:
	// MTA410.PRW, TKGRPED.PRW, SF2460I.PRW, AGR202.PRW, AGX528.PRW, AGX603.PRW.
	//

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+aCols[N][nPProd])
		 
	nTxIcm := TKCALCICM(N)	

	aOldaCols := aClone(aCols)
	aOldHeader := aClone(aHeader)
	nBackup	:= n
//Performance - Emerson Probst 17.08.16,trocado calculo por campos

//DA1_ZCSTCO   =CstTotCompra                      
//DA1_ZPVEND   =PercRefVenda
//DA1_ZPMARG   =PercRefMarge
//  nCusto  := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","CUSTO_REF",0)              //CUSTO REFERสNCIA DA TABELA DE PREวOS
//  nVlrCpr := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)	
//	nPerVds := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
//	nPerMgr := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","PERC_REF_MARGEM",0)  //PORCENTUAL MARGEM CONTRIBUICAO (j)  
	nVlrCpr :=0
    nPerVds:=0
	nPerMgr :=0

IF DA1->(FieldPos("DA1_ZCSTCO")) > 0											
	DbSelectArea("DA1")
	DbSetOrder(1)
	If	DbSeek(xFilial("DA1")+M->UA_TABELA+aCols[N][nPProd],.T.)
	   	nVlrCpr  :=DA1_ZCSTCO   //=CstTotCompra                      
    	nPerVds  :=DA1_ZPVEND   //=PercRefVenda
		nPerMgr  :=DA1_ZPMARG   //=PercRefMarge
    Endif
   // cmens:='DA1 ->'+aCols[N][nPProd]+Chr(13)+CHR(10)+Chr(13)+CHR(10)
  //	cmens+='nVlrCpr'+alltrim(str(nVlrCpr))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
 //	cmens+='nPervds'+alltrim(str(nPervds))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
//	cmens+='nPerMgr'+alltrim(str(nPerMgr))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
  //	cmens+='===================='+Chr(13)+CHR(10)+Chr(13)+CHR(10)

Else
	Pergunte( "MTC010", .F. ) 
    nVlrCpr := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","CUSTO_TOTAL_DA_COMPRA",0)  //CUSTO TOTAL DA COMPRA (j)	
	nPerVds := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","PERC_REF_VENDAS",0)        //PERCENTUAL DE REFERENCIA PARA CALCULO DO CUSTO DA VENDA  (j)
 	nPerMgr := MaPrcPlan(aCols[N][nPProd],"SLA_AGR","PERC_REF_MARGEM",0)        //PORCENTUAL MARGEM CONTRIBUICAO (j)  
//    cmens+='Calculo ->'+aCols[N][nPProd]+Chr(13)+CHR(10)+Chr(13)+CHR(10)
Endif   
//cmens+='nVlrCpr'+alltrim(str(nVlrCpr))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
//cmens+='nPervds'+alltrim(str(nPervds))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
//cmens+='nPerMgr'+alltrim(str(nPerMgr))+Chr(13)+CHR(10)+Chr(13)+CHR(10)
//alert(cmens)
	
	n := nBackup
	IaCols := aClone(aOldaCols)
	aHeader := aClone(aOldHeader)

	_nPreco := aCols[N][nPTotIt] - (aCols[N][nPTotIt] * (M->UA_PDESCAB / 100)) //Atualiza Pre็o Unitแrio com Descontos
    _nPercVd := aCols[N][nPComis]  // Percentual de comissao Vendedor   (j)
    _nPercTl := aCols[N][nPComis2] // Percentual de comissao Televendas (j)

     nVlrVds := (_nPreco * (nPerVds/100))  //CUSTO DA VENDA (j) 
     nVlrMgr := (_nPreco * (nPerMgr/100))  //VALOR MARGEM CONTRIBUICAO (j)	 
	    			
    _nVComV := (_nPreco * (_nPercVd/100))  //Valor de Comissao Vendedor (j) 
    _nVComT := (_nPreco * (_nPercTl/100))  //Valor de Comissao Televendas (j) 
    _nIcmsS := (_nPreco * (nTxIcm/100  ))  //Valor de Icms sobre as vendas nTxIcm (j)
     
	 //nRent  :=  _nPreco - nCusto           //Atualiza Valor Unitแrio da Rentabilidade
     nRent   := (_nPreco - nVlrCpr - (nVlrVds+_nVComV+_nVComT+_nIcmsS) + nVlrMgr ) // Atualiza Valor Unitแrio da Rentabilidade (j) 

	aCols[N][nPIRent] := ((nRent / _nPreco ) * 100) //ATUALIZA UB_RENTAB

	nCbase := 0
	cTpBase:= ""
	DbSelectArea("DA1")
	DbSetOrder(1)
	DbGotop()
	If	DbSeek(xFilial("DA1")+M->UA_TABELA+aCols[N][nPProd],.T.)
		nCbase := DA1->DA1_CBASE
		cTpBase:= DA1->DA1_TPBASE
	Else
		nCbase := 0
	EndIf

	IF nPCB > 0
	aCols[N][nPCB] := nCbase  //ATUALIZA UB_CBASE
	acols[N][nPTB] := cTpBase //ATUALIZA UB_TPBASE
   Endif                                             
                    
	//Alert("Executou")  

Return ((nRent / _nPreco ) * 100)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202Cria บAutor  ณ ALAN LEANDRO       บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function S202GrvSub()
	****************************
	LOCAL _i   := 0
	LOCAL nPC1 := 0
	LOCAL nPC2 := 0
	LOCAL nPC3 := 0

	nPC1  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS"})
	nPC2  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS2"})
	nPC3  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_COMIS3"})
	nPRT  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_RENTAB"})
	nPCB  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_CBASE"})    //Incluido por Valdecir em 02.03.04
	nPTB  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPBASE"})	 //Incluido por Valdecir em 02.03.04


	dbSelectArea("SUB")
	dbSetOrder(1)
	dbSeek(xFilial("SUB")+SUA->UA_NUM)
	While !EOF() .and. SUB->UB_FILIAL == xFilial("SUB") .and. SUB->UB_NUM == SUA->UA_NUM
		_i++

		RecLock("SUB",.F.)
		SUB->UB_COMIS  := aCols[_i][nPC1]
		SUB->UB_COMIS2 := aCols[_i][nPC2]
		SUB->UB_COMIS3 := aCols[_i][nPC3]
		SUB->UB_RENTAB := aCols[_i][nPRT]

		SUB->UB_CBASE  := aCols[_i][nPCB]  //Incluido por Valdecir em 02.03.04
		SUB->UB_TPBASE := aCols[_i][nPTB]  //Incluido por Valdecir em 02.03.04

		MsUnlock("SUB")

		dbSelectArea("SUB")
		dbSkip()
	End

Return

Static Function TKCALCICM(nLin)
************************
LOCAL cEstado	:= GetMV("MV_ESTADO")
LOCAL cNorte	:= GetMV("MV_NORTE")
LOCAL nPerRet   := 0

DbSelectarea("SF4")
DbSetorder(1)
If DbSeek(xFilial("SF4")+aCols[nLin][nPTes1])
	
	If SF4->F4_ICM = "S"
		If Empty(SA1->A1_INSCR)
			nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
			nPerRet := Iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("MV_ICMPAD"))
		Elseif SB1->B1_PICM > 0
			nPerRet := SB1->B1_PICM
		Elseif SA1->A1_EST == cEstado
			nPerRet := GetMV("MV_ICMPAD")
		Elseif SA1->A1_EST <> cEstado .AND. SB1->B1_PICM == 0
			nPerRet:= GetMV("MV_ICMPAD")
		Elseif SA1->A1_EST $ cNorte .AND. At(cEstado,cNorte) == 0
			nPerRet := 7
		Else
			nPerRet := 12
		Endif
	Endif	
	// ALTERACAO JOAO - SLA - 20.07.2016
	//If SF4->F4_BASEICM > 0 //Reducao base calculo conf. Alexandre 030809
	//	nPerRet := (nPerRet * SF4->F4_BASEICM) / 100
	//Endif
		
	If SF4->F4_BASEICM > 0 .OR. SF4->F4_PICMDIF <> 0   //Reducao base calculo ou ICMS Diferido		
		nPICMBase := ROUND(((nPerRet * SF4->F4_BASEICM)/ 100),0)
		nPICMDif  := ROUND(((nPerRet * SF4->F4_PICMDIF)/ 100),0)
		nPerRet := (nPerRet - nPICMBase - nPICMDif )
	EndIf
	// FIM ALTERACAO
		
	If aCols[nLin][nPTes1] == "513" .AND.  SM0->M0_CODIGO = "01" .AND. SM0->M0_CODFIL = "02"
		nPerRet := 12
	EndIf
		
Endif

Return nPerRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202IMPINI บAutor  ณ DECO             บ Data ณ  15/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicia pelo Botao Imprimir Or็amento                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function S202IMPINI()
	************************************

	S202IMP()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S202IMP บAutor  ณ DECO                บ Data ณ  26/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprimir Or็amento                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function S202IMP(cAlias,nReg,nOpc)
	************************************
	cPerg     := ""
	Limite   := 80
	cString  :="SUA"
	cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o relatorio")
	cDesc2   := OemToAnsi("de metas dos vendedores e grupos de produtos selecionados")
	cDesc3   := ""
	nChar    := 18
	cTamanho := "P"
	cProduto := ""

	aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
	cNomeProg:= "TMKR03"
	aLinha   := {}
	nLastKey := 0

	Titulo   := "ESPELHO DO PEDIDO DE VENDA"
	cCabec1  := ""
	cCabec2  := ""
	cCancel  := "***** CANCELADO PELO OPERADOR *****"
	m_pag    := 1        //Variavel que acumula numero da pagina
	wnrel    := "TMKR03" //Nome Default do relatorio em Disco

	//If (FunName() == "#TMKR03") .or. (FunName() == "#TMKR3A") .or. (FunName() == "TMKR03")
	If (FunName() == "#TMKR03") .or. (FunName() == "#TMKR3A") .or. (FunName() == "TMKR03")

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica as perguntas selecionadas .ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cPerg := "TMK003"
		pergunte(cPerg,.F.)

		SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)
	Else
		SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)
	Endif

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	RptStatus({|lEnd| STMKIMP(@lEnd,wnrel,cString)},Titulo)

Return


Static Function STMKIMP(lEnd,WnRel,cString,cNumAte)
	***************************************************

	Local cPerg     := "TMK003"
	Local cArqTrab  := ""
	Local nomeprog  := "TMKR03"
	Local cObs	    := ""
	Local cVendAnt  := ""
	Local cCodCli   := ""
	Local cNome     := ""
	Local cEnder    := ""
	Local cFone     := ""
	Local lFirst    := .F.
	Local cCPF	    := ""
	Local cRG       := ""
	Local cLinha    := ""
	Local nInd      := 0
	Local nValdesc  := 0
	Local cContato  := ""
	Local cEntidade := ""
	Local lSC5      := .F.
	Local Co        := 0
	Local nPrecoST  := 0
	Local nTotGeST  := 0

	PRIVATE aFatura   := {}
	PRIVATE cFormPag  := ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape  .ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag    := 1

	Li := 1

	SetPrc(0,0)
	@ 000,000 PSAY CHR(18)


	IMPCABEC()

	lFirst:=.T.

	CABITEM()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprime os produtos/servicos pedidos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nCont := 0
	dbSelectArea("SUB")
	dbSetOrder(1)
	dbSeek(xFilial("SUB")+SUA->UA_NUM)
	While !EOF() .and. (xFilial("SUB") == SUB->UB_FILIAL) .and. (SUA->UA_NUM    == SUB->UB_NUM)
		nCont++

		dbSelectArea("SUB")
		dbSkip()
	End

	nPagR := nCont / 9
	nPagR++
	cPagR := Alltrim(str(nPagR))
	cPagR := substr(cPagR,1,1)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprime os produtos/servicos pedidos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SUB")
	dbSetOrder(1)
	If dbSeek(xFilial("SUB")+SUA->UA_NUM)
		nVrunit  := 0
		nTotQtd  := 0
		nTotGeral:= 0

		nPagA := 1

		dbSelectArea("SUB")
		Do While !Eof() .and. (xFilial("SUB") == SUB->UB_FILIAL) .and. (SUA->UA_NUM    == SUB->UB_NUM)

			If Li == 23
				@ 027,000		PSAY " ************  CONTINUA ************ "
				@ 029,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
				@ 031,000		PSAY " "

				nPagA++
				LI := 33
				IMPCABEC()
				CABITEM()
			ElseIf Li == 53
				@ 057,000		PSAY " ************  CONTINUA ************ "
				@ 059,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR

				nPagA++
				LI := 1
				IMPCABEC()
				CABITEM()
			EndIf

			dbSelectArea("SUB")

			_cDesc1 := substr(SUB->UB_DESCAUX,1,38)

			If EMPTY(_cDesc1)
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbGotop()
				dbSeek(xFilial("SB1")+SUB->UB_PRODUTO)

				_cDesc1 := SUBSTR(SB1->B1_DESC,1,38)
			ENDIF
			Li++

			cProduto := SUB->UB_PRODUTO

			@ Li,002		PSAY ALLTRIM(SUB->UB_PRODUTO)
			@ Li,010		PSAY _cDesc1
			@ Li,054		PSAY SUB->UB_UM
			If SM0->M0_CODIGO == "02"
				@ Li,058		PSAY SUB->UB_QUANT			PICTURE "@E 999,999.99"
				@ Li,068		PSAY SUB->UB_VRUNIT			PICTURE "@E 99999.9999"
			Else
				@ Li,058		PSAY SUB->UB_QUANT			PICTURE "@E 999,999.99"
				@ Li,068		PSAY SUB->UB_VRUNIT			PICTURE "@E 999,999.99"
			EndIf

			nTotQtd  += SUB->UB_QUANT
			nTotGeral+= SUB->UB_VLRITEM
			nVrunit  := SUB->UB_VRUNIT

			dbSelectArea("SUB")
			dbSkip()

		EndDo

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณImprime os totais de quantidade e valor.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Li+= 2
		@ Li,000 PSAY Repl("-",80)
		Li++

		nTotGeral := nTotGeral - (nTotGeral * (SUA->UA_PDESCAB/100))

		//	nTotGeral := round(nTotGeral,2) COMENTADO RODRIGO/WILLIAN 17112009

		// Atualiza atendimento caso seja valor diferente do que saiu na impressao Cfe Neia 19/09/2006
		dbSelectArea("SUA")
		If nTotGeral <> SUA->UA_VALBRUT .or. ;
		nTotGeral <> SUA->UA_VALMERC .or. ;
		nTotGeral <> SUA->UA_VLRLIQ  .or. ;
		nTotGeral <> SUA->UA_FINANC
			RecLock("SUA",.F.)
			SUA->UA_VALBRUT := nTotGeral
			SUA->UA_VALMERC := nTotGeral
			SUA->UA_VLRLIQ  := nTotGeral
			SUA->UA_FINANC  := nTotGeral
			MsUnlock("SUA")
		EndIf

		@ Li,000 PSAY "Total das quantidades:" + Transform(nTotQtd, PESQPICT("SUB","UB_QUANT") )
		@ Li,040 PSAY "Valor total do Pedido:" + Transform(nTotGeral, "@E 99,999,999.99")

		// Imprime Preco com Imposto Subst. Trib e Total para controle Rose na Mime Distrib. Cfe Ademir/Alexandre 10/08/2006
		If Alltrim(cProduto) == '00072' .Or. Alltrim(cProduto) == '00073'
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbGotop()
			dbSeek(xFilial("SB1")+cProduto)
			nPrecoST := 0 // Pre็o com imposto substitui็ao tributaria cfe Ademir/Alexandre 10/08/2006
			nTotGeST := 0 // Total com imposto substitui็ao tributaria cfe Alexandre 11/10/2006
			nPrecoST := noRound( ( noRound (nTotQtd * SB1->B1_VLSOL * (SB1->B1_ALIQICM/100) ,4 ) - noRound(nTotGeral * (SB1->B1_PICM/100) ,4) + nTotGeral ) / nTotQtd ,4)
			nTotGeST := Round( ( noRound (nTotQtd * SB1->B1_VLSOL * (SB1->B1_PICM/100) ,4) - noRound (nTotQtd * nVrunit * (SB1->B1_ALIQICM/100) ,4 ) ) + nTotGeral ,2)
			If nPrecoST <> 0
				Li += 2
				@ Li,000 PSAY "Pre็o C/Icms Substit.:" + Transform(noRound(nPrecoST,4),  "@E 99,999,999.9999")
				@ Li,040 PSAY "Valor total C/Icms ST:" + Transform(noRound(nTotGeST,4), "@E 99,999,999.99")
			EndIf
		EndIf

		If Li > 33
			@ 059,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
			nPagA++

			Li := 1
		Else
			@ 029,000		PSAY time() + " | Pagina: "+Alltrim(str(nPagA))+" - "+cPagR
			@ 031,000		PSAY " "

			nPagA++
			Li := 33
		Endif
	EndIf

	aFatura   := {}
	nTotQtd   := 0
	nTotGeral := 0

	If TYPE("uPorPrograma") == "U"
		fErase(cArqTrab+OrdBagExt())
		fErase(cArqTrab)
	Endif

	Set Device To Screen

	SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	EndIf

	MS_FLUSH()

Return

STATIC FUNCTION IMPCABEC()
	**************************
	cNome    :=	Posicione("SA1",1,xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"SA1->A1_NOME")
	cCid     :=	Posicione("SA1",1,xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"SA1->A1_MUN")
	cDDD     :=	Posicione("SA1",1,xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"SA1->A1_DDD")
	cTEL     :=	Posicione("SA1",1,xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"SA1->A1_TEL")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta uma string com as formas de pagamento utilizada na vendaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SL4")
	DbSetOrder(1)
	cFormPag := ""
	If MsSeek(xFilial("SL4") + SUA->UA_Num + "SIGATMK")
		Do While .not. eof() .and.;
		SL4->L4_Filial == xFilial("SL4") .and.;
		SL4->L4_Num == SUA->UA_Num .and.;
		Trim(SL4->L4_ORIGEM) == "SIGATMK"
			//Alterado por Marcelo em 10/10/03
			//////////////////////////////////
			//If !(Trim(SL4->L4_FORMA) $ cFormPag)
			//	cFormPag := cFormPag + Trim(SL4->L4_FORMA) + "/"
			//EndIf
			If Empty(cFormPag)
				cFormPag := SL4->L4_FORMA
			Endif
			AaDd(aFatura, {SL4->L4_Data, SL4->L4_Valor, SL4->L4_Forma} )
			DbSkip()
		EndDo
		//cFormPag := SubStr(cFormPag,1,Len(cformPag)-1)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona no respectivo registro do SC5, cabecalho do pedido de vendasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SC5")
	DbSetOrder(1)
	If MsSeek(xFilial("SC5") + SUA->UA_NUMSC5)
		lSC5 := .T.
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprime os dados do Cliente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ Li,000 PSAY Repl("-",80)
	Li++
	@ Li,000 PSAY "Pedido: " + SUA->UA_NUMSC5
	@ Li,040 PSAY "Data: " + DTOC(SUA->UA_EMISSAO)
	@ Li,060 PSAY "Orcamento: " + SUA->UA_NUM
	Li++
	Li++
	@ Li,000 PSAY "Cliente: " + SUA->UA_CLIENTE + "/" + SUA->UA_LOJA + " - " + Alltrim(SubStr(cNome,1,32)) + " | " + cCid
	Li++
	@ Li,030 PSAY "Fone       : " + cDDD + " " + cTEL
	Li++
	@ Li,000 PSAY "Prazo: " + ALLTRIM(Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI"))
	@ Li,030 PSAY "Forma Pagto: " + ALLTRIM(Posicione("SX5",1,xFilial("SX5")+"24"+cFormPag,"X5_DESCRI"))
	@ Li,055 PSAY "% Desc.เ Vista: " + Transform(SUA->UA_PDESCAB, "@E 99.99")
	Li++
	@ Li,000 PSAY "Obs: "+SUBSTR(SUA->UA_OBSERVA,1,70)
	Li++
	@ Li,000 PSAY "Representantes: "
	@ Li,016 PSAY SUA->UA_VEND + " - " + Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_NREDUZ")
	Li++
	lVend2 := .F.
	lVend3 := .F.
	If !Empty(SUA->UA_VEND2)
		@ Li,016 PSAY SUA->UA_VEND2 + " - " + Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND2,"A3_NREDUZ")
		Li++
		lVend2 := .T.
	EndIf
	If !Empty(SUA->UA_VEND3)
		@ Li,016 PSAY SUA->UA_VEND3 + " - " + Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND3,"A3_NREDUZ")
		Li++
		lVend23 := .T.
	EndIf
	@ Li,000 PSAY "Transportadora: "
	@ Li,016 PSAY SUA->UA_TRANSP + " - " + Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NREDUZ")

	If !lVend2 .And. !lVend3
		Li++
	EndIf


RETURN

STATIC FUNCTION CABITEM()
	****************************
	Li++
	@ Li,000 PSAY Repl("-",80)
	Li++
	@ Li,000 PSAY "* PRODUTO DESCRICAO                                   UM       QTDE      PRECO *"
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789
	Li++
	@ Li,000 PSAY Repl("-",80)
	Li++
	RETURN

Return
