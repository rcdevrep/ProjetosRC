#Include "Protheus.ch"
#Include "FWMVCDef.ch"

Static aFieldsM := {"ZNF_FILIAL","ZNF_DOC","ZNF_SERIE","ZNF_FORN","ZNF_LOJA","ZNF_NOME","ZNF_DTINC"}
Static aFieldsD := {"ZNF_ITNF","ZNF_COD","ZNF_DESC","ZNF_QTDNF","ZNF_LOCAL","ZNF_LOTE","ZNF_ITEND","ZNF_ENDER","ZNF_QTDEND","ZNF_QTDMOV"}

/*/{Protheus.doc} EST001A
Programa para auxílio no cancelamento de notas fiscais.
@type function
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return Nil.
/*/
User Function EST001A()

	Local cUsrLib	:= SuperGetMV("MV_XULENF",,"")
    Local oBrowse 	:= Nil
	
//	Valida se usuário tem permissão para acessar a rotina.
	If __cUserID $ cUsrLib
		oBrowse := FWMBrowse():New()
//		Define a tabela de dados.
		oBrowse:SetAlias("ZNF")
//	 	Nome do fonte onde esta a função MenuDef.
		oBrowse:SetMenuDef("EST001A")
//		Descrição do browse.
		oBrowse:SetDescription("Est. Mov. p/ Exclusão de NF de Entrada")
//		Legendas.
		oBrowse:AddLegend("ZNF_STATUS=='E'","YELLOW","Movimentações de estoque estornadas, aguardando NF de entrada.","",.T.)
		oBrowse:AddLegend("ZNF_STATUS=='F'","GREEN","NF de entrada relançada.","",.T.)
//		Desabilita opção Ambiente do menu Ações Relacionadas.
		oBrowse:SetAmbiente(.F.)
//		Desabilita opção WalkThru do menu Ações Relacionadas.
		oBrowse:SetWalkThru(.F.)
//		Desabilita a exibição dos detalhes do registro posicionado.
		oBrowse:DisableDetails()
//		Ativação da classe.
		oBrowse:Activate()
	Else
		MsgStop("Usuário sem permissão para acessar a rotina.","NoPerm")
	EndIf

Return

/*/{Protheus.doc} MenuDef
Opções do menu da rotina.
@type function
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return aRotina, Array com as opções do menu.
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EST001A" OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.EST001A" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	
Return aRotina

/*/{Protheus.doc} ModelDef
Model do componente MVC.
@type function
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return oModel, Objeto MPFormModel.
/*/
Static Function ModelDef()
	
	Local aRltMxD		:= {{"ZNF_FILIAL","xFilial('ZNF')"};
							,{"ZNF_DOC","ZNF_DOC"};
							,{"ZNF_SERIE","ZNF_SERIE"};
							,{"ZNF_FORN","ZNF_FORN"};
							,{"ZNF_LOJA","ZNF_LOJA"};
							,{"ZNF_DTINC","ZNF_DTINC"}}
	Local aTrigger 		:= {}
	Local bBefore		:= {|oModel,cID,cAlias| GrvOthers(oModel,cID,cAlias)}
	Local bCommit		:= {|| FWFormCommit(Self,bBefore,,,)}
	Local bLinePre		:= {|oModelGrid,nLine,cAction,cIDField,xValue,xCurValue| InitLine(oModelGrid,nLine,cAction,cIDField,xValue,xCurValue)}
	Local bPost			:= {|oModel| TudoOK(oModel)}
	Local bPre			:= {|oModel,cAction,cField,xValue| VldPre(oModel,cAction,cField,xValue)}
	Local oModel   		:= Nil
	Local oStrMaster	:= FWFormStruct(1,"ZNF",{|cCampo| AScan(aFieldsM,AllTrim(cCampo)) > 0})
	Local oStrDetail	:= FWFormStruct(1,"ZNF")

//	Adiciona a data e hora de inclusão ao inicializador do campo.
	oStrMaster:SetProperty("ZNF_DTINC",MODEL_FIELD_INIT,{|| GravaData(Date(),.F.,5) + SubStr(Time(),1,5)})
//	Adiciona a descrição do produto ao inicializador do campo quando não for inclusão.
	oStrDetail:SetProperty("ZNF_DESC",MODEL_FIELD_INIT,{|| IIf(!INCLUI,Posicione("SB1",1,xFilial('SB1') + ZNF->ZNF_COD,"B1_DESC"),"")})

//	Trigger para infornar o nome do fornecedor.
	aTrigger := FwStruTrigger("ZNF_LOJA","ZNF_NOME","SA2->A2_NREDUZ",.T.,"SA2",1,"xFilial('SA2')+M->ZNF_FORN+ZNF_LOJA","SF1->F1_TIPO != 'D'","01")
	aTrigger := FwStruTrigger("ZNF_LOJA","ZNF_NOME","SA1->A1_NREDUZ",.T.,"SA1",1,"xFilial('SA1')+M->ZNF_FORN+ZNF_LOJA","SF1->F1_TIPO != 'D'","02")
	oStrMaster:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

//	Instancia a classe model.
	oModel := MPFormModel():New("EST001MVC",,bPost,bCommit)
//	Define os campos do MASTER.
	oModel:AddFields("MASTER",,oStrMaster,bPre)
//	Informa o uso da grid MASTER e DETAIL.
	oModel:AddGrid("DETAIL","MASTER",oStrDetail,bLinePre)
//	Define o relacionamento entre MASTER e DETAIL.
	oModel:SetRelation("DETAIL",aRltMxD,ZNF->(IndexKey(1)))
//	Informa a chave primária.
	oModel:SetPrimaryKey({})
//	Impede deletar registros.
	oModel:GetModel("DETAIL"):SetNoDeleteLine(.T.)
//	Descrição do modelo.
	oModel:SetDescription("Est. Mov. p/ Exclusão de NF de Entrada")
	
Return oModel

/*/{Protheus.doc} ViewDef
View do componente MVC.
@type function
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return oView, Objeto FWFormView.
/*/
Static Function ViewDef()
	
	Local oModel 		:= FWLoadModel("EST001A")
	Local oStrMaster	:= FWFormStruct(2,"ZNF",{|cCampo| AScan(aFieldsM,AllTrim(cCampo)) > 0})
	Local oStrDetail	:= FWFormStruct(2,"ZNF",{|cCampo| AScan(aFieldsD,AllTrim(cCampo)) > 0})
	Local oView			:= Nil
	
	oView := FWFormView():New()
//	Informa o Model ao View.
	oView:SetModel(oModel)
//	Adiciona os campos ao View Master.
	oView:AddField("VIEW_MASTER",oStrMaster,"MASTER")
//	Adiciona os campos ao View Detail.
   	oView:AddGrid("VIEW_DETAIL",oStrDetail,"DETAIL")
//	Cria as Boxes.
   	oView:CreateHorizontalBox("SUPERIOR",30)
   	oView:CreateHorizontalBox("INFERIOR",70)
//	Informa o superior das Boxes.
	oView:SetOwnerView("VIEW_MASTER","SUPERIOR")
	oView:SetOwnerView("VIEW_DETAIL","INFERIOR")
//	Habilitando título.
	oView:EnableTitleView("VIEW_MASTER","Documento de Entrada")
	oView:EnableTitleView("VIEW_DETAIL","Itens Nota Fiscal")
//	Fecha ao pressionar Ok.
	oView:SetCloseOnOk({|oView| .T.})
	
Return oView

/*/{Protheus.doc} VldPre
Função para validação do model.
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return lOk, se pode prosseguir.
@param oMaster, object, model.
@param cAction, characters, ação.
@param cField, characters, campo.
@param xValue, undefined, valor atribuído.
@type function
/*/
Static Function VldPre(oMaster,cAction,cField,xValue)

	Local lOk 		:= .T.
	Local dUlMes	:= SuperGetMV("MV_ULMES",,SToD("19970101"))

	Begin Sequence
//		Carrega o grid de itens.
		If cField == "ZNF_DOC" .And. cAction == "SETVALUE"
//			Validação do fechamento de estoque.
			If SF1->F1_DTDIGIT <= dUlMes
				Help(,,"MVUlMes",,"O parâmetro MV_ULMES está com a data de: " + DToC(dUlMes);
									+ " e a nota fiscal foi digitada na data de: " + DToC(SF1->F1_DTDIGIT),1,0)
				Break
//			Verifica se os títulos da nota estão baixados.
			ElseIf TitNFBx(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
				Help(,,"TitBx",,"A nota fiscal possui títulos no financeiro baixados e por conta disto não poderá ser estornada.",1,0)
				Break
			EndIf
		//ElseIf cField == "ZNF_NOME"
			//SetItens(oMaster:GetValue("ZNF_DOC"),oMaster:GetValue("ZNF_SERIE"),oMaster:GetValue("ZNF_FORN"),oMaster:GetValue("ZNF_LOJA"))
			SetItens(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
		EndIf
	Recover
		lOk := .F.
	End Sequence

Return lOk

/*/{Protheus.doc} TitNFBx
Função para verifica se os títulos da nota fiscal possuem baixa.
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return Nil.
@param cDoc, characters, número da nota fiscal.
@param cSerie, characters, série da nota fiscal.
@param cForn, characters, código do fornecedor.
@param cLoja, characters, loja do fornecedor.
@type function
/*/
Static Function TitNFBx(cDoc,cSerie,cForn,cLoja)

	Local _cAlias := GetNextAlias()

	BeginSQL Alias _cAlias
		SELECT
			SE2.*
		FROM
			%Table:SF1% SF1
		INNER JOIN
			%Table:SE2% SE2
			ON	E2_FILIAL = %xFilial:SE2%
			AND E2_NUM = F1_DUPL
			AND E2_PREFIXO = F1_PREFIXO
			AND E2_FORNECE = F1_FORNECE
			AND E2_LOJA = F1_LOJA
			AND E2_BAIXA != %Exp:CriaVar("E2_BAIXA",.F.)%
			AND SE2.%NotDel%
		WHERE
				F1_FILIAL = %xFilial:SF1%
			AND F1_DOC = %Exp:cDoc%
			AND F1_SERIE = %Exp:cSerie%
			AND F1_FORNECE = %Exp:cForn%
			AND F1_LOJA = %Exp:cLoja%
			AND SF1.%NotDel%
	EndSQL

	lBxTit := !(_cAlias)->(EOF())

	(_cAlias)->(DBCloseArea())

Return lBxTit

/*/{Protheus.doc} InitLine
Função para validar a inclusão das linhas.
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return lOk, logical, se por inserir a linha.
@param oModelGrid, object, model.
@param nLine, numeric, linha.
@param cAction, characters, ação.
@param cIDField, characters, campo.
@param xValue, undefined, valor do campo.
@param xCurValue, undefined, valor atual do campadmino.
@type function
/*/
Static Function InitLine(oModelGrid,nLine,cAction,cIDField,xValue,xCurValue)
	
	Local lOk := .F.

	Help(,,"NoManAlt",,"As informações não podem ser alteradas manualmente, apenas através da seleção de nota fiscal.",1,0)
	
Return lOk

/*/{Protheus.doc} SetItens
Função para alimentar o grid de produtos da nota fiscal de entrada conforme o endereçamento dos itens.
@author Paulo Felipe Silva
@since 19/07/2018
@version 1.0
@return Nil.
@param cDoc, characters, número da nota fiscal.
@param cSerie, characters, série da nota fiscal.
@param cForn, characters, código do fornecedor.
@param cLoja, characters, loja do fornecedor.
@type function
/*/
Static Function SetItens(cDoc,cSerie,cForn,cLoja)

	Local _cAlias 	:= GetNextAlias()
	Local nCount	:= 1
	LocaL nQtdMov	:= 0
	Local oDetail 	:= Nil
	Local oMaster 	:= Nil
	Local oModel	:= FWModelActive()

	oDetail := oModel:GetModel("DETAIL")
	oMaster := oModel:GetModel("MASTER")

	BeginSQL Alias _cAlias
		SELECT
			D1_DTDIGIT AS DTDIGIT,
			D1_ITEM AS ITNF,
			DB_PRODUTO AS COD,
			B1_DESC AS DESCRI,
			D1_QUANT AS QTDNF,
			DB_LOCAL AS LOCAL,
			DB_LOTECTL AS LOTE,
			DB_NUMSEQ AS NUMSEQ,
			DB_ITEM AS ITEND,
			DB_QUANT AS QTDEND,
			(CASE (BF_QUANT) WHEN NULL THEN 0 ELSE BF_QUANT END) AS SALDO_SBF,
			DB_LOCALIZ AS ENDER,
			DB_DATA AS DTEND
		FROM
			%Table:SD1% SD1
		INNER JOIN
			%Table:SDB% SDB
			ON	DB_FILIAL = D1_FILIAL
			AND DB_PRODUTO = D1_COD
			AND DB_LOCAL = D1_LOCAL
			AND DB_NUMSEQ = D1_NUMSEQ
			AND DB_DOC = D1_DOC
			AND DB_SERIE = D1_SERIE
			AND DB_CLIFOR = D1_FORNECE
			AND DB_LOJA = D1_LOJA
			AND DB_ESTORNO != 'S'
			AND SDB.%NotDel%
		LEFT JOIN
			%Table:SBF% SBF
			ON	BF_FILIAL = DB_FILIAL
			AND BF_LOCAL = DB_LOCAL
			AND BF_LOCALIZ = DB_LOCALIZ
			AND BF_PRODUTO = DB_PRODUTO
			AND BF_NUMSERI = DB_NUMSERI
			AND BF_LOTECTL = DB_LOTECTL
			AND SBF.%NotDel%
		INNER JOIN
			%Table:SB1% SB1
			ON	B1_FILIAL = %xFilial:SD1%
			AND B1_COD = D1_COD
			AND SB1.%NotDel%
		WHERE
				D1_FILIAL = %xFilial:SD1%
			AND D1_DOC = %Exp:cDoc%
			AND D1_SERIE = %Exp:cSerie%
			AND D1_FORNECE = %Exp:cForn%
			AND D1_LOJA = %Exp:cLoja%
			AND SD1.%NotDel%
	EndSQL

	While !(_cAlias)->(EOF())
//			Adiciona a linha e preenche a mesma.
		If nCount > 1
			oDetail:AddLine()
//			Preenchimento das informações da capa para as nova linhas.
			AEVal(aFieldsM,{|x| oDetail:LoadValue(x,oMaster:GetValue(x))})
		EndIf

//		Verifica a quantidade necessária para realizar o movimento do estoque.
		nQtdMov := IIf((_cAlias)->SALDO_SBF - (_cAlias)->QTDEND < 0,ABS((_cAlias)->SALDO_SBF - (_cAlias)->QTDEND),0)

		oDetail:LoadValue("ZNF_STATUS"	,"E")
		oDetail:LoadValue("ZNF_DTDIG"	,SToD((_cAlias)->DTDIGIT))
		oDetail:LoadValue("ZNF_ITNF"	,(_cAlias)->ITNF)
		oDetail:LoadValue("ZNF_COD"		,(_cAlias)->COD)
		oDetail:LoadValue("ZNF_DESC"	,(_cAlias)->DESCRI)
		oDetail:LoadValue("ZNF_QTDNF"	,(_cAlias)->QTDNF)
		oDetail:LoadValue("ZNF_LOCAL"	,(_cAlias)->LOCAL)
		oDetail:LoadValue("ZNF_LOTE"	,(_cAlias)->LOTE)
		oDetail:LoadValue("ZNF_NSNFE"	,(_cAlias)->NUMSEQ)
		oDetail:LoadValue("ZNF_ITEND"	,(_cAlias)->ITEND)
		oDetail:LoadValue("ZNF_QTDMOV"	,nQtdMov)
		oDetail:LoadValue("ZNF_ENDER"	,(_cAlias)->ENDER)
		oDetail:LoadValue("ZNF_DTEND "	,SToD((_cAlias)->DTEND))
		oDetail:LoadValue("ZNF_QTDEND"	,(_cAlias)->QTDEND)
		nCount++
		(_cAlias)->(DBSkip())
	End
	(_cAlias)->(DBCloseArea())

Return

/*/{Protheus.doc} TudoOK
Função de validação após clicar em confirmar.
@author paulo.silva
@since 19/06/2017
@version 1.0
@type function
/*/
Static Function TudoOK(oModel)
	
	Local aAreaZNF	:= ZNF->(GetArea())
	Local lOk		:= .T.
	Local nOper		:= oModel:GetOperation()
	Local oMaster	:= oModel:GetModel("MASTER")

	Begin Sequence
		If nOper == MODEL_OPERATION_INSERT
			If ZNF->(DBSeek(xFilial("ZNF") + oMaster:GetValue("ZNF_DOC") + oMaster:GetValue("ZNF_SERIE") + oMaster:GetValue("ZNF_FORN") + oMaster:GetValue("ZNF_LOJA") + "E"))
				Help(,,"AguEst",,"A nota fiscal informada está pendente realizar o estorno, favor verificar.",1,0)
				Break
			EndIf
		EndIf
	Recover
		lOk := .F.
	End Sequence
	
	RestArea(aAreaZNF)

Return lOk

/*/{Protheus.doc} GrvOthers
Função para gravar outras informações que não fazem parte do model.
@author Pualo Felipe Silva
@since 19/07/2018
@version 1.0
@return Nil.
@param oModel, object, modelo.
@param cID, characters, ID do model.
@param cAlias, characters, alias.
@type function
/*/
Static Function GrvOthers(oModel,cID,cAlias)

	Local nOper	:= oModel:GetOperation()
	
	If nOper == MODEL_OPERATION_INSERT .And. cID == "DETAIL"
		FWMsgRun(,{|| EstEndIt(oModel)},"Processando","Estornando endereçamento dos itens...")
	EndIf

Return

/*/{Protheus.doc} EstEndIt
Função para estornar o endereçamento do item.
@author Pualo Felipe Silva
@since 19/07/2018
@version 1.0
@return Nil.
@param oModel, object, modelo.
@type function
/*/
Static Function EstEndIt(oModel)

	Local aCabSDB		:= {}
	Local aItSDB		:= {}
	Local aSD3			:= {}
	Local cTM			:= SuperGetMV("MV_XTMENF",.F.,"")
	Private lMsErroAuto	:= .F.

	Begin Sequence
		If !oModel:IsDeleted()
			lMsErroAuto	:= .F.
//			Apenas se não houver saldo necessário para estorno do endereçamento.
			If oModel:GetValue("ZNF_QTDMOV") > 0
//				Prepara array para moviemntação interna.
				aSD3 := {{"D3_EMISSAO"	,oModel:GetValue("ZNF_DTEND ")		,Nil};
						,{"D3_DOC"		,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil};
						,{"D3_TM"		,cTM								,Nil};
						,{"D3_COD"		,oModel:GetValue("ZNF_COD")			,Nil};
						,{"D3_LOCAL"	,oModel:GetValue("ZNF_LOCAL")		,Nil};
						,{"D3_LOCALIZ"	,oModel:GetValue("ZNF_ENDER")		,Nil};
						,{"D3_LOTECTL"	,oModel:GetValue("ZNF_LOTE")		,Nil};
						,{"D3_QUANT"	,oModel:GetValue("ZNF_QTDMOV")		,Nil}}
				
//				Realiza movimentação de entrada em estoque.
				MSExecAuto({|x,y| Mata240(x,y)},aSD3,3)
//				Verifica a ocorrência de erro.
				If lMsErroAuto
					MostraErro()
					Break
				Else
//					Preenche NUMSEQ para posterior estorno.
					oModel:LoadValue("ZNF_NSMOV",SD3->D3_NUMSEQ)

//					Preenche os dados para endereçamento do movimento interno.
					aCabSDB :=  {{"DA_PRODUTO"	,oModel:GetValue("ZNF_COD")		,Nil};
								,{"DA_NUMSEQ"	,oModel:GetValue("ZNF_NSMOV")	,Nil}}
					aItSDB :=  {{{"DB_ITEM"		,oModel:GetValue("ZNF_ITEND")	,Nil};
								,{"DB_LOCALIZ"	,oModel:GetValue("ZNF_ENDER")	,Nil};
								,{"DB_LOTECTL"	,oModel:GetValue("ZNF_LOTE")	,Nil};
								,{"DB_QUANT"	,oModel:GetValue("ZNF_QTDMOV")	,Nil};
								,{"DB_DATA"		,oModel:GetValue("ZNF_DTEND ")	,Nil}}}
//					Realiza o endereçamento do movimento interno.
					MsExecAuto({|x,y,z| Mata265(x,y,z)},aCabSDB,aItSDB,3)
//					Verifica a ocorrência de erro.
					If lMsErroAuto
						MostraErro()
						Break
					EndIf
				EndIf
			EndIf
//			Preenche os dados para estorno do endereçamento da nota fiscal de origem.
			aCabSDB :=  {{"DA_PRODUTO"	,oModel:GetValue("ZNF_COD")	,Nil};
						,{"DA_NUMSEQ"	,oModel:GetValue("ZNF_NSNFE")	,Nil}}
			aItSDB :=  {{{"DB_ITEM"		,oModel:GetValue("ZNF_ITEND")	,Nil};
						,{"DB_ESTORNO"	,"S"							,Nil};
						,{"DB_LOCALIZ"	,oModel:GetValue("ZNF_ENDER")	,Nil};
						,{"DB_LOTECTL"	,oModel:GetValue("ZNF_LOTE")	,Nil};
						,{"DB_DATA"		,oModel:GetValue("ZNF_DTEND ")	,Nil}}}
//			Realiza o estorno do endereçamento da nota fiscal de origem.
			MsExecAuto({|x,y,z| Mata265(x,y,z)},aCabSDB,aItSDB,4)
//			Verifica a ocorrência de erro.
			If lMsErroAuto
				MostraErro()
				Break
			EndIf
		EndIf
	Recover
		DisarmTransation()
		Help(,,"ErrForm",,"Devido a erros no programa, o formulário não será salvo.",1,0)
	End Sequence

Return