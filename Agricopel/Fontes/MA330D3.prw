#Include 'Protheus.ch'
#Include "TOTVS.CH"

User Function MA330D3()  

	//Se for um Produto do DBGint não recalcula, captura do campo específico
	If FieldPos("D3_XCMDBG") > 0
		If SD3->D3_XCMDBG <>  0 //SD3->D3_LOCAL == 'DB'      
			CONOUT('MA330D3 ANTES: '+ SD3->D3_FILIAL + SD3->D3_COD+'->'+STR(SD3->D3_CUSTO1))
			RecLock('SD3',.F.)	
				SD3->D3_CUSTO1 := SD3->D3_XCMDBG   
			SD3->(MsUnlock()) 
			CONOUT('MA330D3 DEPOIS: '+SD3->D3_FILIAL + SD3->D3_COD+'->'+STR(SD3->D3_CUSTO1))
		Endif
	Endif
	
Return              
