#Include "rwmake.ch" 
#Include "protheus.ch"  
#Include "Topconn.ch"  

User Function SMSAGR07()
 
	Local cQry 		:= ""
	Private nCol 	:= 0  
	Private _CPERG := "SMSAGR07" 
	Private nCol1 	:= 20
	Private nCol2 	:= 400-150
	Private nCol3 	:= 1100-80
	Private nCol4 	:= 1300-80
	Private nCol5 	:= 1500-80
	Private nCol6 	:= 1800-80
	Private nCol7 	:= 2100-80	
	Private nQuebra := 3000
	Private cMark   := ""//GetMark(,"TRB","C5_OK")
	Private aBrw 	:= {}
	Private lMarcados := .F.
	Private oMB 
	Private aRotina := {} 
	Private xLocaliz := ""
	Private xLote 	  := ""
	Private aCampos := {}      
	
	ValPerg(_CPERG)

	If !(Pergunte(_CPERG))
	    Return
	Endif
	
	
	aRotina   := { { "Confirmar"	,"U_SMS07OK" , 0, 4},; 
				   { "Recarregar"   ,"U_SMS07REC" , 0, 4}}               
	

	//Gera Query de dados
	GeraQry()
	
    //Gera arquivo de Trabalho
	GeraTRB()
	 
	//Grava arquivo de trabalho
	GravaTRB()    
	
	aBRW := {}
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	For nI := 1 To Len(aCampos)
		If dbSeek(aCampos[nI][1])    
			IF Alltrim(X3_TITULO) == 'Nome'
				AADD(aBRW,{X3_CAMPO,"",IIF(nI==1,"",PADR(X3_TITULO,40)),Trim(X3_PICTURE)})   
			Else
		   		AADD(aBRW,{X3_CAMPO,"",IIF(nI==1,"",Trim(X3_TITULO)),Trim(X3_PICTURE)}) 
			Endif	
		EndIf
	Next
   
   	//Cria MarkBrow      
	cMark   := GetMark(,"TRB","DA_OK")
	CriaMark()
	
Return
    

Static  Function GeraTRB()   

	aCampos := {}
      
	Aadd(aCampos,{ "DA_OK"		, "C", 02, 0 } )
	Aadd(aCampos,{ "DA_PRODUTO"	, "C", 15, 0 } )
	Aadd(aCampos,{ "DA_LOTECTL"	, "C", 10, 0 } )
	Aadd(aCampos,{ "DA_NUMLOTE"	, "C", 06, 0 } )
	Aadd(aCampos,{ "DA_LOCAL"	, "C", 02, 0 } )
	Aadd(aCampos,{ "DA_DOC"		, "C", 09, 0 } )
	Aadd(aCampos,{ "DA_SERIE"	, "C", 03, 0 } ) 
	Aadd(aCampos,{ "DA_DATA"	, "D", 08, 0 } )  
	Aadd(aCampos,{ "DA_ORIGEM"	, "C", 03, 0 } )
	Aadd(aCampos,{ "RECNO"		, "N", 09, 0 } )    

	cNomArq := CriaTrab(aCampos)
	
	If (Select("TRB") <> 0)
	   DbSelectArea("TRB")
	   DbCloseArea()
	End
	
	DbUseArea(.T., , cNomArq, "TRB", Nil, .F.)
	
	cIndex := Criatrab(nil,.F.)
	
	IndRegua("TRB", cIndex, "DA_PRODUTO+DA_LOCAL",,, "Selecionando Registros...")
	
Return
        
       
Static  Function GravaTRB()   

	While QRYSMS07->(!EOF())
	      
	      Dbselectarea('TRB')
	      Reclock('TRB',.T.) 
	    	TRB->DA_OK  	 := "  "//QRYSMS07->DA_OK
  			TRB->DA_PRODUTO  := QRYSMS07->DA_PRODUTO
			TRB->DA_LOTECTL  := QRYSMS07->DA_LOTECTL
			TRB->DA_NUMLOTE  := QRYSMS07->DA_NUMLOTE
			TRB->DA_LOCAL    := QRYSMS07->DA_LOCAL
			TRB->DA_DOC      := QRYSMS07->DA_DOC
			TRB->DA_SERIE    := QRYSMS07->DA_SERIE
			TRB->DA_DATA     := StoD(QRYSMS07->DA_DATA)
			TRB->DA_ORIGEM   := QRYSMS07->DA_ORIGEM 
			TRB->RECNO   	 := QRYSMS07->RECNO
	      
	      TRB->(MSUNLOCK())
	
	
		QRYSMS07->(dbskip())
	Enddo
	
	TRB->(DBGOTOP())
Return

Static Function CriaMark()
      
   	oMB := MarkBrow("TRB","DA_OK","",aBRW,.F.,cMark,'U_MarkTd()')
   	
Return    
                                               
            
User Function MarkTd()
                       
	Local cGravar := "  "
	
	lMarcados := !lMarcados 
	
	If lMarcados
	   cGravar := cMark 
    Endif
		
	TRB->(DBGOTOP())
    While TRB->(!Eof())   
    		Reclock('TRB',.F.)
	   			TRB->DA_OK := cGravar
	   		TRB->(MSUNLOCK())
    	TRB->(Dbskip())
    Enddo 

Return

Static function GeraQry()

	Local cQuery := ""   
	
	cQuery := " SELECT DA_PRODUTO,DA_LOTECTL,DA_NUMLOTE,DA_LOCAL,DA_DOC,DA_SERIE,DA_DATA,DA_LOTECTL,DA_ORIGEM, R_E_C_N_O_ AS RECNO "
	cQuery += " FROM "+RetSqlname('SDA')+" "
	cQuery += " WHERE "
    cQuery += " D_E_L_E_T_ = '' AND DA_FILIAL = '"+xFilial('SDA')+"' "
	cQuery += " AND DA_SALDO > 0 AND DA_LOCAL = '"+MV_PAR01+"'" 
	cQuery += " AND DA_DATA >= '"+DtoS(MV_PAR02)+"' " 
	cQuery += " AND DA_DATA <= '"+DtoS(MV_PAR03)+"' " 
	cQuery += " ORDER BY DA_DATA "
	
	If (Select("QRYSMS07") <> 0)
		dbSelectArea("QRYSMS07")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYSMS07"
	         	 
	dbSelectArea("QRYSMS07")   
	QRYSMS07->(dbGoTop())


Return                       


//Recarrega dados em tela
User Function SMS07REC() 

	Pergunte(_CPERG)
	
	//Exclui TRB
	ExcluiTRB()
   
   	//Gera Query de dados
	GeraQry()
	
    //Gera arquivo de Trabalho
	//GeraTRB()
	 
	//Grava arquivo de trabalho
	GravaTRB()
          
	MarkBRefresh()	

Return                        
                      

//Confirma dados
User Function SMS07OK() 
     
    Local aSMS07Ped := {}   

	If !MsgYesNo("Confirma Endere�amento com Data Base: "+DtoC(dDataBase)+" ?")
		Return()
	EndIf
    
    //Chama Janela para colocar os dados
    If !U_SMS07END()
        Return
    Endif 
    
	Dbselectarea('TRB')
	TRB->(DbGoTop())
	
	While TRB->(!Eof())
	     
	     If cMark == TRB->DA_OK
	      	AADD(aSMS07Ped,TRB->RECNO )  
	      Endif
		
		TRB->(dbskip())
	Enddo
	     
	                       
	If len(aSMS07Ped) > 0 
	
	   //Grava TABELA SDA 
	   GravaSDA(aSMS07Ped)  	
	   U_SMS07REC()                   
	  	   
	Else
		Alert('Selecione ao menos um item!')
	Endif
	
Return
              
    
//Grava dados e gera Rotina autom�tica    
Static function GravaSDA(xPedG)
   
   Local cErrors  := "" 
   Local aErro 	  := {}
   Local aGerados := {}
   Local _cDoc    := ""
   Local _cProd   := ""  
   Local cMsg     := ""  
   Local _lRastro := .F.        
   
   For i := 1 to len(xPedG)
  	
  	 DbSelectarea('SDA')
  	 DbsetOrder(1)
  	 DbGoto(xPedG[i])   
  	     
  	 	lmsErroAuto := .F.
  	 
  	 		aItem := {}  
			
			 //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	  			//xLocaliz := cLocaliz
				//xLote 	  := cGet1  
            _cProd   := SDA->DA_PRODUTO 
            _cDoc    := SDA->DA_DOC
  			_lRastro  := Rastro(SDA->DA_PRODUTO)//_cRastro := POSICIONE('SB1',1,xfilial('SB1')+SDA->DA_PRODUTO,"B1_RASTRO")
  			
  			
  			aCab := {{"DA_PRODUTO"	,SDA->DA_PRODUTO,NIL},;
			{"DA_QTDORI"	,SDA->DA_QTDORI	,NIL},;
			{"DA_SALDO"		,SDA->DA_SALDO	,NIL},;
			{"DA_DATA"		,SDA->DA_DATA	,NIL},;
			{"DA_LOTECTL"	,iif(_lRastro, SDA->DA_LOTECTL,""),NIL},;    
			{"DA_DOC"		,SDA->DA_DOC	,NIL},;
			{"DA_LOCAL"		,SDA->DA_LOCAL	,NIL},;
			{"DA_ORIGEM"	,SDA->DA_ORIGEM	,NIL},;
			{"DA_NUMSEQ"	,SDA->DA_NUMSEQ	,NIL}}    
		//	{"DA_NUMLOTE"	,SDA->DA_NUMLOTE,NIL},;
		      
			nItem := 1 
			
			//Trata itens estornados
			DBSELECTAREA('SDB')
			DBSETORDER(1)
			_cSeek    := xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ+SDA->DA_DOC+SDA->DA_SERIE+SDA->DA_CLIFOR+SDA->DA_LOJA
			if DBSEEK(_cSeek)
				while SBD->(!EOF()) .AND. _cSeek == SDB->DB_FILIAL+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA
					IF SDB->DB_TM <= "500" .And. SDB->DB_TIPO == "D"   
						Aadd(aItem, {	{"DB_ITEM"		,StrZero(nItem,4)	,NIL},; 
									{"DB_ESTORNO"	,SDB->DB_ESTORNO	,NIL},;
									{"DB_TIPO"		,SDB->DB_TIPO		,NIL},;
									{"DB_LOCAL"		,SDB->DB_LOCAL		,NIL},;
									{"DB_LOCALIZ"	,SDB->DB_LOCALIZ	,NIL},;//{"DB_ESTFIS"	,SBE->BE_ESTFIS		,NIL},;
									{"DB_LOTECTL"	,SDB->DB_LOTECTL	,NIL},;//{"DB_NUMLOTE"	,SDA->DA_NUMLOTE	,NIL},; 
									{"DB_QUANT "	,SDB->DB_QUANT      ,NIL},;
									{"DB_DATA"		,SDB->DB_DATA		,NIL}})
			
		   				nItem++			
					ENDIF 
					SDB->(dbskip())
				Enddo
			 Endif
			
			Aadd(aItem, {	{"DB_ITEM"		,StrZero(nItem,4)	,NIL},;
			{"DB_LOCAL"		,SDA->DA_LOCAL		,NIL},;
			{"DB_LOCALIZ"	,xLocaliz			,NIL},;//{"DB_ESTFIS"	,SBE->BE_ESTFIS		,NIL},;
			{"DB_LOTECTL"	,iif(_lRastro, SDA->DA_LOTECTL,"")				,NIL	},;//{"DB_NUMLOTE"	,SDA->DA_NUMLOTE	,NIL},; 
			{"DB_QUANT "	,SDA->DA_SALDO      ,NIL},;
			{"DB_DATA"		,ddatabase			,NIL}})
			
			nItem++
			
			//{"DB_TIPO"		,'D'				,NIL},;
			//{"DB_NUMSEQ"	,ProxNum()			,NIL},;
			//{"DB_ORIGEM"	,'SD3'				,NIL},;
			//{"DB_ALI_WT"	,"SDB"				,NIL},;
			//{"DB_QUANT"		,nQuant  			,NIL}})      

			MSExecAuto({|x,y,z| mata265(x,y,z)},aCab,aItem,3) //Distribui
	
			If lmsErroAuto               
				MostraErro()
				aAdd(aErro,{ _cDoc , _cProd })		      
		  	Else
		       	aAdd(aGerados,{_cDoc , _cProd})
		    Endif   		
   Next i    
   
   //Mensagem de Errados
   If len(aerro) > 0   
   		cMsg := "Os Itens Abaixo N�O foram Endere�ados: "+chr(10)+chr(13)
   Endif
   For i := 1 to len(aErro)  
        cMsg += " Produto: "+alltrim(aErro[i][2])+", Doc: "+alltrim(aErro[i][1])+chr(10)+chr(13)
   Next i
   If alltrim(cMsg) <> "" 
    	Alert(cMsg)                                                                             
    	cMsg := ""
   Endif          
      
   //Mensagem de Gerados
   If len(aGerados) > 0   
   		cMsg := "Os Itens Abaixo foram Endere�ados COM SUCESSO: "+chr(10)+chr(13)
   Endif
   For i := 1 to len(aGerados)  
          cMsg += " Produto: "+alltrim(aGerados[i][2])+", Doc: "+alltrim(aGerados[i][1])+chr(10)+chr(13)
   Next i  
   If alltrim(cMsg) <> "" 
    	MSGINFO(cMsg,"Informacao")                                                                           
    	cMsg := ""
   Endif          

Return                        
        

//Tela para coloca��o do endere�o e Armazem
User Function SMS07END()
                                           
	Local oDlg1
	Local oButton1
	Local oGet1
	Local cGet1 :=  "          "
	Local oLocaliz
	Local cLocaliz := "               "
	Local oSay1
	Local oSay2       
	Local lRetu := .F.

  DEFINE MSDIALOG oDlg1 TITLE "Informe os Campos" FROM 000, 000  TO 145, 250 COLORS 0, 16777215 PIXEL
   
    @ 022-10, 011 SAY oSay2 PROMPT "Endereco" SIZE 025, 007 OF oDlg1 COLORS 0, 16777215 PIXEL 
    @ 021-10, 043 MSGET oLocaliz VAR cLocaliz SIZE  060, 010 F3 'SBE' OF oDlg1 COLORS 0, 16777215 PIXEL 
    
 //   @ 042-10, 007 SAY oSay1 PROMPT "Lote" SIZE 025, 007 OF oDlg1 COLORS 0, 16777215 PIXEL
//    @ 041-10, 042 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg1 COLORS 0, 16777215 PIXEL       
     
    
    @ 056, 067 BUTTON oButton1 PROMPT "Confirmar"  ACTION( lRetu := .T., oDlg1:End() )SIZE 037, 012 OF oDlg1 PIXEL
    
  ACTIVATE MSDIALOG oDlg1        
  
  If  lRetu
	xLocaliz := cLocaliz
//	xLote 	  := cGet1  
  Else
	xLocaliz  := ""
//	xLote 	  := ""    
  Endif	
	   
Return lRetu
                            
    
//Exclui arquivo de trabalho
Static Function ExcluiTRB()

    Dbselectarea('TRB')
    TRB->(Dbgotop())
    While TRB->(!EOF())
                      
         Reclock('TRB',.F.)
          	dbdelete()
         Msunlock()
         
    	TRB->(DbSkip())
    Enddo
    
Return


//Pergunte 
Static Function ValPerg(_CPERG)

	PutSx1(_CPERG,"01","Armazem  ","", "", "mv_ch1","C",02,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
	PutSx1(_CPERG,'02','Data de  ','', '', 'mv_ch2','D',08,0,0,'G','','','','','mv_par02','','','','','','','','','','','','','','','','','','','')
	PutSx1(_CPERG,'03','Data At� ','', '', 'mv_ch3','D',08,0,0,'G','','','','','mv_par03','','','','','','','','','','','','','','','','','','','')
	 
Return  