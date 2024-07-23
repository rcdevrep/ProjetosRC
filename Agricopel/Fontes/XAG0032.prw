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
	Local cEst      := ""
	Local cEstE     := ""
	Local cTipo     := ""
	Local cUfCons   := ""
	Local cTipProd  := ""
	Local _cUfE     := ""
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
	cQuery += " SELECT D2.*,B1_CODSIMP"/*,B1_CODSIMP"*/+IIF(lCodIf,",B1_CODIF","")/*,B1_CODIF*/+",B1_DESC,C0G_DESCRI,B1_ORIGEM,B1_PESO"//D2_BASEICM,D2_VALICM,D2_FILIAL,D2_SERIE ,D2_DOC,D2_CLIENTE,D2_LOJA ,D2_ITEM,D2_COD,D2_PICM,R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SD2") + " (NOLOCK) AS D2 "                                                                             
	cQuery += " INNER JOIN " + RetSqlName("SB1") + "(NOLOCK) AS B1 ON B1_FILIAL = D2_FILIAL AND B1_COD = D2_COD AND B1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial('SB1')+"' " 
	cQuery += " LEFT  JOIN " + RetSqlName("C0G") + "(NOLOCK) AS C0G ON B1_CODSIMP = C0G_CODIGO AND C0G.D_E_L_E_T_ = '' AND (C0G_VALIDA >= '"+dtos(ddatabase)+"' OR C0G_VALIDA = '')  "
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

	aTamSX3:=TamSx3('CD6_FILIAL')//TCSetField("GERACD6",'D2_FILIAL' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_SERIE')//TCSetField("GERACD6",'D2_SERIE' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_DOC')//TCSetField("GERACD6",'D2_DOC' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_CLIFOR')//TCSetField("GERACD6",'D2_CLIENTE' ,"C",aTamSX3[1],aTamSX3[2]) 
	aTamSX3:=TamSx3('CD6_LOJA')//TCSetField("GERACD6",'D2_LOJA' ,"C",aTamSX3[1],aTamSX3[2])
	aTamSX3:=TamSx3('CD6_COD')//TCSetField("GERACD6",'D2_COD' ,"C",aTamSX3[1],aTamSX3[2]) 
	aTamSX3:=TamSx3('CD6_ITEM')//TCSetField("GERACD6",'D2_ITEM' ,"C",aTamSX3[1],aTamSX3[2])
    ntamItem := aTamSX3[1]   
    
    	   
	GERACD6->(DbGotop())
	
    While GERACD6->(!eof())   

		nFator61 := 1.0635//0.9456

		//Grava dados na tabela CD2 - Paliativo para atender  NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023
		If alltrim(GERACD6->D2_CLASFIS) =='061'
			cUpd61 := " UPDATE "+RetSqlname('CD2')+" SET CD2_ALIQ = "+cValtochar(nFator61)+", CD2_VLTRIB = "+cValtochar(GERACD6->D2_QUANT * nFator61)+",CD2_BC = "+cValtochar(GERACD6->D2_QUANT)+" "
			cUpd61 += " WHERE CD2_FILIAL = '"+GERACD6->D2_FILIAL+"' AND CD2_TPMOV = 'S' AND CD2_DOC = '"+GERACD6->D2_DOC+"' AND CD2_SERIE =  '"+GERACD6->D2_SERIE+"'  "
			cUpd61 += " AND CD2_CODCLI = '"+GERACD6->D2_CLIENTE+"' AND CD2_LOJCLI = '"+GERACD6->D2_LOJA+"' AND CD2_ITEM = '"+GERACD6->D2_ITEM+"' AND CD2_IMP = 'ICM'   "
			cUpd61 += " AND D_E_L_E_T_ = ''  "

			If (TcSqlExec(cUpd61) < 0)
				MsgStop("TCSQLError() " + TCSQLError())
				Return(.F.)
			EndIf
		Endif 


        Dbselectarea('CD6')
  	    CD6->(DbSetorder(1))// Filial + TIPOMOV + SERIE + DOC + CLIFOR + LOJA + ITEM + COD 

		/*If CD6->(FieldPos("CD6_TPCOM")) > 0 
			lCD6_TPCOM := .T.
		else
			lCD6_TPCOM := .F.	
		Endif */
		  
    	                                                                                                                   
    	//Verifica se não existe o Registro
    	If !DbSeek(GERACD6->D2_FILIAL + 'S' + GERACD6->D2_SERIE + GERACD6->D2_DOC + GERACD6->D2_CLIENTE + GERACD6->D2_LOJA + PADR(GERACD6->D2_ITEM,ntamItem) + alltrim(GERACD6->D2_COD) )
 

	      
	        //Chamado 232002 - Verificar situação de venda para cliente no estado SC e manda entregar em estado diferente de SC. 
    	 	cEst:=     Posicione("SA1",1,xFilial("SA1")+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,"A1_EST") 
    	 	cEstE:=    Posicione("SA1",1,xFilial("SA1")+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,"A1_ESTE")
         	cTipo:=    Posicione("SA1",1,xFilial("SA1")+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,"A1_TIPO")
            cUfCons:=  IIF(alltrim(SF2->F2_EST)<> '',SF2->F2_EST,POSICIONE('SA1',1,xfilial('SA1')+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,'A1_EST'))  

    	 	If ( (cEmpAnt == '01' .And. cFilAnt $ '03/16') .OR. cEmpant $ '15') //.and. (cEst <> cEstE)

				cTipProd:= Posicione("SB1",1,xFilial("SB1")+GERACD6->D2_COD,"B1_TIPO") 

				If cTipProd $ "CO/LU/SH" .AND. cTipo <> "R" 

					//Verifica se tem atendimento
					_cUfE := Posicione('SUA',8,xfilial('SUA') + GERACD6->D2_PEDIDO, 'UA_ESTE')

					If Empty(_cUfE)
						dbSelectarea('SC5')
						dbSetOrder(1)
						
						If GERACD6->D2_PEDIDO <> SC5->C5_NUM 
							dbseek('SC5',1,xFilial('SC5') + GERACD6->D2_PEDIDO)							
						Endif 

						_cUfE := SC5->C5_ESTE
						
					Endif 

					If !Empty(_cUfE)
						cUfCons := _cUfE
					else
					    If Alltrim(cEstE) <> ''  // SM0->M0_ESTCOB <> cEstE   chamado 281074
            	    		cUfCons:= cEstE    
         	      		Endif
					Endif 
          	   Endif    
    	 	Endif
    	 	
    	 	If cEmpant $ '44' .and. (cEst <> cEstE)
	
	    	   cTipProd:= Posicione("SB1",1,xFilial("SB1")+GERACD6->D2_COD,"B1_TIPO") 
    
			   If cTipProd $ "CO/LU/SH" .AND. cTipo <> "R" 

        	      If SM0->M0_ESTCOB == cEstE
    
            	     cUfCons:= cEstE
    
         	      Endif
     
          	   Endif    
  
      	    Endif
 
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
    		  CD6->CD6_UFCONS := cUfCons  //IIF(alltrim(SF2->F2_EST)<> '',SF2->F2_EST,POSICIONE('SA1',1,xfilial('SA1')+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,'A1_EST'))  
			  CD6_PBRUTO	  := iif( GERACD6->D2_PESO == 0  , GERACD6->B1_PESO , GERACD6->D2_PESO )
    		  CD6_PLIQUI	  := iif( GERACD6->D2_PESO == 0  , GERACD6->B1_PESO , GERACD6->D2_PESO ) 
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
			  //Grava dados na tabela CD2 - Paliativo para atender  NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
			  If alltrim(GERACD6->B1_CODSIMP) $ '210203001,210203003,210203004,210203005,420102004,420102005,420105001,420201001,420201003,420301002,820101001,820101012,820101013,820101033,820101034'
				  If dtos(SF2->F2_EMISSAO) < '20240301'
				  	CD6->CD6_PBIO  := 12
			      Else
					CD6->CD6_PBIO  := 14
				  Endif 		
				  //Campos novos
				  CD6->CD6_VALIQ  := 1.0635//0.9456 // ALIQUOTA CIDE 
				  //CD6_UFCONS := SF2->F2_EST //SA2->A2_EST
				  CD6_INDIMP := GERACD6->B1_ORIGEM
				  CD6_UFORIG := SM0->M0_ESTENT 
				  CD6_PORIG = 100
			   Endif 

			   //Diesel Maritimo 
			   /*If lCD6_TPCOM
					If alltrim(GERACD6->B1_CODSIMP) == '420201001'
						CD6_TPCOM := 'P'
					Else
						CD6_TPCOM := 'M'
					Endif
			   Endif */
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

       
//Gera CD6 para notas de Entrada e DEVOLUÇÃO
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
	cQuery += " SELECT D1.*,B1_CODSIMP"+IIF(lCodIf,",B1_CODIF","")/*,B1_CODIF*/+",B1_DESC,C0G_DESCRI,B1_ORIGEM,B1_PESO "//D1_BASEICM,D1_VALICM,D1_FILIAL,D1_SERIE ,D1_DOC,D1_FORNECE,D1_LOJA ,D1_ITEM,D1_COD,D1_PICM,R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK) AS D1 "                                                                             
	cQuery += " INNER JOIN " + RetSqlName("SB1") + "(NOLOCK) AS B1 ON B1_FILIAL = D1_FILIAL AND B1_COD = D1_COD AND B1.D_E_L_E_T_ = ''  " 
	cQuery += " LEFT  JOIN " + RetSqlName("C0G") + "(NOLOCK) AS C0G ON B1_CODSIMP = C0G_CODIGO AND C0G.D_E_L_E_T_ = '' AND (C0G_VALIDA >= '"+dtos(ddatabase)+"' OR C0G_VALIDA = '') "
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
		
		If CD6->(FieldPos("CD6_TPCOM")) > 0 
			lCD6_TPCOM := .T.
		else
			lCD6_TPCOM := .F.	
		Endif 
  
    	                                                                                                                   
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
			  CD6_PBRUTO	  := iif( GERACD6->D1_PESO == 0  , GERACD6->B1_PESO , GERACD6->D1_PESO )
			  CD6_PLIQUI	  := iif( GERACD6->D1_PESO == 0  , GERACD6->B1_PESO , GERACD6->D1_PESO )
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

			  //Grava dados na tabela CD2 - Paliativo para atender  NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
			  If alltrim(GERACD6->B1_CODSIMP) $ '210203001,210203003,210203004,210203005,420102004,420102005,420105001,420201001,420201003,420301002,820101001,820101012,820101013,820101033,820101034'
	
				//Campos novos
				If dtos(SF1->F1_EMISSAO) < '20240301'
					CD6->CD6_PBIO  := 12
				Else
					CD6->CD6_PBIO  := 14
				Endif 
				CD6->CD6_VALIQ  := 1.0635//0.9456 // ALIQUOTA CIDE 
				CD6_UFCONS := SM0->M0_ESTENT //SA2->A2_EST
				CD6_INDIMP := GERACD6->B1_ORIGEM
				CD6_UFORIG := SF1->F1_EST
				CD6_PORIG = 100
			  Endif 

			     //Diesel Maritimo 
			   If lCD6_TPCOM
					If alltrim(GERACD6->B1_CODSIMP) == '420201001'
						CD6_TPCOM := 'P'
					Else
						CD6_TPCOM := 'M'
					Endif
			   Endif 
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


//Geração MANUAL da TABELA CD6 para notas que não possuem por
//se tratar de uma função de ajuste não foi colocada no menu
//chamar atraves de formulas
User Function XAG0032x()

	Local cQuery 	:= ""
	Local _aarea    := Getarea()  
	Local ntamItem  := 4
	Local lCodIf    := .T.
    Local aPergs    := {} 
    Local  aRet     := {}
	Local  _dDatade  
    Local  _dDataate 
    Local  _cDocDe   
    Local  _cDocAte 
	Local _cTipo  := ""

    Private aCab    := {}

	aAdd( aPergs ,{1,"Data de: "  ,Ctod(Space(8)),"","","","",50,.T.}) 
	aAdd( aPergs ,{1,"Data ate: " ,Ctod(Space(8)),"","","","",50,.T.}) 
	aAdd( aPergs ,{1,"Documento de:",Space(9),"@",'.T.','','.T.',50,.F.})  
	aAdd( aPergs ,{1,"Documento ate:",Space(9),"@",'.T.','','.T.',50,.T.})  
	aAdd( aPergs  ,{2, "Tipo de Movimentação?","", {"A=Ambas","E=Entrada", "S=Saida"},    80, ".T.", .F.})// MV_PAR05


    If ParamBox(aPergs ,"Parâmetros",aRet) 
        _dDatade  := aRet[1]
        _dDataate := aRet[2]
        _cDocDe   := aRet[3]
        _cDocAte  := aRet[4]
		_cTipo    := aRet[5]
	else
		Return
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


	//Entradas 
	If _cTipo == 'A' .OR. _cTipo == 'E'

		cQuery := " SELECT D1_ITEM,D1.*,B1_CODSIMP"+IIF(lCodIf,",B1_CODIF","")+",B1_DESC,C0G_DESCRI, D1_BASEICM,D1_VALICM,D1_FILIAL,D1_SERIE ,D1_DOC,D1_FORNECE,D1_LOJA ,D1_ITEM,D1_COD,D1_PICM,D1_ORIIMP,B1_PESO  "
		cQuery += " FROM  	    " + RetSqlName("SD1") + " (NOLOCK) AS D1 "  
		cQuery += " INNER JOIN  " + RetSqlName("SF1") + " (NOLOCK) AS F1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND F1.D_E_L_E_T_ = ''  "                                                                           
		cQuery += " INNER JOIN  " + RetSqlName("SB1") + " (NOLOCK) AS B1 ON B1_FILIAL = D1_FILIAL AND B1_COD = D1_COD AND B1.D_E_L_E_T_ = ''  " 
		cQuery += " INNER JOIN  " + RetSqlName("SA2") + " (NOLOCK) AS A2 ON A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND A2.D_E_L_E_T_ = ''  " 
		cQuery += " LEFT  JOIN  " + RetSqlName("C0G") + " (NOLOCK) AS C0G ON B1_CODSIMP = C0G_CODIGO AND C0G.D_E_L_E_T_ = '' AND (C0G_VALIDA >= '"+dtos(_dDataate)+"' OR C0G_VALIDA = '') "
		//cQuery += " INNER JOIN  " + RetSqlName("SB1") + " (NOLOCK) AS B1 ON B1_FILIAL = D1_FILIAL AND B1_COD = D1_COD AND B1.D_E_L_E_T_ = ''  " 
		cQuery += " WHERE "
		cQuery += " 	D1_DTDIGIT BETWEEN '"+dtos(_dDatade)+"' AND '"+dtos(_dDataate)+"' AND D1.D_E_L_E_T_ = '' "
		cQuery += " 	AND D1_DOC BETWEEN '"+_cDocDe+"' AND '"+_cDocAte+"' AND D1.D_E_L_E_T_ = '' "
		cQuery += " 	AND B1_CODSIMP <> '' AND B1_MSBLQL <> '1' "
		cQuery += " 	AND D1_FILIAL = '"+xfilial('SD1')+"' "
		cQuery += " 	AND D1_TIPO <> 'C' "
		cQuery += " AND ( "
		cQuery += " SELECT COUNT(CD6_DOC) FROM " + RetSqlName("CD6") + " (NOLOCK)  "
		cQuery += " 	WHERE CD6_FILIAL = D1_FILIAL AND "
		cQuery += " 			CD6_DOC = D1_DOC AND "
		cQuery += " 			CD6_SERIE = D1_SERIE AND CD6_TPMOV = 'E' AND "
		cQuery += " 			CD6_CLIFOR = D1_FORNECE AND "
		cQuery += " 			CD6_LOJA  = D1_LOJA AND "
		cQuery += " 			D_E_L_E_T_ = '' "
		cQuery += " 	) = 0 "
		
		
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

			If CD6->(FieldPos("CD6_TPCOM")) > 0 .AND. _cTipo == 'E'
				lCD6_TPCOM := .T.
			else
				lCD6_TPCOM := .F.	
			Endif 
	
																															
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
				CD6_PBRUTO	  := iif( GERACD6->D1_PESO == 0  , GERACD6->B1_PESO , GERACD6->D1_PESO )
				CD6_PLIQUI	  := iif( GERACD6->D1_PESO == 0  , GERACD6->B1_PESO , GERACD6->D1_PESO )
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

				//Grava dados na tabela CD2 - Paliativo para atender  NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
				If alltrim(GERACD6->B1_CODSIMP) $ '210203001,210203003,210203004,210203005,420102004,420102005,420105001,420201001,420201003,420301002,820101001,820101012,820101013,820101033,820101034'
					If dtos(SF1->F1_EMISSAO) < '20240301'
						CD6->CD6_PBIO  := 12
					Else
						CD6->CD6_PBIO  := 14
					Endif 	
					//Campos novos
					CD6->CD6_VALIQ  := 1.0635//0.9456 // ALIQUOTA CIDE 
					CD6_UFCONS := SM0->M0_ESTENT //SA2->A2_EST
					CD6_INDIMP := GERACD6->B1_ORIGEM
					CD6_UFORIG := SF1->F1_EST
					CD6_PORIG = 100
				Endif 

				   //Diesel Maritimo 
			   If lCD6_TPCOM
					If alltrim(GERACD6->B1_CODSIMP) == '420201001'
						CD6_TPCOM := 'P'
					Else
						CD6_TPCOM := 'M'
					Endif
			   Endif 
				//DEMAIS CAMPOS
				//CD6->CD6_BCCIDE := 0 // Cobranca CIDE 
				
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
	Endif 

	//Saídas 
	If _cTipo == 'A' .OR. _cTipo == 'S'


		cQuery := ""
		cQuery += " SELECT D2.*,B1_CODSIMP"/*,B1_CODSIMP"*/+IIF(lCodIf,",B1_CODIF","")/*,B1_CODIF*/+",B1_DESC,C0G_DESCRI,B1_PESO "//D2_BASEICM,D2_VALICM,D2_FILIAL,D2_SERIE ,D2_DOC,D2_CLIENTE,D2_LOJA ,D2_ITEM,D2_COD,D2_PICM,R_E_C_N_O_ "
		cQuery += " FROM " + RetSqlName("SD2") + " (NOLOCK) AS D2 "                                                                             
		cQuery += " INNER JOIN " + RetSqlName("SF2") + " (NOLOCK) AS F2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND F2.D_E_L_E_T_ = ''  "                                                                           "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK) AS B1 ON B1_FILIAL = D2_FILIAL AND B1_COD = D2_COD AND B1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial('SB1')+"' " 
		cQuery += " INNER JOIN " + RetSqlName("SA1") + " (NOLOCK) AS A1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1.D_E_L_E_T_ = ''  " 
		cQuery += " LEFT  JOIN " + RetSqlName("C0G") + " (NOLOCK) AS C0G ON B1_CODSIMP = C0G_CODIGO AND C0G.D_E_L_E_T_ = '' "	
		cQuery += " WHERE "
		cQuery += " 	D2_EMISSAO BETWEEN '"+dtos(_dDatade)+"' AND '"+dtos(_dDataate)+"' "
		cQuery += " 	AND D2_DOC BETWEEN '"+_cDocDe+"' AND '"+_cDocAte+"' AND D2.D_E_L_E_T_ = '' "
		cQuery += " 	AND B1_CODSIMP <> '' AND B1_MSBLQL <> '1' "
		cQuery += " 	AND D2_FILIAL = '"+xfilial('SD2')+"' "
		cQuery += " 	AND D2_TIPO <> 'C' "
		cQuery += " AND ( "
		cQuery += " SELECT COUNT(CD6_DOC) FROM " + RetSqlName("CD6") + " (NOLOCK)  "
		cQuery += " 	WHERE CD6_FILIAL = D2_FILIAL AND "
		cQuery += " 			CD6_DOC = D2_DOC AND "
		cQuery += " 			CD6_SERIE = D2_SERIE AND CD6_TPMOV = 'S' AND "
		cQuery += " 			CD6_CLIFOR = D2_CLIENTE AND "
		cQuery += " 			CD6_LOJA  = D2_LOJA AND "
		cQuery += " 			D_E_L_E_T_ = '' "
		cQuery += " 	) = 0 "
		
		If Select("GERACD6") <> 0
			dbSelectArea("GERACD6")
			GERACD6->(dbCloseArea())
		Endif
			
		TCQuery cQuery NEW ALIAS "GERACD6" 

		aTamSX3:=TamSx3('CD6_FILIAL')//TCSetField("GERACD6",'D2_FILIAL' ,"C",aTamSX3[1],aTamSX3[2])
		aTamSX3:=TamSx3('CD6_SERIE')//TCSetField("GERACD6",'D2_SERIE' ,"C",aTamSX3[1],aTamSX3[2])
		aTamSX3:=TamSx3('CD6_DOC')//TCSetField("GERACD6",'D2_DOC' ,"C",aTamSX3[1],aTamSX3[2])
		aTamSX3:=TamSx3('CD6_CLIFOR')//TCSetField("GERACD6",'D2_CLIENTE' ,"C",aTamSX3[1],aTamSX3[2]) 
		aTamSX3:=TamSx3('CD6_LOJA')//TCSetField("GERACD6",'D2_LOJA' ,"C",aTamSX3[1],aTamSX3[2])
		aTamSX3:=TamSx3('CD6_COD')//TCSetField("GERACD6",'D2_COD' ,"C",aTamSX3[1],aTamSX3[2]) 
		aTamSX3:=TamSx3('CD6_ITEM')//TCSetField("GERACD6",'D2_ITEM' ,"C",aTamSX3[1],aTamSX3[2])
		ntamItem := aTamSX3[1]   
		
			
		GERACD6->(DbGotop())
		
		While GERACD6->(!eof())   

			nFator61 := 1.0635//0.9456

			//Grava dados na tabela CD2 - Paliativo para atender  NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023
			If alltrim(GERACD6->D2_CLASFIS) =='061'
				cUpd61 := " UPDATE "+RetSqlname('CD2')+" SET CD2_ALIQ = "+cValtochar(nFator61)+", CD2_VLTRIB = "+cValtochar(GERACD6->D2_QUANT * nFator61)+",CD2_BC = "+cValtochar(GERACD6->D2_QUANT)+" "
				cUpd61 += " WHERE CD2_FILIAL = '"+GERACD6->D2_FILIAL+"' AND CD2_TPMOV = 'S' AND CD2_DOC = '"+GERACD6->D2_DOC+"' AND CD2_SERIE =  '"+GERACD6->D2_SERIE+"'  "
				cUpd61 += " AND CD2_CODCLI = '"+GERACD6->D2_CLIENTE+"' AND CD2_LOJCLI = '"+GERACD6->D2_LOJA+"' AND CD2_ITEM = '"+GERACD6->D2_ITEM+"' AND CD2_IMP = 'ICM'   "
				cUpd61 += " AND D_E_L_E_T_ = ''  "

				If (TcSqlExec(cUpd61) < 0)
					MsgStop("TCSQLError() " + TCSQLError())
					Return(.F.)
				EndIf
			Endif 


			Dbselectarea('CD6')
			CD6->(DbSetorder(1))// Filial + TIPOMOV + SERIE + DOC + CLIFOR + LOJA + ITEM + COD 

			/*If CD6->(FieldPos("CD6_TPCOM")) > 0 
				lCD6_TPCOM := .T.
			else
				lCD6_TPCOM := .F.	
			Endif */
			
	
																															
			//Verifica se não existe o Registro
			If !DbSeek(GERACD6->D2_FILIAL + 'S' + GERACD6->D2_SERIE + GERACD6->D2_DOC + GERACD6->D2_CLIENTE + GERACD6->D2_LOJA + PADR(GERACD6->D2_ITEM,ntamItem) + alltrim(GERACD6->D2_COD) )
	
			
				//Chamado 232002 - Verificar situação de venda para cliente no estado SC e manda entregar em estado diferente de SC. 
				cEst:=     Posicione("SA1",1,xFilial("SA1")+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,"A1_EST") 
				cEstE:=    Posicione("SA1",1,xFilial("SA1")+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,"A1_ESTE")
				cTipo:=    Posicione("SA1",1,xFilial("SA1")+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,"A1_TIPO")
				cUfCons:=  IIF(alltrim(SF2->F2_EST)<> '',SF2->F2_EST,POSICIONE('SA1',1,xfilial('SA1')+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,'A1_EST'))  

				If ( (cEmpAnt == '01' .And. cFilAnt == '03') .OR. cEmpant $ '11/15') .and. (cEst <> cEstE)
		
				cTipProd:= Posicione("SB1",1,xFilial("SB1")+GERACD6->D2_COD,"B1_TIPO") 
		
				If cTipProd $ "CO/LU/SH" .AND. cTipo <> "R" 

					If Alltrim(cEstE) <> ''  // SM0->M0_ESTCOB <> cEstE   chamado 281074
						cUfCons:= cEstE    
					Endif
		
				Endif    
	
				Endif
				
				If cEmpant $ '44' .and. (cEst <> cEstE)
		
				cTipProd:= Posicione("SB1",1,xFilial("SB1")+GERACD6->D2_COD,"B1_TIPO") 
		
				If cTipProd $ "CO/LU/SH" .AND. cTipo <> "R" 

					If SM0->M0_ESTCOB == cEstE
		
						cUfCons:= cEstE
		
					Endif
		
				Endif    
	
				Endif
	
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
				CD6->CD6_UFCONS := cUfCons  //IIF(alltrim(SF2->F2_EST)<> '',SF2->F2_EST,POSICIONE('SA1',1,xfilial('SA1')+GERACD6->D2_CLIENTE+GERACD6->D2_LOJA,'A1_EST'))  
				CD6_PBRUTO	  := iif( GERACD6->D2_PESO == 0  , GERACD6->B1_PESO , GERACD6->D2_PESO )
				CD6_PLIQUI	  := iif( GERACD6->D2_PESO == 0  , GERACD6->B1_PESO , GERACD6->D2_PESO )
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
				//Grava dados na tabela CD2 - Paliativo para atender  NT -Tributação Monofásica sobre Combustíveis  de 01/05/2023	
				If alltrim(GERACD6->B1_CODSIMP) $ '210203001,210203003,210203004,210203005,420102004,420102005,420105001,420201001,420201003,420301002,820101001,820101012,820101013,820101033,820101034'
					If dtos(SF2->F2_EMISSAO) < '20240301'
						CD6->CD6_PBIO  := 12
					Else
						CD6->CD6_PBIO  := 14
					Endif 
				Endif 

				//Campos novos
				CD6->CD6_VALIQ  := 1.0635//0.9456 // ALIQUOTA CIDE 
				CD6_UFCONS := SF2->F2_EST //SA2->A2_EST
				CD6_INDIMP := GERACD6->B1_ORIGEM
				CD6_UFORIG := SM0->M0_ESTENT
				CD6_PORIG = 100

				   //Diesel Maritimo 
			    /*If lCD6_TPCOM
					If alltrim(GERACD6->B1_CODSIMP) == '420201001'
						CD6_TPCOM := 'P'
					Else
						CD6_TPCOM := 'M'
					Endif
			    Endif */
			

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

	Endif 

	//Roda Ajustes 
	//-- UPDATE NAS SAÍDAS 
		/*SELECT 
		CD6_PBIO, --12
		CD6_VALIQ, --0.9456 
		CD6_UFCONS, --ENTRADA SM0 / SAIDA UF DO CLIENTE
		CD6_INDIMP, --B1_ORIGEM
		CD6_UFORIG,--ENTRADA UF FORNECEDOR / SAIDA SM0 
		CD6_PORIG, --100,
		'UPDATE CD6010 SET CD6_PBIO = 12,CD6_VALIQ = 0.9456, '+
		'CD6_UFCONS = '''+F2_EST+''''+', CD6_INDIMP = '''+B1_ORIGEM+''','+
		'CD6_UFORIG = '''+EMP_ESTADO+''', CD6_PORIG = 100 WHERE R_E_C_N_O_ = '+CAST(CD6010.R_E_C_N_O_ AS varchar(18)) ,
		* FROM CD6010(NOLOCK)
		//--INNER  JOIN SA1010(NOLOCK) ON A1_COD = CD6_CLIFOR AND A1_LOJA = 
		//--CD6_LOJA AND SA1010.D_E_L_E_T_ = ''
		INNER JOIN SF2010(NOLOCK) ON F2_FILIAL = CD6_FILIAL AND 
		F2_DOC = CD6_DOC AND CD6_CLIFOR = F2_CLIENTE AND F2_LOJA = CD6_LOJA AND 
		F2_SERIE = CD6_SERIE AND SF2010.D_E_L_E_T_ = '' AND 
		F2_EMISSAO between  '20230601' AND '20230630'
		INNER JOIN SB1010(NOLOCK) ON B1_FILIAL = CD6_FILIAL AND B1_COD = CD6_COD 
		and SB1010.D_E_L_E_T_ = ''
		INNER JOIN EMPRESAS ON EMP_COD = '01' AND EMP_FIL = F2_FILIAL  
		WHERE  CD6010.D_E_L_E_T_ = '' AND CD6_TPMOV = 'S' AND F2_FILIAL = '16' */


	//-- UPDATE NAS ENTRADAS 
		/*SELECT 
		CD6_PBIO, --12
		CD6_VALIQ, --0.9456 
		CD6_UFCONS, --ENTRADA SM0 / SAIDA UF DO CLIENTE
		CD6_INDIMP, --B1_ORIGEM
		CD6_UFORIG,--ENTRADA UF FORNECEDOR / SAIDA SM0 
		CD6_PORIG, --100,
		'UPDATE CD6010 SET CD6_PBIO = 12,CD6_VALIQ = 0.9456, '+
		'CD6_UFCONS = '''+EMP_ESTADO+''''+', CD6_INDIMP = '''+B1_ORIGEM+''','+
		'CD6_UFORIG = '''+F1_EST+''''+', CD6_PORIG = 100 WHERE R_E_C_N_O_ = '+CAST(CD6010.R_E_C_N_O_ AS varchar(18)),
		* FROM CD6010(NOLOCK)
		//--INNER  JOIN SA2010(NOLOCK) ON A2_COD = CD6_CLIFOR AND A2_LOJA = 
		//--CD6_LOJA AND SA2010.D_E_L_E_T_ = ''
		INNER JOIN SF1010(NOLOCK) ON F1_FILIAL = CD6_FILIAL AND 
		F1_DOC = CD6_DOC AND F1_SERIE = CD6_SERIE AND SF1010.D_E_L_E_T_ = '' 
		AND CD6_CLIFOR = F1_FORNECE AND CD6_LOJA = F1_LOJA AND F1_DTDIGIT  between  '20230601' AND '20230630'
		INNER JOIN SB1010(NOLOCK) ON B1_FILIAL = CD6_FILIAL AND B1_COD = CD6_COD 
		and SB1010.D_E_L_E_T_ = ''
		INNER JOIN EMPRESAS ON EMP_COD = '01' AND EMP_FIL = F1_FILIAL  
		WHERE  CD6010.D_E_L_E_T_ = '' AND CD6_TPMOV = 'E' AND F1_FILIAL = '16'*/


	//-- UPDATE PESO
		/*SELECT 
		'UPDATE CD6010 SET CD6_PLIQUI = ' + CAST(B1_PESO  AS varchar(10))+ ' , CD6_PBRUTO = ' + CAST(B1_PESO  AS varchar(10))+
		' WHERE R_E_C_N_O_ =  '+CAST(CD6010.R_E_C_N_O_ AS varchar(18)),B1_PESO,
		* FROM CD6010(NOLOCK)
		INNER JOIN SB1010(NOLOCK) ON B1_FILIAL = CD6_FILIAL  AND CD6_COD = B1_COD 
		AND SB1010.D_E_L_E_T_ = ''
		WHERE (CD6_PLIQUI = 0 OR CD6_PBRUTO = 0 )  AND CD6010.D_E_L_E_T_ = '' AND B1_PESO > 0  and CD6_FILIAL = '16'*/


	//-- UPDATE PESOB 
		/*SELECT SB1010.*,B1_PESOB,
		'UPDATE CD6010 SET CD6_PLIQUI = ' + CAST(B1_PESOB  AS varchar(10))+ ' , CD6_PBRUTO = ' + CAST(B1_PESOB  AS varchar(10))+
		' WHERE R_E_C_N_O_ =  '+CAST(CD6010.R_E_C_N_O_ AS varchar(18)),B1_PESO,
		* FROM CD6010(NOLOCK)
		INNER JOIN SB1010(NOLOCK) ON B1_FILIAL = CD6_FILIAL  AND CD6_COD = B1_COD 
		AND SB1010.D_E_L_E_T_ = ''
		WHERE (CD6_PLIQUI = 0 OR CD6_PBRUTO = 0 )  AND CD6010.D_E_L_E_T_ = '' AND (B1_PESO = 0 AND B1_PESOB > 0 ) and CD6_FILIAL = '16'*/



	//--UPDATE SA2 
		cUpd0032 := " UPDATE "+RetSqlname('SA2')+" SET A2_CATEGOR = 'DIS' "
		cUpd0032 += " WHERE A2_CATEGOR <> 'DIS' AND A2_COD+A2_LOJA IN( "
		cUpd0032 += " SELECT D1_FORNECE + D1_LOJA FROM "+RetSqlname('SD1')+" "
		cUpd0032 += " WHERE  D1_DTDIGIT BETWEEN '"+dtos(_dDatade)+"' AND '"+dtos(_dDataate)+"'  "
		cUpd0032 += " AND D1_COD NOT LIKE 'DB%' AND D1_TP = 'CO' AND D1_FILIAL = '"+xfilial('SD1')+"' "
		cUpd0032 += " ) "

		If (TcSqlExec(cUpd0032) < 0)
			MsgStop("TCSQLError() " + TCSQLError())
			Return(.F.)
		EndIf

	//--UPDATE SA1  - CFC
		cUpd0032 := " UPDATE "+RetSqlname('SA1')+" SET A1_CATEGOR = 'CFC'  "
		//--SELECT A1_INSCR,A1_CATEGOR,A1_COD FROM SA1010(NOLOCK)
		cUpd0032 += " WHERE A1_CATEGOR <> 'CFC' "
		cUpd0032 += " AND A1_INSCR <> 'ISENTO' "
		cUpd0032 += " AND A1_COD+A1_LOJA IN( "
		cUpd0032 += " 	SELECT D2_CLIENTE + D2_LOJA FROM "+RetSqlname('SD2')+"(NOLOCK) "
		cUpd0032 += " 	WHERE  D2_EMISSAO BETWEEN '"+dtos(_dDatade)+"' AND '"+dtos(_dDataate)+"' "
		cUpd0032 += " 	AND D2_COD NOT LIKE 'DB%' AND D2_TP = 'CO' AND D2_FILIAL = '"+xfilial('SD2')+"'  "
		cUpd0032 += " ) "
		//cUpd0032 += "GROUP BY A1_INSCR,A1_CATEGOR,A1_COD "

		If (TcSqlExec(cUpd0032) < 0)
			MsgStop("TCSQLError() " + TCSQLError())
			Return(.F.)
		EndIf

	//--UPDATE SA1  - CNF
		//SELECT A1_INSCR,A1_CATEGOR,* FROM SA1010(NOLOCK)
		cUpd0032 := " UPDATE "+RetSqlname('SA1')+" SET A1_CATEGOR = 'CNF' " 
		cUpd0032 += " WHERE A1_CATEGOR <> 'CNF' "
		cUpd0032 += " AND A1_INSCR = 'ISENTO' "
		cUpd0032 += " AND A1_COD+A1_LOJA IN( "
		cUpd0032 += " 	SELECT D2_CLIENTE + D2_LOJA FROM "+RetSqlname('SD2')+"(NOLOCK) "
 		cUpd0032 += " 	WHERE  D2_EMISSAO BETWEEN '"+dtos(_dDatade)+"' AND '"+dtos(_dDataate)+"'  "
		cUpd0032 += " 	AND D2_COD NOT LIKE 'DB%' AND D2_TP = 'CO' AND D2_FILIAL = '"+xfilial('SF2')+"' " 
		cUpd0032 += " )

		If (TcSqlExec(cUpd0032) < 0)
			MsgStop("TCSQLError() " + TCSQLError())
			Return(.F.)
		EndIf

                
    Restarea(_aarea)

Return
