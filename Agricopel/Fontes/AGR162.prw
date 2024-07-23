#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR162    ºAutor  ³Microsiga           º Data ³  02/15/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Programa para recalcular os itens, quando houver         º±±
±±º              alteracao na condicao de pagamento. 			          º±±
±±º             														  º±±
±±º             														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// TKEVALI.prw TMKVDEL.prw e AGR162.prw possuem a mesma logica de calculos dos itens e acumulo nos totais!!!


User Function AGR162(_xCampo)

	
	
	Local aa := 0 
	Local xx := 0 

	Default _xCampo := ""
	
	nPProduto	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
	nPPrcTab	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRCTAB"})
	nPQuant		:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
	nPVrUnit	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
	nPVlrItem 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
	nPPDesTab 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESTAB"})	
	nPPdescom 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})		
	nPDesc    	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
	nPVlrDesc 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VALDESC"})
	nPVdescom 	:= aScan(aHeader,{|x| alltrim(x[2]) == "UB_VDESCOM"})
	nPosTabAux  := aScan(aHeader,{|x| alltrim(x[2]) == "UB_AUXTAB"})
	nPCodPai    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_CODPAI"})
	nPTpVlr     := aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPVLR"})
    nPosAcr     := aScan(aHeader,{|x| alltrim(x[2]) == "UB_ACRE"})
    nPosVAc     := aScan(aHeader,{|x| alltrim(x[2]) == "UB_VALACRE"})
    nPXvlSt     := aScan(aHeader,{|x| alltrim(x[2]) == "UB_XVLST"})
	nPXVlTSt    := aScan(aHeader,{|x| Alltrim(x[2]) == "UB_XVLTST"})
	nPTES   	:= aScan(aHeader,{|x| Alltrim(x[2]) == "UB_TES"})
	nCBase   	:= aScan(aHeader,{|x| Alltrim(x[2]) == "UB_CBASE"})
	nTPBase   	:= aScan(aHeader,{|x| Alltrim(x[2]) == "UB_TPBASE"})
	  
	aValImp     := {}

	If Len(aCols) > 0 .And. Len(aCols) == 1 .And. Empty(aCols[1][nPProduto])
		Return .T.
	EndIf   

	For aa := 1 to Len(Acols)                           
		// ALAN LEANDRO - COMENTEI A PARTE QUE VALIDA SE ESTA OU NAO DELETADO, PARA AJUSTAR A LINHA MESMO QUANDO ELA ESTIVER DELETADA
		//If !( aCols[aa][Len(aCols[aa])] )//Deletado	UB_AUXTAB

		    If aCols[aa][nPTpVlr] <> "S" .or. cEmpAnt == "16" // (.or. cEmpAnt == "16") ajuste feito por Max Ivan (Nexus) em 16/07/2018, para Luparco
			   	aCols[aa][nPPrcTab]   := aCols[aa,nPosTabAux] + ROUND(((aCols[aa,nPosTabAux]* M->UA_X_ACRES) / 100),4)
		    EndIf
		 //  	aCols[aa][nPPrcTab]   := aCols[aa,nPosTabAux] + ROUND(((aCols[aa,nPosTabAux]* aCols[aa,nPAcres]) / 100),4)
		
			//Busco Valor da nova tabela escolhida	
			If _xCampo $ 'UA_TABELA/UA_OPER'  
				 Dbselectarea('DA1')
				 DbSetorder(1)
				 If DbSeek(xFilial("DA1")+M->UA_TABELA+aCols[aa][nPProduto])
					aCols[aa][nPPrcTab] := DA1->DA1_PRCVEN
					aCols[aa][nCBase]  	:= DA1->DA1_CBASE
					aCols[aa][nTPBase]  := DA1->DA1_TPBASE
				 Endif 	
			Endif 

												
		 //	aCols[aa][nPPdescom] := M->UA_DESCCOM
		 //	nPerTotal				:= (aCols[aa][nPPDesTab]+aCols[aa][nPPDescom]) - Round(((aCols[aa][nPPDesTab] * aCols[aa][nPPDescom]) / 100),4)
		 //	aCols[aa][nPDesc] 	:= nPerTotal
			aCols[aa][nPVrUnit]	 := aCols[aa][nPPrcTab] - Round(((aCols[aa][nPPrcTab] * aCols[aa][nPDesc] /100)),4)
			If cEmpAnt == "16" //Condição criada por Max Ivan em 23/07/2018, para considerar o acrescimo tb
			   aCols[aa][nPVrUnit]	 += Round(((aCols[aa][nPPrcTab] * aCols[aa][nPosAcr] /100)),4)
			EndIf
			aCols[aa][nPVlrItem] := aCols[aa][nPVrUnit] * aCols[aa][nPQuant]
			aCols[aa][nPVlrDesc] := Round(((aCols[aa][nPPrcTab] * aCols[aa][nPDesc] /100)),4) * aCols[aa][nPQuant]
			aCols[aa][nPVdescom] := Round(((aCols[aa][nPPrcTab] * aCols[aa][nPPdescom] /100)),4) * aCols[aa][nPQuant]
			If cEmpAnt == "16" //Condição criada por Max Ivan em 23/07/2018, para considerar o acrescimo tb
			   aCols[aa][nPosVAc] := Round(((aCols[aa][nPPrcTab] * aCols[aa][nPosAcr] /100)),4) * aCols[aa][nPQuant]
			EndIf

			//Caso tenha ST ,recalcula
			If aCols[aa][nPXvlSt] > 0 
				

				//Recalculo Indice de acordo com o Preço de tabela
				//Atualiza as Variaveis Fiscais
				n := aa
				MaFisAlt("IT_TES",aCols[n][nPTes],n)
				MaFisAlt("IT_QUANT",aCols[n][nPQuant],n)
				MaFisAlt("IT_PRCUNI",aCols[n][nPVrUnit],n)
				MaFisAlt("IT_VALMERC",A410Arred(aCols[n][nPQuant]*(aCols[n][nPVrUnit]) ,"UB_VLRITEM"),n)
				nVlrImp := 0
				nVlrTot  := aCols[n][nPvlritem]
				nVlrImp := MaFisRet(n,"IT_VALSOL")

				//calculo do ìndice
				nIndice := (1-( nVlrImp / (nVlrTot+nVlrImp) ))  //NoRound( (aCols[n][nPvlritem] / nTotST), 8)

				//Gravo o Preço unitário e Preço total
				nCalcPrc   := Round( (aCols[n][nPvlritem] * nIndice),4)//Round( (aCols[n][nPVrUnit] * nIndice),4) 
				nCalcPrcUN := Round( (aCols[n][nPVrUnit] * nIndice),4)
				aCols[n][nPvlritem] := nCalcPrc  
				aCols[n][nPVrUnit]  := nCalcPrcUN

				// Recalculo do Imposto
				MaFisAlt("IT_TES",aCols[n][nPTes],n)
				MaFisAlt("IT_QUANT",aCols[n][nPQuant],n)
				MaFisAlt("IT_PRCUNI",aCols[n][nPVrUnit],n)
				MaFisAlt("IT_VALMERC",A410Arred(aCols[n][nPQuant]*(aCols[n][nPVrUnit]) ,"UB_VLRITEM"),n)

				nVlrTot  := aCols[n][nPvlritem]
				nVlrImp := MaFisRet(n,"IT_VALSOL")

				//Gravo nos Campos Customizados
				If nVlrImp > 0
					aCols[n][nPXvlSt] := nVlrImp
					aCols[n][nPXVlTSt] := round(nVlrTot+nVlrImp,2)
				Endif

			Endif
			
			//Osmar 18.10.2019
			/*nVlrImp := 0
			nVlrImp := MaFisRet(aa,"IT_VALSOL") //MaFisRecal("UB_QUANT",1,ddatabase)

			If nVlrImp > 0
 				aCols[aa][nPXvlSt]  := nVlrImp //+ ROUND(((nVlrImp * M->UA_X_ACRES) / 100),4)
				aCols[aa][nPVrUnit] := (aCols[aa][nPVrUnit] - (nVlrImp / iif(aCols[aa][nPQuant] == 0 , 1,aCols[aa][nPQuant]) ))
				aCols[aa][nPVlrItem]:= (aCols[aa][nPVlrItem] - nVlrImp)
				aCols[aa][nPXvlTSt] := aCols[aa][nPVlrItem] + nVlrImp //aCols[aa][nPXvlSt] 

				//Msginfo("Valor de venda deste Produto -> "+str(nVlrImp))
			Endif*/			
		//EndIf					
	Next aa

	nVlrMerc := 0
	nVlrPedi := 0
	nVlrFat  := 0  //aqui
	For xx := 1 to Len(aCols)
		If !( aCols[xx][Len(aCols[xx])] )//Deletado												
			nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
			nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem] + aCols[xx][nPXvlSt]
			nVlrFat  := nVlrFat  + aCols[xx][nPVlrItem] + aCols[xx][nPXvlSt]
		EndIf			
	Next xx

	aValores[1] := Round(NoRound(nVlrMerc,4),2)
	aValores[6] := Round(NoRound(nVlrPedi,4),2)//nVlrPedi
	aValores[8] := Round(NoRound(nVlrFat,4),2)//nVlrFat   // aqui
   
  // alert(aValores[1])
  // alert(aValores[2])
  // alert(aValores[3])
  // alert(aValores[4])
  // alert(aValores[5])
  // alert(aValores[6])
  // alert(aValores[7])
  // alert(aValores[8])

   
   
	//If (oGettlv <> Nil)
	oGettlv:oBrowse:Refresh()
	//Tk273Refresh(aValores)	
	//Endif
	//SysRefresh()

Return .T.
