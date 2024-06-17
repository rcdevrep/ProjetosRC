#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'RWMAKE.CH'
#include "fileio.ch"
#INCLUDE "TOPCONN.CH"



// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTEC06 - PRODUCAO TETO METEOR 
// PROJETO - RQS TETO METEOR
// DATA - 10/06/2024

User Function RCTEC06()

	Local   oBrowse
	Local aArea    := GetArea()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias('SBM')
	oBrowse:SetDescription( "Grupos de Produtos" )
	oBrowse:SetMenuDef("RCTEC06")
	//oBrowse:AddFilter('Status',"SF1->F1_STATUS = 'Z'",.T.,.T.)
	//oBrowse:addLegend({|| SF1->F1_XSTATUS = 'Z'}        ,'BR_CINZA'  ,'pre classificacao/pendente recebimento')
	oBrowse:Activate()
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.RCTEC06' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.RCTEC06' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RCTEC06' OPERATION 2 ACCESS 0

Return(aRotina)

Static Function ModelDef()

	// Declara um Objeto Model ( Conjunto de estruturas )
	Local oModel

	// Cria os conjuntos de estruturas e campos ( Ira criar campos com suas validações conforme o SX3 )
	// TETO METEOR (ZT0)
	Private oStMain  := FWFormStruct(1,'SBM')
	// DIARIO DE BORDO (ZT1)
	Private oStAba1  := FWFormStruct(1,'SB1')
	// SETUP RQ 08.319 (ZT2) 
	Private oStAba2 := FWFormStruct(1,'SB1')
	// ACOMPANHAMENTO DE MOLDAGEM RQ 08.317 (ZT3)
	Private oStAba3 := FWFormStruct(1,'SB1')
	// REGISTRO DE DUREZA RQ 08.358 (ZT4)
	Private oStAba4 := FWFormStruct(1,'SB1')
	// RESERVA, DELETAR CASO NAO PRECISE
	Private oStAba5 := FWFormStruct(1,'SB1')

	// Cria o Model
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

	// CHAMADA DE FUNCOES DOS BOTOES DOS RODAPES DE CADA ABA
	oView:AddOtherObject('VIEW_RODAPE1',{|oPanel|fRodape1(oPanel)})
	oView:AddOtherObject('VIEW_RODAPE2',{|oPanel|fRodape2(oPanel)})
	oView:AddOtherObject('VIEW_RODAPE3',{|oPanel|fRodape3(oPanel)})
	oView:AddOtherObject('VIEW_RODAPE4',{|oPanel|fRodape4(oPanel)})

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 50 )
	//oView:CreateHorizontalBox( 'RODAPE'  , 10 )

	oView:CreateFolder('PASTA_ABAS', 'INFERIOR')
    oView:AddSheet('PASTA_ABAS', 'ABA_1', "Diario de Bordo")
    oView:AddSheet('PASTA_ABAS', 'ABA_2', "SETUP 08.319")
	oView:AddSheet('PASTA_ABAS', 'ABA_3', "Acomp. Moldagem 08.317")
	oView:AddSheet('PASTA_ABAS', 'ABA_4', "Reg. Dureza 08.358")
	oView:AddSheet('PASTA_ABAS', 'ABA_5', "VAZIO")

    oView:CreateHorizontalBox('ITENS1', 85, , , 'PASTA_ABAS', 'ABA_1')
	oView:CreateHorizontalBox('RODAPE1', 15, , , 'PASTA_ABAS', 'ABA_1')

    oView:CreateHorizontalBox('ITENS2', 85, , , 'PASTA_ABAS', 'ABA_2')
	oView:CreateHorizontalBox('RODAPE2', 15, , , 'PASTA_ABAS', 'ABA_2')

	oView:CreateHorizontalBox('ITENS3', 85, , , 'PASTA_ABAS', 'ABA_3')
	oView:CreateHorizontalBox('RODAPE3', 15, , , 'PASTA_ABAS', 'ABA_3')

	oView:CreateHorizontalBox('ITENS4', 85, , , 'PASTA_ABAS', 'ABA_4')
	oView:CreateHorizontalBox('RODAPE4', 15, , , 'PASTA_ABAS', 'ABA_4')

	oView:CreateHorizontalBox('ITENS5', 100, , , 'PASTA_ABAS', 'ABA_5')

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SBM'  , 'SUPERIOR' )
	
	oView:SetOwnerView( 'VIEW_SB1'	, 'ITENS1' )
	oView:SetOwnerView( 'VIEW_RODAPE1'  , 'RODAPE1')
    oView:SetOwnerView('VIEW_FILHO2', 'ITENS2')
	oView:SetOwnerView('VIEW_FILHO3', 'ITENS3')
	oView:SetOwnerView('VIEW_FILHO4', 'ITENS4')
	oView:SetOwnerView('VIEW_FILHO5', 'ITENS5')
	

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

STATIC FUNCTION fRodape1(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	oBtnInc := TButton():New(001,10 , "Incluir", oPanel, {|| U_ConfReceb()},nLargBtn)
	oBtnAlt := TButton():New(001,60 , "Alterar", oPanel, {|| U_CancReceb()},nLargBtn)
	oBtn5s := TButton():New(001,110 , "Realizar 5S", oPanel, {|| U_CancReceb()},nLargBtn)
	oBtnApr := TButton():New(001,160 , "Aprovar Diario", oPanel, {|| U_CancReceb()},nLargBtn)
	oBtnApr := TButton():New(001,210 , "Observações", oPanel, {|| fObserv()},nLargBtn)

RETURN

STATIC FUNCTION fRodape2(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	//oBtnInc := TButton():New(001,10 , "Incluir", oPanel, {|| U_ConfReceb()},nLargBtn)
	//oBtnAlt := TButton():New(001,60 , "Alterar", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtn5s := TButton():New(001,110 , "Realizar 5S", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtnApr := TButton():New(001,160 , "Aprovar Diario", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtnApr := TButton():New(001,210 , "Observações", oPanel, {|| fObserv()},nLargBtn)

RETURN

STATIC FUNCTION fRodape3(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	//oBtnInc := TButton():New(001,10 , "Incluir", oPanel, {|| U_ConfReceb()},nLargBtn)
	//oBtnAlt := TButton():New(001,60 , "Alterar", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtn5s := TButton():New(001,110 , "Realizar 5S", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtnApr := TButton():New(001,160 , "Aprovar Diario", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtnApr := TButton():New(001,210 , "Observações", oPanel, {|| fObserv()},nLargBtn)

RETURN

STATIC FUNCTION fRodape4(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	//oBtnInc := TButton():New(001,10 , "Incluir", oPanel, {|| U_ConfReceb()},nLargBtn)
	//oBtnAlt := TButton():New(001,60 , "Alterar", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtn5s := TButton():New(001,110 , "Realizar 5S", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtnApr := TButton():New(001,160 , "Aprovar Diario", oPanel, {|| U_CancReceb()},nLargBtn)
	//oBtnApr := TButton():New(001,210 , "Observações", oPanel, {|| fObserv()},nLargBtn)

RETURN

STATIC FUNCTION fObserv(cCodTeto)

	Local _cTxtLog     := ""
	Local _cObserv     := ""
	Local _oFontCabO   := TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local _oFontObs    := TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)
	Private _lContinua := .F.

	If (Select("TEMPOBS") <> 0)
		dbSelectArea("TEMPOBS")
		dbCloseArea()
	Endif

	_cQuery := " SELECT NVL(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(ZCG.ZCG_OBSERV,2000,1)), ' ') ZCG_OBSERV, ZCG.ZCG_DATA, ZCG.ZCG_HORA, ZCG.ZCG_CODUSU "
	_cQuery += " FROM " + RetSQLName("ZCG") + " ZCG "
	_cQuery += " WHERE ZCG.ZCG_ENTIDA = 'SZA' "
	_cQuery += "   AND ZCG.ZCG_FILIAL = '" + xFilial("ZCG") + "' "
	_cQuery += "   AND ZCG.ZCG_CODENT = '" + cCodTeto + "' "
	_cQuery += "   AND ZCG.D_E_L_E_T_ = ' ' "
	_cQuery += " ORDER BY R_E_C_N_O_ DESC "

	TCQuery _cQuery NEW ALIAS "TEMPOBS"

	While TEMPOBS->(!Eof())

		If Alltrim(TEMPOBS->ZCG_OBSERV) != "" .AND. TEMPOBS->ZCG_OBSERV != Nil
			_cTxtLog += "[ " + UsrRetName(TEMPOBS->(ZCG_CODUSU)) + " - " + Transform(StoD(TEMPOBS->ZCG_DATA), "@!") + " - " + TEMPOBS->ZCG_HORA + "]: " + TEMPOBS->ZCG_OBSERV + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		EndIf

		TEMPOBS->(dbSkip())

	End

	If Empty(_cTxtLog)
		_cTxtLog := "Pick não possui registro de observações anteriores."
	EndIf

	_oDlgObs	:= TDialog():New(000,000,470,520,"PEDIDO: " + TRB2->PEDIDO,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	_oSay1		:= TSay():New(000,005,{|| "Histórico do pedido: " + TRB2->PEDIDO},_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet1	:= TMultiget():New(010,005,{|u| _cTxtLog},_oDlgObs,250,130,_oFontObs,,,,,.T.)
	_oMtGet1:lReadOnly := .T.

	_oSay2		:= TSay():New(145,005,{|| "Informe a Observação Desejada:" },_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet2	:= TMultiget():New(155,005,{|u| if(Pcount()>0,_cObserv := u,_cObserv)},_oDlgObs,250,060,_oFontObs,,,,,.T.)
	_oBtConf	:= TButton():New(220,130,"Confirmar"  ,_oDlgObs,{|| (U_fSalvaObs(_cObserv, cCodTeto), _oDlgObs:End())},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtClos	:= TButton():New(220,195,"Sair"	      ,_oDlgObs,{|| _oDlgObs:End()                                  },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oBtConf:SetCss(EstiloBt("OK.png"))
	_oBtClos:SetCss(EstiloBt("CANCEL.png"))

	_oDlgObs:Activate(,,,.T.,{|| .t.},,{|| .t.})

RETURN _lContinua
