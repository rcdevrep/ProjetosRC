#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGR886       ºAutor  ³Alan Leandro    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que chama o JOB para incluir uma nota de Entrada    º±±
±±º          ³ na empresa que fez a entrada da NF na empresa              º±±
±±º          ³ transportadora.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR886()
********************
Local aSeg		:= GetArea()
Local aSegDTC	:= DTC->(GetArea())
Local aSegSA1	:= SA1->(GetArea())
Local aSegSM0	:= SM0->(GetArea())
Local cMsg, lRet := .T., cEmpRem, cFilRem, cCgcTran
Local aDados	:= {}, lChamaJob := .T.             


//TESTE RODRIGO            
/*   ALERT("ANTES UPDATE")
	cQuery := ""
	cQuery += "UPDATE "+RetSqlName("SE1")+" SET E1_NATUREZ = '101011    ' "
   cQuery += "WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND D_E_L_E_T_ = '' "
	cQuery += "AND E1_NUM = '" + DTC->DTC_DOC + "' AND "
   cQuery += "AND E1_SERIE = '" + DTC->DTC_SERIE + "' "
   TcSqlExec(cQuery)    
   ALERT("DEPOIS UPDATE") */


//FIM TESTE






// Verifico se a empresa esta configurada como transportadora
/////////////////////////////////////////////////////////////////////////////
If GetMv("MV_EMPTRAN") <> "S"
	Return
EndIf

// Se nao for o remetente que vai pagar o frete, nao gero a NF de entrada
/////////////////////////////////////////////////////////////////////////////
If DT6->DT6_devfre <> "1" .and. DT6->DT6_devfre <> "2"
	Return
EndIf

// Posiciono no cliente que deve pagar o frete
/////////////////////////////////////////////////////////////////////////////
If DT6->DT6_devfre == "1"
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+DT6->DT6_clirem+DT6->DT6_lojrem))
Else
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+DT6->DT6_clides+DT6->DT6_lojdes))
EndIf

// Busco a empresa e filial que deu a entrada da NF na empresa transportadora
///////////////////////////////////////////////////////////////////////////////////
DTC->(dbSetOrder(1))
If DTC->(dbSeek(xFilial("DTC")+DT6->DT6_filori+DT6->DT6_lotnfc+DT6->DT6_clirem+DT6->DT6_lojrem+DT6->DT6_clides+DT6->DT6_lojdes))
	cEmpRem 	:= DTC->DTC_emprem
	cFilRem 	:= DTC->DTC_filrem
	cCgcTran	:= SM0->M0_cgc
	If !Empty(cEmpRem) .and. !Empty(cFilRem)
		// Se for o destinatario que vai pagar, procuro o destinatario no sigamat.
		// Se existir, e chamado o JOB para incluir o documento de entrada na empresa.
		////////////////////////////////////////////////////////////////////////////////////////////
		If DT6->DT6_devfre == "2"
			lChamaJob := .F.
			If !Empty(SA1->A1_cgc)
				SM0->(dbGoTop())
				While !SM0->(EOF())
					If Alltrim(SA1->A1_cgc) == Alltrim(SM0->M0_cgc)
						cEmpRem := SM0->M0_codigo
						cFilRem := SM0->M0_codfil
						lChamaJob := .T.
						Exit
					EndIf
					SM0->(dbSkip())
				EndDo
			EndIf
		EndIf
		
		If lChamaJob
			// Alimento o array que sera passado para a rotina que vai gerar o documento de entrada
			///////////////////////////////////////////////////////////////////////////////////////////////////
			aDados := {cCgcTran,DT6->DT6_valtot,DT6->DT6_doc,DT6->DT6_serie,dDataBase}
			
			// Chamo o JOB que vai gerar o documento de entrada na empresa que deu entrada da NF na empresa transportadora
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			lRet	:= StartJob("U_AGR887",GetEnvServer(),.T.,cEmpRem,cFilRem,aDados)
			If !lRet
				cMsg := "Nao e possivel incluir a NF de entrada na empresa "+Alltrim(SA1->A1_nome)+". "
				cMsg += "Contacte o Administrador do sistema!!!"
				Aviso("Atencao",cMsg,{"Cancelar"})
			EndIf
		EndIf
	EndIf
EndIf            




RestArea(aSeg)
RestArea(aSegDTC)
RestArea(aSegSA1)
RestArea(aSegSM0)
Return lRet
