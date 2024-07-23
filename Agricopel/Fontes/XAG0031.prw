#include 'protheus.ch'
#include 'topconn.ch'
#include "AP5MAIL.CH" 
#include "TBICONN.CH"
                                    
/*{Protheus.doc} XAG0031
//Chamado 67619 - Criação Geração e envio automático de E-mail para Nyke
@author Spiller
@since 16/05/2018
@version undefined
@param empresa
@type function */
              
User function XAG0031()

	Local nCountDe   := 0
	Local nCountPara := 0

    Private nEmpDe    
 	Private cMail	  := ''    
	Private cFrom 	  := ''
	Private cCartei   := ""
	Private aEmpresas := {}
	Private cAliasTrb := "TRB"

	cUsername := 'MICROSIGA'//Cria como usuário microsiga para o controle de semaforo
	aEmpDePara := U_AGX635EM()
	
	For nCountDe := Len(aEmpDePara)  To 1  STEP -1

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]

		For nCountPara := Len(aEmpPara) To 1  STEP -1

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3] 
				nFilde       := aEmpPara[nCountPara][1] 
                
                //Somente gerado para empresa 01
                If cEmpPara == '01'
			   	
				   	PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5"
				
				    RPCSetType(3)
				    RPCSetEnv(cEmpPara, cFilialPara)
				    cUsername := 'MICROSIGA'//Cria como usuário microsiga para o controle de semaforo
				    cFilAnt := cFilialPara
				    cEmpant := cEmpPara 
					conout('XAG0031 - inicio')
				    //dDatabase := stod('20180514')	//AQUI 
					//Carrega parâmetros da Rotina de Geração de Boletos                
				    PerAGR95A()
				    
				    conout('*** XAG0031 '+cEmpant+' - '+cFilAnt +' ' + dtoc(date()) +' -> '+ time())
				 
				    //Seta Conta do projeto Nyke   
				    mv_par01 := '   '//xSerie	//Serie De          
					mv_par02 := 'ZZZ'//xSerie	//Serie Ate         
					mv_par03 := '         '//xDoc	//Nota De           
					mv_par04 := 'ZZZZZZZZZ'//xDoc	//Nota Ate          
					mv_par05 := stod('20180528')//Emissao De  //Data de Inicio da Rotina de Geração      
					mv_par06 := stod('21990101')//Emissao Ate       
					mv_par07 := '      '//xCliente	//Cliente De        
					mv_par08 := 'ZZZZZZ'//xCliente	//Cliente Ate       
					mv_par09 := '  '//xLoja		//Loja De           
					mv_par10 := 'ZZ'//xLoja  		//Loja Ate          
					mv_par11 := 7 			//% de JUROS ao Mês 
					mv_par12 := 0 			//% de Multa        
					mv_par13 := '237'        //Banco             
					mv_par14 := '02693'      //Agencia   	      
					mv_par15 := '00277207  ' //Conta             
					mv_par16 := '001'  		 //Sub-Conta         
					mv_par17 := '09'         //Carteira 
					mv_par18 := 1  
					
					Dbselectarea('SA6')
				    DbSetorder(1)
				    dbSeek(xFilial("SA6")+mv_par13+mv_par14+mv_par15)
				    
				    //Gera query com os Boleto a Ser gerado
				    cQuery := ""
					cQuery := " SELECT F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,A1_CGC AS CNPJ, F2_PREFIXO  AS PREFIXO"
					cQuery += " FROM " + RetSqlName("SF2") + " (NOLOCK) F2 " 
					cQuery += " INNER JOIN " + RetSqlName("SA1") +" (NOLOCK) A1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = '' AND "  
					cQuery += " A1_FILIAL = '"+xFilial('SA1')+"' "
					//Spiller - Trava para nao mostrar Títulos de outros portadores
					cQuery += " LEFT JOIN " + RetSqlName("SE1") + " (NOLOCK) E1 ON E1_FILIAL = '' AND "
					cQuery += "						E1_CLIENTE = F2_CLIENTE AND "
					cQuery += "						E1_LOJA   = F2_LOJA AND "
					cQuery += "						E1_PREFIXO = F2_PREFIXO AND "
					cQuery += "						E1_NUM = F2_DOC AND "
					cQuery += "					 	E1.D_E_L_E_T_ = '' AND E1_TIPO <> 'FT' AND E1_EMISSAO >= '"+DTOS(mv_par05)+"'" //Evita erro quando for gerado fatura de boleto nyke 
					//Fim
					cQuery += "WHERE F2.D_E_L_E_T_ <> '*' "
					cQuery += "AND F2_FILIAL   = '" + xFilial("SF2") + "' " 
					cQuery += "AND F2_EMISSAO >= '" + DTOS(mv_par05) + "' "
					cQuery += "AND F2_EMISSAO <= '" + DTOS(mv_par06) + "' "
					cQuery += "AND F2_SERIE   >= '" + mv_par01 + "' "
					cQuery += "AND F2_SERIE   <= '" + mv_par02 + "' "
					cQuery += "AND F2_DOC 	  >= '" + mv_par03 + "' "
					cQuery += "AND F2_DOC 	  <= '" + mv_par04 + "' "
					cQuery += "AND F2_CLIENTE >= '" + mv_par07 + "' "
					cQuery += "AND F2_CLIENTE <= '" + mv_par08 + "' "
					cQuery += "AND F2_LOJA 	  >= '" + mv_par09 + "' "
					cQuery += "AND F2_LOJA 	  <= '" + mv_par10 + "' " 
					cQuery += "AND F2_XPROJ    = '2' " //Determina que é projeto nyke  
					cQuery += "AND E1_NUMBCO   = '' " //Determina que ainda não foi gerado boleto
					cQuery += "AND F2_ORIIMP LIKE 'AGX635CS' "//Adequado trecho pois DBGInt sempre grava 001     
					
					//Spiller - Trava para nao mostrar Títulos de outros portadores
					cQuery += "AND (E1_PORTADO =  '"+mv_par13+"' OR E1_PORTADO = '' ) " 
					cQuery += "AND E1_SALDO > 0 AND E1_XMAILBO = '' " 
					cQuery += "GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, A1_NOME, A1_CGC, F2_PREFIXO "
					//Fim
					cQuery += "ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME, A1_CGC "
					//conout(cQuery)
					//Conout(cAliasTrb)
					
					If Select(cAliasTrb) <> 0
						dbSelectArea(cAliasTrb)
						dbCloseArea()
					Endif

					cAliasTrb := MpSysOpenQuery(cQuery)
					TCSetField(cAliasTrb,"EMISSAO","D",08,0)
					
					(cAliasTrb)->(dbgotop())     
					//conout('XAG0031 - 105')
					//Função de Envio de Email.  
					If (cAliasTrb)->(!eof())   
						conout('XAG0031 - enviando')  
						//cMailNyke := EMailNyke(nEmpDe,TRB->CNPJ)
						cFrom     := 'frete.nyke@agricopel.com.br'   
						//Cria as conexoes
						U_AGX635CN("DBG")
						U_AGX635CN("PRT") 
						//If cFilAnt <> '02'
				   			U_A095Mail(.T.,cFrom) //(Automático,E-mail from)
				    	//Endif
				    Else
				    	conout('XAG0031 - Nenhum Titulo encontrado!')
				    Endif     
				    
				 	RPCClearEnv()
					dbCloseAll()
				 	RESET ENVIRONMENT 
				
				Endif
				
		Next nCountPara
           
  		//FErase(cArqTmp + GetDbExtension())
		//FErase(cArqTmp + OrdBagExt())
	
	Next nCountDe 
	
	//startjob("U_XAG0031",getenvserver(),.T.,'01','05','000013412','2','04722 ','01', 'leandro.h@agricopel.com.br','frete.nyke@agricopel.com.br')
	//U_XAG0031('01','05','000013412','2','04722 ','01', 'leandro.h@agricopel.com.br','frete.nyke@agricopel.com.br')
	//U_XAG0031('01','01','000067050','4','00368 ','35', 'leandrohey@gmail.com','frete.nyke@agricopel.com.br') 
	
Return     


/*Static Function EMailNyke(xEmpDe,xCnpj)//(xCodEmp,xEntDes,xEndDes)
            
	Local cQuery   := ""
	Local cMailRet := "" 
	Local cMaiNFE  := "" 
	Default xEmpDe := ""
	Default xCnpj  := ""
	  
	//conout('EMailNyke')
	//conout(xEmpDe)
	//conout(xCnpj)
	U_AGX635CN("DBG")
	cQuery  := " SELECT GEN_ENDENT_EmailNFe,GEN_TABENT_Codigo,GEN_ENDENT_Codigo,GEN_ENDENT_EmailNFe AS EMAIL FROM GEN_ENDENT "
	cQuery  += " WHERE GEN_ENDENT_IF = '"+xCnpj+"' " 
	//CONOUT(cQuery)
	If Select("EMailNyke") <> 0
  		dbSelectArea("EMailNyke")
   		EMailNyke->(dbCloseArea())
  	Endif
	TCQuery cQuery NEW ALIAS ("EMailNyke") 
	     
	EMailNyke->(dbgotop())  
	If EMailNyke->(!eof())
		cMaiNFE := EMailNyke->EMAIL
	Endif   
	
	cQuery  := " SELECT CTE_CLINYK_EmailBoleto as EMAIL " 
	cQuery  += " FROM CTE_CLINYK  "
	cQuery  += " WHERE STG_GEN_TABEMP_CTe_Codigo = '"+alltrim(str(xEmpDe))+"' AND "
	cQuery  += " STG_GEN_TABENT_NYK_Codigo ='"+alltrim(str(EMailNyke->GEN_TABENT_Codigo))+"' AND "
	cQuery  += " STG_GEN_ENDENT_NYK_Codigo ='"+alltrim(str(EMailNyke->GEN_ENDENT_Codigo)) +"' "
	If Select("EMailNyke") <> 0
  		dbSelectArea("EMailNyke")
   		EMailNyke->(dbCloseArea())
  	Endif
    //CONOUT(cQuery)
 	TCQuery cQuery NEW ALIAS ("EMailNyke") 
	     
	EMailNyke->(dbgotop())
	If EMailNyke->(!eof())
		cMailRet := EMailNyke->EMAIL
	Endif   
	 
	//Se não achar no E-mail específico, Pega da Tabela de Clientes
	If alltrim(cMailRet) == ''
		cMailRet := cMaiNFE
	Endif     
	
	//Conout('AGX635CS - E-MAIL NYKE: '+cMailRet) 
	
	U_AGX635CN("PRT")

Return cMailRet
*/

User function XAG0031B(xEmp,xFil,xDoc,xSerie,xCliente,xLoja,xMail,xFrom)   
          //U_XAG0031('01','01','000067050','4','00368 ','35', 'leandrohey@gmail.com','frete.nyke@agricopel.com.br')
          //U_XAG0031('01','01','000067050','4','00368 ','35',     ,'frete.nyke@agricopel.com.br')   
          //U_XAG0031('01','05','000013412','2','04722 ','01', 'leandro.h@agricopel.com.br','frete.nyke@agricopel.com.br')
 	Default xEmp  	  := ''
	Default xFil	  := ''
	Default xDoc	  := ''
	Default xSerie	  := ''
	Default xCliente  := ''
	Default xLoja	  := ''
	Default xMail	  := ''    
	Default xFrom 	  := ''
	Private cCartei   := ""
	//Private cMailDB  := ""  

   	PREPARE ENVIRONMENT Empresa xEmp Filial xFil Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5"

    RPCSetType(3)
    RPCSetEnv(xEmp, xFil) 
	conout('XAG0031 - inicio')
    //dDatabase := stod('20180514')	//AQUI 
	//Carrega parâmetros da Rotina de Geração de Boletos                
    Pergunte("AGR95A",.F.)                              
    
    //Seta Conta do projeto Nyke   
    mv_par01 := xSerie	//Serie De          
	mv_par02 := xSerie	//Serie Ate         
	mv_par03 := xDoc	//Nota De           
	mv_par04 := xDoc	//Nota Ate          
	mv_par05 := stod('20180401')//Emissao De        
	mv_par06 := stod('21990101')//Emissao Ate       
	mv_par07 := xCliente	//Cliente De        
	mv_par08 := xCliente	//Cliente Ate       
	mv_par09 := xLoja		//Loja De           
	mv_par10 := xLoja  		//Loja Ate          
	mv_par11 := 7 			//% de JUROS ao Mês 
	mv_par12 := 0 			//% de Multa        
	mv_par13 := '237'        //Banco             
	mv_par14 := '02693'      //Agencia   	      
	mv_par15 := '00277207  ' //Conta             
	mv_par16 := '001'  		 //Sub-Conta         
	mv_par17 := '09'         //Carteira   
	mv_par18 := 1
	
	Dbselectarea('SA6')
    DbSetorder(1)
    dbSeek(xFilial("SA6")+mv_par13+mv_par14+mv_par15)
    
    //Gera query com os Boleto a Ser gerado
    cQuery := ""
	cQuery := "SELECT F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI "
	cQuery += "FROM " + RetSqlName("SF2") + " (NOLOCK) F2 " 
	cQuery += " INNER JOIN " + RetSqlName("SA1") +" (NOLOCK) A1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = '' AND "  
	cQuery += " A1_FILIAL = '"+xFilial('SA1')+"' "
	//Spiller - Trava para nao mostrar Títulos de outros portadores
	cQuery += " LEFT JOIN " + RetSqlName("SE1") + " (NOLOCK) E1 ON E1_FILIAL = '' AND "
	cQuery += "						E1_CLIENTE = F2_CLIENTE AND "
	cQuery += "						E1_LOJA   = F2_LOJA AND "
	cQuery += "						E1_PREFIXO = F2_PREFIXO AND "
	cQuery += "						E1_NUM = F2_DOC AND "
	cQuery += "					 	E1.D_E_L_E_T_ = '' "  
	//Fim
	cQuery += "WHERE F2.D_E_L_E_T_ <> '*' "
	cQuery += "AND F2_FILIAL   = '" + xFilial("SF2") + "' "
	cQuery += "AND F2_EMISSAO >= '" + DTOS(mv_par05) + "' "
	cQuery += "AND F2_EMISSAO <= '" + DTOS(mv_par06) + "' "
	cQuery += "AND F2_SERIE   >= '" + mv_par01 + "' "
	cQuery += "AND F2_SERIE   <= '" + mv_par02 + "' "
	cQuery += "AND F2_DOC 	  >= '" + mv_par03 + "' "
	cQuery += "AND F2_DOC 	  <= '" + mv_par04 + "' "
	cQuery += "AND F2_CLIENTE >= '" + mv_par07 + "' "
	cQuery += "AND F2_CLIENTE <= '" + mv_par08 + "' "
	cQuery += "AND F2_LOJA 	  >= '" + mv_par09 + "' "
	cQuery += "AND F2_LOJA 	  <= '" + mv_par10 + "' "
	cQuery += "AND (F2_COND <> '001' OR F2_ORIIMP LIKE 'AGX635CS'  ) "//Adequado trecho pois DBGInt sempre grava 001     
	
	//Spiller - Trava para nao mostrar Títulos de outros portadores
	cQuery += "AND (E1_PORTADO =  '"+mv_par13+"' OR E1_PORTADO = '' )" 
	cQuery += "GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, A1_NOME "
	//Fim
	cQuery += "ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME "
	conout(cQuery)
	//cQuery := ChangeQuery(cQuery)
	If Select(cAliasTrb) <> 0
		dbSelectArea(cAliasTrb)
		dbCloseArea()
	Endif
	//TCQuery cQuery NEW ALIAS cAliasTrb
	cAliasTrb := MpSysOpenQuery(cQuery)
	TCSetField(cAliasTrb,"EMISSAO","D",08,0)  
	
	(cAliasTrb)->(dbgotop())     
	//conout('XAG0031 - 105')
	//Função de Envio de Email.  
	If (cAliasTrb)->(!eof())   
		//conout('XAG0031 - 107')
   		U_A095Mail(.T.,xFrom) //(Automático,E-mail para Receber,E-mail from)
    Else
    	conout('XAG0031 - Nenhum Titulo encontrado!')
    Endif     
    
 	RPCClearEnv()
	dbCloseAll()
 	RESET ENVIRONMENT
    
Return

//Relatório de Boletos Nyke
User function XAG0031R()   
     
	Local cQuery := ""
	Local cPerg := "XAG0031R"  
	       
	If !Pergunte(cPerg,.T.)
		Return 
    Endif
    
 	//Gera query com os Boleto a Ser gerado
    cQuery := ""
	cQuery := "SELECT F2_FILIAL,F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,E1_XMAILBO,"
	cQuery += " E1_AGEDEP AS AGENCIA, E1_CONTA AS CONTA, E1_NUMBCO AS NOSSONUM "
	cQuery += "FROM " + RetSqlName("SF2") + " (NOLOCK) F2" 	
	cQuery += " INNER JOIN " + RetSqlName("SA1") +" (NOLOCK) A1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = '' AND"  
	cQuery += " A1_FILIAL = '"+xFilial('SA1')+"' "
	//Spiller - Trava para nao mostrar Títulos de outros portadores
	cQuery += " LEFT JOIN " + RetSqlName("SE1") + " (NOLOCK) E1 ON E1_FILIAL = '' AND "
	cQuery += "						E1_CLIENTE = F2_CLIENTE AND "
	cQuery += "						E1_LOJA   = F2_LOJA AND "
	cQuery += "						E1_PREFIXO = F2_PREFIXO AND "
	cQuery += "						E1_NUM = F2_DOC AND "
	cQuery += "					 	E1.D_E_L_E_T_ = '' "  
	//Fim
	cQuery += "WHERE F2.D_E_L_E_T_ <> '*' "
	cQuery += "AND F2_FILIAL  >= '" + mv_par01 + "' "
	cQuery += "AND F2_FILIAL  <= '" + mv_par02 + "' "
	cQuery += "AND F2_EMISSAO >= '" + dtos(mv_par03) + "' "
	cQuery += "AND F2_EMISSAO <= '" + dtos(mv_par04)  + "' "
	cQuery += "AND F2_SERIE   >= '" + mv_par05 + "' "
	cQuery += "AND F2_SERIE   <= '" + mv_par06 + "' "
	cQuery += "AND F2_DOC 	  >= '" + mv_par07 + "' "
	cQuery += "AND F2_DOC 	  <= '" + mv_par08 + "' "
	cQuery += "AND F2_CLIENTE >= '" + mv_par09 + "' "
	cQuery += "AND F2_CLIENTE <= '" + mv_par10 + "' "
	cQuery += "AND F2_LOJA 	  >= '" + mv_par11 + "' "
	cQuery += "AND F2_LOJA 	  <= '" + mv_par12 + "' "
	cQuery += "AND (F2_XPROJ = '2' AND F2_ORIIMP LIKE 'AGX635CS'  ) "//Adequado trecho pois DBGInt sempre grava 001     
	cQuery += "GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, A1_NOME,E1_XMAILBO,E1_AGEDEP, E1_CONTA,E1_NUMBCO"
	cQuery += "ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME,E1_XMAILBO "
	
	If Select("XAG0031R") <> 0
		dbSelectArea("XAG0031R")
		XAG0031R->(dbCloseArea())
	Endif
	
	TCQuery cQuery NEW ALIAS "XAG0031R"
	XAG0031R->(DbGotop())     
	
	If XAG0031R->(!eof())
		GeraCSV()
	Else
		alert('Não há dados com os parâmetros informados!')
    Endif

Return


Static Function GeraCSV()
      
    Local cMSgRel      := ""  
	Local lPrimeiro    := .T.

    //F2_FILIAL,F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,E1_XMAILBO

    //Varre a query
	While XAG0031R->(!eof()) 
	      
	  	//se for Primeiro registro Gera Cabeçalho
	  	If lPrimeiro 
	  	      cMSgRel += 'Filial ;'
		      cMSgRel += 'Documento ;'
		      cMSgRel += 'Serie ; '
		      cMSgRel += 'Cliente; '
		      cMSgRel += 'Loja.; '
		      cMSgRel += 'Emissao.; '
		      cMSgRel += 'Nome.Cliente; '
			  cMSgRel += 'Agencia; '
			  cMSgRel += 'Conta; '
			  cMSgRel += 'Nosso Num.; '		      
			  cMSgRel += 'E-Mail Enviado; ' +chr(13)
	  	   
	  		lPrimeiro := .F.
	  	Endif  

   		//F2_FILIAL,F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,E1_XMAILBO
       	cMSgRel += "'"+alltrim(XAG0031R->F2_FILIAL)+"'"+";"
      	cMSgRel += "'"+alltrim(XAG0031R->DOC)+"'"+";"
      	cMSgRel += "'"+XAG0031R->SERIE+"'"+";"
      	cMSgRel += "'"+XAG0031R->CLIENTE+"'"+";"
      	cMSgRel += "'"+XAG0031R->LOJA+"'"+";"
      	cMSgRel += DTOC(STOD(XAG0031R->EMISSAO))+";"
      	cMSgRel += XAG0031R->NOMECLI+";"
		cMSgRel += +"'"+XAG0031R->AGENCIA+"'"+";"
		cMSgRel += +"'"+XAG0031R->CONTA+"'"+";"
		cMSgRel += +"'"+XAG0031R->NOSSONUM+"'"+";"      	
		cMSgRel += alltrim(XAG0031R->E1_XMAILBO)+chr(13) 
    
    	XAG0031R->(dbskip())  	
    
    Enddo
	
	cArq := 'XAG0031R'+dtos(ddatabase)+''+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+'.csv'
		
	//Grava Arquivo
	MEMOWRITE(cArq,cMSgRel)
	      
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



//Utilizado para Testes de execução da Filial 02
User function XAG0031X()

	Local nCountDe   := 0
	Local nCountPara := 0

    Private nEmpDe    
 	Private cMail	  := ''    
	Private cFrom 	  := ''
	Private cCartei   := ""
	Private aEmpresas := {}

	aEmpDePara := U_AGX635EM()  
	
	For nCountDe := Len(aEmpDePara) To 1 STEP -1

		nEmpDe   := aEmpDePara[nCountDe][1]
		aEmpPara := aEmpDePara[nCountDe][2]
                                             

		For nCountPara := Len(aEmpPara)  To 1  STEP -1

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3] 
				nFilde       := aEmpPara[nCountPara][1] 
                conout('FORA '+ cEmpPara+cFilialPara)
                //Somente gerado para empresa 01
                If cEmpPara == '01' 
			   		conout('ENTROU '+ cEmpPara+cFilialPara)
				   	PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5"
				
				    RPCSetType(3)
				    RPCSetEnv(cEmpPara, cFilialPara)
				    
				    cFilAnt := cFilialPara
				    cEmpant := cEmpPara 

					//Cria as conexoes
					U_AGX635CN("DBG")
					cQuery  := " SELECT GEN_ENDENT_EmailNFe,GEN_TABENT_Codigo,GEN_ENDENT_Codigo,GEN_ENDENT_EmailNFe AS EMAIL FROM GEN_ENDENT "
					cQuery  += " WHERE GEN_ENDENT_IF = '999999999' "   
					
					//CONOUT(cQuery)
					If Select("EMailNyke") <> 0
				  		dbSelectArea("EMailNyke")
				   		EMailNyke->(dbCloseArea())
				  	Endif                     
				  	
				  	//Só executa TcQuery se O DBGINT consehuir conectar
				  	If (TCSQLExec(cQuery) < 0)
						CONOUT(cFilialPara+' XAG0031X - ERRO Execução query DBGINT '+cQuery )
					Else 
						CONOUT(cFilialPara+' XAG0031X - SUCESSO Execução query DBGINT '+cQuery ) 	
					EndIf
					
					U_AGX635CN("PRT") 
					
				 	RPCClearEnv()
					dbCloseAll()
				 	RESET ENVIRONMENT 
				
				Endif
				
		Next nCountPara
           
  
	Next nCountDe 
		
Return 

Static Function PerAGR95A()
	Pergunte("AGR95A",.F.)
Return()