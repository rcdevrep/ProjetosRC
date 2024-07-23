#INCLUDE "RWMAKE.CH"


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

User Function AGR162()

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
		
												
//			aCols[aa][nPPdescom] := M->UA_DESCCOM
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
		//EndIf					
	Next aa

	nVlrMerc := 0
	nVlrPedi	:= 0
	nVlrFat  := 0  //aqui
	For xx := 1 to Len(aCols)
		If !( aCols[xx][Len(aCols[xx])] )//Deletado												
			nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
			nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem]		
			nVlrFat  := nVlrFat + aCols[xx][nPVlrItem]		//aqui

		EndIf			
	Next xx

	aValores[1] := Round(NoRound(nVlrMerc,4),2)
	aValores[6] := Round(NoRound(nVlrPedi,4),2)
	aValores[8] := Round(NoRound(nVlrFat,4),2)   // aqui
   
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