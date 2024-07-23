#INCLUDE "PROTHEUS.CH"

User Function TMKVLDE4(_Var1,_cCdPgto,_Var3)

	Local _lRet := .T.

	If (M->UA_OPER != "2") .And. ((SM0->M0_CODIGO == '01' .And. (Alltrim(SM0->M0_CODFIL) == '03' .Or. Alltrim(SM0->M0_CODFIL) == '06')) .Or. (SM0->M0_CODIGO == '11') .Or. (SM0->M0_CODIGO == '15'))
		If (_cCdPgto <> M->UA_CONDPG)
			Alert("Condição de pagamento não pode ser alterada nesta tela, somente na tela principal do Televendas!" + CRLF + "Condição no Atendimento: " + M->UA_CONDPG + CRLF+ "Condição informada: " + _cCdPgto)
			// M->UA_CLIENTE := Space(6)
			_lRet := .F.
		EndIf
	EndIf

Return(_lRet)
