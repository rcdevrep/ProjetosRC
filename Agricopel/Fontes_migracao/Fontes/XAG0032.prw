#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} XAG0032 
cria tabela CD6 - Combustíveis na transmissão da Nota
@author Leandro Hey Spiller
@since 11/06/2018
@version 1
@type function 
@Params xCD6MANUAL: usado apenas para gerar manualamente a tabela CD6, deve se Passar Nota+Serie 
/*/
User Function XAG0032(xCD6MANUAL)

	Local cQuery 	:= ""
	Local _aarea    := Getarea()  
	Local ntamItem  := 4
	Local lCodIf    := .T.
	Default xCD6MANUAL := ""
	
	//Quando for necessário executar manualmente a CD6 - Passar a Chave completa da Nota
	If alltrim(xCD6MANUAL) <> ""
		Dbselectarea('SF2')
		Dbsetorder(1)
		dbseek(xfilial('SF2')+xCD6MANUAL  )
	Endif 
	
	//Valida se Existe o Campo de Codigo Simp na tabela de Produtos
	Dbselectarea('SB1')
	If SB1->(FieldPos("B1_CODSIMP")) <= 0 
		Return
	Endif 


	//Valida se Existe o Campo de Codigo Simp na tabela de Produtos
	Dbselectarea('SB1')
	If SB1->(FieldPos("B1_CODIF")) <= 0 
		lCodIf    := .F.
	Endif 
	
	//Valida se Existe o Campo de Codigo Simp na tabela C0G
	Dbselectarea('C0G')
	If C0G->(FieldPos("C0G_CODIGO")) <= 0  
		Return
	Endif
	
	//Valida se Existe o Campo de Codigo Simp na tabela CD6
	Dbselectarea('CD6')
	If CD6->(FieldPos("CD6_CODANP")) <= 0 .OR. CD6->(FieldPos("CD6_DESANP")) <= 0 
		Return
	Endif  
	
	cQuery := ""
	cQuery += " SELECT D2.*,B1_CODSIMP"/*,B1_CODANP"*/+IIF(lCodIf,",B1_CODIF","")/*,B1_CODIF*/+",B1_DESC,C0G_DESCRI "//D2_BASEICM,D2_VALICM,D2_FILIAL,D2_SERIE ,D2_DOC,D2_CLIENTE,D2_LOJA ,D2_ITEM,D2_COD,D2_PICM,R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SD2") + " (NOLOCK) AS D2 "                                                                             
	cQuery += " INNER JOIN " + RetSqlName("SB1") + "(NOLOCK) AS B1 ON B1_COD = D2_COD AND B1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial('SB1')+"' " 
	cQuery += " LEFT  JOIN " + RetSqlName("C0G") + "(NOLOCK) AS C0G ON B1_CODSIMP = C0G_CODIGO AND C0G.D_E_L_E_T_ = '' "
	cQuery += " WHERE D2.D2_DOC = '" + SF2->F2_DOC + "' "
	cQuery += " AND D2.D2_SERIE  = '" + SF2->F2_SERIE  + "' "
	cQuery += " AND D2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "'"
	cQuery += " AND D2.D2_LOJA    = '" + SF2->F2_LOJA + "'"
	cQuery += " AND D2.D2_FILIAL  = '" + xFilial("SD2")  + "' "
	cQuery += " AND B1_CODSIMP <> '' AND B1_MSBLQL <> '1' "
	cQuery += " AND D2.D_E_L_E_T_ <> '*' "
	
	If Select("GERACD6") <> 0
		dbSelectArea("GERACD6")
		GERACD6->(dbCloseArea())
	Endif
		
	TCQuery cQuery NEW ALIAS "GERACD6" 

	aTamSX3:=TamSx3('CD6_FILIAL'); TCSetField("GERACD6",'D2_FILIAL' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_SERIE');  TCSetField("GERACD6",'D2_SERIE' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_DOC');    TCSetField("GERACD6",'D2_DOC' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_CLIFOR'); TCSetField("GERACD6",'D2_CLIENTE' ,"C",aTamSX3[1],aTamSX3[2]) 
	aTamSX3:=TamSx3('CD6_LOJA');   TCSetField("GERACD6",'D2_LOJA' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_COD');    TCSetField("GERACD6",'D2_COD' ,"C",aTamSX3[1],aTamSX3[2]) 
	aTamSX3:=TamSx3('CD6_ITEM');   TCSetField("GERACD6",'D2_ITEM' ,"C",aTamSX3[1],aTamSX3[2])
    ntamItem := aTamSX3[1]   
    
    	   
	GERACD6->(DbGotop())
	
    While GERACD6->(!eof())   
  
        Dbselectarea('CD6')
  	    CD6->(DbSetorder(1))// Filial + TIPOMOV + SERIE + DOC + CLIFOR + LOJA + ITEM + COD 
  
    	                                                                                                                   
    	//Verifica se não existe o Registro
    	If !DbSeek(GERACD6->D2_FILIAL + 'S' + GERACD6->D2_SERIE + GERACD6->D2_DOC + GERACD6->D2_CLIENTE + GERACD6->D2_LOJA + PADR(GERACD6->D2_ITEM,ntamItem) + alltrim(GERACD6->D2_COD) )
    	  
    		Reclock('CD6',.T.)		  
    		  
			  //Campos de Transmissão Obrigatória
			  CD6->CD6_FILIAL := GERACD6->D2_FILIAL
    		  CD6->CD6_TPMOV  := 'S'
    		  CD6->CD6_SERIE  := GERACD6->D2_SERIE
    		  CD6->CD6_DOC    := GERACD6->D2_DOC
    		  CD6->CD6_CLIFOR := GERACD6->D2_CLIENTE
    		  CD6->CD6_LOJA   := GERACD6->D2_LOJA
    		  CD6->CD6_ITEM   := GERACD6->D2_ITEM
    		  CD6->CD6_COD    := GERACD6->D2_COD
			  CD6->CD6_QTDE   := GERACD6->D2_QUANT
			  CD6->CD6_VOLUME := GERACD6->D2_QUANT
    		  CD6->CD6_UFCONS := IIF(alltrim(SF2->F2_EST)<> '',SF2->F2_EST,POSICIONE('SA1',1,xfilial('SA1')+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,'A1_EST'))  
			  CD6_PBRUTO	  := GERACD6->D2_PESO
    		  CD6_PLIQUI	  := GERACD6->D2_PESO
			  CD6->CD6_CODANP := GERACD6->B1_CODSIMP
			  IF !Empty(GERACD6->C0G_DESCRI) 
				CD6->CD6_DESANP := ALLTRIM(SUBSTRING(GERACD6->C0G_DESCRI,1,95))
			  ELSE
				CD6->CD6_DESANP := ALLTRIM(SUBSTRING(GERACD6->B1_DESC,1,95))
			  ENDIF
    		  
			  //Campos Extras
			  If lCodIf
			  	CD6->CD6_SEFAZ  := GERACD6->B1_CODIF 
    		  Endif
    		  CD6->CD6_ESPEC  := SF2->F2_ESPECIE
    		  CD6->CD6_TRANSP := SF2->F2_TRANSP 
    		  CD6->CD6_HORA   := SF2->F2_HORA
    		  CD6->CD6_PLACA  := SF2->F2_PLACA
        
    		  //DEMAIS CAMPOS
    		  //CD6->CD6_BCCIDE := 0 // Cobranca CIDE 
    		  //CD6->CD6_VALIQ  := 0 // ALIQUOTA CIDE 
    		  //CD6->CD6_VCIDE  := 0 // Valor CIDE    
    		  //CD6->CD6_MIXGN  := 0 //Perc Gas GLP
    		  //CD6->CD6_PASSE  := ""// Número do passe fiscal VER CONTABILIDADE
			  //CD6_VPART // Vlr. Partida
    		  //CD6_PGNI  // Perc. GLGNi  
    		  //CD6_PGLP  // Perc. GLP   
    		  //CD6_PGNN  // Perc. GLGNn 
    		  //CD6_QTAMB // QTDE FAT. TEMP. AMB.
    		  //CD6_TEMP
    		  //CD6_MOTOR
    		  //CD6_CPFMOT   
    		  //CD6_TANQUE
    		  //CD6_UFPLAC
    		  //CD6_QTAMB	  
    		CD6->(MsUnlock())
    	Endif            
    	
    	GERACD6->(dbskip())
    Enddo
                
    Restarea(_aarea)

Return

       
//Gera CD6 para notas de Entrada de DEVOLUÇÃO
User Function XAG0032E(xCD6MANUAL)

	Local cQuery 	:= ""
	Local _aarea    := Getarea()  
	Local ntamItem  := 4
	Local lCodIf    := .T.
	Default xCD6MANUAL := ""
	
	
	//Quando necessário executar manualmente a CD6
	If alltrim(xCD6MANUAL) <> ""
		Dbselectarea('SF1')
		Dbsetorder(1)
		dbseek(xfilial('SF1')+xCD6MANUAL  )
	Endif          
	
	
	//Valida se Existe o Campo de Codigo Simp na tabela de Produtos
	Dbselectarea('SB1')
	If SB1->(FieldPos("B1_CODSIMP")) <= 0 
		Return
	Endif 


	//Valida se Existe o Campo de Codigo Simp na tabela de Produtos
	Dbselectarea('SB1')
	If SB1->(FieldPos("B1_CODIF")) <= 0 
		lCodIf    := .F.
	Endif 
	
	//Valida se Existe o Campo de Codigo Simp na tabela C0G
	Dbselectarea('C0G')
	If C0G->(FieldPos("C0G_CODIGO")) <= 0  
		Return
	Endif
	
	//Valida se Existe o Campo de Codigo Simp na tabela CD6
	Dbselectarea('CD6')
	If CD6->(FieldPos("CD6_CODANP")) <= 0 .OR. CD6->(FieldPos("CD6_DESANP")) <= 0 
		Return
	Endif  
	
	cQuery := ""
	cQuery += " SELECT D1.*,B1_CODSIMP"/*,B1_CODANP"*/+IIF(lCodIf,",B1_CODIF","")/*,B1_CODIF*/+",B1_DESC,C0G_DESCRI "//D1_BASEICM,D1_VALICM,D1_FILIAL,D1_SERIE ,D1_DOC,D1_FORNECE,D1_LOJA ,D1_ITEM,D1_COD,D1_PICM,R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK) AS D1 "                                                                             
	cQuery += " INNER JOIN " + RetSqlName("SB1") + "(NOLOCK) AS B1 ON B1_COD = D1_COD AND B1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial('SB1')+"' " 
	cQuery += " LEFT  JOIN " + RetSqlName("C0G") + "(NOLOCK) AS C0G ON B1_CODSIMP = C0G_CODIGO AND C0G.D_E_L_E_T_ = '' "
	cQuery += " WHERE D1.D1_DOC = '" + SF1->F1_DOC + "' "
	cQuery += " AND D1.D1_SERIE  = '" + SF1->F1_SERIE  + "' "
	cQuery += " AND D1.D1_FORNECE = '" + SF1->F1_FORNECE + "'"
	cQuery += " AND D1.D1_LOJA    = '" + SF1->F1_LOJA + "'"
	cQuery += " AND D1.D1_FILIAL  = '" + xFilial("SD1")  + "' "
	cQuery += " AND B1_CODSIMP <> '' AND B1_MSBLQL <> '1' "
	cQuery += " AND D1.D_E_L_E_T_ <> '*' "
	
	If Select("GERACD6") <> 0
		dbSelectArea("GERACD6")
		GERACD6->(dbCloseArea())
	Endif
		
	TCQuery cQuery NEW ALIAS "GERACD6" 

	aTamSX3:=TamSx3('CD6_FILIAL'); TCSetField("GERACD6",'D1_FILIAL' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_SERIE');  TCSetField("GERACD6",'D1_SERIE' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_DOC');    TCSetField("GERACD6",'D1_DOC' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_CLIFOR'); TCSetField("GERACD6",'D1_FORNECE' ,"C",aTamSX3[1],aTamSX3[2]) 
	aTamSX3:=TamSx3('CD6_LOJA');   TCSetField("GERACD6",'D1_LOJA' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_COD');    TCSetField("GERACD6",'D1_COD' ,"C",aTamSX3[1],aTamSX3[2]) 
	aTamSX3:=TamSx3('CD6_ITEM');   TCSetField("GERACD6",'D1_ITEM' ,"C",aTamSX3[1],aTamSX3[2])
    ntamItem := aTamSX3[1]   
    
    	   
	GERACD6->(DbGotop())
	
    While GERACD6->(!eof())   
  
        Dbselectarea('CD6')
  	    CD6->(DbSetorder(1))// Filial + TIPOMOV + SERIE + DOC + CLIFOR + LOJA + ITEM + COD 
  
    	                                                                                                                   
    	//Verifica se não existe o Registro
    	If !DbSeek(GERACD6->D1_FILIAL + 'E' + GERACD6->D1_SERIE + GERACD6->D1_DOC + GERACD6->D1_FORNECE + GERACD6->D1_LOJA + PADR(GERACD6->D1_ITEM,ntamItem) + alltrim(GERACD6->D1_COD) )
    	  
    		Reclock('CD6',.T.)		  
    		  
			  //Campos de Transmissão Obrigatória
			  CD6->CD6_FILIAL := GERACD6->D1_FILIAL
    		  CD6->CD6_TPMOV  := 'E'
    		  CD6->CD6_SERIE  := GERACD6->D1_SERIE
    		  CD6->CD6_DOC    := GERACD6->D1_DOC
    		  CD6->CD6_CLIFOR := GERACD6->D1_FORNECE
    		  CD6->CD6_LOJA   := GERACD6->D1_LOJA
    		  CD6->CD6_ITEM   := GERACD6->D1_ITEM
    		  CD6->CD6_COD    := GERACD6->D1_COD
			  CD6->CD6_QTDE   := GERACD6->D1_QUANT
			  CD6->CD6_VOLUME := GERACD6->D1_QUANT
    		  CD6->CD6_UFCONS := IIF(alltrim(SF1->F1_EST)<> '',SF1->F1_EST,POSICIONE('SA2',1,xfilial('SA2')+GERACD6->D1_FORNECE+GERACD6->D1_LOJA,'A2_EST'))   
			  CD6_PBRUTO	  := GERACD6->D1_PESO
    		  CD6_PLIQUI	  := GERACD6->D1_PESO
			  CD6->CD6_CODANP := GERACD6->B1_CODSIMP
			  IF !Empty(GERACD6->C0G_DESCRI) 
				CD6->CD6_DESANP := ALLTRIM(SUBSTRING(GERACD6->C0G_DESCRI,1,95))
			  ELSE
				CD6->CD6_DESANP := ALLTRIM(SUBSTRING(GERACD6->B1_DESC,1,95))
			  ENDIF
    		  
			  //Campos Extras
			  If lCodIf
			  	CD6->CD6_SEFAZ  := GERACD6->B1_CODIF 
    		  Endif
    		  CD6->CD6_ESPEC  := SF1->F1_ESPECIE
    		  CD6->CD6_TRANSP := SF1->F1_TRANSP 
    		  CD6->CD6_HORA   := SF1->F1_HORA
    		  CD6->CD6_PLACA  := SF1->F1_PLACA
        
    		  //DEMAIS CAMPOS
    		  //CD6->CD6_BCCIDE := 0 // Cobranca CIDE 
    		  //CD6->CD6_VALIQ  := 0 // ALIQUOTA CIDE 
    		  //CD6->CD6_VCIDE  := 0 // Valor CIDE    
    		  //CD6->CD6_MIXGN  := 0 //Perc Gas GLP
    		  //CD6->CD6_PASSE  := ""// Número do passe fiscal VER CONTABILIDADE
			  //CD6_VPART // Vlr. Partida
    		  //CD6_PGNI  // Perc. GLGNi  
    		  //CD6_PGLP  // Perc. GLP   
    		  //CD6_PGNN  // Perc. GLGNn 
    		  //CD6_QTAMB // QTDE FAT. TEMP. AMB.
    		  //CD6_TEMP
    		  //CD6_MOTOR
    		  //CD6_CPFMOT   
    		  //CD6_TANQUE
    		  //CD6_UFPLAC
    		  //CD6_QTAMB	  
    		CD6->(MsUnlock())
    	Endif            
    	
    	GERACD6->(dbskip())
    Enddo
                
    Restarea(_aarea)

Return