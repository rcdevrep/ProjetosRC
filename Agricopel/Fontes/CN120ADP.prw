#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch' 

User Function CN120ADP()

	Local _cMvPlCdc	 := SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local _cMvPlJur  := SuperGetMv("MV_XPLNJUR",.F.,"003")
    Local _cMvSe2Atr := SuperGetMv("MV_XSE2ATR",.F.,.F.)

    // exclui titulo gerado, quando for juros sobre cdc
    If CN9->CN9_ESPCTR == '1'
	    // Consulta tabela SE2
	    cQryAux	:= " "
		cQryAux	+= " SELECT R_E_C_N_O_ FROM " + RetSqlName("SE2")
		cQryAux	+= " WHERE D_E_L_E_T_ = ' ' "
		cQryAux	+= " AND E2_FILIAL = '" + xFilial('SE2') + "' 
		cQryAux	+= " AND E2_MDCONTR = '" + CND->CND_CONTRA + "'
		cQryAux	+= " AND E2_MDPLANI = '" + CND->CND_NUMERO + "'
		cQryAux	+= " AND E2_MDPARCE = '" + CND->CND_PARCEL + "'
		//cQryAux	+= " AND E2_FORNECE = '" + CND->CND_FORNEC + "'
		cQryAux	+= " AND E2_FORNECE = '" + CNA->CNA_FORNEC + "'
		//cQryAux	+= " AND E2_LOJA = '" + CND->CND_LJFORN + "'
		cQryAux	+= " AND E2_LOJA = '" + CNA->CNA_LJFORN + "'
		cQryAux	+= " AND E2_ORIGEM = 'CNTA121' "
		If Select("Qry1") <> 0
			Qry1->(dbCloseArea())
		EndIf
		TCQuery cQryAux Alias Qry1 New
		dbSelectArea("QRY1")
		Qry1->(dbGotop()) 
		If !Qry1->(Eof())
		    dbSelectArea("SE2")
			DBGoTo(Qry1->R_E_C_N_O_)
			If Funname() == "CNTA121" .or. Funname() == "CNTA260"
		    	// Verifica se contrato eh de juros ou locacao para abortar geracao titulo real
		    	If (CNA->CNA_TIPPLA == _cMvPlJur)
		    		RecLock("SE2",.F.)
				 	SE2->(dbdelete())
				 	MsUnLock("SE2")
		    	ElseIf SE2->E2_EMISSAO < FirstDate(Date()) .and. !(_cMvSe2Atr)
		    		RecLock("SE2",.F.)
				 	SE2->(dbdelete())
				 	MsUnLock("SE2")
		    	EndIf
		    EndIf
		    // Verifica se o título está sendo gerado pelo Gestao de Contratos
		    If Funname() == "CNTA300"
		    	// Verifica se contrato eh de CDC para abortar geracao titulo provisorio
		    	If (CNA->CNA_TIPPLA == _cMvPlJur) .and. (CN9->CN9_TPCTO == _cMvPlCdc)
		    		RecLock("SE2",.F.)
				 	SE2->(dbdelete())
				 	MsUnLock("SE2")
		    	EndIf
		    EndIf
		EndIf
	EndIf

Return
