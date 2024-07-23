#include 'topconn.ch'  
#include 'protheus.ch'


//Spiller - Baixa arquivos da Raizen
User Function F110FIL() 

	Local _cfiltro := ""        
   	Local lretArq     := .F.
    Local _aRetParam  := {}
    Local _aParamBox  := {}                                             
    Local _cmv_par01   := mv_par01
  	Private aCab 		  := {}
	Private aItem		  := {}
	Private cNumPedcom  := ''
	Private cCondPgto   := ''
	Private cItem       := '0001'
	Private nOpc        := 3
	Private lMsErroAuto := .F. 
	Private _CPERG 	  := "AGX444IM"    
	Private aDados 	  := {}
	Private aItens    := {} 
	Private cArqIMP   := ""  
    Public _xf110jur  := .F.
    
	//pergunta se Soma Juros no Total da Baixa
	//If cEmpAnt == '20' .AND. (alltrim(FUNNAME())  <> 'AGX444')
 
       // Exibe tela de parametros      2                     3             4             5    6    7 
       /*01*/Aadd(_aParamBox,{4,"Calcula Juros ?"		, .T. 	, "S=Sim;N=Não" ,     10, '.F.',.F.})                                    

       IF !ParamBox(_aParamBox,"Informe os Parametros",@_aRetParam) 
          Return
       Endif

       _xf110jur:= mv_par01

       mv_par01:= _cmv_par01
    
    //Endif

	//Se For Empresa 01, Pergunta se é um arquivo raizen e Filtra dados  
	If cEmpAnt == '01' .AND. (alltrim(FUNNAME())  <> 'AGX444')
		IF MsgYesNo(" Deseja importar um Arquivo Raizen? ")
		
			PutSx1(_cPerg,"01","Arquivo     "	,"","","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{'Informe o Arquivo a ser Importado!'},{},{})
			
			If !(Pergunte(_CPERG))
			   	//Retorna pergunte da Tela Inicial 
		    	pergunte("FIN110",.F.) 
		    	_cfiltro := "E1_NUM  = ''"
			    Return _cfiltro
			Endif          
			 
			//Valida Arquivo
			If Alltrim(MV_PAR01) == ''
		   	    MSGINFO("  Selecione o arquivo!","Inválido")
		   	    //Retorna pergunte da Tela Inicial 
		    	pergunte("FIN110",.F.)    
		    	_cfiltro := "E1_NUM  = ''"
		   	    Return  _cfiltro                 
		 	Else
		  		cArqIMP := Alltrim(MV_PAR01)
		  	Endif   
		   
		   	//Retorna pergunte da Tela Inicial 
		    pergunte("FIN110",.F.)
		    
		    If !('.csv' $ Alltrim(cArqIMP))
		 		MSGINFO("O arquivo deve estar no formato .CSV!","Inválido") 
		 		_cfiltro := "E1_NUM  = ''"
		    	Return _cfiltro
		   	Endif
		       
		   Processa( {|| lretArq := GrvSE1() })   
		   
		   _cfiltro :=  " E1_XDTIMP  <> '' "/*' .And.*/ //' !(Empty(E1_XDTIMP))'
		    
		   //If lretArq
		   //	u_AGX444AAA('SE1',SE1->(recno()),3,.T.)      
		  // Endif   
		
		Endif      
	Endif 
	       
Return _cfiltro 
   
        

//Lê arquivo e grava SE1
Static Function GrvSE1()  

	Private nposCli    := 0 
    Private nposLoja   := 0
    Private nposLote   := 0
    Private nposPref   := 0
    Private nposNum    := 0
    Private nposParc   := 0
    //Local nposDtEmis := 0
    Private nposSitua  := 0
    Private nposValor  := 0
    Private nposValPG  := 0
    Private nposSitua  := 0
    Private nposStatus := 0 
    Private nPosSaldo  := 0 
    Private nLin       := 0
    Private aMsgErro   := {} 
    Private cMsgErro   := ""
       
	nHandle := FT_FUSE(cArqIMP)
    
    If nHandle < 0
    	MSGINFO("Arquivo vazio ou inválido!","Inválido")
    	Return
    Endif
    
    //Leandro Spiller - 25/09/2017
    //Limpa Data de Importação
    cQryUPd := " UPDATE "+Retsqlname('SE1')+" SET E1_XDTIMP = '' "
    cQryUPd += " WHERE E1_BAIXA = '' AND E1_XDTIMP <> ''"
    cQryUPd += " AND D_E_L_E_T_ = ''"
    If (TCSQLExec(cQryUPd) < 0)
		Conout("Falha ao executar SQL: " + cQryUPd)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf

    ProcRegua((FT_FLASTREC()*2))

    //FT_FGOTOP()

    While !FT_FEOF()
         
      	nLin++
      	
        IncProc("Lendo arquivo...")
     
        cLinha := FT_FREADLN()
                       
        AADD(aDados,Separa(cLinha,";",.T.))
        
        //Lê cabeçalho
     	If nLin == 1
   			nposCli    := aScan(aDados[nLin],"Cod Cliente")
		    nposLoja   := aScan(aDados[nLin],"Loja")
		    nposLote   := aScan(aDados[nLin],"Lote")
		    nposPref   := aScan(aDados[nLin],"Prefixo")
		    nposNum    := aScan(aDados[nLin],"Numero")
		    nposParc   := aScan(aDados[nLin],"Parcela")
		    //nposDtEmis := aScan(aDados,{|x| Alltrim(x[1])=="Data Emissão"})
		    nposSitua  := aScan(aDados[nLin],"Situacao Titulo")
		    nposValor  := aScan(aDados[nLin],"Vlr. Titulo")
		    nposValPG  := aScan(aDados[nLin],"Valor Pago")
		    nposSitua  := aScan(aDados[nLin],"Situacao Titulo")
		    nposStatus := aScan(aDados[nLin],"Status Pagto") 
		  	nPosSaldo  := aScan(aDados[nLin],"Saldo") 
		  	          
		    //Valida se leu todos as colunas do cabeçalho
		    If nposCli== 0 .and. nposLoja== 0 .and. nposLote== 0 .and. nposPref== 0 .and. nposNum== 0 .and. nposParc== 0 .and.;
		     nposSitua== 0 .and. nposValor== 0 .and. nposValPG== 0 .and. nposSitua== 0 .and. nposStatus== 0 
		    	alert(' Não foi possível ler campo da planilha, Verifique o arquivo!  ')
		    	 FT_FUSE()
                Return .F.
       		Endif
       	
       	Endif
     	
     	FT_FSKIP()

    EndDo          
    
    FT_FUSE()         
        
    //Se não há dados Retorna        
    If Len(aDados) == 0 
    	Alert('Não foram encontrados dados no arquivo! ')
   		Return .F.
   	Endif	

	nTamCli  := TAMSX3('E1_CLIENTE')[1]
    nTamLoja := TAMSX3('E1_LOJA')[1]
    nTamPref := TAMSX3('E1_PREFIXO')[1]
    nTamNum  := TAMSX3('E1_NUM')[1]
                                                  
	For i := 2 to len(aDados) 
	    IncProc("Gravando dados...")
		//Busca título para efeturar a baixa
		If alltrim(aDados[i][nposNum]) <> ''
		     
			//Se foi pago valor integral
			//já grava senão verifica se nao foi pago por lote ou a menos
			If StrtoVal(aDados[i][nPosSaldo]) == 0  
				DbSelectarea('SE1')
				DbSetOrder(1)//DbSetOrder(2) 
				         //FILIAL + CLIENTE + LOJA + PREFIXO + NUMERO
				If DbSeek(xFilial('SE1')+;		//PADR(aDados[i][nposCli],nTamCli,'')+;	PADR(aDados[i][nposLoja],nTamLoja,'')+;
					PADL(aDados[i][nposPref],nTamPref,'0')+;
			   		PADL(aDados[i][nposNum],nTamNum,'0'))
			   		If !(EMPTY(SE1->E1_BAIXA))
			   			AADD(aMsgErro,{' Título já baixado: ',aDados[i][nposPref]+aDados[i][nposNum]+' R$ '+alltrim(str(SE1->E1_VALOR))})
			   		Endif
			   					   		
	               Reclock('SE1',.F.)
	                  SE1->E1_XDTIMP := dDataBase
	               SE1->(MsUnlock())  
		    	Else
		    		AADD(aMsgErro,{' Título não encontrado: ',aDados[i][nposPref]+aDados[i][nposNum]}) 
		    	Endif  
		    
		    Else   
		    
		    	//Verifica lotes e Só grava se foi pago o valor integral
		    	//Retorna na linha que parou a verificação  
		    	If alltrim(aDados[i][nposLote]) <> ""
		    		i := GrvLote(i) 
		    	Else                                     
		    
		    	   //Se o saldo For menor  que R$1,00, baixa senão Gera Log
		    	   If ABS(VAL(aDados[i][nPosSaldo])) < 1 //If StrtoVal(aDados[i][nPosSaldo]) > 1 
		    		
			    		DbSelectarea('SE1')
				  		DbSetOrder(1)
					         						//FILIAL + CLIENTE + LOJA + PREFIXO + NUMERO
				 		If DbSeek(xFilial('SE1')+;		//PADR(aDados[i][nposCli],nTamCli,'')+;	PADR(aDados[i][nposLoja],nTamLoja,'')+;
					  							PADL(aDados[i][nposPref],nTamPref,'0')+;
					   							PADL(aDados[i][nposNum],nTamNum,'0'))
				   			If !(EMPTY(SE1->E1_BAIXA))
				   				AADD(aMsgErro,{' Título já baixado: ',aDados[i][nposPref]+aDados[i][nposNum]+' R$ '+alltrim(str(SE1->E1_VALOR))})
				   			Endif
				   					   		
		                    Reclock('SE1',.F.)
		               	      SE1->E1_XDTIMP := dDataBase
		            	    SE1->(MsUnlock())  
			      		Else
			    			AADD(aMsgErro,{' Título não encontrado: ',aDados[i][nposPref]+aDados[i][nposNum]}) 
			       		Endif      
			       Else
			       		AADD(aMsgErro,{' Divergência Valor do Título: ', aDados[i][nposPref]+aDados[i][nposNum]+' ->'+aDados[i][nPosSaldo] })
			       Endif
		    	
		    	Endif 
		    Endif               	
		Endif    

	Next i 
	
	//Mostra Msg de erro
	If Len(aMsgErro) > 0  
		For i := 1 to len(aMsgErro) 
			cMsgErro += aMsgErro[i][1]+aMsgErro[i][2]+chr(13)
		Next i    
		_cArquivo := StrTran( alltrim(cArqIMP),".csv", "_LOG.txt" )
		//_cArquivo := alltrim(MV_PAR01)+'_LOG.TXT'    
		MemoWrite(_cArquivo, cMsgErro ) 
	    alert(' Arquivo importado com divergências, Verifique: '+chr(13)+_cArquivo)
    Else
    	MSGINFO("  Arquivo importado com Sucessso!  ","Importado")
	Endif


Return  .T.
          
         
//Verifica e grava pagamentos por LOTE
Static function GrvLote(_i)
     
  Local nSomaPago := 0  
  Local nSomaVal  := 0     
                           
  //Captura o lote corrente
  cNumLote := aDados[_i][nposLote]  
  
  //Varre arquivo e valida se pagou todos os títulos
  For x := _i to len(aDados)  
      if alltrim(cNumLote) ==  alltrim(aDados[x][nposLote])
      	 nSomaVal  += StrtoVal(aDados[x][nposValor])
      	 nSomaPago += StrtoVal(aDados[x][nposValPG])
      Else 
      	 x--
         EXIT
      Endif 
  Next x
  
  nDiferenca := 0            
  If nSomaVal > nSomaPago   
  	nDiferenca := (nSomaVal - nSomaPago)
  Elseif  nSomaVal < nSomaPago      
  	nDiferenca :=  (nSomaPago - nSomaVal)     
  Endif
                                       
  // A pedido do Fernando foi colocado uma Margem de R$1,00 
  // para divergencias dee valores para importação.
  If nDiferenca > 1 
  	 AADD(aMsgErro,{' Divergência Valor Pago, Lote: ', cNumLote+' - '+alltrim(str(nSomaVal))+' -> '+alltrim(str(nSomaPago))})
  Else  
  	 //Varre da numeração inicial até final do lote
  	 For y := _i to x
	  	 DbSelectarea('SE1')
		 DbSetOrder(1)//DbSetOrder(2) 
		 			//FILIAL + CLIENTE + LOJA + PREFIXO + NUMERO
		 If DbSeek(xFilial('SE1')+;//	PADR(aDados[y][nposCli],nTamCli,'')+;	PADR(aDados[y][nposLoja],nTamLoja,'')+;
						PADL(aDados[y][nposPref],nTamPref,'0')+;
				   		PADL(aDados[y][nposNum],nTamNum,'0'))  
				   		
				If !(EMPTY(SE1->E1_BAIXA))
			   			AADD(aMsgErro,{' Título já baixado: ',aDados[Y][nposPref]+aDados[Y][nposNum]+' R$ '+alltrim(str(SE1->E1_VALOR))})
			   	Endif
			   	
				Reclock('SE1',.F.)
		   	   		 SE1->E1_XDTIMP := dDataBase
		   	 	SE1->(MsUnlock())  		    
	  	 Else
		
		   		AADD(aMsgErro,{' Título não encontrado: ',aDados[y][nposPref]+aDados[y][nposNum]}) 
		 Endif
	 Next y  
  Endif
  
Return x
    
//Transforma String em Valor
Static function StrtoVal(xValor) 
	
	Local nRetVal := 0                                                  
                                                  

	nRetVal := Val(Strtran(;
	               Strtran(;
	               Strtran(StrTran( xValor,".", "" );
	               ,"R$", "" );
	               ,',','.');
	               ,' ','')) 

Return nRetVal