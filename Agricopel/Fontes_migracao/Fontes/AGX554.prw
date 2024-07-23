#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH" 
#INCLUDE "rwmake.ch


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX554    ºAutor  ³Microsiga           º Data ³  01/17/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ATUALIZA CUSTO BASE DA NOTA DE SAIDA PARA PRODUTOS COM     º±±
±±º          ³ CUSTO ZERADO                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



User Function AGX554()
Private cPerg := 'AGX554'
 
CriaSx1(cPerg)               

If Pergunte(cPerg,.T.)
   	Processa({ || xAtulCusto(),OemToAnsi('Atualizando custos zerados...')}, OemToAnsi('Aguarde...'))
  // xAtulCusto()
EndIf

Return()          


Static Function xAtulCusto()
Local cAliasSD2 := "SD2"
Local cAliasSD2 := GetNextAlias()           
Local cAliasSDX := GetNextAlias()           
Local lQuery    := .T.       


	BeginSql Alias cAliasSD2  
	
		//COLUMN F3_ENTRADA AS DATE
		//COLUMN F3_DTCANC AS DATE
		
		SELECT D2_FILIAL, D2_DOC, D2_SERIE, D2_COD, D2_EMISSAO, D2_LOCAL, D2_NUMSEQ , D2_PEDIDO, D2_ITEMPV , D2_COD
		FROM %Table:SD2% (NOLOCK) SD2
		WHERE SD2.D2_FILIAL = %xFilial:SD2% 
		AND SD2.D2_EMISSAO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% 
		AND SD2.D2_CBASE = 0 
		AND SD2.D2_TIPO = 'N' 
		AND SD2.D2_COD BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% 
		AND SD2.%notdel%
		//SF3.F3_DTCANC = %Exp:Space(8)% AND	
	EndSql              
	
	
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄx¤[¿
	//³Navega nos itens que o custo esta zerado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄx¤[Ù
	ENDDOC*/
	dbSelectArea(cAliasSD2)
	dbGoTop()
	While !eof()                        
		
		dDataEmis := (cAliasSD2)->D2_EMISSAO 	
		cProduto  := (cAliasSD2)->D2_COD
	    cAliasSDX := GetNextAlias()     
	                    
	    BeginSql Alias cAliasSDX 
			SELECT  TOP 1 D2_COD, D2_EMISSAO , D2_CBASE  FROM %Table:SD2% (NOLOCK) D2
			WHERE D2_EMISSAO <= %Exp:dDataEmis%
			  AND D2_FILIAL = %xFilial:SD2% 
			  AND D2.%notdel%
			  AND D2_CBASE <> 0 
			  AND D2_TIPO = 'N'
			  AND D2_COD = %Exp:cProduto%
			  GROUP BY D2_COD , D2_EMISSAO, D2_CBASE                                                                                               
			  ORDER BY D2_COD, D2_EMISSAO DESC
		EndSql


	    dbSelectArea(cAliasSDX)
		dbGotop()  
		While !eof()                  
			//nCusto := cAliasSDX->D2_CBASE		
			dbSelectArea("SD2")
			dbSetOrder(1)
			If dbSeek(xFilial("SD2")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_LOCAL+(cAliasSD2)->D2_NUMSEQ)
				Reclock("SD2",.F.) 
					SD2->D2_CBASE := (cAliasSDX)->D2_CBASE		
				MsUnlock()
			EndIf                                                             
			
			dbSelectArea("SC6")
			dbSetOrder(1)    		   
			If dbseek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD)
				Reclock("SC6",.F.)
					SC6->C6_CBASE  := (cAliasSDX)->D2_CBASE 
				MsUnlock()
			EndIf       
				
		   	dbSelectArea(cAliasSDX)
		   	dbSkip()		
		EndDo  
		
		
		dbSelectArea(cAliasSDX)
		(cAliasSDX)->( dbCloseArea() )

                                                                                                                          
	                                                        
		dbSelectArea(cAliasSD2)
		dbSkip()
	
	EndDo   
	dbSelectArea(cAliasSD2)
	(cAliasSD2)->( dbCloseArea() )      
//	MSGBOX("Procedimento executado com sucesso!","Atualização Custo","INFO") 
  	Alert("Fim Processo.")
	
	

Return()


Static Function CriaSx1(cPerg)
	PutSx1(cPerg, "01", "Emissao de      ?", "" , "", "mv_ch1", "D", 8  , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")     
	PutSx1(cPerg, "02", "Emissao ate     ?", "" , "", "mv_ch2", "D", 8  , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")    
	PutSx1(cPerg, "03", "Produto de      ?", "" , "", "mv_ch3", "C", 15 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "04", "Produto até     ?", "" , "", "mv_ch4", "C", 15 , 0, 2, 'G',"","","","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", "")
Return()