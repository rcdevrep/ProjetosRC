#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ROTINA DE INTEGRA��O COM DBGINT - ROTINA PRINCIPAL
*/
User Function AGX635(xSchedule)  

	Local aEmpDePara := {}
	Local lIntProd   := .T.//Integra Produto
	Local lIntNE	 := .T.//Integra Nota de Entrada 
	Local lIntCTS    := .T.//Integra CTE Sa�da   
	Local lIntCTE    := .T.//Integra CTE Entrada
	Local lIntNS	 := .T.//Integra Nota de Sa�da
	Local lIntCF 	 := .F.//Integra Cliente/Fornecedor  
	Default xSchedule := .T.
                              
    Public xAGX635x :=  xSchedule   
           
	// Monta Array que mapeia as empresas - DBGint X Protheus - aEmpresas{nEmpresa, {}}
	aEmpDePara := U_AGX635EM()     
	
	If (Len(aEmpDePara) > 0)
		If lIntProd //Integra Produtos  
			aEmpDePara := startjob("U_AGX635PR",getenvserver(),.T.,@aEmpDePara)
	 	Endif
	    //Ser� realizado no momento da Inclus�o da Nota
	    //If lIntCF//Integra Cliente Fornecedor
		//	U_AGX635CF(aEmpDePara)  
		//	Endif  
		If 	lIntNE//Integra Nota de Entrada    
			aEmpDePara := startjob("U_AGX635EX",getenvserver(),.T.,@aEmpDePara)
			aEmpDePara := startjob("U_AGX635NE",getenvserver(),.T.,@aEmpDePara)  
		Endif  
		If 	lIntCTE//Integra CTE Entrada
			aEmpDePara := startjob("U_AGX635CE",getenvserver(),.T.,@aEmpDePara) 
		Endif  		   
	   	If 	lIntNS//Integra Nota de Sa�da
	   		aEmpDePara := startjob("U_AGX635NS",getenvserver(),.T.,@aEmpDePara)  
	   	Endif   
		If 	lIntCTS//Integra CTE Sa�da
			aEmpDePara := startjob("U_AGX635CS",getenvserver(),.T.,@aEmpDePara)
		Endif  			
	EndIf
 
Return()          


   