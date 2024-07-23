#include 'protheus.ch'
#include 'parmtype.ch'

User Function CNTPRSE2()

	Local _cPlnLocC	:= SuperGetMv("MV_XPLNVLC",.F.,"005")
	
	If CN9->CN9_TPCTO == _cPlnLocC
		SE2->E2_HIST := CN9->CN9_XMSGPG
	EndIf

Return