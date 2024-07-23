#INCLUDE "PROTHEUS.CH"

User Function MT103IP2()
	
	Local nItem := PARAMIXB[1]
	
	If IsInCallStack("ImpXMLNFe") .And. oGetD:aCols[nItem][_nPosDescX] > 0
		
		MaFisAlt("IT_DESCONTO", oGetD:aCols[nItem][_nPosDescX], nItem)
		
	EndIf
	
Return
