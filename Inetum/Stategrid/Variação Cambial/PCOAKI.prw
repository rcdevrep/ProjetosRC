#include "PROTHEUS.CH"
#include "TOPCONN.CH"

User Function PCOAKI(cAKIPROCES,cAKIITEM,cAKISEQ)

    Local cQuery    := ""
	Local _cAliQry	:= CriaTrab(Nil,.F.)
    Local cTESPar
    Local cTES
    Private nRet := 0

    IF cAKIPROCES == '000002' .And. cAKIITEM == '01' .And. cAKISEQ == '01'; nRet := IIF (M->E2_ORIGEM <> "MATA100".AND.M->E2_ORIGEM <> "FINA631".AND.M->E2_ORIGEM <> "FINA290M".AND.M->E2_ORIGEM <> "MATA953",IIF (GETMV("MV_XPCOBL") == .T. .AND. POSICIONE("CTT",1,XFILIAL("CTT")+M->E2_CCD,"CTT_XBLOQU")== "1" .AND. POSICIONE("AK5",1,XFILIAL("AK5")+M->E2_XCO,"AK5_XPCOBL")== "1", IF (M->E2_RATEIO="S" .OR. M->E2_MULTNAT="1" ,0, M->(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_ACRESC-E2_DECRESC)),0),0); EndIf
    IF cAKIPROCES == '000051' .And. cAKIITEM == '01' .And. cAKISEQ == '01'; nRet := IIF(GETMV("MV_XPCOBL")==.T..AND.POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("C1_CC"),"CTT_XBLOQU")=="1".AND.POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET("C1_XOCO"),"AK5_XPCOBL")=="1",If(SubStr(cContrato, 1, 1)<>'P',GDFIELDGET("C1_XVALOR"),GDFIELDGET("C1_XVRANO")),0); EndIf
    IF cAKIPROCES == '000052' .And. cAKIITEM == '01' .And. cAKISEQ == '01'; nRet := IIF (GETMV("MV_XPCOBL") == .T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('C7_XCO'),"AK5_XPCOBL")== "1", IF(!EMPTY(ALLTRIM(GDFIELDGET("C7_NUMCOT"))).OR. ALLTRIM(FUNNAME())$"CNTA121".OR.EMPTY(ALLTRIM(GDFIELDGET("C7_NUMSC"))).OR.GDFIELDGET("C7_RATEIO")="1".OR.POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("C7_CC"),"CTT_XBLOQU")=='2',0,GDFIELDGET("C7_QUANT")*SC1->C1_XVALOR),0); EndIf  //ALTERADO PARA 
    IF cAKIPROCES == '000052' .And. cAKIITEM == '01' .And. cAKISEQ == '02'; nRet := IIF (GETMV("MV_XPCOBL") == .T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('C7_XCO'),"AK5_XPCOBL")== "1" .AND. POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("C7_CC"),"CTT_XBLOQU")=='1', IF(!EMPTY(ALLTRIM(GDFIELDGET("C7_NUMCOT"))).OR.ALLTRIM(FUNNAME())$"CNTA121".OR.GDFIELDGET("C7_RATEIO")="1",0,GDFIELDGET("C7_TOTAL")+AVALORES[4]+AVALORES[3]+AVALORES[7]-AVALORES[2]), 0); EndIf
        
    
    IF cAKIPROCES == '000355' .And. cAKIITEM == '02' .And. cAKISEQ == '01'; nRet := IIF(FunName()=="CNTA121",IIF(M->CND_XCORTE=="S".OR.!EMPTY(GDFIELDGET('CNE_XNF')),0,IIF(GETMV("MV_XPCOBL")==.T. .AND.POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET('CNE_CC'),"CTT_XBLOQU")== "1".AND.POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('CNE_XCO'),"AK5_XPCOBL")== "1", GDFIELDGET('CNE_VLTOT'), 0 )),;
                                                                                                             IIF(FWFldGet("CND_XCORTE")=="S".OR.!EMPTY(FWFldGet('CNE_XNF')),0,IIF(GETMV("MV_XPCOBL")==.T. .AND.POSICIONE("CTT",1,XFILIAL("CTT")+FWFldGet('CNE_CC'),"CTT_XBLOQU")== "1".AND.POSICIONE("AK5",1,XFILIAL("AK5")+FWFldGet('CNE_XCO'),"AK5_XPCOBL")== "1", FWFldGet('CNE_VLTOT'), 0 ))); EndIf
    IF cAKIPROCES == '000355' .And. cAKIITEM == '02' .And. cAKISEQ == '01'; nRet := IIF(FunName()=="CNTA121",IIF(M->CND_XCORTE=="S".OR.!EMPTY(GDFIELDGET('CNE_XNF')),0,IIF(GETMV("MV_XPCOBL")==.T. .AND.POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET('CNE_CC'),"CTT_XBLOQU")== "1".AND.POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('CNE_XCO'),"AK5_XPCOBL")== "1", GDFIELDGET('CNE_VLTOT'), 0 )),0); EndIf
    IF cAKIPROCES == '000355' .And. cAKIITEM == '02' .And. cAKISEQ == '02'; nRet := IIF(FunName()=="CNTA121",IIF(FWFldGet("CND_XCORTE")=="S".OR.!EMPTY(FWFldGet("CNE_XNF")),0,IIF(GETMV("MV_XPCOBL")==.T. .AND.POSICIONE("CTT",1,XFILIAL("CTT")+FWFldGet("CNE_CC"),"CTT_XBLOQU")== "1".AND.POSICIONE("AK5",1,XFILIAL("AK5")+FWFldGet("CNE_XCO"),"AK5_XPCOBL")== "1", FWFldGet("CNE_VLTOT"), 0 )),0); EndIf

    IF cAKIPROCES == '900005' .And. cAKIITEM == '01' .And. cAKISEQ == '01'; nRet := IIF (GETMV("MV_XPCOBL") == .T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('D1_XCO'),"AK5_XPCOBL")== "1", IF (ALLTRIM(FUNNAME())$"MATA103" .OR. POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='2',0 , GDFIELDGET("D1_TOTAL")),0); EndIf
    IF cAKIPROCES == '900005' .And. cAKIITEM == '01' .And. cAKISEQ == '03'; nRet := IIF(GETMV("MV_XPCOBL")==.T..AND.POSICIONE("AK5",1,XFILIAL("AK5")+IF(SUBSTR(GDFIELDGET("D1_XCO"),1,3)<>'003',GDFIELDGET("D1_XCO"),SUBSTR(GDFIELDGET("D1_XCO"),1,5)+'0608'),"AK5_XPCOBL")=="1",IF(POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='2',0,GDFIELDGET("D1_VALFRE")),0); EndIf
    IF cAKIPROCES == '900005' .And. cAKIITEM == '01' .And. cAKISEQ == '04'; nRet := IIF(GDFIELDGET("D1_TES")=="009",0,IIF(GETMV("MV_XPCOBL")==.T..AND.POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('D1_XCO'),"AK5_XPCOBL")=="1",IF(POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='2',0,GDFIELDGET("D1_TOTAL")+GDFIELDGET("D1_VALIPI")+GDFIELDGET("D1_VALINP")-GDFIELDGET("D1_VALDESC")),0)); EndIf





    ///PONTO DE BLOQUEIO PARA REALIZAÇÃO DO DÉBITO DO EMPENHO
    IF cAKIPROCES == '000054' .And. cAKIITEM == '01' .And. cAKISEQ == '01' 
        
        cTESPar := GetMv("MV_XTESVC")
        cTES    := GDFIELDGET('D1_TES')

        If !(cTES $ cTESPar)

            // Verifica se o campo pedido de compras está vazio ou se a emissao é diferente do ano atual
            If EMPTY(GDFIELDGET("D1_PEDIDO")) .OR. SUBSTR(DTOS(DDATABASE),1,4) <> SUBSTR(DTOS(SC7->C7_EMISSAO),1,4)

                nRet := 0

            // Se tiver pedido de compras atrelado entra no else
            Else
                // Verifica se o Parametro MV_XPCOBL está ativo e se a conta orçamentária está com Bloqueio ativo e se o centro de custo está com bloqueio ativo
                If GETMV("MV_XPCOBL") == .T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('D1_XCO'),"AK5_XPCOBL")== "1" .AND. POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='1'
                    
                    // Retorna o valor empenhado do pedido realizando o calculo baseado na quantidade utilizada na nota fiscal Vezes o preço usado no pedido de compras + Valor do IPI + ICMS RET - Valor de desconto
                    nRet := (((POSICIONE("SC7",9,XFILIAL("SD1")+GDFIELDGET("D1_FORNECE")+GDFIELDGET("D1_LOJA")+GDFIELDGET("D1_PEDIDO")+GDFIELDGET("D1_ITEMPC"),"SC7->C7_PRECO") * GDFIELDGET("D1_QUANT"))+SC7->C7_VALIPI+SC7->C7_ICMSRET) - SC7->C7_VLDESC)
                Else
                    nRet := 0
                Endif
            EndIf  

        Else
            nRet := 0
        EndIf

    EndIf




    

    ///PONTO DE BLOQUEIO PARA REALIZAÇÃO DO DÉBITO DO ADIANTAMENTO
    IF cAKIPROCES == '000054' .And. cAKIITEM == '01' .And. cAKISEQ == '02'

        cTESPar := GetMv("MV_XTESVC")
        cTES    := GDFIELDGET('D1_TES')

        If !(cTES $ cTESPar)

            nRet := 0

            cQuery := "SELECT ISNULL(SUM(ZZ1_VLCOMP), 0) VLR_COMP "
            cQuery += " 	 , (SELECT SUM(D1_TOTAL+D1_VALIPI+D1_VALINP-D1_VALDESC) "
            cQuery += "	    FROM "+RetSqlName("SD1")+" D1 "
            cQuery += "	    WHERE D1.D_E_L_E_T_ = ' ' "
            cQuery += "	      AND D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO = '"+xFilial("ZZ1")+CNFISCAL+CSERIE+CA100FOR+CLOJA+CTIPO+"') AS VLNOTA "    
            cQuery += "FROM "+RetSqlName("ZZ1")+" ZZ1 "
            cQuery += "	 LEFT JOIN "+RetSqlName("SE2")+" SE2 ON (E2_XCHVZZ0 = ZZ1_CONTRA+ZZ1_REVISA+SUBSTRING(ZZ1_FILIAL,1,2)+ZZ1_NUMERO)
            cQuery += "WHERE ZZ1.D_E_L_E_T_ = ' ' "
            cQuery += "  AND ZZ1.ZZ1_FILIAL	= '" + xFilial("ZZ1") + "' AND ZZ1_PROCHL = 'S' "
            cQuery += "  AND ZZ1.ZZ1_SF1 = '"+xFilial("ZZ1")+CNFISCAL+CSERIE+CA100FOR+CLOJA+CTIPO+"' "
            cQuery += "  AND SE2.D_E_L_E_T_ = ' ' "
            cQuery += "  AND SE2.E2_CCD = '"+GDFIELDGET("D1_CC")+"' "
            cQuery += "  AND SE2.E2_XCO = '"+GDFIELDGET('D1_XCO')+"' "

            If Select(_cAliQry) > 0
                DbselectArea(_cAliQry)
                (_cAliQry)->(DbcloseArea())
            EndIf

            DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), _cAliQry, .F., .T.)

            If !(_cAliQry)->(Eof())
                nRet := ((_cAliQry)->VLR_COMP * (GDFIELDGET("D1_TOTAL")+GDFIELDGET("D1_VALIPI")+GDFIELDGET("D1_VALINP")-GDFIELDGET("D1_VALDESC")) / (_cAliQry)->VLNOTA) - ;
                        (GDFIELDGET('D1_VALCOF')+GDFIELDGET('D1_VALCSL')+GDFIELDGET('D1_VALPIS'))
            EndIf

            (_cAliQry)->(DbcloseArea())

 
        Else
            nRet := 0
        EndIf
       

    EndIf



                                  

   // PONTO DE BLOQUEIO DE FRETE
    IF cAKIPROCES == '000054' .And. cAKIITEM == '01' .And. cAKISEQ == '03'

        cTESPar := GetMv("MV_XTESVC")
        cTES    := GDFIELDGET('D1_TES')

        If !(cTES $ cTESPar)

            IF GETMV("MV_XPCOBL")==.T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('D1_XCO'),"AK5_XPCOBL") =="1"
                IF POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='2'
                    nRet := 0
                Else
                    nRet := GDFIELDGET("D1_VALFRE")
                EndIf
            Else
                nRet := 0
            Endif                                                                                     

 
        Else
            nRet := 0
        EndIf

    EndIf


    // PONTO DE BLOQUEIO DE Valor
    IF cAKIPROCES == '000054' .And. cAKIITEM == '01' .And. cAKISEQ == '04'


        cTESPar := GetMv("MV_XTESVC")
        cTES    := GDFIELDGET('D1_TES')

        If !(cTES $ cTESPar)


            IF Posicione("SF4",1,xFilial("SF4")+GDFIELDGET("D1_TES"),"F4_DUPLIC")=="N"
                nRet :=  0
            Else
                IF GETMV("MV_XPCOBL")==.T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('D1_XCO'),"AK5_XPCOBL")=="1"
                    IF POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='2'
                        nRet :=  0
                    Else
                        nRet :=  GDFIELDGET("D1_TOTAL")+GDFIELDGET("D1_VALIPI")+GDFIELDGET("D1_VALINP")-GDFIELDGET("D1_VALDESC")
                    EndIf
                Else
                    nRet :=  0 
                EndIf

            EndIf

        Else
            nRet := 0
        EndIf

    Endif






    // PONTO DE BLOQUEIO DE ICMS
    IF cAKIPROCES == '000054' .And. cAKIITEM == '01' .And. cAKISEQ == '05'
        

        cTESPar := GetMv("MV_XTESVC")
        cTES    := GDFIELDGET('D1_TES')

        If !(cTES $ cTESPar)


            IF GETMV("MV_XPCOBL")==.T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('D1_XCO'),"AK5_XPCOBL") =="1"
                IF POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='2'
                    nRet :=  0
                Else
                    nRet :=  GDFIELDGET("D1_ICMSCOM")
                EndIf
            Else
                nRet :=  0
            EndIf    
                                                      
        Else
            nRet := 0
        EndIf

    EndIf





    // PONTO DE BLOQUEIO DE ICMS VARIAÇÃO CAMBIAL
    IF cAKIPROCES == '000054' .And. cAKIITEM == '01' .And. cAKISEQ == '06'
        

        cTESPar := GetMv("MV_XTESVC")
        cTES    := GDFIELDGET('D1_TES')

        If !(cTES $ cTESPar)


            IF GETMV("MV_XPCOBL")==.T. .AND. POSICIONE("AK5",1,XFILIAL("AK5")+GDFIELDGET('D1_XCO'),"AK5_XPCOBL") =="1"
                IF POSICIONE("CTT",1,XFILIAL("CTT")+GDFIELDGET("D1_CC"),"CTT_XBLOQU")=='2'
                    nRet :=  0
                Else
                    nRet :=  GDFIELDGET("D1_VALICM")
                EndIf
            Else
                nRet :=  0
            EndIf    
                                                      
        Else
            nRet := 0
        EndIf

    EndIf

    

Return nRet




User Function PCOAKIDATA(cAKIPROCES,cAKIITEM,cAKISEQ)

    // Tratamento do campo Data no processo 54 item 01 seq 01 - Débito do EM
    IF cAKIPROCES == '000054' .And. cAKIITEM == '01' .And. cAKISEQ == '01' 

        //if SUBSTR(DTOS(DDATABASE),1,4) <> SUBSTR(DTOS(POSICIONE("SC7",9,XFILIAL("SD1")+GDFIELDGET("D1_FORNECE")+GDFIELDGET("D1_LOJA")+GDFIELDGET("D1_PEDIDO")+GDFIELDGET("D1_ITEM"),"SC7->C7_EMISSAO")),1,4)
        if SUBSTR(DTOS(DDATABASE),1,4) <> SUBSTR(DTOS(SC7->C7_EMISSAO),1,4)  
        
            dRet := SC7->C7_EMISSAO
        
        Else

            dRet := DDATABASE

        Endif
    

    Endif

Return dRet
