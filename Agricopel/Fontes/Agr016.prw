#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR016    �Autor  �Valdecir Santos     � Data �  02/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa utilizado no gatilho UA_CLIENTE tela de Atendimen-���
���          � to do CallCenter                                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Agr016()


	cContato := Space(06)
	cNome		:= Space(30)
   DbSelectArea("AC8")
   DbSetOrder(2)
   DbGotop()
   If DbSeek(xFilial("AC8")+"SA1"+xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA)
   	DbSelectArea("SU5")
   	DbSetOrder(1)
   	DbGotop()
   	If DbSeek(xFilial("SU5")+AC8->AC8_CODCON,.T.)
   		cContato      := SU5->U5_CODCONT
			M->UA_CODCONT := SU5->U5_CODCONT   
			M->UA_DESCNT  := SUBSTR(SU5->U5_CONTAT,1,30)
   	Else
   		msgstop("Atencao, nao existe contato para este cliente")	
   	EndIf
   Else
   		msgstop("Atencao, nao existe contato para este cliente")		
   EndIf

Return cContato