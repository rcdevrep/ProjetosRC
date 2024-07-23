#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch" 

// Rotina de importação
// Movimentos de Estoque DBGint
User Function AGX635ZM()

	Local aEmpDePara := {}
	Local lIntSB9    := .F.  
	Local lAjustaSB9 := .F.
	Local lInTSD3 	 := .F.
	Local lIntAMB	 := .f.
	Local lInTTUDO   := .f.  
	Local lInTSIM    := .F.
	Local oDlg_IMP
	Local oButton1    
	Local oCheckBox1
	Local oCheckBox2
 	Local oCheckBox5
	Local oCheckBox7 
	Local oCheckBox3
	Local oGroup1 
	Local oSay1  
	Local oSay2
	Local lConfirm   := .F.   
	Local lwhenSB9   := .F.
	Local lWhenSIM   := .F.
	Local lWhenTUDO  := .F.
	Local lWhenSD3   := .F.
	Local lWhenCTE   := .F.
	Local lWhenCTS   := .F.  
	Local cHora      := ""    
	Local cMinutos   := "" 
	Local cMesReq    := ""
	Local aFechament := {} 
	Local aFiliais   := {}
	Private cEmpLogada := cEmpAnt
	Private cFilLogada := cFilAnt  
	Private cAnoMes    := ""
 	Private cUlMes     := ""  
 	Private cUlMesBKP 
 	Private cDataHora := ""  
 
	lwhenSB9   := .T.
	lwhenAJUB9 := .T.
	lWhenSD3   := .T.
	lWhenTUDO  := .F.  
	lWhenSIM   := .T.   
	
	              
	//Valida se a Empresa Logada integra com DBGint
	If !(FilialDBG())
	  	Alert('Essa filial não possui integração com DBGINT! ')   
		Return
	Endif
                              
	DEFINE MSDIALOG oDlg_IMP TITLE "Fechamento Dbgint" FROM 000, 000  TO 280, 370 COLORS 0, 16777215 PIXEL
	
	    @ 010, 007 GROUP oGroup1 TO 130, 170 PROMPT "" OF oDlg_IMP COLOR 0, 16777215 PIXEL  
	    
	    @ 013+10, 008+10 SAY oSay1 PROMPT "Requisições" SIZE 040, 007 OF oDlg_IMP COLORS 0, 16777215 PIXEL 
	    @ 013+20, 008+10 CHECKBOX oCheckBox7 VAR lInTSD3   PROMPT "Importar Requisições do Mês('SD3')"   WHEN lWhenSD3 SIZE 128, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
   	    @ 023+20, 008+10 CHECKBOX oCheckBox3 VAR lInTSIM   PROMPT "Relatorio de Requisicoes('SD3') "   WHEN lWhenSIM SIZE 128, 008 OF oGroup1 COLORS 0, 16777215 PIXEL    
  	   
  	    @ 023+40, 008+10 SAY oSay2 PROMPT "Saldos" SIZE 040, 007 OF oDlg_IMP COLORS 0, 16777215 PIXEL 
  	    @ 033+40, 008+10 CHECKBOX oCheckBox2 VAR lIntSB9     PROMPT "Relatorio de Divergencias de Saldo Fec."   WHEN lwhenSB9 SIZE 128, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
	    @ 043+40, 008+10 CHECKBOX oCheckBox4 VAR lAjustaSB9  PROMPT "***Atenção*** Ajustar Divergencias Saldo Fec."   WHEN lwhenAJUB9 SIZE 128, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
   	    
   	    @ 053+50, 008+10 CHECKBOX oCheckBox1 VAR lInTTUDO PROMPT "Todas as Filiais ? "   WHEN lWhenTUDO SIZE 128, 008 OF oGroup1 COLORS 0, 16777215 PIXEL 
	    @ 101+10, 107+10 BUTTON oButton1 PROMPT "Confirmar" Action( lConfirm := .T.,oDlg_IMP:END()) SIZE 037, 012 OF oGroup1 PIXEL
	
	ACTIVATE MSDIALOG oDlg_IMP	    
    
    cUlMesBKP := dtos(GetMv("MV_ULMES")) 
     
    //Se confirmou executa programas de importação
    If lConfirm       	
    	      
    	If lIntSB9  .or. lAjustaSB9
			aPergs 	:= {}  		//PARAMBOX
			cCodRec := space(07)//PARAMBOX
			aRet    := {}		//PARAMBOX  
			
			
			cUlMes := cUlMesBKP
			cUlMes := Substring(cUlMes,1,4)+'/'+Substring(cUlMes,5,2)  
			AAdd( aPergs ,{1,"Ano / Mês:",cCodRec,"@",'.T.',,'.T.',40,.T.})  
			
			If ParamBox(aPergs ,"Estoque DBGint",aRet)      
				cAnoMes :=  aRet[1] 
				If alltrim(cAnoMes) <> '' .AND. '/' $ cAnoMes 
					
					If Substr(cAnoMes, 6,2 ) > '12' 
						Alert("Mês inválido "+Substr(cAnoMes, 6,2 ) ) 	
						Return
					//Valida se o Protheus está aberto com o Mês que está sendo importado no DBGInt
					Elseif cAnoMes > cUlMes .AND. SOMA1(Substring(cUlMes,6,2))  <>  Substring(cAnoMes,6,2)
						If ! (SOMA1(Substring(cUlMes,6,2))  == '13' .AND. Substring(cAnoMes,6,2) == '01')
							Alert("Somente pode trazer Saldo inicial(SB9) do DBGint do Período("+cAnoMes+"), se o mês estiver aberto no protheus, ultimo fechamento Protheus foi em ("+cUlMes+").") 	
							Return
						Endif	
					Else     
					
						If lAjustaSB9  		
							If !MsgYesno("Essa Rotina irá REPLICAR o Saldo de estoque e custos do DBGINT para Protheus e SOMENTE deverá ser utilizada "+;
							             "após cuidadosa análise do relatório de divergências e certificar-se que todas as requisições e Notas Foram Importadas "+;
							             ". Deseja continuar? ") 
							    	Return         
							Else
							
								If !MsgYesno("Fechamento Atual do Protheus("+cUlMes+")"+". Você escolheu AJUSTAR o SALDO do Mês("+cAnoMes+"), Confirma? ") 
					     			Return
								Endif
							Endif					
						Else
							If !MsgYesno("Fechamento Atual do Protheus("+cUlMes+")"+". Você escolheu analisar o Mês("+cAnoMes+") no DBGint, Confirma? ") 
					     		Return
							Endif
						Endif
					Endif
				Else
					Alert("Parâmetro deve ser preenchido com Ano/Mês, Exemplo: 2019/03 ") 
					Return
				Endif 
			Else
				Return
			EndIf   
		
		Elseif lInTSIM 
		
			aPergs 	:= {}  		//PARAMBOX
			cCodRec := space(07)//PARAMBOX
			aRet    := {}		//PARAMBOX  
			
			
			cUlMes := cUlMesBKP
			cUlMes := Substring(cUlMes,1,4)+'/'+Substring(cUlMes,5,2)  
			AAdd( aPergs ,{1,"Ano / Mês:",cCodRec,"@",'.T.',,'.T.',40,.T.})  
			
			If ParamBox(aPergs ,"Estoque DBGint",aRet)      
				cAnoMes :=  aRet[1] 
				If alltrim(cAnoMes) <> '' .AND. '/' $ cAnoMes 
					
					If Substr(cAnoMes, 6,2 ) > '12' 
						Alert("Mês inválido "+Substr(cAnoMes, 6,2 ) ) 	
						Return
					Endif
				Else
					Alert("Parâmetro deve ser preenchido com Ano/Mês, Exemplo: 2019/03 ") 
					Return
				Endif 
			Else
				Return
			EndIf   
		Elseif lInTSD3
			       
			cMesReq := Substr( dtoc( MonthSum( stod(cUlMesBKP), 1 ) ), 4,8 )   
			If !MsgYesno("Fechamento Atual do Protheus( "+dToc(stod(cUlMesBKP))+" )"+". Serão importadas as requisições do mês "+cMesReq+". Confirma? ")
			   	Return
			Endif
	
		Endif  
	    
	
		If	lIntTudo //Se for Rodar para Todas as Filiais
    	   
    		If !MsgYesno("Será importado o fechamento para todas as filiais, confirma? ")
    	   		Return		
    		Endif  
    		aFiliais := GetFiliais(cEmpAnt)

			//Varre as filiais para validar se estão fechadas
			For i := 1 to len(aFiliais)          
			
			   cFilialPara := aFiliais[i]
			   cUltFec  := 	dtos(SUPERGETMV( 'MV_ULMES', .F., '' , cFilialPara ))
			   
			   If cUlMesBKP <> cUltFec
			   	   Alert('A filial '+cFilialPara+' está com fechamento('+dtoc(stod(cUltFec))+'), diferente da filial '+cFilLogada+'('+dtoc(stod(cUlMesBKP))+ '). Verifique se as filiais foram fechadas antes de rodar Fechamento para todas!' )	
			   	   Return
			   Endif
			Next i                     
			
			aEmpDePara := U_AGX635EM( , ,cEmpLogada)
    		
  		Else
			aEmpDePara := U_AGX635EM( , ,cEmpLogada,cFilLogada)			
    	Endif  
   
    	// Monta Array que mapeia as empresas - DBGint X Protheus - aEmpresas{nEmpresa, {}}
	   //aEmpDePara := U_AGX635EM( , ,cEmpLogada,cFilLogada)
	   
		If (Len(aEmpDePara) > 0)

			If lIntSB9 .or. lAjustaSB9//Integra Produtos  
				//aEmpDePara := startjob("U_AGX635PR",getenvserver(),.T.,@aEmpDePara) 
				//CONOUT("Buscando Saldos Iniciais(SB9) - Aguarde")
			    MsgRun( "Buscando Saldos Iniciais(SB9) - Aguarde..." , "Executando Produtos" , { || aEmpDePara := startjob("U_AGX635MI",getenvserver(),.T.,@aEmpDePara,@cAnoMes,@lAjustaSB9/*@cUlmescAnoMes*/)} )
		 	Endif
			If 	lInTSD3
				MsgRun( "Integrando REQUISIÇÕES(SD3) - Aguarde..." , "Executando  REQUISIÇÕES" , { || aEmpDePara := startjob("U_AGX635MO",getenvserver(),.T.,@aEmpDePara)})		
			Endif  
			
			iF lInTSIM
				MsgRun( "Relatorio de REQUISIÇÕES(SD3) - Aguarde..." , "Relatorio  REQUISIÇÕES" , { || aEmpDePara := startjob("U_AGX635MR",getenvserver(),.T.,@aEmpDePara,@cAnoMes)})		
            Endif
			
			 							
		EndIf
  
	    cDirTemp  := AllTrim(GetTempPath())
	    cDataHora := '_'+dtos(dDatabase) +'_' +STRTRAN( time(),':','' ) 
	
	    //Log das movimentações     
	    If lInTSD3
	   		 __Copyfile("Log_MOVIMENTACOES_DBGINT.txt",cDirTemp+"Log_MOVIMENTACOES_DBGINT"+cDataHora+".txt")
	   		  shellExecute( "Open", "C:\Windows\System32\notepad.exe", "Log_MOVIMENTACOES_DBGINT"+cDataHora+".txt", cDirTemp, 1 )
	    Endif
	                            
		//Log do Estoque
	    If lIntSB9 .or. lAjustaSB9
	    	//__Copyfile("Log_SALDOINI_DBGINT.txt"     ,cDirTemp+"Log_SALDOINI_DBGINT.txt") 
	        //shellExecute( "Open", "C:\Windows\System32\notepad.exe", "Log_SALDOINI_DBGINT.txt", cDirTemp, 1 )   
	        
	        
	        If !ApOleClient("MsExcel")                     	
   	  			MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
   	  			Return	
   	  		EndIf
   	  		
			__Copyfile("Log_SALDOINI_DBGINT.csv",cDirTemp+"Log_SALDOINI_DBGINT"+cDataHora+".csv")             
				
			oExcelApp:= MsExcel():New()
			oExcelApp:WorkBooks:Open(AllTrim(cDirTemp)+"Log_SALDOINI_DBGINT"+cDataHora+".csv")//cArqTrbex+".XLS")
			oExcelApp:SetVisible(.T.)                       
						                 
			fErase("Log_SALDOINI_DBGINT.csv") //Deletando arquivo de trabalho	
	    Endif 
	     
	    //Relatorio de Movimentações
	    If lInTSIM     
	    		
       		If !ApOleClient("MsExcel")                     	
   	  			MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
   	  			Return	
   	  		EndIf
   	  		
			__Copyfile("Rel_MOVIMENTACOES_DBGINT.csv",cDirTemp+"Rel_MOVIMENTACOES_DBGINT"+cDataHora+".csv")             
				
			oExcelApp:= MsExcel():New()
			oExcelApp:WorkBooks:Open(AllTrim(cDirTemp)+"Rel_MOVIMENTACOES_DBGINT"+cDataHora+".csv")//cArqTrbex+".XLS")
			oExcelApp:SetVisible(.T.)                       
						                 
			fErase("Rel_MOVIMENTACOES_DBGINT.csv") //Deletando arquivo de trabalho	
	  	
        Endif
	    
	    OpenSM0() //Abrir Tabela SM0 (Empresa/Filial) 
		dbSelectArea("SM0")
		SM0->(dbSetOrder(1))
		SM0->(DBSEEK(cEmpLogada+cFilLogada)) //Restaura Tabela
		cFilAnt := cFilLogada //Restaura variaveis de ambiente
		cEmpAnt := cEmpLogada
		OpenFile(cEmpLogada + cFilLogada)
  
    Endif      
 
Return    

//Busca filiais 
Static Function GetFiliais(xEmp)

	Local aFilRet := {}
	Local cQuery   := ""
	
	cQuery := " SELECT * FROM EMPRESAS "
	cQuery += " WHERE EMP_COD = '"+xEmp+"' AND INTEGRA_DBGINT = 'S' "
	
	If Select("GETFILIAIS") <> 0
		dbSelectArea("GETFILIAIS")
		("GETFILIAIS")->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ("GETFILIAIS")  
	
	While ("GETFILIAIS")->(!eof())
		AADD(aFilRet,EMP_FIL) 
   		("GETFILIAIS")->(dbskip())
	Enddo    

Return aFilRet   

//Busca filiais 
Static Function FilialDBG()

	Local lRet     := .F.
	Local cQuery   := ""
	
	cQuery := " SELECT * FROM EMPRESAS "
	cQuery += " WHERE EMP_COD = '"+cEmpAnt+"' AND EMP_FIL = '"+cFilAnt+"' AND INTEGRA_DBGINT = 'S' "
	
	If Select("GETFILIAIS") <> 0
		dbSelectArea("GETFILIAIS")
		("GETFILIAIS")->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS ("GETFILIAIS")  
	
	IF  ("GETFILIAIS")->(!eof())
		lRet := .T.
	Endif  
	
	If Select("GETFILIAIS") <> 0
		dbSelectArea("GETFILIAIS")
		("GETFILIAIS")->(dbCloseArea())
	Endif
  

Return lRet 