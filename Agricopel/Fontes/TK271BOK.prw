#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271BOK  ºAutor  ³Thiago Padilha      º Data ³  27/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa executa algumas validacoes quando pressiona      º±±
±±º          ³  o botao de confirmar no atendimento do Call Center        º±±
±±º          ³  Foi inserida validacao para informar se pedido ja se      º±±
±±º          ³  encontra impresso (C5_XIMPRE = S). Chamado 51183          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TK271BOK()

	Local _cRotDBGin :=  SuperGetMv( "MV_XROTDBG" , .F. , ""  ) 
	Private lRet     := .T.
	Private aSegSUA  := SUA->(GetArea())



	//Chamado[651437] -  Verificar casos de clientes diferente de endereço de entrega 
	IF Alltrim(M->UA_CLIENTE) <> ''
		If (Alltrim(M->UA_CLIENTE) <> Alltrim(M->UA_CLIENT)) .or.( Alltrim(M->UA_LOJA) <> Alltrim(M->UA_LOJAENT) )
			MsgAlert("Divergencia entre Cliente e Cliente de Entrega.","Entre em contato com a TI!")
			Return .F.
		Endif 
	Endif 




	dbSelectArea("SUA")
	dbSetOrder(1)
	If dbSeek(xFilial("SUA")+M->UA_NUM)
		If ((cEmpAnt == "01" .and. cFilAnt $ "06") .or. (cEmpAnt == "16")) .and. !empty(Alltrim(SUA->UA_NUMSC5))
			dbSelectArea("SC5")
			dbSetOrder(1)
			//if dbSeek(xFilial("SC5")+M->UA_NUMSC5,.T.)
			If dbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
				IF Alltrim(SC5->C5_XIMPRE) == "S"
					//alert("entrou no while, pedido impresso: " +M->UA_NUMSC5+ " atend: "+M->UA_NUM)
					//lRet := MsgYesNO("O Pedido " +SUA->UA_NUMSC5+ " se encontra impresso, deseja continuar com o processo? ")
					APMSGALERT("O Pedido " +SUA->UA_NUMSC5+ " se encontra impresso, para efetivar a alteração, entre em contato com setor de faturamento! ")
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If(cEmpAnt == "01" .and. cFilAnt == "19")

			If !(ValSepMax(SUA->UA_NUMSC5))
				MSGINFO("O Pedido " +SUA->UA_NUMSC5+ " ja foi enviado para o operador logistico, entre em contato com o setor de faturamento! ","TK271BOK")
				lRet := .F.
			Endif 

		Endif 


		//If cFilAnt $ GetMV("MV_XFALTPE") .AND. !Empty(cPedido) .AND. Paramixb[1] == 4
		If cFilAnt $ SuperGetMV("MV_XFALTPE",.T.,'') .AND. !Empty(alltrim(SUA->UA_NUMSC5)) //.AND. Paramixb[1] == 4

			DbSelectArea("SC5")
			SC5->(dbSetOrder(1)) //Ordeno no índice 1
			SC5->(dbSeek(xFilial("SC5")+SUA->UA_NUMSC5)) //Localizo o meu pedido
			
			//If  Alltrim(SC5->C5_VEICULO) != '' .AND. (!__cuserid $ GetMV("MV_XUALTPE") .OR. __cuserid != '000000')
			If  Alltrim(SC5->C5_VEICULO) != '' .AND. !(__cuserid $ SuperGetMV("MV_XUALTPE",.T.,'') .OR. FWIsAdmin(__cuserid) )
				FWAlertError("Pedido com veículo preenchido, usuário sem acesso a alterar. Verificar com a Logistica." , "TK271ABR")
				lRet := .F.
			EndIf

		EndIf  


	EndIf

	If (lRet) .And. (SM0->M0_CODIGO == '16' .And. Alltrim(SM0->M0_CODFIL) == '01' .And. M->UA_TIPOCLI == 'F')
		lRet := ValTesLuparco()
	EndIf

	//Cliente inativo nao pode gerar pedido no TRR
	If (lRet) .And. ((SM0->M0_CODIGO == '01' .And. ( Alltrim(SM0->M0_CODFIL) $ '02/03/06/11/15/16/17/18/05/19'  )) .Or. (SM0->M0_CODIGO == '11').Or.(SM0->M0_CODIGO == '12') .Or. (SM0->M0_CODIGO == '15'))
		lRet := ValClienteInativo()

		If (lRet)
			lRet := ValDataRetorno()
		EndIf
	EndIf

	If (lRet) .And. (M->UA_OPER != "2") .And. ((SM0->M0_CODIGO == '01' .And. (Alltrim(SM0->M0_CODFIL) == '03' .Or. Alltrim(SM0->M0_CODFIL) $ '11/15/17/18/05'.Or. Alltrim(SM0->M0_CODFIL) == '16')) .Or. (SM0->M0_CODIGO == '11') .Or. (SM0->M0_CODIGO == '15'))

		lRet := ValPrcTRR()
	EndIf

    //Se Tiver Municipio Preenchido e não tiver código Bloqueia
	If xfilial('SUA') $ alltrim(_cRotDBGin) .and. alltrim(M->UA_XCODMUN) == '' .And. alltrim(M->UA_MUNE) <> ''
		MsgAlert("Favor preencher o Codigo do Municipio de Entrega"," Codigo do Municipio Vazio")
		lRet := .F.
	Endif 


	//Valida se o Estado de entrega é diferente do Cadastro do Cliente 
	If (lRet) .And. M->UA_ESTE <> SA1->A1_EST 
		If !(MsgYesno("ATENÇÃO: Estado de ENTREGA diferente do estado de CADASTRO do Cliente!,  CONFIRMA A OPERAÇÃO?","ESTADO de ENTREGA"))
			lRet := .F.
		Endif  
	Endif

	//Tratamento para Clientes dpo tipo Distribuidor 
	If cEmpant == '01'
		If POSICIONE('AI0',1,xfilial('AI0')+M->UA_CLIENTE+M->UA_LOJA, 'AI0_ZZDIST') == 'S'
			If SUA->(FieldPos("UA_XCLIENT")) > 0 
				IF Empty(M->UA_XCLIENT) .OR. Empty(M->UA_XLOJA) 
					MsgInfo(" O Cliente: "+M->UA_CLIENTE+'-'+M->UA_LOJA+ " exige que seja informado um cliente de Entrega!","Cliente de Entrega Vazio")
					lRet := .F.
				Endif   
			Endif 
		Endif 
	Endif 

	RestArea(aSegSUA)

Return(lRet)

Static Function ValTesLuparco()

	Local lRet        := .T.
	Local nUB_TES     := aScan(aHeader,{|x| alltrim(x[2]) == "UB_TES"})
	Local nUB_Produto := aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
	Local nLenSUB     := Len(aCols)
	Local i           := 0
	Local aSegSB1     := SB1->(GetArea())
	Local cListaPrd   := ""
	Local cProduto    := ""
	Local cTes        := ""

	SB1->(DbSetOrder(1))

	For i := 1 to nLenSUB

		cProduto := aCols[i][nUB_Produto]
		cTes     := aCols[i][nUB_TES]

		If (SB1->(DbSeek(xFilial("SB1")+cProduto)))

			If (AllTrim(SB1->B1_POSIPI) == '33074900') .And. (cTes <> "516")
				cListaPrd += "TES: " + AllTrim(cTes) + " - Produto: " + AllTrim(cProduto) + " - " + AllTrim(SB1->B1_DESC) + Chr(13) + Chr(10)
			EndIf
		EndIf
	Next

	RestArea(aSegSB1)

	If (!Empty(cListaPrd))
		lRet := .F.
		Alert("Atendimento possui um ou mais produtos com a TES inconsistente para venda a consumidor final!" + Chr(13)+Chr(10)+Chr(13)+Chr(10) + cListaPrd + Chr(13)+Chr(10) + "Será necessário corrigir estas inconsistências antes de continuar!")
	EndIf

Return(lRet)


Static Function ValClienteInativo()

	Local lRet        := .T.

	IF (SA1->A1_SITUACA == "2")
		MSGSTOP("CLIENTE INATIVO !")
		lRet := .F.
	ENDIF

Return(lRet)


Static Function ValDataRetorno()

	Local lRet := .T.
	Local nDias :=  0

	If (!Empty(M->UA_PROXLIG)) .And. ((M->UA_PROXLIG <= Date()) .or. (M->UA_PROXLIG <= dDatabase))
		MSGSTOP("Necessario preencher o retorno com data maior que a data atual "+ DTOC(Date()) +" !")
		lRet := .F.
	ENDIF
	
	If cFilAnt == '06' .AND. (!Empty(M->UA_PROXLIG)) .AND. alltrim(SA1->A1_SATIV7) <> ''
	
		If  alltrim(SA1->A1_SATIV7) == 'REVEND'//45 dias
			nDias :=  45 
		Elseif alltrim(SA1->A1_SATIV7) == 'FROTA' .or. alltrim(SA1->A1_SATIV7) == 'B2B' .or. alltrim(SA1->A1_SATIV7) == 'B2C' //180 dias
			nDias :=  180 
		Elseif alltrim(SA1->A1_SATIV7) == 'VAREJO'//30 dias
			nDias :=  30 
		Endif 
		
		If nDias > 0 
			If(M->UA_PROXLIG - Date()) > nDias
				MSGSTOP( "Para o segmento: "+alltrim(SA1->A1_SATIV7)+" o máximo de retorno é de "+alltrim(str(nDias))+" dias. ")
				lRet := .F.
			Endif 
		Endif 
	Endif 

Return (lRet)

Static Function ValPrcTRR()

	Local lRet        := .T.
	Local nUB_VRUNIT  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
	Local nUB_Produto := aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
	Local nLenSUB     := Len(aCols)
	Local _nI         := 0
	Local _cMsgProd   := ""
	Local _cMsgItem   := 0
	Local _cMsgErro   := ""
	Local _cCodProd   := ""
	Local _nPrcProd   := 0

	Local _cLogin  := UsrRetName(RetCodUsr())
	Local _cLogAut := U_XAG0062G("LOGIN_LIB_CALLCENTER", .T., .F.)

	Local _cA1SATIV := ""
	Local _cA1VEND3 := ""
	Local _cA1VEND6 := ""
	Local _cA1VEND7 := ""

	Local _cVend3   := ""
	Local _cVend6   := ""
	Local _cVend7   := ""
	Local _cSativ   := ""

	_cLogin   := ";" + _cLogin + ";"
	_cLogAut  := ";" + _cLogAut + ";"

	If ("*" $ _cLogAut .Or. Upper(_cLogin) $ Upper(_cLogAut))
		Return(.T.)
	EndIf

	_cA1VEND3 := U_XAG0062G("A1_VEND3_LIB_CALLCENTER", .T., .F.)
	_cA1VEND3 := ";" + _cA1VEND3 + ";"
	_cVend3   := GetA1Info("A1_VEND3", M->UA_CLIENTE, M->UA_LOJA)
	_cVend3   := ";" + _cVend3 + ";"

	If (_cVend3 $ Upper(_cA1VEND3))
		Return(.T.)
	EndIf

	_cA1VEND6 := U_XAG0062G("A1_VEND6_LIB_CALLCENTER", .T., .F.)
	_cA1VEND6 := ";" + _cA1VEND6 + ";"
	_cVend6   := GetA1Info("A1_VEND6", M->UA_CLIENTE, M->UA_LOJA)
	_cVend6   := ";" + _cVend6 + ";"

	If (_cVend6 $ Upper(_cA1VEND6))
		Return(.T.)
	EndIf

	_cA1VEND7 := U_XAG0062G("A1_VEND7_LIB_CALLCENTER", .T., .F.)
	_cA1VEND7 := ";" + _cA1VEND7 + ";"
	_cVend7   := GetA1Info("A1_VEND7", M->UA_CLIENTE, M->UA_LOJA)
	_cVend7   := ";" + _cVend7 + ";"

	If (_cVend7 $ Upper(_cA1VEND7))
		Return(.T.)
	EndIf

	_cA1SATIV := U_XAG0062G("A1_SATIV5_LIB_CALLCENTER", .T., .F.)
	_cA1SATIV := ";" + _cA1SATIV + ";"
	_cSativ   := GetA1Info("A1_SATIV5", M->UA_CLIENTE, M->UA_LOJA)
	_cSativ   := ";" + _cSativ + ";"

	If (_cSativ $ Upper(_cA1SATIV))
		Return(.T.)
	EndIf

	For _nI := 1 to nLenSUB
		_cCodProd := aCols[_nI][nUB_Produto]
		_nPrcProd := aCols[_nI][nUB_VRUNIT]

		_cMsgItem := U_XAG0062P(_cCodProd, M->UA_CLIENTE, M->UA_LOJA, M->UA_CONDPG, M->UA_TABELA, _nPrcProd)

		If !Empty(_cMsgItem)
			_cMsgProd += _cMsgItem + CRLF
		EndIf
	Next

	If (!Empty(_cMsgProd))
		lRet := .F.

		_cMsgErro := "Atendimento possui um ou mais produtos com preço divergente das regras de preço para o cliente e condição de pagamento!"
		_cMsgErro += CRLF+CRLF
		_cMsgErro += _cMsgProd
		_cMsgErro += CRLF+CRLF
		_cMsgErro += "Será necessário corrigir estas inconsistências antes de continuar!"
		_cMsgErro += CRLF+CRLF
		_cMsgErro += "Esta mensagem irá fechar em 5 segundos, clique em 'TIMER OFF' para evitar"

		Aviso("Atenção!",_cMsgErro,{"Ok"},,,,,.T.,5000)
	EndIf

Return(lRet)

Static Function GetA1Info(Info, _cA1Cod, _cA1Loja)

	Local _cQuery   := ""
	Local _cAlias   := ""
	Local _cInfoRet := ""

	_cQuery += " SELECT SA1." + Info + " AS INFO_RET "
	_cQuery += " FROM " + RetSqlName("SA1") + " SA1 (NOLOCK) "
	_cQuery += " WHERE SA1.A1_COD = '" + AllTrim(_cA1Cod) + "'"
	_cQuery += " AND SA1.A1_LOJA = '" + AllTrim(_cA1Loja) + "'"
	_cQuery += " AND SA1.D_E_L_E_T_ = '' "

	_cAlias := MpSysOpenQuery(_cQuery)

	_cInfoRet := (_cAlias)->INFO_RET

	(_cAlias)->(DbCloseArea())

Return(_cInfoRet)


Static Function ValSepMax(xPedido)

	Local _cQuery   := ""
	Local _cAlias   := ""
	Local _lRetMax  := .T.

	_cQuery += " SELECT C9_PEDIDO "
	_cQuery += " FROM " + RetSqlName("SC9") + " SC9 (NOLOCK) "
	_cQuery += " WHERE C9_FILIAL = '" +xFilial('SC9') + "' "
	_cQuery += " AND C9_PEDIDO = '" + xPedido + "' "
	_cQuery += " AND C9_XDTEDI <> '' "
	_cQuery += " AND D_E_L_E_T_ = '' "

	_cAlias := MpSysOpenQuery(_cQuery)


	If (_cAlias)->(!eof())
		_lRetMax  := .F.
	Endif 

Return(_lRetMax)
