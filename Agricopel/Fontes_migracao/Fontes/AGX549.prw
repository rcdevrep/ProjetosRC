#include "rwmake.ch"                                                                       	
#include "topconn.ch"
User Function AGX549()


dbSelectArea("SB1")
dbSetORder(1)
dbGoTop()           
dbSeek(xFilial("SB1") )
While !Eof() .and. xFilial("SB1") = SB1->B1_FILIAL  
	cCodEan  := "" 
	cDig     := ""
	cDigCalc := "" 
	If alltrim(SB1->B1_CODBAR) <> "" .AND. SB1->B1_LOCPAD == "02" 	
		Do Case 
			Case Len(AllTrim(SB1->B1_CODBAR)) == 8   
				cCodEan  := substr(AllTrim(SB1->B1_CODBAR),1,7)
				cDig     := substr(AllTrim(SB1->B1_CODBAR),8,1) 
			    cDigCalc := eandigito(alltrim(cCodEan))      
			    If cDigCalc <> cDig	
			    	CONOUT("DIGITO INCORRETO - VALOR: " + cDig + "  CALCULADO:" + cDigCalc + "    PRODUTO:"  + SB1->B1_COD)    
			    	Reclock("SB1",.F.)
			    		SB1->B1_CODBAR := alltrim(cCodEan) + alltrim(cDigCalc)
			    	MSunlock()    	
			    EndIf
			Case Len(AllTrim(SB1->B1_CODBAR)) == 12   
				cCodEan  := substr(AllTrim(SB1->B1_CODBAR),1,11)
				cDig     := substr(AllTrim(SB1->B1_CODBAR),12,1)
			    cDigCalc := eandigito(alltrim(cCodEan))      
			    If cDigCalc <> cDig	
			    	CONOUT("DIGITO INCORRETO - VALOR: " + cDig + "  CALCULADO:" + cDigCalc + "    PRODUTO:"  + SB1->B1_COD)   			    	
			    	Reclock("SB1",.F.)
			    		SB1->B1_CODBAR := alltrim(cCodEan) + alltrim(cDigCalc)
			    	MSunlock()
			    EndIf                                         
			Case Len(AllTrim(SB1->B1_CODBAR)) == 13   
				cCodEan  := substr(AllTrim(SB1->B1_CODBAR),1,12)
				cDig     := substr(AllTrim(SB1->B1_CODBAR),13,1)
			    cDigCalc := eandigito(alltrim(cCodEan))      
			    If cDigCalc <> cDig	
			    	CONOUT("DIGITO INCORRETO - VALOR: " + cDig + "  CALCULADO:" + cDigCalc + "    PRODUTO:"  + SB1->B1_COD)   
			    	Reclock("SB1",.F.)
			    		SB1->B1_CODBAR := alltrim(cCodEan) + alltrim(cDigCalc)
			    	MSunlock()
			    EndIf                                         
			Case Len(AllTrim(SB1->B1_CODBAR)) == 14   
				cCodEan  := substr(AllTrim(SB1->B1_CODBAR),1,13)
				cDig     := substr(AllTrim(SB1->B1_CODBAR),14,1)
			    cDigCalc := eandigito(alltrim(cCodEan))      
			    If cDigCalc <> cDig	
			    	CONOUT("DIGITO INCORRETO - VALOR: " + cDig + "  CALCULADO:" + cDigCalc + "    PRODUTO:"  + SB1->B1_COD)  			    	
			    	Reclock("SB1",.F.)
			    		SB1->B1_CODBAR := alltrim(cCodEan) + alltrim(cDigCalc)
			    	MSunlock()
			    EndIf                                        
		Otherwise
				CONOUT("CODIGO DE BARRAS INVALIDO : PRODUTO : " + SB1->B1_COD + "   CODBAR: " + SB1->B1_CODBAR)				
			   	//Reclock("SB1",.F.)
			   	//	SB1->B1_CODBAR := "" 
			   	//MSunlock()
		EndCase
		
	EndIf 
	
	dbSelectArea("SB1")
	dbskip()
	
EndDo   


  alert("FIM")


Return()


//trim(m->b1_codbar)+eandigito(trim(m->b1_codbar))                                                    