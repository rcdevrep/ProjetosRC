#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _cTab7 := Upper(AllTrim(GetNewPar("MV_ZGOTAB7", ""))) // Usuários com acesso ao importador
Static _cCmp7 := IIf(SubStr(_cTab7, 1, 1) == "S", SubStr(_cTab7, 2, 2), _cTab7)
	
// Usuários do Importador

User Function GOX014()
	
	Local aRotAux := IIf(Type("aRotina") # "U", aRotina, Nil)
	
	aRotina := Nil
	
	If Empty(_cTab7)
		
		MsgInfo("A tabela de usuários do importador deve estar criada!")
		
		Return
		
	EndIf
	
	If !(__cUserId $ GetNewPar("MV_XGTGERP", ""))
		
		MsgInfo("Você não tem acesso a essa rotina!")
		
		Return
		
	EndIf
	
	Private oBrwUsu := FWMBrowse():New()
	
	oBrwUsu := FWMBrowse():New()
	oBrwUsu:SetAlias(_cTab7)
	oBrwUsu:SetMenuDef("GOX014")
	oBrwUsu:SetDescription("Usuários Importador")
	
	oBrwUsu:Activate()
	
	aRotina := aRotAux
	
Return

// -----------------

Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.GOX014" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.GOX014" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.GOX014" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.GOX014" OPERATION MODEL_OPERATION_DELETE ACCESS 0
	
Return aRotina

// -----------------

Static Function ModelDef()
	
	Local oModel
	
	Local oStructUsu := FWFormStruct(1, _cTab7)
	
	oModel := MPFormModel():New("GOX14USU",, {|oModel| GOX14POS(oModel)}, /*bCommit*/, /*{|oModel| GOX7CAN(oModel)}/*bCancel*/)
	
	oModel:SetVldActivate({|oModel| GOX14VLD(oModel)})
	
	oModel:AddFields("GOX014_USU", Nil, oStructUsu, /*bPre*/ ,/**/,/*bLoad*/)
	
	oModel:SetPrimaryKey({_cCmp7 + "_FILIAL", _cCmp7 + "_USU"})
	
Return oModel

// -----------------

Static Function ViewDef()
	
	Local oModel     := FWLoadModel("GOX014")
	Local oView
	      
	Local oStructUsu := FWFormStruct(2, _cTab7)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField("GOX014_USU", oStructUsu)
	
	// Montagem da Tela
	
	oView:CreateHorizontalBox("USUARIO", 100)
			
		oView:SetOwnerView("GOX014_USU", "USUARIO")
		
Return oView

// -----------------

Static Function GOX14POS()
	
	
	
Return .T.

// -----------------

Static Function GOX14VLD()
	
	
	
Return .T.

// -----------------

User Function GOX14POS()
	
	If !Empty(_cTab7)
		
		dbSelectArea(_cTab7)
		(_cTab7)->( dbSetOrder(1) )
		If (_cTab7)->( dbSeek(xFilial(_cTab7) + __cUserId) )
			
			Return .T.
			
		EndIf
		
		dbSelectArea(_cTab7)
		(_cTab7)->( dbSetOrder(1) )
		If (_cTab7)->( dbSeek(xFilial(_cTab7) + PadR("*", 6)) )
			
			Return .T.
			
		EndIf
		
		Return .F.
		
	EndIf
	
Return .F.

// --------------------- Indica que pode importar CT-e

User Function GOX14CTE()
	
Return (_cTab7)->&(_cCmp7 + "_CTE")

// --------------------- Indica que pode importar por pré-nota

User Function GOX14PRE()
	
Return (_cTab7)->&(_cCmp7 + "_PRENOT")

// --------------------- Indica que só pode importar Pré-Nota

User Function GOX14SPN()
	
Return (_cTab7)->&(_cCmp7 + "_PRENOT") .And. !(_cTab7)->&(_cCmp7 + "_RETORN") .And. (_cTab7)->&(_cCmp7 + "_PRENOT") .And. !(_cTab7)->&(_cCmp7 + "_NFCLAS")

// --------------------- Indica se pode importar nota Já Classificada

User Function GOX14NFC()
	
Return (_cTab7)->&(_cCmp7 + "_NFCLAS")

// --------------------- Indica se pode importar usar o Retornar

User Function GOX14RET()
	
Return (_cTab7)->&(_cCmp7 + "_RETORN")

// --------------------- Indica que pode classificar nota

User Function GOX14CLA()
	
Return (_cTab7)->&(_cCmp7 + "_CLASS")

// --------------------- Indica que pode ver o menu de rotinas

User Function GOX14ROT()
	
Return (_cTab7)->&(_cCmp7 + "_ROTINA")

// --------------------- Indica que pode ver o menu de relatórios

User Function GOX14REL()
	
Return (_cTab7)->&(_cCmp7 + "_RELAT")

// --------------------- Indica que pode importar Nota Fiscal

User Function GOX14NF()
	
Return (_cTab7)->&(_cCmp7 + "_NFEN") .Or. (_cTab7)->&(_cCmp7 + "_NFEC") .Or. (_cTab7)->&(_cCmp7 + "_NFED")

// --------------------- Indica que pode importar Nota Fiscal Normal

User Function GOX14NFN()
	
Return (_cTab7)->&(_cCmp7 + "_NFEN")

// --------------------- Indica que pode importar Nota Fiscal Complementar

User Function GOX14NCO()
	
Return (_cTab7)->&(_cCmp7 + "_NFEC")

// --------------------- Indica que pode importar Nota Fiscal de Devolução

User Function GOX14NFD()
	
Return (_cTab7)->&(_cCmp7 + "_NFED")

// --------------------- Indica que é um Usuário de Liberação (Só quando utilizar esse processo!)

User Function GOX14LIB()
	
Return (_cTab7)->&(_cCmp7 + "_LIBER")

// --------------------- Indica que é permitido selecionar a nota origem de uma nota normal

User Function GOX14NFO()
	
Return (_cTab7)->&(_cCmp7 + "_NFORI")

// --------------------- Indica se é obrigatório informar o pedido de compras numa nota normal

User Function GOX14PC()
	
Return (_cTab7)->&(_cCmp7 + "_PCCOMP")
