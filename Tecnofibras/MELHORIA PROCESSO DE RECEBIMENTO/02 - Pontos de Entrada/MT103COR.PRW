#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

// RC CONSULTORIA
// EVANDRO BURLIN
// PE MT103LEG- ADICIONA COR NA LEGENDA AO MATA103
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024

USER FUNCTION MT103COR()

Local aCores :={}	

	aAdd(aCores,{'F1_XSTATUS=="Z"'	,'BR_PRETO_1', 'pré classificação/pendente recebimento'})
	aAdd(aCores,{'F1_XSTATUS=="A"'	,'DISABLE', 'Nota Classificada RCTEC05'})
	aAdd(aCores,{'F1_XSTATUS==" " .AND. F1_STATUS == "A"','DISABLE', 'Nota Classificada'})
	aAdd(aCores,{'Empty(F1_STATUS).And.F1_GF<>"GF"','ENABLE', 'NF Nao Classificada'})
	aAdd(aCores,{'Empty(F1_STATUS).And.F1_GF=="GF"','BR_MARRON_OCEAN', 'NF Não Classificada com Guarda Fiscal'})
	aAdd(aCores,{'F1_STATUS=="B"','BR_LARANJA', 'NF Bloqueada'})
	aAdd(aCores,{'F1_STATUS=="C"','BR_VIOLETA' , 'NF Bloqueada s/classf.'})
	//aAdd(aCores,{'F1_TIPO=="N"'	,'DISABLE', 'NF Normal'})
	aAdd(aCores,{'F1_TIPO=="P"'	,'BR_AZUL', 'NF de Compl. IPI'})
	aAdd(aCores,{'F1_TIPO=="I"','BR_MARROM', 'NF de Compl. ICMS'})
	aAdd(aCores,{'F1_TIPO=="D"'	,'BR_AMARELO', 'NF de Devolucao'})
	
	
	
RETURN aCores
