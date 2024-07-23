#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"

// Função responsável para ser chamada no P.E. MT100TOK.
// Irá mostrar a comparação dos impostos, e poderá barrar ou não caso haja diferença.

User Function GOXIMP()
    
    Local aImpXML := {}
    Local aImpNf  := {}
    Local nIt
    Local nI
    Local nX
    
    Local lRet := .F.
    Local cMsg := ""
    
    Local aImpVal := {;
        {"ICM", "ICMS", .T.}, ;
        {"IPI", "IPI", .T.}, ;
        {"ICR", "ICMS Retido", .F.} ;
    }
    
    Local aXmlImp := GetXmlImp()
    Local aSisImp := GetSisImp()
    
    Local nPosImp
    
    Local nPosB
    Local nPosA
    Local nPosV
    
    Private oLayerImp
    Private oDlgImp
    
    Private aImpFis := MaFisNFCab()
    Private aImp := {}
    
    If AllTrim(cEspecie) != "SPED"
        
        Return .T.
        
    EndIf
    
    If GetNewPar("MV_ZIMPVPC", .F.)
        
        AAdd(aImpVal, {"PS2", "PIS Apuração", .T.})
        AAdd(aImpVal, {"CF2", "COFINS Apuração", .T.})
        
    EndIf
    
    For nX := 1 To Len(aXmlImp)
        
        nPosImp := AScan(aImpVal, {|x| x[1] == aXmlImp[nX][1]})
        
        If nPosImp > 0
            
            AAdd(aImp, {;
                '', ; // Código
                aImpVal[nPosImp][2], ; // Descrição
                '', ; // Informado
                '', ; // No XML
                '', ; // Calc Sistema
                '', ; // Status
                '' ; // Chave
            })
            
            AAdd(aImp, {;
                aImpVal[nPosImp][1], ; // Código
                'Base', ;// Descrição
                0, ;//Transform(0, "@E 999,999,999.99"), ;// Informado
                aXmlImp[nX][2], ;//Transform(aXmlImp[nX][2], "@E 999,999,999.99"), ;// No XML
                0, ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                'Diferença', ; // Status
                aImpVal[nPosImp][1] + cValToChar(aXmlImp[nX][3]) + "B" ; // Chave
            })
            
            AAdd(aImp, {;
                aImpVal[nPosImp][1], ; // Código
                'Alíquota', ;// Descrição
                0, ;//Transform(0, "@E 999,999,999.99"), ;// Informado
                aXmlImp[nX][3], ;//Transform(aXmlImp[nX][3], "@E 999,999,999.99"), ;// No XML
                0, ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                'Diferença', ; // Status
                aImpVal[nPosImp][1] + cValToChar(aXmlImp[nX][3]) + "A" ; // Chave
            })
            
            AAdd(aImp, {;
                aImpVal[nPosImp][1], ; // Código
                'Valor', ;// Descrição
                0, ;//Transform(0, "@E 999,999,999.99"), ;// Informado
                aXmlImp[nX][4], ;//Transform(aXmlImp[nX][4], "@E 999,999,999.99"), ;// No XML
                0, ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                'Diferença', ; // Status
                aImpVal[nPosImp][1] + cValToChar(aXmlImp[nX][3]) + "V" ; // Chave
            })
            
            AAdd(aImp, {;
                '', ; // Código
                '--', ;// Descrição
                '--', ;// Informado
                '--', ;// No XML
                '--', ;// Calc Sistema
                '--', ; // Status
                '' ; // Chave
            })
            
        EndIf
        
    Next nX
        
    For nI := 1 To Len(aImpFis)
        
        If (nPosA := AScan(aImp, {|x| x[7] == aImpFis[nI][1] + cValToChar(aImpFis[nI][4]) + "A"})) > 0
            
            nPosB := AScan(aImp, {|x| x[7] == aImpFis[nI][1] + cValToChar(aImpFis[nI][4]) + "B"})
            nPosV := AScan(aImp, {|x| x[7] == aImpFis[nI][1] + cValToChar(aImpFis[nI][4]) + "V"})
            
            aImp[nPosB][3] += aImpFis[nI][3]
            aImp[nPosA][3] += aImpFis[nI][4]
            aImp[nPosV][3] += aImpFis[nI][5]
            
        Else 
            
            nPosImp := AScan(aImpVal, {|x| x[1] == aImpFis[nI][1]})
            
            If nPosImp > 0
            
                AAdd(aImp, {;
                    '', ; // Código
                    aImpVal[nPosImp][2], ; // Descrição
                    '', ; // Informado
                    '', ; // No XML
                    '', ; // Calc Sistema
                    '', ; // Status
                    '' ; // Chave
                })
                
                AAdd(aImp, {;
                    aImpVal[nPosImp][1], ; // Código
                    'Base', ;// Descrição
                    aImpFis[nI][3], ;//Transform(aImpFis[nI][3], "@E 999,999,999.99"), ;// Informado
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// No XML
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                    'Diferença', ; // Status
                    aImpVal[nPosImp][1] + cValToChar(aImpFis[nI][4]) + "B" ; // Chave
                })
                
                AAdd(aImp, {;
                    aImpVal[nPosImp][1], ; // Código
                    'Alíquota', ;// Descrição
                    aImpFis[nI][4], ;////Transform(aImpFis[nI][4], "@E 999,999,999.99"), ;// Informado
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// No XML
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                    'Diferença', ; // Status
                    aImpVal[nPosImp][1] + cValToChar(aImpFis[nI][4]) + "A" ; // Chave
                })
                
                AAdd(aImp, {;
                    aImpVal[nPosImp][1], ; // Código
                    'Valor', ;// Descrição
                    aImpFis[nI][5], ;//Transform(aImpFis[nI][5], "@E 999,999,999.99"), ;// Informado
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// No XML
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                    'Diferença', ; // Status
                    aImpVal[nPosImp][1] + cValToChar(aImpFis[nI][4]) + "V" ; // Chave
                })
                
                AAdd(aImp, {;
                    '', ; // Código
                    '--', ;// Descrição
                    '--', ;// Informado
                    '--', ;// No XML
                    '--', ;// Calc Sistema
                    '--', ; // Status
                    '' ; // Chave
                })
                
            EndIf
            
        EndIf
        
    Next nI
    
    For nI := 1 To Len(aSisImp)
        
        If (nPosA := AScan(aImp, {|x| x[7] == aSisImp[nI][1] + cValToChar(aSisImp[nI][4]) + "A"})) > 0
            
            nPosB := AScan(aImp, {|x| x[7] == aSisImp[nI][1] + cValToChar(aSisImp[nI][4]) + "B"})
            nPosV := AScan(aImp, {|x| x[7] == aSisImp[nI][1] + cValToChar(aSisImp[nI][4]) + "V"})
            
            aImp[nPosB][5] += aSisImp[nI][3]
            aImp[nPosA][5] += aSisImp[nI][4]
            aImp[nPosV][5] += aSisImp[nI][5]
            
        Else 
            
            nPosImp := AScan(aImpVal, {|x| x[1] == aSisImp[nI][1]})
            
            If nPosImp > 0
            
                AAdd(aImp, {;
                    '', ; // Código
                    aImpVal[nPosImp][2], ; // Descrição
                    '', ; // Informado
                    '', ; // No XML
                    '', ; // Calc Sistema
                    '', ; // Status
                    '' ; // Chave
                })
                
                AAdd(aImp, {;
                    aImpVal[nPosImp][1], ; // Código
                    'Base', ;// Descrição
                    0, ;//Transform(aSisImp[nI][3], "@E 999,999,999.99"), ;// Informado
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// No XML
                    aSisImp[nI][3], ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                    'Diferença', ; // Status
                    aImpVal[nPosImp][1] + cValToChar(aSisImp[nI][4]) + "B" ; // Chave
                })
                
                AAdd(aImp, {;
                    aImpVal[nPosImp][1], ; // Código
                    'Alíquota', ;// Descrição
                    0, ;////Transform(aSisImp[nI][4], "@E 999,999,999.99"), ;// Informado
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// No XML
                    aSisImp[nI][4], ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                    'Diferença', ; // Status
                    aImpVal[nPosImp][1] + cValToChar(aSisImp[nI][4]) + "A" ; // Chave
                })
                
                AAdd(aImp, {;
                    aImpVal[nPosImp][1], ; // Código
                    'Valor', ;// Descrição
                    0, ;//Transform(aSisImp[nI][5], "@E 999,999,999.99"), ;// Informado
                    0, ;//Transform(0, "@E 999,999,999.99"), ;// No XML
                    aSisImp[nI][5], ;//Transform(0, "@E 999,999,999.99"), ;// Calc Sistema
                    'Diferença', ; // Status
                    aImpVal[nPosImp][1] + cValToChar(aSisImp[nI][4]) + "V" ; // Chave
                })
                
                AAdd(aImp, {;
                    '', ; // Código
                    '--', ;// Descrição
                    '--', ;// Informado
                    '--', ;// No XML
                    '--', ;// Calc Sistema
                    '--', ; // Status
                    '' ; // Chave
                })
                
            EndIf
            
        EndIf
        
    Next nI
    
    // Verificar as Diferenças
    
    For nI := 1 To Len(aImp)
        
        If !Empty(aImp[nI][1])
        
            If aImp[nI][3] == aImp[nI][4] .And. aImp[nI][3] == aImp[nI][5]
                
                aImp[nI][6] := "Ok"
                
            EndIf
            
        EndIf
        
    Next nI
    
    If Len(aImp) > 0 //.And. !IsBlind()
        
        // Abrir a tela e mostrar os Impostos
        DEFINE MSDIALOG oDlgImp FROM aSize[7], 0 TO aSize[6]/1.5, aSize[5]/1.5 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
            oLayerImp := FWLayer():New()
            oLayerImp:Init(oDlgImp, .F.)
                
                oLayerImp:AddLine('LIN1', 90, .F.)
                    
                    oLayerImp:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
                        
                        oLayerImp:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Validação de Impostos", 100, .F., .T., , 'LIN1',)
                            
                            oBrwImp := TCBrowse():New(50, 50, 200, 200,,,, oLayerImp:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'),,,,,,,,,,,, .T.,, .T.,)
                            oBrwImp:Align := CONTROL_ALIGN_ALLCLIENT
                            oBrwImp:nClrBackFocus := GetSysColor(13)
                            oBrwImp:nClrForeFocus := GetSysColor(14)
                            oBrwImp:SetArray(aImp)
                            
                            oBrwImp:SetBlkBackColor({|| IIf(Empty(aImp[oBrwImp:nAt, 1]), , IIf(aImp[oBrwImp:nAt, 6] == "Ok", RGB(0,255,0), RGB(255,0,0)))})
                            
                            //ADD COLUMN TO oBrwImp HEADER "Código" OEM DATA {|| aImp[oBrwImp:nAt, XML_ITEM]} ALIGN LEFT SIZE 90 PIXELS
                            
                            ADD COLUMN TO oBrwImp HEADER "Descrição" OEM DATA {|| aImp[oBrwImp:nAt, 2]} ALIGN LEFT SIZE 80 PIXELS
                            
                            ADD COLUMN TO oBrwImp HEADER "Informado Nota" OEM DATA {|| aImp[oBrwImp:nAt, 3]} ALIGN RIGHT /*PICTURE "@E 9,999,999.99"*/ SIZE 50 PIXELS
                            
                            ADD COLUMN TO oBrwImp HEADER "No XML" OEM DATA {|| aImp[oBrwImp:nAt, 4]} ALIGN RIGHT /*PICTURE "@E 9,999,999.99"*/ SIZE 50 PIXELS
                            
                            ADD COLUMN TO oBrwImp HEADER "Calc. Sistema" OEM DATA {|| aImp[oBrwImp:nAt, 5]} ALIGN RIGHT /*PICTURE "@E 9,999,999.99"*/ SIZE 50 PIXELS
                            
                            ADD COLUMN TO oBrwImp HEADER "Status" OEM DATA {|| aImp[oBrwImp:nAt, 6]} ALIGN LEFT SIZE 30 PIXELS
                            
                            //ADD COLUMN TO oBrwImp HEADER "Alíq. XML" OEM DATA {|| aImp[oBrwImp:nAt, 6]} ALIGN RIGHT PICTURE "@E 9,999,999.99" SIZE 30 PIXELS
                            
                            //ADD COLUMN TO oBrwImp HEADER "Valor Informado" OEM DATA {|| aImp[oBrwImp:nAt, 5]} ALIGN RIGHT PICTURE "@E 9,999,999.99" SIZE 30 PIXELS
                            
                            //ADD COLUMN TO oBrwImp HEADER "Valor XML" OEM DATA {|| aImp[oBrwImp:nAt, 6]} ALIGN RIGHT PICTURE "@E 9,999,999.99" SIZE 30 PIXELS
                            
                            //oBrwImp:bLDblClick := {|| MarcReg(1)}
                            
                            oBrwImp:GoTop()
                            
                oLayerImp:AddLine('LIN2', 10, .F.)
                    
                    oLayerImp:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
                        
                        oPanelBot := tPanel():New(0,0,"", oLayerImp:GetColPanel('COL1_LIN2', 'LIN2'),,,,,RGB(239,243,247),000,015)
					    oPanelBot:Align	:= CONTROL_ALIGN_BOTTOM
                        
                        oCanc := THButton():New(0, 0, "Continuar", oPanelBot, {|| lRet := .T., oDlgImp:End()}, , , )
                        oCanc:nWidth  := 100
                        oCanc:nHeight := 10
                        oCanc:Align := CONTROL_ALIGN_RIGHT
                        oCanc:SetColor(RGB(002, 070, 112), )
                        
                        oSair := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgImp:End()}, , , )
                        oSair:nWidth  := 100
                        oSair:nHeight := 10
                        oSair:Align := CONTROL_ALIGN_RIGHT
                        oSair:SetColor(RGB(002, 070, 112), )
                        
        ACTIVATE MSDIALOG oDlgImp CENTERED
        
    EndIf
    
    If lRet
        
        // Verificar se Tem algum bloqueio
        
        For nI := 1 To Len(aImp)
            
            If !Empty(aImp[nI][1])
        
            If aImp[nI][3] != aImp[nI][4] .Or. aImp[nI][3] != aImp[nI][5]
                
                nPosImp := AScan(aImpVal, {|x| x[1] == aImp[nI][1]})
                
                If aImpVal[nPosImp][3] // Deve Validar
                    
                    cMsg += "- " + aImp[nI][2] + " do Imposto " + aImpVal[nPosImp][2] + " possui divergência e não poderá ser importado com diferença." + CRLF + CRLF
                    lRet := .F.
                    
                EndIf
                
            EndIf
            
        EndIf
            
        Next nI
        
        If !lRet
            
            Help(,, "Diferença com Pedido de Compras",, "Diferenças encontradas nos Impostos" + CRLF + CRLF + cMsg, 1, 0)
            
        EndIf
        
    EndIf
    
Return lRet

Static Function GetXmlImp()
    
    Local nI
    Local aIcms
    Local nPos
    
    Local aXImp := {}
        /*{"ICM", 0, 0, 0}, ;
        {"IPI", 0, 0, 0}, ;
        {"ICR", 0, 0, 0}, ;
        {"PS2", 0, 0, 0}, ;
        {"CF2", 0, 0, 0} ;*/
    //}
    
    If Type("oXML") == "O"
        
        // Buscar em Todos os Itens os valores
        
        //U_GOXmlIcm //ICMS e ICMS ST
        
        For nI := 1 To Len(oXml:_NfeProc:_Nfe:_InfNfe:_det)
            
            aIcms := U_GOXmlIcm(oXml, nI)
            
            //======================= ICMS
            
            nPos := AScan(aXImp, {|x| x[1] == "ICM" .And. x[3] == aIcms[3]})
            
            If nPos > 0
                
                aXImp[nPos][2] += aIcms[2]
                aXImp[nPos][4] += aIcms[4]
                
            Else
                
                AAdd(aXImp, {"ICM", aIcms[2], aIcms[3], aIcms[4]})
                
            EndIf
            
            //======================= ICMS ST
            
            nPos := AScan(aXImp, {|x| x[1] == "ICR" .And. x[3] == aIcms[8]})
            
            If nPos > 0
                
                aXImp[nPos][2] += aIcms[7]
                aXImp[nPos][4] += aIcms[9]
                
            Else
                
                AAdd(aXImp, {"ICR", aIcms[7], aIcms[8], aIcms[9]})
                
            EndIf
            
            //======================= PIS
            
            If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nI) + "]:_Imposto:_PIS") == "O" .And. ;
                Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nI) + "]:_Imposto:_PIS:_PISAliq") == "O"
            
                nBasePIS := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_PIS:_PISAliq:_vBC:Text)
                nAliqPIS := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_PIS:_PISAliq:_pPIS:Text)
                nValPIS  := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_PIS:_PISAliq:_vPIS:Text)
                
                nPos := AScan(aXImp, {|x| x[1] == "PS2" .And. x[3] == nAliqPIS})
                
                If nPos > 0
                    
                    aXImp[nPos][2] += nBasePIS
                    aXImp[nPos][4] += nValPIS
                    
                Else
                    
                    AAdd(aXImp, {"PS2", nBasePIS, nAliqPIS, nValPIS})
                    
                EndIf
                
            EndIf
            
            //======================= COFINS
            
            If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nI) + "]:_Imposto:_COFINS") == "O" .And. ;
                Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nI) + "]:_Imposto:_COFINS:_COFINSAliq") == "O"
            
                nBaseCOFINS := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_COFINS:_COFINSAliq:_vBC:Text)
                nAliqCOFINS := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:Text)
                nValCOFINS  := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_COFINS:_COFINSAliq:_vCOFINS:Text)
                
                nPos := AScan(aXImp, {|x| x[1] == "CF2" .And. x[3] == nAliqCOFINS})
                
                If nPos > 0
                    
                    aXImp[nPos][2] += nBaseCOFINS
                    aXImp[nPos][4] += nValCOFINS
                    
                Else
                    
                    AAdd(aXImp, {"CF2", nBaseCOFINS, nAliqCOFINS, nValCOFINS})
                    
                EndIf
                
            EndIf
            
            //======================= IPI
            
            If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nI) + "]:_Imposto:_IPI") == "O" .And. ;
                Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nI) + "]:_Imposto:_IPI:_IPITrib") == "O" .And. ;
                Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nI) + "]:_Imposto:_IPI:_IPITrib:_vBC") == "O"
            
                nBaseIPI := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_IPI:_IPITrib:_vBC:Text)
                nAliqIPI := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_IPI:_IPITrib:_pIPI:Text)
                nValIPI  := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Imposto:_IPI:_IPITrib:_vIPI:Text)
                
                nPos := AScan(aXImp, {|x| x[1] == "IPI" .And. x[3] == nAliqIPI})
                
                If nPos > 0
                    
                    aXImp[nPos][2] += nBaseIPI
                    aXImp[nPos][4] += nValIPI
                    
                Else
                    
                    AAdd(aXImp, {"IPI", nBaseIPI, nAliqIPI, nValIPI})
                    
                EndIf
                
            EndIf
            
        Next nI
        
    EndIf
    
Return aXImp

// Função para chamar no MT100TOK para validar pedido x nota

User Function GOXIPED()

	Local nI
	Local lRet := .T.

	Local aAreaSC7 := SC7->( GetArea() )
	Local nPosPed  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_PEDIDO"})
	Local nPosItPC := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEMPC"})
	Local nPosItQt := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_QUANT"})

	Local nPosIt := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEM"})
    
	Local nPosCod := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_COD"})

	Local cMsgErr := ""
    
    Local nPerTol := GetNewPar("MV_ZTOLDPP", 1)

	dbSelectArea("SC7")
	SC7->( dbSetOrder(1) )

	For nI := 1 To Len(aCols)

		If !aTail(aCols[nI])

			If !Empty(aCols[nI][nPosPed]) .And. !Empty(aCols[nI][nPosItPC])

				If SC7->( dbSeek(xFilial("SC7") + aCols[nI][nPosPed] + aCols[nI][nPosItPC]) )

					nValItem := MaFisRet(nI, "IT_TOTAL") //+ MaFisRet(nI, "IT_VALSOL") + MaFisRet(nI, "IT_VALIPI")

					//nValItem += IT_VALICM
					//nValItem += IT_VALSOL
					//nValItem += IT_VALIPI
					//nValItem += IT_VALCF2
					//nValItem += IT_VALPS2
					
					If aCols[nI][nPosItQt] == SC7->C7_QUANT
						
						If Abs((SC7->C7_TOTAL - SC7->C7_VLDESC) - nValItem) > ((SC7->C7_TOTAL - SC7->C7_VLDESC) * nPerTol / 100) //GetNewPar("MV_ZTOLDFP", 0.01)
							
							//Help(,, "Diferença com Pedido de Compras",, "O total do item de número " + aCols[nI][nPosIt] + " está diferente do pedido de compras." + CRLF + "Total do Item: " + Transform(nValItem, "@E 999,999,999.99") + CRLF + "Total do Pedido: " + Transform(SC7->C7_TOTAL, "@E 999,999,999.99"), 1, 0)

							cMsgErr += "-> Item " + aCols[nI][nPosIt] + ", Produto (" + aCols[nI][nPosCod] + ") do Pedido (" + aCols[nI][nPosPed] + "/" + aCols[nI][nPosItPC] + ") - Total Nota: " + Transform(nValItem, "@E 999,999,999.99") + " x Total Pedido: " + Transform(SC7->C7_TOTAL, "@E 999,999,999.99") + " (Diferença: " + Transform(nValItem - (SC7->C7_TOTAL - SC7->C7_VLDESC), "@E 999,999,999.99") + ")" + CRLF + CRLF

							lRet := .F.

						EndIf
						
					Else 
						
						nPondVal := ((aCols[nI][nPosItQt] / SC7->C7_QUANT) * (SC7->C7_TOTAL - SC7->C7_VLDESC))
						
						If Abs(nPondVal - nValItem) > ((SC7->C7_TOTAL - SC7->C7_VLDESC) * nPerTol / 100) //GetNewPar("MV_ZTOLDFP", 0.01)

							cMsgErr += "-> Item " + aCols[nI][nPosIt] + ", Produto (" + aCols[nI][nPosCod] + ") do Pedido (" + aCols[nI][nPosPed] + "/" + aCols[nI][nPosItPC] + ") - Total Nota: " + Transform(nValItem, "@E 999,999,999.99") + " x Total Pedido PONDERADO: " + Transform(nPondVal, "@E 999,999,999.99") + " (Diferença: " + Transform(nValItem - nPondVal, "@E 999,999,999.99") + ")" + CRLF + CRLF
							
							lRet := .F.

						EndIf
						
					EndIf

				EndIf

			EndIf

		EndIf

	Next nI

	RestArea(aAreaSC7)

	If !Empty(cMsgErr)
		
		Help(,, "Diferença com Pedido de Compras",, "Diferenças encontradas entre Nota x Pedido de Compras" + CRLF + CRLF + cMsgErr, 1, 0)

	EndIf

Return lRet

// Função para chamar no MT140TOK para validar pedido x nota

User Function GOXIPNPX()

	Local nI
	Local lRet := .T.

	Local aAreaSC7 := SC7->( GetArea() )
	Local nPosPed  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_PEDIDO"})
	Local nPosItPC := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEMPC"})
	Local nPosItQt := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_QUANT"})
    Local nPosTot  := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_TOTAL"})

	Local nPosIt := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEM"})
	Local nPosCod := aScan(aHeader, {|x| Alltrim(x[2]) == "D1_COD"})

	Local cMsgErr := ""
    
    Local nPerTol := GetNewPar("MV_ZTOLDPP", 1)
    
    If IsInCallStack("U_GOX008") .And. Type("oXml") == "O" .And. !l140Auto
        
        dbSelectArea("SC7")
        SC7->( dbSetOrder(1) )

        For nI := 1 To Len(aCols)

            If !aTail(aCols[nI])

                If !Empty(aCols[nI][nPosPed]) .And. !Empty(aCols[nI][nPosItPC])

                    If SC7->( dbSeek(xFilial("SC7") + aCols[nI][nPosPed] + aCols[nI][nPosItPC]) )
                        
                        nValItem := aCols[nI][nPosTot]
                        
                        //nItem := Val(aCols[nI][nPosIt])
                        
                        //If nI <= Len(oXml:_nfeProc:_NFe:_infNFe:_det) .And. nItem > 0
                        
                            // Somar Valores do XML
                            /*If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_det[nItem]:_prod,"_VDESC")) <> "U"
                            
                                nDesconto := Val(oXml:_nfeProc:_NFe:_infNFe:_det[nItem]:_prod:_vDesc:Text)
                                
                            Else
                            
                                nDesconto := 0
                                
                            EndIf*/
                            
                            nDesconto := oGetD:aCols[nI][_nPosDescX]
                            
                            /*If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_det[nItem]:_prod,"_VFRETE")) <> "U"
                                
                                nValItFre := Val(oXml:_nfeProc:_NFe:_infNFe:_det[nItem]:_prod:_vFrete:Text)
                                
                            Else
                                
                                nValItFre := 0
                                
                            EndIf*/
                            
                            nValItFre := oGetD:aCols[nI][_nPosVlFrt]
                            
                            //aIcms := U_GOXmlIcm(oXml, nItem)
                            
                            nICMSSt := 0
                                
                            nICMSStA := 0
                            
                            If !ExistBlock("GOXSOMST") .Or. ExecBlock("GOXSOMST", .F., .F., {nI})
                                
                                nICMSSt := oGetD:aCols[nI][_nPosVlISt]
                                
                                nICMSStA := oGetD:aCols[nI][_nPosVlStA]
                                
                            EndIf
                            
                            // IPI =======================
                            
                            /*If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nItem) + "]:_Imposto:_IPI") == "O" .And. ;
                                Type("oXml:_NfeProc:_Nfe:_InfNfe:_det[" + cValToChar(nItem) + "]:_Imposto:_IPI:_IPITrib") == "O"
                            
                                nValIPI  := Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nItem]:_Imposto:_IPI:_IPITrib:_vIPI:Text)
                                
                            Else
                                
                                nValIPI := 0
                                
                            EndIf*/
                            
                            nValIPI := oGetD:aCols[nI][_nPosVlIpi]
                            
                            nValItem := nValItem - nDesconto + nICMSSt + nICMSStA + nValItFre + nValIPI
                            
                            //===========================================
                            
                            If aCols[nI][nPosItQt] == SC7->C7_QUANT
                                
                                If Abs((SC7->C7_TOTAL - SC7->C7_VLDESC) - nValItem) > ((SC7->C7_TOTAL - SC7->C7_VLDESC) * nPerTol / 100) //GetNewPar("MV_ZTOLDFP", 0.01)
                                    
                                    //Help(,, "Diferença com Pedido de Compras",, "O total do item de número " + aCols[nI][nPosIt] + " está diferente do pedido de compras." + CRLF + "Total do Item: " + Transform(nValItem, "@E 999,999,999.99") + CRLF + "Total do Pedido: " + Transform(SC7->C7_TOTAL, "@E 999,999,999.99"), 1, 0)

                                    cMsgErr += "-> Item " + aCols[nI][nPosIt] + ", Produto (" + aCols[nI][nPosCod] + ") do Pedido (" + aCols[nI][nPosPed] + "/" + aCols[nI][nPosItPC] + ") - Total Nota: " + Transform(nValItem, "@E 999,999,999.99") + " x Total Pedido: " + Transform(SC7->C7_TOTAL, "@E 999,999,999.99") + " (Diferença: " + Transform(nValItem - (SC7->C7_TOTAL - SC7->C7_VLDESC), "@E 999,999,999.99") + ")" + CRLF + CRLF

                                    lRet := .F.

                                EndIf
                                
                            Else 
                                
                                nPondVal := ((aCols[nI][nPosItQt] / SC7->C7_QUANT) * (SC7->C7_TOTAL - SC7->C7_VLDESC))
                                
                                If Abs(nPondVal - nValItem) > ((SC7->C7_TOTAL - SC7->C7_VLDESC) * nPerTol / 100) //GetNewPar("MV_ZTOLDFP", 0.01)

                                    cMsgErr += "-> Item " + aCols[nI][nPosIt] + ", Produto (" + aCols[nI][nPosCod] + ") do Pedido (" + aCols[nI][nPosPed] + "/" + aCols[nI][nPosItPC] + ") - Total Nota: " + Transform(nValItem, "@E 999,999,999.99") + " x Total Pedido PONDERADO: " + Transform(nPondVal, "@E 999,999,999.99") + " (Diferença: " + Transform(nValItem - nPondVal, "@E 999,999,999.99") + ")" + CRLF + CRLF
                                    
                                    lRet := .F.

                                EndIf
                                
                            EndIf
                            
                            //========================================
                            
                        //EndIf

                    EndIf

                EndIf

            EndIf

        Next nI

        RestArea(aAreaSC7)

        If !Empty(cMsgErr)
            
            Help(,, "Diferença com Pedido de Compras",, "Diferenças encontradas entre Nota x Pedido de Compras" + CRLF + CRLF + cMsgErr, 1, 0)

        EndIf
        
    EndIf
    
Return lRet

Static Function GetSisImp()
    
    Local nI
    //Local aSImp := {}
    Local aRet := {}
    
    MaFisSave()
    
    For nI := 1 To Len(aCols)

		If !aTail(aCols[nI])
            
            MaFisRecal(,nI)
            
        EndIf
        
    Next nI
    
    aRet := MaFisNFCab()
    
    MaFisRestore()
    
Return aRet
