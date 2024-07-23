#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR887       ºAutor  ³Alan Leandro    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que inclui a NF de entrada na empresa que deu       º±±
±±º          ³ a entrada da NF na empresa transportadora.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR887(cEmpTrans,cFilTrans,aInfo)
******************************************
Local aSeg, aSegSA1, aSegSD1, aSegSF1
Local cStartPath, lRet := .F.
Local cFornece, cLojFor, aCabNFE, aItemNFE, cProdFrete, cCond, cTes

// Seta job para nao consumir licencas
/////////////////////////////////////////////////////////////////////////////
RpcSetType(3)

// Abro o ambiente da empresa da transportadora
/////////////////////////////////////////////////////////////////////////////
PREPARE ENVIRONMENT EMPRESA cEmpTrans FILIAL cFilTrans MODULO "COM" TABLES "SA1,SD1,SF1"

conout("======================================================================")
conout("Inicio da Rotina que Inclui uma NF de entrada na Empresa Origem: "+Alltrim(Time()))
conout("======================================================================")

//  Estrutura do array aInfo
//////////////////////////////////////
//	aInfo[1]  - Cgc da Transportadora
//	aInfo[2]  - Valor total do frete
//	aInfo[3]  - Numero do conhecimento de frete
//	aInfo[4]  - Serie do conhecimento de frete
//	aInfo[5]  - DataBase do sistema no momento do conhecimento de frete

aSeg		:= GetArea()
aSegSA1		:= SA1->(GetArea())
aSegSD1		:= SD1->(GetArea())
aSegSF1		:= SF1->(GetArea())
cStartPath	:= GetSrvProfString("Startpath","")

// Verifico se devo gerar o documento de entrada na empresa solicitada
/////////////////////////////////////////////////////////////////////////////
If GetMv("MV_NFEFRET") <> "S"
	Return .T.
EndIf

// Altero a DataBase do sistem para poder fazer a inclusao da NFE
///////////////////////////////////////////////////////////////////////////////////////////////////
dDataBase := aInfo[5]

// Busco a transportadora no cadastro de fornecedores
///////////////////////////////////////////////////////////////////////////////////////////////////
SA2->(dbSetOrder(3))
SA2->(dbSeek(xFilial("SA2")+aInfo[1]))
cFornece := SA2->A2_cod
cLojFor  := SA2->A2_loja

// Pego o produto que vai ser generico do frete para o documento de entrada
////////////////////////////////////////////////////////////////////////////////////////////////////
cProdFrete	:= Padr(GetMv("MV_PRODFRE"),15)
cCond		:= Padr(GetMv("MV_CONDNFE"),3)
cTes		:= Padr(GetMv("MV_TESNFE"),3)

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cProdFrete))    

aCabNFE		:= {	{"F1_TIPO"			,"N"			, Nil},;
					{"F1_FORMUL"		,"N"			, Nil},;
					{"F1_DOC"			,aInfo[3]		, Nil},;
					{"F1_SERIE"			,aInfo[4]		, Nil},;
					{"F1_EMISSAO"		,dDataBase		, Nil},;
					{"F1_FORNECE"		,cFornece    	, Nil},;
					{"F1_LOJA"	   		,cLojFor       	, Nil},;
					{"F1_COND" 	   		,cCond			, Nil},;
					{"F1_ESPECIE"		,"CTR"    		, Nil}}

aItemNFE	:= {	{"D1_COD"			,cProdFrete		, Nil},;
					{"D1_UM"			,SB1->B1_um		, Nil},;
					{"D1_QUANT"			,1				, Nil},;
					{"D1_VUNIT"			,aInfo[2]		, Nil},;
					{"D1_TOTAL"			,aInfo[2]		, Nil},;
					{"D1_TES"			,cTes			, Nil}}

lMsErroAuto := .F.
Begin Transaction
MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabNFE,{aItemNFE},3)
If lMsErroAuto
	// Gravo o log de erro com 'NFE' mais o numero e serie da nota fiscal que nao conseguiu ser dado entrada
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	MostraErro(cStartPath,"E"+Alltrim(aInfo[3])+"-"+Alltrim(aInfo[4])+".log")
	DisarmTransaction()
	break
Else
	lRet := .T.
Endif
End Transaction

RestArea(aSeg)
RestArea(aSegSA1)
RestArea(aSegSD1)
RestArea(aSegSF1)

conout("===================================================================")
conout("Fim da Rotina que Inclui uma NF de entrada na Empresa Origem: "+Alltrim(Time()))
conout("===================================================================")

RESET ENVIRONMENT

Return lRet
