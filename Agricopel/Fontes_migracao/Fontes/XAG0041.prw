#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} XAG0030
Função para geração de Relatorio de Borderô por dia
@author Leandro Spiller
@since 20/09/2018
@version 1.0
@return Nil, Função não tem retorno
@example XAG0041()
/*/  
User Function XAG0041()  

	Local cQuery := ""
	Local cPerg := "XAG0041"   
	
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Emissao De        ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Emissao Ate       ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Bordero De        ?","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","bordero Ate       ?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	U_CriaPer(cPerg,aRegistros)
	       
	If !Pergunte(cPerg,.T.)
		Return 
    Endif
		
	cQuery := ""	
	cQuery += "	SELECT E1_TIPO,E1_FILORIG,E1_NUMBOR, E1_PORTADO AS BANCO,E1_CONTA AS CONTA,E1_NUMBCO AS NN,* FROM "+RetSqlName('SE1')+ "(NOLOCK) "
	cQuery += "	WHERE E1_DATABOR  BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND "
	cQuery += " E1_NUMBOR BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += "	AND D_E_L_E_T_ = '' "
	cQuery += "	ORDER BY E1_PREFIXO,E1_NUM,E1_PORTADO,E1_CONTA   " 
	
	conout(cQuery)
	If Select("XAG0041") <> 0
		dbSelectArea("XAG0041")
		XAG0041->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS "XAG0041"  
	TCSetField("XAG0041", "E1_SALDO", "N", 14, 2)
	
	XAG0041->(DbGotop())     
	
	If XAG0041->(!eof())
		Processa({|lEnd| GeraCSV()})
	Else
		alert('Não há dados com os parâmetros informados!')
    Endif

Return


Static Function GeraCSV()
      
    Local cMSgRel      := ""  
	Local lPrimeiro    := .T. 
	Local nQtdReg      := 0 
	  
    //DbSelectArea('AGR095R')
   	Count To nQtdReg
   	XAG0041->(dbgotop())  
	
	ProcRegua(nQtdReg)

    //Varre a query
	While XAG0041->(!eof()) 
	    
		If lEnd
		   Return
		Endif
	      
		cMsgInc := " >>> Imprimindo Registro "+alltrim(XAG0041->E1_NUM)+" ..."
		Incproc(cMsgInc)	      
	  	
	  	//se for Primeiro registro Gera Cabeçalho
	  	If lPrimeiro
			  cMSgRel += 'Filial Orig. ;'
	  	      cMSgRel += 'Data Bordero ;'
	  	      cMSgRel += 'Bordero ;'
	  	      cMSgRel += 'Portador ;'  
	  	      cMSgRel += 'Conta ;' 
		      cMSgRel += 'Prefixo ;'
		      cMSgRel += 'Numero ; '
		      cMSgRel += 'Cliente; '
		      cMSgRel += 'Loja.; '
		      cMSgRel += 'Nome Cliente; ' 
		      cMSgRel += 'Parcela; '
		      cMSgRel += 'Saldo; '     
		      cMSgRel += 'Nosso Numero; '
		      cMSgRel += 'Agencia; '
		      cMSgRel += 'Tipo ' +chr(13)
	  	   
	  		lPrimeiro := .F.
	  	Endif  

   		//F2_FILIAL,F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,E1_XMAILBO
   	   	cMSgRel += "'"+XAG0041->E1_FILORIG+"'"+";" 
       	cMSgRel += "'"+DTOC(STOD(XAG0041->E1_DATABOR))+"'"+";"  
       	cMSgRel += "'"+alltrim(XAG0041->E1_NUMBOR)+"'"+";"//'Banco ;'
	  	cMSgRel += "'"+alltrim(XAG0041->E1_PORTADO)+"'"+";"//'Agencia ;'  
	  	cMSgRel += "'"+alltrim(XAG0041->E1_CONTA)+"'"+";"//'Conta ;' 
      	cMSgRel += "'"+alltrim(XAG0041->E1_PREFIXO)+"'"+";"
      	cMSgRel += "'"+XAG0041->E1_NUM+"'"+";"
      	cMSgRel += "'"+XAG0041->E1_CLIENTE+"'"+";"
      	cMSgRel += "'"+XAG0041->E1_LOJA+"'"+";"
      	cMSgRel += "'"+XAG0041->E1_NOMCLI+"';"  
      	cMSgRel += "'"+XAG0041->E1_PARCELA+"';"  
      	cMSgRel += ""+TRANSFORM(XAG0041->E1_SALDO, '@E 9,999,999.99') +";"  //TRANSFORM(XAG0041->E1_SALDO, "@E 999.999.999,99") +";"          	
      	cMSgRel += "'"+XAG0041->E1_NUMBCO+"';"
      	cMSgRel += "'"+alltrim(XAG0041->E1_AGEDEP)+"';" 
      	cMSgRel += "'"+alltrim(XAG0041->E1_TIPO)+"'" 	+chr(13) 
    
    	XAG0041->(dbskip())  	
    
    Enddo
	
	cArq := 'XAG0041'+dtos(ddatabase)+''+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+'.csv'
		
	//Grava Arquivo
	MEMOWRITE(cArq,cMSgRel)
	
	Incproc('Salvando Arquivo ...') 
	    
	If !ApOleClient("MsExcel")                     	
	 	MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
		Return	
	EndIf
		
	//Copia para temp e Abre no Excel
	__CopyFIle(cArq , AllTrim(GetTempPath())+cArq)             
		
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cArq)//cArqTrbex+".XLS")
	oExcelApp:SetVisible(.T.)                       
				                 
	fErase(cArq) //Deletando arquivo de trabalho	

Return


Return
