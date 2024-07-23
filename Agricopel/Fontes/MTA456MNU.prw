#include "totvs.ch"
/*/{Protheus.doc} MA440MNU
Criação de itens no menu da rotina LIBERAÇÃO DE CREDITO/ESTOQUE
@type function
@version  
@author Lucilene Mendes
@since 23/03/2023
@return variant, return_description
/*/
User Function MTA456MNU()

If Type("aRotina") == "A"
    aAdd(aRotina,{"Consuta Credito Serasa", "u_XAG0113A",    0, 6, 0, nil})
Endif

Return
