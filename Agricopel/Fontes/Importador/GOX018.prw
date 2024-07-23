#INCLUDE "PROTHEUS.CH"

Static aProv := {;
		{"BETHA", "01"}, ;
		{"PRONIM", "02"}, ;
		{"NOTABLU", "03"}, ;
		{"IPM", "04"}, ;
		{"SP", "05"}, ;
		{"PUBLICA", "06"}, ;
		{"THEMA", "07"}, ;
		{"CIGA", "08"}, ;
		{"BHISS", "09"}, ;
		{"SIMPLISS", "10"}, ;
		{"BETHAV2", "11"}, ;
		{"WEBISSV2", "12"}, ;
		{"RECIFE", "13"}, ;
		{"TIPLAN", "14"}, ;
		{"SIMPLISSV2", "15"}, ;
		{"RJ", "16"}, ;
		{"BLUV1", "17"}, ; // Layout antigo de Blumenau, rever quando o BRPROJ enviar
		{"CUSTOMJOINVILLE", "18"}, ;// Customizado de Joinville
		{"ISSE", "19"}, ;// Customizado de Joinville
		{"ISSCURITIBA", "20"}, ;// Curitiba
		{"CUSTOMFLORIANOPOLIS", "21"}, ;// Floripa
		{"CUSTOMDSF", "22"}, ;// DSF
		{"WEBISS", "23"}, ;// DSF
		{"CUSTOMTHEMA", "24"} ;// DSF
	}

// Programa para unificar as informações e tratamentos da Nota fiscal de serviço

User Function GOX18NFS(oXml, cProvedor)
	
	Local aRet := {}
	Local nI
	Local nAux
	
	// Campos lidos do XML
	Local cNumero  := ""
	Local cSerie   := ""
	Local dDtEmi   := ""
	Local cHrEmi   := ""
	Local cEstMun  := ""
	
	// Valores
	Local nValServ := 0
	Local nValPIS  := 0
	Local nValCOF  := 0
	Local nValIR   := 0
	Local nValCSLL := 0
	
	Local nValISS  := 0
	Local nAliqISS := 0
	Local nValBase := 0
	
	Local nValDesc := 0
	
	Local nValLiq  := 0
	//////////////////////
	
	// Prestador 
	
	Local cCgcPrest  := ""
	Local cIBGEPrest := ""
	
	// Tomador
	
	Local cCgcTom := ""
	Local cIBGETom := ""
	
	// Itens do XML
	Local aItens := {}
	Local aAux
	// ======> Cçdigo Serviço
	// ======> Descriçõo
	// ======> Quantidade
	// ======> Valor Unitçrio
	// ======> Total
	// ======> Desconto
	// ======> Aliquota
	
	// Parcelas Pagamento
	Local aPag := {}
	// ======> Parcela
	// ======> Data ???
	// ======> Valor
	
	Local lRelac := .T.

	Begin Sequence

		If IsInCallStack("U_GOX1MAN") .And. (ValType(GetNodeNFS(oXml, cProvedor, "",, @lRelac)) # "O" .Or. !lRelac)

			Break

		EndIf

		If cProvedor == "BETHA"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_Numero:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItBetha2Ar(GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), oXml, cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento
			
			
			
		ElseIf cProvedor == "PRONIM"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)
				
				nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValoresNfse:_ValorLiquidoNfse:Text", "0"))
				
			EndIf
			
			// Itens
			
			aAux := ItProni2Ar(GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""))
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				//nAux := Val(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + Val(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
	//				Val(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", 0})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento
			
		ElseIf cProvedor == "NOTABLU"
			
			cSerie  := "" // Ok
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", "")) // OK

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi) // OK
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8) // OK
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", "")) // OK
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")) //OK
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)
				
				nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValoresNfse:_ValorLiquidoNfse:Text", "0"))
				
			EndIf
			
			If Empty(nValLiq)
				
				nValLiq := nValServ
				
			EndIf
			
			// Itens
			
			aAux := ItNBlu2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				//nAux := Val(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + Val(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
	//				Val(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", 0})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
			
			If Empty(cCgcPrest)

				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_Prestador:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Prestador:_IdentificacaoPrestador:_Cpf:Text", "")

			EndIf

			If Empty(cCgcPrest)

				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_Prestador:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_Prestador:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")

			EndIf

			cCgcPrest := StrTran(cCgcPrest, "-", "")
			cCgcPrest := StrTran(cCgcPrest, ".", "")
			cCgcPrest := StrTran(cCgcPrest, "/", "")
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
			
			cCgcTom := StrTran(cCgcTom, "-", "")
			cCgcTom := StrTran(cCgcTom, ".", "")
			cCgcTom := StrTran(cCgcTom, "/", "")
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento
			
		ElseIf cProvedor == "IPM"
			
			cSerie  := ""//GetNodeNFS(oXml, cProvedor, "_nf:_serie_nfse:Text", "")
			
			dDtEmi  := CToD(GetNodeNFS(oXml, cProvedor, "_nf:_data_nfse:Text", ""))
			
			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_nf:_numero_nfse:Text", ""), dDtEmi)

			cHrEmi  := GetNodeNFS(oXml, cProvedor, "_nf:_hora_nfse:Text", "")
			
			cEstMun := ""
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_nf:_valor_total:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_nf:_valor_pis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_nf:_valor_cofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_nf:_valor_ir:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_nf:_valor_contribuicao_social:Text", "0"))
			
			nValISS  := 0
			nAliqISS := 0
			nValBase := 0
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_nf:_valor_desconto:Text", "0"))
			
			nValLiq  := nValServ
			
			// Itens
			
			aAux := ItIpm2Ar(oXml, cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				//nAux := Val(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + Val(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
	//				Val(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", 0})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_prestador:_cpfcnpj:Text", "")
			
			If Len(cCgcPrest) <= 11
				
				cCgcPrest := PadL(cCgcPrest, 11, "0")
				
			Else
				
				cCgcPrest := PadL(cCgcPrest, 14, "0")
				
			EndIf
				
			cIBGEPrest := ""
			
			// Tomador
			
			cCgcTom  := PadL(GetNodeNFS(oXml, cProvedor, "_tomador:_cpfcnpj:Text", ""), 14, "0")
				
			cIBGETom := ""
			
			// Pagamento
			
		ElseIf cProvedor == "SP"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissaoNFe:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_ChaveNFe:_NumeroNFe:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissaoNFe:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_EnderecoPrestador:_Cidade:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorPIS:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorCOFINS:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorIR:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorCSLL:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorISS:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_AliquotaServicos:Text", "0"))
			nValBase := nValServ
			
			nValDesc := 0
			
			nValLiq  := nValServ
			
			// Itens
			
			aAux := ItSP2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				//nAux := Val(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + Val(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
	//				Val(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", 0})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_CPFCNPJPrestador:_CNPJ:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_CPFCNPJPrestador:_CPF:Text", "")
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_EnderecoPrestador:_Cidade:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_CPFCNPJTomador:_CNPJ:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_CPFCNPJTomador:_CPF:Text", "")
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_EnderecoTomador:_Cidade:Text", ""))
			
			// Pagamento
			
		ElseIf cProvedor == "PUBLICA"
			
			cSerie  := "" // Ok
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", "")) // OK

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi) // OK
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8) // OK
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", "")) // OK
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")) //OK
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)
				
				nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValoresNfse:_ValorLiquidoNfse:Text", "0"))
				
			EndIf
			
			If Empty(nValLiq)
				
				nValLiq := nValServ
				
			EndIf
			
			// Itens
			
			aAux := ItPub2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				//nAux := Val(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + Val(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
	//				Val(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", 0})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cCgcPrest := StrTran(cCgcPrest, "-", "")
			cCgcPrest := StrTran(cCgcPrest, ".", "")
			cCgcPrest := StrTran(cCgcPrest, "/", "")
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
			
			cCgcTom := StrTran(cCgcTom, "-", "")
			cCgcTom := StrTran(cCgcTom, ".", "")
			cCgcTom := StrTran(cCgcTom, "/", "")
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento
			
		ElseIf cProvedor == "BETHAV2"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_Numero:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItBetha2Ar(GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), oXml, cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "THEMA"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_Numero:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "CIGA"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento
			
		ElseIf cProvedor == "BHISS"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "SIMPLISS"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "SIMPLISSV2"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf

			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_Prestador:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_Prestador:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "WEBISSV2"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "RECIFE"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "TIPLAN"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItTiplan2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "RJ"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItTiplan2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento

		ElseIf cProvedor == "BLUV1"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DT_COMPETENCIA:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := ""//SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_ES_MUNICIPIO:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_SERVICO:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_PIS:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_COFINS:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_IR:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_CSLL:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_ISS:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_ALIQUOTA:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_BASE_CALCULO:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_DEDUCAO:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_VL_DESCONTO_CONDICIONADO:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_VL_DESCONTO_INCONDICIONADO:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_VL_LIQUIDO_NFSE:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItBluV12Ar(oXml, GetNodeNFS(oXml, cProvedor, "_DISCRIMINACAO:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_CNPJ:Text", "")
				
			/*If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf*/
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PRE_ENDERECO_ES_MUNICIPIO:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TOM_CPF_CNPJ:Text", "")
				
			/*If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf*/
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TOM_ENDERECO_ES_MUNICIPIO:Text", ""))
			
			/*If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf*/
			
			// Pagamento

		ElseIf cProvedor == "CUSTOMJOINVILLE"

			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(GetNodeNFS(oXml, cProvedor, "_NOTA:_DATA_EMISSAO:Text", ""), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NOTA:_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := ""//SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := ""//AllTrim(GetNodeNFS(oXml, cProvedor, "_ES_MUNICIPIO:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_TOTAL:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_PIS:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_COFINS:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_IRRF:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_CSLL:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_ISS:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_ALIQUOTA_ISS:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_BASE_CALCULO:Text", "0"))
			
			nValDesc := 0
			nValDesc += 0
			nValDesc += 0
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_TOTAL:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItCuJoi2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_NOTA:_DESCRICAO_SERVICOS:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PRESTADOR:_DOCUMENTO:Text", "")
				
			/*If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf*/
				
			cIBGEPrest := ""//AllTrim(GetNodeNFS(oXml, cProvedor, "_PRE_ENDERECO_ES_MUNICIPIO:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_NOTA:_TOMADOR:_DOCUMENTO:Text", "")
				
			/*If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf*/
				
			cIBGETom := ""//AllTrim(GetNodeNFS(oXml, cProvedor, "_TOM_ENDERECO_ES_MUNICIPIO:Text", ""))

		ElseIf cProvedor == "ISSE"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_Numero:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItIsse2Ar(GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), oXml, cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
			// Pagamento
			
		ElseIf cProvedor == "ISSCURITIBA"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
		ElseIf cProvedor == "CUSTOMFLORIANOPOLIS"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_numeroSerie:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_inscricaoMunicipalPrestador:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_valorTotalServicos:Text", "0"))
			nValPIS  := 0//MyVal(GetNodeNFS(oXml, cProvedor, "_valorPis:Text", "0"))
			nValCOF  := 0//MyVal(GetNodeNFS(oXml, cProvedor, "_ValorCOFINS:Text", "0"))
			nValIR   := 0//MyVal(GetNodeNFS(oXml, cProvedor, "_ValorIR:Text", "0"))
			nValCSLL := 0//MyVal(GetNodeNFS(oXml, cProvedor, "_ValorCSLL:Text", "0"))
			
			nValISS  := 0//MyVal(GetNodeNFS(oXml, cProvedor, "_ValorISS:Text", "0"))
			nAliqISS := 0//MyVal(GetNodeNFS(oXml, cProvedor, "_AliquotaServicos:Text", "0"))
			nValBase := nValServ
			
			nValDesc := 0
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_valorTotalServicos:Text", "0"))
			
			// Itens
			
			aAux := ItCF2Ar(oXml, cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				//nAux := Val(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + Val(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
				//Val(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", 0})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_cnpjPrestador:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_cpfPrestador:Text", "")
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_inscricaoMunicipalPrestador:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_identificacaoTomador:Text", "")
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_codigoMunicipioTomador:Text", ""))
			
		ElseIf cProvedor == "CUSTOMDSF"
			
			
			
		ElseIf cProvedor == "WEBISS"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NUMERO:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_Servico:_CodigoMunicipio:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCofins:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIr:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorCsll:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorIss:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_Aliquota:Text", "0"))
			nValBase := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_BaseCalculo:Text", "0"))
			
			nValDesc := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorDeducoes:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoCondicionado:Text", "0"))
			nValDesc += MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_DescontoIncondicionado:Text", "0"))
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorLiquidoNfse:Text", "0"))
			
			If Empty(nValLiq)

				nValLiq := nValServ
				
			EndIf

			// Itens
			
			aAux := ItThema2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				nAux := MyVal(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + MyVal(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
					MyVal(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", nAux})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text", "")
				
			If Empty(cCgcPrest)
				
				cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text", "") + ;
					GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_PrestadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			If Empty(cCgcTom)
				
				cCgcTom  := GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text", "") + ;
				GetNodeNFS(oXml, cProvedor, "_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text", "")
				
			EndIf
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_TomadorServico:_Endereco:_CodigoMunicipio:Text", ""))
			
			If Empty(cIBGETom)
				
				cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_Tomador:_Endereco:_CodigoMunicipio:Text", ""))
				
			EndIf
			
		ElseIf cProvedor == "CUSTOMTHEMA"
			
			cSerie  := ""
			
			dDtEmi  := SToD(StrTran(Left(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", "          "), 10), "-", ""))

			cNumero := TrataNumNf(GetNodeNFS(oXml, cProvedor, "_NumeroNota:Text", ""), dDtEmi)
			
			cHrEmi  := SubStr(GetNodeNFS(oXml, cProvedor, "_DataEmissao:Text", ""), 12, 8)
			
			cEstMun := AllTrim(GetNodeNFS(oXml, cProvedor, "_cidadePrestador:Text", ""))
			
			nValServ := MyVal(GetNodeNFS(oXml, cProvedor, "_valorBruto:Text", "0"))
			nValPIS  := MyVal(GetNodeNFS(oXml, cProvedor, "_valorPis:Text", "0"))
			nValCOF  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorCOFINS:Text", "0"))
			nValIR   := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorIR:Text", "0"))
			nValCSLL := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorCSLL:Text", "0"))
			
			nValISS  := MyVal(GetNodeNFS(oXml, cProvedor, "_ValorISS:Text", "0"))
			nAliqISS := MyVal(GetNodeNFS(oXml, cProvedor, "_AliquotaServicos:Text", "0"))
			nValBase := nValServ
			
			nValDesc := 0
			
			nValLiq  := MyVal(GetNodeNFS(oXml, cProvedor, "_valorLiquidoNfse:Text", "0"))
			
			// Itens
			
			aAux := ItCt2Ar(oXml, GetNodeNFS(oXml, cProvedor, "_descricaoListaServico:Text", ""), cProvedor)
			
			For nI := 1 To Len(aAux)
				
				AAdd(aItens, {})
				
				AAdd(ATail(aItens), {"QUANT", MyVal(U_GOX18REF(aAux[nI], "QUANTIDADE", "1"))})
				AAdd(ATail(aItens), {"CODIGO", U_GOX18REF(aAux[nI], "ITEMSERVICO", "")})
				AAdd(ATail(aItens), {"DESC", U_GOX18REF(aAux[nI], "DESCRICAO", "")})
				AAdd(ATail(aItens), {"UM", ""}) // ????
				AAdd(ATail(aItens), {"VLUNIT", MyVal(U_GOX18REF(aAux[nI], "VALORUNITARIO", "0"))})
				AAdd(ATail(aItens), {"TOTAL", MyVal(U_GOX18REF(aAux[nI], "VALORSERVICO", "0"))})
				
				//nAux := Val(U_GOX18REF(aAux[nI], "DEDUCOES", "0")) + Val(U_GOX18REF(aAux[nI], "DESCONTOCONDICIONADO", "0")) + ;
	//				Val(U_GOX18REF(aAux[nI], "DESCONTOINCONDICIONADO", "0"))
				
				AAdd(ATail(aItens), {"DESCONTO", 0})
				
				AAdd(ATail(aItens), {"BASEISS", MyVal(U_GOX18REF(aAux[nI], "VALORBASECALCULO", "0"))})
				AAdd(ATail(aItens), {"ALIQISS", MyVal(U_GOX18REF(aAux[nI], "ALIQUOTA", "0"))})
				
			Next nI
			
			// Prestador
			
			cCgcPrest  := GetNodeNFS(oXml, cProvedor, "_CPFCNPJPrestador:Text", "")
				
			cIBGEPrest := AllTrim(GetNodeNFS(oXml, cProvedor, "_cidadePrestador:Text", ""))
			
			// Tomador
			
			cCgcTom  := GetNodeNFS(oXml, cProvedor, "_cpfCnpjTomador:Text", "")
				
			cIBGETom := AllTrim(GetNodeNFS(oXml, cProvedor, "_cidadeTomador:Text", ""))
			
		EndIf
		
	End Sequence

	AAdd(aRet, {"NUMERO", cNumero})
	AAdd(aRet, {"SERIE", cSerie})
	AAdd(aRet, {"EMISSAO", dDtEmi})
	AAdd(aRet, {"HREMIS", cHrEmi})
	AAdd(aRet, {"IBGE", cEstMun})
	
	AAdd(aRet, {"CGCPREST", cCgcPrest})
	AAdd(aRet, {"IBGEPREST", cIBGEPrest})
	
	AAdd(aRet, {"CGCTOMA", cCgcTom})
	AAdd(aRet, {"IBGETOMA", cIBGETom})
	
	AAdd(aRet, {"VALPIS", nValPis})
	AAdd(aRet, {"VALCOF", nValCof})
	AAdd(aRet, {"VALIR", nValIr})
	AAdd(aRet, {"VALCSLL", nValCSLL})
	
	AAdd(aRet, {"VALISS", nValIss})
	AAdd(aRet, {"ALISS", nAliqISS})
	AAdd(aRet, {"BASISS", nValBase})
	
	AAdd(aRet, {"DESCON", nValDesc})
	
	AAdd(aRet, {"TOTAL", nValServ})
	AAdd(aRet, {"LIQUIDO", nValLiq})
	
	AAdd(aRet, {"IBGE", cEstMun})
	
	AAdd(aRet, {"ITENS", aItens})
	
	AAdd(aRet, {"PAGTO", aPag})

	If !Empty(dDtEmi) .And. !Empty(cCgcPrest) .And. !Empty(cNumero)
		AAdd(aRet, {"CHAVE", "00" + PadL(cCgcPrest, 14, "0") + Right(cValToChar(Year(dDtEmi)), 2) + PadL(cValToChar(Month(dDtEmi)), 2, "0") + "99" + PadL(cNumero, 22, "0")})
	Else
		AAdd(aRet, {"CHAVE", ""})
	EndIf
	
Return aRet

User Function GOX18PRV(xProvedor, lRetNum)
	
	Local cRet := ""
	Local nPos
	
	Default lRetNum := .T.
	
	If lRetNum
		
		nPos := AScan(aProv, {|x| x[1] == xProvedor})
		
		If nPos > 0
			
			cRet := aProv[nPos][2] 

		Else
			
			cRet := ""

		EndIf
		
	Else
		
		nPos := AScan(aProv, {|x| x[2] == xProvedor})
		
		If nPos > 0
			
			cRet := aProv[nPos][1]
			
		Else
			
			cRet := ""

		EndIf

	EndIf
	
Return cRet

Static Function GetNodeNFS(oXml, cProvedor, cNode, xDefault, lRelac)
	
	Local xRet   := Nil
	Local aMatch := {}
	Local nM
	
	Default cNode := ""
	Default cProvedor := ""
	
	Private oXmlAux := oXml
	Private oXmlAux2
	
	If !Empty(cProvedor)
		
		If cProvedor == "BETHA" .Or. cProvedor == "BETHAV2"
			
			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ComplNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {":_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico"}
			
		ElseIf cProvedor == "PRONIM"
			
			If Type("oXmlAux:_CompNFSE:_NFSE:_INFNFSE") # "U"
				oXmlAux2 := oXmlAux:_CompNFSE:_NFSE:_INFNFSE
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "NOTABLU"
			
			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "IPM"
			
			If Type("oXmlAux:_nfse") # "U"
				oXmlAux2 := oXmlAux:_nfse
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "SP"
			
			If Type("oXmlAux:_RetornoConsulta:_NFe") # "U"
				oXmlAux2 := oXmlAux:_RetornoConsulta:_NFe
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "PUBLICA"

			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_GerarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_GerarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "THEMA" .Or. cProvedor == "CIGA" .Or. cProvedor == "TIPLAN" .Or. cProvedor == "RJ"
			
			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {}

		ElseIf cProvedor == "BHISS"
			
			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {}

		ElseIf cProvedor == "SIMPLISS" .Or. cProvedor == "SIMPLISSV2"

			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse[1]:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse[1]:_Nfse:_InfNfse
			EndIf
			
			aMatch := {":_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico"}

		ElseIf cProvedor == "WEBISSV2" .Or. cProvedor == "WEBISS"

			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {":_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico"}

		ElseIf cProvedor == "RECIFE"

			If Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseRpsResposta:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseFaixaResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {}

		ElseIf cProvedor == "BLUV1"

			If Type("oXmlAux:_NOTAS:_NOTA") # "U"
				oXmlAux2 := oXmlAux:_NOTAS:_NOTA
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "CUSTOMTHEMA"

			If Type("oXmlAux:_NOTAS:_NOTA") # "U"
				oXmlAux2 := oXmlAux:_NOTAS:_NOTA
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "CUSTOMFLORIANOPOLIS"
			
			If Type("oXmlAux:_xmlNfpse") # "U"
				oXmlAux2 := oXmlAux:_xmlNfpse
			EndIf
			
			aMatch := {}
			
		ElseIf cProvedor == "CUSTOMJOINVILLE"

			If Type("oXmlAux:_LOTE") # "U"
				oXmlAux2 := oXmlAux:_LOTE
			EndIf
			
			aMatch := {}

		ElseIf cProvedor == "ISSE"
			
			If Type("oXmlAux:_ConsultarNfseServicoPrestadoResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseServicoPrestadoResposta:_ListaNfse:_ComplNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseServicoPrestadoResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseServicoPrestadoResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ConsultarNfseServicoPrestadoResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ConsultarNfseServicoPrestadoResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_CompNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_CompNfse:_Nfse:_InfNfse
			ElseIf Type("oXmlAux:_ComplNfse:_Nfse:_InfNfse") # "U"
				oXmlAux2 := oXmlAux:_ComplNfse:_Nfse:_InfNfse
			EndIf
			
			aMatch := {":_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico"}

		EndIf
		
	EndIf
	
	If Empty(oXmlAux2)
		
		lRelac := .F.

		oXmlAux2 := oXmlAux

	EndIf

	If Type("oXmlAux2" + IIf(Empty(cNode), "", ":") + cNode) # "U"
		
		xRet := &("oXmlAux2" + IIf(Empty(cNode), "", ":") + cNode)
		
	ElseIf Len(aMatch) > 0
		
		For nM := 1 To Len(aMatch)
			
			If Type("oXmlAux2" + aMatch[nM] + IIf(Empty(cNode), "", ":") + cNode) # "U"
							
				xRet := &("oXmlAux2" + aMatch[nM] + IIf(Empty(cNode), "", ":") + cNode)
				
				Exit
				
			EndIf
			
		Next nM
		
	EndIf
	
	If Empty(xRet) .And. ValType(xDefault) # "U"
		
		xRet := xDefault
		
	EndIf
	
Return xRet

// Transforma a Discriminaçõo do Serviço Betha para um array de itens

Static Function ItBetha2Ar(cDisc, oXml, cProvedor)
	
	Local aRet := {}
	
	Local aAux := StrTokArr2(cDisc, "]][[")
	Local aAux1
	Local aAux2
	Local cAux
	Local nI
	Local nX

	If At("][", cDisc) == 0

		AAdd(aRet, {})

		AAdd(ATail(aRet), {"QUANTIDADE", "1"})
		AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_ItemListaServico:Text", "1")})
		AAdd(ATail(aRet), {"DESCRICAO", cDisc})
		AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
		AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})

	Else
		
		For nX := 1 To Len(aAux)

			AAdd(aRet, {})

			aAux1 := StrTokArr2(aAux[nX], "][")

			For nI := 1 To Len(aAux1)
				
				cAux := StrTran(aAux1[nI], "[", "")
				cAux := StrTran(cAux, "]", "")
				cAux := StrTran(cAux, "{", "")
				cAux := StrTran(cAux, "}", "")
				
				aAux2 := StrTokArr2(cAux, "=")
				
				AAdd(ATail(aRet), {Upper(aAux2[1]), aAux2[2]})
				
			Next nI

		Next nX

	EndIf
	
	/*Local nTotStr := Len(cDisc)
	Local nI
	Local cChar
	
	Local nStatus := 0 // 0= Sem informaçõo, 1=Array aberto, 2= Item aberto
	
	For nI := 1 To Len(cDisc)
		
		cChar := SubStr(cDisc, nI, 1)
		
		If cChar == "{"
			
			nStatus := 1
			
		ElseIf nStatus == 1 .And. cChar == "["
			
			nStatus := 2
			
			AAdd(aRet, {})
			
		ElseIf nStatus
			
			
			
		EndIf
		
	Next nI*/
	
Return aRet

// Itens vindo do provedor PRONIM

Static Function ItProni2Ar(cDisc)
	
	Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux
	
	For nI := 2 To Len(aAux) // Pula o primeiro que nço ç item
		
		// CODIGO
		cCod := AllTrim(SubStr(aAux[nI], 1, At(" - ", aAux[nI])-1))
		
		///////// DESC
		cAux := SubStr(aAux[nI], At(" - ", aAux[nI])+3)
		
		cDsc := AllTrim(SubStr(cAux, 1, At("(QTD:", aAux[nI])-1))
		
		//////QTDE
		cAux := SubStr(aAux[nI], At("(QTD: ", aAux[nI])+6)
		
		nQtd := MyVal(StrTran(StrTran(SubStr(cAux, At(" ", cAux)-1), ".", ""), ",", ".")) 
		
		//////////// V UNIT
		cAux := SubStr(aAux[nI], At("VL UNIT: ", aAux[nI])+12)
		
		nVUn := MyVal(StrTran(StrTran(SubStr(cAux, 1, At(")", cAux)-1), ".", ""), ",", "."))
		
		//////////// TOTAL
		nTot := Round(nQtd * nVUn, 2)
		
		// Adiciona no Array
		
		If !Empty(cCod) .And. !Empty(cDsc) .And. !Empty(nTot)
			
			AAdd(aRet, {})
			
			AAdd(ATail(aRet), {"QUANTIDADE", cValToChar(nQtd)})
			AAdd(ATail(aRet), {"ITEMSERVICO", cCod})
			AAdd(ATail(aRet), {"DESCRICAO", cDsc})
			AAdd(ATail(aRet), {"VALORUNITARIO", cValToChar(nVUn)})
			AAdd(ATail(aRet), {"VALORSERVICO", cValToChar(nTot)})
			
		EndIf
		
	Next nI
	
Return aRet

// Itens vindo do provedor NOTABLU

Static Function ItNBlu2Ar(oXml, cDisc, cProvedor)
	
	Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux
	
	AAdd(aRet, {})
	
	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", "1"})
	AAdd(ATail(aRet), {"DESCRICAO", "Serviço"})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
	
	/*For nI := 2 To Len(aAux) // Pula o primeiro que nço ç item
		
		// CODIGO
		cCod := AllTrim(SubStr(aAux[nI], 1, At(" - ", aAux[nI])-1))
		
		///////// DESC
		cAux := SubStr(aAux[nI], At(" - ", aAux[nI])+3)
		
		cDsc := AllTrim(SubStr(cAux, 1, At("(QTD:", aAux[nI])-1))
		
		//////QTDE
		cAux := SubStr(aAux[nI], At("(QTD: ", aAux[nI])+6)
		
		nQtd := Val(StrTran(StrTran(SubStr(cAux, At(" ", cAux)-1), ".", ""), ",", ".")) 
		
		//////////// V UNIT
		cAux := SubStr(aAux[nI], At("VL UNIT: ", aAux[nI])+12)
		
		nVUn := Val(StrTran(StrTran(SubStr(cAux, 1, At(")", cAux)-1), ".", ""), ",", "."))
		
		//////////// TOTAL
		nTot := Round(nQtd * nVUn, 2)
		
		// Adiciona no Array
		
		If !Empty(cCod) .And. !Empty(cDsc) .And. !Empty(nTot)
			
			AAdd(aRet, {})
			
			AAdd(ATail(aRet), {"QUANTIDADE", cValToChar(nQtd)})
			AAdd(ATail(aRet), {"ITEMSERVICO", cCod})
			AAdd(ATail(aRet), {"DESCRICAO", cDsc})
			AAdd(ATail(aRet), {"VALORUNITARIO", cValToChar(nVUn)})
			AAdd(ATail(aRet), {"VALORSERVICO", cValToChar(nTot)})
			
		EndIf
		
	Next nI*/
	
Return aRet

Static Function ItBluV12Ar(oXml, cDisc, cProvedor)

	//Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux

	cDsc := StrTran(cDisc, Chr(10), "")
	cDsc := StrTran(cDsc, Chr(13), "")

	If Empty(cDsc)

		cDsc := "Serviço"

	EndIf

	AAdd(aRet, {})

	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(oXml, cProvedor, "_ES_ITEM_LISTA_SERVICO:Text", "1")})
	AAdd(ATail(aRet), {"DESCRICAO", cDsc})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_VL_LIQUIDO_NFSE:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_VL_LIQUIDO_NFSE:Text", "0")})

Return aRet

Static Function ItCuJoi2Ar(oXml, cDisc, cProvedor)

	//Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux

	cDsc := StrTran(cDisc, Chr(10), "")
	cDsc := StrTran(cDsc, Chr(13), "")

	If Empty(cDsc)

		cDsc := "Serviço"

	EndIf

	AAdd(aRet, {})

	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(oXml, cProvedor, "_NOTA:_SERVICO:Text", "1")})
	AAdd(ATail(aRet), {"DESCRICAO", cDsc})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_TOTAL:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_NOTA:_VALOR_TOTAL:Text", "0")})

Return aRet

Static Function ItIsse2Ar(cDisc, oXml, cProvedor)

	//Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux

	cDsc := StrTran(cDisc, Chr(10), "")
	cDsc := StrTran(cDsc, Chr(13), "")

	If Empty(cDsc)

		cDsc := "Serviço"

	EndIf

	AAdd(aRet, {})

	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
		AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_ItemListaServico:Text", "1")})
		AAdd(ATail(aRet), {"DESCRICAO", cDsc})
		AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
		AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})

Return aRet

Static Function ItThema2Ar(oXml, cDisc, cProvedor)

	//Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux
	
	cDsc := GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", "")

	cDsc := StrTran(cDsc, Chr(10), "")
	cDsc := StrTran(cDsc, Chr(13), "")

	AAdd(aRet, {})

	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_ItemListaServico:Text", "1")})
	AAdd(ATail(aRet), {"DESCRICAO", cDsc})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})

Return aRet

Static Function ItTiplan2Ar(oXml, cDisc, cProvedor)

	//Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux
	
	cDsc := GetNodeNFS(oXml, cProvedor, "_Servico:_Discriminacao:Text", "")

	cDsc := StrTran(cDsc, Chr(10), "")
	cDsc := StrTran(cDsc, Chr(13), "")

	AAdd(aRet, {})

	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_ItemListaServico:Text", "1")})
	AAdd(ATail(aRet), {"DESCRICAO", cDsc})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})

Return aRet

// Itens vindo do provedor PUBLICA

Static Function ItPub2Ar(oXml, cDisc, cProvedor)
	
	Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux
	
	AAdd(aRet, {})
	
	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", "1"})
	AAdd(ATail(aRet), {"DESCRICAO", "Serviço"})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_Servico:_Valores:_ValorServicos:Text", "0")})
	
	/*For nI := 2 To Len(aAux) // Pula o primeiro que nço ç item
		
		// CODIGO
		cCod := AllTrim(SubStr(aAux[nI], 1, At(" - ", aAux[nI])-1))
		
		///////// DESC
		cAux := SubStr(aAux[nI], At(" - ", aAux[nI])+3)
		
		cDsc := AllTrim(SubStr(cAux, 1, At("(QTD:", aAux[nI])-1))
		
		//////QTDE
		cAux := SubStr(aAux[nI], At("(QTD: ", aAux[nI])+6)
		
		nQtd := Val(StrTran(StrTran(SubStr(cAux, At(" ", cAux)-1), ".", ""), ",", ".")) 
		
		//////////// V UNIT
		cAux := SubStr(aAux[nI], At("VL UNIT: ", aAux[nI])+12)
		
		nVUn := Val(StrTran(StrTran(SubStr(cAux, 1, At(")", cAux)-1), ".", ""), ",", "."))
		
		//////////// TOTAL
		nTot := Round(nQtd * nVUn, 2)
		
		// Adiciona no Array
		
		If !Empty(cCod) .And. !Empty(cDsc) .And. !Empty(nTot)
			
			AAdd(aRet, {})
			
			AAdd(ATail(aRet), {"QUANTIDADE", cValToChar(nQtd)})
			AAdd(ATail(aRet), {"ITEMSERVICO", cCod})
			AAdd(ATail(aRet), {"DESCRICAO", cDsc})
			AAdd(ATail(aRet), {"VALORUNITARIO", cValToChar(nVUn)})
			AAdd(ATail(aRet), {"VALORSERVICO", cValToChar(nTot)})
			
		EndIf
		
	Next nI*/
	
Return aRet

// Itens vindo do provedor IPM

Static Function ItIpm2Ar(oXml, cProvedor)
	
	Local aAux
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	aAux := GetNodeNFS(oXml, cProvedor, "_itens:_lista")
	
	If ValType(aAux) != "A"
		
		aAux := {aAux}
		
	EndIf
	
	For nI := 1 To Len(aAux)
		
		AAdd(aRet, {})
		
		AAdd(ATail(aRet), {"QUANTIDADE", "1"})
		AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(aAux[nI], cProvedor, "_codigo_local_prestacao_servico:Text")})
		AAdd(ATail(aRet), {"DESCRICAO", GetNodeNFS(aAux[nI], cProvedor, "_descritivo:Text")})
		AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(aAux[nI], cProvedor, "_valor_tributavel:Text", "0")})
		AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(aAux[nI], cProvedor, "_valor_tributavel:Text", "0")})
		
	Next nI
	
Return aRet

// Itens vindo do provedor SP

Static Function ItSP2Ar(oXml, cDisc, cProvedor)
	
	Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux
	
	If ValType(aAux) # "A" .Or. Empty(aAux)
		
		aAux := {aAux}
		
	EndIf
	
	AAdd(aRet, {})
	
	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", "1"})
	AAdd(ATail(aRet), {"DESCRICAO", IIf(Empty(aAux[1]), "Serviço", aAux[1])})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_ValorServicos:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_ValorServicos:Text", "0")})
	
	/*For nI := 2 To Len(aAux) // Pula o primeiro que nço ç item
		
		// CODIGO
		cCod := AllTrim(SubStr(aAux[nI], 1, At(" - ", aAux[nI])-1))
		
		///////// DESC
		cAux := SubStr(aAux[nI], At(" - ", aAux[nI])+3)
		
		cDsc := AllTrim(SubStr(cAux, 1, At("(QTD:", aAux[nI])-1))
		
		//////QTDE
		cAux := SubStr(aAux[nI], At("(QTD: ", aAux[nI])+6)
		
		nQtd := Val(StrTran(StrTran(SubStr(cAux, At(" ", cAux)-1), ".", ""), ",", ".")) 
		
		//////////// V UNIT
		cAux := SubStr(aAux[nI], At("VL UNIT: ", aAux[nI])+12)
		
		nVUn := Val(StrTran(StrTran(SubStr(cAux, 1, At(")", cAux)-1), ".", ""), ",", "."))
		
		//////////// TOTAL
		nTot := Round(nQtd * nVUn, 2)
		
		// Adiciona no Array
		
		If !Empty(cCod) .And. !Empty(cDsc) .And. !Empty(nTot)
			
			AAdd(aRet, {})
			
			AAdd(ATail(aRet), {"QUANTIDADE", cValToChar(nQtd)})
			AAdd(ATail(aRet), {"ITEMSERVICO", cCod})
			AAdd(ATail(aRet), {"DESCRICAO", cDsc})
			AAdd(ATail(aRet), {"VALORUNITARIO", cValToChar(nVUn)})
			AAdd(ATail(aRet), {"VALORSERVICO", cValToChar(nTot)})
			
		EndIf
		
	Next nI*/
	
Return aRet

Static Function ItCt2Ar(oXml, cDisc, cProvedor)
	
	Local aAux := StrTokArr(cDisc, CRLF)
	Local aRet := {}
	Local nI
	
	Local cCod
	Local cDsc
	Local nQtd
	Local nVUn
	Local nTot
	
	Local cAux
	
	If ValType(aAux) # "A"
		
		aAux := {aAux}
		
	EndIf
	
	AAdd(aRet, {})
	
	AAdd(ATail(aRet), {"QUANTIDADE", "1"})
	AAdd(ATail(aRet), {"ITEMSERVICO", GetNodeNFS(oXml, cProvedor, "_itemListaServico:Text", "1")})
	AAdd(ATail(aRet), {"DESCRICAO", IIf(Empty(aAux[1]), "Serviço", aAux[1])})
	AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_valorLiquidoNfse:Text", "0")})
	AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_valorLiquidoNfse:Text", "0")})
	
Return aRet

Static Function ItCF2Ar(oXml, cProvedor)
	
	Local aRet := {}
	
	Local aItens
	Local nI
	
	aItens := GetNodeNFS(oXml, cProvedor, "_itensServico:_itemServico", {})
	
	If ValType(aItens) != "A"
		
		aItens := {aItens}
		
	EndIf
	
	For nI := 1 To Len(aItens)
	
		AAdd(aRet, {})
		
		/*AAdd(ATail(aRet), {"QUANTIDADE", GetNodeNFS(oXml, cProvedor, "_itensServico:_itemServico:_quantidade:Text", "0")})
		AAdd(ATail(aRet), {"ITEMSERVICO", "1"})
		AAdd(ATail(aRet), {"DESCRICAO", GetNodeNFS(oXml, cProvedor, "_itensServico:_itemServico:_descricaoServico:Text", "0")})
		AAdd(ATail(aRet), {"VALORUNITARIO", GetNodeNFS(oXml, cProvedor, "_itensServico:_itemServico:_valorUnitario:Text", "0")})
		AAdd(ATail(aRet), {"VALORSERVICO", GetNodeNFS(oXml, cProvedor, "_itensServico:_itemServico:_valorTotal:Text", "0")})*/
		
		AAdd(ATail(aRet), {"QUANTIDADE", aItens[nI]:_quantidade:Text})
		AAdd(ATail(aRet), {"ITEMSERVICO", cValToChar(nI)})
		AAdd(ATail(aRet), {"DESCRICAO", aItens[nI]:_descricaoServico:Text})
		AAdd(ATail(aRet), {"VALORUNITARIO", aItens[nI]:_valorUnitario:Text})
		AAdd(ATail(aRet), {"VALORSERVICO", aItens[nI]:_valorTotal:Text})
		
	Next nI
	
Return aRet

User Function GOX18REF(aArr, cKey, xDefault)
	
	Local nPos
	Local xRet
	
	Default xDefault := Nil
	
	If Empty(aArr) .Or. ValType(aArr) # "A" .Or. Len(aArr) == 0 .Or. Empty(cKey)
		
		Return xDefault
		
	EndIf
		
	nPos := AScan(aArr, {|x| x[1] == cKey})
	
	If nPos > 0
		
		xRet := aArr[nPos][2]
		
	EndIf
	
	If Empty(xRet) .And. ValType(xDefault) # "U"
		
		xRet := xDefault
		
	EndIf
	
Return xRet

Static Function TrataNumNf(cNumero, dData)

	Local cRet := AllTrim(cNumero)
	Local cAno := cValToChar(Year(dData))
	Local cDireita := cValToChar(Val(Right(cRet, 9)))

	If Left(cRet, 4) == cAno .And. Len(cDireita) <= 5

		cRet := Left(cRet, 4) + Right(cRet, 5)

	ElseIf Len(cRet) > 9

		cRet := Right(cRet, 9)

	EndIf

Return cRet

User Function GOX18GPR()

Return aProv

Static Function MyVal(cVal)

Return Val(StrTran(cVal, ",", "."))
