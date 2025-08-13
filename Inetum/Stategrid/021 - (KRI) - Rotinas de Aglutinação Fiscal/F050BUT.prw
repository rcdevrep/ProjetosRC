#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F050BUT   ºAutor  ³Angelo Henrique     º Data ³  09/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para adicionar botao no contas a pagar     º±±
±±º          ³para visualizar a grade de aprovação                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³STATE GRID                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F050BUT
Local aArea		:= GetArea()
Local aBotao    := {}
Private cIdioma := RetAcsName()

//	*'----------------------------------------------------------------------'*
//	*'Para somente visualizar a Grade de Aprovação na visualização do Título'*
//	*'----------------------------------------------------------------------'*
	If  !INCLUI                               
		If cIdioma == ".ACS"
			Aadd(aBotao,{"BUDGET",	{|| U_STAA009()},"Consulta Aprovacao","Cons. Aprov."})
						
			IF !EMPTY(SE2->E2_DATALIB)
				Aadd(aBotao,{'Anexo',	{|| U_TOTVSANEXO(cEmpAnt,cFilAnt,"FIN",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)+ALLTRIM(SE2->E2_FORNECE), .F. ) },'Anexos','Anexos'})
			ELSE
				Aadd(aBotao,{'Anexo',	{|| U_TOTVSANEXO(cEmpAnt,cFilAnt,"FIN",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)+ALLTRIM(SE2->E2_FORNECE), .T. ) },'Anexos','Anexos'})
			ENDIF
			
			Aadd(aBotao,{"BUDGET",	{|| U_INC_PG_FL(SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO))},"Env.Fluig Apr.","Env.Fluig Apr."})
			Aadd(aBotao,{"BUDGET",	{|| U_STAA048(SE2->(RECNO()) ) },"Rejeitar/Liberar","Rejeitar/Liberar"})			
		Else
			Aadd(aBotao,{"BUDGET",		{|| U_STAA009()},"View Approval","View Approv."})
			
			IF !EMPTY(SE2->E2_DATALIB)
				Aadd(aBotao,{'Attachment',	{|| U_TOTVSANEXO(cEmpAnt,cFilAnt,"FIN",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)+ALLTRIM(SE2->E2_FORNECE), .F.  )  },'Attachment','Attachment.'})
			ELSE
				Aadd(aBotao,{'Attachment',	{|| U_TOTVSANEXO(cEmpAnt,cFilAnt,"FIN",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)+ALLTRIM(SE2->E2_FORNECE), .T. ) },'Attachment','Attachment.'})
			ENDIF
			
			If !cArqRel == "SIGAFIS.REL"
				Aadd(aBotao,{"BUDGET",		{|| U_INC_PG_FL(SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO))},"Send Fluig Appr.","Send Fluig Appr."})
				Aadd(aBotao,{"BUDGET",		{|| U_STAA048(SE2->(RECNO())) },"Rejeitar/Liberar","Rejeitar/Liberar"})
			EndIf
		EndIf			
	EndIf

	RestArea(aArea)

Return aBotao
