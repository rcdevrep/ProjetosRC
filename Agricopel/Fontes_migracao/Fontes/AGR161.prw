#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR161    ºAutor  ³Microsiga           º Data ³  02/15/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa utilizado para Calcular o Desconto Comercial.     º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR161()

	nPProd		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
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
	
	nPCodPai    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_CODPAI"})  
	
	
	

	nRet := aCols[n][nPVrUnit]
	
	if 	(Alltrim(ReadVar()) == "M->UB_QUANT"  .OR. 	(Alltrim(ReadVar()) == "M->UB_PRODUTO"))  .AND. ALLTRIM(aCols[n][nPCodPai]) == "" 
	

	If (Alltrim(ReadVar()) == "M->UB_PRODUTO")
	
		If SB1->B1_TIPO == "CO"
			nRet := aCols[n][nPVrUnit]
			Return nRet
		EndIf
	
   //		aCols[n][nPPdescom] 	:= M->UA_DESCCOM
   //		aCols[n][nPDesc] 		:= aCols[n][nPDesc] //(aCols[n][nPPDesTab]+aCols[n][nPPDescom]) - Round(((aCols[n][nPPDesTab] * aCols[n][nPPDescom]) / 100),4)	
   //COMENTADO RODRIGO.
		aCols[n][nPVrUnit] 	:= (aCols[n][nPPrcTab] 	- (aCols[n][nPPrcTab] 	* aCols[n][nPDesc] / 100))
		aCols[n][nPVlrItem] 	:= aCols[n][nPVrUnit] * aCols[n][nPQuant]

		aCols[n][nPVlrDesc]  := Round((aCols[n][nPPrcTab] * aCols[n][nPDesc]) /100,4) * aCols[n][nPQuant]  
				
		
   //		aCols[n][nPVdescom] 	:= Round((aCols[n][nPPrcTab] * aCols[n][nPPdescom])/100,4) * aCols[n][nPQuant]		
		nRet 						:= aCols[n][nPVrUnit]
		

	ElseIf (Alltrim(ReadVar()) == "M->UB_QUANT")  

		If SB1->B1_TIPO == "CO"
			nRet := aCols[n][nPVdescom]                                                 	
			Return nRet
		EndIf 
		
		aCols[n][nPVlrDesc]  := Round((aCols[n][nPPrcTab] * aCols[n][nPDesc]) /100,4) * aCols[n][nPQuant]
//		aCols[n][nPVdescom] 	:= Round((aCols[n][nPPrcTab] * aCols[n][nPPdescom])/100,4) * aCols[n][nPQuant]
		nRet						:= aCols[n][nPVdescom]
	EndIf

	nVlrMerc := 0
	nVlrPedi	:= 0
	nVlrFat := 0 
	For xx := 1 to Len(aCols)
		If !( aCols[xx][Len(aCols[xx])] )//Deletado												
			nVlrMerc := nVlrMerc + aCols[xx][nPVlrItem]
			nVlrPedi := nVlrPedi + aCols[xx][nPVlrItem]		
			nVlrFat  := nVlrFat  + aCols[xx][nPVlrItem]		
		EndIf	
	Next xx

	aValores[1] := Round(NoRound(nVlrMerc,4),2)
	aValores[6] := Round(NoRound(nVlrPedi,4),2)
 	aValores[8] := Round(NoRound(nVlrFat,4),2)
	

	aBkp		:= {}
	aBkp 		:= aClone(aCols)	  // Backup dados do Browse Principal.	
 	TKCLIENTE()  
 	
 	ENDIF
	//aCols := aClone(aBkp)

	//If (oGettlv <> Nil)
  //AQUI	//oGettlv:oBrowse:Refresh()
	//Tk273Refresh(aValores)	
	//Endif
	//SysRefresh()	
	
Return nRet