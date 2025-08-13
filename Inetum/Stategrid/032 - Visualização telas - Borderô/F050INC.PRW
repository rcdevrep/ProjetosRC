#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} F050INC 

Ponto de Entrada executado após a gravação , antes da contabilização e antes dos titulos de desdobramento.

@author TOTVS - Marcos Furtado 
@Data: 19/04/2018
@version P11 - State Grid
*/
//-------------------------------------------------------------------

User Function F050INC()

	local lRet := .F.
	Local aArea 	:= GetArea()


	DbSelectArea("CTD")
	SET FILTER TO
	RestArea(aArea)

	/*
	if AllTrim(E2_PREFIXO) ==   'SPG' .AND. ALLTRIM(E2_TIPO) == 'PA'
	mv_par05 := 1  //Gera Cheque
	mv_par09 := 1  //Movimento Bancário    
	ENDIF   
	*/

	if AllTrim(E2_PREFIXO) ==   'ADM' .AND. ALLTRIM(E2_TIPO) == 'PA'
		mv_par05 := 2  //Não Gera Cheque
		mv_par09 := 2  //Não Gera Movimento Bancário    
	ENDIF

Return(.T.)
