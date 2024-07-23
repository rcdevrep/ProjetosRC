#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/*#######################################################################*\
||#                  RELATÓRIO DE NOTAS PENDENTES                       #||
||#                                                                     #||
||# Data: 28/10/2015                                                    #||
\*#######################################################################*/

User Function GOX009()
	
	Local oReport
	
	Private cAliXML := GetNextAlias()
	Private nDiaDif
	//Private nDiaCri 
	
	Private _cTab1  := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))
	Private _cCmp1  := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	
	Private lUrbano   := GetNewPar("MV_XSNURB", .T.)
	
	AtuSX1()
	
	If Pergunte("GOX009")
	
		oReport := ReportDef()
		oReport:PrintDialog()
		
	EndIf
	
	If Select(cAliXML) > 0
		
		(cAliXML)->( dbCloseArea() )
		
	EndIf
	
Return

////////////////////////////////////////

Static Function ReportDef()
	
	Local oSection
	
	oReport:= TReport():New("GOX009", "Relatório de Notas Pendentes de Importação", "", {|oReport| ReportPrint(oReport)}, "Este relatório irá apresentar as Notas que estão pendentes de importação no Importador.")
	oReport:SetPortrait() 
	
	oSection := TRSection():New(oReport, "Notas", {cAliXML}, {})
	
	oSection:SetHeaderPage()
	oSection:SetTotalInLine(.F.)
	oSection:SetReadOnly()
	
	TRCell():New(oSection, _cCmp1 + '_FILIAL', cAliXML)
	TRCell():New(oSection, _cCmp1 + '_DOC'   , cAliXML)
	TRCell():New(oSection, _cCmp1 + '_SERIE' , cAliXML)
	TRCell():New(oSection, _cCmp1 + '_CODEMI', cAliXML)
	TRCell():New(oSection, _cCmp1 + '_LOJEMI', cAliXML)
	TRCell():New(oSection, _cCmp1 + '_EMIT'  , cAliXML)//,,,, .T., {|| U_SNDSEMIT()})
	
	If MV_PAR05 == 1
		
		TRCell():New(oSection, _cCmp1 + '_DTEMIS' , cAliXML)
		
	Else
		
		TRCell():New(oSection, _cCmp1 + '_DTCRIA' , cAliXML)
		
	EndIf
	
	//TRCell():New(oSection, _cCmp1 + '_DIAEMI', cAliXML,'Dias Emissão', "", 10, .T., {|| nDiaEmi})
	TRCell():New(oSection, _cCmp1 + '_DIACRI', cAliXML,'Dias', "", 10, .T., {|| nDiaDif})
	TRCell():New(oSection, _cCmp1 + '_NATOP' , cAliXML)
	TRCell():New(oSection, _cCmp1 + '_TIPO'  , cAliXML)
	TRCell():New(oSection, _cCmp1 + '_CHAVE' , cAliXML)
	
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	
	If SX3->( dbSeek(_cCmp1 + '_TIPO') )
		oSection:Cell(_cCmp1 + '_TIPO'):SetCBox(AllTrim(SX3->( X3CBox() )))
	EndIf
	
Return oReport

////////////////////////////////////////

Static Function ReportPrint(oReport)
	
	Local oSection  := oReport:Section(1)
	Local nDiasDe
	Local nDiasAte 
	Local cDtRefDe
	Local cDtRefAte
	Local nTotal    := 0
	Local aFils 
	Local aFilial
	Local nI
	Local cCNPJ := ""
	
	Local aAreaTb1  := (_cTab1)->( GetArea() )
	
	If lUrbano
		
		aFils := FWAllFilial(, , SM0->M0_CODIGO)
		
		For nI := 1 To Len(aFils)
			
			If aFils[nI] >= MV_PAR01 .And. aFils[nI] <= MV_PAR02
				
				aFilial := FWArrFilAtu(SM0->M0_CODIGO, aFils[nI])
				
				If Empty(cCNPJ)
					
					cCNPJ += "'" + aFilial[18] + "'"
					
				Else
					
					cCNPJ += ", '" + aFilial + "'"
					
				EndIf
				
			EndIf
			
		Next nI
		
	EndIf
	
	cQuery := " SELECT TAB1." + _cCmp1 + "_FILIAL, "
	cQuery += "        TAB1." + _cCmp1 + "_DOC, "
	cQuery += "        TAB1." + _cCmp1 + "_SERIE, "
	cQuery += "        TAB1." + _cCmp1 + "_CODEMI, "
	cQuery += "        TAB1." + _cCmp1 + "_LOJEMI, "
	cQuery += "        TAB1." + _cCmp1 + "_DTEMIS, "
	cQuery += "        TAB1." + _cCmp1 + "_DTCRIA, "
	cQuery += "        TAB1." + _cCmp1 + "_CHAVE, "
	cQuery += "        TAB1." + _cCmp1 + "_NATOP, "
	cQuery += "        TAB1." + _cCmp1 + "_TIPO "
	//cQuery += "        ,TAB1.R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName(_cTab1) + " TAB1 "
	cQuery += " WHERE TAB1.D_E_L_E_T_ = ' ' AND (TAB1." + _cCmp1 + "_SIT = '1' OR TAB1." + _cCmp1 + "_SIT = '3') "
	cQuery += " AND (TAB1." + _cCmp1 + "_TIPO = '1' OR TAB1." + _cCmp1 + "_TIPO = '2') "
	
	If !Empty(MV_PAR01)
		
		cQuery += " AND TAB1." + _cCmp1 + "_FILIAL >= '" + MV_PAR01 + "' "
		
	EndIf
	
	If !Empty(MV_PAR02)
		
		cQuery += " AND TAB1." + _cCmp1 + "_FILIAL <= '" + MV_PAR02 + "' "
		
	EndIf
	
	/*nDiasDe  := MV_PAR03
	cDtRefDe := DToS(Date() - nDiasDe) 
	
	nDiasAte  := MV_PAR04
	cDtRefAte := DToS(Date() - nDiasAte)*/
	
	//If MV_PAR05 == 1
		
		If !Empty(MV_PAR03)
			
			cQuery += " AND TAB1." + _cCmp1 + "_DTEMIS >= '" + DToS(MV_PAR03) + "' "
			
		EndIf
		
		If !Empty(MV_PAR04)
			
			cQuery += " AND TAB1." + _cCmp1 + "_DTEMIS <= '" + DToS(MV_PAR04) + "' "
			
		EndIf
		
	/*Else
		
		cQuery += " AND TAB1." + _cCmp1 + "_DTCRIA < '" + cDtRefDe + "' "
		cQuery += " AND TAB1." + _cCmp1 + "_DTCRIA >= '" + cDtRefAte + "' "
		
	EndIf*/
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAliXML, .F., .T.)
	
	TcSetField(cAliXML, _cCmp1 + "_DTEMIS", "D", 8, 0)
	TcSetField(cAliXML, _cCmp1 + "_DTCRIA", "D", 8, 0)
	
	(cAliXML)->( DbEval({|| nTotal++}) )
	
	oReport:SetMeter(nTotal)
	
	(cAliXML)->( dbGoTop() )
	
	oSection:Init()
	
	While !(cAliXML)->( Eof() )
		
		oReport:IncMeter()
		
		//(_cTab1)->( dbGoTo((cAliXML)->RECNO) )
		
		nDiaDif := Date() - (cAliXML)->&(_cCmp1 + "_DTEMIS")
		
		oSection:PrintLine()
		
		(cAliXML)->( dbSkip() )
		
	EndDo
	
	// 
	
	If lUrbano
		
		cQuery := " SELECT  
		cQuery += " '01' " + _cCmp1 + "_FILIAL, "
		cQuery += " XML_CHAVE, XML_EMISSA "
		cQuery += " 	FROM CONDORXML TAB1 "
		cQuery += " LEFT JOIN SF1010 SF1 ON SF1.F1_CHVNFE = TAB1.XML_CHAVE "
		
		If !Empty(MV_PAR03)
			
			cQuery += " AND TAB1." + _cCmp1 + "_DTEMIS >= '" + DToS(MV_PAR03) + "' "
			
		EndIf
		
		If !Empty(MV_PAR04)
			
			cQuery += " AND TAB1." + _cCmp1 + "_DTEMIS <= '" + DToS(MV_PAR04) + "' "
			
		EndIf
		
		// AND TAB1.XML_DEST = '84432111000167'
		
		cQuery += " 	AND SF1.F1_FILIAL IS NULL "
		
	EndIf
	
	oSection:Finish()
	
	RestArea(aAreaTb1)
	
Return

Static Function AtuSX1()
	
	Local aArea    := GetArea()
	Local aAreaDic := SX1->( GetArea() )
	Local aEstrut  := {}
	Local aStruDic := SX1->( dbStruct() )
	Local aDados   := {}
	Local nI       := 0
	Local nJ       := 0
	Local nTam1    := Len( SX1->X1_GRUPO )
	Local nTam2    := Len( SX1->X1_ORDEM )
	
	aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
	             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
	             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
	             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
	             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
	             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
	             "X1_IDFIL"  }
	
	aAdd( aDados, {'GOX009','01','Filial de?','Filial de?','Filial de?','MV_CH0','C',2,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {'GOX009','02','Filial ate?','Filial ate?','Filial ate?','MV_CH0','C',2,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {'GOX009','03','Data de?','Data de?','Data de?','MV_CH0','D',8,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {'GOX009','04','Data até?','Data até?','Data até?','MV_CH0','D',8,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {'GOX009','05','Pelo data de:','Pelo data de:','Pelo data de:','MV_CH0','C',1,0,1,'C','','MV_PAR05','Emissao','','','','','Criacao no Imp.','','','','','','','','','','','','','','','','','','','','','','','',''} )
	
	
	//
	// Atualizando dicionário
	//
	dbSelectArea( "SX1" )
	SX1->( dbSetOrder( 1 ) )
	
	For nI := 1 To Len( aDados )
		If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
			RecLock( "SX1", .T. )
			For nJ := 1 To Len( aDados[nI] )
				If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
					SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
				EndIf
			Next nJ
			MsUnLock()
		EndIf
	Next nI
	
	RestArea( aAreaDic )
	RestArea( aArea )

Return
