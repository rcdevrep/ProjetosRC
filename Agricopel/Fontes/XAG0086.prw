#INCLUDE 'TOTVS.CH'
#INCLUDE 'RWMAKE.CH'

User Function XAG0086()         
    Local dDataFin  As Date
    Local cUserOK   As Character
    
    Private oDlg    As Object
    Private oDlg2   As Object
    //Private oButton As Object
    Private oCombo  As Object
    Private cCombo  As Character
    Private aItems  As Array

    cUserOK := SuperGetMV('MV_XUSERD',.T.,'000000')

    IF __cUserID $ AllTrim(cUserOK)

        dDataFin    := CTOD(" / / ")

        aItems      := {"Bloqueio Financeiro","Bloq/Lib. Baixa Financeiro"}

        cCombo      := aItems[1]

        DEFINE MSDIALOG oDlg FROM 0,0 TO 150,300 PIXEL TITLE 'Parâmetros Financeiros'
        oCombo:= tComboBox():New(10,10,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,100,20,oDlg,,,,,,.T.,,,,,,,,,"cCombo")
        
        @ 30,010 BMPBUTTON TYPE 01 ACTION Continua()  
        @ 30,050 BMPBUTTON TYPE 02 ACTION Close(oDlg)
        ACTIVATE MSDIALOG oDlg CENTERED

    ELSE
        MsgBox("Sem permissão de acesso","Informacao","INFO")
    EndIF

Return

Static Function Continua()  
    Processa( {|| RunProc()} )
Return

Static Function RunProc()
    Local i As Numeric

    nOpc := 1
    For i := 1 To Len(aItems)
        IF AllTrim(cCombo) == Alltrim(aItems[i])
            nOpc := i
            i := Len(aItems)	
        EndIF
    Next   

    IF nOpc == 1                            
        
        dDataFin := GetMV("MV_DATAFIN")
        
        @ 200,001 TO 390,380 DIALOG oDlg2 TITLE OemToAnsi("Bloqueio Financeiro")
        @ 002,010 TO 050,180
        @ 10,018 Say " Data limite p/ realizacao de operacoes financeiras" Color 255
        @ 36,018 Say " Conteúdo --> " Color 16711680
        @ 36,045 Get dDataFin Size 40,10
        
        @ 70,128 BMPBUTTON TYPE 01 ACTION DataFin(dDataFin)
        @ 70,158 BMPBUTTON TYPE 02 ACTION Close(oDlg2)
        
        ACTIVATE DIALOG oDlg2 CENTERED

    ELSEIF nOpc == 2

        cBaixaFin := GetMV("MV_BXDTFIN")
        
        @ 200,001 TO 390,380 DIALOG oDlg2 TITLE OemToAnsi("Permite Baixar Titulo")
        @ 002,010 TO 050,180
        @ 10,018 Say " Nao permite data de baixa menor que o a data conti" Color 255
        @ 18,018 Say " da no parâmetro MV_DATAFIM (1=Permite, 2=Não Permite)" Color 255
        @ 36,018 Say " Conteúdo --> " Color 16711680
        @ 36,045 Get cBaixaFin Size 40,10
        
        @ 70,128 BMPBUTTON TYPE 01 ACTION BxDtFin(cBaixaFin)
        @ 70,158 BMPBUTTON TYPE 02 ACTION Close(oDlg2)
        
        ACTIVATE DIALOG oDlg2 CENTERED
                                
    EndIF

Return                 

Static Function DataFin(dDataFin)
    SETMV("MV_DATAFIN",DTOS(dDataFin))
    MsgBox("Alteracao realizada com sucesso!!","Informacao","INFO")
    Close(oDlg2)
Return                                                 

Static Function BxDtFin(cBaixaFin)
    SETMV("MV_BXDTFIN",AllTrim(cBaixaFin))
    MsgBox("Alteracao realizada com sucesso!!","Informacao","INFO")
    Close(oDlg2)
Return
