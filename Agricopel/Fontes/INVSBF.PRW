#Include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.CH"

/*/{Protheus.doc} InvZero
Rotina para lançamento de inventario com quantidade Zero.
@author Cesar - SLA
@since 09/01/2018
@version P12
@uso Exclusivo Agricopel
@return null
@type function
/*/

User Function InvZero()

Private _DtInv  := dDataBase
Private _cDoc	:= Space(09)
Private _cLocal	:= Space(02)

DEFINE FONT oFont1 NAME "Calibri" SIZE 0,15 BOLD
DEFINE FONT oFont2 NAME "Arial"   SIZE 0,14 BOLD

@ 003,001 TO 250,350 DIALOG oDlg1 TITLE "Zeramento de Inventario"

@ 022,015 Say "Dt. Zeramento:"      SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 022,065 Get _DtInv             	SIZE 50,20 
@ 052,015 Say "Num.Documento:"      SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 052,065 Get _cDoc             	SIZE 50,20
@ 082,015 Say "Armazem:"      		SIZE 195, 020 OF  oDlg1 FONT oFont1 COLOR CLR_RED  PIXEL 
@ 082,065 Get _cLocal            	SIZE 15,20 

@ 105,080 BUTTON "_Gerar"          	SIZE 30,15 ACTION Gerar()
@ 105,130 BUTTON "_Sair"           	SIZE 30,15 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTERED

Return()
                                     

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Gerar()

If Empty(_DtInv) .or. Empty(_cDoc) .or. Empty(_cLocal)
	Alert("Preecha todos os Parametros!") 
	Return()
EndIf

MsgRun("Lançando Zeramento de Inventario...","Processando",{|| Gravar() })

Return()


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Gravar()

cQuery	:= ""

//Produtos com saldo no SB2.  
cQuery  := " SELECT * " 
cQuery  += " FROM "+RetSqlName("SB2")+" SB2 (NOLOCK)"
cQuery  += " WHERE SB2.D_E_L_E_T_ <> '*' "    
cQuery  += " AND B2_FILIAL = '"+xfilial("SB2")+"' " 
cQuery  += " AND B2_LOCAL  = '"+AllTrim(_cLocal)+"'
cQuery  += " AND B2_QATU <> 0 "      
cQuery  += " ORDER BY B2_COD "
//cQuery  := ChangeQuery(cQuery)

If Select("TRBsb2") <> 0
	TrbSb2->(dbCloseArea())
EndIf 

TCQUERY cQuery NEW ALIAS "TRBsb2"
DbSelectArea("TRBsb2")
TRBsb2->(DbGoTop())

WHILE !TRBsb2->(EOF())  

	_cLocaliz 	:= Posicione("SB1",1,xfilial("SB1")+TRBsb2->B2_COD,"B1_LOCALIZ") 
    _cRastro	:= Posicione("SB1",1,xfilial("SB1")+TRBsb2->B2_COD,"B1_RASTRO")    

	//Controla localização e lote
	If _cLocaliz = "S" .and. _cRastro = "L" 

		cQuery1 := ""
		
		//Produto que controlam endereço e lote.
		cQuery1  := " SELECT BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_NUMLOTE, BF_NUMSERI, BF_DATAVEN, BF_LOTECTL, B1_TIPO, B8_DTVALID, B1_GRUPO, BF_QUANT " 
		cQuery1  += " FROM "+RetSqlName("SBF")+" SBF (NOLOCK), "+RetSqlName("SB8")+" SB8 (NOLOCK), "+RetSqlName("SB1")+" SB1 (NOLOCK) "
		cQuery1  += " WHERE SBF.D_E_L_E_T_ <> '*' AND SB8.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' "    
		cQuery1  += " AND BF_FILIAL = '"+xfilial("SBF")+"' " 
		cQuery1  += " AND BF_FILIAL = B1_FILIAL "  
		cQuery1  += " AND BF_FILIAL = B8_FILIAL " 
		cQuery1  += " AND BF_PRODUTO = '"+TRBsb2->B2_COD+"' "  
		cQuery1  += " AND BF_LOCAL = '"+AllTrim(_cLocal)+"'
		cQuery1  += " AND BF_PRODUTO = B8_PRODUTO " 
		cQuery1  += " AND BF_PRODUTO = B1_COD "
		cQuery1  += " AND BF_LOCAL = B8_LOCAL "
		cQuery1  += " AND BF_LOTECTL = B8_LOTECTL "  
		cQuery1  += " AND B1_RASTRO = 'L' "  
		cQuery1  += " AND B1_LOCALIZ = 'S' "
		cQuery1  += " AND BF_QUANT <> 0 "      
		cQuery1  += " ORDER BY BF_LOCAL,BF_PRODUTO "
//		cQuery1  := ChangeQuery(cQuery1)
		
		If Select("TRBsbf") <> 0
			TRBsbf->(dbCloseArea())
		End
		
		TCQUERY cQuery1 NEW ALIAS "TRBsbf"
		DbSelectArea("TRBsbf")
		TRBsbf->(DbGoTop())
		
		
		WHILE !TRBsbf->(EOF())
		
			RecLock("SB7",.T.)
	            SB7->B7_FILIAL 	:= xFilial("SB7")
	            SB7->B7_COD 	:= TRBsbf->BF_PRODUTO
	            SB7->B7_LOCAL 	:= TRBsbf->BF_LOCAL
	            SB7->B7_TIPO 	:= TRBsbf->B1_TIPO  
	            SB7->B7_DOC 	:= _cDoc
	            SB7->B7_QUANT 	:= 0
	            SB7->B7_QTSEGUM := 0
	            SB7->B7_DATA 	:= _DtInv
	            SB7->B7_LOTECTL := TRBsbf->BF_LOTECTL
	            SB7->B7_DTVALID := StoD(TRBsbf->B8_DTVALID)
	            SB7->B7_LOCALIZ := TRBsbf->BF_LOCALIZ
	            SB7->B7_NUMSERI := TRBsbf->BF_NUMSERI 
	            SB7->B7_STATUS	:= "1"
	            SB7->B7_ESCOLHA := "S"
	            SB7->B7_CONTAGE	:= "001"
			MsUnLock()
			     
		TRBsbf->(DbSkip())     
		EndDo
			 
	
	EndIf 
	
	//Controla localização e não controla lote
	If _cLocaliz = "S" .and. _cRastro <> "L"

		cQuery1 := ""
		
		//Produto que controlam endereço e lote.
		cQuery1  := " SELECT BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_NUMLOTE, BF_NUMSERI, BF_DATAVEN, BF_LOTECTL, B1_TIPO, B1_GRUPO " 
		cQuery1  += " FROM "+RetSqlName("SBF")+" SBF (NOLOCK), "+RetSqlName("SB1")+" SB1 (NOLOCK) "
		cQuery1  += " WHERE SBF.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' "    
		cQuery1  += " AND BF_FILIAL = '"+xfilial("SBF")+"' "
		cQuery1  += " AND BF_FILIAL = B1_FILIAL "  	 
		cQuery1  += " AND BF_PRODUTO = '"+TRBsb2->B2_COD+"' "   
		cQuery1  += " AND BF_LOCAL = '"+AllTrim(_cLocal)+"'
		cQuery1  += " AND BF_PRODUTO = B1_COD " 
		cQuery1  += " AND B1_LOCALIZ = 'S' "
		cQuery1  += " AND B1_RASTRO <> 'L' "  
		cQuery1  += " AND BF_QUANT <> 0 "      
		cQuery1  += " ORDER BY BF_LOCAL,BF_PRODUTO "
//		cQuery1  := ChangeQuery(cQuery1)
		
		If Select("TRBsbf") <> 0
			TRBsbf->(dbCloseArea())
		End
		
		TCQUERY cQuery1 NEW ALIAS "TRBsbf"
		DbSelectArea("TRBsbf")
		TRBsbf->(DbGoTop())
		
		
		WHILE !TRBsbf->(EOF())
		
			RecLock("SB7",.T.)
	            SB7->B7_FILIAL 	:= xFilial("SB7")
	            SB7->B7_COD 	:= TRBsbf->BF_PRODUTO
	            SB7->B7_LOCAL 	:= TRBsbf->BF_LOCAL
	            SB7->B7_TIPO 	:= TRBsbf->B1_TIPO  
	            SB7->B7_DOC 	:= _cDoc
	            SB7->B7_QUANT 	:= 0
	            SB7->B7_QTSEGUM := 0
	            SB7->B7_DATA 	:= _DtInv
	            SB7->B7_LOCALIZ := TRBsbf->BF_LOCALIZ
	            SB7->B7_NUMSERI := TRBsbf->BF_NUMSERI 
	            SB7->B7_STATUS	:= "1"
	            SB7->B7_ESCOLHA := "S"
	            SB7->B7_CONTAGE	:= "001"
			MsUnLock()
			     
		TRBsbf->(DbSkip())     
		EndDo
			 	
	EndIf
	
	//Não controla localização e controla lote
	If 	_cLocaliz <> "S" .and. _cRastro = "L"  

		cQuery1 := ""
		
		//Produto que controlam endereço e lote.
		cQuery1  := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_DTVALID, B8_SALDO, B1_TIPO, B1_GRUPO " 
		cQuery1  += " FROM "+RetSqlName("SB8")+" SB8 (NOLOCK), "+RetSqlName("SB1")+" SB1 (NOLOCK) "
		cQuery1  += " WHERE SB8.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' "    
		cQuery1  += " AND B8_FILIAL = '"+xfilial("SB8")+"' "  
		cQuery1  += " AND B8_FILIAL = B1_FILIAL "  		
		cQuery1  += " AND B8_PRODUTO = '"+TRBsb2->B2_COD+"' "  
		cQuery1  += " AND B8_LOCAL = '"+AllTrim(_cLocal)+"' "
		cQuery1  += " AND B8_PRODUTO = B1_COD " 
		cQuery1  += " AND B8_QUANT <> 0 " 
		cQuery1  += " AND B1_LOCALIZ <> 'S' "  
		cQuery1  += " AND B1_RASTRO = 'L' "       
		cQuery1  += " ORDER BY BF_LOCAL,BF_PRODUTO "
//		cQuery1  := ChangeQuery(cQuery1)
		
		If Select("TRBsb8") <> 0
			TRBsb8->(dbCloseArea())
		End
		
		TCQUERY cQuery1 NEW ALIAS "TRBsb8"
		DbSelectArea("TRBsb8")
		TRBsb8->(DbGoTop())
		
		
		WHILE !TRBsb8->(EOF())
		
			RecLock("SB7",.T.)
	            SB7->B7_FILIAL 	:= xFilial("SB7")
	            SB7->B7_COD 	:= TRBsb8->B8_PRODUTO
	            SB7->B7_LOCAL 	:= TRBsb8->B8_LOCAL
	            SB7->B7_TIPO 	:= TRBsb8->B1_TIPO  
	            SB7->B7_DOC 	:= _cDoc
	            SB7->B7_QUANT 	:= 0
	            SB7->B7_QTSEGUM := 0
	            SB7->B7_DATA 	:= _DtInv
	            SB7->B7_LOTECTL := TRBsb8->B8_LOTECTL
	            SB7->B7_DTVALID := StoD(TRBsb8->B8_DTVALID)
	            SB7->B7_STATUS	:= "1"
	            SB7->B7_ESCOLHA := "S"
	            SB7->B7_CONTAGE	:= "001"
			MsUnLock()
			     
		TRBsb8->(DbSkip())     
		EndDo
                                              
	EndIf

	//Não controla localização e tambem não controla lote
	If 	_cLocaliz <> "S" .and. _cRastro <> "L"  

		RecLock("SB7",.T.)
            SB7->B7_FILIAL 	:= xFilial("SB7")
            SB7->B7_COD 	:= TRBsb2->B2_COD
            SB7->B7_LOCAL 	:= TRBsb2->B2_LOCAL
            SB7->B7_TIPO 	:= Posicione("SB1",1,xfilial("SB1")+TRBsb2->B2_COD,"B1_TIPO")   
            SB7->B7_DOC		:= _cDoc
            SB7->B7_QUANT 	:= 0
            SB7->B7_QTSEGUM := 0
            SB7->B7_DATA 	:= _DtInv
            SB7->B7_STATUS	:= "1"
            SB7->B7_ESCOLHA := "S"
            SB7->B7_CONTAGE	:= "001"
		MsUnLock()                                              
    
	EndIf

TRBsb2->(DbSkip())     
EndDo

MsgInfo("Executado o Lançamento de Inventario com Quantidade Zero!","Lançamento de Inventario")   

Close(oDlg1)

Return()
