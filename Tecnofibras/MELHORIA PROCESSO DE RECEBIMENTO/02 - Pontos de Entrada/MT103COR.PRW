#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

// RC CONSULTORIA
// EVANDRO BURLIN
// PE MT103LEG- ADICIONA COR NA LEGENDA AO MATA103
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024

USER FUNCTION MT103COR()

Local aCoresUsr :={	{'Empty(F1_STATUS).And.F1_GF<>"GF"'	,'ENABLE'			},;	// NF Nao Classificada
					{'Empty(F1_STATUS).And.F1_GF=="GF"'	,'BR_MARRON_OCEAN'	},;	// NF Não Classificada com Guarda Fiscal
					{'F1_STATUS=="B"'					,'BR_LARANJA'		},;	// NF Bloqueada
					{'F1_STATUS=="C"'					,'BR_VIOLETA'   	},;	// NF Bloqueada s/classf.
					{'F1_STATUS=="D"'					,'BR_BRANCO'	    },;	// Evento desacordo aguardando SEFAZ
					{'F1_STATUS=="E"'					,'BR_AZUL_CLARO'  	},;	// Evento desacordo vinculado
					{'F1_STATUS=="F"'					,'BR_VERDE_ESCURO' 	},;	// Evento desacordo com problemas
                    {'F1_STATUS == "Z" ', 'BR_PRETO_1'},;
                    {'F1_STATUS == "X" ', 'BR_PRETO_2'},;
                    {'F1_STATUS == "Y" ', 'BR_PRETO_3'},;
					{'F1_TIPO=="N"'						,'DISABLE'   		},;	// NF Normal
					{'F1_TIPO=="P"'						,'BR_AZUL'   		},;	// NF de Compl. IPI
					{'F1_TIPO=="I"'						,'BR_MARROM' 		},;	// NF de Compl. ICMS
					{'F1_TIPO=="C"'						,'BR_PINK'   		},;	// NF de Compl. Preco/Frete
					{'F1_TIPO=="B"'						,'BR_CINZA'  		},;	// NF de Beneficiamento
					{'F1_TIPO=="D"'						,'BR_AMARELO'		} }	// NF de Devolucao

RETURN aCoresUsr
