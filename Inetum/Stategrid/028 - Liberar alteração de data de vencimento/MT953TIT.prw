#INCLUDE "PROTHEUS.CH"
#INCLUDE "Rwmake.ch"
#INCLUDE "TopConn.ch"       

#DEFINE CRLF Chr(13)+Chr(10)

User Function MT953TIT()

Local lTitulo     := PARAMIXB[1]
Local cImposto    := PARAMIXB[2]
Local cImp        := PARAMIXB[3]
Local cLcPadTit   := PARAMIXB[4]
Local dDtIni      := PARAMIXB[5]
Local dDtFim      := PARAMIXB[6]
Local dDtVenc     := PARAMIXB[7]
Local nMoedTit    := PARAMIXB[8]
Local lGuiaRec    := PARAMIXB[9]
Local nMes        := PARAMIXB[10]
Local nAno        := PARAMIXB[11]
Local lContab     := PARAMIXB[12]
Local aGNREST     := PARAMIXB[13]
Local cOrgArrec   := PARAMIXB[16]
Local nValGuiaSF6 := PARAMIXB[17]
Local nVlrTitulo  := aCols7[2][3]
Local nGerTitDifal := MV_PAR17
Local cNumero	  := ""
Local aTitulo	  := {}
Local aGNRE       := {}
Local aRecTit     := {}
Local aTitCDH     := {}
Local lConfTit	  := .F.
Local lInfComp    := .F.
Local nRecTit     := 0
Local cNumero2    := ""
Local aReturn     := {}
Local cQuery      := ""
Local cAlias      := GetNextAlias()
Local cAliasZ7    := GetNextAlias()
Local aCCustos    := GetCCustos()
Local aDados      := {}
Local nJuros      := 0
Local nMulta      := 0
Local nI


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o titulo do ICMS Normal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nRecTit := Len(aRecTit)
lConfTit:= .F.

IF lTitulo

    GravaTit(lTitulo,nValGuiaSF6,cImposto,cImp,cLcPadTit,dDtIni,dDtFim,dDtVenc,nMoedTit,lGuiaRec,nMes,nAno, nValGuiaSf6,;
        0,"MATA953",lContab,@cNumero,@aGNRE,,,,,,,,@aRecTit,@lConfTit)

    If nRecTit <> Len(aRecTit)	
        aRecTit[Len(aRecTit)][02] := "Apuração do ICMS - ICMS Normal"		
        dbSelectArea("SE2")	
        MsGoto(aRecTit[Len(aRecTit)][01])
        
        MsgInfo("Gerado Título de ICMS Normal: " + SE2->E2_NUM + CRLF +;
                "Valor: " + TransForm(SE2->E2_VALOR, "@E 99,999,999.99") + CRLF +;
                "Centro de Custo: " + SE2->E2_CCD + CRLF +;
                "Tipo de Operação: " + SE2->E2_ITEMD, "")
        
        U_TOTVSANEXO(cEmpAnt,cFilAnt,"FIN",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+ALLTRIM(E2_FORNECE)) )

        //Chamar função de envio de workflow
        U_STAA008()

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
        //³Array com os dados dos titulos gerados, para gravação no CDH                                                  ³	
        //³deve estar no seguinte formato: {E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,"IC" ou "ST","Descr"}³	
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
        AADD(aTitCDH,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"IC","Apuração do ICMS - ICMS Normal"})
    Endif

    If nVlrTitulo>0 .And. lConfTit
        
        AADD(aTitulo,{"TIT",cNumero+" "+Dtoc(dDtVenc)+" "+cOrgArrec,nVlrTitulo})

    Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o titulo do ICMS Difal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nRecTit := Len(aRecTit)
lConfTit:= .F.

If nGerTitDifal == 1 // Se o Parametro "Gera título de ICMS complementar" estiver como SIM (1)
    lTitDifal := .T.
else
    lTitDifal := .F.
Endif

If nVlrTitulo > 0 .AND. lTitDifal

    cQuery := " SELECT SUBSTRING(D1_EMISSAO,1,6) COMPET, D1_CC, SUM(D1_ICMSCOM) DIFAL"
    cQuery += " FROM "+RetSqlName("SD1")+" (NOLOCK) D1 LEFT JOIN "+RetSqlName("SF4")+" (NOLOCK) F4 ON (D1_TES = F4_CODIGO)"
    cQuery += " WHERE D1.D_E_L_E_T_ = ' '"
    cQuery += "   AND F4.D_E_L_E_T_ = ' '"
    cQuery += "   AND D1.D1_FILIAL  = '"+xFilial("SD1")+"'"
    cQuery += "   AND D1.D1_DTDIGIT BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"'"
    cQuery += "   AND D1.D1_ICMSCOM > 0"
    cQuery += " GROUP BY SUBSTRING(D1_EMISSAO,1,6), D1_CC"

    If Select(cAlias) > 0
        DbselectArea(cAlias)
        (cAlias)->(DbcloseArea())
    EndIf

    DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), cAlias, .F., .T.)

    While (cAlias)->(!Eof())

        nPosCC  := AScan(aCCustos, {|x| AllTrim(x[1]) == AllTrim((cAlias)->D1_CC)})
        nPos    := AScan(aDados, {|x| AllTrim(x[1]) == aCCustos[nPosCC][2]+"|"+(cAlias)->COMPET})

        If nPos = 0
            Aadd(aDados, {aCCustos[nPosCC][2]+"|"+(cAlias)->COMPET,aCCustos[nPosCC][2],(cAlias)->DIFAL})
        Else
            aDados[nPos][3] += (cAlias)->DIFAL
        EndIf

        (cAlias)->(DBSkip())
    EndDo

    For nI := 1 To Len(aDados)

        cQuery := " SELECT Z7_TPOPER, Z7_DEBITO, Z7_NACIONA, Z7_ORCAMEN"
        cQuery += " FROM "+RetSqlName("SZ7")+" (NOLOCK) Z7"
        cQuery += " WHERE Z7.D_E_L_E_T_ = ' '"
        cQuery += "   AND Z7.Z7_NATUREZ = '413026'"
        cQuery += "   AND Z7.Z7_CC      = '"+aDados[nI][2]+"'"

        If Select(cAliasZ7) > 0
            DbselectArea(cAliasZ7)
            (cAliasZ7)->(DbcloseArea())
        EndIf

        DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), cAliasZ7, .F., .T.)
        
        nJuros  := 0
        nMulta  := 0

        JurosMulta(@nJuros, @nMulta, aDados[nI], @dDtVenc)

        xGravaTit(lTitDifal,aDados[nI][3],cImposto,cImp,cLcPadTit,dDtIni,dDtFim,dDtVenc,nMoedTit,lGuiaRec,nMes,nAno, nValGuiaSf6,;
                0,"MATA953",lContab,@cNumero,@aGNRE,,,,,,,,@aRecTit,@lConfTit,,,,,,,,,,,,,,,,,,,,,,,,,aDados[nI][2],;
                (cAliasZ7)->Z7_TPOPER, (cAliasZ7)->Z7_DEBITO, (cAliasZ7)->Z7_NACIONA, (cAliasZ7)->Z7_ORCAMEN, nJuros, nMulta, aDados[nI])

        (cAliasZ7)->(DbcloseArea())
        
        If nRecTit <> Len(aRecTit)
            aRecTit[Len(aRecTit)][02] := "Apuração do ICMS - ICMS Difal"
            dbSelectArea("SE2")
            MsGoto(aRecTit[Len(aRecTit)][01])
            
            MsgInfo("Gerado Título de ICMS Difal: " + SE2->E2_NUM + CRLF +;
                    "Valor: " + TransForm(SE2->E2_VALOR, "@E 99,999,999.99") + CRLF +;
                    "Centro de Custo: " + SE2->E2_CCD + CRLF +;
                    "Tipo de Operação: " + SE2->E2_ITEMD, "")
	
            U_TOTVSANEXO(cEmpAnt,cFilAnt,"FIN",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+ALLTRIM(E2_FORNECE)) )

            //Chamar função de envio de workflow
            U_STAA008()

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
            //³Array com os dados dos titulos gerados, para gravação no CDH                                                  ³	
            //³deve estar no seguinte formato: {E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,"IC" ou "ST","Descr"}³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            AADD(aTitCDH,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"IC","Apuração do ICMS - ICMS Normal"})
        Endif

        If lTitDifal .And. nVlrTitulo>0 .And. lConfTit
            AADD(aTitulo,{"TIT",cNumero+" "+Dtoc(dDtVenc)+" "+cOrgArrec,nVlrTitulo})
        Endif

        (cAlias)->(!DBSkip())
    Next nI

    (cAlias)->(DbcloseArea())

/*
    xGravaTit(lTitulo,nVlrTitulo,cImposto,cImp,cLcPadTit,dDtIni,dDtFim,dDtVenc,nMoedTit,lGuiaRec,nMes,nAno, nValGuiaSf6,;
            0,"MATA953",lContab,@cNumero,@aGNRE,,,,,,,,@aRecTit,@lConfTit,cCentroCusto)
            
    If nRecTit <> Len(aRecTit)
        aRecTit[Len(aRecTit)][02] := "Apuração do ICMS - ICMS Normal"
        dbSelectArea("SE2")
        MsGoto(aRecTit[Len(aRecTit)][01])	
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
        //³Array com os dados dos titulos gerados, para gravação no CDH                                                  ³	
        //³deve estar no seguinte formato: {E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,"IC" ou "ST","Descr"}³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        AADD(aTitCDH,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"IC","Apuração do ICMS - ICMS Normal"})
    Endif

    If lTitulo .And. nVlrTitulo>0 .And. lConfTit
        AADD(aTitulo,{"TIT",cNumero+" "+Dtoc(dDtVenc)+" "+cOrgArrec,nVlrTitulo})
    Endif
*/
    aReturn:= {cNumero,aGNRE,aGNREST,aTitulo,lInfComp,cNumero2,aTitCDH }

EndIf

Return(aReturn)

Static Function xGravaTit(lTitulo,;
				nVlrTitulo,;
				cImposto,;
				cImp,;
				cLcPadTit,;		//5
				dDtIni,;
				dDtFim,;
				dDtVenc,;
				nMoedTit,;
				lGuiaRec,;      //10
				nMes,;
				nAno,;
				nTitICMS,;
				nTitST,;
				cOrigem,;		//15
				lContab,;
				cNumero,;
				aGnre,;
				cClasse,;
				aGNREST,;		//20
				cUF,;
				cCodRetIPI,;
				lFECP,;
				lDifAlq,;
				cNumGnre,;		//25
				aRecTit,;
				lConfTit,;
				nTitFun,;
				aDadSf2,;
				lArt65,; 		//30
				cOriGNRE,;
				aApIncent,;
				cCodGnre,;
				nGuiaSN,;
				nConv139,;	 // 35
				lGTitFluig,; //Parametros utilizados para a experiencia 3 ( WorkFlow - Fiscal )
				cNrLivro,;   //Parametros utilizados para a experiencia 3 ( WorkFlow - Fiscal )
				nApuracao,;  //Parametros utilizados para a experiencia 3 ( WorkFlow - Fiscal )
				nPeriodo,;   //Parametros utilizados para a experiencia 3 ( WorkFlow - Fiscal )
				nNumSolFlg,; //Parametros utilizados para a experiencia 3 ( WorkFlow - Fiscal ) //40
				cForIss,;
				cLojISS,; // 42
				lDifal,;
				lAntParcBA,;
				cNumConv,; // 45
				lAutomato,;
				aRetAuto,;
				cCodMunRec,; // 48
				cTpImp,;
				cNatureza,;
				cObserv,; // 51
                cCentroCusto,;
                cTipoOper,;
                cDebito,;
                cCredito,;
                cCtaOrc,;
                nJuros,;
                nMulta,;
                aDados)

LOCAL cTipo     := ""
LOCAL cGetMv1   := ""
LOCAL cGetMv2   := ""
LOCAL cPrefixo  := ""
Local cPrefPar  := ""
LOCAL dVencReal := ""
LOCAL cHistorico:= ""
Local nX        := 0
Local nJ		:= 0
Local cFornece	:= ""
Local cInsc		:= ""
Local lGerTit	:= .T.
Local cMVESTADO := SuperGetMV("MV_ESTADO")
Local cApICMP	:= SuperGetMv("MV_APICMP") //Natureza do Titulo de ICMS Complementar.
Local cApFECP	:= SuperGetMv("MV_APFECP") //Natureza do Titulo de FECP.
Local cApFunder	:= GetNewPar ("MV_APFUNDS","")	//Natureza do Titulo do Fundersul
Local cApSenar  := GetNewPar ("MV_APSENAR","")	//Natureza do Titulo do Senar
Local cApSNac	:= GetNewPar ("MV_APSINAC","")	//Natureza do Titulo do Simples Nacional
Local cMunic	:= GetNewPar ("MV_MUNIC","")	//Fornecedor dos titulos de ISS
Local cApICMST	:= GetNewPar ("MV_APICMST","")	//Natureza do Titulo do Simples Nacional
Local lFumacop	:= cMVESTADO == "MA" .And. SB1->B1_ALFUMAC <> 0 //FUMACOP
Local cGNRInfC	:= ""
Local cFornST	:= ""
Local cLojaST	:= ""
Local nTamForn	:= TamSX3("A2_COD")[1]
Local nTamLoja	:= TamSX3("A2_LOJA")[1]
Local nTamNF 	:= TamSX3("F2_DOC")[1]
Local aSvRot	:= Nil
Local lGravaSF6 := .F.
Local aCamps		:= {}
Local aCampAt		:= {}
Local lMVLEGM953	:= GetNewPar ("MV_LEGM953",.F.)
Local lNgnreNf		:= GetNewPar("MV_GNRENF",.F.)
Local nVFecpST 		:= 0
Local nVlrConv 		:= 0
Local cApProtege	:= GetNewPar ("MV_PROTEGE","")//Natureza do Titulo de PROTEGE - GO.
Local nPos := 0
Local nPosGNRE 		:= 0
Local cTipoDoc		:= "  "
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSED		:= SED->(GetArea())
Local aAreaSE2		:= SE2->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local cFilSF1	    := ""
Local nTamASF6		:= 0
Local aCposAut		:= {}
Local aInfoFluig     := {}
Local lGerSolFlg     := .T.
Local aFornGNRE := {}
Local cGNRImp 		:= ""
Local cMVDATAVNC 	:= GetNewPar("MV_DATAVNC","")
Local nMVDATAVNC	:= Iif(!Empty(cMVDATAVNC),VAL(cMVDATAVNC),-1)
Local dVenParBA := cToD("//")
Local lBlqEdtNr := .F.
Local aCmpAlt := {}
Local aAuto 		:= {}
Local cCNPJ := ""
Local aAreaSA1   := SA1->( GetArea () )
Local cApFEEF    := GetNewPar ("MV_FEEFRJ","")//Natureza do Titulo de FEEF-RJ
Local cFilSx5    := xFilial("SX5")
Local lCPAPUICMS := ExistBlock("CPAPUICMS")
Local lTITICMST  := ExistBlock("TITICMST")
Local lINFOGNRE  := ExistBlock("INFOGNRE")


DEFAULT dDtIni     := cToD("//")
DEFAULT dDtFim     := cToD("//")
DEFAULT cCodGnre   := ""
DEFAULT cClasse    := space(06)
DEFAULT aGNREST    := {}
DEFAULT cUF        := SuperGetMV("MV_ESTADO")
DEFAULT cCodRetIPI := ""
DEFAULT lFECP      := .F.
DEFAULT lDifAlq    := .F.
DEFAULT cNumGnre   := Space (TamSx3("F6_NUMERO")[1])
DEFAULT aRecTit    := {}
DEFAULT aDadSf2    := {}
DEFAULT lConfTit   := .F.
DEFAULT lContab    := .F.
DEFAULT nTitFun    := 0
DEFAULT lArt65     := .F.
DEFAULT cOriGNRE   := "RECSALDO"
DEFAULT aApIncent  := {}
DEFAULT nGuiaSN    := 0
DEFAULT nConv139   := 0
DEFAULT lGTitFluig := .F.
DEFAULT cForIss    := ""
DEFAULT cLojISS    := ""
DEFAULT lDifal     := .F.
DEFAULT lAntParcBA := .F.
DEFAULT cNumConv   := Space (TamSx3("F6_NUMCONV")[1])
DEFAULT lAutomato  := .F.
DEFAULT aRetAuto   := {}
DEFAULT cCodMunRec := ""
DEFAULT cTpImp     := ""
DEFAULT cNatureza  := ""
DEFAULT cObserv    := ""

PRIVATE cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") //Guia de Recolhimento
PRIVATE lRefresh  := .T.
PRIVATE Inclui    := .T.

    //Abertura de tabelas (set do indice utilizado na funcao)
    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    DbSelectArea("SED")
    SED->(DbSetOrder(1))
    DbSelectArea("SE2")
    SE2->(DbSetOrder(1))
    DbSelectArea("SX5")
    SX5->(DbSetOrder(1))
    DbSelectArea("CE1")
    CE1->(DbSetOrder(1))
    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Nao gero titulo para quando apuracao de IPI tiver um valor de debito inferior ao informado no parametro.³
    //³Neste momento o valor minimo de he R$ 10,00 para o estado de Sao Paulo - Lei 9.430/96, art 68.          ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lTitulo .And. !(GeraLinhaApur (nVlrTitulo, cOrigem))
        nVlrTitulo := 0
    EndIf

    //Tratamento para notas Emitidas pelo faturamento considerar parametro MV_DATAVNC para determinar
    //quantidade de dias uteis para data de vencimento do titulo e GNRE de Difal e ICMS ST
    IF cOrigem == "MATA460A" .And. nMVDATAVNC >= 0 .And. (lDifal .Or. nTitST > 0)
        dDtVenc := SomaData(nMVDATAVNC,dDatabase)
    Endif

    //Tratamento para título e guia de recolhimento de Antecipacao Parcial - BA.
    //O recolhimento poderá ser efetuado até o dia 25 do mês subsequente ao da entrada da mercadoria.
    If cOrigem == "MATA103" .And. lAntParcBA .And. nTitST > 0
        dVenParBA := cToD("25" + "/" + cValtoChar(Month(dDtvenc)) + "/" + cValtoChar(Year(dDtvenc)))
        dDtvenc := DataValida(dVenParBA, .T.)
    EndIf

    //Em situacoes de geracao de titulo/GNRE de ICMS-ST sera verificado se o contribuinte tem IE
    //na UF do recolhimento. Essa verificacao sera feita pelo MV_SUBTRIB.
    If cOrigem == "MATA953"
        If nTitST > 0
            nVlrTitulo := nTitST

            //Tratamento para permitir que indepdendente do SUBTRIB, as operacoes internas com ST gerem a GNRE
            //normalmente; mesmo que não tenha a inscricao no subtrib mais tenha a IE no SIGAMAT.
            //Este tratamento é para manter o legado que nao obrigava o contribuinte a informar a IE do estado domiciliado no SUBTRIB
            If lMVLEGM953 .And. cUF==cMVESTADO .And. !Empty(SM0->M0_INSC)
                cInsc := SM0->M0_INSC
            Else
                IF cUF==cMVESTADO //Gera guia ede ICMS proprio com inscricao do contribuinte no SIGAMAT
                    cInsc := SM0->M0_INSC
                Else
                    cInsc := IESubTrib(cUf,lDifal)
                endif
            Endif

            If Empty(cInsc)
                //Tratamento para acordo entre os estados preenchidos no parametro MV_STNIEUF, quando em
                //um movimento com ICMS-ST nao e' necessario ter incscricao estadual, assim esse tratamento
                //retorna a incricao " " para gerar a guia de recolhimento para o estado destino
                //Este tratamento foi feit a partir da necessidade das UF de MG p/ PR,onde existe esse acordo
                //PROTOCOLO ICMS CONSELHO NACIONAL DE POLÍTICA FAZENDÁRIA - CONFAZ Nº 191 DE 11.12.2009
                If !(AllTrim(cMVESTADO+cUF)$AllTrim(SUPERGETMV("MV_STNIEUF",.F.,"")))
                    Return .F.
                EndIf
            EndIf
        Else
            //Gera guia ede ICMS proprio com inscricao do contribuinte no SIGAMAT
            cInsc := SM0->M0_INSC
        EndIf
    EndIf

    //ByPass quando nao deve gerar titulo
    If lTitulo .and. nVlrTitulo > 0

        //Dados do Titulo
        Do Case
            Case cImp=="IC"
                cPrefixo:= "ICM"
                cGetMv1 := SuperGetMv("MV_ICMS",.F.,"ICMS")
                cGetMv2 := SuperGetMV("MV_RECEST")

                //Verifica se existe o parametro para o fornecedor padrao por estado - ST
                cFornST := ""
                cLojaST := ""
                aFornGNRE := StrToKarr(cGetMv2, ";") 
                If Len(aFornGNRE) >= 2
                    cFornST := PadR(aFornGNRE[1], nTamForn)
                    cLojaST := PadR(aFornGNRE[2], nTamLoja)
                    //	Ajusto a variavel para que seja usada no seek logo abaixo
                    cGetMv2 := cFornSt + cLojaSt
                EndIf
                If cMVESTADO <> cUF
                    cGetMv2 := '"MV_RECST' + cUF + '"'
                    cGetMv2 := SuperGetMv(&cGetMv2)

                    aFornGNRE := StrToKarr(cGetMv2, ";")

                    If Len(aFornGNRE) >= 2
                        cFornST := PadR(aFornGNRE[1], nTamForn)
                        cLojaST := PadR(aFornGNRE[2], nTamLoja)
                    EndIf

                    //	Ajusto a variavel para que seja usada no seek logo abaixo
                    cGetMv2 := cFornSt + cLojaSt
                EndIf
                //Natureza do Titulo de ICMS ST
                If nTitST <> 0 .And. !Empty (cApICMST)
                    cGetMv1 := cApICMST
                Endif

                //Natureza do Titulo de FECP.
                If (lFECP) .And. !Empty (cApFECP)
                    cGetMv1 := cApFECP

                //Natureza do Titulo de ICMS Complementar.
                ElseIf (lDifAlq) .And. !Empty (cApICMP)
                    cGetMv1 := cApICMP
                EndIf

                If Len(aApIncent) > 0
                    cPrefixo:= Iif ( aApIncent[6] <> Nil, aApIncent[6], cPrefixo )
                    cGetMv1 := Iif ( aApIncent[7] <> Nil, aApIncent[7], cGetMv1 )
                    cGetMv2 := SuperGetMV("MV_RECEST")
                Endif

            Case cImp=="IP" .Or. cImp=="SI"
                cPrefixo:= "IPI"
                cGetMv1 := SuperGetMv("MV_IPI")
                cGetMv2 := SuperGetMv("MV_UNIAO")
            Case cImp=="IS"
                cPrefixo := "ISS"

                // Atribui fornecedor do titulo com base na apuração de ISS
                If !(Empty(cForIss))
                    cMunic := cForIss
                EndIf

                // Atribui loja do titulo com base na apuração de ISS
                If !(Empty(cLojISS))
                    cMunic += cLojISS
                EndIf

                // Natureza alternativa para o titulo a pagar de ISS
                If SuperGetMv("MV_APURISS") == ""
                    cGetMv1 := &(SuperGetMv("MV_ISS"))
                Else
                    cGetMv1 := SuperGetMv("MV_APURISS")
                Endif
                If Empty(cMunic)
                    cGetMv2 := SUBS("MUNICIPIO",1,TAMSX3("A2_COD")[1])
                Else
                    cGetMv2 := cMunic
                Endif
            Case cImp=="FD"
                cGetMv1		:=	Iif(!Empty(cApFunder),cApFunder,GetNewPar("MV_ICMS","ICMS")) 
                cGetMv2		:=	GetMv("MV_RECEST")
                cPrefixo	:=	"FDS"
            Case cImp=="SE"
                cGetMv1		:=	Iif(!Empty(cApSenar),cApSenar,GetNewPar("MV_ICMS","ICMS")) 
                cGetMv2		:=	GetMv("MV_UNIAO")
                cPrefixo	:=	"SEN"
            Case cImp=="SN"
                cGetMv1		:=	Iif(!Empty(cApSNac),cApSNac,GetNewPar("MV_ICMS","ICMS")) 
                cGetMv2		:=	GetMv("MV_RECEST")
                cPrefixo	:=	"SPN"
            Case cImp=="PR"
                cGetMv1		:=	Iif(!Empty(cApProtege),cApProtege,GetNewPar("MV_ICMS","ICMS")) 
                cGetMv2		:=	GetMv("MV_RECEST")
                cPrefixo	:=	"PTG"
            Case cImp=="FEEF"
                cGetMv1		:=	Iif(!Empty(cApFEEF),cApFEEF,GetNewPar("MV_ICMS","ICMS")) 
                cGetMv2		:=	GetMv("MV_RECEST")
                cPrefixo	:=	"FEE"
        EndCase

        cTipo := "TX"+Space(TamSx3("E2_TIPO")[1]-2)

        If Empty(cNatureza)
            cNatureza := cGetMv1
        EndIf

        If Empty(cFornST)
            cFornece  := cGetMv2
        Else
            cFornece  := cFornST
        Endif

        cFornece  := Padr(cFornece,Len(SE2->E2_FORNECE))
        dVencReal := dDtVenc

        If (cOrigem == "MATA953" .Or. cOrigem == "MATA952") .AND. Empty(cObserv)
            cHistorico := cImposto+": "+DtoC(dDtIni)+" A "+Dtoc(dDtFim)
        Else
            cHistorico := cObserv
        Endif

        //Determina lancamento automatico
        cLA := IIf(VerPadrao(cLcPadTit),"S","N")

        //Nao gera o titulo de ST de outros estados se nao existir o parametro/fornecedor³
        If cImp == "IC" .And. cMVESTADO <> cUF .And. (Empty(cGetMv2) .Or. SA2->(!dbSeek(xFilial("SA2")+cGetMv2)))
            If Empty(cGetMv2)
                Alert("O parametro MV_RECEST está vazio."+Chr(13)+Chr(10)+"Favor entrar em contato com a TI.")
            ElseIf SA2->(!dbSeek(xFilial()+cGetMv2))
                Alert("O Fornecedor informado no parametro MV_RECEST não foi encontrado.")
            EndIf
            lGerTit := .F.
        Endif

        If lGerTit

            //Grava a informação de que o estado gerou o titulo
            If cMVESTADO <> cUF .And. cOrigem == "MATA953"
                nX := aScan(aGNREST,{|x| x[1]==cUF})
                IF nX > 0 .And. !lGTitFluig
                    aGNREST[nX][03] := .T.
                EndiF
            Endif

            Begin Transaction

                //Numero do Titulo a ser gerado
                If SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumero := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                    //RecLock("SX5",.F.)

                    //Cria o fornecedor, caso nao exista
                    IF (cGetMv2 == SuperGetMv("MV_MUNIC"))
                        cGetMv2 := SuperGetMv("MV_MUNIC")
                    ENDIF
                    If SA2->(!dbSeek(xFilial()+cGetMv2))
                        Reclock("SA2",.T.)
                        SA2->A2_FILIAL := xFilial("SA2")
                        If Empty(cFornST)
                            SA2->A2_COD  := cGetMv2
                        Else
                            SA2->A2_COD  := cFornST
                        Endif
                        If Empty(cLojaST)
                            SA2->A2_LOJA := "00"
                        Else
                            SA2->A2_LOJA := cLojaST
                        Endif
                        SA2->A2_BAIRRO := "."
                        SA2->A2_MUN    := "."
                        SA2->A2_EST    := cMVESTADO
                        SA2->A2_END    := "."
                        Do Case
                            Case cImp=="IC" .Or. cImp=="FD"
                                SA2->A2_NOME 	:= "RECEITA ESTADUAL"
                                SA2->A2_NREDUZ	:= "ESTADO"
                            Case cImp=="IP" .Or. cImp=="SI" .Or. cImp=="SN"
                                SA2->A2_NOME 	:= "UNIAO"
                                SA2->A2_NREDUZ	:= "UNIAO"
                            Case cImp=="IS"
                                SA2->A2_NOME	:= "MUNICIPIO"
                                SA2->A2_NREDUZ	:= "MUNICIPIO"
                        EndCase
                        MsUnlock()
                        SA2->(FKCommit())
                    EndIF

                    //Cria a natureza ICMS caso nao exista
                    If SED->(!dbSeek(xFilial("SED")+cGetMv1))
                        RecLock("SED",.T.)
                        SED->ED_FILIAL  := xFilial()
                        SED->ED_CODIGO  := cGetMv1
                        SED->ED_CALCIRF := "N"
                        SED->ED_CALCISS := "N"
                        SED->ED_DESCRIC := cImposto
                        MsUnlock()
                        SED->(FKCommit())
                    EndIf

                    //Converte valor do Titulo
                    nVlrConv := xMoeda(nVlrTitulo,1,nMoedTit,dDataBase)

                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Verifica se existem parametros para definicao do prefixo ³
                    //³ Apenas para títulos gerados via apuração.                ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    If cOrigem == "MATA953" .Or. cOrigem == "MATA952"
                        Do Case
                        Case cImp=="IC"
                            If !Empty( cPrefPar := &( GetNewPar( "MV_PFAPUIC", "" ) ) )
                                cPrefPar := Iif(substr(cPrefPar,1,1)=='"',&(cPrefPar),cPrefPar)
                                cPrefixo := cPrefPar
                            EndIf
                        Case cImp=="IP"
                            If !Empty( cPrefPar := &( SuperGetMV( "MV_PFAPUIP" ) ) )
                                cPrefixo := cPrefPar
                            EndIf
                        Case cImp=="IS"
                            If !Empty( cPrefPar := &( SuperGetMV( "MV_PFAPUIS" ) ) )
                                cPrefixo := cPrefPar
                            EndIf
                        Case cImp=="SI"
                            If !Empty( cPrefPar := &( SuperGetMV( "MV_PFAPUSF" ) ) )
                                cPrefixo := cPrefPar
                            EndIf
                        Case cImp=="FD"
                            If !Empty( cPrefPar := &( GetNewPar( "MV_PFAPUFD","" ) ) )
                                cPrefixo := cPrefPar
                            EndIf
                        Case cImp=="SE"
                            If !Empty( cPrefPar := &( GetNewPar( "MV_PFSENAR","" ) ) )
                                cPrefixo := cPrefPar
                            EndIf
                        Case cImp=="SN"
                            If !Empty( cPrefPar := &( GetNewPar( "MV_PFAPUSN","" ) ) )
                                cPrefixo := cPrefPar
                            EndIf
                        EndCase
                    EndIf

                    If SE2->(!dbSeek(xFilial("SE2")+cPrefixo+Iif(cOrigem == "MATA103", aDadSf2[1][1] ,cNumero)+Space(Len(SE2->E2_PARCELA))+cTipo+cFornece+SA2->A2_LOJA))

                        //Caso utilize o Fluig nao sera gerado o titulo neste momento, apenas serao
                        //gravadas as informacoes na tabela CH3 e apos a confirmacao da solicitacao no FLUIG
                        //o titulo sera gerado
                        If lGTitFluig

                            //Funcao para gravar as informacoes para posterior processamento da apuracao
                            Aadd( aInfoFluig, { cNumero,;
                                                cPrefixo,;
                                                cTipo,;
                                                cNatureza,;
                                                cFornece,;
                                                SA2->A2_LOJA,;
                                                SA2->A2_NREDUZ,;
                                                nMoedTit,;
                                                nVlrConv,;
                                                cHistorico,;
                                                cLA,;
                                                dDataBase,;
                                                dVencReal,;
                                                cOrigem,;
                                                cFilAnt,;
                                                Iif( cImp == "IP" .and. len(cCodRetIPI) == 4, cCodRetIPI, "" ),;
                                                lContab } )
                        Else
                            nPos  := At("|", aDados[1])

                            RecLock("SE2",.T.)
                            SE2->E2_FILIAL     := xFilial("SE2")
                            SE2->E2_NUM        := Iif(cOrigem == "MATA103", aDadSf2[1][1] ,cNumero)
                            SE2->E2_PREFIXO    := cPrefixo
                            SE2->E2_TIPO       := cTipo
                            SE2->E2_NATUREZ    := cNatureza
                            SE2->E2_FORNECE    := cFornece
                            SE2->E2_LOJA       := SA2->A2_LOJA
                            SE2->E2_NOMFOR     := SA2->A2_NREDUZ
                            SE2->E2_MOEDA      := nMoedTit
                            SE2->E2_VALOR      := nVlrConv
                            SE2->E2_SALDO      := nVlrConv
                            SE2->E2_VLCRUZ     := nVlrConv
                            SE2->E2_HIST       := cHistorico+' C: '+Substr(aDados[1], nPos + 5, 2) + "/" + Substr(aDados[1], nPos + 1, 4) 
                            SE2->E2_LA         := cLA
                            SE2->E2_EMISSAO    := dDataBase//iif(Empty(dDtEmiIPI),dDataBase,dDtEmiIPI)
                            SE2->E2_VENCTO     := dVencReal
                            SE2->E2_VENCREA    := DataValida(dVencReal,.T.)
                            SE2->E2_VENCORI    := dVencReal
                            SE2->E2_EMIS1      := dDataBase
                            SE2->E2_ORIGEM     := cOrigem
                            SE2->E2_FILORIG    := cFilAnt
                            SE2->E2_CCD        := cCentroCusto
                            SE2->E2_CCC        := cCentroCusto
                            SE2->E2_ITEMC      := cTipoOper
                            SE2->E2_ITEMD      := cTipoOper
                            SE2->E2_DEBITO     := cDebito
                            SE2->E2_CREDIT     := cCredito
                            SE2->E2_XCO        := cCtaOrc
                            SE2->E2_XOBS       := 'APURACAO ICMS DIFAL '+cHistorico+' COMP: '+Substr(aDados[1], nPos + 5, 2) + "/" + Substr(aDados[1], nPos + 1, 4) 
                            SE2->E2_XMULTA     := nMulta
                            SE2->E2_XJUR       := nJuros

                            If cImp == "IP" .and. len(cCodRetIPI) == 4
                                SE2->E2_CODRET := cCodRetIPI
                            EndIf

                            If cOrigem == "MATA103" .And. Alltrim(cTipo) == Alltrim(MVTAXA) .And. !lGTitFluig
                                dbSelectArea("SF1")
                                SF1->(dbSetOrder(1))
                                cFilSF1	:= xFilial("SF1")
                                If SF1->(MsSeek(cFilSF1+aDadSf2[1][1]+aDadSf2[1][2]+aDadSf2[1][3]+aDadSf2[1][4]))
                                    RecLock("SF1",.F.)
                                    SF1->F1_NUMTRIB := aDadSf2[1][1]
                                EndIf
                            EndIf
                        EndIf
                    Else
                        //Realiza a busca de um Numero de Titulo ainda nao usado
                        While SE2->(dbSeek(xFilial("SE2")+cPrefixo+cNumero+Space(Len(SE2->E2_PARCELA))+cTipo+cFornece+SA2->A2_LOJA))
                            cNumero := Soma1(cNumero)
                        EndDo

                        //Caso utilize o Fluig nao sera gerado o titulo neste momento, apenas serao
                        //gravadas as informacoes na tabela CH3 e apos a confirmacao da solicitacao no FLUIG
                        //o titulo sera gerado
                        If lGTitFluig

                            //Funcao para gravar as informacoes para posterior processamento da apuracao
                            Aadd( aInfoFluig, { cNumero,;
                                                cPrefixo,;
                                                cTipo,;
                                                cNatureza,;
                                                cFornece,;
                                                SA2->A2_LOJA,;
                                                SA2->A2_NREDUZ,;
                                                nMoedTit,;
                                                nVlrConv,;
                                                cHistorico,;
                                                cLA,;
                                                dDataBase,;
                                                dVencReal,;
                                                cOrigem,;
                                                cFilAnt,;
                                                Iif( cImp == "IP" .and. len(cCodRetIPI) == 4, cCodRetIPI, "" ),;
                                                lContab } )

                        Else

                            nPos  := At("|", aDados[1])

                            RecLock("SE2",.T.)
                            SE2->E2_FILIAL     := xFilial("SE2")
                            SE2->E2_NUM        := cNumero
                            SE2->E2_PREFIXO    := cPrefixo
                            SE2->E2_TIPO       := cTipo
                            SE2->E2_NATUREZ    := cNatureza
                            SE2->E2_FORNECE    := cFornece
                            SE2->E2_LOJA       := SA2->A2_LOJA
                            SE2->E2_NOMFOR     := SA2->A2_NREDUZ
                            SE2->E2_MOEDA      := nMoedTit
                            SE2->E2_VALOR      := nVlrConv
                            SE2->E2_SALDO      := nVlrConv
                            SE2->E2_VLCRUZ     := nVlrConv
                            SE2->E2_HIST       := cHistorico+' C: '+Substr(aDados[1], nPos + 5, 2) + "/" + Substr(aDados[1], nPos + 1, 4) 
                            SE2->E2_LA         := cLA
                            SE2->E2_EMISSAO    := dDataBase
                            SE2->E2_VENCTO     := dVencReal
                            SE2->E2_VENCREA    := DataValida(dVencReal,.T.)
                            SE2->E2_DATAAGE    := DataValida(dVencReal,.T.)
                            SE2->E2_VENCORI    := dVencReal
                            SE2->E2_EMIS1      := dDataBase
                            SE2->E2_ORIGEM     := cOrigem
                            SE2->E2_FILORIG    := cFilAnt
                            SE2->E2_CCD        := cCentroCusto
                            SE2->E2_CCC        := cCentroCusto
                            SE2->E2_ITEMC      := cTipoOper
                            SE2->E2_ITEMD      := cTipoOper
                            SE2->E2_DEBITO     := cDebito
                            SE2->E2_CREDIT     := cCredito
                            SE2->E2_XCO        := cCtaOrc
                            SE2->E2_XOBS       := 'APURACAO ICMS DIFAL '+cHistorico+' COMP: '+Substr(aDados[1], nPos + 5, 2) + "/" + Substr(aDados[1], nPos + 1, 4) 
                            SE2->E2_XMULTA     := nMulta
                            SE2->E2_XJUR       := nJuros

                            If cImp == "IP" .and. len(cCodRetIPI) == 4
                                SE2->E2_CODRET := cCodRetIPI
                            EndIf

                            //Se for um titulo de TX, o cliente deve ter executado UPDFIS para
                            //criacao do campo F1_NUMTRIB
                            If cOrigem == "MATA103" .And. Alltrim(cTipo) == Alltrim(MVTAXA) .And. !lGTitFluig
                                dbSelectArea("SF1")
                                SF1->(dbSetOrder(1))
                                cFilSF1	:= xFilial("SF1")
                                If SF1->(MsSeek(cFilSF1+aDadSf2[1][1]+aDadSf2[1][2]+aDadSf2[1][3]+aDadSf2[1][4]))
                                    RecLock("SF1",.F.)
                                    SF1->F1_NUMTRIB := cNumero
                                EndIf
                            EndIf
                        Endif
                    EndIf

                    If !lGTitFluig
                        If lTITICMST
                            //-- As regras abaixo devem ser alteradas conforme da guia de recolhimento (SF6)
                            cTipoImp := "1"
                            If nTitICMS > 0 .And. (cOrigem == "MATA953" .Or. cOrigem == "MATA460A" .Or. cOrigem == "MATA913")
                                cTipoImp  := "1"
                            ElseIf nTitICMS > 0 .And. cOrigem == "MATA954"
                                cTipoImp  := "2"
                            ElseIf nTitFun > 0 .And. cOrigem == "MATA953" .And. cImp == "FD"
                                cTipoImp  := "6"
                            ElseIf nTitFun > 0 .And. cOrigem == "MATA953" .And. cImp == "SE"
                                cTipoImp  := "9"
                            ElseIf nTitFun > 0 .And. cOrigem == "MATA953" .And. cImp == "FU"
                                cTipoImp  := "A"
                            ElseIf nConv139 > 0 .And. cOrigem == "MATA953" .And. Substr(cImp,1,3) == "IC"
                                cTipoImp  := "1"
                            ElseIf nTitFun  > 0 .And. cOrigem == "MATA953" .And. Substr(cImp,1,3) == "IC" .And. Len(aApIncent) > 0
                                cTipoImp  := "1"
                            ElseIf nTitICMS > 0 .And. cOrigem == "MATA924"
                                cTipoImp  := "7"
                            ElseIf nGuiaSN > 0 .And. cOrigem == "MATA924"
                                cTipoImp  := "7"
                            ElseIf nTitST > 0 .And. (cOrigem == "MATA953" .Or. cOrigem == "MATA460A" .Or. cOrigem == "MATA103")
                                If cOrigem $ "MATA460A/MATA953" .And. lDifal .And. (lFECP .Or. lDifAlq)
                                    If lFECP .And. lFumacop
                                        cTipoImp :='A' //FUMACOP
                                    Else
                                        cTipoImp := "B"
                                    EndIf
                                Else
                                    If lAntParcBA
                                        cTipoImp := "0"
                                    Else
                                        cTipoImp := "3"
                                    EndIf
                                EndIf
                            EndIf
                            aTITICMST := ExecBlock("TITICMST", .F., .F., {cOrigem,cTipoImp, lDifal})
                            If aTITICMST<>Nil .And. ValType(aTITICMST)=="A"
                                cNumero := Iif(Len(aTITICMST)>=1,aTITICMST[1],cNumero)
                                dDtVenc := Iif(Len(aTITICMST)>=2,aTITICMST[2],dDtVenc)
                            EndIf
                        EndIf

                        // PE para gravar campos no Contas a Pagar não gravados na apuração (Centro Custo, Item Contábil)
                        If lCPAPUICMS
                            ExecBlock("CPAPUICMS",.F.,.F.,{"SE2"})
                        Endif

                        MsUnlock()

                        // O registro sera utilizado para exibir o titulo gerado no SE2 pelo Mata953
                        Aadd(aRecTit,{SE2->(RecNo()),""})

                        // Indica que todas as condicoes para geracao do titulo foram atendidas e o SE2 foi gerado
                        lConfTit := .T.
                    EndIf

                    //Gravacao do Numero do Titulo no SX5
                    //SX5->X5_DESCRI  := cNumero
                    //SX5->X5_DESCSPA := cNumero
                    //SX5->X5_DESCENG := cNumero
                    //SX5->(MsUnlock())

                    FwPutSX5(, "53", cImposto, cNumero, cNumero, cNumero, )

                    // Uso o numero gravado da tabela.
                    If Empty(cNumGnre) .And. Upper(Alltrim(cImposto)) == "SENAR"
                        cNumGnre := cNumero
                    EndIf

                    If !lGTitFluig
                        //Efetua Lancamento Contabil
                        If lContab
                            LancCont(cLcPadTit,cOrigem,lContab)
                        Endif
                    EndIf

                Endif

            End Transaction

            //Armazena numero e valor do titulo para ser gravado em arquivo texto
            If cOrigem$"MATA951#MATA952#MATA913" .And. !lGTitFluig
                nPos := Ascan(aGetApur,{|x|x[1]="TIT"})
                If nPos > 0
                    aGetApur[nPos,2] := Stuff(aGetApur[nPos,2],1,Len(ALLTRIM(cNumero)),ALLTRIM(cNumero))
                    aGetApur[nPos,3] := nVlrTitulo
                Endif
            EndIf
        Endif
    EndIf

    If lGuiaRec
        nPos:= Len(aDadSf2)

        //-- Guarda variavel Private aRotina. uso AxInclui
        If Type("aRotina") == "A"
            aSvRot := aClone(aRotina)
            Private aRotina := 	{ { " "," ",0,1 } ,{ " "," ",0,2 },{ " "," ",0,3 } }
        EndIf

        dbSelectArea("SF6")

        If cOrigem $ "MATA460A/MATA103"
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Tratamento para que a numeração da GNRE seja obtida da SX5     ³
            //³mesmo se não for configurada geração de título. Quando houve   ³
            //³geracao do titulo o prefixo e o numero já vem preenchidos e    ³
            //³nao poderao ser alterados para nao perdermos a rastreabilidade.³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If cImp == "IC" .And. (!lTitulo .Or. nVlrTitulo <= 0)	
                If SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cPrefixo:= "ICM"
                    cNumero := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                    // Nesta situacao ja preciso atualizar o SX5 pois a sequencia
                    // obtida acima ainda nao foi gravada, visto que nao foi gerado
                    // titulo. Entao vou "reservar" esta numeracao para garantir
                    // que nao seja sugerido o mesmo numero para outra GNRE caso
                    // haja mais guias sendo geradas simultaneamente.
                    //RecLock("SX5",.F.)
                    //SX5->X5_DESCRI  := cNumero
                    //SX5->X5_DESCSPA := cNumero
                    //SX5->X5_DESCENG := cNumero
                    //SX5->(MsUnlock())

                    FwPutSX5(, "53", cImposto, cNumero, cNumero, cNumero, )
                Endif
            EndIf

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Tratamento para que nao seja permitida a alteracao do numero ³
            //³das GNRE's geradas no faturamento apos 15/06/2016.           ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            lBlqEdtNr := dDataBase >= cToD("15/06/2016")
        EndIf

        If lBlqEdtNr
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Selecao dos campos da tabela SF6 a serem alterados ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            /*cAliasTmp := "SX3TST"
            OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)

            aCampos:= FWSX3Util():GetAllFields( 'SF6' , .T. ) 

            (cAliasTmp)->(dbSetOrder(1))
            (cAliasTmp)->(dbSeek("SF6"))
            While (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->X3_ARQUIVO == 'SF6'
                If X3USO((cAliasTmp)->X3_USADO) 
                    If AllTrim((cAliasTmp)->X3_CAMPO) <> "F6_NUMERO"
                        Aadd(aCmpAlt, (cAliasTmp)->X3_CAMPO)
                    EndIf
                Endif
                (cAliasTmp)->(dbSkip())
            Enddo
            (cAliasTmp)->(DbCloseArea())*/
        EndIf

        If	nTitICMS > 0 .And. (cOrigem == "MATA953" .Or. cOrigem == "MATA460A" .Or. cOrigem == "MATA913" .Or. cOrigem == "MATA103")
            If !Empty (cNumGnre)
                SF6->(DbSetOrder (1))
                If SF6->(DbSeek (xFilial ("SF6")+cMVESTADO+cNumGnre)) .And. nTitICMS==SF6->F6_VALOR

                    cNumGnre  := PadR(cNumGnre,TamSx3("F6_NUMERO")[1])
                    cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo //Guia de Recolhimento do ICMS
                    aCamps    := {}
                    aCampAt   := {}

                    //Selecao dos campos da tabela SF6 a serem exibidos e os habilitados para alteracao
                    
                    /*cAliasTmp := "SX3TST"
                    OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)

                    aCampos:= FWSX3Util():GetAllFields( 'SF6' , .T. ) 

                    (cAliasTmp)->(dbSetOrder(1))
                    (cAliasTmp)->(dbSeek("SF6"))
                    While (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->X3_ARQUIVO == 'SF6'
                        If X3USO(SX3->X3_USADO) 
                            If AllTrim(SX3->X3_CAMPO)$"F6_NUMERO/F6_EST"
                                Aadd(aCamps,  (cAliasTmp)->X3_CAMPO)
                            Else
                                Aadd(aCamps,  (cAliasTmp)->X3_CAMPO)
                                Aadd(aCampAt, (cAliasTmp)->X3_CAMPO)
                            EndIf
                        Endif
                        (cAliasTmp)->(dbSkip())
                    Enddo
                    (cAliasTmp)->(DbCloseArea())*/
                    
                    //Montando tela de alteração da GNRE

                    If lAutomato
                        AADD(aAuto,{"F6_NUMERO" ,SF6->F6_NUMERO,Nil})
                        AADD(aAuto,{"F6_EST"    ,SF6->F6_EST,Nil})
                        AADD(aAuto,{"F6_TIPOIMP",SF6->F6_TIPOIMP,Nil})
                        AADD(aAuto,{"F6_VALOR"  ,SF6->F6_VALOR,Nil})
                        AADD(aAuto,{"F6_DTARREC",SF6->F6_DTARREC,Nil})
                        AADD(aAuto,{"F6_DTVENC" ,SF6->F6_DTVENC,Nil})
                        AADD(aAuto,{"F6_MESREF" ,SF6->F6_MESREF,Nil})
                        AADD(aAuto,{"F6_ANOREF" ,SF6->F6_ANOREF,Nil})

                        For nJ := 1 to Len(aRetAuto)
                            If aRetAuto[nJ][1] == SF6->F6_EST .And. aRetAuto[nJ][2] == SF6->F6_TIPOIMP
                                AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                            EndIf
                        Next nJ
                    EndIf

                    AxAltera("SF6",SF6->(Recno()),3,aCamps,aCampAt,,,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil))

                    If lRefaz
                        AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE}) //RECSALDO - Guia de Saldo apurado
                    Else
                        AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC","RECAPURA"}) //RECAPURA - Recolhido via Apuracao de ICMS
                    EndIf

                Else
                    //No caso do valor de GNRE diferente, devo excluir a anterior e gerar uma nova
                    If !SF6->(Eof()) .And.;
                        SF6->(F6_FILIAL+F6_EST+F6_NUMERO)==xFilial("SF6")+cMVESTADO+cNumGnre .And.;
                        nTitICMS<>SF6->F6_VALOR
                        RecLock("SF6",.F.)
                            SF6->(DbDelete())
                        MsUnlock()
                    EndIf

                    //GERADA GUIA MANUAL, GRAVAR ESTA GUIA
                    AADD(aDadSF6,{IIf(nVlrConv>0,nVlrConv,nTitICMS),dDataBase,nMes,nAno,dDtVenc,'1',cClasse,cMVESTADO,cNumGnre,"","","","","","",cInsc,cTipoDoc})//imposto a recolher

                    cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo //Guia de Recolhimento do ICMS

                    If lAutomato

                        If Empty(cNumGnre)
                            SX5->(dbSeek(cFilSx5+"53"+cImposto))
                            cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                        EndIf

                        AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                        AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                        AADD(aAuto,{"F6_TIPOIMP","1",Nil})
                        AADD(aAuto,{"F6_VALOR",IIf(nVlrConv>0,nVlrConv,nTitICMS),Nil})
                        AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                        AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                        AADD(aAuto,{"F6_MESREF",nMes,Nil})
                        AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                        For nJ := 1 to Len(aRetAuto)
                            If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "1"
                                AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                            EndIf
                        Next nJ

                    EndIf

            		If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
                    //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1				
		                If lRefaz
                            AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE}) //RECSALDO - Guia de Saldo apurado
                        Else
                            AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC","RECAPURA"}) //RECAPURA - Recolhido via Apuracao de ICMS
                        EndIf
                    Endif
                EndIf
            Else

                aDadSF6 := {}

                //GUIA EM BRANCO, GRAVAR SALDO
                If cOrigem == "MATA460A" 
                    cInsc := SM0->M0_INSC
                EndIf
                
                If Empty(cTpImp)
                    If cImp == "PR"
                        cTpImp := 'C'
                        cGNRImp := "PROTEGE-GO"
                    Else
                        cTpImp := '1'
                        cGNRImp := "IC"
                    EndIf
                EndIf
                //Issue https://jiraproducao.totvs.com.br/browse/DSERFIS1-16304
                //Para fins de escrituração da prestação do serviço de transporte, se deve considerar o local de início da prestação de serviços, ou seja, o local de coleta da mercadoria, pois é neste momento que se considera ocorrido o fato gerador do imposto.
                If nModulo == 43 .and. Alltrim(aDadSF2[nPos,8]) $ "CTR/CTE/CTA/CA/CTF"
                    cUFOrigem := MaFisRet(,"NF_UFORIGEM")
                    If cUFOrigem <> cMVESTADO .OR. aDadSF2[nPos,7] <> cMVESTADO
                        If cUFOrigem == cMVESTADO
                            cCltOrig	:= cUFOrigem 
                        ElseIf cUFOrigem <> cMVESTADO .AND. aDadSF2[nPos,7] <> cMVESTADO
                            cCltOrig	:= cUFOrigem
                        ElseIf cUFOrigem <> cMVESTADO .AND. aDadSF2[nPos,7] == cMVESTADO
                            cCltOrig := cUFOrigem
                        EndIF
                    Else
                        cCltOrig := cMVESTADO
                    EndIf
                Else
                    cCltOrig := cMVESTADO
                Endif
                
                
                If cOrigem $ "MATA460A/MATA103" .And. Len(aDadSF2[nPos]) >= 6
                    AADD(aDadSF6,{nTitICMS,dDataBase,nMes,nAno,dDtVenc,cTpImp,cClasse,cCltOrig,cPrefixo+cNumero,aDadSF2[nPos,1],aDadSF2[nPos,2],aDadSF2[nPos,3],;
                                aDadSF2[nPos,4],aDadSF2[nPos,5],aDadSF2[nPos,6],cInsc,cTipoDoc,"","",.F.,"",cObserv,If(Len(aDadSF2[nPos]) >= 9,aDadSF2[nPos,9],.F.)})//imposto a recolher , adicionado validação da posição 23 para identificar se é uma antecipação
                Else
                    AADD(aDadSF6,{nTitICMS,dDataBase,nMes,nAno,dDtVenc,cTpImp,cClasse,cMVESTADO,cPrefixo+cNumero,"","","","","","",cInsc,cTipoDoc,,,,,cObserv})//imposto a recolher
                EndIf

                cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") + " " + cPrefixo + " " + cGNRImp //"Guia de Recolhimento do ICMS"    

                If lAutomato
                    If Empty(cPrefixo+cNumero)
                        SX5->(dbSeek(cFilSx5+"53"+cImposto))
                        AADD(aAuto,{"F6_NUMERO",Soma1(Substr(X5Descri(),1,nTamNF),nTamNF),Nil})
                    Else
                        AADD(aAuto,{"F6_NUMERO",cPrefixo+cNumero,Nil})
                    EndIf
                    AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                    AADD(aAuto,{"F6_TIPOIMP","1",Nil})
                    AADD(aAuto,{"F6_VALOR",nTitICMS,Nil})
                    AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                    AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                    AADD(aAuto,{"F6_MESREF",nMes,Nil})
                    AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                    For nJ := 1 to Len(aRetAuto)
                        If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "1"
                            AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                        EndIf
                    Next nJ

                EndIf

                // Tratamento p/ geracao da GNRE de ICMS Proprio sem interface (AxInclui).
                If cOrigem $ "MATA460A/MATA103" .And. lNgnreNf
                    xApGrvSF6(aDadSF2, aDadSF6, cPrefixo + cNumero, cCodGnre)
                    AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE}) //RECSALDO - Guia de Saldo apurado
                ElseIf xApIncSF6("SF6",1,3,"U_uFisIcmF6",Iif(lBlqEdtNr,aCmpAlt,NIL),"SF6TudoOk('"+cOrigem+"','"+cPrefixo+"','"+cNumero+"')",If(lAutomato,aAuto,Nil)) == 1
                //ElseIf AxInclui("SF6",1,3,,"U_uFisIcmF6",Iif(lBlqEdtNr,aCmpAlt,NIL),"SF6TudoOk('"+cOrigem+"','"+cPrefixo+"','"+cNumero+"')",,,,,If(lAutomato,aAuto,Nil)) == 1
                    AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE}) //RECSALDO - Guia de Saldo apurado
                Endif
            EndIf
        EndIf
        If	nTitST > 0 .And. (cOrigem == "MATA953" .Or. cOrigem == "MATA460A" .Or. cOrigem == "MATA103")

            If cOrigem == "MATA460A"
                If cModulo == "ACD"
                    If !Empty(SM0->M0_INSC)
                        cInsc := SM0->M0_INSC
                    Else
                        cInsc := IESubTrib(cUf,lDifal)
                    EndIf
                Else
                    If (nPos := Len(aDadSf2)) > 0
                        If aDadSF2[nPos,5] == "B"
                            If SA2->(MsSeek(xFilial("SA2")+aDadSF2[nPos,3]+aDadSF2[nPos,4]))
                                cInsc := SA2->A2_INSCR
                                cCNPJ := SA2->A2_CGC
                            EndIf
                        Else
                        If SA1->(MsSeek(xFilial("SA1")+aDadSF2[nPos,3]+aDadSF2[nPos,4]))
                                cInsc := SA1->A1_INSCR
                                cCNPJ := SA1->A1_CGC
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf

            aDadSF6 := {}

            If Empty(cTpImp)

                IF cOrigem $ "MATA460A/MATA953/MATA103" .And. lDifal .And. (lFECP .Or. lDifAlq) 
                    If lFECP .And. lFumacop
                        cTpImp :='A' //FUMACOP
                        cGNRImp := "FUMACOP"
                    Else
                        cTpImp :='B'
                        cGNRImp := 'DIFAL'//Iif(lFECP,"FECP E.C. 87/15", "DIFAL E.C. 87/15")
                    EndIf
                Else
                    If lAntParcBA
                        cTpImp :='0'
                        cGNRImp :="Antecipação Parcial"
                    Else
                        cTpImp :='3'
                        cGNRImp :="ST"
                    EndIf
                Endif

            EndIf				

            If Len(aDadSf2)>0
                nPos:=Len(aDadSf2)
                AADD(aDadSF6,{nTitST,dDataBase,nMes,nAno,dDtVenc,cTpImp,cClasse,aDadSF2[nPos,7],cPrefixo+cNumero,aDadSF2[nPos,1],aDadSF2[nPos,2],aDadSF2[nPos,3],;
                aDadSF2[nPos,4],aDadSF2[nPos,5],aDadSF2[nPos,6],cInsc,cTipoDoc,cNumConv,Iif(Len(aDadSF2[nPos]) >= 8, aDadSF2[nPos,8], ""),lFecp,cCNPJ,cObserv,If(Len(aDadSF2[nPos]) >= 9,aDadSF2[nPos,9],.F.)}) 

                If IsBlind() .And. cOrigem == "MATA103"  .Or. (cOrigem == "MATA460A" .And. cModulo == "ACD") .And. !lGTitFluig
                    // Preenchimento do array de rotina automatica para geracao de guia de antecipacao de ICMS 
                    nTamASF6 := Len(aDadSF6)
                    aadd(aCposAut,{"F6_NUMERO"	,aDadSF6[nTamASF6,9]	,Nil})
                    aadd(aCposAut,{"F6_EST"		,PadR(aDadSF6[nTamASF6,8],TamSX3("F6_EST")[1]),Nil})
                    aadd(aCposAut,{"F6_TIPOIMP"	,aDadSF6[nTamASF6,6]	,Nil})
                    aadd(aCposAut,{"F6_VALOR"	,aDadSF6[nTamASF6,1]	,Nil})
                    aadd(aCposAut,{"F6_INSC"	,PadR(aDadSF6[nTamASF6,16],TamSX3("F6_INSC")[1]),Nil})
                    aadd(aCposAut,{"F6_DTARREC"	,aDadSF6[nTamASF6,2]	,Nil})
                    aadd(aCposAut,{"F6_DTVENC"	,aDadSF6[nTamASF6,5]	,Nil})
                    aadd(aCposAut,{"F6_MESREF"	,aDadSF6[nTamASF6,3]	,Nil})
                    aadd(aCposAut,{"F6_ANOREF"	,aDadSF6[nTamASF6,4]	,Nil})
                    aadd(aCposAut,{"F6_CLAVENC"	,aDadSF6[nTamASF6,7]	,Nil})
                    aadd(aCposAut,{"F6_DOC"		,aDadSF6[nTamASF6,10]	,Nil})
                    aadd(aCposAut,{"F6_SERIE"	,aDadSF6[nTamASF6,11]	,Nil})
                    aadd(aCposAut,{"F6_CLIFOR"	,aDadSF6[nTamASF6,12]	,Nil})
                    aadd(aCposAut,{"F6_LOJA"	,aDadSF6[nTamASF6,13]	,Nil})
                    aadd(aCposAut,{"F6_OPERNF"	,aDadSF6[nTamASF6,15]	,Nil})
                    aadd(aCposAut,{"F6_TIPODOC"	,aDadSF6[nTamASF6,14]	,Nil})

                    If SerieNfId("SF6",3,"F6_SERIE") == "F6_SDOC"
                        aadd(aCposAut,{"F6_SDOC"	,SubStr(aDadSF6[nTamASF6,11],1,3)	,Nil})
                    EndIf
                    If	SF6->(FieldPos("F6_FECP")) > 0
                        If Len(aDadSF6[nTamASF6])>=20 .And. aDadSF6[nTamASF6,20]
                            aadd(aCposAut,{"F6_FECP"	,"1"	,Nil})
                        Else
                            aadd(aCposAut,{"F6_FECP"	,"2"	,Nil})
                        EndIf
                    EndIf

                EndIf

                cGNRInfC := xApInfC(lAutomato)

            Else
                AADD(aDadSF6,{nTitST,dDataBase,nMes,nAno,dDtVenc,cTpImp,cClasse,cUF,Iif(((cTpImp == 'B' .And. (lFECP .Or. lDifAlq)) .Or. Empty(cNumGnre)),cPrefixo+cNumero,cNumGnre),"","","","","","",cInsc,cTipoDoc,"","",lFecp,"",cObserv}) //imposto a recolher Substituicao Tributaria
                If lAutomato .And. Empty(aCposAut)

                    If Empty(cPrefixo+cNumero)
                        SX5->(dbSeek(cFilSx5+"53"+cImposto))
                        AADD(aCposAut,{"F6_NUMERO",Soma1(Substr(X5Descri(),1,nTamNF),nTamNF),Nil})
                    Else
                        AADD(aCposAut,{"F6_NUMERO",cPrefixo+cNumero,Nil})
                    EndIf

                    AADD(aCposAut,{"F6_EST",cUF ,Nil})
                    AADD(aCposAut,{"F6_TIPOIMP",cTpImp,Nil})
                    AADD(aCposAut,{"F6_VALOR",nTitST,Nil})
                    AADD(aCposAut,{"F6_DTARREC",dDataBase,Nil})
                    AADD(aCposAut,{"F6_DTVENC",dDtVenc,Nil})
                    AADD(aCposAut,{"F6_MESREF",nMes,Nil})
                    AADD(aCposAut,{"F6_ANOREF",nAno,Nil})

                    For nJ := 1 to Len(aRetAuto)
                        If aRetAuto[nJ][1] == cUF .And. aRetAuto[nJ][2] == cTpImp
                            AADD(aCposAut,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                        EndIf
                    Next nJ

                EndIf
            Endif

            cCadastro := cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo

            If cTpImp =='B' .AND. ( lFECP .Or. lDifAlq )

                If cOriGNRE == 'DEBITO ESPECIAL'
                    cCadastro += ' - EC 87/15 - DEBITO ESPECIAL - '
                ElseIf cOriGNRE == 'DEBITO ESPECIAL FECP'
                    cCadastro += ' - EC 87/15 - DEBITO ESPECIAL FECP - '
                Elseif lDifAlq
                    cCadastro += ' - EC 87/15  - '
                Elseif lFECP
                    cCadastro += ' - EC 87/15 - FECP - '
                EndIF

            EndIF

            cCadastro += "/"+cGNRImp //"Guia de Recolhimento do ICMS"
            If lINFOGNRE
                lGravaSF6 := ExecBlock("INFOGNRE", .F., .F.)
                If lGravaSF6
                    AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,cGNRImp,cOriGNRE})
                    nPosGNRE := Len(aGnre)
                    If Len(aDadSf2)>0 
                        DbSelectArea("CDC")
                        CDC->(DbSetOrder(1))//CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF						
                        If !DbSeek(xFilial("CDC")+IIF(aDadSF2[nPos,6]=="1","E","S")+aDadSF2[nPos,1]+aDadSF2[nPos,2]+aDadSF2[nPos,3]+aDadSF2[nPos,4]+AVKEY(IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero),"CDC_GUIA")+aDadSF2[nPos,7])
                            RecLock("CDC",.T.)
                            CDC_FILIAL :=xFilial("CDC")
                            CDC_TPMOV  :=IIF(aDadSF2[nPos,6]=="1","E","S")
                            CDC_DOC    :=aDadSF2[nPos,1]
                            SerieNfId("CDC",1,"CDC_SERIE",,,,aDadSF2[nPos,2])
                            CDC_CLIFOR :=aDadSF2[nPos,3]
                            CDC_LOJA   :=aDadSF2[nPos,4]
                            CDC_GUIA   :=IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero)
                            CDC_UF     :=aDadSF2[nPos,7]
                            CDC_IFCOMP :=cGNRInfC
                            CDC->(MsUnlock())
                        Endif
                    Endif
                EndIf
            Else
                If !Empty(cNumGnre)
                    SF6->(DbSetOrder(1))
                    If SF6->(DbSeek(xFilial("SF6")+cUF+cNumGnre)) .And. nTitST==SF6->F6_VALOR
                        cNumGnre := PadR(cNumGnre,TamSx3("F6_NUMERO")[1])
                        aCamps   := {}
                        aCampAt  := {}

                        //Selecao dos campos da tabela SF6 a serem exibidos e os habilitados para alteracao
                        /*cAliasTmp := "SX3TST"
                        OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)

                        aCampos:= FWSX3Util():GetAllFields( 'SF6' , .T. ) 

                        (cAliasTmp)->(dbSetOrder(1))
                        (cAliasTmp)->(dbSeek("SF6"))
                        While (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->X3_ARQUIVO == 'SF6'
                            If X3USO(SX3->X3_USADO) 
                                If AllTrim(SX3->X3_CAMPO)$"F6_NUMERO/F6_EST"
                                    Aadd(aCamps,  (cAliasTmp)->X3_CAMPO)
                                Else
                                    Aadd(aCamps,  (cAliasTmp)->X3_CAMPO)
                                    Aadd(aCampAt, (cAliasTmp)->X3_CAMPO)
                                EndIf
                            Endif
                            (cAliasTmp)->(dbSkip())
                        Enddo
                        (cAliasTmp)->(DbCloseArea())*/

                        //Montando tela de alteração da GNRE
                        If lAutomato
                            AADD(aAuto,{"F6_NUMERO" ,SF6->F6_NUMERO,Nil})
                            AADD(aAuto,{"F6_EST"    ,SF6->F6_EST,Nil})
                            AADD(aAuto,{"F6_TIPOIMP",SF6->F6_TIPOIMP,Nil})
                            AADD(aAuto,{"F6_VALOR"  ,SF6->F6_VALOR,Nil})
                            AADD(aAuto,{"F6_DTARREC",SF6->F6_DTARREC,Nil})
                            AADD(aAuto,{"F6_DTVENC" ,SF6->F6_DTVENC,Nil})
                            AADD(aAuto,{"F6_MESREF" ,SF6->F6_MESREF,Nil})
                            AADD(aAuto,{"F6_ANOREF" ,SF6->F6_ANOREF,Nil})

                            For nJ := 1 to Len(aRetAuto)
                                If aRetAuto[nJ][1] == SF6->F6_EST .And. aRetAuto[nJ][2] == SF6->F6_TIPOIMP
                                    AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                                EndIf
                            Next nJ

                        EndIf

                        AxAltera("SF6",SF6->(Recno()),3,aCamps,aCampAt,,,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil))
                        AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,cGNRImp,cOriGNRE})
                    Else
                        //No caso do valor de GNRE diferente, devo excluir a anterior e gerar uma nova
                        If !SF6->(Eof()) .And.;
                            SF6->(F6_FILIAL+F6_EST+F6_NUMERO)==xFilial("SF6")+cUF+cNumGnre .And.;
                            nTitST<>SF6->F6_VALOR
                            RecLock("SF6",.F.)
                            SF6->(DbDelete())
                            MsUnlock()
                        EndIf
                    EndIf

                EndIf

                If aScan(aGNRE,{|aX| aX[1] == cNumGnre .And. aX[6] == cGNRImp}) == 0

                    // Tratamento p/ geracao da GNRE de ICMS-ST sem interface (AxInclui).
                    If cOrigem $ "MATA460A/MATA103" .And. lNgnreNf .And. !lGTitFluig

                        xApGrvSF6(aDadSF2, aDadSF6, cPrefixo + cNumero, cCodGnre)

                        AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,cGNRImp,cOriGNRE})
                        nPosGNRE := Len(aGnre)
                        If Len(aDadSf2)>0
                            DbSelectArea("CDC")
                            CDC->(DbSetOrder(1))//CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF						    
                            If !DbSeek(xFilial("CDC")+IIF(aDadSF2[nPos,6]=="1","E","S")+aDadSf2[nPos,1]+aDadSF2[nPos,2]+aDadSF2[nPos,3]+aDadSF2[nPos,4]+AVKEY(IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero),"CDC_GUIA")+aDadSF2[nPos,7])
                                RecLock("CDC",.T.)
                                CDC_FILIAL :=xFilial("CDC")
                                CDC_TPMOV  :=IIF(aDadSF2[nPos,6]=="1","E","S")
                                CDC_DOC    :=aDadSf2[nPos,1]
                                SerieNfId("CDC",1,"CDC_SERIE",,,,aDadSF2[nPos,2])
                                CDC_CLIFOR :=aDadSF2[nPos,3]
                                CDC_LOJA   :=aDadSF2[nPos,4]
                                CDC_GUIA   :=IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero)
                                CDC_UF     :=aDadSF2[nPos,7]
                                CDC_IFCOMP :=cGNRInfC
                                CDC->(MsUnlock())
                            Endif
                        Endif

                    ElseIf xApIncSF6("SF6",1,3,"FisSTF6",Iif(lBlqEdtNr,aCmpAlt,NIL),"SF6TudoOk('"+cOrigem+"','"+cPrefixo+"','"+cNumero+"')",If(Len(aCposAut)>0,aCposAut,Nil)) == 1
                    //ElseIf AxInclui("SF6",1,3,,"FisSTF6",Iif(lBlqEdtNr,aCmpAlt,NIL),"SF6TudoOk('"+cOrigem+"','"+cPrefixo+"','"+cNumero+"')",,,,,If(Len(aCposAut)>0,aCposAut,Nil)) == 1

                        AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,cGNRImp,cOriGNRE})
                        nPosGNRE := Len(aGnre)

                        If Len(aDadSf2)>0
                            DbSelectArea("CDC")
                            CDC->(DbSetOrder(1))//CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF						    
                            If !DbSeek(xFilial("CDC")+IIF(aDadSF2[nPos,6]=="1","E","S")+aDadSF2[nPos,1]+aDadSF2[nPos,2]+aDadSF2[nPos,3]+aDadSF2[nPos,4]+AVKEY(IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero),"CDC_GUIA")+aDadSF2[nPos,7])
                                RecLock("CDC",.T.)
                                CDC_FILIAL :=xFilial("CDC")
                                CDC_TPMOV  :=IIF(aDadSF2[nPos,6]=="1","E","S")
                                CDC_DOC    :=aDadSF2[nPos,1]
                                SerieNfId("CDC",1,"CDC_SERIE",,,,aDadSF2[nPos,2])
                                CDC_CLIFOR :=aDadSF2[nPos,3]
                                CDC_LOJA   :=aDadSF2[nPos,4]
                                CDC_GUIA   :=IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero)
                                CDC_UF     :=aDadSF2[nPos,7]
                                CDC_IFCOMP :=cGNRInfC
                                CDC->(MsUnlock())
                            Endif
                        Endif
                    Endif
                EndIf
            EndIf
        Endif
        If	nTitICMS > 0 .and. cOrigem == "MATA954"
            AADD(aDadSF6,{nVlrTitulo,dDataBase,nMes,nAno,dDtVenc,"2",cClasse,cUf,cNumGnre,"","","","","","","","",SE2->E2_NUM,cCodMunRec})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo //"Guia de Recolhimento"

            If lAutomato

                If Empty(cNumGnre)
                    SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                EndIf

                AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                AADD(aAuto,{"F6_EST",cUf,Nil})
                AADD(aAuto,{"F6_TIPOIMP","2",Nil})
                AADD(aAuto,{"F6_VALOR",nVlrTitulo,Nil})
                AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                AADD(aAuto,{"F6_MESREF",nMes,Nil})
                AADD(aAuto,{"F6_ANOREF",nAno,Nil})
                AADD(aAuto,{"F6_CODMUN",cCodMunRec,Nil})

                For nJ := 1 to Len(aRetAuto)
                    If aRetAuto[nJ][1] == cUf .And. aRetAuto[nJ][2] == "2"
                        AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                    EndIf
                Next nJ

            EndIf

            If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
            //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1
                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IS",cOriGNRE})
            EndIf
        Endif
        If	nTitFun > 0 .and. cOrigem == "MATA953" .And. SF6->(FieldPos("F6_TIPOIMP")) > 0 .and. cImp == "FD"
            AADD(aDadSF6,{nTitFun,dDataBase,nMes,nAno,dDtVenc,"6",cClasse,cMVESTADO,cNumGnre,"","","","","","",cInsc,cTipoDoc})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / Fundersul" //"Guia de Recolhimento do ICMS"

            If lAutomato

                If Empty(cNumGnre)
                    SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                EndIf

                AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                AADD(aAuto,{"F6_TIPOIMP","6",Nil})
                AADD(aAuto,{"F6_VALOR",nTitFun,Nil})
                AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                AADD(aAuto,{"F6_MESREF",nMes,Nil})
                AADD(aAuto,{"F6_ANOREF",nAno,Nil})
                AADD(aAuto,{"F6_INSC",cInsc,Nil})
                AADD(aAuto,{"F6_TIPODOC",cTipoDoc,Nil})

                For nJ := 1 to Len(aRetAuto)
                    If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "6"
                        AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                    EndIf
                Next nJ

            EndIf

            If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
            //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1
                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE})
            EndIf
        Endif
        //senar
        If (nTitFun > 0 .and. cOrigem == "MATA953") .and. SF6->(FieldPos("F6_TIPOIMP")) > 0 .and. cImp == "SE"
            AADD(aDadSF6,{nTitFun,dDataBase,nMes,nAno,dDtVenc,"9",cClasse,cMVESTADO,cNumGnre})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / Senar" //"Guia de Recolhimento do Senar"

            If lAutomato

                If Empty(cNumGnre)
                    SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                EndIf

                AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                AADD(aAuto,{"F6_TIPOIMP","9",Nil})
                AADD(aAuto,{"F6_VALOR",nTitFun,Nil})
                AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                AADD(aAuto,{"F6_MESREF",nMes,Nil})
                AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                For nJ := 1 to Len(aRetAuto)
                    If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "9"
                        AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                    EndIf
                Next nJ

            EndIf

            If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
            //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1
                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE})
            EndIf
        Endif
        //Fumacop
        If (nTitFun > 0 .and. cOrigem == "MATA953") .and. SF6->(FieldPos("F6_TIPOIMP")) > 0 .and. cImp == "FU"
            AADD(aDadSF6,{nTitFun,dDataBase,nMes,nAno,dDtVenc,"A",cClasse,cMVESTADO,cNumGnre})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / Fumacop" //"Guia de Recolhimento do Fumacop"

            If lAutomato

                If Empty(cNumGnre)
                    SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                EndIf

                AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                AADD(aAuto,{"F6_TIPOIMP","A",Nil})
                AADD(aAuto,{"F6_VALOR",nTitFun,Nil})
                AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                AADD(aAuto,{"F6_MESREF",nMes,Nil})
                AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                For nJ := 1 to Len(aRetAuto)
                    If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "A"
                        AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                    EndIf
                Next nJ

            EndIf

            If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
            //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1
                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE})
            EndIf
        Endif

        If (nConv139 > 0 .and. cOrigem == "MATA953") .and. SF6->(FieldPos("F6_TIPOIMP")) > 0 .and. Substr(cImp,1,3) == "IC"

            AADD(aDadSF6,{nConv139,dDataBase,nMes,nAno,dDtVenc,'1',cClasse,cUF,cNumGnre,"","","","","","",cInsc,cTipoDoc})//imposto a recolher
            cCadastro := "Guia Recolhimento COnvenio 139/06" //OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / "+ aApIncent[Len(aApIncent)] //"Guia de Recolhimento / 'Incentivo' "

            /*
            Aqui verifico se a GNRE já foi gravada, para então abrir a tela em mode de edição.
            Como para Convênio 139/06 trata diversas UFs, fiz separado a parte de validação das GNREs
            */
            dbSelectArea("SF6")
            SF6->(DbSetOrder (1))
            If nConv139 > 0 .AND.!Empty (cNumGnre) .AND. SF6->(DbSeek (xFilial ("SF6")+cUF+cNumGnre)) .And. nConv139==SF6->F6_VALOR

                cNumGnre  := PadR(cNumGnre,TamSx3("F6_NUMERO")[1])
                cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo //"Guia de Recolhimento do ICMS"
                aCamps    := {}
                aCampAt   := {}
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³Selecao dos campos da tabela SF6 a serem exibidos e os habilitados para alteracao³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                /*cAliasTmp := "SX3TST"
                OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)

                aCampos:= FWSX3Util():GetAllFields( 'SF6' , .T. ) 

                (cAliasTmp)->(dbSetOrder(1))
                (cAliasTmp)->(dbSeek("SF6"))
                While (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->X3_ARQUIVO == 'SF6'
                    If X3USO(SX3->X3_USADO) 
                        If AllTrim(SX3->X3_CAMPO)$"F6_NUMERO/F6_EST"
                            Aadd(aCamps,  (cAliasTmp)->X3_CAMPO)
                        Else
                            Aadd(aCamps,  (cAliasTmp)->X3_CAMPO)
                            Aadd(aCampAt, (cAliasTmp)->X3_CAMPO)
                        EndIf
                    Endif
                    (cAliasTmp)->(dbSkip())
                Enddo
                (cAliasTmp)->(DbCloseArea())*/
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³Montando tela de alteração da GNRE³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                AxAltera("SF6",SF6->(Recno()),3,aCamps,aCampAt,,,"SF6TudoOk()")
                If lRefaz
                    AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE}) //RECSALDO - Guia de Saldo apurado
                Else
                    AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC","RECAPURA"}) //RECAPURA - Recolhido via Apuracao de ICMS
                EndIf

            Else		
                If lAutomato

                    If Empty(cNumGnre)
                        SX5->(dbSeek(cFilSx5+"53"+cImposto))
                        cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                    EndIf

                    AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                    AADD(aAuto,{"F6_EST",cUf,Nil})
                    AADD(aAuto,{"F6_TIPOIMP","1",Nil})
                    AADD(aAuto,{"F6_VALOR",nConv139,Nil})
                    AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                    AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                    AADD(aAuto,{"F6_MESREF",nMes,Nil})
                    AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                    For nJ := 1 to Len(aRetAuto)
                        If aRetAuto[nJ][1] == cUf .And. aRetAuto[nJ][2] == "1"
                            AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                        EndIf
                    Next nJ	

                EndIf

                If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
                //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1
                    AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE})
                EndIf
            Endif
        EndIf
        //Incentivos Fiscais
        If (nTitFun > 0 .and. cOrigem == "MATA953") .and. SF6->(FieldPos("F6_TIPOIMP")) > 0 .and. Substr(cImp,1,3) == "IC" .And. Len(aApIncent) > 0

            AADD(aDadSF6,{nTitFun,dDataBase,nMes,nAno,dDtVenc,'1',cClasse,cMVESTADO,cNumGnre,"","","","","","",cInsc,cTipoDoc})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / "+ aApIncent[Len(aApIncent)] //"Guia de Recolhimento / 'Incentivo' "

            If lAutomato

                If Empty(cNumGnre)
                    SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                EndIf

                AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                AADD(aAuto,{"F6_TIPOIMP","1",Nil})
                AADD(aAuto,{"F6_VALOR",nTitFun,Nil})
                AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                AADD(aAuto,{"F6_MESREF",nMes,Nil})
                AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                For nJ := 1 to Len(aRetAuto)
                    If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "1"
                        AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                    EndIf
                Next nJ

            EndIf

            If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
            //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1
                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE})
            EndIf
        Endif

        If (nTitICMS > 0 .and. cOrigem == "MATA924")
            AADD(aDadSF6,{nTitICMS,dDataBase,nMes,nAno,dDtVenc,"7",cClasse,cMVESTADO,cNumGnre})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / Simples Nacional" //"Guia de Recolhimento do Simples Nacional"

            If lAutomato

                If Empty(cNumGnre)
                    SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                EndIf

                AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                AADD(aAuto,{"F6_TIPOIMP","7",Nil})
                AADD(aAuto,{"F6_VALOR",nTitFun,Nil})
                AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                AADD(aAuto,{"F6_MESREF",nMes,Nil})
                AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                For nJ := 1 to Len(aRetAuto)
                    If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "7"
                        AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                    EndIf
                Next nJ

            EndIf
            AADD(aDadSF6,{nTitICMS,dDataBase,nMes,nAno,dDtVenc,"7",cClasse,cMVESTADO,cNumGnre})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / Simples Nacional" //"Guia de Recolhimento do Simples Nacional"
            If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()",If(lAutomato,aAuto,Nil)) == 1
            //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()",,,,,If(lAutomato,aAuto,Nil)) == 1
                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE})
            EndIf
        Endif
        
        If (nGuiaSN > 0 .and. cOrigem == "MATA924")
            AADD(aDadSF6,{nGuiaSN,dDataBase,nMes,nAno,dDtVenc,"7",cClasse,cMVESTADO,cNumGnre})//imposto a recolher
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / Simples Nacional" //"Guia de Recolhimento do Simples Nacional Resolução CGSN nº 51/2008"

            If lAutomato

                If Empty(cNumGnre)
                    SX5->(dbSeek(cFilSx5+"53"+cImposto))
                    cNumGnre := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
                EndIf

                AADD(aAuto,{"F6_NUMERO",cNumGnre,Nil})
                AADD(aAuto,{"F6_EST",cMVESTADO,Nil})
                AADD(aAuto,{"F6_TIPOIMP","7",Nil})
                AADD(aAuto,{"F6_VALOR",nTitFun,Nil})
                AADD(aAuto,{"F6_DTARREC",dDataBase,Nil})
                AADD(aAuto,{"F6_DTVENC",dDtVenc,Nil})
                AADD(aAuto,{"F6_MESREF",nMes,Nil})
                AADD(aAuto,{"F6_ANOREF",nAno,Nil})

                For nJ := 1 to Len(aRetAuto)
                    If aRetAuto[nJ][1] == cMVESTADO .And. aRetAuto[nJ][2] == "7"
                        AADD(aAuto,{aRetAuto[nJ][3],aRetAuto[nJ][4],aRetAuto[nJ][5]})
                    EndIf
                Next nJ

            EndIf

            If xApIncSF6("SF6",1,3,"U_uFisIcmF6",,"SF6TudoOk()") == 1
            //If AxInclui("SF6",1,3,,"U_uFisIcmF6",,"SF6TudoOk()") == 1
                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC",cOriGNRE})
            EndIf
        Endif
        If (nTitICMS > 0 .and. cOrigem == "MATA460A" .and. lArt65) .And. !lGTitFluig
            If Len(aDadSf2)>0
                cInsc := SM0->M0_INSC
                nPos:=Len(aDadSf2)
                AADD(aDadSF6,{nTitICMS,dDataBase,nMes,nAno,dDtVenc,"1",cClasse,aDadSF2[nPos,7],cPrefixo+cNumero,aDadSF2[nPos,1],aDadSF2[nPos,2],aDadSF2[nPos,3],aDadSF2[nPos,4],aDadSF2[nPos,5],aDadSF2[nPos,6],cInsc,cTipoDoc})//imposto a recolher
                cGNRInfC := xApInfC(lAutomato)
            Endif
            cCadastro := OemtoAnsi("Guia de Recolhimento do ICMS") +" "+ cPrefixo+" / ART 65 RICMS PR" //"Guia de Recolhimento de ICMS ART 65 DO RICMS PR "
            If xApIncSF6("SF6",1,3,"FisSTF6",,"SF6TudoOk()") == 1
            //If AxInclui("SF6",1,3,,"FisSTF6",,"SF6TudoOk()") == 1

                AADD(aGnre,{SF6->F6_NUMERO,SF6->F6_DTVENC,SF6->F6_VALOR,SF6->F6_CLAVENC,SF6->F6_EST,"IC"})
                nPosGNRE := Len(aGnre)
                If Len(aDadSf2)>0 
                    DbSelectArea("CDC")
                    CDC->(DbSetOrder(1))//CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF				           
                    If !DbSeek(xFilial("CDC")+IIF(aDadSF2[nPos,6]=="1","E","S")+aDadSF2[nPos,1]+aDadSF2[nPos,2]+aDadSF2[nPos,3]+aDadSF2[nPos,4]+AVKEY(IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero),"CDC_GUIA")+aDadSF2[nPos,7])
                        RecLock("CDC",.T.)
                        CDC_FILIAL :=xFilial("CDC")
                        CDC_TPMOV  :=IIF(aDadSF2[nPos,6]=="1","E","S")
                        CDC_DOC    :=aDadSF2[nPos,1]
                        SerieNfId("CDC",1,"CDC_SERIE",,,,aDadSF2[nPos,2])
                        CDC_CLIFOR :=aDadSF2[nPos,3]
                        CDC_LOJA   :=aDadSF2[nPos,4]
                        CDC_GUIA   :=IIf(aGnre[nPosGNRE][1]<>cPrefixo+cNumero,aGnre[nPosGNRE][1],cPrefixo+cNumero)
                        CDC_UF     :=aDadSF2[nPos,7]
                        CDC_IFCOMP :=cGNRInfC
                        CDC->(MsUnlock())
                    Endif
                Endif
            EndIf
        Endif
    EndIf

    //Dados referentes a Guia de recolhimento gerado no Contas a Pagar
    If cPaisLoc=="BRA" .And. cOrigem=="MATA460A" .And. lConfTit .And. !lGTitFluig
        nPos:= Len(aDadSf2)
        If nPos>0
            If SF2->(DBSEEK(xFilial("SF2")+aDadSf2[nPos][1]+aDadSf2[nPos][2]+aDadSf2[nPos][3]+aDadSf2[nPos][4])) .And. !lFECP
                If SF2->(FieldPos("F2_GNRDIF")) > 0 .And. lDifal
                    RecLock("SF2",.F.)
                    IF EMPTY(ALLTRIM(SF2->F2_GNRDIF))
                        If lGuiaRec .And. Len(aGnre) >= nPos .And. aGnre[nPos][1] <> cPrefixo+cNumero
                            SF2->F2_GNRDIF := aGnre[nPos][1]
                        Else
                            SF2->F2_GNRDIF := cPrefixo+cNumero
                        EndIf
                    ENDIF
                    SF2->(MsUnlock())
                ElseIf SF2->(FieldPos("F2_NFICMST")) > 0 .And. nTitST > 0
                    RecLock("SF2",.F.)
                    // Se gerar GNRE e a numeração for alterada utilizar o nro. digitado p/ gravar na SF2 (F2_NFICMST)
                    // pois a grvação da tabela CDC possui este mesmo tratamento.
                    IF EMPTY(ALLTRIM(SF2->F2_NFICMST))
                        If lGuiaRec .And. Len(aGnre) >= nPos .And. aGnre[nPos][1] <> cPrefixo+cNumero
                            SF2->F2_NFICMST := aGnre[nPos][1]
                        Else
                            SF2->F2_NFICMST := cPrefixo+cNumero
                        EndIf
                    ENDIF
                    SF2->(MsUnlock())
                Endif
            Endif
            If SF2->(DBSEEK(xFilial("SF2")+aDadSf2[nPos][1]+aDadSf2[nPos][2]+aDadSf2[nPos][3]+aDadSf2[nPos][4])) .And. lFECP
                If cMVESTADO=="RN" .And. SF3->(FieldPos("F3_VFESTRN"))>0 .And. !lDifal
                    nVFecpST  := IIf(SF3->F3_VFECPST > 0, SF3->F3_VFECPST, SF3->F3_VFESTRN)
                    If nVFecpST > 0 .And. SF2->(FieldPos("F2_NTFECP"))>0
                        RecLock("SF2",.F.)
                        SF2->F2_NTFECP:=cPrefixo+cNumero
                        SF2->(MsUnlock())
                    Endif
                ElseIf cMVESTADO=="MG" .And. SF3->(FieldPos("F3_VFESTMG"))>0 .And. !lDifal
                    nVFecpST  := IIf(SF3->F3_VFECPST > 0, SF3->F3_VFECPST, SF3->F3_VFESTMG)
                    If nVFecpST > 0 .And. SF2->(FieldPos("F2_NTFECP"))>0
                        RecLock("SF2",.F.)
                        SF2->F2_NTFECP:=cPrefixo+cNumero
                        SF2->(MsUnlock())
                    Endif
                ElseIf cMVESTADO=="MT" .And. SF3->(FieldPos("F3_VFESTMT"))>0 .And. !lDifal
                    nVFecpST  := IIf(SF3->F3_VFECPST > 0, SF3->F3_VFECPST, SF3->F3_VFESTMT)
                    If nVFecpST > 0 .And. SF2->(FieldPos("F2_NTFECP"))>0
                        RecLock("SF2",.F.)
                        SF2->F2_NTFECP:=cPrefixo+cNumero
                        SF2->(MsUnlock())
                    Endif
                Elseif lDifal
                    If SF2->(FieldPos("F2_GNRFECP"))>0 .And. SF3->(FieldPos("F3_VFCPDIF"))>0
                        If SF3->F3_VFCPDIF > 0
                            RecLock("SF2",.F.)
                            SF2->F2_GNRFECP:=cPrefixo+cNumero
                            SF2->(MsUnlock())
                        Endif
                    Endif
                Else
                    nVFecpST  := SF3->F3_VFECPST
                    If nVFecpST > 0 .And. SF2->(FieldPos("F2_NTFECP"))>0
                        RecLock("SF2",.F.)
                        SF2->F2_NTFECP:=cPrefixo+cNumero
                        SF2->(MsUnlock())
                    Endif
                Endif
            Endif
        Endif
    Endif

    //Verifica se o cliente utiliza o Fluig
    If lGTitFluig

        //Para casos de Re-apuração de ICMS
        //Verifico se existe proceso em aberto para o periodo da solicitacao no Fluig,
        //caso exista realizo o cancelamento da solicitacao corrente e inicio a nova
        DbSelectArea( "CH4" )
        CH4->( DbSetOrder(2) )
        If CH4->( MsSeek( xFilial( "CH4" ) + Alltrim( Str( nApuracao ) ) + Alltrim( Str( nPeriodo ) ) + dToS( dDtIni ) + dToS( dDtFim ) + cNrLivro ) )

            Begin Transaction

                cCodUser := RetCodUsr()

                //Como podem existir varias linhas da tabela CH4 para o mesmo periodo realizo um laco
                //para excluir todas as ocorrecias
                While CH4->( !Eof() ) .And. ( xFilial("CH4") + Alltrim( Str( nApuracao ) ) + Alltrim( Str( nPeriodo ) ) + dToS( dDtIni ) + dToS( dDtFim ) + cNrLivro ) == ;
                                            ( CH4_FILIAL + CH4_TIPOPR + CH4_PERIOD + Dtos( CH4_DTINI ) + Dtos( CH4_DTFIN ) + CH4_LIVRO )


                    //Cancelando a solicitacao no Fluig
                    //If FWECMCancelProcess( Val( CH4->CH4_PROCES ), FWWFColleagueId( RetCodUsr() ) , "Solicitação Cancelada pela apuração de ICMS" ) //"Solicitação Cancelada pela apuração de ICMS" 
                    If FWECMCancelProcess( Val( CH4->CH4_PROCES ), FWWFColleagueId( cCodUser ) , "Solicitação Cancelada pela apuração de ICMS" ) //"Solicitação Cancelada pela apuração de ICMS" 

                        //Excluo o registro da CH4 ( Espelho da CDH )
                        RecLock( "CH4", .F. )
                            CH4->( DbDelete() )
                        CH4->( MsUnlock() )

                        //Excluo o registro da CH3 ( Espelho da SE2 )
                        DbSelectArea("CH3")
                        CH3->( DbSetOrder( 1 ) )
                        If MsSeek( xFilial( "CH3" ) + CH4->CH4_PROCES )

                            //Caso o campo referente a aprovacao nao esteja vazio significa
                            //que a solicitacao anterior ja foi finalizada no Fluig, sendo assim
                            //nao posso apaga-la, apenas gero a nova solicitacao
                            If !Empty( CH3->CH3_APRTIT )
                                DisarmTransaction()
                                Exit
                            EndIf

                            RecLock( "CH3", .F. )
                                CH3->( DbDelete() )
                            CH3->( MsUnlock() )
                        EndIf

                    //Caso por qualquer motivo nao consiga cancelar a solicitacao alerto o usuario
                    //e seto a variavel lGerSolFlg como .F., desta forma as novas solicitacoes
                    //NAO serao geradas no Fluig.
                    Else
                        Help(" ",1,"EXCAPUFLG")
                        DisarmTransaction()
                        lGerSolFlg := .F.
                        Exit
                    EndIf

                    CH4->( DbSkip() )
                End

            End Transaction
        EndIf

        //Caso nao tenha ocorrido problemas com o cancelamento da solicitacao ou
        //seja uma nova solicitacao
        If lGerSolFlg

            //Caso tenha sido gerado um titulo
            If Len( aInfoFluig ) > 0

                //Busco o numero da solicitacao que foi gerada
                nNumSolFlg := StartProc( aInfoFluig )

                //Caso ocorra algum problema para iniciar a solicitacao no Fluig
                If nNumSolFlg <= 0
                    Help(" ",1,"EXCAPUFLG")
                EndIf
            EndIf
        EndIf
    EndIf

    //Restaura variavel Private aRotina. uso AxInclui
    If aSvRot <> Nil
        aRotina := aClone(aSvRot)
    EndIf

    //Restaura area
    dbSelectArea("SF3")
    SF3->(dbSetOrder(1))
    RestArea(aAreaSA2)
    RestArea(aAreaSED)
    RestArea(aAreaSE2)
    RestArea(aAreaSF2)
    RestArea(aAreaSA1)

Return(.T.)

Static Function GeraLinhaApur (nValor, cOrigem)
	Local	lRet	:=	.T.
	//
	If !(cOrigem==Nil)
		If ("MATA952"$cOrigem) .And. (nValor>0) .And. (nValor<SuperGetMv ("MV_MINIPI"))
	 		If !MsgYesNo ('SSS', "BBB")
				lRet	:=	.F.
			EndIf
		EndIf
	Else
		If (nValor>0) .And. (nValor<SuperGetMv ("MV_MINIPI"))
			lRet	:=	.T.
		Else
			lRet	:=	.F.	
		EndIf
	EndIf
Return (lRet)

Static Function xApIncSF6(cAlias,nReg,nOpc,cFunc,aCmpAlt,cTdOk,aAuto)
Local lAPURF6CAN := ExistBlock("APURF6CAN")
Local nOpca := 0

While .T.
	nOpcA := 0
	Begin Transaction
		nOpcA := AxInclui(cAlias,nReg,nOpc,,cFunc,aCmpAlt,cTdOk,,,,,aAuto)
	End Transaction
	If nOpcA <> 1 .And. lAPURF6CAN
		If ExecBlock("APURF6CAN",.F.,.F.)
			Exit
		EndIf
	Else
		Exit
	EndIf
EndDo
dbSelectArea(cAlias)

Return nOpca

User Function uFisIcmF6()
Local cSavAlias:= Alias()
Local nPos := Len(aDadSF6)
Local cOrigem := "MATA954"

If ExistBlock("DADOSTIT")
	aDadosTit := ExecBlock("DADOSTIT", .F., .F., {cOrigem})
	If aDadosTit<>Nil .And. ValType(aDadosTit)=="A"
		aDadSF6[nPos,9] := Iif(Len(aDadosTit)>=1,aDadosTit[1],aDadSF6[nPos,9])
		aDadSF6[nPos,5] := Iif(Len(aDadosTit)>=2,aDadosTit[2],aDadSF6[nPos,5])
	EndIf
EndIf

DbselectArea("SF6")
M->F6_DTARREC := aDadSF6[nPos,2]
M->F6_VALOR   := aDadSF6[nPos,1]
M->F6_MESREF  := aDadSF6[nPos,3]
M->F6_ANOREF  := aDadSF6[nPos,4]
M->F6_DTVENC  := aDadSF6[nPos,5]
M->F6_EST     := aDadSF6[nPos,8]
M->F6_TIPOIMP := aDadSF6[nPos,6]
M->F6_CLAVENC := aDadSF6[nPos,7]
M->F6_NUMERO  := aDadSF6[nPos,9]

M->F6_LOJA    := PAdr('',TamSX3("F6_LOJA")[1])
M->F6_TIPODOC := PAdr('',TamSX3("F6_TIPODOC")[1])

If Len(aDadSF6[nPos]) >= 10 .AND. !Empty(aDadSF6[nPos,10])
	M->F6_DOC := aDadSF6[nPos,10]
EndIf
If Len(aDadSF6[nPos]) >= 11 .AND. !Empty(aDadSF6[nPos,11])
	M->F6_SERIE	:= aDadSF6[nPos,11]
	If SerieNfId("SF6",3,"F6_SERIE") == "F6_SDOC"
		M->F6_SDOC := SubStr(aDadSF6[nPos,11],1,3)
	EndIf
EndIf
If Len(aDadSF6[nPos]) >= 12 .AND. !Empty(aDadSF6[nPos,12])
	M->F6_CLIFOR := aDadSF6[nPos,12]
EndIf
If Len(aDadSF6[nPos]) >= 13 .AND. !Empty(aDadSF6[nPos,13])
	M->F6_LOJA := PadR(aDadSF6[nPos,13],TamSX3("F6_LOJA")[1])
EndIf
If Len(aDadSF6[nPos]) >= 14 .AND. !Empty(aDadSF6[nPos,14])
	M->F6_TIPODOC := Padr(aDadSF6[nPos,14], TamSX3("F6_TIPODOC")[1])
EndIf
If Len(aDadSF6[nPos]) >= 15 .AND. !Empty(aDadSF6[nPos,15])
	M->F6_OPERNF := aDadSF6[nPos,15]
EndIf
If Len(aDadSF6[nPos])>=16 .AND. !Empty(aDadSF6[nPos,16])
	M->F6_INSC := aDadSF6[nPos,16]
EndIf 
If Len(aDadSF6[nPos]) >= 17 .AND. !Empty(aDadSF6[nPos,17])
	M->F6_TIPODOC := Padr(aDadSF6[nPos,17], TamSX3("F6_TIPODOC")[1])
EndIf
If Len(aDadSF6[nPos])>=18 .AND. !Empty(aDadSF6[nPos,18])
	M->F6_NUMCONV := aDadSF6[nPos,18]
EndIf
If Len(aDadSF6[nPos])>=19 .AND. !Empty(aDadSF6[nPos,19]) .And. IsInCallStack('MATA954')
	M->F6_CODMUN := aDadSF6[nPos,19]
EndIf
dbSelectArea(cSavAlias)
Return


Static Function GetCCustos()

Local aCCustos  := {}
Local aArea := GetArea()

dbSelectArea("ZZL")
dbSetOrder(1)
	dbGoTop()
	While !Eof()

		AADD(aCCustos,{ZZL->ZZL_CCDE,ZZL->ZZL_CCPARA})
	    dbSkip()

	EndDo
RestArea( aArea )
    
Return aCCustos

Static Function JurosMulta(nJuros, nMulta, aDados, dDtVenc)

	Local oGet1
	Local cGet1 	:= 0
	Local oSay1
	Local oGet2
	Local cGet2		:= 0
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
    Local nPos  := At("|", aDados[1])

    DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "" FROM 000, 000  TO 253, 180 COLORS 0, 16777215 PIXEL

	@ 002, 004 SAY oSay3 PROMPT "Centro de Custo " + aDados[2] SIZE 120, 007 OF oDlg FONT oBold COLORS 0, 16777215 PIXEL
	@ 012, 004 SAY oSay4 PROMPT "Valor R$ " + AllTrim(Transform(aDados[3], "@E 999,999,999,999.99")) SIZE 120, 007 OF oDlg FONT oBold COLORS 0, 16777215 PIXEL
	@ 022, 004 SAY oSay5 PROMPT "Competência " + Substr(aDados[1], nPos + 5, 2) + "/" + Substr(aDados[1], nPos + 1, 4) SIZE 120, 007 OF oDlg FONT oBold COLORS 0, 16777215 PIXEL

	@ 033, 004 SAY oSay1 PROMPT "Multa" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 041, 004 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL

	@ 056, 004 SAY oSay2 PROMPT "Juros" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 064, 004 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL

	@ 079, 004 SAY oSay6 PROMPT "Dt.Vencimento" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 087, 004 MSGET oGet2 VAR dDtVenc SIZE 060, 010 OF oDlg  COLORS 0, 16777215 PIXEL

	DEFINE SBUTTON oSButton1 FROM 113, 060 TYPE 01 OF oDlg ENABLE ACTION Processa({|| lReturn:= ValOk(cGet1, oDlg, cGet2)},,"Gravando....")

	ACTIVATE MSDIALOG oDlg CENTERED

    nMulta := cGet1
    nJuros := cGet2

Return

Static Function ValOk( nMulta, oDlg, nJuros )

	Local lReturn 	:= .T.

	If nMulta < 0 .Or. nJuros < 0
		Alert("Os valores não podem ser menores do que zero!")
		lReturn := .F.
	EndIf	

	If lReturn
		oDlg:End()
	EndIf

Return lReturn
