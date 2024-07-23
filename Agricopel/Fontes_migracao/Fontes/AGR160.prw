#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR160    ºAutor  ³Microsiga           º Data ³  02/15/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa utilizado no campo UA_CONDPG, na validacao de     º±±
±±º          ³ usuario. Trazer o Desconto comercial, apartir da Cond.Pagto.±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR160()            

	nUA_DESCCOM := 0
	nUA_ACRECOM := 0         
	nUA_X_ACRES := 0
	DbSelectArea("SE4")
	DbSetOrder(1)
	//DbGotop()
	If DbSeek(xFilial("SE4")+M->UA_CONDPG)
		If !Empty(SE4->E4_DESCCOM)
			nUA_DESCCOM := SE4->E4_DESCCOM		
		Else
			nUA_DESCCOM := 0
		EndIf 
		
		If cEmpAnt == "01" .OR. cEmpAnt == "16"
			If !Empty(SE4->E4_X_ACRES) 
				nUA_X_ACRES := SE4->E4_X_ACRES
			Else
			  	nUA_X_ACRES := 0
			EndIf		
		EndIf
	EndIf
	
	If cEmpAnt == "01" .OR. cEmpAnt == "16"
		If ((SM0->M0_CODIGO == "01" .And. (SM0->M0_CODFIL == "03" .or. SM0->M0_CODFIL == "15")) .OR.;
			(SM0->M0_CODIGO == "01" .And. SM0->M0_CODFIL == "02" .And. M->UA_TABELA == "777"))   //Consistencia para nao repassar desconto para empresa Agricopel Base.
			M->UA_DESCCOM := 0	
			M->UA_X_ACRES := 0
		Else
			M->UA_DESCCOM := nUA_DESCCOM
			M->UA_X_ACRES := nUA_X_ACRES
		EndIf	      
	EndIf		
	//alert(nUA_ACRECOM) 

Return .T.