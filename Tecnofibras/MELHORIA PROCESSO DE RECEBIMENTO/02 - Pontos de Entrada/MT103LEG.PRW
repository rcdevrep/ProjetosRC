#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

// RC CONSULTORIA
// EVANDRO BURLIN
// PE MT103LEG- ADICIONA LEGENDA AO MATA103
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024
USER FUNCTION MT103LEG()

Local aLegenda := {}

    aAdd(aLegenda,{"BR_PRETO_1", "Pendente de Recebimento"})
    aAdd(aLegenda,{"BR_PRETO_2", "Recebimento OK"})
    aAdd(aLegenda,{"BR_PRETO_3", "Não Conformidade no Recebimento"})



RETURN aLegenda
