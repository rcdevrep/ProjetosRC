#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include 'RestFul.CH'

/*/{Protheus.doc} XAGDOX03
Integração DOX - Alteração de Preços TRR
@author Leandro Spiller
@since 20/10/2020
@version 1.0
/*/
User Function XAGDOX03(_oJsonDOX)

	//Local _aEmpresa := {}
	Local _cTipoReq := ""
	Private _cEmpFil  := ""
	Private oRetDox    := DOXWsRetorno():New()
	Private nGapS10  
    Private nGapS500 
    Private nMaxNv1  
    Private nMaxNv2  
	Private _cAliasSA1 := 'XSA1'

	//conout(' ******* XAGDOX03 ********** ')

	_cEmpFil  := _oJsonDOX:GetJsonText("empFil")
	_cTipoReq := _oJsonDOX:GetJsonText("param")

	BuscaSM0(_cEmpFil)

	If !Empty(_cEmpFil)
		//RPCSetType(3)
		//RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"","","","",{"SA1"})
		//conout(_cTipoReq + ' - '+time())

		cEmpAnt := substr(_cEmpFil,1,2)
		cFilAnt := substr(_cEmpFil,3,2)
		cNumEmp := _cEmpFil
		//conout('XAGDOX03 ClearEnv- 38 '+ cNumEmp)
		RPCClearEnv()
		conout('XAGDOX03 ClearEnv - 40 '+ cNumEmp)
		cEmpAnt := substr(_cEmpFil,1,2)
		cFilAnt := substr(_cEmpFil,3,2)
		cNumEmp := _cEmpFil
		//conout('XAGDOX03 SETENV - 44 '+ cNumEmp)
		RPCSetType(3)
		RPCSetEnv(substr(_cEmpFil,1,2), substr(_cEmpFil,3,2),"USERREST","*R3st2021","","",{"SA1"})
		//conout('XAGDOX03 SETENV - 46 '+ cNumEmp)
		If _cTipoReq == 'BUSCAR'
			BuscaDados(_oJsonDOX)
		Elseif _cTipoReq == 'GRAVAR'
			GravaDados(_oJsonDOX)	
		Elseif _cTipoReq == 'TIPO'
			BuscaTipo('Json')	
		Endif 

		If Select(_cAliasSA1) <> 0
			dbSelectArea(_cAliasSA1)
   			dbCloseArea()
		Endif    
		
		cEmpAnt := substr(_cEmpFil,1,2)
		cFilAnt := substr(_cEmpFil,3,2)
		cNumEmp := _cEmpFil
		//conout('XAGDOX03 ClearEnv - 63 '+ cNumEmp)
		RPCClearEnv()
		//conout('XAGDOX03 ClearEnv - 65 '+ cNumEmp)
		cEmpAnt := substr(_cEmpFil,1,2)
		cFilAnt := substr(_cEmpFil,3,2)
		cNumEmp := _cEmpFil


	Else
		RetErro("Nao foi possivel encontrar a empresa no Protheus!")
	EndIf

Return(oRetDox)


Static Function BuscaDados(_oJsonDOX)


	local cRet     := ""
	Local cCodLoja := ""
	Local cCnpjCli := ""
	Local cCodCli  := cLoja := cTpProd := cCondPagto := cTabPrec := ""
	Local cFaixa   := cCateg := cVendedor  := ""
	Local nPrcAnt  := nPrcFaix := 0
	Local aTipos   := {}
	Local _I       := 0

	cCodLoja := _oJsonDOX:GetJsonText("cnpjCliente")
	//conout('BuscaSA1 INI - '+ cCodLoja + ' - '+time())
	//conout(cCodLoja)
	//Dbselectarea('SA1')
	//DbSetOrder(3)
	If BuscaSA1(alltrim(cCodLoja))//DbSeek(xfilial('SA1') + alltrim(cCodLoja))
		//CONOUT(cQuery)
		cCodCli  := (_cAliasSA1)->A1_COD 
		cLoja    := (_cAliasSA1)->A1_LOJA
		If xfilial('ZDH') == '15' .or. xfilial('ZDH')  == '11' .or. xfilial('ZDH')  == '17' .or. xfilial('ZDH')  == '18' .or. xfilial('ZDH')  == '05' 
			cVendedor  := (_cAliasSA1)->A1_VEND7 
			cVendedor2 := (_cAliasSA1)->A1_VEND6
		Else
			cVendedor  := (_cAliasSA1)->A1_VEND3 
			cVendedor2 := (_cAliasSA1)->A1_VEND5 
		Endif
		cCnpjCli := (_cAliasSA1)->A1_CGC
	Else
		RetErro("Cliente Não encontrado: " + cCodLoja )
	Endif 
	//conout('BuscaSA1 FIM - '+ cCodLoja + ' - '+time())
	//conout('XAG0062G INI - '+ cCodLoja + ' - '+time())
	cCondPagto := U_XAG0062G("COND_PAGTO_PADRAO", .T., .F.)
	cTabPrec   := U_XAG0062G("TABELA_PADRAO", .T., .F.)
	//conout('XAG0062G FIM - '+ cCodLoja + ' - '+time())

	//conout('XAG0062D INI - '+ cCodLoja + ' - '+time())
	cCateg := U_CalcCateg(cCnpjCli) //StaticCall(XAG0062D, CalcCateg, cCnpjCli) //CalcCateg(cCodLoja)
	cFaixa := U_CalcFaixa(cCnpjCli, cCateg, cVendedor)//StaticCall(XAG0062D, CalcFaixa, cCnpjCli, cCateg, cVendedor)//CalcFaixa(cCodLoja, cCateg, cVendedor)
	
	cRet := " Produto                          -   Prc.Ant.     -  Prc.Faixa "  +  chr(13)         
	cRet += "------------------------------------------------------------------------------"+  chr(13)
	
	aTipos := BuscaTipo('Array')
	//CONOUT('----------------------------')
	//conout(VALTYPE(aTipos))
	//conout(LEN(aTipos))
	
	For _I := 1 to len(aTipos)
		
		
		cTpProd  := aTipos[_I][1] //'1'
		nPrcAnt  := U_GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)//StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := U_GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)//StaticCall(XAG0062D,GetPrcFaix, cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		
		//Se for inteiro preciso inserir o ponto flutuante
		If INT(nPrcAnt) == nPrcAnt	
			cPrcAnt := PadR(cValToChar(nPrcAnt)+".",6,'0')
		Else 
			cPrcAnt := PadR(cValToChar(nPrcAnt),6,'0')
		Endif 

		If 	INT(nPrcFaix) == nPrcFaix	
			cPrcFaix := PadR(cValToChar(nPrcFaix)+".",6,'0') 
		Else 
			cPrcFaix := PadR(cValToChar(nPrcFaix),6,'0') 
		Endif 




			If len(aTipos[_I][2]) >= 12
				cRet     += /*PADR(*/aTipos[_I][2]/*,25,' ')*/+space(21-(int(len(aTipos[_I][2]))))+" -   R$ "+cPrcAnt+" - R$ "+cPrcFaix +  chr(13)                   
			Else
				cRet     += /*PADR(*/aTipos[_I][2]/*,25,' ')*/+space(30-(int(len(aTipos[_I][2]))))+" -   R$ "+cPrcAnt+" - R$ "+cPrcFaix +  chr(13)                   
			Endif 
		
	/*	//1=DIESEL S10;2=DIESEL S10 EVOLUX;3=DIESEL S500;4=DIESEL S500 EVOLUX 
		//Busca preços S10 
		cTpProd := '1'
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix, cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		cRet += "DIESEL S10                     -   R$ "+PadR(cValToChar(nPrcAnt),6,'0')+" - R$ "+PadR(cValToChar(nPrcFaix),6,'0')  +  chr(13)                   
		
		//Busca preços S10 (EVOLUX)
		cTpProd := '2'
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix,cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		cRet += "DIESEL S10 (EVOLUX)  -   R$ "+PadR(cValToChar(nPrcAnt),6,'0')+" - R$ "+PadR(cValToChar(nPrcFaix),6,'0')    +  chr(13)                    

		//Busca preços S500
		cTpProd := '3' 
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix,cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		cRet += "DIESEL S500                   -  R$ "+PadR(cValToChar(nPrcAnt),6,'0')+" - R$ "+PadR(cValToChar(nPrcFaix),6,'0') +  chr(13)            					

		//Busca preços S500(EVOLUX)
		cTpProd := '4'
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix,cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		cRet += "DIESEL S500(EVOLUX) -  R$ "+PadR(cValToChar(nPrcAnt),6,'0')+" - R$ "+PadR(cValToChar(nPrcFaix),6,'0')     +  chr(13)         					
	*/
	Next _I 
	cRet += "------------------------------------------------------------------------------"+  chr(13)
	//conout('XAG0062D FIM - '+ cCodLoja + ' - '+time())
	RetSucesso(cRet)

Return()


//Grava dados da Solicitação
Static Function GravaDados(_oJsonDOX)

	Local aClientes := {}
	Local cClientes := _oJsonDOX:GetJsonText("cnpjCliente")
	Local i,_i      := 0 
	Local nI        := 0 
	Local cCodLoja  := ""
	Local cCnpjCli  := ""
	Local cNomcli   := ""//SA1->A1_NOME
	Local nPrcNovo  := 0 
	Local cCodCli   := cLoja := cTpProd := cCondPagto := cTabPrec := ""
	Local cFaixa    := cCateg := cVendedor  := ""
	Local _aPreco   := {}
	Local _aPrcAnt  := {}
	Local aAprRet   := {}
	Local cNumSolic := ""
	Local lErro     := .F.
	Local cProcDox  := _oJsonDOX:GetJsonText("processo")
	Local cObs      := _oJsonDOX:GetJsonText("obs")
	Local lSucesso  := .F.
	Local oPrecos   :=  _oJsonDOX:GetJsonObject("precos")
	Local _cFilZDH  := xfilial('ZDH') 
	
	cObs := DecodeUTF8(cObs)

	aClientes := SEPARA(cClientes,';')

	//Verifico se todos os Clientes são válidos
	For i := 1 to len(aClientes)
		cCodLoja := alltrim(aClientes[i])

		If Empty(cCodLoja)
			i++
			loop
		Endif 

		//Dbselectarea('SA1')
		//DbSetOrder(3)
		If  BuscaSA1(alltrim(cCodLoja))//DbSeek(xfilial('SA1') + alltrim(cCodLoja))
			cCodCli  := (_cAliasSA1)->A1_COD 
			cLoja    := (_cAliasSA1)->A1_LOJA
			If _cFilZDH  == '15' .or. _cFilZDH  == '11' .or. _cFilZDH  == '17' .or. _cFilZDH == '18'  .or. _cFilZDH == '05' 
				cVendedor  := (_cAliasSA1)->A1_VEND7 
				cVendedor2 := (_cAliasSA1)->A1_VEND6
			Else
				cVendedor  := (_cAliasSA1)->A1_VEND3 
				cVendedor2 := (_cAliasSA1)->A1_VEND5 
			Endif
			cNomcli  := (_cAliasSA1)->A1_NOME
			cCnpjCli := (_cAliasSA1)->A1_CGC			
		Else
			RetErro("Cliente Não encontrado: " + cCodLoja )
			lErro := .T.
		Endif 
	Next i 

	//Se encontrou problema Return
	If lErro 
		Return
	Endif 


	cNumSolic := GETSXENUM('ZDH','ZDH_NUM','ZDHNUM' + substr(_cEmpFil,1,2) + _cFilZDH) 
	ConfirmSX8()	
	
	For i := 1 to len(aClientes)

		cCodLoja := alltrim(aClientes[i])

		If Empty(cCodLoja)
			i++
			loop
		Endif 

		//Dbselectarea('SA1')
		//DbSetOrder(3)
		//If DbSeek(xfilial('SA1') + alltrim(cCodLoja))
		
		If BuscaSA1(alltrim(cCodLoja))
			cCodCli    := (_cAliasSA1)->A1_COD 
			cLoja      := (_cAliasSA1)->A1_LOJA
			If _cFilZDH  == '15' .or. _cFilZDH  == '11' .or. _cFilZDH  == '17' .or. _cFilZDH == '18'  .or. _cFilZDH == '05' 
				cVendedor  := (_cAliasSA1)->A1_VEND7 
				cVendedor2 := (_cAliasSA1)->A1_VEND6
			Else
				cVendedor  := (_cAliasSA1)->A1_VEND3 
				cVendedor2 := (_cAliasSA1)->A1_VEND5 
			Endif
			cNomcli    := (_cAliasSA1)->A1_NOME	
			cCnpjCli   := (_cAliasSA1)->A1_CGC		
		Endif 

		cCondPagto := U_XAG0062G("COND_PAGTO_PADRAO", .T., .F.)
		cTabPrec   := U_XAG0062G("TABELA_PADRAO", .T., .F.)
		cCateg     := U_CalcCateg(cCnpjCli)//StaticCall(XAG0062D, CalcCateg, cCnpjCli) //CalcCateg(cCodLoja)
		cFaixa     := U_CalcFaixa(cCnpjCli, cCateg, cVendedor)//StaticCall(XAG0062D, CalcFaixa, cCnpjCli, cCateg, cVendedor)//CalcFaixa(cCodLoja, cCateg, cVendedor)
		_aPreco     := {}
		_aPrcAnt    := {}

		/*aAdd(aPreco, {oModZDI:GetValue("ZDI_TPPROD"), oModZDI:GetValue("ZDI_PRCFXA"), oModPrc:GetValue("ZDI_PRCNOV")})
    
    	aAprRet := U_XAG0062F(aPreco, nGapS10, nGapS500, nMaxNv1, nMaxNv2)
    	cMotZDH := aAprRet[1]
    	aPreco  := aAprRet[2]*/
		
		//Inicia a Transação
		BEGIN TRANSACTION
		//Grava ZDH
		Reclock('ZDH',.T.)
			ZDH_FILIAL := _cFilZDH
			ZDH_NUM    := cNumSolic//GETSXENUM('ZDH','ZDH_NUM','ZDHNUM' + substr(_cEmpFil,1,2) + XFILIAL('ZDH'))  
			ZDH_CODCLI := cCodCli
			ZDH_LOJA   := cLoja
			ZDH_NOMCLI := cNomcli
			ZDH_VEND   := cVendedor
			ZDH_VEND2  := cVendedor2
			ZDH_CATEGO := cCateg
			ZDH_FAIXA  := cFaixa
			ZDH_DATA   := dDatabase
			ZDH_HORA   := Time()
			ZDH_CONDPG := cCondPagto
			ZDH_CODTAB := cTabPrec
			ZDH_MOTIVO := ""
			ZDH_STATUS := 'A'
			ZDH_PRODOX := cProcDox
			ZDH_OBSSOL := cObs
		ZDH->(MSunlock())

		//Varre Preços e Gera array de dados
		For _i := 1 to len(oPrecos)
			
			cTpProd := oPrecos[_i]:GetJsonText("tipo")	
			nPrcNovo := Val(StrTran(oPrecos[_i]:GetJsonText("preco"),",","."))	
			//conout(cTpProd + alltrim(str(nPrcNovo)))
			nPrcAnt  := U_GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)//StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
   			nPrcFaix := U_GetPrcFaix( cFaixa, cCateg, cVendedor, cTpProd)//StaticCall(XAG0062D,GetPrcFaix, cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
			//nPrcNovo := Val(StrTran( _oJsonDOX:GetJsonText("preco"),",","."))
			AADD(_aPreco, {cTpProd, nPrcFaix, nPrcNovo});AADD(_aPrcAnt,nPrcAnt)

		Next _i 

		//GravaZDI S10 
		/*cTpProd := '1'
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
   		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix, cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		nPrcNovo := Val(StrTran( _oJsonDOX:GetJsonText("preco1"),",","."))
		AADD(_aPreco, {cTpProd, nPrcFaix, nPrcNovo});AADD(_aPrcAnt,nPrcAnt)
		
		//GravaZDI S10 (EVOLUX)
		cTpProd := '2'
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
   		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix,cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		nPrcNovo := Val(StrTran( _oJsonDOX:GetJsonText("preco2"),",","."))
		AADD(_aPreco, {cTpProd, nPrcFaix, nPrcNovo});AADD(_aPrcAnt,nPrcAnt)
	
		//GravaZDI S500
		cTpProd := '3' 
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix,cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		nPrcNovo := Val(StrTran( _oJsonDOX:GetJsonText("preco3"),",","."))
		AADD(_aPreco, {cTpProd, nPrcFaix, nPrcNovo});AADD(_aPrcAnt,nPrcAnt)
	
		//Busca preços S500(EVOLUX)
		cTpProd := '4'
		nPrcAnt  := StaticCall(XAG0062D,GetPrcAnt, cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec) //GetPrcAnt(cCodCli, cLoja, cTpProd, cCondPagto, cTabPrec)
		nPrcFaix := StaticCall(XAG0062D,GetPrcFaix,cFaixa, cCateg, cVendedor, cTpProd)//GetPrcFaix(cFaixa, cCateg, cVendedor, cTpProd)
		nPrcNovo := Val(StrTran( _oJsonDOX:GetJsonText("preco4"),",","."))
		AADD(_aPreco, {cTpProd, nPrcFaix, nPrcNovo});AADD(_aPrcAnt,nPrcAnt)
		*/
		aAprRet    := U_XAG0062F(_aPreco/*, nGapS10, nGapS500, nMaxNv1, nMaxNv2*/)
		cMotZDH    := aAprRet[1]
		aMotZDI    := aAprRet[2] //Retorna todos os motivos 

		//Varre Precos calculados e Grava motivos
		For nI := 1 to len(_aPreco)

			cMotZDI := aMotZDI[nI][2]

		   //GravaZDI(cTpProd      ,nPrcAnt    ,nPrcFaix     ,nPrcnovo     , cMotZDI )
			GravaZDI(_aPreco[nI][1],_aPrcAnt[nI],_aPreco[nI][2],_aPreco[nI][3], cMotZDI )
			
		Next nI 

		//MsUnlockAll()   
	    END TRANSACTION 

		//Atualiza Motivo na ZDH
		Reclock('ZDH',.F.)
			ZDH_MOTIVO := cMotZDH
		ZDH->(Msunlock())

		lSucesso := .T.

	Next i 
	//conout(lSucesso)
	//Processa as alterações de preços TRR
	If lSucesso
		u_XAG0062H(cNumSolic)
		RetSucesso(cNumSolic)
	Else
		RetErro("Erro ao gravar a Solicitação " + cNumSolic )	
	Endif 

Return 

Static function GravaZDI(xTipo,xPrcAnt,xPrcFx,xPrcnovo,xMotivo )

	BEGIN TRANSACTION 
	
		Reclock('ZDI',.T.)
			ZDI_FILIAL  := xFilial('ZDI')
			ZDI_NUM     := ZDH->ZDH_NUM
			ZDI_CODCLI  := ZDH->ZDH_CODCLI
			ZDI_LOJA    := ZDH->ZDH_LOJA
			ZDI_TPPROD  := xTipo
			ZDI_PRCANT  := xPrcAnt
			ZDI_PRCFXA  := xPrcFx
			ZDI_PRCNOV  := xPrcnovo
			ZDI_PRCAPR  := xPrcnovo
			ZDI_MOTIVO  := xMotivo
		ZDI->(Msunlock())

	END TRANSACTION
Return 

Static Function RetErro(msgErro)

	oRetDox:errorMessage += msgErro + "|"
	oRetDox:Sucesso      := .F.

Return()


Static Function RetSucesso(mensagem,xarray)

	oRetDox:errorMessage := ""
	oRetDox:msgSucesso   := mensagem
	oRetDox:Sucesso      := .T.
	oRetDox:arrayRet     := xarray

Return()

Static Function BuscaSM0(xEmpFil)

	OpenSM0()
	SET DELETE ON
	SM0->(DbGoTop())

	While (!SM0->(Eof()))
		If (SM0->M0_CODIGO + Alltrim(SM0->M0_CODFIL) == xEmpFil)
			Exit
		EndIf()

		SM0->(DbSkip())
	End

	dbCloseAll()

Return 


Static Function BuscaSA1(xCnpj)

	Local cQuery := ""
	Local lRetSA1 := .F. 
	Local lCodCli := .F.

	//Se tamanho for menor que 9 , significa que está mandando o codigo do Cliente
	If len(alltrim(xCnpj)) < 9 
		lCodCli := .T.
	Endif 
	
	cQuery := " SELECT A1_COD,A1_LOJA,A1_VEND3,A1_VEND5,A1_VEND6,A1_VEND7,A1_NOME,A1_CGC FROM "+RetSqlName('SA1')+"(NOLOCK) SA1 "
	cQuery += " WHERE D_E_L_E_T_ ='' AND A1_MSBLQL <> '1' "
	If lCodCli
		cQuery += " AND A1_COD + A1_LOJA = '"+ xCnpj +"' "
	Else
		cQuery += " AND A1_CGC = '"+xCnpj+"' "  
	Endif 

	//CONOUT(cQuery)
	If Select(_cAliasSA1) <> 0
		dbSelectArea(_cAliasSA1)
   		dbCloseArea()
	Endif    

	TCQuery cQuery New Alias (_cAliasSA1)

	If (_cAliasSA1)->(!Eof())
		lRetSA1 := .T.
	Endif 

Return  lRetSA1

 
//Utilizar para realizar testes:
User Function XAGDOXT()

    Local _cJson := ""
    Local _cRet  := ""

	//Buscar 
    _cJson += '{ '
    _cJson += '    "rotina": "XAGDOX03",'
	_cJson += '    "param": "BUSCAR",'
    _cJson += '	   "cnpjCliente": "03200 02", '
    _cJson += '    "obs": "Teste Leandro TI", '
    _cJson += '	   "empFil": "0103" '
    _cJson += '} '

	//Gravar 
	/*_cJson += '{ '
    _cJson += '    "rotina": "XAGDOX03",'
	_cJson += '    "param": "GRAVAR",'
	_cJson += '    "processo": "455454",'
    _cJson += '	   "cnpjCliente": "02222498000162;01317277000105", '
    _cJson += '    "obs": "Teste Leandro TI", '
	_cJson += '    "preco1": "2.01", '
	_cJson += '    "preco2": "2.02", '
	_cJson += '    "preco3": "2.03", '
	_cJson += '    "preco4": "2.04", '
    _cJson += '	   "empFil": "0103" '
    _cJson += '} '
	*/

    _cRet := ProcReq(_cJson)

    MsgInfo(_cRet)

Return()

Static Function ProcReq(_cJson)

   Local _oJsonDOX  := Nil
   Local _cRotina   := ""
   Local _cRetJson  := ""

   Private _oRet    := Nil

	bError := ErrorBlock({|oError|LogErroIni(oError)})
	BEGIN SEQUENCE
      _oJsonDOX := JsonObject():new()
      _oJsonDOX:fromJson(_cJson)

      _cRotina := "U_" + _oJsonDOX:GetJsonText("rotina") + "(_oJsonDOX)"
      _oRet := &(_cRotina)
	END SEQUENCE
	ErrorBlock(bError)

   _cRetJson := EncodeUtf8(SerialRet(_oRet))

   FreeObj(_oRet)

Return(_cRetJson)

Static Function SerialRet(_oRet)

   Local _oRetJson := Nil
   Local _cRet     := ""

   _oRetJson := JsonObject():new()

   _oRetJson["errorMessage"] := _oRet:errorMessage
   _oRetJson["errorCode"]    := _oRet:errorCode
	_oRetJson["msgSucesso"]   := _oRet:msgSucesso
	_oRetJson["sucesso"]      := If(_oRet:sucesso, .T., .F.)

   _cRet := _oRetJson:toJSON()
   FreeObj(_oRetJson)

Return(_cRet)
//Fim Testes 


/*Static Function DadosPrd()

    Local aArrCbox  := {}
    Local aCboxTmp  := {}
    Local aCboxTmp2 := {}
    Local cX3Cbox   := ""
    Local nX        := 0
	Local _cTpProd  := U_XAG0062G("TIPOS_PRODUTO")

    cX3Cbox := GetSX3Cache("ZDI_TPPROD", "X3_CBOX")

    aCboxTmp := StrToKArr(AllTrim(cX3Cbox), ";")

    For nX := 1 To Len(aCboxTmp)
        aCboxTmp2 := StrToKArr(aCboxTmp[nX],"=")

		If (aCboxTmp2[1] $ _cTpProd)
        	Aadd(aArrCBox, {aCboxTmp2[1], aCboxTmp2[2]})
		EndIf

    Next nX

Return(aArrCBox)
*/

Static Function BuscaTipo(xReturn)

    Local aArrCbox  := {}
    Local aCboxTmp  := {}
    Local aCboxTmp2 := {}
    Local cX3Cbox   := ""
    Local nX        := 0
	Local _cTpProd  := U_XAG0062G("TIPOS_PRODUTO")
	Local lTemDados := .F.
	Local _cJson    := "["

    Default xReturn := 'Array'

    cX3Cbox := GetSX3Cache("ZDI_TPPROD", "X3_CBOX")

    aCboxTmp := StrToKArr(AllTrim(cX3Cbox), ";")
	//conout('Len(aCboxTmp)')
	//conout(Len(aCboxTmp))
	For nX := 1 To Len(aCboxTmp)
        aCboxTmp2 := StrToKArr(aCboxTmp[nX],"=")
		//conout(aCboxTmp2[1]+'  $ '+_cTpProd)
		If (aCboxTmp2[1] $ _cTpProd)
        	If xReturn == 'Array'
				Aadd(aArrCBox, {aCboxTmp2[1], aCboxTmp2[2]})
			Else
				_cJson += ' {"tipo":"'+aCboxTmp2[1]+'","descricao":"'+ aCboxTmp2[2] + '"},'
				lTemDados := .T.
			Endif 
		EndIf

		//Remove virgula no Ultimo Item
		If nX == Len(aCboxTmp)
			_cJson := substr(_cJson,1,len(_cJson)-1)
			_cJson += ']'
		Endif 

    Next nX  
	
	If xReturn == 'Json'
		//conout(_cJson)
		If lTemDados 
			RetSucesso('Tem Produtos',_cJson)
		Else
			RetErro("Não encontrado Tipos de produtos para essa empresa" )
		Endif 
	Endif 
   
Return(aArrCBox)
