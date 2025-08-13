#Include "PROTHEUS.CH" 
#include "rwmake.ch"

User Function STAA054
Local aItemsPg := StrTokArr(SuperGetMV("MV_XFORPAG",.F.,"   ;MAN;TED;BOL;"),",")

Local oLabelFilial
Local oLabelNumero 
Local oLabelParcela
Local oLabelPrefixo
Local oLabelTipo
Local oLabelFornecedor
Local oLabelForPag
Local oLabelLinDig
Local oLabelCodBar
Local oLabelMulta
Local oLabelJuros
Local oLabelDesc
Local oLabelAcres  
Local oLabelDecres
Local oLabelBancoFor
Local oLabelDvAgenciaFor
Local oLabelDvContaFor
Local oLabelAgenciaFor
Local oLabelContaFor

Local oFili
Local oFornece
Local oNumero
Local oParcela
Local oPrefixo
Local oTipo
Local oComboForPag
Local oLinDig
Local oCodBar
Local oMulta
Local oJuros
Local oDesc
Local oAcres
Local oDecres
Local oBancoFor
Local oAgenciaFor
Local oDvAgenciaFor
Local oDvContaFor
Local oContaFor
Local oSButton1
Local oSButton2

Local cFili         := SE2->E2_FILIAL
Local cPrefixo      := SE2->E2_PREFIXO
Local cNumero       := SE2->E2_NUM
Local cParcela      := SE2->E2_PARCELA
Local cTipo         := SE2->E2_TIPO
Local cFornece      := SE2->E2_FORNECE
Local cSalvarForPag	:= SE2->E2_XFORPAG
Local cLinDig       := SE2->E2_LINDIG
Local nMulta        := SE2->E2_XMULTA
Local nJuros        := SE2->E2_XJUR
Local nDesc         := SE2->E2_XDESC
Local nAcres        := SE2->E2_ACRESC
Local nDecres       := SE2->E2_DECRESC
Local cBancoFor     := SE2->E2_FORBCO
Local cAgenciaFor   := SE2->E2_FORAGE
Local cDvAgenciaFor := SE2->E2_FAGEDV
Local cContaFor     := SE2->E2_FORCTA
Local cDvContaFor   := SE2->E2_FCTADV
Private cCodBar       := SE2->E2_CODBAR

Static oDlg

If !EMPTY(SE2->E2_BAIXA)
    Alert("Este título possui baixas parciais ou já está baixado totalmente.")
Elseif !EMPTY(SE2->E2_NUMBOR)
    Alert("Este título está em borderô, antes de realizar a alteração remova-o do borderô.")
else
    DEFINE MSDIALOG oDlg TITLE "Alteração de dados bancários" FROM 000, 000  TO 600, 360 COLORS 0, 16777215 PIXEL    
    
    @ 005, 015 SAY oLabelFilial PROMPT "Filial" SIZE 015, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 035 MSGET oFili VAR cFili SIZE 045, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 035, 015 SAY oLabelNumero PROMPT "Numero" SIZE 023, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 035, 035 MSGET oNumero VAR cNumero SIZE 045, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 020, 015 SAY oLabelPrefixo PROMPT "Prefixo" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 020, 035 MSGET oPrefixo VAR cPrefixo SIZE 045, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 020, 091 SAY oLabelTipo PROMPT "Tipo" SIZE 017, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 021, 121 MSGET oTipo VAR cTipo SIZE 045, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 005, 091 SAY oLabelParcela PROMPT "Parcela" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 121 MSGET oParcela VAR cParcela SIZE 045, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 035, 091 SAY oLabelFornecedor PROMPT "Fornecedor" SIZE 027, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 035, 121 MSGET oFornece VAR cFornece SIZE 045, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 056, 015 SAY oLabelForPag PROMPT "Forma de Pagamento" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    oComboForPag := TComboBox():New(66,15,{|u|if(PCount()>0,cSalvarForPag:=u,cSalvarForPag)}, aItemsPg,150,10,oDlg,,,,,,.T.,,,,,,,,,'cSalvarForPag','',2,,CLR_RED)
    @ 083, 015 SAY oLabelLinDig PROMPT "Linha Digitavel" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 093, 015 MSGET oLinDig VAR cLinDig SIZE 150, 010 OF oDlg COLORS 0, 16777215 ON CHANGE CnvLD(cLinDig) PIXEL
    @ 112, 015 SAY oLabelCodBar PROMPT "Codigo de barras" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 122, 015 MSGET oCodBar VAR cCodBar SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 139, 015 SAY oLabelMulta PROMPT "Multa a PG" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 149, 015 MSGET oMulta VAR nMulta SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
    @ 165, 015 SAY oLabelJuros PROMPT "Juros" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 174, 015 MSGET oJuros VAR nJuros SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
    @ 139, 104 SAY oLabelDesc PROMPT "Desconto PG" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 149, 104 MSGET oDesc VAR nDesc SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
    @ 192, 015 SAY oLabelAcres PROMPT "Acrescimo" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 200, 015 MSGET oAcres VAR nAcres SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
    @ 165, 104 SAY oLabelDecres PROMPT "Decrescimo" SIZE 036, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 174, 104 MSGET oDecres VAR nDecres SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
    @ 192, 104 SAY oLabelBancoFor PROMPT "Banco Fornecedor" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 199, 104 MSGET oBancoFor VAR cBancoFor SIZE 055, 010 OF oDlg COLORS 0, 16777215 F3 "BNCFO2" PIXEL
    @ 216, 104 SAY oLabelDvAgenciaFor PROMPT "DV Agencia" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 225, 104 MSGET oDvAgenciaFor VAR cDvAgenciaFor SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 240, 104 SAY oLabelDvContaFor PROMPT "DV Conta" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 249, 104 MSGET oDvContaFor VAR cDvContaFor SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 216, 015 SAY oLabelAgenciaFor PROMPT "Agencia For" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 225, 015 MSGET oAgenciaFor VAR cAgenciaFor SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 240, 015 SAY oLabelContaFor PROMPT "Conta For" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL   
    @ 249, 015 MSGET oContaFor VAR cContaFor SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    
    DEFINE SBUTTON oSButton1 FROM 282, 138 TYPE 01 OF oDlg ENABLE ACTION Processa({|| GrvInfoBanc(cSalvarForPag,cLinDig,cCodBar,nMulta,nJuros,nDesc,nAcres,nDecres,cBancoFor,cAgenciaFor,cDvAgenciaFor,cContaFor,cDvContaFor)  },,"Processando....")
    DEFINE SBUTTON oSButton2 FROM 282, 015 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()
   

    ACTIVATE MSDIALOG oDlg CENTERED
Endif

Return

Static Function GrvInfoBanc(cSalvarForPag,cLinDig,cCodBar,nMulta,nJuros,nDesc,nAcres,nDecres,cBancoFor,cAgenciaFor,cDvAgenciaFor,cContaFor,cDvContaFor)
    iF RECLOCK("SE2", .F.)
        SE2->E2_XFORPAG := cSalvarForPag
        SE2->E2_LINDIG  := cLinDig
        SE2->E2_CODBAR  := cCodBar
        SE2->E2_XMULTA  := nMulta
        SE2->E2_XJUR    := nJuros
        SE2->E2_XDESC   := nDesc
        SE2->E2_ACRESC  := nAcres
        SE2->E2_SDACRES := nAcres
        SE2->E2_DECRESC := nDecres
        SE2->E2_SDDECRE := nDecres
        SE2->E2_FORBCO  := cBancoFor
        SE2->E2_FORAGE  := cAgenciaFor
        SE2->E2_FAGEDV  := cDvAgenciaFor
        SE2->E2_FORCTA  := cContaFor
        SE2->E2_FCTADV  := cDvContaFor
        SE2->E2_XVLIQ   := SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC+SE2->E2_XMULTA+SE2->E2_XJUR+SE2->E2_XTAXA-SE2->E2_XDESC
        MSUNLOCK()

        MSGINFO("Alterações realizadas com sucesso.", "Informativo" )

    else
        Alert("Este título está em uso por outro usuário e não poderá ser salvo")
    Endif

    oDlg:End()

Return

STATIC FUNCTION CnvLD(cLinDig)
    SETPRVT("cStr")
    //
    cStr := LTRIM(RTRIM(cLinDig))

    IF VALTYPE(cLinDig) == NIL .OR. EMPTY(cLinDig)
        // Se o Campo está em Branco não Converte nada.
        cStr := ""
    ELSE
        // Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
        // necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.
        cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
    ENDIF

    DO CASE
    CASE LEN(cStr) == 47
        cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
    CASE LEN(cStr) == 48
        cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
    OTHERWISE
        cStr := cStr+SPACE(48-LEN(cStr))
    ENDCASE

    cCodBar := cStr

RETURN

