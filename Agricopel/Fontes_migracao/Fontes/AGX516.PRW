#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

User Function AGX516()

	Local cFile     := ""
	Local cNomeArq  := ""

	Private _aListaLog := {}
	Private cPath      := "\importacao_nfe\"
	Private cPathArq   := ""
	Private oMSNewGe1  := Nil

	cPathArq := AllTrim(cGetFile("Arquivos XML|*.XML", "Importar XML", 0,"C:\XML", .T.,GETF_LOCALHARD,.T.))

	If AllTrim(cPathArq) <> ""

		cNomeArq  := RetFileName(cPathArq) + ".XML"

		If CpyT2S(cPathArq, "\importacao_nfe")
			ImpXML(cNomeArq)
		Else
			MsgAlert("Falha na cópia do arquivo XML para o servidor! [" + cNomeArq + "]")
		EndIf

	EndIf

    If Select("LSF1") <> 0
       dbSelectArea("LSF1")
   	   dbCloseArea()
    EndIf

    If Select("LSD1") <> 0
       dbSelectArea("LSD1")
   	   dbCloseArea()
    Endif

    If Select("SF4") <> 0
       dbSelectArea("SF4")
   	   dbCloseArea()
    Endif

    If Select("SF1") <> 0
       dbSelectArea("SF1")
   	   dbCloseArea()
    Endif

    If Select("SD1") <> 0
       dbSelectArea("SD1")
   	   dbCloseArea()
    Endif

    If Select("SB1") <> 0
       dbSelectArea("SB1")
   	   dbCloseArea()
    Endif

    If Select("SA2") <> 0
       dbSelectArea("SA2")
   	   dbCloseArea()
    Endif

    If Select("ZZO") <> 0
       dbSelectArea("ZZO")
   	   dbCloseArea()
    Endif

Return()

Static Function ImpXML(cFile)

	Local oXml        := Nil

	Local cCNPJ_FOR   := ""
	Local cDtEmissao  := ""
	Local nNumItens   := 0
	Local nCont       := 0

	Local cF1_DOC     := ""
	Local cF1_SERIE   := ""
	Local cF1_LOJA    := ""
	Local cF1_FORNECE := ""

	Local cCNPJ_FIL   := ""
	Local cVersao     := ""

	oXml := AbrirXML(cFile)
	
	If oXml == Nil
		Return()
	EndIf

	cCNPJ_FIL := oXml:_INFNFE:_DEST:_CNPJ:TEXT

	If AllTrim(cCNPJ_FIL) <> AllTrim(SM0->M0_CGC)
		MsgAlert("É necessário loga-se à Empresa/Filial do XML! " + Chr(13) + Chr(10) + "CNPJ: " + cCNPJ_FIL + Chr(13) + Chr(10) + "Descrição: " + oXml:_INFNFE:_DEST:_xNome:TEXT)
		Return()
	EndIf

	cCNPJ_FOR := oXml:_INFNFE:_EMIT:_CNPJ:TEXT
    cVersao   := oXml:_INFNFE:_VERSAO:Text
    
	DBSelectArea("SA2")
	DBSetOrder(3)
	If DbSeek(xFilial("SA2")+cCNPJ_FOR)
		cF1_LOJA    := SA2->A2_LOJA
		cF1_FORNECE := SA2->A2_COD
	Else
		MsgAlert("Impossivel identificar Fornecedor! CNPJ: " + cCNPJ_FOR)
		Return()
	Endif

	cF1_DOC     := StrZero(Val(AllTrim(oXml:_INFNFE:_IDE:_NNF:TEXT)),TamSX3("F1_DOC")[1])
	cF1_SERIE   := PadR(oXml:_InfNfe:_IDE:_Serie:Text,TAMSX3("F1_SERIE")[1]," ")

	DBSelectArea("SF1")
	DBSetOrder(1)
	If DbSeek(xFilial("SF1")+cF1_DOC+cF1_SERIE+cF1_FORNECE+cF1_LOJA)
	     MsgAlert("Número e série da nota fiscal já existe para este fornecedor!";
	     + Chr(13) + Chr(10) + "Forn: " + SA2->A2_COD + "-" + SA2->A2_LOJA + " - " + SA2->A2_NOME;
	     + Chr(13) + Chr(10) + "Nota: " + cF1_DOC  + "-" + cF1_SERIE)

		Return()
	Endif

	CriarSF1()
	CriarSD1()

	dbSelectArea("LSF1")
	RecLock("LSF1", .T.)

		LSF1->LF1_DOC    := cF1_DOC
		LSF1->LF1_SERIE  := cF1_SERIE
		LSF1->LF1_FORNEC := SA2->A2_COD
		LSF1->LF1_LOJA   := SA2->A2_LOJA
	    LSF1->LF1_ESPECI := "SPED"
		LSF1->LF1_TIPO   := "N"
		LSF1->LF1_FORMUL := "N"

		LSF1->LF1_CHVNFE := StrTran(Upper(oXml:_INFNFE:_ID:Text), "NFE")
        
        If cVersao = "3.10"
           cDtEmissao       := oXml:_INFNFE:_IDE:_DHEmi:Text
        Else
           cDtEmissao       := oXml:_INFNFE:_IDE:_dEmi:Text  
        Endif        
		
		cDtEmissao       := Substr(cDtEmissao,9,2)+"/"+Substr(cDtEmissao,6,2)+"/"+Substr(cDtEmissao,1,4)
		LSF1->LF1_EMISSA := CtoD(cDtEmissao)

		LSF1->LF1_VALMER := Val(oXml:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text) 
		LSF1->LF1_FRETE  := 0
		LSF1->LF1_SEGURO := Val(oXml:_INFNFE:_TOTAL:_ICMSTOT:_VSeg:Text) 
 //		LSF1->LF1_VALDESC:= Val(oXml:_INFNFE:_TOTAL:_ICMSTOT:_VSeg:Text)

	MsUnlock()

	nNumItens := Len(oXml:_InfNfe:_DET)

	For nCont := 1 to nNumItens

		dbSelectArea("LSD1")
		RecLock("LSD1", .T.)
                                                                              
		LSD1->LD1_ITEM   := StrZero(nCont,TamSX3("D1_ITEM")[1])
	    LSD1->LD1_FILIAL := cFilAnt
	    LSD1->LD1_COD    := ""
	    LSD1->CODPRDFOR  := AllTrim(oXml:_INFNFE:_DET[nCont]:_Prod:_CPROD:Text)
	    LSD1->DESPRDFOR  := AllTrim(oXml:_INFNFE:_DET[nCont]:_Prod:_XPROD:Text)
	    LSD1->CFOPXMLFO  := AllTrim(oXml:_INFNFE:_DET[nCont]:_Prod:_CFOP:Text)

		LSD1->LD1_QUANT  := Val(oXml:_INFNFE:_DET[nCont]:_Prod:_QCOM:Text)
		LSD1->LD1_VUNIT  := Val(oXml:_INFNFE:_DET[nCont]:_Prod:_VUNCOM:Text)   

		If(XmlChildEx( oXml:_INFNFE:_DET[nCont]:_Prod ,"_VDESC")<>Nil)	
			LSD1->LD1_VDESC  := Val(oXml:_INFNFE:_DET[nCont]:_Prod:_VDESC:Text)
		Else
			LSD1->LD1_VDESC  := 0
		EndIf
		
		                                                                                                                  
		LSD1->LD1_TOTAL  := Val(oXml:_INFNFE:_DET[nCont]:_Prod:_VPROD:Text)

		LSD1->LD1_CONTA  := ""
		LSD1->LD1_TES    := ""
		LSD1->LD1_CF     := ""

		LSD1->AUTDELETA  := "N"

		MsUnlock()

	Next

	CarrPrdFor()
	MontarTela()
Return()

Static Function CriarSF1()

	Local cArqTrab
	Local nX
	Local aAreaSF1    := {}

	Local aCamposSF1  := {{"LF1_TIPO"  , "F1_TIPO"   },;
                          {"LF1_CHVNFE", "F1_CHVNFE" },;
                          {"LF1_DOC"   , "F1_DOC"    },;
                          {"LF1_SERIE" , "F1_SERIE"  },;
                          {"LF1_EMISSA", "F1_EMISSAO"},;
                          {"LF1_FORNEC", "F1_FORNECE"},;
                          {"LF1_LOJA"  , "F1_LOJA"   },;
                          {"LF1_FORMUL", "F1_FORMUL" },;
                          {"LF1_ESPECI", "F1_ESPECIE"},;
                          {"LF1_SEGURO" ,"F1_SEGURO" },;
                          {"LF1_FRETE" , "F1_FRETE"  },;
                          {"LF1_VALMER", "F1_VALMER" },;
                          {"LF1_VALBRU", "F1_VALBRU" };
                         }

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For nX := 1 to Len(aCamposSF1)

		If SX3->(DbSeek(aCamposSF1[nX][2]))
			aAdd(aAreaSF1, {aCamposSF1[nX][1], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
		Else
			MsgAlert("ATENÇÃO! CAMPO [" + aCamposSF1[nX][2] + "] NÃO ENCONTRADO EM SX3!")
		Endif

	Next nX

    If Select("LSF1") <> 0
       dbSelectArea("LSF1")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aAreaSF1,.T.)
	dbUseArea(.T.,,cArqTrab,"LSF1",.T.,.F.)

	TCSetField("LSF1", "LF1_EMISSA", "D", 08, 0)

Return()

Static Function CriarSD1()

	Local cArqTrab1
	Local cArqTrab2
	Local nX
	Local aAreaSD1    := {}

   /*	Local aCamposSD1  := {{"LD1_ITEM"  , "D1_ITEM"   },;
	                      {"LD1_FILIAL", "D1_FILIAL" },;
	                      {"LD1_COD"   , "D1_COD"    },;
	                      {"LD1_DESCRI", "D1_DESCRI" },;
	                      {"LD1_QUANT" , "D1_QUANT"  },;
	                      {"LD1_VUNIT" , "D1_VUNIT"  },;
	                      {"LD1_TOTAL" , "D1_TOTAL"  },;
	                      {"LD1_TES"   , "D1_TES"    },;
	                      {"LD1_CF"    , "D1_CF"     },;
	                      {"LD1_CONTA" , "D1_CONTA"  },;
	                      {"CODPRDFOR" , ""          },;
	                      {"DESPRDFOR" , ""          },;
	                      {"CFOPXMLFO" , ""          };
	                     } */
	                     
	                     
   	Local aCamposSD1  := {{"LD1_ITEM"  , "D1_ITEM"   },;
	                      {"LD1_FILIAL", "D1_FILIAL" },;
	                      {"LD1_COD"   , "D1_COD"    },;
	                      {"LD1_DESCRI", "D1_DESCRI" },;
	                      {"LD1_QUANT" , "D1_QUANT"  },;
	                      {"LD1_VUNIT" , "D1_VUNIT"  },;
				          {"LD1_VDESC" , "D1_VALDESC"},;
	                      {"LD1_TOTAL" , "D1_TOTAL"  },;
	                      {"LD1_TES"   , "D1_TES"    },;
	                      {"LD1_CF"    , "D1_CF"     },;
	                      {"LD1_CONTA" , "D1_CONTA"  },;
	                      {"CODPRDFOR" , ""          },;
	                      {"DESPRDFOR" , ""          },;
	                      {"CFOPXMLFO" , ""          };
	                     } 	                     

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For nX := 1 to Len(aCamposSD1)

		If AllTrim(aCamposSD1[nX][2]) <> "" .And. SX3->(DbSeek(aCamposSD1[nX][2]))
			aAdd(aAreaSD1, {aCamposSD1[nX][1], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
		ElseIf aCamposSD1[nX][1] = "CODPRDFOR"
			aAdd(aAreaSD1,{"CODPRDFOR" ,"C",15,0})
		ElseIf aCamposSD1[nX][1] = "DESPRDFOR"
			aAdd(aAreaSD1,{"DESPRDFOR" ,"C",50,0})
		ElseIf aCamposSD1[nX][1] = "CFOPXMLFO"
			aAdd(aAreaSD1,{"CFOPXMLFO" ,"C",5,0})
		Else
			MsgAlert("ATENÇÃO! CAMPO [" + aCamposSD1[nX][2] + "] NÃO ENCONTRADO EM SX3!")
		Endif

	Next nX

	aAdd(aAreaSD1,{"AUTDELETA" ,"C",1,0}) // AUTDELETA SEMPRE DEVERÁ SER O ÚLTIMO CAMPO DO ARRAY

    If Select("LSD1") <> 0
       dbSelectArea("LSD1")
   	   dbCloseArea()
    Endif

	cArqTrab1 := CriaTrab(aAreaSD1,.T.)
	dbUseArea(.T.,,cArqTrab1,"LSD1",.T.,.F.)

	IndRegua("LSD1",cArqTrab1,"LD1_ITEM",,,)

Return()

Static Function MontarTela()

	Private oDlog

	@ 000,000 TO 550, 1150 DIALOG oDlog TITLE "Geração de Nota a partir de XML importado"

	@ 020,010 Say "Nota Fiscal:"
	@ 020,050 Say LSF1->LF1_DOC + "/" + LSF1->LF1_SERIE

	@ 020,100 Say "Fornecedor:"
	@ 020,140 Say SA2->A2_COD + " - " + SA2->A2_NOME

	MontarItens()

	oDlog:bInit := {|| EnchoiceBar(oDlog, {||oGravar() }, {||oDlog:End()},,{} )}

	ACTIVATE DIALOG oDlog CENTERED

Return()

Static Function MontarItens()

	Local nX
	Local aFieldFill := {}
	Local aHeaderEx  := {}
	Local aColsEx    := {}
	Local cCampo     := ""

	Local aFields  := {{"LD1_ITEM"  , "D1_ITEM"   },;
	                   {"LD1_COD"   , "D1_COD"    },;
	                   {"LD1_QUANT" , "D1_QUANT"  },;
	                   {"LD1_VUNIT" , "D1_VUNIT"  },; 
	                   {"LD1_VDESC" , "D1_VALDESC"},;
	                   {"LD1_TOTAL" , "D1_TOTAL"  },;
	                   {"LD1_TES"   , "D1_TES"    },;
	                   {"CODPRDFOR" , ""          },;
	                   {"DESPRDFOR" , ""          },;
	                   {"CFOPXMLFO" , ""          };
	                  }

	Local aAlterFields := {"LD1_COD", "LD1_TES"}
	Local aLinha := {}

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)

		If AllTrim(aFields[nX][2]) <> "" .And. SX3->(DbSeek(aFields[nX][2]))

			Aadd(aHeaderEx, {AllTrim(X3Titulo()),aFields[nX][1],SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,,;
							 SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

		ElseIf aFields[nX][1] = "CODPRDFOR"
			aAdd(aHeaderEx,{"Cód Prod Forn","CODPRDFOR","",15,0,,SX3->X3_USADO,"C",,,,})
		ElseIf aFields[nX][1] = "DESPRDFOR"
			aAdd(aHeaderEx,{"Desc Prod Forn","DESPRDFOR","",45,0,,SX3->X3_USADO,"C",,,,})
		ElseIf aFields[nX][1] = "CFOPXMLFO"
			aAdd(aHeaderEx,{"CFOP XML","CFOPXMLFO","",05,0,,SX3->X3_USADO,"C",,,,})
		Endif

	Next nX

	DbSelectArea("LSD1")
	dbGoTop()
	While !Eof()

		aLinha := {}

		For nX := 1 to Len(aFields)
			aAdd(aLinha, LSD1->(&(aFields[nX][1])))
		Next

		aAdd(aLinha, .F.)
		AADD(aColsEx, aLinha)

		DbSelectArea("LSD1")
		DbSkip()

	EndDo

	oMSNewGe1 := MsNewGetDados():New( 040, 010, 250, 570, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlog, aHeaderEx, aColsEx)

Return()

Static Function oGravar()

	If ValGrava() .And. PrepItens() .And. GerarPreNF()

		MsgInfo("Pré-Nota gerada com sucesso!")
		MoverArq()
		oDlog:End()

	EndIf

Return()

Static Function ValGrava()

	Local _nX
	Local _lRet     := .T.
	Local _cProd    := ""
	Local _cItem    := ""
	Local _cTES     := ""
	Local _cMsgErro := ""

	Local aHeaderEx := oMSNewGe1:aHeader
	Local aColsEx   := oMSNewGe1:aCols

	Local _nLD1_COD  := aScan(aHeaderEx,{|x|UPPER(Alltrim(x[2])) == "LD1_COD"})
	Local _nLD1_ITEM := aScan(aHeaderEx,{|x|UPPER(Alltrim(x[2])) == "LD1_ITEM"})
	Local _nLD1_TES  := aScan(aHeaderEx,{|x|UPPER(Alltrim(x[2])) == "LD1_TES"})

	For _nX := 1 To (Len(aColsEx))

		_cProd := AllTrim(aColsEx[_nX][_nLD1_COD])
		_cItem := AllTrim(aColsEx[_nX][_nLD1_ITEM])
		_cTES  := AllTrim(aColsEx[_nX][_nLD1_TES])

		If AllTrim(_cProd) == ""
			_cMsgErro += "Item: " + _cItem + " - Código do produto não informado!" + Chr(13) + Chr(10)
		Else
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek(xFilial("SB1")+_cProd)
				_cMsgErro += "Item: " + _cItem + " - Cód: " + _cProd + " - Código do produto inválido!" + Chr(13) + Chr(10)
			EndIf
		EndIf

		If AllTrim(_cTES) == ""
			_cMsgErro += "Item: " + _cItem + " - Código da TES não informado!" + Chr(13) + Chr(10)
		Else
			DbSelectArea("SF4")
			DbSetOrder(1)
			If !DbSeek(xFilial("SF4")+_cTES)
				_cMsgErro += "Item: " + _cItem + " - TES: " + _cTES + " - Código da TES inválido!" + Chr(13) + Chr(10)
			EndIf
		EndIf

	Next _nX

	If AllTrim(_cMsgErro) <> ""
		Aviso("INCONSISTÊNCIAS:", AllTrim(_cMsgErro), {"OK"}, 3)
		_lRet := .F.
	EndIf

Return _lRet

Static Function PrepItens()

	Local _nX

	Local _cProd      := ""
	Local _cItem      := ""
	Local _cTES       := ""

	Local aHeaderEx   := oMSNewGe1:aHeader
	Local aColsEx     := oMSNewGe1:aCols

	Local _nLD1_COD    := aScan(aHeaderEx,{|x|UPPER(Alltrim(x[2])) == "LD1_COD"})
	Local _nLD1_ITEM   := aScan(aHeaderEx,{|x|UPPER(Alltrim(x[2])) == "LD1_ITEM"})
	Local _nLD1_TES    := aScan(aHeaderEx,{|x|UPPER(Alltrim(x[2])) == "LD1_TES"})

	For _nX := 1 To (Len(aColsEx))

		_cProd      := AllTrim(aColsEx[_nX][_nLD1_COD])
		_cItem      := AllTrim(aColsEx[_nX][_nLD1_ITEM])
		_cTES       := AllTrim(aColsEx[_nX][_nLD1_TES])

		DbSelectArea("LSD1")
		DbSetOrder(1)
		DbGoTop()

		If DbSeek(_cItem)		
			RecLock("LSD1", .F.)
			LSD1->LD1_COD := _cProd
			LSD1->LD1_TES := _cTES
			MsUnlock()
		Else
			MsgAlert("Não achou Item no arquivo dos itens da Nota! [" + _cItem + "]")
			Return .F.
		EndIf

	Next _nX

Return .T.

Static Function GerarPreNF()

	Local aCabec := {}
	Local aLinha := {}
	Local aItens := {}

	Local _lGravOK := .F.

	Private lMsErroAuto := .F.

	CargInfo()

	aAdd(aCabec, {"F1_DOC",     LSF1->LF1_DOC   , Nil})
	aAdd(aCabec, {"F1_SERIE",   LSF1->LF1_SERIE , Nil})
	aAdd(aCabec, {"F1_FORNECE", LSF1->LF1_FORNEC, Nil})
	aAdd(aCabec, {"F1_LOJA",    LSF1->LF1_LOJA  , Nil})
	aAdd(aCabec, {"F1_ESPECIE", LSF1->LF1_ESPECI, Nil})
	aAdd(aCabec, {"F1_TIPO",    LSF1->LF1_TIPO  , Nil})
	aAdd(aCabec, {"F1_FORMUL",  LSF1->LF1_FORMUL, Nil})
	aAdd(aCabec, {"F1_CHVNFE",  LSF1->LF1_CHVNFE, Nil})
	aAdd(aCabec, {"F1_EMISSAO", LSF1->LF1_EMISSA, Nil})
	aAdd(aCabec, {"F1_VALMERC", LSF1->LF1_VALMER, Nil})
	aAdd(aCabec, {"F1_FRETE",   LSF1->LF1_FRETE , Nil})
	aAdd(aCabec, {"F1_SEGURO",  LSF1->LF1_SEGURO, Nil})

	aAdd(aCabec, {"F1_VALBRUT", LSF1->LF1_VALMER, Nil})
	aAdd(aCabec, {"F1_DTDIGIT", dDataBase       , Nil})

	DbSelectArea("LSD1")
	DbGoTop()
	While !Eof()

		aLinha := {}

		aAdd(aLinha, {"D1_ITEM",    LSD1->LD1_ITEM  , Nil})
		aAdd(aLinha, {"D1_FILIAL",  LSD1->LD1_FILIAL, Nil})
		aAdd(aLinha, {"D1_COD",     LSD1->LD1_COD   , Nil})
		aAdd(aLinha, {"D1_QUANT",   LSD1->LD1_QUANT , Nil})
		aAdd(aLinha, {"D1_VUNIT",   LSD1->LD1_VUNIT , Nil})    
		aAdd(aLinha, {"D1_VALDESC", LSD1->LD1_VDESC , Nil})  //aqui
		aAdd(aLinha, {"D1_TOTAL",   LSD1->LD1_TOTAL , Nil})
		aAdd(aLinha, {"D1_CONTA",   LSD1->LD1_CONTA , Nil})
//		aAdd(aLinha, {"D1_TES",     LSD1->LD1_TES   , Nil})
//		aAdd(aLinha, {"D1_CF",      LSD1->LD1_CF    , Nil})

		aAdd(aLinha, {"D1_GARANTI", "N"             , Nil})
		aAdd(aLinha, {"D1_STSERV",  "1"             , Nil})
		aAdd(aLinha, {"D1_DFABRIC", LSF1->LF1_EMISSA, Nil})

		aAdd(aLinha, {"AUTDELETA",  LSD1->AUTDELETA , Nil})	
		aAdd(aItens, aLinha)

		DbSelectArea("LSD1")
		DbSkip()

	End

	Begin Transaction
		MATA140(aCabec,aItens,3)
		GravPrdFor()

		DbSelectArea("LSD1")
		DbGoTop()
		While !Eof()

			DbSelectArea("SD1")
			DbSetOrder(1)

			If DbSeek(xFilial("SD1")+LSF1->LF1_DOC+LSF1->LF1_SERIE+LSF1->LF1_FORNECE+LSF1->LF1_LOJA+LSD1->LD1_COD+LSD1->LD1_ITEM)

				If SD1->D1_EMISSAO == LSF1->LF1_EMISSAO

					RecLock("SD1", .F.)
					SD1->D1_TES := LSD1->LD1_TES
					SD1->D1_CF  := LSD1->LD1_CF
					MsUnlock()

				EndIf

			EndIf

			DbSelectArea("LSD1")
			DbSkip()
		End

		If !lMsErroAuto
			_lGravOK := .T.
		Else
			MostraErro()
			lMsErroAuto := .F.
			DisarmTransaction()
		EndIf
	End Transaction

Return _lGravOK

Static Function CargInfo()

	DbSelectArea("LSD1")
	DbGoTop()
	While !Eof()

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+LSD1->LD1_COD)

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+LSD1->LD1_TES)

		DbSelectArea("LSD1")
		RecLock("LSD1", .F.)

		LSD1->LD1_CONTA   := SB1->B1_CONTA
		LSD1->LD1_DESCRI  := SB1->B1_DESC
//		LSD1->LD1_TES     := SB1->B1_TE
		LSD1->LD1_CF      := SF4->F4_CF

		MsUnlock()
		DbSelectArea("LSD1")
		DbSkip()

	End

Return()

Static Function CarrPrdFor()

	DbSelectArea("LSD1")
	DbGoTop()
	While !Eof()

		DbSelectArea("ZZO")
		DbSetOrder(2)

		If DbSeek(xFilial("ZZO")+LSF1->LF1_FORNEC+LSF1->LF1_LOJA+LSD1->CODPRDFOR)

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+ZZO->ZZO_PRODUT)

			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+SB1->B1_TE)

			DbSelectArea("LSD1")
			RecLock("LSD1", .F.)
			LSD1->LD1_COD := ZZO->ZZO_PRODUT
			LSD1->LD1_TES := SB1->B1_TE
			LSD1->LD1_CF  := SF4->F4_CF
			MsUnlock()

		EndIf

		DbSelectArea("LSD1")
		DbSkip()
	End
Return()

Static Function GravPrdFor()

	DbSelectArea("LSD1")
	DbGoTop()
	While !Eof()

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+LSD1->LD1_COD)

		DbSelectArea("ZZO")
		DbSetOrder(2)

		If DbSeek(xFilial("ZZO")+LSF1->LF1_FORNEC+LSF1->LF1_LOJA+LSD1->CODPRDFOR)
			DbSelectArea("ZZO")
			RecLock("ZZO", .F.)
			ZZO->ZZO_PRODUT := LSD1->LD1_COD
			ZZO->ZZO_NMPROD := SB1->B1_DESC
			MsUnlock()
		Else
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+LSF1->LF1_FORNEC+LSF1->LF1_LOJA)

			DbSelectArea("ZZO")
			RecLock("ZZO", .T.)
			ZZO->ZZO_FILIAL := xFilial("ZZO")
			ZZO->ZZO_FORNEC := LSF1->LF1_FORNEC
			ZZO->ZZO_LOJA   := LSF1->LF1_LOJA
			ZZO->ZZO_NOMEFO := SA2->A2_NOME
			ZZO->ZZO_PRODUT := LSD1->LD1_COD
			ZZO->ZZO_CODPRF := LSD1->CODPRDFOR
			ZZO->ZZO_NMPROD := SB1->B1_DESC
			MsUnlock()
		EndIf

		DbSelectArea("LSD1")
		DbSkip()
	End

Return()

Static Function MoverArq()

	Local cNomeArq  := ""
	Local cPathDest := "C:\XML\OLD\"
	Local cDestino  := ""
	Local nCount    := 0

	cNomeArq := RetFileName(cPathArq)

	cDestino := cPathDest + cNomeArq + ".xml"

	Do While File(cDestino)
		nCount += 1
		cDestino := cPathDest + cNomeArq + "_" + AllTrim(Str(nCount)) + ".xml"
	End

	FRename(cPathArq, cDestino)

Return

Static Function AbrirXML(cFile)
	
	Local cError    := ""
	Local cWarning  := ""
	Local oXml      := Nil
	Local oXml := Nil

	Local oAuxXML   := Nil
	Local nX        := 0
	Local lFound    := .F.

	oXml := XmlParserFile(cPath + cFile, "_", @cError, @cWarning)

	If ValType(oXml) != "O"
		Alert(cFile + " - " + cError)
		Return(Nil)
	Endif

	oAuxXML := oXml

	While !lFound
		oAuxXML := XmlChildEx(oAuxXML,"_NFE")

		If !(lFound := oAuxXML # Nil)

			For nX := 1 To XmlChildCount(oXML)

				oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
				lFound := oAuxXML:_InfNfe # Nil

				If lFound
					oXml := oAuxXML
					Exit
				EndIf
			Next nX
		EndIf
			
		If lFound
			oXml := oAuxXML
			Exit
		EndIf
	EndDo

	If ValType(oXml:_InfNfe:_DET) = "O"
		XmlNode2Arr(oXml:_InfNfe:_DET, "_DET")
	EndIf

Return oXml