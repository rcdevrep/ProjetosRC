#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*/{Protheus.doc} AGX468
ACERTO SALDOS SB2
@author Microsiga
@since 06/02/2011
@return Sem retorno
@type function
/*/
User Function AGX468()

	Private cPerg := "AGX468"
	aMov		:= {}

	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Produto        ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"})
	AADD(aRegistros,{cPerg,"02","Armazem        ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Quantidade     ?","mv_ch3","N",9,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})

	//U_CriaPer(cPerg,aRegistros)

	Pergunte(cPerg,.T.)

	If MsgYesNo("Deseja atualizar saldos gerenciais (SB2) ?" ,"Acerto Saldos SB2")

		cQuery := ""
		cQuery := " SELECT * FROM " + RetSqlName("SB2") + " "
		cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
		cQuery += "AND D_E_L_E_T_ <> '*' "
		cQuery += "AND B2_COD = '" + mv_par01 + "' "
		cQuery += "AND B2_LOCAL = '"  + mv_par02 + "' "

		If (Select("QRY") <> 0)
			dbSelectArea("QRY")
			dbCloseArea()
		Endif

		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "QRY"

		dbSelectArea("QRY")
		ProcRegua(500)
		dbGoTop()
		While !Eof()

			nQtdDif := 0
			nQtd   := mv_par03
			nQtdEnd := QRY->B2_QATU

			cTipoMov := "002" //Entrada
			alert(nQtdEnd)
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbgoTop()
			if !dbseek(xFilial("SB1")+QRY->B2_COD)
				Alert("Atenção! Produto não encontrado!")
				return()
			EndIf
			//Verifico o valor que deve estar em estoque

			Do Case
				Case nQtdEnd < 0
				nQtdDif := nQtd + (nQtdEnd*(-1))
				cTipoMov := "002" //Entrada
				Case nQtd > nQtdEnd
				nQtdDif := nQtd - nQtdEnd
				cTipoMov := "002" //Entrada
				Case nQtd < nQtdEnd
				nQtdDif := nQtdEnd - nQtd
				cTipoMov := "600" //saida
			EndCase

			cContLot := ""
			cContEnd := ""

			cContLot := SB1->B1_RASTRO
			cContEnd := SB1->B1_LOCALIZ

			RecLock("SB1",.F.)
			SB1->B1_RASTRO := "N"
			SB1->B1_LOCALIZ := "N"
			MsUnlock( )

			aMov := {}
			CONOUT(nQtdDif)
			AAdd(aMov,{'D3_TM'		,cTipoMov				,Nil})
			AAdd(aMov,{'D3_COD'		,QRY->B2_COD		,Nil})
			AAdd(aMov,{'D3_QUANT'   ,nQtdDif								,Nil})
			AAdd(aMov,{'D3_LOCAL'    ,QRY->B2_LOCAL	,Nil})
			//				AAdd(aMovSD3,{'D3_LOCALIZ'	,PadR(aProduto[n1Cnt,2],Len(SD3->D3_LOCALIZ))	,Nil})
			AAdd(aMov,{'D3_EMISSAO'	,dDataBase		  								,Nil})
			//				AAdd(aMovSD3,{'D3_LOTECTL'	,PadR(aProduto[n1Cnt,4],Len(SD3->D3_LOTECTL))	,Nil})
			//				AAdd(aMovSD3,{'D3_NUMLOTE'	,PadR(aProduto[n1Cnt,5],Len(SD3->D3_NUMLOTE))	,Nil})
			//				AAdd(aMovSD3,{'D3_NUMSERI'	,PadR(aProduto[n1Cnt,6],Len(SD3->D3_NUMSERI))	,Nil})

			lMsErroAuto := .F.
			Begin Transaction
				MSEXECAUTO({|x|MATA240(x)},aMov)
				If lMsErroAuto
					// Gravo o log de erro com 'LOT', mais o numero e serie da nota fiscal que nao conseguiu ser dado entrada
					////////////////////////////////////////////////////////////////////////////////////////////////////////////
					MostraErro("c:\" ,"aaa.txt")
					DisarmTransaction()
					break
				Endif
			End Transaction
			DbSelectArea("SB1")
			RecLock("SB1",.F.)
			SB1->B1_RASTRO := cContLot
			SB1->B1_LOCALIZ := cContEnd
			MsUnlock( )
			dbSelectArea("QRY")

			QRY->(dbskip())
		EndDo

		MsgInfo("Procedimento Realizado Com Sucesso!")
	EndIf
Return()

