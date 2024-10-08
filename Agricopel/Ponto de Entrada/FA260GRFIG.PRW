
#INCLUDE "PROTHEUS.CH"

user function FA260GRFIG
Local cCNPJ:= ""
Local cQuery:= ""
Local cQueryA:= ""
Local cQueryF:= ""
Local cQueryU:= ""
Local cQueryL:= ""

    cQueryL := " UPDATE " + RETSQLNAME("FIG")
	cQueryL += " SET FIG_FORNEC = '', FIG_LOJA = '', FIG_NOMFOR = '' "
	cQueryL += " WHERE D_E_L_E_T_ <> '*' "
	cQueryL += " AND FIG_DATA = '" +DTOS(DDATABASE)+ "' "
	cQueryL += " AND FIG_CONCIL = '2' "
	cQueryL += " AND FIG_DDASE2 = '' "
    cQueryL += " R_E_C_N_O_ = '"+FIG->(Recno())+"'"
			
	TcSqlExec(cQueryL)  
	


Return Nil
