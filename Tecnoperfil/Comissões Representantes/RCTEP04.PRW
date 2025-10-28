//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function RCTEP04
admin
@SenhaSegura9&@
@since 03/02/2025
@version 1.0
/*/

//Variveis Estaticas
Static cTitulo := "Calculo de Comissões"
Static cAliasMVC := "ZP0"

User Function RCTEP04()
	Private _oProc		:= MsNewProcess():New({ || fCalcula() },"Processando","Aguarde...",.F.)
	Private _dFecAno	:= SuperGetMV("FL_FECANO",,STOD("20241231")) //TROCAR
	Private _dFecMes	:= SuperGetMV("FL_FECMES",,STOD("20250131")) //TROCAR
	Private _dData		:= SuperGetMV("FL_COMMES",,STOD("20250131")) //TROCAR
	Private _dDtIni		:= (_dFecAno + 1)
	Private _dDtFec		:= LastDay(Date())
	Private _dDtPag		:= (_dDtFec + 1)
	Private _nTpCalc	:= 1

	///ADICIONAR CAMPO NOME DO VENDEDOR.

	_oDlgIni := TDialog():New(000,000,350,350,"Cálculo Período Comissão - Representantes",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	_oGroup1 := TGroup():New(005,005,050,170,'',_oDlgIni,,,.T.)

	_oGet01 := TGet():New(010,010,{|u|if(Pcount()>0,_dData := u,_dData)		},_oDlgIni,060,012,"@!",{|| .T.},RGB(47,79,79),RGB(245,245,245),,.F.,Nil,.T.,Nil,.F.,{|| .T.},.F.,.F.,{|| .T.},.F.,.F.,"","_dData","",.T.,0,.T.,.F.,.T.,"Dt Último Cálculo		",2,,CLR_BLACK,"")
	_oGet01:lReadOnly := .T.

	_oGet02 := TGet():New(030,010,{|u|if(Pcount()>0,_dFecMes := u,_dFecMes)		},_oDlgIni,060,012,"@!",{|| .T.},RGB(47,79,79),RGB(245,245,245),,.F.,Nil,.T.,Nil,.F.,{|| .T.},.F.,.F.,{|| .T.},.F.,.F.,"","_dFecMes","",.T.,0,.T.,.F.,.T.,"Dt Último Fechamento	",2,,CLR_BLACK,"")
	_oGet02:lReadOnly := .T.

	_oGroup2 := TGroup():New(050,005,150,170,'',_oDlgIni,,,.T.)

	_oGet03 := TGet():New(055,010,{|u|if(Pcount()>0,_dDtIni := u,_dDtIni)	},_oDlgIni,060,012,"@!",{|| .T.},RGB(47,79,79),RGB(245,245,245),,.F.,Nil,.T.,Nil,.F.,{|| .T.},.F.,.F.,{|| .T.},.F.,.F.,"","_dDtIni","",.T.,0,.T.,.F.,.T.,"Dt Inicio Cálculo		",2,,CLR_BLACK,"")
	_oGet03:lReadOnly := .T.

	_oGet04 := TGet():New(075,010,{|u|if(Pcount()>0,_dDtFec := u,_dDtFec)	},_oDlgIni,060,012,"@!",{|| .T.},RGB(47,79,79),RGB(245,245,245),,.F.,Nil,.T.,Nil,.F.,{|| .T.},.F.,.F.,{|| .T.},.F.,.F.,"","_dDtFec","",.T.,0,.T.,.F.,.T.,"Dt Fechamento *		",2,,CLR_BLACK,"")
	_oGet04:SetFocus()

	_oGet05 := TGet():New(095,010,{|u|if(Pcount()>0,_dDtPag := u,_dDtPag)	},_oDlgIni,060,012,"@!",{|| .T.},RGB(47,79,79),RGB(245,245,245),,.F.,Nil,.T.,Nil,.F.,{|| .T.},.F.,.F.,{|| .T.},.F.,.F.,"","_dDtPag","",.T.,0,.T.,.F.,.T.,"Dt Pagamento *		",2,,CLR_BLACK,"")


	_oTSayCalc	:= TSay():New(115,010,{||'Processar *'		},_oDlgIni,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	_oRadCalc	:= TRadMenu():New(115,090,{"Calculo e Fechamento", "Somente Calculo", "Somente Fechamento"},,_oDlgIni,,,,,,,,80,10,,,,.T.)
	_oRadCalc:bSetGet := {|u| Iif(PCount()==0, _nTpCalc, _nTpCalc := u) }
	_oRadCalc:bChange := {|| fDataFec() }


	_oBtConf	:= TButton():New(155,005," Confirmar"	,_oDlgIni,{|| _oProc:Activate()	},65,16,,,.F.,.T.,.F.,,.F.,,,.F.)
	_oBtSair	:= TButton():New(155,075," Sair"		,_oDlgIni,{|| _oDlgIni:End()	},65,16,,,.F.,.T.,.F.,,.F.,,,.F.)

	_oDlgIni:Activate(,,,.T.,{|| .T.},,{|| .T.} )

Return Nil

Static Function fDataFec()

	If _nTpCalc == 3
		//Verifica Competencia se existe mais de um fechamento
		_dDtSel := fVerifComp(SubStr(DtoS(_dDtIni),1,4), _dFecMes, .T.)

		If Type("_dDtSel") == "D"
			_dDtFec := _dDtSel
			_dDtPag	:= (_dDtFec + 1)

			_oGet04:Refresh()
			_oGet05:Refresh()

		Else
			MsgInfo("Não existe cálculo em Aberto para fazer o Fechamento!")
		Endif

		_oGet04:lReadOnly := .T.
		_oGet04:Refresh()

	Else
		_oGet04:lReadOnly := .F.
		_oGet04:Refresh()

	Endif


Return

Static Function CallRnw()

//Cria novamente a chamada da rotina
	_oProc		:= MsNewProcess():New({ || fCalcula() },"Processando","Aguarde...",.F.)

Return

static function fCalcula

	Local aVend := {}
	Local n

	cQueryTab := "  "
	cQueryTab += "SELECT C5_FILIAL FILIAL, C5_EMISSAO EMISSAO, C5_VEND2 VEND2,SA3.A3_NOME PRINCIPAL, C5_VEND3 VEND3, NVL(SA32.A3_NOME,' ') SECUNDARIO, C5_NUM PEDIDO,A1_NOME NOME,   "
	cQueryTab += "A1_COD CLIENTE, A1_LOJA LOJA, "
	cQueryTab += "SUM(C6_VALOR) TOTAL,  "
	cQueryTab += "SUM(CASE WHEN C5_VEND3 <> ' ' THEN C6_VALOR/2 ELSE C6_VALOR END) VALOR,  "
	cQueryTab += "CASE WHEN C5_VEND3 <> ' ' THEN 'METADE' ELSE 'TOTAL' END TIPO  "
	cQueryTab += "FROM "+RETSQLNAME("SC5")+" SC5  "
	cQueryTab += "INNER JOIN "+RETSQLNAME("SC6")+" SC6 on C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_CLI = C5_CLIENTE AND C6_LOJA = C5_LOJACLI AND SC6.D_E_L_E_T_ <> '*' "
	cQueryTab += "LEFT JOIN "+RETSQLNAME("SA3")+" SA3 on SA3.A3_COD = C5_VEND2 AND SA3.D_E_L_E_T_ <> '*' "
	cQueryTab += "LEFT JOIN "+RETSQLNAME("SA3")+" SA32 on SA32.A3_COD = C5_VEND3 AND SA32.D_E_L_E_T_ <> '*' "
	cQueryTab += "INNER JOIN "+RETSQLNAME("SA1")+" SA1 on A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ <> '*' "
	cQueryTab += "WHERE C5_EMISSAO > '"+DTOS(_dFecMes)+"' AND C5_EMISSAO <= '"+DTOS(_dDtFec)+"' AND SC5.D_E_L_E_T_ <> '*' "
	cQueryTab += "AND C5_VEND1 <> ' ' "
	cQueryTab += "AND C5_VEND2 NOT IN ('113396','110641', '6001') "
	//cQueryTab += "AND C5_VEND2 = '30771' "
	cQueryTab += "AND A1_NREDUZ <> 'MRV' " 
	cQueryTab += "AND C6_NOTA <> ' ' "
	//cQueryTab += "AND C6_NUM IN (select E3_PEDIDO from SE3010 where E3_VEND = '30771' AND E3_EMISSAO >= '20251001') "
	cQueryTab += "AND C6_TES <> '598' AND C6_TES <> '905' AND C6_TES <> '921' AND C5_NUM <> '004298'  "
	cQueryTab += "AND C5_VEND2 <> ' ' "
	cQueryTab += "GROUP BY C5_FILIAL, C5_EMISSAO, C5_VEND2, C5_VEND3, C5_NUM,A1_NOME, A1_COD, A1_LOJA, SA3.A3_NOME, SA32.A3_NOME  "
	cQueryTab += "ORDER BY C5_VEND2 "
	
	TCQuery cQueryTab New Alias 'QRY_TAB'

	cUpdQry := " UPDATE ZP3010 SET D_E_L_E_T_ = '*' WHERE ZP3_ANO = '"+Year2Str(_dDtFec)+"' AND ZP3_MES = '"+Month2Str(_dDtFec)+"' AND D_E_L_E_T_ <> '*' "
	If (TCSQLExec(cUpdQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	dbselectarea("QRY_TAB")
	dbgotop()
	WHILE QRY_TAB->(!EOF())
		
		RECLOCK("ZP3",.T.)

		ZP3_FILIAL := QRY_TAB->FILIAL
		ZP3_VEND1 := QRY_TAB->VEND1
		ZP3_ANO := Year2Str(STOD(QRY_TAB->EMISSAO))
		ZP3_MES := Month2Str(STOD(QRY_TAB->EMISSAO))
		ZP3_EMISSAO := STOD(QRY_TAB->EMISSAO)
		ZP3_VEND2 := QRY_TAB->VEND2
		ZP3_PEDIDO := QRY_TAB->PEDIDO
		ZP3_CLIENT := QRY_TAB->CLIENTE
		ZP3_LOJA := QRY_TAB->LOJA
		ZP3_TOTAL := QRY_TAB->TOTAL
		ZP3_VALOR := QRY_TAB->VALOR
		ZP3_TIPO := QRY_TAB->TIPO

		MSUNLOCK()

		/*
		PRINCIPAL
		SECUNDARIO
		NOME
		//METADE TOTAL
		*/

		QRY_TAB->(DBSKIP())
	END

	FWAlertSuccess("Calculado com Sucesso", "Sucesso")

	cQueryZP3 := " SELECT ZP3_VEND1,ZP0_PERC, SUM(ZP3_VALOR) VALOR FROM ZP3010 ZP3 "
	cQueryZP3 += "inner join "+RETSQLNAME("ZP0")+" on ZP0_CODIGO = ZP3_MES AND ZP0_ANO = ZP3_ANO AND ZP0_CODSA3 = ZP3_VEND1 "
	cQueryZP3 += "WHERE ZP3_ANO = '"+Year2Str(_dDtFec)+"' AND ZP3_MES = '"+Month2Str(_dDtFec)+"' AND ZP0_LOCAL = 'I' AND ZP3.D_E_L_E_T_ <> '*' "
	cQueryZP3 += "group by ZP3_VEND1,ZP0_PERC"

	TCQuery cQueryZP3 New Alias 'ZP3_TAB'

	cUpdZP1 := " UPDATE "+RETSQLNAME("ZP1")+" SET D_E_L_E_T_ = '*' WHERE ZP1_ANO = '"+Year2Str(_dDtFec)+"' AND ZP1_MES = '"+Month2Str(_dDtFec)+"' AND ZP0_LOCAL = 'I' AND D_E_L_E_T_ <> '*' "
	If (TCSQLExec(cUpdZP1) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	dbselectarea("ZP3_TAB")
	dbgotop()
	WHILE ZP3_TAB->(!EOF())

		RECLOCK("ZP1",.T.)
		ZP1_CODSA3 := ZP3_TAB->ZP3_VEND1
		ZP1_ANO := Year2Str(_dDtFec)
		ZP1_MES := Month2Str(_dDtFec)
		ZP1_DTINI := _dDtFec
		ZP1_DTFECH := _dDtFec
		ZP1_DTPAG := _dDtFec
		ZP1_TICKET := 0
		ZP1_METAEQ := 0
		ZP1_PROSPE := 0
		ZP1_POSITI := 0 
		ZP1_META := ZP3_TAB->ZP0_PERC
		ZP1_VALOR := ZP3_TAB->VALOR
		ZP1_BONUS := 0

		MSUNLOCK()
		ZP3_TAB->(DBSKIP())
	END

	cQry1 := " "
	cQry1 += "SELECT ZP1_CODSA3 CODIGO, ZP1_META META, ZP1_VALOR VALOR FROM"+RETSQLNAME("ZP1")+" "
	cQry1 += "WHERE ZP1_ANO = "+Year2Str(_dDtFec)+" "
	cQry1 += "AND ZP1_MES = "+Month2Str(_dDtFec)+" "
	cQry1 += "AND D_E_L_E_T_ <> '*' "
	cQry1 += "ORDER BY ZP1_CODSA3 "

	TCQuery cQry1 New Alias 'ZPRC1'

	//VERIFICA QUAIS VENDEDORES ALCANCARAM A META
	WHILE !(ZPRC1)->(EOF())
		IF (ZPRC1_VALOR > ZPRC1_META)
			aadd(aVend,ZPRC1_CODIGO)
		ENDIF

	ENDDO
	
	 //VARRE O ARRAY DE VENDEDORES QUE ALCANCARAM A META
	FOR n := 1 TO Len(aVend)

		//ATUALIZA O VALOR DAS COMISSOES E PORCENTAGENS
		cQry2 := " "
		cQry2 += "UPDATE "+RETSQLNAME("SE3")+" SET E3_COMIS = (E3_BASE * 7)/100, E3_PORC = 7 "
		cQry2 += "WHERE E3_VEND = '"+aVend[n]+"' "
		cQry2 += "AND SUBSTR(E3_EMISSAO,1,6) = '"+Year2Str(_dDtFec)+Month2Str(_dDtFec)+"' "

		If (TCSQLExec(cQry2) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

		//FAZER SELECT DA SE3 COM AS COMISSÕES GERADAS DO MÊS
		cQry3 := " "
		cQry3 += "SELECT E3_FILIAL FILIAL, E3_VEND VENDEDOR, E3_EMISSAO EMISSAO ,E3_NUM DOC, E3_SERIE SERIE E3_CODCLI CLIENTE FROM "+RETSQLNAME("SE3")+" "
		cQry3 += "WHERE E3_VEND = '"+aVend[n]+"' "
		cQry3 += "AND SUBSTR(E3_EMISSAO,1,6) = '"+Year2Str(_dDtFec)+Month2Str(_dDtFec)+"' "

		TCQuery cQry3 New Alias 'ZPRC3'

			WHILE !(ZPRC3)->(EOF())

				cQry4 := " "
				cQry4 += "UPDATE "+RETSQLNAME("SD2")+"SET D2_COMIS2 = 7 "
				cQry4 += "WHERE D2_FILIAL = "+ZPRC3_FILIAL+" "
				cQry4 += "D2_EMISSAO = "+ZPRC3_EMISSAO+" "
				cQry4 += "AND D2_DOC = "+ZPRC3_DOC+" "
				cQry4 += "AND D2_SERIE = "+ZPRC3_SERIE+" "
				cQry4 += "AND D2_CLIENTE = "+ZPRC3_CODCLI+" "
				cQry4 += "AND D2_LOJA = "+ZPRC3_LOJA+" "
				cQry4 += "AND D2_COMIS2 = 5 "
				cQry4 += "AND D_E_L_E_T_ <> '*' "

				IF (TCSQLExec(cQry4) < 0)
					RETURN MsgStop("TCSQLError() " + TCSQLError())
				ENDIF

				cQry5 := " "
				cQry5 += "UPDATE "+RETSQLNAME("SE1")+"SET E1_COMIS2 = 7 "
				cQry5 += "WHERE E1_FILIAL = "+ZPRC3_FILIAL+" "
				//cQry5 += "AND E1_EMISSAO = "+ZPRC3_EMISSAO+" "
				cQry5 += "AND E1_NUM = "+ZPRC3_DOC+" "
				cQry5 += "AND E1_PREFIXO = "+ZPRC3_SERIE+" "
				cQry5 += "AND E1_CLIENTE ="+ZPRC3_CODCLI+" "
				cQry5 += "AND E1_LOJA = "+ZPRC3_LOJA+" "
				cQry5 += "AND E1_COMIS2 = 5 "
				cQry5 += "AND D_E_L_E_T_ <> '*' "

				IF (TCSQLExec(cQry5) < 0)
					RETURN MsgStop("TCSQLError() " + TCSQLError())
				ENDIF

				cQry6 := " "
				cQry6 += "UPDATE "+RETSQLNAME("SC6")+"SET C6_COMIS2 = 7 "
				cQry6 += "WHERE C6_FILIAL = "+ZPRC3_FILIAL+" "
				//cQry6 += "AND E1_EMISSAO = "+ZPRC3_EMISSAO+" "
				cQry6 += "AND C6_NOTA = "+ZPRC3_DOC+" "
				cQry6 += "AND C6_SERIE = "+ZPRC3_SERIE+" "
				cQry6 += "AND C6_CLI ="+ZPRC3_CODCLI+" "
				cQry6 += "AND C6_COMIS2 = 5 "
				cQry6 += "AND D_E_L_E_T_ <> '*' "

				IF (TCSQLExec(cQry6) < 0)
					RETURN MsgStop("TCSQLError() " + TCSQLError())
				ENDIF

				ZPRC3->(DBSKIP())

			ENDDO

			ZPRC3->(DBCLOSEAREA())

	NEXT n

RETURN
