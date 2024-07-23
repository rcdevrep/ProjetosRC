#include 'protheus.ch'  
    

/*/{Protheus.doc} XAG0059
Programa que realiza a atualização do preço para  produtos com ST,
foi criado para atender o Chamado 186178, e é disparado pelo campo  UB_XVLTST
@author Leandro Spiller
@since 07/11/2019
@version 1
@param aParam, array, Contém duas Strings: CdEmpresa e CdFilial da execução
@return Não retorna nada
@type function
/*/
User Function XAG0059(xCampo)
            
	Local nPVrUnit	 := aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"}) 
	Local nPVlritem	 := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_VLRITEM"})
	Local nPXvlSt    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_XVLST"})
	Local nPXVlTSt   := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_XVLTST"}) 
	Local nPrctab	 := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_PRCTAB"})
	Local nPosPRD	 := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_PRODUTO"}) 
	Local nPosQtd	 := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_QUANT"})    
	Local nPosDesc	 := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_DESC"}) 
	Local nPosValDes := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_VALDESC"}) 
	Local nPTES      := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_TES"})
	Local _cTesINT   := ""
	Local nIndice    := 1 
	Local nTotST     := 0 
	Local nValST     := 0 
	Local nVunit     := 0  
 	Local nCalcPrc   := 0   
	Local nCalcPrcUN := 0 
 	Local nLimit     := 500
 	Local lSomou     := .F.
 	Local lSubtraiu  := .F.  
 	Local cProdAtu   := "" 
	Local xx         := 0 

 	
 	Default xCampo := "UB_XVLTST" 
 	//Return .T.//retirar          
 	//Captura produto 
 	If xCampo == 'UB_PRODUTO'
 		cProdAtu := M->UB_PRODUTO
 	Else
 		cProdAtu := aCols[n][nPosPRD]
 	Endif

	//Chamado no Modo Edição dos Campos Acresc. e Desc.
	If xCampo == "UB_DESC" .OR. xCampo == "UB_ACRE"
		
		Dbselectarea('SB1')
		If cProdAtu <> SB1->B1_COD
			DbSetOrder(1)
			DbSeek(xFilial('SB1') + cProdAtu)
		Endif

		//Para o Tipo querosene não pode incluir Desc/Acrescimo
		If SB1->B1_TIPO == 'QR'
			Return .F.
		Endif

		Return .T.
	Endif 	
 	                  
 	//Verifica se Está na regra de Execução
 	If !(u_XAG0059V(cProdAtu))   
 		//Limpa Valores de ST
 		If xCampo == "UB_PRODUTO"  .and. aCols[n][nPXvlSt] > 0 
			aCols[n][nPXvlSt]    := 0 
			aCols[n][nPXVlTSt]   := 0 
			TK273Calcula("UB_VLRITEM") 
 		Endif                
 		//Recalcula somando ST
 		If xCampo == "UB_VRUNIT" 
 			For xx := 1 to Len(aCols)
				If !( aCols[xx][Len(aCols[xx])] )//Deletado												
					aValores[6] += aCols[xx][nPXvlSt]
				EndIf			
			Next xx
 		Endif
 		Return .T.
 	Endif         
 	
 	//Se não tem os campos de ST, ignora atualização
 	If  nPXvlSt == 0  .or. nPXVlTSt == 0 
 		Return .T.
 	Endif 

	//Ajusta TES de acordo com a TES inteligente 
	_cTesINT := MaTesInt(2,'01',M->UA_CLIENTE,M->UA_LOJA,"C",cProdAtu,NIL,M->UA_TIPOCLI)
	If aCols[n][nPTES] <>  _cTesINT .and. !Empty(_cTesINT)
		aCols[n][nPTES] := _cTesINT
	Endif
 	     
 	//Captura valores no Acols
 	nVTabPrc := aCols[n][nPrctab] 
 	nVunit 	 := aCols[n][nPVrUnit]   
 	nTotST 	 := aCols[n][nPXVlTSt]
 	nQtdPrd  := aCols[n][nPosQtd] 
	nVlrTot  := aCols[n][nPvlritem] 
	nValST   := aCols[n][nPXVlSt]  

	// Executa função somente se não foi calculado ainda preço 
	// Dessa Forma calcula o índice em cima do Preço de tabela 
	If nValST == 0 .or. xCampo == 'UB_PRODUTO'  
	
		MaFisAlt("IT_TES",aCols[n][nPTes],n)
		MaFisAlt("IT_QUANT",aCols[n][nPosQtd],n)
		MaFisAlt("IT_PRCUNI",aCols[n][nPVrUnit],n)
		MaFisAlt("IT_VALMERC",A410Arred((aCols[n][nPosQtd]*aCols[n][nPVrUnit]) ,"UB_VLRITEM"),n)
							 
		nVlrImp := 0
		nVlrImp := MaFisRet(n,"IT_VALSOL") //MaFisRecal("UB_QUANT",1,ddatabase)

		//Retirado pois tem casos de ST ZERO
		If nVlrImp > 0
			aCols[n][nPXvlSt]  := nVlrImp
			aCols[n][nPXVlTSt] := Round(nVlrTot+nVlrImp,2)
		Else
			aCols[n][nPXvlSt]  := 0 
			aCols[n][nPXVlTSt] := 0 
		Endif 
	Endif                 

	//Totalizadores de St
	nTotST  := aCols[n][nPXVlTSt]
	nValST  := aCols[n][nPXVlSt]   

	//Executa funções de acordo com o Campo
 	If xCampo == 'UB_PRODUTO'  

		//Só calcula se tiver ST
		If nTotST > 0  
			nIndice := (1-( aCols[n][nPXvlSt] / (aCols[n][nPXVlTSt] /*- aCols[n][nPXvlSt]*/)  ))  //NoRound( (aCols[n][nPvlritem] / nTotST), 8)

			nCalcPrc   := Round( (aCols[n][nPvlritem] * nIndice),4)//Round( (aCols[n][nPVrUnit] * nIndice),4) 
			nCalcPrcUN := Round( (aCols[n][nPVrUnit] * nIndice),4)

			aCols[n][nPXvlSt]   := round(nVlrTot - nCalcPrc,2)      
			aCols[n][nPXVlTSt]  := round(nVlrTot,2)                               	
			aCols[n][nPvlritem] := nCalcPrc  
			aCols[n][nPVrUnit]  := nCalcPrcUN
		
			TK273Calcula("UB_VLRITEM") 
		EndIf

		Return .T.	

	ElseIf	xCampo == "UB_VRUNIT"   		  

		aCols[n][nPosDesc]  := 0 //Zera Desconto
    	aCols[n][nPosValDes]  := 0 //Zera Total Desconto               	
    	
    	nVlrMerc := 0
		nVlrPedi := 0
		For xx := 1 to Len(aCols)
			If !( aCols[xx][Len(aCols[xx])] )//Deletado												
				aValores[6] += aCols[xx][nPXvlSt]
			EndIf			
		Next xx

		Return .T.
	ElseIf xCampo == "UB_XVLTST"
		
		nIndice 			:= iif( nTotST == 0, 1, aCols[n][nPvlritem] / nTotST) //NoRound( (aCols[n][nPvlritem] / nTotST), 8)
		nCalcPrc 		 	:= Round( (M->UB_XVLTST * nIndice),4) 
		//nTotSt      		:= M->UB_XVLTST 
		
		aCols[n][nPVrUnit]  := NoRound( (Round(nCalcPrc,4) /  aCols[n][nPosQtd]),4 )
		aCols[n][nPvlritem] := Round( aCols[n][nPVrUnit] * aCols[n][nPosQtd] , 4 ) //Round(nCalcPrc,4) 

		MaFisAlt("IT_TES",aCols[n][nPTes],n)
		MaFisAlt("IT_QUANT",aCols[n][nPosQtd],n)
		MaFisAlt("IT_PRCUNI",aCols[n][nPVrUnit],n)
		MaFisAlt("IT_VALMERC",A410Arred(aCols[n][nPosQtd]*(aCols[n][nPVrUnit]) ,"UB_VLRITEM"),n)

		nVlrImp := 0
		nVlrImp := MaFisRet(n,"IT_VALSOL") 

		//Retirado pois tem casos de ST ZERO
		If nVlrImp > 0
			aCols[n][nPXvlSt]  := nVlrImp
			aCols[n][nPXVlTSt] := Round(aCols[n][nPvlritem]+nVlrImp,2)
		Else
			aCols[n][nPXvlSt]  := 0
			aCols[n][nPXVlTSt] := 0
		Endif 
		TK273Calcula("UB_VLRITEM") 
		//U_Agr063Calc("UB_XVLTST")

	Else
	
		nIndice :=  iif( nTotST == 0, 1,aCols[n][nPvlritem] / nTotST)//NoRound( (aCols[n][nPvlritem] / nTotST), 8)
	
	Endif  
	
 	//Se calculou e trouxe vazio, ignora 
 	If nTotST == 0 
	 	M->UB_XVLTST 		:= 0 
		aCols[n][nPXVlSt]  := 0 
		MsgInfo('Não há Valor de ST para esse item, Você pode recalcular o preço clicando no Campo Quantidade!')
 		Return .T.
 	Endif 
	                        
	                                              	    
	//Se Valor calculado não for o Valor pedido Recalcula com índice
	While Round(aCols[n][nPXVlTSt],2)  <>  round(M->UB_XVLTST,2) .AND. nLimit > 0       
	
		nDifValor :=  ( M->UB_XVLTST - aCols[n][nPXVlTSt] )  
		                
		IF nDifValor > 0 
       		If !lSubtraiu
       			aCols[n][nPVrUnit] := (aCols[n][nPVrUnit] + iif( nDifValor > 1 ,0.1000 ,  0.0001))    
       		Endif
       		lSomou := .T.
        Else 
        	If !lSomou
        		aCols[n][nPVrUnit] := (aCols[n][nPVrUnit] - iif( nDifValor < -1 ,0.1000 ,  0.0001))  
        	Endif
        	lSubtraiu := .T. 	
		Endif     
		                         
		If aCols[n][nPVrUnit] <= 0    
			Exit
		Endif      
	
		
		//Executa função para recalculo preço
		aCols[n][nPvlritem] := Round( aCols[n][nPVrUnit] * aCols[n][nPosQtd] , 4 ) //Round(nCalcPrc,4) 

		MaFisAlt("IT_TES",aCols[n][nPTes],n)
		MaFisAlt("IT_QUANT",aCols[n][nPosQtd],n)
		MaFisAlt("IT_PRCUNI",aCols[n][nPVrUnit],n)
		MaFisAlt("IT_VALMERC",A410Arred(aCols[n][nPosQtd]*(aCols[n][nPVrUnit]) ,"UB_VLRITEM"),n)

		nVlrImp := 0
		nVlrImp := MaFisRet(n,"IT_VALSOL") 
		If nVlrImp > 0
			aCols[n][nPXvlSt]  := nVlrImp
			aCols[n][nPXVlTSt] := Round(aCols[n][nPvlritem]+nVlrImp,2)
		Endif 
		TK273Calcula("UB_VLRITEM") 

		//U_Agr063Calc("UB_XVLTST")  
			
				                  
		//Se já somou e subtraiu quer dizer que é impossível chegar no Valor desejado, dessa forma saí do While 
		//para Evitar Loop Infinito
		If (lSomou .and. lSubtraiu) 
			nLimit := 0 
			//M->UB_XVLTST := aCols[n][nPXVlTSt]
			Exit	
		Endif
		
		nLimit--
		                        	 
	Enddo
	
	M->UB_XVLTST := aCols[n][nPXVlTSt]

Return .T.     

                      
//valida se Deve executar o Programa
User Function XAG0059V(xProduto)
                           
	Local lRetV := .F.
	Default xProduto := ""    

	Dbselectarea('SB1')

	If xProduto <> SB1->B1_COD 
	   DbSetOrder(1)
	   DbSeek(xfilial('SB1') + xProduto)
	Endif
	
    If alltrim(SB1->B1_TIPO) == 'QR'//SB1->B1_GRTRIB = '001'
    	lRetV := .T.
    Endif

Return lRetV


//	PEDIDO DE VENDA -> Calcula o Preço unitário - ST para Querosene
User Function XAG0059P(xCampo)

	Local nPPrunit 	 := aScan(aHeader,{|x| Alltrim(x[2]) == "C6_PRUNIT"})//Preco de Tabela 
	Local nPPrcVen   := aScan(aHeader,{|x| alltrim(x[2]) == "C6_PRCVEN"})//Preco de Venda
	Local nPValor    := aScan(aHeader,{|x| alltrim(x[2]) == "C6_VALOR"})
	Local nPProduto  := aScan(aHeader,{|x| alltrim(x[2]) == "C6_PRODUTO"})
	Local nPXvlSt	 := aScan(aHeader,{|x| alltrim(x[2]) == "C6_XVLST"})
	Local nPXVlTSt 	 := aScan(aHeader,{|x| alltrim(x[2]) == "C6_XVLTST"})
	Local nPosQtd    := aScan(aHeader,{|x| alltrim(x[2]) == "C6_QTDVEN"})
	Local nPosTes    := aScan(aHeader,{|x| alltrim(x[2]) == "C6_TES"})
	Local nPosPrcTab := aScan(aHeader,{|x| alltrim(x[2]) == "C6_PRCLIST"})
	Local nPTotLiq   := aScan(aHeader,{|x| alltrim(x[2]) == "C6_TOTLIQ"})
	Local nPTotItem  := aScan(aHeader,{|x| alltrim(x[2]) == "C6_TOTITEM"})
	Local nPValDesc  := aScan(aHeader,{|x| alltrim(x[2]) == "C6_VALDESC"})
	Local nPDescont  := aScan(aHeader,{|x| alltrim(x[2]) == "C6_DESCONT"})
	Local nIndice    := 0 
	Local _cProduto  := ""
	Local _nVlrImp   := 0 
	Local nLimit     := 300 
	Local lSomou     := .F.
 	Local lSubtraiu  := .F.  

	//Se não tiver os campos de ST criados Sai da Rotina
	If nPXvlSt == 0 .or. nPXVlTSt == 0 
		Return .T.	
	Endif

	//Posiciona na SB1
	DbSelectarea('SB1')
	If SB1->B1_COD <> aCols[n][nPProduto]
		DbSetorder(1)
		DbSeek(xFilial('SB1') + aCols[n][nPProduto])
	Endif 

	_cProduto := SB1->B1_COD 

	//Se não for Querosene sai da função
	If SB1->B1_TIPO <> 'QR'
		Return .T.	
	Endif  
	
	//Se For Campo Total de ST, Calcula Unitário
	If xCampo == 'C6_XVLTST'
		//Se estiver Zerado, Preenche com Preço de Tabela 
		If M->C6_XVLTST == 0 
			M->C6_XVLTST := aCols[n][nPValor] //aCols[n][nPPrunit]
		Endif
	Endif 

	MaFisSave()
	MaFisEnd() 

	//Calculo do Valor de ICMS ST			
	//_nVlrImp := U_XAG0061(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_TIPOCLI,_cProduto,aCols[n][nPosTes],aCols[n][nPosQtd],aCols[n][nPosPrcTab]						,NoRound(aCols[n][nPosQtd]*aCols[n][nPosPrcTab],4))[57]
	  _nVlrImp := U_XAG0061(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_TIPOCLI,_cProduto,aCols[n][nPosTes],aCols[n][nPosQtd],NoRound(M->C6_XVLTST /aCols[n][nPosQtd],4) ,M->C6_XVLTST)[57]
				//XAG0061(cCliente     , cLoja      ,cTipo         ,cProduto   ,cTes           ,nQtd             ,nPrc                ,nValor                                           ,aCab)
	
	If _nVlrImp > 0
		aCols[n][nPXvlSt] := _nVlrImp
		aCols[n][nPXVlTSt] := Round(M->C6_XVLTST  + _nVlrImp , 2 ) //Round(aCols[n][nPValor]+_nVlrImp,2)
	Else
		Return .T.
	Endif 

	//Calculo o preço Unitário pelo índice
	
	nIndice := (1-( aCols[n][nPXvlSt] / (aCols[n][nPXVlTSt] /*- aCols[n][nPXvlSt]*/)  )) 

	nCalcPrc   := Round( NoRound( M->C6_XVLTST/*aCols[n][nPosPrcTab]*/,4) * nIndice ,2)
	nCalcPrcUN := Round( (NoRound(M->C6_XVLTST / aCols[n][nPosQtd] /*aCols[n][nPosPrcTab]*/,4) * nIndice) ,4)

	aCols[n][nPValor] 	:= Round(nCalcPrcUN * aCols[n][nPosQtd] ,2)  
	aCols[n][nPPrcVen]  := nCalcPrcUN  
	aCols[n][nPPrunit]  := nCalcPrcUN                     	

	//Recalculo o Total de ST de acordo com o Unitário encontrado para garantir o arredondamento
	_nVlrImp := U_XAG0061(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_TIPOCLI,_cProduto,aCols[n][nPosTes],aCols[n][nPosQtd],aCols[n][nPPrcVen],aCols[n][nPValor])[57]

	aCols[n][nPXvlSt]   := _nVlrImp      
    aCols[n][nPXVlTSt]  := aCols[n][nPValor] + _nVlrImp

	
	//Se Valor calculado não for o Valor pedido Recalcula com índice
	While Round(aCols[n][nPXVlTSt],2)  <>  round(M->C6_XVLTST,2) .AND. nLimit > 0       
	
		nDifValor :=  ( M->C6_XVLTST - aCols[n][nPXVlTSt] )  
		                
		IF nDifValor > 0 
       		If !lSubtraiu
       			aCols[n][nPPrcVen] := (aCols[n][nPPrcVen] + iif( nDifValor > 1 ,0.1000 ,  0.0001))    
       		Endif
       		lSomou := .T.
        Else 
        	If !lSomou
        		aCols[n][nPPrcVen] := (aCols[n][nPPrcVen] - iif( nDifValor < -1 ,0.1000 ,  0.0001))  
        	Endif
        	lSubtraiu := .T. 	
		Endif  
                 
		If aCols[n][nPPrcVen] <= 0    
			Exit
		Endif      
	
		
		//Executa função para recalculo preço
		aCols[n][nPValor] := Round( aCols[n][nPPrcVen] * aCols[n][nPosQtd] , 2 ) //Round(nCalcPrc,4) 

		_nVlrImp := U_XAG0061(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_TIPOCLI,_cProduto,aCols[n][nPosTes],aCols[n][nPosQtd],aCols[n][nPPrcVen],aCols[n][nPValor])[57]
	
		If _nVlrImp > 0
			aCols[n][nPXvlSt]  := _nVlrImp
			aCols[n][nPXVlTSt] := Round(aCols[n][nPValor]+_nVlrImp,2)
		Endif 
			                  
		//Se já somou e subtraiu quer dizer que é impossível chegar no Valor desejado, dessa forma saí do While 
		//para Evitar Loop Infinito
		If (lSomou .and. lSubtraiu) 
			nLimit := 0 
			Exit	
		Endif
		
		nLimit--
		                        	 
	Enddo 

	//Atualiza o Preço unitário
	aCols[n][nPPrunit] := aCols[n][nPPrcVen]
	aCols[n][nPTotLiq]  := aCols[n][nPValor] 
	aCols[n][nPTotItem] := aCols[n][nPValor]
	//aCols[n][nPValDesc] := aScan(aHeader,{|x| alltrim(x[2]) == "C6_VALDESC"})
	//aCols[n][nPDescont] := aScan(aHeader,{|x| alltrim(x[2]) == "C6_DESCONT"})


Return .T.                 


/*User Function XAG0059T()   

	Local _aSC5   := {}  
	Local _aSC6   := {}
	Local _aItens := {}

	Aadd(_aSC5, {"C5_FILIAL"  , xFilial("SC5")          , Nil})
	Aadd(_aSC5, {"C5_TIPO"    , "N"                     , Nil})
	Aadd(_aSC5, {"C5_CLIENTE" , '00368 '   				, Nil})
	Aadd(_aSC5, {"C5_LOJACLI" , '01'  					, Nil})
	Aadd(_aSC5, {"C5_LOJAENT" , '01'  					, Nil})
	Aadd(_aSC5, {"C5_TIPOCLI" , 'R'  					, Nil})
	Aadd(_aSC5, {"C5_EMISSAO" , dDataBase               , Nil})
	Aadd(_aSC5, {"C5_MOEDA"   , 1                       , Nil})
	Aadd(_aSC5, {"C5_CONDPAG" , "911"                   , Nil})
	Aadd(_aSC5, {"C5_TABELA"  , "001"                   , Nil})
	Aadd(_aSC5, {"C5_TRANSP"  , '000022' 				, Nil})
	Aadd(_aSC5, {"C5_VEND1"   , 'RL0231'  				, Nil})
	Aadd(_aSC5, {"C5_VEND2"   , ''  					, Nil})
	Aadd(_aSC5, {"C5_IMPORTA" , "P"                     , Nil})
	Aadd(_aSC5, {"C5_TIPLIB"  , "1"                     , Nil})
	Aadd(_aSC5, {"C5_X_ORIG"  , "XAG0038"               , Nil})
	Aadd(_aSC5, {"C5_BLQ"     , ""                      , Nil})    
	Aadd(_aSC5, {"C5_TPCARGA" , "2"                 	, Nil})  
	Aadd(_aSC5, {"C5_GERAWMS" , "1"           	    	, Nil})  
		
	AAdd(_aSC6, {"C6_FILIAL"      , xFilial("SC6")              , Nil})
	AAdd(_aSC6, {"C6_ITEM"        , '01'                    	, Nil})
	AAdd(_aSC6, {"C6_PRODUTO"     , '00060040       '		    , Nil})
	AAdd(_aSC6, {"C6_DESCRI"      , 'AGRICOPEL QUEROSENE 12X1 ' , Nil})
	AAdd(_aSC6, {"C6_UM"       	  , 'CX'      					, Nil})
	AAdd(_aSC6, {"C6_QTDVEN"      , 10			                , Nil})
	AAdd(_aSC6, {"C6_QTDLIB"      , 10			                , Nil})
	AAdd(_aSC6, {"C6_PRCVEN"      , 93.8586		                , Nil})
	AAdd(_aSC6, {"C6_TES"         , '730'					    , Nil})
	AAdd(_aSC6, {"C6_LOCAL"       , '01'					    , Nil})
	AAdd(_aSC6, {"C6_CLI"         , '00368 '			        , Nil})
	AAdd(_aSC6, {"C6_ENTREG"      , dDataBase                   , Nil})
	AAdd(_aSC6, {"C6_PRUNIT"      , 93.8586		                , Nil})
	AAdd(_aSC6, {"C6_TURNO"       , ""                          , Nil})
	AAdd(_aSC6, {"C6_CLASFIS"     , '030'						, Nil}) 
	AAdd(_aSC6, {"C6_XVLTST"     , 938.59						, Nil}) 
	
	AAdd(_aItens, _aSC6)
	lMsErroAuto := .F.
	MsExecAuto({|x,y,z|MATA410(x,y,z)}, _aSC5, _aItens, 3)

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		Return(.F.)
	EndIf
	
	ALERT(SC5->C5_NUM)

Return
*/