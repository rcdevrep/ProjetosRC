#INCLUDE "PROTHEUS.CH"

User Function GOXSOMST()
    
    Local nX := PARAMIXB[1]
    
    If Right(AllTrim(oGetD:aCols[nX, _nPosStTri]), 2) $ "10;30" .Or. ;
        AllTrim(oGetD:aCols[nX, _nPosCSOSN]) $ "201"
        
        Return .T.
        
    EndIf
    
Return .F.
