#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR881       ºAutor  ³Alan Leandro    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que gera as entradas das NF's de clientes           º±±
±±º          ³ na empresa transportadora.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR881(cEmpTrans,cFilTrans,aInfo)
******************************************
Local aSeg, aSegSA1, aSegSB1, aSegDTC, aSegDTP
Local aItemDTC	:= {}, aLote := {}
Local aTotDTC	:= {}
Local aCabDTC	:= {}
Local cProdDTC  := "", cCliRem, cLojRem, cCliDes, cLojDes, cCliDev, cLojDev, cTpFrete
Local cStartPath, cLote, nQtdLot := 1, nOpcLote, lRet := .F.
             
// Seta job para nao consumir licencas
/////////////////////////////////////////////////////////////////////////////
RpcSetType(3)

// Abro o ambiente da empresa da transportadora
/////////////////////////////////////////////////////////////////////////////


PREPARE ENVIRONMENT EMPRESA cEmpTrans FILIAL cFilTrans MODULO "TMS" TABLES "SA1,SB1,DTC,DTP"

conout("=========================================================")
conout("Inicio da Rotina que gera o DTC na Transportadora: "+Alltrim(Time()))
conout("=========================================================")
//  Estrutura do array aInfo
//////////////////////////////////////
//	aInfo[1]  - Cgc do Remetente
//	aInfo[2]  - Cgc do Destinatario
//	aInfo[3]  - Numero da NF
//	aInfo[4]  - Serie da NF
//	aInfo[5]  - Emissao
//	aInfo[6]  - Volume total
//	aInfo[7]  - Peso total
//	aInfo[8]  - Valor da Mercadoria
//	aInfo[9]  - Tipo de Frete 
//	aInfo[10] - Empresa Remetente
//	aInfo[11] - Filial Remetente

aSeg		:= GetArea()
aSegDTC		:= DTC->(GetArea())
aSegDTP		:= DTP->(GetArea())
aSegSA1		:= SA1->(GetArea())
aSegSB1		:= SB1->(GetArea())
cStartPath	:= GetSrvProfString("Startpath","")

// Verifico se a empresa esta configurada como transportadora
/////////////////////////////////////////////////////////////////////////////
If GetMv("MV_EMPTRAN") <> "S"
	Return .T.
EndIf

// Altero a DataBase do sistem para poder fazer a inclusao do DTC 
///////////////////////////////////////////////////////////////////////////////////////////////////
dDataBase := aInfo[5]

// Busco o cliente remetente
///////////////////////////////////////////////////////////////////////////////////////////////////
SA1->(dbSetOrder(3))
SA1->(dbSeek(xFilial("SA1")+aInfo[1]))
cCliRem := SA1->A1_cod
cLojRem := SA1->A1_loja

// Busco o cliente destinatario
///////////////////////////////////////////////////////////////////////////////////////////////////
SA1->(dbSetOrder(3))
SA1->(dbSeek(xFilial("SA1")+aInfo[2]))
cCliDes := SA1->A1_cod
cLojDes := SA1->A1_loja
cCdrDes := SA1->A1_cdrdes
       
// Pego o produto que vai ser generico na entrada da nota fiscal
////////////////////////////////////////////////////////////////////////////////////////////////////
cProdDTC := Padr(GetMv("MV_PRODDTC"),15)

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cProdDTC))    

// Faco a Logica de verificar se vai ser CIF ou FOB
///////////////////////////////////////////////////////////////////////////////////////////////////
If aInfo[9] == "F"
	cTpFrete := "2"
	cCliDev  := cCliDes
	cLojDev  := cLojDes
Else
	cTpFrete := "1"
	cCliDev  := cCliRem
	cLojDev  := cLojRem
EndIf	

// Verifico se existe algum lote para este remetente e destinatario que ainda nao foi calculado
/////////////////////////////////////////////////////////////////////////////////////////////////////
cQuery := "SELECT DISTINCT DTP.DTP_LOTNFC, DTP.DTP_QTDLOT "
cQuery += "FROM "+RetSqlName("DTP")+" DTP, "
cQuery +=         RetSqlName("DTC")+" DTC "
cQuery += "WHERE DTP.D_E_L_E_T_ <> '*' AND DTP.DTP_FILIAL = '"+xFilial("DTP")+"' "
cQuery += "AND DTP.DTP_STATUS IN ('1','2') "
cQuery += "AND DTC.DTC_LOTNFC = DTP.DTP_LOTNFC AND DTC.DTC_FILORI = DTP.DTP_FILORI "
cQuery += "AND DTC.D_E_L_E_T_ <> '*' AND DTC.DTC_FILIAL = '"+xFilial("DTC")+"' "
cQuery += "AND DTC.DTC_CLIREM = '"+cCliRem+"' AND DTC.DTC_LOJREM = '"+cLojRem+"' "
cQuery += "AND DTC.DTC_CLIDES = '"+cCliDes+"' AND DTC.DTC_LOJDES = '"+cLojDes+"' "
cQuery += "AND DTC.DTC_EMPREM = '"+aInfo[10]+"' AND DTC.DTC_FILREM = '"+aInfo[11]+"' "

If (Select("ALN") <> 0)
	DbSelectArea("ALN")
	DbCloseArea()
EndIf

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "ALN"
TCSetField("ALN","DTP_QTDLOT","N",3,0)

ALN->(dbGotop())
While !ALN->(EOF())
	cLote	:= ALN->DTP_lotnfc
	nQtdlot := ALN->DTP_qtdlot + 1
	ALN->(dbSkip())
EndDo

If (Select("ALN") <> 0)
	DbSelectArea("ALN")
	DbCloseArea()
EndIf
                                        
// Parametros da TMS170 (cadastro de Lotes)
// xAutoCab - dados para preencher o lote
// nOpcAuto - (a principio opcoes padroes)
If !Empty(cLote)
	aLote		:=	{	{"DTP_LOTNFC"      ,cLote			, Nil},;
						{"DTP_QTDLOT"      ,nQtdLot			, Nil}}
	nOpcLote	:= 4
Else
	aLote		:=	{	{"DTP_QTDLOT"      ,nQtdLot			, Nil}}
	nOpcLote	:= 3
EndIf	

lMsErroAuto := .F.
Begin Transaction
MSExecAuto({|x,y| TMSA170(x,y)},aLote,nOpcLote)
If lMsErroAuto
	// Gravo o log de erro com 'LOT', mais o numero e serie da nota fiscal que nao conseguiu ser dado entrada
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	MostraErro(cStartPath,"LOT"+Alltrim(aInfo[3])+"-"+Alltrim(aInfo[4])+".log")
	DisarmTransaction()
	break
Endif
End Transaction

If Empty(cLote)
	cLote := DTP->DTP_lotnfc
EndIf	
            
// Alimento os arrays para a rotina automatica de entrada de NF
//////////////////////////////////////////////////////////////////////////////////////////////////
aItemDTC :=	{	{"DTC_NUMNFC" 		,aInfo[3]				, Nil},;
				{"DTC_SERNFC"		,aInfo[4]				, Nil},;
				{"DTC_CODPRO"		,cProdDTC				, Nil},;
				{"DTC_CODEMB"    	,SB1->B1_um				, Nil},;
				{"DTC_EMINFC"  		,aInfo[5]				, Nil},;
				{"DTC_QTDVOL"  		,aInfo[6]				, Nil},;
				{"DTC_PESO"  		,aInfo[7]				, Nil},;
				{"DTC_VALOR"  		,aInfo[8]				, Nil},;
				{"DTC_EDI"			,"2"					, Nil},;
				{"DTC_NFENTR"		,"1" 				, Nil}}

aadd(aTotDTC,aItemDTC)

If Len(aTotDTC) > 0

	aCabDTC :=	{	{"DTC_FILORI"		,cFilAnt				, Nil},;
					{"DTC_LOTNFC"		,cLote					, Nil},;
					{"DTC_CLIREM"		,cCliRem				, Nil},;
					{"DTC_LOJREM"		,cLojRem				, Nil},;
					{"DTC_DATENT"		,dDataBase				, Nil},;					
					{"DTC_CLIDES"		,cCliDes				, Nil},;
					{"DTC_LOJDES"		,cLojDes				, Nil},;
					{"DTC_CLIDEV"		,cCliDev				, Nil},;
					{"DTC_LOJDEV"		,cLojDev				, Nil},;
					{"DTC_CLICAL"		,cCliDev				, Nil},;
					{"DTC_LOJCAL"		,cLojDev				, Nil},;					
					{"DTC_DEVFRE"		,cTpFrete				, Nil},;					
					{"DTC_SERTMS"		,"3"					, Nil},;					
					{"DTC_TIPTRA"		,"1"					, Nil},;
					{"DTC_SERVIC"		,GetMv("MV_SERVDTC")	, Nil},;
					{"DTC_TIPNFC"		,"0"					, Nil},;
					{"DTC_TIPFRE"		,cTpFrete				, Nil},;
					{"DTC_SELORI"		,"1"					, Nil},;
					{"DTC_CDRORI"		,GetMv("MV_CDRORI")		, Nil},;
					{"DTC_CDRDES"		,cCdrDes           		, Nil},;
					{"DTC_CDRCAL"		,cCdrDes           		, Nil},;					
					{"DTC_DISTIV"		,"2"	           		, Nil},;
					{"DTC_EMPREM"		,aInfo[10]				, Nil},;
					{"DTC_FILREM"		,aInfo[11]				, Nil},;
					{"DTC_NFENTR"		,"1" 				, Nil}}
	
	lMsErroAuto := .F.
	Begin Transaction
	// Parametros da TMSA050 (notas fiscais do cliente)
	// xAutoCab - Cabecalho da nota fiscal
	// xAutoItens - Itens da nota fiscal
	// xItensPesM3 - acols de Peso Cubado
	// xItensEnder - acols de Enderecamento
	// nOpcAuto - Opcao rotina automatica (Inclusao/Estorno) (acho que eh 3 e 5)	
	MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aTotDTC,,,3)
	If lMsErroAuto
		// Gravo o log de erro com o numero e serie da nota fiscal que nao conseguiu ser dado entrada
		//////////////////////////////////////////////////////////////////////////////////////////////////
		MostraErro(cStartPath,Alltrim(aInfo[3])+"-"+Alltrim(aInfo[4])+".log")
		DisarmTransaction()
		break
	Else
		lRet := .T.	
	Endif
	End Transaction
EndIf

RestArea(aSeg)
RestArea(aSegDTC)
RestArea(aSegDTP)
RestArea(aSegSA1)
RestArea(aSegSB1)

conout("======================================================")
conout("Fim da Rotina que gera o DTC na Transportadora: "+Alltrim(Time()))
conout("======================================================")

RESET ENVIRONMENT

Return lRet
