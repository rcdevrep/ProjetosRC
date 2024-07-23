#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"


User Function AGX529()                   
	
	nPis := 0
	nCusEnt := 0
	
 
 //Custo de entrada do produto	
 Do Case
 	Case SB1->B1_CUTFA >0 
	 	nCusEnt := SB1->B1_CUTFA 
	Case SB1->B1_UPRC >0 
		nCusEnt := SB1->B1_UPRC
	OtherWise 
		nCusEnt := 0
 EndCase
 
	
 //Calculo Pis
 Do Case 
 	Case SB1->B1_AGMRKP='FILTRO_W_ICMS_ST'
 		nPis := 0 
 	Case SB1->B1_AGMRKP='P_FILTRO_W'
 		nPis := 0
 	Case SB1->B1_AGMRKP='CONV_CERVEJAS'
 		nPis := 0
 	Otherwise 
		nPis := nCusEnt * 0.0165
EndCase                                  

Return(nPis)