#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} F200VAR
//PE  para alterar o idcnab 
@author groundwork
@since 02/11/2012
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/    
User function F200VAR()     

	Local _cQry := " "

	
	If MV_PAR06 == "422" // ESPECIFICO SAFRA 

		 _cQry := " UPDATE "+RetSqlName("SE1")+" SET E1_IDCNAB = LEFT(E1_NUMBCO,9) "
		 _cQry += " WHERE D_E_L_E_T_ = '' AND LEN(E1_NUMBCO) = '9' AND E1_NUMBCO <> E1_IDCNAB AND E1_PORTADO = '422' "

		TCSqlExec(_cQry)

	ElseIf MV_PAR06 == "001"  // BANCO DO BRASIL 
		
		_cQry := " UPDATE "+RetSqlName("SE1")+" SET E1_IDCNAB = LEFT(E1_NUMBCO,10) "
		_cQry += " WHERE D_E_L_E_T_ = '' AND LEN(E1_NUMBCO) = '10' AND E1_NUMBCO <> E1_IDCNAB AND E1_PORTADO = '001' "
		
		TCSqlExec(_cQry)

	Endif

Return 
