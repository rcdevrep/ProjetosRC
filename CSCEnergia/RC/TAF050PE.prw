#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function TAFA050()
    Local _cUsers   := ""

    _cUsers	:= SuperGetMV("MV_USRCOMP",.F.,"000000")

    IF Altera .AND. !(__cUserId $ _cUsers)

        Help(NIL, NIL, "Atencao!", NIL, "Usuario sem permissao para alterar complemento cadastral.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Entre em contato com a TI."})
        Return .F.
    ENDIF

RETURN .T.
