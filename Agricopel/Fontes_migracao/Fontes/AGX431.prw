#INCLUDE "RWMAKE.CH"

User function AGX431()

	nQtdeRegistros := Len(aCols)  	
	nPosCampoDtEntrega := aScan(aHeader,{|x| alltrim(x[2]) == "UB_DTENTRE"})
    
	if nQtdeRegistros > 0   
			
		for nCountFor := 1 to nQtdeRegistros
		    aCols [nCountFor, nPosCampoDtEntrega] := M->UA_DTENTRE
		next             
	endif        
	
	GetDRefresh()	
return(M->UA_DTENTRE)