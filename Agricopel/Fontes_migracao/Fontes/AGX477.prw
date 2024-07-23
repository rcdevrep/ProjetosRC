#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*/{Protheus.doc} AGX477
Acerto Saldo SB8
@author Microsiga
@since 06/02/2011
@return Sem retorno
@type function
/*/
User Function AGX477()

	Private cPerg := "AGX469"
	//ZERO SB8

	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Produto ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"02","Armazem ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Quantidade?","mv_ch3","N",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Lote     ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Tipo Movimento ?","mv_ch5","N",1,0,0,"C","","mv_par05","ENTRADA","","","SAIDA","","","","","","","","","","",""})

	//U_CriaPer(cPerg,aRegistros)

	Pergunte(cPerg,.T.)

	If MsgYesNo("Deseja atualizar saldos de lotes (SB8) ?" ,"Acerto Saldos SB8")

		cTipoMov := ""

		//Verifico se o produto possui lote informado

		/*	cQuery := ""
		cQuery += "SELECT * FROM SB8010 WHERE B8_LOCAL = '99'  AND D_E_L_E_T_ <> '*'"

		If (Select("QRYB8") <> 0)
		dbSelectArea("QRYB8")
		dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRYB8"

		dbSelectArea("QRYB8")
		dbGoTop()
		While !eof()   */

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbgoTop()
		if !dbseek(xFilial("SB1")+mv_par01)
			Alert("Atenção! Produto não encontrado!")
			return()
		EndIf

		If SB1->B1_RASTRO <> "L"
			Alert("Antenção! Este produdo não controla rastreabilidade!")
			return()
		EndIf

		//Verifico se o produto possui lote informado

		//   mv_par03 := nQtdDif

		cQuery := ""
		cQuery += "SELECT * "
		cQuery += "FROM " + RETSQLNAME("SB8") + " "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
		cQuery += "  AND B8_FILIAL = '"  + xFilial("SB8") + "' "
		cQuery += "  AND B8_LOCAL   = '"   + mv_par02 + "' "
		cQuery += "  AND B8_PRODUTO = '"   + mv_par01 + "' "
		cQuery += "  AND B8_LOTECTL = '"   + mv_par04 + "' "

		If (Select("QRY") <> 0)
			dbSelectArea("QRY")
			dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRY"

		dbSelectArea("QRY")
		dbGoTop()
		While !Eof()

			nQtdDif := 0
			nQtd    := mv_par03
			nQtdEnd := QRY->B8_SALDO

			Do Case
				Case nQtdEnd < 0
				nQtdDif := nQtd + (nQtdEnd*(-1))
				cTipoMov := "499" //entrada
				Case nQtd > nQtdEnd
				nQtdDif := nQtd - nQtdEnd
				cTipoMov := "499" //entrada
				Case nQtd < nQtdEnd
				nQtdDif := nQtdEnd - nQtd
				cTipoMov := "999" //saida
			EndCase

			cNumSeq := ProxNum()

			GravaSD5("INV",QRY->B8_PRODUTO,QRY->B8_LOCAL,QRY->B8_LOTECTL,QRY->B8_NUMLOTE,cNumSeq,"ACERTO","1",,;
			cTipoMov,"","",QRY->B8_LOTEFOR,nQtdDif,,dDatabase,StoD(QRY->B8_DTVALID))

			QRY->(dbSkip())
		EndDo

		/*  dbSelectArea("QRYB8")
		QRYB8->(dbSkip())
		EndDo   */
	EndIf

	MsgInfo("Procedimento Realizado Com Sucesso!")

Return()
