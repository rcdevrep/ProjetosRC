#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} XAG0041
Fun��o para gera��o de Relatorio de Border� por dia
@author Leandro Spiller
@since 20/09/2018
@version 1.0
@return Nil, Fun��o n�o tem retorno
@example XAG0041()
/*/  
User Function XAG0041()  

	Local cQuery    := ""
	Local cPerg     := "XAG0041"   

	Private cArq      := ""
	Private nRetRadio := 0 

	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Emissao De        ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Emissao Ate       ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Bordero De        ?","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","bordero Ate       ?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	U_CriaPer(cPerg,aRegistros)
	       
	If !Pergunte(cPerg,.T.)
		Return 
    Endif
		
	nRetRadio := GetProg()
	
	If nRetRadio == 0 
		Return
	Endif 

	cQuery := ""	
	cQuery += "	SELECT E1_TIPO,E1_FILORIG, E1_PORTADO AS BANCO,E1_CONTA AS CONTA,E1_NUMBCO AS NN,* FROM "+RetSqlName('SE1')+ "(NOLOCK) "
	cQuery += "	WHERE E1_DATABOR  BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND "
	cQuery += " E1_NUMBOR BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += "	AND D_E_L_E_T_ = '' "
	cQuery += "	ORDER BY E1_DATABOR,E1_NUMBOR,E1_PORTADO,E1_CONTA,E1_PREFIXO,E1_NUM  " 
	
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
		alert('N�o h� dados com os par�metros informados!')
    Endif

Return


Static Function GeraCSV()
      
    Local cMSgRel       := ""  
	Local lPrimeiro     := .T. 
	Local nQtdReg       := 0 
	Local cBordero  	:= ""
	Local cChaveBor 	:= ""
	Local lIdVazio      := .F.
	Local lIdPreenc     := .F.
	Local cStatus       := ""
	  
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
	  	
	  	//se for Primeiro registro Gera Cabe�alho
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
		      cMSgRel += 'Tipo; ' 
			  cMSgRel += 'ID Cnab; '+chr(13)
			
			  cBordero += 'Bordero ;'
	  	      cBordero += 'Data Bordero ;'
			  cBordero += 'Conta ;'
			  cBordero += 'Portador ;'
			  cBordero += 'Remessa Gerada '+chr(13)  
	  	      
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
      	cMSgRel += "'"+alltrim(XAG0041->E1_TIPO)+"';" 	
		cMSgRel += "'"+alltrim(XAG0041->E1_IDCNAB)+"';"  +chr(13) 

		//Grava dados dos Border�s
		If cChaveBor <> alltrim(XAG0041->E1_NUMBOR)+DTOC(STOD(XAG0041->E1_DATABOR))+alltrim(XAG0041->E1_CONTA)+alltrim(XAG0041->E1_PORTADO)
			lIdVazio      := .F.
			lIdPreenc     := .F.			
			cBordero += alltrim(XAG0041->E1_NUMBOR)+';'
			cBordero += DTOC(STOD(XAG0041->E1_DATABOR))+';'
			cBordero += alltrim(XAG0041->E1_CONTA)+';'
			cBordero += alltrim(XAG0041->E1_PORTADO)+';'//+chr(13)  	

		Endif

		//Grava se tem IdCnab Preenchido
		If alltrim(XAG0041->E1_IDCNAB) == ''
			lIdVazio      := .T.
		Else
			lIdPreenc     := .T.
		Endif


		iF lIdVazio .and. !lIdPreenc //Todos vazios
			cStatus := "N�O"
		Elseif lIdVazio .AND. lIdPreenc//Vazios e preenchidos
			cStatus := "PARCIAL"
		Else //Todos Preenchidos
			cStatus := "TOTAL"
		Endif

		cChaveBor := alltrim(XAG0041->E1_NUMBOR)+DTOC(STOD(XAG0041->E1_DATABOR))+alltrim(XAG0041->E1_CONTA)+alltrim(XAG0041->E1_PORTADO)
    
    	XAG0041->(dbskip())  

		//Grava o Status do Envio do Border�
		If cChaveBor <> alltrim(XAG0041->E1_NUMBOR)+DTOC(STOD(XAG0041->E1_DATABOR))+alltrim(XAG0041->E1_CONTA)+alltrim(XAG0041->E1_PORTADO)
			cBordero += cStatus+chr(13) 
		Endif
    Enddo
		
	cArq := 'XAG0041'+dtos(ddatabase)+''+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+'.csv'

	//Grava Arquivo
	MEMOWRITE(cArq,cBordero+chr(13)+chr(13)+cMSgRel)
	
	Incproc('Salvando Arquivo ...') 
	Imprime(nRetRadio)
	    

Return


Static Function Imprime(xPrograma)

	Local  cDirTemp  := AllTrim(GetTempPath())

	//Copia para temp e Abre no Programa escolhido
	__CopyFIle(cArq , cDirTemp+cArq)             

	If xPrograma == 1	//Abre Excel
	
		If !ApOleClient("MsExcel")                     	
			MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
			Return	
		EndIf
			
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open(cDirTemp+cArq)//cArqTrbex+".XLS")
		oExcelApp:SetVisible(.T.)                       
	
		fErase(cArq) //Deletando arquivo de trabalho

	Elseif xPrograma == 2//Abre Calc 

	   	shellExecute( "Open", "C:\Program Files\LibreOffice\program\scalc.exe", cArq, cDirTemp, 1 )

	Endif 

Return 


Static Function GetProg()

	Local oDlg
	Local oButton1
	Local oRadMenu1
	Local nRadMenu1 := 1
	Local oSay1
	Local lConfirm := .F.

	DEFINE MSDIALOG oDlg TITLE "Abrir Com: " FROM 000, 000  TO 100, 200 COLORS 0, 16777215 PIXEL

		@ 012, 008 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Excel","Calc" SIZE 058, 020 OF oDlg COLOR 0, 16777215 PIXEL
		@ 034, 056 BUTTON oButton1 PROMPT "Confirmar" ACTION( lConfirm := .T.,oDlg:End())SIZE 037, 012 OF oDlg PIXEL
		@ 002, 007 SAY oSay1 PROMPT "Selecione: " SIZE 046, 007 OF oDlg COLORS 0, 16777215 PIXEL
		
	ACTIVATE MSDIALOG oDlg

	If !lConfirm
		nRadMenu1 := 0	
	Endif 

Return nRadMenu1
