#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

Static __COMPAUT := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103FIM  ºAutor  ³Angelo Henrique     º Data ³  27/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina utilizada para fazer com que os títulos gerados      º±±
±±º          ³pela classificação da nota entrem no processo de aprovaçãoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT103FIM

	Local _aArea	:= GetArea()
	Local _cQuery	:= ""
	Local _cAliQry	:= GetNextAlias()
	Local _cDadUsu 	:= __cUserId
	Local _cGrupoAp := GetMv("MV_XALCFIN")
	Local _cParc	:= ""
	Local _cTip		:= ""
	Local _lTit		:= .F.
	Local cAlias	:= CriaTrab(Nil,.F.)	
	Local _nOpcao   := PARAMIXB[1]
	Local _nConfirm	:= PARAMIXB[2]
	Local cRefCode  := ""
	Local nRecnoSE2 := 0

	Local cEmpresas		:= SuperGetMV("MV_XEMPCOS",.F.,"04/06/07/08/09/10/11/12/13/14/15/16/17/21/22/23/24/25")
	Local lIntRJ		:= SuperGetMV("MV_XRJCOSW",.F.,.F.)
	Local cCCustos		:= SuperGetMV("MV_XCCCOSW",.F.,"20000200/20000213")

//	Local lMVXCMPAC		:= SuperGetMV("MV_XCMPAC",.F.,.F.)
	Local lMVXCMPAM		:= SuperGetMV("MV_XCMPAM",.F.,.F.)
	Local lMVXCMPC7		:= SuperGetMV("MV_XCMPC7",.F.,.F.)
	Local lMVXCMPHL		:= SuperGetMV("MV_XCMPHL",.F.,.F.)

	Private _lTemPed := .F.

	// Ponto de chamada ConexãoNF-e
	// Na inclusão de uma nota tanto pelo documento de entrada (MATA103) quanto pelo importador (GATI001),
	// ele gerará um arquivo para integração com o portal atualizando o flag “ERP”. Na exclusão de um documento
	// de entrada fará a geração de arquivo para atualizar a flag “ERP” do portal. Também volta o status do XML
	// para ficar disponível para nova importação.
	U_GTPE002()

	SF1->(DbSetOrder(1))
	SF1->(DbSeek(xFilial("SF1")+CNFISCAL+CSERIE+CA100FOR+CLOJA+CTIPO))

	cQry := "SELECT C7_XOEMLOC FROM "+RETSQLNAME("SC7")+" SC7,"+RETSQLNAME("SD1")+" SD1"
	cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'"
	cQry += " AND D1_FILIAL   = '"+xFilial("SD1")+"'"
	cQry += " AND C7_ITEM     = D1_ITEMPC"
	cQry += " AND C7_NUM      = D1_PEDIDO"
	cQry += " AND C7_FORNECE  = D1_FORNECE"
	cQry += " AND C7_LOJA     = D1_LOJA"
	cQry += " AND D1_FORNECE  = '"+SF1->F1_FORNECE+"'"
	cQry += " AND D1_LOJA     = '"+SF1->F1_LOJA   +"'"
	cQry += " AND D1_DOC      = '"+SF1->F1_DOC    +"'"
	cQry += " AND D1_SERIE    = '"+SF1->F1_SERIE  +"'"
	cQry += " AND C7_XOEMLOC <> ' '
	cQry += " AND C7_PRODUTO  = D1_COD"
	cQry += " AND SC7.D_E_L_E_T_ <> '*'"
	cQry += " AND SD1.D_E_L_E_T_ <> '*'"
	TCQUERY cQry ALIAS (cAlias) NEW
	If !(cAlias)->(Eof())
		cRefCode := (cAlias)->C7_XOEMLOC
		SF1->(RecLock("SF1",.F.))
		SF1->F1_XOEMLOC := cRefCode
		SF1->(MsUnLock("SF1"))
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(_aArea)

	// Irá fazer as validações abaixo quando não for chamado através do Importador ConexãoNfe ou Quando for pelo ConexãoNfe e
	// esteja na tela do Documento de Entrada
	 
	If !FwIsInCallStack('U_GATI001')  .Or. (FwIsInCallStack('U_GATI001') .And. !l103Auto) .And. PARAMIXB[2] <> 0
		If _nConfirm == 1

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Bloqueando todos os títulos gerados pela Nota, menos os títulos de impostos conforme solicitado  ³
			//³pela STATE GRID os mesmo devem enrar desbloqueados			    								³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cQuery := " SELECT R_E_C_N_O_ RECN, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_ORIGEM "
			_cQuery += " FROM "+RetSqlName("SE2")+" SE2"
			_cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
			_cQuery += " AND E2_NUM      = '"+CNFISCAL+"'"
			_cQuery += " AND E2_PREFIXO  = '"+CSERIE+"'"
			_cQuery += " AND E2_FORNECE  = '"+CA100FOR+"'"
			_cQuery += " AND E2_LOJA     = '"+CLOJA+"'"
			_cQuery += " AND E2_ORIGEM   = 'MATA100'"
			_cQuery += " AND SE2.D_E_L_E_T_ = ' '"

			If Select(_cAliQry) > 0
				DbselectArea(_cAliQry)
				(_cAliQry)->(DbcloseArea())
			EndIf

			DbUseArea(.T., 'TOPCONN', TCGenQry(,,_cQuery), _cAliQry, .F., .T.)

			While (_cAliQry)->(!Eof())

				SE2->(DbGoTo((_cAliQry)->RECN))

				_lTit := .T.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pegando informações do primeiro título gerado  ³
				//³para ser usado na chamada da função do workflow³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(SE2->E2_PARCELA) .OR. Empty(_cParc)

					_cParc		:= SE2->E2_PARCELA
					_cTip		:= SE2->E2_TIPO
					nRecnoSE2	:= SE2->(Recno())

				EndIf

				SE2->(Reclock("SE2",.F.))

				SE2->E2_XLIBERA	:= "B"
				SE2->E2_XGRPG 	:= _cGrupoAp
				SE2->E2_XSOLIC  := _cDadUsu
				If _lTemPed
					SE2->E2_DATALIB := dDatabase
				Else
					SE2->E2_DATALIB := CTOD(" / / ")
				Endif
				SE2->E2_XOEMLOC := cRefCode
				SE2->(MsUnlock())

				(_cAliQry)->(DbSkip())

			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realizando a chamada da função que irá disparar o workflow³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nRecnoSE2 > 0 .And. _lTit .And. SF1->F1_XHOLD <> "S" .And. SF1->F1_XCELNF <> "S"
				SE2->(DbGoTo(nRecnoSE2))
				U_STAA008(SF1->F1_VALBRUT)
			EndIf

			If Select(_cAliQry) > 0
				DbselectArea(_cAliQry)
				(_cAliQry)->(DbcloseArea())
			EndIf

		EndIf

		If _nOpcao == 4 .AND. _nConfirm == 1

			SN1->(DBSetOrder(8))
			SN1->(DBSeek(xFilial("SN1")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_ESPECIE+SF1->F1_DOC+SF1->F1_SERIE))

			DbSelectArea("ZZ3")
			ZZ3->(dbSetOrder(1))

			While !SN1->(EOF()) .AND. SF1->F1_FORNECE == SN1->N1_FORNEC .AND.;
					SF1->F1_LOJA == SN1->N1_LOJA .AND. SF1->F1_DOC == SN1->N1_NFISCAL .AND. SF1->F1_SERIE == SN1->N1_NSERIE

				SN3->(DBSetOrder(1))

				If SN3->(DBSeek(xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM))

					SN3->(RecLock("SN3",.F.))
					SN3->N3_TIPO 	:= "  "
					SN3->N3_HISTOR	:= SN1->N1_DESCRIC
					SN3->N3_VORIG1	:= SN3->N3_VORIG1 + IIF(Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_COMPL")=="S",IIF(!EMPTY(SD1->D1_ICMSCOM),SD1->D1_ICMSCOM,0),0)
					SN3->(MsUnLock("SN3"))

					SN1->(RecLock("SN1",.F.))
					SN1->N1_XUNID	:= SD1->D1_UM
					SN1->N1_VLAQUIS	:= SN3->N3_VORIG1
										
					//Jader Berto - Atualização
					if ZZ3->(dbSeek(xFilial("ZZ3")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM))
						SN1->N1_XODI := ZZ3->ZZ3_ODI 
						SN1->N1_XTI	 := ZZ3->ZZ3_TI
						SN1->N1_XCM	 := Replace(ZZ3->(ZZ3_CM1+ZZ3_CM2+ZZ3_CM3),' ','')
						SN1->N1_XTUC := ZZ3->ZZ3_TUC
						SN1->N1_XUAR := ZZ3->ZZ3_UAR
						SN1->N1_XA1	 := ZZ3->ZZ3_A1
						SN1->N1_XA2	 := ZZ3->ZZ3_A2
						SN1->N1_XA3	 := ZZ3->ZZ3_A3
						SN1->N1_XA4	 := ZZ3->ZZ3_A4
						SN1->N1_XA5	 := ZZ3->ZZ3_A5
						SN1->N1_XA6	 := ZZ3->ZZ3_A6
						SN1->N1_XIDUC:= ZZ3->ZZ3_IDUC
					EndIf
					SN1->(MsUnLock("SN3"))

				EndIf

				SN1->(DBSkip())

			EndDo

		EndIf
	EndIf

	bOk := .F.
	SD1->(DBSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	While !SD1->(EoF()) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

		SB1->(DBSeek(xFilial("SB1") + SD1->D1_COD))

		If SB1->B1_TIPO <> "SV" .And. AllTrim(SD1->D1_CC) $ cCCustos
			bOk := .T.
		EndIf

		SD1->(DBSkip())

	EndDo

	SD1->(DBSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

	If SubStr(SM0->M0_CODFIL, 1, 2) $ cEmpresas .And. (lIntRJ .Or. SubStr(SM0->M0_CODFIL, 3, 2) <> "01" )

		If bOk .And. (_nOpcao == 3 .OR. _nOpcao == 4) .AND. _nConfirm == 1

			/* Integração COSWIN - Início */
			//If Posicione("SF4", 1, xFilial("SF4") + SD1->D1_TES, "F4_ESTOQUE") == "S"

			//If !SZJ->(DBSeek(xFilial("SZJ") + SD1->D1_PEDIDO + "   PED" + SF1->F1_FORNECE + SF1->F1_LOJA))

			cQry := "SELECT MAX(ZJ_IDCOSWI) AS ZJ_IDCOSWI FROM "+RETSQLNAME("SZJ")+" SZJ"
			TCQUERY cQry ALIAS (cAlias) NEW

			cIDCoswin:= Soma1((cAlias)->ZJ_IDCOSWI)

			(cAlias)->(DbCloseArea())

			SZJ->(RecLock("SZJ",.T.))
			SZJ->ZJ_FILIAL	:= xFilial("SZJ")
			SZJ->ZJ_DOC		:= SF1->F1_DOC
			SZJ->ZJ_SERIE	:= SF1->F1_SERIE
			SZJ->ZJ_FORNEC	:= SF1->F1_FORNECE
			SZJ->ZJ_LOJA	:= SF1->F1_LOJA
			SZJ->ZJ_OPERACA	:= "I"
			SZJ->ZJ_INTEGRA	:= "N"
			SZJ->ZJ_IDCOSWI	:= cIDCoswin //GetSx8Num("SZJ","ZJ_IDCOSWI")
			SZJ->(MsUnLock("SZJ"))

			//EndIf

			//EndIf

			/* Integração COSWIN - Fim */

		ElseIf _nOpcao == 5 .AND. _nConfirm == 1

			/* Integração COSWIN - Início */

			SZJ->(DBSetOrder(1))

			If SZJ->(DBSeek(xFilial("SZJ") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

				If SZJ->ZJ_OPERACA = "I" .And. SZJ->ZJ_INTEGRA = "S"

					cIDCoswin	:= SZJ->ZJ_IDCOSWI

					SZJ->(RecLock("SZJ", .T.))
					SZJ->ZJ_FILIAL	:= xFilial("SZJ")
					SZJ->ZJ_DOC		:= SF1->F1_DOC
					SZJ->ZJ_SERIE	:= SF1->F1_SERIE
					SZJ->ZJ_FORNEC	:= SF1->F1_FORNECE
					SZJ->ZJ_LOJA	:= SF1->F1_LOJA
					SZJ->ZJ_OPERACA	:= "E"
					SZJ->ZJ_INTEGRA	:= "N"
					SZJ->ZJ_IDCOSWI	:= cIDCoswin
					SZJ->(MsUnLock("SZJ"))

				Else

					SZJ->(RecLock("SZJ", .F.))
					SZJ->(DBDelete())
					SZJ->(MsUnLock("SZJ"))

				EndIf

			EndIf

			/* Integração COSWIN - Fim */
		EndIf

	EndIf

	If _nOpcao == 5 .AND. _nConfirm == 1

		DbSelectArea("ZZK")
		DbSetOrder(1)
		ZZK->(DBSeek(xFilial("ZZK")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

		While !ZZK->(Eof()) .And. ZZK->(ZZK_DOC+ZZK_SERIE+ZZK_FORNEC+ZZK_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			ZZK->(RecLock("ZZK", .F.))
				ZZK->(DbDelete())
				ZZK->(MsUnLock())
			ZZK->(DbSkip())
		EndDo

		// Realização do Estorno dos movimentos manuais de ajuste de impostos
		SD1->(DbSetOrder(1))
		SD1->(DBSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		While !SD1->(EoF()) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

			U_EstMovMn() // Função que estornará os movimentos - Localizada no STAA074.prw

			SD1->(DBSkip())

		EndDo
		
	EndIf

	If _nOpcao == 4 .AND. _nConfirm == 1

		// Se for Nota Incluída por Célula de cadastro
		// e ainda não foi liberada para pagamento
		If SF1->F1_XCELNF == "S" .And. SF1->F1_XLIBPAG <> "S"
			//Envia alerta para o solicitante para liberar para o pagamento
			EnvAlerta()
		EndIf
		
	EndIf

		/*/Alexander dos Santos - 04/05/2022 
			Ajuste solicitado pela equipe de classificação de notas, 
			eles precisam do nome de quem classifcou a nf, o userlga - grava a ultima alteração 
			independente de qual seja, por isto este campo foi criado.
		/*/

	IF !FwIsInCallStack('U_STAA085') //Incluído pois não funciona com execauto da rotina de inclusão de notas de combustível.
		if (_nOpcao == 3 .or. _nOpcao == 4) .and.  _nConfirm == 1

			
			SF1->(RecLock("SF1", .F.))
			SF1->F1_XUSERCL := Substr(Alltrim(PswChave(RetCodUsr())),1,TamSX3("F1_XUSERCL")[1])
			SF1->F1_XDTINCP := DATE()

			If Type("_cMensag") <> "U"
				SF1->F1_XMENNOT:= _cMensag

				FWFREEVAR(@_cMensag)
			EndIf

			SF1->(MsUnLock())	
				
		endif
	ENDIF

	RestArea(_aArea)

	//Eduardo Coimbra - 19/05/2020
	//Realiza a Compensação automática dos adiantamentos do contrato

	/* Chamada desabilitada por Agenor - 05/05/2023 pois esta chamada não será mais usada.
	If lMVXCMPAC
		Processa( { || fCmpAC() }, "Realizando as Compensações automáticas dos adiantamentos do contrato padrão, aguarde...",, .T. )
	EndIf
	*/
	If lMVXCMPAM
		Processa( { || fCmpAM() }, "Realizando as Compensações automáticas dos adiantamentos de contrato multifilial, aguarde...",, .T. )
	EndIf
	If lMVXCMPC7
		Processa( { || fCmpC7() }, "Realizando as Compensações automáticas dos adiantamentos de pedido, aguarde...",, .T. )
	EndIf
	If lMVXCMPHL
		Processa( { || fCmpHOLD() }, "Realizando as Compensações automáticas dos adiantamentos em notas em Hold, aguarde...",, .T. )
	EndIf

Return

//Eduardo Coimbra - 19/05/2020
//Realiza a Compensação automática dos adiantamentos do contrato padrão

Static Function fCmpAC()
	Local aArea		:= GetArea()
	Local aAreaE2	:= SE2->(GetArea())
	Local lRet 		:= .F.
	Local cQry 		:= ""
	Local aTipos 	:= {"NF "}
	Local cTblTmp 	:= ""
	Local aNF 		:= {}
	Local aPA	 	:= {}
//	Local nSldComp 	:= 0
	Local nOpcao    := PARAMIXB[1]
	Local nConfirm	:= PARAMIXB[2]
//	Local lEstNF	:= .F.
	Local nY		:= 0
	Local aValCmp	:= {}
	Local cNF		:= ""
	Local cPA 		:= ""
	Local nSalPA	:= 0
	Local nSalNF	:= 0
	Local nVrComp	:= 0
	Local cFilPA	:= ""
	Local lPABloq	:= .F.
	Private xCO_PCO	:= ""
	Private xVal_PCO:= 0
	Private xCC_PCO	:= ""

	IF (nOpcao == 3 .Or. nOpcao == 4) .And. (nConfirm == 1)

		cQry := " SELECT TOP 1 "
		cQry += " E2_TIPO TIPO, R_E_C_N_O_ R_E_C_N_O_NF,E2_VALOR VALOR "
		cQry += " FROM "+RetSqlName("SE2")+" SE2"
		cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry += " AND E2_NUM      = '"+CNFISCAL+"'"
		cQry += " AND E2_PREFIXO  = '"+CSERIE+"'"
		cQry += " AND E2_FORNECE  = '"+CA100FOR+"'"
		cQry += " AND E2_LOJA     = '"+CLOJA+"'"
		cQry += " AND E2_ORIGEM   = 'MATA100'"
		cQry += " AND E2_TIPO IN (?)"
		cQry += " AND SE2.D_E_L_E_T_ = ''"
		cQry += " UNION ALL "
		cQry += "SELECT DISTINCT "
		cQry += "E2_TIPO TIPO, SE2.R_E_C_N_O_ R_E_C_N_O_A,CZY_VALOR VALOR "
		cQry += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("SC7")+" SC7, "+RETSQLNAME("CZY")+" CZY, "+RETSQLNAME("CNX")+" CNX, "+RETSQLNAME("SD1")+" SD1 "
		cQry += "WHERE "
		cQry += "SE2.D_E_L_E_T_ = '' AND SC7.D_E_L_E_T_ = '' AND CZY.D_E_L_E_T_ = '' AND CNX.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND "
		cQry += "E2_FILIAL = '"+XFILIAL("SE2")+"' AND C7_FILIAL = '"+XFILIAL("SC7")+"' AND CZY_FILIAL = '"+cFilAnt+"' AND CNX_FILIAL = '"+XFILIAL("CNX")+"' AND D1_FILIAL = '"+XFILIAL("SD1")+"' AND "
		cQry += "D1_DOC = '"+CNFISCAL+"' AND D1_SERIE = '"+CSERIE+"' AND D1_FORNECE = '"+CA100FOR+"' AND D1_LOJA = '"+CLOJA+"' AND "
		cQry += "C7_ITEM = D1_ITEMPC AND C7_NUM = D1_PEDIDO AND C7_FORNECE = D1_FORNECE AND C7_LOJA = D1_LOJA AND C7_PRODUTO = D1_COD AND "
		cQry += "C7_CONTRA = CNX_CONTRA AND CNX_REVGER = C7_CONTREV AND C7_FORNECE = CNX_FORNEC AND C7_LOJA = CNX_LJFORN AND "
		cQry += "C7_MEDICAO = CZY_NUMMED AND C7_PLANILH = CZY_NUMPLA AND "
		cQry += "CZY_CONTRA = C7_CONTRA AND CZY_REVISA = CNX_REVGER AND CNX_NUMERO = CZY_NUMERO AND "
		cQry += "E2_TIPO = 'PA' AND E2_PREFIXO = CNX_PREFIX AND E2_NUM = CNX_NUMTIT AND CNX_FORNEC = E2_FORNECE AND CNX_LJFORN = E2_LOJA AND E2_PARCELA = '' AND E2_ORIGEM = 'CNTA100' "
		cQry += "ORDER BY R_E_C_N_O_NF"

		cQry := ChangeQuery(cQry)
		__COMPAUT := FWPreparedStatement():New(cQry)

		__COMPAUT:SetIn(1, aTipos)
		cQry := __COMPAUT:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)

		While (cTblTmp)->(!Eof())
			If ((cTblTmp)->TIPO $ "PA ")
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aPA, {(cTblTmp)->R_E_C_N_O_NF})
					aAdd(aValCmp,(cTblTmp)->VALOR)
				EndIf
			Else
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aNF, (cTblTmp)->R_E_C_N_O_NF)
				EndIf
			EndIf

			(cTblTmp)->(DbSkip())
			lRet := .T.
		EndDo

		(cTblTmp)->(DbCloseArea())
		cTblTmp := ""

		if lRet .And. !Empty(aNF) .And. !Empty(aPA)

			For nY := 1 to Len(aPA)

				Pergunte("AFI340", .F.)
				lContabiliza := MV_PAR11 == 1
				lAglutina := MV_PAR08 == 1
				lDigita := MV_PAR09 == 1

				dbSelectArea("SE2")
				dbSetOrder(1)

				SE2->(dbGoTo(aPA[nY,1]))
				nSalPA	:= SE2->E2_SALDO
				cPA		:= SE2->E2_NUM
				cFilPA	:= SE2->E2_FILIAL

				If Empty(SE2->E2_DATALIB)
					lPABloq := .T.
				EndIf

				//Caso o PA não tenha movimentação, a compensacao nao sera executada.
				If Alltrim(SE2->E2_TIPO) $ MVPAGANT .and. !U_Fx340PA(Nil, "SE2",.F.)[1]
					Help(" ",1,"NOMOVADT",,"Não é possível compensar pagamento antecipado sem movimentação bancária.")  //"Não é possível compensar pagamento antecipado sem movimentação bancária."

					//Notifica requisitante do erro na compensação
					U_MTMAILCP()

					DisarmTransaction()

					Return (.F.)
				Endif				

				dbGoTo(aNF)

				cNF := SE2->E2_NUM

				RecLock("SE2",.F.)
				SE2->E2_XVALCMP := aValCmp[nY]
				MsUnlock()

				nVrComp	:= aValCmp[nY]

				If nVrComp > nSalNF
					nVrComp := nSalNF
				EndIf
				If nVrComp > nSalPA
					nVrComp := nSalPA
				EndIf

				If lPABloq
					Aviso("Compensação Automática","A compensação automática da NF "+SE2->E2_NUM+" com o adiantamento "+cPA+" não foi realizada. Verifique se o PA está liberado e se já foi pago.",{"OK"})
					Loop
				EndIf

				dbGoTo(aNF[1])

				//lRet := MaIntBxCP(2,aNF,,aPA[nY],,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,aValCmp[nY],dDatabase)

				_aParametrosJob := {cFilPA, aNF, aPA[nY], {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.}, nVrComp, dDatabase}
				//lRet 			:= StartJob( "U_CompAuto", GetEnvServer(), .T. , _aParametrosJob )
				lRet 			:= U_CompAuto(_aParametrosJob )

				SE2->(dbGoTo(aPA[nY,1]))

				If (nSalPA == SE2->E2_SALDO)
					Aviso("Compensação Automática","A compensação automática da NF "+cNF+" com o adiantamento "+SE2->E2_NUM+" via contrato não foi realizada. Verificar o título de adiantamento no financeiro.",{"OK"})
				EndIf

				xCO_PCO		:= SE2->E2_XCO
				xVal_PCO	:= aValCmp[nY]
				xCC_PCO		:= SE2->E2_CCD

				PcoIniLan("000017")
				PcoDetLan("000017", "03", "FINA340")
				PcoFinLan("000017")

			Next nY

			If lRet

			Else
				MostraErro()
				//Alert("Ocorreu um erro no processo de compensação")
			EndIf

		EndIf

	EndIf

	if FunName() == "MATA140"
		Pergunte("MTA140", .F.)
	Else
		Pergunte("MTA103", .F.)
	EndIf

	RestArea(aAreaE2)
	RestArea(aArea)

Return()

Static Function fEstPreNF()
	Local aArea			:= GetArea()
	Local aAreaD1		:= SD1->(GetArea())
	Local lEstNF		:= .T.
	Private aCabec      := {}
	Private aItens      := {}
	Private aLinha      := {}
	Private lMsErroAuto := .F.

	aAdd(aCabec,{'F1_TIPO',SF1->F1_TIPO,NIL})
	aAdd(aCabec,{'F1_FORMUL',SF1->F1_FORMUL,NIL})
	aAdd(aCabec,{'F1_DOC',SF1->F1_DOC,NIL})
	aAdd(aCabec,{"F1_SERIE",SF1->F1_SERIE,NIL})
	aAdd(aCabec,{"F1_EMISSAO",SF1->F1_EMISSAO,NIL})
	aAdd(aCabec,{'F1_FORNECE',SF1->F1_FORNECE,NIL})
	aAdd(aCabec,{'F1_LOJA',SF1->F1_LOJA,NIL})
	aAdd(aCabec,{"F1_ESPECIE",SF1->F1_ESPECIE,NIL})
	aAdd(aCabec,{"F1_COND",SF1->F1_COND,NIL})
	aAdd(aCabec,{"F1_STATUS",SF1->F1_STATUS,NIL})

	SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

	While SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		aAdd(aItens,{'D1_COD',SD1->D1_COD,NIL})
		aAdd(aItens,{"D1_QUANT",SD1->D1_QUANT,Nil})
		aAdd(aItens,{"D1_VUNIT",SD1->D1_VUNIT,Nil})
		aAdd(aItens,{"D1_TOTAL",SD1->D1_TOTAL,Nil})
		aAdd(aItens,{"D1_TES",SD1->D1_TES,NIL})

		aAdd(aLinha,aItens)

		aItens := {}

		SD1->(dbSkip())
	EndDo

	lMsErroAuto := .F.

	MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, 7,,)

	If lMsErroAuto
		lEstNF := .F.
		Mostraerro()
	Else
		//Alert("Execauto MATA140 executado com sucesso!")
	EndIf

	RestArea(aAreaD1)
	RestArea(aArea)
Return(lEstNF)

User Function xPCO17(nOpc)
	Local xRet		:= ""
	Local nValCpdo	:= 0

	if nOpc == 1
		if ISINCALLSTACK('FINA340') 
			xRet := SE2->E2_XCO
		elseif Type("xCO_PCO") <> "U" 
			xRet := xCO_PCO
		Else
			xRet := ""
		EndIf
	ElseIf nOpc == 2
		xRet 	 := 0
		nValCpdo := 0
		IF ISINCALLSTACK('FINA340') 
			if AKC->AKC_PROCESS == '000017' .and. ( (AKC->AKC_ITEM == '04' .AND. AKC->AKC_SEQ == '04') .OR. ( AKC->AKC_ITEM == '05' .AND. AKC->AKC_SEQ == '03' ) )
//			  	.AND. 	(SE2->E2_PREFIXO <> 'SPG'	.AND. SE2->E2_PREFIXO <> 'PCA')
				nValCpdo := U_xMedComp() 
		  		IF nValCpdo > 0
					IF(SE5->E5_MOEDA > '01')
						xRet := SE5->E5_VALOR * SE5->E5_TXMOEDA
					ELSE
						xRet := SE5->E5_VALOR
					ENDIF
				ELSE
					xRet := 0
				endif	
			else	
				IF(SE5->E5_MOEDA > '01')
					xRet := SE5->E5_VALOR * SE5->E5_TXMOEDA
				ELSE
					xRet := SE5->E5_VALOR
				ENDIF
			endif	 
		elseif Type("xVal_PCO") <> "U" 
			xRet := xVal_PCO
		Else
			xRet := 0
		Endif

	ElseIf nOpc == 3
		if ISINCALLSTACK('FINA340')
			xRet := SE2->E2_CCD
		elseif Type("xCC_PCO") <> "U" 
			xRet := xCC_PCO
		Else
			xRet := ""
		EndIf
	EndIf

Return(xRet)

//Eduardo Coimbra - 24/06/2020
//Realiza a Compensação automática dos adiantamentos do contrato customizado

Static Function fCmpAM()
	Local aArea		:= GetArea()
	Local aAreaE2	:= SE2->(GetArea())
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local lRet 		:= .F.
	Local cQry 		:= ""
	Local aTipos 	:= {"NF "}
	Local cTblTmp 	:= ""
	Local aNF 		:= {}
	Local aPA	 	:= {}
//	Local nSldComp 	:= 0
	Local nOpcao    := PARAMIXB[1]
	Local nConfirm	:= PARAMIXB[2]
//	Local lEstNF	:= .F.
	Local nY		:= 0
	Local aValCmp	:= {}
	Local cNF		:= ""
	Local lPABloq	:= .F.
	Local cPA		:= ""
	Local nSalPA	:= 0
	Local nSalNF	:= 0
	Local nVrComp	:= 0
	Local cFilPA	:= ""
	Private xCO_PCO	:= ""
	Private xVal_PCO:= 0
	Private xCC_PCO	:= ""

	IF (nOpcao == 3 .Or. nOpcao == 4) .And. (nConfirm == 1)

		cQry := " SELECT TOP 1 "
		cQry += " E2_TIPO TIPO, R_E_C_N_O_ R_E_C_N_O_NF,E2_VALOR VALOR, '0' ZZ1RECNO "
		cQry += " FROM "+RetSqlName("SE2")+" SE2"
		cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry += " AND E2_NUM      = '"+CNFISCAL+"'"
		cQry += " AND E2_PREFIXO  = '"+CSERIE+"'"
		cQry += " AND E2_FORNECE  = '"+CA100FOR+"'"
		cQry += " AND E2_LOJA     = '"+CLOJA+"'"
		cQry += " AND E2_ORIGEM   = 'MATA100'"
		cQry += " AND E2_TIPO IN (?)"
		cQry += " AND SE2.D_E_L_E_T_ = ''"
		cQry += " UNION ALL "

		cQry += "SELECT DISTINCT "
		cQry += "E2_TIPO TIPO, SE2.R_E_C_N_O_ R_E_C_N_O_A,ZZ1_VLCOMP VALOR,  ZZ1.R_E_C_N_O_ ZZ1RECNO "
		cQry += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("SC7")+" SC7, "+RETSQLNAME("ZZ0")+" ZZ0, "+RETSQLNAME("ZZ1")+" ZZ1, "+RETSQLNAME("SD1")+" SD1 "
		cQry += "WHERE "
		cQry += "SE2.D_E_L_E_T_ = '' AND SC7.D_E_L_E_T_ = '' AND ZZ0.D_E_L_E_T_ = '' AND ZZ1.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND "

		cQry += "E2_FILIAL = ZZ0_FILDES AND C7_FILENT = '"+XFILIAL("SC7")+"' AND ZZ1_FILDES = ZZ0_FILDES AND "
		cQry += "D1_FILIAL = '"+XFILIAL("SD1")+"' AND " // ZZ1_FILIAL = '"+XFILIAL("ZZ1")+"' AND "

		cQry += "D1_DOC = '"+CNFISCAL+"' AND D1_SERIE = '"+CSERIE+"' AND D1_FORNECE = '"+CA100FOR+"' AND D1_LOJA = '"+CLOJA+"' AND "
		cQry += "C7_ITEM = D1_ITEMPC AND C7_NUM = D1_PEDIDO AND C7_FORNECE = D1_FORNECE AND C7_LOJA = D1_LOJA AND C7_PRODUTO = D1_COD AND "
		//cQry += "C7_CONTRA = ZZ0_CONTRA AND ZZ0_REVISA = C7_CONTREV AND C7_FORNECE = ZZ0_FORNEC AND C7_LOJA = ZZ0_LOJA AND "
		cQry += "C7_CONTRA = ZZ0_CONTRA AND "
		cQry += "C7_MEDICAO = ZZ1_NUMMED AND "
//		cQry += "C7_PLANILH = ZZ1_NUMPLA AND "
		cQry += "ZZ1_CONTRA = C7_CONTRA AND ZZ1_REVISA = ZZ0_REVISA AND ZZ0_NUMERO = ZZ1_NUMERO AND "
		cQry += "E2_XCHVZZ0 = ZZ0_CONTRA+ZZ0_REVISA+SUBSTRING(ZZ0_FILIAL,1,2)+ZZ0_NUMERO AND ZZ1_PROCHL <> 'S' "
		cQry += "ORDER BY R_E_C_N_O_NF"

		cQry := ChangeQuery(cQry)
		__COMPAUT := FWPreparedStatement():New(cQry)

		__COMPAUT:SetIn(1, aTipos)
		cQry := __COMPAUT:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)

		While (cTblTmp)->(!Eof())
			If ((cTblTmp)->TIPO $ "PA ")
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aPA, {(cTblTmp)->R_E_C_N_O_NF})
					aAdd(aValCmp,{(cTblTmp)->VALOR,(cTblTmp)->ZZ1RECNO})
				EndIf
			Else
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aNF, (cTblTmp)->R_E_C_N_O_NF)
				EndIf
			EndIf

			(cTblTmp)->(DbSkip())
			lRet := .T.
		EndDo

		(cTblTmp)->(DbCloseArea())
		cTblTmp := ""

		if lRet .And. !Empty(aNF) .And. !Empty(aPA)

		Begin Transaction

			//Libera os títulos da nota fiscal.
			U_LibTitCom(aNF[1])	

			For nY := 1 to Len(aPA)

				Pergunte("AFI340", .F.)
				lContabiliza := MV_PAR11 == 1
				lAglutina := MV_PAR08 == 1
				lDigita := MV_PAR09 == 1

				MV_PAR05	:= 1
				MV_PAR06	:= "0101"
				MV_PAR07	:= "9999"

				dbSelectArea("SE2")
				dbSetOrder(1)

				SE2->(dbGoTo(aPA[nY,1]))
				nSalPA	:= SE2->E2_SALDO
				cPA		:= SE2->E2_NUM
				cFilPA	:= SE2->E2_FILIAL

				If Empty(SE2->E2_DATALIB)
					lPABloq := .T.
				EndIf

				//Caso o PA não tenha movimentação, a compensacao nao sera executada.
				If Alltrim(SE2->E2_TIPO) $ MVPAGANT .and. !U_Fx340PA(Nil, "SE2",.F.)[1]
					Help(" ",1,"Não é possível compensar pagamento antecipado de número: "+cPA+" Valor: "+rtrim(ltrim(str(TRANSFORM(aValCmp[nY], "@E 999,999,999.99")))) +"sem movimentação bancária.")  //"Não é possível compensar pagamento antecipado sem movimentação bancária."
			
					//Notifica requisitante do erro na compensação
					U_MTMAILCP()

					DisarmTransaction()
					Return (.F.)
				Endif				

				dbGoTo(aNF[1])

				nSalNF		:= SE2->E2_SALDO - SF1->F1_VALPIS - SF1->F1_VALCOFI - SF1->F1_VALCSLL
				nNFValRet 	:= SE2->(E2_VRETPIS+E2_VRETCSL+E2_VRETCOF)
				nSalNFTOT	:= SE2->E2_SALDO 
				cNF 		:= SE2->E2_NUM
				cFilNF		:= SE2->E2_FILIAL 

				RecLock("SE2",.F.)
				SE2->E2_XVALCMP := aValCmp[nY][1]
				MsUnlock()

				If lPABloq 
					Aviso("Compensação Automática","A compensação automática da NF "+SE2->E2_NUM+" com o adiantamento "+cPA+" não foi realizada. Verifique se o PA está liberado e se já foi pago.",{"OK"})
								
					//Notifica requisitante do erro na compensação
					U_MTMAILCP()

					DisarmTransaction()
					Loop
				EndIf

				nVrComp	:= aValCmp[nY][1]

				If nVrComp > nSalNF
					nVrComp := nSalNF
				EndIf
				If nVrComp > nSalPA
					nVrComp := nSalPA
				EndIf

				nValLiq := SE2->E2_VALLIQ

				//lRet := FinCmpAut(aNF, aPA[nY], {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,, nVrComp, dDatabase)
				_aParametrosJob := {cFilPA, aNF, aPA[nY], {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.}, nVrComp, dDatabase, cFilNF}
//				lRet 			:= StartJob( "U_CompAuto", GetEnvServer(), .T. , _aParametrosJob )
				lRet 			:= U_CompAuto(_aParametrosJob)

				//Posiciona na nota fiscal para validar os saldos
				SE2->(dbGoTo(aNf[1]))
				IF (round(nSalNFTOT-nVrComp-(SE2->(E2_VRETPIS+E2_VRETCSL+E2_VRETCOF)-nNFValRet) ,0) <> round(SE2->E2_SALDO,0)) 
					Aviso("Compensação Automática","A compensação automática da NF "+cNF+" com o adiantamento "+SE2->E2_NUM+" não foi realizada, informar ao requisitante. Verificar o título de adiantamento no financeiro.",{"OK"})					
					//Notifica requisitante do erro na compensação
					U_MTMAILCP()
					DisarmTransaction()							
				endif

				//Posiciona no PA para validar os saldos
				SE2->(dbGoTo(aPA[nY,1]))
				If (nSalPA == SE2->E2_SALDO) 
					Aviso("Compensação Automática","A compensação automática da NF "+cNF+" com o adiantamento "+SE2->E2_NUM+" via contrato não foi realizada. Verificar o título de adiantamento no financeiro.",{"OK"})
					//Notifica requisitante do erro na compensação
					U_MTMAILCP()
					DisarmTransaction()
				EndIf


				//Verifica se o valor compensado é menor que o valor original e atualiza a ZZ1.
				DbSelectArea("ZZ1")
				DbGoTo(aValCmp[nY][2])
				IF ZZ1->ZZ1_VLCOMP <> nVrComp
					ZZ1->(RecLock("ZZ1",.F.))
						ZZ1->ZZ1_VLCOMP := nVrComp
					ZZ1->(MsUnlock())
				ENDIF
				

				xCO_PCO		:= SE2->E2_XCO
				xVal_PCO	:= aValCmp[nY][1]
				xCC_PCO		:= SE2->E2_CCD

				/*
				PcoIniLan("000017")
				PcoDetLan("000017", "03", "FINA340")
				PcoFinLan("000017")
				*/
				
				cQuery := "SELECT E2_XCHVZZ0,E2_SALDO FROM "+RETSQLNAME("SE2")+" WHERE R_E_C_N_O_ = "+AllTrim(Str(aPA[nY][1]))
				TCQuery cQuery NEW ALIAS (cAlias)

				nChvZZ0 := (cAlias)->E2_XCHVZZ0
				nSaldPA := (cAlias)->E2_SALDO

				(cAlias)->(dbCloseArea())

				cQuery := "UPDATE "+RETSQLNAME("ZZ0")+" SET ZZ0_SALDO = "+AllTrim(Str(nSaldPA))+" WHERE "
				cQuery += "ZZ0_CONTRA+ZZ0_REVISA+SUBSTRING(ZZ0_FILIAL,1,2)+ZZ0_NUMERO = '"+nChvZZ0+"'"

				if TCSQLExec(cQuery) < 0
					Aviso("Erro SQL",TCSQLError(),{"OK"})
				EndIf

			Next nY

			If !lRet
				MostraErro()
				//Alert("Ocorreu um erro no processo de compensação")
			Else
				//Nova função para tratar a liberação do título. Incluído no Begin Transaction para executar o rollback caso ocorra algum problema na compensação				
				fLibSE2()
			EndIf
			
			END TRANSACTION

		EndIf

	EndIf

	if FunName() == "MATA140"
		Pergunte("MTA140", .F.)
	Else
		Pergunte("MTA103", .F.)
	EndIf

	RestArea(aAreaE2)
	RestArea(aArea)

Return()

Static Function fCmpC7()
	Local aArea		:= GetArea()
	Local aAreaE2	:= SE2->(GetArea())
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local lRet 		:= .F.
	Local cQry 		:= ""
	Local aTipos 	:= {"NF "}
	Local cTblTmp 	:= ""
	Local aNF 		:= {}
	Local aPA	 	:= {}
//	Local nSldComp 	:= 0
	Local nOpcao    := PARAMIXB[1]
	Local nConfirm	:= PARAMIXB[2]
//	Local lEstNF	:= .F.
	Local nY		:= 0
	Local aValCmp	:= {}
	Local nSalPA	:= 0
	Local cNF		:= ""
	Local cPA		:= ""
	Local nSalNF	:= 0
	Local nVrComp	:= 0
	Local cFilPA	:= ""
	Local lPABloq	:= .F.
	Local cError   := ""
	Local bError   := ErrorBlock({ |oError| cError := oError:Description})
	Private xCO_PCO	:= ""
	Private xVal_PCO:= 0
	Private xCC_PCO	:= ""

	IF (nOpcao == 3 .Or. nOpcao == 4) .And. (nConfirm == 1)

		cQry := " SELECT TOP 1 "
		cQry += " E2_TIPO TIPO, R_E_C_N_O_ R_E_C_N_O_NF,E2_VALOR VALOR, '0' ZZ1RECNO "
		cQry += " FROM "+RetSqlName("SE2")+" SE2"
		cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry += " AND E2_NUM      = '"+CNFISCAL+"'"
		cQry += " AND E2_PREFIXO  = '"+CSERIE+"'"
		cQry += " AND E2_FORNECE  = '"+CA100FOR+"'"
		cQry += " AND E2_LOJA     = '"+CLOJA+"'"
		cQry += " AND E2_ORIGEM   = 'MATA100'"
		cQry += " AND E2_TIPO IN (?)"
		cQry += " AND SE2.D_E_L_E_T_ = ''"
		cQry += " UNION ALL "

		cQry += "SELECT DISTINCT "
		cQry += "E2_TIPO TIPO, SE2.R_E_C_N_O_ R_E_C_N_O_A,ZZ1_VLCOMP VALOR,  ZZ1.R_E_C_N_O_ ZZ1RECNO  "
		cQry += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("SC7")+" SC7, "+RETSQLNAME("ZZ0")+" ZZ0, "+RETSQLNAME("ZZ1")+" ZZ1, "+RETSQLNAME("SD1")+" SD1 "
		cQry += "WHERE "
		cQry += "SE2.D_E_L_E_T_ = '' AND SC7.D_E_L_E_T_ = '' AND ZZ0.D_E_L_E_T_ = '' AND ZZ1.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND "

		cQry += "E2_FILIAL = ZZ0_FILDES AND C7_FILENT = '"+XFILIAL("SC7")+"' AND ZZ1_FILDES = ZZ0_FILDES AND "
		cQry += "D1_FILIAL = '"+XFILIAL("SD1")+"' AND  ZZ1_FILIAL = '"+XFILIAL("ZZ1")+"' AND "

		cQry += "D1_DOC = '"+CNFISCAL+"' AND D1_SERIE = '"+CSERIE+"' AND D1_FORNECE = '"+CA100FOR+"' AND D1_LOJA = '"+CLOJA+"' AND "
		cQry += "C7_ITEM = D1_ITEMPC AND C7_NUM = D1_PEDIDO AND C7_FORNECE = D1_FORNECE AND C7_LOJA = D1_LOJA AND C7_PRODUTO = D1_COD AND "
		cQry += "C7_CONTRA = '' AND C7_CONTREV = '' AND C7_FORNECE = ZZ0_FORNEC AND C7_LOJA = ZZ0_LOJA AND "
		cQry += "C7_MEDICAO = '' AND ZZ1_NUMMED = '' AND C7_PLANILH = '' AND ZZ1_NUMPLA = '' AND "
		cQry += "ZZ1_CONTRA = ZZ0_CONTRA AND ZZ1_REVISA = ZZ0_REVISA AND ZZ0_NUMERO = ZZ1_NUMERO AND "
		cQry += "ZZ0_REVISA = 'SC7' AND LTRIM(ZZ0_CONTRA) = 'SC7'+C7_FILIAL+C7_NUM AND "
		cQry += "E2_XCHVZZ0 = ZZ0_CONTRA+ZZ0_REVISA+SUBSTRING(ZZ0_FILIAL,1,2)+ZZ0_NUMERO AND ZZ1_PROCHL <> 'S' "
		cQry += "AND ZZ1_SF1 = '"+SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"' "
		cQry += "ORDER BY R_E_C_N_O_NF "

		cQry := ChangeQuery(cQry)
		__COMPAUT := FWPreparedStatement():New(cQry)

		__COMPAUT:SetIn(1, aTipos)
		cQry := __COMPAUT:GetFixQuery() 
		cTblTmp := MpSysOpenQuery(cQry)

		While (cTblTmp)->(!Eof())
			If ((cTblTmp)->TIPO $ "PA ")
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aPA, {(cTblTmp)->R_E_C_N_O_NF})					
					aAdd(aValCmp,{(cTblTmp)->VALOR,(cTblTmp)->ZZ1RECNO})
				EndIf
			Else
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aNF, (cTblTmp)->R_E_C_N_O_NF)
				EndIf
			EndIf

			(cTblTmp)->(DbSkip())
			lRet := .T.
		EndDo

		(cTblTmp)->(DbCloseArea())
		cTblTmp := ""


		if lRet .And. !Empty(aNF) .And. !Empty(aPA)

		Begin Transaction

			//Libera os títulos da nota fiscal.
			U_LibTitCom(aNF[1])

			For nY := 1 to Len(aPA)

				Pergunte("AFI340", .F.) 
				lContabiliza := MV_PAR11 == 1
				lAglutina := MV_PAR08 == 1
				lDigita := MV_PAR09 == 1

				dbSelectArea("SE2")
				dbSetOrder(1)

				SE2->(dbGoTo(aPA[nY,1]))
				nSalPA	:= SE2->E2_SALDO
				cPA		:= SE2->E2_NUM
				cFilPA	:= SE2->E2_FILIAL

				//Caso o PA não tenha movimentação, a compensacao nao sera executada.
				If Alltrim(SE2->E2_TIPO) $ MVPAGANT .and. !U_Fx340PA(Nil, "SE2",.F.)[1]

					Help(" ",1,"Não é possível compensar pagamento antecipado sem movimentação bancária.")  //"Não é possível compensar pagamento antecipado sem movimentação bancária."

					//Notifica requisitante do erro na compensação
					U_MTMAILCP()

					DisarmTransaction()
					Return (.F.)
				Endif


				If Empty(SE2->E2_DATALIB)
					lPABloq := .T.
				EndIf

				nSalPA := SE2->E2_SALDO

				dbGoTo(aNF[1])

				nSalNF		:= SE2->E2_SALDO - SF1->F1_VALPIS - SF1->F1_VALCOFI - SF1->F1_VALCSLL
				nNFValRet 	:= SE2->(E2_VRETPIS+E2_VRETCSL+E2_VRETCOF)
				nSalNFTOT	:= SE2->E2_SALDO 
				cFilNF		:= SE2->E2_FILIAL
				
				RecLock("SE2",.F.)
				SE2->E2_XVALCMP := aValCmp[nY][1]
				MsUnlock()

				If lPABloq
					Aviso("Compensação Automática","A compensação automática da NF "+SE2->E2_NUM+" com o adiantamento "+cPA+" não foi realizada. Verifique se o PA está liberado e se já foi pago.",{"OK"})
								
					//Notifica requisitante do erro na compensação
					U_MTMAILCP()

					DisarmTransaction()
					Loop
				EndIf

				nVrComp	:= aValCmp[nY][1]

				If nVrComp > nSalNF
					nVrComp := nSalNF
				EndIf
				If nVrComp > nSalPA
					nVrComp := nSalPA
				EndIf

				nValLiq := SE2->E2_VALLIQ

				//lRet := MaIntBxCP(2,aNF,,aPA[nY],,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,aValCmp[nY],dDatabase)
				//lRet := FinCmpAut(aNF, aPA[nY], {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,, nVrComp, dDatabase)

				_aParametrosJob := {cFilPA, aNF, aPA[nY], {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.}, nVrComp, dDatabase, cFilNF}
				//lRet 			:= StartJob( "U_CompAuto", GetEnvServer(), .T. , _aParametrosJob )
				lRet 			:= U_CompAuto(_aParametrosJob )

				SE2->(dbGoTo(aNf[1]))
				
				If (round(nSalNFTOT-nVrComp-(SE2->(E2_VRETPIS+E2_VRETCSL+E2_VRETCOF)-nNFValRet) ,0) <> round(SE2->E2_SALDO,0)) 
					Aviso("Compensação Automática","A compensação automática da NF "+cNF+" com o adiantamento "+SE2->E2_NUM+" não foi realizada, informar ao requisitante. Verificar o título de adiantamento no financeiro.",{"OK"})					
					//Notifica requisitante do erro na compensação
					U_MTMAILCP()
					DisarmTransaction()
					Return (.F.)				
				endif



				//Posiciona no PA e verifica o saldo
				SE2->(dbGoTo(aPA[nY,1]))
				If (nSalPA == SE2->E2_SALDO) 
					Aviso("Compensação Automática","A compensação automática da NF "+cNF+" com o adiantamento "+SE2->E2_NUM+" não foi realizada. Verificar o título de adiantamento no financeiro.",{"OK"})					
					//Notifica requisitante do erro na compensação
					U_MTMAILCP()
					DisarmTransaction()		
					Return (.F.)			
				Else

				//Verifica se o valor compensado é menor que o valor original e atualiza a ZZ1.
				DbSelectArea("ZZ1")
				DbGoTo(aValCmp[nY][2])
				IF ZZ1->ZZ1_VLCOMP <> nVrComp
					ZZ1->(RecLock("ZZ1",.F.))
						ZZ1->ZZ1_VLCOMP := nVrComp
					ZZ1->(MsUnlock())
				ENDIF
				

					xCO_PCO		:= SE2->E2_XCO
					xVal_PCO	:= aValCmp[nY][1]
					xCC_PCO		:= SE2->E2_CCD

					/*
					PcoIniLan("000017")
					PcoDetLan("000017", "03", "FINA340")
					PcoFinLan("000017")
					*/	
					cQuery := "SELECT E2_XCHVZZ0,E2_SALDO FROM "+RETSQLNAME("SE2")+" WHERE R_E_C_N_O_ = "+AllTrim(Str(aPA[nY][1]))
					TCQuery cQuery NEW ALIAS (cAlias)

					nChvZZ0 := (cAlias)->E2_XCHVZZ0
					nSaldPA := (cAlias)->E2_SALDO

					(cAlias)->(dbCloseArea())

					cQuery := "UPDATE "+RETSQLNAME("ZZ0")+" SET ZZ0_SALDO = "+AllTrim(Str(nSaldPA))+" WHERE "
					cQuery += "ZZ0_CONTRA+ZZ0_REVISA+SUBSTRING(ZZ0_FILIAL,1,2)+ZZ0_NUMERO = '"+nChvZZ0+"'"

					if TCSQLExec(cQuery) < 0
						Aviso("Erro SQL",TCSQLError(),{"OK"})
					EndIf
				EndIf

			Next nY

			If !lRet
				MostraErro()
				//Alert("Ocorreu um erro no processo de compensação")
			Else
				//Nova função para tratar a liberação do título. Incluído no Begin Transaction para executar o rollback caso ocorra algum problema na compensação				
				fLibSE2()
			EndIf


		
			END TRANSACTION

		EndIf

	

	EndIf

	if FunName() == "MATA140"
		Pergunte("MTA140", .F.)
	Else
		Pergunte("MTA103", .F.)
	EndIf

	RestArea(aAreaE2)
	RestArea(aArea)

Return()



Static Function EnvAlerta()

Local aFiles := {}

	If UPPER(GetEnvServer()) == 'STATEGRID' .OR. UPPER(GetEnvServer()) == 'STATEGRID_EN'
		cEmailAprov := UsrRetMail(SF1->F1_XREQUIS)
	Else
		cEmailAprov := UsrRetMail(SF1->F1_XREQUIS)+";marcos.silva@stategrid.com.br"
	EndIf

	cTitle	:= OEMTOANSI("Nota fiscal classificada - " + LTRIM(SF1->F1_DOC) )

	aMsg := {}

	SA2->(DbSetOrder(1))
	SA2->(DBSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))

	AADD(aMsg, '<font font size="7" color="green">Nota fiscal classificada.</font>' )
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Prezado(a), " + UsrFullName(SF1->F1_XREQUIS))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "A Nota fiscal foi classificada. A mesma está aguardando a liberação para pagamento.") 
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, Dtoc(MSDate()) + " - " + Time() + '</b>')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Usuário Responsável.......... " + UsrFullName(retcodusr()) )
	AADD(aMsg, "Empresa.................................. " + SF1->F1_FILIAL)
	AADD(aMsg, "Número do Documento........... " + LTRIM(SF1->F1_DOC))
	AADD(aMsg, "Série......................................... " + LTRIM(SF1->F1_SERIE))
	AADD(aMsg, "Código do Fornecedor............. " + LTRIM(SF1->F1_FORNECE))
	AADD(aMsg, "Nome do Fornecedor............. " + LTRIM(SA2->A2_NOME))
	AADD(aMsg, "Data de entrega para o fiscal... "+ DTOC(SF1->F1_RECBMTO))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<font font size="7" color="green">Classified Invoice</font>' )
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Dear, " + UsrFullName(SF1->F1_XREQUIS))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "The Invoice has been sorted. It is awaiting release for payment.")           
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, Dtoc(MSDate()) + " - " + Time() + '</b>')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Responsable operator.......... " + UsrFullName(retcodusr()) )
	AADD(aMsg, "Company.............................. " + SF1->F1_FILIAL)
	AADD(aMsg, "Document number............... " + LTRIM(SF1->F1_DOC))
	AADD(aMsg, "Serie...................................... " + LTRIM(SF1->F1_SERIE))
	AADD(aMsg, "Supplier code........................ " + LTRIM(SF1->F1_FORNECE))
	AADD(aMsg, "Supplier name.................. " + LTRIM(SA2->A2_NOME))
	AADD(aMsg, "Delivery Date to TAX............. "+ DTOC(SF1->F1_RECBMTO))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')

	MSGRUN( "Enviando e-mail para a célula de classificação", "Enviando", {||U_STAAX11(cEmailAprov, cTitle, aMsg, aFiles)} )						

Return




User Function Fx340PA(aMovPA As Array, cTbl As Character, lVerMov As Logical) As Array 
Local cQry      As Character
Local cTblTmp   As Character
Local aArea     As Array
Local cCampoChq As Character 
//Local __oMovCnb :=  Nil
Local __oMovPA 	:=  Nil

Default aMovPA  := {.F., dDataBase, ""}
Default cTbl    := "SE2"
Default lVerMov := .T.

//Inicializa variáveis
cQry 	  := ""
cTblTmp   := ""
cCampoChq := Padr("", TamSX3("E5_NUMCHEQ")[1])
aArea     := GetArea()

cQry := "SELECT E5_DATA, E5_TIPODOC FROM " + RetSqlName("SE5") + " "
cQry += "WHERE E5_FILIAL = ? AND E5_PREFIXO = ? AND "
cQry += "E5_NUMERO = ? AND E5_PARCELA = ? AND "
cQry += "E5_TIPO = ? AND E5_CLIFOR = ? AND E5_LOJA = ? AND "
cQry += "((E5_TIPODOC = 'PA' ) OR (E5_TIPODOC = 'BA' AND E5_NUMCHEQ <> '" + cCampoChq + "' ) OR "
cQry += "(E5_TIPODOC = 'CH' AND E5_NUMCHEQ <> '" + cCampoChq + "')) AND "
cQry += "E5_RECPAG = 'P' AND E5_SITUACA = ' ' AND D_E_L_E_T_ = ' ' "
cQry := ChangeQuery(cQry)
__oMovPA := FWPreparedStatement():New(cQry)

	__oMovPA:SetString(1, xFilial("SE5", (cTbl)->E2_FILORIG))
	__oMovPA:SetString(2, (cTbl)->E2_PREFIXO)
	__oMovPA:SetString(3, (cTbl)->E2_NUM)
	__oMovPA:SetString(4, (cTbl)->E2_PARCELA)
	__oMovPA:SetString(5, (cTbl)->E2_TIPO)
	__oMovPA:SetString(6, (cTbl)->E2_FORNECE)
	__oMovPA:SetString(7, (cTbl)->E2_LOJA)

	cQry := __oMovPA:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQry)

(cTblTmp)->(DbGotop())

If (cTblTmp)->(!Eof())
	dDtMov := If(Empty((cTblTmp)->E5_DATA), dDataBase, STOD((cTblTmp)->E5_DATA))
	aMovPA := {.T., dDtMov, (cTblTmp)->E5_TIPODOC}
EndIf

(cTblTmp)->(DbCloseArea())
RestArea(aArea)

Return aMovPA


User Function MTMAILCP(lEstClass, nRecNoPA)

	Local aMsg			:= {}
	Local aFiles		:= {}
	Local cTitulo		:= "Erro na compensação automática"

	Default lEstClass	:= .F.
	Default nRecNoPA	:= 0

	cUserMail := UsrRetMail(SF1->F1_XREQUIS)
	cUserMail += ";agenor.junior@stategrid.com.br"
	cUserMail += ";rodrigo.miras@stategrid.com.br"
	cUserMail += ";marcos.silva@stategrid.com.br"


	AADD(aMsg, '<font font size="7" color="green">Erro na compensação automática.</font>' )
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Prezado(a), " + UsrFullName(SF1->F1_XREQUIS))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	
	If !lEstClass
		AADD(aMsg, "A Nota fiscal foi classificada e NAO teve suas compensacoes realizadas com sucesso.") 
		AADD(aMsg, "a Nota ficará bloqueada, aguardando o estorno da classificação.")
	Else
		AADD(aMsg, "A Nota fiscal NAO foi classificada devido a um erro ocorrido na compensação automática.") 
		AADD(aMsg, "A Nota fiscal ficará bloqueada. Favor verificar o título de adiantamento com a Equipe do Financeiro, enviando e-mail para sgbh.cap@stategrid.com.br.")
	EndIf

	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, Dtoc(MSDate()) + " - " + Time() + '</b>')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Usuário Responsável.......... " + UsrFullName(retcodusr()) )
	AADD(aMsg, "Empresa.................................. " + SF1->F1_FILIAL)

	If nRecNoPA > 0
		nRecSE2:= SE2->(RecNo())

		SE2->(DBGoto(nRecNoPA))

		AADD(aMsg, "Número do Adiantamento........... " + LTRIM(SE2->E2_NUM))
		AADD(aMsg, "Valor do Adiantamento............ " + LTRIM(TRANSFORM(SE2->E2_VALOR, "@E 999,999,999.99")))
		AADD(aMsg, "Saldo do Adiantamento............ " + LTRIM(TRANSFORM(SE2->E2_SALDO, "@E 999,999,999.99")))

		SE2->(DBGoto(nRecSE2))
	EndIf

	AADD(aMsg, "Número do Documento........... " + LTRIM(SF1->F1_DOC))
	AADD(aMsg, "Série......................................... " + LTRIM(SF1->F1_SERIE))
	AADD(aMsg, "Código do Fornecedor............. " + LTRIM(SF1->F1_FORNECE))
	AADD(aMsg, "Nome do Fornecedor............. " + LTRIM(SA2->A2_NOME))
	AADD(aMsg, "Data de entrega para o fiscal... "+ DTOC(SF1->F1_RECBMTO))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<font font size="7" color="green">Invoice Compensatiom Problem</font>' )
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Dear, " + UsrFullName(SF1->F1_XREQUIS))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	
	If !lEstClass
		AADD(aMsg, "The Invoice has been didn't have your compensations successfully carried out.")           
		AADD(aMsg, "The will be blocked, waiting for the reversal of the classification.")           
	Else
		AADD(aMsg, "The Invoice was NOT classified due to an error that occurred in automatic compensation.") 
		AADD(aMsg, "The invoice will be blocked. Please check the advance title with the Finance Team by sending an email to sgbh.cap@stategrid.com.br.")
	EndIf

	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, Dtoc(MSDate()) + " - " + Time() + '</b>')
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')
	AADD(aMsg, "Responsable operator.......... " + UsrFullName(retcodusr()) )
	AADD(aMsg, "Company.............................. " + SF1->F1_FILIAL)

	If nRecNoPA > 0
		nRecSE2:= SE2->(RecNo())

		SE2->(DBGoto(nRecNoPA))

		AADD(aMsg, "Advance number........... " + LTRIM(SE2->E2_NUM))
		AADD(aMsg, "Advance value............ " + LTRIM(TRANSFORM(SE2->E2_VALOR, "@E 999,999,999.99")))
		AADD(aMsg, "Advance balance............ " + LTRIM(TRANSFORM(SE2->E2_SALDO, "@E 999,999,999.99")))

		SE2->(DBGoto(nRecSE2))
	EndIf

	AADD(aMsg, "Document number............... " + LTRIM(SF1->F1_DOC))
	AADD(aMsg, "Serie...................................... " + LTRIM(SF1->F1_SERIE))
	AADD(aMsg, "Supplier code........................ " + LTRIM(SF1->F1_FORNECE))
	AADD(aMsg, "Supplier name.................. " + LTRIM(SA2->A2_NOME))
	AADD(aMsg, "Delivery Date to TAX............. "+ DTOC(SF1->F1_RECBMTO))
	AADD(aMsg, '<br />')
	AADD(aMsg, '<br />')


MSGRUN( "Enviando e-mail para o solicitante", "Enviando", {||U_STAAX11(cUserMail, cTitulo, aMsg, aFiles)} )	

Return


User Function LibTitCom(nrec)

Local lret 		:=  .T.
Local aArea		:= GetArea()
Local _cAliQry	:= CriaTrab(Nil,.F.)

DbSelectArea("SE2")
DbGoto(nrec)

		cQry := " SELECT R_E_C_N_O_ RECN "
		cQry += " FROM "+RetSqlName("SE2")+" SE2"
		cQry += " WHERE E2_FILIAL    = '"+xFilial("SE2")+"'"
		cQry += " AND E2_NUM         = '"+SE2->E2_NUM+"'"
		cQry += " AND E2_PREFIXO     = '"+SE2->E2_PREFIXO+"'"
		cQry += " AND E2_FORNECE     = '"+SE2->E2_FORNECE+"'"
		cQry += " AND E2_LOJA        = '"+SE2->E2_LOJA+"'"
		cQry += " AND E2_ORIGEM      = 'MATA100'"
		cQry += " AND SE2.D_E_L_E_T_ = ' '"

		If Select(_cAliQry) > 0
			DbselectArea(_cAliQry)
			(_cAliQry)->(DbcloseArea())
		EndIf

		DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), _cAliQry, .F., .T.)

		While (_cAliQry)->(!Eof())
			SE2->(DbGoTo((_cAliQry)->RECN))
			SE2->(Reclock("SE2",.F.))
			SE2->E2_DATALIB := DDATABASE
			SE2->(MsUnLock("SE2"))
			(_cAliQry)->(DbSkip())
		EndDo
		(_cAliQry)->(DbCloseArea())
		RestArea(aArea)

Return lret		


Static Function fCmpHOLD()

	Local aArea		:= GetArea()
	Local aAreaE2	:= SE2->(GetArea())
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local lRet 		:= .F.
	Local cQry 		:= ""
	Local aTipos 	:= {"NF "}
	Local cTblTmp 	:= ""
	Local aNF 		:= {}
	Local aPA	 	:= {}
	Local nOpcao    := PARAMIXB[1]
	Local nConfirm	:= PARAMIXB[2]
	Local nY		:= 0
	Local aValCmp	:= {}
	Local nSalPA	:= 0
	Local cNF		:= ""
	Local cPA		:= ""
	Local nSalNF	:= 0
	Local nVrComp	:= 0
	Local cFilPA	:= ""
	Local lPABloq	:= .F.
	Local cError   := ""
	Local bError   := ErrorBlock({ |oError| cError := oError:Description})
	Private xCO_PCO	:= ""
	Private xVal_PCO:= 0
	Private xCC_PCO	:= ""

	IF (nOpcao == 3 .Or. nOpcao == 4) .And. (nConfirm == 1)

		cQry := " SELECT TOP 1 "
		cQry += " E2_TIPO TIPO, R_E_C_N_O_ R_E_C_N_O_NF,E2_VALOR VALOR, '0' ZZ1RECNO "
		cQry += " FROM "+RetSqlName("SE2")+" SE2"
		cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
		cQry += " AND E2_NUM      = '"+CNFISCAL+"'"
		cQry += " AND E2_PREFIXO  = '"+CSERIE+"'"
		cQry += " AND E2_FORNECE  = '"+CA100FOR+"'"
		cQry += " AND E2_LOJA     = '"+CLOJA+"'"
		cQry += " AND E2_ORIGEM   = 'MATA100'"
		cQry += " AND E2_TIPO IN (?)"
		cQry += " AND SE2.D_E_L_E_T_ = ''"

		cQry += " UNION ALL "

		cQry += "SELECT DISTINCT "
		cQry += "E2_TIPO TIPO, SE2.R_E_C_N_O_ R_E_C_N_O_A,ZZ1_VLCOMP VALOR,  ZZ1.R_E_C_N_O_ ZZ1RECNO  "
		cQry += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("ZZ0")+" ZZ0, "+RETSQLNAME("ZZ1")+" ZZ1 "
		cQry += "WHERE SE2.D_E_L_E_T_ = '' AND ZZ0.D_E_L_E_T_ = '' AND ZZ1.D_E_L_E_T_ = '' AND "

		cQry += "E2_FILIAL = ZZ0_FILDES AND ZZ1_FILDES = ZZ0_FILDES AND ZZ1_FILIAL = '"+XFILIAL("ZZ1")+"' AND "

		cQry += "ZZ1_NUMMED = '' AND ZZ1_NUMPLA = '' AND "
		cQry += "ZZ1_CONTRA = ZZ0_CONTRA AND ZZ1_REVISA = ZZ0_REVISA AND ZZ0_NUMERO = ZZ1_NUMERO AND "
		cQry += "E2_XCHVZZ0 = ZZ0_CONTRA+ZZ0_REVISA+SUBSTRING(ZZ0_FILIAL,1,2)+ZZ0_NUMERO "
		cQry += "AND ZZ1_SF1 = '"+SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"' AND ZZ1_PROCHL = 'S' "
		cQry += "ORDER BY R_E_C_N_O_NF "

		cQry := ChangeQuery(cQry)
		__COMPAUT := FWPreparedStatement():New(cQry)

		__COMPAUT:SetIn(1, aTipos)
		cQry := __COMPAUT:GetFixQuery() 
		cTblTmp := MpSysOpenQuery(cQry)

		While (cTblTmp)->(!Eof())
			If ((cTblTmp)->TIPO $ "PA ")
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aPA, {(cTblTmp)->R_E_C_N_O_NF})					
					aAdd(aValCmp,{(cTblTmp)->VALOR,(cTblTmp)->ZZ1RECNO})
				EndIf
			Else
				if !Empty((cTblTmp)->R_E_C_N_O_NF)
					Aadd(aNF, (cTblTmp)->R_E_C_N_O_NF)
				EndIf
			EndIf

			(cTblTmp)->(DbSkip())
			lRet := .T.
		EndDo

		(cTblTmp)->(DbCloseArea())
		cTblTmp := ""


		If lRet .And. !Empty(aNF) .And. !Empty(aPA)

		Begin Transaction

			//Libera os títulos da nota fiscal.
			U_LibTitCom(aNF[1])

			For nY := 1 to Len(aPA)

				Pergunte("AFI340", .F.) 
				lContabiliza := MV_PAR11 == 1
				lAglutina := MV_PAR08 == 1
				lDigita := MV_PAR09 == 1

				dbSelectArea("SE2")
				dbSetOrder(1)

				SE2->(dbGoTo(aPA[nY,1]))
				nSalPA	:= SE2->E2_SALDO
				cPA		:= SE2->E2_NUM
				cFilPA	:= SE2->E2_FILIAL

				//Caso o PA não tenha movimentação, a compensacao nao sera executada.
				If Alltrim(SE2->E2_TIPO) $ MVPAGANT .and. !U_Fx340PA(Nil, "SE2",.F.)[1]

					Help(" ",1,"Não é possível compensar pagamento antecipado sem movimentação bancária." + CRLF + "A classificação da Nota será estornada!")  //"Não é possível compensar pagamento antecipado sem movimentação bancária."

					//Notifica requisitante do erro na compensação
					U_MTMAILCP(.T., aPA[nY,1])

					DisarmTransaction()

					EstClassif()

					Return (.F.)
				Endif


				If Empty(SE2->E2_DATALIB)
					lPABloq := .T.
				EndIf

				nSalPA := SE2->E2_SALDO

				dbGoTo(aNF[1])

				nSalNF		:= SE2->E2_SALDO - SF1->F1_VALPIS - SF1->F1_VALCOFI - SF1->F1_VALCSLL
				nNFValRet 	:= SE2->(E2_VRETPIS+E2_VRETCSL+E2_VRETCOF)
				nSalNFTOT	:= SE2->E2_SALDO 
				cFilNF		:= SE2->E2_FILIAL
				
				RecLock("SE2",.F.)
				SE2->E2_XVALCMP := aValCmp[nY][1]
				MsUnlock()

				If lPABloq
					Aviso("Compensação Automática","A compensação automática da NF "+SE2->E2_NUM+" com o adiantamento "+cPA+" não foi realizada. Verifique se o PA está liberado e se já foi pago." +;
							CRLF + "A classificação da Nota será estornada!",{"OK"})
								
					//Notifica requisitante do erro na compensação
					U_MTMAILCP(.T., aPA[nY,1])

					DisarmTransaction()

					EstClassif()

					Loop
				EndIf

				nVrComp	:= aValCmp[nY][1]

				If nVrComp > nSalNF
					nVrComp := nSalNF
				EndIf
				If nVrComp > nSalPA
					nVrComp := nSalPA
				EndIf

				nValLiq := SE2->E2_VALLIQ

				_aParametrosJob := {cFilPA, aNF, aPA[nY], {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.}, nVrComp, dDatabase, cFilNF}
				lRet 			:= U_CompAuto(_aParametrosJob )

				SE2->(dbGoTo(aNf[1]))
				
				If (round(nSalNFTOT-nVrComp-(SE2->(E2_VRETPIS+E2_VRETCSL+E2_VRETCOF)-nNFValRet) ,0) <> round(SE2->E2_SALDO,0)) 
					Aviso("Compensação Automática","A compensação automática da NF "+cNF+" com o adiantamento "+SE2->E2_NUM+" não foi realizada, informar ao requisitante. Verificar o título de adiantamento no financeiro." +;
						 CRLF + "A classificação da Nota será estornada!",{"OK"})
					//Notifica requisitante do erro na compensação
					U_MTMAILCP(.T., aPA[nY,1])
					DisarmTransaction()

					EstClassif()

					Return (.F.)				
				EndIf

				//Posiciona no PA e verifica o saldo
				SE2->(dbGoTo(aPA[nY,1]))
				If (nSalPA == SE2->E2_SALDO) 
					Aviso("Compensação Automática","A compensação automática da NF "+cNF+" com o adiantamento "+SE2->E2_NUM+" não foi realizada. Verificar o título de adiantamento no financeiro." +;
						 CRLF + "A classificação da Nota será estornada!",{"OK"})
					//Notifica requisitante do erro na compensação
					U_MTMAILCP(.T., aPA[nY,1])
					DisarmTransaction()		

					EstClassif()

					Return (.F.)			
				Else

					//Verifica se o valor compensado é menor que o valor original e atualiza a ZZ1.
					DbSelectArea("ZZ1")
					DbGoTo(aValCmp[nY][2])
					If ZZ1->ZZ1_VLCOMP <> nVrComp
						ZZ1->(RecLock("ZZ1",.F.))
							ZZ1->ZZ1_VLCOMP := nVrComp
						ZZ1->(MsUnlock())
					EndIf
				
					xCO_PCO		:= SE2->E2_XCO
					xVal_PCO	:= aValCmp[nY][1]
					xCC_PCO		:= SE2->E2_CCD

					cQuery := "SELECT E2_XCHVZZ0,E2_SALDO FROM "+RETSQLNAME("SE2")+" WHERE R_E_C_N_O_ = "+AllTrim(Str(aPA[nY][1]))
					TCQuery cQuery NEW ALIAS (cAlias)

					nChvZZ0 := (cAlias)->E2_XCHVZZ0
					nSaldPA := (cAlias)->E2_SALDO

					(cAlias)->(dbCloseArea())

					cQuery := "UPDATE "+RETSQLNAME("ZZ0")+" SET ZZ0_SALDO = "+AllTrim(Str(nSaldPA))+" WHERE "
					cQuery += "ZZ0_CONTRA+ZZ0_REVISA+SUBSTRING(ZZ0_FILIAL,1,2)+ZZ0_NUMERO = '"+nChvZZ0+"'"

					if TCSQLExec(cQuery) < 0
						Aviso("Erro SQL",TCSQLError(),{"OK"})
					EndIf
				EndIf

			Next nY

			If !lRet
				MostraErro()
				//Alert("Ocorreu um erro no processo de compensação")
			Else
				//Nova função para tratar a liberação do título. Incluído no Begin Transaction para executar o rollback caso ocorra algum problema na compensação				
				fLibSE2()
			EndIf

			//Bloqueia os títulos da nota fiscal.
			BloqTit(aNF[1])
		
			END TRANSACTION

		EndIf	

	EndIf

	if FunName() == "MATA140"
		Pergunte("MTA140", .F.)
	Else
		Pergunte("MTA103", .F.)
	EndIf

	RestArea(aAreaE2)
	RestArea(aArea)

Return()


Static Function BloqTit(nRec)

	Local aArea		:= GetArea()
	Local _cAliQry	:= CriaTrab(Nil,.F.)

	DbSelectArea("SE2")
	DbGoto(nRec)

	cQry := " SELECT R_E_C_N_O_ RECN "
	cQry += " FROM "+RetSqlName("SE2")+" SE2"
	cQry += " WHERE E2_FILIAL    = '"+xFilial("SE2")+"'"
	cQry += " AND E2_NUM         = '"+SE2->E2_NUM+"'"
	cQry += " AND E2_PREFIXO     = '"+SE2->E2_PREFIXO+"'"
	cQry += " AND E2_FORNECE     = '"+SE2->E2_FORNECE+"'"
	cQry += " AND E2_LOJA        = '"+SE2->E2_LOJA+"'"
	cQry += " AND E2_ORIGEM      = 'MATA100'"
	cQry += " AND SE2.D_E_L_E_T_ = ' '"

	If Select(_cAliQry) > 0
		DbselectArea(_cAliQry)
		(_cAliQry)->(DbcloseArea())
	EndIf

	DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), _cAliQry, .F., .T.)

	While (_cAliQry)->(!Eof())

		//If SE2->E2_SALDO > 0
			SE2->(DbGoTo((_cAliQry)->RECN))
			SE2->(Reclock("SE2",.F.))
			SE2->E2_DATALIB := SToD('')
			SE2->(MsUnLock("SE2"))
		//EndIf

		(_cAliQry)->(DbSkip())
	EndDo
	(_cAliQry)->(DbCloseArea())
	RestArea(aArea)
Return


Static Function EstClassif()

    Local nOpc := 7
 
    Private aCabec      := {}
    Private aItens      := {}
    Private aLinha      := {}

    Private lMsErroAuto := .F.
 
    aAdd(aCabec, {"F1_DOC",     SF1->F1_DOC,     Nil})
    aAdd(aCabec, {"F1_SERIE",   SF1->F1_SERIE,   Nil})
    aAdd(aCabec, {"F1_FORNECE", SF1->F1_FORNECE, Nil})
    aAdd(aCabec, {"F1_LOJA",    SF1->F1_LOJA,    Nil})
    aAdd(aCabec, {"F1_TIPO",    SF1->F1_TIPO,    Nil})
    aAdd(aCabec, {"F1_ESPECIE", SF1->F1_ESPECIE, Nil})
      
    SD1->(DbGoTop())
    If SD1->(DbSeek(FWxFilial('SD1') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
        
        //Percorre os itens e monta o array de itens
        While ! SD1->(EoF())					.And.;
			SD1->D1_DOC     == SF1->F1_DOC		.And.;
			SD1->D1_SERIE   == SF1->F1_SERIE	.And.;
			SD1->D1_FORNECE == SF1->F1_FORNECE	.And.;
			SD1->D1_LOJA    == SF1->F1_LOJA 
                
            aLinha := {}
            aAdd(aLinha,  {"D1_DOC",     SD1->D1_DOC,     Nil})
            aAdd(aLinha,  {"D1_SERIE",   SD1->D1_SERIE,   Nil})
            aAdd(aLinha,  {"D1_FORNECE", SD1->D1_FORNECE, Nil})
            aAdd(aLinha,  {"D1_LOJA",    SD1->D1_LOJA,    Nil})
            aAdd(aLinha,  {"D1_TIPO",    SD1->D1_TIPO,    Nil})
            aAdd(aLinha,  {"D1_ITEM",    SD1->D1_ITEM,    Nil})
            aAdd(aLinha,  {"D1_COD",     SD1->D1_COD,     Nil})
            aAdd(aDadSD1, aClone(aLinha))
                
            SD1->(DbSkip())
        EndDo
            
        //Ordena pelo número do item
        aSort(aDadSD1, , , { |x, y| x[6] < y[6] })
    EndIf
      
    aAdd(aLinha,aItens)
      
    MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)
      
    If lMsErroAuto
        MostraErro()
    Else

		cHisAnt := SF1->F1_XHISREJ

		RecLock("SF1", .F.)
			SF1->F1_XHISREJ := cHisAnt+" - "+DTOC(date())+" - "+"Operador Responsável: "+UsrFullName(retcodusr())+" - Motivo da Rejeição : "+Chr(13)+Chr(10)+"Erro na realização da Compensação Automática"+Chr(13)+Chr(10)+Chr(13)+Chr(10)
			SF1->F1_STATUS  := "B"
		MsUnlock()

        Alert("Realizado o estorno da Classificação!")
    EndIf
     
Return

Static Function fLibSE2
	Local cAlias2	:= CriaTrab(Nil,.F.)
	Local cAlias3	:= CriaTrab(Nil,.F.)
	Local _aArea := GetArea()
	
	SF1->(DbSetOrder(1)) 
	SF1->(DbSeek(xFilial("SF1")+CNFISCAL+CSERIE+CA100FOR+CLOJA+CTIPO))

	_lTemPed := .F.
	If Empty(SF1->F1_XCELNF)
		//VERIFICAR SE TEM NOTAS COM PEDIDO VAZIO E PREENCHIDO, SEM SIM CAI BLOQUEADO E VERFICAR A LIBERAÇÃO MANUAL
		_cQuery := "SELECT DISTINCT D1_PEDIDO FROM "+RETSQLNAME("SD1")+" " 
		_cQuery += "WHERE D1_FILIAL = '"+xFilial("SF1")+"' AND D1_FORNECE  = '"+CA100FOR+"' AND D1_LOJA     = '"+CLOJA+"' AND "
		_cQuery += "	  D1_DOC      = '"+CNFISCAL+"' AND D1_SERIE    = '"+CSERIE+"' AND "
		_cQuery += "	  D_E_L_E_T_ = ' '"
		TCQUERY _cQuery ALIAS (cAlias2) NEW

		If !(cAlias2)->(Eof())

			//Se tem pedido, libera título
			If !Empty((cAlias2)->D1_PEDIDO)
				_cQuery := " SELECT R_E_C_N_O_ RECN, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_ORIGEM "
				_cQuery += " FROM "+RetSqlName("SE2")+" SE2"
				_cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
				_cQuery += " AND E2_NUM      = '"+CNFISCAL+"'"
				_cQuery += " AND E2_PREFIXO  = '"+CSERIE+"'"
				_cQuery += " AND E2_FORNECE  = '"+CA100FOR+"'"
				_cQuery += " AND E2_LOJA     = '"+CLOJA+"'"
				_cQuery += " AND SE2.D_E_L_E_T_ = ' '"

				If Select(cAlias3) > 0
					DbselectArea(cAlias3)
					(cAlias3)->(DbcloseArea())
				EndIf

				DbUseArea(.T., 'TOPCONN', TCGenQry(,,_cQuery), cAlias3, .F., .T.)

				While (cAlias3)->(!Eof())

					SE2->(DbGoTo((cAlias3)->RECN))
					SE2->(Reclock("SE2",.F.))
					SE2->E2_DATALIB := dDatabase
					SE2->(MsUnlock())

					(cAlias3)->(DbSkip())

				EndDo
			Endif
		Endif
		(cAlias2)->(DbCloseArea())
	Endif

	RestArea(_aArea)

Return _lTemPed
