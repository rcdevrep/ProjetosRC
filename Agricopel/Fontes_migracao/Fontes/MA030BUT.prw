#INCLUDE "PROTHEUS.CH"

User Function MA030BUT()

	Local aBtn := {}

	If cEmpAnt == "01" .and. (cFilAnt == "02" .or. cFilAnt == "06")
		Aadd( aBtn, {"SIGAECO32", {|| U_AGX482()}, "Serasa", "Serasa" , {|| .T.}} )
	EndIf

Return(aBtn)