#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//Bloqueio da Liberação de Estoque
User Function MTA455P()

	Local nOpcao            := ParamIxb[01]
	Local lRet              := .T.
	Local _nQtdLib          := SC9->C9_QTDLIB
	Local _cUsrLocal        := SuperGetMV("MV_XLIBEST",,"",xfilial('SC9'))//Configuração do Parâmetro: CODUSER/LOCAL;CODUSER/LOCAL; 

	
	//Bloqueio de usuarios com permissão de liberação por armazem
	If nOpcao == 2 .and. lRet .and. !isBlind()
		If !FWIsAdmin(__cUserId) .and. _cUsrLocal <> "" //Se parametro vazio ou administrador ignora
			if  !((__cUserId+"/"+"ZZ" $ _cUsrLocal)  .or. (__cUserId+"/"+AllTrim(SC9->C9_LOCAL) $ _cUsrLocal) )
				lRet := .F.
				Aviso("Parametro:  MV_XLIBEST",'Voce nao tem permissao para Liberacao de estoque do pedido: '+SC9->C9_PEDIDO+', Local: '+SC9->C9_LOCAL+'.',{"Ok"},,,,,.T.,5000)
			Endif 
		Endif 
	Endif 

	If nOpcao == 2 .And. (SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06" ) .and. lRet //.And. AllTrim(SC9->C9_LOCAL) <> "03" .And. AllTrim(SC9->C9_LOCAL) <> "05")

		nSldAtu  := VerSaldo()//SaldoSB2(,GetNewPar("MV_QEMPV",.T.)) + Iif( Empty(SC9->C9_BLEST), SC9->C9_QTDLIB, 0 )

		If _nQtdLib > nSldAtu
			lRet := .F.
			MsgAlert('O Produto: '+ALLTRIM(SC9->C9_PRODUTO)+' do pedido: '+SC9->C9_PEDIDO+', nao possui saldo suficiente! ','Ponto de Entrada: MTA455P' )
		Endif


	Endif

Return(lRet)

//Bloqueio da Liberação de Cred/Estoque
User Function MTA456P()

	Local nOpcao            := ParamIxb[01]
	Local lRet              := .T.
	Local _nQtdLib          := SC9->C9_QTDLIB

	If (nOpcao == 2  .OR. nOpcao == 4 .OR. nOpcao == 1) .And. !(SM0->M0_CODIGO == "01" .And. Alltrim(SM0->M0_CODFIL) == "06" .And. AllTrim(SC9->C9_LOCAL) == "05")

		nSldAtu  := VerSaldo() //SaldoSB2(,GetNewPar("MV_QEMPV",.T.)) + Iif( Empty(SC9->C9_BLEST), SC9->C9_QTDLIB, 0 )

		If _nQtdLib > nSldAtu
			lRet := .F.
			Alert('O Produto: '+ALLTRIM(SC9->C9_PRODUTO)+' do pedido: '+SC9->C9_PEDIDO+', não possui saldo suficiente!' )
		Endif
	Endif

Return(lRet)

Static Function VerSaldo()

	Local _cQuery    := ""
	Local _cAliasQry := ""
	Local _nSaldo    := 0

	_cQuery := " SELECT B2_QATU, B2_QEMP, B2_RESERVA "
	_cQuery += " FROM " + RetSqlName("SB2") + " (NOLOCK) "
	_cQuery += " WHERE B2_FILIAL = '" + xFilial("SB2") + "'"
	_cQuery += " AND B2_COD = '" + SC9->C9_PRODUTO + "'"
	_cQuery += " AND B2_LOCAL = '" + SC9->C9_LOCAL + "'"
	_cQuery += " AND D_E_L_E_T_ = '' "

	_cAliasQry := MpSysOpenQuery(_cQuery)

	_nSaldo := (_cAliasQry)->B2_QATU - ((_cAliasQry)->B2_QEMP + (_cAliasQry)->B2_RESERVA)

	(_cAliasQry)->(DbCloseArea())

Return(_nSaldo)
