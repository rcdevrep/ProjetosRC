#INCLUDE "PROTHEUS.CH"

// Relatório de notas em trânsito verificando todos os grupos de empresa (sigamat.emp)

User Function GOX015()
	
	Local aParam := {}
	
	Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
		
	If ParamBox({{1,"Filial de" , cFilAnt, "", "", "", "", 2, .T.}, ;
				 {1,"Filial até", cFilAnt, "", "", "", "", 2, .T.}, ;
				 {1,"Data Emissão de ", SToD(SubStr(DToS(dDataBase), 1, 6) + "01"),"","","","", 8, .T.}, ;
				 {1,"Data Emissão até", dDataBase,"","","","", 8, .T.} ;
				}, "Filtros Relatório Nota em Trânsito", @aParam)
		
		Verifica(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
		
	EndIf
	
Return

Static Function Verifica(cFilDe, cFilAte, dData1, dData2)
	
	Private oProc
		
	oProc := MsNewProcess():New({|| RefNotas(cFilDe, cFilAte, dData1, dData2)}, "Aguarde...", "Verificando Notas...")
	oProc:Activate()
	
Return

Static Function RefNotas(cFilDe, cFilAte, dData1, dData2)
	
	Local cArquivo
    Local oFWMSEx  := FWMsExcelEx():New()
    Local oExcel
	
	Local cAliTemp := GetNextAlias()
	Local cQuery   := ""
	
	Local nCount   := 0
	Local lGerou   := .F.
	
	Private aSM0   := FWLoadSM0()
	
	cArquivo := GetTempPath() + '\Notas_em_transito_' + AllTrim(FWFilialName()) + '_' + StrTran(Time(), ":", "") + '.xml'	
	
	oFWMSEx:AddworkSheet("Notas em Trânsitos")
        
        oFWMSEx:AddTable("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa")
            
            //Adicionando as colunas
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Empresa Origem", 1, 1)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Filial Origem", 1, 1)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Empresa Destino", 1, 1)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Filial Destino", 1, 1)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Número", 1, 2)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Série", 1, 1)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Emissão", 1, 1)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Valor Total", 1, 1)
            oFWMSEx:AddColumn("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", "Chave", 1, 1)
	
	oProc:SetRegua1(3)
			
	oProc:IncRegua1("Buscando Notas em Trânsito")
	
	cInCNPJ := GetAllCNPJ(SM0->M0_CGC)
	
	cQuery := " SELECT ZD7.ZD7_DOC DOC, ZD7.ZD7_SERIE SERIE, ZD7.ZD7_CGCEMI EMIT, ZD7.ZD7_CHAVE CHAVE, "
	cQuery += " ZD7.ZD7_DTEMIS EMISSAO, ZD7.ZD7_TOTVAL TOTAL, ZD7.ZD7_TIPO TIPO "
	cQuery += " FROM " + RetSqlName(_cTab1) + " ZD7 "
	cQuery += " WHERE ZD7.D_E_L_E_T_ = ' ' AND ZD7.ZD7_CGCEMI IN " + cInCNPJ
	cQuery += " AND ZD7.ZD7_TIPO = '1' AND ZD7.ZD7_SIT <> '5' "
	cQuery += " AND ZD7.ZD7_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQuery += " AND ZD7.ZD7_DTEMIS BETWEEN '" + DToS(dData1) + "' AND '" + DToS(dData2) + "' "
		
	dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAliTemp, .F., .T.)
	
	(cAliTemp)->( dbEval({|| nCount++}) )
	
	oProc:SetRegua2(nCount + 1)
	
	(cAliTemp)->( dbGoTop() )
	
	oProc:SetRegua2(nCount)
	
	While !(cAliTemp)->( Eof() )
		
		aSit := ExisteNota((cAliTemp)->DOC, (cAliTemp)->CHAVE, (cAliTemp)->TIPO)
		
		If !aSit[1]
			
			lGerou := .T.
			
	        oFWMSEx:AddRow("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", ;
	        	{GetEmp((cAliTemp)->EMIT), GetFil((cAliTemp)->EMIT), SM0->M0_CODIGO, SM0->M0_CODFIL, (cAliTemp)->DOC, (cAliTemp)->SERIE, DToC(SToD((cAliTemp)->EMISSAO)), AllTrim(Transform((cAliTemp)->TOTAL, "@E 999,999,999.99")), (cAliTemp)->CHAVE})
	        	
	    EndIf
		
		(cAliTemp)->( dbSkip() )
		
	EndDo
	
	If !lGerou
		
		oFWMSEx:AddRow("Notas em Trânsitos", "Notas em Trânsito entre Grupos de Empresa", ;
		        	{"", "", "", "", "", "", "", "", ""})		
		
	EndIf
	
	(cAliTemp)->( dbCloseArea() )
	
	oProc:IncRegua1("Gerando Excel")
	
	If lGerou
		
		oFWMSEx:Activate()
		oFWMSEx:GetXMLFile(cArquivo)
		
		If ApOleClient("MsExcel")
		    
		    oExcel := MsExcel():New()
		    oExcel:WorkBooks:Open(cArquivo)
		    oExcel:SetVisible(.T.)
		    oExcel:Destroy()
			
		Else
			
			MsgAlert("Não foi encontrado o Excel para abrir o relatório :(")
			
		EndIf
		
	Else
			
		MsgInfo("Nenhuma nota em trânsito para a Empresa/Filial selecionada!!")
		
	EndIf
	
Return

Static Function ExisteNota(cFil, cChave, cTipo) 
	
	Local aRet := {.F., "", "", .F.}
	
	Default cTipo := "1"
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(8) )
	
	If SF1->( dbSeek(cFil + cChave) )
		
		aRet[1] := .T. // Nota Importada
		aRet[2] := "Nota Importada"
		aRet[4] := .T. // Nota Existe
		aRet[3] := SF1->F1_NOMEUSR
		
		Return aRet
		
	Else
		
		//
		
	EndIf
	
	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )
	If (_cTab1)->( dbSeek(cChave + cTipo) )
		
		aRet[4] := .T. // Nota Existe
		
		If (_cTab1)->&(_cCmp1 + "_SIT") == "2"
			
			aRet[1] := .T. //Nota Importada
			aRet[2] := "Nota Importada"
			If Empty(aRet[3])
				aRet[3] := (_cTab1)->&(_cCmp1 + "_USUIMP")
			EndIf
			
		ElseIf (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
			
			aRet[2] := "XML pendente para importar"
			
		ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "5"
			
			aRet[2] := "XML cancelado"
			
		ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "6"
			
			aRet[2] := "XML pendente e com inconsistência"
			
		EndIf
		
	Else
		
		aRet[2] := "XML não consta mais no Importador."
		
	EndIf
	
Return aRet

Static Function GetAllCNPJ(cExcCNPJ)

	Local cRet := "("
	Local nI
	
	For nI := 1 To Len(aSM0) 
		
		If AllTrim(aSM0[nI][18]) # AllTrim(cExcCNPJ)
			
			cRet += + "'" + AllTrim(aSM0[nI][18]) + "',"
			
		EndIf 
		
	Next nI
	
	cRet := SubStr(cRet, 1, Len(cRet) - 1) + ")"
	
Return cRet

Static Function GetEmp(cCGCEmit)
	
	Local nI
	
	For nI := 1 To Len(aSM0)
		
		If AllTrim(aSM0[nI][18]) == AllTrim(cCGCEmit)
			
			Return aSM0[nI][1]
			
		EndIf
		
	Next nI
	
Return ""

Static Function GetFil(cCGCEmit)
	
	Local nI
	
	For nI := 1 To Len(aSM0)
		
		If AllTrim(aSM0[nI][18]) == AllTrim(cCGCEmit)
			
			Return aSM0[nI][2]
			
		EndIf
		
	Next nI
	
Return ""
