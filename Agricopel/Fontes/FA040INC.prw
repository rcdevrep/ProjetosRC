#include 'protheus.ch'
#include 'parmtype.ch'

// Bloquear a geração de titulo quando for empresa 20 - Agricopel Postos e contrato tipo de locacao
User Function FA040INC()

	Local _lReturn 	 := .T.
	Local _cMvPlnLoc := SuperGetMv("MV_XPLNLOC",.F.,"004")
    
    // Verifica se o título está sendo gerado pelo Gestao de Contratos
    If Funname() == "CNTA120" .or. Funname() == "CNTA260"
    	// Verifica se contrato eh de locacao para abortar geracao titulo real quando for empresa 20 - Agricopel Postos
    	If CNA->CNA_TIPPLA == _cMvPlnLoc 
    		If cEmpAnt == "20"
    			_lReturn := .F.
    		EndIf
    	EndIf
    EndIf

Return _lReturn