#INCLUDE "rwmake.ch" 
#Include "topconn.ch" 

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 30/07/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Controle saldos no estorno de medição.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

//User Function CN120ATESL()
User Function CN121ASD()


	Local lRet := .T. 

	_cNumContrat:= CND->CND_CONTRA
	_cRevisao	:= CND->CND_REVISA 
	_cNumMed	:= CND->CND_NUMMED
	_nSldEmpres	:= CND->CND_XSLDEM  //saldo anterior 
	_nSldCapta	:= CND->CND_XSLDCP  //saldo anterior

	cQry 	:= ""
	cQry    += " Update "+RetSQLName("CND")+" Set CND_XTITUL = ' ', CND_XMEDTI = ' ' " 
	cQry    += " FROM "+RetSqlName("CND")+" "                                                                                                      
	cQry    += " WHERE D_E_L_E_T_ = ' ' AND CND_FILIAL = '"+xFilial('CND')+"' 
	cQry    += " AND CND_CONTRA = '"+_cNumContrat+"' AND CND_REVISA = '"+_cRevisao+"' "  
	cQry    += " AND CND_XMEDTI = '"+_cNumMed+"' "    
	cQry    += " AND CND_XTITUL = 'S' AND CND_XPGEFE = '2' "  
	TCSQLEXEC(cQry)	

	Reclock("CN9",.F.)
	CN9->CN9_XSLDEM :=  _nSldEmpres  
	CN9->CN9_XSLDCP :=  _nSldCapta 
	CN9->(MsUnlock())

	Reclock("CND",.F.)
	CND->CND_XVLMED := 0
	CND->CND_XJUROS := 0
	CND->CND_XVARIA := 0
	CND->CND_XJRCAP := 0
	CND->(MsUnlock())

Return(lRet)
