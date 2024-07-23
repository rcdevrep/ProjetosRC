#include 'protheus.ch'
#include 'topconn.ch'

//-------------------------------------------//
//    Função:SLAGETPC                        //
//    Utilização: Busca pedidos em aberto	 //
//    Data: 09/03/2016                       //
//    Autor: Leandro Spiller                 //                               
//-------------------------------------------//
User Function SLAGETPC(xProduto)

	Local cQuery 	:= ""
	Local lTemPC 	:= .F.    
	Local lCriaTRB  := .T.  
	
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"C7_DATPRF ","C7_QUANT  ","C7_NUM"}
	Private aAlterFields := {}
	Private oMSNewGetDados1 
	Private _cProduto := ""                 
	Private oDlgGetPC

	Default xProduto := ''
	 
	// Caso não seja passado o parametro xProduto
	// indica que a rotina está sendo usada via
	// Call Center                       
	If alltrim(xProduto) <> '' 
		_cProduto := xProduto
	Else
	   	_cProduto := acols[n][2]//M->UB_PRODUTO
	Endif
	   
	
	//Valida produto Vazio
    If alltrim(_cProduto) == ''
		 MsgInfo('Campo Produto	Vazio',' Vazio')     
	    Return
    endif
	
	//Query de Busca de Saldo em pedido
	cQuery := " SELECT  C7_RESIDUO,C7_PRODUTO,C7_NUM,C7_QUANT,C7_QUJE,C7_DATPRF FROM "+RetSqlName('SC7')+" "
	cQuery += " WHERE "
	cQuery += " D_E_L_E_T_ = '' " 	
	cQuery += " AND C7_PRODUTO = '"+_cProduto+"' "
	cQuery += " AND C7_QUANT <> C7_QUJE "
	cQuery += " AND C7_RESIDUO = '' "
	cQuery += " AND C7_FILIAL = '"+xFilial('SC7')+"' "
	cQuery += " ORDER BY C7_PRODUTO "                           	
	
	If (Select("SLAGETPC") <> 0)
		dbSelectArea("SLAGETPC")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "SLAGETPC"   
	
	TCSETFIELD("SLAGETPC","C7_DATPRF" 		  ,"D",08,0)
	         	 
	dbSelectArea("SLAGETPC")   
	SLAGETPC->(dbGoTop())     
	              
	//Grava ACols
	While SLAGETPC->(!eof())
		lTemPC := .T.
		aFieldFill := {}

		//Preenche Acols                      
		Aadd(aFieldFill, SLAGETPC->C7_DATPRF)
		Aadd(aFieldFill, SLAGETPC->C7_QUANT )
		Aadd(aFieldFill, SLAGETPC->C7_NUM)
		
		Aadd(aFieldFill, .F.)
	  	Aadd(aColsEx, aFieldFill)

		SLAGETPC->(Dbskip())
	Enddo
	
	//Se tiver PC cria janela, senão mostra Msg de Erro
	If lTemPC
	 	CriaWin(_cProduto)                                  
	Else   
	    MsgInfo('Não existem pedidos de compra em aberto para o produto: '+_cProduto,' Não há ')     
	    Return
	Endif 

Return                                
                                   

//Cria Janela para demostrar a Grid      
Static Function CriaWin()
                                                    
	 Local oFechar
	 Local oGetProd
	 Local cGetProd := _cProduto
	 Local oSay1

 	 DEFINE MSDIALOG oDlgGetPC TITLE "Pedidos de Compra" FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL

  	   GeraGrid()
   	 
   	   @ 006, 005 SAY oSay1 PROMPT "Produto: " SIZE 025, 006 OF oDlgGetPC COLORS 0, 16777215 PIXEL
   	   @ 003, 031 MSGET oGetProd VAR cGetProd WHEN .F. SIZE 060, 010 OF oDlgGetPC COLORS 0, 16777215 PIXEL
       @ 082, 115+43 BUTTON oFechar PROMPT "Fechar" Action(oDlgGetPC:End())SIZE 037, 012 OF oDlgGetPC PIXEL
  	
  	ACTIVATE MSDIALOG oDlgGetPC

Return
               
                                  
//Cria a Grid de dados                                  
Static Function GeraGrid()

  Local nX

  // Define field properties
  DbSelectArea("SX3")
  SX3->(DbSetOrder(2))
  For nX := 1 to Len(aFields)
    If SX3->(DbSeek(aFields[nX]))
      Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                       SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Endif
  Next nX
 
  oMSNewGetDados1 := MsNewGetDados():New( 017, 004, 077, 184+15, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgGetPC, aHeaderEx, aColsEx)

Return