#Include 'protheus.ch'

/*/{Protheus.doc} FCalDesc
//PE na FINA110, utlizado para mostrar corretamente
o valor do título quando SEM Juros
@author Spiller
@since 04/04/2018
@version undefined
@param
@type function
/*/
User Function FCalDesc()  

	Local _cMarca := ParamIxb[1]
	Local _cTRB   := paramixb[3]
      
	//Se não calcular Juros debita o valor de juros do totalizador
   	If _xf110jur == .F.
   		 
   		//Se ta marcando o Registro Subtrai, senão SOMA! 
   		If (_cTRB)->E1_OK == _cMarca
			If  nValorMarca > 0 
	 			  nValorMarca:= nValorMarca-(nJuros)
	 			  nValor := nValor - (nJuros)
	   		Endif
	  	Else  
	  		nValorMarca:= nValorMarca+(nJuros)
	   		nValor := nValor + (nJuros)
	  	Endif
	Endif
    
Return         
 