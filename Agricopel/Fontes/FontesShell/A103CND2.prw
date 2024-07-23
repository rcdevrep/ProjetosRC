#INCLUDE "PROTHEUS.CH"

User Function A103CND2()
	
	Local nI
	Local aRet := {}
	
	Local aFin := PARAMIXB
	
	Local nTotal := 0
	
	If IsInCallStack("U_GOX008") .Or. IsInCallStack("U_SENX008")
		
		If IsInCallStack("GeraSConhe") .Or. IsInCallStack("GeraConhec")
			
			If l103Auto .And. !Empty(dCtVenc)
				
				For nI := 1 To Len(aFin)
					
					nTotal += aFin[nI][2]
					
				Next nI
				
				AAdd(aRet, {dCtVenc, nTotal})
				
				Return aRet
				
			EndIf
			
		Else
		
			If Type("aXmlDup") == "A" .And. !Empty(aXmlDup) .And. l103Auto
				
				For nI := 1 To Len(aXmlDup)
					
					// {Data, Valor}
					AAdd(aRet, {DXToD(aXmlDup[nI]:_dVenc:Text), Val(aXmlDup[nI]:_vDup:Text)})
					
				Next nI
				
				If !IsBlind() .And. MsgYesNo("Foram encontradas informções de vencimentos das parcelas no XML, deseja utilizar conforme o XML?")
					
					Return aRet

				EndIf
					
			EndIf
			
		EndIf
		
	EndIf
	
Return Nil

Static Function DXToD(cData)
	
Return SToD(StrTran(cData, "-", ""))
