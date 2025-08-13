
#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} F040ALT
O ponto de entrada F040ALT valida os dados da alteração apos a confirmação da mesma.  
@type     function
@author      Jader Berto
@since       2024.08.06
/*/
User Function F040ALT()
    IF EXISTBLOCK("CTLTIT01")
        EXECBLOCK("CTLTIT01",.F.,.F.)
    ENDIF
Return( Nil )
