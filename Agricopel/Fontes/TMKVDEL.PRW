#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKVDEL   ºAutor  ³Deco                º Data ³  20/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Programa para recalcular os itens e atualizar os totais  º±±
±±º              do rodape do atendimento qdo houver exclusao de alguma   º±±
±±º              linha do Browse.                                         º±±
±±º             														                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                            

// TKEVALI.prw TMKVDEL.prw e AGR162.prw possuem a mesma logica de calculos dos itens e acumulo nos totais!!!

User Function TMKVDEL()

	
	Local xx := 0 
	Local aa := 0 
	Local _lRecalc := .T.
	Private	bFolderRefresh	:= {|| (IIf(!lTk271Auto,Tk273FRefresh(),""))}			// Efetua o Refresh do Folder
	
   If SM0->M0_CODIGO = '01' .And. (Alltrim(SM0->M0_CODFIL) = '01' .Or. Alltrim(SM0->M0_CODFIL) == '02' .OR. Alltrim(SM0->M0_CODFIL) =="06")  // Somente para Agricopel Matriz e Pien 

		nPProduto	:=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
		nPPrcTab	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRCTAB"})
		nPQuant		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
		nPVrUnit	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
		nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
		nPPDesTab 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESTAB"})	
		nPPdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})		
		nPDesc    	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
		nPVlrDesc 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VALDESC"})
		nPVdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VDESCOM"})	 
 	    nPosTabAux  :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_AUXTAB"})   
        nPXvlSt     :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_XVLST"})
 	    
 	    nPTpVlr  :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPVLR"}) 
	
		If Len(aCols) > 0 .And. Len(aCols) == 1 .And. Empty(aCols[1][nPProduto])
			Return .T.
		EndIf

		For aa := 1 to Len(Acols)                           
	
			// Qdo for combustivel Nao considera a execuçao desta logica 
			xProduto := aCols[aa][nPProduto]
			lCombust := .F.
			DbSelectArea("SB1")
			DbSetOrder(1)
			If(DbSeek(xFilial("SB1")+xProduto))
				If SB1->B1_TIPO == "CO"
					lCombust := .T.		
				EndIf
			EndIf
		
			//Caso tenha ST não efetua o Recalculo
			If nPXvlSt
				If (aCols[aa][nPXvlSt]) > 0 
					_lRecalc := .F.
				Else
					_lRecalc := .T.
				Endif
			Else
				_lRecalc := .T.
			Endif 

	
			// ALAN LEANDRO - COMENTEI A PARTE QUE VALIDA SE ESTA OU NAO DELETADO, PARA AJUSTAR A LINHA MESMO QUANDO ELA ESTIVER DELETADA
			//If !( aCols[aa][Len(aCols[aa])] )//Deletado											
			If !lCombust  .and. _lRecalc

			   aCols[aa][nPPdescom] := 0 //M->UA_DESCCOM retirado por Max Ivan (Nexus) em 09/09/2019, pelo projeto de Revitalização do Call Center
			   
			   If aCols[aa][nPTpVlr] <> "S"
				   aCols[aa][nPPrcTab]   := aCols[aa,nPosTabAux] + ROUND(((aCols[aa,nPosTabAux]* M->UA_X_ACRES) / 100),4)
			   EndIf

				//nPerTotal				:= (aCols[aa][nPPDesTab]+aCols[aa][nPPDescom]) - Round(((aCols[aa][nPPDesTab] * aCols[aa][nPPDescom]) / 100),4)
				//aCols[aa][nPDesc] 	:= nPerTotal
				aCols[aa][nPVrUnit]	:= aCols[aa][nPPrcTab] - Round(((aCols[aa][nPPrcTab] * aCols[aa][nPDesc] /100)),4) 
				aCols[aa][nPVlrItem] := aCols[aa][nPVrUnit] * aCols[aa][nPQuant]
				aCols[aa][nPVlrDesc]	:= Round(((aCols[aa][nPPrcTab] * aCols[aa][nPDesc] /100)),4) * aCols[aa][nPQuant]
				aCols[aa][nPVdescom] := Round(((aCols[aa][nPPrcTab] * aCols[aa][nPPdescom] /100)),4) * aCols[aa][nPQuant]
			EndIf					
			//Endif
		Next aa
	
		nVlrMerc := 0
		nVlrPedi	:= 0
		For xx := 1 to Len(aCols)
			If !( aCols[xx][Len(aCols[xx])] )//Deletado												
				nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
				nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem]	+ aCols[xx][nPXvlSt]
			EndIf			
		Next xx
	
		aValores[1] := Round(NoRound(nVlrMerc,4),2)
		aValores[6] := Round(NoRound(nVlrPedi,4),2)

	
		//If (oGettlv <> Nil)
		//oGettlv:oBrowse:Refresh()Comentado devido ao problema do refresh na tela do call-center Feito. Willian e Rodrigo 23/06/08
		GetDRefresh()
		//Tk273Refresh(aValores)	
		//Endif
		//SysRefresh()
	EndIf

Return 