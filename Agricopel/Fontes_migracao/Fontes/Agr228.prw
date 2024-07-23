#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR228   ºAutor  ³ Marcelo da Cunha   º Data ³  06/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho no Televendas nos campos C6_PRODUTO, C6_DESCONT e  º±±
±±º          ³  C5_TABELA                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR228()
********************
LOCAL aSeg := GetArea(), aSegSA1 := SA1->(GetArea()), aSegACO := ACO->(GetArea()), aSegSZ8 := SZ8->(GetArea())
LOCAL aSegACP := ACP->(GetArea()), aSegSB1 := SB1->(GetArea()), nSeg := N
LOCAL cCliente := M->C5_cliente , cLoja  := M->C5_lojacli, cTabela := M->C5_tabela    
LOCAL cVend1   := M->C5_vend1   , cVend2 := M->C5_vend2 , cVend3  := M->C5_vend3
LOCAL nComis1  := 0, nComis2 := 0, nComis3 := 0, nDesc := 0, nPos := 0, nLinIni := 0, nLinFim := 0
LOCAL lPromoc := .F., cProduto := Space(15), xRetu := &(ReadVar())
LOCAL lCall    := .F., lLubr := .F., lComb := .F.  

LOCAL nACP_DESMAX := 0  //Incluido por Valdecir em 01.03.04.   




	nPos  := aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRODUTO"})	
//	xRetu := cProduto := aCols[_e,nPos]


//RETURN(xRetu)  //NAO ESQUECER

//Se for campo do cabecalho recalcular os itens
///////////////////////////////////////////////
If (Alltrim(ReadVar()) == "M->C6_PRODUTO").or.(Alltrim(ReadVar()) == "M->C6_DESCONT")
	nLinIni  := N
	nLinFim  := N
Else
	nLinIni  := 1
	nLinFim  := Len(aCols)
Endif

For _e := nLinIni to nLinFim

	//Busco variaveis necessarias
	/////////////////////////////
	If (Alltrim(ReadVar()) == "M->C6_PRODUTO")    
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_DESCONT"})
		cProduto := M->C6_produto
		nDesc    := aCols[_e,nPos]
	Elseif (Alltrim(ReadVar()) == "M->C6_DESCONT")
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRODUTO"})
		cProduto := aCols[_e,nPos]
		nDesc    := M->C6_descont
	Else
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRODUTO"})
		cProduto := aCols[_e,nPos]
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_DESCONT"})
		nDesc    := aCols[_e,nPos]
	Endif

	lCall   := .F.
	lLubr   := .F.
	lComb   := .F.
	lPromoc := .F.
	nComis1 := 0
	nComis2 := 0
	nComis3 := 0

	//Verifico quais representantes vao ganhar comissao
	///////////////////////////////////////////////////
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)
		lCall := !(Substr(SB1->B1_grupo,1,1) $ "4/9")
		lLubr := !(Substr(SB1->B1_grupo,1,1) $ "1/4/9")
		lComb := (Substr(SB1->B1_grupo,1,1) == "1")
	Endif

	nACP_DESMAX := 0  //Incluido por Valdecir em 01.03.04.
			
	//Verifico se o produto possui uma regra de desconto
	////////////////////////////////////////////////////
	dbSelectArea("ACO")  
	dbSetOrder(2)
	dbSeek(xFilial("ACO")+cTabela,.T.)
	While !Eof().and.(xFilial("ACO") == ACO->ACO_filial).and.(ACO->ACO_codtab == cTabela)
		If (ACO->ACO_promoc == "S")
			dbSelectArea("ACP")
			dbSetOrder(1)
			dbSeek(xFilial("ACP")+ACO->ACO_codreg,.T.)
			While !Eof().and.(xFilial("ACP") == ACP->ACP_filial).and.(ACP->ACP_codreg == ACO->ACO_codreg)
				If (ACP->ACP_codpro == cProduto)

					//Incluido por Valdecir em 01.03.04.
					If nDesc < ACP->ACP_DESMAX
						nACP_DESMAX := ACP->ACP_DESMAX
					Else
						nACP_DESMAX := 0
					EndIf
					//=================================				

					If (lCall)
						nComis1 := ACP->ACP_comis
					Endif
					If (lLubr)
						nComis2 := ACP->ACP_comis2
					Endif
					If (lComb)
						nComis3 := ACP->ACP_comis3
					Endif
					lPromoc := .T.
				Endif
			   dbSkip()
			Enddo
		Endif	
		dbSelectArea("ACO")
		dbSkip()
	Enddo

	//Se nao for promocao busco do cadastro de clientes
	///////////////////////////////////////////////////
//	If (!lPromoc)
	If !lPromoc .or. nACP_DESMAX <> 0	 //Incluido por Valdecir em 01.03.04.	
		If nACP_DESMAX == 0  // Incluido por Valdecir em 01.03.04.	
			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1")+cCliente+cLoja)
				If (lCall)
					nComis1 := SA1->A1_comis 
				Endif
				If (lLubr)
					nComis2 := SA1->A1_comis2
				Endif
				If (lComb)
					nComis3 := SA1->A1_comis3
				Endif
			Endif
		EndIf
		//Se comissao estiver vazia no cadastro busco da tabela nova
		////////////////////////////////////////////////////////////
//		If Empty(nComis1).and.Empty(nComis2).and.Empty(nComis3)
		If Empty(nComis1).and.Empty(nComis2).and.Empty(nComis3).Or. nACP_DESMAX <> 0 //Incluido por Valdecir em 01.03.04		
			
			cTpClien := Space(01)
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+cCliente+cLoja)		
			If SA1->A1_SATIV1 == "999999"
				cTpClien := "I"				
			Else
				cTpClien := SA1->A1_TIPO
			EndIf
			
			dbSelectArea("SZ8")
			dbSetOrder(2)
			dbSeek(xFilial("SZ8")+cVend1+cTpClien,.T.)
			While !Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cVend1) .And. (SZ8->Z8_TPCLIEN == cTpClien)
				If (Round(nDesc,2) >= SZ8->Z8_descmin).and.(Round(nDesc,2) <= SZ8->Z8_descmax).and.(lCall)
				   nComis1 := SZ8->Z8_comis
				Endif
				dbSkip()
			Enddo
			dbSelectArea("SZ8")
			dbSetOrder(2)
			dbSeek(xFilial("SZ8")+cVend2+cTpClien,.T.)
			While !Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cVend2)  .And. (SZ8->Z8_TPCLIEN == cTpClien)
				If (Round(nDesc,2) >= SZ8->Z8_descmin).and.(Round(nDesc,2) <= SZ8->Z8_descmax).and.(lLubr)
				   nComis2 := SZ8->Z8_comis
				Endif
				dbSkip()
			Enddo
			dbSelectArea("SZ8")
			dbSetOrder(2)
			dbSeek(xFilial("SZ8")+cVend3+cTpClien,.T.)
			While !Eof().and.(xFilial("SZ8") == SZ8->Z8_filial).and.(SZ8->Z8_repre == cVend3)  .And. (SZ8->Z8_TPCLIEN == cTpClien)
				If (Round(nDesc,2) >= SZ8->Z8_descmin).and.(Round(nDesc,2) <= SZ8->Z8_descmax).and.(lComb)
				   nComis3 := SZ8->Z8_comis
				Endif
				dbSkip()
			Enddo
		Endif
	Endif

	//Alimento variaveis de comissao dos itens
	//////////////////////////////////////////
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_COMIS1"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis1
	Endif
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_COMIS2"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis2
	Endif
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_COMIS3"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis3
	Endif                                            

Next _e

//Retorno area original do arquivo
//////////////////////////////////
N := nSeg
RestArea(aSegSA1)
RestArea(aSegSB1)
RestArea(aSegACO)
RestArea(aSegACP)
RestArea(aSegSZ8)
RestArea(aSeg)             

//SysRefresh()

Return xRetu