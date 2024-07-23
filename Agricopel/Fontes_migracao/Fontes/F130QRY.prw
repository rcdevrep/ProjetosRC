#include 'protheus.ch'
#include 'parmtype.ch'

user function F130QRY()

	Local cRet := ""
	
	//Cria Filtro para Projeto Nyke
	If cEmpant == '01'
		If MsgYesNo('Deseja Imprimir SOMENTE Títulos do Projeto Nyke? ')
			cRet := " AND SE1.E1_NUM+SE1.E1_PREFIXO IN ( "
			cRet += " SELECT F2_DOC+F2_PREFIXO FROM "+RetSqlName('SF2')+"(NOLOCK) SF2 "
			cRet += " WHERE F2_XPROJ = '2' "
			cRet += " AND F2_EMISSAO BETWEEN "+DTOS(mv_par13)+""
			If ( MV_PAR38 == 2 ) .and. mv_par14 >= mv_par36
				cRet += " AND '" + DtoS(mv_par36) + "'"
			Else
				cRet += " AND '" + DTOS(mv_par14) + "'"
			Endif
			cRet += ")"
		Endif
	Endif
	
return cRet