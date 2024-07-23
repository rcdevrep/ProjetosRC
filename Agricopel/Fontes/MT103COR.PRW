#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MT103COR
Ponto de entrada para tratar as cores do browse de MATA103.PRW
Inserir uma regra de liberação da pré nota
@author TSC 422-Rodrigo
@since N/A
@version 1
@type function
/*/
User Function MT103COR 

    Local aCores := ParamIXB[1]

    aCores[4][1] := "F1_TIPO == 'N' .AND. F1_STATUS == 'X'"
    aAdd(aCores, {"F1_STATUS=='X'","BR_BRANCO"} )

Return aCores