#INCLUDE "RWMAKE.CH"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR134    ºAutor  ³Deco                º Data ³  29/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para historico lactoo padrao 520-01 520-05       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR134()

PRIVATE cHistor := "VAL REC.NF."+SE1->E1_NUM+ "-" + ALLTRIM(SA1->A1_NREDUZ)
Private CNa

//* Qdo baixa normal      
                      

If alltrim(SE5->E5_BANCO) <> "100"
	If alltrim(SE1->E1_TIPO) <> 'CH' .and. Empty(SE1->E1_TIPOLIQ)
	   cHistor := "VAL REC.NF. "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)
	EndIf 
	
	//	* Qdo baixa por liquidacao correspondente a baixa com cheques 
	
	If alltrim(SE1->E1_TIPO) <> 'CH' .and. Alltrim(SE1->E1_TIPOLIQ) = 'CH'
	   cHistor := "BAIXA NF. "+SE1->E1_NUM+" LIQ. "+SE1->E1_NUMLIQ+" "+ALLTRIM(SA1->A1_NREDUZ)
	EndIf
	
	
	//* Qdo baixa cheque proveniente da liquidacao de um titulo com cheque
	
	If alltrim(SE1->E1_TIPO) == 'CH' 
	   cHistor := "VAL REC.CHQ. "+SE1->E1_NUM+" LIQ. "+SE1->E1_NUMLIQ+" "+ALLTRIM(SA1->A1_NREDUZ)
	EndIf
	
	
	//* Qdo baixa cheque proveniente cheque dev. enviado cliente   
	
	If alltrim(SE1->E1_NATUREZ) == '101006' 
	   cHistor := "VAL REC.CHQ. "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)  // Devolucao inclusa fernando, historico cfe Alexandre 17/08/2005
	EndIf                   
Else
	cHistor := "VAL BAIXA PERDA REF."+SE1->E1_NUM+ "-" + ALLTRIM(SA1->A1_NREDUZ)
EndIf   

If alltrim(SE1->E1_TIPO) == 'RA' 
   cHistor := "VAL DEV. RA "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)
EndIf
		
If alltrim(SE1->E1_TIPO) == 'NCC' 
   cHistor := "VAL DEV. NCC "+SE1->E1_NUM+" "+ALLTRIM(SA1->A1_NREDUZ)
EndIf

Return(cHistor)