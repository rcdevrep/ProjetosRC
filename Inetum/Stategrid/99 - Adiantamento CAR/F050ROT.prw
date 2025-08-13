#include "totvs.ch"
#include "protheus.ch"
#include "fina050.ch"
 
/* 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Programa  ³ F050ROT  ºAutor  ³ Jader Berto         Data ³ 09/05/2024      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.  ³Ponto de Entrada - Inclusões de Botoões                        º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                            	          º±±
±±º                                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso    ³ SIGAFIS                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/ 

User Function F050ROT()
    Local aArea   := GetArea()
    Local aRotina := Paramixb// Array contendo os botoes padrões da rotina.
    Local aNRotin := {} 
    
    // Tratamento no array aRotina para adicionar novos botoes e retorno do novo array.

	
    If cArqRel == "SIGAFIS.REL"

        
        //Aadd(aNRotin, { "Alterar",                        "U_xFA050A", 0, 4, 0,.F.})

        Aadd(aNRotin, aRotina[1])
        Aadd(aNRotin, aRotina[2])
        Aadd(aNRotin, aRotina[4])

        //Aadd(aNRotin, { "Aglut.Imposto",                  "U_STAAGLIMP('FINA376')", 0, 8, 0,.F.})
        //Aadd(aNRotin, { "Aglut.Pis, Cofins e CSLL",       "U_STAAGLIMP('FINA378')", 0, 8, 0,.F.})
        //Aadd(aNRotin, { "Aglut.IRRF, Pis, Cofins e CSLL", "U_STAAGLIMP('FINA381')", 0, 8, 0,.F.})
        //Aadd(aNRotin, { "Faturas a Pagar",                "U_STAAGLIMP('FINA290')", 0, 8, 0,.F.})

        aRotina := aNRotin

    EndIf
    
    Aadd(aRotina, { "Impressão de Devolução",                  "U_SGADEVRC()", 0, 8, 0,.F.})

    RestArea(aArea)

Return aRotina



User Function xFA050A(cAlias,nReg,nOpc)

    Local lPanelFin := IsPanelFin()
    LOCAL nOpca     := 0
    LOCAL aCpos     := {}
    LOCAL nRecno    := 0
    LOCAL cParcela 	:= E2_PARCELA
    LOCAL nK        := 0
    LOCAL aUsers 	:= {}
    LOCAL aAreaSE2	:= SE2->(GetArea())
    LOCAL nIndex	:= SE2->(IndexOrd())
    Local cTudoOK   := Nil
    Local aBut050	:= {}



    Local __lFA50UPD := .F.
    Local __lFNCDRET := .F.
    Local __lRatMNat := .F.
    Local __lPLSFN50 := .F.
    Local __lIntPFS  := SuperGetMv("MV_JURXFIN",.T.,.F.) //Integração do Financeiro com o Juridico(Habilitado = .T.)
    Local __lBtrISS  := .F.

    Local __lHasEAI  := .F.
    Local __lTemMR   := (FindFunction("FTemMotor") .and. FTemMotor())

    Local __nVlrMR   := 0
    Local __lLocBRA  := cPaisLoc == "BRA"
    Local __lRateioIR := .F.

    Local __lMetric  := .F.
    Local __cFunBkp  := ""
    Local __cFunMet  := ""


    //Controla o Pis Cofins e Csll na baixa
    Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"

    Local lIRPFBaixa    := .F.
    Local nInss         := SE2->E2_INSS
    Local lCalcIssBx    := IsIssBx("P")
    Local lJustCP       := CposJust()
    Local cDirfImp      := ""
    Local cDirfPai      := ""
    Local lFoundTx      := .F.
    Local cLojaImp      := PadR( "00", TamSX3("A2_LOJA")[1], "0" )
    Local aCRets        := {}
    Local lRatPrj       :=.T.//indica se existe rateio de projetos
    Local cE2NATUREZ := Alltrim(SE2->E2_NATUREZ)
    Local cE2VENCTO  := DTOC(SE2->E2_VENCTO)
    Local cE2VENCREA := DTOC(SE2->E2_VENCREA)
    Local cE2VALOR   := Alltrim(Transform(SE2->E2_VALOR,PesqPict("SE2","E2_VALOR")))
    Local cE2DECRESC := Alltrim(Transform(SE2->E2_DECRESC,PesqPict("SE2","E2_DECRESC")))
    Local cE2ACRESC  := Alltrim(Transform(SE2->E2_ACRESC,PesqPict("SE2","E2_ACRESC")))
    Local cE2VALJUR  := Alltrim(Transform(SE2->E2_VALJUR,PesqPict("SE2","E2_VALJUR")))
    Local cE2PORCJUR := Alltrim(Transform(SE2->E2_PORCJUR,PesqPict("SE2","E2_PORCJUR")))
    Local cE2HIST    := Alltrim(SE2->E2_HIST)
    Local aAlt       := {}
    Local cKeySE2 	 := SE2->(indexkey())
    Local nRecSE2 	 := SE2->(Recno())
    Local lFA050ALT  := ExistBlock("FA050ALT")
    Local lF050ALT	 := ExistBlock("F050ALT")
    Local lAltPA     := .F.
    Local cTxDirf	 := ""
    Local lFKG       := .F.
    Local aFKGLoc    := {}
    Local nPosEv     := 0
    Local lFKF       := .F.
    Local aFKFLoc    := {}
    Local aTitImp    := {}
    Local cNatImp    := ""
    Local cAlias     := "SE2"
    Private aHeader := {}
    Private aCols := {}
    Private aRegs := {}
    Private cParcIr     := ""
    Private cFunct		:= ""
    Private cParcIss    := ""
    PRIVATE dOldVencRe	:= SE2->E2_VENCREA
    PRIVATE nOldVlCruz	:= SE2->E2_VLCRUZ
    PRIVATE dEmissao 	:= SE2->E2_EMISSAO
    PRIVATE lFirstAlt := .T.
    // A variavel abaixo ira guardar valor da ultima alteracao em tela. Serve
    // p/ evitar erro na reconstituicao do valor qdoe, numa 2¦ ou n¦ altera-
    // cao, o valor do INSS for zerado.
    PRIVATE nVlAltInss	:= 0
    PRIVATE nVlAltSEST   := 0
    PRIVATE aRatAFR		:= {}
    PRIVATE bPMSDlgFI	:= {||PmsDlgFI(4,M->E2_PREFIXO,M->E2_NUM,M->E2_PARCELA,M->E2_TIPO,M->E2_FORNECE,M->E2_LOJA)}
    PRIVATE aAutRatAFR	:= {}
    PRIVATE nOldVlAcres  := SE2->E2_ACRESC
    PRIVATE nOldVlDecres := SE2->E2_DECRESC
    PRIVATE cModRetPIS := GetNewPar( "MV_RT10925", "1" )
    PRIVATE aDadosRet  := Array(5)
    PRIVATE lAlterNat  := .F.
    Private nVlrOri    := SE2->E2_VALOR
    Private nPisOri    := SE2->E2_PIS
    Private nCofOri    := SE2->E2_COFINS
    Private nCslOri    := SE2->E2_CSLL
    Private nIrfOri    := SE2->E2_IRRF
    Private nISSOri    := SE2->E2_ISS
    Private nBtrISSOri := 0
    Private nPisInter  := SE2->E2_PIS
    Private nCofInter  := SE2->E2_COFINS
    Private nCslInter  := SE2->E2_CSLL
    Private cOldNaturez := SE2->E2_NATUREZ
    Private cOldNatPFS  := SE2->E2_NATUREZ
    Private aCposAlter  := {}
    Private _Opc := nOpc
    Private aSE2FI2		:=	{} // Utilizada para gravacao das justificativas
    PRIVATE lAltValor 	:= .F.
    PRIVATE lTitRetA 	:= .F.
    Private lAlteraTit  := .F. //DFS - 06/08/13 - Inclusão de flag para permitir apenas alterar o vencimento da Nota Fiscal gerada a partir do módulo EIC
    Private aCposEIC    := {}  //LGS - 18/05/16 - Utilizado no tratamento de validações para titulos originados pelo sigaeic
    // Utilizado para avaliar alteração *
    // no vencimento real               *
    Private dVencReaAnt	:= SE2->E2_VENCREA
    // Utilizado para armazemar valor *
    // alterado na tela de alteração  *
    Private cDirfAlt
    Private lRatOk  := .T.

    SE2->(DbSetOrder(nIndex))
    If !(SE2->(MsSeek(SE2->(&(cKeySE2)))))
        Help(" ",1,"ARQVAZIO")
        Return .T.
    Else
        SE2->(dbGoto(nRecSE2))
    Endif

    __cFunBkp := FunName()
    __cFunMet := Iif(AllTrim(__cFunBkp)=='RPC',"RPCFINA050",__cFunBkp)

    If __lMetric
        SetFunName(__cFunMet)
        // Metrica de controle de acessos 
        FwCustomMetrics():setSumMetric(Alltrim(ProcName()), "financeiro-protheus_qtd-por-acesso_total", 1)
        SetFunName(__cFunBkp)
    Endif

    nOldTxMoeda	:= 0

    If __lBtrISS
        nBtrISSOri := SE2->E2_BTRISS
    EndIf

    SA2->(dbSetOrder(1))
    SA2->(MSSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))

    //Motor de retenções,verifica quais impostos estão configurados
    If __lTemMR
        F050ImpCon(4)
    EndIf

    lIRProg := IIf(__lLocBRA,IIf(!Empty(SA2->A2_IRPROG),SA2->A2_IRPROG,"2"),"2")

    lIRPFBaixa := IIf( __lLocBRA, SA2->A2_CALCIRF == "2", .F.)

    lF050Auto   := IF(Type("lF050Auto") == "U", .F., lF050Auto)

    __lRateioIR := .F.

    //Permite rateio de Múltiplas natureza
    __lRatMNat := MV_MULNATP .And. Empty(SE2->E2_BAIXA) .And. AllTrim(SE2->E2_LA) <> "S" .And.;
    SE2->(E2_VALOR == E2_SALDO) .And. Alltrim(SE2->E2_ORIGEM) <> "MATA100"

    IF SED->ED_DEDINSS == "2"  //Nao desconta o INSS do principal
        nInss := 0
    Endif

    //Verifica se o título gera ou nao DIRF, buscando essa informação nos TXs.
    If __lLocBRA .And. !(Alltrim(SE2->E2_TIPO) $ MVTAXA+"|"+MVTXA)
        nRecno   := SE2->(Recno())
        cChave   := SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM
        cDirfPai := SE2->E2_DIRF
        cTxDirf := If(lAltPa,MVTXA,MVTAXA)
        cNatImp := AllTrim(GetMv("MV_PISNAT"))+"|"+AllTrim(GetMv("MV_COFINS"))+"|"+AllTrim(GetMv("MV_CSLL")) + "|"+ AllTrim(&(GetMv("MV_IRF")))
       
         aTitImp := ImpCtaPg(/*cImposto*/ , .F. )
        For nK := 1 To Len(aTitImp)

            If AllTrim(aTitImp[nK][4]) ==  cTxDirf  .And. AllTrim(aTitImp[nK][5]) $ cNatImp
                cDirfImp := SE2->E2_DIRF
                Exit
            Endif
        Next nK

        SE2->(dbGoto(nRecno))
        cDirfImp := If(AllTrim(cDirfImp) <> "", cDirfImp, cDirfPai)
        //Atualizo o campo E2_DIRF com o valor preenchido inicialmente, somente para a tela de alteração.
        If SE2->E2_DIRF<>cDirfImp
            RecLock("SE2",.F.)
            SE2->E2_DIRF := cDirfImp
            MsUnlock()
        EndIf
    Endif

    // Codigo de retenção anterior para IN4815
    cOldCodRet	:= SE2->E2_CODRET
    nOldIrrf 	:= SE2->E2_IRRF
    nOldIssInt 	:= SE2->E2_ISS
    nOldValor	:= SE2->E2_VALOR
    nOldSaldo	:= SE2->E2_SALDO
    nOldIns	 	:= SE2->E2_INSS
    nOldSES     := SE2->E2_SEST
    nValorAnt 	:= SE2->E2_VALOR
    If __lLocBRA
        nOldCID		:= SE2->E2_CIDE
    EndIf
    nOldPisAnt	:= SE2->E2_PIS
    nOldCofAnt	:= SE2->E2_COFINS
    nOldCslAnt	:= SE2->E2_CSLL
    If !lF050Auto
        aDadosRet := Array(5)
        nVlRetPis	:= 0
        nVlRetCof	:= 0
        nVlRetCsl	:= 0
        Afill(aDadosRet,0)
    Endif

    //Se controla Retencao
    If !lPccBaixa
        nOldPisAnt := IIF(Empty(SE2->E2_VRETPIS), SE2->E2_PIS , SE2->E2_VRETPIS )
        nOldCofAnt := IIF(Empty(SE2->E2_VRETCOF), SE2->E2_COFINS , SE2->E2_VRETCOF )
        nOldCslAnt := IIF(Empty(SE2->E2_VRETCSL), SE2->E2_CSLL , SE2->E2_VRETCSL )
    Endif

    // Grava o valor que realmente foi retido nos campos do PCC  *
    // para ser apresentado na tela do AxAltera e não afetar os  *
    // titulos de PCC gerados na emissão.                        *
    If __lLocBRA .and. !lPccBaixa .and. !lAlterNat
        //Gravo temporariamente do PIS/Cofins/Csll.
        RECLOCK("SE2",.F.,,.T.)
        SE2->E2_PIS := nOldPisAnt
        SE2->E2_COFINS := nOldCofAnt
        SE2->E2_CSLL := nOldCslAnt
        MsUnlock()
    EndIf

    //Botoes adicionais na EnchoiceBar
    aBut050 := fa050BAR('IntePms()')

    //inclusao do botao Posicao
    AADD(aBut050, {"HISTORIC", {|| Fc050Con() }, STR0204}) //"Posicao"

    //inclusao do botao Rastreamento
    AADD(aBut050, {"HISTORIC", {|| Fin250Pag(2) }, STR0205}) //"Rastreamento"

    If lJustCP // Adiciona botao para justificativa
        Aadd(aBut050,{'BAIXATIT',{||Fa050JUST()},STR0134})		//"Justificativa"
    Endif

    If __lIntPFS .And. FindFunction("JURA246") .And. !(SE2->E2_TIPO $ MVTAXA+"|"+MVINSS+"|"+MVISS+"|"+MVTXA+"|SES|INA|IRF|PIS|COF|CSL")
        Aadd(aBut050,{"", {|| JURA246(4) }, "Detalhe / Desdobramentos"}) //"Detalhe / Desdobramentos" (Modulo SIGAPFS)
    EndIf

    // Somente permite a alteracao de multiplas naturezas para titulo digitados
    If ((SE2->E2_MULTNAT == "1" .And. Alltrim(SE2->E2_ORIGEM) <> "MATA100") .OR. __lRatMNat) .And.;
        SE2->E2_FORNECE + SE2->E2_LOJA # GetMV("MV_UNIAO"  ) + Space(Len(SE2->E2_FORNECE) - Len(GetMV("MV_UNIAO"  ))) + cLojaImp .And.;
        SE2->E2_FORNECE + SE2->E2_LOJA # GetMV("MV_FORINSS") + Space(Len(SE2->E2_FORNECE) - Len(GetMV("MV_FORINSS"))) + cLojaImp .And.;
        SE2->E2_FORNECE + SE2->E2_LOJA # GetMV("MV_MUNIC"  ) + Space(Len(SE2->E2_FORNECE) - Len(GetMV("MV_MUNIC"  ))) + cLojaImp

        Aadd(aBut050, {'S4WB013N',;
        {||	MultNat(	"SE2",;
        0 /*@nHdlPrv*/,;
        M->E2_VALOR /*@nTotal*/,;
        "", /*@cArquivo*/;
        .F. /*lContabiliza*/,;
        If( SE2->E2_LA != "S", 4, 2 ) /*nOpc*/,;
        If(	/*lExpr*/	mv_par06==1,;
        /*T*/	If(	lPccBaixa .Or. ( lIRPFBaixa .And. ! M->E2_TIPO $ MVPAGANT ),;
        0,;
        M->E2_IRRF ) +;
        If( !lCalcIssBx, M->E2_ISS, 0 ) +;
        nInss +;
        M->E2_RETENC +;
        M->E2_SEST +;
        If( lPccBaixa, 0, E2_PIS + E2_COFINS + E2_CSLL ),;
        /*F*/	0 ) /*nImpostos*/,;
        mv_par10 = 2 .And. mv_par06 = 2 /*lRatImpostos*/,;
        aHeader /*acolsM*/,;
        aCols /*aHeaderM*/,;
        aRegs /*aRegs*/,;
        .F. /*lGrava*/,;
        /*lMostraTela*/,;
        /*lRotAuto*/,;
        /*lUdaFlag*/,;
        /*@aFlagCTB*/) },;
        STR0116 /*Rateio das Naturezas do titulo*/,;
        STR0123 /*Rateio*/ } )
    Endif

    If SE2->( EOF()) .or. xFilial("SE2") # SE2->E2_FILIAL
        Help(" ",1,"ARQVAZIO")
        Return .T.
    Endif

    ///Projeto
    // Verifica campos do usuario
    dbSelectArea("SX3")
    dbSetOrder(1)
    dbSeek("SE2")

    While !Eof() .and. X3_ARQUIVO == "SE2"
        If SX3->X3_PROPRI == "U"
            Aadd(aUsers,SX3->X3_CAMPO)
        Endif
        dbSkip()
    Enddo

    // Validação Siafi
    If FinTemDH()
        Return .T.
    Endif

    //Se veio atraves da integracao Protheus X Tin nao Pode ser alterado
    If (!Type("lF050Auto") == "L" .Or. !lF050Auto) .and.  Upper(AllTrim(SE2->E2_ORIGEM))=="FINI055"
        HELP(" ",1,"ProtheusXTIN",,STR0213,2,0)//"Título gerado pela Integração Protheus X Tin não Pode ser alterado pelo Protheus"
        Return
    Endif

    // AAF - Titulos originados no SIGAEFF não devem ser alterados
    If !lF050Auto .AND. "SIGAEFF" $ SE2->E2_ORIGEM
        Help(" ",1,"FAORIEFF")
        Return
    EndIf

    //verifica se e titulo originado do SIGAPLS e nao deixa alterar.
    if __lPLSFN50 .and. ! lF050Auto .and. PLSFN050(nOpc)
        return(.f.)
    endIf

    // DFS - 16/03/11 - Deve-se verificar se os títulos foram gerados por módulos Trade-Easy, antes de apresentar a mensagem.
    // TDF - 26/12/11 - Acrescentado o módulo EFF para permitir liquidação
    // NCF - 25/03/13 - Acrescentado o módulo SIGAESS (Siscoserv)
    If (UPPER(Alltrim(SE2->E2_ORIGEM)) $ "SIGAEEC/SIGAEIC/SIGAEDC/SIGAECO/SIGAESS" .OR.;
    (!(Left(Alltrim(SE2->E2_ORIGEM),3) == 'FIN') .And. SE2->E2_PREFIXO == 'EIC')) .AND. !(cModulo $ "EEC/EIC/EDC/ECO/EFF/ESS")

        If FindFunction("EasyOrigem")
            If F050EasyOrig(AllTrim(SE2->E2_ORIGEM))
                If lAlteraTit
                    aCpos := aClone( aCposEIC )
                Else
                    Return
                EndIf
            EndIf
        Else
            If Posicione("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_PAIS") <> "105" .AND. SE2->E2_MOEDA > 1
                HELP(" ",1,"FAORIEEC")
                Return
                // GFP - 07/03/2014 - Tratamento para liberar os campos que são permitidos para alteração, com exceção daqueles utilizados pelos módulos de Comercio Exterior.
            ElseIf UPPER(Alltrim(SE2->E2_TIPO)) == "NF" .AND. SE2->E2_MOEDA == 1
                aCpos := fa050MCpo(4)
                If (nPos := aScan(aCpos, "E2_VENCREA")) # 0
                    ADEL(aCpos,nPos)
                    ASIZE(aCpos,LEN(aCpos)-1)
                EndIf
                If (nPos := aScan(aCpos, "E2_VALOR")) # 0
                    ADEL(aCpos,nPos)
                    ASIZE(aCpos,LEN(aCpos)-1)
                EndIf
                If (nPos := aScan(aCpos, "E2_VLCRUZ")) # 0
                    ADEL(aCpos,nPos)
                    ASIZE(aCpos,LEN(aCpos)-1)
                EndIf
                lAlteraTit := .T.
            Else   
                HELP(" ",1,"FAORIEEC")
                Return
            EndIf
        EndIf
    Endif

    // Caso titulo esteja num bordero nao pode sofrer alteracao
    If !Empty(SE2->E2_NUMBOR)
        Help(" ",1,"F050BORD",,STR0099+CHR(13)+STR0100,1,0)
        Return
    EndIf

    // Verifica se o titulo esta bloqueado
    If !Empty(SE2->(FieldPos("E2_MSBLQL"))) .And. SE2->E2_MSBLQL == "1" .And. lVerifyBlq .and. UPPER(Alltrim(SE2->E2_ORIGEM)) $ "CNTA090/CNTA100/CNTA120/CNTA121"
        Help(" ",1,"SE2BLOQ")
        Return
    EndIf

    // Verifica se data do movimento n„o ‚ menor que data limite de
    // movimentacao no financeiro
    If !DtMovFin(,,"1")
        Return
    Endif

    nOldIRR 	:= SE2->E2_IRRF
    nOldISS 	:= SE2->E2_ISS
    If __lBtrISS
        nOldBtrISS := SE2->E2_BTRISS
    EndIf
    nOldInss	:= SE2->E2_INSS
    nOldSEST	:= SE2->E2_SEST
    If __lLocBRA
        nOldCID  := SE2->E2_CIDE
    EndIf

    // Se existir os campos de impostos a pagar, PIS, COFINS, CSLL - MP 135
    If !lPccBaixa
        nOldPis	   := SE2->E2_PIS
        nOldCofins := SE2->E2_COFINS
        nOldCsll   := SE2->E2_CSLL
    Endif
    // Atencao para criar o array aCpos
    cParcIss	 := If(Empty(SE2->E2_PARCISS),cParcela,SE2->E2_PARCISS)
    cParcIr	 := If(Empty(SE2->E2_PARCIR ),cParcela,SE2->E2_PARCIR )
    cParcInss := If(Empty(SE2->E2_PARCINS),cParcela,SE2->E2_PARCINS)
    cParcSEST := If(Empty(SE2->E2_PARCSES),cParcela,SE2->E2_PARCSES)
    If __lLocBRA
        cParcCIDE := If(Empty(SE2->E2_PARCCID),cParcela,SE2->E2_PARCCID)
    EndIf

    //Monta campos para usuario
    //DFS - 06/08/13 - Caso não seja alteração de título gerado pelo EIC, pode incluir os outros campos para alteração
    If !lAlteraTit
        aCpos := fa050MCpo(4)
    EndIf
    If aCpos == Nil
        return
    EndIf

    // Caso seja um PA, somente permite alterar o historico e campos de usuario
    If SE2->E2_TIPO $ MVPAGANT .And. F050MovBco()
        lAltPA := .T.
        aCpos := {"E2_HIST"}
    EndIf

    aCposAlter := aClone( aCpos )

    // Preenche campos alter veis (usu rio)
    If Len(aUsers) > 0
        FOR nk:=1 TO Len(aUsers)
            Aadd(aCpos,Alltrim(aUsers[nk]))
        NEXT nk
    EndIf

    lAltera := .T.

    dbSelectArea("SA2")
    dbSeek(cFilial+SE2->E2_FORNECE+SE2->E2_LOJA)

    dbSelectArea( cAlias )
    dbSetOrder(1)

    IF __lFA50UPD
        // Ponto de Entrada para Pre-Validacao de Alteracao
        IF !ExecBlock("FA050UPD",.f.,.f.)
            Return .F.
        Endif
    Endif

    // integração com o PMS
    If IntePMS()
        SetKey(VK_F10, {|| Eval(bPMSDlgFI)})
    EndIf

    cTudoOk := 'Iif(Len(aSE2FI2)==0,Fa050JUST(),.T.) .And. F050PcoLan() '
    If !lF050Auto
        cTudoOk += ' .And. If(M->E2_TEMDOCS == "1",CN062NecDocs(),.T.) ' //Documentos
        cTudoOk += ' .And. F050CodRet()'
    EndIf

    IF lFA050ALT
        cTudoOK += ' .and. ExecBlock("FA050ALT",.f.,.f.)'
    Endif
    If  IntePMS() .and. (nPosAFR:=AScan(aAutocab,{|x|AllTrim(x[1])=="AUTRATAFR"})) >0 //rateio automatico de projetos
        aAutoAFR:=aClone(aAutoCab[nPosAFR][2])
        cTudoOk+=' .and. F050AutAFR('+Str(nOpc,2)+') '
    Endif

    cTudoOK += ' .And. F050VldVlr() '

    If FindFunction("JurValidCP") .And. __lIntPFS
        cTudoOK += ' .And. JurValidCP(4) '
    EndIf

    cTudoOK += ' .and. f050RatOk(lRatOK) '

    Afill(aDadosRet,0)
    //Controle de retencao do PIS/Cofins/CSLL
    If __lLocBRA .and. !lPccBaixa .and. !lAltPA

        If (SE2->E2_PRETPIS == "1" .or. SE2->E2_PRETCOF == "1" .or. SE2->E2_PRETCSL == "1" )
            nOldPis := 0
            nOldCofins := 0
            nOldCsll := 0
        Else
            nOldPis := IIF(Empty(SE2->E2_VRETPIS), SE2->E2_PIS , SE2->E2_VRETPIS )
            nOldCofins := IIF(Empty(SE2->E2_VRETCOF), SE2->E2_COFINS , SE2->E2_VRETCOF )
            nOldCsll := IIF(Empty(SE2->E2_VRETCSL), SE2->E2_CSLL , SE2->E2_VRETCSL )
        Endif

        //Apresento o botao de retencao apenas se existir possibilidade de alteracao do valor
        If (nPos := Ascan(aCpos,{ |x| x == "E2_VALOR" } )) > 0
            Aadd(aBut050,{"NOTE",{||F050CalcRt()},STR0125,STR0126})  //"Modalidade de Retenção Pis/Cofins/Csll"###"Impostos"
        Endif
    EndIf

    ///Projeto
    // Inicializa a gravacao dos lancamentos do SIGAPCO
    PcoIniLan("000002")

    If lAltPA
        cFunct :=""
        aBut050 := {}
    Else
        cFunct :="FA050AXALT('"+cAlias+"','"+cParcIss+"','"+cParcIr+"','"+cParcInss+"','"+cParcSEST+"')"
    EndIf

    Begin Transaction
        __nVlrMR    := 0
        If !Type("lF050Auto") == "L" .or. !lF050Auto
            If lPanelFin  //Chamado pelo Painel Financeiro
                dbSelectArea("SE2")
                xMemory("SE2",.F.,.F.,.F.,"FINA050")
                nValDig := M->E2_VALOR	// Carrega o valor do titulo para nao zerar variavel de memoria no uso de gatilho
                oPanelDados := FinWindow:GetVisPanel()
                oPanelDados:FreeChildren()
                aDim := DLGinPANEL(oPanelDados)
                nOpca := xAltera(cAlias,nReg,nOpc,,aCpos,4,SA2->A2_NOME,cTudoOk,cFunct,,aBut050,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,.T.,oPanelDados,aDim,FinWindow)

            Else
                xMemory("SE2",.F.,.F.,.F.,"FINA050") // incluido Eduardo
                nValDig := M->E2_VALOR	// Carrega o valor do titulo para nao zerar variavel de memoria no uso de gatilho
                nOpca := xAltera(cAlias,nReg,nOpc,,aCpos,4,SA2->A2_NOME,cTudoOk,cFunct,,aBut050)
            Endif
        Else
            xMemory("SE2",.F.,.F.)
            nValDig := M->E2_VALOR
            If f050AltCmp(aCpos, aAutoCab) .And. EnchAuto(cAlias,aAutoCab,cTudoOk,nOpc )
                nPosEv := AScan(aAutocab,{|x|AllTrim(x[1])=="AUTCMTIT"})
                If nPosEv>0
                    aFKFLoc := aClone(aAutoCab[nPosEv][2])
                    lFKF    := .T.
                EndIf

                nPosEv:=AScan(aAutocab,{|x|AllTrim(x[1])=="AUTCMIMP"})
                If nPosEv>0
                    aFKGLoc := aClone(aAutoCab[nPosEv][2])
                    lFKG    := .T.
                EndIf

                If cPaisLoc=="BRA" .and. (lFKF .or. lFKG)
                    lRet:= F986ExAut("SE2", aFKFLoc, aFKGLoc, 4, aAutocab)
                EndIf

                nOpcA := AxIncluiAuto(cAlias,,cFunct,4,SE2->(RecNo()))
            EndIf
        EndIf

        IF lF050ALT .and. !lAltPA
            // Ponto de Entrada para Valida‡Æo pos-Confirma‡Æo de Alteracao
            ExecBlock("F050ALT",.f.,.f.,{nOpca})
        Endif

        If nOpca == 1 //verifica se houve alterações, para geração do log de alterações

            If !(cE2NATUREZ == Alltrim(SE2->E2_NATUREZ))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0258 , STR0256 + ' - ' +  Alltrim(cE2NATUREZ) , STR0257 + ' - ' + Alltrim(SE2->E2_NATUREZ)})
            endif

            If !(cE2VENCTO == Alltrim(DTOC(SE2->E2_VENCTO)))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0259 , STR0256 + ' - ' + Alltrim(cE2VENCTO) , STR0257 + ' - ' +  Alltrim(DTOC(SE2->E2_VENCTO))})
            endif

            If !(cE2VENCREA == Alltrim(DTOC(SE2->E2_VENCREA)))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0260 , STR0256 + ' - '  +  Alltrim(cE2VENCREA) , STR0257 + ' - ' +  Alltrim(DTOC(SE2->E2_VENCREA))})
            endif

            If !(cE2VALOR == Alltrim(Transform(SE2->E2_VALOR,PesqPict("SE2","E2_VALOR"))))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0261 , STR0256 + ' - '  +  Alltrim(cE2VALOR) , STR0257 + ' - ' + Alltrim(Transform(SE2->E2_VALOR,PesqPict("SE2","E2_VALOR"))) })
            endif

            If !(cE2DECRESC == Alltrim(Transform(SE2->E2_DECRESC,PesqPict("SE2","E2_DECRESC"))))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0262 , STR0256 + ' - '  +  Alltrim(cE2DECRESC) ,STR0257 + ' - ' + Alltrim(Transform(SE2->E2_DECRESC,PesqPict("SE2","E2_DECRESC"))) })
            endif

            If !(cE2ACRESC == Alltrim(Transform(SE2->E2_ACRESC,PesqPict("SE2","E2_ACRESC"))))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0263 , STR0256 + ' - '  +  Alltrim(cE2ACRESC) ,STR0257 + ' - ' + Alltrim(Transform(SE2->E2_ACRESC,PesqPict("SE2","E2_ACRESC"))) })
            endif

            If !(cE2VALJUR == Alltrim(Transform(SE2->E2_VALJUR,PesqPict("SE2","E2_VALJUR"))))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0264 , STR0256 + ' - ' +  Alltrim(cE2VALJUR) , STR0257 + ' - ' +  Alltrim(Transform(SE2->E2_VALJUR,PesqPict("SE2","E2_VALJUR"))) })
            endif

            If !(cE2PORCJUR == Alltrim(Transform(SE2->E2_PORCJUR,PesqPict("SE2","E2_PORCJUR"))))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0265 , STR0256 + ' - '  +  Alltrim(cE2PORCJUR) ,STR0257 + ' - ' +  Alltrim(Transform(SE2->E2_PORCJUR,PesqPict("SE2","E2_PORCJUR"))) })
            endif

            If !(cE2HIST == Alltrim(SE2->E2_HIST))
                aadd( aAlt,{ STR0253 , STR0254 + ' :', STR0255 + ' - '  + STR0266 , STR0256 + ' - '  +  Alltrim(cE2HIST) ,STR0257 + ' - ' +  Alltrim(SE2->E2_HIST)})
            endif

            ///chamada da Função que cria o Log de alterações
            FinaCONC(aAlt,"SE2")

        endif

        If __lLocBRA .and. !lPccBaixa .and. nOpca != 1 .and.(!lAlterNat .or. ;
        STR(SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL,17,2) == STR(nPisOri+nCofOri+nCslOri,17,2))
            //Regravo os valores originais de PIS/Cofins/Csll em caso de desistencia de alteracao
            RECLOCK("SE2",.F.,,.T.)
            SE2->E2_PIS := nPisOri
            SE2->E2_COFINS := nCofOri
            SE2->E2_CSLL := nCslOri
            MsUnlock()
        EndIf

        nOldValor := SE2->E2_VALOR
        nOldSaldo := SE2->E2_SALDO
        nOldIRR   := SE2->E2_IRRF
        nOldISS   := SE2->E2_ISS
        If __lBtrISS
            nOldBtrISS := SE2->E2_BTRISS
        EndIf
        nOldInss  := SE2->E2_INSS
        nOldSEST  := SE2->E2_SEST
        nOldPis	  := SE2->E2_PIS
        nOldCofins:= SE2->E2_COFINS
        nOldCsll  := SE2->E2_CSLL

        If !lPccBaixa
            nOldPis := IIF(Empty(SE2->E2_VRETPIS), SE2->E2_PIS , SE2->E2_VRETPIS )
            nOldCofins := IIF(Empty(SE2->E2_VRETCOF), SE2->E2_COFINS , SE2->E2_VRETCOF )
            nOldCsll := IIF(Empty(SE2->E2_VRETCSL), SE2->E2_CSLL , SE2->E2_VRETCSL )
        Endif
        // Finaliza a gravacao dos lancamentos do SIGAPCO
        PcoFinLan("000002")

        PcoFreeBlq("000002")

        // Trexo que altera os campos Gera Dirf e Codigo de Retencao
        // dos titulos filhos (quando houverem)
        If __lLocBRA .And. !(Alltrim(SE2->E2_TIPO) $ MVTAXA+"|"+MVTXA)
            nRecno  := SE2->(Recno())
            cChave  := SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM
            cCodRet := SE2->E2_CODRET
            cDirf   := Iif((SE2->E2_DIRF != cDirfImp .AND. cDirfAlt != '1').OR.(SE2->E2_DIRF=="1" .AND.cDirfAlt == "1") , SE2->E2_DIRF, cDirfImp)
            cTxDirf := If(lAltPa,MVTXA,MVTAXA)
            lFoundTx := .F.

            If SE2->E2_DIRF != cDirfImp
                //Se houve alteração do status da DIRF, atualizo os TXs e o tit. principal na sequencia.
                dbSeek(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM,.T.)
                Do While !EOF() .And. SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == cChave
                    If Alltrim(SE2->E2_TIPO) == cTxDirf .And. Alltrim(SE2->E2_NATUREZ) $ "IRF/PIS/COFINS/CSLL"
                        RecLock("SE2",.F.,,.T.)
                        SE2->E2_DIRF := cDirf
                        lFoundTx := .T.
                        If "IRF" $ SE2->E2_NATUREZ
                            SE2->E2_CODRET := cCodRet
                        Endif
                        If Alltrim(SE2->E2_NATUREZ) $ "PIS/COFINS/CSLL"
                            //uso de código único de retenção - empresa pública
                            If __lFNCDRET
                                aCRets :=ExecBlock("FINCDRET")
                                If aScan(aCRets,cCodRet) > 0
                                    SE2->E2_CODRET := cCodRet
                                EndIf
                            EndIf
                        EndIf
                        MsUnlock()
                    Endif
                    dbSkip()
                Enddo
                SE2->(dbGoto(nRecno))
                RecLock("SE2",.F.,,.T.)
                SE2->E2_DIRF := If(lFoundTx,"2",cDirf)
                MsUnlock()
            Else
                //Se não houve alteração do status da DIRF, restauro o valor original.
                RecLock("SE2",.F.,,.T.)
                SE2->E2_DIRF := cDirfPai
                MsUnlock()
            Endif
        Endif

        If IntePMS()
            SetKey(VK_F10, Nil)
        EndIf
        If SE2->E2_INSS > 0 .and. !lAltPA
            Reclock("SE2",.F.,,.T.)
            SE2->E2_VRETINS := SE2->E2_INSS
            MsUnlock()
        EndIf

        If 	cPaisLoc $ "DOM|COS"  .And. !lF050Auto  .And. (SE2->E2_NATUREZ <> M->E2_NATUREZ .Or. SE2->E2_VALOR <> M->E2_VALOR)
            //Deleção dos titulos de Abatimento Gerados Anteriormente
            fa050DelRet()
            //Geração das Retenções de Impostos - Republica Dominicana //1-Contas a Pagar ou 3-Ambos e Fato Gerador 1-Emissao.
            fa050CalcRet("'1|3'", "2", SE2->E2_NATUREZ, SE2->E2_VALOR, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE)
        EndIf

        If nOpcA == 1 .AND. GetNewPar('MV_NGMNTFI','N') == 'S'  .and. !lAltPA
            NGMNTSE2(nOpc)
        Endif

        // Integração protheus X tin.
        If nOpcA == 1 .and. __lHasEAI .and. !lAltPA
            lRatPrj := PMSRatPrj("SE2",,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA)
            If !( AllTrim(SE2->E2_TIPO) $ MVPAGANT .and. lRatPrj  .and. !(cPaisLoc $ "BRA|")) //nao integra PA  para Totvs Obras e Projetos Localizado
                aEaiRet := FWIntegDef('FINA050',,,, 'FINA050')
                If !aEaiRet[1]
                    Help(" ", 1, "HELP", "Erro EAI", "Problemas na integração EAI. Transação não executada." + CRLF + aEAIRET[2], 3, 1)  // "Erro EAI" / "Problemas na integração EAI. Transação não executada."
                    DisarmTransaction()
                    nOpcA := 2
                    Break
                Endif
            Endif
        Endif

    End Transaction

    If __lLocBRA
        F986LimpaVar() //Limpa as variaveis estaticas - Complemento de Titulo
        f050LRatIR(.T.)
    EndIf

    RestArea(aAreaSE2)
    FwFreeArray(aAreaSE2)

Return nOPCA






Static FUNCTION xAltera(cAlias,nReg,nOpc,aAcho,aCpos,nColMens,cMensagem,cTudoOk,cTransact,cFunc,;
				aButtons,aParam,aAuto,lVirtual,lMaximized,cTela,lPanelFin,oFather,aDim,uArea,lFlat)

Local aArea    := GetArea(cAlias)
Local aPosEnch := {}
Local bCampo   := {|nCPO| Field(nCPO) }
Local bOk      := Nil
Local bOk2     := {|| .T.}
Local cCpoFil  := PrefixoCpo(cAlias)+"_FILIAL"
Local cMemo    := ""
Local nOpcA    := 0
Local nX       := 0
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cAliasMemo
Local bEndDlg := {|lOk| lOk:=oDlg:End(), nOpcA:=1, lOk}
Local oEnc01
Local oSize

Private aTELA[0][0]
Private aGETS[0]

DEFAULT lVirtual:= .F.
DEFAULT cTudoOk := ".T."
DEFAULT nReg    := (cAlias)->(RecNO())
DEFAULT bOk := &("{|| "+cTudoOk+"}")
DEFAULT lPanelFin := .F.
DEFAULT lFlat := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento de codeblock de validacao de confirmacao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aParam)
	bOk2 := aParam[2]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se esta' alterando um registro da mesma filial               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
If (cAlias)->(FieldGet(FieldPos(cCpoFil))) == xFilial(cAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SoftLock(cAlias)
		xMemory(cAlias,.F.,lVirtual)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis para campos Memos Virtuais		 			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aMemos")=="A"
			For nX:=1 to Len(aMemos)
				cMemo := aMemos[nX][2]
				If ExistIni(cMemo)
					&cMemo := InitPad(SX3->X3_RELACAO)
				Else
					&cMemo := ""
				EndIf
			Next nX
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis para campos Memos Virtuais		 			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( ValType( cFunc ) == 'C' )
		    If ( !("(" $ cFunc) )
			   cFunc+= "()"
			EndIf
			&cFunc
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento de codeblock de antes da interface                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aParam)
			Eval(aParam[1],nOpc)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para processamento dos Gets				   	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aAuto == Nil
		   If !lPanelFin .AND. !lFlat

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula as dimensoes dos objetos                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSize := FwDefSize():New( .T. ) // Com enchoicebar

				oSize:lLateral     := .F.  // Calculo vertical

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria Enchoice                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Dispara o calculo                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSize:Process()

				nTop    := oSize:aWindSize[1]
				nLeft   := oSize:aWindSize[2]
				nBottom := oSize:aWindSize[3]
				nRight  := oSize:aWindSize[4]

				If IsPDA()
					nTop := 0
					nLeft := 0
					nBottom := PDABOTTOM
					nRight  := PDARIGHT
				EndIf
				// Build com correção no tratamento dos controles pendentes na dialog ao executar o método End()
				bEndDlg := {|lOk| If(lOk:=oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}

				DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd STYLE nOr(WS_VISIBLE,WS_POPUP)

				If lMaximized <> NIL
					oDlg:lMaximized := lMaximized
				EndIf

				If IsPDA()
					oEnc01:= MsMGet():New( cAlias, nReg, nOpc,     ,"CRA",oemtoansi("Quantas alterações?"),aAcho,  aPosEnch,aCpos, ,nColMens,If(nColMens != Nil,cMensagem,NIL),cTudoOk,,lVirtual,.t.,,,,,,,,, cTela) //"Quanto …s altera‡”es?"
					oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
				Else

					aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
						 oSize:GetDimension("ENCHOICE","COLINI"),;
						 oSize:GetDimension("ENCHOICE","LINEND"),;
						 oSize:GetDimension("ENCHOICE","COLEND")}

					If nColMens != Nil
						oEnc01:= MsMGet():New( cAlias, nReg, nOpc, ,"CRA",oemtoansi("Quantas alterações?"),aAcho,aPosEnch,aCpos,,nColMens,cMensagem,cTudoOk,,,lVirtual,,,,,,,,, cTela) //"Quanto …s altera‡”es?"
					Else
						oEnc01:= MsMGet():New( cAlias, nReg, nOpc, ,"CRA",oemtoansi("Quantas alterações?"),aAcho,aPosEnch,aCpos,,,,cTudoOk,,,lVirtual,,,,,,,,, cTela) //"Quanto …s altera‡”es?"
					EndIf
					oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
				EndIf
				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.F.))},{|| nOpcA := 3,oDlg:End()},,aButtons,nReg,cAlias)
			Else

				DEFINE MSDIALOG ___oDlg OF oFather:oWnd  FROM 0, 0 TO 0, 0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

				aPosEnch := {,,,}
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,"CRA",oemtoansi("Quantas alterações?"),aAcho,aPosEnch,aCpos,,,,cTudoOk,___oDlg  ,,lVirtual,.F.,,,,,,,,cTela) //"Quanto …s altera‡”es?"
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT

				bEndDlg := {|lOk| If(lOk:=___oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}

				// posiciona dialogo sobre a celula
				___oDlg:nWidth := aDim[4]-aDim[2]
				ACTIVATE MSDIALOG ___oDlg  ON INIT (FaMyBar(___oDlg,{|| If(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.f.))},{|| nOpcA := 3,___oDlg:End()},aButtons), ___oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1]) )

			Endif
		Else
			If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela) .And. Eval(bOk).And.Eval(bOk2,nOpc)},nOpc,aCpos)
				nOpcA := 1
			EndIf
		EndIf
		(cAlias)->(MsGoTo(nReg))
		If nOpcA == 1
			Begin Transaction
				RecLock(cAlias,.F.)
				For nX := 1 TO FCount()
					FieldPut(nX,M->&(EVAL(bCampo,nX)))
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava os campos Memos Virtuais					  				  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("aMemos") == "A"
					For nX := 1 to Len(aMemos)
						cVar := aMemos[nX][2]
						cVar1:= aMemos[nX][1]
						//Incluído parametro com o nome da tabela de memos => para módulo APT
						cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
						MSMM(&cVar1,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
					Next nX
				EndIf
				If cTransact != Nil
					If !("("$cTransact)
						cTransact+="()"
					EndIf
					&cTransact
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processamento de codeblock dentro da transacao                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aParam)
					Eval(aParam[3],nOpc)
				EndIf
			End Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento de codeblock fora da transacao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aParam)
				Eval(aParam[4],nOpc)
			EndIf
		EndIf
	Else
		nOpcA := 3
	EndIf
Else
	Help(" ",1,"A000FI")
	nOpcA := 3
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()
RestArea(aArea)

If lPanelFin
	FinVisual(cAlias,uArea,(cAlias)->(Recno()))
Endif

Return(nOpcA)


Static Function xMemory(cAlias,lInc,lDic,lInitPad, cStack)

Local aArea    := GetArea()
Local aAreaSX3 := SX3->(GetArea())
Local nX    := 0
Local cCpo  := ""

DEFAULT lInc := .F.
DEFAULT lDic := .T.
DEFAULT lInitPad := .T.
DEFAULT __HasSNPrvt := FindFunction('_SETNAMEDPRVT')

If ( cStack != NIL ) .And. ( ! __HasSNPrvt )
	UserException( 'Cannot find function _SetNamedPrvt' )
EndIf

If lDic
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	While !Eof() .and. SX3->X3_ARQUIVO == cAlias
		DbSelectArea(cAlias)
		If SX3->X3_CONTEXT == "V" .or. lInc
			If ( cStack == NIL )
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),lInitPad))
			Else
				_SetNamedPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),lInitPad), cStack)
			EndIf
		Else
			cCpo := (cAlias+"->"+Trim(SX3->X3_CAMPO))
			If ( cStack == NIL )
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO),&cCpo)
			Else
				_SetNamedPrvt(Trim(SX3->X3_CAMPO),&cCpo, cStack)
			EndIf
		EndIf
		DbSelectArea("SX3")
		DbSkip()
	EndDo
Else
	dbSelectArea(cAlias)
	For nX := 1 To FCount()
		If ( lInc )
			cCpo := CriaVar(Trim(FieldName(nX)),lInitPad)
		Else
			cCpo := &(cAlias+"->"+Trim(FieldName(nX)))
		EndIf

		If ( cStack == NIL )
			_SetOwnerPrvt(Trim(FieldName(nX)),cCpo)
		Else
			_SetNamedPrvt(Trim(FieldName(nX)),cCpo, cStack)
		EndIf
	Next nX
EndIf
RestArea(aAreaSX3)
RestArea(aArea)
Return(Nil)



//-------------------------------------------------------------------
/*/{Protheus.doc} F050ImpCon()

@author  Sivaldo Oliveira
@since 07/11/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function F050ImpCon(nOper As Numeric)

    Local nY As Numeric
    Local nImpConf As Numeric
    Local aImpConf As Array

    Default nOper := 0

    //Inicializa a variável
    nY := 0
    nImpConf := 0
    aImpConf := {}

    //Verifica quais os impostos configurados
    If nOper == 3 //Inclusao
        aImpConf := FinImpConf("1", cFilAnt, M->E2_FORNECE, M->E2_LOJA, M->E2_NATUREZ)
    Else
        aImpConf := FinImpConf("1", cFilAnt, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ)
    EndIf

    nImpConf := Len(aImpConf)

    For nY := 1 To nImpConf
        Do Case
            Case aImpConf[nY,1] $ "PIS|COF|CSL"
                __lPccMR := .T.
            Case aImpConf[nY,1] == "IRF"
                __lIrfMR := .T.
            Case aImpConf[nY,1] == "INSS"
                __lInsMR := .T.
            Case aImpConf[nY,1] == "ISS"
                __lIssMR := .T.
            Case aImpConf[nY,1] == "CIDE"
                __lCidMR := .T.
            Case aImpConf[nY,1] == "SEST"
                __lSestMR := .T.
            OtherWise
                __lOtImpMR := .T.
        EndCase
    Next nY

Return Nil
