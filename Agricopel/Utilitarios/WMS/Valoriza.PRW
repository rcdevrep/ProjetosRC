#Include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.CH"

User Function VALORIZA()

Private _DtRef   := CtoD("  /  /  ")
Private _DtRef2  := CtoD("  /  /  ")

DEFINE FONT oFont1 NAME "Calibri" SIZE 0,15 BOLD
DEFINE FONT oFont2 NAME "Arial"   SIZE 0,14 BOLD

@ 003,001 TO 250,350 DIALOG oDlg1 TITLE "Valoriza SB9"

@ 022,015 Say "Dt.Referencia:"      SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 022,065 Get _DtRef             	SIZE 50,20 
@ 052,015 Say "Atualizar:"          SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 052,065 Get _DtRef2             	SIZE 50,20 


@ 085,080 BUTTON "_Ok"            	SIZE 30,15 ACTION Gravar()
@ 085,130 BUTTON "_Sair"           	SIZE 30,15 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTERED

Return()

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Gravar()
   
Local cQuery := ""

cQuery     := " SELECT * "  
cQuery     += " FROM SB9010 "
cQuery     += " WHERE D_E_L_E_T_ = '' AND B9_FILIAL = '"+xFilial("SB9")+"' AND B9_DATA = '"+DtoS(_DtRef2)+"' AND B9_QINI > 0 AND B9_LOCAL = '02' "      
cQuery 	   := ChangeQuery(cQuery)
 
If Select("TRB") <> 0
	TRB->(dbCloseArea())
End

TCQUERY cQuery NEW ALIAS "TRB"
DbSelectArea("TRB")
TRB->(DbGoTop())

WHILE !TRB->(EOF()) 

	_cFilial:= TRB->B9_FILIAL
	_cProd	:= TRB->B9_COD
	_cLocal := TRB->B9_LOCAL

	cQuery1 := ""          	

	cQuery1     := " SELECT * "  
	cQuery1     += " FROM SB9010 "
	cQuery1     += " WHERE D_E_L_E_T_ = '' AND B9_DATA = '"+DtoS(_DtRef)+"' AND B9_FILIAL = '"+_cFilial+"' AND B9_COD = '"+_cProd+"' "
	cQuery1     += " AND B9_LOCAL = '"+_cLocal+"' AND B9_QINI > 0 AND B9_LOCAL = '02' "  
	cQuery1     := ChangeQuery(cQuery1)	 
	 
	If Select("TRB1") <> 0
		TRB1->(dbCloseArea())
	End
	
	TCQUERY cQuery1 NEW ALIAS "TRB1"
	DbSelectArea("TRB1")
	TRB1->(DbGoTop()) 
	
	_nCusto1 := 0
	_nCusto2 := 0
	_nCusto3 := 0 
	
	If !TRB1->(EOF()) 
		WHILE !TRB1->(EOF())
		 
			If TRB1->B9_VINI1 <> 0 .and. TRB1->B9_QINI <> 0			
				_nCusto1 := TRB->B9_QINI*(TRB1->B9_VINI1/TRB1->B9_QINI )
			Endif 

			If TRB1->B9_VINI2 <> 0 .and. TRB1->B9_QINI <> 0			
				_nCusto2 := TRB->B9_QINI*(TRB1->B9_VINI2/TRB1->B9_QINI )
			Endif

			If TRB1->B9_VINI3 <> 0 .and. TRB1->B9_QINI <> 0			
				_nCusto3 := TRB->B9_QINI*(TRB1->B9_VINI3/TRB1->B9_QINI )
			Endif
			
			dbSelectArea("SB9")
			SB9->(dbGoto(TRB->R_E_C_N_O_))			
			If TRB->B9_COD = SB9->B9_COD //Apenas por precaução... rssss....   
			
				recLock("SB9",.F.)
                	SB9->B9_VINI1 := _nCusto1
                	SB9->B9_VINI2 := _nCusto2
                	SB9->B9_VINI3 := _nCusto3
				msUnlock()
			
			Endif
				
			//Alert("Produto:"+Alltrim(TRB->B9_COD)+" Custo R$"+Str(_nCusto1)+" Custo $:"+Str(_nCusto2)+"!") 
		
		TRB1->(DbSkip())     
		EndDo
	Else
		Alert("Não encontrou custo para:"+Alltrim(TRB->B9_COD)+"!")
	Endif
     
TRB->(DbSkip())     
EndDo

Alert("OK")  

Return()
