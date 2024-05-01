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
	oBrowse:addLegend({|| SF1->F1_STATUS = 'A'}        ,'GREEN'  ,'Classificado')
	oBrowse:addLegend({|| SF1->F1_STATUS = 'Z'}        ,'BR_CINZA'  ,'Pendente de Recebimento')
	oBrowse:addLegend({|| SF1->F1_STATUS = 'X'}        ,'BLACK'  ,'Recebimento OK')
	oBrowse:addLegend({|| SF1->F1_STATUS = 'Y'}        ,'RED'  ,'Não Conformidade no Recebimento')
	oBrowse:Activate()

Return()

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RCTEC05' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.KHR05A07' OPERATION 3 ACCESS 0
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
	//oModel:getModel('RODAPE'):SetDescription('Rodape')

	//oModel:GetModel('SD1DETAIL'):SetUniqueLine({"D1_FILIAL","D1_DOC","D1_SERIE"})  //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}

	// Faz o relacionamento entre as estruturas, o fonte ira realizar as validações necessarias por este relacionamento.

	oModel:SetRelation( 'SD1DETAIL'	 , { { 'D1_FILIAL', 'F1_FILIAL' } ,{ 'D1_EMISSAO', 'F1_EMISSAO' }, { 'D1_DOC', 'F1_DOC' }, { 'D1_SERIE', 'F1_SERIE' },{ 'D1_FORNECE', 'F1_FORNECE' },{ 'D1_LOJA', 'F1_LOJA' }    } , SD1->( IndexKey( 3 ) ) )
	//oStrSD1:SetProperty("F1_STATUS",MODEL_FIELD_VALID, .T.)
	//oStrSF1:SetProperty("D1_COD"  ,MODEL_FIELD_VALID, .T.)
	//oStrSZD:SetProperty("F1_STATUS",MODEL_FIELD_VALID, {|oModel|sfVldCpo(oModel,"F1_STATUS")})
	//oStrSZC:SetProperty("D1_DOC"  ,MODEL_FIELD_VALID, {|oModel|sfVldCpo(oModel,"D1_DOC"  )})

	oModel:SetVldActivate( { |oModel| sfValAtiva( oModel ) } )
	//oModel:Activate()

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel('RCTEC05')
	Private oView	 := FWFormView():New()
	Private oStrSF1  := FWFormStruct(2,'SF1',{ |cCampo| STRUMASTER(cCampo)   })
	Private oStrSD1  := FWFormStruct(2,'SD1',{ |cCampo| STRUDETAIL(cCampo,1) })
	//Private oStrROD   := FWFormStruct(2,'SD1',{ |cCampo| STRUDETAIL(cCampo,2) })

	oView:SetModel(oModel)
	// Seta a view com o model criado anteriormente

	// Cria os objetos com os campos existentes nas esturturas
	oView:AddField('VIEW_SF1' , oStrSF1	,'SF1MASTER'	) // objeto filds, ( Grids e Says )
	oView:AddGrid('VIEW_SD1'  , oStrSD1	,'SD1DETAIL'	) // objeto grid
	//oView:AddField( 'VIEW_RODAPE', oStrROD, 'RODAPE' )

	oView:AddOtherObject('VIEW_RODAPE',{|oPanel|fRodape(oPanel)})

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 30 )
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

Static Function sfIncluiHi()
	Local lRet := .T.
	Private cGetHist := space(2000)

	oDlgHist := MSDialog():New(1,1,250,400,'Inclusão Historico',,,,,CLR_BLACK,CLR_WHITE,,,.t.)

	oSay     :=TSay():New(001,001,{|| 'Historico:'},oDlgHist,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	oGetHist :=TMultiget():New(01,01,{|u|if(Pcount()>0,cGetHist:=u,cGetHist)},oDlgHist,200,100,,,,,,.T.,,,,,,,,,,,.T.,,,,)

	oBtnESC := SButton():New(110, 145, 2,{||lRet := IncluiSZK("1")}, oDlgHist, .T.,,)
	oBtnOk  := SButton():New(110, 175, 1,{||lRet := IncluiSZK("2")}, oDlgHist, .T.,,)

	oDlgHist:Activate()

Return(lRet)

Static Function sfLinPos(oModel)

	Local lRet	     := .T.

Return(lRet)

Static Function IncluiSZK(mvTipo)
	Local lRet     := .T.
	Default mvTipo := ""

	If mvTipo == "1"
		lRet     := .F.
		Close(oDlgHist)
		If Empty(cGetHist)
			lRet := .F.
		EndIf
	ElseIf mvTipo == "2"
		If Empty(cGetHist)
			lRet := .F.
		Else
			cHora := TIME()
			RecLock("SZK",.T.)
			SZK->ZK_TABORI  := "SA1"
			SZK->ZK_RECORI	:= SA1->(recno())
			SZK->ZK_KEY     := "01"+SF1->ZC_CLIENTE + SF1->ZC_LOJA
			SZK->ZK_USER    := cUserName
			SZK->ZK_DATA    := dDatabase
			SZK->ZK_HORA    := SubStr(cHora,1,5)
			SZK->ZK_HIST    := cGetHist
			SZK->ZK_ORIGEM  := "Protheus"
			SZK->ZK_CONTRAT  := SF1->ZC_NUM
			If SZK->(FieldPos("ZK_ZCARCRM")) > 0
				SZK->ZK_ZCARCRM := dToc(dDataBase) + " - " + Time()
			EndIf
			SZK->ZK_CLIENTE := SF1->ZC_CLIENTE
			SZK->ZK_LOJA    := SF1->ZC_LOJA
			SZK->(MsUnlock())
		EndIf
		Close(oDlgHist)
	Else

	EndIf

Return(lRet)

//Retorno de campos que serao usados

Static Function STRUMASTER(cCampo)

	Local lRet	  := .T.


Return(lRet)

//Campos usados no browse

Static Function STRUDETAIL(cCampo)

	Local lRet	:= .T.

	//	If ((Alltrim(cCampo) == "ZD_QTDE") .Or. (Alltrim(cCampo) == "ZD_VLRUNIT") .Or. (Alltrim(cCampo) == "ZD_TOTAL") .Or. (Alltrim(cCampo) == "ZD_DATAADT")) //.And. (SF1->ZC_TIPO <> "R")
	//		lRet	:= .F.
	//		Conout(cCampo)
	//	EndIf

Return(lRet)

Static Function BeforeCMdl(oModel)
	Local lRet	:= .T.
	/*
	Local oModel     := FWModelActive()
	Local oModelSF1  := oModel:GetModel("SF1MASTER")
	Local oModelSC7	 := oModel:GetModel('SC7DETAIL')
	//If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oModel:LMODIFY := .T.
	//EndIf

	oModelSC7:RemoveField( 'ZD_VLRUNIT' )
	//Alert("Teste")
	*/
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

 //MUDA O STATUS PARA X (Recebimento OK) E PREENCHE O RECEBIMENTO DO ALMOX
		
	IF SF1->F1_STATUS <> 'X'
		RECLOCK("SF1", .F.)
		SF1->F1_STATUS = "X"
		SF1->F1_XRECEB = Date()
		MSUNLOCK()
	ELSE
		MSGSTOP("NOTA JA RECEBIDA")
	ENDIF

RETURN

USER FUNCTION CancReceb()

	IF SF1->F1_STATUS <> 'Y'
		RECLOCK("SF1", .F.)
		SF1->F1_STATUS = "Y"
		SF1->F1_XRECEB = STOD("")
		MSUNLOCK()
	ELSE
		MSGSTOP("NOTA JA ESTA NO STATUS DE NAO CONFORMIDADE")
	ENDIF

RETURN
