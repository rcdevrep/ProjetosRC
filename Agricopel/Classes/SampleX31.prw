#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

user function SampleX31
Local cTabAlias := "SC5"






__SetX31Mode(.F.)

X31UpdTable(cTabAlias)

If __GetX31Error()
    FWAlertError("Houve um erro na atualização da tabela '" + cTabAlias + "':" + CRLF + CRLF + __GetX31Trace())
Else
    FWAlertSuccess("Sucesso na atualização da tabela '" + cTabAlias + "'", "Sucesso")
EndIf


return 
