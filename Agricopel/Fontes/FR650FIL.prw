#include "protheus.ch"
/*/{Protheus.doc} FR650FIL
PE chamado no relat�rio de retorno para posicionar o t�tulo
@type function
@version P12
@author Rafael SMS
@since 16/07/2023
@return logical, Deve retornar .T. para que o relat�rio entenda que o t�tulo foi encontrado
/*/
User Function FR650FIL
Private lRel650 := .F.

ExecBlock("FA200FIL", .F., .F., ParamIXB[1])

Return lRel650
