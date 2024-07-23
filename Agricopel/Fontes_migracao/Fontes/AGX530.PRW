#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"


User Function AGX530()                   
	
	nCof := 0
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
 
	
 //Calculo Cofins
 Do Case 
 	Case SB1->B1_AGMRKP='FILTRO_W_ICMS_ST'
 		nCof := 0 
 	Case SB1->B1_AGMRKP='P_FILTRO_W'
 		nCof := 0
 	Case SB1->B1_AGMRKP='CONV_CERVEJAS'
 		nCof := 0
 	Otherwise 
		nCof := nCusEnt * 0.076
EndCase                                  


Return(nCof)