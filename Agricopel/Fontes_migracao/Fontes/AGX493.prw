#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

User Function AGX493()

	If Date() <> ddatabase .and. (cEmpAnt == "01" .or. cEmpAnt == "02" .or. cEmpAnt == "39")
		Alert("Atenção! Data base do sistema diferente da data do servidor! Verifique!")
	Else
		MATA460A()
	EndIf

Return()