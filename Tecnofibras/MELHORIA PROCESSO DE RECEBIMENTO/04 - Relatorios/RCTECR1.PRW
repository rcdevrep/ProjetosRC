#INCLUDE "PROTHEUS.CH"

user Function RCTECR1()

Local oReport as Object
Local oSection as Object

//Classe TREPORT
oReport := TReport():New('EXEMPLO',"Clientes por UF",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection)})

//Se��o 1 
oSection := TRSection():New(oReport,'Clientes')

//Defini��o das colunas de impress�o da se��o 1
TRCell():New(oSection, "A1_COD" , "TRB", "C�digo", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "A1_NOME", "TRB", "Raz�o" , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "A1_EST" , "TRB", "UF"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

//Defin��o da collection
oColl:=TRCollection():New("TOTAL UF", "COUNT", /*oBreak*/,"Total POR UF",;
 /*cPicture*/, /*uFormula*/ oSection:Cell("A1_COD"), /*.lEndSection.*/ .F.,;
 /*.lEndReport.*/ .T., /*oParent*/ oSection, /*bCondition*/,;
 /*uContent*/ oSection:Cell("A1_EST") ) 

oReport:PrintGraphic()
oReport:PrintDialog()

Return

Static Function ReportPrint(oReport,oSection)

#IFDEF TOP

    Local cAlias := "TRB"

    BEGIN REPORT QUERY oSection

        BeginSql alias cAlias
            SELECT A1_COD,A1_NOME,A1_EST
            FROM %table:SA1% 
            ORDER BY A1_FILIAL,A1_EST
        EndSql

    END REPORT QUERY oSection 

    oSection:aCollection[1]:SetGraphic(4,"UF")
    oSection:PrintGraphic()
    oSection:Print()

#ENDIF

return