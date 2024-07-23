#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
/*
ROTINA DE INTEGRAÇÃO COM DBGINT - CLIENTES E FORNECEDORES
*/               
//Cnpj: Cnpj de cadastero no dbgint 
//Tipo: SA1 ou SA2
User Function AGX635CF(xCNPJ,xTipo)

	Local nQtdeRegCF     := 0
	Local cAliasCF       := ""
	//Local oTmpTable		 := Nil
	Local cNewCT1        := ""
	Private  oError := ErrorBlock({|e| GVErrorlog(e)})
    //Local _aarea         := Getarea()   
                                   
    //Gera query do DBGInt
	//Cria arquivo com dados do DBGINT  
	/*oTmpTable := CriarArqCF(xCNPJ)

	cAliasCF := oTmpTable:GetAlias()*/
	cAliasCF := CriarArqCF(xCNPJ)
	If Select(cAliasCF) <> 0
		
		nQtdeRegCF := (cAliasCF)->(RecCount())

		U_AGX635CN("PRT")
		If nQtdeRegCF > 0

			if xTipo == 'SA1'
				cNewCT1 := SA1Inserir(cAliasCF)  
			Endif
			if xTipo == 'SA2'				
				cNewCT1 := SA2Inserir(cAliasCF)               
			Endif

		EndIf

		(cAliasCF)->(DbCloseArea())
	Else
		conout("AGX635CF - Nao foi Possivel selecionar:"+cAliasCF)
	Endif 
	//oTmpTable:Delete()
	//FreeObj(oTmpTable)
    ErrorBlock(oError)  
	//Restarea(_aarea)
Return cNewCT1   


//Busca dados de Cliente/Fornecedor
Static Function SelectCF(xCNPJ)

	Local cAliasCF  := "SelectCF"//GetNextAlias()
	Local cQuery    := ""

	cQuery += " SELECT "

	cQuery += "    TABENT.GEN_TABENT_Codigo AS ENTCOD, " // Código da Entidade (geralmente parte inicial do CNPJ do fornecedor ou cliente quando for pessoa jurídica ou CPF quando for pessoa física - mas pode ser utilizado quando código numérico)
	cQuery += "    TABENT.GEN_TABENT_Razao AS RAZAO, " // Razão Social
	cQuery += "    TABENT.GEN_TABENT_Fantasia AS FANTASIA, " // Nome Fantasia
	cQuery += "    TABENT.GEN_TABENT_TipoPessoa AS TPPESSOA, " // Pessoa Física (F), Jurídica (J) ou Isento (I)
	cQuery += "    TABENT.GEN_TABENT_Cliente AS ISCLIENTE, " // É um CLIENTE ? (0 ou 1)
	cQuery += "    TABENT.GEN_TABENT_Forn AS ISFORNECE, " // É um FORNECEDOR ? (0 ou 1)
	cQuery += "    TABENT.GEN_TABENT_Transp IS_TRANSP, " // É um TRANSPORTADOR ? (0 ou 1)
	//	cQuery += "    TABENT.GEN_TABENT_Rep, " // É um REPRESENTANTE ? (0 ou 1)
	cQuery += "    ENDENT.GEN_ENDENT_Ativo AS ATIVO, " // Registro está Ativo ? (0 ou 1)
	//	cQuery += "    TABENT.GEN_TABENT_Created, " // Data e hora da criação do registro
	//	cQuery += "    TABENT.GEN_TABENT_Updated, " // Data e hora da última alteração do registro
	//	cQuery += "    TABENT.GEN_TABENT_Sequencia, " // ID interno de sequencia para endereços de entidades
	//	cQuery += "    TABENT.GEN_TABENT_TextoVisitante, " // Texto informado ao dar entrada do fornecedor na Portaria (movimentação de visitantes)
	//	cQuery += "    TABENT.GEN_TABENT_Terceiro, " // É um AGREGADO/TERCEIRO ? (0 ou 1)
	//	cQuery += "    TABENT.GEN_TABENT_DHIntTotvs, " // Data e hora da integração da entidade no Protheus (indica se o registro foi inserido ou não no sistema Protheus e quando)
	cQuery += "    ENDENT.GEN_ENDENT_Codigo AS ENDCOD, " // Código do Endereço da Entidade (geralmente o código depois da barra do CNPJ de cada cliente ou fornecedor)
	cQuery += "    ENDENT.GEN_ENDENT_Endereco AS RUA, " // Rua / Logradouro
	cQuery += "    ENDENT.GEN_ENDENT_Bairro AS BAIRRO, " // Bairro
	cQuery += "    ENDENT.GEN_ENDENT_Cep AS CEP, " // CEP
	cQuery += "    ENDENT.GEN_ESTMUN_Estado AS UF, " // Estado
	cQuery += "    ENDENT.GEN_ESTMUN_Municipio AS MUNIC, " // Munícipio
	cQuery += "    ENDENT.GEN_ENDENT_Fone AS FONE, " // Telefone
	cQuery += "    ENDENT.GEN_ENDENT_Fax AS FAX, " // Fax
	cQuery += "    ENDENT.GEN_ENDENT_Celular AS CELULAR, " // Celular
	cQuery += "    ENDENT.GEN_ENDENT_Email AS EMAIL, " // Endereço de E-mail
	cQuery += "    ENDENT.GEN_ENDENT_Contato AS CONTATO, " // Nome do Contato Principal
	cQuery += "    ENDENT.GEN_ENDENT_IF AS CNPJ_CPF, " // CNPJ ou CPF
	cQuery += "    ENDENT.GEN_ENDENT_IE AS INSCR_EST, " // Inscrição Estadual
	cQuery += "    ENDENT.GEN_ENDENT_IM AS INSCR_MUN, " // Inscrição Municipal
	cQuery += "    ENDENT.GEN_ENDENT_DataNasc AS DTNASC, " // Data de Nascimento da Pessoa Física ou Data da Fundação da Empresa
	//	cQuery += "    ENDENT.GEN_ENDENT_Created, " // Data e hora da criação do registro
	//	cQuery += "    ENDENT.GEN_ENDENT_Updated, " // Data e hora da última alteração do registro
	cQuery += "    ENDENT.GEN_ENDENT_Numero AS NUMERO, " // Número do endereço
	cQuery += "    ENDENT.GEN_ENDENT_Complemento AS COMPLEM, " // Complemento do endereço
	//	cQuery += "    ENDENT.GEN_ENDENT_NumLicFed, " // Número da Licença Federal - campo não utilizado
	//	cQuery += "    ENDENT.GEN_ENDENT_ValLicFed, " // Validade da Licença Federal - campo não utilizado
	//	cQuery += "    ENDENT.GEN_ENDENT_NumLicExe, " // Número da Licença do Exército - campo não utilizado
	//	cQuery += "    ENDENT.GEN_ENDENT_ValLicExe, " // Validade da Licença do Exército - campo não utilizado
	cQuery += "    ENDENT.GEN_ENDENT_EMailNFe AS EMAILNFE, " // Endereço de e-mail para envio de DANFE da Nfe
	cQuery += "    ENDENT.GEN_ENDENT_Ativo AS ATIVO, " // Endereço está ATIVO ? (0 ou 1)
	//	cQuery += "    ENDENT.GEN_ENDENT_ContribICMS AS CONTR_ICMS, " // Entidade é Contribuinte do ICMS ? (0 ou 1)
	cQuery += "    ENDENT.GEN_TABPAI_Codigo AS CDPAIS, " // Código da Tabela de Países (tabela do SISCOMEX com códigos de todos os países - 01058 é o código do Brasil)
	cQuery += "    ENDENT.GEN_ENDENT_Obs AS OBSERVACAO, " // Observações
	//	cQuery += "    ENDENT.GEN_ENDENT_RefCom, " // Referências Comerciais
	//	cQuery += "    ENDENT.GEN_ENDENT_RefBanc, " // Referências Bancárias
	//	cQuery += "    ENDENT.GEN_ENDENT_AtivoSite, " // Endereço utiliza SITE DE COTAÇÕES ? (0 ou 1)
	//	cQuery += "    ENDENT.GEN_ENDENT_CategoriasSite, " // Categoria de Produtos que a entidade oferece e cota
	//	cQuery += "    ENDENT.GEN_ENDENT_SenhaSite, " // Senha do site de cotações
	//	cQuery += "    ENDENT.GEN_ENDENT_EmailsSite, " // E-mail do site de cotações
	//	cQuery += "    ENDENT.GEN_ENDENT_ChaveSenhaSite, " // Chave para requisitar nova senha no site de cotações
	//	cQuery += "    ENDENT.GEN_ENDENT_Celular2, " // Celular Adicional
	cQuery += "    ENDENT.GEN_ENDENT_SituacaoFiscal AS SITFISCAL, " // Situação Fiscal da Entidade (0-Contribuinte de ICMS, 1-Contribuinte Isento, 2-Não Contribuinte)
	//	cQuery += "    ENDENT.GEN_ENDENT_DHIntTotvs " // Data e hora da integração no Protheus (indica se o registro foi inserido ou não no sistema Protheus e quando)

	cQuery += "    ESTMUN.GEN_ESTMUN_Estado AS UF, " // Estado
	cQuery += "    ESTMUN.GEN_ESTMUN_Municipio AS MUNIC, " // Munícipio
	cQuery += "    CAST(ESTMUN.GEN_ESTMUN_CodIBGE AS CHAR(10)) AS IBGE " // Código IBGE

	cQuery += " FROM GEN_TABENT TABENT, GEN_ENDENT ENDENT, GEN_ESTMUN ESTMUN "
	cQuery += " WHERE TABENT.GEN_TABENT_Codigo = ENDENT.GEN_TABENT_Codigo "
   //	cQuery += " AND   (GEN_ENDENT_DHIntTotvs IS NULL OR GEN_TABENT_DHIntTotvs IS NULL) "

	cQuery += " AND   ENDENT.GEN_ESTMUN_Estado = ESTMUN.GEN_ESTMUN_Estado "
	cQuery += " AND   ENDENT.GEN_ESTMUN_Municipio = ESTMUN.GEN_ESTMUN_Municipio "

	//cQuery += " AND   (TABENT.GEN_TABENT_Cliente = 0 OR TABENT.GEN_TABENT_Forn = 0) " 
	
	// Definido junto Vanderleia e Thaiara para nao criar lixo no protheus 
	// Todos fornecedores estarão como inativo do GBGInt e somente serão 
	// ativados quando tiverem uma nota
	//cQuery += " AND ENDENT.GEN_ENDENT_Ativo = 1 "  
	cQuery += " AND ENDENT.GEN_ENDENT_IF = '"+xCNPJ+"' "

	cQuery += " ORDER BY TABENT.GEN_TABENT_Codigo, ENDENT.GEN_ENDENT_Codigo "

	//cQuery += " Limit 500 "
    
	//conout(cQuery)
	U_AGX635CN("DBG")

	TCQuery cQuery NEW ALIAS (cAliasCF)

Return(cAliasCF)  
          

//Cria arquivo de dados
Static Function CriarArqCF(xCNPJ)

	Local aStruTmp     := {}
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0
	//Local oTmpTable    := Nil

	cAliasQry := SelectCF(xCNPJ)

	aStruTmp := (cAliasQry)->(DbStruct())

	For nX := 1 To Len(aStruTmp)
		If (aStruTmp[nX][2] == "N" .And. aStruTmp[nX][3] == 15)
			aStruTmp[nX][4] := 0
		EndIf
	Next nX

	/*oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aStruTmp)
	oTmpTable:AddIndex("1", {aStruTmp[1][1]})
	oTmpTable:Create()*/

	cAliasArea := "CriarArqCF"//GetNextAlias()
	cArquivo := CriaTrab(,.F.)
	dbCreate(cArquivo,aStruTmp)
	dbUseArea(.T.,__LocalDriver,cArquivo,cAliasArea,.F.,.F.)
	//cAliasArea := oTmpTable:GetAlias()

	nFieldCount := (cAliasArea)->(FCount())

	While !(cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		For nX := 1 To nFieldCount
			cFieldName := (cAliasArea)->(FieldName(nX))
			(cAliasArea)->&(cFieldName) := (cAliasQry)->&(cFieldName)
		Next nX

		MsUnlock((cAliasArea))
		(cAliasQry)->(DbSkip())
	End


Return(cAliasArea) 


//Insere dados do Cliente
Static Function SA1Inserir(cAliasCli)

	Local lNovoCli    := .F.
	Local cCodNovo    := ""
	Local cLojaNovo   := ""
	Local cTpPessoa   := ""
	Local cCGCBase    := ""
	Local aUltCdLj    := {}  
	Local nTamFone    := 0
	Local cCategoria  := ""   
	private _CCONTA   := ""	

	(cAliasCli)->(DbGoTop())
	While (!(cAliasCli)->(Eof()))

		If (CGC((cAliasCli)->(CNPJ_CPF))) // Validação de CPF/CNPJ

			Conout("-----------------")   
			Conout("Clientes")
			Conout("Empresa Logada: " + cEmpAnt + "-" + cFilAnt)
			Conout("CNPJ Cli: " + (cAliasCli)->(CNPJ_CPF))
			Conout("Razao Cli: " + (cAliasCli)->(RAZAO))
			Conout("Tipo Cli: " + IIf((cAliasCli)->(TPPESSOA) == "F", "F", "J"))

			SA1->(DbSetOrder(3))
			SA1->(DbGoTop())
			lNovoCli  := !SA1->(DbSeek(xFilial("SA1")+(cAliasCli)->(CNPJ_CPF)))
			
	   		If (lNovoCli)

	 			cTpPessoa := IIf((cAliasCli)->(TPPESSOA) == "F", "F", "J")

   				If (cTpPessoa == "F")
   					cCodNovo   := SA1NovoCod()
	 				cLojaNovo  := "01"
				Else
					cCGCBase := SubStr((cAliasCli)->(CNPJ_CPF), 1, 8)
					aUltCdLj := SA1UltLoja(cCGCBase)
       	
					If (Len(aUltCdLj) == 2)
						cCodNovo   := aUltCdLj[1]
						cLojaNovo  := aUltCdLj[2]
   					Else
						cCodNovo   := SA1NovoCod()
   						cLojaNovo  := "01"
			   		EndIf
		   		EndIf  
		   	Else
		   	 	cCodNovo   := SA1->A1_COD
	 			cLojaNovo  := SA1->A1_LOJA
     		Endif    
     	   
     		//Cria uma conta nova somente se for a primeira Loja	 
     		If cLojaNovo == '01'
     	  		_cConta := U_X635CONT(alltrim(NoAcento(AnsiToOem((cAliasCli)->(FANTASIA)))),"SA1")  
     		Else
     		   	//Localiza Conta no Cadastro de Clientes
     		   	_cConta := U_X635A1CO(cCodNovo,cLojaNovo,'SA1') 
     		   	If Alltrim(_cConta) == ""
     		   		_cConta := U_X635CONT(alltrim(NoAcento(AnsiToOem((cAliasCli)->(FANTASIA)))),"SA1")
     		   	Endif 
     		Endif
			
			//Se for isento preencher com  CNF, senão CFC
			If alltrim((cAliasCli)->(INSCR_EST)) == '' .or. alltrim((cAliasCli)->(INSCR_EST)) == 'ISENTO'
				cCategoria := "CNF" 
			Else
				cCategoria := "CFC"
			Endif 
     		
     		// Caso o cadastro já exista no protheus, só altera se ele foi incluido
     		// Via integração do DBGInt
     		If alltrim(_cConta) <> '' .or. ( ('AGX635' $ SA1->A1_OBSERV .and. !lNovoCli) .or. lNovoCli )
				RecLock("SA1", lNovoCli)

				SA1->A1_COD     := cCodNovo
				SA1->A1_LOJA    := cLojaNovo
				SA1->A1_FILIAL  := xFilial("SA1")
				SA1->A1_CGC     := (cAliasCli)->(CNPJ_CPF)
				SA1->A1_NOME    := NoAcento(AnsiToOem((cAliasCli)->(RAZAO)))
				SA1->A1_NREDUZ  := NoAcento(AnsiToOem((cAliasCli)->(FANTASIA)))
				SA1->A1_INSCR   := (cAliasCli)->(INSCR_EST)
	
				SA1->A1_END     := (cAliasCli)->(RUA)
				If !Empty((cAliasCli)->(NUMERO))
					SA1->A1_END += ", " + (cAliasCli)->(NUMERO)
				EndIf
	
				SA1->A1_BAIRRO  := (cAliasCli)->(BAIRRO)
				SA1->A1_EST     := (cAliasCli)->(UF)
				SA1->A1_COD_MUN := SUBSTR( alltrim( (cAliasCli)->(IBGE) ) ,3,5)//(cAliasCli)->(IBGE)
				//SA1->A1_MUN_ANP := SUBSTR( alltrim( (cAliasFor)->(IBGE) ) ,3,5)//(cAliasCli)->(IBGE)
				SA1->A1_MUN     := (cAliasCli)->(MUNIC)
				SA1->A1_CEP     :=  StrTran((cAliasCli)->(CEP),"-","")
				SA1->A1_CODPAIS := (cAliasCli)->(CDPAIS)
				SA1->A1_PABCB   := (cAliasCli)->(CDPAIS) //criado Emp 50
				SA1->A1_ESTE    := (cAliasCli)->(UF) 
				
				//Tratamento para quando informado DDD
				nTamFone := Len(alltrim((cAliasCli)->(FONE)))
				if nTamFone > 9
			   		SA1->A1_TEL     := substr (alltrim( (cAliasCli)->(FONE)), nTamFone-9,nTamFone)
			   		SA1->A1_DDD     := substr( alltrim((cAliasCli)->(FONE)) ,2,2)
				else 
			   		SA1->A1_TEL     := ALLTRIM((cAliasCli)->(FONE))    
			 	endif    
			 	
				SA1->A1_CONTATO := (cAliasCli)->(CONTATO)
				SA1->A1_EMAIL   := (cAliasCli)->(EMAIL)
				SA1->A1_VEND    := ""
				SA1->A1_LC      := 0
	
				SA1->A1_DTINCL  := Date() //CRIAR
				SA1->A1_DTCAD   := Date()
	
				If (cTpPessoa == "F") // Pessoa Física
					SA1->A1_TIPO    := "F" // L - Produtor Rural; F - Cons.Final; R - Revendedor; S - ICMS Solidário sem IPI na base; X - Exportação.
				Else
					SA1->A1_TIPO    := "R" // L - Produtor Rural; F - Cons.Final; R - Revendedor; S - ICMS Solidário sem IPI na base; X - Exportação.
				EndIf
	
				SA1->A1_PESSOA  := cTpPessoa
				SA1->A1_SITUACA := "1"   //criado Emp 50
				SA1->A1_MSBLQL  := "2"
				//SA1->A1_BLOQ    := "T" // Campo utilizado para Exportar para BLink(Agricopel Atacado)
				SA1->A1_POSTOAG := "2"  //criado Emp 50
				SA1->A1_GRPVEN  := "000001"
				SA1->A1_MAXDESC := 0.01     //criado Emp 50
				SA1->A1_TRANSP  := "000001" 
				SA1->A1_CONTA   := _cConta
				SA1->A1_TPFRET  := "C"
				SA1->A1_GRPTRIB :='999'
				SA1->A1_OBS     := ""
				SA1->A1_OBSERV  := "AGX635 - Importação DBGint - Cod: " + cValToChar((cAliasCli)->ENTCOD) + "-" + cValToChar((cAliasCli)->ENDCOD)

				SA1->A1_CATEGOR := cCategoria

				SA1->(MsUnLock())

				If __lSX8
					ConfirmSX8()
				EndIf

			Endif
		EndIf

		(cAliasCli)->(DbSkip())
	End

Return _cConta
            

//Valida ultima Loja 
Static Function SA1UltLoja(cCGCBase)

	Local cQuery    := ""
	Local cAliasQry := "SA1UltLoja"//GetNextAlias()
	Local cLoja     := ""
	Local aRet      := {}

	cQuery += " SELECT SA1.A1_COD, "
	cQuery += " MAX(SA1.A1_LOJA) AS A1_LOJA "
	cQuery += " FROM " + RetSQLName("SA1") + " SA1 (NOLOCK) "
	cQuery += " WHERE SA1.D_E_L_E_T_ = '' "
	cQuery += " AND   SA1.A1_CGC LIKE '" + cCGCBase + "%' "
	cQuery += " GROUP BY SA1.A1_COD "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If !Empty((cAliasQry)->(A1_COD)) .And. !Empty((cAliasQry)->(A1_LOJA))
		aAdd(aRet, (cAliasQry)->(A1_COD))

		cLoja := Soma1((cAliasQry)->(A1_LOJA))
		aAdd(aRet, cLoja)
	EndIf

Return(aRet)
              

//Pega proximo código válido
Static Function SA1NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	cX3_Relacao := GetSx3Cache("A1_COD", "X3_RELACAO")

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA1", "A1_COD")
		EndIf

		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		lJaExiste := SA1->(DbSeek(xFilial("SA1")+cCodNovo))
	End

Return(cCodNovo)
                  

//Insere Fornecedor
Static Function SA2Inserir(cAliasFor)

	Local lNovoFor    := .F.
	Local cCodNovo    := ""
	Local cLojaNovo   := ""
	Local cTpPessoa   := ""
	Local cCGCBase    := ""
	Local aUltCdLj    := {}

	(cAliasFor)->(DbGoTop())
	While (!(cAliasFor)->(Eof()))

		If (CGC((cAliasFor)->(CNPJ_CPF))) // Validação de CPF/CNPJ

			Conout("-----------------")
			Conout("Fornecedores")
			Conout("Empresa Logada: " + cEmpAnt + "-" + cFilAnt)
			Conout("CNPJ Cli: " + (cAliasFor)->(CNPJ_CPF))
			Conout("Razao Cli: " + (cAliasFor)->(RAZAO))
			Conout("Tipo Cli: " + IIf((cAliasFor)->(TPPESSOA) == "F", "F", "J"))

			SA2->(DbSetOrder(3))
			SA2->(DbGoTop())
			lNovoFor  := !SA2->(DbSeek(xFilial("SA2")+(cAliasFor)->(CNPJ_CPF)))
			
			If (lNovoFor)

				cTpPessoa := IIf((cAliasFor)->(TPPESSOA) == "F", "F", "J")

				If (cTpPessoa == "F")
					cCodNovo   := SA2NovoCod()
					cLojaNovo  := "01"
				Else
					cCGCBase := SubStr((cAliasFor)->(CNPJ_CPF), 1, 8)
					aUltCdLj := SA2UltLoja(cCGCBase)

					If (Len(aUltCdLj) == 2)
						cCodNovo   := aUltCdLj[1]
						cLojaNovo  := aUltCdLj[2]
					Else
						cCodNovo   := SA2NovoCod()
						cLojaNovo  := "01"
					EndIf
				EndIf  

				//Cria uma conta nova somente se for a primeira Loja	 
     			If cLojaNovo == '01'
     	  			_cConta := U_X635CONT(Alltrim(NoAcento(AnsiToOem((cAliasFor)->(FANTASIA)))),"SA2")  
     			Else
     			   	//Localiza Conta no Cadastro de Fornecedor
     			   	_cConta := U_X635A1CO(cCodNovo,cLojaNovo,'SA2') 
     			   	If Alltrim(_cConta) == ""
     			   		_cConta := U_X635CONT(Alltrim(NoAcento(AnsiToOem((cAliasFor)->(FANTASIA)))),"SA2")
     			   	Endif 
     			Endif

				//Valida se Consguiu Criar a Conta 
				//_cConta:= U_X635CONT(NoAcento(AnsiToOem((cAliasFor)->(FANTASIA))),"SA2")
				If alltrim(_cConta) <> ''
					RecLock("SA2", .T.)
					
					If cEmpant <> '44'
						SA2->A2_CLASSIF    := "00"  
						SA2->A2_MUN_ANP    := (cAliasFor)->(IBGE) 
						SA2->A2_PABCB   := (cAliasFor)->(CDPAIS)
						SA2->A2_ORIIMP  := "AGX635CF"
					Endif
					SA2->A2_COD        := cCodNovo
					SA2->A2_LOJA       := cLojaNovo
					SA2->A2_FILIAL     := xFilial("SA2")
					SA2->A2_NOME       := NoAcento(AnsiToOem((cAliasFor)->(RAZAO)))
					SA2->A2_NREDUZ     := NoAcento(AnsiToOem((cAliasFor)->(FANTASIA)))
					SA2->A2_CEP        := StrTran((cAliasFor)->(CEP),"-","")
					SA2->A2_END        := (cAliasFor)->(RUA)
					If !Empty((cAliasFor)->(NUMERO))
						SA2->A2_END += ", " + (cAliasFor)->(NUMERO)
					EndIf

					SA2->A2_BAIRRO     := (cAliasFor)->(BAIRRO)
					SA2->A2_EST        := (cAliasFor)->(UF)
					SA2->A2_COD_MUN    := SUBSTR( alltrim( (cAliasFor)->(IBGE) ) ,3,5)
					SA2->A2_MUN        := (cAliasFor)->(MUNIC)
					SA2->A2_INSCR      := (cAliasFor)->(INSCR_EST)
					SA2->A2_CGC        := (cAliasFor)->(CNPJ_CPF)
					SA2->A2_TEL        := (cAliasFor)->(FONE)
					SA2->A2_CONTATO    := (cAliasFor)->(CONTATO)

					If (cTpPessoa == "F") // Pessoa Física
						SA2->A2_TPESSOA := "PF" // CI - Comercio/Industria; PF - Pessoa Fisica; OS - Prestacäo de Servico
						SA2->A2_TIPO    := "F"  // F - Fisico; J - Juridico; X - Outros
					Else
						SA2->A2_TPESSOA := "CI" // CI - Comercio/Industria; PF - Pessoa Fisica; OS - Prestacäo de Servico
						SA2->A2_TIPO    := "J"  // F - Fisico; J - Juridico; X - Outros
					EndIf

					SA2->A2_CODPAIS := (cAliasFor)->(CDPAIS)
					SA2->A2_EMAIL   := (cAliasFor)->(EMAIL)
					SA2->A2_MSBLQL  := "2"
					SA2->A2_TRANSP  := "000001"
					SA2->A2_CONTA   := _cConta//U_X635CONT(NoAcento(AnsiToOem((cAliasFor)->(FANTASIA))),"SA2")//Cadastra uma Nova conta para o Fornecedor				
					SA2->A2_CATEGOR := "DIS"

					SA2->(MsUnLock())

					If __lSX8
						ConfirmSX8()

					EndIf
				Endif 
			EndIf
		EndIf

		(cAliasFor)->(DbSkip())
	End

Return _cConta      


//Ultima Loja válida
Static Function SA2UltLoja(cCGCBase)

	Local cQuery    := ""
	Local cAliasQry := "SA2UltLoja"//GetNextAlias()
	Local cLoja     := ""
	Local aRet      := {}

	cQuery += " SELECT SA2.A2_COD, "
	cQuery += " MAX(SA2.A2_LOJA) AS A2_LOJA "
	cQuery += " FROM " + RetSQLName("SA2") + " SA2 (NOLOCK) "
	cQuery += " WHERE SA2.D_E_L_E_T_ = '' "
	cQuery += " AND   SA2.A2_CGC LIKE '" + cCGCBase + "%' "
	cQuery += " GROUP BY SA2.A2_COD "

	TCQuery cQuery NEW ALIAS (cAliasQry)

	If !Empty((cAliasQry)->(A2_COD)) .And. !Empty((cAliasQry)->(A2_LOJA))
		aAdd(aRet, (cAliasQry)->(A2_COD))

		cLoja := Soma1((cAliasQry)->(A2_LOJA))
		aAdd(aRet, cLoja)
	EndIf

Return(aRet)    
              

//Gera novo código
Static Function SA2NovoCod()

	Local cX3_Relacao := ""
	Local cCodNovo    := ""
	Local lJaExiste   := .T.

	cX3_Relacao := GetSx3Cache("A2_COD", "X3_RELACAO")

	While (lJaExiste)

		If __lSX8
			ConfirmSX8()
		EndIf

		If !(Empty(cX3_Relacao))
			cCodNovo := (&cX3_Relacao)
		Else
			cCodNovo := GetSXENum("SA2", "A2_COD")
		EndIf

		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
		lJaExiste := SA2->(DbSeek(xFilial("SA2")+cCodNovo))
	End

Return(cCodNovo)   
    

//Geração de Conta Contabil automaticamente
User Function X635CONT(xRazao,xTipo)
	
	Local nOpcAuto :=0
	Local nX
	Local oCT1
	Local aLog
	Local cLog   := "" 
	Local _cConta := "" 

	Default xTipo = "SA2" 
	                     
	Static __oModelAut //:= NIL //variavel oModel para substituir msexecauto em MVC
     
	//Se for conta de Fornecedor
    If xTipo ==  "SA2"   

    	__oModelAut := FWLoadModel('CTBA020')	
		nOpcAuto:=3
		__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
		__oModelAut:Activate() //ativa modelo	                   
      
		DbSelectArea('CT1')	
		RegtoMemory('CT1') 
		_cConta := ALLTRIM(STR(u_x635NEXT(xTipo)))
		oCT1 := __oModelAut:GetModel('CT1MASTER') //Objeto similar enchoice CT1 
		oCT1:SETVALUE('CT1_CONTA',_cConta/*'211016859'*/)
		oCT1:SETVALUE('CT1_DESC01',xRazao)
		oCT1:SETVALUE('CT1_CLASSE','2')
		oCT1:SETVALUE('CT1_NORMAL' ,'2')
		oCT1:SETVALUE('CT1_BLOQ' ,'2')
		oCT1:SETVALUE('CT1_CVD02','1')
		oCT1:SETVALUE('CT1_CVD03','1')
		oCT1:SETVALUE('CT1_CVD04','1')
		oCT1:SETVALUE('CT1_CVD05','1')
		oCT1:SETVALUE('CT1_CVC02','1')
		oCT1:SETVALUE('CT1_CVC03','1')
		oCT1:SETVALUE('CT1_CVC04','1')
		oCT1:SETVALUE('CT1_CVC05','1')
		oCT1:SETVALUE('CT1_CTASUP','21101')
		oCT1:SETVALUE('CT1_ACITEM','1')	               
		oCT1:SETVALUE('CT1_ACCUST','1')
		oCT1:SETVALUE('CT1_ACCLVL','1')  
		oCT1:SETVALUE('CT1_AGLSLD','2')  
		oCT1:SETVALUE('CT1_RGNV1','200001')
		oCT1:SETVALUE('CT1_CCOBRG','2')   
		oCT1:SETVALUE('CT1_ITOBRG','2') 
		oCT1:SETVALUE('CT1_CLOBRG','2') 
		oCT1:SETVALUE('CT1_LALHIR','2')
		oCT1:SETVALUE('CT1_ACATIV','2')
		oCT1:SETVALUE('CT1_ATOBRG','2')
		oCT1:SETVALUE('CT1_05OBRG','2')
		oCT1:SETVALUE('CT1_PVARC','1')
		oCT1:SETVALUE('CT1_ACET05','2')
		oCT1:SETVALUE('CT1_INTP','1')  
		oCT1:SETVALUE('CT1_NTSPED','02') 

		//Campos do cadastro de Fornecedores
		oCT1:SETVALUE('CT1_ORIIMP','PASSIVO') 
		oCT1:SETVALUE('CT1_GRUPO','00000035') 
		oCT1:SETVALUE('CT1_XSGRUP','00000035') 

		DbSelectArea('CVD')
		RegtoMemory('CVD')
		oCVD := __oModelAut:GetModel('CVDDETAIL') //Objeto similar getdados CVD
		oCVD:SETVALUE('CVD_FILIAL' ,xFilial('CVD')) 
		oCVD:SETVALUE('CVD_ENTREF','10')
		oCVD:SETVALUE('CVD_CODPLA','003   '/*PadR('2016',Len(CVD->CVD_CODPLA))*/) 
		oCVD:SETVALUE('CVD_CTAREF','2.01.01.03.01                 '/*PadR('1.01.01.01.01', Len(CVD->CVD_CTAREF))*/)
		oCVD:SETVALUE('CVD_TPUTIL','A')
		oCVD:SETVALUE('CVD_CLASSE','2') 
		oCVD:SETVALUE('CVD_VERSAO','0001'/*PadR('0001',Len(CVD->CVD_VERSAO))*/)
		oCVD:SETVALUE('CVD_NATCTA','02')
		oCVD:SETVALUE('CVD_CTASUP','2.01.01.03                    ') 
		//oCVD:SETVALUE('CVD_CUSTO' ,'001'/*PadR('001',Len(CVD->CVD_CUSTO))*/)

		oCTS := __oModelAut:GetModel('CTSDETAIL') //Objeto similar getdados CTS    
		DbSelectArea('CTS') 
		DbSetOrder(2)
		If DbSeek(xfilial('CTS')+'999'+'0000000502'+'004')
			RegtoMemory('CTS')  

			oCTS:SETVALUE('CTS_FILIAL' ,xFilial('CTS')) 
			oCTS:SETVALUE('CTS_CODPLA' ,'999')
			oCTS:SETVALUE('CTS_CONTAG' ,'000000000000400500.1') 
			oCTS:SETVALUE('CTS_ORDEM' ,'0000000502')       
			oCTS:SETVALUE('CTS_IDENT' ,'1')	
		Endif

		If __oModelAut:VldData() //validacao dos dados pelo modelo	
	   		__oModelAut:CommitData() //gravacao dos dados	
		Else	                                                     	
			aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
			
			//laco para gravar em string cLog conteudo do array aLog
			For nX := 1 to Len(aLog)
				If !Empty(aLog[nX])
					cLog += Alltrim(aLog[nX]) + CRLF
				EndIf
			Next nX

			lMsErroAuto := .T. //seta variavel private como erro
			Conout(cLog)
			//AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
			//mostraerro()
			_cConta := ""
		EndIf 
		
		__oModelAut:DeActivate() //desativa modelo   

	//Se dor Cliente
	Else                                                    
		__oModelAut := FWLoadModel('CTBA020')	
		nOpcAuto:=3
		__oModelAut:SetOperation(nOpcAuto) // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
		__oModelAut:Activate() //ativa modelo	                   
      
		DbSelectArea('CT1')	
		RegtoMemory('CT1') 
		_cConta := ALLTRIM(STR(u_x635NEXT(xTipo)))
		oCT1 := __oModelAut:GetModel('CT1MASTER') //Objeto similar enchoice CT1 
		oCT1:SETVALUE('CT1_CONTA',_cConta/*'211016859'*/)
		oCT1:SETVALUE('CT1_DESC01',xRazao)
		oCT1:SETVALUE('CT1_CLASSE','2')
		oCT1:SETVALUE('CT1_NORMAL' ,'1')
		oCT1:SETVALUE('CT1_BLOQ' ,'2')
		oCT1:SETVALUE('CT1_CVD02','1')
		oCT1:SETVALUE('CT1_CVD03','1')
		oCT1:SETVALUE('CT1_CVD04','1')
		oCT1:SETVALUE('CT1_CVD05','1')
		oCT1:SETVALUE('CT1_CVC02','1')
		oCT1:SETVALUE('CT1_CVC03','1')
		oCT1:SETVALUE('CT1_CVC04','1')
		oCT1:SETVALUE('CT1_CVC05','1')
		oCT1:SETVALUE('CT1_CTASUP','11201')
		oCT1:SETVALUE('CT1_ACITEM','1')//1	               
		oCT1:SETVALUE('CT1_ACCUST','1')//1
		oCT1:SETVALUE('CT1_ACCLVL','1')//1  
		oCT1:SETVALUE('CT1_AGLSLD','2')  
		oCT1:SETVALUE('CT1_RGNV1','100010')
		oCT1:SETVALUE('CT1_CCOBRG','2')//2   
		oCT1:SETVALUE('CT1_ITOBRG','2')//2 
		oCT1:SETVALUE('CT1_CLOBRG','2') //2
		oCT1:SETVALUE('CT1_LALHIR','2')//2
		oCT1:SETVALUE('CT1_ACATIV','2')//2
		oCT1:SETVALUE('CT1_ATOBRG','2')//2
		oCT1:SETVALUE('CT1_05OBRG','2')//2
		oCT1:SETVALUE('CT1_PVARC','1')//1
		oCT1:SETVALUE('CT1_ACET05','2')//2
		oCT1:SETVALUE('CT1_INTP','1') //1 
		oCT1:SETVALUE('CT1_NTSPED','01') //01

		//Campos do cadastro de Clientes
		oCT1:SETVALUE('CT1_ORIIMP','ATIVO') 
		oCT1:SETVALUE('CT1_GRUPO','00000034') 
		oCT1:SETVALUE('CT1_XSGRUP','00000034') 
	
		DbSelectArea('CVD')
		RegtoMemory('CVD')
		oCVD := __oModelAut:GetModel('CVDDETAIL') //Objeto similar getdados CVD
		oCVD:SETVALUE('CVD_FILIAL' ,xFilial('CVD')) 
		oCVD:SETVALUE('CVD_ENTREF','10')
		oCVD:SETVALUE('CVD_CODPLA','003   '/*PadR('2016',Len(CVD->CVD_CODPLA))*/) 
		oCVD:SETVALUE('CVD_CTAREF','1.01.02.02.01                 '/*PadR('1.01.01.01.01', Len(CVD->CVD_CTAREF))*/)
		oCVD:SETVALUE('CVD_TPUTIL','A')
		oCVD:SETVALUE('CVD_CLASSE','2') 
		oCVD:SETVALUE('CVD_VERSAO','0001'/*PadR('0001',Len(CVD->CVD_VERSAO))*/)
		oCVD:SETVALUE('CVD_NATCTA','01')
		oCVD:SETVALUE('CVD_CTASUP','1.01.02.02                    ') 
		//oCVD:SETVALUE('CVD_CUSTO' ,'001'/*PadR('001',Len(CVD->CVD_CUSTO))*/)
		
		oCTS := __oModelAut:GetModel('CTSDETAIL') //Objeto similar getdados CTS    
		DbSelectArea('CTS') 
		DbSetOrder(2)
		If DbSeek(xfilial('CTS')+'999'+'0000000502'+'004')
			RegtoMemory('CTS')  
			
			oCTS:SETVALUE('CTS_FILIAL' ,xFilial('CTS')) 
			oCTS:SETVALUE('CTS_CODPLA' ,'999')
			oCTS:SETVALUE('CTS_CONTAG' ,'000000000000000020.3') 
			oCTS:SETVALUE('CTS_ORDEM' ,'0000000004')       
			oCTS:SETVALUE('CTS_IDENT' ,'1')	
		Endif
			
		If __oModelAut:VldData() //validacao dos dados pelo modelo	
	   		__oModelAut:CommitData() //gravacao dos dados	
		Else	                                                     	
			aLog := __oModelAut:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
			
			//laco para gravar em string cLog conteudo do array aLog
			For nX := 1 to Len(aLog)
				If !Empty(aLog[nX])
					cLog += Alltrim(aLog[nX]) + CRLF
				EndIf
			Next nX
			
			lMsErroAuto := .T. //seta variavel private como erro
			Conout(cLog)
			//AutoGRLog(cLog) //grava log para exibir com funcao mostraerro
			//mostraerro()
			_cConta := ""
		EndIf 
		
		__oModelAut:DeActivate() //desativa modelo   
	Endif

	
	//Valida se conseguiu criar a conta 
	If alltrim(_cConta) <>  ""
		Dbselectarea('CT1')
		DbSetOrder(1)
		If !( DbSeek(xfilial('CT1') + _cConta )) 
			_cConta := ""
		ElseIf !(SUBSTR(xRazao,1,40) $ CT1->CT1_DESC01)
			_cConta := ""
		Endif 
	Endif 

Return _cConta         
          

//Captura próxima conta Válida
User Function x635NEXT(xTipo)

 	Local cQuery 	:= ""  
 	Local cAliasQry := "TCT1"  
 	Local _nConta   := 0
 	                
 	//Busca conta do cliente
 	iF xTipo = 'SA1'
 		/*cQuery += " SELECT MAX(CT1_CONTA) AS CT1_CONTA FROM CT1"+cEmpant+"0"
		cQuery += " WHERE CT1_CONTA  LIKE '11201%'
		cQuery += " AND D_E_L_E_T_ = '' AND CT1_CONTA <> '112019999' "  */
		
		cQuery += " SELECT (MIN(CT1.CT1_CONTA) + 1 ) AS CT1_CONTA "
		cQuery += " FROM CT1"+cEmpant+"0 CT1 (NOLOCK) "
		cQuery += " WHERE CT1.D_E_L_E_T_ = ''   "
   		cQuery += " AND   CT1.CT1_CONTA BETWEEN '1120100000' AND '1120199999' "
		cQuery += " AND   LEN(RTRIM(CT1.CT1_CONTA))  IN( 9,10 ) "
		cQuery += " AND   NOT EXISTS (SELECT CT1SUB.CT1_CONTA   "
        cQuery += "          FROM CT1"+cEmpant+"0 CT1SUB (NOLOCK)  "
		cQuery += " 		  WHERE CT1.CT1_CONTA + 1 = CT1SUB.CT1_CONTA "
		cQuery += " 		  AND   CT1SUB.D_E_L_E_T_ = '' "
		cQuery += " 		  AND   CT1SUB.CT1_CONTA BETWEEN '1120100000' AND '1120199999' "
		cQuery += " 		  AND   LEN(RTRIM(CT1.CT1_CONTA))  IN( 9,10 ) AND   LEN(RTRIM(CT1SUB.CT1_CONTA))  IN( 9,10 ) ) "			  
 	Else
		/*cQuery += " SELECT MAX(CT1_CONTA) AS CT1_CONTA FROM CT1"+cEmpant+"0"
		cQuery += " WHERE CT1_CONTA  LIKE '21101%'
		cQuery += " AND D_E_L_E_T_ = ''   */
		
		cQuery += "SELECT (MIN(CT1.CT1_CONTA) + 1) AS CT1_CONTA  "
		cQuery += "FROM CT1"+cEmpant+"0 CT1 (NOLOCK) "
		cQuery += "WHERE CT1.D_E_L_E_T_ = '' "
		cQuery += "	AND   CT1.CT1_CONTA BETWEEN '211010000' AND '211019999'  "
   		cQuery += "	AND   LEN(RTRIM(CT1.CT1_CONTA))  IN( 9,10 )   "
  		cQuery += "	AND   NOT EXISTS (SELECT CT1SUB.CT1_CONTA  " "
       	cQuery += "           FROM CT1"+cEmpant+"0 CT1SUB (NOLOCK)  "
   		cQuery += "			  WHERE CT1.CT1_CONTA + 1 = CT1SUB.CT1_CONTA   "
   		cQuery += "			  AND   CT1SUB.D_E_L_E_T_ = ''    "
  		cQuery += "			  AND   CT1SUB.CT1_CONTA BETWEEN '211010000' AND '211019999'
  		cQuery += "			  AND   LEN(RTRIM(CT1.CT1_CONTA))  IN( 9,10 )  AND   LEN(RTRIM(CT1SUB.CT1_CONTA))  IN( 9,10 ))    "  
	Endif 
   
	//CONOUT(cQuery)
	
	If Select(cAliasQry) <> 0
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS (cAliasQry) 
	   
	_nConta := (cAliasQry)->CT1_CONTA
	 
 	 //Sequencia
	/* nSeq    := Val(Substr(alltrim((cAliasQry)->CT1_CONTA),6,6))//+1   
	 //Monta a Conta
	 //cConta  := PADR( SUBSTR( alltrim((cAliasQry)->CT1_CONTA) ,1,5)+ALLTRIM(str(nSeq)) ,20, '')
	 //Se for menor que Mil, inclui ZERO 
	 If nSeq < 1000
	 	_nConta := VAL(  SUBSTR( alltrim((cAliasQry)->CT1_CONTA) ,1,5)+'0'+ALLTRIM(str(nSeq)) ) 
	 Else
		//Se for igual a 9999 soma 1
		If nSeq == 9999
	    	nSeq++
	    Endif	 
		 _nConta := VAL(  SUBSTR( alltrim((cAliasQry)->CT1_CONTA) ,1,5)+ALLTRIM(str(nSeq)) ) 
	 Endif
     CONOUT(_nConta) */
Return _nConta
        

// Busca Primeira conta do Cliente / Fornecedor  
// É feito isso devido a ser um código por cliente
// e não por Cliente/Loja
User Function X635A1CO(xCod,xLoja,xTipo)  
	
	Local _aGetArea := Getarea()
	Local _cConta   := ""     

	//busca conta no cadastro 	 
	If xTipo == 'SA1'
		DbSelectarea('SA1')
		DbSetOrder(1)
		If Dbseek(xFilial('SA1')+xCod )
			_cConta := SA1->A1_CONTA 
		Endif
	ElseIf xTipo == 'SA2'   
		DbSelectarea('SA2')
		DbSetOrder(1)
		If Dbseek(xFilial('SA2')+xCod )
			_cConta := SA2->A2_CONTA 
		Endif	
	Endif               

	RestArea(_aGetArea) 	


Return _cConta


Static Function GVErrorlog(xError)

	CONOUT('*******************')
	CONOUT('GRERRORLOG')
	CONOUT(xError:Description) 
	CONOUT('*******************')

	//GRAVA Array de LOG
	AADD(aLogs,{;
			{'ZDB_DBEMP'  ,''},;
			{'ZDB_DBFIL'  ,''},;
			{'ZDB_MSG'	  ,'ERRORLOG '+xError:Description},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,'ERRORLOG'},; 
			{'ZDB_TAB' 	  ,''},; 
			{'ZDB_INDICE' ,1},;   
			{'ZDB_TIPOWF' ,8},; 
			{'ZDB_CHAVE'  ,'ERRORLOG'};
			})   

//		DisarmTransaction()

Return
