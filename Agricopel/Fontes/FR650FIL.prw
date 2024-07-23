#include "protheus.ch"
/*/{Protheus.doc} FR650FIL
PE chamado no relatório de retorno para posicionar o título
@type function
@version P12
@author Rafael SMS
@since 16/07/2023
@return logical, Deve retornar .T. para que o relatório entenda que o título foi encontrado
/*/
User Function FR650FIL
Private lRel650 := .F.

ExecBlock("FA200FIL", .F., .F., ParamIXB[1])

Return lRel650
