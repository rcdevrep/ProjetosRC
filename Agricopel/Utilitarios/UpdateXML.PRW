#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "RWMAKE.CH"


/*/{Protheus.doc} UPDXML
//Função Generica para Leitura de Xml e gravação de campos específicos realtivos a ST
@author Leandro Spiller
@since 04/08/2020
@version 1
@param 
@type function
/*/

User Function UPDXML()

    Local cStrXml    := ""
    Local cChave     := ""
    //Local cTagsItem  := ""
    //Local cTagsCab   := ""
    Local aXMLS      := {}
    Local i          := 0 
    Local nI         := 0 
    Local _oXml     
    Local oItem     
    Local cRegistros  := ""
    Local cCabecalho  := ""
    Local cPulaLinha  := chr(13) + chr(10)
    Local nBaseICST   := 0 
	Local nPerICMST   := 0 
	Local nValICMST   := 0
    Local cArquivo    := ""
	Local cAtualizou := ""

    Private cDiretorio := ""
	Private cAliasQry  := "UPDXML"
	Private oDlg
	Private Confirma
	//Private oCheckRel
	//Private lCheckRel := .F.
	//Private oCheckSD1
	//Private lCheckSD1 := .F.	
	Private lconfirm  := .F.
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private cOperacao := "SIMULAÇÃO"
	Private lAchouIt  := .F.

  	DEFINE MSDIALOG oDlg TITLE "XML x Protheus" FROM 000, 000  TO 120, 200 COLORS 0, 16777215 PIXEL

		//@ 011, 005 CHECKBOX oCheckRel VAR lCheckRel PROMPT "Gerar Relatorio" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL
		//@ 021, 005 CHECKBOX oCheckSD1 VAR lCheckSD1 PROMPT "Atualizar Registros" SIZE 063, 008 OF oDlg COLORS 0, 16777215 PIXEL
        @ 009, 006 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Simulação","Atualizar dados" SIZE 063, 019 OF oDlg COLOR 0, 16777215 PIXEL

		@ 039, 054 BUTTON Confirma PROMPT "Confirma" ;
			Action( lconfirm := .T., iif(lconfirm, odlg:end(),));
			SIZE 037, 012 OF oDlg PIXEL

  	ACTIVATE MSDIALOG oDlg

	if !lconfirm
		Return
	Endif

	if nRadMenu1 == 2
		cOperacao := "ATUALIZAR DADOS"

		If !MsgNoYes("Deseja realmente atualizar os dados ta tabela SD1 com os dados contidos no XML? ",cOperacao)
			Return
		Endif
	Endif

    cDiretorio := "/XMLST/"
    aXMLS := Directory(cDiretorio+'*.*'/*, "D"*/)

	cCabecalho := 	  "XML Chave; "+; 
                      "XML Prod.Forn; "+;
                      "XML Descri forn;"+;
                      "XML Quantidade;"+; 
                      "XML Valor Tot;"+; 
                      "XML Valor Unit;"+; 
                      "XML Base ST;"+;
                      "XML Aliquota ST;"+;
                      "XML Valor ST;"+;
					  "PRT Valor ST;"+;
					  "PRT Aliquota ST;"+;
					  "PRT Base ST;"+;
					  "Doc.;"+;
					  "Serie;"+;
					  "Item;"+;
					  "Produto;"+;
					  "R_E_C_N_O_;"+;
					   cOperacao+";"+;
					  "ATUALIZAÇÃO;"+;			  
                      cPulaLinha
		

	//Varre pastas com XML 
    For i := 1 to len(aXMLS) 

        cArquivo := aXMLS[i][1]

        //Lê xml e Cria NODE
        _oXml := LerXml(cDiretorio+cArquivo)
    

        cChave := _oXml:_Nfeproc:_protnfe:_infProt:_chNFe:Text
            
        //Transforma itens em Array
        XmlNode2Arr(_oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
		
        
        For nI := 1 To Len(_oXml:_NfeProc:_Nfe:_InfNfe:_det)

           oItem := _oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]
    
           cProdForn     := oItem:_prod:_cProd:Text
           cDescProdF    := oItem:_prod:_xProd:Text
           nQuantidade   := Val(oItem:_prod:_qCom:Text)
           nValorTotal   := Val(oItem:_prod:_vProd:Text)
           nValorUnit    := Val(oItem:_prod:_vUnCom:Text)

           If ValType(oItem:_imposto:_ICMS) == "O" 
                
                SAVE oItem:_imposto:_ICMS XMLSTRING cStrXml
	
                If At("<ICMS00>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
				EndIf
				If At("<ICMS10>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
				EndIf
				If At("<ICMS20>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
				EndIf
				If At("<ICMS30>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nPRedBCST  := Val(Substr(cStrXml, At("<pRedBCST>", cStrXml) + 10, At("</pRedBCST>", cStrXml) - (At("<pRedBCST>", cStrXml) + 10) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
				EndIf
				If (At("<ICMS40>", cStrXml) > 0).or. (At("<ICMS41>", cStrXml) > 0).or.(At("<ICMS50>", cStrXml) > 0)
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
				EndIf
				If At("<ICMS51>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nvICMSOp := Val(Substr(cStrXml, At("<vICMSOp>", cStrXml) + 9, At("</vICMSOp>", cStrXml) - (At("<vICMSOp>", cStrXml) + 9)))
						npDif := Val(Substr(cStrXml, At("<pDif>", cStrXml) + 6, At("</pDif>", cStrXml) - (At("<pDif>", cStrXml) + 6) ))
						nvICMSDif := Val(Substr(cStrXml, At("<vICMSDif>", cStrXml) + 10, At("</vICMSDif>", cStrXml) - (At("<vICMSDif>", cStrXml) + 10)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
				EndIf
				If At("<ICMS60>", cStrXml) > 0  .or. At("<ICMSST>", cStrXml) > 0  //Nova TAG
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
					
						nvBCSTRet := Val(Substr(cStrXml, At("<vBCSTDest>", cStrXml) + 11, At("</vBCSTDest>", cStrXml) - (At("<vBCSTDest>", cStrXml) + 11) ))
						nvICMSSTRet := Val(Substr(cStrXml, At("<vICMSSTDest>", cStrXml) + 13, At("</vICMSSTDest>", cStrXml) - (At("<vICMSSTDest>", cStrXml) + 13)))						
						
						//Se não Tiver St destino pebga o normal
						If nvBCSTRet == 0 .or. nvICMSSTRet == 0 
							nvBCSTRet := Val(Substr(cStrXml, At("<vBCSTRet>", cStrXml) + 10, At("</vBCSTRet>", cStrXml) - (At("<vBCSTRet>", cStrXml) + 10) ))
							nvICMSSTRet := Val(Substr(cStrXml, At("<vICMSSTRet>", cStrXml) + 12, At("</vICMSSTRet>", cStrXml) - (At("<vICMSSTRet>", cStrXml) + 12)))
						Endif 
						
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						//Spiller - Chamado 57063 
						If nvICMSSTRet <> 0 
							nBaseICST := nvBCSTRet
							nValICMST := nvICMSSTRet
							nPerICMST := Val(Substr(cStrXml, At("<pST>", cStrXml) + 5, At("</pST>", cStrXml) - (At("<pST>", cStrXml) + 5) )) 
							If nPerICMST == 0 .AND. nBaseICST > 0 
								nPerICMST := Round( (nValICMST / nBaseICST) *100 ,0)
							Endif	
						Else
							nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
							nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
							nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))  
							If nPerICMST == 0 .AND. nBaseICST > 0 
								nPerICMST := Round( (nValICMST / nBaseICST) *100 ,0)
							Endif	 
						Endif
				EndIf

				If At("<ICMS70>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nPRedBCST  := Val(Substr(cStrXml, At("<pRedBCST>", cStrXml) + 10, At("</pRedBCST>", cStrXml) - (At("<pRedBCST>", cStrXml) + 10) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
				EndIf

				If At("<ICMS90>", cStrXml) > 0
						cStTrib  := Substr(cStrXml, At("<orig>", cStrXml) + 6, 1) + Substr(cStrXml, At("<CST>", cStrXml) + 5, 2)
						nPRedBC  := Val(Substr(cStrXml, At("<pRedBC>", cStrXml) + 8, At("</pRedBC>", cStrXml) - (At("<pRedBC>", cStrXml) + 8) ))
						nBaseICM := Val(Substr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5) ))
						nPerICM  := Val(Substr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(Substr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						nPmVast  := Val(Substr(cStrXml, At("<pMVAST>", cStrXml) + 8, At("</pMVAST>", cStrXml) - (At("<pMVAST>", cStrXml) + 8) ))
						nPRedBCST  := Val(Substr(cStrXml, At("<pRedBCST>", cStrXml) + 10, At("</pRedBCST>", cStrXml) - (At("<pRedBCST>", cStrXml) + 10) ))
						nBaseICST := Val(Substr(cStrXml, At("<vBCST>", cStrXml) + 7, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 7) ))
						nPerICMST := Val(Substr(cStrXml, At("<pICMSST>", cStrXml) + 9, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 9)))
						nValICMST := Val(Substr(cStrXml, At("<vICMSST>", cStrXml) + 9, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 9)))
						nvICMSDeson := Val(Substr(cStrXml, At("<vICMSDeson>", cStrXml) + 12, At("</vICMSDeson>", cStrXml) - (At("<vICMSDeson>", cStrXml) + 12)))
				EndIf

           Endif 

			//Grava Registros do XML
		    cRegistros += "'"+cChave +"';"    +;  
                         cProdForn +";"  +;  
                         cDescProdF+";"  +;   
                         Alltrim(Str(nQuantidade))+";" +;  
                         Alltrim(Str(nValorTotal))+";" +;  
                         Alltrim(Str(nValorUnit)) +";" +; 
                         Alltrim(Str(nBaseICST))  +";" +; 
                         Alltrim(Str(nPerICMST))  +";" +; 
                         Alltrim(Str(nValICMST))  +";" ;
			
		    //Grava Registros da SD1

			MsgRun(cChave,"",{|| lAchouIt := BuscaItem(cChave,cProdForn,nValorTotal,nValorUnit,nQuantidade) })
			If lAchouIt//BuscaItem(cChave,cProdForn,nValorTotal,nValorUnit,nQuantidade)	

				cAtualizou := ""
				If (cAliasQry)->D1_ICMNDES <> nValICMST .and. nValICMST > 0 
					cAtualizou += "VALOR ST "
				Endif
				If (cAliasQry)->D1_ALQNDES <> nPerICMST .and. nPerICMST > 0 
					cAtualizou += "ALIQUOTA ST "
				Endif
				If (cAliasQry)->D1_BASNDES <> nBaseICST .and. nBaseICST > 0 
					cAtualizou += "BASE  ST"
				Endif 

				//Atualiza Registro na SD1
				If nRadMenu1 == 2
					
					cAtualizou := " -  "+cAtualizou
					DbSelectarea('SD1')
					DbSetorder(1)
					DbGoto((cAliasQry)->RECNO)
 
					Reclock('SD1',.F.)
						If (cAliasQry)->D1_ICMNDES <> nValICMST .and. nValICMST > 0 
							SD1->D1_ICMNDES := nValICMST
						Endif
						If (cAliasQry)->D1_ALQNDES <> nPerICMST .and. nPerICMST > 0 
							SD1->D1_ALQNDES := nPerICMST
						Endif
						If (cAliasQry)->D1_BASNDES <> nBaseICST .and. nBaseICST > 0 
							SD1->D1_BASNDES := nBaseICST
						Endif 

				
					SD1->(MsUnlock())

					DbselectArea('SF1')
					DbSetOrder(1)
					DbGOTO((cAliasQry)->F1RECNO)

					//Reprocessa Nota
					ReprocSF1(SF1->F1_EMISSAO, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_FILIAL)
				Endif 

				//Se Não atualizou nada, grava 
				If Alltrim(cAtualizou) == ""
					cAtualizou := "SEM DIVERGENCIAS"
				Endif 

				cRegistros += Alltrim(Str((cAliasQry)->D1_ICMNDES))+";"  +; 
								  Alltrim(Str((cAliasQry)->D1_ALQNDES))+";"  +; 
								  Alltrim(Str((cAliasQry)->D1_BASNDES))+";"  +; 
								  (cAliasQry)->D1_DOC+";"  +; 
							  	  (cAliasQry)->D1_SERIE+";"  +; 
							  	  (cAliasQry)->D1_ITEM+";"  +; 
							  	  (cAliasQry)->D1_COD+";"  +; 
							  	  Alltrim(Str((cAliasQry)->RECNO))+";"  +; 
								  cOperacao+";"+;
								  cAtualizou +";"
				   
				
			Else
				
				cRegistros += "0;0;0;NÃO ENCONTRADO;"
				
			Endif

			//Fecha Arquivo de trabalho
			If Select(cAliasQry) > 0
				(cAliasQry)->( dbCloseArea() )
			EndIf

           	cRegistros += cPulaLinha
        
		Next nI
        
    Next i

	cArquivo := StrTran( time(), ":", "_" )+"_AJUSTE_ST_RETROATIVO.csv"

	//Conout(cCabecalho+cRegistros)
	MemoWrite( cArquivo, cCabecalho+cRegistros ) 

	If !ApOleClient("MsExcel")                     	
		MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
		Return	
	Endif
	
	__CopyFIle(cArquivo , AllTrim(GetTempPath())+cArquivo)             
		
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cArquivo)//cArqTrbex+".XLS")
	oExcelApp:SetVisible(.T.)                       
								
	fErase(cArquivo) //Deletando arquivo de trabalho	

Return


//lER xml e Criar NODE
Static Function LerXML(carqXML)

	Local oXml      := Nil
    Private cError    := ""
	Private  cWarning  := ""

	oXml := XmlParserFile(carqXML,"_", @cError, @cWarning)

    If ValType(oXml) != "O"
		Alert('ERRO ao Ler XML '+carqXML + " - " + cError)
		Return Nil 
	Endif

Return oXml

//Função para Buscar o Item no Protheus
Static Function BuscaItem(xChave,xProdForn,xValorTot,xValorUnit,xQuantidade)
	
	Local cQuery 	 := ""
	Local ntotal     := 0 
	//Local aRet       := {}
	Local lEncontrou := .F.
	//Local lTemSA5    := .F.

	cQuery += " SELECT D1_DOC,D1_SERIE,D1_ITEM,D1_COD,D1_BASNDES,D1_ICMNDES,D1_ALQNDES,A5_PRODUTO,A5_CODPRF,D1_TOTAL,D1_VUNIT,D1_QUANT,D1.R_E_C_N_O_ as RECNO,F1.R_E_C_N_O_ as F1RECNO FROM "+RetSqlName('SF1')+"(NOLOCK) F1"
	cQuery += " INNER JOIN "+RetSqlName('SD1')+"(NOLOCK) D1 ON D1_FILIAL = F1_FILIAL AND "
	cQuery += " F1_DOC = D1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE" 
	cQuery += " AND D1_LOJA = F1_LOJA AND D1.D_E_L_E_T_ = ''"
	cQuery += " LEFT JOIN "+RetSqlName('SA5')+"(NOLOCK) A5 ON A5_FORNECE = D1_FORNECE AND A5_LOJA = D1_LOJA AND A5.D_E_L_E_T_ = '' "
	cQuery += " AND A5_CODPRF = '"+alltrim(xProdForn)+"' "
	cQuery += " WHERE F1.D_E_L_E_T_ = '' AND "
	cQuery += " F1_CHVNFE = '"+xChave+"' "

	If Select(cAliasQry) <> 0
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasQry)

	Count To nTotal
    (cAliasQry)->(DbGoTop())

	//Se buscar só um registro nao valida Produto
	If ntotal == 1
		lEncontrou  := .T.
	Else
		//Varre itens 
		While (cAliasQry)->(!eof())
			
			//Verifica se encontrou na SA5
			/*If Valtype( (cAliasQry)->A5_PRODUTO ) == 'C'
				If ALLTRIM( (cAliasQry)->A5_PRODUTO ) <> ""		
					lTemSA5 := .T.
				Endif 
			Endif*/

			//Valida o Valor total 
			If xValorTot  == (cAliasQry)->D1_TOTAL .AND. NOROUND(xValorUnit,2) == NOROUND( (cAliasQry)->D1_VUNIT,2) .AND. xQuantidade == (cAliasQry)->D1_QUANT
				lEncontrou := .T.
			Endif 

			//Se encontrou Sai 
			If lEncontrou
				Exit
			Endif 

			(cAliasQry)->(DbSkip())
		Enddo

	Endif 


Return lEncontrou 



//Executa Rotina de Reprocessamento
Static Function ReprocSF1(dData, cNrDoc, cSerieDoc, cClieForn, cLojaCli, cNrFil)

	Local aPerg930  := {}
	Local nRegSM0   := 0
	Local aSegSM0   := SM0->(GetArea())
	Local lOutraFil := .F.         
	
	CONOUT('Reprocessando Nota '+cNrDoc+'-'+cSerieDoc+'/'+cClieForn+'-'+cLojaCli+'-'+cNrFil)

	If (AllTrim(cNrFil) <> AllTrim(cFilAnt))
		dbSelectArea("SM0")
		nRegSM0 := RecNo()
		cFilAnt := cNrFil

		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt,.T.)

		lOutraFil := .T.
	EndIf

	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, 1)

	aAdd(aPerg930, cNrDoc)
	aAdd(aPerg930, cNrDoc)

	aAdd(aPerg930, cSerieDoc)
	aAdd(aPerg930, cSerieDoc)

	aAdd(aPerg930, cClieForn)
	aAdd(aPerg930, cClieForn)

	aAdd(aPerg930, cLojaCli)
	aAdd(aPerg930, cLojaCli)

	MSExecAuto({|x,y|MATA930(x,y)}, .T., aPerg930) 

	If (lOutraFil)
		dbSelectArea("SM0")
		dbGoTo(nRegSM0)
		cFilAnt := SM0->M0_CODFIL
		RestArea(aSegSM0)
	EndIf
Return()       


//Função para Ajuste em notas de 
User Function UPDXMLP()

	Local cQuery := ""

	cQuery := " SELECT ZZ5_SEQIMP,ZZ5_NATFIN,ZZ5_TIPOEN,ZZ5_NATOP, R_E_C_N_O_ as RECNO, ZZ5_CGCEMI FROM ZZ5010(NOLOCK) "
	cQuery += " WHERE ZZ5_TIPOEN = 'F' AND ZZ5_NATOP LIKE '%DEVOL%'and D_E_L_E_T_ = '' "
	//cQuery += " AND  ZZ5_CHAVE IN ('42200883488882002904550020000014101001827903') "

	If Select('095TESTE') <> 0
		dbSelectArea('095TESTE')
		('095TESTE')->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS ('095TESTE') 
 
	While ('095TESTE')->(!eof())

		dbselectarea('ZZ5')
		dbsetorder(1)
		dbgoto(('095TESTE')->RECNO)
		
		dbselectarea("SA1")
		dbsetorder(3)
		If SA1->( dbSeek(xFilial("SA1") + ('095TESTE')->ZZ5_CGCEMI)  )

			RECLOCK('ZZ5',.F.)
				ZZ5_TIPOEN := 'C'
				ZZ5_NATFIN := '101001'
				ZZ5_CODEMI := SA1->A1_COD
				ZZ5_LOJEMI := SA1->A1_LOJA
				ZZ5_NATFIN := SA1->A1_NATUREZ
			ZZ5->(MSUNLOCK())
		Endif 
	
		('095TESTE')->(dbskip())
	Enddo 
Return


// Rotina para importar notas de prestação de contas
// Utilizada incialmente apenas para Lançar notas que Não estão no sistema
User function UPDXMLA()

	Local  cDiretorio := "/XML_DOXPC/"
    Local  aXMLS := Directory(cDiretorio+'*.*'/*, "D"*/)
	Local  i         := 0 
	Local cCGCEmit   := ""
	Local cCGCDest   := ""
	Local _cTipoNF   := "N"
	Local AddErroXml := {}
	Local cCabecalho := ""
	Local cRegistros := ""
	Local dEmissao   := date()
	Local cPulaLinha := chr(13) + chr(10)
	Local aItens     := {}
	Local nPosCC     := 0 
	Local cCcusto    := ""
	Private nDecTot  := 2//TamSX3("D1_TOTAL")[2]
	Private aEmpresas := {}
	Private cCnpjAtual  
	Private cObs     := ""
	Private nTamNota   := 9
	Private nTamCmpNF  := TamSX3("F1_DOC")[1]
	Private nTamCmpSer := TamSX3("F1_SERIE")[1]
	Private cEmitCod := ""
	Private cEmitLoj := ""
	Private cNatFin  := ""
	Private cEstado  := ""
	Private cConPgto := ""
	Private cTpNFe   := ""
	Private lMsErroAuto := .F.
	Private lConfere    := .T.
	Private aCCxChave := {}

	cCabecalho := 	  "XML Chave; "+; 
                      "XML Cnpj Dest; "+;
                      "XML Cnpj Emi;"+;
                      "XML Tipo Nf;"+;
					  "XML Emissao;"+;
                      "XML Valor Tot;"+;
					  "PRT Cliente;"+;
					  "PRT Loja;"+;
					  "PRT CC;"+;
					  "PRT Obs;"
	
	cCabecalho	  += cPulaLinha

	aEmpresas := Empresas()

	GravaArrCC()

	cCnpjAtual := SM0->M0_CGC

	//Varre pastas com XML 
    For i := 1 to len(aXMLS) 

        cArquivo := aXMLS[i][1]
		

        //Lê xml e Cria NODE
        _oXml := LerXml(cDiretorio+cArquivo)
    
		//Busca Cnpj do Destinatario
		If ValType(XmlChildEx(_oXml:_nfeProc:_NFe:_infNFe:_dest, "_CNPJ")) <> "U"
			cCGCDest := AllTrim(_oXml:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:Text)
		Else
			cCGCDest := AllTrim(_oXml:_nfeProc:_NFe:_infNFe:_dest:_CPF:Text)
		EndIf

		//Valida se Precisa mudar de empresa
		If cCnpjAtual <> cCGCDest
			nPosEmp := aScan(aEmpresas,{|x|Alltrim(x[1])==cCGCDest})

			//Se encontrou 
			if nPosEmp > 0 
				cCnpjAtual  :=  aEmpresas[nPosEmp][1]
				cEmpAnt 	:=  aEmpresas[nPosEmp][2]
				cFilAnt 	:=  aEmpresas[nPosEmp][3]	
			Else 
				Loop
			Endif
			
			RPCClearEnv()
			RPCSetEnv(cEmpAnt,cFilAnt)
		
		Endif 
		
		//Limpa Variaveis
		cObs := ""
		cCcusto  := ""
		cEmitCod := ""
		cEmitLoj := ""
		cNatFin  := ""
		cEstado  := ""
		cConPgto := ""
		cTpNFe   := ""
		cProdDes := 'DES52111633    '

        cChave := _oXml:_Nfeproc:_protnfe:_infProt:_chNFe:Text
		
		nPosCC := aScan(aCCxChave,{|x|Alltrim(x[1])==cChave})

		//Se encontrou 
		If nPosCC > 0  
			cCcusto  :=  aCCxChave[nPosCC][2]
			Dbselectarea('CTT')
			DbSetorder(1)
			If !(DbSeek(xfilial('CTT') + cCcusto))
				cObs := "Centro de Custo NÃO existe no Protheus "
			Endif
		Else 
			cObs := "Centro de Custo não preenchido no DOX "
		Endif 
 		
		If Valtype(XmlChildEx(_oXml:_NfeProc:_Nfe:_InfNfe:_Ide,"_DHEMI")) == "O"
			dEmissao := CToD(Substr(_oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_dhEmi:Text,9,2) + "/" + Substr(_oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_dhEmi:Text,6,2) + "/" + Substr(_oXml:_NfeProc:_Nfe:_InfNfe:_Ide:_dhEmi:Text,1,4))
        Else
			dEmissao := CToD(Substr(_oXml:_nfeProc:_NFe:_infNFe:_ide:_dEmi:Text,9,2) + "/" + Substr(_oXml:_nfeProc:_NFe:_infNFe:_ide:_dEmi:Text,6,2) + "/" + Substr(_oXml:_nfeProc:_NFe:_infNFe:_ide:_dEmi:Text,1,4))
        Endif
		
		//Busca Cnpj do Emissor
		If ValType(XmlChildEx(_oXml:_nfeProc:_NFe:_infNFe:_emit, "_CNPJ")) <> "U"
			cCGCEmit := AllTrim(_oXml:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:Text)
		Else
			cCGCEmit := AllTrim(_oXml:_nfeProc:_NFe:_infNFe:_emit:_CPF:Text)
		EndIf

		//Identificar que é uma nota de Devolução
		If ValType(XmlChildEx(_oXml:_nfeProc:_NFe:_infNFe:_ide, "_FINNFE")) <> "U"
			_cTipoNF := 'N'
			If AllTrim(_oXml:_nfeProc:_NFe:_infNFe:_ide:_finNFe:Text) == '4'
				_cTipoNF := 'D'
			Endif 
		Endif 
       
        //Transforma itens em Array
       	XmlNode2Arr(_oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
		nValFrete  := Round(Val(_oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vFrete:Text), nDecTot)
		nValSeguro := Round(Val(_oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vSeg:Text  ), nDecTot)
		nValDesp   := Round(Val(_oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vOutro:Text), nDecTot)
		nValDesc   := Round(Val(_oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vDesc:Text ), nDecTot)
		nValMerc   := Round(Val(_oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vProd:Text ), nDecTot)
		nVnf       := Round(Val(_oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vNf:Text )  , nDecTot)

		/*cRegistros  += 	  "XML Chave; "+; 
                      "XML Cnpj Dest; "+;
                      "XML Cnpj Emi;"+;
                      "XML Tipo Nf;"+; 
                      "XML Valor Tot;"*/

		cRegistros += "	"+cChave +";"    +;  
						"	"+cCGCDest +";"  +;  
						"	"+cCGCEmit+";"  +;   
						_cTipoNF+";" +; 
						dtoc(dEmissao) +";" +;
						Alltrim(Str(nVnf))+";" 

		//Busca Dados de Acordo com o Tipo da Nota
		If _cTipoNF <> 'D'
			dbSelectArea("SA2")
			SA2->( dbSetOrder(3) )
			If U_SMS01CGC(cCGCEmit)//SA2->( dbSeek(xFilial("SA2") + cCGCEmit) )

				cEmitCod := SA2->A2_COD	
				cEmitLoj := SA2->A2_LOJA
				cNatFin  := SA2->A2_NATUREZ
				cEstado  := SA2->A2_EST
				cConPgto := SA2->A2_COND
				cTpNFe   := "F"
			Else
				cObs += "Fornecedor não encontrado "
			Endif		
		Else

			cObs := "Nota de Devulução nao pode ser lançada "
			dbSelectArea("SA1")
			SA1->( dbSetOrder(3) )
			If SA1->( dbSeek(xFilial("SA1") + cCGCEmit) )

				cEmitCod := SA1->A1_COD
				cEmitLoj := SA1->A1_LOJA
				cNatFin  := SA1->A1_NATUREZ
				cEstado  := SA1->A1_EST
				cConPgto := SA1->A1_COND
				cTpNFe   := "C"
			Else
				cObs += " - Cliente não encontrado "
			EndIf
		EndIf

		
		cNumNF   := Right(IIf(Len(_oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text) >= nTamNota, _oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, PadL(_oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, nTamNota, "0")), nTamCmpNF)
		cSerieNF := PadR(_oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text, nTamCmpSer)

		//Verfica se a nota Existe 
		If cObs == ""
			SF1->( dbSetOrder(1) )
			If SF1->( dbSeek(xFilial("SF1") + cNumNF + cSerieNF + cEmitCod + cEmitLoj) )
				//AddErroXml(cArquivo, "- Já existe Nota Fiscal no sistema com a chave de número: " + AllTrim(cNumNF) + " e série: " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text) + " para o fornecedor: " + AllTrim(cEmitCod) + "/" + cEmitLoj + ".")
				cObs := "Já Existe no Protheus"
			EndIf
		Endif


		//Verifica se o produto Existe 
		If cObs == ""
			SB1->( dbSetOrder(1) )
			If !(SB1->( dbSeek(xFilial("SB1") + cProdDes ) ))
				//AddErroXml(cArquivo, "- Já existe Nota Fiscal no sistema com a chave de número: " + AllTrim(cNumNF) + " e série: " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text) + " para o fornecedor: " + AllTrim(cEmitCod) + "/" + cEmitLoj + ".")
				cObs := "Não existe produto "+cProdDes
			EndIf
		Endif

		//Verifica se existe a TES
		If cObs == ""
			SF4->( dbSetOrder(1) )
			If !(SF4->( dbSeek(xFilial("SB1") + SB1->B1_TE ) ))
				//AddErroXml(cArquivo, "- Já existe Nota Fiscal no sistema com a chave de número: " + AllTrim(cNumNF) + " e série: " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text) + " para o fornecedor: " + AllTrim(cEmitCod) + "/" + cEmitLoj + ".")
				cObs := "Não existe produto "+cProdDes
			EndIf
		Endif

		lLancar := .f.

		//Se nao tiver Erros Grava Dados 
		If alltrim(cObs) == "" .and. lLancar

			//Caso Seja uma Nota com mais de 6 meses Altera parametro MV_CHVNFE
			If (dDatabase - dEmissao) > 170 
				If GetMv('MV_CHVNFE')
					PUTMV('MV_CHVNFE', .F.)
				Endif 
			Endif  

			aCabec := { {"F1_DOC"	 , cNumNF					         , Nil, Nil},;
						{"F1_SERIE"  , cSerieNF                          , Nil, Nil},;
						{"F1_FORNECE", cEmitCod			                 , Nil, Nil},;
						{"F1_LOJA"   , cEmitLoj				             , Nil, Nil},;
						{"F1_COND"   , '919'							 , Nil, Nil},;
						{"F1_EMISSAO", dEmissao                          , Nil, Nil},;
						{"F1_DTDIGIT", dDataBase		     		     , Nil, Nil},;
						{"F1_EST"    , cEstado	                         , Nil, Nil},;
						{"F1_TIPO"   , _cTipoNF                          , Nil, Nil},;
						{"F1_ESPECIE", "SPED"                            , Nil, Nil},;
						{"F1_FORMUL" , "N"					             , Nil, Nil},;
						{"F1_CHVNFE" , cChave                            , Nil, Nil},;
						{"F1_VALMERC", nValMerc                          , Nil, Nil},;
						{"F1_FRETE"  , nValFrete                         , Nil, Nil},;
						{"F1_DESPESA", nValDesp                          , Nil, Nil},;
						{"F1_DESCONT", nValDesc                          , Nil, Nil},;
						{"F1_SEGURO" , nValSeguro                        , Nil, Nil},;
						{"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil},;
						{"E2_NATUREZ", cNatFin                           , Nil, Nil},;
						{"F1_ORIIMP"   , 'XAG0071A'						 , Nil, Nil};
				}
			aItens := {}
			AAdd(aItens, {})
				AAdd(aItens[len(aItens)], {"D1_ITEM"   , '0001'			, Nil} )                                                
				AAdd(aItens[len(aItens)], {"D1_COD"	   , cProdDes	   , Nil})
				AAdd(aItens[len(aItens)], {"D1_UM"     , SB1->B1_UM	    , Nil})
				AAdd(aItens[len(aItens)], {"D1_QUANT"     , 1 	    , Nil})
				AAdd(aItens[len(aItens)], {"D1_VUNIT"  , nVnf 			, Nil})
				AAdd(aItens[len(aItens)], {"D1_TOTAL"  , nVnf , Nil})
				AAdd(aItens[len(aItens)], {"D1_TES"    , SB1->B1_TE   , Nil})
				AAdd(aItens[len(aItens)], {"D1_TIPO"   , _cTipoNF                                                           , Nil})
				AAdd(aItens[len(aItens)], {"D1_SERIE"  , cSerieNF                                     , Nil})
				AAdd(aItens[len(aItens)], {"D1_CLASFIS", '0'+SF4->F4_SITTRIB , Nil})
				AAdd(aItens[len(aItens)], {"D1_CONTA"  , SB1->B1_CONTA , Nil})
				AAdd(aItens[len(aItens)], {"D1_CC"     , '4004     '    , Nil})
				AAdd(aItens[len(aItens)], {"AUTDELETA" , "N"			                                                   , Nil})   	        

			//MsAguarde({|| MsExecAuto({|x,y,z,w| Mata103(x,y,z,w)}, aCabec, aItens, 3, lConfere)}, "Importação", "Importando Nota Fiscal Entrada ...")
			MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)
			
			If (dDatabase - dEmissao) > 170 
				If !(GetMv('MV_CHVNFE'))
					PUTMV('MV_CHVNFE', .T.)
				Endif 
			Endif
			
			If lMsErroAuto
				Mostraerro()
				//Alert('ERRO EXECAUTO!')
			Else
				cObs := 'Incluído com Sucesso!'
			Endif


		Endif 

			//Grava Fornece/Loja e Observacao
		cRegistros += 	"	"+cEmitCod +";" +;  
						"	"+cEmitLoj +";" +; 
						"	"+cCcusto +";" +; 	 
						"	"+cObs+";"    

		cRegistros += cPulaLinha

		// {"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil},;
		

	Next i


	cArquivo := StrTran( time(), ":", "_" )+"_PRESTACAO_CONTAS.csv"

	//Conout(cCabecalho+cRegistros)
	MemoWrite( cArquivo, cCabecalho+cRegistros ) 

	If !ApOleClient("MsExcel")                     	
		MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
		Return	
	Endif
	
	__CopyFIle(cArquivo , AllTrim(GetTempPath())+cArquivo)             
		
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cArquivo)//cArqTrbex+".XLS")
	oExcelApp:SetVisible(.T.)                       
								
	fErase(cArquivo) //Deletando arquivo de trabalho	

Return

Static Function Empresas()

	Local cQuery    := ""
	Local cAliasQry := "EMPRESAS"
	Local aRet := {}

	cQuery += " SELECT * FROM EMPRESAS "

	If Select(cAliasQry) <> 0
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasQry)

	While (cAliasQry)->(!eof())

		AADD(aRet,{ (cAliasQry)->EMP_CNPJ,(cAliasQry)->EMP_COD,(cAliasQry)->EMP_FIL,(cAliasQry)->EMP_NOME_FIL  })
		(cAliasQry)->(dbskip())	
	Enddo

	(cAliasQry)->(dbCloseArea())


Return (aRet) 



Static function GravaArrCC()

	
		AADD(aCCxChave,{'35200157619728000113550010000074071232656260','5002'})
		AADD(aCCxChave,{'35200680732928004944550020000003581067629818','12001'})
		AADD(aCCxChave,{'41190818864102000110550010000106551978533248','5003'})
		AADD(aCCxChave,{'41191003479760000111550010001688971635540896','5002'})
		AADD(aCCxChave,{'41191005339319000160550010002656171010116970','5002'})
		AADD(aCCxChave,{'41191005783976000100550010005613801063030627','5104'})
		AADD(aCCxChave,{'41191011774907000205550010000008301289411320','5104'})
		AADD(aCCxChave,{'41191076070689000354550020000598441002565251','8000'})
		AADD(aCCxChave,{'41191077022705000134550020000384791003847902','8000'})
		AADD(aCCxChave,{'41191077190361000172550000002443201325810551','5003'})
		AADD(aCCxChave,{'41191077488005001020550030000003871230013101','5002'})
		AADD(aCCxChave,{'41191079130647000198550020000083011000134788','5003'})
		AADD(aCCxChave,{'41191079794921000557550010000885651399059434','5002'})
		AADD(aCCxChave,{'41191103424013000186550030000009741686652977','5104'})
		AADD(aCCxChave,{'41191103479760000111550010001715371854710135','5002'})
		AADD(aCCxChave,{'41191124120896000100550010000012651001012649','5002'})
		AADD(aCCxChave,{'41191168822154000100550020000052391000668154','5002'})
		AADD(aCCxChave,{'41191177488005000997550010000110081099467645','5002'})
		AADD(aCCxChave,{'41191177488005001101550010000028351756418330','5002'})
		AADD(aCCxChave,{'41191179130647000198550020000085501000140361','5003'})
		AADD(aCCxChave,{'41191180245988000198550020000141041001585970','5002'})
		AADD(aCCxChave,{'41191180245988000198550020000149511001679625','5002'})
		AADD(aCCxChave,{'41191204739586000161550010000001021017058852','5014'})
		AADD(aCCxChave,{'41191206281900000130550010000258681000553720','5200'})
		AADD(aCCxChave,{'41191206281900000130550010000258691000553744','5104'})
		AADD(aCCxChave,{'41191206281900000130550010000258731000553810','5002'})
		AADD(aCCxChave,{'41191206281900000130550010000258741000553833','5000'})
		AADD(aCCxChave,{'41191211343246000182550010000228031001303253','5000'})
		AADD(aCCxChave,{'41191245543915003520550010002533591292220655','5003'})
		AADD(aCCxChave,{'41191275308551000116550010001145891078989696','5003'})
		AADD(aCCxChave,{'41191277022705000134550020000395321003953207','5002'})
		AADD(aCCxChave,{'41191282686114000100550030000208201288669664','5002'})
		AADD(aCCxChave,{'41200103424013000186550020000026151112093325','5104'})
		AADD(aCCxChave,{'41200117125454000125550050000462751008901084','6003'})
		AADD(aCCxChave,{'41200117125457000125550050000462751008901084','6005'})
		AADD(aCCxChave,{'41200118864102000110550010000121681581836140','5003'})
		AADD(aCCxChave,{'41200175179879000180550020000095281000460757','5002'})
		AADD(aCCxChave,{'41200176947126000130550020000340121000353978','5002'})
		AADD(aCCxChave,{'41200177488005000997550030000004821384316121','5002'})
		AADD(aCCxChave,{'41200177488005000997550030000005111692343999','5002'})
		AADD(aCCxChave,{'41200179379491000779550010004451221101525677','5200'})
		AADD(aCCxChave,{'41200202786090000113550010002106941000299056','6000'})
		AADD(aCCxChave,{'41200203479760000111550010001789961867359200','5002'})
		AADD(aCCxChave,{'41200203626094000105550010000564881589578874','5002'})
		AADD(aCCxChave,{'41200205783976000100550010005709621064333550','5104'})
		AADD(aCCxChave,{'41200207025401000145550010000246511710130892','2001'})
		AADD(aCCxChave,{'41200210327548000102550200000032861276374098','5002'})
		AADD(aCCxChave,{'41200212132199000190550020000023181822260343','2001'})
		AADD(aCCxChave,{'41200225282758000190550010000006101830676726','5104'})
		AADD(aCCxChave,{'41200230491578000159550030000014501356391246','5104'})
		AADD(aCCxChave,{'41200277190361000172550000002492811901503527','5003'})
		AADD(aCCxChave,{'41200306336878000189550020000399701000853499','6014'})
		AADD(aCCxChave,{'41200311343246000182550010000233991001345909','5000'})
		AADD(aCCxChave,{'41200313216867000120550010000007161102231561','5002'})
		AADD(aCCxChave,{'41200377488005000997550030000005941855072344','5002'})
		AADD(aCCxChave,{'41200377488005000997550030000006491504496273','5002'})
		AADD(aCCxChave,{'41200378415056000102550010002695991620910534','6000'})
		AADD(aCCxChave,{'41200379130647000198550020000113251000202043','5003'})
		AADD(aCCxChave,{'41200379130647000198550020000115521000207221','5003'})
		AADD(aCCxChave,{'41200410482716000207550010000059771025788465','5003'})
		AADD(aCCxChave,{'41200410482716000207550010000059781065626374','5003'})
		AADD(aCCxChave,{'41200500834743000167550010000192001425213160','5002'})
		AADD(aCCxChave,{'41200501994951001168550010000276801094584166','5003'})
		AADD(aCCxChave,{'41200503479760000111550010001864371598127418','5002'})
		AADD(aCCxChave,{'41200505035532000269550020001787481008795240','5003'})
		AADD(aCCxChave,{'41200511769886000159550010000848961000038580','5002'})
		AADD(aCCxChave,{'41200577488005000997550030000072014611131277','5002'})
		AADD(aCCxChave,{'41200608578269000161550010000936731000936745','6014'})
		AADD(aCCxChave,{'41200611343246000182550010000236731001363460','5000'})
		AADD(aCCxChave,{'41200677190361000172550000002536101800883384','5003'})
		AADD(aCCxChave,{'41200677488005001020550030000008321986998084','5002'})
		AADD(aCCxChave,{'41200679130647000198550020000138051000258000','5003'})
		AADD(aCCxChave,{'41200700834743000167550010000195921972399848','5002'})
		AADD(aCCxChave,{'41200705157202000165550030000087841000265871','6014'})
		AADD(aCCxChave,{'41200776070689000192550020000551661002767431','12001'})
		AADD(aCCxChave,{'41200777488005000997550030000008241718505890','5002'})
		AADD(aCCxChave,{'41200831496230000117550010000021371487895710','5002'})
		AADD(aCCxChave,{'42190608285342000107550010000014771000014773','5001'})
		AADD(aCCxChave,{'42190983428250000154550010000239461000239503','4004'})
		AADD(aCCxChave,{'42190983488882000618550030000052311000185173','4004'})
		AADD(aCCxChave,{'42190983488882001770550030000193061000228037','4004'})
		AADD(aCCxChave,{'42190983488882004524550030000025041000154035','4004'})
		AADD(aCCxChave,{'42191002100201000196550010000000271000000055','2121'})
		AADD(aCCxChave,{'42191002100201000196550010000000301000000123','2121'})
		AADD(aCCxChave,{'42191077893725000180550020001356281001362216','4000'})
		AADD(aCCxChave,{'42191078219169000124550010000013081044734674','5103'})
		AADD(aCCxChave,{'42191081803793000189550010000008771557610602','5001'})
		AADD(aCCxChave,{'42191082846197000149550010000001441521463090','2000'})
		AADD(aCCxChave,{'42191082956160002117550010000553311524655264','1009'})
		AADD(aCCxChave,{'42191082956160002117550010000553361108118021','1009'})
		AADD(aCCxChave,{'42191082956160002117550010000553371545209544','1009'})
		AADD(aCCxChave,{'42191082956160002117550010000553381201713931','1009'})
		AADD(aCCxChave,{'42191082956160002117550010000553391524655264','1009'})
		AADD(aCCxChave,{'42191082956160002117550010000553401653545075','1009'})
		AADD(aCCxChave,{'42191083198994000391550010000425101000577824','4001'})
		AADD(aCCxChave,{'42191083270397000592550020001617851007685602','5001'})
		AADD(aCCxChave,{'42191083305235006400550010003529641085014902','4000'})
		AADD(aCCxChave,{'42191083305235006400550010003532311424442320','4000'})
		AADD(aCCxChave,{'42191100125318000360550020000031891142235902','5001'})
		AADD(aCCxChave,{'42191102100201000196550010000000341000000150','2121'})
		AADD(aCCxChave,{'42191103603595001563550020000345571000876772','5000'})
		AADD(aCCxChave,{'42191103603595001563550020000345581000876800','5000'})
		AADD(aCCxChave,{'42191107021895000190550010000014381254736146','2149'})
		AADD(aCCxChave,{'42191107021895000190550010000014441582880570','2149'})
		AADD(aCCxChave,{'42191110354510000110550010000069831000057807','4004'})
		AADD(aCCxChave,{'42191110482364000109550010000101811610034200','5001'})
		AADD(aCCxChave,{'42191114248867000175550010000013881786825929','5001'})
		AADD(aCCxChave,{'42191125138908000197550020000036891000037112','4000'})
		AADD(aCCxChave,{'42191127573106000130550550000019161000019236','4000'})
		AADD(aCCxChave,{'42191176822832000155550010000038021508655024','5001'})
		AADD(aCCxChave,{'42191177893725000180550020001360781001366715','4000'})
		AADD(aCCxChave,{'42191177893725000180550020001371781001377717','5001'})
		AADD(aCCxChave,{'42191179379491001589550010001332831181225380','6000'})
		AADD(aCCxChave,{'42191179379491001589550010001340261958745005','6000'})
		AADD(aCCxChave,{'42191182647165002087550040000795771509870400','1012'})
		AADD(aCCxChave,{'42191183198994000391550010000428291000558753','4001'})
		AADD(aCCxChave,{'42191183198994000391550010000430261000587472','4001'})
		AADD(aCCxChave,{'42191183305235006400550010003537381657018352','4000'})
		AADD(aCCxChave,{'42191183305235006400550010003545201899293524','5001'})
		AADD(aCCxChave,{'42191183305235006400550010003551811186615698','5001'})
		AADD(aCCxChave,{'42191183305235006400550010003559271801453231','4000'})
		AADD(aCCxChave,{'42191193603595001563550020000345611000876856','5001'})
		AADD(aCCxChave,{'42191200125318000360550020000034531260724650','4000'})
		AADD(aCCxChave,{'42191200125318000360550020000034721395961183','4000'})
		AADD(aCCxChave,{'42191200125318000360550020000036111267082077','5001'})
		AADD(aCCxChave,{'42191201180531000176550010000223141674963186','5104'})
		AADD(aCCxChave,{'42191201398128000118550020000417861001286103','4004'})
		AADD(aCCxChave,{'42191202690750000168550010000006781789528167','2149'})
		AADD(aCCxChave,{'42191208033253001579550040000779351529184504','5001'})
		AADD(aCCxChave,{'42191208664169000158550000000869401610361799','5001'})
		AADD(aCCxChave,{'42191225138908000197550020000039021000039245','5001'})
		AADD(aCCxChave,{'42191276822832000155550010000038331509110021','5001'})
		AADD(aCCxChave,{'42191276863877000259550010000235111241467150','5001'})
		AADD(aCCxChave,{'42191277893725000180550020001385351001391283','5001'})
		AADD(aCCxChave,{'42191279383030000184550000000096481835912933','5104'})
		AADD(aCCxChave,{'42191281298960000181550010000453231000119816','4004'})
		AADD(aCCxChave,{'42191283305235006400550010003566051862264743','4000'})
		AADD(aCCxChave,{'42191283305235006400550010003574461073587664','5001'})
		AADD(aCCxChave,{'42191283305235006400550010003582201426536786','5001'})
		AADD(aCCxChave,{'42191283646984001505550010004612401000368111','5103'})
		AADD(aCCxChave,{'42191285152601000172550010000052011697647827','5001'})
		AADD(aCCxChave,{'42200100125318000107550010001237531052379338','5001'})
		AADD(aCCxChave,{'42200100125318000360550020000038111995731342','5001'})
		AADD(aCCxChave,{'42200100125318000360550020000040091304508841','5001'})
		AADD(aCCxChave,{'42200102100201000196550010000000381000000272','2121'})
		AADD(aCCxChave,{'42200104777365000188550030000099581001166418','4003'})
		AADD(aCCxChave,{'42200107395723000186550020000038561348915359','5001'})
		AADD(aCCxChave,{'42200125138908000197550020000039741000039967','5001'})
		AADD(aCCxChave,{'42200127573106000130550550000029951000021050','5001'})
		AADD(aCCxChave,{'42200173730129001958550010000014351100174167','5001'})
		AADD(aCCxChave,{'42200175362707000147550100000015341001059488','5001'})
		AADD(aCCxChave,{'42200177893725000180550020001411331001417267','5001'})
		AADD(aCCxChave,{'42200181298960000181550010000454431000121016','4001'})
		AADD(aCCxChave,{'42200181632093001574550010000023631100041410','12001'})
		AADD(aCCxChave,{'42200183198994000391550010000442071000608975','4001'})
		AADD(aCCxChave,{'42200183305235006400550010003597821527163675','5001'})
		AADD(aCCxChave,{'42200183305235006400550010003604761771589448','5001'})
		AADD(aCCxChave,{'42200183305235006400550010003611021948517566','5001'})
		AADD(aCCxChave,{'42200183305235006400550010003618101939442785','5001'})
		AADD(aCCxChave,{'42200183392050000199550010000873551878162077','4004'})
		AADD(aCCxChave,{'42200183488882000103550030000583771000898515','5001'})
		AADD(aCCxChave,{'42200184588417000107550030000154801011556410','2330'})
		AADD(aCCxChave,{'42200184588656000167550030000029421000031387','4003'})
		AADD(aCCxChave,{'42200200125318000360550020000041341583708356','5001'})
		AADD(aCCxChave,{'42200200125318000360550020000042081677076324','5001'})
		AADD(aCCxChave,{'42200201018921000144550020000004351163307975','2000'})
		AADD(aCCxChave,{'42200202100201000196550010000000421000000163','2121'})
		AADD(aCCxChave,{'42200203462986000100550010000035161596493045','2200'})
		AADD(aCCxChave,{'42200204320984000149550010000149171100441656','5103'})
		AADD(aCCxChave,{'42200205235301000118550020000047731000905039','5001'})
		AADD(aCCxChave,{'42200207966074000126550020000035471000905011','5001'})
		AADD(aCCxChave,{'42200207966074000126550020000035481000905000','5001'})
		AADD(aCCxChave,{'42200207966074000126550020000035491000904990','5001'})
		AADD(aCCxChave,{'42200207966074000126550020000035501000904975','5001'})
		AADD(aCCxChave,{'42200208033253002389550040000546471878583210','5001'})
		AADD(aCCxChave,{'42200208930481000146550040000115401000003391','5001'})
		AADD(aCCxChave,{'42200208930481000146550040000115491000003486','5001'})
		AADD(aCCxChave,{'42200208930481000146550040000115641000003636','5001'})
		AADD(aCCxChave,{'42200213501187000744550010002975161338327914','2005'})
		AADD(aCCxChave,{'42200213501187000744550010002976961596577634','2005'})
		AADD(aCCxChave,{'42200227573106000130550550000021771000000496','5001'})
		AADD(aCCxChave,{'42200227573106000130550550000021861000000584','5001'})
		AADD(aCCxChave,{'42200235149948000198550010000000081075236605','5001'})
		AADD(aCCxChave,{'42200272123912000161550010001205691285348446','4003'})
		AADD(aCCxChave,{'42200275362707000147550100000018141001062281','5001'})
		AADD(aCCxChave,{'42200277893725000180550020001419221001425158','5001'})
		AADD(aCCxChave,{'42200278219169000124550010000013911820466693','5103'})
		AADD(aCCxChave,{'42200279379491007277550010001348021374872081','2005'})
		AADD(aCCxChave,{'42200280664220000159550010000003471020648968','2305'})
		AADD(aCCxChave,{'42200281800849006344550010000597461005974612','5001'})
		AADD(aCCxChave,{'42200281803793000189550010000009301548391427','5001'})
		AADD(aCCxChave,{'42200283198994000391550010000446721000617501','4001'})
		AADD(aCCxChave,{'42200283198994000391550010000447791000619438','4001'})
		AADD(aCCxChave,{'42200283305235006400550010003624751306957215','5001'})
		AADD(aCCxChave,{'42200283305235006400550010003646231706965499','5001'})
		AADD(aCCxChave,{'42200285152601000172550010000052781561311430','5001'})
		AADD(aCCxChave,{'42200300125318000360550020000046841718961219','5001'})
		AADD(aCCxChave,{'42200302100201000196550010000000471000000090','2121'})
		AADD(aCCxChave,{'42200304711501000137550010000075501878051108','5001'})
		AADD(aCCxChave,{'42200308033253001579550040000797271734088790','5001'})
		AADD(aCCxChave,{'42200308033253001579550040000799281096218340','5001'})
		AADD(aCCxChave,{'42200308033253002389550040000547811442310986','5001'})
		AADD(aCCxChave,{'42200308930481000146550040000115881000003879','5001'})
		AADD(aCCxChave,{'42200308930481000146550040000116011000004003','5001'})
		AADD(aCCxChave,{'42200327573106000130550550000022381000001124','5001'})
		AADD(aCCxChave,{'42200376863877000259550010000255651757190715','5001'})
		AADD(aCCxChave,{'42200377044618005147551000001871661030187160','2121'})
		AADD(aCCxChave,{'42200380451289000102550010003730051003585525','5001'})
		AADD(aCCxChave,{'42200383305235006400550010003652521500683070','5001'})
		AADD(aCCxChave,{'42200383305235006400550010003660581098735749','5001'})
		AADD(aCCxChave,{'42200383488882000103550030000610181000924925','4000'})
		AADD(aCCxChave,{'42200383488882002408550030000060021000107328','12001'})
		AADD(aCCxChave,{'42200407365481000188550010000402811000080520','4003'})
		AADD(aCCxChave,{'42200408930481000146550040000116341000004334','5001'})
		AADD(aCCxChave,{'42200408930481000146550040000116501000004494','5001'})
		AADD(aCCxChave,{'42200408930481000146550040000116621000004614','5001'})
		AADD(aCCxChave,{'42200408981807000164550010000368711000145060','4003'})
		AADD(aCCxChave,{'42200414563006000181550010000153441000153572','5001'})
		AADD(aCCxChave,{'42200427573106000130550550000023551000002325','5001'})
		AADD(aCCxChave,{'42200478219169000124550010000014271087988389','5103'})
		AADD(aCCxChave,{'42200479292553000115550040000338471148688025','4003'})
		AADD(aCCxChave,{'42200481800849006344550010000637871006378718','5001'})
		AADD(aCCxChave,{'42200481800849006344550010000638941006389418','5001'})
		AADD(aCCxChave,{'42200483220723004463550010000142981005419321','4003'})
		AADD(aCCxChave,{'42200483488882005687550030000001381001123787','4001'})
		AADD(aCCxChave,{'42200486547635000471550010000009341000074125','12001'})
		AADD(aCCxChave,{'42200502494093000183550010000086251000075547','4001'})
		AADD(aCCxChave,{'42200507395723000186550020000040301503974421','5001'})
		AADD(aCCxChave,{'42200507864302000157550010000356421000089121','4003'})
		AADD(aCCxChave,{'42200508033253001579550040000808751612971625','5001'})
		AADD(aCCxChave,{'42200508033253002389550040000558491787034045','5001'})
		AADD(aCCxChave,{'42200508930481000146550040000117001000004998','5001'})
		AADD(aCCxChave,{'42200508930481000146550040000117201000005199','5001'})
		AADD(aCCxChave,{'42200508930481000146550040000117271000005262','5001'})
		AADD(aCCxChave,{'42200508930481000146550040000117421000005412','5001'})
		AADD(aCCxChave,{'42200514248867000175550010000015601898289330','5001'})
		AADD(aCCxChave,{'42200525138908000197550020000046191000046417','5001'})
		AADD(aCCxChave,{'42200527573106000130550550000024251000003020','5001'})
		AADD(aCCxChave,{'42200581800849006344550010000639681006396812','5001'})
		AADD(aCCxChave,{'42200581803793000189550010000009771201953455','5001'})
		AADD(aCCxChave,{'42200583305235006400550010003708631520273573','5001'})
		AADD(aCCxChave,{'42200583488882004958550030000117471000230667','12001'})
		AADD(aCCxChave,{'42200583488882004958550030000118061000231259','12001'})
		AADD(aCCxChave,{'42200583534396000184550010001293151004571071','12001'})
		AADD(aCCxChave,{'42200601277443000197550010000031081043277005','5001'})
		AADD(aCCxChave,{'42200604415958018054550010000887041500884305','4001'})
		AADD(aCCxChave,{'42200605821270000187550020000275911405341408','12001'})
		AADD(aCCxChave,{'42200608930481000146550040000117941000005935','5001'})
		AADD(aCCxChave,{'42200608930481000146550040000118191000006185','5001'})
		AADD(aCCxChave,{'42200618157881000114550010000336921871045480','12001'})
		AADD(aCCxChave,{'42200625138908000197550020000046531000046757','5001'})
		AADD(aCCxChave,{'42200625138908000197550020000047201000047421','5001'})
		AADD(aCCxChave,{'42200627573106000130550550000024731000003500','5001'})
		AADD(aCCxChave,{'42200672123912000161550010001236071791208693','5001'})
		AADD(aCCxChave,{'42200676863877000259550010000274561258041248','5001'})
		AADD(aCCxChave,{'42200677893725000180550020001481411001487348','5001'})
		AADD(aCCxChave,{'42200678219169000124550010000014861501488304','5103'})
		AADD(aCCxChave,{'42200681800849006344550010000661841006618413','5001'})
		AADD(aCCxChave,{'42200683305235006400550010003725681748927787','5001'})
		AADD(aCCxChave,{'42200683305235006400550010003732281973132870','5001'})
		AADD(aCCxChave,{'42200683488882003048550030000234261000270545','12001'})
		AADD(aCCxChave,{'42200683595926000102550020000029781190820451','5001'})
		AADD(aCCxChave,{'42200708677847000117550010000364141893031359','12001'})
		AADD(aCCxChave,{'42200708930481000146550040000118571000006562','5001'})
		AADD(aCCxChave,{'42200708930481000146550040000118791000006780','5001'})
		AADD(aCCxChave,{'42200708930481000146550040000118971000006967','5001'})
		AADD(aCCxChave,{'42200714248867000175550010000016621578370338','5001'})
		AADD(aCCxChave,{'42200723448964001255550010000028041946993932','12001'})
		AADD(aCCxChave,{'42200725138908000197550020000047921000048145','5001'})
		AADD(aCCxChave,{'42200777893725000180550020001484141001490074','5001'})
		AADD(aCCxChave,{'42200777893725000180550020001488671001494601','5001'})
		AADD(aCCxChave,{'42200777893725000180550020001491681001497612','5001'})
		AADD(aCCxChave,{'42200777893725000180550020001495231001501164','5001'})
		AADD(aCCxChave,{'42200777893725000180550020001498241001504175','5001'})
		AADD(aCCxChave,{'42200777893725000180550020001499341001505270','5001'})
		AADD(aCCxChave,{'42200783305235006400550010003756131427993526','5001'})
		AADD(aCCxChave,{'42200783488882001509550030000816581000852580','12001'})
		AADD(aCCxChave,{'42200807395723000186550020000041721219773340','5001'})
		AADD(aCCxChave,{'42200808033253001579550040000821611383458115','5001'})
		AADD(aCCxChave,{'42200814631967000186550010000241701441199996','12001'})
		AADD(aCCxChave,{'42200822915775000120550010000603161006031616','12001'})
		AADD(aCCxChave,{'42200833360446000186550010000089971071841972','4004'})
		AADD(aCCxChave,{'42200833360446000186550010000090081489827443','4001'})
		AADD(aCCxChave,{'42200877893725000180550020001501981001507915','5001'})
		AADD(aCCxChave,{'42200877893725000180550020001502821001508755','5001'})
		AADD(aCCxChave,{'42200877893725000180550020001505691001511629','5001'})
		AADD(aCCxChave,{'42200883305235006400550010003780131634557882','5001'})
		AADD(aCCxChave,{'42200883305235006400550010003787431154757818','5001'})
		AADD(aCCxChave,{'43190910401845000142550200000002181001624721','8001'})
		AADD(aCCxChave,{'43190910401845000142550200000002581001637675','8001'})
		AADD(aCCxChave,{'43190910401845000142550200000002921001643162','8001'})
		AADD(aCCxChave,{'43191010401845000142550200000003031001647368','8001'})
		AADD(aCCxChave,{'43191010401845000142550200000003201001651684','8001'})
		AADD(aCCxChave,{'43191010401845000142550200000003491001659578','8001'})
		AADD(aCCxChave,{'43191010401845000142550200000003631001663949','8001'})
		AADD(aCCxChave,{'43191010401845000142550200000003871001670858','8001'})
		AADD(aCCxChave,{'43191010401845000142550200000003951001672763','8001'})
		AADD(aCCxChave,{'43191010401845000142550200000004021001674940','8001'})
		AADD(aCCxChave,{'43191110401845000142550200000004411001687491','8001'})
		AADD(aCCxChave,{'43191194673480000952550010001070401002489791','8001'})
		AADD(aCCxChave,{'43200119926983000110550020000015571043277008','5104'})
		AADD(aCCxChave,{'43200292392463000164550010000001731458049360','8001'})
		AADD(aCCxChave,{'50191021564846000124550010000199271908781656','5104'})
		AADD(aCCxChave,{'50191206156076000197550010000561861001537692','5104'})
		AADD(aCCxChave,{'50191224175991000101550010000016971000016978','5104'})
		AADD(aCCxChave,{'50200121564846000124550010000209581624662476','5104'})
		AADD(aCCxChave,{'50200202322859000142550010000078011000958310','5104'})
		AADD(aCCxChave,{'50200206156076000197550010000572581001691645','5104'})
		AADD(aCCxChave,{'50200302101372000130550010000179671001547591','5104'})
		AADD(aCCxChave,{'50200302101372000130550010000179731000743122','5104'})
		AADD(aCCxChave,{'50200321564846000124550010000218921372763506','12001'})
		AADD(aCCxChave,{'50200500199238000198550010000054581002050721','12001'})
		AADD(aCCxChave,{'50200622959736000124550010000002071000002088','12001'})
		AADD(aCCxChave,{'50200706156076000197550010000596091002045792','12001'})
		AADD(aCCxChave,{'51200613593624000101550010000294911999194926','5002'})
		AADD(aCCxChave,{'51200613593654000101550010000294951999594923','5000'})

Return