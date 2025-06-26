#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

user function SampleX31
Local cTabAlias := " "
Local cPasta   := ""
Local cArquivo := ""

cPasta   := GetTempPath()
cArquivo := "LogX31Update.txt"

oFWriter := FWFileWriter():New(cPasta + cArquivo, .T.)

If ! oFWriter:Create()
        MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oFWriter:Error():Message, "Atenção")
Else

    cQuery := ""
    cQuery += "SELECT DISTINCT X2_CHAVE FROM SX2"+cEmpresa+"0 WHERE D_E_L_E_T_ <> '*'"

    If (Select("TSX2") != 0)
        dbSelectArea("TSX2")
        dbCloseArea()
    Endif

    TCQuery cQuery NEW ALIAS "TSX2"

    dbSelectArea("TSX2")
    dbGoTop()
    While !Eof()


        cTabAlias := TSX2->X2_CHAVE
        
        __SetX31Mode(.F.)

        X31UpdTable(cTabAlias)

        If __GetX31Error()
            oFWriter:Write("Houve um erro na atualização da tabela '" + cTabAlias + "':" + CRLF + CRLF + __GetX31Trace() + CRLF)
            //FWAlertError("Houve um erro na atualização da tabela '" + cTabAlias + "':" + CRLF + CRLF + __GetX31Trace())
        Else
            oFWriter:Write("Sucesso na atualização da tabela '" + cTabAlias + "'" + CRLF)
            //FWAlertSuccess("Sucesso na atualização da tabela '" + cTabAlias + "'", "Sucesso")
        EndIf
    
        TSX2->(dbskip())
    EndDo

    oFWriter:Close()
    If MsgYesNo("Arquivo log gerado com sucesso (" + cPasta + cArquivo + ")!" + CRLF + "Deseja abrir?", "Atenção")
        ShellExecute("OPEN", cArquivo, "", cPasta, 1 )
    EndIf

ENDIF


return 
