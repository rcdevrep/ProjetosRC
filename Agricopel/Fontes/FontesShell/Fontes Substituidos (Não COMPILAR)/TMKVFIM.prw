#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMKVFIM  ºAutor  ³ Joao Tavares S Juniorº Data ³ 03/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na gravacao da orcamento no televendas    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKVFIM( cNumAtend, cNumPedido )
	Local aSeg := GetArea()
	Local aSegSC5 := SC5->(GetArea()), aSegSC6 := SC6->(GetArea()), aSegSUB := SUB->(Getarea())
	Local aSegSU6 := SU6->(GetArea()), aSegSU5 := SU5->(GetArea()), aSegSA1 := SA1->(GetArea())
	Local cNumero := SUA->UA_NUMSC5
	Local nQtdProd := 0
	Local lZeraDesconto := GETMV("ES_ZERADES")
	Local lComboFldPos := SC6->(FieldPos("C6_COMBO")) > 0 .And. SUB->(FieldPos("UB_COMBO") > 0)
	Local lCodPaiFldPos := SC6->(FieldPos("C6_CODPAI")) > 0 .And. SUB->(FieldPos("UB_CODPAI") > 0)
	Local lAltera := If(Type("ALTERA")<>"U",ALTERA,.F.)

	Private lTransf := .F.,lLiber := .T. , lSugere := .T.

	//MAN00000240101_EF_001 - Rodrigo Guerato
	//---------------------------------------
	If FindFunction("U_F010011")
		U_F010011(cNumAtend, cNumPedido)
	Endif
	//---------------------------------------

	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial("SC5")+cNumero)
		cGeraWMS := ""

		dbSelectArea("SUB")
		dbSetOrder(1)
		dbSeek(xFilial("SUB")+SUA->UA_NUM,.T.)
		While !Eof().and.(xFilial("SUB") == SUB->UB_FILIAL).And.(SUB->UB_NUM == SUA->UA_NUM)
			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek(xFilial("SC6")+cNumero+SUB->UB_ITEM+SUB->UB_PRODUTO)
				Reclock("SC6",.F.)

				IF lZeraDesconto       //Incluido Joao Junior
					SC6->C6_PRCLIST:= SC6->C6_PRUNIT
					SC6->C6_PERDESC:= SC6->C6_DESCONT
					SC6->C6_VALODES:= SC6->C6_VALDESC
					SC6->C6_PRUNIT := SC6->C6_PRCVEN
					SC6->C6_DESCONT:= 0
					SC6->C6_VALDESC:= 0
					nQtdProd += SC6->C6_QTDVEN
				EndIf

				If lComboFldPos
					SC6->C6_COMBO := SUB->UB_COMBO
				EndIf

				If lCodPaiFldPos
					SC6->C6_CODPAI := SUB->UB_CODPAI
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Customização a para gravar margens do Call Center no pedido de vendas - 23/03/2015                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SUB->(FieldPos("UB_MARGEM")) > 0 //Verifica se os campos existem na base
					SC6->C6_MARGEM := SUB->UB_MARGEM
				EndIf
				//FIM do bloco de Customização 23/03/2015

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Customização para gravar os campos de captação nos itens do PV. - 10/08/2015                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SUB->(FieldPos("UB_DTCAPTA")) > 0 .and. SUB->(FieldPos("UB_HRCAPTA")) > 0 .and. SUB->(FieldPos("UB_USCAPTA")) > 0 //Verifica se os campos existem na base
					SC6->C6_DTCAPTA := SUB->UB_DTCAPTA
					SC6->C6_HRCAPTA := SUB->UB_HRCAPTA
					SC6->C6_USCAPTA := SUB->UB_USCAPTA
				EndIf
				//FIM do bloco de Customização 10/08/2015

				MsUnlock("SC6")

				dbSelectArea("SUB")
				dbSkip()
			EndIf
		EndDo

		dbSelectArea("SC5")
		Reclock("SC5",.F.)

		SC5->C5_DESCONT = 0.00 //Estava deslocado lá em cima, então passamos pra cá - Ajustado por Max Ivan (Nexus) em 13/06/2017
		SC5->C5_vend1  := SUA->UA_VEND

		//  	SC5->C5_vend2  := U_IniVend2()
		SC5->C5_vend2  := SUA->UA_VEND2

		SC5->C5_X_ACRES:= SUA->UA_X_ACRES
		SC5->C5_OBS    := SUA->UA_OBSSA1
		SC5->C5_MENNOTA:= SUA->UA_MENNOTA
		SC5->C5_MENNOT2:= SUA->UA_MENNOT2
		SC5->C5_ESPECI1:= "DIVERSOS"
		SC5->C5_VOLUME1:= nQtdProd
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Customização a pedido da  Brazmax - Gravar campos data e hora da última alteração do PV - 26/06/2014³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SC5->(FieldPos("C5_ZZDATA")) > 0 .and. SC5->(FieldPos("C5_ZZHORA")) > 0 .and. SC5->(FieldPos("C5_ZZUSER")) > 0 //Verifica se os campos existem na base
			SC5->C5_ZZDATA := dDataBase
			SC5->C5_ZZHORA := SubsTr(Time(),1,5)
			SC5->C5_ZZUSER := cUserName
		EndIf
		//FIM do bloco de Customização 26/06/2014
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Customização a para gravar margens do Call Center no pedido de vendas - 23/03/2015                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SUA->(FieldPos("UA_MARGEM")) > 0 //Verifica se os campos existem na base
			SC5->C5_MARGEM := SUA->UA_MARGEM
		EndIf
		//FIM do bloco de Customização 23/03/2015
		SC5->C5_IMPORTA := SUA->UA_IMPORTA
		SC5->C5_PAGANT  := SUA->UA_PAGANT

		If SUA->(FieldPos("UA_NUMPESQ")) > 0 //Verifica se o campo existe na base
			SC5->C5_NUMPESQ := SUA->UA_NUMPESQ
		EndIf

		MsUnlock("SC5")

		//Liberacao pedido vendas Automatico
		//------------------------------------------------------------------------------------
		aSegSC52 := SC5->(GetArea())
		aSegSC62 := SC6->(GetArea())
		aHeadbkp := aClone(aHeader)
		aHeader := {}
		acolBkp	:= aClone(aCols)
		aCols := {}

		Pergunte("MTALIB",.F.)
		MV_PAR01 := 1
		MV_PAR02 := SC5->C5_NUM
		MV_PAR03 := SC5->C5_NUM
		MV_PAR04 := SC5->C5_CLIENTE
		MV_PAR05 := SC5->C5_CLIENTE
		MV_PAR06 := DATE()-7
		MV_PAR07 := DATE()+30
		MV_PAR08 := 1
		ALTERA := If(!lAltera, .T., lAltera)
		nRecn := SC5->(Recno())
		a440Proces("SC5",nRecn,4,.F.)
		ALTERA := lAltera
		aHeader := aClone(aHeadbkp)
		aCols	:= aClone(acolBkp)
		RestArea(aSegSC52)
		RestArea(aSegSC62)

		//------------------------------------------------------------------------------------
		aArea2     := GetArea()
		aAreaSC6  := SC6->(GetArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama evento de liberacao de regras com o SC5 posicionado               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaAvalSC5("SC5",9)
		If Existblock("FT210LIB")
			ExecBlock("FT210LIB",.f.,.f.)
		EndIf

		RestArea(aAreaSC6)
		RestArea(aArea2)

		aSegSC52 := SC5->(GetArea())
		aSegSC62 := SC6->(GetArea())
		aHeadbkp := aClone(aHeader)
		aHeader := {}
		acolBkp	:= aClone(aCols)
		aCols := {}

		Pergunte("MTALIB",.F.)
		MV_PAR01 := 1
		MV_PAR02 := SC5->C5_NUM
		MV_PAR03 := SC5->C5_NUM
		MV_PAR04 := SC5->C5_CLIENTE
		MV_PAR05 := SC5->C5_CLIENTE
		MV_PAR06 := DATE()-7
		MV_PAR07 := DATE()+30
		MV_PAR08 := 1
		ALTERA := If(!lAltera, .T., lAltera)
		nRecn := SC5->(Recno())
		a440Proces("SC5",nRecn,4,.F.)
		ALTERA := lAltera
		aHeader := aClone(aHeadbkp)
		aCols	:= aClone(acolBkp)
		RestArea(aSegSC52)
		RestArea(aSegSC62)

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
	//³Retorno estado original das areas utilizadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
	If SUA->UA_OPER == "1"
		U_SHEC010("SC5")
	EndIf

	RestArea(aSegSC5)
	RestArea(aSegSC6)
	RestArea(aSegSUB)
	RestArea(aSegSU6)
	RestArea(aSegSU5)
	RestArea(aSegSA1)
	RestArea(aSeg)

Return (.T.)