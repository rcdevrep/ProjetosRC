#include 'Protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} XAG0056
//Rotina para acerto de Rateio de Notas de Entrada no LP 
@author Spiller
@since 18/07/2019
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/   
User Function XAG0056(xCampo) 
    
	Local nRet := 0 
	Local nDif := 0
	Local nTotRateio := 0  
	
	Default xCampo := ""   
	
	//Se não tiver Rateio Retorna 0 
	If SD1->D1_RATEIO <> '1' 
   		Return 0
	Endif
	                         
	     
	//Se for o primeiro item valida se o valor fecha 100%    
	If Val(SDE->DE_ITEM) == 1
		nDif := CalcDif(xCampo)
	Endif
	                                                               
	//Arredonda Valor e Debita se necessário    
	If alltrim(xCampo) == 'D1_TOTAL'  
   		nTotRateio := SD1->&(xCampo) + SD1->D1_VALIPI+SD1->D1_ICMSRET-SD1->D1_VALDESC+SD1->D1_DESPESA+SD1->D1_VALFRE
   		nRet := ROUND( nTotRateio * (SDE->DE_PERC / 100),2 ) + nDif
	Else
		nRet := ROUND( SD1->&(xCampo) * (SDE->DE_PERC / 100),2 ) + nDif                                                                                                                                                                                                                       
	Endif     

Return nRet  

      
//Realiza o Calculo dos Percentuais e adiciona a Diferença ao Primeiro Item
Static Function CalcDif(xCampo)

	Local cQuery  := "" 
	Local nRetDif := 0  
	Local nValTot := 0
	Local nValSDE := 0             
	     
	//Tratativa para Calcular o Custo        
	If alltrim(xCampo) == 'D1_TOTAL' 
		nValTot := SD1->&(xCampo) + SD1->D1_VALIPI+SD1->D1_ICMSRET-SD1->D1_VALDESC+SD1->D1_DESPESA+SD1->D1_VALFRE
	Else
		nValTot := SD1->&(xCampo)
	Endif
	cQuery := " SELECT "
	//cQuery += " SUM( ROUND("+cValtoChar(nValTot)+"*(DE_PERC/100), 2 ) ) AS SOMARAT "
	cQuery += " DE_PERC "//SUM( ROUND("+cValtoChar(nValTot)+"*(DE_PERC/100), 2 ) ) AS SOMARAT "
	cQuery +="  FROM "+RetSqlName('SDE')+" TSDE "
	cQuery += " WHERE "
	cQuery += " D_E_L_E_T_ = '' AND "
	cQuery += " DE_DOC 	   = '"+SDE->DE_DOC+"' AND "
	cQuery += " DE_SERIE   = '"+SDE->DE_SERIE+"' AND "
	cQuery += " DE_FORNECE = '"+SDE->DE_FORNECE+"' AND "   
	cQuery += " DE_LOJA	   = '"+SDE->DE_LOJA+"' AND "  
	cQuery += " DE_ITEMNF  = '"+SDE->DE_ITEMNF+"' "  
	                                                    	
	If Select('TSDE') <> 0
		dbSelectArea('TSDE')
		TSDE->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ('TSDE')    
	
	TSDE->(DbGoTop())
	  
	While TSDE->(!eof()) 
		
		nValSDE += ROUND( nValTot * (TSDE->DE_PERC / 100),2 )
		
		TSDE->(DbSkip())
	Enddo
	
 	nRetDif := (nValtot - nValSDE  )
 	
 	If Select('TSDE') <> 0
		dbSelectArea('TSDE')
		('TSDE')->(dbCloseArea())
	Endif
	

Return nRetDif                                                                                                                                                                                                                                                                                         