#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

USER FUNCTION MT103COR()

Local aCores := {}

aAdd(aCores, {'F1_STATUS == "Z" ', 'BR_PRETO_1'})

RETURN aCores
