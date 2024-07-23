#include 'Protheus.ch'
    
/*/{Protheus.doc} F200TIT
//Função após a Gravação do Retorno Bancário
@author Leandro Spiller
@since 13/08/2019
@version 1
@type function
/*/
User Function F200TIT()    

	Local _aArea 	 := GetArea() 
	Local _nValBaixa := 0   
	Local _cPerg     := ""     
	 
	//Garante que os parâmetros sejam salvos após a execauto 
	If Type("cPerg") == 'C'
		_cPerg := cPerg
	Endif 

	//Chamado[19655] - Nota Devolução para Fornecedor
   	If Valtype(nValrec) == "N"//Variável Privada de Valor Recebido
		_nValBaixa := nValrec
	Endif   
 
	DbSelectarea('SE1') 
	 	      
	//Se For uma NCF procura a NDF corresponde e realiza a Baixa
	If alltrim(SE1->E1_TIPO) == 'NCF' .AND. FieldPos("E1_XCHVNDF") > 0  .AND. U_XAG0053V(SE1->E1_FILORIG)                      
	  
		//Se houve alguma Baixa de Valores aplica na NDF
		If _nValBaixa > 0  .AND. !Empty(SE1->E1_XCHVNDF)
			BaixaNDF(_nValBaixa)
			pergunte(_cPerg,.F.)
		Endif
	
	Endif          
	//Fim Chamado[19655]    
     
	RestArea(_aArea)

Return     
 

//Busca e baixa a NDF
Static Function BaixaNDF(xValBaixa)    

	Local _aBaixa 	 := {}  
	Local _cChaveSE2 := ""   
	                                  
	//dbselectarea('SE1')
	//dbsetorder(1)
	//dbgoto(3122087)

	_cChaveSE2 :=  Rtrim(SE1->E1_XCHVNDF)  

	DbSelectArea('SE2')
	SE2->(DbSetOrder(1))
	If SE2->( Dbseek(_cChaveSE2) ) 
	    //CONOUT('ANTES FINA080 ')
	    //conout(SE2->E2_NUM)
	    //conout(MV_PAR01)
		_aBaixa := {}
		
	   //CONOUT('*>ANTES FINA080 ')
	   //conout(MV_PAR01)
	    
		AADD(_aBaixa, {"E2_FILIAL"   , SE2->E2_FILIAL  , Nil})
		AADD(_aBaixa, {"E2_PREFIXO"  , SE2->E2_PREFIXO , Nil})
		AADD(_aBaixa, {"E2_NUM" 	 , SE2->E2_NUM 	   , Nil})
		AADD(_aBaixa, {"E2_PARCELA"  , SE2->E2_PARCELA , Nil})
		AADD(_aBaixa, {"E2_TIPO" 	 , SE2->E2_TIPO    , Nil})
		AADD(_aBaixa, {"E2_FORNECE"  , SE2->E2_FORNECE , Nil})
		AADD(_aBaixa, {"E2_LOJA" 	 , SE2->E2_LOJA    , Nil}) 
		AADD(_aBaixa, {"AUTBANCO" 	 , "CX1" 		   , Nil})
		AADD(_aBaixa, {"AUTAGENCIA"  , "00001" 		   , Nil})
		AADD(_aBaixa, {"AUTCONTA" 	 , "0000000001"    , Nil})
		AADD(_aBaixa, {"AUTHIST" 	 , "BAIXA POR NCF" , Nil}) 
		Aadd(_aBaixa, {"AUTVLRPG",     xValBaixa	   , Nil})
		Aadd(_aBaixa, {"AUTMOTBX",     "NOR"		   , Nil})
		Aadd(_aBaixa, {"AUTDTBAIXA",   dDataBase	   , Nil})
		Aadd(_aBaixa, {"AUTDTCREDITO", dDataBase	   , Nil})
			
		lMsErroAuto := .F.
		
		MSEXECAUTO({|x,y| FINA080(x,y)}, _aBaixa, 3)
	    
	    //CONOUT('*>DEPOIS FINA080 ')
	    //conout(MV_PAR01)
	          
		If lMsErroAuto
		   	MOSTRAERRO() 
	   		Return .F.
		EndIf  
		
	Endif	

Return .T.    
          