#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

// RC CONSULTORIA
// EVANDRO BURLIN
// PE MT103LEG- ADICIONA LEGENDA AO MATA103
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024
USER FUNCTION MT103LEG()

Local aLegeUsr := {}

    aAdd(aLegeUsr, {"ENABLE"    ,"Docto. nao Classificado"}) //"Docto. nao Classificado"
    aAdd(aLegeUsr, {"BR_LARANJA","Docto. Bloqueado"}) //"Docto. Bloqueado"
    aAdd(aLegeUsr, {"BR_VIOLETA","Doc. C/Bloq. de Mov."}) //"Doc. C/Bloq. de Mov."
    aAdd(aLegeUsr, {"DISABLE"   ,"Docto. Normal"}) //"Docto. Normal"
    aAdd(aLegeUsr, {"BR_AZUL"   ,"Docto. de Compl. IPI"}) //"Docto. de Compl. IPI"
	aAdd(aLegeUsr, {"BR_MARROM" ,"Docto. de Compl. ICMS"}) //"Docto. de Compl. ICMS"
	aAdd(aLegeUsr, {"BR_PINK"   ,"Docto. de Compl. Preco/Frete/Desp. Imp."}) //"Docto. de Compl. Preco/Frete/Desp. Imp."
	aAdd(aLegeUsr, {"BR_CINZA"  ,"Docto. de Beneficiamento"}) //"Docto. de Beneficiamento"
	aAdd(aLegeUsr, {"BR_AMARELO","Docto. de Devolucao"}) //"Docto. de Devolucao"
    aAdd(aLegeUsr,{"BR_PRETO","Docto. em processo de conferencia"}) //"Docto. em processo de conferencia"
    aAdd(aLegeUsr,{"BR_BRANCO","Evento desacordo aguardando SEFAZ"}) // Evento desacordo aguardando SEFAZ
	aAdd(aLegeUsr,{"BR_AZUL_CLARO","Evento desacordo vinculado "}) // Evento desacordo vinculado 
	aAdd(aLegeUsr,{"BR_VERDE_ESCURO","Evento desacordo com problemas"}) // Evento desacordo com problemas

    aAdd(aLegeUsr,{"BR_PRETO_1", "pre classificacao/pendente recebimento"})
    //aAdd(aLegeUsr,{"BR_PRETO_2", "Recebimento OK"})
    //aAdd(aLegeUsr,{"BR_PRETO_3", "Não Conformidade no Recebimento"})



RETURN aLegeUsr
