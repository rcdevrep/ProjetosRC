#include "PROTHEUS.CH"
#Include "TopConn.ch"

#Define QUEBRA (CHR(13)+CHR(10))

User Function PCOAKC(cAKCPROCES,cAKCITEM,cAKCSEQ)

    Private nRet := 0

    IF cAKCPROCES == '000002' .And. cAKCITEM == '01' .And. cAKCSEQ == '01'; nRet := IIF(  ALLTRIM(SE2->E2_TIPO) $ "PR |PA |TX |IRF|PIS|COF|CSL" .OR. SE2->E2_PREFIXO == 'IMP' .OR. SE2->E2_ORIGEM <> 'FINA050', 0, IF(GETADVFVAL("AK5","AK5_XPCOIN",XFILIAL("AK5")+SE2->E2_XCO,1,"")=="1",IF(SE2->E2_MULTNAT <>"1",SE2->(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_ACRESC-E2_DECRESC),0),0)); EndIf
    IF cAKCPROCES == '000051' .And. cAKCITEM == '01' .And. cAKCSEQ == '01'; nRet := IIF(GETMV("MV_XPCOBL")==.T..AND.POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("C1_CC"),"CTT_XBLOQU")=="1".AND.POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET("C1_XOCO"),"AK5_XPCOBL")=="1",If(SubStr(cContrato, 1, 1)<>'P',GDFIELDGET("C1_XVALOR"),GDFIELDGET("C1_XVRANO")),0); EndIf

    If cAKCPROCES == '000052' .And. cAKCITEM == '01' .And. cAKCSEQ == '06'
    
        IF POSICIONE("AK5",1,XFILIAL()+SC7->C7_XCO,"AK5_XPCOIN")== "1" .AND. EMPTY(POSICIONE("CNE",1,XFILIAL("CNE")+SC7->C7_CONTRA+SC7->C7_CONTREV+SC7->C7_PLANILH+SC7->C7_MEDICAO+SC7->C7_ITEMED,"CNE_XNF")) 
            nRet := ((SC7->C7_TOTAL+SC7->C7_VALIPI+SC7->C7_ICMSRET) - SC7->C7_VLDESC )-U_XPCOENCMED(4)
        Endif                             

    Endif

    
    If cAKCPROCES == '000017' .And. cAKCITEM == '01' .And. cAKCSEQ == '02'    
        
        nRet := 0
        
        IF FwisInCallStack("U_STACOMP") .And. SE5->E5_MOEDA > "1"
            IF AllTrim(SE5->E5_TIPO) <> "NDF"
                nRet := U_xPCO17(2)
            Else 
                nRet := 0
            Endif
            
            nRet := nRet * nTxAcorda
        Else
            IF AllTrim(SE5->E5_TIPO) <> "NDF"
                nRet := U_xPCO17(2)
            Else
                nRet := 0
            EndIf
        EndIf
        
    EndIf

Return nRet

// Função criada para tratar o valor do campo código da planilha

User Function PCOAKCCPLA(cAKCPROCES,cAKCITEM,cAKCSEQ)

Local cRet := " "

    // Tratamento do ponto de lançamento 000054 Item 01 Seq 01 - Débito do EM
    If ((cAKCPROCES == '000054' .OR. cAKCPROCES == '900005') .And. cAKCITEM == '01' .And. cAKCSEQ == '01')

        // Verifica se a data de digitação da NF é diferente da data de emissão do pedido de compras
        If SUBSTR(DTOS(SD1->D1_DTDIGIT),1,4) <> SUBSTR(DTOS(SC7->C7_EMISSAO),1,4)
        
            cRet := SUBSTR(DTOS(SC7->C7_EMISSAO),1,4)

        else

            cRet := SUBSTR(DTOS(SD1->D1_DTDIGIT),1,4)

        Endif
    
    Endif

    If cAKCPROCES == '900005' .And. cAKCITEM == '01' .And. cAKCSEQ == '04'

        // Verifica se a data do sistema é diferente da data de emissão do pedido de compras
        If SUBSTR(DTOS(DDATABASE),1,4) <> SUBSTR(DTOS(SC7->C7_EMISSAO),1,4)
        
            cRet := SUBSTR(DTOS(SC7->C7_EMISSAO),1,4)

        else

            cRet := SUBSTR(DTOS(DDATABASE),1,4)

        Endif
    
    Endif

Return cRet


/*
    Função criada para realizar o retorno de informações para a compensação da NDF
*/
User Function PCOAKCCO(cAKCPROCES,cAKCITEM,cAKCSEQ,cINFO)

    Local aArea     := GetArea()
    Local cQry      := ""
    Local cAlias	:= CriaTrab(Nil,.F.)
    Private cRet    := ""

    If cAKCPROCES == '000017'
        If cAKCITEM == '03' .And. cAKCSEQ $ '04/05'

            cRet := If(cINFO=="CO",SE2->E2_XCO,If(cINFO=="CC",SE2->E2_CCD,""))

            If Alltrim(SE2->E2_TIPO) <> "NDF"

                cQry := " SELECT TOP 1 E2_XCO, E2_CCD"+QUEBRA
                cQry += " FROM SE2010 E2 (NOLOCK) "+QUEBRA
                cQry += " WHERE E2.D_E_L_E_T_ = ' '"+QUEBRA
                cQry += "   AND E2.E2_TIPO = 'NDF'"+QUEBRA
                cQry += "   AND E2.E2_PREFIXO   = '"+SE5->E5_PREFIXO+"'"+QUEBRA
                cQry += "   AND E2.E2_NUM       = '"+SE5->E5_NUMERO+"'"+QUEBRA
                cQry += "   AND E2.E2_PARCELA   = '"+SE5->E5_PARCELA+"'"+QUEBRA
                cQry += "   AND E2.E2_TIPO      = '"+SE5->E5_TIPO+"'"+QUEBRA
                cQry += "   AND E2.E2_FORNECE   = '"+SE5->E5_CLIFOR+"'"+QUEBRA
                cQry += "   AND E2.E2_LOJA      = '"+SE5->E5_LOJA+"'"+QUEBRA

                TCQUERY cQry ALIAS (cAlias) NEW
                
                cRet := If(cINFO=="CO",(cAlias)->E2_XCO,If(cINFO=="CC",(cAlias)->E2_CCD,""))

                (cAlias)->(DBCloseArea())

            EndIf
        EndIf
    EndIf

    RestArea(aArea)

Return cRet 
