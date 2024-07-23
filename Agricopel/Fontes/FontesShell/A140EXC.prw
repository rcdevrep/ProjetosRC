#INCLUDE "PROTHEUS.CH"

User Function A140EXC()

	Local _cTab1 := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))
	Local _cCmp1 := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
	
	dbSelectArea(_cTab1)
	(_cTab1)->( dbSetOrder(1) )
	
	//                    *Chave           *NFe  *Importado
	If (_cTab1)->( dbSeek(SF1->F1_CHVNFE + "1" + "2") )
	
		RecLock(_cTab1, .F.)
		
			If GetNewPar("MV_XGTDELX", .F.)
			
				dbDelete()
				
			Else
			
				(_cTab1)->&(_cCmp1+"_SIT")    := "1"
				(_cTab1)->&(_cCmp1+"_LIBALM") := " "
				
			EndIf
			
		(_cTab1)->( MsUnlock() )
		
	ElseIf (_cTab1)->( dbSeek(SF1->F1_CHVNFE + "2" + "2") )
	
		If SF1->F1_TIPO == "C"
		
			dbSelectArea("SF8")
			SF8->( dbSetOrder(3) )
			
			If SF8->( dbSeek(xFilial("SF8") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
			
				While !SF8->( Eof() ) .And. SF8->F8_FILIAL == xFilial("SF8") .And. SF8->F8_NFDIFRE == SF1->F1_DOC .And. ;
				      SF8->F8_SEDIFRE == SF1->F1_SERIE .And. SF8->F8_TRANSP == SF1->F1_FORNECE .And. SF8->F8_LOJTRAN == SF1->F1_LOJA
				
					RecLock("SF8", .F.)
					
						dbDelete()
						
					SF8->( MsUnlock() )
					
					SF8->( dbSkip() )
					
				EndDo
				
			EndIf
			
		EndIf
		
		RecLock(_cTab1, .F.)
		
			If GetNewPar("MV_XGTDELX", .F.)
			
				dbDelete()
				
			Else
			
				(_cTab1)->&(_cCmp1+"_SIT") := "1"
				
			EndIf
			
		(_cTab1)->( MsUnlock() )
		
	EndIf
	
	dbCloseArea(_cTab1)
	
Return .T.