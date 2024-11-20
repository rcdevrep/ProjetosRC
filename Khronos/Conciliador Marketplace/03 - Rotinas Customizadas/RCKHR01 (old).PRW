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
// ROTINA RCKHR01 - RC1_CONCR MARKETPLACE 
// PROJETO - RC1_CONCR MARKETPLACE
// DATA - 09/10/2024

User Function RCKHR01()

	Local   oBrowse
	Local aArea    := GetArea()
    Local cQuery := ""
	Local cQuery1 := ""
	Local aFields := {}
	Local aIndex := {}
	Local aFields1 := {}
	Local aColunas := {}
	Local oRcTemp1,oRcTemp2,oRcTemp3
	Private MV_PAR01 := DATE()-30
	Private MV_PAR02 := DATE()
	Private cAlisCab   := GetNextAlias()
    Private cAlisGr1   := GetNextAlias()
    Private cAlisGr2   := GetNextAlias()

	cPerg    := "RCKHR01"
	
	//MV_PAR01 = Data de...
	//MV_PAR02 = Data até...
	//PERGUNTE(cPerg,.T.)

	IF (Select("TEMPKHR1") <> 0)
		DBSELECTAREA("TEMPKHR1")
		DBCLOSEAREA()
	ENDIF   

	IF (Select("TEMPKHR2") <> 0)
		DBSELECTAREA("TEMPKHR2")
		DBCLOSEAREA()
	ENDIF  

	//FIELDS JANELA PRINCIAPAL
	aAdd(aFields,{"RC1_TIPO","C",10,0})
	aAdd(aFields,{"RC1_PERIOD","D",08,0})
	aAdd(aFields,{"RC1_TOTAL","N",10,0})
	aAdd(aFields,{"RC1_CONC","N",10,0})
	aAdd(aFields,{"RC1_PEND","N",10,0})
	aAdd(aFields,{"RC1_MOVIM","N",10,0})

	//FIELDS JANELA 1
	aAdd(aFields1,{"RC2_NUM","C",10,0})
	aAdd(aFields1,{"RC2_TIPO","C",10,0})
	aAdd(aFields1,{"RC2_VALOR","N",10,0})
	aAdd(aFields1,{"RC2_EMISSA","D",08,0})
	aAdd(aFields1,{"RC2_PARCEL","C",3,0})
	aAdd(aFields1,{"RC2_VENC","D",08,0})

	oRcTemp1 := FWTemporaryTable():New(cAlisCab)
	oRcTemp1:SetFields(aFields)
	oRcTemp1:AddIndex( 'Periodo', {"RC1_PERIOD"})
	oRcTemp1:Create()



	oRcTemp2 := FWTemporaryTable():New('RCTEMP2')
	oRcTemp2:SetFields(aFields1)
	oRcTemp2:AddIndex( 'Periodo', {"RC2_VENC"})
	oRcTemp2:Create()

	//oRcTemp3 := FWTemporaryTable():New('RCTEMP3')
	//oRcTemp3:SetFields(aFields)
//	oRcTemp3:Create()


	// QUERY JANELA PRINCIPAL
	cQuery := "SELECT RC1_TIPO, TAB.RC1_PERIOD, RC1_TOTAL, RC1_CONC, RC1_PEND, RC1_MOVIM FROM ( "
    cQuery += "SELECT 'REDECARD' RC1_TIPO, E1_VENCREA RC1_PERIOD, SUM(E1_VALOR) RC1_TOTAL,  SUM(E1_VALOR - E1_SALDO) RC1_CONC, SUM(E1_SALDO) RC1_PEND "
	cQuery += "FROM "+RetSQLName("SE1")+" SE1 " 
	cQuery += "WHERE SE1.D_E_L_E_T_ = ' ' " 
	cQuery += "AND E1_TIPO IN ('MAQ','CC','CD') " 
    cQuery += "AND E1_VENCREA >= '"+DTOS(MV_PAR01)+"' AND E1_VENCREA <= '"+DTOS(MV_PAR02)+"' "
    cQuery += "GROUP BY E1_VENCREA) TAB " 
    cQuery += "INNER JOIN (SELECT 'REDECARD', E5_DATA RC1_PERIOD, SUM(E5_VALOR) RC1_MOVIM from "+RetSQLName("SE5")+" WHERE E5_HISTOR LIKE 'BX. AUTO ARQUIVO%' "
	cQuery += "AND E5_NATUREZ = 'CARTAO' AND E5_DATA >= '20240101' AND D_E_L_E_T_ <> '*'  AND E5_MOEDA = 'M1' "
    cQuery += "GROUP BY E5_DATA) TAB2 on TAB2.RC1_PERIOD = TAB.RC1_PERIOD " 
    cQuery += "ORDER BY TAB.RC1_PERIOD "

	TCQuery cQuery NEW ALIAS "TEMPKHR1"	

	WHILE !TEMPKHR1->(Eof())
		RECLOCK("RCTEMP1",.T.)
		(cAlisCab)->RC1_TIPO := TEMPKHR1->RC1_TIPO
		(cAlisCab)->RC1_PERIOD := STOD(TEMPKHR1->RC1_PERIOD)
		(cAlisCab)->RC1_TOTAL := TEMPKHR1->RC1_TOTAL
		(cAlisCab)->RC1_CONC := TEMPKHR1->RC1_CONC
		(cAlisCab)->RC1_PEND := TEMPKHR1->RC1_PEND
		(cAlisCab)->RC1_MOVIM := TEMPKHR1->RC1_MOVIM
		MSUNLOCK()
		TEMPKHR1->(DbSkip())
	ENDDO

//QUERY -> 
	//QUERY JANELA 1 MOSTRA TITULOS EM ABERTO

		IF(Select('TEMPKHR2') > 0)
			TEMPKHR2->(DbCloseArea())
		Endif

		cQuery1 := "SELECT E1_NUM RC2_NUM,E1_TIPO RC2_TIPO,E1_VALOR RC2_VALOR, E1_EMIS1 RC2_EMISSA, E1_PARCELA RC2_PARCEL, E1_VENCREA RC2_VENC "
		cQuery1 += "FROM "+RetSQLName("SE1")+" " 
   		cQuery1 += "WHERE E1_VENCREA >= '"+DTOS(MV_PAR01)+"' AND E1_VENCREA <= '"+DTOS(MV_PAR02)+"' "
		cQuery1 += "AND E1_TIPO IN ('MAQ','CC','CD') " 
		cQuery1 += "AND E1_NOMCLI = 'REDECARD' AND E1_SALDO > 0 "
		cQuery1 += "AND D_E_L_E_T_ <> '*'  " 
		cQuery1 += "ORDER BY E1_NUM "

		TCQuery cQuery1 NEW ALIAS "TEMPKHR2"	

		
		Dbselectarea("TEMPKHR2")

		WHILE !TEMPKHR2->(Eof())
			RECLOCK("RCTEMP2",.T.)
			RCTEMP2->RC2_NUM := TEMPKHR2->RC2_NUM
			RCTEMP2->RC2_TIPO := TEMPKHR2->RC2_TIPO
			RCTEMP2->RC2_VALOR := TEMPKHR2->RC2_VALOR
			RCTEMP2->RC2_EMISSA := STOD(TEMPKHR2->RC2_EMISSA)
			RCTEMP2->RC2_PARCEL := TEMPKHR2->RC2_PARCEL
			RCTEMP2->RC2_VENC := STOD(TEMPKHR2->RC2_VENC)
			MSUNLOCK()
			TEMPKHR2->(DbSkip())
		ENDDO


	
/*
	WHILE !TEMPKHR1->(Eof())
		RECLOCK("RCTEMP3",.T.)
		RCTEMP3->RC1_TIPO := TEMPKHR1->RC1_TIPO
		RCTEMP3->RC1_PERIOD := STOD(TEMPKHR1->RC1_PERIOD)
		RCTEMP3->RC1_TOTAL := TEMPKHR1->RC1_TOTAL
		RCTEMP3->RC1_CONC := TEMPKHR1->RC1_CONC
		RCTEMP3->RC1_PEND := TEMPKHR1->RC1_PEND
		RCTEMP3->RC1_MOVIM := TEMPKHR1->RC1_MOVIM
		MSUNLOCK()
		TEMPKHR1->(DbSkip())
	ENDDO*/

	//COLUNAS DO BROWSE
	//aAdd(aColunas,{"OK","OK", "L",1,0,,})
	aAdd(aColunas, {"RC1_TIPO", "RC1_TIPO", "C", 10, 0, "@!"})
    aAdd(aColunas, {"RC1_PERIOD","RC1_PERIOD", "D", 08, 0, "@D"})
    aAdd(aColunas, {"RC1_TOTAL","RC1_TOTAL", "N", 10, 0, "@E 9,999,999.99"})
	aAdd(aColunas, {"RC1_CONC","RC1_CONC", "N", 10, 0, "@E 9,999,999.99"})
	aAdd(aColunas, {"RC1_PEND","RC1_PEND", "N", 10, 0, "@E 9,999,999.99"})
    aAdd(aColunas, {"RC1_MOVIM","RC1_MOVIM", "N", 10, 0, "@E 9,999,999.99"})
	
	//CRIA O BROWSE DA PRIMEIRA TELA
    oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias(cAlisCab)
	//oBrowse:SetAlias('SE1')
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(aColunas)
	oBrowse:SetDescription( "Conciliador Mkt/Cartões" )
	oBrowse:SetMenuDef("RCKHR01")
	//oBrowse:AddFilter('Status',"SF1->F1_STATUS = 'Z'",.T.,.T.)
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '0'}        ,'BR_VERDE'  ,'Não Iniciado/RC1_PEND')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '1'}        ,'BR_AMARELO'  ,'Setup OK')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '2'}        ,'BR_LARANJA'  ,'Moldagem OK')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '3'}        ,'BR_VERMELHO'  ,'Dureza 10/12min OK')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '4'}        ,'BR_PRETO'  ,'Teto Finalizado')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '5'}        ,'BR_PRETO'  ,'Dureza OK')
	oBrowse:Activate()
	RestArea(aArea)

Return 

Static Function MenuDef()

	Local aRotina := {}

	//ADD OPTION aRotina TITLE 'Incluir' ACTION 'U_fIncTeto' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Conciliar'    ACTION 'VIEWDEF.RCKHR01' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Relatorio'    ACTION 'U_RCTECR2' OPERATION 2 ACCESS 0

Return(aRotina)

Static Function ModelDef()

	// MODEL MAIN
	Local oModel := Nil
	Private oStMain  := FWFormModelStruct():New()

	//Instanciando o modelo
    oModel := MPFormModel():New("MODEL1",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	// Cria descrições para os objetos, para que seja possivel a chamada pelo nome posteriormente.
	oModel:getModel('MASTER')
	//:SetDescription('RC1_CONCr Marketplace')

	// Cria Tabela para Receber os Dados
	oStMain:AddTable('RCTEMP1', {'RC1_TIPO', 'RC1_PERIOD', 'RC1_TOTAL', 'RC1_CONC','RC1_PEND','RC1_MOVIM'},"Conciliador", {|| oRcTemp1:GetRealName()})

	// [01]  C   Titulo do campo
    // [02]  C   ToolTip do campo
    // [03]  C   Id do Field
    // [04]  C   RC1_TIPO do campo
    // [05]  N   Tamanho do campo
    // [06]  N   Decimal do campo
    // [07]  B   Code-block de validação do campo
    // [08]  B   Code-block de validação When do campo
    // [09]  A   Lista de RC2_VALORes permitido do campo
    // [10]  L   Indica se o campo tem preenchimento obrigatório
    // [11]  B   Code-block de inicializacao do campo
    // [12]  L   Indica se trata-se de um campo chave
    // [13]  L   Indica se o campo pode receber RC2_VALOR em uma operação de update.
	
	 //Adiciona os campos da estrutura
	//oStMain:AddField( " ", " ", "OK", "L", 1, 0, FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"), FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"), Nil, .F., Nil, .F., .F., .T.)
    oStMain:AddField("RC1_TIPO","RC1_TIPO","RC1_TIPO","C",08,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_TIPO,'')" ),.T.,.F.,.F.) 
	oStMain:AddField("RC1_PERIOD","RC1_PERIOD","RC1_PERIOD","D",08,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_PERIOD,'')" ),.T.,.F.,.F.) 
	oStMain:AddField("RC1_TOTAL","RC1_TOTAL","RC1_TOTAL","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_TOTAL,'')" ),.T.,.F.,.F.) 
	oStMain:AddField("RC1_CONC","RC1_CONC","RC1_CONC","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_CONC,'')" ),.T.,.F.,.F.) 
	oStMain:AddField("RC1_PEND","RC1_PEND","RC1_PEND","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_PEND,'')" ),.T.,.F.,.F.) 
	oStMain:AddField("RC1_MOVIM","RC1_MOVIM","RC1_MOVIM","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_MOVIM,'')" ),.T.,.F.,.F.) 

	// Associa os objetos visuais criados com as estruturas criadas, desta forma ira criar os campos conforme as estrutura.
    oModel:AddFields("MASTER",/*cOwner*/,oStMain)

	// MODEL JANELA 1
	Private oStJan1  := FWFormModelStruct():New()



	// Cria descrições para os objetos, para que seja possivel a chamada pelo nome posteriormente.
	oModel:getModel('JANELA1')
	//:SetDescription('Janela 1')

	// Cria Tabela para Receber os Dados
	oStJan1:AddTable('RCTEMP2', {'RC2_NUM','RC2_TIPO', 'RC2_VALOR', 'RC2_EMISSA'},"Titulos em aberto" ,  {|| oRcTemp2:GetRealName()})

	//Adiciona os campos da estrutura
	oStJan1:AddField( " ", " ", "OK", "L", 1, 0, FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"), FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"), Nil, .F., Nil, .F., .F., .T.)
    oStJan1:AddField("RC2_NUM","RC2_NUM","RC2_NUM","C",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, RCTEMP2->RC2_NUM,'')" ),.T.,.F.,.F.) 
	oStJan1:AddField("RC2_TIPO","RC2_TIPO","RC2_TIPO","C",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, RCTEMP2->RC2_TIPO,'')" ),.T.,.F.,.F.) 
	oStJan1:AddField("RC2_VALOR","RC2_VALOR","RC2_VALOR","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, RCTEMP2->RC2_VALOR,'')" ),.T.,.F.,.F.) 
	oStJan1:AddField("RC2_EMISSA","RC2_EMISSA","RC2_EMISSA","D",08,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, RCTEMP2->RC2_EMISSA,'')" ),.T.,.F.,.F.) 
	oStJan1:AddField("RC2_PARCEL","RC2_PARCEL","RC2_PARCEL","C",03,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, RCTEMP2->RC2_PARCEL,'')" ),.T.,.F.,.F.) 
	oStJan1:AddField("RC2_VENC","RC2_VENC","RC2_VENC","D",08,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, RCTEMP2->RC2_VENC,'')" ),.T.,.F.,.F.) 

	// Cria o Grid para Receber os Dados
	oModel:AddGrid('JANELA1','MASTER',oStJan1)
	
	// Associa os objetos visuais criados com as estruturas criadas, desta forma ira criar os campos conforme as estrutura.
    //oModel:AddFields("JANELA1",/*cOwner*/,oStJan1)
	
	// MODEL JANELA 2
	//Private oStJan2  := FWFormModelStruct():New()

	// Cria descrições para os objetos, para que seja possivel a chamada pelo nome posteriormente.
	//oModel:getModel('JANELA2')
	//:SetDescription('Janela 2')

	// Cria Tabela para Receber os Dados
	//oStJan2:AddTable('RCTEMP3', {'RC1_TIPO', 'RC1_PERIOD', 'RC1_TOTAL', 'RC1_CONC','RC1_PEND','RC1_MOVIM'}, "RCTEMP3")

	//Adiciona os campos da estrutura
    /*oStJan2:AddField("RC1_TIPO","RC1_TIPO","RC1_TIPO","C",08,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_TIPO,'')" ),.T.,.F.,.F.) 
	oStJan2:AddField("RC1_PERIOD","RC1_PERIOD","RC1_PERIOD","D",08,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_PERIOD,'')" ),.T.,.F.,.F.) 
	oStJan2:AddField("RC1_TOTAL","RC1_TOTAL","RC1_TOTAL","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_TOTAL,'')" ),.T.,.F.,.F.) 
	oStJan2:AddField("RC1_CONC","RC1_CONC","RC1_CONC","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_CONC,'')" ),.T.,.F.,.F.) 
	oStJan2:AddField("RC1_PEND","RC1_PEND","RC1_PEND","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_PEND,'')" ),.T.,.F.,.F.) 
	oStJan2:AddField("RC1_MOVIM","RC1_MOVIM","RC1_MOVIM","N",10,0,Nil,Nil,{},.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, (cAlisCab)->RC1_MOVIM,'')" ),.T.,.F.,.F.) */

	// Cria o Grid para Receber os Dados
	//oModel:AddGrid('JANELA2','MASTER',oStJan2)
	
	// Associa os objetos visuais criados com as estruturas criadas, desta forma ira criar os campos conforme as estrutura.
    //oModel:AddFields("JANELA2",/*cOwner*/,oStJan2)

	// Cria chave primaria do cadastro principal.


	//oModel:getModel('JANELA1' ):SetOptional(.T.)

	// Faz o relacionamento entre as estruturas, o fonte ira realizar as validações necessarias por este relacionamento.

	oModel:SetRelation( 'JANELA1'	 , { { 'RC2_VENC','RC1_PERIOD'  } }, RCTEMP2->(IndexKey(1))  )
	//oModel:SetRelation( 'JANELA2'	 , { { 'ZT2_FILIAL', 'ZT0_FILIAL' } ,{ 'ZT2_CTETO', 'ZT0_CODIGO' } } , ZT2->( IndexKey( 1 ) ) )
	//oModel:SetRelation( 'ABA3'	 , { { 'ZT3_FILIAL', 'ZT0_FILIAL' } ,{ 'ZT3_CTETO', 'ZT0_CODIGO' } } , ZT3->( IndexKey( 1 ) ) )
	//oModel:SetRelation( 'ABA4'	 , { { 'ZT4_FILIAL', 'ZT0_FILIAL' } ,{ 'ZT4_CTETO', 'ZT0_CODIGO' } } , ZT4->( IndexKey( 1 ) ) )

    oModel:SetPrimaryKey({'RC1_PERIOD'})

	oModel:SetVldActivate( { |oModel| sfValAtiva( oModel ) } )

Return oModel

Static Function ViewDef(oView)

	Local oModel     := FWLoadModel('RCKHR01')
	Local oView	 := FWFormView():New()
	//Local aFbrw1 := {}

	oView:SetModel(oModel)

	// [01]  C   Nome do Campo
    // [02]  C   Ordem
    // [03]  C   Titulo do campo
    // [04]  C   Descricao do campo
    // [05]  A   Array com Help
    // [06]  C   RC1_TIPO do campo
    // [07]  C   Picture
    // [08]  B   Bloco de PictTre Var
    // [09]  C   Consulta F3
    // [10]  L   Indica se o campo é alteravel
    // [11]  C   Pasta do campo
    // [12]  C   Agrupamento do campo
    // [13]  A   Lista de RC2_VALORes permitido do campo (Combo)
    // [14]  N   Tamanho maximo da maior opção do combo
    // [15]  C   Inicializador de Browse
    // [16]  L   Indica se o campo é virtual
    // [17]  C   Picture Variavel
    // [18]  L   Indica pulo de linha após o campo

	// VIEW MAIN
	Private oStMain  := FWFormViewStruct():New()

	oStMain:AddField("RC1_TIPO","01","RC1_TIPO","RC1_TIPO", Nil,"C","@!",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStMain:AddField("RC1_PERIOD","02","RC1_PERIOD","RC1_PERIOD", Nil,"D","@D",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStMain:AddField("RC1_TOTAL","03","RC1_TOTAL","RC1_TOTAL", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStMain:AddField("RC1_CONC","04","RC1_CONC","RC1_CONC", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStMain:AddField("RC1_PEND","05","RC1_PEND","RC1_PEND", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStMain:AddField("RC1_MOVIM","06","RC1_MOVIM","RC1_MOVIM", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)

	oView:AddField('VIEW_MASTER',oStMain,'MASTER')

	//MARK BROWSE JANELA 1
	//Private oBrw1 := FWMarkBrowse():New()

	// ESTRUTURA DO ARRAY 
	//TABELA TEMPORÁRIA
	//[n][01] Descrição do campo
	//[n][02] Nome do campo
	//[n][03] RC1_TIPO
	//[n][04] Tamanho
	//[n][05] Decimal
	//[n][06] Picture

	//COLUNAS DO BROWSE
	//aAdd(aFbrw1, {"RC1_TIPO", "RC1_TIPO", "C", 10, 0, "@!"})
    //aAdd(aFbrw1, {"RC1_PERIOD","RC1_PERIOD", "D", 08, 0, "@D"})
    //aAdd(aFbrw1, {"RC1_TOTAL","RC1_TOTAL", "N", 10, 0, "@E 9,999,999.99"})
	//aAdd(aFbrw1, {"RC1_CONC","RC1_CONC", "N", 10, 0, "@E 9,999,999.99"})
	//aAdd(aFbrw1, {"RC1_PEND","RC1_PEND", "N", 10, 0, "@E 9,999,999.99"})
    //aAdd(aFbrw1, {"RC1_MOVIM","RC1_MOVIM", "N", 10, 0, "@E 9,999,999.99"})

	//oBrw1:SetAlias('RCTEMP2')
	//oBrowse:SetAlias('SE1')
	//oBrw1:SetTemporary(.T.)
	//oBrw1:SetFields(aFbrw1)
	//oBrw1:SetDescription( "Janela 1" )
	//oBrowse:SetMenuDef("RCKHR01")
	//oBrowse:AddFilter('Status',"SF1->F1_STATUS = 'Z'",.T.,.T.)
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '0'}        ,'BR_VERDE'  ,'Não Iniciado/RC1_PEND')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '1'}        ,'BR_AMARELO'  ,'Setup OK')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '2'}        ,'BR_LARANJA'  ,'Moldagem OK')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '3'}        ,'BR_VERMELHO'  ,'Dureza 10/12min OK')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '4'}        ,'BR_PRETO'  ,'Teto Finalizado')
	//oBrowse:addLegend({|| ZT0->ZT0_STATUS = '5'}        ,'BR_PRETO'  ,'Dureza OK')
	//oBrw1:Activate()



	
	// VIEW JANELA 1 
	Private oStJan1  := FWFormViewStruct():New()
	oStJan1:AddField("OK","01","Ok","Ok", Nil,"L","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan1:AddField("RC2_NUM","02","RC2_NUM","RC2_NUM", Nil,"C","@!",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan1:AddField("RC2_TIPO","03","RC2_TIPO","RC2_TIPO", Nil,"C","@!",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan1:AddField("RC2_VALOR","04","RC2_VALOR","RC2_VALOR", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan1:AddField("RC2_EMISSA","05","RC2_EMISSA","RC2_EMISSA", Nil,"D","@D",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan1:AddField("RC2_PARCEL","06","RC2_PARCEL","RC2_PARCEL", Nil,"C","@!",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan1:AddField("RC2_VENC","07","RC2_VENC","RC2_VENC", Nil,"D","@D",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)

	//oView:AddField('VIEW_JAN1',oStJan1,'JANELA1')
	//oView:SetViewProperty("VIEW_JAN1", "ENABLENEWGRID")
	oView:AddGrid('VIEW_JAN1' ,oStJan1,'JANELA1')


	// VIEW JANELA 2
	/*Private oStJan2  := FWFormViewStruct():New()
	oStJan2:AddField("RC1_TIPO","01","RC1_TIPO","RC1_TIPO", Nil,"C","@!",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan2:AddField("RC1_PERIOD","02","RC1_PERIOD","RC1_PERIOD", Nil,"D","@D",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan2:AddField("RC1_TOTAL","03","RC1_TOTAL","RC1_TOTAL", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan2:AddField("RC1_CONC","04","RC1_CONC","RC1_CONC", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan2:AddField("RC1_PEND","05","RC1_PEND","RC1_PEND", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	oStJan2:AddField("RC1_MOVIM","06","RC1_MOVIM","RC1_MOVIM", Nil,"N","@E 9,999,999.99",Nil,Nil,Iif(INCLUI, .T., .F.),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)*/

	//oView:AddField('VIEW_JAN2',oStJan2,'JANELA2')
	//oView:SetViewProperty("VIEW_JAN2", "ENABLENEWGRID")
	//oView:AddGrid('VIEW_JAN2' ,oStJan2,'JANELA2')
    //oView:EnableTitleView('VIEW_TMP', 'Dados - '+cTitulo )  

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

	// Criar um "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox('ESQUERDA',45, 'INFERIOR')
	oView:CreateVerticalBox('CENTRAL', 10, 'INFERIOR')
	oView:CreateVerticalBox('DIREITA', 45, 'INFERIOR')

	//BOTAO CONCILIAR
	oView:AddOtherObject('CENTRAL',{|oPanel|fBtnCon(oPanel)})
	//oView:AddOtherObject('ESQUERDA',{|oPanel|fBrw1(oPanel)})

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_MASTER','SUPERIOR')
	oView:SetOwnerView('VIEW_JAN1'	, 'ESQUERDA' )
	//oView:SetOwnerView('VIEW_JAN2'  , 'DIREITA')

	//Adiciona Incremento automatico no campo
	//oView:AddIncrementField( 'VIEW_ZT2', 'ZT2_ORDEM' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

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
	Local oModel1  := oModel:GetModel("JANELA1")
	//Local oModel2  := oModel:GetModel("JANELA2")
	//Local oModel3  := oModel:GetModel("ABA3")
	//Local oModel4  := oModel:GetModel("ABA4")
	Local aSaveLines := FWSaveRows()

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return(_lRet)

//Validação da linha
Static Function sfLinPre(oModel)
	Local lRet       := .T.
Return(lRet)

Static Function sfLinPre1(oModel)
	Local lRet       := .T.
Return(lRet)

Static Function sfLinPre2(oModel)
	Local lRet       := .T.
Return(lRet)

Static Function sfVldCpo(oModel,cCpo)

	Local lRet	     := .T.
	Local oModel     := FWModelActive()
	Local oModelM  := oModel:GetModel("MASTER")
	Local oModel1	 := oModel:GetModel('JANELA1')
	//Local oModel2	 := oModel:GetModel('JANELA2')
	//Local oModel3	 := oModel:GetModel('ABA3')
	//Local oModel4	 := oModel:GetModel('ABA4')
	Default cCpo     := ""

Return(lRet)

Static Function sfLinPos(oModel)
	Local lRet	     := .T.	
Return(lRet)

Static Function sfLinPos1(oModel)
	Local lRet	     := .T.
Return(lRet)

Static Function sfLinPos2(oModel)
	Local lRet	     := .T.	
Return(lRet)

//Retorno de campos que serao usados na janela principal
Static Function STRUMASTER(cCampo)
	Local lRet	  := .T.

	//DO CASE
	//CASE cCampo = "E1_PREFIXO" ; RETURN .T.
	//CASE cCampo = "E1_NUM" ; RETURN .T.
	//CASE cCampo = "E1_PARCELA" ; RETURN .T.
	//ENDCASE
Return(lRet)

//Retorno de campos que serao usados na Janela 1
Static Function STRU1(cCampo)
	Local lRet	:= .T.

	//DO CASE
	//CASE cCampo = "E1_PREFIXO" ; RETURN .T.
	//CASE cCampo = "E1_NUM" ; RETURN .T.
	//CASE cCampo = "E1_PARCELA" ; RETURN .T.
	//ENDCASE
Return(lRet)

//Retorno de campos que serao usados na Janela 2
Static Function STRU2(cCampo)
	Local lRet	:= .T.

	//DO CASE
	//CASE cCampo = "E1_PREFIXO" ; RETURN .T.
	//CASE cCampo = "E1_NUM" ; RETURN .T.
	//CASE cCampo = "E1_PARCELA" ; RETURN .T.
	//ENDCASE
Return(lRet)
Static Function BeforeCMdl(oModel)

	Local lRet	:= .T.
Return(lRet)

// BOTAO DE CONCILIAR
STATIC FUNCTION fBtnCon(oPanel)
	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	oBtnOt := TButton():New(10,107 , "Conciliar", oPanel, {|| U_fObserv(ZT0->ZT0_CODIGO)},nLargBtn)

RETURN
