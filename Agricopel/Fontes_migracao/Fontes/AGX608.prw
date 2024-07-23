#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"
#include "rwmake.ch"                                                                       	
#include "topconn.ch"       
#include 'Protheus.ch'


User Function AGX608()       

ALERT("ENTROU NO AGX608") 

cAliasQRY1 := GetNextAlias()

cQuery := "SELECT D3_NUMSEQ,D3_COD, D3_EMISSAO ,D3_DOC, SUM(1) SOMA  FROM SD3010 "
cQuery += "WHERE D3_EMISSAO BETWEEN '20141001' AND '20141231' "
cQuery += "  AND D3_FILIAL = '06'    AND D_E_L_E_T_ <> '*'   AND D3_OP = ''  GROUP BY D3_NUMSEQ,D3_COD,D3_EMISSAO,D3_DOC  " 


If Select(cAliasQRY1) <> 0
	dbSelectArea(cAliasQRY1)
	dbCloseArea()
Endif
    
cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS (cAliasQRY1)  

 
dbSelectArea(cAliasQRY1)
dbGoTop()
do while !eof()               
  /*	If (cAliasQRY1)->SOMA < 3
		(cAliasQRY1)->(dbSkip())
		loop
	EndIf      */                                     
	
		
	cQuery := " SELECT D3_LOTECTL,D3_LOCALIZ,D3_NUMSEQ , R_E_C_N_O_ REC,  * FROM SD3010 "
	cQuery += " WHERE D3_NUMSEQ = '" + (cAliasQRY1)->D3_NUMSEQ + "' " 
   	cQuery += " AND D3_EMISSAO = '" + (cAliasQRY1)->D3_EMISSAO + "' " 
   	cQuery += " AND D_E_L_E_T_ <> '*'
   	cQuery += " AND D3_DOC = '"  + (cAliasQRY1)->D3_DOC + "' "
   	cQuery += " AND D3_COD = '" + (cAliasQRY1)->D3_COD + "' " 
   	cQuery += " ORDER BY R_E_C_N_O_ "      
   	
   	cAliasQRY2 := GetNextAlias() 
   	
   	If Select(cAliasQRY2) <> 0
	dbSelectArea(cAliasQRY2)
		dbCloseArea()
	Endif
    
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS (cAliasQRY2)  

    
 	nContAux := 1
 	cProxNum := ProxNum()
	dbSelectArea(cAliasQRY2)
	dbGoTop()
	do while !eof()
		if nContAux = 3 
			cProxNum := ProxNum()
			nContAux := 1		
		EndIf     
		CONOUT((cAliasQRY2)->D3_NUMSEQ) 
		
		
		cQuery := ""
		cQuery += "UPDATE " + RetSqlName("SD3") + "  " 
		cQuery += "SET D3_NUMSEQ = '" + cProxNum + "' " 
		cQuery += "WHERE R_E_C_N_O_ = " +  str((cAliasQRY2)->REC) + " " 
	
			
	    If (TCSQLExec(cQuery) < 0)
		   Return MsgStop("TCSQLError() " + TCSQLError())
	    EndIf  
		
		
		
		 
		nContAux++
		
		(cAliasQRY2)->(dbSkip())
		   		
 	EndDo    
 	
 	dbSelectArea(cAliasQRY2)
 	dbCloseArea()
 	
 	
 	dbSelectArea(cAliasQRY1)
 	(cAliasQRY1)->(dbSkip())
 EndDo 
 
 Alert("Fim")
 	
 	
                        	




Return()


