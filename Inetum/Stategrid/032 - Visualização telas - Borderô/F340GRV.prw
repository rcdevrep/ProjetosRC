#INCLUDE "TOTVS.CH"

/* 
�����������������������������������������������������������������������������
Programa  � F340GRV  �Autor  � Jader Berto         Data � 20/06/2024      ���
�����������������������������������������������������������������������������
���Desc.  �Ap�s Compensa��o                                               ���
���                                                                       ���
���                                                                       ���
���                                                                       ���
���                                                            	          ���
���                                                                       ���
�����������������������������������������������������������������������������
���Uso    � SIGAORG                                                       ���
����������������������������������������������������������������������������� 
*/

User Function F340GRV()
Local nValor := SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC+SE2->E2_XMULTA+SE2->E2_XJUR+SE2->E2_XTAXA-SE2->E2_XDESC

	Reclock("SE2" , .F. ) 

		SE2->E2_XVLIQ := nValor 

	MsUnlock()	


Return( Nil )
