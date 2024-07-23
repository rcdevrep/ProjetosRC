#Include "rwmake.ch"



User Function AGX534()   
	//Busco tabela de preco conforme condicao de pagamento
	
	cTabela := ""
	
	Do Case
		Case M->C5_CONDPAG == "001"
			cTabela := "001"
		Case M->C5_CONDPAG == "007"
			cTabela := "002"
		Case M->C5_CONDPAG == "003"
			cTabela := "003"
		Case M->C5_CONDPAG == "017"
			cTabela := "004"
		Otherwise
			cTabela := "001" 
	EndCase
		
	
	
/*	dbSelectArea("DA0")
	dBSetOrder(1)
	dbGoTop()
	While !eof() 
		If DA0->DA0_CONDPG == M->C5_CONDPAG
			cTabela := DA0->DA0_CODTAB
		EndIf
	   
		DA0->(dbSkip())
	
	EndDo             */
	
Return(cTabela)