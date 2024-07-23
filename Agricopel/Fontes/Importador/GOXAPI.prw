#INCLUDE "PROTHEUS.CH"

#DEFINE GOLOG_DISABLED "1"
#DEFINE GOLOG_INFO "2"
#DEFINE GOLOG_DEBUG "3"
#DEFINE GOLOG_CONSOLE "4"

User Function GOXAddXM(cIdNfe, cCodRetNfe)
    
    Local nTamSer  := TamSX3("F2_SERIE")[1]
    Local cSerie   := Left(cIdNfe, nTamSer)
    Local cNota    := SubStr(cIdNfe, nTamSer + 1)
    
    Local aAreaSF2 := SF2->( GetArea() )
    
    dbSelectArea("SF2")
    SF2->( dbSetOrder(1) )
    If SF2->( dbSeek(xFilial('SF2') + cNota + cSerie ) )
        
        If VerTrf()
            
            If AllTrim(cCodRetNfe) == '100'// Buscar XML e adicionar no Importador
                
                TransfXML(cIdNfe)
                
            EndIf
    
        EndIf
        
    EndIf
    
    RestArea(aAreaSF2)
    
Return

/* Funcao para verificar se nota de transferencia */
Static Function VerTrf()

	Local _aArea	:= GetArea()
	Local _lRet 	:= .F.
	
	//Posiciona no cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
	
	//Posiciona no item da NF
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial("SF2")+SF2->(F2_DOC + F2_SERIE)))
	While SD2->(!EoF()) .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE) == xFilial("SF2")+SF2->(F2_DOC + F2_SERIE)
	
		//Caso a RAIZ do CNPJ da filial atual seja igual ao CNPJ do cliente
		If Left(SA1->A1_CGC, 8) == Left(SM0->M0_CGC, 8)
            
            _lRet := .T.
        
            Exit
		
		EndIf		
	
		SD2->(DbSkip())
	
	EndDo
	
	RestArea(_aArea)

Return(_lRet)

Static Function TransfXML(cIdNfe)
    
    Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cNFes    := ""
	Local aDeleta  := {}
	Local cMsg     := ""
	Local cUrlAux  := cURL
    
    Local cError   := ""
    
    Local cIdEnt   := getCfgEntidade(@cError) //StaticCall(SPEDNFE, GetIdEnt)
    Local cCGCCli
    Local cXML     := ""
    Local cChvCan  := ""
    Local cChvInu  := ""
    
    Local nX
    
    Private oRetorno
    
    cURL := AllTrim(cURL) + "/NFeSBRA.apw"
    
    If !CTIsReady(cURL)
        
        Return
        
    EndIf
    
    If !CTIsReady(cUrlAux)
        
        Return
        
    EndIf
    
    dbSelectArea("SA1")
    SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA) )
    
    cCGCCli := SA1->A1_CGC
    
    oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt 
	oWS:_URL              := cURL
	oWS:cIdInicial        := cIdNfe
	oWS:cIdFinal          := cIdNfe
	oWS:nDiasparaExclusao := 0
    
	If oWS:RETORNAFAIXA()
        
        oRetorno := oWS:oWsRetornaFaixaResult
        
        For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)
            
	 		oXml := oRetorno:OWSNOTAS:OWSNFES3[nX]
			oXmlExp   := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
			
	 		If !Empty(oXml:oWSNFe:cProtocolo) .and. Empty(oXml:OWSNFECANCELADA)
                
		    	cNotaIni := oXml:cID	 		
				cIdflush := cNotaIni
                
		 		cNFes := cNFes+cNotaIni+CRLF
	
	 			cChvNFe  := GENNfeId(oXml:oWSNFe:cXML,"Id")
                 
				cModelo := cChvNFe
				cModelo := StrTran(cModelo,"NFe","")
				cModelo := StrTran(cModelo,"CTe","")
				cModelo := SubStr(cModelo, 21, 02)
				
				Do Case
					Case cModelo == "57"
						cPrefixo := "CTe"
					OtherWise
						cPrefixo := "NFe"
				EndCase
				
				cCab1 := '<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.10">'
				cRodap:= '</nfeProc>'
	 			
	 			cXml += AllTrim(cCab1)
	 			cXml += AllTrim(oXml:oWSNFe:cXML)
	 			cXml += AllTrim(oXml:oWSNFe:cXMLPROT)
	 			cXml += AllTrim(cRodap)
		 			
	 			aadd(aDeleta, oXml:cID)

		 	EndIf
            
		 	cChvCan  := ''
		 	cChvInu  := ''
             
		 	If _lTrf .and. oXml:OWSNFECANCELADA<>Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo)
                
		 		If !"INUT"$oXml:oWSNFeCancelada:cXML
		 		
			 		cChvCan  := GENNfeId(oXml:oWSNFeCancelada:cXML,"Id")
				 	//cNameFile :=  "Sensus_" + cChvCan + "-proc-can.xml"

			 		cXml += AllTrim(oXml:oWSNFeCancelada:cXML)
			 		cXml += AllTrim(oXml:oWSNFeCancelada:cXMLPROT)
				 	
				else

			 		cChvInu  := GENNfeId(oXml:oWSNFeCancelada:cXML,"Id")

				endif
                
			endif
						 
	    Next nX
        
        aDeleta  := {}
        
        If !Empty(cXml)
            
            __cFilBkp := cFilAnt
            _nRegM0	:= SM0->(recno())
            aFiliais := FWAllFilial(, , SM0->M0_CODIGO)
            
            For nI := 1 To Len(aFiliais)
            
                aFilial := FWArrFilAtu(SM0->M0_CODIGO, aFiliais[nI])
                
                if alltrim(cCGCCli) == AllTrim(aFilial[18])
                
                    cFilAnt := aFilial[02]
                    
                    SM0->(dbSeek(cEmpAnt + cFilAnt))
                            
                    Exit
                    
                endif 
                
            Next nI
        
            Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
            Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
            Private _cTab5 := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
            Private _cCmp5 := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
            Private _cTab6 := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
            Private _cCmp6 := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
            Private _cTab8 := Upper(AllTrim(GetNewPar("MV_ZGOTAB8", "")))  // 
            Private _cCmp8 := IIf(SubStr(_cTab8, 1, 1) == "S", SubStr(_cTab8, 2, 2), _cTab8)
            
            Private lUsaLib := GetNewPar("MV_ZGOLIBX", .F.) // Indica se utiliza processo de liberação do XML
            
            Private oGOLog    := GOLog():New("importador_servico", "Importador Servico", IIf(GetNewPar("MV_XGTLGS", .T.), GOLOG_CONSOLE, GOLOG_DISABLED)) // GOLOG_CONSOLE
            Private nTamNota   := GetNewPar("MV_XGTTMNF", 9)
            Private nTamCmpNF  := TamSX3("F1_DOC")[1]
            Private nTamCmpSer := TamSX3("F1_SERIE")[1]
            Private lXGTLSer   := GetNewPar("MV_XGTLSER", .F.) // Parâmetro para limpar série
            Private lSaveLog   := .F.
            Private lVlErrMsg  := .F.
            Private cEspNFe    := PadR(GetNewPar("MV_XGTNFES", ""), TamSX3("F1_ESPECIE")[1])
            Private cEspNFSe   := PadR(GetNewPar("MV_XGTNFCE", "NFS"), TamSX3("F1_ESPECIE")[1])
            Private cEspNFCe   := PadR(GetNewPar("MV_XGTNFCE", "NFCE"), TamSX3("F1_ESPECIE")[1])
            Private cEspCTe    := PadR(GetNewPar("MV_XGTCTES", ""), TamSX3("F1_ESPECIE")[1])
            Private cEspCTeOS  := PadR(GetNewPar("MV_XGTCTOS", "CTEOS"), TamSX3("F1_ESPECIE")[1])
            
            Private cRetBxXML := ""
            
            If empty(cChvCan) .and. empty(cChvInu) 
            
                U_GoCargaX(,, cXml)
                
            ElseIf !empty(cChvCan) .and. empty(cChvInu) .and. !empty(cXml)
            
                (_cTab1)->(dbSetOrder(1))
                If (_cTab1)->(dbSeek(substr(cChvCan, 3, 44)))

                    cXml := (_cTab1)->&(_cCmp1 + "_XML")
                    U_GoCargaX(.T.,, cXml)

                EndIf
                
            EndIf
            
            cFilAnt := __cFilBkp 
            
            SM0->(dbGoto(_nRegM0))
            
        EndIf
        
    EndIf
    
Return

Static Function GENNfeId(cXML, cAttId)

    Local nAt   := 0
    Local cURI  := ""
    Local nSoma := Len(cAttId) + 2

    nAt  := At(cAttId+'=', cXml)
    cURI := SubStr(cXml, nAt + nSoma)
    nAt  := At('"', cURI)
    
    If nAt == 0
        
        nAt := At("'", cURI)
        
    EndIf
    
    cURI := SubStr(cURI, 1, nAt - 1)
    
Return cUri
