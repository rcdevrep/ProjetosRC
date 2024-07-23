#include 'parmtype.ch'
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "FILEIO.CH"
#Include "FWCommand.ch"

User Function XAG0022(_cFilial,_cNumCtr,_cNumPln,_cCntCrt,_cCntLng,_dDtBase,_vValJur,_cCntJur,_cRevisa,_cTipoCtr)

	Local _cMvPlnJur := SuperGetMv("MV_XPLNJUR",.F.,"003")
	Local _cMvPlnCdc := SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local _lPrPrc := .F.
	Local _MedJur := .F.
	Local cQuery  := ""
	Local _cMsg   := ""
	Local cErro	  := ""
	Local _nX	  := 0
	Local _nVlr1  := 0
	Local _nVlr2  := 0
	Local _nVlr3  := 0
	Local aItens  := {}
	Local aCab	  := {}
	Private lMsErroAuto

	// Verificar se eh CDC e JUROS
	If _cTipoCtr == _cMvPlnCdc .and. CNA->CNA_TIPPLA == _cMvPlnJur

		// Verifica as parcelas em aberto para o contrato
		cQuery := " SELECT	CONCAT(SUBSTRING(CNF.CNF_COMPET,4,4),SUBSTRING(CNF.CNF_COMPET,1,2)), "
		cQuery += " 		SUM(CASE WHEN CNF.CNF_NUMPLA = '"+CNA->CNA_NUMERO+"' THEN ((CNF.CNF_VLPREV/58)*12)*-1 ELSE CNF.CNF_VLPREV END) AS VLPREV "
		cQuery += " FROM 	" + RetSqlName("CNF") + " CNF "
		cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9 ON (CN9.CN9_FILIAL = CNF.CNF_FILIAL AND CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA) "
		cQuery += " WHERE 	CNF.D_E_L_E_T_ = ' ' "
		cQuery += " AND 	CNF.CNF_FILIAL = '" + _cFilial + "' " 
		cQuery += " AND 	CNF.CNF_CONTRA = '" + _cNumCtr + "' "
		cQuery += " AND 	CNF.CNF_SALDO  <> 0 "
		cQuery += " AND 	CN9.CN9_SITUAC = '05' "
		cQuery += " GROUP BY CONCAT(SUBSTRING(CNF.CNF_COMPET,4,4),SUBSTRING(CNF.CNF_COMPET,1,2)) "
		cQuery += " ORDER BY 1 "
		cQuery := ChangeQuery(cQuery)  			
		If Select("QRYT1") <> 0
			QRYT1->(dbCloseArea())
		EndIf
		TCQuery cQuery NEW ALIAS "QRYT1"
		dbSelectArea("QRYT1")
		QRYT1->(dbGoTop()) 
	
		If Contar("QRYT1","!EOF()") > 0
			
			_nX		:= 1
			_nVlr1	:= 0
			_nVlr2	:= 0

			// Busca Juros
			QRYT1->(dbGoTop())
			While QRYT1->(!EOF())
			
				// Verifica se é a primeira parcela do contrato
				If CND->CND_PARCEL == "001"
					_lPrPrc := .T.
				EndIf
				// Guarda valor das primeiras 12 iterações
				If _nX > 1 .and. _nX < 14
					_nVlr2 += QRYT1->VLPREV
				EndIf
				// Guarda o valor para a 13a. parcela
				If _nX = 14
					_nVlr1 := QRYT1->VLPREV
				EndIf
				// Reinicia
				_nX++
				QRYT1->(DBSKIP())
	
			EndDo 
			
			If _lPrPrc
				
				_nVlr3 := _nVlr2
				
				aCab	:=   { {'DDATALANC'	,_dDtBase	,NIL},;
							   {'CLOTE'		,'008850'	,NIL},;
							   {'CSUBLOTE' 	,'001'		,NIL},;
							   {'CDOC' 		, STRZERO(seconds(),6),NIL},;
							   {'CPADRAO' 	,''			,NIL},;
							   {'NTOTINF' 	,0			,NIL},;
							   {'NTOTINFLOT',0			,NIL} }
				
				_cMsg  := "TRANSF. LONGO P/ CURTO REF."+Substr(DtoS(_dDtBase),5,2)+"/"+substr(DtoS(_dDtBase),1,4)+" CONTR "+_cNumCtr
				aItens := {}
				
				// Adiciona dados no array
				aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial	, NIL},;
							  {'CT2_LINHA' 		,'001'		, NIL},;
							  {'CT2_MOEDLC' 	,'01' 		, NIL},; 
							  {'CT2_DC' 		,'3' 		, NIL},;
							  {'CT2_DEBITO' 	,_cCntLng 	, NIL},;
							  {'CT2_CREDIT' 	,_cCntCrt 	, NIL},;
							  {'CT2_VALOR' 		,_nVlr3		, NIL},;
							  {'CT2_ORIGEM' 	,'XAG0022'	, NIL},;
							  {'CT2_HP' 		,''			, NIL},;
							  {'CT2_CONVER'		,'15555'	, NIL},;
							  {'CT2_HIST' 		,Substr(_cMsg,1,40), NIL} } )
		
				// Complemento de historico
				aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial 	, NIL},;
							  {'CT2_LINHA'		,'002' 		, NIL},;
							  {'CT2_DC'			,'4' 		, NIL},;
							  {'CT2_HIST'		,Substr(_cMsg,41,80), NIL} } )
		
				// Executa inclusão no Contabil
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z|CTBA102(x,y,z)},aCab,aItens,3)
				If lMsErroAuto
					conout('Erro na inclusao!')
					MostraErro()
				EndIf

			Else
				_nVlr3 := _nVlr1
			EndIf
			
			// Aguarda 2 segundos para afazer o proximo processamento
			sleep(2000)
			
		 	// Zera variavel
		 	aItens  := {}
		 	
			aCab	:= { {'DDATALANC'	,_dDtBase	,NIL},;
					     {'CLOTE'		,'008850'	,NIL},;
					     {'CSUBLOTE' 	,'001'		,NIL},;
					     {'CDOC' 		, STRZERO(seconds(),6)	,NIL},;
					     {'CPADRAO' 	,''			,NIL},;
					     {'NTOTINF' 	,0			,NIL},;
					     {'NTOTINFLOT'	,0			,NIL} }
			
			_cMsg := "JUROS REF. "+Substr(DtoS(_dDtBase),5,2)+"/"+substr(DtoS(_dDtBase),1,4)+" CONTR."+_cNumCtr
			
			// Adiciona dados no array
			_cConta := Iif(_lPrPrc,_cCntLng,_cCntCrt)
			aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial	, NIL},;
						  {'CT2_LINHA' 		,'001'		, NIL},;
						  {'CT2_MOEDLC' 	,'01' 		, NIL},; 
						  {'CT2_DC' 		,'3' 		, NIL},;
						  {'CT2_DEBITO' 	,_cCntJur 	, NIL},;
						  {'CT2_CREDIT' 	,_cConta	, NIL},;
						  {'CT2_CCD'	 	,"1098" 	, NIL},;
						  {'CT2_VALOR' 		,_vValJur	, NIL},;
						  {'CT2_ORIGEM' 	,'XAG0022'	, NIL},;
						  {'CT2_HP' 		,''			, NIL},;
						  {'CT2_CONVER'		,'15555'	, NIL},;
						  {'CT2_HIST' 		,Substr(_cMsg,1,40), NIL} } )
						  
		    lMsErroAuto := .F.
			MSExecAuto({|x,y,z|CTBA102(x,y,z)},aCab,aItens,3)
			If lMsErroAuto
				conout('Erro na inclusao!')
				MostraErro()
			EndIf
	
		EndIf

		// Aguarda 2 segundos para afazer o proximo processamento
		sleep(2000)

		If CND->CND_PARCEL <> "001"
			
			// Verifica as parcelas em aberto para o contrato
			cQuery := " SELECT	CONCAT(SUBSTRING(CNF.CNF_COMPET,4,4),SUBSTRING(CNF.CNF_COMPET,1,2)), "
			cQuery += " 		SUM(CASE WHEN CNF.CNF_NUMPLA = '"+CNA->CNA_NUMERO+"' THEN ((CNF.CNF_VLPREV/58)*12)*-1 ELSE CNF.CNF_VLPREV END) AS VLPREV "
			cQuery += " FROM 	" + RetSqlName("CNF") + " CNF "
			cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9 ON (CN9.CN9_FILIAL = CNF.CNF_FILIAL AND CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA) "
			cQuery += " WHERE 	CNF.D_E_L_E_T_ = ' ' "
			cQuery += " AND 	CNF.CNF_FILIAL = '" + _cFilial + "' " 
			cQuery += " AND 	CNF.CNF_CONTRA = '" + _cNumCtr + "' "
			cQuery += " AND 	CNF.CNF_SALDO  <> 0 "
			cQuery += " AND 	CN9.CN9_SITUAC = '05' "
			cQuery += " GROUP BY CONCAT(SUBSTRING(CNF.CNF_COMPET,4,4),SUBSTRING(CNF.CNF_COMPET,1,2)) "
			cQuery += " ORDER BY 1 "
			cQuery := ChangeQuery(cQuery)  			
			If Select("QRYT1") <> 0
				QRYT1->(dbCloseArea())
			EndIf
			TCQuery cQuery NEW ALIAS "QRYT1"
			dbSelectArea("QRYT1")
			QRYT1->(dbGoTop()) 
		
			If Contar("QRYT1","!EOF()") > 0
				
				_nX		:= 1
				_nVlr1	:= 0
				_nVlr2	:= 0
	
				// Busca Juros
				QRYT1->(dbGoTop())
				While QRYT1->(!EOF())
				
					// Guarda valor das primeiras 12 iterações
					If _nX = 12 .and. _nX < 14
						_nVlr2 += QRYT1->VLPREV
					EndIf
					// Reinicia
					_nX++
					QRYT1->(DBSKIP())
		
				EndDo 
				
				// Zera variavel
			 	aItens  := {}
			 	
				aCab	:= { {'DDATALANC'	,_dDtBase	,NIL},;
						     {'CLOTE'		,'008850'	,NIL},;
						     {'CSUBLOTE' 	,'001'		,NIL},;
						     {'CDOC' 		, STRZERO(seconds(),6)	,NIL},;
						     {'CPADRAO' 	,''			,NIL},;
						     {'NTOTINF' 	,0			,NIL},;
						     {'NTOTINFLOT'	,0			,NIL} }
				
				_cMsg  := "TRANSF. LONGO P/ CURTO REF."+Substr(DtoS(_dDtBase),5,2)+"/"+substr(DtoS(_dDtBase),1,4)+" CONTR "+_cNumCtr
				aItens := {}
								
				// Adiciona dados no array
				aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial	, NIL},;
							  {'CT2_LINHA' 		,'001'		, NIL},;
							  {'CT2_MOEDLC' 	,'01' 		, NIL},; 
							  {'CT2_DC' 		,'3' 		, NIL},;
							  {'CT2_DEBITO' 	,_cCntLng 	, NIL},;
							  {'CT2_CREDIT' 	,_cCntCrt	, NIL},;
							  {'CT2_CCD'	 	,"1098" 	, NIL},;
							  {'CT2_VALOR' 		,_nVlr2		, NIL},;
							  {'CT2_ORIGEM' 	,'XAG0022'	, NIL},;
							  {'CT2_HP' 		,''			, NIL},;
							  {'CT2_CONVER'		,'15555'	, NIL},;
							  {'CT2_HIST' 		,Substr(_cMsg,1,40), NIL} } )
		
				// Complemento de historico
				aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial 	, NIL},;
							  {'CT2_LINHA'		,'002' 		, NIL},;
							  {'CT2_DC'			,'4' 		, NIL},;
							  {'CT2_HIST'		,Substr(_cMsg,41,80), NIL} } )
							  
			    lMsErroAuto := .F.
				MSExecAuto({|x,y,z|CTBA102(x,y,z)},aCab,aItens,3)
				If lMsErroAuto
					conout('Erro na inclusao!')
					MostraErro()
				EndIf
		
			EndIf

		EndIf

	Else
	
		// Verifica as parcelas em aberto para o contrato
		cQuery := " SELECT	CNF.CNF_PARCEL, CNF.CNF_COMPET, SUM(CNF.CNF_VLPREV) AS VLPREV "
		cQuery += " FROM 	" + RetSqlName("CNF") + " CNF "
		cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9 ON (CN9.CN9_FILIAL = CNF.CNF_FILIAL AND CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA) "
		cQuery += " WHERE 	CNF.D_E_L_E_T_ = ' ' "
		cQuery += " AND 	CNF.CNF_FILIAL = '" + _cFilial + "'" 
		cQuery += " AND 	CNF.CNF_CONTRA = '" + _cNumCtr + "'"
		cQuery += " AND 	CNF.CNF_SALDO  <> 0 "
		cQuery += " AND 	CN9.CN9_SITUAC = '05' "
		cQuery += " GROUP BY CNF.CNF_PARCEL, CNF.CNF_COMPET"
		cQuery := ChangeQuery(cQuery)  			
		If Select("QRYT1") <> 0
			QRYT1->(dbCloseArea())
		EndIf
		TCQuery cQuery NEW ALIAS "QRYT1"
		dbSelectArea("QRYT1")
		QRYT1->(dbGoTop()) 
	
		If Contar("QRYT1","!EOF()") > 0
			
			_nX    := 1
			_nVlr1 := 0
			_nVlr2 := 0
			QRYT1->(dbGoTop())
			
			While QRYT1->(!EOF())
			
				// Verificar se é medição de juros
				If CNA->CNA_TIPPLA == _cMvPlnJur
					_MedJur := .T.
				EndIf
				
				// Verifica se é a primeira parcela do contrato
				If QRYT1->CNF_PARCEL == "001" .and. _MedJur
					_lPrPrc := .T.
				EndIf
				
				// Guarda valor das primeiras 12 iterações
				If _nX < 13
					_nVlr2 += QRYT1->VLPREV
				EndIf
				
				// Guarda o valor para a 13a. parcela
				If _nX = 13
					_nVlr1 := QRYT1->VLPREV
				EndIf
				
				_nX++
				QRYT1->(DBSKIP())
	
			EndDo 
			
			If _lPrPrc
				_nVlr3 := _nVlr2
			Else
				_nVlr3 := _nVlr1
			EndIf
			
			aCab	:=   { {'DDATALANC'	,_dDtBase	,NIL},;
						   {'CLOTE'		,'008850'	,NIL},;
						   {'CSUBLOTE' 	,'001'		,NIL},;
						   {'CDOC' 		, STRZERO(seconds(),6),NIL},;
						   {'CPADRAO' 	,''			,NIL},;
						   {'NTOTINF' 	,0			,NIL},;
						   {'NTOTINFLOT',0			,NIL} }
			
			_cMsg  := "TRANSF. LONGO P/ CURTO REF. "+Substr(DtoS(_dDtBase),5,2)+"/"+substr(DtoS(_dDtBase),1,4)+" CONTR. "+_cNumCtr
			aItens := {}
			
			// Adiciona dados no array
			aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial	, NIL},;
						  {'CT2_LINHA' 		,'001'		, NIL},;
						  {'CT2_MOEDLC' 	,'01' 		, NIL},; 
						  {'CT2_DC' 		,'3' 		, NIL},;
						  {'CT2_DEBITO' 	,_cCntLng 	, NIL},;
						  {'CT2_CREDIT' 	,_cCntCrt 	, NIL},;
						  {'CT2_VALOR' 		,_nVlr3		, NIL},;
						  {'CT2_ORIGEM' 	,'XAG0022'	, NIL},;
						  {'CT2_HP' 		,''			, NIL},;
						  {'CT2_CONVER'		,'15555'	, NIL},;
						  {'CT2_HIST' 		,Substr(_cMsg,1,40), NIL} } )
	
			// Complemento de historico
			aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial 	, NIL},;
						  {'CT2_LINHA'		,'002' 		, NIL},;
						  {'CT2_DC'			,'4' 		, NIL},;
						  {'CT2_HIST'		,Substr(_cMsg,41,80), NIL} } )
	
			// Executa inclusão no Contabil
			If _MedJur
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z|CTBA102(x,y,z)},aCab,aItens,3)
				If lMsErroAuto
					conout('Erro na inclusao!')
					MostraErro()
				EndIf
			EndIf
			
			// Aguarda 2 segundos para afazer o proximo processamento
			sleep(2000)
			
			// Realiza contabilização dos juros corridos
			If _MedJur
			
			 	// Zera variavel
			 	aItens  := {}
			 	
				aCab	:= { {'DDATALANC'	,_dDtBase	,NIL},;
						     {'CLOTE'		,'008850'	,NIL},;
						     {'CSUBLOTE' 	,'001'		,NIL},;
						     {'CDOC' 		, STRZERO(seconds(),6)	,NIL},;
						     {'CPADRAO' 	,''			,NIL},;
						     {'NTOTINF' 	,0			,NIL},;
						     {'NTOTINFLOT'	,0			,NIL} }
				
				_cMsg := "JUROS REF. "+Substr(DtoS(_dDtBase),5,2)+"/"+substr(DtoS(_dDtBase),1,4)+" CONTR. "+_cNumCtr
				
				// Adiciona dados no array
				aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial	, NIL},;
							  {'CT2_LINHA' 		,'001'		, NIL},;
							  {'CT2_MOEDLC' 	,'01' 		, NIL},; 
							  {'CT2_DC' 		,'3' 		, NIL},;
							  {'CT2_DEBITO' 	,_cCntJur 	, NIL},;
							  {'CT2_CREDIT' 	,_cCntCrt 	, NIL},;
							  {'CT2_CCD'	 	,"1098" 	, NIL},;
							  {'CT2_VALOR' 		,_vValJur	, NIL},;
							  {'CT2_ORIGEM' 	,'XAG0022'	, NIL},;
							  {'CT2_HP' 		,''			, NIL},;
							  {'CT2_CONVER'		,'15555'	, NIL},;
							  {'CT2_HIST' 		,Substr(_cMsg,1,40), NIL} } )
		
				// Complemento de historico
				aAdd(aItens,{ {'CT2_FILIAL'		,_cFilial 	, NIL},;
							  {'CT2_LINHA'		,'002' 		, NIL},;
							  {'CT2_DC'			,'4' 		, NIL},;
							  {'CT2_HIST'		,Substr(_cMsg,41,80), NIL} } )
							  
			    lMsErroAuto := .F.
				MSExecAuto({|x,y,z|CTBA102(x,y,z)},aCab,aItens,3)
				If lMsErroAuto
					conout('Erro na inclusao!')
					MostraErro()
				EndIf
			EndIf
	
		EndIf
	
	EndIf

Return