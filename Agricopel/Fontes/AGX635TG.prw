#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ROTINA DE INTEGRAÇÃO COM DBGINT - PRODUTOS
*/

/*/{Protheus.doc} AGX635PR
//ROTINA DE INTEGRAÇÃO COM DBGINT - TABELA GENERICA
@author Leandro Spiller
@since 22/01/2018
@type function
/*/
User Function AGX635TG()  

	Local cAlias := 'ZDA'
	Local cTitulo := "Cadastro de Tabelas Genéricas DBGInt"
	Local cVldExc := ".T."
	Local cVldAlt := ".T."
        
	dbSelectArea(cAlias)
	dbSetOrder(2)
	AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return            
             

//Busca dados da Tabela Generica 
//xEmp    = Codigo empresa
//xFil    = Codigo filial
//xTab    = Codigo da Tabela, Ex: 01 para Conta Contabil 
//xTexto  = Conteudo a ser filtrado no campo de Bsuca 
//xBusca = Nome do Campo para de busca, Ex: ZDA_CAMP1
//xReturn = Nome do Campo para retorno, Ex: ZDA_CAMP1
User Function X635TGBU(xEmp,xFil,xTab,xTexto,xBusca,xReturn) 

	Local cQuery    := "" 
	Local cWhere    := "" 
	Local cAliasTG  := "X635TGBU"   
	Local cRetTG    := ""
	Default xEmp    := "" 	
	Default xFil    := ""
	Default xTab    := ""
	Default xTexto  := ""  
	Default xReturn := ""

	cQuery += " SELECT * FROM ZDA010 "
	cQuery += " WHERE "  
 	If alltrim(xEmp) <> ''
 		cWhere += iif(alltrim(cWhere) <> ""," AND "," ")
 		cWhere += " ZDA_EMP = '"+xEmp+"' "
 	Endif
 	If alltrim(xFil) <> '' 
 		cWhere += iif(alltrim(cWhere) <> ""," AND "," ")
 	    cWhere += " ZDA_FILIAL = '"+xFil+"' "  
 	Endif
 	If alltrim(xTab) <> ''
 	    cWhere += iif(alltrim(cWhere) <> ""," AND "," ")
 	    cWhere += " ZDA_TABELA = '"+xTab+"' " 
 	Endif
 	If alltrim(xTexto) <> ''  .and. alltrim(xBusca) <> ''                          
 		cWhere += iif(alltrim(cWhere) <> ""," AND "," ")
   		cWhere += xBusca + " = '"+xTexto+"' "
 	Endif         
	
	// Se montou corretamente o Where,
	// Executa query
	If alltrim(cWhere) <> ""
	    
		cQuery += cWhere
	
		If Select(cAliasTG) <> 0
			dbSelectArea(cAliasTG)
			(cAliasTG)->(dbCloseArea())
		Endif  
//		CONOUT(cAliasTG)
   		TCQuery cQuery NEW ALIAS (cAliasTG)   
   		cRetTG := (cAliasTG)->&(xReturn) 
   		
	Endif

Return cRetTG
