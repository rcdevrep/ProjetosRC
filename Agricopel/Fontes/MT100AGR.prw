#INCLUDE "RWMAKE.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT100AGR
APOS A GRAVACAO DA NF FORA DA TRANSACAO                 
O ponto de entrada é chamado apos a inclusao da NF, porem fora da transacao.                                
Isto foi feito pois clientes que utilizavam TTS e tinham
interface com o usuario no ponto MATA100 "travavam" os
registros utilizados, causando parada para outros 
usuarios que estavam acessando a base.
@author Microsiga
@since 24/10/08
@version 1
@type function
/*/
User Function MT100AGR()

	//SOMENTE PARA AGRICOPEL, DIESEL PARANA e TRR MARTENDAL
	//Removida empresa 16 dessa validacao pois precisava atender o chamado 62797, ERRO BASE DE PIS E COFINS
	If SM0->M0_CODIGO == "01" .OR. SM0->M0_CODIGO == "11" .OR. SM0->M0_CODIGO == "12" .OR. SM0->M0_CODIGO == "15" .OR. SM0->M0_CODIGO == "19"

		cQuery := ""
		cQuery += " SELECT D1_COD AS PRODUTO, "
		cQuery += "        D1_BRICMS AS RETICMS, "
		cQuery += "        D1_QUANT AS QUANT "

		cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK) "

		cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "'"
		cQuery += " AND D1_DOC      = '" + SF1->F1_DOC    + "'"
		cQuery += " AND D1_SERIE    = '" + SF1->F1_SERIE  + "'"
		cQuery += " AND D1_FORNECE  = '" + SF1->F1_FORNECE  + "'"
		cQuery += " AND D1_LOJA 	= '" + SF1->F1_LOJA  + "'"
		cQuery += " AND D1_BRICMS > 0 "

		If Select("MT100AGR") <> 0
			dbSelectArea("MT100AGR")
			dbCloseArea()
		EndIf

		TCQuery cQuery NEW ALIAS "MT100AGR"

		DbSelectArea("MT100AGR")
		DbGoTop()
		While !Eof()
			DbSelectArea("SB1")
			DbSeek(xFilial("SB1")+MT100AGR->PRODUTO,.T.)
			//cE5_VALOR := Transform(nE5_VALOR,"@E 999999999999,99")
			RecLock("SB1",.F.)
			SB1->B1_BASEIST := Round((MT100AGR->RETICMS / MT100AGR->QUANT),2)
			MsUnLock("SB1")
			DbSelectArea("MT100AGR")
			DbSkip()
		EndDo

		/* Chamado 438758 - Estava sobreescrevendo os valores preenchidos na nota e não considerava desconto. 
		cQuery := ""
		cQuery += " SELECT * "           
		cQuery += " FROM " + RetSqlName("SD1") + " AS D1 (NOLOCK), " + RetSqlName("SB1") + " AS B1 (NOLOCK), " + RetSqlName("SF4") + " AS F4 (NOLOCK) "
		cQuery += " WHERE D1.D1_DOC = '" + SF1->F1_DOC + "' "      
		cQuery += " AND D1.D1_SERIE  = '" + SF1->F1_SERIE  + "' "   
		cQuery += " AND D1.D1_SERIE  = '" + SF1->F1_SERIE  + "' "   
		cQuery += " AND D1.D1_FORNECE = '" + SF1->F1_FORNECE  + "' "   
		cQuery += " AND D1.D1_LOJA  = '" + SF1->F1_LOJA  + "' "   	
		cQuery += " AND D1.D1_FILIAL  = '" + xFilial("SD1")  + "' "
		cQuery += " AND F4.F4_FILIAL = D1.D1_FILIAL  "
		cQuery += " AND F4.F4_CODIGO = D1.D1_TES   "
		cQuery += " AND F4.D_E_L_E_T_ <> '*' "
		cQuery += " AND B1.B1_FILIAL = D1.D1_FILIAL  "
		cQuery += " AND B1_COD = D1.D1_COD  "
		cQuery += " AND B1.D_E_L_E_T_ <> '*' "
		cQuery += " AND D1.D_E_L_E_T_ <> '*' "
		cQuery += " AND F4.F4_PISCOF < '4'  "
		cQuery += " AND (B1.B1_PPIS > 0 OR B1.B1_PCOFINS > 0) "

		If Select("MTEMP") <> 0
			dbSelectArea("MTEMP")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "MTEMP"
        
		dbSelectArea("MTEMP")
		dbGoTop()                   
		While !Eof()
      
			DbSelectArea("SD1")
			DbSetOrder(4)
			DbGotop()
			DbSeek(xFilial("SD1")+MTEMP->D1_NUMSEQ,.T.)

			While !Eof()  .And. SD1->D1_FILIAL 	== xFilial("SD1") .And. SD1->D1_NUMSEQ == MTEMP->D1_NUMSEQ

				DbSelectArea("SD1")
				RecLock("SD1",.F.)
					SD1->D1_ALQIMP5 := MTEMP->B1_PCOFINS
					SD1->D1_ALQIMP6 := MTEMP->B1_PPIS
					SD1->D1_BASIMP5 := ROUND(MTEMP->D1_TOTAL + MTEMP->D1_ICMSRET + MTEMP->D1_VALIPI,4)
					SD1->D1_BASIMP6 := ROUND(MTEMP->D1_TOTAL + MTEMP->D1_ICMSRET + MTEMP->D1_VALIPI,4)
					SD1->D1_VALIMP5 := ROUND((((MTEMP->D1_TOTAL + MTEMP->D1_ICMSRET + MTEMP->D1_VALIPI)* MTEMP->B1_PCOFINS)/100),4)
					SD1->D1_VALIMP6 := ROUND((((MTEMP->D1_TOTAL + MTEMP->D1_ICMSRET + MTEMP->D1_VALIPI)* MTEMP->B1_PPIS)/100),4)
				MsUnLock("SD1")

				dbSelectArea("SD1")
				SD1->(dbSkip())
			EndDo

			dbSelectArea("MTEMP")
			MTEMP->(dbSkip())
		EndDo*/
	EndIf

	If (SF1->F1_STATUS == "A")
		
		DbSelectarea('SF1')
		If (SF1->(FieldPos("F1_ZDTCLAS") > 0))
			RecLock("SF1")		
				SF1->F1_ZDTCLAS := Date()
				SF1->F1_ZHRCLAS := Substr(Time(),1,5)
				SF1->F1_ZUSRCLA := UsrRetName(RetCodUsr())
			SF1->(MsUnlock())
		EndIf

	EndIf
 
Return()
