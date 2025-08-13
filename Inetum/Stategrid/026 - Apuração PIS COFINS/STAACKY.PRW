#include "Protheus.ch"                                                                    
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.ch"                                                                                                                             
#INCLUDE "TBICONN.CH"

User Function STAACKY()
Local lRet := .T.
Local nValPis := 0
Local nValCof := 0
Local nValPisTot := 0
Local nValCofTot := 0
Local nValPisCalc := 0
Local nValCofCalc := 0
static cCodNatRet := "02"
//Não Cumulativo
LOCAL cEmpNcumulat 	:= GETMV("MV_XEMNCUM")  
//Cumulativo
LOCAL cEmpCumulat 	:= GETMV("MV_XEMCUM")


cQuery := "SELECT CKY_FILIAL, CKY_PER, R_E_C_N_O_  "
cQuery += "FROM "+RetSqlName("CKY")+" "
cQuery += "WHERE D_E_L_E_T_  = ' ' " 

If Select("TMP") > 0 
	dbSelectArea("TMP")
	TMP->(dbCloseArea())
EndIf

TCQUERY cQuery Alias TMP NEW


DbSelectArea("SFV")
SFV->(dbSetOrder(1))


DbSelectArea("SFW")
SFW->(dbSetOrder(1))


While TMP->(!Eof()) 

    DbSelectArea("CKY")
    CKY->(DbGotop())
    CKY->(DbGoto(TMP->R_E_C_N_O_))

    If CKY->CKY_FILIAL $ cEmpNcumulat // VERIFICA SE A FILIAL ESTIVER NO PARAMETRO DAS EMPRESAS NÃO CUMULATIVAS

        RecLock("CKY", .F.)		
            CKY->CKY_INDREC := "1" // 1 = Não cumulativo
            CKY->CKY_INDRET := cCodNatRet		
        CKY->(MsUnLock()) //Confirma e finaliza a operação

    elseif CKY->CKY_FILIAL $ cEmpcumulat // VERIFICA SE A FILIAL ESTIVER NO PARAMETRO DAS EMPRESAS CUMULATIVAS

        RecLock("CKY", .F.)		
            CKY->CKY_INDREC := "2" // 2 = Cumulatico
            CKY->CKY_INDRET := cCodNatRet	
        CKY->(MsUnLock()) //Confirma e finaliza a operação

        nValPis := CKY->CKY_PISRET
        nValCof := CKY->CKY_COFRET

        aArea := GetArea()

            DbSelectArea("CKR")
            CKR->(dbSetOrder(1))
            IF CKR->(dbSeek(TMP->CKY_FILIAL + TMP->CKY_PER + "2"+ "1")) // param[3] (1 = consolidado / 2 = Detalhado)  param[4] (1 = PIS / 2 = Cofins)
                RecLock("CKR", .F.)		
                    CKR->CKR_RTATUC := nValPis + nValPisTot
                    nValPisTot := CKR->CKR_RTATUC
                    CKR->CKR_CREC := CKR->CKR_CONC - nValPisTot
                    nValPisCalc := CKR->CKR_CREC
                CKR->(MsUnLock()) //Confirma e finaliza a operação
            Endif
            IF CKR->(dbSeek(TMP->CKY_FILIAL + TMP->CKY_PER + "2"+ "2")) // param[3] (1 = consolidado / 2 = Detalhado)  param[4] (1 = PIS / 2 = Cofins)
                RecLock("CKR", .F.)		
                    CKR->CKR_RTATUC := nValCof + nValCofTot
                    nValCofTot := CKR->CKR_RTATUC
                    CKR->CKR_CREC := CKR->CKR_CONC - nValCofTot
                    nValCofCalc := CKR->CKR_CREC
                CKR->(MsUnLock()) //Confirma e finaliza a operação
            Endif

            DbSelectArea("CL3")
            CL3->(dbSetOrder(1))
            IF CL3->(dbSeek(TMP->CKY_FILIAL + TMP->CKY_PER + "2")) // PIS
                RecLock("CL3", .F.)
                    CL3->CL3_VALOR := nValPisCalc
                CL3->(MsUnLock())
            Endif
            IF CL3->(dbSeek(TMP->CKY_FILIAL + TMP->CKY_PER + "4")) // COFINS
                RecLock("CL3", .F.)
                    CL3->CL3_VALOR := nValCofCalc
                CL3->(MsUnLock())
            Endif

            SFV->(DbGoTop())

            While SFV->(!Eof())
                If SFV->FV_NATRET <> cCodNatRet
                    IF SFV->FV_PER == SubStr(TMP->CKY_PER,5,2) + SubStr(TMP->CKY_PER,1,4)
                        RecLock("SFV", .F.)
                            SFV->FV_NATRET := cCodNatRet
                            SFV->FV_MESANO := ""
                        SFV->(MsUnLock())
                    Endif
                EndIf
            SFV->(DbSkip())
            EndDo
            SFV->(DbCloseArea())

            SFW->(DbGoTop())

            While SFW->(!Eof())
                 If SFW->FW_NATRET <> cCodNatRet
                    IF SFW->FW_PER == SubStr(TMP->CKY_PER,5,2) + SubStr(TMP->CKY_PER,1,4)   
                        RecLock("SFW", .F.)
                            SFW->FW_NATRET := cCodNatRet
                            SFW->FW_MESANO := ""
                        SFW->(MsUnLock())
                    Endif
                EndIf
            SFW->(DbSkip())
            EndDo
            SFW->(DbCloseArea())

            


        RestArea(aArea)

    Else
        
    Endif

   
    TMP->(DbSkip())
			
EndDo
TMP->(dbCloseArea())




cQuery := "SELECT CKY_FILIAL, CKY_PER, SUM(CKY_PISRET) PIS, SUM(CKY_COFRET) COF "
cQuery += "FROM "+RetSqlName("CKY")+" "
cQuery += "WHERE D_E_L_E_T_  = ' ' " 
cQuery += "AND CKY_FILIAL = '"+xFilial("CKY")+"' "
cQuery += "GROUP BY CKY_FILIAL, CKY_PER " 

If Select("TMP") > 0 
	dbSelectArea("TMP")
	TMP->(dbCloseArea())
EndIf

TCQUERY cQuery Alias TMP NEW


While TMP->(!Eof()) 
    //Ajuste de tabelas SFV e SFW (PIS e COFINS)
    fPisCof(TMP->CKY_PER, TMP->PIS, TMP->COF)
    TMP->(DbSkip())
			
EndDo
TMP->(dbCloseArea())

MsgBox("Os registros para a geração do blocos F600 / M200 / M205 / M600 / M605 / 1300 / 1700 foram ajustados.", "Informativo", "Info")

Return lRet




Static Function fPisCof(cPeriodo, nTotPIS, nTotCOF)
Local cQuery
Local nRecPis := 0
Local nRecCof := 0


    //AJUSTE DO PIS ------------------------------------------------------------------------------------------------------------------------------
    cQuery := "SELECT TOP 1  R_E_C_N_O_   FROM "+RETSQLNAME("SFV")+"  WHERE FV_PER = '"+SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4) +"' AND D_E_L_E_T_  = ' ' "


    If Select("TMPX") > 0 
        dbSelectArea("TMPX")
        TMPX->(dbCloseArea())
    EndIf

    TCQUERY cQuery Alias TMPX NEW
    
    While TMPX->(!Eof()) 
        nRecPis := TMPX->R_E_C_N_O_    
    TMPX->(DbSkip())
	EndDo
    TMPX->(dbCloseArea())

    If nRecPis > 0 .AND. nTotPIS > 0
        DbSelectArea("SFV")
        SFV->(DbGoTo(nRecPis))

        Reclock("SFV", .F.)
            SFV->FV_VLDISP  := 0 
            SFV->FV_MESANO  := SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4)
            SFV->FV_CONSOL  := '2'
            SFV->FV_TPREG   := '1'
            SFV->FV_APURPER := nTotPIS
            SFV->FV_COMP    := 0
            SFV->FV_NATRET  := '02'
            SFV->FV_RESRET  := '2'
            SFV->FV_TOTRET  := nTotPIS
        SFV->(MsUnlock())
    EndIf

    If nRecPis == 0 .AND. nTotPIS > 0
        DbSelectArea("SFV")
        Reclock("SFV", .T.)
            SFV->FV_VLDISP  := 0 
            SFV->FV_PER     := SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4)
            SFV->FV_MESANO  := SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4)
            SFV->FV_CONSOL  := '2'
            SFV->FV_TPREG   := '1'
            SFV->FV_APURPER := nTotPIS
            SFV->FV_COMP    := 0
            SFV->FV_NATRET  := '02'
            SFV->FV_RESRET  := '2'
            SFV->FV_TOTRET  := nTotPIS
        SFV->(MsUnlock())      
    EndIf



    //AJUSTE DO COFINS ------------------------------------------------------------------------------------------------------------------------------
    
    cQuery := "SELECT TOP 1  R_E_C_N_O_   FROM "+RETSQLNAME("SFW")+"  WHERE FW_PER = '"+SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4) +"' AND D_E_L_E_T_  = ' ' "

    If Select("TMPW") > 0 
        dbSelectArea("TMPW")
        TMPW->(dbCloseArea())
    EndIf

    TCQUERY cQuery Alias TMPW NEW
    
    While TMPW->(!Eof()) 
        nRecCof := TMPW->R_E_C_N_O_    
    TMPW->(DbSkip())
	EndDo
    TMPW->(dbCloseArea())

    If nRecCof > 0 .AND. nTotCOF > 0
        DbSelectArea("SFW")
        SFW->(DbGoTo(nRecCof))

        Reclock("SFW", .F.)
            SFW->FW_MESANO := SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4)
            SFW->FW_VLDISP := 0
            SFW->FW_RESRET := '2'
            SFW->FW_CONSOL := '2'
            SFW->FW_APURPER:= nTotCOF
            SFW->FW_NATRET := '02'
            SFW->FW_TOTRET := nTotCOF
        SFW->(MsUnlock())
    EndIf

    If nRecCof == 0 .AND. nTotCOF > 0
        DbSelectArea("SFW")
        Reclock("SFW", .T.)
            SFW->FW_PER    := SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4)
            SFW->FW_MESANO := SubStr(cPeriodo,5,2) + SubStr(cPeriodo,1,4)
            SFW->FW_VLDISP := 0
            SFW->FW_RESRET := '2'
            SFW->FW_CONSOL := '2'
            SFW->FW_APURPER:= nTotCOF
            SFW->FW_NATRET := '02'
            SFW->FW_TOTRET := nTotCOF
        SFW->(MsUnlock())      
    EndIf


Return

