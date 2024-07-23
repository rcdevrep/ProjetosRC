#INCLUDE 'Protheus.ch'

User Function ImpXML_Cte(cFile, lJob, aErros, oXml, lVldExist,lPrimeira)

Local lRet       := .T.
Local lRemet 	 := .F.
Local lDevSemSF1 := .F.
Local nX		 := 0
Local nPesoBruto := 0
Local nPesoLiqui := 0
Local cError     := ""
Local lToma4	 := .F.
Local cCNPJ_CT	 := ""
Local cCNPJ_CF	 := ""
Local cFornCTe   := ""
Local cLojaCTe   := ""
Local cNomeCTe   := ""
Local cCodiRem   := ""
Local cLojaRem   := ""
Local cChaveNF   := ""
Local cChaveNF2  := ""
Local cPrdFrete  := PadR(SuperGetMV("MV_XMLPFCT",.F.,""),TamSX3("B1_COD")[1])
Local cTES_CT 	 := ""
Local cCPag_CT 	 := ""
Local cTipoFrete := ""
Local aDadosFor  := Array(2) //-- 1- Codigo; 2-Loja
Local aDadosCli  := Array(2) //-- 1- Codigo; 2-Loja
Local aCabec116	 := {}
Local aItens116	 := {}
Local aAux		 := {}
Local aEspecVol  := {}
Local aAux1		 := {}
Local lDesTrFil	 := .F.
Local cTagDest	 := ""
Local cTagRem	 := "" 
Local cTagExp	 := "" //27.12.2017 - Chamado 62165
Local aAreaSZW   := (_cTab1)->( GetArea() )
Local nBaseICMS := 0
Local nValICMS	:= 0
Local nAliqICMS	:= 0
Local lBaseICMS := .F.
Local lValICMS	:= .F.
Local lAliqICMS	:= .F.
Local cTiponf	:= "1"
Local lCliente	:= .F.
Local cMunIni   := ""
Local cMunFim   := ""

Default lJob      := .T.
Default aErros    := {} 
Default lVldExist := .T.
Default lPrimeira := .T. 

Private cCteAgricopel := .F.

//-- Verifica se o arquivo pertence a filial corrente
If !CTe_VldEmp(oXML, SM0->M0_CGC, @lDesTrFil, @lToma4)
	
	If lJob
		aAdd(aErros,{cFile, "Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente."})
	Else
		Aviso("Erro", "Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente.",{"OK"},2,"ImpXML_CTe")
	EndIf
	lRet := .F.
EndIf

//-- Verifica se o ID ja foi processado

(_cTab1)->( dbSetOrder(1) )
If lRet .And. lVldExist .And. (_cTab1)->(dbSeek(Right(AllTrim(oXML:_InfCte:_Id:Text),44) + "2"))
	If lJob
		aAdd(aErros,{cFile, "ID de CT-e já registrado na NF " + (_cTab1)->(AllTrim(&(_cCmp1+"_DOC")) + "/" + AllTrim(&(_cCmp1+"_SERIE"))); //
						 + " do Fornecedor/Cliente " + (_cTab1)->(AllTrim(&(_cCmp1+"_CODEMI")) + "/" + AllTrim(&(_cCmp1+"_LOJEMI"))) + " na filial " + (_cTab1)->&(_cCmp1+"_FILIAL") + ".", "Exclua o documento registrado na ocorrência."})
	Else
		Aviso("Erro", "ID de CT-e já registrado na NF " + (_cTab1)->(AllTrim(&(_cCmp1+"_DOC")) + "/" + AllTrim(&(_cCmp1+"_SERIE")));
					  + " do Fornecedor/Cliente " + (_cTab1)->(AllTrim(&(_cCmp1+"_CODEMI")) + "/" + AllTrim(&(_cCmp1+"_LOJEMI"))) + " na filial " + (_cTab1)->&(_cCmp1+"_FILIAL") + ".", {"OK"}, 2, "ImpXML_CTe")
	EndIf
	lRet := .F.
EndIf
RestArea(aAreaSZW)

//-- Verifica se o fornecedor do conhecimento esta cadastrado no sistema.
If lRet
	If ValType(XmlChildEx(oXML:_InfCte:_Emit,"_CNPJ")) <> "U"
		cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CNPJ:Text)
	Else
		cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CPF:Text)
	EndIf
	SA2->(dbSetOrder(3))
	If !u_SMS01CGC(cCNPJ_CT)//!SA2->(dbSeek(xFilial("SA2")+cCNPJ_CT))
		
		If lJob
			aAdd(aErros,{cFile,"Fornecedor " + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R 99.999.999/9999-99") +"] "+ "inexistente na base.", "Gere cadastro para este fornecedor."})
		Else
			Aviso("Erro","Fornecedor " + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R 99.999.999/9999-99") +"] "+ "inexistente na base.", "Gere cadastro para este fornecedor.",2,"ImpXML_CTe")
		EndIf
		lRet := .F.
	Else
		cFornCTe := SA2->A2_COD
		cLojaCTe := SA2->A2_LOJA
		cNomeCTe := SA2->A2_NOME
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica se a empresa foi remetente das notas fiscais contidas no conhecimento: 			³
//³ 																				 			³
//³ Se sim, significa que as notas contidas no conhecimento sao notas de saida, podendo ser 	³
//³ notas de venda, devolucao de compras ou devolucao de remessa para beneficiamento.     		³
//³ 																				 			³	
//³ Se nao, significa que as notas contidas no conhecimento sao notas de entrada, podendo ser	³
//³ notas de compra, devolucao de vendas ou remessa para beneficiamento.     					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
	cTagRem := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF")
	If lRemet := (SM0->M0_CGC == AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)) .And. !lDesTrFil
		cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF")
		cCNPJ_CF := AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) //-- Armazena o CNPJ do destinatario das notas contidas no conhecimento
		cTipoFrete := "F"
	Else
		cCNPJ_CF := AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text) //-- Armazena o CNPJ do remetente das notas contidas no conhecimento
		cTipoFrete := "C"
		//-- Como no XML nao e possivel saber se o destinatario e cliente ou fornecedor
		//-- Validarei os dois casos
		SA1->(dbSetOrder(3))
		If SA1->(dbSeek(xFilial("SA1")+cCNPJ_CF))
			aDadosCli[1] := SA1->A1_COD
			aDadosCli[2] := SA1->A1_LOJA
		Else
			aDadosCli[1] := CriaVar("A1_COD",.F.)
			aDadosCli[2] := CriaVar("A1_LOJA",.F.)
		EndIf
		SA2->(dbSetOrder(3))
		If U_SMS01CGC(cCNPJ_CF)//SA2->(dbSeek(xFilial("SA2")+cCNPJ_CF))
			aDadosFor[1] := SA2->A2_COD
			aDadosFor[2] := SA2->A2_LOJA
		Else
			aDadosFor[1] := CriaVar("A2_COD",.F.)
			aDadosFor[2] := CriaVar("A2_LOJA",.F.)
		EndIf
		If Empty(aDadosCli[1]) .And. !Empty(aDadosFor[1])
			cCodiRem := aDadosFor[1]
			cLojaRem := aDadosFor[2]
		ElseIf !Empty(aDadosCli[1]) .And. Empty(aDadosFor[1])
			cCodiRem := aDadosCli[1]
			cLojaRem := aDadosCli[2] //cCodiRem := aDadosCli[2]
			_lCliente := .T.
		ElseIf !Empty(aDadosCli[1]) .And. !Empty(aDadosFor[1])
			cCodiRem := ""
			cLojaRem := ""
		ElseIf lDesTrFil .And. !Empty(aDadosFor[1])
			cCodiRem := aDadosFor[1]
			cLojaRem := aDadosFor[2]
		Else
			If lJob
				aAdd(aErros,{cFile,"Fornecedor: " + oXML:_InfCte:_Rem:_Xnome:Text +" [" + Transform(cCNPJ_CF,"@R 99.999.999/9999-99") +"] "+ "inexistente na base.","Gere cadastro para este fornecedor."})
			Else
				Aviso("Erro","Fornecedor: " + oXML:_InfCte:_Rem:_Xnome:Text +" [" + Transform(cCNPJ_CF,"@R 99.999.999/9999-99") +"] "+ "inexistente na base.", "Gere cadastro para este fornecedor.",2,"ImpXML_CTe")
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet
	//-- Caso o remetente nao seja a propria empresa, valida o cadastro do remetente
	//-- Podendo este ser cliente ou fornecedor (descobira atrabes das notas do conhecimento)
	If !lRemet
		//-- Separa secao que contem as notas do conhecimento para laco
		If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA03")) <> "U"    
			If AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "3"  //DESTINATARIO
				If ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNF")) != "U"
					aAux := If(ValType(oXML:_InfCte:_Rem:_INFNF) == "O", {oXML:_InfCte:_Rem:_INFNF}, oXML:_InfCte:_Rem:_INFNF)
				EndIf
				If ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNFE")) != "U"
					aAux1 := If(ValType(oXML:_InfCte:_Rem:_INFNFE) == "O", {oXML:_InfCte:_Rem:_INFNFE}, oXML:_InfCte:_Rem:_INFNFE)
				EndIf                                                              
		    elseif AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "0" // REMETENTE  
				If ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm:_Infdoc,"_INFNF")) != "U"
					aAux := If(ValType(oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF) == "O",{oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF},oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF)
				EndIf                                                     	
				If ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm:_Infdoc,"_INFNFE")) != "U"
					aAux1 := If(ValType(oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE) == "O",{oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE},oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE)
				EndIf
		    elseif AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "1" // Chamado 75401 - Validação de Expedidor errada  
				If ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm:_Infdoc,"_INFNF")) != "U"
					aAux := If(ValType(oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF) == "O",{oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF},oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF)
				EndIf                                                     	
				If ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm:_Infdoc,"_INFNFE")) != "U"
					aAux1 := If(ValType(oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE) == "O",{oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE},oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE)
				EndIf
			EndIf
		ElseIf ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA4")) <> "U"
			If AllTrim(oXML:_InfCte:_Ide:_Toma4:_TOMA:Text) == "4"  //DESTINATARIO
				If ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNF")) != "U"
					aAux := If(ValType(oXML:_InfCte:_Rem:_INFNF) == "O", {oXML:_InfCte:_Rem:_INFNF}, oXML:_InfCte:_Rem:_INFNF)
				elseIf ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNFE")) != "U"
					aAux1 := If(ValType(oXML:_InfCte:_Rem:_INFNFE) == "O", {oXML:_InfCte:_Rem:_INFNFE}, oXML:_InfCte:_Rem:_INFNFE)
				ELSEIF ValType(XmlChildEx(oXML:_InfCte,"_InfCteNorm")) != "U"
					IF ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm:_Infdoc,"_INFNF")) != "U"
						aAux := If(ValType(oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF) == "O",{oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF},oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNF)
					elseIf ValType(XmlChildEx(oXML:_InfCte:_InfCteNorm:_Infdoc,"_INFNFE")) != "U"
						aAux1 := If(ValType(oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE) == "O",{oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE},oXML:_InfCte:_InfCteNorm:_Infdoc:_INFNFE)
					ENDIF
				EndIf
			endif
		EndIf
		// Limpa filtro da tabela SF1 para pesquisar pelo fornecedor correto
		SF1->(dbClearFilter())

		If Len(aAux) > 0		// Quando preenche aAux significa que o XML contem os numeros das notas originais, portanto o emitente do CTe nao trabalha com NF-e
			
			SF1->(dbSetOrder(1))
			
			For nX := 1 To Len(aAux)
				cChaveNF :=	Padr(PadL(AllTrim(aAux[nX]:_nDoc:Text), GetNewPar("MV_XSMS005", 9), "0"),TamSX3("F1_DOC")[1]) +;
							Padr(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F1_SERIE")[1])
				
				cChaveNF2 := Padr(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F1_DOC")[1]) +;
							Padr(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F1_SERIE")[1])
				
				//-- Se remetente nao identificado e porque pode ser cliente ou fornecedor
				//-- Dai identifica atraves de seek no SF1
				If Empty(cCodiRem)
					If SF1->(dbSeek(xFilial("SF1") + cChaveNF + aDadosFor[1] + aDadosFor[2])) .Or. ;
					   SF1->(dbSeek(xFilial("SF1") + cChaveNF2 + aDadosFor[1] + aDadosFor[2])) // Se achar, significa que sao notas de compra
						cCodiRem := aDadosFor[1]
						cLojaRem := aDadosFor[2]
						cTiponf	:= "1"
					ElseIf SF1->(dbSeek(xFilial("SF1") + cChaveNF + aDadosCli[1] + aDadosCli[1])) .Or. ;
						   SF1->(dbSeek(xFilial("SF1") + cChaveNF2 + aDadosCli[1] + aDadosCli[1])) //Se achar, significa que sao notas de devol./beneficiamento
						cCodiRem := aDadosCli[1]
						cLojaRem := aDadosCli[2]
						cTiponf	:= "2"
					Else //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
						lRet := .F.
					EndIf
				ElseIf !SF1->(dbSeek(xFilial("SF1") + cChaveNF + cCodiRem + cLojaRem)) .And. !SF1->(dbSeek(xFilial("SF1") + cChaveNF2 + cCodiRem + cLojaRem))
					lRet := .F. //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
				EndIf
							
				//-- Registra notas que farao parte do conhecimento
				If lRet
					aAdd(aItens116, {{"PRIMARYKEY", SubStr(SF1->&(IndexKey()), FwSizeFilial() + 1)}})
				Else
					If lJob
						aAdd(aErros, {cFile, "Documento de entrada " + AllTrim(aAux[nX]:_nDoc:Text) + "/" + AllTrim(aAux[nX]:_Serie:Text) + " inexistente na base ou com chave divergente.", "Processe o recebimento deste documento de entrada."})
					Else
						Aviso("Erro", "Documento de entrada " + AllTrim(aAux[nX]:_nDoc:Text) + "/" + AllTrim(aAux[nX]:_Serie:Text) + " inexistente na base ou com chave divergente. Processe o recebimento deste documento de entrada.", 2, "ImpXML_CTe")
					EndIf
					Exit
				EndIf
			Next nX
		
			// Tratamento para CTe de devolucao quando o cliente nao aceitou receber a mercadoria
			// Neste caso a transportadora emite um novo CTe referenciando as notas de venda, as notas estarao em SF2 e nao SF1
			If !lRet .And. lCliente
				SF2->(dbClearFilter())
				SF2->(dbSetOrder(1))
				For nY := 1 To Len(aAux)
					cChaveNF :=	Padr(AllTrim(aAux[nY]:_nDoc:Text),TamSX3("F2_DOC")[1]) +;
								Padr(AllTrim(aAux[nY]:_Serie:Text),TamSX3("F2_SERIE")[1])
					If SF2->(dbSeek(xFilial("SF2")+cChaveNF+aDadosCli[1]+aDadosCli[2]))
						cCodiRem := aDadosCli[1]
						cLojaRem := aDadosCli[2]
						cTipoNf := "2"
						lRet := .T.
					Else
						lRet := .F.
						Exit
					EndIf
				Next nY
				If lRet
					aErros	:= {}
					cTipoFrete := "F"
					lDevSemSF1 := .T.
				EndIf
			EndIf
		EndIf

		If Len(aAux1) > 0 // Quando preenche aAux1 significa que o XML contem a chave DANFE das notas originais, portanto o emitente do CTe trabalha com NF-e
			For nX := 1 To Len(aAux1)
				SF1->(dbSetOrder(8))
				cChaveNF :=	Padr(AllTrim(aAux1[nX]:_chave:Text),TamSX3("F1_CHVNFE")[1])
				//-- Se remetente nao identificado e porque pode ser cliente ou fornecedor
				//-- Dai identifica atraves de seek no SF1 e SF2
				If Empty(cCodiRem)
					If SF1->(dbSeek(xFilial("SF1")+cChaveNF))
						dbSelectArea("SA2")
						dbSetOrder(1)
						If SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)) // Se achar, significa que sao notas de compra
							cCodiRem := aDadosFor[1]
							cLojaRem := aDadosFor[2]
							cTipoNf	:= "1"
						Else
							dbSelectArea("SA1")
							dbSetOrder(1)
							If SA1->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)) //Se achar, significa que sao notas de devol./beneficiamento
								cCodiRem := aDadosCli[1]
								cLojaRem := aDadosCli[2]
								cTipoNf	:= "2"
							EndIf
						EndIf
					Else //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
						lRet := .T. //lRet := .F. // Thiago  
						cCteAgricopel := .T.                                          
					EndIf
					
				ElseIf !SF1->(dbSeek(xFilial("SF1")+cChaveNF))
						lRet := .T. //.F. Thiago //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
						cCteAgricopel := .T.
				EndIf
				SF1->(dbSetOrder(1))
				//-- Registra notas que farao parte do conhecimento
				If lRet
					aAdd(aItens116, {{"PRIMARYKEY", SubStr(SF1->&(IndexKey()), FWSizeFilial() + 1)}})
				Else
					If lJob
						aAdd(aErros,{cFile, "Documento de entrada " + cChaveNF + "inexistente na base.","Processe o recebimento deste documento de entrada."})
					Else
						Aviso("Erro", "Documento de entrada" + cChaveNF + "inexistente na base. Processe o recebimento deste documento de entrada.",2,"ImpXML_CTe")
					EndIf
				    	lRet := .F.
					Exit
				EndIf
			Next nX

			// Tratamento para CTe de devolucao quando o cliente nao aceitou receber a mercadoria
			// Neste caso a transportadora emite um novo CTe referenciando as notas de venda, as notas estarao em SF2 e nao SF1
			If !lRet .And. lCliente
				cChaveNF := ""
				For nY := 1 To Len(aAux1)
					cChaveNF +=	"'" + Padr(AllTrim(aAux1[nY]:_chave:Text),TamSX3("F2_CHVNFE")[1]) + "',"
					nCount++
				Next nY
				cChaveNF :=	"(" + Substr(cChaveNF,1,Len(cChaveNF)-1) + ")"
				SF2->(dbClearFilter())
				SF2->(dbSetOrder(1))
				#IFDEF TOP
					// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					// |  MONTA QUERY   |
				    // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery += " SELECT COUNT(*) TOTAL "
					cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
					cQuery += " WHERE F2_CHVNFE IN " + cChaveNF
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TMP", .T., .T.)
					TMP->(dbGoTop())
					If !TMP->(Eof())
						If nCount == TMP->TOTAL
							lRet := .T.
						EndIf
					EndIf
					TMP->(dbCloseArea())
				#ENDIF

				If lRet
					aErros	:= {}
					cTipoFrete := "F"
					lDevSemSF1 := .T.
				EndIf
			EndIf
		EndIf
	Else
		SB1->(dbSetOrder(1))
		cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
		If At(";",cPrdFrete) > 0
			cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
		EndIf
		cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])
		//-- Valida existencia do produto frete
		If Empty(cPrdFrete) .Or. !SB1->(dbSeek(xFilial("SB1")+cPrdFrete))
			If lJob
				aAdd(aErros,{cFile, "Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente.","Verifique a configuração do parâmetro."}) //#
			Else
				alert("Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente.","Verifique a configuração do parâmetro.") //"Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente."#"Verifique a configuração do parâmetro."
			EndIf
			lRet := .F.
		EndIf
	endif
EndIf	
If lRet
	if lPrimeira
		aImp := GetXmlIcms(oXml)		
		//-- Separa secao que contem as notas do conhecimento para laco
		If ValType(XmlChildEx(oXML:_InfCte,"_INFCTENORM")) <> "U"
		 	aAux := If(ValType(oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ) == "O",{oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ},oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ)
		EndIf
	 	For nX := 1 To Len(aAux)
			If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO BRUTO"
				nPesoBruto := Val(aAux[nX]:_QCARGA:Text)
			EndIf
			If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO LIQUIDO"
				nPesoLiqui := Val(aAux[nX]:_QCARGA:Text)
			EndIf
			If !("PESO" $ Upper(aAux[nX]:_TPMED:Text)) .And. Len(aEspecVol) < 5
				aAdd(aEspecVol,{AllTrim(aAux[nX]:_TPMED:Text),Val(aAux[nX]:_QCARGA:Text)})
			EndIf
		Next nX
		// Apuracao do ICMS para as diversas situacoes tributarias
		If ValType(XmlChildEx(oXML:_InfCte:_imp,"_ICMS")) <> "U"
			If ( oICMS := oXML:_INFCTE:_IMP:_ICMS ) != Nil
				If ( oICMSTipo := XmlGetChild( oICMS, 1 )) != Nil
					For nZ := 1 To 5	// O nivel maximo para descer dentro da tag que define o tipo do ICMS para obter tanto base quanto valor é 5, conforme manual de orientacao do CTe
						If ( oICMSNode := XmlGetChild( oICMSTipo, nZ )) != Nil
							If "vBC" $ oICMSNode:REALNAME
								nBaseICMS := Val(oICMSNode:TEXT)
								lBaseICMS := .T.
							ElseIf "vICMS" $ oICMSNode:REALNAME
								nValICMS := Val(oICMSNode:TEXT)
								lValICMS := .T.
							ElseIf "pICMS" $ oICMSNode:REALNAME
								nAliqICMS := Val(oICMSNode:TEXT)
								lAliqICMS := .T.
							EndIf
							If lBaseICMS .And. lValICMS .And. lAliqICMS
								Exit
							EndIf
						EndIf
					Next nZ
				EndIf
			EndIf
		EndIf
			//-- Grava itens do conhecimento de transporte
		Begin Transaction
	
		//-- Grava cabeca do conhecimento de transporte
		RecLock(_cTab1,.T.)
	
		(_cTab1)->&(_cCmp1+"_FILIAL")			:= xFilial("SF1")														// Filial
		(_cTab1)->&(_cCmp1+"_SEQIMP") 		:= GetSXENUM(_cTab1, _cCmp1+"_SEQIMP")                                  // Sequencia de importação
		If lRemet .Or. lDevSemSF1 .Or. lToma4
			(_cTab1)->&(_cCmp1+"_STCTE")			:= "S"	 //if (_cTab1)->&(_cCmp1+"_STCTE") == "S"		// remetente do CTE
	    else
			(_cTab1)->&(_cCmp1+"_STCTE")			:= "N"																// remetente do CTE
	    endif
	   	(_cTab1)->&(_cCmp1+"_CGCEMI")			:= cCNPJ_CT																// CGC
	    (_cTab1)->&(_cCmp1+"_DOC")			:= PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0")			// Numero do Documento
	    (_cTab1)->&(_cCmp1+"_SERIE")		:= AllTrim(oXML:_InfCte:_Ide:_Serie:Text) 								// Serie
	    (_cTab1)->&(_cCmp1+"_CODEMI")		:= cFornCTe																// Fornecedor do Conhecimento de transporte
	    (_cTab1)->&(_cCmp1+"_LOJEMI")		:= cLojaCTe																// Loja do Fornecedor do Conhecimento de transporte
	    (_cTab1)->&(_cCmp1+"_CODREM")		:= cCodiRem																// Remetente das notas - codigo
	    (_cTab1)->&(_cCmp1+"_LOJREM")		:= cLojaRem																// Remetente das notas - loja
	    (_cTab1)->&(_cCmp1+"_DTEMIS")		:= StoD(StrTran(AllTrim(oXML:_InfCte:_Ide:_Dhemi:Text),"-",""))			// Data de Emissão
	    (_cTab1)->&(_cCmp1+"_EST")			:= oXML:_InfCte:_Ide:_UFIni:TEXT										// Estado de emissao da NF
	    (_cTab1)->&(_cCmp1+"_TIPO")			:= "2"													 				// Tipo da Nota
	    (_cTab1)->&(_cCmp1+"_FORMUL")		:= "N" 																	// Formulario proprio
	    (_cTab1)->&(_cCmp1+"_ESPECI")		:= " "																  	// Especie
	    (_cTab1)->&(_cCmp1+"_ARQUIV")		:= AllTrim(cFile)														// Arquivo importado
	    (_cTab1)->&(_cCmp1+"_CHAVE")		:= Right(AllTrim(oXML:_InfCte:_Id:Text),44)								// Chave de Acesso da NF
	    (_cTab1)->&(_cCmp1+"_VERSAO")		:= AllTrim(oXML:_InfCte:_Versao:Text) 									// Versão
//	    (_cTab1)->&(_cCmp1+"_TOTVAL")		:= Val(oXML:_InfCte:_VPrest:_VRec:Text)								  	// Valor Mercadoria
	    (_cTab1)->&(_cCmp1+"_TOTVAL")		:= IIF (Val(oXML:_InfCte:_VPrest:_VRec:Text) < Val(oXML:_InfCte:_VPrest:_vTPrest:Text),Val(oXML:_InfCte:_VPrest:_vTPrest:Text),Val(oXML:_InfCte:_VPrest:_VRec:Text)) // Valor a Receber / Valor Total do Serviço
	    (_cTab1)->&(_cCmp1+"_TPFRET")		:= cTipoFrete															// Tipo de Frete
	    (_cTab1)->&(_cCmp1+"_PBRUTO")		:= nPesoBruto															// Peso Bruto
	    (_cTab1)->&(_cCmp1+"_PLIQUI")		:= nPesoLiqui															// Peso Liquido
		(_cTab1)->&(_cCmp1+"_TOTICM") 		:= aImp[4]
		(_cTab1)->&(_cCmp1+"_TRIB")   		:= aImp[1]
		(_cTab1)->&(_cCmp1+"_DTCRIA") 		:= dDataBase
		(_cTab1)->&(_ccmp1+"_HRCRIA") 		:= Time()
		(_cTab1)->&(_cCmp1+"_USUCRI") 		:= cUserName
		(_cTab1)->&(_cCmp1+"_SIT")    		:= "1"
		(_cTab1)->&(_cCmp1+"_XML")    		:= cXml     // Variavel que contém o XML
		(_cTab1)->&(_cCmp1+"_TIPONF")  		:= cTipoNf
		(_cTab1)->&(_cCmp1+"_NATFIN") 		:= ""
		(_cTab1)->&(_cCmp1+"_CONDPG") 		:= ""
		(_cTab1)->&(_cCmp1+"_NATOP")  		:= oXml:_InfCte:_Ide:_NatOp:Text
	    For nX := 1 To Len(aEspecVol)
	    	If (_cTab1)->(FieldPos ((_cCmp1+"_ESPEC" +Str(nX,1)))) > 0
			    (_cTab1)->&((_cCmp1+"_ESPEC" +Str(nX,1))) := aEspecVol[nX,1]							 		// Especie
				(_cTab1)->&((_cCmp1+"_VOLUM" +Str(nX,1))) := aEspecVol[nX,2]							 		// Volume
			EndIf
		Next nX
		(_cTab1)->&(_cCmp1+"_BASEIC") 		:= nBaseICMS
		(_cTab1)->&(_cCmp1+"_VALICM") 		:= nValICMS
		If lRemet .Or. lDevSemSF1 .Or. lToma4
			(_cTab1)->&(_cCmp1+'_ITEM')			:= StrZero(1,TamSX3((_cCmp1+'_ITEM'))[1])							   		// Item
			(_cTab1)->&(_cCmp1+'_COD')			:= cPrdFrete														// Codigo do produto
			(_cTab1)->&(_cCmp1+'_QUANT')		:= 1																// vQuantidade
			(_cTab1)->&(_cCmp1+'_PICM') 		:= nAliqICMS
		EndIf
		IF cCteAgricopel
			(_cTab1)->&(_cCmp1+"_ESPECI") 		:= "CTEAG" // Thiago SLA - Específico Agricopel
		ENDIF

	  cMunIni := XmlChildEx(oXml:_InfCte:_Ide:_cMunIni,"TEXT")
	  cMunFim := XmlChildEx(oXml:_InfCte:_Ide:_cMunFim,"TEXT")

		//Spiller -> Campos de Inicio e Fim do Frete
		(_cTab1)->&(_cCmp1+"_UFORIT")  := XmlChildEx(oXml:_InfCte:_Ide:_UFIni,"TEXT")
		(_cTab1)->&(_cCmp1+"_MUORIT")  := If(!Empty(cMunIni),substr(cMunIni,3,5),"") 
		(_cTab1)->&(_cCmp1+"_UFDEST")  := XmlChildEx(oXml:_InfCte:_Ide:_UFFim,"TEXT")
		(_cTab1)->&(_cCmp1+"_MUDEST")  := If(!Empty(cMunFim),substr(cMunFim,3,5),"")

		(_cTab1)->(MsUnlock())
		ConfirmSX8()
		End Transaction
	endif
EndIf
	
Return{lRet, aItens116, aErros}

//////////////////////////////////////

Static Function CTe_VldEmp(oXML,cCNPJ_CPF,lDesTrFil)
	
Local lRet 	   := .T.
Local cTagRem  := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF")
Local cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF")  
Local cTagExp  := ""//If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF") //27.12.2017 - Chamado 62165
Local oValXML  := oXML
//27.12.2017 - Chamado 62165              
If ValType(XmlChildEx(oValXML:_InfCte,"_EXPED")) <> "U"   
	If ValType(XmlChildEx(oValXML:_InfCte:_Exped,"_CNPJ")) <> "U"   
		cTagExp := If(ValType(XmlChildEx(oValXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
	Endif
Endif


DEFAULT lDesTrFil:= .F.

//-- Verifica se o arquivo pertence a filial corrente
lRet := AllTrim(XmlChildEx(oValXML:_InfCte:_Rem,cTagRem):Text) == AllTrim(cCNPJ_CPF) .Or.;
			AllTrim(XmlChildEx(oValXML:_InfCte:_Dest,cTagDest):Text) == AllTrim(cCNPJ_CPF)  

//27.12.2017 - Chamado 62165 
If ValType(XmlChildEx(oValXML:_InfCte,"_EXPED")) <> "U" //Type('oValXML:_InfCte:_Exped') <> "U" 			
	If ValType(XmlChildEx(oValXML:_InfCte:_Exped,"_CNPJ")) <> "U"  .and.  !lRet
   		  lRet := AllTrim(XmlChildEx(oValXML:_InfCte:_Exped,cTagExp):Text) == AllTrim(cCNPJ_CPF) //27.12.2017 - Chamado 62165       
	Endif 
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Validacao para Transferencia entre Filiais: 									 			³
//³ 																				 			³
//| Valida se o CT-e deve ser importado na filial remetente ou na filial destinataria			³
//| para o caso de ser uma operacao de transferencia entre filiais  				 			³
//| 																				 			³
//| Validacao efetuada pela tag TOMA03 conforme Manual do Conhecimento de Transporte Eletronico |
//| Versao 1.0.4c - Abril/2012, que identifica quem e o tomador do servico, sendo:				|
//| 0-Remetente																					|
//| 1-Expedidor																					|
//| 2-Recebedor																					|
//| 3-Destinatario																				|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ValType(XmlChildEx(oValXML:_InfCte:_Ide,"_TOMA3")) == "O" .And. ValType(XmlChildEx(oValXML:_InfCte:_Ide:_Toma3,"_TOMA")) <> "U"
	If AllTrim(oValXML:_InfCte:_Ide:_Toma3:_TOMA:Text) == "3"
		lDesTrFil := .T. // Destinatario da nota no processo de transferencia entre filiais
		If AllTrim(XmlChildEx(oValXML:_InfCte:_Dest,cTagDest):Text) != AllTrim(cCNPJ_CPF)
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf   
	//27.12.2017 - Chamado 62165 - Validar Também o CPF do Expedidor
	If AllTrim(oValXML:_InfCte:_Ide:_Toma3:_TOMA:Text) == "1"	
		//lDesTrFil := .T. 
		If AllTrim(XmlChildEx(oValXML:_InfCte:_Exped,cTagExp):Text) != AllTrim(cCNPJ_CPF)
			lRet := .F.   
		Else
			lRet := .T.
		Endif
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Validacao para tag TOMA4 quando a empresa nao e Remetente, Expedidor, Recebedor nem			³
//³ Destinatario																	 			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(XmlChildEx(oValXML:_InfCte:_Ide,"_TOMA4")) <> "U"
	If AllTrim(oValXML:_InfCte:_Ide:_Toma4:_TOMA:Text) == "4"
		cTagToma4 := If(ValType(XmlChildEx(oValXML:_InfCte:_Ide:_Toma4,"_CNPJ")) == "O","_CNPJ","_CPF")
		lToma4 := .T.
		If AllTrim(XmlChildEx(oValXML:_InfCte:_Ide:_Toma4,cTagToma4):Text) == AllTrim(cCNPJ_CPF)
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetXmlIcms(oXml)

Local nIcms := 0
Local aIcms := {{"1", {"_ICMS00", "_ICMS20", "_CST00", "_CST20"}},;
				{"2", {"_ICMS45", "_CST45"}},;
				{"3", {"_ICMS60", "_CST60"}},;
				{"4", {"_ICMS80", "_ICMS90", "_CST80", "_CST90"}};
			   }
Local nX
Local nY
Local oXmlAux
//Local oXmlIcms := XmlChildEx(oXml:_cteProc:_CTe:_infCte:_imp, "_ICMS")
Local oXmlIcms := XmlChildEx(oXml:_infCte:_imp, "_ICMS")
Local aRet     := {"2" /*Tributação*/, 0/*Base*/, 0/*Alíquota*/, 0/*Valor*/}

If ValType(oXmlIcms) # "O"
	oXmlIcms := oXml
EndIf

Begin Sequence
	If ValType(oXmlIcms) # "O"
		Break
	EndIf
	For nX := 1 To Len(aIcms)
		For nY := 1 To Len(aIcms[nX][2])
			If ValType(oXmlAux := XmlChildEx(oXmlIcms, aIcms[nX][2][nY])) == "O"     
				If aIcms[nX][1] != "2"
					IF aIcms[nX][2][1] == '_ICMS60'
						aRet := {aIcms[nX][1], Val(oXmlAux:_vBCSTRet:Text), Val(oXmlAux:_vICMSSTRet:Text), Val(oXmlAux:_pICMSSTRet:Text)}
					ELSE
						aRet := {aIcms[nX][1], Val(oXmlAux:_vBC:Text), Val(oXmlAux:_pICMS:Text), Val(oXmlAux:_vICMS:Text)}
					ENDIF
				EndIf
				Break
			EndIf
		Next nY
	Next nX
End Sequence

Return (aRet)