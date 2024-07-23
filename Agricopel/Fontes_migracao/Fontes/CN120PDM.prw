#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch' 

User Function CN120PDM()

	Local aArea      := GetArea()
	Local ExpL1		 := PARAMIXB[1]
	Local _cMvPlCdc	 := SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local _cMvPlJur  := SuperGetMv("MV_XPLNJUR",.F.,"003")
	Local _cMvEfTit  := SuperGetMv("MV_XEFTTIT",.F.,.T.)
    Local _cMvSe2Atr := SuperGetMv("MV_XSE2ATR",.F.,.F.)

	If _cMvEfTit

		If !ISINCALLSTACK("U_GERTITDS")
	
			// Verifica se titulo financeiro foi criado CN9_ESPCTR = 1 (SE2) e CN9_ESPCTR = 2 (SE1)
			If CN9->CN9_ESPCTR == '1'
		
				// valida apenas caso nao seja juros de cdc
				If !(CN9->CN9_TPCTO == _cMvPlCdc .and. CNA->CNA_TIPPLA == _cMvPlJur) 
		
					// Consulta titulo na SE2
					cQryAux	:= " "
					cQryAux	+= " SELECT E2_NUM FROM " + RetSqlName("SE2")
					cQryAux	+= " WHERE D_E_L_E_T_ = ' ' "
					cQryAux	+= " AND E2_FILIAL = '" + xFilial('SE2') + "' 
					cQryAux	+= " AND E2_MDCONTR = '" + CND->CND_CONTRA + "'
					cQryAux	+= " AND E2_MDPLANI = '" + CND->CND_NUMERO + "'
					cQryAux	+= " AND E2_MDPARCE = '" + CND->CND_PARCEL + "'
					cQryAux	+= " AND E2_FORNECE = '" + CND->CND_FORNEC + "'
					cQryAux	+= " AND E2_LOJA = '" + CND->CND_LJFORN + "'
					cQryAux	+= " AND E2_ORIGEM = 'CNTA120' "
					If Select("Qry1") <> 0
						Qry1->(dbCloseArea())
					EndIf
					TCQuery cQryAux Alias Qry1 New
					dbSelectArea("QRY1")
					Qry1->(dbGotop()) 
					If !Qry1->(Eof()) 				
						Return ExpL1
					Else
						Return .F.
					EndIf
		
				EndIf
		
			Else
		
				// Consulta titulo na SE1
				cQryAux	:= " "
				cQryAux	+= " SELECT E1_NUM FROM " + RetSqlName("SE1")
				cQryAux	+= " WHERE D_E_L_E_T_ = ' ' "
				cQryAux	+= " AND E1_FILIAL = '" + xFilial('SE1') + "' 
				cQryAux	+= " AND E1_MDCONTR = '" + CND->CND_CONTRA + "'
				cQryAux	+= " AND E1_MDPLANI = '" + CND->CND_NUMERO + "'
				cQryAux	+= " AND E1_MDPARCE = '" + CND->CND_PARCEL + "'
				cQryAux	+= " AND E1_CLIENTE = '" + CND->CND_CLIENT + "'
				cQryAux	+= " AND E1_LOJA = '" + CND->CND_LOJACL + "'
				cQryAux	+= " AND E1_ORIGEM = 'CNTA120' "
				If Select("Qry1") <> 0
					Qry1->(dbCloseArea())
				EndIf
				TCQuery cQryAux Alias Qry1 New
				dbSelectArea("QRY1")
				Qry1->(dbGotop()) 
				If !Qry1->(Eof()) 				
					Return ExpL1
				Else
					Return .F.
				EndIf
		
			EndIf
	
		EndIf

	EndIf

	RestArea(aArea)

Return ExpL1