#INCLUDE 'Protheus.ch'

User Function GOX003(lJob, aErros, oXml, lVldExist, lIsCTeOS)
	
	Local aAreaSZW   := (_cTab1)->( GetArea() )
	Local aAux		 := {}
	Local aAux1		 := {}
	Local aAux2		 := {}
	Local aCabec116	 := {}
	Local aDadosCli  := Array(3) //-- 1- Codigo; 2-Loja
	Local aDadosFor  := Array(3) //-- 1- Codigo; 2-Loja
	Local aEspecVol  := {}
	Local aItens116	 := {}
	Local cChaveNF   := ""
	Local cChaveNF2  := ""
	Local cChaveNF3  := ""
	Local cCNPJ_CF	 := ""
	Local cCNPJ_CT	 := ""
	Local cCodiRem   := ""
	Local cCPag_CT 	 := ""
	Local cError     := ""
	Local cFornCTe   := ""
	Local cLojaCTe   := ""
	Local cLojaRem   := ""
	Local cNomeCTe   := ""
	Local lMultRem   := .F.
	Local cPrdFrete  := "" //PadR(SuperGetMV("MV_XMLPFCT",.F.,""),TamSX3("B1_COD")[1])
	Local cTagDest	 := ""
	Local cTagRem	 := ""
	Local cTES_CT 	 := ""
	Local cTipoFrete := "F"
	Local lDesTrFil	 := .F.
	Local lOutTom    := .F.
	Local lRemet 	 := .F.
	Local lDest      := .F.
	Local lExped     := .F.
	Local lRet       := .T.
	Local lCtExiste  := .F.
	Local nPesoBruto := 0
	Local nPesoLiqui := 0
	Local nTamCmpNF  := TamSX3("F1_DOC")[1]
	Local nTamNota   := GetNewPar("MV_XGTTMNF", 9)
	Local nX		 := 0
	Local lTemNota   := .T.
	Local oInfNf
	Local aEmit
	Local _cRem      := "" // Porque a Lidi tem problemas com inicializar a variável
	Local _cDest     := "" // Porque a Lidi tem problemas com inicializar a variável
	Local aAllRem    := {}
	Local nAll
	Local cCodRAnt
	Local cLojRAnt
	
	Local lSubCont := .F.
	
	Local lInfOutros := .F.
	
	Local lOutFil    := .F.
	
	Local cChvCte
	
	Local aRetPosNF
	
	Private lFilRem  := .F.
	Private lFilDest := .F.
	Private cFilRem  := xFilial("SF2")
	Private cFilDest := xFilial("SF1")
	
	Default aErros    := {} 
	Default lJob      := .T.
	Default lVldExist := .T.
	Default lISCTeOS  := .F.
	
	oXmlAux := oXml

	//-- Verifica se o arquivo pertence a filial corrente
	If !CTe_VldEmp(oXML, SM0->M0_CGC, @lDesTrFil, @lOutTom, @lRemet, @lDest, lIsCTeOS, @lExped)
		
		If lJob
			aAdd(aErros, "Esta filial não é a tomadora do frete deste XML. Verificar se corresponde a filial corrente e pertente a este grupo de empresa.")
		Else
			Aviso("Erro", "Esta filial não é a tomadora do frete deste XML. Verificar se corresponde a filial corrente e pertente a este grupo de empresa.",{"OK"},2,"ImpXML_CTe")
		EndIf
		
		lRet := .F.
		
		lOutFil := .T.
		
	EndIf
	
	If Type("oXmlAux:_InfCte:_Ide:_TPSERV") == "O"
		
		If AllTrim(oXmlAux:_InfCte:_Ide:_TPSERV:Text) == "1"
			
			lSubCont := .T.
			
		EndIf
		
	EndIf
	
	//-- Verifica se o ID ja foi processado
	
	cChvCte := Right(AllTrim(oXML:_InfCte:_Id:Text),44)
	
	(_cTab1)->( dbSetOrder(1) )
	
	If lRet .And. lVldExist .And. (_cTab1)->( dbSeek(cChvCte + "2") )
		
		If lJob
			aAdd(aErros, "ID de CT-e já registrado na NF " + (_cTab1)->(AllTrim(&(_cCmp1+"_DOC")) + "/" + AllTrim(&(_cCmp1+"_SERIE"))); //
							 + " do Fornecedor/Cliente " + (_cTab1)->(AllTrim(&(_cCmp1+"_CODEMI")) + "/" + AllTrim(&(_cCmp1+"_LOJEMI"))) + " na filial " + (_cTab1)->&(_cCmp1+"_FILIAL") + " com situação: " + AllTrim(CBoxInfo(_cCmp1 + "_SIT", (_cTab1)->&(_cCmp1 + "_SIT"), 2)) + ".")
		Else
			Aviso("Erro", "ID de CT-e já registrado na NF " + (_cTab1)->(AllTrim(&(_cCmp1+"_DOC")) + "/" + AllTrim(&(_cCmp1+"_SERIE")));
						  + " do Fornecedor/Cliente " + (_cTab1)->(AllTrim(&(_cCmp1+"_CODEMI")) + "/" + AllTrim(&(_cCmp1+"_LOJEMI"))) + " na filial " + (_cTab1)->&(_cCmp1+"_FILIAL") + " com situação: " + AllTrim(CBoxInfo(_cCmp1 + "_SIT", (_cTab1)->&(_cCmp1 + "_SIT"), 2)) + ".", {"OK"}, 2, "ImpXML_CTe")
		EndIf
		
		lRet      := .F.
		lCtExiste := .T.
		
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
		
		aEmit := U_CliForGO(cCNPJ_CT)
		
		If aEmit[1] # 1//!SA2->(dbSeek(xFilial("SA2")+cCNPJ_CT))
			
			If lJob
				aAdd(aErros, "Fornecedor " + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R 99.999.999/9999-99") +"] inexistente no sistema.")
			Else
				Aviso("Erro","Fornecedor " + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R 99.999.999/9999-99") +"] inexistente no sistema.", "Gere cadastro para este fornecedor.",2,"ImpXML_CTe")
			EndIf
			
			lRet := .F.
			
		Else
			
			cFornCTe := aEmit[2]
			cLojaCTe := aEmit[3]
			cNomeCTe := aEmit[7]
			
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
	
	If lRet .And. !lIsCTeOS

		cTagRem := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF")
		
		If lRemet .And. !lDesTrFil //:= (SM0->M0_CGC == ALLTRIM(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)) .And. !lDesTrFil
			
			cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF")
			cCNPJ_CF := ALLTRIM(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
			
			aEmit := U_CliForGO(cCNPJ_CF, .T.)
			
			//SA1->(dbSetOrder(3))
			If aEmit[1] == 2 //SA1->(dbSeek(xFilial("SA1")+cCNPJ_CF))
				aDadosCli[1] := aEmit[2]//SA1->A1_COD
				aDadosCli[2] := aEmit[3]//SA1->A1_LOJA
				aDadosCli[3] := aEmit[9]
			Else
				aDadosCli[1] := CriaVar("A1_COD",.F.)
				aDadosCli[2] := CriaVar("A1_LOJA",.F.)
				aDadosCli[3] := .F.
			EndIf
			
			aEmit := U_CliForGO(cCNPJ_CF)
			
			//SA2->(dbSetOrder(3))
			If aEmit[1] == 1 //SA2->(dbSeek(xFilial("SA2")+cCNPJ_CF))
				aDadosFor[1] := aEmit[2]//SA2->A2_COD
				aDadosFor[2] := aEmit[3]//SA2->A2_LOJA
				aDadosFor[3] := aEmit[9]
			Else
				aDadosFor[1] := CriaVar("A2_COD",.F.)
				aDadosFor[2] := CriaVar("A2_LOJA",.F.)
				aDadosFor[3] := .F.
			EndIf
			
			If !Empty(aDadosCli[1]) .And. Empty(aDadosFor[1])
				cCodiRem := aDadosCli[1]
				cLojaRem := aDadosCli[2]
				lMultRem := aDadosCli[3]
			ElseIf Empty(aDadosCli[1]) .And. !Empty(aDadosFor[1])
				cCodiRem := aDadosFor[1]
				cLojaRem := aDadosFor[2]
				lMultRem := aDadosFor[3]
			ElseIf !lDesTrFil .And. !Empty(aDadosCli[1])
				cCodiRem := aDadosCli[1]
				cLojaRem := aDadosCli[2]
				lMultRem := aDadosCli[3]
			EndIf
			
			cTipoFrete := "F"
		
		EndIf
		
		If lDest .And. (!lRemet .Or. lDesTrFil) //!(lRemet .And. !lDesTrFil)

			cTagRem  := IF(ValType(XmlChildEx(oXML:_InfCte:_Rem, "_CNPJ")) == "O", "_CNPJ", "_CPF")
			cCNPJ_CF := ALLTRIM(XmlChildEx(oXML:_InfCte:_Rem, cTagRem):Text)  //-- Armazena o CNPJ do remetente das notas contidas no conhecimento

			cTipoFrete := "C"
			//-- Como no XML nao e possivel saber se o destinatario e cliente ou fornecedor
			//-- Validarei os dois casos
			
			aEmit := U_CliForGO(cCNPJ_CF, .T.)
			
			//SA1->(dbSetOrder(3))

			If aEmit[1] == 2 //SA1->(dbSeek(xFilial("SA1")+cCNPJ_CF))

				aDadosCli[1] := aEmit[2] //SA1->A1_COD
				aDadosCli[2] := aEmit[3] //SA1->A1_LOJA
				aDadosCli[3] := aEmit[9]
				
			Else

				aDadosCli[1] := CriaVar("A1_COD",.F.)
				aDadosCli[2] := CriaVar("A1_LOJA",.F.)
				aDadosCli[3] := .F.
				
			EndIf
			
			aEmit := U_CliForGO(cCNPJ_CF)
			
			//SA2->(dbSetOrder(3))

			If aEmit[1] == 1 //SA2->(dbSeek(xFilial("SA2")+cCNPJ_CF))

				aDadosFor[1] := aEmit[2] //SA2->A2_COD
				aDadosFor[2] := aEmit[3] //SA2->A2_LOJA
				aDadosFor[3] := aEmit[9]
				
			Else

				aDadosFor[1] := CriaVar("A2_COD",.F.)
				aDadosFor[2] := CriaVar("A2_LOJA",.F.)
				aDadosFor[3] := .F.
				
			EndIf

			If Empty(aDadosCli[1]) .And. !Empty(aDadosFor[1])

				cCodiRem := aDadosFor[1]
				cLojaRem := aDadosFor[2]
				lMultRem := aDadosFor[3]
				
			ElseIf !Empty(aDadosCli[1]) .And. Empty(aDadosFor[1])

				cCodiRem := aDadosCli[1]
				cLojaRem := aDadosCli[2]
				lMultRem := aDadosCli[3]

			ElseIf lDesTrFil .And. !Empty(aDadosFor[1])

				cCodiRem := aDadosFor[1]
				cLojaRem := aDadosFor[2]
				lMultRem := aDadosFor[3]

			EndIf
			
		EndIf
		
		If lOutTom .And. !lDest .And. !lRemet .And. !lSubCont
			
			cTipoFrete := "C"
			
			cCodiRem := ""
			cLojaRem := ""
			
			_cTagRem  := If(ValType(XmlChildEx(oXML:_InfCte:_Rem, "_CNPJ")) == "O", "_CNPJ", "_CPF")
			_cRem     := ""
			
			If Type("oXmlAux:_InfCte:_Rem:" + _cTagRem) == "O"
			
				_cRem := ALLTRIM(XmlChildEx(oXML:_InfCte:_Rem, _cTagRem):Text)
				
			EndIf
			
			_cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_Dest, "_CNPJ")) == "O", "_CNPJ", "_CPF")
			_cDest    := ""
			
			If Type("oXmlAux:_InfCte:_Dest:" + _cTagDest) == "O"
				
				_cDest := ALLTRIM(XmlChildEx(oXML:_InfCte:_Dest, _cTagDest):Text)
				
			EndIf
			
			RetoFili(_cRem, _cDest)
			
		EndIf
		
	EndIf
	
	If lRet .And. !lIsCTeOS
		//-- Caso o remetente nao seja a propria empresa, valida o cadasotro do remetente
		//-- Podendo este ser cliente ou fornecedor (descobira atrabes das notas do conhecimento)
		If (lDest .Or. (lOutTom .And. !lRemet)) .And. !lSubCont
			
			If (lOutTom .And. !lRemet) .And. !lDest
			
				aEmit := U_CliForGO(_cRem)
	
				If aEmit[1] == 1
					aDadosFor[1] := aEmit[2]
					aDadosFor[2] := aEmit[3]
				Else
					aDadosFor[1] := CriaVar("A2_COD",.F.)
					aDadosFor[2] := CriaVar("A2_LOJA",.F.)
				EndIf
				
				aEmit := U_CliForGO(_cRem, .T.)
	
				If aEmit[1] == 2
					aDadosCli[1] := aEmit[2]
					aDadosCli[2] := aEmit[3]
				Else
					aDadosCli[1] := CriaVar("A1_COD",.F.)
					aDadosCli[2] := CriaVar("A1_LOJA",.F.)
				EndIf
			
			EndIf
			
			If ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNF")) != "U" .Or. ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNFE")) != "U"
				
				oInfNf := oXML:_InfCte:_Rem
			
			ElseIf ValType(XmlChildEx(oXML:_InfCte, "_INFCTENORM")) != "U"
				
				If ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm, "_INFDOC")) != "U"
				
					If ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc, "_INFNF")) != "U" .Or. ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc, "_INFNFE")) != "U" .Or. ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc, "_INFOUTROS")) != "U"
					
						oInfNf := oXML:_InfCte:_InfCTeNorm:_InfDoc
						
					Else
						
						lTemNota := .F.
						
					EndIf
					
				Else
					
					lTemNota := .F.
					
				EndIf
			
			ElseIf ValType(XmlChildEx(oXML:_InfCte, "_INFCTECOMP")) != "U"
				
				oInfNf := oXML:_InfCte
				
			Else
				
				lTemNota := .F.
				
			EndIf
			
			If lTemNota
			
				//-- Separa secao que contem as notas do conhecimento para laco
				If ValType(XmlChildEx(oInfNf, "_INFNF")) != "U"
					
					aAux := If(ValType(oInfNf:_INFNF) == "O", {oInfNf:_INFNF}, oInfNf:_INFNF)
					
				EndIf
				
				If ValType(XmlChildEx(oInfNf, "_INFOUTROS")) != "U"
					
					lInfOutros := .T.
					
					aAux := If(ValType(oInfNf:_INFOUTROS) == "O", {oInfNf:_INFOUTROS}, oInfNf:_INFOUTROS)
					
					If ValType(XmlChildEx(aAux[1], "_NDOC")) == "U" .And. ValType(XmlChildEx(aAux[1], "_DESCOUTROS")) == "U"
						
						aAux := {}
						
					EndIf
					
				EndIf
				
				If ValType(XmlChildEx(oInfNf, "_INFNFE")) != "U"
					
					aAux1 := If(ValType(oInfNf:_INFNFE) == "O", {oInfNf:_INFNFE}, oInfNf:_INFNFE)
					
				EndIf
				
				If ValType(XmlChildEx(oInfNf, "_INFCTECOMP")) != "U"
					
					aAux1 := If(ValType(oInfNf:_INFCTECOMP) == "O", {oInfNf:_INFCTECOMP}, oInfNf:_INFCTECOMP)
					
				EndIf
				
				// Limpa filtro da tabela SF1 para pesquisar pelo fornecedor correto
				SF1->(dbClearFilter())
				
				If Len(aAux) > 0		// Quando preenche aAux significa que o XML contem os numeros das notas originais, portanto o emitente do CTe nao trabalha com NF-e
				
					SF1->(dbSetOrder(1))
					//Miseri
					For nX := 1 To Len(aAux)
						
						If lInfOutros
							
							If ValType(XmlChildEx(aAux[1], "_NDOC")) == "U"
								
								cChaveNF  := Padr(PadL(AllTrim(aAux[nX]:_DescOutros:Text), GetNewPar("MV_XGTTMNF", 9), "0"),TamSX3("F1_DOC")[1])
								
								cChaveNF2 := Padr(AllTrim(aAux[nX]:_DescOutros:Text),TamSX3("F1_DOC")[1])
								
							Else
								
								cChaveNF  := Padr(PadL(AllTrim(aAux[nX]:_nDoc:Text), GetNewPar("MV_XGTTMNF", 9), "0"),TamSX3("F1_DOC")[1])
								
								cChaveNF2 := Padr(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F1_DOC")[1])
								
							EndIf
							
						Else
							
							cChaveNF  := Padr(PadL(AllTrim(aAux[nX]:_nDoc:Text), GetNewPar("MV_XGTTMNF", 9), "0"),TamSX3("F1_DOC")[1]) + ;
							PadR(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F1_SERIE")[1])
							
							cChaveNF2 := Padr(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F1_DOC")[1]) + ;
							PadR(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F1_SERIE")[1])
							
						EndIf
						
						If !lInfOutros .And. IsDigit(aAux[nX]:_Serie:Text)
							
							cChaveNF3 := Padr(PadL(AllTrim(aAux[nX]:_nDoc:Text), GetNewPar("MV_XGTTMNF", 9), "0"),TamSX3("F1_DOC")[1]) + ;
							Padr(cValToChar(Val(AllTrim(aAux[nX]:_Serie:Text))), TamSX3("F1_SERIE")[1])
							
						EndIf
						
						//-- Se remetente nao identificado e porque pode ser cliente ou fornecedor
						//-- Dai identifica atraves de seek no SF1
						If Empty(cCodiRem)
						
							If SF1->(dbSeek(cFilDest + cChaveNF + aDadosFor[1] + aDadosFor[2])) .Or. ;
							   SF1->(dbSeek(cFilDest + cChaveNF2 + aDadosFor[1] + aDadosFor[2])) // Se achar, significa que sao notas de compra
							
								cCodiRem := SF1->F1_FORNECE
								cLojaRem := SF1->F1_LOJA
								
							ElseIf SF1->(dbSeek(cFilDest + cChaveNF + aDadosCli[1] + aDadosCli[1])) .Or. ;
							       SF1->(dbSeek(cFilDest + cChaveNF2 + aDadosCli[1] + aDadosCli[1])) //Se achar, significa que sao notas de devol./beneficiamento
							
								cCodiRem := SF1->F1_FORNECE
								cLojaRem := SF1->F1_LOJA
								
							Else //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
								
								lRet := .F.
								
							EndIf
							
						Else 
							
							If !SF1->( dbSeek(cFilDest + cChaveNF + cCodiRem + cLojaRem) ) .And. !SF1->( dbSeek(cFilDest + cChaveNF2 + cCodiRem + cLojaRem) ) .And. IIf(!Empty(cChaveNF3), !SF1->( dbSeek(cFilDest + cChaveNF3 + cCodiRem + cLojaRem) ), .T.)
								
								lRet := .F. //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
								
								aAllRem := AllEmit("SA2", cCodiRem + cLojaRem)
								
								If lMultRem
									
									cCodRAnt := cCodiRem
									cLojRAnt := cLojaRem
									
									For nAll := 1 To Len(aAllRem)
										
										cCodiRem := aAllRem[nAll][1]
										cLojaRem := aAllRem[nAll][2]
										
										If SF1->( dbSeek(cFilDest + cChaveNF + cCodiRem + cLojaRem) ) .Or. SF1->( dbSeek(cFilDest + cChaveNF2 + cCodiRem + cLojaRem) ) .Or. IIf(!Empty(cChaveNF3), SF1->( dbSeek(cFilDest + cChaveNF3 + cCodiRem + cLojaRem) ), .F.)
											
											lRet := .T.
											
											Exit
											
										EndIf
										
									Next nAll
									
									cCodiRem := cCodRAnt
									cLojaRem := cLojRAnt
									
								EndIf
								
								If !lRet .And. ExistBlock("GOXPOSNF")
									
									aRetPosNF := ExecBlock("GOXPOSNF", .F., .F., {aAux, cCodiRem, cLojaRem, cFilDest, nX})
									
									If ValType(aRetPosNF) == "A" .And. Len(aRetPosNF) > 1
										
										If aRetPosNF[1]
											
											SF1->( dbGoTo(aRetPosNF[2]) )
											
											lRet := .T.
											
										EndIf
										
									EndIf
									
								EndIf
								
							EndIf
							
						EndIf
						
						SF1->( dbSetOrder(1) )
						
						//-- Registra notas que farao parte do conhecimento
						If lRet
						
							cTipoFrete := "C"
							
							aAdd(aItens116, {{"PRIMARYKEY", SF1->&(IndexKey())}})
							
						Else
						
							If lJob
								
								If lInfOutros
									
									aAdd(aErros, "Documento de entrada Outros Documentos inexistente no sistema.")
									
								Else
									
									aAdd(aErros, "Documento de entrada Outros Documentos inexistente no sistema.")
									
								EndIf
								
							Else
							
								Aviso("Erro", "Documento de entrada " + AllTrim(aAux[nX]:_nDoc:Text) + "/" + AllTrim(aAux[nX]:_Serie:Text) + " inexistente no sistema. Processe o recebimento deste documento de entrada.", 2, "ImpXML_CTe")
								
							EndIf
							
							If Alltrim(cCNPJ_CT) $ GetNewPar("MV_XGTCTSN", "") .Or. lOutTom .Or. lSubCont ;
								.Or. (AllTrim(cCodiRem) + AllTrim(cLojaRem)) $ GetNewPar("MV_ZGOCTLF", "")
								
								lTemNota := .F.
								
								lRet := .T.
								
							Else
								
								Exit
								
							EndIf
							
						EndIf
						
					Next nX
					
				EndIf
				
				If Len(aAux1) > 0 // Quando preenche aAux1 significa que o XML contem a chave DANFE das notas originais, portanto o emitente do CTe trabalha com NF-e
				
					For nX := 1 To Len(aAux1)
					
						SF1->(dbSetOrder(8))
						
						If ValType(XmlChildEx(aAux1[nX], "_CHAVE")) != "U"
							
							cChaveNF :=	Padr(AllTrim(aAux1[nX]:_chave:Text),TamSX3("F1_CHVNFE")[1])
							
						ElseIf ValType(XmlChildEx(aAux1[nX], "_CHCTE")) != "U"
							
							cChaveNF :=	Padr(AllTrim(aAux1[nX]:_chCTe:Text),TamSX3("F1_CHVNFE")[1])
							
						EndIf
						
						dbSelectArea(_cTab8)
						(_cTab8)->( dbSetOrder(1) )
						If !(_cTab8)->( dbSeek(cChvCte + cChaveNF) )
							
							RecLock(_cTab8, .T.)
								
								(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
								(_cTab8)->&(_cCmp8 + "_TIPO")   := "1 "
								(_cTab8)->&(_cCmp8 + "_CHVCTE") := cChvCte
								(_cTab8)->&(_cCmp8 + "_CHVNFE") := cChaveNF
								
							(_cTab8)->( MSUnlock() )
							
						EndIf
						
						//-- Se remetente nao identificado e porque pode ser cliente ou fornecedor
						//-- Dai identifica atraves de seek no SF1 e SF2
						If Empty(cCodiRem)
						
							If SF1->(dbSeek(cFilDest + cChaveNF))
							
								dbSelectArea("SA2")
								dbSetOrder(1)
								
								If SA2->(dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA)) // Se achar, significa que sao notas de compra
								
									cCodiRem := SF1->F1_FORNECE
									cLojaRem := SF1->F1_LOJA
									
								Else
								
									dbSelectArea("SA1")
									dbSetOrder(1)
									
									If SA1->(dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA)) //Se achar, significa que sao notas de devol./beneficiamento
									
										cCodiRem := SF1->F1_FORNECE
										cLojaRem := SF1->F1_LOJA
										
									EndIf
									
								EndIf
								
							Else //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
							
								lRet := .F.
								
							EndIf
							
						ElseIf !SF1->(dbSeek(cFilDest + cChaveNF))
						
							lRet := .F. //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
							
							If ExistBlock("GOXPSNFE")
								
								aRetPosNF := ExecBlock("GOXPSNFE", .F., .F., {aAux, cCodiRem, cLojaRem, cFilDest, cChaveNF, nTamNota})
								
								If ValType(aRetPosNF) == "A" .And. Len(aRetPosNF) > 1
									
									If aRetPosNF[1]
										
										SF1->( dbGoTo(aRetPosNF[2]) )
										
										lRet := .T.
										
									EndIf
									
								EndIf
								
							EndIf
							
						EndIf
						
						SF1->(dbSetOrder(1))
						
						//-- Registra notas que farao parte do conhecimento
						If lRet
							
							cTipoFrete := "C"
							
							aAdd(aItens116, {{"PRIMARYKEY", SF1->&(IndexKey())}})
							
						Else
						
							If lJob
							
								aAdd(aErros, "Documento de entrada " + cChaveNF + " inexistente no sistema.")
								
							Else
							
								Aviso("Erro", "Documento de entrada" + cChaveNF + " inexistente no sistema. Processe o recebimento deste documento de entrada.",2,"ImpXML_CTe")
								
							EndIf
							
							If lOutTom .Or. lSubCont
								
								lTemNota := .F.
								
								lRet := .T.
								
							Else
							
								Exit
								
							EndIf
							
						EndIf
						
					Next nX
					
				EndIf
				
			Else
			
				If lJob
				
					aAdd(aErros, "Conhecimento sem nota vinculada.")
					
				Else
				
					Aviso("Erro", "Conhecimento sem nota vinculada",2,"ImpXML_CTe")
					
				EndIf
				
				//lRet := .F.
				
			EndIf
			
		EndIf
		
		If Empty(aItens116) //.And. (lRemet .Or. lOutTom)
			
			aAux		 := {}
			aAux1		 := {}
			aAux2		 := {}
			
			If (lOutTom) .And. !lRemet
			
				aEmit := U_CliForGO(_cDest)
	
				If aEmit[1] == 1
					aDadosFor[1] := aEmit[2]
					aDadosFor[2] := aEmit[3]
				Else
					aDadosFor[1] := CriaVar("A2_COD",.F.)
					aDadosFor[2] := CriaVar("A2_LOJA",.F.)
				EndIf
				
				aEmit := U_CliForGO(_cDest, .T.)
	
				If aEmit[1] == 2
					aDadosCli[1] := aEmit[2]
					aDadosCli[2] := aEmit[3]
				Else
					aDadosCli[1] := CriaVar("A1_COD",.F.)
					aDadosCli[2] := CriaVar("A1_LOJA",.F.)
				EndIf
			
			EndIf
			
			If ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNF")) != "U" .Or. ValType(XmlChildEx(oXML:_InfCte:_Rem, "_INFNFE")) != "U"
				
				oInfNf := oXML:_InfCte:_Rem
			
			ElseIf ValType(XmlChildEx(oXML:_InfCte, "_INFCTENORM")) != "U"
				
				If ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm, "_INFDOC")) != "U"
				
					If ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc, "_INFNF")) != "U" .Or. ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc, "_INFNFE")) != "U"
						
						oInfNf := oXML:_InfCte:_InfCTeNorm:_InfDoc
						
					Else
						
						lTemNota := .F.
						
					EndIf
					
				Else
					
					lTemNota := .F.
					
				EndIf
				
			ElseIf ValType(XmlChildEx(oXML:_InfCte, "_INFCTECOMP")) != "U"
				
				oInfNf := oXML:_InfCte
				
			Else
					
				lTemNota := .F.
				
			EndIf
			
			If lTemNota
			
				//-- Separa secao que contem as notas do conhecimento para laco
				If ValType(XmlChildEx(oInfNf, "_INFNF")) != "U"
				
					aAux := If(ValType(oInfNf:_INFNF) == "O", {oInfNf:_INFNF}, oInfNf:_INFNF)
					
				EndIf
				
				If ValType(XmlChildEx(oInfNf, "_INFNFE")) != "U"
				
					aAux1 := If(ValType(oInfNf:_INFNFE) == "O", {oInfNf:_INFNFE}, oInfNf:_INFNFE)
					
				EndIf
				
				If ValType(XmlChildEx(oInfNf, "_INFCTECOMP")) != "U"
				
					aAux2 := If(ValType(oInfNf:_INFCTECOMP) == "O", {oInfNf:_INFCTECOMP}, oInfNf:_INFCTECOMP)
					
				EndIf
				
				SF2->( dbClearFilter() )
				
				If Len(aAux) > 0
				
					SF2->( dbSetOrder(1) )
					
					For nX := 1 To Len(aAux)
					
						cChaveNF :=	Padr(PadL(AllTrim(aAux[nX]:_nDoc:Text), GetNewPar("MV_XGTTMNF", 9), "0"),TamSX3("F2_DOC")[1]) + ;
						            Padr(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F2_SERIE")[1])
						
						cChaveNF2 := Padr(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F2_DOC")[1]) + ;
						             Padr(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F2_SERIE")[1])
						
						If Empty(cCodiRem)
						
							If SF2->(dbSeek(cFilRem + cChaveNF + aDadosCli[1] + aDadosCli[1])) .Or. ;
							   SF2->(dbSeek(cFilRem + cChaveNF2 + aDadosCli[1] + aDadosCli[1]))
							
								cCodiRem := aDadosCli[1]
								cLojaRem := aDadosCli[2]
								
							ElseIf SF2->(dbSeek(cFilRem + cChaveNF + aDadosFor[1] + aDadosFor[2])) .Or. ;
							       SF2->(dbSeek(cFilRem + cChaveNF2 + aDadosFor[1] + aDadosFor[2]))
							
								cCodiRem := aDadosFor[1]
								cLojaRem := aDadosFor[2]
								
							Else
							
								lRet := .F.
								
							EndIf
							
						ElseIf !SF2->(dbSeek(cFilRem + cChaveNF + cCodiRem + cLojaRem)) .And. !SF2->(dbSeek(cFilRem + cChaveNF2 + cCodiRem + cLojaRem))
						
							lRet := .F. //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
							
						EndIf
						
						//-- Registra notas que farao parte do conhecimento
						If lRet .And. !lSubCont
						
							cTipoFrete := "F"
							
							aAdd(aItens116, {{"PRIMARYKEY", SF2->&(IndexKey())}})
							
						Else
						
							If lJob
							
								aAdd(aErros, "Documento de saída " + AllTrim(aAux[nX]:_nDoc:Text) + "/" + AllTrim(aAux[nX]:_Serie:Text) + " inexistente no sistema.")
								
							Else
							
								Aviso("Erro", "Documento de saída " + AllTrim(aAux[nX]:_nDoc:Text) + "/" + AllTrim(aAux[nX]:_Serie:Text) + " inexistente no sistema. Processe o recebimento deste documento de entrada.", 2, "ImpXML_CTe")
								
							EndIf
							
							If Alltrim(cCNPJ_CT) $ GetNewPar("MV_XGTCTSN", "") .Or. lSubCont ;
								.Or. (AllTrim(cCodiRem) + AllTrim(cLojaRem)) $ GetNewPar("MV_ZGOCTLF", "")
							
								lTemNota := .F.
								lRet     := .T.
								
							Else
							
								Exit
								
							EndIf
							
						EndIf
						
					Next nX
					
				EndIf
				
				If Len(aAux1) > 0
				
					For nX := 1 To Len(aAux1)
					
						SF2->(dbOrderNickName("CHAVE"))
						cChaveNF :=	Padr(AllTrim(aAux1[nX]:_chave:Text),TamSX3("F2_CHVNFE")[1])
						
						dbSelectArea(_cTab8)
						(_cTab8)->( dbSetOrder(1) )
						If !(_cTab8)->( dbSeek(cChvCte + cChaveNF) )
							
							RecLock(_cTab8, .T.)
								
								(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
								(_cTab8)->&(_cCmp8 + "_TIPO")   := "1 "
								(_cTab8)->&(_cCmp8 + "_CHVCTE") := cChvCte
								(_cTab8)->&(_cCmp8 + "_CHVNFE") := cChaveNF
								
							(_cTab8)->( MSUnlock() )
							
						EndIf
						
						If Empty(cCodiRem)
						
							If SF2->(dbSeek(cFilRem + cChaveNF))
							
								lRet := .T.
								
								dbSelectArea("SA1")
								dbSetOrder(1)
								
								If SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
								
									cCodiRem := SF2->F2_CLIENTE
									cLojaRem := SF2->F2_LOJA
									
								Else
								
									dbSelectArea("SA2")
									dbSetOrder(1)
									
									If SA2->(dbSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA))
									
										cCodiRem := SF2->F2_CLIENTE
										cLojaRem := SF2->F2_LOJA
										
									EndIf
									
								EndIf
								
							Else
							
								lRet := .F.
								
							EndIf
							
						Else
						
							If SF2->(dbSeek(cFilRem + cChaveNF))
							
								lRet := .T.
								
							Else
							
								lRet := .F.
								
							EndIf
							
						EndIf
						
						SF2->(dbSetOrder(1))
						
						If lRet .And. !lSubCont
						
							cTipoFrete := "F"
							
							aAdd(aItens116, {{"PRIMARYKEY", SF2->&(IndexKey())}})
							
						Else
						
							If lJob
							
								aAdd(aErros, "Documento de saída " + cChaveNF + " inexistente no sistema.")
								
							Else
							
								Aviso("Erro", "Documento de saída " + cChaveNF + " inexistente no sistema. Processe o recebimento deste documento de entrada.",2,"ImpXML_CTe")
								
							EndIf
							
							If lSubCont
							
								lTemNota := .F.
								lRet     := .T.
								
							Else
							
								Exit
								
							EndIf
							
						EndIf
						
					Next nX
					
				EndIf
				
				If Len(aAux2) > 0 // Quando preenche aAux1 significa que o XML contem a chave DANFE das notas originais, portanto o emitente do CTe trabalha com NF-e
					
					For nX := 1 To Len(aAux2)
					
						SF1->(dbSetOrder(8))
						If ValType(XmlChildEx(aAux2[nX], "_CHCTE")) == "O"
							
							cChaveNF :=	Padr(AllTrim(aAux2[nX]:_chCTe:Text),TamSX3("F1_CHVNFE")[1])
							
						Else
							
							cChaveNF :=	Padr(AllTrim(aAux2[nX]:_chave:Text),TamSX3("F1_CHVNFE")[1])
							
						EndIf
						
						dbSelectArea(_cTab8)
						(_cTab8)->( dbSetOrder(1) )
						If !(_cTab8)->( dbSeek(cChvCte + cChaveNF) )
							
							RecLock(_cTab8, .T.)
								
								(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
								(_cTab8)->&(_cCmp8 + "_TIPO")   := "1 "
								(_cTab8)->&(_cCmp8 + "_CHVCTE") := cChvCte
								(_cTab8)->&(_cCmp8 + "_CHVNFE") := cChaveNF
								
							(_cTab8)->( MSUnlock() )
							
						EndIf
						
						//-- Se remetente nao identificado e porque pode ser cliente ou fornecedor
						//-- Dai identifica atraves de seek no SF1 e SF2
						If Empty(cCodiRem)
						
							If SF1->(dbSeek(cFilDest + cChaveNF))
							
								lRet := .T.
								
								dbSelectArea("SA2")
								dbSetOrder(1)
								
								If SA2->(dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA)) // Se achar, significa que sao notas de compra
								
									cCodiRem := SF1->F1_FORNECE
									cLojaRem := SF1->F1_LOJA
									
								Else
								
									dbSelectArea("SA1")
									dbSetOrder(1)
									
									If SA1->(dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA)) //Se achar, significa que sao notas de devol./beneficiamento
									
										cCodiRem := SF1->F1_FORNECE
										cLojaRem := SF1->F1_LOJA
										
									EndIf
									
								EndIf
								
							Else //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
							
								lRet := .F.
								
							EndIf
							
						Else
						
							If SF1->(dbSeek(cFilDest + cChaveNF))
							
								lRet := .T.
								
							Else
							
								lRet := .F. //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
								
							EndIf
							
						EndIf
						
						SF1->(dbSetOrder(1))
						
						//-- Registra notas que farao parte do conhecimento
						If lRet .And. !lSubCont
						
							cTipoFrete := "C"
							
							aAdd(aItens116, {{"PRIMARYKEY", SF1->&(IndexKey())}})
							
						Else
						
							If lJob
							
								aAdd(aErros, "Documento de entrada " + cChaveNF + " inexistente no sistema.")
								
							Else
							
								Aviso("Erro", "Documento de entrada" + cChaveNF + " inexistente no sistema. Processe o recebimento deste documento de entrada.",2,"ImpXML_CTe")
								
							EndIf
							
							If lSubCont
							
								lTemNota := .F.
								lRet     := .T.
								
							Else
							
								Exit
								
							EndIf
							
						EndIf
						
					Next nX
					
				EndIf
				
			Else
			
				If lJob
				
					aAdd(aErros, "Conhecimento sem nota vinculada.")
					
				Else
				
					Aviso("Erro", "Conhecimento sem nota vinculada",2,"ImpXML_CTe")
					
				EndIf
				
				//lRet := .F.
				
			EndIf
			
		EndIf
		
	EndIf
	
	IF lRet
		
		If lIsCTeOS
			
			lTemNota := .F.
			
		EndIf
		
		//-- Grava itens do conhecimento de transporte
		//IF lRemet

		AADD(aCabec116, {"MV_PAR11"  , dDataBase-90})                                                         // Data inicial para filtro das notas
		AADD(aCabec116, {"MV_PAR12"  , dDataBase})                                                            // Data final para filtro das notas
		AADD(aCabec116, {"MV_PAR13"  , 2})                                                                    // 2-Inclusao ; 1=Exclusao
		AADD(aCabec116, {"MV_PAR14"  , cCodiRem})                                                             // Rementente das notas contidas no conhecimento
		AADD(aCabec116, {"MV_PAR15"  , cLojaRem})                                                             // Loja do remetente das notas contidas no conhecimento
		AADD(aCabec116, {"MV_PAR16"  , 1})                                                                    // Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
		AADD(aCabec116, {"MV_PAR17"  , /*Aglutina*/})                                                         // 1=Aglutina itens ; 2=Nao aglutina itens
		AADD(aCabec116, {"MV_PAR18"  , Space(TamSx3("F1_EST")[1])})                                           // UF das notas contidas no conhecimento
		AADD(aCabec116, {"MV_PAR21"  , Val(oXML:_InfCte:_VPrest:_vTPrest:Text)})                                 // Valor do conhecimento
		AADD(aCabec116, {"MV_PAR22"  , 1})                                                                    // Formulario proprio: 1=Nao ; 2=Sim
		AADD(aCabec116, {"MV_PAR23"  , Right(IIf(Len(ALLTRIM(oXML:_InfCte:_Ide:_nCt:Text)) >= nTamNota, oXML:_InfCte:_Ide:_nCt:Text, PadL(ALLTRIM(oXML:_InfCte:_Ide:_nCt:Text), nTamNota, "0")), nTamCmpNF)})  // Numero da nota de conhecimento
		AADD(aCabec116, {"MV_PAR24"  , PadR(oXML:_InfCte:_Ide:_Serie:Text, TamSx3("F1_SERIE")[1])})           // Serie da nota de conhecimento
		AADD(aCabec116, {"MV_PAR25"  , cFornCTe})                                                             // Fornecedor da nota de conhecimento
		AADD(aCabec116, {"MV_PAR26"  , cLojaCTe})                                                             // Loja do fornecedor da nota de conhecimento
		AADD(aCabec116, {"MV_PAR27"  , ""/*TES*/})                                                            // TES a ser utilizada nos itens do conhecimento
		AADD(aCabec116, {"MV_PAR28"  , 0/*Val(oXML:_InfCte:_imp:_icms:_ICMS00:_vBC:Text)*/})                  // Valor da base de calculo do ICMS retido
		AADD(aCabec116, {"MV_PAR29"  , 0/*Val(oXML:_InfCte:_imp:_icms:_ICMS00:_vICMS:Text)*/})                // Valor do ICMS retido
		AADD(aCabec116, {"MV_PAR31"  , ""/*Cond*/})                                                           // Condicao de pagamento
		AADD(aCabec116, {"Emissao"   , SToD(Substr(StrTran(oXML:_InfCte:_Ide:_dhEmi:Text, "-", ""), 1, 8))})  // Data de emissao do conhecimento
		AADD(aCabec116, {"F1_ESPECIE", /*Especie*/})                                                          // Especie do documento
		AADD(aCabec116, {"Natureza"  , /*Natureza*/})
		AADD(aCabec116, {"COLAB"     , "N"})                                                                  // Chave para tratamentos especificos
		AADD(aCabec116, {"F1_CHVNFE" , Right(ALLTRIM(oXML:_InfCte:_Id:Text), 44)})                            // Chave para tratamentos especificos

	ENDIF
	
Return {lRet, aCabec116, aItens116, (cTipoFrete == "F"), lTemNota, lCtExiste, lOutFil}

//////////////////////////////////////

Static Function CTe_VldEmp(oXML, cCNPJ_CPF, lDesTrFil, lOutTom, lRemet, lDest, lIsCTeOS, lExped)
	
	Local lRet 	   := .T.
	Local cTagRem
	Local cTagDest
	Local cTagExp  := ""
	Local cTagTom  := ""
	
	Local lTemExp := .F.
	
	DEFAULT lDesTrFil := .F.
	DEFAULT lOutTom   := .F.
	
	If lIsCTeOS
		
		lDesTrFil := .F.
		lOutTom   := .F.
		lRemet    := .F.
		lDest     := .F.
		
		If ValType(XmlChildEx(oXML:_InfCte, "_TOMA")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Toma,"_CNPJ")) <> "U"
			
			If AllTrim(oXML:_InfCte:_Toma:_CNPJ:Text) # AllTrim(cCNPJ_CPF)
				
				lRet := .F.
				
			EndIf
			
		Else
			
			lRet := .F.
			
		EndIf
		
	Else
		
		cTagRem  := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF")
		cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF")
		
		If ValType(XmlChildEx(oXML:_InfCte, "_EXPED")) == "O"
			
			cTagExp := If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
			
			lTemExp := .T.
			
		EndIf
		
		//-- Verifica se o arquivo pertence a filial corrente
		lRemet := AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text) == AllTrim(cCNPJ_CPF)
		lDest  := AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) == AllTrim(cCNPJ_CPF)
		
		If lTemExp .And. AllTrim(XmlChildEx(oXML:_InfCte:_Exped,cTagExp):Text) == AllTrim(cCNPJ_CPF)
			
			lExped := .T.
			
		EndIf
		
		lRet := lRemet .Or. lDest .Or. lExped
		
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
		
		If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA03")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma03,"_TOMA")) <> "U"
			
			If AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "3"
				lDesTrFil := .T. // Destinatario da nota no processo de transferencia entre filiais
				If AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) != AllTrim(cCNPJ_CPF)
					lRet := .F.
				EndIf
			ElseIf AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "0"
				
				If !lRemet
					lRet := .F.
				EndIf
				
			ElseIf AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "1"
				
				lOutTom := .T.
				
				If !lExped
					lRet := .F.
				EndIf
				
			EndIf
			
		ElseIf ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA3")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma3,"_TOMA")) <> "U"
			
			If AllTrim(oXML:_InfCte:_Ide:_Toma3:_TOMA:Text) == "3"
				lDesTrFil := .T. // Destinatario da nota no processo de transferencia entre filiais
				If AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) != AllTrim(cCNPJ_CPF)
					lRet := .F.
				EndIf
			ElseIf AllTrim(oXML:_InfCte:_Ide:_Toma3:_TOMA:Text) == "0"
				
				If !lRemet
					lRet := .F.
				EndIf
				
			ElseIf AllTrim(oXML:_InfCte:_Ide:_Toma3:_TOMA:Text) == "1"
				
				If !lExped
					lRet := .F.
				EndIf
				
			EndIf
			
		ElseIf ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA4")) == "O"
			
			cTagTom := If(ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4, "_CNPJ")) == "O", "_CNPJ", "_CPF")
			
			If AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagTom):Text) != AllTrim(cCNPJ_CPF)
				
				lRet := .F.
				
			Else
				
				lOutTom := .T.
				lRet := .T.
				
			EndIf
			
		EndIf
		
	EndIf

Return lRet

Static Function CBoxInfo(cNmFld, cValue, nInfoType)

	Local cAux

	Default nInfoType := 2

	cAux := StrTokArr(Posicione("SX3", 2, cNmFld, "X3_CBOX"), ';')[Val(cValue)]

Return If(!Empty(cAux), StrTokArr(cAux, "=")[nInfoType], "")

////////////////////////////////////////

Static Function RetoFili(cRem, cDest)

	Local aFilial  := {}
	Local aFiliais := {}
	Local nI
	
	aFiliais := FWAllFilial(, , SM0->M0_CODIGO, .F.)
	
	For nI := 1 To Len(aFiliais)
	
		aFilial := FWArrFilAtu(SM0->M0_CODIGO, aFiliais[nI])
	
		If AllTrim(aFilial[18]) == AllTrim(cRem)
			
			lFilRem := .T.
			
			cFilRem := aFiliais[nI]
			
		ElseIf AllTrim(aFilial[18]) == AllTrim(cDest)
			
			lFilDest := .T.
			
			cFilDest := aFiliais[nI]
			
		EndIf
	
		aFilial := {}
		
	Next nI
	
	cFilRem  := IIf(Empty(cFilRem), xFilial("SF2"), cFilRem)
	cFilDest := IIf(Empty(cFilDest), xFilial("SF1"), cFilDest)
	
Return

Static Function AllEmit(cAli, cCodLoj)
	
	Local aRet     := {}
	Local aAreaAli := (cAli)->( GetArea() )
	Local cCGC     := ""
	Local cCmp     := SubStr(cAli, 2, 2)
	
	dbSelectArea(cAli)
	(cAli)->( dbSetOrder(1) )
	If (cAli)->( dbSeek(xFilial(cAli) + cCodLoj) )
		
		cCGC := (cAli)->&(cCmp + "_CGC")
		
	EndIf
	
	dbSelectArea(cAli)
	(cAli)->( dbSetOrder(3) )
	
	If (cAli)->( dbSeek(xFilial(cAli) + cCGC) )
		
		While !(cAli)->( Eof() ) .And. (cAli)->&(cCmp + "_FILIAL") == xFilial(cAli) .And. (cAli)->&(cCmp + "_CGC") == cCGC
			
			If (cAli)->&(cCmp + "_MSBLQL") # "1"
				
				AAdd(aRet, {(cAli)->&(cCmp + "_COD"), (cAli)->&(cCmp + "_LOJA")})
				
			EndIf
			
			(cAli)->( dbSkip() )
			
		EndDo
		
	EndIf
	
	RestArea(aAreaAli)
	
Return aRet
