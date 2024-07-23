#include 'protheus.ch'  
#include 'topconn.ch'
      
/*{Protheus.doc} XAG0046
//Chamado 78623 - Relatório de Titulos/Faturas em Aberto
@author Spiller
@since 18/01/2019
@version undefined
@type function */ 
User Function XAG0046()    
         
	Private cPerg   := 'XAG0046' 
	Private lretArq := .F.  
	Private nTotReg := 0
		                  
	Valperg(cPerg)          
	          
	If !Pergunte(cPerg)    
	    Return
	Endif 
	
	Processa( {|| lretArq := BuscaDados() }, "Buscando dados...")  //BuscaDados()
   //	 Processa( {|| U_TestSX3(aCampos) }, "Aguarde...", "Carregando definição dos campos...",.F.)
	If lretArq
		Processa( {|| Imprime()	})
    Else
    	Alert('Nenhum Título com os parâmetros selecionados!')
    Endif 
Return


//Busca Dados
Static Function BuscaDados()
    
   	Local cQuery := "" 
   	Local lRet 	 := .F.  
   	
  	//Incproc(">>> Buscando dados ...")	 
	
	cQuery += "SELECT A1_DDD,A1_TEL,A1_COD,A1_LOJA,A1_NOME  "
	cQuery += ",E1.E1_EMISSAO AS EMIS_TIT " 
	cQuery += ",E1.E1_VENCREA AS VENC_TIT "
	cQuery += ",E1.E1_PREFIXO AS PREFIXO "
	cQuery += ",E1.E1_NUM AS NUM_TIT "
	cQuery += ",E1.E1_VALOR AS VALORTIT "
	cQuery += ",E1.E1_SALDO AS SALDOTIT "
	cQuery += ",E1FAT.E1_EMISSAO AS EMIS_FAT "
	cQuery += ",E1FAT.E1_VENCREA AS VENC_FAT "
	cQuery += ",E1FAT.E1_NUM AS NUM_FAT "//--, FI7.FI7_NUMDES 
	cQuery += ",E1FAT.E1_PREFIXO AS PREF_FAT "//--, FI7.FI7_NUMDES
	cQuery += ",E1FAT.E1_VALOR AS VALORFAT,E1FAT.E1_SALDO AS SALDOFAT "//--, SF2.*
	cQuery += " FROM "+RetSqlName('SF2')+"(NOLOCK) SF2 "
	cQuery += "INNER JOIN "+RetSqlName('SA1')+" (NOLOCK) A1  ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = '' AND A1_FILIAL = '"+xfilial('SA1')+"' " 
	cQuery += "LEFT JOIN EMPRESAS(NOLOCK)  EMP ON A1_CGC = EMP_CNPJ "
	cQuery += "INNER JOIN "+RetSqlName('SE1')+" (NOLOCK) E1 ON E1.E1_NUM = F2_DOC AND E1.E1_PREFIXO = SF2.F2_PREFIXO AND "
	cQuery += "E1.E1_CLIENTE = F2_CLIENTE AND F2_LOJA = E1.E1_LOJA AND E1.D_E_L_E_T_ = '' "///*AND E1.E1_TIPO <> 'FT'*/ -- Trago todas que tem título
	cQuery += "LEFT JOIN "+RetSqlName('FI7')+"(NOLOCK)FI7  ON FI7_NUMORI = E1.E1_NUM AND FI7_PRFORI = E1.E1_PREFIXO AND " 
	cQuery += "FI7.D_E_L_E_T_ = '' AND FI7_CLIORI = E1_CLIENTE AND FI7_LOJORI = E1_LOJA "//--'039322'
	cQuery += "LEFT JOIN "+RetSqlName('SE1')+"(NOLOCK) E1FAT ON E1FAT.E1_NUM = FI7_NUMDES AND E1FAT.E1_PREFIXO = FI7_PRFDES AND "
	cQuery += "E1FAT.E1_CLIENTE = FI7_CLIDES AND E1FAT.E1_LOJA = FI7_LOJDES AND E1FAT.D_E_L_E_T_ = '' AND E1FAT.E1_TIPO = 'FT'"//-- Trago todas que tem título
	cQuery += "WHERE "
	cQuery += "E1.E1_PREFIXO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	cQuery += "E1.E1_NUM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
	cQuery += "F2_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' AND "
	cQuery += "F2_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
	cQuery += "F2_LOJA BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND " 
	If MV_PAR11 == 1 //Somente Vencidos
		cQuery += "( E1.E1_SALDO > 0 OR E1FAT.E1_SALDO > 0 ) AND " 
		cQuery += " ( E1.E1_VENCREA <= '"+dtos(ddatabase)+"' OR (E1FAT.E1_VENCREA <= '"+dtos(ddatabase)+"' AND E1FAT.E1_VENCREA IS NOT NULL ) ) AND " 
	Endif
	If MV_PAR12 == 2//Não Mostra Empresas do Grupo
		cQuery += "EMP_COD IS  NULL AND "//-- Somente de empresas que não sejam do grupo
    Endif   
                                            
 	//Fretes
    If MV_PAR13 == 1 //Outros
		cQuery += "F2_ORIIMP IN ('AGX635CS') AND "//--= 'AGX635CS' --Somente o que veio do DBGint 
		cQuery += "F2_XPROJ <> '2' AND "//-- Somente o que não é Nyke
		cQuery += "A1_NOME NOT LIKE '%RAIZEN%' "//-- somente o que não é Raizen
	ElseIf MV_PAR13 == 2 //Raizen
		cQuery += "F2_ORIIMP IN ('AGX635CS') AND "//--= 'AGX635CS' --Somente o que veio do DBGint 
		cQuery += "F2_XPROJ <> '2' AND "//-- Somente o que não é Nyke
		cQuery += "A1_NOME LIKE '%RAIZEN%'  "//-- somente o que não é Raizen
	ElseIf MV_PAR13 == 3//Nyke
		cQuery += "F2_ORIIMP IN ('AGX635CS') AND "//--= 'AGX635CS' --Somente o que veio do DBGint 
		cQuery += "F2_XPROJ = '2'  "//-- Somente o que não é Nyke
	ElseIf MV_PAR13 == 4//Todos
		cQuery += "F2_ORIIMP IN ('AGX635CS')  "
	ElseIf MV_PAR13 == 5//Não são Fretes
	  	cQuery += "F2_ORIIMP NOT IN ('AGX635CS') " 
	Else
		cQuery += " "
	Endif
	cQuery += "ORDER BY F2_CLIENTE,F2_LOJA,E1FAT.E1_NUM, E1.E1_NUM,E1.E1_EMISSAO,E1FAT.E1_EMISSAO 
	
	If Select('XAG0046') <> 0
      dbSelectArea('XAG0046')
	  dbCloseArea()
    Endif
    
    TCQuery cQuery NEW ALIAS 'XAG0046'  
    
    TCSetField('XAG0046',"EMIS_TIT","D",08,0)
    TCSetField('XAG0046',"VENC_TIT","D",08,0)
    TCSetField('XAG0046',"EMIS_FAT","D",08,0)
    TCSetField('XAG0046',"VENC_FAT","D",08,0)                     
    
  	XAG0046->(dbgotop()) 
  	If XAG0046->(!eof())
    	lRet := .T.
	Endif     
	
	DBSELECTAREA('XAG0046')  
	nTotReg := Contar('XAG0046',"!Eof()") 
	XAG0046->(dbgotop())     
	
Return lRet 

Static Function Imprime()
    
    Local cCabec   := ""
    Local cCabec2  := "" 
    Local cRelat   := ""
    Local cLinha   := ""
    Local cCliente := "" 
    
    ProcRegua(nTotReg)
          
	cCabec += "Codigo;"
	cCabec += "Loja;"
	cCabec += "Nome;"
	cCabec += "DDD;"
	cCabec += "Tel.;" 
	
	cCabec2 := "Emis. TIT;"
	cCabec2 += "Vencto TIT;"
	cCabec2 += "Num. TIT;"
	cCabec2 += "Vlr. TIT;"
	cCabec2 += "Saldo TIT;"
	cCabec2 += "FATURA Saldo;"
	cCabec2 += "FATURA Vlr.;" 
	cCabec2 += "FATURA Num.;"
	cCabec2 += "FATURA Emis.;"
	cCabec2 += "FATURA Vencto.;"



	//cRelat += cCabec+chr(13)        

	While XAG0046->(!eof())  
		
		cLinha := ""
		Incproc(">>> Imprimindo ..."+XAG0046->PREFIXO+' - '+ XAG0046->NUM_TIT)	 
		
		//Só imprime o Título caso a fatura esteja vencida
		If MV_PAR11 == 1 //Somente Vencidos
			If !empty(XAG0046->VENC_FAT) 
				If XAG0046->VENC_FAT >= ddatabase
					XAG0046->(Dbskip())
					Loop
				Endif
			Endif
		Endif
		            
		//Analitico Quebra por Cliente 
		If MV_PAR14 == 1 
			If cCliente <> XAG0046->A1_COD+XAG0046->A1_LOJA
				cRelat += chr(13)+cCabec+chr(13)

		   		cRelat += FormatReg(XAG0046->A1_COD)+";"
				cRelat += FormatReg(XAG0046->A1_LOJA)+";"
				cRelat += FormatReg(XAG0046->A1_NOME)+";" 
				cRelat += alltrim(XAG0046->A1_DDD)+";"  
				cRelat += alltrim(XAG0046->A1_TEL)+""	+chr(13)
				cRelat += cCabec2+chr(13)
			Endif
		Else
			If Empty(cRelat) 
				cRelat := cCabec+cCabec2+chr(13)
			Endif
			cLinha += FormatReg(XAG0046->A1_COD)+";"
			cLinha += FormatReg(XAG0046->A1_LOJA)+";"
			cLinha += FormatReg(XAG0046->A1_NOME)+";" 
			cLinha += alltrim(XAG0046->A1_DDD)+";"  
			cLinha += alltrim(XAG0046->A1_TEL)+";"
		Endif  
		
		cLinha += FormatReg(XAG0046->EMIS_TIT)+";"
		cLinha += FormatReg(XAG0046->VENC_TIT)+";"
	    cLinha += FormatReg(XAG0046->PREFIXO+'-'+XAG0046->NUM_TIT)+";"               
		//cLinha += FormatReg(XAG0046->NUM_TIT)+";"
   		cLinha += FormatReg(XAG0046->VALORTIT)+";"
		cLinha += FormatReg(XAG0046->SALDOTIT)+";" 
		
		If !Empty(XAG0046->NUM_FAT)//Só imprime Fatura se houver
			cLinha += FormatReg(XAG0046->SALDOFAT)+";" 
			cLinha += FormatReg(XAG0046->VALORFAT)+";" 
			cLinha += FormatReg(XAG0046->PREF_FAT+'-'+NUM_FAT )+";"
			cLinha += FormatReg(XAG0046->EMIS_FAT)+";"
			cLinha += FormatReg(XAG0046->VENC_FAT)+";"
		Endif

		cRelat += clinha+chr(13)
		
		cCliente := XAG0046->A1_COD+XAG0046->A1_LOJA
		
		XAG0046->(dbskip())	
	Enddo                       


	cArq := 'XAG0046_'+dtos(ddatabase)+''+SubStr( Time(), 1, 2 )+SubStr( Time(), 4, 2 )+SubStr( Time(), 7, 2 )+'.csv'
		
	//Grava Arquivo
	MEMOWRITE(cArq,cRelat)
	
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
         

Static Function FormatReg(xCampo)  
                                    
	Local cCampo := ""                            
 
	If Valtype(xCampo) == 'C' 
		If !Empty(xCampo)
	   		cCampo := "'"+xCampo+"'" 
	 	Endif
	Elseif Valtype(xCampo) == 'D' 
		cCampo := dtoc(xCampo)
	ElseIf Valtype(xCampo) == 'N'  
		cCampo := alltrim(StrTran( str( xCampo ), ".", ","))
	Endif

	cCampo := alltrim(cCampo)

Return cCampo

Static function Valperg()

	Local aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Prefixo De        ?","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Prefixo Ate       ?","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Título De         ?","mv_ch3","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Título Ate        ?","mv_ch4","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Emissao De        ?","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Emissao Ate       ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Cliente De        ?","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","CLI"})
	AADD(aRegistros,{cPerg,"08","Cliente Ate       ?","mv_ch8","C",6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","CLI"})
	AADD(aRegistros,{cPerg,"09","Loja De           ?","mv_ch9","C",2,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Loja Ate          ?","mv_chA","C",2,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"11","Somente Vencidos  ?","mv_chB","N",01,0,0,"C","","mv_par11","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Mostra Emp. Grupo ?","mv_chC","N",01,0,0,"C","","mv_par12","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"13","Fretes			   ?","mv_chD","N",01,0,0,"C","","mv_par13","Outros","","","Raizen"      ,"","","Nyke"        ,"","","Todos os fretes","","","Nao Fretes","",""})
	AADD(aRegistros,{cPerg,"14","Tipo Rel.		   ?","mv_chE","N",01,0,0,"C","","mv_par14","Analitico","","","Sintetico","","",""        ,"","","","","","","",""})
  

	U_CriaPer(cPerg,aRegistros)
                                                                                                                                        
	//Só Vencidos:   Sim / Não
	//Emp. do Grupo: Sim / Não 
	//Fretes: Outros / Raizen / Nyke

Return