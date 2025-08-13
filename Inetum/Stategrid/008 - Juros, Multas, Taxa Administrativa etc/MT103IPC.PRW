

User Function MT103IPC()


Local nPosCo 		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_XCO"})
Local nPosCred  	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_XCREDIT"})
Local nPosDebi  	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_XDEBITO"})
Local nPosApro  	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_XAPROV"})
Local nPosDescP 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_XDESCR"})
Local nPosValCmp 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_XVALCMP"})

Local nItem 	:= ParamIXB[1]

Public cFormPagto	:= "" 

If nPosApro > 0 .And. !Empty(SC7->C7_XAPROV) 
	aCols[nItem][nPosApro] := SC7->C7_XAPROV
EndIf   

If nPosCo > 0 .And. !Empty(SC7->C7_XCO) 
	aCols[nItem][nPosCo] := SC7->C7_XCO
EndIf        
	
If nPosCred > 0 .And. !Empty(SC7->C7_XCREDIT)
	aCols[nItem][nPosCred] := SC7->C7_XCREDIT
EndIf
	
If nPosDebi > 0 .And. !Empty(SC7->C7_XDEBITO)
	aCols[nItem][nPosDebi] := SC7->C7_XDEBITO
EndIf

If nPosDescP > 0 
		aCols[nItem][nPosDescP] := SC7->C7_DESCRI
EndIf

If nPosValCmp > 0 
		aCols[nItem][nPosValCmp] := SC7->C7_XVALCMP
EndIf

_cCamNovo1      := SC7->C7_XMULTA
_cCamNovo2      := SC7->C7_XJUROS
If M->F1_XMULTA == Nil
    M->F1_XMULTA := _cCamNovo1
    M->F1_XJUROS := _cCamNovo2
EndIf

cFormPagto := SC7->C7_XFORPAG

Return 
