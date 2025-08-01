//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function RCTEP01
Metas Individuais
@author Evandro Burlin
admin
@SenhaSegura9&@
@since 03/02/2025
@version 1.0
/*/

//Variveis Estaticas
Static cTitulo := "Calculo de Comissões"
Static cAliasMVC := "ZP0"

User Function RCTEP01()
	Private _oProc		:= MsNewProcess():New({ || fCalcula() },"Processando","Aguarde...",.F.)
	Private _dFecAno	:= SuperGetMV("FL_FECANO",,STOD("20241231"))
	Private _dFecMes	:= SuperGetMV("FL_FECMES",,STOD("20250131"))
	Private _dData		:= SuperGetMV("FL_COMMES",,STOD("20250131"))
	Private _dDtIni		:= (_dFecAno + 1)
	Private _dDtFec		:= LastDay(Date())
	Private _dDtPag		:= (_dDtFec + 1)
	Private _nTpCalc	:= 1

	///ADICIONAR CAMPO NOME DO VENDEDOR.

	_oDlgIni := TDialog():New(000,000,350,350,"Cálculo Período Comissão - NOVO V1",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

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

	cQueryTab := "  "
	cQueryTab += " select C5_FILIAL FILIAL, C5_EMISSAO EMISSAO, C5_VEND1 VEND1,SA3.A3_NOME PRINCIPAL, C5_VEND4 VEND2, NVL(SA32.A3_NOME,' ') SECUNDARIO, C5_NUM PEDIDO,A1_NOME NOME,  "
	cQueryTab += "A1_COD CLIENTE, A1_LOJA LOJA, "
	cQueryTab += "SUM(C6_VALOR) TOTAL,  "
	cQueryTab += "SUM(CASE WHEN C5_VEND4 <> ' ' THEN C6_VALOR/2 ELSE C6_VALOR END) VALOR,  "
	cQueryTab += "CASE WHEN C5_VEND4 <> ' ' THEN 'METADE' ELSE 'TOTAL' END TIPO  "
	cQueryTab += "from SC5010 SC5  "
	cQueryTab += "inner join SC6010 SC6 on C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_CLI = C5_CLIENTE AND C6_LOJA = C5_LOJACLI AND SC6.D_E_L_E_T_ <> '*' "
	cQueryTab += "left join SA3010 SA3 on SA3.A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ <> '*' "
	cQueryTab += "left join SA3010 SA32 on SA32.A3_COD = C5_VEND4 AND SA32.D_E_L_E_T_ <> '*' "
	cQueryTab += "inner join SA1010 SA1 on A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ <> '*' "
	cQueryTab += "where C5_EMISSAO >= '20250601' AND C5_EMISSAO <= '20250630' AND SC5.D_E_L_E_T_ <> '*' "
	cQueryTab += "AND (C5_VEND1 = '9996' OR C5_VEND4 = '9996') "
	cQueryTab += "AND C5_VEND1 NOT IN ('113396','110641', '6001') "
	cQueryTab += "AND A1_NREDUZ <> 'MRV' "
	cQueryTab += "AND C6_TES <> '598' AND C5_NUM <> '004298' "
	cQueryTab += "GROUP BY C5_FILIAL, C5_EMISSAO, C5_VEND1, C5_VEND4, C5_NUM,A1_NOME, A1_COD, A1_LOJA, SA3.A3_NOME, SA32.A3_NOME "
	cQueryTab += "ORDER BY C5_EMISSAO "
	
	TCQuery cQueryTab New Alias 'QRY_TAB'

	








return
