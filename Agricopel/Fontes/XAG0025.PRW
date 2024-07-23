#INCLUDE "RWMAKE.CH"

/*
Programa.:  XAG0025
Autor....: Emerson - Sla
Data.....: 28/03/2018
Descricao: Controle de Comissão Sobre a Margem
Uso......: Agricopel
*/

User Function XAG0025()

	Local aCamposBrw := {}
	Local aTam := {}
	Private cPerg  := "XAG0025"
	Dbselectarea("SX3")
	aSavSX3:={Alias(),IndexOrd(),Recno()}
	SX3->(DbSetOrder(02))
	SX3->(DbSeek("ZDE_NOME"))
	IF SX3->(Eof())
		Msgalert("Rotina Não Implementada para Esta Empresa","Atencão")
		RestArea(aSAVSX3)
		Return
	Endif
	RestArea(aSAVSX3)
	AjustaSX1(cperg)

	cCadastro := "Controle de Comissao Vendedores Agricopel"
	aRotina   := {{"Pesquisar","AxPesqui",0,1},;
	{"Imprime     ",'EXECBLOCK("XAG0025I",.F.,.F.)',0,3},;
	{"Calcula     ",'EXECBLOCK("XAG0025R",.F.,.F.)',0,3},;
	{"Manutenção  ",'EXECBLOCK("XAG0025M",.F.,.F.)',0,4},;
	{"Cad Vendedor  ",'EXECBLOCK("XAG025C1",.F.,.F.)',0,4},;
	{"Cad Margem  ",'EXECBLOCK("XAG025C2",.F.,.F.)'	,0,4},;
	{"Exclui      ",'EXECBLOCK("XAG025C3",.F.,.F.)',0,5},;
	{"Recal.Custos",'EXECBLOCK("XAG025C4",.F.,.F.)'	,0,4}}

	aTam:=TamSX3("A3_FILIAL")
	AADD(aCamposBrw,{"Filial", "A3_FILIAL", "C",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("A3_COD")
	AADD(aCamposBrw,{"Codigo", "A3_COD", "C",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("A3_NOME")
	AADD(aCamposBrw,{"Nome", "A3_NOME", "C",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("A3_NREDUZ")
	AADD(aCamposBrw,{"Nome Reduzido", "A3_NREDUZ", "N",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("A3_SALBASE")
	AADD(aCamposBrw,{"Salario Base ", "A3_SALBASE", "N",aTam[1],aTam[2], "" } )
	aTam:=TamSX3("A3_COMISLT")
	AADD(aCamposBrw,{"Comis Litros ", "A3_COMISLT", "N",aTam[1],aTam[2], "" } )
	mBrowse(6,1,22,75,"SA3",aCamposBrw,,,,,)
Return

Static Function AjustaSX1(cPerg)

	Local nTam      := 0
	Local aHelp     := {}
	Local cAliasSX1 := "SX1"

	// #METADATASQL
	(cAliasSX1)->( dbSetOrder(1) )
	nTam := Len((cAliasSX1)->(FieldGet((cAliasSX1)->(FieldPos("X1_GRUPO")))))

	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"01" ) )
		(cAliasSX1)->( RecLock((cAliasSX1),.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "01"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Da Filial"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH1"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "C"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 2))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par01"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_F3")), "SM0EMP"))
		(cAliasSX1)->( msUnlock() )
	Endif

	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"02" ) )
		(cAliasSX1)->( RecLock((cAliasSX1),.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "02"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Ate Filial"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH2"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "C"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 2))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par02"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_F3")), "SM0EMP"))
		(cAliasSX1)->( msUnlock() )
	Endif
	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"03" ) )
		(cAliasSX1)->( RecLock((cAliasSX1),.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "03"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Da Data"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH3"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "D"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 8))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par03"))
		(cAliasSX1)->( msUnlock() )
	Endif
	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"04" ) )
		(cAliasSX1)->( RecLock((cAliasSX1),.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "04"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Ate Data"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH4"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "D"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 8))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par04"))
		(cAliasSX1)->( msUnlock() )
	Endif
	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"05" ) )
		(cAliasSX1)->( RecLock((cAliasSX1),.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "05"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "De Vendedor"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH5"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "C"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 6))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par05"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_F3")), "SA3"))
		(cAliasSX1)->( msUnlock() )
	Endif

	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"06" ) )
		(cAliasSX1)->( RecLock((cAliasSX1),.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "06"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "ATE Vendedor"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_CH6"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "C"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 6))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "G"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par06"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_F3")), "SA3"))
		(cAliasSX1)->( msUnlock() )
	Endif

	If (cAliasSX1)->( !dbSeek( Padr(cPerg,nTam)+"07" ) )
		(cAliasSX1)->( RecLock((cAliasSX1),.T.) )
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GRUPO")), cPerg))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_ORDEM")), "07"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PERGUNT")), "Relatorio Tipo"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VARIAVL")), "mv_ch7"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TIPO")), "N"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_TAMANHO")), 1))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DECIMAL")), 0))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_PRESEL")), 1))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_GSC")), "C"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_VAR01")), "mv_par07"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DEF01")), "Analitico"))
		(cAliasSX1)->(FieldPut((cAliasSX1)->(FieldPos("X1_DEF02")), "Sintetico"))
		(cAliasSX1)->( msUnlock() )
	Endif

	Aadd(aHelp,{"Informe a filial ."               }) // 01
	Aadd(aHelp,{"Informe o Vendedor"                 }) // 03
	Aadd(aHelp,{"Informe a data   ."                 }) // 03
	Aadd(aHelp,{"Relatorio de Comissão (A/S)"                 }) // 03
	PutSX1Help("P." + cPerg + "01.",aHelp[01],aHelp[01],aHelp[01])
	PutSX1Help("P." + cPerg + "02.",aHelp[01],aHelp[01],aHelp[01])
	PutSX1Help("P." + cPerg + "03.",aHelp[02],aHelp[01],aHelp[01])
	PutSX1Help("P." + cPerg + "04.",aHelp[02],aHelp[01],aHelp[01])
	PutSX1Help("P." + cPerg + "05.",aHelp[03],aHelp[01],aHelp[01])
	PutSX1Help("P." + cPerg + "06.",aHelp[03],aHelp[01],aHelp[01])
	PutSX1Help("P." + cPerg + "07.",aHelp[04],aHelp[04],aHelp[04])
Return

User Function XAG0025I()
	Dbselectarea("SA3")
	aSavZDE:={Alias(),IndexOrd(),Recno()}
	U_XAG0026()
	RestArea(aSAVZDE)
Return

User Function XAG0025M()
	Dbselectarea("SA3")
	aSavZDE:={Alias(),IndexOrd(),Recno()}
	MATA490()
	RestArea(aSAVZDE)
Return

User Function XAG025C4()
	Dbselectarea("SA3")
	aSavZDE:={Alias(),IndexOrd(),Recno()}
	If  ApMsgNoYes( 'Confirma o Recalculo dos Custos das NOTAS ?', 'Calculo Custo NOTAS' )
		U_XAG027C()
	Endif
	RestArea(aSAVZDE)
Return

User Function XAG025C2()
	Dbselectarea("SA3")
	aSavZDE:={Alias(),IndexOrd(),Recno()}
	U_XAG0024()
	RestArea(aSAVZDE)
Return

User Function XAG025C1()
	Dbselectarea("SA3")
	aSavZDE:={Alias(),IndexOrd(),Recno()}
	MATA040()
	RestArea(aSAVZDE)
Return

User Function XAG025C3()

	Local lOk       := .F.
	Private oProcess  := NIL
	Private cPerg  := "XAG0025"
	Pergunte(cPerg,.T.)
	Dbselectarea("SA3")
	aSavSA3:={Alias(),IndexOrd(),Recno()}

	IF DAY(Date()) < 11 //SE O DIA CONECTADO FOR MENOR QUE 11
		IF MONTH(Date()) - MONTH(MV_PAR03) > 1
			msgalert('Periodo NÃO Permitido, entre em contato com a TI','Atençao')
			Return
		Endif
	Else
		IF MONTH(Date()) - MONTH(MV_PAR03) > 0
			msgalert('Periodo NÃO Permitido, entre em contato com a TI','Atençao')
			Return
		Endif
	Endif

	If  ApMsgNoYes( 'Confirma a Exclusão do Calculo da Comissao ?', 'Calculo Comissão Agricopel' )
		oProcess := MsNewProcess():New( { | lEnd | lOk := EXECProc( @lEnd) }, 'EXCLUINDO', 'Aguarde, atualizando ...', .F. )
		oProcess:Activate()
	Endif
	RestArea(aSAVSA3)
Return

Static Function EXECProc(lEnd)

	Local cQuery
	Local cAliasTmp  := GetNextAlias()
	Local Nreg:=0
	Pergunte(cPerg,.F.)

	cQuery := "SELECT E3.R_E_C_N_O_ RECNOSE3"
	cQuery += " FROM "+RetSqlName("SE3")+" E3 "
	cQuery += "  WHERE E3.D_E_L_E_T_ = ' '  AND (E3_TIPCOM = 'M' OR E3_TIPCOM ='L') "
	cQuery += "  AND E3.E3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += "  AND E3.E3_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	cQuery += "  AND E3.E3_VEND    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06+ "' "
	//cQuery += "  AND E3_DATA = '" + Dtos(Ctod("")) + "'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	nREG:=(cAliasTmp)->(RecCount())
	oProcess:SetRegua1(2)
	oProcess:SetRegua2(nREG)

	oProcess:IncRegua1('Aguarde..')

	(cAliasTmp)->(DbGoTop())

	while (cAliasTmp)->(!Eof())

		oProcess:IncRegua2('Excluindo Dados ')

		Dbselectarea("SE3")
		Dbgoto((cAliasTmp)->RECNOSE3)

		Dbselectarea("SE3")
		Reclock("SE3",.F.)
		SE3->E3_USERLGA:=Embaralha(SubStr(cUsuario,7,15),0)
		dbdelete()
		Msunlock()
		(cAliasTmp)->(DbSkip())
	enddo
	oProcess:IncRegua1('Aguarde..')
	(cAliasTmp)->( dbCloseArea() )
	If Select(cAliasTmp) == 0
		Ferase(cAliasTmp+GetDBExtension())
	Endif
Return

User Function XAG0025R()

	Local lOk       := .F.
	Private oProcess  := NIL
	Private cPerg  := "XAG0025"
	Pergunte(cPerg,.T.)
	Dbselectarea("SA3")
	aSavSA3:={Alias(),IndexOrd(),Recno()}

	IF DAY(Date()) < 11 //SE O DIA CONECTADO FOR MENOR QUE 11
		IF MONTH(Date()) - MONTH(MV_PAR03) > 1
			msgalert('Periodo NÃO Permitido, entre em contato com a TI','Atençao')
			Return
		Endif
	Else
		IF MONTH(Date()) - MONTH(MV_PAR03) > 0
			msgalert('Periodo NÃO Permitido, entre em contato com a TI','Atençao')
			Return
		Endif
	Endif

	If  ApMsgNoYes( 'Confirma o Calculo da Comissao ?', 'Calculo Comissão Agricopel' )
		oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd) }, 'CALCULANDO', 'Aguarde, atualizando ...', .F. )
		oProcess:Activate()
	Endif
	RestArea(aSAVSA3)
Return

Static Function FSTProc(lEnd)

	Local cFilBack  := cFilAnt //bpk filial posicionada no sistema
	Local cQuery    := ""
	Local cAliasTmp := GetNextAlias()
	Local cVendedor := ""
	Local cVend     := ""
	Local nQtdVend  := Fa440CntVen()
	local nPerMrg   := 0
	Local Nreg      := 0
	Local nCntFor   := 0

	Pergunte(cPerg,.F.)

	cQuery := "SELECT E3.R_E_C_N_O_ RECNOSE3"
	cQuery += " FROM "+RetSqlName("SE3")+" E3 "
	cQuery += "  WHERE E3.D_E_L_E_T_ = ' ' "//AND (E3_TIPCOM = 'M' OR E3_TIPCOM ='L') "
	cQuery += "  AND E3.E3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += "  AND E3.E3_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	cQuery += "  AND E3.E3_VEND    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06+ "' "
	//cQuery += "  AND E3_DATA = '" + Dtos(Ctod("")) + "'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	nREG:=(cAliasTmp)->(RecCount())
	oProcess:SetRegua1(nREG)

	(cAliasTmp)->(DbGoTop())

	while (cAliasTmp)->(!Eof())

		Dbselectarea("SE3")
		Dbgoto((cAliasTmp)->RECNOSE3)

		oProcess:IncRegua1('Apagando Calculo Anterior...')

		Dbselectarea("SE3")
		Reclock("SE3",.F.)
		SE3->E3_USERLGA:=Embaralha(SubStr(cUsuario,7,15),0)
		dbdelete()
		Msunlock()
		(cAliasTmp)->(DbSkip())

	enddo
	(cAliasTmp)->( dbCloseArea() )
	If Select(cAliasTmp) == 0
		Ferase(cAliasTmp+GetDBExtension())
	Endif

	cQuery := "SELECT D2.R_E_C_N_O_ RECNOSD2,F2.R_E_C_N_O_  RECNOSF2"
	cQuery += " FROM "+RetSqlName("SD2")+" D2, "+RetSqlName("SF2")+" F2, "+RetSqlName("SF4")+" F4 "
	cQuery += "  WHERE D2.D_E_L_E_T_ = ' ' AND F2.D_E_L_E_T_ =  ' '   AND F4.D_E_L_E_T_ =  ' '"
	cQuery += "  AND D2.D2_FILIAL = F2.F2_FILIAL"
	cQuery += "  AND D2.D2_DOC    = F2.F2_DOC   AND D2.D2_UM = 'L ' AND D2_QUANT > 0 "
	cQuery += "  AND D2.D2_TES      = F4.F4_CODIGO  AND F4_DUPLIC = 'S' "
	cQuery += "  AND D2.D2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += "  AND D2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	nREG:=(cAliasTmp)->(RecCount())
	if nREG > 0
		oProcess:SetRegua1(nREG/nQtdVend)
	Endif
	(cAliasTmp)->(DbGoTop())

	while (cAliasTmp)->(!Eof())

		Dbselectarea("SD2")
		Dbgoto((cAliasTmp)->RECNOSD2)
		Dbselectarea("SF2")
		Dbgoto((cAliasTmp)->RECNOSF2)

		oProcess:IncRegua1('Calculando Comissoes ...'+DTOC(SF2->F2_EMISSAO))

		IF SD2->D2_XCSTAGR	> 0

			cVend := "1"

			oProcess:SetRegua2(nQtdVend)

			For nCntFor := 1 To nQtdVend

				cVendedor := SF2->(FieldGet(SF2->(FieldPos("F2_VEND"+cVend))))

				oProcess:IncRegua2('Nota ->'+SF2->F2_DOC+' - '+cVendedor)

				IF !EMPTY(cVendedor)

					IF cVendedor >= MV_PAR05 .and. cVendedor <= MV_PAR06

						nPerMrg:=0
						nPerMrg:=(SD2->D2_TOTAL / SD2->D2_QUANT) -  (SD2->D2_XCSTAGR / SD2->D2_QUANT)
						nPercom:=0

						Dbselectarea("SA3")
						SA3->(DbSetOrder(01))
						SA3->(DbSeek(SF2->F2_FILIAL+cVendedor))

						Dbselectarea("ZDE")
						ZDE->(DbSetOrder(01))
						ZDE->(DbSeek(SF2->F2_FILIAL+cVendedor,.T.))

						While !EOF() .AND. ZDE->ZDE_FILIAL+ZDE->ZDE_COD == SF2->F2_FILIAL+cVendedor

							IF ZDE->ZDE_VLRMRG <=  nPerMrg
								nPercom:=ZDE->ZDE_VLRCOM
							Endif
							ZDE->(DbSkip())
						Enddo
						IF nPercom > 0
							Dbselectarea("SE3")
							Reclock("SE3",.T.)
							SE3->E3_PREFIXO:='MRG'
							SE3->E3_FILIAL:=SD2->D2_FILIAL
							SE3->E3_VEND  :=cVendedor
							SE3->E3_NUM   :=SD2->D2_DOC
							SE3->E3_SERIE :=SD2->D2_SERIE
							SE3->E3_PARCELA :=SD2->D2_ITEM
							SE3->E3_CODCLI  := SF2->F2_CLIENTE    		// C¢d. Cliente
							SE3->E3_LOJA    := SF2->F2_LOJA       		// Loja
							SE3->E3_EMISSAO := SF2->F2_EMISSAO    		// Data da emissao
							SE3->E3_BAIEMI  := "E"                		// Flag (Pago na Emissao)
							SE3->E3_TIPCOM  := "M"                		// ESCALONADA)
							SE3->E3_ORIGEM  := ' ' //BRANCO PARA NAO RECALCULAR
							SE3->E3_PEDIDO  := SD2->D2_PEDIDO
							SE3->E3_CCUSTO  := SD2->D2_CCUSTO
							SE3->E3_NFORI   := SD2->D2_DOC
							SE3->E3_SDOC    := SD2->D2_SERIE
							SE3->E3_BASE    := SD2->D2_QUANT
							SE3->E3_COMIS   := SD2->D2_QUANT * nPercom
							SE3->E3_SEQ     := '01'
							SE3->E3_XVALNFS :=SD2->D2_TOTAL / SD2->D2_QUANT
							SE3->E3_XCSTNFS :=SD2->D2_XCSTAGR / SD2->D2_QUANT
							SE3->E3_XVLRCOM :=nPercom
							SE3->E3_XCODPRO :=SD2->D2_COD
							SE3->E3_COMISS   :=(SD2->D2_TOTAL / SD2->D2_QUANT) - (SD2->D2_XCSTAGR / SD2->D2_QUANT)
							SE3->E3_XORIGEM:='XAG0025'
							SE3->E3_USERLGI:=Embaralha(SubStr(cUsuario,7,15),0)
							Msunlock()
						Endif
						if SA3->A3_COMISLT > 0
							Dbselectarea("SE3")
							Reclock("SE3",.T.)
							SE3->E3_PREFIXO :='LTS'
							SE3->E3_FILIAL  :=SD2->D2_FILIAL
							SE3->E3_VEND    :=cVendedor
							SE3->E3_NUM      :=SD2->D2_DOC
							SE3->E3_SERIE    :=SD2->D2_SERIE
							SE3->E3_CODCLI   := SF2->F2_CLIENTE    		// C¢d. Cliente
							SE3->E3_LOJA     := SF2->F2_LOJA       		// Loja
							SE3->E3_EMISSAO  := SF2->F2_EMISSAO    		// Data da emissao
							SE3->E3_PARCELA  :=SD2->D2_ITEM
							SE3->E3_BAIEMI   := "E"                		// Flag (Pago na Emissao)
							SE3->E3_TIPCOM   := "L"                		// ESCALONADA)
							SE3->E3_ORIGEM   := ' ' //BRANCO PARA NAO RECALCULAR
							SE3->E3_PEDIDO   := SD2->D2_PEDIDO
							SE3->E3_CCUSTO   := SD2->D2_CCUSTO
							SE3->E3_NFORI    := SD2->D2_DOC
							SE3->E3_SDOC     := SD2->D2_SERIE
							SE3->E3_BASE     := SD2->D2_QUANT
							SE3->E3_COMIS    := SD2->D2_QUANT * SA3->A3_COMISLT
							SE3->E3_XVALNFS  :=SD2->D2_TOTAL / SD2->D2_QUANT
							SE3->E3_XCSTNFS  :=SD2->D2_XCSTAGR / SD2->D2_QUANT
							SE3->E3_XVLRCOM  :=SA3->A3_COMISLT
							SE3->E3_XCODPRO  :=SD2->D2_COD
							SE3->E3_SEQ      := '02'
							SE3->E3_COMISS   :=(SD2->D2_TOTAL / SD2->D2_QUANT) - (SD2->D2_XCSTAGR / SD2->D2_QUANT)
							SE3->E3_XORIGEM:='XAG0025'
							SE3->E3_USERLGI:=Embaralha(SubStr(cUsuario,7,15),0)
							Msunlock()
						Endif
					Endif
				Endif

				cVend := Soma1(cVend,1)
			Next nCntFor
		Endif
		(cAliasTmp)->(DbSkip())
	enddo
	(cAliasTmp)->( dbCloseArea() )
	If Select(cAliasTmp) == 0
		Ferase(cAliasTmp+GetDBExtension())
	Endif
	cQuery := "SELECT D1.R_E_C_N_O_ RECNOSD1,F1.R_E_C_N_O_  RECNOSF1"
	cQuery += " FROM "+RetSqlName("SD1")+" D1, "+RetSqlName("SF1")+" F1, "+RetSqlName("SF4")+" F4 "
	cQuery += "  WHERE D1.D_E_L_E_T_ = ' ' AND F1.D_E_L_E_T_ =  ' '   AND F4.D_E_L_E_T_ =  ' '"
	cQuery += "  AND D1.D1_FILIAL = F1.F1_FILIAL AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA"
	cQuery += "  AND D1.D1_DOC    = F1.F1_DOC   AND D1.D1_UM = 'L ' AND D1.D1_QUANT > 0 AND D1.D1_TIPO = 'D' "
	cQuery += "  AND D1.D1_TES      = F4.F4_CODIGO  AND F4_DUPLIC = 'S' "
	cQuery += "  AND D1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += "  AND D1.D1_DTDIGIT  BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	nREG:=(cAliasTmp)->(RecCount())
	if nREG > 0
		oProcess:SetRegua1(nREG/nQtdVend)
	Endif
	(cAliasTmp)->(DbGoTop())

	while (cAliasTmp)->(!Eof())

		Dbselectarea("SD1")
		Dbgoto((cAliasTmp)->RECNOSD1)
		Dbselectarea("SF1")
		Dbgoto((cAliasTmp)->RECNOSF1)

		oProcess:IncRegua1('Calculando Comissoes DEV.'+DTOC(SD1->D1_DTDIGIT))

		Dbselectarea("SD2")
		Dbsetorder(3)
		Dbseek(SD1->D1_FILIAL+SD1->D1_NFORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEM)

		IF !EOF() .AND. SD2->D2_XCSTAGR	> 0

			cVend := "1"

			oProcess:SetRegua2(nQtdVend)

			For nCntFor := 1 To nQtdVend

				cVendedor := SF2->(FieldGet(SF2->(FieldPos("F2_VEND"+cVend))))

				oProcess:IncRegua2('Nota DEV ->'+SF2->F2_DOC+' - '+cVendedor)

				IF !EMPTY(cVendedor)

					IF cVendedor >= MV_PAR05 .and. cVendedor <= MV_PAR06

						nPerMrg:=0
						nPerMrg:=(SD2->D2_TOTAL / SD2->D2_QUANT) -  (SD2->D2_XCSTAGR / SD2->D2_QUANT)
						nPercom:=0

						Dbselectarea("SA3")
						SA3->(DbSetOrder(01))
						SA3->(DbSeek(SF2->F2_FILIAL+cVendedor))

						Dbselectarea("ZDE")
						ZDE->(DbSetOrder(01))
						ZDE->(DbSeek(SF2->F2_FILIAL+cVendedor,.T.))

						While !EOF() .AND. ZDE->ZDE_FILIAL+ZDE->ZDE_COD == SF2->F2_FILIAL+cVendedor

							IF ZDE->ZDE_VLRMRG <=  nPerMrg
								nPercom:=ZDE->ZDE_VLRCOM
							Endif
							ZDE->(DbSkip())
						Enddo
						IF nPercom > 0
							Dbselectarea("SE3")
							Reclock("SE3",.T.)
							SE3->E3_PREFIXO:='MRG'
							SE3->E3_FILIAL:=SD2->D2_FILIAL
							SE3->E3_VEND  :=cVendedor
							SE3->E3_NUM   :=SD2->D2_DOC
							SE3->E3_SERIE :=SD2->D2_SERIE
							SE3->E3_PARCELA :=SD2->D2_ITEM
							SE3->E3_CODCLI  := SF2->F2_CLIENTE    		// C¢d. Cliente
							SE3->E3_LOJA    := SF2->F2_LOJA       		// Loja
							SE3->E3_EMISSAO := SF2->F2_EMISSAO    		// Data da emissao
							SE3->E3_BAIEMI  := "E"                		// Flag (Pago na Emissao)
							SE3->E3_TIPCOM  := "M"                		// ESCALONADA)
							SE3->E3_ORIGEM  := ' ' //BRANCO PARA NAO RECALCULAR
							SE3->E3_PEDIDO  := SD2->D2_PEDIDO
							SE3->E3_CCUSTO  := SD2->D2_CCUSTO
							SE3->E3_NFORI   := SD2->D2_DOC
							SE3->E3_SDOC    := SD2->D2_SERIE
							SE3->E3_BASE    := SD2->D2_QUANT * -1
							SE3->E3_COMIS   := (SD2->D2_QUANT * nPercom) *-1
							SE3->E3_SEQ     := '03'
							SE3->E3_XVALNFS :=SD2->D2_TOTAL / SD2->D2_QUANT
							SE3->E3_XCSTNFS :=SD2->D2_XCSTAGR / SD2->D2_QUANT
							SE3->E3_XVLRCOM :=nPercom
							SE3->E3_XCODPRO :=SD2->D2_COD
							SE3->E3_COMISS   :=(SD2->D2_TOTAL / SD2->D2_QUANT) - (SD2->D2_XCSTAGR / SD2->D2_QUANT)
							SE3->E3_XORIGEM:='XAG0025'
							SE3->E3_USERLGI:=Embaralha(SubStr(cUsuario,7,15),0)
							Msunlock()
						Endif
						if SA3->A3_COMISLT > 0
							Dbselectarea("SE3")
							Reclock("SE3",.T.)
							SE3->E3_PREFIXO  :='LTS'
							SE3->E3_FILIAL   :=SD2->D2_FILIAL
							SE3->E3_VEND     :=cVendedor
							SE3->E3_NUM      :=SD2->D2_DOC
							SE3->E3_SERIE    :=SD2->D2_SERIE
							SE3->E3_CODCLI   := SF2->F2_CLIENTE    		// C¢d. Cliente
							SE3->E3_LOJA     := SF2->F2_LOJA       		// Loja
							SE3->E3_EMISSAO  := SF2->F2_EMISSAO    		// Data da emissao
							SE3->E3_PARCELA  :=SD2->D2_ITEM
							SE3->E3_BAIEMI   := "E"                		// Flag (Pago na Emissao)
							SE3->E3_TIPCOM   := "L"                		// ESCALONADA)
							SE3->E3_ORIGEM   := ' ' //BRANCO PARA NAO RECALCULAR
							SE3->E3_PEDIDO   := SD2->D2_PEDIDO
							SE3->E3_CCUSTO   := SD2->D2_CCUSTO
							SE3->E3_NFORI    := SD2->D2_DOC
							SE3->E3_SDOC     := SD2->D2_SERIE
							SE3->E3_BASE    := SD2->D2_QUANT * -1
							SE3->E3_COMIS   := (SD2->D2_QUANT * nPercom) *-1
							SE3->E3_XVALNFS  :=SD2->D2_TOTAL / SD2->D2_QUANT
							SE3->E3_XCSTNFS  :=SD2->D2_XCSTAGR / SD2->D2_QUANT
							SE3->E3_XVLRCOM  :=SA3->A3_COMISLT
							SE3->E3_XCODPRO  :=SD2->D2_COD
							SE3->E3_SEQ      := '04'
							SE3->E3_COMISS   :=(SD2->D2_TOTAL / SD2->D2_QUANT) - (SD2->D2_XCSTAGR / SD2->D2_QUANT)
							SE3->E3_XORIGEM:='XAG0025'
							SE3->E3_USERLGI:=Embaralha(SubStr(cUsuario,7,15),0)
							Msunlock()
						Endif
					Endif
				Endif

				cVend := Soma1(cVend,1)
			Next nCntFor
		Endif
		(cAliasTmp)->(DbSkip())
	enddo
	(cAliasTmp)->( dbCloseArea() )
	If Select(cAliasTmp) == 0
		Ferase(cAliasTmp+GetDBExtension())
	Endif
	cFilAnt := cFilBack //Retorna para a filial posicionada no SISTEMA
Return