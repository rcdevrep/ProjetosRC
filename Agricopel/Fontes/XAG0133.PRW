#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'
#include "rwmake.ch"
#include "tbiconn.ch"
#include 'protheus.ch'
#include 'parmtype.ch'


WSRESTFUL Precos DESCRIPTION 'Serviço de Alteração de valores' SECURITY 'MATA010' FORMAT 'APPLICATION_JSON,TEXT,HTML'

	WSMETHOD PUT Precos;
		DESCRIPTION 'Alteração de precos';
		WSSYNTAX '/precos_put/';
		PATH '/precos_put/'

	WSMETHOD POST produto;
		DESCRIPTION 'Cadastro de produto no cliente';
		WSSYNTAX '/produto_post/';
		PATH '/produto_post/'

	WSMETHOD PUT produto;
		DESCRIPTION 'Alteração de produtos do cliente';
		WSSYNTAX '/produto_put/';
		PATH '/produto_put/'

	WSMETHOD DELETE produto;
		DESCRIPTION 'Deletar produto do cliente';
		WSSYNTAX '/produto_delete/';
		PATH '/produto_delete/'
	WSMETHOD POST CondPag;
		DESCRIPTION 'Cadastrar nova condpag para o cliente';
		WSSYNTAX '/condpg_post/';
		PATH '/condpg_post/'
	WSMETHOD PUT CondPag;
		DESCRIPTION 'Ativar/Inativar condpag do cliente';
		WSSYNTAX '/condpg_put/';
		PATH '/condpg_put/'

ENDWSRESTFUL

WSMETHOD PUT precos_put WSSERVICE Precos
	Local cQry      	:= ""
	Local oJson     	:= JsonObject():New()
	Local oResponse 	:= JsonObject():New()
	Local nAcres		:= 0
	Local cAliasSE4
	Local cAliasQry
	Local cJson
	Local nPrecoAtu := 0
	Local nPrecoBase := 0
	Local aLog 		:= {}

	cJson  := Self:GetContent()
	oJson:FromJson(cJson)

	cAliasQry := GetNextAlias()
	cAliasSE4 := GetNextAlias()
	DbSelectArea('ACP')

	cQry := " SELECT E4_CODIGO, E4_XACRTRR FROM " + RetSqlName('SE4') + CRLF
	cQry += " WHERE E4_CODIGO = '" + oJson['CondPag'] + "'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF
	
	PlsQuery(cQry, cAliasSE4)

	aAdd(aLog, {Time(), "Executou a query da SE4"})


	nAcres := (cAliasSE4)->E4_XACRTRR

	cQry := " SELECT ACO.ACO_CODCLI, ACO.ACO_LOJA, ACO.ACO_CONDPG, ACO.ACO_DATATE, ACO.ACO_CODTAB, ACP.ACP_CODPRO, ACP.ACP_PRECO, SE4.E4_XACRTRR, ACP.R_E_C_N_O_ AS [RecACP] FROM " + RetSqlName('ACO')+" ACO "
	cQry += " JOIN " + RetSqlName('ACP')+" ACP ON ACO.ACO_FILIAL = ACP.ACP_FILIAL AND ACO.ACO_CODREG = ACP.ACP_CODREG AND ACP.D_E_L_E_T_ = '' " + CRLF
	cQry += " JOIN " + RetSqlName('SE4')+" SE4 ON ACO.ACO_CONDPG = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = '' " + CRLF
	cQry += " WHERE ACO.ACO_FILIAL = '" + oJson['Filial'] +"'" + CRLF
	cQry += " AND ACO.ACO_CODCLI = '" + oJson['Cliente'] +"'" + CRLF
	cQry += " AND ACO.ACO_LOJA = '" + oJson['Loja'] +"'" + CRLF
	cQry += " AND (ACO.ACO_DATATE < " + DtoS(Date()) + " OR ACO.ACO_DATATE <> '' )" + CRLF
	cQry += " AND ACO.ACO_CODTAB = '" + oJson['CodTabPreco'] +"'" + CRLF
	cQry += " AND ACP.ACP_CODPRO = '" + oJson['CodProduto'] + "'" + CRLF
	cQry += " AND ACO.D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasQry)

	aAdd(aLog, {Time(), "Executou a query da ACO e ACP"})

	If ! (cAliasQry)->(EoF())
		(cAliasQry)->(DbGoTop())
		WHILE ! (cAliasQry)->(EoF())
			nPrecoBase := oJson['Preco'] - nAcres
			nPrecoAtu := nPrecoBase + (cAliasQry)->E4_XACRTRR
			ACP->(DbGoTo((cAliasQry)->RecACP))
			RecLock('ACP', .F.)
			ACP->ACP_PRECO  := nPrecoAtu
			ACP->(MsUnLock())

			(cAliasQry)->(DbSkip())
		ENDDO

		aAdd(aLog, {Time(), "Preços atualizados"})

		oResponse['PrecoAlterado'] 	:= "true"
		oResponse['Mensagem'] 		:= "Preco alterado com sucesso"
		oResponse['Preco']			:= ACP->ACP_PRECO
	Else
		oResponse['PrecoAlterado'] := "false"
		oResponse['Mensagem'] := "Nao existem descontos cadastrados para essas condicoes"
	ENDIF
	Self:SetStatus(201)
	Self:SetContentType(APPLICATION_JSON)
	Self:SetResponse(oResponse:ToJson())

	(cAliasQry)->(DbCloseArea())
return


WSMETHOD PUT produto_put WSSERVICE Precos
	Local cQry 		:= ""
	Local cAliasACP := GetNextAlias()
	Local cAliasRec := GetNextAlias()
	Local oJson 	:= JsonObject():New()
	Local oResponse := JsonObject():New()
	Local lRet 		:= .T.
	Local cJson 	:= ""
	Local nPrcProd	:= 0
	Local aFil 		:= {}
	Local nAtual 	:= 0

	cJson  := Self:GetContent()
	oJson:FromJson(cJson)

	//RpcClearEnv()
	//RpcSetType(3)
	///RpcSetEnv('01', "03")

	//Se for uma ativação de produtos, vai rodar todas as filiais primeiro para verificar se o produto existe
	IF oJson['Status'] == '2'
		aFil := StrTokArr(oJson['Filial'],",")
		FOR nAtual := 1 to len(aFil)

			cQry := " SELECT ACO.ACO_FILIAL, ACO.ACO_CODCLI, ACO.ACO_LOJA, ACP.ACP_CODPRO, ACP.R_E_C_N_O_ AS ACPREC, ACP.ACP_MSBLQL FROM " +RetSqlName('ACO') +" ACO " + CRLF
			cQry += " JOIN " + RetSqlName('ACP') + " ACP ON ACP.ACP_FILIAL = ACO.ACO_FILIAL AND ACP.ACP_CODREG = ACO.ACO_CODREG AND ACP.D_E_L_E_T_ = '' AND ACP.ACP_CODPRO = '" +oJson['CodProduto']+"'  " + CRLF
			//cQry += " WHERE ACO.ACO_FILIAL = '" + aFil[nAtual] +"'" + CRLF
			cQry += " AND ACO.ACO_CODCLI = '" + oJson['CodCli'] + "'" + CRLF
			cQry += " AND ACO.ACO_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
			cQry += " AND ACO.D_E_L_E_T_ = ''  " + CRLF


			PlsQuery(cQry, cAliasACP)

			IF (cAliasACP)->(EoF())
				lRet := .F.
				SetRestFault(400, "Nao existe um produto para esses parametros: " + "Codigo do cliente - "+oJson['CodCli']+" Loja - "+oJson['LojaCli'])
				return(lRet)
			ENDIF
		NEXT
	ELSE
		aAdd(aFil, '01')
	ENDIF

	FOR nAtual := 1 to len(aFil)
		IF oJson['Status'] == '2'
			cQry := " SELECT ACO.ACO_FILIAL, ACO.ACO_CODCLI, ACO.ACO_LOJA, ACO.ACO_CONDPG, ACP.ACP_CODPRO, ACP.R_E_C_N_O_ AS ACPREC, ACP.ACP_MSBLQL, DA1.DA1_PRCVEN, SE4.E4_XACRTRR FROM " + RetSqlName('ACO') + " ACO " + CRLF
			cQry += " JOIN " + RetSqlName('ACP') + " ACP ON ACP.ACP_FILIAL = ACO.ACO_FILIAL AND ACP.ACP_CODREG = ACO.ACO_CODREG AND ACP.D_E_L_E_T_ = '' AND ACP.ACP_CODPRO = '" + oJson['CodProduto'] + "' " + CRLF
			cQry += " JOIN " + RetSqlName('DA1') + " DA1 ON DA1.DA1_FILIAL = ACP.ACP_FILIAL AND DA1.DA1_CODPRO = ACP.ACP_CODPRO AND DA1.D_E_L_E_T_ = '' AND DA1.DA1_CODTAB = '888' " + CRLF
			cQry += " JOIN " + RetSqlName('SE4') + " SE4 ON SE4.E4_CODIGO = ACO.ACO_CONDPG AND SE4.D_E_L_E_T_ = '' " + CRLF
		//	cQry += " WHERE ACO.ACO_FILIAL = '" + aFil[nAtual] +"'" + CRLF
			cQry += " WHERE ACO.ACO_CODCLI = '" + oJson['CodCli'] + "'" + CRLF
			cQry += " AND ACO.ACO_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
			cQry += " AND ACO.D_E_L_E_T_ = ''  " + CRLF
		ELSE
			cQry := " SELECT ACO.ACO_FILIAL, ACO.ACO_CODCLI, ACO.ACO_LOJA, ACP.ACP_CODPRO, ACP.R_E_C_N_O_ AS ACPREC, ACP.ACP_MSBLQL FROM " +RetSqlName('ACO') +" ACO " + CRLF
			cQry += " JOIN " + RetSqlName('ACP') + " ACP ON ACP.ACP_FILIAL = ACO.ACO_FILIAL AND ACP.ACP_CODREG = ACO.ACO_CODREG AND ACP.D_E_L_E_T_ = '' AND ACP.ACP_CODPRO = '" +oJson['CodProduto']+"'  " + CRLF
			cQry += " WHERE ACO.ACO_CODCLI = '" + oJson['CodCli'] + "'" + CRLF
			cQry += " AND ACO.ACO_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
			cQry += " AND ACO.D_E_L_E_T_ = ''  " + CRLF
		ENDIF

		PlsQuery(cQry, cAliasRec)

		IF !(cAliasRec)->(EoF())
			(cAliasRec)->(DbGoTop())
			WHILE !(cAliasRec)->(EoF())
				DbSelectArea('ACP')
				ACP->(DbGoTo((cAliasRec)->ACPREC))
				RecLock('ACP', .F.)
				ACP->ACP_MSBLQL = oJson['Status']
				IF oJson['Status'] == '2'
					nPrcProd := (cAliasRec)->DA1_PRCVEN + (cAliasRec)->E4_XACRTRR
					ACP->ACP_PRECO := nPrcProd
				ENDIF
				ACP->(MsUnLock())
				(cAliasRec)->(DbSkip())
			ENDDO
		ENDIF

		oResponse['code']         	:= 201
		oResponse['message']      	:= "Status do produto alterado com sucesso"
		IF oJson['Status'] == '2'
			oResponse['filial'] 		:= oJson['Filial']
		ENDIF
	NEXT

	Self:SetStatus(201)
	Self:SetContentType(APPLICATION_JSON)
	Self:SetResponse(oResponse:ToJson())
return


WSMETHOD POST produto_post WSSERVICE Precos
	Local cQry              := ""
	Local cAliasQry         := ""
	Local cAliasACP         := ""
	Local cAliasSB1 		:= ""
	Local cAliasDA1 		:= ""
	Local cJson             := ""
	Local oJson             := JsonObject():New()
	Local oResponse         := JsonObject():New()
	Local cAliasVld			:= ""
	Local aCodReg 			:= {}
	Local nItem             := 0
	Local nPrecoProd        := 0
	Local cCodProd          := ""
	Local nAcrsFin 			:= 0
	Local lInclui 			:= .T.
	Local lRet 				:= .T.
	Local aFil 				:= {}
	Local nAtual 			:= 0
	Local cFilInc 			:= ""

	RpcSetType(3)
	RpcSetEnv('01', '03')

	cJson  := Self:GetContent()
	oJson:FromJson(cJson)

	aFil := StrTokArr(oJson['Filial'],",")

	cAliasQry := GetNextAlias()
	cAliasACP := GetNextAlias()
	cAliasVld := GetNextAlias()
	SB1->(DbSetOrder(1))

	//Validação do produto
	cAliasSB1 := GetNextAlias()

	cQry := " SELECT B1_COD, B1_DESC FROM " + RetSqlName('SB1') + CRLF
	cQry += " WHERE B1_COD = '" +oJson['CodProduto'] + "'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasSB1)
	IF !(cAliasSB1)->(EoF())
		cCodProd := oJson['CodProduto']
	ELSE
		SetRestFault(400, EncodeUTF8("Esse produto não está cadastrado no Protheus"))
		lRet := .F.
		return(lRet)
	ENDIF

	//Validação da regra de desconto
	FOR nAtual := 1 to Len(aFil)

		cQry := " SELECT ACO.ACO_FILIAL, ACO.ACO_CODREG,ACO.ACO_CODCLI, ACO.ACO_LOJA, ACO.ACO_DESCRI, ACO.ACO_CONDPG, ACO.ACO_DATATE, ACO.ACO_CODTAB, SE4.E4_XACRTRR, SE4.E4_DESCRI FROM "+RetSqlName("ACO")+" ACO " + CRLF
		cQry += " JOIN "+RetSqlName("SE4")+" SE4 ON ACO.ACO_CONDPG = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = ''  " + CRLF
		cQry += " WHERE ACO.ACO_FILIAL = '" + aFil[nAtual] +"'" + CRLF
		cQry += " AND ACO.ACO_CODCLI = '" +  oJson['CodCli'] + "'"  + CRLF
		cQry += " AND ACO.ACO_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
		cQry += " AND ACO.D_E_L_E_T_ = '' " + CRLF

		PlsQuery(cQry, cAliasQry)

		IF (cAliasQRY)->(EoF())
			SetRestFault(400, EncodeUTF8("Não existe regra de desconto cadastrada para esses parâmetros:" + " Filial - "+aFil[nAtual]+" Codigo do cliente - "+oJson['CodCli']+" Loja - "+oJson['LojaCli']))
			lRet := .F.
			return(lRet)
		ENDIF

		//VERIFICA SE JÁ NÃO EXISTE O PRODUTO NA REGRA DE DESCONTO
		cQry := " SELECT ACP_FILIAL,ACP_CODREG,ACP_CODPRO AS ACP_ITEM FROM " + RetSqlName('ACP') + CRLF
		cQry += " WHERE ACP_FILIAL = '" +  aFil[nAtual] + "'" +CRLF
		cQry += " AND ACP_CODREG = '" + (cAliasQry)->ACO_CODREG + "'" + CRLF
		cQry += " AND ACP_CODPRO = '"+oJson['CodProduto']+"'" + CRLF
		cQry += " AND D_E_L_E_T_ = '' " + CRLF

		PlsQuery(cQry, cAliasVld)

		IF !(cAliasVld)->(EoF())
			//SetRestFault(400, EncodeUTF8("O produto já está cadastrado para esses parâmetros:" + " Filial - "+aFil[nAtual]+" Codigo do cliente - "+oJson['CodCli']+" Loja - "+oJson['LojaCli'] + " Cod. Regra - " + (cAliasQry)->ACO_CODREG))
			//lRet := .F.
			//return(lRet)
			lInclui := .F.
			//aAdd(aFil[nAtual], .F.)
		ENDIF

		IF lInclui
			cFilInc += aFil[nAtual] + "|"
		ENDIF

	NEXT

	cQry := " SELECT ACO.ACO_FILIAL, ACO.ACO_CODREG,ACO.ACO_CODCLI, ACO.ACO_LOJA, ACO.ACO_DESCRI, ACO.ACO_CONDPG, ACO.ACO_DATATE, ACO.ACO_CODTAB, SE4.E4_XACRTRR, SE4.E4_DESCRI FROM "+RetSqlName("ACO")+" ACO " + CRLF
	cQry += " JOIN "+RetSqlName("SE4")+" SE4 ON ACO.ACO_CONDPG = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = ''  " + CRLF
	cQry += " WHERE ACO.ACO_CODCLI = '" +  oJson['CodCli'] + "'"  + CRLF
	cQry += " AND ACO.ACO_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
	cQry += " AND ACO.D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasQry)

	nAcrsFin 	:= (cAliasQry)->E4_XACRTRR

	IF ! (cAliasQry)->(EoF())

		(cAliasQry)->(DbGoTop())
		WHILE ! (cAliasQry)->(EoF())
			aAdd(aCodReg, (cAliasQry)->ACO_CODREG)
			(cAliasQry)->(DbSkip())
		ENDDO

		FOR nAtual := 1 to len(aFil)
			IF aFil[nAtual] $ cFilInc

				RpcClearEnv()
				RpcSetType(3)
				RpcSetEnv('01',aFil[nAtual])

				cQry := " SELECT MAX(ACP_ITEM) AS ACP_ITEM FROM " + RetSqlName('ACP') + CRLF
				cQry += " WHERE ACP_FILIAL = '" +  aFil[nAtual] + "'" +CRLF
				cQry += " AND ACP_CODREG = '" + aCodReg[nAtual] + "'" + CRLF
				cQry += " AND D_E_L_E_T_ = '' " + CRLF

				PlsQuery(cQry, cAliasACP)

				cAliasDA1 := GetNextAlias()

				cQry := " SELECT DA1_FILIAL, DA1_CODTAB, DA1_CODPRO, DA1_PRCVEN FROM " + RetSqlName('DA1') + " (NOLOCK) " + CRLF
				cQry += " WHERE DA1_FILIAL = '" + aFil[nAtual] +"'" + CRLF
				cQry += " AND DA1_CODPRO = '" + cCodProd + "'" + CRLF
				cQry += " AND DA1_CODTAB = '888' " + CRLF

				PlsQuery(cQry, cAliasDA1)

				IF !(cAliasDA1)->(EoF())

					nItem := cValToChar(StrZero(Val((cAliasACP)->ACP_ITEM ) + 1, 3))
					nPrecoProd := (cAliasDA1)->DA1_PRCVEN + nAcrsFin

					RecLock('ACP', .T.)
					ACP->ACP_FILIAL := aFil[nAtual]
					ACP->ACP_CODREG := aCodReg[nAtual]
					ACP->ACP_ITEM   := nItem
					ACP->ACP_CODPRO := cCodProd
					ACP->ACP_FAIXA 	:= 999999.99
					ACP->ACP_PRECO  := nPrecoProd
					ACP->(MsUnLock())
				ELSE
					SetRestFault(400, EncodeUTF8("O produto '" + AllTrim((cAliasSB1)->B1_COD) + "' não está cadastrado na regra de desconto '888' da filial " + aFil[nAtual]))
					lRet := .F.
					return(lRet)
				ENDIF
			ENDIF
		NEXT

		oResponse['code']         	:= 201
		oResponse['message']      	:= "Produto gravado na regra de desconto"
		oResponse['filial'] 		:= oJson['Filial']
	ENDIF

	Self:SetStatus(201)
	Self:SetContentType(APPLICATION_JSON)
	Self:SetResponse(oResponse:ToJson())
return(lRet)

WSMETHOD DELETE produto_delete WSSERVICE Precos
	Local cQry          := ""
	Local cAliasQry     := ""
	Local cAliasACP     := ""
	Local cJson         := ""
	Local oJson         := JsonObject():New()
	Local lDeuCerto     := .T.
	Local oResponse     := JsonObject():New()

	cJson  := Self:GetContent()
	oJson:FromJson(cJson)

	cAliasQry := GetNextAlias()
	cAliasACP := GetNextAlias()
	DbSelectArea('ACP')
	SB1->(DbSetOrder(1))

	IF SB1->(DbSeek(FWxFilial('SB1') +oJson['CodProduto']))
		cCodProd := oJson['CodProduto']
	ELSE
		SetRestFault(400, "Esse produto não está cadastrado no Protheus")
		return
	ENDIF

	cQry := " SELECT ACO.ACO_CODREG,ACO.ACO_CODCLI, ACO.ACO_LOJA, ACO.ACO_DESCRI, ACO.ACO_CONDPG, ACO.ACO_DATATE, ACO.ACO_CODTAB FROM "+RetSqlName("ACO")+" ACO " + CRLF
	cQry += " WHERE ACO.ACO_FILIAL = '" + oJson['Filial'] +"'" + CRLF
	cQry += " AND ACO.ACO_CODCLI = '" +  oJson['CodCli'] + "'"  + CRLF
	cQry += " AND ACO.ACO_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
	cQry += " AND ACO.D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasQry)

	IF ! (cAliasQry)->(EoF())
		(cAliasQry)->(DbGoTop())
		WHILE ! (cAliasQry)->(EoF())
			cQry := " SELECT *  FROM " + RetSqlName('ACP') + CRLF
			cQry += " WHERE ACP_FILIAL = '" +  oJson['Filial'] + "'" +CRLF
			cQry += " AND ACP_CODREG = '" + (cAliasQry)->ACO_CODREG + "'" + CRLF
			cQry += " AND ACP_CODPRO = '" + cCodProd + "'" + CRLF
			cQry += " AND D_E_L_E_T_ = '' " + CRLF

			PlsQuery(cQry, cAliasACP)

			IF ! (cAliasACP)->(EoF())
				ACP->(DbGoTo((cAliasACP)->R_E_C_N_O_))
				IF RecLock('ACP', .F.)
					DbDelete()
					ACP->(MsUnLock())
					lDeuCerto   := .T.
				ENDIF
			ENDIF
			(cAliasQry)->(DbSkip())
		ENDDO
		oResponse['code']         	:= 201
		oResponse['message']      	:= "Produto excluido da regra de desconto"
		oResponse['filial'] 		:= cFilAnt
	ELSE
		SetRestFault(400, "Não existe regra de desconto cadastrada para esses parâmetros")
	ENDIF
	Self:SetStatus(201)
	Self:SetContentType(APPLICATION_JSON)
	Self:SetResponse(oResponse:ToJson())
return

WSMETHOD POST condpg_post WSSERVICE Precos
	Local cQry			:= ""
	Local nAtual 		:= 0
	Local aProdutos 	:= {}
	Local cAliasACP 	:= ""
	Local cAliasSE4 	:= ""
	Local nX			:= 0
	Local nValorTotal 	:= 0
	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local aLinha 		:= {}
	Local aPrcProd		:= {}
	Local cLogErro 		:= ""
	Local cCodCli 		:= ""
	Local cLojaCli 		:= ""
	Local cIdPed 		:= ""
	Local lRet 			:= .T.
	Local nPosProd 		:= 0
	Local aAcres 		:= {}
	Local nPrecoBase 	:= 0
	Local aPrecos 		:= {}
	Local aCondPag 		:= {}
	Local aErroAuto 	:= {}
	Local cAliasSA1 	:= ""
	Local oJson 		:= JsonObject():New()
	Local aFil 			:= {}
	Local oResponse 	:= JsonObject():New()
	Local cCodReg
	PRIVATE lMsErroAuto   	:= .F.
	PRIVATE lAutoErrNoFile	:= .T.

	cJson  := Self:GetContent()
	oJson:FromJson(cJson)

	aFil := StrTokArr(oJson['Filial'],",")

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv('01', '15')

	cAliasACP := GetNextAlias()
	cAliasSE4 := GetNextAlias()
	cAliasSA1 := GetNextAlias()

	//BUSCA PARA PEGAR O CODIGO DO CLIENTE CONFORME O BANCO
	cQry := " SELECT A1_COD, A1_LOJA FROM " + RetSqlName('SA1') + CRLF
	cQry += " WHERE A1_COD = '" + oJson['CodCli'] + "'" + CRLF
	cQry += " AND A1_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasSA1)

	cCodCli 	:= (cAliasSA1)->A1_COD
	cLojaCli 	:= (cAliasSA1)->A1_LOJA

	//BUSCA DOS PRODUTOS RELACIONADOS AO CLIENTE
	cQry := " SELECT ACP.ACP_CODPRO, ACO.ACO_CONDPG, SE4.E4_XACRTRR, ACP.ACP_PRECO FROM "+RetSqlName('ACP')+" ACP " + CRLF
	cQry += " JOIN "+RetSqlName('ACO')+" ACO ON ACO.ACO_FILIAL = ACP.ACP_FILIAL AND ACO.ACO_CODREG = ACP.ACP_CODREG AND ACO.ACO_CODCLI = '"+cCodCli+"' AND ACO.ACO_LOJA = '" + oJson['LojaCli'] +"' AND ACO.D_E_L_E_T_ = '' " + CRLF
	cQry += " JOIN "+RetSqlName('SE4')+" SE4 ON ACO.ACO_CONDPG = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = '' " + CRLF
	cQry += " WHERE ACP.ACP_FILIAL = '"+ oJson['Filial'] + "'" + CRLF
	cQry += " AND ACP.D_E_L_E_T_ = ''" + CRLF

	PlsQuery(cQry, cAliasACP)

	(cAliasACP)->(DbGoTop())
	WHILE ! (cAliasACP)->(EoF())
		nPosProd := 0
		nPosProd := aScan(aProdutos, {|x| Alltrim((x)) = Alltrim((cAliasACP)->ACP_CODPRO)})
		IF nPosProd == 0
			aAdd(aProdutos, (cAliasACP)->ACP_CODPRO)
			aAdd(aCondPag, 	(cAliasACP)->ACO_CONDPG)
			aAdd(aAcres,	(cAliasACP)->E4_XACRTRR)
			aAdd(aPrecos, 	(cAliasACP)->ACP_PRECO)
		ENDIF
		(cAliasACP)->(DbSkip())
	ENDDO

	//FOR PARA PRECIFICAR OS PRODUTOS
	FOR nAtual := 1 to Len(aProdutos)
		cQry := " SELECT SE4.E4_CODIGO,SE4.E4_XACRTRR FROM " + RetSqlName('SE4') +" SE4 " + CRLF
		cQry += " WHERE SE4.E4_CODIGO = '"+ oJson['CodCondPg']+ "'" + CRLF
		cQry += " AND SE4.D_E_L_E_T_ = '' " + CRLF

		PlsQuery(cQry, cAliasSE4)

		nPrecoBase := aPrecos[nAtual] - aAcres[nAtual]

		nValorTotal := nPrecoBase + (cAliasSE4)->E4_XACRTRR

		aAdd(aPrcProd, {aProdutos[nAtual], nValorTotal})

	NEXT

	BEGIN TRANSACTION

		FOR nX := 1 to Len(aFil)
			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv('01', aFil[nX])
			cCodReg := GetSxeNum("ACO", "ACO_CODREG")

			aAdd(aCabec, {"ACO_FILIAL",   		aFil[nX],                       	Nil})
			aAdd(aCabec, {"ACO_CODREG",   		cCodReg,                         	Nil})
			aAdd(aCabec, {"ACO_DESCRI",   		oJson['DescCondPg'], 				Nil})
			aAdd(aCabec, {"ACO_CODCLI",   		cCodCli, 							Nil})
			aAdd(aCabec, {"ACO_LOJA",   		cLojacli, 							Nil})
			aAdd(aCabec, {"ACO_CODTAB",   		"888", 								Nil})
			aAdd(aCabec, {"ACO_MOEDA ",   		1, 									Nil})
			aAdd(aCabec, {"ACO_CONDPG",   		oJson['CodCondPg'],					Nil})
			aAdd(aCabec, {"ACO_TPHORA",   		'1',                             	Nil})
			aAdd(aCabec, {"ACO_HORADE",  		'00:00',                          	Nil})
			aAdd(aCabec, {"ACO_HORATE",  		'23:59',                          	Nil})
			aAdd(aCabec, {"ACO_DATDE",    		Date(),                          	Nil})

			FOR nAtual := 1 to len(aPrcProd)
				aLinha := {}
				aAdd(aLinha,{"ACP_FILIAL",     	aFil[nX],   								Nil})
				aAdd(aLinha,{"ACP_ITEM",      	cValToChar(StrZero(nAtual, 3)),   				Nil})
				aAdd(aLinha,{"ACP_CODPRO",    	aPrcProd[nAtual][1],  							Nil})
				aAdd(aLinha,{"ACP_PRECO",    	aPrcProd[nAtual][2],      						Nil})

				aAdd(aItens, aLinha)
			NEXT

			SA1->(DbCloseArea())

			MSExecAuto({|a, b, c| FATA080(a, b, c)}, aCabec, aItens, 3)

			ConfirmSX8()
			If lMsErroAuto
				DisarmTransaction()
				aErroAuto := GetAutoGRLog()
				For nAtual := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(aErroAuto[nAtual], "<", ""), "-", "") + " " + CRLF
				Next
				cIdPed 	:= GetSXENum("ZZ9","ZZ9_ID")
				Reclock("ZZ9",.T.)
				ZZ9->ZZ9_FILIAL := aFil[nX]
				ZZ9->ZZ9_ID 	:= cIdPed
				ZZ9->ZZ9_ROTINA := "CONDPAG"
				ZZ9->ZZ9_DATA 	:= Date()
				ZZ9->ZZ9_LOG  	:= cLogErro
				ZZ9->ZZ9_STATUS := "P"
				ZZ9->ZZ9_JSON 	:= cJson
				ZZ9->(MsUnLock())
				ConfirmSX8()
				lRet := .F.
				SetRestFault(400, EncodeUTF8("Não foi possivel cadastrar a condição de pagamento na filial " +aFil[nX]+ ", por favor verificar na tabela de log ID " + cIdPed))
				return
			ELSE
				lRet := .T.
			ENDIF
		NEXT nAtual

	END TRANSACTION

	IF lRet
		oResponse['code'] 			:= 201
		oResponse['message']      	:= "Condicao incluida com sucesso"
		oResponse['condicao']		:= cCodReg
		oResponse['filial'] 		:= oJson['Filial']
	ENDIF
	Self:SetStatus(201)
	Self:SetContentType(APPLICATION_JSON)
	Self:SetResponse(oResponse:ToJson())
return(lRet)

WSMETHOD PUT CondPag WSSERVICE Precos
	Local cQry 			:= ""
	Local cAliasACO 	:= ""
	Local oJson 		:= JsonObject():New()
	Local oResponse 	:= JsonObject():New()
	Local cJson 		:= ""

	cJson  := Self:GetContent()
	oJson:FromJson(cJson)

	cAliasACO := GetNextAlias()
	DBSelectArea('ACO')

	cQry := " SELECT ACO_FILIAL, ACO_CODCLI, ACO_LOJA, ACO_CONDPG, ACO_MSBLQL, R_E_C_N_O_ FROM " + RetSqlName('ACO') + CRLF
	cQry += " WHERE ACO_FILIAL = '" + oJson['Filial'] + "'" +CRLF
	cQry += " AND ACO_CODCLI = '" + oJson['CodCli'] + "'" + CRLF
	cQry += " AND ACO_LOJA = '" + oJson['LojaCli'] + "'" + CRLF
	cQry += " AND ACO_CONDPG = '" + oJson['CodCondPg'] + "'" + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	PlsQuery(cQry, cAliasACO)

	IF ! (cAliasACO)->(EoF())
		ACO->(DbGoTo((cAliasACO)->R_E_C_N_O_))
		RecLock('ACO', .F.)
		ACO->ACO_MSBLQL := oJson['Status']
		ACO->(MsUnLock())

		oResponse['code'] 			:= 201
		oResponse['message']      	:= "Condicao alterada com sucesso"
	ELSE
		SetRestFault(400, "Esse produto não está cadastrado no Protheus")
		return
	ENDIF

	Self:SetStatus(201)
	Self:SetContentType(APPLICATION_JSON)
	Self:SetResponse(oResponse:ToJson())
return
