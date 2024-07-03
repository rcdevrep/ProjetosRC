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
	oBrowse:SetAlias('ZT0')
	oBrowse:SetDescription( "Teto Meteor" )
	oBrowse:SetMenuDef("RCTEC06")
	//oBrowse:AddFilter('Status',"SF1->F1_STATUS = 'Z'",.T.,.T.)
	oBrowse:addLegend({|| ZT0->ZT0_STATUS = '0'}        ,'BR_MARROM'  ,'Não Iniciado/Pendente')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '1'}        ,'BR_VERMELHO'  ,'Diario de Bordo Aprovado')
	oBrowse:addLegend({|| ZT0->ZT0_STATUS = '1'}        ,'BR_LARANJA'  ,'Setup OK')
	oBrowse:addLegend({|| ZT0->ZT0_STATUS = '2'}        ,'BR_AMARELO'  ,'Moldagem OK')
	oBrowse:addLegend({|| ZT0->ZT0_STATUS = '3'}        ,'BR_VERDE'  ,'Dureza OK')
	oBrowse:Activate()
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir' ACTION 'U_fIncTeto' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Produção'    ACTION 'VIEWDEF.RCTEC06' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RCTEC06' OPERATION 2 ACCESS 0

Return(aRotina)

Static Function ModelDef()

	// Declara um Objeto Model ( Conjunto de estruturas )
	Local oModel

	// Cria os conjuntos de estruturas e campos ( Ira criar campos com suas validações conforme o SX3 )
	// TETO METEOR (ZT0)
	Private oStMain  := FWFormStruct(1,'ZT0')
	// DIARIO DE BORDO (ZT1)
	Private oStAba1  := FWFormStruct(1,'ZT1')
	// SETUP RQ 08.319 (ZT2)
	Private oStAba2 := FWFormStruct(1,'ZT2')
	// ACOMPANHAMENTO DE MOLDAGEM RQ 08.317 (ZT3)
	Private oStAba3 := FWFormStruct(1,'SB1')
	// REGISTRO DE DUREZA RQ 08.358 (ZT4)
	Private oStAba4 := FWFormStruct(1,'SB1')

	// Cria o Model
	oModel := MPFormModel():New('PETEC06'        ,{|oModel| BeforeCMdl(oModel)},{|oModel|sfTudoOk(oModel)})

	// Associa os objetos visuais criados com as estruturas criadas, desta forma ira criar os campos conforme as estrutura.
	oModel:addFields('MASTER' ,/*cOwner*/  ,oStMain   ,/*bLinePre*/                          ,/*bLinePost*/,/*bPreVal*/, /*bPost*/                          ,/*BLoad*/ )

	oModel:AddGrid('ABA1', 'MASTER', oStAba1,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/ )
	oModel:AddGrid('ABA2', 'MASTER', oStAba2,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/)
	oModel:AddGrid('ABA3', 'MASTER', oStAba3,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/)
	oModel:AddGrid('ABA4', 'MASTER', oStAba4,/*bLinePre*/{|oModel|sfLinPre(oModel)},/**/,/*bPreVal*/,{|oModel|sfLinPos(oModel)} /*bPost*/,/*BLoad*/)

	// Cria chave primaria do cadastro principal.
	oModel:SetPrimaryKey( { } )

	// Cria descrições para os objetos, para que seja possivel a chamada pelo nome posteriormente.
	oModel:SetDescription('Teto Meteor')
	oModel:getModel('MASTER' ):SetDescription('Master')
	oModel:getModel('ABA1' ):SetDescription('Aba1')
	oModel:getModel('ABA2' ):SetDescription('Aba2')
	oModel:getModel('ABA3' ):SetDescription('Aba3')
	oModel:getModel('ABA4' ):SetDescription('Aba4')

	// Faz o relacionamento entre as estruturas, o fonte ira realizar as validações necessarias por este relacionamento.

	oModel:SetRelation( 'ABA1'	 , { { 'ZT1_FILIAL', 'ZT0_FILIAL' } } , ZT1->( IndexKey( 2 ) ) )
	oModel:SetRelation( 'ABA2'	 , { { 'ZT2_FILIAL', 'ZT0_FILIAL' } ,{ 'ZT2_CTETO', 'ZT0_CODIGO' } } , ZT2->( IndexKey( 1 ) ) )
	//oModel:SetRelation( 'ABA3'	 , { { 'B1_FILIAL', 'BM_FILIAL' } ,{ 'B1_GRUPO', 'BM_GRUPO' } } , SB1->( IndexKey( 1 ) ) )
	//oModel:SetRelation( 'ABA4'	 , { { 'B1_FILIAL', 'BM_FILIAL' } ,{ 'B1_GRUPO', 'BM_GRUPO' } } , SB1->( IndexKey( 1 ) ) )

	oModel:SetVldActivate( { |oModel| sfValAtiva( oModel ) } )

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel('RCTEC06')
	Local cSolicit := ""
	Private oView	 := FWFormView():New()
	Private oStMain  := FWFormStruct(2,'ZT0',{ |cCampo| STRUMASTER(cCampo)   })
	Private oStAba1  := FWFormStruct(2,'ZT1',{ |cCampo| STRUABA1(cCampo,1) })
	Private oStAba2  := FWFormStruct(2,'ZT2',{ |cCampo| STRUABA2(cCampo,1) })
	Private oStAba3 := FWFormStruct(2,'SB1',{ |cCampo| STRUDETAIL(cCampo,1) })
	Private oStAba4 := FWFormStruct(2,'SB1',{ |cCampo| STRUDETAIL(cCampo,1) })

	oView:SetModel(oModel)
	// Seta a view com o model criado anteriormente

	// Cria os objetos com os campos existentes nas esturturas
	oView:AddField('VIEW_ZT0' , oStMain	,'MASTER'	) // objeto filds, ( Grids e Says )
	oView:AddGrid('VIEW_ZT1'  , oStAba1	,'ABA1'	) // objeto grid
	oView:AddGrid('VIEW_ZT2',oStAba2,'ABA2')
	oView:AddGrid('VIEW_FILHO3',oStAba3,'ABA3')
	oView:AddGrid('VIEW_FILHO4',oStAba4,'ABA4')

	// CHAMADA DE FUNCOES DOS BOTOES DOS RODAPES DE CADA ABA
	oView:AddOtherObject('VIEW_ZT0',{|oPanel|fBtnObs(oPanel)})
	oView:AddOtherObject('VIEW_RODAPE1',{|oPanel|fRodape1(oPanel)})
	oView:AddOtherObject('VIEW_RODAPE2',{|oPanel|fRodape2(oPanel)})
	oView:AddOtherObject('VIEW_RODAPE3',{|oPanel|fRodape3(oPanel)})
	oView:AddOtherObject('VIEW_RODAPE4',{|oPanel|fRodape4(oPanel)})

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )
	//oView:CreateHorizontalBox( 'RODAPE'  , 10 )

	oView:CreateFolder('PASTA_ABAS', 'INFERIOR')
	oView:AddSheet('PASTA_ABAS', 'ABA_1', "Diario de Bordo")
	oView:AddSheet('PASTA_ABAS', 'ABA_2', "SETUP 08.319")
	oView:AddSheet('PASTA_ABAS', 'ABA_3', "Acomp. Moldagem 08.317")
	oView:AddSheet('PASTA_ABAS', 'ABA_4', "Reg. Dureza 08.358")

	oView:CreateHorizontalBox('ITENS1', 85, , , 'PASTA_ABAS', 'ABA_1')
	oView:CreateHorizontalBox('RODAPE1', 15, , , 'PASTA_ABAS', 'ABA_1')

	oView:CreateHorizontalBox('ITENS2', 85, , , 'PASTA_ABAS', 'ABA_2')
	oView:CreateHorizontalBox('RODAPE2', 15, , , 'PASTA_ABAS', 'ABA_2')

	oView:CreateHorizontalBox('ITENS3', 85, , , 'PASTA_ABAS', 'ABA_3')
	oView:CreateHorizontalBox('RODAPE3', 15, , , 'PASTA_ABAS', 'ABA_3')

	oView:CreateHorizontalBox('ITENS4', 85, , , 'PASTA_ABAS', 'ABA_4')
	oView:CreateHorizontalBox('RODAPE4', 15, , , 'PASTA_ABAS', 'ABA_4')

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZT0'  , 'SUPERIOR' )

	oView:SetOwnerView( 'VIEW_ZT1'	, 'ITENS1' )
	oView:SetOwnerView( 'VIEW_RODAPE1'  , 'RODAPE1')

	oView:SetOwnerView('VIEW_ZT2', 'ITENS2')
	oView:SetOwnerView( 'VIEW_RODAPE2'  , 'RODAPE2')

	oView:SetOwnerView('VIEW_FILHO3', 'ITENS3')
	oView:SetOwnerView('VIEW_FILHO4', 'ITENS4')

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
	Local oModel2  := oModel:GetModel("ABA2")
	Local oModel3  := oModel:GetModel("ABA3")
	Local oModel4  := oModel:GetModel("ABA4")
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
	Local oModel2	 := oModel:GetModel('ABA2')
	Local oModel3	 := oModel:GetModel('ABA3')
	Local oModel4	 := oModel:GetModel('ABA4')
	Default cCpo     := ""

Return(lRet)

Static Function sfLinPos(oModel)
	Local lRet	     := .T.
Return(lRet)

//Retorno de campos que serao usados ZT0
Static Function STRUMASTER(cCampo)
	Local lRet	  := .F.

	DO CASE
	CASE cCampo = "ZT0_CODIGO" ; RETURN .T.
	CASE cCampo = "ZT0_DESC" ; RETURN .T.
	CASE cCampo = "ZT0_DATA" ; RETURN .T.
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

//Retorno de campos que serao usados ZT1
Static Function STRUABA1(cCampo)
	Local lRet	:= .F.
	DO CASE
	CASE cCampo = "ZT1_DATA" ; RETURN .T.
	CASE cCampo = "ZT1_HINI" ; RETURN .T.
	CASE cCampo = "ZT1_HFIM" ; RETURN .T.
	CASE cCampo = "ZT1_APROVA" ; RETURN .T.
	ENDCASE
Return(lRet)

Static Function STRUABA2(cCampo)
	Local lRet	:= .F.
	DO CASE
	CASE cCampo = "ZT2_CTETO" ; RETURN .T.
	CASE cCampo = "ZT2_DATA" ; RETURN .T.
	CASE cCampo = "ZT2_ORDEM" ; RETURN .T.
	CASE cCampo = "ZT2_TURNO" ; RETURN .T.
	CASE cCampo = "ZT2_CAV" ; RETURN .T.
	ENDCASE
Return(lRet)

Static Function BeforeCMdl(oModel)
	Local lRet	:= .T.
Return(lRet)

// RODAPE ZT1 - DIARIO DE BORDO
STATIC FUNCTION fRodape1(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	oBtnInc := TButton():New(001,10 , "Incluir", oPanel, {|| U_incDiario(DTOS(Date()),TIME())},nLargBtn)
	oBtnAlt := TButton():New(001,60 , "Alterar", oPanel, {|| U_altDiario(ZT1->ZT1_DATA,ZT1->ZT1_HINI,ZT1->ZT1_HFIM,ZT1->ZT1_PRAZO)},nLargBtn)
	oBtn5s := TButton():New(001,110 , "Realizar Checklist", oPanel, {|| U_fCheckl(Date())},nLargBtn)
	oBtnApr := TButton():New(001,160 , "Aprovar/Desaprovar Diario", oPanel, {|| U_fAprovD()},nLargBtn)
	oBtnObs := TButton():New(001,210 , "Observações Diario", oPanel, {|| U_fObservD(Date())},nLargBtn)

RETURN

STATIC FUNCTION fRodape2(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	oBtnInc := TButton():New(001,10 , "Incluir", oPanel, {|| U_incSetup(ZT0->ZT0_CODIGO)},nLargBtn)
	oBtnAlt := TButton():New(001,60 , "Alterar", oPanel, {|| U_CancReceb()},nLargBtn)
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

// BOTAO DE OBSERVACOES (TETO)
STATIC FUNCTION fBtnObs(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	oBtnOt := TButton():New(001,180 , "Observações Teto", oPanel, {|| U_fObserv(ZT0->ZT0_CODIGO)},nLargBtn)

RETURN

// TELA DE OBSERVACOES (TETO)
USER FUNCTION fObserv(cCodTeto)

	Local _cTxtLog     := ""
	Local _cObserv     := ""
	Local _oFontCabO   := TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local _oFontObs    := TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)
	Private _lContinua := .F.

	If (Select("TEMPOBS") <> 0)
		dbSelectArea("TEMPOBS")
		dbCloseArea()
	Endif

	_cQuery := " SELECT ZT9_OBS, ZT9.ZT9_DATA, ZT9.ZT9_HORA, ZT9.ZT9_USER "
	_cQuery += " FROM " + RetSQLName("ZT9") + " ZT9 "
	_cQuery += " WHERE ZT9.ZT9_ENTIDA = 'ZT0' "
	_cQuery += "   AND ZT9.ZT9_FILIAL = '" + xFilial("SC2") + "' "
	_cQuery += "   AND ZT9.ZT9_CODENT = '" + cCodTeto + "' "
	_cQuery += "   AND ZT9.D_E_L_E_T_ = ' ' "
	_cQuery += " ORDER BY R_E_C_N_O_ DESC "

	TCQuery _cQuery NEW ALIAS "TEMPOBS"

	While TEMPOBS->(!Eof())

		If Alltrim(TEMPOBS->ZT9_OBS) != "" .AND. TEMPOBS->ZT9_OBS != Nil
			_cTxtLog += "[ " + UsrRetName(TEMPOBS->(ZT9_USER)) + " - " + Transform(StoD(TEMPOBS->ZT9_DATA), "@!") + " - " + TEMPOBS->ZT9_HORA + "]: " + TEMPOBS->ZT9_OBS + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		EndIf

		TEMPOBS->(dbSkip())

	End

	If Empty(_cTxtLog)
		_cTxtLog := "Não possui registro de observações anteriores."
	EndIf

	_oDlgObs	:= TDialog():New(000,000,470,520,"TETO: " + cCodTeto,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	_oSay1		:= TSay():New(000,005,{|| "Histórico do TETO: " + cCodTeto},_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet1	:= TMultiget():New(010,005,{|u| _cTxtLog},_oDlgObs,250,130,_oFontObs,,,,,.T.)
	_oMtGet1:lReadOnly := .T.

	_oSay2		:= TSay():New(145,005,{|| "Informe a Observação Desejada:" },_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet2	:= TMultiget():New(155,005,{|u| if(Pcount()>0,_cObserv := u,_cObserv)},_oDlgObs,250,060,_oFontObs,,,,,.T.)

	_oBtConf	:= TButton():New(220,130,"Confirmar"  ,_oDlgObs,{|| (U_fSalvaObs(_cObserv, cCodTeto), _oDlgObs:End())},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtClos	:= TButton():New(220,195,"Sair"	      ,_oDlgObs,{|| _oDlgObs:End()                                  },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oDlgObs:Activate(,,,.T.,{|| .t.},,{|| .t.})

RETURN _lContinua

// FUNCAO PARA SALVAR OBSERVACOES (TETO)
USER FUNCTION fSalvaObs(_cObsSalv, cCodTeto)

	If !Empty(_cObsSalv)

		RecLock("ZT9", .T.)
		ZT9->ZT9_FILIAL	:= xFilial("SC2")
		ZT9->ZT9_ENTIDA	:= "ZT0"
		ZT9->ZT9_CODENT	:= cCodTeto
		ZT9->ZT9_DATA		:= Date()
		ZT9->ZT9_HORA		:= Time()
		ZT9->ZT9_USER	:= __cUserID
		ZT9->ZT9_OBS	:= Alltrim(_cObsSalv)
		MsUnlock()

		MessageBox("Observação Registrada com Sucesso.", "", 0)

	EndIf

	_lContinua := .T.

RETURN

// TELA DE OBSERVACOES (DIARIO)
USER FUNCTION fObservD(dData)

	Local _cTxtLog     := ""
	Local  cData := DTOS(dData)
	Local _cObserv     := ""
	Local _oFontCabO   := TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local _oFontObs    := TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)
	Private _lContinua := .F.

	If (Select("TMPOBSD") <> 0)
		dbSelectArea("TMPOBSD")
		dbCloseArea()
	Endif

	_cQuery := " SELECT ZT9_OBS, ZT9.ZT9_DATA, ZT9.ZT9_HORA, ZT9.ZT9_USER "
	_cQuery += " FROM " + RetSQLName("ZT9") + " ZT9 "
	_cQuery += " WHERE ZT9.ZT9_ENTIDA = 'ZT1' "
	_cQuery += "   AND ZT9.ZT9_FILIAL = '" + cFilAnt + "' "
	_cQuery += "   AND ZT9.ZT9_CODENT = '" + cData + "' "
	_cQuery += "   AND ZT9.D_E_L_E_T_ = ' ' "
	_cQuery += " ORDER BY R_E_C_N_O_ DESC "

	TCQuery _cQuery NEW ALIAS "TMPOBSD"

	While TMPOBSD->(!Eof())

		If Alltrim(TMPOBSD->ZT9_OBS) != "" .AND. TMPOBSD->ZT9_OBS != Nil
			_cTxtLog += "[ " + UsrRetName(TMPOBSD->(ZT9_USER)) + " - " + Transform(StoD(TMPOBSD->ZT9_DATA), "@!") + " - " + TMPOBSD->ZT9_HORA + "]: " + TMPOBSD->ZT9_OBS + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		EndIf

		TMPOBSD->(dbSkip())

	End

	If Empty(_cTxtLog)
		_cTxtLog := "Não possui registro de observações anteriores."
	EndIf

	_oDlgObs	:= TDialog():New(000,000,470,520,"Diário: " + cData,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	_oSay1		:= TSay():New(000,005,{|| "Histórico do Diário: " + cData},_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet1	:= TMultiget():New(010,005,{|u| _cTxtLog},_oDlgObs,250,130,_oFontObs,,,,,.T.)
	_oMtGet1:lReadOnly := .T.

	_oSay2		:= TSay():New(145,005,{|| "Informe a Observação Desejada:" },_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet2	:= TMultiget():New(155,005,{|u| if(Pcount()>0,_cObserv := u,_cObserv)},_oDlgObs,250,060,_oFontObs,,,,,.T.)

	_oBtConf	:= TButton():New(220,130,"Confirmar"  ,_oDlgObs,{|| (U_fSlvObsD(_cObserv, cData), _oDlgObs:End())},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtClos	:= TButton():New(220,195,"Sair"	      ,_oDlgObs,{|| _oDlgObs:End()                                  },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oDlgObs:Activate(,,,.T.,{|| .t.},,{|| .t.})

RETURN _lContinua

// FUNCAO PARA SALVAR OBSERVACOES (DIARIO)
USER FUNCTION fSlvObsD(_cObsSalv, cData)

	DBSELECTAREA("ZT1")
	DBSETORDER(1)

	IF DbSeek(cFilAnt+cData,.T.) .AND. !Empty(_cObsSalv)

		RecLock("ZT9", .T.)
		ZT9->ZT9_FILIAL	:= cFilAnt
		ZT9->ZT9_ENTIDA	:= "ZT1"
		ZT9->ZT9_CODENT	:= cData
		ZT9->ZT9_DATA		:= Date()
		ZT9->ZT9_HORA		:= Time()
		ZT9->ZT9_USER	:= __cUserID
		ZT9->ZT9_OBS	:= Alltrim(_cObsSalv)
		MsUnlock()

		MessageBox("Observação Registrada com Sucesso.", "", 0)
		_lContinua := .T.
	ELSE
		FWAlertError("Diário não existe, use a opção de incluir", "RCTEC06")
		_lContinua := .F.
	ENDIF
	DBCLOSEAREA()
RETURN _lContinua

// FUNCAO PARA INCLUIR NOVO CODIGO DE TETO
USER FUNCTION fIncTeto()

	Local lValida := .F.
	Local cCodTeto := GetSXENum('ZT0', 'ZT0_CODIGO')

	IF MsgYesNo("Deseja Gerar Novo Teto?", "Confirma", .T.)

		IF RECLOCK("ZT0",.T.)
			ZT0->ZT0_FILIAL := cFilant
			ZT0->ZT0_CODIGO := cCodTeto
			ZT0->ZT0_STATUS := '0'
			ZT0->ZT0_DESC := "Teto Meteor"
			ZT0->ZT0_DATA := Date()
			FWAlertSuccess("Novo Codigo Gerado: "+cCodTeto, "Sucesso")
			lValida := .T.
			ConfirmSX8()
			MSUNLOCK()
			RETURN lValida
		ELSE
			FWAlertError("Não foi possivel criar o codigo ", "Erro")
			RollBackSX8()
		ENDIF
	ELSE
		RollBackSX8()
		lValida := .F.
	ENDIF

RETURN lValida

// FUNCAO QUE REALIZA O CHECKLIST
USER FUNCTION fCheckl(dData)

	Local lPergs := .T.
	Local aPergs := {}
	Local i
	Local cnConf := ""
	Local cData := DTOS(dData)

	IF dData != Date()
		FWAlertError("Data de Diário Inválida, utilize o diário do dia de hoje. ", "Erro")
		RETURN .F.
	ENDIF

	DBSELECTAREA("ZT1")
	DBSETORDER(1)
	IF DbSeek(cFilAnt+cData,.T.)
		IF ZT1->ZT1_APROVA = 'S'
			FWAlertError("Diario ja aprovado, deve-se usar a opcao de Reabertura ", "Erro")
			DBCLOSEAREA()
			RETURN .F.
		ELSE
			aAdd(aPergs,ZT1->ZT1_CHK01)
			aAdd(aPergs,ZT1->ZT1_CHK02)
			aAdd(aPergs,ZT1->ZT1_CHK03)
			aAdd(aPergs,ZT1->ZT1_CHK04)
			aAdd(aPergs,ZT1->ZT1_CHK05)
			aAdd(aPergs,ZT1->ZT1_CHK06)
			aAdd(aPergs,ZT1->ZT1_CHK07)
			aAdd(aPergs,ZT1->ZT1_CHK08)
			aAdd(aPergs,ZT1->ZT1_CHK09)
			aAdd(aPergs,ZT1->ZT1_CHK10)
			aAdd(aPergs,ZT1->ZT1_CHK11)
			aAdd(aPergs,ZT1->ZT1_CHK12)
			aAdd(aPergs,ZT1->ZT1_CHK13)
			aAdd(aPergs,ZT1->ZT1_CHK14)
			aAdd(aPergs,ZT1->ZT1_CHK15)
			aAdd(aPergs,ZT1->ZT1_CHK16)
			aAdd(aPergs,ZT1->ZT1_CHK17)
			aAdd(aPergs,ZT1->ZT1_CHK18)
			aAdd(aPergs,ZT1->ZT1_CHK19)
			aAdd(aPergs,ZT1->ZT1_CHK20)
			aAdd(aPergs,ZT1->ZT1_CHK21)
			aAdd(aPergs,ZT1->ZT1_CHK22)
			aAdd(aPergs,ZT1->ZT1_CHK23)
			aAdd(aPergs,ZT1->ZT1_CHK24)
			aAdd(aPergs,ZT1->ZT1_CHK25)
			aAdd(aPergs,ZT1->ZT1_CHK26)
			aAdd(aPergs,ZT1->ZT1_CHK27)
			aAdd(aPergs,ZT1->ZT1_CHK28)
			aAdd(aPergs,ZT1->ZT1_CHK29)
			aAdd(aPergs,ZT1->ZT1_CHK30)
			aAdd(aPergs,ZT1->ZT1_CHK31)

			FOR i = 1 TO Len(aPergs)
				IF aPergs[i] == .T.
					//Conout("Pergunta:"+i+" Conforme")
				ELSE
					DO CASE
					CASE aPergs[i] == .F. ; cnConf += "Pergunta: "+cValtoChar(i)+" Não Conforme"+'\n'
					ENDCASE
					lPergs := .F.
				ENDIF
			NEXT i

			IF lPergs
				FWAlertSuccess("Checklist já está Conforme e Realizado. ", "Sucesso")
				DBCLOSEAREA()
				RETURN .T.
			ELSE
				RECLOCK("ZT1",.F.)
				IF !(ZT1->ZT1_CHK01)
					IF MsgYesNo("Arrumação e Limpeza?", "Confirma", .T.)
						ZT1->ZT1_CHK01 := .T.
					ELSE
						ZT1->ZT1_CHK01 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK02)
					IF MsgYesNo("Resina, gel coat, catalisador, disponíveis na área e dentro do prazo validade?", "Confirma", .T.)
						ZT1->ZT1_CHK02 := .T.
					ELSE
						ZT1->ZT1_CHK02 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK03)
					IF MsgYesNo("Temperatura da resina OK?", "Confirma", .T.)
						ZT1->ZT1_CHK03 := .T.
					ELSE
						ZT1->ZT1_CHK03 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK04)
					IF MsgYesNo("Produtos químicos (Embalagem apropriada? Identificados?)", "Confirma", .T.)
						ZT1->ZT1_CHK04 := .T.
					ELSE
						ZT1->ZT1_CHK04 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK05)
					IF MsgYesNo("Kit de ferramentas à disposição?", "Confirma", .T.)
						ZT1->ZT1_CHK05 := .T.
					ELSE
						ZT1->ZT1_CHK05 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK06)
					IF MsgYesNo("Solução de limpeza, cera e desmoldante disponíveis?", "Confirma", .T.)
						ZT1->ZT1_CHK06 := .T.
					ELSE
						ZT1->ZT1_CHK06 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK07)
					IF MsgYesNo("Manta, tecidos e reforços metálicos disponíveis?", "Confirma", .T.)
						ZT1->ZT1_CHK07 := .T.
					ELSE
						ZT1->ZT1_CHK07 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK08)
					IF MsgYesNo("Moldes limpos, conservados, sem vazamento de ar/água,abertura/fechamento funcionando?", "Confirma", .T.)
						ZT1->ZT1_CHK08 := .T.
					ELSE
						ZT1->ZT1_CHK08 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK09)
					IF MsgYesNo("Temperatura do molde / cavidade (I) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK09 := .T.
					ELSE
						ZT1->ZT1_CHK09 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK10)
					IF MsgYesNo("Temperatura do molde / cavidade (II) OK? ", "Confirma", .T.)
						ZT1->ZT1_CHK10 := .T.
					ELSE
						ZT1->ZT1_CHK10 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK11)
					IF MsgYesNo("Temperatura do molde / cavidade (III) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK11 := .T.
					ELSE
						ZT1->ZT1_CHK11 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK12)
					IF MsgYesNo("Temperatura do molde / cavidade (IV) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK12 := .T.
					ELSE
						ZT1->ZT1_CHK12 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK13)
					IF MsgYesNo("Temperatura do molde / matriz (I) OK? ", "Confirma", .T.)
						ZT1->ZT1_CHK13 := .T.
					ELSE
						ZT1->ZT1_CHK13 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK14)
					IF MsgYesNo("Temperatura do molde / matriz (II) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK14 := .T.
					ELSE
						ZT1->ZT1_CHK14 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK15)
					IF MsgYesNo("Qualidade do molde / cavidade (I) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK15 := .T.
					ELSE
						ZT1->ZT1_CHK15 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK16)
					IF MsgYesNo("Qualidade do molde / cavidade (II) OK? ", "Confirma", .T.)
						ZT1->ZT1_CHK16 := .T.
					ELSE
						ZT1->ZT1_CHK16 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK17)
					IF MsgYesNo("Qualidade do molde / cavidade (III) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK17 := .T.
					ELSE
						ZT1->ZT1_CHK17 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK18)
					IF MsgYesNo("Qualidade do molde / cavidade (IV) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK18 := .T.
					ELSE
						ZT1->ZT1_CHK18 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK19)
					IF MsgYesNo("Qualidade do molde / matriz (I) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK19 := .T.
					ELSE
						ZT1->ZT1_CHK19 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK20)
					IF MsgYesNo("Qualidade do molde / matriz (II) OK? ", "Confirma", .T.)
						ZT1->ZT1_CHK20 := .T.
					ELSE
						ZT1->ZT1_CHK20 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK21)
					IF MsgYesNo("Limpeza do molde / cavidade (I) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK21 := .T.
					ELSE
						ZT1->ZT1_CHK21 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK22)
					IF MsgYesNo("Limpeza do molde / cavidade (II) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK22 := .T.
					ELSE
						ZT1->ZT1_CHK22 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK23)
					IF MsgYesNo("Limpeza do molde / cavidade (III) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK23 := .T.
					ELSE
						ZT1->ZT1_CHK23 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK24)
					IF MsgYesNo("Limpeza do molde / cavidade (IV) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK24 := .T.
					ELSE
						ZT1->ZT1_CHK24 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK25)
					IF MsgYesNo("Limpeza do molde / matriz (I) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK25 := .T.
					ELSE
						ZT1->ZT1_CHK25 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK26)
					IF MsgYesNo("Limpeza do molde / matriz (II) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK26 := .T.
					ELSE
						ZT1->ZT1_CHK26 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK27)
					IF MsgYesNo("Sistema extração molde / cavidade (I) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK27 := .T.
					ELSE
						ZT1->ZT1_CHK27 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK28)
					IF MsgYesNo("Sistema extração molde / cavidade (II) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK28 := .T.
					ELSE
						ZT1->ZT1_CHK28 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK29)
					IF MsgYesNo("Sistema extração molde / cavidade (III) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK29 := .T.
					ELSE
						ZT1->ZT1_CHK29 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK30)
					IF MsgYesNo("Sistema extração molde / cavidade (IV) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK30 := .T.
					ELSE
						ZT1->ZT1_CHK30 := .F.
					ENDIF
				ENDIF
				IF !(ZT1->ZT1_CHK31)
					IF MsgYesNo("Sistema extração molde / matriz (I) OK?", "Confirma", .T.)
						ZT1->ZT1_CHK31 := .T.
					ELSE
						ZT1->ZT1_CHK31 := .F.
					ENDIF
				ENDIF
				MSUNLOCK()
			ENDIF
		ENDIF
		IF cnConf == ""
			FWAlertSuccess("Checklist Finalizado com Sucesso!. ", "Sucesso")
			DBCLOSEAREA()
			RETURN .T.
		ENDIF
		DBCLOSEAREA()
	ELSE
		FWAlertError("Diario não encontrado, deve-se usar a opção Incluir ", "Erro")
		DBCLOSEAREA()
		RETURN .F.
	ENDIF
RETURN

// FUNCAO INCLUIR DIARIO DE BORDO
USER FUNCTION incDiario(cData,cHora)

	//Local _cTxtLog     := ""
	Local  cHFim 	   := ""
	Local nPrazo := 0
	Local cUser := UsrRetName(__cUserID)
	Local cAprov := 'N'
	Local _oFontCabO   := TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local _oFont    := TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)

	DBSELECTAREA("ZT1")
	DBSETORDER(1)
	IF DbSeek(cFilAnt+cData,.T.)
		FWAlertError("Diário já existente, use a opção de alterar", "RCTEC06")
		DBCLOSEAREA()
		RETURN .F.
	ENDIF

	// JANELA PRINCIPAL
	_oDlg	:= TDialog():New(000,000,470,720,"Diario de Bordo" ,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	// DATA DIARIO
	_oSay1		:= TSay():New(005,005,{|| "Data do Diário: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet1	:= TMultiget():New(012,005,{|u| cData},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet1:lReadOnly := .T.

	// HORA INICIO
	_oSay2		:= TSay():New(027,005,{|| "Hora de Inicio: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet2	:= TMultiget():New(035,005,{|u| cHora},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet2:lReadOnly := .T.

	// HORA DE FINALIZACAO
	_oSay3		:= TSay():New(050,005,{|| "Hora de Finalização:" },_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet3	:= TMultiget():New(058,005,{|u| if(Pcount()>0,cHFim := u,cHFim)},_oDlg,50,010,_oFont,,,,,.T.)

	// PRAZO PARA CONFORMIDADE (EM HORAS)
	_oSay4		:= TSay():New(073,005,{|| "Prazo para Conformidade (Em Horas):" },_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet4	:= TMultiget():New(081,005,{|u| if(Pcount()>0,nPrazo := u,nPrazo)},_oDlg,50,010,_oFont,,,,,.T.)

	// USUARIO
	_oSay5		:= TSay():New(096,005,{|| "Hora de Inicio: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet5	:= TMultiget():New(104,005,{|u| cUser},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet5:lReadOnly := .T.

	// APROVADO?
	_oSay6		:= TSay():New(119,005,{|| "Diário Aprovado?: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet6	:= TMultiget():New(127,005,{|u| cAprov},_oDlg,10,010,_oFont,,,,,.T.)
	_oMtGet6:lReadOnly := .T.

	// BOTOES
	_oBtConf	:= TButton():New(220,130,"Confirmar"  ,_oDlg,{|| (U_fSalvaD(cData,cHFim,nPrazo,cUser), _oDlg:End())},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtClos	:= TButton():New(220,195,"Sair"	      ,_oDlg,{|| _oDlg:End()                                  },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oDlg:Activate(,,,.T.,{|| .t.},,{|| .t.})

RETURN

USER FUNCTION altDiario(cData,cHora,cHFim,nPrazo)

	// COLOCAR AQUI TRAVA PARA DIARIOS JA APROVADOS

	//Local _cTxtLog     := ""
	Local cUser := UsrRetName(__cUserID)
	Local cAprov := 'N'
	Local _oFontCabO   := TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local _oFont    := TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)

	// JANELA PRINCIPAL
	_oDlg	:= TDialog():New(000,000,470,720,"Diario de Bordo" ,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	// DATA DIARIO
	_oSay1		:= TSay():New(005,005,{|| "Data do Diário: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet1	:= TMultiget():New(012,005,{|u| cData},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet1:lReadOnly := .T.

	// HORA INICIO
	_oSay2		:= TSay():New(027,005,{|| "Hora de Inicio: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet2	:= TMultiget():New(035,005,{|u| cHora},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet2:lReadOnly := .T.

	// HORA DE FINALIZACAO
	_oSay3		:= TSay():New(050,005,{|| "Hora de Finalização:" },_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet3	:= TMultiget():New(058,005,{|u| if(Pcount()>0,cHFim := u,cHFim)},_oDlg,50,010,_oFont,,,,,.T.)

	// PRAZO PARA CONFORMIDADE (EM HORAS)
	_oSay4		:= TSay():New(073,005,{|| "Prazo para Conformidade (Em Horas):" },_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet4	:= TMultiget():New(081,005,{|u| if(Pcount()>0,nPrazo := u,nPrazo)},_oDlg,50,010,_oFont,,,,,.T.)

	// USUARIO
	_oSay5		:= TSay():New(096,005,{|| "Hora de Inicio: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet5	:= TMultiget():New(104,005,{|u| cUser},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet5:lReadOnly := .T.

	// APROVADO?
	_oSay6		:= TSay():New(119,005,{|| "Diário Aprovado?: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet6	:= TMultiget():New(127,005,{|u| cAprov},_oDlg,10,010,_oFont,,,,,.T.)
	_oMtGet6:lReadOnly := .T.

	// BOTOES
	_oBtConf	:= TButton():New(220,130,"Confirmar"  ,_oDlg,{|| (U_fSalvaDA(cData,cHFim,nPrazo,cUser), _oDlg:End())},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtClos	:= TButton():New(220,195,"Sair"	      ,_oDlg,{|| _oDlg:End()                                  },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oDlg:Activate(,,,.T.,{|| .t.},,{|| .t.})

RETURN

// FINCAO SALVAR DIARIO DE BORDO
USER FUNCTION fSalvaD(cData,cHFim,nPrazo,cUser,cAprov)

	IF !Empty(cData)

		RecLock("ZT1", .T.)
		ZT1->ZT1_FILIAL	:= cFilant
		ZT1->ZT1_DATA	:= STOD(cData)
		ZT1->ZT1_HINI	:= Time()
		ZT1->ZT1_HFIM		:= cHFim
		ZT1->ZT1_PRAZO	:= nPrazo
		ZT1->ZT1_USER	:= cUser
		ZT1->ZT1_APROVA := cAprov
		MsUnlock()

		MessageBox("Diario Registrado com Sucesso.", "RCTEC06", 0)

	ELSE
		FWAlertError("Não foi possível gravar o Diário, contate a TI", "RCTEC06")
		RETURN .F.
	ENDIF

RETURN .T.

USER FUNCTION fSalvaDA(cData,cHFim,nPrazo,cUser,cAprov)

	IF !Empty(cData)

		RecLock("ZT1", .F.)
		//ZT1->ZT1_FILIAL	:= cFilant
		//ZT1->ZT1_DATA	:= STOD(cData)
		//ZT1->ZT1_HINI	:= Time()
		ZT1->ZT1_HFIM		:= cHFim
		ZT1->ZT1_PRAZO	:= nPrazo
		//ZT1->ZT1_USER	:= cUser
		//ZT1->ZT1_APROVA := cAprov
		MsUnlock()

		MessageBox("Diario Registrado com Sucesso.", "RCTEC06", 0)

	ELSE
		FWAlertError("Não foi possível gravar o Diário, contate a TI", "RCTEC06")
		RETURN .F.
	ENDIF

RETURN .T.


// FUNCAO APROVAR DIARIO DE BORDO
USER FUNCTION fAprovD()

// COLOCAR CONDICAO PARA DESAPROVAR TAMBEM

RETURN

// FUNCAO INCLUIR SETUP
USER FUNCTION incSetup(cCodTeto)

	Local nOrdem := 0
	Local cTurno
	Local cCav
	Local nTma
	Local cOrdem
	Local cUser := UsrRetName(__cUserID)
	Local cData := DTOS(Date())
	Local _oFontCabO   := TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local _oFont    := TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)

	// JANELA PRINCIPAL
	_oDlg	:= TDialog():New(000,000,700,900,"Setup Teto: "+cCodTeto ,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	//@ 330, 250 BITMAP oBitmap1 SIZE 416, 319 OF _oDlg NOBORDER FILENAME "\system\imagens\tetometeor\pontos.jpg" PIXEL

	// TETO
	_oSay1		:= TSay():New(005,005,{|| "Codigo do Teto: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet1	:= TMultiget():New(012,005,{|u| cCodTeto},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet1:lReadOnly := .T.

	// DATA
	_oSay2		:= TSay():New(027,005,{|| "Data: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet2	:= TMultiget():New(035,005,{|u| cData},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet2:lReadOnly := .T.

	// ORDEM
	If (Select("TEMPORD") <> 0)
		dbSelectArea("TEMPORD")
		dbCloseArea()
	Endif

	_cQuery := " SELECT COUNT (ZT2_ORDEM) CONTAGEM FROM "+ RetSQLName("ZT2") +" WHERE ZT2_CTETO = '"+cCodTeto+"' AND D_E_L_E_T_ <> '*' "
	TCQuery _cQuery NEW ALIAS "TEMPORD"
	nOrdem := TEMPORD->CONTAGEM + 1
	cOrdem := cValtoChar(nOrdem)


	_oSay3		:= TSay():New(049,005,{|| "Ordem: "},_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet3	:= TMultiget():New(058,005,{|u| cOrdem},_oDlg,50,010,_oFont,,,,,.T.)
	_oMtGet3:lReadOnly := .T.

	// TURNO DE TRABALHO
	_oSay4		:= TSay():New(072,005,{|| "Turno (1,2,3,4):" },_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet4	:= TMultiget():New(081,005,{|u| if(Pcount()>0,cTurno := u,cTurno)},_oDlg,50,010,_oFont,,,,,.T.)

	// CAVIDADE (1,2,3,4)
	_oSay5		:= TSay():New(094,005,{|| "Cavidade (1,2,3,4):" },_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet5	:= TMultiget():New(104,005,{|u| if(Pcount()>0,cCav := u,cCav)},_oDlg,50,010,_oFont,,,,,.T.)

	// CAVIDADE (1,2,3,4)
	_oSay6		:= TSay():New(116,005,{|| "Temp. Molde A - 50.0 +- 2:" },_oDlg,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,50,10)
	_oMtGet6	:= TMultiget():New(127,005,{|u| if(Pcount()>0,nTma := u,nTma)},_oDlg,50,010,_oFont,,,,,.T.)

	// BOTOES
	_oBtConf	:= TButton():New(600,100,"Confirmar"  ,_oDlg,{|| (U_fSalvaS(cCodTeto,cData,nOrdem,cTurno,cCav), _oDlg:End())},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtClos	:= TButton():New(600,195,"Sair"	      ,_oDlg,{|| _oDlg:End() },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oDlg:Activate(,,,.T.,{|| .t.},,{|| .t.})

RETURN

USER FUNCTION fSalvaS(cCodTeto,cData,nOrdem,cTurno,cCav)

	IF !Empty(cCodTeto)

		RecLock("ZT2", .T.)
		ZT2->ZT2_FILIAL	:= cFilant
		ZT2->ZT2_CTETO	:= cCodTeto
		ZT2->ZT2_DATA	:= STOD(cData)
		ZT2->ZT2_ORDEM		:= nOrdem
		ZT2->ZT2_TURNO	:= cTurno
		ZT2->ZT2_CAV	:= cCav
		//ZT1->ZT1_APROVA := cAprov
		MsUnlock()

		MessageBox("Setup Registrado com Sucesso.", "RCTEC06", 0)

	ELSE
		FWAlertError("Não foi possível gravar o Setup, contate a TI", "RCTEC06")
		RETURN .F.
	ENDIF

RETURN .T.
