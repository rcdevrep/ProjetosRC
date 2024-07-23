#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MT103LEG
Adicionar legenda para valida��o das quantidades e valores
@author TSC 422-Rodrigo
@since 13/09/11
@version 1
@type user function
/*/
User Function MT103LEG

	Local aLegenda := PARAMIXB[1]

	aAdd(aLegenda, {"BR_BRANCO","Bloqueado Diverg�ncia Pedido"} )

Return(aLegenda)