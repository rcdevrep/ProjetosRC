#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMKVFIM  ºAutor  ³ Marcelo da Cunha   º Data ³  06/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na gravacao da orcamento no televendas    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//User Function TMKVFIM()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Função (PE) de TMKVFIM p/ F010011, e criado esta chamada dentro do fonte original da Shell.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function F010011

	LOCAL aSeg := GetArea()
	LOCAL aSegSC5 := SC5->(GetArea()), aSegSC6 := SC6->(GetArea()), aSegSUB := SUB->(Getarea())
	LOCAL aSegSU6 := SU6->(GetArea()), aSegSU5 := SU5->(GetArea()), aSegSA1 := SA1->(GetArea())
	LOCAL cNumero := SUA->UA_numsc5, cCliente := Space(8), cOperad := Space(6), cLista := Space(6), cCodTex1 := Space(3)
	LOCAL cVend1 :=  SUA->UA_vend, cVend2 := SUA->UA_vend2,	cVend3  := SUA->UA_vend3
	LOCAL cQuery := ""

	Private _cPlaca
	PRIVATE lTransf := .F.,lLiber := .T. , lSugere := .T.

	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial("SC5")+cNumero)
		cGeraWMS := ""

		dbSelectArea("SUB")
		dbSetOrder(1)
		dbSeek(xFilial("SUB")+SUA->UA_NUM,.T.)
		While !Eof().and.(xFilial("SUB") == SUB->UB_FILIAL).and.(SUB->UB_NUM == SUA->UA_NUM)

			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek(xFilial("SC6")+cNumero+SUB->UB_ITEM+SUB->UB_PRODUTO)

				Reclock("SC6",.F.)

				SC6->C6_COMIS1  := SUB->UB_COMIS
				SC6->C6_COMIS2  := SUB->UB_COMIS2
				SC6->C6_COMIS3  := SUB->UB_COMIS3
				SC6->C6_COMIS4  := 0
				SC6->C6_COMIS5  := 0
				SC6->C6_RENTAB  := SUB->UB_RENTAB
				SC6->C6_CBASE   := SUB->UB_CBASE		//Incluido por Valdecir em 01.03.04
				SC6->C6_TPBASE  := SUB->UB_TPBASE		//Incluido por Valdecir em 01.03.04
				SC6->C6_CF      := SUB->UB_CF
				SC6->C6_PEDCLIN := SUB->UB_PEDCOM
				SC6->C6_PEDCLIT := SUB->UB_PEDCOMI

				//SC6->C6_QTDLIB  := SC6->C6_QTDVEN

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica de produto controla endereco³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := ""
				cQuery += "SELECT B1.B1_COD,B1.B1_TIPO,B1.B1_UM,B1.B1_LOCALIZ,R_E_C_N_O_ FROM " + RetSqlName("SB1")+ " B1 (NOLOCK) "
				cQuery += "WHERE LTRIM(RTRIM(B1.B1_FILIAL))  = '" + xFilial("SB1") + "' "
				cQuery += "  AND LTRIM(RTRIM(B1.B1_COD))     = '" + trim(SUB->UB_produto)  + "' "
				cQuery += "  AND B1.D_E_L_E_T_ <> '*'"

				If (Select("MSB1") != 0)
					dbSelectArea("MSB1")
					dbCloseArea()
				Endif

				TCQuery cQuery NEW ALIAS "MSB1"

				lAchou := .F.
				cTipoPro := ""
				cUMPro   := ""
				cLocaLiz := ""

				dbSelectArea("MSB1")
				dbGoTop()
				While !Eof()
					cTipoPro := MSB1->B1_TIPO
					cUMPro   := MSB1->B1_UM
					cLocaliz := MSB1->B1_LOCALIZ
					MSB1->(dbskip())
				EndDo

				If cLocaliz == "S"
					SC6->C6_SERVIC = GetMV("MV_SERVWMS")
					SC6->C6_ENDPAD := "DS1"
					SC6->C6_TPOP   := "F"
					SC6->C6_SUGENTR   := DDATABASE
					cGeraWMS := "S"
				EndIf

				dbSelectArea("SC6")
				MsUnlock("SC6")

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento texto padrao conforme regras³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If	SM0->M0_CODIGO == "01" // Se Agricopel
					If SM0->M0_CODFIL == "02" // Filial Pien
						If SUB->UB_TES = "513"
							cCodTex1 := "007"
						EndIf
						If SUB->UB_TES = "503"
							cCodTex1 := ""
						EndIf
					EndIf
				Else
					If SM0->M0_CODIGO == "12" // Se TRR MARTENDAL
						If trim(SUB->UB_PRODUTO) == "00000010"
							If trim(SA1->A1_EST) == "SC"
								cCodTex1 := "001"
							Else
								cCodTex1 := "007"
							EndIf
						Else
							If EMPTY(cCodTex1)
								cCodTex1 := "006"
							EndIf
						EndIf
					EndIf
				EndIf

				dbSelectArea("SUB")
				dbSkip()
			EndIf
		EndDo

		// Insere a placa do Veiculo no pedido de venda
		IF !EMPTY("UA_TRANSP") .AND. SUA->UA_OPER == '1' .AND. cEmpAnt == '16'
			IF MSGYESNO("Foi selecionado a transportadora "+SUA->UA_TRANSP+" - "+ALLTRIM(POSICIONE("SA4", 1, xFilial("SA4") + SUA->UA_TRANSP,"A4_NOME"))+;
			", deseja informar a placa do veículo?","TMKVFIM - Informar a Placa")
				u_InfPlc()
			ELSE
				_cPlaca := ''
			ENDIF
		ENDIF

		dbSelectArea("SC5")
		Reclock("SC5",.F.)

		If cGeraWMS == "S"
			SC5->C5_TPCARGA := "1" // UTILIZA
			SC5->C5_GERAWMS := "2" // NA MONTAGEM DA CARGA
		Else
			SC5->C5_TPCARGA := "2" // NÃO UTILIZA
			SC5->C5_GERAWMS := "1" // NO PEDIDO
		EndIf

		If !Empty(_cPlaca)
			SC5->C5_PLACA := _cPlaca
		EndIf

		SC5->C5_VEND1  := cVend1
		SC5->C5_VEND2  := cVend2
		SC5->C5_VEND3  := cVend3
		SC5->C5_VEND4  := Space(6)
		SC5->C5_VEND5  := Space(6)

		// Inicio Incluido devido a solicitação de Saionara - chamado 40125 - Thiago SLA - 25/05/2016
		IF cEmpAnt == '01' .OR. cEmpAnt == '11' .OR. cEmpAnt == '12'  .OR. cEmpAnt == '15' .OR. cEmpAnt == '16'
			SC5->C5_VEND6 := SUA->UA_VEND6
			SC5->C5_VEND7 := SUA->UA_VEND7
			SC5->C5_VEND8 := SUA->UA_VEND8
		ENDIF
		// Fim - Thiago SLA - 25/05/2016

		SC5->C5_COMIS1 := 0
		SC5->C5_COMIS2 := 0
		SC5->C5_COMIS3 := 0
		SC5->C5_COMIS4 := 0
		SC5->C5_COMIS5 := 0
		SC5->C5_RENTAB := SUA->UA_RENTAB

		If EMPTY(SC5->C5_CODTEX1)
			SC5->C5_CODTEX1   := "001"
		EndIf

		If EMPTY(SC5->C5_CODTEX2)
			SC5->C5_CODTEX2   := "002"
		EndIf

		If !EMPTY(cCodTex1)
			SC5->C5_CODTEX1   := cCodTex1 // Atualizo o texto padrao caso produto cfe alexandre/Ctb 09/08/2006
		EndIf

		SC5->C5_FORMPAG := SUA->UA_FORMPG
		SC5->C5_OBS     := SUA->UA_OBSSA1
		SC5->C5_MENS1   := SUA->UA_MENNOTA
		SC5->C5_MENS2   := SUA->UA_MENNOT2

		MsUnlock("SC5")
	Endif

	//Atualizo dados do atendimento
	///////////////////////////////
	If !Empty(M->UA_proxlig)
		//Gravo dados adicionais na agenda
		//////////////////////////////////
		dbSelectArea("SU6")
		dbSetOrder(1)
		dbSeek(xFilial("SU6")+SU4->U4_lista,.T.)
		While !Eof().and.(xFilial("SU6") == SU4->U4_filial).and.(SU4->U4_lista == SU6->U6_lista)
			dbSelectArea("SU5")
			dbSetOrder(1)
			dbSeek(xFilial("SU5")+SU6->U6_contato,.T.)
			If (SU6->U6_entida == "SA1")
				dbSelectArea("SA1")
				dbSetOrder(1)
				If dbSeek(xFilial("SA1")+Substr(SU6->U6_codent,1,6)+M->UA_LOJA)
					dbSelectArea("SU6")
					Reclock("SU6",.F.)
					SU6->U6_operad  := SU4->U4_operad
					SU6->U6_nomecli := Substr(SA1->A1_nome,1,30)
					SU6->U6_DDD     := SA1->A1_DDD
					SU6->U6_telcli  := Substr(SA1->A1_tel,1,20)
					SU6->U6_nomecon := Substr(SU5->U5_contat,1,20)
					SU6->U6_cidade  := Substr(SA1->A1_mun,1,20)
					SU6->U6_estado  := SA1->A1_est
					SU6->U6_codent  := Substr(SU6->U6_codent,1,6)+M->UA_LOJA
					MsUnlock("SU6")
					cCliente := SA1->A1_cod+SA1->A1_loja
					cLista   := SU4->U4_lista
					cOperad  := SU4->U4_operad
				Endif
			Endif

			dbSelectArea("SU6")
			dbSkip()
		Enddo

		cOperad := TKOPERADOR()  // Pega o Operador do call center para evitar de excluir agenda indevidamente!
		//Marco agenda como realizada
		////////////////////////////

		cQuery := ""
		cQuery += "SELECT U6_LISTA,U6_CODIGO FROM "+RetSqlName("SU6")+" (NOLOCK) "
		cQuery += "WHERE U6_FILIAL = '"+xFilial("SU6")+"' AND D_E_L_E_T_ = '' "
		cQuery += "AND U6_OPERAD = '"+cOperad+"' AND U6_ENTIDA = 'SA1' "
		cQuery += "AND U6_CODENT = '"+cCliente+"' AND U6_LISTA <> '"+cLista+"' "
		cQuery += "AND U6_STATUS <> '3' "

		If	(Select("MSU6") <> 0)
			dbSelectArea("MSU6")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "MSU6"
		dbSelectArea("MSU6")
		dbGotop()
		While !Eof()
			dbSelectArea("SU6")
			dbSetOrder(1)
			If dbSeek(xFilial("SU6")+MSU6->U6_lista+MSU6->U6_codigo)
				Reclock("SU6",.F.)
				SU6->U6_status := "3"
				MsUnlock("SU6")
			Endif
			dbSelectArea("MSU6")
			dbSkip()
		Enddo
		If (Select("MSU6") <> 0)
			dbSelectArea("MSU6")
			dbCloseArea()
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Marco agenda como concluida³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If (Type("M->UA_AGENDA") == "C").and.!Empty(M->UA_agenda)
		dbSelectArea("SU6")
		dbSetOrder(1)
		If dbSeek(xFilial("SU6")+M->UA_agenda)
			Reclock("SU6",.F.)
			SU6->U6_status := "3"
			MsUnlock("SU6")
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Altera status restricao na emissao do pedidos no cadastro³
	//³no cadastro do cliente na Agricopel                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If SM0->M0_CODIGO = "01"
		dbSelectArea("SA1")
		dbSetOrder(1)
		DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
		RecLock("SA1",.F.)
		SA1->A1_LIBORC := ""
		MsUnLock("SA1")
	EndIf

	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
	//³Retorno estado original das areas utilizadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù

	RestArea(aSegSC5)
	RestArea(aSegSC6)
	RestArea(aSegSUB)
	RestArea(aSegSU6)
	RestArea(aSegSU5)
	RestArea(aSegSA1)
	RestArea(aSeg)
Return (.T.)

User Function InfPlc()

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Rotina para informar a placa do veículo  ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ*/

	Private _cDescTransp := space(TamSX3("DA3_DESC")[1])
	Private cPlaca := space(TamSX3("DA3_COD")[1])
	SetPrvt("oDlg1","oSay1","oSay2","oGet1","oGet2","oBtn1","oBtn2")

	oDlg1      := MSDialog():New( 092,232,194,550,"Informe a Placa do Veículo",,,.F.,,,,,,.T.,,,.T. )

	oSay1      := TSay():New( 002,004,{||"Placa"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 010,004,{|u| If(PCount()>0,cPlaca:=u,cPlaca)},oDlg1,044,008,'',{|| (_cDescTransp := POSICIONE("DA3",3, xFilial("DA3") + cPlaca, "DA3_DESC"))},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DA3","cPlaca",,)

	oSay2      := TSay():New( 002,055,{||"Veículo"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
	oGet2      := TGet():New( 010,055,{|u| If(PCount()>0,_cDescTransp:=u,_cDescTransp)},oDlg1,102,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","_cDescTransp",,)

	oBtn1      := TButton():New( 032,040,"OK",oDlg1,{ || RetPlc(cPlaca)},037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 032,088,"Sair",oDlg1,{  || oDlg1:END()},037,012,,,,.T.,,"",,,,.F. )

	oDlg1:Activate(,,,.T.)

Return(_cPlaca)

// Retorna a placa
Static Function RetPlc(cPlaca)

	DBSELECTAREA("DA3")
	DBSETORDER(1)
	IF !DbSeek(xFilial("DA3")+cPlaca)
		MSGALERT("Placa inválida, verifique!","Atenção")
		RETURN()
	ELSE
		_cPlaca := cPlaca
		SysRefresh()
		oDlg1:END()
	ENDIF

Return(_cPlaca)