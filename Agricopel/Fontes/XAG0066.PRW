#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ XAG0066  ºAutor  ³ Thiago Padilha Bottaro  º Data ³  26/03/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho no Pedido de Venda no campo C5_LOJACLI                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso       ³ Rotina baseada na AGR211, as validacoes foram removidas para     º±±
±±ºUso       ³ evitar mensagens em pedidos colocados por fora do Protheus       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/

User Function XAG0066()

LOCAL aSeg     := GetArea()
LOCAL aSegSA1  := SA1->(GetArea())
LOCAL lRet     := .T.


dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)
	
    // Mesma regra que existe na rotina AGR211
    If (cEmpAnt == "01" .and. (cFilAnt == "02" .or. cFilAnt == "03" .or. cFilAnt == "11" .or. cFilAnt == "15" .or. cFilAnt == "16" .or. cFilAnt == "17"  .or. cFilAnt == "18" .or. cFilAnt == "05")) .or. cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15"
       M->C5_VEND6   := SA1->A1_VEND6
       M->C5_VEND7   := SA1->A1_VEND7
       M->C5_VEND8   := SA1->A1_VEND8
    EndIf
    
	If cEmpAnt == "01"
		M->C5_VEND    := SA1->A1_VEND
    	M->C5_vend3   := SA1->A1_vend3

		if (cFilAnt == "03" .or. cFilAnt == "11" .or. cFilAnt == "15" .or. cFilAnt == "17" .or. cFilAnt == "18" .or. cFilAnt == "05" ) 
		    M->C5_vend2   := SA1->A1_VEND5
	    else
	    	M->C5_vend2   := SA1->A1_vend2 
		endif
	Else
       If (cEmpAnt == "11" .or. cEmpAnt == "12" .or. cEmpAnt == "15")
           M->C5_vend2   := SA1->A1_VEND5
		   M->C5_VEND    := SA1->A1_VEND
    	   M->C5_vend3   := SA1->A1_vend3           
       Else
           M->C5_vend2   := SA1->A1_VEND2
       EndIf
	Endif
EndIf

//Retorno area original do arquivo
//////////////////////////////////
RestArea(aSegSA1)
RestArea(aSeg)

Return lRet
