#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR251    ºAutor  ³Microsiga           º Data ³  05/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para exclusao da Agenda do Operador.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR251()

	Local oTempTbl  := Nil

	Private cAliasTbl := ""

	MsgRun("Buscando agendas do operador","Processando",{|| oTempTbl  := GetTempTbl()})

	CriaBrowse()

	(cAliasTbl)->(DbCloseArea())
	oTempTbl:Delete()

Return()

Static Function SU6Dados()

	Local cQuery    := ""
	Local cAliasQry := ""
	Local cOperador := TkOperador()

	cQuery := " SELECT  "
	cQuery += "    SU6.U6_DATA, "
	cQuery += "    SU6.U6_HRINI, "
	cQuery += "    SUBSTRING(SU6.U6_CODENT,1,6) AS CLIENTE, "
	cQuery += "    SUBSTRING(SU6.U6_CODENT,7,2) AS LOJA, "
	cQuery += "    SU6.U6_NOMECLI, "
	cQuery += "    SU6.U6_DDD, "
	cQuery += "    SU6.U6_TELCLI, "
	cQuery += "    SU6.U6_NOMECON, "
	cQuery += "    SU6.U6_CIDADE, "
	cQuery += "    SU6.U6_ESTADO, "
	cQuery += "    SU6.R_E_C_N_O_ AS SU6RECNO "
	cQuery += " FROM " + RetSqlName("SU6") + " SU6 WITH (NOLOCK) "
	cQuery += " WHERE SU6.D_E_L_E_T_ = '' "
	cQuery += " AND   SU6.U6_ENTIDA = 'SA1' "
	cQuery += " AND   SU6.U6_OPERAD = '" + cOperador + "'"
	cQuery += " AND   SU6.U6_STATUS = '1' "
	cQuery += " AND   SU6.U6_FILIAL = '" + xFilial("SU6") + "'"

	cAliasQry := MpSysOpenQuery(cQuery)
	TcSetField(cAliasQry,"U6_DATA","D",08,0)

	While !(cAliasQry)->(Eof())
		RecLock(cAliasTbl, .T.)
		(cAliasTbl)->DAT        := (cAliasQry)->U6_DATA
		(cAliasTbl)->HRINI      := (cAliasQry)->U6_HRINI
		(cAliasTbl)->CLIENTE    := (cAliasQry)->CLIENTE
		(cAliasTbl)->LOJA       := (cAliasQry)->LOJA
		(cAliasTbl)->NOMECLI    := (cAliasQry)->U6_NOMECLI
		(cAliasTbl)->DDD        := (cAliasQry)->U6_DDD
		(cAliasTbl)->TELCLI     := (cAliasQry)->U6_TELCLI
		(cAliasTbl)->NOMECON    := (cAliasQry)->U6_NOMECON
		(cAliasTbl)->CIDADE     := (cAliasQry)->U6_CIDADE
		(cAliasTbl)->ESTADO     := (cAliasQry)->U6_ESTADO
		(cAliasTbl)->RECID      := (cAliasQry)->SU6RECNO
		MsUnlock(cAliasTbl)

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
	(cAliasTbl)->(DbGoTop())

Return()

Static Function Cancelar()

	Local cMarca := ""

	cMarca := oBrowseSU6:Mark()

	(cAliasTbl)->(DbGotop())
	While !(cAliasTbl)->(Eof())

		If (cAliasTbl)->OK == cMarca
			SU6->(DbGoto((cAliasTbl)->RECID))

			DbSelectArea("SU6")
			RecLock("SU6",.F.)
			SU6->U6_STATUS := "3"
			MsUnLock()

			DbSelectArea(cAliasTbl)
			RecLock(cAliasTbl,.F.)
			(cAliasTbl)->(DbDelete())
			MsUnLock()
		EndIf

		(cAliasTbl)->(DbSkip())
	End

	(cAliasTbl)->(DbGotop())
	MsgInfo("Exclusão efetuada!", "Concluído")

	oBrowseSU6:Refresh(.T.)

Return

Static Function GetTempTbl()

	Local aStru     := {}
	Local oTempTbl  := Nil

	aAdd(aStru,{"OK"		,"C",02,00})
	aAdd(aStru,{"DAT"		,"D",TamSx3("U6_DATA")[1],00})
	aAdd(aStru,{"HRINI"		,"C",TamSx3("U6_HRINI")[1],00})
	aAdd(aStru,{"CLIENTE"	,"C",TamSx3("A1_COD")[1],00})
	aAdd(aStru,{"LOJA"		,"C",TamSx3("A1_LOJA")[1],00})
	aAdd(aStru,{"NOMECLI"	,"C",TamSx3("U6_NOMECLI")[1],00})
	aAdd(aStru,{"DDD" 		,"C",TamSx3("U6_DDD")[1],00})
	aAdd(aStru,{"TELCLI" 	,"C",TamSx3("U6_TELCLI")[1],00})
	aAdd(aStru,{"NOMECON" 	,"C",TamSx3("U6_NOMECON")[1],00})
	aAdd(aStru,{"CIDADE" 	,"C",TamSx3("U6_CIDADE")[1],00})
	aAdd(aStru,{"ESTADO" 	,"C",TamSx3("U6_ESTADO")[1],00})
	aAdd(aStru,{"RECID" 	,"N",16,00})

	oTempTbl := FwTemporaryTable():New()
	oTempTbl:SetFields(aStru)
	oTempTbl:AddIndex("IDX1", {"DAT","HRINI","CLIENTE","LOJA"})

	oTempTbl:Create()
	cAliasTbl := oTempTbl:GetAlias()

	SU6Dados()

Return(oTempTbl)

Static Function CriaBrowse()

	Local lMarcar := .F.

	Private oBrowseSU6 := Nil

	oBrowseSU6 := FWMarkBrowse():New()
	oBrowseSU6:SetAlias(cAliasTbl)
	oBrowseSU6:SetDescription("Selecione as agendas para excluir")
	oBrowseSU6:SetFieldMark("OK")
	oBrowseSU6:DisableDetails()
	oBrowseSU6:SetTemporary(.T.)
	oBrowseSU6:SetWalkThru(.F.)
	oBrowseSU6:oBrowse:SetFixedBrowse(.T.)
	oBrowseSU6:oBrowse:SetDBFFilter(.F.)
	oBrowseSU6:oBrowse:SetUseFilter(.F.)
	oBrowseSU6:oBrowse:SetFilterDefault("")

	oBrowseSU6:bAllMark := { || CheckAll(oBrowseSU6:Mark() ,lMarcar), lMarcar := !lMarcar}
	oBrowseSU6:AddButton("Cancelar Agendas", { || MsgRun("Cancelando agendas selecionadas","Processando",{|| Cancelar()})},,,, .F., 2 )

	oBrowseSU6:SetColumns(MontaColunas("DAT",     "Data"          ,01,"@!",1,TamSx3("U6_DATA")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("HRINI",   "HrIni"         ,02,"@!",1,TamSx3("U6_HRINI")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("CLIENTE", "Cliente"       ,03,"@!",1,TamSx3("A1_COD")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("LOJA",    "Tipo"          ,04,"@!",1,TamSx3("A1_LOJA")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("NOMECLI", "Nome Cliente"  ,05,"@!",1,TamSx3("U6_NOMECLI")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("DDD",     "DDD"           ,06,"@!",1,TamSx3("U6_DDD")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("TELCLI",  "Tel. Cliente"  ,07,"@!",1,TamSx3("U6_TELCLI")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("NOMECON", "Nome Contato"  ,08,"@!",1,TamSx3("U6_NOMECON")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("CIDADE",  "Cidade"        ,09,"@!",1,TamSx3("U6_CIDADE")[1],0))
	oBrowseSU6:SetColumns(MontaColunas("ESTADO",  "Estado"        ,10,"@!",1,TamSx3("U6_ESTADO")[1],0))

	oBrowseSU6:Activate()

Return()

Static Function CheckAll(cMarca, lMarcar)

	Local aAreaTRB  := (cAliasTbl)->(GetArea())
	Local cSetMarca := ""

	cSetMarca := IIf(lMarcar, cMarca, "  ")

	dbSelectArea(cAliasTbl)
	(cAliasTbl)->(dbGoTop())

	While !(cAliasTbl)->(Eof())
		RecLock((cAliasTbl), .F.)
		(cAliasTbl)->OK := cSetMarca
		MsUnlock()

		(cAliasTbl)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)
	oBrowseSU6:Refresh(.T.)

Return(.T.)

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return({aColumn})