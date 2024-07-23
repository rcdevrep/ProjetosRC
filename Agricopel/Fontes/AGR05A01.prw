#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+------------------+---------------------------------------------------------+
!Descricao         ! Integração HMax Hotel, rotina para realizar a importação!
!                  ! de arquivos XML gerando doucmento de saida via MATA920. !
+------------------+---------------------------------------------------------+
!Autor             ! Gruppe - Felipe José Limas                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/2020                                                 !
+------------------+--------------------------------------------------------*/

User Function AGR05A01()

Private cFOpen	    := ""
Private aLog 	    := {}//Array para armazenar o log das operacoes
Private CARACTERES	:= strtran(space(20)," ","*")
Private cDirLog	    := ""//Diretorio para salvar o arquivo de Log
Private cArqLog     := "Baixa - " + CUSERNAME + "-" + dtos(DATE()) + "-" + strTran(TIME(),":","") + ".log"
Private _lErro      := .F.

cFOpen :=   cGetFile( '*.xml|*.xml' ,"Selecione o diretorio",  ,'C:\' ,.T. ,GETF_LOCALFLOPPY+GETF_LOCALHARD+128,.F.,)

aArqNFSe := Directory(cFOpen + "*.xml")

If !ExistDir(cFOpen+"Agricopel_log_nfse") //Diretorio de Importação
	MontaDir(cFOpen+"Agricopel_log_nfse")
Endif

cDirLog := cFOpen+"Agricopel_log_nfse\"

If Len(aArqNFSe) > 0
	oProcess := MsNewProcess():New( { || ProcDir(aArqNFSe) } , "Importando NFS-e." , "Processando aguarde..." , .F. )
	oProcess:Activate()
Else
	MsgStop("Não existem arquivos a serem importados no diretório " + cFOpen,"Atencao!")
Endif

Return()

//Função para processar os arquivos de NFSe
Static Function ProcDir(aFileNFSe)

Local nX			:= 0
Local nLast			:= 0
Local lStatus		:= .T.
Local cXmlNFSe		:= ""

nLast	:= Len(aFileNFSe)   //Incrementa regua
oProcess:SetRegua1( nLast ) //Alimenta a primeira barra de progresso

//Percorre todos os arquivos XMLs da pasta selecionada.
For nX := 1 To nLast

	lStatus := .T. //Ajusta o status para iniciar o processo do arquivo

	cArquivo := cFOpen + aFileNFSe[nX,1]
	oProcess:IncRegua1("Importando arquivo(s)... [" + AllTrim(Str(nX)) + " de " + AllTrim(Str(nLast)) +" | "+AllTrim(Str(Int((nX * 100) / nLast)))+"%]")

	cXmlNFSe:= AbreNFSe(cArquivo)

	IF !Empty(cXmlNFSe)
		lStatus:= NFSePrc(cXmlNFSe)
	EndIF

Next nx

If _lErro
	U_AGR05A2G(cDirLog,cArqLog)
	MsgAlert( "Integracao Realizada com Erros! Para verificar os erros favor acessar o Log "+ Alltrim(cArqLog) +" em "+ Alltrim(cDirLog) )
	aLog 	:= {}
Else
	If len(aLog) > 0
		U_AGR05A2G(cDirLog,cArqLog)
	Endif
	MsgInfo("Integracao Realizada com Sucesso! Para ter acesso ao Log "+ Alltrim(cArqLog) +" em "+ Alltrim(cDirLog))
	aLog 	:= {}
Endif

Return()

//Função para processar o xml do NFSe
Static Function NFSePrc(cNFSe)

Local cError   	       := ""
Local cWarning 	       := ""
Local _cNumNota        := ""
Local _cCodSA1         := ""
Local cMsgLog          := ""
Local _cInscMun        := ""
Local _cCNPJFor        := ""
Local oXml 		       := XmlParserFile(cNFSe,"_",@cError,@cWarning) // irá chamar a função para preparar o XML
Local _cProdSer        := SuperGetMv("MV_ZPROSER", ,"9911")
Local _cSerie          := SuperGetMv("MV_ZSERSER", ,"IS")
Local _cPrefixo        := SuperGetMv("MV_ZPRESER", ,"IS")
Local _cBanco          := SuperGetMv("MV_ZBANSER", ,"CX1")
Local _cCondPag        := SuperGetMv("MV_ZCOPSER", ,"001")
Local cMotBx           := AllTrim(GetNewPar("MV_ZPLBXMB", "NOR"))
Local _cContaCon       := SuperGetMv("MV_ZCONTSE", ,"112010005")
Local _cNatureza       := SuperGetMv("MV_ZNATSER", ,"101001")
Local _nValorSer       := 0
Local _nNotas          := 0
Local _nTotnotas       := 0
Local _dDataEmis       := Nil

Local aRegSD2       := {}
Local aRegSE1       := {}
Local aRegSE2       := {}

Local _lMostraCTB   := .F.
Local _lAglCTB      := .F.
Local _lContab      := .F.
Local _lCarteira    := .F.
Local _lCancelada   := .F.
Local lRet		       := .T.
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

cMsgLog := "Log de Processamento inportação de Nota fiscal de serviço. " + CRLF + "Arquivo: " + cArquivo

U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )

//Verifica se criou o objeto
If ValType(oXml)=="O"

	// Se houve erro ou aviso, na criação do objeto, gerará o log do erro e interromperá a importação
	If !Empty(cError)

		cMsgLog := "Arquivo (Erro): "+RetFileName(cArquivo)+" Erro Capturado: "+Alltrim(cError)
		nArqErro += 1
		lRet     := .F.
		_lErro   := .T.
		U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )

	ElseIf !Empty(cWarning)

		cMsgLog := "Arquivo (Aviso): "+RetFileName(cArquivo)+" Aviso Capturado: "+Alltrim(cWarning)
		nArqErro += 1
		lRet     := .F.
		_lErro   := .T.
		U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )

	EndIf

	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + PadR(_cProdSer,TamSX3("B1_COD")[1]) ))
		SF4->(DbSetOrder(1))
		SF4->(DbGoTop())
		If SF4->(DbSeek(xFilial("SF4") + PadR(SB1->B1_TS,TamSX3("F4_CODIGO")[1]) ))
			SE4->(DbSetOrder(1))
			SE4->(DbGoTop())
			If SE4->(DbSeek(xFilial("SE4") + PadR(_cCondPag,TamSX3("E4_CODIGO")[1]) ))
			Else
				cMsgLog := "* Erro Condição de pagamento =>> Erro: "
				cMsgLog += "Condição " + _cCondPag + " não cadastrada."
				U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
				lRet   := .F.
				_lErro := .T.
			EndIf
		Else
			cMsgLog := "* Erro TES =>> Erro: "
			cMsgLog += "TES " + SB1->B1_TS + " não cadastrada."
			U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
			lRet   := .F.
			_lErro := .T.
		EndIf
	Else
		cMsgLog := "* Erro Produto =>> Erro: "
		cMsgLog += "Produto " + _cProdSer + " não cadastrada."
		U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
		lRet   := .F.
		_lErro := .T.
	EndIf

	If lRet
		// Verifica se o objeto foi criado e diferente de vazio
		If (oXml <> Nil )
			If lRet

				If VALTYPE(OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE) == 'A'
					_nTotnotas := Len(OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE)
				Else
					_nTotnotas := 1
				Endif
				oProcess:SetRegua2( _nTotnotas ) //Alimenta a segunda barra de progresso

				For _nNotas := 1 To _nTotnotas

					oProcess:IncRegua2("Importando nota(s) "+ Alltrim(Str(_nNotas)) + " De " + Alltrim(Str(_nTotnotas)))

					aCabec     := {}
					aItens     := {}
					aLinha     := {}
					_nValorSer := 0
					_cNumNota  := ""
					lRet       := .T.
					_lCancelada := .F.					   

					If XmlNodeExist(OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CPFCNPJ,"_CNPJ")
						_cCNPJFor  :=  OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT
						If XmlNodeExist(OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR,"_INSCRICAOMUNICIPAL")
							_cInscMun  :=  OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT
						Else
							_cInscMun  := "ISENTO"
						EndIf
					ElseIf XmlNodeExist(OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CPFCNPJ,"_CPF")
						_cCNPJFor  :=  OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT
						_cInscMun  := "ISENTO"
					EndIf

					SA1->(DbSetOrder(3))
					SA1->(DbGoTop())
					If (SA1->(DbSeek(xFilial("SA1") + PadR(_cCNPJFor,TamSX3("A1_CGC")[1]) )))
					Else

						_cCodSA1   := sfGatiSA1()
						_cRazaoSo  := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_RAZAOSOCIAL:TEXT
						_cNomeFan  := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_RAZAOSOCIAL:TEXT
						_cMailCli  := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_EMAIL:TEXT
						//_cTelCli   := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_TELEFONE:TEXT
						If XmlNodeExist(OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO,"_BAIRRO")
							_cBaiCli := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_BAIRRO:TEXT
						Else
							_cBaiCli := ""
						Endif 
						_cCepCli   := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CEP:TEXT
						_cCodMuCli := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CODIGOMUNICIPIO:TEXT
						_cDesMuCli := ""
						_cEndCli   := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_ENDERECO:TEXT
						//_cNumCli   := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_NUMERO:TEXT
						_cUfCli    := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_UF:TEXT
						_cEndCli := Alltrim(_cEndCli) //+ ", " + Alltrim(_cNumCli)

						CC2->(DbSetOrder(1))  // CC2_FILIAL+CC2_EST+CC2_CODMUN
						If  CC2->(DbSeek(xFilial("CC2")+ Padr(_cUfCli,TamSX3("CC2_EST")[1]) + Padr(SubStr(_cCodMuCli,3),TamSX3("CC2_CODMUN")[1])))
							_cDesMuCli := CC2->CC2_MUN
						Endif

						aDadosCli :=  {}
						aAdd(aDadosCli,{"A1_PESSOA"  ,Iif(Len(Alltrim(_cCNPJFor)) > 11,"J","F")         ,Nil})
						aAdd(aDadosCli,{"A1_COD"	 ,_cCodSA1                                          ,Nil})
						aAdd(aDadosCli,{"A1_LOJA"	 ,"01"                                              ,Nil})
						aAdd(aDadosCli,{"A1_NOME"	 ,Padr(_cRazaoSo,TamSX3("A1_NOME")[1])	            ,Nil})
						aAdd(aDadosCli,{"A1_NREDUZ"	 ,Padr(_cRazaoSo,TamSX3("A1_NREDUZ")[1])	        ,Nil})
						aAdd(aDadosCli,{"A1_TIPO"	 ,"F"  										        ,Nil})
						aAdd(aDadosCli,{"A1_END"	 ,Padr(_cEndCli,TamSX3("A1_END")[1])	            ,Nil})
						aAdd(aDadosCli,{"A1_EST"	 ,Padr(_cUfCli,TamSX3("A1_EST")[1])		            ,Nil})
						aAdd(aDadosCli,{"A1_MUN"     ,_cDesMuCli                                        ,Nil})
						aAdd(aDadosCli,{"A1_CGC"	 ,Padr(_cCNPJFor,TamSX3("A1_CGC")[1])		        ,Nil})
						aAdd(aDadosCli,{"A1_INSCR"	 ,Padr(_cInscMun,TamSx3("A1_INSCR")[1])	            ,Nil})
						aAdd(aDadosCli,{"A1_CONTA"	 ,Padr(_cContaCon,TamSx3("A1_CONTA")[1])	        ,Nil})
						aAdd(aDadosCli,{"A1_SOCIO"	 ,Padr("AAA",TamSx3("A1_SOCIO")[1])	                ,Nil})
						aAdd(aDadosCli,{"A1_COD_MUN" ,Padr(SubStr(_cCodMuCli,3),TamSX3("A1_COD_MUN")[1]),Nil})
						aAdd(aDadosCli,{"A1_CEP"	 ,Padr(_cCepCli,TamSX3("A1_CEP")[1])		        ,Nil})
						aAdd(aDadosCli,{"A1_BAIRRO"	 ,Padr(_cBaiCli,TamSX3("A1_BAIRRO")[1])             ,Nil})
						aAdd(aDadosCli,{"A1_NATUREZ" ,Padr(_cNatureza,TamSx3("A1_NATUREZ")[1])	        ,Nil})
						aAdd(aDadosCli,{"A1_ESTE"	 ,Padr("SC",TamSx3("A1_ESTE")[1])	                ,Nil})
						aAdd(aDadosCli,{"A1_CODPAIS" ,Padr("01058",TamSx3("A1_CODPAIS")[1])	            ,Nil})
						aAdd(aDadosCli,{"A1_SOCPF"	 ,Padr("00000000000",TamSx3("A1_SOCPF")[1])	        ,Nil})
						aAdd(aDadosCli,{"A1_PAIS"	 ,Padr("105",TamSx3("A1_PAIS")[1])	                ,Nil})
						aAdd(aDadosCli,{"A1_EMAIL"	 ,Padr(_cMailCli,TamSx3("A1_EMAIL")[1])	            ,Nil})
						aAdd(aDadosCli,{"A1_GRPVEN"	 ,Padr("000001",TamSx3("A1_GRPVEN")[1])	            ,Nil})

						aDadosCli := FWVetByDic(aDadosCli, 'SA1',.F.)

						lMsErroAuto := .F.

						MSExecAuto({|x,y|MATA030(x,y)},aDadosCli,3)

						If lMsErroAuto
							cRetAuto := MontaErro(GetAutoGrLog())
							cMsgLog := "* Erro ao tentar cadastrar o cliente : " + Alltrim(_cRazaoSo) + ", CPF/CGC: " + _cCNPJFor +"' =>> Erro: "
							cMsgLog += cRetAuto
							Alert(cMsgLog)
							U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
							lRet := .F.
							_lErro := .T.
						Else
							cMsgLog := "* Realizado cadastro do cliente : " + Alltrim(_cRazaoSo) + ", CPF/CGC: " + _cCNPJFor
							U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
						Endif

					EndIF

					_dDataEmis := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_DATAEMISSAO:TEXT
					_dDataEmis :=  Stod(SubStr(_dDataEmis,1,4) + SubStr(_dDataEmis,6,2) + SubStr(_dDataEmis,9,2))
					_cNumNota  := Padl(alltrim( OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_NUMERO:TEXT),9,'0' )
					_nValorSer := OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas]:_NFSE:_INFNFSE:_VALORESNFSE:_VALORLIQUIDONFSE:TEXT
					_nValorSer := Val(_nValorSer)

					//Verifica se a nota foi cancelada.
					If XmlNodeExist(OXML:_CONSULTARNFSEFAIXARESPOSTA:_LISTANFSE:_COMPNFSE[_nNotas],"_NfseCancelamento")
						_lCancelada := .T.
					Endif 
					If lRet
						//Verifica se a nota ja foi digitada.
						SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						SF2->(DbGoTop())
						If (SF2->(DbSeek(xfilial("SF2") + PADR(_cNumNota,TamSX3('F2_DOC')[1]) + PADR(_cSerie,TamSX3('F2_SERIE')[1]) + SA1->A1_COD  + SA1->A1_LOJA )))

							cMsgLog := "* Erro importação NFse =>> Erro: "
							cMsgLog += "Nota fiscal " + _cNumNota + " série " + _cSerie + " ja cadastrada."
							U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
							lRet   := .F.
							_lErro := .T.

						Else
							aCabec := {} 
							aAdd(aCabec,{"F2_TIPO"    ,"N"           })
							aAdd(aCabec,{"F2_FORMUL"  ,"S"           })
							aAdd(aCabec,{"F2_DOC"     ,_cNumNota	 })
							aAdd(aCabec,{"F2_SERIE"   ,_cSerie       })
							aAdd(aCabec,{"F2_EMISSAO" ,_dDataEmis    })
							aAdd(aCabec,{"F2_CLIENTE" ,SA1->A1_COD   })
							aAdd(aCabec,{"F2_LOJA"    ,SA1->A1_LOJA  })
							aAdd(aCabec,{"F2_ESPECIE" ,"NFS"         })
							aAdd(aCabec,{"F2_TIPOCLI" ,SA1->A1_TIPO  })
							aadd(aCabec,{"F2_COND"    ,_cCondPag     })
							aadd(aCabec,{"F2_DESCONT" ,0             })
							aadd(aCabec,{"F2_FRETE"   ,0             })
							aadd(aCabec,{"F2_SEGURO"  ,0             })
							aadd(aCabec,{"F2_DESPESA" ,0             })

							aLinha := {}
							aAdd(aLinha,{"D2_ITEM"   ,StrZero(1,TamSX3('D2_ITEM')[1]) ,Nil})
							aAdd(aLinha,{"D2_COD"    ,_cProdSer	                      ,Nil})
							aAdd(aLinha,{"D2_QUANT"  ,1	                              ,Nil})
							aAdd(aLinha,{"D2_PRCVEN" ,_nValorSer	                  ,Nil})
							aAdd(aLinha,{"D2_TOTAL"  ,_nValorSer                      ,Nil})
							aAdd(aLinha,{"D2_TES"    ,SB1->B1_TS                      ,Nil})
							aAdd(aLinha,{"D2_ORIGLAN","LF"                            ,Nil})

							aadd(aItens,aLinha)
							lMsErroAuto 	:= .F.

							aCabec := FWVetByDic(aCabec, 'SF2',.F.)
							aItens := FWVetByDic(aItens, 'SD2',.T.)

							MSExecAuto({|x,y,z| Mata920(x,y,z)},aCabec,aItens,3) //Inclusao documanto de saida via livros Ficais.

							If lMsErroAuto
								cRetAuto := MontaErro(GetAutoGrLog())
								cMsgLog := "* Erro na inclusão da nota : " + _cNumNota + "' =>> Erro: "
								cMsgLog += cRetAuto
								U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
								lRet := .F.
								_lErro := .T.
							Else

								SD2->(DbSetOrder(3))
								SD2->(DbGoTop())
								If SD2->(DbSeek(xFilial("SD2") + PADR(_cNumNota,TamSX3('F2_DOC')[1]) + PADR(_cSerie,TamSX3('F2_SERIE')[1]) + SA1->A1_COD  + SA1->A1_LOJA ))
									//Percorre toda tabela SD2 alterando o campo D2_ORIGLAN.
									While !SD2->(Eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC == PADR(_cNumNota,TamSX3('F2_DOC')[1]) .And. SD2->D2_SERIE == PADR(_cSerie,TamSX3('F2_SERIE')[1]) .And. SD2->D2_CLIENTE == SA1->A1_COD .And. SD2->D2_LOJA == SA1->A1_LOJA
										RecLock("SD2",.F.)
										SD2->D2_ORIGLAN := ""
										SD2->(MsUnlock())
										SD2->(DbSkip())
									EndDo
								EndIf

								cMsgLog := "* Nota fiscal " + _cNumNota + " série " + _cSerie + " importada."
								U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )

								//Prepara para incluir titulo.
								_aVetSE1 := {}

								aadd(_aVetSE1 , {"E1_FILIAL"  , xfilial("SE1")	                         , NIL})
								aadd(_aVetSE1 , {"E1_PREFIXO" , Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1])  , NIL})
								aadd(_aVetSE1 , {"E1_NUM" 	  , Padl(_cNumNota,TamSx3("E1_NUM")[1])      , NIL})
								aadd(_aVetSE1 , {"E1_PARCELA" , Padr("",TamSx3("E1_PARCELA")[1]) 	     , NIL})
								aadd(_aVetSE1 , {"E1_TIPO" 	  , Padr("BOL",TamSx3("E1_TIPO")[1])   	     , NIL})
								aadd(_aVetSE1 , {"E1_NATUREZ" , Padr(_cNatureza,TamSx3("E1_NATUREZ")[1]) , NIL})
								aadd(_aVetSE1 , {"E1_CLIENTE" , SA1->A1_COD                              , NIL})
								aadd(_aVetSE1 , {"E1_LOJA"    , SA1->A1_LOJA 	                         , NIL})
								aadd(_aVetSE1 , {"E1_EMISSAO" , _dDataEmis		                         , NIL})
								aadd(_aVetSE1 , {"E1_EMIS1"   , _dDataEmis		        	             , NIL})
								aadd(_aVetSE1 , {"E1_VENCTO"  , _dDataEmis                               , NIL})
								aadd(_aVetSE1 , {"E1_VALOR"   , _nValorSer                               , NIL})

								_aVetSE1 := FWVetByDic(_aVetSE1, 'SE1')

								lMsErroAuto 	:= .F.

								MSExecAuto({|x,y| Fina040(x,y)},_aVetSE1,3)

								If lMsErroAuto
									cRetAuto := MontaErro(GetAutoGrLog())
									cMsgLog := "* Erro na inclusçao de titulo referente a nota : " + _cNumNota + "' =>> Erro: "
									cMsgLog += cRetAuto
									U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
									lRet := .F.
									_lErro := .T.

								Else

									SE1->( DbGoTop() )
									SE1->(DBSETORDER(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									If(SE1->( DbSeek( XFILIAL('SE1') + SA1->A1_COD + SA1->A1_LOJA + Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1]) + Padr(_cNumNota,TamSx3("E1_NUM")[1]))))

										While (SE1->E1_PREFIXO == Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1])) .And. (SE1->E1_NUM == Padr(_cNumNota,TamSx3("E1_NUM")[1])) .And. (SE1->E1_CLIENTE == SA1->A1_COD) .And. (SE1->E1_LOJA == SA1->A1_LOJA) .And. (!SE1->(Eof()))
											//Alterando origem do titulo para vincular a nota fiscal.
											RecLock("SE1",.F.)
											SE1->E1_ORIGEM := "MATA920"
											SE1->(MsUnlock())
											SE1->(DbSkip())
										EndDo
									EndIf
									SE1->( DbGoTop() )
									SE1->(DBSETORDER(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									If(SE1->( DbSeek( XFILIAL('SE1') + SA1->A1_COD + SA1->A1_LOJA + Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1]) + Padr(_cNumNota,TamSx3("E1_NUM")[1]) + Padr("",TamSx3("E1_PARCELA")[1]) + Padr("BOL",TamSx3("E1_TIPO")[1]) )))
										If !Empty(_cBanco)
											SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
											SA6->(dbGoTop())
											If SA6->(dbSeek(xFilial("SA6") + _cBanco))
												//Baixar titulos
												aBaixa := {{"E1_FILIAL" , SE1->E1_FILIAL                        , Nil     },;
												{"E1_PREFIXO"   , SE1->E1_PREFIXO                               , Nil     },;
												{"E1_NUM"       , SE1->E1_NUM                                   , Nil     },;
												{"E1_CLIENTE"   , SE1->E1_CLIENTE                               , Nil     },;
												{"E1_LOJA"      , SE1->E1_LOJA                                  , Nil     },;
												{"E1_TIPO"      , SE1->E1_TIPO                                  , Nil     },;
												{"E1_PARCELA"   , SE1->E1_PARCELA                               , Nil     },;
												{"AUTMOTBX"     , cMotBx                                        , Nil     },;
												{"AUTBANCO"     , PadR(SA6->A6_COD,TamSx3("E5_BANCO")[1])       , Nil     },;
												{"AUTAGENCIA"   , PadR(SA6->A6_AGENCIA,TamSx3("E5_AGENCIA")[1]) , Nil     },;
												{"AUTCONTA"     , PadR(SA6->A6_NUMCON,TamSx3("E5_CONTA")[1])    , Nil     },;
												{"AUTDTBAIXA"   , _dDataEmis                                    , Nil     },;
												{"AUTDTCREDITO" , _dDataEmis                                    , Nil     },;
												{"AUTHIST"      , "Baixa automatica rotina AGR05A01."           , Nil     },;
												{"AUTJUROS"     , 0                                             , Nil, .T.},;
												{"AUTVALREC"    , _nValorSer                                    , Nil     }}

												lMsErroAuto := .F.

												MSExecAuto({|x, y| Fina070(x, y)}, aBaixa, 3)

												If lMsErroAuto
													cRetAuto := MontaErro(GetAutoGrLog())
													cMsgLog := "* Erro na baixa do titulo de Prefixo : " + SE1->E1_PREFIXO + ", Numero: " + SE1->E1_NUM + " e Parcela: '" + SE1->E1_PARCELA + "' =>> Erro: "
													cMsgLog += cRetAuto
													U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
													lRet := .F.
													_lErro := .T.
												EndIf

											Else
												cRetAuto := MontaErro(GetAutoGrLog())
												cMsgLog := "* Erro na baixa do titulo de Prefixo : " + SE1->E1_PREFIXO + ", Numero: " + SE1->E1_NUM + " e Parcela: '" + SE1->E1_PARCELA + "' =>> Erro: "
												cMsgLog += "Banco " + _cBanco + " não cadastrado na base de dados"
												U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
												lRet := .F.
												_lErro := .T.
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf

						If _lCancelada

							//Verifica se a nota ja foi digitada.
							SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
							SF2->(DbGoTop())
							If (SF2->(DbSeek(xfilial("SF2") + PADR(_cNumNota,TamSX3('F2_DOC')[1]) + PADR(_cSerie,TamSX3('F2_SERIE')[1]) + SA1->A1_COD  + SA1->A1_LOJA )))

								_dDataEmis := SF2->F2_EMISSAO

								_lRetExc := MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
								If _lRetExc
									SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,_lMostraCTB,_lAglCTB,_lContab,_lCarteira))
									_lExcluida := .T.
								Else
									cMsgLog := "* Erro no cancelamento da nota : " + _cNumNota + "'"
									U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
									lRet   := .F.
									_lErro := .T.
								EndIf
								If _lExcluida
									cMsgLog := "Nota fiscal " + _cNumNota + " série " + _cSerie + " cancelada."
									U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
									lRet   := .F.

									SE1->( DbGoTop() )
									SE1->(DBSETORDER(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									If(SE1->( DbSeek( XFILIAL('SE1') + SA1->A1_COD + SA1->A1_LOJA + Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1]) + Padr(_cNumNota,TamSx3("E1_NUM")[1]) + Padr("",TamSx3("E1_PARCELA")[1]) + Padr("BOL",TamSx3("E1_TIPO")[1]) )))
										aBaixa := {}
										If !Empty(_cBanco)
											SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
											SA6->(dbGoTop())
											If SA6->(dbSeek(xFilial("SA6") + _cBanco))
												//Baixar titulos
												aBaixa := {{"E1_FILIAL" , SE1->E1_FILIAL                        , Nil     },;
												{"E1_PREFIXO"   , SE1->E1_PREFIXO                               , Nil     },;
												{"E1_NUM"       , SE1->E1_NUM                                   , Nil     },;
												{"E1_CLIENTE"   , SE1->E1_CLIENTE                               , Nil     },;
												{"E1_LOJA"      , SE1->E1_LOJA                                  , Nil     },;
												{"E1_TIPO"      , SE1->E1_TIPO                                  , Nil     },;
												{"E1_PARCELA"   , SE1->E1_PARCELA                               , Nil     },;
												{"AUTMOTBX"     , cMotBx                                        , Nil     },;
												{"AUTBANCO"     , PadR(SA6->A6_COD,TamSx3("E5_BANCO")[1])       , Nil     },;
												{"AUTAGENCIA"   , PadR(SA6->A6_AGENCIA,TamSx3("E5_AGENCIA")[1]) , Nil     },;
												{"AUTCONTA"     , PadR(SA6->A6_NUMCON,TamSx3("E5_CONTA")[1])    , Nil     },;
												{"AUTDTBAIXA"   , _dDataEmis                                    , Nil     },;
												{"AUTDTCREDITO" , _dDataEmis                                    , Nil     },;
												{"AUTHIST"      , "Baixa automatica rotina AGR05A01."           , Nil     },;
												{"AUTJUROS"     , 0                                             , Nil, .T.},;
												{"AUTVALREC"    , SE1->E1_VALOR                                 , Nil     }}
												lMsErroAuto := .F.
												MSExecAuto({|x, y| Fina070(x, y)}, aBaixa, 6)
												If !(lMsErroAuto)
													While (SE1->E1_PREFIXO == Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1])) .And. (SE1->E1_NUM == Padr(_cNumNota,TamSx3("E1_NUM")[1])) .And. (SE1->E1_CLIENTE == SA1->A1_COD) .And. (SE1->E1_LOJA == SA1->A1_LOJA) .And. (!SE1->(Eof()))
														//Alterando origem do titulo para vincular a nota fiscal.
														RecLock("SE1")
														SE1->(dbDelete())
														SE1->(MsUnLock())
														SE1->(DbSkip())
													EndDo
												EndIf
											EndIf
										EndIf
									EndIf

								Else
									cMsgLog := "* Erro no cancelamento da nota : " + _cNumNota + "'"
									U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
									lRet   := .F.
									_lErro := .T.
								EndIf
							EndIf
						EndIf
					Endif 
				Next _nNotas
			EndIf
		Else
			cMsgLog := "Arquivo com  erro."
			lRet := .F.
			_lErro := .T.
			U_AGR05A2H( CARACTERES + CRLF + cMsgLog + CRLF )
		EndIF
	EndIf
EndIF

Return(lRet)

//Função para abrir o arquivo, trazer a string e fechar arquivo.
Static Function AbreNFSe(cArquivo)
Local cXMLOri	:= ""
Local cXMLEncod	:= ""
Local nPosPesq	:= 0
Local cStrXML	:= ""
Local nHandle 	:= FOpen(cArquivo)
Local nLength 	:= FSeek(nHandle,0,FS_END)

FSeek(nHandle,0)

If nHandle > 0

	FRead(nHandle, cXMLOri, nLength)

	FClose(nHandle)

	If !Empty(cXMLOri)
		If SubStr(cXMLOri,1,1) != "<"
			nPosPesq := At("<",cXMLOri)
			cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
		EndIf
	EndIf

	cXMLEncod := EncodeUtf8(cXMLOri)

	// Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode, neste caso e feito o tratamento pela funcao A140IRemASC
	If Empty(cXMLEncod)
		cStrXML := cXMLOri
		cXMLOri := A140IRemASC(cStrXML)
		cXMLEncod := EncodeUtf8(cXMLOri)
	EndIf

	If Empty(cXMLEncod)
		cXMLEncod := cXMLOri
	EndIf

EndIf

Return(cXMLEncod)

Static Function sfGatiSA1()

Local _cRet     := ""
Local _cQuery   := ""
Local _aRetSQL  := {}

_cQuery := " SELECT MAX(A1_COD)"                 + CRLF
_cQuery += " FROM  " + RetSqlName("SA1")+" SA1"  + CRLF
_cQuery += " WHERE " + RetSqlCond('SA1')         + CRLF
_cQuery += " AND LEN(A1_COD) >= 5 "   + CRLF

memowrit("c:\query\sfGatiSA1.txt",_cQuery)

_aRetSQL := U_AGR05A2S(_cQuery)

_cRet := Soma1(_aRetSQL[01][01])

Return(_cRet)

Static Function MontaErro(aErro)

Local nI
Local cMsg := ""

For nI := 1 To Len(aErro)
	cMsg += aErro[nI] + CRLF
Next
Return(cMsg)
