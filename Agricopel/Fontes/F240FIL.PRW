
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F240FIL   �Autor  �Microsiga           � Data �  31/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtro para Considerar somentes titulos a pagar no vecto   ���
���          � parametrizado e com codigo de barras.                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function F240FIL() 

cRet:=""    

//If cEmpAnt == "44" .or. cEmpAnt == "11" .or. cEmpAnt == "15" .or. cEmpAnt == "01"

	If MsgYesNo("Deseja Filtrar Boletos ?")

		If CMODPGTO == "31" 
     
		   cRet := Space(50)
		   cRet := '(!Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240) .AND. len(alltrim(E2_AUXBAR)) == 47 .OR. (!Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240) .AND. EMPTY(E2_AUXBAR) .OR. (!Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240) .AND. len(alltrim(E2_AUXBAR)) == 44'
		       
		Else 
		
		   cRet := Space(50)
		   cRet := '(!Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240) .AND. len(alltrim(E2_AUXBAR)) == 48'
		   
		Endif     
        
	Else
	               
       If CMODPGTO <> "01" .OR.  CMODPGTO <> "41"  .OR.  CMODPGTO <> "31"  .OR.  CMODPGTO <> "48" //DEMAIS PAGAMENTOS 
       
          cRet := Space(50)
	      cRet := "(Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. Empty(POSICIONE('SA2', 1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_BANCO')) .AND. E2_VENCREA <= DVENFIM240)"  
    
       Endif

	    If CMODPGTO == "48" 
       
          cRet := Space(50)
	      cRet := "(Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. !Empty(POSICIONE('SA2', 1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_PIXCHV')) .AND. E2_VENCREA <= DVENFIM240)"  
    
       Endif
    
       If CMODPGTO == "01"  //DEPOSITO COM CONTA CORRENTE
         
          cRet := "(Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240 .AND. !Empty(POSICIONE('SA2', 1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_BANCO')) .AND. POSICIONE('SA2',1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_BANCO') == CPORT240 )"
   
       Endif

       If CMODPGTO == "41" //TED
         
          cRet := "(Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240 .AND. !Empty(POSICIONE('SA2', 1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_BANCO')) .AND. POSICIONE('SA2',1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_BANCO') <> CPORT240 )"
   
       Endif

   Endif
                        
//Else
	
	//cRet := Space(50)
	//cRet := '(!Empty(E2_CODBAR) .AND. E2_VENCREA >= DVENINI240 .AND. E2_VENCREA <= DVENFIM240)'  

//Endif

Return(cRet)
