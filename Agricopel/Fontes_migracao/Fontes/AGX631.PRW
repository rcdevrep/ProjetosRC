#INCLUDE "rwmake.ch"
#INCLUDE "colors.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณagx483    บAutor  ณMicrosiga           บ Data ณ  07/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importacao arquivo SIMP                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX631()
PRIVATE oDlg    := Nil, oCon := Nil, oCan := Nil, oPar := Nil         


	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ AJUSTE NO SX1                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPerg := "AGX631"
	aRegistros := {}

	PutSx1(cPerg,"01","Importa Arquivo       ?","","","mv_ch1","N",1,0,1,"C","","","","","mv_par01","Sim","Si","Yes","","Nao","No","No","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Atualiza Informa็๕es  ?","","","mv_ch2","N",1,0,1,"C","","","","","mv_par02","Sim","Si","Yes","","Nao","No","No","","","","","","","","","","","","")

	If !Pergunte(cPerg,.T.)
		Return
	EndIf       
	
	If mv_par01 == 1
		Processa({|| U_AGX630()}, "Importando Arquivo SIMP! Aguarde...")	
	EndIf  
	
  
	If mv_par02 == 1
	 	Processa({|| AnalCli()}, "Analisando Clientes! Aguarde...")		
 		Processa({|| AnalFor()}, "Analisando Fornecedores! Aguarde...")	
 	EndIf
	
	
	MSGINFO("Importa็ใo Concluida!")  
Return()                                  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX483    บAutor  ณMicrosiga           บ Data ณ  09/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ZERA A1_INSTANP,A1_MUN_ANP                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function ZeraSA1()

cQuery := "" 
cQuery := "UPDATE " + RetSqlName("SA1") 
cQuery += " SET A1_INSTANP = '',A1_MUN_ANP = ''


If (TCSQLExec(cQuery) < 0)
	Return MsgStop("TCSQLError() " + TCSQLError())
EndIf                  


Return()   




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX483    บAutor  ณMicrosiga           บ Data ณ  09/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ZERA A2_INSTANP,A2_MUN_ANP                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function ZeraSA2()
cQuery := "" 
cQuery := "UPDATE " + RetSqlName("SA2") 
cQuery += " SET A2_INSTANP = '',A2_MUN_ANP = ''


If (TCSQLExec(cQuery) < 0)
	Return MsgStop("TCSQLError() " + TCSQLError())
EndIf
 

Return()




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452IMP บAutor  ณMicrosiga           บ Data ณ  06/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa o arquivo do SPED FISCAL                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



Static Function GeraArq()
LOCAL nLineLength := 200, nTabSize := 3, lWrap := .F. , nRec := 1
LOCAL nLines, nCurrentLine
Private cImp := .T.     	
	aImpArq  := {} 
	cArq     := "" 
	
	Aadd(aImpArq,{"CNPJ"      ,"C",14,0,"C"})     //CNPJ
	Aadd(aImpArq,{"INSTALA"   ,"C",7,0,"C"})        //REGISTRO   
	
	
	
	                                  
/*	cQuery := "bulk insert PESSOA "
	cQuery += "from 'E:\SIMP\COD1.txt' " 
	cQuery += "	with " 
	cQuery += "("
	cQuery += "fieldterminator = ';',"       
	cQuery += "	rowterminator = '\n') "

	
	
	If (TCSQLExec(cQuery) < 0)
   		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf   
	
		cQuery := "bulk insert PESSOA "
	cQuery += "from 'E:\SIMP\COD2.txt' " 
	cQuery += "	with " 
	cQuery += "("
	cQuery += "fieldterminator = ';',"
	cQuery += "	rowterminator = '\n' )  "

	
	
	If (TCSQLExec(cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf    */
	
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImporto o arquivo TXT do Sped Fiscal para manipula็ใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
			
/*	If (Select("QRYPES") <> 0)
	dbSelectArea("QRYPES") 
		dbCloseArea()
	Endif
	cArq := CriaTrab(aImpArq,.T.)
	dbUseArea(.T.,,cArq,"QRYPES",.T.,.F.)  */	    

    
    //*******************************************************
    
    nRec := 1
    cQuery := "" 
    cQuery := "SELECT * FROM PESSOA"        
    
    If Select("QRYPES") <> 0
       dbSelectArea("QRYPES")
   	   dbCloseArea()
    Endif
    
   	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYPES" 
    
    
    dbSelectArea("QRYPES")
    dbGoTop()
    ProcRegua(QRYPES->(RecCount()))    
    While !eof()
   		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbseek(xFilial("SA1")+ALLTRIM(QRYPES->CNPJ))
			RecLock("SA1",.F.)
			SA1->A1_INSTANP  := ALLTRIM(QRYPES->CODINST)
			MsUnLock()                            
        EndIf
		
		dbSelectArea("SA2")
		dbSetOrder(3)
		If dbseek(xFilial("SA2")+ALLTRIM(QRYPES->CNPJ))
			RecLock("SA2",.F.)
				SA2->A2_INSTANP  := ALLTRIM(QRYPES->CODINST)
			MsUnLock()                            
        EndIf 

    	dbSelectArea("QRYPES")
    	QRYPES->(dbskip())   
    	nRec++       
    	CONOUT(nRec)
    EndDo
    
       
        
    
    
    
    

/*    nRec := 1
	Ft_fUse(mv_par01)    
    FT_FGOTOP()                     //PONTO NO TOPO      
    nTotalLin := 0
    nTotalLin := FT_FLASTREC()
    ProcRegua(FT_FLASTREC())   //QTOS REGISTROS LER
	While !FT_FEof()
//		IncProc("Aguarde Importa็ใo...")   
       // ALERT("CNPJ - " + ALLTRIM(SUBSTR(FT_FReadLn(),(At(";",FT_FReadLn())+1),14)) )  //+ " - " STR(nRec) + " de " + STR(FT_FLASTREC()  )
		IncProc("CNPJ - " + ALLTRIM(SUBSTR(FT_FReadLn(),(At(";",FT_FReadLn())+1),14)) + " - " + AllTrim(STR(nRec)) + " de " + AllTrim(STR(nTotalLin)))
		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbseek(xFilial("SA1")+ALLTRIM(SUBSTR(FT_FReadLn(),(At(";",FT_FReadLn())+1),14)))
			RecLock("SA1",.F.)
	//			MIMPARQ->CNPJ     := SUBSTR(FT_FReadLn(),(At(";",FT_FReadLn())+1),14)
				SA1->A1_INSTANP  := ALLTRIM(SUBSTR(FT_FReadLn(),1,(At(";",FT_FReadLn())-1)))
			MsUnLock()                            
        EndIf
		
		dbSelectArea("SA2")
		dbSetOrder(3)
		If dbseek(xFilial("SA2")+ALLTRIM(SUBSTR(FT_FReadLn(),(At(";",FT_FReadLn())+1),14)))
			RecLock("SA2",.F.)
	//			MIMPARQ->CNPJ     := SUBSTR(FT_FReadLn(),(At(";",FT_FReadLn())+1),14)
				SA2->A2_INSTANP  := ALLTRIM(SUBSTR(FT_FReadLn(),1,(At(";",FT_FReadLn())-1)))
			MsUnLock()                            
        EndIf 
        nRec++
		FT_FSkip()                                        
		
	
	EndDo          
	FT_fUse()*/
	
	
	
	
		
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFim Importa็ใoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/   

Return()                  




Static Function AnalCli()

	cQuery := "" 
	cQuery := "UPDATE " + RetSqlName("SA1") 
	cQuery += " SET A1_INSTANP = '',A1_MUN_ANP = ''


	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf                  


	cQuery := "" 
	cQuery += " UPDATE SA1010 "
	cQuery += " SET A1_INSTANP = CODINST FROM PESSOA INNER JOIN SA1010 A1 (NOLOCK) ON A1_CGC = CNPJ WHERE A1.D_E_L_E_T_ <> '*' "     
	
	
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf    
	               
	
	cQuery := ""
	cQuery := " UPDATE SA1010 SET A1_MUN_ANP = ANP FROM SA1010 (NOLOCK) INNER JOIN CIDADE_ANP "
	cQuery += " ON EST = A1_EST AND CODMUN = A1_COD_MUN  WHERE A1_INSTANP = ''  AND D_E_L_E_T_ <> '*' "
	
	
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf    
	




/*	cQuery := ""
	cQuery := " SELECT A1_COD,A1_LOJA, A1_COD_MUN,A1_EST FROM " + RetSqlName("SA1") + "  "
	cQuery += "WHERE A1_INSTANP = ''    AND D_E_L_E_T_ <> '*'  "     */
	
	
 /*	cQuery := "" 	 
	cQuery := "SELECT A1_COD, A1_LOJA, A1_COD_MUN, A1_EST FROM " + RetSqlName("SA1") + " SA1 (NOLOCK) "
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) "
	cQuery += " ON  A1_COD  = D2_CLIENTE "
	cQuery += " AND A1_LOJA = D2_LOJA "
	cQuery += " WHERE D2_FILIAL = '" + xFilial("SD2") + "' "
	cQuery += " AND SD2.D_E_L_E_T_ <> '*' AND D2_TIPO = 'N' "
	cQuery += "  AND D2_EMISSAO BETWEEN '20130701' AND '20130731' "
    cQuery += "  AND (D2_TP = 'CO' OR D2_TP = 'GV' OR D2_TP = 'LU') " 
	cQuery += "  AND LTRIM(RTRIM(D2_CF)) NOT IN('5663','6663' ) " 
	cQuery += "  AND SA1.D_E_L_E_T_ <> '*' AND A1_INSTANP = ''"
	cQuery += "  GROUP BY A1_COD, A1_LOJA, A1_COD_MUN, A1_EST "
	cQuery += "  ORDER BY A1_COD "    */


 /*   If Select("QRYSA1") <> 0
       dbSelectArea("QRYSA1")
   	   dbCloseArea()
    Endif
    
   	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSA1"
    
    
    dbSelectArea("QRYSA1")
    dbGoTop()
    ProcRegua(QRYSA1->(RecCount()))    
    While !eof()
        dbSelectArea("SA1")
        dbSetOrder(1)
        If dbSeek(xFilial("SA1")+QRYSA1->A1_COD+QRYSA1->A1_LOJA)     
        
	        
	        cQuery := ""
			cQuery := " SELECT ANP FROM CIDADE_ANP  "
			cQuery += "WHERE EST = '" + QRYSA1->A1_EST + "' "
			cQuery += "  AND CODMUN = '" + QRYSA1->A1_COD_MUN + "' "
		
	
	        If Select("QRYCID") <> 0
	           dbSelectArea("QRYCID")
	   	       dbCloseArea()
	        Endif
	    
	   	    cQuery := ChangeQuery(cQuery)
		    TCQuery cQuery NEW ALIAS "QRYCID" 
		    
		    cCidANP := ""                     
		    dbSelectArea("QRYCID")
		    dbGoTop()
	  	    cCidANP := QRYCID->ANP
	  	    
	  	    dbSelectArea("SA1")
	  	    RecLock("SA1" , .F.)
	  	    	SA1->A1_MUN_ANP := cCidANP
	        MsUnLock()
            IncProc("Cliente - " + SA1->A1_COD)     
            CONOUT('ANALISANDO')
	  	EndIf    
	    
	    QRYSA1->(dbSkip())
    EndDo  */


Return()  


Static Function AnalFor()
	cQuery := "" 
	cQuery := "UPDATE " + RetSqlName("SA2") 
	cQuery += " SET A2_INSTANP = '',A2_MUN_ANP = ''


	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf                  


	cQuery := "" 
	cQuery += " UPDATE SA2010 "
	cQuery += " SET A2_INSTANP = CODINST FROM PESSOA INNER JOIN SA2010 A2 (NOLOCK) ON A2_CGC = CNPJ WHERE A2.D_E_L_E_T_ <> '*' "     
	
	
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf    
	               
	
	cQuery := ""
	cQuery := " UPDATE SA2010 SET A2_MUN_ANP = ANP FROM SA2010 (NOLOCK) INNER JOIN CIDADE_ANP "
	cQuery += " ON EST = A2_EST AND CODMUN = A2_COD_MUN  WHERE A2_INSTANP = ''  AND D_E_L_E_T_ <> '*' "
	
	
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf    


Return()





//taize.rh@hotmail.com

		       
		       