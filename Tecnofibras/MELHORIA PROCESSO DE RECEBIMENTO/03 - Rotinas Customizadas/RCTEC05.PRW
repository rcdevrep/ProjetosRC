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
	Local aArea    := GetArea()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias('SF1')
	oBrowse:SetDescription( "Notas Pendentes Recebimento" )
	oBrowse:SetMenuDef("RCTEC05")
	oBrowse:AddFilter('Status',"SF1->F1_XSTATUS = 'Z'",.T.,.T.)

	//Adiciona Leganda
	oBrowse:addLegend({|| SF1->F1_XSTATUS = 'Z'}        ,'BR_CINZA'  ,'pre classificacao/pendente recebimento')
	oBrowse:Activate()
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	IF EMPTY(SF1->F1_SOLICIT)
		U_nSolicit()
	ENDIF

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RCTEC05' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Receber'    ACTION 'VIEWDEF.RCTEC05' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Romaneio'    ACTION 'U_RCTECR1' OPERATION 2 ACCESS 0

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
	//oModel:getModel("SF1MASTER"):GetStruct():SetProperty("B1_COD", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
	oModel:getModel('SD1DETAIL' ):SetDescription('Itens')

	// Faz o relacionamento entre as estruturas, o fonte ira realizar as validações necessarias por este relacionamento.

	oModel:SetRelation( 'SD1DETAIL'	 , { { 'D1_FILIAL', 'F1_FILIAL' } ,{ 'D1_EMISSAO', 'F1_EMISSAO' }, { 'D1_DOC', 'F1_DOC' }, { 'D1_SERIE', 'F1_SERIE' },{ 'D1_FORNECE', 'F1_FORNECE' },{ 'D1_LOJA', 'F1_LOJA' }    } , SD1->( IndexKey( 3 ) ) )

	oModel:SetVldActivate( { |oModel| sfValAtiva( oModel ) } )

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel('RCTEC05')
	Local cSolicit := ""
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
	CASE cCampo = "F1_SOLICIT" ; RETURN .T.
	CASE cCampo = "F1_EMISSAO" ; RETURN .T.
	CASE cCampo = "F1_EST" ; RETURN .T.
		//CASE cCampo = "F1_XRECEB" ; RETURN .T.
	CASE cCampo = "F1_NOMEFOR" ; RETURN .T.
	CASE cCampo = "F1_STATUS"  ; RETURN .T.
	ENDCASE
Return(lRet)

//Campos usados no browse

Static Function STRUDETAIL(cCampo)
	Local lRet	:= .F.
	DO CASE
	CASE cCampo = "D1_ITEM" ; RETURN .T.
	CASE cCampo = "D1_COD" ; RETURN .T.
	CASE cCampo = "D1_UM" ; RETURN .T.
	CASE cCampo = "D1_SEGUM" ; RETURN .T.
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
	//oBtnRom := TButton():New(001,190 , "Romaneio", oPanel, {|| U_RCTECR1()},nLargBtn)

RETURN

USER FUNCTION ConfReceb()
	//PARAMETRO COM OS USUARIOS DA PORTARIA
	Local cUsrPor := SuperGetMV("MV_PORTARI", .F., " ")


	IF !(__cUserId $ cUsrPor)

		U_CLAS103()

		oViewActive := FWViewActive()

		oViewActive:oOwner:End()

	ELSE
		MSGSTOP("USUÁRIO SEM PERMISSÃO - RCTEC05")
	ENDIF
RETURN

USER FUNCTION CancReceb()
	//PARAMETRO COM OS USUARIOS DA PORTARIA
	Local cUsrPor := SuperGetMV("MV_PORTARI", .F., " ")

	IF !(__cUserId $ cUsrPor)

		U_DEL103()

		oViewActive := FWViewActive()

		oViewActive:oOwner:End()

	ELSE
		MSGSTOP("USUÁRIO SEM PERMISSÃO - RCTEC05")
	ENDIF
RETURN

USER FUNCTION CLAS103()

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local nOpc := 4 // Classificação
	Local nI := 0
	Local nX := 0
	Local nReg := 1

	IF SF1->F1_STATUS == 'A'
		MSGSTOP("NOTA JA CLASSIFICADA")
		RETURN .F.
	ENDIF

	Conout("Inicio Classificacao RCTEC05: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	cPedido := POSICIONE("SD1",1,xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA, "D1_PEDIDO")

	DBSELECTAREA("SD1")
	DBSETORDER(1)
	DBGOTOP()
	IF(DBSEEK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

		//Cabeçalho
		aadd(aCab,{"F1_FILIAL" , SF1->F1_FILIAL ,NIL})
		aadd(aCab,{"F1_TIPO" , SF1->F1_TIPO ,NIL})
		aadd(aCab,{"F1_FORMUL" ,SF1->F1_FORMUL ,NIL})
		aadd(aCab,{"F1_DOC" ,SF1->F1_DOC ,NIL})
		aadd(aCab,{"F1_SERIE" ,SF1->F1_SERIE ,NIL})
		aadd(aCab,{"F1_EMISSAO" ,DDATABASE ,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,DDATABASE ,NIL})
		//aadd(aCab,{"F1_XRECEB" ,SF1->F1_XRECEB ,NIL})
		aadd(aCab,{"F1_FORNECE" ,SF1->F1_FORNECE ,NIL})
		aadd(aCab,{"F1_LOJA" ,SF1->F1_LOJA ,NIL})
		aadd(aCab,{"F1_ESPECIE" ,SF1->F1_ESPECIE ,NIL})
		//aadd(aCab,{"F1_COND" ,SF1->F1_COND ,NIL})
		aadd(aCab,{"F1_DESPESA" ,SF1->F1_DESPESA,NIL})
		aadd(aCab,{"F1_DESCONT" ,SF1->F1_DESCONT,Nil})
		aadd(aCab,{"F1_SEGURO" ,SF1->F1_SEGURO,Nil})
		aadd(aCab,{"F1_FRETE" ,SF1->F1_FRETE,Nil})
		aadd(aCab,{"F1_MOEDA" ,SF1->F1_MOEDA,Nil})
		aadd(aCab,{"F1_TXMOEDA" ,SF1->F1_TXMOEDA,Nil})
		aadd(aCab,{"F1_STATUS" ,SF1->F1_STATUS,Nil})
		aadd(aCab,{"F1_NFORIG" ,SF1->F1_NFORIG,Nil})
		aadd(aCab,{"F1_SERORIG" ,SF1->F1_SERORIG,Nil})
		aadd(aCab,{"E2_NATUREZ" ,"010456",Nil})

		//Itens
		aItem := {}
		WHILE !SD1->(Eof()) .AND. SF1->F1_FILIAL = SD1->D1_FILIAL .AND. ;
				SF1->F1_DOC = SD1->D1_DOC .AND. SF1->F1_SERIE = SD1->D1_SERIE .AND. ;
				SF1->F1_FORNECE = SD1->D1_FORNECE .AND. SF1->F1_LOJA = SD1->D1_LOJA
	
			aItem := {}
			aAdd(aItem,{"LINPOS" , "D1_ITEM",SD1->D1_ITEM })
			aadd(aItem,{"D1_FILIAL" ,SD1->D1_FILIAL,NIL})
			//aadd(aItem,{"D1_ITEM" ,SD1->D1_ITEM,NIL})
			aadd(aItem,{"D1_COD" ,SD1->D1_COD,NIL})
			aadd(aItem,{"D1_UM" ,SD1->D1_UM,NIL})
			aadd(aItem,{"D1_QUANT" ,SD1->D1_QUANT,NIL})
			aadd(aItem,{"D1_VUNIT" ,SD1->D1_VUNIT,NIL})
			aadd(aItem,{"D1_TOTAL" ,SD1->D1_TOTAL,NIL})
			aadd(aItem,{"D1_CONTA" ,SD1->D1_CONTA,NIL})
			aadd(aItem,{"D1_TES" ,SD1->D1_TESACLAS,NIL})
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
			//aadd(aItem,{"D1_PEDIDO" ,SD1->D1_PEDIDO,NIL})
			//aadd(aItem,{"D1_ITEMPC" ,SD1->D1_ITEMPC,NIL})
			aadd(aItem,{"D1_LOCAL" ,SD1->D1_LOCAL,NIL})
			aadd(aItem,{"D1_GRUPO" ,SD1->D1_GRUPO,NIL})
			aadd(aItem,{"D1_TIPO" ,SD1->D1_TIPO,NIL})
			aadd(aItem,{"D1_NUMSEQ" ,SD1->D1_NUMSEQ,NIL})
			aadd(aItem,{"D1_TP" ,SD1->D1_TP,NIL})
			aadd(aItem,{"D1_QTSEGUM" ,SD1->D1_QTSEGUM,NIL})
			aadd(aItem,{"D1_SEQCALC" ,SD1->D1_SEQCALC,NIL})
			aadd(aItem,{"D1_BASEICM" ,SD1->D1_BASEICM,NIL})
			aadd(aItem,{"D1_DTVALID" ,SD1->D1_DTVALID,NIL})
			aadd(aItem,{"D1_CLASFIS" ,SD1->D1_CLASFIS,NIL})
			aadd(aItem,{"D1_CUSTO" ,SD1->D1_CUSTO,NIL})
			aadd(aItem,{"D1_QTDPEDI" ,SD1->D1_QTDPEDI,NIL})
			aadd(aItem,{"D1_RATEIO" ,SD1->D1_RATEIO,NIL})
			aadd(aItem,{"D1_BASEINS" ,SD1->D1_BASEINS,NIL})
			aadd(aItem,{"D1_RGESPST" ,SD1->D1_RGESPST,NIL})
			aadd(aItem,{"D1_ALIQSOL" ,SD1->D1_ALIQSOL,NIL})
			aadd(aItem,{"D1_BASEPIS" ,SD1->D1_BASEPIS,NIL})
			aadd(aItem,{"D1_BASECOF" ,SD1->D1_BASECOF,NIL})
			aadd(aItem,{"D1_BASECSL" ,SD1->D1_BASECSL,NIL})
			aadd(aItem,{"D1_VALPIS" ,SD1->D1_VALPIS,NIL})
			aadd(aItem,{"D1_VALCOF" ,SD1->D1_VALCOF,NIL})
			aadd(aItem,{"D1_VALCSL" ,SD1->D1_VALCSL,NIL})
			aadd(aItem,{"D1_ALQPIS" ,SD1->D1_ALQPIS,NIL})
			aadd(aItem,{"D1_ALQCOF" ,SD1->D1_ALQCOF,NIL})
			aadd(aItem,{"D1_ALQCSL" ,SD1->D1_ALQCSL,NIL})
			aadd(aItem,{"D1_ALIQCMP" ,SD1->D1_ALIQCMP,NIL})
			aadd(aItem,{"D1_NFORI" ,SD1->D1_NFORI,NIL})
			aadd(aItem,{"D1_SERIORI" ,SD1->D1_SERIORI,NIL})
			aadd(aItem,{"AUTDELETA" ,"N",Nil,Nil})
			aAdd(aItens,aItem)
			aadd(Atail(aItens), {"LINPOS" , "D1_PEDIDO",SD1->D1_PEDIDO })
          	aadd(Atail(aItens), {"LINPOS" , "D1_ITEMPC",SD1->D1_ITEMPC })
			
			SD1->(dbskip())
		ENDDO

		//aCab := FWVetByDic(aCab, 'SF1')
		//aItens := FWVetByDic(aItens, 'SD1', .T.)

		ASort(aItens,,, {|x, y| x[1][3] < y[1][3]})

		//3-Inclusão / 4-Classificação / 5-Exclusão
		FWMsgRun(,{|| MSExecAuto({|x,y,z,w| MATA103(x,y,z,w)},aCab,aItens,nOpc,.T.)},"Aguarde","Classificando Nota...") 

		If !lMsErroAuto
			ConOut(" NF Classificada RCTEC05: " + SF1->F1_DOC)
			FWAlertSuccess("Classificada com Sucesso!", "Sucesso")
			Reclock("SF1",.F.)
			SF1->F1_XSTATUS := 'A'
			SF1->F1_USRREC := __cUserId
			MSUNLOCK()
		Else
			MostraErro()
			ConOut("Erro na Classificação RCTEC05")
		EndIf

		ConOut("Fim Classificacao RCTEC05: " + Time())
	ELSE
		CONOUT("Item não encontrado.")
	ENDIF

	DBCLOSEAREA("SD1")

Return

USER FUNCTION DEL103()

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local aItensRat := {}
	Local aCodRet := {}
	Local nOpc := 5 // Exclusão
	Local nI := 0
	Local nX := 0
	Local nReg := 1

	IF SF1->F1_STATUS == 'A'
		MSGSTOP("NOTA JA CLASSIFICADA")
		RETURN .F.
	ENDIF

	Conout("Inicio Exclusao RCTEC05: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	DBSELECTAREA("SD1")
	DBSETORDER(1)
	DBGOTOP()
	IF(DBSEEK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

		//Cabeçalho
		aadd(aCab,{"F1_TIPO" , SF1->F1_TIPO ,NIL})
		aadd(aCab,{"F1_FORMUL" ,SF1->F1_FORMUL ,NIL})
		aadd(aCab,{"F1_DOC" ,SF1->F1_DOC ,NIL})
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
		aadd(aCab,{"E2_NATUREZ" ,"010456",Nil})

		//Itens
		aItem := {}
		WHILE !SD1->(Eof()) .AND. SF1->F1_FILIAL = SD1->D1_FILIAL .AND. ;
				SF1->F1_DOC = SD1->D1_DOC .AND. SF1->F1_SERIE = SD1->D1_SERIE .AND. ;
				SF1->F1_FORNECE = SD1->D1_FORNECE .AND. SF1->F1_LOJA = SD1->D1_LOJA

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
			aadd(aItem,{"D1_NUMSEQ" ,SD1->D1_NUMSEQ,NIL})
			aadd(aItem,{"D1_TP" ,SD1->D1_TP,NIL})
			aadd(aItem,{"D1_QTSEGUM" ,SD1->D1_QTSEGUM,NIL})
			aadd(aItem,{"D1_SEQCALC" ,SD1->D1_SEQCALC,NIL})
			aadd(aItem,{"D1_BASEICM" ,SD1->D1_BASEICM,NIL})
			aadd(aItem,{"D1_DTVALID" ,SD1->D1_DTVALID,NIL})
			aadd(aItem,{"D1_CLASFIS" ,SD1->D1_CLASFIS,NIL})
			aadd(aItem,{"D1_CUSTO" ,SD1->D1_CUSTO,NIL})
			aadd(aItem,{"D1_RATEIO" ,SD1->D1_RATEIO,NIL})
			aadd(aItem,{"D1_BASEINS" ,SD1->D1_BASEINS,NIL})
			aadd(aItem,{"D1_RGESPST" ,SD1->D1_RGESPST,NIL})
			aadd(aItem,{"D1_ALIQSOL" ,SD1->D1_ALIQSOL,NIL})
			aadd(aItem,{"D1_BASEPIS" ,SD1->D1_BASEPIS,NIL})
			aadd(aItem,{"D1_BASECOF" ,SD1->D1_BASECOF,NIL})
			aadd(aItem,{"D1_BASECSL" ,SD1->D1_BASECSL,NIL})
			aadd(aItem,{"D1_VALPIS" ,SD1->D1_VALPIS,NIL})
			aadd(aItem,{"D1_VALCOF" ,SD1->D1_VALCOF,NIL})
			aadd(aItem,{"D1_VALCSL" ,SD1->D1_VALCSL,NIL})
			aadd(aItem,{"D1_ALQPIS" ,SD1->D1_ALQPIS,NIL})
			aadd(aItem,{"D1_ALQCOF" ,SD1->D1_ALQCOF,NIL})
			aadd(aItem,{"D1_ALQCSL" ,SD1->D1_ALQCSL,NIL})
			aadd(aItem,{"D1_ALIQCMP" ,SD1->D1_ALIQCMP,NIL})
			aAdd(aItens,aItem)
			SD1->(dbskip())
		ENDDO

		//3-Inclusão / 4-Classificação / 5-Exclusão
		//MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc,/*aItensRat*/,/*aCodRet*/)
		MSExecAuto({|x, y, z| MATA140(x, y, z)}, aCab, aItens, nOpc)

		If !lMsErroAuto
			ConOut(" NF Excluida RCTEC05: " + SF1->F1_DOC)
		Else
			MostraErro()
			ConOut("Erro na Exclusao RCTEC05")
		EndIf

		ConOut("Fim Exclusao RCTEC05: " + Time())

	ENDIF

	DBCLOSEAREA("SD1")


Return

// FUNCAO PARA BUSCAR O NOME DO solicitante NA SC1
USER FUNCTION nSolicit()

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


RETURN
