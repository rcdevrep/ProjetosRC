#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch" 

/*
ROTINA DE INTEGRAÇÃO COM DBGINT - ROTINA PRINCIPAL
*/             
/*/{Protheus.doc} AGX635Z
//ROTINA DE INTEGRAÇÃO COM DBGINT - Logs 
@author Spiller
@since 11/12/2017
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/ 
User Function AGX635Z()

	PRIVATE aRotina:= { ;//{ "Visualizar" ,"AxVisual" , 0 , 1},;//}    // }      
						{ "Importar" 	    		,"u_635ZIMP()" , 0 , 3},;//,;  // }  
	                    { "Filtrar"		    		,"u_635ZFIL()" , 0 , 3},;  // }  
	                    { "Gerar DT6"      		 	,"u_635ZDT6()", 0 , 3},;                 //{ "Relatorio Diverg.","u_635ZREL()", 0 , 3},;   
	                    { "Marcar como Importado"	,"u_635ZUPD()", 0 , 3},; 
	                    { "Excluir LOGS"  			,"u_635ZEXC()", 0 , 3}}  // }  
	
	Private cCadastro := "Registro de LOGS "    
	                                             
	//roda somente na empresa 01
	If (cEmpAnt == '01' .AND. cFilAnt == '01')
		dbselectarea('ZDB')
		Dbsetorder(2)
		mBrowse( 6, 1,22,75,"ZDB")
	Else
	    Alert("Essa rotina só deve ser executada pela empresa Agricopel(01-01)")
	Endif
Return()     
                 
                
//Rotina de importação
User Function 635ZIMP()

	Local aEmpDePara := {}
	Local lIntProd   := .F.//Integra Produto
	Local lIntCF 	 := .F.//Integra Cliente/Fornecedor
	Local lIntNE	 := .f.//Integra Nota de Entrada 
	Local lIntCTE    := .f.//Integra CTE Entrada
	Local lIntNS	 := .f.//Integra Nota de Saída
	Local lIntCTS    := .f.//Integra CTE Saída 
	Local oDlg_IMP
	Local oButton1
	Local oCheckBox2
 	Local oCheckBox4
	Local oCheckBox5
	Local oCheckBox6
	Local oCheckBox7
	Local oCheckBox8
	Local oGroup1 
	Local lConfirm  := .F.   
	Local lWhenProd := .F.
	Local lWhenNE   := .F.
	Local lWhenNS   := .F.
	Local lWhenCTE  := .F.
	Local lWhenCTS  := .F.  
	Local cHora     := ""    
	Local cMinutos  := ""
	
	//Bloqueio de Rotina enquanto Executando Schedule que roda de Hora em Hora
	If !(substr(alltrim(GetEnvServer()),1,10) == 'N2SD9W_HOM'	.OR. substr(alltrim(GetEnvServer()),1,12) == 'N2SD9W_MIGRA' ) 
		cHora 	 := SUBSTR(TIME(), 1, 3)  
		cMinutos := SUBSTR(TIME(), 4, 2)
		If Val(cMinutos) < 10 .or. Val(cMinutos) > 55//Só libera a Utilização após 10 minutos e antes de 5 Minutos da execução do Schedule
			MsgInfo('Rotina está sendo executada via schedule, você somente poderá utilizar após as '+cHora+'10 .') 
			Return		
		Endif 
	Endif
	  
	//Somente Ativo Entradas                   
	If __cUserID $ GetMV('MV_XIMPENT') 
		 lWhenProd := .T.
		 lWhenNE   := .T.
		 lWhenCTE  := .T.		
	Endif    
	
	//Somente Ativo saídas
	If __cUserID $ GetMV('MV_XIMPSAI')  
		 lWhenNS   := .T.   
		 lWhenCTS  := .T.
	Endif            
	
	//Administrador Tem todos os acessos
	if __cUserID = '000000'
		 lWhenProd := .T.
		 lWhenNE   := .T.
		 lWhenNS   := .T.
		 lWhenCTE  := .T.
		 lWhenCTS  := .T.
	Endif 
	
	
                              
	DEFINE MSDIALOG oDlg_IMP TITLE "Importar" FROM 000, 000  TO 280, 370 COLORS 0, 16777215 PIXEL
	
	    @ 010, 007 GROUP oGroup1 TO 130, 170 PROMPT "   Importar   " OF oDlg_IMP COLOR 0, 16777215 PIXEL
	    @ 013+20, 008+10 CHECKBOX oCheckBox2 VAR lIntProd PROMPT "Produto"    WHEN lWhenProd SIZE 048, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
	    @ 023+20, 008+10 CHECKBOX oCheckBox7 VAR lIntNS PROMPT "Nota Saída"   WHEN lWhenNS SIZE 048, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
	    @ 033+20, 008+10 CHECKBOX oCheckBox5 VAR lIntNE PROMPT "Nota Entrada" WHEN lWhenNE SIZE 048, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
	    @ 043+20, 008+10 CHECKBOX oCheckBox8 VAR lIntCTS PROMPT "CTE Saída"   WHEN lWhenCTS SIZE 048, 008 OF oGroup1 COLORS 0, 16777215 PIXEL 
   	    @ 053+20, 008+10 CHECKBOX oCheckBox6 VAR lIntCTE PROMPT "CTE Entrada" WHEN lWhenCTE SIZE 048, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
		//@ 063+20, 008+10 CHECKBOX oCheckBox4 VAR lIntCF PROMPT "Cliente/Forn" SIZE 048, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
	    @ 101+10, 107+10 BUTTON oButton1 PROMPT "Confirmar" Action( lConfirm := .T.,oDlg_IMP:END()) SIZE 037, 012 OF oGroup1 PIXEL
	
	ACTIVATE MSDIALOG oDlg_IMP	    
    
     
    //Se confirmou executa programas de importação
    If lConfirm
    
	    // Monta Array que mapeia as empresas - DBGint X Protheus - aEmpresas{nEmpresa, {}}
		aEmpDePara := U_AGX635EM()
	      
		If (Len(aEmpDePara) > 0)
			If lIntProd //Integra Produtos  
				//aEmpDePara := startjob("U_AGX635PR",getenvserver(),.T.,@aEmpDePara)
				 MsgRun( "Integrando Produtos - Aguarde..." , "Executando Produtos" , { || aEmpDePara := startjob("U_AGX635PR",getenvserver(),.T.,@aEmpDePara)} )
		 	Endif
		    //If lIntCF//Integra Cliente Fornecedor
			//	U_AGX635CF(aEmpDePara)  
			//Endif  
			If 	lIntNE//Integra Nota de Entrada   
				MsgRun( "Integrando Exclusão de Entrada - Aguarde..." , "Executando Exclusão de Nota de Entrada" , { || aEmpDePara := startjob("U_AGX635EX",getenvserver(),.T.,@aEmpDePara) })
				MsgRun( "Integrando Notas de Entrada - Aguarde..." , "Executando Nota de Entrada" , { || aEmpDePara := startjob("U_AGX635NE",getenvserver(),.T.,@aEmpDePara) }) 
			Endif  
			If 	lIntCTE//Integra CTE Entrada
   				MsgRun( "Integrando Exclusão de Entrada - Aguarde..." , "Executando Exclusão de CTE de Entrada" , { || aEmpDePara := startjob("U_AGX635EX",getenvserver(),.T.,@aEmpDePara) })
				MsgRun( "Integrando CTE Entrada - Aguarde..." , "Executando CTE Entrada" , { || aEmpDePara := startjob("U_AGX635CE",getenvserver(),.T.,@aEmpDePara) })
			Endif  		   
			If 	lIntNS//Integra Nota de Saída
				MsgRun( "Integrando  Nota de Saída - Aguarde..." , "Executando Nota de Saída " , { || aEmpDePara := startjob("U_AGX635NS",getenvserver(),.T.,@aEmpDePara) }) 
			Endif   
			If 	lIntCTS//Integra CTE Saída
					MsgRun( "Integrando  CTE Saída- Aguarde..." , "Executando  CTE Saída" , { || aEmpDePara := startjob("U_AGX635CS",getenvserver(),.T.,@aEmpDePara)})
			Endif  			
		EndIf
  
    Endif      
    
    OpenSM0() //Abrir Tabela SM0 (Empresa/Filial) 
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DBSEEK('0101')) //Restaura Tabela
	cFilAnt := '01' //Restaura variaveis de ambiente
	cEmpAnt := '01'
	OpenFile('01' + '01')
	DBSELECTAREA('ZDB')
	Dbsetorder(2)
    
Return 
     
//Função para Criação de Filtro    
User Function 635ZFIL()

   Local cFiltro      := ""   
   Private cPerg      := 'AGX635Z'
   
   cFiltro := ""
   If Pergunte(cPerg)

   		IF !Empty(MV_PAR02)
   			cFiltro  +=  " ZDB_EMP >= '"+MV_PAR01+"' .AND. ZDB_EMP <= '"+MV_PAR02+"' "  
   		Endif
   		
   		IF !Empty(MV_PAR04)
   			cFiltro  += Iif( alltrim(cFiltro)<>'', ' .AND. ', '' )     
   	   		cFiltro  +=  " ZDB_FILIAL >= '"+MV_PAR03+"' .AND. ZDB_FILIAL <= '"+MV_PAR04+"' " 
   		Endif
   		
   		IF !Empty(MV_PAR06)
   	   		cFiltro  += Iif( alltrim(cFiltro)<>'', ' .AND. ', '' ) 
   	  		cFiltro  +=  " DTOS(ZDB_DATA) >= '"+DTOS(MV_PAR05)+"' .AND. DTOS(ZDB_DATA) <= '"+DTOS(MV_PAR06)+"' " 
   		Endif
   		
   		IF !Empty(MV_PAR08)
   	   		cFiltro  += Iif( alltrim(cFiltro)<>'', ' .AND. ', '' ) 
   	   		cFiltro  +=  " ZDB_HORA >= '"+MV_PAR07+"' .AND. ZDB_HORA <= '"+MV_PAR08+"' " 
   		Endif
  
	    dbSelectarea('ZDB')                                       
	    dbsetorder(1)

    Endif
                  
	_oObj := GetObjBrow()
	_oObj:Default()  
	if Alltrim(cFiltro) <> ''
		 _oObj:SetFilterDefault(cFiltro)
	Endif
	_oObj:Refresh() 
	
Return           

//Rotina de Geração da Tabela DT6
User Function 635ZDT6()
	
	Local aRegistros := {}  
	Local cPerg      := "AGX635D6" 
	Local aParamDT6  := {}     
	   
	//Se For administrador ou cadastrado no Parâmetro de saídas
	If ! ((__cUserID $ GetMV('MV_XIMPDT6') ) .or. __cUserID == '000000' ) 
		Alert('Usuário sem acesso a Geração da Rotina')
	   	Return	
	Endif
	
	AADD(aRegistros,{cPerg,"01","Serie De          ?","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Serie Ate         ?","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","CTE De            ?","mv_ch3","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","CTE Ate           ?","mv_ch4","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Emissao De        ?","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Emissao Ate       ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Filial De        ?","mv_ch7","C",2,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Filial Ate       ?","mv_ch8","C",2,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	//AADD(aRegistros,{cPerg,"09","Empresa De        ?","mv_ch9","C",2,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	//AADD(aRegistros,{cPerg,"10","Empresa Ate       ?","mv_cha","C",2,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	
	If !Pergunte(cPerg, .T.)
		Return
	Endif  
	
	If !MsgBox("Esse Processo pode demorar alguns minutos, Deseja continuar? " ,"Limpar LOGS","YESNO")  
		Return
	Endif
	
	AADD(aParamDT6,MV_PAR01)   
	AADD(aParamDT6,MV_PAR02) 
	AADD(aParamDT6,alltrim(str(Val(StrTran(MV_PAR03,'Z','9'))))) 
	AADD(aParamDT6,alltrim(str(Val(StrTran(MV_PAR04,'Z','9'))))) 
	AADD(aParamDT6,DateMySql(MV_PAR05,'00')) 
	AADD(aParamDT6,DateMySql(MV_PAR06,'99'))
	AADD(aParamDT6,MV_PAR07)   
	AADD(aParamDT6,MV_PAR08)  
	//AADD(aParamDT6,MV_PAR09)   
	//AADD(aParamDT6,MV_PAR10) 

	 	
	// Monta Array que mapeia as empresas - DBGint X Protheus - aEmpresas{nEmpresa, {}}
	aEmpDePara := U_AGX635EM()
	      
	If (Len(aEmpDePara) > 0)
	   //	aEmpDePara := startjob("U_AGX635D6",getenvserver(),.T.,@aEmpDePara,@aParamDT6)
		aEmpDePara := startjob("U_AGX635D6",getenvserver(),.T.,@aEmpDePara,aParamDT6) 
	Endif
	

	OpenSM0() //Abrir Tabela SM0 (Empresa/Filial) 
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DBSEEK('0101')) //Restaura Tabela
	cFilAnt := '01' //Restaura variaveis de ambiente
	cEmpAnt := '01'
	OpenFile('01' + '01')
	DBSELECTAREA('ZDB')
	Dbsetorder(2)

Return       
    
//Transforma em DATA/HORA do Myql
Static Function DateMySql(xData,xTime) 

	Local cDateMSql := "" 

	cDateMSql := dtos(xData)
	cDateMSql := substr(cDateMSql,1,4)+'-'+substr(cDateMSql,5,2)+'-'+substr(cDateMSql,7,2)+' '+xTime


Return cDateMSql 

//Exclusão de LOGS
User Function 635ZEXC()   

	Local aRegistros := {}  
	Local cPerg      := "AGX635ZEXC" 
	Local aParamDT6  := {}
	
	AADD(aRegistros,{cPerg,"01","Data De        ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data Ate       ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	
	U_CriaPer(cPerg,aRegistros)
	
	If !Pergunte(cPerg, .T.)
		Return   
	Else
		If !MsgBox("Deseja excluir TODOS os Logs de "+DTOC(MV_PAR01)+" até "+DTOC(MV_PAR02)+"" ,"Limpar LOGS","YESNO")
			Return
  		EndIf
	Endif    
	
	Dbselectarea('ZDB')
	Dbsetorder(2)
	//DTOS(ZDB_DATA)+ZDB_HORA    
	Dbseek(DTOS(mv_par01),.T.)    
	While ZDB->(!eof()) .and. DTOS(mv_par02) >=  DTOS(ZDB->ZDB_DATA) 
	     Reclock('ZDB',.F.)
	     	dbdelete()	
	     Msunlock()  	
		ZDB->(dbskip())
	Enddo 

Return


//Marca Registro no DBGInt como Importado
User Function 635ZUPD()

	Local lNotaEnt   := iif(alltrim(ZDB->ZDB_ROTINA) == 'AGX635NE',.T.,.F. )
	Local lCteSaida  := iif(alltrim(ZDB->ZDB_ROTINA) == 'AGX635CS',.T.,.F. )                           
	Local lProduto	 := iif(alltrim(ZDB->ZDB_ROTINA) == 'AGX635PR',.T.,.F. )   
	Local lExcNota   := iif(alltrim(ZDB->ZDB_ROTINA) == 'AGX635EX',.T.,.F. ) 
	Local lNotaSai   := iif(alltrim(ZDB->ZDB_ROTINA) == 'AGX635NS',.T.,.F. )	 
	Local cQuery     := ""
	Local lErroSQL   := .F. 
	Local lExistUPD  := .F.
	
	If !MsgBox("Deseja Marcar o Registro como Importado? Dessa forma o sistema não tentará importá-lo novamente."+;
				"Será marcado o campo de importação com ('2000-01-01 00:00:00')","Marcar Data/Hora","YESNO")
		Return
  	EndIf                        
	       
 	Do Case 
 	
 		Case lNotaSai  
 		
 			If /*ZDB->ZDB_TIPOWF == 8 .and.*/ 'existe'  $ ZDB->ZDB_MSG
			     
				lExistUPD := .T.
				cQuery += " UPDATE VEN_NOTSAI SET "
	  			cQuery += " VEN_NOTSAI_DHIntTotvs = '2000-01-01 00:00:00' "
	 			cQuery += " WHERE (VEN_NOTSAI_DHIntTotvs IS NULL "
				
				_cID := 	alltrim(ZDB->ZDB_DBCHAV)   
				
				If alltrim(_cID) <> ''
					cQuery += " AND GEN_TABEMP_Codigo 	  =  "+ZDB->ZDB_DBEMP+""
					cQuery += " AND GEN_TABFIL_Codigo	  =  "+ZDB->ZDB_DBFIL+""
					cQuery += " AND VEN_NOTSAI_Numero 		  =  "+_cID+" ) "     
					 
					U_AGX635CN("DBG") 
					If (TCSQLExec(cQuery) < 0)  
   						lErroSQL := .T.
					Endif             
					U_AGX635CN("PRT") 
				Endif     
			Endif
	
 	 	
		Case  lNotaEnt  
		       
		    //Se Foi erro de update atualiza de acordo com DBCHAVE, pois já está formatada
			If ZDB->ZDB_TIPOWF == 8 .and. 'Update'  $ ZDB->ZDB_MSG 
				
				lExistUPD := .T.
				cQuery += " UPDATE COM_NOTCOM SET "
				cQuery += " COM_NOTCOM_DHIntTotvs = '2000-01-01 00:00:00'" //current_timestamp() "
				cQuery += " WHERE (COM_NOTCOM_DHIntTotvs IS NULL "
			    cQuery += ZDB->ZDB_DBCHAV  
			       
			    U_AGX635CN("DBG") 
			    If (TCSQLExec(cQuery) < 0)  
   					lErroSQL := .T.
				Endif     
		
		   		U_AGX635CN("PRT")
			Else  

				_aCampos := 	SEPARA(ZDB->ZDB_DBCHAV,'+')
	
				If len(_aCampos) > 3 .and. !(Empty(ZDB->ZDB_DBEMP)) .and. !(Empty(ZDB->ZDB_DBFIL))
					 
					lExistUPD := .T.		   
					cQuery += " UPDATE COM_NOTCOM SET "
					cQuery += " COM_NOTCOM_DHIntTotvs = '2000-01-01 00:00:00'" //current_timestamp() "
					cQuery += " WHERE (COM_NOTCOM_DHIntTotvs IS NULL "
					cQuery += " AND STG_GEN_TABEMP_Codigo 	  =  "+ZDB->ZDB_DBEMP+""
			   		cQuery += " AND STG_GEN_TABFIL_Codigo	  =  "+ZDB->ZDB_DBFIL+""
			  		cQuery += " AND COM_NOTCOM_NUMERO 		  =  "+_aCampos[1]+""
			  		cQuery += " AND COM_NOTCOM_SERIE 		  =  '"+_aCampos[2]+"'"
			  		cQuery += " AND STG_GEN_TABENT_For_Codigo =  "+_aCampos[3]+""
			   		cQuery += " AND STG_GEN_ENDENT_For_Codigo =  "+_aCampos[4]+") "  
		   	      
		   			U_AGX635CN("DBG") 
		   		
		   		   	If (TCSQLExec(cQuery) < 0)  
   				  		lErroSQL := .T.
				  	Endif     
		
		   			U_AGX635CN("PRT")
		   		Else  
		   			For i := 1 to len(_aCampos) 
		   	   			  _cCampos := _aCampos[i]
		   	 		Next i  
		   	 		Alert('Chave Incompleta ('+ZDB->ZDB_DBEMP+')+('+ZDB->ZDB_DBFIL+'): '+_cCampos) 
		   		Endif 
		   		
		    Endif  
		Case  lCteSaida   
		             
	   		_aCampos := 	SEPARA(ZDB->ZDB_DBCHAV,'+')  
	   		
	   		If len(_aCampos) > 1 .and. !(Empty(ZDB->ZDB_DBEMP)) .and. !(Empty(ZDB->ZDB_DBFIL))
				     
				lExistUPD := .T.
				cQuery += " UPDATE CTE_MOVCTE SET "
	   	   		cQuery += " CTE_MOVCTE_DHIntTotvs = '2000-01-01 00:00:00'" //= current_timestamp() "
				cQuery += " WHERE CTE_MOVCTE_DHIntTotvs IS NULL " 
				cQuery += " AND STG_GEN_TABEMP_CTe_Codigo 	  =  "+ZDB->ZDB_DBEMP+""
				cQuery += " AND STG_GEN_TABFIL_CTe_Codigo =  "+ZDB->ZDB_DBFIL+""
		   		cQuery += " AND CTE_MOVCTE_Numero	 	  =  " +_aCampos[1]+""
		   		cQuery += " AND  CTE_MOVCTE_Serie		  =	 '"+_aCampos[2]+"' " 
		   		 
		   		U_AGX635CN("DBG") 
		  
		   	  	If (TCSQLExec(cQuery) < 0)  
   			 		lErroSQL := .T.
			  	Endif
		   		
		   		U_AGX635CN("PRT")
			Else
				For i := 1 to len(_aCampos) 
		   	   		  _cCampos := _aCampos[i]
		   	 	Next i  
		   	 	Alert('Chave Incompleta ('+ZDB->ZDB_DBEMP+')+('+ZDB->ZDB_DBFIL+'): '+_cCampos) 
		  	Endif
		Case lProduto    
		
			_aCampos := 	SEPARA(ZDB->ZDB_DBCHAV,'+')               
		
			If len(_aCampos) > 0 .and. !(Empty(ZDB->ZDB_DBEMP)) .and. !(Empty(ZDB->ZDB_DBFIL))  
			     
				lExistUPD := .T.
				cQuery += " UPDATE EST_TABPRO SET "
				cQuery += " EST_TABPRO_DHIntTotvs = '2000-01-01 00:00:00' " //current_timestamp() "
				cQuery += " WHERE EST_TABPRO_DHIntTotvs IS NULL "
				cQuery += " AND  GEN_TABEMP_Codigo = " + ZDB->ZDB_DBEMP+" "
				cQuery += " AND  EST_TABPRO_Codigo =  " + _aCampos[1] + " "  
				
				U_AGX635CN("DBG")
				
			   	If (TCSQLExec(cQuery) < 0)  
   			  		lErroSQL := .T.
			  	Endif
				
				U_AGX635CN("PRT") 
			Else
				For i := 1 to len(_aCampos) 
		   	   		  _cCampos := _aCampos[i]
		   	 	Next i  
		   	 	Alert('Chave Incompleta ('+ZDB->ZDB_DBEMP+')+('+ZDB->ZDB_DBFIL+'): '+_cCampos) 
		  	Endif       
		
		Case lExcNota   
			
			_aCampos := 	SEPARA(ZDB->ZDB_DBCHAV,'+')               
		
			If len(_aCampos) > 3 .and. !(Empty(ZDB->ZDB_DBEMP)) .and. !(Empty(ZDB->ZDB_DBFIL))  
				
				lExistUPD := .T.
				cQuery += " UPDATE COM_NOTCOM_EXC SET "
				cQuery += " COM_NOTCOM_EXC_DHIntTotvs =  '2000-01-01 00:00:00' " //current_timestamp() "
	   			cQuery += " WHERE COM_NOTCOM_EXC_DHIntTotvs IS NULL "
	   			cQuery += " AND COM_NOTCOM_EXC_Empresa 	 	  =  "+ZDB->ZDB_DBEMP+""
				cQuery += " AND COM_NOTCOM_EXC_Filial	  =  "+ZDB->ZDB_DBFIL+" "
				cQuery += " AND COM_NOTCOM_EXC_Numero 	  =  "+_aCampos[1]+" "
				cQuery += " AND COM_NOTCOM_EXC_Serie 	  =  '"+_aCampos[2]+"' "
				cQuery += " AND COM_NOTCOM_EXC_Fornecedor =  "+_aCampos[3]+" "
				cQuery += " AND COM_NOTCOM_EXC_Endereco   =  "+_aCampos[4]+" "  
				
				U_AGX635CN("DBG")
				
			   	If (TCSQLExec(cQuery) < 0)  
   			   		lErroSQL := .T.
			  	Endif
				
				U_AGX635CN("PRT") 
			Else
				For i := 1 to len(_aCampos) 
		   	   		  _cCampos := _aCampos[i]
		   	 	Next i  
		   	 	Alert('Chave Incompleta ('+ZDB->ZDB_DBEMP+')+('+ZDB->ZDB_DBFIL+'): '+_cCampos) 
		  	Endif
		
	Otherwise
			Alert('Não é possível marcar como importado!')
	Endcase 
    
    //Se deu erro No update, mostra query em tela
	If lExistUPD
		If lErroSQL 
			ALERT('Erro em UPDATE!')
			u_msgmemo("Erro ao executar UPDATE",cQuery,.f.)
   		Else
   		 	MsgInfo('Data/Hora Importação Atualizada!') 
    		u_msgmemo("UPDATE Executado",cQuery,.f.)
   		Endif 
   	Else
   		ALERT('Esse registro não está habilitado para marcar para NÃO importação, entre em contato com a TI!')     
   	Endif
    
Return