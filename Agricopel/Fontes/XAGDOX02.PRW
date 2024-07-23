#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGDOX02
Integração DOX - Inclusão de contas a pagar para reembolso de viagem
@author Leandro F Silveira
@since 28/06/2019
@version 1.0	
/*/
User Function XAGDOX02(_oJsonDOX)

	Local _aEmpresa := {}
	Local cCNPJ     := ""

	Private TIPO_TIT := "DP"
	Private NATUREZA := "219012"
	Private CONTA 	 := "52111515"

	Private oRetDox := DOXWsRetorno():New()

	cCNPJ := _oJsonDOX:GetJsonText("cnpjEmpresaTitulo")

	_aEmpresa := GetEmpresa(cCNPJ)
	
	If len(_aEmpresa) > 0 
		//RPCSetType(3)
		//RPCSetEnv(_aEmpresa[1], _aEmpresa[2])

		RPCClearEnv()
		RPCSetEnv(_aEmpresa[1], _aEmpresa[2],"USERREST","*R3st2021","","")

		InserirSE2(_oJsonDOX)

		//RPCClearEnv()
	Else
		RetErro("XAGDOX02 - Não foi possível encontrar a empresa, CNPJ [" + cCNPJ + "] - Entre em contato com a TI!")
	EndIf

Return(oRetDox)

Static Function RetErro(msgErro)

	oRetDox:errorMessage += msgErro + "|"
	oRetDox:Sucesso      := .F.

Return()

Static Function RetSucesso(mensagem,xTitulo)

	oRetDox:errorMessage := ""
	oRetDox:msgSucesso   := mensagem
	oRetDox:Sucesso      := .T.
	oRetDox:observacao   := xTitulo

Return()

Static Function GetEmpresa(CNPJ_PED)

	Local _aEmpresa := {}
	Local nCont

	//OpenSM0()
	//SET DELETE ON
	//SM0->(DbGoTop())
	aSM0 := FWLoadSM0()

	For nCont:=1 to Len(aSM0)
		If Alltrim(aSM0[nCont][18]) ==  Alltrim(CNPJ_PED)
			_aEmpresa := {Alltrim(aSM0[nCont][1]),Alltrim(aSM0[nCont][2])}
		EndIf
	Next

	/*While (!SM0->(Eof()))
		If (SM0->M0_CGC == CNPJ_PED)
			_aEmpresa := {SM0->M0_CODIGO, Alltrim(SM0->M0_CODFIL)}
			Exit
		EndIf()

		SM0->(DbSkip())
	End

	dbCloseAll()*/

Return(_aEmpresa)

Static Function InserirSE2(_oJsonDOX)

	Local _aSE2 := {}
	Local cNumTitOld := ""
	Private lMsErroAuto := .F.
	Private _cTitAdto   := _oJsonDOX:GetJsonText("adiantamentoNumero")
	Private _cValAdto   := _oJsonDOX:GetJsonText("adiantamentoValor")
	Private _cTipo 	    := _oJsonDOX:GetJsonText("tipo")
	Private _cRetBaixa  := ""
	Private _nValAdto   := 0 
	Private dDtAdiant   := CToD("  /  /  ")


	//Caso não tenha o Tipo considera que é uma despesa
	If _cTipo  == 'null'
		_cTipo := 'DESP'
	Endif 

	//Caso não envie o conteudo alimenta a Variável 
	If _cTitAdto == 'null'
		_cTitAdto := ""
	Endif
	If _cValAdto == 'null'
		_nValAdto := 0 
	Else
		_nValAdto := Val(_cValAdto)
	Endif 

	//Se for adiantamento Altera Dados 
	iF _cTipo == 'ADTO'
		CONTA     := '112040001'
		NATUREZA  := '201005'
		dDtAdiant := ctod(_oJsonDOX:GetJsonText("dtAdiantamento"))
	Endif 

	_aSE2 := getSE2(_oJsonDOX)

	If (!Empty(_aSE2))

		//busca Se existe título
		cNumTitOld := ExistTit(_aSE2)
	
		If alltrim(cNumTitOld) == ""


			lExibeLanc := .f.
			//conout('XAGDOX02 - Antes Execauto')
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, _aSE2,, 3)
			//conout('XAGDOX02 -  Depois Execauto')
			If lMsErroAuto
				RetErro(LerLogErro())
			Else
				If alltrim(SE2->E2_NUM) == ''
					RetErro('ERRO AO GERAR TÍTULO, Entre em contato com a TI! ') 
				Else
					If _nValAdto > 0 
						_cRetBaixa := BaixaAdto()
					Endif 
					If _cRetBaixa <> 'ERRO'
						RetSucesso("Titulo gerado: " + SE2->E2_NUM + "/" + SE2->E2_PARCELA , SE2->E2_NUM + "/" + SE2->E2_PARCELA )
					Endif 
				End
			EndIf
		Else
			If _nValAdto > 0 
				_cRetBaixa := BaixaAdto()
			Endif 
			If _cRetBaixa <> 'ERRO'
				RetSucesso("Titulo ja gerado: " + cNumTitOld, cNumTitOld )
			Endif 	
		
		Endif
	EndIf

Return()

Static Function getSE2(_oJsonDOX)

	Local _aSE2     := {}
	Local _cNum     := ""
	Local _cPrefixo := ""
	Local _cParcela := ""
	Local _dVencto  := CToD("  /  /  ")

	If (!ValidSE2(_oJsonDOX))
		Return({})
	EndIf

	_cNum := StrZero(Val(cValToChar(Month(Date())) + cValToChar(Year(Date()))), 9)
	_cPrefixo := cFilAnt
	_cParcela := CalcParcel(_cNum, _cPrefixo)

	//conout('dDtAdiant')
	//conout(dDtAdiant)
	//Se preenchido data de adiantamento subs
	If !Empty(dDtAdiant)
		_dVencto  := dDtAdiant
	Else 
		_dVencto  := CalcVencto()
	Endif 

	//conout('_dVencto')
	//conout(_dVencto)

	aAdd(_aSE2, {"E2_FILORIG", cFilAnt, Nil})
	aAdd(_aSE2, {"E2_MSFIL", cFilAnt, Nil})
	aAdd(_aSE2, {"E2_FILIAL", xFilial("SE2"), Nil})

	aAdd(_aSE2, {"E2_PREFIXO", _cPrefixo, Nil})
	aAdd(_aSE2, {"E2_NUM", _cNum, Nil})
	aAdd(_aSE2, {"E2_PARCELA", _cParcela, Nil})

	aAdd(_aSE2, {"E2_TIPO", TIPO_TIT, Nil})
	aAdd(_aSE2, {"E2_NATUREZ", NATUREZA, Nil})
	aAdd(_aSE2, {"E2_ORIIMP", "XAGDOX02", Nil})
	aAdd(_aSE2, {"E2_CTA", CONTA, Nil})

	aAdd(_aSE2, {"E2_FORNECE", SA2->A2_COD, Nil})
	aAdd(_aSE2, {"E2_LOJA", SA2->A2_LOJA, Nil})
	aAdd(_aSE2, {"E2_NOMFOR", SA2->A2_NOME, Nil})

	aAdd(_aSE2, {"E2_EMISSAO", dDataBase, Nil})
	aAdd(_aSE2, {"E2_EMIS1", dDataBase, Nil})
	aAdd(_aSE2, {"E2_VENCTO", _dVencto, Nil})
	aAdd(_aSE2, {"E2_VENCREA", DataValida(_dVencto), Nil})
	aAdd(_aSE2, {"E2_VENCORI", _dVencto, Nil})

	aAdd(_aSE2, {"E2_HIST", _oJsonDOX:GetJsonText("observacao") + ' - '+iif(_cTipo == 'ADTO','Adiantamento','Despesa'), Nil})
	aAdd(_aSE2, {"E2_CCUSTO", _oJsonDOX:GetJsonText("centroCusto"), Nil})
	aAdd(_aSE2, {"E2_VALOR", Val(_oJsonDOX:GetJsonText("valor")), Nil})
	aAdd(_aSE2, {"E2_SALDO", Val(_oJsonDOX:GetJsonText("valor")), Nil})

	aAdd(_aSE2, {"E2_NOMERET", "", Nil})
	aAdd(_aSE2, {"E2_MOEDA", 1, Nil})
	aAdd(_aSE2, {"E2_ORIGEM", "FINA050", Nil})

	aAdd(_aSE2, {"E2_FLUXO", "S", Nil})
	aAdd(_aSE2, {"E2_LA", "N", Nil})

Return(_aSE2)

Static Function CalcParcel(_cNum, _cPrefixo)

	Local _lExiste   := .T.
	Local _cParcela  := "A"
	Local _cQuery    := ""
	Local _cAliasSE2 := GetNextAlias()

	While (_lExiste)
		_cQuery := " SELECT COUNT(E2_NUM) AS QTDE "
		_cQuery += " FROM " + RetSqlName("SE2") + " SE2 WITH (NOLOCK) "
		_cQuery += " WHERE SE2.E2_FORNECE = '" + SA2->A2_COD + "'"
		_cQuery += " AND   SE2.E2_LOJA = '" + SA2->A2_LOJA + "'"
		_cQuery += " AND   SE2.E2_PREFIXO = '" +_cPrefixo + "'"
		_cQuery += " AND   SE2.E2_NUM = '" +_cNum + "'"
		_cQuery += " AND   SE2.E2_PARCELA = '" + _cParcela + "'"
		_cQuery += " AND   SE2.E2_TIPO = '" + TIPO_TIT + "'"
		_cQuery += " AND   SE2.D_E_L_E_T_ = '' "

		TCQuery _cQuery New Alias (_cAliasSE2)

		If ((_cAliasSE2)->QTDE == 0)
			_lExiste := .F.
		Else
			If (_cParcela <> "Z")
				_cParcela := Soma1(_cParcela)
			Else
				_cParcela := "AA"
			EndIf
		EndIf

		(_cAliasSE2)->(DbCloseArea())
		_cAliasSE2 := GetNextAlias()
	End

Return(_cParcela)

Static Function CalcVencto()

	Local _dVencto   := dDataBase
	Local _nDiaSeman := DoW(dDataBase)

	If (_nDiaSeman) == 1 // Domingo
		_dVencto := DaySum(dDataBase, 4)
	ElseIf (_nDiaSeman) == 2 // Segunda-feira
		_dVencto := DaySum(dDataBase, 3)
	ElseIf (_nDiaSeman) == 3 // Terca-feira
		_dVencto := DaySum(dDataBase, 2)
	ElseIf (_nDiaSeman) == 4 // Quarta-feira
		_dVencto := DaySum(dDataBase, 8)
	ElseIf (_nDiaSeman) == 5 // Quinta-feira
		_dVencto := DaySum(dDataBase, 7)
	ElseIf (_nDiaSeman) == 6 // Sexta-feira
		_dVencto := DaySum(dDataBase, 6)
	ElseIf (_nDiaSeman) == 7 // Sabado
		_dVencto := DaySum(dDataBase, 5)
	EndIf

Return(_dVencto)

Static Function LerLogErro()

	Local cRet       := ""
	Local nX         := 0
	Local aErroLog   := GetAutoGRLog()

	If Len(aErroLog) > 0

		cRet := "Lendo erro: "

		For nX := 1 to Len(aErroLog)
			cRet += AllTrim(aErroLog[nX])
		End
	Else
		cRet := MostraErro("/dirdoc", "error.log")
	EndIf

Return(cRet)

Static Function ValidSE2(_oJsonDOX)

	Local _lValidOk  := .T.
	Local _cCnpjForn := ""
	Local _cCCusto   := ""

	_cCnpjForn := _oJsonDOX:GetJsonText("cnpjCpfParaReembolso")

	Dbselectarea('SA2')
	SA2->(DbSetOrder(3))
	SA2->(DbGoTop())
	If (!SA2->(DbSeek(xFilial("SA2")+_cCnpjForn)))
		RetErro("Fornecedor nao encontrado pelo CNPJ/CPF informado! [" + _cCnpjForn + "]")
		_lValidOk := .F.
	EndIf

	_cCCusto := _oJsonDOX:GetJsonText("centroCusto")

	Dbselectarea('CTT')
	CTT->(DbSetOrder(1))
	CTT->(DbGoTop())
	If (!CTT->(DbSeek(xFilial("CTT")+_cCCusto)))
		RetErro("Centro de custo nao encontrado! [" + _cCCusto + "]")
		_lValidOk := .F.
	Else
		If (CTT->CTT_CLASSE <> "2")
			RetErro("Centro de custo informado não é do tipo analítico! [" + _cCCusto + "]")
			_lValidOk := .F.
		EndIf

		If (CTT->CTT_BLOQ == "1")
			RetErro("Centro de custo informado encontra-se bloqueado para uso! [" + _cCCusto + "]")
			_lValidOk := .F.
		EndIf
	EndIf

Return(_lValidOk)


//Verifica se ja foi inserido título desse processo
Static Function ExistTit(xSE2)

	local cRet   := ""
	local cQuery := ""
	local nE2_FILIAL   :=  aScan(xSE2,{|x| alltrim(x[1])  == "E2_FILIAL"}) 
	local nE2_PREFIXO  :=  aScan(xSE2,{|x| alltrim(x[1])  == "E2_PREFIXO"}) 
	local nE2_NUM 	   :=  aScan(xSE2,{|x| alltrim(x[1])  == "E2_NUM"}) 
	local nE2_FORNECE  :=  aScan(xSE2,{|x| alltrim(x[1])  == "E2_FORNECE"}) 
	local nE2_LOJA     :=  aScan(xSE2,{|x| alltrim(x[1])  == "E2_LOJA"}) 
	local nE2_HIST     :=  aScan(xSE2,{|x| alltrim(x[1]) == "E2_HIST"}) 
	local nE2_FILORIG  :=  aScan(xSE2,{|x| alltrim(x[1]) == "E2_FILORIG"}) 
	local nE2_NATUREZ  :=  aScan(xSE2,{|x| alltrim(x[1]) == "E2_NATUREZ"}) 
	local nE2_CTA  	   :=  aScan(xSE2,{|x| alltrim(x[1]) == "E2_CTA"}) 
	
	
	If nE2_FILIAL > 0  .and. nE2_PREFIXO > 0 .and. nE2_NUM > 0 .and.nE2_FORNECE > 0 .and.;
	  	 nE2_LOJA > 0  .and. nE2_HIST > 0  .and. nE2_FILORIG > 0 .and. nE2_NATUREZ > 0  .and. nE2_CTA > 0

		cQuery := " SELECT R_E_C_N_O_ AS RECNO,E2_VALOR,E2_SALDO,E2_PREFIXO,E2_NUM,E2_FORNECE,E2_LOJA FROM "+RetSqlName('SE2')+ " (NOLOCK)"
		cQuery += " WHERE "
		cQuery += " E2_FILIAL = '"+xSE2[nE2_FILIAL][2]+"' AND "
		//cQuery += " E2_NUM '"+xSE2[nE2_NUM] +"' AND " 
		cQuery += " E2_PREFIXO = '"+xSE2[nE2_PREFIXO][2] +"' AND "
		cQuery += " E2_FORNECE = '"+xSE2[nE2_FORNECE][2] +"' AND "
		cQuery += " E2_LOJA = '"+xSE2[nE2_LOJA][2] +"' AND "
		cQuery += " E2_NATUREZ = '"+xSE2[nE2_NATUREZ][2] +"' AND "
		cQuery += " E2_CTA = '"+xSE2[nE2_CTA][2] +"' AND "
		//cQuery += " E2_ORIIMP =  'XAGDOX02' AND "
		cQuery += " E2_HIST LIKE  '%"+alltrim(xSE2[nE2_HIST][2])+"%' AND "
		cQuery += " D_E_L_E_T_ = '' "

		If (Select("EXISTTIT") != 0)
			dbSelectArea("EXISTTIT")
			dbCloseArea()
		Endif
		TCQuery cQuery NEW ALIAS "EXISTTIT"

		If EXISTTIT->(!eof())
			cRet :=  EXISTTIT->E2_PREFIXO+' / '+  EXISTTIT->E2_NUM
			Conout('XAGDOX02 - Ja Existe Título '+ EXISTTIT->E2_PREFIXO+' - '+  EXISTTIT->E2_NUM  )
		Endif 
	Else
		Conout('XAGDOX02 - NÃO ENCONTROU CAMPOS')
	Endif 	


	//Posiciona na SE2
	If !Empty(cRet)
		DbSelectAre('SE2')
		DbGoto(EXISTTIT->RECNO)
	Endif 
	
	If (Select("EXISTTIT") != 0)
		dbSelectArea("EXISTTIT")
		dbCloseArea()
	Endif


		
Return  cRet

// Ao prestar contas, precisa debitar o valor do adiantamento
//no título de prestação de Contas
Static Function BaixaAdto()

    Local lExibeLanc := .F.
    Local lOnline    := .T.
	Local cRet       := ""
 
    //Operação a ser realizada (3 = Baixa, 5 = cancelamento, 6 = Exclusão)
    Default nOpc := 3
    //Se Valor da prestaçãode contas for Menor que Adiantamento baixa integral 
    Default nVlrPag := iif(SE2->E2_VALOR < _nValAdto , SE2->E2_VALOR , _nValAdto)
    //Sequência de baixa 
    Default nSeqBx := 1
 
    Private lMsErroAuto := .F.
    Private cHistBaixa := "Bx adiantamento "+_cTitAdto 
 	
	aBaixa := {}        
	
	Aadd(aBaixa, {"E2_FILIAL"   , SE2->E2_FILIAL,  nil})
	Aadd(aBaixa, {"E2_PREFIXO"  , SE2->E2_PREFIXO,  nil})
	Aadd(aBaixa, {"E2_NUM"      , SE2->E2_NUM,      nil})
	Aadd(aBaixa, {"E2_PARCELA"  , SE2->E2_PARCELA,  nil})
	Aadd(aBaixa, {"E2_TIPO"	    , SE2->E2_TIPO,     nil})
	Aadd(aBaixa, {"E2_FORNECE"  , SE2->E2_FORNECE,  nil})
	Aadd(aBaixa, {"E2_LOJA"	    , SE2->E2_LOJA ,    nil})
	Aadd(aBaixa, {"AUTMOTBX"    , "NOR",            nil})
	Aadd(aBaixa, {"AUTBANCO"    , "999",            nil})
	Aadd(aBaixa, {"AUTAGENCIA"  , "99999",          nil})
	Aadd(aBaixa, {"AUTCONTA"    , "9999999999",     nil})
	Aadd(aBaixa, {"AUTDTBAIXA"  , dDataBase,        nil})
	Aadd(aBaixa, {"AUTDTCREDITO", dDataBase,        nil})
	Aadd(aBaixa, {"AUTHIST"     , cHistBaixa,       nil})
	Aadd(aBaixa, {"AUTVLRPG"    , nVlrPag,          nil})

	//Pergunte da rotina
	AcessaPerg("FINA080", .F.)                  
	
	//Chama a execauto da rotina de baixa manual (FINA080)
	MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aBaixa, nOpc, .F., nSeqBx, lExibeLanc, lOnline)
	
	If lMsErroAuto
		RetErro(LerLogErro())
		cRet := "ERRO"
	Else
		If nOpc == 3
			CONOUT("Baixa efetuada com sucesso")
		Else
			CONOUT("Exclusão realizada com sucesso")
		EndIf
		cRet := " Baixado: "+alltrim(str(nVlrPag))
	EndIf
	
Return cRet
