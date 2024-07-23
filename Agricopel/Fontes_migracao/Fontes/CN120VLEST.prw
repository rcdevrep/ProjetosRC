#INCLUDE "rwmake.ch" 
#Include "topconn.ch" 

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 20/09/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Validação no estorno de medição.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function CN120VLEST()

	Local lRet := .T. 

	_cNumContrat:= CND->CND_CONTRA
	_cRevisao	:= CND->CND_REVISA 
	_cNumMed	:= CND->CND_NUMMED
	_nSldEmpres	:= CND->CND_XSLDEM  //saldo anterior 
	_nSldCapta	:= CND->CND_XSLDCP  //saldo anterior

	//Tratar para poder estornar sempre a maior medição do contrato.
	cquery        := cQuerysel := cQueryfrom := cQuerywher :=  " "   	
	cQuerysel     := " SELECT MAX(CND_NUMMED) AS CND_NUMMED"
	cQueryfrom    := " FROM "+RetSqlName("CND")+" "                                                                                                      
	cQuerywher    := " WHERE D_E_L_E_T_ = ' ' AND CND_FILIAL = '"+xFilial('CND')+"' 
	cQuerywher    += " AND CND_CONTRA = '"+_cNumContrat+"' AND CND_REVISA = '"+_cRevisao+"' " 
	cQuerywher    += " AND CND_DTFIM <> ' ' " 
	cquery        := cquerysel + cqueryfrom + cquerywher                                                           

	If Select("Qry1") <> 0
		Qry1->(dbCloseArea())
	EndIf

	TCQuery cQuery Alias Qry1 New

	dbSelectArea("QRY1")
	Qry1->(dbGotop()) 

	If !Qry1->(Eof()) 				
		If AllTrim(Qry1->CND_NUMMED) <> AllTrim(_cNumMed) 
			Alert("Você deve estarnor sempre a ultima medição do contrato!")
			Return(.F.)
		EndIf
	Endif

Return(lRet)