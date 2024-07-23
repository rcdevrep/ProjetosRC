

/*/{Protheus.doc} F200VAR
//PE  para baixar títulos em que o prefixo foi registrado no banco com 3 casas
@author Spiller
@since 11/10/2019
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/    
User function F200VAR()     

	Local _aArea   := getArea() 
	Local _cTitulo := paramIxb[1][1] //Numero do título

	//Se o título não estiver Vazio, tamanho para garantir que 
	If alltrim(_cTitulo) <> ""
		If Len(alltrim(_cTitulo)) == 17 //Significa que é um título antigo com 3 posições no prefixo registradas no banco
			cNumTit := substr(_cTitulo,1,3)+"  "+substr(_cTitulo,4,len(_cTitulo) - 5)
		Endif
	Endif 
	
	restarea(_aArea)
	
Return