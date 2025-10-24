#INCLUDE "TOTVS.CH"
#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} F340CAN
Cancela compensação
@type     function
@author      Eurai Rapelli
@since       2023.01.01
/*/
User Function F340CAN()
    Local aVetReg := {} as array
    Local cPadrao
    Local cHistoric, cHistori2, cDocument
    Local nValCont := 0
    Local lRet      := .F.
    Local cAlias := GetNextAlias()
    Private lMsErroAuto := .F.
    Private cLote       := '000780'
   
    
    IF(!Empty(SE2->E2_EC05DB))       

        nValCont := SE5->E5_CAMBIO
        If nValCont < 0
            cPadrao := "V02"
            cHistoric   := "CANCELAMENTO VARIACAO CAMBIAL PASSIVA "
        Else
            cPadrao := "V01"
            cHistoric   := "CANCELAMENTO VARIACAO CAMBIAL ATIVA "
        EndIf

        cHistori2 := "S/NF "+SE2->E2_NUM+" "

        cQuery := "SELECT ISNULL(MAX(CT2_DOC),'000000') AS DOC "
        cQuery += "FROM "+RetSqlName("CT2")+" (NOLOCK) "
        cQuery += "WHERE CT2_FILIAL	= '"+xFilial("CT2")+"' "
        cQuery += "AND CT2_LOTE 	= '" + cLote + "' "
        cQuery += "AND CT2_DATA 	= '"+DToS(dDatabase)+"' "
        cQuery += "AND D_E_L_E_T_ 	= ' ' 	"

        TCQuery cQuery NEW ALIAS (cAlias)

        cDocument	:= Soma1((cAlias)->DOC)

        (cAlias)->(dbCloseArea())

        aCab := {}
        aAdd(aCab,  {'DDATALANC'	, dDataBase ,NIL} )
        aAdd(aCab,  {'CLOTE'		, cLote 	,NIL} )
        aAdd(aCab,  {'CSUBLOTE'		, '001'		,NIL} )
        aAdd(aCab,  {'CDOC'			, cDocument	,NIL} )
        aAdd(aCab,  {'CPADRAO'		, cPadrao	,NIL} )
        aAdd(aCab,  {'NTOTINF'		, 0			,NIL} )
        aAdd(aCab,  {'NTOTINFLOT'	, 0			,NIL} )

        aItem := {}
        aAdd(aItem, { {'CT2_FILIAL'     ,cFilAnt                                                                , NIL},;
                    {'CT2_LINHA'		, '001'										                            , NIL},;
                    {'CT2_MOEDLC'		, '01'										                            , NIL},;
                    {'CT2_DC'			, '3'										                            , NIL},;
                    {'CT2_VALOR'		, Abs(nValCont)                                                         , NIL},;
                    {'CT2_CONVER'		, "155  "                                                               , NIL},;
                    {'CT2_ORIGEM'		, cPadrao+'STACOMP - ' + UsrFullName(RetCodUsr())                               , NIL},;
                    {'CT2_HP'			, ''										                            , NIL},;
                    {'CT2_HIST'			, cHistoric                                                             , NIL},;
                    {'CT2_DEBITO'		, iif(cPadrao=="V01","630520602001",SE2->E2_DEBITO)	                    , NIL},;
                    {'CT2_CREDIT'		, iif(cPadrao=="V01",SE2->E2_DEBITO,"630120601003")	                    , NIL},;
                    {'CT2_CLVLDB'		, SE2->E2_FORNECE		                                                , NIL},;
                    {'CT2_CLVLCR'		, SE2->E2_FORNECE                       	                            , NIL},;
                    {'CT2_CCD'			, SE2->E2_CCD	                                                        , NIL},;
                    {'CT2_CCC'			, SE2->E2_CCD	                                                        , NIL},;
                    {'CT2_ITEMD'		, SE2->E2_ITEMD	                                                        , NIL},;
                    {'CT2_ITEMC'		, SE2->E2_ITEMD	                                                        , NIL},;
                    {'CT2_LP'		    , cPadrao	                                                            , NIL},;
                    {'CT2_EC06CR'		, SE2->E2_MDCONTR	                                                    , NIL},;
                    {'CT2_KEY'		    , cHistoric + " " + cHistori2                                           , NIL},;
                    {'CT2_EC06DB'		, SE2->E2_MDCONTR                                                       , NIL}})

                    //
                    
        aAdd(aItem, {{'CT2_FILIAL'      ,cFilAnt                                                                , NIL},;
                    {'CT2_LINHA'		, '002'										                            , NIL},;
                    {'CT2_DC'			, '4'										                            , NIL},;
                    {'CT2_HIST'			, cHistori2                                                             , NIL}})

        MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab, aItem, 3)
        If lMsErroAuto
            lMsErroAuto := .F.
            lReturn     := .F.
            MsgAlert("ERRO Lançamento" , "Erro")
            mostraErro()
        Endif
    Endif

Return( Nil )

