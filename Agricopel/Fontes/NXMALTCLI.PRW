#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

User Function NXMALTCLI()

Local aCampo:={}

aCampo:= FWSX3Util():GetFieldStruct( "A1_CATEGOR" ) 

If Len(aCampo) > 0
	If (Upper(Funname()) == "MATA030" .AND. INCLUI) .OR. (Upper(Funname()) == "MATA030" .AND. ALTERA)

		If M->A1_ATIVIDA == "47318"
			Reclock("SA1", .F.)
				SA1->A1_CATEGOR := "PRV"
			SA1->(MsUnlock())
		
		ElseIf M->A1_PESSOA = "J" .AND. ( Upper(Alltrim(M->A1_INSCR)) != "ISENTO" .AND. Upper(Alltrim(M->A1_INSCR)) != "" )  
			Reclock("SA1", .F.)
				SA1->A1_CATEGOR := "CFC"
			SA1->(MsUnlock())	
		
		ElseIf M->A1_PESSOA = "J" .AND. ( Upper(Alltrim(M->A1_INSCR)) == "ISENTO" .OR. Upper(Alltrim(M->A1_INSCR)) == "" )  
			Reclock("SA1", .F.)
				SA1->A1_CATEGOR := "CNF"
			SA1->(MsUnlock())		

		Else
			Reclock("SA1", .F.)
				SA1->A1_CATEGOR := "CNF"
			SA1->(MsUnlock())
		
		EndIf
	EndIf
EndIf	
	
Return
