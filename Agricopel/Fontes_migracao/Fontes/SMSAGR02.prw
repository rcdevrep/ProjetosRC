#Include "PROTHEUS.CH" 
#Include "RWMAKE.CH"                       


//-------------------------------------------//
//    Função:SMSAGR02                        //
//    Utilização: Exporta endereços	         //
//    Data: 30/09/2015                       //
//    Autor: Leandro Spiller                 //                               
//-------------------------------------------//
User Function SMSAGR02()

	Local cLinha  := "" 
	Local cArq    := ""  
	Local cPerg   := "SMSAGR02"
	Local aDados  := {}
    Local nHandle := 0
  
  	If !(Pergunte(cPerg)) 
  	      Return
  	Endif
      
  	If Alltrim(MV_PAR01) == ''
   	    Alert("Selecione o arquivo!")
   	    Return
 	Else
  		cArq := MV_PAR01
  	Endif   
      
    If !('.csv' $ Alltrim(cArq))
   	 	Alert("Selecione o arquivo .CSV!")
   	    Return
   	Endif
    
	nHandle := FT_FUSE(cArq)
    
    If nHandle < 0
    	Alert("Arquivo vazio ou inválido!")
    	Return
    Endif

	
    ProcRegua(FT_FLASTREC())

    FT_FGOTOP()

    While !FT_FEOF()
     
        IncProc("Lendo arquivo...")
     
        cLinha := FT_FREADLN()
        
        AADD(aDados,Separa(cLinha,";",.T.))
     
        FT_FSKIP()

    EndDo          
    
    FT_FUSE()         
            
   If Len(aDados) > 0 
 	  ATUALIZAB1(aDados)
   Endif                              
Return

Static Function ATUALIZAB1(aDados)  

	If Len(aDados)  > 0 
		
		For I := 1 TO LEN(aDados) 
   	
   			Dbselectarea("SB1")
			DBSETORDER(1)
			DBGOTOP()
	
			//GRAVA O CODIGO DE BARRAS                      
			If alltrim(adados[i][1]) <> "CODIGO"
				If DBSEEK(xfilial('SB1')+alltrim(adados[i][1])) 
			 		RECLOCK('SB1',.F.)
			 		  
			 			//B1_XENDER := ALLTRIM(adados[i][3])         
			 			If Alltrim(adados[i][3]) <> ''
			 				B1_XRUA     := UPPER(Substr(Alltrim(adados[i][3]),1,3))
  							B1_XBLOCO	:= UPPER(Substr(Alltrim(adados[i][3]),4,3))
  							B1_XNIVEL   := UPPER(Substr(Alltrim(adados[i][3]),7,2))
  							B1_XAPTO    := UPPER(Substr(Alltrim(adados[i][3]),9,3))    
  						Endif
  						  
  						//Leandro Spiller - 24/02/2016
  						//Adicionado gravação dos endereços 2 e 3.
  						If len(adados[i]) >= 4
  							If Alltrim(adados[i][4]) <> ''
  								B1_XLOCAL2 := Alltrim(adados[i][4]) //Endereço 2
  							Endif 
  						Endif
  						
  						If len(adados[i]) >= 5
  							If Alltrim(adados[i][5]) <> ''
  						   		B1_XLOCAL3 := Alltrim(adados[i][5]) //Endereço 3
    		       		    Endif
			 		    Endif
			 		    
			 		MSUNLOCK()
			 		
				Endif
			Endif
		Next I
	Endif	
	
Return
                                    