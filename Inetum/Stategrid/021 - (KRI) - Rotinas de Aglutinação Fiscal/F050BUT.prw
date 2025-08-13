#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F050BUT   �Autor  �Angelo Henrique     � Data �  09/12/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para adicionar botao no contas a pagar     ���
���          �para visualizar a grade de aprova��o                        ���
�������������������������������������������������������������������������͹��
���Uso       �STATE GRID                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function F050BUT
Local aArea		:= GetArea()
Local aBotao    := {}
Private cIdioma := RetAcsName()

//	*'----------------------------------------------------------------------'*
//	*'Para somente visualizar a Grade de Aprova��o na visualiza��o do T�tulo'*
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
