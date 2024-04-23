#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"


User Function RCTEC02()
	Local aSeek   := {}
	Private bFiltro	:= {|| REFRESH(.T.) } // Variavel para tecla F12
	Private oMarca
	//Public cMsgPerm := "Usuário sem Permissão" // MSG PADRAO USUARIO SEM PERMISSAO
	Private oTempMRK
	Private MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11
	Private _Mv_par01,_Mv_par02,_Mv_par03,_Mv_par04,_Mv_par05,_Mv_par06,_Mv_par07,_Mv_par08,_Mv_par09,_Mv_par10,_Mv_par11

	// INICIO GERACAO DE TELA
	// Array da Estrutura a ser criada
	aStru:={}
	Aadd(aStru,{"FILIAL"     ,"C",02,0})
	Aadd(aStru,{"NUMERO"   ,"C",9,0})
	Aadd(aStru,{"SERIE"   ,"C",3,0})
	Aadd(aStru,{"FORNECEDOR"  ,"C",8,0})
	Aadd(aStru,{"LOJA"  ,"C",4,0})
	Aadd(aStru,{"CONDPAGTO","C",3,0})
	Aadd(aStru,{"DTEMISSAO","D",8,0})
	Aadd(aStru,{"DTDIGI"   ,"D",8,0})
	Aadd(aStru,{"CLASSIFICADO"   ,"C",1,0})
	//Aadd(aStru,{"BLEST"   ,"C",2,0})
	//Aadd(aStru,{"BLCRED"   ,"C",2,0})
	//Aadd(aStru,{"IDSZA","C",10,0})
	//Aadd(aStru,{"TOTALITENS"  ,"N",12,3})
	//Aadd(aStru,{"STATUS","C",1,0})
	//Aadd(aStru,{"NFISCAL"   ,"C",09,0})
	//Aadd(aStru,{"NFSERIE"   ,"C",03,0})
	//Aadd(aStru,{"EMISSAONF"   ,"C",8,0})
	//Aadd(aStru,{"REG"  ,"N",16,0})
	//Aadd(aStru,{"LOJA"  ,"C",4,0})
	//Aadd(aStru,{"PRODUTO"  ,"C",15,0})

	//aAdd(aSeek,{"Pedido"   ,{{"","C",010,0,"Pedido"    ,"@!"}} } )

	// Abre uma Tabela TRC1 (Temporaria)
	If (Select("TRC1") <> 0)
		dbSelectArea("TRC1")
		dbCloseArea()
	Endif

	// PERGUNTA QUANDO O USUARIO ABRE A TELA
	//If	!Pergunte("ITCDIG",.T.)
	//	Msginfo("Cancelado!","Picking")
	//	return
	//Endif

	//Cria a temporária
	oTempTable := FWTemporaryTable():New( "TRC1" )
	//Define as colunas usadas
	oTempTable:SetFields( aStru )

	//Cria índice com colunas setadas anteriormente
	oTempTable:AddIndex("01", {"NUMERO"} )

	//Efetua a criação da tabela
	oTempTable:Create()

	DbSelectArea('TRC1')

	// Janela que mostra ao carregar
	Processa({||GeraDados()},'Gerando informacoes...')

	TRC1->(DbGoTop()) // Primeiro registro da tabela
	If TRC1->(!Eof())
		oMarca := FWMarkBrowse():New()
		oMarca:SetDescription('Classificar Notas Pendentes')
		oMarca:SetParam(bFiltro) // Padrão de chamada da tecla F12
		oMarca:SetAlias("TRC1")
		oMarca:SetFieldMark( "OK" )
		oMarca:oBrowse:SetDBFFilter(.T.)
		oMarca:oBrowse:SetUseFilter(.T.)
		oMarca:oBrowse:SetFixedBrowse(.T.)
		oMarca:SetWalkThru(.F.)
		oMarca:SetAmbiente(.T.)
		oMarca:SetTemporary()
		oMarca:oBrowse:SetSeek(.T.,aSeek)
		oMarca:oBrowse:SetFilterDefault("")

		bReceb := "" //Liberar Financeiro - C para E ou S
		//bLibEst := "" //Liberar Estoque - E para S
		//bLibSep  := "" //Liberar Separacao - S para W
		//bLog := "" //Log do Pedido
		bObs := "" //Observações
		//bVisPed := "" //Visualizar Pedido

		bReceb := {|| Recebimento() }
		//bLibEst := {|| LibEstoque()  }
		//bLibSep := {|| LibSeparacao() }
		//bLog := {|| LogPedido(TRC1->PEDIDO) }
		bObs := {|| fObserv(TRC1->NUMERO) }
		//bVisPed := {|| VisPedido("V",TRC1->REG) }
		//bAlt := {|| U_ALTERCLI(TRC1->CLIENTE,TRC1->LOJA) }
		//bFat := {||  fFaturar() }

		// Botões da Tela e Outras Ações
		oMarca:AddButton('Receber',bReceb)
		//oMarca:AddButton('Liberar Estoque',bLibEst)
		//oMarca:AddButton('Liberar Separação',bLibSep)
		//oMarca:AddButton('Log Pedido',bLog)
		oMarca:AddButton('Observações',bObs)
		//oMarca:AddButton('Visualizar Pedido',bVisPed)
		//oMarca:AddButton('Alterar Cliente',bAlt)
		//oMarca:AddButton('Gerar Faturamento',bFat)

		oMarca:ForceQuitButton(.T.)

		// Adicionando as Legendas
		oMarca:AddLegend( "ALLTRIM(CLASSIFICADO) == 'N'", "BR_AMARELO","Pendente Recebimento" )
		//oMarca:AddLegend( "ALLTRIM(STATUS) == 'E'", "BR_VERMELHO","Estoque Bloqueado" )
		//oMarca:AddLegend( "ALLTRIM(STATUS) == 'S'", "BR_LARANJA","Aguardando Separação" )
		//oMarca:AddLegend( "ALLTRIM(STATUS) == 'W'", "BR_VIOLETA","Em Processo de Expedição" )
		//oMarca:AddLegend( "ALLTRIM(STATUS) == 'F'", "BR_MARROM","Aguardando Faturamento" )
		//oMarca:AddLegend( "ALLTRIM(STATUS) == 'X'", "BR_VERDE","Faturado" )
		//oMarca:AddLegend( "ALLTRIM(STATUS) == 'L'", "BR_PRETO","Limite de Alçada Incompatível" )


		// Adicionando as colunas
		oColumn := FWBrwColumn():New()
		oColumn:SetData({||FILIAL})
		oColumn:SetTitle("Filial")
		oColumn:SetSize(2)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||NUMERO})
		oColumn:SetTitle("Numero")
		oColumn:SetSize(9)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||SERIE})
		oColumn:SetTitle("Serie")
		oColumn:SetSize(3)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||FORNECEDOR})
		oColumn:SetTitle("Fornecedor")
		oColumn:SetSize(8)
		//oColumn:SetPicture("@E 999,999.99")
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||LOJA})
		oColumn:SetTitle("Loja")
		oColumn:SetSize(4)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||CONDPAGTO})
		oColumn:SetTitle("Cond. Pagto")
		oColumn:SetSize(3)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||DTEMISSAO})
		oColumn:SetTitle("DT Emissao")
		oColumn:SetSize(8)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||DTDIGI})
		oColumn:SetTitle("DT Digitacao")
		oColumn:SetSize(8)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||CLASSIFICADO})
		oColumn:SetTitle("Classificado")
		oColumn:SetSize(1)
		oMarca:SetColumns({oColumn})

		/*oColumn := FWBrwColumn():New()
		oColumn:SetData({||BLCRED})
		oColumn:SetTitle("Block Credito")
		oColumn:SetSize(2)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||IDSZA})
		oColumn:SetTitle("Fluxo SZA")
		oColumn:SetSize(10)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||TOTALITENS})
		oColumn:SetTitle("Total Itens")
		oColumn:SetSize(7)
		oColumn:SetPicture("@E 999,999.99")
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||STATUS})
		oColumn:SetTitle("Status")
		oColumn:SetSize(1)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||NFISCAL})
		oColumn:SetTitle("Nota Fiscal")
		oColumn:SetSize(9)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||NFSERIE})
		oColumn:SetTitle("Serie NF")
		oColumn:SetSize(3)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||EMISSAONF})
		oColumn:SetTitle("Emissao NF")
		oColumn:SetSize(8)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||REG})
		oColumn:SetTitle("Registro SC5")
		oColumn:SetSize(16)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||LOJA})
		oColumn:SetTitle("Loja Cliente")
		oColumn:SetSize(16)
		oMarca:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||PRODUTO})
		oColumn:SetTitle("Cod Produto")
		oColumn:SetSize(15)
		oMarca:SetColumns({oColumn})*/

		oMarca:Activate()
		oMarca:oBrowse:Setfocus()
		//FINAL GERACAO DE TELA
	else
		MSGINFO("Nenhum registro encontrado.")
	endif

RETURN

// FUNCAO PARA CHAMAR O REFRESH DA TELA E AS PERGUNTAS F12
STATIC FUNCTION REFRESH(bParam)

	//Pergunte("ITCDIG",bParam)

	Processa({||GeraDados()},'Gerando informacoes...')
	//oMarca:SetParam(bFiltro)
	oMarca:SetInvert(.F.)
	oMarca:Refresh(.T.)
	SetKey( VK_F12,{|| REFRESH(.T.) })
RETURN

// Função que chama os dados
STATIC FUNCTION GeraDados()

	Local cQuery    := ""

	cQuery := "SELECT F1_FILIAL FILIAL, F1_DOC NUMERO, F1_SERIE SERIE, F1_FORNECE FORNECEDOR, F1_LOJA LOJA, F1_COND CONDPAGTO, F1_EMISSAO DTEMISSAO, F1_DTDIGIT DTDIGI "
	cQuery += "FROM "+RetSQLName("SF1") + " SF1 WHERE F1_COND = '352' AND SF1.D_E_L_E_T_ <> '*' "
    cQuery += "ORDER BY F1_DOC "	
	

	// Abre tabela TEMPITA (Temporaria)
	If (Select("TRC2") <> 0)
		dbSelectArea("TRC2")
		dbCloseArea()
	Endif

	If (Select("TRC1") <> 0)
		dbSelectArea("TRC1")
		dbCloseArea()
	Endif

	//Cria a temporária
	oTempTable := FWTemporaryTable():New( "TRC1" )
	//Define as colunas usadas
	oTempTable:SetFields( aStru )

	//Cria índice com colunas setadas anteriormente
	oTempTable:AddIndex("01", {"PEDIDO"} )

	//Efetua a criação da tabela
	oTempTable:Create()

	DbSelectArea('TRC1')

	TCQuery cQuery NEW ALIAS "TRC2"

	dbSelectArea("TRC2")
	dbGoTop()
	Procregua(reccount())

	WHILE !(TRC2->(Eof()))

		Reclock("TRC1",.T.)
		TRC1->FILIAL := TRC2->F1_FILIAL
		TRC1->NUMERO := TRC2->F1_DOC
		TRC1->SERIE := TRC2->F1_SERIE
		TRC1->FORCENEDOR := TRC2->F1_FORNECEDOR
		TRC1->LOJA := TRC2->F1_LOJA
		TRC1->CONDPAGTO := TRC2->F1_CONDPAGTO
		TRC1->DTEMISSAO := TRC2->F1_DTEMISSAO
		TRC1->DTDIGI := TRC2->F1_DTDIGI
		TRC1->CLASSIFICADO := TRC2->F1_CLASS
		//TRC1->IDSZA := TRC2->ZA_ID
		//TRC1->TOTALITENS := TRC2->TOTALITENS
		//TRC1->STATUS := TRC2->ZA_STATUS
		//TRC1->NFISCAL := TRC2->C9_NFISCAL
		//TRC1->NFSERIE := TRC2->C9_SERIENF
		//TRC1->EMISSAONF := TRC2->F2_EMISSAO
		//TRC1->REG := TRC2->SC5REG
		//TRC1->PEDORI := TRC2->C5_PEDORI
		//TRC1->LOJA := TRC2->C9_LOJA
		MsUnlock()

		TRC2->(dbSkip())
	END

RETURN

STATIC FUNCTION Recebimento()

	Local cMarca := oMarca:Mark()
	Local cMsg := "Liberado(s) Financeiro: "
	Local cMsgPed := ""
	Local nQtd := 0
	Local cQueryqtd := ""
	Local cUsrName := UsrRetName(RetCodUsr())

	Private aRotina := {	;
		{"Pesquisar" 	,"PesqBrw"	  	, 0 , 1 , 0 , .F.},;
		{"Visualizar"	,"A410Visual" 	, 0 , 2 , 0 , NIL},;
		{"Liberar"   	,"A440Libera" 	, 0 , 6 , 0 , NIL},;
		{"Automático"	,"A440Automa" 	, 0 , 0 , 0 , NIL},;
		{"Legenda"   	,"A410Legend" 	, 0 , 0 , 0 , .F.}}

	cStatus := "S"

	DBSELECTAREA("SX5")
	DBSETORDER(1)

	IF (DBSEEK( xFilial("SX5")+"ZC"+__cUserId))// VALIDA SE O USUARIO TEM PERMISSAO

		ProcRegua(TRC1->(RecCount()))
		dbSelectArea("TRC1")
		TRC1->(DbGoTop())
		While !TRC1->(EoF())
			IF(oMarca:IsMark(cMarca))

				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				SC5->(dbGoTo(TRC1->REG))
				cCodSza := SC5->C5_CODSZA // Recebe o ID da SZA
				cPedido := ALLTRIM(TRC1->PEDIDO)

				DBSELECTAREA("ZCA")
				DBSETORDER(1)
				IF(DBSEEK(xFilial("ZCA")+__cUserId))
					IF (TRC1->TOTALPED < ZCA->ZCA_MIN .OR. TRC1->TOTALPED > ZCA->ZCA_MAX )
						Help( ,, 'Help',, "Usuário sem limite de alçada",1,0)
						U_ADDSZAB(cPedido,cCodSza, "L", "Limite de Alçada incompativel, Pedido: "+cPedido)
						RECLOCK("TRC1",.F.)
						TRC1->STATUS = "L"
						MSUNLOCK()
						TRC1->(dbskip())
						loop
					ENDIF
				ELSE
					Help( ,, 'Help',, "Usuário sem liberação de alçada",1,0)
					U_ADDSZAB(cPedido,cCodSza, "L", "Usuário sem liberação de alçada, Pedido: "+cPedido)
					RECLOCK("TRC1",.F.)
					TRC1->STATUS = "L"
					MSUNLOCK()
					RETURN
				ENDIF


				IF (TRC1->STATUS <> "C") .AND. (TRC1->STATUS <> "L")
					Help( ,, 'Help',, "Pedido "+cPedido+" não está no processo de liberação Financeira",1,0)
					TRC1->(dbskip())
				ELSE

					IF (TRC1->STATUS == "L")
						U_ADDSZAB(cPedido,cCodSza, "C", "Liberado Alçada Financeira, Pedido: "+cPedido)
					ENDIF

					If (Select("TEMPQTD") <> 0)
						dbSelectArea("TEMPQTD")
						dbCloseArea()
					Endif

					//NAO TIRAR
					dbSelectArea("SC9")
					SC9->(dbSetOrder(1))
					If SC9->(dbSeek(xFilial("SC9") + AllTrim(TRC1->PEDIDO)))

						// QUERY PARA VERIFICAR QTD DE BLOQUEIO FINANCEIRO SC9
						cQueryqtd := " SELECT COUNT(C9_BLCRED) AS QTD "
						cQueryqtd += " FROM "+ RetSqlName("SC9")
						cQueryqtd += " WHERE C9_FILIAL  = '"+ xFilial("SC9") +"' "
						cQueryqtd += " AND   C9_PEDIDO  = '"+ cPedido +"' "
						cQueryqtd += " AND   C9_BLCRED  != '  ' "
						cQueryqtd += " AND   D_E_L_E_T_  = '  ' "
						cQueryqtd += " AND   C9_NFISCAL  = '  ' "
						cQueryqtd += " ORDER BY R_E_C_N_O_ DESC "

						TCQuery cQueryqtd NEW ALIAS "TEMPQTD"

						WHILE (SC9->C9_BLCRED = "  ") .AND. (SC9->C9_PEDIDO = cPedido)
							SC9->(DBSKIP())
						ENDDO

						// SE TIVER BLOQUEIO, EXECUTA A LIBERACAO
						If (TEMPQTD->QTD > 0)


							//Libera Financeiro (FUNCAO PADRAO)

							IF !(EMPTY(SC5->C5_PEDORI))
								U_VincSc5 (SC5->C5_PEDORI)
							ENDIF

							IF(U_CHECKFIN(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_CONDPAG))

								ConOut("Liberando Financeiro")
								A450LibMan()

								U_ITCUPDC9(cCodSza, cPedido)

								cMsgPed += cPedido + " "

							ENDIF

							// LIMPA A QUERY ANTERIOR E GERA UMA NOVA
							DBSELECTAREA( "TEMPQTD" )
							dbclosearea()
							TCQuery cQueryqtd NEW ALIAS "TEMPQTD"
							// CASO O USUARIO TENHA CLICADO EM CANCELAR NA JANELA DE LIBERACAO FIN
							// VERIFICA NOVAMENTE O BLOQUEIO DE CREDITO
							DBSELECTAREA( "TEMPQTD" )
							IF (TEMPQTD->QTD > 0)
								MSGINFO("PEDIDO NÃO LIBERADO OU CANCELADO, VERIFIQUE CONDIÇÕES FINANCEIRAS")
								TRC1->(dbskip())
								loop
							ELSE
								// Melhoria 19/03/2024
								RecLock("SC5", .F.)
								SC5->C5_ZUSAPCR:=cUsrName
								SC5->C5_ZDTAPCR:= Date()
								SC5->C5_ZTPAPCR:="Manual"
								MsUnLock ()
							ENDIF
							dbclosearea()

						ENDIF

						nQtd ++

						If Select("TEMPQTD") <> 0
							dbselectarea("TEMPQTD")
							dbCloseArea()
						ENDIF

						If Select("TEMPEST") <> 0
							dbselectarea("TEMPEST")
							dbCloseArea()
						ENDIF

						cQueryEst := " SELECT COUNT(C9_BLEST) AS QTDBLQ "
						cQueryEst += " FROM "+ RetSqlName("SC9")
						cQueryEst += " WHERE C9_FILIAL  = '"+ xFilial("SC9") +"' "
						cQueryEst += " AND   C9_PEDIDO  = '"+ cPedido +"' "
						cQueryEst += " AND   C9_BLEST  != '  ' "
						cQueryEst += " AND   D_E_L_E_T_  = '  ' "
						cQueryEst += " AND   C9_NFISCAL  = '  ' "
						cQueryEst += " ORDER BY R_E_C_N_O_ DESC "

						TCQuery cQueryEst NEW ALIAS "TEMPEST"

						If (TEMPEST->QTDBLQ > 0)
							cStatus := "E"
						ENDIF

						dbCloseArea()

						IF(SC5->C5_XORIGEM != "2" .AND. cStatus = "S")
							cStatus := "F"
						ENDIF



						IF(cStatus == "E")
							U_ADDSZAB(cPedido,cCodSza, cStatus, "Bloqueio de Estoque: "+cPedido)
						ELSE
							IF(cStatus == "F")
								U_ADDSZAB(cPedido,cCodSza, cStatus,  "Liberado para Faturamento: "+cPedido)
							ELSE
								U_ADDSZAB(cPedido,cCodSza, cStatus, "Liberado para Separação: "+cPedido)
							ENDIF
						ENDIF
						MsUnlock()

						incproc("Pedido: "+TRC1->PEDIDO+" Liberado")

						RecLock("TRC1", .F.)
						TRC1->OK := ""
						TRC1->STATUS := cStatus
						MsUnlock()
					ENDIF
				ENDIF
				fObserv(cCodSza)
			ENDIF
			TRC1->(dbskip())
		ENDDO

		oMarca:Refresh(.T.)
		IF(!Empty(cMsgPed) .AND. nQtd > 0)
			MSGALERT(cMsg+cMsgPed)
		ENDIF
	ELSE
		MSGALERT(cMsgPerm)
	ENDIF
RETURN

// LOG DO PEDIDO //
STATIC FUNCTION LogPedido(cPedido)
	Local _aLista := {}

	Local cQuery    := ""

	cQuery := "SELECT ZB_ID, ZB_DATA, ZB_HORA, ZB_USER, ZB_OBS, ZB_STATUS "
	cQuery += " FROM  "+RetSQLName("SZB")+" SZB "
	cQuery += "INNER JOIN "+RetSQLName("SC5")+" SC5 "
	cQuery += "ON C5_CODSZA  = ZB_ID AND SC5.D_E_L_E_T_ = ' '  "
	cQuery += " WHERE  SZB.D_E_L_E_T_  = ' ' and C5_NUM = '"+cPedido+"' ORDER BY SZB.R_E_C_N_O_ "

	// Abre tabela TEMPITA (Temporaria)
	If (Select("TEMPITAL") <> 0)
		dbSelectArea("TEMPITAL")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "TEMPITAL"

	dbSelectArea("TEMPITAL")
	dbGoTop()
	Procregua(reccount())

	WHILE !(TEMPITAL->(Eof()))

		AADD(_aLista,{TEMPITAL->ZB_STATUS,TEMPITAL->ZB_DATA,TEMPITAL->ZB_HORA, TEMPITAL->ZB_OBS, TEMPITAL->ZB_USER})

		TEMPITAL->(dbSkip())
	END

	dbCloseArea()

	DEFINE DIALOG oDlg TITLE "Log do Pedido: "+cPedido FROM 0,0 TO 440,600 PIXEL

	@ 10,10 LISTBOX oLbx FIELDS HEADER "Status", "Data", "Hora", "Log",  "User" SIZE 279,186 OF oDlg PIXEL
	oLbx:SetArray( _aLista )
	oLbx:bLine := {|| {_aLista[oLbx:nAt,1],;
		DTOC(STOD(_aLista[oLbx:nAt,2])),;
		_aLista[oLbx:nAt,3],;
		_aLista[oLbx:nAt,4],;
		_aLista[oLbx:nAt,5]}}

	DEFINE SBUTTON FROM 202,140 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER

RETURN

// CARREGA OBSERVACOES //
STATIC FUNCTION fObserv(_cCodPick)

	Local _cTxtLog     := ""
	Local _cObserv     := ""
	Local _oFontCabO   := TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
	Local _oFontObs    := TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)
	Private _lContinua := .F.

	If (Select("TEMPOBS") <> 0)
		dbSelectArea("TEMPOBS")
		dbCloseArea()
	Endif

	_cQuery := " SELECT NVL(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(ZCG.ZCG_OBSERV,2000,1)), ' ') ZCG_OBSERV, ZCG.ZCG_DATA, ZCG.ZCG_HORA, ZCG.ZCG_CODUSU "
	_cQuery += " FROM " + RetSQLName("ZCG") + " ZCG "
	_cQuery += " WHERE ZCG.ZCG_ENTIDA = 'SZA' "
	_cQuery += "   AND ZCG.ZCG_FILIAL = '" + xFilial("ZCG") + "' "
	_cQuery += "   AND ZCG.ZCG_CODENT = '" + _cCodPick + "' "
	_cQuery += "   AND ZCG.D_E_L_E_T_ = ' ' "
	_cQuery += " ORDER BY R_E_C_N_O_ DESC "

	TCQuery _cQuery NEW ALIAS "TEMPOBS"

	While TEMPOBS->(!Eof())

		If Alltrim(TEMPOBS->ZCG_OBSERV) != "" .AND. TEMPOBS->ZCG_OBSERV != Nil
			_cTxtLog += "[ " + UsrRetName(TEMPOBS->(ZCG_CODUSU)) + " - " + Transform(StoD(TEMPOBS->ZCG_DATA), "@!") + " - " + TEMPOBS->ZCG_HORA + "]: " + TEMPOBS->ZCG_OBSERV + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		EndIf

		TEMPOBS->(dbSkip())

	End

	If Empty(_cTxtLog)
		_cTxtLog := "Pick não possui registro de observações anteriores."
	EndIf

	_oDlgObs	:= TDialog():New(000,000,470,520,"PEDIDO: " + TRC1->PEDIDO,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	_oSay1		:= TSay():New(000,005,{|| "Histórico do pedido: " + TRC1->PEDIDO},_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet1	:= TMultiget():New(010,005,{|u| _cTxtLog},_oDlgObs,250,130,_oFontObs,,,,,.T.)
	_oMtGet1:lReadOnly := .T.

	_oSay2		:= TSay():New(145,005,{|| "Informe a Observação Desejada:" },_oDlgObs,,_oFontCabO,,,,.T.,CLR_BLACK,CLR_WHITE,200,10)
	_oMtGet2	:= TMultiget():New(155,005,{|u| if(Pcount()>0,_cObserv := u,_cObserv)},_oDlgObs,250,060,_oFontObs,,,,,.T.)
	_oBtConf	:= TButton():New(220,130,"Confirmar"  ,_oDlgObs,{|| (U_fSalvaObs(_cObserv, _cCodPick), _oDlgObs:End())},60,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtClos	:= TButton():New(220,195,"Sair"	      ,_oDlgObs,{|| _oDlgObs:End()                                  },60,15,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oBtConf:SetCss(EstiloBt("OK.png"))
	_oBtClos:SetCss(EstiloBt("CANCEL.png"))

	_oDlgObs:Activate(,,,.T.,{|| .t.},,{|| .t.})

RETURN _lContinua

//GRAVA OBSERVACOES
USER FUNCTION fSalvaObs(_cObsSalv, _cCodEnt)

	If !Empty(_cObsSalv)

		RecLock("ZCG", .T.)
		ZCG->ZCG_FILIAL	:= xFilial("ZCG")
		ZCG->ZCG_ENTIDA	:= "SZA"
		ZCG->ZCG_CODENT	:= _cCodEnt
		ZCG->ZCG_DATA		:= Date()
		ZCG->ZCG_HORA		:= Time()
		ZCG->ZCG_CODUSU	:= __cUserID
		ZCG->ZCG_OBSERV	:= Alltrim(_cObsSalv)
		MsUnlock()

		MessageBox("Observação Registrada com Sucesso.", "", 0)

	EndIf

	_lContinua := .T.

RETURN

Static Function EstiloBt(_cIcon)

	_cEstilo := "QPushButton {"
	_cEstilo += " border-style: outset;"
	_cEstilo += " border-width: 2px;"
	_cEstilo += " border: 1px solid #C0C0C0;"
	_cEstilo += " border-radius: 5px;"
	_cEstilo += " border-color: #C0C0C0;"
	_cEstilo += " font: bold 12px Arial;"
	_cEstilo += " padding: 6px;"
	If !Empty(_cIcon)
		_cEstilo += " background-image: url(rpo:"+ _cIcon +");background-repeat: none; margin: 2px;"
	Endif
	_cEstilo += " background-color: qradialgradient(cx: 0.5, cy: 0.5, radius: 2, fx: 0.5, fy: 1, stop: 0 rgba(127,157,183,255), stop: 0.2 rgba(127,157,183,144), stop: 0.4 rgba(127,157,183,32));
		_cEstilo += "}"
	_cEstilo += "QPushButton:pressed {"
	_cEstilo += " background-color: #E6E6F9;"
	_cEstilo += " border-style: inset;"
	_cEstilo += "}"

Return _cEstilo

//LIBERAR SEPARACAO//
Static Function LibSeparacao()
	fObserv(TRC1->IDSZA)
	//DLGA150()
	//oMarca:Refresh(.T.)
	//oTempMRK := oMarca
	DLGA150()
	RecLock("TRC1", .F.)
	TRC1->OK := ""
	MsUnlock()
	//oMarca := oTempMRK
	//oMarca:SetParam(bFiltro)
	//oMarca:Refresh(.T.)
	REFRESH(.F.)
RETURN

USER FUNCTION CheckVinc (cPedVinc)

	Local bRet := .T.
	Local cQryVinc := ""
	Local aPedVinc := {}

	If select("TEMPVINC") > 0
		dbSelectArea("TEMPVINC")
		dbCloseArea()
	EndIf

	// QUERY QUE FILTRA OS PEDIDOS VINCULADOS E SE ESTAO MARCADOS
	cQryVinc := "SELECT C5_NUM PEDIDO,C5_PEDORI PAI ,C9_OK OK"
	cQryVinc += " FROM "+RetSQLName("SC5") + " SC5"
	cQryVINC += " INNER JOIN "+RetSQLName("SC9") + " SC9 "+ "ON C9_PEDIDO = C5_NUM AND SC9.D_E_L_E_T_ <> '*'"
	cQryVinc += " WHERE C5_PEDORI = "+"'"+cPedVinc+"'"+" ORDER BY C5_NUM"
	TCQuery cQryVinc NEW ALIAS "TEMPVINC"

	DBSELECTAREA( "TEMPVINC" )

	While (TEMPVINC->(!Eof()))
		//Adiciona todos os numeros de pedidos em um array
		aadd(aPedVinc,TEMPVINC->PEDIDO + ", ")

		// Se não estiver marcado C9_OK (Padrão), altera para Falso
		IF (EMPTY(TEMPVINC->OK))
			bRet := .F.
		ENDIF
		TEMPVINC->(DbSkip())
	EndDo

	cDados := ArrTokStr(aPedVinc)

	// Se estiver Falso, retorna Falso e mostra os pedidos vinculados
	IF (bRet = .F.)
		MsgStop("Faturamento permitido somente para todos os pedidos vinculados: "+cDados)
		RETURN bRet
	ENDIF
	TEMPVINC->(DBCLOSEAREA())
RETURN bRet

USER FUNCTION VincSc5 (cPedVinc)

	Local bRet := .T.
	Local cQryVinc := ""
	Local aPedVinc := {}

	// QUERY QUE FILTRA OS PEDIDOS VINCULADOS E SE ESTAO MARCADOS
	cQryVinc := "SELECT C5_NUM PEDIDO,C5_PEDORI PAI "
	cQryVinc += " FROM "+RetSQLName("SC5") + " SC5"
	cQryVinc += " WHERE C5_PEDORI = "+"'"+cPedVinc+"'"+" ORDER BY C5_NUM"
	TCQuery cQryVinc NEW ALIAS "TEMPVINC"

	DBSELECTAREA( "TEMPVINC" )

	While (TEMPVINC->(!Eof()))
		//Adiciona todos os numeros de pedidos em um array
		aadd(aPedVinc,TEMPVINC->PEDIDO + ", ")
		TEMPVINC->(DbSkip())
	EndDo

	cDados := ArrTokStr(aPedVinc)
	MsgInfo("Pedidos Vinculados: "+cDados)
	TEMPVINC->(DBCLOSEAREA())

RETURN bRet

static Function fSaveParam()

	_Mv_par01 := MV_PAR01
	_Mv_par02 := MV_PAR02
	_Mv_par03 := MV_PAR03
	_Mv_par04 := MV_PAR04
	_Mv_par05 := MV_PAR05
	_Mv_par06 := MV_PAR06
	_Mv_par07 := MV_PAR07
	_Mv_par08 := MV_PAR08
	_Mv_par09 := MV_PAR09
	_Mv_par10 := MV_PAR10
	_Mv_par11 := MV_PAR11



return

static function fLoadParam()

	MV_PAR01 := _Mv_par01
	MV_PAR02 := _Mv_par02
	MV_PAR03 := _Mv_par03
	MV_PAR04 := _Mv_par04
	MV_PAR05 := _Mv_par05
	MV_PAR06 := _Mv_par06
	MV_PAR07 := _Mv_par07
	MV_PAR08 := _Mv_par08
	MV_PAR09 := _Mv_par09
	MV_PAR10 := _Mv_par10
	MV_PAR11 := _Mv_par11

return

STATIC FUNCTION Vinculo(cOrigem)

	Local lRet := .T.
	Local nRecNo := TRC1->(RECNO())
	Local cQryVinc := ""
	Local aPedVinc := {}
	Local i
	Local cMarca := oMarca:Mark()
	Local cTexto := ""

	If select("TEMPVINC") > 0
		dbSelectArea("TEMPVINC")
		dbCloseArea()
	EndIf

	// QUERY QUE FILTRA OS PEDIDOS VINCULADOS
	cQryVinc := "SELECT C5_NUM PEDIDO,C5_PEDORI PAI "
	cQryVinc += " FROM "+RetSQLName("SC5") + " SC5"
	cQryVINC += " INNER JOIN "+RetSQLName("SC9") + " SC9 "+ "ON C9_PEDIDO = C5_NUM AND SC9.D_E_L_E_T_ <> '*'"
	cQryVinc += " WHERE C5_PEDORI = "+"'"+cOrigem+"'"+" ORDER BY C5_NUM"
	TCQuery cQryVinc NEW ALIAS "TEMPVINC"

	DBSELECTAREA( "TEMPVINC" )

	While (TEMPVINC->(!Eof()))
		//Adiciona todos os numeros de pedidos em um array
		aadd(aPedVinc,TEMPVINC->PEDIDO)
		TEMPVINC->(DbSkip())
	EndDo

	TEMPVINC->(DBCLOSEAREA())

	FOR i := 1 TO Len(aPedVinc)
		dbSelectArea("TRC1")
		TRC1->(DbGoTop())
		While !TRC1->(EoF())
			IF ALLTRIM(TRC1->PEDIDO) = aPedVinc[i]
				IF!(oMarca:IsMark(cMarca))
					cTexto += aPedVinc[i]+" "
					lRet := .F.
				ENDIF
			ENDIF
			TRC1->(DbSkip())
		ENDDO
	NEXT i

	IF !(lRet)
		MSGSTOP("Existem Pedidos Vinculados não Selecionados: "+cTexto)
	ENDIF

	TRC1->(DBGOTO(nRecNo))

RETURN lRet
