#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "TOPCONN.CH"
#Include 'FWMVCDef.ch'
#INCLUDE "FWPrintSetup.ch"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "RPTDEF.CH"

#define DS_MODALFRAME   128

Static __lChgX5Fil
Static __cSX5NUM
Static wkFolderMnt
Static __lForceClose

Static aFolder    := {}
Static lEAIFunOK  := (FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI") .And. Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0)
//Geral
Static nNrLimPrg := 0	//Limite de programas abertos

/*/{Protheus.doc} XAG0109A.PRW
Programa Monitor do Faturamento 
@author Geovani S Mauricio
@since Dez/2022
@version 1.0
@see (links_or_references)

Novos Parametros
MV_XROMAN  : identifica se executa ou n„o a rotina de Romaneio
MV_XBOLETO : identifica se executa ou n„o a rotina de Boleto
MV_XSRAUTO : identifica a serie a ser utilizada na geraÁ„o da nota fiscal.
MV_XNFEIMP : identifica se ir· gerar, transmitir e imprimir diretamente a DANFE

/*/
User FUNCTION XAG0109A()

	Local nLinT :=  05 
		
	Private oDlgm, oBrwmnt, aSize
	Private oSay1
	
	Private aStruSQL := {}
	Private aExceSQL := {}
	
	Private QRY
	Private aHead01 := {}, aCols01 := {}	//Cargas

	Private oSayChk1, oSayChk2, oSayChk3, oSayChk4, oSayChk5

	Private oCheck1_b, oCheck2_b, oCheck3_b, oCheck4_b, oCheck5_b, oCheck6_b
	Private oCheck1_o, oCheck2_o, oCheck3_o, oCheck4_o, oCheck5_o, oCheck6_o
	Private oCheck1_n, oCheck2_n, oCheck3_n, oCheck4_n, oCheck5_n, oCheck6_n

	Private _BmpYES := "yes_agricopel.PNG" 
	Private _BmpNO  := "no_agricopel.PNG"

	Private _oBtn1, _oBtn2, _oBtn3, _oBtn4, _oBtn5, _oBtn6  
	
	/* -- Variaveis Filtros ----------------------------------------- */
	Private cPedido:= SPACE(TAMSX3("C5_NUM")[1])
	Private _cNomeTmp, _cNomeTRBF, _nIndTRBF, _nIndCRT, cTabTmp, cAlTmp
	Private _cNameCHK  //, _nIndTRBC
	Private cIDTemp := CriaTrab(NIL, .F.)
	Private _DiasSC9 := 30
	
//======================================
// Gera as Perguntas
//======================================
	lRetorno := Pergunta()
	if !lRetorno
		Return
	EndIf
	_DiasSC9 := mv_par01
	
	/* -- Variaveis Filtros - FIM ------------------------------------- */

	AADD(aHead01,{ "Pedido"		,"PEDIDO"		,"C", tamSx3("C5_NUM")[1], 0,  "" } )
	AADD(aHead01,{ "Item"		,"C6ITEM"		,"N", 5, 0,  "" } )
	AADD(aHead01,{ "Produto"	,"C6PROD"		,"N", 5, 0,  "" } )
	AADD(aHead01,{ "Quantidade"	,"C6QTDE"		,"N", tamSx3("C9_QTDLIB")[1], tamSx3("C9_QTDLIB")[2], PesqPict("SC9","C9_QTDLIB") } )
	AADD(aHead01,{ "Cliente"	,"A1NOME"		,"N", tamSx3("A1_NOME")[1], 0 } )
	AADD(aHead01,{ "Nota Fiscal","NFISCAL"		,"C", Tamsx3("C9_NFISCAL")[1] , 0} )

	//Efetua a criacao do arquivo temporario
	STPROGCRIA()
	
	nNrLimPrg := 10

	//Resolucao de Tela 
	aSize		:= MsAdvSize( .F. )
	aObjects := {} 
	AAdd( aObjects, { 100, 35,  .t., .f., .t. } )
	AAdd( aObjects, { 100, 100 , .t., .t. } )
	AAdd( aObjects, { 100, 50 , .t., .f. } )

	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj  := MsObjSize( aInfo, aObjects) 

	// Cria Fonte para visualizaùùo 
	//Private oFont := TFont():New("Mono As",0,14,,.T.,,,,,.F.,.F.)
	Private oFont := TFont():New("Arial",0,14,,.F.)

	DEFINE MSDIALOG oDlgm TITLE "Monitor de Faturamento" PIXEL FROM If( FlatMode(), 0, aSize[7] ),0 TO aSize[6],aSize[5]  //STYLE nOR(WS_VISIBLE,WS_POPUP)
	
	oTimer := TTimer():New(30000, {|| stAtuBrw() }, oDlgm)
	oTimer:Activate()

	/* -- Layers -------------------------------------------------- */
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgm, .F., .T.)

	oFWLayer:AddLine('TOP', 10, .F.)
	oFWLayer:AddCollumn('FIL2', 100, .T., 'TOP') //Filtros
	oLayerT := oFWLayer:GetColPanel('FIL2', 'TOP')

	/* -- Filtros -------------------------------------------------- */

	oGrpFil := tGroup():New(005,005,060,445,"",oLayerT,CLR_HBLUE,CLR_WHITE,.T.)
	oGrpFil:Align := CONTROL_ALIGN_ALLCLIENT 

	oBtnAtu  := tButton():New(008, 035, "Atualizar ("+Str(_DiasSC9,3)+" dias) " , oGrpFil, { || stAtuBrw() },100,15,,,,.T.,,,,,,)

	oFWLayer:AddLine('CENTER', 90, .F.) 
	oFWLayer:AddCollumn('BRW2', 75, .T., 'CENTER') //Browse
	oLayerR := oFWLayer:GetColPanel('BRW2', 'CENTER')		

	/* -- Browses -------------------------------------------------- */

	oBrwmnt:=FWMBrowse():New()
	oBrwmnt:SetOwner(oLayerR)
	oBrwmnt:SetDescription('Pedidos Liberados')
	oBrwmnt:SetAlias('TRBF')
	oBrwmnt:SetTemporary(.T.) 
	oBrwmnt:SetFields(aHead01)
	
	oBrwmnt:bLDblClick := {|| stIniProc( TRBF->PEDIDO ) }

	oBrwmnt:bChange	:= {|| stChgCheck()}
	oBrwmnt:DisableDetails()

	oBrwmnt:AddButton("Iniciar Processo",{|| stIniProc( TRBF->PEDIDO ) },,1,,.F.)
	oBrwmnt:AddButton("Sair",{|| oDlgm:End() },,4,,.F.)
	oBrwmnt:SetProfileID("1")
	oBrwmnt:SetAmbiente(.F.)
	oBrwmnt:SetWalkthru(.F.)		
	oBrwmnt:SetFixedBrowse(.T.)		
	oBrwmnt:Activate()

	oFWLayer:AddCollumn('BRW_D', 25, .T., 'CENTER') //Browse
	oFWLayer:AddWindow('BRW_D', 'WIN_BRW_D', "Check-List", 100, .F., .T.,, 'CENTER',)

	oLayerD := oFWLayer:GetWinPanel('BRW_D', 'WIN_BRW_D', 'CENTER')		

	oScrLD := TScrollBox():New(oLayerD,0,0,30,345,.T.,.F.,.T.)
	oScrLD:Align := CONTROL_ALIGN_ALLCLIENT

	oSayChk1 	:= tSay():New(nLinT,008,{|| "1. Nota Fiscal: " },oScrLD,,oFont,,,,.T.,CLR_BLACK ,CLR_WHITE,380,9)
	oCheck1_b	:= TBitmap():New(nLinT,080,032,032,"FUNDODLG",,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck1_b:lAutoSize := .T.
	oCheck1_o	:= TBitmap():New((nLinT-4),080,032,032, Nil, _BmpYES , .T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck1_o:lAutoSize := .T.
	oCheck1_o:Hide()
	oCheck1_n	:= TBitmap():New(nLinT,080,032,032,Nil, _BmpNO,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck1_n:lAutoSize := .T.
	oCheck1_n:Hide()

	nLinT += 15
	oSayChk2	:= tSay():New(nLinT,008,{|| "2. Transmissao: " },oScrLD,,oFont,,,,.T.,CLR_BLACK ,CLR_WHITE,380,9)
	oCheck2_b	:= TBitmap():New(nLinT,080,032,032,"FUNDODLG",,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck2_b:lAutoSize := .T.
	oCheck2_o	:= TBitmap():New((nLinT-4),080,032,032,Nil, _BmpYES, .T., oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck2_o:lAutoSize := .T.
	oCheck2_o:Hide()
	oCheck2_n	:= TBitmap():New(nLinT,080,032,032,Nil, _BmpNO, .T., oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck2_n:lAutoSize := .T.
	oCheck2_n:Hide()

	nLinT += 15
	oSayChk3	:= tSay():New(nLinT,008,{|| "3. DANFE......: " },oScrLD,,oFont,,,,.T.,CLR_BLACK ,CLR_WHITE,380,9)
	oCheck3_b	:= TBitmap():New(nLinT,080,032,032,"FUNDODLG",,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck3_b:lAutoSize := .T.
	oCheck3_o	:= TBitmap():New((nLinT-4),080,032,032,Nil, _BmpYES, .T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck3_o:lAutoSize := .T.
	oCheck3_o:Hide()
	oCheck3_n	:= TBitmap():New(nLinT,080,032,032,Nil, _BmpNO, .T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck3_n:lAutoSize := .T.
	oCheck3_n:Hide()

	nLinT += 15
	oSayChk4	:= tSay():New(nLinT,008,{|| "4. Impressao Boleto: " },oScrLD,,oFont,,,,.T.,CLR_BLACK ,CLR_WHITE,380,9)
	oCheck4_b	:= TBitmap():New(nLinT,080,032,032,"FUNDODLG",,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck4_b:lAutoSize := .T.
	oCheck4_o	:= TBitmap():New((nLinT-4),080,032,032,Nil,_BmpYES,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck4_o:lAutoSize := .T.
	oCheck4_o:Hide()
	oCheck4_n	:= TBitmap():New(nLinT,080,032,032,Nil,_BmpNO,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck4_n:lAutoSize := .T.
	oCheck4_n:Hide()

	nLinT += 15
	oSayChk5 	:= tSay():New(nLinT,008,{|| "5. Romaneio: " },oScrLD,,oFont,,,,.T.,CLR_BLACK ,CLR_WHITE,380,9)
	oCheck5_b	:= TBitmap():New(nLinT,080,032,032,"FUNDODLG",,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck5_b:lAutoSize := .T.
	oCheck5_o	:= TBitmap():New((nLinT-4),080,032,032,Nil, _BmpYES,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck5_o:lAutoSize := .T.
	oCheck5_o:Hide()
	oCheck5_n	:= TBitmap():New(nLinT,080,032,032,Nil, _BmpNO,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck5_n:lAutoSize := .T.
	oCheck5_n:Hide()

	nLinT += 15
	oSayChk6 	:= tSay():New(nLinT,008,{|| "6. Etiqueta: " },oScrLD,,oFont,,,,.T.,CLR_BLACK ,CLR_WHITE,380,9)
	oCheck6_b	:= TBitmap():New(nLinT,080,032,032,"FUNDODLG",,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck6_b:lAutoSize := .T.
	oCheck6_o	:= TBitmap():New((nLinT-4),080,032,032,Nil, _BmpYES,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck6_o:lAutoSize := .T.
	oCheck6_o:Hide()
	oCheck6_n	:= TBitmap():New(nLinT,080,032,032,Nil, _BmpNO,.T.,oScrLD,,,.F.,.F.,,,.F.,,.T.,,.F.)
	oCheck6_n:lAutoSize := .T.
	oCheck6_n:Hide()

	stAtuBrw()

	ACTIVATE DIALOG oDlgm CENTERED

	If ( Select('TRBF') <> 0 )
		TRBF->(dbCloseArea())
	Endif
	
	If (Select(cTabTmp) <> 0)
		(cTabTmp)->(DbCloseArea())
	Endif

return                                


/*
+--------------------+-----------------------------------------------------------+
!Descricao				! Funcao para Chamar Rotina com regua de processamento		! 
+--------------------+-----------------------------------------------------------+
!Autor             	! 																	!
+--------------------+-----------------------------------------------------------+
!Data de Criacao   	! 21/09/2015														!
+--------------------+-----------------------------------------------------------+
*/
Static Function stAtuBrw()

	Local lAchou := .t. 
	
	oProcBrw := MsNewProcess():New({|| STINSDATA(lAchou)}, "Aguarde...", "Processando Pedidos Liberados...")
	oProcBrw:Activate()

	if lAchou 
		TRBF->(dbSetOrder(_nIndTRBF))
		TRBF->(dbGoTop())
		oBrwmnt:UpdateBrowse()		
		nLinT := 05
		iif('10' $ TRBF->TCHECK,(oCheck1_b:Hide(),oCheck1_o:Show(),oCheck1_n:Hide()),(oCheck1_b:Hide(),oCheck1_o:Hide(),oCheck1_n:Show()))
		iif('15' $ TRBF->TCHECK,(oCheck2_b:Hide(),oCheck2_o:Show(),oCheck2_n:Hide()),(oCheck2_b:Hide(),oCheck2_o:Hide(),oCheck2_n:Show()))
		iif('20' $ TRBF->TCHECK,(oCheck3_b:Hide(),oCheck3_o:Show(),oCheck3_n:Hide()),(oCheck3_b:Hide(),oCheck3_o:Hide(),oCheck3_n:Show()))
		iif('25' $ TRBF->TCHECK,(oCheck4_b:Hide(),oCheck4_o:Show(),oCheck4_n:Hide()),(oCheck4_b:Hide(),oCheck4_o:Hide(),oCheck4_n:Show()))
		iif('30' $ TRBF->TCHECK,(oCheck5_b:Hide(),oCheck5_o:Show(),oCheck5_n:Hide()),(oCheck5_b:Hide(),oCheck5_o:Hide(),oCheck5_n:Show()))
		iif('35' $ TRBF->TCHECK,(oCheck6_b:Hide(),oCheck6_o:Show(),oCheck6_n:Hide()),(oCheck6_b:Hide(),oCheck6_o:Hide(),oCheck6_n:Show()))
	Else 
		MsgAlert('Nao possui PEDIDOS LIBERADOS para monitorar.', 'ATENCAO')
	Endif 
	If ( Select('QRY') <> 0 )
		QRY->(dbCloseArea())
	Endif

Return

//-------------------------------------------
// Atualizar browse com os pedidos liberados
//-------------------------------------------
Static Function STINSDATA(lAchou)

   	Local _DtSC9 := (dDatabase - _DiasSC9)
	
	if ( Select('TRBF') == 0 )
		stProgCria()
	else
		TRBF->(dbGotop())
		if TRBF->(!eof())
			If ( Select('TRBF') <> 0 )
				TRBF->(dbCloseArea())
			Endif
			stProgCria()
		endif
	endif
	//apagar registros
	TCSqlExec("DELETE FROM " + _cNomeTRBF )

	oProcBrw:setRegua1(1)
	oProcBrw:incRegua1("Preparando a query das informacoes...")
	oProcBrw:setRegua2(1)
	oProcBrw:incRegua2("Preparando a query das informacoes...")
	If ( Select('QRY') <> 0 )
		QRY->(dbCloseArea())
	Endif
	_cQry := "SELECT C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_QTDLIB, C9_NFISCAL, C9_SERIENF, C9_CLIENTE, C9_LOJA, "
	_cQry += " A1_NOME "
	_cQry += "From " + RetSqlName("SC9") + " SC9 "
	_cQry += "Inner Join " + RetSqlName("SC5") + " SC5 on SC5.D_E_L_E_T_ = '' AND C5_NUM = C9_PEDIDO AND C5_FILIAL = '"+xFilial("SC5")+"' " "
	_cQry += "Inner Join " + RetSqlName("SA1") + " SA1 on SA1.D_E_L_E_T_ = '' AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND A1_FILIAL = '"+xFilial("SA1")+"' " "
	_cQry += "Where SC9.D_E_L_E_T_ = '' and SC9.C9_FILIAL = '"+xFilial("SC9")+"' "
	_cQry += "AND (SC9.C9_BLEST IN ('','10') AND SC9.C9_BLCRED IN ('','10')) " 
	_cQry += "AND SC9.C9_DATALIB >= '"+dTos(_DtSC9)+"' "
	_cQry += "AND SC5.C5_TIPO = 'N' "
	_cQry := ChangeQuery(_cQry)
	TCQuery _cQry NEW ALIAS "QRY"
	qry->(dbgotop())

	oProcBrw:incRegua1("Filtrando Pedidos Liberados...")

	//alimentar o arquivo temporario
	lAchou := .f.
	QRY->(dbgotop())
	While QRY->(!EOF())

		oProcBrw:incRegua2("Gravando dados temporarios...")

		lAchou := .t.

		//Verifica se nota gerada para a carga
		_cChk10 := ''		// Nota Fiscal
		_cChk15 := ''		// Transmissao
		_cChk20 := ''		// Impressùo
		_cChk25 := ''		// Boleto
		_cChk30 := ''		// Romaneio
		_cChk35 := ''		// Etiqueta
		
		// Verifica geraùùo de nota fiscal
		sf2->(dbsetorder(1))
		if sf2->(dbseek(xFilial("SF2")+qry->C9_NFISCAL+qry->C9_SERIENF))
			_cChk10 += '10|'
			if !empty(SF2->F2_CHVNFE)
				if !('15' $ _cChk15)
					_cChk15 += '15|'
				endif 
				if SF2->F2_ZIMP == 'S'
					if !('20' $ _cChk20)
						_cChk20 += '20|'
					endif 
					// Verifica emissao Boleto
					SE1->(DBSETORDER(1))
					SE1->(DBSEEK(xFILIAL('SE1')+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC))
					While !SE1->(eof()) .and. xFilial('SE1') == SF2->F2_FILIAL ;
						.and. SF2->F2_CLIENTE == SE1->E1_CLIENTE .and. SF2->F2_LOJA == SE1->E1_LOJA ;
						.and. SF2->F2_SERIE == SE1->E1_PREFIXO .and. SF2->F2_DOC == SE1->E1_NUM
						if !EMPTY(SE1->E1_NUMBCO)
							if !('25' $ _cChk25)
								_cChk25 += '25|'
							endif 
						endif
						SE1->(DBSKIP())
					End 
				
					// Verifica se possui Romaneio
					if !Empty(sf2->f2_romane)
						if !('30' $ _cChk30)
							_cChk30 += '30|'
						endif 
					endif
				endif
			endif 
		endif 
		
		if Empty(_cChk10) .or. Empty(_cChk15) .or. Empty(_cChk20) .or. Empty(_cChk25) .or. Empty(_cChk30)  
			recLock('TRBF', .T.)
			TRBF->PEDIDO   := QRY->C9_PEDIDO
			TRBF->C6ITEM   := QRY->C9_ITEM
			TRBF->C6PROD   := QRY->C9_PRODUTO
			TRBF->C6QTDE   := QRY->C9_QTDLIB
			TRBF->A1NOME   := Alltrim(QRY->A1_NOME) 
			TRBF->NFISCAL  := QRY->C9_NFISCAL
			TRBF->SERIE    := QRY->C9_SERIENF
			TRBF->CLIENTE  := QRY->C9_CLIENTE
			TRBF->LOJA     := QRY->C9_LOJA
			TRBF->TCHECK   := alltrim(_cChk10 + _cChk15 + _cChk20 + _cChk25 + _cChk30 + _cChk35  )
			TRBF->(msUnlock())
		endif 
		QRY->(dbskip())
	End

Return lAchou

/*
+--------------------+-----------------------------------------------------------+
!Descricao				! Funcao para criar fisicamente o arquivo temporario			! 
+--------------------+-----------------------------------------------------------+
!Autor             	! 																	!
+--------------------+-----------------------------------------------------------+
!Data de Criacao   	! 11/10/2014														!
+--------------------+-----------------------------------------------------------+
*/
Static Function STPROGCRIA()

	aStruSQL := {}
	AADD(aStruSQL,{"PEDIDO"		,"C", TamSx3("C5_NUM")[1]    , TamSx3("C5_NUM")[2] })
	AADD(aStruSQL,{"C6ITEM"		,"C", TamSx3("C6_ITEM")[1]   , TamSx3("C6_ITEM")[2] })
	AADD(aStruSQL,{"C6PROD"		,"C", TamSx3("C6_PRODUTO")[1], TamSx3("C6_PRODUTO")[2] })
	AADD(aStruSQL,{"C6QTDE"		,"N", TamSx3("C6_QTDVEN")[1] , TamSx3("C6_QTDVEN")[2] })
	AADD(aStruSQL,{"A1NOME"		,"C", 35 , 0 })
	AADD(aStruSQL,{"NFISCAL"    ,"C", TamSx3("F2_DOC")[1]     , TamSx3("F2_DOC")[2] })
	AADD(aStruSQL,{"SERIE"      ,"C", TamSx3("F2_SERIE")[1]   , TamSx3("F2_SERIE")[2] })
	AADD(aStruSQL,{"CLIENTE"    ,"C", TamSx3("F2_CLIENTE")[1] , TamSx3("F2_CLIENTE")[2]})
	AADD(aStruSQL,{"LOJA"       ,"C", TamSx3("F2_LOJA")[1]    , TamSx3("F2_LOJA")[2]})

	AADD(aStruSQL,{"TCHECK"		,"C", 120 , 0 })

	If ( Select('TRBF') <> 0 )
		dbSelectArea ('TRBF')
		dbCloseArea()
	Endif
	
	_cNomeTRBF := CriaTrab(aStruSQL,.T.)
	dbUseArea(.T.,__LOCALDRIVER,_cNomeTRBF,'TRBF',.T.,.F.)

	//Indices
	cArqInd1 := CriaTrab(nil,.F.)
	indregua('TRBF',cArqInd1,"PEDIDO+C6ITEM",,"","Selecionando os registros...")
	dbClearIndex()

	dbSelectArea("TRBF")
	dbSetIndex(cArqInd1+OrdBagExt())

return

Static Function stChgCheck()

	nRegT := TRBF->(Recno())
	TRBF->(dbGoTop())
	if TRBF->(!eof())

		TRBF->(dbGoto(nRegT))

			iif('10' $ TRBF->TCHECK,(oCheck1_b:Hide(),oCheck1_o:Show(),oCheck1_n:Hide()),(oCheck1_b:Hide(),oCheck1_o:Hide(),oCheck1_n:Show()))
			iif('15' $ TRBF->TCHECK,(oCheck2_b:Hide(),oCheck2_o:Show(),oCheck2_n:Hide()),(oCheck2_b:Hide(),oCheck2_o:Hide(),oCheck2_n:Show()))
			iif('20' $ TRBF->TCHECK,(oCheck3_b:Hide(),oCheck3_o:Show(),oCheck3_n:Hide()),(oCheck3_b:Hide(),oCheck3_o:Hide(),oCheck3_n:Show()))
			iif('25' $ TRBF->TCHECK,(oCheck4_b:Hide(),oCheck4_o:Show(),oCheck4_n:Hide()),(oCheck4_b:Hide(),oCheck4_o:Hide(),oCheck4_n:Show()))
			iif('30' $ TRBF->TCHECK,(oCheck5_b:Hide(),oCheck5_o:Show(),oCheck5_n:Hide()),(oCheck5_b:Hide(),oCheck5_o:Hide(),oCheck5_n:Show()))
			iif('35' $ TRBF->TCHECK,(oCheck6_b:Hide(),oCheck6_o:Show(),oCheck6_n:Hide()),(oCheck6_b:Hide(),oCheck6_o:Hide(),oCheck6_n:Show()))
	endif

Return

/*
Tela de Inicio do Processo 
*/
Static Function stIniProc( _xPedido )

	oBrwmnt:Refresh()

	STATIC oDlgS

	Private _cNotaFiscal := Space(09)    // Nota fiscal gerada para o pedido

	iif('10' $ TRBF->TCHECK,(lCheck1_o:=.T.,lCheck1_n:=.F.),(lCheck1_o:=.F.,lCheck1_n:=.T.))
	iif('15' $ TRBF->TCHECK,(lCheck2_o:=.T.,lCheck2_n:=.F.),(lCheck2_o:=.F.,lCheck2_n:=.T.))
	iif('20' $ TRBF->TCHECK,(lCheck3_o:=.T.,lCheck3_n:=.F.),(lCheck3_o:=.F.,lCheck3_n:=.T.))
	iif('25' $ TRBF->TCHECK,(lCheck4_o:=.T.,lCheck4_n:=.F.),(lCheck4_o:=.F.,lCheck4_n:=.T.))
	iif('30' $ TRBF->TCHECK,(lCheck5_o:=.T.,lCheck5_n:=.F.),(lCheck5_o:=.F.,lCheck5_n:=.T.))
	iif('35' $ TRBF->TCHECK,(lCheck6_o:=.T.,lCheck6_n:=.F.),(lCheck6_o:=.F.,lCheck6_n:=.T.))

	nLin	:= 08

	aSize	:= MsAdvSize(.F., .F., aSize[6] + 50)

	DEFINE MSDIALOG oDlgS FROM aSize[7], 0 TO aSize[6], aSize[5] TITLE "Monitor Processos" Of oMainWnd PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

	oFWLayerP := FWLayer():New()
	oFWLayerP:Init(oDlgS, .F., .T.)

	//1a. coluna
	oFWLayerP:AddCollumn('BRW_C', 15, .F., 'CENTER') //Browse
	oFWLayerP:SetColSplit('BRW_C',CONTROL_ALIGN_RIGHT,'CENTER',{||})
	oFWLayerP:AddWindow('BRW_C', 'WIN_BRW_C', "Pedido: [ " + _xPedido + " ]", 100, .F., .T.,, 'CENTER',)
	oLayerC := oFWLayerP:GetWinPanel('BRW_C', 'WIN_BRW_C', 'CENTER')

//	oScrLC := TScrollBox():New(oLayerC,0,0,30,345,.T.,.F.,.T.)
	oScrLC := TScrollBox():New(oLayerC,0,0,80,200,.T.,.F.,.T.)

	oScrLC:Align := CONTROL_ALIGN_ALLCLIENT

	//2a. coluna                  85
	oFWLayerP:AddCollumn('BRW_W',85, .F., 'CENTER') //Browse
//	oLayerD := tPanel():New(0, 0, "", oFWLayerP:GetColPanel('BRW_W', 'CENTER'),,,,, RGB(239,243,247), 000, 015)
	oLayerD := tPanel():New(0, 0, "", oFWLayerP:GetColPanel('BRW_W', 'CENTER'),,,,, RGB(239,243,247), 000, 015)
	oLayerD:Align := CONTROL_ALIGN_ALLCLIENT

	// Cria Folder da WorkSpace
//	wkFolderMnt := TWorkspaceFolder():New( oLayerD, 000, 000, 500, 500 )
	wkFolderMnt := TWorkspaceFolder():New( oLayerD, 000, 000, 500, 500 )
	wkFolderMnt:Align := CONTROL_ALIGN_ALLCLIENT
	__lForceClose := .F.

	//Monta tela com o check list do pedido
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial('SC5') + _xPedido))
	THButton():New(nLin, 002, "Pedido: " + sc5->c5_num, oScrLC, {|| }, 75, 09,oFont, )				
	// Geraùùo de NF
	nLin += 15
	if Empty(trbf->nfiscal)
		THButton():New(nLin, 002, "1. Gerar NF: "                , oScrLC, {|| fGeraDoc('10')}    , 75, 09,oFont, "Executar Tarefa")
	else
		THButton():New(nLin, 002, "1. Nota Fiscal "+trbf->nfiscal, oScrLC, /*{|| fGeraDoc('10')}*/, 75, 09,oFont, "Executar Tarefa")
	endif 
	_oCheck1_o	:= TBitmap():New((nLin-4),075,024,024, Nil, _BmpYES ,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck1_o:lAutoSize := .T.
	_oCheck1_n	:= TBitmap():New((nLin-1),075,024,024, Nil, _BmpNO,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck1_n:lAutoSize := .T.
	iif(lCheck1_o,_oCheck1_o:Show(),_oCheck1_o:Hide())
	iif(lCheck1_n,_oCheck1_n:Show(),_oCheck1_n:Hide())
	// Transmissao SEFAZ
	nLin += 12
	THButton():New(nLin, 002, "2. Transmissao SEFAZ: ", oScrLC, {||fTransmite('15') }, 75, 09,oFont, "Executar Tarefa")
	_oCheck2_o	:= TBitmap():New((nLin-4),075,024,024, Nil, _BmpYES,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck2_o:lAutoSize := .T.
	_oCheck2_n	:= TBitmap():New((nLin-1),075,020,020, Nil, _BmpNO,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck2_n:lAutoSize := .T.
	iif(lCheck2_o,_oCheck2_o:Show(),_oCheck2_o:Hide())
	iif(lCheck2_n,_oCheck2_n:Show(),_oCheck2_n:Hide())
	// Impressùo DANFE
	nLin += 12
	THButton():New(nLin, 002, "3. Impressao DANFE : ", oScrLC, {|| fImprDANFE('20')}, 75, 09,oFont, "Executar Tarefa")
	_oCheck3_o	:= TBitmap():New((nLin-4),075,024,024, Nil, _BmpYES,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck3_o:lAutoSize := .T.
	_oCheck3_n	:= TBitmap():New((nLin-1),075,020,020,Nil, _BmpNO, .T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck3_n:lAutoSize := .T.
	iif(lCheck3_o,_oCheck3_o:Show(),_oCheck3_o:Hide())
	iif(lCheck3_n,_oCheck3_n:Show(),_oCheck3_n:Hide())
	// Impressùo Boleto
	nLin += 12
	THButton():New(nLin, 002, "4. Impressao BOLETO : ", oScrLC, {|| fImprBoleto('25')}, 75, 09,oFont, "Executar Tarefa")
	_oCheck4_o	:= TBitmap():New((nLin-4),075,024,024, Nil, _BmpYES,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck4_o:lAutoSize := .T.
	_oCheck4_n	:= TBitmap():New((nLin-1),075,020,020,Nil, _BmpNO, .T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck4_n:lAutoSize := .T.
	iif(lCheck4_o,_oCheck4_o:Show(),_oCheck4_o:Hide())
	iif(lCheck4_n,_oCheck4_n:Show(),_oCheck4_n:Hide())
	// Impressao Romaneio
	nLin += 12
	THButton():New(nLin, 002, "5. Romaneio: ", oScrLC, {|| fImprRomaneio('30')}, 75, 09,oFont, "Executar Tarefa")
	_oCheck5_o	:= TBitmap():New((nLin-4),075,024,024, Nil, _BmpYES,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck5_o:lAutoSize := .T.
	_oCheck5_n	:= TBitmap():New((nLin-1),075,020,020,Nil, _BmpNO, .T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck5_n:lAutoSize := .T.
	iif(lCheck5_o,_oCheck5_o:Show(),_oCheck5_o:Hide())
	iif(lCheck5_n,_oCheck5_n:Show(),_oCheck5_n:Hide())
	// Impressao Etiquetas
	nLin += 12
	THButton():New(nLin, 002, "6. Etiquetas: ", oScrLC, {|| fImprEtiqueta('35')}, 75, 09,oFont, "Executar Tarefa")
	_oCheck6_o	:= TBitmap():New((nLin-4),075,024,024, Nil, _BmpYES,.T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck6_o:lAutoSize := .T.
	_oCheck6_n	:= TBitmap():New((nLin-1),075,020,020,Nil, _BmpNO, .T.,oScrLC,,,.F.,.F.,,,.F.,,.T.,,.F.)
	_oCheck6_n:lAutoSize := .T.
	iif(lCheck6_o,_oCheck6_o:Show(),_oCheck6_o:Hide())
	iif(lCheck6_n,_oCheck6_n:Show(),_oCheck6_n:Hide())
	// Retornar
	nLin += 18
	THButton():New(nLin, 000, "  7. Retornar:", oScrLC, {|| iif(CloseAll(),(oDlgS:End()),1==1)}, 60, 10,oFont, "Executar Tarefa")

	ACTIVATE MSDIALOG oDlgS CENTERED

Return

//----------------------------
User Function stForceClose()
	__lForceClose := .T.
return 

//----------------------------
Static Function Closeall()
	Local nI
	Local aProcess
	Local lSair := .F.

	if MsgYesNo("Deseja realmente sair?","")

		//Sleep(5000)
		FwMsgRun(, {|| /*Sleep(5000)*/}, "Fechando Programa", "Aguarde " + cUserName + "...")
		
		aProcess := PtGetSessions()
		
		if len(aProcess)>1
			for nI := 1 to len(aProcess)
				//PtRuninSession(aProcess[nI],"ForceClose()")
				PtRuninSession(aProcess[nI],"u_stForceClose()")
				PtKillSession(aProcess[nI])
				//sleep(100)
			next
		endif

		lSair := .T.

	endif

Return( lSair )

//-----------------------------------
// Gerar nota fiscal
//-----------------------------------
Static Function fGeraDoc( cxCheck  )

	Private oProcDoc

	oProcDoc := MsNewProcess():New({|| U_GERANOTA()}, "Aguarde...", "Processando Documento de Saida/Expedicao ...")
	oProcDoc:Activate()

	_xPedido := trbf->pedido 
	_oCheck1_n:Hide()
	_oCheck1_o:Show()
	// STATUS 2 - Processamento efetuado com sucesso
	PutGlbValue("G_" + _xPedido + "_" + cxCheck,"2")

	if !Empty(trbf->nfiscal)
// Executa rotina de Transmissao
		fTransmite('15')
		_cDoc  := trbf->nfiscal
		_cSerie:= trbf->serie
		_cCliente := trbf->cliente 
		_cLojam   := trbf->loja 
		SF2->(dbSetOrder(1))//->F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->(dbSeek(xFilial("SF2") + _cDoc + _cSerie + _cCliente + _cLojam)) 
			if !Empty(sf2->f2_chvnfe)
				fImprDanfe('20')
			endif
		Endif 
	Else 
		MsgAlert('NOTA FISCAL nao GERADA. Verifique !!!', 'ATENCAO')
	Endif 

Return 

//=============================================
// Executa a geraùùo da nota fiscal
//=============================================
User Function GeraNota()
 
    Local aPvlDocS := {}
    Local nPrcVen := 0
    Local cC5Num  := trbf->pedido
    Local cSerie  := GETMV( 'MV_XSRAUTO')  //"1"
    Local cEmbExp := ""
    Local cDoc    := ""
	Local aNotas  := {}
	Local _i

	if Empty(cSerie)
		MSGALERT( 'SERIE NOTA FISCAL NAO DEFINIDA NO PARAMETRO MV_XSRAUTO. VERIFIQUE !!!', "ERRO" )
		RETURN
	endif 
	
	SC5->(DbSetOrder(1))
    SC5->(MsSeek(xFilial("SC5")+cC5Num))
 
    SC6->(dbSetOrder(1))
    SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
	nReg := 0
	SC6->(dbgotop())
	While !SC6->(eof()) .and. Alltrim(SC6->C6_NUM) == Alltrim(SC5->C5_NUM)
		nReg += 1
		SC6->(dbskip())
	End 
	SC6->(dbgotop())
	
	oProcDoc:setRegua1(1)
	oProcDoc:incRegua1("Preparando geracao Documento...")

    //ù necessùrio carregar o grupo de perguntas MT460A, se nùo serù executado com os valores default.
    if cFilAnt $ ("03_11_15_16_17")
		Pergunte("MT460A",.T.)
	else
		Pergunte("MT460A",.F.)
	endif 
	
    // Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saùda
    SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
	While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM
 
	    oProcDoc:incRegua2("Preparando as informacoes para Geracao Nota Fiscal...")

	    SC9->(DbSetOrder(1))
        SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM
 
        SE4->(DbSetOrder(1))
        SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO
 
        SB1->(DbSetOrder(1))
        SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO
 
        SB2->(DbSetOrder(1))
        SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL
 
        SF4->(DbSetOrder(1))
        SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES
 
        nPrcVen := SC9->C9_PRCVEN
        If ( SC5->C5_MOEDA <> 1 )
            nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
        EndIf
 
        If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == ""
            AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
                            SC9->C9_ITEM,;
                            SC9->C9_SEQUEN,;
                            SC9->C9_QTDLIB,;
                            nPrcVen,;
                            SC9->C9_PRODUTO,;
                            .F.,;
                            SC9->(RecNo()),;
                            SC5->(RecNo()),;
                            SC6->(RecNo()),;
                            SE4->(RecNo()),;
                            SB1->(RecNo()),;
                            SB2->(RecNo()),;
                            SF4->(RecNo())})
        EndIf
 
        SC6->(DbSkip())
    EndDo
 
	oProcDoc:incRegua2("Gerando Nota Fiscal...")

	Begin Transaction

    	SetFunName("MATA461")
     
    	cDoc := MaPvlNfs(  /*aPvlNfs*/         aPvlDocS,;  // 01 - Array com os itens a serem gerados
                       /*cSerieNFS*/       cSerie,;    // 02 - Serie da Nota Fiscal
                       /*lMostraCtb*/      .F.,;       // 03 - Mostra Lanùamento Contùbil
                       /*lAglutCtb*/       .F.,;       // 04 - Aglutina Lanùamento Contùbil
                       /*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
                       /*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
                       /*lReajuste*/       .F.,;       // 07 - Reajuste de preùo na Nota Fiscal
                       /*nCalAcrs*/        0,;         // 08 - Tipo de Acrùscimo Financeiro
                       /*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
                       /*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarraùùo Cliente x Produto
                       /*lECF*/            .F.,;       // 11 - Cupom Fiscal
                       /*cEmbExp*/         cEmbExp,;   // 12 - Nùmero do Embarque de Exportaùùo
                       /*bAtuFin*/         {||},;      // 13 - Bloco de Cùdigo para complemento de atualizaùùo dos tùtulos financeiros
                       /*bAtuPGerNF*/      {||},;      // 14 - Bloco de Cùdigo para complemento de atualizaùùo dos dados apùs a geraùùo da Nota Fiscal
                       /*bAtuPvl*/         {||},;      // 15 - Bloco de Cùdigo de atualizaùùo do Pedido de Venda antes da geraùùo da Nota Fiscal
                       /*bFatSE1*/         {|| .T. },; // 16 - Bloco de Cùdigo para indicar se o valor do Titulo a Receber serù gravado no campo F2_VALFAT quando o parùmetro MV_TMSMFAT estiver com o valor igual a "2".
                       /*dDataMoe*/        dDatabase,; // 17 - Data da cotaùùo para conversùo dos valores da Moeda do Pedido de Venda para a Moeda Forte
                       /*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais
     
    	If !Empty(cDoc)
        	aAdd(aNotas,{cSerie,cDoc})
    	EndIf

	End Transaction
   
	if Len(aNotas) > 0
		For _i := 1 to Len(aNotas)
			Reclock("TRBF",.f.)
			TRBF->NFISCAL := aNotas[_i][2]  // numero docto
			TRBF->SERIE   := aNotas[_i][1]  // Serie Docto
			TRBF->TCHECK  := '10|' 
			MsUnlock("TRBF")
			MsgAlert("Documento de Saida: " + aNotas[_i][1] + "-" + aNotas[_i][2] + ", gerado com sucesso!!!","AVISO")
		Next
	else
		MsgAlert('Nota Fiscal NAO GERADA. Verifique !!!', 'ATENCAO')	
	endif 

RETURN

//-----------------------------------
// Transmitir nota fiscal
//-----------------------------------
static function fTransmite( cxCheck )

	_cDoc  := trbf->nfiscal
	_cSerie:= trbf->serie
	_cCliente := trbf->cliente 
	_cLojam   := trbf->loja 
	SF2->(dbSetOrder(1))//->F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(dbSeek(xFilial("SF2") + _cDoc + _cSerie + _cCliente + _cLojam)) 
		if !Empty(sf2->f2_chvnfe)
			MsgAlert('NOTA FISCAL ja TRANSMITIDA. Verifique !!!', 'ATENCAO')
		else 
			Processa({|lEnd| u_fGeraDANFE() }, "Aguarde...","Preparando dados para transmissao da nota.",.F.)
			if !Empty(sf2->f2_chvnfe)
				MsgAlert('Nota Fiscal transmitida com sucesso !!!','AVISO')
				_xPedido := trbf->pedido 
				_oCheck1_n:Hide()
				_oCheck1_o:Show()
	// STATUS 2 - Processamento efetuado com sucesso
				PutGlbValue("G_" + _xPedido + "_" + cxCheck,"2")
				stFreeObj( trbf->pedido )
			else
				MsgAlert('Transmissao da Nota Fiscal com ERRO !!!','ATENCAO')
			endif 
		endif 
	Else 
		MsgAlert('NOTA FISCAL nao GERADA. Verifique !!!', 'ATENCAO')
	Endif 

Return 

/* Funcao para checar as execucoes dos sub-processos e atualizar a tela */
Static Function stFreeObj( _xPedido )

	//Geracao de Notas 
	if !Empty(trbf->nfiscal)
		cGlbCont :=  GetGlbValue('G_' + _xPedido + '_' + '10')
		if (cGlbCont == '2' .or. cGlbCont == '4')
			ClearGlbValue('G_' + _xPedido + '_' + '10')
			if cGlbCont == '2'
				_oCheck1_n:Hide()
				_oCheck1_o:Show()
				//_oBtn2:Hide()
			endif
		endif
	endif
	
	//Transmissao de notas
	cGlbCont :=  GetGlbValue('G_' + _xPedido + '_' + '15')
	if (cGlbCont == '2' .or. cGlbCont == '4')
		ClearGlbValue('G_' + _xPedido + '_' + '15')
		if cGlbCont == '2'
			_oCheck2_n:Hide()
			_oCheck2_o:Show()
		endif
	endif
	
	//Emissao da DANFE
	cGlbCont :=  GetGlbValue('G_' + _xPedido + '_' + '20')
	if (cGlbCont == '2' .or. cGlbCont == '4')
		ClearGlbValue('G_' + _xPedido + '_' + '20')
		if cGlbCont == '2'
			_oCheck3_n:Hide()
			_oCheck3_o:Show()
		endif
	endif

	//Emissao Boletos
	cGlbCont :=  GetGlbValue('G_' + _xPedido + '_' + '25')
	if (cGlbCont == '2' .or. cGlbCont == '4')
		ClearGlbValue('G_' + _xPedido + '_' + '25')
		if cGlbCont == '2'
			_oCheck4_n:Hide()
			_oCheck4_o:Show()
		endif
	endif

	//Emissao Romaneio
	cGlbCont :=  GetGlbValue('G_' + _xPedido + '_' + '30')
	if (cGlbCont == '2' .or. cGlbCont == '4')
		ClearGlbValue('G_' + _xPedido + '_' + '30')
		if cGlbCont == '2'
			_oCheck5_n:Hide()
			_oCheck5_o:Show()
		endif
	endif

return

//-----------------------------------
// 20 - Impresao DANFE
//-----------------------------------
Static Function fImprDANFE(cxCheck)
	Local _i

//  Acha nota fiscal
	_cNota := trbf->nfiscal
	_cSerie:= trbf->serie

	aStNotas := {}
	SF2->(dbsetorder(1))
	SF2->(dbSeek(xFilial('SF2') + _cNota + _cSerie))
	While SF2->(!eof()) .and. SF2->F2_FILIAL == xFilial("SF2") .and. Alltrim(sf2->f2_doc) == Alltrim(_cNota) .and. Alltrim(sf2->f2_serie) == Alltrim(_cSerie)
		if !Empty(SF2->F2_CHVNFE)
			aadd( aStNotas, {SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_EMISSAO, SF2->( Recno() )} )		
		endif
		SF2->(dbSkip())
	End

	if empty(len(aStNotas))

		MsgAlert('Este PEDIDO nao possui DANFE transmitida. Verifique !!!', 'ATENCAO')

	else 

		_nTipo  := 2     // 2= Saida
		cIdent := RetIdEnti()	//Pega o IDENT da empresa
		
		For _i := 1 to Len(aStNotas)
			_cSerie   := aStNotas[_i][1]
			_cDoc     := aStNotas[_i][2]
			_cArquivo := "danfe_"+Alltrim(_cDoc)
			_cCaminho := "C:\TEMP\"
			_dEmis    := aStNotas[_i][3]

			if u_CTIMPDANFE(_nTipo, _cSerie,_cDoc,_dEmis,_cCaminho,_cArquivo)
				SF2->(dbsetorder(1))
				SF2->(dbSeek(xFilial('SF2') + _cDoc + _cSerie))
				While SF2->(!eof()) .and. SF2->F2_FILIAL == xFilial("SF2") ;
					.and. Alltrim(sf2->f2_doc) == Alltrim(_cDoc) .and. Alltrim(sf2->f2_serie) == Alltrim(_cSerie)
					Reclock("SF2",.f.)
					sf2->f2_zimp := 'S'
					MsUnlock("SF2")	
					sf2->(dbskip())
				End 
			endif 

		Next
			
		_oCheck3_n:Hide()
		_oCheck3_o:Show()
		// STATUS 2 - Processamento efetuado com sucesso
		PutGlbValue("G_" + trbf->Pedido + "_" + cxCheck,"2")
						//GlbUnLock()
		//goGrvTrbc(_xPedido, cxCheck, '2')
	
	endif

RETURN

//-----------------------------------
// Impressùo Boleto
//-----------------------------------
Static Function fImprBoleto(cxCheck)

//  Acha nota fiscal
	_cNota := trbf->nfiscal
	_cSerie:= trbf->serie
	_cCliente := trbf->Cliente
	_cLoja    := trbf->loja 
	_cBoleto  := GETMV( MV_XBOLETO )

	if _cBoleto == "S"   // Devera imprimir boleto

		cRet := U_XAG0045E(cFilant , _cNota, _cSerie , "I")
		if cRet <> "SUCESSO"
			MsgAlert("ATEN«√O: GeraÁ„o do Boleto com erro, verifique !!!","ERRO")
		else		
			_oCheck4_n:Hide()
			_oCheck4_o:Show()
		// STATUS 2 - Processamento efetuado com sucesso
			PutGlbValue("G_" + _xPedido + "_" + cxCheck,"2")
		//goGrvTrbc(_xPedido, cxCheck, '2')
		endif 
	else
		MSGALERT( "Emiss„o Boleto n„o liberada. Favor acionar Suporte !!!", "AVISO" )
	endif 

Return 

//-----------------------------------
// Impressùo Romaneio
//-----------------------------------
Static Function fImprRomaneio(cxCheck)

	Local _cRomaneio := GETMV("MV_XROMAN")
	Local _cNota     := trbf->nfiscal
	
	if Empty(_cNota)
		MsgAlert('Nota Fiscal ainda nao gerada. Verifique!!', 'ATENCAO')
	else
	// chama rotin Romaneio
		if _cRomaneio == "S"
			u_AGR245()
			_oCheck5_n:Hide()
			_oCheck5_o:Show()
		// STATUS 2 - Processamento efetuado com sucesso
			PutGlbValue("G_" + _xPedido + "_" + cxCheck,"2")
		//goGrvTrbc(_xPedido, cxCheck, '2')
		else
			MSGALERT( "ExecuÁ„o Romaneio nao liberada. Verifique com o Suporte !!!", "AVISO" )
		endif
	endif 
RETURN

//-----------------------------------
// Transmissùo DANFE
//-----------------------------------
User Function fGeraDANFE()

//User Function fImpDanf(_nTipo,_lEnvia, _cDoc, _cSerie, _cCliente, _cLojam, _lAuto, _lImp, _lLog, _cLog)
Local aArea		:= GetArea()
Local cANfeAmbi	:= GetNewPar("MV_ANFEAMB",'2') //(1=producao,2=Homologacao)
Local _nSlpANFe	:= GetNewPar("MV_ANFESLP",500) //->Sleep envio Auto NF-e
Local _lRet		:= .T.
Default _lAuto	:= .F.
Default _lImp	:= .F.
Default _lLog	:= .F.

_cDoc  := trbf->nfiscal
_cSerie:= trbf->serie
_nTipo := 2    // 2- Saida
_lEnvia:= .t.
_cCliente := trbf->cliente 
_cLojam   := trbf->loja 
_lAuto    := .f.
_lImp     := .f.
_lLog     := .f.
_cLog     := ''

SF2->(dbSetOrder(1))//->F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If SF2->(dbSeek(xFilial("SF2") + _cDoc + _cSerie + _cCliente + _cLojam)) 
	If _lEnvia //-> Envia NF-e
		U_CTAutoNfe(cEmpAnt,xFilial("SF2"),"0",cANfeAmbi,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC)
		Sleep(_nSlpANFe)
	Endif
            
	U_CTNFeMnt(_cSerie, _cDoc, _cDoc) //-> monitora a nfe
	If _lImp //-> Se Imprime o Danfe
		U_fGerDanf(_nTipo,_cCliente, _cLojam, _cDoc, _cSerie) //-> Imprime o DANFE
	Endif
Else
	MsgAlert('Documento nao encontrado.['+_cDoc + _cSerie + _cCliente + _cLojam+']')
	_lRet:= .F.
Endif

RestArea(aArea)
Return(_lRet)

/*/{Protheus.doc} fGerDanf
//Geraùùo da DANFE
/*/
User Function fGerDanf(_nTipo,_cCliente, _cLojam, _cDoc, _cSerie)
Local _cPastaTmp:= GetNewPar("CT_DVDANEX","c:\temp\")
//Local _cFileTmp	:= AllTrim(_cCliente + _cLojam +  _cDoc + _cSerie) +'.PDF'
Local _aArea	:= GetArea()
Local _nSleepNFE:= GetNewPar("CT_DANFSLP",500) //-> Sleep para a geraùùo do documento
Local _lVerAut	:= GetnewPar("CT_DANFVSA",.F.) //-> Se deve verificar se a NFE jù tem o cùdigo de retorno da SEFAZ
Local _lContinua:= .T.

If !ExistDir(_cPastaTmp)
	MakeDir(_cPastaTmp)
	If !ExistDir(_cPastaTmp)
		MsgStop('Pasta Padrao nao existe.')
		RestArea(_aArea)
		Return .F.
	Endif
EndIf

Sleep(_nSleepNFE)
SysRefresh()

SF2->(dbGoTop())
SF3->(dbGoTop())
	
SF2->(dbSetOrder(1))//->F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If SF2->(dbSeek(xFilial("SF2") + _cDoc + _cSerie + _cCliente + _cLojam)) 
	If _lVerAut
		SF3->(dbSetOrder(4)) //-> Verifica se estù autorizada
		If SF3->(MsSeek(xFilial("SF3")+_cCliente + _cLojam + _cDoc + _cSerie))
			If SF3->F3_CODRSEF <> '100'
				_lContinua:=.F.
			Endif
		Endif
	Endif
	
	If _lContinua
		Return(.T.)
	Endif
	
Endif

MsgStop('Nao foi possivel imprimir o DANFE.')
RestArea(_aArea)
Return(.T.)

/*/{Protheus.doc} CTAutoNfe
//Transmite NF-e
/*/
User Function CTAutoNfe(cEmpresa,cFilProc,cWait,cOpc,cSerie,cNotaIni,cNotaFim)
	Local aArea       := GetArea()
	Local aPerg       := {}
	Local lEnd        := .F.
	Local aParam      := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC))}
	Local aXML        := {}
	Local cRetorno    := ""
	Local cIdEnt      := ""
	Local cModalidade := ""
	Local cAmbiente   := ""
	Local cVersao     := ""
	Local cVersaoCTe  := ""
	Local cVersaoDpec := ""
	Local cMonitorSEF := ""
	Local cSugestao   := ""
	Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local nX          := 0
	Local lOk         := .T.
	Local oWs
	Local cParNfeRem  := SM0->M0_CODIGO+SM0->M0_CODFIL+"AUTONFEREM"

	If cSerie == Nil
		MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfeRem,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
		MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfeRem,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
		MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfeRem,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
	Else
		MV_PAR01 := aParam[01] := cSerie
		MV_PAR02 := aParam[02] := cNotaIni
		MV_PAR03 := aParam[03] := cNotaFim
	EndIf

	If .T.//CTIsRdy()

//-> Obtem o codigo da entidade

		cIdEnt := GetIdEnt()

		If !Empty(cIdEnt)

//-> Obtem o ambiente de execucao do Totvs Services SPED
			oWS := WsSpedCfgNFe():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:nAmbiente  := 0
			oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk			   := execWSRet( oWS, "CFGAMBIENTE")
			If lOk
				cAmbiente := oWS:cCfgAmbienteResult
			Else
				Conout(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
			EndIf
//-> Obtem a modalidade de execucao do Totvs Services SPED
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt 
				oWS:nModalidade:= 0
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				oWs:cModelo	   := "55"
				lOk 		   := execWSRet( oWS, "CFGModalidade" )
				If lOk
					cModalidade:= oWS:cCfgModalidadeResult
				Else
					Conout(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
				EndIf
			EndIf
//-> Obtem a versao de trabalho da NFe do Totvs Services SPED
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:cVersao    := "0.00"
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk			   := execWSRet( oWs, "CFGVersao" )
				If lOk
					cVersao    := oWS:cCfgVersaoResult
				Else
					Conout(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
				EndIf
			EndIf
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:cVersao    := "0.00"
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk 		   := execWSRet( oWs, "CFGVersaoCTe" )
				If lOk
					cVersaoCTe := oWS:cCfgVersaoCTeResult
				Else
					Conout(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
				EndIf
			EndIf
			If lOk
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:cVersao    := "0.00"
				oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				lOk			   := execWSRet( oWs, "CFGVersaoDpec" )
				If lOk
					cVersaoDpec:= oWS:cCfgVersaoDpecResult
				Else
					Conout(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
				EndIf
			EndIf
//-> Verifica Status Sefaz
			If lOk
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
				lOk := oWS:MONITORSEFAZMODELO()
				If lOk
					aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
					For nX := 1 To Len(aXML)
						Do Case
						Case aXML[nX]:cModelo == "55"
							cMonitorSEF += "- NFe"+CRLF
							cMonitorSEF += "Versao do layout: "+cVersao+CRLF
							If !Empty(aXML[nX]:cSugestao)
								cSugestao += 'Sugestao'+"(NFe)"+": "+aXML[nX]:cSugestao+CRLF 
							EndIf

						Case aXML[nX]:cModelo == "57"
							cMonitorSEF += "- CTe"+CRLF
							cMonitorSEF += "Versao do layout: "+cVersaoCTe+CRLF
							If !Empty(aXML[nX]:cSugestao)
								cSugestao += 'Sugestao'+"(CTe)"+": "+aXML[nX]:cSugestao+CRLF
							EndIf
						EndCase
						cMonitorSEF += Space(6)+"Versao da mensagem"+": "+aXML[nX]:cVersaoMensagem+CRLF
						cMonitorSEF += Space(6)+"Codigo do Status"+": "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF
						cMonitorSEF += Space(6)+"UF Origem"+": "+aXML[nX]:cUFOrigem
						If !Empty(aXML[nX]:cUFResposta)
							cMonitorSEF += "("+aXML[nX]:cUFResposta+")"+CRLF //"UF Resposta"
						Else
							cMonitorSEF += CRLF
						EndIf
						If aXML[nX]:nTempoMedioSEF <> Nil
							cMonitorSEF += Space(6)+"Tempo de espera"+": "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF
						EndIf
						If !Empty(aXML[nX]:cMotivo)
							cMonitorSEF += Space(6)+"Motivo"+": "+aXML[nX]:cMotivo+CRLF 
						EndIf
						If !Empty(aXML[nX]:cObservacao)
							cMonitorSEF += Space(6)+'Observacao'+": "+aXML[nX]:cObservacao+CRLF
						EndIf
					Next nX
				EndIf
			EndIf

			Conout("[JOB  ]["+cIdEnt+"] - Iniciando transmissao NF-e de saida!")
			cRetorno := SpedNFeTrf("SF2",aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,.F.,.T.)
			Conout("[JOB  ]["+cIdEnt+"] - "+cRetorno)
			
		EndIf
	Else
		Conout("SPED","Execute o modulo de configuracao do servico, antes de utilizar esta opcao!!!")
	EndIf

	RestArea(aArea)
Return
 
/*/
Rotina : GetIdEnt
Obtem o codigo da entidade apos enviar o post para o Totvs
/*/
Static Function GetIdEnt()

	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs

	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{'Erro'},3)
	EndIf

	RestArea(aArea)
Return(cIdEnt)

//----------------------------------------------------
// Impressùo DANFE
//----------------------------------------------------
User Function CTIMPDANFE(_nTipo, _cSerie,_cDoc,_dEmis,_cCaminho,_cArquivo)
 Local _lExibe	:= .F.
 Local cIdEnt := ""
 local nFlags := ""
 Local cFilePrint := ""
 Local _lRet := .f.

 Private cCondicao := ""
 Private lEnd := .F.
 Private _lImpr := GetMV("MV_XNFEIMP")

 nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
 cFilePrint := _cArquivo
 cCondicao := ""
  
//cIdEnt := StaticCall(SPEDNFE,GetIdEnt) 
cIdent := RetIdEnti() //->Entidade

 cPerg := "NFSIGW"
 cPerg :=  PADR(cPerg,Len(SX1->X1_GRUPO))

	Private mv_par01 := _cDoc //de nf 
	Private mv_par02 := _cDoc //ate nf
	Private mv_par03 := _cSerie //serie
	Private mv_par04 := _nTipo //tipo: 2-saida/1-entrada
	Private mv_par05 := 2 //imprime no verso
	Private mv_par06 := 2 //DANFE Simplificada
	Private MV_PAR07 := _dEmis
	Private MV_PAR08 := _dEmis

	oSetup:=FWPrintSetup():New(nFlags, "DANFE")
	oSetup:SetPropert(PD_PRINTTYPE , iif(_lImpr == 'S', 1 , 6))//ou 1 verificar
	oSetup:SetPropert(PD_ORIENTATION , 1)
	oSetup:SetPropert(PD_DESTINATION , 1)
	oSetup:SetPropert(PD_MARGIN , {60,60,60,60})
	oSetup:SetPropert(PD_PAPERSIZE , 2)
	oSetup:aOptions[PD_VALUETYPE] := _cCaminho

 	oDanfe := FWMSPrinter():New(cFilePrint,iif(_lImpr == "S", IMP_SPOOL, IMP_PDF),.F.,_cCaminho,_lExibe, ,oSetup, , , .F., ,.F. ,1)

	if U_PrtNfeSef(cIdEnt,,,oDanfe,oSetup,cFilePrint)
	
		Sleep(500)// Para o processamento por 3 segundos
		_lRet := .t.
		
	endif 
Return _lRet

/*****************************************************************/
/* ATENùùO: AO FINALIZAR O PROJETO ENCAPSULAR                    */
/*****************************************************************/
User Function fGravaSX1 (cInGrupo, cInSeqPerg, _xValor)
/*
	Local 	aAreaOld		:= GetArea ()
	Local 	cXUserName 	:= ""
	Local 	cXMemoProf 	:= ""
	Local 	nLinAux    	:= 0
	Local 	aLinhas   		:= {}
	Local 	lContinua 		:= .T.
	Local	cGrupoAux		:= cInGrupo
	Local	cSeqPerg		:= cInSeqPerg
	Local	cLinAux		:= ""

	// Na versao Protheus10 o tamanho das perguntas aumentou.
	cGrupoAux = padr (cGrupoAux, len (sx1 -> x1_grupo), " ")

	If lContinua
		If ! sx1 -> (dbseek (cGrupoAux + cSeqPerg, .F.))
			MsgAlert ("Programa " + procname () + ": grupo/pergunta '" + cGrupoAux + "/" + cSeqPerg + "' nao encontrado no arquivo SX1." + sfPilha(),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			lContinua = .F.
		Endif
	Endif

	If lContinua
		// Atualizarei sempre no SX1. Depois vou ver se tem profile de usuario.
		Do case
		Case sx1 -> x1_gsc == "C"
			reclock("SX1", .F.)
			sx1 -> x1_presel := val (cvaltochar (_xValor))
			sx1 -> x1_cnt01 := ""
			sx1 -> (msunlock ())
		Case sx1 -> x1_gsc == "G"
			If ValType (_xValor) != sx1 -> x1_tipo
				MsgAlert ("Programa " + ProcName () + ": incompatibilidade de tipos: o parametro '" + cSeqPerg + "' do grupo de perguntas '" + cGrupoAux + "' eh do tipo '" + sx1 -> x1_tipo + "', mas o valor recebido eh do tipo '" + valtype (_xValor) + "'." + sfPilha(),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				lContinua := .F.
			Else
				reclock ("SX1", .F.)
				sx1 -> x1_presel := 0
				If sx1 -> x1_tipo == "D"
					sx1 -> x1_cnt01 := "'"+dtoc (_xValor)+"'"
				Elseif sx1 -> x1_tipo == "N"sfPilha
					sx1 -> x1_cnt01 := str (_xValor, sx1 -> x1_tamanho, sx1 -> x1_decimal)
				Elseif sx1 -> x1_tipo == "C"
					sx1 -> x1_cnt01 := _xValor
				Endif
				sx1 -> (msunlock())
			Endif
		otherwise
			MsgAlert ("Programa " + procname () + ": tratamento para X1_GSC = '" + sx1 -> x1_gsc + "' ainda nao implementado." + sfPilha(),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			lContinua := .F.
		EndCase
	Endif


	psworder(1) // Ordena arquivo de senhas por ID do usuario
	PswSeek(__cUserID) // Pesquisa usuario corrente
	cXUserName := PswRet(1)[1,2]

	// Encontra e atualiza profile deste usuario para a rotina / pergunta atual.
	// Enquanto o usuario nao alterar nenhuma pergunta, ficarah usando do SX1 e
	// seu profile nao serah criado.
	If FindProfDef(Substr(cEmpAnt+cXUserName,1,15), cGrupoAux, "PERGUNTE", "MV_PAR")
		// Carrega memo com o profile do usuario (o profile fica gravado
		// em um campo memo)
		cXUserName	:= Substr(cEmpAnt+cXUserName,1,15)
		cXMemoProf := RetProfDef (cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR")
	ElseIf FindProfDef(cEmpAnt+cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR")
		cXUserName	:= Substr(cXUserName,1,15)
		cXMemoProf := RetProfDef (cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR")
	Endif
	
	// Monta array com as linhas do memo (tem uma pergunta por linha)
	aLinhas = {}
	For nLinAux = 1 To MLCount (cXMemoProf)
		Aadd (aLinhas, AllTrim (MemoLine (cXMemoProf,, nLinAux)) + chr (13) + chr (10))
	Next

	// Monta uma linha com o novo conteudo do parametro atual.
	// Pos 1 = tipo (numerico/data/caracter...)
	// Pos 2 = aspassimples#aspassimples
	// Pos 3 = GSC
	// Pos 4 = aspassimples#aspassimples
	// Pos 5 em diante = conteudo.
	cLinAux = sx1 -> x1_tipo + "#" + sx1 -> x1_gsc + "#" + iif (sx1 -> x1_gsc == "C", cValToChar (sx1 -> x1_presel), sx1 -> x1_cnt01) + chr (13) + chr (10)

	// Se foi passada uma pergunta que nao consta no profile, deve tratar-se
	// de uma pergunta nova, pois jah encontrei-a no SX1. Entao vou criar uma
	// linha para ela na array. Senao, basta regravar na array.
	
	If Val(cSeqPerg) > Len (aLinhas)
		Aadd (aLinhas, cLinAux)
	Else
		// Grava a linha de volta na array de linhas
		aLinhas [Val (cSeqPerg)] = cLinAux
	Endif

	// Remonta memo para gravar no profile
	cXMemoProf = ""
	For nLinAux = 1 To Len (aLinhas)
		cXMemoProf += aLinhas[nLinAux]
	Next

	// Grava o memo no profile
	If FindProfDef( cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR" )
		WriteProfDef(cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR", ; // Chave antiga
		cXUserName, cGrupoAux, "PERGUNTE", "MV_PAR", ; // Chave nova
		cXMemoProf) // Novo conteudo do memo.
	Endif

	Restarea (aAreaOld)
*/
Return .T.

/*/{Protheus.doc} sfPilha
(long_description)
@author MarceloLauschner
@since 27/04/2014
@version 1.0
@return cRetPilha, Pilha de chamadas
@example
(examples)
@see (links_or_references)
/*/
Static Function sfPilha()
	
	Local nI       	:= 0
	Local cRetPilha 	:= chr (13) + chr (10) + chr (13) + chr (10) + "Pilha de chamadas:"
	
	Do while procname (nI) != ""
		cRetPilha += chr (13) + chr (10) + procname (nI)
		nI++
	Enddo
	
Return cRetPilha


User Function CTNFeMnt(cSerie,cNotaIni,cNotaFim, lCTe, lMDFe, cModel,lTMS, lAutoColab,lExibTela,lUsaColab,lNFCE)

local _cMsgtrans    := ""
Local cIdEnt   		:= ""
//local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local aParam   		:= {Space(Len(SerieNfId("SF2",2,"F2_SERIE"))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),CtoD(""),CtoD("")}
//Local cParNfeRem 	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
Local lOK        	:= .F.
Local lSdoc     	:= TamSx3("F2_SERIE")[1] == 14
Default cSerie   	:= ''
Default cNotaIni 	:= ''
Default cNotaFim 	:= ''
Default lCTe    	:= .F.
Default lMDFe    	:= .F.
Default cModel	 	:= "55"
default lTMS     	:= .F.
Default lAutoColab 	:= .F.
Default lExibTela 	:= .F. // Nùo exibe se Falso
Default lUsaColab 	:= .F.
Default lNFCE		:= IIf (FunName()$"LOJA701",.T.,.F.)
Default nModeloDef	:= 1
Default lMsg		:= .T.

lUsaColab := .f.  //UsaColaboracao( IIF(lCte,"2",IIF(lMDFe,"5",IIF(lNFCE,,"1"))))
if lUsacolab .And. Empty(cModel)
	cModel := Iif(lCte,"57",iif(lMDFe,"58","55"))
endif

//If CTIsRdy( ,,,lUsaColab )
//	cIdEnt := GetIdEnt( lUsaColab )
	cIdEnt := GetIdEnt()
	If !Empty(cIdEnt)
		aParam[01] := cSerie
		aParam[02] := cNotaIni
		aParam[03] := cNotaFim
		lOK        := .T.
		
		If lSdoc
			dDataDe  := aParam[04]
			dDataAte := aParam[05]
		EndIF
		
		If (lOK)
			aListBox := WsNFeMnt(cIdEnt,nModeloDef,aParam,lCTe,lMsg,cModel)
			if Len(aListBox) > 0
				//MsgAlert(Alltrim(aListBox[1][6]), 'MONITOR DANFE')
				_cMsgtrans := aListBox[1][6]
			EndIf

	Else
		Aviso("SPED","Execute o modulo de configuracao do servico, antes de utilizar esta opcao!!!",{"Atencao"},3)	//
	EndIf
//Else
//	Aviso("SPED","Execute o mùdulo de configuraùùo do serviùo, antes de utilizar esta opùùo!!!",{"Atenùùo"},3) //"Execute o mùdulo de configuraùùo do serviùo, antes de utilizar esta opùùo!!!"
EndIf

Return _cMsgtrans

/*****************************************************************/
/* ATENùùO: AO FINALIZAR O PROJETO ENCAPSULAR                    */
/*****************************************************************/
Static Function WsNFeMnt(cIdEnt,nModelo,aParam,lCTe,lMsg,cModel)

Local aListBox	:= {}
Local aMsg		:= {}
Local aXML		:= {}
Local aNotas	:= {}

Local nX		:= 0
Local nY		:= 0
Local nSX3SF2	:= TamSx3("F2_DOC")[1]
Local nLastXml	:= 0
Local nSFTIndex	:= 0
Local nSFTRecno	:= 0
Local nSF3Index	:= 0
Local nSF3Recno	:= 0

Local lOk		:= .T.
Local lUsaColab := .F.

Local oOk		:= LoadBitMap(GetResources(), "ENABLE")
Local oNo		:= LoadBitMap(GetResources(), "DISABLE")
Local oWS
Local oRetorno

Local 	cTextInut	:= GetNewPar("MV_TXTINUT","")
Local 	cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local 	lCTECan		:= GetNewPar( "MV_CTECAN", .F. ) //-- Cancelamento CTE - .F.-Padrao .T.-Apos autorizacao
Local 	cModalidade:= ""
Local 	cChaveF3	:= ""
Local 	cChaveFT	:= ""
Local 	cTipoMov	:= ""
Local 	cSerChv		:= ""
Local	cNfChv		:= ""
Local lSdoc     	:= TamSx3("F2_SERIE")[1] == 14
Local cMV_INTTAF  	:= GetNewPar( 'MV_INTTAF', 'N' ) //Verifica se o parùmetro da integraùùo online esta como 'S'
Local lTafKey     	:= SFT->( ColumnPos( 'FT_TAFKEY' ) ) > 0
Local lIntegTaf   	:= ( cMV_INTTAF == 'S' .and. lTafKey )
Local lTAFVldAmb	:= ExistFunc( 'TAFVldAmb' ) .And. TAFVldAmb( '1' ) .And. ExistFunc( 'DocFisxTAF' ) //Valida se o cliente habilitou a integraùùo nativa Protheus x TAF

Private 	oXml
Default 	lCTe   := .F.
Default		lMsg   := .T.
Default 	cModel := ""

Private cError		:= ""

//?ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
//? Tratamento da NFCe para o Loja                                         ?
//ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
If cModel == "65"
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif
If cModel <> "65"
	lUsaColab	:= UsaColaboracao( IIF(lCte,"2","1") )
EndIf

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN    := "TOTVS"
oWS:cID_ENT       := cIdEnt
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

If cModel == "65"
	oWS:cModelo   := cModel
Endif

If nModelo == 1
	oWS:cIdInicial    := aParam[01]+aParam[02]
	oWS:cIdFinal      := aParam[01]+aParam[03]
	lOk := oWS:MONITORFAIXA()
	oRetorno := oWS:oWsMonitorFaixaResult
Else
	If VALTYPE(aParam[01]) == "N"
		oWS:nIntervalo := Max((aParam[01]),60)
	Else
		oWS:nIntervalo := Max(Val(aParam[01]),60)
	EndIf
	lOk := oWS:MONITORTEMPO()
	oRetorno := oWS:oWsMonitorTempoResult
EndIf
If lOk
	dbSelectArea("SF3")
	dbSetOrder(5)
    For nX := 1 To Len(oRetorno:oWSMONITORNFE)
  		aMsg := {}
 		oXml := oRetorno:oWSMONITORNFE[nX]
 		If Type("oXml:OWSERRO:OWSLOTENFE")<>"U"
			nLastRet := Len(oXml:OWSERRO:OWSLOTENFE)
	 		For nY := 1 To Len(	oXml:OWSERRO:OWSLOTENFE)
 				If oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE<>0
	 				aadd(aMsg,{oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE,oXml:OWSERRO:OWSLOTENFE[nY]:DDATALOTE,oXml:OWSERRO:OWSLOTENFE[nY]:CHORALOTE,;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:NRECIBOSEFAZ,;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:CCODENVLOTE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGENVLOTE,50),;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETRECIBO,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETRECIBO,50),;
	 							oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE,50)})
				EndIf
				SF3->(dbSetOrder(5))
				If SF3->(MsSeek(xFilial("SF3")+oXml:Cid,.T.))
					nSFTRecno:= SFT->(RECNO())
					nSFTIndex:= SFT->(IndexOrd())
					While !SF3->(Eof()) .And. AllTrim(SF3->(F3_SERIE+F3_NFISCAL))==oXml:Cid
						If SF3->( (Left(F3_CFO,1)>="5" .Or. (Left(F3_CFO,1)<"5" .And. F3_FORMUL=="S")) .And. FieldPos("F3_CODRSEF")<>0)
							RecLock("SF3")
							SF3->F3_CODRSEF:= oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
							//SE FOR UMA NOTA DENEGADA, INFORMA NO CAMPO F3_OBSERV
							If oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE $ RetCodDene()
								SF3->F3_OBSERV := "NF DENEGADA"
							EndIf
						    //SE FOR INUTILIZAù?O ALTERA NOS LIVROS FISCAIS
							If !Empty(cTextInut)
							    If Type("oXml:OWSERRO:OWSLOTENFE["+AllTrim(Str(nY))+"]:CMSGRETNFE")<>"U" .And. ("Inutilizacao de numero homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE .Or. "Inutilizaùùo de n?mero homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE)
									SF3->F3_OBSERV := ALLTRIM(cTextInut)
								EndIf
							EndIF

							If SF3->F3_FORMUL == "S"
								cTipoMov :=	"E"
							Else
								cTipoMov := "S"
							EndIf

							SFT->(dbSetOrder(1))
							If SFT->(Dbseek(xFilial("SFT")+cTipoMov+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA))
								RecLock("SFT")
								If !Empty(cTextInut)
							    	If Type("oXml:OWSERRO:OWSLOTENFE["+AllTrim(Str(nY))+"]:CMSGRETNFE")<>"U" .And. ("Inutilizacao de numero homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE .Or. "Inutilizaùùo de n?mero homologado" $ oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE)
										SFT->FT_OBSERV := ALLTRIM(cTextInut)
									EndIf
								EndIF
							EndIf
							MsUnlock()

							//-- Exclusao CTE somente apos envio e autorizacao da SEFAZ
							If lCTE .And. lCTECan .And. !Empty(SF3->F3_DTCANC)
								DT6->(dbSetOrder(1))
								If	DT6->(MsSeek(xFilial('DT6')+cFilAnt+PadR(SF3->F3_NFISCAL,Len(DT6->DT6_DOC))+SF3->F3_SERIE)) .And. DT6->DT6_STATUS$"B/D"
									RecLock('DT6',.F.)
									If SF3->F3_CODRSEF == '101'
										DT6->DT6_STATUS := 'C'  //Cancelamento SEFAZ Autorizado
									Else
										DT6->DT6_STATUS := 'D'  //Cancelamento SEFAZ Nao Autorizado
									EndIf
									MsUnLock()
								EndIf
							EndIf

						EndIf
						SF3->(dbSkip())
					End
					SFT->(DBSETORDER(nSFTIndex))
					SFT->(DBGOTO(nSFTRecno))
				EndIf

//				If ExistBlock("FISMNTNFE")
///    				ExecBlock("FISMNTNFE",.f.,.f.,{oXml:Cid,aMsg})
//         		Endif

			Next nY

		   	SF3->(DbSetOrder(5))
			If SF3->(MsSeek(xFilial("SF3")+oXml:Cid,.T.))
				nSF3Recno:= SF3->(RECNO())
				nSF3Index:= SF3->(IndexOrd())
				While !SF3->(Eof()) .And. AllTrim(SF3->(F3_SERIE+F3_NFISCAL))==oXml:Cid
					If (SubStr(SF3->F3_CFO,1,1)>="5" .Or. SF3->F3_FORMUL=="S")
						aNotas 	:= {}
						aXml2	:= {}
						aadd(aNotas,{})
						aadd(Atail(aNotas),.F.)
						aadd(Atail(aNotas),IIF(SF3->F3_CFO<"5","E","S"))
						aadd(Atail(aNotas),SF3->F3_ENTRADA)
						aadd(Atail(aNotas),SF3->F3_SERIE)
						aadd(Atail(aNotas),SF3->F3_NFISCAL)
						aadd(Atail(aNotas),SF3->F3_CLIEFOR)
						aadd(Atail(aNotas),SF3->F3_LOJA)
						aXml2 := GetXMLNFE(cIdEnt,aNotas,@cModalidade,Iif(lCTE,"57",""))

						If ( Len(aXml2) > 0 )
							aAdd(aXml,aXml2[1])
						EndIf

						nLastXml := Len(aXml)
					Else
						nLastXml:= Len(aXml)
					EndIf
						SF3->(dbSkip())
				End
				SF3->(DBSETORDER(nSF3Index))
				SF3->(DBGOTO(nSF3Recno))
			EndIf

			//Nota de saida
			dbSelectArea("SF2")
			dbSetOrder(1)

			cSerChv 	:= If (lSdoc,SUBSTR(oXml:Cid,1,14),SUBSTR(oXml:Cid,1,3))
			cNfChv  	:= If(lSdoc,PadR(SUBSTR(oXml:Cid,15,Len(oXml:Cid)),nSX3SF2),PadR(SUBSTR(oXml:Cid,4,Len(oXml:Cid)),nSX3SF2))

			If SF2->(MsSeek(xFilial("SF2")+cNfChv+cSerChv,.T.)) .And. nLastXml > 0 .And. !Empty(aXml)
				If (SF2->(FieldPos("F2_HAUTNFE"))<>0 .And. SF2->(FieldPos("F2_DAUTNFE"))<>0) .And. (Empty(SF2->F2_HAUTNFE) .Or. Empty(SF2->F2_DAUTNFE) .Or. (SF2->(FieldPos("F2_CHVNFE"))>0 .And. Empty(SF2->F2_CHVNFE)))
					RecLock("SF2")
					//SF2->F2_HORA 	:= SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF2->F2_NFELETR := SUBSTR(oXml:Cid,4,9)
					//SF2->F2_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
					//SF2->F2_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF2->F2_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
					SF2->F2_HAUTNFE := IIF(!Empty(aXML[nLastXML][6]),SUBSTR(aXML[nLastXML][6],1,5),"")      //Grava a hora de autorizaùùo da nota
					SF2->F2_DAUTNFE	:= IIF(!Empty(aXML[nLastXML][7]),aXML[nLastXML][7],SToD("  /  /    "))  //Grava a data de autorizaùùo da nota
					If !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. !oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ "100,101,102,124,"+ RetCodDene() 	//Se o retorno for uma rejeiùùo, grava o F2_FIMP como N e a legenda fica como Nùo Autorizada(preto) (124 = Autorizaùùo DPEC)
						SF2->F2_FIMP := "N"
					ElseIf !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() 					// Atualizar a Leganda para Nf-e denegada
						SF2->F2_FIMP := "D"
					EndIf

					MsUnlock()
				EndIf

				If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. ( !Empty(aXml[nLastXml][1]) .OR. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() )// Inserida verificaùùo do protocolo , antes de gravar a Chave. Para nota denegada deve gravar a chave
					RecLock("SF2")
					SF2->F2_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					MsUnlock()

					//Funùùo para gravaùùo de campos da Nota no modulo Controle de Lojas com Legislaùùo PAF-ECF
					If ExistFunc("STFMMd5NS")
						STFMMd5NS()
					EndIf

					// Grava quando a nota for Transferencia entre filiais
					IF SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
				       SF1->(dbSetOrder(1))
				    	If SF1->(MsSeek(SF2->F2_FILDEST+SF2->F2_DOC+SF2->f2_SERIE+SF2->F2_FORDES+SF2->F2_LOJADES+SF2->F2_FORMDES))
				    		If EMPTY(SF1->F1_CHVNFE)
					    		RecLock("SF1",.F.)
					    		SF1->F1_CHVNFE := SF2->F2_CHVNFE
					    		MsUnlock()
					    	EndIf
				    	Endif
				    EndiF
				EndIf

			  	//Atualizo SF3
				SF3->(dbSetOrder(4))
				cChave := xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE
				If SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,.T.))
					Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
						RecLock("SF3",.F.)
						//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() )  // Inserida verificaùùo do protocolo, antes de gravar a Chave. Para nota denegada deve gravar a chave.
							SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()
				    SF3->(dbSkip())
				    EndDo
				EndIf
				//Atualizo SF3
				// Grava quando a nota for Transferencia entre filiais
				IF SF1->(!EOF()) .And. SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
					SF3->(dbSetOrder(4))
					cChave := SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
					If SF3->(MsSeek(SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.))
						Do While cChave == SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
							RecLock("SF3",.F.)
							//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
							//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
							//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
							//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() ) // Inserida verificaùùo do protocolo, antes de gravar a Chave. Para nota denegada deve gravar a chave.
								If EMPTY(SF3->F3_CHVNFE)
									SF3->F3_CHVNFE  := SF2->F2_CHVNFE
								EndIf
							EndIf
							MsUnLock()
					    SF3->(dbSkip())
					    EndDo
					EndIf
				 EndIf

			  	//Atualizo SFT
			  	SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
				If SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))
					Do While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
						RecLock("SFT",.F.)
						//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SFT->FT_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() ) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
							SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIf
						MsUnLock()

						//-----------------------------------------------------------------------------------------
						//Quando o cliente utiliza integraùùo com o TAF no retorno do TSS faùo o envio do documento
						//-----------------------------------------------------------------------------------------
						If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
							FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
						EndIf

						SFT->(dbSkip())
			    	EndDo
				EndIf

			  	//Atualizo SFT
				// Grava quando a nota for Transferencia entre filiais
				IF SF1->(!EOF()) .And. SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
				  	SFT->(dbSetOrder(1))
					cChave := SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
					If SFT->(MsSeek(SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
						Do While cChave == SFT->FT_FILIAL+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
							RecLock("SFT",.F.)
							//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
							//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
							//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
							//SFT->FT_CODNFE	:=IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
							If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene() ) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
								If EMPTY(SFT->FT_CHVNFE)
									SFT->FT_CHVNFE  := SF2->F2_CHVNFE
								Endif
							EndIf
							MsUnLock()

							//-----------------------------------------------------------------------------------------
							//Quando o cliente utiliza integraùùo com o TAF no retorno do TSS faùo o envio do documento
							//-----------------------------------------------------------------------------------------
							If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
								FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
							EndIf

							SFT->(dbSkip())
				    	EndDo
					EndIf
				EndIf
			ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)>="5" //Alimenta Chave da NFe Cancelada na F3/FT ao consultar o monitorfaixa
				SF3->(dbSetOrder(4))
				cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
				cChaveFT := xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
				SF3->(dbSeek(cChaveF3,.T.))
				While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
					RecLock("SF3",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene()) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
						SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()
				    SF3->(dbSkip())
			    EndDo

   				SFT->(dbSetOrder(1))
				SFT->(dbSeek(cChaveFT,.T.))
				While !SFT->(Eof()) .And. xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
					RecLock("SFT",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. ( !Empty(aXml[nLastXml][1]) .Or. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene()) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
						SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()

					//-----------------------------------------------------------------------------------------
					//Quando o cliente utiliza integraùùo com o TAF no retorno do TSS faùo o envio do documento
					//-----------------------------------------------------------------------------------------
					If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
						FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
					EndIf

					SFT->(dbSkip())
		    	EndDo
			EndIf

			//Nota de entrada
			dbSelectArea("SF1")
			dbSetOrder(1)

			cSerChv 	:= If (lSdoc,SUBSTR(oXml:Cid,1,14),SUBSTR(oXml:Cid,1,3))
			cNfChv  	:= If(lSdoc,PadR(SUBSTR(oXml:Cid,15,Len(oXml:Cid)),nSX3SF2),PadR(SUBSTR(oXml:Cid,4,Len(oXml:Cid)),nSX3SF2))

			If SF1->(MsSeek(xFilial("SF1")+cNfChv+cSerChv,.T.)) //.And. nLastXml > 0 .And. !Empty(aXml)

					aNotas 	:= {}
					aXml2	:= {}
					aadd(aNotas,{})
					aadd(Atail(aNotas),.F.)
					aadd(Atail(aNotas),"E")
					aadd(Atail(aNotas),SF1->F1_EMISSAO)
					aadd(Atail(aNotas),SF1->F1_SERIE)
					aadd(Atail(aNotas),SF1->F1_DOC)
					aadd(Atail(aNotas),SF1->F1_FORNECEDOR)
					aadd(Atail(aNotas),SF1->F1_LOJA)
					aXml2 := GetXMLNFE(cIdEnt,aNotas,@cModalidade,Iif(lCTE,"57",""))

					If ( Len(aXml2) > 0 )
						aAdd(aXml,aXml2[1])
					EndIf

					nLastXml := Len(aXml)

				//If SF1->(FieldPos("F1_HORA"))<>0 .And. (Empty(SF1->F1_HORA) .OR. Empty(SF1->F1_NFELETR) .Or. Empty(SF1->F1_EMINFE) .Or.Empty(SF1->F1_HORNFE) .Or. Empty(SF1->F1_CODNFE) .Or. (SF1->(FieldPos("F1_CHVNFE"))>0 .And. Empty(SF1->F1_CHVNFE)))
				If (SF1->(FieldPos("F1_HAUTNFE")) <> 0 .And. SF1->(FieldPos("F1_DAUTNFE")) <> 0) .And. (Empty(SF1->F1_HAUTNFE) .Or. Empty(SF1->F1_DAUTNFE) .Or. (SF1->(FieldPos("F1_CHVNFE")) > 0 .And. Empty(SF1->F1_CHVNFE))) .and. len(axml) > 0
					RecLock("SF1")
		   			//SF1->F1_HORA	:= SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF1->F1_NFELETR := SUBSTR(oXml:Cid,4,9)
					//SF1->F1_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
					//SF1->F1_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
					//SF1->F1_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
					SF1->F1_HAUTNFE := IIF(!Empty(aXML[nLastXML][6]),SUBSTR(aXML[nLastXML][6],1,5),"")      //Grava a hora de autorizaùùo da nota
					SF1->F1_DAUTNFE	:= IIF(!Empty(aXML[nLastXML][7]),aXML[nLastXML][7],SToD("  /  /    "))  //Grava a data de autorizaùùo da nota
					If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
					    If (SF1->F1_FORMUL == "S") // So grava a a chave da nota se for formulerio prorpio igual a SIM
						   		SF1->F1_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						EndIF
					EndIf
					If !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. !oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ "100,101,102,124,"+RetCodDene() 	 //Se o retorno for uma rejeiùùo, grava o F2_FIMP como N e a legenda fica como Nùo Autorizada(preto) (124 = Autorizaùùo DPEC)
						SF1->F1_FIMP := "N"
					ElseIf !Empty(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE) .And. oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE $ RetCodDene()  					// Atualizar a Leganda para Nf-e denegada
						SF1->F1_FIMP := "D"
					EndIf
					MsUnlock()
				EndIf

				//Atualizo SF3
				SF3->(dbSetOrder(4))
				cChave := xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
				If SF3->(MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.T.))
					Do While cChave == xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE .And. !SF3->(Eof())
						RecLock("SF3",.F.)
						//SF3->F3_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SF3->F3_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SF3->F3_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SF3->F3_CODNFE	:= IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
							If (SF3->F3_FORMUL == "S")
								SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
						    Endif
						EndIf
						MsUnLock()
				    SF3->(dbSkip())
				    EndDo
				EndIf

			  	//Atualizo SFT
			  	SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
				If SFT->(MsSeek(xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
					Do While cChave == xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
						RecLock("SFT",.F.)
						//SFT->FT_NFELETR	:= SUBSTR(oXml:Cid,4,9)
						//SFT->FT_EMINFE	:= oXml:OWSERRO:OWSLOTENFE[nLastRet]:DDATALOTE
						//SFT->FT_HORNFE	:= STRTRAN(oXml:OWSERRO:OWSLOTENFE[nLastRet]:CHORALOTE,":","")//SUBSTR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:cHORALOTE,1,5)
						//SFT->FT_CODNFE	:=IIF(!Empty(aXml[nLastXml][1]),aXml[nLastXml][1],"")
						If !Empty(aXML) .And.!Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
							If (SFT->FT_FORMUL == "S")
								SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
							Endif
						EndIf
						MsUnLock()

						//-----------------------------------------------------------------------------------------
						//Quando o cliente utiliza integraùùo com o TAF no retorno do TSS faùo o envio do documento
						//-----------------------------------------------------------------------------------------
						If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
							FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
						EndIf

						SFT->(dbSkip())
			    	EndDo
				EndIf
			ElseIf !Empty(SF3->F3_DTCANC) .and. SubStr(SF3->F3_CFO,1,1)<"5" //Alimenta Chave da NFe Cancelada na F3/FT  ao consultar o monitorfaixa
				SF3->(dbSetOrder(4))
				cChaveF3 := xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
				cChaveFT := xFilial("SFT")+"E"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
				SF3->(dbSeek(cChaveF3,.T.))
				While !SF3->(Eof()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == cChaveF3
					RecLock("SF3",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]) .And. !Empty(aXml[nLastXml][1]) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
						SF3->F3_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()
				    SF3->(dbSkip())
			    EndDo

   				SFT->(dbSetOrder(1))
				SFT->(dbSeek(cChaveFT,.T.))
				While !SFT->(Eof()) .And. xFilial("SFT")+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == cChaveFT
					RecLock("SFT",.F.)
					If !Empty(aXML) .And. !Empty(aXml[nLastXml][2]).And. !Empty(aXml[nLastXml][1]) // Inserida verificaùùo do protocolo, antes de gravar a Chave.
						SFT->FT_CHVNFE  := SubStr(NfeIdSPED(aXML[nLastXml][2],"Id"),4)
					EndIf
					MsUnLock()

					//-----------------------------------------------------------------------------------------
					//Quando o cliente utiliza integraùùo com o TAF no retorno do TSS faùo o envio do documento
					//-----------------------------------------------------------------------------------------
					If lIntegTaf .and. !empty( SFT->FT_CHVNFE )
						FIntegNfTaf( { SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_CLIEFOR, SFT->FT_LOJA, SFT->FT_TIPOMOV, SFT->FT_ENTRADA }, lTAFVldAmb )
					EndIf

					SFT->(dbSkip())
		    	EndDo
			EndIf
 		EndIf
   			aadd(aListBox,{ IIf(Empty(oXml:cPROTOCOLO) .Or. oXml:OWSERRO:OWSLOTENFE[1]:CCODRETNFE $ RetCodDene(),oNo,oOk),;
			oXml:cID,;
			IIf(oXml:nAMBIENTE==1,"Producao","Homologacao"),; //"Produùùo"###"Homologaùùo"
			IIf(oXml:nMODALIDADE==1 .Or. oXml:nMODALIDADE==4 .Or. oXml:nModalidade==6,"Normal","Contingencia"),; //"Normal"###"Contingùncia"
			oXml:cPROTOCOLO,;
			PadR(oXml:cRECOMENDACAO,250),;
			oXml:cTEMPODEESPERA,;
			oXml:nTEMPOMEDIOSEF,;
			aMsg})

			aXml 		:= {}
			nLastXml	:= 0
    Next nX

    If Empty(aListBox) .And. lMsg 
    	Aviso("SPED","documento nao encontrados em notas transmitidas.",{"Atencao"})
    EndIf


ElseIf !lOk .And. lMsg
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Atencao"},3)
EndIf

Return(aListBox)

Static Function CTIsRdy(cURL,nTipo,lHelp,lUsaColab)

Local cHelp    := ""
local cError	:= ""
Local lRetorno := .F.
DEFAULT nTipo := 1
DEFAULT lHelp := .F.
DEFAULT lUsaColab := .F.
if !lUsaColab
   If FunName() <> "LOJA701"
   		If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := "MV_SPEDURL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "URL SPED NFe"
			MsUnLock()
			PutMV("MV_SPEDURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Else
		If !Empty(cURL) .And. !PutMV("MV_NFCEURL",cURL)
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := "MV_NFCEURL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "URL de comunicacao com TSS"
			MsUnLock()
			PutMV("MV_NFCEURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	EndIf
	//Verifica se o servidor da Totvs esta no ar
	if(isConnTSS(@cError))
		lRetorno := .T.
	Else
		If lHelp
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Atenlcao."},3)
		EndIf
		lRetorno := .F.
	EndIf


	//Verifica se Hù Certificado configurado
	If nTipo <> 1 .And. lRetorno

		if( isCfgReady(, @cError) )
			lRetorno := .T.
		else
			If nTipo == 3
				cHelp := cError

				If lHelp .And. !"003" $ cHelp
					Aviso("SPED",cHelp,{"Atencao."},3)
					lRetorno := .F.

				EndIf

			Else
				lRetorno := .F.

			EndIf
		endif

	EndIf

	//Verifica Validade do Certificado
	If nTipo == 2 .And. lRetorno
		isValidCert(, @cError)
	EndIf
else
	lRetorno := ColCheckUpd()
	if lHelp .And. !lRetorno .And. !lAuto
		MsgInfo("UPDATE do TOTVS Colaboracao 2.0 nùo aplicado. Desativado o uso do TOTVS Colaboraùùo 2.0")
	endif
endif

Return(lRetorno)

//======================================
// Gera as Perguntas
//======================================
Static Function Pergunta()
    Local lRetorno := .F.
    Local aRet := {}
	Local aParambox := {}
    Local nDiasSC9:= 30
	
	aAdd(aParamBox,{1 , "Verificar quantos dias?",  nDiasSC9,  "@E 999", "Positivo()", "", ".T.", 80,  .F.})
    If ParamBox(aParamBox,"Pergunte...",@aRet)
        lRetorno := .T.
    Endif

return lRetorno
