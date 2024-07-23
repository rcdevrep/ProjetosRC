
#INCLUDE "PROTHEUS.CH"




User Function AGX602()                  
PRIVATE cCusMed := GetMv("MV_CUSMED")
PRIVATE dInicio := GetMv("MV_ULMES")+1
PRIVATE lLancToOn                             
PRIVATE lCusRep    := SuperGetMv("MV_CUSREP",.F.,.F.)
aSaldoIni := {}   	

aSaldoIni := CalcEst("981","02",dInicio,,,lCusRep)


Alert("fim") 

Return()
