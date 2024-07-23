#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX425    บAutor  ณLeandro             บ Data ณ  10/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Log Altera็ใo Pre็o Unitแrio Nota Entrada                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP10                                                       บฑฑ                      
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX425()

	SetPrvt("aImprime")
          
	aImprime := {}   
	cDesc1        	:= OemToAnsi("Este programa tem como objetivo, listar as")
	cDesc2        	:= OemToAnsi("๚ltimas entradas dos produtos. ")
	cDesc3        	:= ""
	cPict         	:= ""
	nLin         	:= 80 
	cabec1       	:= "CำDIGO          CODIGO TKE DESCRIวรO                                                         NOTA 1            VALOR 1     EMISSAO 1            NOTA 2            VALOR 2     EMISSAO 2     VL ALTERADO     % ALTERADO"
    cabec2  	    := ""            
	imprime      	:= .T.
	aOrd 			:= ""
	lEnd            := .F.
	lAbortPrint     := .F.
	CbTxt           := ""
	limite          := 132
	tamanho         := "G"
	nomeprog        := "AGX425"
	nTipo           := 18
	aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey        := 0
	cbtxt        	:= Space(10)
	cbcont       	:= 00
	CONTFL      	:= 01
	m_pag       	:= 01
	wnrel       	:= "AGX425"
	aRegistros  	:= {}
	cPerg		    := "AGX425"
	cString 	   	:= "SD1"  
	titulo  	    :="Rela็ใo das ๚ltimas entradas dos produtos"
    cCancel 	    := "***** CANCELADO PELO OPERADOR *****"
	aRegistros      := {}                                                                                                                                                     
	
	AADD(aRegistros,{cPerg,"01","Data Emissใo De    ?","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data Emissใo Ate   ?","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})	            
	AADD(aRegistros,{cPerg,"03","Produto De         ?","mv_ch3","C",15,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","SB1"})	
	AADD(aRegistros,{cPerg,"04","Produto Ate        ?","mv_ch4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SB1"})	
	AADD(aRegistros,{cPerg,"05","Armazem De         ?","mv_ch5","C",02,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"06","Armazem Ate        ?","mv_ch6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","",""})		
	AADD(aRegistros,{cPerg,"07","Somente Alterados  ?","mv_ch7","N",01,0,0,"C","","MV_PAR07","SIM","","","NรO","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Tipo Valor NF      ?","mv_ch8","N",01,0,0,"C","","MV_PAR08","Vl Unit","","","Custo","","","Custo C/ Imp","","","","","","","",""})
	
	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg,.F.)
	
    wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  
	
	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
	    Set Filter To
	    Return
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracoes de arrays                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Processa({|| GeraDados() })

    RptStatus({|| RptDetail() })

Return

Static Function GeraDados()

	Local nValor1 := 0
	Local nValor2 := 0
	Local nPDif   := 0
	Local nVlDif  := 0

    If Select("ARQ_TRAB_TEMP") <> 0
       dbSelectArea("ARQ_TRAB_TEMP")
   	   dbCloseArea()
    Endif

    IncProc("Processando...")

	aCampos := {}
                 
	aTam:=TamSX3("D1_COD")
	AADD(aCampos,{ "CODPROD"     ,"C",aTam[1],aTam[2] } )    
	                
	aTam:=TamSX3("B1_CODTKE")
	AADD(aCampos,{ "COD_TKE"     ,"C",aTam[1],aTam[2] } ) 
	                   	
	aTam:=TamSX3("B1_DESC")
	AADD(aCampos,{ "DSPROD"      ,"C",aTam[1],aTam[2] } )  
	                  		
	aTam:=TamSX3("D1_DOC")
	AADD(aCampos,{ "NOTA_1"      ,"C",aTam[1],aTam[2] } )  
	                
	aTam:=TamSX3("D1_SERIE")
	AADD(aCampos,{ "SERIE_1"     ,"C",aTam[1],aTam[2] } )  	                
	                   
	aTam:=TamSX3("D1_VUNIT")
	AADD(aCampos,{ "VALOR_1"     ,"N",aTam[1],aTam[2] } )	                  
	                  
	aTam:=TamSX3("D1_EMISSAO")
	AADD(aCampos,{ "EMISSAO_1"   ,"D",aTam[1],aTam[2] } ) 	                  
	                  
	aTam:=TamSX3("D1_DOC")
	AADD(aCampos,{ "NOTA_2"      ,"C",aTam[1],aTam[2] } )  	  
	 
	aTam:=TamSX3("D1_SERIE")
	AADD(aCampos,{ "SERIE_2"     ,"C",aTam[1],aTam[2] } )  
		
	aTam:=TamSX3("D1_VUNIT")
	AADD(aCampos,{ "VALOR_2"     ,"N",aTam[1],aTam[2] } )	 
	
	aTam:=TamSX3("D1_EMISSAO")
	AADD(aCampos,{ "EMISSAO_2"   ,"D",aTam[1],aTam[2] } )  
	                  
	aTam:=TamSX3("D1_VUNIT")	
	AADD(aCampos,{ "VLDIF"		 ,"N",aTam[1],aTam[2] } )			              
	
	aTam:=TamSX3("D1_VUNIT")	
	AADD(aCampos,{ "PDIF"		 ,"N",aTam[1],aTam[2] } )		              	
        
	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"ARQ_TRAB_TEMP",.T.,.F.)
            
	IndRegua("ARQ_TRAB_TEMP",cArqTrab,"PDIF",,,"REGUA_1")    

    aImprime := {} 
	  
	cQuery := ""                                                
	cQuery := "  SELECT DISTINCT(SD1.D1_COD), "
	cQuery += "         SB1.B1_DESC, "
	cQuery += "         SB1.B1_CODTKE, "	
	cQuery += "         SB1.B1_GRTRIB "	
	
	cQuery += "  FROM " + RetSqlName("SD1") + " AS SD1, " + RetSqlName("SB1") + " AS SB1, " + RetSqlName("SF1") + " AS SF1 "
	
	cQuery += "  WHERE SD1.D1_FILIAL = " + xFilial("SD1")
	cQuery += "    AND SD1.D_E_L_E_T_ <> '*' "
	cQuery += "    AND SD1.D1_TIPO = 'N' "     

	cQuery += "    AND SF1.F1_FORNECE = SD1.D1_FORNECE "
	cQuery += "    AND SF1.F1_DOC = SD1.D1_DOC "
	cQuery += "    AND SF1.F1_SERIE = SD1.D1_SERIE "
	cQuery += "    AND SF1.F1_EMISSAO = SD1.D1_EMISSAO "

	cQuery += "    AND SF1.D_E_L_E_T_ <> '*' "
	cQuery += "    AND SF1.F1_STATUS = 'A' "

	cQuery += "    AND SB1.B1_FILIAL = " + xFilial("SB1")
	cQuery += "    AND SB1.D_E_L_E_T_ <> '*' "	                      
	cQuery += "    AND SB1.B1_COD = SD1.D1_COD "	                      
	
	cQuery += "    AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQuery += "    AND SD1.D1_COD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cQuery += "    AND SD1.D1_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"

	cQuery += "  ORDER BY SD1.D1_COD "

    cQuery := ChangeQuery(cQuery)
    
    If Select("QRY_SD1") <> 0
       dbSelectArea("QRY_SD1")
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS "QRY_SD1"

	dbSelectArea("QRY_SD1") 	 
	dbGoTop() 	
	While !Eof()
	           	   
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Busca da ๚ltima nota de compra do produto                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	           	  
	           	  
		cQuery2 := ""                                                
		cQuery2 := "  SELECT SD1.D1_EMISSAO, "
		cQuery2 += "         SD1.D1_UM, "
		cQuery2 += "         SD1.D1_DOC, "	
		cQuery2 += "         SD1.D1_SERIE, "
		cQuery2 += "         SD1.D1_VUNIT, "

		cQuery2 += "         ROUND(D1_VALICM / D1_QUANT,2) AS VALICM, "
		cQuery2 += "         ROUND(D1_VALIPI / D1_QUANT,2) AS VALIPI, "
		cQuery2 += "         ROUND(D1_ICMSRET / D1_QUANT,2) AS ICMSRET, "

		cQuery2 += "         ROUND(D1_CUSTO / D1_QUANT, 2) AS D1_CUSTO "
		
		cQuery2 += "  FROM " + RetSqlName("SD1") + " AS SD1, " + RetSqlName("SF1") + " AS SF1 "

		cQuery2 += "  WHERE SD1.D1_FILIAL = " + xFilial("SD1")
		cQuery2 += "    AND SD1.D_E_L_E_T_ <> '*' "
		cQuery2 += "    AND SD1.D1_TIPO = 'N' "     

		cQuery2 += "    AND SF1.F1_FORNECE = SD1.D1_FORNECE "
		cQuery2 += "    AND SF1.F1_DOC = SD1.D1_DOC "
		cQuery2 += "    AND SF1.F1_SERIE = SD1.D1_SERIE "
		cQuery2 += "    AND SF1.F1_EMISSAO = SD1.D1_EMISSAO "

		cQuery2 += "    AND SF1.D_E_L_E_T_ <> '*' "
		cQuery2 += "    AND SF1.F1_STATUS = 'A' "
                                                                   
		cQuery2 += "    AND SD1.D1_COD = '" + QRY_SD1->D1_COD + "'"
		                                          
		cQuery2 += "    AND SD1.D1_EMISSAO = (SELECT MAX(SD1_SUB.D1_EMISSAO) "
		cQuery2 += "  						  FROM " + RetSqlName("SD1") + " AS SD1_SUB "		
		cQuery2 += "  						  WHERE SD1_SUB.D1_FILIAL = " + xFilial("SD1")
		cQuery2 += "    					  AND SD1_SUB.D_E_L_E_T_ <> '*' "
		cQuery2 += "    					  AND SD1_SUB.D1_TIPO = 'N' "                                                                
		cQuery2 += "    					  AND SD1_SUB.D1_COD = SD1.D1_COD) "
		         
	    cQuery2 := ChangeQuery(cQuery2)
		      
	    If Select("QRY_NOTA1") <> 0
	       dbSelectArea("QRY_NOTA1")
	   	   dbCloseArea()
	    Endif
	
		TCQuery cQuery2 NEW ALIAS "QRY_NOTA1"
		TCSetField("QRY_NOTA1", "D1_EMISSAO", "D", 08, 0)   		
                    
        cDtEmissao := ""
        cDtEmissao := Dtos(QRY_NOTA1->D1_EMISSAO)  
          
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Busca da pen๚ltima nota de compra do produto                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery3 := ""                                                
		cQuery3 := "  SELECT SD1.D1_EMISSAO, "
		cQuery3 += "         SD1.D1_UM, "
		cQuery3 += "         SD1.D1_DOC, "	
		cQuery3 += "         SD1.D1_SERIE, "
		cQuery3 += "         SD1.D1_VUNIT, "

		cQuery3 += "         ROUND(D1_VALICM / D1_QUANT,2) AS VALICM, "
		cQuery3 += "         ROUND(D1_VALIPI / D1_QUANT,2) AS VALIPI, "
		cQuery3 += "         ROUND(D1_ICMSRET / D1_QUANT,2) AS ICMSRET, "

		cQuery3 += "         ROUND(D1_CUSTO / D1_QUANT, 2) AS D1_CUSTO "

		cQuery3 += "  FROM " + RetSqlName("SD1") + " AS SD1, " + RetSqlName("SF1") + " AS SF1 "

		cQuery3 += "  WHERE SD1.D1_FILIAL = " + xFilial("SD1")
		cQuery3 += "    AND SD1.D_E_L_E_T_ <> '*' "
		cQuery3 += "    AND SD1.D1_TIPO = 'N' " 

		cQuery3 += "    AND SF1.F1_FORNECE = SD1.D1_FORNECE "
		cQuery3 += "    AND SF1.F1_DOC = SD1.D1_DOC "
		cQuery3 += "    AND SF1.F1_SERIE = SD1.D1_SERIE "
		cQuery3 += "    AND SF1.F1_EMISSAO = SD1.D1_EMISSAO "

		cQuery3 += "    AND SF1.D_E_L_E_T_ <> '*' "
		cQuery3 += "    AND SF1.F1_STATUS = 'A' "

		cQuery3 += "    AND SD1.D1_COD = '" + QRY_SD1->D1_COD + "'"

		cQuery3 += "    AND SD1.D1_EMISSAO = (SELECT MAX(SD1_SUB.D1_EMISSAO) "
		cQuery3 += "  						  FROM " + RetSqlName("SD1") + " AS SD1_SUB "
		cQuery3 += "  						  WHERE SD1_SUB.D1_FILIAL = " + xFilial("SD1")
		cQuery3 += "    					  AND SD1_SUB.D_E_L_E_T_ <> '*' "
		cQuery3 += "    					  AND SD1_SUB.D1_TIPO = 'N' "
		cQuery3 += "    					  AND SD1_SUB.D1_COD = SD1.D1_COD "

		cQuery3 += "    					  AND SD1_SUB.D1_EMISSAO <> '" + cDtEmissao + "'"
		cQuery3 += "						 ) "

	    cQuery3 := ChangeQuery(cQuery3)

	    If Select("QRY_NOTA2") <> 0
	       dbSelectArea("QRY_NOTA2")
	   	   dbCloseArea()
	    Endif

		TCQuery cQuery3 NEW ALIAS "QRY_NOTA2"
		TCSetField("QRY_NOTA2", "D1_EMISSAO", "D", 08, 0)

		dbSelectArea("ARQ_TRAB_TEMP")
		RecLock("ARQ_TRAB_TEMP",.T.)

		Do Case 
			Case MV_PAR08 == 1
				nValor1 := QRY_NOTA1->D1_VUNIT
				nValor2 := QRY_NOTA2->D1_VUNIT
			Case MV_PAR08 == 2
				nValor1 := QRY_NOTA1->D1_CUSTO
				nValor2 := QRY_NOTA2->D1_CUSTO
			Case MV_PAR08 == 3
				// Regra deste trecho foi retirada do fonte AGR129 - Linha 148 em diante
				If Alltrim(QRY_SD1->B1_GRTRIB) == '10' .Or. Alltrim(SB1->B1_GRTRIB) == '60'
					nValor1 := QRY_NOTA1->D1_VUNIT + QRY_NOTA1->VALIPI + QRY_NOTA1->ICMSRET
					nValor2 := QRY_NOTA2->D1_VUNIT + QRY_NOTA2->VALIPI + QRY_NOTA2->ICMSRET
				Else
					nValor1 := QRY_NOTA1->D1_VUNIT - QRY_NOTA1->VALICM + QRY_NOTA1->VALIPI + QRY_NOTA1->ICMSRET
					nValor2 := QRY_NOTA2->D1_VUNIT - QRY_NOTA1->VALICM + QRY_NOTA2->VALIPI + QRY_NOTA2->ICMSRET
				EndIf
		End Case

		nVlDif	:= nValor1 - nValor2

		If nVlDif <> 0
			nPDif   := (nVlDif / nValor1) * 100
		Else
			nPDif   := 0
		EndIf

		REPLACE CODPROD         WITH  QRY_SD1->D1_COD
		REPLACE COD_TKE			WITH  QRY_SD1->B1_CODTKE
		REPLACE DSPROD			WITH  QRY_SD1->B1_DESC
		REPLACE NOTA_1			WITH  AllTrim(QRY_NOTA1->D1_DOC)
		REPLACE SERIE_1			WITH  AllTrim(QRY_NOTA1->D1_SERIE)
		REPLACE EMISSAO_1		WITH  QRY_NOTA1->D1_EMISSAO
		REPLACE NOTA_2			WITH  AllTrim(QRY_NOTA2->D1_DOC)
		REPLACE SERIE_2			WITH  AllTrim(QRY_NOTA2->D1_SERIE)
		REPLACE VALOR_1			WITH  nValor1
		REPLACE VALOR_2			WITH  nValor2
		REPLACE EMISSAO_2		WITH  QRY_NOTA2->D1_EMISSAO
		REPLACE VLDIF			WITH  nVlDif		
		REPLACE PDIF		    WITH  Round(nPDif, 2)
						
		MsUnLock()           
					   
        dbSelectArea("QRY_SD1")   
        Skip()		
	EndDo

Return

Static Function RptDetail

  	Titulo   := Titulo

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18))//Impressao do cabecalho
	 
	SetRegua(Len(aImprime))
	
	nLin 	 := 9
	nTotVol	 := 0
	nTotFat	 := 0  
	RepCod   := ''
	GruCod   := ''
	PriVez   := 'N'  
	dDataC   := CtoD('  /  /  ')   
	Nota     := ''
	Serie    := ''         
	Usuario  := ''

	nLin 	 += 1
    
	dbSelectArea("ARQ_TRAB_TEMP")   	
	dbGoTop() 		                  
	While !Eof()
		If lEnd
			Exit
		endif
	           
	 	if (MV_PAR07 == 2) .Or. (ARQ_TRAB_TEMP->PDIF <> 0)
			if nLin > 55
				Roda(0,"","P") 		
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIf(aReturn[4]==1,15,18)) //Impressao do cabecalho
				nLin := 9			
			EndIf
		
			@ nLin,000 PSAY ARQ_TRAB_TEMP->CODPROD
			@ nLin,016 PSAY ARQ_TRAB_TEMP->COD_TKE
			@ nLin,027 PSAY substr(ARQ_TRAB_TEMP->DSPROD, 1,60)
			@ nLin,093 PSAY allTrim(ARQ_TRAB_TEMP->NOTA_1) + "/" + allTrim(ARQ_TRAB_TEMP->SERIE_1)
			@ nLin,107 PSAY Transform(ARQ_TRAB_TEMP->VALOR_1,"@E 99999999.99")
			@ nLin,123 PSAY ARQ_TRAB_TEMP->EMISSAO_1
		          
			if allTrim(ARQ_TRAB_TEMP->NOTA_2) <> "" // SE ENCONTROU A SEGUNDA NF IRม IMPRIMIR SEUS DADOS
				@ nLin,144 PSAY allTrim(ARQ_TRAB_TEMP->NOTA_2) + "/" + allTrim(ARQ_TRAB_TEMP->SERIE_2)
				@ nLin,158 PSAY Transform(ARQ_TRAB_TEMP->VALOR_2,"@E 99999999.99") 
				@ nLin,174 PSAY ARQ_TRAB_TEMP->EMISSAO_2
				@ nLin,188 PSAY Transform(ARQ_TRAB_TEMP->VLDIF,"@E 99999999.99") 
				@ nLin,205 PSAY Transform(ARQ_TRAB_TEMP->PDIF, "@E 999999.99") 
			Endif
              
			incRegua()
		 	nLin++
		Endif
		
		skip()
	Enddo
           
	dbSelectArea("ARQ_TRAB_TEMP")
	dbCloseArea()

	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool   
Return