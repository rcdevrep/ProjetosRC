#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAGDOX06
Integração DOX - Inclusão de contas a receber  para Desconto de Avarias
@author Leandro Spiller 
@since 09/09/2021
@version 1.0	
/*/
User Function XAGDOX06(_oJsonDOX)

	//Local _aEmpresa := {}
	//Local cCNPJ     := ""

	Private TIPO_TIT   := "NDC"
	Private NATUREZA   := ""
	Private CONTA 	   := ""
	Private cFileBol   := ""
	Private cCartei   := ""

	Private oRetDox := DOXWsRetorno():New()

	//cCNPJ := _oJsonDOX:GetJsonText("cnpjEmpresaTitulo")
    _cEmpFil  := _oJsonDOX:GetJsonText("empFil")
	
	//If (!Empty(_aEmpresa))
		//RPCSetType(3)
	//RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"","","","",{"SA1","SE1"})

	
		RPCClearEnv()
		RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"USERREST","*R3st2021","","",{"SA1","SE1"})
        
		InserirSE1(_oJsonDOX)

	//RPCClearEnv()
	//Else
	//	RetErro("Nao foi possivel encontrar a empresa pelo CNPJ [" + cCNPJ + "] - Precisa ser CNPJ sem formatacao!")
	//EndIf

Return(oRetDox)

Static Function InserirSE1(_oJsonDOX)

	Local _aSE1         := {}
	Local cNumTitOld    := ""
    Local _i            := 0 
    Local _aParcela     := {}
    Local _nTotParc     := 0 
	Private lMsErroAuto := .F.
    Private _cCC	    := _oJsonDOX:GetJsonText("centrocusto")
    Private _cTipo 	    := _oJsonDOX:GetJsonText("tipo") // 'M' / 'A' 
    Private _nValor     := Val(_oJsonDOX:GetJsonText("valor"))
    Private _nQtdParc   := Val(_oJsonDOX:GetJsonText("quant_parcelas"))
    Private _cDataParc  := _oJsonDOX:GetJsonText("dt_parcela")
    Private _cProcesso  := _oJsonDOX:GetJsonText("processo")
    Private _cCnpjCli   := _oJsonDOX:GetJsonText("cnpjCpf")
    Private _nValorParc := 0 
    Private _cRetBaixa  := ""
	Private _nValAdto   := 0 
	Private dDtAdiant   := CToD("  /  /  ")


	//Caso não tenha o Tipo considera que é uma despesa
	If _cTipo  == 'null'
		_cTipo := 'M'
	Endif 

	//Se for adiantamento Altera Dados 
	iF _cTipo == 'M'
		NATUREZA  := '102004'
	else
        NATUREZA  := '102005'  
    Endif 

    //Valida Cnpj e CC
    If (!ValidSE1(_oJsonDOX))
		Return({})
	EndIf

    //Calcula Valor da parcela
    _nValParc := Round((_nValor / _nQtdParc ),2)

    //Grava array com Valores de parcela 
    For _i := 1 to _nQtdParc

        If _i == 1
            _dDataParc := stod(_cDataParc)
        Else
            _dDataParc := MonthSum(_dDataParc ,1)
        Endif 

        AADD(_aParcela, { _dDataParc ,_nValParc } )

        _nTotParc += _nValParc

        //Ajusta para Fechar valor em 100%
        If _i = _nQtdParc
            _aParcela[_i][2] += (_nValor - _nTotParc )
        Endif 
    
    Next _i 

    //Gera títulos por parcela
    For _i := 1 to len(_aParcela)
        
        _aSE1 := getSE1(_oJsonDOX ,_aParcela[_i][1],_aParcela[_i][2], cvaltochar(_i) )

        If (!Empty(_aSE1))

            //busca Se existe título antes de executar 

			If _i == 1
            	cNumTitOld := ExistTit(_aSE1)
			Endif 

            If alltrim(cNumTitOld) == ""

                lExibeLanc := .f.
               
                conout('XAGDOX06 - Antes Execauto')
                MSExecAuto({|x,y| Fina040(x,y)},_aSE1,3)
                conout('XAGDOX06 -  Depois Execauto')
               
                If lMsErroAuto
                    RetErro(LerLogErro())
                Else
                    If alltrim(SE1->E1_NUM) == ''
                        RetErro('ERRO AO GERAR TÍTULO, Entre em contato com a TI! ') 
					Else
						RetSucesso("Titulo Gerado com Sucesso:  " + SE1->E1_PREFIXO +' / '+SE1->E1_NUM, SE1->E1_PREFIXO +' / '+SE1->E1_NUM )
					Endif
                EndIf
            Else
            	RetSucesso("Titulo Ja Gerado  " + SE1->E1_PREFIXO +' / '+SE1->E1_NUM, SE1->E1_PREFIXO +' / '+SE1->E1_NUM )	
            Endif
        EndIf

    Next _i 
	
	//Gera Boleto
	/*cNumtit := SE1->E1_PREFIXO +'/'+ SE1->E1_NUM
	If GeraBoleto(SE1->E1_FILORIG,SE1->E1_NUM,SE1->E1_CLIENTE,SE1->E1_LOJA) 
		RetSucesso("Titulo/Boleto Gerado com Sucesso:  " + cNumtit, cFileBol )
	Else
		RetErro("Não foi Possível gerar o Boleto, Verifique!")
	Endif 	*/

Return()

Static Function getSE1(_oJsonDOX , xVencto, xValor , xParcela)

	Local _aSE1     := {}
	Local _cNum     := ""
	Local _cPrefixo := ""
	Local _cParcela := ""
	//Local _dVencto  := CToD("  /  /  ")

	_cNum := StrZero(Val(_cProcesso), 9)//StrZero(Val(cValToChar(Month(Date())) + cValToChar(Year(Date()))), 9)
	_cPrefixo := 'NDC'
	_cParcela := xParcela

	aAdd(_aSE1, {"E1_FILORIG", cFilAnt, Nil})
	aAdd(_aSE1, {"E1_MSFIL"  , cFilAnt, Nil})
	aAdd(_aSE1, {"E1_FILIAL" , xFilial("SE1"), Nil})

	aAdd(_aSE1, {"E1_PREFIXO", _cPrefixo, Nil})
	aAdd(_aSE1, {"E1_NUM"    ,  _cNum   , Nil})
	aAdd(_aSE1, {"E1_PARCELA", _cParcela, Nil})

	aAdd(_aSE1, {"E1_TIPO"   , TIPO_TIT, Nil})
	aAdd(_aSE1, {"E1_NATUREZ", NATUREZA, Nil})
	aAdd(_aSE1, {"E1_ORIIMP" , "XAGDOX06", Nil})
	aAdd(_aSE1, {"E1_CTA"    , CONTA, Nil})

	aAdd(_aSE1, {"E1_CLIENTE", SA1->A1_COD, Nil})
	aAdd(_aSE1, {"E1_LOJA"   , SA1->A1_LOJA, Nil})
	//aAdd(_aSE1, {"E1_NOMCLI" , SA1->A1_NOME, Nil})

	aAdd(_aSE1, {"E1_EMISSAO", dDataBase, Nil})
	aAdd(_aSE1, {"E1_EMIS1"  , dDataBase, Nil})
	aAdd(_aSE1, {"E1_VENCTO" , xVencto, Nil})
	aAdd(_aSE1, {"E1_VENCREA", DataValida(xVencto), Nil})
	aAdd(_aSE1, {"E1_VENCORI", xVencto, Nil})

	aAdd(_aSE1, {"E1_HIST"   , 'Processo Dox:' + _cProcesso, Nil})
	aAdd(_aSE1, {"E1_CCUSTO" , _cCC, Nil})
	aAdd(_aSE1, {"E1_VALOR"  , xValor, Nil})
	aAdd(_aSE1, {"E1_SALDO"  , xValor, Nil})

    _aSE1 := FWVetByDic(_aSE1, 'SE1')

Return(_aSE1)

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

Static Function ValidSE1(_oJsonDOX)

	Local _lValidOk  := .T.
	
	Dbselectarea('SA1')
	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	If (!SA1->(DbSeek(xFilial("SA1")+_cCnpjCli)))
		RetErro("Cliente nao encontrado pelo CNPJ/CPF informado! [" + _cCnpjCli + "]")
		_lValidOk := .F.
	EndIf


	Dbselectarea('CTT')
	CTT->(DbSetOrder(1))
	CTT->(DbGoTop())
	If (!CTT->(DbSeek(xFilial("CTT")+_cCC)))
		RetErro("Centro de custo nao encontrado! [" + _cCC + "]")
		_lValidOk := .F.
	Else
		If (CTT->CTT_CLASSE <> "2")
			RetErro("Centro de custo informado não é do tipo analítico! [" + _cCC + "]")
			_lValidOk := .F.
		EndIf

		If (CTT->CTT_BLOQ == "1")
			RetErro("Centro de custo informado encontra-se bloqueado para uso! [" + _cCC + "]")
			_lValidOk := .F.
		EndIf
	EndIf

Return(_lValidOk)


//Verifica se ja foi inserido título desse processo
Static Function ExistTit(xSE1)

	local cRet   := ""
	local cQuery := ""
	local nE1_FILIAL   :=  aScan(xSE1,{|x| alltrim(x[1])  == "E1_FILIAL"}) 
	local nE1_PREFIXO  :=  aScan(xSE1,{|x| alltrim(x[1])  == "E1_PREFIXO"}) 
	local nE1_NUM 	   :=  aScan(xSE1,{|x| alltrim(x[1])  == "E1_NUM"}) 
	local nE1_CLIENTE  :=  aScan(xSE1,{|x| alltrim(x[1])  == "E1_CLIENTE"}) 
	local nE1_LOJA     :=  aScan(xSE1,{|x| alltrim(x[1])  == "E1_LOJA"}) 
	local nE1_HIST     :=  aScan(xSE1,{|x| alltrim(x[1]) == "E1_HIST"}) 
	local nE1_FILORIG  :=  aScan(xSE1,{|x| alltrim(x[1]) == "E1_FILORIG"}) 
	local nE1_NATUREZ  :=  aScan(xSE1,{|x| alltrim(x[1]) == "E1_NATUREZ"}) 
	local nE1_PARCELA  :=  aScan(xSE1,{|x| alltrim(x[1]) == "E1_PARCELA"}) 
	local nE1_CTA  	   :=  aScan(xSE1,{|x| alltrim(x[1]) == "E1_CTA"}) 
	
	
	If nE1_FILIAL > 0  .and. nE1_PREFIXO > 0 .and. nE1_NUM > 0 .and.nE1_CLIENTE > 0 .and.;
	  	 nE1_LOJA > 0  .and. nE1_HIST > 0  .and. nE1_FILORIG > 0 .and. nE1_NATUREZ > 0  .and. nE1_CTA > 0

		cQuery := " SELECT R_E_C_N_O_ AS RECNO,E1_VALOR,E1_SALDO,E1_PREFIXO,E1_NUM,E1_CLIENTE,E1_LOJA FROM "+RetSqlName('SE1')+ " (NOLOCK)"
		cQuery += " WHERE "
		cQuery += " E1_FILIAL = '"+xSE1[nE1_FILIAL][2]+"' AND "
		//cQuery += " E1_NUM '"+xSE1[nE1_NUM] +"' AND " 
		cQuery += " E1_PREFIXO = '"+xSE1[nE1_PREFIXO][2] +"' AND "
		cQuery += " E1_CLIENTE = '"+xSE1[nE1_CLIENTE][2] +"' AND "
		cQuery += " E1_LOJA = '"+xSE1[nE1_LOJA][2] +"' AND "
		cQuery += " E1_NATUREZ = '"+xSE1[nE1_NATUREZ][2] +"' AND "
		cQuery += " E1_CTA = '"+xSE1[nE1_CTA][2] +"' AND "
		cQuery += " E1_PARCELA =  '"+xSE1[nE1_PARCELA][2] +"' AND "
		cQuery += " E1_HIST LIKE  '%"+alltrim(xSE1[nE1_HIST][2])+"%' AND "
		cQuery += " D_E_L_E_T_ = '' "

		If (Select("EXISTTIT") != 0)
			dbSelectArea("EXISTTIT")
			dbCloseArea()
		Endif
		TCQuery cQuery NEW ALIAS "EXISTTIT"

		If EXISTTIT->(!eof())
			cRet :=  EXISTTIT->E1_PREFIXO+' / '+  EXISTTIT->E1_NUM
			Conout('XAGDOX02 - Ja Existe Título '+ EXISTTIT->E1_PREFIXO+' - '+  EXISTTIT->E1_NUM  )
		Endif 
	Else
		Conout('XAGDOX02 - NÃO ENCONTROU CAMPOS')
	Endif 	


	//Posiciona na SE1
	If !Empty(cRet)
		DbSelectAre('SE1')
		DbGoto(EXISTTIT->RECNO)
	Endif 
	
	If (Select("EXISTTIT") != 0)
		dbSelectArea("EXISTTIT")
		dbCloseArea()
	Endif


		
Return  cRet
