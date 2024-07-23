#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Microsiga           º Data ³  05/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para integracao do faturamento com o televendas.  º±±
±±º          ³ Sera abastecido no Orcamento do Televendas os seguintes    º±±
±±º          ³ campos:                                                    º±±
±±º          ³ UA_STATUS   := "NF." (Nota Emitida)                        º±±
±±º          ³ UA_DOC      := C9_NFISCAL                                  º±±
±±º          ³ UA_SERIE    := C9_SERIENF                                  º±±
±±º          ³ UA_EMISNF   := C9_DATALIB                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Leandro F Silveira  º Data ³  25/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ VendArla()                                                 º±±
±±º          ³ Criação de regra para repassar os valores dos campos       º±±
±±º          ³ de vendedores arla de SF2 para seu respectivo SE1          º±±
±±º          ³ F2_VEND6 -> E1_XVEND6                                      º±±
±±º          ³ F2_VEND7 -> E1_XVEND7                                      º±±
±±º          ³ F2_VEND8 -> E1_XVEND8                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//User Function M460FIM()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³04/12/2017 - MAX IVAN (Nexus) - Mudado o nome da Função (PE) de M460FIM p/ SHM460FI, e criado esta chamada dentro do fonte original da Shell.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function SHM460FI

	/*Verifico se na empresa Agricopel Pien possui algum produto com a TES 513.
	Se verdade, atualizar a aliquota de ICM para 12% e o valor do ICMS das tabelas
	que envolvem os campos citados */

	If cEmpAnt == '01' .and. cFilAnt == '02'
		lCheqIt := .F.
		cQuery := ""
		cQuery += "SELECT R_E_C_N_O_ "
		cQuery += "FROM " + RetSqlName("SD2") + " AS D2 (NOLOCK) "
		cQuery += "WHERE D2.D2_DOC = '" + SF2->F2_DOC + "' "
		cQuery += "AND D2.D2_SERIE  = '" + SF2->F2_SERIE  + "' "
		cQuery += "AND D2.D2_FILIAL  = '" + xFilial("SD2")  + "' "
		cQuery += "AND D2.D2_TES     = '513' "
		cQuery += "AND D2.D_E_L_E_T_ <> '*' "

		If Select("MTEMP") <> 0
			dbSelectArea("MTEMP")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "MTEMP"

		//Atualizo para aliquota com 12%
		dbSelectArea("MTEMP")
		dbGoTop()
		While !Eof()
			lCheqIt := .T.

			cQuery := ""
			cQuery += "UPDATE " + RetSqlName("SD2") + " "
			cQuery += " SET D2_PICM = 12 ,"
			cQuery += " D2_VALICM  = (D2_BASEICM * 12) / 100 "
			cQuery += " WHERE R_E_C_N_O_ = '" + STR(MTEMP->R_E_C_N_O_) + "' "

			If (TCSQLExec(cQuery) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf
			dbSelectArea("MTEMP")
			MTEMP->(dbSKIP())
		EndDo

		//Realizo a soma do icms de todos os itens se houver alteração
		If lCheqIt
			cQuery := ""
			cQuery += "SELECT D2_BASEICM,D2_VALICM,D2_FILIAL,D2_SERIE ,D2_DOC,D2_CLIENTE,D2_LOJA ,D2_ITEM,D2_COD,D2_PICM,R_E_C_N_O_ "
			cQuery += "FROM " + RetSqlName("SD2") + " AS D2 (NOLOCK) "
			cQuery += "WHERE D2.D2_DOC = '" + SF2->F2_DOC + "' "
			cQuery += "AND D2.D2_SERIE  = '" + SF2->F2_SERIE  + "' "
			cQuery += "AND D2.D2_FILIAL  = '" + xFilial("SD2")  + "' "
			cQuery += "AND D2.D_E_L_E_T_ <> '*' "

			If Select("MTEMP") <> 0
				dbSelectArea("MTEMP")
				dbCloseArea()
			Endif

			TCQuery cQuery NEW ALIAS "MTEMP"

			//Somo o ICMS de todos os itens da NF
			nValIcm := 0
			dbSelectArea("MTEMP")
			dbGoTop()
			While !Eof()
				nValIcm+= MTEMP->D2_VALICM

				//Atualizo a CD2
				cQuery := ""
				cQuery += "UPDATE " + RetSqlName("CD2") + " "
				cQuery += " SET CD2_BC = " + str(MTEMP->D2_BASEICM) + " , CD2_VLTRIB =  " + str(MTEMP->D2_VALICM) + " ,CD2_ALIQ = " + str(MTEMP->D2_PICM) + " "
				cQuery += " WHERE CD2_FILIAL = '" + MTEMP->D2_FILIAL + "' "
				cQuery += "   AND CD2_TPMOV  = 'S' "
				cQuery += "   AND CD2_SERIE= '" + MTEMP->D2_SERIE + "' "
				cQuery += "   AND CD2_DOC= '" + MTEMP->D2_DOC + "' "
				cQuery += "   AND CD2_CODCLI = '" + MTEMP->D2_CLIENTE + "' "
				cQuery += "   AND CD2_LOJCLI =  '" + MTEMP->D2_LOJA + "' "
				cQuery += "   AND CD2_ITEM = '" + MTEMP->D2_ITEM + "' "
				cQuery += "   AND CD2_CODPRO = '" + MTEMP->D2_COD + "' "
				cQuery += "   AND CD2_IMP = 'ICM' "
				cQuery += "   AND D_E_L_E_T_ <> '*'"

				If (TCSQLExec(cQuery) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf

				//Atualizo SFT
				DbSelectArea("SFT")
				DbSetOrder(7)
				DbGotop()
				DbSeek(MTEMP->D2_FILIAL+MTEMP->D2_DOC+MTEMP->D2_SERIE+MTEMP->D2_CLIENTE+MTEMP->D2_LOJA+"S"+MTEMP->D2_COD,.T.)

				If !DbSeek(MTEMP->D2_FILIAL+MTEMP->D2_DOC+MTEMP->D2_SERIE+MTEMP->D2_CLIENTE+MTEMP->D2_LOJA+"S"+MTEMP->D2_COD,.T.)
					//			  	   ALERT("NÃO ENCONTROU SFT - M460FIM")
				Else
					//  ALERT("ENCONTROU")
					RecLock("SFT",.F.)
					SFT->FT_BASEICM := MTEMP->D2_BASEICM
					SFT->FT_VALICM  := MTEMP->D2_VALICM
					SFT->FT_ALIQICM := MTEMP->D2_PICM
					MsUnLock("SFT")
				EndIf

				dbSelectArea("MTEMP")
				MTEMP->(dbSKIP())
			EndDo

			//Atualizo a Capa da NF com o ICMS Novo
			RecLock("SF2",.F.)
			SF2->F2_VALICM := nValIcm
			MsUnLock("SF2")

			//Atualizo SF3 com os valores ICMS Calculado
			//Deleto registros existentes na SF3 para este documento

			cQuery := ""
			cQuery += "UPDATE " + RetSqlName("SF3") + " "
			cQuery += " SET D_E_L_E_T_ = '*' "
			cQuery += "WHERE F3_SERIE   = '" + SF2->F2_SERIE  + "' "
			cQuery += "AND   F3_NFISCAL = '" + SF2->F2_DOC + "' "
			cQuery += "AND   F3_FILIAL  = '" + xFilial("SF3")  + "' "
			cQuery += "AND   D_E_L_E_T_ <> '*' "
			cQuery += "AND   F3_CLIEFOR = '" + SF2->F2_CLIENTE  + "' "
			cQuery += "AND   F3_LOJA    = '" + SF2->F2_LOJA  + "' "
			cQuery += "AND   F3_CLIENT = '" + SF2->F2_CLIENTE  + "' "

			If (TCSQLExec(cQuery) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			//TOTALIZO VALORES
			cQuery := ""
			cQuery += "SELECT FT_FILIAL,FT_ENTRADA,FT_EMISSAO,FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA,FT_CFOP,FT_ALIQICM,FT_ESPECIE,FT_TIPOMOV,FT_CLIENT,FT_LOJENT,"
			cQuery += "SUM(FT_BASERET) AS FT_BASERET,SUM(FT_ICMSRET) AS FT_ICMSRET , SUM(FT_VALCONT) "
			cQuery += "AS FT_VALCONT,SUM(FT_BASEICM)AS FT_BASEICM,SUM(FT_VALICM) AS FT_VALICM , "
			cQuery += "SUM(FT_ISENICM) FT_ISENICM,SUM(FT_OUTRICM) FT_OUTRICM, SUM(FT_BASEIPI) FT_BASEIPI,SUM(FT_VALIPI) FT_VALIPI, "
			cQuery += "SUM(FT_ISENIPI) FT_ISENIPI,SUM(FT_ICMSCOM) FT_ICMSCOM, SUM(FT_ICMSDIF) FT_ICMSDIF,SUM(FT_TRFICM) FT_TRFICM, "
			cQuery += "SUM(FT_CRDEST)  FT_CRDEST,SUM(FT_IPIOBS) FT_IPIOBS,SUM(FT_OBSICM) FT_OBSICM,SUM(FT_OBSSOL) FT_OBSSOL, SUM(FT_SOLTRIB) FT_SOLTRIB, "
			cQuery += "SUM(FT_ICMAUTO) FT_ICMAUTO,SUM(FT_BASIMP1) FT_BASIMP1,SUM(FT_BASIMP2) FT_BASIMP2,SUM(FT_BASIMP3) FT_BASIMP3,SUM(FT_BASIMP4) FT_BASIMP4, "
			cQuery += "SUM(FT_BASIMP5) FT_BASIMP5,SUM(FT_BASIMP6) FT_BASIMP6, FT_ALQIMP1, FT_ALQIMP2, FT_ALQIMP3, "
			cQuery += "FT_ALQIMP4, FT_ALQIMP5, FT_ALQIMP6,SUM(FT_VALIMP1) FT_VALIMP1,SUM(FT_VALIMP2) FT_VALIMP2, "
			cQuery += "SUM(FT_VALIMP3) FT_VALIMP3,SUM(FT_VALIMP4) FT_VALIMP4,SUM(FT_VALIMP5) FT_VALIMP5,SUM(FT_VALIMP6) FT_VALIMP6,SUM(FT_RETIMP1) FT_RETIMP1, "
			cQuery += "SUM(FT_RETIMP1) FT_RETIMP2,SUM(FT_RETIMP3) FT_RETIMP3,SUM(FT_RETIMP4) FT_RETIMP4,SUM(FT_RETIMP5) FT_RETIMP5,SUM(FT_RETIMP6) FT_RETIMP6 "
			cQuery += "FROM " + RetSqlName("SFT") + " (NOLOCK) "
			cQuery += "WHERE FT_NFISCAL = '" + SF2->F2_DOC + "' "
			cQuery += "AND   FT_SERIE   = '" + SF2->F2_SERIE  + "' "
			cQuery += "AND   FT_FILIAL  = '" + xFilial("SFT")  + "' "
			cQuery += "AND   D_E_L_E_T_ <> '*' "
			cQuery += "AND   FT_CLIEFOR = '" + SF2->F2_CLIENTE  + "' "
			cQuery += "AND   FT_LOJA    = '" + SF2->F2_LOJA  + "' "
			cQuery += "AND   FT_CLIENT = '" + SF2->F2_CLIENTE  + "' "
			cQuery += "GROUP BY FT_FILIAL,FT_ENTRADA,FT_EMISSAO,FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA,FT_CFOP,FT_ALIQICM,FT_ESPECIE,FT_TIPOMOV,FT_CLIENT,FT_LOJENT, "
			cQuery += "FT_ALQIMP1,FT_ALQIMP2,FT_ALQIMP3,FT_ALQIMP4,FT_ALQIMP5,FT_ALQIMP6 "

			If Select("MFT") <> 0
				dbSelectArea("MFT")
				dbCloseArea()
			Endif

			TCQuery cQuery NEW ALIAS "MFT"

			dbSelectArea("MFT")
			dbGoTop()
			While !Eof()
				RecLock("SF3",.T.)
				SF3->F3_FILIAL  := MFT->FT_FILIAL
				SF3->F3_ENTRADA := CTOD(MFT->FT_ENTRADA)
				SF3->F3_EMISSAO := CTOD(MFT->FT_EMISSAO)
				SF3->F3_NFISCAL := MFT->FT_NFISCAL
				SF3->F3_SERIE   := MFT->FT_SERIE
				SF3->F3_CLIEFOR := MFT->FT_CLIEFOR
				SF3->F3_LOJA    := MFT->FT_LOJA
				SF3->F3_CFO     := MFT->FT_CFOP
				SF3->F3_ALIQICM := MFT->FT_ALIQICM
				SF3->F3_ESPECIE := MFT->FT_ESPECIE
				//					SF3->F3_TIPOMOV := MFT->FT_TIPOMOV
				SF3->F3_CLIENT  := MFT->FT_CLIENT
				SF3->F3_LOJENT  := MFT->FT_LOJENT
				SF3->F3_BASERET := MFT->FT_BASERET
				SF3->F3_ICMSRET := MFT->FT_ICMSRET
				SF3->F3_VALCONT := MFT->FT_VALCONT
				SF3->F3_BASEICM := MFT->FT_BASEICM
				SF3->F3_VALICM  := MFT->FT_VALICM
				SF3->F3_ISENICM := MFT->FT_ISENICM
				SF3->F3_OUTRICM := MFT->FT_OUTRICM
				SF3->F3_BASEIPI := MFT->FT_BASEIPI
				SF3->F3_VALIPI  := MFT->FT_VALIPI
				SF3->F3_ISENIPI := MFT->FT_ISENIPI
				SF3->F3_ICMSCOM := MFT->FT_ICMSCOM
				SF3->F3_ICMSDIF := MFT->FT_ICMSDIF
				SF3->F3_TRFICM  := MFT->FT_TRFICM
				SF3->F3_CRDEST  := MFT->FT_CRDEST
				SF3->F3_IPIOBS  := MFT->FT_IPIOBS
				SF3->F3_OBSICM  := MFT->FT_OBSICM
				SF3->F3_OBSSOL  := MFT->FT_OBSSOL
				SF3->F3_SOLTRIB := MFT->FT_SOLTRIB
				SF3->F3_ICMAUTO := MFT->FT_ICMAUTO
				SF3->F3_BASIMP1 := MFT->FT_BASIMP1
				SF3->F3_BASIMP1 := MFT->FT_BASIMP2
				SF3->F3_BASIMP1 := MFT->FT_BASIMP3
				SF3->F3_BASIMP1 := MFT->FT_BASIMP4
				SF3->F3_BASIMP1 := MFT->FT_BASIMP5
				SF3->F3_BASIMP1 := MFT->FT_BASIMP6
				SF3->F3_ALQIMP1 := MFT->FT_ALQIMP1
				SF3->F3_ALQIMP2 := MFT->FT_ALQIMP2
				SF3->F3_ALQIMP3 := MFT->FT_ALQIMP3
				SF3->F3_ALQIMP4 := MFT->FT_ALQIMP4
				SF3->F3_ALQIMP5 := MFT->FT_ALQIMP5
				SF3->F3_ALQIMP6 := MFT->FT_ALQIMP6
				SF3->F3_VALIMP1 := MFT->FT_VALIMP1
				SF3->F3_VALIMP2 := MFT->FT_VALIMP2
				SF3->F3_VALIMP3 := MFT->FT_VALIMP3
				SF3->F3_VALIMP4 := MFT->FT_VALIMP4
				SF3->F3_VALIMP5 := MFT->FT_VALIMP5
				SF3->F3_VALIMP6 := MFT->FT_VALIMP6
				SF3->F3_RETIMP1 := MFT->FT_RETIMP1
				SF3->F3_RETIMP2 := MFT->FT_RETIMP2
				SF3->F3_RETIMP3 := MFT->FT_RETIMP3
				SF3->F3_RETIMP4 := MFT->FT_RETIMP4
				SF3->F3_RETIMP5 := MFT->FT_RETIMP5
				SF3->F3_RETIMP6 := MFT->FT_RETIMP6
				MsUnLock("SF3")

				dbSelectArea("MFT")
				MFT->(dbSKIP())
			EndDo
		EndIf
	EndIf
	//********FIM CALCULOS PIEN

	DbSelectArea("SC9")
	DbSetOrder(6)
	DbGotop()
	DbSeek(xFilial("SC9")+SF2->F2_SERIE+SF2->F2_DOC,.T.)
	While !Eof()  .And. SC9->C9_FILIAL 	== xFilial("SC9");
	.And. SC9->C9_SERIENF == SF2->F2_SERIE;
	.And. SC9->C9_NFISCAL == SF2->F2_DOC

		If !EMPTY(SC9->C9_NFISCAL)
			DbSelectArea("SUA")
			DbSetOrder(8)
			DbGotop()
			If DbSeek(xFilial("SUA")+SC9->C9_PEDIDO,.T.)
				DbSelectArea("SUA")
				RecLock("SUA",.F.)
				SUA->UA_STATUS := "NF."
				SUA->UA_DOC		:= SC9->C9_NFISCAL
				SUA->UA_SERIE	:= SC9->C9_SERIENF
				SUA->UA_EMISNF	:= SF2->F2_EMISSAO//SC9->C9_DATALIB
				MsUnLock("SUA")
			EndIf
		EndIF

		DbSelectArea("SC9")
		SC9->(DbSkip())
	Enddo

	// Calculo PIS COFINS NF SAIDA-----------------------------------------------------------------------------------------------------
	cQuery := ""
	cQuery += "SELECT * "
	cQuery += "FROM " + RetSqlName("SD2") + " AS D2 (NOLOCK), " + RetSqlName("SB1") + " AS B1 (NOLOCK), " + RetSqlName("SF4") + " AS F4 (NOLOCK) "
	cQuery += "WHERE D2.D2_DOC = '" + SF2->F2_DOC + "' "
	cQuery += "AND D2.D2_SERIE  = '" + SF2->F2_SERIE  + "' "
	cQuery += "AND D2.D2_FILIAL  = '" + xFilial("SD2")  + "' "
	cQuery += "AND F4.F4_FILIAL = D2.D2_FILIAL  "
	cQuery += "AND F4.F4_CODIGO = D2.D2_TES   "
	cQuery += "AND F4.D_E_L_E_T_ <> '*' "
	cQuery += "AND B1.B1_FILIAL = D2.D2_FILIAL  "
	cQuery += "AND B1_COD = D2.D2_COD  "
	cQuery += "AND B1.D_E_L_E_T_ <> '*' "
	cQuery += "AND D2.D_E_L_E_T_ <> '*' "
	cQuery += "AND F4.F4_PISCOF < '4'  "

	If SM0->M0_CODIGO == "01" .OR. SM0->M0_CODIGO == "11" .OR. SM0->M0_CODIGO =="12" .OR. SM0->M0_CODIGO =="15"
		cQuery += "AND (B1.B1_PPIS > 0 OR B1.B1_PCOFINS > 0) "
	EndIf

	If Select("MTEMP") <> 0
		dbSelectArea("MTEMP")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "MTEMP"

	dbSelectArea("MTEMP")
	dbGoTop()
	While !Eof()

		DbSelectArea("SD2")
		DbSetOrder(4)
		DbGotop()
		DbSeek(xFilial("SD2")+MTEMP->D2_NUMSEQ,.T.)
		While !Eof()  .And. SD2->D2_FILIAL 	== xFilial("SD2");
		.And. SD2->D2_NUMSEQ == MTEMP->D2_NUMSEQ

			//Cálculo PIS COFINS COM BASE NO TOTAL E ALIQUOTA DO PRODUTO PARA AGRICOPEL
			If SM0->M0_CODIGO == "01" .OR. SM0->M0_CODIGO == "11" .OR. SM0->M0_CODIGO == "12" .OR. SM0->M0_CODIGO == "15"
				DbSelectArea("SD2")
				RecLock("SD2",.F.)
				SD2->D2_ALQIMP5 := MTEMP->B1_PCOFINS
				SD2->D2_ALQIMP6 := MTEMP->B1_PPIS

				/*
				SD2->D2_BASIMP5 := ROUND(MTEMP->D2_TOTAL + MTEMP->D2_ICMSRET + MTEMP->D2_VALIPI,4)
				SD2->D2_BASIMP6 := ROUND(MTEMP->D2_TOTAL + MTEMP->D2_ICMSRET + MTEMP->D2_VALIPI,4)
				SD2->D2_VALIMP5 := ROUND((((MTEMP->D2_TOTAL + MTEMP->D2_ICMSRET + MTEMP->D2_VALIPI)* MTEMP->B1_PCOFINS)/100),4)
				SD2->D2_VALIMP6 := ROUND((((MTEMP->D2_TOTAL + MTEMP->D2_ICMSRET + MTEMP->D2_VALIPI)* MTEMP->B1_PPIS)/100),4)
				*/

				SD2->D2_BASIMP5 := ROUND(MTEMP->D2_TOTAL + MTEMP->D2_VALIPI,4)
				SD2->D2_BASIMP6 := ROUND(MTEMP->D2_TOTAL + MTEMP->D2_VALIPI,4)
				SD2->D2_VALIMP5 := ROUND((((MTEMP->D2_TOTAL + MTEMP->D2_VALIPI)* MTEMP->B1_PCOFINS)/100),4)
				SD2->D2_VALIMP6 := ROUND((((MTEMP->D2_TOTAL + MTEMP->D2_VALIPI)* MTEMP->B1_PPIS)/100),4)

				MsUnLock("SD2")
			EndIf

			dbSelectArea("SD2")
			SD2->(dbSkip())

		EndDo

		dbSelectArea("MTEMP")
		MTEMP->(dbSkip())
	EndDo

	//- No momento que uma nota for faturada o ponto de entrada é executado, verificando através do tipo do produto se o mesmo é de manutenção,
	//se for, o sistema abastece com as informações de cliente e produto(retira estes dados da tabela SD2) a tabela AA3 (Base Instalada - TECA040),
	// nos campos AA3_CODCLI, AA3_LOJA, AA3_CODPRO, AA3_NUMSER, AA3_DTVEND.

	If SM0->M0_CODIGO == "01" .and. SM0->M0_CODFIL == "01"
		cQuery := ""
		cQuery += "SELECT * "
		cQuery += "FROM " + RetSqlName("SD2") + " AS D2, " + RetSqlName("SB1") + " AS B1 "
		cQuery += "WHERE D2.D2_DOC = '" + SF2->F2_DOC + "' "
		cQuery += "AND D2.D2_SERIE  = '" + SF2->F2_SERIE  + "' "
		cQuery += "AND D2.D2_FILIAL  = '" + xFilial("SD2")  + "' "
		cQuery += "AND B1.B1_FILIAL = D2.D2_FILIAL  "
		cQuery += "AND B1_COD = D2.D2_COD  "
		cQuery += "AND B1_TIPO = 'MS'  "
		cQuery += "AND B1.D_E_L_E_T_ <> '*' "
		cQuery += "AND D2.D_E_L_E_T_ <> '*' "

		cQuery := ChangeQuery(cQuery)
		If Select("MTEMP") <> 0
			dbSelectArea("MTEMP")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "MTEMP"

		dbSelectArea("MTEMP")
		dbGoTop()
		While !Eof()
			DbSelectArea("AA3")
			DbSetOrder(1)
			DbGotop()
			If !DbSeek(xFilial("AA3")+MTEMP->D2_CLIENTE,MTEMP->D2_LOJA,MTEMP->D2_COD,MTEMP->D2_COD,.T.)

				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³AQUI VOU BUSCAR QUAL A ULTIMA SERIE PARA ESTE PRODUTO NA BASE INSTALADA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

				cQuery := ""
				cQuery += "SELECT MAX(AA3_NUMSER) + 1 SERIE"
				cQuery += "FROM " + RetSqlName("AA3") + " AS AA3 "
				cQuery += "WHERE AA3.AA3_CODPRO = '" + MTEMP->D2_COD + "' "
				cQuery += "AND AA3.AA3_FILIAL  = '" + xFilial("AA3")  + "' "
				cQuery += "AND AA3.D_E_L_E_T_ <> '*' "

				cQuery := ChangeQuery(cQuery)
				If Select("MAA3") <> 0
					dbSelectArea("MAA3")
					dbCloseArea()
				Endif

				TCQuery cQuery NEW ALIAS "MAA3"

				dbSelectArea("MAA3")
				dbgotop()

				If Select("MAA3") <> 0
					nSerie := MAA3->SERIE
				Else
					nSerie := 1
				EndIf

				cPict := '@E 999999'
				cSerie := Transform( cPict, nSerie)

				RecLock("AA3",.T.)
				AA3->AA3_CODCLI := MTEMP->D2_CLIENTE
				AA3->AA3_LOJA   := MTEMP->D2_LOJA
				AA3->AA3_CODPRO := MTEMP->D2_COD
				AA3->AA3_NUMSER := cSerie
				AA3->AA3_DTVEND := MTEMP->D2_EMISSAO
				MsUnLock("AA3")
			EndIF
			MTEMP->(DBSKIP())
		EndDo
	EndiF

	VendArla()

	//Gera Tabela CD6 - Complemento de cobustível
	U_XAG0032()//GeraCD6()
	
	//Chamado[19655] - Gera título na SE1 quando for uma NDF
	If SF2->F2_TIPO == 'D'  .AND. U_XAG0053V(SF2->F2_FILIAL)     
	
		DbSelectarea('SE2')
		DbSetOrder(6)
		If Dbseek(xFilial('SE2') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL ) 
			U_XAG0053() 
		Else
			//Alert('Não foi encontrada NDF para essa Nota de devolução, Verifique!!')
			Alert('Não foi gerado título para o doc:'+SF2->F2_DOC+', Verifique!')
		Endif        
			
	Endif 	
	
Return()

Static Function VendArla()

	Local cQuery := ""

	IF (cEmpAnt == '01' .OR. cEmpAnt == '11' .OR. cEmpAnt == '12' .OR. cEmpAnt == '15' .OR. cEmpAnt == '16') .And. ;
	(AllTrim(SC5->C5_VEND6) <> '' .Or. AllTrim(SC5->C5_VEND7) <> '' .Or. AllTrim(SC5->C5_VEND8) <> '')

		dbSelectArea("SF2")
		RecLock("SF2",.F.)
		SF2->F2_VEND6 := SC5->C5_VEND6
		SF2->F2_VEND7 := SC5->C5_VEND7
		SF2->F2_VEND8 := SC5->C5_VEND8
		MsUnLock("SF2")

		cQuery := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
		cQuery += " FROM " + RetSqlName("SE1") + " AS SE1 (NOLOCK) "

		cQuery += " WHERE SE1.E1_NUM    = '" + SF2->F2_DOC + "' "
		cQuery += " AND SE1.E1_PREFIXO  = '" + ALLTRIM(SF2->F2_FILIAL) + SUBSTR(ALLTRIM(SF2->F2_SERIE),1,1)  + "' "
		cQuery += " AND SE1.E1_CLIENTE  = '" + SF2->F2_CLIENTE  + "' "
		cQuery += " AND SE1.E1_LOJA     = '" + SF2->F2_LOJA  + "' "

		cQuery += " AND SE1.E1_TIPO     = 'NF' "
		cQuery += " AND SE1.D_E_L_E_T_  <> '*' "

		cQuery := ChangeQuery(cQuery)
		If Select("TMP_SE1") <> 0
			dbSelectArea("TMP_SE1")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "TMP_SE1"

		dbSelectArea("TMP_SE1")
		dbGoTop()
		While !Eof()
			dbSelectArea("SE1")
			dbSetOrder(1)
			dbGotop()

			If DbSeek(xFilial("SE1")+TMP_SE1->E1_PREFIXO+TMP_SE1->E1_NUM+TMP_SE1->E1_PARCELA+TMP_SE1->E1_TIPO,.F.)
				RecLock("SE1",.F.)
				SE1->E1_XVEND6 := SF2->F2_VEND6
				SE1->E1_XVEND7 := SF2->F2_VEND7
				SE1->E1_XVEND8 := SF2->F2_VEND8
				MsUnLock("SE1")
			EndIf

			dbSelectArea("TMP_SE1")
			TMP_SE1->(DBSKIP())
		EndDo
	ENDIF

Return()     		  