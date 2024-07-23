#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "MSMGADD.CH"

#DEFINE GOLOG_DISABLED "1"
#DEFINE GOLOG_INFO "2"
#DEFINE GOLOG_DEBUG "3"
#DEFINE GOLOG_CONSOLE "4"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GOX001   ºAutor  ³Octávio A. F. Macedoº Data ³  15/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa importador de NF-e e CT-e                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Genérico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// Manter a chamada do antigo Importador Gerencial
User Function GOX001()
	
	U_GOX008()
	
Return

////////////////////////////////////////

Static Function SetFieldsBrowse(oBrowse)

	Local aFields := {}
	Local aNotCol := {_cCmp1 + "_DSEVEN"}
		
	dbSelectArea("SX3")
	SX3->( dbSetOrder(1) )
	SX3->( dbSeek(_cTab1) )
	
	While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab1
	
		If SX3->X3_BROWSE == "S" .And. AScan(aNotCol, {|x| x == AllTrim(SX3->X3_CAMPO)}) == 0 
		
			AAdd(aFields, AllTrim(SX3->X3_CAMPO))
			
		EndIf
		
		SX3->( dbSkip() )
		
	EndDo
	
	oBrowse:SetOnlyFields(aFields)
	
Return

//-----------------

User Function GOX1IMP(cTab, lRetorna, lClass, lPreN)
	
	Local aRetCF
	
	Default lRetorna := .F.
	Default lClass   := .F.
	Default lPreN    := .F.
	
	Private lPreNota := lPreN
	
	//Variáveis de posição dos campos - Tab2
	Private _nPosItXml  // *_DESC     -  Item XML
	Private _nPosPedid  // *_PEDIDO   -  Pedido
	Private _nPosItePc  // *_ITEMPC   -  Item PC
	Private _nPosProdu  // *_COD      -  Produto
	Private _nPosDcPrd  // *_DSPROD   -  Desc Produto
	Private _nPosNcm    // *_NCM      -  NCM
	Private _nPosUm     // *_UM       -  Nossa UM
	Private _nPosUmFor  // *_UM       -  UM Fornec
	Private _nPosQtdFr  // *_QUANT1   -  vQtde.Fornec.
	Private _nPosQtdNo  // *_QUANT2   -  Nossa Qtde.
	Private _nPosVlUnt  // *_VUNIT    -  Valor Unit.
	Private _nPosVlTot  // *_TOTAL    -  Valor Total
	Private _nPosTes    // *_TES      -  TES
	Private _nPosCdFis  // *_CF       -  Cod.Fiscal
	Private _nPosConta  // *_CONTA    -  Conta Contábil
	Private _nPosCtCus  // *_CC       -  Centro Custo
	Private _nPosItCon  // *_ITEMCTA  -  Item Conta
	Private _nPosClVal  // *_CLVL     -  Classe Valor
	Private _nPosBsIcm  // *_BASEIC   -  Base ICMS
	Private _nPosAqIcm  // *_PICM     -  Aliq. ICMS
	Private _nPosVlIcm  // *_VALICM   -  Vl. ICMS
	Private _nPosBsIpi  // *_BASEIP   -  Base IPI
	Private _nPosAqIpi  // *_IPI      -  Aliq. IPI
	Private _nPosVlIpi  // *_VALIPI   -  Vl. IPI
	Private _nPosStTri  // *_CLASFI   -  Sit.Trib.
	Private _nPosCSOSN
	Private _nPosDescX   // *_DESCTO   -  Desconto
	Private _nPosNFOri
	Private _nPosSerOr
	Private _nPosItOri
	Private _nPosVlFrt
	
	Private _nPosBsISt
	Private _nPosPIcSt
	Private _nPosVlISt
	
	Private _nPosBsStA
	Private _nPosPStA
	Private _nPosVlStA
	
	Private _nPosVlAnt

	Private _nPosLote
	Private _nPosDtFab
	Private _nPosDtVld
	Private _nPosFciCd
	
	Private aXmlDup
	
	Private oXml
	
	Private oLancApICMS
	
	Begin Sequence
	
		Do Case
		
			Case cTab == "NFE"
				
				oXml := XmlParser((_cTab1)->&(_cCmp1 + "_XML"), "_", @cError, @cWarning)
				
				If Empty(oXml)
					
					//aRet[1] := .F.
					//aRet[2] := "Processo de importação abortado devido a falha de leitura do Xml. Erro : " + cError
					U_GOSetEr("Processo de importação abortado devido a falha de leitura do Xml. Erro : " + cError)
					
					Break
					
				EndIf
				
				// Verifica liberação
				
				If lUsaLib .And. (_cTab1)->&(_cCmp1 + "_LIBER") # "1"
					
					U_GOSetEr("O XML está pendente de liberação do setor responsável. Não será permitida importação.")
					
					Break
					
				EndIf
				
				// Verifica o tipo de nota pelo CFOP 
				// (Retirado, pois, o usuário pode selecionar em tela e já virá modificado no campo _TIPOEN)
				
				// COLOCAR AQUI A CRIAÇÃO DA AMARRAÇÃO DE CFOP
				
				aRetCF := VldCFOPNF(.T.)
				
				If aRetCF[2]
					
					//aRet[1] := .F.
					//aRet[2] := aRetCF[3]
					
					RecLock(_cTab1, .F.)
						(_cTab1)->&(_cCmp1 + "_SIT") := "4"
						(_cTab1)->&(_cCmp1 + "_ERRO") := aRetCF[3]
					(_cTab1)->( MSUnlock() )
					
					Break
					
				EndIf
				
				RelacCFOP(oXml, (_cTab1)->&(_cCmp1 + "_TIPOEN"), lRetorna, (_cTab1)->&(_cCmp1 + "_TPCOMP"))
				
				// Salva numa variável private o valor o array de Duplicatas da nota, se houver.
				
				aXmlDup := GetNodeNFe(oXml, "_infNFe:_cobr:_dup")
				
				If ValType(aXmlDup) == "O"
					
					aXmlDup := {aXmlDup}
					
				EndIf
				
				//--------------------------------------
				
				If ((_cTab1)->&(_cCmp1 + "_DTCRIA") - (_cTab1)->&(_cCmp1 + "_DTEMIS")) >= 180
					
					If Aviso("Limite de tempo de consulta", "O seguinte XML de número " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " foi enviado ao e-mail do fiscal depois de 180 dias de sua emissão, impossibilitando a consulta para verificar seu status de autorizada. Confirme no portal da SEFAZ a autorização do Documento!!!", {"Confirmar", "Abortar"}, 2) # 1
						
						U_GOSetEr("Cancelado pelo Usuário importação de nota emitida há mais de 180 dias.")
						
						Break
						
					EndIf
					
				EndIf
				
				If lRetorna
					
					Inclui := .T. // Pois não é chamado de menu de Browse que cria a variável.
					
					U_GORetorn(_cTab1, (_cTab1)->( RecNo() ), 3)
					
				ElseIf lClass
					
					// Classificar Nota, chamar a rotina padrão da totvs de classificar!
					
					// Salva numa variável private o valor o array de Duplicatas da nota, se houver.
					
					aXmlDup := GetNodeNFe(oXml, "_infNFe:_cobr:_dup")
					
					If ValType(aXmlDup) == "O"
						
						aXmlDup := {aXmlDup}
						
					EndIf
					
					ImpClassNf()
					
				ElseIf lPreNota .And. (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "I;P;C"
					
					//aRet[1] := .F.
					//aRet[2] := "Somente é possível importar pré-notas para os tipos 'Normal', 'Devolução', 'Beneficiamento'."
					U_GOSetEr("Somente é possível importar pré-notas para os tipos 'Normal', 'Devolução', 'Beneficiamento'.")
					
					Break
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "I;P;C"
				
					ImportNFeC()
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B"
				
					ImportNFeD()
					
				ElseIf (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "N"
					
					ImportarNFe()
					
				EndIf
				
			Case cTab == "CTE"
				
				ImportaCTe()
				
			Case cTab == "NFS" // Nota Fiscal de Serviço
				
				oXml := XmlParser((_cTab1)->&(_cCmp1 + "_XML"), "_", @cError, @cWarning)
				
				If Empty(oXml)
					
					U_GOSetEr("Processo de importação interrompido devido a falha de leitura do Xml. Erro : " + cError)
					
					Break
					
				EndIf
				
				ImportarNFe()
				
			Case cTab == "INC" // Reprocessamento das inconsistências
				
				U_GOCargaX(((_cTab1)->&(_cCmp1 + "_TIPO") == "5"), .T.)
				
		EndCase
		
	End Sequence
	
	oXml := Nil
	DelClassIntf()
	
Return

////////////////////////////////////////

Static Function GetFilterXml(cSit)
	
	Local cFilter := _cTab1 + "->" + _cCmp1 + "_FILIAL == '" + cFil + "' "
	Local aSit    := StrTokArr(cSit, ";")
	Local nI
	
	For nI := 1 To Len(aSit)
		
		If nI == 1
			
			cFilter += ".And. ("
			
		Else
			
			cFilter += ".Or."
			
		EndIf
		
		cFilter += " " + _cTab1 + "->" + _cCmp1 + "_SIT == '" + aSit[nI] + "'"
		
		If nI == Len(aSit)
			
			cFilter += ")"
			
		EndIf
		
	Next nI
	
	cFilter += ".And. (" + _cTab1 + "->" + _cCmp1 + "_TIPO == '1' .Or. " + _cTab1 + "->" + _cCmp1 + "_TIPO == '2' .Or. " + _cTab1 + "->" + _cCmp1 + "_TIPO == '6')"
	
Return cFilter

User Function GOCargaX(lCancel, lReproc, cXMLMan, cParProv)
	
	Local cXml
	Local aRetXml
	Local nXmlImp  := 0
	Local aAux
	Local aArqAux
	Local cTxtCan
	Local aTxtCan
	Local lOK      := .T.
	Local lManual  := .F.

	Local cXmlAux  := ""

	Local nI
	
	Local aInfoEmi
	
	Default cParProv := ""

	///Variáveis de preenchimento da tabela _cTab1 com informações do XML
	Private lNFServ   := !Empty(cParProv)
	Private cProvedor := cParProv
	Private cNumNF    := ""
	Private cSerNFS   := ""
	Private dNFSEmis  := CToD("  /  /    ")
	Private nValTotIt := 0
	Private nValTotNFS:= 0
	Private cNumCTe   := ""
	Private cEmitCod  := ""
	Private cEmitLoj  := ""
	Private cTpNFe    := ""
	Private cTpCompNF := ""
	Private cNatFin   := ""
	Private cEstado   := ""
	Private cConPgto  := ""
	Private cEvtoDoc  := ""
	Private cEvtoSer  := ""
	Private cEvtoCNPJ := ""
	Private cEvtoTp   := ""
	Private cCanSit   := "1"
	Private cNFeSit   := "1"
	Private cCTeSit   := "1"
	Private cCgcEmit  := ""
	Private cCgcDest  := ""
	Private lSerie    := .T.
	Private cTipoEnt  := ""
	Private lXmlIgnor := .F.
	Private cErroXML  := ""
	Private lVldErro  := .F.
	Private cLiber    := "1"
	
	Private cInfErroC := ""
	Private lXmlErro  := .F.
	Private cChaveCan := ""
	
	Private cChvNfsMan := ""

	Default lCancel   := .F.
	Default lReproc   := .F.
	Default cXMLMan   := ""
	
	Private oXml
	
	cRetBxXML := ""
	
	If !Empty(cXMLMan)
		
		lManual := .T.
		
	EndIf

	If !lReproc .And. !lManual
	
		//Verificação para Nota Fiscal de Serviço
		
		If !Empty(cParProv) .Or. (Empty(cParProv) .And. SubStr(oCabXml:CCHAVE, 21, 2) == "99")

			lNFServ   := .T.

			If oCabXml:RequestNFSeXML()
			
				If Empty(oCabXML:oWSRequestNFSeXMLResult:cdocumento)
					
					cInfErroC := cRetBxXML := " XML não existente, verifique se ele realmente foi emitido contra a filial em questão."
					
					Return .F.
					
				EndIf

				cXmlAux := oCabXML:oWSRequestNFSeXMLResult:cdocumento

				If Empty(cProvedor)

					cProvedor := Upper(oCabXML:oWSRequestNFSeXMLResult:cprovedor)

				EndIf

			EndIf

		ElseIf oCabXml:RequestXML()
			
			If Empty(oCabXML:CREQUESTXMLRESULT)
				
				cInfErroC := cRetBxXML := " XML não existente, verifique se ele realmente foi emitido contra a filial em questão."
				
				Return .F.
				
			EndIf

			cXmlAux := oCabXML:CREQUESTXMLRESULT

		EndIf
		
	EndIf
	
	cError    := ""
	cWarning  := ""
	lSerie    := .T.
	lXmlIgnor := .F.
	
	oXml := Nil
	
	If lManual
		
		cXml := cXMLMan
		
	Else
		
		cXml := IIf(lReproc, (_cTab1)->&(_cCmp1 + "_XML"), cXmlAux)
		
	EndIf
	
	If Empty(cXml)
		
		cInfErroC := cRetBxXML := " Não foi possível obter o conteúdo do XML. Erro: " + GetWSCError()
		
		Return .F.
		
	EndIf
	
	/*If lNFServ //Tratamento de erro de XML de serviço vindo sem o > ao final

		cXml := AllTrim(cXml)

		If Right(AllTrim(cXml), 1) # ">"

			cXml := cXml + ">"

		EndIf

	EndIf*/

	oXml := XmlParser(cXml, "_", @cError, @cWarning)
	
	Begin Sequence
	
		If !Empty(oXml)
			
			//////////////////////////////////////// Validações
			If !lCancel .And. Type("oXml:_nfeProc:_NFe") == "O" // Nota Fiscal
				
				ValidaNFe(lReproc)
				
			ElseIf !lCancel .And. (Type("oXml:_cteProc") == "O" .Or. Type("oXml:_cteOSProc") == "O") //Conhecimento de Transporte ou Conhecimento de Transporte de Ourtos Serviços
				
				ValidaCTe(lReproc)
				
			ElseIf lCancel
				
				ValidaCan(lReproc)
				
			ElseIf lNFServ
				
				ValidaNFS(lReproc, lManual)
				
			Else
				
				AddIncXml("O Xml não possui estrutura correta para nenhum tipo de documento aceito (NF-e, CT-e, Cancelamento). O Fornecedor pode ter enviado em um formato inválido.")
				lOK := .F.
				
			EndIf
			
			If lXmlIgnor
				
				lOK := .F.
				Break
				
			EndIf
			
			If lXmlErro .And. !lReproc
				
				If !lManual
					
					dbSelectArea(_cTab1)
					(_cTab1)->( dbSetOrder(1) )
					If !(_cTab1)->( dbSeek(oCabXml:CCHAVE + "3") )
						
						RecLock(_cTab1, .T.)
							
							(_cTab1)->&(_cCmp1 + "_FILIAL") := xFilial("SF1")
							(_cTab1)->&(_cCmp1 + "_SEQIMP") := GetSXENUM(_cTab1, _cCmp1 + "_SEQIMP",, 6)
							(_cTab1)->&(_cCmp1 + "_SIT")    := "7"
							(_cTab1)->&(_cCmp1 + "_TIPO")   := "3" // Erro de XML
							(_cTab1)->&(_cCmp1 + "_CHAVE")  := oCabXml:CCHAVE
							(_cTab1)->&(_cCmp1 + "_DTCRIA") := Date()
							(_cTab1)->&(_cCmp1 + "_HRCRIA") := Time()
							(_cTab1)->&(_cCmp1 + "_HRIMP")  := Time()
							(_cTab1)->&(_cCmp1 + "_USUCRI") := cUserName
							(_cTab1)->&(_cCmp1 + "_ERRO")   := cInfErroC
							(_cTab1)->&(_cCmp1 + "_XML")    := cXml
							
						(_cTab1)->( MsUnlock() )
						
						ConfirmSX8()
					
					EndIf
					
				EndIf
				
				lOK := .F.
				Break
				
			ElseIf !lXmlErro .And. !lReproc
				
				If !lManual
					
					dbSelectArea(_cTab1)
					(_cTab1)->( dbSetOrder(1) )
					If (_cTab1)->( dbSeek(oCabXml:CCHAVE + "3") )
						
						RecLock(_cTab1, .F.)
							
							dbDelete()
							
						(_cTab1)->( MsUnlock() )
						
					EndIf
					
				EndIf
				
			EndIf
			
			//////////////////////////////////////// Fim Validações
			
			If lVldErro
				
				cNFeSit := cCTeSit := cCanSit := "6"
				
			EndIf
			
			nXmlImp++
			
			If !lCancel .And. Type("oXml:_nfeProc") == "O" // Nota Fiscal de Entrada
				
				RecLock(_cTab1, IIf(lReproc, .F., .T.))
				
					(_cTab1)->&(_cCmp1 + "_FILIAL") := xFilial("SF1")
					If !lReproc
						(_cTab1)->&(_cCmp1 + "_SEQIMP") := GetSXENUM(_cTab1, _cCmp1 + "_SEQIMP",, 6)
					EndIf
					(_cTab1)->&(_cCmp1 + "_DOC")    := cNumNF
					
					// Limpa a Série
					If lxgtLSer .And. !lSerie
					
						(_cTab1)->&(_cCmp1 + "_SERIE") := ""
						
					Else
						
						If GetNewPar("MV_ZGOSERP", .F.)
							
							(_cTab1)->&(_cCmp1 + "_SERIE") := PadL(AllTrim(oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text), TamSX3("F1_SERIE")[1], "0")
							
						Else
						
							(_cTab1)->&(_cCmp1 + "_SERIE") := oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text
							
						EndIf
						
					EndIf
					
					(_cTab1)->&(_cCmp1 + "_CGCEMI") := cCGCEmit
					(_cTab1)->&(_cCmp1 + "_CGCDES") := cCGCDest
					(_cTab1)->&(_cCmp1 + "_DTEMIS") := CToD(SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 9, 2) + "/" + SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 6, 2) + "/" + SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 1, 4))
					(_cTab1)->&(_cCmp1 + "_NATOP")  := oXml:_nfeProc:_NFe:_infNFe:_ide:_natOp:Text
					(_cTab1)->&(_cCmp1 + "_TOTVAL") := Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vNF:Text)
					(_cTab1)->&(_cCmp1 + "_TOTITE") := Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vProd:Text)
					(_cTab1)->&(_cCmp1 + "_TOTIPI") := Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vIPI:Text)
					(_cTab1)->&(_cCmp1 + "_TOTICM") := Val(oXml:_nfeProc:_NFe:_infNFe:_total:_ICMSTot:_vICMS:Text)
					(_cTab1)->&(_cCmp1 + "_CODEMI") := cEmitCod
					(_cTab1)->&(_cCmp1 + "_LOJEMI") := cEmitLoj
					(_cTab1)->&(_cCmp1 + "_EST")    := cEstado
					(_cTab1)->&(_cCmp1 + "_NATFIN") := cNatFin
					(_cTab1)->&(_cCmp1 + "_CONDPG") := cConPgto
					(_cTab1)->&(_cCmp1 + "_TIPOEN") := cTpNFe
					
					(_cTab1)->&(_cCmp1 + "_TPCOMP") := cTpCompNF
						
					(_cTab1)->&(_cCmp1 + "_LIBER") := cLiber
					
					(_cTab1)->&(_cCmp1 + "_XML")    := cXml
					(_cTab1)->&(_cCmp1 + "_SIT")    := cNFeSit
					(_cTab1)->&(_cCmp1 + "_TIPO")   := "1"
					(_cTab1)->&(_cCmp1 + "_CHAVE")  := Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44)
					(_cTab1)->&(_cCmp1 + "_DTCRIA") := Date()
					(_cTab1)->&(_cCmp1 + "_HRCRIA") := Time()
					(_cTab1)->&(_cCmp1 + "_USUCRI") := cUserName
					(_cTab1)->&(_cCmp1 + "_ERRO")   := cErroXML
					
					If (_cTab1)->( FieldPos(_cCmp1 + "_CIDINI") ) > 0
						
						aInfoEmi := U_CliForGO(cCGCEmit)
						
						(_cTab1)->&(_cCmp1 + "_CIDINI") := GFE065RUF(aInfoEmi[5], 1) + AllTrim(aInfoEmi[10]) //Replicate("0", 7)
						(_cTab1)->&(_cCmp1 + "_CIDFIM") := SM0->M0_CODMUN //Replicate("0", 7)
						
					EndIf
					
				(_cTab1)->( MsUnlock() )
				
				If !lReproc
					
					ConfirmSX8()
					
					GeraCplVen()
					
				EndIf
				
			ElseIf !lCancel .And. (Type("oXml:_cteProc") == "O" .Or. Type("oXml:_cteOSProc") == "O")
			
				aAux := XmlCteIcms(oXml)
				
				RecLock(_cTab1, IIf(lReproc, .F., .T.))
				
					(_cTab1)->&(_cCmp1 + "_FILIAL") := xFilial("SF1")
					If !lReproc
						(_cTab1)->&(_cCmp1 + "_SEQIMP") := GetSXENUM(_cTab1, _cCmp1 + "_SEQIMP",, 6)
					EndIf
					(_cTab1)->&(_cCmp1 + "_DOC")    := cNumCTe
					
					If GetNewPar("MV_ZGOSERP", .F.)
						
						(_cTab1)->&(_cCmp1 + "_SERIE") := PadL(AllTrim(GetNodeCte(oXml, "_infCte:_ide:_serie:Text")), TamSX3("F1_SERIE")[1], "0")
						
					Else
					
						(_cTab1)->&(_cCmp1 + "_SERIE")  := GetNodeCte(oXml, "_infCte:_ide:_serie:Text") //:_cteProc:_CTe:_infCte:_ide:_serie:Text
						
					EndIf
					
					(_cTab1)->&(_cCmp1 + "_CGCEMI") := cCGCEmit
					(_cTab1)->&(_cCmp1 + "_CGCDES") := cCGCDest
					(_cTab1)->&(_cCmp1 + "_DTEMIS") := CToD(SubStr(GetNodeCTe(oXml, "_infCTe:_ide:_dhEmi:Text"), 9, 2) + "/" + SubStr(GetNodeCTe(oXml, "_infCTe:_ide:_dhEmi:Text"), 6, 2) + "/" + SubStr(GetNodeCTe(oXml, "_infCTe:_ide:_dhEmi:Text"), 1, 4))
					(_cTab1)->&(_cCmp1 + "_NATOP")  := GetNodeCTe(oXml, "_infCte:_ide:_natOp:Text")
					(_cTab1)->&(_cCmp1 + "_TOTVAL") := Val(GetNodeCTe(oXml, "_infCte:_vPrest:_vTPrest:Text"))
					(_cTab1)->&(_cCmp1 + "_TOTICM") := aAux[4]
					(_cTab1)->&(_cCmp1 + "_TRIB")   := aAux[1]
					(_cTab1)->&(_cCmp1 + "_CODEMI") := cEmitCod
					(_cTab1)->&(_cCmp1 + "_LOJEMI") := cEmitLoj
					(_cTab1)->&(_cCmp1 + "_EST")    := cEstado
					(_cTab1)->&(_cCmp1 + "_NATFIN") := cNatFin
					(_cTab1)->&(_cCmp1 + "_CONDPG") := cConPgto
					(_cTab1)->&(_cCmp1 + "_XML")    := cXml
					(_cTab1)->&(_cCmp1 + "_TIPOEN") := cTipoEnt
					(_cTab1)->&(_cCmp1 + "_SIT")    := cCTeSit
					(_cTab1)->&(_cCmp1 + "_TIPO")   := "2"
					(_cTab1)->&(_cCmp1 + "_CHAVE")  := Right(GetNodeCTe(oXml, "_infCTe:_Id:Text"), 44)
					(_cTab1)->&(_cCmp1 + "_DTCRIA") := Date()
					(_cTab1)->&(_cCmp1 + "_HRCRIA") := Time()
					(_cTab1)->&(_cCmp1 + "_USUCRI") := cUserName
					(_cTab1)->&(_cCmp1 + "_ERRO")   := cErroXML
					(_cTab1)->&(_cCmp1 + "_LIBER")  := cLiber
					
					If (_cTab1)->( FieldPos(_cCmp1 + "_CIDINI") ) > 0 .And. IsNodeCTe(oXml, "_infCte:_ide:_cMunIni")
						(_cTab1)->&(_cCmp1 + "_CIDINI") := GetNodeCte(oXml, "_infCte:_ide:_cMunIni:Text")
						(_cTab1)->&(_cCmp1 + "_CIDFIM") := GetNodeCte(oXml, "_infCte:_ide:_cMunFim:Text")
					EndIf
					
				(_cTab1)->( MsUnlock() )
				
				If !lReproc
					
					ConfirmSX8()
					
				EndIf
			
			ElseIf lNFServ
				
				RecLock(_cTab1, IIf(lReproc, .F., .T.))
				
					(_cTab1)->&(_cCmp1 + "_FILIAL") := xFilial("SF1")
					If !lReproc
						(_cTab1)->&(_cCmp1 + "_SEQIMP") := GetSXENUM(_cTab1, _cCmp1 + "_SEQIMP",, 6)
					EndIf
					(_cTab1)->&(_cCmp1 + "_DOC")    := cNumNF
					
					If GetNewPar("MV_ZGOSERP", .F.)
						
						(_cTab1)->&(_cCmp1 + "_SERIE") := PadL(AllTrim(cSerNFS), TamSX3("F1_SERIE")[1], "0")
						
					Else
					
						(_cTab1)->&(_cCmp1 + "_SERIE")  := cSerNFS
						
					EndIf 
					
					(_cTab1)->&(_cCmp1 + "_CGCEMI") := cCGCEmit
					(_cTab1)->&(_cCmp1 + "_CGCDES") := cCGCDest
					(_cTab1)->&(_cCmp1 + "_DTEMIS") := dNFSEmis 
					(_cTab1)->&(_cCmp1 + "_NATOP")  := "NOTA FISCAL DE SERVIÇO" // Confirmar
					(_cTab1)->&(_cCmp1 + "_TOTVAL") := nValTotNFS // Criar
					(_cTab1)->&(_cCmp1 + "_TOTITE") := nValTotIt // Criar
					(_cTab1)->&(_cCmp1 + "_CODEMI") := cEmitCod
					(_cTab1)->&(_cCmp1 + "_LOJEMI") := cEmitLoj
					(_cTab1)->&(_cCmp1 + "_EST")    := cEstado
					(_cTab1)->&(_cCmp1 + "_NATFIN") := cNatFin
					(_cTab1)->&(_cCmp1 + "_CONDPG") := cConPgto
					(_cTab1)->&(_cCmp1 + "_TIPOEN") := cTpNFe
						
					(_cTab1)->&(_cCmp1 + "_LIBER") := cLiber
					
					(_cTab1)->&(_cCmp1 + "_XML")    := cXml
					(_cTab1)->&(_cCmp1 + "_SIT")    := cNFeSit
					(_cTab1)->&(_cCmp1 + "_TIPO")   := "6"
					(_cTab1)->&(_cCmp1 + "_CHAVE")  := IIf(lManual, cChvNfsMan, oCabXml:CCHAVE)
					(_cTab1)->&(_cCmp1 + "_DTCRIA") := Date()
					(_cTab1)->&(_cCmp1 + "_HRCRIA") := Time()
					(_cTab1)->&(_cCmp1 + "_USUCRI") := cUserName
					(_cTab1)->&(_cCmp1 + "_ERRO")   := cErroXML
					
					//(_cTab1)->&(_cCmp1 + "_NFS")  := "1"
					(_cTab1)->&(_cCmp1 + "_PROV") := U_GOX18PRV(cProvedor) // Provedor
					
				(_cTab1)->( MsUnlock() )
				
				If !lReproc
					
					ConfirmSX8()
					
					GeraNFSVen()
					
				EndIf
				
			ElseIf lCancel
				
				RecLock(_cTab1, IIf(lReproc, .F., .T.))
				
					(_cTab1)->&(_cCmp1 + "_FILIAL") := xFilial("SF1")
					If !lReproc
						(_cTab1)->&(_cCmp1 + "_SEQIMP") := GetSXENUM(_cTab1, _cCmp1 + "_SEQIMP",, 6)
					EndIf
					(_cTab1)->&(_cCmp1 + "_DOC")    := cEvtoDoc
					
					If GetNewPar("MV_ZGOSERP", .F.)
						
						(_cTab1)->&(_cCmp1 + "_SERIE") := PadL(AllTrim(cEvtoSer), TamSX3("F1_SERIE")[1], "0")
						
					Else
					
						(_cTab1)->&(_cCmp1 + "_SERIE")  := cEvtoSer
						
					EndIf
					
					(_cTab1)->&(_cCmp1 + "_CGCEMI") := cEvtoCNPJ
					(_cTab1)->&(_cCmp1 + "_CODEMI") := cEmitCod
					(_cTab1)->&(_cCmp1 + "_LOJEMI") := cEmitLoj
					(_cTab1)->&(_cCmp1 + "_XML")    := cXml
					(_cTab1)->&(_cCmp1 + "_SIT")    := cCanSit
					(_cTab1)->&(_cCmp1 + "_TIPO")   := "5"
					If lManual
						(_cTab1)->&(_cCmp1 + "_CHAVE") := cChaveCan
					Else
						(_cTab1)->&(_cCmp1 + "_CHAVE")  := IIf(lReproc, (_cTab1)->&(_cCmp1 + "_CHAVE"), oCabXml:CCHAVE)
					EndIf
					(_cTab1)->&(_cCmp1 + "_TPCAN")  := cEvtoTp
					If !lReproc
						(_cTab1)->&(_cCmp1 + "_DTCRIA") := Date()
						(_cTab1)->&(_cCmp1 + "_HRCRIA") := Time()
					EndIf
					If cCanSit == "2"
						(_cTab1)->&(_cCmp1 + "_DTIMP") := Date()
						(_cTab1)->&(_cCmp1 + "_HRIMP") := Time()
					EndIf
					(_cTab1)->&(_cCmp1 + "_USUCRI") := cUserName
					(_cTab1)->&(_cCmp1 + "_ERRO")   := cErroXML
					
				(_cTab1)->( MsUnlock() )
				
				If !lReproc
					
					ConfirmSX8()
					
				EndIf
				
			EndIf
			
		Else
			
			lOK       := .F.
			lVlErrMsg := .T.
			AddIncXml("***Erro ao ler o XML do arquivo, ele não será importado e continuará no diretório de origem.")
			
		EndIf
		
	End Sequence
	
	cRetBxXML := cInfErroC
	
	oXml       := Nil
	cXml       := Nil
	
	DelClassIntf()
	
Return lOK

////////////////////////////////////////

Static Function ValidaNFS(lReproc, lManual)
	
	Local aAreaTab  := (_cTab1)->( GetArea() )
	Local aNotaInfo
	
	Local cChave := IIf(lManual, "", IIf(lReproc, (_cTab1)->&(_cCmp1 + "_CHAVE"), AllTrim(oCabXml:CCHAVE)))
	
	Local aEmit
	Local aEmitAux
	
	Local aEmitCNPJ
	
	Default lReproc := .F.
	
	aNotaInfo := U_GOX18NFS(oXml, cProvedor) // Retona as informações da nota de Serviço de acordo com o Provedor
	
	cCGCEmit := U_GOX18REF(aNotaInfo, "CGCPREST", "")
	cCGCDest := U_GOX18REF(aNotaInfo, "CGCTOMA", "")
	
	cChvNfsMan := U_GOX18REF(aNotaInfo, "CHAVE", "")

	If lManual

		cChave := cChvNfsMan
		
	EndIf

	Begin Sequence
	
		cNFeSit := "1"
		
		If cCGCDest # SM0->M0_CGC
			
			lXmlIgnor := .T.
			
			AddIncXml("Arquivo pertence a outra filial, arquivo desconsiderado.")
			
		EndIf		
		
		aEmit := U_CliForGO(cCGCEmit)
		aEmitAux := U_CliForGO(cCGCEmit, .T.)
		
		If aEmit[1] == 1 .And. aEmit[8] # "1"
			
			cEmitCod := aEmit[2]
			cEmitLoj := aEmit[3]
			cNatFin  := aEmit[4]
			cEstado  := aEmit[5]
			cConPgto := aEmit[6]
			
		ElseIf aEmit[1] == 2 .And. aEmit[8] # "1"
			
			cEmitCod := aEmit[2]
			cEmitLoj := aEmit[3]
			cNatFin  := aEmit[4]
			cEstado  := aEmit[5]
			cConPgto := aEmit[6]
			
			lForn := .F.
			
		ElseIf aEmit[1] == 1 .And. aEmit[8] == "1" .And. aEmitAux[1] == 2 .And. aEmitAux[8] # "1"
			
			cEmitCod := aEmitAux[2]
			cEmitLoj := aEmitAux[3]
			cNatFin  := aEmitAux[4]
			cEstado  := aEmitAux[5]
			cConPgto := aEmitAux[6]
			
			lForn := .F.
			
		ElseIf aEmit[1] == 1 .And. aEmit[8] == "1" .And. (aEmitAux[1] == 0 .Or. (aEmitAux[1] == 2 .And. aEmitAux[8] == "1"))
			
			AddErroXml("- Emissor de CNPJ " + cCGCEmit + " informado no XML está cadastrado, porém está BLOQUEADO no sistema. Desbloqueie o Fornecedor/Cliente para dar continuidade na importação.")
			
		ElseIf aEmit[1] == 0
			
			AddErroXml("- Emissor de CNPJ " + cCGCEmit + " informado no XML não cadastrado no sistema.")
			
		EndIf
		
		cNumNF := U_GOX18REF(aNotaInfo, "NUMERO", "")		
		cNumNF := Right(IIf(Len(cNumNF) >= nTamNota, cNumNF, PadL(cNumNF, nTamNota, "0")), nTamCmpNF)
		
		If Empty(U_GOX18REF(aNotaInfo, "NUMERO", ""))
			
			AddErroXml("- Não econtrado número da nota da NFS-e, pode estar com estrutura de XML Diferente.")
			
		EndIf
		
		cSerNFS := U_GOX18REF(aNotaInfo, "SERIE", "")
		
		dNFSEmis := U_GOX18REF(aNotaInfo, "EMISSAO", CToD("  /  /   "))
		
		nValTotIt := U_GOX18REF(aNotaInfo, "TOTAL", 0)
		nValTotNFS:= U_GOX18REF(aNotaInfo, "LIQUIDO", 0)
		
		If Len(cValToChar(Round(nValTotNFS, 0))) > TamSX3(_cCmp1 + "_TOTVAL")[1] - (TamSX3(_cCmp1 + "_TOTVAL")[2] + 1)
			
			nValTotNFS := Val(Replicate("9", TamSX3(_cCmp1 + "_TOTVAL")[1] - (TamSX3(_cCmp1 + "_TOTVAL")[2] + 1)) + "." + Replicate("9", TamSX3(_cCmp1 + "_TOTVAL")[2]))
			
		EndIf
		
		If Len(cValToChar(Round(nValTotIt, 0))) > TamSX3(_cCmp1 + "_TOTITE")[1] - IIf(TamSX3(_cCmp1 + "_TOTITE")[2]>0, (TamSX3(_cCmp1 + "_TOTITE")[2] + 1), 0)
			
			nValTotIt := Val(Replicate("9", TamSX3(_cCmp1 + "_TOTITE")[1] - IIf(TamSX3(_cCmp1 + "_TOTITE")[2]>0, (TamSX3(_cCmp1 + "_TOTITE")[2] + 1), 0)) + IIf(TamSX3(_cCmp1 + "_TOTITE")[2] > 0, "." + Replicate("9", TamSX3(_cCmp1 + "_TOTITE")[2]), ""))
			
		EndIf
		
		If Empty(cSerNFS)
			
			cSerNFS := PadR(GetNewPar("MV_ZGOSNFS", "IS"), TamSx3("F1_SERIE")[1])
			
		EndIf
		
		cSerNFS := PadR(cSerNFS, TamSX3("F1_SERIE")[1])
		
		aAchouNota := NumNotas(cChave, ;
		                       cNumNF, ;
		                       cSerNFS, ;
		                       cEmitCod, cEmitLoj, cEspNFSe, dNFSEmis)
		
		If aAchouNota[1]
		
			cNumNF := aAchouNota[2]
			
		Else
		
			aEmitCNPJ := U_CliForGO(cCGCEmit, .T.)
			
			If aEmitCNPJ[1] == 2
				
				aAchouNota := NumNotas(cChave, ;
				                       cNumNF, ;
				                       cSerNFS, ;
				                       aEmitCNPJ[2], aEmitCNPJ[3], cEspNFSe, dNFSEmis)
				
				If aAchouNota[1]
				
					cNumNF   := aAchouNota[2]
					cEmitCod := aEmitCNPJ[2]
					cEmitLoj := aEmitCNPJ[3]
					cNatFin  := aEmitCNPJ[4]
					cEstado  := aEmitCNPJ[5]
					cConPgto := aEmitCNPJ[6]
					
					lForn := .F.
					
				EndIf
				
			EndIf
			
		EndIf
		
		cTpNFe := "N"
		
		If aAchouNota[1]
			
			cTpNFe  := aAchouNota[3]
			
			//cTpCompNF := aAchouNota[11]
			
			cNFeSit := "2"
			
		EndIf
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		
		// Nota já Importada
		If !lReproc
			
			If (_cTab1)->( dbSeek(cChave + "6") )
				
				lXmlIgnor := .T.
				
				AddIncXml("- Já existe Nota Fiscal de Serviço no importador com a chave " + ;
				             cChave + ". Arquivo desconsiderado.", 1)
				          
			ElseIf (_cTab1)->( dbSeek(cChave + "5") )
				
				cNFeSit   := "5"
				
			EndIf
			
		EndIf
		
		// Vincular Pedido Automaticamente à nota
		
		If GetNewPar("MV_ZSUGPED", .F.)
			
			VinPedXMLS(cEmitCod, cEmitLoj, cChave, aNotaInfo)
			
		EndIf
		
	End Sequence
	
	RestArea(aAreaTab)
	
Return

////////////////////////////////////////

Static Function ValidaNFe(lReproc)

	Local aAreaSZW  := (_cTab1)->( GetArea() )
	Local aAchouNota
	Local aEmitCNPJ
	Local aTransXml := {}
	Local lBloqEmit := .F.
	Local aEmit
	Local aEmitAux
	Local aRetCF
	Local lForn     := .T.
	
	Default lReproc := .F.
	
	If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_emit, "_CNPJ")) <> "U"
	
		cCGCEmit := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:Text)
		
	Else
	
		cCGCEmit := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_emit:_CPF:Text)
		
	EndIf
	
	If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_dest, "_CNPJ")) <> "U"
	
		cCGCDest := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:Text)
		
	Else
	
		cCGCDest := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_dest:_CPF:Text)
		
	EndIf
	
	Begin Sequence
	
		cNFeSit := "1"
		
		If cCGCDest # SM0->M0_CGC
			
			lXmlIgnor := .T.
			
			AddIncXml("Arquivo pertence a outra filial, arquivo desconsiderado.")
			
		EndIf		
		
		aEmit := U_CliForGO(cCGCEmit)
		aEmitAux := U_CliForGO(cCGCEmit, .T.)
		
		If aEmit[1] == 1 .And. aEmit[8] # "1"
			
			cEmitCod := aEmit[2]
			cEmitLoj := aEmit[3]
			cNatFin  := aEmit[4]
			cEstado  := aEmit[5]
			cConPgto := aEmit[6]
			
		ElseIf aEmit[1] == 2 .And. aEmit[8] # "1"
			
			cEmitCod := aEmit[2]
			cEmitLoj := aEmit[3]
			cNatFin  := aEmit[4]
			cEstado  := aEmit[5]
			cConPgto := aEmit[6]
			
			lForn := .F.
			
		ElseIf aEmit[1] == 1 .And. aEmit[8] == "1" .And. aEmitAux[1] == 2 .And. aEmitAux[8] # "1"
			
			cEmitCod := aEmitAux[2]
			cEmitLoj := aEmitAux[3]
			cNatFin  := aEmitAux[4]
			cEstado  := aEmitAux[5]
			cConPgto := aEmitAux[6]
			
			lForn := .F.
			
		ElseIf aEmit[1] == 1 .And. aEmit[8] == "1" .And. (aEmitAux[1] == 0 .Or. (aEmitAux[1] == 2 .And. aEmitAux[8] == "1"))
			
			AddErroXml("- Emissor de CNPJ " + cCGCEmit + " informado no XML está cadastrado, porém está BLOQUEADO no sistema. Desbloqueie o Fornecedor/Cliente para dar continuidade na importação.")
			
		ElseIf aEmit[1] == 0
			
			AddErroXml("- Emissor de CNPJ " + cCGCEmit + " informado no XML não cadastrado no sistema.")
			
		EndIf
		
		cNumNF     := Right(IIf(Len(oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text) >= nTamNota, oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, PadL(oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text, nTamNota, "0")), nTamCmpNF)
		aAchouNota := NumNotas(Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44), ;
		                       cNumNF, ;
		                       oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text, ;
		                       cEmitCod, cEmitLoj, cEspNFe, CToD(SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 9, 2) + "/" + SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 6, 2) + "/" + SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 1, 4)))
		
		If aAchouNota[1]
		
			cNumNF := aAchouNota[2]
			
		Else
		
			aEmitCNPJ := U_CliForGO(cCGCEmit, .T.)
			
			If aEmitCNPJ[1] == 2
				
				aAchouNota := NumNotas(Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44), ;
				                       cNumNF,; //oXml:_nfeProc:_NFe:_infNFe:_ide:_nNF:Text,      ;
				                       oXml:_nfeProc:_NFe:_infNFe:_ide:_serie:Text,    ;
				                       aEmitCNPJ[2], aEmitCNPJ[3], cEspNFe, CToD(SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 9, 2) + "/" + SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 6, 2) + "/" + SubStr(AllTrim(&("oXml:_nfeProc:_NFe:_infNFe:_ide:_dhEmi:Text")), 1, 4)))
				
				If aAchouNota[1]
				
					cNumNF   := aAchouNota[2]
					cEmitCod := aEmitCNPJ[2]
					cEmitLoj := aEmitCNPJ[3]
					cNatFin  := aEmitCNPJ[4]
					cEstado  := aEmitCNPJ[5]
					cConPgto := aEmitCNPJ[6]
					
					lForn := .F.
					
				EndIf
				
			EndIf
			
		EndIf
		
		// Se achou a nota na função NumNotas ou faz dbSeek
		If aAchouNota[1]
			
			cTpNFe  := aAchouNota[3]
			
			cTpCompNF := aAchouNota[11]
			
			cNFeSit := "2"
			
		ElseIf lxgtLSer .And. aAchouNota[10]
			
			lSerie := .F.
			
		EndIf
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		
		// Nota já Importada
		If !lReproc
			
			If (_cTab1)->( dbSeek(Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44) + "1") )
				
				lXmlIgnor := .T.
				
				AddIncXml("- Já existe Nota Fiscal no importador com a chave " + ;
				             Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44) + " e situação: " + ;
				             AllTrim(CBoxInfo(_cCmp1 + "_SIT", (_cTab1)->&(_cCmp1 + "_SIT"), 2)) + ". Arquivo desconsiderado.", 1)
				          
			ElseIf (_cTab1)->( dbSeek(Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44) + "5") )
				
				cNFeSit   := "5"
				
			EndIf
			
		EndIf
		
		aRetCF := VldCFOPNF(.T.)
		
		If aRetCF[2]
			
			cTpNFe    := "Z"
			cTpCompNF := " "
			cNFeSit   := "4"
			
			cErroXML += aRetCF[3]
			
		ElseIf aRetCF[1]
			
			cTpNFe    := aRetCF[3]
			cTpCompNF := aRetCF[4]
			
		Else
			
			cTpNFe    := " "
			cTpCompNF := " "
			
		EndIf
		
		If Empty(cTpNFe) .Or. GetNewPar("MV_ZFRCTPX", .F.)
			
			// Verificar pela Finalidade da Nota.
			
			If oXml:_nfeProc:_NFe:_infNFe:_ide:_finNFe:Text == "1" //Normal
				
				cTpNFe := "N"
				
			ElseIf oXml:_nfeProc:_NFe:_infNFe:_ide:_finNFe:Text == "2" //Complementar
				
				cTpNFe := "C"
				
			ElseIf oXml:_nfeProc:_NFe:_infNFe:_ide:_finNFe:Text == "4" //Complementar
				
				cTpNFe := "D"
				
			EndIf
			
		EndIf
		
		If Left(oXml:_nfeProc:_NFe:_infNFe:_ide:_tpNf:Text, 1) == "0"
			
			cTpNFe    := "P"
			cTpCompNF := " "
			cNFeSit   := "4"
			
		EndIf
		
		//[TODO] Verifica se algum produto não possui amarração e envia WorkFlow para interessados.
		
		If GetNewPar("MV_ZGOWFAP", .F.) // Workflow de amarração de produto
			
			WFAmarrPrd(oXml)
			
		EndIf
		
		////////////////////
		
		// Vincular Pedido Automaticamente à nota
		
		If GetNewPar("MV_ZSUGPED", .F.)
			
			VincPedXML(cEmitCod, cEmitLoj)
			
		EndIf
		
		////////////////////
		
		If lUsaLib
			
			cLiber   := "2" // Bloqueio de Entrada
			cErroXML += "XML precisa de liberação do setor responsável para permitir entrada de NF-e."
			
		EndIf
		
	End Sequence
	
	RestArea(aAreaSZW)
	
Return

////////////////////////////////////////

/*#######################################################################*\
||#                PROCURA A EXISTÊNCIA DA NOTA NA BASE                 #||
\*#######################################################################*/
Static Function NumNotas(cChave, cNumNota, cSerieN, cFornN, cLojaN, cEspN, dDtEmiN)

	Local aAreaSF1  := SF1->( GetArea() )
	Local cEspecie  := ""
	Local cNotaAux  := cValToChar(Val(cNumNota))
	Local cNumAchou := ""
	Local cTipo     := ""
	Local cTpComp   := ""
	Local cSerie    := ""
	Local cFornece  := ""
	Local cLoja     := ""
	Local cCGC      := ""
	Local dDtDigit
	Local lAchou    := .F.
	Local nI
	Local lRepet    := .F.
	
	Default cEspN   := ""
	Default dDtEmiN := CToD("  /  /    ")
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(8) )
	
	If SF1->( dbSeek(xFilial("SF1") + cChave) )
	
		cEspecie  := SF1->F1_ESPECIE
		cNumAchou := SF1->F1_DOC
		cTipo     := SF1->F1_TIPO
		
		cTpComp := SF1->F1_TPCOMPL
		
		dDtDigit  := SF1->F1_DTDIGIT
		cSerie    := SF1->F1_SERIE
		cFornece  := SF1->F1_FORNECE
		cLoja     := SF1->F1_LOJA
		cCGC      := IIf(SF1->F1_TIPO $ "D;B", Posicione("SA1", 1, xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA, "A1_CGC"), Posicione("SA2", 1, xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA, "A2_CGC"))
		lAchou    := .T.
		
	Else
	
		For nI := 0 To (nTamNota - Len(cNotaAux))
		
			dbSelectArea("SF1")
			SF1->( dbSetOrder(1) )
			
			If SF1->( dbSeek(xFilial("SF1") + PadR(PadL(cNotaAux, Len(cNotaAux) + nI, "0"), nTamNota) + PadR(cSerieN, nTamCmpSer) + cFornN + cLojaN) )
				
				If (!Empty(cEspN) .And. SF1->F1_ESPECIE != cEspN) .Or. (!Empty(dDtEmiN) .And. SF1->F1_EMISSAO != dDtEmiN)
					
					If PadR(PadL(cNotaAux, Len(cNotaAux) + nI, "0"), nTamNota) == cNumNota
						
						// Nota idêntica no sistema referente a chave primária, porém espécie ou data de emissão diferente. Deverá barrar.
						lRepet := .T.
						
					EndIf
					
					Exit
					
				EndIf
				
				cEspecie  := SF1->F1_ESPECIE
				cNumAchou := SF1->F1_DOC
				cTipo     := SF1->F1_TIPO
				
				cTpComp := SF1->F1_TPCOMPL
				
				dDtDigit  := SF1->F1_DTDIGIT
				cSerie    := SF1->F1_SERIE
				cFornece  := SF1->F1_FORNECE
				cLoja     := SF1->F1_LOJA
				cCGC      := IIf(SF1->F1_TIPO $ "D;B", Posicione("SA1", 1, xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA, "A1_CGC"), Posicione("SA2", 1, xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA, "A2_CGC"))
				lAchou    := .T.
				
				If Empty(SF1->F1_CHVNFE)
				
					RecLock("SF1", .F.)
					
						SF1->F1_CHVNFE := cChave
						
					SF1->( MsUnlock() )
					
				EndIf
				
				Exit
				
			EndIf
			
		Next nI
		
	EndIf
	
	RestArea(aAreaSF1)
	
Return {lAchou, cNumAchou, cTipo, cEspecie, dDtDigit, cSerie, cFornece, cLoja, cCGC, lRepet, cTpComp}

////////////////////////////////////////

Static Function ValidaCTe(lReproc)

	Local aErros    := {}
	Local aTransXml := {}
	Local cErros    := ""
	Local aRet
	Local nI
	
	Default lReproc := .F.
	
	aRet := U_GOX003(.T., aErros, GetNodeCTe(oXml), !lReproc, IsCteOS(oXml))
		
	If IsNodeCTe(oXml, "_InfCte:_emit:_CNPJ")
		
		cCGCEmit := AllTrim(GetNodeCTe(oXml, "_InfCte:_emit:_CNPJ:Text"))
		
	Else
	
		cCGCEmit := AllTrim(GetNodeCTe(oXml, "_InfCte:_emit:_CPF:Text"))
		
	EndIf
		
	If !IsCteOS(oXml)
		
		If IsNodeCTe(oXml, "_InfCte:_dest:_CNPJ")
		
			cCGCDest := AllTrim(GetNodeCTe(oXml, "_InfCte:_dest:_CNPJ:Text"))
			
		Else
		
			cCGCDest := AllTrim(GetNodeCTe(oXml, "_InfCte:_dest:_CPF:Text"))
			
		EndIf
		
	EndIf
	
	If !aRet[1]
	
		// CTe já existe
		If aRet[6] .Or. aRet[7]
			
			lXmlIgnor := .T.
			
			If aRet[6]
				
				AddIncXml("-ID de CT-e já registrado na NF " + (_cTab1)->(AllTrim(&(_cCmp1+"_DOC")) + ;
				            "/" + AllTrim(&(_cCmp1+"_SERIE"))) + " do Fornecedor/Cliente " + ;
				            (_cTab1)->(AllTrim(&(_cCmp1+"_CODEMI")) + "/" + AllTrim(&(_cCmp1+"_LOJEMI"))) + ;
				            " na filial " + (_cTab1)->&(_cCmp1+"_FILIAL") + ".")
			
			ElseIf aRet[7]
				
				AddIncXml("- CTe pertence a outra filial ou a empresa não é a tomadora do frete, e portanto não será processado.")
				
			EndIf
			
			Return
			
		EndIf
		
		For nI := 1 To Len(aErros)
		
			cErros += "-" + aErros[nI] + CRLF
			
		Next nI
		
		AddErroXml(cErros)
		
	Else
	
		cCTeSit  := "1"
		cEmitCod := aRet[2][13][2]
		cEmitLoj := aRet[2][14][2]
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		
		// Nota já Importada
		If !lReproc
			
			If (_cTab1)->( dbSeek(Right(GetNodeCTe(oXml, "_infCTe:_Id:Text"), 44) + "5") )
				
				cCTeSit := "5"
				
			EndIf
			
		EndIf
		
		If Len(aRet) > 3
		
			cTipoEnt := IIf(aRet[4], "F", "C")
			
		Else
		
			cTipoEnt := "C"
			
		EndIf
		
		// Notas Relacionadas, Colocar no array Aqui pra Salvar lá em cima
		
		aCTeChvs := {}
		
		For nI := 1 To Len(aRet[3])
			
			If cTipoEnt == "F"
				
				dbSelectArea("SF2")
				SF2->( dbSetOrder(1) )
				
				If SF2->( dbSeek(aRet[3][nI][1][2]) )
					
					AAdd(aCTeChvs, SF2->F2_CHVNFE)
					
				EndIf
				
			Else
				
				dbSelectArea("SF1")
				SF1->( dbSetOrder(1) )
				
				If SF1->( dbSeek(aRet[3][nI][1][2]) )
					
					AAdd(aCTeChvs, SF1->F1_CHVNFE)
					
				EndIf
				
			EndIf
			
		Next nI
		
		dbSelectArea("SA2")
		SA2->( dbSetOrder(1) )
		
		If SA2->( dbSeek(xFilial("SA2") + cEmitCod + cEmitLoj) )
		
			cNatFin  := SA2->A2_NATUREZ
			cEstado  := SA2->A2_EST
			cConPgto := SA2->A2_COND
			
		EndIf
	
	EndIf
	
	cNumCTe    := Right(IIf(Len(GetNodeCTe(oXml, "_infCte:_ide:_nCT:Text")) >= nTamNota, GetNodeCTe(oXml, "_infCte:_ide:_nCT:Text"), PadL(GetNodeCTe(oXml, "_infCte:_ide:_nCT:Text"), nTamNota, "0")), nTamCmpNF)
	aAchouNota := NumNotas(Right(GetNodeCTe(oXml, "_InfCte:_Id:Text"), 44) , ;
	                       cNumCTe,; //oCTe:_infCte:_ide:_nCT:Text, ;
	                       GetNodeCTe(oXml, "_infCte:_ide:_serie:Text"), ;
	                       cEmitCod, cEmitLoj, cEspCTe, CToD(SubStr(AllTrim(GetNodeCTe(oXml, "_infCTe:_ide:_dhEmi:Text")), 9, 2) + "/" + SubStr(AllTrim(GetNodeCTe(oXml, "_infCTe:_ide:_dhEmi:Text")), 6, 2) + "/" + SubStr(AllTrim(GetNodeCTe(oXml, "_infCTe:_ide:_dhEmi:Text")), 1, 4)))
	
	If aAchouNota[1]
	
		cCTeSit  := "2"
		cNumCTe  := aAchouNota[2]
		cTipoEnt := aAchouNota[3]
		
	EndIf
	
Return

////////////////////////////////////////

Static Function ValidaCan(lReproc)

	Local aAreaSZW := (_cTab1)->( GetArea() )
	Local aAreaSF1 := SF1->( GetArea() )
	Local cChaveE  := ""
	
	Default lReproc := .F.
	
	// Mesmo no cancelamento o retorno do WebService devolve o XML da Nota que foi cancelada.
	If Type("oXml:_nfeProc:_NFe:_infNFe:_Id:Text") # "U"
		cChaveE := Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44)
	ElseIf IsNodeCTe(oXml, "_infCTe:_Id:Text")
		cChaveE := Right(GetNodeCTe(oXml, "_infCTe:_Id:Text"), 44)
	EndIf
	
	cCanSit := "6"
	
	cChaveCan := cChaveE
	
	If Empty(cChaveE)
		
		lXmlIgnor := .T.
		AddIncXml("- Estrutura do Cancelamento da nota de Entrada de número: " + AllTrim(SF1->F1_DOC) + " e série: " + AllTrim(SF1->F1_SERIE) + " está incorreta, será necessário solicitar XML correto da nota.")
		
	Else
		
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )
		
		If !lReproc .And. (_cTab1)->( dbSeek(cChaveE + "5") )
			
			lXmlIgnor := .T.
			AddIncXml("- Já existe um Xml de cancelamento para o Documento de Entrada de número: " + AllTrim(SF1->F1_DOC) + " e série: " + AllTrim(SF1->F1_SERIE) + ".")
			
		ElseIf (_cTab1)->( dbSeek(cChaveE + "1") ) .Or. (_cTab1)->( dbSeek(cChaveE + "2") )
		
			cEvtoDoc  := (_cTab1)->&(_cCmp1 + "_DOC")
			cEvtoSer  := (_cTab1)->&(_cCmp1 + "_SERIE")
			cEvtoCNPJ := (_cTab1)->&(_cCmp1 + "_CGCEMI")
			cEmitCod  := (_cTab1)->&(_cCmp1 + "_CODEMI")
			cEmitLoj  := (_cTab1)->&(_cCmp1 + "_LOJEMI")
			cEvtoTp   := IIf((_cTab1)->&(_cCmp1 + "_TIPO") == "1", "N", "C")
			
			If (_cTab1)->&(_cCmp1 + "_SIT") $ "1;3"
				
				If IsInCallStack("U_GOX004")
					
					If File("\workflow\modelos\importador\XML_CANC.htm")
						
						lEnvWFCan  := .T.
						lEnvWFCanF := .T.
						
						AAdd(oWFCan:oHTML:ValByName('xm.cFilial') , cFilAnt)
						AAdd(oWFCan:oHTML:ValByName('xm.cNumero') , (_cTab1)->&(_cCmp1 + "_DOC"))
						AAdd(oWFCan:oHTML:ValByName('xm.cFornece'), (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
						AAdd(oWFCan:oHTML:ValByName('xm.cEmissao'), DToC((_cTab1)->&(_cCmp1 + "_DTEMIS")))
						AAdd(oWFCan:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
						AAdd(oWFCan:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO OK - Documento não escriturado foi marcado como cancelado e não poderá ser mais importado!")
						
						AAdd(oWFCanF:oHTML:ValByName('xm.cFilial') , cFilAnt)
						AAdd(oWFCanF:oHTML:ValByName('xm.cNumero') , (_cTab1)->&(_cCmp1 + "_DOC"))
						AAdd(oWFCanF:oHTML:ValByName('xm.cFornece'), (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
						AAdd(oWFCanF:oHTML:ValByName('xm.cEmissao'), DToC((_cTab1)->&(_cCmp1 + "_DTEMIS")))
						AAdd(oWFCanF:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
						AAdd(oWFCanF:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO OK - Documento não escriturado foi marcado como cancelado e não poderá ser mais importado!")
						
					EndIf
					
				EndIf
				
				SetStatusXML(IIf((_cTab1)->&(_cCmp1 + "_TIPO") == "1", "NFE", "CTE"), "5", 1, .F.)
				
				cCanSit := "2"
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "2"
			
				dbSelectArea("SF1")
				SF1->( dbSetOrder(1) )
				
				If !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
				    
					If IsInCallStack("U_GOX004")
						
						If File("\workflow\modelos\importador\XML_CANC.htm")
							
							lEnvWFCan  := .T.
							lEnvWFCanF := .T.
							
							AAdd(oWFCan:oHTML:ValByName('xm.cFilial') , cFilAnt)
							AAdd(oWFCan:oHTML:ValByName('xm.cNumero') , (_cTab1)->&(_cCmp1 + "_DOC"))
							AAdd(oWFCan:oHTML:ValByName('xm.cFornece'), (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
							AAdd(oWFCan:oHTML:ValByName('xm.cEmissao'), DToC((_cTab1)->&(_cCmp1 + "_DTEMIS")))
							AAdd(oWFCan:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
							AAdd(oWFCan:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO OK - Documento não escriturado foi marcado como cancelado e não poderá ser mais importado!")
							
							AAdd(oWFCanF:oHTML:ValByName('xm.cFilial') , cFilAnt)
							AAdd(oWFCanF:oHTML:ValByName('xm.cNumero') , (_cTab1)->&(_cCmp1 + "_DOC"))
							AAdd(oWFCanF:oHTML:ValByName('xm.cFornece'), (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
							AAdd(oWFCanF:oHTML:ValByName('xm.cEmissao'), DToC((_cTab1)->&(_cCmp1 + "_DTEMIS")))
							AAdd(oWFCanF:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
							AAdd(oWFCanF:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO OK - Documento não escriturado foi marcado como cancelado e não poderá ser mais importado!")
							
						EndIf
						
					EndIf
					
					SetStatusXML(IIf((_cTab1)->&(_cCmp1 + "_TIPO") == "1", "NFE", "CTE"), "5", 1, .F.)
					
					cCanSit := "2"
					
				Else
					
					// Chama rotina automática de exclusão, se der erro grava o erro pelo AddErroXml
										
					ImportarCan()
					
				EndIf
				
			ElseIf (_cTab1)->&(_cCmp1 + "_SIT") == "5"
				
				cCanSit := "2"
				
			EndIf
			
		Else
			
			cEvtoDoc  := SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 26, 9)
			cEvtoSer  := SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 23, 3)
			cEvtoCNPJ := SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 7, 14)
			cEvtoTp   := IIf(SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 21, 2) == "57", "C", "N")
			
			AddErroXml("- Não foi encontrado Documento de Entrada com a chave eletrônica " + cChaveE + " informada no Xml. Documento de Entrada pode ainda não ter sido atualizado.")
			
		EndIf
		
	EndIf
	
	RestArea(aAreaSZW)
	RestArea(aAreaSF1)
	
Return

/* ####################################################################### *\
|| #                             ICMS DO CTE                             # ||
\* ####################################################################### */
Static Function XmlCteIcms(oXml)

	Local nIcms := 0
	Local aIcms := {{"1", {"_ICMS00", "_ICMS20", "_CST00", "_CST20"}}, ;
	                {"2", {"_ICMS45", "_CST45"}}, ;
	                {"3", {"_ICMS60", "_CST60"}}, ;
	                {"4", {"_ICMS80", "_ICMS90", "_CST80", "_CST90", "_ICMSOUTRAUF"}};
	               }
	Local nX
	Local nY
	Local oXmlAux
	Local oXmlIcms// := XmlChildEx(oXml:_cteProc:_CTe:_infCte:_imp, "_ICMS")
	Local aRet     := {"2" /*Tributação*/, 0/*Base*/, 0/*Alíquota*/, 0/*Valor*/}
	
	oXmlIcms := XmlChildEx(GetNodeCTe(oXml, "_infCte:_imp"), "_ICMS")
	
	If ValType(oXmlIcms) # "O"
	
		oXmlIcms := oXml
		
	EndIf
	
	Begin Sequence
	
		If ValType(oXmlIcms) # "O"
		
			Break
			
		EndIf
		
		For nX := 1 To Len(aIcms)
		
			For nY := 1 To Len(aIcms[nX][2])
			
				If ValType(oXmlAux := XmlChildEx(oXmlIcms, aIcms[nX][2][nY])) == "O"
				
					If aIcms[nX][1] != "2"
						
						If aIcms[nX][2][nY] == "_ICMSOUTRAUF" .And. ValType(XmlChildEx(oXmlAux, "_VBCOUTRAUF")) != "U"
							
							aRet := {aIcms[nX][1], Val(oXmlAux:_vBCOutraUF:Text), Val(oXmlAux:_pICMSOutraUF:Text), Val(oXmlAux:_vICMSOutraUF:Text)}
							
						ElseIf ValType(XmlChildEx(oXmlAux, "_VBC")) != "U"
							
							aRet := {aIcms[nX][1], Val(oXmlAux:_vBC:Text), Val(oXmlAux:_pICMS:Text), Val(oXmlAux:_vICMS:Text)}
							
						EndIf
						
					EndIf
					
					Break
					
				EndIf
				
			Next nY
			
		Next nX
		
	End Sequence
	
Return aRet

/* ####################################################################### *\
|| #                             ICMS DO NFE                             # ||
\* ####################################################################### */
User Function GOXmlIcm(oXml, nItem)//XmlNfeIcms(oXml, nItem)
	
	Local aRet     := {'2' /*Tributação*/, 0/*Base*/, 0/*Alíquota*/, 0/*Valor*/, ""/*Origem*/, ""/*CST*/, /*BS ST*/0, /*PER ST*/0, /*VAL ST*/0, /*BS ST ANT*/0, /*PER ST ANT*/0, /*VAL ST ANT*/0, /*VAL SUBSTITUIDO D1_VALANTI*/ 0}
	Local aSitTrib := {}
	Local cStrProd := ''
	Local cStrImp  := ''
	Local nBaseICM, nPICM, nValICM, cOrigem := "", cCST := "", nBaseICMST := 0, nPICMST := 0, nValICMST := 0, nBaseSTAnt := 0, nPSTAnt := 0, nValSTAnt := 0, nValSubA := 0
	Local nB
    local nVNfST := 0
	
	Local lSTAnt := ExistBlock("GOXVLSTA")
	/*
	  PASSA O GRUPO DE ICMS E 
	  O TIPO 1 = Tributado
	         2 = Isento
	         3 = Subs. Tributaria
	         4 = Outros
	*/
	AAdd(aSitTrib, {'00', '1'})
	AAdd(aSitTrib, {'10', '1'})
	AAdd(aSitTrib, {'20', '1'})
	AAdd(aSitTrib, {'30', '2'})
	AAdd(aSitTrib, {'40', '2'})
	AAdd(aSitTrib, {'41', '2'})
	AAdd(aSitTrib, {'50', '2'})
	AAdd(aSitTrib, {'51', '4'})
	AAdd(aSitTrib, {'60', '3'})
	AAdd(aSitTrib, {'70', '3'})
	AAdd(aSitTrib, {'90', '4'})
	AAdd(aSitTrib, {'SN900', '1'})
	AAdd(aSitTrib, {'SN201', '1'})
	
	Begin Sequence
	
		// TRANSFORMA EM ARRAY UM OBJETO DA ESTRUTURA DO XML
		If Type('oXml:_NfeProc:_Nfe:_InfNfe:_det') == 'O'
		
			XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, '_det')
			
		EndIf
		
		If nItem > Len(oXml:_NfeProc:_Nfe:_InfNfe:_det)
			
			Break
			
		EndIf
		
		// PERCORRE TODOS OS GRUPOS DE DETALHAMENTO DE PRODUTOS E SERVIÇOS DA NF-E
		//For nA := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)
		
			// VERIFICA SE TEM O ICMS
			If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS') == 'O'
			
				SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nItem]:_prod          XMLSTRING cStrProd
				SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nItem]:_imposto:_ICMS XMLSTRING cStrImp
				
				For nB := 1 To Len(aSitTrib)
				
					//aRet := {'2', 0, 0, 0}  // VALOR PADRÃO
					
					// VERIFICA QUAL GRUPO DE ICMS ESTÁ PRESENTE NO XML
					If At('<ICMS' + aSitTrib[nB][1] + '>', cStrImp) > 0
					
						// VALOR DA BC DO ICMS
						If At('<VBC>', Upper(cStrImp)) > 0
						
							nBaseICM := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VBC:TEXT'))
							nValICM  := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VICMS:TEXT'))
							nPICM    := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_PICMS:TEXT'))
							
							aRet     := {aSitTrib[nB][2], nBaseICM, nPICM, nValICM, "", "", 0, 0, 0, 0, 0, 0, 0}
							
						// MOTIVO DA DESONERAÇÃO DO ICMS  /  VALOR DO DESCONTO
						ElseIf At('<MOTDESICMS>', Upper(cStrImp)) > 0 .And. At('<VDESC>', Upper(cStrProd)) > 0
							
							nValICM  := Val(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VICMS:TEXT'))
							
							aRet     := {aSitTrib[nB][2], 0, 0, nValICM, "", "", 0, 0, 0, 0, 0, 0, 0}
							
						EndIf
						
						//ICMS ST
						//<vBCST>12527.44</vBCST>
						//<pICMSST>17.0000</pICMSST>
						//<vICMSST>711.78</vICMSST>
						If At('<VBCST>', Upper(cStrImp)) > 0
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VBCST:TEXT') # "U"
								nBaseICMST := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VBCST:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VICMSST:TEXT') # "U"
								nValICMST  := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VICMSST:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_PICMSST:TEXT') # "U"
								nPICMST    := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_PICMSST:TEXT'))
							EndIf

                            //Marcelo
                            if oXml:_nfeProc:_NFe:_infNFe:_ide:_finNFe:Text == "2" //Complementar
                                If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_prod:_vProd:TEXT') # "U"
                                    nVNfST    := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_prod:_vProd:TEXT'))
                                EndIf
                            endif
							
							If Empty(nPICMST) .Or. nPICMST == 0
								
								nPICMST := Round(nValICMST * 100 / nBaseICMST, 2)
								
							EndIf
							
							//IMCS ST - Situação ocorreu na Agricopel - NF chave 33210910456016000248550010001451921162565299
							If aSitTrib[nB][1] == "30" .and. oXml:_nfeProc:_NFe:_infNFe:_ide:_finNFe:Text == "2" //Complementar

                                aRet := {aSitTrib[nB][2], nBaseICMST, nPICMST, nVNfST, "", "", 0, 0, 0, 0, 0, 0, 0}
                            
                            elseif aSitTrib[nB][1] == "60" .Or. (lSTAnt .And. ExecBlock("GOXVLSTA", .F., .F., {aSitTrib[nB][1]}))
								
								aRet[10] := nBaseICMST
								aRet[11] := nPICMST
								aRet[12] := nValICMST
								
							Else
								
								aRet[7] := nBaseICMST
								aRet[8] := nPICMST
								aRet[9] := nValICMST
								
							EndIf

						EndIf

						If At('<VBCSTRET>', Upper(cStrImp)) > 0
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VBCSTRet:TEXT') # "U"
								nBaseSTAnt := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_VBCSTRet:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_vICMSSTRet:TEXT') # "U"
								nValSTAnt := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_vICMSSTRet:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_vICMSSubstituto:TEXT') # "U"
								nValSubA := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_vICMSSubstituto:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_pST:TEXT') # "U"
								nPSTAnt    := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_pST:TEXT'))
							EndIf
							
							If Empty(nPSTAnt) .Or. nPSTAnt == 0
								
								nPSTAnt := Round(nValSTAnt * 100 / nBaseSTAnt, 2)
								
							EndIf
							
							If aSitTrib[nB][1] == "60" .Or. (lSTAnt .And. ExecBlock("GOXVLSTA", .F., .F., {aSitTrib[nB][1]}))
								
								aRet[10] := nBaseSTAnt
								aRet[11] := nPSTAnt
								aRet[12] := nValSTAnt
								aRet[13] := nValSubA
								
							Else
								
								aRet[7] := nBaseSTAnt
								aRet[8] := nPSTAnt
								aRet[9] := nValSTAnt
								
							EndIf
							
						EndIf
						
						If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_orig') == "O"
							cOrigem := &('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_orig:TEXT')
						EndIf
						
						aRet[5] := cOrigem
						
						If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_CST') == "O"
							cCST := &('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_CST:TEXT')
						ElseIf Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_CSOSN') == "O"
							cCST := &('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMS' + aSitTrib[nB][1] + ':_CSOSN:TEXT')
						EndIf
						
						aRet[6] := cCST
						
						Exit
						
					EndIf
					
					If At('<ICMSST>', cStrImp) > 0
						
						If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_orig') == "O"
							cOrigem := &('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_orig:TEXT')
						EndIf
						
						aRet[5] := cOrigem
						
						If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_CST') == "O"
							cCST := &('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_CST:TEXT')
						EndIf
						
						aRet[6] := cCST
						
						/*If At('<VBCEFET>', Upper(cStrImp)) > 0
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vBCEfet:TEXT') # "U"
								nBaseSTEf := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vBCEfet:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vICMSEfet:TEXT') # "U"
								nValSTEf  := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vICMSEfet:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_pICMSEfet:TEXT') # "U"
								nPSTEf    := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_pICMSEfet:TEXT'))
							EndIf
							
							aRet[10] := nBaseSTEf
							aRet[11] := nPSTEf
							aRet[12] := nValSTEf
							
						EndIf*/
						
						If At('<VBCST>', Upper(cStrImp)) > 0
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_VBCST:TEXT') # "U"
								nBaseICMST := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_VBCST:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_VICMSST:TEXT') # "U"
								nValICMST  := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_VICMSST:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_PICMSST:TEXT') # "U"
								nPICMST    := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_PICMSST:TEXT'))
							EndIf
							
							If Empty(nPICMST) .Or. nPICMST == 0
								
								nPICMST := Round(nValICMST * 100 / nBaseICMST, 2)
								
							EndIf
								
							If cCST == "60" .Or. (lSTAnt .And. ExecBlock("GOXVLSTA", .F., .F., {cCST}))
							
								aRet[10] := nBaseICMST
								aRet[11] := nPICMST
								aRet[12] := nValICMST
																
							Else
								
								aRet[7] := nBaseICMST
								aRet[8] := nPICMST
								aRet[9] := nValICMST
								
							EndIf

						EndIf

						If At('<VBCSTRET>', Upper(cStrImp)) > 0
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_VBCSTRet:TEXT') # "U"
								nBaseSTAnt := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_VBCSTRet:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vICMSSTRet:TEXT') # "U"
								nValSTAnt := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vICMSSTRet:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vICMSSubstituto:TEXT') # "U"
								nValSubA := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_vICMSSubstituto:TEXT'))
							EndIf
							
							If Type('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_pST:TEXT') # "U"
								nPSTAnt    := VAL(&('oXml:_nfeProc:_NFe:_infNFe:_det[' + CVALTOCHAR(nItem) + ']:_imposto:_ICMS:_ICMSST:_pST:TEXT'))
							EndIf
							
							If Empty(nPSTAnt) .Or. nPSTAnt == 0
								
								nPSTAnt := Round(nValSTAnt * 100 / nBaseSTAnt, 2)
								
							EndIf
							
							If cCST == "60" .Or. (lSTAnt .And. ExecBlock("GOXVLSTA", .F., .F., {cCST}))
								
								aRet[10] := nBaseSTAnt
								aRet[11] := nPSTAnt
								aRet[12] := nValSTAnt
								aRet[13] := nValSubA
								
							Else
								
								aRet[7] := nBaseSTAnt
								aRet[8] := nPSTAnt
								aRet[9] := nValSTAnt
								
							EndIf
							
						EndIf
					
					EndIf
					
				Next nB
				
			EndIf
			
		//Next nA
		
	End Sequence
	
Return aRet

////////////////////////////////////////

Static Function ImportNFeC()
	
	Local cError   := ""
	Local cWarning := ""
	Local cDesComp := IIf((_cTab1)->&(_cCmp1 + "_TIPOEN")=="I", "ICMS", IIf((_cTab1)->&(_cCmp1 + "_TIPOEN")=="P", "IPI", "Preço/Frete"))	
	Local aItens   := {}
	Local nI, nX
	Local cAlias   := GetNextAlias()
	Local cQuery   := ""
	Local aFields  := {_cCmp1 + "_FILIAL", _cCmp1 + "_DOC" , _cCmp1 + "_SERIE", _cCmp1 + "_DTEMIS", _cCmp1 + "_CODEMI", ;
	                   _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_EST"  , "NOUSER"}
	Local aUpdFlds := {}
	Local aCabec
	Local aItens   := {}
	Local cProduto := Space(TamSX3("D1_COD")[1])
	Local cStrXml  := ""
	Local cClasFis := ""
	Local aAltItem := {_cCmp2 + "_COD", _cCmp2 + "_TES", _cCmp2 + "_CF", _cCmp2 + "_TOTAL"}
	Local aAltNFs  := {}
	Local aNFsIni  := {"D2_OK", "D1_DOC", "D1_SERIE", "D1_FORNECE", "D1_LOJA", "D1_EMISSAO", "D1_ITEM", "D1_UM", "D1_COD", "D1_DESCRI", "D1_QUANT", "D1_VUNIT", "D1_TOTAL", "D1_TES", "D1_CF", "D1_NUMSEQ", "D1_LOTECTL", "D1_NUMLOTE"}
	Local lConfirm := .F.
	//Local cEnchOld := GetMv("MV_ENCHOLD")
	Local aAchouNota := {}
	Local cBusca   := Space(nTamCmpNF)
	Local dEmisDe  := CToD("  /  /    ")
	Local dEmisAte := CToD("  /  /    ")
	Local aTrocaEmit
	
	Local nIcms
	
	//Totais
	Private nValFrete
	Private nValSeguro
	Private nValDesp
	Private nValDesc
	Private nValMerc
	Private nValXIPI
	Private nValXST
	////////
	Private oLayerNFeC
	Private oGetDItem, oGetDNFs
	Private cDescDev       := "complemento de " + IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "I", "ICMS", IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "P", "IPI", "Preço/Frete"))
	Private aHeadItem      := {}
	Private aColsItem
	Private aHeadNFs       := {}
	Private aColsNFs
	Private oBrwNFsIt
	Private aMarcNFs       := {}
	Private oFootAtu
	Private oFootDes
	Private lCompCli       := .F.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	
	aTrocaEmit := U_CliForGO((_cTab1)->&(_cCmp1 + "_CGCEMI"))
	
	If aTrocaEmit[1] == 1 .And. aTrocaEmit[8] # "1"
		
		RecLock(_cTab1, .F.)
		
			(_cTab1)->&(_cCmp1 + "_CODEMI") := aTrocaEmit[2]
			(_cTab1)->&(_cCmp1 + "_LOJEMI") := aTrocaEmit[3]
			(_cTab1)->&(_cCmp1 + "_NATFIN") := aTrocaEmit[4]
			(_cTab1)->&(_cCmp1 + "_EST")    := aTrocaEmit[5]
			(_cTab1)->&(_cCmp1 + "_CONDPG") := aTrocaEmit[6]
		
		(_cTab1)->( MsUnlock() )
		
	ElseIf aTrocaEmit[1] == 1 .And. aTrocaEmit[8] == "1"
		
		//Aviso("Erro", "Fornecedor bloqueado no sistema, não poderá ser importado como complemento.", {"Ok"}, 2)
		
		U_GOSetEr("Fornecedor bloqueado no sistema, não poderá ser importado como complemento.")
		
		Return .F.
		
	Else
		
		//Aviso("Erro", "Fornecedor inexistente no sistema.", {"Ok"}, 2)
		
		U_GOSetEr("Fornecedor inexistente no sistema.")
		
		Return .F.
		
	EndIf
	
	aAchouNota := NumNotas((_cTab1)->&(_cCmp1 + "_CHAVE"), (_cTab1)->&(_cCmp1 + "_DOC"), (_cTab1)->&(_cCmp1 + "_SERIE"), ;
	                       (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"), cEspNFe, (_cTab1)->&(_cCmp1 + "_DTEMIS"))
	
	// Se achou a nota importada
	If aAchouNota[1]
	
		If Aviso("Aviso", "A Nota Fiscal " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " já foi importada com o número: '" + aAchouNota[2] + "'. " + CRLF + ;
		         "Deseja marcá-la como Processada?", {"Sim", "Não"}, 2) == 1
		
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_DOC")    := aAchouNota[2]
				(_cTab1)->&(_cCmp1 + "_TIPOEN") := aAchouNota[3]
				
				(_cTab1)->&(_cCmp1 + "_TPCOMP") := aAchouNota[11]
				
				(_cTab1)->&(_cCmp1 + "_ESPECI") := aAchouNota[4]
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := aAchouNota[5]
				(_cTab1)->&(_cCmp1 + "_SERIE")  := aAchouNota[6]
				(_cTab1)->&(_cCmp1 + "_CODEMI") := aAchouNota[7]
				(_cTab1)->&(_cCmp1 + "_LOJEMI") := aAchouNota[8]
				(_cTab1)->&(_cCmp1 + "_CGCEMI") := aAchouNota[9]
				
			(_cTab1)->( MsUnlock() )
			
		EndIf
		
		Return .F.
		
	ElseIf aAchouNota[10]
		
		/*Aviso("Aviso", "A Nota Fiscal já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " +;
		      "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      "problema de chave duplicada.", {"Ok"}, 2)*/
		
		U_GOSetEr("A Nota Fiscal já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " +;
		      	   "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      	   "poblema de chave duplicada.")
		
		Return .F.
		
	EndIf
	
	U_GOSetEr(,, .T.)
	
	SetKey(VK_F7, {|| CargaNFs(, cBusca, dEmisDe, dEmisAte)})
	
	Begin Sequence
		
		nValFrete  := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vFrete:Text)
		nValSeguro := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vSeg:Text)
		nValDesp   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vOutro:Text)
		nValDesc   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vDesc:Text)
		nValMerc   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vProd:Text)
		nValXIPI   := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vIPI:Text"))
		nValXST    := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vST:Text"))
		
		If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
		
			XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
			
		EndIf

		DEFINE MSDIALOG oDlgNFeC FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE 'Importador - Nota Fiscal de Complemento de ' + cDesComp COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
			oDlgNFeC:lEscClose := .F.
			oLayerNFeC := FWLayer():New()
			oLayerNFeC:Init(oDlgNFeC, .F.)
			
				oLayerNFeC:AddLine('TOP', 29, .F.)
				
					oLayerNFeC:AddCollumn('NFEC_INFO', 100, .T., 'TOP')
					
						oLayerNFeC:AddWindow('NFEC_INFO', 'WIN_NFEC_INFO', "Informações da Nota Fiscal de Complemento de " + cDesComp + " a ser importada", 100, .F., .T., , 'TOP', )
						
							RegToMemory(_cTab1)
							//PutMv("MV_ENCHOLD", "2")
							
							oGetCab := MsMGet():New(_cTab1, , MODEL_OPERATION_UPDATE, , , , aFields, {0, 0, 0, 0}, aUpdFlds, ;
							           , , , , oLayerNFeC:GetWinPanel('NFEC_INFO', 'WIN_NFEC_INFO', 'TOP'), , .T., , , .T., , , , , , , .T.)
							
							//PutMv("MV_ENCHOLD", cEnchOld)
							oGetCab:oBox:Align := CONTROL_ALIGN_ALLCLIENT
							
				oLayerNFeC:AddLine('CENTER', 33, .F.)
				
					oLayerNFeC:AddCollumn('NFEC_ITEM', 100, .T., 'CENTER')
					
						oLayerNFeC:AddWindow('NFEC_ITEM', 'WIN_NFEC_ITEM', "Itens da Nota Fiscal de Complemento de " + cDesComp + " a ser importada", 100, .F., .T., , 'CENTER', )
						
							dbSelectArea("SX3")
							SX3->( dbSetOrder(2) )
							
							If SX3->( dbSeek("D2_OK") )
							
								AAdd(aHeadItem, {"Vinculada?", _cCmp2 + "_OK", "@BMP", 9, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
								
							EndIf
							
							dbSelectArea("SX3")
							SX3->( dbSetOrder(1) )
							SX3->( dbSeek(_cTab2) )
							
							While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab2
							
								If !(AllTrim(SX3->X3_CAMPO) $ _cCmp2 + "_FILIAL|" + _cCmp2 + "_PEDIDO|" + _cCmp2 + "_ITEMPC|" + _cCmp2 + "_BASEIC|" + _cCmp2 + "_PICM|" + _cCmp2 + "_VALICM|" + _cCmp2 + "_BASEIP|" + _cCmp2 + "_IPI|" + _cCmp2 + "_VALIPI|" + _cCmp2 + "_QUANT1|" + _cCmp2 + "_NFORI|" + _cCmp2 + "_SERORI|" + _cCmp2 + "_ITORI" + _cCmp2 + "_CSTERP" + _cCmp2 + "_SEQIMP") .And. AllTrim(SX3->X3_CAMPO) != (_cCmp2 + "_DESCTO")
								
									AAdd(aHeadItem, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
									
								EndIf
								
								SX3->( dbSkip() )
								
							EndDo
							
							// Pega a posição dos itens da Tab2
							_nPosItXml := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DESC"   , 10)})
							_nPosPedid := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_PEDIDO" , 10)})
							_nPosItePc := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_ITEMPC" , 10)})
							_nPosProdu := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_COD"    , 10)})
							_nPosDcPrd := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DSPROD" , 10)})
							_nPosNcm   := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_NCM"    , 10)})
							_nPosUm    := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_UM"     , 10)})
							_nPosUmFor := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_UMF"    , 10)})
							_nPosQtdFr := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_QUANT1" , 10)})
							_nPosQtdNo := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_QUANT2" , 10)})
							_nPosVlUnt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VUNIT"  , 10)})
							_nPosVlTot := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_TOTAL"  , 10)})
							_nPosTes   := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_TES"    , 10)})
							_nPosCdFis := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CF"     , 10)})
							_nPosConta := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CONTA"  , 10)})
							_nPosCtCus := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CC"     , 10)})
							_nPosItCon := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_ITEMCTA", 10)})
							_nPosClVal := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CLVL"   , 10)})
							_nPosBsIcm := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BASEIC" , 10)})
							_nPosAqIcm := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_PICM"   , 10)})
							_nPosVlIcm := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VALICM" , 10)})
							_nPosBsIpi := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BASEIP" , 10)})
							_nPosAqIpi := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_IPI"    , 10)})
							_nPosVlIpi := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VALIPI" , 10)})
							_nPosStTri := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CLASFI" , 10)})
							_nPosCSOSN := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CSOSN" , 10)})
							
							_nPosBsISt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BASEST" , 10)})
							_nPosPIcSt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_PICMST" , 10)})
							_nPosVlISt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VLICST" , 10)})

							_nPosBsStA := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BSSTAN" , 10)})
							_nPosPStA := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_ALSTAN" , 10)})
							_nPosVlStA := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VLSTAN" , 10)})
							
							_nPosVlAnt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VLANTI" , 10)})
							
							_nPosLote  := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_LOTE" , 10)})
							_nPosDtFab := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DTFAB" , 10)})
							_nPosDtVld := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DTVLD" , 10)})
							_nPosFciCd := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_FCICOD" , 10)})
							
							aColsItem := {}
							aMarcNFs  := Array(Len(oXml:_NfeProc:_Nfe:_InfNfe:_det))
							aFill(aMarcNFs, {"", "", "", "", "", "", "", "", ""})
							
							//-------------------- Carregar Itens do Xml no array
							
							For nI := 1 To Len(oXml:_NfeProc:_Nfe:_InfNfe:_det)
							
								cProduto := Space(TamSX3("B1_COD")[1])
								AAdd(aColsItem, Array(Len(aHeadItem) + 1))
								
								For nX := 1 To Len(aHeadItem)
								
									If !(aHeadItem[nX, 2] $ _cCmp2 + "_OK")
									
										aColsItem[nI, nX] := CriaVar(aHeadItem[nX, 2])
										
									EndIf
									
								Next nX
								
								aColsItem[nI, Len(aHeadItem) + 1] := .F.
								
								cQuery := "SELECT SA5.A5_PRODUTO FROM " + RetSqlName("SA5") + " SA5"
								cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
								cQuery += " SA5.A5_FILIAL  = '" + xFilial("SA5") + "' AND "
								cQuery += " SA5.A5_FORNECE = '" + M->&(_cCmp1 + "_CODEMI") + "' AND "
								cQuery += " SA5.A5_LOJA    = '" + M->&(_cCmp1 + "_LOJEMI") + "' AND "
								cQuery += " SA5.A5_CODPRF  = '" + AllTrim(Upper(StrTran(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text, "'"))) + "' AND "
								cQuery += " SA5.A5_PRODUTO <> ' '"
								
								If Select(cAlias) > 0
									
									(cAlias)->( dbCloseArea() )
									
								EndIf
								
								dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAlias, .F., .T.)
								
								If !(cAlias)->( Eof() )
								
									cProduto := (cAlias)->A5_PRODUTO
									
								Else
								
									
								EndIf
								
								
								If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nI) + "]:_imposto:_ICMS") == "O"
								
									SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_imposto:_ICMS XMLSTRING cStrXml
									
									If At("<ICMS", cStrXml) > 0
									
										cClasFis := SubStr(cStrXml, At("<orig>", cStrXml) + 6, 1) + SubStr(cStrXml, At("<CST>", cStrXml) + 5, 2)
										
										If SubStr(cClasFis, 1, 1) == "1"
											
											cClasFis := "2" + SubStr(cClasFis, 2, 2)
											
										EndIf
										
										If !U_GO1VLCST(cClasFis)
											
											cClasFis := "   "
											
										EndIf
										
									EndIf
									
								EndIf
								
								aColsItem[nI][1] := "BR_CANCEL" // Vinculada?
								
								// Desrição do Item (vindo do Xml no formato do Cliente)
								If _nPosItXml > 0
								
									aColsItem[nI][_nPosItXml] := SubStr(AllTrim(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text) + " - " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_xProd:Text), 1, 40)
									
								EndIf
								
								// Código do Produto
								If _nPosProdu > 0
								
									aColsItem[nI][_nPosProdu] := cProduto
									
								EndIf
								
								If _nPosUm > 0 .And. !Empty(cProduto)
									
									aColsItem[nI][_nPosUm] := Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_UM")
									
								EndIf
								
								// Descrição do Produto
								If _nPosDcPrd > 0
								
									aColsItem[nI][_nPosDcPrd] := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC"), Space(TamSX3("B1_DESC")[1]))
									
								EndIf
								
								// Unidade de Medida
								If _nPosUmFor > 0
								
									aColsItem[nI][_nPosUmFor] := Upper(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_uCom:Text)
									
								EndIf
								
								// Quantidade da Nota de saída selecionada
								If _nPosQtdNo > 0
								
									aColsItem[nI][_nPosQtdNo] := 0
									
								EndIf
								
								nIcms := U_GOXmlIcm(oXml, nI)[4]
								
								// Valor unitário
								If _nPosVlUnt > 0
								
									aColsItem[nI][_nPosVlUnt] := nIcms//RetItemICMS(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI], {"_IMPOSTO", "_ICMS", "_ICMS00", "_VICMS"}) //Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_vUnCom:Text), 2)
									
								EndIf
								
								// Valor total
								If _nPosVlTot > 0
								
									aColsItem[nI][_nPosVlTot] := nIcms//RetItemICMS(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI], {"_IMPOSTO", "_ICMS", "_ICMS00", "_VICMS"}) 
									
								EndIf
								
								// Tes
								If _nPosTes > 0
								
									aColsItem[nI][_nPosTes] := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_TE"), Space(TamSX3("B1_TE")[1]))
									
								EndIf
								
								// Código Fiscal
								If _nPosCdFis > 0
								
									aColsItem[nI][_nPosCdFis] := IIf(!Empty(aColsItem[nI][_nPosTes]), IIf(GETMV("MV_ESTADO") == M->&(_cCmp1 + "_EST"), "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + aColsItem[nI][_nPosTes], "F4_CF"), 2, 3), "")
									
								EndIf
								
								// Classificação Fiscal
								If _nPosStTri > 0
								
									aColsItem[nI][_nPosStTri] := cClasFis
									
								EndIf
								
							Next nI
							
							(cAlias)->( dbCloseArea() )
							
							If Len(aMarcNFs) == 0
							
								Aviso("Aviso", "Não há itens vinculados a Nota Fiscal.", {"Ok"}, 2)
								Break
								
							EndIf
							
							oGetDItem := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltItem, 0, 999, Nil, Nil, "AlwaysFalse", oLayerNFeC:GetWinPanel('NFEC_ITEM', 'WIN_NFEC_ITEM', 'CENTER'), aHeadItem, aColsItem, "")
							oGetDItem:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
							oGetDItem:bLinhaOk := {|| LimpaNfs(), .T.}
							
				oLayerNFeC:AddLine('MIDDLE', 33, .F.)
				
					oLayerNFeC:AddCollumn('NFEC_NFE', 100, .T., 'MIDDLE')
					
						oLayerNFeC:AddWindow('NFEC_NFE', 'WIN_NFEC_NFE', "Itens das Notas Fiscais de origem (Entrada)", 100, .F., .T., , 'MIDDLE', )
						
							dbSelectArea("SX3")
							SX3->( dbSetOrder(2) )
							
							For nI := 1 To Len(aNFsIni)
							
								If SX3->( dbSeek(aNFsIni[nI]) )
								
									AAdd(aHeadNFs, {Trim(X3Titulo()), IIf(AllTrim(aNFsIni[nI]) == "D2_OK", "D1_OK", SX3->X3_CAMPO), IIf(AllTrim(aNFsIni[nI]) == "D2_OK", "@BMP", SX3->X3_PICTURE), IIf(AllTrim(aNFsIni[nI]) == "D2_OK", 8, SX3->X3_TAMANHO), SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
									
								EndIf
								
							Next nI
							
							aColsNFs := {Array(Len(aHeadNFs) + 1)}
							ATail(aColsNFs)[Len(aHeadNFs) + 1] := .F.
							oGetDNFs := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltNFs, 0, 999, Nil, Nil, "AlwaysFalse", oLayerNFeC:GetWinPanel('NFEC_NFE', 'WIN_NFEC_NFE', 'MIDDLE'), aHeadNFs, aColsNFs, {|| /*bChange*/})
							oGetDNFs:oBrowse:blDblClick := {|x, nCol| MarcaNFs()}
							oGetDNFs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
							
				//----------------- Carrega NFs de Entrada
				oLayerNFeC:AddLine('BOTTOM', 5, .F.)
				
					oLayerNFeC:AddCollumn('NFEC_BAR', 100, .T., 'BOTTOM')
					
						oPanelBot := tPanel():New(0, 0, "", oLayerNFeC:GetColPanel('NFEC_BAR', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
						oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
						
						oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgNFeC:End()}, , , )
						oQuit:nWidth  := 80
						oQuit:nHeight := 10
						oQuit:Align   := CONTROL_ALIGN_RIGHT
						oQuit:SetColor(RGB(002, 070, 112), )
						
						oImp := THButton():New(0, 0, "Importar Complemento de " + cDesComp, oPanelBot, {|| lConfirm := .T., IIf(InsereNFeD(@lConfirm), oDlgNFeC:End(), )}, , , )
						oImp:nWidth  := 180
						oImp:nHeight := 10
						oImp:Align   := CONTROL_ALIGN_RIGHT
						oImp:SetColor(RGB(002, 070, 112), )
						
						////// Objetos para busca da nota fiscal
						
						oEmisDe    := TGet():New(000, 002, {|u| IF(Pcount() > 0, dEmisDe := u, dEmisDe)}, oPanelBot, 040, 010, '@', , , , , , , .T., , , {|| .T.}, , , , , , , "dEmisDe", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Emis De", 2, , )
						
						oEmisAte    := TGet():New(000, 064, {|u| If(Pcount() > 0, dEmisAte := u, dEmisAte)}, oPanelBot, 040, 010, '@', , , , , , , .T., , , {|| .T.}, , , , , , , "dEmisAte", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Até", 2, , )
						
						oBusca    := TGet():New(000, 115, {|u| If(Pcount() > 0, cBusca := u, cBusca)}, oPanelBot, 045, 010, '@', , , , , , , .T., , , {|| .T.}, , , , , , , "cBusca", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Nota", 2, , )
						
						oBuscaBtn := tButton():New(000, 175, 'Filtrar', oPanelBot, {|| CargaNFs(, cBusca, dEmisDe, dEmisAte)}, 25, 12, , , , .T.)
						//Complemento de saída
						
						oChk := TCheckBox():New(001, 210, 'Complemento de cliente?', , oPanelBot, 70, 160, , , , , , , , .T., , , )
						oChk:cToolTip  := "Indica que os complementos são referentes a notas de Clientes, o importador irá procurar para clientes que tiverem o mesmo CNPJ do fornecedor."
						oChk:bSetGet   := {|| lCompCli}
						oChk:bLClicked := {|| lCompCli := !lCompCli}
						
						////////////////////////////////////////
						
						/*oFootAtu := TSay():New(4, 10, {|| "  Todos os itens estão vinculados."}, oPanelBot, , TFont():New('Arial', , -12, , .F.), , , , .T., CLR_BLUE, CLR_WHITE, 100, 30)
						oFootAtu:Align := CONTROL_ALIGN_LEFT
						oFootAtu:Hide()
						
						oFootDes := TSay():New(4, 10, {|| "  Há itens ainda não vinculados."}, oPanelBot, , TFont():New('Arial', , -12, , .T.), , , , .T., CLR_RED, CLR_WHITE, 100, 30)
						oFootDes:Align := CONTROL_ALIGN_LEFT
						oFootDes:Show()*/
						
		ACTIVATE MSDIALOG oDlgNFeC CENTERED
		
	End Sequence
	
	SetKey(VK_F7, {|| })
	
	//RefreshTab()
	//RefreshLog()
	
Return

////////////////////////////////////////

User Function GO1TOT()

	If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "I;P;C"
	
		GDFieldPut(_cCmp2 + "_VUNIT", GDFieldGet(_cCmp2 + "_TOTAL", , .T.))
		
	EndIf
	
	oGetDNfs:oBrowse:Refresh()
	
Return .T.

////////////////////////////////////////

Static Function ImportNFeD()
	
	Local aItens     := {}
	Local nI, nX
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local aFields    := {_cCmp1 + "_FILIAL", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_DTEMIS", _cCmp1 + "_CODEMI", ;
	                     _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_EST", "NOUSER"}
	Local aUpdFlds   := {}
	Local aCabec
	Local aItens     := {}
	Local cProduto   := Space(TamSX3("D1_COD")[1])
	Local cStrXml    := ""
	Local cClasFis   := ""
	Local aAltItem   := {_cCmp2 + "_COD", _cCmp2 + "_QUANT2", _cCmp2 + "_TES", _cCmp2 + "_CF", _cCmp2 + "_VUNIT", _cCmp2 + "_TOTAL"}
	Local aAltNFs    := {}
	Local aNFsIni    := {"D2_OK", "D2_DOC", "D2_SERIE", "D2_CLIENTE", "D2_LOJA", "D2_EMISSAO", "D2_ITEM", "D2_COD", "D2_UM", "D2_QUANT", "D2_PRCVEN", "D2_TOTAL", "D2_TES", "D2_QTDEDEV", "D2_NUMSEQ", "D2_LOTECTL", "D2_NUMLOTE"}
	Local lConfirm   := .F.
	//Local cEnchOld   := GetMv("MV_ENCHOLD")
	Local aAchouNota := {}
	Local cBusca     := Space(nTamCmpNF)
	Local dEmisDe    := CToD("  /  /    ")
	Local dEmisAte   := CToD("  /  /    ")
	Local cCampProib := ""
	Local aTrocaEmit
	
	//Totais
	Private nValFrete
	Private nValSeguro
	Private nValDesp
	Private nValDesc
	Private nValMerc
	Private nValXIPI
	Private nValXST
	
	Private oLayerNFeD
	Private oGetDItem, oGetDNFs
	Private aHeadItem      := {}
	Private aColsItem
	Private aHeadNFs       := {}
	Private aColsNFs
	Private oBrwNFsIt
	Private aMarcNFs       := {}
	Private oFootAtu
	Private oFootDes
	Private cDescDev       := IIf((_cTab1)->&(_cCmp1 + "_TIPOEN")=="D", "devolução", "beneficiamento")
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private aComboCli      := {}
	Private cComboCli      := "1"
	Private oCombCli
	
	aTrocaEmit := U_CliForGO((_cTab1)->&(_cCmp1 + "_CGCEMI"), .T.)
	
	If aTrocaEmit[1] == 2 .And. aTrocaEmit[8] # "1"
		
		RecLock(_cTab1, .F.)
		
			(_cTab1)->&(_cCmp1 + "_CODEMI") := aTrocaEmit[2]
			(_cTab1)->&(_cCmp1 + "_LOJEMI") := aTrocaEmit[3]
			(_cTab1)->&(_cCmp1 + "_NATFIN") := aTrocaEmit[4]
			(_cTab1)->&(_cCmp1 + "_EST")    := aTrocaEmit[5]
			(_cTab1)->&(_cCmp1 + "_CONDPG") := aTrocaEmit[6]
		
		(_cTab1)->( MsUnlock() )
		
	ElseIf aTrocaEmit[1] == 2 .And. aTrocaEmit[8] == "1"
		
		//Aviso("Erro", "Cliente bloqueado no sistema, não poderá ser importado como devolução.", {"Ok"}, 2)
		U_GOSetEr("Fornecedor bloqueado no sistema, não poderá ser importado como normal.")
		
		Return .F.
		
	Else
		
		//Aviso("Erro", "Cliente inexistente no sistema.", {"Ok"}, 2)
		U_GOSetEr("Cliente inexistente no sistema.")
		
		Return .F.
		
	EndIf
	
	aAchouNota := NumNotas((_cTab1)->&(_cCmp1 + "_CHAVE"), (_cTab1)->&(_cCmp1 + "_DOC"), (_cTab1)->&(_cCmp1 + "_SERIE"), ;
	                       (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"), cEspNFe, (_cTab1)->&(_cCmp1 + "_DTEMIS"))
	
	// Se achou a nota importada
	If aAchouNota[1]
	
		If Aviso("Aviso", "A Nota Fiscal " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " já foi importada com o número: '" + aAchouNota[2] + "'. " + CRLF + ;
		         "Deseja marcá-la como Processada?", {"Sim", "Não"}, 2) == 1
		
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_DOC")    := aAchouNota[2]
				(_cTab1)->&(_cCmp1 + "_TIPOEN") := aAchouNota[3]
				
				(_cTab1)->&(_cCmp1 + "_TPCOMP") := aAchouNota[11]
				
				(_cTab1)->&(_cCmp1 + "_ESPECI") := aAchouNota[4]
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := aAchouNota[5]
				(_cTab1)->&(_cCmp1 + "_SERIE")  := aAchouNota[6]
				(_cTab1)->&(_cCmp1 + "_CODEMI") := aAchouNota[7]
				(_cTab1)->&(_cCmp1 + "_LOJEMI") := aAchouNota[8]
				(_cTab1)->&(_cCmp1 + "_CGCEMI") := aAchouNota[9]
				
			(_cTab1)->( MsUnlock() )
			
		EndIf
		
		Return .F.
	
	ElseIf aAchouNota[10]
		
		/*Aviso("Aviso", "A Nota Fiscal já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " + ;
		      "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      "problema de chave duplicada.", {"Ok"}, 2)*/
		
		U_GOSetEr("A Nota Fiscal já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " + ;
		      	   "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      	   "problema de chave duplicada.")
		
		Return .F.
		
	EndIf
	
	U_GOSetEr(,, .T.)
	
	SetKey(VK_F7, {|| CargaNFs(, cBusca, dEmisDe, dEmisAte)})
	
	
	Begin Sequence
		
		nValFrete  := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vFrete:Text)
		nValSeguro := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vSeg:Text)
		nValDesp   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vOutro:Text)
		nValDesc   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vDesc:Text)
		nValMerc   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vProd:Text)
		nValXIPI   := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vIPI:Text"))
		nValXST    := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vST:Text"))
		
		If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
			
			XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
			
		EndIf
		
		aComboCli := RtFilCli((_cTab1)->&(_cCmp1 + "_CGCEMI"))
		
		DEFINE MSDIALOG oDlgNFeD FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE 'Importador - Nota Fiscal de ' + cDescDev COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
			oDlgNFeD:lEscClose := .F.
			
			oLayerNFeD := FWLayer():New()
			oLayerNFeD:Init(oDlgNFeD, .F.)
			
			oLayerNFeD:AddLine('TOP', 29, .F.)
			
				oLayerNFeD:AddCollumn('NFED_INFO', 100, .T., 'TOP')
				
					oLayerNFeD:AddWindow('NFED_INFO', 'WIN_NFED_INFO', "Informações da Nota Fiscal de " + IIf((_cTab1)->&(_cCmp1 + "_TIPOEN")=="D", "Devolução", "Beneficiamento") + " a ser importada", 100, .F., .T., , 'TOP', )
					
						RegToMemory(_cTab1)
						//PutMv("MV_ENCHOLD", "2")
						oGetCab := MsMGet():New(_cTab1, , MODEL_OPERATION_UPDATE, , , , aFields, {0, 0, 0, 0}, aUpdFlds, ;
						                        , , , , oLayerNFeD:GetWinPanel('NFED_INFO', 'WIN_NFED_INFO', 'TOP'), , .T., , , .T., , , , , , , .T.)
						//PutMv("MV_ENCHOLD", cEnchOld)
						oGetCab:oBox:Align := CONTROL_ALIGN_ALLCLIENT
						
			oLayerNFeD:AddLine('CENTER', 33, .F.)
			
				oLayerNFeD:AddCollumn('NFED_ITEM', 100, .T., 'CENTER')
				
					oLayerNFeD:AddWindow('NFED_ITEM', 'WIN_NFED_ITEM', "Itens da Nota Fiscal de " + IIf((_cTab1)->&(_cCmp1 + "_TIPOEN")=="D", "Devolução", "Beneficiamento") + " a ser importada", 100, .F., .T., , 'CENTER', )
					
						dbSelectArea("SX3")
						SX3->( dbSetOrder(2) )
						
						If SX3->( dbSeek("D2_OK") )
						
							AAdd(aHeadItem, {"Vinculada?", _cCmp2 + "_OK", "@BMP", 9, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
							
						EndIf
						
						dbSelectArea("SX3")
						SX3->( dbSetOrder(1) )
						SX3->( dbSeek(_cTab2) )
						
						// Pré-Nota não tem informações fiscais.
						If lPreNota
							
							cCampProib := "|" + _cCmp2 + "_TES|" + _cCmp2 + "_CF|" + _cCmp2 + "_CLASFI"
							
						EndIf
						
						While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab2

							If !(AllTrim(SX3->X3_CAMPO) $ _cCmp2 + "_FILIAL|" + _cCmp2 + "_PEDIDO|" + _cCmp2 + "_ITEMPC|" + _cCmp2 + "_BASEIC|" + _cCmp2 + "_PICM|" + _cCmp2 + "_VALICM|" + _cCmp2 + "_BASEIP|" + _cCmp2 + "_IPI|" + _cCmp2 + "_VALIPI|" + _cCmp2 + "_CC|" + _cCmp2 + "_ITEMCTA|" + _cCmp2 + "_CLVL|" + _cCmp2 + "_NFORI|" + _cCmp2 + "_SERORI|" + _cCmp2 + "_ITORI" + _cCmp2 + "_CSTERP" + _cCmp2 + "_SEQIMP" + cCampProib) .And. AllTrim(SX3->X3_CAMPO) != (_cCmp2 + "_DESCTO")

								AAdd(aHeadItem, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
								
							EndIf
							
							SX3->( dbSkip() )
							
						EndDo
						
						// Pega a posição dos itens da Tab2
						_nPosItXml := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DESC"   , 10)})
						_nPosPedid := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_PEDIDO" , 10)})
						_nPosItePc := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_ITEMPC" , 10)})
						_nPosProdu := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_COD"    , 10)})
						_nPosDcPrd := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DSPROD" , 10)})
						_nPosNcm   := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_NCM"    , 10)})
						_nPosUm    := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_UM"     , 10)})
						_nPosUmFor := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_UMF"    , 10)})
						_nPosQtdFr := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_QUANT1" , 10)})
						_nPosQtdNo := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_QUANT2" , 10)})
						_nPosVlUnt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VUNIT"  , 10)})
						_nPosVlTot := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_TOTAL"  , 10)})
						_nPosTes   := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_TES"    , 10)})
						_nPosCdFis := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CF"     , 10)})
						_nPosConta := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CONTA"  , 10)})
						_nPosCtCus := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CC"     , 10)})
						_nPosItCon := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_ITEMCTA", 10)})
						_nPosClVal := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CLVL"   , 10)})
						_nPosBsIcm := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BASEIC" , 10)})
						_nPosAqIcm := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_PICM"   , 10)})
						_nPosVlIcm := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VALICM" , 10)})
						_nPosBsIpi := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BASEIP" , 10)})
						_nPosAqIpi := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_IPI"    , 10)})
						_nPosVlIpi := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VALIPI" , 10)})
						_nPosStTri := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CLASFI" , 10)})
						_nPosCSOSN := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_CSOSN" , 10)})
						
						_nPosBsISt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BASEST" , 10)})
						_nPosPIcSt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_PICMST" , 10)})
						_nPosVlISt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VLICST" , 10)})

						_nPosBsStA := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_BSSTAN" , 10)})
						_nPosPStA  := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_ALSTAN" , 10)})
						_nPosVlStA := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VLSTAN" , 10)})
						
						_nPosVlAnt := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_VLANTI" , 10)})
						
						_nPosLote  := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_LOTE" , 10)})
						_nPosDtFab := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DTFAB" , 10)})
						_nPosDtVld := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_DTVLD" , 10)})
						_nPosFciCd := AScan(aHeadItem, {|x| x[2] == PadR(_cCmp2 + "_FCICOD" , 10)})
						
						aColsItem := {}
						aMarcNFs  := Array(Len(oXml:_NfeProc:_Nfe:_InfNfe:_det))
						aFill(aMarcNFs, {"", "", "", "", "", "", "", "", ""})
						
						//-------------------- Carregar Itens do Xml no array
						
						For nI := 1 To Len(oXml:_NfeProc:_Nfe:_InfNfe:_det)
						
							cProduto := Space(TamSX3("B1_COD")[1])
							AAdd(aColsItem, Array(Len(aHeadItem) + 1))
							
							For nX := 1 To Len(aHeadItem)
							
								If !(aHeadItem[nX, 2] $ _cCmp2 + "_OK")
								
									aColsItem[nI, nX] := CriaVar(aHeadItem[nX, 2])
									
								EndIf
								
							Next nX
							
							aColsItem[nI, Len(aHeadItem) + 1] := .F.
							
							cQuery := "SELECT SA7.A7_PRODUTO FROM " + RetSqlName("SA7") + " SA7"
							cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
							cQuery += " SA7.A7_FILIAL = '" + xFilial("SA7") + "' AND "
							cQuery += " SA7.A7_CLIENTE = '" + M->&(_cCmp1 + "_CODEMI") + "' AND "
							cQuery += " SA7.A7_LOJA = '" + M->&(_cCmp1 + "_LOJEMI") + "' AND "
							cQuery += " SA7.A7_CODCLI = '" + AllTrim(Upper(StrTran(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text, "'"))) + "' AND "
							cQuery += " SA7.A7_PRODUTO <> ' '"
							
							If Select(cAlias) > 0
							
								(cAlias)->( dbCloseArea() )
								
							EndIf
							
							dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAlias, .F., .T.)
							
							
							If !(cAlias)->( Eof() )
							
								cProduto := (cAlias)->A7_PRODUTO
								
							EndIf
							
							If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nI) + "]:_imposto:_ICMS") == "O"
							
								SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_imposto:_ICMS XMLSTRING cStrXml
								
								If At("<ICMS", cStrXml) > 0
								
									cClasFis := SubStr(cStrXml, At("<orig>", cStrXml) + 6, 1) + SubStr(cStrXml, At("<CST>", cStrXml) + 5, 2)
									
									If SubStr(cClasFis, 1, 1) == "1"
										
										cClasFis := "2" + SubStr(cClasFis, 2, 2)
										
									EndIf
									
								EndIf
								
								If !U_GO1VLCST(cClasFis)
									
									cClasFis := "   "
									
								EndIf
								
							EndIf
							
							aColsItem[nI][1] := "BR_CANCEL" // Vinculada?
							
							// Desrição do Item (vindo do Xml no formato do Cliente)
							If _nPosItXml > 0
							
								aColsItem[nI][_nPosItXml] := SubStr(AllTrim(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_prod:_cProd:Text) + " - " + AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_xProd:Text), 1, 40)
								
							EndIf
							
							// Código do Produto
							If _nPosProdu > 0
							
								aColsItem[nI][_nPosProdu] := cProduto
								
							EndIf
							
							// Descrição do Produto
							If _nPosDcPrd > 0
							
								aColsItem[nI][_nPosDcPrd] := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC"), Space(TamSX3("B1_DESC")[1]))
								
							EndIf
							
							// Unidade de Medida
							If _nPosUmFor > 0
							
								aColsItem[nI][_nPosUmFor] := oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_uCom:Text 
								
							EndIf
							
							// Quantidade no XML
							If _nPosQtdFr > 0
							
								aColsItem[nI][_nPosQtdFr] := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_qCom:Text), 2)
								
							EndIf
							
							// Nossa Unidade de Medida
							If _nPosUm > 0
							
								aColsItem[nI][_nPosUm] := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_UM"), Space(TamSX3("B1_UM")[1]))
								
							EndIf
							
							// Quantidade da Nota de saída selecionada
							If _nPosQtdNo > 0
							
								aColsItem[nI][_nPosQtdNo] := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_qCom:Text), 2)
								
							EndIf
							
							// Valor unitário
							If _nPosVlUnt > 0
							
								aColsItem[nI][_nPosVlUnt] := Round(Val(oXml:_NfeProc:_Nfe:_InfNfe:_det[nI]:_Prod:_vUnCom:Text), 2)
								
							EndIf
							
							// Valor total
							If _nPosVlTot > 0
							
								aColsItem[nI][_nPosVlTot] := IIf(_nPosQtdFr > 0 .And. _nPosVlUnt > 0, Round(aColsItem[nI][_nPosQtdFr]*aColsItem[nI][_nPosVlUnt], 2), 0)
								
							EndIf
							
							// Tes
							If _nPosTes > 0
							
								aColsItem[nI][_nPosTes] := IIf(!Empty(cProduto), Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_TE"), Space(TamSX3("B1_TE")[1]))
								
							EndIf
							
							// Código Fiscal
							If _nPosCdFis > 0
							
								//aColsItem[nI][_nPosCdFis] := IIf(!Empty(aColsItem[nI][_nPosTes]), IIf(GETMV("MV_ESTADO") == M->&(_cCmp1 + "_EST"), "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + aColsItem[nI][_nPosTes], "F4_CF"), 2, 3), "")
								aColsItem[nI][_nPosCdFis] := IIf(GETMV("MV_ESTADO") == M->&(_cCmp1 + "_EST"), "1", "2") + SubStr(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_CFOP:Text, 2, 3)
								
							EndIf
							
							If !IsDevCFOP(oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_CFOP:Text)
								
								Aviso("Aviso", "No Item " + cValToChar(nI) + " o CFOP " + oXml:_nfeProc:_NFe:_infNFe:_det[nI]:_prod:_CFOP:Text + " não é de devolução e portanto a nota não poderá ser importada.", {"Ok"}, 2)
								Break
								
							EndIf
							
							// Classificação Fiscal
							If _nPosStTri > 0
							
								aColsItem[nI][_nPosStTri] := cClasFis
								
							EndIf
							
						Next nI
						
						(cAlias)->( dbCloseArea() )
						
						If Len(aMarcNFs) == 0
						
							Aviso("Aviso", "Não há itens vinculados a Nota Fiscal.", {"Ok"}, 2)
							Break
							
						EndIf
						
						oGetDItem := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltItem, 0, 999, Nil, Nil, "AlwaysFalse", oLayerNFeD:GetWinPanel('NFED_ITEM', 'WIN_NFED_ITEM', 'CENTER'), aHeadItem, aColsItem, "")
						oGetDItem:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						oGetDItem:bLinhaOk := {|| LimpaNfs(), .T.}
						
			oLayerNFeD:AddLine('MIDDLE', 33, .F.)
			
				oLayerNFeD:AddCollumn('NFED_NFS', 100, .T., 'MIDDLE')
				
					oLayerNFeD:AddWindow('NFED_NFS', 'WIN_NFED_NFS', "Itens das Notas Fiscais de origem (Saída)", 100, .F., .T., , 'MIDDLE', )
					
						dbSelectArea("SX3")
						SX3->( dbSetOrder(2) )
						
						For nI := 1 To Len(aNFsIni)
						
							If SX3->( dbSeek(aNFsIni[nI]) )
							
								AAdd(aHeadNFs, {Trim(X3Titulo()), SX3->X3_CAMPO, IIf(AllTrim(aNFsIni[nI]) == "D2_OK", "@BMP", SX3->X3_PICTURE), IIf(AllTrim(aNFsIni[nI]) == "D2_OK", 8, SX3->X3_TAMANHO), SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
								
							EndIf
							
						Next nI
						
						aColsNFs := {Array(Len(aHeadNFs) + 1)}
						ATail(aColsNFs)[Len(aHeadNFs) + 1] := .F.
						
						oGetDNFs := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAltNFs, 0, 999, Nil, Nil, "AlwaysFalse", oLayerNFeD:GetWinPanel('NFED_NFS', 'WIN_NFED_NFS', 'MIDDLE'), aHeadNFs, aColsNFs, {|| /*bChange*/})
						oGetDNFs:oBrowse:blDblClick := {|x, nCol| MarcaNFs()}
						oGetDNFs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						
			//----------------- Carrega NFs de Saída
			oLayerNFeD:AddLine('BOTTOM', 5, .F.)
			
				oLayerNFeD:AddCollumn('NFED_BAR', 100, .T., 'BOTTOM')
				
					oPanelBot := tPanel():New(0, 0, "", oLayerNFeD:GetColPanel('NFED_BAR', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oQuit := THButton():New(0, 0, "&Sair", oPanelBot, {|| oDlgNFeD:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oImp := THButton():New(0, 0, "&Importar " + Capital(cDescDev), oPanelBot, {|| lConfirm := .T., IIf(InsereNFeD(@lConfirm), oDlgNFeD:End(), )}, , , )
					oImp:nWidth  := 120
					oImp:nHeight := 10
					oImp:Align   := CONTROL_ALIGN_RIGHT
					oImp:SetColor(RGB(002, 070, 112), )
					
					oImp := THButton():New(0, 0, "&Desagrupar", oPanelBot, {|| DesagrXIt()}, , , )
					oImp:nWidth  := 120
					oImp:nHeight := 10
					oImp:Align   := CONTROL_ALIGN_RIGHT
					oImp:SetColor(RGB(002, 070, 112), )
					
					////// Objetos para busca da nota fiscal
					oEmisDe    := TGet():New(000, 002, {|u| IF(Pcount() > 0, dEmisDe := u, dEmisDe)}, oPanelBot, 040, 010, '@', , , , , , , .T., , , {|| .T.}, , , , , , , "dEmisDe", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Emis De", 2, , )
					
					oEmisAte    := TGet():New(000, 064, {|u| If(Pcount() > 0, dEmisAte := u, dEmisAte)}, oPanelBot, 040, 010, '@', , , , , , , .T., , , {|| .T.}, , , , , , , "dEmisAte", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Até", 2, , )
					
					oBusca    := TGet():New(000, 115, {|u| If(Pcount() > 0, cBusca := u, cBusca)}, oPanelBot, 045, 010, '@', , , , , , , .T., , , {|| .T.}, , , , , , , "cBusca", , , , .F./*lHasButton*/, .T./*lNoButton*/, , "Nota", 2, , )
					
					oCombCli := TComboBox():New(001, 174, {|u| If(PCount() > 0, cComboCli := u, cComboCli)}, aComboCli[1], 130, 10, oPanelBot,, /*{|| bChange}*/,,,, .T.,,,,,,,,, 'cComboCli', "Cliente")
					
					oBuscaBtn := tButton():New(000, 322, 'Filtrar', oPanelBot, {|| CargaNFs(, cBusca, dEmisDe, dEmisAte)}, 25, 12, , , , .T.)
					
		ACTIVATE MSDIALOG oDlgNFeD CENTERED
		
	End Sequence
	
	SetKey(VK_F7, {|| })
	
	//RefreshTab()
	//RefreshLog()
	
Return .T.

////////////////////////////////////////

Static Function DesagrXIt()
	
	Local aColsIt := AClone(oGetDItem:aCols) 
	Local nI
	
	//// Variáveis da tela
	Local oDlg1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oBtn1
	Local oBtn2
	Local lConfirma := .F.
	Local nLineAtu  := oGetDItem:nAt
	
	Private oGet1
	Private oGet2
	
	Private nQuantAnt := GDFieldGet(_cCmp2 + "_QUANT2", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)
	Private nQuantAtu := 0
	
	If nQuantAnt > 0
		
		oDlg1 := MSDialog():New(091,232,289,583,"Desagrupar item",,,.F.,,,,,,.T.,,,.T.)
		oSay1 := TSay():New(006,008,{||"Informe o valor da quantidade no novo item:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,152,008)
		oSay2 := TSay():New(028,008,{||"Qtde. item atual"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
		oSay3 := TSay():New(049,009,{||"Qtde. novo item"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
		oBtn1 := TButton():New(068,026,"Confirmar",oDlg1, {|| IIf(ConfDesg(), (lConfirma := .T., oDlg1:End()), )},044,016,,,,.T.,,"",,,,.F.)
		oBtn2 := TButton():New(068,099,"Cancelar",oDlg1, {|| oDlg1:End()},044,016,,,,.T.,,"",,,,.F.)
		oGet1 := TGet():New(024,056, {|u| IF(Pcount() > 0, nQuantAnt := u, nQuantAnt)},oDlg1,088,014,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",, {|| .F.},.F.,.F.,,.F.,.F.,"","nQuantAnt",, )
		oGet2 := TGet():New(044,056, {|u| IF(Pcount() > 0, nQuantAtu := u, nQuantAtu)},oDlg1,088,014,'@E 999,999.9999', {|| VldDesgr()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nQuantAtu",, )
		
		oDlg1:Activate(,,,.T.)
		
		If lConfirma .And. nQuantAtu > 0
			
			AAdd(aColsIt, Array(Len(aHeadItem) + 1))
			
			ATail(aColsIt)[Len(aHeadItem) + 1] := .F.
			
			For nI := 1 To Len(aHeadItem)
				
				If AllTrim(aHeadItem[nI][2]) == _cCmp2 + "_OK"
					
					ATail(aColsIt)[nI] := "BR_CANCEL"
					
				ElseIf AllTrim(aHeadItem[nI][2]) == _cCmp2 + "_QUANT2"
					
					ATail(aColsIt)[nI] := nQuantAtu
					
				ElseIf AllTrim(aHeadItem[nI][2]) == _cCmp2 + "_TOTAL"
					
					ATail(aColsIt)[nI] := nQUantAtu * GDFieldGet(_cCmp2 + "_VUNIT", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)
					
				Else
					
					ATail(aColsIt)[nI] := GDFieldGet(aHeadItem[nI][2], oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)
					
				EndIf
				
			Next nI
			
			AAdd(aMarcNFs, {"", "", "", "", "", "", "", "", ""})
			
			oGetDItem:SetArray(aColsIt, .T.)
			
			oGetDItem:oBrowse:Refresh()
			
			GDFieldPut(_cCmp2 + "_QUANT2", nQUantAnt, nLineAtu, oGetDItem:aHeader, oGetDItem:aCols)
			
			GDFieldPut(_cCmp2 + "_TOTAL", nQUantAnt * GDFieldGet(_cCmp2 + "_VUNIT", nLineAtu, , oGetDItem:aHeader, oGetDItem:aCols), nLineAtu, oGetDItem:aHeader, oGetDItem:aCols)
			
		EndIf
		
	Else
		
		Help(, , 'Quantidade zero', , "A quantidade do item selecionado não poderá ser 0 para desagrupar.", 1, 0)
		
	EndIf
	
Return

////////////////////////////////////////

Static Function ConfDesg()
	
	If nQuantAtu <= 0
		
		Help(, , 'Help', , "A nova quantidade não pode ser 0.", 1, 0)
		
		Return .F.
		
	EndIf
	
Return .T.

////////////////////////////////////////

Static Function VldDesgr() 
	
	If nQuantAtu >= GDFieldGet(_cCmp2 + "_QUANT2", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)
		
		Help(, , 'Help', , "A nova quantidade não pode ultrapassar a original.", 1, 0)
		
		Return .F.
			
	EndIf
	
	nQuantAnt := GDFieldGet(_cCmp2 + "_QUANT2", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols) - nQuantAtu
	
	oGet1:Refresh()
	
Return .T.

////////////////////////////////////////

Static Function InsereNFeD(lConfirm)
	
	Local nItem
	Local aCabec
	Local aItens           := {}
	Local aColsItem        := oGetDItem:aCols
	Local nPos
	Local aResp
	Local lRet             := .T.
	Local lErroRegra       := .F.
	Local cMsgRegra        := ""
	
	Local cOrigImpF        := AllTrim(GetNewPar("MV_ZGOORIF", ""))
	Local cOrigImpD        := AllTrim(GetNewPar("MV_ZGOORID", ""))
	
	Private lMsHelpAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	
	If _nPosProdu > 0 .And. (nPos := aScan(aColsItem, {|x| Empty(x[GDFieldPos(_cCmp2 + "_COD", oGetDItem:aHeader)])})) > 0
	
		Help(, , 'Help', , "O campo do Produto deve ser informado para o item da Nota Fiscal na linha " + cValToChar(nPos) + ".", 1, 0)
		Return .F.
		
	EndIf
	
	If _nPosTes > 0 .And. (nPos := aScan(aColsItem, {|x| Empty(x[GDFieldPos(_cCmp2 + "_TES", oGetDItem:aHeader)])})) > 0
	
		Help(, , 'Help', , "O campo do TES deve ser informado para o item da Nota Fiscal na linha " + cValToChar(nPos) + ".", 1, 0)
		Return .F.
		
	EndIf
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") # "B" .And. AScan(aMarcNFs, {|x| Empty(x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7]+ x[8] + x[9])}) > 0
		
		If GetNewPar("MV_ZOBGNFD", .T.) // Obriga nota Origem
			
			Help(,, 'Help',, "Todos os itens da Nota Fiscal de " + cDescDev + " devem estar relacionados a um item de uma Nota Fiscal de " + IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") $ "I;P;C", "Entrada", "Saída") + ".", 1, 0)
			Return .F.
			
		Else
			
			If Aviso("Aviso", "Há notas sem origem informada, deseja importar com uma nota origem padrão (999999999) ?", {"Sim", "Não"}, 2) <> 1
				
				Return .F.
				
			EndIf
			
		EndIf
		
	EndIf
	
	// Validação do CST, não permitir que um produto no XML com origem 0 seja vinculado a um produto de origem diferente de 0
	
	If (_cTab1)->&(_cCmp1 + "_LIBER") # "1"
		
		CleanRegra()
		
		For nItem := 1 To Len(aColsItem)
			
			If U_GO1VLCST(GDFieldGet(_cCmp2 + "_CLASFI", nItem,, oGetDItem:aHeader, aColsItem))
				
				dbSelectArea("SB1")
				SB1->( dbSetOrder(1) )
				If SB1->( dbSeek(xFilial("SB1") + GDFieldGet(_cCmp2 + "_COD", nItem,, oGetDItem:aHeader, aColsItem)) )
					
					If SubStr(GDFieldGet(_cCmp2 + "_CLASFI", nItem,, oGetDItem:aHeader, aColsItem), 1, 1) == "0" .And. SB1->B1_ORIGEM # SubStr(GDFieldGet(_cCmp2 + "_CLASFI", nItem,, oGetDItem:aHeader, aColsItem), 1, 1)
						
						lErroRegra := .T.
						
						cMsgRegra  := "O produto na linha " + cValToChar(nItem) + " possui origem (" + cValToChar(SB1->B1_ORIGEM) + "), porém, a origem no XML é (" + SubStr(GDFieldGet(_cCmp2 + "_CLASFI", nItem,, oGetDItem:aHeader, aColsItem), 1, 1) + "). Será necessário solicitar liberação ao setor responsável."
						
						AddErroRegra(oGetDItem, nItem, 1)
						
					EndIf
					
				EndIf
				
			EndIf
			
		Next nItem
		
		If lErroRegra
			
			SetErroRegra("Existem produtos dos quais a origem do CST está diferente do produto com o do XML.")
			
			Help(,, 'Help',, cMsgRegra, 1, 0)
			
			Return .F.
			
		EndIf
		
	EndIf
	
	aCabec := {{"F1_DOC"    , (_cTab1)->&(_cCmp1 + "_DOC")                             , Nil, Nil}, ;
	           {"F1_SERIE"  , (_cTab1)->&(_cCmp1 + "_SERIE")                           , Nil, Nil}, ;
	           {"F1_FORNECE", (_cTab1)->&(_cCmp1 + "_CODEMI")                          , Nil, Nil}, ;
	           {"F1_LOJA"   , (_cTab1)->&(_cCmp1 + "_LOJEMI")                          , Nil, Nil}, ;
	           {"F1_EMISSAO", (_cTab1)->&(_cCmp1 + "_DTEMIS")                          , Nil, Nil}, ;
	           {"F1_DTDIGIT", dDataBase                                                , Nil, Nil}, ;      
	           {"F1_EST"    , (_cTab1)->&(_cCmp1 + "_EST")                             , Nil, Nil}, ;      
	           {"F1_TIPO"   , (_cTab1)->&(_cCmp1 + "_TIPOEN")                          , Nil, Nil}, ;
	           {"F1_ESPECIE", cEspNFe					                               , Nil, Nil}, ;
	           {"F1_FORMUL" , "N"					    	                           , Nil, Nil}, ;
	           {"F1_CHVNFE" , (_cTab1)->&(_cCmp1 + "_CHAVE")                           , Nil, Nil}, ;
	           {"F1_VALMERC", nValMerc                                                 , Nil, Nil}, ;
	           {"F1_FRETE"  , nValFrete                                                , Nil, Nil}, ;
	           {"F1_DESPESA", nValDesp                                                 , Nil, Nil}, ;
	           {"F1_DESCONT", nValDesc                                                 , Nil, Nil}, ;
	           {"F1_SEGURO" , nValSeguro                                               , Nil, Nil}, ;
	           {"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil}  ;
	          }
	
    //_TIPOEN - N=Normal;D=Devolucao;B=Beneficiamento;I=Comp.ICMS;P=Comp.IPI;C=Comp.Preco/Frete
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") == "C"
		
		AIns(aCabec, 9)
		aCabec[9] := {"F1_TPCOMPL", (_cTab1)->&(_cCmp1 + "_TPCOMP"), Nil, Nil}

        //Complemento sem Condição de Pagamento - Agricopel - NF 33210910456016000248550010001451921162565299
        if len(aMarcNFs) > 0    

            SF1->(dbSetOrder(1))
            if SF1->(dbSeek(xFilial('SF1') + aMarcNFs[1][1] + aMarcNFs[1][2] + aMarcNFs[1][3] + aMarcNFs[1][4]))
                AAdd(aCabec, {"F1_COND", SF1->F1_COND, Nil, nil})
            endif

        endif
		
	EndIf
	
	If !Empty(cOrigImpF) // Origem do Lançamento
		
		AAdd(aCabec, {cOrigImpF, "GOX001", Nil})
		
	EndIf
	
	For nItem := 1 To Len(aColsItem)
	
		AAdd(aItens, {{"D1_ITEM"   , StrZero(nItem, 4)                                                   , Nil}, ;
		              {"D1_COD"	   , GDFieldGet(_cCmp2 + "_COD", nItem,, oGetDItem:aHeader, aColsItem)   , Nil}, ;
    				  {"D1_UM"     , GDFieldGet(_cCmp2 + "_UM", nItem,, oGetDItem:aHeader, aColsItem)    , Nil}, ;
		              {"D1_VUNIT"  , GDFieldGet(_cCmp2 + "_VUNIT", nItem,, oGetDItem:aHeader, aColsItem) , Nil}, ;
	    	          {"D1_TOTAL"  , GDFieldGet(_cCmp2 + "_TOTAL", nItem,, oGetDItem:aHeader, aColsItem) , Nil}, ;
	    	          ;//{"D1_TIPO"   , (_cTab1)->&(_cCmp1 + "_TIPOEN")                                     , Nil}, ;
	    	          {"D1_SERIE"  , (_cTab1)->&(_cCmp1 + "_SERIE")                                      , Nil}, ;
					  {"D1_NFORI"  , IIf(Empty(aMarcNFs[nItem][1]), "999999999", aMarcNFs[nItem][1])     , Nil}, ;
	    	          {"AUTDELETA" , "N"			                                                     , Nil}  ;
	    	         })
		
		If !Empty(aMarcNFs[nItem][1])
			
			AAdd(ATail(aItens), {"D1_SERIORI", aMarcNFs[nItem][2], Nil})
			AAdd(ATail(aItens), {"D1_ITEMORI", aMarcNFs[nItem][6], Nil})
			
		EndIf
		
		If !Empty(cOrigImpD) // Origem do Lançamento
			
			AAdd(ATail(aItens), {cOrigImpD, "GOX001", Nil})
			
		EndIf
		
		If !lPreNota
			
			AAdd(ATail(aItens), {})
			AIns(ATail(aItens), 6)
			ATail(aItens)[6] := {"D1_TES", GDFieldGet(_cCmp2 + "_TES", nItem,, oGetDItem:aHeader, aColsItem), Nil}
			
			AAdd(ATail(aItens), {"D1_CLASFIS", GDFieldGet(_cCmp2 + "_CLASFI", nItem,, oGetDItem:aHeader, aColsItem), Nil})
			
		EndIf
		
	 	If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B"
			
			AAdd(ATail(aItens), {"D1_IDENTB6", aMarcNFs[nItem][7], Nil})
			
			// Se possui Rastreio
			
			If GetNewPar("MV_XGTLOTE", .F.) .And. Rastro(GDFieldGet(_cCmp2 + "_COD", nItem,, oGetDItem:aHeader, aColsItem))
				
				If !Empty(aMarcNFs[nItem][8])
					
					AAdd(ATail(aItens), {"D1_LOTECTL", aMarcNFs[nItem][8], Nil})
					
					If !Empty(aMarcNFs[nItem][9])
						
						AAdd(ATail(aItens), {"D1_NUMLOTE", aMarcNFs[nItem][9], Nil})
						
					EndIf
					
				EndIf
				
			EndIf
			
			// Adicionado um elemento vazio, pois a função AIns elimina o último elemento do array.
			AAdd(ATail(aItens), {})
			
	 		AIns(ATail(aItens), 4)

	 		ATail(aItens)[4] := {"D1_QUANT", GDFieldGet(_cCmp2 + "_QUANT2", nItem, , oGetDItem:aHeader, aColsItem), Nil}
			
			//[TODO] Verificar, pois nesses casos ele pega pela tes de devolução cadastrada na tes de origem.
			/*If GetNewPar("MV_ZGOTSIN", .F.)
				
				// Amarração de Tes Inteligente
				GOXTESAm(GDFieldGet(_cCmp2 + "_COD", nItem,, oGetDItem:aHeader, aColsItem), M->&(_cCmp1 + "_CODEMI"), M->&(_cCmp1 + "_LOJEMI"), GDFieldGet(_cCmp2 + "_TES", nItem,, oGetDItem:aHeader, aColsItem), "2")
				
			EndIf*/
			
			dbSelectArea("SA7")
			SA7->( dbSetOrder(2) )
			
			If !SA7->( dbSeek(xFilial("SA7") + PadR(GDFieldGet(_cCmp2 + "_COD", nItem,, oGetDItem:aHeader, aColsItem), TamSX3("A5_PRODUTO")[1]) + M->&(_cCmp1 + "_CODEMI") + M->&(_cCmp1 + "_LOJEMI")) )
				
				RecLock("SA7", .T.)
				
					SA7->A7_FILIAL  := xFilial("SA7")
					SA7->A7_PRODUTO := GDFieldGet(_cCmp2 + "_COD", nItem,, oGetDItem:aHeader, aColsItem)
					SA7->A7_CLIENTE := PadR(M->&(_cCmp1 + "_CODEMI"), TamSX3("A7_CLIENTE")[1])
					SA7->A7_LOJA    := PadR(M->&(_cCmp1 + "_LOJEMI"), TamSX3("A7_LOJA")[1])
					SA7->A7_CODCLI  := SubStr(GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem), 1, At(" - [", GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem)) - 1)
					SA7->A7_DESCCLI := SubStr(GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem), At(" - [", GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem)) + 3)
					
				SA7->( MsUnlock() )
				
			Else
			
				RecLock("SA7", .F.)
				
					SA7->A7_CODCLI  := SubStr(GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem), 1, At(" - [", GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem)) - 1)
					SA7->A7_DESCCLI := SubStr(GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem), At(" - [", GDFieldGet(_cCmp2 + "_DESC", nItem,, oGetDItem:aHeader, aColsItem)) + 3)
					
				SA7->( MsUnlock() )
				
			EndIf
			
		EndIf
		
	Next nItem
	
	//Begin Transaction
	
		If lPreNota
		
			MsAguarde({|| MsExecAuto({|x, y, z, w, k| MATA140(x, y, z, w, k)}, aCabec, aItens, 3, .F., 1)}, "Pré-nota de entrada", "Importando Nota Fiscal " + cDescDev + " como Pré-nota...")
			
		Else
		
			MsAguarde({|| MsExecAuto({|x, y, z, w| Mata103(x, y, z, w)}, aCabec, aItens, 3, .T./*lConfere*/)}, "Importação", "Importando Nota Fiscal de " + cDescDev + "...")
			
		EndIf
		
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		
		If !lMsErroAuto .And. !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
		
			lConfirm := .F.
			lRet     := .F.
			
		ElseIf lMsErroAuto
			
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")  := "3"
				(_cTab1)->&(_cCmp1 + "_ERRO") := MontaErro(GetAutoGrLog())
				
			(_cTab1)->( MsUnlock() )
			
			ExibeErro()
			
			lRet := .F.
			
		Else
			
			RecLock("SF1")
				
				SF1->&(cOrigImpF) := "GOX001"
				
			SF1->( MSUnlock() )
			
			dbSelectArea("SD1")
			SD1->( dbSetOrder(1) )
			SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
			
			While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
					SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
				
				RecLock("SD1")
					
					SD1->&(cOrigImpD) := "GOX001"
					
				SD1->( MSUnlock() )
				
				SD1->( dbSkip() )
					
			EndDo
			
			RecLock(_cTab1, .F.)
				
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_ESPECI") := cEspNFe
				(_cTab1)->&(_cCmp1 + "_NATFIN") := M->&(_cCmp1 + "_NATFIN")
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := dDataBase
				(_cTab1)->&(_cCmp1 + "_HRIMP")  := Time()
				(_cTab1)->&(_cCmp1 + "_USUIMP") := cUserName
				
			(_cTab1)->( MsUnlock() )
			
			oGOLog:Add("Importação da Nota Fiscal de " + cDescDev + " realizada com sucesso.", 1)
			oGOLog:NewLine()
			
			//aResp := U_CriRespArq("NFE", {(_cTab1)->&(_cCmp1 + "_CHAVE")})
			
			/*If aResp[1]
			
				oGOLog:Add("Arquivo de resposta para o portal criado com sucesso: " + aResp[2] + ".", 1)
				
			Else
			
				oGOLog:Add("***Erro ao gerar arquivo de resposta para o portal." + cValToChar(FError()))
				
			EndIf*/
			
			//Aviso("Aviso", "Importação realizada com sucesso!", {"Ok"}, 2)
			
		EndIf
		
	//End Transaction
	
Return lRet

////////////////////////////////////////

Static Function LimpaNFs()

	Local aCols	:= {Array(Len(aHeadNFs) + 1)}
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B"
	
		oLayerNFeD:SetWinTitle('NFED_NFS', 'WIN_NFED_NFS', "Filtre o item para buscar as notas fiscais de Saída", 'MIDDLE')
		
	Else
	
		oLayerNFeC:SetWinTitle('NFEC_NFE', 'WIN_NFEC_NFE', "Filtre o item para buscar as notas fiscais de Entrada", 'MIDDLE')
		
	EndIf
	
	ATail(aCols)[Len(aHeadNFs) + 1] := .F.
	oGetDNFs:SetArray(aCols, .T.)
	oGetDNFs:oBrowse:Refresh()
	
Return

////////////////////////////////////////

Static Function CargaNFs(lRefresh, cNota, dEmisDe, dEmisAte)

	Local nX
	Local cQuery
	Local cAlias
	Local aCols	 := {Array(Len(aHeadNFs) + 1)}
	Local cTab   := IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") $ "I;P;C", "SD1", "SD2")
	//------------Valores da busca
	Local cProduto := GDFieldGet(_cCmp2 + "_COD", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)
	Local aCompCli
	
	Default lRefresh := .T.
	Default cNota    := ""
	Default dEmisDe  := CToD("  /  /    ")
	Default dEmisAte := CToD("  /  /    ")
	
	ATail(aCols)[Len(aHeadNFs) + 1] := .F.
	CursorWait()
	
	If Empty(cProduto)
	
		CursorArrow()
		Return .F.
		
	EndIf
	
	cAlias := GetNextAlias()
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "I;P;C"
	
		oLayerNFeC:SetWinTitle('NFEC_NFE', 'WIN_NFEC_NFE', "Itens das Notas Fiscais de origem (Entrada) para o item " + AllTrim(GDFieldGet(_cCmp2 + "_COD", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)) + " - " + AllTrim(GDFieldGet(_cCmp2 + "_DSPROD", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)), 'MIDDLE')
		
		cQuery := " SELECT SD1.R_E_C_N_O_ TBRECNO "
		cQuery += " FROM " + RetSqlName("SF1") + " SF1"
		cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1"
		cQuery += " 	ON SD1.D1_FILIAL  = SF1.F1_FILIAL AND "
		cQuery += " 	   SD1.D1_FORNECE = SF1.F1_FORNECE AND "
		cQuery += " 	   SD1.D1_LOJA    = SF1.F1_LOJA AND "
		cQuery += " 	   SD1.D1_DOC     = SF1.F1_DOC AND "
		cQuery += " 	   SD1.D1_SERIE   = SF1.F1_SERIE AND "
		cQuery += " 	   SD1.D1_TIPO    = SF1.F1_TIPO "
		cQuery += " WHERE "
		
		If lCompCli
		
			aCompCli := ClientesCNPJ((_cTab1)->&(_cCmp1 + "_CGCEMI"))
			
			If Empty(aCompCli[1])
			
				Help(, , 'Help', , "Não existe cliente para este CNPJ.", 1, 0)
				
			EndIf
			
			cQuery += " 	SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
			cQuery += " 	SF1.F1_FORNECE = '" + aCompCli[1] + "' AND "
			cQuery += " 	SF1.F1_LOJA    = '" + aCompCli[2] + "' AND "
			cQuery += "     SD1.D1_COD     = '" + cProduto + "' AND "
			cQuery += " 	SD1.D1_ORIGLAN <> 'LF' AND "
			cQuery += " 	SD1.D1_TIPO IN('D', 'B') AND "
			cQuery += " 	SF1.D_E_L_E_T_ = ' ' AND "
			cQuery += " 	SD1.D_E_L_E_T_ = ' ' "
			
		Else
		
			cQuery += " 	SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
			cQuery += " 	SF1.F1_FORNECE = '" + M->&(_cCmp1 + "_CODEMI") + "' AND "
			cQuery += " 	SF1.F1_LOJA    = '" + M->&(_cCmp1 + "_LOJEMI") + "' AND "
			cQuery += "     SD1.D1_COD     = '" + cProduto + "' AND "
			cQuery += " 	SD1.D1_ORIGLAN <> 'LF' AND "
			cQuery += " 	SD1.D1_TIPO NOT IN('D', 'B', 'P', 'I') AND "
			cQuery += " 	SF1.D_E_L_E_T_ = ' ' AND "
			cQuery += " 	SD1.D_E_L_E_T_ = ' ' "
			
		EndIf
		
		If !Empty(cNota)
		
			cQuery += " AND SF1.F1_DOC LIKE '%" + AllTrim(cNota) + "%' "
			
		EndIf
		
		If !Empty(dEmisDe)
		
			cQuery += " AND SF1.F1_EMISSAO >= '" + DToS(dEmisDe) + "' "
			
		EndIf
		
		If !Empty(dEmisAte)
		
			cQuery += " AND SF1.F1_EMISSAO <= '" + DToS(dEmisAte) + "' "
			
		EndIf
		
		cQuery += " AND SF1.F1_EMISSAO <= '" + DToS(M->&(_cCmp1 + "_DTEMIS")) + "' "
		
		cQuery += " ORDER BY "
		cQuery += " 	SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM "
		
	Else
	
		oLayerNFeD:SetWinTitle('NFED_NFS', 'WIN_NFED_NFS', "Itens das Notas Fiscais de origem (Saída) para o item " + AllTrim(GDFieldGet(_cCmp2 + "_COD", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)) + " - " + AllTrim(GDFieldGet(_cCmp2 + "_DSPROD", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)), 'MIDDLE')
		
		cQuery := " SELECT SD2.R_E_C_N_O_ TBRECNO "
		cQuery += " FROM " + RetSqlName("SF2") + " SF2"
		cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2"
		cQuery += " 	ON SD2.D2_FILIAL = SF2.F2_FILIAL AND "
		cQuery += " 	SD2.D2_CLIENTE   = SF2.F2_CLIENTE AND "
		cQuery += " 	SD2.D2_LOJA      = SF2.F2_LOJA AND "
		cQuery += " 	SD2.D2_DOC       = SF2.F2_DOC AND "
		cQuery += " 	SD2.D2_SERIE     = SF2.F2_SERIE AND "
		cQuery += " 	SD2.D2_TIPO      = SF2.F2_TIPO "
		cQuery += " WHERE "
		cQuery += " 	SF2.F2_FILIAL  = '" + xFilial("SF2") + "' AND "
		
		If (_cTab1)->&(_cCmp1 + "_TIPOEN") == "D"
		
			cQuery += " SF2.F2_CLIENTE = '" + aComboCli[2][Val(cComboCli)][1] + "' AND "
			cQuery += " SF2.F2_LOJA    = '" + aComboCli[2][Val(cComboCli)][2] + "' AND "
			
		Else
		
			cQuery += " SF2.F2_CLIENTE = '" + M->&(_cCmp1 + "_CODEMI") + "' AND "
			cQuery += " SF2.F2_LOJA    = '" + M->&(_cCmp1 + "_LOJEMI") + "' AND "
			
		EndIf
		
		cQuery += "     SD2.D2_COD     = '" + cProduto + "' AND "
		cQuery += " 	SD2.D2_ORIGLAN <> 'LF' AND "
		cQuery += " 	SD2.D2_QUANT > D2_QTDEDEV AND "
		cQuery += " 	SF2.D_E_L_E_T_ = ' ' AND "
		cQuery += " 	SD2.D_E_L_E_T_ = ' ' "
		
		If !Empty(cNota)
		
			cQuery += " AND SF2.F2_DOC LIKE '%" + AllTrim(cNota) + "%' "
			
		EndIf
		
		If !Empty(dEmisDe)
		
			cQuery += " AND SF2.F2_EMISSAO >= '" + DToS(dEmisDe) + "' "
			
		EndIf
		
		If !Empty(dEmisAte)
		
			cQuery += " AND SF2.F2_EMISSAO <= '" + DToS(dEmisAte) + "' "
			
		EndIf
		
		cQuery += " AND SF2.F2_EMISSAO <= '" + DToS(M->&(_cCmp1 + "_DTEMIS")) + "' "
		
		cQuery += " ORDER BY "
		cQuery += " 	SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_ITEM "
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .T., .T.)
	
	If !(cAlias)->( Eof() )
	
		aCols := {}
		
	EndIf
	
	While !(cAlias)->( Eof() )
	
		AAdd(aCols, Array(Len(aHeadNFs) + 1))
		ATail(aCols)[Len(aHeadNFs) + 1] := .F.
		
		dbSelectArea(cTab)
		(cTab)->( dbSetOrder(1) )
		(cTab)->( dbGoTo((cAlias)->TBRECNO) )
		
		For nX := 1 To Len(aHeadNFs)
		
			If AllTrim(aHeadNFs[nX, 2]) $ "D2_OK;D1_OK"
			
				If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B"
				
					If SD2->D2_DOC     == aMarcNFs[oGetDItem:nAt][1] .And. SD2->D2_SERIE == aMarcNFs[oGetDItem:nAt][2] .And.;
					   SD2->D2_CLIENTE == aMarcNFs[oGetDItem:nAt][3] .And. SD2->D2_LOJA  == aMarcNFs[oGetDItem:nAt][4] .And.;
					   SD2->D2_COD     == aMarcNFs[oGetDItem:nAt][5] .And. SD2->D2_ITEM  == aMarcNFs[oGetDItem:nAt][6]
					
						ATail(aCols)[nX] := "BR_VERDE"
						
					Else
					
						ATail(aCols)[nX] := Space(8)
						
					EndIf
					
				Else
				
					If SD1->D1_DOC     == aMarcNFs[oGetDItem:nAt][1] .And. SD1->D1_SERIE == aMarcNFs[oGetDItem:nAt][2] .And.;
					   SD1->D1_FORNECE == aMarcNFs[oGetDItem:nAt][3] .And. SD1->D1_LOJA  == aMarcNFs[oGetDItem:nAt][4] .And.;
					   SD1->D1_COD     == aMarcNFs[oGetDItem:nAt][5] .And. SD1->D1_ITEM  == aMarcNFs[oGetDItem:nAt][6]
					
						ATail(aCols)[nX] := "BR_VERDE"
						
					Else
					
						ATail(aCols)[nX] := Space(8)
						
					EndIf
					
				EndIf
				
			Else
			
				ATail(aCols)[nX] := &(cTab + "->" + aHeadNFs[nX, 2])
				
			EndIf
			
		Next nX
		
		(cAlias)->( dbSkip() )
		
	EndDo
	
	oGetDNFs:SetArray(aCols, .T.)
	
	If lRefresh
	
		If Len(aCols) > 0
		
			oGetDNFs:oBrowse:GoTop()
			
		EndIf
		
		oGetDNFs:oBrowse:Refresh()
		
	EndIf
	
	(cAlias)->( dbCloseArea() )
	CursorArrow()
	
Return aCols

////////////////////////////////////////

Static Function MarcaNFs()

	Local nI
	Local cImg := "BR_VERDE"
	Local cEmit
	Local cCmp
	Local cDesc
	Local cVUnit
	Local cTes := ""
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "I;P;C"
	
		cEmit  := "D1_FORNECE"
		cCmp   := "D1"
		cDesc  := "Entrada"
		cVUnit := "D1_VUNIT"
		
	Else
	
		cEmit  := "D2_CLIENTE"
		cCmp   := "D2"
		cDesc  := "Saída"
		cVUnit := "D2_PRCVEN"
		
	EndIf
	
	If GDFieldGet(cCmp + "_OK", oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols) == cImg
	
		GDFieldPut(cCmp + "_OK", Space(8), oGetDNfs:nAt, oGetDNfs:aHeader, oGetDNfs:aCols)
		GDFieldPut(_cCmp2 + "_OK", "BR_CANCEL", oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
		aMarcNFs[oGetDItem:nAt] := {"", "", "", "", "", "", "", "", ""}
		
	Else
	
		If Empty(GDFieldGet(cCmp + "_DOC", oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols))
		
			Aviso("Aviso", "Não foram encontrados itens de Notas Fiscais de " + cDesc + " para selecionar.", {"Ok"}, 2)
			Return
			
		EndIf
		
		For nI := 1 To Len(oGetDNfs:aCols)
		
			GDFieldPut(cCmp + "_OK", Space(8), nI, oGetDNfs:aHeader, oGetDNfs:aCols)
			
		Next nI
		
		GDFieldPut(cCmp + "_OK", cImg, oGetDNfs:nAt, oGetDNfs:aHeader, oGetDNfs:aCols)
		GDFieldPut(_cCmp2 + "_OK", "CHECKOK", oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
		aMarcNFs[oGetDItem:nAt] := {GDFieldGet(cCmp + "_DOC", oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols), ;
		GDFieldGet(cCmp + "_SERIE", oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols), ;
		GDFieldGet(cEmit, oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols), ;
		GDFieldGet(cCmp + "_LOJA", oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols), ;
		GDFieldGet(cCmp + "_COD", oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols), ;
		GDFieldGet(cCmp + "_ITEM", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
		GDFieldGet(cCmp + "_NUMSEQ", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
		GDFieldGet(cCmp + "_LOTECTL", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols),;
		GDFieldGet(cCmp + "_NUMLOTE", oGetDNfs:nAt,, oGetDNfs:aHeader, oGetDNfs:aCols)}
		
		If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B" .And. GDFieldGet(cVUnit, oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols) # GDFieldGet(_cCmp2 + "_VUNIT", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols)
		
			If Aviso("Preço unitário", "O preço unitário da Nota Fiscal de origem é " + AllTrim(Transform(GDFieldGet(cVUnit, oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols), "@E 999,999,999.99")) + ;
			         " e do item do XML " + AllTrim(Transform(GDFieldGet(_cCmp2 + "_VUNIT", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols), "@E 999,999,999.99")) + ". " + ;
			         "Deseja substituir o valor com o da Nota Fiscal de origem?", {"Substituir", "Manter"}, 2) == 1
			
				GDFieldPut(_cCmp2 + "_VUNIT", GDFieldGet(cVUnit, oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols), oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
				GDFieldPut(_cCmp2 + "_TOTAL", GDFieldGet(cVUnit, oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols)*GDFieldGet(_cCmp2 + "_QUANT2", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols), oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
				
			EndIf
			
		EndIf
		
		If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D"
			
			If !lPreNota
				
				dbSelectArea("SF4")
				SF4->( dbSetOrder(1) )
				If SF4->( dbSeek(xFilial("SF4") + GDFieldGet(cCmp + "_TES", oGetDNfs:nAt, , oGetDNfs:aHeader, oGetDNfs:aCols)) ) .And. !Empty(SF4->F4_TESDV)
					
					cTesDev := SF4->F4_TESDV
					
					GDFieldPut(_cCmp2 + "_TES", cTesDev, oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
					
					GDFieldPut(_cCmp2 + "_CF", RetCF(cTesDev, IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "N", cEstado, M->&(_cCmp1 + "_EST"))), oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
					
					GDFieldPut(_cCmp2 + "_CLASFI", SubStr(GDFieldGet(_cCmp2 + "_CLASFI", oGetDItem:nAt, , oGetDItem:aHeader, oGetDItem:aCols), 1, 1) + Posicione("SF4", 1, xFilial("SF4") + cTesDev, "F4_SITTRIB"), oGetDItem:nAt, oGetDItem:aHeader, oGetDItem:aCols)
					
				EndIf
				
			EndIf
			
			// Bloqueio de regra na seleção da nota origem
			If (_cTab1)->&(_cCmp1 + "_LIBER") # "1"
				
				If U_GO1VLCST(GDFieldGet(_cCmp2 + "_CLASFI", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols))
					
					dbSelectArea("SB1")
					SB1->( dbSetOrder(1) )
					If SB1->( dbSeek(xFilial("SB1") + GDFieldGet(_cCmp2 + "_COD", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols)) )
						
						If SubStr(GDFieldGet(_cCmp2 + "_CLASFI", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols), 1, 1) == "0" .And. SB1->B1_ORIGEM # SubStr(GDFieldGet(_cCmp2 + "_CLASFI", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols), 1, 1)
							
							cMsgRegra := "O produto desta nota possui origem (" + cValToChar(SB1->B1_ORIGEM) + "), porém, a origem no XML é (" + SubStr(GDFieldGet(_cCmp2 + "_CLASFI", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols), 1, 1) + "). Será necessário solicitar liberação ao setor responsável."
							
							If !ExisteRegra(GDFieldGet(_cCmp2 + "_DESC", oGetDItem:nAt,, oGetDItem:aHeader, oGetDItem:aCols))
								
								AddErroRegra(oGetDItem, oGetDItem:nAt, 1)
								
								SetErroRegra(cMsgRegra)
								
							EndIf
							
							Help(,, 'Help',, cMsgRegra, 1, 0)
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	oGetDItem:oBrowse:Refresh()
	oGetDNfs:oBrowse:Refresh()
	
Return

Static aNatAnt := {"", ""}

/* ####################################################################### *\
|| #       FUNÇÃO DE IMPORTAÇÃO DO XML DE NOTA FISCAL SELECIONADO        # ||
\* ####################################################################### */
Static Function ImportarNFe()
	
	Local oDlgItens
	Local aItens     := {}
	Local aStruct    := {}
	Local aAlter     := {}
	Local aConv      := {}
	Local cStrXml    := ""
	Local cPedido    := ""
	Local cItemPC    := ""
	Local cStTrib    := ""
	Local cStTribS   := ""
	Local nBaseICM   := 0
	Local nPerICM    := 0
	Local nValICM    := 0
	
	//Icms St
	Local nBaseICMST := 0
	Local nPerICMST  := 0
	Local nValICMST  := 0
	Local aAuxICM

	//Icms St Ant
	Local nBaseSTAnt := 0
	Local nPerSTAnt  := 0
	Local nValSTAnt  := 0
	
	Local nValSubA := 0
	
	Local nBaseIPI   := 0
	Local nPerIPI    := 0
	Local nValIPI    := 0
	Local lImport    := .F.
	Local lConfirm   := .F.
	Local lProdForn  := .F.
	Local dDtEmis    := (_cTab1)->&(_cCmp1 + "_DTEMIS")
	Local aFields    := {}
	Local aUpdFlds   := {}
	//Local cEnchOld   := GetMv("MV_ENCHOLD")
	Local cNCM       := ""
	Local nDesconto  := 0
	Local nValItFre  := 0
	Local aUm
	Local aAchouNota := {}
	Local lDireto    := .T.
	Local aHeadPreNt := {}
	Local aHeadNotC  := {_cCmp2 + "_SEQIMP", _cCmp2 + "_CSTERP"}
	Local aTrocaEmit
	Local aNfeIcms   := {}
	Local aSitTrib   := {}
	Local cModFrete  := ""
	
	Local lNFCE      := SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 21, 2) == "65"
	Local lNFSe      := (_cTab1)->&(_cCmp1 + "_TIPO") == "6"

	Local nX1
	Local nX
	Local nY
	
	Local aPedAux
	
	Local aNFSInfo
	Local aItAux

	// Variáveis para o Rastro
	Local aRastro
	Local nR
	Local nV
	
	Local nQtdLote := 0
	Local cXLote := ""
	Local dDtFab := CToD("  /  /    ")
	Local dDtVld := CToD("  /  /    ")
	Local cFciCd := ""

	Local nTotRat := 0
	Local aTotRat := {}
	Local aValRat := {3, 5, 10, 12, 13, 15, 17, 18, 20, 22}
	Local aTotItR := {}
	Local nValRat := 0
	Local nRatVOri
	Local nPosRat

	Local aItXml := {}
	
	Local lVincAutPr := GetNewPar("MV_ZVIAUPR", .T.)
	
	Local lUsaRastro := GetNewPar("MV_ZGOIRAS", .T.)
	
	///////////////////

	Private nUsado   := 0
	
	//Totais
	Private nValFrete
	Private nValSeguro
	Private nValDesp
	Private nValDesc
	Private nValMerc
	Private nValXIPI
	Private nValXST
	////////
	
	Private cNaturez := Space(TamSX3("A2_NATUREZ")[1])
	Private cConPgto := Space(TamSX3("A2_COND")[1])
	Private cFornece := ""
	Private cLoja	 := ""
	Private cDescFor := ""
	Private cEstado  := ""
	Private aHeader  := {}
	Private aCols	 := {}
	Private oGetD
	Private oLayerImp
	
	Private cTpFrete := " "
	
	Private aJaPed   := {}
	
	aTrocaEmit := U_CliForGO((_cTab1)->&(_cCmp1 + "_CGCEMI"))
	
	If aTrocaEmit[1] == 1 .And. aTrocaEmit[8] # "1" 
	
		RecLock(_cTab1, .F.)
		
			(_cTab1)->&(_cCmp1 + "_CODEMI") := aTrocaEmit[2]
			(_cTab1)->&(_cCmp1 + "_LOJEMI") := aTrocaEmit[3]
			(_cTab1)->&(_cCmp1 + "_NATFIN") := aTrocaEmit[4]
			(_cTab1)->&(_cCmp1 + "_EST")    := aTrocaEmit[5]
			(_cTab1)->&(_cCmp1 + "_CONDPG") := aTrocaEmit[6]
		
		(_cTab1)->( MsUnlock() )
		
	ElseIf aTrocaEmit[1] == 1 .And. aTrocaEmit[8] == "1"
		
		//Aviso("Erro", "Fornecedor bloqueado no sistema, não poderá ser importado como normal.", {"Ok"}, 2)
		U_GOSetEr("Fornecedor bloqueado no sistema, não poderá ser importado como normal.")
		
		Return .F.
		
	Else
		
		//Aviso("Erro", "Fornecedor inexistente no sistema.", {"Ok"}, 2)
		U_GOSetEr("Fornecedor inexistente no sistema.")
		
		Return .F.
		
	EndIf
	
	aAchouNota := NumNotas((_cTab1)->&(_cCmp1 + "_CHAVE"), (_cTab1)->&(_cCmp1 + "_DOC"), (_cTab1)->&(_cCmp1 + "_SERIE"), ;
	                       (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"), IIf(lNFCE, cEspNFCe, IIf(lNFSe, cEspNFSe, cEspNFe)), (_cTab1)->&(_cCmp1 + "_DTEMIS"))
	
	// Se achou a nota importada
	If aAchouNota[1]
	
		If Aviso("Aviso", "A Nota Fiscal " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " já foi importada com o número: '" + aAchouNota[2] + "'. " + CRLF + ;
		         "Deseja marcá-la como Processada?", {"Sim", "Não"}, 2) == 1
		
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_DOC")    := aAchouNota[2]
				(_cTab1)->&(_cCmp1 + "_TIPOEN") := aAchouNota[3]
				
				(_cTab1)->&(_cCmp1 + "_TPCOMP") := aAchouNota[11]
				
				(_cTab1)->&(_cCmp1 + "_ESPECI") := aAchouNota[4]
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := aAchouNota[5]
				(_cTab1)->&(_cCmp1 + "_SERIE")  := aAchouNota[6]
				(_cTab1)->&(_cCmp1 + "_CODEMI") := aAchouNota[7]
				(_cTab1)->&(_cCmp1 + "_LOJEMI") := aAchouNota[8]
				(_cTab1)->&(_cCmp1 + "_CGCEMI") := aAchouNota[9]
				
			(_cTab1)->( MsUnlock() )
			
		EndIf
		
		Return .F.
		
	ElseIf aAchouNota[10]
		
		/*Aviso("Aviso", "A Nota Fiscal já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " + ;
		      "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      "porblema de chave duplicada.", {"Ok"}, 2)*/
		U_GOSetEr("A Nota Fiscal já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " + ;
		      	   "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      	   "problema de chave duplicada.")
		
		Return .F.
		
	EndIf
	
	// Para settar como nenhum erro encontrado.
	U_GOSetEr(,, .T.)
	
	oGOLog:NewLine()
	oGOLog:Add("-------- Importando Nota Fiscal de número: " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " e série: " + AllTrim((_cTab1)->&(_cCmp1 + "_SERIE")) + " [Normal]")
	oGOLog:NewLine()
	
	Begin Sequence
		
		If (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
			
			aNFSInfo := U_GOX18NFS(oXml, U_GOX18PRV((_cTab1)->&(_cCmp1 + "_PROV"), .F.))
			
			nValFrete  := 0
			nValSeguro := 0
			nValDesp   := 0
			nValXIPI   := 0
			nValXST    := 0
			nValDesc   := U_GOX18REF(aNFSInfo, "DESCON", 0)
			nValMerc   := U_GOX18REF(aNFSInfo, "TOTAL", 0)
			
			aItAux := U_GOX18REF(aNFSInfo, "ITENS", "")
			
			For nX1 := 1 To Len(aItAux)
				
				AAdd(aItens, {U_GOX18REF(aItAux[nX1], "CODIGO", ""),            ; // 1
			              SubStr(U_GOX18REF(aItAux[nX1], "DESC", ""), 1, 55), ; // 2
			              cValToChar(U_GOX18REF(aItAux[nX1], "QUANT", 0)),                 ; // 3
			              PadR(Upper(U_GOX18REF(aItAux[nX1], "UM", "")), TamSX3(_cCmp2 + "_UMF")[1]),          ; // 4
			              cValToChar(U_GOX18REF(aItAux[nX1], "TOTAL", 0)),                ; // 5
			              cValToChar(U_GOX18REF(aItAux[nX1], "VLUNIT", 0)),               ; // 6
			              "",                                                               ; // 7
			              "",                                                               ; // 8
			              "",                                                               ; // 9
			              0,                                                              ; // 10
			              0,                                                               ; // 11
			              0,                                                               ; // 12
			              0,                                                              ; // 13
			              0,                                                               ; // 14
			              0,                                                               ; // 15
			              "",                                                                  ; // 16
			              U_GOX18REF(aItAux[nX1], "DESCONTO", 0),                                                             ; // 17
			              0,                                                             ; // 18
			              "",                  ; // 19
						  0, ; // 20
						  0, ; // 21
						  0, ; // 22
						  "", ; // 23
						  CToD("  /  /    "), ; // 24
						  CToD("  /  /    "), ; // 25
						  "", ; // 26
						  0, ; // 27
						  0, ; // 28
						  0, ; // 29
						  0, ; // 30
						  "" ; // 31
			             })
				
			Next nX1
			
			/*AAdd(aItens, {oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_cProd:Text,                ; // 1
			              SubStr(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_xProd:Text, 1, 55), ; // 2
			              oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_qCom:Text,                 ; // 3
			              PadR(Upper(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_uCom:Text), TamSX3(_cCmp2 + "_UMF")[1]),          ; // 4
			              oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vProd:Text,                ; // 5
			              oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vUnCom:Text,               ; // 6
			              cPedido,                                                               ; // 7
			              cItemPC,                                                               ; // 8
			              cStTrib,                                                               ; // 9
			              nBaseICM,                                                              ; // 10
			              nPerICM,                                                               ; // 11
			              nValICM,                                                               ; // 12
			              nBaseIPI,                                                              ; // 13
			              nPerIPI,                                                               ; // 14
			              nValIPI,                                                               ; // 15
			              cNCM,                                                                  ; // 16
			              nDesconto,                                                             ; // 17
			              nValItFre,                                                             ; // 18
			              oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_CFOP:Text                  ; // 19
			             })*/
			
		Else
			
			nValFrete  := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vFrete:Text)
			nValSeguro := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vSeg:Text)
			nValDesp   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vOutro:Text)
			nValDesc   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vDesc:Text)
			nValMerc   := Val(oXml:_NfeProc:_Nfe:_InfNfe:_total:_ICMSTot:_vProd:Text)
			nValXIPI   := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vIPI:Text"))
			nValXST    := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vST:Text"))
			
			If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe,"_TRANSP")) <> "U" .And. ;
			   ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_Transp,"_MODFRETE")) <> "U"
				
				cModFrete := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_Transp:_ModFrete:Text)
				
				If cModFrete == "0"
					
					//cTpFrete := "C"
					cTpFrete := "C-CIF"
					
				ElseIf cModFrete == "1"
					
					//cTpFrete := "F"
					cTpFrete := "F-FOB"
					
				ElseIf cModFrete == "2"
					
					//cTpFrete := "T"
					cTpFrete := "T-Por Conta Terceiros"
					
				ElseIf cModFrete == "9"
					
					//cTpFrete := "S"
					cTpFrete := "S-Sem Frete"
					
				EndIf
				
			EndIf
			
			If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
			
				XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
				
			EndIf
			
			oGOLog:Add("- Lendo itens da Nota Fiscal...", 1)
			
			For nX1 := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)
				
				nBaseICM := 0
				nPerICM := 0
				nValICM := 0
				nBaseIPI := 0
				nPerIPI := 0
				nValIPI := 0
				nDesconto := 0
				nValItFre := 0
				nBaseICMST := 0
				nPerICMST := 0
				nValICMST := 0
				nBaseSTAnt := 0
				nPerSTAnt := 0
				nValSTAnt := 0
				nValSubA := 0
				
				nQtdLote := 0
				cXLote := ""
				dDtFab := CToD("  /  /    ")
				dDtVld := CToD("  /  /    ")
				cFciCd := ""
				nTotRat := 0

				aTotRat := {}
				aTotItR := {}
				aRastro := {}

				SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod XMLSTRING cStrXml
				
				// Descontinuado o pedido e intem do pedido enviado no XML, geralmente nunca bate.
				/*If At("<xPed>", cStrXml) > 0 .And. At("<nItemPed>", cStrXml) > 0
				
					cPedido := SubStr(cStrXml, At("<xPed>", cStrXml) + 6, At("</xPed>", cStrXml) - (At("<xPed>", cStrXml) + 6))
					cItemPC := SubStr(cStrXml, At("<nItemPed>", cStrXml) + 10, At("</nItemPed>", cStrXml) - (At("<nItemPed>", cStrXml) + 10))
					
					dbSelectArea("SC7")
					SC7->( dbSetOrder(1) )
					
					If !SC7->( dbSeek(xFilial("SC7") + cPedido + cItemPC) )
					
						cPedido := ""
						cItemPC := ""
						
					EndIf
					
				EndIf*/
				
				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_imposto:_ICMS") == "O"
				
					SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_imposto:_ICMS XMLSTRING cStrXml
					
					If At("<ICMS", cStrXml) > 0
						
						If "<CSOSN>" $ cStrXml
							
							cStTribS := SubStr(cStrXml, At("<CSOSN>", cStrXml) + 7, 3)
							
							If !U_GO1VLCSO(cStTribs)
								
								cStTribs := "   "
								
							EndIf
							
						Else
							
							cStTrib  := SubStr(cStrXml, At("<orig>", cStrXml) + 6, 1) + SubStr(cStrXml, At("<CST>", cStrXml) + 5, 2)
							
							If SubStr(cStTrib, 1, 1) == "1"
								
								cStTrib := "2" + SubStr(cStTrib, 2, 2)
								
							EndIf
							
							If !U_GO1VLCST(cStTrib)
								
								cStTrib := "   "
								
							EndIf
							
						EndIf
						
						nBaseICM := Val(SubStr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5)))
						nPerICM  := Val(SubStr(cStrXml, At("<pICMS>", cStrXml) + 7, At("</pICMS>", cStrXml) - (At("<pICMS>", cStrXml) + 7)))
						nValICM  := Val(SubStr(cStrXml, At("<vICMS>", cStrXml) + 7, At("</vICMS>", cStrXml) - (At("<vICMS>", cStrXml) + 7)))
						
						If ValType(nBaseICM) # "N"
							
							nBaseICM := 0
							
						EndIf
						
						If ValType(nPerICM) # "N"
							
							nPerICM := 0
							
						EndIf
						
						If ValType(nValICM) # "N"
							
							nValICM := 0
							
						EndIf
						
						If nPerICM <= 0
							
							nPerICM := Round(nValICM * 100 / nBaseICM, 2)
							
						EndIf
						
						// Tratar o ICMS ST, e Somar no total
						//<vBCST>12527.44</vBCST>
						//<pICMSST>17.0000</pICMSST>
						//<vICMSST>711.78</vICMSST>
						
						//nBaseICMST := Val(SubStr(cStrXml, At("<vBCST>", cStrXml) + 5, At("</vBCST>", cStrXml) - (At("<vBCST>", cStrXml) + 5)))
						//nPerICMST  := Val(SubStr(cStrXml, At("<pICMSST>", cStrXml) + 7, At("</pICMSST>", cStrXml) - (At("<pICMSST>", cStrXml) + 7)))
						//nValICMST  := Val(SubStr(cStrXml, At("<vICMSST>", cStrXml) + 7, At("</vICMSST>", cStrXml) - (At("<vICMSST>", cStrXml) + 7)))
						
						aAuxICM := U_GOXmlIcm(oXml, nX1)
						
						nBaseICMST := aAuxICM[7]
						nPerICMST  := aAuxICM[8]
						nValICMST  := aAuxICM[9]

						nBaseSTAnt := aAuxICM[10]
						nPerSTant  := aAuxICM[11]
						nValSTAnt  := aAuxICM[12]
						nValSubA   := aAuxICM[13]
						
					EndIf
					
				EndIf
				
				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_imposto:_IPI") == "O"
				
					SAVE oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_imposto:_IPI XMLSTRING cStrXml
					
					If AT("<IPITrib>", cStrXml) > 0
					
						nBaseIPI := Val(SubStr(cStrXml, At("<vBC>", cStrXml) + 5, At("</vBC>", cStrXml) - (At("<vBC>", cStrXml) + 5)))
						nPerIPI  := Val(SubStr(cStrXml, At("<pIPI>", cStrXml) + 6, At("</pIPI>", cStrXml) - (At("<pIPI>", cStrXml) + 6)))
						nValIPI  := Val(SubStr(cStrXml, At("<vIPI>", cStrXml) + 6, At("</vIPI>", cStrXml) - (At("<vIPI>", cStrXml) + 6)))
						
					EndIf
					
				EndIf
				
				If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod,"_NCM")) <> "U"
				
					cNCM := oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_NCM:Text
					
				Else
				
					cNCM := ""
					
				EndIf
				
				If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod,"_VDESC")) <> "U"
				
					nDesconto := Val(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vDesc:Text)
					
				Else
				
					nDesconto := 0
					
				EndIf
				
				If ValType(XmlChildEx(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod,"_VFRETE")) <> "U"
					
					nValItFre := Val(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vFrete:Text)
					
				Else
					
					nValItFre := 0
					
				EndIf
				
				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_prod:_rastro") == "O"

					aRastro := {oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_rastro}

				ElseIf Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_prod:_rastro") == "A"
					
					aRastro := oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_rastro

				EndIf

				If Len(aRastro) > 0
				
					SAVE aRastro[1] XMLSTRING cStrXml
					
					If AT("<nLote>", cStrXml) > 0
					
						cXLote := SubStr(cStrXml, At("<nLote>", cStrXml) + 7, At("</nLote>", cStrXml) - (At("<nLote>", cStrXml) + 7))
						
					EndIf
					
					If AT("<dFab>", cStrXml) > 0
						
						dDtFab := SToD(StrTran(SubStr(cStrXml, At("<dFab>", cStrXml) + 6, At("</dFab>", cStrXml) - (At("<dFab>", cStrXml) + 6)), "-", ""))
						
					EndIf
					
					If AT("<dVal>", cStrXml) > 0
						
						dDtVld := SToD(StrTran(SubStr(cStrXml, At("<dVal>", cStrXml) + 6, At("</dVal>", cStrXml) - (At("<dVal>", cStrXml) + 6)), "-", ""))
						
					EndIf

					If AT("<qLote>", cStrXml) > 0
						
						nQtdLote := Val(SubStr(cStrXml, At("<qLote>", cStrXml) + 7, At("</qLote>", cStrXml) - (At("<qLote>", cStrXml) + 7)))
						
					EndIf
					
				EndIf
				
				If Type("oXml:_nfeProc:_NFe:_infNFe:_det[" + cValToChar(nX1) + "]:_prod:_nFCI") == "O"
				
					cFciCd := oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_nFCI:Text
					
				EndIf
							
				If Len(aRastro) > 1 .And. lUsaRastro

					For nR := 1 To Len(aRastro)

						SAVE aRastro[nR] XMLSTRING cStrXml
						
						If AT("<nLote>", cStrXml) > 0
						
							cXLote := SubStr(cStrXml, At("<nLote>", cStrXml) + 7, At("</nLote>", cStrXml) - (At("<nLote>", cStrXml) + 7))
							
						EndIf
						
						If AT("<dFab>", cStrXml) > 0
							
							dDtFab := SToD(StrTran(SubStr(cStrXml, At("<dFab>", cStrXml) + 6, At("</dFab>", cStrXml) - (At("<dFab>", cStrXml) + 6)), "-", ""))
							
						EndIf
						
						If AT("<dVal>", cStrXml) > 0
							
							dDtVld := SToD(StrTran(SubStr(cStrXml, At("<dVal>", cStrXml) + 6, At("</dVal>", cStrXml) - (At("<dVal>", cStrXml) + 6)), "-", ""))
							
						EndIf
						
						If AT("<qLote>", cStrXml) > 0
							
							nQtdLote := Val(SubStr(cStrXml, At("<qLote>", cStrXml) + 7, At("</qLote>", cStrXml) - (At("<qLote>", cStrXml) + 7)))
							
						EndIf

						nTotRat += nQtdLote

						AAdd(aItens, {oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_cProd:Text,                ; // 1
							SubStr(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_xProd:Text, 1, 55), ; // 2
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_qCom:Text,                 ; // 3
							PadR(Upper(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_uCom:Text), TamSX3(_cCmp2 + "_UMF")[1]),          ; // 4
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vProd:Text,                ; // 5
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vUnCom:Text,               ; // 6
							cPedido,                                                               ; // 7
							cItemPC,                                                               ; // 8
							cStTrib,                                                               ; // 9
							nBaseICM,                                                              ; // 10
							nPerICM,                                                               ; // 11
							nValICM,                                                               ; // 12
							nBaseIPI,                                                              ; // 13
							nPerIPI,                                                               ; // 14
							nValIPI,                                                               ; // 15
							cNCM,                                                                  ; // 16
							nDesconto,                                                             ; // 17
							nValItFre,                                                             ; // 18
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_CFOP:Text,                 ; // 19
							nBaseICMST,                                                            ; // 20
							nPerICMST,                                                             ; // 21
							nValICMST,                                                             ; // 22
							cXLote, ;// 23 
							dDtFab, ;// 24
							dDtVld, ;// 25
							cFciCd, ;// 26
							nQtdLote, ;//27
							nBaseSTAnt,                                                            ; // 28
							nPerSTAnt,                                                             ; // 29
							nValSTAnt,                                                             ; // 30
							cStTribs,                                                             ;  // 31
							nValSubA                                                              ; // 32
							})

						AAdd(aTotItR, Len(aItens))

					Next nR

					For nR := 1 To Len(aTotItR) // Percorre todos os itens replicado do Lote para Ratear

						For nV := 1 To Len(aValRat) // Todos os valores para ratear

							//nTotRat --> Total da Quantidade do Lote.
							If ValType(aItens[aTotItR[nR]][aValRat[nV]]) == "C"
								
								nRatVOri := Val(aItens[aTotItR[nR]][aValRat[nV]])
								
							Else
								
								nRatVOri := aItens[aTotItR[nR]][aValRat[nV]]
								
							EndIf

							If ValType(aItens[aTotItR[nR]][aValRat[nV]]) == "C"
								
								nValRat := Val(aItens[aTotItR[nR]][aValRat[nV]]) * aItens[aTotItR[nR]][27] / nTotRat

								aItens[aTotItR[nR]][aValRat[nV]] := cValToChar(nValRat)

							Else

								nValRat := aItens[aTotItR[nR]][aValRat[nV]] * aItens[aTotItR[nR]][27] / nTotRat

								aItens[aTotItR[nR]][aValRat[nV]] := nValRat

							EndIf

							nPosRat := AScan(aTotRat, {|x| x[1] == aValRat[nV]})

							If nPosRat > 0 

								aTotRat[nPosRat][2] += nValRat

							Else
								
								AAdd(aTotRat, {aValRat[nV], nValRat, nRatVOri})

							EndIf

						Next nV

					Next nR

					For nR := 1 To Len(aTotRat) // Verifica se foi tudo rateado sem diferença de centavos

						If aTotRat[nR][2] # aTotRat[nR][3]

							If ValType(aItens[ATail(aTotItR)][aTotRat[nR][1]]) == "C" // tratamento especial para quantidade
								
								aItens[ATail(aTotItR)][aTotRat[nR][1]] := cValToChar(Val(aItens[ATail(aTotItR)][aTotRat[nR][1]]) + (aTotRat[nR][3] - aTotRat[nR][2]))

							Else

								aItens[ATail(aTotItR)][aTotRat[nR][1]] += (aTotRat[nR][3] - aTotRat[nR][2])

							EndIf

						EndIf

					Next nR

				Else

					AAdd(aItens, {oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_cProd:Text,                ; // 1
							SubStr(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_xProd:Text, 1, 55), ; // 2
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_qCom:Text,                 ; // 3
							PadR(Upper(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_uCom:Text), TamSX3(_cCmp2 + "_UMF")[1]),          ; // 4
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vProd:Text,                ; // 5
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vUnCom:Text,               ; // 6
							cPedido,                                                               ; // 7
							cItemPC,                                                               ; // 8
							cStTrib,                                                               ; // 9
							nBaseICM,                                                              ; // 10
							nPerICM,                                                               ; // 11
							nValICM,                                                               ; // 12
							nBaseIPI,                                                              ; // 13
							nPerIPI,                                                               ; // 14
							nValIPI,                                                               ; // 15
							cNCM,                                                                  ; // 16
							nDesconto,                                                             ; // 17
							nValItFre,                                                             ; // 18
							oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_CFOP:Text,                 ; // 19
							nBaseICMST,                                                            ; // 20
							nPerICMST,                                                             ; // 21
							nValICMST,                                                             ; // 22
							cXLote, ;// 23 
							dDtFab, ;// 24
							dDtVld, ;// 25
							cFciCd, ;// 26
							nQtdLote, ;//27
							nBaseSTAnt,                                                            ; // 28
							nPerSTAnt,                                                             ; // 29
							nValSTAnt,                                                             ; // 30
							cStTribs,                                                               ; // 31
							nValSubA                                                                ; // 32
							})

				EndIf
				
			Next nX1
			
			oGOLog:Add("Total de " + cValToChar(Len(oXml:_nfeProc:_NFe:_infNFe:_det)) + " itens.", 1)
			oGOLog:NewLine()
			oGOLog:Add("-Procurando Fornecedor...", 1)
		
		EndIf
		
		dbSelectArea("SA2")
		SA2->( dbSetOrder(1) )
		
		If SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
		
			oGOLog:Add("-Fornecedor encontrado com o CNPJ: " + (_cTab1)->&(_cCmp1 + "_CGCEMI"), 1)
			oGOLog:Add("-Fornecedor: " + "Cod.: " + SA2->A2_COD + ", Loja: " + SA2->A2_LOJA + " - " + SA2->A2_NOME, 2)
			oGOLog:Add("-Natureza: " + (_cTab1)->&(_cCmp1 + "_NATFIN"), 2)
			oGOLog:Add("-Estado: " + SA2->A2_EST, 2)
			oGOLog:Add("-Condição de pagamento: " + SA2->A2_COND + " - " + Posicione("SE4", 1, xFilial("SE4") + SA2->A2_COND, "E4_DESCRI"), 2)
			oGOLog:NewLine()
			
			cDescFor := SA2->A2_COD + " - " + SA2->A2_NOME
			cFornece := SA2->A2_COD
			cLoja	 := SA2->A2_LOJA
			cNaturez := SA2->A2_NATUREZ
			cEstado  := SA2->A2_EST
			cConPgto := SA2->A2_COND
			nUsado := 0
			
			If Empty(cNaturez) .And. aNatAnt[1] == "6" .And. (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
				
				cNaturez := aNatAnt[2]
				
			EndIf
			
			// Campos que serão apresentados quando for Pré-Nota.
			AAdd(aHeadPreNt, _cCmp2 + '_DESC')
			AAdd(aHeadPreNt, _cCmp2 + '_PEDIDO')
			AAdd(aHeadPreNt, _cCmp2 + '_ITEMPC')
			AAdd(aHeadPreNt, _cCmp2 + '_COD')
			AAdd(aHeadPreNt, _cCmp2 + '_DSPROD')
			AAdd(aHeadPreNt, _cCmp2 + '_NCM')
			AAdd(aHeadPreNt, _cCmp2 + '_UMF')
			AAdd(aHeadPreNt, _cCmp2 + '_QUANT1')
			AAdd(aHeadPreNt, _cCmp2 + '_UM')
			AAdd(aHeadPreNt, _cCmp2 + '_QUANT2')
			AAdd(aHeadPreNt, _cCmp2 + '_VUNIT')
			AAdd(aHeadPreNt, _cCmp2 + '_TOTAL')
			
			If GetNewPar("MV_ZGOPNTE", .T.)
				
				AAdd(aHeadPreNt, _cCmp2 + '_TES')
				AAdd(aHeadPreNt, _cCmp2 + '_CF')
				AAdd(aHeadPreNt, _cCmp2 + '_CLASFI')
				AAdd(aHeadPreNt, _cCmp2 + '_CSOSN')
				
			EndIf
			
			AAdd(aHeadPreNt, _cCmp2 + '_DESCTO')
			AAdd(aHeadPreNt, _cCmp2 + '_CC')
			AAdd(aHeadPreNt, _cCmp2 + '_CLVL')
			AAdd(aHeadPreNt, _cCmp2 + '_ITEMCTA')
			
			// Adicionar ICMS, ICMSST e IPI
			AAdd(aHeadPreNt, _cCmp2 + '_VLFRET')
			
			AAdd(aHeadPreNt, _cCmp2 + '_BASEIC')
			AAdd(aHeadPreNt, _cCmp2 + '_PICM')
			AAdd(aHeadPreNt, _cCmp2 + '_VALICM')
			
			AAdd(aHeadPreNt, _cCmp2 + '_BASEIP')
			AAdd(aHeadPreNt, _cCmp2 + '_IPI')
			AAdd(aHeadPreNt, _cCmp2 + '_VALIPI')
			
			AAdd(aHeadPreNt, _cCmp2 + '_LOTE')
			AAdd(aHeadPreNt, _cCmp2 + '_DTFAB')
			AAdd(aHeadPreNt, _cCmp2 + '_DTVLD')
			AAdd(aHeadPreNt, _cCmp2 + '_FCICOD')
			
			AAdd(aHeadPreNt, _cCmp2 + '_BASEST')
			AAdd(aHeadPreNt, _cCmp2 + '_PICMST')
			AAdd(aHeadPreNt, _cCmp2 + '_VLICST')
			
			AAdd(aHeadPreNt, _cCmp2 + '_BSSTAN')
			AAdd(aHeadPreNt, _cCmp2 + '_ALSTAN')
			AAdd(aHeadPreNt, _cCmp2 + '_VLSTAN')

			dbSelectArea("SX3") 
			SX3->( dbSetOrder(1) )
			SX3->( dbSeek(_cTab2) )
			
			If lPreNota
			
				While !SX3->( Eof() ) .And. X3_ARQUIVO == _cTab2
				
					// Só adiciona os campos que estiverem na variável 'aHeadPreNt'.
					If SX3->X3_CAMPO # _cCmp2 + "_FILIAL" .And. AScan(aHeadPreNt, {|x| x == AllTrim(SX3->X3_CAMPO)}) > 0
					
						nUsado++
						AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT}) 
						
					EndIf
					
					SX3->( dbSkip() )
					
				EndDo
				
			Else
			
				While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab2
				
					If SX3->X3_CAMPO # _cCmp2 + "_FILIAL" .And. AScan(aHeadNotC, {|x| x == AllTrim(SX3->X3_CAMPO)}) == 0
					
						nUsado++
						AAdd(aHeader, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT}) 
						
					EndIf
					
					SX3->( dbSkip() )
					
				EndDo
				
			EndIf
			
			// Pega a posição dos itens da Tab2
			_nPosItXml := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_DESC"   , 10)})
			_nPosPedid := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_PEDIDO" , 10)})
			_nPosItePc := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_ITEMPC" , 10)})
			_nPosProdu := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_COD"    , 10)})
			_nPosDcPrd := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_DSPROD" , 10)})
			_nPosNcm   := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_NCM"    , 10)})
			_nPosUm    := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_UM"     , 10)})
			_nPosUmFor := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_UMF"    , 10)})
			_nPosQtdFr := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_QUANT1" , 10)})
			_nPosQtdNo := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_QUANT2" , 10)})
			_nPosVlUnt := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_VUNIT"  , 10)})
			_nPosVlTot := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_TOTAL"  , 10)})
			_nPosTes   := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_TES"    , 10)})
			_nPosCdFis := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CF"     , 10)})
			_nPosConta := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CONTA"  , 10)})
			_nPosCtCus := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CC"     , 10)})
			_nPosItCon := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_ITEMCTA", 10)})
			_nPosClVal := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CLVL"   , 10)})
			_nPosBsIcm := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_BASEIC" , 10)})
			_nPosAqIcm := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_PICM"   , 10)})
			_nPosVlIcm := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_VALICM" , 10)})
			_nPosBsIpi := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_BASEIP" , 10)})
			_nPosAqIpi := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_IPI"    , 10)})
			_nPosVlIpi := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_VALIPI" , 10)})
			_nPosStTri := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CLASFI" , 10)})
			_nPosCSOSN := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CSOSN" , 10)})
			_nPosDescX := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_DESCTO" , 10)})
			_nPosNFOri := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_NFORI"  , 10)})
			_nPosSerOr := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_SERORI" , 10)})
			_nPosItOri := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_ITORI"  , 10)})
			_nPosVlFrt := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_VLFRET" , 10)})
			
			// ICMS ST
			_nPosBsISt := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_BASEST" , 10)})
			_nPosPIcSt := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_PICMST" , 10)})
			_nPosVlISt := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_VLICST" , 10)})

			// ICMS ST ANTERIOR
			_nPosBsStA := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_BSSTAN" , 10)})
			_nPosPStA  := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_ALSTAN" , 10)})
			_nPosVlStA := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_VLSTAN" , 10)})
			
			_nPosVlAnt := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_VLANTI" , 10)})
			
			_nPosLote  := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_LOTE" , 10)})
			_nPosDtFab := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_DTFAB" , 10)})
			_nPosDtVld := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_DTVLD" , 10)})
			_nPosFciCd := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_FCICOD" , 10)})
			
			AAdd(aAlter, _cCmp2 + "_CONTA")    // Conta Contábil
			AAdd(aAlter, _cCmp2 + "_CC")       // Centro Custo
			AAdd(aAlter, _cCmp2 + "_CF")       // Cod.Fiscal
			AAdd(aAlter, _cCmp2 + "_CLVL")     // Classe Valor
			AAdd(aAlter, _cCmp2 + "_COD")      // Produto
			AAdd(aAlter, _cCmp2 + "_ITEMCTA")  // Item Conta
			AAdd(aAlter, _cCmp2 + "_ITEMPC")   // Item Pedido
			AAdd(aAlter, _cCmp2 + "_PEDIDO")   // Pedido
			AAdd(aAlter, _cCmp2 + "_QUANT2")   // Nossa Qtde.
			AAdd(aAlter, _cCmp2 + "_VUNIT")    // Valor unitário
			AAdd(aAlter, _cCmp2 + "_TES")      // Tipo de Entrada
			
			aCols := Array(Len(aItens), nUsado + 1)
			
			For nY := 1 to Len(aItens)
			
				For nX := 1 To nUsado
				
					aCols[nY, nX] := CriaVar(aHeader[nX, 2])
					
				Next nX
				
				/*
				  Verifica se as posições existem antes de atribuir,
				  pois quando é Pré-Nota algumas posição não devem aparecer.
				*/
				If _nPosItXml > 0
				
					aCols[nY, _nPosItXml] := AllTrim(aItens[nY, 1]) + " - [" + SubStr(aItens[nY, 2], 1, 30) + "]"
					
				EndIf
				
				If _nPosPedid > 0
				
					aCols[nY, _nPosPedid] := aItens[nY, 7]
					
				EndIf
				
				If _nPosItePc > 0
				
					aCols[nY, _nPosItePc] := aItens[nY, 8]
					
				EndIf
				
				If _nPosProdu > 0
				
					aCols[nY, _nPosProdu] := Space(TamSX3("B1_COD")[1])
					
				EndIf
				
				If _nPosNcm > 0
				
					aCols[nY, _nPosNcm] := aItens[nY, 16]
					
				EndIf
				
				If _nPosDcPrd > 0
				
					aCols[nY, _nPosDcPrd] := Space(TamSX3("B1_DESC")[1])
					
				EndIf
				
				If _nPosUmFor > 0
				
					aCols[nY, _nPosUmFor] := aItens[nY, 4]
					
				EndIf
				
				If _nPosQtdFr > 0
				
					aCols[nY, _nPosQtdFr] := Val(aItens[nY, 3])
					
				EndIf
				
				If _nPosQtdNo > 0
				
					aCols[nY, _nPosQtdNo] := Val(aItens[nY, 3])
					
				EndIf
				
				If _nPosVlUnt > 0
				
					aCols[nY, _nPosVlUnt] := Val(aItens[nY, 6])
					
				EndIf
				
				If _nPosVlTot > 0
				
					aCols[nY, _nPosVlTot] := Val(aItens[nY, 5])
					
					If GetNewPar("MV_ZSMSTPN", .F.) .And. lPreNota .And. aItens[nY, 22] > 0
						
						aCols[nY, _nPosVlTot] += aItens[nY, 22]
						
						aCols[nY, _nPosVlUnt] := Round(aCols[nY, _nPosVlTot] / aCols[nY, _nPosQtdNo], TamSX3(_cCmp2 + "_VUNIT")[2])
						
					EndIf
					
				EndIf
				
				If _nPosBsIcm > 0
				
					aCols[nY, _nPosBsIcm] := aItens[nY, 10]
					
				EndIf
				
				If _nPosAqIcm > 0
				
					aCols[nY, _nPosAqIcm] := aItens[nY, 11]
					
				EndIf
				
				If _nPosVlIcm > 0
				
					aCols[nY, _nPosVlIcm] := aItens[nY, 12]
					
				EndIf
				
				If _nPosBsIpi > 0
				
					aCols[nY, _nPosBsIpi] := aItens[nY, 13]
					
				EndIf
				
				If _nPosAqIpi > 0
				
					aCols[nY, _nPosAqIpi] := aItens[nY, 14]
					
				EndIf
				
				If _nPosVlIpi > 0
				
					aCols[nY, _nPosVlIpi] := aItens[nY, 15]
					
				EndIf
				
				If _nPosStTri > 0
				
					aCols[nY, _nPosStTri] := aItens[nY, 9]
					
				EndIf
				
				If _nPosCSOSN > 0
					
					aCols[nY, _nPosCSOSN] := aItens[nY, 31]
					
				EndIf
				
				If _nPosDescX > 0
					
					aCols[nY, _nPosDescX] := aItens[nY, 17]
					
				EndIf
				
				If _nPosVlFrt > 0
					
					aCols[nY, _nPosVlFrt] := aItens[nY, 18]
					
				EndIf
				
				// ST

				If _nPosBsISt > 0
				
					aCols[nY, _nPosBsISt] := aItens[nY, 20]
					
				EndIf
				
				If _nPosPIcSt > 0
				
					aCols[nY, _nPosPIcSt] := aItens[nY, 21]
					
				EndIf
				
				If _nPosVlISt > 0
				
					aCols[nY, _nPosVlISt] := aItens[nY, 22]
					
				EndIf

				// ST ANTERIOR

				If _nPosBsStA > 0
				
					aCols[nY, _nPosBsStA] := aItens[nY, 28]
					
				EndIf
				
				If _nPosPStA > 0
					
					aCols[nY, _nPosPStA] := aItens[nY, 29]
					
				EndIf
				
				If _nPosVlStA > 0
				
					aCols[nY, _nPosVlStA] := aItens[nY, 30]
					
				EndIf
				
				If _nPosVlAnt > 0
					
					aCols[nY, _nPosVlAnt] := aItens[nY, 32]
					
				EndIf
				
				If _nPosLote > 0
					
					aCols[nY, _nPosLote] := aItens[nY, 23]
					
				EndIf
				
				If _nPosDtFab > 0
					
					aCols[nY, _nPosDtFab] := aItens[nY, 24]
					
				EndIf
				
				If _nPosDtVld > 0
					
					aCols[nY, _nPosDtVld] := aItens[nY, 25]
					
				EndIf
				
				If _nPosFciCd > 0
					
					aCols[nY, _nPosFciCd] := aItens[nY, 26]
					
				EndIf
				
				aCols[nY, nUsado + 1] := .F.
				
				oGOLog:Add("-Buscando cadastro do produto " + AllTrim(aItens[nY, 1]) + " para o Fornecedor...", 1)
				
				dbSelectArea("SA5")
				SA5->( dbSetOrder(5) )
				SA5->( dbSeek(xFilial("SA5") + AllTrim(aItens[nY, 1])) )
				
				While SA5->( !Eof() ) .And. SA5->A5_FILIAL == xFilial("SA5") .And. AllTrim(SA5->A5_CODPRF) == AllTrim(aItens[nY, 1])
				
					If SA5->A5_FORNECE == SA2->A2_COD .And. SA5->A5_LOJA == SA2->A2_LOJA
					
						lProdForn := .T.
						oGOLog:Add("-Cadastro do produto para o fornecedor encontrado.", 1)
						oGOLog:Add("-Substituindo os valores nos itens vindos do Xml:", 1)
						
						If _nPosProdu > 0
						
							aCols[nY, _nPosProdu] := SA5->A5_PRODUTO
							
						EndIf
						
						If _nPosDcPrd > 0
							
							aCols[nY, _nPosDcPrd] := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_DESC")
							
						EndIf
						
						If _nPosUm > 0
						
							aCols[nY, _nPosUm] := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_UM")
							
						EndIf
						
						If _nPosTes > 0
							
							If GetNewPar("MV_ZGOTSIN", .F.)
								
								aCols[nY, _nPosTes] := GoGetTes(SA5->A5_PRODUTO, SA2->A2_COD, SA2->A2_LOJA, aItens[nY, 19], "1", Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_TE"))
								
							Else
								
								aCols[nY, _nPosTes] := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_TE")
								
							EndIf
							
						EndIf
						
						// Realiza a conversão de Unidade de Medida por Produto
						If (_nPosUm > 0 .And. _nPosUmFor > 0) .And. (!Empty(aCols[nY, _nPosUm]) .And. !Empty(aCols[nY, _nPosUmFor]) .And. ;
						   aCols[nY, _nPosUm] # aCols[nY, _nPosUmFor]) .And. lUMConv
							
							//                *Produto               *UM For                *UM Nosso           *Qtd For
							aConv := ValConUM(aCols[nY, _nPosProdu], aCols[nY, _nPosUmFor], aCols[nY, _nPosUm], aCols[nY, _nPosQtdFr], (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"))
							
							// Conversão Ocorrida
							If aConv[1]
								
								If aCols[nY, _nPosQtdFr] # aConv[2] .And. (!lUMMsg .Or. (GetNewPar("MV_ZNPRCUM", .F.) .And. !lPreNota) .Or. Aviso("Unidade de Medida", "A Unidade de Medida do Produto " + AllTrim(SA5->A5_PRODUTO) + " está diferente do arquivo XML." + CRLF + ;
										 "Doc: " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " / " + AllTrim((_cTab1)->&(_cCmp1 + "_SERIE")) + CRLF + ;
										 "Item XML: " + aCols[nY, _nPosItXml] + CRLF + ;
								         "Un.Medida do arquivo XML: " + aCols[nY, _nPosUmFor] + CRLF + ;
								         "Un.Medida do Produto Informado: " + aCols[nY, _nPosUm] + CRLF + ;
								         "Foi encontrado cadastro de conversão dessas unidades, gostaria de recalcular a quantidade e valor unitário?" + CRLF + ;
								         "Conversão: " + AllTrim(Transform(aCols[nY, _nPosQtdFr], "@E 999999999.9999")) + " " + aCols[nY, _nPosUmFor] + " => " + AllTrim(Transform(aConv[2], "@E 999999999.9999")) + " " + aCols[nY, _nPosUm], {"Sim", "Não"}, 3) == 1)
								 	
									aCols[nY, _nPosQtdNo] := aConv[2]
									
									If aConv[2] > 0
									
										aCols[nY, _nPosVlUnt] := Round(aCols[nY, _nPosVlTot] / aConv[2], TamSX3(_cCmp2 + "_VUNIT")[2])
										
									EndIf
									
								EndIf
								
							/*ElseIf lUMMsg
							
								Aviso("Unidade de Medida", "A Unidade de Medida do Produto " + AllTrim(SA5->A5_PRODUTO) + " está diferente do arquivo XML!" + CRLF + ;
								      "Un.Medida do arquivo XML: " + aCols[nY, _nPosUmFor] + CRLF + ;
								      "Un.Medida do Produto Informado: " + aCols[nY, _nPosUm] + CRLF + ;
								      "Não foi encontrado cadastro de conversão de unidade de medida entre as informada. Os valores não serão alterados.", {"Ok"}, 3)*/
								
							EndIf
							
						EndIf
						
						If _nPosNcm > 0 .And. Empty(aCols[nY, _nPosNcm])
						
							aCols[nY, _nPosNcm] := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_POSIPI")
							
						EndIf
						
						If _nPosTes > 0 .And. !Empty(aCols[nY, _nPosTes])
							
							If _nPosCdFis > 0
								
								aCols[nY, _nPosCdFis] := IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + aCols[nY, _nPosTes], "F4_CF"), 2, 3)
								
							EndIf
							
							If _nPosStTri > 0 .And. GetNewPar("MV_ZALTTXM", .F.)
								// PEGA A SITUAÇÃO TRIBUTÁRIA DE ACORDO COM A TES
								aCols[nY, _nPosStTri] := SubStr(aCols[nY, _nPosStTri], 1, 1) + Posicione("SF4", 1, xFilial("SF4") + aCols[nY, _nPosTes], "F4_SITTRIB")
							EndIf
							
						EndIf
						
						If _nPosConta > 0
							
							If !Empty(aCols[nY, _nPosPedid] + aCols[nY, _nPosItePc])
								aCols[nY, _nPosConta] := Posicione("SC7", 1, xFilial("SC7") + aCols[nY, _nPosPedid] + aCols[nY, _nPosItePc], "C7_CONTA")
							Else
								aCols[nY, _nPosConta] := Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_CONTA")
							EndIf
							
						EndIf
						
						oGOLog:Add("-Produto:" + SA5->A5_PRODUTO + " - " + Posicione("SB1", 1, xFilial("SB1") + SA5->A5_PRODUTO, "B1_DESC"), 2)
						
						If _nPosUm > 0
						
							oGOLog:Add("-Unidade de Medida: " + aCols[nY, _nPosUm], 2)
							
						EndIf
						
						If _nPosTes > 0
						
							oGOLog:Add("-Tipo de Entrada e Sáida: " + aCols[nY, _nPosTes] + " - " + Posicione("SF4", 1, xFilial("SF4") + aCols[nY, _nPosTes], "F4_TEXTO"), 2)
							
						EndIf
						
						If _nPosCdFis > 0
						
							oGOLog:Add("-Código Fiscal: " + aCols[nY, _nPosCdFis] + " - " + Posicione("SX5", 1, xFilial("SX5") + "13" + aCols[nY, _nPosCdFis], "X5_DESCRI"), 2)
							
						EndIf
						
						Exit
						
					EndIf
					
					SA5->( dbSkip() )
					
				EndDo
				
				If !lProdForn
				
					oGOLog:Add("-Não foi encontrado cadastro do produto para o fornecedor.", 1)
					
				EndIf
				
				// Adicionar dados no Array
				
				If !lVincAutPr .Or. !Empty(aCols[nY, _nPosProdu])
					
					AAdd(aItXml, {;
						2, ;
						"", ;
						aCols[nY, _nPosProdu], ;
						"", ;
						aCols[nY, _nPosQtdFr], ;
						aCols[nY, _nPosVlUnt], ;
						aCols[nY, _nPosVlTot], ;
						nY ;
					})
					
				EndIf
				
			Next nY
			
			// Deverá verificar se existe apenas um pedido de compras para o fornecedor e já trazer vinculado.
			
			If _nPosPedid > 0 .And. Len(aItXml) > 0
				
				aPedAux := GetPedFor(aItXml, (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"), .T.)
				
				For nY := 1 To Len(aPedAux)
					
					aCols[aPedAux[nY][1], _nPosPedid] := aPedAux[nY][2]
					aCols[aPedAux[nY][1], _nPosItePc] := aPedAux[nY][3]
					
				Next nY
				
			EndIf
			
			aFields  := {_cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_DTEMIS", _cCmp1 + "_CODEMI", ;
			             _cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_CGCEMI", _cCmp1 + "_NATFIN", _cCmp1 + "_CONDPG", "NOUSER"}
			aUpdFlds := IIf(lPreNota, {}, {_cCmp1 + "_NATFIN", _cCmp1 + "_CONDPG"})  // Se Pré-Nota, estes campos ficam bloqueados.
			
			SetKey(VK_F7, {|| NFOriN()})
			
			DEFINE MSDIALOG oDlgItens FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE 'Importador NFE' COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
			
				oDlgItens:lEscClose := .F.
				oLayerImp := FWLayer():New()
				oLayerImp:Init(oDlgItens, .F.)
				
					oLayerImp:AddLine('TOP', 32, .F.)
					
						oLayerImp:AddCollumn('COL_TOP', 100, .T., 'TOP')
						
							oLayerImp:AddWindow('COL_TOP', 'WIN_TOP', "Dados da Nota Fiscal", 100, .F., .T., , 'TOP', )
							
								RegToMemory(_cTab1)
								
									M->&(_cCmp1 + "_NATFIN") := IIf(lPreNota, Space(TamSX3("A2_NATUREZ")[1]), cNaturez)
									M->&(_cCmp1 + "_CONDPG") := IIf(lPreNota, Space(TamSX3("A2_COND")[1]), cConPgto)
									
									//PutMv("MV_ENCHOLD", "2")
									oGetCab := MsMGet():New(_cTab1,, MODEL_OPERATION_UPDATE,,,, aFields, {0,0,0,0}, aUpdFlds,;
									           ,,,, oLayerImp:GetWinPanel('COL_TOP', 'WIN_TOP', 'TOP'),,.T.,,,.T.,,,,,.T.,,.T.)
									//PutMv("MV_ENCHOLD", cEnchOld)
									oGetCab:oBox:Align := CONTROL_ALIGN_ALLCLIENT
									
					oLayerImp:AddLine('CENTER', 63, .F.)
					
						oLayerImp:AddCollumn('COL_CENTER', 100, .T., 'CENTER')
						
							oLayerImp:AddWindow('COL_CENTER', 'WIN_CENTER', "Itens da Nota Fiscal a ser importada", 100, .F., .T., , 'CENTER', )
							
								oGetD := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAlter, 000, 999, Nil, Nil, "AlwaysFalse", oLayerImp:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'), aHeader, aCols)
								oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
								
								If GetNewPar("MV_ZSLVXMD", .T.)
									
									RestBkpXML(oGetD)
									
								EndIf
								
					oLayerImp:AddLine('BOTTOM', 5, .F.)
					
						oLayerImp:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')
						
							oPanelBot := tPanel():New(0, 0, "", oLayerImp:GetColPanel('COL_BOTTOM', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
							oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
							
							oQuit := THButton():New(0, 0, "&Sair", oPanelBot, {|| BkpXMLIt(oGetD), oDlgItens:End()}, , , )
							oQuit:nWidth  := 80
							oQuit:nHeight := 10
							oQuit:Align   := CONTROL_ALIGN_RIGHT
							oQuit:SetColor(RGB(002, 070, 112), )
							
							oImp := THButton():New(0, 0, "&Importar", oPanelBot, {|| lConfirm := .T., IIf((MsAguarde({|| lImport := ImpXMLNFe(@lConfirm)}, "Importando XML da Nota Fiscal..."), lImport), oDlgItens:End(), (SetKey(VK_F7, {|| NFOriN()}), .F.))}, , , )
							oImp:nWidth  := 80
							oImp:nHeight := 10
							oImp:Align := CONTROL_ALIGN_RIGHT
							oImp:SetColor(RGB(002, 070, 112), )
							
							oPedCom := THButton():New(0, 0, "&Ped. Compra", oPanelBot, {|| If(GetNewPar("MV_ZIMPNP", .F.), U_GOX1PED(), ConsPed())}, , , )
							oPedCom:nWidth  := 120
							oPedCom:nHeight := 10
							oPedCom:Align   := CONTROL_ALIGN_RIGHT
							oPedCom:SetColor(RGB(002, 070, 112), )
							
							If (_cTab1)->&(_cCmp1 + "_TIPO") # "6"
								
								oPedCom := THButton():New(0, 0, "&Desagrupar", oPanelBot, {|| DesagruNfe()}, , , )
								oPedCom:nWidth  := 120
								oPedCom:nHeight := 10
								oPedCom:Align   := CONTROL_ALIGN_RIGHT
								oPedCom:SetColor(RGB(002, 070, 112), )
								
							EndIf
							
							// Descontinuado devido a nova interface de vínculo de pedido de compras.
							/*If GetNewPar("MV_ZSNAGRI", .F.)
								
								oPedCom := THButton():New(0, 0, "&Agrupar Itens", oPanelBot, {|| If(GetNewPar("MV_ZIMPNP", .F.), U_GOX1PED(..), ConsPed(.T.))}, , , )
								oPedCom:nWidth  := 120
								oPedCom:nHeight := 10
								oPedCom:Align   := CONTROL_ALIGN_RIGHT
								oPedCom:SetColor(RGB(002, 070, 112), )
								
							EndIf*/
							
							If U_GOX14NFO() .And. (_cTab1)->&(_cCmp1 + "_TIPO") # "6"
								
								oPedCom := THButton():New(0, 0, "&Nota Origem", oPanelBot, {|| NFOriN()}, , , )
								oPedCom:nWidth  := 120
								oPedCom:nHeight := 10
								oPedCom:Align   := CONTROL_ALIGN_RIGHT
								oPedCom:SetColor(RGB(002, 070, 112), )
								
							EndIf
							
							If GetNewPar("MV_ZGOCPAU", .F.) .And. (_cTab1)->&(_cCmp1 + "_TIPO") # "6"
								
								oPedCom := THButton():New(0, 0, "&Cria Prod Aut", oPanelBot, {|| U_GOXPrdAu()}, , , )
								oPedCom:nWidth  := 120
								oPedCom:nHeight := 10
								oPedCom:Align   := CONTROL_ALIGN_RIGHT
								oPedCom:SetColor(RGB(002, 070, 112), )
								
							EndIf
							
							If GetNewPar("MV_ZGOPDAU", .F.) .And. (_cTab1)->&(_cCmp1 + "_TIPO") # "6"
								
								oPedCom := THButton():New(0, 0, "&Cria Pedido", oPanelBot, {|| U_GOXPedAu()}, , , )
								oPedCom:nWidth  := 120
								oPedCom:nHeight := 10
								oPedCom:Align   := CONTROL_ALIGN_RIGHT
								oPedCom:SetColor(RGB(002, 070, 112), )
								
							EndIf
							
							lDireto := IIf(lPreNota, .F., VldInfoNfe(.F.))
							
							If GetNewPar("MV_XGTPGDI", .F.) .And. lDireto
								
								If !MsgYesNo("Deseja pular a alteração dos dados do xml e ir diretamente para a rotina de Documento de Entrada?", "Importação de Nota Fiscal")
								
									lDireto := .F.
									
								EndIf
								
							EndIf

			ACTIVATE MSDIALOG oDlgItens CENTERED ON INIT (valPC(), IIf(lDireto, Eval({|| lConfirm := .T., IIf((MsAguarde({|| lImport := ImpXMLNFe(@lConfirm)}, "Importando XML da Nota Fiscal..."), lImport), oDlgItens:End(), .F.)}), Nil))
			
			SetKey(VK_F7, {|| })
			
		Else
		
			Aviso("Aviso", "Fornecedor não encontrado para o CNPJ:" + (_cTab1)->&(_cCmp1 + "_CGCEMI"), {"Ok"}, 2)
			oGOLog:Add("***Fornecedor não encontrado para o CNPJ:" + (_cTab1)->&(_cCmp1 + "_CGCEMI") + ". Processo abortado.")
			Break
			
		EndIf
		
	End Sequence
	
	dbCloseArea("SA2")
	dbCloseArea("SA5")
	
	If !lConfirm
	
		oGOLog:NewLine()
		oGOLog:Add("***Importação cancelada pelo usuário...", 1)
		
	EndIf
	
	oGOLog:NewLine()
	oGOLog:Add("-------- Fim da importação da Nota Fiscal de número: " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " e série: " + AllTrim((_cTab1)->&(_cCmp1 + "_SERIE")) + IIf(lConfirm, ". Status final: " + IIf(lImport, "Importada com sucesso.", "Houve erros. Não importada."), ""))
	//RefreshTab()
	//RefreshLog()
	
Return .T.

Static Function NFOriN()
	
	Local aFields := {}
	Local oFiltros
	Local nI
	
	Private aSize := MsAdvSize(.F., .F.)
	Private oLayer
	
	Private oDlgNFOri
	
	Private aValNFS  := {}
	Private aHeadNFO := {"D2_DOC", "D2_SERIE", "D2_CLIENTE", "D2_LOJA", "D2_EMISSAO", "D2_ITEM", "D2_COD", "D2_UM", "D2_QUANT", "D2_PRCVEN", "D2_TOTAL", "D2_TES", "D2_QTDEDEV", "D2_NUMSEQ", "D2_LOTECTL", "D2_NUMLOTE"}
	
	SetKey(VK_F7, {|| })
	
	DEFINE MSDIALOG oDlgNFOri FROM aSize[7], 0 TO aSize[6]/1.2, aSize[5]/1.2 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgNFOri:lEscClose := .F.
		
		oLayer := FWLayer():New()
		oLayer:Init(oDlgNFOri, .F.)
			
			oLayer:AddLine('LN1', 20, .F.)
				
				oLayer:AddCollumn('COL1_LN1', 100, .T., 'LN1')
					
					oLayer:AddWindow('COL1_LN1', 'WIN1_COL1_LN1', "Filtros", 100, .F., .T., , 'LN1',)
						
						ADD FIELD aFields TITULO "Emissão de" CAMPO "EMISDE" TIPO "D" TAMANHO 8 DECIMAL 0 PICTURE "" VALID {|| NFOriQry()} NIVEL 1
						M->EMISDE := CToD("  /  /    ")
						
						ADD FIELD aFields TITULO "Emissão ate" CAMPO "EMISATE" TIPO "D" TAMANHO 8 DECIMAL 0 PICTURE "" VALID {|| NFOriQry()} NIVEL 1
						M->EMISATE := CToD("  /  /    ")
						
						ADD FIELD aFields TITULO "Nº Nota" CAMPO "NOTA" TIPO "C" TAMANHO TamSX3("F1_DOC")[1] DECIMAL 0 PICTURE "" VALID {|| NFOriQry()} NIVEL 1
						M->NOTA := Space(TamSX3("F1_DOC")[1])
						
						oFiltros := MsMGet():New(,, 4,,,,, {0,0,0,0},,,,,, oLayer:GetWinPanel('COL1_LN1', 'WIN1_COL1_LN1', 'LN1'),,.T.,,,,.T., aFields,,.T.,,,.T.)
						
						oFiltros:oBox:Align := CONTROL_ALIGN_ALLCLIENT
						
			oLayer:AddLine('LN2', 70, .F.)
				
				oLayer:AddCollumn('COL1_LN2', 100, .T., 'LN2')
					
					oLayer:AddWindow('COL1_LN2', 'WIN1_COL1_LN2', "Notas de Origem", 100, .F., .T., , 'LN2',)
						
						aValNFS := {}
						
						oBrwNFS := TCBrowse():New(01, 01, 000, 000, , /*{}*/, /*{4, 15}*/, oLayer:GetWinPanel('COL1_LN2', 'WIN1_COL1_LN2', 'LN2'), , , , , {||}, , , , , , , .F., , .T., , .F., , , )
						oBrwNFS:Align := CONTROL_ALIGN_ALLCLIENT
						
						SX3->( dbSetOrder(2) )
						
						For nI := 1 To Len(aHeadNFO)
							
							If SX3->( dbSeek(aHeadNFO[nI]) )
								
								ADD COLUMN TO oBrwNFS HEADER X3Titulo()   OEM DATA &("{|| aValNFS[oBrwNFS:nAt, " + cValToChar(nI) + "]}") ALIGN LEFT SIZE SX3->X3_TAMANHO PIXELS
								
							EndIf
							
						Next nI
						
						If !NFOriQry()
							
							MsgInfo("Não foram encontradas notas de saída com este produto para este fornecedor.")
							
							Return .F.
							
						EndIf
						
			oLayer:AddLine('LN3', 10, .F.)
				
				oLayer:AddCollumn('COL1_LN3', 100, .T., 'LN3')
					
					oPanelBot := tPanel():New(0,0,"",oLayer:GetColPanel('COL1_LN3', 'LN3'),,,,,RGB(239,243,247),000,015)
					oPanelBot:Align	:= CONTROL_ALIGN_BOTTOM
					
					oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| oDlgNFOri:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oLimp := THButton():New(0, 0, "Selecionar", oPanelBot, {|| SelNFOri()}, , , )
					oLimp:nWidth  := 80
					oLimp:nHeight := 10
					oLimp:Align := CONTROL_ALIGN_RIGHT
					oLimp:SetColor(RGB(002, 070, 112), )
					
					oLimp := THButton():New(0, 0, "Limpar NF Ori", oPanelBot, {|| LimpNFOri()}, , , )
					oLimp:nWidth  := 80
					oLimp:nHeight := 10
					oLimp:Align := CONTROL_ALIGN_RIGHT
					oLimp:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgNFOri CENTERED
	
	SetKey(VK_F7, {|| NFOriN()})
	
Return

Static Function SelNFOri()
	
	Local nPosDoc := AScan(aHeadNFO, {|x| x == "D2_DOC"})
	Local nPosSer := AScan(aHeadNFO, {|x| x == "D2_SERIE"})
	Local nPosIt  := AScan(aHeadNFO, {|x| x == "D2_ITEM"})
	
	If Len(aValNFS) > 0
		
		GDFieldPut(_cCmp2 + "_NFORI" , aValNFS[oBrwNFS:nAt][nPosDoc], oGetD:nAt, oGetD:aHeader, oGetD:aCols)
		GDFieldPut(_cCmp2 + "_SERORI", aValNFS[oBrwNFS:nAt][nPosSer], oGetD:nAt, oGetD:aHeader, oGetD:aCols)
		GDFieldPut(_cCmp2 + "_ITORI" , aValNFS[oBrwNFS:nAt][nPosIt], oGetD:nAt, oGetD:aHeader, oGetD:aCols)
		
		oDlgNFOri:End()
		
	Else
		
		MsgInfo("É necessário selecionar uma nota para confirmar.")
		
	EndIf
	
Return

Static Function LimpNFOri()
	
	GDFieldPut(_cCmp2 + "_NFORI" , Space(TamSX3(_cCmp2 + "_NFORI")[1]), oGetD:nAt, oGetD:aHeader, oGetD:aCols)
	GDFieldPut(_cCmp2 + "_SERORI", Space(TamSX3(_cCmp2 + "_NFORI")[1]), oGetD:nAt, oGetD:aHeader, oGetD:aCols)
	GDFieldPut(_cCmp2 + "_ITORI" , Space(TamSX3(_cCmp2 + "_NFORI")[1]), oGetD:nAt, oGetD:aHeader, oGetD:aCols)
	
	oDlgNFOri:End()
	
Return

Static Function NFOriQry()
	
	Local cQuery := ""
	Local nI
	
	Local cAlias := GetNextAlias()
	
	cQuery := " SELECT SD2.R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("SF2") + " SF2"
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2"
	cQuery += " 	ON SD2.D2_FILIAL = SF2.F2_FILIAL AND "
	cQuery += " 	SD2.D2_CLIENTE   = SF2.F2_CLIENTE AND "
	cQuery += " 	SD2.D2_LOJA      = SF2.F2_LOJA AND "
	cQuery += " 	SD2.D2_DOC       = SF2.F2_DOC AND "
	cQuery += " 	SD2.D2_SERIE     = SF2.F2_SERIE AND "
	cQuery += " 	SD2.D2_TIPO      = SF2.F2_TIPO "
	cQuery += " WHERE "
	cQuery += " 	SF2.F2_FILIAL  = '" + xFilial("SF2") + "' AND "
	
	// Verificar se é de interesse buscar saída do tipo normal com código de cliente que o retorno foi feito como Normal com o código de fornecedor.???
	cQuery += " SF2.F2_CLIENTE = '" + M->&(_cCmp1 + "_CODEMI") + "' AND "
	cQuery += " SF2.F2_LOJA    = '" + M->&(_cCmp1 + "_LOJEMI") + "' AND "
	
	cQuery += "     SD2.D2_COD     = '" + oGetD:aCols[oGetD:nAt, _nPosProdu] + "' AND "
	cQuery += " 	SD2.D2_ORIGLAN <> 'LF' AND "
	cQuery += " 	SD2.D2_QUANT > D2_QTDEDEV AND "
	cQuery += " 	SF2.D_E_L_E_T_ = ' ' AND "
	cQuery += " 	SD2.D_E_L_E_T_ = ' ' "
	
	If !Empty(M->NOTA)
	
		cQuery += " AND SF2.F2_DOC LIKE '%" + AllTrim(M->NOTA) + "%' "
		
	EndIf
	
	If !Empty(M->EMISDE)
	
		cQuery += " AND SF2.F2_EMISSAO >= '" + DToS(M->EMISDE) + "' "
		
	EndIf
	
	If !Empty(M->EMISATE)
	
		cQuery += " AND SF2.F2_EMISSAO <= '" + DToS(M->EMISATE) + "' "
		
	EndIf
	
	cQuery += " AND SF2.F2_EMISSAO <= '" + DToS(M->&(_cCmp1 + "_DTEMIS")) + "' "
	
	cQuery += " ORDER BY "
	cQuery += " 	SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_ITEM "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,, cQuery), cAlias, .F., .T.)
	
	If (cAlias)->( Eof() )
		
		(cAlias)->( dbCloseArea() )
		
		Return .F.
		
	Else
		
		aValNFS := {}
		
		While !(cAlias)->( Eof() )
			
			SD2->( dbGoTo((cAlias)->RECNO) )
			
			AAdd(aValNFS, Array(Len(aHeadNFO)))
			
			For nI := 1 To Len(aHeadNFO)
				
				ATail(aValNFS)[nI] := SD2->(&(aHeadNFO[nI]))
				
			Next nI
			
			(cAlias)->( dbSkip() )
			
		EndDo
		
		oBrwNFS:SetArray(aValNFS)
		oBrwNFS:Refresh()
		
	EndIf
	
	(cAlias)->( dbCloseArea() )
	
Return .T.

/* ####################################################################### *\
|| #           IMPORTAÇÃO DE CTE'S POR LOTE OU INDIVIDUALMENTE           # ||
\* ####################################################################### */
Static Function ImportaCTe()

	Local nI
	Local nA
	Local cAli     := IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "F", "SF2", "SF1")  //TIPOEN: N=Normal;D=Devolucao;B=Beneficiamento;I=Comp.ICMS;P=Comp.IPI;C=Comp.Preco/Frete
	Local aFields  := {_cCmp1 + "_FILIAL", _cCmp1 + "_DOC", _cCmp1 + "_SERIE", _cCmp1 + "_DTEMIS", _cCmp1 + "_CODEMI", ;
	_cCmp1 + "_LOJEMI", _cCmp1 + "_EMIT", _cCmp1 + "_EST"}
	Local aUpdFlds := {_cCmp1 + "_CONDPG", _cCmp1 + "_NATFIN"}
	Local aErros   := {}
	Local aRet
	Local cFiltro  := ""
	Local aAreaAli := (cAli)->( GetArea() )
	Local cError   := ""
	Local cWarning := ""
	Local lErro    := .F.
	//Local cEnchOld := GetMv("MV_ENCHOLD")
	Local lSucess  := .T.
	Local cExped   := ""
	Local cTagExp  := ""
	Local cForExp  := ""
	Local cLojExp  := ""
	Local cNomeExp := ""
	Local aAchouNota
	
	Private oXml
	
	If cAli == "SF2"
	
		AAdd(aFields, _cCmp1 + "_TES")
		AAdd(aUpdFlds, _cCmp1 + "_TES")
		
	Else
	
		AAdd(aFields, _cCmp1 + "_TES")
		AAdd(aUpdFlds, _cCmp1 + "_TES")
		
	EndIf
	
	AAdd(aFields, _cCmp1 + "_CONDPG")
	AAdd(aFields, _cCmp1 + "_NATFIN")
	AAdd(aFields, "NOUSER")

	Private oDlgCTe
	Private oBrwNFCTe
	Private oLayerImpCTe
	Private oGetCab
	Private aCab
	Private aNotas
	Private aNotasAux
	Private lConfirm  := .F.
	Private aButtons  := {{"&Visualizar", 'StaticCall(GOX001, VisuImpDoc, AlwaysTrue())', 0, 2}}
	Private lTemNotaCT
	
	aAchouNota := NumNotas((_cTab1)->&(_cCmp1 + "_CHAVE"), (_cTab1)->&(_cCmp1 + "_DOC"), (_cTab1)->&(_cCmp1 + "_SERIE"), ;
	              (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"), cEspCTe, (_cTab1)->&(_cCmp1 + "_DTEMIS"))
	
	// Se achou a nota importada
	If aAchouNota[1]
	
		If Aviso("Aviso", "O conhecimento de frete " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " já foi importado com o número: '" + aAchouNota[2] + "'. " + CRLF + ;
		         "Deseja marcá-lo como Processado?", {"Sim", "Não"}, 2) == 1
		
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_DOC")    := aAchouNota[2]
				(_cTab1)->&(_cCmp1 + "_TIPOEN") := aAchouNota[3]
				
				(_cTab1)->&(_cCmp1 + "_TPCOMP") := aAchouNota[11]
				
				(_cTab1)->&(_cCmp1 + "_ESPECI") := aAchouNota[4]
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := aAchouNota[5]
				(_cTab1)->&(_cCmp1 + "_SERIE")  := aAchouNota[6]
				(_cTab1)->&(_cCmp1 + "_CODEMI") := aAchouNota[7]
				(_cTab1)->&(_cCmp1 + "_LOJEMI") := aAchouNota[8]
				(_cTab1)->&(_cCmp1 + "_CGCEMI") := aAchouNota[9]
				
			(_cTab1)->( MsUnlock() )
			
		EndIf
		
		Return .F.
		
	ElseIf aAchouNota[10]
		
		/*Aviso("Aviso", "A Nota Fiscal já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " + ;
		      "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      "problema de chave duplicada.", {"Ok"}, 2)*/
		U_GOSetEr("O Conhecimento de Frete já existe para o Fornecedor/Cliente em questão, com a mesma numeração, porém " + ;
		      	   "com data de emissão ou espécie diferente. Por favor regularize a nota anterior para que não ocorra " + ;
		      	   "problema de chave duplicada.")
		
		Return .F.
		
	EndIf
	
/* ######################################### *\
|| #   VALIDA SE É ENTRADA OU SAÍDA PARA   # ||
|| #        CHAMAR A FUNÇÃO CORRETA        # ||
\* ######################################### */
	If cAli == "SF2"
		
		AAdd(aButtons, {"&Gerar Conhecimento", "StaticCall(GOX001, GeraSConhe)", 0, 3})
		
	Else
		
		AAdd(aButtons, {"&Gerar Conhecimento", "StaticCall(GOX001, GeraConhec)", 0, 3})
		
	EndIf
	
	oGOLog:Newline()
	oGOLog:Add("-------- Importando Conhecimento de Transporte de número: " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " e série: " + AllTrim((_cTab1)->&(_cCmp1 + "_SERIE")))
	
	dbSelectArea("SA2")
	SA2->( dbSetOrder(3) )
	
	If !SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) )
		
		U_GOSetEr("Fornecedor informado no XML não cadastrado.")
		
		Return .F.
		
	EndIf
	
	oXml := XmlParser((_cTab1)->&(_cCmp1 + "_XML"), "_", @cError, @cWarning)
	
	aRet := U_GOX003(.T., aErros, GetNodeCTe(oXml), .F., IsCteOS(oXml))
	
	If aRet[1]
		
		U_GOSetEr(,, .T.)
		
		lTemNotaCT := aRet[5]
		
		//Verifica o expedidor
		If !IsCteOS(oXml) .And. AllTrim(SM0->M0_CGC) $ GetNewPar("MV_XGTCEXP", "")
		
			If ValType(XmlChildEx(GetNodeCTe(oXml, "_infCte"), "_EXPED")) != "U"
			
				cTagExp := If(ValType(XmlChildEx(GetNodeCTe(oXml, "_infCte:_exped"),"_CNPJ")) == "O","_CNPJ","_CPF")
				cExped  := PadR(AllTrim(XmlChildEx(GetNodeCTe(oXml, "_infCte:_exped"),cTagExp):Text), 14)
				
				dbSelectArea("SA2")
				SA2->( dbSetOrder(3) )
				
				If SA2->( dbSeek(xFilial("SA2") + cExped) )
				
					While !SA2->( Eof() ) .And. SA2->A2_FILIAL == xFilial("SA2") .And. SA2->A2_CGC == cExped
					
						If SA2->A2_MSBLQL # "1"
						
							cForExp := SA2->A2_COD
							cLojExp := SA2->A2_LOJA
							cNomeExp := AllTrim(SA2->A2_NREDUZ)
							
							Exit
							
						EndIf
						
						SA2->( dbSkip() )
						
					EndDo
					
					If Empty(cForExp)
					
						If SA2->( dbSeek(xFilial("SA2") + cExped) )
						
							cForExp  := SA2->A2_COD
							cLojExp  := SA2->A2_LOJA
							cNomeExp := AllTrim(SA2->A2_NREDUZ)
							
						EndIf
						
					EndIf
					
				EndIf
				
				If !Empty(cForExp)
				
					If ((_cTab1)->&(_cCmp1 + "_CODEMI") != cForExp .Or. (_cTab1)->&(_cCmp1 + "_LOJEMI") != cLojExp)
						
						If Aviso("Expedidor CTe", "Foi encontrado o expedidor " + cNomeExp + " para o CTe " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + ", deseja assumí-lo como fornecedor da nota?", {"Sim", "Não"}, 2) == 1 
							
							RecLock(_cTab1, .F.)
							
								(_cTab1)->&(_cCmp1 + "_CODEMI") := cForExp
								(_cTab1)->&(_cCmp1 + "_LOJEMI") := cLojExp
								(_cTab1)->&(_cCmp1 + "_CGCEMI") := cExped
							
								If ValType(XmlChildEx(GetNodeCTe(oXml, "_infCte:_emit"), "_CNPJ")) != "U" .And. ;
									AllTrim(GetNodeCTe(oXml, "_infCte:_emit:_CNPJ:Text")) == SM0->M0_CGC
									
									(_cTab1)->&(_cCmp1 + "_FORMP") := .T.
									
								EndIf
								
							(_cTab1)->( MSUnlock() )
							
						EndIf
						
					Else
						
						If ValType(XmlChildEx(GetNodeCTe(oXml, "_infCte:_emit"), "_CNPJ")) != "U" .And. ;
							AllTrim(GetNodeCTe(oXml, "_infCte:_emit:_CNPJ:Text")) == SM0->M0_CGC
							
							RecLock(_cTab1, .F.)
								
								(_cTab1)->&(_cCmp1 + "_FORMP") := .T.
								
							(_cTab1)->( MSUnlock() )
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
		aCab      := AClone(aRet[2])
		aNotas    := AClone(aRet[3])
		aNotasAux := {}
		
		
		For nA := 1 To Len(aNotas)
			
			dbSelectArea(cAli)
			(cAli)->( dbSetOrder(1) )
			
			If (cAli)->( dbSeek(aNotas[nA][1][2]) )
			
				oGOLog:Add("- Nota de número: " + AllTrim(IIf(cAli == "SF2", SF2->F2_DOC, SF1->F1_DOC)) + ;
				             " e série: " + AllTrim(IIf(cAli == "SF2", SF2->F2_SERIE, SF1->F1_SERIE)) + ;
				             " informada no Xml foi encontrada no sistema e será marcada.", 2)
				AAdd(aNotasAux, {{"PRIMARYKEY", (cAli)->&(IndexKey())}})	
				
/* ######################################### *\
|| #    SÓ IMPORTA COM NOTAS VINCULADAS    # ||
\* ######################################### */
			Else
			
				oGOLog:Add("- Nota Fiscal com chave: " + aNotas[nA][1][2] + " informada no Xml não foi encontrada no sistema ou não satisfaz o filtro.", 2)
				lErro := .T.
				
			EndIf
			
		Next nA
		
		If lErro
			
			Return .F.
			
		EndIf
		
		If cAli == "SF2" .Or. !lTemNotaCT
			
			lSucess := GeraSConhe()
			
		Else
		
			lSucess := GeraConhec(IsCteRem())
			
		EndIf
		
	Else
		
		lSucess := .F.
		
		GravaXmlErro(aErros, .F.)
		
	EndIf
	
Return lSucess

////////////////////////////////////////

Static Function SetMarkNf()

	Local cAli     := IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "F", "SF2", "SF1")
	Local aAreaAli := (cAli)->( GetArea() )
	Local aChave
	Local lIsMark
	Local nPos
	Local cDoc     := AllTrim(IIf(cAli == "SF2", SF2->F2_DOC, SF1->F1_DOC))
	
	dbSelectArea(cAli)
	(cAli)->( dbSetOrder(1) )
	
	aChave  := SubStr((cAli)->&(IndexKey()), 3)
	lIsMark := oBrwNFCTe:IsMark(oBrwNFCTe:Mark())
	
	Begin Sequence
	
		If AScan(aNotas, {|x| x[1][2] == aChave}) > 0
		
			If lIsMark .And. Aviso("Aviso", "A Nota " + cDoc + " está informada no Xml, deseja realmente desmarcá-la?", {"Sim", "Não"}, 3) == 2
			
				Break
				
			EndIf
			
		Else
		
			If !lIsMark .And. Aviso("Aviso", "A Nota " + cDoc + " não está informada no Xml, deseja marcá-la?", {"Sim", "Não"}, 3) == 2
			
				Break
				
			EndIf
			
		EndIf
		
		RecLock(cAli, .F.)
		
			If cAli == "SF2"
			
				SF2->F2_OK := IIf(lIsMark, Space(2), oBrwNFCTe:Mark())
				
			Else
			
				SF1->F1_OK := IIf(lIsMark, Space(2), oBrwNFCTe:Mark())
				
			EndIf
			
		(cAli)->( MsUnlock() )
		
		If lIsMark
		
			nPos := AScan(aNotasAux, {|x| x[1][2] == (cAli)->&(IndexKey())})
			ADel(aNotasAux, nPos)
			ASize(aNotasAux, Len(aNotasAux) - 1)
			
		Else
		
			AAdd(aNotasAux, {{"PRIMARYKEY", (cAli)->&(IndexKey())}})
			
		EndIf
		
	End Sequence
	
	RestArea(aAreaAli)
	oBrwNFCTe:Refresh()
	
Return

////////////////////////////////////////

Static Function MarkNFs(aNotas)

	Local cAli     := IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "F", "SF2", "SF1")
	Local nI
	Local aAreaAli := (cAli)->( GetArea() )
	Local lFind    := .T.
	Local cDoc     := AllTrim(IIf(cAli == "SF2", SF2->F2_DOC, SF1->F1_DOC))
	Local cSerie   := AllTrim(IIf(cAli == "SF2", SF2->F2_SERIE, SF1->F1_SERIE))
	
	oGOLog:NewLine()
	oGOLog:Add("-Buscando Notas Fiscais informadas no Xml:", 1)
	
	If Empty(aNotas)
	
		oGOLog:Add("***Nenhuma Nota Fiscal informada no Xml.", 2)
		
	EndIf
	
	For nI := 1 To Len(aNotas)
	
		dbSelectArea(cAli)
		(cAli)->( dbSetOrder(1) )
		
		If (cAli)->( dbSeek(xFilial(cAli) + aNotas[nI][1][2]) )
		
			oGOLog:Add("-Nota de número: " + cDoc + " e série: " + cSerie + " informada no Xml foi encontrada no sistema e será marcada.", 2)
			
			RecLock(cAli, .F.)
			
				If cAli == "SF2"
				
					SF2->F2_OK := oBrwNfCTe:Mark()
					
				Else
				
					SF1->F1_OK := oBrwNfCTe:Mark()
					
				EndIf
				
			(cAli)->( MsUnlock() )
			
			AAdd(aNotasAux, {{"PRIMARYKEY", (cAli)->&(IndexKey())}})
			
		Else
		
			oGOLog:Add("-Nota Fiscal com chave: " + aNotas[nI][1][2] + " informada no Xml não foi encontrada no sistema ou não satisfaz o filtro.", 2)
			lFind := .F.
			
		EndIf
		
	Next nI
	
	RestArea(aAreaAli)
	oBrwNFCTe:Refresh()
	
	If !lFind .And. Aviso("Leitura das Notas Fiscais", "Há Notas Fiscais informadas no Xml que não foram encontradas no sistema ou que o filtro desconsiderou. Deseja continuar?", {"Continuar", "Cancelar"}, 2) == 2
	
		oDlgCTe:End()
		
	EndIf
	
Return

////////////////////////////////////////

Static Function GeraConhec(lAgrup)
	
	Local nA
	Local aCabec     := {}
	Local aItens     := {}
	Local cEst       := ""
	Local cDoc       := ""
	Local cProdFrete := IIf(lAgrup, cPrdFrtSai, AllTrim(GetNewPar("MV_XGTFRTE", "")))
	Local cTpCTEnt   := IIf(lAgrup, AllTrim(GetNewPar("MV_ZGOTCTA", "N")), AllTrim(GetNewPar("MV_XSNTPCT", "C")))
	Local lConfAtu   := .T. //lConfere
	Local lSucess    := .T.
	Local nItem      := 0
	Local nPosAgt    := AScan(aCab, {|x| x[1] == "MV_PAR17"})
	Local nPosCod    := 0
	Local nPosCon    := AScan(aCab, {|x| x[1] == "MV_PAR31"})
	Local nPosEsp    := AScan(aCab, {|x| x[1] == "F1_ESPECIE"})
	Local nPosNat    := AScan(aCab, {|x| x[1] == "Natureza"})
	Local nPosTes    := AScan(aCab, {|x| x[1] == "MV_PAR27"})
	Local nTamItem   := TamSX3("D1_ITEM")[1]
	Local nTotPond   := 0
	Local nTotProd   := 0
	Local nVlConhe   := 0
	Local nVlPonde   := 0
	Local aSF8       := {}
	Local nI
	Local nItAju     := 0
	Local aIcms
	Local cTpCte     := "N"
	//Local cDTpCTe    := "N - Normal"
	Local cDTpCTe    := "N"
	Local cforPag    := ""
	
	Local nPosVUnit  := 4
	Local nPosVTot   := 5
	
	Local cTransp    := ""
	Local cLojTran   := ""
	Local lAchouSF8  := .F.
	
	Local cOrigImpF        := AllTrim(GetNewPar("MV_ZGOORIF", ""))
	Local cOrigImpD        := AllTrim(GetNewPar("MV_ZGOORID", ""))
		
	Private _aItemOri      := {}
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .F.
	Private cXDForPag      := "F-FOB"
	
	// TIPO DE CTE
	If IsNodeCTe(oXml, "_infCte:_ide:_tpCTe")
	
		cTpCte := GetNodeCTe(oXml, "_infCte:_ide:_tpCTe:Text")
		
		Do Case
		
			Case cTpCte == "0"
				
				//cDTpCTe := "N - Normal"
				cDTpCTe := "N"
				
			Case cTpCte == "1"
				
				//cDTpCTe := "C - Complemen.Valores"
				cDTpCTe := "C"
				
			Case cTpCte == "2"
				
				//cDTpCTe := "A - Anula.Valores"
				cDTpCTe := "A"
				
			Case cTpCte == "3"
				
				//cDTpCTe := "S - Substituto"
				cDTpCTe := "S"
				
		EndCase
		
	EndIf
	
	// SE FOR GERAÇÃO DE LOTE, NÃO ABRE TELA DE CONFERÊNCIA
	
	lConfAtu := GetNewPar("MV_XGTCOLT", .T.)
	
	lConfirm := .T.
	
	If IsNodeCTe(oXml, "_infCte:_ide:_UFIni") .And. !(cFilAnt $ GetNewPar("MV_ZGOFESC", "")) 
		
		cEst := GetNodeCTe(oXml, "_infCte:_ide:_UFIni:Text")
		
	Else
		
		cEst := Posicione("SA2", 1, xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI"), "A2_EST")
		
	EndIf
/* ####################################################################### *\
|| #                          CABEÇALHO DA NOTA                          # ||
\* ####################################################################### */
	aCabec := {{"F1_DOC"    , (_cTab1)->&(_cCmp1 + "_DOC")   , Nil, Nil}, ;
	           {"F1_SERIE"  , (_cTab1)->&(_cCmp1 + "_SERIE") , Nil, Nil}, ;
	           {"F1_FORNECE", (_cTab1)->&(_cCmp1 + "_CODEMI"), Nil, Nil}, ; 
	           {"F1_LOJA"   , (_cTab1)->&(_cCmp1 + "_LOJEMI"), Nil, Nil}, ;
	           {"F1_COND"   , cCond                          , Nil, Nil}, ;
	           {"F1_EMISSAO", (_cTab1)->&(_cCmp1 + "_DTEMIS"), Nil, Nil}, ;
	           {"F1_DTDIGIT", dDataBase                      , Nil, Nil}, ;
	           {"F1_TIPO"   , cTpCTEnt                       , Nil, Nil}, ;
	           {"F1_ESPECIE", cEspCTe                        , Nil, Nil}, ;
	           {"F1_FORMUL" , IIf((_cTab1)->&(_cCmp1 + "_FORMP"), "S", "N")       , Nil, Nil}, ;
	           {"F1_CHVNFE" , (_cTab1)->&(_cCmp1 + "_CHAVE") , Nil, Nil}, ;
	           {"F1_TPFRETE", cXDForPag                      , Nil, Nil}, ;
			   {"F1_TPCTE"  , cDTpCTe                        , Nil, Nil}, ;	           
	           {"F1_MODAL"  , "01"                           , Nil, Nil}, ;
	           {"E2_NATUREZ", cNatur                         , Nil, Nil}, ;
	           {"F1_EST"    , cEst                           , Nil, Nil} ;
	          }
			  
	If !Empty(cOrigImpF) // Origem do Lançamento
		
		AAdd(aCabec, {cOrigImpF, "GOX001", Nil})
		
	EndIf
	
	If cTpCTEnt == "C"
		
		AAdd(aCabec, {})
		AIns(aCabec, 9)
		
		aCabec[9] := {"F1_TPCOMPL", IIf(cTpCte == "C", "1", "3") , Nil, Nil}
		
	EndIf
	
	If SF1->( FieldPos("F1_MUORITR") ) > 0
		
		//(_cTab1)->&(_cCmp1 + "_CHAVE")
		
		AAdd(aCabec, {"F1_UFORITR", GFE065RUF(Left((_cTab1)->&(_cCmp1 + "_CIDINI"), 2), 2), Nil, Nil})
		AAdd(aCabec, {"F1_UFDESTR", GFE065RUF(Left((_cTab1)->&(_cCmp1 + "_CIDFIM"), 2), 2), Nil, Nil})
		AAdd(aCabec, {"F1_MUORITR", Right((_cTab1)->&(_cCmp1 + "_CIDINI"), 5), Nil, Nil})
		AAdd(aCabec, {"F1_MUDESTR", Right((_cTab1)->&(_cCmp1 + "_CIDFIM"), 5), Nil, Nil})
		
	EndIf
	
	nPosVal := AScan(aCab, {|x| x[1] == "MV_PAR21"}) // VALOR DO CONHECIMENTO
	
	// VALIDA PRODUTO PASSADO POR PARÂMETRO
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	
	If !Empty(cProdFrete) .And. !SB1->( dbSeek(xFilial("SB1") + cProdFrete) )
	
		Aviso("Produto padrão de Frete", "Deve ser informado no parâmetro MV_XGTFRTE o produto padrão que será utilizado para a geração dos itens do conhecimento de frete.", {"Ok"}, 2)
		Return .F.
		
	EndIf
	
	If GetNewPar("MV_ZGOVLTI", .F.)
		
		dbSelectArea("SF4")
		SF4->( dbSetOrder(1) )
		If SF4->( dbSeek(xFilial("SF4") + cTesE) )
			
			dbSelectArea("SA2")
			SA2->( dbSetOrder(1) )
			If SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
			
				If SA2->A2_SIMPNAC == "1" .And. SF4->F4_ICM == "S"
					
					Aviso("Tes gera ICMS", "Um Ct-e com Fornecedor Simples Nacional não pode ter TES que gera ICMS.", {"Ok"}, 2)
					Return .F.
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	aIcms := XmlCteIcms(oXml)
	
	// NOTAS SELECIONADAS
	For nA := 1 To Len(aNotasAux)
	
/* ####################################################################### *\
|| #                                 SF1                                 # ||
|| #                     CABECALHO DAS NF DE ENTRADA                     # ||
\* ####################################################################### */
		dbSelectArea("SF1")
		// Numero + Serie + Fornecedor + Loja + Tipo da Nota
		SF1->( dbSetOrder(1) )
		
		If SF1->( dbSeek(aNotasAux[nA][1][2]) )
		
			AAdd(aSF8, {SF1->F1_DTDIGIT, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA})
			//       *Num. Docto.  *Serie          *Cliente          *Loja
			cDoc := (SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
			
			If Left(SF1->F1_ESPECIE, 3) $ "CTE" .And. !Empty(SF1->F1_TPFRETE)
				
				If SF1->F1_TPFRETE == "C"
					
					cXDForPag := "C-CIF"
					aCabec[AScan(aCabec, {|x| x[1] == "F1_TPFRETE"})][2] := cXDForPag
					 
				EndIf
				
			EndIf
			
/* ####################################################################### *\
|| #                                 SD1                                 # ||
|| #                       ITENS DAS NF DE ENTRADA                       # ||
\* ####################################################################### */
			dbSelectArea("SD1")
			SD1->( dbSetOrder(1) )
			
			If SD1->( dbSeek(cDoc) )
			
				While SD1->( !Eof() ) .And. (SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA) == cDoc
				
					// BUSCA PRODUTO NO ARRAY
					nPosCod	 := aScan(aItens, {|x| x[2][2] == SD1->D1_COD})
					
/* ####################################################################### *\
|| #                            ITENS DA NOTA                            # ||
\* ####################################################################### */
					
					//[TODO] verificar se é de ativo imobilizado, caso seja, deve pegar outra TES.
					
					If Empty(cProdFrete) .Or. (!Empty(cProdFrete) .And. Empty(aItens))
						
						AAdd(aItens, {{"D1_ITEM"   , STRZERO(++nItem, nTamItem), Nil}, ;
						              {"D1_COD"    , SD1->D1_COD               , Nil}, ;
						              {"D1_UM"     , SD1->D1_UM                , Nil}, ;
						              {"D1_QUANT"  , 1                         , Nil}, ;
						              {"D1_VUNIT"  , SD1->D1_TOTAL             , Nil}, ;
						              {"D1_TOTAL"  , SD1->D1_TOTAL             , Nil}, ;
						              ;//{"D1_TIPO"   , cTpCTEnt                  , Nil}, ;
						              {"D1_SERIE"  , SD1->D1_SERIE             , Nil}, ;
						              {"D1_TES"    , cTesE                     , Nil}, ;
						              {"D1_PICM"   , aIcms[3]                  , Nil}, ;
						              {"AUTDELETA" , "N"                       , Nil}  ;
						             })
									 
						If !Empty(cOrigImpD) // Origem do Lançamento
							
							AAdd(ATail(aItens), {cOrigImpD, "GOX001", Nil})
							
						EndIf
						
						//{"D1_NFORI"  , SD1->D1_DOC               , Nil}, ;
						//{"D1_SERIORI", SD1->D1_SERIE             , Nil}, ;
						
						If cTpCTEnt == "C"
							
							If GetNewPar("MV_ZSNCTCE", .F.)
								
								AAdd(ATail(aItens), {"D1_CONTA", SD1->D1_CONTA, Nil})
								AAdd(ATail(aItens), {"D1_CC"   , SD1->D1_CC, Nil})
								
							EndIf
							
							ADel(ATail(aItens), 4)
							ASize(ATail(aItens), Len(ATail(aItens)) - 1)
							
							AAdd(ATail(aItens), {"D1_NFORI", SD1->D1_DOC, Nil})
							AAdd(ATail(aItens), {"D1_SERIORI", SD1->D1_SERIE, Nil})
							AAdd(_aItemOri, PADR(SD1->D1_ITEM, nTamItem))
							
						ElseIf cTpCTEnt == "N"
							
							If GetNewPar("MV_ZSNCTCS", .F.)
								
								AAdd(ATail(aItens), {"D1_CONTA", SD1->D1_CONTA, Nil})
								AAdd(ATail(aItens), {"D1_CC"   , SD1->D1_CC, Nil})
								
							EndIf
							
							nPosVUnit := 5
							nPosVTot  := 6
							
							If GetNewPar("MV_XGTCTSO", .F.)
								
								AAdd(ATail(aItens), {"D1_NFORI", SD1->D1_DOC, Nil})
								AAdd(ATail(aItens), {"D1_SERIORI", SD1->D1_SERIE, Nil})
								AAdd(_aItemOri, PADR(SD2->D2_ITEM, nTamItem))
								
							EndIf
							
						EndIf
					
					EndIf
					
					// SÓ ADICIONA UM ITEM CASO TIVER O PRODUTO PADRÃO POR PARÂMETRO E O PRODUTO FOR VÁLIDO
					If !Empty(cProdFrete)
					
						// DADOS DO PRODUTO PADRÃO
						ATail(aItens)[2][2]         := SB1->B1_COD
						ATail(aItens)[3][2]         := SB1->B1_UM
						ATail(aItens)[nPosVUnit][2] := SF1->F1_VALMERC
						ATail(aItens)[nPosVTot][2]  := SF1->F1_VALMERC
						
						nTotProd += SF1->F1_VALMERC
						
						Exit
						
					Else
					
						// SOMA O TOTAL DOS PRODUTOS
						nTotProd += SD1->D1_TOTAL
						
					EndIf
					
					SD1->( dbSkip() )
					
				EndDo
				
			EndIf
			
			SD1->( dbCloseArea() )
			
		EndIf
		
		SF1->( dbCloseArea() )
		
	Next nA
	
/* ####################################################################### *\
|| #                           RATEIA O VALOR                            # ||
\* ####################################################################### */
	nVlConhe := aCab[nPosVal][2]
	
	If Empty(nVlConhe)
		
		nVlConhe := aIcms[4]
		aCabec[8][2] := "I"
		
	EndIf 
	
	For nA := 1 To Len(aItens)
		
		If nA > Len(aItens)
			
			Exit
			
		EndIf
		
		If nItAju > 0
			
			aItens[nA][1][2] := StrZero(Val(aItens[nA][1][2]) - nItAju, nTamItem)
			
		EndIf
		
		//          VALOR DO FRETE   VALOR TOTAL         TOTAL DOS ITENS
		nVlPonde := Round(nVlConhe * aItens[nA][5][2] / nTotProd, 2)  // (VALOR * CRITÉRIO / TOTAL DO CRITÉRIO = VALOR PONDERADO)
		
		aItens[nA][nPosVUnit][2] := nVlPonde // VALOR UNITÁRIO
		aItens[nA][nPosVTot][2] := nVlPonde // VALOR TOTAL
		
		nTotPond += nVlPonde
		
		If nVlPonde == 0 .And. Len(aItens) > 1
			
			aDel(aItens, nA)
			aSize(aItens, Len(aItens) - 1)
			
			nA--
			
			//Refaz numeração dos itens
			
			nItAju++
			
		EndIf
		
	Next nA
	
	If (nTotPond - nVlConhe) > 0
	
		ATail(aItens)[nPosVUnit][2] -= nTotPond - nVlConhe
		ATail(aItens)[nPosVTot][2] -= nTotPond - nVlConhe
		
	ElseIf (nTotPond - nVlConhe) < 0
	
		ATail(aItens)[nPosVUnit][2] += Abs(nTotPond - nVlConhe)
		ATail(aItens)[nPosVTot][2] += Abs(nTotPond - nVlConhe)
		
	EndIf
	
	SB1->( dbCloseArea() )
	
/* ####################################################################### *\
|| #                            IMPORTANDO...                            # ||
\* ####################################################################### */
	//Begin Transaction
	
		MsAguarde({|| MsExecAuto({|x, y, z, w| MATA103(x, y, z, w)}, aCabec, aItens, 3, lConfAtu)}, "Importação", ;
		          "Importando Compl. de " + IIf(aCabec[8][2]=="C", "Preço/Frete...", "ICMS..."))
		
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		
		If !lMsErroAuto .And. !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
		
			lConfirm := .F.
			lSucess  := .F.
			
		ElseIf lMsErroAuto .And. !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
		
			//DisarmTransaction()
			
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")  := "3"
				(_cTab1)->&(_cCmp1 + "_ERRO") := MontaErro(GetAutoGrLog())
				
			(_cTab1)->( MsUnlock() )
			
			lSucess := .F.
			
		Else
		
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_ESPECI") := cEspCTe
				(_cTab1)->&(_cCmp1 + "_TES")    := cTesE
				(_cTab1)->&(_cCmp1 + "_NATFIN") := cNatur
				(_cTab1)->&(_cCmp1 + "_CONDPG") := cCond
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := dDataBase
				(_cTab1)->&(_cCmp1 + "_HRIMP")  := Time()
				(_cTab1)->&(_cCmp1 + "_USUIMP") := cUserName
				
			(_cTab1)->( MsUnlock() )
			
			// FORÇA A GRAVAÇÃO DO TIPO DE CTE
			/*RecLock("SF1", .F.)
			
				SF1->F1_TPCTE   := cTpCte
				SF1->F1_TPFRETE := cforPag
				
			SF1->( MsUnlock() )*/
			
			For nI := 1 To Len(aSF8)
				
				cTransp   := aCab[AScan(aCab, {|x| x[1] == "MV_PAR25"})][2]
				cLojTran  := aCab[AScan(aCab, {|x| x[1] == "MV_PAR26"})][2]
				lAchouSF8 := .F.
				
				dbSelectArea("SF8")
				SF8->( dbSetOrder(1) )
				If SF8->( dbSeek(xFilial("SF8") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + cTransp + cLojTran) )
					
					While !SF8->( Eof() ) .And. SF8->F8_FILIAL == xFilial("SF8") .And. SF8->F8_NFDIFRE == (_cTab1)->&(_cCmp1 + "_DOC") .And. ;
						SF8->F8_SEDIFRE == (_cTab1)->&(_cCmp1 + "_SERIE") .And. SF8->F8_TRANSP == cTransp .And. SF8->F8_LOJTRAN == cLojTran
												
						If SF8->F8_NFORIG == aSF8[nI][2] .And. SF8->F8_SERORIG == aSF8[nI][3] .And. SF8->F8_FORNECE == aSF8[nI][4] .And. SF8->F8_LOJA == aSF8[nI][5]
							
							lAchouSF8 := .T.
							
							Exit
							
						EndIf						
						
						SF8->( dbSkip() )
						
					EndDo
					
				EndIf
				
				If !lAchouSF8
					
					RecLock("SF8", .T.)
					
						SF8->F8_FILIAL	:= xFilial("SF8")
						// Informação do conhecimento
						SF8->F8_NFDIFRE	:= (_cTab1)->&(_cCmp1 + "_DOC")
						SF8->F8_SEDIFRE	:= (_cTab1)->&(_cCmp1 + "_SERIE")
						SF8->F8_TRANSP	:= cTransp
						SF8->F8_LOJTRAN	:= cLojTran
						SF8->F8_TIPO	:= "F"
						// Informações da nota fiscal filha
						SF8->F8_DTDIGIT := aSF8[nI][1]
						SF8->F8_NFORIG	:= aSF8[nI][2]
						SF8->F8_SERORIG	:= aSF8[nI][3]
						SF8->F8_FORNECE	:= aSF8[nI][4]
						SF8->F8_LOJA	:= aSF8[nI][5]
						
					SF8->( MsUnlock() )
					
				EndIf
				
			Next nI
			
		EndIf
		
	//End Transaction
	
Return lSucess

/* ####################################################################### *\
|| #           GERA CONHECIMENTO DE ENTRADA COM NOTA DE SAÍDA            # ||
\* ####################################################################### */
Static Function GeraSConhe()
	
	Local nA
	Local aItens     := {}
	Local cDoc       := ''
	Local cProdFrete := cPrdFrtSai
	Local lConfAtu   := GetNewPar("MV_ZGOAUCS", .T.)
	Local lSucess    := .T.
	Local nItem      := 0
	Local nPosCod    := 0
	Local nPosVal    := 0
	Local nTamItem   := TamSX3("D1_ITEM")[1]
	Local nTotPond   := 0
	Local nTotProd   := 0
	Local nVlConhe   := 0
	Local nVlPonde   := 0
	Local aIcms
	Local cTpCte     := "N"
	//Local cDTpCTe    := "N - Normal"
	Local cDTpCTe    := "N"
	Local cforPag    := ""
	
	Local nI
	Local cEst
	
	Local cOrigImpF        := AllTrim(GetNewPar("MV_ZGOORIF", ""))
	Local cOrigImpD        := AllTrim(GetNewPar("MV_ZGOORID", ""))

	Local aSF8       := {}
	Local lAchouSF8  := .F.
	Local lAjuSF8    := GetNewPar("MV_XAJUSF8", .f.)

	
	Private _aItemOri      := {}
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .F.
	Private cXDForPag      := "C-CIF"
	
	// TIPO DE CTE
	If IsNodeCTe(oXml, "_infCte:_ide:_tpCTe")
		
		cTpCte := GetNodeCTe(oXml, "_infCte:_ide:_tpCTe:Text")
		
		Do Case
			
			Case cTpCte == "0"
				
				//cDTpCTe := "N - Normal"
				cDTpCTe := "N"
				
			Case cTpCte == "1"
				
				//cDTpCTe := "C - Complemen.Valores"
				cDTpCTe := "C"
				
			Case cTpCte == "2"
				
				//cDTpCTe := "A - Anula.Valores"
				cDTpCTe := "A"
				
			Case cTpCte == "3"
				
				//cDTpCTe := "S - Substituto"
				cDTpCTe := "S"
				
		EndCase
		
	EndIf
	
	// SE É FOB OU CIF
	/*If IsNodeCTe(oXml, "_infCte:_ide:_forPag")
		
		cforPag := GetNodeCTe(oXml, "_infCte:_ide:_forPag:Text")
		
		If cforPag == "0"// .Or. cforPag == "1" .Or. cforPag == "2"
			
			//cXDForPag := "C"
			cXDForPag := "C-CIF"
			
		EndIf
		
	EndIf*/
	
	//lConfAtu := GetNewPar("MV_XGTCOLT", .T.)
	
/* ######################################### *\
|| #               VALIDAÇÃO               # ||
|| #    (SE NÃO FOR IMPORTAÇÃO DE LOTE)    # ||
\* ######################################### */
	
	/*If IsNodeCTe(oXml, "_infCte:_ide:_UFFim") .And. !(cFilAnt $ GetNewPar("MV_ZGOFESC", "")) 
		
		cEst := GetNodeCTe(oXml, "_infCte:_ide:_UFFim:Text")
		
	Else*/
		
		cEst := Posicione("SA2", 1, xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI"), "A2_EST")
		
	//EndIf
	
/* ####################################################################### *\
|| #                          CABEÇALHO DA NOTA                          # ||
\* ####################################################################### */
	aCabec := {{"F1_DOC"    , (_cTab1)->&(_cCmp1 + "_DOC")   , Nil, Nil}, ;
			   {"F1_SERIE"  , (_cTab1)->&(_cCmp1 + "_SERIE") , Nil, Nil}, ;
			   {"F1_FORNECE", (_cTab1)->&(_cCmp1 + "_CODEMI"), Nil, Nil}, ;
	           {"F1_LOJA"   , (_cTab1)->&(_cCmp1 + "_LOJEMI"), Nil, Nil}, ;
	           {"F1_COND"   , cCond                          , Nil, Nil}, ;
	           {"F1_EMISSAO", (_cTab1)->&(_cCmp1 + "_DTEMIS"), Nil, Nil}, ;
	           {"F1_DTDIGIT", dDataBase                      , Nil, Nil}, ;
	           {"F1_TIPO"   , "N"                            , Nil, Nil}, ;
	           {"F1_ESPECIE", IIf(IsCTeOS(oXML), cEspCTeOS, cEspCTe)       , Nil, Nil}, ;
	           {"F1_FORMUL" , IIf((_cTab1)->&(_cCmp1 + "_FORMP"), "S", "N")       , Nil, Nil}, ;
	           {"F1_CHVNFE" , (_cTab1)->&(_cCmp1 + "_CHAVE") , Nil, Nil}, ;
	           {"F1_TPFRETE", cXDForPag                      , Nil, Nil}, ;
	           {"F1_TPCTE"  , cDTpCTe                        , Nil, Nil}, ;
	           {"F1_MODAL"  , "01"                           , Nil, Nil}, ;
	           {"E2_NATUREZ", cNatur                         , Nil, Nil}, ;
	           {"F1_EST"    , cEst                           , Nil, Nil} ;
	          }
			  
	If !Empty(cOrigImpF) // Origem do Lançamento
		
		AAdd(aCabec, {cOrigImpF, "GOX001", Nil})
		
	EndIf
	
	nPosVal := AScan(aCab, {|x| x[1] == "MV_PAR21"}) // VALOR DO CONHECIMENTO
	
	// VALIDA PRODUTO PASSADO POR PARÂMETRO
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	
	If !Empty(cProdFrete) .And. !SB1->( dbSeek(xFilial("SB1") + cProdFrete) )
	
		Aviso("Produto padrão de Frete", "Deve ser informado no parâmetro MV_XGTFRET o produto padrão que será utilizado para a geração dos itens do conhecimento de frete.", {"Ok"}, 2)
		Return .F.
		
	EndIf
	
	If !lTemNotaCT .And. Empty(cProdFrete)
	
		Aviso("Produto padrão de Frete", "Esse CTe não possui nota fiscal vinculada e não há produto padrão de frete informado. Portanto não será possível a importação.", {"Ok"}, 2)
		Return .F.
		
	EndIf
	
	If SF1->( FieldPos("F1_MUORITR") ) > 0
		
		//(_cTab1)->&(_cCmp1 + "_CHAVE")
		
		AAdd(aCabec, {"F1_UFORITR", GFE065RUF(Left((_cTab1)->&(_cCmp1 + "_CIDINI"), 2), 2), Nil, Nil})
		AAdd(aCabec, {"F1_UFDESTR", GFE065RUF(Left((_cTab1)->&(_cCmp1 + "_CIDFIM"), 2), 2), Nil, Nil})
		AAdd(aCabec, {"F1_MUORITR", Right((_cTab1)->&(_cCmp1 + "_CIDINI"), 5), Nil, Nil})
		AAdd(aCabec, {"F1_MUDESTR", Right((_cTab1)->&(_cCmp1 + "_CIDFIM"), 5), Nil, Nil})
		
	EndIf
	
	aIcms := XmlCteIcms(oXml)
	
	If lTemNotaCT 
	
		// NOTAS SELECIONADAS
		For nA := 1 To Len(aNotasAux)
		
/* ####################################################################### *\
|| #                                 SF2                                 # ||
|| #                      CABECALHO DAS NF DE SAIDA                      # ||
\* ####################################################################### */
			dbSelectArea("SF2")
			//    Chave NFe
			SF2->( dbSetOrder(1) )
			
			If SF2->( dbSeek(aNotasAux[nA][1][2]) )

				if lAjuSF8
					AAdd(aSF8, {iif(!empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO), SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA})
				endif
			
				//       *Num. Docto.  *Serie          *Cliente          *Loja
				cDoc := (SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
				
/* ####################################################################### *\
|| #                                 SD2                                 # ||
|| #                        ITENS DE VENDA DA NF                         # ||
\* ####################################################################### */
				dbSelectArea("SD2")
				SD2->( dbSetOrder(3) ) 
				
				If SD2->( dbSeek(cDoc) )
				
					While SD2->( !Eof() ) .And. (SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA) == cDoc
					
						// BUSCA PRODUTO NO ARRAY
						nPosCod	 := aScan(aItens, {|x| x[2][2] == SD2->D2_COD})
						
/* ####################################################################### *\
|| #                            ITENS DA NOTA                            # ||
\* ####################################################################### */
						If Empty(cProdFrete) .Or. (!Empty(cProdFrete) .And. Empty(aItens))
						
							AAdd(aItens, {{"D1_ITEM"   , STRZERO(++nItem, nTamItem), Nil}, ;
							              {"D1_COD"    , SD2->D2_COD               , Nil}, ;
							              {"D1_UM"     , SD2->D2_UM                , Nil}, ;
							              {"D1_QUANT"  , 1                         , Nil}, ;
							              {"D1_VUNIT"  , SD2->D2_TOTAL             , Nil}, ;
							              {"D1_TOTAL"  , SD2->D2_TOTAL             , Nil}, ;
							              ;//{"D1_TIPO"   , SD2->D2_TIPO              , Nil}, ;
							              {"D1_SERIE"  , SD2->D2_SERIE             , Nil}, ;
							              {"D1_TES"    , cTesS                     , Nil}, ;
							              {"D1_PICM"   , aIcms[3]                  , Nil}, ;
							              {"AUTDELETA" , "N"                       , Nil}  ;
							             })
							
							If !Empty(cOrigImpD) // Origem do Lançamento
								
								AAdd(ATail(aItens), {cOrigImpD, "GOX001", Nil})
								
							EndIf
	
							If GetNewPar("MV_XGTCTSO", .F.)
								
								AAdd(ATail(aItens), {"D1_NFORI", SD2->D2_DOC, Nil})
								AAdd(ATail(aItens), {"D1_SERIORI", SD2->D2_SERIE, Nil})
								AAdd(_aItemOri, PADR(SD2->D2_ITEM, nTamItem))
								
							EndIf

							If !Empty(cCCS)
								
								AAdd(ATail(aItens), {"D1_CC", cCCS, Nil})
								
							EndIf

						EndIf
						
						// SÓ ADICIONA UM ITEM CASO TIVER O PRODUTO PADRÃO POR PARÂMETRO E O PRODUTO FOR VÁLIDO
						If !Empty(cProdFrete)
							
							// DADOS DO PRODUTO PADRÃO
							If nTotProd == 0
							
								ATail(aItens)[2][2] := SB1->B1_COD
								ATail(aItens)[3][2] := SB1->B1_UM
								ATail(aItens)[5][2] := SF2->F2_VALMERC
								ATail(aItens)[6][2] := SF2->F2_VALMERC
								
							Else
							
								ATail(aItens)[5][2] += SF2->F2_VALMERC
								ATail(aItens)[6][2] += SF2->F2_VALMERC
								
							EndIf
							
							// SOMA O TOTAL DOS PRODUTOS
							nTotProd += SF2->F2_VALMERC
							Exit
							
						Else
						
							// SOMA O TOTAL DOS PRODUTOS
							nTotProd += SD2->D2_TOTAL
							
						EndIf
						
						SD2->( dbSkip() )
						
					EndDo
					
				EndIf
				
				SD2->( dbCloseArea() )
				
			EndIf
			
			SF2->( dbCloseArea() )
			
		Next nA
		
/* ####################################################################### *\
|| #                           RATEIA O VALOR                            # ||
\* ####################################################################### */
		nVlConhe := aCab[nPosVal][2]
		
		For nA := 1 To Len(aItens)
		
			//          VALOR DO FRETE   VALOR TOTAL         TOTAL DOS ITENS
			nVlPonde := Round(nVlConhe * aItens[nA][6][2] / nTotProd, 2) // (VALOR * CRITÉRIO / TOTAL DO CRITÉRIO = VALOR PONDERADO)
			aItens[nA][5][2] := nVlPonde // VALOR UNITÁRIO
			aItens[nA][6][2] := nVlPonde // VALOR TOTAL
			nTotPond += nVlPonde
			
		Next nA
		
		If Len(aItens) > 0
			
			If (nTotPond - nVlConhe) > 0
			
				ATail(aItens)[5][2] -= nTotPond - nVlConhe 
				ATail(aItens)[6][2] -= nTotPond - nVlConhe
				
			ElseIf (nTotPond - nVlConhe) < 0
			
				ATail(aItens)[5][2] += Abs(nTotPond - nVlConhe)
				ATail(aItens)[6][2] += Abs(nTotPond - nVlConhe)
				
			EndIf
			
		EndIf
		
	Else
	
		AAdd(aItens, {{"D1_ITEM"  , STRZERO(1, nTamItem), Nil}, ;
		              {"D1_COD"   , SB1->B1_COD         , Nil}, ;
		              {"D1_UM"    , SB1->B1_UM          , Nil}, ;
		              {"D1_QUANT" , 1                   , Nil}, ;
		              {"D1_VUNIT" , aCab[nPosVal][2]    , Nil}, ;
		              {"D1_TOTAL" , aCab[nPosVal][2]    , Nil}, ;				
		              {"D1_TES"   , cTesS               , Nil}, ;
		              {"D1_PICM"  , aIcms[3]            , Nil}, ;
		              {"AUTDELETA", "N"                 , Nil}  ;
		             })
					 
		If !Empty(cOrigImpD) // Origem do Lançamento
			
			AAdd(ATail(aItens), {cOrigImpD, "GOX001", Nil})
			
		EndIf

		If !Empty(cCCS)
			
			AAdd(ATail(aItens), {"D1_CC", cCCS, Nil})

		EndIf
		
	EndIf
	
	SB1->( dbCloseArea() )
	
/* ####################################################################### *\
|| #                            IMPORTANDO...                            # ||
\* ####################################################################### */
	//Begin Transaction
	
		MsAguarde({|| MsExecAuto({|x, y, z, w| MATA103(x, y, z, w)}, aCabec, aItens, 3, lConfAtu)}, "Importação", "Importando Conhecimento Normal")
		
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		
		If !lMsErroAuto .And. !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + ;
		   (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
			
			lConfirm := .F.
			lRet     := .F.
			lSucess  := .F.
			
		ElseIf lMsErroAuto
		
			//DisarmTransaction()
			
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")  := "3"
				(_cTab1)->&(_cCmp1 + "_ERRO") := MontaErro(GetAutoGrLog())
				
			(_cTab1)->( MsUnlock() )
			
			lRet    := .F.
			lSucess := .F.
			
		Else
		
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_ESPECI") := cEspNFe
				(_cTab1)->&(_cCmp1 + "_NATFIN") := cNatur
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := dDataBase
				(_cTab1)->&(_cCmp1 + "_HRIMP")  := Time()
				(_cTab1)->&(_cCmp1 + "_USUIMP") := cUserName
				
			(_cTab1)->( MsUnlock() )
			
			// FORÇA A GRAVAÇÃO DO TIPO DE CTE
			/*RecLock("SF1", .F.)
			
				SF1->F1_TPCTE   := cTpCte
				SF1->F1_TPFRETE := cforPag
				
			SF1->( MsUnlock() )*/


			if lAjuSF8

				For nI := 1 To Len(aSF8)

					cTransp   := SF1->F1_FORNECE//aCab[AScan(aCab, {|x| x[1] == "MV_PAR25"})][2]
					cLojTran  := SF1->F1_LOJA//aCab[AScan(aCab, {|x| x[1] == "MV_PAR26"})][2]
					lAchouSF8 := .F.

					dbSelectArea("SF8")
					SF8->( dbSetOrder(1) )
					If SF8->( dbSeek(xFilial("SF8") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + cTransp + cLojTran) )

						While !SF8->( Eof() ) .And. SF8->F8_FILIAL == xFilial("SF8") .And. SF8->F8_NFDIFRE == (_cTab1)->&(_cCmp1 + "_DOC") .And. ;
						SF8->F8_SEDIFRE == (_cTab1)->&(_cCmp1 + "_SERIE") .And. SF8->F8_TRANSP == cTransp .And. SF8->F8_LOJTRAN == cLojTran

							/*If SF8->F8_NFORIG == aSF8[nI][2] .And. SF8->F8_SERORIG == aSF8[nI][3] .And. SF8->F8_FORNECE == aSF8[nI][4] .And. SF8->F8_LOJA == aSF8[nI][5]

								lAchouSF8 := .T.

								Exit

							EndIf*/

							RecLock("SF8", .F.)

								SF8->( dbDelete() )

							SF8->( MSUnlock() )

							SF8->( dbSkip() )

						EndDo

					EndIf

					//If !lAchouSF8

						RecLock("SF8", .T.)

						SF8->F8_FILIAL	:= xFilial("SF8")
						// Informa?o do conhecimento
						SF8->F8_NFDIFRE	:= (_cTab1)->&(_cCmp1 + "_DOC")
						SF8->F8_SEDIFRE	:= (_cTab1)->&(_cCmp1 + "_SERIE")
						SF8->F8_TRANSP	:= cTransp
						SF8->F8_LOJTRAN	:= cLojTran
						SF8->F8_TIPO	:= "F"
						// Informa?es da nota fiscal filha
						SF8->F8_DTDIGIT := aSF8[nI][1]
						SF8->F8_NFORIG	:= aSF8[nI][2]
						SF8->F8_SERORIG	:= aSF8[nI][3]
						SF8->F8_FORNECE	:= aSF8[nI][4]
						SF8->F8_LOJA	:= aSF8[nI][5]

						SF8->( MsUnlock() )

					//EndIf

				Next nI

			endif
			
		EndIf
		
		SF1->( dbCloseArea() )
		
	//End Transaction
	
Return lSucess

////////////////////////////////////////

Static Function ImportarCan()
	
	Local aCabec
	Local aItens   := {}
	Local aAreaSF1 := SF1->( GetArea() )
	Local aAreaSZW := (_cTab1)->( GetArea() )
	Local cChave
	Local lElimina := .T.
	Local cErroCan
	
	Local lExcAut  := GetNewPar("MV_ZGOEXAT", .T.)
	
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	
	If cEvtoTp $ "N;C"
		
		If ExistBlock("GOXDELC")
					
			lElimina := ExecBlock("GOXDELC", .F., .F., {})
			
		EndIf
		
		If lElimina .And. lExcAut
			
			oGOLog:NewLine()
			oGOLog:Add("-------- Importando Cancelamento para a Nota Fiscal de número: " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " e série: " + AllTrim((_cTab1)->&(_cCmp1 + "_SERIE")))
			cChave := (_cTab1)->&(_cCmp1 + "_CHAVE")
			
			dbSelectArea("SF1")
			SF1->( dbSetOrder(1) )
			
			If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
			
				aCabec := {{"F1_DOC"    , SF1->F1_DOC    , Nil, Nil}, ;
				           {"F1_SERIE"  , SF1->F1_SERIE  , Nil, Nil}, ;
				           {"F1_FORNECE", SF1->F1_FORNECE, Nil, Nil}, ;
				           {"F1_LOJA"   , SF1->F1_LOJA   , Nil, Nil}, ;
				           {"F1_COND"   , SF1->F1_COND   , Nil, Nil}, ;
				           {"F1_EMISSAO", SF1->F1_EMISSAO, Nil, Nil}, ;
				           {"F1_DTDIGIT", SF1->F1_DTDIGIT, Nil, Nil}, ;      
				           {"F1_EST"    , SF1->F1_EST    , Nil, Nil}, ;      
				           {"F1_TIPO"   , SF1->F1_TIPO   , Nil, Nil}, ;
				           {"F1_ESPECIE", SF1->F1_ESPECIE, Nil, Nil}, ;
				           {"F1_FORMUL" , SF1->F1_FORMUL , Nil, Nil}, ;
				           {"F1_CHVNFE" , SF1->F1_CHVNFE , Nil, Nil};
				          }
				
				dbSelectArea("SD1")
				SD1->( dbSetOrder(1) )
				SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
				
				While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
				      SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
				
					AAdd(aItens, {{"D1_ITEM"   , SD1->D1_ITEM   , Nil}, ;
					              {"D1_COD"    , SD1->D1_COD    , Nil}, ;
					              {"D1_UM"     , SD1->D1_UM     , Nil}, ;
					              {"D1_QUANT"  , SD1->D1_QUANT  , Nil}, ;
					              {"D1_VUNIT"  , SD1->D1_VUNIT  , Nil}, ;
					              {"D1_TOTAL"  , SD1->D1_TOTAL  , Nil}, ;
					              {"D1_TES"    , SD1->D1_TES    , Nil}, ;
					              ;//{"D1_TIPO"   , SD1->D1_TIPO   , Nil}, ;
					              {"D1_SERIE"  , SD1->D1_SERIE  , Nil}, ;
					              {"D1_BASEICM", SD1->D1_BASEICM, Nil}, ;
					              {"D1_PICM"   , SD1->D1_PICM   , Nil}, ;
					              {"D1_VALICM" , SD1->D1_VALICM , Nil}, ;
					              {"D1_BASEIPI", SD1->D1_BASEIPI, Nil}, ;
					              {"D1_IPI"    , SD1->D1_IPI    , Nil}, ;
					              {"D1_VALIPI" , SD1->D1_VALIPI , Nil}, ;
					              {"D1_CLASFIS", SD1->D1_CLASFIS, Nil}, ;
					              {"AUTDELETA" , "N"            , Nil};
					             })
					
					SD1->( dbSkip() )
					
				EndDo
				
				oGOLog:NewLine()
				
				//Begin Transaction
				
					dbSelectArea("SF1")
					SF1->( dbSetOrder(1) )
					
					If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
					
						If Empty(SF1->F1_STATUS)
							
							MsExecAuto({|x, y, z, w, k| MATA140(x, y, z, w, k)}, aCabec, aItens, 5, .F.)
							
						Else
							
							MsExecAuto({|x, y, z, w| MATA103(x, y, z, w)}, aCabec, aItens, 5)
							
						EndIf
						
					EndIf
					
					If lMsErroAuto
						
						cErroCan := MontaErro(GetAutoGrLog())
						
						AddErroXml(cErroCan)
						
						If IsInCallStack("U_GOX004")
							
							If lElapT .And. File("\workflow\modelos\importador\XML_CANC.htm")
								
								lEnvWFCan  := .T.
								lEnvWFCanF := .T.
								
								AAdd(oWFCan:oHTML:ValByName('xm.cFilial') , cFilAnt)
								AAdd(oWFCan:oHTML:ValByName('xm.cNumero') , aCabec[1][2])
								AAdd(oWFCan:oHTML:ValByName('xm.cFornece'), aCabec[3][2] + "/" + aCabec[4][2] )
								AAdd(oWFCan:oHTML:ValByName('xm.cEmissao'), DToC(aCabec[6][2]))
								AAdd(oWFCan:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
								AAdd(oWFCan:oHTML:ValByName('xm.cErro')   , cErroCan)
								
								AAdd(oWFCanF:oHTML:ValByName('xm.cFilial') , cFilAnt)
								AAdd(oWFCanF:oHTML:ValByName('xm.cNumero') , aCabec[1][2])
								AAdd(oWFCanF:oHTML:ValByName('xm.cFornece'), aCabec[3][2] + "/" + aCabec[4][2] )
								AAdd(oWFCanF:oHTML:ValByName('xm.cEmissao'), DToC(aCabec[6][2]))
								AAdd(oWFCanF:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
								AAdd(oWFCanF:oHTML:ValByName('xm.cErro')   , cErroCan)
								
							EndIf
							
						EndIf
						
						oGOLog:Add("Houve problemas no cancelamento da Nota Fiscal.", 1)
						
					Else
						
						dbSelectArea("SF1")
						SF1->( dbSetOrder(1) )
						
						If !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
							
							If IsInCallStack("U_GOX004")
								
								If File("\workflow\modelos\importador\XML_CANC.htm")
									
									lEnvWFCan  := .T.
									lEnvWFCanF := .T.
									
									AAdd(oWFCan:oHTML:ValByName('xm.cFilial') , cFilAnt)
									AAdd(oWFCan:oHTML:ValByName('xm.cNumero') , aCabec[1][2])
									AAdd(oWFCan:oHTML:ValByName('xm.cFornece'), aCabec[3][2] + "/" + aCabec[4][2] )
									AAdd(oWFCan:oHTML:ValByName('xm.cEmissao'), DToC(aCabec[6][2]))
									AAdd(oWFCan:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
									AAdd(oWFCan:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO OK - Documento escriturado foi excluído do sistema com SUCESSO!")
									
									AAdd(oWFCanF:oHTML:ValByName('xm.cFilial') , cFilAnt)
									AAdd(oWFCanF:oHTML:ValByName('xm.cNumero') , aCabec[1][2])
									AAdd(oWFCanF:oHTML:ValByName('xm.cFornece'), aCabec[3][2] + "/" + aCabec[4][2] )
									AAdd(oWFCanF:oHTML:ValByName('xm.cEmissao'), DToC(aCabec[6][2]))
									AAdd(oWFCanF:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
									AAdd(oWFCanF:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO OK - Documento escriturado foi excluído do sistema com SUCESSO!")
									
								EndIf
								
							EndIf
							
							cCanSit  := "2"
							cErroXML := ""
							
							SetStatusXML("NFE", "5", 1)
							
							oGOLog:Add("Nota Fiscal cancelada com sucesso.", 1)
							
						Else
							
							cErroCan := "Documento não foi excluído do sistema. Erro não foi identificado, o processo pode ser verificado manualmente para mais informações."
							
							AddErroXml(cErroCan)
							
							If IsInCallStack("U_GOX004")
								
								If lElapT .And. File("\workflow\modelos\importador\XML_CANC.htm")
									
									lEnvWFCan  := .T.
									lEnvWFCanF := .T.
									
									AAdd(oWFCan:oHTML:ValByName('xm.cFilial') , cFilAnt)
									AAdd(oWFCan:oHTML:ValByName('xm.cNumero') , aCabec[1][2])
									AAdd(oWFCan:oHTML:ValByName('xm.cFornece'), aCabec[3][2] + "/" + aCabec[4][2] )
									AAdd(oWFCan:oHTML:ValByName('xm.cEmissao'), DToC(aCabec[6][2]))
									AAdd(oWFCan:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
									AAdd(oWFCan:oHTML:ValByName('xm.cErro')   , cErroCan)
									
									AAdd(oWFCanF:oHTML:ValByName('xm.cFilial') , cFilAnt)
									AAdd(oWFCanF:oHTML:ValByName('xm.cNumero') , aCabec[1][2])
									AAdd(oWFCanF:oHTML:ValByName('xm.cFornece'), aCabec[3][2] + "/" + aCabec[4][2] )
									AAdd(oWFCanF:oHTML:ValByName('xm.cEmissao'), DToC(aCabec[6][2]))
									AAdd(oWFCanF:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
									AAdd(oWFCanF:oHTML:ValByName('xm.cErro')   , cErroCan)
									
								EndIf
								
							EndIf
							
							oGOLog:Add("Houve problemas no cancelamento da Nota Fiscal.", 1)
							
						EndIf
						
					EndIf
					
				//End Transaction
				
			Else
				
				AddErroXml("Nota Fiscal de chave " + (_cTab1)->&(_cCmp1 + "_CHAVE") + " não encontrada, é possível que outro processo tenha eliminado a Nota Fiscal ou não foi dada entrada.")
				oGOLog:Add("***Nota Fiscal não encontrada, é possível que outro processo tenha eliminado a Nota Fiscal.", 1)
				
			EndIf
			
			oGOLog:NewLine()
			//oGOLog:Add("-------- Fim da importação do Cancelamento da Nota Fiscal de número: " + AllTrim((_cTab1)->&(_cCmp1 + "_DOC")) + " e série: " + AllTrim((_cTab1)->&(_cCmp1 + "_SERIE")) + IIf(lConfirm, ". Status final: " + IIf((_cTab1)->&(_cCmp1 + "_SIT") == "2", "Importada com sucesso.", "Houve erros. Não importada."), ""))
		
		Else
			
			If !lElimina
				
				oGOLog:Add("Exclusão manual do cancelamento, a exclusão da nota ficará em cargo da rotina seguinte.", 1)
				
				dbSelectArea("SF1")
				SF1->( dbSetOrder(1) )
				
				If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
					
					cCanSit  := "2"
					cErroXML := ""
					
					SetStatusXML("NFE", "5", 1)
					
					oGOLog:Add("Nota Fiscal cancelada com sucesso.", 1)
					
				EndIf
				
			ElseIf !lExcAut
				
				oGOLog:Add("Exclusão marcada para não ocorrer de forma automática. Deverá ser realizada manualmente. Cancelamento ficará pendente.", 1)
				
				If IsInCallStack("U_GOX004")
					
					If File("\workflow\modelos\importador\XML_CANC.htm")
						
						lEnvWFCan  := .T.
						lEnvWFCanF := .T.
						
						AAdd(oWFCan:oHTML:ValByName('xm.cFilial') , cFilAnt)
						AAdd(oWFCan:oHTML:ValByName('xm.cNumero') , (_cTab1)->&(_cCmp1 + "_DOC"))
						AAdd(oWFCan:oHTML:ValByName('xm.cFornece'), (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
						AAdd(oWFCan:oHTML:ValByName('xm.cEmissao'), DToC((_cTab1)->&(_cCmp1 + "_DTEMIS")))
						AAdd(oWFCan:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
						AAdd(oWFCan:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO PENDENTE (Manual) - Documento escriturado no sistema pendente para ser cancelado!")
						
						AAdd(oWFCanF:oHTML:ValByName('xm.cFilial') , cFilAnt)
						AAdd(oWFCanF:oHTML:ValByName('xm.cNumero') , (_cTab1)->&(_cCmp1 + "_DOC"))
						AAdd(oWFCanF:oHTML:ValByName('xm.cFornece'), (_cTab1)->&(_cCmp1 + "_CODEMI") + "/" + (_cTab1)->&(_cCmp1 + "_LOJEMI"))
						AAdd(oWFCanF:oHTML:ValByName('xm.cEmissao'), DToC((_cTab1)->&(_cCmp1 + "_DTEMIS")))
						AAdd(oWFCanF:oHTML:ValByName('xm.cChave')  , (_cTab1)->&(_cCmp1 + "_CHAVE"))
						AAdd(oWFCanF:oHTML:ValByName('xm.cErro')   , "CANCELAMENTO PENDENTE (Manual) - Documento escriturado no sistema pendente para ser cancelado!")
						
					EndIf
					
				EndIf
							
			EndIf
			
		EndIf
		
	EndIf
	
	RestArea(aAreaSF1)
	RestArea(aAreaSZW)
	
Return

/* ####################################################################### *\
|| #                      IMPORTAÇÃO DO ARQUIVO XML                      # ||
\* ####################################################################### */
Static Function ImpXMLNFe(lConfirm)
	
	Local nA
	Local nX
	Local cEst             := Posicione("SA2", 1, xFilial("SA2") + M->&(_cCmp1 + "_CODEMI") + M->&(_cCmp1 + "_LOJEMI"), "A2_EST")
	Local cTipo            := (_cTab1)->&(_cCmp1 + "_TIPOEN")
	Local aCabec           := {}
	Local aItemPC          := {}
	Local aProj            := {}
	Local aResp
	Local lRet             := .T.
	Local aPrj             := {}
	Local lGOPRJ          := ExistBlock("GOPRJ")
	Local nPMSIPC          := GetMv("MV_PMSIPC")
	Local aTesAnt          := {}
	Local cPedTes          := ""
	Local nPosQtde         := 0
	Local lNFCE            := SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 21, 2) == "65"
	Local lNFSe            := (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
	Local lTemPed          := .F.
	
	Local cOrigImpF        := AllTrim(GetNewPar("MV_ZGOORIF", ""))
	Local cOrigImpD        := AllTrim(GetNewPar("MV_ZGOORID", ""))
	
	Local cCondPC          := ""

	Local cVarLot          := AllTrim(GetNewPar("MV_ZGOVLOT", ""))
	Local cVarDtV          := AllTrim(GetNewPar("MV_ZGOVDTV", ""))
	Local cVarDtF          := AllTrim(GetNewPar("MV_ZGOVDTF", ""))
	Local cVarFci          := AllTrim(GetNewPar("MV_ZGOVFCI", ""))
	
	Local lOkLote          := .F.
	
	Private lMsHelpAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private aAdItem
	
	If !VldInfoNfe()
	
		Return .F.
		
	EndIf
	
	// Salva natureza para trazer na próxima tela.
	
	If !Empty(M->&(_cCmp1 + "_NATFIN")) .And. (_cTab1)->&(_cCmp1 + "_TIPO") == "6"
		
		aNatAnt[1] := "6"
		aNatAnt[2] := M->&(_cCmp1 + "_NATFIN")
		
	EndIf
	
	aCabec := {{"F1_DOC"    , (_cTab1)->&(_cCmp1 + "_DOC")                             , Nil, Nil}, ;
	           {"F1_SERIE"  , (_cTab1)->&(_cCmp1 + "_SERIE")                           , Nil, Nil}, ;
	           {"F1_FORNECE", M->&(_cCmp1 + "_CODEMI")                                 , Nil, Nil}, ;
	           {"F1_LOJA"   , M->&(_cCmp1 + "_LOJEMI")                                 , Nil, Nil}, ;
	           {"F1_COND"   , M->&(_cCmp1 + "_CONDPG")                                 , Nil, Nil}, ;
	           {"F1_EMISSAO", (_cTab1)->&(_cCmp1 + "_DTEMIS")                          , Nil, Nil}, ;
	           {"F1_DTDIGIT", dDataBase                                                , Nil, Nil}, ;
	           {"F1_EST"    , cEst                                                     , Nil, Nil}, ;
	           {"F1_TIPO"   , cTipo                                                    , Nil, Nil}, ;
	           {"F1_ESPECIE", IIf(lNFCE, cEspNFCe, IIf(lNFSe, cEspNFSe, cEspNFe))      , Nil, Nil}, ;
	           {"F1_FORMUL" , "N"                                                      , Nil, Nil}, ;
	           {"F1_CHVNFE" , (_cTab1)->&(_cCmp1 + "_CHAVE")/*IIF(lNFSe, "", (_cTab1)->&(_cCmp1 + "_CHAVE"))*/           , Nil, Nil}, ;
	           {"F1_VALMERC", nValMerc                                                 , Nil, Nil}, ;
	           {"F1_FRETE"  , nValFrete                                                , Nil, Nil}, ;
	           {"F1_DESPESA", nValDesp                                                 , Nil, Nil}, ;
	           {"F1_DESCONT", nValDesc                                                 , Nil, Nil}, ;
	           {"F1_SEGURO" , nValSeguro                                               , Nil, Nil}, ;
	           {"F1_VALBRUT", (nValMerc - nValDesc + nValSeguro + nValDesp + nValFrete), Nil, Nil}, ;
	           {"E2_NATUREZ", M->&(_cCmp1 + "_NATFIN")                                 , Nil, Nil} ;
	          }
			  
	If !Empty(cOrigImpF) // Origem do Lançamento
		
		AAdd(aCabec, {cOrigImpF, "GOX001", Nil})
		
	EndIf
	
	For nX := 1 To Len(oGetD:aCols)
	
		If lGOPRJ
			
			aPrj := ExecBlock("GOPRJ", .F., .F., {oGetD:aCols, nX})
			
			If ValType(aPrj) == "A" .And. !Empty(aPrj)
			
				AAdd(aProj, aPrj)
				
			EndIf
			
		EndIf
		
		AAdd(aItemPC, {{"D1_ITEM"   , StrZero(nX, 4)                                       , Nil}, ;
		               {"D1_COD"    , IIf(_nPosProdu > 0, oGetD:aCols[nX, _nPosProdu], "") , Nil}, ;
		               {"D1_UM"     , IIf(_nPosUm > 0, Upper(oGetD:aCols[nX, _nPosUm]), ""), Nil}, ;
		               {"D1_QUANT"  , IIf(_nPosQtdNo > 0, oGetD:aCols[nX, _nPosQtdNo], 0)  , Nil}, ;
		               {"D1_VUNIT"  , IIf(_nPosVlUnt > 0, oGetD:aCols[nX, _nPosVlUnt], 0)  , Nil}, ;
		               {"D1_TOTAL"  , IIf(_nPosVlTot > 0, oGetD:aCols[nX, _nPosVlTot], 0)  , Nil}, ;
		               {"D1_TES"    , IIf(_nPosTes > 0, oGetD:aCols[nX, _nPosTes], "")     , Nil}, ;
					   ;//{"D1_TIPO"   , cTipo                                                , Nil}, ;
		               {"D1_SERIE"  , (_cTab1)->&(_cCmp1 + "_SERIE")                       , Nil}, ;
		               {"D1_BASEIPI", IIf(_nPosBsIpi > 0, oGetD:aCols[nX, _nPosBsIpi], 0)  , Nil}, ;
		               {"D1_IPI"    , IIf(_nPosAqIpi > 0, oGetD:aCols[nX, _nPosAqIpi], 0)  , Nil}, ;
		               {"D1_VALIPI" , IIf(_nPosVlIpi > 0, oGetD:aCols[nX, _nPosVlIpi], 0)  , Nil}, ;
		               {"D1_BASEICM", IIf(_nPosBsIcm > 0, oGetD:aCols[nX, _nPosBsIcm], 0)  , Nil}, ;
		               {"D1_PICM"   , IIf(_nPosAqIcm > 0, oGetD:aCols[nX, _nPosAqIcm], 0)  , Nil}, ;
		               {"D1_VALICM" , IIf(_nPosVlIcm > 0, oGetD:aCols[nX, _nPosVlIcm], 0)  , Nil}, ;
		               {"AUTDELETA" , "N"                                                  , Nil}  ;
		              })
				
		cPedTes := ""
		
		If lPreNota .And. _nPosTes
			
			AAdd(aItemPC[nX], {"D1_TESACLA", oGetD:aCols[nX, _nPosTes], Nil})
			
		EndIf
		
		If _nPosClVal > 0 .And. !Empty(oGetD:aCols[nX, _nPosClVal])
		
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], 3)
			aItemPC[nX][3] := {"D1_CLVL", oGetD:aCols[nX, _nPosClVal], Nil}
			
		EndIf
		
		If _nPosItCon > 0 .And. !Empty(oGetD:aCols[nX, _nPosItCon])
		
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], 3)
			aItemPC[nX][3] := {"D1_ITEMCTA", oGetD:aCols[nX, _nPosItCon], Nil}
			
		EndIf
		
		If _nPosCtCus > 0 .And. !Empty(oGetD:aCols[nX, _nPosCtCus])
			
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], 3)
			aItemPC[nX][3] := {"D1_CC", oGetD:aCols[nX, _nPosCtCus], Nil}
			
		EndIf
		
		If _nPosDescX > 0 .And. !Empty(oGetD:aCols[nX, _nPosDescX])
		
			AAdd(aItemPC[nX], {"D1_VALDESC", oGetD:aCols[nX, _nPosDescX], Nil})
			
		EndIf
		
		If _nPosNFOri > 0 .And. !Empty(oGetD:aCols[nX, _nPosNFOri])
			
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], 2)
			aItemPC[nX][2] := {"D1_ITEMORI", oGetD:aCols[nX, _nPosItOri], Nil}
			
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], 2)
			aItemPC[nX][2] := {"D1_SERIORI", oGetD:aCols[nX, _nPosSerOr], Nil}
			
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], 2)
			aItemPC[nX][2] := {"D1_NFORI"  , oGetD:aCols[nX, _nPosNFOri], Nil}
			
		EndIf
		
		/*If _nPosVlFrt > 0
			
			AAdd(aItemPC[nX], {"D1_VALFRE", oGetD:aCols[nX, _nPosVlFrt], Nil})
			
		EndIf*/
		
		If _nPosPedid > 0 .And. !Empty(oGetD:aCols[nX, _nPosPedid])
			
			lTemPed := .T.
			
			nPosQtde := AScan(aItemPC[nX], {|x| AllTrim(x[1]) == "D1_QUANT"})
			
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], nPosQtde)
			aItemPC[nX][nPosQtde] := {"D1_PEDIDO", oGetD:aCols[nX, _nPosPedid], Nil}
			
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], nPosQtde+1)
			aItemPC[nX][nPosQtde+1] := {"D1_ITEMPC", oGetD:aCols[nX, _nPosItePc], Nil}
			
			dbSelectArea("SC7")
			SC7->( dbSetOrder(1) )
			
			If SC7->( dbSeek(xFilial("SC7") + oGetD:aCols[nX,_nPosPedid] + oGetD:aCols[nX,_nPosItePc]) )
				
				If Empty(cCondPC)
					
					cCondPC := SC7->C7_COND

					If !Empty(cCondPC)

						// Atualizar condição de pagamento
						aCabec[5][2] := cCondPC

					EndIf

				EndIf
				
				If !Empty(SC7->C7_OP)
					
					AAdd(aItemPC[nX], {"D1_OP", SC7->C7_OP, Nil})
					
				EndIf
				
				If !Empty(SC7->C7_LOCAL)
					
					AAdd(aItemPC[nX], {})
					AIns(aItemPC[nX], nPosQtde)
					aItemPC[nX][nPosQtde] := {"D1_LOCAL", SC7->C7_LOCAL, Nil}
					
				EndIf
				
			EndIf
			
			/*###################*\
			||# CÓDIGO MOLDTOOL #||
			\*###################*/
			If SM0->M0_CGC == "04120251000160"
			
				dbSelectArea("SC7")
				SC7->( dbSetOrder(1) )
				
				If SC7->( dbSeek(xFilial("SC7") + oGetD:aCols[nX,_nPosPedid] + oGetD:aCols[nX,_nPosItePc]) )
				
					dbSelectArea("SF4")
					SF4->( dbSetOrder(1) )
					
					If SF4->( dbSeek(xFilial("SF4") + SC7->C7_TES) )
					
						cPedTes := SF4->F4_PODER3
						AAdd(aTesAnt, SC7->C7_TES)
						
					Else
					
						AAdd(aTesAnt, "   ")
						
					EndIf
					
					If _nPosTes > 0 .And. SF4->( dbSeek(xFilial("SF4") + oGetD:aCols[nX,_nPosTes]) )
					
						If cPedTes == "D" .And. SF4->F4_PODER3 != "D"
						
							RecLock("SC7", .F.)
							
								SC7->C7_TES := oGetD:aCols[nX,_nPosTes]
								
							SC7->( MsUnlock() )
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			/*################*\
			||# FIM MOLDTOOL #||
			\*################*/
			
		EndIf
		
		If _nPosConta > 0 .And. !Empty(oGetD:aCols[nX, _nPosConta])
			
			AAdd(aItemPC[nX], {})
			AIns(aItemPC[nX], 3)
			aItemPC[nX][3] := {"D1_CONTA", oGetD:aCols[nX, _nPosConta], Nil}
			
		EndIf
		
		If _nPosStTri > 0 .And. U_GO1VLCST(oGetD:aCols[nX, _nPosStTri])
			
			AAdd(aItemPC[nX], {"D1_CLASFIS", oGetD:aCols[nX, _nPosStTri], Nil})
			
		EndIf
		
		If _nPosCSOSN > 0 .And. U_GO1VLCSO(oGetD:aCols[nX, _nPosCSOSN])
			
			AAdd(aItemPC[nX], {"D1_CSOSN", oGetD:aCols[nX, _nPosCSOSN], Nil})
			
		EndIf

		If _nPosVlFrt > 0
			
			AAdd(aItemPC[nX], {"D1_VALFRE", oGetD:aCols[nX, _nPosVlFrt], Nil})
			
		EndIf
		
		If _nPosBsStA > 0

			AAdd(ATail(aItemPC), {"D1_BASNDES", IIf(_nPosBsStA > 0, oGetD:aCols[nX, _nPosBsStA], 0)  , Nil})
			AAdd(ATail(aItemPC), {"D1_ALQNDES", IIf(_nPosPStA > 0, oGetD:aCols[nX, _nPosPStA], 0)  , Nil})
			AAdd(ATail(aItemPC), {"D1_ICMNDES", IIf(_nPosVlStA > 0, oGetD:aCols[nX, _nPosVlStA], 0)  , Nil})
			
			AAdd(ATail(aItemPC), {"D1_VALANTI", IIf(_nPosVlAnt > 0, oGetD:aCols[nX, _nPosVlAnt], 0)  , Nil})

		EndIf

		If _nPosBsISt > 0

			AAdd(ATail(aItemPC), {"D1_BRICMS", IIf(_nPosBsISt > 0, oGetD:aCols[nX, _nPosBsISt], 0)  , Nil})
			AAdd(ATail(aItemPC), {"D1_ALIQSOL", IIf(_nPosPIcSt  > 0, oGetD:aCols[nX, _nPosPIcSt], 0)  , Nil})
			AAdd(ATail(aItemPC), {"D1_ICMSRET", IIf(_nPosVlISt > 0, oGetD:aCols[nX, _nPosVlISt], 0)  , Nil})

		EndIf
		
		If !Empty(cOrigImpD) // Origem do Lançamento
			
			AAdd(ATail(aItemPC), {cOrigImpD, "GOX001", Nil})
			
		EndIf
		
		// Lotes e Afins
	
		If _nPosLote > 0 .And. !Empty(cVarLot)
			
			AAdd(aItemPC[nX], {cVarLot, oGetD:aCols[nX, _nPosLote], Nil})
			
			If GetNewPar("MV_ZGOXVLL", .T.)
				
				dbSelectArea("SB1")
				SB1->( dbSetOrder(1) )
				
				If SB1->( dbSeek(xFilial("SB1") + PadR(oGetD:aCols[nX, _nPosProdu], TamSX3("A5_PRODUTO")[1])) )
					
					If AllTrim(SB1->B1_GRUPO) + ";" $ GetNewPar("MV_ZGOGRVL", "") .And. Empty(oGetD:aCols[nX, _nPosLote]) .And. !lOkLote
						
						If Aviso("Lote", "Existe itens sem lote informado no XML. Deseja continuar?", {"Confirmar", "Cancelar"}, 2) == 1
							
							lOkLote := .T.
							
						Else
							
							Return .F.
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
		If _nPosDtFab > 0 .And. !Empty(cVarDtF)
			
			AAdd(aItemPC[nX], {cVarDtF, oGetD:aCols[nX, _nPosDtFab], Nil})
			
		EndIf
		
		If _nPosDtVld > 0 .And. !Empty(cVarDtV)
			
			AAdd(aItemPC[nX], {cVarDtV, oGetD:aCols[nX, _nPosDtVld], Nil})
			
		EndIf
		
		If _nPosFciCd > 0 .And. !Empty(cVarFci)
			
			AAdd(aItemPC[nX], {cVarFci, oGetD:aCols[nX, _nPosFciCd], Nil})
			
		EndIf
		
		// ---------------
		
		If ExistBlock("GT1ITEM")
		
			aAdItem := ExecBlock("GT1ITEM", .F., .F., aClone(oGetD:aCols[nX]))
			
			If ValType(aAdItem) == "A"
			
				For nA := 1 To Len(aAdItem)
				
					AAdd(aItemPC[nX], aAdItem[nA])
					
				Next nA
				
			EndIf
			
		EndIf
		
		If GetNewPar("MV_ZGOTSIN", .F.) .And. !lPreNota
			
			// Realiza a amarração de TES Inteligente
			
			U_GOXTESAm(oGetD:aCols[nX, _nPosProdu], M->&(_cCmp1 + "_CODEMI"), M->&(_cCmp1 + "_LOJEMI"), oGetD:aCols[nX,_nPosTes])
			
		EndIf
		
		//Amarração do Produto X Fornecedor
		dbSelectArea("SA5")
		SA5->( dbSetOrder(2) )

		If !SA5->( dbSeek(xFilial("SA5") + PadR(oGetD:aCols[nX, _nPosProdu], TamSX3("A5_PRODUTO")[1]) + M->&(_cCmp1 + "_CODEMI") + M->&(_cCmp1 + "_LOJEMI")) )

			RecLock("SA5", .T.)
				SA5->A5_FILIAL  := xFilial("SA5")
				SA5->A5_PRODUTO := PadR(oGetD:aCols[nX, _nPosProdu], TamSX3("A5_PRODUTO")[1])
				SA5->A5_FORNECE := PadR(M->&(_cCmp1 + "_CODEMI"), TamSX3("A5_FORNECE")[1])
				SA5->A5_LOJA    := PadR(M->&(_cCmp1 + "_LOJEMI"), TamSX3("A5_LOJA")[1])
				SA5->A5_CODPRF  := SubStr(oGetD:aCols[nX, _nPosItXml], 1, At(" - [", oGetD:aCols[nX, _nPosItXml]) - 1)
				SA5->A5_NOMPROD := SubStr(oGetD:aCols[nX, _nPosItXml], At(" - [", oGetD:aCols[nX, _nPosItXml]) + 4)
				SA5->A5_NOMEFor := Posicione("SA2", 1, xFilial("SA2") + PadR(M->&(_cCmp1 + "_CODEMI"), TamSX3("A5_FORNECE")[1]) + PadR(M->&(_cCmp1 + "_LOJEMI"), TamSX3("A5_LOJA")[1]), "A2_NOME")
			SA5->( MsUnlock() )
			
		Else
			
			RecLock("SA5", .F.)
				SA5->A5_CODPRF  := SubStr(oGetD:aCols[nX, _nPosItXml], 1, At(" - [", oGetD:aCols[nX, _nPosItXml]) - 1)
				SA5->A5_NOMPROD := SubStr(oGetD:aCols[nX, _nPosItXml], At(" - [", oGetD:aCols[nX, _nPosItXml]) + 4)
			SA5->( MsUnlock() )
			
		EndIf
		
		// Amarrar a conversão de unidade de medida.
		
		If GetNewPar("MV_ZGOAMUN", .T.)
			
			UMAmarra(oGetD:aCols[nX, _nPosProdu], oGetD:aCols[nX, _nPosUmFor], oGetD:aCols[nX, _nPosUm], M->&(_cCmp1 + "_CODEMI"), M->&(_cCmp1 + "_LOJEMI"), oGetD:aCols[nX, _nPosQtdFr], oGetD:aCols[nX, _nPosQtdNo])
			
		EndIf
		
		If GetNewPar("MV_XGTNCM", .F.) .And. _nPosNcm > 0 .And. !Empty(oGetD:aCols[nX, _nPosNcm])
			
			dbSelectArea("SB1")
			SB1->( dbSetOrder(1) )
			
			If SB1->( dbSeek(xFilial("SB1") + PadR(oGetD:aCols[nX, _nPosProdu], TamSX3("A5_PRODUTO")[1])) )
				
				RecLock("SB1", .F.)
				
					SB1->B1_POSIPI := StrTran(oGetD:aCols[nX, _nPosNcm], ".", "")
					
				SB1->( MsUnlock() )
				
			EndIf
			
		EndIf
		
		oGOLog:NewLine()
		
	Next nX
	
	If !lTemPed
		
		AAdd(aCabec, {"F1_TPFRETE", /*If(nValFrete > 0,*/ cTpFrete/*, " ")*/, Nil, Nil})
		
	EndIf
	
	//Begin Transaction
	
		If lGOPRJ
			
			PutMv("MV_PMSIPC", "2")
			
		EndIf
		
		lMsErroAuto := .F.
		
		If lPreNota
			
			MsAguarde({|| MsExecAuto({|x, y, z, w, k| MATA140(x, y, z, w, k)}, aCabec, aItemPC, 3, .F., 1)}, "Pré-nota de entrada", "Importando Nota Fiscal Normal como Pré-nota...")
			
		Else
			
			MsExecAuto({|x, y, z, w, k| Mata103(x, y, z, w, , k)}, aCabec, aItemPC, 3, .T./*lConfere*/, aProj)
			
			/*###################*\
			||# CÓDIGO MOLDTOOL #||
			\*###################*/
			If SM0->M0_CGC == "04120251000160"
			
				If Len(aTesAnt) > 0
				
					For nX := 1 To Len(oGetD:aCols)
					
						If !Empty(oGetD:aCols[nX,_nPosPedid])
						
							dbSelectArea("SC7")
							SC7->( dbSetOrder(1) )
							
							If SC7->( dbSeek(xFilial("SC7") + oGetD:aCols[nX,_nPosPedid] + oGetD:aCols[nX,_nPosItePc]) )
								
								dbSelectArea("SF4")
								SF4->( dbSetOrder(1) )
								
								If SF4->( dbSeek(xFilial("SF4") + SC7->C7_TES) )
								
									RecLock("SC7", .F.)
									
										SC7->C7_TES := aTesAnt[nX]
										
									SC7->( MsUnlock() )
									
								EndIf
								
							EndIf
							
						EndIf
						
					Next nX
					
				EndIf
				
			EndIf
			/*################*\
			||# FIM MOLDTOOL #||
			\*################*/
			
		EndIf
		
		If lGOPRJ
		
			PutMv("MV_PMSIPC", nPMSIPC)
			
		EndIf
		
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		
		If !lMsErroAuto .And. !SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
		
			lConfirm := .F.
			lRet     := .F.
			
		ElseIf lMsErroAuto
		
			//DisarmTransaction()
			
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")  := "3"
				(_cTab1)->&(_cCmp1 + "_ERRO") := MontaErro(GetAutoGrLog())
				
			(_cTab1)->( MsUnlock() )
			
			ExibeErro()
			oGOLog:Add("Houve problemas na inclusão da Nota Fiscal.", 1)
			oGOLog:Add("Erro: " + (_cTab1)->&(_cCmp1 + "_ERRO"), 1)
			lRet := .F.
			
		Else
			
			RecLock("SF1")
				
				SF1->&(cOrigImpF) := "GOX001"
				
			SF1->( MSUnlock() )
			
			dbSelectArea("SD1")
			SD1->( dbSetOrder(1) )
			SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
			
			While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
					SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
				
				RecLock("SD1")
					
					SD1->&(cOrigImpD) := "GOX001"
					
				SD1->( MSUnlock() )
				
				SD1->( dbSkip() )
					
			EndDo
			
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				If SF1->F1_STATUS == "B"
					(_cTab1)->&(_cCmp1 + "_ERRO") := "Nota Bloqueada. Verificar divergências com o Pedido de compras, como Valor Unitário, etc."
				Else
					(_cTab1)->&(_cCmp1 + "_ERRO") := ""
				EndIf
				(_cTab1)->&(_cCmp1 + "_ESPECI") := cEspNFe
				//(_cTab1)->&(_cCmp1 + "_TIPOEN") := cTipo
				(_cTab1)->&(_cCmp1 + "_NATFIN") := M->&(_cCmp1 + "_NATFIN")
				(_cTab1)->&(_cCmp1 + "_CONDPG") := M->&(_cCmp1 + "_CONDPG")
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := dDataBase
				(_cTab1)->&(_cCmp1 + "_HRIMP")  := Time()
				(_cTab1)->&(_cCmp1 + "_USUIMP") := cUserName
				(_cTab1)->&(_cCmp1 + "_LIBALM") := IIf(lPreNota, "1", "2")
				
			(_cTab1)->( MsUnlock() )
			
			// Quando é Pré-Nota, o MATA140 não salva a Chave
			If lPreNota
				
				RecLock("SF1", .F.)
					
					SF1->F1_CHVNFE := (_cTab1)->&(_cCmp1 + "_CHAVE")
					
				SF1->( MsUnlock() )
				
				// Gravar os Pedidos atrelados à Pré-nota
				
				If (_cTab8)->( FieldPos(_cCmp8 + "_NUMPED") ) > 0
					
					GrvPedXML()
					
				EndIf
				
			EndIf
			
			oGOLog:Add("Nota Fiscal incluída com sucesso.", 1)
			oGOLog:NewLine()
			
			//Aviso("Aviso", "Importação realizada com sucesso!", {"Ok"}, 2)
			
		EndIf
		
	//End Transaction

Return lRet

Static Function ConsPed(lAgrItens)
	
	Local oDlgPedido
	Local cBuscaPed   := Space(TamSX3("C7_NUM")[1])
	
	If lAgrItens
		
		Private aHeaderPd := {"", "Pedido", "Item", "Data Emissão", "Produto", "UM", "Quantidade", "Preço Unitário", "Descrição"}
		
	Else
		
		Private aHeaderPd := {"", "" , "Item", "Desc Item", "", "Pedido", "Item", "Data Emissão", "Produto", "UM", "Quantidade", "Preço Unitário", "Total", "Descrição"}
		
	EndIf
	
	Private oListPed
	Private aPedidos  := {}
	Private oLayerPed
	Private aSeqPed   := {}
	Private cAddPed   := ""
	Private oOk       := LoadBitmap(GetResources(), "LBOK")
	Private oNo       := LoadBitmap(GetResources(), "LBNO")
	Private oUp       := LoadBitmap(GetResources(), "FW_ARROW_TOP")
	Private oDown     := LoadBitmap(GetResources(), "FW_ARROW_DOWN")
	
	Private cPrxProd  := PadR(oGetD:aCols[1][_nPosItXml], 200)
	Private oPrxProd
	
	Default lAgrItens := .F.
	
	AtualizaPed(, lAgrItens, .F.)
	
	If Len(aPedidos) > 0
	
		DEFINE MSDIALOG oDlgPedido FROM aSize[7],0 To aSize[6]/1.2,aSize[5]/1.1 TITLE 'Consulta de Pedidos de Compra' COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
			
			oDlgPedido:lEscClose := .F.
			oLayerPed := FWLayer():New()
			oLayerPed:Init(oDlgPedido, .F.)
				
				If !lAgrItens .And. .F.
				
					oLayerPed:AddLine('TOP', 10, .F.)
						
						oLayerPed:AddCollumn('COL_TOP', 100, .T., 'TOP')
							
							oPanelTop := tPanel():New(0, 0, "", oLayerPed:GetColPanel('COL_TOP', 'TOP'), , , , , RGB(239, 243, 247), 000, 015)
							oPanelTop:Align	:= CONTROL_ALIGN_ALLCLIENT
							
							oPrxProd := TGet():New(02, 02, {|u| IF(Pcount() > 0, cPrxProd := u, cPrxProd )}, oPanelTop, 300, 12, '@',,,,,,, .T.,,,,,,, .T.,,, "cPrxProd",,,,,,, "Próximo produto")
							oPrxProd:cToolTip := "O produto exibido será o relacionado ao próximo produto marcado."
				
				EndIf
				
				oLayerPed:AddLine('CENTER', IIf(lAgrItens .Or. .T., 92, 82), .F.)
				
					oLayerPed:AddCollumn('COL_CENTER', 100, .T., 'CENTER')
					
						oLayerPed:AddWindow('COL_CENTER', 'WIN_CENTER', "Fornecedor: " + cDescFor, 100, .F., .T., , 'CENTER', )
							
							oListPed := TWBrowse():New(40, 05, 204, 140, , aHeaderPd, , oLayerPed:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'), , , , , , , , , , , , .F., , .T., , .F., , , )
							oListPed:bLDblClick := {|x, nCol| IIf(nCol == 5, setPedUp(), IIf(nCol == 2, setPedDown(), ClickSelPed(lAgrItens)))}
							oListPed:SetArray(aPedidos)
							oListPed:bLine := &('{|| {	IIf(aPedidos[oListPed:nAt, 1], oOk, oNo), ' + IIf(lAgrItens, '', ;
														   '"-", ' + ;
														   'aPedidos[oListPed:nAt, 13], ' + ;
														   'aPedidos[oListPed:nAt, 14], ' + ;
														   '"+", ') + ;
							                               'aPedidos[oListPed:nAt, 2], ' + ;
							                               'aPedidos[oListPed:nAt, 3], ' + ;
							                               'aPedidos[oListPed:nAt, 4], ' + ;
							                               'aPedidos[oListPed:nAt,5]' + cAddPed + ',' +;
							                               'aPedidos[oListPed:nAt,6],' +;
							                               'PADL(Transform(aPedidos[oListPed:nAt,7],"@E 999,999.9999"),20,""),' +;
							                               'PADL(Transform(aPedidos[oListPed:nAt,9],"@E 999,999.9999"),20,""),' +;
							                               'PADL(Transform(aPedidos[oListPed:nAt,15],"@E 999,999,999.9999"),20,""),' +;
							                               'aPedidos[oListPed:nAt,8]}}')
							                               
							oListPed:Align := CONTROL_ALIGN_ALLCLIENT
							
				oLayerPed:AddLine('BOTTOM', 8, .F.)
				
					oLayerPed:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')
					
						oPanelBot := tPanel():New(0, 0, "", oLayerPed:GetColPanel('COL_BOTTOM', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
						oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
						
						oQuit := THButton():New(0, 0, "Cancelar", oPanelBot, {|| oDlgPedido:End()}, , , )
						oQuit:nWidth  := 100
						oQuit:nHeight := 10
						oQuit:Align   := CONTROL_ALIGN_RIGHT
						oQuit:SetColor(RGB(002, 070, 112), )
						
						oSel := THButton():New(0, 0, "Selecionar", oPanelBot, {|| IIf(lAgrItens, IIf(AgrItens(), oDlgPedido:End(), .F.), IIf(ValPed(), oDlgPedido:End(), .F.))}, , , )
						oSel:nWidth  := 110
						oSel:nHeight := 10
						oSel:Align := CONTROL_ALIGN_RIGHT
						oSel:SetColor(RGB(002, 070, 112), )
						
						/// Nota
						oBuscaPed := TSay():New(005, 010, {|| "  Pedido: "}, oPanelBot, , TFont():New('Arial', , -12, , .F.), , , , .T., CLR_BLUE, CLR_WHITE, 025, 007)
						oBuscaPed:Align := CONTROL_ALIGN_LEFT
						
						oBusca    := TGet():New(004, 005, {|u| IF(Pcount() > 0, cBuscaPed := u, cBuscaPed)}, oPanelBot, 050, 010, '@', , , , , , , .T., , , {|| .T.}, , , , , , , "cBuscaPed", , , , )
						oBusca:Align := CONTROL_ALIGN_LEFT
						
						oBuscaBtn := tButton():New(004, 005, 'Filtrar', oPanelBot, {|| AtualizaPed(cBuscaPed, lAgrItens)}, 25, 10, , , , .T.)
						oBuscaBtn:Align := CONTROL_ALIGN_LEFT
						
		ACTIVATE MSDIALOG oDlgPedido CENTERED 
		
	Else
	
		Aviso("Aviso", "Não foram encontrados Pedidos de Compra para este Fornecedor!", {"Ok"}, 2)
		
	EndIf
	
Return .T.

Static Function AtualizaPed(cPed, lAgrItens, lRefresh)
	
	Local lFilPed := .F.
	Local lMonta  := .T.
	Local nCmp    := 1
	Local nI
	Local aAddCmp := ""
	Local nSeq
	
	Local aFor
	
	Default cPed      := ""
	Default lAgrItens := .F.
	Default lRefresh  := .T.
	
	aFor := U_GOX1ALLF(Posicione("SA2", 1, xFilial("SA2") + cFornece + cLoja, "A2_CGC"))
	
	dbSelectArea("SC7")
	SC7->( dbSetOrder(3) )
	
	If !Empty(cPed)
		
		For nI := 1 To Len(aFor)
			
			If SC7->( dbSeek(xFilial("SC7") + aFor[nI][1] + aFor[nI][2] + cPed) )
				
				lFilPed := .T.
				
			EndIf
			
		Next nI
		
		If !lFilPed
			
			MsgInfo("Pedido não encontrado para o Fornecedor. Será retornado todos os pedidos de compra.")
			
		EndIf
		
	EndIf
	
	If lRefresh
		
		FreeVet(aPedidos)
		aPedidos := {}
		
	EndIf
	
	For nSeq := 1 To Len(aFor)
		
		// Antes não validava a loja, mas como o produto padrão valida, foi adicionada a validação novamente.
		If SC7->( dbSeek(xFilial("SC7") + aFor[nSeq][1] + aFor[nSeq][2] + IIf(lFilPed, cPed, "")) )
		
			While !SC7->( Eof() ) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_FORNECE == aFor[nSeq][1] .And. SC7->C7_LOJA == aFor[nSeq][2] .And. IIf(lFilPed, SC7->C7_NUM == cPed, .T.)
				
				If SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA > 0 .And. Empty(SC7->C7_RESIDUO) .And. SC7->C7_TPOP <> 'P' .And. SC7->C7_CONAPRO # "B"
					
					AAdd(aPedidos, {.F.,                            ;  // 1
					                SC7->C7_NUM,                    ;  // 2
					                SC7->C7_ITEM,                   ;  // 3
					                SC7->C7_EMISSAO,                ;  // 4
					                SC7->C7_PRODUTO,                ;  // 5
					                SC7->C7_UM,                     ;  // 6
					                (SC7->C7_QUANT - SC7->C7_QUJE), ;  // 7
					                SC7->C7_DESCRI,                 ;  // 8
					                SC7->C7_PRECO,                  ;  // 9
					                SC7->C7_TES,                    ;  // 10
					                SC7->C7_PICM,                   ;  // 11
					                SC7->C7_IPI,                    ;  // 12
					                0,                              ;  // 13
					                Space(50),                      ;  // 14
					                SC7->C7_TOTAL})                    // 15
					
					If ExistBlock("GOPED")
					
						aAddCmp := ExecBlock("GOPED", .F., .F.)
						
						If ValType(aAddCmp) == "A" .And. !Empty(aAddCmp)
						
							For nCmp := 1 To Len(aAddCmp)
								
								If lMonta
								
									If (nCmp+5) > Len(aHeaderPd)
									
										AAdd(aHeaderPd, aAddCmp[nCmp][1])
										
									Else
									
										AIns(aHeaderPd, nCmp+5)
										aHeaderPd[nCmp+5] := aAddCmp[nCmp][1]
										
									EndIf
									
								EndIf
								
								AAdd(aTail(aPedidos), aAddCmp[nCmp][2])
								
								If lMonta
								
									cAddPed += ", aPedidos[oListPed:nAt," + cValToChar(Len(aTail(aPedidos))) + "]"
									
								EndIf
								
							Next nCmp
							
							lMonta := .F.
							
						EndIf
						
					EndIf
					
				EndIf
				
				SC7->( dbSkip() )
				
			EndDo
			
			For nI := 1 To (nCmp-1)
			
				AAdd(aHeaderPd, {"UM", "Quantidade", "Preço Unitário", "Descrição"}[nI])
				
			Next nI
			
		EndIf
		
	Next nSeq
	
	FreeVet(aSeqPed)
	aSeqPed := {}
	
	// Para contador dos itens selecionados
	
	For nSeq := 1 To Len(aPedidos)
		
		AAdd(aSeqPed, nSeq)
		
	Next nSeq
	
	//----------
	
	If lRefresh
		
		oListPed:SetArray(aPedidos)
		oListPed:bLine := &('{|| {	IIf(aPedidos[oListPed:nAt, 1], oOk, oNo), ' + IIf(lAgrItens, '', ;
						   '"-", ' + ;
						   'aPedidos[oListPed:nAt, 13], ' + ;
						   'aPedidos[oListPed:nAt, 14], ' + ;
						   '"+", ') + ;
                           'aPedidos[oListPed:nAt, 2], ' + ;
                           'aPedidos[oListPed:nAt, 3], ' + ;
                           'aPedidos[oListPed:nAt, 4], ' + ;
                           'aPedidos[oListPed:nAt,5]' + cAddPed + ',' +;
                           'aPedidos[oListPed:nAt,6],' +;
                           'PADL(Transform(aPedidos[oListPed:nAt,7],"@E 999,999.9999"),20,""),' +;
                           'PADL(Transform(aPedidos[oListPed:nAt,9],"@E 999,999.9999"),20,""),' +;
                           'PADL(Transform(aPedidos[oListPed:nAt,15],"@E 999,999,999.9999"),20,""),' +;
                           'aPedidos[oListPed:nAt,8]}}')
		oListPed:Refresh()
		
	EndIf
	
Return

Static Function setPedUp()
	
	Local nI
	Local nAt  := oListPed:nAt
	Local nAtu := aPedidos[oListPed:nAt, 13]
	Local nTot := Len(oGetD:aCols)
	Local nToS := 0
	Local lMov := .F.
	
	aEval(aPedidos, {|x| IIf(x[1], nToS++, )})
	
	nTot := Max(nTot, nToS)
	
	If !aPedidos[oListPed:nAt, 1]
		
		Return
		
	EndIf
	
	If nAtu + 1 > nTot + 1
		
		MsgAlert("O item já será adicionado, não se pode subir mais o nível do item.")
		Return
		
	EndIf
	
	lMov := AScan(aPedidos, {|x| x[13] == (aPedidos[oListPed:nAt, 13] + 1)}) > 0
	
	DelSeqPed(aPedidos[oListPed:nAt, 13])
	
	aPedidos[oListPed:nAt, 13] := nAtu + 1
	
	If aPedidos[oListPed:nAt, 13] > nTot
		
		aPedidos[oListPed:nAt, 14] := "ITEM ADICIONADO" 
		
	Else
		
		aPedidos[oListPed:nAt, 14] := oGetD:aCols[aPedidos[oListPed:nAt, 13]][1]
		
	EndIf
	
	If lMov
		
		For nI := 1 To Len(aPedidos)
			
			If nI # nAt .And. aPedidos[nI, 1]
				
				If aPedidos[nI, 13] >= aPedidos[oListPed:nAt, 13]
					
					If aPedidos[nI, 13] + 1 > nTot + 1
						
						aPedidos[nI, 13] := UsaSeqPed(.T.)
						
					Else
						
						aPedidos[nI, 13]++
						
					EndIf
					
					If aPedidos[nI, 13] > nTot
						
						aPedidos[nI, 14] := "ITEM ADICIONADO" 
						
					Else
						
						aPedidos[nI, 14] := oGetD:aCols[aPedidos[nI, 13]][1]
						
					EndIf
					
				EndIf 
				
			EndIf
			
		Next nI
		
	EndIf
	
	oListPed:Refresh()
	
Return

Static Function setPedDown()
	
	Local nI
	Local nAt  := oListPed:nAt
	Local nAtu := aPedidos[oListPed:nAt, 13]
	 
	If !aPedidos[oListPed:nAt, 1]
		
		Return
		
	EndIf
	
	If nAtu == 1
		
		MsgAlert("A posição não pode ser 0.")
		
		Return
		
	EndIf
	
	DelSeqPed(aPedidos[oListPed:nAt, 13])
	
	aPedidos[oListPed:nAt, 13] := nAtu - 1
	
	For nI := 1 To Len(aPedidos)
		
		If nI # nAt .And. aPedidos[nI, 1]
			
			If aPedidos[nI, 13] == aPedidos[oListPed:nAt, 13]
				
				aPedidos[nI, 13] := UsaSeqPed(.T.)
				
			EndIf 
			
		EndIf
		
	Next nI
	
	oListPed:Refresh()
	
Return

Static Function UsaSeqPed(lLast)
	
	Local nPos
	
	Default lLast := .F.
	
	nPos := IIf(lLast, ATail(aSeqPed), aSeqPed[1])
	
	ADel(aSeqPed, IIf(lLast, Len(aSeqPed), 1))
	
	ASize(aSeqPed, Len(aSeqPed) - 1)
	
Return nPos

Static Function DelSeqPed(nPos)
	
	AAdd(aSeqPed, nPos)
	
	If Len(aSeqPed) == Len(aPedidos)
	
		aSort(aSeqPed)
		
	EndIf
	
Return

/* ####################################################################### *\
|| #           FUNÇÃO AO SELECIONAR PEDIDO DE COMPRA VIA TELA            # ||
\* ####################################################################### */
Static Function ClickSelPed(lAgrItens)
	
	aPedidos[oListPed:nAt, 1] := !(aPedidos[oListPed:nAt, 1])
	
	If aPedidos[oListPed:nAt, 1] //Item do pedido foi selecionado
		
		aPedidos[oListPed:nAt, 13] := UsaSeqPed()
		
		If aPedidos[oListPed:nAt, 13] > Len(oGetD:aCols)
			
			aPedidos[oListPed:nAt, 14] := "ITEM ADICIONADO" 
			
		Else
			
			aPedidos[oListPed:nAt, 14] := oGetD:aCols[aPedidos[oListPed:nAt, 13]][1]
			
		EndIf
		
	Else //Item do pedido foi desmarcado
		
		DelSeqPed(aPedidos[oListPed:nAt, 13])
		
		aPedidos[oListPed:nAt, 13] := 0
		
		aPedidos[oListPed:nAt, 14] := Space(50)
		
	EndIf
	
	/*If !lAgrItens
	
		If (nSeqPed + 1) > Len(oGetD:aCols)
				
			cPrxProd := " + ITEM SERÁ ADICIONADO "
			
		Else
			
			cPrxProd := oGetD:aCols[nSeqPed+1][_nPosItXml]
			
		EndIf
		
		//oPrxProd:Refresh()
		
	EndIf*/
		
	oListPed:Refresh()
	
Return

/* ####################################################################### *\
|| #           VALIDA A SELEÇÃO DE PEDIDOS DE COMPRA VIA TELA            # ||
\* ####################################################################### */
Static Function ValPed()

	Local aConv   := {}
	Local lPassou := .F.
	Local nCont   := 0
	Local nQuant  := 0
	Local nVal    := 0
	Local nX
	
	For nX := 1 To Len(aPedidos)
	
		If aPedidos[nX, 1] == .T.
		
			nCont++
			
		EndIf
		
	Next nX
	
	If nCont == 0
	
		Aviso("Aviso", "Não houve seleção de itens do Pedido!", {"Ok"}, 2)
		Return .F.
		
	EndIf
	
	If nCont > Len(oGetD:aCols)
	
		If Aviso("Aviso", "Quantidade de itens selecionados difere da quantidade de itens da nota!" + CHR(13) + CHR(10) + ;
		         "Deseja adicionar mais itens à Nota?", {"Sim", "Não"}, 3) == 2
			
			Return .F.
			
		EndIf
		
	EndIf
	
	nCont := 1
	aSort(aPedidos, , , {|x, y| x[13] < y[13]})
	
	For nX := 1 To Len(aPedidos)
		
		lPassou := .F.
		
		If aPedidos[nX, 1]
			
			nCont := aPedidos[nX, 13]
			
			lPassou := .T.
			
			// O número de itens do Pedido é maior que o número de itens da Nota
			// Adiciona um item extra na tela
			If nCont > Len(oGetD:aCols)
			
				AAdd(oGetD:aCols, Array(nUsado + 1))
				ATail(oGetD:aCols)[1]     := "ITEM ADICIONADO"
				ATail(ATail(oGetD:aCols)) := .F.
				
				// Obrigatório passar estes campos em branco para não dar erro.
				If _nPosCtCus > 0
				
					oGetD:aCols[nCont, _nPosCtCus] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_CC") 
					
				EndIf
				
				If _nPosItCon > 0
				
					oGetD:aCols[nCont, _nPosItCon] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_ITEMCTA")
					
				EndIf
				
				If _nPosClVal > 0
				
					oGetD:aCols[nCont, _nPosClVal] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_CLVL")
					
				EndIf
				
				If _nPosVlTot > 0
				
					ATail(oGetD:aCols)[_nPosVlTot] := aPedidos[nX, 15]
					
				EndIf
				
				/*If _nPosConta > 0
					
					ATail(oGetD:aCols)[_nPosConta] := Posicione("SB1", 1, xFilial("SB1") + aPedidos[nX, 5], "B1_CONTA")
					
				EndIf*/
				
				If _nPosConta > 0
					
					oGetD:aCols[nCont, _nPosConta] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_CONTA") 
					
				EndIf
				
				If _nPosDescX > 0
					
					ATail(oGetD:aCols)[_nPosDescX] := 0
					
				EndIf
				
				If _nPosVlFrt > 0
					
					ATail(oGetD:aCols)[_nPosVlFrt] := 0
					
				EndIf
				
				nQuant := aPedidos[nX, 7]
				nVal   := aPedidos[nX, 9]
				
			// Só valida itens já existentes na tela
			Else
			
				If _nPosUmFor > 0 .And. !Empty(oGetD:aCols[nCont, _nPosUmFor]) .And. oGetD:aCols[nCont, _nPosUmFor] != aPedidos[nX, 6] .And. lUMConv
				
					// Realiza a conversão de Unidade de Medida por Produto
					//                *Produto         *UM For                         *UM Nosso        *Qtd For
					aConv := ValConUM(aPedidos[nX, 5], oGetD:aCols[nCont, _nPosUmFor], aPedidos[nX, 6], oGetD:aCols[nCont, _nPosQtdFr], M->&(_cCmp1 + "_CODEMI"), M->&(_cCmp1 + "_LOJEMI"))
					
					// Conversão Ocorrida
					If aConv[1]
					
						If aConv[2] # aPedidos[nX, 7]
							
							If Aviso("Aviso", "A quantidade do Pedido de Compra é diferente do que a do Item da Nota!" + CRLF + ;
							   "Qtde. Xml: " + Transform(aConv[2], "@E 999999999.9999") + CRLF + ;
							   "Qtde. Pedido de Compra: " + Transform(aPedidos[nX, 7], "@E 99999999.9999") + CRLF + ;
							   "Deseja manter os valores do XML, ou substituir pelo do pedido?", {"XML", "Pedido"}, 2) == 1
							   	
								nQuant := aConv[2]
								
								If aConv[2] > 0
								
									nVal := Round(oGetD:aCols[nCont, _nPosVlTot] / aConv[2], TamSX3(_cCmp2 + "_VUNIT")[2])
									
									If Abs(nVal - aPedidos[nX, 9]) < 0.01
										
										nVal := aPedidos[nX, 9]
										
									EndIf
									
								EndIf
								
							Else
							
								nQuant := aPedidos[nX, 7]
								nVal   := aPedidos[nX, 9]
								
							EndIf
							
						Else
						
							nQuant := aPedidos[nX, 7]
							nVal   := aPedidos[nX, 9]
							
						EndIf
						
					Else
					
						If Aviso("Unidade de Medida", "A Unidade de Medida do Produto está diferente do arquivo XML!" + CRLF + ;
						         "Un.Medida do arquivo XML: " + Transform(oGetD:aCols[nCont, _nPosQtdFr], "@E 999999999.9999") + " " + oGetD:aCols[nCont, _nPosUmFor] + CRLF + ;
						         "Un.Medida do Produto Informado: " + Transform(aPedidos[nX, 7], "@E 999999999.9999") + " " + aPedidos[nX, 6] + CRLF + ;
						         "Não foi encontrado cadastro de conversão de unidade de medida entre as informada. Deseja manter os valores do XML, ou substituir pelo do pedido?.", {"XML", "Pedido"}, 3) == 2
						
							nQuant := aPedidos[nX, 7]
							nVal   := aPedidos[nX, 9]
							
						Else
						
							nQuant := oGetD:aCols[nCont, _nPosQtdNo]
							nVal   := oGetD:aCols[nCont, _nPosVlUnt]
							
						EndIf
						
					EndIf
					
				Else
				
					If !Empty(oGetD:aCols[nCont, _nPosQtdFr]) .And. oGetD:aCols[nCont, _nPosQtdFr] < aPedidos[nX, 7]
					
						If Aviso("Aviso", "A quantidade do Pedido de Compra é maior do que a do Item da Nota!" + CRLF + ;
						         "Qtde. XML: " + Transform(oGetD:aCols[nCont, _nPosQtdFr], "@E 999999999.9999") + CRLF + ;
								 "Qtde. Pedido de Compra: " + Transform(aPedidos[nX, 7], "@E 99999999.99") + CRLF + ;
								 "Deseja manter os valores do XML, ou substituir pelo do pedido?", {"XML", "Pedido"}, 2) == 1
						
							nQuant := oGetD:aCols[nCont, _nPosQtdNo]
							
						Else
						
							nQuant := aPedidos[nX, 7]
							
						EndIf
						
					Else
					
						nQuant := aPedidos[nX, 7]
						
					EndIf
					
					/*If oGetD:aCols[nCont, _nPosVlUnt] # aPedidos[nX, 9]
					
						If Aviso("Aviso", "O Valor Unitário do Pedido de Compra está diferente do item da Nota!" + CRLF + ;
						         "Valor Unit. Item da Nota:  R$ " + AllTrim(TRANSFORM(oGetD:aCols[nCont, _nPosVlUnt], "@E 999,999,999.99")) + CRLF + ;
								 "Valor Unit. Pedido de Compra:  R$ " + AllTrim(TRANSFORM(aPedidos[nX, 9], "@E 999,999,999.99")) + CRLF + ;
								 "Deseja assumir o valor do pedido de compra?", {"Sim", "Não"}, 2) == 1
						
							nVal := aPedidos[nX, 9]
							
						Else
						
							nVal := oGetD:aCols[nCont, _nPosVlUnt]
							
						EndIf
						
					EndIf*/
					
					nVal := oGetD:aCols[nCont, _nPosVlUnt]  // VALOR DEFAULT
					
				EndIf
				
			EndIf
			
		EndIf
		
		// ALTERA OS DADOS COM AS INFORMAÇÕES VINDAS DO PEDIDO DE COMPRA
		If lPassou
		
			If _nPosPedid > 0
			
				oGetD:aCols[nCont, _nPosPedid] := aPedidos[nX, 2]
				
			EndIf
			
			If _nPosItePc > 0
			
				oGetD:aCols[nCont, _nPosItePc] := aPedidos[nX, 3]
				
			EndIf
			
			If _nPosProdu > 0
			
				oGetD:aCols[nCont, _nPosProdu] := aPedidos[nX, 5]
				
			EndIf
			
			If _nPosDcPrd > 0
			
				oGetD:aCols[nCont, _nPosDcPrd] := IIf(_nPosProdu > 0, Posicione("SB1", 1, xFilial("SB1") + oGetD:aCols[nCont, _nPosProdu], "B1_DESC"), "")
				
			EndIf
			
			If _nPosUm > 0
			
				oGetD:aCols[nCont, _nPosUm] := aPedidos[nX, 6]
				
			EndIf
			
			If _nPosQtdNo > 0
			
				oGetD:aCols[nCont, _nPosQtdNo] := nQuant
				
			EndIf
			
			If _nPosVlUnt > 0
				
				/*If nCont > Len(oGetD:aCols)
					
					oGetD:aCols[nCont, _nPosVlUnt] := Round(aPedidos[nX, 15] / nQuant, TamSX3(_cCmp2 + "_VUNIT")[2])
					
				Else*/
					
					If Abs(nVal - aPedidos[nX, 9]) < 0.01
						
						nVal := aPedidos[nX, 9]
						
					EndIf
					
					oGetD:aCols[nCont, _nPosVlUnt] := Round(oGetD:aCols[nCont, _nPosVlTot] / nQuant, TamSX3(_cCmp2 + "_VUNIT")[2])
					
				//EndIf
				
			EndIf
			
			If _nPosVlTot > 0
				// [TODO] Talvez não precisa, pq já cria lá em cima da função
				If nCont > Len(oGetD:aCols)
					
					oGetD:aCols[nCont, _nPosVlTot] := aPedidos[nX, 15]
					
				EndIf
				
				//oGetD:aCols[nCont, _nPosVlTot] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, oGetD:aCols[nCont, _nPosQtdNo] * oGetD:aCols[nCont, _nPosVlUnt], 0)
				
			EndIf
			
			If _nPosTes > 0
			
				oGetD:aCols[nCont, _nPosTes] := aPedidos[nX, 10]
				
			EndIf
			
			If _nPosCdFis > 0
				
				oGetD:aCols[nCont, _nPosCdFis] := IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + aPedidos[nX, 10], "F4_CF"), 2, 3)
				
			EndIf
			
			If _nPosStTri > 0
				
				oGetD:aCols[nCont, _nPosStTri] := "   "//SubStr(oGetD:aCols[nCont, _nPosStTri], 1, 1) + Posicione("SF4", 1, xFilial("SF4") + aPedidos[nX, 10], "F4_SITTRIB")
				
			EndIf
			
			If _nPosBsIcm > 0
			
				oGetD:aCols[nCont, _nPosBsIcm] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, oGetD:aCols[nCont, _nPosQtdNo] * oGetD:aCols[nCont, _nPosVlUnt], 0)
				
			EndIf
			
			If _nPosAqIcm > 0
			
				oGetD:aCols[nCont, _nPosAqIcm] := aPedidos[nX, 11]
				
			EndIf
			
			If _nPosVlIcm > 0
			
				oGetD:aCols[nCont, _nPosVlIcm] := IIf(_nPosBsIcm > 0 .And. _nPosAqIcm > 0, oGetD:aCols[nCont, _nPosBsIcm] * oGetD:aCols[nCont, _nPosAqIcm] / 100, 0)
				
			EndIf
			
			If _nPosBsIpi > 0
			
				oGetD:aCols[nCont, _nPosBsIpi] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, oGetD:aCols[nCont, _nPosQtdNo] * oGetD:aCols[nCont, _nPosVlUnt], 0)
				
			EndIf
			
			If _nPosAqIpi > 0
			
				oGetD:aCols[nCont, _nPosAqIpi] := aPedidos[nX, 12]
				
			EndIf
			
			If _nPosVlIpi > 0
			
				oGetD:aCols[nCont, _nPosVlIpi] := IIf(_nPosBsIpi > 0 .And. _nPosAqIpi> 0, oGetD:aCols[nCont, _nPosBsIpi] * oGetD:aCols[nCont, _nPosAqIpi] / 100, 0)
				
			EndIf
			
			If _nPosConta > 0
				
				oGetD:aCols[nCont, _nPosConta] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_CONTA") 
				
			EndIf
			
			If _nPosCtCus > 0
			
				oGetD:aCols[nCont, _nPosCtCus] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_CC") 
				
			EndIf
			
			If _nPosItCon > 0
			
				oGetD:aCols[nCont, _nPosItCon] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_ITEMCTA")
				
			EndIf
			
			If _nPosClVal > 0
			
				oGetD:aCols[nCont, _nPosClVal] := Posicione("SC7", 1, xFilial("SC7") + aPedidos[nX, 2] + aPedidos[nX, 3], "C7_CLVL")
				
			EndIf
			
			nCont++
			
		EndIf
		
	Next nX
	
Return .T.

/* ####################################################################### *\
|| #       VALIDA OS PEDIDOS DE COMPRA NO MOMENTO DO CARREGAMENTO        # ||
\* ####################################################################### */
Static Function ValPC()

	Local lPassou
	Local cRaiz
	Loca nX
	
	For nX := 1 To Len(oGetD:aCols)
	
		lPassou := .F.
		
		If _nPosPedid > 0
		
			If !Empty(oGetD:aCols[nX, _nPosPedid]) 
			
				dbSelectArea("SC7")
				SC7->( dbSetOrder(1) )
				
				If !SC7->( dbSeek(xFilial("SC7") + oGetD:aCols[nX, _nPosPedid] + oGetD:aCols[nX, _nPosItePc]) ) .Or. AllTrim(SC7->C7_NUM + SC7->C7_ITEM) # AllTrim(oGetD:aCols[nX, _nPosPedid] + oGetD:aCols[nX, _nPosItePc])  
					
					Aviso("Aviso", "Número do Pedido de Compra informado no XML para o item " + StrZero(nX, 4) + " não foi encontrado no sistema!", {"Ok"}, 2)
					Return .F.
					
				ElseIf SC7->C7_QUJE < SC7->C7_QUANT .And. SC7->C7_ENCER <> "E"
					
					cRaiz := Left(Posicione("SA2", 1, xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, "A2_CGC"), 8)
					
					If cRaiz # Left((_cTab1)->&(_cCmp1 + "_CGCEMI"), 8)
					
						Aviso("Aviso", "Pedido de Compra informado no item " + StrZero(nX, 4) + " não pertence ao fornecedor selecionado!", {"Ok"}, 2)
						Return .F.
						
					ElseIf .T.//.F. .And. Aviso("Aviso", "Foi encontrado um Pedido de Compra informado no item " + StrZero(nX, 4) + "!" + CRLF + ;
							//	 "Deseja importar as informações?", {"Sim", "Não"}, 2) == 1
					
						If _nPosProdu > 0
						
							oGetD:aCols[nX, _nPosProdu] := SC7->C7_PRODUTO
							
						EndIf
						
						If _nPosDcPrd > 0
						
							oGetD:aCols[nX, _nPosDcPrd] := Posicione("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "B1_DESC")
							
						EndIf
						
						If _nPosUm > 0
						
							oGetD:aCols[nX, _nPosUm] := SC7->C7_UM
							
						EndIf
						
						If _nPosTes > 0 .And. !Empty(SC7->C7_TES)
						
							oGetD:aCols[nX, _nPosTes] := SC7->C7_TES
							
							If !Empty(oGetD:aCols[nX, _nPosTes])
							
								If _nPosCdFis > 0
								
									oGetD:aCols[nX, _nPosCdFis] := IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + SC7->C7_TES, "F4_CF"), 2, 3)
									
								EndIf
								
								If _nPosStTri > 0 .And. GetNewPar("MV_ZALTTXM", .F.)
								
									// PEGA A SITUAÇÃO TRIBUTÁRIA DE ACORDO COM A TES
									oGetD:aCols[nX, _nPosStTri] := SubStr(oGetD:aCols[nX, _nPosStTri], 1, 1) + Posicione("SF4", 1, xFilial("SF4") + SC7->C7_TES, "F4_SITTRIB")
									
								EndIf
								
							EndIf
							
						EndIf
						
						If _nPosQtdFr > 0
						
							If (SC7->C7_QUANT-SC7->C7_QUJE)>oGetD:aCols[nX, _nPosQtdNo]
								
								If Aviso("Aviso", "Quantidade do Pedido no item [" + AllTrim(oGetD:aCols[nX, _nPosDcPrd]) + "] está MAIOR que quantidade do arquivo XML!" + CRLF + ;
										 "Qtde. do XML: " + Transform(oGetD:aCols[nX, _nPosQtdNo], "@E 999999999.9999") + " " + oGetD:aCols[nX, _nPosUm] + CRLF + ;
										 "Qtde. Pedido de Compra: " + Transform((SC7->C7_QUANT-SC7->C7_QUJE), "@E 99999999.9999") + " " + oGetD:aCols[nX, _nPosUm] + CRLF + ;
										 "Deseja assumir o valor do Pedido de Compra?", {"XML", "Pedido"}, 2) == 2
									
									lPassou := .T.
									
								EndIf
								
							ElseIf (SC7->C7_QUANT-SC7->C7_QUJE) < oGetD:aCols[nX, _nPosQtdNo]
							
								If Aviso("Aviso", "Quantidade informada no item [" + AllTrim(oGetD:aCols[nX, _nPosDcPrd]) + "] está MENOR que quantidade do arquivo XML!" + CRLF + ;
										 "Qtde. XML: " + Transform(oGetD:aCols[nX, _nPosQtdNo], "@E 999999999.9999") + " " + oGetD:aCols[nX, _nPosUm] + CRLF + ;
										 "Qtde. Pedido de Compra: " + Transform((SC7->C7_QUANT-SC7->C7_QUJE), "@E 99999999.9999") + " " + oGetD:aCols[nX, _nPosUm] + CRLF + ;
										 "Deseja utilizar valores do pedido?", {"XML", "Pedido"}, 2) == 2
										
									lPassou := .T.
									
								EndIf
								
							Endif
							
						EndIf
						
						If lPassou
						
							If _nPosQtdNo > 0
							
								oGetD:aCols[nX, _nPosQtdNo] := (SC7->C7_QUANT-SC7->C7_QUJE)
								
							EndIf
							
							If _nPosVlUnt > 0
								
								oGetD:aCols[nX, _nPosVlUnt] := Round(oGetD:aCols[nX, _nPosVlTot] / oGetD:aCols[nX, _nPosQtdNo], TamSX3(_cCmp2 + "_VUNIT")[2]) //SC7->C7_PRECO
								
							EndIf
							
							/*If _nPosVlTot > 0
							
								oGetD:aCols[nX, _nPosVlTot] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, oGetD:aCols[nX, _nPosQtdNo] * oGetD:aCols[nX, _nPosVlUnt], 0)
								
							EndIf*/
							
							/*If _nPosBsIcm > 0
							
								oGetD:aCols[nX, _nPosBsIcm] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, oGetD:aCols[nX, _nPosQtdNo] * oGetD:aCols[nX, _nPosVlUnt], 0)
								
							EndIf
							
							If _nPosAqIcm > 0
							
								oGetD:aCols[nX, _nPosAqIcm] := SC7->C7_PICM
								
							EndIf
							
							If _nPosVlIcm > 0
							
								oGetD:aCols[nX, _nPosVlIcm] := IIf(_nPosBsIcm > 0 .And. _nPosAqIcm > 0, oGetD:aCols[nX, _nPosBsIcm] * oGetD:aCols[nX, _nPosAqIcm] / 100, 0)
								
							EndIf
							
							If _nPosBsIpi > 0
								
								oGetD:aCols[nX, _nPosBsIpi] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, oGetD:aCols[nX, _nPosQtdNo] * oGetD:aCols[nX, _nPosVlUnt], 0)
								
							EndIf
							
							If _nPosAqIpi > 0
							
								oGetD:aCols[nX, _nPosAqIpi] := SC7->C7_IPI					                                                             
								
							EndIf
							
							If _nPosVlIpi > 0
							
								oGetD:aCols[nX, _nPosVlIpi] := IIf(_nPosBsIpi > 0 .And. _nPosAqIpi > 0, oGetD:aCols[nX, _nPosBsIpi] * oGetD:aCols[nX, _nPosAqIpi] / 100, 0)
								
							EndIf*/
							
						EndIf
						
						oGetD:oBrowse:Refresh()                                                             
						
					EndIf
					
				Else
				
					Aviso("Aviso", "Número do Pedido de Compra informado no item " + StrZero(nX, 2) + " não foi encontrado!", {"Ok"}, 2)
					Return .F.
					
				EndIf
				
			EndIf
			
		EndIf
		
	Next
	
Return .T.

/* ####################################################################### *\
|| #               FUNÇÕES DE VALIDAÇÕES DE CAMPOS DE TELA               # ||
\* ####################################################################### */
User Function GO1PROD()

	Local aConv   := {}
	Local cItePed := GDFieldGet(_cCmp2 + "_ITEMPC", , .T.)
	Local cNcm
	Local cNcmXml
	Local cPedido := GDFieldGet(_cCmp2 + "_PEDIDO", , .T.)
	Local cPicm
	Local cProd   := GDFieldGet(_cCmp2 + "_COD", , .T.)
	Local cTes
	Local cUM
	Local cUMXml
	Local nAI
	Local nAIXml  := IIf((_cTab1)->&(_cCmp1 + "_TIPO") == "6", 0, U_GOXmlIcm(oXml, N)[3])  // PEGA O ICMS DO XML - Posição 4 é o valor
	Local nConv
	
	GdFieldPut(_cCmp2 + "_DSPROD", Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_DESC"))
	cUM := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_UM")
	GdFieldPut(_cCmp2 + "_UM", cUM)
	cTes := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_TE")
	
	If !Empty(cTes) .And. !lPreNota
	
		GdFieldPut(_cCmp2 + "_TES", cTes)
		GdFieldPut(_cCmp2 + "_CF", IIf(GETMV("MV_ESTADO") == IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "N", cEstado, M->&(_cCmp1 + "_EST")), "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_CF"), 2, 3))
		// PEGA A SITUAÇÃO TRIBUTÁRIA DE ACORDO COM A TES
		GDFieldPut(_cCmp2 + "_CLASFI", SubStr(GDFieldGet(_cCmp2 + "_CLASFI", , .T.), 1, 1) + Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_SITTRIB"))

	EndIf
	
	If (_cTab1)->&(_cCmp1 + "_TIPO") # "6" .And. N > Len(oXml:_nfeProc:_NFe:_infNFe:_det)
		
		If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B;I;P;C"
		
			If GDFieldGet(_cCmp2 + "_COD",, .T.) # GDFieldGet(_cCmp2 + "_COD")
			
				aMarcNFs[N] := {"", "", "", "", "", "", "", "", ""}
			
				GDFieldPut(_cCmp2 + "_OK", "BR_CANCEL")
				
				LimpaNFs()
				
			EndIf
	
		EndIf
		
		Return .T.
		
	EndIf
	
/* ####################################################################### *\
|| #                      VALIDA UNIDADE DE MEDIDA                       # ||
\* ####################################################################### */
	
	If (_cTab1)->&(_cCmp1 + "_TIPO") # "6"
		
		cNcmXml := oXml:_nfeProc:_NFe:_infNFe:_det[N]:_prod:_NCM:Text
		cUMXml  := PadR(Upper(oXml:_nfeProc:_NFe:_infNFe:_det[N]:_prod:_uCom:Text), TamSX3(_cCmp2 + "_UMF")[1])
		
		If cUMXml <> cUM			
			
			GdFieldPut(_cCmp2 + "_UMF", cUMXml)
			GdFieldPut(_cCmp2 + "_UM", cUM)
			
			// Realiza a conversão de Unidade de Medida por Produto
			//                *Produto  *UM For  *UM Nosso  *Qtd For
			
			If lUMConv
				
				aConv := ValConUM(cProd, cUMXml, cUM, GDFieldGet(_cCmp2 + "_QUANT1", , .T.), (_cTab1)->&(_cCmp1 + "_CODEMI"), (_cTab1)->&(_cCmp1 + "_LOJEMI"), (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "B;D")
				
				// Conversão Ocorrida
				If aConv[1] .And. GDFieldGet(_cCmp2 + "_QUANT1",, .T.) # aConv[2]
				
					If Aviso("Unidade de Medida", "A Unidade de Medida do Produto está diferente do arquivo XML." + CRLF + ;
					         "Un.Medida do arquivo XML: " + cUMXml + CRLF + ;
					         "Un.Medida do Produto Informado: " + cUM + CRLF + ;
					         "Foi encontrado cadastro de conversão dessas unidades, gostaria de recalcular a quantidade e valor unitário?" + CRLF + ;
					         "Conversão: " + cValToChar(GDFieldGet(_cCmp2 + "_QUANT1",, .T.)) + " " + cUMXml + " => " + cValToChar(aConv[2]) + " " + cUM, {"Sim", "Não"}, 3) == 1
					
						GdFieldPut(_cCmp2 + "_QUANT2", aConv[2])
						
						If aConv[2] > 0
						
							GdFieldPut(_cCmp2 + "_VUNIT", Round(GDFieldGet(_cCmp2 + "_TOTAL", , .T.) / aConv[2], TamSX3(_cCmp2 + "_VUNIT")[2]))
							
						EndIf
						
					EndIf
					
				/*ElseIf lUMMsg
				
					Aviso("Unidade de Medida", "A Unidade de Medida do Produto está diferente do arquivo XML!" + CRLF + ;
					      "Un.Medida do arquivo XML: " + cUMXml + CRLF + ;
					      "Un.Medida do Produto Informado: " + cUM + CRLF + ;
					      "Não foi encontrado cadastro de conversão de unidade de medida entre as informada. Os valores não serão alterados.", {"Ok"}, 3)*/
					
				EndIf
				
			EndIf
			
		EndIf
		
	/* ####################################################################### *\
	|| #                     VALIDA ALÍQUOTA DE IMPOSTO                      # ||
	\* ####################################################################### */
		/*nAI := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_PICM")
		
		If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "N" .And. nAIXml <> nAI
		
			If Aviso("Alíquota de Imposto", "A Alíquota de Imposto do Produto está diferente do arquivo XML!" + CRLF + ;
			         "Alíquota do arquivo XML: " + IIf(!Empty(nAIXml), AllTrim(TRANSFORM(nAIXml, "@E 99.99")), "0") + CRLF + ;
			         "Alíquota do Produto Informado: " + IIf(!Empty(nAI), AllTrim(TRANSFORM(nAI, "@E 99.99")), "0") + CRLF + ;
			         "Deseja substituir pela alíquota de imposto do produto ou manter a do Xml?", {"Substituir", "Manter"}, 2) == 1
			
				GdFieldPut(_cCmp2 + "_PICM", nAI)
				
			Else
			
				GdFieldPut(_cCmp2 + "_PICM", nAIXml)
				
			EndIf
			
		ElseIf nAIXml <> nAI
		
			Aviso("Alíquota de Imposto", "A Alíquota de Imposto do Produto está diferente do arquivo XML!" + CRLF + ;
			      "Alíquota do arquivo XML: " + IIf(!Empty(nAIXml), AllTrim(TRANSFORM(nAIXml, "@E 99.99")), "0") + CRLF + ;
			      "Alíquota do Produto Informado: " + IIf(!Empty(nAI), AllTrim(TRANSFORM(nAI, "@E 99.99")), "0"), ;
			      {"Entendi"}, 2)
			
		EndIf*/
		
	EndIf
	
/* ####################################################################### *\
|| #                             VALIDA NCM                              # ||
\* ####################################################################### */
	cNcm := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_POSIPI")
	
	If AllTrim(cNcmXml) <> AllTrim(cNcm)
	
		If (_cTab1)->&(_cCmp1 + "_TIPO") == "6" .Or. Aviso("Código do NCM", "O código do NCM do Produto está diferente do arquivo XML!" + CRLF + ;
		         "NCM do arquivo XML: " + IIf(!Empty(cNcmXml), AllTrim(TRANSFORM(cNcmXml, "@R 9999.99.99")), "0") + CRLF + ;
		         "NCM do Produto Informado: " + IIf(!Empty(cNcm), AllTrim(TRANSFORM(cNcm, "@R 9999.99.99")), "0") + CRLF + ;
		         "Deseja substituir pelo código do NCM do produto ou manter o do Xml?", {"Substituir", "Manter"}, 2) == 1
		
			GdFieldPut(_cCmp2 + "_NCM", cNcm)
			
		Else
		
			GdFieldPut(_cCmp2 + "_NCM", cNcmXml)
			
		EndIf
		
	EndIf
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "N"
		
		If _nPosConta > 0
			
			GdFieldPut(_cCmp2 + "_CONTA", Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_CONTA"))
			
		EndIf
		
	EndIf
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B;I;P;C"
	
		If GDFieldGet(_cCmp2 + "_COD",, .T.) # GDFieldGet(_cCmp2 + "_COD")
		
			aMarcNFs[N] := {"", "", "", "", "", "", "", "", ""}
			GDFieldPut(_cCmp2 + "_OK", "BR_CANCEL")
			LimpaNFs()
			
		EndIf
		
	EndIf
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N" .And. GetNewPar("MV_XGODPPD", .T.) .And. oGetD:nAt == 1 .And. Len(oGetD:aCols) > 1 .And. (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N"
		
		GOXRepPD(oGetD, cProd)
		
	EndIf
	
Return .T.

////////////////////////////////////////

// [TODO]

Static Function GOXRepPD(oGetD, cProd)
	
	
	
Return

////////////////////////////////////////

User Function GO1QTDE()

	Local nQtdXml  := GDFieldGet(_cCmp2 + "_QUANT1", , .T.)
	Local nQtdInfo := GDFieldGet(_cCmp2 + "_QUANT2", , .T.)
	
	/*If nQtdXml # nQtdInfo
	
		If Aviso("Quantidade de produto", "Quantidade informada está diferente da quantidade do arquivo XML!" + CRLF + ;
		         "Qtde. Arquivo XML: " + Transform(nQtdXml, "@E 999999999.9999") + CRLF + ;
				 "Qtde. Informada: " + Transform(nQtdInfo, "@E 99999999.99") + CRLF + ;
				 "Deseja continuar?", {"Sim", "Não"}, 2) # 1
		
			Return .T.
			
		EndIf
		
	EndIf*/
	
	//GDFieldPut(_cCmp2 + "_TOTAL", Round(nQtdInfo * GDFieldGet(_cCmp2 + "_VUNIT", , .T.), TamSX3(_cCmp2 + "_TOTAL")[2]))
	GDFieldPut(_cCmp2 + "_VUNIT", Round(GDFieldGet(_cCmp2 + "_TOTAL", , .T.) / nQtdInfo, TamSX3(_cCmp2 + "_VUNIT")[2]) )//Round(nQtdInfo * GDFieldGet(_cCmp2 + "_VUNIT", , .T.), TamSX3(_cCmp2 + "_VUNIT")[2]))
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N" .And. !lPreNota
	
		GDFieldPut(_cCmp2 + "_BASEIC", GDFieldGet(_cCmp2 + "_TOTAL" , , .T.))
		GDFieldPut(_cCmp2 + "_VALICM", GDFieldGet(_cCmp2 + "_BASEIC", , .T.) * GDFieldGet(_cCmp2 + "_PICM", , .T.) / 100)
		GDFieldPut(_cCmp2 + "_BASEIP", GDFieldGet(_cCmp2 + "_TOTAL" , , .T.))
		GDFieldPut(_cCmp2 + "_VALIPI", GDFieldGet(_cCmp2 + "_BASEIP", , .T.) * GDFieldGet(_cCmp2 + "_IPI", , .T.) / 100)
		
	EndIf
	
Return .T.

////////////////////////////////////////

User Function GO1VUNIT()

	//GDFieldPut(_cCmp2 + "_TOTAL", GDFieldGet(_cCmp2 + "_QUANT2", , .T.)*GDFieldGet(_cCmp2 + "_VUNIT", , .T.))
	
	GDFieldPut(_cCmp2 + "_QUANT2", Round(GDFieldGet(_cCmp2 + "_TOTAL", , .T.) / GDFieldGet(_cCmp2 + "_VUNIT", , .T.), TamSX3(_cCmp2 + "_QUANT2")[2]) )
	
Return .T.

////////////////////////////////////////

User Function GO1CONTA()
	
	Local cCta := GDFieldGet(_cCmp2 + "_CONTA", , .T.)
	Local oGetDados
	
	If  (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N"
		
		oGetDados := oGetD
		
	Else
		
		oGetDados := oGetDItem
		
	EndIf
	
	If GetNewPar("MV_XSNDPTS", .T.) .And. oGetDados:nAt == 1 .And. Len(oGetDados:aCols) > 1 .And. (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N"
	
		GOXRepCta(oGetDados, cCta)
		
	EndIf
	
Return .T.

Static Function GOXRepCta(oGetDados, cCta)
	
	Local nI
	Local oDlgCta
	Local oLayerCta
	Local oListCta
	Local lOk     := .F.
	Local aProds  := {}
	Local aHeader := {"", "Produto", "Descrição", "Quantidade", "Vl. Unit.", "Total", "Conta Atual"}
	Local oOk     := LoadBitmap(GetResources(), "LBOK")
	Local oNo     := LoadBitmap(GetResources(), "LBNO")
	
	For nI := 1 To Len(oGetDados:aCols)
		
		If oGetDados:nAt # nI
			
			AAdd(aProds, { ;
				.T. , ;
				oGetDados:aCols[nI][_nPosProdu] , ;
				oGetDados:aCols[nI][_nPosDcPrd], ;
				oGetDados:aCols[nI][_nPosQtdNo], ;
				oGetDados:aCols[nI][_nPosVlUnt], ;
				oGetDados:aCols[nI][_nPosVlTot], ;
				oGetDados:aCols[nI][_nPosConta]  , ;
				nI ;
			})
			
		EndIf
		
	Next nI
	
	DEFINE MSDIALOG oDlgCta FROM aSize[7],0 To aSize[6]/1.3,aSize[5]/1.3 TITLE 'Replicar Conta' PIXEL
		
		oLayerCta := FWLayer():New()
		oLayerCta:Init(oDlgCta, .F.)
			
			oLayerCta:AddLine('CENTER', 95, .F.)
			
				oLayerCta:AddCollumn('COL_CENTER', 100, .T., 'CENTER')
				
					oLayerCta:AddWindow('COL_CENTER', 'WIN_CENTER', "Produtos para substituir a Conta", 100, .F., .T., , 'CENTER', )
						
						oListCta := TWBrowse():New(40, 05, 204, 140, , aHeader, , oLayerCta:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'), , , , , , , , , , , , .F., , .T., , .F., , , )
						oListCta:bLDblClick := {|| aProds[oListCta:nAt, 1] := !aProds[oListCta:nAt, 1], oListCta:Refresh()} // ClickSelPed(lAgrItens)
						oListCta:SetArray(aProds)
						oListCta:bLine := {|| { ;
											IIf(aProds[oListCta:nAt, 1], oOk, oNo), ;
						 					aProds[oListCta:nAt, 2], ;
						 					aProds[oListCta:nAt, 3], ;
						 					aProds[oListCta:nAt, 4], ;
						 					aProds[oListCta:nAt, 5], ;
						 					aProds[oListCta:nAt, 6], ;
						 					aProds[oListCta:nAt, 7] ;
										  }}
						oListCta:Align := CONTROL_ALIGN_ALLCLIENT
						
			oLayerCta:AddLine('BOTTOM', 5, .F.)
			
				oLayerCta:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')
				
					oPanelBot := tPanel():New(0, 0, "", oLayerCta:GetColPanel('COL_BOTTOM', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oQuit := THButton():New(0, 0, "&Cancelar", oPanelBot, {|| oDlgCta:End()}, , , )
					oQuit:nWidth  := 100
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oSel := THButton():New(0, 0, "&Replicar", oPanelBot, {|| lOk := .T., oDlgCta:End()}, , , )
					oSel:nWidth  := 110
					oSel:nHeight := 10
					oSel:Align := CONTROL_ALIGN_RIGHT
					oSel:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgCta CENTERED
	
	If lOk
		
		For nI := 1 To Len(aProds)
			
			If aProds[nI][1]
				
				GDFieldPut(_cCmp2 + "_CONTA", cCta, aProds[nI][8], oGetDados:aHeader, oGetDados:aCols)
				
			EndIf
			
		Next nI
		
	EndIf
	
Return

////////////////////////////////////////

User Function GO1CC()
	
	Local cCC := GDFieldGet(_cCmp2 + "_CC", , .T.)
	Local oGetDados
	
	If  (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N"
		
		oGetDados := oGetD
		
	Else
		
		oGetDados := oGetDItem
		
	EndIf
	
	If GetNewPar("MV_XSNDPTS", .T.) .And. oGetDados:nAt == 1 .And. Len(oGetDados:aCols) > 1 .And. (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N"
	
		GOXRepCC(oGetDados, cCC)
		
	EndIf
	
Return .T.

Static Function GOXRepCC(oGetDados, cCC)
	
	Local nI
	Local oDlgCC
	Local oLayerCC
	Local oListCC
	Local lOk     := .F.
	Local aProds  := {}
	Local aHeader := {"", "Produto", "Descrição", "Quantidade", "Vl. Unit.", "Total", "CC Atual"}
	Local oOk     := LoadBitmap(GetResources(), "LBOK")
	Local oNo     := LoadBitmap(GetResources(), "LBNO")
	
	For nI := 1 To Len(oGetDados:aCols)
		
		If oGetDados:nAt # nI
			
			AAdd(aProds, { ;
				.T. , ;
				oGetDados:aCols[nI][_nPosProdu] , ;
				oGetDados:aCols[nI][_nPosDcPrd], ;
				oGetDados:aCols[nI][_nPosQtdNo], ;
				oGetDados:aCols[nI][_nPosVlUnt], ;
				oGetDados:aCols[nI][_nPosVlTot], ;
				oGetDados:aCols[nI][_nPosCtCus]  , ;
				nI ;
			})
			
		EndIf
		
	Next nI
	
	DEFINE MSDIALOG oDlgCC FROM aSize[7],0 To aSize[6]/1.3,aSize[5]/1.3 TITLE 'Replicar Centro de Custo' PIXEL
		
		oLayerCC := FWLayer():New()
		oLayerCC:Init(oDlgCC, .F.)
			
			oLayerCC:AddLine('CENTER', 95, .F.)
			
				oLayerCC:AddCollumn('COL_CENTER', 100, .T., 'CENTER')
				
					oLayerCC:AddWindow('COL_CENTER', 'WIN_CENTER', "Produtos para substituir o Centro de Custo", 100, .F., .T., , 'CENTER', )
						
						oListCC := TWBrowse():New(40, 05, 204, 140, , aHeader, , oLayerCC:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'), , , , , , , , , , , , .F., , .T., , .F., , , )
						oListCC:bLDblClick := {|| aProds[oListCC:nAt, 1] := !aProds[oListCC:nAt, 1], oListCC:Refresh()} // ClickSelPed(lAgrItens)
						oListCC:SetArray(aProds)
						oListCC:bLine := {|| { ;
											IIf(aProds[oListCC:nAt, 1], oOk, oNo), ;
						 					aProds[oListCC:nAt, 2], ;
						 					aProds[oListCC:nAt, 3], ;
						 					aProds[oListCC:nAt, 4], ;
						 					aProds[oListCC:nAt, 5], ;
						 					aProds[oListCC:nAt, 6], ;
						 					aProds[oListCC:nAt, 7] ;
										  }}
						oListCC:Align := CONTROL_ALIGN_ALLCLIENT
						
			oLayerCC:AddLine('BOTTOM', 5, .F.)
			
				oLayerCC:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')
				
					oPanelBot := tPanel():New(0, 0, "", oLayerCC:GetColPanel('COL_BOTTOM', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oQuit := THButton():New(0, 0, "&Cancelar", oPanelBot, {|| oDlgCC:End()}, , , )
					oQuit:nWidth  := 100
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oSel := THButton():New(0, 0, "&Replicar", oPanelBot, {|| lOk := .T., oDlgCC:End()}, , , )
					oSel:nWidth  := 110
					oSel:nHeight := 10
					oSel:Align := CONTROL_ALIGN_RIGHT
					oSel:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgCC CENTERED
	
	If lOk
		
		For nI := 1 To Len(aProds)
			
			If aProds[nI][1]
				
				GDFieldPut(_cCmp2 + "_CC", cCC, aProds[nI][8], oGetDados:aHeader, oGetDados:aCols)
				
			EndIf
			
		Next nI
		
	EndIf
	
Return

////////////////////////////////////////

User Function GO1TES()
	
	Local cTes      := GDFieldGet(_cCmp2 + "_TES", , .T.)
	Local oGetDados
	
	If  (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N"
		
		oGetDados := oGetD
		
	Else
		
		oGetDados := oGetDItem
		
	EndIf
	
	If (_cTab1)->&(_cCmp1 + "_TIPOEN") == "D" .And. Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_PODER3") # "N"
	
		Help(, , 'Help', , "Em uma devolução a TES informada deve possuir poder de terceiros igual a N=Não controla.", 1, 0)
		Return .F.
		
	ElseIf (_cTab1)->&(_cCmp1 + "_TIPOEN") == "B" .And. Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_PODER3") # "D"
	
		GDFieldPut(_cCmp2 + "_OK", "CHECKOK", oGetDados:nAt, oGetDados:aHeader, oGetDados:aCols)
		
	ElseIf (_cTab1)->&(_cCmp1 + "_TIPOEN") == "B" .And. Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_PODER3") == "D" .And. Empty(aMarcNfs[oGetDItem:nAt][1])
	
		GDFieldPut(_cCmp2 + "_OK", "BR_CANCEL", oGetDados:nAt, oGetDados:aHeader, oGetDados:aCols)
		
	EndIf
	
	If _nPosCdFis > 0
		
		GDFieldPut(_cCmp2 + "_CF", RetCF(cTes, IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "N", cEstado, M->&(_cCmp1 + "_EST"))))
		// PEGA A SITUAÇÃO TRIBUTÁRIA DE ACORDO COM A TES
		
	EndIf
	
	If _nPosStTri > 0 .And. GetNewPar("MV_ZALTTXM", .F.)
		
		GDFieldPut(_cCmp2 + "_CLASFI", SubStr(GDFieldGet(_cCmp2 + "_CLASFI"), 1, 1) + Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_SITTRIB"))
		
	EndIf
	
	// Processo para perguntar se deseja replicar a TES:
	
	If GetNewPar("MV_XSNDPTS", .T.) .And. oGetDados:nAt == 1 .And. Len(oGetDados:aCols) > 1 .And. (_cTab1)->&(_cCmp1 + "_TIPOEN") == "N"
		
		GOXRepTES(oGetDados, cTes)
		
	EndIf
	
Return .T.

// ----------------------------

Static Function GOXRepTES(oGetDados, cTes)
	
	Local nI
	Local oDlgTes
	Local oLayerTES
	Local oListTes
	Local lOk     := .F.
	Local aProds  := {}
	Local aHeader := {"", "Produto", "Descrição", "Quantidade", "Vl. Unit.", "Total", "TES Atual", "CF Atual"}
	Local oOk     := LoadBitmap(GetResources(), "LBOK")
	Local oNo     := LoadBitmap(GetResources(), "LBNO")
	
	For nI := 1 To Len(oGetDados:aCols)
		
		If oGetDados:nAt # nI
			
			AAdd(aProds, { ;
				.T. , ;
				oGetDados:aCols[nI][_nPosProdu] , ;
				oGetDados:aCols[nI][_nPosDcPrd], ;
				oGetDados:aCols[nI][_nPosQtdNo], ;
				oGetDados:aCols[nI][_nPosVlUnt], ;
				oGetDados:aCols[nI][_nPosVlTot], ;
				oGetDados:aCols[nI][_nPosTes]  , ;
				oGetDados:aCols[nI][_nPosCdFis], ;
				oGetDados:aCols[nI][_nPosStTri], ;
				nI ;
			})
			
		EndIf
		
	Next nI
	
	DEFINE MSDIALOG oDlgTes FROM aSize[7],0 To aSize[6]/1.3,aSize[5]/1.3 TITLE 'Replicar TES' PIXEL
		
		oLayerTES := FWLayer():New()
		oLayerTES:Init(oDlgTes, .F.)
			
			oLayerTES:AddLine('CENTER', 95, .F.)
			
				oLayerTES:AddCollumn('COL_CENTER', 100, .T., 'CENTER')
				
					oLayerTES:AddWindow('COL_CENTER', 'WIN_CENTER', "Produtos para substituir a TES", 100, .F., .T., , 'CENTER', )
						
						oListTes := TWBrowse():New(40, 05, 204, 140, , aHeader, , oLayerTES:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'), , , , , , , , , , , , .F., , .T., , .F., , , )
						oListTes:bLDblClick := {|| aProds[oListTes:nAt, 1] := !aProds[oListTes:nAt, 1], oListTes:Refresh()} // ClickSelPed(lAgrItens)
						oListTes:SetArray(aProds)
						oListTes:bLine := {|| { ;
											IIf(aProds[oListTes:nAt, 1], oOk, oNo), ;
						 					aProds[oListTes:nAt, 2], ;
						 					aProds[oListTes:nAt, 3], ;
						 					aProds[oListTes:nAt, 4], ;
						 					aProds[oListTes:nAt, 5], ;
						 					aProds[oListTes:nAt, 6], ;
						 					aProds[oListTes:nAt, 7], ;
						 					aProds[oListTes:nAt, 8], ;
						 					aProds[oListTes:nAt, 9]  ;
										  }}
						oListTes:Align := CONTROL_ALIGN_ALLCLIENT
						
			oLayerTES:AddLine('BOTTOM', 5, .F.)
			
				oLayerTES:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')
				
					oPanelBot := tPanel():New(0, 0, "", oLayerTES:GetColPanel('COL_BOTTOM', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oQuit := THButton():New(0, 0, "&Cancelar", oPanelBot, {|| oDlgTes:End()}, , , )
					oQuit:nWidth  := 100
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oSel := THButton():New(0, 0, "&Replicar", oPanelBot, {|| lOk := .T., oDlgTes:End()}, , , )
					oSel:nWidth  := 110
					oSel:nHeight := 10
					oSel:Align := CONTROL_ALIGN_RIGHT
					oSel:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgTes CENTERED
	
	If lOk
		
		For nI := 1 To Len(aProds)
			
			If aProds[nI][1]
				
				GDFieldPut(_cCmp2 + "_TES", cTes, aProds[nI][10], oGetDados:aHeader, oGetDados:aCols)
				
				If _nPosCdFis > 0
					
					GDFieldPut(_cCmp2 + "_CF", RetCF(cTes, IIf((_cTab1)->&(_cCmp1 + "_TIPOEN") == "N", cEstado, M->&(_cCmp1 + "_EST"))), aProds[nI][10], oGetDados:aHeader, oGetDados:aCols)
					
				EndIf
				
				If _nPosStTri > 0 .And. GetNewPar("MV_ZALTTXM", .F.)
					
					GDFieldPut(_cCmp2 + "_CLASFI", SubStr(GDFieldGet(_cCmp2 + "_CLASFI", aProds[nI][10], , oGetDados:aHeader, oGetDados:aCols), 1, 1) + Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_SITTRIB"), aProds[nI][10], oGetDados:aHeader, oGetDados:aCols)
					
				EndIf
				
			EndIf
			
		Next nI
		
	EndIf
	
Return

Static Function ExibeInfo(cCmp)
	
	Local oDlg
	Local cInfo
	Local cDesc := ""
	
	If (_cTab1)->( Eof() )
		
		Aviso("Aviso", "É necessário selecionar um registro válido da tabela.", {"Ok"}, 2)
		Return
		
	EndIf
	
	cInfo := &("(_cTab1)->" + cCmp)
	
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	
	If SX3->( dbSeek(cCmp) )
		
		cDesc := X3Descric()
		
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE "Visualizar - " + cDesc From 0, 0 To 30, 80
	
		oPanelA := tPanel():New(10, 10, , oDlg, , , , , , 10, 10, .F., .F.)
		oPanelA:Align := CONTROL_ALIGN_ALLCLIENT
		
		oPanelB := tPanel():New(0, 0, , oDlg, , , , , , 20, 20, .F., .F.)
		oPanelB:Align := CONTROL_ALIGN_BOTTOM
		
		oTMultiget := TMultiget():New(06, 06, {|u| If(Pcount()>0, cInfo:=u, cInfo)}, ;
		              oPanelA, 265, 105, , , , , , .T., , , , , , .T.)		
		oTMultiget:Align := CONTROL_ALIGN_ALLCLIENT
		oTMultiget:EnableVScroll(.T.)
		oTMultiget:EnableHScroll(.T.)
		
		oButtonOK := tButton():New(5, 5, 'OK', oPanelB, {|| oDlg:End()}, 25, 10, , , , .T.)
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

Static Function ExibeErro()

	If !(_cTab1)->( Eof() ) .And. !((_cTab1)->&(_cCmp1 + "_SIT") $ "3,6")
		
		Aviso("Aviso", "Para mostrar um erro, selecione um Xml com problemas de importação.", {"Ok"}, 2)
		Return
		
	EndIf
	
	ExibeInfo(_cCmp1 + "_ERRO")
	
Return

////////////////////////////////////////

//Static Function XmlImportado(aSit)

User Function GOX1XMLI(aSit)
	
	Local aAreaSZW := (_cTab1)->( GetArea() )
	Local oBrowse
	Local cSits    := ""
	Local nI
	Local aRotAux := IIf(Type("aRotina") # "U", aRotina, Nil)
	
	aRotina := Nil
	
	Private cItemPos := ''  // Pega o registro corrente, para que ao validar a legenda o registro não seja posicionado duas vezes.
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(_cTab1)
	oBrowse:SetMenuDef("") 
	oBrowse:SetDescription("Xml's Importados")
	oBrowse:DisableReport()
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	
	For nI := 1 To Len(aSit)
	
		If nI == Len(aSit)
		
			cSits += aSit[nI][1]
			
		Else
		
			cSits += aSit[nI][1] + ";"
			
		EndIf
		
	Next nI
	
	If "4" $ cSits .Or. "5" $ cSits
		
		For nI := 1 To Len(aSit)
			
			oBrowse:AddLegend(_cCmp1 + "_SIT == '" + aSit[nI][1] + "'", aSit[nI][3], aSit[nI][2], "2")
			
		Next nI
		
	Else
		
		oBrowse:AddLegend("U_GOSitImp(1)", "ENABLE"    , "NF Não Classificada", "1")
		oBrowse:AddLegend("U_GOSitImp(2)", "BR_LARANJA", "NF Bloqueada", "1")
		oBrowse:AddLegend("U_GOSitImp(3)", "BR_VIOLETA", "NF Bloqueada s/classf.", "1")
		oBrowse:AddLegend("U_GOSitImp(4)", "DISABLE"   , "NF Normal", "1")
		oBrowse:AddLegend("U_GOSitImp(5)", "BR_AZUL"   , "NF de Compl. IPI", "1")
		oBrowse:AddLegend("U_GOSitImp(6)", "BR_MARROM" , "NF de Compl. ICMS", "1")
		oBrowse:AddLegend("U_GOSitImp(7)", "BR_PINK"   , "NF de Compl. Preco/Frete", "1")
		oBrowse:AddLegend("U_GOSitImp(8)", "BR_CINZA"  , "NF de Beneficiamento", "1")
		oBrowse:AddLegend("U_GOSitImp(9)", "BR_AMARELO", "NF de Devolução", "1")
		oBrowse:AddLegend("U_GOSitImp(0)", "XCLOSE"    , "NF Não Existe no sistema", "1")
		
	EndIf
	
	SetFieldsBrowse(oBrowse)
	oBrowse:SetFilterDefault(GetFilterXml(cSits))
	oBrowse:AddButton("&Visualizar Xml", "StaticCall(GOX001, ExibeInfo, '" + _cCmp1 + "_XML')", , 4, 0)
	oBrowse:AddButton("Do&wnload Xml", "U_GOX1BXXM()", , 4, 0)
	
	/*If !("4" $ cSits) .And. !("5" $ cSits)
	
		oBrowse:AddButton("&Classificar", "StaticCall(GOX001, ClassDoc, AlwaysTrue())", , 5, 0)
		
	EndIf*/
	
	If !("4" $ cSits) .And. !("5" $ cSits)
		
		oBrowse:AddButton("&Excluir", "StaticCall(GOX001, ExcluirDoc, AlwaysTrue())", , 4, 0)
		oBrowse:AddButton("&Alterar", "StaticCall(GOX001, AlterarDoc, AlwaysTrue())", , 4, 0)
		oBrowse:AddButton("&Vis. Doc.", "StaticCall(GOX001, VisuImpDoc)", , 4, 0)
		oBrowse:AddButton("&Imprimir", "StaticCall(GOX001, Mt103Imp)", , 4, 0)
		oBrowse:AddButton("&DANFE", "U_GOX1IMPX()", , 4, 0)
		
	EndIf
	
	oBrowse:Activate()
	RestArea(aAreaSZW)
	
	aRotina := aRotAux
	
Return

/* ####################################################################### *\
|| #      VALIDA A SITUAÇÃO DA NOTA PARA IDENTICAR QUE LEGENDA USAR      # ||
\* ####################################################################### */
User Function GOSitImp(nType)

	// SE O ITEM POSICIONADO FOR DIFERENTE DO ITEM CORRENTE
	If cItemPos != (xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + ;
	                (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI"))

		// PEGA O ITEM CORRENTE
		cItemPos := (xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + ;
		             (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI"))

		//SF1->( dbCloseArea() )
		// POSICIONA NA TABELA
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		SF1->( dbSeek(cItemPos) )

	EndIf
	
	Do Case
		
		Case nType == 0                     // NF Não Existe no sistema
			
			Return (SF1->( Eof() ) .Or. Empty(SF1->F1_DOC))
			
		Case nType == 1                     // NF Nao Classificada
			
			Return (Empty(SF1->F1_STATUS) .And. !Empty(SF1->F1_DOC))
			
		Case nType == 2                     // NF Bloqueada
			
			Return (SF1->F1_STATUS == "B")
			
		Case nType == 3                     // NF Bloqueada s/classf.

			Return (SF1->F1_STATUS == "C")
		
		Case nType == 4                     // NF Normal

			Return (SF1->F1_TIPO == "N")
		
		Case nType == 5                     // NF de Compl. IPI

			Return (SF1->F1_TIPO == "P")
		
		Case nType == 6                     // NF de Compl. ICMS

			Return (SF1->F1_TIPO == "I")
		
		Case nType == 7                     // NF de Compl. Preco/Frete

			Return (SF1->F1_TIPO == "C")
		
		Case nType == 8                     // NF de Beneficiamento

			Return (SF1->F1_TIPO == "B")
		
		Case nType == 9                     // NF de Devolucao

			Return (SF1->F1_TIPO == "D")
		
	EndCase
	
Return .F.

////////////////////////////////////////

Static Function VisuImpDoc(lPos)

	Private aRotina := {{"&Visualizar", "A103NFiscal", 0, 2}}

	Default lPos := .F.

	If lPos

		MsAguarde({|| A103NFiscal("SF1", , 1, .F., .F.)}, "Aguarde", "Carregando visualização...")
		Return

	EndIf
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(8) )
	
	If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_CHAVE")) )
		
		MsAguarde({|| A103NFiscal("SF1", , 1, .F., .F.)}, "Aguarde", "Carregando visualização...")

	Else

		Aviso("Aviso", "Documento de entrada não encontrado.", {"Ok"}, 2)

	EndIf

Return

////////////////////////////////////////

CLASS GOLog

	DATA cFilename
	DATA cFullFile
	DATA cTitulo
	DATA cBody
	DATA cLogOption
	DATA lAutoSave

	// Declaração dos Métodos da Classe
	METHOD New(cFilename, cTitulo, cLogOption) CONSTRUCTOR
	METHOD Add(cTexto, nIdent, lSkip)
	METHOD AddDebug(cTexto)
	METHOD ShowParameters(cPergunte)
	METHOD NewLine(nCont)
	METHOD Save()
	METHOD CheckLimit()
	METHOD EndLog()
	METHOD ChangeFilename(cNewFile)
	METHOD Reset(cFilename, cTitulo, cLogOption)
	METHOD GetBody()

ENDCLASS

////////////////////////////////////////

METHOD GetBody() Class GOLog

Return ::cBody

////////////////////////////////////////

METHOD Reset(lNew) Class GOLog

	Default lNew := .F.

	::cBody := ""

	If !lNew .And. File(::cFullFile)

		FErase(::cFullFile)

	EndIf

	If ::cLogOption == GOLOG_CONSOLE

		conout(::cTitulo + " : Reiniciando Log " + Replicate("-", 20))

	EndIf

	If ::cLogOption $ GOLOG_INFO + GOLOG_DEBUG

		::ChangeFilename(::cFilename)

		::cBody += Replicate("-", 120) + CRLF
		::cBody += ::cTitulo + CRLF
		::cBody += "Data da Geração: " + Dtoc(Date()) + " - " + Time() + CRLF
		::cBody += "Grupo de Empresa: " + AllTrim(FWGrpCompany()) + "-" + AllTrim(FWGrpName()) + " | " + "Filial: " + AllTrim(cFilAnt) + "-" + AllTrim(FwFilialName()) + CRLF
		::cBody += "Usuário: " + cUserName + CRLF
		::cBody += Replicate("-", 120) + CRLF
		::NewLine(2)

	EndIf

Return

////////////////////////////////////////

METHOD New(cFilename, cTitulo, cLogOption, lAutoS) Class GOLog

	Default cLogOption := GOLOG_DISABLED
	Default lAutoS := .T.

	::cTitulo 	 := cTitulo
	::cFilename  := cFilename
	::cFullFile  := cFilename
	::cLogOption := cLogOption
	::cBody		 := ""
	::lAutoSave  := lAutoS

	If ::cLogOption == GOLOG_CONSOLE

		conout(::cTitulo + " : Início do Log " + Replicate("-", 20))

	EndIf

	If ::cLogOption $ GOLOG_INFO + GOLOG_DEBUG

		::ChangeFilename(cFilename)

		::cBody += Replicate("-", 120) + CRLF
		::cBody += ::cTitulo + CRLF
		::cBody += "Data da Geração: " + DToC(Date()) + " - " + Time() + CRLF
		::cBody += "Grupo de Empresa: " + AllTrim(FWGrpCompany()) + "-" + AllTrim(FWGrpName()) + " | " + "Filial: " + AllTrim(cFilAnt) + "-" + AllTrim(FwFilialName()) + CRLF
		::cBody += "Usuário: " + cUserName + CRLF
		::cBody += Replicate("-", 120) + CRLF
		::NewLine(2)

	EndIf

Return Self

////////////////////////////////////////

METHOD EndLog() Class GOLog
	
	If ::cLogOption == GOLOG_DISABLED
		
		Return
		
	EndIf
	
	If ::cLogOption == GOLOG_CONSOLE
		
		conout(::cTitulo + " : Fim do processamento " + Replicate("-", 20))
		Return
		
	EndIf
	
	::NewLine(2)
	::cBody += Replicate("-", 120) + CRLF
	::cBody += "Término da Geração: " + DToC(Date()) + " - " + Time() + CRLF
	::cBody += Replicate("-", 120) + CRLF
	::Save()
	
Return Nil

////////////////////////////////////////

METHOD Add(cTexto, nIdent, lSkip) Class GOLog
	
	Default nIdent := 0
	Default lSkip  := .T.
	
	If ::cLogOption == GOLOG_DISABLED
		
		Return
		
	EndIf

	If ::cLogOption == GOLOG_CONSOLE

		conout(::cTitulo + " : " + cTexto)
		Return

	EndIf

	If Empty(cTexto)

		::NewLine()
		Return Nil

	EndIf

	If ::cLogOption == GOLOG_DEBUG

		::cBody += "[" + PADR(Time(), 8) + "]" + Space(2)

	EndIf

	If nIdent > 0

		::cBody += Replicate(" ", nIdent*2)

	EndIf

	::cBody += cTexto + IIf(lSkip, CRLF, "")

	If ::lAutoSave

		::Save()

	Else
		
		::CheckLimit()

	EndIf

Return Nil

////////////////////////////////////////

METHOD AddDebug(cTexto) Class GOLog

	If ::cLogOption != GOLOG_DEBUG

		Return

	EndIf

	::cBody := ::cBody + cTexto + CRLF

	If ::lAutoSave

		::Save()

	Else
		
		::CheckLimit()

	EndIf

Return Nil

////////////////////////////////////////

METHOD ShowParameters(cPergunte) Class GOLog

	Local nTextSize := 0
	Local nI
	Local aItens := {}
	Local cValue

	::Add("Parâmetros ------------------------")

	dbSelectArea("SX1")
	dbSetOrder(1)
	dbSeek(cPergunte)

	While !SX1->( Eof() ) .And. SX1->X1_GRUPO = cPergunte

		If Len(AllTrim(SX1->X1_PERGUNT)) > nTextSize

			nTextSize := Len(AllTrim(SX1->X1_PERGUNT))

		EndIf

		AAdd(aItens, AllTrim(SX1->X1_PERGUNT))
		SX1->( dbSkip() )

	EndDo

	For nI := 1 To Len(aItens)

		cValue := &("MV_PAR" + If(nI <= 9, "0", "") + AllTrim(cValToChar(nI)))
		::Add(aItens[nI] + Replicate(".", nTextSize - Len(aItens[nI])) + ": " + cValToChar(cValue))

	Next

	::NewLine()

Return Nil

////////////////////////////////////////

METHOD NewLine(nCont) Class GOLog

	Default nCont := 1

	If ::cLogOption == GOLOG_DISABLED

		Return

	EndIf

	If ::cLogOption == GOLOG_CONSOLE

		conout(::cTitulo)
		Return

	EndIf

	::cBody := ::cBody + Replicate(CRLF, nCont)
	
	If ::lAutoSave

		::Save()

	Else
		
		::CheckLimit()

	EndIf

Return Nil

////////////////////////////////////////

METHOD CheckLimit()  Class GOLog
	
	If ::cLogOption == GOLOG_DISABLED
		
		Return
		
	EndIf
	
	If Len(::cBody) > 900000
		
		::Save()
		
	EndIf
	
Return Nil

////////////////////////////////////////

METHOD ChangeFilename(cNewFile) Class GOLog
	
	::cFilename := cNewFile
	
	If ::cLogOption != GOLOG_INFO .And. ::cLogOption != GOLOG_DEBUG
		
		Return
		
	EndIf
	
	::cFullFile := ::cFilename + "_" + Dtos(Date()) + "_" + StrTran(Time(), ":", "") + ".log"
	
Return Nil

////////////////////////////////////////

METHOD Save() Class GOLog
	
	Local nHandle := 0
	Local cDir    := GetNewPar("MV_ZDIRSLG", "\system\importador_logs")
	
	If ::cLogOption != GOLOG_INFO .And. ::cLogOption != GOLOG_DEBUG
		
		Return
		
	EndIf
	
	If !ExistDir(cDir)
		
		MakeDir(cDir)
		
	EndIf
	
	cDir += "\"
	
	If !File(cDir + ::cFullFile)  // Arquivo não existe
		
		// Cria o arquivo de log
		nHandle := FCreate(cDir + ::cFullFile, FC_NORMAL)
		FSeek(nHandle, 0)	// Posiciona no inicio do arquivo de log
		
	Else	// Arquivo existe
		
		nHandle := FOpen(cDir + ::cFullFile, FO_READWRITE + FO_EXCLUSIVE)
		FSeek(nHandle, 0, FS_END)	// Posiciona no fim do arquivo de log
		
	EndIf
	
	FWrite(nHandle, ::cBody, Len(::cBody)) // Grava o conteudo da variavel no arquivo de log
	FClose(nHandle) // Fecha o arquivo de log
	::cBody := ""
	
Return Nil

/* ####################################################################### *\
|| #                         CONTROLE DE VERSÃO                          # ||
\* ####################################################################### */
User Function GO001V()

Return {"12.1.25", CToD("23/10/2020")}

////////////////////////////////////////

// Quando há qualquer erro no XML que impessa sua importação, onde ele seja ignorado (XML de outra filial, por exemplo) ou erro de estrutura (XML enviado pelo fornecedor inválido)
Static Function AddIncXml(cMsg)
	
	lXmlErro := .T.
	
	cInfErroC += cMsg
	
Return 

Static Function AddErroXml(cMsg)
	
	lVldErro := .T.
	
	cErroXML += cMsg
	
Return

////////////////////////////////////////

User Function GODSEMIT(lTmp)
	
	Default lTmp := .F.
	
	If lTmp .And. (!IsInCallStack("U_GOX1XMLI") .Or. IsInCallStack("ConfSelXml"))
		
		Return (cAliXML)->&(_cCmp1 + "_EMIT")
		
	EndIf
	
	SA2->( dbSetOrder(3) )
	If SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) )
		
		While !SA2->( Eof() ) .And. SA2->A2_FILIAL == xFilial("SA2") .And. SA2->A2_CGC == (_cTab1)->&(_cCmp1 + "_CGCEMI")
			
			If SA2->A2_MSBLQL # "1"
				
				Return SA2->A2_NOME
				
			EndIf
			
			SA2->( dbSkip() )
			
		EndDo
		
		If SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) )
		
			Return SA2->A2_NOME
			
		EndIf

	Else

		dbSelectArea("SA1")
		SA1->( dbSetOrder(3) )
		If SA1->( dbSeek(xFilial("SA1") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) )
			
			While !SA1->( Eof() ) .And. SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_CGC == (_cTab1)->&(_cCmp1 + "_CGCEMI")
				
				If SA1->A1_MSBLQL # "1"
					Return SA1->A1_NOME
				EndIf
				
				SA1->( dbSkip() )
				
			EndDo
			
			If SA1->( dbSeek(xFilial("SA1") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) )
			
				Return SA1->A1_NOME
				
			EndIf

		EndIf

	EndIf

Return ""

////////////////////////////////////////

Static Function CBoxInfo(cNmFld, cValue, nInfoType)
	
	Local cAux

	Default nInfoType := 2

	cAux := StrTokArr(Posicione("SX3", 2, cNmFld, "X3_CBOX"), ';')[Val(cValue)]

Return If(!Empty(cAux), StrTokArr(cAux, "=")[nInfoType], "")

////////////////////////////////////////

Static Function RetCF(cTes, cEstado)

Return IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_CF"), 2, 3)

////////////////////////////////////////

Static Function MontaErro(aErro)

	Local nI
	Local cMsg := ""	

	For nI := 1 To Len(aErro)

		cMsg += aErro[nI] + CRLF

	Next

Return cMsg

User Function GOXErAut(aErro)

	Local nI
	Local cMsg := ""	

	For nI := 1 To Len(aErro)

		cMsg += aErro[nI] + CRLF

	Next

Return cMsg

////////////////////////////////////////

Static Function AjustaSX6()

	Local aSX6    := {}
	Local aEstrut := {}
	Local i       := 0
	Local j       := 0
	Local lInclui := .F.

	aEstrut:= {"X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_DSCSPA", "X6_DSCENG", "X6_DESC1", "X6_DSCSPA1", ;
			   "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", ;
			   "X6_PROPRI", "X6_PYME"}

	AAdd(aSX6, {cFil, ;											  //Filial
			"MV_XGTCONF", ;										  //Var
			"L", ;                 								  //Tipo
			"Marque esta opcao para na efetivacao da importacao", ;//Descric
			"Marque esta opcao para na efetivacao da importacao", ;//DscSpa
			"Marque esta opcao para na efetivacao da importacao", ;//DscEng
			" da NFe mostre a tela de Documento de Entrada para", ;//Desc1
			" da NFe mostre a tela de Documento de Entrada para", ;//DscSpa1
			" da NFe mostre a tela de Documento de Entrada para", ;//DscEng1
			" conferencia de como o Documento sera implantado. ", ;//Desc2
			" conferencia de como o Documento sera implantado. ", ;//DscSpa2
			" conferencia de como o Documento sera implantado. ", ;//DscEng2
			".T.", ;												  //Conteud
			".T.", ;												  //ContSpa
			".T.", ;												  //ContEng
			"U", ;												  //Propri		
			"S"})												  //Pyme

	AAdd(aSX6, {cFil, ;											  //Filial
			"MV_XGTNFIN", ;										  //Var
			"C", ;                 								  //Tipo
			"Local onde os XML que chegarem a empresa devem ser", ;//Descric
			"Local onde os XML que chegarem a empresa devem ser", ;//DscSpa
			"Local onde os XML que chegarem a empresa devem ser", ;//DscEng
			" armazenados.", ;									  //Desc1
			" armazenados.", ;									  //DscSpa1
			" armazenados.", ;									  //DscEng1
			"", ;												  //Desc2
			"", ;												  //DscSpa2
			"", ;												  //DscEng2
			"", ;												  //Conteud
			"", ;												  //ContSpa
			"", ;												  //ContEng
			"U", ;												  //Propri		
			"S"})

	AAdd(aSX6, {cFil, ;										  //Filial
			"MV_XGTNFOU", ;									  //Var
			"C", ;                 							  //Tipo
			"Local aonde os XML ja importados serao salvos.", ;//Descric
			"Local aonde os XML ja importados serao salvos.", ;//DscSpa
			"Local aonde os XML ja importados serao salvos.", ;//DscEng
			"", ;											  //Desc1
			"", ;											  //DscSpa1
			"", ;											  //DscEng1
			"", ;											  //Desc2
			"", ;											  //DscSpa2
			"", ;											  //DscEng2
			"", ;											  //Conteud
			"", ;											  //ContSpa
			"", ;											  //ContEng
			"U", ;											  //Propri
			"S"})

	AAdd(aSX6, {cFil, ;										  //Filial
			"MV_XGTPROC", ;									  //Var
			"C", ;                 							  //Tipo
			"Local do arquivo de confirmação de atualização.", ;//Descric
			"Local do arquivo de confirmação de atualização.", ;//DscSpa
			"Local do arquivo de confirmação de atualização.", ;//DscEng
			"", ;											  //Desc1
			"", ;											  //DscSpa1
			"", ;											  //DscEng1
			"", ;											  //Desc2
			"", ;											  //DscSpa2
			"", ;											  //DscEng2
			"", ;											  //Conteud
			"", ;											  //ContSpa
			"", ;											  //ContEng
			"U", ;											  //Propri
			"S"})

	AAdd(aSX6, {cFil, ;										  //Filial
			"MV_XGTTMNF", ;									  //Var
			"N", ;                 							  //Tipo
			"Tamanho das notas importadas.", ;				  //Descric
			"Tamanho das notas importadas.", ;				  //DscSpa
			"Tamanho das notas importadas.", ;				  //DscEng
			"", ;											  //Desc1
			"", ;											  //DscSpa1
			"", ;											  //DscEng1
			"", ;											  //Desc2
			"", ;											  //DscSpa2
			"", ;											  //DscEng2
			"9", ;											  //Conteud
			"9", ;											  //ContSpa
			"9", ;											  //ContEng
			"U", ;											  //Propri
			"S"})

	dbSelectArea("SX6")
	SX6->( dbSetOrder(1) )

	For i := 1 To Len(aSX6)

		If !SX6->( dbSeek(cFil + aSX6[i, 2]) )

			RecLock("SX6", .T.)

				For j := 1 To Len(aSX6[i])

					If FieldPos(aEstrut[j]) > 0

						FieldPut(FieldPos(aEstrut[j]), aSX6[i, j])

					EndIf

				Next j

			MsUnLock()

		EndIf

	Next i

Return

////////////////////////////////////////

User Function GORetorn(cAlias, nReg, nOpcx)
	
	Private lAtivo := .T.
	
	If Inclui
		
		GO103Dev(cAlias, nReg, nOpcx)

		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )

		If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )

			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1 + "_SIT")    := "2"
				(_cTab1)->&(_cCmp1 + "_ERRO")   := ""
				(_cTab1)->&(_cCmp1 + "_ESPECI") := cEspNFe
				//(_cTab1)->&(_cCmp1 + "_TIPOEN") := SF1->F1_TIPO
				(_cTab1)->&(_cCmp1 + "_DTIMP")  := dDataBase
				(_cTab1)->&(_cCmp1 + "_HRIMP")  := Time()
				(_cTab1)->&(_cCmp1 + "_USUIMP") := cUserName
			(_cTab1)->( MsUnlock() )

		EndIf

	EndIf

Return .T.

////////////////////////////////////////

Static Function GO103Dev(cAlias, nReg, nOpcx)
	
	Local oDlgEsp
	Local oLbx
	Local lCliente  := .F.
	Local aRotina   := {{"&Retornar", "U_GO103DvF(cNomeCdx), U_GO103PrD", 0, 4}} //"Retornar"
	Local nOpca     := 0
	Local aHSF2     := {}
	Local aSF2      := {}
	Local aCpoSF2   := {}
	Local dDataDe   := CToD('  /  /  ')
	Local dDataAte  := CToD('  /  /  ')
	Local nCnt      := 0
	Local nPosDoc   := 0
	Local nPosSerie := 0
	Local cDocSF2   := ''
	Local cIndex    := ''
	Local cQuery    := ''    
	Local cCampos   := ''
	Local lMT103CAM	:= Existblock("MT103CAM")
	Local lFilCliFor:= .T.
	Local lAllCliFor:= .T.
	Local lFlagDev	:= GetNewPar("MV_FLAGDEV",.F.)
	Local aSize		:= {}
	
	Private cCliente := CriaVar("F2_CLIENTE",.F.)
	Private cLoja    := CriaVar("F2_LOJA",.F.)    
	Private cQrDvF2  := ""
	Private l103Devol := .T.
	
	SF2->(dbSetOrder(1))
	
	If Inclui
		//-- Valida filtro de retorno de doctos fiscais.
		If GO103FRet(@lCliente, @dDataDe, @dDataAte, @lFilCliFor, @lAllCliFor)
			If lCliente
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ P.E. Utilizado para adicionar novos campos na GetDados       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If lMT103CAM
			    	cCampos := ExecBlock("MT103CAM",.F.,.F.)
			    EndIf
				Aadd( aHSF2, ' ' )
				SX3->(DbSetOrder(1))
				SX3->(DbSeek("SF2"))
				While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SF2" 
				    If (SX3->X3_BROWSE == "S" .And. (AllTrim(SX3->X3_CAMPO) == 'F2_DOC' .Or. AllTrim(SX3->X3_CAMPO) == 'F2_SERIE')) .Or. (AllTrim(SX3->X3_CAMPO) $ cCampos)
	
							Aadd( aHSF2, X3Titulo() )
						
						Aadd( aCpoSF2, SX3->X3_CAMPO )
						//-- Armazena a posicao do documento e serie
						If AllTrim(SX3->X3_CAMPO) == 'F2_DOC'
							nPosDoc := Len(aHSF2)
						ElseIf AllTrim(SX3->X3_CAMPO) == 'F2_SERIE'
							nPosSerie := Len(aHSF2)
						EndIf
					EndIf
	
					SX3->(DbSkip())
				EndDo
				//-- Retorna as notas que atendem o filtro.
				aSF2 := GO103RetNF(aCpoSF2, dDataDe, dDataAte, lFilCliFor, lAllCliFor)
				If !Empty(aSF2)
					aSize := {00,12,320,610}
					DEFINE MSDIALOG oDlgEsp TITLE "Retorno de Doctos. de Saída" FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL
	
					oLbx:= TWBrowse():New( aSize[1]+20, (aSize[2]-12), aSize[3], (aSize[4]-470), NIL, ;
					aHSF2, NIL, oDlgEsp, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
	
					oLbx:SetArray( aSF2 )
					oLbx:bLDblClick  := { || { aSF2[oLbx:nAT,1] := !aSF2[oLbx:nAT,1] }}
					oLbx:bLine := &('{|| U_GO103Lin(oLbx:nAT, aSF2)}')
					ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpca := 1, oDlgEsp:End()},{||oDlgEsp:End()}) CENTERED
					//-- Processa Devolucao				
					If nOpca == 1
						ASort( aSF2,,,{|x,y| x[1] > y[1] })
						For nCnt := 1 To Len(aSF2)
							If !aSF2[nCnt,1]
								Exit
							EndIf
								cDocSF2 += IIF(Len(cDocSF2)>0,",","")+"'"+aSF2[nCnt,nPosDoc]+aSF2[nCnt,nPosSerie]+"'"
						Next nCnt
						If !Empty(cDocSF2)
								cDocSF2 := "("+Subs(cDocSF2,1,Len(cDocSF2))+")"
						EndIf
						U_GO103PrD(cAlias, nReg, nOpcx, lCliente, cCliente, cLoja, cDocSF2)
					EndIf			
				Else
					
					RecLock(_cTab1, .F.)
						
						(_cTab1)->&(_cCmp1 + "_ERRO") := "Retornar: Não foram encontradas Notas Fiscais de Saída para retornar."
						
					(_cTab1)->( MSUnlock() )
				EndIf
			Else
				DbSelectArea("SF2")
				cIndex := CriaTrab(NIL,.F.)
				
	   			If ExistBlock("MT103RET")//Ponto de entrada para complemento de filtro na query
	       		   cQuery := ExecBlock("MT103RET",.F.,.F.,{dDataDe,dDataAte})
	            Else  
			       cQuery := "F2_FILIAL == '" + xFilial("SF2") + "' "
			  	   cQuery += ".AND. F2_TIPO <> 'D' "
	               
	               If !lAllCliFor
					   If lFilCliFor 		
					  	   	cQuery += ".And. F2_TIPO <> 'B' "
		               Else
					  	   	cQuery += ".And. F2_TIPO <> 'N' "                  
		               EndIf
	               EndIf
	
				   If !Empty(cCliente)
				      cQuery += " .And. F2_CLIENTE == '" + cCliente + "' "
				   EndIf
				   If !Empty(cLoja)
					  cQuery += " .And. F2_LOJA    == '" + cLoja    + "' "
				   EndIf
				   If !Empty(dDataDe)
					  cQuery += " .And. DtoS(F2_EMISSAO) >= '" + DtoS(dDataDe)  + "'"
				   EndIf
				   If !Empty(dDataAte)
					  cQuery += " .And. DtoS(F2_EMISSAO) <= '" + DtoS(dDataAte) + "' "
				   EndIf         
				   If lFlagDev                                                        
					   cQuery += " .And. F2_FLAGDEV <> '1' "
				   Endif
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para passar por parametro as informacoes na MaWndBrowse³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRotina[1,2] :=	 StrTran(aRotina[1,2],"cNomeCdx","'" + cIndex + "'")
	   			cQrDvF2 := cQuery
	
				IndRegua("SF2",cIndex,SF2->(IndexKey()),,cQuery)
				If SF2->(!Eof())
					MaWndBrowse(0, 0, 300, 600, "Retorno de Doctos. de Saída", "SF2", , aRotina, , , , .T., , , , , , .F.) //"Retorno de Doctos. de Saida"
				Else
					
					RecLock(_cTab1, .F.)
						
						(_cTab1)->&(_cCmp1 + "_ERRO") := "Retornar: Não foram encontradas Notas Fiscais de Saída para retornar."
						
					(_cTab1)->( MSUnlock() )
				EndIf
				RetIndex( "SF2" )
				FErase( cIndex+OrdBagExt() )
			EndIf
		EndIf
	EndIf
	
	Inclui := !Inclui

Return .T.

////////////////////////////////////////

Static Function GO103FRet(lCliFor,dDataDe,dDataAte,lFilCliFor,lAllCliFor)
	
	Local oDlgEsp
	Local oCliente
	Local oFornece
	Local oDocto
	Local lDocto    := .T.
	Local lMotObrig := X3Obrigat("F1_MOTRET")
	Local nOpcao    := 0
	Local aSize     := MsAdvSize(.F.)
	Local lTCliFor  := .F.  // CNPJ para ambos os cadastros.
	
	Local cNumNota := (_cTab1)->&(_cCmp1 + "_DOC")
	Local cSerNota := (_cTab1)->&(_cCmp1 + "_SERIE")
	
	Private cCodCli  := CriaVar("F2_CLIENTE",.F.)
	Private cLojCli  := CriaVar("F2_LOJA",.F.)
	Private cCodFor  := CriaVar("F1_FORNECE",.F.)
	Private cLojFor  := CriaVar("F1_LOJA",.F.)
	Private cDescRet := CriaVar("DHI_DESCRI",.F.)
	Private cMotRet  := CriaVar("DHI_CODIGO",.F.)
	Private cHistRet := CriaVar("F1_HISTRET",.F.)
	Private oMemoRet := Nil
	
	SA2->( dbSetOrder(3) )
	SA1->( dbSetOrder(3) )
	If SA1->( dbSeek(xFilial("SA1") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) ) .And. SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) )
		
		nCliFor := 1
		
		DEFINE MSDIALOG oDlgEsp From 0,0 To 250, 400 OF oMainWnd PIXEL TITLE "Fornecedor/Cliente"
			
			@ 35,005 SAY "Retorno de Cliente ou Fornecedor?" PIXEL Of oDlgEsp
			
			oRadio := TRadMenu():New(45, 8, {'Fornecedor', 'Cliente'},, oDlgEsp,,,,,,,, 100,100,,,,.T.)
			oRadio:bSetGet := {|u|Iif (PCount()==0, nCliFor, nCliFor:=u)}
			
		ACTIVATE MSDIALOG oDlgEsp CENTERED ON INIT EnchoiceBar(oDlgEsp, {||oDlgEsp:End()},{||oDlgEsp:End()})

		lTCliFor := .T.
		
		// CLIENTE
		If nCliFor == 2
		
			cCodCli  := SA1->A1_COD
			cLojCli  := SA1->A1_LOJA
			cCodFor  := CriaVar("F1_FORNECE",.F.)
			cLojFor  := CriaVar("F1_LOJA",.F.)

			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1 + "_CODEMI") := SA1->A1_COD
				(_cTab1)->&(_cCmp1 + "_LOJEMI") := SA1->A1_LOJA
			(_cTab1)->( MsUnlock() )
			
		// FORNECEDOR
		Else
		
			cCodCli  := CriaVar("F2_CLIENTE",.F.)
			cLojCli  := CriaVar("F2_LOJA",.F.)
			cCodFor  := SA2->A2_COD
			cLojFor  := SA2->A2_LOJA
			
			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1 + "_CODEMI") := SA2->A2_COD
				(_cTab1)->&(_cCmp1 + "_LOJEMI") := SA2->A2_LOJA
			(_cTab1)->( MsUnlock() )
			
		EndIf
	
	EndIf
	
		// CLIENTE - Se não tiver em ambos os cadastros e não estiver na SA2, é cliente
		SA2->( dbSetOrder(3) )
		If !lTCliFor .And. !SA2->( dbSeek(xFilial("SA2") + (_cTab1)->&(_cCmp1 + "_CGCEMI")) )
			
			cCodCli  := (_cTab1)->&(_cCmp1 + "_CODEMI")
			cLojCli  := (_cTab1)->&(_cCmp1 + "_LOJEMI")
			cCodFor  := CriaVar("F1_FORNECE",.F.)
			cLojFor  := CriaVar("F1_LOJA",.F.)
	
		// FORNECEDOR - Se não tiver em ambos os cadastros e estiver na SA2, é fornecedor
		ElseIf !lTCliFor
			
			cCodCli  := CriaVar("F2_CLIENTE",.F.)
			cLojCli  := CriaVar("F2_LOJA",.F.)
			cCodFor  := (_cTab1)->&(_cCmp1 + "_CODEMI")
			cLojFor  := (_cTab1)->&(_cCmp1 + "_LOJEMI")
			
		EndIf
	
	DEFINE MSDIALOG oDlgEsp From aSize[7],0 To aSize[6]/1.5,aSize[5]/2 OF oMainWnd PIXEL TITLE "Seleção Notas"
		
		@ 06,005 SAY RetTitle("F1_DOC")   PIXEL
		@ 05,040 MSGET cNumNota SIZE 95,10 OF oDlgEsp PIXEL WHEN .F.
		 
		@ 06,145 SAY RetTitle("F1_SERIE") PIXEL
		@ 05,160 MSGET cSerNota SIZE 25,10 OF oDlgEsp PIXEL WHEN .F.
		
		If Empty(cCodFor) .Or. Empty(cLojFor)
			@ 21,005 SAY RetTitle("F2_CLIENTE") PIXEL
			@ 20,040 MSGET cCodCli F3 'SA1' SIZE 95,10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA1',cCodCli+RTrim(cLojCli),1)  WHEN .F.
			
			@ 21,145 SAY RetTitle("F2_LOJA") PIXEL
			@ 20,160 MSGET cLojCli SIZE 20,10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA1',cCodCli+RTrim(cLojCli),1)  WHEN .F.
	
		Else
			@ 21,005 SAY RetTitle("F1_FORNECE") PIXEL
			@ 20,040 MSGET cCodFor F3 'FOR' SIZE 95, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA2',cCodFor+RTrim(cLojFor),1)  WHEN .F.
			
			@ 21,145 SAY RetTitle("F1_LOJA") PIXEL
			@ 20,160 MSGET cLojFor SIZE 20, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA2',cCodFor+RTrim(cLojFor),1) WHEN .F.
	
		EndIf
		
		@ 36, 05 SAY "Data de" PIXEL
		@ 35,40 MSGET dDataDe PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL
	
		@ 36, 120 SAY "Data até" PIXEL
		@ 35,160 MSGET dDataAte PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL
	
		@ 060,005 TO __DlgHeight(oDlgEsp)-120,__DlgWidth(oDlgEsp)-5 LABEL "Tipo de Seleção" OF oDlgEsp PIXEL // 'Tipo de Selecao'
		
		//-- 'Cliente'
		@ 75,010 CHECKBOX oCliente VAR lCliFor PROMPT IIf(Empty(cCodFor) .Or. Empty(cLojFor), AllTrim(RetTitle("F2_CLIENTE")), AllTrim(RetTitle("F1_FORNECE"))) SIZE 100,010 ON CLICK( lDocto := .F., oDocto:Refresh() ) OF oDlgEsp PIXEL
		//-- 'Documento'
		@ 75,__DlgWidth(oDlgEsp)-60 CHECKBOX oDocto VAR lDocto PROMPT OemToAnsi("Documento") SIZE 50,010 ON CLICK( lCliFor := .F., oCliente:Refresh() ) OF oDlgEsp PIXEL
		
		@ __DlgHeight(oDlgEsp)-110,005 TO __DlgHeight(oDlgEsp)-025,__DlgWidth(oDlgEsp)-5 LABEL "Motivo do retorno" OF oDlgEsp PIXEL // 'Motivo do retorno'
		
		@ __DlgHeight(oDlgEsp)-94,010 SAY RetTitle("F1_MOTRET") PIXEL
		@ __DlgHeight(oDlgEsp)-95,040 MSGET cMotRet SIZE 95, 10 OF oDlgEsp F3 "DHI" PIXEL VALID;
		 (cDescRet:=Posicione("DHI",1,xFilial("DHI")+cMotRet,"DHI_DESCRI"), Vazio() .Or. ExistCpo('DHI',cMotRet,1))
		
		@ __DlgHeight(oDlgEsp)-95,145 MSGET cDescRet SIZE __DlgWidth(oDlgEsp)-165, 10 OF oDlgEsp PIXEL VALID Vazio() WHEN .F.
		
		@ __DlgHeight(oDlgEsp)-70,010 SAY RetTitle("F1_HISTRET") PIXEL
		@ __DlgHeight(oDlgEsp)-71,040 GET oMemoRet VAR cHistRet Of oDlgEsp MEMO size __DlgWidth(oDlgEsp)-60,37 pixel
	
	
	DEFINE SBUTTON FROM 05,__DlgWidth(oDlgEsp)-35 TYPE 1 OF oDlgEsp ENABLE PIXEL ACTION ;
	Eval({||cCliente := IIF(Empty(cCodCli),cCodFor,cCodCli),;
			cLoja    := IIF(Empty(cLojCli),cLojFor,cLojCli),;
			IIF(Empty(cCliente).And.Empty(cLoja),lAllCliFor:=.T.,lAllCliFor:=.F.),;
			IIF(!Empty(cCodCli),lFilCliFor:=.T.,lFilCliFor:=.F.),.t.}).and.;
			If(Iif(!Empty(cMotRet),.T.,Iif(lMotObrig,(MsgAlert("Informe um código de motivo valido."),.F.),.T.)) .And.	; //"Informe um código de motivo valido."
				((!Empty(cCliente)     .And.	;
				!Empty(cLoja)		 .And.	;
				!Empty(dDataDe)		 .And.	;
				!Empty(dDataAte)	 .And. 	;
				lCliFor)			 .Or.	;
				lDocto),(GoXSetRet(cMotRet,cHistRet),nOpcao := 1,oDlgEsp:End()),.F.)
			
	DEFINE SBUTTON FROM 20,__DlgWidth(oDlgEsp)-35 TYPE 2 OF oDlgEsp ENABLE PIXEL ACTION (nOpcao := 0,oDlgEsp:End())
	
	ACTIVATE MSDIALOG oDlgEsp CENTERED

Return ( nOpcao == 1 )

Static Function GoXSetRet(cMotRet, cHistRet)
	
	cMT103Mot  := cMotRet
	cMT103Hist := cHistREt
	
Return

////////////////////////////////////////

Static Function Go103RetNF(aCpoSF2,dDataDe,dDataAte,lFilCliFor,lAllCliFor)
	
	Local aSF2      := {}
	Local aAux      := {}
	Local nCnt      := 0
	Local cAliasSF2 := 'SF2'
	Local cQuery    := ''
	Local cIndex    := ''
	Local nIndexSF2 := 0
	Local lFlagDev	:= GetNewPar("MV_FLAGDEV",.F.)
	
	cAliasSF2 := GetNextAlias()
	If ExistBlock("MT103DEV")//Ponto de entrada para complemento de filtro na query
       cQuery := ExecBlock("MT103DEV",.F.,.F.,{dDataDe,dDataAte})
    Else
	   cQuery := " SELECT * "
	   cQuery += "   FROM " + RetSqlName("SF2")
	   cQuery += "   WHERE F2_FILIAL  = '" + xFilial("SF2") + "' "
	   cQuery += "     AND F2_TIPO <> 'D' "

       If !lAllCliFor
	       If lFilCliFor 		
	          cQuery += " AND F2_TIPO <> 'B' "
	       Else
	          cQuery += " AND F2_TIPO <> 'N' "                  
	       EndIf
       EndIf

	   cQuery += "     AND F2_CLIENTE = '" + cCliente + "' "
	   cQuery += "     AND F2_LOJA    = '" + cLoja    + "' "
	   cQuery += "     AND F2_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
	   If lFlagDev
		   cQuery += "     AND F2_FLAGDEV <> '1' "
	   Endif
	   cQuery += "     AND D_E_L_E_T_ = ' ' "
	   cQuery += "     ORDER BY F2_FILIAL,F2_DOC,F2_SERIE "
	EndIf
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSF2, .F., .T. )

	While (cAliasSF2)->(!Eof())
		aAux := {}
		Aadd( aAux, .F. )
		For nCnt := 1 To Len(aCpoSF2)
			Aadd( aAux, &(aCpoSF2[nCnt]) )
		Next nCnt
		aAdd( aSF2, aClone(aAux) )
		(cAliasSF2)->(DbSkip())
	EndDo

	(cAliasSF2)->(DbCloseArea())

Return aSF2

////////////////////////////////////////

User Function GO103PrD(cAlias, nReg, nOpcx, lCliente, cCliente, cLoja, cDocSF2)
	
	Local aArea     := GetArea()
	Local aAreaSF2  := SF2->(GetArea())
	Local aCab      := {}
	Local aLinha    := {}
	Local aItens    := {}
	Local cTipoNF   := ""
	Local lDevolucao:= .T.
	Local lPoder3   := .T.
	Local aHlpP		:=	{}
	Local aHlpE		:=	{}
	Local aHlpS		:=	{} 
	Local lFlagDev	:= GetNewPar("MV_FLAGDEV",.F.)
	Local cIndex	:= ""  
	Local lRestDev	:= .T.
	Local nPFreteI  := 0
	Local nPFreteC  := 0
	Local nPSegurI  := 0
	Local nPSegurC  := 0
	Local nPDespI   := 0
	Local nPDespC   := 0
	Local nX        := 0 
	Local cMvNFEAval :=	GetNewPar( "MV_NFEAFSD", "000" )
	Local nHpP3     := 0
	Local lHelpTES  := .T.
	Local cEspecie	:= "NF"
	
	Local cOrigImpF        := AllTrim(GetNewPar("MV_ZGOORIF", ""))
	Local cOrigImpD        := AllTrim(GetNewPar("MV_ZGOORID", ""))
	
	Default lCliente := .F.
	Default cCliente := SF2->F2_CLIENTE
	Default cLoja    := SF2->F2_LOJA
	Default cDocSF2  := ''                                
	Default	cQrDvF2  := ''
	
	If Type("cTipo") == "U"
		PRIVATE cTipo:= ""
	EndIf
	
	If Empty(cQrDvF2)
		cQrDvF2 := "F2_FILIAL == '" + xFilial("SF2") + "' "
		cQrDvF2 += ".AND. F2_TIPO <> 'D' "
	Endif
	
	If !SF2->(Eof())
	
		lDevolucao := Go103FilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,,@nHpP3,@lHelpTES,@cEspecie)
		
		If lDevolucao .and. Len(aItens)>0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd(aCab, {"F1_DOC", (_cTab1)->&(_cCmp1 + "_DOC"), Nil})	// Numero da NF : Obrigatorio
				AAdd(aCab, {"F1_SERIE", (_cTab1)->&(_cCmp1 + "_SERIE"), Nil})	// Serie da NF  : Obrigatorio
			
			If !lPoder3
				AAdd( aCab, { "F1_TIPO"   , "D"                  		, Nil } )	// Tipo da NF   : Obrigatorio
			Else
				AAdd( aCab, { "F1_TIPO"   , IIF(cTipoNF=="B","N","B")	, Nil } )	// Tipo da NF   : Obrigatorio		
			EndIf
			
			AAdd( aCab, { "F1_FORNECE", cCliente    				, Nil } )	// Codigo do Fornecedor : Obrigatorio
			AAdd( aCab, { "F1_LOJA"   , cLoja    	   		   	    , Nil } )	// Loja do Fornecedor   : Obrigatorio
				AAdd(aCab, {"F1_EMISSAO", (_cTab1)->&(_cCmp1 + "_DTEMIS"), Nil})  // Emissao da NF        : Obrigatorio
				AAdd(aCab, {"F1_FORMUL" , "N"                            , Nil})  // Formulario
			
			
				AAdd(aCab, {"F1_ESPECIE", cEspNFe})                               // Especie
			AAdd( aCab, { "F1_FRETE",0,Nil})
			AAdd( aCab, { "F1_SEGURO",0,Nil})
			AAdd( aCab, { "F1_DESPESA",0,Nil})	
				AAdd(aCab, {"F1_CHVNFE" , (_cTab1)->&(_cCmp1 + "_CHAVE") , Nil})	
				
			If !Empty(cOrigImpF) // Origem do Lançamento
				
				AAdd(aCab, {cOrigImpF, "GOX001", Nil})
				
			EndIf
			
	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Agrega o Frete/Desp/Seguro  referente a NF Retornada  ³
			//| de acordo com o parametro MV_NFEAFSD 				  ³
			//ÀÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
			nPFreteC := aScan(aCab,{|x| AllTrim(x[1])=="F1_FRETE"})
			nPFreteI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_VALFRE"})
	   		nPSegurC := aScan(aCab,{|x| AllTrim(x[1])=="F1_SEGURO"})
			nPSegurI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_SEGURO"})
	   		nPDespC := aScan(aCab,{|x| AllTrim(x[1])=="F1_DESPESA"})
			nPDespI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_DESPESA"})
			    
			For nX = 1 to Len(aItens)
			    If len(cMvNFEAval)>=1
			        If Substr(cMvNFEAval,1,1)=="1"
	  		   			aCab[nPFreteC][2] := aCab[nPFreteC][2] + aItens[nX][nPFreteI][2]
	  		  	    EndIf
	  		  	EndIf
	  		  	If len(cMvNFEAval)>=2
			        If Substr(cMvNFEAval,2,1)=="1"
	  		    		aCab[nPSegurC][2] := aCab[nPSegurC][2] + aItens[nX][nPSegurI][2]
	  		  	    EndIf
	  		  	EndIf
	   		  	If len(cMvNFEAval)=3
			        If Substr(cMvNFEAval,3,1)=="1"
	  		    		aCab[nPDespC][2] := aCab[nPDespC][2] + aItens[nX][nPDespI][2]
	  		  	    EndIf
	  		  	EndIf
					
				If !Empty(cOrigImpD) // Origem do Lançamento
					
					AAdd(aItens[nX], {cOrigImpD, "GOX001", Nil})
					
				EndIf
					
			Next nX
			
			lMSHelpAuto := .F.
			lMSErroAuto := .F.
			
			MsExecAuto({|x, y, z, w| Mata103(x, y, z, w)}, aCab, aItens, 3, .T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se nao ha mais saldo para devolucao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA" .And. lFlagDev
					lRestDev := GO103FilDv(@aLinha, @aItens, cDocSF2, cCliente, cLoja, lCliente, @cTipoNF, @lPoder3, .F.)		
				If !lRestDev
					RecLock("SF2",.F.)
					SF2->F2_FLAGDEV := "1"
					MsUnLock()
				Endif         
			Endif
		Else
			If !lAtivo 
				FwAlertInfo("Este tipo de nota não pode utilizar TES movimentando ativo.", "Erro") //"Este tipo de nota não pode utilizar TES movimentando ativo."
			Endif
			
			If lHelpTES .And. !lDevolucao .And. !lPoder3 .AND. lAtivo
				Help(" ", 1, "TESPOD3")
			EndIf
			/*
			nHpP3 = Situacao 0 -> Mostra a mensagem
			nHpP3 = Situacao 1 -> Nao mostra a mensagem
			*/
			If (nHpP3 == 0) .And. lPoder3
				Help(" ",1,"NFDGSPTZ")	//Nota Fiscal de Devolução já gerada ou o saldo devedor em poder de terceiro está zerado.
			EndIf
		EndIf
		
		MsUnLockAll()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Refaz o filtro quando a selecao e por documento, visto que a tela com os³
		//³documentos que podem ser devolvidos e montada novamente.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lCliente
			DbSelectArea("SF2")
			SF2->(dbSetOrder(1))
			cIndex := CriaTrab(NIL,.F.)
			IndRegua("SF2",cIndex,SF2->(IndexKey()),,cQrDvF2)
		Endif
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a entrada da rotina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aAreaSF2)
	RestArea(aArea)
	
Return(.T.)

////////////////////////////////////////

User Function GO103DvF(cIndex)

	Local nRecSF2 := SF2->( Recno() )
	RetIndex("SF2")
	FErase(cIndex + OrdBagExt())

	SF2->( MsGoto(nRecSF2) )

Return

////////////////////////////////////////

Static Function GO103FilDv(aLinha,aItens,cDocSF2,cCliente,cLoja,lCliente,cTipoNF,lPoder3,lHelp,nHpP3,lHelpTES,cEspecie)

Local cAliasSD2 := "SD2"
Local cAliasSF4 := "SF4"
Local nSldDev   := 0
Local nSldDevAux:= 0  
Local nDesc     := 0
Local nTotal	:= 0
Local lDevolucao:= .T.
Local lQuery    := .F.
Local lMt103FDV := ExistBlock("MT103FDV")
Local lDevCode	:= .F.
Local cCfop     := ""
Local cFilSX5   := xFilial("SX5")
Local cNFORI  	:= ""
Local cSERIORI	:= ""
Local cITEMORI	:= ""
Local nVlCompl  := 0
Local aAreaAnt  := {}
Local aSaldoTerc:= {}

Local lCompl    := (GetNewPar("MV_RTCOMPL","S") == "S")

Local nTpCtlBN  :=  A410CtEmpBN()
Local cNewDSF2	:= ""
Local cDSF2Aux	:= ""
Local nPosDiv	:= 0
Local nX		:= 0
Local lTravou	:= .F.
Local lExit		:= .F.
Local aStruSD2  := {}
Local cQuery    := ""
Local cAliasCpl := ""

Default lHelp := .T.
Default lHelpTES := .T.

If !Empty(cDocSF2)												// Selecao foi feita por "Cliente/Fornecedor"

		cNewDSF2 := StrTran(StrTran(cDocSF2,"('",),"')",)		// Retira parêteses e aspas da string do documento, caso houver
	
	nPosDiv := At("','",cNewDSF2)								// String ',' identifica que foi selecionada mais de uma nota de saida
	If nPosDiv == 0												// Se foi selecionada apenas uma nota de saida
		DbSelectArea("SF2")
		DbSetOrder(1)
		If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
			lTravou := SoftLock("SF2")							// Tenta reservar o registro para prosseguir com o processo
		Else
			dbGoTop()
		EndIf
	Else														// Se foi selecionada mais de uma nota de saida 
		cDSF2Aux := cNewDSF2
		For nX := 1 to Len(cDSF2Aux)
			nPosDiv := At("','",cDSF2Aux)
			If nPosDiv > 0
				cNewDSF2 := SubStr(cDSF2Aux,1,(nPosDiv-1))		// Extrai a primeira nota/serie da string
				cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+3),Len(cDSF2Aux)) // Grava nova string sem a primeira nota/serie
			Else
				cNewDSF2 := cDSF2Aux
				lExit := .T.
			EndIf
			If !Empty(cNewDSF2)
				DbSelectArea("SF2")
				DbSetOrder(1)
				If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
					lTravou := SoftLock("SF2")					// Tenta reservar todos os registros para prosseguir com o processo
				Else
					dbGoTop()
				EndIf
			EndIf
			If lExit
				Exit
			EndIf
		Next nX
	EndIf
Else
	lTravou := SoftLock("SF2")
EndIf

If lTravou

	If !Empty(SF2->F2_ESPECIE)
		cEspecie := SF2->F2_ESPECIE
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem dos itens da Nota Fiscal de Devolucao/Retorno          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD2")
	DbSetOrder(3)

		lQuery    := .T.
		cAliasSD2 := "Oms320Dev"
		cAliasSF4 := "Oms320Dev"
		aStruSD2  := SD2->(dbStruct())
		cQuery    := "SELECT SF4.F4_CODIGO, SF4.F4_CF, SF4.F4_PODER3, SF4.F4_QTDZERO, SF4.F4_ATUATF, SD2.*, "
		cQuery    += " SD2.R_E_C_N_O_ SD2RECNO "
		cQuery    += " FROM "+RetSqlName("SD2")+" SD2,"
		cQuery    += RetSqlName("SF4")+" SF4 "
		cQuery    += " WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
		If !lCliente
			cQuery    += "SD2.D2_DOC   = '"+SF2->F2_DOC+"' AND "
			cQuery    += "SD2.D2_SERIE = '"+SF2->F2_SERIE+"' AND "   
		Else
			If !Empty(cDocSF2)     
				If UPPER(Alltrim(TCGetDb()))=="POSTGRES" 
					cQuery += " Concat(D2_DOC,D2_SERIE) IN "+cDocSF2+" AND "
				Else
					cQuery += " D2_DOC||D2_SERIE IN "+cDocSF2+" AND "
				EndIf
			EndIf
		EndIf
		cQuery    += " SD2.D2_CLIENTE   = '"+cCliente+"' AND "
		cQuery    += " SD2.D2_LOJA      = '"+cLoja+"' AND "
		cQuery    += " ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
		cQuery    += " (SD2.D2_VALDEV  = 0) OR "
		cQuery    += " (SF4.F4_QTDZERO = '1' AND SD2.D2_VALDEV < SD2.D2_TOTAL)) AND "
		cQuery    += " SD2.D_E_L_E_T_  = ' ' AND "
		cQuery    += " SF4.F4_FILIAL   = '"+xFilial("SF4")+"' AND "
		cQuery    += " SF4.F4_CODIGO   = (SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
		cQuery    += " F4_FILIAL	   = '"+xFilial("SF4")+"' AND "
		cQuery    += " F4_CODIGO	   = SD2.D2_TES AND "
		cQuery    += " D_E_L_E_T_	   = ' ' ) AND "
		cQuery    += " SF4.D_E_L_E_T_  = ' ' "
		cQuery    += " ORDER BY "+SqlOrder(SD2->(IndexKey()))	

		cQuery    := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2]<>"C"
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX

		If Eof()    
			If lHelp  
				Help(" ",1,"DSNOTESDT")
				nHpP3 := 1
			Endif
			lDevolucao := .F.
			lHelpTES   := .F.
		EndIf

	While !Eof() .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And.;
			(cAliasSD2)->D2_CLIENTE 		   == cCliente 		  .And.;
			(cAliasSD2)->D2_LOJA			   == cLoja 		  .And.;
			If(!lCliente,(cAliasSD2)->D2_DOC  == SF2->F2_DOC     .And.;
			(cAliasSD2)->D2_SERIE			   == SF2->F2_SERIE,.T.)

		If ((cAliasSD2)->D2_QTDEDEV < (cAliasSD2)->D2_QUANT) .Or. ((cAliasSD2)->D2_VALDEV == 0) .Or. ((cAliasSD2)->F4_QTDZERO == "1" .And. (cAliasSD2)->D2_VALDEV < (cAliasSD2)->D2_TOTAL)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe um tes de devolucao correspondente           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lQuery
				DbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
					If Empty(SF4->F4_TESDV) .Or. !(SF4->(MsSeek(xFilial("SF4")+SF4->F4_TESDV)))
						lDevolucao := .F.
						Exit
					EndIf
					If SF4->F4_PODER3<>"D"
						lPoder3 := .F.
					EndIf
					If lPoder3 .And. !cTipo$"B|N"
						cTipo := IIF(cTipoNF=="B","N","B")
					ElseIf !cTipo$"B|N"
						cTipo := "D"
					EndIf
				EndIf
			Else
				If (cAliasSD2)->F4_PODER3<>"D"
					lPoder3 := .F.
				EndIf
				If lPoder3 .And. !cTipo$"B|N"
					cTipo := IIF(cTipoNF=="B","N","B")
				ElseIf !cTipo$"B|N"
					cTipo := "D"
				EndIf
				If (cAliasSD2)->F4_ATUATF = "S" .AND. cTipo$"B|D"
					lAtivo     := .F.
					Exit
				Endif				
			EndIf
			If !lMt103FDV .Or. ExecBlock("MT103FDV",.F.,.F.,{cAliasSD2})
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Destroi o Array, o mesmo é carregado novamente pela CalcTerc    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If Len(aSaldoTerc)>0 
					aSize(aSaldoTerc,0)
				EndIf 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o Saldo a devolver                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				cTipoNF := (cAliasSD2)->D2_TIPO
				
				Do Case
					Case (cAliasSF4)->F4_PODER3=="D"
						aSaldoTerc := CalcTerc((cAliasSD2)->D2_COD,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_IDENTB6,(cAliasSD2)->D2_TES,cTipoNF)
						nSldDev :=iif(Len(aSaldoTerc)>0,aSaldoTerc[1],0)
					Case cTipoNF == "N"
						nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
					Case cTipoNF == "B" .And.(cAliasSF4)->F4_PODER3 =="N" .And. GO103DvPdr((cAliasSF4)->F4_CODIGO)
						nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
						lPoder3 := .T.
					OtherWise
						nSldDev := 0
				EndCase

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetua a montagem da Linha                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nSldDev > 0 .Or. (cTipoNF$"CIP" .And. (cAliasSD2)->D2_VALDEV == 0) .Or.;
				   ( (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_VALDEV == 0 .And. (cAliasSD2)->D2_TOTAL > 0 ) .Or.;
					( (cAliasSD2)->F4_QTDZERO == "1" .And. (cAliasSD2)->D2_VALDEV < (cAliasSD2)->D2_TOTAL )

					lDevCode := .T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se deve considerar o preco das notas de complemento    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCompl
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe nota de complemento de preco                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lQuery
							aAreaAnt  := GetArea()
							cAliasCpl := GetNextAlias()
							cQuery    := "SELECT SUM(SD2.D2_PRCVEN) AS D2_PRCVEN "
							cQuery    += "  FROM "+RetSqlName("SD2")+" SD2 "
							cQuery    += " WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
							cQuery    += "   AND SD2.D2_TIPO    = 'C' "
							cQuery    += "   AND SD2.D2_NFORI   = '"+SF2->F2_DOC+"'"
							cQuery    += "   AND SD2.D2_SERIORI = '"+SF2->F2_SERIE+"'"
							cQuery    += "   AND SD2.D2_ITEMORI = '"+(cAliasSD2)->D2_ITEM +"'"
							cQuery    += "   AND ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
							cQuery    += "       (SD2.D2_VALDEV = 0))"
							cQuery    += "   AND SD2.D2_TES         = '"+(cAliasSD2)->D2_TES+"'"
							cQuery    += "   AND SD2.D_E_L_E_T_     = ' ' "
					
							cQuery    := ChangeQuery(cQuery)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCpl,.T.,.T.)
	
							TcSetField(cAliasCpl,"D2_PRCVEN","N",TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2])
	
							If !(cAliasCpl)->(Eof())
								nVlCompl := (cAliasCpl)->D2_PRCVEN
							Else
								nVlCompl := 0
							EndIf
	
							(cAliasCpl)->(dbCloseArea())
							RestArea(aAreaAnt)
						Else
							aAreaSD2 := SD2->(GetArea())
							SD2->(dbSetOrder(3))
							cIndexCpl := CriaTrab(NIL,.F.)
							cQuery := "       SD2->D2_FILIAL  == '" + xFilial("SD2") + "' "
							cQuery += " .And. SD2->D2_TIPO    == 'C' "
							cQuery += " .And. SD2->D2_NFORI   == '"+SF2->F2_DOC   +"' "
							cQuery += " .And. SD2->D2_SERIORI == '"+SF2->F2_SERIE +"' "
							cQuery += " .And. AllTrim(SD2->D2_ITEMORI) == '"+(cAliasSD2)->D2_ITEM +"' "
							cQuery += " .And. SD2->D2_TES     == '"+(cAliasSD2)->D2_TES+"' "
	
							IndRegua("SD2",cIndexCpl,SD2->(IndexKey()),,cQuery)
							SD2->(DbGotop())
							
							nVlCompl := 0
							While !SD2->(Eof())							
								nVlCompl += SD2->D2_PRCVEN
								SD2->(dbSkip())
							EndDo
							
						    nIndex := RetIndex("SD2")
							FErase( cIndexCpl+OrdBagExt() )
	
						    If lCliente
								dbSetIndex(cIndex+OrdBagExt())
								dbSetOrder(nIndex+1)
                            EndIf
	
							RestArea(aAreaSD2)
						EndIf
					EndIf
		
					aLinha := {}				
					nDesc  := 0
	  				AAdd( aLinha, { "D1_COD"    , (cAliasSD2)->D2_COD    , Nil } )
					AAdd( aLinha, { "D1_QUANT"  , nSldDev, Nil } )					
					If (cAliasSD2)->D2_QUANT==nSldDev
						If Len(aSaldoTerc)=0   // Nf sem Controle Poder Terceiros                      
							If ((cAliasSD2)->F4_QTDZERO == "1" .And. (cAliasSD2)->D2_VALDEV < (cAliasSD2)->D2_TOTAL)
								AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_PRCVEN - (cAliasSD2)->D2_VALDEV), Nil })
							ElseIf (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
							   	AAdd( aLinha, { "D1_VUNIT"  , (cAliasSD2)->D2_PRCVEN, Nil })
							Else 
							    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
								AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_TOTAL+nDesc)/(cAliasSD2)->D2_QUANT, Nil })
							EndIf
						Else                   // Nf com Controle Poder Terceiros 
							If (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
								AAdd( aLinha, { "D1_VUNIT"  , (aSaldoTerc[5]-aSaldoTerc[4])/nSldDev, Nil })
							Else
							    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
							    nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
								AAdd( aLinha, { "D1_VUNIT"  , ((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev, Nil })
							EndIf
						EndIf
						nTotal:= A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL")
						If nTotal == 0 .And. (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_PRCVEN == (cAliasSD2)->D2_TOTAL
							If (cAliasSD2)->F4_QTDZERO == "1"
								nTotal := (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_VALDEV
							Else
								nTotal := (cAliasSD2)->D2_TOTAL
							EndIf
						EndIf
	 					AAdd( aLinha, { "D1_TOTAL"  , nTotal,Nil } )						
						AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )
						AAdd( aLinha, { "D1_DESC", (cAliasSD2)->D2_DESC , Nil } )					
						AAdd( aLinha, { "D1_VALFRE", (cAliasSD2)->D2_VALFRE, Nil } )  
						AAdd( aLinha, { "D1_SEGURO", (cAliasSD2)->D2_SEGURO, Nil } )  
						AAdd( aLinha, { "D1_DESPESA", (cAliasSD2)->D2_DESPESA, Nil } )
					Else
						nSldDevAux:= (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
						If Len(aSaldoTerc)=0	// Nf sem Controle Poder Terceiros  
						    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
						    nDesc:=iif(nDesc>0,(nDesc/(cAliasSD2)->D2_QUANT)*IIf(nSldDevAux==0,1,nSldDevAux),0)
						    AAdd( aLinha, { "D1_VUNIT"  ,((((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR))-(cAliasSD2)->D2_VALDEV)/IIf(nSldDevAux==0,1,nSldDevAux), Nil })
					    Else  					// Nf com Controle Poder Terceiros
						    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
						    nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
							AAdd( aLinha, { "D1_VUNIT"  , ((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev, Nil })
					    EndIf
						
	 					AAdd( aLinha, { "D1_TOTAL"  , A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL"),Nil } )
						AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )	
						AAdd( aLinha, { "D1_DESC", (cAliasSD2)->D2_DESC , Nil } )					
						AAdd( aLinha, { "D1_VALFRE" , A410Arred(((cAliasSD2)->D2_VALFRE/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_VALFRE"),Nil } )						
						AAdd( aLinha, { "D1_SEGURO" , A410Arred(((cAliasSD2)->D2_SEGURO/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_SEGURO"),Nil } )						
						AAdd( aLinha, { "D1_DESPESA" , A410Arred(((cAliasSD2)->D2_DESPESA/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_DESPESA"),Nil } )						
					EndIf
					AAdd( aLinha, { "D1_IPI"    , (cAliasSD2)->D2_IPI    , Nil } )	
					AAdd( aLinha, { "D1_LOCAL"  , (cAliasSD2)->D2_LOCAL  , Nil } )
					AAdd( aLinha, { "D1_TES" 	, (cAliasSF4)->F4_CODIGO , Nil } )
					If ("000"$AllTrim((cAliasSF4)->F4_CF) .Or. "999"$AllTrim((cAliasSF4)->F4_CF))
						cCfop := AllTrim((cAliasSF4)->F4_CF)
					Else
                        cCfop := SubStr("123",At(SubStr((cAliasSD2)->D2_CF,1,1),"567"),1)+SubStr((cAliasSD2)->D2_CF,2)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe CFOP equivalente considerando a CFOP do documento de saida  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SX5->( dbSetOrder(1) )
						If !SX5->(MsSeek( cFilSX5 + "13" + cCfop ))
							cCfop := AllTrim((cAliasSF4)->F4_CF)
						EndIf
					EndIf
					AAdd( aLinha, { "D1_CF"		, cCfop, Nil } )
					AAdd( aLinha, { "D1_UM"     , (cAliasSD2)->D2_UM , Nil } )
                    If (nTpCtlBN != 0)
     					AAdd( aLinha, { "D1_OP" 	, A103OPBen(cAliasSD2, nTpCtlBN) , Nil } )
                    EndIf
					If Rastro((cAliasSD2)->D2_COD)
						AAdd( aLinha, { "D1_LOTECTL", (cAliasSD2)->D2_LOTECTL, ".T." } )
						If (cAliasSD2)->D2_ORIGLAN == "LO"
							If Rastro((cAliasSD2)->D2_COD,"L") .AND. !Empty((cAliasSD2)->D2_NUMLOTE)
								AAdd( aLinha, { "D1_NUMLOTE", Nil , ".T." } )							
							Else
								AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )													
							EndIf
						Else
							AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )						
						EndIf

						AAdd( aLinha, { "D1_DTVALID", (cAliasSD2)->D2_DTVALID, ".T." } )
						AAdd( aLinha, { "D1_POTENCI", (cAliasSD2)->D2_POTENCI, ".T." } )
						SB8->(dbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID
						If 	SB8->(MsSeek(xFilial("SB8")+(cAliasSD2)->D2_COD + (cAliasSD2)->D2_LOCAL + (cAliasSD2)->D2_LOTECTL + (cAliasSD2)->D2_NUMLOTE))  
								AAdd( aLinha, { "D1_DFABRIC", SB8->B8_DFABRIC, ".T." } )
						Endif
					EndIf
					cNFORI  := (cAliasSD2)->D2_DOC
					cSERIORI:= (cAliasSD2)->D2_SERIE
					cITEMORI:= (cAliasSD2)->D2_ITEM 
					If cTipo == "D"
						SF4->(dbSetOrder(1))
						If SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)) .And. SF4->F4_PODER3$"D|R"
							If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "N"
								cNFORI  := ""
								cSERIORI:= ""
								cITEMORI:= ""
								Help(" ",1,"A100NOTES")
							EndIf
							If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "R"
								cNFORI  := ""
								cSERIORI:= ""
								cITEMORI:= ""
							    Help(" ",1,"A103TESNFD")
							EndIf
						EndIf
					EndIf
					AAdd( aLinha, { "D1_NFORI"  , cNFORI   			      , Nil } )
					AAdd( aLinha, { "D1_SERIORI", cSERIORI  		      , Nil } )
					AAdd( aLinha, { "D1_ITEMORI", cITEMORI   			  , Nil } )
					AAdd( aLinha, { "D1_ICMSRET", (cAliasSD2)->D2_ICMSRET, Nil } )					
					If (cAliasSF4)->F4_PODER3=="D"
						AAdd( aLinha, { "D1_IDENTB6", (cAliasSD2)->D2_NUMSEQ, Nil } )								
					Endif

					//Obtém o valor do Acrescimo Financeiro na Nota de Origem e faz o rateio //
					If (cAliasSD2)->D2_VALACRS >0                                
						AAdd( aLinha, { "D1_VALACRS", ((cAliasSD2)->D2_VALACRS / (cAliasSD2)->D2_QUANT )*nSldDev , Nil })
					Endif

					If ExistBlock("MT103LDV")
						aLinha := ExecBlock("MT103LDV",.F.,.F.,{aLinha,cAliasSD2})
					EndIf
					
					If !(Empty((cAliasSD2)->D2_CCUSTO ))
						AAdd( aLinha, { "D1_CC"  , (cAliasSD2)->D2_CCUSTO  , Nil } )
					EndIf

					AAdd( aLinha, { "D1RECNO",    Iif(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RECNO()) ), Nil } )

					AAdd( aItens, aLinha)
				EndIf
			Else
				lHelpTes := .F.
			EndIf		
		Else
			nHpP3 := 1 
		Endif
		DbSelectArea(cAliasSD2)
		dbSkip()
	EndDo
	If lQuery
		DbSelectArea(cAliasSD2)
		dbCloseArea()
	Else
		If lCliente
			RetIndex( "SD2" )
			FErase( cIndex+OrdBagExt() )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nenhum item foi processado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDevCode
		lDevolucao := .F.
	Endif
	DbSelectArea("SD2")

Endif               

Return lDevolucao

//////////////////////////////////////////

Static Function GO103DvPdr(cTES)
	
	Local aAreaAnt := GetArea()
	Local aAreaSF4 := SF4->(GetArea())
	Local lRet := .F.
	
	SF4->(DbSetOrder(1)) // FILIAL + CODIGO
	SF4->(MsSeek(xFilial("SF4")+cTES))
	
	If !Empty(SF4->F4_TESDV)
		SF4->(MsSeek(xFilial("SF4")+SF4->F4_TESDV))
		lRet := SF4->F4_PODER3 == "N"
	Else
		lRet := .T.
	EndIf
	
	RestArea(aAreaSF4)
	RestArea(aAreaAnt)
	
Return lRet

////////////////////////////////////////

/* ####################################################################### *\
|| #    CHAMA A FUNÇÃO PADRÃO DO MATA103 PARA EXCLUIR O DOCUMENTO        # ||
\* ####################################################################### */
Static Function ExcluirDoc(lPos)

	Local aCab
	Local aItens := {}
	
	Private aRotina := {}
	
	Default lPos := .F.
	
	If lPos
	
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		
		If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
		
			If Empty(SF1->F1_STATUS)  // NÃO CLASSIFICADA
			
				aCab := {{"F1_DOC"    , SF1->F1_DOC    , Nil, Nil}, ;
				         {"F1_SERIE"  , SF1->F1_SERIE  , Nil, Nil}, ;
				         {"F1_FORNECE", SF1->F1_FORNECE, Nil, Nil}, ;
				         {"F1_LOJA"   , SF1->F1_LOJA   , Nil, Nil}, ;
				         {"F1_EMISSAO", SF1->F1_EMISSAO, Nil, Nil}}
				
				MsAguarde({|| MsExecAuto({|x, y, z, w, k| MATA140(x, y, z, w, k)}, aCab, aItens, 5, .F., 1)}, "Pré-nota de entrada", "Excluindo Pré-nota de entrada...")
				
			Else
			
				AAdd(aRotina, {"Excluir", "A103NFiscal", 3 , 5, 0, Nil})
				
				MsAguarde({|| A103NFiscal("SF1", , 1, .F., .F.)}, "Aguarde", "Preparando Documento...")
				
			EndIf
			
		// Não existe na base
		Else
		
			RecLock(_cTab1, .F.)
			
				(_cTab1)->&(_cCmp1 + "_SIT") := "1"
				
			(_cTab1)->( MsUnlock() )
			
		EndIf
		
	EndIf
	
Return

/* ####################################################################### *\
|| #    CHAMA A FUNÇÃO PADRÃO DO MATA103 PARA CLASSIFICAR O DOCUMENTO    # ||
\* ####################################################################### */
Static Function ClassDoc(lPos)
	
	Private aRotina := {}
	
	AAdd(aRotina, {"&Classificar", "A103NFiscal", 0 , 4, 0, Nil})
	Default lPos := .F.

	If lPos
		
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		
		If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
			
			If Empty(SF1->F1_STATUS)  // NÃO CLASSIFICADA
				
				Private lRetorna := .F.
				
				MsAguarde({|| A103NFiscal("SF1", , 1, .F., .F.)}, "Aguarde", "Preparando Documento...")
				Return
				
			Else
				
				Aviso("Aviso", "Por favor, selecione apenas pré-notas.", {"Ok"}, 2)
				
			EndIf
			
		EndIf
		
	EndIf
	
Return

/* ####################################################################### *\
|| #    CHAMA A FUNÇÃO PADRÃO DO MATA103 PARA ALTERAR O DOCUMENTO    # ||
\* ####################################################################### */
Static Function AlterarDoc(lPos)
	
	Private aRotina := &("StaticCall(MATA140, MenuDef)")
	
	//AAdd(aRotina, {"&Alterar", "A140NFiscal", 0 , 4, 0, Nil})
	Default lPos := .F.

	Pergunte("MTA140", .F.)
	
	// Variáveis da Rotina
	
	PRIVATE cCadastro	:= OemToAnsi("Pre-Documento de Entrada")
	PRIVATE l140Auto	:= .F.
	PRIVATE aAutoCab	:= Nil
	PRIVATE aAutoItens	:= Nil
	PRIVATE aHeadSD1    := {}
	PRIVATE l103Auto	:= l140Auto
	PRIVATE lOnUpdate	:= .T.
	PRIVATE nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
	PRIVATE a140Total := {0,0,0}
	PRIVATE a140Desp  := {0,0,0,0,0,0,0,0}

	Private oLbx  
	Private _aDivPNF := {}

	Private nVlrFrt140	:= 0
	Private aFrt140		:= {}
	PRIVATE lTOPDRFRM 	:= FindFunction("A120RDFRM") .And. A120RDFRM("A103")
	Private axCodRet 	:= {}  

	///////////////////////
	
	If lPos
		
		dbSelectArea("SF1")
		SF1->( dbSetOrder(1) )
		
		If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
			
			If Empty(SF1->F1_STATUS)  // NÃO CLASSIFICADA
				
				Private lRetorna := .F.
				
				MsAguarde({|| A140NFiscal("SF1", , 4)}, "Aguarde", "Preparando Documento...")
				
				Return
				
			Else
				
				Aviso("Aviso", "Por favor, selecione apenas pré-notas.", {"Ok"}, 2)
				
			EndIf
			
		EndIf
		
	EndIf
	
Return

/* ####################################################################### *\
|| #                         MATA 103: IMPRIMIR                          # ||
\* ####################################################################### */
Static Function Mt103Imp()

	Local aArea := SF1->( GetArea() )
	Local xRet  := .T.

	dbSelectArea("SF1")
	SF1->( dbSetOrder(1) )

	If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + SA2->A2_COD + SA2->A2_LOJA) )

		xRet := MATR170("SF1", SF1->( Recno() ))

	Else

		Aviso("Aviso", "Documento de entrada não encontrado.", {"Ok"}, 2)

	EndIf

	SF1->( RestArea(aArea) )

Return(xRet)

/* ####################################################################### *\
|| #                     FAZ A LEITURA DE UM ARQUIVO                     # ||
\* ####################################################################### */
User Function GOMEMO(cArq)
	
	Local cString := ""
	Local nHandle := 0
	
	nHandle := FOPEN(cArq, FO_READ + FO_SHARED)
	
	If nHandle == -1
		
		Return ""
		
	EndIf
	
	cString := FReadStr(nHandle, 1048476)
	
	FClose(nHandle)
	
Return cString

/* ####################################################################### *\
|| #                        AGRUPAR ITENS DA NOTA                        # ||
\* ####################################################################### */
Static Function AgrItens()

	Local aExcItNota := {}  //  Array de 2 colunas {"Posição do item no oGetD:aCols", "Pedido + Item"}
	Local aHeader    := {"", "Item XML", "Produto", "Descrição"}
	Local aItens     := {}  //  Array de 5 colunas {"Indicador de selecionado", "Item XML", "Produto", "Descrição do Produto", "Posição do Item"}
	Local aIfExtras  := {}  //  Array de 2 colunas {"Pedido + Item", "Nome de todos os itens agrupados"}
	Local aNovItNota := {}  //  Array que recebe o oGetD:aCols[nX], para montar uma nova lista pra tela
	Local lExclui    := .F.
	Local nCont      := 0
	Local nPos       := 0
	Local oDlgAgrIte, oLayerAgIt, oListAgrIt, oPanelBot, oQuit, oSel
	Local oNo        := LoadBitmap(GetResources(), "LBNO")
	Local oOk        := LoadBitmap(GetResources(), "LBOK")
	Local lSemPed    := .F.
	Local lSPPassou  := .F.
	Local nI
	Local nX
	Local nA
	Local nB
	Local nC
	
	//  VALIDAÇÕES
	For nX := 1 To Len(aPedidos)
	
		If aPedidos[nX, 1] == .T.
		
			nCont++
			
		EndIf
		
	Next nX
	
	If nCont == 0
		
		If GetNewPar("MV_ZSNPSGP", .F.)
			
			Aviso("Aviso", "Não houve seleção de itens do Pedido!", {"Ok"}, 2)
			Return .F.
			
		Else
			
			lSemPed := .T.
			
		EndIf
		
	EndIf
	
	If nCont > Len(oGetD:aCols)
	
		Aviso("Aviso", "Quantidade de itens selecionados difere da quantidade de itens da nota!", {"Ok"}, 2)
		Return .F.
		
	EndIf
	
	aSort(aPedidos, , , {|x, y| x[13] < y[13]})
	
	//  LISTA DE PEDIDOS
	For nX := 1 To Len(aPedidos)
	
		//  VALIDA PEDIDO SELECIONADO
		If aPedidos[nX, 1] .Or. lSemPed
		
			aItens := {}
			
			// LISTA DE ITENS QUE AINDA NÃO FORAM SELECIONADOS PARA EXCLUSÃO
			For nA := 1 To Len(oGetD:aCols)
			
				//  VALIDA SE ITEM JÁ ESTÁ NO ARRAY DE EXCLUSÃO PARA NÃO APRESENTAR NA TELA NOVAMENTE
				//  x[1] É A POSIÇÃO DO ITEM NO oGetD:aCols
				If AScan(aExcItNota, {|x| x[1] == nA}) == 0
				
					//  ITENS A SEREM APRESENTADOS NA TELA 'Agrupar Itens da Nota'
					AAdd(aItens, {.F., oGetD:aCols[nA, _nPosItXml], oGetD:aCols[nA, _nPosProdu], oGetD:aCols[nA, _nPosDcPrd], nA, oGetD:aCols[nA, _nPosQtdNo], oGetD:aCols[nA, _nPosUm], oGetD:aCols[nA, _nPosVlUnt], oGetD:aCols[nA, _nPosTes], oGetD:aCols[nA, _nPosAqIcm], oGetD:aCols[nA, _nPosAqIpi]})
					
				EndIf
				
			Next nA
			
			If Len(aItens) > 0
			
				DEFINE MSDIALOG oDlgAgrIte FROM 0, 0 TO 350, 630 TITLE 'Agrupar Itens da Nota' COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
				
					oDlgAgrIte:lEscClose := .F.
					
					oLayerAgIt := FWLayer():New()
					oLayerAgIt:Init(oDlgAgrIte, .F.)
					
					oLayerAgIt:AddLine('CENTER', 90, .F.)
					
						oLayerAgIt:AddCollumn('COL_CENTER', 100, .T., 'CENTER')
						
							oLayerAgIt:AddWindow('COL_CENTER', 'WIN_CENTER', IIf(lSemPed, 'Selecione os itens para agrupar sem pedido', 'Escolha os itens que compõe o "Pedido: ' + AllTrim(aPedidos[nX][2]) + ' - ' + AllTrim(aPedidos[nX][3]) + ' / Produto: ' + AllTrim(aPedidos[nX][5]) + '"'), 100, .F., .T., , 'CENTER', )
							
								oListAgrIt := TWBrowse():New(40, 05, 204, 140, , aHeader, , oLayerAgIt:GetWinPanel('COL_CENTER', 'WIN_CENTER', 'CENTER'), , , , , , , , , , , , .F., , .T., , .F., , , )
								oListAgrIt:bLDblClick := {|| IIf(lSemPed, SelItSemPed(aItens, oListAgrIt), aItens[oListAgrIt:nAt, 1] := !(aItens[oListAgrIt:nAt, 1])), oListAgrIt:Refresh()}
								oListAgrIt:SetArray(aItens)
								oListAgrIt:bLine := &('{|| {IIf(aItens[oListAgrIt:nAt, 1], oOk, oNo), ' + ;
								                               'aItens[oListAgrIt:nAt, 2], ' + ;
															   'aItens[oListAgrIt:nAt, 3], ' + ;
															   'aItens[oListAgrIt:nAt, 4]}}')
								oListAgrIt:Align := CONTROL_ALIGN_ALLCLIENT
								
					oLayerAgIt:AddLine('BOTTOM', 10, .F.)
						
						oLayerAgIt:AddCollumn('COL_BOTTOM', 100, .T., 'BOTTOM')
						
							oPanelBot := tPanel():New(0, 0, "", oLayerAgIt:GetColPanel('COL_BOTTOM', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
							oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
							
							oQuit := THButton():New(0, 0, "Cancelar", oPanelBot, {|| lExclui := .F., oDlgAgrIte:End()}, , , )
							oQuit:nWidth  := 100
							oQuit:nHeight := 10
							oQuit:Align   := CONTROL_ALIGN_RIGHT
							oQuit:SetColor(RGB(002, 070, 112), )
							
							oSel := THButton():New(0, 0, "Selecionar", oPanelBot, {|| lExclui := .T., oDlgAgrIte:End()}, , , )
							oSel:nWidth  := 110
							oSel:nHeight := 10
							oSel:Align := CONTROL_ALIGN_RIGHT
							oSel:SetColor(RGB(002, 070, 112), )
							
				ACTIVATE MSDIALOG oDlgAgrIte CENTERED
				
				//  VALIDA BOTÃO SELECIONAR
				If lExclui
				
					nCont := 0
					
					//  LISTA DE ITENS
					For nB := 1 To Len(aItens)
					
						If aItens[nB, 1]
						
							nCont++
							
						EndIf
						
					Next nB
					
					//  A QUANTIDADE DE ITENS SELECIONADOS TEM QUE SER MAIOR QUE 1, SE NÃO PERDE O SENTIDO DE 'AGRUPAR'
					If nCont <= 1
					
						Aviso("Aviso", "É necessário selecionar mais de 1 item para agrupar.", {"Ok"}, 2)
						
					Else
					
						// ADICIONA LINHA NO ARRAY E GRAVA A REFERENCIA DO PEDIDO
						AAdd(aIfExtras, {IIf(lSemPed, "", aPedidos[nX][2] + aPedidos[nX][3]), ""})
						
						//  LISTA DE ITENS
						For nC := 1 To Len(aItens)
						
							//  ITEM SELECIONADO
							If aItens[nC, 1]
							
								//  ADICIONA NA LISTA DE EXCLUSÃO
								//                  *Posição                           *Pedido    +        Item
								AAdd(aExcItNota, {aItens[nC][5], IIf(lSemPed, "", aPedidos[nX][2] + aPedidos[nX][3])})
								
								If Empty(ATail(aIfExtras)[2])
								
									//ATail(aIfExtras)[2] += " / "
									
									ATail(aIfExtras)[2] := aItens[nC][2]//AllTrim(SubStr(, 18, Len(aItens[nC][2])))  // NOME DE TODOS OS ITENS AGRUPADOS
									
								EndIf
								
								//  SOMA TODOS OS NOMES PARA APRESENTAR NO CAMPO AGRUPADOR
								//ATail(aIfExtras)[2] += AllTrim(SubStr(aItens[nC][2], 18, Len(aItens[nC][2])))  // NOME DE TODOS OS ITENS AGRUPADOS
								
							EndIf
							
						Next nC
						
					EndIf
					
				EndIf
				
			EndIf
			
			If lSemPed
				
				Exit
				
			EndIf
			
		EndIf
		
	Next nX
	
	//  VALIDA LISTA DE ITENS A SEREM EXCLUÍDOS
	If Len(aExcItNota) > 0
	
		//  LISTA DE ITENS DA TELA
		For nX := 1 To Len(oGetD:aCols)
		
			//  VALIDA SE O ITEM CONSTA NO ARRAY DE EXCLUSÃO
			If AScan(aExcItNota, {|x| x[1] == nX}) == 0
				
				//  CRIA UM NOVO ARRAY QUE NÃO CONTERÁ OS ITENS PRESENTES NO ARRAY DE EXCLUSÃO
				AAdd(aNovItNota, oGetD:aCols[nX])
				
			EndIf
			
		Next nX
		
		cPedItem := ""
		
		//  LISTA DE ITENS A SEREM EXCLUÍDOS
		For nX := 1 To Len(aExcItNota)
		
			//  CADA ITEM A SER EXCLUÍDO CONTÉM 'NÚMERO DO PEDIDO + O ITEM' QUE O SUBSTITUIRÁ
			//  AO TROCAR O ITEM DO PEDIDO, ADICIONA UM NOVO ITEM QUE SERÁ O AGRUPADOR
			//            *Pedido + Item
			If lSemPed .Or. cPedItem # aExcItNota[nX, 2]
				
				nPos := AScan(aIfExtras, {|x| x[1] == aExcItNota[nX, 2]})
				
				dbSelectArea("SC7")
				dbSetOrder(1)
				
				//  VALIDA SE PEDIDO EXISTE
				If lSemPed .Or. SC7->( dbSeek(xFilial("SC7") + aExcItNota[nX, 2]) )
					
					If !lSPPassou
						
						AAdd(aNovItNota, Array(nUsado + 1))
						
						For nI := 1 To Len(oGetD:aHeader)
							
							If oGetD:aHeader[nI][8] == "C"
								
								ATail(aNovItNota)[nI] := Space(oGetD:aHeader[nI][4])
								
							ElseIf oGetD:aHeader[nI][8] == "N"
								
								ATail(aNovItNota)[nI] := 0
								
							EndIf
							
						Next nI
						
					EndIf
					
					//ATail(aNovItNota)[_nPosOK] := "LBNO"
					
					ATail(aNovItNota)[_nPosItXml] := IIf(!Empty(nPos), aIfExtras[nPos][2], "ITEM AGRUPADO")
					
					If _nPosPedid > 0
						
						ATail(aNovItNota)[_nPosPedid] := IIf(lSemPed, "", SC7->C7_NUM)
						
					EndIf
					
					If _nPosItePc > 0
						
						ATail(aNovItNota)[_nPosItePc] := IIf(lSemPed, "", SC7->C7_ITEM)
						
					EndIf
					
					If _nPosProdu > 0
						
						ATail(aNovItNota)[_nPosProdu] := IIf(lSemPed, aItens[aExcItNota[nX, 1], 3], SC7->C7_PRODUTO)
						
					EndIf
					
					If _nPosDcPrd > 0
					
						ATail(aNovItNota)[_nPosDcPrd] := Posicione("SB1", 1, xFilial("SB1") + IIf(lSemPed, aItens[aExcItNota[nX, 1], 3], SC7->C7_PRODUTO), "B1_DESC")
						
					EndIf
					
					If _nPosUm > 0
						
						ATail(aNovItNota)[_nPosUm] := IIf(lSemPed, aItens[aExcItNota[nX, 1], 7], SC7->C7_UM)
						
					EndIf
					
					If _nPosQtdNo > 0
						
						If lSPPassou
							
							ATail(aNovItNota)[_nPosQtdNo] += aItens[aExcItNota[nX, 1], 6]
							
						Else
							
							ATail(aNovItNota)[_nPosQtdNo] := IIf(lSemPed, aItens[aExcItNota[nX, 1], 6], (SC7->C7_QUANT - SC7->C7_QUJE))
							
						EndIf
						
					EndIf
					
					If _nPosVlUnt > 0
					
						ATail(aNovItNota)[_nPosVlUnt] := IIf(lSemPed, aItens[aExcItNota[nX, 1], 8], SC7->C7_PRECO)
						
					EndIf
					
					If _nPosVlTot > 0
					
						ATail(aNovItNota)[_nPosVlTot] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, ATail(aNovItNota)[_nPosQtdNo] * ATail(aNovItNota)[_nPosVlUnt], 0)
						
					EndIf
					
					If _nPosTes > 0
						
						If nx == 1 .Or. !Empty(aItens[aExcItNota[nX, 1], 9])
							
							ATail(aNovItNota)[_nPosTes] := IIf(lSemPed, aItens[aExcItNota[nX, 1], 9], SC7->C7_TES)
							
						EndIf
						
					EndIf
					
					If _nPosCdFis > 0
					
						ATail(aNovItNota)[_nPosCdFis] := IIf(GETMV("MV_ESTADO") == cEstado, "1", "2") + SubStr(Posicione("SF4", 1, xFilial("SF4") + IIf(lSemPed, ATail(aNovItNota)[_nPosTes], SC7->C7_TES), "F4_CF"), 2, 3)
						
					EndIf
					
					If _nPosCtCus > 0
					
						ATail(aNovItNota)[_nPosCtCus] := ""
						
					EndIf
					
					If _nPosItCon > 0
					
						ATail(aNovItNota)[_nPosItCon] := ""
						
					EndIf
					
					If _nPosClVal > 0
					
						ATail(aNovItNota)[_nPosClVal] := ""
						
					EndIf
					
					If _nPosBsIcm > 0
					
						ATail(aNovItNota)[_nPosBsIcm] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, ATail(aNovItNota)[_nPosQtdNo] * ATail(aNovItNota)[_nPosVlUnt], 0)
						
					EndIf
					
					If _nPosAqIcm > 0
					
						ATail(aNovItNota)[_nPosAqIcm] := IIf(lSemPed, aItens[aExcItNota[nX, 1], 10], SC7->C7_PICM)
						
					EndIf
					
					If _nPosVlIcm > 0
					
						ATail(aNovItNota)[_nPosVlIcm] := IIf(_nPosBsIcm > 0 .And. _nPosAqIcm > 0, ATail(aNovItNota)[_nPosBsIcm] * ATail(aNovItNota)[_nPosAqIcm] / 100, 0)
						
					EndIf
					
					If _nPosBsIpi > 0
					
						ATail(aNovItNota)[_nPosBsIpi] := IIf(_nPosQtdNo > 0 .And. _nPosVlUnt > 0, ATail(aNovItNota)[_nPosQtdNo] * ATail(aNovItNota)[_nPosVlUnt], 0)
						
					EndIf
					
					If _nPosAqIpi > 0
					
						ATail(aNovItNota)[_nPosAqIpi] := IIf(lSemPed, aItens[aExcItNota[nX, 1], 11], SC7->C7_IPI)
						
					EndIf
					
					If _nPosVlIpi > 0
					
						ATail(aNovItNota)[_nPosVlIpi] := IIf(_nPosBsIpi > 0 .And. _nPosAqIpi > 0, ATail(aNovItNota)[_nPosBsIpi] * ATail(aNovItNota)[_nPosAqIpi] / 100, 0)
						
					EndIf
					
					ATail(ATail(aNovItNota)) := .F.
					
					If lSemPed
						lSPPassou := .T.
					EndIf
					
				EndIf
				
				SC7->( dbCloseArea() )
				
				cPedItem := aExcItNota[nX, 2]
				
			EndIf
			
		Next nX
		
		//  ATUALIZA A TELA COM O NOVO ARRAY, SEM OS ITENS EXCLUÍDOS E COM O NOVO ITEM AGRUPADOR
		If Len(aNovItNota) > 0
		
			oGetD:SetArray(aNovItNota, .T.)
			oGetD:Refresh()
			
		EndIf
		
	//  LISTA DE ITENS A SEREM EXCLUÍDOS VAZIA
	Else
	
		Aviso("Aviso", "É necessário selecionar algum item da nota para exclusão! Por favor, refaça o processo.", {"Ok"}, 2)
		Return .F.
		
	Endif
	
Return .T.

////////////////////////////////////////

Static Function SelItSemPed(aItens, oBrw)
	
	Local nI
	Local cProd := aItens[oBrw:nAt][3]
	
	For nI := 1 To Len(aItens)
		
		If aItens[nI][1] .And. aItens[nI][3] # cProd
			
			MsgAlert("Só é permitido agrupar produtos iguais.")
			
			Return .F.
			
		EndIf
		
	Next nI
	
	aItens[oBrw:nAt, 1] := !(aItens[oBrw:nAt, 1])
	
Return

////////////////////////////////////////

Static Function VldInfoNfe(lMsg)

	Local cNPed     := ""
	Local lNatCdPag := .F.
	Local nX
	
	Local lErro := .F.
	Local lErrIt := .F.
	
	Local lValQtd := GetNewPar("MV_ZVLQTPD", .T.)
	Local lSomaImp := GetNewPar("MV_ZVLPDIM", .F.)
	
	Local nAuxPrc
	
	Local cRaiz
	
	Local cMsgGeral := ""
	
	Default lMsg := .T.
	
	For nX := 1 To Len(oGetD:aCols)
	
		If _nPosPedid > 0
			
			// Valida o Pedido de Compra
			If !Empty(oGetD:aCols[nX, _nPosPedid])
			
				dbSelectArea("SC7")
				SC7->( dbSetOrder(1) )
				
				If !SC7->( dbSeek(xFilial("SC7") + oGetD:aCols[nX, _nPosPedid] + oGetD:aCols[nX, _nPosItePc]) )
				
					If lMsg
					
						Aviso("Aviso", "Número do Pedido de Compra informado no item " + StrZero(nX, 2) + " não foi encontrado.", {"Ok"}, 2)
						
					EndIf
					
					Return .F.
					
				Else
					
					cRaiz := Left(Posicione("SA2", 1, xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, "A2_CGC"), 8)
					
					If cRaiz # Left((_cTab1)->&(_cCmp1 + "_CGCEMI"), 8)
					
						If lMsg
						
							Aviso("Aviso", "Pedido de Compra informado no item " + StrZero(nX, 2) + " não pertence ao fornecedor selecionado!", {"Ok"}, 2)
							
						EndIf
						
						Return .F.
						
					/*ElseIf Round(oGetD:aCols[nX, _nPosVlUnt] * oGetD:aCols[nX, _nPosQtdNo], TamSX3("D1_TOTAL")[2]) # oGetD:aCols[nX, _nPosVlTot]
						
						If lMsg
						
							Aviso("Aviso", "O Valor total no item " + cValToChar(nX) + " não confere com a multiplicação de Quantidade x Valor Unitário, e o Total não pode ser modificado, pois vem do XML. Ajuste a Quantidade ou Preço Unitário.", {"Ok"}, 2)
							
						EndIf
						
						Return .F.*/
						
					EndIf
					
					If oGetD:aCols[nX, _nPosVlUnt] # SC7->C7_PRECO
						
						If lMsg .And. GetNewPar("MV_ZGOVLPP", .T.)
							
							If Aviso("Aviso", "O Valor Unitário (" + AllTrim(Transform(oGetD:aCols[nX, _nPosVlUnt], "@E 999,999,999." + Replicate("9", TamSX3("D1_VUNIT")[2]))) + ") do item " + cValToChar(nX) + " está diferente do Pedido de Compras (" + AllTrim(Transform(SC7->C7_PRECO, "@E 999,999,999." + Replicate("9", TamSX3("D1_VUNIT")[2]))) + "), deseja continuar?", {"Sim", "Não"}, 2) # 1
								
								Return .F.
								
							EndIf
							
						EndIf
						
					EndIf
					
					If lValQtd
						
						lErrIt := .F.
						
						If (oGetD:aCols[nX, _nPosQtdNo] - (SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA)) > 0.009
							
							lErro := .T.
							
							lErrIt := .T.
							
							If lMsg
								
								cMsgGeral += Replicate("-", 40) + CRLF
								cMsgGeral += "Pedido/Item: " + SC7->C7_NUM + "/" + SC7->C7_ITEM + " (Produto: " + AllTrim(oGetD:aCols[nX, _nPosProdu]) + ")" + CRLF
								
								cMsgGeral += "Qtde. XML: " + AllTrim(Transform(oGetD:aCols[nX, _nPosQtdNo], "@E 9,999,999.99")) + " <========> " + "Qtde. Pedido: " + AllTrim(Transform((SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA), "@E 9,999,999.99")) + " (Já Entregue: " + AllTrim(Transform(SC7->C7_QUJE, "@E 9,999,999.99")) + ")" + CRLF
								
								//cMsgGeral += "Valor XML: " + AllTrim(Transform(oGetD:aCols[nX, _nPosVlTot], "@E 9,999,999.99")) + " <========> " + "Valor Pedido: " + AllTrim(Transform((SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA) * SC7->C7_PRECO, "@E 9,999,999.99")) + CRLF
								
							EndIf
							
						EndIf
						
						If lSomaImp
							
							nAuxPrc := oGetD:aCols[nX, _nPosVlTot] + ;
								oGetD:aCols[nX, _nPosVlIpi] + oGetD:aCols[nX, _nPosVlFrt]
								
							If !ExistBlock("GOXSOMST") .Or. ExecBlock("GOXSOMST", .F., .F., {nX})
								
								nAuxPrc += oGetD:aCols[nX, _nPosVlISt] + ;
								oGetD:aCols[nX, _nPosVlStA]
								
							EndIf
								
							nAuxPrc := Round(nAuxPrc / oGetD:aCols[nX, _nPosQtdNo], TamSx3("C7_PRECO")[2])
							
						Else
							
							nAuxPrc := oGetD:aCols[nX, _nPosVlUnt]
							
						EndIf
						
						If Abs(nAuxPrc - SC7->C7_PRECO) > 0.1
							
							lErro := .T.
							
							If lMsg
							
								If !lErrIt
									
									cMsgGeral += Replicate("-", 40) + CRLF
									cMsgGeral += "Pedido/Item: " + SC7->C7_NUM + "/" + SC7->C7_ITEM + " (Produto: " + AllTrim(oGetD:aCols[nX, _nPosProdu]) + ")" + CRLF
									
								EndIf
								
								lErrIt := .T.
								
								cMsgGeral += "Preço XML: " + AllTrim(Transform(nAuxPrc, "@E 9,999,999.99")) + " <========> " + "Preço Pedido: " + AllTrim(Transform(SC7->C7_PRECO, "@E 9,999,999.99")) + CRLF
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
				// Verificar se existe itens salvos de outra nota com o pedido informado
				
				If !(aVldPedS := VldPedSlv(oGetD:aCols[nX, _nPosQtdNo]))[1]
					
					If Aviso("Aviso", "Pedido/Item: " + SC7->C7_NUM + "/" + SC7->C7_ITEM + " (Produto: " + AllTrim(oGetD:aCols[nX, _nPosProdu]) + ")" + CRLF + " -> Já possui a nota fiscal " + aVldPedS[2] + " salva com este pedido, deseja realmente continuar?", {"Cancelar", "Continuar"}, 2) == 1
						
						Return .F.
						
					EndIf
					
				EndIf
				
			Else
			
				cNPed += cValToChar(nX) + ", "
				
			EndIf
			
		EndIf
		
		If _nPosProdu > 0
		
			// Demais validações
			If Empty(oGetD:aCols[nX, _nPosProdu])
			
				If lMsg
				
					Aviso("Aviso", "Código do produto deve ser informado!", {"Ok"}, 2)
					
				EndIf
				
				Return .F.
				
			EndIf
			
		EndIf
		
		If _nPosQtdNo > 0
		
			If Empty(oGetD:aCols[nX, _nPosQtdNo])
			
				If lMsg
				
					Aviso("Aviso", "Quantidade do produto deve ser informado!", {"Ok"}, 2)
					
				EndIf
				
				Return .F.
				
			EndIf
			
		EndIf
		
		If _nPosTes > 0
		
			If Empty(oGetD:aCols[nX, _nPosTes])

				if !lPreNota
			
					If lMsg
					
						Aviso("Aviso", "Código da TES deve ser informado!", {"Ok"}, 2)
						
					EndIf
					
					Return .F.

				endif
				
			ElseIf !lNatCdPag
			
				lNatCdPag := IIf(Posicione("SF4", 1, xFilial("SF4") + oGetD:aCols[nX, _nPosTes], "F4_DUPLIC") == "S", .T., .F.)
				
			EndIf
			
		EndIf
		
	Next nX
	
	If lErro 
		
		If !Empty(cMsgGeral)
			
			cMsgGeral := "Erros na validação de XML e Pedido de Compra" + CRLF + CRLF + cMsgGeral
			
			Aviso("Aviso", cMsgGeral, {"Ok"}, 3)
		
		EndIf
		
		Return .F.
		
	EndIf
		
	If !lPreNota
	
		// Só obriga os campos de natureza e condição de pagamento, caso algum item tenha uma TES que gera duplicata
		If !Empty(M->&(_cCmp1 + "_NATFIN"))
		
			dbSelectArea("SED")
			SED->( dbSetOrder(1) )
			
			If !SED->( dbSeek(xFilial("SED") + M->&(_cCmp1 + "_NATFIN")) )
			
				If lMsg
				
					Aviso("Aviso", "Deve ser informada uma Natureza Financeira válida!", {"Ok"}, 2)
					
				EndIf
				
				Return .F.
				
			EndIf
			
		ElseIf lNatCdPag .And. Empty(M->&(_cCmp1 + "_NATFIN"))
		
			If lMsg
			
				Aviso("Aviso", "Natureza Financeira deve ser informada!", {"Ok"}, 2)
				
			EndIf
			
			Return .F.
			
		EndIf
		
		If !Empty(M->&(_cCmp1 + "_CONDPG"))
		
			dbSelectArea("SE4")
			SE4->( dbSetOrder(1) )
			
			If !SE4->( dbSeek(xFilial("SE4") + M->&(_cCmp1 + "_CONDPG")) )
			
				If lMsg
				
					Aviso("Aviso", "Deve ser informada uma Condição de Pagamento válida!", {"Ok"}, 2)
					
				EndIf
				
				Return .F.
				
			EndIf
			
		ElseIf lNatCdPag .And. Empty(M->&(_cCmp1 + "_CONDPG"))
		
			If lMsg
			
				Aviso("Aviso", "Condição de Pagamento deve ser informada!", {"Ok"}, 2)
				
			EndIf
			
			Return .F.
			
		EndIf
		
	EndIf
	
	If lMsg .And. !Empty(cNPed)
		
		If U_GOX14PC()
			
			Aviso("Aviso", "Seu usuário está parametrizado com obrigatoriedade para informar o pedido de compras!", {"Ok"}, 2)
			Return .F.
			
		ElseIf GetNewPar("MV_ZPERSPC", .T.) .And. Aviso("Pedido de Compra", "Não foi(ram) informado(s) Pedido(s) de Compra para o(s) produto(s) na(s) linha(s): " + SubStr(cNPed, 1, Len(cNPed) - 2) + ". Deseja continuar com a importação?", {"Continuar", "Cancelar"}, 2) # 1
		
			Return .F.
			
		EndIf
		
	EndIf
	
Return .T.

////////////////////////////////////////

User Function CliForGO(cCNPJ, lCliente)

	Local aRet   := {0, "", "", "", "", "", "", "", .F., ""}
	Local lFirst := .T.
	
	Default lCliente := .F. 
	
	cCNPJ = PadR(cCNPJ, TamSX3("A2_CGC")[1])
	
	dbSelectArea("SA2")
	SA2->( dbSetOrder(3) )

	If SA2->( dbSeek(xFilial("SA2") + cCNPJ) ) .And. !lCliente

		While !SA2->( Eof() ) .And. SA2->A2_FILIAL == xFilial("SA2") .And. SA2->A2_CGC == cCNPJ
			
			If SA2->A2_MSBLQL # "1"
				
				If lFirst
					
					aRet[1] := 1
					aRet[2] := SA2->A2_COD
					aRet[3] := SA2->A2_LOJA
					aRet[4] := SA2->A2_NATUREZ
					aRet[5] := SA2->A2_EST
					aRet[6] := SA2->A2_COND
					aRet[7] := SA2->A2_NOME
					aRet[8] := SA2->A2_MSBLQL
					aRet[10] := SA2->A2_COD_MUN
					
				Else
					
					aRet[9] := .T.
					
				EndIf
				
				lFirst := .F.
				
				//Exit
				
			EndIf
			
			SA2->( dbSkip() )

		EndDo

		If Empty(aRet[2])

			If SA2->( dbSeek(xFilial("SA2") + cCNPJ) )

				aRet[1] := 1
				aRet[2] := SA2->A2_COD
				aRet[3] := SA2->A2_LOJA
				aRet[4] := SA2->A2_NATUREZ
				aRet[5] := SA2->A2_EST
				aRet[6] := SA2->A2_COND
				aRet[7] := SA2->A2_NOME
				aRet[8] := SA2->A2_MSBLQL
				aRet[10] := SA2->A2_COD_MUN
				
			EndIf

		EndIf

	Else

		dbSelectArea("SA1")
		SA1->( dbSetOrder(3) )

		If SA1->( dbSeek(xFilial("SA1") + cCNPJ) )

			While !SA1->( Eof() ) .And. SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_CGC == cCNPJ
				
				If SA1->A1_MSBLQL # "1" .And. !(AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) $ GetNewPar("MV_ZEMTPDR", "7063/01"))
					
					If lFirst
						
						aRet[1] := 2
						aRet[2] := SA1->A1_COD
						aRet[3] := SA1->A1_LOJA
						aRet[4] := SA1->A1_NATUREZ
						aRet[5] := SA1->A1_EST
						aRet[6] := SA1->A1_COND
						aRet[7] := SA1->A1_NOME
						aRet[8] := SA1->A1_MSBLQL
						aRet[10] := SA1->A1_COD_MUN
						
					Else
						
						aRet[9] := .T.
						
					EndIf
					
					lFirst := .F.
					
					//Exit
					
				EndIf
				SA1->( dbSkip() )

			EndDo

			If Empty(aRet[2])

				If SA1->( dbSeek(xFilial("SA1") + cCNPJ) )

					aRet[1] := 2
					aRet[2] := SA1->A1_COD
					aRet[3] := SA1->A1_LOJA
					aRet[4] := SA1->A1_NATUREZ
					aRet[5] := SA1->A1_EST
					aRet[6] := SA1->A1_COND
					aRet[7] := SA1->A1_NOME
					aRet[8] := SA1->A1_MSBLQL
					aRet[10] := SA1->A1_COD_MUN
					
				EndIf

			EndIf

		EndIf

	EndIf
	
Return aRet

////////////////////////////////////////

Static Function ClientesCNPJ(cCNPJ)
	
	Local aRetCli
	Local aClientes  := {}
	Local nNumDesblq := 0
	
	Local aCliCmp  := {"A1_COD", "A1_LOJA", "A1_NOME"} //A1_BLQ
	Local aHeadCli := {}
	Local aColsCli := {}
	Local nI
	Local nX
	
	Local aSize := MsAdvSize()
	Local oDlgCli
	
	dbSelectArea("SA1")
	SA1->( dbSetOrder(3) )

	SA1->( dbSeek(xFilial("SA1") + cCNPJ) )
	
	While !SA1->( Eof() ) .And. SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_CGC == cCNPJ
		
		If SA1->A1_MSBLQL # "1"
			
			AAdd(aClientes, {SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME, .F.})
			
			nNumDesblq++
			
		Else
			
			AAdd(aClientes, {SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME, .T.})
			
		EndIf
		
		SA1->( dbSkip() )
		
	EndDo
	
	If Len(aClientes) == 0
		
		Return {"", ""}
		
	EndIf
	
	If Len(aClientes) > 1
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(2) )
		
		For nI := 1 To Len(aCliCmp)
			
			If aCliCmp[nI] == "A1_BLQ"
				
				SX3->( dbSeek("A1_NOME") )
				
				AAdd(aHeadCli, {"Sit. Cliente", "A1_BLQ", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", SX3->X3_USADO, SX3->X3_TIPO, "   ", SX3->X3_CONTEXT})
				
			ElseIf SX3->( dbSeek(aCliCmp[nI]) )
				
				AAdd(aHeadCli, {Trim(X3Titulo()), AllTrim(SX3->X3_CAMPO), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
				 				"", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
				
			EndIf
			
		Next nI
		
		For nI := 1 To Len(aClientes)
						
			AAdd(aColsCli, Array(Len(aHeadCli) + 1))
			
			For nX := 1 To Len(aHeadCli)
				
				If aHeadCli[nX][2] == "A1_BLQ"
					
					ATail(aColsCli)[nX] := IIf(aClientes[nI][nX], "Bloqueado", "Ativo")
					
				Else
					
					ATail(aColsCli)[nX] := aClientes[nI][nX]
					
				EndIf
				
			Next nX
			
			ATail(ATail(aColsCli)) := .F.
			
		Next nI
		
		DEFINE MSDIALOG oDlgCli FROM aSize[7], 0 TO aSize[6]/1.5, aSize[5]/1.5 TITLE 'Selecionar o cliente das notas' PIXEL
			oDlgCli:lEscClose := .F.

			oLayerCli := FWLayer():New()
			oLayerCli:Init(oDlgCli, .F.)
			
			oLayerCli:AddLine('LN_CLI', 90, .F.)

				oLayerCli:AddCollumn('COL_CLI', 100, .T., 'LN_CLI')
	
					oLayerCli:AddWindow('COL_CLI', 'WIN_CLI', "Selecione o cliente para buscar as notas:", 100, .F., .T., , 'LN_CLI', )
			
						oGetCli := MsNewGetDados():New(000, 000, 000, 000, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", {}, 0, 999, Nil, Nil, "AlwaysFalse", oLayerCli:GetWinPanel('COL_CLI', 'WIN_CLI', 'LN_CLI'), aHeadCli, aColsCli, "")
			
						oGetCli:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						//oGetProd:oBrowse:SetBlkBackColor({|| IIf(oGetProd:aCols[oGetProd:nAt][4] > 0, RGB(0,255,0), RGB(255,255,255))})
						oGetCli:oBrowse:bLDblClick := {|| aRetCli := {oGetCli:aCols[oGetCli:nAt][1], oGetCli:aCols[oGetCli:nAt][2]}, oDlgCli:End()}
						
						oGetCli:SetArray(aColsCli, .T.)
						
			oLayerCli:AddLine('LN_BUTTON', 10, .F.)

				oLayerCli:AddCollumn('COL_BUTTON', 100, .T., 'LN_BUTTON')
					
					oPanelBot := tPanel():New(0, 0, "", oLayerCli:GetColPanel('COL_BUTTON', 'LN_BUTTON'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oOk := THButton():New(0, 0, "Cancelar", oPanelBot, {|| oDlgCli:End()}, , , )
					oOk:nWidth  := 80
					oOk:nHeight := 10
					oOk:Align   := CONTROL_ALIGN_RIGHT
					oOk:SetColor(RGB(002, 070, 112), )
					
					oQuit := THButton():New(0, 0, "Confirmar", oPanelBot, {|| aRetCli := {oGetCli:aCols[oGetCli:nAt][1], oGetCli:aCols[oGetCli:nAt][2]}, oDlgCli:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
		ACTIVATE MSDIALOG oDlgCli CENTERED
		
	Else
		
		aRetCli := {aClientes[1][1], aClientes[1][2]}
		
	EndIf
	
	If Empty(aRetCli)
		
		aRetCli := {aClientes[1][1], aClientes[1][2]}
		
	EndIf
	
Return aRetCli

////////////////////////////////////////

Static Function RetItemICMS(oXml, aTags)
	
	Local nRet := 0
	Local nI
	Local oTagAtu := oXml
	
	Default aTags := {}
	
	If ValType(oTagAtu) == "O"
	
		For nI := 1 To Len(aTags)
			
			If ValType(oTagAtu := XmlChildEx(oTagAtu, aTags[nI])) == "O"
				
				If nI == Len(aTags)
					
					nRet := Round(Val(oTagAtu:Text), 2)
					
				EndIf
				
			Else
				
				Exit
				
			EndIf
			
		Next nI
		
	EndIf
	
Return nRet

/*#######################################################################*\
||#    CRIA UMA TELA DE CONVERSÃO DE UNIDADES DE MEDIDA POR PRODUTO     #||
\*#######################################################################*/
User Function ConUMGO()

	Private aRotina := {}
	
	If !Empty(_cTab4)
	
		AxCadastro(_cTab4, "Conversão de Unidade de Medida por Produto")
		
	Else
	
		Aviso("Conversão de Unidade de Medida por Produto", "Preencha o parâmetro MV_XGTTAB4 e execute a " + ;
		      "função U_UPDGT001(). " + CRLF + "Ou entre em contato com o suporte da Goone Consultoria.", {"Ok"}, 1)
		
	EndIf
	
Return(.T.)

/*#######################################################################*\
||#         FAZ OS CÁLCULOS DA CONVERSÃO E RETORNA O RESULTADO          #||
||#                   UNIDADES DE MEDIDA POR PRODUTO                    #||
\*#######################################################################*/
Static Function ValConUM(cProdu, cUmFor, cUm, nQtdFr, cEmit, cLoj, lFor)
	
	Local cDescPrd := ""
	Local nConv    := 0
	Local aRet
	
	Default lFor   := .T.
	
	// Sem estas informações dá erro no cálculo, então barra antes.
	If Empty(_cTab4) .Or. Empty(cProdu) .Or. Empty(cUmFor) .Or. Empty(cUm) .Or. Empty(nQtdFr) .Or. Empty(cEmit) .Or. Empty(cLoj)
		
		Return {.F.}
		
	EndIf
	
	// Descrição do produto
	cDescPrd := Posicione("SB1", 1, xFilial("SB1") + cProdu, "B1_DESC")
	
	dbSelectArea(_cTab4)
	
	// Se não houver conversão para o produto, solicita cadastro.
	/*If AllTrim(cProdu) == "*" .And. !(_cTab4)->( dbSeek(xFilial(_cTab4) + cProdu) )
	
		If lUMMsg .And. Aviso("Aviso", "Não foi encontrado conversão de Unidade de Medida para o produto " + AllTrim(cDescPrd) + ". " + ;
		         "Deseja criar uma conversão agora?", {"Sim", "Não"}, 2) == 1
			
			U_ConUMGO()
			
		Else
			
			Return {.F.}
			
		EndIf
		
	EndIf*/
	
	cUmFor := PadR(cUmFor, TamSX3(_cCmp2 + "_UMF")[1])
	
	If lFor
		
		(_cTab4)->( dbSetOrder(3) )
		
	Else
		
		(_cTab4)->( dbSetOrder(5) )
		
	EndIf
	
	// Conversão Normal: Origem - Destino
	If (_cTab4)->( dbSeek(xFilial(_cTab4) + cEmit + cLoj + cProdu + cUmFor + cUm) )
		
		If (_cTab4)->&(_cCmp4 + "_OPERA") == "/"
			
			nConv := Round(nQtdFr / (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
			
		ElseIf (_cTab4)->&(_cCmp4 + "_OPERA") == "*"
			
			nConv := Round(nQtdFr * (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
			
		EndIf
		
	Else
		
		If lFor
			
			(_cTab4)->( dbSetOrder(4) )
			
		Else
			
			(_cTab4)->( dbSetOrder(6) )
			
		EndIf
		
		// Conversão Inversa: Destino - Origem
		If (_cTab4)->( dbSeek(xFilial(_cTab4) + cEmit + cLoj + cProdu + cUmFor + cUm) )
			
			If (_cTab4)->&(_cCmp4 + "_OPERA") == "/"
				
				nConv := Round(nQtdFr * (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
				
			ElseIf (_cTab4)->&(_cCmp4 + "_OPERA") == "*"
				
				nConv := Round(nQtdFr / (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
				
			EndIf
			
		Else
			
			(_cTab4)->( dbSetOrder(1) )
			
			If (_cTab4)->( dbSeek(xFilial(_cTab4) + cProdu + cUmFor + cUm) )
				
				If (_cTab4)->&(_cCmp4 + "_OPERA") == "/"
					
					nConv := Round(nQtdFr / (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
					
				ElseIf (_cTab4)->&(_cCmp4 + "_OPERA") == "*"
					
					nConv := Round(nQtdFr * (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
					
				EndIf
				
			Else
				
				(_cTab4)->( dbSetOrder(2) )
				
				If (_cTab4)->( dbSeek(xFilial(_cTab4) + cProdu + cUmFor + cUm) )
					
					If (_cTab4)->&(_cCmp4 + "_OPERA") == "/"
						
						nConv := Round(nQtdFr * (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
						
					ElseIf (_cTab4)->&(_cCmp4 + "_OPERA") == "*"
						
						nConv := Round(nQtdFr / (_cTab4)->&(_cCmp4 + "_FATOR"), 2)
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	If nConv # 0
		
		Return {.T., nConv}
		
	/*ElseIf AllTrim(cProdu) # "*"
		
		aRet := ValConUM(PadR("*", TamSX3(_cCmp4 + "_PRODUT")[1]), cUmFor, cUm, nQtdFr)
		
		If aRet[1]
			
			Return aRet
			
		EndIf*/
		
	EndIf
	
Return {.F.}

/*#######################################################################*\
||#                      RETORNA FILIAIS DE CLIENTE                     #||
\*#######################################################################*/

Static Function RtFilCli(cCNPJ)

	Local aCli      := {}
	Local aCodCli   := {}
	Local cMeioCNPJ := ""
	Local cSa1      := GetNextAlias()
	Local cQuery    := ""
	Local nOp       := 1
	
	If Empty(cCNPJ)
		
		Return
		
	EndIf
	
	cMeioCNPJ := SubStr(AllTrim(cCNPJ), 1, 8)  // Pega os primeiros 8 dígitos
	
	cQuery := " SELECT SA1.A1_COD, "
	cQuery += "        SA1.A1_LOJA, "
	cQuery += "        SA1.A1_CGC, "
	cQuery += "        SA1.A1_MSBLQL, "
	cQuery += "        SA1.A1_NREDUZ, "
	cQuery += "        '' INCORP "
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += " AND   SA1.A1_CGC LIKE '" + cMeioCNPJ + "%' "
	cQuery += " AND   SA1.D_E_L_E_T_ <> '*' "
	
	If SA1->( FieldPos("A1_ZCGCINC") ) > 0
		
		cQuery += " UNION ALL "
		cQuery += " SELECT SA1.A1_COD, "
		cQuery += "        SA1.A1_LOJA, "
		cQuery += "        SA1.A1_CGC, "
		cQuery += "        SA1.A1_MSBLQL, "
		cQuery += "        SA1.A1_NREDUZ, "
		cQuery += "        '(Incorp.)' INCORP "
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
		cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += " AND SA1.A1_ZCGCINC = '" + cCNPJ + "' "
		cQuery += " AND   SA1.D_E_L_E_T_ <> '*' "
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cSa1, .F., .T.)
	
	// A primeira linha deve ser do CNPJ Informado
	AAdd(aCli, "")
	AAdd(aCodCli, {"", "", ""})
	
	(cSa1)->( dbGoTop() )
	
	While !(cSa1)->( Eof() )
	
		If (cSa1)->A1_CGC == cCNPJ
			
			If Empty(aCli[1])
				
				aCli[1]       := "1=" + AllTrim((cSa1)->A1_CGC) + " / " + AllTrim((cSa1)->A1_NREDUZ) + (cSa1)->INCORP
				aCodCli[1][1] := AllTrim((cSa1)->A1_COD)
				aCodCli[1][2] := AllTrim((cSa1)->A1_LOJA)
				aCodCli[1][3] := AllTrim((cSa1)->A1_MSBLQL)
				
			ElseIf (cSa1)->A1_MSBLQL <> '1' .And. aCodCli[1][3] == '1'
				
				AAdd(aCli, cValToChar(++nOp) + SubStr(aCli[1], 2))
				AAdd(aCodCli, {aCodCli[1][1], aCodCli[1][2], aCodCli[1][3]})
				
				aCli[1]       := "1=" + AllTrim((cSa1)->A1_CGC) + " / " + AllTrim((cSa1)->A1_NREDUZ) + (cSa1)->INCORP
				aCodCli[1][1] := AllTrim((cSa1)->A1_COD)
				aCodCli[1][2] := AllTrim((cSa1)->A1_LOJA)
				aCodCli[1][3] := AllTrim((cSa1)->A1_MSBLQL)
				
			Else
				
				AAdd(aCli, cValToChar(++nOp) + "=" + AllTrim((cSa1)->A1_CGC) + " / " + AllTrim((cSa1)->A1_NREDUZ) + (cSa1)->INCORP)
				AAdd(aCodCli, {AllTrim((cSa1)->A1_COD), AllTrim((cSa1)->A1_LOJA), AllTrim((cSa1)->A1_MSBLQL)})
				
			EndIf
			
		Else
			
			AAdd(aCli, cValToChar(++nOp) + "=" + AllTrim((cSa1)->A1_CGC) + " / " + AllTrim((cSa1)->A1_NREDUZ) + (cSa1)->INCORP)
			AAdd(aCodCli, {AllTrim((cSa1)->A1_COD), AllTrim((cSa1)->A1_LOJA)})
			
		EndIf
		
		(cSa1)->( dbSkip() )
		
	EndDo
	
	(cSa1)->( dbCloseArea() )
	
Return {aCli, aCodCli} // Retorna o array pra apresentar no combo e o array com o código.

// -----------------

Static Function VldCFOPNF(lVerifica)
	
	Local nX
	Local cCFOP
	Local cTipo  := "X"
	Local cComp  := ""
	Local aCFOP
	Local aNCFOP := {}
	Local aRet   := {.F., .F., "", ""}
	Local cErro  := ""
	Local cBCFOP := ""  
	
	Default lVerifica := .F.
	
	// Requer que o objeto do XML da Nota Fiscal já esteja criado
	
	If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") # "U"
		
		If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
			
			XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
			
		EndIf
		
		For nX := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)
			
			cCFOP := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nX]:_prod:_CFOP:Text)
			
			If !(SubStr(cCFOP, 1, 1) $ "5,6,7")
				
				cTipo := "Z"
				
				cErro := "CFOP no XML do emissor não é de saída."
				
				cBCFOP := cCFOP
				
				Exit
				
			EndIf
			
			dbSelectArea(_cTab6)
			(_cTab6)->( dbSetOrder(1) )
			If (_cTab6)->( dbSeek(xFilial(_cTab6) + cCFOP) )
				
				dbSelectArea(_cTab5)
				(_cTab5)->( dbSetOrder(1) )
				If (_cTab5)->( dbSeek(xFilial(_cTab5) + (_cTab6)->&(_cCmp6 + "_SEQ")) )
					
					If cTipo == "X" .Or. ((_cTab6)->( FieldPos(_cCmp6 + "_BLOQ") ) > 0 .And. (_cTab6)->&(_cCmp6 + "_BLOQ"))
						
						If (_cTab6)->( FieldPos(_cCmp6 + "_BLOQ") ) > 0 .And. (_cTab6)->&(_cCmp6 + "_BLOQ")
							
							cTipo := "Z"
							
						Else
							
							cTipo := (_cTab5)->&(_cCmp5 + "_TIPO")
							
							If cTipo == "C"
								
								cComp := (_cTab5)->&(_cCmp5 + "_TPCOMP")
								
							EndIf
							
						EndIf
						
						If cTipo == "Z"
							
							cBCFOP := cCFOP // Grava qual foi a CFOP que impediu a entrada da nota
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
			If AScan(aNCFOP, {|x| x == cCFOP}) == 0
				
				AAdd(aNCFOP, cCFOP)
				
			EndIf
			
		Next nX
	
		If cTipo == "X"
			
			If !lVerifica .And. File("\workflow\modelos\importador\SEMCFOP.htm")
			
				// Percorre as CFOPS inexistentes e envia e-mail
				
				oProcess := TWFProcess():New("000001", OemToAnsi("CFOP não Cadastrada"))
				
				oProcess:NewTask("000001", "\workflow\modelos\importador\SEMCFOP.htm")
				
				oProcess:cSubject 	:= "CFOP não cadastrado no Importador "
				oProcess:bReturn  	:= ""
				oProcess:bTimeOut	:= {}
				oProcess:fDesc 		:= "CFOP não cadastrado no Importador "
				oProcess:ClientName(cUserName)
				oHTML := oProcess:oHTML
				
				oHTML:ValByName('cFilial', cFilName)
				
				oHTML:ValByName('cUser', cUserName)
				
				oHTML:ValByName('cNumNota', (_cTab1)->&(_cCmp1 + "_DOC"))
				
				oHTML:ValByName('cNomeForn', U_GODSEMIT())
				
				// Futuramente poderemos enviar o XML da nota
				//oProcess:AttachFile("")
			
			EndIf
			
			cErro := "Tipo de Nota não cadastrado para as CFOPs "
			
			For nX := 1 To Len(aNCFOP)
				
				dbSelectArea("SX5")
				SX5->( dbSetOrder(1) )
				If SX5->( dbSeek(xFilial("SX5") + "13" + PadR(aNCFOP[nX], TamSX3("X5_CHAVE")[1])) )
					
					If !lVerifica .And. File("\workflow\modelos\importador\SEMCFOP.htm")
						
						AAdd(oProcess:oHtml:ValByName('cf.cCFOP'), aNCFOP[nX])
						AAdd(oProcess:oHtml:ValByName('cf.cDesc'), AllTrim(SX5->X5_DESCRI))
						
					EndIf
					
					cErro += IIf(nX # 1, ",", "") + AllTrim(aNCFOP[nX])
					
				EndIf
				
			Next nX
			
			cErro += "."
			
			If !lVerifica .And. File("\workflow\modelos\importador\SEMCFOP.htm")
				
				oProcess:cTo := GetNewPar("MV_ZSENCFO", "octavio@gooneconsultoria.com.br")
				
				// Inicia o processo
				oProcess:Start()
				// Finaliza o processo
				oProcess:Finish()
			
			EndIf
			
		EndIf
	
	EndIf
	
	If !(cTipo $ "Z;X")
		
		If !lVerifica
			
			RecLock(_cTab1, .F.)
				
				(_cTab1)->&(_cCmp1 + "_TIPOEN") := cTipo
				
				(_cTab1)->&(_cCmp1 + "_TPCOMP") := cComp
				
			(_cTab1)->( MsUnLock() )
			
		EndIf
		
		aRet[1] := .T.
		aRet[2] := .F.
		aRet[3] := cTipo
		aRet[4] := cComp
		
	ElseIf cTipo == "X"
		
		aRet[1] := .F.
		aRet[2] := .F.
		aRet[3] := cErro
		aRet[4] := ""
		
	ElseIf cTipo == "Z"
		
		aRet[1] := .T.
		aRet[2] := .T.
		aRet[3] := "Impedida entrada da nota devido a CFOP " + cBCFOP + CRLF + cErro
		aRet[4] := ""
		
	EndIf
	
Return aRet

// -----------------

User Function GOGDeUpd(cChave, cContent)	
	
	Local aRet := {.F., ""}
	
	Private oCabXMLP	:=	WSGDeWService():New()
	     
	oCabXMLP:CCNPJ 		:= SM0->M0_CGC
	oCabXMLP:CLOGIN	  	:= GetNewPar("MV_ZSNWSUS", "urbano")
	oCabXMLP:CSENHA		:= GetNewPar("MV_ZSNWSPS", "ajfu4381")
	oCabXMLP:CCHAVE		:= cChave
	oCabXMLP:cconteudo	:= cContent // Conteúdo a ser gravado no campo customizado
	oCabXMLP:nnCustom	:= 1 // Número do campo Customizado (qual campo customizado)(Podem ser criados até n campos customizados)
	
	If oCabXMLP:UpdateCustom()
		
		If Empty(oCabXMLP:CUPDATECUSTOMRESULT)
			aRet := {.F., "Não foi possível atualizar o XML - Chave: " + cChave}
		Else
			aRet := {.T., ""}
		EndIf
		
	Else
		
		aRet := {.F., GetWscError()}
		 
	EndIf
	
Return aRet

// -----------------

// ----------------- Será a função utilizada para settar o erro para uma tentativa de processamento,
// Assim será possível mostrar na tree, todo processamento sem sucesso deverá mudar o status para 3, ficando vermelho no grid.

User Function GOSetEr(cErro, nRecNo, lLimpa)
	
	Local aAreaTab1 := (_cTab1)->( GetArea() )
	
	Default nRecno := 0
	Default cErro  := ""
	Default lLimpa := .F.
	
	If !Empty(cErro) .Or. lLimpa
		
		If nRecno > 0
			
			dbSelectArea(_cTab1)
			(_cTab1)->( dbGoTo(nRecno) )
			
		EndIf
		
		RecLock(_cTab1, .F.)
			
			(_cTab1)->&(_cCmp1 + "_SIT")  := IIf(lLimpa, "1", "3")
			(_cTab1)->&(_cCmp1 + "_ERRO") := IIf(lLimpa, "", cErro)
			
		(_cTab1)->( MSUnlock() )
		
	EndIf
	
	RestArea(aAreaTab1)
	
Return

// ----------------------------

Static Function RelacCFOP(oXml, cTipo, lRetorna, cTpComp)
	
	Local aCFOP := {}
	Local nX
	Local cCFOP := ""
	Local cNumSeq
	
	Default cTpComp := ""
	
	If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") # "U"
		
		If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
			
			XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
			
		EndIf
		
		For nX := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)
			
			cCFOP := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nX]:_prod:_CFOP:Text)
			
			dbSelectArea(_cTab6)
			(_cTab6)->( dbSetOrder(1) )
			If (_cTab6)->( dbSeek(xFilial(_cTab6) + cCFOP) )
				
				dbSelectArea(_cTab5)
				(_cTab5)->( dbSetOrder(1) )
				If (_cTab5)->( dbSeek(xFilial(_cTab5) + (_cTab6)->&(_cCmp6 + "_SEQ")) )
					
					If cTipo # (_cTab5)->&(_cCmp5 + "_TIPO")
						
						// Quando encontrar já cadastrado mas diferente...
						
					Else
						
						If (_cTab5)->&(_cCmp5 + "_TIPO") == "C" .And. Empty( AllTrim((_cTab5)->&(_cCmp5 + "_TPCOMP")) )
							
							RecLock(_cTab5, .F.)
								
								(_cTab5)->&(_cCmp5 + "_TPCOMP") := cTpComp
								
							(_cTab5)->( MSUnlock() )
							
						EndIf
						
						// Quando encontrar já cadastrado e mesmo tipo OK
						
					EndIf
					
				EndIf
				
			Else
				
				// Quando não encontrar cadastrado da CFOP
				
				dbSelectArea(_cTab5)
				(_cTab5)->( dbSetOrder(2) )
				If (_cTab5)->( dbSeek(xFilial(_cTab5) + cTipo) )
					
					If (_cTab5)->&(_cCmp5 + "_TIPO") == "C" .And. Empty( AllTrim((_cTab5)->&(_cCmp5 + "_TPCOMP")) )
						
						RecLock(_cTab5, .F.)
							
							(_cTab5)->&(_cCmp5 + "_TPCOMP") := cTpComp
							
						(_cTab5)->( MSUnlock() )
						
					EndIf
					
					RecLock(_cTab6, .T.)
						
						(_cTab6)->&(_cCmp6 + "_FILIAL") := xFilial(_cTab6)
						(_cTab6)->&(_cCmp6 + "_SEQ")    := (_cTab5)->&(_cCmp5 + "_SEQ")
						(_cTab6)->&(_cCmp6 + "_CFOP")   := cCFOP
						(_cTab6)->&(_cCmp6 + "_AUTO")   := .F.
						(_cTab6)->&(_cCmp6 + "_RETOR")  := lRetorna
						If (_cTab6)->( FieldPos(_cCmp6 + "_BLOQ") ) > 0
							(_cTab6)->&(_cCmp6 + "_BLOQ")   := .F.
						EndIf
						(_cTab6)->&(_cCmp6 + "_OBRIGA") := .F.
						
					(_cTab6)->( MSUnlock() )
					
				Else
					
					cNumSeq := GETSXENUM(_cTab5, _cCmp5 + "_SEQ")
					
					RecLock(_cTab5, .T.)
						
						(_cTab5)->&(_cCmp5 + "_FILIAL") := xFilial(_cTab5)
						(_cTab5)->&(_cCmp5 + "_SEQ")    := cNumSeq
						(_cTab5)->&(_cCmp5 + "_TIPO")   := cTipo
						
						If cTipo == "C"
							
							(_cTab5)->&(_cCmp5 + "_TPCOMP") := cTpComp
							
						EndIf
						
					(_cTab5)->( MSUnlock() )
					
					ConfirmSX8()
					
					RecLock(_cTab6, .T.)
						
						(_cTab6)->&(_cCmp6 + "_FILIAL") := xFilial(_cTab6)
						(_cTab6)->&(_cCmp6 + "_SEQ")    := cNumSeq
						(_cTab6)->&(_cCmp6 + "_CFOP")   := cCFOP
						(_cTab6)->&(_cCmp6 + "_AUTO")   := .F.
						(_cTab6)->&(_cCmp6 + "_RETOR")  := lRetorna
						If (_cTab6)->( FieldPos(_cCmp6 + "_BLOQ") ) > 0
							(_cTab6)->&(_cCmp6 + "_BLOQ")   := .F.
						EndIf
						(_cTab6)->&(_cCmp6 + "_OBRIGA") := .F.
						
					(_cTab6)->( MSUnlock() )
					
				EndIf
				
			EndIf
			
		Next nX
		
	EndIf
	
Return

User Function GOX1MAN()
	
	Local oDlgMan
	Local oFile
	Local cFile := Space(254) 
	Local cXML
	Local oLayerMan
	
	DEFINE MSDIALOG oDlgMan FROM aSize[7], 0 TO 100, aSize[5]/2.5 TITLE 'Importador XML' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgMan:lEscClose := .F.
		
		//////////////////////////////////////// XML
		
		oLayerMan := FWLayer():New()
		oLayerMan:Init(oDlgMan, .F.)
			
			oLayerMan:AddLine('MAIN', 80, .F.)
						
				oLayerMan:AddCollumn('MAN_ARQ', 100, .T., 'MAIN')
					
					oLayerMan:AddWindow('MAN_ARQ', 'WIN_MAN_ARQ', "Importação manual de XML", 100, .F., .T., , 'MAIN',)
						
						oFile := TGet():New(02, 02, {|u| IF(Pcount() > 0, cFile := u, cFile)}, oLayerMan:GetWinPanel('MAN_ARQ', 'WIN_MAN_ARQ', 'MAIN'), 200, 12, ,,,,,,, .T.,,,,,,, .F.,,, "cFile",,,,,,, "Arquivo XML"/* Label */)
						oFile:bValid := {|| VldXMLMan(AllTrim(cFile))}
						
						oButton := tButton():New(3, 235, 'Buscar', oLayerMan:GetWinPanel('MAN_ARQ', 'WIN_MAN_ARQ', 'MAIN'), {|| cFile := cGetFile("Arquivos XML(*.XML)|*.xml|", "Arquivos XML", 1,,, nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE), .F., .T.), IIf(Empty(cFile), (cFile := Space(254)), )}, 25, 10, , , , .T.)
						
			oLayerMan:AddLine('BOTTOM', 20, .F.)
				
				oLayerMan:AddCollumn('MAN_BOTTOM', 100, .T., 'BOTTOM')
					
					oPanelBot := tPanel():New(0, 0, "", oLayerMan:GetColPanel('MAN_BOTTOM', 'BOTTOM'),,,,, RGB(239,243,247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_BOTTOM
					
					oQuit := THButton():New(0, 0, "Cancelar", oPanelBot, {|| oDlgMan:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oQuit := THButton():New(0, 0, "Confirmar", oPanelBot, {|| IIf(ImpXMLMan(AllTrim(cFile)), oDlgMan:End(), )}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgMan CENTERED
	
Return

Static Function VldXMLMan(cFile)
	
	If !Empty(cFile) .And. (!File(cFile) .Or. Lower(SubStr(cFile, Len(cFile) - 3)) # ".xml")
		
		MsgAlert("Informe um arquivo de extensão XML válido para importar.", "Arquivo inválido")
		
		Return .F.
		
	EndIf
	
Return .T.

Static Function ImpXMLMan(cFile)
	
	Local cXML    := U_GOMEMO(cFile)
	Local oLogAux := oGOLog
	Local lRet    := .T.
	
	Local lImp    := .F.
	Local aProv   := U_GOX18GPR()

	Local nI

	oGOLog := GOLog():New("importacao_manual", "Importacao_Manual", GOLOG_INFO)
	
	If !Empty(cXML)
		
		If U_GOCargaX(,, @cXML)
			
			Aviso("Importação", "Importação realizada com sucesso!", {"Ok"}, 2)
			
		Else

			For nI := 1 To Len(aProv)

				lImp := U_GOCargaX(,, @cXML, aProv[nI][1])
				
				If lImp 

					Exit

				EndIf

			Next nI
			
			If lImp

				Aviso("Importação", "Importação de nota fiscal de serviço do Provedor " + aProv[nI][1] + " importada com sucesso!", {"Ok"}, 2)

			Else
				
				Aviso("Erro Importação", oGOLog:GetBody(), {"Ok"}, 3)
				
			EndIf

			lRet := .F.
			
		EndIf
		
	Else
		
		MsgInfo("Informe um arquivo válido.", "Arquivo")
		
		lRet := .F.
		
	EndIf
	
	FreeObj(oGOLog)
	
	oGOLog := oLogAux
	
Return lRet

User Function GOMultRet()
	
	Local aAreaTb1 := (_cTab1)->( GetArea() )
	Local cMarkNFe := oBrowseNfe:Mark()
	
	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(4) )
	(_cTab1)->( dbSeek(cMarkNFe) )
	
	While !(_cTab1)->( Eof() ) .And. (_cTab1)->&(_cCmp1 + "_OK") == cMarkNFe
		
		U_GORetorn(_cTab1, (_cTab1)->( RecNo() ), 3)
		
		(_cTab1)->( dbSkip() )
		
	EndDo
	
	RestArea(aAreaTb1)
	
Return

Static Function FreeVet(aVet)
	
	ASize(aVet, 0)
	aVet := Nil
	
Return

User Function GO1VLCST(cCST, nOp)
	
	Local aAreaSX5 := SX5->( GetArea() )
	Local cOrigem
	Local cSitTrib
	Local aRet     := {.F., "", ""}
	
	Default cCST := ""
	Default nOp  := 1
	
	If ValType(cCST) == "C" .And. !Empty(AllTrim(cCST)) .And. Len((cCST := AllTrim(cCST))) == 3
		
		cOrigem  := Left(cCST, 1)
		cSitTrib := Right(cCST, 2)
		
		dbSelectArea("SX5")
		SX5->( dbSetOrder(1) )
		If SX5->( dbSeek(xFilial("SX5") + "S2" + cSitTrib) )
			
			aRet[2] := SX5->X5_DESCRI
			
			If SX5->( dbSeek(xFilial("SX5") + "S0" + cOrigem) )
				
				aRet[1] := .T.
				aRet[3] := SX5->X5_DESCRI
				
			EndIf
			
		EndIf
		
		RestArea(aAreaSX5)
		
	EndIf
	
Return aRet[nOp]

User Function GO1VLCSO(cCSOSN, nOp)
	
	Local aAreaSX5 := SX5->( GetArea() )
	Local aRet     := {.F., ""}
	
	Default cCSOSN := ""
	Default nOp  := 1
	
	If ValType(cCSOSN) == "C" .And. !Empty(AllTrim(cCSOSN)) .And. Len((cCSOSN := AllTrim(cCSOSN))) == 3
		
		dbSelectArea("SX5")
		SX5->( dbSetOrder(1) )
		If SX5->( dbSeek(xFilial("SX5") + "SG" + cCSOSN) )
			
			aRet[1] := .T.
			aRet[2] := SX5->X5_DESCRI
			
		EndIf
		
		RestArea(aAreaSX5)
		
	EndIf
	
Return aRet[nOp]

User Function GO1GRDOK(cTitulo, cMensagem, aHeader, aCols, aButtons)
	
	Local aColSize := AFill(Array(Len(aHeader)), 15)
	Local aSize    := MsAdvSize(.F., .F.)
	Local nX
	Local bExec
	Local cExec := ""
	
	Private oDlgGen
	Private oBrwGen
	Private oLayGen
	Private aHeadGen := aHeader
	Private aColsGen := aCols
	Private nRet     := 0
	
	DEFINE MSDIALOG oDlgGen FROM aSize[7], 0 TO aSize[6]/1.5, aSize[5]/1.7 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgGen:lEscClose := .F.
		
		oLayGen := FWLayer():New()
			oLayGen:Init(oDlgGen, .F.)
				
				oLayGen:AddLine('MSG', 20, .F.)
					
					oLayGen:AddCollumn('COL1_MSG', 100, .T., 'MSG')
						
						oLayGen:AddWindow('COL1_MSG', 'WIN1_COL1_MSG', cTitulo, 100, .F., .T., , 'MSG',)
							
							oTMultiget := TMultiget():New(06, 06, {|u| If(Pcount()>0, cMensagem:=u, cMensagem)}, ;
					              oLayGen:GetWinPanel('COL1_MSG', 'WIN1_COL1_MSG', 'MSG'), 265, 105, , , , , , .T., , , , , , .T.)		
					
							oTMultiget:Align := CONTROL_ALIGN_ALLCLIENT
					
							oTMultiget:EnableVScroll(.T.)
							oTMultiget:EnableHScroll(.T.)
							
				oLayGen:AddLine('TOP', 70, .F.)
					
					oLayGen:AddCollumn('COL1_TOP', 100, .T., 'TOP')
						
						oLayGen:AddWindow('COL1_TOP', 'WIN1_COL1_TOP', "Itens com CST diferente do XML", 100, .F., .T., , 'TOP',)
							
							oBrwGen := TCBrowse():New(01, 01, 000, 000, , aHeadGen, aColSize, oLayGen:GetWinPanel('COL1_TOP', 'WIN1_COL1_TOP', 'TOP'), , , , , {||}, , , , , , , .F., , .T., , .F., , , )
							oBrwGen:SetArray(aColsGen)
							
							For nX := 1 To Len(aHeadGen)
								
								cExec += "oBrwGen:AddColumn(TCColumn():New('" + aHeadGen[nX] + "', {|| aColsGen[oBrwGen:nAt, " + cValToChar(nX) + "]}, , , , 'LEFT', , .F., .T., , , , .F., )) " + CRLF
								
							Next nX
							
							bExec := __COMPSTR(cExec)
							
							__RUNCB(bExec)
							
							oBrwGen:Align := CONTROL_ALIGN_ALLCLIENT
							
				oLayGen:AddLine('BOTTOM', 10, .F.)
					
					oLayGen:AddCollumn('COL1_BOTTOM', 100, .T., 'BOTTOM')
					
					oPanelBot := tPanel():New(0, 0, "", oLayGen:GetColPanel('COL1_BOTTOM', 'BOTTOM'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					For nX := 1 To Len(aButtons)
						
						oOK := THButton():New(0, 0, aButtons[nX][2], oPanelBot, &("{|| nRet := " + cValToChar(aButtons[nX][1]) + ", oDlgGen:End()}"), , , )
						oOK:nWidth  := 160
						oOK:nHeight := 10
						oOK:Align   := CONTROL_ALIGN_RIGHT
						oOK:SetColor(RGB(002, 070, 112), )
						
					Next nX
					
	ACTIVATE MSDIALOG oDlgGen CENTERED //ON INIT 
	
Return nRet

User Function GO1WFCST(aNf, aColsXML)
	
	Local oHTML
	Local nX
	
	If File("\workflow\modelos\importador\CSTDIF.htm")
		
		oProcess := TWFProcess():New("000001", OemToAnsi("Nota inserida com origem de CST diferente"))
		
		oProcess:NewTask("000001", "\workflow\modelos\importador\CSTDIF.htm")
		
		oProcess:cSubject 	:= "Nota inserida com origem de CST diferente"
		oProcess:bReturn  	:= ""
		oProcess:bTimeOut	:= {}
		oProcess:fDesc 		:= "Nota inserida com origem de CST diferente"
		oProcess:ClientName(cUserName)
		
		oHTML := oProcess:oHTML
		
		oHTML:ValByName('cEmpresa', FWGrpName())
		
		oHTML:ValByName('cAmb', GetEnvServer())
		
		oHTML:ValByName('cUsuario', cUserName)
		
		AAdd(oProcess:oHtml:ValByName('xm.cFilial') , xFilial("SF1"))
		AAdd(oProcess:oHtml:ValByName('xm.cNumero') , aNf[1])
		AAdd(oProcess:oHtml:ValByName('xm.cSerie')  , aNf[2])
		AAdd(oProcess:oHtml:ValByName('xm.cFornece'), aNf[3] + "/" + aNf[4])
		AAdd(oProcess:oHtml:ValByName('xm.cEmissao'), DToC(aNf[5]))
		
		For nX := 1 To Len(aColsXML)
			
			AAdd(oProcess:oHtml:ValByName('it.cItem')   , aColsXML[nX][1])
			AAdd(oProcess:oHtml:ValByName('it.cProduto'), aColsXML[nX][2])
			AAdd(oProcess:oHtml:ValByName('it.cDesc')   , aColsXML[nX][3])
			AAdd(oProcess:oHtml:ValByName('it.cCSTO')   , aColsXML[nX][9])
			AAdd(oProcess:oHtml:ValByName('it.cDescCO') , aColsXML[nX][5])
			AAdd(oProcess:oHtml:ValByName('it.cCSTX')   , aColsXML[nX][10])
			AAdd(oProcess:oHtml:ValByName('it.cDescCX') , aColsXML[nX][7])
			
		Next nX
		
		oProcess:cTo := GetNewPar("MV_ZSNCSTD", "octavio@gooneconsultoria.com.br")
		
		// Inicia o processo
		oProcess:Start()
		// Finaliza o processo
		oProcess:Finish()
		
	EndIf
	
Return

User Function GO1GTCST()
	
	Local nPosCST := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CLASFIS"})
	Local cOrig   := "" 
	
	If (IsInCallStack("U_GOX001") .Or. IsInCallStack("U_GOX008")) .And. !IsInCallStack("GeraSConhe") .And. !IsInCallStack("GeraConhec") 					
					
		If IsInCallStack("ImportNFeD") .Or. IsInCallStack("ImportNFeC")
			
			If n <= Len(oGetDItem:aCols)
				
				cOrig := SubStr(oGetDItem:aCols[n][_nPosStTri], 1, 1)
				
				If cOrig == "1"
					
					cOrig := "2"
					
				EndIf
				
				If U_GO1VLCST(cOrig + SubStr(aCols[n][nPosCST], 2, 2))
					
					MaFisRef("IT_CLASFIS", "MT100", cOrig + SubStr(aCols[n][nPosCST], 2, 2))
					
				EndIf
				
			EndIf
			
		ElseIf IsInCallStack("ImportarNFe")
			
			If n <= Len(oGetD:aCols)
				
				cOrig := SubStr(oGetD:aCols[n][_nPosStTri], 1, 1)
				
				If cOrig == "1"
					
					cOrig := "2"
					
				EndIf
				
				If U_GO1VLCST(cOrig + SubStr(aCols[n][nPosCST], 2, 2))
					
					MaFisRef("IT_CLASFIS", "MT100", cOrig + SubStr(aCols[n][nPosCST], 2, 2))
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
Return .T.

User Function GO103Lin(nAT, aSF2)

	Static oNoMarked := LoadBitmap(GetResources(), 'LBNO'			)
	Static oMarked	  := LoadBitmap(GetResources(), 'LBOK'			)
	Local abLine     := {}
	Local nCnt       := 0

	For nCnt := 1 To Len(aSF2[nAT])

		If nCnt == 1

			AAdd(abLine, IIf(aSF2[ nAT, nCnt ], oMarked, oNoMarked))

		Else

			AAdd(abLine, aSF2[ nAT, nCnt ])

		EndIf

	Next nCnt
	
Return abLine

Static Function SetErroRegra(cErro)
	
	RecLock(_cTab1, .F.)
		(_cTab1)->&(_cCmp1 + "_LIBER")  := "2"
		(_cTab1)->&(_cCmp1 + "_ERRO")   := cErro
		(_cTab1)->&(_cCmp1 + "_USUIMP") := cUserName
	(_cTab1)->( MSUnlock() )
	
Return

Static Function AddErroRegra(oBrw, nLinha, nTp)
	
	Local aAreaSD1 := SD1->( GetArea() )
	Local aAreaSD2 := SD2->( GetArea() )
	Local aAreaSX3 := SX3->( GetArea() )
	
	Default nTp := 0
	
	RecLock(_cTab2, .T.)
		
		(_cTab2)->&(_cCmp2 + "_FILIAL") := (_cTab1)->&(_cCmp1 + "_FILIAL")
		(_cTab2)->&(_cCmp2 + "_SEQIMP") := (_cTab1)->&(_cCmp1 + "_SEQIMP")
		
		dbSelectArea("SX3")
		SX3->( dbSetOrder(1) )
		SX3->( dbSeek(_cTab2) )
		
		While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == _cTab2
			
			If GDFieldPos(AllTrim(SX3->X3_CAMPO), oBrw:aHeader) > 0
				
				(_cTab2)->&(SX3->X3_CAMPO) := GDFieldGet(SX3->X3_CAMPO, nLinha,, oBrw:aHeader, oBrw:aCols)
				
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
		// Condições para cada tipo de regra, para poder ter tratamentos diferentes.
		If nTp == 1
			
			If (_cTab1)->&(_cCmp1 + "_TIPOEN") $ "D;B"
				
				//Índice 3 = D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				dbSelectArea("SD2")
				SD2->( dbSetOrder(3) )
				If SD2->( dbSeek(xFilial("SD2") + aMarcNFs[nLinha][1] + aMarcNFs[nLinha][2] + aMarcNFs[nLinha][3] + aMarcNFs[nLinha][4] + aMarcNFs[nLinha][5] + aMarcNFs[nLinha][6]) )
					
					(_cTab2)->&(_cCmp2 + "_CSTERP") := SD2->D2_CLASFIS
					
				EndIf
				
			Else
				
				//Índice 1 = D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				dbSelectArea("SD1")
				SD1->( dbSetOrder(1) )
				If SD1->( dbSeek(xFilial("SD1") + aMarcNFs[nLinha][1] + aMarcNFs[nLinha][2] + aMarcNFs[nLinha][3] + aMarcNFs[nLinha][4] + aMarcNFs[nLinha][5] + aMarcNFs[nLinha][6]) )
					
					(_cTab2)->&(_cCmp2 + "_CSTERP") := SD1->D1_CLASFIS
					
				EndIf
				
			EndIf
			
			(_cTab2)->&(_cCmp2 + "_NFORI")  := aMarcNFs[nLinha][1]
			(_cTab2)->&(_cCmp2 + "_SERORI") := aMarcNFs[nLinha][2]
			(_cTab2)->&(_cCmp2 + "_ITORI")  := aMarcNFs[nLinha][6]
			
		EndIf
		
	(_cTab2)->( MSUnlock() )
	
	RestArea(aAreaSX3)
	RestArea(aAreaSD2)
	RestArea(aAreaSD1)
	
Return

Static Function CleanRegra()
	
	dbSelectArea(_cTab2)
	(_cTab2)->( dbSetOrder(1) )
	(_cTab2)->( dbSeek((_cTab1)->&(_cCmp1 + "_FILIAL") + (_cTab1)->&(_cCmp1 + "_SEQIMP")) )
		
	While !(_cTab2)->( Eof() ) .And. (_cTab2)->&(_cCmp2 + "_FILIAL") == (_cTab1)->&(_cCmp1 + "_FILIAL") .And. (_cTab2)->&(_cCmp2 + "_SEQIMP") == (_cTab1)->&(_cCmp1 + "_SEQIMP")
		
		RecLock(_cTab2, .F.)
			
			dbDelete()
			
		(_cTab2)->( MSUnlock() )
		
		(_cTab2)->( dbSkip() )
		
	EndDo
	
Return

Static Function ExisteRegra(cDesc)
	
	dbSelectArea(_cTab2)
	(_cTab2)->( dbSetOrder(1) )
	(_cTab2)->( dbSeek((_cTab1)->&(_cCmp1 + "_FILIAL") + (_cTab1)->&(_cCmp1 + "_SEQIMP")) )
		
	While !(_cTab2)->( Eof() ) .And. (_cTab2)->&(_cCmp2 + "_FILIAL") == (_cTab1)->&(_cCmp1 + "_FILIAL") .And. (_cTab2)->&(_cCmp2 + "_SEQIMP") == (_cTab1)->&(_cCmp1 + "_SEQIMP")
		
		If (_cTab2)->&(_cCmp2 + "_DESC") == PadR(cDesc, TamSX3(_cCmp2 + "_DESC")[1]) 
			
			Return .T.
			
		EndIf
		
		(_cTab2)->( dbSkip() )
		
	EndDo
	
Return .F.

Static Function IsCTeOS(oXml)
	
	Private oXmlAux := oXml
	
Return Type("oXmlAux:_cteOSProc") == "O"

Static Function IsNodeCTe(oXml, cNode)
	
	Local lRet := .F.
	Local lIsCte := .F.
	
	Private oCTe
	Private oXmlAux := oXml
	
	If Type("oXmlAux:_cteOSProc") == "O"
		
		oCTe := oXmlAux:_cteOSProc:_CTeOS
		
		lIsCte := .T.
		
	ElseIf Type("oXmlAux:_cteProc") == "O"
		
		oCTe := oXmlAux:_cteProc:_CTe
		
		lIsCte := .T.
		
	EndIf
	
	If lIsCte
		
		If Type("oCTe" + IIf(Empty(cNode), "", ":") + cNode) # "U"
			
			lRet := .T.
			
		EndIf
		
	EndIf
	
Return lRet

Static Function GetNodeCTe(oXml, cNode)
	
	Local xRet := Nil
	
	Default cNode := ""
	
	Private oCTe
	Private oXmlAux := oXml
	
	If Type("oXmlAux:_cteOSProc") == "O"
		
		oCTe := oXmlAux:_cteOSProc:_CTeOS
		
	Else
		
		oCTe := oXmlAux:_cteProc:_CTe
		
	EndIf
	
	If Type("oCTe" + IIf(Empty(cNode), "", ":") + cNode) # "U"
		
		xRet := &("oCTe" + IIf(Empty(cNode), "", ":") + cNode)
		
	EndIf
	
Return xRet

Static Function IsNodeNFe(oXml, cNode)
	
	Local lRet := .F.
	Local lIsNFe := .F.
	
	Private oNFe
	Private oXmlAux := oXml
	
	Default cNode := ""
	
	If Type("oXmlAux:_nfeProc") == "O"
		
		oNFe := oXmlAux:_nfeProc:_NFe
		
		lIsNFe := .T.
		
	EndIf
	
	If lIsNFe
		
		If Type("oNFe" + IIf(Empty(cNode), "", ":") + cNode) # "U"
			
			lRet := .T.
			
		EndIf
		
	EndIf
	
Return lRet

Static Function GetNodeNFe(oXml, cNode)
	
	Local xRet := Nil
	
	Default cNode := ""
	
	Private oNFe
	Private oXmlAux := oXml
	
	If Type("oXmlAux:_nfeProc:_NFe") == "O"
		
		oNFe := oXmlAux:_nfeProc:_NFe
		
	EndIf
	
	If Type("oNFe" + IIf(Empty(cNode), "", ":") + cNode) # "U"
		
		xRet := &("oNFe" + IIf(Empty(cNode), "", ":") + cNode)
		
	EndIf
	
Return xRet

Static Function GoGetTes(cProduto, cCliFor, cLoja, cCFOP, cTipo, cDefault)
	
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cRet   := cDefault
	Local cOper
	
	Default cTipo := "1"
	
	If Empty(cProduto) .Or. Empty(cCliFor) .Or. Empty(cLoja)// .Or. Empty(cCFOP)
		
		Return cDefault
		
	EndIf
	
	cOper := DeParaOper(cCFOP)
	
	cQuery := " SELECT FM.FM_TE TES FROM " + RetSqlName("SFM") + " FM WHERE "
	cQuery += " FM.FM_FILIAL = '" + xFilial("SFM") + "' AND "
	cQuery += " FM.FM_PRODUTO = '" + cProduto + "' AND "
	cQuery += " FM.FM_TIPO    = '" + cOper + "' AND "
	
	If cTipo == "1"
		
		cQuery += " FM.FM_FORNECE = '" + cCliFor + "' AND FM.FM_LOJAFOR = '" + cLoja + "' AND "
		
	Else
		
		cQuery += " FM.FM_CLIENTE = '" + cCliFor + "' AND FM.FM_LOJACLI = '" + cLoja + "' AND "
		
	EndIf
	
	cQuery += " FM.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAlias, .F., .T.)
	
	If !(cAlias)->( Eof() )
		
		cRet := (cAlias)->TES
		
	EndIf
	
	(cAlias)->( dbCloseArea() )
	
Return cRet

User Function GOXTESAm(cProduto, cCliFor, cLoja, cTes, cTipo)
	
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cCFOP  := ""
	Local cOper  := ""
	
	Default cTipo := "1"
	
	If Empty(cProduto) .Or. Empty(cCliFor) .Or. Empty(cLoja) .Or. Empty(cTes)
		
		Return ""
		
	EndIf
	
	dbSelectArea("SF4")
	SF4->( dbSetOrder(1) )
	If SF4->( dbSeek(xFilial("SF4") + cTes) )
		
		cCFOP := SF4->F4_CF
		
	EndIf
	
	cOper := DeParaOper(cCFOP)
	
	cQuery := " SELECT FM.R_E_C_N_O_ RECNO FROM " + RetSqlName("SFM") + " FM WHERE "
	cQuery += " FM.FM_FILIAL = '" + xFilial("SFM") + "' AND "
	cQuery += " FM.FM_PRODUTO = '" + cProduto + "' AND "
	cQuery += " FM.FM_TIPO    = '" + cOper + "' AND "
	
	If cTipo == "1"
		
		cQuery += " FM.FM_FORNECE = '" + cCliFor + "' AND FM.FM_LOJAFOR = '" + cLoja + "' AND "
		
	Else
		
		cQuery += " FM.FM_CLIENTE = '" + cCliFor + "' AND FM.FM_LOJACLI = '" + cLoja + "' AND "
		
	EndIf
	
	cQuery += " FM.D_E_L_E_T_ = ' ' "

	// [TODO] filtrar também por filial
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAlias, .F., .T.)
	
	If (cAlias)->( Eof() )
		
		//Criar
		
		RecLock("SFM", .T.)
			
			SFM->FM_FILIAL  := xFilial("SFM")
			SFM->FM_TIPO    := cOper
			SFM->FM_TE      := cTes
			SFM->FM_PRODUTO := cProduto
			
			If cTipo == "1"
				
				SFM->FM_FORNECE := cCliFor
				SFM->FM_LOJAFOR := cLoja
				
			Else
				
				SFM->FM_CLIENTE := cCliFor
				SFM->FM_LOJACLI := cLoja
				
			EndIf
			
		SFM->( MSUnlock() )
		
	Else
		
		SFM->( dbGoTo((cAlias)->RECNO) )
		
		RecLock("SFM", .F.)
			
			SFM->FM_TE := cTes
			
		SFM->( MSUnlock() )
		
	EndIf
	
	(cAlias)->( dbCloseArea() )
	
Return .T.

Static Function DeParaOper(cCFOP)
	
	Local cRet := ""
	
	cRet := GetNewPar("MV_ZGOOPDF", "XM")
	
	//[TODO] Fazer um DE-Para de CFOP e Operação pela SX5 (Criar tabela nova!)
	
Return PadR(cRet, TamSX3("FM_TIPO")[1])

Static Function WFAmarrPrd(oXml)
	
	Local aProd  := GetNodeNFe(oXml, "_infNFe:_det")
	Local cAlias := GetNextAlias()
	Local aWFPrd := {}
	Local cQuery 
	Local nI
	
	If Empty(cEmitCod)
		
		Return
		
	EndIf
	
	If ValType(aProd) == "O"
		
		aProd := {aProd}
		
	EndIf
	
	For nI := 1 To Len(aProd)
	 	
	 	cQuery := " SELECT SA5.A5_PRODUTO FROM " + RetSqlName("SA5") + " SA5 "
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
		cQuery += " SA5.A5_FILIAL  = '" + xFilial("SA5") + "' AND "
		cQuery += " SA5.A5_FORNECE = '" + cEmitCod + "' AND "
		cQuery += " SA5.A5_LOJA    = '" + cEmitLoj + "' AND "
		cQuery += " SA5.A5_CODPRF  = '" + AllTrim(Upper(StrTran(aProd[nI]:_prod:_cProd:Text, "'"))) + "' AND "
		cQuery += " SA5.A5_PRODUTO <> ' '"
	 	
	 	dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAlias, .F., .T.)
		
		If (cAlias)->( Eof() )
	 		
	 		AAdd(aWFPrd, {AllTrim(Upper(StrTran(aProd[nI]:_prod:_cProd:Text, "'"))), aProd[nI]:_prod:_xProd:Text, aProd[nI]:_prod:_NCM:Text})
	 		
	 	EndIf
	 	
	 	(cAlias)->( dbCloseArea() )
	 	
	Next nI
	
	If File("\workflow\modelos\importador\AMARRA_PRODUTO.htm") .And. Len(aWFPrd) > 0
		
		oProcess := TWFProcess():New("000001", OemToAnsi("Produto de XML não amarrado"))
		
		oProcess:NewTask("000001", "\workflow\modelos\importador\AMARRA_PRODUTO.htm")
		
		oProcess:cSubject 	:= "Produto de XML não amarrado"
		oProcess:bReturn  	:= ""
		oProcess:bTimeOut	:= {}
		oProcess:fDesc 		:= "Produto de XML não amarrado"
		oProcess:ClientName(cUserName)
		
		oHTML := oProcess:oHTML
		
		oHTML:ValByName('cNota', cNumNF)
		
		oHTML:ValByName('cCliFor', cEmitCod + "/" + cEmitLoj)
		
		For nI := 1 To Len(aWFPrd)
			
			AAdd(oProcess:oHtml:ValByName('xm.cFilial'), cFilAnt)
			AAdd(oProcess:oHtml:ValByName('xm.cCod')   , aWFPrd[nI][1])
			AAdd(oProcess:oHtml:ValByName('xm.cDesc')  , aWFPrd[nI][2])
			AAdd(oProcess:oHtml:ValByName('xm.cNCM')   , aWFPrd[nI][3])
			
		Next nI
		
		oProcess:cTo := GetNewPar("MV_ZSENCFO", "octavio@gooneconsultoria.com.br")
		
		// Inicia o processo
		oProcess:Start()
		// Finaliza o processo
		oProcess:Finish()
				
	EndIf
	
Return 

Static Function GetPedFor(aItXmlP, cForn, cLoja, lCalc)
	
	Local aRet     := {}
	Local aAreaSC7 := SC7->( GetArea() )
	Local aPed     := {}
	Local aFor
	Local nI
	
	Local lAllFor := GetNewPar("MV_ZPDXMAF", .T.)
	
	Local cInFor
	Local cQuery
	Local cAlias
	
	/// Busca
	
	Local lAchou  := .F.
	
	Local nX
	
	Default lCalc := .F.
	
	Private aItXml := aItXmlP
	Private aItPed := {}
	Private aRelac := {}
	Private aItVin := {{1, "", "", "", "", "", "", "", "", 0, ""}}
	
	dbSelectArea("SC7")
	SC7->( dbSetOrder(2) )
	
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2") + cForn + cLoja) )
	
	If lAllFor
		
		aFor := U_GOX1ALLF(SA2->A2_CGC)
		
	Else
		
		aFor := {{SA2->A2_COD, SA2->A2_LOJA, SA2->A2_MSBLQL}}
		
	EndIf
	
	If Empty(aFor)
		
		Return aRet
		
	EndIf
	
	cInFor := " AND ( "
	
	For nI := 1 To Len(aFor)
		
		If nI == 1
			
			cInFor += "( C7.C7_FORNECE = '" + aFor[nI][1] + "' AND C7.C7_LOJA = '" + aFor[nI][2] + "')"
			
		Else
			
			cInFor += " OR ( C7.C7_FORNECE = '" + aFor[nI][1] + "' AND C7.C7_LOJA = '" + aFor[nI][2] + "')"
			
		EndIf
		
	Next nI
	
	cInFor += ") "
	
	cQuery := " SELECT "
	cQuery += " C7.C7_NUM, C7.C7_ITEM, C7.C7_PRODUTO, C7.C7_DESCRI, C7.C7_QUANT, C7.C7_QUJE, C7.C7_PRECO, C7.C7_TOTAL, C7.C7_EMISSAO "
	cQuery += " FROM " + RetSqlName("SC7") + " C7 "
	//cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_COD = C7.C7_PRODUTO AND B1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE C7.D_E_L_E_T_ = ' ' AND C7.C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += " 	AND (C7.C7_QUANT - C7.C7_QUJE - C7.C7_QTDACLA) > 0 AND C7.C7_RESIDUO = ' ' AND C7.C7_TPOP <> 'P' AND C7.C7_CONAPRO <> 'B' "
	cQuery += cInFor
	
	cAlias := MpSysOpenQuery(cQuery)
		
	If (cAlias)->( Eof() )
		
		aItPed := {{2, "", "", "", "", "", "", "", CToD("  /  /    "), "", ""}}
		
	Else
		
		While !(cAlias)->( Eof() )
			
			AAdd(aItPed, {;
				2, ;
				(cAlias)->C7_NUM, ;
				(cAlias)->C7_ITEM, ;
				(cAlias)->C7_PRODUTO, ;
				(cAlias)->C7_DESCRI, ;
				((cAlias)->C7_QUANT - (cAlias)->C7_QUJE), ;
				(cAlias)->C7_PRECO, ;
				(cAlias)->C7_TOTAL, ;
				SToD((cAlias)->C7_EMISSAO), ;
				"Pedido", ;
				"P" ;
			})
			
			(cAlias)->( dbSkip() )
			
		EndDo
		
	EndIf
	
	//StaticCall(GOX001PED, VincAut, .T., lCalc)
	
	U_GOX1VA(.T., lCalc)
	
	// Verificar Arrays de Saída
	
	//aRelac
	
	If Len(aRelac) > 0
		
		For nI := 1 To Len(aRelac)
			
			For nX := 1 To Len(aRelac[nI][2])
				
				AAdd(aRet, {aRelac[nI][1][1], aRelac[nI][2][nX][1], aRelac[nI][2][nX][2]})
				
			Next nX
			
		Next nI
		
	EndIf
		
	/*If Len(aPed) > 0
		
		ASort(aPed,,, {|x, y| x[4] < y[4]})
		
		For nI := 1 To Len(aPed)
			
			If nQuant == aPed[nI][5] .And. (nVUnit == aPed[nI][6] .Or. (nVUnit - aPed[nI][6]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. nTotal == aPed[nI][7]
				
				aRet[1] := .T.
				
				aRet[2] := aPed[nI][2]
				aRet[3] := aPed[nI][3]
				
				AAdd(aJaPed, {aPed[nI][1], aPed[nI][2], aPed[nI][3]})
				
				Exit
				
			EndIf
			
		Next nI
		
		If !aRet[1]
			
			For nI := 1 To Len(aPed)
				
				If nQuant < aPed[nI][5] .And. (nVUnit == aPed[nI][6] .Or. (nVUnit - aPed[nI][6]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. nTotal == aPed[nI][7]
					
					aRet[1] := .T.
					
					aRet[2] := aPed[nI][2]
					aRet[3] := aPed[nI][3]
					
					AAdd(aJaPed, {aPed[nI][1], aPed[nI][2], aPed[nI][3]})
					
					Exit
					
				EndIf
				
			Next nI
		
		EndIf
		
		If !aRet[1]
			
			For nI := 1 To Len(aPed)
				
				If nQuant < aPed[nI][5] .And. (nVUnit == aPed[nI][6] .Or. (nVUnit - aPed[nI][6]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. nTotal == aPed[nI][7]
					
					aRet[1] := .T.
					
					aRet[2] := aPed[nI][2]
					aRet[3] := aPed[nI][3]
					
					AAdd(aJaPed, {aPed[nI][1], aPed[nI][2], aPed[nI][3]})
					
					Exit
					
				EndIf
				
			Next nI
		
		EndIf
		
		If !aRet[1]
			
			For nI := 1 To Len(aPed)
				
				If (nVUnit == aPed[nI][6] .Or. (nVUnit - aPed[nI][6]) < GetNewPar("MV_ZTOLUNP", 0.005)) .And. nTotal == aPed[nI][7]
					
					aRet[1] := .T.
					
					aRet[2] := aPed[nI][2]
					aRet[3] := aPed[nI][3]
					
					AAdd(aJaPed, {aPed[nI][1], aPed[nI][2], aPed[nI][3]})
					
					Exit
					
				EndIf
				
			Next nI
		
		EndIf
		
	EndIf*/
	
	RestArea(aAreaSC7)
	
Return aRet

Static Function UMAmarra(cProd, cUMFor, cUM, cEmit, cLoj, nFor, nNossa, lFor)
	
	Default lFor := .T.
	
	dbSelectArea(_cTab4)
	
	If Empty(cUMFor) .Or. Empty(cUM)
		
		Return
		
	EndIf
	
	If lFor
		
		(_cTab4)->( dbSetOrder(3) )
		
	Else
		
		(_cTab4)->( dbSetOrder(5) )
		
	EndIf
	
	If !(_cTab4)->( dbSeek(xFilial(_cTab4) + cEmit + cLoj + cProd + cUMFor + cUM) )
		
		RecLock(_cTab4, .T.)
			
			(_cTab4)->&(_cCmp4 + "_FILIAL") := xFilial(_cTab4)
			(_cTab4)->&(_cCmp4 + "_PRODUT") := cProd
			(_cTab4)->&(_cCmp4 + "_UMORIG") := cUMFor
			(_cTab4)->&(_cCmp4 + "_UMDEST") := cUM
			(_cTab4)->&(_cCmp4 + "_FATOR")  := Round(nNossa / nFor, TamSX3(_cCmp4 + "_FATOR")[2])
			(_cTab4)->&(_cCmp4 + "_OPERA")  := "*"
			
			If lFor
				
				(_cTab4)->&(_cCmp4 + "_FORN")   := cEmit
				(_cTab4)->&(_cCmp4 + "_LOJFOR") := cLoj
				
			Else
				
				(_cTab4)->&(_cCmp4 + "_CLIENT") := cEmit
				(_cTab4)->&(_cCmp4 + "_LOJCLI") := cLoj
				
			EndIf
			
		(_cTab4)->( MSUnlock() )
		
	Else
		
		RecLock(_cTab4)
			
			(_cTab4)->&(_cCmp4 + "_FATOR")  := Round(nNossa / nFor, TamSX3(_cCmp4 + "_FATOR")[2])
			
		(_cTab4)->( MSUnlock() )
		
	EndIf
	
Return

Static Function ImpClassNf()
	
	Local aCabec
	
	Local cTes   := ""
	Local cTesP  := PadR(GetNewPar("MV_ZGOTESE", ""), TamSX3("D1_TES")[1])
	Local cNat   := ""
	Local cNatP  := PadR(GetNewPar("MV_ZGONATE", ""), TamSX3("ED_CODIGO")[1])
	
	Local aRecD1 := {}
	
	Private aXItens := {}
	
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .F.
	
	Private nValFrete  := Val(GetNodeNFe(oXml, "_InfNfe:_total:_ICMSTot:_vFrete:Text"))
	Private nValSeguro := Val(GetNodeNFe(oXml, "_InfNfe:_total:_ICMSTot:_vSeg:Text"))
	Private nValDesp   := Val(GetNodeNFe(oXml, "_InfNfe:_total:_ICMSTot:_vOutro:Text"))
	Private nValDesc   := Val(GetNodeNFe(oXml, "_InfNfe:_total:_ICMSTot:_vDesc:Text"))
	Private nValMerc   := Val(GetNodeNFe(oXml, "_InfNfe:_total:_ICMSTot:_vProd:Text"))
	Private nValXIPI   := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vIPI:Text"))
	Private nValXST    := Val(GetNodeNFe(oXml, "_infNfe:_total:_ICMSTot:_vST:Text"))
	
	dbSelectArea("SF1")
	SF1->( dbSetOrder(1) )
	
	If SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) )
		
		dbSelectArea("SA2")
		SA2->( dbSetOrder(1) )
		If SA2->( dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA) )
			
			cNat := SA2->A2_NATUREZ
			
		EndIf
		
		If Empty(cNat)
			
			cNat := cNatP
			
		EndIf
		
		aCabec := {{"F1_DOC"    , SF1->F1_DOC    , Nil, Nil}, ;
		           {"F1_SERIE"  , SF1->F1_SERIE  , Nil, Nil}, ;
		           {"F1_FORNECE", SF1->F1_FORNECE, Nil, Nil}, ;
		           {"F1_LOJA"   , SF1->F1_LOJA   , Nil, Nil}, ;
		           ;//{"F1_COND"   , SF1->F1_COND   , Nil, Nil}, ;
		           {"F1_EMISSAO", SF1->F1_EMISSAO, Nil, Nil}, ;
		           {"F1_DTDIGIT", SF1->F1_DTDIGIT, Nil, Nil}, ;      
		           {"F1_EST"    , SF1->F1_EST    , Nil, Nil}, ;      
		           {"F1_TIPO"   , SF1->F1_TIPO   , Nil, Nil}, ;
		           {"F1_ESPECIE", SF1->F1_ESPECIE, Nil, Nil}, ;
		           {"F1_FORMUL" , SF1->F1_FORMUL , Nil, Nil}, ;
		           {"F1_CHVNFE" , SF1->F1_CHVNFE , Nil, Nil}, ;
		           {"E2_NATUREZ", cNat           , Nil, Nil} ;
		          }
		
		dbSelectArea("SD1")
		SD1->( dbSetOrder(1) )
		SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
		
		While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
		      SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
		      
		    AAdd(aRecD1, SD1->( Recno() ))
		      
			AAdd(aXItens, {{"LINPOS", "D1_ITEM" , SD1->D1_ITEM}, ;
						  {"D1_COD"   , SD1->D1_COD    , Nil}, ;
			              {"D1_UM"    , SD1->D1_UM     , Nil}, ;
			              {"D1_OPER"  , PadR(GetNewPar("MV_ZGOOPDF", "XM"), TamSX3("D1_OPER")[1]), Nil}, ;
			              ;//{"D1_TIPO"  , SD1->D1_TIPO   , Nil}, ;
			              {"D1_SERIE" , SD1->D1_SERIE  , Nil}, ;
			              {"AUTDELETA", "N"            , Nil};
			             })
			
			If !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
				
				AAdd(ATail(aXItens), {"LINPOS", "D1_PEDIDO", SD1->D1_PEDIDO})
				AAdd(ATail(aXItens), {"LINPOS", "D1_ITEMPC", SD1->D1_ITEMPC})
				
			EndIf
			
			If !Empty(SD1->D1_LOCAL)
				
				AAdd(ATail(aXItens), {"D1_LOCAL", SD1->D1_LOCAL, Nil})
				
			EndIf
			
			//AAdd(ATail(aXItens), {"LINPOS", "D1_ITEM", SD1->D1_ITEM})
			
			cTes := GoGetTes(SD1->D1_COD, SF1->F1_FORNECE, SF1->F1_LOJA, "XM", IIf(SF1->F1_TIPO $ "D;B", "2", "1"), Posicione("SB1", 1, SD1->D1_COD, "B1_TE"))
			
			If !Empty(cTes) 
				
				AAdd(ATail(aXItens), {"D1_TES", cTes, Nil})
				
				RecLock("SD1")
					
					SD1->D1_TESACLA := cTes
					
				SD1->( MsUnlock() )
				
			ElseIf !Empty(cTesP)
				
				AAdd(ATail(aXItens), {"D1_TES", cTesP, Nil})
				
				RecLock("SD1")
					
					SD1->D1_TESACLA := cTesP
					
				SD1->( MsUnlock() )
				
			Else
				
				RecLock(_cTab1, .F.)
					(_cTab1)->&(_cCmp1 + "_ERRO") := "Não foi encontrada amarração de TES para o produto, nem TES padrão no cadastro do Produto. Informa a TES padrão de entrada no cadastro do produto."
				(_cTab1)->( MSUnlock() )
				
				Return .F.
				
			EndIf
			
			//AAdd(ATail(aXItens), {"D1_QUANT", SD1->D1_QUANT, Nil})
  			AAdd(ATail(aXItens), {"D1_VUNIT", SD1->D1_VUNIT, Nil})
     		//AAdd(ATail(aXItens), {"D1_TOTAL", SD1->D1_TOTAL, Nil})
			
			AAdd(ATail(aXItens), {"D1_VALDESC", SD1->D1_VALDESC, Nil})
			AAdd(ATail(aXItens), {"D1_VALFRE" , SD1->D1_VALFRE , Nil})
			AAdd(ATail(aXItens), {"D1_SEGURO" , SD1->D1_SEGURO , Nil})
			AAdd(ATail(aXItens), {"D1_DESPESA", SD1->D1_DESPESA, Nil})
			
			SD1->( dbSkip() )
			
		EndDo
		
		ASort(aXItens,,, {|x, y| x[1][3] < y[1][3]})
		
		// Perguntar se deseja alterar as Tes já selecionadas para os produtos
		If GetNewPar("MV_ZCLPRTT", .T.) .And. MsgYesNo("Deseja alterar as TES que foram selecionadas automaticamente para os produtos?")
			
			AltTesClas(aXItens, aRecD1)
			
		EndIf
		
		SD1->( dbSetOrder(3) )
		
		//PutMv("MV_LIBQTEM", .T.)
		
		FwMsgRun(, {|| MsExecAuto({|x, y, z, w| MATA103(x, y, z, w)}, aCabec, aXItens, 4, .T.)}, "Aguarde", "Classificando Nota...")
		
		//PutMv("MV_LIBQTEM", .F.)
		
		//SetFunName("MATA103")
		
		//ClassDoc(.T.)
		
		//SetFunName("U_GOX008")
		
		If lMsErroAuto
			
			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1 + "_ERRO") := MontaErro(GetAutoGrLog())
			(_cTab1)->( MSUnlock() )
			
		ElseIf SF1->( dbSeek(xFilial("SF1") + (_cTab1)->&(_cCmp1 + "_DOC") + (_cTab1)->&(_cCmp1 + "_SERIE") + (_cTab1)->&(_cCmp1 + "_CODEMI") + (_cTab1)->&(_cCmp1 + "_LOJEMI")) ) .And. ;
			Empty(SF1->F1_STATUS)
			
			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1 + "_ERRO") := "Cancelado pelo usuário."
			(_cTab1)->( MSUnlock() )
			
		Else
			
			RecLock(_cTab1, .F.)
				(_cTab1)->&(_cCmp1 + "_ERRO") := ""
			(_cTab1)->( MSUnlock() )
			
		EndIf
		
	EndIf
	
Return

Static Function AltTesClas(aXItens, aRecD1)
	
	Local nI
	Local nX
	
	Local nPos
	
	Local aCampos := {"D1_ITEM", "D1_COD", "D1_DESCRI", "D1_QUANT", "D1_VUNIT", "D1_TOTAL", "D1_TES"}
	Local aAlt    := {"D1_TESALT"}
	
	Local aAreaSD1 := SD1->( GetArea() )
	
	Private aColsAlt := {}
	Private aHeaderAlt := {}
	
	Private oDlgAlt
	Private oLayAlt
	Private oGetAlt
	
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	
	For nI := 1 To Len(aCampos)
		
		If SX3->( dbSeek(aCampos[nI]) )
			
			If aCampos[nI] $ "D1_TES"
				
				AAdd(aHeaderAlt, {Trim(X3Titulo()), "D1_TESALT ", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "U_GOXRep(oGetAlt)", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
				
			Else
				
				AAdd(aHeaderAlt, {Trim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
				
			EndIf
			
		EndIf
		
	Next nI
						
	For nI := 1 To Len(aXItens)
		
		AAdd(aColsAlt, {})
		
		For nX := 1 To Len(aHeaderAlt)
			
			/*If AllTrim(aHeaderAlt[nX][2]) == "D1_DESCRI"
				
				nPos  := AScan(aXItens[nI], {|x| x[1] == "D1_COD"})
				
				AAdd(ATail(aColsAlt), Posicione("SB1", 1, xFilial("SB1") + aXItens[nI][nPos][2], "B1_DESC"))
				
			Else*/If AllTrim(aHeaderAlt[nX][2]) == "D1_TESALT"
				
				nPos  := AScan(aXItens[nI], {|x| x[1] == "D1_TES"})
				
				AAdd(ATail(aColsAlt), aXItens[nI][nPos][2])
				
			Else
				
				SD1->( dbGoTo(aRecD1[nI]) )
				
				AAdd(ATail(aColsAlt), SD1->&(aHeaderAlt[nX][2]))
				
				/*nPos  := AScan(aXItens[nI], {|x| (x[1] == AllTrim(aHeaderAlt[nX][2])) .Or. ;
					(AllTrim(x[1]) == "LINPOS" .And. x[2] == AllTrim(aHeaderAlt[nX][2]))})
				
				If nPos > 0
					
					If Empty(aXItens[nI][nPos][3])
						AAdd(ATail(aColsAlt), aXItens[nI][nPos][2])
					Else
						AAdd(ATail(aColsAlt), aXItens[nI][nPos][3])
					EndIf
					
				Else
					
					AAdd(ATail(aColsAlt), CriaVar(aHeaderAlt[nX][2], .T.))
					
				EndIf*/
				
			EndIf
			
		Next nX
		
		AAdd(ATail(aColsAlt), .F.)
		
	Next nI
	
	// Tela
	
	DEFINE MSDIALOG oDlgAlt FROM aSize[7], 0 TO aSize[6]/1.2, aSize[5]/1.2 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgAlt:lEscClose := .F.
		
		oLayAlt := FWLayer():New()
		oLayAlt:Init(oDlgAlt, .F.)
			
			oLayAlt:AddLine('LIN1', 95, .F.)
				
				oLayAlt:AddCollumn('COL1_LIN1', 100, .T., 'LIN1')
					
					oLayAlt:AddWindow('COL1_LIN1', 'WIN1_COL1_LIN1', "Alteração TES para Classificar", 100, .F., .T., , 'LIN1',)
						
						oGetAlt := MsNewGetDados():New(011, 010, 190, aSize[6] + 90, GD_UPDATE, "AlwaysTrue", "AlwaysTrue", "", aAlt, 000, 999, Nil, Nil, "AlwaysFalse", oLayAlt:GetWinPanel('COL1_LIN1', 'WIN1_COL1_LIN1', 'LIN1'), aHeaderAlt, aColsAlt)
						oGetAlt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						
						/*oGetAlt:aInfo[nPosNumSC][5] := " "
						oGetAlt:aHeader[nPosNumSC][14] := " "
						
						oGetAlt:aInfo[nPosItSC][5] := " "
						oGetAlt:aHeader[nPosItSC][14] := " "*/
						
			oLayAlt:AddLine('LIN2', 5, .F.)
				
				oLayAlt:AddCollumn('COL1_LIN2', 100, .T., 'LIN2')
					
					oPanelBot := tPanel():New(0, 0, "", oLayAlt:GetColPanel('COL1_LIN2', 'LIN2'), , , , , RGB(239, 243, 247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_ALLCLIENT
					
					oQuit := THButton():New(0, 0, "&Cancelar", oPanelBot, {|| oDlgAlt:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align   := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oImp := THButton():New(0, 0, "&Confirmar", oPanelBot, {|| IIf(ConfAltTes(aXItens), oDlgAlt:End(), )}, , , )
					oImp:nWidth  := 90
					oImp:nHeight := 10
					oImp:Align := CONTROL_ALIGN_RIGHT
					oImp:SetColor(RGB(002, 070, 112), )
	
	ACTIVATE MSDIALOG oDlgAlt CENTERED
	
	RestArea(aAreaSD1)
	
Return

Static Function ConfAltTes(aXItens)
	
	Local nI
	Local nPosTes := AScan(oGetAlt:aHeader, {|x| AllTrim(x[2]) == "D1_TESALT"})
	Local nPosAlt
	
	For nI := 1 To Len(oGetAlt:aCols)
		
		nPosAlt := AScan(aXItens[nI], {|x| x[1] == "D1_TES"})
		
		aXItens[nI][nPosAlt][2] := oGetAlt:aCols[nI][nPosTes]
		
	Next nI
	
Return .T.

Static Function DesagruNfe()
	
	Local aColsIt  := AClone(oGetD:aCols)
	Local nI
	Local nIt
	
	Local nTamDTot := TamSX3("D1_TOTAL")[2]
	
	Local nQtdFor
	Local nQtdNo
	
	//// Variáveis da tela
	Local oDlg1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oBtn1
	Local oBtn2
	Local lConfirma := .F.
	Local nLineAtu  := oGetD:nAt
	
	Private oGet1
	Private oGet2
	
	Private nQuantAnt := GDFieldGet(_cCmp2 + "_QUANT2", oGetD:nAt, , oGetD:aHeader, oGetD:aCols)
	Private nQuantAtu := 0
	Private nQuantIt  := 1
	
	If nQuantAnt <= 0
	    
		Help(, , 'Quantidade zero', , "A quantidade do item selecionado não poderá ser 0 para desagrupar.", 1, 0)
	    
	EndIf
	
	oDlg1 := MSDialog():New(091,232,289,583,"Desagrupar item",,,.F.,,,,,,.T.,,,.T.)
	oSay1 := TSay():New(006,008,{||"Informe o valor da quantidade no novo item:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,152,008)
	
	oSay2 := TSay():New(028,008,{||"Qtde. item atual"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
	oGet1 := TGet():New(024,056, {|u| IF(Pcount() > 0, nQuantAnt := u, nQuantAnt)},oDlg1,088,014,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",, {|| .F.},.F.,.F.,,.F.,.F.,"","nQuantAnt",, )
	
	oSay3 := TSay():New(049,009,{||"Qtde. novo item"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
	oGet2 := TGet():New(044,056, {|u| IF(Pcount() > 0, nQuantAtu := u, nQuantAtu)},oDlg1,088,014,'@E 999,999.9999', {|| VldDesgNfe()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nQuantAtu",, )
	
	oSay4 := TSay():New(070,009,{||"Qtde. Itens Ad."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
	oGet3 := TGet():New(064,056, {|u| IF(Pcount() > 0, nQuantIt := u, nQuantIt)},oDlg1,088,014,'@ 99', {|| VldDesgNfe()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nQuantIt",, )
	
	oBtn1 := TButton():New(082,026,"Confirmar",oDlg1, {|| IIf(ConfDesg(), (lConfirma := .T., oDlg1:End()), )},044,016,,,,.T.,,"",,,,.F.)
	oBtn2 := TButton():New(082,099,"Cancelar",oDlg1, {|| oDlg1:End()},044,016,,,,.T.,,"",,,,.F.)
	
	oDlg1:Activate(,,,.T.)
	
	If lConfirma .And. nQuantAtu > 0
		
		nQtdFor := GDFieldGet(_cCmp2 + "_QUANT1", nLineAtu, , oGetD:aHeader, oGetD:aCols)
		nQtdNo  := GDFieldGet(_cCmp2 + "_QUANT2", nLineAtu, , oGetD:aHeader, oGetD:aCols)
		
		For nIt := 1 To nQuantIt
			
			AAdd(aColsIt, Array(Len(aHeader) + 1))
			
			ATail(aColsIt)[Len(aHeader) + 1] := .F.
			
			For nI := 1 To Len(aHeader)
				
				If AllTrim(aHeader[nI][2]) == _cCmp2 + "_QUANT1"
					
					ATail(aColsIt)[nI] := (nQtdFor * nQuantAtu) / nQtdNo
					
				ElseIf AllTrim(aHeader[nI][2]) == _cCmp2 + "_QUANT2"
					
					ATail(aColsIt)[nI] := nQuantAtu
					
				ElseIf AllTrim(aHeader[nI][2]) == _cCmp2 + "_TOTAL"
					
					ATail(aColsIt)[nI] := Round(nQuantAtu * GDFieldGet(_cCmp2 + "_VUNIT", oGetD:nAt, , oGetD:aHeader, oGetD:aCols), nTamDTot)
					
				Else
					
					ATail(aColsIt)[nI] := GDFieldGet(aHeader[nI][2], oGetD:nAt, , oGetD:aHeader, oGetD:aCols)
					
				EndIf
				
			Next nI
			
		Next nIt
		
		oGetD:SetArray(aColsIt, .T.)
		
		oGetD:oBrowse:Refresh()
		
		//Fazer proporção
		GDFieldPut(_cCmp2 + "_QUANT1", (nQtdFor * nQuantAnt) / nQtdNo, nLineAtu, oGetD:aHeader, oGetD:aCols)
		
		GDFieldPut(_cCmp2 + "_QUANT2", nQuantAnt, nLineAtu, oGetD:aHeader, oGetD:aCols)
		
		GDFieldPut(_cCmp2 + "_TOTAL", Round(nQuantAnt * GDFieldGet(_cCmp2 + "_VUNIT", nLineAtu, , oGetD:aHeader, oGetD:aCols), nTamDTot), nLineAtu, oGetD:aHeader, oGetD:aCols)
		
	EndIf
	
Return

Static Function VldDesgNfe()
	
	Local nQtde := Round(nQuantAtu * nQuantIt, TamSX3("D1_QUANT")[2])
	
	If nQuantAtu <= 0
		
		Help(, , 'Help', , "A nova quantidade deve ser maior que 0.", 1, 0)
		
		Return .F.
		
	EndIf
	
	If nQuantIt <= 0
		
		Help(, , 'Help', , "A quantidade de novos itens deve ser maior que 0.", 1, 0)
		
		Return .F.
		
	EndIf
	
	If nQtde >= GDFieldGet(_cCmp2 + "_QUANT2", oGetD:nAt, , oGetD:aHeader, oGetD:aCols)
		
		Help(, , 'Help', , "A nova quantidade não pode ultrapassar a original.", 1, 0)
		
		Return .F.
		
	EndIf
	
	nQuantAnt := GDFieldGet(_cCmp2 + "_QUANT2", oGetD:nAt, , oGetD:aHeader, oGetD:aCols) - nQtde
	
	oGet1:Refresh()
	
Return .T.

Static Function SetStatusXML(cTab, cStatus, nPos, lRefresh)

	Local aSit := {"Normal", "Importada", "Com erro", "Doc. de Entrada não existe", "Cancelad" + GetDescXml(cTab)[1]}
	
	Default nPos     := 0
	Default lRefresh := .T.
	
	RecLock(_cTab1, .F.)
		
		(_cTab1)->&(_cCmp1 + "_SIT") := cStatus
		
	(_cTab1)->( MsUnlock() )
	
	Do Case
	
		Case cTab == "NFE"
		
			oGoLog:Add("*Situação da Nota Fical alterada para: " + aSit[Val(cStatus)] + ".", nPos)
			oGoLog:Add("-Filial: " + (_cTab1)->&(_cCmp1 + "_FILIAL"), 1 + nPos)
			oGoLog:Add("-Seq. Importação: " + (_cTab1)->&(_cCmp1 + "_SEQIMP"), 1 + nPos)
			oGoLog:Add("-Número Nota: " + (_cTab1)->&(_cCmp1 + "_DOC"), 1 + nPos)
			oGoLog:Add("-Série: " + (_cTab1)->&(_cCmp1 + "_SERIE"), 1 + nPos)
			oGoLog:Add("-Chave: " + (_cTab1)->&(_cCmp1 + "_CHAVE"), 1 + nPos)
			
		Case cTab == "CTE"
		
			oGoLog:Add("*Situação do Conhecimento de Transporte alterada para: " + aSit[Val(cStatus)] + ".", nPos)
			oGoLog:Add("-Filial: " + (_cTab1)->&(_cCmp1 + "_FILIAL"), 1 + nPos)
			oGoLog:Add("-Seq. Importação: " + (_cTab1)->&(_cCmp1 + "_SEQIMP"), 1 + nPos)
			oGoLog:Add("-Número Conhecimento: " + (_cTab1)->&(_cCmp1 + "_DOC"), 1 + nPos)
			oGoLog:Add("-Série: " + (_cTab1)->&(_cCmp1 + "_SERIE"), 1 + nPos)
			oGoLog:Add("-Chave: " + (_cTab1)->&(_cCmp1 + "_CHAVE"), 1 + nPos)
			
		Case cTab == "CAN"
			
			oGoLog:Add("*Situação do Cancelamento alterada para: " + aSit[Val(cStatus)] + ".", nPos)
			oGoLog:Add("-Filial: " + (_cTab1)->&(_cCmp1 + "_FILIAL"), 1 + nPos)
			oGoLog:Add("-Seq. Importação: " + (_cTab1)->&(_cCmp1 + "_SEQIMP"), 1 + nPos)
			oGoLog:Add("-Número Conhecimento: " + (_cTab1)->&(_cCmp1 + "_DOC"), 1 + nPos)
			oGoLog:Add("-Série: " + (_cTab1)->&(_cCmp1 + "_SERIE"), 1 + nPos)
			oGoLog:Add("-Chave: " + (_cTab1)->&(_cCmp1 + "_CHAVE"), 1 + nPos)
			
	EndCase
	
	oGoLog:NewLine()
	
Return

Static Function GetDescXml(cKey)

    //Local cKey := GetActiveTab()
    Local aDesc := {{"NFE", {"a", "as", "Nota Fiscal", "Notas Fiscais"}}, ;
    				{"CTE", {"o", "os", "Conhecimento de Transporte", "Conhecimentos de Transporte"}}, ;
    				{"CCE", {"a", "as", "Carta de Correção", "Cartas de Correção"}}, ;
    				{"MDE", {"o", "os", "Manifesto", "Manifestos"}}, ;
    				{"CAN", {"o", "os", "Cancelamento", "Cancelamentos"}}, ;
    				{"ALL", {"o", "os", "Documento", "Documentos"}} ;
    			   }
	
Return aDesc[AScan(aDesc, {|x| x[1] == cKey}), 2]

User Function GOX1ALLF(cCNPJ)

	Local aFor      := {}
	Local cMeioCNPJ := ""
	Local cSa2      := GetNextAlias()
	Local cQuery    := ""
	
	If Empty(cCNPJ)
		
		Return {}
		
	EndIf
	
	cMeioCNPJ := SubStr(AllTrim(cCNPJ), 1, 8)  // Pega os primeiros 8 dígitos
	
	cQuery := " SELECT SA2.A2_COD, "
	cQuery += "        SA2.A2_LOJA, "
	cQuery += "        SA2.A2_CGC, "
	cQuery += "        SA2.A2_MSBLQL, "
	cQuery += "        SA2.A2_NREDUZ, "
	cQuery += "        '' INCORP "
	cQuery += " FROM " + RetSqlName("SA2") + " SA2 "
	cQuery += " WHERE SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
	cQuery += " AND   SA2.A2_CGC LIKE '" + cMeioCNPJ + "%' "
	cQuery += " AND   SA2.D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cSa2, .F., .T.)
	
	// A primeira linha deve ser do CNPJ Informado
	AAdd(aFor, {"", "", ""})
	
	While !(cSa2)->( Eof() )
	
		If (cSa2)->A2_CGC == cCNPJ
			
			If Empty(aFor[1][1])
				
				aFor[1][1] := (cSa2)->A2_COD
				aFor[1][2] := (cSa2)->A2_LOJA
				aFor[1][3] := (cSa2)->A2_MSBLQL
				
			ElseIf (cSa2)->A2_MSBLQL <> '1' .And. aFor[1][3] == '1'
				
				AAdd(aFor, {aFor[1][1], aFor[1][2], aFor[1][3]})
				
				aFor[1][1] := (cSa2)->A2_COD
				aFor[1][2] := (cSa2)->A2_LOJA
				aFor[1][3] := (cSa2)->A2_MSBLQL
				
			Else
				
				AAdd(aFor, {(cSa2)->A2_COD, (cSa2)->A2_LOJA, (cSa2)->A2_MSBLQL})
				
			EndIf
			
		Else
			
			AAdd(aFor, {(cSa2)->A2_COD, (cSa2)->A2_LOJA, (cSa2)->A2_MSBLQL})
			
		EndIf
		
		(cSa2)->( dbSkip() )
		
	EndDo
	
	(cSa2)->( dbCloseArea() )
	
Return aFor

/* ####################################################################### *\
|| #             CARGA INICIAL DOS XML DA PASTA DE ENTRADAS              # ||
\* ####################################################################### */
Static Function ReCarga(cChave)
	
	Default cChave := ""
	
	Private oProcess
	
	oProcess := MsNewProcess():New({|| U_GOX004(,,cChave)}, "Aguarde...", "Processando XML's.")
	oProcess:Activate()
	
	If lVlErrMsg
	
		lVlErrMsg := .F.
		
	EndIf
	
Return .T.

// Função que infica que é um CT-e de remessa.
Static Function IsCteRem()
	
	Local lRet       := .F.
	Local cCfPrdFrt  := AllTrim(GetNewPar("MV_ZCFCTEP", "")) // Novo, indica os finais de CFOP que leva para o produto de frete padrão
	Local nI
	Local aAreaSF1   := SF1->( GetArea() )
	Local lSoRemessa := .T.
	
	For nI := 1 To Len(aNotasAux)
		
		dbSelectArea("SF1")
		// Numero + Serie + Fornecedor + Loja + Tipo da Nota
		SF1->( dbSetOrder(1) )
		If SF1->( dbSeek(aNotasAux[nI][1][2]) )
			
			dbSelectArea("SD1")
			SD1->( dbSetOrder(1) )
			If SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
				
				While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
				      SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
				     
				     If !(Right(SD1->D1_CF, 3) $ cCfPrdFrt)
				     
				     	lSoRemessa := .F.
				     	Exit
				     	
				     EndIf
				     
				     SD1->( dbSkip() )
				      
				EndDo
				
				lRet := lSoRemessa
				
			EndIf
			
		EndIf
		
	Next nI
	
	RestArea(aAreaSF1)
	
	If !lSoRemessa .And. GetNewPar("MV_ZGOCTTP", .F.)
		
		If Type("oXML:_cteProc:_Cte:_InfCte:_Ide:_TPSERV") == "O"
			
			If AllTrim(oXML:_cteProc:_Cte:_InfCte:_Ide:_TPSERV:Text) == "1"
				
				lRet := .T.
				
			EndIf
			
		EndIf
		
	EndIf
	
Return lRet

User Function GOX1IMPX()
	
	If (_cTab1)->&(_cCmp1 + "_TIPO") # "1"
		
		Alert("Somente será permitido impressão da DANFE para notas modelo 55.")
		
		Return .F.
		
	EndIf
	
	FwMsgRun(, {|| U_GOX1DANF()}, "Aguarde", "Imprimindo DANFE...")
	
Return

User Function GOX1BXXM()
	
	Local oDlgDown
	Local oFile
	Local cDirXML := Space(254) 
	Local cXML
	Local oLayerDown
	
	DEFINE MSDIALOG oDlgDown FROM aSize[7], 0 TO 100, aSize[5]/2.5 TITLE '' OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL
		
		oDlgDown:lEscClose := .F.
		
		//////////////////////////////////////// XML
		
		oLayerDown := FWLayer():New()
		oLayerDown:Init(oDlgDown, .F.)
			
			oLayerDown:AddLine('MAIN', 80, .F.)
						
				oLayerDown:AddCollumn('MAN_ARQ', 100, .T., 'MAIN')
					
					oLayerDown:AddWindow('MAN_ARQ', 'WIN_MAN_ARQ', "Download XML", 100, .F., .T., , 'MAIN',)
						
						oFile := TGet():New(02, 02, {|u| IF(Pcount() > 0, cDirXML := u, cDirXML)}, oLayerDown:GetWinPanel('MAN_ARQ', 'WIN_MAN_ARQ', 'MAIN'), 200, 12, ,,,,,,, .T.,,,,,,, .F.,,, "cDirXML",,,,,,, "DIretório"/* Label */)
						//oFile:bValid := {|| IIf(!File(cDirXML), (Alert("Informe um diretório válido"), .F.), .T.)}
						
						oButton := tButton():New(3, 235, 'Buscar', oLayerDown:GetWinPanel('MAN_ARQ', 'WIN_MAN_ARQ', 'MAIN'), {|| cDirXML := cGetFile("", "Retorna diretório", 1, "", .F., nOR(GETF_LOCALFLOPPY, GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_RETDIRECTORY),.F., .T. ), IIf(Empty(cDirXML), (cDirXML := Space(254)), )}, 25, 10, , , , .T.)
						
			oLayerDown:AddLine('BOTTOM', 20, .F.)
				
				oLayerDown:AddCollumn('MAN_BOTTOM', 100, .T., 'BOTTOM')
					
					oPanelBot := tPanel():New(0, 0, "", oLayerDown:GetColPanel('MAN_BOTTOM', 'BOTTOM'),,,,, RGB(239,243,247), 000, 015)
					oPanelBot:Align	:= CONTROL_ALIGN_BOTTOM
					
					oQuit := THButton():New(0, 0, "Cancelar", oPanelBot, {|| oDlgDown:End()}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
					oQuit := THButton():New(0, 0, "Confirmar", oPanelBot, {|| IIf(DownXML(AllTrim(cDirXML)), oDlgDown:End(), )}, , , )
					oQuit:nWidth  := 80
					oQuit:nHeight := 10
					oQuit:Align := CONTROL_ALIGN_RIGHT
					oQuit:SetColor(RGB(002, 070, 112), )
					
	ACTIVATE MSDIALOG oDlgDown CENTERED
	
Return

Static Function DownXML(cDir)
	
	Local cFile := (_cTab1)->&(_cCmp1 + "_CHAVE") + ".xml"
	
	If SubStr(cDir, Len(cDir)) $ "/\"
		
		cDir := Left(cDir, Len(cDir) - 1)
		
	EndIf
	
	If !File(cDir)
		
		Alert("Diretório Inválido! Informe um diretório que você tenha acesso para salvar o XML.")
		
		Return .F.		
		
	EndIf
		
	MemoWrite(cDir + "\" + cFile, (_cTab1)->&(_cCmp1 + "_XML"))
	
	If File(cDir + "\" + cFile)
		
		ShellExecute("Open", cDir, "", Left(cDir, 3), 1 )
		
		MsgInfo("XML Salvo com sucesso!")
		
	Else
		
		MsgInfo("Erro ao fazer o download do arquivo. Verifique o diretório informado.")
		
		Return .F.
		
	EndIf
	
Return .T.

Static Function GetNFsItem()
	
	Local aRet := AFill(Array(19), "")
	
	If (_cTab1)->&(_cCmp1 + "_PROV") == ""
		
		
		
	Else
		
		
		
	EndIf
	
Return aRet

Static Function NFSEInfo()
	
	
	
Return

Static Function GravaXmlErro(aErro, lMostra)

	Local oDlg
	Local cInfo := ""
	Local nI

	For nI := 1 To Len(aErro)

		cInfo += "-" + aErro[nI] + CRLF

	Next nI

	RecLock(_cTab1, .F.)

	(_cTab1)->&(_cCmp1 + "_ERRO") := cInfo

	(_cTab1)->( MSUnlock() )

	If lMostra

		DEFINE MSDIALOG oDlg TITLE "Erro ao importar" From 0, 0 To 30, 80

		oPanelA := tPanel():New(10, 10, , oDlg, , , , , , 10, 10, .F., .F.)
		oPanelA:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelB := tPanel():New(0, 0, , oDlg, , , , , , 20, 20, .F., .F.)
		oPanelB:Align := CONTROL_ALIGN_BOTTOM

		oTMultiget := TMultiget():New(06, 06, {|u| If(Pcount()>0, cInfo:=u, cInfo)}, ;
		oPanelA, 265, 105, , , , , , .T., , , , , , .T.)
		oTMultiget:Align := CONTROL_ALIGN_ALLCLIENT
		oTMultiget:EnableVScroll(.T.)
		oTMultiget:EnableHScroll(.T.)

		oButtonOK := tButton():New(5, 5, 'OK', oPanelB, {|| oDlg:End()}, 25, 10, , , , .T.)

		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

Return

Static Function VincPedXML(cEmitCod, cEmitLoj)
	
	Local nX1
	
	Local cProd  := ""
	Local cProdF := ""
	Local nQuant := 0
	Local nPreco := 0
	Local nTotal := 0
	
	Local lSA5   := .F.
	
	Local nQuantC := 0
	Local nPrecoC := 0
	
	Local cForn  := ""
	Local cLoja  := ""
	
	Local cUmPrd
	Local cUmFor
	
	Local aConv
	
	Local aPed := {}
	Local nI
	
	Local aPedAux
	Local cChave := Right(oXml:_nfeProc:_NFe:_infNFe:_Id:Text, 44)
	
	Local aItXml := {}
	
	If Type("oXml:_NfeProc:_Nfe:_InfNfe:_det") == "O"
	
		XmlNode2Arr(oXml:_NfeProc:_Nfe:_InfNfe:_det, "_det")
		
	EndIf
	
	For nX1 := 1 To Len(oXml:_nfeProc:_NFe:_infNFe:_det)
		
		cProdF := AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_cProd:Text)
		nQuant := Val(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_qCom:Text)
		nTotal := Val(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vProd:Text)
		nPreco := Val(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_vUnCom:Text)
		
		dbSelectArea("SA5")
		SA5->( dbSetOrder(5) )
		SA5->( dbSeek(xFilial("SA5") + cProdF) )
		
		lSA5 := .F.
		
		While SA5->( !Eof() ) .And. SA5->A5_FILIAL == xFilial("SA5") .And. AllTrim(SA5->A5_CODPRF) == cProdF
		
			If SA5->A5_FORNECE == cEmitCod .And. SA5->A5_LOJA == cEmitLoj
				
				lSA5 := .T.
				
				cProd := SA5->A5_PRODUTO
				
				cUmPrd := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_UM")
				
				cUmFor := Upper(AllTrim(oXml:_nfeProc:_NFe:_infNFe:_det[nX1]:_prod:_uCom:Text))
				
				// Realiza a conversão de Unidade de Medida por Produto
				If !Empty(cUmPrd) .And. !Empty(cUmFor) .And. cUmPrd # cUmFor
					
					//                *Produto               *UM For                *UM Nosso           *Qtd For
					aConv := ValConUM(cProd, cUmFor, cUmPrd, nQuant, cEmitCod, cEmitLoj)
					
					// Conversão Ocorrida
					If aConv[1]
						
						If nQuant # aConv[2]
							
							nQuantC := aConv[2]
							
							If aConv[2] > 0
							
								nPrecoC := Round(nTotal / aConv[2], TamSX3(_cCmp2 + "_VUNIT")[2])
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
					
				AAdd(aItXml, { ;
					2, ;
					"", ;
					cProd, ;
					"", ;
					nQuant, ;
					nPreco, ;
					nTotal, ;
					nX1 ;
				})
				
				Exit
				
			EndIf
			
			SA5->( dbSkip() )
			
		EndDo
		
		If !lSA5
			
			AAdd(aItXml, { ;
				2, ;
				"", ;
				"", ;
				"", ;
				nQuant, ;
				nPreco, ;
				nTotal, ;
				nX1 ;
			})
			
		EndIf
		
	Next nX1
	
	aPedAux := GetPedFor(aItXml, cEmitCod, cEmitLoj)
	
	For nX1 := 1 To Len(aPedAux)
		
		If !Empty(aPedAux[nX1][2]) .And. AScan(aPed, {|x| x == aPedAux[nX1][2]}) == 0
		
			AAdd(aPed, aPedAux[nX1][2])
			
		EndIf
		
	Next nX1
	
	If Len(aPed) > 0
		
		For nI := 1 To Len(aPed)
			
			RecLock(_cTab8, .T.)
				
				(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
				(_cTab8)->&(_cCmp8 + "_TIPO")   := "2 "
				(_cTab8)->&(_cCmp8 + "_CHVNFE") := cChave
				(_cTab8)->&(_cCmp8 + "_NUMPED") := aPed[nI]
				
			(_cTab8)->( MSUnlock() )
			
		Next nI
		
	EndIf
	
Return

Static Function VinPedXMLS(cEmitCod, cEmitLoj, cChave, aNotaInfo)
	
	Local nX1
	
	Local cProd  := ""
	Local cProdF := ""
	Local nQuant := 0
	Local nPreco := 0
	Local nTotal := 0
	
	Local lSA5   := .F.
	
	Local nQuantC := 0
	Local nPrecoC := 0
	
	Local cForn  := ""
	Local cLoja  := ""
	
	Local cUmPrd
	Local cUmFor
	
	Local aConv
	
	Local aPed := {}
	Local nI
	
	Local aPedAux
	
	Local aItXml := {}
	
	Local aItAux := U_GOX18REF(aNotaInfo, "ITENS", "")
	
	For nX1 := 1 To Len(aItAux)
						 
		cProdF := AllTrim(U_GOX18REF(aItAux[nX1], "CODIGO", ""))
		nQuant := U_GOX18REF(aItAux[nX1], "QUANT", 0)
		nTotal := U_GOX18REF(aItAux[nX1], "TOTAL", 0)
		nPreco := U_GOX18REF(aItAux[nX1], "VLUNIT", 0)
		
		dbSelectArea("SA5")
		SA5->( dbSetOrder(5) )
		SA5->( dbSeek(xFilial("SA5") + cProdF) )
		
		lSA5 := .F.
		
		While SA5->( !Eof() ) .And. SA5->A5_FILIAL == xFilial("SA5") .And. AllTrim(SA5->A5_CODPRF) == cProdF
		
			If SA5->A5_FORNECE == cEmitCod .And. SA5->A5_LOJA == cEmitLoj
				
				lSA5 := .T.
				
				cProd := SA5->A5_PRODUTO
				
				cUmPrd := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_UM")
				
				cUmFor := PadR(Upper(U_GOX18REF(aItAux[nX1], "UM", "")), TamSX3(_cCmp2 + "_UMF")[1])
				
				// Realiza a conversão de Unidade de Medida por Produto
				If !Empty(cUmPrd) .And. !Empty(cUmFor) .And. cUmPrd # cUmFor
					
					//                *Produto               *UM For                *UM Nosso           *Qtd For
					aConv := ValConUM(cProd, cUmFor, cUmPrd, nQuant, cEmitCod, cEmitLoj)
					
					// Conversão Ocorrida
					If aConv[1]
						
						If nQuant # aConv[2]
							
							nQuantC := aConv[2]
							
							If aConv[2] > 0
							
								nPrecoC := Round(nTotal / aConv[2], TamSX3(_cCmp2 + "_VUNIT")[2])
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
					
				AAdd(aItXml, { ;
					2, ;
					"", ;
					cProd, ;
					"", ;
					nQuant, ;
					nPreco, ;
					nTotal, ;
					nX1 ;
				})
				
				Exit
				
			EndIf
			
			SA5->( dbSkip() )
			
		EndDo
		
		If !lSA5
			
			AAdd(aItXml, { ;
				2, ;
				"", ;
				"", ;
				"", ;
				nQuant, ;
				nPreco, ;
				nTotal, ;
				nX1 ;
			})
			
		EndIf
		
	Next nX1
	
	If Len(aItXml) > 0 
		
		aPedAux := GetPedFor(aItXml, cEmitCod, cEmitLoj)
		
		For nX1 := 1 To Len(aPedAux)
			
			If !Empty(aPedAux[nX1][2]) .And. AScan(aPed, {|x| x == aPedAux[nX1][2]}) == 0
			
				AAdd(aPed, aPedAux[nX1][2])
				
			EndIf
			
		Next nX1
		
		If Len(aPed) > 0
			
			For nI := 1 To Len(aPed)
				
				RecLock(_cTab8, .T.)
					
					(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
					(_cTab8)->&(_cCmp8 + "_TIPO")   := "2 "
					(_cTab8)->&(_cCmp8 + "_CHVNFE") := cChave
					(_cTab8)->&(_cCmp8 + "_NUMPED") := aPed[nI]
					
				(_cTab8)->( MSUnlock() )
				
			Next nI
			
		EndIf
		
	EndIf
	
Return

Static Function GrvPedXML()
	
	Local aPed := {}
	Local nI
	
	dbSelectArea(_cTab8)
	(_cTab8)->( dbSetOrder(2) )
	(_cTab8)->( dbSeek((_cTab1)->&(_cCmp1 + "_CHAVE")) )
	
	While !(_cTab8)->( Eof() ) .And. (_cTab8)->&(_cCmp8 + "_CHVNFE") == (_cTab1)->&(_cCmp1 + "_CHAVE")
		
		If !Empty((_cTab8)->&(_cCmp8 + "_NUMPED"))
			
			RecLock(_cTab8)
				
				(_cTab8)->( dbDelete() )
				
			(_cTab8)->( MSUnlock() )
			
		EndIf
		
		(_cTab8)->( dbSkip() )
		
	EndDo
	
	dbSelectArea("SD1")
	SD1->( dbSetOrder(1) )
	SD1->( dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
				
	While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
		SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
		
		If AScan(aPed, {|x| x == SD1->D1_PEDIDO}) == 0
			
			AAdd(aPed, SD1->D1_PEDIDO)
			
		EndIf
		
		SD1->( dbSkip() )
		
	EndDo
	
	For nI := 1 To Len(aPed)
		
		RecLock(_cTab8, .T.)
			
			(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
			(_cTab8)->&(_cCmp8 + "_TIPO")   := "2 "
			(_cTab8)->&(_cCmp8 + "_CHVNFE") := SF1->F1_CHVNFE
			(_cTab8)->&(_cCmp8 + "_NUMPED") := aPed[nI]
			
		(_cTab8)->( MSUnlock() )
		
	Next nI
	
Return

Static Function BkpXMLIt(oBrw)
	
	Local nX
	Local nI
	
	If !MsgYesNo("Deseja salvar as informações digitadas até o momento para recuperar posteriormente?")
		
		Return
		
	EndIf
	
	CleanRegra()
	
	For nX := 1 To Len(oBrw:aCols)
		
		RecLock(_cTab2, .T.)
		
			(_cTab2)->&(_cCmp2 + "_FILIAL") := (_cTab1)->&(_cCmp1 + "_FILIAL")
			(_cTab2)->&(_cCmp2 + "_SEQIMP") := (_cTab1)->&(_cCmp1 + "_SEQIMP")
		
			For nI := 1 To Len(oBrw:aHeader)
				
				If (_cTab2)->( FieldPos(oBrw:aHeader[nI][2]) )
					
					(_cTab2)->&(oBrw:aHeader[nI][2]) := oBrw:aCols[nX][nI]
					
				EndIf
				
			Next nI
			
		(_cTab2)->( MSUnlock() )
		
	Next nX
	
Return

Static Function RestBkpXML(oBrw)
	
	Local nI
	
	Local aColsAux := {}
	
	dbSelectArea(_cTab2)
	(_cTab2)->( dbSetOrder(1) )
	If (_cTab2)->( dbSeek((_cTab1)->&(_cCmp1 + "_FILIAL") + (_cTab1)->&(_cCmp1 + "_SEQIMP")) )
		
		If !MsgYesNo("Existem dados salvos para o XML em questão, deseja restaurar os dados?")
			
			Return
			
		EndIf
		
	Else
		
		Return
		
	EndIf
	
	While !(_cTab2)->( Eof() ) .And. (_cTab2)->&(_cCmp2 + "_FILIAL") == (_cTab1)->&(_cCmp1 + "_FILIAL") .And. (_cTab2)->&(_cCmp2 + "_SEQIMP") == (_cTab1)->&(_cCmp1 + "_SEQIMP")
		
		AAdd(aColsAux, {})
		
		For nI := 1 To Len(oBrw:aHeader)
			
			If (_cTab2)->( FieldPos(oBrw:aHeader[nI][2]) )
				
				AAdd(ATail(aColsAux), (_cTab2)->&(oBrw:aHeader[nI][2]))
				
			Else
				
				AAdd(ATail(aColsAux), CriaVar(oBrw:aHeader[nI][2], .F.))
				
			EndIf
			
		Next nI
		
		AAdd(ATail(aColsAux), .F.)
		
		(_cTab2)->( dbSkip() )
		
	EndDo
	
	oBrw:SetArray(aColsAux, .T.)
	oBrw:Refresh()
			
Return

Static Function GeraCplVen()
	
	Local aXmlDup
	Local nDup
	
	Local dVencAux
	
	If (_cTab8)->( FieldPos(_cCmp8 + "_DTVENC") ) > 0
		
		aXmlDup := GetNodeNFe(oXml, "_infNFe:_cobr:_dup")
		
		If ValType(aXmlDup) # "U"
			
			If ValType(aXmlDup) == "O"
				
				aXmlDup := {aXmlDup}
				
			EndIf
			
			For nDup := 1 To Len(aXmlDup)
				
				dVencAux := SToD(StrTran(aXmlDup[nDup]:_dVenc:Text, "-", ""))
				
				RecLock(_cTab8, .T.)
					
					(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
					(_cTab8)->&(_cCmp8 + "_TIPO")   := "3 "
					(_cTab8)->&(_cCmp8 + "_CHVNFE") := (_cTab1)->&(_cCmp1 + "_CHAVE")
					(_cTab8)->&(_cCmp8 + "_DTVENC") := dVencAux
					
				(_cTab8)->( MSUnlock() )
				
			Next nDup
			
		EndIf
		
	EndIf
	
Return

Static Function GeraNFSVen()
	
	Local aDup := {}
	Local nI
	
	dbSelectArea(_cTab8)
	(_cTab8)->( dbSetOrder(4) )
	
	If (_cTab8)->( FieldPos(_cCmp8 + "_DTVENC") ) > 0
		
		dbSelectArea("SC7")
		SC7->( dbSetOrder(1) )
		
		(_cTab8)->( dbSeek("2 " + (_cTab1)->&(_cCmp1 + "_CHAVE")) )
		
		While !(_cTab8)->( Eof() ) .And. (_cTab8)->&(_cCmp8 + "_TIPO") == "2 " .And. ;
			(_cTab8)->&(_cCmp8 + "_CHVNFE") == (_cTab1)->&(_cCmp1 + "_CHAVE")
			
			If SC7->( dbSeek(xFilial("SC7") + (_cTab8)->&(_cCmp8 + "_NUMPED")) )
				
				aDup := Condicao(1000, SC7->C7_COND, 0, (_cTab1)->&(_cCmp1 + "_DTEMIS"))
				
				Exit
				
			EndIf
			
			(_cTab8)->( dbSkip() )
			
		EndDo
		
		For nI := 1 To Len(aDup)
			
			RecLock(_cTab8, .T.)
				
				(_cTab8)->&(_cCmp8 + "_FILIAL") := xFilial(_cTab8)
				(_cTab8)->&(_cCmp8 + "_TIPO")   := "3 "
				(_cTab8)->&(_cCmp8 + "_CHVNFE") := (_cTab1)->&(_cCmp1 + "_CHAVE")
				(_cTab8)->&(_cCmp8 + "_DTVENC") := aDup[nI][1]
				
			(_cTab8)->( MSUnlock() )
			
		Next nI
		
	EndIf
	
Return

Static Function VldPedSlv(nQtd)
	
	Local cQuery := ""
	Local cAli
	
	Local aRet := {.T., ""}
	
	cQuery := " SELECT (C7.C7_QUANT - C7.C7_QUJE - C7.C7_QTDACLA) SALDO_PED, TAB2." + _cCmp2 + "_QUANT2 NOSSA_QTDE, TAB1.* FROM " + RetSqlName(_cTab1) + " TAB1 "
	cQuery += " INNER JOIN " + RetSqlName(_cTab2) + " TAB2 ON TAB2." + _cCmp2 + "_FILIAL = TAB1." + _cCmp1 + "_FILIAL AND TAB2." + _cCmp2 + "_SEQIMP = TAB1." + _cCmp1 + "_SEQIMP AND TAB2.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SC7") + " C7 ON C7.C7_FILIAL = '" + xFilial("SC7") + "' AND C7.C7_NUM = TAB2." + _cCmp2 + "_PEDIDO AND C7.C7_ITEM = TAB2." + _cCmp2 + "_ITEMPC AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE TAB1." + _cCmp1 + "_CHAVE <> '" + (_cTab1)->&(_cCmp1 + "_CHAVE") + "' "
	cQuery += " 	AND TAB2." + _cCmp2 + "_PEDIDO = '" + SC7->C7_NUM + "' "
	cQuery += " 	AND TAB2." + _cCmp2 + "_ITEMPC = '" + SC7->C7_ITEM + "' "
	cQuery += " 	AND (TAB1." + _cCmp1 + "_SIT IN ('1', '3') OR (TAB1." + _cCmp1 + "_SIT = '2' AND TAB1." + _cCmp1 + "_LIBALM = '1'))"
	
	cAli := MpSysOpenQuery(cQuery)
	
	If !(cAli)->( Eof() ) .And. nQtd < ((cAli)->SALDO_PED - (cAli)->NOSSA_QTDE)
		
		aRet[1] := .F.
		
		aRet[2] := (cAli)->&(_cCmp1 + "_DOC")
		
	EndIf
	
	(cAli)->( dbCloseArea() )
	
Return aRet

Static Function IsDevCFOP(cCFOP)
	
	// CFOPS de Devolução
	Local aDevCFOP := {;
		'201', ;
		'202', ;
		'203', ;
		'204', ;
		'208', ;
		'209', ;
		'210', ;
		'211', ;
		'212', ;
		'410', ;
		'411', ;
		'412', ;
		'413', ;
		'503', ;
		'504', ;
		'505', ;
		'506', ;
		'553', ;
		'555', ;
		'556', ;
		'660', ;
		'661', ;
		'662', ;
		'918', ;
		'919', ;
		'921' ;
	}     

	cCFOP := AllTrim(cCFOP)
	
	If Len(cCFOP) # 4 .And. Len(cCFOP) # 3
		
		Return .F.
		
	EndIf
	
	If Len(cCFOP) == 4
		
		cCFOP := Right(cCFOP, 3)
		
	EndIf
	
Return ASCan(aDevCFOP, {|x| x == cCFOP}) > 0

User Function GOX1GNCT(oXml, cNode)

Return GetNodeCTe(oXml, cNode)

User Function GOX1REC(cChaveSeek)

Return Recarga(cChaveSeek)
