#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} Classe XAGConexao
Rotina para centralizar a conexão com os bancos de dados
@author Leandro F Silveira
@since 02/09/2019
@version 1.0
/*/
//User Function XAGCON()
//Return()

Class XAGConexao

	Data nConecATS
	Data nConecPRT
	Data nConecDBG
	Data nConecDOX
	Data nConecEMS


	Method New() Constructor
	Method ConecATS()
	Method ConecEMS()
	Method ConecPRT()
	Method ConecDBG()
	Method ConecDOX()
	Method DescATS()
	Method DescEMS()
	Method DescDBG()
	Method DescDOX()

	Method isEnvTeste()
	Method GetPorta()
	Method GetIp()
	Method GetNomePRT()
	Method Conectar(_cAliasBD)
	Method SetConn(_nConec)

	Method SetConecATS(_nConec)
	Method SetConecEMS(_nConec)
	Method SetConecPRT(_nConec)
	Method SetConecDBG(_nConec)
	Method SetConecDOX(_nConec)

	Method CalcConPrt()

EndClass

Method New() Class XAGConexao

	Self:nConecATS := -1
	Self:nConecDBG := -1
	Self:nConecPRT := -1
	Self:nConecDOX := -1
	Self:nConecEMS := -1

	Self:CalcConPrt()

Return(Self)

Method ConecATS() Class XAGConexao

	Local nConec := -1

	If (Self:nConecATS >= 0 .And. TCIsConnected(Self:nConecATS))
		nConec := Self:nConecATS
	Else
		If (Self:isEnvTeste() .And. !isBlind())
			MsgInfo("Você está conectado a um ambiente de testes do Protheus e está se conectAndo a um ambiente de PRODUÇÃO do Autosystem!", "Importante")
		EndIf

		//Empresa 51 está com EMSYS
		If cEmpAnt == '51'
			nConec := Self:Conectar("POSTGRES/AUTOSYSTEM_EMSYS")	
		ElseIf cEmpAnt == '44' // Empresa 44 Farol possui autosystem exclusivo para ela
			nConec := Self:Conectar("POSTGRES/AUTOSYSTEM_FAROL")
		Else
			nConec := Self:Conectar("POSTGRES/AUTOSYSTEM_PROD")
		Endif 
		Self:SetConecATS(nConec)
	EndIf

Return(Self:SetConn(nConec))

Method ConecPRT() Class XAGConexao

	Local nConec     := -1
	Local cNomeConec := ""

	If (Self:nConecPRT >= 0 .And. TCIsConnected(Self:nConecPRT))
		nConec := Self:nConecPRT
	Else
		cNomeConec := Self:GetNomePRT()
		nConec := Self:Conectar(cNomeConec)
		Self:SetConecPRT(nConec)
	EndIf

Return(Self:SetConn(nConec))

Method ConecDBG() Class XAGConexao

	Local nConec := -1

	If (Self:nConecDBG >= 0 .And. TCIsConnected(Self:nConecDBG))
		nConec := Self:nConecDBG
	Else
		If (Self:isEnvTeste())
			nConec := Self:Conectar("ODBC/DBGINT_TESTE")//nConec := Self:Conectar("MYSQL/DBGINT_TESTE")
		Else
			nConec := Self:Conectar("ODBC/DBGINT_PROD")//nConec := Self:Conectar("MYSQL/DBGINT_PROD")
		EndIf

		Self:SetConecDBG(nConec)
	EndIf

Return(Self:SetConn(nConec))


Method ConecDOX() Class XAGConexao

	Local nConec := -1

	If (Self:nConecDOX >= 0 .And. TCIsConnected(Self:nConecDOX))
		nConec := Self:nConecDOX
	Else
		If (Self:isEnvTeste())
			nConec := Self:Conectar("ODBC/DOX_HOM")
		Else
			nConec := Self:Conectar("ODBC/DOX_PROD")
		EndIf

		Self:SetConecDOX(nConec)
	EndIf

Return(Self:SetConn(nConec))


Method ConecEMS() Class XAGConexao

	Local nConec := -1

	If (Self:nConecEMS >= 0 .And. TCIsConnected(Self:nConecEMS))
		nConec := Self:nConecEMS
	Else
		If (Self:isEnvTeste() .And. !isBlind())
			MsgInfo("Você está conectado a um ambiente de testes do Protheus e está se conectAndo a um ambiente de PRODUÇÃO do EMSYS!", "Importante")
		EndIf

		nConec := Self:Conectar("POSTGRES/EMSYS")
		Self:SetConecEMS(nConec)
	EndIf

Return(Self:SetConn(nConec))

Method DescATS() Class XAGConexao

	If (Self:nConecATS >= 0 .And. TCIsConnected(Self:nConecATS))
		TcUnlink(Self:nConecATS)
		Self:nConecATS := -1
	EndIf

Return()

Method DescDBG() Class XAGConexao

	If (Self:nConecDBG >= 0 .And. TCIsConnected(Self:nConecDBG))
		TcUnlink(Self:nConecDBG)
		Self:nConecDBG := -1
	EndIf

Return()

Method DescEMS() Class XAGConexao

	If (Self:nConecEMS >= 0 .And. TCIsConnected(Self:nConecEMS))
		TcUnlink(Self:nConecEMS)
		Self:nConecEMS := -1
	EndIf

Return()


Method DescDOX() Class XAGConexao

	If (Self:nConecDOX >= 0 .And. TCIsConnected(Self:nConecDOX))
		TcUnlink(Self:nConecDOX)
		Self:nConecDOX := -1
	EndIf

Return()


Method isEnvTeste() Class XAGConexao

	Local _lRet      := .F.
	Local _cAmbiente := GetEnvServer()

	_lRet := "HOM" $ Upper(_cAmbiente) .Or. "MIG" $ Upper(_cAmbiente)

Return(_lRet)

Method GetPorta() Class XAGConexao

	Local _cRet := ""

	_cRet := GetSrvProfString("TOPPORT", "")

	If (Empty(_cRet))
		_cRet := GetSrvProfString("DBPort", "NOT_FOUND")
	EndIf

Return(_cRet)

Method GetIp() Class XAGConexao

	Local _cRet := ""

	_cRet := GetSrvProfString("TOPSERVER", "")

	//If alltrim(upper(_cRet)) $ alltrim(upper('localhost'))
	//	_cRet := '172.28.71.10'
	//Endif 

	If (Empty(_cRet))
		_cRet := GetSrvProfString("DBServer", "NOT_FOUND")
	EndIf

Return(_cRet)

Method GetNomePRT() Class XAGConexao

	Local _cRet      := ""
	Local _cDbAlias  := ""
	Local _cDataBase := ""

	_cDbAlias := GetSrvProfString("TOPALIAS", "")
	
	If (Empty(_cDbAlias))
		 _cDbAlias := GetSrvProfString("DBAlias", "NOT_FOUND")
	EndIf

	_cDataBase := GetSrvProfString("TOPDATABASE", "")

	If (Empty(_cDataBase))
		_cDataBase := GetSrvProfString("DBDataBase", "NOT_FOUND")
	EndIf

	_cRet := _cDataBase + "/" + _cDbAlias

Return(_cRet)

Method Conectar(_cAliasBD) Class XAGConexao

	Local _cMsgErr := ""
	Local _nRet    := -1
	Local _cIp     := Self:GetIp()
	Local _nPorta  := Val(Self:GetPorta())

	_nRet := TcLink(_cAliasBD, _cIp, _nPorta)

	If (_nRet < 0)
		_cMsgErr := "[" + DToC(Date()) + " " + Time() + "] " + CRLF
		_cMsgErr += "XAGCON.prw: Não foi possivel conectar ao banco." + CRLF
		_cMsgErr += "[IP: " + _cIp + "] " + CRLF
		_cMsgErr += "[PORTA: " + cValToChar(_nPorta) + "] " + CRLF
		_cMsgErr += "[AliasBD: " + _cAliasBD + "]" + CRLF
		ConOut(_cMsgErr)

		If (!IsBlind())
			MsgAlert(_cMsgErr)
		EndIf
	/*Else
		_cMsgErr := "[" + DToC(Date()) + " " + Time() + "] " + CRLF
		_cMsgErr += "XAGCON.prw: CONECTOU." + CRLF
		_cMsgErr += "[IP: " + _cIp + "] " + CRLF
		_cMsgErr += "[PORTA: " + cValToChar(_nPorta) + "] " + CRLF
		_cMsgErr += "[AliasBD: " + _cAliasBD + "]" + CRLF
		ConOut(_cMsgErr)

		If (!IsBlind())
			MsgAlert(_cMsgErr)
		EndIf */

	EndIf

Return(_nRet)

Method SetConn(_nConec) Class XAGConexao

	Local _lRet := .F.

	If (_nConec >= 0)
		_lRet := TcSetConn(_nConec)
	EndIf

Return(_lRet)

Method SetConecATS(_nConec) Class XAGConexao

	Self:nConecATS := _nConec

	If (Self:nConecATS == Self:nConecDBG)
		Self:nConecDBG := -1
	EndIf

	If (Self:nConecATS == Self:nConecPRT)
		Self:nConecPRT := -1
	EndIf

	If (Self:nConecATS == Self:nConecDOX)
		Self:nConecDOX := -1
	EndIf

Return()

Method SetConecPRT(_nConec) Class XAGConexao

	Self:nConecPRT := _nConec

	If (Self:nConecPRT == Self:nConecDBG)
		Self:nConecDBG := -1
	EndIf

	If (Self:nConecPRT == Self:nConecATS)
		Self:nConecATS := -1
	EndIf

	If (Self:nConecPRT == Self:nConecDOX)
		Self:nConecDOX := -1
	EndIf

Return()

Method SetConecDBG(_nConec) Class XAGConexao

	Self:nConecDBG := _nConec

	If (Self:nConecDBG == Self:nConecPRT)
		Self:nConecPRT := -1
	EndIf

	If (Self:nConecDBG == Self:nConecATS)
		Self:nConecATS := -1
	EndIf

	If (Self:nConecDBG == Self:nConecDOX)
		Self:nConecDOX := -1
	EndIf

Return()

Method SetConecDOX(_nConec) Class XAGConexao

	Self:nConecDOX := _nConec

	If (Self:nConecDOX == Self:nConecPRT)
		Self:nConecPRT := -1
	EndIf

	If (Self:nConecDOX == Self:nConecATS)
		Self:nConecATS := -1
	EndIf

	If (Self:nConecDOX == Self:nConecDBG)
		Self:nConecDBG := -1
	EndIf

Return()

Method SetConecEMS(_nConec) Class XAGConexao

	Self:nConecEMS := _nConec

	If (Self:nConecEMS == Self:nConecDBG)
		Self:nConecDBG := -1
	EndIf

	If (Self:nConecEMS == Self:nConecPRT)
		Self:nConecPRT := -1
	EndIf

	If (Self:nConecEMS == Self:nConecDOX)
		Self:nConecDOX := -1
	EndIf

	If (Self:nConecEMS == Self:nConecATS)
		Self:nConecATS := -1
	EndIf


Return()


Method CalcConPrt() Class XAGConexao

	If (TCGetConn() == 0 .And. "MSSQL" $ Upper(TcGetDB()))
		Self:SetConecPRT(0)
	EndIf

Return()
