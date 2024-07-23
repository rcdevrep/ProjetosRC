#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR885       ºAutor  ³Alan Leandro    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que exclui as entradas das NF's de clientes         º±±
±±º          ³ na empresa transportadora.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR885(cEmpTrans,cFilTrans,aInfo)
******************************************
Local aSeg, aSegSA1, aSegSB1, aSegDTC, aSegDTP
Local aItemDTC	:= {}, aLote := {}
Local aTotDTC	:= {}
Local aCabDTC	:= {}
Local cCliRem, cLojRem, cCliDes, cLojDes
Local cStartPath, cLote, nQtdLot := 1, nOpcLote, lRet := .T.

// Seta job para nao consumir licencas
/////////////////////////////////////////////////////////////////////////////
RpcSetType(3)

// Abro o ambiente da empresa da transportadora
/////////////////////////////////////////////////////////////////////////////
PREPARE ENVIRONMENT EMPRESA cEmpTrans FILIAL cFilTrans MODULO "TMS" TABLES "SA1,SB1,DTC,DTP"

conout("==========================================================")
conout("Inicio da Rotina que Exclui o DTC na Transportadora: "+Alltrim(Time()))
conout("==========================================================")

//  Estrutura do array aInfo
//////////////////////////////////////
//	aInfo[1]  - Cgc do Remetente
//	aInfo[2]  - Cgc do Destinatario
//	aInfo[3]  - Numero da NF
//	aInfo[4]  - Serie da NF
//	aInfo[5]  - Empresa Remetente
//	aInfo[6]  - Filial Remetente
//	aInfo[7]  - DataBase do sistema no momento da exclusao da Nota Fiscal

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

// Altero a DataBase do sistema para poder fazer a exclusao do DTC
///////////////////////////////////////////////////////////////////////////////////////////////////
dDataBase := aInfo[7]

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

// Busco o registro da entrada da NF solicitada
/////////////////////////////////////////////////////////////////////////////////////////////////////
cQuery := "SELECT DTC_FILORI, DTC_LOTNFC, DTC_DEVFRE, DTC_SERTMS, DTC_TIPTRA, DTC_CODPRO, DTC_CODEMB, DTC_EMINFC, DTC_SERVIC "
cQuery += "FROM "+RetSqlName("DTC")+" "
cQuery += "WHERE D_E_L_E_T_ <> '*' AND DTC_FILIAL = '"+xFilial("DTC")+"' "
cQuery += "AND DTC_CLIREM = '"+cCliRem+"' AND DTC_LOJREM = '"+cLojRem+"' "
cQuery += "AND DTC_CLIDES = '"+cCliDes+"' AND DTC_LOJDES = '"+cLojDes+"' "
cQuery += "AND DTC_NUMNFC = '"+aInfo[3]+"' AND DTC_SERNFC = '"+aInfo[4]+"' "
cQuery += "AND DTC_EMPREM = '"+aInfo[5]+"' AND DTC_FILREM = '"+aInfo[6]+"' "

If (Select("ALN") <> 0)
	DbSelectArea("ALN")
	DbCloseArea()
EndIf

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "ALN"
TCSetField("ALN","DTC_EMINFC","D",8,0)

ALN->(dbGotop())
While !ALN->(EOF())    
	lRet := .F.
	DTP->(dbSetOrder(1))
	If DTP->(dbSeek(xFilial("DTP")+ALN->DTC_lotnfc))
		// So e permitido excluir registros caso o lote nao tenha sido calculado ainda
		/////////////////////////////////////////////////////////////////////////////////////////////////
		If DTP->DTP_status $ "1,2"
			nQtdLot := DTP->DTP_qtdlot
			cLote 	:= DTP->DTP_lotnfc  
         
			DTC->(dbSetOrder(1))
			If DTC->(dbSeek(xFilial("DTC")+ALN->DTC_filori+cLote+cCliRem+cLojRem+cCliDes+cLojDes+ALN->DTC_servic+ALN->DTC_codpro+aInfo[3]+aInfo[4]))
				RecLock("DTC",.F.)
				dbDelete()
				DTC->(MsUnLock())
				lRet := .T.	
			EndIf			
			/*
			// Alimento os arrays para a rotina automatica de entrada de NF
			//////////////////////////////////////////////////////////////////////////////////////////////////
			aItemDTC :=	{	{"DTC_NUMNFC" 		,aInfo[3]				, Nil},;
							{"DTC_SERNFC"		,aInfo[4]				, Nil},;
							{"DTC_CODPRO"		,ALN->DTC_codpro		, Nil},;
							{"DTC_CODEMB"    	,ALN->DTC_codemb		, Nil},;
							{"DTC_EMINFC"  		,ALN->DTC_eminfc		, Nil}}
			
			aadd(aTotDTC,aItemDTC)
			
			If Len(aTotDTC) > 0
				
				aCabDTC :=	{	{"DTC_FILORI"		,ALN->DTC_filori	, Nil},;
								{"DTC_LOTNFC"		,cLote				, Nil},;
								{"DTC_CLIREM"		,cCliRem			, Nil},;
								{"DTC_LOJREM"		,cLojRem			, Nil},;
								{"DTC_CLIDES"		,cCliDes			, Nil},;
								{"DTC_LOJDES"		,cLojDes			, Nil},;
								{"DTC_DEVFRE"		,ALN->DTC_devfre	, Nil},;
								{"DTC_SERTMS"		,ALN->DTC_sertms	, Nil},;
								{"DTC_TIPTRA"		,ALN->DTC_tiptra	, Nil}}
				
				lMsErroAuto := .F.
				Begin Transaction
				// Parametros da TMSA050 (notas fiscais do cliente)
				// xAutoCab - Cabecalho da nota fiscal
				// xAutoItens - Itens da nota fiscal
				// xItensPesM3 - acols de Peso Cubado
				// xItensEnder - acols de Enderecamento
				// nOpcAuto - Opcao rotina automatica (Inclusao/Estorno) (acho que eh 3 e 5)
				MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aTotDTC,,,5)
				If lMsErroAuto
					// Gravo o log de erro com 'E' mais o numero e serie da nota fiscal que nao conseguiu ser dado entrada
					////////////////////////////////////////////////////////////////////////////////////////////////////////
					MostraErro(cStartPath,"E"+Alltrim(aInfo[3])+"-"+Alltrim(aInfo[4])+".log")
					DisarmTransaction()
					break
				Else
					lRet := .T.	
				Endif
				End Transaction
			EndIf
			*/
			
			// Faco o tratamento do lote. se for quantidade 1, eu excluo o lote, senao eu apenas altero diminuindo a quantidade
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// Parametros da TMS170 (cadastro de Lotes)
			// xAutoCab - dados para preencher o lote
			// nOpcAuto - (a principio opcoes padroes)
			nOpcLote	:= 5
			If nQtdLot > 1
				nQtdLot := nQtdLot - 1
				nOpcLote	:= 4
			EndIf
			aLote		:=	{	{"DTP_LOTNFC"      ,cLote			, Nil},;
								{"DTP_QTDLOT"      ,nQtdLot			, Nil}}
			
			lMsErroAuto := .F.
			Begin Transaction
			MSExecAuto({|x,y| TMSA170(x,y)},aLote,nOpcLote)
			If lMsErroAuto
				// Gravo o log de erro com 'ELOT', mais o numero e serie da nota fiscal que nao conseguiu ser dado entrada
				////////////////////////////////////////////////////////////////////////////////////////////////////////////
				MostraErro(cStartPath,"ELOT"+Alltrim(aInfo[3])+"-"+Alltrim(aInfo[4])+".log")
				DisarmTransaction()
				break
			Endif
			End Transaction
			
		EndIf
	EndIf
	ALN->(dbSkip())
EndDo

If (Select("ALN") <> 0)
	DbSelectArea("ALN")
	DbCloseArea()
EndIf

RestArea(aSeg)
RestArea(aSegDTC)
RestArea(aSegDTP)
RestArea(aSegSA1)
RestArea(aSegSB1)

conout("=======================================================")
conout("Fim da Rotina que Exclui o DTC na Transportadora: "+Alltrim(Time()))
conout("=======================================================")

RESET ENVIRONMENT

Return lRet
