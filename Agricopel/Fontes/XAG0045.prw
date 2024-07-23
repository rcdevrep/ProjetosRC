#include 'protheus.ch'
#include 'topconn.ch'
#include "AP5MAIL.CH" 
#include "TBICONN.CH"
                                    
/*{Protheus.doc} XAG0045
//Chamado 67619 - Criação Geração e envio automático de E-mail 
Envia E-mail para todas empresas, Exceto o que é projeto NYKE.
Configurações necessárias:
1) Tabela Empresas: 
 - BOLETO_AUTO = 'S' 
 - BOLETO_EMAIL preenchido
2) Programa XAG0045C(Dia da semana x banco para Faturamento)
Preencher dias da semana da Filial desejada, o programa 
atualiza o campo A6_XDIAFAT com o 'Numero' do dia da semana.
@author Spiller
@since 13/12/2018
@version undefined
@param xDatabase,xEmpresas,xGerManual, xDoc, xSerie, xAcao 
@type function */    
User function XAG0045(xDatabase,xEmpresas,xGerManual, xDoc, xSerie, xAcao )
     
	Default xDoc   := ''
	Default xSerie := '' 
	Default xAcao  := 'E'

	Local oXagCon := XagConexao():New()
	Local i       := 0

    Private nEmpDe    
 	Private cMail	   	:= ''    
	Private cFrom 	   	:= ''
	Private cCartei    	:= ""
	Private _aEmpresas  := {}
	Private cDiaSemana 	:= ''
	Private _aConta     := {} 
    Private cAliasTrb   := "TRB"	
	//Private _cRetorno   := "SUCESSO"

	Default xDatabase 	:= date()   
	Default xEmpresas   := {}
	Default xGerManual  := .F. //determina se é uma geração manual
		  
	 _cRetorno   := "SUCESSO"

	If len(xEmpresas) > 0 //xGerManual
	   _aEmpresas := xEmpresas 
	Else		
		cUsername := 'MICROSIGA'//Cria como usuário microsiga para o controle de semaforo                  
		oXagCon:ConecPRT()
	 	_aEmpresas := U_XAG0045A()//busca empresas que gerar boleto Auto 
	Endif         
      
  	//Varre empresas
  	For i := 1 to len(_aEmpresas)
  	                               
  		cEmpPara     := _aEmpresas[i][1]
		cFilialPara  := _aEmpresas[i][2]
  		cMail        := _aEmpresas[i][3]  
  		
  		CONOUT('_aEmpresas')
  	    CONOUT(cEmpPara)        
  	    CONOUT(cFilialPara)
  		CONOUT(cMail)
  		
  		//Se for uma geração manual, não usa prepare environment  
  		If !(xGerManual)                                                                                         
  	    	PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5"
  	    	
  	    	RPCSetType(3)
			RPCSetEnv(cEmpPara, cFilialPara)

		//RPCClearEnv()
		//RPCSetEnv(cEmpPara,cFilialPara,"USERREST","*R3st2021","","",{"SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5"})

  	    Endif

		cUsername := 'MICROSIGA'//Cria como usuário microsiga para o controle de semaforo
		cFilAnt := cFilialPara
		cEmpant := cEmpPara 
		conout('XAG0045 - inicio')
	    
		PerAGR95()
		conout('*** XAG0045 '+cEmpant+' - '+cFilAnt)
		
		cDiaSemana := alltrim(str(DOW(xDatabase))) 
		CONOUT('dia da Semana')   
		CONOUT(cDiaSemana)
		            
		//Busca a conta do dia
		_aConta := U_XAG0045B(cDiaSemana)   
			   	
	   	//Se tem conta cadastrada para o dia da semana, faz a geração
	   	If len(_aConta)  > 0 //.AND. alltrim(cMail) <> ''
			CONOUT('XAG0045, Conta:')   
			CONOUT(_aConta[3])
															 
			//Se nao for passado doc gera ate ZZZ   
			if Empty(xDoc) 
				mv_par01 := '   '//xSerie	//Serie De          
				mv_par02 := 'ZZZ'//xSerie	//Serie Ate         
				mv_par03 := '         '//xDoc	//Nota De           
				mv_par04 := 'ZZZZZZZZZ'//xDoc	//Nota Ate          
			Else
				mv_par01 := xSerie//xSerie	//Serie De          
				mv_par02 := xSerie//xSerie	//Serie Ate         
				mv_par03 := xDoc//xDoc	//Nota De           
				mv_par04 := xDoc//xDoc	//Nota Ate  
			Endif 
			mv_par05 := IIF(alltrim(xDoc) == '' .AND. xGerManual, xDatabase,stod('20220406'))//stod('20180102')//Emissao De  //Data de Inicio da Rotina de Geração      
			mv_par06 := xDatabase//stod('20180102')//Emissao Ate       
			mv_par07 := '      '//xCliente	//Cliente De        
			mv_par08 := 'ZZZZZZ'//xCliente	//Cliente Ate       
			mv_par09 := '  '//xLoja		//Loja De           
			mv_par10 := 'ZZ'//xLoja  		//Loja Ate          
			mv_par11 := 0 			//% de JUROS ao Mês 
			mv_par12 := 0 			//% de Multa        
			mv_par13 := _aConta[1] //Banco             
			mv_par14 := _aConta[2] //Agencia   	      
			mv_par15 := _aConta[3] //Conta             
			mv_par16 := _aConta[4] //Sub-Conta         
			mv_par17 := _aConta[5] //Carteira   
			mv_par18 := 1          //Mostra Todos

			Dbselectarea('SA6')
			DbSetorder(1)
			dbSeek(xFilial("SA6")+mv_par13+mv_par14+mv_par15)
					    
			//Gera query com os Boleto a Ser gerado
			cQuery := ""
			cQuery := " SELECT F2_DOC AS DOC, F2_SERIE AS SERIE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_EMISSAO AS EMISSAO, A1_NOME AS NOMECLI,A1_CGC AS CNPJ, E1_PREFIXO AS PREFIXO "
			cQuery += " FROM " + RetSqlName("SF2") + " (NOLOCK) F2 " 
			cQuery += " INNER JOIN " + RetSqlName("SA1") +" (NOLOCK) A1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = '' AND "  
			cQuery += " A1_FILIAL = '"+xFilial('SA1')+"' AND "
			If alltrim(xDoc) <> ''
				cQuery += " A1_XBOLETO <> '3' "
			Else
				cQuery += " A1_XBOLETO = '2' "
			Endif 
			//Spiller - Trava para nao mostrar Títulos de outros portadores
			cQuery += " LEFT JOIN " + RetSqlName("SE1") + " (NOLOCK) E1 ON E1_FILIAL = '' AND "
			cQuery += "						E1_CLIENTE = F2_CLIENTE AND "
			cQuery += "						E1_LOJA   = F2_LOJA AND "
			cQuery += "						E1_SERIE = F2_SERIE AND E1_FILORIG = F2_FILIAL AND"
			cQuery += "						E1_NUM = F2_DOC AND "
			cQuery += "					 	E1.D_E_L_E_T_ = '' AND E1_TIPO <> 'FT' AND E1_EMISSAO >= '"+DTOS(mv_par05)+"'"  
			//Fim
			//Spiller - Trava para nao mostrar Títulos com notas NÃO autorizadas no NfeSEfaz
			cQuery += "LEFT JOIN "  + RetSqlName("SF3") + " (NOLOCK) F3 ON F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F2_FILIAL = F3_FILIAL "
			cQuery += "AND F2_CLIENTE = F3_CLIEFOR AND F2_LOJA = F3_LOJA and F3.D_E_L_E_T_ = '' "            
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
			cQuery += "AND F2_XPROJ   <> '2' " //Retira projeto Nyke
			//cQuery += "AND E1_NUMBCO   = '' " //Determina que ainda não foi GERADO boleto
			cQuery += "AND E1_XMAILBO   = '' " //Determina que ainda não foi ENVIADO boleto
			cQuery += "AND F2_ORIIMP NOT LIKE '%AGX635%' "//Retira tudo vindo do DBGint    
						
			//Spiller - Trava para nao mostrar Títulos de outros portadores
			cQuery += "AND ( (E1_PORTADO =  '"+mv_par13+"' AND E1_CONTA = '"+mv_par15+"' ) OR E1_PORTADO = '' ) " 
			cQuery += " AND E1_SALDO > 0  "
			cQuery += " AND F2_COND <> '001'  AND (A1_EMAIL <> '' OR A1_EMAIL2 <> '') AND E1_VENCREA >=  '" + DTOS(mv_par06) + "' "  
			cQuery += " AND (F3_CODRSEF = '100' OR  F3_CODRSEF = ''  OR  F3_CODRSEF IS NULL ) "
			cQuery += " AND (F2_CHVNFE  <> '' OR F2_CHVCONH <> '' ) "
			//Fim              
			cQuery += " AND NOT (E1_SITUACA = '0' AND (E1_NUMBCO <> '' OR E1_ZNBANCO <> '' )) "
			cQuery += "GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, A1_NOME, A1_CGC, E1_PREFIXO "
			cQuery += "ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, A1_NOME, A1_CGC "
			conout(cQuery)
			//cQuery := ChangeQuery(cQuery)
			If Select(cAliasTrb) <> 0
				dbSelectArea(cAliasTrb)
				dbCloseArea()
			Endif

			
			//TCQuery cQuery NEW ALIAS cAliasTrb//"TRB"
			cAliasTrb := MpSysOpenQuery(cQuery)
			TCSetField(cAliasTrb,"EMISSAO","D",08,0)  
						
			(cAliasTrb)->(dbgotop())     
					
			//Função de Envio de Email.  
			If (cAliasTrb)->(!eof())   
				conout('XAG0045 - enviando')  
				cFrom     := cMail//'frete.nyke@agricopel.com.br' 
						
			  	U_A095Mail(.T.,cFrom, xAcao) //(Automático , E-mail from , acao)
			   			  
			Else
				_cRetorno := "ERRO - Nenhum Titulo encontrado!"
				conout('XAG0045 - Nenhum Titulo encontrado!')
			Endif     
		Else
			conout('XAG0045 - '+cEmpant+' - '+cFilAnt+'Nenhuma conta cadastrada para esse dia da semana, '+cDiaSemana )
			_cRetorno := "ERRO - Nenhuma conta cadastrada para esse dia da semana, "+cDiaSemana
		Endif			    

		If !(xGerManual) 
			RPCClearEnv()
			dbCloseAll()   
			RESET ENVIRONMENT 
		Endif		
    Next i 
	 
	
Return _cRetorno     
           
      
//Busca Bancos que geram Boleto Automáticamente 
User Function XAG0045A(_xEmp,_xFil)
              
    Local cQuery  := ""
    Local aEmpBol := {}
    
    Default _xEmp := ''
    Default _xFil := ''    
    
    cQuery := " SELECT * FROM EMPRESAS "
	cQuery += " WHERE BOLETO_AUTO = 'S' " 
	If alltrim(_xEmp) <> ''
		cQuery += " AND EMP_COD = '"+_xEmp+"' "
		cQuery += " AND EMP_FIL = '"+_xFil+"' " 
	Endif
	cQuery += " ORDER BY EMP_COD,EMP_FIL "
	conout(cQuery)
	If Select("XAG0045A") <> 0
		dbSelectArea("XAG0045A")
		dbCloseArea()
	Endif
	
	TCQuery cQuery NEW ALIAS "XAG0045A"

	XAG0045A->(dbgotop())     
    
	While XAG0045A->(!eof())
	                         
	    AADD( aEmpBol,{ XAG0045A->EMP_COD , XAG0045A->EMP_FIL, XAG0045A->BOLETO_EMAIL} ) 
	                        
		XAG0045A->(dbskip())
	Enddo 
	
Return aEmpBol
               
        
//Busca Conta Cadastrada para o dia da Semana
User Function XAG0045B(xdiaSemana)
              
    Local cQuery    := "" 
    Local cCodBan   := ""
    Local cAgencia  := ""
    Local cConta    := ""
    Local cSubCon   := ""
    Local cCarteira := ""  
    Local aRet0045  := {}
 
	cQuery := " SELECT EE.R_E_C_N_O_ AS RECNOSEE, * FROM "+RetSqlName('SEE')+"(NOLOCK) EE " 
	cQuery += " INNER JOIN "+RetSqlName('SA6')+"(NOLOCK) A6  ON EE_CODIGO = A6_COD AND EE_CONTA = A6_NUMCON "
	cQuery += " AND A6_AGENCIA = EE_AGENCIA AND A6.D_E_L_E_T_ = '' AND A6_FILIAL = '"+xfilial('SA6')+"'  "	 
	cQuery += " WHERE EE_XGERABO = 'S' AND EE.D_E_L_E_T_ = '' AND A6_XGERABO = 'S' " 
	cQuery += " AND A6_XDIAFAT LIKE '%"+xdiaSemana+"%'  AND A6_FILIAL = '"+xfilial('SA6')+"' "    
	cQuery += " ORDER BY EE_CODIGO "
	conout(cQuery)
	If Select("XAG0045B") <> 0
		dbSelectArea("XAG0045B")
		dbCloseArea()
	Endif
	
	TCQuery cQuery NEW ALIAS "XAG0045B"

	XAG0045B->(dbgotop())    
	
	
	cCodBan   := XAG0045B->EE_CODIGO   //'237'         //Banco             
	cAgencia  := XAG0045B->EE_AGENCIA // '02693'      //Agencia   	      
	cConta    := XAG0045B->EE_CONTA     // '00277207  '   //Conta             
	cSubCon   := XAG0045B->EE_SUBCTA   //'001'  		 //Sub-Conta         
	cCarteira := XAG0045B->A6_CART   //'09'         //Carteira    
		
	If XAG0045B->(!eof())
		AADD(aRet0045, cCodBan )
		AADD(aRet0045, cAgencia )
		AADD(aRet0045, cConta ) 
		AADD(aRet0045, cSubCon ) 
		AADD(aRet0045, cCarteira )                      
	Endif
	
Return aRet0045
                         

//--------------------------------------------------------------
/*/{Protheus.doc} XAG0045C                                    
Description Cadastro de Dia da semana x banco para Faturamento.                                                                                                                  
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Leandro Hey Spiller                                             
@since 13/12/2018                                                   
/*/                                                             
//--------------------------------------------------------------
User Function XAG0045C()      
                                                   
    Local   cStrdia := ""   
    Local   oButton1
	// Local   oButton2 
	Local   oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oSay7                          
	Private oDlgBol
	Private oDomingo,oSegunda,oTerca,oQuarta,oQuinta,oSexta,oSabado
	Private oDomingo1,oSegunda1,oTerca1,oQuarta1,oQuinta1,oSexta1,oSabado1
	Private cDomingo := SPACE(50)
	Private cSegunda := SPACE(50)
	Private cTerca   := SPACE(50) 
	Private cQuarta  := SPACE(50)
	Private cQuinta  := SPACE(50)
	Private cSexta   := SPACE(50) 
	Private cSabado  := SPACE(50)
	Private cDomingo1:= SPACE(50)
	Private cSegunda1:= SPACE(50)
	Private cTerca1  := SPACE(50) 
	Private cQuarta1 := SPACE(50)
	Private cQuinta1 := SPACE(50)  
	Private cSexta1  := SPACE(50)
	Private cSabado1 := SPACE(50)
	
    cQuery := " SELECT EE.R_E_C_N_O_ AS RECNOSEE, * FROM "+RetSqlName('SEE')+"(NOLOCK) EE " 
	cQuery += " INNER JOIN "+RetSqlName('SA6')+"(NOLOCK) A6  ON EE_CODIGO = A6_COD AND EE_CONTA = A6_NUMCON "
	cQuery += " AND A6_AGENCIA = EE_AGENCIA AND A6.D_E_L_E_T_ = '' AND A6_FILIAL = '"+xfilial('SA6')+"'  "	 
	cQuery += " WHERE EE_XGERABO = 'S' AND EE.D_E_L_E_T_ = '' AND A6_XGERABO = 'S' " 
	cQuery += " AND A6_XDIAFAT <> '' "
	cQuery += " ORDER BY EE_CODIGO,A6_XDIAFAT "
	conout(cQuery)	
	//Se não tiver gerado Sql nao seleciona a tabela 
	If Select("XAG0045C") <> 0
  		dbSelectArea("XAG0045C")
   		XAG0045C->(dbclosearea())
  	Endif  

	TCQuery cQuery NEW ALIAS "XAG0045C" 

	While XAG0045C->(!eof()) 
 		
 		cStrdia :=  StrTran( StrTran( XAG0045C->A6_XDIAFAT, " ", "" ), ";", "" )                 
 		
 		If '2' $ cStrdia 
 			cSegunda1 := cSegunda := XAG0045C->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA) 
 		Endif
 		If '3' $ cStrdia 
 		   cTerca1  :=  cTerca  := XAG0045C->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA)
 		Endif
 		If '4' $ cStrdia 
 		   cQuarta1  := cQuarta  := XAG0045C->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA)
 		Endif
 		If '5' $ cStrdia 
 		    cQuinta1 := cQuinta := XAG0045C->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA)
 		Endif
 		If '6' $ cStrdia 
 		     cSexta1 := cSexta := XAG0045C->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA)
 		Endif
 		If '7' $ cStrdia 
 		    cSabado1 := cSabado := XAG0045C->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA)
 		Endif
 		If '1' $ cStrdia 
 		    cDomingo1 := cDomingo := XAG0045C->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA)
 		Endif
 		
 		XAG0045C->(dbskip()) 
	Enddo   

  	DEFINE MSDIALOG oDlgBol TITLE "Dia da semana x banco para Faturamento" FROM 000, 000  TO 350, 450 COLORS 0, 16777215 PIXEL
    
        @ 007, 045 MSGET oSegunda  VAR cSegunda SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 F3 'SEEBOL' VALID (iif (ValBanco(cSegunda),cSegunda1 := cSegunda,cSegunda := cSegunda1 := SPACE(50))) PIXEL  
	    @ 007, 133 MSGET oSegunda1 VAR cSegunda1 SIZE 080, 010 OF oDlgBol COLORS 0, 16777215  PICTURE "@R 999-99999-9999999999"    WHEN .F. PIXEL 
	     
	    @ 027, 045 MSGET oTerca  VAR cTerca SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 F3 'SEEBOL' VALID (iif (ValBanco(cTerca),cTerca1 := cTerca,cTerca := cTerca1 := SPACE(50))) PIXEL
	    @ 027, 133 MSGET oTerca1 VAR cTerca1 SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 PICTURE "@R 999-99999-9999999999" WHEN .F. PIXEL
	    
	    @ 047, 045 MSGET oQuarta  VAR cQuarta SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 F3 'SEEBOL' VALID (iif (ValBanco(cQuarta),cQuarta1 := cQuarta,cQuarta := cQuarta1 := SPACE(50))) PIXEL
	    @ 047, 133 MSGET oQuarta1 VAR cQuarta1 SIZE 080, 010 OF oDlgBol COLORS 0, 16777215  PICTURE "@R 999-99999-9999999999" WHEN .F. PIXEL
	       
	    @ 067, 045 MSGET oQuinta  VAR cQuinta SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 F3 'SEEBOL' VALID (iif (ValBanco(cQuinta),cQuinta1 := cQuinta,cQuinta := cQuinta1 := SPACE(50))) PIXEL  
	    @ 067, 133 MSGET oQuinta1 VAR cQuinta1 SIZE 080, 010 OF oDlgBol COLORS 0, 16777215  PICTURE "@R 999-99999-9999999999" WHEN .F. PIXEL
	    
	    @ 087, 045 MSGET oSexta  VAR cSexta SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 F3 'SEEBOL' VALID (iif (ValBanco(cSexta),cSexta1 := cSexta,cSexta := cSexta1 := SPACE(50))) PIXEL  
	    @ 087, 133 MSGET oSexta1 VAR cSexta1 SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 PICTURE "@R 999-99999-9999999999" WHEN .F. PIXEL
	    
	    @ 107, 045 MSGET oSabado  VAR cSabado SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 F3 'SEEBOL' VALID (iif (ValBanco(cSabado),cSabado1 := cSabado,cSabado := cSabado1 := SPACE(50))) PIXEL 
	    @ 107, 133 MSGET oSabado1 VAR cSabado1 SIZE 080, 010 OF oDlgBol COLORS 0, 16777215  PICTURE "@R 999-99999-9999999999" WHEN .F. PIXEL
	    
	    @ 127, 045 MSGET oDomingo  VAR cDomingo SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 F3 'SEEBOL' VALID (iif (ValBanco(cDomingo),cDomingo1 := cDomingo,cDomingo := cDomingo1 := SPACE(50))) PIXEL 
	    @ 127, 133 MSGET oDomingo1 VAR cDomingo1 SIZE 080, 010 OF oDlgBol COLORS 0, 16777215 PICTURE "@R 999-99999-9999999999"  WHEN .F. PIXEL
	    
	    @ 008, 006 SAY oSay1 PROMPT "SEGUNDA" SIZE 029, 007 OF oDlgBol COLORS 0, 16777215 PIXEL
	    @ 088, 006 SAY oSay2 PROMPT "SEXTA"   SIZE 025, 007 OF oDlgBol COLORS 0, 16777215 PIXEL
	    @ 028, 006 SAY oSay3 PROMPT "TERCA"   SIZE 025, 007 OF oDlgBol COLORS 0, 16777215 PIXEL
	    @ 068, 006 SAY oSay4 PROMPT "QUINTA"  SIZE 025, 007 OF oDlgBol COLORS 0, 16777215 PIXEL
	    @ 048, 006 SAY oSay5 PROMPT "QUARTA"  SIZE 025, 007 OF oDlgBol COLORS 0, 16777215 PIXEL
	    @ 108, 006 SAY oSay6 PROMPT "SABADO"  SIZE 025, 007 OF oDlgBol COLORS 0, 16777215 PIXEL
	    @ 128, 006 SAY oSay7 PROMPT "DOMINGO" SIZE 030, 007 OF oDlgBol COLORS 0, 16777215 PIXEL
	    @ 150, 173 BUTTON oButton1 PROMPT "Gravar" ACTION(GravaBco()) SIZE 037, 012 OF oDlgBol PIXEL
	    //@ 150, 133 BUTTON oButton2 PROMPT "Cancelar" ACTION(oDlgBol:End()) SIZE 037, 012 OF oDlgBol PIXEL  
	    
  	ACTIVATE MSDIALOG oDlgBol CENTERED

Return     


Static Function ValBanco(xChave)
                 
   	Local lRet := .F.                                       

	Dbselectarea('SEE')
	DbSetorder(1) 
	DbGotop()
	If Dbseek(xChave)//	SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA)
		If alltrim(SEE->EE_XGERABO) == 'S'
			lRet := .T.
		Endif
	Endif	
	
	If !lRet
		Alert('Conta inválida!')
	Endif

Return lRet        


Static Function GravaBco()
                 
    Local aDiaBanco := {} 
    Local cQueryGrv := ""
	Local i         := 0
                   
    //Valida se tem algum campo vazio                     
 	If   alltrim(cDomingo)=='' .or. alltrim(cSegunda)=='' .or. alltrim(cTerca)=='' .or. alltrim(cQuarta)=='';
 		.or. alltrim(cQuinta)=='' .or. alltrim(cSexta)=='' .or. alltrim(cSabado)==''
    	Alert('Favor preencher todos os dias!')     
	    Return
    Endif   
          
    AADD(aDiaBanco,cDomingo)
	AADD(aDiaBanco,cSegunda)
	AADD(aDiaBanco,cTerca)
	AADD(aDiaBanco,cQuarta)
	AADD(aDiaBanco,cQuinta)
	AADD(aDiaBanco,cSexta)
	AADD(aDiaBanco,cSabado)
	    
	//Limpa Campos
    cQueryGrv := " UPDATE "+RetSqlName('SA6')+" SET A6_XDIAFAT = '' "
    cQueryGrv += " WHERE A6_FILIAL = '"+xFilial('SA6')+"' AND "
    cQueryGrv += " A6_XDIAFAT <> '' AND D_E_L_E_T_ = '' "  

    If (TCSQLExec(cQueryGrv) < 0)
		Alert("ERRO Gravação, Verifique os campos e confirme novamente: " + cQueryGrv)
		Alert("TCSQLError() - " + TCSQLError()) 
		return
	EndIf   
    
    CONOUT(cQueryGrv)
    
    For i := 1 to len(aDiaBanco) 
        
    	//Grava dia da semana
    	cQueryGrv := " UPDATE "+RetSqlName('SA6')+" SET A6_XDIAFAT = RTRIM(A6_XDIAFAT)+'"+alltrim(STR(I))+"' "
  	  	cQueryGrv += " WHERE  A6_XGERABO = 'S' AND D_E_L_E_T_ = '' AND " 
   		cQueryGrv += " A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON = '"+xFilial('SA6')+"'+'"+ SUBSTRING(aDiaBanco[I],3,18) +"' " 
   		CONOUT(cQueryGrv)      
   		 If (TCSQLExec(cQueryGrv) < 0)
   			Alert("ERRO Gravação, Verifique os campos e confirme novamente: " + cQueryGrv)
			Alert("TCSQLError() - " + TCSQLError()) 
		return
		EndIf   
   	Next i 
   	
   	oDlgBol:End()
    
Return 
    
    


//--------------------------------------------------------------
/*/{Protheus.doc} XAG0045D                                    
Description Executa manualmente a geração / envio da data, pode ser utilizado caso
tenha havido algum problema na execução do dia anterior.                                                                                                                  
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Leandro Hey Spiller                                             
@since 13/12/2018                                                   
/*/                                                             
//--------------------------------------------------------------
User Function XAG0045D()

	Local oDlgEnv
	Local oConfEnv
	Local oData1
	Local dData1 := Date()
	Local oSayData  
	Local lConfirm := .F. 
	//Local oFil1,oFil2 
	//Local cFil1:= "  ",cFil2 := "  "    
	
	If !(FWIsAdmin(__cuserid)) //__cuserid <> '000000'
		Alert("Somente Usuário administrador pode utilizar a Rotina!") 
		Return
	Endif

	DEFINE MSDIALOG oDlgEnv TITLE "Envio Manual de Boletos" FROM 000, 000  TO 120+25, 250 COLORS 0, 16777215 PIXEL
	
	    @ 003+3, 007 SAY oSayData PROMPT "Data Emissao" SIZE 038, 007 OF oDlgEnv COLORS 0, 16777215 PIXEL
	    @ 002+3, 052 MSGET oData1 VAR dData1 SIZE 043, 010 OF oDlgEnv COLORS 0, 16777215 PIXEL  
	    
	    //@ 017, 007 SAY oSayData PROMPT "Filial  de" SIZE 038, 007 OF oDlgEnv COLORS 0, 16777215 PIXEL
	    //@ 016, 052 MSGET oFil1 VAR cFil1 SIZE 043, 010 OF oDlgEnv COLORS 0, 16777215 PIXEL 
	    
	    //@ 032, 007 SAY oSayData PROMPT "Filial  ate" SIZE 038, 007 OF oDlgEnv COLORS 0, 16777215 PIXEL
	    //@ 031, 052 MSGET oFil2 VAR cFil2 SIZE 043, 010 OF oDlgEnv COLORS 0, 16777215 PIXEL     
	    
	    @ 050, 082 BUTTON oConfEnv PROMPT "Confirma" Action(lConfirm := .T.,iif( !empty(dData1),oDlgEnv:End(),Alert('Prencha os campos de Empresa/Filial ate ')) )SIZE 039, 012 OF oDlgEnv PIXEL  
	    
	ACTIVATE MSDIALOG oDlgEnv   
	           
	//Se confirmou, executa
	If lConfirm  
		
		_aEmp := U_XAG0045A(cEmpant,cFilAnt)//busca empresas que gerar boleto Aut
	    
	    If len(_aEmp) > 0   
			IF MsgYesNo(" A rotina irá Gerar/Enviar Manualmente os boletos do dia "+dtoc(dData1)+", Empresa("+cEmpAnt+"/"+cFilAnt+"). CONFIRMA? ")
				U_XAG0045(dData1,_aEmp,.T.)
			Endif
		Else
			Alert("Empresa("+cEmpAnt+"/"+cFilAnt+") não está configurada para geração Automática de boletos")
		Endif   		
	Endif

Return    
    
Static Function PerAGR95()
	Pergunte("AGR95"+xFilial('SA6'),.F.)
Return()




//--------------------------------------------------------------
/*/{Protheus.doc} XAG0045E                                    
Description Geração de boletos com opção de envio por email, geração de pdf
ou impressao                                                                                                                  
@param xFil Filial 
@param xDoc Documento
@param xSerie Serie
@param xAcao Acao ( I - Impressao, A - arquivo , E - Email )
@param xInterface ( .t. - Executado via smartclient, .F. - Executado via Api(nesse caso sera utilizado
prepare environment)
@return  cRetorno  ação = 'I' - 'SUCESSO' , ação = 'A' - caminho do arquivo , 'E' - Sucesso                              
@author Leandro Hey Spiller                                             
@since 01/11/2023     
//Exemplos:
// Exemplo via api:       U_XAG0045E( '06' , '000000001' , '1' , 'A' , .F. )
// Exemplo via Protheus:  U_XAG0045E( '06' , '000000001' , '1' , 'I' , .T. )
/*/                                                             
//--------------------------------------------------------------
User Function XAG0045E( xFil , xDoc , xSerie , xAcao , xInterface )

	Default xFil    := cFilAnt 
	Default xAcao   := 'I' // I - impressora / A - Arquivo / E - Email  
	Default xInterface := .T.
	
	local _aEmp := {}
	Private _cRetorno   := "SUCESSO"

	If Type("_cPrinter") == 'U'	
		_cPrinter := SuperGetMV( "MV_XPRAUTO" , .F. , "Microsoft Print to PDF" )  //Impressora para nota e boleto
	Endif 

	//Carrego apenas os arquivos da empresa Logada
	AADD(_aEmp ,{ cEmpant , cFilAnt, ''} )
	
	//Chamo a Rotina de Geração 
	//Parametros(xDatabase,xEmpresas,xGerManual, documento, serie e ação )
	U_XAG0045(dDatabase,_aEmp,xInterface, xDoc, xSerie , xAcao )
	
Return _cRetorno 
