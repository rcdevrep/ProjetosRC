#include 'protheus.ch'
#include 'parmtype.ch'

User Function CNTPRSE1()

	Local _cPlnLocV	:= SuperGetMv("MV_XPLNLOC",.F.,"004")
	
	If CN9->CN9_TPCTO == _cPlnLocV
		SE1->E1_HIST := CN9->CN9_XMSGPG
	EndIf

Return