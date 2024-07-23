#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWBROWSE.CH' 
#include "rwmake.ch" 
#INCLUDE 'FWMVCDEF.CH'           
                                 


User Function AGX615()

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
     Local aCoord := { 0, 0, 500, 1000 }  
	 Local bKeyF12    := SetKey(VK_F12)   
	 Local bKeyF5    := SetKey(VK_F5)  
	 cCGCDist		:= AllTrim(SM0->M0_CGC)
	 
 	If !CriaSx1()
		Return
	EndIf                 
	

    Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Pixel style DS_MODALFRAME   
    
   	CriaTab()
   	Carga()
   	
	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TRB" OF oDlg	

	oBrowse:DisableConfig ( )      
    oBrowse:SetDoubleClick({||TelaIt()})    
     	 
	SetKey(VK_F12, {|| XCarregaBrow(),oBrowse:Refresh(),oBrowse:GoTop(.t.)})    
	SetKey(VK_F5, {|| oBrowse:Refresh(),oBrowse:GoTop(.t.)})
   	
   	 

	

	 ADD LEGEND DATA 'ALLTRIM(TRB->PEDSIGA)  == "" '         					     	 COLOR "RED" TITLE   "Pedido Nao Importado"  OF oBrowse 
	 ADD LEGEND DATA 'ALLTRIM(TRB->PEDSIGA) == "*" '         					         COLOR "BLACK" TITLE "Pedido duplicado ou com problema nos produtos"      OF oBrowse 
	 ADD LEGEND DATA 'ALLTRIM(TRB->PEDSIGA)  <> "" .AND. ALLTRIM(TRB->PEDSIGA) <> "*"  ' COLOR "GREEN"  TITLE "Pedido Importado" OF oBrowse 
	 ADD LEGEND DATA 'ALLTRIM(TRB->CLIBLOQ)  <> "2" .AND. ALLTRIM(TRB->CLIBLOQ)  <> "" ' COLOR "ORANGE"  TITLE "Pedido Importado" OF oBrowse 
//     ADD LEGEND DATA 'ALLTRIM(TRB->PEDSIGA)  <> "" .AND. ALLTRIM(TRB->PEDSIGA) <> "*"  ' COLOR "GREEN"  TITLE "Pedido Importado" OF oBrowse 


   //	AADD(aCampos,{"OK"			,"","Gerar"     		,"@!"  		})
	AADD(aCampos,{"PEDIDO"       ,"Pedido Blink"       ,"@!"  		})    
	AADD(aCampos,{"PEDSIGA"      ,"Pedido Protheus"       ,"@!"  		})    
	AADD(aCampos,{"CLIENTE"	    ,"Cliente"          	,"@!"	    })                 	
	AADD(aCampos,{"LOJA"	    ,"Loja"	        ,"@!"		})                                                    	
	AADD(aCampos,{"NOME"		,"Nome                       " ,"@!"		})
	AADD(aCampos,{"EMISSAO"		,"Dt Emissao"	     		,"@!"		})   
	AADD(aCampos,{"IMPORTA"		,"Dt Importacao    "   		,"@!"		})                                                                   
	AADD(aCampos,{"LEITURA"		,"Dt Leitura       "   		,"@!"		})                                                                   
	AADD(aCampos,{"CODVEND"		,"Representante"   		,"@!"		})       
	AADD(aCampos,{"NOMVEND"		,"Nome                    " ,"@!"		})   
//	AADD(aCampos,{"CONDPAG"		,"Cond Pag"   		,"@!"		})   
//	AADD(aCampos,{"DESCOND"		,"Descricao"   		,"@!"		})   
	AADD(aCampos,{"TOTPED"		,"Total Ped"   		,"99999.99"		})    
	


	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos )
	     ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2] PICTURE aCampos[nI][3] Of oBrowse
	Next
	
	
	//ADD MARKCOLUMN oColumn DATA { || If(.T./* Função com a regra*/,'LBOK','LBNO') } DOUBLECLICK { |oBrowse| /* Função que atualiza a regra*/ } HEADERCLICK { |oBrowse| /* Função executada no clique do header */ } OF oBrowse		
		
	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------         
	
	


	Activate FWBrowse oBrowse             



     aButton := { { "Importar"   , { || ReImp(),oBrowse:Refresh()}, "Importar" ,"Importar"   }}
//                  { "RELATORIO", { || fRel() }, "Imprimir","Imprimir" }}
                  
	
   	 
                       

     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},,aButton)        
     

     RestArea( aArea )


   


Return()	


Static Function CriaSx1()
	Private cPerg      := "AGX615"

	PutSx1(cPerg, "01", "Vendedor  de    ?", "" , "", "mv_ch1", "C",TamSX3("A3_COD")[1]  , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")     
	PutSx1(cPerg, "02", "Vendedor  até   ?", "" , "", "mv_ch2", "C",TamSX3("A3_COD")[1] , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")    
	PutSx1(cPerg, "03", "Importado de    ?", "" , "", "mv_ch3", "D", 8 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	PutSx1(cPerg, "04", "Importado até   ?", "" , "", "mv_ch4", "D", 8 , 0, 2, 'G',"","","","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	PutSx1(cPerg, "05", "Cliente de      ?", "" , "", "mv_ch5", "C", 6 , 0, 2, 'G',"","","","", "mv_par05", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	PutSx1(cPerg, "06", "Cliente ate     ?", "" , "", "mv_ch6", "C", 6 , 0, 2, 'G',"","","","", "mv_par06", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	PutSx1(cPerg, "07", "Loja    de      ?", "" , "", "mv_ch7", "C", 2 , 0, 2, 'G',"","","","", "mv_par07", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	PutSx1(cPerg, "08", "Loja    ate     ?", "" , "", "mv_ch8", "C", 2 , 0, 2, 'G',"","","","", "mv_par08", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "09", "Importados      ?",""  , "", "mv_ch9", "N",01,0,1,"C","","","","","mv_par09","Todos Pedidos","Todos Pedidos","Todos Pedidos","","Nao Importados","Nao Importados","Nao Importados","","","" )		
	
	
Return Pergunte(cPerg,.T.)


Static Function CriaTab()                 
	aCampos := {}      
	
 //	aAdd(aCampos,{"OK"		,"C",02,00})
	aAdd(aCampos,{"PEDIDO"	,"C",25,00}) 
	aAdd(aCampos,{"PEDSIGA"	,"C",06,00})
	aAdd(aCampos,{"CLIENTE"	,"C",06,00})
	aAdd(aCampos,{"LOJA"    ,"C",02,00})
	aAdd(aCampos,{"NOME"	,"C",40,00})
	aAdd(aCampos,{"EMISSAO" ,"D",08,00})
	aAdd(aCampos,{"IMPORTA"	,"C",40,00})
	aAdd(aCampos,{"LEITURA"	,"C",40,00})
	aAdd(aCampos,{"CODVEND"	,"C",06,00})	
	aAdd(aCampos,{"NOMVEND"	,"C",40,00})	
	aAdd(aCampos,{"CLIBLOQ"	,"C",01,00}) 
	aAdd(aCampos,{"CLIATIV"	,"C",01,00})
 //	aAdd(aCampos,{"CONDPAG"	,"C",03,00})	
 //	aAdd(aCampos,{"DESCOND"	,"C",40,00})
 	aAdd(aCampos,{"TOTPED"	,"N",11,02})	

	
	
	
    If Select("TRB") <> 0
       dbSelectArea("TRB")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)            
	dbUseArea(.T.,,cArqTrab,"TRB",.T.,.F.)

	IndRegua("TRB", cArqTrab, "PEDIDO",,,"Indexando registros..." )

Return() 



Static Function Carga()
	cALiasCapa   := GetNextAlias()
	cCGCDist		:= AllTrim(SM0->M0_CGC)
        	

	dData1 :=  dtos(mv_par03)
	dData2 :=  dtos(mv_par04)   
	
	BeginSql Alias cALiasCapa  
		SELECT PEDIDOS.NUMPEDMOBILE ,PEDIDOS.NUMPED, A1_COD, A1_LOJA, A1_NREDUZ, DTEMISSAO, CAST(IMPORTACAO AS VARCHAR) IMPORTACAO, 
		CAST(DT_LEITURA AS VARCHAR) DT_LEITURA, CODVEND, A3_NOME, CONDPAG,E4_COND,  TOTPED , A1_SITUACA, A1_MSBLQL 
		FROM INTEGRA_PALM..PEDIDOS (NOLOCK)                                                                                                                      
		INNER JOIN SA1010 (NOLOCK) A1
		ON A1_CGC = CNPJ 
		INNER JOIN SE4010 (NOLOCK) E4
		ON E4_CODIGO = CONDPAG
		INNER JOIN SA3010 (NOLOCK) A3 
		ON A3_COD = CODVEND
		AND A3_FILIAL = FILIAL
		WHERE A1.D_E_L_E_T_ <> '*'
		  AND E4.D_E_L_E_T_ <> '*'
		  AND A3.D_E_L_E_T_ <> '*'
		  AND CODVEND   BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%   
		  AND A1.A1_COD BETWEEN  %Exp:mv_par05% AND %Exp:mv_par06%
		  AND A1.A1_LOJA BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%    
		  AND CONVERT(DATE,IMPORTACAO,103) BETWEEN CONVERT(DATE,%Exp:dData1%,103) AND CONVERT(DATE,%Exp:dData2%,103)  
		  AND CGCDIST = %exp:cCGCDist%
		ORDER BY IMPORTACAO DESC
	EndSql   
	
	DbSelectArea(cALiasCapa)                  
	dbGoTop()
	While !eof()        
	
		If mv_par09 == 2 .AND. (ALLTRIM((cALiasCapa)->NUMPED) <> "" .AND. alltrim((cALiasCapa)->NUMPED) <> "*")    
			(cALiasCapa)->(dbSkip())
			loop
		EndIf
		
			
	     
		dbSelectArea("TRB")
		RecLock("TRB", .T.)
			PEDIDO   := (cALiasCapa)->NUMPEDMOBILE 
			PEDSIGA  := (cALiasCapa)->NUMPED
			CLIENTE  := (cALiasCapa)->A1_COD
			LOJA     := (cALiasCapa)->A1_LOJA
			NOME     := (cALiasCapa)->A1_NREDUZ
			//EMISSAO  := (cALiasCapa)->DTEMISSAO
			IMPORTA  := (cALiasCapa)->IMPORTACAO
		   	LEITURA  := (cALiasCapa)->DT_LEITURA
			CODVEND  := (cALiasCapa)->CODVEND
			NOMVEND  := (cALiasCapa)->A3_NOME 
			CLIBLOQ  := (cALiasCapa)->A1_MSBLQL
			CLIATIV  := (cALiasCapa)->A1_SITUACA
//			CONDPAG  := (cALiasCapa)->CONDPAG
//			DESCOND  := (cALiasCapa)->E4_COND
			TOTPED   := (cALiasCapa)->TOTPED
		MsUnLock()                                      
		
		dbSelectArea(cALiasCapa)
		dbSkip()	
	EndDo       
	
	dbSelectArea(cALiasCapa)
	dbCloseArea()
    
	dbSelectArea("TRB")
	dbGoTop()
                       
Return()             


Static Function XCarregaBrow()
	If !CriaSx1()
		Return
	EndIf 
	CriaTab()
	Carga()
Return()   

           

Static Function ReImp()


If MSGBOX("Deseja recarregar o pedido para nova importação?","Nova Importação","YESNO")
    
	
	Atualiza()
 //	ALERT(TRB->PEDIDO)                                                                   
	
Endif
		


Return() 



Static Function Atualiza()  
    cCGCDist := ''
    cCGCDist := AllTrim(SM0->M0_CGC)

	cQuery := ""
	cQuery := "UPDATE INTEGRA_PALM..PEDIDOS "
	cQuery += " SET NUMPED = '',"
	cQuery += " DT_LEITURA = NULL "
	cQuery += " WHERE NUMPEDMOBILE = '" + TRB->PEDIDO + "' "  
    cQuery += "   AND CGCDIST      = '" + cCGCDist + "' "
	If TCSQLExec(cQuery) < 0
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf     
	
	cQuery := ""
	cQuery := "UPDATE INTEGRA_PALM..ITENS "
	cQuery += " SET DT_LEITURA = NULL "
	cQuery += " WHERE NUMPEDMOBILE = '" + TRB->PEDIDO + "' "   
    cQuery += "   AND CGCDIST      = '" + cCGCDist + "' "
    
	If TCSQLExec(cQuery) < 0
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf    
	
 	RecLock("TRB", .F.)
			TRB->PEDSIGA   := ""
		   	TRB->LEITURA  := ""
	MsUnlock()	          
	
Return()                            


Static Function CargaIt()     
	cALiasIt   := GetNextAlias()  
	cCGCDist		:= AllTrim(SM0->M0_CGC) 
	
	
	BeginSql Alias cALiasIt  
		SELECT NUMITEM, CODPROD ,B1_DESC,QTDVEN, PRCVEN,DESCONT, VALOR, B1_SITUACA,B1_MSBLQL  
		FROM INTEGRA_PALM..ITENS (NOLOCK)  INNER JOIN SB1010 B1 (NOLOCK)
		ON B1_FILIAL = FILIAL 
		AND B1_COD = CODPROD  
		WHERE NUMPEDMOBILE = %Exp:TRB->PEDIDO%     
		AND CGCDIST = %exp:cCGCDist%
		ORDER BY NUMITEM 
	EndSql  

	DbSelectArea(cALiasIt)                  
	dbGoTop()
	While !eof() 
		RecLock("TRBIT",.T.)
			ITEM    :=  (cALiasIt)->NUMITEM
			CODPROD :=  (cALiasIt)->CODPROD 
			DESCRI  :=	(cALiasIt)->B1_DESC
			QTD     :=	(cALiasIt)->QTDVEN
			PRCVEN  :=	(cALiasIt)->PRCVEN
			DESCON  :=	(cALiasIt)->DESCONT
  			VALOR   :=	(cALiasIt)->VALOR
  			SITUACA :=  (cALiasIt)->B1_SITUACA
  			BLOQ	:=  (cALiasIt)->B1_MSBLQL
  		MsUnlock()

		dbSelectArea(cALiasIt)
  		(cALiasIt)->(dbSkip())
  	EndDo
    
	dbSelectArea(cALiasIt)
	dbCloseArea()
	
	dbSelectArea("TRBIT")
	dbGoTop()

Return()     



Static Function TrabIt()                 
	aCampos := {}      
	
	aAdd(aCampos,{"ITEM"	,"C",3,00}) 
	aAdd(aCampos,{"CODPROD"	,"C",15,00})
	aAdd(aCampos,{"DESCRI"	,"C",40,00})
	aAdd(aCampos,{"QTD"     ,"N",11,02})
	aAdd(aCampos,{"PRCVEN"	,"N",11,02})
	aAdd(aCampos,{"DESCON" , "N",11,02})
	aAdd(aCampos,{"VALOR"  , "N",11,02})
	aAdd(aCampos,{"SITUACA" , "C",01,00})
	aAdd(aCampos,{"BLOQ" , "C",01,00})

	
	
	
    If Select("TRBIT") <> 0
       dbSelectArea("TRBIT")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)            
	dbUseArea(.T.,,cArqTrab,"TRBIT",.T.,.F.)

	IndRegua("TRBIT", cArqTrab, "ITEM",,,"Indexando registros..." )

Return()      


Static Function TelaIt()

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
     Local oBrowse2
     Local oColumn                                                                     
     Local oDlg2
     Local oGed2
     Local aCoord := { 0, 0, 500, 1000 }   

    Define MsDialog oDlg2 FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Pixel style DS_MODALFRAME   
    
   	TrabIt()
   	CargaIt()
   	
	DEFINE FWBROWSE oBrowse2 DATA TABLE ALIAS "TRBIT" OF oDlg2	

	oBrowse2:DisableConfig ( )      

   	 

	
	 ADD LEGEND DATA 'ALLTRIM(TRBIT->BLOQ) == "1" '  COLOR "BLACK"  TITLE "Produto Bloqueado"      OF oBrowse2 
	 ADD LEGEND DATA 'ALLTRIM(TRBIT->BLOQ) <> "1"  ' COLOR "GREEN"  TITLE "Produto Ativo" OF oBrowse2 

   //	AADD(aCampos,{"OK"			,"","Gerar"     		,"@!"  		})
	AADD(aCampos,{"ITEM"          ,"Item"       ,"@!"  		})    
	AADD(aCampos,{"CODPROD"      ,"Produto"       ,"@!"  		})    
	AADD(aCampos,{"DESCRI"	    ,"Descrição                    "          	,"@!"	    })                 	
	AADD(aCampos,{"QTD"	    ,"Quantidade"	        ,"999999.99"		})                                                    	
	AADD(aCampos,{"PRCVEN"		,"Preço Venda                       " ,"999999.99"		})
	AADD(aCampos,{"DESCON"		,"Desconto"	     		,"999.99"		})   
	AADD(aCampos,{"VALOR"		,"Total    "   		,"9999999.99"		})                                                                   
   
	

	


	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos )
	     ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2] PICTURE aCampos[nI][3] Of oBrowse2
	Next
	
	
	//ADD MARKCOLUMN oColumn DATA { || If(.T./* Função com a regra*/,'LBOK','LBNO') } DOUBLECLICK { |oBrowse| /* Função que atualiza a regra*/ } HEADERCLICK { |oBrowse| /* Função executada no clique do header */ } OF oBrowse		
		
	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------         
	
	


	Activate FWBrowse oBrowse2             



 //    aButton := { { "Importar"   , { || ReImp(),oBrowse2:Refresh()}, "Importar" ,"Importar"   }}
//                  { "RELATORIO", { || fRel() }, "Imprimir","Imprimir" }}
                  
	
   	 
                       

     ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| nOpca := 1,oDlg2:End()},{|| nOpca := 2,oDlg2:End()},,aButton)        
     

     RestArea( aArea )


   


Return()	



