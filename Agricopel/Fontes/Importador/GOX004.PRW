#Include 'Protheus.Ch'
#Include 'ApWebSrv.Ch'
#include "XMLXFUN.CH"

#DEFINE GOLOG_DISABLED "1"
#DEFINE GOLOG_INFO "2"
#DEFINE GOLOG_DEBUG "3"
#DEFINE GOLOG_CONSOLE "4"

// Fonte para leitura via WS

User Function GOX004(cEmpPar, cFilPar, cChaveU)
	
	Local lAuto   := .F.
	Local aFil    := {}
	Local cAli    := GetNextAlias()
	Local cQuery  := ""
	Local nC      := 0
	Local nFil    := 0
	Local cFilAux
	Local aInfoFil
	Local lEnvWF  := .F.
	Local lEnvWFT := .F.
	Local cNotFil := ""
	Local nI
	
	Local bBlock   := ErrorBlock({|e| U_GOX4SER(e), Final()})
	
	//Default aParam  := {"01", "01"}
	Default cEmpPar := "01"
	Default cFilPar := "0101"
	Default cChaveU := ""
	
	// Tratamento para quando é serviço
	
	If !IsInCallStack("U_GOX001") .And. !IsInCallStack("U_GOX008")
		
		lAuto := .T.
		
		conout("Carregando como serviço")
		
		RpcSetType(1)
		//RpcSetEnv(aParam[1], aParam[2])
		RpcSetEnv(cEmpPar, cFilPar)
		
	EndIf
	
	If !lAuto .And. Empty(cChaveU)
		
		oProcess:setRegua1(4)
		oProcess:incRegua1("Conectando...")
		
		oProcess:setRegua2(0)
		
		While !LockByName("GOX004", .T., .T.)
			
			oProcess:incRegua2("Outro usuário atualizando no momento... Aguarde...")
			//conout("Utilizando em outro processo!! Aguardando...")
			Sleep(500)
			
		EndDo
		
	EndIf
	
	cFilAux := cFilAnt
	
	Private oCabPed	:= WSGDeWService():New()
	Private oCabCan	:= WSGDeWService():New()
	Private oCabXml	:= WSGDeWService():New()
	Private oCabUpd	:= WSGDeWService():New()
	Private oCabUpC	:= WSGDeWService():New()
	Private oCabNfS	:= WSGDeWService():New()
	//Private nI
	
	Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	Private _cTab2 := Upper(AllTrim(GetNewPar("MV_XGTTAB2", "")))  // Importador NFe
	Private _cCmp2 := IIf(SubStr(_cTab2, 1, 1) == "S", SubStr(_cTab2, 2, 2), _cTab2)
	Private _cTab4 := Upper(AllTrim(GetNewPar("MV_XGTTAB4", "")))  // Conversão UM
	Private _cCmp4 := IIf(SubStr(_cTab4, 1, 1) == "S", SubStr(_cTab4, 2, 2), _cTab4)
	Private _cTab5 := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
	Private _cCmp5 := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
	Private _cTab6 := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
	Private _cCmp6 := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
	Private _cTab8 := Upper(AllTrim(GetNewPar("MV_ZGOTAB8", "")))  // 
	Private _cCmp8 := IIf(SubStr(_cTab8, 1, 1) == "S", SubStr(_cTab8, 2, 2), _cTab8)
	Private nTotal := 0
	
	Private lUsaLib := GetNewPar("MV_ZGOLIBX", .F.) // Indica se utiliza processo de liberação do XML
	
	Private oWF
	Private oWFT
	Private oWFCan
	Private oWFCanF
	Private lEnvWFCan  := .F.
	Private lEnvWFCanF := .F.
	
	Private lElap
	Private lElapT
		
	lElap  := GetElap(1)//"00:00:10"
	lElapT := GetElap(2)//"00:00:10"
	
	If !IsInCallStack("U_GOX001") .And. !IsInCallStack("U_GOX008")
		
		aFil := FWAllFilial(, , SM0->M0_CODIGO, .F.)
		
		// Variáveis necessárias quando rodar como serviço!
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
		
		// Variável para quando a tentativa de baixa do XML pela chave não ocorra com sucesso, guarde a mensagem de erro.
		// Neste caso apenas para compatibilidade
		Private cRetBxXML := ""
		
		oGOLog:Add("Iniciando busca dos XMLs do BRGDE em modo serviço!")
		oGOLog:NewLine()
		
	Else
		
		aFil := {cFilAnt}
		
	EndIf
	
	If File("\workflow\modelos\importador\XML_ERRO_TOT.htm")
		
		oWFT := TWFProcess():New("000001", OemToAnsi("XMLs inválidos enviados ao e-mail fiscal"))
		
		oWFT:NewTask("000001", "\workflow\modelos\importador\XML_ERRO_TOT.htm")
		
		oWFT:cSubject 	:= "XMLs inválidos enviados ao e-mail fiscal"
		oWFT:bReturn  	:= ""
		oWFT:bTimeOut	:= {}
		oWFT:fDesc 		:= "XMLs inválidos enviados ao e-mail fiscal"
		oWFT:ClientName(cUserName)
		
		oWFT:oHTML:ValByName('cEmpresa', cEmpAnt + " - " + AllTrim(FWGrpName()))
		
	EndIf
	
	If File("\workflow\modelos\importador\XML_CANC.htm")
		
		oWFCan := TWFProcess():New("000001", OemToAnsi("Cancelamentos automáticos"))
		
		oWFCan:NewTask("000001", "\workflow\modelos\importador\XML_CANC.htm")
		
		oWFCan:cSubject 	:= "Cancelamentos automáticos"
		oWFCan:bReturn  	:= ""
		oWFCan:bTimeOut	    := {}
		oWFCan:fDesc 		:= "Cancelamentos automáticos"
		oWFCan:ClientName(cUserName)
		
		oWFCan:oHTML:ValByName('cEmpresa', cEmpAnt + " - " + AllTrim(FWGrpName()))
		
	EndIf
	
	For nFil := 1 To Len(aFil)
		
		aInfoFil := FWArrFilAtu(SM0->M0_CODIGO, aFil[nFil])
		
		If Empty(aInfoFil)
			
			Loop
			
		EndIf
		
		cFilAnt    := aInfoFil[2]
		
		dbSelectArea("SM0")
		SM0->( dbSetOrder(1) )
		SM0->( dbSeek(cEmpAnt + cFilAnt) )
		
		lEnvWF     := .F.
		lEnvWFCanF := .F.
		
		cNotFil    := GetNewPar("MV_XSNNOTF", "")
		
		If !Empty(cNotFil) .And. AllTrim(cFilAnt) $ cNotFil 
			
			Loop
			
		EndIf
		
		If lAuto
			
			If !LockByName("GOX004", .T., .T.)
				
				//conout("Utilizando em outro processo!! Aguardando...")
				Loop
				
			EndIf
			
		EndIf
		
		conout("Processando Filial " + cFilAnt + " da Empresa " + cEmpAnt)
		
		If !lAuto
			
			If Empty(cChaveU)
				
				//oProcess:setRegua1(2)
				oProcess:incRegua1("Atualizando XMLs baixados...")
				
			Else
				
				oProcess:setRegua1(1)
				
			EndIf
			
		Else
			
			oGOLog:Add(" *---- Realizando processo para a filial " + cFilAnt + " da Empresa " + cEmpAnt)
			
		EndIf
			
		oCabPed:cCNPJ  := aInfoFil[18]
		oCabPed:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
		oCabPed:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
		
		oCabCan:cCNPJ  := aInfoFil[18]
		oCabCan:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
		oCabCan:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
		
		oCabXml:cCNPJ  := aInfoFil[18]
		oCabXml:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
		oCabXml:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
		
		oCabUpd:cCNPJ  := aInfoFil[18]
		oCabUpd:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
		oCabUpd:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
		
		oCabUpC:cCNPJ  := aInfoFil[18]
		oCabUpC:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano"))
		oCabUpC:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381"))
		
		oCabNfS:cCNPJ  := aInfoFil[18]
		oCabNfS:cLogin := AllTrim(GetNewPar("MV_ZSNWSUS", "urbano")) //integracao.unifique
		oCabNfS:cSenha := AllTrim(GetNewPar("MV_ZSNWSPS", "ajfu4381")) //adoRGj4@39d
		
		// Busca os XMLs 
		
		If !lAuto
			
			If Empty(cChaveU)
				
				oProcess:incRegua1("Baixando novos XMLs")
				
			Else
				
				oProcess:incRegua1("XML de chave: " + cChaveU)
				
			EndIf
			
		Else
			
			oGOLog:Add(" ++++++ Baixando novos XMLs")
			
		EndIf
		
		If Empty(cChaveU)
			
			//If .F. // Retirar
			
			oCabPed:cStatusDoc := " "
			
			If File("\workflow\modelos\importador\XML_ERRO.htm")
				
				oWF := TWFProcess():New("000001", OemToAnsi("XMLs inválidos enviados ao e-mail fiscal"))
				
				oWF:NewTask("000001", "\workflow\modelos\importador\XML_ERRO.htm")
				
				oWF:cSubject 	:= "XMLs inválidos enviados ao e-mail fiscal"
				oWF:bReturn  	:= ""
				oWF:bTimeOut	:= {}
				oWF:fDesc 		:= "XMLs inválidos enviados ao e-mail fiscal"
				oWF:ClientName(cUserName)
				
				oWF:oHTML:ValByName('cFilial', cFilAnt + " - " + AllTrim(FWFilialName()))
				
			EndIf
			
			If File("\workflow\modelos\importador\XML_CANC.htm")
				
				//Cancelamento por filial
				
				oWFCanF := TWFProcess():New("000001", OemToAnsi("Cancelamentos automáticos"))
				
				oWFCanF:NewTask("000001", "\workflow\modelos\importador\XML_CANC.htm")
				
				oWFCanF:cSubject 	:= "Cancelamentos automáticos"
				oWFCanF:bReturn  	:= ""
				oWFCanF:bTimeOut	    := {}
				oWFCanF:fDesc 		:= "Cancelamentos automáticos"
				oWFCanF:ClientName(cUserName)
				
				oWFCanF:oHTML:ValByName('cEmpresa', cEmpAnt + " - " + AllTrim(FWGrpName()))
				
			EndIf
			
			If lAuto
				
				oGOLog:Add("VARIÁVEL STATUS DOC IGUAL A: '" + oCabPed:cStatusDoc + "' ")
				
				oGOLog:Add("Realizando método RequestPendentes...")
				oGOLog:NewLine()
			
			EndIf
			
			If oCabPed:RequestPendentes()
				
				If lAuto
					
					oGOLog:Add("RequestPendentes realizado com sucesso..")
					
				EndIf
				
				nTotal := Len(oCabPed:OWSREQUESTPENDENTESRESULT:OWSPENDENTES)
				
				If !lAuto
					oProcess:setRegua2(nTotal)
				EndIf
				
				If Empty(oCabPed:OWSREQUESTPENDENTESRESULT:OWSPENDENTES[1]:CCHAVE)
					
					If !lAuto
						oProcess:incRegua2("Nenhum XML encontrado...")
					Else
						oGOLog:Add("Não foi encontrado nenhum XML novo para baixar.")
					EndIf
					
				Else
					
					If lAuto
						oGOLog:Add("Foram encontrados " + cValToChar(nTotal) + " XMLs para baixar.")
					EndIf
					
					dbSelectArea(_cTab1)
					(_cTab1)->( dbSetOrder(1) )
					
					For nI := 1 To Len(oCabPed:OWSREQUESTPENDENTESRESULT:OWSPENDENTES)
						
						//lWFAlt := .F.
						
						If !lAuto
							oProcess:incRegua2("Baixando XML " + cValToChar(nI) + " de " + cValToChar(nTotal) + "...")
						EndIf
						
						oCabXml:CCHAVE := oCabPed:OWSREQUESTPENDENTESRESULT:OWSPENDENTES[nI]:CCHAVE
						
						conout("Chave: " + oCabXml:CCHAVE)
						
						If lAuto
							oGOLog:Add("Baixando novo XML de chave: " + oCabXml:CCHAVE)
						EndIf
						
						U_GOCargaX()
						
						(_cTab1)->( dbSetOrder(1) )
						If (_cTab1)->( dbSeek(oCabXml:CCHAVE + "1") ) .Or. (_cTab1)->( dbSeek(oCabXml:CCHAVE + "2") )
							
							oCabUpd:CCHAVE	   := (_cTab1)->&(_cCmp1 + "_CHAVE")
							oCabUpd:cconteudo  := 'I' // Conteúdo a ser gravado no campo customizado
							oCabUpd:nnCustom   := 1   // Número do campo Customizado (qual campo customizado)(Podem ser criados até n campos customizados)
							
							oCabUpd:cStatusDoc := " "
							
							If lAuto
								oGOLog:Add("Marcando como lida a chave: " + oCabXml:CCHAVE)
							EndIf
							
							If oCabUpd:UpdateCustom()
								
								If lAuto
									oGOLog:Add("*** UpdateCustom OK")
								EndIf
								
								If !Empty(oCabUpd:CUPDATECUSTOMRESULT)
									
									If lAuto
										oGOLog:Add("!!!!!!!!!!!!!!! XML Marcado como já processado no BRGDE!")
									EndIf
									
								EndIf
								
							Else
								
								conout("Erro update - " + GetWscError())
								
								If lAuto
									
									oGOLog:Add("Erro ao chamar método WS para atualizar: " + GetWscError())
									
								EndIf
								
							EndIf
							
						ElseIf (_cTab1)->( dbSeek(oCabXml:CCHAVE + "3") )
							
							//cElap := ElapTime((_cTab1)->&(_cCmp1 + "_HRCRIA"), Time())
							
							If lElap/*ProcElap(cElap)*/ .And. File("\workflow\modelos\importador\XML_ERRO.htm")
								
								lEnvWF := .T.
								
								//lWFAlt := .T.
								
								AAdd(oWF:oHTML:ValByName('xm.cChave') , (_cTab1)->&(_cCmp1 + "_CHAVE"))
								AAdd(oWF:oHTML:ValByName('xm.cNumero'), SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 26, 9))
								AAdd(oWF:oHTML:ValByName('xm.cErro')  , (_cTab1)->&(_cCmp1 + "_ERRO"))
								
								/*RecLock(_cTab1, .F.)
									
									(_cTab1)->&(_cCmp1 + "_HRCRIA") := Time()
									
								(_cTab1)->( MSUnlock() )*/
								
							EndIf
							
							//cElapT := ElapTime((_cTab1)->&(_cCmp1 + "_HRIMP"), Time())
							
							If lElapT/*ProcElap(cElapT, .T.)*/ .And. File("\workflow\modelos\importador\XML_ERRO_TOT.htm")
								
								lEnvWFT := .T.
								
								AAdd(oWFT:oHTML:ValByName('xm.cFilial'), cFilAnt /*+ " - " + AllTrim(FWFilialName())*/)
								AAdd(oWFT:oHTML:ValByName('xm.cChave') , (_cTab1)->&(_cCmp1 + "_CHAVE"))
								AAdd(oWFT:oHTML:ValByName('xm.cNumero'), SubStr((_cTab1)->&(_cCmp1 + "_CHAVE"), 26, 9))
								AAdd(oWFT:oHTML:ValByName('xm.cErro')  , (_cTab1)->&(_cCmp1 + "_ERRO"))
								
								/*If !lWFAlt
									
									RecLock(_cTab1, .F.)
										
										(_cTab1)->&(_cCmp1 + "_HRIMP") := Time()
										
									(_cTab1)->( MSUnlock() )
									
								EndIf*/
								
							EndIf
							
						EndIf
						
					Next nI
					
				EndIf
				
			EndIf
			
			If lEnvWF .And. File("\workflow\modelos\importador\XML_ERRO.htm")
				
				oWF:cTo := GetNewPar("MV_XSENXME", "octavio@gooneconsultoria.com.br")
				
				// Inicia o processo
				oWF:Start()
				// Finaliza o processo
				oWF:Finish()
				
			EndIf
			
			If File("\workflow\modelos\importador\XML_ERRO.htm")
				
				FreeObj(oWF)
				oWF := Nil
				
			EndIf
			
			//EndIf //Retirar
			
			// Busca Notas Fiscais de Serviço
			
			If (_cTab1)->( FieldPos(_cCmp1 + "_PROV") ) > 0
			
				oCabNfS:cStatusDoc := " "
				
				If oCabNfS:RequestPendentesNFSe()
					
					If !Empty(oCabNfS:oWsRequestPendentesNFSEResult:oWSPendentesNFSE) .And. ;
						Len(oCabNfS:oWsRequestPendentesNFSEResult:oWSPendentesNFSE) > 0 .And. ;
						!Empty(oCabNfS:oWsRequestPendentesNFSEResult:oWSPendentesNFSE[1]:cChave)
						
						dbSelectArea(_cTab1)
						(_cTab1)->( dbSetOrder(1) )
						
						For nI := 1 To Len(oCabNfS:oWsRequestPendentesNFSEResult:oWSPendentesNFSE)
							
							oCabXml:CCHAVE := oCabNfS:oWsRequestPendentesNFSEResult:oWSPendentesNFSE[nI]:CCHAVE
							
							U_GOCargaX(,,, Upper(oCabNfS:oWsRequestPendentesNFSEResult:oWSPendentesNFSE[nI]:cProvedor))
							
							(_cTab1)->( dbSetOrder(1) )
							If (_cTab1)->( dbSeek(oCabXml:CCHAVE + "6") )
								
								oCabUpd:CCHAVE	   := (_cTab1)->&(_cCmp1 + "_CHAVE")
								oCabUpd:cconteudo  := 'I' // Conteúdo a ser gravado no campo customizado
								oCabUpd:nnCustom   := 1   // Número do campo Customizado (qual campo customizado)(Podem ser criados até n campos customizados)
								
								oCabUpd:cStatusDoc := " "
								
								If oCabUpd:UpdateCustom()
									
									If !Empty(oCabUpd:CUPDATECUSTOMRESULT)
										
										conout("!!!!!!!!!!!!!!! XML Marcado como já processado no BRGDE!")
										
									EndIf
									
								Else
									
									conout("Erro update - " + GetWscError())
									
								EndIf*/
								
							ElseIf (_cTab1)->( dbSeek(oCabXml:CCHAVE + "3") )
								
								conout("Erro de estrutura de XML.")
								
							EndIf
								
						Next nI
						
					EndIf
					
				EndIf
				
			EndIf
			
			// Busca os cancelamentos
			
			If !lAuto
				oProcess:incRegua1("Baixando cancelamentos")
			Else
				oGOLog:Add("---------Baixando cancelamentos.")
			EndIf
			
			oCabCan:cStatusDoc := "C"
			
			If lAuto
				
				oGOLog:Add("VARIÁVEL STATUS DOC IGUAL A: '" + oCabCan:cStatusDoc + "' ")
				
				oGOLog:Add("Realizando método RequestPendentes...")
				oGOLog:NewLine()
			
			EndIf
			
			If oCabCan:RequestPendentes()
				
				If lAuto
					
					oGOLog:Add("RequestPendentes realizado com sucesso..")
					
				EndIf
				
				nTotal := Len(oCabCan:OWSREQUESTPENDENTESRESULT:OWSPENDENTES)
				
				If !lAuto
					oProcess:setRegua2()
				EndIf
				
				If Empty(oCabCan:OWSREQUESTPENDENTESRESULT:OWSPENDENTES[1]:CCHAVE)
					
					If !lAuto
						oProcess:incRegua2("Nenhum Cancelamento encontrado...")
					Else
						oGOLog:Add("Não foi encontrado nenhum cancelamento para importar.")
					EndIf
					
					conout("Nao ha cancelamentos para importar..")
					
				Else
					
					If lAuto
						oGOLog:Add("Foram encontrados " + cValToChar(nTotal) + " XMLs para baixar.")
					EndIf
					
					For nI := 1 To Len(oCabCan:OWSREQUESTPENDENTESRESULT:OWSPENDENTES)
						
						If !lAuto
							oProcess:incRegua2("Baixando Cancelamento " + cValToChar(nI) + " de " + cValToChar(nTotal) + "...")
						EndIf
						
						oCabXml:CCHAVE := oCabCan:OWSREQUESTPENDENTESRESULT:OWSPENDENTES[nI]:CCHAVE
						
						conout("Cancelamento: " + oCabXml:CCHAVE)
						
						If lAuto
							oGOLog:Add("Baixando cancelamento de chave " + oCabXml:CCHAVE)
						EndIf
						
						// Para primeiro incluir o Documento
						// U_GOCargaX()
						
						U_GOCargaX(.T.)
						
						(_cTab1)->( dbSetOrder(1) )
						If (_cTab1)->( dbSeek(oCabXml:CCHAVE + "5") )
							
							oCabUpC:CCHAVE	   := (_cTab1)->&(_cCmp1 + "_CHAVE")
							oCabUpC:cconteudo  := 'C' // Conteúdo a ser gravado no campo customizado
							oCabUpC:nnCustom   := 1   // Número do campo Customizado (qual campo customizado)(Podem ser criados até n campos customizados)
							
							oCabUpC:cStatusDoc := "C"
							
							If lAuto
								oGOLog:Add("Marcando como lida a chave de cancelamento: " + oCabXml:CCHAVE)
							EndIf
							
							If oCabUpC:UpdateCustom()
								
								If lAuto
									oGOLog:Add("*** UpdateCustom OK. (C)")
								EndIf
								
								If !Empty(oCabUpC:CUPDATECUSTOMRESULT)
									
									If lAuto
										oGOLog:Add("!!!!!!!!!!!!!!! XML Marcado como já processado no BRGDE!")
									EndIf
									
								EndIf
								
							Else
								
								conout("Erro update - " + GetWscError())
								
								If lAuto
									oGOLog:Add("Erro ao chamar método WS para atualizar: " + GetWscError())
								EndIf
								
							EndIf
							
						EndIf
						
					Next nI
					
				EndIf
				
			EndIf
			
			If lEnvWFCanF .And. File("\workflow\modelos\importador\XML_CANC.htm")
				
				oWFCanF:cTo := GetNewPar("MV_XSENXFC", "octavio@gooneconsultoria.com.br")
				
				// Inicia o processo
				oWFCanF:Start()
				// Finaliza o processo
				oWFCanF:Finish()
				
			EndIf
			
			// Também deverá reprocessar os cancelamentos!! Caso a nota entre por algum motivo depois do cancelamento :S
			// Ou seja, caso o tipo seja cancelamento (TAB1_TIPO == '5') e estiver como inconsistência (TAB1_SIT = '6')
			// deverá pegar a chave eletrônica (TAB1_CAHVE) e verificar se a nota existe para excluir. 
			// O processo já existe, deverá fazer idêntico ao reprocessamento da tela de inconsistência para quando é cancelamento.
			// Contudo terá que realizar uma query buscando para a filial em questão esses cancelamentos, posicionar na TAB1 pelo 
			// recNo e chamar a função de processamento do XML -> U_GOCargaX(.T., .T.)
			
			If lAuto
				oGOLog:Add("Reprocessando Inconsistências.")
			Else
				oProcess:incRegua1("Reprocessando Inconsistências...")
			EndIf
			
			cQuery := " SELECT R_E_C_N_O_ RECNO "
			cQuery += " FROM " + RetSqlName(_cTab1) + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "//"AND " + _cCmp1 + "_TIPO = '5' "
			cQuery += " AND " + _cCmp1 + "_SIT = '6' "
			cQuery += " AND " + _cCmp1 + "_DTEMIS >= '" + DToS((Date() - GetNewPar("MV_ZGODRIN", 365))) + "' "
			cQuery += " AND " + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
			
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), cAli, .F., .T.)
			
			nTotal := 1
			
			(cAli)->( dbEval({|| nTotal++}) )
			
			If !lAuto
				oProcess:setRegua2(nTotal)
			EndIf
			
			(cAli)->( dbGoTop() )
			
			dbSelectArea(_cTab1)
			
			While !(cAli)->( Eof() )
				
				If !lAuto
					oProcess:incRegua2("Reprocessando XMLs...")
				EndIf
				
				(_cTab1)->( dbGoTo((cAli)->RECNO) )
				
				If lAuto
					oGOLog:Add("Reprocessando documento de sequência : " + (_cTab1)->&(_cCmp1 + "_SEQIMP"))
					oGOLog:Add("Número : " + (_cTab1)->&(_cCmp1 + "_DOC"))
					oGOLog:Add("Tipo   : " + (_cTab1)->&(_cCmp1 + "_TIPO"))
				EndIf
				
				If (_cTab1)->( RecNo() ) # 0
					
					If (_cTab1)->&(_cCmp1 + "_TIPO") == "1"
						
						If lAuto
							oGOLog:Add("Serviço - Reproc. NF-e: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						EndIf
						
						Conout("Reproc. NF-e: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						
						U_GOCargaX(, .T.)
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "2"
						
						If lAuto
							oGOLog:Add("Serviço - Reproc. CT-e: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						EndIf
						
						Conout("Reproc. CT-e: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						
						U_GOCargaX(, .T.)
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "5" 
						
						If lAuto
							oGOLog:Add("Serviço - Reproc. Canc.: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						EndIf
						
						Conout("Reproc. Canc.: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						
						U_GOCargaX(.T., .T.)
						
					ElseIf (_cTab1)->&(_cCmp1 + "_TIPO") == "6" .And. (_cTab1)->( FieldPos(_cCmp1 + "_PROV") ) > 0
						
						If lAuto
							oGOLog:Add("Serviço - Reproc. NFS-e.: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						EndIf
						
						Conout("Reproc. NFS-e.: " + (_cTab1)->&(_cCmp1 + "_CHAVE"))
						
						U_GOCargaX(.F., .T.,, U_GOX18PRV((_cTab1)->&(_cCmp1 + "_PROV"), .F.))
						
					EndIf
					
				EndIf
				
				If lAuto
					oGOLog:Add("Após processamento - seq : " + (_cTab1)->&(_cCmp1 + "_SEQIMP"))
				EndIf
				
				(cAli)->( dbSkip() )
				
			EndDo
			
			(cAli)->( dbCloseArea() )

			// Melhoria para analisar todos os XML's pendentes e avaliar se já não foram lançados manualmente ou por outra ferramenta.
			// Trazer tudo que é _SIT = 1 ou 3, ou _SIT = 2 e _LIBALM = 1
			
			If lAuto
				oGOLog:Add("Verificando notas já importada.")
			Else
				oProcess:incRegua1("Verificando notas já importada...")
			EndIf
			
			cQuery := " SELECT TAB.R_E_C_N_O_ RECNO, F1.F1_FILIAL, F1.F1_STATUS, TAB." + _cCmp1 + "_LIBALM LIBALM "
			cQuery += " FROM " + RetSqlName(_cTab1) + " TAB "
			cQuery += " LEFT JOIN " + RetSqlName("SF1") + " F1 ON F1.F1_FILIAL = " + xFilial("SF1") + " AND F1.F1_CHVNFE = TAB." + _cCmp1 + "_CHAVE AND F1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE TAB.D_E_L_E_T_ = ' ' "
			cQuery += " AND (TAB." + _cCmp1 + "_SIT IN ('1', '3') OR (TAB." + _cCmp1 + "_SIT = '2' AND TAB." + _cCmp1 + "_LIBALM = '1') ) "
			cQuery += " AND TAB." + _cCmp1 + "_DTEMIS >= '" + DToS((Date() - GetNewPar("MV_ZGODRIN", 1095))) + "' "
			cQuery += " AND TAB." + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
			
			cQuery := ChangeQuery(cQuery)
			
			cAli := MpSysOpenQuery(cQuery)
			
			While !(cAli)->( Eof() )
				
				(_cTab1)->( dbGoTo((cAli)->RECNO) )
				
				If !Empty((cAli)->F1_FILIAL) .And. ((cAli)->LIBALM # "1" .Or. !Empty((cAli)->F1_STATUS))
					
					RecLock(_cTab1)
						
						If (cAli)->LIBALM == "1"
							
							(_cTab1)->&(_cCmp1 + "_LIBALM") := '3'
							
						Else
							
							(_cTab1)->&(_cCmp1 + "_SIT") := '2'
							
						EndIf
						
					(_cTab1)->( MSUnlock() )
					
				EndIf
				
				(cAli)->( dbSkip() )
				
			EndDo
			
			(cAli)->( dbCloseArea() )
			
		Else
			
			If !lAuto
				oProcess:setRegua2(nTotal := 1)
				oProcess:incRegua2("Baixando XML 1 de 1...")
			EndIf
			
			oCabXml:CCHAVE := cChaveU
			
			conout("Chave: " + oCabXml:CCHAVE)
			
			U_GOCargaX()
			
			(_cTab1)->( dbSetOrder(1) )
			If (_cTab1)->( dbSeek(oCabXml:CCHAVE + "1") ) .Or. (_cTab1)->( dbSeek(oCabXml:CCHAVE + "2") )
				
				oCabUpd:CCHAVE	   := cChaveU
				oCabUpd:cconteudo  := 'I' // Conteúdo a ser gravado no campo customizado
				oCabUpd:nnCustom   := 1   // Número do campo Customizado (qual campo customizado)(Podem ser criados até n campos customizados)
				
				oCabUpd:cStatusDoc := " "
				
				If oCabUpd:UpdateCustom()
					
					If !Empty(oCabUpd:CUPDATECUSTOMRESULT)
						
						// Se marcou OK no BRGD-e
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
		If File("\workflow\modelos\importador\XML_CANC.htm")
			
			FreeObj(oWFCanF)
			oWFCanF := Nil
			
		EndIf
		
		If lAuto
			
			UnLockByName("GOX004", .T., .T.)
			
		EndIf
		
	Next nFil
	
	If lEnvWFT .And. File("\workflow\modelos\importador\XML_ERRO_TOT.htm")
		
		oWFT:cTo := GetNewPar("MV_XSENXMT", "octavio@gooneconsultoria.com.br")
		
		// Inicia o processo
		oWFT:Start()
		// Finaliza o processo
		oWFT:Finish()
		
	EndIf
	
	If lEnvWFCan .And. File("\workflow\modelos\importador\XML_CANC.htm")
		
		oWFCan:cTo := GetNewPar("MV_XSENXMC", "octavio@gooneconsultoria.com.br")
		
		// Inicia o processo
		oWFCan:Start()
		// Finaliza o processo
		oWFCan:Finish()
		
	EndIf
	
	cFilAnt := cFilAux
	
	// Limpa RPCSetEnv se precisar executar o RPCSetEnv e RPCSetType (verificar)
	If lAuto
		
		oGOLog:Add("Processo finalizado..")
		
		oGOLog:EndLog()
		
		//Alert("Terminou!! " + oGOLog:cFullFile)
		
		oGOLog:Reset(.T.)
		
		RpcClearEnv()
		
	ElseIf !lAuto .And. Empty(cChaveU)
		
		UnLockByName("GOX004", .T., .T.)
		
	EndIf
	
	FreeObj(oCabUpd)
	FreeObj(oCabUpC)
	FreeObj(oCabXml)
	FreeObj(oCabCan)
	FreeObj(oCabPed)
	
	FreeVet(aInfoFil)
	FreeVet(aFil)
	
	DelClassIntf()
	
Return .T.

Static Function FreeVet(aVet)
	
	If ValType(aVet) == "A"
		
		ASize(aVet, 0)
		aVet := Nil
		
	EndIf
	
Return

Static Function ProcElap(cTime, lTot)
	
	Local cHora := SubStr(cTime, 1, 2)
	Local cMin  := SubStr(cTime, 4, 2)
	Local cSeg  := SubStr(cTime, 7, 2)
	
	Local cSecElap := (Val(cHora) * 3600) + (Val(cMin) * 60) + Val(cSeg) 
	
	Default lTot := .F.
	
	If lTot
		
		If cSecElap >= GetNewPar("MV_XSENWFT", 72000)
			
			Return .T.
			
		EndIf 
		
	Else
		
		If cSecElap <= 5
			
			Return .T.
			
		ElseIf cSecElap >= GetNewPar("MV_XSENWFS", 3600)
			
			Return .T.
			
		EndIf
		
	EndIf
	
Return .F.

Static Function GetElap(nOp)
	
	Local cParam  := AllTrim(GetNewPar("MV_XSENWF1", "")) // Parâmetro deverá ser no formato AAAAMMDD;HH:MM:SS
	Local cParamT := AllTrim(GetNewPar("MV_XSENWF2", "")) // Parâmetro deverá ser no formato AAAAMMDD;HH:MM:SS
	Local dData
	Local cHora
	Local aAux
	Local nLimit
	Local dDtAtu  := Date()
	Local cHrAtu  := Time()
	Local nElapT  := 0
	Local lRet    := .F.
	
	Default nOp := 1
	
	If (nOp == 1 .And. Empty(cParam)) .Or. (nOp == 2 .And. Empty(cParamT))
		
		lRet := .F.
		
	Else
		
		If nOp == 1
			
			aAux := StrTokArr(cParam, ";")
			nLimit := GetNewPar("MV_XSENWFS", 3600)
			
		ElseIf nOp == 2
			
			aAux := StrTokArr(cParamT, ";")
			nLimit := GetNewPar("MV_XSENWFT", 72000)
			
		EndIf
		
		dData := SToD(aAux[1])
		
		cHora := aAux[2]
		
		nElapT := MyElapTime(dData, cHora, dDtAtu, cHrAtu)
		
		If nElapT >= nLimit
			
			If nOp == 1
				
				PutMV("MV_XSENWF1", DToS(dDtAtu) + ";" + cHrAtu)
				
			ElseIf nOp == 2
				
				PutMV("MV_XSENWF2", DToS(dDtAtu) + ";" + cHrAtu)
				
			EndIf
			
			lRet := .T.
			
		EndIf
		
	EndIf
	
Return lRet

Static Function MyElapTime(dData, cHora, dDtAtu, cHrAtu)
	
	Local nDayDif
	Local nHrDif
	Local nElapT := 0
	
	// Dias passados desde o último envio
	nDayDif := dDtAtu - dData
	
	If dDtAtu == dData
		
		// Tempo passado desde o último envio
		nHrDif := HrStrToSec(ElapTime(cHora, cHrAtu))
		
	ElseIf dDtAtu > dData
		
		If nDayDif > 1
			
			nElapT := (24 * 60 * 60 * (nDayDif - 1))
			
		EndIf
		
		nHrDif := HrStrToSec(ElapTime(cHora, "00:00:00"))
		nHrDif += HrStrToSec(ElapTime("00:00:00", cHrAtu))
		
	EndIf
	
	nElapT += nHrDif
	
Return nElapT

Static Function HrStrToSec(cTime)
	
	Local cHora := SubStr(cTime, 1, 2)
	Local cMin  := SubStr(cTime, 4, 2)
	Local cSeg  := SubStr(cTime, 7, 2)
	
	Local nSecElap := (Val(cHora) * 3600) + (Val(cMin) * 60) + Val(cSeg) 
	
Return nSecElap

User Function GOX4SER(e)
	
	Local oWF
	
	GFEMail(GetNewPar("MV_ZSCHXME", "octavio@gooneconsultoria.com.br"), ;
		">>>> ERRO NO SCHEDULE DE XML's NA EMPRESA " + cEmpAnt + " - " + AllTrim(FWGrpName()), ;
		"Erro: " + StrTran(e:ErrorStack, "\n", "<br>"), .F.)
	
Return
