#INCLUDE "PROTHEUS.CH"

// Programa de WorkFlows diversos.

User Function GOX017(aParams)
	
	Default aParams := {"01", "0101"}
	
	RpcSetType(3)
	If RpcSetEnv(aParams[1], aParams[2])
		
		Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
		Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
		
		ProcWF()
		
		RpcClearEnv()
		
	EndIf
	
Return

Static Function ProcWF()
	
	Local cQuery
	Local cAli    := GetNextAlias()
	Local nPeriod := GetNewPar("MV_ZIXMDPW", 7)
	Local aPrint  := {}
	Local cTitulo := ""
	Local aNota
	
	cTitulo := "Notas para Classificar"
	
	cQuery := " SELECT "
	cQuery += " R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName(_cTab1) + " XML "
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND " + _cCmp1 + "_TIPO = '1' "
	cQuery += " AND " + _cCmp1 + "_SIT IN ('1', '2', '3') "
	cQuery += " AND " + _cCmp1 + "_DTEMIS >= '" + DToS(Date() - nPeriod) + "' "
	cQuery += " AND " + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAli, .F., .T.)
	
	While !(cAli)->( Eof() )
		
		(_cTab1)->( dbGoTo((cAli)->RECNO) )
		
		aNota := ExisteNota(cFilAnt, (_cTab1)->&(_cCmp1 + "_CHAVE"), "2")
		
		If aNota[1] .And. aNota[3]
			
			AAdd(aPrint, {(_cTab1)->&(_cCmp1 + "_FILIAL"), ;
						  (_cTab1)->&(_cCmp1 + "_CHAVE"), ;
						  (_cTab1)->&(_cCmp1 + "_DOC"), ;
						  (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"), ;
						  U_GODSEMIT(), ;
						  AllTrim(Transform((_cTab1)->&(_cCmp1 + "_TOTVAL"), "@E 999,999,999.99")), ;
						  aNota[2] ;
						  })
		
		EndIf
		
		(cAli)->( dbSkip() )
		
	EndDo
	
	If Select(cAli) > 0
		
		(cAli)->( dbCloseArea() )
		
	EndIf
	
	If !Empty(aPrint)
		
		SendWF(aPrint, cTitulo, DToC(Date() - nPeriod))
		
	EndIf
	
Return

Static Function SendWF(aPrint, cTitulo, cData)
	
	Local nI
	
	oProcess := TWFProcess():New("000001", OemToAnsi(cTitulo))
	
	oProcess:NewTask("000001", "\workflow\modelos\importador\XML_GENERICO.htm")
	
	oProcess:cSubject 	:= cTitulo
	oProcess:bReturn  	:= ""
	oProcess:bTimeOut	:= {}
	oProcess:fDesc 		:= cTitulo
	oProcess:ClientName(cUserName)
	oHTML := oProcess:oHTML
	
	oHTML:ValByName('cTitulo', cTitulo + " na filial " + FWFilialName() + " desde: " + cData)
	
	//oHTML:ValByName('cAviso', "")
	
	For nI := 1 To Len(aPrint)
		
		AAdd(oHTML:ValByName('xm.cFilial'), aPrint[nI][1])
		AAdd(oHTML:ValByName('xm.cChave') , aPrint[nI][2])
		AAdd(oHTML:ValByName('xm.cNumero'), aPrint[nI][3])
		AAdd(oHTML:ValByName('xm.cForn')  , aPrint[nI][4])
		AAdd(oHTML:ValByName('xm.cNome')  , aPrint[nI][5])
		AAdd(oHTML:ValByName('xm.cValor') , aPrint[nI][6])
		AAdd(oHTML:ValByName('xm.cObs')   , aPrint[nI][7])
		
	Next nI
				
	oProcess:cTo := AllTrim(GetNewPar("MV_ZGOXGEN", "octavio@gooneconsultoria.com.br"))
	
	oProcess:Start()
	
	oProcess:Finish()
	
Return

Static Function ExisteNota(cFil, cChave, cTipo) 
	
	Local aRet := {.F., "", .F., .F.}
	
	Default cTipo := "1"
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(8) )
	
	If SF1->( dbSeek(cFil + cChave) )
		
		aRet[4] := .T. // Nota Existe
		aRet[1] := .T. // Nota Importada
		
		If Empty(SF1->F1_STATUS)
			
			aRet[2] := "XML para classificar"
			aRet[3] := .T.
			
		Else
			
			aRet[2] := "XML escriturado"
			
		EndIf
		
	Else
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		If (_cTab1)->( dbSeek(cChave + cTipo) )
			
			aRet[4] := .T. // Nota Existe
			
			If (_cTab1)->&(_cCmp1 + "_SIT") == "2"
				
				aRet[1] := .T. //Nota Importada
				
				If (_cTab1)->&(_cCmp1 + "_LIBALM") == "1"
					aRet[2] := "XML para classificar"
					aRet[3] := .T.
				Else
					aRet[2] := "XML escriturado"
				EndIf
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
				
				aRet[2] := "XML pendente para importar"
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "4"
				
				aRet[2] := "XML bloqueado"
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "5"
				
				aRet[2] := "XML cancelado"
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "6"
				
				aRet[2] := "XML pendente e com inconsistencia"
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "7"
				
				aRet[2] := "XML com estrutura errada"
				
			EndIf
			
		Else
			
			aRet[2] := "XML nao encontrado"
			
		EndIf
		
	EndIf
	
Return aRet
