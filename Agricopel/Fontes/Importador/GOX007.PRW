#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Cadastro de ação por CFOP

User Function GOX007()
	
	Local _cTab5  := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
	Local _cTab6  := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
	Local _cCmp5  := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
	Local _cCmp6  := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
	
	Local aRotAux := IIf(Type("aRotina") # "U", aRotina, Nil)
	
	aRotina := Nil
	
	Private oBrwCF := FWMBrowse():New()
	
	oBrwCF := FWMBrowse():New()
	oBrwCF:SetAlias(_cTab5)
	oBrwCF:SetMenuDef("GOX007")
	oBrwCF:SetDescription("Tipos de Nota por CFOP")
	
	oBrwCF:Activate()
	
	aRotina := aRotAux
	
Return

// -----------------

Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.GOX007" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.GOX007" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.GOX007" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.GOX007" OPERATION MODEL_OPERATION_DELETE ACCESS 0
	
Return aRotina

// -----------------

Static Function ModelDef()
	
	Local oModel
	Local oModelCF2 
	
	// Criação Local pois se caso um dia a inclusão for automática pelo LoadModel, não terá as variáveis Private criadas
	Local _cTab5     := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
	Local _cTab6     := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
	Local _cCmp5     := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
	Local _cCmp6     := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
	
	Local oStructCF1 := FWFormStruct(1, _cTab5)
	Local oStructCF2 := FWFormStruct(1, _cTab6)
	
	oModel := MPFormModel():New("GOX7CF",, {|oModel| GOX7POS(oModel)}, /*bCommit*/, /*{|oModel| GOX7CAN(oModel)}/*bCancel*/)
	
	oModel:SetVldActivate({|oModel| GOX7VLD(oModel)})
	
	oModel:AddFields("GOX007_CF1", Nil, oStructCF1, /*bPre*/ ,/**/,/*bLoad*/)
	oModel:SetPrimaryKey({_cCmp5+"_SEQ"})
	
	// ---
	
	oModel:AddGrid("GOX007_CF2", "GOX007_CF1", oStructCF2,,, /*bPreVal*/, /*bPosVal*/, /*bLoad?*/ )
	oModel:SetRelation("GOX007_CF2",{{_cCmp6+"_FILIAL", "xFilial('"+_cTab6+"')"},{_cCmp6+"_SEQ", _cCmp5+"_SEQ"}}, _cCmp6+"_FILIAL+"+_cCmp6 + "_SEQ")
	
	oModelCF2 := oModel:GetModel("GOX007_CF2")
	oModelCF2:SetUniqueLine({_cCmp6+"_CFOP"})
	
	// --
	
	//oModel:SetActivate({|oModel| GOX007(oModel)})
	
Return oModel

// -----------------

Static Function ViewDef()
	
	Local oModel     := FWLoadModel("GOX007")
	Local oView
	
	// Criação Local pois se caso um dia a inclusão for automática pelo LoadModel, não terá as variáveis Private criadas
	Local _cTab5     := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
	Local _cTab6     := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
	Local _cCmp5     := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
	Local _cCmp6     := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
	      
	Local oStructCF1 := FWFormStruct(2, _cTab5)
	Local oStructCF2 := FWFormStruct(2, _cTab6)
	
	oStructCF2:RemoveField(_cCmp6+"_SEQ")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField("GOX007_CF1", oStructCF1)
	
	oView:AddGrid("GOX007_CF2", oStructCF2)
	
	// Montagem da Tela
	
	oView:CreateHorizontalBox("TIPONF", 25)
			
		oView:SetOwnerView("GOX007_CF1", "TIPONF")
		
	oView:CreateHorizontalBox("CFOP", 75)
		
		oView:CreateFolder("CFOP_F1", "CFOP")
		oView:AddSheet("CFOP_F1", "CFOP_F1S1", "CFOPs para o tipo de Nota Fiscal")
		
			oView:CreateHorizontalBox("CFOP_G", 100,,, "CFOP_F1", "CFOP_F1S1")
				
				oView:SetOwnerView("GOX007_CF2", "CFOP_G")
		
Return oView

// -----------------

Static Function GOX7POS()
	
	
	
Return .T.

// -----------------

Static Function GOX7VLD()
	
	
	
Return .T.
 
// -----------------

User Function GOX7VC()
	
	Local _cTab5 := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
	Local _cTab6 := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
	Local _cCmp5 := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
	Local _cCmp6 := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
	
	Local aAreaCF1 := (_cTab5)->( GetArea() )
	Local aAreaCF2 := (_cTab6)->( GetArea() )
	Local aValor   := {"N", "D", "B", "I", "P", "C"} 
	Local cValor   := "" 
	
	dbSelectArea("SX5")
	SX5->( dbSetOrder(1) )
	If SX5->( dbSeek(xFilial("SX5") + "13" + PadR(M->&(_cCmp6 + "_CFOP"), TamSX3("X5_CHAVE")[1])) )
		
		dbSelectArea(_cTab6)
		(_cTab6)->( dbSetOrder(1) )
		(_cTab6)->( dbSeek(xFilial(_cTab6) + FwFldGet(_cCmp6 + "_CFOP")) )
		
		While !(_cTab6)->( Eof() ) .And. (_cTab6)->&(_cCmp6 + "_FILIAL") == xFilial(_cTab6) .And. (_cTab6)->&(_cCmp6 + "_CFOP") == FwFldGet(_cCmp6 + "_CFOP")
			
			If (_cTab6)->&(_cCmp6 + "_SEQ") # FwFldGet(_cCmp6 + "_SEQ")
				
				cValor := Posicione(_cTab5, 1, xFilial(_cTab5) + (_cTab6)->&(_cCmp6 + "_SEQ"), _cCmp5 + "_TIPO")
				
				Help(, , 'CFOP Inválida', , "Esta CFOP já está informada no cadastro de Tipo de Nota de sequência " + (_cTab6)->&(_cCmp6 + "_SEQ") + " para o tipo '" + CBoxInfo(_cCmp5 + "_TIPO", cValToChar(AScan(aValor, {|x| x == cValor}))) + "'.", 1, 0)
				Return .F.
				
			EndIf
			
			(_cTab6)->( dbSkip() )
			
		EndDo
		
	Else
		
		Help(, , 'CFOP Inválida', , "Informe uma CFOP válida.", 1, 0)
		Return .F.
		
	EndIf
	
	RestArea(aAreaCF2)
	RestArea(aAreaCF1)
	
Return .T.

////////////////////////////////////////

Static Function CBoxInfo(cNmFld, cValue, nInfoType)

	Local cAux

	Default nInfoType := 2
	
	If Val(cValue) == 0
		Return "[Indefinido]"
	EndIf
	
	cAux := StrTokArr(Posicione("SX3", 2, cNmFld, "X3_CBOX"), ';')[Val(cValue)]

Return If(!Empty(cAux), StrTokArr(cAux, "=")[nInfoType], "")
