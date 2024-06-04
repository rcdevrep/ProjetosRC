#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"
#include "FWMVCDef.ch"

// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTEC04 - BOTAO "SALVAR - ENVIAR PARA RECEBIMENTO" (MATA103)
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024

USER FUNCTION RCTEC04(l103Class)

	Local nY,nX
	Local cItPCNew	:= ""
	Local nQtdPCNew	:= 0
	Local lMT103CLAS := .T.
	Local lVerif := .F.
	Local lTit := .F.

	//PEGO DO PADRAO A103GrvCla
	If l103Class

		aCamposAd := {	{"D1_BASIMP6","IT_BASEPS2"},{"D1_ALQIMP6","IT_ALIQPS2"},{"D1_VALIMP6","IT_VALPS2"},;
			{"D1_BASIMP5","IT_BASECF2"},{"D1_ALQIMP5","IT_ALIQCF2"},{"D1_VALIMP5","IT_VALCF2"},;
			{"D1_BASEPS3","IT_BASEPS3"},{"D1_ALIQPS3","IT_ALIQPS3"},{"D1_VALPS3","IT_VALPS3"}, ;
			{"D1_VALFRE","IT_FRETE"},{"D1_DESPESA","IT_DESPESA"},{"D1_SEGURO","IT_SEGURO"}, ;
			{"D1_BASECF3","IT_BASECF3"},{"D1_ALIQCF3","IT_ALIQCF3"},{"D1_VALCF3","IT_VALCF3"},{"D1_BASEDES","IT_BASEDES"},{"D1_ICMSDIF","IT_ICMSDIF"}}

		For nX := 1 to Len(aCols)

			lRecZero	:= .F.
			nRec		:= aCols[nX,Len(aCols[nX])-1]

			If nRec == 0 //Inclusão via Pedido (Documento)
				nRec := A103RECD1(aCols[nX,GetPosSD1("D1_ITEM")])
				lRecZero := .T.
			Endif

			lAtuPC := .F.

			//Posicionamento no R_E_C_N_O_
			SD1->(MsGoto(nRec))

			cPCAnt    := SD1->D1_PEDIDO
			cItPCAnt  := SD1->D1_ITEMPC
			nQtdPCAnt := GetAdvFVal("SC7","C7_QUANT",cFilAnt + cPCAnt + cItPCAnt,14)

			For nY := 1 To Len(aHeader)
				If aHeader[nY][10] # "V" .And. !IsHeadRec( aHeader[nY,01] ) .And. !IsHeadAlias( aHeader[nY,01] ) .And. AllTrim(aHeader[nY,02]) # "D1_TESACLA"
					If AllTrim(aHeader[nY,02]) == "D1_PEDIDO"
						cPCNew := aCols[nX][nY]
					Elseif AllTrim(aHeader[nY,02]) == "D1_ITEMPC"
						cPCItNew := aCols[nX][nY]
					Elseif AllTrim(aHeader[nY,02]) == "D1_QUANT"
						nQtdPCNew := aCols[nX][nY]
					Endif
				EndIf
			Next nY

			//Não tinha vinculo e foi vinculado na classificação
			If Empty(cPCAnt) .And. !Empty(cPCNew)
				lAtuPC := .T.

				//Ja tinha vinculo, mas mudou o PC
				//Com isso e ajustado o PC antigo para depois atualizar o novo
			Elseif !Empty(cPCAnt) .And. cPCAnt <> cPCNew
				MaAvalSD1(2,"SD1")
				lAtuPC := .T.

				//Ja tinha vinculo, mas mudou o item do PC
				//Com isso e ajustado o PC antigo para depois atualizar o novo
			Elseif !Empty(cPCAnt) .And. cPCAnt == cPCNew .And. cItPCAnt <> cItPCNew
				MaAvalSD1(2,"SD1")
				lAtuPC := .T.

				//Ja tinha vinculo, mas alterou a quantidade
				//PC é atualizado
			Elseif !Empty(cPCAnt) .And. cPCAnt == cPCNew .And. cItPCAnt == cItPCNew .And. nQtdPCAnt <> nQtdPCNew
				lAtuPC := .T.
			Endif

			RecLock("SD1",.F.)

			For nY := 1 To Len(aHeader)
				If aHeader[nY][10] # "V" .And. !IsHeadRec( aHeader[nY,01] ) .And. !IsHeadAlias( aHeader[nY,01] ) .And. AllTrim(aHeader[nY,02]) # "D1_TESACLA"
					If AllTrim(aHeader[nY,02]) == "D1_TES"
						SD1->(FieldPut(FieldPos("D1_TESACLA"),aCols[nX][nY]))
					Else
						If lRecZero
							If AllTrim(aHeader[nY,02]) == "D1_DOC"
								SD1->(FieldPut(FieldPos(aHeader[nY][2]),cNFiscal))
							ElseIf AllTrim(aHeader[nY,02]) == "D1_SERIE"
								SD1->(FieldPut(FieldPos(aHeader[nY][2]),cSerie))
							ElseIf AllTrim(aHeader[nY,02]) == "D1_FORNECE"
								SD1->(FieldPut(FieldPos(aHeader[nY][2]),cA100For))
							ElseIf AllTrim(aHeader[nY,02]) == "D1_LOJA"
								SD1->(FieldPut(FieldPos(aHeader[nY][2]),cLoja))
							Else
								SD1->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
							Endif
						Else
							SD1->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
						Endif
					EndIf
				EndIf
			Next nY

			If lAtuPC
				MaAvalSD1(1,"SD1")
			Endif

			// Salva valores de impostos para campos não usados (PIS / COFINS)
			For nY := 1 To Len(aCamposAd)
				SD1->(FieldPut(FieldPos(aCamposAd[nY][1]),MaFisRet(nX,aCamposAd[nY][2])))
			Next nY

			// Controle para processo de Guarda Fiscal (cliente Todimo)
			// Ao classificar novamente a nota, os valores fiscais digitados nao devem ser recalculados na funcao MontaAcols
			SD1->D1_ORIGEM := "GF"
			lGFGrvD1 := .T.

		Next nX
	
			//MUDA O STATUS PARA Z (PENDENTE DE RECEBIMENTO) E LIMPA O RECEBIMENTO
			RECLOCK("SF1", .F.)
			SF1->F1_XSTATUS = "Z"
			SF1->F1_RECBMTO = STOD("")
			MSUNLOCK()

			
			//FECHA A TELA
			oGetDados:oBrowse:oParent:End()

	EndIf



RETURN .T.
