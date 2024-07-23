#Include "rwmake.ch"

// ROTINA JA VERIFICADA VIA XAGLOGRT

User Function AGX534()   

	//Busco tabela de preco conforme condicao de pagamento
	Local cTabela := ""
	
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
	
Return(cTabela)