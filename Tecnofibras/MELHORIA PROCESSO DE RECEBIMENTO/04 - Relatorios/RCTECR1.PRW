#INCLUDE "PROTHEUS.CH"


// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTECR1 - RELATORIO ROMANEIO DE RECEBIMENTO
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 17/06/2024
USER Function RCTECR1()

Local oReport as Object
Local oSection as Object

//Classe TREPORT
oReport := TReport():New('ROMANEIO',"Romaneio Recebimento",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection)})

//Seção 1 
oSection := TRSection():New(oReport,'Romaneio')

//Definição das colunas de impressão da seção 1
TRCell():New(oSection, "F1_DOC" , "TRB", "Numero", /*Picture*/, 50, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "F1_SERIE", "TRB", "Serie" , /*Picture*/, 50, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "F1_FORNECE" , "TRB", "Cod Fornece"    , /*Picture*/, 50, /*lPixel*/, /*{|| code-block de impressao }*/)
//TRCell():New(oSection, "F1_NOMEFOR" , "TRB", "Nome Fornece"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "F1_SOLICIT" , "TRB", "Solicitante"    , /*Picture*/, 50, /*lPixel*/, /*{|| code-block de impressao }*/)

oReport:PrintDialog()

Return

Static Function ReportPrint(oReport,oSection)

#IFDEF TOP

    Local cAlias := "TRB"
    Local cDoc := SF1->F1_DOC
    Local cSerie := SF1->F1_SERIE
    Local cFornece := SF1->F1_FORNECE

    BEGIN REPORT QUERY oSection

        BeginSql alias cAlias
            SELECT F1_DOC,F1_SERIE,F1_FORNECE,F1_SOLICIT
            FROM %Table:SF1% SF1
            WHERE F1_FILIAL = %XFilial:SF1%  AND F1_DOC = %Exp:cDoc% AND F1_SERIE = %Exp:cSerie% AND F1_FORNECE = %Exp:cFornece% AND SF1.%NotDel%
            ORDER BY F1_DOC
        EndSql

    END REPORT QUERY oSection 
    
    oSection:Print()

#ENDIF

return
