#INCLUDE "PROTHEUS.CH"

User Function GOXVLSTA()
    
    Local cST := PARAMIXB[1]
    
    If cST == "41" .And. (cEmpAnt $ "11,15" .Or. (cEmpAnt == "01" .And. cFilAnt == "03") .Or. ;
        (cEmpAnt == "01" .And. cFilAnt == "16"))
        
        Return .T.
        
    EndIf
    
Return .F.
