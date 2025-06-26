#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'

CLASS Ajus99_NF FROM LongNameClass // OPENFOLD

	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	
	METHOD AtuCont99()
	METHOD AtuCtPag99()
    METHOD AtuLivro99()

	// CLOSEFOLD
ENDCLASS

User Function STAA099()

    Local l1Elem    := .F.
    Local MvParDef  :="12345"
    Local cReturn   := ""

    Private aSit    := {"1 - PIS","2 - COFINS", "3 - CSLL", "4 - INSS", "5 - IRRF"}

 
    f_Opcoes(@cReturn, "Ajuste de Nota Fiscal", aSit, MvParDef, 12, 49, l1Elem)
    
 
    If "1" $ cReturn
        U_STX099PS()    // Rotina de Acerto do PIS
    ElseIf "2" $ cReturn
        U_STX099CF()    // Rotina de Acerto do COFINS
    ElseIf "3" $ cReturn
        U_STX099CS()    // Rotina de Acerto do CSLL
    ElseIf "4" $ cReturn
        U_STX099IN()    // Rotina de Acerto do INSS
    ElseIf "5" $ cReturn
        U_STX099IR()    // Rotina de Acerto do IRRF
    EndIf

Return


/* ---------------------------------------------------------------------------------------------------------
Método    : NEW
Descrição : Função construtora da Classe
--------------------------------------------------------------------------------------------------------- */
METHOD New() CLASS Ajus99_NF // OPENFOLD

	// CLOSEFOLD
RETURN SELF


/* ---------------------------------------------------------------------------------------------------------
Método    : AtuCont99
Descrição : Função para realizar o ajuste na contabilidade
--------------------------------------------------------------------------------------------------------- */
METHOD AtuCont99(oGrid, nPos, cTipo) CLASS Ajus99_NF // OPENFOLD
//User Function AtuCont99(oGrid, nPos, cTipo)

    Local aArea		:= GetArea()
    Local aAreaCT5  := CT5->(GetArea())
    Local lReturn 	:= .T.
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
    Local aCab      := {}
    Local aItem     := {}
	Local nPosDifer	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == IIf(cTipo=="COFINS",'PIS_COFINS',IIf(cTipo=="PIS",'PIS_PIS',IIf(cTipo=="CSLL",'PIS_CSLL',IIf(cTipo=="INSS",'PIS_INSS',IIf(cTipo=="IRRF",'PIS_IRRF','')))))})
    Local nVlrMov   := 0
    //Local cMvCtaDif := SuperGetMV("MV_XCTADIF",.F.,"210520101001")
    //Local cMvCtaCOFINS := SuperGetMV("MV_XCTACOFINS",.F.,"210530101001")
    Local cDebito   := ""
    Local cCredito  := ""
    Local cHistoric := ""
    Local cHistoric2:= ""
    
    //Contabilizacao
    //Local cArquivo  := "TRB"
    Local cPadrao     := ""
    //Local lDigita   := .F.
    //Local nHdlPrv

    
    Local lAchou  := .F.
    Local aPergs   := {}
    Local cNatRen  := Space(TamSX3("DHR_NATREN")[01])


    Private cLote       := '000777'
    Private nValorDif   := oGrid:aCols[nPos][nPosDifer]
    Private lMsErroAuto := .F.
    PRIVATE cNFiscal	:= ""
    PRIVATE cSerie		:= ""
    PRIVATE cA100For	:= ""
    PRIVATE cLoja		:= ""


    if cTipo == "COFINS"
        cPadrao := "T06"
    Elseif cTipo == "PIS"
        cPadrao := "T05"
    Elseif cTipo == "INSS"
        cPadrao := "T03"
    Elseif cTipo == "IRRF"
        cPadrao := "T04"
    Elseif cTipo == "CSLL"
        cPadrao := "T07"
    EndIf



    CT5->(DbSetOrder(1))
    CT5->(DbSeek(xFilial("CT5")+cPadrao))

    /*
    If cTipo == "PIS"
        cDebito   := &(CT5->CT5_DEBITO) //If(nValorDif > 0, SD1->D1_XDEBITO, cMvCtaDif)
        cCredito  := &(CT5->CT5_CREDIT) //If(nValorDif > 0, cMvCtaDif, SD1->D1_XDEBITO)
        nVlrMov   := If(nValorDif > 0, nValorDif, nValorDif * -1)
        cHistoric := "VALOR REF AJUSTE ICMS DIFAL NF " +  ALLTRIM(SF1->F1_DOC)
        cHistoric2:= " " + ALLTRIM(GETADVFVAL('SA2','A2_NOME',XFILIAL("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
    ElseIf cTipo == "COFINS"
        cDebito   := &(CT5->CT5_DEBITO) //If(nValorDif > 0, SD1->D1_XCREDIT, cMvCtaCOFINS)
        cCredito  := &(CT5->CT5_CREDIT) //If(nValorDif > 0, cMvCtaCOFINS, SD1->D1_XCREDIT)
        nVlrMov   := If(nValorDif > 0, nValorDif, nValorDif * -1)
        cHistoric := "VALOR REF AJUSTE COFINS NF " +  ALLTRIM(SF1->F1_DOC)
        cHistoric2:= " " + ALLTRIM(GETADVFVAL('SA2','A2_NOME',XFILIAL("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
    EndIf
    */
    cDebito   := &(CT5->CT5_DEBITO) 
    cCredito  := &(CT5->CT5_CREDIT) 
    nVlrMov   := If(nValorDif > 0, nValorDif, nValorDif * -1)
    cHistoric := "VALOR REF AJUSTE "+cTipo+" NF " +  ALLTRIM(SF1->F1_DOC)
    cHistoric2:= " " + ALLTRIM(GETADVFVAL('SA2','A2_NOME',XFILIAL("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))

    RestArea(aAreaCT5)

    //nHdlPrv   := HeadProva(cLote, "CSTVEND", Alltrim(cUserName), @cArquivo)
    //DetProva(nHdlPrv, cPadrao, "CSTVEND", cLote)
    //RodaProva(nHdlPrv, nVlrMov)

    // Envia para Lancamento Contabil
    //cA100Incl(cArquivo, nHdlPrv, 3, cLote, lDigita, .F.) // Essa e a funcao do quadro dos lancamentos.

    cQuery := "SELECT ISNULL(MAX(CT2_DOC),'000000') AS DOC "
    cQuery += "FROM "+RetSqlName("CT2")+" (NOLOCK) "
    cQuery += "WHERE CT2_FILIAL	= '"+xFilial("CT2")+"' "
    cQuery += "AND CT2_LOTE 	= '" + cLote + "' "
    cQuery += "AND CT2_DATA 	= '"+DToS(dDatabase)+"' "
    cQuery += "AND D_E_L_E_T_ 	= ' ' 	"
    TCQuery cQuery NEW ALIAS (cAlias)

    cDocument	:= Soma1((cAlias)->DOC)

    (cAlias)->(dbCloseArea())

    aAdd(aCab,  {'DDATALANC'	, dDataBase ,NIL} )
    aAdd(aCab,  {'CLOTE'		, cLote 	,NIL} )
    aAdd(aCab,  {'CSUBLOTE'		, '001'		,NIL} )
    aAdd(aCab,  {'CDOC'			, cDocument	,NIL} )
    aAdd(aCab,  {'CPADRAO'		, ''		,NIL} )
    aAdd(aCab,  {'NTOTINF'		, 0			,NIL} )
    aAdd(aCab,  {'NTOTINFLOT'	, 0			,NIL} )

    aAdd(aItem, { {'CT2_FILIAL'     , SD1->D1_FILIAL                    , NIL},;
        {'CT2_LINHA'		, '001'										, NIL},;
        {'CT2_MOEDLC'		, '01'										, NIL},;
        {'CT2_DC'			, '3'										, NIL},;
        {'CT2_DEBITO'		, cDebito                                   , NIL},;
        {'CT2_CREDIT'		, cCredito                                  , NIL},;
        {'CT2_CCC'			, SD1->D1_CC		                        , NIL},;
        {'CT2_CCD'			, SD1->D1_CC		                        , NIL},;
        {'CT2_ITEMC'		, SD1->D1_ITEMCTA	                        , NIL},;
        {'CT2_ITEMD'		, SD1->D1_ITEMCTA	                        , NIL},;
        {'CT2_CLVLDB'		, SD1->D1_FORNECE		                    , NIL},;
        {'CT2_CLVLCR'		, SD1->D1_FORNECE                   		, NIL},;
        {'CT2_VALOR'		, nVlrMov                                   , NIL},;
        {'CT2_CONVER'		, "155  "                                   , NIL},;
        {'CT2_ORIGEM'		, 'STAA099 - ' + UsrFullName(RetCodUsr())   , NIL},;
        {'CT2_HP'			, ''										, NIL},;
        {'CT2_HIST'			, cHistoric                                 , NIL} } )

    aAdd(aItem, { {'CT2_FILIAL'     , SD1->D1_FILIAL                    , NIL},;
        {'CT2_LINHA'		, '002'										, NIL},;
        {'CT2_MOEDLC'		, '01'										, NIL},;
        {'CT2_DC'			, '4'										, NIL},;
        {'CT2_DEBITO'		, ''                                        , NIL},;
        {'CT2_CREDIT'		, ''                                        , NIL},;
        {'CT2_CCC'			, ''		                                , NIL},;
        {'CT2_CCD'			, ''		                                , NIL},;
        {'CT2_ITEMC'		, ''	                                    , NIL},;
        {'CT2_ITEMD'		, ''	                                    , NIL},;
        {'CT2_CLVLDB'		, ''		                                , NIL},;
        {'CT2_CLVLCR'		, ''                   		                , NIL},;
        {'CT2_VALOR'		, 0                                         , NIL},;
        {'CT2_ORIGEM'		, 'STAA099 - ' + UsrFullName(RetCodUsr())   , NIL},;
        {'CT2_HP'			, ''										, NIL},;
        {'CT2_HIST'			, cHistoric2                                , NIL} } )

	If Select("TMP") > 0 
		dbSelectArea("TMP")
		TMP->(dbCloseArea())
	EndIf

    MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab, aItem, 3)

    If lMsErroAuto
        lMsErroAuto := .F.
        lReturn     := .F.
        MsgAlert("ERRO Lançamento" , "Erro")
        mostraErro()
    Else
        
        if cTipo $ "COFINS|PIS|CSLL"

            cNFiscal := SD1->D1_DOC
            cSerie   := SD1->D1_SERIE
            CA100FOR := SD1->D1_FORNECE
            cLoja    := SD1->D1_LOJA

            aAdd(aPergs, {1, "Natureza Rend.",  cNatRen,  "@!",     "A103NATVLD()", "NATREN", ".T.", 5,  .F.})
            
            If ParamBox(aPergs, "Informe a Natureza de Rendimento")
                DbSelectArea("DHR")
                DHR->(DbSetOrder(1))
                lAchou := DHR->(MsSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM))
                If RecLock("DHR",!lAchou)
                    DHR->DHR_FILIAL := xFilial("DHR")
                    DHR->DHR_DOC    := SD1->D1_DOC
                    DHR->DHR_SERIE  := SD1->D1_SERIE
                    DHR->DHR_FORNEC := SD1->D1_FORNECE
                    DHR->DHR_LOJA   := SD1->D1_LOJA
                    DHR->DHR_ITEM	:= SD1->D1_ITEM
                    DHR->DHR_NATREN := MV_PAR01
                    DHR->(MsUnlock())
                Endif
            EndIf
        EndIf

    Endif

    RestArea(aArea)
	// CLOSEFOLD
RETURN lReturn


/* ---------------------------------------------------------------------------------------------------------
Método    : AtuCtPag99
Descrição : Função para realizar o ajuste no Contas a Pagar
--------------------------------------------------------------------------------------------------------- */
METHOD AtuCtPag99(nValorDif, cTipo) CLASS Ajus99_NF // OPENFOLD
//User Function AtuCtPag99(nValorDif, cTipo)

    Local aArea		:= GetArea()
    Local lReturn 	:= .T.

    lReturn:= GerarSE2(nValorDif, "FOR", "NF_NDF")
    lReturn:= GerarSE2(nValorDif, "TX", cTipo)


    RestArea(aArea)
	// CLOSEFOLD
RETURN lReturn


Static Function GerarSE2(nValor, cEntidade, cTipo)
    
	Local aArea		    := GetArea()
    Local cFile
    Local cPatch
    Local cDescErro
    Local cMemo
    Local nMemCount
    Local nI
    Local _aDadosSE2	:= {}
    Local lReturn 	    := .T.
	Local cQuery	    := ""
	Local cAlias	    := GetNextAlias()
    Local cFornec       := 'UNIAO'
    Local cLoja         := '00'
    Local cParcela      := ""
    Local cCentCusto    := ""
    Local cNatureza     := ""
    Local cItemCtb      := ""
    Local cCtCredit     := ""
    Local cCtDebito     := ""
    Local cCtOrcament   := ""
    Local cNumeroCP     := ""
    Local cContrato     := ""
    Local _dEmissao      := dDataBase
    Local _dVencto      := dDataBase
    Local _dDtPagto     := dDataBase
    Local cTitPai       := ""

	Private lMsErroAuto := .F.


    /*
    If cEntidade == "FOR" .AND. nValor < 0
        cTipo       := "NF"
        lReturn     := DataPgto(@_dDtPagto, .F.)
    ElseIf cEntidade == "FOR" .AND. nValor > 0
        cTipo       := "NDF"
    ElseIf cEntidade == "PREF" .AND. nValor < 0
        cTipo       := "NDF"
    ElseIf cEntidade == "PREF" .AND. nValor > 0
        cTipo       := "TX"
        lReturn     := PedeDtPgto(@_dDtPagto, @_dVencto)
    EndIf
    */



    
    
    if cTipo == "COFINS"
        cNatureza := "413054"
        cTipo     := "TX"
        lReturn   := PedeDtPgto(@_dDtPagto, @_dVencto)
    Elseif cTipo == "PIS"
        cNatureza := "413053"
        cTipo     := "TX"
        lReturn   := PedeDtPgto(@_dDtPagto, @_dVencto)
    Elseif cTipo == "INSS"
        cNatureza := "413038"
        cTipo     := "TX"
        lReturn   := PedeDtPgto(@_dDtPagto, @_dVencto)
    Elseif cTipo == "IRRF"
        cNatureza := "413043"
        cTipo     := "TX"
        lReturn   := PedeDtPgto(@_dDtPagto, @_dVencto)
    Elseif cTipo == "CSLL"
        cNatureza := "413042"
        cTipo     := "TX"
        lReturn   := PedeDtPgto(@_dDtPagto, @_dVencto)
    Else
        If cEntidade == "FOR" .AND. nValor < 0
            cTipo       := "NF"
            lReturn     := DataPgto(@_dDtPagto, .F.)
        ElseIf cEntidade == "FOR" .AND. nValor > 0
            cTipo       := "NDF"
        EndIf
        
        lReturn   := DataPgto(@_dDtPagto, .F.)
    EndIf



    If !lReturn
        MsgStop("Processo cancelado pelo usuário.", "Atenção")
        Return .F.
    EndIf

    If cEntidade # "TX"

        cQuery := " SELECT TOP 1 * "
        cQuery += " FROM "+RetSqlName("SE2")+" (NOLOCK) "
        cQuery += " WHERE E2_FILIAL	    = '"+SF1->F1_FILIAL+"' "
        cQuery += "   AND E2_NUM  	    = '"+SF1->F1_DOC+"' "
        cQuery += "   AND E2_TIPO  	    = '"+cTipo+"' "
        cQuery += "   AND E2_PREFIXO  	= '"+SF1->F1_SERIE+"' "
        cQuery += "   AND D_E_L_E_T_ 	= ' ' "
        cQuery += " ORDER BY R_E_C_N_O_ DESC "
        TCQuery cQuery NEW ALIAS (cAlias)

        If !(cAlias)->(Eof())
        

            cNatureza   := (cAlias)->E2_NATUREZ
            cFornec     := (cAlias)->E2_FORNECE
            cLoja       := (cAlias)->E2_LOJA

            cCentCusto  := (cAlias)->E2_CCD
            cItemCtb    := (cAlias)->E2_ITEMD
            cCtCredit   := (cAlias)->E2_CREDIT
            cCtDebito   := (cAlias)->E2_DEBITO
            cCtOrcament := (cAlias)->E2_XCO
            cNumeroCP   := (cAlias)->E2_EC05DB
            cContrato   := (cAlias)->E2_MDCONTR
            cParcela    := If(Empty((cAlias)->E2_PARCELA), "01", Soma1((cAlias)->E2_PARCELA))
            cTitPai     := (cAlias)->E2_TITPAI
        EndIf

        (cAlias)->(dbCloseArea())

    ElseIf cEntidade == "TX"

        cFornec     := 'UNIAO'
        cLoja       := '00'
        
        cQuery := " SELECT TOP 1 * "
        cQuery += " FROM "+RetSqlName("SE2")+" (NOLOCK) "
        cQuery += " WHERE E2_FILIAL	    = '"+SF1->F1_FILIAL+"' "
        cQuery += "   AND E2_FORNECE	= '"+cFornec+"' "
        cQuery += "   AND E2_LOJA  	    = '"+cLoja+"' "
        cQuery += "   AND E2_NUM  	    = '"+SF1->F1_DOC+"' "
        cQuery += "   AND E2_PREFIXO  	= '"+SF1->F1_SERIE+"' "
        cQuery += "   AND D_E_L_E_T_ 	= ' ' "
        cQuery += " ORDER BY R_E_C_N_O_ DESC "
        TCQuery cQuery NEW ALIAS (cAlias)

        If !(cAlias)->(Eof())

        
            cNatureza   := (cAlias)->E2_NATUREZ
            cFornec     := (cAlias)->E2_FORNECE
            cLoja       := (cAlias)->E2_LOJA
        
            cCentCusto  := (cAlias)->E2_CCD
            cItemCtb    := (cAlias)->E2_ITEMD
            cCtCredit   := (cAlias)->E2_CREDIT
            cCtDebito   := (cAlias)->E2_DEBITO
            cCtOrcament := (cAlias)->E2_XCO
            cNumeroCP   := (cAlias)->E2_EC05DB
            cContrato   := (cAlias)->E2_MDCONTR
            cParcela    := If(Empty((cAlias)->E2_PARCELA), "01", Soma1((cAlias)->E2_PARCELA))
            cTitPai     := (cAlias)->E2_TITPAI

            /*
            If cTipo == "NF"
                _dEmissao:= SToD((cAlias)->E2_EMISSAO)
                _dVencto:= SToD((cAlias)->E2_VENCTO)
                 cTitPai:= " "
            EndIf
            */
        EndIf

        (cAlias)->(dbCloseArea())

    EndIf
    

	aadd(_aDadosSE2, {'E2_PREFIXO'	, SF1->F1_SERIE									, NIL})
	aadd(_aDadosSE2, {'E2_NUM'		, SF1->F1_DOC                                   , NIL})
	aadd(_aDadosSE2, {'E2_PARCELA'	, cParcela										, NIL})
	aadd(_aDadosSE2, {'E2_TIPO'   	, cTipo											, NIL})
	aadd(_aDadosSE2, {'E2_FORNECE'	, cFornec										, NIL})
	aadd(_aDadosSE2, {'E2_LOJA'   	, cLoja     									, NIL})
	aadd(_aDadosSE2, {'E2_EMISSAO'	, _dEmissao								        , NIL})
	aadd(_aDadosSE2, {'E2_FILIAL'	, xFilial("SE2")								, NIL})
	aadd(_aDadosSE2, {'E2_FILORIG'	, xFilial("SE2")								, NIL})
	aadd(_aDadosSE2, {'E2_DATALIB'	, Date()                                        , NIL})
	aadd(_aDadosSE2, {'E2_VENCTO' 	, _dVencto 										, NIL})
	aadd(_aDadosSE2, {'E2_VENCREA'	, DataValida(_dVencto) 							, NIL})
	aadd(_aDadosSE2, {'E2_DATAAGE'	, DataValida(_dDtPagto)							, NIL})
	aadd(_aDadosSE2, {'E2_MOEDA'  	, 1												, NIL})
	aadd(_aDadosSE2, {'E2_HIST'   	, "STAA099 - Ajuste de COFINS"					, NIL})
	aadd(_aDadosSE2, {'E2_VALOR'  	, If(nValor < 0, nValor * -1, nValor)			, NIL})
	aadd(_aDadosSE2, {'E2_DESDOBR' 	, "N"   										, NIL})
	aadd(_aDadosSE2, {'E2_NATUREZ'	, cNatureza										, NIL})
	aadd(_aDadosSE2, {'E2_CCD'   	, cCentCusto									, NIL})
	aadd(_aDadosSE2, {'E2_ITEMD'   	, cItemCtb										, NIL})
	aadd(_aDadosSE2, {'E2_CREDIT'  	, cCtCredit										, NIL})
	aadd(_aDadosSE2, {'E2_DEBITO' 	, cCtDebito										, NIL})
	aadd(_aDadosSE2, {'E2_XCO' 		, cCtOrcament									, NIL})
	aadd(_aDadosSE2, {'E2_TXMOEDA' 	, 0												, NIL})
	aadd(_aDadosSE2 ,{'E2_MULTNAT'  , '2'											, Nil})
	aadd(_aDadosSE2 ,{'E2_XOBS'  	, "STAA099 - Ajuste de COFINS"					, Nil})
	aadd(_aDadosSE2 ,{'E2_EC05DB'  	, cNumeroCP										, Nil})
	aadd(_aDadosSE2 ,{'E2_MDCONTR'  , cContrato										, Nil})
	aadd(_aDadosSE2 ,{'E2_ORIGEM'   , "STAA099"										, Nil})
    aadd(_aDadosSE2 ,{'E2_TITPAI'   , cTitPai										, Nil})

	lMsErroAuto := .F.

	MSExecAuto( {|x,y,z| Fina050(x,y,z)}, _aDadosSE2, , 3 )

	if lMsErroAuto

		lReturn := .F.

		cFile		:= "Erro_Adt_"+DTOS(Date())+"_"+Time()+".log"
		cPatch		:= "\TEMP"
		cDescErro	:= ""
        MostraErro()
		MostraErro(cPatch,cFile)

		cMemo := MemoRead(cPatch+"\"+cFile)

		nMemCount := MlCount( cMemo , 80 )
		For nI := 1 To nMemCount
			cDescErro+= AllTrim(MemoLine( cMemo, 80, nI ))+CRLF
		Next nI
	EndIf
			
    RestArea(aArea)

Return lReturn


//-------------------------------------------------
// Função para realizar o ajuste nos livros fiscais
//-------------------------------------------------
METHOD AtuLivro99(oGrid, nPos, cTipo) CLASS Ajus99_NF // OPENFOLD
    
    Local aArea		:= GetArea()
    Local lReturn 	:= .T.
	Local nPosDifer	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == IIf(cTipo=="COFINS",'PIS_COFINS',IIf(cTipo=="PIS",'PIS_PIS',IIf(cTipo=="CSLL",'PIS_CSLL',IIf(cTipo=="INSS",'PIS_INSS',IIf(cTipo=="IRRF",'PIS_IRRF','')))))})  
    Local nPosAlCOF	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_COF'})
    Local nPosBaCOF	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASECOF'})
    Local nPosAlPIS	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_PIS'})
    Local nPosBaPIS	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASEPIS'})
    Local nPosAlCSL	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_CSLL'})
    Local nPosBaCSL:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASECSLL'})
    Local nPosAlINS	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_INS'})
    Local nPosBaINS:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASEINS'})
    Local nPosAlIRR	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_ALIQ_IRR'})
    Local nPosBaIRR:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == 'NEW_BASEIRR'})
    Local nValorDif := oGrid:aCols[nPos][nPosDifer]

    SD1->(RecLock("SD1",.F.))

        If cTipo == "COFINS"
            SD1->D1_BASECOF	:= oGrid:aCols[nPos][nPosBaCOF]
            SD1->D1_ALQCOF	:= oGrid:aCols[nPos][nPosAlCOF]
            SD1->D1_VALCOF	+= nValorDif
        ElseIf cTipo == "PIS"
            SD1->D1_ICMSCOM	:= SD1->D1_ICMSCOM + nValorDif
            SD1->D1_CUSTO	:= SD1->D1_CUSTO + nValorDif
            SD1->D1_BASEPIS	:= oGrid:aCols[nPos][nPosBaPIS]
            SD1->D1_ALQPIS	:= oGrid:aCols[nPos][nPosAlPIS]
            SD1->D1_VALPIS	+= nValorDif
        ElseIf cTipo == "CSLL"
            SD1->D1_BASECSL	:= oGrid:aCols[nPos][nPosBaCSL]
            SD1->D1_ALQCSL	:= oGrid:aCols[nPos][nPosAlCSL]
            SD1->D1_VALCSL	+= nValorDif
        ElseIf cTipo == "INSS"
            SD1->D1_BASEINS	:= oGrid:aCols[nPos][nPosBaINS]
            SD1->D1_ALIQINS	:= oGrid:aCols[nPos][nPosAlINS]
            SD1->D1_VALINS	+= nValorDif
        ElseIf cTipo == "IRRF"
            SD1->D1_BASEIRR	:= oGrid:aCols[nPos][nPosBaIRR]
            SD1->D1_ALIQIRR	:= oGrid:aCols[nPos][nPosAlIRR]
            SD1->D1_VALIRR	+= nValorDif
        EndIf

    SD1->(MsUnlock())   

    SF1->(RecLock("SF1",.F.))

        If cTipo == "COFINS"
            SF1->F1_VALCOFI     += nValorDif
        EndIf
        If cTipo == "PIS"
            SF1->F1_VALPIS     += nValorDif
        EndIf
        If cTipo == "CSLL"
            SF1->F1_VALCSLL     += nValorDif
        EndIf
        If cTipo == "INSS"
            SF1->F1_INSS     += nValorDif
        EndIf
        If cTipo == "IRRF"
            SF1->F1_IRRF     += nValorDif
        EndIf

    DbSelectArea("SE2")
    SE2->(DbSetOrder(6))
	If SE2->(DbSeek(xFilial("SE2")+SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC)))

        SE2->(RecLock("SE2",.F.))

            If cTipo == "COFINS"
                SE2->E2_BASECOF := oGrid:aCols[nPos][nPosBaCOF] 
                SE2->E2_COFINS  += nValorDif
            EndIf
            If cTipo == "PIS"
                SE2->E2_BASEPIS  := oGrid:aCols[nPos][nPosBaPIS]
                SE2->E2_PIS += nValorDif
            EndIf
            If cTipo == "CSLL"
                SE2->E2_BASECSL  := oGrid:aCols[nPos][nPosBaCSL]
                SE2->E2_CSLL += nValorDif
            EndIf
            If cTipo == "INSS"
                SE2->E2_BASEINS  := oGrid:aCols[nPos][nPosBaINS]
                SE2->E2_INSS += nValorDif
            EndIf
            If cTipo == "IRRF"
                SE2->E2_BASEIRF := oGrid:aCols[nPos][nPosBaIRR]
                SE2->E2_IRRF += nValorDif
            EndIf


        SE2->(MsUnlock())   
    Endif

    SFT->(DbSetOrder(1))
    If SFT->(DBSeek(SD1->(D1_FILIAL+'E'+D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD)))
        SFT->(RecLock("SFT",.F.))

            If cTipo == "PIS"
                SFT->FT_ICMSCOM	:= SFT->FT_ICMSCOM + nValorDif
                SFT->FT_BASEPIS	:= oGrid:aCols[nPos][nPosBaPIS]
                SFT->FT_ALIQPIS  := oGrid:aCols[nPos][nPosAlPIS]
                SFT->FT_VALPIS   := SF1->F1_VALPIS
            EndIf
            If cTipo == "COFINS"
                SFT->FT_BASECOF	:= oGrid:aCols[nPos][nPosBaCOF]
                SFT->FT_ALIQCOF  := oGrid:aCols[nPos][nPosAlCOF]
                SFT->FT_VALCOF   := SF1->F1_VALCOFI
            EndIf
            If cTipo == "CSLL"
                SFT->FT_BASECSL	:= oGrid:aCols[nPos][nPosBaCSL]
                SFT->FT_ALIQCSL  := oGrid:aCols[nPos][nPosAlCSL]
                SFT->FT_VALCSL   := SF1->F1_VALCSLL
            EndIf
            If cTipo == "INSS"
                SFT->FT_BASEINS	:= oGrid:aCols[nPos][nPosBaINS]
                SFT->FT_ALIQINS  := oGrid:aCols[nPos][nPosAlINS]
                SFT->FT_VALINS   := SF1->F1_INSS
            EndIf
            If cTipo == "IRRF"
                SFT->FT_BASEIRR	:= oGrid:aCols[nPos][nPosBaIRR]
                SFT->FT_ALIQIRR  := oGrid:aCols[nPos][nPosAlIRR]
                SFT->FT_VALIRR   := SF1->F1_IRRF
            EndIf
        SFT->(MsUnlock()) 
    EndIf


    RestArea(aArea)
	// CLOSEFOLD
Return lReturn


Static Function PedeDtPgto(_dDtPagto, _dDtVencto)
	Local oGet1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oGet3
	Local lReturn	:= .F.

	Static oDlg

	#IFDEF ENGLISH
        cInfo       := "Enter the Expiration and Payment Date of the COFINS ticket."
		cDtPagt		:= "Payday"
		cDtVencto	:= "Due date"
		cInfoDt		:= "For payment, the 5th, 10th, 15th, 20th and 25th of each month are considered."
	#ELSE
        cInfo       := "Informe a Data de Vencimento e de Pagamento para o título de COFINS."
		cDtPagt		:= "Data de Pagamento"
		cDtVencto	:= "Data de Vencimento"
		cInfoDt		:= "Para pagamento são considerados os dias 05, 10, 15, 20 e 25 de cada mês."
	#ENDIF

	DEFINE MSDIALOG oDlg TITLE "" FROM 000, 000  TO 220, 210 COLORS 0, 16777215 PIXEL

	@ 002, 004 SAY oSay3 PROMPT cInfo SIZE 110, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 023, 004 SAY oSay3 PROMPT cDtVencto SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 031, 004 MSGET oGet3 VAR _dDtVencto SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 046, 004 SAY oSay1 PROMPT cDtPagt SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 054, 004 MSGET oGet1 VAR _dDtPagto SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 067, 004 SAY oSay2 PROMPT cInfoDt SIZE 110, 014 OF oDlg COLORS 0, 16777215 PIXEL

	DEFINE SBUTTON oSButton1 FROM 090, 028 TYPE 01 OF oDlg ENABLE ACTION Processa({|| lReturn:= DataPgto(@_dDtPagto, .T., @_dDtVencto, oDlg)},,"Gravando....")
	DEFINE SBUTTON oSButton2 FROM 090, 060 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

Return( lReturn )


Static Function DataPgto(_dDtPagto, lPergunt, _dDtVencto, oDlg)

    Local lReturn   := .T.
    Local dDataPgto := _dDtPagto
    Local dDtSugPg	:= _dDtPagto

    If dDataPgto == Date()
        dDataPgto:= DaySum(dDataPgto, 2)
    EndIf

	If Day(dDataPgto) < 5
		dDtSugPg:= CToD("05/" + StrZero(Month(dDataPgto), 2) + "/" + StrZero(Year(dDataPgto), 4))

		If lPergunt .And. !ApMsgYesNo("A data de pagamento será alterada para " + DToC(dDtSugPg) + "." + CRLF + " Continua?")
			lReturn := .F.
		EndIf
	ElseIf Day(dDataPgto) > 5 .And. Day(dDataPgto) < 10
		dDtSugPg:= CToD("10/" + StrZero(Month(dDataPgto), 2) + "/" + StrZero(Year(dDataPgto), 4))

		If lPergunt .And. !ApMsgYesNo("A data de pagamento será alterada para " + DToC(dDtSugPg) + "." + CRLF + " Continua?")
			lReturn := .F.
		EndIf
	ElseIf Day(dDataPgto) > 10 .And. Day(dDataPgto) < 15
		dDtSugPg:= CToD("15/" + StrZero(Month(dDataPgto), 2) + "/" + StrZero(Year(dDataPgto), 4))

		If lPergunt .And. !ApMsgYesNo("A data de pagamento será alterada para " + DToC(dDtSugPg) + "." + CRLF + " Continua?")
			lReturn := .F.
		EndIf
	ElseIf Day(dDataPgto) > 15 .And. Day(dDataPgto) < 20
		dDtSugPg:= CToD("20/" + StrZero(Month(dDataPgto), 2) + "/" + StrZero(Year(dDataPgto), 4))

		If lPergunt .And. !ApMsgYesNo("A data de pagamento será alterada para " + DToC(dDtSugPg) + "." + CRLF + " Continua?")
			lReturn := .F.
		EndIf
	ElseIf Day(dDataPgto) > 20 .And. Day(dDataPgto) < 25
		dDtSugPg:= CToD("25/" + StrZero(Month(dDataPgto), 2) + "/" + StrZero(Year(dDataPgto), 4))

		If lPergunt .And. !ApMsgYesNo("A data de pagamento será alterada para " + DToC(dDtSugPg) + "." + CRLF + " Continua?")
			lReturn := .F.
		EndIf
	ElseIf Day(dDataPgto) > 25
		dDtSugPg:= CToD("05/" + StrZero(Month(dDataPgto), 2) + "/" + StrZero(Year(dDataPgto), 4))
		dDtSugPg:= MonthSum(dDtSugPg, 1)

		If lPergunt .And. !ApMsgYesNo("A data de pagamento será alterada para " + DToC(dDtSugPg) + "." + CRLF + " Continua?")
			lReturn := .F.
		EndIf
	EndIf

    If lReturn
        _dDtPagto   := dDtSugPg

        If ValType(oDlg) <> "U"
            oDlg:End()
        EndIf
    EndIf

Return lReturn
