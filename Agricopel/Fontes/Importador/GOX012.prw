#INCLUDE "PROTHEUS.CH"

// Relatório Unificado de XML's emitidos, escriturados, etc.

User Function GOX012(aParams)
	
	Local aParam := {}
	
	Private lAuto := .F.
	
	Default aParams := {"01", "0101"}
	
	//[TODO]
	// o Terceiro parâmetro indica o tipo de impressão
	// 1 - Todos
	// 2 - CT-e
	// 3 - Notas Pendentes
	
	If Select("SM0") == 0
		
		lAuto := .T.
		
		RpcSetType(3)
		RpcSetEnv(aParams[1], aParams[2])
		
	EndIf
	
	Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	
	If lAuto
		
		//Verifica(cFilAnt, cFilAnt, SToD(cValToChar(Year(Date())) + "0101"), LastDay(MonthSub(Date(), 1), 2))
		Verifica(cFilAnt, cFilAnt, SToD(Left(DToS(Date()), 6) + "01"), Date())
		
	Else
		
		If ParamBox({{1,"Filial de" , cFilAnt, "", "", "", "", FwSizeFilial(), .T.}, ;
					 {1,"Filial ate", cFilAnt, "", "", "", "", FwSizeFilial(), .T.}, ;
					 {1,"Data de", SToD(SubStr(DToS(dDataBase), 1, 6) + "01"),"","","","", 50, .T.}, ;
					 {1,"Data ate", dDataBase,"","","","", 50, .T.} ;
					}, "Filtros Relatório Unificado de XML", @aParam)
			
			Verifica(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
			
		EndIf
		
	EndIf
	
	If lAuto
		
		RpcClearEnv()
		
	EndIf
	
Return

Static Function Verifica(cFilDe, cFilAte, dData1, dData2)
	
	Local cQuery
	Local cIndex
	
	Private oProc
	
	If lAuto
		
		RefNotas(cFilDe, cFilAte, dData1, dData2)
		
	Else
		
		oProc := MsNewProcess():New({|| RefNotas(cFilDe, cFilAte, dData1, dData2)}, "Aguarde...", "Verificando Notas...")
		oProc:Activate()
		
	EndIf
	
Return

Static Function RefNotas(cFilDe, cFilAte, dData1, dData2)
	
	Local cArquivo
    Local oFWMSEx  := FWMsExcelEx():New()
    Local oExcel
	
	Local lGera    := .F.
	Local nCount   := 0 
	Local nI
	
	Local cCC      := GetNewPar("MV_ZCCSNPX", "")
	Local lMostra  := GetNewPar("MV_ZRXMMTD", .T.)
	
	Local lGerou := .F.
	
	Local cAliTemp := GetNextAlias()
	
	Private aXmlEmi
	Private aCteEmi
	
	If lAuto
		
		cArquivo := '\temp\Relatorio_Unificado_XML_' + cFilAnt + '_' + StrTran(Time(), ":", "") + '.xml'
		
	Else
		
		cArquivo := GetTempPath() + '\Relatorio_Unificado_XML_' + AllTrim(FWFilialName()) + '_' + StrTran(Time(), ":", "") + '.xml'
		
	EndIf
	
	If !lAuto .Or. lMostra
		
		oFWMSEx:AddworkSheet("Emitidos e nao Baixadas")
	        
	        oFWMSEx:AddTable("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas")
	            //Adicionando as colunas
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Filial", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Tipo", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Numero", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Serie", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Dt Emissão", 1, 2)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "CGC Emitente", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Nome", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Autorização", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Manifestação", 1, 1)
	            oFWMSEx:AddColumn("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", "Chave", 1, 1)
		
		If !lAuto
			oProc:SetRegua1(7)
		EndIf
		
		/////////////////////////////////////////// ABA NOTAS EMITIDAS
		
		If !lAuto
			oProc:IncRegua1("Buscando Notas nao Baixadas")
		EndIf
		
	EndIf
	
	aXmlEmi := GetXmlEmiCGC(cFilDe, cFilAte, dData1, dData2)
	
	If !lAuto .Or. lMostra
		
		If !lAuto
			oProc:SetRegua2(Len(aXmlEmi) + 1)
		EndIf
		
		For nI := 1 To Len(aXmlEmi)
			
			If !lAuto
				oProc:IncRegua2("Lendo notas")
			EndIf
			
			lGera := .T.
			
			If Empty(aXmlEmi[nI][1]:cIntegracao) .And. !ExisteNota(aXmlEmi[nI][3], aXmlEmi[nI][1]:cChave, "1")[4]
				
				lGerou := .T.
				
		        oFWMSEx:AddRow("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", ;
		        	{aXmlEmi[nI][3], GetNmNfe(aXmlEmi[nI][1]:cChave), PadL(AllTrim(aXmlEmi[nI][1]:cNumero), 9, "0"), aXmlEmi[nI][1]:cSerie, aXmlEmi[nI][2], aXmlEmi[nI][1]:cEmitente, GetEmiName(aXmlEmi[nI][1]:cEmitente), GetDescAut(aXmlEmi[nI][1]:cAutorizacao), GetDescMan(aXmlEmi[nI][1]:cManifestacao), aXmlEmi[nI][1]:cChave})
		        	
			EndIf
			
		Next nI
		
	EndIf
	
	////////////////////////////////////////// CT-e's Emitidos
	
	If !lAuto
		
		oProc:IncRegua1("Buscando CT-e's nao Baixados")
		
	EndIf
	
	aCteEmi := GetXmlEmiCGC(cFilDe, cFilAte, dData1, dData2, "1")
	
	If !lAuto .Or. lMostra
		
		If !lAuto
			oProc:SetRegua2(Len(aCteEmi) + 1)
		EndIf
		
		For nI := 1 To Len(aCteEmi)
			
			If !lAuto
				oProc:IncRegua2("Lendo CT-e's")
			EndIf
			
			lGera := .T.
			
			If Empty(aCteEmi[nI][1]:cIntegracao) .And. !ExisteNota(aCteEmi[nI][3], aCteEmi[nI][1]:cChave, "2")[4]
				
				lGerou := .T.
							
		        oFWMSEx:AddRow("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", ;
		        	{aCteEmi[nI][3], "CTE", PadL(AllTrim(aCteEmi[nI][1]:cNumero), 9, "0"), aCteEmi[nI][1]:cSerie, aCteEmi[nI][2], aCteEmi[nI][1]:cEmitente, GetEmiName(aCteEmi[nI][1]:cEmitente), GetDescAut(aCteEmi[nI][1]:cAutorizacao), GetDescMan(aCteEmi[nI][1]:cManifestacao), aCteEmi[nI][1]:cChave})
		        	
			EndIf
			
		Next nI
		
		If !lGerou
			
			oFWMSEx:AddRow("Emitidos e nao Baixadas", "Notas/Conhecimentos Emitidos e nao Baixadas", ;
		        	{"", "", "", "", "", "", "", "", "", ""})
			
		EndIf
		
	EndIf
	
	//----------------- Layout
	
	oFWMSEx:AddworkSheet("Baixadas e nao Escrituradas")
        
        oFWMSEx:AddTable("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados")
            //Adicionando as colunas
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Filial", 1, 1)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Tipo", 1, 1)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Numero", 1, 1)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Serie", 1, 1)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Dt Emissão", 1, 2)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "CGC Emitente", 1, 1)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Nome", 1, 1)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "UF", 1, 1) // novo
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "CFOP", 1, 1) // novo
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Valor Tot.", 3, 3)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Manifestação", 1, 1) // novo
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Chave", 1, 1)
            oFWMSEx:AddColumn("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", "Sit. Protheus", 1, 1)
	
	// ------------------------------- Notas Baixadas e nao Escrituradas
	
	If !lAuto
	
		oProc:IncRegua1("Buscando Notas e CT-e's nao Escriturados")
	
	EndIf
	
	cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " XML "
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND " + _cCmp1 + "_SIT IN ('1', '3', '4', '6') "
	cQuery += " AND (" + _cCmp1 + "_TIPO = '1' OR " + _cCmp1 + "_TIPO = '2') "
	cQuery += " AND " + _cCmp1 + "_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQuery += " AND " + _cCmp1 + "_DTEMIS BETWEEN '" + DToS(dData1) + "' AND '" + DToS(dData2) + "' "
	cQuery += " ORDER BY " + _cCmp1 + "_FILIAL, " + _cCmp1 + "_TIPO "
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAliTemp, .F., .T.)
	
	If !lAuto
		
		nCount := 0
		
		(cAliTemp)->( dbEval({|| nCount++}) )
		
		oProc:SetRegua2(nCount + 1)
		
		(cAliTemp)->( dbGoTop() )
		
	EndIf
	
	lGerou := .F.
	
	While !(cAliTemp)->( Eof() )
		
		If !lAuto
				
			oProc:IncRegua2("Lendo Status dos XML's")
			
		EndIf
		
		lGera  := .T.
		
		aSit := ExisteNota((cAliTemp)->&(_cCmp1 + "_FILIAL"), (cAliTemp)->&(_cCmp1 + "_CHAVE"), (cAliTemp)->&(_cCmp1 + "_TIPO"))
			
		If !aSit[1] .And. !(GetArrMan((cAliTemp)->&(_cCmp1 + "_CHAVE"), (cAliTemp)->&(_cCmp1 + "_TIPO"), 2) $ "3/4")
			
			lGerou := .T.
			
	        oFWMSEx:AddRow("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", ;
	        	{(cAliTemp)->&(_cCmp1 + "_FILIAL"), ;
	        		IIf((cAliTemp)->&(_cCmp1 + "_TIPO") == "1", GetNmNfe((cAliTemp)->&(_cCmp1 + "_CHAVE")), "CTE"), ;
	        		PadL(AllTrim((cAliTemp)->&(_cCmp1 + "_DOC")), 9, "0"), ;
	        		(cAliTemp)->&(_cCmp1 + "_SERIE"), ;
	        		SToD((cAliTemp)->&(_cCmp1 + "_DTEMIS")), ;
	        		(cAliTemp)->&(_cCmp1 + "_CGCEMI"), ;
	        		GetEmiName((cAliTemp)->&(_cCmp1 + "_CGCEMI")), ;
	        		GetEmiEst((cAliTemp)->&(_cCmp1 + "_CGCEMI")), ; // UF
	        		GetAllCFOP((cAliTemp)->&(_cCmp1 + "_CHAVE")), ; // CFOP
	        		(cAliTemp)->&(_cCmp1 + "_TOTVAL"), ;
	        		GetArrMan((cAliTemp)->&(_cCmp1 + "_CHAVE"), (cAliTemp)->&(_cCmp1 + "_TIPO")), ; // Manifestação
	        		(cAliTemp)->&(_cCmp1 + "_CHAVE"), ;
	        		aSit[2]})
        	
        EndIf
		
		(cAliTemp)->( dbSkip() )
		
	EndDo
	
	//(cAliTemp)->( dbCloseArea() )
	
	If !lGerou
		
		oFWMSEx:AddRow("Baixadas e nao Escrituradas", "Notas/Conhecimentos Baixados e nao Escriturados", ;
		        	{"", "", "", "", "", "", "", "", "", "", "", "", ""})
		
	EndIf
	
	///////////// Mesma query, porém com tratamento no while. 
	
	//----------------- Layout
	
	oFWMSEx:AddworkSheet("Desconhecimento/Op. nao Realizada")
        
        oFWMSEx:AddTable("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada")
            //Adicionando as colunas
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Filial", 1, 1)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Tipo", 1, 1)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Numero", 1, 1)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Serie", 1, 1)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Dt Emissão", 1, 2)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "CGC Emitente", 1, 1)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Nome", 1, 1)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "UF", 1, 1) // novo
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "CFOP", 1, 1) // novo
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Valor Tot.", 3, 3)
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Manifestação", 1, 1) // novo
            oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Chave", 1, 1)
            //oFWMSEx:AddColumn("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", "Sit. Protheus", 1, 1)
            
	(cAliTemp)->( dbGoTop() )
	
	If !lAuto
		
		oProc:SetRegua2(nCount + 1)
		
	EndIf
	
	lGerou := .F.
	
	While !(cAliTemp)->( Eof() )
		
		If !lAuto
				
			oProc:IncRegua2("Lendo Status dos XML's")
			
		EndIf
		
		lGera  := .T.
		
		aSit := ExisteNota((cAliTemp)->&(_cCmp1 + "_FILIAL"), (cAliTemp)->&(_cCmp1 + "_CHAVE"), (cAliTemp)->&(_cCmp1 + "_TIPO"))
			
		If !aSit[1] .And. GetArrMan((cAliTemp)->&(_cCmp1 + "_CHAVE"), (cAliTemp)->&(_cCmp1 + "_TIPO"), 2) $ "3/4"
			
			lGerou := .T.
			
	        oFWMSEx:AddRow("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", ;
	        	{(cAliTemp)->&(_cCmp1 + "_FILIAL"), ;
	        		IIf((cAliTemp)->&(_cCmp1 + "_TIPO") == "1", GetNmNfe((cAliTemp)->&(_cCmp1 + "_CHAVE")), "CTE"), ;
	        		PadL(AllTrim((cAliTemp)->&(_cCmp1 + "_DOC")), 9, "0"), ;
	        		(cAliTemp)->&(_cCmp1 + "_SERIE"), ;
	        		SToD((cAliTemp)->&(_cCmp1 + "_DTEMIS")), ;
	        		(cAliTemp)->&(_cCmp1 + "_CGCEMI"), ;
	        		GetEmiName((cAliTemp)->&(_cCmp1 + "_CGCEMI")), ;
	        		GetEmiEst((cAliTemp)->&(_cCmp1 + "_CGCEMI")), ; // UF
	        		GetAllCFOP((cAliTemp)->&(_cCmp1 + "_CHAVE")), ; // CFOP
	        		(cAliTemp)->&(_cCmp1 + "_TOTVAL"), ;
	        		GetArrMan((cAliTemp)->&(_cCmp1 + "_CHAVE"), (cAliTemp)->&(_cCmp1 + "_TIPO")), ; // Manifestação
	        		(cAliTemp)->&(_cCmp1 + "_CHAVE")})//, ;
	        		//aSit[2]})
        	
        EndIf
		
		(cAliTemp)->( dbSkip() )
		
	EndDo
	
	(cAliTemp)->( dbCloseArea() )
	
	If !lGerou
		
		oFWMSEx:AddRow("Desconhecimento/Op. nao Realizada", "Notas/Conhecimentos Desconhecimento/Op. nao Realizada", ;
		        	{"", "", "", "", "", "", "", "", "", "", "", ""})
		
	EndIf
	
	If !lAuto .Or. lMostra
		
		//----------------- Layout Escrituradas
		
		oFWMSEx:AddworkSheet("Notas/Conhecimentos Escrituradas com XML")
	        
	        oFWMSEx:AddTable("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados")
	            //Adicionando as colunas
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Filial", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Tipo", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Numero", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Serie", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Dt Emissão", 1, 2)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Dt Digit.", 1, 2)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "CGC Emitente", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Nome", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "UF", 1, 1) // Nova
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "CFOP", 1, 1) // Nova 
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Valor Tot.", 3, 3)
	            //oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Autorização", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Manifestação", 1, 1) // Nova
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Chave", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", "Pre-nota?", 1, 1)
		
		If !lAuto
			oProc:IncRegua1("Buscando Notas Escrituradas")
		EndIf
		
		cQuery := " SELECT * FROM " + RetSqlName("SF1") + " SF1 "
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND F1_CHVNFE <> ' ' AND F1_FORMUL <> 'S' "
		cQuery += " AND F1_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
		cQuery += " AND F1_DTDIGIT BETWEEN '" + DToS(dData1) + "' AND '" + DToS(dData2) + "' "
		cQuery += " ORDER BY F1_FILIAL, F1_ESPECIE DESC "
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAliTemp, .F., .T.)
		
		If !lAuto
			
			nCount := 0
			
			(cAliTemp)->( dbEval({|| nCount++}) )
			
			oProc:SetRegua2(nCount + 1)
			
			(cAliTemp)->( dbGoTop() )
			
		EndIf
		
		//oProc:SetRegua2(Len(aXmlEmi) + 1)
		
		lGerou := .F.
		
		While !(cAliTemp)->( Eof() )
			
			If !lAuto
				oProc:IncRegua2("Lendo Status das Notas")
			EndIf
			
			lGera  := .T.
			
			aSit := ExisteNota((cAliTemp)->F1_FILIAL, (cAliTemp)->F1_CHVNFE, IIf(AllTrim((cAliTemp)->F1_ESPECIE) == "SPED", "1", "2"))
				
			If aSit[1]
				
				lGerou := .T.
				
				If (cAliTemp)->F1_TIPO $ "D;B"
					
					cCgcFor := Posicione("SA1", 1, xFilial("SA1") + (cAliTemp)->F1_FORNECE + (cAliTemp)->F1_LOJA, "A1_CGC")
					
				Else
					
					cCgcFor := Posicione("SA2", 1, xFilial("SA2") + (cAliTemp)->F1_FORNECE + (cAliTemp)->F1_LOJA, "A2_CGC")
					
				EndIf
				
		        oFWMSEx:AddRow("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", ;
		        	{(cAliTemp)->F1_FILIAL, ;
		        	 IIf(AllTrim((cAliTemp)->F1_ESPECIE) == "SPED", GetNmNfe((cAliTemp)->F1_CHVNFE), "CTE"), ;
		        	 PadL(AllTrim((cAliTemp)->F1_DOC), 9, "0"), ;
		        	 (cAliTemp)->F1_SERIE, ;
		        	 SToD((cAliTemp)->F1_EMISSAO), ;
		        	 SToD((cAliTemp)->F1_DTDIGIT), ;
		        	 cCgcFor, ;
		        	 GetEmiName(cCgcFor), ;
		        	 GetEmiEst(cCgcFor), ; // UF
		        	 GetAllCFOP((cAliTemp)->F1_CHVNFE), ; // CFOP
		        	 (cAliTemp)->F1_VALMERC, ;
		        	 GetArrMan((cAliTemp)->F1_CHVNFE, IIf(AllTrim((cAliTemp)->F1_ESPECIE) == "SPED", "1", "2")), ; // Manifestação
		        	 (cAliTemp)->F1_CHVNFE, ;
		        	 IIf(Empty((cAliTemp)->F1_STATUS), "Sim", "nao")})
		        	 //aSit[3]})
				
			EndIf
			
			(cAliTemp)->( dbSkip() )
			
		EndDo
		
		(cAliTemp)->( dbCloseArea() )
		
		If !lGerou
			
			oFWMSEx:AddRow("Notas/Conhecimentos Escrituradas com XML", "Notas/Conhecimentos Baixados e Escriturados", ;
			        	{"", "", "", "", "", "", "", "", "", "", "", "", "", ""})
			
		EndIf
		
	EndIf
	
	////////////////////////// ABA DE NOTAS CANCELADAS ///////////////
	
	If !lAuto .Or. lMostra
		
		//----------------- Layout Escrituradas
		
		oFWMSEx:AddworkSheet("Notas/Conhecimentos Cancelados")
	        
	        oFWMSEx:AddTable("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados")
	            //Adicionando as colunas
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Filial", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Tipo", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Numero", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Serie", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Dt Cancel.", 1, 2)
	            //oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Dt Digit.", 1, 2)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "CGC Emitente", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Nome", 1, 1)
	            //oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Valor Tot.", 3, 3)
	            //oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Autorização", 1, 1)
	            //oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Manifestação", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Chave", 1, 1)
	            oFWMSEx:AddColumn("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", "Obs", 1, 1)
		
		If !lAuto
			oProc:IncRegua1("Buscando Notas/CT-e's Cancelados")
		EndIf
		
		cQuery := " SELECT * FROM " + RetSqlName(_cTab1) + " XML "
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND " + _cCmp1 + "_SIT IN ('1', '3', '2', '6') "
		cQuery += " AND " + _cCmp1 + "_TIPO = '5' "
		cQuery += " AND " + _cCmp1 + "_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
		cQuery += " AND " + _cCmp1 + "_DTCRIA BETWEEN '" + DToS(dData1) + "' AND '" + DToS(dData2) + "' "
		cQuery += " ORDER BY " + _cCmp1 + "_FILIAL, " + _cCmp1 + "_TPCAN "
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAliTemp, .F., .T.)
		
		If !lAuto
			
			nCount := 0
			
			(cAliTemp)->( dbEval({|| nCount++}) )
			
			oProc:SetRegua2(nCount + 1)
			
			(cAliTemp)->( dbGoTop() )
			
		EndIf
		
		//oProc:SetRegua2(Len(aXmlEmi) + 1)
		
		lGerou := .F.
		
		While !(cAliTemp)->( Eof() )
			
			If !lAuto
				oProc:IncRegua2("Lendo Status das Cancelamentos")
			EndIf
			
			lGera  := .T.
			
			aSit1 := ExisteNota((cAliTemp)->&(_cCmp1 + "_FILIAL"), (cAliTemp)->&(_cCmp1 + "_CHAVE"), "1")
			
			aSit2 := ExisteNota((cAliTemp)->&(_cCmp1 + "_FILIAL"), (cAliTemp)->&(_cCmp1 + "_CHAVE"), "2")
				
			If !aSit1[1] .And. !aSit2[1]
				
				lGerou := .T.
				
				oFWMSEx:SetCelFrColor("#000000")
				oFWMSEx:SetCelBgColor("#B8CCE4")
				
				oFWMSEx:AddRow("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", ;
		        	{(cAliTemp)->&(_cCmp1 + "_FILIAL"), IIf(SubStr((cAliTemp)->&(_cCmp1 + "_CHAVE"), 21, 2) == "55", GetNmNfe((cAliTemp)->&(_cCmp1 + "_CHAVE")), "CTE"), PadL(AllTrim((cAliTemp)->&(_cCmp1 + "_DOC")), 9, "0"), (cAliTemp)->&(_cCmp1 + "_SERIE"), SToD((cAliTemp)->&(_cCmp1 + "_DTCRIA")), (cAliTemp)->&(_cCmp1 + "_CGCEMI"), GetEmiName((cAliTemp)->&(_cCmp1 + "_CGCEMI")), (cAliTemp)->&(_cCmp1 + "_CHAVE"), "NF-e/CT-e nao consta mais no sistema!"})
				
			Else
				
				oFWMSEx:SetCelFrColor("#000000")
				oFWMSEx:SetCelBgColor("#FF7F50")
				
				oFWMSEx:AddRow("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", ;
		        	{(cAliTemp)->&(_cCmp1 + "_FILIAL"), IIf(SubStr((cAliTemp)->&(_cCmp1 + "_CHAVE"), 21, 2) == "55", GetNmNfe((cAliTemp)->&(_cCmp1 + "_CHAVE")), "CTE"), PadL(AllTrim((cAliTemp)->&(_cCmp1 + "_DOC")), 9, "0"), (cAliTemp)->&(_cCmp1 + "_SERIE"), SToD((cAliTemp)->&(_cCmp1 + "_DTCRIA")), (cAliTemp)->&(_cCmp1 + "_CGCEMI"), GetEmiName((cAliTemp)->&(_cCmp1 + "_CGCEMI")), (cAliTemp)->&(_cCmp1 + "_CHAVE"), "NF-e/CT-e AINDA CONSTA NO SISTEMA!!!"})
				
			EndIf
			
			(cAliTemp)->( dbSkip() )
			
		EndDo
		
		(cAliTemp)->( dbCloseArea() )
		
		If !lGerou
			
			oFWMSEx:AddRow("Notas/Conhecimentos Cancelados", "Notas/Conhecimentos Cancelados", ;
			        	{"", "", "", "", "", "", "", "", ""})
			
		EndIf
		
	EndIf
	
	//////////////////////////////////////////////////////////////////
	
	If lGera
		
		oFWMSEx:Activate()
		oFWMSEx:GetXMLFile(cArquivo)
			    
		If lAuto
			
			//CpyT2S(cArquivo, "\temp\", .T.)
			
			/*If File("\temp\" + SubStr(cArquivo, RAt("\", cArquivo) + 1))
				
				cArquivo := "\temp\" + SubStr(cArquivo, RAt("\", cArquivo) + 1)
				
			EndIf*/
			
			//cArquivo
			oProcess := TWFProcess():New("000001", OemToAnsi("Xmls nao escriturados"))
			
			oProcess:NewTask("000001", "\workflow\modelos\importador\XML_NAO_ESCRI.htm")
			
			oProcess:cSubject 	:= "XML's nao escriturados"
			oProcess:bReturn  	:= ""
			oProcess:bTimeOut	:= {}
			oProcess:fDesc 		:= "XML's nao escriturados"
			oProcess:ClientName(cUserName)
			oHTML := oProcess:oHTML
			
			oHTML:ValByName('cDataDe', DToC(dData1))
			
			oHTML:ValByName('cDataAte', DToC(dData2))
			
			oHTML:ValByName('cEmp', FWGrpName())
			oHTML:ValByName('cFil', FWFilialName())
			
			oHTML:ValByName('cMsg', ;
			"Você esta recebendo o relatorio das situações dos XML's no Protheus.")
			
			oProcess:AttachFile(cArquivo)
						
			oProcess:cTo := AllTrim(GetNewPar("MV_ZGOEMXN", "octavio@gooneconsultoria.com.br")) + cCC
			
			oProcess:Start()
			
			oProcess:Finish()
			
		Else
			
			If ApOleClient("MsExcel")
			    
			    oExcel := MsExcel():New()
			    oExcel:WorkBooks:Open(cArquivo)
			    oExcel:SetVisible(.T.)
			    oExcel:Destroy()
				
			Else
				
				MsgAlert("nao foi encontrado o Excel para abrir o relatorio :(")
				
			EndIf
			
		EndIf
		
	Else
		
		If !lAuto
			
			MsgInfo("Nenhuma nota encontrada para gerar o relatorio!!")
			
		EndIf
		
	EndIf
	
Return

Static Function GetXmlEmiCGC(cFilDe, cFilAte, dData1, dData2, cTipo)
	
	Local oWS := WSUrbano():New()
	Local nI
	Local nX
	Local aArr    := {}
	Local nFil
	Local aFil    := {}
	Local aCnpjs  := {}
	Local aAllFil := {}
	
	Default cTipo := "0"
	
	aAllFil := FWAllFilial(, , SM0->M0_CODIGO, .F.)
	
	For nI := 1 To Len(aAllFil)
		
		If aAllFil[nI] >= cFilDe .And. aAllFil[nI] <= cFilAte
			
			aFil := FWArrFilAtu(SM0->M0_CODIGO, aAllFil[nI])
			AAdd(aCnpjs, {AllTrim(aFil[18]), aAllFil[nI]})
			
		EndIf
		
	Next nI
	
	For nFil := 1 To Len(aCnpjs)
		
		oWS:Reset()
		
		oWS:cLogin   := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
		oWS:cSenha   := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
		oWS:cTipoDoc := cTipo
		oWS:cCNPJ    := AllTrim(aCnpjs[nFil][1])
		
		For nI := 0 To (dData2 - dData1)
			
			oWS:cDataEmissao := DToS(dData1 + nI)
			
			If oWS:ListaDocumentos()
				
				For nX := 1 To Len(OWS:OWSLISTADOCUMENTOSRESULT:OWSDOCUMENTOS)
					
					If !Empty(OWS:OWSLISTADOCUMENTOSRESULT:OWSDOCUMENTOS[nX]:cChave)
						
						AAdd(aArr, {OWS:OWSLISTADOCUMENTOSRESULT:OWSDOCUMENTOS[nX], SToD(oWS:cDataEmissao), aCnpjs[nFil][2]})
						
					EndIf
					
				Next nX
				
			EndIf
			
		Next nI
		
	Next nFil
	
Return aArr

User Function TesteGGG()
	
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	GetXmlEmiCGC("01", "01", SToD("20171210"), SToD("20171210"))
	
	RpcClearEnv()
	
Return

Static Function GetDescAut(cAut)
	
	Local cRet := ""
	
	If cAut == "0"
		
		cRet := "Em Fila de Validação"
		
	ElseIf cAut == "1"
		
		cRet := "Documento Autorizado"
		
	ElseIf cAut == "2"	
		
		cRet := "Documento Cancelado ou Denegado"
		
	ElseIf cAut == "3"
		
		cRet := "Impossivel de Consultar no SEFAZ"
		
	ElseIf cAut == "6"
		
		cRet := "Falha na consulta (Nova tentativa de validação sera feita no dia seguinte)"
		
	EndIf
	
Return cRet

Static Function GetDescMan(cMan)
	
	Local cRet := ""
	
	If cMan == "0"
		
		cRet := "Documento nao Manifestado"
		
	ElseIf cMan == "1"
		
		cRet := "Ciência da Operação"
		
	ElseIf cMan == "2"	
		
		cRet := "Confirmação da Operação"
		
	ElseIf cMan == "3"
		
		cRet := "Desconhecimento da Operação"
		
	ElseIf cMan == "4"
		
		cRet := "Operação nao Realizada"
		
	EndIf
	
Return cRet

Static Function GetEmiName(cCGC)
	
Return FWNoAccent(U_CliForGO(cCGC)[7])

Static Function GetEmiEst(cCGC)
	
Return U_CliForGO(cCGC)[5]

Static Function ExisteNota(cFil, cChave, cTipo) 
	
	Local aRet := {.F., "", "", .F.}
	
	Default cTipo := "1"
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(8) )
	
	If SF1->( dbSeek(cFil + cChave) )
		
		aRet[1] := .T. // Nota Importada
		aRet[2] := "Nota Importada"
		aRet[4] := .T. // Nota Existe
		aRet[3] := "--"
		
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
		
		aRet[2] := "XML nao consta mais no Importador."
		
	EndIf
	
Return aRet

Static Function GetEmiNmChv(cChave)
	
	Local aAreaXML := (_cTab1)->( GetArea() )
	Local cRet     := ""
	
	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )
	If (_cTab1)->( dbSeek(cChave + "2") )
		
		cRet := GetEmiName((_cTab1)->&( _cCmp1 + "_CGCEMI" ))
		
	EndIf
	
	RestArea(aAreaXML)
	
Return cRet

Static Function GetEmiCgcC(cChave)
	
	Local aAreaXML := (_cTab1)->( GetArea() )
	Local cRet     := ""
	
	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )
	If (_cTab1)->( dbSeek(cChave + "2") )
		
		cRet := (_cTab1)->&( _cCmp1 + "_CGCEMI" )
		
	EndIf
	
	RestArea(aAreaXML)
	
Return cRet

Static Function GetArrMan(cChave, cTipo, nRet)
	
	Local cRet := ""
	Local nPos
	
	Default nRet := 1
	
	If cTipo == "1"
		
		If (nPos := AScan(aXmlEmi, {|x| x[1]:cChave == cChave})) > 0
			
			If nRet == 1
				
				cRet := GetDescMan(aXmlEmi[nPos][1]:cManifestacao)
				
			Else
				
				cRet := aXmlEmi[nPos][1]:cManifestacao
				
			EndIf
			
		EndIf
		
	ElseIf cTipo == "2"
		
		If (nPos := AScan(aCteEmi, {|x| x[1]:cChave == cChave})) > 0
			
			If nRet == 1
				
				cRet := GetDescMan(aCteEmi[nPos][1]:cManifestacao)
				
			Else
				
				cRet := aCteEmi[nPos][1]:cManifestacao
				
			EndIf
			
		EndIf
		
	EndIf
	
	If Empty(cRet)
		
		If nRet == 1
			
			cRet := "Manifestação nao encontrada"
			
		Else
			
			cRet := "-1"
			
		EndIf
		
	EndIf
	
Return cRet

Static Function GetAllCFOP(cChave)
	
	Local cRet     := ""  
	Local cError   := ""
	Local cWarning := ""
	Local cCFOP    := ""
	Local nX
	
	Private oXml
	
	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )
	If (_cTab1)->( dbSeek(cChave) )
		
		oXml := XmlParser((_cTab1)->&(_cCmp1 + "_XML"), "_", @cError, @cWarning)
		
		If (_cTab1)->&(_cCmp1 + "_TIPO") == "2" // CT-e
			
			//cRet := StaticCall(GOX001, GetNodeCTe, oXml, "_infCte:_ide:_CFOP:Text")
			
			cRet := U_GOX1GNCT(oXml, "_infCte:_ide:_CFOP:Text")
			
		Else
			
			If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") # "U"
				
				If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
					
					XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
					
				EndIf
				
				For nX := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)
					
					cCFOP := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nX]:_prod:_CFOP:Text)
					
					If !(cCFOP $ cRet)
						
						If nX > 1
							
							cRet += ","
							
						EndIf
						
						cRet += AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nX]:_prod:_CFOP:Text)
						
					EndIf
					
				Next nX
			
			EndIf
			
		EndIf
		
		If ValType(oXml) == "O"
			
			FreeObj(oXml)
			oXml := Nil
			
		EndIf
		
		DelClassIntf()
		
	EndIf
	
Return cRet

Static Function GetNmNfe(cChave)
	
	If SubStr(cChave, 21, 2) == "65"
		
		Return "NFCE"
		
	EndIf
	
Return "NFE"
