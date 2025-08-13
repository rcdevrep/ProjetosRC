#INCLUDE "TOTVS.CH"

/* 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Programa  ³ F340GRV  ºAutor  ³ Jader Berto         Data ³ 20/06/2024      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.  ³Após Compensação                                               º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                            	          º±±
±±º                                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso    ³ SIGAORG                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/

User Function F340GRV()
Local nValor := SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC+SE2->E2_XMULTA+SE2->E2_XJUR+SE2->E2_XTAXA-SE2->E2_XDESC

	Reclock("SE2" , .F. ) 

		SE2->E2_XVLIQ := nValor 

	MsUnlock()	


Return( Nil )
