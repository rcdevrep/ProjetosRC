#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'RWMAKE.CH'

// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTEC02 - CLASSIFICAR NOTAS PENDENTES 
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024

User Function RCTEC05()

	Local   oBrowse

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias('SF1')
	oBrowse:SetDescription( "Notas Pendentes Recebimento" )
	oBrowse:SetMenuDef("RCTEC05")

	//Adiciona Leganda
	oBrowse:addLegend({|| SF1->F1_STATUS = 'A'}        ,'GREEN'  ,'Finalizada')
	oBrowse:addLegend({|| SF1->F1_STATUS = 'Z'}        ,'BR_CINZA'  ,'Pendente de Recebimento')
	//oBrowse:addLegend({|| SF1->F1_STATUS = 'X'}        ,'BLACK'  ,'Recebimento OK')
	oBrowse:addLegend({|| SF1->F1_STATUS = 'Y'}        ,'RED'  ,'Não Conformidade no Recebimento')
	oBrowse:Activate()

Return()

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RCTEC05' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Receber'    ACTION 'VIEWDEF.RCTEC05' OPERATION 4 ACCESS 0

Return(aRotina)

Static Function ModelDef()

	// Declara um Objeto Model ( Conjunto de estruturas )
	Local oModel

	// Cria os conjuntos de estruturas e campos ( Ira criar campos com suas validações conforme o SX3 )
	Private oStrSF1  := FWFormStruct(1,'SF1')
	Private oStrSD1  := FWFormStruct(1,'SD1')

	// Cria o Model com noe MD_VERBA e guarda no objeto

	oModel := MPFormModel():New('PETEC05'        ,{|oModel| BeforeCMdl(oModel)},{|oModel|sfTudoOk(oModel)})

	// Associa os objetos visuais criados com as estruturas criadas, desta forma ira criar os campos conforme as estrutura.
	oModel:addFields('SF1MASTER' ,/*cOwner*/  ,oStrSF1   ,/*bLinePre*/                          ,/*bLinePost*/,/*bPreVal*/, /*bPost*/                          ,/*BLoad*/ )
	oModel:AddGrid(  'SD1DETAIL', 'SF1MASTER', oStrSD1  ,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/ )

	// Cria chave primaria do cadastro principal.
	oModel:SetPrimaryKey( { "F1_FILIAL", "F1_DOC"} )

	// Cria descrições para os objetos, para que seja possivel a chamada pelo nome posteriormente.
	oModel:SetDescription('Recebimento de Notas')
	oModel:getModel('SF1MASTER' ):SetDescription('Cabeçalho')
	oModel:getModel('SD1DETAIL' ):SetDescription('Itens')

	// Faz o relacionamento entre as estruturas, o fonte ira realizar as validações necessarias por este relacionamento.

	oModel:SetRelation( 'SD1DETAIL'	 , { { 'D1_FILIAL', 'F1_FILIAL' } ,{ 'D1_EMISSAO', 'F1_EMISSAO' }, { 'D1_DOC', 'F1_DOC' }, { 'D1_SERIE', 'F1_SERIE' },{ 'D1_FORNECE', 'F1_FORNECE' },{ 'D1_LOJA', 'F1_LOJA' }    } , SD1->( IndexKey( 3 ) ) )

	oModel:SetVldActivate( { |oModel| sfValAtiva( oModel ) } )

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel('RCTEC05')
	Private oView	 := FWFormView():New()
	Private oStrSF1  := FWFormStruct(2,'SF1',{ |cCampo| STRUMASTER(cCampo)   })
	Private oStrSD1  := FWFormStruct(2,'SD1',{ |cCampo| STRUDETAIL(cCampo,1) })

	oView:SetModel(oModel)
	// Seta a view com o model criado anteriormente

	// Cria os objetos com os campos existentes nas esturturas
	oView:AddField('VIEW_SF1' , oStrSF1	,'SF1MASTER'	) // objeto filds, ( Grids e Says )
	oView:AddGrid('VIEW_SD1'  , oStrSD1	,'SD1DETAIL'	) // objeto grid

	oView:AddOtherObject('VIEW_RODAPE',{|oPanel|fRodape(oPanel)})

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )
	oView:CreateHorizontalBox( 'RODAPE'  , 10 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SF1'  , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_SD1'	, 'INFERIOR' )
	oView:SetOwnerView( 'VIEW_RODAPE'  , 'RODAPE')

	oView:AddIncrementField( 'SD1DETAIL', 'D1_ITEM' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView

Static Function sfValAtiva(oModel)
	Local _lRet      := .T.
	Local _nOpc      := oModel:GetOperation()
	Local oModel     := FWModelActive()
	Local oModelSF1
	Local oModelSD1
	Local aSaveLines

Return(_lRet)

Static Function sfTudoOk(oModel)
	Local aArea		 := GetArea()
	Local _lRet		 := .T.
	Local nOperation := oModel:GetOperation()
	Local oModel     := FWModelActive()
	Local oModelSF1  := oModel:GetModel("SF1MASTER")
	Local oModelSC7  := oModel:GetModel("SD1DETAIL")
	Local aSaveLines := FWSaveRows()

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return(_lRet)

//Validação da linha
Static Function sfLinPre(oModel)
	Local lRet       := .T.
Return(lRet)

Static Function sfVldCpo(oModel,cCpo)

	Local lRet	     := .T.
	Local oModel     := FWModelActive()
	Local oModelSF1  := oModel:GetModel("SF1MASTER")
	Local oModelSC7	 := oModel:GetModel('SD1DETAIL')
	Default cCpo     := ""

Return(lRet)

Static Function sfLinPos(oModel)
	Local lRet	     := .T.
Return(lRet)

//Retorno de campos que serao usados

Static Function STRUMASTER(cCampo)
	Local lRet	  := .F.

	DO CASE
	CASE cCampo = "F1_DOC" ; RETURN .T.
	CASE cCampo = "F1_SERIE" ; RETURN .T.
	CASE cCampo = "F1_FORNECE" ; RETURN .T.
	CASE cCampo = "F1_LOJA" ; RETURN .T.
	CASE cCampo = "F1_EMISSAO" ; RETURN .T.
	CASE cCampo = "F1_EST" ; RETURN .T.
	CASE cCampo = "F1_XRECEB" ; RETURN .T.
	CASE cCampo = "F1_NOMEFOR" ; RETURN .T.
	ENDCASE
Return(lRet)

//Campos usados no browse

Static Function STRUDETAIL(cCampo)
	Local lRet	:= .F.
	DO CASE
	CASE cCampo = "D1_ITEM" ; RETURN .T.
	CASE cCampo = "D1_COD" ; RETURN .T.
	CASE cCampo = "D1_UM" ; RETURN .T.
	CASE cCampo = "D1_QUANT" ; RETURN .T.
	CASE cCampo = "D1_VUNIT" ; RETURN .T.
	CASE cCampo = "D1_TOTAL" ; RETURN .T.
	CASE cCampo = "D1_CONTA" ; RETURN .T.
	ENDCASE
Return(lRet)

Static Function BeforeCMdl(oModel)
	Local lRet	:= .T.
Return(lRet)

STATIC FUNCTION fRodape(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	oBtnOk := TButton():New(001,90 , "Confirmar Recebimento", oPanel, {|| U_ConfReceb()},nLargBtn)
	oBtnCan := TButton():New(001,140 , "Cancelar Recebimento", oPanel, {|| U_CancReceb()},nLargBtn)

RETURN

USER FUNCTION ConfReceb()
	//PARAMETRO COM OS USUARIOS DA PORTARIA
	Local cUsrPor := SuperGetMV("MV_PORTARI", .F., " ")

	IF !(__cUserId $ cUsrPor)

		U_EXEC103()
		//MUDA O STATUS PARA X (Recebimento OK) E PREENCHE O RECEBIMENTO DO ALMOX

		/*IF SF1->F1_STATUS <> 'X'
			RECLOCK("SF1", .F.)
			SF1->F1_STATUS = "X"
			SF1->F1_XRECEB = Date()
			MSUNLOCK()
			MSGALERT("REGISTRO ALTERADO COM SUCESSO")
		ELSE
			MSGSTOP("NOTA JA RECEBIDA")
		ENDIF*/
	ELSE
		MSGSTOP("USUÁRIO SEM PERMISSÃO - RCTEC05")
	ENDIF
RETURN

USER FUNCTION CancReceb()
	//PARAMETRO COM OS USUARIOS DA PORTARIA
	Local cUsrPor := SuperGetMV("MV_PORTARI", .F., " ")

	IF !(__cUserId $ cUsrPor)

		IF SF1->F1_STATUS <> 'Y'
			RECLOCK("SF1", .F.)
			SF1->F1_STATUS = "Y"
			SF1->F1_XRECEB = Date()
			MSUNLOCK()
			MSGALERT("REGISTRO ALTERADO COM SUCESSO")
		ELSE
			MSGSTOP("NOTA JA ESTA NO STATUS DE NAO CONFORMIDADE")
		ENDIF
	ELSE
		MSGSTOP("USUÁRIO SEM PERMISSÃO - RCTEC05")
	ENDIF
RETURN

USER FUNCTION EXEC103()

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local aItensRat := {}
	Local aCodRet := {}
	Local nOpc := 4 
	Local cNum := ""
	Local nI := 0
	Local nX := 0
	Local nReg := 1

	Conout("Inicio Classificacao RCTEC05: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "COM"

	DBSELECTAREA("SD1")
	DBSETORDER(1)
	DBGOTOP()
	DBSEEK(xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

	cNum := SF1->F1_DOC
	//cNum := GetSxeNum("SF1","F1_DOC") 
	//SF1->(dbSetOrder(1)) 
	//While SF1->(dbSeek(xFilial("SF1")+cNum)) 
	//ConfirmSX8() 
	//cNum := GetSxeNum("SF1","F1_DOC") 
	//EndDo

	//Cabeçalho
	aadd(aCab,{"F1_TIPO" , SF1->F1_TIPO ,NIL})
	aadd(aCab,{"F1_FORMUL" ,SF1->F1_FORMUL ,NIL})
	aadd(aCab,{"F1_DOC" ,cNum ,NIL})
	aadd(aCab,{"F1_SERIE" ,SF1->F1_SERIE ,NIL})
	aadd(aCab,{"F1_EMISSAO" ,DDATABASE ,NIL})
	aadd(aCab,{"F1_DTDIGIT" ,DDATABASE ,NIL})
	aadd(aCab,{"F1_FORNECE" ,SF1->F1_FORNECE ,NIL})
	aadd(aCab,{"F1_LOJA" ,SF1->F1_LOJA ,NIL})
	aadd(aCab,{"F1_ESPECIE" ,SF1->F1_ESPECIE ,NIL})
	aadd(aCab,{"F1_COND" ,SF1->F1_COND ,NIL})
	aadd(aCab,{"F1_DESPESA" ,SF1->F1_DESPESA,NIL})
	aadd(aCab,{"F1_DESCONT" ,SF1->F1_DESCONT,Nil})
	aadd(aCab,{"F1_SEGURO" ,SF1->F1_SEGURO,Nil})
	aadd(aCab,{"F1_FRETE" ,SF1->F1_FRETE,Nil})
	aadd(aCab,{"F1_MOEDA" ,SF1->F1_MOEDA,Nil})
	aadd(aCab,{"F1_TXMOEDA" ,SF1->F1_TXMOEDA,Nil})
	aadd(aCab,{"F1_STATUS" ,SF1->F1_STATUS,Nil})

	//Itens
	//For nX := 1 To 1
	aItem := {}
	WHILE !SD1->(Eof()) .AND. SF1->F1_DOC = SD1->D1_DOC .AND. SF1->F1_SERIE = SD1->D1_SERIE .AND. SF1->F1_FORNECE = SD1->D1_FORNECE .AND. SF1->F1_LOJA = SD1->D1_LOJA
		aadd(aItem,{"D1_ITEM" ,SD1->D1_ITEM,NIL})
		aadd(aItem,{"D1_COD" ,SD1->D1_COD,NIL})
		aadd(aItem,{"D1_UM" ,SD1->D1_UM,NIL})
		aadd(aItem,{"D1_QUANT" ,SD1->D1_QUANT,NIL}) 
		aadd(aItem,{"D1_VUNIT" ,SD1->D1_VUNIT,NIL}) 
		aadd(aItem,{"D1_TOTAL" ,SD1->D1_TOTAL,NIL})
		aadd(aItem,{"D1_CONTA" ,SD1->D1_CONTA,NIL})
		aadd(aItem,{"D1_TES" ,SD1->D1_TES,NIL})
		aadd(aItem,{"D1_CF" ,SD1->D1_CF,NIL})
		aadd(aItem,{"D1_LOTEFOR" ,SD1->D1_LOTEFOR,NIL})
		aadd(aItem,{"D1_VLDLOTE" ,SD1->D1_VLDLOTE,NIL})
		aadd(aItem,{"D1_LOTECTL" ,SD1->D1_LOTECTL,NIL})
		aadd(aItem,{"D1_IPI" ,SD1->D1_IPI,NIL})
		aadd(aItem,{"D1_PICM" ,SD1->D1_PICM,NIL})
		aadd(aItem,{"D1_FORNECE" ,SD1->D1_FORNECE,NIL})
		aadd(aItem,{"D1_LOJA" ,SD1->D1_LOJA,NIL})
		aadd(aItem,{"D1_DOC" ,SD1->D1_DOC,NIL})
		aadd(aItem,{"D1_EMISSAO" ,SD1->D1_EMISSAO,NIL})
		aadd(aItem,{"D1_DTDIGIT" ,SD1->D1_DTDIGIT,NIL})
		aadd(aItem,{"D1_VALICM" ,SD1->D1_VALICM,NIL})
		aadd(aItem,{"D1_ITEMCTA" ,SD1->D1_ITEMCTA,NIL})
		aadd(aItem,{"D1_SERIE" ,SD1->D1_SERIE,NIL})
		aadd(aItem,{"D1_CC" ,SD1->D1_CC,NIL})
		aadd(aItem,{"D1_PEDIDO" ,SD1->D1_PEDIDO,NIL})
		aadd(aItem,{"D1_ITEMPC" ,SD1->D1_ITEMPC,NIL})
		aadd(aItem,{"D1_LOCAL" ,SD1->D1_LOCAL,NIL})
		aadd(aItem,{"D1_GRUPO" ,SD1->D1_GRUPO,NIL})
		aadd(aItem,{"D1_TIPO" ,SD1->D1_TIPO,NIL})
		aAdd(aItens,aItem)
	SD1->(dbskip())
	ENDDO
	//Next nX

	/*
	//Rateio de Centro de Custo
	aItem := {}
	aAdd(aItensRat, Array(2))
	aItensRat[Len(aItensRat)][1] := "0001"
	aItensRat[Len(aItensRat)][2] := {}

	aAdd(aItem, {"DE_FILIAL" , xFilial("SDE") , Nil})
	aAdd(aItem, {"DE_ITEM" , StrZero(1,TamSx3("DE_ITEM")[1]) , Nil})
	aAdd(aItem, {"DE_DOC" , cNum , Nil})
	aAdd(aItem, {"DE_SERIE" , "1" , Nil})
	aAdd(aItem, {"DE_FORNECE" , "001 " , Nil})
	aAdd(aItem, {"DE_LOJA" , "01" , Nil})
	aAdd(aItem, {"DE_ITEMNF" , "0001" , Nil})
	aAdd(aItem, {"DE_PERC" , 100 , Nil})
	aAdd(aItem, {"DE_CC" , "01" , Nil})
	aAdd(aItensRat[Len(aItensRat)][2], aClone(aItem))

	//Array contendo a informação se gera DIRF e os códigos de retenção por imposto
	aAdd( aCodRet, {01, "0297", 1, "..."} )
	aAdd( aCodRet, {02, "0297", 1, "IRR"} )
	aAdd( aCodRet, {03, "5979", 1, "PIS"} )
	aAdd( aCodRet, {04, "5960", 1, "COF"} )
	aAdd( aCodRet, {05, "5987", 1, "CSL"} ) */

	//3-Inclusão / 4-Classificação / 5-Exclusão
	MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc,/*aItensRat*/,/*aCodRet*/)

	If !lMsErroAuto
	ConOut(" NF Classificada RCTEC05: " + cNum)
	Else
	MostraErro()
	ConOut("Erro na Classificação RCTEC05")
	EndIf

	ConOut("Fim Classificacao RCTEC05: " + Time())

	RESET ENVIRONMENT

Return
