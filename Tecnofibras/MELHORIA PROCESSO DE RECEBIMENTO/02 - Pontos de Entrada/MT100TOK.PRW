#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100TOK  ºAutor  ³ Marcelo da Cunha   º Data ³  04/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para validar se titulo nao esta vencimento        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*	---------------------------------------------------------------------------------------------------
	Alteração 13-12-2021
	Por Adriano Zanella Junior
	Cria uma trava para não permirtir notas com numeração duplicada por cliente e série.
	Solicitado por Luciana Vidaletti em 10-12-2021, no chamado 4432
	---------------------------------------------------------------------------------------------------
*/

User Function MT100TOK()
	**********************
	Local _xz
	//Local _x
	Local _y, _z, x
	//LOCAL aSeg := GetArea()
	Local aCond := {}, _i, lCondVenc := .F.
	//Local lEntrou := .F.
	Local lRetu := .T., lCondPrazo := .F.
	Local lAmbProd := .F.

	// 24/05/2016 - Marlon (Sensus): inserido o trecho abaixo para não ocorrer erro na inutilização da NF de Saída
	If IsInCallStack("MATA920")
		Return(.T.)
	EndIf

	aCond 		:= Condicao(1000,cCondicao,,DDEMISSAO)
	_nPosTES    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
	_nPosPedido := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})
	_nPosItemPC := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC"})
	_nPosProduto:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
	_nPosItem   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
	_nPosTipo   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TIPO"})
	_nPosTipo   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_FORNECE"})
	_nPosTipo   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOJA"})
	_nTaHeader  := Len(aHeader)+1
	aDif 		:= {}
	cMsg		:= ""
	lAntecip 	:= .F.
	lPrazo	 	:= .F.

	If !l103Auto
		If l103Class
			SF1->(DbSetOrder(1))
			cNfiscal := SF1->F1_DOC
			cSerie 	 := SF1->F1_SERIE
		Endif
	Endif

	If cFormul == 'N' .And. !l103Auto
		/*If (Msdate() - Ddemissao) >= 365
			MsgInfo("Data Emissao Nao Pode ser Maior que 12 Meses","Atenção!")
			Ddemissao := Msdate()			
			Return(.F.)		
		Endif*/
		For _xz :=1 To Len(cnFiscal)
			If (asc(substr(cnfiscal,_xz,_xz)) < 48 .Or. asc(substr(cnfiscal,_xz,_xz)) > 57) .AND. asc(substr(cnfiscal,_xz,_xz)) != 32
				MsgInfo("Numero da Nota Fiscal nao Pode Ser Letra","Atenção!")
				cnFiscal := space(9)
				Return(.F.)
				Exit
			Else
				If cTipo == 'C' //Tipo da NF
					cEspecie := 'CTR'
				Endif
			Endif
		Next
		//Incluido em 11/01/2013    
		If Substr(M->F1_CHVNFE,21,2) == '57'
			cEspecie :=	'CTE'
		Endif
		//Incluido em 11/01/2013
		If Substr(M->F1_CHVNFE,21,2) == '55'
			cEspecie :=	'SPED'
		Endif	

	ElseIf cFormul == 'S'
		cEspecie	:=	'SPED'
	Endif

	If Sm0->M0_Codigo $ "11,30"
		Return(.T.)
	Endif

	If !l103Auto
		If SE4->E4_PGTANTE $ "1/2"
			lAntecip := .T.
		Endif
		If SE4->E4_PGTANTE == "3"
			lPrazo := .T.
		Endif                   	

		If cTipo == "N" //SO NF NORMAIS
			For _y := 1 to len(aCols)
				If !(aCols[_y][_nTaHeader])
					cPedido 	:= aCols[_y][_nPosPedido]
					cItemPC		:= aCols[_y][_nPosItemPC]
					cProduto 	:= aCols[_y][_nPosProduto]
					cItem		:= aCols[_y][_nPosItem]
					DbSelectArea("SC7")
					DbSetOrder(1)
					If DbSeek(xFilial("SC7")+cPedido+cItemPC,.T.)
						cCond := SC7->C7_COND
						If cCond != cCondicao
							cDescCond := Space(15)
							DbSelectArea("SE4")
							DbSetOrder(1)
							If DbSeek(xFilial("SE4")+cCond)
								cDescCond := AllTrim(SE4->E4_DESCRI)
							EndIf
							DbCloseArea()
							aadd(aDif,{cItem,cProduto,cCond,cPedido,cItemPC,cDescCond})
						Endif 
					Endif
				Endif
			Next _y		

			If !Empty(aDif)
				For _z := 1 to len(aDif)
					cMsg += aDif[_z,1]+" - "+alltrim(aDif[_z,2])+" - "+aDif[_z,6]+"  -  "+aDif[_z,3]+"   -   "+aDif[_z,4]+"  -  "+aDif[_z,5]+Chr(13)
				Next _z
				/*MsgStop("Itens c/ Condicao de Pagamento diferente da Condicao da NF: "+Chr(13)+;
				"Item  -  Produto - Condicao - Pedido - Item Pedido"+Chr(13)+;
				cMsg)*/
				cMsg := "Itens com Condição de Pagamento diferente da Condição da NF:"+Chr(13)+;
				"Item - Produto - Condição - Desc. Condição - Pedido - Item Pedido"+Chr(13)+;
				cMsg+Chr(13)+;
				"Deseja Continuar Mesmo Assim?"
				If !MsgYesNo(cMsg,"MT100TOK - Condição de Pagamento Diferente")
					Return .F.
				EndIf
			Endif

			//INICIO - TRATA CONDICAO VENCIDA
			For _i := 1 to Len(aCond)
				If (aCond[_i,1] < MsDate())
					lCondVenc := .T.
					Exit
				Endif
				//If (aCond[_i,1] < MsDate()+7) - Desabilitado em 07/08/2013 - Solicitacao Diego
				If (aCond[_i,1] < MsDate()+1) //- Habilitado em 07/08/2013 - Solicitacao Diego
					lCondPrazo := .T.
					Exit
				Endif
			Next _i		

			If lCondVenc
				For x := 1 to Len(aCols)
					cTes := (aCols[x][_nPosTES])
					SF4->(dbSetorder(1))
					SF4->(DbSeek(xFilial("SF4")+cTES,.T.))
					If SF4->F4_DUPLIC != "N" .AND. !(aCols[x][_nTaHeader]) .AND. !lAntecip
						MsgStop("Nao é possivel lançar Nota Fiscal com titulos vencidos!")
						Return .F.					
					Endif
				Next x

			ElseIf lCondPrazo
				For x := 1 to Len(aCols)
					cTes := (aCols[x][_nPosTES])
					SF4->(dbSetorder(1))
					SF4->(DbSeek(xFilial("SF4")+cTES,.T.))
					If SF4->F4_DUPLIC != "N" .AND. !(aCols[x][_nTaHeader]) .AND. !lPrazo
						//MsgStop("Nao é possivel lançar Nota Fiscal com vencimento menor que 7 dias!")
						MsgStop("Nao é possivel lançar Nota Fiscal com vencimento menor que 1 dia!")
						Return .F.					
					Endif
				Next x
			EndIf

			// Veririca se fornecedor é de SC, devido a isenção de ICMS
			If !l103Auto .And. SM0->M0_CEPCOB == 'SC'

				_Fornec		:=	CA100FOR
				_Lojaf		:=	CLoja

				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				SA2->(DbSeek(xFilial("SA2")+_Fornec+_Lojaf))

				If SA2->A2_EST == 'SC'
					If MsgYesNo("Fornecedor é de Santa Catarina, Quanto ao ICMS está Correto?","Atenção!")
						lRetu	:=	.T.
					Else
						lRetu	:=	.F.
					Endif
				Else
					lRetu	:=	.T.
				Endif
			Else
				lRetu	:=	.T.
			Endif
		Endif
	Endif
	//RestArea(aSeg)
	 
	If UPPER(AllTrim(GetEnvServer())) $ "ENVIRONMENT"
		lAmbProd := .T.
	else
		MsgAlert("Ambiente de Teste "+UPPER(AllTrim(GetEnvServer())), "MT100OK!")
	Endif
	/*
	If l103Class
		MsgAlert("Classificação de Nota", "MT100OK!")
	Else
		MsgAlert("Não é Classificação de Nota", "MT100OK!")
	End
	*/

		If !l103Class .AND. (( AllTrim(CTIPO) == "C" .AND. AllTrim(CTPCOMPL) == "3") .OR. AllTrim(cEspecie) == "CTE")
			//MsgInfo("Nota de Entrada de Frete", "MT100TOK")
			cNumNF := REPLICATE('0',9-Len(AllTrim(CNFISCAL)))+AllTrim(CNFISCAL)
			cSerieNF := REPLICATE('0',3-Len(AllTrim(CSERIE)))+AllTrim(CSERIE)
			cFornecedor := AllTrim(CA100FOR)
			cForLoja := AllTrim(CLOJA)
			cTipoNF := AllTrim(CTIPO)

			lRetu := lRetu .AND. lCkNumNF(cNumNF, cSerieNF, cFornecedor, cForLoja, cTipoNF)
		EndIf
		lRet := lRetu .and. U_GTPE005() // CONEXAO NFE

		// RC CONSULTORIA - 07/05/2024

		//PEGA A NATUREZA DA TELA DE DOCUMENTO DE ENTRADA
		cNat := MaFisRet(,"NF_NATUREZA")

		IF lRet
			IF SF1->F1_STATUS == ' ' .AND. SF1->F1_XSTATUS == ' '

				IF SELECT("TMPD1")
					DbSelectArea("TMPD1")
					DbCloseArea()
				ENDIF
				
				cQryD1 := "SELECT * FROM SD1010 "
				cQryD1 += "WHERE D1_DOC = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"' AND D1_FORNECE = '"+SF1->F1_FORNECE+"' AND D1_LOJA = '"+SF1->F1_LOJA+"' AND D_E_L_E_T_ <> '*' "
				TCQuery cQryD1 NEW ALIAS "TMPD1"

				cConta := SUBSTR(TMPD1->D1_CONTA,1,4) 

				WHILE TMPD1->(!EOF())
					IF (cConta == "1131" )
						U_RCTEC04(l103Class)
						FWAlertSuccess("Enviado para Recebimento! ", "Sucesso")
						RETURN .F.
					ENDIF
					TMPD1->(DBSKIP())
				END
				IF MsgYesNo("Deseja Enviar para Recebimento?", "Confirma", .T.)
					U_RCTEC04(l103Class)
					FWAlertSuccess("Enviado com sucesso! ", "Sucesso")
					RETURN .F.
				ELSE
					IF !EMPTY(cNat) 
						IF MsgYesNo("Deseja Classificar a Nota?", "Confirma", .T.)
							FWAlertSuccess("Classificada com Sucesso!", "Sucesso")
							RETURN .T.
						ELSE
							FWAlertInfo("Nota Nao Classificada", "Cancelado")
							RETURN .F.
						ENDIF
					ELSE
						FWAlertInfo("Para este caso Preencha a Natureza!", "Em Branco")
						RETURN .F.
					ENDIF
				ENDIF
			ENDIF
			//ELSEIF SF1->F1_XSTATUS = 'Z'
				IF l103Class
					RETURN .T.
				ENDIF
				//ELSE
				//	FWAlertError("Nota Já Enviada para Recebimento", "RCTEC05")
				//	RETURN .F.
				//ENDIF
			//ENDIF

		ENDIF
Return lRet

/*/{Protheus.doc} lCkNumNF
	(long_description)
	@type  Static Function
	@author Adriano Zanella Junior
	@since 11/04/2022
	@version 1.0
	@param cNum, Character(9), Numero da Nota
	@param cSerie, Character(9), Série da Nota
	@param cForne, Character(9), Código do Fornecedor da Nota
	@param cLoja, Character(9), Loja do Fornecedor da Nota
	@param cTipo, Character(9), Tipo da Nota
	@return lRet, Logico, Verdadeiro de não encontrou nota repetida. Falso se encontrou nota repetida
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lCkNumNF(cNum, cSerie, cForne, cLoja, cTipo)
	Local lRet := .T.

	cCkRep := "SELECT	F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO "
	cCkRep += "FROM	SF1010 "
	cCkRep += "WHERE	D_E_L_E_T_ = '' "
	cCkRep += "		AND F1_DOC = '"+cNum+"'	 AND F1_SERIE = '"+cSerie+"' "
	cCkRep += "		AND F1_FORNECE = '"+cForne+"' AND F1_LOJA = '"+cLoja+"' "
	cCkRep += "		AND F1_TIPO = '"+cTipo+"' "

	If Select("_SF1RP")
		DbSelectArea("_SF1RP")
		DbCloseArea()
	EndIf
	TCQuery cCkRep NEW ALIAS "_SF1RP"
	DbSelectArea("_SF1RP")
	If _SF1RP->(!Eof())
		lRet := .F.
	EndIf
	DbCloseArea()

Return lRet
