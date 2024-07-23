#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0095
Tela de Cadastro Produtos x Natureza x TES
@author Geyson Albano
@since 08/11/2022
@version 1.0
@Return Nil
/*/

User Function XAG0095()

	Local aArea   := GetArea()
	Local oBrowse := Nil

	Private cTitulo := "Cadastro Produto x Natureza x TES"

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZZX")
	oBrowse:SetDescription(cTitulo)

	oBrowse:Activate()

	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.XAG0095' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.XAG0095' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.XAG0095' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.XAG0095' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Replicar Cadastro'    ACTION 'U_XAG0095B()' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

	Local oModel := Nil
	Local oStZZX := FWFormStruct(1, "ZZX")

	oModel := MPFormModel():New("ZZX_FM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMZZX",/*cOwner*/,oStZZX)

	oModel:SetPrimaryKey({'ZZX_FILIAL','ZZX_PRODUT','ZZX_ESPECI'})

	oModel:SetDescription(cTitulo)
	oModel:GetModel("FORMZZX"):SetDescription("Formulário do Cadastro " + cTitulo)

Return (oModel)

Static Function ViewDef()

	Local oModel   := FWLoadModel("XAG0095")
	Local oStZZX   := FWFormStruct(2, "ZZX")
	Local oView    := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZZX", oStZZX, "FORMZZX")
	oView:CreateHorizontalBox("TELA", 100)
	oView:EnableTitleView('VIEW_ZZX', 'Dados - '+cTitulo )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_ZZX","TELA")

Return oView

/*/{Protheus.doc} XAG0095B
	(long_description)
	@type  Static Function
	@author user
	@since 19/11/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function XAG0095B()

    Local _aEmpre  := EscEmpresa()
    Local _aArea   := {}

    If (Len(_aEmpre) > 0 .And. MsgYesNo("Confirma a replicação do cadastro do produto para a(s) empresa(s) selecionadas?" + CRLF + ;
                                        "Produto: " + AllTrim(ZZX->ZZX_PRODUT) , "Replicação de produto"))
        _aArea := GetArea()

        ZZXRepl(_aEmpre)

        RestArea(_aArea)
    EndIf

Return()

Static Function EscEmpresa()

    Local _aEmpresas := {}
    Local _aRet      := {}
    Local nX         := 0
    Local nRetScan   := 0

    _aEmpresas := U_XAGEMP(.T.)

    For nX := 1 To Len(_aEmpresas)
        nRetScan := IIf(Len(_aRet) > 0, aScan(_aRet, {|x| x[1] == _aEmpresas[nX, 1]} ), 0)

        If (nRetScan > 0)
            aAdd(_aRet[nRetScan][2], _aEmpresas[nX, 2])
        Else
            aAdd(_aRet, {_aEmpresas[nX, 1], {_aEmpresas[nX, 2]}})
        EndIf
    End

Return(_aRet) 

Static Function ZZXRepl(_aEmpre)

    Local _aLog      := {}
    Local _cLog      := ""
    Local nI         := 0
    Local nQtdEmp    := Len(_aEmpre)

    For nI := 1 to nQtdEmp        
        MsgRun('Replicando produto - ' + cValToChar(nI) + "/" + cValToChar(nQtdEmp) + " - Empresa: " + _aEmpre[nI][1], "Aguarde - Processando",{|| _aLog := GravZZX(_aEmpre[nI])})
    Next

    FWAlertSuccess("Fim da replicação de produtos!", "TOTVS")

Return Nil

Static Function GravZZX(_aGrav)

Local lRet := .T.
Local nI         := 0
Local cProdut := ZZX->ZZX_PRODUT
Local cEspec  := ZZX->ZZX_ESPECI
Local cTes  := ZZX->ZZX_TES
Local cNatu  := ZZX->ZZX_NATURE

For nI := 1 to Len(_aGrav[2])

	DbSelectArea("ZZX")
	DbSetOrder(1)
	If !DbSeek(_aGrav[2][nI]+cProdut+cEspec)

		RecLock("ZZX", .T.)
			ZZX->ZZX_FILIAL := _aGrav[2][nI]    
			ZZX->ZZX_ESPECI := cEspec
			ZZX->ZZX_NATURE := cNatu
			ZZX->ZZX_PRODUT := cProdut
			ZZX->ZZX_TES	:= cTes			
		MsUnlock()
		
	EndIf	

Next

Return lRet
