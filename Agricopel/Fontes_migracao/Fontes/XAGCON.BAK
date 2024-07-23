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

	Method New() Constructor
	Method ConecATS()
	Method ConecPRT()
	Method ConecDBG()
	Method DescATS()
	Method DescDBG()

	Method isEnvTeste()
	Method GetPorta()
	Method GetIp()
	Method GetNomePRT()
	Method Conectar(_cAliasBD)
	Method SetConn(_nConec)

	Method SetConecATS(_nConec)
	Method SetConecPRT(_nConec)
	Method SetConecDBG(_nConec)

	Method CalcConPrt()

EndClass

Method New() Class XAGConexao

	Self:nConecATS := -1
	Self:nConecDBG := -1
	Self:nConecPRT := -1

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

		nConec := Self:Conectar("POSTGRES/MATRIZ_AGRICOPEL")
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
			nConec := Self:Conectar("MYSQL/DBGINT_TESTE")
		Else
			nConec := Self:Conectar("MYSQL/DBGINT_PRD")
		EndIf

		Self:SetConecDBG(nConec)
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

Method isEnvTeste() Class XAGConexao

	Local _lRet      := .F.
	Local _cAmbiente := GetEnvServer()

	_lRet := "HOM" $ Upper(_cAmbiente) .Or. "MIGRA" $ Upper(_cAmbiente)

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

Return()

Method SetConecPRT(_nConec) Class XAGConexao

	Self:nConecPRT := _nConec

	If (Self:nConecPRT == Self:nConecDBG)
		Self:nConecDBG := -1
	EndIf

	If (Self:nConecPRT == Self:nConecATS)
		Self:nConecATS := -1
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

Return()

Method CalcConPrt() Class XAGConexao

	If (TCGetConn() == 0 .And. "MSSQL" $ Upper(TcGetDB()))
		Self:SetConecPRT(0)
	EndIf

Return()