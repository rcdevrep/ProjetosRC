#include "Protheus.ch"      
#Include "Rwmake.ch"        
#Include "TopConn.ch"                     

//-------------------------------------------//
//    Função:SMSAGR08                        //
//    Utilização: Importa SIMP		         //
//    Data: 22/12/2015                       //
//    Autor: Leandro Spiller                 //                               
//-------------------------------------------//
User Function SMSAGR08()

	Local   lretTRB := .F.
	Private cLinha  := "" 
	Private cArq    := "" 
	Private cArq2   := "" 
	Private cPerg   := "SMSAGR08"
	Private aDados  := {}
    Private nHandle := 0        
    
    ValPerg(cperg)
         
  	If !(Pergunte(cPerg)) 
  	      Return
  	Endif
    
    //Valida Arquivo 1  
  	If Alltrim(MV_PAR01)+Alltrim(MV_PAR02) == ''
   	    Alert("Selecione um arquivo!")
   	    Return
 	Else
  		cArq := MV_PAR01
    	If !('.csv' $ Alltrim(cArq))
   			Alert("Arquivo 1 deve ser .CSV!")
   	   		Return
   		Endif
    Endif
    
	//Valida Arquivo 2
	If Alltrim(MV_PAR02) <> '' 
	  	cArq2 := MV_PAR02
  	   	If !('.csv' $ Alltrim(cArq2))
   	 		Alert("Arquivo 2 deve ser .CSV!")
   	   		Return
   		Endif  
   		
   		If MV_PAR01 == MV_PAR02 .AND. Len(MV_PAR01) == Len(MV_PAR02)
 	  	 		Alert("Arquivo 1 e Arquivo 2, não podem ser iguais!")
   	   		Return
   		Endif
	Endif  
	 
	//Grava Tabelas Pessoa e Pessoa1
    If MV_PAR05 == 1
   		 Processa( {|| lRetTrb := GravaTRB() }) 
  	Else
  		lRetTrb := .T. 
  	Endif 
              
   //Atualiza SA1 E SA2 
   If MV_PAR06 == 1
   	    If lRetTRB    
   	      //Atualiza tabelas SA1 e SA2	
  		  Processa( {|| ATUALIZA(aDados) })   
   	 	Endif                              
   Endif
   
Return                         


//Grava Arquivo TRB
//Tabelas Pessoa e Pessoa1
Static Function GravaTRB()
     
	Local lRet := .F.
	
	nHandle := FT_FUSE(cArq)
    
    If nHandle < 0
    	Alert("Arquivo vazio ou inválido!")
    	Return
    Endif              
    
    //Exclui Tabelas       
   	TCSqlExec(" SELECT * FROM PESSOA")
   	TCSqlExec(" DELETE	 FROM PESSOA")  
   	
  	TCSqlExec(" SELECT * FROM PESSOA1")
  	TCSqlExec(" DELETE FROM PESSOA1")

	ProcRegua(FT_FLASTREC())

    FT_FGOTOP()
	IncProc("Atualizando Tabela Pessoa...") 
    While !FT_FEOF()
     
        IncProc("Lendo arquivo 1 ...")
     
        cLinha := FT_FREADLN()
        
        aDados := Separa(cLinha,";",.T.)
        
        If 'A' $ aDados[1]                  
        	FT_FSKIP()
        	LOOP
        Endif   
                  
        cQuery := " INSERT INTO PESSOA "//(CODINST, CNPJ, NOME)"
		cQuery += "		VALUES ('"+aDados[1]+"','"+aDados[2]+"','')"   
		
		If (TCSQLExec(cQuery) < 0)
    			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf          
                               
        FT_FSKIP()

    EndDo  	        
    
    FT_FUSE()  
                            
    //Grava Arquivo 2   
   	If Alltrim(MV_PAR02) <> '' 
   		nHandle := FT_FUSE(cArq2)
    
    	If nHandle < 0
    		Alert("Arquivo 2  vazio ou inválido!")
    		Return
    	Endif              
		ProcRegua(FT_FLASTREC())

   	   FT_FGOTOP()
	
	   While !FT_FEOF()
     
        	IncProc("Lendo arquivo 2 ...")
     
        	cLinha := FT_FREADLN()
             
            aDados := Separa(cLinha,";",.T.)
    
       		If 'A' $ aDados[1] 
        		FT_FSKIP()
        		LOOP
       		 Endif   
                  
   		    cQuery := " INSERT INTO PESSOA1 "//(CODINST, CNPJ, NOME)"
			cQuery += "		VALUES ('"+aDados[1]+"','"+aDados[2]+"','')"   
		
			If (TCSQLExec(cQuery) < 0)
   	 			Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf          
                      
        FT_FSKIP()

   	 EndDo          
    
    FT_FUSE()  
   
   Endif    
   
   if len(aDados) > 0 
      lRet := .T.
   Endif
   
Return lRet
                            

//Atualiza Tabelas SA1 e SA2
Static Function ATUALIZA(aDados)  
                                   
	//Atualiza SA1 X PESSOA
    cQuery := ""   
	//cQuery += " UPDATE SA1010 SET A1_INSTANP = (SELECT TOP 1 CODINST FROM PESSOA INNER JOIN SA1010 (NOLOCK) A1 ON (CNPJ = A1_CGC
	//cQuery += " AND D_E_L_E_T_ = '' AND A1_FILIAL = '"+xFilial('SA1')+"') )" 
	//cQuery +=  " From SA1010 with(nolock) "
	cQuery := " SELECT A1_INSTANP,CODINST,CNPJ,SA1.R_E_C_N_O_ FROM "+RetSqlName('SA1')+" SA1 "
	cQuery += "  INNER JOIN PESSOA ON (CNPJ = A1_CGC AND SA1.D_E_L_E_T_ = '') "	
	cQuery += "  WHERE CODINST <> A1_INSTANP "
	cQuery += "    AND exists(select 1 "
    cQuery += "                 from "+RetSqlName('SF2')+" "
    cQuery += " 	           where F2_CLIENTE = A1_COD "
    cQuery += "                  and D_E_L_E_T_ <> '*' "                            
    cQuery += "                  and F2_EMISSAO between '"+DTOS(MV_PAR03)+"' and '"+DTOS(MV_PAR04)+"' "
    //cQuery += "                  AND F2_FILIAL = '"+xFilial('SF2')+"' " comentado para usuario rodar um processo por empresa, hoje clientes compartilhados
    cQuery += "                GROUP BY F2_CLIENTE,F2_LOJA) "  //aqui ver data
	                                                            
	If (Select("QRYSMS08") <> 0)
		dbSelectArea("QRYSMS08")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSMS08"
	         	 
	dbSelectArea("QRYSMS08")   
	QRYSMS08->(dbGoTop())                                       
	
	IncProc("Atualizando codigo de instalação clientes...") 
	While QRYSMS08->(!Eof())
	     
	     cQuery := " UPDATE "+RetSqlName('SA1')+" SET A1_INSTANP = '"+QRYSMS08->CODINST+"' "
	     cQuery += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(QRYSMS08->R_E_C_N_O_))
	     cQuery += " AND A1_INSTANP <> '"+QRYSMS08->CODINST+"' "
	     
	     If (TCSQLExec(cQuery) < 0)
 			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf    
	
		QRYSMS08->(DbSkip())
	
	Enddo  
	   
    //Atualiza SA2 X PESSOA
	cQuery := ""
	//cQuery += " UPDATE SA2010 SET A2_INSTANP = (SELECT TOP 1 CODINST FROM PESSOA INNER JOIN SA2010 (NOLOCK) A2 ON CNPJ = A2_CGC) " 
	//cQuery += " From SA1010 with(nolock) "
	cQuery := " SELECT A2_INSTANP,CODINST,CNPJ,SA2.R_E_C_N_O_ FROM "+RetSqlName('SA2')+" SA2 "
	cQuery += "  INNER JOIN PESSOA ON (CNPJ = A2_CGC AND SA2.D_E_L_E_T_ = '') "
	cQuery += "  WHERE A2_INSTANP <> CODINST "
	cQuery += "    and exists(select 1 "
    cQuery += "                 from "+RetSqlName('SF1')+" "
    cQuery += "                where F1_FORNECE = A2_COD "
    cQuery += "                  and D_E_L_E_T_ <> '*' "
    cQuery += "                  and F1_EMISSAO between '"+DTOS(MV_PAR03)+"' and '"+DTOS(MV_PAR04)+"'  "
    //cQuery += "                  AND F1_FILIAL = '"+xFilial('SF1')+"' " comentado para usuario rodar um processo por empresa, hoje clientes compartilhados
    cQuery += "                GROUP BY F1_FORNECE,F1_LOJA) "  //aqui ver data) "  //aqui ver data
	
	If (Select("QRYSMS08") <> 0)
		dbSelectArea("QRYSMS08")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSMS08"
	         	 
	dbSelectArea("QRYSMS08")   
	QRYSMS08->(dbGoTop())                                       
	
	IncProc("Atualizando codigo de instalação clientes...") 
	While QRYSMS08->(!Eof())
	     
	     cQuery := " UPDATE "+RetSqlName('SA2')+" SET A2_INSTANP = '"+QRYSMS08->CODINST+"' "
	     cQuery += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(QRYSMS08->R_E_C_N_O_))
	     cQuery += " AND A2_INSTANP <> '"+QRYSMS08->CODINST+"' "
	     If (TCSQLExec(cQuery) < 0)
 			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf    
	
		QRYSMS08->(DbSkip())
	
	Enddo	                                                        
	
//Atualiza SA1 X PESSOA1
IF Alltrim(MV_PAR02) <> ""
    cQuery := ""   
	//cQuery += " UPDATE SA1010 SET A1_INSTANP = (SELECT TOP 1 CODINST FROM PESSOA1 INNER JOIN SA1010 (NOLOCK) A1 ON CNPJ = A1_CGC)"  
	//cQuery += " From SA1010 with(nolock) "
	cQuery := " SELECT A1_INSTANP,CODINST,CNPJ,SA1.R_E_C_N_O_ FROM "+RetSqlName('SA1')+" SA1 "
	cQuery += "  INNER JOIN PESSOA1 ON (CNPJ = A1_CGC AND SA1.D_E_L_E_T_ = '') "	
	cQuery += "  WHERE CODINST <> A1_INSTANP "
	cQuery += "    AND exists(select 1 "
    cQuery += "                 from "+RetSqlName('SF2')+" "
    cQuery += " 	           where F2_CLIENTE = A1_COD   "
    cQuery += "                  and D_E_L_E_T_ <> '*'     "                            
    cQuery += "                  and F2_EMISSAO between '"+DTOS(MV_PAR03)+"' and '"+DTOS(MV_PAR04)+"' "
    //cQuery += "                  AND F2_FILIAL = '"+xFilial('SF2')+"' "
    cQuery += "                GROUP BY F2_CLIENTE,F2_LOJA) "  //aqui ver data) "  //aqui ver data
	
	
	If (Select("QRYSMS08") <> 0)
		dbSelectArea("QRYSMS08")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSMS08"
	         	 
	dbSelectArea("QRYSMS08")   
	QRYSMS08->(dbGoTop())                                       
	
	IncProc("Atualizando codigo de instalação clientes...") 
	While QRYSMS08->(!Eof())
	     
	     cQuery := " UPDATE "+RetSqlName('SA1')+" SET A1_INSTANP = '"+QRYSMS08->CODINST+"' "
	     cQuery += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(QRYSMS08->R_E_C_N_O_))
	     cQuery += " AND A1_INSTANP <> '"+QRYSMS08->CODINST+"' "
	     
	     If (TCSQLExec(cQuery) < 0)
 			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf    
	
		QRYSMS08->(DbSkip())
	
	Enddo
	                   
	
	//Atualiza SA2 X PESSOA1
	cQuery := ""
	//cQuery += " UPDATE SA2010 SET A2_INSTANP = (SELECT TOP 1 CODINST FROM PESSOA1 INNER JOIN SA2010 (NOLOCK) A2 ON CNPJ = A2_CGC) " 
	//cQuery += " From SA1010 with(nolock) "
	cQuery := " SELECT A2_INSTANP,CODINST,CNPJ,SA2.R_E_C_N_O_ FROM "+RetSqlName('SA2')+" SA2 "
	cQuery += "  INNER JOIN PESSOA1 ON (CNPJ = A2_CGC AND SA2.D_E_L_E_T_ = '') "
	cQuery += "  WHERE A2_INSTANP <> CODINST "
	cQuery += "    and exists(select 1 "
    cQuery += "                 from "+RetSqlName('SF1')+" "
    cQuery += " 	           where F1_FORNECE = A2_COD "
    cQuery += "                  and D_E_L_E_T_ <> '*' "
    cQuery += "                  and F1_EMISSAO between '"+DTOS(MV_PAR03)+"' and '"+DTOS(MV_PAR04)+"' "
    //cQuery += "                  AND F1_FILIAL = '"+xFilial('SF1')+"' "
    cQuery += "                GROUP BY F1_FORNECE,F1_LOJA) "  //aqui ver data) "  //aqui ver data
	
	If (Select("QRYSMS08") <> 0)
		dbSelectArea("QRYSMS08")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSMS08"
	         	 
	dbSelectArea("QRYSMS08")   
	QRYSMS08->(dbGoTop())                                       
	
	IncProc("Atualizando codigo de instalação clientes...") 
	While QRYSMS08->(!Eof())
	     
	     cQuery := " UPDATE "+RetSqlName('SA2')+" SET A2_INSTANP = '"+QRYSMS08->CODINST+"' "
	     cQuery += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(QRYSMS08->R_E_C_N_O_))
	     cQuery += " AND A2_INSTANP <> '"+QRYSMS08->CODINST+"' "
	     
	     If (TCSQLExec(cQuery) < 0)
 			Return MsgStop("TCSQLError() " + TCSQLError())
		 EndIf    
	
		QRYSMS08->(DbSkip())
	
	Enddo                        

Endif	      
	
	

//***************************************************
//Atualiza codigo dos Municipios dos Clientes        
//***************************************************      

	//Atualiza SA1 X A1_MUN_ANP
	cQuery := ""
	cQuery += " SELECT SUBSTRING(CODIGO_ANP, 2, LEN(CODIGO_ANP)-2) AS CODIGO, SA1.R_E_C_N_O_  FROM "+RetSqlName('SA1')+" SA1 "
	cQuery += "  INNER JOIN ANP_IMP1 ON (SUBSTRING(CODIGO_IBGE, 4, 5) = A1_COD_MUN and ESTADO = A1_EST)"
	cQuery += "  WHERE D_E_L_E_T_ <> '*' 	and A1_MUN_ANP = ''  	and A1_EST <> 'EX' "
	cQuery += "    and (exists(select 1      "
	cQuery += "                  FROM PESSOA "
	cQuery += "                 where PESSOA.CNPJ = A1_CGC) OR  "
	cQuery += "         exists(select 1       "
	cQuery += "                  FROM PESSOA1 "
	cQuery += "                 where PESSOA1.CNPJ = A1_CGC))  "
	cQuery += "    and exists(select * "
	cQuery += "                 from "+RetSqlName('SF2')+" "
	cQuery += "                where F2_CLIENTE = A1_COD   "
	cQuery += "                  and D_E_L_E_T_ <> '*'     "
	cQuery += "                  and F2_EMISSAO between '"+DTOS(MV_PAR03)+"' and '"+DTOS(MV_PAR04)+"' "
	cQuery += "                  and A1_LOJA = F2_LOJA) "
	
	/*cQuery := ""
	cQuery += " UPDATE "+RetSqlName('SA1')+" SET A1_MUN_ANP = ANP  FROM "+RetSqlName('SA1')+" (NOLOCK) A1 "
	cQuery += " INNER JOIN CIDADE_ANP ON EST = A1_EST AND CODMUN = A1_COD_MUN "
	cQuery += " WHERE A1_INSTANP = ''    AND D_E_L_E_T_ <> '*' "
	*/                                                                       
	If (Select("QRYSMS08") <> 0)
		dbSelectArea("QRYSMS08")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSMS08"
	         	 
	dbSelectArea("QRYSMS08")   
	QRYSMS08->(dbGoTop())                                       
	
	IncProc("Atualizando codigos de Municipio dos Clientes...") 
	While QRYSMS08->(!Eof())
	     
	     cQuery := " UPDATE "+RetSqlName('SA1')+" SET A1_MUN_ANP = '"+QRYSMS08->CODIGO+"' "
	     cQuery += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(QRYSMS08->R_E_C_N_O_))
	     cQuery += " AND A1_MUN_ANP <> '"+QRYSMS08->CODIGO+"' "
	     
	     If (TCSQLExec(cQuery) < 0)
 			Return MsgStop("TCSQLError() " + TCSQLError())
		 EndIf    
	
		QRYSMS08->(DbSkip())
	
	Enddo                              
	
	//Atualiza SA2 X A2_MUN_ANP	
	cQuery := ""
	cQuery += " SELECT SUBSTRING(CODIGO_ANP, 2, LEN(CODIGO_ANP)-2) AS CODIGO, SA2.R_E_C_N_O_    FROM "+RetSqlName('SA2')+" SA2 "
	cQuery += " INNER JOIN ANP_IMP1 ON (SUBSTRING(CODIGO_IBGE, 4, 5) = A2_COD_MUN and ESTADO = A2_EST) "
	cQuery += " WHERE D_E_L_E_T_ <> '*' 	and A2_MUN_ANP = ''  	and A2_EST <> 'EX' "
	cQuery += "   and (exists(select 1      "
	cQuery += "                 from PESSOA "
	cQuery += "                where PESSOA.CNPJ = A2_CGC) OR "
	cQuery += "        exists(select 1       "
	cQuery += "                 from PESSOA1 "
	cQuery += "                where PESSOA1.CNPJ = A2_CGC)) "
	cQuery += "   and exists(select * "
	cQuery += "                FROM "+RetSqlName('SF1')+" "
	cQuery += "               where F1_FORNECE = A2_COD   "
	cQuery += "                 and D_E_L_E_T_ <> '*'     "
	cQuery += "                 and F1_EMISSAO between '"+DTOS(MV_PAR03)+"' and '"+DTOS(MV_PAR04)+"' "
	cQuery += "                 and A2_LOJA = F1_LOJA) "

	If (Select("QRYSMS08") <> 0)
		dbSelectArea("QRYSMS08")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSMS08"
	         	 
	dbSelectArea("QRYSMS08")   
	QRYSMS08->(dbGoTop())                                       
	
	IncProc("Atualizando codigos de Municipio dos Fornecedores...") 
	While QRYSMS08->(!Eof())
	     
	     cQuery := " UPDATE "+RetSqlName('SA2')+" SET A2_MUN_ANP = '"+QRYSMS08->CODIGO+"' "
	     cQuery += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(QRYSMS08->R_E_C_N_O_))
	     cQuery += " AND A2_MUN_ANP <> '"+QRYSMS08->CODIGO+"' "
	     
	     If (TCSQLExec(cQuery) < 0)
 			Return MsgStop("TCSQLError() " + TCSQLError())
		 EndIf    
	
		QRYSMS08->(DbSkip())
	
	Enddo                    
	
	/*cQuery := ""
	cQuery += " UPDATE "+RetSqlName('SA2')+" SET A2_MUN_ANP = ANP  FROM "+RetSqlName('SA2')+" (NOLOCK) A2  
	cQuery += " INNER JOIN CIDADE_ANP ON EST = A2_EST AND CODMUN = A2_COD_MUN 
	cQuery += " WHERE A2_INSTANP = ''    AND D_E_L_E_T_ <> '*'
    
	IIncProc("Atualizando Codigos de Cidade dos Fornecedores...")
	If (TCSQLExec(cQuery) < 0)
 		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	*/   
	
    msginfo("Fim do Processo!")
    
Return

//Pergunte 
Static Function ValPerg(cperg)

	Local aArea := GetArea()
	PutSx1(cPerg,"01","Arquivo 1 "		    	  ,"","","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(cPerg,"02","Arquivo 2 "			 	  ,"","","mv_ch2","C",99,0,0,"G","","DIR","","","mv_par02","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(cPerg,"03","Data de:  "	     	 	  ,"","","mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(cPerg,"04","Data ate: "		          ,"","","mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(cPerg,"05","Gerar Tabela Temporária  ?","","","MV_CH05","C",01,0,0,"C","","","","","MV_PAR05","Sim","","","","Não","","","","","","","","","","","",{""},{""},{""})
	PutSx1(cPerg, "06", "Atualizar dados SIMP"    ,"","", "mv_ch6", "C",01, 0, 0, "C", "","","","","mv_par06","Sim","","","","Não","","","","","","","","","","","",{"","",""},{"","","",""},{"","",""},"")
	restArea(aArea)

Return 