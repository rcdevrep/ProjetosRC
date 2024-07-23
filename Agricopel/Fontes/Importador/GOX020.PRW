#INCLUDE "PROTHEUS.CH"

//User Function GOX020(aParams)
User Function GOX020(cEmp, cFil)
    
    Local aFil
    Local nI
    
    //Default aParams := {"01", "01"}
    Default cEmp := "01"
    Default cFil := "01"
    
    RpcSetType(3)
	//If !RpcSetEnv(aParams[1], aParams[2])
    conout(">>>>>>>>>>>>>>>>> Emp/Fil: (" + cEmp + "_" + cFil + ")")
    If !RpcSetEnv(cEmp, cFil)

        Return

    EndIf
    
    aFil := FWAllFilial(, , SM0->M0_CODIGO, .F.)
    
    For nI := 1 To Len(aFil)
        
        conout(">>>>>>>>>>>>>>>>> Filial: (" + aFil[nI] + ")")
        
        dbSelectArea("SM0")
		SM0->( dbSetOrder(1) )
		SM0->( dbSeek(cEmpAnt + aFil[nI]) )
        
        cFilAnt := aFil[nI]
        
        ProcXML()
        
    Next nI
    
    RpcClearEnv()
    
Return

Static Function ProcXML()
    
    Local cQuery := ""
    Local cAli
    
    Local cDir
    Local cGera
    
    Private _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
	Private _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
    
    cDir := AllTrim(GetNewPar("MV_ZDIRBXM", "c:\temp\"))
    
    conout(">>>>>>>>>>>>>>>>> Verificando Diretório: (" + cDir + ")")
    
    If !ExistDir(cDir)
        
        conout(">>>>>>>>>>>>>>>>> Não Encontrado")
        
        Return
        
    EndIf
    
    cGera := cDir + Left(AllTrim(SM0->M0_CGC), 8)
    
    conout(">>>>>>>>>>>>>>>>> Diretório com CGC " + cGera)
    
    If !ExistDir(cGera)
        
        conout(">>>>>>>>>>>>>>>>> Não Existe, criando....")
        
        MakeDir(cGera)
        
    EndIf
    
    cGera += "\" + StrZero(Month(Date()), 2) + "_" + cValToChar(Year(Date()))
    
    conout(">>>>>>>>>>>>>>>>> Diretório Mês_Ano " + cGera)
    
    If !ExistDir(cGera)
        
        conout(">>>>>>>>>>>>>>>>> Não Existe.... Criando")
        
        MakeDir(cGera)
        
    EndIf
    
    cQuery := " SELECT R_E_C_N_O_ RECNO "
    cQuery += " FROM " + RetSqlName(_cTab1) + " "
    cQuery += " WHERE D_E_L_E_T_ = ' ' " 
    cQuery += " AND (" + _cCmp1 + "_TIPO = '1' OR " + _cCmp1 + "_TIPO = '2' OR " + _cCmp1 + "_TIPO = '6') "
    cQuery += " AND " + _cCmp1 + "_DTEMIS = '" + DToS(Date()) + "' "
    cQuery += " AND " + _cCmp1 + "_FILIAL = '" + cFilAnt + "' "
    
    cAli := MpSysOpenQuery(cQuery)
    
    If !(cAli)->( Eof() ) 
        
        While !(cAli)->( Eof() ) 
            
            (_cTab1)->( dbGoTo((cAli)->RECNO) )
            
            If !File(cGera + "\" + (_cTab1)->&(_cCmp1 + "_CHAVE") + ".xml")
            
                MemoWrite(cGera + "\" + (_cTab1)->&(_cCmp1 + "_CHAVE") + ".xml", (_cTab1)->&(_cCmp1 + "_XML"))
                
            EndIf
            
            (cAli)->( dbSkip() )
            
        EndDo
        
    EndIf
    
    (cAli)->( dbCloseArea() )
    
    conout(">>>>>>>>>>>>>>>>> FINALIZADO")
    
Return
