#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
Programa.:  XAG0024
Autor....: Emerson - Sla
Data.....: 31/03/2018
Descricao: Tabela de comissão Margem. ZDE
Uso......: Agricopel
*/
User Function XAG0024()

	Local oBrowse := Nil
	PRIVATE aRotina    := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZDE')
	oBrowse:SetDescription('Cadastro de Comissão Por Margem - Agricopel')
	oBrowse:Activate()

Return Nil

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.XAG0024' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.XAG0024' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.XAG0024' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.XAG0024' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.XAG0024' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.XAG0024' OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Ajuste'     ACTION 'U_XAG024AJ' OPERATION 4 ACCESS 0
Return(aRotina)

Static Function ModelDef()

	Local oModel   := Nil
	Local oStruZDE := FWFormStruct(1,'ZDE',/*bAvalCampo*/,/*lViewUsado*/)

	oModel := MPFormModel():New('XAG024MO',/*bPreValidacao*/,{ |oModel| ValModelo( oModel ) }/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	oStruZDE:RemoveField( 'ZDE_FILIAL' )

	oModel:AddFields('ZDEMASTER',/*cOwner*/,oStruZDE,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	oModel:SetDescription('Comissão Margem')
	oModel:SetPrimaryKey({})
Return(oModel)

Static Function ViewDef()

	Local oView    := Nil
	Local oModel   := FWLoadModel('XAG0024')
	Local oStruZDE := FWFormStruct(2,'ZDE')

	oStruZDE:SetProperty( 'ZDE_COD'  , MVC_VIEW_ORDEM, '01' )
	oStruZDE:SetProperty( 'ZDE_NOME' , MVC_VIEW_ORDEM, '02' )
	oStruZDE:SetProperty( 'ZDE_VLRMRG' , MVC_VIEW_ORDEM, '03' )
	oStruZDE:SetProperty( 'ZDE_VLRCOM' , MVC_VIEW_ORDEM, '04' )

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_ZDE', oStruZDE,'ZDEMASTER')

	oStruZDE:RemoveField( 'ZDE_FILIAL')
	oView:CreateHorizontalBox('TELA',100)
	oView:SetOwnerView('VIEW_ZDE','TELA')
Return(oView)

Static Function ValModelo(oModel)
	Local nOperation := oModel:GetOperation()
	Local oModelAtv  := FWModelActive()
	Local nPerc      := oModelAtv:GetValue('ZDEMASTER','ZDE_VLRMRG')
	Local cVend      := oModelAtv:GetValue('ZDEMASTER','ZDE_COD')
	Local aAreaZDE   := ZDE->(GetArea())

	if  nOperation == MODEL_OPERATION_INSERT

		DbSelectArea("ZDE")
		ZDE->(DbSetOrder(01))
		If ZDE->(DbSeek(xFilial("ZDE")+cVEND,.T.))
			While !EOF() .and. ZDE->ZDE_FILIAL+ZDE->ZDE_COD == xFilial("ZDE")+cVEND

				IF ZDE->ZDE_VLRMRG == nPerc
					Help("Utilize alteração ",1,'Percentual',,'Percentual de margem já cadastrado: '+ALLTRIM(str(nPerc)),3,0)
					RestArea(aAreaZDE)
					Return(.F.)
				ENDIF
				ZDE->(DbSkip())
			Enddo
		Endif
	Endif
	RestArea(aAreaZDE)
RETURN(.T.)

User Function XAG024MO()

	Local oObj
	Local cIdPonto
	Local cIdModel

	Local aParam := PARAMIXB

	If aParam <> NIL
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
	Endif
Return(.T.)

USER Function XAG024AJ()

	Local aAreaZDE   := ZDE->(GetArea())
	Private cPerg  := "XAG0024"
	AjustaSX1(cPerg)
	Pergunte(cPerg,.T.)

	cVend:=MV_PAR01
	IF empty(cVend)
		msgalert("VENDEDOR OBRIGATORIO","ATENCAO")
		Return
	Endif
	IF MV_PAR02 <> 0
		IF MV_PAR03 <> 0
			msgalert("AJUSTE DE PERCENTUAL OU VALOR","ATENCAO")
			Return
		Endif
	Endif
	IF MV_PAR03 <> 0
		IF MV_PAR02 <> 0
			msgalert("AJUSTE DE PERCENTUAL OU VALOR","ATENCAO")
			Return
		Endif
	Endif

	If  ApMsgNoYes( 'Confirma o Ajuste do Vendedor ? '+cVend, 'Ajuste Comissão Margem' )
		If ZDE->(DbSeek(xFilial("ZDE")+cVEND,.T.))
			While !EOF() .and. ZDE->ZDE_FILIAL+ZDE->ZDE_COD == xFilial("ZDE")+cVEND
				IF MV_PAR02 <> 0
					nValor := ZDE->ZDE_VLRCOM * (MV_PAR02 / 100)
					nValor := IF(nValor > 0,nValor,0)
					Dbselectarea("ZDE")
					Reclock("ZDE",.F.)
					ZDE->ZDE_VLRCOM:=ZDE->ZDE_VLRCOM + nValor
					msunlock()
				Endif
				IF MV_PAR03 <> 0
					nValor := ZDE->ZDE_VLRCOM + MV_PAR03
					nValor := IF(nValor > 0,nValor,0)
					Dbselectarea("ZDE")
					Reclock("ZDE",.F.)
					ZDE->ZDE_VLRCOM:=nValor
					msunlock()
				Endif
				ZDE->(DbSkip())
			Enddo
		Endif
	Endif
	RestArea(aAreaZDE)

Static Function AjustaSX1(cPerg)

	Local nTam      := 0
	Local aHelp     := {}
	Local cAliasSX1 := "SX1"

	// #METADATASQL
	(cAliasSX1)->( dbSetOrder(1) )
	nTam := Len((cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_GRUPO")))))

	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"01" ) )
		(cAliasSX1)->( RecLock("SX1",.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "01"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Vendedor "))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH1"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "C"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 6))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par01"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_F3")), "SA3"))
		(cAliasSX1)->( msUnlock() )
	Endif

	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"02" ) )
		(cAliasSX1)->( RecLock("SX1",.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "02"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Percentual"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH2"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "N"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 5))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 2))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par02"))
		(cAliasSX1)->( msUnlock() )
	Endif

	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"03" ) )
		(cAliasSX1)->( RecLock("SX1",.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "03"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Valor  "))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH3"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "N"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 10))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 5))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par03"))

		(cAliasSX1)->( msUnlock() )
	Endif

	Aadd(aHelp,"Informe o Vendedor")
	Aadd(aHelp,"Informe o Percentual para corrigir")
	Aadd(aHelp,"Informe o Valor a Ser corrigido")

	PutSX1Help("P." + cPerg + "01.",aHelp[1],aHelp[1],aHelp[1])
	PutSX1Help("P." + cPerg + "02.",aHelp[2],aHelp[2],aHelp[2])
	PutSX1Help("P." + cPerg + "03.",aHelp[3],aHelp[3],aHelp[3])

Return