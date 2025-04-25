#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

user function SampleX31
Local cTabAlias := "SC5"






__SetX31Mode(.F.)

X31UpdTable(cTabAlias)

If __GetX31Error()
    FWAlertError("Houve um erro na atualiza��o da tabela '" + cTabAlias + "':" + CRLF + CRLF + __GetX31Trace())
Else
    FWAlertSuccess("Sucesso na atualiza��o da tabela '" + cTabAlias + "'", "Sucesso")
EndIf


return 
