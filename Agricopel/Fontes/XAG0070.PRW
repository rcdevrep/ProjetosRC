#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} XAG0070
// Função Utilizada para lançar notas do Processo de Prestação de 
// Contas do DOX
@author Leandro Spiller
@since 21/08/2020
@version 1
@param 
@type function
/*/
User function XAG0070()

	Private cDiretorio := SUPERGETMV('MV_XAG70D', .T., "/XML_DOXPC/")
	Private aRetEmp     := ""
	Private oArqTrbEmp  := Nil
	Private oBrowseEmp  := Nil
	Private aXMLS := Directory(cDiretorio+'*.*'/*, "D"*/)
	Private _lMarcar := .T.
	Private cProdDes   := SUPERGETMV('MV_XAG70P', .T., 'DES52111633    ')
	Private lMsErroAuto := .F.
	Private nTamNota   := 9
	Private nTamCmpNF  := TamSX3("F1_DOC")[1]
	Private nTamCmpSer := TamSX3("F1_SERIE")[1]
	Private nDecTot  := 2//TamSX3("D1_TOTAL")[2]
	Private aEmpresas := {}
	Private cCnpjAtual  
	Private cLogRotina := ""
	Private cPulaLinha := chr(13) + chr(10)
	Private _cAliasTRB := ""
	Private _cEmpAnt := cEmpAnt
	Private _cFilAnt := cFilAnt
	Private _aArea0070 := GetArea()
	Private  _cKeyCopy := SetKey(3, {|| CopiaCHV() })//CTrl + C 
	Private  oXagCon  := XagConexao():New()

	//Busca Cnpj das nossas empresas
	aEmpresas := Empresas()

	//Cria MarkBrowse com os registros
	CriaBrw()
	oArqTrbEmp:Delete()

	cFilAnt := _cFilAnt
	cEmpAnt := _cEmpAnt
	dbCloseAll()
	//RPCClearEnv()
   	OpenSM0() //Abrir Tabela SM0 (Empresa/Filial) 
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DBSEEK(_cEmpAnt+_cFilAnt)) //Restaura Tabela
	OpenFile(_cEmpAnt + _cFilAnt)
	
	//RPCSetEnv(_cEmpAnt,_cFilAnt)
	Restarea(_aArea0070)

	SetKey(3, {||})
	
	//Desconecta DOX
	oXagCon:DescDOX()
Return


//Busca CNPJ de Todas as Empresas
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


//Busca Registros do processo DOX
Static Function BuscaDox(xXMLS)

	Local cQuery 	:= ""
	Local cAlias 	:= 'BUSCADOX'

	cQuery += " SELECT CHAVENFE,trim(CAST(CENTRO_CUSTO AS VARCHAR(10))) AS CCUSTO,a.DATAINICIO,a.IDPROCESSO,a.VALOR,"
	cQuery += " b.XMLANEXADO as XMLNODOX, CAST('' AS VARCHAR(100)) as ARQUIVOXML,  CAST('  ' AS VARCHAR(2)) AS TAB_OK "
	cQuery += " FROM dox_reembolso_viagem  a "
	cQuery += " LEFT JOIN  crm_processo_xml b on (b.chave = a.chavenfe and b.xmlanexado = 'S' ) "
	cQuery += " WHERE   a.STATUS <> 'Cancelado' "
	cQuery += " AND a.CHAVENFE <> '.' AND a.NFE = 'S' "
	cQuery += " AND a.CENTRO_CUSTO <> '.' "
	cQuery += " AND SUBSTRING( CHAVENFE FROM  21 FOR 2 ) = '55' "
	cQuery += " AND a.DATAINICIO > '2020.08.15' "
	cQuery += " AND a.DATAAPROVACAO <> '01/01/1900' "
	cQuery += " order by datainicio  desc "

	//Conecta no DOX
	oXagCon:ConecDOX()
	
	If Select(cAlias) <> 0
		dbSelectArea(cAlias)
		(cAlias)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAlias)  

	//Muda conexão para Protheus
	oXagCon:ConecPRT()//ConPRT()

Return  cAlias

//Cria Arquivo de Trabalho
Static Function CriaArqDOX()

	Local aStruTmp     := {}
	Local oTmpTable    := Nil
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0
	Local _nRecSF1     := 0 
	Local nPosChave    := 0 

	cAliasQry := BuscaDox()

	aStruTmp := (cAliasQry)->(DbStruct())

	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aStruTmp)
	oTmpTable:AddIndex("1", {aStruTmp[1][1]})
	oTmpTable:Create()

	cAliasArea := oTmpTable:GetAlias()

	nFieldCount := (cAliasArea)->(FCount())

	While !(cAliasQry)->(Eof())


		//Busca Chave no Protheus
		_nRecSF1 := BuscaChave(alltrim(BUSCADOX->CHAVENFE))

		//Se não esta lançado, mostra em tela
		If  _nRecSF1 == 0 

			RecLock((cAliasArea), .T.)

			For nX := 1 To nFieldCount
				cFieldName := (cAliasArea)->(FieldName(nX))
				(cAliasArea)->&(cFieldName) := (cAliasQry)->&(cFieldName)
			Next nX

			nPosChave := aScan(aXMLS,{|x| alltrim(BUSCADOX->CHAVENFE) $ Alltrim(x[1])  })

			//Se encontrou a Chave, grava Nome do Arquivo
			If nPosChave > 0 
				(cAliasArea)->&('ARQUIVOXML') := aXMLS[nPosChave][1]
			Endif  
			
			(cAliasArea)->(MsUnlock())
		Endif
		
		(cAliasQry)->(DbSkip())
	End

Return(oTmpTable)  


//Cria MarkBrowse
Static Function CriaBrw()


	Processa({|| oArqTrbEmp := CriaArqDOX()}, "Aguarde, carregando registros", "", .F.)

	oBrowseEmp := FWMarkBrowse():New()
	oBrowseEmp:SetAlias(oArqTrbEmp:GetAlias())
	oBrowseEmp:SetDescription("Importação de Notas do Processo de Prestação de contas DOX - Selecione as Notas para Importar .")
	oBrowseEmp:SetFieldMark("TAB_OK")
	oBrowseEmp:DisableDetails()
	oBrowseEmp:SetTemporary(.T.)
	oBrowseEmp:SetWalkThru(.F.)
	oBrowseEmp:SetIgnoreARotina(.T.)
	oBrowseEmp:SetMenuDef("")
	oBrowseEmp:oBrowse:SetFixedBrowse(.T.)
	oBrowseEmp:oBrowse:SetDBFFilter(.F.)
	oBrowseEmp:oBrowse:SetUseFilter(.F.)
	oBrowseEmp:oBrowse:SetFilterDefault("")
	oBrowseEmp:oBrowse:SetIgnoreARotina(.T.)
	oBrowseEmp:oBrowse:SetMenuDef("")
	oBrowseEmp:SetValid({|| ValMark()})
	oBrowseEmp:SetAllMark({|| AllMark() })
	
	oBrowseEmp:AddButton("Inserir Notas fiscais Selecionadas", {|| Confirmar()},,,, .F., 2 )
	oBrowseEmp:AddButton('Importar arquivo XML para Pasta', {|| salvarXML()},  ,1, )

	//oBrowseEmp:bAllMark := { || CheckAll(oBrowseEmp:Mark() ,lMarcar := !lMarcar), oBrowseEmp:Refresh(.T.)}

	/*CHAVENFE,
	CENTRO_CUSTO,
	a.DATAINICIO,
	a.IDPROCESSO,
	a.VALOR,
	b.XMLANEXADO as XMLNODOX,
	 '' as ARQUIVOXML,
	  '  ' AS TAB_OK */

   	oBrowseEmp:SetColumns(MontaColunas("CHAVENFE"    ,  "Chave"            , 01, ""						 , 1,  44, 0))
	oBrowseEmp:SetColumns(MontaColunas("CCUSTO"	     , "Centro Custo"      , 02 ,""						 , 1,  6 , 0))
	oBrowseEmp:SetColumns(MontaColunas("VALOR"       , "Valor"             , 03 , "@E 999999999999.99"   , 1, 15 , 2))
	oBrowseEmp:SetColumns(MontaColunas("XMLNODOX"    , "Tem xml no Dox? "  , 04, ""						 , 1, 1  , 0))
	oBrowseEmp:SetColumns(MontaColunas("ARQUIVOXML"  , "Arquivo XML Pasta" , 05, ""						 , 1, 100, 0))
	oBrowseEmp:SetColumns(MontaColunas("IDPROCESSO"  ,  "Id Processo"      , 06, ""						 , 1,  9, 0))

	oBrowseEmp:Activate()

Return()


//Função de confirmação
Static function Confirmar()

	Local aAreaTRB  := {} 
	Local cTAB_OK   :=  oBrowseEmp:Mark()
	Local lInseriu  := .F.

	_cAliasTRB := oBrowseEmp:oBrowse:cAlias//oArqTrbEmp:GetAlias()

	aAreaTRB  := (_cAliasTRB)->(GetArea())

	dbSelectArea(_cAliasTRB)
	(_cAliasTRB)->(dbGoTop())

	While !(_cAliasTRB)->(Eof())
		
		//Se tiver marcada Insere Nota 
		If alltrim((_cAliasTRB)->TAB_OK) == cTAB_OK
			lInseriu := .T.
			MsgRun( "Inserindo Chave: "+ (_cAliasTRB)->CHAVENFE ,"Inserindo" ,{||InsereNota()})		
		Endif 
		(_cAliasTRB)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)

	If lInseriu
		If alltrim(cLogRotina) <> ''
			u_msgmemo("LOG",cLogRotina,.f.)
		Else
			u_msgmemo("LOG",'Registros incluídos com Sucesso!',.f.)
		Endif 
	Endif 

	CloseBrowse()
Return .T.


//Insere Nota fiscal 
Static Function InsereNota()

	Local cCGCEmit   := ""
	Local cCGCDest   := ""
	Local _cTipoNF   := "N"
	Local dEmissao   := date()
	Local aItens     := {}
	Local cObs := ""
	Local cCcusto  := ""
	Local cEmitCod := ""
	Local cEmitLoj := ""
	Local cNatFin  := ""
	Local cEstado  := ""
	Local cConPgto := ""
	Local cTpNFe   := ""
	Local nPosEmp  := 0 
	Local cCnpjAtual := SM0->M0_CGC
	Local cRetErro  := ""
	Local cArquivo  := ""
	
	//Varre pastas com XML 
    cArquivo := (_cAliasTRB)->ARQUIVOXML
		
    //Lê xml e Cria NODE
    _oXml := LerXml(cDiretorio+cArquivo)
    
	//Busca Cnpj do Destinatario
	If ValType(XmlChildEx(_oXml:_nfeProc:_NFe:_infNFe:_dest, "_CNPJ")) <> "U"
		cCGCDest := AllTrim(_oXml:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:Text)
	Else
		cCGCDest := AllTrim(_oXml:_nfeProc:_NFe:_infNFe:_dest:_CPF:Text)
	EndIf

	cChave := _oXml:_Nfeproc:_protnfe:_infProt:_chNFe:Text

	//Valida se Precisa mudar de empresa
	If cCnpjAtual <> cCGCDest
		nPosEmp := aScan(aEmpresas,{|x|Alltrim(x[1])==cCGCDest})

		//Se encontrou Abre a Empresa
		if nPosEmp > 0 
			cCnpjAtual  :=  aEmpresas[nPosEmp][1]
			cEmpAnt 	:=  aEmpresas[nPosEmp][2]
			cFilAnt 	:=  aEmpresas[nPosEmp][3]	

			OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
			dbSelectArea("SM0") //Abro a SM0
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt + cFilAnt,.T.)) //Posiciona Empresa
			OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar

		Else 
			cObs       := ' Não foi emitida contra um CNPJ da Agricopel('+ cCGCDest +')'
			cLogRotina += "("+cEmpAnt+'-'+cFilAnt+")Chave "+ cChave +" com problemas, verifique: "+cObs + cPulaLinha
			//MsgInfo(cArquivo + ' Não foi emitida contra um CNPJ da Agricopel('+ cCGCDest +')','Cnpj de Destino inválido')
			Return
		Endif
		
		//RPCClearEnv()
		//RPCSetEnv(cEmpAnt,cFilAnt)
	
	
	Endif 
		
	//nPosCC := aScan(aCCxChave,{|x|Alltrim(x[1])==cChave})

	//Se encontrou Centro de Custo
	If alltrim((_cAliasTRB)->CCUSTO) <> ''  
		cCcusto  :=  alltrim((_cAliasTRB)->CCUSTO)
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
			cObs += "Fornecedor não encontrado CPF/CNPJ: "+cCGCEmit
		Endif		
	Else

		cObs := "Nota de Devolução não pode ser lançada "
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
			cObs += "Cliente não encontrado CPF/CNPJ: "+cCGCEmit
		EndIf
	EndIf

	cNumNF   := Right(IIf(Len(_oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text) >= nTamNota, _oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, PadL(_oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, nTamNota, "0")), nTamCmpNF)
	cSerieNF := PadR(_oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text, nTamCmpSer)

	//Verfica se a nota Existe 
	If cObs == ""
		SF1->( dbSetOrder(1) )
		If SF1->( dbSeek(xFilial("SF1") + cNumNF + cSerieNF + cEmitCod + cEmitLoj) )
			//AddErroXml(cArquivo, "- Já existe Nota Fiscal no sistema com a chave de número: " + AllTrim(cNumNF) + " e série: " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text) + " para o fornecedor: " + AllTrim(cEmitCod) + "/" + cEmitLoj + ".")
			cObs := "Notá Já Existe no Protheus"
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
			cObs := "Não existe TES: "+SB1->B1_TE 
		EndIf
	Endif

	//lLancar := .f.

	//Se nao tiver Erros Grava Dados 
	If alltrim(cObs) == "" //.and. lLancar
		
		lCHVNFEOLD := GetMv('MV_CHVNFE')
		//Caso Seja uma Nota com mais de 6 meses Altera parametro MV_CHVNFE
		If (dDatabase - dEmissao) > 170 
			
			If lCHVNFEOLD
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
		
		//Se alterou a Verificação do sefaz volta
		If lCHVNFEOLD <> GetMv('MV_CHVNFE')
			PUTMV('MV_CHVNFE', lCHVNFEOLD)
		Endif
		
		If lMsErroAuto
			cRetErro  := MostraErro("/dirdoc", "error.log")
			//Alert('ERRO EXECAUTO!')
		//Else
			cObs := cRetErro
		Endif
	

	Endif 
	// {"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil},;

	//Erro 
	if 	Alltrim(cObs) <> ''
		cLogRotina += "("+cEmpAnt+'-'+cFilAnt+")Chave "+ cChave +" com problemas, verifique: "+cObs + cPulaLinha
		//MsgInfo("Chave "+ cChave +" com problemas, verifique: "+cObs,cTitulo)
	Endif  

Return 


//Monta colunas do Browse
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal,nTipo)

	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowseEmp:DataArray[oBrowseEmp:At(),"+STR(nArrData)+"]}")
	EndIf

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return({aColumn})


Static Function BuscaChave(xChave)

	Local cAliasCHV := GetNextAlias()//"BUSCACHAVE"
	Local cQueryCHV := ""
	Local nRet      := 0 

	cQueryCHV := " SELECT R_E_C_N_O_ AS RECNO FROM "+RetSqlName('SF1')+"(NOLOCK) "
	cQueryCHV += " WHERE F1_CHVNFE = '"+xChave+"' AND D_E_L_E_T_ = '' "

	If Select(cAliasCHV) <> 0
		dbSelectArea(cAliasCHV)
		(cAliasCHV)->(dbclosearea())
	Endif   
	
	TCQuery cQueryCHV NEW ALIAS (cAliasCHV) 
	
	If (cAliasCHV)->(!eof())
		nRet := (cAliasCHV)->(RECNO)
	Endif 

	(cAliasCHV)->(dbclosearea())

Return nRet


//Valida se tem Xml na pasta 
Static Function ValMark()

	Local lRet := .F.

	//Se tem arquivo Xml Deixa Marcar
	If alltrim((oBrowseEmp:oBrowse:cAlias)->ARQUIVOXML) <> ""
		lRet := .T.
	Else
		MsgInfo('Só é possível marcar registros que contenham Arquivo XML!! ','Aviso')
	Endif 

Return lRet


//Valida se tem Xml na pasta 
Static Function AllMark()

	//Local _cAliasTRB := oBrowseEmp:oBrowse:cAlias//oArqTrbEmp:GetAlias()
	Local aAreaTRB  := {} 
	Local cTAB_OK   := IIf(_lMarcar, oBrowseEmp:Mark(), '  ')

	If alltrim(_cAliasTRB) == ''  
		_cAliasTRB := oBrowseEmp:oBrowse:cAlias
	Endif 

	aAreaTRB  := (_cAliasTRB)->(GetArea())

	dbSelectArea(_cAliasTRB)
	(_cAliasTRB)->(dbGoTop())

	While !(_cAliasTRB)->(Eof())
		
		If alltrim((_cAliasTRB)->ARQUIVOXML) <> ""
			RecLock((_cAliasTRB), .F.)
			(_cAliasTRB)->TAB_OK := cTAB_OK
			MsUnlock()
		Endif 
		(_cAliasTRB)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)

	_lMarcar := !_lMarcar
	oBrowseEmp:Refresh(.T.)
Return 


//Ler xml e Criar NODE
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


//Salvar Xml na Pasta
Static Function SalvarXML()

	Local lSalvar   := .F. 
    Local nOpcoes   := GETF_MULTISELECT + GETF_LOCALHARD  //GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_RETDIRECTORY//GETF_LOCALHARD+GETF_NOCHANGEDIR 
    Local ctargetDir
   	Local cEntFile 	:= "C:\"//"\XML_DOXPC\"
	Local cDestino  := StrTran( cDiretorio, "/", "\" )
	Local aArquivos := {}
	Local y         := 0 
	Local _cChave   := ""
	Local _cArquivo := ""

	If _cAliasTRB == ""
		_cAliasTRB := oBrowseEmp:oBrowse:cAlias
	Endif 

   	cEntFile    := alltrim( IIf(SubStr(AllTrim(cEntFile), Len(AllTrim(cEntFile)), 1) == "\", PadR(cEntFile, 200), PadR(AllTrim(cEntFile) + "\", 200)) )

 	MsgInfo(" Na Próxima tela você deverá selecionar todos os Xmls que deseja enviar para a Pasta de importação,"+;
			" o Nome do Arquivo precisa possuir os primeiros 44 caracteres iguais a sua Chave, dessa forma eles ficarão disponiveis para Inclusão no sistema","Importar XML")

	 //cEntFile := cProcFile
   	ctargetDir :=  AllTrim(cGetFile("Arquivos XML|*.XML", "Importar XML", 0,cEntFile/*"C:\XML"*/, lSalvar,nOpcoes,.T.))

	
	If !Empty(ctargetDir)

		//Copia arquivos selecionados para Diretorio de Importação
		aArquivos := Separa(ctargetDir,' | ',.f.)
		//Varre Arquivos Selecionados e Grava na Pasta de destino 
		For y := 1 to len(aArquivos)
			CpyT2S( aArquivos[y], cDestino/*"\IMPBOLETO"*/, .F. )
			_cArquivo := Substr( aArquivos[y],RAT('\',aArquivos[y])+1,199)
			_cChave     = Substr(StrTran(_cArquivo,'.xml','',/*nStart*/,/*nCount*/),1,44)
	
			//Busca a chave no
			DbSelectarea(_cAliasTRB)
			(_cAliasTRB)->(Dbgotop())
			If dbSeek(_cChave)
				Reclock(_cAliasTRB,.F.)
					(_cAliasTRB)->ARQUIVOXML := _cArquivo//aArquivos[y]
				(_cAliasTRB)->(Msunlock())
			Endif 
		Next y 

	Else

		MsgInfo("Nenhum Arquivo Selecionado! ","Salvar XML")
	
	Endif	

	oBrowseEmp:Refresh(.T.)
Return 


//Copia Chave para Clipboard
Static Function CopiaCHV()

	If _cAliasTRB == ""
		_cAliasTRB := oBrowseEmp:oBrowse:cAlias
	Endif 

	CopytoClipboard ( (_cAliasTRB)->CHAVENFE ) 

Return

/* 
//Tabela que é lida pela View
 SELECT * FROM pex_reembolso
 UPDATE pex_reembolso set NFE  = 'N'
 WHERE idprocesso =   428050
 AND CHAVENFE = '41200831496230000117550010000021371487895710'

//tabela do Processo apenas para consulta
--SELECT VALORATUAL  FROM crm_processo_variavel
--WHERE 
--idprocesso = 428050
--AND descricao like '%COMPROVANTE.NFE%'
*;