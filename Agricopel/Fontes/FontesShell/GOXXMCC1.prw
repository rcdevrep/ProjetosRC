#INCLUDE "PROTHEUS.CH"

User Function GOXXMCC1()
    
    Local aParams := PARAMIXB
    Local nLine
    Local xRet
    Local lSomaImp := GetNewPar("MV_ZVLPDIM", .F.)
    Local nAuxPrc
    
    If !Empty(aParams) .And. Len(aParams) > 0 // Retornar conteúdo
        
        nLine := aParams[1]
        
        If lSomaImp
            
            nAuxPrc := oGetD:aCols[nLine, _nPosVlTot] + ;
                oGetD:aCols[nLine, _nPosVlIpi]
                
            If !ExistBlock("GOXSOMST") .Or. ExecBlock("GOXSOMST", .F., .F., {nLine})
                
                nAuxPrc += oGetD:aCols[nLine, _nPosVlISt] + ;
                oGetD:aCols[nLine, _nPosVlStA]
                
            EndIf
                
            nAuxPrc := Round(nAuxPrc / oGetD:aCols[nLine, _nPosQtdNo], TamSx3("C7_PRECO")[2])
            
        Else
            
            nAuxPrc := oGetD:aCols[nLine, _nPosVlUnt]
            
        EndIf
        
        xRet := Round(nAuxPrc, 2)
        
    Else
        
        xRet := {"Val.Unit.Imp.", "RIGHT", 30}
        
    EndIf
    
Return xRet
