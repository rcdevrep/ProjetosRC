#Include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTATIP71  ºAutor  ³ Beto               º Data ³  20/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para gerar o registro tipo 71-Informações º±±
±±º          ³ de Carga Transportadora ao gerar livros em disquete.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Livros Fiscais                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTATIP71
**********************
//Local cAlias  := ParamIXB[1]
Local cAlias  := "SF3"
//Local cArq071 := SF3->(GetArea())
Local cNota   
Local aAlias  := SA1->(GetArea())
Local cCGCTom
Local cIETom
Local cEstTom
Local cCGCRem
Local cIERem
Local cEstRem
Local cTipTom
Local cTipRem
Local lAchouSZA

If AllTrim(Upper(FunName())) == "MATA940A"
	cNota   := (cAlias)->F3_NFiscal+(cAlias)->F3_Serie
	dDtCanc := (cAlias)->F3_DtCanc
Else
	cNota   := ParamIXB[2][1][1] + ParamIXB[2][1][2]
	dDtCanc := ParamIXB[2][1][13]
End

// Sincronizando o SZA com SF3
//SZA->(dbSetOrder(1)) // ZA_FILIAL+ZA_FRETE+ZA_SERIE
//lAchouSZA := SZA->(dbSeek(xFilial("SZA")+cNota))

//If (!lAchouSZA) .Or. (!Empty(dDtCanc)) .Or. (!Empty(SZA->ZA_Flag)) .Or. (!Empty(SZA->ZA_FlagFil))
	// Se a nota estiver cancelada ou não encontrada, não gera registro tipo 71, cfe convênio ICMS 31/99
//	Return
//End

//If AllTrim(SZA->ZA_Modal) == "C"
	// Se for CIF, o remetente paga
	
//	cCGCTom := SZA->ZA_CGCRem
//	cIETom  := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodRem+SZA->ZA_LojaRem,"A1_INSCR")
//	cEstTom := SZA->ZA_EstOri
//	cTipTom := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodRem+SZA->ZA_LojaRem,"A1_TIPO")
//	If cTipTom == "X"
//		// Se for exportação
//		cCGCTom := Space(14)
//		cIETom  := "ISENTO"
//	End
	
//	cCGCRem := SZA->ZA_CGCDest
//	cIERem  := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodDest+SZA->ZA_LojaDes,"A1_INSCR")
//	cEstRem := SZA->ZA_EstDest
//	cTipRem := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodDest+SZA->ZA_LojaDes,"A1_TIPO")
//	If cTipRem == "X"
		// Se for exportação
//		cCGCRem := Space(14)
//		cIERem  := "ISENTO"
//	End
	
//ElseIf AllTrim(SZA->ZA_Modal) == "F"
	// Se for FOB, o destinatário paga
//	cCGCTom := SZA->ZA_CGCDest

	DbSelectArea("SF3")
	DbSetOrder(6)
	DbGotop()
	DbSeek(xFilial("SF3")+cNota)	// CIF = Mime Distribuidora, FOB = Cliente , fazer busca cfe Ademir 30/09/2005
	cIETom  := Posicione("SA1",1,xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA,"A1_INSCR")
	cCGCTom := Posicione("SA1",1,xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA,"A1_CGC")
	cEstTom := Posicione("SA1",1,xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA,"A1_EST")
	cTipTom := Posicione("SA1",1,xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA,"A1_TIPO")
	*
	* Busca dados Transportador caso Nota Frete Cfe Ademir 30/09/2005
	*
	cPedido := Space(6)                                                                
	cPedido := Posicione("SD2",7,xFilial("SD2")+SF3->F3_PDV+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA,"D2_PEDIDO")
	If !Empty(cPedido)
		cTpFrete := Space(1)
		cTpFrete := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_TPFRETE")
	   If !Empty(cTpFrete) .And. cTpFrete = 'C' // Frete CIF busca dados transportador (Mime Distrib)
			cIETom  := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_INSEST")
			cCGCTom := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_CGC")
			cEstTom := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_EST")
         *
         * Carrega variaveis para uso no Registro 70 que eh montado apos aplicacao deste ponto de entrada
         *        Estas variaveis sao usadas no MATA940x(Customizado)
         *
			cTranspIns := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_INSEST")
			cTranspCGC := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_CGC")
			cTranspEst := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_EST")
		EndIf
	EndIf	
	*
	* Informacoes Destinario
	*
	cIERem  := Posicione("SA1",1,xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA,"A1_INSCR")
	cCGCRem := Posicione("SA1",1,xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA,"A1_CGC")
	cEstRem := Posicione("SA1",1,xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA,"A1_EST")

//	If cTipTom == "X"
		// Se for exportação
//		cCGCTom := Space(14)
//		cIETom  := "ISENTO"
//	End
	
//	cCGCRem := SZA->ZA_CGCRem
//	cIERem  := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodRem+SZA->ZA_LojaRem,"A1_INSCR")
//	cEstRem := SZA->ZA_EstOri
//	cTipRem := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodRem+SZA->ZA_LojaRem,"A1_TIPO")
//	If cTipRem == "X"
		// Se for exportação
//		cCGCRem := Space(14)
//		cIERem  := "ISENTO"
//	End
	
//ElseIf AllTrim(SZA->ZA_Modal) == "G"
	// Se for CONSIGNATÁRIO, o consignatário paga
	
//	cCGCTom := SZA->ZA_CGCCon
//	cIETom  := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodCon+SZA->ZA_LojaCon,"A1_INSCR")
//	cEstTom := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodCon+SZA->ZA_LojaCon,"A1_EST")
//	cTipTom := Posicione("SA1",1,xFilial("SA1")+SZA->ZA_CodCon+SZA->ZA_LojaCon,"A1_TIPO")
//	If cTipTom = "X"
		// Se for exportação
//		cCGCTom := Space(14)
//		cIETom  := "ISENTO"
//	End
	
//	cCodRem := SZA->ZA_CodRem+SZA->ZA_LojaRem
//	cCGCRem := SZA->ZA_CGCRem
//	cIERem  := Posicione("SA1",1,xFilial("SA1")+cCodRem,"A1_INSCR")
//	cEstRem := SZA->ZA_EstOri
//	cTipRem := Posicione("SA1",1,xFilial("SA1")+cCodRem,"A1_TIPO")
//	If cTipRem == "X"
		// Se for exportação
//		cCGCRem := Space(14)
//		cIERem  := "ISENTO"
//	End
//End

//SZB->(dbSetOrder(1)) // ZB_FILIAL+ZB_FRETE+ZB_SERIE
//SZB->(dbSeek(xFilial("SZB")+cNota))
//While SZB->(!Eof()) .And. (SZB->ZB_Filial+SZB->ZB_Frete+SZB->ZB_Serie == xFilial("SZB")+cNota) .And. (!Empty(SZB->ZB_Frete))
	// Efetuando gravação no temporário utilizado na rotina MATA940A de todas as notas fiscais do cliente (SZB)
If AllTrim(SF3->F3_ESPECIE) == 'CTR' .and. (AllTrim(SF3->F3_CFO) == '5353' .OR. AllTrim(SF3->F3_CFO) == '6353')
	If AllTrim(Upper(FunName())) == "MATA940A"
//		RecLock(cArq071,.t.)
//		(cArq071)->A71_CgcTom := cCGCTom
//		(cArq071)->A71_IETom  := fRemove(cIETom,"./-")
//		(cArq071)->A71_DtConh := (cAlias)->F3_Emissao
//		(cArq071)->A71_UFTom  := cEstTom
//		(cArq071)->A71_ModCon := "08"
//		(cArq071)->A71_SerCon := (cAlias)->F3_Serie
//		(cArq071)->A71_SubCon := ""
//		(cArq071)->A71_NumCon := (cAlias)->F3_NFiscal
//		(cArq071)->A71_UFRem  := cEstRem
//		(cArq071)->A71_CgcRem := cCGCRem
//		(cArq071)->A71_IERem  := fRemove(cIERem,"./-")
//		(cArq071)->A71_DtNota := (cAlias)->F3_Emissao
//		(cArq071)->A71_ModNot := "01"
//		(cArq071)->A71_SerNot := SF3->F3_SERIE 
//		(cArq071)->A71_NumNot := SF3->F3_NFISCAL
//		(cArq071)->A71_ValNot := SF3->F3_VALCONT
//		msUnLock(cArq071)
	Else
		RecLock("R71",.t.)
		R71->A71_CgcTom := cCGCTom
//		R71->A71_IETom  := fRemove(cIETom,"./-")
		R71->A71_IETom  := cIETom
		R71->A71_DtConh := (cAlias)->F3_Emissao
		R71->A71_UFTom  := cEstTom
		R71->A71_ModCon := "08"
		R71->A71_SerCon := (cAlias)->F3_Serie
		R71->A71_SubCon := ""
		R71->A71_NumCon := (cAlias)->F3_NFiscal
		R71->A71_UFRem  := cEstRem
		R71->A71_CgcRem := cCGCRem
//		R71->A71_IERem  := fRemove(cIERem,"./-")
		R71->A71_IERem  := cIERem
		R71->A71_DtNota := (cAlias)->F3_Emissao
		R71->A71_ModNot := "01"
		R71->A71_SerNot := (cAlias)->F3_SERIE 
		R71->A71_NumNot := (cAlias)->F3_NFISCAL
		R71->A71_ValNot := (cAlias)->F3_VALCONT
		msUnLock("R71")
	EndiF
	
//	SZB->(dbSkip())
//End 

EndIf

RestArea(aAlias)
Return

Static Function fRemove(cString, cCaracters)
********************************************
// Remove caracteres de uma string
Local i

For i := 1 to Len(cCaracters)
	cString := Strtran(cString,Substr(cCaracters,i,1),"")
Next i

Return(cString)
