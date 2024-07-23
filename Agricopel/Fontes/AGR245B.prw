#INCLUDE "RWMAKE.CH"
#Include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR245B   ºAutor  ³Microsiga           º Data ³  04/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Manutencao Romaneio (Incl/Excl/Alter).      º±±
±±º          ³                                                            º±±
±±º          ³  Criar Arquivos:                                           º±±
±±º          ³  SZB - Cabecalho Romaneio de Cargas.                       º±±
±±º          ³  SZC - Itens Romaneio de Cargas.                           º±±
±±º          ³                                                            º±±
±±º          ³  Criar Indices:                                            º±±
±±º          ³  SZB - (1) ZB_FILIAL+ZB_NUM                                º±±
±±º          ³  SZB - (2) ZB_FILIAL+ZB_NUM+ZB_MOTORIS+DTOS(ZB_DTSAIDA)    º±±
±±º          ³  SZC - (1) ZC_FILIAL+ZC_NUM+ZC_DOC                         º±±
±±º          ³                                                            º±±
±±º          ³  Criar Campos                                              º±±
±±º          ³  SF2 - F2_ROMANE 6 C                                       º±±
±±º          ³                                                            º±±
±±º          ³  Appendar o SF2 E SZ9 para o SXB.                          º±±
±±º          ³  Incluir Gatilho                                           º±±
±±º          ³  SZC ZC_SERIE 001                                          º±±
±±º          ³  EXECBLOCK("AGR245D",.F.,.F.)                              º±±
±±º          ³  ZC_COD                                                    º±±
±±º          ³  P                                                         º±±
±±º          ³  N                                                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR245B()

	//ADICIONADO PARA INCLUIR CAMPO COMBOBOX NA TELA
	Local aArray2     := {}
	Local cAliasSX3   := "SX3"
	Local cX3CAMPO    := ""
	Local nCont       := 0
	Private cNomeMot  := "" //Chamado 74984
	Private cMotoris  := ""
	Private cFornece  := ""
	Private cNomeForn := ""

	cForaCombo    := ""
	nLenGrava     := 1

	aHeader  := {}
	nOpc    := 3

	DbSelectArea(cAliasSX3)
	DbSetOrder(1)
	DbGotop()
	DbSeek("SZC",.T.)
	While !Eof() .And. ((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))) == "SZC")

		cX3CAMPO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO"))))

		If (Alltrim(cX3CAMPO) <> "ZC_FILIAL") .And. (Alltrim(cX3CAMPO) <> "ZC_NUM")
			If X3USO((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))))
				
				nUsado++

				AADD(aHeader,{;
				TRIM((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TITULO"))))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_PICTURE")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TAMANHO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_DECIMAL")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_VLDUSER")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TIPO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CONTEXT")))),;
				(cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_F3"))))} )
			Endif
		EndIf

		DbSelectArea(cAliasSX3)
		DbSkip()
	Enddo

	aGetQtd := {}
	Aadd(aGetQtd ,"ZC_DOC")
	Aadd(aGetQtd ,"ZC_SERIE")

	cNum  := SZB->ZB_NUM
	aCols := {}

	DbSelectArea("SZC")
	DbSetOrder(1)
	DbGotop()
	DbSeek(xFilial("SZC")+SZB->ZB_NUM,.T.)
	While !Eof() .And. SZC->ZC_FILIAL == xFilial("SZC");
	.And. SZC->ZC_NUM	 == SZB->ZB_NUM

		Aadd(aCols,{SZC->ZC_DOC,;
		SZC->ZC_SERIE,;
		SZC->ZC_PESO,;
		SZC->ZC_VOLUME,;
		SZC->ZC_VALOR,;
		SZC->ZC_CLIENTE,;
		SZC->ZC_LOJA,;
		SZC->ZC_NOME,;
		/*SZC->ZC_STATUS*/iif(Empty(POSICIONE('SFT',1,xFilial('SFT')+'S'+SZC->ZC_SERIE+SZC->ZC_DOC+SZC->ZC_CLIENTE+SZC->ZC_LOJA,'FT_DTCANC')),'A','C'),;
		.F.})

		DbSelectArea("SZC")
		SZC->(DbSkip())
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo:="Manutencao Romaneio de Cargas"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,840 DIALOG oDlgQtd TITLE cTitulo

	cMotoris := SZB->ZB_MOTORIS
	DbSelectArea("SZ9")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SZ9")+SZB->ZB_MOTORIS,.T.)
		cNomeMot := SZ9->Z9_NOME
	EndIf

	cFornece := SZB->ZB_FORNECE
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SA2")+SZB->ZB_FORNECE,.T.)
		cNomeForn := SA2->A2_NOME
	EndIf
	DbSelectArea("SZB")
	cPlaca   := SZB->ZB_PLACA
	dDtSaida := SZB->ZB_DTSAIDA
	cKMSaida := SZB->ZB_KMSAIDA
	dDtChega := SZB->ZB_DTCHEGA
	cKmChega := SZB->ZB_KMCHEGA
	cDefBase := SZB->ZB_BASE
	cFornece := SZB->ZB_FORNECE 
	cLojafor := SZB->ZB_LOJAFOR 
	cDocent  := SZB->ZB_DOCENT
	cSerient := SZB->ZB_SERIENT 

	//aDefBase := {"03=BASE","04=IRANI","05=ICARA","02=ARAUCARIA","08=LAGES"} // ITENS DO COMBOBOX BASE DE ORIGEM DA CARGA
	//ADICIONADO PARA INCLUIR CAMPO COMBOBOX NA TELA

	nCont    := 1
	aDefBase := RetSX3Box(GetSX3Cache("ZB_BASE","X3_CBOX"),,,1)

	For nCont := 1 To Len(aDefBase)
		If cForaCombo <> "" .And. Left(aDefBase[nCont][1], nLenGrava) $ cForaCombo
			Loop
		Endif
		AADD(aArray2,aDefBase[nCont][1])
	Next nCont

	@ 004,005 Say "Romaneio:"
	@ 004,050 Get cNum  SIZE 40,10 Pict "@!" When .F.

	@ 004,130 Say "Condutor :"
	@ 004,175 Get cMotoris   SIZE 40,10 F3 "SZ9"  Valid GetCondut()

	@ 004,255 Say "Nome Cond:"
	@ 004,300 Get cNomeMot   SIZE 70,10 When .F.

	@ 016,005 Say "Placa :"
	@ 016,050 Get cPlaca   SIZE 40,10

	@ 016,130 Say "Dt Saida:"
	@ 016,175 Get dDtSaida SIZE 40,10

	@ 016,255 Say "KM Saida:"
	@ 016,300 Get cKMSaida SIZE 40,10 Pict "@E 999999"

	@ 027,005 Say "Dt Chegada:"
	@ 027,050 Get dDtChega SIZE 40,10

	@ 027,130 Say "KM Chegada:"
	@ 027,175 Get cKmChega SIZE 40,10 Pict "@E 999999"

	@ 027,255 Say "Base Supri:"
	@ 027,300 Combobox cDefBase Items aArray2 Size 50,13

	@ 042,005 Say "Fornecedor :"
	@ 042,050 Get cFornece   SIZE 40,10 F3 "SA2" VALID GetForne()

	@ 042,130 Say "Loja Forn. :"
	@ 042,175 Get cLojafor   SIZE 40,10 When .F.

	@ 042,255 Say "Nome Forn:"
	@ 042,300 Get cNomeForn   SIZE 70,10 When .F.

	@ 053,005 Say "NF Entrada:"
	@ 053,050 Get cDocent SIZE 40,10 Pict "@E 999999999"

	@ 053,130 Say "Serie NF:"
	@ 053,175 Get cSerient SIZE 20,10 Pict "@E 999"

	oBrowQtd := MsGetDados():New(068,005,170,420,nOpc,"AllwaysTrue","AllwaysTrue",,.T.,aGetQtd,,,999)
	oBrowQtd:oBrowse:bWhen := {||(len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()

	@ 180,300 BUTTON "_Gravar" SIZE 38,12 ACTION oGrava()
	@ 180,340 BUTTON "_Sair"   SIZE 38,12 ACTION Close(oDlgQtd)
	@ 180,10  BUTTON "_Importar" SIZE 38,12 ACTION U_AGR245AI()//Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED

Return

Static Function oGrava()

	Local i := 0
	Local _q := 0  // Contador para gravar a quantidade.
	
	if alltrim(cDefBase) == ''
		MsgStop("Obrigatorio o preenchimento do campo Base Supri")
		Return
	Endif 

	if Len(Alltrim(cDocent)) <= 8 .AND. Len(Alltrim(cDocent)) > 0
		MsgStop("Obrigatorio o preenchimento do campo NF ENTRADA com os 9 digitos, ou deixar o campo em branco")
		Return
	Endif


	DbSelectArea("SZB")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SZB")+cNum,.T.)

		DbSelectArea("SZC")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SZC")+cNum,.T.)
		While !Eof() .And. SZC->ZC_FILIAL == xFilial("SZC");
		.And. SZC->ZC_NUM	 == SZB->ZB_NUM

			DbSelectArea("SF2")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SF2")+SZC->ZC_DOC+SZC->ZC_SERIE+SZC->ZC_CLIENTE+SZC->ZC_LOJA,.T.)
				DbSelectArea("SF2")
				RecLock("SF2",.F.)
				SF2->F2_ROMANE := ""
				MsUnLock("SF2")
			EndIf

			RecLock("SZC",.F.)
			DBDELETE()
			MsUnLock("SZC")

			DbSelectArea("SZC")
			SZC->(DbSkip())
		End

		DbSelectArea("SZB")
		RecLock("SZB",.F.)
		DBDELETE()
		MsUnLock("SZB")

	EndIf

	//Validação para alertar sobre itens pendentes de execução. Cesar-SLA 16/03/2018
	If (cEmpAnt == "01" .And. cFilAnt == "06")

		For i:=1 to Len(aCols)

			If aCols[i,1] <> " "

				cQuery := ""
				cQuery += " SELECT C9_PEDIDO "
				cQuery += " FROM "+RetSqlName("SC9")+" SC9 (NOLOCK) "
				cQuery += " WHERE SC9.D_E_L_E_T_ = '' "
				cQuery += " AND C9_FILIAL = '06'"
				cQuery += " AND C9_LOCAL = '02'"
				cQuery += " AND C9_NFISCAL = '"+aCols[i,1]+"'"
				cQuery += " AND C9_SERIENF   = '"+aCols[i,2]+"'"
				cQuery += " AND C9_SERVIC <> ''"
				cQuery += " AND C9_PEDIDO IN (SELECT DCF_DOCTO FROM DCF010 (NOLOCK) DCF WHERE DCF.D_E_L_E_T_ = '' AND DCF_STSERV <> '3' GROUP BY DCF_DOCTO ) "
				cQuery += " GROUP BY C9_PEDIDO "

				If (Select("QRYT1") <> 0)
					dbSelectArea("QRYT1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "QRYT1"

				DBSELECTAREA("QRYT1")

				If !QRYT1->(EOF())

					WHILE !QRYT1->(EOF())
						Alert("Pedido: "+Alltrim(QRYT1->C9_PEDIDO)+" não esta totalmente executado!")
						QRYT1->(DBSKIP())
					ENDDO

				EndIf

			EndIf

		Next

		If (Select("QRYT1") <> 0)
			dbSelectArea("QRYT1")
			dbCloseArea()
		Endif

	EndIf

	nCont := 0
	For _q := 1 to Len(aCols)

		If ( !aCols[_q][Len(aCols[_q])] ) //Deletado
			If !Empty(aCols[_q,1]) .And. !Empty(aCols[_q,2])

				nCont := nCont + 1

				DbSelectArea("SZC")
				RecLock("SZC",.T.)
				SZC->ZC_FILIAL		:= xFilial("SZC")
				SZC->ZC_NUM			:= cNum
				SZC->ZC_DOC			:= aCols[_q,1]
				SZC->ZC_SERIE		:= aCols[_q,2]
				SZC->ZC_PESO		:= aCols[_q,3]
				SZC->ZC_VOLUME		:= aCols[_q,4]
				SZC->ZC_VALOR		:= aCols[_q,5]
				SZC->ZC_CLIENTE	    := aCols[_q,6]
				SZC->ZC_LOJA		:= aCols[_q,7]
				SZC->ZC_NOME		:= aCols[_q,8]
				//SZC->ZC_STATUS      := iif(	Empty(POSICIONE('SFT',1, xFilial('SFT') +'S'+ SZC->ZC_SERIE +;
				//SZC->ZC_DOC +SZC->ZC_CLIENTE + SZC->ZC_LOJA,'FT_DTCANC')),'','C')
				SZC->(MsUnLock())

				iif(Empty(POSICIONE('SFT',1, xFilial('SFT') +'S'+ SZC->ZC_SERIE+SZC->ZC_DOC+SZC->ZC_CLIENTE+SZC->ZC_LOJA,'FT_DTCANC')),'','C')

				DbSelectArea("SF2")
				DbSetOrder(1)
				DbGotop()
				If DbSeek(xFilial("SF2")+aCols[_q,1]+aCols[_q,2]+aCols[_q,6]+aCols[_q,7],.T.)
					DbSelectArea("SF2")
					RecLock("SF2",.F.)
					SF2->F2_ROMANE := cNum
					SF2->(MsUnLock())
				EndIf
			EndIf
		EndIf
	Next

	If nCont > 0
		RecLock("SZB",.T.)
		SZB->ZB_FILIAL  := xFilial("SZB")
		SZB->ZB_NUM		:= cNum
		SZB->ZB_MOTORIS	:= cMotoris
		SZB->ZB_PLACA   := cPlaca
		SZB->ZB_DTSAIDA := dDtSaida
		SZB->ZB_KMSAIDA := cKMSaida
		SZB->ZB_DTCHEGA	:= dDtChega
		SZB->ZB_KMCHEGA	:= cKMChega
		SZB->ZB_BASE    := cDefBase
		SZB->ZB_FORNECE	:= cFornece
		SZB->ZB_LOJAFOR := cLojafor
		SZB->ZB_DOCENT	:= cDocent 
		SZB->ZB_SERIENT := cSerient
		SZB->(MsUnLock())
	EndIf

	Close(oDlgQtd)

Return


Static function GetCondut()

	cNomeMot := ""

	DbSelectArea("SZ9")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SZ9")+cMotoris)
		cNomeMot := SZ9->Z9_NOME
	Endif 

Return .T.

Static function GetForne()

	cNomeForn := ""

	DbSelectArea("SA2")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SA2")+cFornece+cLojafor)
		cNomeForn := SA2->A2_NOME
	Endif 

Return .T.

