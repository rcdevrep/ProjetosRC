#INCLUDE "TOTVS.CH"

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Personalizado por Max Ivan (Nexus) em 27/12/2018, para tratamento deste fonte dentro do PE M460MARK        ³
//³Obs: Os parâmetros da rotina (PE) original (M460MARK), estão como primeiro parâmetro desta rotina SH460MAR.³
//³     Sendo assim, os parâmetros ficam conforme exemplo abaixo:                                             ³
//³     	NO FONTE ORIGINAL M460MARK			AQUI NESTE FONTE SH460MARK                                    ³
//³				ParamIxb[1]							ParamIxb[1,1]                                             ³
//³				ParamIxb[2]							ParamIxb[1,2]                                             ³
//³Obs2: O retorno do fonte original está no segundo parâmetro (ParamIxb[2])                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
User Function SH460MAR()

    Local _lRet := ParamIxb[2]

Return(_lRet)