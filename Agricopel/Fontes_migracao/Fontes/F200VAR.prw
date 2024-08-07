

/*/{Protheus.doc} F200VAR
//PE  para baixar t�tulos em que o prefixo foi registrado no banco com 3 casas
@author Spiller
@since 11/10/2019
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/    
User function F200VAR()     

	Local _aArea   := getArea() 
	Local _cTitulo := paramIxb[1][1] //Numero do t�tulo

	//Se o t�tulo n�o estiver Vazio, tamanho para garantir que 
	If alltrim(_cTitulo) <> ""
		If Len(alltrim(_cTitulo)) == 17 //Significa que � um t�tulo antigo com 3 posi��es no prefixo registradas no banco
			cNumTit := substr(_cTitulo,1,3)+"  "+substr(_cTitulo,4,len(_cTitulo) - 5)
		Endif
	Endif 
	
	restarea(_aArea)
	
Return