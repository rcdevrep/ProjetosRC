#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

// RC CONSULTORIA
// EVANDRO BURLIN
// PE MT103LEG- ADICIONA COR NA LEGENDA AO MATA103
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024
USER FUNCTION MT103COR()

Local aCores := {}

aAdd(aCores, {'F1_STATUS == "Z" ', 'BR_PRETO_1'})
aAdd(aCores, {'F1_STATUS == "X" ', 'BR_PRETO_2'})
aAdd(aCores, {'F1_STATUS == "Y" ', 'BR_PRETO_3'})

RETURN aCores
