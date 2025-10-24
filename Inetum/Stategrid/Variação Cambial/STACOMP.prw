#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
#Include "FWMVCDEF.CH"

 
/*/{Protheus.doc} STACOMP
Função Para Compensação de Títulos
@param Não recebe parâmetros
@return Não retorna nada
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/
User Function STACOMP()

    Local aPergs    := {}
    Local xPar0     := Space(TamSX3("CN9_NUMERO")[01])
    Local xPar1     := Space(TamSX3("A2_COD"    )[01])
    Local xPar2     := '01'
    Local xPar3     := 0
    Local cDescContr    := ''     


    
    //
    //Adicionando os parametros do ParamBox
    //
    aAdd(aPergs, {1, "Contrato",        xPar0,  X3Picture("CN9_NUMERO"), "U_FExistCN9(MV_PAR01)",           "CN9",  ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Fornecedor",      xPar1,  X3Picture("A2_COD"    ), "U_FExistSA2(MV_PAR02, MV_PAR03)", "SA2",  ".T.", 10,  .F.})
    aAdd(aPergs, {1, "Loja",            xPar2,  X3Picture("A2_LOJA"   ), ".T.",                                  ,  ".F.", 10,  .F.})
    aAdd(aPergs, {1, "Taxa Acordada",   xPar3,  X3Picture("M2_MOEDA5" ), ".T.",                                  ,  ".T.", 80,  .F.})
    
    If ParamBox(aPergs, "Informe os parametros")
        /*
        If Empty(FContrat(@cDescContr))
            FWAlertWarning("Contrato não Vigente!", "Contrato")
            Return()
        Else
        */
        if .not. FUsuAprov(MV_PAR01)
            Return()
        Else     
            fMontaTela(cDescContr)
        EndIf 

    EndIf

Return

Static Function fMontaTela(cDescContr)

    //
    //Janela e componentes
    //
    Local   cJanTitulo  := 'Compensação'
    Local   nLargBtn    := 50

    Private oDialogPvt  := Nil 
    Private oAdtBrw     := Nil
    Private oNFBrw      := Nil    
    Private oTButton    := Nil
    Private lMarker     := .T.
    Private aAdt        := {}
    Private aNF         := {}
    Private oFwLayer

    //Tamanho da janela
    Private aSize       := MsAdvSize(.F.)
    Private nJanLarg    := aSize[5]
    Private nJanAltu    := aSize[6]

    //Fontes
    Private cFontUti    := "Andale Mono"
    Private oFontSub    := TFont():New(cFontUti, , -12)
    Private oFontBtn    := TFont():New(cFontUti, , -12)
    Private oFontSay    := TFont():New(cFontUti, , -12)
    Private oBtnProc, oBtnPrev

    //Cabeçalho
    Private oSayTitCnt, cSayTitCnt := "Contrato: "   + AllTrim(MV_PAR01) + ' - ' + cDescContr
    Private oSayTitFor, cSayTitFor := "Fornecedor: " + AllTrim(MV_PAR02) + ' - ' + GetAdvFVal("SA2", {"A2_NREDUZ"}, FWxFilial("SA2") + MV_PAR02 + MV_PAR03, 1, {''})[1] 
    Private oSayTitAdt, cSayTitAdt := "Adiantamento"
    Private oSayTitNF,  cSayTitNf  := "Nota Fiscal"

    //Valor Total Selecionado Adiantamento e Nota Fiscal
    Private nTotalAdt := 0.00
    Private nTotalNF  := 0.00
    Private cTaxaAcor := "Taxa Acordada: " + cValToChar(Alltrim(Transform(MV_PAR04, X3Picture("M2_MOEDA5" ))))

    //
    //Alimenta o array
    //
    CargaAdt()
    CargaNF()
 
     //Cria a janela
    DEFINE MSDIALOG o3Dlg TITLE cJanTitulo  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
        
        //Criando a camada
        oFwLayer := FwLayer():New()
        oFwLayer:init(o3Dlg,.F.)
   
        //Adicionando 3 linhas, a de título, a superior e a do calendário
        oFWLayer:addLine("TITULO1",  005, .F.)
        oFWLayer:addLine("TITULO2",  005, .F.)
        oFWLayer:addLine("CORPO",    070, .F.)
        oFWLayer:addLine("RODAPE1",  005, .F.)
        oFWLayer:addLine("RODAPE2",  005, .F.)
        oFWLayer:addLine("RODAPE3",  010, .F.)
   
        //Adicionando as colunas das linhas Contrato e Fornecedor
        oFWLayer:addCollumn("BLANKANTES",   001, .T., "TITULO1")
        oFWLayer:addCollumn("HEADERCNT",    049, .T., "TITULO1")
        oFWLayer:addCollumn("BLANK",        001, .T., "TITULO1")
        oFWLayer:addCollumn("HEADERFOR",    049, .T., "TITULO1")
  
        //Adicionando as colunas das linhas Adiantamento e Nota Fiscal
        oFWLayer:addCollumn("BLANKANTES",   001, .T., "TITULO2")
        oFWLayer:addCollumn("HEADERADT",    049, .T., "TITULO2")
        oFWLayer:addCollumn("BLANK",        001, .T., "TITULO2")
        oFWLayer:addCollumn("HEADERNF",     049, .T., "TITULO2")
  
        //Adicionando as colunas das linhas Grid de Adiantamento e Grid Nota Fiscal
        oFWLayer:addCollumn("BLANKANTES",   001, .T., "CORPO")
        oFWLayer:addCollumn("COLGRIDADT",   048, .T., "CORPO")
        oFWLayer:addCollumn("COLBLANK",     002, .T., "CORPO")
        oFWLayer:addCollumn("COLGRIDNF",    048, .T., "CORPO")
        oFWLayer:addCollumn("BLANKDEPOIS",  001, .T., "CORPO")
   
        //Adicionando as colunas das linhas Total de Adiantamento e Nota Fiscal
        oFWLayer:addCollumn("FOOTERTADT",   049, .T., "RODAPE1")
        oFWLayer:addCollumn("BLANKTOTAL",   002, .T., "RODAPE1")
        oFWLayer:addCollumn("FOOTERTNF",    049, .T., "RODAPE1")

        //Adicionando as colunas das linhas Taxa Acordada
        oFWLayer:addCollumn("FOOTERTAXA",   049, .T., "RODAPE2")
        //oFWLayer:addCollumn("BLANKTOTAL",   002, .T., "RODAPE1")
        //oFWLayer:addCollumn("FOOTERTNF",    049, .T., "RODAPE1")

        //Adicionando as colunas das linhas Botão Compensação
        oFWLayer:addCollumn("BTNCOMP",      049, .T., "RODAPE3")
        oFWLayer:addCollumn("BTNSAIR",      049, .T., "RODAPE3")

        //Criando os paineis
        oPanHeaCnt := oFWLayer:GetColPanel("HEADERCNT",  "TITULO1")
        oPanHeaFor := oFWLayer:GetColPanel("HEADERFOR",  "TITULO1")
        oPanHeaAdt := oFWLayer:GetColPanel("HEADERADT",  "TITULO2")
        oPanHeadNF := oFWLayer:GetColPanel("HEADERNF",   "TITULO2")
        oPanGrdAdt := oFWLayer:GetColPanel("COLGRIDADT", "CORPO"  )
        oPanGrdNF  := oFWLayer:GetColPanel("COLGRIDNF",  "CORPO"  )
        oPanRdTadt := oFWLayer:GetColPanel("FOOTERTADT", "RODAPE1")
        oPanRdTNF  := oFWLayer:GetColPanel("FOOTERTNF",  "RODAPE1")
        oPanRdTax  := oFWLayer:GetColPanel("FOOTERTAXA", "RODAPE2")
        oPanComp   := oFWLayer:GetColPanel("BTNCOMP",    "RODAPE3")        
        oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "RODAPE3")        

        //Títulos e SubTítulos
        oSayTitCnt := TSay():New(004, 003, {|| cSayTitCnt}, oPanHeaCnt, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayTitFor := TSay():New(004, 003, {|| cSayTitFor}, oPanHeaFor, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayTitAdt := TSay():New(004, 003, {|| cSayTitAdt}, oPanHeaAdt, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayTitNF  := TSay():New(004, 003, {|| cSayTitNF }, oPanHeadNF, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        //Valor Total Selecionado de Adiantamento e Nota Fiscal 
        oSayTotAdt := TSay():New(004, 003, {|| "Total: " + cValToChar(Alltrim(Transform(nTotalAdt, X3Picture("E2_SALDO" ))))},  oPanRdTadt, "", oFontSay,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayTotNF  := TSay():New(004, 003, {|| "Total: " + cValToChar(Alltrim(Transform(nTotalNF,  X3Picture("E2_SALDO" )))) }, oPanRdTNF,  "", oFontSay,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        //Taxa Acordada 
        oSayTxAcor := TSay():New(004, 003, {|| cTaxaAcor}, oPanRdTax,  "", oFontSay,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

         //Criando os botões
        oBtnComp := TButton():New(006, 150, "Compensar", oPanComp, {|| U_Compensar(), o3Dlg:End() }, nLargBtn, 018, , oFontBtn, , .T., , , , , , )
        oBtnSair := TButton():New(006, 170, "Fechar",    oPanSair, {|| o3Dlg:End()                }, nLargBtn, 018, , oFontBtn, , .T., , , , , , )

        //
        //Criando a janela de Adiantamento
        //
        oAdtBrw  := fwBrowse():New()
        oAdtBrw:setOwner( oPanGrdAdt )
    
        oAdtBrw:setDataArray()
        oAdtBrw:setArray( aAdt )
        oAdtBrw:disableConfig()
        oAdtBrw:disableReport()
    
        //
        //Create Mark Column
        //
        oAdtBrw:AddMarkColumns(  {|| IIf(aAdt[oAdtBrw:nAt,01], "LBOK", "LBNO")},;  //Code-Block image
                                 {|| SelectOneAdt(oAdtBrw, aAdt)                 },;  //Code-Block Double Click
                                 {|| SelectAll(oAdtBrw, 01, aAdt)             })   //Code-Block Header Click
    
        oAdtBrw:addColumn({RetTitle("E2_NUM"    ), {||aAdt[oAdtBrw:nAt,02]}, "C", X3PICTURE("E2_NUM"    ), 1, TamSx3("E2_NUM"    )[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,02]",, .F., .T., , "ETAdt02"})
        oAdtBrw:addColumn({RetTitle("E2_PREFIXO"), {||aAdt[oAdtBrw:nAt,03]}, "C", X3PICTURE("E2_PREFIXO"), 1, TamSx3("E2_PREFIXO")[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,03]",, .F., .T., , "ETAdt03"})
        oAdtBrw:addColumn({RetTitle("E2_TIPO"   ), {||aAdt[oAdtBrw:nAt,04]}, "C", X3PICTURE("E2_TIPO"   ), 1, TamSx3("E2_TIPO"   )[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,04]",, .F., .T., , "ETAdt04"})
        oAdtBrw:addColumn({RetTitle("E2_VALOR"  ), {||aAdt[oAdtBrw:nAt,05]}, "N", X3PICTURE("E2_VALOR"  ), 1, TamSx3("E2_VALOR"  )[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,05]",, .F., .T., , "ETAdt05"})
        oAdtBrw:addColumn({RetTitle("E2_SALDO"  ), {||aAdt[oAdtBrw:nAt,06]}, "N", X3PICTURE("E2_SALDO"  ), 1, TamSx3("E2_SALDO"  )[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,06]",, .F., .T., , "ETAdt06"})
        oAdtBrw:addColumn({RetTitle("E2_VLCRUZ" ), {||aAdt[oAdtBrw:nAt,07]}, "N", X3PICTURE("E2_VLCRUZ" ), 1, TamSx3("E2_VLCRUZ" )[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,07]",, .F., .T., , "ETAdt07"})
        oAdtBrw:addColumn({RetTitle("E2_EMISSAO"), {||aAdt[oAdtBrw:nAt,08]}, "D", X3PICTURE("E2_EMISSAO"), 1, TamSx3("E2_EMISSAO")[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,08]",, .F., .T., , "ETAdt08"})
        oAdtBrw:addColumn({RetTitle("E2_TXMOEDA"), {||aAdt[oAdtBrw:nAt,09]}, "D", X3PICTURE("E2_TXMOEDA"), 1, TamSx3("E2_TXMOEDA")[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,09]",, .F., .T., , "ETAdt09"})
        oAdtBrw:addColumn({RetTitle("E2_VENCREA"), {||aAdt[oAdtBrw:nAt,10]}, "D", X3PICTURE("E2_VENCREA"), 1, TamSx3("E2_VENCREA")[1], , .T. , , .F.,, "aAdt[oAdtBrw:nAt,10]",, .F., .T., , "ETAdt10"})

        oAdtBrw:Activate(.T.)

        //
        //Criando a janela de Nota Fiscal
        //
        oNFBrw:= fwBrowse():New()
        oNFBrw:setOwner( oPanGrdNF )
    
        oNFBrw:setDataArray()
        oNFBrw:setArray( aNF )
        oNFBrw:disableConfig()
        oNFBrw:disableReport()
    
        //oNFBrw:SetLocate() // Habilita a Localização de registros

        //
        //Create Mark Column
        //
        oNFBrw:AddMarkColumns(  {|| IIf(aNF[oNFBrw:nAt,01], "LBOK", "LBNO")},;  //Code-Block image
                                {|| SelectOneNF(oNFBrw, aNF)                 },;  //Code-Block Double Click                                
                             )   //Code-Block Header Click
                                //{|| SelectAll(oNFBrw, 01, aNF)             
    
        oNFBrw:addColumn({RetTitle("E2_NUM"    ), {||aNF[oNFBrw:nAt,02]}, "C", X3PICTURE("E2_NUM"    ), 1, TamSx3('E2_NUM'    )[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,02]",, .F., .T., , "ETNF02"})
        oNFBrw:addColumn({RetTitle("E2_PREFIXO"), {||aNF[oNFBrw:nAt,03]}, "C", X3PICTURE("E2_PREFIXO"), 1, TamSx3('E2_PREFIXO')[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,03]",, .F., .T., , "ETNF03"})
        oNFBrw:addColumn({RetTitle("E2_TIPO"   ), {||aNF[oNFBrw:nAt,04]}, "C", X3PICTURE("E2_TIPO"   ), 1, TamSx3('E2_TIPO'   )[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,04]",, .F., .T., , "ETNF04"})
        oNFBrw:addColumn({RetTitle("E2_VALOR"  ), {||aNF[oNFBrw:nAt,05]}, "N", X3PICTURE("E2_VALOR"  ), 1, TamSx3('E2_VALOR'  )[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,05]",, .F., .T., , "ETNF05"})
        oNFBrw:addColumn({RetTitle("E2_SALDO"  ), {||aNF[oNFBrw:nAt,06]}, "N", X3PICTURE("E2_SALDO"  ), 1, TamSx3('E2_SALDO'  )[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,06]",, .F., .T., , "ETNF06"})
        oNFBrw:addColumn({RetTitle("E2_VLCRUZ" ), {||aNF[oNFBrw:nAt,07]}, "N", X3PICTURE("E2_VLCRUZ" ), 1, TamSx3('E2_VLCRUZ' )[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,07]",, .F., .T., , "ETNF07"})
        oNFBrw:addColumn({RetTitle("E2_EMISSAO"), {||aNF[oNFBrw:nAt,08]}, "D", X3PICTURE("E2_EMISSAO"), 1, TamSx3('E2_EMISSAO')[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,08]",, .F., .T., , "ETNF08"})
        oNFBrw:addColumn({RetTitle("E2_TXMOEDA"), {||aNF[oNFBrw:nAt,09]}, "D", X3PICTURE("E2_TXMOEDA"), 1, TamSx3('E2_TXMOEDA')[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,09]",, .F., .T., , "ETNF09"})
        oNFBrw:addColumn({RetTitle("E2_VENCREA"), {||aNF[oNFBrw:nAt,10]}, "D", X3PICTURE("E2_VENCREA"), 1, TamSx3('E2_VENCREA')[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,10]",, .F., .T., , "ETNF10"})
        oNFBrw:addColumn({"Valor a Compensar",    {||aNF[oNFBrw:nAt,20]}, "N", X3PICTURE("E2_VALOR"  ), 1, TamSx3('E2_VALOR'  )[1], , .T. , , .F.,, "aNF[oNFBrw:nAt,20",, .F., .T., , "ETNF11"})

        oNFBrw:Activate(.T.)

    o3Dlg:Activate(,,,.T.,,,)
 
return .T.

/*/{Protheus.doc} SelectOne
Função Para Marcar/Desmarcar Item Selecionado
@param Objeto e Alias do aArquivo
@return .T.
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function SelectOneNF(oBrowse, aArquivo)

    aArquivo[oBrowse:nAt,1] := !aArquivo[oBrowse:nAt,1]

    TotalNF(oBrowse:nAt) 
    TotalAdt()   
    
    oBrowse:Refresh()

Return .T.

Static Function SelectOneADT(oBrowse, aArquivo)

    aArquivo[oBrowse:nAt,1] := !aArquivo[oBrowse:nAt,1]    
    
    TotalAdt()
    
    oBrowse:Refresh()

Return .T.
    
/*/{Protheus.doc} SelectAll
Função Para Marcar/Desmarcar Todos os itens do Browse
@param Objeto, Culuna, Alias do Arquivo
@return .T.
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
/*Static Function SelectAll(oBrowse, nCol, aArquivo)

    Local _ni := 1

    For _ni := 1 to len(aArquivo)
        aArquivo[_ni,1] := lMarker
    Next

    TotalAdt(0)
    TotalNF()

    lMarker:=!lMarker
    oBrowse:Refresh()

Return .T.*/
 
/*/{Protheus.doc} SelectAll
Função Para Carregar a tabela de Adiantamento
@param Nenhum
@return .T.
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function CargaAdt()

    aAdt    := {}

    BeginSql Alias 'QRYTMPADT'

        COLUMN M2_DATA    AS DATE
        COLUMN E2_EMIS1   AS DATE
        COLUMN E2_VENCREA AS DATE

        SELECT E2_FILIAL
             , E2_NUM
             , E2_PREFIXO 
             , E2_TIPO
             , E2_EMIS1
             , E2_VENCREA
             , E2_VALOR
             , E2_SALDO
             , E2_VLCRUZ 
             , E2_VLCRUZ 
             , E2_TXMOEDA
             , SE2.R_E_C_N_O_ AS E2_RECNO
             , E2_CCD
             , E2_CCC
          FROM %table:SE2% SE2
         WHERE SE2.%notDel% 
           AND E2_FILIAL   = %xFilial:SE2%
           AND E2_TIPO     = %Exp:'PA'%
           AND E2_SALDO    > %Exp:0%
           AND E2_MDCONTR  = %Exp:MV_PAR01%
           AND E2_FORNECE  = %Exp:MV_PAR02%
    EndSql

    DbSelectArea('QRYTMPADT')
    QRYTMPADT->(DbGoTop())
 
    While ! QRYTMPADT->(EoF())

        aadd(aAdt,  { .F.,;
                      QRYTMPADT->E2_NUM,    ;
                      QRYTMPADT->E2_PREFIXO,;
                      QRYTMPADT->E2_TIPO,   ;
                      QRYTMPADT->E2_VALOR,  ;
                      QRYTMPADT->E2_SALDO,  ;
                      QRYTMPADT->E2_VLCRUZ, ;
                      QRYTMPADT->E2_EMIS1,  ;
                      QRYTMPADT->E2_TXMOEDA,;
                      QRYTMPADT->E2_VENCREA,;
                      QRYTMPADT->E2_RECNO,  ;
                      QRYTMPADT->E2_FILIAL, ;
                      QRYTMPADT->E2_CCD,    ;
                      QRYTMPADT->E2_CCC })

        QRYTMPADT->(DbSkip())

    EndDo

    QRYTMPADT->(DbCloseArea())

Return .T.

/*/{Protheus.doc} CargaNF
Função Para Carregar a tabela de Nota Fiscal
@param Nenhum
@return .T.
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function CargaNF()

    aNF := {}

     BeginSql Alias 'QRYTMPNF'

        COLUMN M2_DATA    AS DATE
        COLUMN E2_EMIS1   AS DATE
        COLUMN E2_VENCREA AS DATE

        SELECT E2_FILIAL
             , E2_NUM
             , E2_PREFIXO 
             , E2_TIPO
             , E2_VALOR
             , E2_SALDO
             , E2_VLCRUZ 
             , E2_EMIS1
             , E2_VENCREA
             , E2_ITEMC
             , E2_CCD
             , E2_TXMOEDA
             , SE2.R_E_C_N_O_ AS E2_RECNO
             , E2_FORNECE
             , E2_LOJA
             , E2_ITEMD
             , E2_DEBITO
             , E2_CREDIT
          FROM %table:SE2% SE2
         WHERE SE2.%notDel% 
           AND E2_FILIAL    = %xFilial:SE2%
           AND E2_TIPO      = %Exp:'NF'%
           AND E2_SALDO     > %Exp:0%
           AND ((E2_DATALIB   = %Exp:''% AND E2_SALDO = E2_VALOR) OR (E2_SALDO <> E2_VALOR)) // SE ESTIVER LIBERADO, OU SE ESTIVER BAIXADO PARCIAL.
           AND (E2_MDCONTR  = %Exp:MV_PAR01% OR E2_MDCONTR = %Exp:''%) 
           AND E2_FORNECE   = %Exp:MV_PAR02%
           AND E2_LOJA      = %Exp:MV_PAR03%
           

   EndSql

    DbSelectArea('QRYTMPNF')
    QRYTMPNF->(DbGoTop())
 
    While ! QRYTMPNF->(EoF())

        aadd(aNF,  { .F.,;
                      QRYTMPNF->E2_NUM,                                  ;  //1
                      QRYTMPNF->E2_PREFIXO,                              ;  //2
                      QRYTMPNF->E2_TIPO,                                 ;  //3
                      QRYTMPNF->E2_VALOR,                                ;  //4
                      QRYTMPNF->E2_SALDO,                                ;  //5
                      QRYTMPNF->E2_VLCRUZ,                               ;  //6
                      QRYTMPNF->E2_EMIS1,                                ;  //7
                      Iif(MV_PAR04 == 0, QRYTMPNF->E2_TXMOEDA, MV_PAR04),;  //8
                      QRYTMPNF->E2_VENCREA,                              ;  //9
                      QRYTMPNF->E2_RECNO,                                ;  //10
                      QRYTMPNF->E2_ITEMC,                                ;  //11
                      QRYTMPNF->E2_CCD,                                  ;  //12
                      QRYTMPNF->E2_FILIAL,                               ;  //13
                      QRYTMPNF->E2_FORNECE,                              ;  //14
                      QRYTMPNF->E2_LOJA,                                 ;  //15
                      QRYTMPNF->E2_ITEMD,                                ;  //16
                      QRYTMPNF->E2_DEBITO,                               ;  //17
                      QRYTMPNF->E2_CREDIT, 0 })                          //18

        QRYTMPNF->(DbSkip())

    EndDo

    QRYTMPNF->(DbCloseArea())

Return .T.

/*/{Protheus.doc} FContrat
Função Para Carregar a descricao do contrato
@param Descricao do Contrato (Por Referência)
@return Descricao do Contrato
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function FContrat(cDescContr)

    Local   cWhere	    := "%CN1_CODIGO = CN9_TPCTO%"
    Default cDescContr  := ''

     BeginSql Alias 'QRYCONTRAT'

        SELECT CN1_DESCRI
          FROM %table:CN9% CN9
                INNER JOIN %table:CN1% CN1  
                        ON CN1.%notDel%
                       AND CN1_FILIAL   = %xFilial:CN1%
                       AND %Exp:cWhere%
         WHERE CN9.%notDel% 
           AND CN9_FILIAL = %xFilial:CN9%
           AND CN9_NUMERO = %Exp:MV_PAR01%
           AND CN9_SITUAC = %Exp:'05'%
   EndSql

    DbSelectArea('QRYCONTRAT')
    QRYCONTRAT->(DbGoTop())
 
    If ! QRYCONTRAT->(EoF())
        cDescContr  := QRYCONTRAT->CN1_DESCRI
    EndIf

    QRYCONTRAT->(DbCloseArea())

Return(cDescContr)

/*/{Protheus.doc} FExistCN9
Função Para Validar a existência do contrato vigente
@param Contrato
@return .T. ou .F.
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
User Function FExistCN9(cNumContra)
 
    Local lRet  := .T.

     BeginSql Alias 'QRYCN9'

        SELECT CN9_NUMERO
          FROM %table:CN9% CN9
         WHERE CN9.%notDel% 
           AND CN9_FILIAL = %xFilial:CN9%
           AND CN9_NUMERO = %Exp:cNumContra%
           AND (CN9_SITUAC = %Exp:'05'%
                OR CN9_SITUAC = %Exp:'06'%)
   EndSql

    DbSelectArea('QRYCN9')
    QRYCN9->(DbGoTop())
 
    If QRYCN9->(EoF())
        MsgInfo("Contrato Inválido!")
        lRet    := .F.
    EndIf

    QRYCN9->(DbCloseArea())

Return(lRet)

/*/{Protheus.doc} FExistSA2
Função Para Validar a existência do Fornecedor
@param  Fornecedor e Loja
@return .T. ou .F.
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
User Function FExistSA2(cCodForn, cLoja)
 
    Local lRet  := .T.
    Local aArea := FWGetArea()

    DBSelectArea("SA2")
    DBSetOrder(1)
    If ! ( SA2->( DBSeek( FWxFilial( "SA2" ) + cCodForn + cLoja ) ) )
        MsgInfo("Fornecedor não Encontrado!")
        lRet    := .F.
    EndIf

    FWRestArea(aArea)

Return(lRet)

/*/{Protheus.doc} TotalAdt
Função  Para Calcular o Total dos Adiantamentos Selecionados
@param  Nenhum
@return Nenhum
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function TotalAdt()

    Local _ni   := 1

    For _ni := 1 to len(aAdt)   

        If aAdt[_ni, 01]
            nTotalAdt += aAdt[_ni, 07] 
        EndIf    
    Next

    oSayTotAdt:Refresh()

Return()

/*/{Protheus.doc} TotalNF
Função  Para Calcular o Total das Notas Fiscais Selecionadas
@param  Nenhum
@return Nenhum
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function TotalNF(nPosicao)

    Local _ni   := 1
     Local aSize := {}
    Local nSldCmp := 0
    Local nOpca := 0

    nTotalAdt   := 0

    aSize := MSADVSIZE()

    DEFINE MSDIALOG oDlg2 TITLE "Compensação" From 0,0 To 300,500 PIXEL //"Selecao de Adiantamento"
    
    @ 35,05  SAY "Saldo a Compensar" PIXEL OF oDlg2 SIZE 100,7 
	@ 65,05  MSGET oGetUser VAR nSldCmp PICTURE "@E 999,999,999.99" WHEN .T. PIXEL OF oDlg2 SIZE 100,7

    ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,	{|| If(nSldCmp > 0, (nOpca := 1, oDlg2:End()), .F.)},{|| nOpca := 2,oDlg2:End()},,)

    IF(nPosicao > 0 .AND. nOpca == 1)
        aNF[nPosicao, 20] := nSldCmp
    ENDIF

    nTotalNF    := 0

    For _ni := 1 to len(aNF)
        If aNF[_ni, 01]
            nTotalNF += aNF[_ni, 20] 
        EndIf    
    Next

    oSayTotNF:Refresh() 

Return()

/*/{Protheus.doc} Compensar
Função  de Compensação de Adiantamenros X Notas Fiscais 
@param  Nenhum
@return Nenhum
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
User Function Compensar()
    
    //Salva Parametros Compensação
    Local   cFornec     := MV_PAR02
    Local   cLoja       := MV_PAR03   
    Private   nTxAcorda   := MV_PAR04
    Private nTotCmpAdt  := 0
    Private nTotCmpNF   := 0
    Private nTotCmpAco  := 0

    If nTotalAdt > 0 .and. nTotalNF > 0 
        Processa({|| FProcessa(nTxAcorda)                 }, 'Adiantamentos...')
        Processa({|| FGerContab(cFornec, cLoja, nTxAcorda)}, 'Notas Fiscais...')    
    Else
        FWAlertWarning("Adiantamento e/ou Nota Fiscal, Não Informado(s).", "Selecionar Registros")
    EndIf
Return

/*/{Protheus.doc} fProcessa
Função  Realiza a Compensação 
@param  Nenhum
@return Nenhum
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function FProcessa(nTxAcorda)
    Local aArea     := FWGetArea()
    Local nAtual    := 0
    Local nTotal    := 0
    Local nAdt      := 0
    Local nNf       := 0
    Local nSldComp  := 0
    Local nHdl      := 0
    Local nOperacao := 0
    Local nAcomp    := 0
    Local lRet      := .F.
    Local lHelp     := .T.
    Local aNF_Comp  := {}
    Local aPA_NDF   := {}
    Local aEstorno  := {}
    Local aRecSE5   := {}
    Local aNDFDados := {}
    Local bBlock    := Nil
    Local nCmpAdt   := 0
    Local nCmpNF    := 0
    Local nCmpAco   := 0
    Local aContabil := {}
    Local nI        := 0
     
    Local cIdFK2    := ""
    Local cFilIni   := cFilAnt
    Local aDados   := {}
    Local _aParametrosJob := {}
	Local cAlias	
    Local cHistoric, cHistori2
    Local cPadrao
    Local nValComp
    Local nValCont
    Local aAreaCT2
    Local nRecSE2
 
	Private lMsErroAuto := .F.
    Private cLote       := '000780'

    //Aciona a rotina para alterar o módulo
    aDados := SetModulo("SIGACOM", "COM")
   
    Pergunte("AFI340", .F.)
    lContabiliza    := .T.
    lAglutina       := MV_PAR08 == 1
    lDigita         := MV_PAR09 == 1

    aContabil := {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.}

    ProcRegua(Len(aAdt))
     
    nAtual  := 1
    nTotal  := len(aAdt)

    For nAdt := 1 to len(aAdt)

        If aAdt[nAdt, 01]
            
            nAtual++
            IncProc('Processando Adiantamento ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

            nAcomp := aAdt[nAdt, 7]

            For nNf := 1 to len(aNF)
    
                If nAcomp > 0 

                    If aNF[nNf, 01]

                        If aAdt[nAdt, 7] >= aNF[nNf, 7]
                            nSldComp := aNF[nNf, 20]
                            nValComp := aNF[nNf, 20] / nTxAcorda
                        Else
                            nSldComp := aAdt[nAdt, 6]
                            nValComp := aAdt[nAdt, 6] 
                            //MSGSTOP("Valor da NF superior ao Adiantamento, não é possivel fazer a compensação.")
                            //return .F.
                        EndIf
                        
                        nCmpAdt  := nSldComp * aAdt[nAdt, 9] 
                        nCmpNF   := nSldComp * aNF[ nNf,  9]
                        nCmpAco  := nSldComp * nTxAcorda

                        //Valor da nota / Taxa do Aditivo
                        //aAdt[nAdt, 9]

                        aPA_NDF  := {aAdt[nAdt, 11]}
                        aNF_Comp := {aNF[ nNf,  11]}

                        //PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL aAdt[nAdt, 12] MODULO "COM"
                        cFilAnt  := aAdt[nAdt, 12]
                        cModulo  := "COM"

                        
                        nRecSE2 := SE2->(Recno())

                        //nVrTaxa := (nVrComp / nTaxaPA) - nVrComp
                        //nVrComp := nVrComp + nVrTaxa

                        
                        SE2->(DbGoTo(aNF[nNf, 11]))
                        Reclock("SE2", .F.)
                            SE2->E2_DATALIB := Date()
                            SE2->E2_XVALCMP := nValComp
                        SE2->(MsUnlock())

 
                        ARECSE5 := {}
                        nTaxaADT := aAdt[nAdt, 9] 
                        
                        //_aParametrosJob := {cFilAnt, aNF_Comp, aPA_NDF, aContabil, nSldComp, dDatabase, aNF[nNf, 14]}
                        _aParametrosJob := {cFilAnt, aNF_Comp, aPA_NDF, aContabil, nValComp, dDatabase, aNF[nNf, 14]}
                        lRet 			:= U_CompAuto(_aParametrosJob, nTxAcorda )

                       // FOR 
                       /* SE2->(dbGoTo(aNF_Comp[nNf]))
                        IF (round(0 ,0) <> round(SE2->E2_SALDO,0)) 
                            Aviso("Compensação Automática","A compensação automática da NF com o adiantamento "+SE2->E2_NUM+" não foi realizada, informar ao requisitante. Verificar o título de adiantamento no financeiro.",{"OK"})					
                            //Notifica requisitante do erro na compensação
                            U_MTMAILCP()
                            DisarmTransaction()							
                        endif

                        //Posiciona no PA para validar os saldos
                        SE2->(dbGoTo(aPA_NDF[nNf,1]))
                        If (0 == SE2->E2_SALDO) 
                            Aviso("Compensação Automática","A compensação automática da NF com o adiantamento "+SE2->E2_NUM+" via contrato não foi realizada. Verificar o título de adiantamento no financeiro.",{"OK"})
                            //Notifica requisitante do erro na compensação
                            U_MTMAILCP()
                            DisarmTransaction()
                        EndIf


                        //Verifica se o valor compensado é menor que o valor original e atualiza a ZZ1.
                        DbSelectArea("ZZ1")
                        DbGoTo(aValCmp[nY][2])
                        IF ZZ1->ZZ1_VLCOMP <> nVrComp
                            ZZ1->(RecLock("ZZ1",.F.))
                                ZZ1->ZZ1_VLCOMP := nVrComp
                            ZZ1->(MsUnlock())
                        ENDIF
                        */





                        If lRet
                            
                            nTotCmpAdt  += nSldComp 
                            nTotCmpNF   += nSldComp
                            nTotCmpAco  += nSldComp * nTxAcorda
                            nAcomp      -= nSldComp
                            nValCont    := (nValComp * aAdt[nAdt, 9]) - (nValComp * nTxAcorda)

                            RECLOCK("SE5",.F.)

                            SE5->E5_CAMBIO := nValCont

                            MSUNLOCK()

                            //---INCLUIR A CONTABILIZAÇÃO DA VARIAÇÃO CAMBIAL---------------------------------------------------------
                            
                            If nValCont <> 0
                                aAreaCT2 := GetArea()

                                cAlias	    := GetNextAlias()

                                If nValCont > 0
                                    cPadrao := "V02"
                                    cHistoric   := "VARIACAO CAMBIAL PASSIVA "
                                Else
                                    cPadrao := "V01"
                                    cHistoric   := "VARIACAO CAMBIAL ATIVA "
                                EndIf
                                cNReduz  :=	Posicione("SA2",1,xFilial("SA2")+aNF[nNf, 15]+aNF[nNf, 16],"A2_NREDUZ")
                                cHistori2 := "S/NF "+aNF[nNf, 2]+" "+ cNReduz

                                cQuery := "SELECT ISNULL(MAX(CT2_DOC),'000000') AS DOC "
                                cQuery += "FROM "+RetSqlName("CT2")+" (NOLOCK) "
                                cQuery += "WHERE CT2_FILIAL	= '"+xFilial("CT2")+"' "
                                cQuery += "AND CT2_LOTE 	= '" + cLote + "' "
                                cQuery += "AND CT2_DATA 	= '"+DToS(dDatabase)+"' "
                                cQuery += "AND D_E_L_E_T_ 	= ' ' 	"
                                TCQuery cQuery NEW ALIAS (cAlias)

                                cDocument	:= Soma1((cAlias)->DOC)

                                (cAlias)->(dbCloseArea())

                                nRecSE2 := SE2->(Recno())

                                SE2->(DbGoTo(aAdt[nAdt, 11]))
                                

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
                                            {'CT2_DEBITO'		, iif(cPadrao=="V01",SE2->E2_DEBITO,"630520602001")	                    , NIL},;
                                            {'CT2_CREDIT'		, iif(cPadrao=="V01","630120601003",SE2->E2_DEBITO)	                    , NIL},;
                                            {'CT2_CLVLDB'		, SE2->E2_FORNECE		                                                , NIL},;
                                            {'CT2_CLVLCR'		, SE2->E2_FORNECE                       	                            , NIL},;
                                            {'CT2_CCD'			, SE2->E2_CCD	                                                        , NIL},;
                                            {'CT2_CCC'			, SE2->E2_CCD	                                                        , NIL},;
                                            {'CT2_ITEMD'		, SE2->E2_ITEMD	                                                        , NIL},;
                                            {'CT2_ITEMC'		, SE2->E2_ITEMD	                                                        , NIL},;
                                            {'CT2_LP'		    , cPadrao	                                                            , NIL},;
                                            {'CT2_KEY'		    , cHistoric + " " + cHistori2                                           , NIL},;
                                            {'CT2_EC06CR'		, SE2->E2_MDCONTR	                                                    , NIL},;
                                            {'CT2_EC06DB'		, SE2->E2_MDCONTR                                                       , NIL}})
                                            
                                aAdd(aItem, {{'CT2_FILIAL'      ,cFilAnt                                                                , NIL},;
                                            {'CT2_LINHA'		, '002'										                            , NIL},;
                                            {'CT2_DC'			, '4'										                            , NIL},;
                                            {'CT2_HIST'			, cHistori2                                                             , NIL}})
                                

                                
                                If Select("TMP") > 0 
                                    dbSelectArea("TMP")
                                    TMP->(dbCloseArea())
                                EndIf

                                MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab, aItem, 3)
                            
                                SE2->(DbGoTo(nRecSE2))

                                If lMsErroAuto
                                    lMsErroAuto := .F.
                                    lReturn     := .F.
                                    MsgAlert("ERRO Lançamento" , "Erro")
                                    mostraErro()
                                Endif

                                RestArea(aAreaCT2)
                            Endif
                            

                            //--------------------------------------------------------------------------------------------------------



                            ConOut("Compensação realizada com sucesso")
                        Else
                            ConOut("Ocorreu um erro no processo de compensação")
                        EndIf
                    EndIf
                EndIf
            Next
        EndIf
    Next

    FWFREEVAR(@nTxAcorda)

    cFilAnt := cFilIni 
                     

    FWAlertInfo("Processo Finalizado!", "Compensação")

    FWRestArea(aArea)
Return

/*/{Protheus.doc} fGerContab
Função  Gera a Contabilização das Compensações 
@param  Fornecedor, cLoja
@return Nenhum
@author Vagner Almeida
@owner 
@version Protheus 12
@since Nov|2024
/*/ 
Static Function FGerContab(cFornec, cLoja, nTxAcorda)

    Local aArea     := FWGetArea()
    
    //Contabilizacao
    Local   nHdlPrv
    Local   cArquivo    := "SE2"
    Local   cLPPassivo  := "599"
    Local   cLPAtivo    := "600"
    Local   lDigita     := .F.
    Local   nVarCamb    := 0
    Private _nTotMov  	:= 1
    Private _nTotMed  	:= 0
    Private _nVlrMov   	:= 0
	Private _cCCusto	:= ""
	Private _cTipoOp	:= ""
	Private _cFornec	:= cFornec
	Private _cProjeto	:= ""
    Private cLote       := '000780'
    Private lMsErroAuto := .F.

	SA2->(DBSetOrder(1))
	SA2->(DBSeek(xFilial("SA2") + cFornec + cLoja))

    nHdlPrv := HeadProva(cLote, "STACOMP", Alltrim(cUserName), @cArquivo)
    //DetProva(nHdlPrv, cPadrao, "STACOMP", cLote)
    //RodaProva(nHdlPrv, _nVlrMov)

    //Variação Cambial
    If nTxAcorda > 0
        nVarCamb := ABS(nTotCmpAdt - nTotCmpAco)
        If nVarCamb <> 0
            nHdlPrv := HeadProva(cLote, "STACOMP", Alltrim(cUserName), @cArquivo)
            If nTotCmpAdt < nTotCmpAco 
                DetProva(nHdlPrv, cLPPassivo, "STACOMP", cLote)
            Else   
                DetProva(nHdlPrv, cLPAtivo,   "STACOMP", cLote)
            EndIf     
            RodaProva(nHdlPrv, nVarCamb)
            cA100Incl(cArquivo, nHdlPrv, 3, cLote, lDigita, .F.) 
        EndIf

    EndIf

    FWRestArea(aArea)

Return

/*/{Protheus.doc} fGerContab
Função  Verifica se Usuario Pode Manipular Contrato 
@param  Contrato
@return Logico
@author Vagner Almeida
@owner 
@version Protheus 12
@since Jan|2025
/*/ 
Static Function FUsuAprov(cNumContra)
    Local lRet      := .T.
    Local cCodUsu   := RetCodUsr()

    BeginSql Alias 'QRYCNN'

        SELECT CNN_CONTRA
          FROM %table:CNN% CNN
         WHERE CNN.%notDel% 
           AND CNN_FILIAL = %xFilial:CNN%
           AND CNN_CONTRA = %Exp:cNumContra%
           AND CNN_USRCOD = %Exp:cCodUsu%

    EndSql

    DbSelectArea('QRYCNN')
    QRYCNN->(DbGoTop())
 
    If QRYCNN->(EoF())
        lRet    := .F.
        FWAlertWarning("Usuário Sem Permissão Para Manipular Este Contrato!", "Contrato")
    EndIf

    QRYCNN->(DbCloseArea())

Return(lRet)
