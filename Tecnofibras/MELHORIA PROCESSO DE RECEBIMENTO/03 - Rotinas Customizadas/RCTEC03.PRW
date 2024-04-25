#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"
#include "FWMVCDef.ch"

// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTEC03 - CLASSIFICAR NOTAS PENDENTES 
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024


User Function RCTEC03()
	Local aSeek   := {}
	Private bFiltro	:= {|| REFRESH(.T.) } // Variavel para tecla F12
	Private oTela

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
	Aadd(aStru,{"CLASSI"   ,"C",1,0})

	//aAdd(aSeek,{"NUMERO"   ,{{"","C",009,0,"NUMERO"    ,"@!"}} } )

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
	//oTempTable:AddIndex("01", {"NUMERO"} )

	//Efetua a criação da tabela
	oTempTable:Create()

	DbSelectArea('TRC1')

	// Janela que mostra ao carregar
	Processa({||GeraDados()},'Gerando informacoes...')

	DbSelectArea('TRC1')

	TRC1->(DbGoTop()) // Primeiro registro da tabela
	If TRC1->(!Eof())
		oTela := FWMBrowse():New()
		oTela:SetDescription('Classificar Notas Pendentes')
		oTela:SetParam(bFiltro) // Padrão de chamada da tecla F12
		oTela:SetAlias("TRC1")
		//oMarca:SetFieldMark( "OK" )
		//oMarca:oBrowse:SetDBFFilter(.T.)
		//oMarca:oBrowse:SetUseFilter(.T.)
		//oMarca:oBrowse:SetFixedBrowse(.T.)
		oTela:SetWalkThru(.F.)
		oTela:SetAmbiente(.T.)
		oTela:SetTemporary()
		//oMarca:oBrowse:SetSeek(.T.,aSeek)
		//oMarca:oBrowse:SetFilterDefault("")

		bReceb := "" //Receber
		bObs := "" //Observações


		bReceb := {|| Recebimento() }
		bObs := {|| fObserv(TRC1->NUMERO) }

		// Botões da Tela e Outras Ações
		oTela:AddButton('Receber',bReceb)
		oTela:AddButton('Observações',bObs)

		//oMarca:ForceQuitButton(.T.)

		// Adicionando as Legendas
		oTela:AddLegend( "ALLTRIM(CLASSI) == 'Z'", "BR_AMARELO","Pendente Recebimento" )

		// Adicionando as colunas
		oColumn := FWBrwColumn():New()
		oColumn:SetData({||FILIAL})
		oColumn:SetTitle("Filial")
		oColumn:SetSize(2)
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||NUMERO})
		oColumn:SetTitle("Numero")
		oColumn:SetSize(9)
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||SERIE})
		oColumn:SetTitle("Serie")
		oColumn:SetSize(3)
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||FORNECEDOR})
		oColumn:SetTitle("Fornecedor")
		oColumn:SetSize(8)
		//oColumn:SetPicture("@E 999,999.99")
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||LOJA})
		oColumn:SetTitle("Loja")
		oColumn:SetSize(4)
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||CONDPAGTO})
		oColumn:SetTitle("Cond. Pagto")
		oColumn:SetSize(3)
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||DTEMISSAO})
		oColumn:SetTitle("DT Emissao")
		oColumn:SetSize(8)
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||DTDIGI})
		oColumn:SetTitle("DT Digitacao")
		oColumn:SetSize(8)
		oTela:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||CLASSI})
		oColumn:SetTitle("CLASSIFICADO")
		oColumn:SetSize(1)
		oTela:SetColumns({oColumn})

		oTela:Activate()
		//oMarca:oBrowse:Setfocus()
		//FINAL GERACAO DE TELA
	else
		MSGINFO("Nenhum registro encontrado.")
	endif

RETURN

STATIC FUNCTION Recebimento()

U_TESTANDO()
	
RETURN 


// FUNCAO PARA CHAMAR O REFRESH DA TELA E AS PERGUNTAS F12
STATIC FUNCTION REFRESH(bParam)

	//Pergunte("ITCDIG",bParam)

	Processa({||GeraDados()},'Gerando informacoes...')
	//oMarca:SetParam(bFiltro)
	oTela:SetInvert(.F.)
	oTela:Refresh(.T.)
	SetKey( VK_F12,{|| REFRESH(.T.) })
RETURN

// Função que chama os dados
STATIC FUNCTION GeraDados()

	Local cQuery    := ""

	cQuery := "SELECT F1_FILIAL FILIAL, F1_DOC NUMERO, F1_SERIE SERIE, F1_FORNECE FORNECEDOR, F1_LOJA LOJA, F1_COND CONDPAGTO, F1_EMISSAO DTEMISSAO, F1_DTDIGIT DTDIGI, F1_STATUS CLASSI "
	cQuery += "FROM "+RetSQLName("SF1") + " SF1 WHERE F1_STATUS = 'Z' AND F1_RECBMTO = ' ' AND SF1.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY F1_DOC "


	// Abre tabela TRC2 (Temporaria)
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
	//oTempTable:AddIndex("01", {"PEDIDO"} )

	//Efetua a criação da tabela
	oTempTable:Create()

	//DbSelectArea('TRC1')

	TCQuery cQuery NEW ALIAS "TRC2"

	dbSelectArea("TRC2")
	dbGoTop()
	Procregua(reccount())

	WHILE !(TRC2->(Eof()))

		Reclock("TRC1",.T.)
		TRC1->FILIAL := TRC2->FILIAL
		TRC1->NUMERO := TRC2->NUMERO
		TRC1->SERIE := TRC2->SERIE
		TRC1->FORNECEDOR := TRC2->FORNECEDOR
		TRC1->LOJA := TRC2->LOJA
		TRC1->CONDPAGTO := TRC2->CONDPAGTO
		TRC1->DTEMISSAO := STOD(TRC2->DTEMISSAO)
		TRC1->DTDIGI := STOD(TRC2->DTDIGI)
		TRC1->CLASSI := TRC2->CLASSI
		MsUnlock()

		TRC2->(dbSkip())
	END

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

