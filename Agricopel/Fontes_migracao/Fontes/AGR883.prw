#include "Protheus.ch"
#include "Tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR883       ºAutor  ³Alan Leandro    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que verifica na empresa transportadora se           º±±
±±º          ³ os dados do remetente e destinatario estao corretos.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR883(cCgcCli,cCgcEmp,cEmpTrans,cFilTrans)
***************************************************
Local aSeg, aSegSA1, aSegDUY
Local lCliDes	:= .F., lEmpRem	:= .F., lRet := .F.

// Seta job para nao consumir licencas
/////////////////////////////////////////////////////////////////////////////
RpcSetType(3)

// Abro o ambiente da empresa da transportadora
/////////////////////////////////////////////////////////////////////////////
PREPARE ENVIRONMENT EMPRESA cEmpTrans FILIAL cFilTrans MODULO "TMS" TABLES "SA1,DUY"

conout("====================================================================================")
conout("Inicio da Rotina que verifica se os clientes estao corretos na Transportadora: "+Alltrim(Time()))
conout("====================================================================================")

/*                                                       
conout("Empresa: "+cEmpAnt)
conout("Filial: "+cFilAnt)
conout("Empresa SM0: "+SM0->M0_codigo)
conout("Filial SM0: "+SM0->M0_codfil)              
conout("cCgcCli"+cCgcCli)
conout("cCgcEmp"+cCgcEmp)
conout("cEmpRem"+cEmpRem)
conout("cFilRem"+cFilRem)
*/

// Verifico se a empresa esta configurada como transportadora
/////////////////////////////////////////////////////////////////////////////
If GetMv("MV_EMPTRAN") <> "S"
	Return .T.
EndIf

aSeg	:= GetArea()
aSegDUY	:= DUY->(GetArea())
aSegSA1	:= SA1->(GetArea())
    
// Verifico se existe o cliente destinatario
///////////////////////////////////////////////////////////////// 


CONOUT("ANTES NUMERO 1")
SA1->(dbSetOrder(3))
If SA1->(dbSeek(xFilial("SA1")+cCgcCli))

CONOUT("ENTROU NO NUMERO 1")
	If !Empty(SA1->A1_cdrdes)
	    CONOUT("NAO EH NULO")
		DUY->(dbSetOrder(1))	
		If DUY->(dbSeek(xFilial("DUY")+SA1->A1_cdrdes))
		    CONOUT("ENCONTROU O PRIMEIRO ENDERECO ") 
			lCliDes := .T.
		EndIf
	EndIf
EndIf 

//ALERT(lCliDes)

// Verifico se existe a empresa remetente
/////////////////////////////////////////////////////////////////
CONOUT("ANTES NUMERO 2")

SA1->(dbSetOrder(3))
If SA1->(dbSeek(xFilial("SA1")+cCgcEmp))
   CONOUT("ENCONTROU NUMERO 2") 
   CONOUT(cCgcEmp)
   CONOUT(SA1->A1_cdrdes)
	If !Empty(SA1->A1_cdrdes)
		DUY->(dbSetOrder(1))	
		CONOUT("NAO EH NULO NUMERO 2")
		If DUY->(dbSeek(xFilial("DUY")+SA1->A1_cdrdes))
		    CONOUT("ACHOU NUMERO 2")
			lEmpRem := .T.
		EndIf
	EndIf
EndIf         


//ALERT(lEmpRem)

If lEmpRem .and. lCliDes
	lRet := .T.
EndIf

RestArea(aSeg)
RestArea(aSegDUY)
RestArea(aSegSA1)

conout("=================================================================================")
conout("Fim da Rotina que verifica se os clientes estao corretos na Transportadora: "+Alltrim(Time()))
conout("=================================================================================")

RESET ENVIRONMENT

Return lRet
