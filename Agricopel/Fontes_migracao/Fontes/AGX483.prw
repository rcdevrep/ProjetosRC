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

User Function AGX483() 

	//Chama Rotina de Gera็ใo de dados
	u_SMSAGR08()
	
Return

/*User Function AGX483() 

PRIVATE oDlg    := Nil, oCon := Nil, oCan := Nil, oPar := Nil   


@ 200,1 TO 380,600 DIALOG oDlg TITLE OemToAnsi("Gerenciamento Arquivo SIMP")
//@ 001,001 TO 50,50
@ 001,002 Say " Este programa ira atualizar os codigos de instala็ใo de clientes e fornecedores para gera็ใo do arquivo SIMP." SIZE 100,10  
@ 002,002 Say " Para esse processo verifique se os arquivos contendo as informa็๕es dos c๓digos se encontram no diret๓rio " SIZE 100,10
@ 003,002 Say " E:\SIMP do banco de dados." SIZE 100,10

//@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
//@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkGeraTrb() }) 
//@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt) 
//@ 70,218 BUTTON TYPE 14 ACTION Processa( {|| Concilia() })   

@ 70,190 BUTTON "Atualizar"     SIZE 38,12 PIXEL OF oDlg ACTION  Processa( {|| Atualizar() })  
@ 70,230 BUTTON "Fechar"        SIZE 38,12 PIXEL OF oDlg ACTION  Close(oDlg) 




Activate Dialog oDlg Centered

Return()   

Static Function Atualizar()    

	
	/*IncProc("Limpando instala็ใo clientes...")  
	cQuery := "" 
	cQuery := "UPDATE " + RetSqlName("SA1") 
	cQuery += " SET A1_INSTANP = '',A1_MUN_ANP = ''
	
	
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf  
	
	IncProc("Limpando instala็ใo fornecedores...")  
	cQuery := "" 
	cQuery := "UPDATE " + RetSqlName("SA2") 
	cQuery += " SET A2_INSTANP = '',A2_MUN_ANP = ''
	
	
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf    
	*/
  	/*IncProc("Limpando tabela PESSOA...")  
	cQuery := "TRUNCATE TABLE PESSOA"
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	*//* 
	 
	TCSQLExec("DELETE FROM PESSOA") 
	
    IncProc("Importando Arquivom COD1...")                                  
   
   /*	cQuery := "bulk insert PESSOA "
	cQuery += "from 'E:\PESSOA1.xls' "//'E:\SIMP\COD1.txt' " 
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
	
	IncProc("Importando Arquivom COD2...")  
	If (TCSQLExec(cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf       
	*//*   
	
	GravaTRB()
	
	cQuery := ""   
	cQuery += "UPDATE SA1010 SET A1_INSTANP = CODINST FROM PESSOA INNER JOIN SA1010 (NOLOCK) A1 ON CNPJ = A1_CGC "
	
	IncProc("Atualizando codigo de instala็ใo clientes...") 
	If (TCSQLExec(cQuery) < 0)

 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf       
	
	cQuery := ""
	cQuery += " UPDATE SA2010 SET A2_INSTANP = CODINST FROM PESSOA INNER JOIN SA2010 (NOLOCK) A2 ON CNPJ = A2_CGC "      
	
	
	IncProc("Atualizando codigo de instala็ใo fornecedores...") 
	If (TCSQLExec(cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf         
	
    cQuery := "	UPDATE SA1010 SET A1_MUN_ANP = ANP  FROM SA1010 (NOLOCK) A1  INNER JOIN CIDADE_ANP ON EST = A1_EST AND CODMUN = A1_COD_MUN "
	cQuery += " WHERE A1_INSTANP = ''    AND D_E_L_E_T_ <> '*' "    
	
	IncProc("Atualizando codigo de municipio para clientes que nใo possuem c๓digo de instala็ใo...") 
	If (TCSQLExec(cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf      
	
	
	cQuery := "	UPDATE SA2010 SET A2_MUN_ANP = ANP  FROM SA2010 (NOLOCK) A2  INNER JOIN CIDADE_ANP ON EST = A2_EST AND CODMUN = A2_COD_MUN "
	cQuery += " WHERE A2_INSTANP = ''    AND D_E_L_E_T_ <> '*' "    
	
	IncProc("Atualizando codigo de municipio para fornecedores que nใo possuem c๓digo de instala็ใo...") 
	If (TCSQLExec(cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf   

    msginfo("Fim do Processo!")

Return()


      
   /*

	If !MsgAlert("Deseja realizar a verifica. Continua?","Atencao!")
		Return
	Endif
	
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf 
	
	If mv_par02 == 1 
		Processa({|| ZeraSA1()}, "Zerando Clientes! Aguarde...")		
		Processa({|| ZeraSA2()}, "Zerando Fornecedores!. Aguarde...") 
	EndIf
	If mv_par03 == 1
		Processa({|| GeraArq()}, "Importando Arquivo SIMP! Aguarde...")	
	EndIf    
	If mv_par06 == 1
	 	Processa({|| AnalCli()}, "Analisando Clientes! Aguarde...")		
 		Processa({|| AnalFor()}, "Analisando Fornecedores! Aguarde...")	
 	EndIf
	
	
	MSGINFO("Importa็ใo Concluida!")  
Return()     */                             



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


/*Static Function ZeraSA1()

cQuery := "" 
cQuery := "UPDATE " + RetSqlName("SA1") 
cQuery += " SET A1_INSTANP = '',A1_MUN_ANP = ''


If (TCSQLExec(cQuery) < 0)
	Return MsgStop("TCSQLError() " + TCSQLError())
EndIf


/*dbSelectArea("SA1")
dbSetOrder(1)
dbGoTop() 
ProcRegua(SA1->(RecCount()))       
While !eof() 
//    IncProc(SA1->A1_NOME)
    RecLock("SA1",.F.)
       SA1->A1_INSTANP := ""
       SA1->A1_MUN_ANP := "" 
       
    MsUnLock()
    IncProc("Cliente - " + SA1->A1_NOME)
    SA1->(dbSkip())
EndDo*//*

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
*//*


Static Function ZeraSA2()
cQuery := "" 
cQuery := "UPDATE " + RetSqlName("SA2") 
cQuery += " SET A2_INSTANP = '',A2_MUN_ANP = ''


If (TCSQLExec(cQuery) < 0)
	Return MsgStop("TCSQLError() " + TCSQLError())
EndIf
 
/*dbSelectArea("SA2")
dbSetOrder(1)
dbGoTop() 
ProcRegua(SA2->(RecCount()))       
While !eof() 
    RecLock("SA2",.F.)
       SA2->A2_INSTANP := ""
       SA2->A2_MUN_ANP := "" 
    MsUnLock()
    IncProc("Fornecedor - " + SA2->A2_NOME)
    SA2->(dbSkip())
EndDo*//*

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
*//*



Static Function GeraArq()
LOCAL nLineLength := 200, nTabSize := 3, lWrap := .F. , nRec := 1
LOCAL nLines, nCurrentLine
Private cImp := .T.     	
	aImpArq  := {} 
	cArq     := "" 
	
	Aadd(aImpArq,{"CNPJ"      ,"C",14,0,"C"})     //CNPJ
	Aadd(aImpArq,{"INSTALA"   ,"C",7,0,"C"})        //REGISTRO   
	
	
	cQuery := "TRUNCATE TABLE PESSOA"
	If (TCSQLExec(cQuery) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	
	                                  
	cQuery := "bulk insert PESSOA "
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
	EndIf
	
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
	ENDDOC*//*   

Return()     


Static Function AtuCliente()

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
Return()

             




Static Function AnalCli()
	cQuery := ""
	cQuery := " SELECT A1_COD,A1_LOJA, A1_COD_MUN,A1_EST FROM " + RetSqlName("SA1") + "  "
	cQuery += "WHERE A1_INSTANP = ''    AND D_E_L_E_T_ <> '*'  "
	
	
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
	cQuery += "  ORDER BY A1_COD "    *//*


    If Select("QRYSA1") <> 0
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
    EndDo


Return()  


Static Function AnalFor()
	cQuery := ""
	cQuery := " SELECT A2_COD,A2_LOJA, A2_COD_MUN,A2_EST FROM " + RetSqlName("SA2") + "  "
	cQuery += "WHERE A2_INSTANP = ''    AND D_E_L_E_T_ <> '*'  "
	
/*	cQuery := ""
	cQuery := " SELECT A2_COD, A2_LOJA, A2_COD_MUN, eA2_EST FROM SA2010 SA2 (NOLOCK) "
	cQuery += " INNER JOIN SD1010 SD1 (NOLOCK) "
	cQuery += " ON  A2_COD  = D1_FORNECE "
	cQuery += " AND A2_LOJA = D1_LOJA "
	cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
	cQuery += "  AND SD1.D_E_L_E_T_ <> '*' AND (D1_TIPO = 'N' OR D1_TIPO = 'D') "
	cQuery += "  AND D1_DTDIGIT BETWEEN '20130701' AND '20130731' " 
	cQuery += "  AND D1_TP IN('CO', 'GV', 'LU') " 
	cQuery += "  AND LTRIM(RTRIM(D1_CF)) NOT IN('5663','6663' ) "
	cQuery += "  AND SA2.D_E_L_E_T_ <> '*' AND A2_INSTANP = '' "
	cQuery += "  GROUP BY A2_COD, A2_LOJA, A2_COD_MUN , A2_EST "
	cQuery += "  ORDER BY A2_COD "  *//*



    If Select("QRYSA2") <> 0
       dbSelectArea("QRYSA2")
   	   dbCloseArea()
    Endif
    
   	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSA2"
    
    
    dbSelectArea("QRYSA2")
    dbGoTop()
    ProcRegua(QRYSA2->(RecCount()))    
    While !eof()
        dbSelectArea("SA2")
        dbSetOrder(1)
        If dbSeek(xFilial("SA2")+QRYSA2->A2_COD+QRYSA2->A2_LOJA)     
        
        
	        cQuery := ""
			cQuery := " SELECT ANP FROM CIDADE_ANP  "
			cQuery += "WHERE EST = '" + QRYSA2->A2_EST + "' "
			cQuery += "  AND CODMUN = '" + QRYSA2->A2_COD_MUN + "' "
		
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
	  	    
	  	    dbSelectArea("SA2")
	  	    RecLock("SA2" , .F.)
	  	    	SA2->A2_MUN_ANP := cCidANP
	        MsUnLock()   
            IncProc("Fornecedor - " + SA2->A2_COD)
	    EndIf
	  	    
    
	    QRYSA2->(dbSkip())
    EndDo

               
Return()       

Static function GravaTRB()

Return */
//taize.rh@hotmail.com

		    		       