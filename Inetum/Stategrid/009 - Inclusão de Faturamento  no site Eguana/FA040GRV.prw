
#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} FA040GRV
Executado após a gravação de todos os dados referentes ao título e antes da contabilização .   
@type     function
@author      Jader Berto
@since       2024.08.06
/*/
User Function FA040GRV()
    IF EXISTBLOCK("CTLTIT01")
        EXECBLOCK("CTLTIT01",.F.,.F.)
    ENDIF
Return( Nil )
