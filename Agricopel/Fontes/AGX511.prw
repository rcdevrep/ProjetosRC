#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGX511    �Autor  �Microsiga           � Data �  05/11/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � GATILHO PARA DISPARAR ROTINA AGR162 PARA RECAULCULO NO     ���
���          � CAMPO CONDICAO DE PAGAMENTO NO ATENDIMENTO CALL CENTER     ���
���          � ROTINA JA VERIFICADA VIA XAGLOGRT                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function AGX511()
	cCond := M->UA_CONDPG   
	EXECBLOCK(U_AGR162(),.F.,.F.)
Return(cCond)

User Function AGX511A(xCampo)
	Local _cRetorno := ""
	Default xCampo := ""
	
	If xCampo <> ""
		_cRetorno := M->&(xCampo)//UA_TABELA  
		U_AGR162(xCampo)
	Endif 

Return(_cRetorno)

