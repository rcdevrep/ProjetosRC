#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100LOK  ºAutor  ³Jaylson Ribeiro     º Data ³  30/01/04		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para efetuar concistencias na linha da		º±±
±±º          ³ nota fiscal													º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT100LOK()
	Local _lPassou := .T.
	Local nPreco  := 0
	Local aCFOPs := {"1911","1910","2911","2910"}
	/*	Os Produtos 47.X, 48.X, 51.X, 52.X, 61.X, 63.X, 64.X e 65.X devem ter as contas contábéis entre 14110003 e 14110099 ou 14130001 e 14130099,
		 ou ser das contas41220041 ou 42220024.
		As contas entre 14110003 e 14110099, ou as contas 41220041 ou 42220024 devem ter produtos com os códigos acima.
		A pedido da Geslaine	*/
	/*Local aProdG1 := {"47","48","51","52","61","63","64","65"}
	Local aRng1G1 := {"14110003","14110099"}
	Local aRng2G1 := {"14130001 ","14130099"}
	Local aCntG1 := {"41220041","42220024"}*/

	_Fornec		:=	CA100FOR
	_cTipo	:=	CTIPO
	_cEspDoc := CESPECIE
	_nTaHeader  := Len(aHeader)+1
	_nPosProd	:= ASCAN(aHeader,{|x| alltrim(x[2]) == "D1_COD"})
	_nPosPed    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})
	_nPosItP	:= ASCAN(aHeader,{|x| alltrim(x[2]) == "D1_ITEMPC"})
	nPosVunit	:= ASCAN(aHeader,{|x| alltrim(x[2]) == "D1_VUNIT"}) 
	nPosQuant	:= ASCAN(aHeader,{|x| alltrim(x[2]) == "D1_QUANT"})
	nPosLtFor	:= AScan(aHeader,{|x| allTrim(x[2]) == "D1_LOTEFOR"})
	_nPosCC		:= AScan(aHeader,{|x| allTrim(x[2]) == "D1_CC"})
	_nPosConta	:= AScan(aHeader,{|x| allTrim(x[2]) == "D1_CONTA"})
	_nPosTES	:= AScan(aHeader,{|x| allTrim(x[2]) == "D1_TES"})
	_nPosCFOP	:= AScan(aHeader,{|x| allTrim(x[2]) == "D1_CF"})

	If	FwIsInCallStack('U_GATI001')	// Conexão NFE
        U_GTPE004()
    EndIf
	
	cCusto := AllTrim(aCols[n][_nPosCc])
	cConta := Alltrim(aCols[n][_nPosConta])
	cCodPro := AllTrim(aCols[n][_nPosProd])
	cLoteFor := AllTrim(aCols[n][nPosLtFor])
	
	If	!(aCols[n][_nTaHeader])

		If	!(Ascan( aCFOPs, AllTrim(aCols[n][_nPosCFOP]))) .AND. (SubStr( cConta, 1, 4) != "1131");
			 .AND. Len(cConta) > 0 .AND. Alltrim(Funname()) == "MATA103"

			cRotina := Alltrim(Funname())
			
			If !U_ATCHKCCCNT(cCusto, cConta, cRotina)
				MsgStop("Conta Contábil não permitida para este Centro de Custo!","MT100LOK")
				_lPassou := .F.
			EndIf
		
		EndIf
		
		If	_lPassou
			If Len(aCols[n][_nPosTES]) > 0
				cTES := AllTrim(aCols[n][_nPosTES])
				_lPassou := ckCtaTES(cConta, cTES)
			EndIf
		EndIf

		/*If _lPassou
			cProduto := AllTrim(aCols[n][_nPosProd])
			cConta := Alltrim( aCols[n][_nPosConta])
			If	SubStr(cProduto, 1, 2) == "47" .or. SubStr(cProduto, 1, 2) == "48"
				If !((cConta >= aRng1G1[1] .and. cConta <= aRng1G1[2]) .or. (cConta >= aRng2G1[1] .and. cConta <= aRng2G1[2]) .or. cConta == aCntG1[1] .or. cConta == aCntG1[2])
					MsgStop("Produtos  47.X e 48.X não podem ser utilizados com a Conta Contábil indicada.","MT120LOK - Produto x Conta Contábil")
					_lPassou := .F.
				EndIf
			EndIf

			If (cConta >= aRng1G1[1] .and. cConta <= aRng1G1[2]) .or. cConta == aCntG1[1] .or. cConta == aCntG1[2]
				If	!(AScan( aProdG1, SubStr(cProduto,1,2)) > 0)//!(SubStr(cProduto, 1, 2) == "47" .or. SubStr(cProduto, 1, 2) == "48")
					MsgStop("Conta Contábil indicada deve ser utilizada apenas com produtos 47.X ou 48.X.","MT120LOK - Produto x Conta Contábil")
					_lPassou := .F.
				EndIf
			EndIf
		EndIf*/
		If _lPassou
			If	(SubStr(aCols[n][_nPosProd], 1, 3) == '11.') .AND. (Len(AllTrim(aCols[n][nPosLtFor])) = 0);
				.AND. AllTrim(_cEspDoc) != 'CTE' .AND. !IsInCallStack("MATA119") .AND. IsInCallStack("MATA103")
				MsgAlert("Favor informar o lote do produto.", "MT100LOK")
				_lPassou := .F.
			EndIf
		EndIf

		//If	Alltrim(Funname()) == "MATA103" .AND. _lPassou
		If	IsInCallStack("MATA103") .AND. _lPassou
			If _Fornec != "84683879" .And. Sm0->M0_Codigo != "11" //Inserido em 13.10.11 - Cezar
				If acols[n][len(aheader)+1] == .f.
					If !Empty(aCols[n][_nPosPed])
						DbSelectArea("SC7")
						DbSetOrder(1)
						
						DbSeek( xFilial("SC7")+aCols[n][_nPosPed]+aCols[n][_nPosItP])
						nPreco := round(SC7->C7_PRECO,4) * 1.005
						If ROUND(aCols[n][nPosVunit],4) > round(nPreco,4)
							MsgStop ("Valor Unitario diferente do pedido!"+;
							CHR(13)+"Valor Unitario: "+AllTrim(Str(nPreco))+;
							CHR(13)+"Para o Pedido / Item : "+aCols[n][_nPosPed]+" - "+aCols[n][_nPosItP],"MT100LOK")
							_lPassou := .F.
							//Return(_lPassou)
						EndIf
						
						nQuant := SC7->C7_QUANT //alterado Fernando - 13/05/2011
						If nQuant < aCols[n][nPosQuant]
							MsgStop ("Quantidade diferentes do pedido!"+;
							CHR(13)+"Quantidade: "+Trim(Str(nQuant))+;
							CHR(13)+"Para o Pedido / Item : "+aCols[n][_nPosPed]+" - "+aCols[n][_nPosItP],"MT100LOK")
							_lPassou := .F.
							//Return(_lPassou)
						EndIf
						
						//If dtos(SC7->C7_DATPRF) > dtos(DDATABASE)
						If (YEAR(SC7->C7_DATPRF) >= YEAR(DATE())) .AND. (MONTH(SC7->C7_DATPRF) > MONTH(DATE()))
							MsgStop ("Mês de Entrega maior que do pedido!"+;
							CHR(13)+"Data Entrega: "+dtos(SC7->C7_DATPRF)+;
							CHR(13)+"Para o Pedido / Item : "+aCols[n][_nPosPed]+" - "+aCols[n][_nPosItP],"MT100LOK")
							_lPassou := .F.
							//Return(_lPassou)
						EndIf
						
						DbSelectArea("SC7")
						DBCloseArea()
					EndIf
				EndIf

				If _lPassou .AND. !IsInCallStack("U_GT1IMPXML")
					If !lChkProInv(cCodPro, cLoteFor)
						_lPassou := .F.
						MsgAlert("Produtos de Inventário (cod 11.X) devem vir com o campo Lote Fornecedor preenchido.", "MT100LOK - Lote Fornecedor Vazio")
					EndIf
				EndIf
			EndIf

			If cConta == "41110017" .AND. EMPTY( cCusto ) .AND. !IsInCallStack("U_GT1IMPXML")
				_lPassou := .F.
				MsgStop("Favor, preencher o campo Centro de Custo!","MT100LOK - Centro de Custo não preenchido")
			EndIf
		EndIf
	EndIf
	
Return(_lPassou)

/*/{Protheus.doc} ckContaTES
	(caso a TES atualize o Estoque (F4_ESTOQUE = 1), então a Conta deve do grupo 4 (4xxxxxxx), senão deve ser do grupo 1131 (1131xxx).)
	@type  Static Function
	@author Adriano Zanella Junior
	@since 18/04/2022
	@version 1.0
	@param cConta, String, Conta Contábil da Linha
	@param cTES, String, TES da Linha
	@return lRet, Logico, Ferdadeiro se Permitido, Falso se invalido
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ckCtaTES(cConta, cTES)
	Local lRet := .T.
	Local aTes5885 := {"527","161","554","157","664","466","471","133","454","111","012","351","355"}	// TES Que Não Movimentam Estoque validas para uso com a conta 1131
	Private aCntAtivo := {"1413","1411","1511"}
	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek(xFilial("SF4")+cTES)
		If SubStr(cConta, 1, 4) == "1413"	.AND. SF4->F4_PISCOF != "4"	// Chamado 9625 - 
			MsgAlert("Conta Contábil 1413X requer TES com PIS/COFINS.", "MT100LOK - TES x Contá Contábil")
			lRet := .F.
		EndIf

		If AScan(aCntAtivo, SubStr(cConta, 1, 4))
			Return lRet
		EndIf
		/* Exemplo de busca de Docs com conta 1131, não movimenta estoque e tes de exessão
			SELECT	F4_ESTOQUE, SD1.*
			FROM	SD1010 SD1
					JOIN SF4010 SF4
						ON SD1.D1_TES = SF4.F4_CODIGO
			WHERE	SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = ''
					AND SUBSTRING(SD1.D1_CONTA,1,4) = '1131'
					AND SD1.D1_EMISSAO > '202307'
					AND (SF4.F4_ESTOQUE != 'S')
					AND (SF4.F4_CODIGO IN ('527','161','554','157','664','466','471','133','454','111','012','351','355'))
			ORDER BY SD1.D1_EMISSAO, SD1.D1_DOC
		*/
		If SubStr(cConta, 1, 4) == "1131"  .AND. !(SF4->F4_ESTOQUE == "S") .AND. !(AScan(aTes5885, cTES) > 0)
			MsgAlert("TES inválida para a Conta Contábil 1131.", "MT100LOK - TES x Contá Contábil")
			lRet := .F.
		ElseIf	SubStr(cConta, 1, 1) == "4"  .AND. SF4->F4_ESTOQUE != "N"
			MsgAlert("Conta Contábil Inválida para esta TES. As contas Válidas são do Grupo 4", "MT100LOK - TES x Contá Contábil")
			lRet := .F.
		EndIf
	EndIf
	DbCloseArea()
	//F4_PISCOF
Return lRet

/*/{Protheus.doc} lChkProdInv
	(Produtos com código "11." devem ter a informação de Lote de Fornecedor)
	@type  Static Function
	@author Adriano Zanella Junior
	@since 15/02/2024
	@version 1.0
	@param cCodPro, String, Código do Produto
	@param cLoteFor, String, Lote do Fornecedor
	@return lRet, Logico, Verdadeiro se passou, falso se não
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lChkProInv(cCodPro, cLoteFor)
	Local lRet := .T.
	If SubStr(cCodPro, 1, 3) == "11."
		If Len(cLoteFor) = 0
			lRet := .F.
		EndIf
	EndIf
Return lRet
