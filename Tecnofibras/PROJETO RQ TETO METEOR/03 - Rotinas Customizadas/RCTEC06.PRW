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

User Function RCTEC06()

	Local   oBrowse
	Local aArea    := GetArea()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias('SBM')
	oBrowse:SetDescription( "Grupos de Produtos" )
	oBrowse:SetMenuDef("RCTEC06")
	//oBrowse:AddFilter('Status',"SF1->F1_STATUS = 'Z'",.T.,.T.)
	oBrowse:Activate()
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RCTEC06' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Receber'    ACTION 'VIEWDEF.RCTEC06' OPERATION 4 ACCESS 0

Return(aRotina)

Static Function ModelDef()

	// Declara um Objeto Model ( Conjunto de estruturas )
	Local oModel

	// Cria os conjuntos de estruturas e campos ( Ira criar campos com suas validações conforme o SX3 )
	Private oStMain  := FWFormStruct(1,'SBM')
	Private oStAba1  := FWFormStruct(1,'SB1')
	Private oStAba2 := FWFormStruct(1,'SB1')
	Private oStAba3 := FWFormStruct(1,'SB1')
	Private oStAba4 := FWFormStruct(1,'SB1')
	Private oStAba5 := FWFormStruct(1,'SB1')

	// Cria o Model com noe MD_VERBA e guarda no objeto

	oModel := MPFormModel():New('PETEC06'        ,{|oModel| BeforeCMdl(oModel)},{|oModel|sfTudoOk(oModel)})

	// Associa os objetos visuais criados com as estruturas criadas, desta forma ira criar os campos conforme as estrutura.
	oModel:addFields('MASTER' ,/*cOwner*/  ,oStMain   ,/*bLinePre*/                          ,/*bLinePost*/,/*bPreVal*/, /*bPost*/                          ,/*BLoad*/ )
	
	oModel:AddGrid('ABA1', 'MASTER', oStAba1,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/ )
	oModel:AddGrid('ABA2', 'MASTER', oStAba2,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/)
	oModel:AddGrid('ABA3', 'MASTER', oStAba3,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/)
	oModel:AddGrid('ABA4', 'MASTER', oStAba4,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/)
	oModel:AddGrid('ABA5', 'MASTER', oStAba5,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/)

	// Cria chave primaria do cadastro principal.
	oModel:SetPrimaryKey( { } )

	// Cria descrições para os objetos, para que seja possivel a chamada pelo nome posteriormente.
	oModel:SetDescription('Teto Meteor')
	oModel:getModel('MASTER' ):SetDescription('Master')
	oModel:getModel('ABA1' ):SetDescription('Aba1')
	oModel:getModel('ABA2' ):SetDescription('Aba2')
	oModel:getModel('ABA3' ):SetDescription('Aba3')
	oModel:getModel('ABA4' ):SetDescription('Aba4')
	oModel:getModel('ABA5' ):SetDescription('Aba5')


	// Faz o relacionamento entre as estruturas, o fonte ira realizar as validações necessarias por este relacionamento.

	oModel:SetRelation( 'ABA1'	 , { { 'B1_FILIAL', 'BM_FILIAL' } ,{ 'B1_GRUPO', 'BM_GRUPO' } } , SB1->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'ABA2'	 , { { 'B1_FILIAL', 'BM_FILIAL' } ,{ 'B1_GRUPO', 'BM_GRUPO' } } , SB1->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'ABA3'	 , { { 'B1_FILIAL', 'BM_FILIAL' } ,{ 'B1_GRUPO', 'BM_GRUPO' } } , SB1->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'ABA4'	 , { { 'B1_FILIAL', 'BM_FILIAL' } ,{ 'B1_GRUPO', 'BM_GRUPO' } } , SB1->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'ABA5'	 , { { 'B1_FILIAL', 'BM_FILIAL' } ,{ 'B1_GRUPO', 'BM_GRUPO' } } , SB1->( IndexKey( 1 ) ) )


	oModel:SetVldActivate( { |oModel| sfValAtiva( oModel ) } )

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel('RCTEC06')
	Local cSolicit := ""
	Private oView	 := FWFormView():New()
	Private oStMain  := FWFormStruct(2,'SBM',{ |cCampo| STRUMASTER(cCampo)   })
	Private oStAba1  := FWFormStruct(2,'SB1',{ |cCampo| STRUDETAIL(cCampo,1) })
	Private oStAba2 := FWFormStruct(2,'SB1',{ |cCampo| STRUDETAIL(cCampo,1) })
	Private oStAba3 := FWFormStruct(2,'SB1',{ |cCampo| STRUDETAIL(cCampo,1) })
	Private oStAba4 := FWFormStruct(2,'SB1',{ |cCampo| STRUDETAIL(cCampo,1) })
	Private oStAba5 := FWFormStruct(2,'SB1',{ |cCampo| STRUDETAIL(cCampo,1) })

	oView:SetModel(oModel)
	// Seta a view com o model criado anteriormente

	// Cria os objetos com os campos existentes nas esturturas
	oView:AddField('VIEW_SBM' , oStMain	,'MASTER'	) // objeto filds, ( Grids e Says )
	oView:AddGrid('VIEW_SB1'  , oStAba1	,'ABA1'	) // objeto grid
	oView:AddGrid('VIEW_FILHO2',oStAba2,'ABA2')
	oView:AddGrid('VIEW_FILHO3',oStAba2,'ABA3')
	oView:AddGrid('VIEW_FILHO4',oStAba2,'ABA4')
	oView:AddGrid('VIEW_FILHO5',oStAba2,'ABA5')

	//oView:AddOtherObject('VIEW_RODAPE',{|oPanel|fRodape(oPanel)})

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 50 )
	//oView:CreateHorizontalBox( 'RODAPE'  , 10 )

	oView:CreateFolder('PASTA_ABAS', 'INFERIOR')
    oView:AddSheet('PASTA_ABAS', 'ABA_1', "RQ 08.103")
    oView:AddSheet('PASTA_ABAS', 'ABA_2', "RQ 08.317")
	oView:AddSheet('PASTA_ABAS', 'ABA_3', "RQ 08.319")
	oView:AddSheet('PASTA_ABAS', 'ABA_4', "RQ 08.358")
	oView:AddSheet('PASTA_ABAS', 'ABA_5', "RQ 08.549")

    oView:CreateHorizontalBox('ITENS1', 100, , , 'PASTA_ABAS', 'ABA_1')
    oView:CreateHorizontalBox('ITENS2', 100, , , 'PASTA_ABAS', 'ABA_2')
	oView:CreateHorizontalBox('ITENS3', 100, , , 'PASTA_ABAS', 'ABA_3')
	oView:CreateHorizontalBox('ITENS4', 100, , , 'PASTA_ABAS', 'ABA_4')
	oView:CreateHorizontalBox('ITENS5', 100, , , 'PASTA_ABAS', 'ABA_5')

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SBM'  , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_SB1'	, 'ITENS1' )
    oView:SetOwnerView('VIEW_FILHO2', 'ITENS2')
	oView:SetOwnerView('VIEW_FILHO3', 'ITENS3')
	oView:SetOwnerView('VIEW_FILHO4', 'ITENS4')
	oView:SetOwnerView('VIEW_FILHO5', 'ITENS5')
	//oView:SetOwnerView( 'VIEW_RODAPE'  , 'RODAPE')

	//oView:AddIncrementField( 'ABA1', 'D1_ITEM' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView

Static Function sfValAtiva(oModel)
	Local _lRet      := .T.
	Local _nOpc      := oModel:GetOperation()
	Local oModel     := FWModelActive()
	Local oModelM
	Local oModelSD1
	Local aSaveLines

Return(_lRet)

Static Function sfTudoOk(oModel)
	Local aArea		 := GetArea()
	Local _lRet		 := .T.
	Local nOperation := oModel:GetOperation()
	Local oModel     := FWModelActive()
	Local oModelM  := oModel:GetModel("MASTER")
	Local oModel1  := oModel:GetModel("ABA1")
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
	Local oModelM  := oModel:GetModel("MASTER")
	Local oModel1	 := oModel:GetModel('ABA1')
	Default cCpo     := ""

Return(lRet)

Static Function sfLinPos(oModel)
	Local lRet	     := .T.
Return(lRet)

//Retorno de campos que serao usados

Static Function STRUMASTER(cCampo)
	Local lRet	  := .F.

	DO CASE
	CASE cCampo = "BM_GRUPO" ; RETURN .T.
	CASE cCampo = "BM_DESC" ; RETURN .T.
	//CASE cCampo = "F1_FORNECE" ; RETURN .T.
	//CASE cCampo = "F1_LOJA" ; RETURN .T.
	//CASE cCampo = "F1_SOLICIT" ; RETURN .T.
	//CASE cCampo = "F1_EMISSAO" ; RETURN .T.
	//CASE cCampo = "F1_EST" ; RETURN .T.
	//CASE cCampo = "F1_XRECEB" ; RETURN .T.
	//CASE cCampo = "F1_NOMEFOR" ; RETURN .T.
	//CASE cCampo = "F1_STATUS"  ; RETURN .T.
	ENDCASE
Return(lRet)

//Campos usados no browse

Static Function STRUDETAIL(cCampo)
	Local lRet	:= .F.
	DO CASE
	CASE cCampo = "B1_COD" ; RETURN .T.
	CASE cCampo = "B1_DESC" ; RETURN .T.
	CASE cCampo = "B1_LOCPAD" ; RETURN .T.
	//CASE cCampo = "D1_SEGUM" ; RETURN .T.
	//CASE cCampo = "D1_QUANT" ; RETURN .T.
	//CASE cCampo = "D1_VUNIT" ; RETURN .T.
	//CASE cCampo = "D1_TOTAL" ; RETURN .T.
	//CASE cCampo = "D1_CONTA" ; RETURN .T.
	ENDCASE
Return(lRet)

Static Function BeforeCMdl(oModel)
	Local lRet	:= .T.
Return(lRet)


// FUNCAO PARA BUSCAR O NOME DO solicitante NA SC1
/*USER FUNCTION nSolicit()

	DBSELECTAREA("SD1")
	DBSETORDER(1)
	DBGOTOP()
	IF DBSEEK(xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

		cPedido := SD1->D1_PEDIDO

		DBSELECTAREA("SC7")
		DBSETORDER(3)
		DBGOTOP()
		IF DBSEEK(xFilial("SF1")+SF1->F1_FORNECE+SF1->F1_LOJA+cPedido)

			cNumSc := SC7->C7_NUMSC
			cItemSc := SC7->C7_ITEMSC

			DBSELECTAREA("SC1")
			DBSETORDER(1)
			DBGOTOP()
			IF DBSEEK(xFilial("SF1")+cNumSc+cItemSc)

				IF !EMPTY(SC1->C1_SOLICIT)

					cSolicit := SC1->C1_SOLICIT

					RECLOCK("SF1", .F.)
					SF1->F1_SOLICIT = cSolicit
					MSUNLOCK()
				ENDIF

			ENDIF
		ENDIF
	ENDIF


RETURN*/
