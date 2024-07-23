#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} M460FIM
**** ATENÇÃO COMPILAR APENAS NO AMBEINTE CUSTOM ***** 
cria tabela CD6 - Combustíveis na transmissão da Nota
@author Leandro Hey Spiller
@since 11/06/2018
@version 1
@type function
/*/

User function M460FIM()

    //Gera complemento de combustíveis
	U_XAG0032()

return 