#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/*#######################################################################*\
||#                  RELATÓRIO DE NOTAS COM E SEM XML                   #||
||#                                                                     #||
||# Data: 25/03/2015                                                    #||
\*#######################################################################*/

User Function GOX006()
	
	Local aStruXml := {}
	Local cArqTabXml
	Local oReport
	
	Private _cTab1    := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))
	Private _cCmp1    := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	Private cAliasXml := GetNextAlias()
	Private cSit
	Private cFormul
	Private cOrigem
	
	Private lUrbano   := GetNewPar("MV_XSNURB", .T.)
	
	// Tabela temporária
	aStruXml := {{'XML'    , 'N',  1, 0}, ;
	             {'CHVNFE' , 'C', 44, 0}, ;
	             {'DOC'    , 'C',  9, 0}, ;
	             {'SERIE'  , 'C',  3, 0}, ;
	             {'FORMUL' , 'C',  1, 0}, ;
	             {'FORNECE', 'C',  6, 0}, ;
	             {'LOJA'   , 'C',  2, 0}, ;
	             {'EMISSAO', 'D',  8, 0}, ;
	             {'ESPECIE', 'C',  5, 0}, ;
	             {'ORIGEM' , 'C',  1, 0}}
	
	cArqTabXml := CriaTrab(aStruXml, .T.)
	dbUseArea(.T., __LocalDriver, cArqTabXml, cAliasXml, .F., .F.)
	
	// Índice por XML
	IndRegua(cAliasXml, Left(cArqTabXml, 7) + "A", "XML", , , "")
	dbClearIndex()
	dbSetIndex(Left(cArqTabXml, 7) + "A" + OrdBagExt())
	
	R001Per()
	
	If Pergunte("GOX006")
	
		oReport := ReportDef()
		oReport:PrintDialog()
		
	EndIf
	
	If Select(cAliasXml) > 0
	
		(cAliasXml)->( dbCloseArea() )
		
	EndIf
	
Return

////////////////////////////////////////

Static Function ReportDef()

	Local oSection
	
	oReport:= TReport():New("GOX006", "Relatório de Notas com(sem) XML", "", {|oReport| ReportPrint(oReport)}, "Este relatório irá apresentar as Notas que estão com e sem XML.")
	oReport:SetPortrait() 
	
	oSection := TRSection():New(oReport, "Notas", {cAliasXml}, {})
	
	oSection:SetHeaderPage()
	oSection:SetTotalInLine(.F.)
	oSection:SetReadOnly()
	
	TRCell():New(oSection, 'CHVNFE' , cAliasXml, 'Chave'  , , 44)
	TRCell():New(oSection, 'DOC'    , cAliasXml, 'Nota'   , ,  9)
	TRCell():New(oSection, 'SERIE'  , cAliasXml, 'Série')
	TRCell():New(oSection, 'FORNECE', cAliasXml, 'Fornecedor')
	TRCell():New(oSection, 'LOJA'   , cAliasXml, 'Loja')
	TRCell():New(oSection, 'EMISSAO', cAliasXml, 'Emissão', , 10)
	TRCell():New(oSection, 'FORMUL' , cAliasXml, 'Form. próp?', "@!", 10, .T., {|| cFormul })
	TRCell():New(oSection, 'ESPECIE', cAliasXml, 'Espécie')
	TRCell():New(oSection, 'SIT'    , cAliasXml, 'Situação', "@!", 20, .T., {|| cSit })
	TRCell():New(oSection, 'ORIGEM' , cAliasXml, 'Origem', "@!", 20, .T., {|| cOrigem })
	
Return oReport

////////////////////////////////////////

Static Function ReportPrint(oReport)

	Local cAliasSF1 := GetNextAlias()
	Local cQuery    := ""
	Local lSalva    := .T.
	Local nXML      := 0
	Local oSection  := oReport:Section(1)
	Local nTotal    := 0
	Local nA
	
	If !ExistDir(AllTrim(MV_PAR04))
	
		Aviso("Erro", "O diretório '" + AllTrim(MV_PAR04) + "' não existe. Os XMLs não serão salvos.", {"Ok"}, 1)
		lSalva := .F.
		
	EndIf
	
	cQuery := " SELECT SF1.F1_CHVNFE, "
	cQuery += "        SF1.F1_DOC, "
	cQuery += "        SF1.F1_SERIE, "
	cQuery += "        SF1.F1_FORNECE, "
	cQuery += "        SF1.F1_LOJA, "
	cQuery += "        SF1.F1_EMISSAO, "
	cQuery += "        SF1.F1_FORMUL, "
	cQuery += "        SF1.F1_ESPECIE "
	cQuery += " FROM " + RetSqlName("SF1") + " SF1 "
	cQuery += " WHERE SF1.F1_FILIAL  = '" + xFilial("SF1") + "' "
	cQuery += " AND   SF1.D_E_L_E_T_ = '' "
	cQuery += " AND   SF1.F1_CHVNFE <> '' "  // Chave não pode estar vazia
	
	// Data de Emissão
	If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
	
		cQuery += " AND ("
		
		// Data Inicial
		If !Empty(MV_PAR01)
		
			cQuery += "SF1.F1_EMISSAO >= " + DToS(MV_PAR01)
			
			If !Empty(MV_PAR02)
			
				cQuery += " AND "
				
			EndIf
			
		EndIf
		
		// Data Final
		If !Empty(MV_PAR02)
		
			cQuery += "SF1.F1_EMISSAO <= " + DToS(MV_PAR02)
			
		EndIf
		
		cQuery += ") "
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAliasSF1, .F., .T.)
	TcSetField(cAliasSF1, "F1_EMISSAO", "D", 8, 0)
	
	// Alimenta a tabela temporária e valida se tem XML ou não.
	dbSelectArea(cAliasXml)
	
	(cAliasSF1)->( DbEval({|| nTotal++}) )
	
	oReport:SetMeter(nTotal + IIf(MV_PAR03 # 1, nTotal, nTotal/2))
	
	(cAliasSF1)->( dbGoTop() )
	
	If lUrbano
		SelTbCondor()
	EndIf
	
	While !(cAliasSF1)->( Eof() )
		
		oReport:IncMeter()
		
		// Verifica se tem XML
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
	
		// Cria registro novo
		RecLock(cAliasXml, .T.)
		
			(cAliasXml)->CHVNFE  := (cAliasSF1)->F1_CHVNFE
			(cAliasXml)->DOC     := (cAliasSF1)->F1_DOC
			(cAliasXml)->SERIE   := (cAliasSF1)->F1_SERIE
			(cAliasXml)->FORNECE := (cAliasSF1)->F1_FORNECE
			(cAliasXml)->LOJA    := (cAliasSF1)->F1_LOJA
			(cAliasXml)->FORMUL  := (cAliasSF1)->F1_FORMUL
			(cAliasXml)->EMISSAO := (cAliasSF1)->F1_EMISSAO
			(cAliasXml)->ESPECIE := (cAliasSF1)->F1_ESPECIE
			
			If (_cTab1)->( dbSeek((cAliasSF1)->F1_CHVNFE) )
				
				(cAliasXml)->ORIGEM := "I"
				(cAliasXml)->XML    := 1
				
			ElseIf lUrbano .And. CONDORXML->( dbSeek((cAliasSF1)->F1_CHVNFE) )
				
				(cAliasXml)->ORIGEM := "C"
				(cAliasXml)->XML    := 1
				
			Else
				
				(cAliasXml)->ORIGEM := " "
				(cAliasXml)->XML    := 2
				
			EndIf
			
		(cAliasXml)->( MsUnlock() )
		
		(_cTab1)->( dbCloseArea() )
		(cAliasSF1)->( dbSkip() )
		
	EndDo
	
	(cAliasSF1)->( dbCloseArea() )
	(cAliasXml)->( dbGoTop() )
	(cAliasXml)->( dbSetOrder(1) )
	
	// PASSA DUAS VEZES, 1 = NOTAS COM XML E 2 = NOTAS SEM
	For nA := 1 To 2
	
		// APENAS OS SEM XML
		If nA == 1 .And. MV_PAR03 == 1
		
			// PULA PARA QUE O nA SEJA 2 E IMPRIMA SÓ OS SEM XML
			Loop
			
		EndIf
	
		// Primeira volta = Notas COM XML
		If nA == 1
		
			nXML := 1
			
			(cAliasXml)->( dbGoTop() )
			If (cAliasXml)->( dbSeek(1) )
			
				//oReport:PrintText("")
				//oReport:PrintText("COM XML")
				oSection:Init()
				
			EndIf
			
		// Segunda volta = Notas SEM XML
		Else
		
			nXML := 2
			
			(cAliasXml)->( dbGoTop() )
			If (cAliasXml)->( dbSeek(2) )
			
				//oReport:PrintText("")
				//oReport:PrintText("SEM XML")
				oSection:Init()
				
			EndIf
			
		EndIF
		
		// Imprime os registros
		If (cAliasXml)->( Found() )
		
			While !(cAliasXml)->( Eof() ) .And. (cAliasXml)->XML == nXML
				
				oReport:IncMeter()
				
				cSit := IIf((cAliasXml)->XML == 1, "COM XML", "SEM XML")
				cFormul := IIf((cAliasXml)->FORMUL == "S", "Sim", "Não")
				
				If (cAliasXml)->ORIGEM == "I"
					
					cOrigem := "Importador"
					
				ElseIf (cAliasXml)->ORIGEM == "C"
					
					cOrigem := "Central XML"
					
				EndIf 
				
				//oReport:IncMeter()
				oSection:PrintLine()
				
				If lSalva
				
					SaveXml((cAliasXml)->CHVNFE, (cAliasXml)->ORIGEM)
					
				EndIf
				
				(cAliasXml)->( dbSkip() )
				
			EndDo
			
			oSection:Finish()
			
		EndIf
		
	Next nA
	
	(cAliasXml)->( dbCloseArea() )
	
Return

////////////////////////////////////////

Static Function SaveXml(cChave, cOrigem)

	Local cFile   := AllTrim(MV_PAR04) + IIf(SubStr(AllTrim(MV_PAR04), Len(AllTrim(MV_PAR04)), 1) # "\", "\", "")
	//Local cTime   := StrTran(AllTrim(TIME()), ":", "")
	Local mXml    := ""
	Local nA      := 0
	Local nHandle := 0
	
	If Empty(cChave) .Or. Empty(cFile) .Or. Empty(cOrigem)
	
		Return
		
	EndIf
	
	If cOrigem == "I"
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		
		If !(_cTab1)->( dbSeek(cChave) )
		
			Return
			
		EndIf
		
	ElseIf lUrbano
		
		SelTbCondor()
		
		If !CONDORXML->( dbSeek(cChave) )
			
			Return
			
		EndIf
		
	EndIf
	
	cFile := cFile + "Periodo(" + DToS(MV_PAR01) + "-" + DToS(MV_PAR02) + ")_" + DToS(dDataBase) + "\" // + "_" + cTime + "\"
	
	If !ExistDir(cFile)
	
		MakeDir(cFile)
		
	EndIf
	
	cFile := cFile + cChave + ".xml"//(_cTab1)->&(_cCmp1 + "_ARQUIV")
	
	If File(cFile)
		
		Return
		
	EndIf
	
	If cOrigem == "I"
		
		mXml  := (_cTab1)->&(_cCmp1 + "_XML")
		
	ElseIF lUrbano
		
		mXml  := CONDORXML->XML_ARQ
		
	EndIf
	
	// ARQUIVO NÃO EXISTE
	If !File(cFile)
	
		// CRIA O ARQUIVO DE LOG
		nHandle := FCreate(cFile, FC_NORMAL)
		// POSICIONA NO INICIO DO ARQUIVO DE LOG
		FSeek(nHandle, 0)
		
	// ARQUIVO EXISTE
	Else
	
		nHandle := FOpen(cFile, FO_READWRITE + FO_EXCLUSIVE)
		// POSICIONA NO FIM DO ARQUIVO DE LOG
		FSeek(nHandle, 0, FS_END)
		
	EndIf
	
	// GRAVA O CONTEUDO DA VARIAVEL NO ARQUIVO DE LOG
	FWrite(nHandle, mXml, Len(mXml))
	// FECHA O ARQUIVO DE LOG
	FClose(nHandle)
	mXml := ""
	(_cTab1)->( dbCloseArea() )
	
Return NIL

////////////////////////////////////////

Static Function R001Per()

	Local aDados := {}
	
	aAdd(aDados, {'GOX006', '01', 'Data Inicial:', 'Data Inicial', 'Data Inicial', 'MV_CH1', 'D', 8, 0, 0, 'G', '', 'MV_PAR01', '', '', '', '20140701', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''})
	aAdd(aDados, {'GOX006', '02', 'Data Final:', 'Data Final:', 'Data Final:', 'MV_CH2', 'D', 8, 0, 0, 'G', '', 'MV_PAR02', '', '', '', '20140831', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''})
	aAdd(aDados, {'GOX006', '03', 'Apresenta:', 'Apresenta:', 'Apresenta:', 'MV_CH3', 'N', 1, 0, 0, 'C', '', 'MV_PAR03', 'Sem XML', 'Sem XML', 'Sem XML', '', '', 'Todos', 'Todos', 'Todos', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''})
	aAdd(aDados, {'GOX006', '04', 'Salva XML em:', 'Salva XML em:', 'Salva XML em:', 'MV_CH4', 'C', 60, 0, 0, 'G', '', 'MV_PAR04', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Informe um diretório para salvar os XMLs da faixa acima.', '', ''})
	
	AtuSX1(aDados)
	
Return

////////////////////////////////////////

Static Function AtuSX1(aDados)

	Local aArea    := GetArea()
	Local aAreaDic := SX1->( GetArea() )
	Local aEstrut  := {}
	Local aStruDic := SX1->( dbStruct() )
	Local nI       := 0
	Local nJ       := 0
	Local nTam1    := Len(SX1->X1_GRUPO)
	Local nTam2    := Len(SX1->X1_ORDEM)
	
	aEstrut := {"X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , ;
	            "X1_VARIAVL", "X1_TIPO"   , "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , ;
	            "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , "X1_DEFSPA1", ;
	            "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", ;
	            "X1_DEFENG2", "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", ;
	            "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , "X1_DEF04"  , "X1_DEFSPA4", ;
	            "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
	            "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , ;
	            "X1_HELP"   , "X1_PICTURE", "X1_IDFIL"}
	
	//
	// Atualizando dicionário
	//
	dbSelectArea("SX1")
	SX1->( dbSetOrder(1) )
	
	For nI := 1 To Len(aDados)
	
		If !SX1->( dbSeek(PadR(aDados[nI][1], nTam1) + PadR(aDados[nI][2], nTam2)) )
		
			RecLock("SX1", .T.)
			
				For nJ := 1 To Len(aDados[nI])
				
					If aScan(aStruDic, {|aX| PadR(aX[1], 10) == PadR(aEstrut[nJ], 10)}) > 0
					
						SX1->( FieldPut(FieldPos(aEstrut[nJ]), aDados[nI][nJ]) )
						
					EndIf
					
				Next nJ
				
			MsUnLock()
			
		EndIf
		
	Next nI
	
	RestArea(aAreaDic)
	RestArea(aArea)
	
Return NIL

Static Function SelTbCondor()
	
	Local cIndex := CriaTrab(Nil, .F.)
	
	dbUseArea( .T., "TOPCONN", "CONDORXML", "CONDORXML", .T., .T.)
	
	IndRegua("CONDORXML", cIndex, "XML_CHAVE", , , "Selecionando Registros...")
	
Return
