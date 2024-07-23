#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ROTINA DE INTEGRAÇÃO COM DBGINT - PRODUTOS
*/

/*/{Protheus.doc} AGX635PR
//ROTINA DE INTEGRAÇÃO COM DBGINT - PRODUTOS
@author Leandro Silveira
@since 11/09/2017
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/
User Function AGX635PR(aEmpDePara,xReproc)

	Local aEmpPara       := {}
	Local nEmpDe         := 0
	Local nCountDe       := 0
	Local nCountPara     := 0
	//Local nQtdePrd       := 0
	Local cAliasPrd      := ""
	//Local oTmpTable		 := Nil
	Local cEmpPara       := ""
	Local cFilialPara    := ""    
 	Private aLogs		 := {} //Array de Logs 
 	Default xReproc      := .F.   
 	Private lReproc      := xReproc
	Private  oError := ErrorBlock({|e| GVErrorlog(e)})
 	conout('AGX635PR - Inicio '+time())
	For nCountDe := 1 To Len(aEmpDePara)

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		/*RPCSetType(3)
		RPCSetEnv("01", "01")

		/*oTmpTable := CriaArqPrd(nEmpDe)

		cAliasPrd := oTmpTable:GetAlias()*/
		/*cAliasPrd := CriaArqPrd(nEmpDe)

	   	nQtdePrd := (cAliasPrd)->(RecCount())

		(cAliasPrd)->(DbCloseArea())
		//oTmpTable:Delete()
		//FreeObj(oTmpTable)

		RPCClearEnv()

	   	If nQtdePrd > 0*/
			For nCountPara := 1 To Len(aEmpPara)

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3]

				PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","XXS"
				RPCSetType(3)
				if RPCSetEnv(cEmpPara, cFilialPara)

					/*oTmpTable := CriaArqPrd(nEmpDe)

					cAliasPrd := oTmpTable:GetAlias() */

					cAliasPrd := CriaArqPrd(nEmpDe)

					If Select(cAliasPrd) <> 0

						InserirProd(cAliasPrd)

						(cAliasPrd)->(DbCloseArea())
						//oTmpTable:Delete()
						//FreeObj(oTmpTable)

						RPCClearEnv()
						dbcloseall()
					Else
						conout("AGX635PR - Nao foi Possivel selecionar : "+cAliasPrd)
					Endif 
							
					 
				Else
					conout("AGX635PR - Nao foi Possivel abrir o ambiente: "+cEmpPara+"-"+cFilialPara)
				Endif 
				RESET ENVIRONMENT 
	   		Next

			RPCSetType(3)
			If RPCSetEnv("01", "01")

				BaixarProd(nEmpDe)

				RPCClearEnv()
			Else
				conout("AGX635PR - BaixarProd: Nao foi Possivel abrir o ambiente: 01-01")
			Endif 
	   	//EndIf


	Next
	 
   	If len(aLogs) > 0 
	   	
	   //	U_AGX635CN("PRT") 
	    
 		//Grava Log
		U_AGX635LO(aLogs,'AGX635PR','IMPORTACAO PRODUTOS')
 	Endif

	ErrorBlock(oError)
Return(aEmpDePara)
           
           
//Busca dados no DBGint
Static Function SelectProd(nEmpOrigem)

	Local cAliasPRD := "SelectProd"//GetNextAlias()
	Local cQuery    := ""

	cQuery += " SELECT " 
	cQuery += "    TABPRO.GEN_TABEMP_Codigo AS DBEMP," //Código da Empresa
	cQuery += "    TABPRO.EST_TABPRO_Codigo AS CODIGO, " // Código do Produto
	cQuery += "    TABPRO.EST_TABPRO_Descricao AS DESCRICAO, " // Descrição do Produto
	cQuery += "    TABPRO.EST_TABPRO_Medida AS MEDIDA, " // Campo destinado para informar medida do produto (exemplo PNEUs - Medida: 275x80x22,5"")
	cQuery += "    TABPRO.EST_TABPRO_NrFabrica AS NRFABRICA, " // Número Original da Peça (código da fábrica)
	cQuery += "    TABPRO.EST_TABPRO_Ativo AS ATIVO, " // Produto ativo ou não (0 ou 1)
	cQuery += "    TABPRO.EST_TABPRO_SitTrib AS SITTRIB, " // Situação Tributária (0-Nacional, 1-Estrangeiro Importação Direta, 2-Estrangeiro Adquirido Mercado Interno). Serve para compor o CST nas notas de venda e compra.
	cQuery += "    TABPRO.EST_TABPRO_Created AS CREATED, " // Data e hora de criação do registro
	cQuery += "    TABPRO.EST_TABPRO_Updated AS UPDATED, " // Data e hora da última alteração do registro
	cQuery += "    TABPRO.EST_TABPRO_PercIPI AS PERCIPI, " // Percentual de IPI (quando houver)   
	cQuery += "    EST_TABPRO_CSTPISEntrada    AS CPISENT," 
	cQuery += "    EST_TABPRO_CSTPISSaida      AS CPISSAI,"
	cQuery += "    EST_TABPRO_CSTCOFINSEntrada AS CCOFENT,"
	cQuery += "    EST_TABPRO_CSTCOFINSSaida AS CCOFSAI,"	
	//	cQuery += "    TABPRO.EST_TABPRO_RequerLicFed, " // Requer Licença Federal - campo não utilizado
	//	cQuery += "    TABPRO.EST_TABPRO_RequerLicExe, " // Requer Licença Exército - campo não utilizado
	//	cQuery += "    TABPRO.EST_TABPRO_RequerLotFab, " // Requer Lote de Fabricação (se controla ou não lote de fabricação na compra e venda do produto) - não utilizado por enquanto
	//	cQuery += "    TABPRO.EST_TABPRO_Garantias, " // Texto para informar garantias e observações na impressão do produto na DANFE
	//	cQuery += "    TABPRO.EST_TABPRO_Procedencia, " // Próprio ou Revenda (P ou R) - campo não utilizado
	//	cQuery += "    TABPRO.EST_TABPRO_DiasValidade, " // Dias de validade do produto - utilizado no Lote de Fabricação - quando há o controle por lote
	//	cQuery += "    TABPRO.EST_TABPRO_EmitirCert, " // Emite Certificado de Qualidade - campo não utilizado
	//  cQuery += "    TABPRO.EST_TABPRO_Imagem, " // Foto do Produto
	cQuery += "    TABPRO.EST_TABPRO_ContaCusto AS CC_PROD, " // Código da Conta Contábil de Custos (serve para integração com outros sistemas contábeis via exportação de arquivo TXT)
	//  cQuery += "    TABPRO.EST_TABPRO_ContaFrete AS CCFRETE, " // Código da Conta Contábil de Fretes (serve para integração com outros sistemas contábeis via exportação de arquivo TXT)
	//	cQuery += "    TABPRO.EST_TABPRO_Pneu, " // Produto é um PNEU ?(0 ou 1)
	//	cQuery += "    TABPRO.EST_TABPRO_Critico, " // Produto é Crítico ? (o sistema controla produtos críticos quanto à segurança - aceita 0 ou 1)
	//	cQuery += "    TABPRO.EST_TABPRO_PermiteReqEst, " // Permite Requisição de Estoque ? (0 ou 1)
	//	cQuery += "    TABPRO.EST_TABPRO_Lubrificante, " // Produto é um Lubrificante ? (0 ou 1)
	//	cQuery += "    TABPRO.EST_TABPRO_Arrefecimento, " // Produto é um Líquido de Arrefecimento ? (0 ou 1)
	//	cQuery += "    TABPRO.EST_TABPRO_Aditivo, " // Produto é Arla 32 ? (0 ou 1)
	cQuery += "    TABPRO.EST_TABPRO_ContaEstoque AS CCESTOQUE, " // Código da Conta Contábil de Estoques (server para integração com outros sistemas contábeis via exportação de arquivo TXT)
	//	cQuery += "    TABPRO.EST_TABPRO_SeqModChassi, " // ID de sequencia da tabela de modelos de chassi que o produto atende - é um campo de controle da última sequencia gravada na tabela auxiliar - campo interno
	//	cQuery += "    TABPRO.EST_TABPRO_Servico, " // Item é um Serviço ? (0 ou 1) - mesma tabela de produtos é utilizado para serviços
	//	cQuery += "    TABPRO.EST_TABPRO_GerarSolCompras, " // Gerar Solicitação de Compras ? (0 ou 1) - produto pode ser utilizado em solicitações de compras?
	//	cQuery += "    TABPRO.EST_TABPRO_SeqFornecedor, " // ID de sequencia da tabela de fornecedores de produtos - é um campo de controle da última sequencia gravada na tabela auxiliar - campo interno
	//	cQuery += "    TABPRO.EST_TABPRO_OleoHidraulico, " // Produto é Óleo Hidraúlico ? (0 ou 1)
	cQuery += "    TABPRO.EST_TABPRO_PlanoContaCAR AS CONTACAR, " // Código da Conta no Plano de Contas Financeiro para Contas a Receber - utilizado para categorizar qual tipo de receita é este produto no módulo financeiro
	cQuery += "    TABPRO.EST_TABPRO_BloquearAlmox AS BLQALMOX, " // Bloqueia o uso deste produto na saída do almoxarifado (saída de produtos no consumo da Frota) ? (0 ou 1)
	//  cQuery += "    TABPRO.EST_TABPRO_Kit, " // Este produto é um KIT ? (0 ou 1)

	//	cQuery += "    TABPRO.GEN_TABEMP_Codigo, " // Empresa
	cQuery += "    GEN_TABNCM_Codigo AS NCM, " // Tabela de NCM
	//	cQuery += "    TABPRO.EST_CLACON_Codigo, " // Categorias do Site
	//  cQuery += "    TABPRO.CXB_PLACON_CodRed, " // Conta no Plano de Contas Financeiro para Contas a Pagar
	//	cQuery += "    TABPRO.EST_TABDEP_Codigo, " // Depósito
	//	cQuery += "    TABPRO.EST_TABEMB_Codigo, " // Embalagem (GALÃO, CAIXA, FARDO, ETC.)
	cQuery += "    TABPRO.EST_UNIMED_Codigo AS UNMED," // Unidade de Medida (LT, KG, PC)
	cQuery += "    GRPPRO.EST_GRPPRO_ContaCusto AS CC_GRUPO, " // Grupo do Produto (classificação dos produtos por família)
	cQuery += "    SGRPRO.EST_SGRPRO_ContaCusto AS CC_SUBGRP, " // Subgrupro do Produto
	cQuery += "    CLAPRO.EST_CLAPRO_ContaCusto AS CC_CLASSE,"  // Classe do Produto

	cQuery += "    CAST(TABPRO.EST_CLAPRO_Codigo AS  CHAR) AS COD_CLASS, "
    cQuery += "    CAST(TABPRO.EST_SGRPRO_Codigo AS  CHAR) AS COD_SUBGRP  , "
    cQuery += "    CAST(TABPRO.EST_GRPPRO_Codigo AS  CHAR) AS COD_GRUPO , "

	cQuery += "    EST_CLAPRO_DHIntTotvs AS  DH_CLASS, "
	cQuery += "    EST_SGRPRO_DHIntTotvs AS DH_SUBGRP, "
	cQuery += "    EST_GRPPRO_DHIntTotvs AS DH_GRUPO "

	/*cQuery += "    COALESCE((SELECT EST_CLAPRO_ContaCusto " // Conta contábil da classe do produto
	cQuery += "              FROM EST_CLAPRO CLAPRO"
	cQuery += "              WHERE CLAPRO.GEN_TABEMP_Codigo = TABPRO.GEN_TABEMP_Codigo"
	cQuery += "              AND   CLAPRO.EST_CLAPRO_Codigo = TABPRO.EST_CLAPRO_Codigo"
	cQuery += "              AND   CLAPRO.EST_SGRPRO_Codigo = TABPRO.EST_SGRPRO_Codigo"
	cQuery += "              AND   CLAPRO.EST_GRPPRO_Codigo = TABPRO.EST_GRPPRO_Codigo"
	cQuery += "    ), '') AS CC_CLASSE,"

	cQuery += "    COALESCE((SELECT EST_SGRPRO_ContaCusto"
	cQuery += "              FROM EST_SGRPRO SGRPRO"
	cQuery += "              WHERE SGRPRO.GEN_TABEMP_Codigo = TABPRO.GEN_TABEMP_Codigo"
	cQuery += "              AND   SGRPRO.EST_SGRPRO_Codigo = TABPRO.EST_SGRPRO_Codigo"
	cQuery += "              AND   SGRPRO.EST_GRPPRO_Codigo = TABPRO.EST_GRPPRO_Codigo"
	cQuery += "    ), '') AS CC_SUBGRP,"

	cQuery += "    COALESCE((SELECT EST_GRPPRO_ContaCusto"
	cQuery += "              FROM EST_GRPPRO GRPPRO"
	cQuery += "              WHERE GRPPRO.GEN_TABEMP_Codigo = TABPRO.GEN_TABEMP_Codigo"
	cQuery += "              AND   GRPPRO.EST_GRPPRO_Codigo = TABPRO.EST_GRPPRO_Codigo"
	cQuery += "    ), '') AS CC_GRUPO"*/

	cQuery += " FROM EST_TABPRO TABPRO "
	cQuery += "   LEFT JOIN EST_CLAPRO  CLAPRO ON "
	cQuery += " 			CLAPRO.GEN_TABEMP_Codigo = TABPRO.GEN_TABEMP_Codigo "
	cQuery += "               AND   CLAPRO.EST_CLAPRO_Codigo = TABPRO.EST_CLAPRO_Codigo "
	cQuery += "               AND   CLAPRO.EST_SGRPRO_Codigo = TABPRO.EST_SGRPRO_Codigo "
	cQuery += "               AND   CLAPRO.EST_GRPPRO_Codigo = TABPRO.EST_GRPPRO_Codigo "
	cQuery += " LEFT JOIN EST_SGRPRO SGRPRO ON "
	cQuery += " 			SGRPRO.GEN_TABEMP_Codigo = TABPRO.GEN_TABEMP_Codigo "
	cQuery += "               AND   SGRPRO.EST_SGRPRO_Codigo = TABPRO.EST_SGRPRO_Codigo "
	cQuery += "              AND   SGRPRO.EST_GRPPRO_Codigo = TABPRO.EST_GRPPRO_Codigo "
	cQuery += " LEFT JOIN EST_GRPPRO GRPPRO ON "
	cQuery += " 				GRPPRO.GEN_TABEMP_Codigo = TABPRO.GEN_TABEMP_Codigo "
	cQuery += "               AND   GRPPRO.EST_GRPPRO_Codigo = TABPRO.EST_GRPPRO_Codigo "
	//cQuery += " WHERE (EST_TABPRO_DHIntTotvs IS NULL OR  EST_TABPRO_DHIntTotvs = '1000-01-01 00:00:00') "
	cQuery += " WHERE "
    cQuery += " (  (EST_TABPRO_DHIntTotvs IS NULL OR  EST_TABPRO_DHIntTotvs = '1000-01-01 00:00:00') 
    cQuery += "  OR (EST_CLAPRO_DHIntTotvs IS NULL AND trim(EST_CLAPRO_ContaCusto) <> ''  AND EST_CLAPRO_Updated >= '2022-01-01' ) "
    cQuery += "  OR (EST_SGRPRO_DHIntTotvs IS NULL AND trim(EST_SGRPRO_ContaCusto) <> ''  AND EST_SGRPRO_Updated >= '2022-01-01') "
    cQuery += "  OR (EST_GRPPRO_DHIntTotvs IS NULL AND trim(EST_GRPPRO_ContaCusto) <> ''  AND EST_GRPPRO_Updated >= '2022-01-01') "
    cQuery += " ) "
	cQuery += " AND  TABPRO.GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)  
	cQuery += " AND TABPRO.EST_TABPRO_Codigo NOT LIKE 'DBPC%' "
	
	//conout(cQuery)
	U_AGX635CN("DBG")
	
	If Select(cAliasPRD) <> 0
		dbSelectArea(cAliasPRD)
		(cAliasPRD)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasPRD)

	If Select(cAliasPRD) <> 0
		dbSelectArea(cAliasPRD)
		//(cAliasPRD)->(dbCloseArea())
	Else 
		conout("AGX635PR - SelectProd: Nao foi criar alias "+cAliasPRD)
	Endif 

Return(cAliasPRD)

Static Function BaixarProd(nEmpOrigem)

	Local cAliasPrd := ""
	Local cProdIN   := "'0'"
	Local nQtdeIN   := 0
	//Local oTmpTable := Nil
	Local cClasse := ''//{}
 	Local cSubGrp := ''//{}
	Local cGrupo  := ''//{}
	
	U_AGX635CN("DBG")

	/*oTmpTable := CriaArqPrd(nEmpOrigem)
	cAliasPrd := oTmpTable:GetAlias()*/

	cAliasPrd := CriaArqPrd(nEmpOrigem)

	(cAliasPrd)->(DbGoTop())
	While !((cAliasPrd)->(Eof()))

				//Grava as variaveis para atualizar as Classes 
		Do Case
			Case alltrim(dtos((cAliasPrd)->DH_CLASS)) == '' .AND. alltrim((cAliasPrd)->CC_CLASSE) <> ''
				//conout( '244 - '+ alltrim(dtos((cAliasPrd)->DH_CLASS)) +' - ' +  (cAliasPrd)->COD_CLASS)
				iF alltrim((cAliasPrd)->COD_CLASS) <> ''
					If !(alltrim((cAliasPrd)->COD_CLASS) $ cClasse) 
						cClasse += "'"+alltrim((cAliasPrd)->COD_CLASS)+alltrim((cAliasPrd)->COD_SUBGRP)+alltrim((cAliasPrd)->COD_GRUPO)+"' ," 
					Endif 
				Endif
			Case alltrim(dtos((cAliasPrd)->DH_SUBGRP)) == '' .AND. alltrim((cAliasPrd)->CC_SUBGRP) <> ''
				//conout( '251 - '+ alltrim(dtos((cAliasPrd)->DH_SUBGRP)) +' - ' +  (cAliasPrd)->COD_SUBGRP)
				If alltrim((cAliasPrd)->COD_SUBGRP) <> ''
					If !(alltrim((cAliasPrd)->COD_SUBGRP) $ cSubGrp)  
						cSubGrp += "'"+alltrim((cAliasPrd)->COD_SUBGRP)+alltrim((cAliasPrd)->COD_GRUPO)+"' ," 
					Endif 
				Endif 	   		
			Case alltrim(dtos((cAliasPrd)->DH_GRUPO)) == '' .AND. alltrim((cAliasPrd)->CC_GRUPO) <> '' 
				//conout( '258 - '+ alltrim(dtos((cAliasPrd)->DH_GRUPO)) +' - ' +  (cAliasPrd)->COD_GRUPO)
				If alltrim((cAliasPrd)->COD_GRUPO) <> ''
					If !(alltrim((cAliasPrd)->COD_GRUPO) $ cGrupo)  
						cGrupo += "'"+alltrim((cAliasPrd)->COD_GRUPO)+"' ,"  
					Endif 
				Endif
	    EndCase   

		cProdIN += ",'" + AllTrim((cAliasPrd)->(CODIGO)) + "'"
		nQtdeIN += 1

		(cAliasPrd)->(DbSkip())

		If (nQtdeIN >= 50) .Or. (cAliasPrd)->(Eof())

			UpdateProd(nEmpOrigem, cProdIN)

			
			nQtdeIN := 0
			cProdIN := "'0'"
		EndIf
	Enddo

	/*Conout('272 - AGX635PR')
	Conout(cClasse)
	Conout(cSubGrp)
	Conout(cGrupo)
*/
	//atualiza Classe
	IF alltrim(cClasse) <> '' .or. alltrim(cSubGrp) <> '' .or. alltrim(cGrupo) <> ''
		UpdateClas(  cClasse ,  cSubGrp , cGrupo, nEmpOrigem)
	Endif 


	
	
	(cAliasPrd)->(DbCloseArea())
	//oTmpTable:Delete()
	//FreeObj(oTmpTable)

Return()


Static Function UpdateClas(  cClasse , cSubGrp  ,cGrupo, nEmpOrigem  )
	
	Local cQuery   := ""

	If alltrim(cClasse) <> ''	
		cQuery := " UPDATE EST_CLAPRO SET "
		cQuery += " EST_CLAPRO_DHIntTotvs = current_timestamp() "
		cQuery += " WHERE (EST_CLAPRO_DHIntTotvs IS NULL OR EST_CLAPRO_DHIntTotvs = '1000-01-01 00:00:00' )"
		cQuery += " AND  GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)
		cQuery += " AND  CONCAT(CONVERT(EST_CLAPRO_Codigo, CHAR) , CONVERT(EST_SGRPRO_Codigo, CHAR) , CONVERT(EST_GRPPRO_Codigo, CHAR) )  IN ( " + substr(cClasse,1,len(cClasse) - 1 ) + ")"
		
		//conout('AGX635PR EST_CLAPRO - '+cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao executar SQL: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf
	Endif 

	If alltrim(cSubGrp) <> ''	
		cQuery := " UPDATE EST_SGRPRO SET "
		cQuery += " EST_SGRPRO_DHIntTotvs = current_timestamp() "
		cQuery += " WHERE (EST_SGRPRO_DHIntTotvs IS NULL OR EST_SGRPRO_DHIntTotvs = '1000-01-01 00:00:00' )"
		cQuery += " AND  GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)
		cQuery += " AND  CONCAT( CONVERT(EST_SGRPRO_Codigo, CHAR) , CONVERT(EST_GRPPRO_Codigo, CHAR) )  IN ( " + substr(cSubGrp,1,len(cSubGrp) - 1 ) + ")"
		
		//conout('AGX635PR EST_SGRPRO - '+cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao executar SQL: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf
	Endif 

	If alltrim(cGrupo) <> ''
		cQuery := " UPDATE EST_GRPPRO SET "
		cQuery += " EST_GRPPRO_DHIntTotvs = current_timestamp() "
		cQuery += " WHERE (EST_GRPPRO_DHIntTotvs IS NULL OR EST_GRPPRO_DHIntTotvs = '1000-01-01 00:00:00' )"
		cQuery += " AND  GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)
		cQuery += " AND  CONCAT( CONVERT(EST_GRPPRO_Codigo, CHAR) )  IN ( " + substr(cGrupo,1,len(cGrupo) - 1 ) + ")"
		
		//conout('AGX635PR EST_GRPPRO - '+cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao executar SQL: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf

	Endif 

Return

Static Function UpdateProd(nEmpOrigem, cProdIN)

	Local cQuery   := ""

	cQuery += " UPDATE EST_TABPRO SET "
	cQuery += " EST_TABPRO_DHIntTotvs = current_timestamp() "
	cQuery += " WHERE (EST_TABPRO_DHIntTotvs IS NULL OR EST_TABPRO_DHIntTotvs = '1000-01-01 00:00:00' )"
	cQuery += " AND  GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)
	cQuery += " AND  EST_TABPRO_Codigo IN ( " + cProdIN + ")"

	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao executar SQL: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf

Return()

Static Function InserirProd(cAliasPRD)

	Local lNovo  := .F.
	Local cConta := ""

	U_AGX635CN("PRT")
	
	(cAliasPRD)->(DbGoTop())

	While (!(cAliasPRD)->(Eof()))

		SB1->(dbSetOrder(1))
		SB1->(DbGoTop())
		lNovo := !SB1->(DbSeek(xFilial("SB1")+(cAliasPRD)->(CODIGO)))
        
		if !Empty((cAliasPRD)->CC_CLASSE) .OR. !Empty((cAliasPRD)->CC_SUBGRP)  .OR. !Empty((cAliasPRD)->CC_GRUPO) .OR. !Empty((cAliasPRD)->CC_PROD)

			Reclock("SB1", lNovo)
	
			If (lNovo)
				SB1->B1_FILIAL  := xFilial("SB1")
				SB1->B1_PROC    := "011750" //DBGint
				SB1->B1_LOJPROC := "01"
				SB1->B1_COD     := (cAliasPRD)->(CODIGO) 				
				SB1->B1_RASTRO  := "N"
				SB1->B1_LOCALIZ := "N"
				SB1->B1_GRUPO   := "999"
				If cEmpant <> '44'
					SB1->B1_ORIGIMP := "AGX635"
				Endif
				SB1->B1_GARANT  := "2"
				SB1->B1_LOCPAD  := "DB"
				SB1->B1_CONV    := 1 
				If cEmpant <> '50'
					If cEmpant <> '44'
				  		SB1->B1_GRUCOD  := "011750" //DBGint
						SB1->B1_DTCAD   := dDataBase  
				 		SB1->B1_CABCMIN := "N"     
				 		SB1->B1_CABCMAX := "N"    
				 		SB1->B1_EXPORTA := "N"  
			   	  		SB1->B1_EMBTKE  := 1 
			   	  		SB1->B1_APLICAC := "DB"
			   		Endif
	            Endif 
	            
	            //Foi solicitado pela Eliane que sempre que o produto for CST 50(Entrada) ou CST 01(saída) no DBGINT, 
	            //preencha a importação da seguinte Forma
				//B1_COFINS = 'SIM'
				//B1_PIS = 'SIM'
				//B1_PCOFINS = 1.65
				//B1_PPIS        = 7.6   
				If (cAliasPRD)->(CPISENT) == '50' .AND.(cAliasPRD)->(CPISSAI) == '01'
			   		SB1->B1_COFINS = '1'
			   		SB1->B1_PCOFINS = 7.6 //1.65
				Endif 
				If (cAliasPRD)->(CCOFENT) == '50' .AND.(cAliasPRD)->(CCOFSAI) == '01'
			   		SB1->B1_PIS = '1'
			   		SB1->B1_PPIS = 1.65//7.6 
				Endif

			EndIf    
			 
			cUMedida := (cAliasPRD)->(UNMED)
			
			//De->Para de  Unidade de Medida
			if alltrim((cAliasPRD)->(UNMED)) $ 'FL/SRV'
				cUMedida := "UN"         
			ElseIf (cAliasPRD)->(UNMED) $ 'CJ/RE'
				cUMedida := "KT"
			Elseif (cAliasPRD)->(UNMED) == 'FR'
				cUMedida := "FD" 
			Elseif (cAliasPRD)->(UNMED) == 'KM'
				cUMedida := "M"
			Elseif (cAliasPRD)->(UNMED) == 'LATA'
				cUMedida := "LT" 
			Elseif (cAliasPRD)->(UNMED) == 'LT'
				cUMedida := "L"  
			Elseif (cAliasPRD)->(UNMED) $ 'M2/M3/MT'
				cUMedida := "M"
			Endif
						
			SB1->B1_DESC    := NoAcento(AnsiToOem((cAliasPRD)->(DESCRICAO)))
			SB1->B1_UM      := cUMedida
			SB1->B1_POSIPI  := (cAliasPRD)->(NCM)
	
			SB1->B1_ORIGEM  := (cAliasPRD)->(SITTRIB)
			SB1->B1_GRTRIB  := "01"

	
			SB1->B1_TE      := "001"
			SB1->B1_TS      := "510"
	
			If (!Empty((cAliasPRD)->(CC_PROD)))
				SB1->B1_CTADESP := (cAliasPRD)->(CC_PROD)
			ElseIf (!Empty((cAliasPRD)->(CC_CLASSE)))
				SB1->B1_CTADESP := (cAliasPRD)->(CC_CLASSE)
			ElseIf (!Empty((cAliasPRD)->(CC_SUBGRP)))
				SB1->B1_CTADESP := (cAliasPRD)->(CC_SUBGRP)
			ElseIf (!Empty((cAliasPRD)->(CC_GRUPO)))
				SB1->B1_CTADESP := (cAliasPRD)->(CC_GRUPO)
			EndIf    
			         
			
			SB1->B1_CONTA := '112070011'//FIXA 
			 
						  
			// Busca Dados nas Tabelas Genéricas DBGInt
			// A tabela 01 é um De Para de Conta Contábil,
			// Pois o plano de contas da empresa 50 é diferente das demais			
			If alltrim(SB1->B1_CONTA) <> '' 
			      //CONOUT('AGX635PR - TG')
				  //CONOUT(SB1->B1_CONTA)
				  		  //X635TGBU(  xEmp ,  xFil , xTab,   xTexto    ,  xBusca   ,  xReturn  ) 
				  If cEmpant == '50'
				  	cConta := U_X635TGBU(cEmpant,cFilAnt,'01' ,SB1->B1_CONTA,'ZDA_CAMP1','ZDA_CAMP2')  
				  Else
				  	cConta := U_X635TGBU(cEmpant,'','01' ,SB1->B1_CONTA,'ZDA_CAMP1','ZDA_CAMP2')  
				  Endif
				  //CONOUT(cConta)
				  If alltrim(cConta) <> ""
				  		SB1->B1_CONTA := cConta
				  Endif				  
			Endif
			            
            //SE FOR SERVICO - FALTA DEFINIR CAMPOS FIXOS  
           	If substr(alltrim((cAliasPRD)->(CODIGO)),1,4) == 'DBMO'; 
           		.or. substr(alltrim((cAliasPRD)->(CODIGO)),1,3) == 'DBS'  
           	   SB1->B1_TIPO    := "SV"  
           	   SB1->B1_CODISS  := "16.01" //Chamado 64888
           	Else
			   SB1->B1_TIPO    := "DB"//"PA"
		   EndIf
		   SB1->B1_MSBLQL  := "2"
		   SB1->B1_IPI := (cAliasPRD)->(PERCIPI)           
		   
		   If alltrim(cEmpAnt) <> '50'

		   	   IF cFilant == '14' .and. alltrim(cEmpAnt) == '01'
					SB1->B1_CTAREC  := '51110121'
					SB1->B1_CTADEV  := '51120118'
					SB1->B1_CTAICMS := '51120316'
					SB1->B1_CTAPIS  := '51120522'
					SB1->B1_CTACOFI := '51120622' 
			   	Else
					SB1->B1_CTAREC  := '51110107'
					SB1->B1_CTADEV  := '51120107'
					SB1->B1_CTAICMS := '51120307'
					SB1->B1_CTAPIS  := '51120507'
					SB1->B1_CTACOFI := '51120607' 
				Endif 

			   SB1->B1_AGMRKP  := "PECAS_MASTER"
			   //SB1->B1_CTADESP //não é obrigatório
			     
			   If alltrim(cEmpAnt) <> '44'
				   	If ((cAliasPRD)->(ATIVO) == 1)
						SB1->B1_SITUACA := "1"
						SB1->B1_MSBLQL  := "2"
					Else
						SB1->B1_SITUACA := "2"
						SB1->B1_MSBLQL  := "1"
					EndIf
				Endif 
			Endif
	
			SB1->(MsUnlock())//MsUnlock("SB1")
        Else            
            //AADD(aLogs,{'ZDB_DBEMP','ZDB_DBFIL','ZDB_MSG','ZDB_DATA','ZDB_HORA','ZDB_EMP','ZDB_FILIAL','ZDB_CHAVE'} ) 
            If !lReproc
       	 		//GRAVA Array de LOG
        		AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cAliasPRD)->(DBEMP)},;
						{'ZDB_DBFIL'  ,0/*(cAliasPRD)->(DBFIL)*/}								,;
						{'ZDB_MSG'	  ,'Produto SEM Conta cadastrada:'+(cAliasPRD)->(CODIGO)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cAliasPRD)->(CODIGO)},;  
						{'ZDB_TIPOWF' ,3},;
						{'ZDB_CHAVE'  ,(cAliasPRD)->(CODIGO)};
						})      
        	Else
        	    Alert(	'Produto SEM Conta cadastrada:'+(cAliasPRD)->(CODIGO))
        	Endif    
        	       
           //Exclui Linha para não gravar 
           //data/Hora importação
        	dbselectarea(cAliasPRD)
   			Reclock(cAliasPRD,.F.)
              dbdelete()
        	(cAliasPRD)->(MsUnlock())  
        	
        Endif                  
		
		(cAliasPRD)->(DbSkip())
	EndDO      
               

Return()

Static Function CriaArqPrd(nEmpOrigem)

	Local aStruTmp     := {}
	//Local oTmpTable    := Nil
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	cAliasQry := SelectProd(nEmpOrigem)

	If Select(cAliasQry) <> 0
		aStruTmp := (cAliasQry)->(DbStruct())

		/*oTmpTable := FwTemporaryTable():New()
		oTmpTable:SetFields(aStruTmp)
		oTmpTable:AddIndex("1", {aStruTmp[1][1]})
		oTmpTable:Create()

		cAliasArea := oTmpTable:GetAlias()*/

		cAliasArea := "CriaArqPrd"//GetNextAlias()
		cArquivo := CriaTrab(,.F.)
		dbCreate(cArquivo,aStruTmp)
		dbUseArea(.T.,__LocalDriver,cArquivo,cAliasArea,.F.,.F.)

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
	Endif 

Return(cAliasArea)

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
