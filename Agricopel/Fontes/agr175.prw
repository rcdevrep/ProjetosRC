#Include "Totvs.ch"

User Function AGR175()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Cliente      ³ Agricopel                                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Programa     ³ AGR175           ³ Responsavel ³ Deco                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o    ³ Alterar Numeracao de cheque devido sistema bloquear     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Data        ³ 25.05.05         ³ Implantacao ³                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Programador ³ DECO                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Objetivos   ³ Alterar Numeracao cheque                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Arquivos    ³ SEF,SE5                                                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Observacoes ³                                                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Cuidados na ³                                                         ³±±
	±±³ Atualizacao ³                                                         ³±±
	±±³ de versao   ³                                                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cSavScr1   := ""
	Private tamanho    := "M"
	Private limite     := 132
	Private cDesc1     := "Este programa ira Renumerar Cheque"
	Private cDesc2     := "AGRICOPEL"
	Private cDesc3     := ""
	Private cString    := "SEF"
	Private aReturn    := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
	Private nomeprog   := "AGR175"
	Private nLastKey   := 0
	Private cPerg      := "AGR175"
	Private wnrel      := "AGR175"
	Private aSvAlias   := {Alias(),IndexOrd(),Recno()}
	Private aRegistros := {}
	Private m_pag      := 1
	Private LI         := 80
	Private titulo     := "Renumera Cheque"

	AADD(aRegistros,{"AGR175","01","Cheque nr  ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
	U_CriaPer("AGR175",aRegistros)

	dbSelectArea(aSvAlias[1])
	dbSetOrder(aSvAlias[2])
	dbGoto(aSvAlias[3])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas, busca o padrao da PRE-NOTA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

	If LastKey() == 27 .or. nLastKey == 27
		RestScreen(3,0,24,79,cSavScr1)
		Return
	Endif

	SetDefault(aReturn,cString)

	If LastKey() == 27 .OR. nLastKey == 27
		RestScreen(3,0,24,79,cSavScr1)
		Return
	Endif

	RptStatus({|| RptDetail()})
Return

Static Function RptDetail()

	Local cQuery  := ""
	Local cNumChq := '0' + mv_par01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Selecao de Chaves para os arquivos                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SEF->(DbSetOrder(1))               // filial+cod+loja
	SE5->(DbSetOrder(1))               // filial+cod

	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "
	cQuery += "FROM "+RetSqlName("SEF")+" (NOLOCK) "
	cQuery += "WHERE EF_FILIAL = '"+xFilial("SEF")+"' "
	cQuery += "AND D_E_L_E_T_ = '' "
	cQuery += "AND EF_NUM = '"+mv_par01+"' "

	If Select("SEF01") <> 0
		dbSelectArea("SEF01")
		dbCloseArea()
	Endif

	MpSysOpenQuery(cQuery, "SEF01")

	DbSelectArea("SEF01")
	While !Eof()
		DbSelectArea("SEF")
		DbGoto(SEF01->nIdRecno)
		RecLock("SEF",.F.)
		SEF->EF_NUM := cNumChq
		MsUnLock("SEF")
		DbSelectArea("SEF01")
		DbSkip()
	EndDo

	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "
	cQuery += "FROM "+RetSqlName("SE5")+" (NOLOCK) "
	cQuery += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery += "AND D_E_L_E_T_ = '' "
	cQuery += "AND E5_NUMCHEQ = '"+mv_par01+"' "

	If Select("SE501") <> 0
		dbSelectArea("SE501")
		dbCloseArea()
	Endif

	MpSysOpenQuery(cQuery, "SE501")

	DbSelectArea("SE501")
	While !Eof()
		DbSelectArea("SE5")
		DbGoto(SE501->nIdRecno)
		RecLock("SE5",.F.)
		SE5->E5_NUMCHEQ := cNumChq
		MsUnLock("SE5")
		DbSelectArea("SE501")
		DbSkip()
	EndDo

	set device to screen
	cEmp := sm0->m0_codigo

	dbcloseall()
	OpenFile(cEmp)

	set device to print
	Set Device To Screen

	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	If Select("SEF01") <> 0
		dbSelectArea("SEF01")
		dbCloseArea()
	Endif

	If Select("SE501") <> 0
		dbSelectArea("SE501")
		dbCloseArea()
	Endif

Return()