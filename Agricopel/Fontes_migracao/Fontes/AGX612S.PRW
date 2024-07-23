#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE 'TOPCONN.CH'            

User Function AGX612S()
     Local aArea     := GetArea()
     Local cIdBrowse := ''
     Local cIdRodape := ''
     Local cFile     := ''
     Local nI        := 0
     Local nAt       := 0
     Local cTrab     := GetNextAlias()                      
     Local cQryDoc   := GetNextAlias()
     Local cQuery    := " "
     Local aCampos   := {}
     Local aStru     := {}
     Local aAux      := {}
     Local aButton   := {}
     Local oBrowse
     Local oColumn                                                                     
     Local oDlg
     Local oGed
     Local aSizes := MSADVSIZE()
     Local aCoord := {}//{ 0, 0, 800, 1800 }  
	 Local bKeyF12    := SetKey(VK_F12)    
	 
     aCoord  := { 0, 0, aSizes[6], aSizes[5] }     
     
	 If !CriaSx1() //Chamo grupo de perguntas
		Return
	 EndIf 
     
     Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Pixel style DS_MODALFRAME   
     

     CriaTab() //Crio area de trabalho
   	 Carga() //Dou a carga na TRB
   	 


	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TRB" OF oDlg	

	oBrowse:DisableConfig ( )      
    oBrowse:SetDoubleClick({||testeclick()})    
     	 
	SetKey(VK_F12, {|| XCarregaBrow(),oBrowse:Refresh(),oBrowse:GoTop(.t.)})
   	
   	 
    ADD LEGEND DATA 'TRB->PARCIAL > 0 .OR. (ALLTRIM(TRB->NOTA) <> "" .AND. ALLTRIM(TRB->BLQ_EST) <> "")' COLOR "ORANGE" TITLE "Faturado parcial" OF oBrowse
    ADD LEGEND DATA 'ALLTRIM(TRB->BLQEST)  <> "" '                                            COLOR "BLACK"  TITLE "Bloqueio Estoque" OF oBrowse
    ADD LEGEND DATA 'ALLTRIM(TRB->BLQCRED) <> "" '                                            COLOR "BLUE"   TITLE "Bloqueio Credito" OF oBrowse
    ADD LEGEND DATA 'ALLTRIM(TRB->BLQWMS)  <> "" '                                            COLOR "YELLOW" TITLE "Bloqueio WMS"     OF oBrowse
    ADD LEGEND DATA 'ALLTRIM(TRB->NOTA)    <> "" '                                            COLOR "RED"    TITLE "Pedido Faturado"  OF oBrowse
    ADD LEGEND DATA 'ALLTRIM(TRB->NOTA)    == "" .AND. ALLTRIM(TRB->BLQEST) == ""  .AND. ALLTRIM(TRB->BLQWMS) == "" .AND. ALLTRIM(TRB->BLQCRED) == "" '  COLOR "GREEN"   TITLE "Liberado Faturamento" OF oBrowse 
	 
	 
 	AADD(aCampos,{"PEDIDO"   ,"Pedido"                 ,"@!"        })
 	AADD(aCampos,{"CLIENTE"  ,"Cliente"                ,"@!"        })
 	AADD(aCampos,{"LOJA"     ,"Loja"                   ,"@!"        })
 	AADD(aCampos,{"NOME"     ,"Nome                 	   "     ,"@!" })
 	AADD(aCampos,{"CIDADE"   ,"Cidade                          " ,"@!" })
 	AADD(aCampos,{"EMISSAO"  ,"Dt Emissao"             ,"@!"  		})
	AADD(aCampos,{"BLQEST"   ,"Bloq.Estoque"           ,""  		}) 
	AADD(aCampos,{"BLQCRED"  ,"Bloq.Credito"           ,""  		})  
	AADD(aCampos,{"BLQWMS"   ,"Bloq.WMS"               ,""  		}) 
	AADD(aCampos,{"NOTA"     ,"Nota Fiscal"            ,""  		})    
	AADD(aCampos,{"CREDITO"  ,"Status Aprov Cred"      ,""  		})        
 	AADD(aCampos,{"PRICING"  ,"Status Aprov Pricing  " ,""  		}) 
 	AADD(aCampos,{"VENDEDOR" ,"Representante  "        ,""  		}) 
	

	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos )
	     ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2] PICTURE aCampos[nI][3] Of oBrowse
	Next
	
	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------

	Activate FWBrowse oBrowse
     /*aButton := { { "SALVAR"   , { || fGrava()}, "Salvar" ,"Salvar"   },;
                  { "RELATORIO", { || fRel() }, "Imprimir","Imprimir" }}*/ 
                  
	
   	  AButton :=  {}//{{ "Legenda"   , { || Legenda()}, "Legenda" ,"Legenda" }}
      Aadd( AButton, {"HISTORIC", {|| U_612SLEG()}, "Legenda...", "Legenda" , {|| .T.}} )               

     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},,aButton)

     RestArea( aArea )

Return          

Static Function CriaSx1()
	Private cPerg      := "AGX612S"

	/*cPerg, "01", "Cliente   de    ?", "" , "", "mv_ch1", "C",TamSX3("A1_COD")[1]  , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", ""
	cPerg, "02", "Cliente   até   ?", "" , "", "mv_ch2", "C",TamSX3("A1_COD")[1] , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", ""
   	cPerg, "03", "Loja    de      ?", "" , "", "mv_ch3", "C", 2 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", ""			
	cPerg, "04", "Loja    ate     ?", "" , "", "mv_ch4", "C", 2 , 0, 2, 'G',"","","","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", ""	
	cPerg, "05", "Emissao   de    ?", "" , "", "mv_ch5", "D", 8 , 0, 2, 'G',"","","","", "mv_par05", "","", "","" ,"","","","","","","","","","","","", "","", ""		
	cPerg, "06", "Emissao   até   ?", "" , "", "mv_ch6", "D", 8 , 0, 2, 'G',"","","","", "mv_par06", "","", "","" ,"","","","","","","","","","","","", "","", ""		
	/*09 cPerg, "07", "Armazem           ?", "" , "", "mv_ch7", "C", 2 , 0, 2, 'G',"","","","", "mv_par07", "","", "","" ,"","","","","","","","","","","","", "","", ""	   
	/*10 cPerg, "08","Bloqueios           ?","","","mv_ch8","N",01,0,1,"C","","","","","mv_par08","Todos Pedidos","Todos Pedidos","Todos Pedidos","","Credito","Credito","Credito","Estoque","Estoque","Estoque" 
	/*XX cPerg, "09","Arla                ?","","","mv_ch9","N",01,0,1,"C","","","","","mv_par09","Não","Não","Não","","Sim","Sim","Sim","","","" 
	/*XX cPerg, "10","Filtrar por         ?","","","mv_ch10","N",01,0,1,"C","U_AGX612PE()","","","","mv_par10","Todos","Todos","Todos","","RC","RC","RC","RT","RT","RT","RL","RL","RL" 
	/*07 cPerg, "11", "Represent de      ?", "" , "", "mv_chA", "C", 6 , 0, 2, 'G',"","","","", "mv_par11", "","", "","" ,"","","","","","","","","","","","", "","", ""		
	/*08 cPerg, "12", "Represent ate     ?", "" , "", "mv_chB", "C", 6 , 0, 2, 'G',"","","","", "mv_par12", "","", "","" ,"","","","","","","","","","","","", "","", ""			
    */

	aRegistros := {}

  //Aadd(aRegistros,{cPerg ,"02","Classificar Por  ?","mv_ch2", "N",01                     ,0,0  , "C",""		     ,"MV_PAR02","Desc.Prod."   ,""				, ""			,"Cod.Prod.","" 	   ,""		 ,"Item"   ,""	     ,""	   ,"" ,"","","","",""})	
	AADD(aRegistros,{cPerg, "01", "Cliente   de    ?","mv_ch1", "C",TamSX3("A1_COD")[1]    , 0, 2, 'G',""		     ,"mv_par01", ""		    ,""				, ""			,"" 		,"" 	   ,""	     ,""	   ,""	     ,""	   ,"","","","","",""})
	AADD(aRegistros,{cPerg, "02", "Cliente   até   ?", "mv_ch2", "C",TamSX3("A1_COD")[1]   , 0, 2, 'G',""		     ,"mv_par02", ""		    ,""				, ""			,"" 		,"" 	   ,""	     ,""	   ,""	     ,""	   ,"","","","","",""})
	AADD(aRegistros,{cPerg, "03", "Loja    de      ?", "mv_ch3", "C", 2 				   , 0, 2, 'G',""		     ,"mv_par03", ""		    ,""				, ""			,"" 		,"" 	   ,""	     ,""	   ,""	     ,""	   ,"","","","","",""})
	AADD(aRegistros,{cPerg, "04", "Loja    ate     ?", "mv_ch4", "C", 2 				   , 0, 2, 'G',""		     ,"mv_par04", ""		    ,""				, ""			,"" 		,"" 	   ,""	     ,""	   ,""	     ,""	   ,"","","","","",""})
	AADD(aRegistros,{cPerg, "05", "Emissao   de    ?", "mv_ch5", "D", 8 				   , 0, 2, 'G',""		     ,"mv_par05", ""		    ,""				, ""			,"" 		,"" 	   ,""	     ,""	   ,""	     ,""	   ,"","","","","",""})	
	AADD(aRegistros,{cPerg, "06", "Emissao   até   ?", "mv_ch6", "D", 8 				   , 0, 2, 'G',""		     ,"mv_par06", ""		    ,""				, ""			,"" 		,"" 	   ,""	     ,""	   ,""	     ,""	   ,"","","","","",""})
	AADD(aRegistros,{cPerg, "07", "Armazem         ?", "mv_ch7", "C", 2 				   , 0, 2, 'G',""		     ,"mv_par07", ""		    ,""				, ""			,"" 		,"" 	   ,""	     ,""	   ,""	     ,""	   ,"","","","","",""})
	AADD(aRegistros,{cPerg, "08","Bloqueios        ?","mv_ch8" ,"N",01					   , 0, 1, "C",""            ,"mv_par08","Todos Pedidos","Todos Pedidos","Todos Pedidos","Credito","Credito","Credito","Estoque","Estoque","Estoque","","","","","",""})
	AADD(aRegistros,{cPerg, "09","Arla             ?","mv_ch9" ,"N",01					   , 0, 1, "C",""            ,"mv_par09","Não"			,"Não"			,"Não"	        ,"Sim"    ,"Sim"    ,"Sim"    ,""       ,""		 ,""	   ,""  ,""  ,""  ,"","",""})
	AADD(aRegistros,{cPerg, "10","Filtrar por      ?","mv_ch10","N",01					   , 0, 1, "C","U_AGX612PE()","mv_par10","Todos"		,"Todos"		,"Todos"		,"RC"     ,"RC"     ,"RC"     ,"RT"     ,"RT"     ,"RT"     ,"RL","RL","RL","","",""})
	AADD(aRegistros,{cPerg, "11", "Represent de    ?", "mv_chA", "C", 6 				   , 0, 2, 'G',""            ,"mv_par11", ""			,""				, ""			,""       ,""       ,""       ,""       ,""       ,""       ,""  ,""  ,""  ,"","",""})
	AADD(aRegistros,{cPerg, "12", "Represent ate   ?", "mv_chB", "C", 6 				   , 0, 2, 'G',""            ,"mv_par12", ""			,""				, ""			,""          ,""       ,""       ,""       ,""       ,""       ,""  ,""  ,""  ,"","",""})

	U_CriaPer(cPerg,aRegistros)
	//Alterado  
	//         07 -> 11 OK 
	//		   08 -> 12 OK 
	//		   09 -> 07 OK
	//         10 -> 08 
		
Return Pergunte(cPerg,.T.)


Static Function Carga()

    Local cQuery := ""
	cALiasCapa   := GetNextAlias()
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Buscamos informacoes de bloqueios de estoques, credito ³
	//³, princing                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
		
	//BeginSql Alias cALiasCapa  
	cQuery += " 	SELECT  C5_NUM , C5_CLIENTE, C5_LOJACLI,A1_NOME, A1_MUN,C5_VEND1,C5_EMISSAO,"
	cQuery += " 			ISNULL((SELECT TOP 1 C9_BLEST FROM "+RetSqlName('SC9')+" SC9 (NOLOCK) WHERE C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND C9_BLEST = '02' AND SC9.D_E_L_E_T_ <> '*'),'') BLQ_EST,"
	cQuery += " 			ISNULL((SELECT TOP 1 C9_BLCRED FROM "+RetSqlName('SC9')+" SC9 (NOLOCK) WHERE C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND C9_BLCRED = '01' AND SC9.D_E_L_E_T_ <> '*'),'') BLQ_CRED,"
	cQuery += " 			ISNULL((SELECT TOP 1 C9_BLWMS FROM "+RetSqlName('SC9')+" SC9 (NOLOCK) WHERE C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND C9_BLWMS  IN('01','02')  AND SC9.D_E_L_E_T_ <> '*'),'') BLQ_WMS ,"
	cQuery += " 			ISNULL((SELECT TOP 1 C6_NOTA  FROM "+RetSqlName('SC6')+" SC6 (NOLOCK) WHERE C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_NOTA <> ''  AND SC6.D_E_L_E_T_ <> '*'),'') NOTA,"
	cQuery += " 			(SELECT SUM(C6_QTDVEN - C6_QTDENT)  FROM "+RetSqlName('SC6')+" SC6 (NOLOCK) WHERE C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_NOTA <> ''  AND SC6.D_E_L_E_T_ <> '*') PARCIAL,"
	cQuery += " 			ISNULL((SELECT TOP 1 CR_STATUS  FROM "+RetSqlName('SCR')+"   SCR (NOLOCK) INNER JOIN "+RetSqlName('PB2')+" PB2 ON PB2_FILIAL = CR_FILIAL AND PB2_APROV = CR_APROV AND PB2_NIVEL > '01'AND PB2_VEND =  C5_VEND1"     
	cQuery += " 			WHERE CR_FILIAL = C5_FILIAL "
	cQuery += " 			AND PB2.D_E_L_E_T_ <> '*'"
	cQuery += " 			AND SCR.D_E_L_E_T_ <> '*'"
	cQuery += " 			AND CR_NUM = C5_NUM),'') CREDITO,"
	cQuery += " 			ISNULL((SELECT TOP 1 CR_STATUS  FROM "+RetSqlName('SCR')+" SCR (NOLOCK) INNER JOIN "+RetSqlName('PB4')+" PB2 ON PB4_FILIAL = CR_FILIAL AND PB4_APROV = CR_APROV AND PB4_NIVEL > '01'AND PB4_VEND =  C5_VEND1"
	cQuery += " 			WHERE CR_FILIAL = C5_FILIAL" 
	cQuery += " 			AND PB2.D_E_L_E_T_ <> '*'"
	cQuery += " 			AND SCR.D_E_L_E_T_ <> '*'"
	cQuery += " 			AND CR_NUM = C5_NUM),'') PRICING ,"
	cQuery += " 			ISNULL((SELECT TOP 1 C6_LOCAL FROM "+RetSqlName('SC6')+" SC6 (NOLOCK) WHERE C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ <> '*'),'') LOCALEST"
	cQuery += " 	FROM "+RetSqlName('SC5')+" C5 (NOLOCK) INNER JOIN "+RetSqlName('SA1')+" SA1 (NOLOCK)"  
	cQuery += " 	ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "    
	
	//Chamado 24764 - 04/03/2019             
	//NÃO ARLA
	If MV_PAR09 == 1  
	 	If MV_PAR10 == 1 //Todos
	 		cQuery += " AND (A1_VEND3 BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' " 
	 		cQuery += " OR   A1_VEND5 BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' "  
			cQuery += " OR   A1_VEND  BETWEEN '"+mv_par11+"' AND '"+mv_par12+"') "   
	    Elseif MV_PAR10 == 2 //RC
	 		cQuery += " AND  A1_VEND3 BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"' " 
	 	Elseif MV_PAR10 == 3 //RT
	 		cQuery += " AND  (A1_VEND5 BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' "
			cQuery += " OR    A1_VEND2 BETWEEN '"+mv_par11+"' AND '"+mv_par12+"')"
		Elseif MV_PAR10 == 4 //RL
			cQuery += " AND  A1_VEND  BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"' "  	    
	    Endif
	//SIM ARLA
	Else
	 	If MV_PAR10 == 1 //Todos
	 	 	cQuery += " AND (A1_VEND7 BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"' " 
	 		cQuery += " OR   A1_VEND6 BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"' " 
	 		cQuery += " OR   A1_VEND8 BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"') "  		  
	    Elseif MV_PAR10 == 2 //RC
	  		cQuery += " AND  A1_VEND7 BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"' " 
	    Elseif MV_PAR10 == 3 //RT
	 		cQuery += " AND  A1_VEND6 BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"' "  
	    Elseif MV_PAR10 == 4 //RL
			cQuery += " AND  A1_VEND8 BETWEEN  '"+mv_par11+"' AND '"+mv_par12+"' "  		
		Endif
	Endif
	
	cQuery += " 	WHERE  C5_FILIAL = "+xfilial('SC5')+" "/*%xFilial:SC5%*/             
	cQuery += " 		  AND C5.D_E_L_E_T_ <> '*' "
	cQuery += " 		  AND C5_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' "//%Exp:mv_par05% AND %Exp:mv_par06% "
	cQuery += " 		  AND C5_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "//%Exp:mv_par01% AND %Exp:mv_par02% "  
	cQuery += " 		  AND C5_LOJACLI BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "//%Exp:mv_par03% AND %Exp:mv_par04% "  
	//cQuery += " 		  AND C5_VEND1   BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "//%Exp:mv_par11% AND %Exp:mv_par12% "
	cQuery += " 		  AND SA1.D_E_L_E_T_ <> '*' "   
	cQuery += " 		  AND C5_NOTA <> 'XXXXXXXXX'"
	cQuery += " 	  ORDER BY C5_NUM  "
	//EndSql   
	
	If (Select(cALiasCapa) <> 0)
		dbSelectArea(cALiasCapa)
		dbCloseArea()
	Endif
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS &cALiasCapa
	
	DbSelectArea(cALiasCapa)                  
	dbGoTop()
	While !eof()    
	
		If mv_par08 == 2 .and. ALLTRIM((cALiasCapa)->BLQ_CRED) == ""     // Filtro por bloqueio de credito     
			dbSelectArea(cALiasCapa)
			dbSkip()
			LOOP
		EndIf
		
		If mv_par08 == 3 .and. (ALLTRIM((cALiasCapa)->BLQ_EST) == "" .OR. alltrim((cALiasCapa)->NOTA) <>  "")     // Filtro por bloqueio de estoques
			dbSelectArea(cALiasCapa)
			dbSkip()
			LOOP
		EndIf
	
		If alltrim(mv_par07) <> "" .AND. (alltrim(mv_par07) <> (cALiasCapa)->LOCALEST ) //Filtro por Local 			
			dbSelectArea(cALiasCapa)
			dbSkip()
			LOOP
		EndIf
	
		cPricing := "" 
		cCredito := ""
		 
		Do Case 
			Case (cALiasCapa)->PRICING == "01" .AND. ALLTRIM((cALiasCapa)->BLQ_CRED) <> ""
				cPricing := "Aguardando"
			Case (cALiasCapa)->PRICING == "02" .AND. ALLTRIM((cALiasCapa)->BLQ_CRED) <> ""
				cPricing := "Em Aprovação"
			Case (cALiasCapa)->PRICING == "04".AND. ALLTRIM((cALiasCapa)->BLQ_CRED) <> ""
				cPricing := "Rejeitado"				
			otherwise                     
				cPricing := ""
		EndCase
		
		Do Case 
			Case (cALiasCapa)->CREDITO == "01".AND. ALLTRIM((cALiasCapa)->BLQ_CRED) <> ""
				cCredito := "Aguardando"
			Case (cALiasCapa)->CREDITO == "02" .AND. ALLTRIM((cALiasCapa)->BLQ_CRED) <> ""                         
				cCredito := "Em Aprovação"  
			Case (cALiasCapa)->CREDITO == "04" .AND. ALLTRIM((cALiasCapa)->BLQ_CRED) <> ""
				cCredito := "Rejeitado"				
			otherwise                     
				cCredito := ""
		EndCase   
		
		If alltrim((cALiasCapa)->NOTA) <>  "" 
			cPricing := "" 
			cCredito := ""    
		EndIf
	    
		dbSelectArea("TRB")
		RecLock("TRB", .T.) 
			TRB->PEDIDO   := (cALiasCapa)->C5_NUM
			TRB->CLIENTE  := (cALiasCapa)->C5_CLIENTE
			TRB->LOJA     := (cALiasCapa)->C5_LOJACLI
			TRB->NOME     := (cALiasCapa)->A1_NOME
			TRB->CIDADE   := (cALiasCapa)->A1_MUN
			TRB->VENDEDOR := (cALiasCapa)->C5_VEND1
			TRB->BLQEST   := IIf(ALLTRIM((cALiasCapa)->BLQ_EST)  <> ""  .and.  alltrim((cALiasCapa)->NOTA) == "" , "Sim", "")
			TRB->BLQCRED  := IIf(ALLTRIM((cALiasCapa)->BLQ_CRED) <> ""  .and.  alltrim((cALiasCapa)->NOTA) == "" , "Sim", "")
   			TRB->BLQWMS   := IIf(ALLTRIM((cALiasCapa)->BLQ_WMS)  <> ""  .and.  alltrim((cALiasCapa)->NOTA) == "" , "Sim", "")  
   			TRB->NOTA     := (cALiasCapa)->NOTA 
   			TRB->PRICING  := cPricing 
   			TRB->CREDITO  := cCredito 
   			TRB->LOCALEST := (cALiasCapa)->LOCALEST 
   			TRB->EMISSAO  := stod((cALiasCapa)->C5_EMISSAO)     
   			TRB->PARCIAL  := (cALiasCapa)->PARCIAL   
   			TRB->BLQ_EST  := ALLTRIM((cALiasCapa)->BLQ_EST)
			
		MsUnLock()    
		
		IF ALLTRIM(TRB->PEDIDO) == '392094'  
		    CTETE := ''
		ENDIF                            
		
		dbSelectArea(cALiasCapa)
		dbSkip()	
	EndDo       
	
	dbSelectArea(cALiasCapa)
	dbCloseArea()

	dbSelectArea("TRB")
	dbGoTop()

Return()

Static Function CriaTab()                 
	aCampos := {}      
	
	aAdd(aCampos,{"PEDIDO"	   ,"C",06,00}) 
	aAdd(aCampos,{"CLIENTE"	   ,"C",06,00})
	aAdd(aCampos,{"LOJA"       ,"C",02,00})
	aAdd(aCampos,{"NOME"	   ,"C",40,00})
	aAdd(aCampos,{"CIDADE"	   ,"C",40,00})
	aAdd(aCampos,{"VENDEDOR"   ,"C",06,00})   
	aAdd(aCampos,{"BLQEST"     ,"C",03,00}) 
	aAdd(aCampos,{"BLQCRED"    ,"C",03,00})  
	aAdd(aCampos,{"BLQWMS"     ,"C",03,00})
	aAdd(aCampos,{"NOTA"       ,"C",09,00})  
	aAdd(aCampos,{"PRICING"    ,"C",15,00})  
	aAdd(aCampos,{"CREDITO"    ,"C",15,00})  
	aAdd(aCampos,{"LOCALEST"   ,"C",02,00})
	aAdd(aCampos,{"EMISSAO"    ,"D",08,00})
	aAdd(aCampos,{"PARCIAL"    ,"N",09,02})
	aAdd(aCampos,{"BLQ_EST"    ,"C",02,00})
		
    If Select("TRB") <> 0
       dbSelectArea("TRB")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"TRB",.T.,.F.)

	IndRegua("TRB", cArqTrab, "PEDIDO",,,"Indexando registros..." )

Return()

Static Function xCarregaBrow()

	 If !CriaSx1()
		Return
	 EndIf

    CriaTab()
	Carga()
	
Return()                                    

Static Function testeclick()
     Local aArea2     := GetArea()
     Local cIdBrowse2 := ''
     Local cIdRodape2 := ''
     Local cFile2     := ''
     Local nI2        := 0
     Local nAt2       := 0
     Local cTrab2     := GetNextAlias()
     Local cQryDoc2   := GetNextAlias()
     Local cQuery2    := " "
     Local aCampos2   := {}
     Local aStru2     := {}
     Local aAux2      := {}
     Local aButton2   := {}
     Local oBrowse2
     Local oColumn2
     Local oDlg2
     Local oGed2
     Local aCoord2 := {}// 0, 0, 800, 1600 }
	 ///Local bKeyF12    := SetKey(VK_F12)
	 Local aSizes := MSADVSIZE()
     aCoord2 := {0,0,aSizes[6],aSizes[5]}

     
 /*	 If !CriaSx1() //Chamo grupo de perguntas
		Return
	 EndIf         */
     
    Define MsDialog oDlg2 FROM aCoord2[1], aCoord2[2] To aCoord2[3], aCoord2[4] Pixel style DS_MODALFRAME

    TabSC9() //Crio area de trabalho
    CargaSC9() //Dou a carga na TRB


	DEFINE FWBROWSE oBrowse2 DATA TABLE ALIAS "TRB2" OF oDlg2

	oBrowse2:DisableConfig ( )
    //oBrowse:SetDoubleClick({||testeclick()})

	//SetKey(VK_F12, {|| XCarregaBrow(),oBrowse:Refresh()})

    ADD LEGEND DATA 'TRB2->PARCIAL > 0 '              COLOR "ORANGE" TITLE "Faturado parcial" OF oBrowse2
    ADD LEGEND DATA 'ALLTRIM(TRB2->BLQEST)  <> "" '   COLOR "BLACK"  TITLE "Bloqueio Estoque" OF oBrowse2
    ADD LEGEND DATA 'ALLTRIM(TRB2->BLQCRED) <> "" '   COLOR "BLUE"   TITLE "Bloqueio Credito" OF oBrowse2
    ADD LEGEND DATA 'ALLTRIM(TRB2->BLQWMS)  <> "" '   COLOR "YELLOW" TITLE "Bloqueio WMS"     OF oBrowse2
    ADD LEGEND DATA 'ALLTRIM(TRB2->NOTA)    <> "" '   COLOR "RED"    TITLE "Pedido Faturado"  OF oBrowse2
    ADD LEGEND DATA 'ALLTRIM(TRB2->NOTA)    == "" .AND. ALLTRIM(TRB2->BLQEST) == ""  .AND. ALLTRIM(TRB2->BLQWMS) == "" .AND. ALLTRIM(TRB2->BLQCRED) == "" '  COLOR "GREEN"   TITLE "Liberado Faturamento" OF oBrowse2 

 	AADD(aCampos2,{"ITEM"      ,"Item"     		,"@!"  		})
 	AADD(aCampos2,{"PRODUTO"   ,"Produto"       ,"@!"  		}) 
 	AADD(aCampos2,{"DESCRICAO" ,"Descricao                           ","@!" }) 
 	AADD(aCampos2,{"QTDVEN"    ,"Qtde Venda"	,"@E 999,999.99"  		})  
 	AADD(aCampos2,{"QTDLIB"    ,"Qtde Liberada" ,"@E 999,999.99"  		}) 
 	AADD(aCampos2,{"PARCIAL"   ,"Saldo"     	,"@E 999,999.99"  		}) 
 	AADD(aCampos2,{"PRCVEN"    ,"Preco Venda"   ,"@E 999,999.99"  		})
	AADD(aCampos2,{"VALOR"     ,"Total "     	,"@E 999,999.99"  		}) 
	AADD(aCampos2,{"BLQEST"    ,"Bloq.Estoque"  ,""  		})  
	AADD(aCampos2,{"BLQCRED"   ,"Bloq.Credito"  ,""  		}) 
	AADD(aCampos2,{"BLQWMS"    ,"Bloq.WMS"      ,""  		})    
	AADD(aCampos2,{"NOTA"      ,"Nota"          ,""  		})
	

	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos2 )
	     ADD COLUMN oColumn2 DATA &( ' { || ' + aCampos2[nI][1] + ' } ' ) Title aCampos2[nI][2] PICTURE aCampos2[nI][3] Of oBrowse2
	Next
	
	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------

	Activate FWBrowse oBrowse2

     /*aButton := { { "SALVAR"   , { || fGrava()}, "Salvar" ,"Salvar"   },;
                  { "RELATORIO", { || fRel() }, "Imprimir","Imprimir" }}*/ 
   
 	AButton2 :=  {}//{ "Legenda"   , { ||Legenda()}, "Legenda" ,"Legenda" }
    Aadd( AButton2, {"HISTORIC", {|| U_612SLEG()}, "Legenda...", "Legenda" , {|| .T.}} )     
     
     ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| nOpca2 := 1,oDlg2:End()},{|| nOpca2 := 2,oDlg2:End()},,aButton2)        
     

     RestArea( aArea2 )
Return() 


Static Function TabSC9()                 
	aCampos := {}         
	
	aAdd(aCampos,{"ITEM"	   ,"C",02,00}) 
	aAdd(aCampos,{"PRODUTO"	   ,"C",15,00})
	aAdd(aCampos,{"DESCRICAO"  ,"C",40,00})
	aAdd(aCampos,{"QTDVEN"	   ,"N",10,4})
	aAdd(aCampos,{"PRCVEN"	   ,"N",10,4})
	aAdd(aCampos,{"VALOR"      ,"N",10,2})   
	aAdd(aCampos,{"BLQEST"     ,"C",03,00}) 
	aAdd(aCampos,{"BLQCRED"    ,"C",03,00})  
	aAdd(aCampos,{"BLQWMS"     ,"C",03,00})
	aAdd(aCampos,{"NOTA"       ,"C",09,00})  
	aAdd(aCampos,{"QTDLIB"     ,"N",10,4})  
	aAdd(aCampos,{"PARCIAL"    ,"N",9,2})
		
    If Select("TRB2") <> 0
       dbSelectArea("TRB2")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"TRB2",.T.,.F.)

	IndRegua("TRB2", cArqTrab, "ITEM",,,"Indexando registros..." )

Return()        
        


Static Function CargaSC9()

	cALiasSC9   := GetNextAlias()
	
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Buscamos informacoes de bloqueios de estoques, credito ³
	//³, princing                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/                

	BeginSql Alias cALiasSC9
		      SELECT C9_ITEM ITEM, C9_PRODUTO, B1_DESC, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C9_BLEST,C9_BLCRED, C9_BLWMS, C9_NFISCAL , C6_QTDENT ,SUM(C9_QTDLIB) QTDELIB
		      FROM %table:SC9%  C9  (NOLOCK)
			      INNER JOIN %table:SC6%  C6 (NOLOCK)
			      ON C9_FILIAL = C6_FILIAL 
			      AND C9_PEDIDO = C6_NUM 
			      AND C9_ITEM = C6_ITEM
			      INNER JOIN %table:SB1% B1 (NOLOCK)
			      ON B1_FILIAL = C9_FILIAL 
			      AND B1_COD = C9_PRODUTO 
		      WHERE C9_PEDIDO = %Exp:TRB->PEDIDO%
		        AND C9.D_E_L_E_T_ <> '*'
		        AND C6.D_E_L_E_T_ <> '*'
		        AND B1.D_E_L_E_T_ <> '*'
		        AND C9_FILIAL = %xFilial:SC9% 
		      GROUP BY  C9_ITEM , C9_PRODUTO, B1_DESC, C6_QTDVEN, C6_PRCVEN, C6_VALOR,C9_BLEST, C9_BLCRED, C9_BLWMS, C9_NFISCAL,C6_QTDENT
		      ORDER BY C9_ITEM 
	EndSql
	        
	      
	DbSelectArea(cALiasSC9)                  
	dbGoTop()
	While !eof()  
		dbSelectArea("TRB2")
		RecLock("TRB2", .T.) 
			TRB2->ITEM       := (cALiasSC9)->ITEM
			TRB2->PRODUTO    := (cALiasSC9)->C9_PRODUTO    
			TRB2->DESCRICAO  := (cALiasSC9)->B1_DESC    		
			TRB2->QTDVEN     := (cALiasSC9)->C6_QTDVEN
			TRB2->PRCVEN     := (cALiasSC9)->C6_PRCVEN
			TRB2->VALOR      := (cALiasSC9)->C6_VALOR
			TRB2->BLQEST     := IIf(ALLTRIM((cALiasSC9)->C9_BLEST)  <> ""  .and.  alltrim((cALiasSC9)->C9_NFISCAL) == "" , "Sim", "")
			TRB2->BLQCRED    := IIf(ALLTRIM((cALiasSC9)->C9_BLCRED)  <> ""  .and.  alltrim((cALiasSC9)->C9_NFISCAL) == "" , "Sim", "")
			TRB2->BLQWMS     := IIf((ALLTRIM((cALiasSC9)->C9_BLWMS) == "01" .OR. ALLTRIM((cALiasSC9)->C9_BLWMS)== "02" ).and.  alltrim((cALiasSC9)->C9_NFISCAL) == "" , "Sim", "")
   			TRB2->NOTA       := (cALiasSC9)->C9_NFISCAL 
   			TRB2->QTDLIB     := IIF( alltrim(TRB2->BLQCRED+TRB2->BLQEST) == "", (cALiasSC9)->QTDELIB,0)  
   			TRB2->PARCIAL    := (cALiasSC9)->C6_QTDVEN - (cALiasSC9)->C6_QTDENT 
		MsUnLock()                                  
		          
		CTESTE := ""
		dbSelectArea(cALiasSC9)
		dbSkip()                               			      
	EndDo			                               	

Return()

User Function 612SLEG()

	Local aLegenda := {} 
	
	AADD(aLegenda,{"BR_LARANJA" 	,"Faturado Parcial"	})
	AADD(aLegenda,{"BR_PRETO" 		,"Bloqueio Estoque"	})
	AADD(aLegenda,{"BR_AZUL" 		,"Bloqueio Credito"	})
	AADD(aLegenda,{"BR_AMARELO" 	,"Bloqueio WMS"  	})  
	AADD(aLegenda,{"BR_VERMELHO" 	,"Pedido Faturado"	})
	AADD(aLegenda,{"BR_VERDE" 		,"Liberado" 	})
	    
                
	BrwLegenda("Legenda", "Legenda", aLegenda)

Return