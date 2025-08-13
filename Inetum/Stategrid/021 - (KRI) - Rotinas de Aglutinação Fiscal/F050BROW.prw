#include "Totvs.ch"                                                                                                



User Function F050BROW()



    If !cArqRel == "SIGAFIS.REL"
        Aadd(aRotina,	{"Rejeitar/Liberar"		,"U_STAA048(SE2->(RECNO()))", 0 , 4})
        Aadd(aRotina,    {"Alterar dados Bancarios"    ,"U_STAA054()", 0 , 4})
    EndIf


Return      

